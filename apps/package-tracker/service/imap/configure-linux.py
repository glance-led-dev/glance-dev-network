"""Provision encrypted Linux credentials without files containing plaintext."""
import getpass
import json
import os
from pathlib import Path
import subprocess
from urllib.parse import urlsplit
from discover import connect, upload

def main():
    if os.geteuid() != 0:
        raise SystemExit('Run with sudo.')
    target = Path('/etc/glance/packages.cred')
    if target.exists():
        raise SystemExit('Credentials already exist; keep a backup before replacing them.')
    values = {'email': input('Gmail address: ').strip()}
    values['app-password'] = getpass.getpass('Gmail app password: ').replace(' ', '')
    values['endpoint'] = input('Your HTTPS Worker /discover URL: ').strip()
    url = urlsplit(values['endpoint'])
    if url.scheme != 'https' or not url.hostname or url.path != '/discover' or url.username or url.password or url.query or url.fragment:
        raise SystemExit('Use an HTTPS /discover URL with no query or credentials.')
    values['write-key'] = getpass.getpass('Worker WRITE_KEY: ').strip()
    if not all(values.values()):
        raise SystemExit('All values are required.')
    client = connect(values['email'], values['app-password'])
    client.logout()
    upload(values['endpoint'], values['write-key'], [], False)
    target.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    result = subprocess.run(['systemd-creds', 'encrypt', '--with-key=host', '--name=secrets', '-', str(target)], input=json.dumps(values).encode(), capture_output=True)
    if result.returncode:
        raise SystemExit('Credential encryption failed.')
    target.chmod(0o600)
    print('Connections verified; encrypted credentials saved.')

if __name__ == '__main__':
    try:
        main()
    except Exception:
        raise SystemExit('Setup failed; check account and service configuration.') from None
