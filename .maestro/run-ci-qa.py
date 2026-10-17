#!/usr/bin/env python3
"""Build and observe 1.1.2 on one CI-owned, disposable iOS simulator."""

import argparse
from contextlib import redirect_stdout
import importlib.util
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
from uuid import UUID

ROOT = Path(__file__).resolve().parent.parent
XCRUN = "/usr/bin/xcrun"
APP_ID = "io.DDD.Attendance"
VERSION = "1.1.2"
QA_SPEC = importlib.util.spec_from_file_location("ci_observe", Path(__file__).with_name("run-qa.py"))
qa = importlib.util.module_from_spec(QA_SPEC)
QA_SPEC.loader.exec_module(qa)
DEVICES = {
    "duo": ("com.apple.CoreSimulator.SimDeviceType.iPhone-Duo",
            "com.apple.CoreSimulator.SimRuntime.iOS-27-1"),
    "iphone18pro": ("com.apple.CoreSimulator.SimDeviceType.iPhone-18-Pro",
                    "com.apple.CoreSimulator.SimRuntime.iOS-27-0"),
}


def command(args, *, timeout=120, output=None):
    with subprocess.Popen([str(arg) for arg in args], cwd=ROOT,
                          stdout=output or subprocess.PIPE,
                          stderr=output or subprocess.PIPE,
                          start_new_session=True) as process:
        try:
            stdout, stderr = process.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            raise RuntimeError(f"Timed out: {args[0]}")
        finally:
            # Includes descendants after a CLI leader exits, and interruption by CI cancellation.
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.wait()
        if process.returncode:
            raise RuntimeError(f"Exited {process.returncode}: {args[0]} "
                               f"{(stderr or b'').decode(errors='replace')[-300:]}")
        return stdout or b""


def require_runtime(device_type, runtime):
    listing = json.loads(command([XCRUN, "simctl", "list", "-j"]))
    if not any(item.get("identifier") == device_type for item in listing["devicetypes"]):
        raise ValueError(f"Required device type unavailable: {device_type}")
    if not any(item.get("identifier") == runtime and item.get("isAvailable")
               for item in listing["runtimes"]):
        raise ValueError(f"Required runtime unavailable: {runtime}")


def bundle_metadata(app):
    plist = app / "Info.plist"
    if not plist.is_file():
        raise ValueError("Fresh Stage build did not produce DDDAttendance.app")
    def value(key):
        return command(["/usr/libexec/PlistBuddy", "-c", f"Print :{key}", plist]).decode().strip()
    if value("CFBundleIdentifier") != APP_ID or value("CFBundleShortVersionString") != VERSION:
        raise ValueError("Fresh Stage build is not io.DDD.Attendance 1.1.2")
    build = value("CFBundleVersion")
    if not build:
        raise ValueError("Fresh Stage build has no build number")
    return build


def run(device):
    device_type, runtime = DEVICES[device]
    require_runtime(device_type, runtime)
    artifacts = Path(os.environ.get("ATTENDANCE_QA_ARTIFACTS", ROOT / ".maestro/artifacts/qa")).resolve()
    artifacts.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(prefix=f"ci-{device}-", dir=artifacts))
    udid = None
    error = None
    cleanup_errors = []
    smoke_result = None
    derived = output / "DerivedData"
    pending_signal = None
    def interrupted(signum, frame):
        nonlocal pending_signal
        if udid is None:
            # Keep the short create -> UUID assignment window alive so cleanup owns it.
            pending_signal = signum
            return
        raise InterruptedError(f"QA interrupted by signal {signum}")
    previous_signals = {sig: signal.signal(sig, interrupted)
                        for sig in (signal.SIGTERM, signal.SIGINT)}
    try:
        created = command([XCRUN, "simctl", "create", f"Attendance-CI-1.1.2-{device}",
                           device_type, runtime]).decode().strip()
        udid = str(UUID(created)).upper()
        if pending_signal is not None:
            raise InterruptedError(f"QA interrupted by signal {pending_signal}")
        command([XCRUN, "simctl", "boot", udid])
        command([XCRUN, "simctl", "bootstatus", udid, "-b"], timeout=180)
        destination = f"platform=iOS Simulator,id={udid}"
        with (output / "build.log").open("wb") as log:
            command(["mise", "exec", "--", "tuist", "xcodebuild", "build",
                     "-workspace", "DDDAttendance.xcworkspace",
                     "-scheme", "DDDAttendance-Stage", "-configuration", "Stage",
                     "-destination", destination, "-derivedDataPath", derived,
                     "ONLY_ACTIVE_ARCH=YES", "SWIFT_ENABLE_PREFIX_MAPPING=NO",
                     "CODE_SIGNING_ALLOWED=NO", "COMPILATION_CACHE_ENABLE_CACHING=NO"],
                    timeout=1800, output=log)
        app = derived / "Build/Products/Stage-iphonesimulator/DDDAttendance.app"
        build = bundle_metadata(app)
        command([XCRUN, "simctl", "install", udid, app], timeout=180)
        with (output / "smoke.log").open("w") as log, redirect_stdout(log):
            if qa.run(udid, expected_build=build) != 0:
                raise RuntimeError("Start-screen smoke failed")
    except (ValueError, RuntimeError, OSError) as exc:
        error = exc
    finally:
        for sig in previous_signals:
            signal.signal(sig, signal.SIG_IGN)
        smoke_log = output / "smoke.log"
        try:
            if smoke_log.exists():
                smoke_result = json.loads(smoke_log.read_text())
        except (ValueError, UnicodeError, OSError):
            error = error or ValueError("Smoke result JSON is missing or invalid")
        if error is None and (not isinstance(smoke_result, dict)
                              or smoke_result.get("status") != "passed"
                              or smoke_result.get("udid") != udid
                              or smoke_result.get("app_id") != APP_ID
                              or smoke_result.get("app_version") != VERSION
                              or smoke_result.get("app_build") != build):
            error = ValueError("Exact 1.1.2 smoke result is missing or does not match the fresh build")
        if udid is not None:
            try:
                command([XCRUN, "simctl", "shutdown", udid], timeout=90)
            except (RuntimeError, OSError) as exc:
                cleanup_errors.append(str(exc))
            try:
                command([XCRUN, "simctl", "delete", udid], timeout=90)
            except (RuntimeError, OSError) as exc:
                cleanup_errors.append(str(exc))
        if derived.exists():
            try:
                shutil.rmtree(derived)
            except OSError as exc:
                cleanup_errors.append(str(exc))
        report = {"device": device, "status": "passed" if error is None and not cleanup_errors else "failed",
                  "smoke_result": smoke_result, "cleanup_errors": cleanup_errors,
                  "error": str(error) if error else None}
        try:
            (output / "result.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
        finally:
            for sig, previous in previous_signals.items():
                signal.signal(sig, previous)
    if report["status"] != "passed":
        raise RuntimeError(f"{device} QA failed. Local result: {output / 'result.json'}") from error
    print(f"{device}: 1.1.2 fresh build, install and start-screen smoke passed. "
          f"Local result: {output / 'result.json'}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, choices=sorted(DEVICES))
    args = parser.parse_args()
    try:
        run(args.device)
    except (ValueError, RuntimeError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
