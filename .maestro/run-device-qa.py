#!/usr/bin/env python3
"""Observe installed Attendance 1.1.2 on one explicitly selected physical iPhone."""
import argparse
import base64
import importlib.util
import json
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
import sys
import tempfile
import time
from urllib.error import HTTPError, URLError
from urllib.request import Request, build_opener, ProxyHandler

ROOT = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("simulator_qa", ROOT / "run-qa.py")
qa = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(qa)
APP = qa.APP
TOOLS = ROOT / ".tools/appium-3.8.0"
CLI = TOOLS / "node_modules/.bin/appium"
ROOT_IDS = ("auth.login.root", "member.home.root", "management.staff.root")
SKELETON_IDS = ("member.home.skeleton", "management.staff.skeleton")


def device_json(udid, args):
    with tempfile.TemporaryDirectory(prefix="attendance-device-") as directory:
        output = Path(directory) / "device.json"
        qa.command([qa.XCRUN, "devicectl", "device", "info", *args,
                    "--device", udid, "--timeout", "15", "--json-output", output], timeout=25)
        return json.loads(output.read_text())["result"]


def target(udid, expected_build=None):
    if not re.fullmatch(r"[0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}", udid):
        raise ValueError("An explicit physical device UDID is required; names and UUIDs are rejected.")
    udid = udid.upper()
    details = device_json(udid, ["details"])
    hardware = details["hardwareProperties"]
    connection = details["connectionProperties"]
    if hardware.get("udid", "").upper() != udid or hardware.get("reality") != "physical":
        raise ValueError("Device identity does not match the requested physical UDID.")
    if (details["deviceProperties"].get("developerModeStatus") != "enabled"
            or connection.get("pairingState") != "paired"
            or connection.get("tunnelState") != "connected"):
        raise ValueError("Device must be paired, connected and have Developer Mode enabled.")
    apps = device_json(udid, ["apps", "--bundle-id", APP])["apps"]
    app = next((a for a in apps if a.get("bundleIdentifier") == APP), None)
    if not app or app.get("version") != "1.1.2" or not app.get("bundleVersion"):
        raise ValueError("Installed Attendance must be exactly 1.1.2 with a nonempty build number.")
    if expected_build is not None and app["bundleVersion"] != expected_build:
        raise ValueError("Installed build does not match --expected-build.")
    return udid, {"app_id": APP, "app_version": app["version"],
                  "app_build": app["bundleVersion"], "os_version": details["deviceProperties"].get("osVersionNumber")}


def capabilities(udid, team, bundle, port, output, platform_version=None):
    if not re.fullmatch(r"[A-Z0-9]{10}", team):
        raise ValueError("Explicit 10-character signing team required.")
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9-]*(?:\.[A-Za-z0-9-]+){2,}", bundle) or bundle.startswith("io.DDD."):
        raise ValueError("Use your own explicit WDA bundle identifier, not the Attendance app namespace.")
    values = {"automationName": "XCUITest", "udid": udid, "bundleId": APP,
              "noReset": True, "fullReset": False, "autoLaunch": False,
              "forceAppLaunch": False, "shouldTerminateApp": False, "useNewWDA": False,
              "xcodeOrgId": team, "xcodeSigningId": "Apple Development",
              "updatedWDABundleId": bundle, "wdaLocalPort": port,
              "derivedDataPath": str(output / "DerivedData"),
              "allowProvisioningDeviceRegistration": False,
              "wdaStartupRetries": 1, "wdaLaunchTimeout": 60000,
              "newCommandTimeout": 120, "showXcodeLog": True}
    if platform_version:
        values["platformVersion"] = platform_version
    return {"platformName": "iOS", **{f"appium:{k}": v for k, v in values.items()}}


def request(base, method, path, data=None, timeout=30):
    # Never route device-control requests through an ambient HTTP proxy.
    body = None if data is None else json.dumps(data).encode()
    req = Request(base + path, data=body, method=method, headers={"Content-Type": "application/json"})
    try:
        with build_opener(ProxyHandler({})).open(req, timeout=timeout) as response:
            result = json.load(response)
    except HTTPError as error:
        try:
            detail = json.loads(error.read()).get("value", {}).get("message", "")[:800]
        except (ValueError, AttributeError):
            detail = ""
        finally:
            error.close()
        raise RuntimeError(f"Appium HTTP {error.code} for {method} {path}: {detail}") from error
    value = result.get("value")
    if isinstance(value, dict) and value.get("error"):
        raise RuntimeError(f"Appium {value['error']}: {value.get('message', '')[:800]}")
    return value


def free_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def stop_group(process):
    # The group is ours even when its leader has already exited.
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        process.wait()
        return
    try:
        process.wait(timeout=3)
    except subprocess.TimeoutExpired:
        pass
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    process.wait()


def observe(base, session):
    prefix = f"/session/{session}"
    def elements(identifier):
        matches = request(base, "POST", prefix + "/elements",
                          {"using": "accessibility id", "value": identifier})
        return any(request(base, "GET", prefix + "/element/" + element[
            "element-6066-11e4-a52e-4f735466cecf"] + "/displayed") for element in matches)
    deadline = time.monotonic() + 30
    while True:
        roots = [identifier for identifier in ROOT_IDS if elements(identifier)]
        skeletons = [identifier for identifier in SKELETON_IDS if elements(identifier)]
        if roots and not skeletons:
            return roots
        if time.monotonic() >= deadline:
            raise RuntimeError("No supported start screen, or a loading skeleton is still visible.")
        time.sleep(1)


def run(udid, team, bundle, expected_build=None):
    # Validate signing arguments before interacting with any device.
    capabilities(udid, team, bundle, 0, Path("unused"))
    udid, metadata = target(udid, expected_build)
    if not CLI.is_file():
        raise ValueError("Run bash .maestro/install-wda-tools.sh first.")
    env = {**os.environ, "APPIUM_HOME": str(TOOLS / "home")}
    if qa.command([CLI, "--version"], env=env, timeout=30).decode().strip() != "3.8.0":
        raise ValueError("Appium 3.8.0 is required.")
    driver = TOOLS / "home/node_modules/appium-xcuitest-driver/package.json"
    if json.loads(driver.read_text()).get("version") != "12.18.1":
        raise ValueError("XCUITest driver 12.18.1 is required.")
    parent = ROOT / "artifacts/qa"
    parent.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(prefix="device-", dir=parent))
    result = {**metadata, "udid": udid, "status": "failed", "scope": "installed-app-start-screen",
              "login_status": "not_exercised", "vision_status": "not_run",
              "signing_team": team, "wda_bundle_id": bundle + ".xctrunner",
              "provisioning_profile": "not_inspected", "wda_may_remain_installed": True}
    port, wda_port = free_port(), free_port()
    while port == wda_port:
        wda_port = free_port()
    base = f"http://127.0.0.1:{port}"
    process, session = None, None
    try:
        with (output / "appium.log").open("wb") as log:
            process = subprocess.Popen([str(CLI), "server", "--address", "127.0.0.1",
                                        "--port", str(port), "--use-drivers", "xcuitest",
                                        "--log-level", "info"], env=env, cwd=TOOLS,
                                       stdout=log, stderr=log, stdin=subprocess.DEVNULL,
                                       start_new_session=True)
            deadline = time.monotonic() + 30
            while True:
                if process.poll() is not None:
                    raise RuntimeError("Appium exited before becoming ready; see appium.log.")
                try:
                    if request(base, "GET", "/status", timeout=2).get("ready"):
                        break
                except (URLError, TimeoutError, RuntimeError):
                    pass
                if time.monotonic() >= deadline:
                    raise RuntimeError("Appium server startup timed out.")
                time.sleep(0.5)
            value = request(base, "POST", "/session", {"capabilities": {
                "alwaysMatch": capabilities(udid, team, bundle, wda_port, output, metadata["os_version"]),
                "firstMatch": [{}]}}, timeout=240)
            session = value["sessionId"]
            result["wda_connected"] = True
            prefix = f"/session/{session}"
            request(base, "POST", prefix + "/appium/device/activate_app", {"bundleId": APP})
            roots = observe(base, session)
            result["visible_roots"] = roots
            result["login_status"] = "awaiting_user_login" if "auth.login.root" in roots else "existing_session_observed"
            picture = request(base, "GET", prefix + "/screenshot")
            (output / "screen.png").write_bytes(base64.b64decode(picture, validate=True))
            result["screenshot"] = str(output / "screen.png")
            result["status"] = "passed"
    except (RuntimeError, ValueError, KeyError, OSError) as error:
        result["error"] = str(error)
    finally:
        if session:
            try:
                request(base, "DELETE", f"/session/{session}", timeout=15)
            except (RuntimeError, OSError, ValueError) as error:
                result["cleanup_error"] = str(error)
                result["status"] = "failed"
        if process:
            stop_group(process)
        (output / "result.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
        print(json.dumps({"status": result["status"], "artifacts": str(output),
                          "error": result.get("error"), "login_status": result["login_status"]}, ensure_ascii=False))
    return 0 if result["status"] == "passed" else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True)
    parser.add_argument("--team", required=True)
    parser.add_argument("--wda-bundle-id", required=True)
    parser.add_argument("--expected-build")
    args = parser.parse_args()
    try:
        sys.exit(run(args.device, args.team, args.wda_bundle_id, args.expected_build))
    except (RuntimeError, ValueError, OSError, KeyError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
