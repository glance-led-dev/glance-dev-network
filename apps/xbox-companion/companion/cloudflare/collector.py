"""One-owner Xbox collector. Microsoft tokens stay encrypted on this machine."""
import os,json,time,base64
from pathlib import Path
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from xbox import call,fetch_snapshot
CONFIG=json.loads((Path(os.environ['CREDENTIALS_DIRECTORY'])/'secrets').read_text())
TOKEN=Path('/var/lib/glance-xbox/refresh.enc')
BOX=Fernet(CONFIG['ENCRYPTION_KEY'].encode())
def un64(s):return base64.urlsafe_b64decode(s+'='*((-len(s))%4))
def save(value):
    tmp=TOKEN.with_suffix('.tmp')
    with open(tmp,'wb') as f:f.write(BOX.encrypt(value.encode()));f.flush();os.fsync(f.fileno())
    os.replace(tmp,TOKEN)
def exchange(payload):
    return call('https://login.microsoftonline.com/consumers/oauth2/v2.0/token',dict(payload,client_id=CONFIG['CLIENT_ID'],client_secret=CONFIG['CLIENT_SECRET']),form=True)
def worker(path,payload):return call(CONFIG['PUBLIC_URL']+path,payload,headers={'Authorization':'Bearer '+CONFIG['WRITE_KEY']})
while True:
    stage='cloud handoff'
    try:
        grant=worker('/collector/grant',{}).get('grant')
        tokens=None
        if grant:
            g=json.loads(AESGCM(un64(CONFIG['HANDOFF_KEY'])).decrypt(un64(grant['iv']),un64(grant['data']),None))
            if g['expires']<time.time()*1000:raise ValueError('Expired grant')
            stage='Microsoft sign-in exchange'
            tokens=exchange({'grant_type':'authorization_code','code':g['code'],'redirect_uri':g['redirect_uri'],'code_verifier':g['verifier']})
            if not tokens.get('refresh_token'):raise ValueError('Offline access absent')
        elif TOKEN.exists():
            stage='Microsoft token renewal'
            tokens=exchange({'grant_type':'refresh_token','refresh_token':BOX.decrypt(TOKEN.read_bytes()).decode()})
        if tokens:
            if tokens.get('refresh_token'):save(tokens['refresh_token'])
            stage='Xbox collection'
            checks,data=fetch_snapshot(tokens['access_token'],str(CONFIG.get('SHOW_FRIENDS','false')).lower()=='true')
            if not data.get('profile',{}).get('gamertag'):raise ValueError('Xbox profile unavailable')
            stage='snapshot publication'
            worker('/ingest',data)
            Path('/var/lib/glance-xbox/health.json').write_text(json.dumps({'updated':data['updated'],'published':True,'artwork':bool(data['profile'].get('art'))}))
            print('Xbox snapshot published.',flush=True)
        else:print('Waiting for owner Microsoft sign-in.',flush=True)
    except Exception as e:print('Xbox collection failed at',stage+':',type(e).__name__,flush=True)
    time.sleep(240 if TOKEN.exists() else 15)
