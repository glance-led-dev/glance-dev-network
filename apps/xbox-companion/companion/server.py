"""Single-owner companion. Credentials never enter panel snapshots or logs."""
import base64
import hashlib
import json
import os
from pathlib import Path
import secrets
import threading
import time
from urllib.parse import urlencode, urlsplit
from cryptography.fernet import Fernet
from flask import Flask, request, session, redirect, jsonify
from waitress import serve
from xbox import call, fetch_snapshot

PUBLIC = os.environ['PUBLIC_URL'].rstrip('/')
if urlsplit(PUBLIC).scheme != 'https' or urlsplit(PUBLIC).path or urlsplit(PUBLIC).query:
    raise ValueError('PUBLIC_URL must be an HTTPS origin')
CLIENT = os.environ['CLIENT_ID']
SECRET = os.environ['CLIENT_SECRET']
ADMIN = os.environ['ADMIN_KEY']
READ = os.environ['READ_KEY']
if min(len(ADMIN),len(READ)) < 32 or ADMIN == READ:
    raise ValueError('Use distinct random admin/read keys of at least 32 characters')
BOX = Fernet(os.environ['ENCRYPTION_KEY'].encode())
TOKEN = Path(os.environ.get('DATA_DIR','/data'))/'refresh.enc'
FRIENDS = os.environ.get('SHOW_FRIENDS','false').lower() == 'true'
CALLBACK = PUBLIC+'/auth/callback'
app = Flask(__name__)
app.secret_key = hashlib.sha256(ADMIN.encode()).digest()
app.config.update(SESSION_COOKIE_SECURE=True,SESSION_COOKIE_HTTPONLY=True,
                  SESSION_COOKIE_SAMESITE='Lax',MAX_CONTENT_LENGTH=4096)
snapshot = {'schema':1,'updated':0,'state':'reconnect'}
lock = threading.Lock()
wake = threading.Event()
pending = {}

def save_token(value):
    TOKEN.parent.mkdir(parents=True,exist_ok=True)
    tmp=TOKEN.with_suffix('.tmp')
    fd=os.open(tmp,os.O_WRONLY|os.O_CREAT|os.O_TRUNC,0o600)
    with os.fdopen(fd,'wb') as f:
        f.write(BOX.encrypt(value.encode()))
    os.replace(tmp,TOKEN)

def exchange(payload):
    return call('https://login.microsoftonline.com/consumers/oauth2/v2.0/token',
                dict(payload,client_id=CLIENT,client_secret=SECRET),form=True)

def collect(tokens):
    global snapshot
    if tokens.get('refresh_token'):
        save_token(tokens['refresh_token'])
    _, data=fetch_snapshot(tokens['access_token'],FRIENDS)
    if not data.get('profile',{}).get('gamertag'):
        raise ValueError('Profile unavailable')
    snapshot=data

def poll():
    global snapshot
    while True:
        wake.wait(240)
        wake.clear()
        with lock:
            if not TOKEN.exists():
                continue
            try:
                refresh=BOX.decrypt(TOKEN.read_bytes()).decode()
                collect(exchange({'grant_type':'refresh_token','refresh_token':refresh}))
            except Exception:
                # Keep the original timestamp: never make old data look fresh.
                if time.time()-snapshot.get('updated',0)>300:
                    snapshot={'schema':1,'updated':int(time.time()),'state':'reconnect'}

@app.after_request
def headers(response):
    response.headers['Cache-Control']='no-store'
    response.headers['Referrer-Policy']='no-referrer'
    response.headers['Content-Security-Policy']="default-src 'none'; form-action 'self' https://login.microsoftonline.com https://login.live.com; frame-ancestors 'none'"
    response.headers['X-Content-Type-Options']='nosniff'
    return response

@app.get('/')
def home():
    session['csrf']=secrets.token_urlsafe(32)
    return '<h1>Connect your Xbox</h1><p>Enter the administrator key from your own .env file.</p><form method="post" action="/connect"><input type="hidden" name="csrf" value="'+session['csrf']+'"><input name="key" type="password" required autocomplete="off"><button>Connect Microsoft account</button></form>'

@app.post('/connect')
def connect():
    if not secrets.compare_digest(request.form.get('key',''),ADMIN) or not session.get('csrf') or not secrets.compare_digest(request.form.get('csrf',''),session['csrf']):
        return 'Not authorized',403
    state=secrets.token_urlsafe(32)
    verifier=secrets.token_urlsafe(48)
    with lock:
        for key in list(pending):
            if pending[key][1]<time.time():
                del pending[key]
        pending[state]=(verifier,time.time()+600)
    session.clear()
    session['state']=state
    challenge=base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).decode().rstrip('=')
    return redirect('https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize?'+urlencode({
        'client_id':CLIENT,'redirect_uri':CALLBACK,'response_type':'code',
        'scope':'XboxLive.signin offline_access','state':state,'code_challenge':challenge,
        'code_challenge_method':'S256'}))

@app.get('/auth/callback')
def callback():
    state=request.args.get('state','')
    if not state or not secrets.compare_digest(state,session.get('state','')):
        return 'Connection expired. Start again.',400
    session.clear()
    with lock:
        entry=pending.pop(state,None)
        if not entry or entry[1]<time.time() or not request.args.get('code'):
            return 'Connection expired or declined. Start again.',400
        try:
            tokens=exchange({'grant_type':'authorization_code','code':request.args['code'],
                             'redirect_uri':CALLBACK,'code_verifier':entry[0]})
            if not tokens.get('refresh_token'):
                return 'Microsoft did not issue offline access. Reconnect with consent.',400
            collect(tokens)
        except Exception:
            return 'Connection failed. Check app configuration and try again.',502
    return redirect('/connected')

@app.get('/connected')
def connected():
    return '<h1>Connection attempt finished</h1><p>If successful, your Glance status URL is your HTTPS address followed by /status. Use READ_KEY from your .env as the device read key. The companion refreshes every four minutes.</p>'

@app.get('/status')
def status():
    if not secrets.compare_digest(request.headers.get('Authorization',''),'Bearer '+READ):
        return jsonify(error='Unauthorized'),401
    # Polling by devices cannot trigger extra upstream requests.
    return jsonify(snapshot)

if __name__ == '__main__':
    threading.Thread(target=poll,daemon=True).start()
    wake.set()
    serve(app,host='0.0.0.0',port=8080,threads=4)
