#!/usr/bin/env python3
"""Observe Attendance on one explicit, already booted iOS simulator."""
import argparse
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from uuid import UUID

ROOT = Path(__file__).resolve().parent
APP = "io.DDD.Attendance"
APP_VERSION = "1.1.2"
CLI = ROOT / ".tools/cli-2.11.0/bin/maestro"
XCRUN = "/usr/bin/xcrun"


def command(args, *, env=None, timeout=30, log=None, input_data=None):
    # Only terminate the process group created by this invocation on timeout.
    with subprocess.Popen(
        [str(a) for a in args], cwd=ROOT.parent, env=env,
        stdin=subprocess.PIPE if input_data is not None else subprocess.DEVNULL,
        stdout=log or subprocess.PIPE, stderr=log or subprocess.PIPE,
        start_new_session=True,
    ) as process:
        try:
            out, err = process.communicate(input_data, timeout=timeout)
        except subprocess.TimeoutExpired:
            stop_process_group(process.pid)
            process.communicate()
            raise RuntimeError(f"Command timed out after {timeout}s: {args[0]}")
        finally:
            # Maestro can exit while its xcodebuild is still collecting diagnostics.
            # Reap only this invocation's session, including after a normal exit.
            stop_process_group(process.pid)
        if process.returncode:
            raise RuntimeError(f"Command exited {process.returncode}: {args[0]}\n"
                               + (err or b"").decode(errors="replace")[-2000:])
        return out or b""


def stop_process_group(pid):
    try:
        os.killpg(pid, signal.SIGKILL)
    except ProcessLookupError:
        pass


def target(udid, expected_build=None):
    # Reject 'booted', device names and all implicit device selection.
    udid = str(UUID(udid)).upper()
    listing = json.loads(command([XCRUN, "simctl", "list", "devices", "--json"]))
    device = next((d for group in listing["devices"].values() for d in group
                   if d["udid"].upper() == udid), None)
    if not device or device.get("state") != "Booted" or not device.get("isAvailable"):
        raise ValueError("The explicit UDID must identify an available, booted simulator.")
    apps = command([XCRUN, "simctl", "listapps", udid])
    apps = json.loads(command(["/usr/bin/plutil", "-convert", "json", "-o", "-", "-"],
                              input_data=apps))
    if APP not in apps:
        raise ValueError(f"{APP} is not installed on {udid}.")
    app = apps[APP]
    version = app.get("CFBundleShortVersionString")
    build = app.get("CFBundleVersion")
    if version != APP_VERSION:
        raise ValueError(f"Expected {APP} version {APP_VERSION}; installed version is {version!r}.")
    if not isinstance(build, str) or not build.strip():
        raise ValueError(f"{APP} is missing a nonempty build number.")
    if expected_build is not None and build != expected_build:
        raise ValueError(f"Expected {APP} build {expected_build!r}; installed build is {build!r}.")
    return udid, {"name": device["name"], "app_id": APP,
                  "app_version": version, "app_build": build}


def environment():
    env = os.environ.copy()
    home = env.get("JAVA_HOME")
    if not home:
        for candidate in ("/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home",
                          "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"):
            if (Path(candidate) / "bin/java").is_file():
                home = candidate
                break
    if not home:
        home = command(["/usr/libexec/java_home", "-v", "17+"]).decode().strip()
    java = command([str(Path(home) / "bin/java"), "--version"]).decode()
    major = re.search(r"(?:openjdk|java)\s+(\d+)", java)
    if not major or int(major.group(1)) < 17:
        raise ValueError("Java 17 or later is required. Check JAVA_HOME.")
    env.update(JAVA_HOME=home, MAESTRO_CLI_NO_ANALYTICS="1",
               MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED="true")
    env["PATH"] = f"{ROOT / 'bin'}:{Path(home) / 'bin'}:{env.get('PATH', '')}"
    return env


def run(udid, display="primary", expected_build=None, profile=False):
    udid, metadata = target(udid, expected_build=expected_build)
    if not CLI.is_file():
        raise ValueError("Pinned CLI missing. Run: bash .maestro/install-cli.sh")
    env = environment()
    version = command([CLI, "--version"], env=env, timeout=60).decode().strip()
    if not re.search(r"(?m)^2\.11\.0\s*$", version):
        raise ValueError(f"Expected Maestro 2.11.0; received {version!r}")
    parent = Path(os.environ.get("ATTENDANCE_QA_ARTIFACTS", ROOT / "artifacts/qa")).resolve()
    parent.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(prefix="run-", dir=parent))
    result = {**metadata, "udid": udid, "maestro_version": "2.11.0",
              "started_at": datetime.now(timezone.utc).isoformat(),
              "scope": "authenticated-profile" if profile else "installed-app-start-screen", "status": "failed",
              "vision_status": "not_run", "display": display, "artifacts": str(output)}
    launched = False
    try:
        # simctl does not terminate a running app unless explicitly requested.
        command([XCRUN, "simctl", "launch", udid, APP])
        launched = True
        args = [CLI, "--verbose", "--device", udid, "test", "--debug-output", output / "debug",
                "--format", "junit", "--output", output / "junit.xml",
                ROOT / ("qa/profile.yaml" if profile else "qa/observe.yaml")]
        result["command"] = [str(a) for a in args]
        with (output / "maestro.log").open("wb") as log:
            command(args, env=env, timeout=180, log=log)
        result["status"] = "passed"
    except (RuntimeError, OSError) as error:
        result["error"] = str(error)
    finally:
        if launched:
            try:
                command([XCRUN, "simctl", "io", udid, "screenshot",
                         f"--display={display}", output / "screen.png"])
                result["screenshot"] = str(output / "screen.png")
            except (RuntimeError, OSError) as error:
                result["screenshot_error"] = str(error)
                result["status"] = "failed"
        result["finished_at"] = datetime.now(timezone.utc).isoformat()
        (output / "result.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
        print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["status"] == "passed" else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, help="Explicit booted simulator UDID")
    parser.add_argument("--display", default="primary", help="Screenshot display (default: primary)")
    parser.add_argument("--expected-build", help="Require this exact installed 1.1.2 build number")
    parser.add_argument("--profile", action="store_true", help="Open profile from an already authenticated home; preserve login")
    args = parser.parse_args()
    try:
        sys.exit(run(args.device, args.display, args.expected_build, args.profile))
    except (ValueError, RuntimeError, OSError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
