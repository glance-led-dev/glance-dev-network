"""Provision this owner's Linux credentials without printing secret values."""
import os,json,getpass,secrets,base64,subprocess
from pathlib import Path
from urllib.parse import urlsplit
if os.geteuid()!=0:raise SystemExit('Run using sudo.')
target=Path('/etc/glance/xbox.cred')
if target.exists():raise SystemExit('Credentials already exist; refusing to replace the encryption key.')
url=input('Your Worker HTTPS origin: ').strip().rstrip('/')
p=urlsplit(url)
if p.scheme!='https' or not p.hostname or p.path or p.query or p.fragment or p.username:raise SystemExit('Use an HTTPS origin without a path.')
c={'PUBLIC_URL':url,'CLIENT_ID':input('Your Microsoft client ID: ').strip()}
c['SHOW_FRIENDS']='true' if input('Collect shared friend activity (y/N)? ').strip().lower()=='y' else 'false'
for name in ['CLIENT_SECRET','WRITE_KEY','HANDOFF_KEY']:c[name]=getpass.getpass(name+': ').strip()
if len(base64.urlsafe_b64decode(c['HANDOFF_KEY']+'='*((-len(c['HANDOFF_KEY']))%4)))!=32:raise SystemExit('HANDOFF_KEY must encode exactly 32 bytes.')
if not c['CLIENT_SECRET'] or len(c['WRITE_KEY'])<32:raise SystemExit('Missing or weak credentials.')
c['ENCRYPTION_KEY']=base64.urlsafe_b64encode(secrets.token_bytes(32)).decode()
target.parent.mkdir(mode=0o700,exist_ok=True)
p=subprocess.run(['systemd-creds','encrypt','--with-key=host','--name=secrets','-',str(target)],input=json.dumps(c).encode(),capture_output=True)
if p.returncode:raise SystemExit('Credential encryption failed.')
os.chmod(target,0o600)
print('Encrypted service credentials saved. Back up the host credential key with the VM.')
