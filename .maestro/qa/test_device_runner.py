"""Safety gates and transport failures without connecting to a real device."""
import importlib.util
import json
from pathlib import Path
import signal
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch
from urllib.error import HTTPError

SPEC = importlib.util.spec_from_file_location("device_qa", Path(__file__).parents[1] / "run-device-qa.py")
qa = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(qa)
UDID = "12345678-0123456789ABCDEF"
TEAM = "ABCDEFGHIJ"
BUNDLE = "com.example.AttendanceQA.WDA"


def details():
    return {"hardwareProperties": {"udid": UDID, "reality": "physical"},
            "connectionProperties": {"pairingState": "paired", "tunnelState": "connected"},
            "deviceProperties": {"developerModeStatus": "enabled", "osVersionNumber": "27.0.1"}}


def apps(version="1.1.2", build="123"):
    return {"apps": [{"bundleIdentifier": qa.APP, "version": version, "bundleVersion": build}]}


class PhysicalTests(unittest.TestCase):
    def test_reject_implicit_device_before_any_command(self):
        with patch.object(qa, "device_json") as command:
            for identifier in ("booted", "iPhone", "123456", "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"):
                with self.assertRaises(ValueError):
                    qa.target(identifier)
            command.assert_not_called()

    def test_reject_wrong_identity_and_unready_device(self):
        for key, field, value in [("hardwareProperties", "udid", "87654321-0123456789ABCDEF"),
                                  ("hardwareProperties", "reality", "simulated"),
                                  ("connectionProperties", "pairingState", "unpaired"),
                                  ("connectionProperties", "tunnelState", "disconnected"),
                                  ("deviceProperties", "developerModeStatus", "disabled")]:
            data = details()
            data[key][field] = value
            with patch.object(qa, "device_json", return_value=data) as command:
                with self.assertRaises(ValueError):
                    qa.target(UDID)
                self.assertEqual(command.call_count, 1)

    def test_version_build_gates_prevent_starting_server(self):
        for app, expected in [(apps("1.0.9"), None), (apps(None), None),
                              (apps(build=None), None), (apps(build=""), None), (apps(), "999")]:
            with patch.object(qa, "device_json", side_effect=[details(), app]), \
                 patch.object(qa.subprocess, "Popen") as popen:
                with self.assertRaises(ValueError):
                    qa.run(UDID, TEAM, BUNDLE, expected)
                popen.assert_not_called()

    def test_exact_device_and_build(self):
        with patch.object(qa, "device_json", side_effect=[details(), apps()]) as command:
            identifier, metadata = qa.target(UDID.lower(), "123")
        self.assertEqual(identifier, UDID)
        self.assertEqual(metadata["app_build"], "123")
        self.assertTrue(all(c.args[0] == UDID for c in command.call_args_list))

    def test_caps_preserve_session_and_disable_provisioning(self):
        caps = qa.capabilities(UDID, TEAM, BUNDLE, 9999, Path("/tmp/qa-test"))
        self.assertEqual(caps["appium:udid"], UDID)
        self.assertTrue(caps["appium:noReset"])
        for key in ("fullReset", "autoLaunch", "forceAppLaunch", "shouldTerminateApp", "useNewWDA",
                    "allowProvisioningDeviceRegistration"):
            self.assertFalse(caps[f"appium:{key}"])
        # WDA adds both provisioning flags only when device registration is enabled.
        self.assertNotIn("appium:allowProvisioningUpdates", caps)
        self.assertNotIn("appium:app", caps)
        self.assertNotIn("appium:otherApps", caps)

    def test_http_failure_and_timeout_propagate(self):
        for error in (HTTPError("http://127.0.0.1", 500, "bad", {}, None), TimeoutError("timeout")):
            opener = Mock()
            opener.open.side_effect = error
            with patch.object(qa, "build_opener", return_value=opener):
                with self.assertRaises((RuntimeError, TimeoutError)):
                    qa.request("http://127.0.0.1:1234", "POST", "/session", {})

    def test_cleanup_targets_owned_group_even_if_leader_exited(self):
        process = Mock(pid=12345)
        with patch.object(qa.os, "killpg") as killpg:
            qa.stop_group(process)
        self.assertEqual(killpg.call_args_list[0].args, (12345, signal.SIGTERM))
        self.assertEqual(killpg.call_args_list[1].args, (12345, signal.SIGKILL))

    def test_failed_session_still_writes_failure_and_cleans_server(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            cli = root / "appium"
            cli.touch()
            driver = root / "home/node_modules/appium-xcuitest-driver/package.json"
            driver.parent.mkdir(parents=True)
            driver.write_text('{"version":"12.18.1"}')
            process = Mock(pid=12345)
            process.poll.return_value = None
            with patch.object(qa, "ROOT", root), patch.object(qa, "CLI", cli), patch.object(qa, "TOOLS", root), \
                 patch.object(qa, "target", return_value=(UDID, {"app_version": "1.1.2", "app_build": "123", "os_version": "27.1"})), \
                 patch.object(qa.qa, "command", return_value=b"3.8.0\n"), \
                 patch.object(qa, "free_port", side_effect=[10001, 10002]), \
                 patch.object(qa.subprocess, "Popen", return_value=process), \
                 patch.object(qa, "request", side_effect=[{"ready": True}, TimeoutError("session timeout")]), \
                 patch.object(qa, "stop_group") as cleanup, patch("builtins.print"):
                self.assertEqual(qa.run(UDID, TEAM, BUNDLE), 1)
                cleanup.assert_called_once_with(process)
            report = json.loads(next(root.glob("artifacts/qa/*/result.json")).read_text())
            self.assertEqual(report["status"], "failed")
            self.assertIn("timeout", report["error"])
            self.assertNotIn("screenshot", report)


if __name__ == "__main__":
    unittest.main()
