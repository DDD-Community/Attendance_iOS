"""Tuist 캐시 명령 라우팅을 다운로드나 실제 빌드 없이 검증한다."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class CacheCommandsTests(unittest.TestCase):
    def run_command(self, arguments, *, ci=False, failure=None):
        with tempfile.TemporaryDirectory(prefix="attendance-cache-test-") as directory:
            folder = Path(directory)
            log = folder / "commands.jsonl"
            mise = folder / "mise"
            mise.write_text(
                f"#!{sys.executable}\n"
                "import json, os, sys\n"
                "args = sys.argv[1:]\n"
                "with open(os.environ['COMMAND_LOG'], 'a') as log:\n"
                "    log.write(json.dumps(args) + '\\n')\n"
                "failure = os.environ.get('FAIL_COMMAND', '')\n"
                "sys.exit(7 if failure and failure in args else 0)\n"
            )
            mise.chmod(0o755)
            environment = os.environ.copy()
            for key in ("CI", "GITHUB_ACTIONS", "TUIST_CI"):
                environment.pop(key, None)
            environment.update(
                PATH=f"{folder}:{environment['PATH']}",
                COMMAND_LOG=str(log),
                FAIL_COMMAND=failure or "",
            )
            if ci:
                environment["CI"] = "true"
            result = subprocess.run(
                [str(ROOT / "make"), *arguments],
                cwd=ROOT,
                env=environment,
                capture_output=True,
                text=True,
                timeout=60,
            )
            calls = (
                [json.loads(line) for line in log.read_text().splitlines()]
                if log.exists()
                else []
            )
            return result, [call[3:] for call in calls if call[:3] == ["exec", "--", "tuist"]]

    def test_generate_uses_prepared_cache_without_authentication(self):
        result, calls = self.run_command(["generate", "--no-open"], failure="auth")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [["generate", "--no-open"]])

    def test_install_prepares_cache_before_generate(self):
        result, calls = self.run_command(["install", "--no-open"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            calls,
            [
                ["install"],
                ["setup", "cache"],
                ["cache", "warm", "--cache-profile", "only-external"],
                ["generate", "--no-open"],
            ],
        )

    def test_binary_cache_opt_out_skips_warm(self):
        result, calls = self.run_command(["install", "--no-binary-cache", "--no-open"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            calls,
            [
                ["install"],
                ["setup", "cache"],
                ["generate", "--no-binary-cache", "--no-open"],
            ],
        )

    def test_ci_skips_local_cache_preparation(self):
        result, calls = self.run_command(["install"], ci=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [["install"], ["generate"]])

    def test_install_failure_stops_chain(self):
        result, calls = self.run_command(["install"], failure="install")
        self.assertEqual(result.returncode, 7)
        self.assertEqual(calls, [["install"]])

    def test_cache_setup_failure_stops_before_warm(self):
        result, calls = self.run_command(["install"], failure="setup")
        self.assertEqual(result.returncode, 7)
        self.assertEqual(calls, [["install"], ["setup", "cache"]])

    def test_warm_failure_stops_before_generate(self):
        result, calls = self.run_command(["install"], failure="warm")
        self.assertEqual(result.returncode, 7)
        self.assertEqual(
            calls,
            [
                ["install"],
                ["setup", "cache"],
                ["cache", "warm", "--cache-profile", "only-external"],
            ],
        )

    def test_cache_warms_external_dependencies(self):
        result, calls = self.run_command(["cache"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [["cache", "warm", "--cache-profile", "only-external"]])

    def test_explicit_cache_profile_is_preserved(self):
        for options in (["--cache-profile", "all-possible"], ["--cache-profile=none"]):
            with self.subTest(options=options):
                result, calls = self.run_command(["cache", "warm", *options])
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls, [["cache", "warm", *options]])

    def test_legacy_flags_are_translated(self):
        for flag, profile in (("--external-only", "only-external"),
                              ("--no-external-only", "all-possible")):
            with self.subTest(flag=flag):
                result, calls = self.run_command(["cache", flag])
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls, [["cache", "warm", "--cache-profile", profile]])

    def test_cache_setup_runs_tuist_setup(self):
        result, calls = self.run_command(["cache:setup"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [["setup", "cache"]])

    def test_setup_prepares_cache_before_generate(self):
        result, calls = self.run_command(["setup", "--no-open"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            calls,
            [
                ["install"],
                ["setup", "cache"],
                ["cache", "warm", "--cache-profile", "only-external"],
                ["generate", "--no-open"],
            ],
        )


if __name__ == "__main__":
    unittest.main()
