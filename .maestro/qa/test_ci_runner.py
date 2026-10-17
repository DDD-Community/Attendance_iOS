"""CI simulator ownership and fail-closed smoke checks without touching devices."""
import importlib.util
import json
from pathlib import Path
import signal
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("ci_qa", Path(__file__).parents[1] / "run-ci-qa.py")
ci = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ci)
UDID = "6A3E9844-040C-4B1D-9388-0984B681292F"


class CIRunnerTests(unittest.TestCase):
    def test_exact_runtime_is_required_before_creating_device(self):
        listing = {"devicetypes": [{"identifier": ci.DEVICES["duo"][0]}],
                   "runtimes": [{"identifier": ci.DEVICES["duo"][1], "isAvailable": False}]}
        with patch.object(ci, "command", return_value=json.dumps(listing)) as invoke:
            with self.assertRaisesRegex(ValueError, "runtime unavailable"):
                ci.require_runtime(*ci.DEVICES["duo"])
            self.assertEqual(invoke.call_count, 1)

    def test_build_version_and_number_are_checked_before_install(self):
        with tempfile.TemporaryDirectory() as directory:
            app = Path(directory) / "DDDAttendance.app"
            app.mkdir()
            (app / "Info.plist").touch()
            for values, message in [
                ([ci.APP_ID, "1.1.1", "10"], "not io.DDD.Attendance 1.1.2"),
                ([ci.APP_ID, "1.1.2", ""], "no build number"),
            ]:
                with self.subTest(values=values), patch.object(ci, "command",
                                                       side_effect=[s.encode() for s in values]):
                    with self.assertRaisesRegex(ValueError, message):
                        ci.bundle_metadata(app)

    def test_only_created_uuid_is_cleaned_after_smoke_failure(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(ci, "ROOT", Path(directory)), \
             patch.object(ci, "require_runtime"), patch.object(ci, "bundle_metadata", return_value="2609071448"):
            calls = []
            def invoke(args, **kwargs):
                words = [str(arg) for arg in args]
                calls.append(words)
                if "create" in words:
                    return (UDID + "\n").encode()
                return b""
            with patch.object(ci, "command", side_effect=invoke), \
                 patch.object(ci.qa, "run", side_effect=RuntimeError("smoke failed")):
                with self.assertRaisesRegex(RuntimeError, "duo QA failed"):
                    ci.run("duo")
            lifecycle = [words for words in calls if len(words) >= 3 and words[0] == ci.XCRUN]
            self.assertEqual([words[2] for words in lifecycle],
                             ["create", "boot", "bootstatus", "install", "shutdown", "delete"])
            for words in lifecycle[1:]:
                self.assertIn(UDID, words)
            self.assertFalse(any("erase" in words for words in calls))

    def test_success_keeps_exact_smoke_result_and_deletes_owned_simulator(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(ci, "ROOT", Path(directory)), \
             patch.object(ci, "require_runtime"), patch.object(ci, "bundle_metadata", return_value="2609071448"):
            calls = []
            def invoke(args, **kwargs):
                words = [str(arg) for arg in args]
                calls.append(words)
                if "create" in words:
                    return (UDID + "\n").encode()
                return b""
            def observe(udid, expected_build):
                self.assertEqual((udid, expected_build), (UDID, "2609071448"))
                print(json.dumps({"status": "passed", "udid": UDID, "app_id": ci.APP_ID,
                                  "app_version": "1.1.2", "app_build": "2609071448",
                                  "artifacts": str(Path(directory) / ".maestro/artifacts/qa/run-exact")}))
                return 0
            with patch.object(ci, "command", side_effect=invoke), patch.object(ci.qa, "run", side_effect=observe):
                ci.run("duo")
            report = json.loads(next(Path(directory).glob(".maestro/artifacts/qa/ci-duo-*/result.json")).read_text())
            self.assertEqual(report["status"], "passed")
            self.assertEqual(report["smoke_result"]["artifacts"],
                             str(Path(directory) / ".maestro/artifacts/qa/run-exact"))
            self.assertTrue(any("delete" in words and UDID in words for words in calls))
            self.assertFalse(any(Path(directory).glob(".maestro/artifacts/qa/ci-duo-*/DerivedData")))

    def test_shutdown_failure_still_attempts_delete_and_fails_gate(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(ci, "ROOT", Path(directory)), \
             patch.object(ci, "require_runtime"), patch.object(ci, "bundle_metadata", return_value="2609071448"):
            calls = []
            def invoke(args, **kwargs):
                words = [str(arg) for arg in args]
                calls.append(words)
                if "create" in words:
                    return (UDID + "\n").encode()
                if "shutdown" in words:
                    raise OSError("shutdown unavailable")
                return b""
            def observe(udid, expected_build):
                print(json.dumps({"status": "passed", "app_version": "1.1.2",
                                  "app_build": "2609071448", "udid": UDID, "app_id": ci.APP_ID}))
                return 0
            with patch.object(ci, "command", side_effect=invoke), patch.object(ci.qa, "run", side_effect=observe):
                with self.assertRaisesRegex(RuntimeError, "duo QA failed"):
                    ci.run("duo")
            self.assertTrue(any("delete" in words and UDID in words for words in calls))
            report = json.loads(next(Path(directory).glob(".maestro/artifacts/qa/ci-duo-*/result.json")).read_text())
            self.assertEqual(report["status"], "failed")
            self.assertIn("shutdown unavailable", report["cleanup_errors"])

    def test_wrong_smoke_identity_fails_even_if_process_exits_zero(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(ci, "ROOT", Path(directory)), \
             patch.object(ci, "require_runtime"), patch.object(ci, "bundle_metadata", return_value="2609071448"):
            def invoke(args, **kwargs):
                words = [str(arg) for arg in args]
                if "create" in words:
                    return (UDID + "\n").encode()
                return b""
            def observe(udid, expected_build):
                print(json.dumps({"status": "passed", "udid": "other", "app_id": ci.APP_ID,
                                  "app_version": "1.1.2", "app_build": "2609071448"}))
                return 0
            with patch.object(ci, "command", side_effect=invoke), patch.object(ci.qa, "run", side_effect=observe):
                with self.assertRaisesRegex(RuntimeError, "duo QA failed"):
                    ci.run("duo")
            report = json.loads(next(Path(directory).glob(".maestro/artifacts/qa/ci-duo-*/result.json")).read_text())
            self.assertEqual(report["status"], "failed")
            self.assertIn("smoke result", report["error"])

    def test_interruption_still_deletes_created_uuid(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(ci, "ROOT", Path(directory)), \
             patch.object(ci, "require_runtime"), patch.object(ci, "bundle_metadata", return_value="2609071448"):
            calls = []
            def invoke(args, **kwargs):
                words = [str(arg) for arg in args]
                calls.append(words)
                if "create" in words:
                    return (UDID + "\n").encode()
                return b""
            previous = signal.getsignal(signal.SIGTERM)
            with patch.object(ci, "command", side_effect=invoke), \
                 patch.object(ci.qa, "run", side_effect=InterruptedError("CI cancelled")):
                with self.assertRaisesRegex(RuntimeError, "duo QA failed"):
                    ci.run("duo")
            self.assertTrue(any("delete" in words and UDID in words for words in calls))
            self.assertEqual(signal.getsignal(signal.SIGTERM), previous)

    def test_cancellation_during_create_waits_for_uuid_before_cleanup(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(ci, "ROOT", Path(directory)), \
             patch.object(ci, "require_runtime"):
            calls = []
            def invoke(args, **kwargs):
                words = [str(arg) for arg in args]
                calls.append(words)
                if "create" in words:
                    signal.raise_signal(signal.SIGTERM)
                    return (UDID + "\n").encode()
                return b""
            with patch.object(ci, "command", side_effect=invoke):
                with self.assertRaisesRegex(RuntimeError, "duo QA failed"):
                    ci.run("duo")
            self.assertTrue(any("delete" in words and UDID in words for words in calls))
            self.assertFalse(any("boot" in words for words in calls))

    def test_create_failure_does_not_clean_an_existing_device(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(ci, "ROOT", Path(directory)), \
             patch.object(ci, "require_runtime"):
            calls = []
            def invoke(args, **kwargs):
                calls.append([str(arg) for arg in args])
                raise RuntimeError("create failed")
            with patch.object(ci, "command", side_effect=invoke):
                with self.assertRaisesRegex(RuntimeError, "duo QA failed"):
                    ci.run("duo")
            self.assertEqual(len(calls), 1)
            self.assertIn("create", calls[0])


if __name__ == "__main__":
    unittest.main()
