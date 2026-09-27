import os,sys,tempfile
from pathlib import Path
from cryptography.fernet import Fernet
root=Path(__file__).resolve().parent
sys.path.insert(0,str(root))
with tempfile.TemporaryDirectory() as d:
 os.environ.update(PUBLIC_URL='https://example.invalid',CLIENT_ID='test',CLIENT_SECRET='test',ADMIN_KEY='a'*40,READ_KEY='b'*40,ENCRYPTION_KEY=Fernet.generate_key().decode(),DATA_DIR=d)
 import server as s
 c=s.app.test_client()
 assert c.get('/status').status_code==401
 assert c.get('/status',headers={'Authorization':'Bearer '+'b'*40}).status_code==200
 assert c.post('/connect',data={'key':'a'*40}).status_code==403
 c.get('/',base_url='https://example.invalid')
 with c.session_transaction(base_url="https://example.invalid") as ss: csrf=ss['csrf']
 r=c.post('/connect',base_url='https://example.invalid',data={'key':'a'*40,'csrf':csrf})
 assert r.status_code==302 and 'code_challenge=' in r.location and 'offline_access' in r.location
 from urllib.parse import urlsplit,parse_qs
 state=parse_qs(urlsplit(r.location).query)['state'][0]
 assert c.get('/auth/callback?state=wrong&code=test',base_url='https://example.invalid').status_code==400
 s.exchange=lambda p:{'access_token':'fake-access','refresh_token':'fake-refresh'}
 s.fetch_snapshot=lambda *a: ([],{'schema':1,'state':'ready','updated':123,'profile':{'gamertag':'TEST'}})
 r=c.get('/auth/callback?state='+state+'&code=test',base_url='https://example.invalid')
 assert r.status_code==302
 assert b'fake-refresh' not in s.TOKEN.read_bytes()
 assert s.BOX.decrypt(s.TOKEN.read_bytes())==b'fake-refresh'
 assert c.get('/auth/callback?state='+state+'&code=test',base_url='https://example.invalid').status_code==400
 assert 'fake-' not in c.get('/status',headers={'Authorization':'Bearer '+'b'*40}).text
 print('PASS: read-key boundary, CSRF, PKCE/offline scope, callback state/replay, encrypted persistence, snapshot secret exclusion')
