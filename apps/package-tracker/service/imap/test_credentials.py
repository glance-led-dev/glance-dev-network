import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch, Mock
import discover

class CredentialTests(unittest.TestCase):
    def test_linux_reads_only_systemd_credential(self):
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory)/'secrets').write_text(json.dumps({'email':'test@example.invalid','write-key':'test-key'}))
            with patch.dict(os.environ, {'CREDENTIALS_DIRECTORY':directory}), patch.object(discover.sys, 'platform', 'linux'):
                vault=discover.credential_store()
                self.assertEqual(vault.get_password(discover.SERVICE,'write-key'),'test-key')
                self.assertIsNone(vault.get_password(discover.SERVICE,'missing'))
                with self.assertRaises(ValueError):vault.get_password('other','write-key')
                with self.assertRaises(RuntimeError):vault.set_password(discover.SERVICE,'write-key','replacement')

    def test_linux_missing_credential_has_no_fallback(self):
        with patch.dict(os.environ,{},clear=True), patch.object(discover.sys,'platform','linux'):
            with self.assertRaises(RuntimeError):discover.credential_store()

    def test_windows_retains_explicit_native_backend(self):
        backend=Mock()
        with patch.dict('sys.modules',{'keyring':Mock(),'keyring.backends':Mock(),'keyring.backends.Windows':backend}), patch.object(discover.sys,'platform','win32'):
            self.assertIs(discover.credential_store(),backend.WinVaultKeyring.return_value)
            backend.WinVaultKeyring.assert_called_once_with()

if __name__=='__main__':unittest.main()
