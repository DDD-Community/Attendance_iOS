"""Device isolation and failure reporting regressions; no simulator required."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("qa_runner", Path(__file__).parents[1] / "run-qa.py")
qa = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(qa)
UDID = "6A3E9844-040C-4B1D-9388-0984B681292F"


class DeviceTests(unittest.TestCase):
    def test_rejects_implicit_target_before_invoking_any_command(self):
        with patch.object(qa, "command") as command:
            for value in ["booted", "iPhone Duo", "", "--help"]:
                with self.assertRaises(ValueError):
                    qa.target(value)
            command.assert_not_called()

    def test_rejects_shut_down_or_missing_target(self):
        for devices in [[], [{"udid": UDID, "state": "Shutdown", "isAvailable": True}]]:
            with patch.object(qa, "command", return_value=json.dumps({"devices": {"ios": devices}})) as command:
                with self.assertRaises(ValueError):
                    qa.target(UDID)
                self.assertEqual(command.call_count, 1)

    def test_rejects_missing_app_without_launching(self):
        devices = {"devices": {"ios": [{"udid": UDID, "state": "Booted", "isAvailable": True}]}}
        with patch.object(qa, "command", side_effect=[json.dumps(devices), b"plist", b"{}"]):
            with self.assertRaisesRegex(ValueError, "not installed"):
                qa.target(UDID)

    def test_rejects_wrong_or_incomplete_installed_app_before_launch(self):
        devices = {"devices": {"ios": [{"udid": UDID, "name": "iPhone Duo",
                                        "state": "Booted", "isAvailable": True}]}}
        invalid_apps = [
            ({"CFBundleShortVersionString": "1.0.9", "CFBundleVersion": "109"}, "version 1.1.2"),
            ({"CFBundleVersion": "112"}, "version 1.1.2"),
            ({"CFBundleShortVersionString": "1.1.2"}, "nonempty build"),
            ({"CFBundleShortVersionString": "1.1.2", "CFBundleVersion": ""}, "nonempty build"),
            ({"CFBundleShortVersionString": "1.1.2", "CFBundleVersion": "  "}, "nonempty build"),
        ]
        for app, error in invalid_apps:
            with self.subTest(app=app):
                with patch.object(qa, "command", side_effect=[json.dumps(devices), b"plist",
                                                            json.dumps({qa.APP: app})]) as command:
                    with self.assertRaisesRegex(ValueError, error):
                        qa.run(UDID)
                    self.assertEqual(command.call_count, 3)
                    self.assertFalse(any("launch" in call.args[0] for call in command.call_args_list))

    def test_expected_build_must_match_exactly_before_launch(self):
        devices = {"devices": {"ios": [{"udid": UDID, "name": "iPhone Duo",
                                        "state": "Booted", "isAvailable": True}]}}
        app = {qa.APP: {"CFBundleShortVersionString": "1.1.2", "CFBundleVersion": "2609071448"}}
        with patch.object(qa, "command", side_effect=[json.dumps(devices), b"plist", json.dumps(app)]) as command:
            with self.assertRaisesRegex(ValueError, "Expected .* build 'other'"):
                qa.run(UDID, expected_build="other")
            self.assertEqual(command.call_count, 3)

        with patch.object(qa, "command", side_effect=[json.dumps(devices), b"plist", json.dumps(app)]):
            _, metadata = qa.target(UDID, expected_build="2609071448")
            self.assertEqual(metadata["app_version"], "1.1.2")
            self.assertEqual(metadata["app_build"], "2609071448")

    def exercise(self, fail_test=False, fail_screenshot=False, expected_build=None):
        with tempfile.TemporaryDirectory(prefix="qa test ") as directory:
            root = Path(directory)
            cli = root / "maestro"
            cli.touch()
            calls = []

            def invoke(args, **kwargs):
                args = [str(a) for a in args]
                calls.append(args)
                if "--version" in args:
                    return b"2.11.0\n"
                if "test" in args and fail_test:
                    raise RuntimeError("UI assertion failed")
                if "screenshot" in args and fail_screenshot:
                    raise RuntimeError("Screenshot unavailable")
                return b""

            with patch.object(qa, "ROOT", root), patch.object(qa, "CLI", cli), \
                 patch.object(qa, "target", return_value=(UDID, {"app_id": qa.APP})), \
                 patch.object(qa, "environment", return_value={}), \
                 patch.object(qa, "command", side_effect=invoke), patch("builtins.print"):
                status = qa.run(UDID, expected_build=expected_build)
            result = json.loads(next(root.glob("artifacts/qa/*/result.json")).read_text())
            return status, result, calls

    def test_explicit_target_for_launch_cli_and_screenshot(self):
        status, result, calls = self.exercise()
        self.assertEqual(status, 0)
        self.assertEqual(result["status"], "passed")
        self.assertEqual(result["vision_status"], "not_run")
        targeted = [c for c in calls if any(a in c for a in ["launch", "test", "screenshot"])]
        self.assertEqual(len(targeted), 3)
        for cmd in targeted:
            self.assertIn(UDID, cmd)
            self.assertNotIn("booted", cmd)
            self.assertNotIn("--terminate-running-process", cmd)
        test = next(c for c in calls if "test" in c)
        self.assertEqual(test[test.index("--device") + 1], UDID)
        self.assertTrue(test[-1].endswith("qa/observe.yaml"))
        screenshot = next(c for c in calls if "screenshot" in c)
        self.assertIn("--display=primary", screenshot)
        self.assertEqual(result["display"], "primary")

    def test_successful_screenshot_does_not_hide_failed_assertion(self):
        status, result, _ = self.exercise(fail_test=True)
        self.assertEqual(status, 1)
        self.assertEqual(result["status"], "failed")
        self.assertIn("screenshot", result)
        self.assertIn("UI assertion failed", result["error"])

    def test_missing_screenshot_fails_evidence_collection(self):
        status, result, _ = self.exercise(fail_screenshot=True)
        self.assertEqual(status, 1)
        self.assertEqual(result["status"], "failed")
        self.assertIn("screenshot_error", result)


if __name__ == "__main__":
    unittest.main()
