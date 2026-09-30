const enc=new TextEncoder();
const headers={'Cache-Control':'no-store','Referrer-Policy':'no-referrer','X-Content-Type-Options':'nosniff','Content-Security-Policy':"default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; frame-ancestors 'none'"};
const b64=b=>btoa(String.fromCharCode(...new Uint8Array(b))).replaceAll('+','-').replaceAll('/','_').replace(/=+$/,'');
const un64=s=>Uint8Array.from(atob(s.replaceAll('-','+').replaceAll('_','/')),c=>c.charCodeAt(0));
const random=()=>b64(crypto.getRandomValues(new Uint8Array(32)));
const digest=async s=>new Uint8Array(await crypto.subtle.digest('SHA-256',enc.encode(s)));
export async function equal(a,b){const x=await digest(String(a)),y=await digest(String(b));let v=0;for(let i=0;i<x.length;i++)v|=x[i]^y[i];return v===0;}
const json=(o,status=200,extra={})=>new Response(JSON.stringify(o),{status,headers:{...headers,'Content-Type':'application/json',...extra}});
const html=(s,extra={})=>new Response('<!doctype html><meta name="viewport" content="width=device-width"><title>Xbox Companion</title><style>body{font:18px system-ui;max-width:40rem;margin:4rem auto;padding:1rem;background:#111;color:#eee}input,button{font:inherit;padding:.7rem;margin:.5rem 0}button{background:#107c10;color:white;border:0;border-radius:.3rem}a{color:#8bdc65}</style>'+s,{headers:{...headers,'Content-Type':'text/html; charset=utf-8',...extra}});
const cookie=(req,name)=>{const value=(req.headers.get('Cookie')||'').split(';').map(s=>s.trim()).find(s=>s.startsWith(name+'='));return value?value.slice(name.length+1):'';};
const setCookie=(name,value,age=600)=>`${name}=${value}; Secure; HttpOnly; SameSite=Lax; Path=/; Max-Age=${age}`;
async function sign(text,key){const k=await crypto.subtle.importKey('raw',enc.encode(key),{name:'HMAC',hash:'SHA-256'},false,['sign']);return b64(await crypto.subtle.sign('HMAC',k,enc.encode(text)));}
async function csrf(key){const value=Date.now()+'.'+random();return value+'.'+await sign(value,key);}
async function checkCsrf(value,key){const parts=value.split('.');return parts.length===3&&Date.now()-Number(parts[0])>=0&&Date.now()-Number(parts[0])<600000&&await equal(parts[2],await sign(parts.slice(0,2).join('.'),key));}
export async function seal(value,key){const k=await crypto.subtle.importKey('raw',un64(key),'AES-GCM',false,['encrypt']);const iv=crypto.getRandomValues(new Uint8Array(12));return {iv:b64(iv),data:b64(await crypto.subtle.encrypt({name:'AES-GCM',iv},k,enc.encode(JSON.stringify(value))))};}
async function readBody(req,max=2_000_000){const reader=req.body?.getReader();if(!reader)return '';let size=0,chunks=[];for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>max){await reader.cancel();throw Error('SIZE');}chunks.push(value);}const data=new Uint8Array(size);let pos=0;for(const c of chunks){data.set(c,pos);pos+=c.length;}return new TextDecoder().decode(data);}
const text=s=>typeof s==='string'?s.slice(0,256):'';
function art(value){return Array.isArray(value)&&value.length===26&&value.every(r=>Array.isArray(r)&&r.length===26&&r.every(p=>typeof p==='string'&&/^#[0-9a-fA-F]{6}$/.test(p)))?value:[];}
export function snapshot(value,friends=false){
  if(value?.schema!==1||value.state!=='ready'||!Number.isFinite(value.updated)||Math.abs(Date.now()/1000-value.updated)>600||!value.profile?.gamertag)throw Error('SNAPSHOT');
  const item=v=>({name:text(v?.name),detail:text(v?.detail),art:art(v?.art)});
  const out={schema:1,updated:value.updated,state:'ready',profile:{gamertag:text(value.profile.gamertag),score:text(String(value.profile.score??'')),art:art(value.profile.art)},presence:{state:text(value.presence?.state),device:text(value.presence?.device),title:text(value.presence?.title),rich:text(value.presence?.rich),art:art(value.presence?.art)},achievements:(Array.isArray(value.achievements)?value.achievements:[]).slice(0,5).map(v=>({name:text(v.name),score:text(String(v.score??'')),game:text(v.game),unlocked:text(v.unlocked),art:art(v.art)})),activity:{state:text(value.activity?.state),items:(Array.isArray(value.activity?.items)?value.activity.items:[]).slice(0,5).map(item)},friends:{state:'disabled',items:[]}};
  if(value.lastplayed)out.lastplayed={title:text(value.lastplayed.title),date:text(value.lastplayed.date),art:art(value.lastplayed.art)};
  if(friends)out.friends={state:text(value.friends?.state),items:(Array.isArray(value.friends?.items)?value.friends.items:[]).slice(0,20).map(item)};
  return out;
}
export class XboxOwner {
  constructor(state,env){this.storage=state.storage;this.env=env;}
  async fetch(req){
    const e=this.env,u=new URL(req.url),path=u.pathname;
    if(u.origin!==e.PUBLIC_URL)return json({error:'Host mismatch'},400);
    if(!e.ADMIN_KEY||!e.READ_KEY||!e.WRITE_KEY||!e.HANDOFF_KEY)return json({error:'Setup incomplete'},503);
    const authenticated=async key=>equal(req.headers.get('Authorization')||'','Bearer '+key);
    if(path==='/status'&&req.method==='GET'){
      if(!await authenticated(e.READ_KEY))return json({error:'Unauthorized'},401);
      return json(await this.storage.get('snapshot')||{schema:1,updated:0,state:'reconnect'});
    }
    if(path==='/ingest'&&req.method==='POST'){
      if(!await authenticated(e.WRITE_KEY))return json({error:'Unauthorized'},401);
      const value=snapshot(JSON.parse(await readBody(req)),e.SHOW_FRIENDS==='true');await this.storage.put('snapshot',value);return json({ok:true});
    }
    if(path==='/collector/grant'&&req.method==='POST'){
      if(!await authenticated(e.WRITE_KEY))return json({error:'Unauthorized'},401);
      const grant=await this.storage.transaction(async tx=>{const g=await tx.get('grant');await tx.delete('grant');return g;});
      return json(grant&&grant.expires>Date.now()?{grant:grant.box}:{grant:null});
    }
    // A short-lived, single-use setup ticket lets the owner connect without copying keys.
    if(path==='/admin/ticket'&&req.method==='POST'){
      if(!await authenticated(e.ADMIN_KEY))return json({error:'Unauthorized'},401);
      const ticket=random();await this.storage.put('ticket',{hash:b64(await digest(ticket)),expires:Date.now()+300000});return json({ticket});
    }
    if(path==='/start'&&req.method==='POST'){
      const form=new URLSearchParams(await readBody(req,4096));
      const ticket=await this.storage.transaction(async tx=>{const t=await tx.get('ticket');if(t&&t.expires>Date.now()&&await equal(t.hash,b64(await digest(form.get('ticket')||'')))){await tx.delete('ticket');return t;}return null;});
      if(!ticket)return json({error:'Setup link expired'},403);
      return this.begin();
    }
    if(path==='/'&&req.method==='GET'){
      const token=await csrf(e.ADMIN_KEY);
      return html('<h1>Your Xbox Companion</h1><p>This private installation serves one account. Community users deploy their own copy.</p><form method="post" action="/connect"><input type="hidden" name="csrf" value="'+token+'"><label>Administrator key<br><input name="key" type="password" required autocomplete="off"></label><br><button>Connect Microsoft account</button></form>',{'Set-Cookie':setCookie('xbox_csrf',token)});
    }
    if(path==='/connect'&&req.method==='POST'){
      if(req.headers.get('Origin')!==e.PUBLIC_URL)return json({error:'Unauthorized'},403);
      const form=new URLSearchParams(await readBody(req,4096)),token=form.get('csrf')||'';
      if(!await equal(token,cookie(req,'xbox_csrf'))||!await checkCsrf(token,e.ADMIN_KEY)||!await equal(form.get('key')||'',e.ADMIN_KEY))return json({error:'Unauthorized'},403);
      return this.begin();
    }
    if(path==='/auth/callback'&&req.method==='GET'){
      const state=u.searchParams.get('state')||'',code=u.searchParams.get('code')||'';
      if(!state||!code||code.length>4096||!await equal(state,cookie(req,'xbox_state')))return json({error:'Connection expired or declined'},400);
      const pending=await this.storage.transaction(async tx=>{const p=await tx.get('pending');if(p&&p.expires>Date.now()&&await equal(p.state,state)){await tx.delete('pending');return p;}return null;});
      if(!pending)return json({error:'Connection expired'},400);
      const key=await crypto.subtle.importKey('raw',un64(e.HANDOFF_KEY),'AES-GCM',false,['decrypt']);
      const verifier=JSON.parse(new TextDecoder().decode(await crypto.subtle.decrypt({name:'AES-GCM',iv:un64(pending.verifier.iv)},key,un64(pending.verifier.data))));
      await this.storage.put('grant',{expires:Date.now()+600000,box:await seal({code,verifier,redirect_uri:e.PUBLIC_URL+'/auth/callback',expires:Date.now()+600000},e.HANDOFF_KEY)});
      return new Response(null,{status:303,headers:{...headers,Location:e.PUBLIC_URL+'/connected','Set-Cookie':setCookie('xbox_state','',0)}});
    }
    if(path==='/connected'&&req.method==='GET')return html('<h1>Sign-in received</h1><p>Your private collector is finishing the connection. It can take up to four minutes.</p><p>Your account tokens are stored encrypted on your own server. Cloudflare receives only a short-lived encrypted sign-in handoff and your display snapshot.</p>');
    return json({error:'Not found'},404);
  }
  async begin(){
    const state=random(),verifier=random()+random();
    await this.storage.put('pending',{state,verifier:await seal(verifier,this.env.HANDOFF_KEY),expires:Date.now()+600000});
    const query=new URLSearchParams({client_id:this.env.CLIENT_ID,redirect_uri:this.env.PUBLIC_URL+'/auth/callback',response_type:'code',scope:'XboxLive.signin offline_access',state,code_challenge:b64(await digest(verifier)),code_challenge_method:'S256'});
    return new Response(null,{status:303,headers:{...headers,Location:'https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize?'+query,'Set-Cookie':setCookie('xbox_state',state)}});
  }
}
export default {async fetch(request,env){try{return await env.OWNER.get(env.OWNER.idFromName('owner')).fetch(request);}catch{return json({error:'Request failed'},400);}}};
