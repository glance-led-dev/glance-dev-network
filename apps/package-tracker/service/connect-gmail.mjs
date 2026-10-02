// Run locally only. Opens no third-party pages and never prints tokens.
// Supply Google's downloaded Desktop-app client JSON as argv[2].
import fs from 'node:fs';
import http from 'node:http';
import crypto from 'node:crypto';

const file=process.argv[2];
if(!file){console.error('Usage: node connect-gmail.mjs path/to/google-client.json');process.exit(1);}
const config=JSON.parse(fs.readFileSync(file,'utf8')).installed;
if(!config?.client_id){console.error('Use a Google OAuth Desktop-app client JSON.');process.exit(1);}
const state=crypto.randomBytes(32).toString('base64url'),verifier=crypto.randomBytes(48).toString('base64url');
const challenge=crypto.createHash('sha256').update(verifier).digest('base64url');
const server=http.createServer(async(req,res)=>{
 const url=new URL(req.url,'http://127.0.0.1');
 if(url.pathname!=='/callback'){res.writeHead(404).end();return;}
 if(url.searchParams.get('state')!==state){res.writeHead(400).end('Invalid authorization state.');return;}
 const code=url.searchParams.get('code');
 if(!code){res.writeHead(400).end('Authorization was not completed.');return;}
 try{
  const response=await fetch('https://oauth2.googleapis.com/token',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({client_id:config.client_id,client_secret:config.client_secret||'',code,code_verifier:verifier,redirect_uri:redirect,grant_type:'authorization_code'}),signal:AbortSignal.timeout(20000)});
  const tokens=await response.json();
  if(!response.ok||!tokens.refresh_token)throw Error('No refresh token');
  fs.writeFileSync('google-refresh.secret',tokens.refresh_token,{mode:0o600,flag:'wx'});
  res.writeHead(200,{'Content-Type':'text/plain','Cache-Control':'no-store'}).end('Connected. You may close this tab.');
  console.log('Refresh token saved to ignored local file google-refresh.secret. Upload it as GOOGLE_REFRESH_TOKEN using Wrangler, then remove that local file.');
  clearTimeout(timer);server.close();
 }catch{
  res.writeHead(400).end('Connection could not be saved. Check your client settings and whether google-refresh.secret already exists.');
  console.error('Connection failed; no token was printed.');
 }
});
let redirect;
server.listen(0,'127.0.0.1',()=>{
 redirect=`http://127.0.0.1:${server.address().port}/callback`;
 const url=new URL('https://accounts.google.com/o/oauth2/v2/auth');
 url.search=new URLSearchParams({client_id:config.client_id,redirect_uri:redirect,response_type:'code',scope:'https://www.googleapis.com/auth/gmail.readonly',access_type:'offline',prompt:'consent',state,code_challenge:challenge,code_challenge_method:'S256'}).toString();
 console.log('Open this Google authorization link in your browser:\n'+url.toString());
});
const timer=setTimeout(()=>{server.close();console.error('Authorization timed out. Run the helper again when ready.');},10*60*1000);
