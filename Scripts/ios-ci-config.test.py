"""Secrets and runner-local configuration must drive the same CI inputs."""
import base64
import io
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'Scripts/restore-ios-ci-config.sh'
GOOGLE = 'Projects/App/Resources/GoogleService-Info.plist'

class CIConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.local = self.base / 'local'
        self.checkout = self.base / 'checkout'
        self.checkout.mkdir()
        for name in ('base', 'Stage', 'Prod'):
            self.write(self.local, f'Config/{name}.xcconfig', f'local-{name}')
        self.write(self.local, 'Config/extra.xcconfig', 'local-include')
        self.write(self.local, GOOGLE, 'local-plist')

    def write(self, root, path, value):
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(value)

    def run_restore(self, **values):
        env = os.environ.copy()
        env.update(CONFIG_TAR='', GOOGLE_PLIST='', IOS_LOCAL_CONFIG_ROOT=str(self.local))
        env.update(values)
        return subprocess.run(['bash', str(SCRIPT)], cwd=self.checkout, env=env, text=True, capture_output=True)

    def archive(self):
        data = io.BytesIO()
        with tarfile.open(fileobj=data, mode='w:gz') as archive:
            for name in ('base', 'Stage', 'Prod'):
                body = f'secret-{name}'.encode()
                entry = tarfile.TarInfo(f'Config/{name}.xcconfig')
                entry.size = len(body)
                archive.addfile(entry, io.BytesIO(body))
        return base64.b64encode(data.getvalue()).decode()

    def test_fork_uses_local_files_including_extra_includes(self):
        result = self.run_restore()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.checkout / 'Config/base.xcconfig').read_text(), 'local-base')
        self.assertEqual((self.checkout / 'Config/extra.xcconfig').read_text(), 'local-include')
        self.assertEqual((self.checkout / GOOGLE).read_text(), 'local-plist')
        self.assertEqual((self.local / GOOGLE).read_text(), 'local-plist')
        self.assertNotIn('local-plist', result.stdout + result.stderr)

    def test_secrets_take_precedence_without_local_snapshot(self):
        result = self.run_restore(CONFIG_TAR=self.archive(), GOOGLE_PLIST=base64.b64encode(b'secret-plist').decode(), IOS_LOCAL_CONFIG_ROOT=str(self.base / 'missing'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.checkout / 'Config/base.xcconfig').read_text(), 'secret-base')
        self.assertEqual((self.checkout / GOOGLE).read_text(), 'secret-plist')

    def test_partial_secrets_fall_back_independently(self):
        result = self.run_restore(CONFIG_TAR=self.archive())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.checkout / GOOGLE).read_text(), 'local-plist')
        self.assertEqual((self.checkout / 'Config/base.xcconfig').read_text(), 'secret-base')

    def test_missing_local_inputs_fail_before_mutation(self):
        (self.local / GOOGLE).unlink()
        result = self.run_restore()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Missing runner-local', result.stderr)
        self.assertEqual(list(self.checkout.iterdir()), [])

    def test_invalid_secret_does_not_silently_use_local_inputs(self):
        result = self.run_restore(CONFIG_TAR='not-base64!')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.checkout / 'Config').exists())

    def test_default_snapshot_is_under_runner_home(self):
        home = self.base / 'home'
        target = home / '.config/ddd-attendance-ci'
        target.parent.mkdir(parents=True)
        self.local.rename(target)
        result = self.run_restore(HOME=str(home), IOS_LOCAL_CONFIG_ROOT='')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_empty_token_does_not_override_local_authentication(self):
        action = (ROOT / '.github/actions/setup-ios-runner/action.yml').read_text()
        step = action.split('    - name: Configure Tuist authentication\n', 1)[1]
        script = '\n'.join(line[8:] for line in step.split('      run: |\n', 1)[1].splitlines())
        for token in ('', 'fake-ci-token'):
            with self.subTest(token=bool(token)):
                exported = self.base / 'github-env'
                exported.write_text('')
                env = dict(os.environ, CI_TUIST_TOKEN=token, GITHUB_ENV=str(exported))
                result = subprocess.run(['bash', '-e', '-c', script], env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(exported.read_text(), f'TUIST_TOKEN={token}\n' if token else '')
                if token:
                    self.assertIn(f'::add-mask::{token}', result.stdout)

if __name__ == '__main__':
    unittest.main()
