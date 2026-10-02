import {extractTracking,gmailBody,senderName,normalizeTracker,providerCarrier,validTracking} from './tracking.mjs';
import {fedexToken,fetchFedex} from './fedex.mjs';
import {validNotification,applyNotification} from './notification.mjs';
import {upsToken,fetchUps} from './ups.mjs';

const now=()=>Math.floor(Date.now()/1000);
const json=(value,status=200)=>Response.json(value,{status,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
async function getSetting(db,key){return (await db.prepare('SELECT value FROM settings WHERE key=?').bind(key).first())?.value||'';}
async function setSetting(db,key,value){await db.prepare('INSERT INTO settings(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value').bind(key,String(value)).run();}
async function request(url,options={}) {
  // Workers supports manual redirect handling. Reject 3xx below; never forward credentials.
  const response=await fetch(url,{...options,redirect:'manual',signal:AbortSignal.timeout(15000)});
  if(!response.ok)throw new Error(`UPSTREAM_${response.status}`);
  return response.json();
}
async function googleToken(env){
  if(!env.GOOGLE_CLIENT_ID||!env.GOOGLE_CLIENT_SECRET||!env.GOOGLE_REFRESH_TOKEN)throw new Error('GMAIL_NOT_CONNECTED');
  const token=await request('https://oauth2.googleapis.com/token',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({client_id:env.GOOGLE_CLIENT_ID,client_secret:env.GOOGLE_CLIENT_SECRET,refresh_token:env.GOOGLE_REFRESH_TOKEN,grant_type:'refresh_token'})});
  if(!token.access_token)throw new Error('GMAIL_RECONNECT_REQUIRED');
  return token.access_token;
}

export async function discover(env) {
  const token=await googleToken(env),headers={Authorization:'Bearer '+token};
  const query=env.GMAIL_QUERY||'newer_than:30d -in:sent -in:spam -in:trash {subject:tracking subject:shipped subject:shipment subject:delivery}';
  let pageToken=await getSetting(env.DB,'mail_page_token');
  let imported=0,examined=0;
  // Resume longer mailboxes across schedules. Never silently skip the remainder.
  for(let page=0;page<3;page++){
    const params=new URLSearchParams({q:query,maxResults:'50'});if(pageToken)params.set('pageToken',pageToken);
    let batch;
    try{batch=await request('https://gmail.googleapis.com/gmail/v1/users/me/messages?'+params,{headers});}
    catch(error){if(pageToken&&error.message==='UPSTREAM_400'){pageToken='';await setSetting(env.DB,'mail_page_token','');continue;}throw error;}
    for(const {id} of batch.messages||[]){
      if(await env.DB.prepare('SELECT id FROM processed_messages WHERE id=?').bind(id).first())continue;
      const message=await request('https://gmail.googleapis.com/gmail/v1/users/me/messages/'+encodeURIComponent(id)+'?format=full',{headers});
      const packages=extractTracking(gmailBody(message.payload)),sender=senderName(message.payload);
      for(const p of packages){
        // Deduplicate repeat merchant/carrier notifications without replacing a known sender.
        await env.DB.prepare(`INSERT INTO packages(id,carrier,tracking_code,sender,first_seen) VALUES(?,?,?,?,?)
          ON CONFLICT(id) DO UPDATE SET sender=CASE WHEN packages.sender='' THEN excluded.sender ELSE packages.sender END`)
          .bind(p.carrier+':'+p.tracking_code,p.carrier,p.tracking_code,sender,now()).run();imported++;
      }
      await env.DB.prepare('INSERT OR IGNORE INTO processed_messages(id,processed_at) VALUES(?,?)').bind(id,now()).run();examined++;
      // Stay below typical Worker subrequest budgets. Revisit this page and skip processed IDs.
      if(examined>=20){await setSetting(env.DB,'mail_page_token',pageToken);return {imported,backlog:true};}
    }
    pageToken=batch.nextPageToken||'';await setSetting(env.DB,'mail_page_token',pageToken);
    if(!pageToken)break;
  }
  await env.DB.prepare('DELETE FROM processed_messages WHERE processed_at < ?').bind(now()-45*86400).run();
  return {imported,backlog:!!pageToken};
}

export async function refreshTracking(env) {
  const directFedex=!!(env.FEDEX_CLIENT_ID&&env.FEDEX_CLIENT_SECRET);
  const directUps=!!(env.UPS_CLIENT_ID&&env.UPS_CLIENT_SECRET);
  // Legacy paid integration is opt-in; a stray key must never enable billable trackers.
  const legacy=env.ALLOW_PAID_TRACKING==='true'&&!!env.EASYPOST_API_KEY;
  if(!directFedex&&!directUps&&!legacy)throw new Error('TRACKING_NOT_CONNECTED');
  let token='',upsAccess='',failed=false;
  if(directFedex){
    try{token=await fedexToken(env,request);await setSetting(env.DB,'fedex_status','CONNECTED');await setSetting(env.DB,'fedex_error','');}
    catch(error){
      const kind=/^UPSTREAM_\d{3}$/.test(error.message)?error.message:
        /redirect/i.test(error.message)?'REQUEST_REDIRECT_ERROR':
        ['SyntaxError','TypeError','TimeoutError','AbortError'].includes(error.name)?error.name:'FEDEX_AUTH_FAILED';
      await setSetting(env.DB,'fedex_status','CHECK CONNECTION');await setSetting(env.DB,'fedex_error',kind);failed=true;
    }
  }
  if(directUps){
    try{upsAccess=await upsToken(env,request);await setSetting(env.DB,'ups_status','CONNECTED');}
    catch{await setSetting(env.DB,'ups_status','CHECK CONNECTION');failed=true;}
  }
  const headers=legacy?{Authorization:'Basic '+btoa(env.EASYPOST_API_KEY+':'),'Content-Type':'application/json'}:{};
  const carriers=[...(token?["'FEDEX'"]:[]),...(upsAccess?["'UPS'"]:[])];
  const rows=(!legacy&&!carriers.length)?[]:(await env.DB.prepare("SELECT * FROM packages WHERE archived=0 AND status!='delivered'"+(legacy?'':' AND carrier IN ('+carriers.join(',')+')')+" ORDER BY checked_at ASC, id ASC LIMIT 15").all()).results;
  for(const row of rows){
    try{
      let normalized,trackerId=row.tracker_id;
      if(row.carrier==='FEDEX'&&token){normalized=await fetchFedex(row,token,request,env.DELIVERY_TIMEZONE||'UTC');}
      else if(row.carrier==='UPS'&&upsAccess){normalized=await fetchUps(row,upsAccess,request,env.DELIVERY_TIMEZONE||'UTC');}
      else {
        const tracker=row.tracker_id?await request('https://api.easypost.com/v2/trackers/'+encodeURIComponent(row.tracker_id),{headers}):await request('https://api.easypost.com/v2/trackers',{method:'POST',headers,body:JSON.stringify({tracker:{tracking_code:row.tracking_code,carrier:providerCarrier(row.carrier)}})});
        if(!tracker.id||!tracker.status)throw new Error('INVALID_TRACKER');
        normalized=normalizeTracker(tracker,row,env.DELIVERY_TIMEZONE||'UTC');trackerId=tracker.id;
      }
      await env.DB.prepare('UPDATE packages SET tracker_id=?, status=?, normalized=?, checked_at=?, error=NULL WHERE id=?').bind(trackerId,normalized.status,JSON.stringify(normalized),now(),row.id).run();
    }catch{
      failed=true;
      // Preserve last known data. Fair scheduling prevents an invalid number starving other packages.
      await env.DB.prepare('UPDATE packages SET checked_at=?, error=? WHERE id=?').bind(now(),'TRACKING UPDATE FAILED',row.id).run();
    }
  }
  return failed?'CHECK TRACKING CONNECTION':legacy?'CONNECTED':[token?'FEDEX':'',upsAccess?'UPS':''].filter(Boolean).join(' + ')+' CONNECTED';
}

async function scheduled(env) {
  if(env.DISCOVERY_MODE==='imap'){
    const last=Number(await getSetting(env.DB,'last_discovery'));
    if(!last||now()-last>3600)await setSetting(env.DB,'discovery_status','CHECK GMAIL CONNECTION');
  }else{
    try{const result=await discover(env);await setSetting(env.DB,'discovery_status',result.backlog?'IMPORTING':'CONNECTED');await setSetting(env.DB,'last_discovery',now());}
    catch{await setSetting(env.DB,'discovery_status','CHECK GMAIL CONNECTION');}
  }
  try{await setSetting(env.DB,'tracking_status',await refreshTracking(env));}
  catch{await setSetting(env.DB,'tracking_status','CHECK TRACKING CONNECTION');}
  await setSetting(env.DB,'last_run',now());
}

export default {
  async scheduled(controller,env,ctx){ctx.waitUntil(scheduled(env));},
  async fetch(request,env){
    const url=new URL(request.url);
    if(request.method==='POST'&&url.pathname==='/refresh'){
      if(!env.WRITE_KEY||env.WRITE_KEY===env.READ_KEY||request.headers.get('Authorization')!=='Bearer '+env.WRITE_KEY)return json({error:'Unauthorized'},401);
      // A private manual check uses the same bounded path as the 15-minute schedule.
      await scheduled(env);
      return json({tracking_status:await getSetting(env.DB,'tracking_status'),fedex_status:await getSetting(env.DB,'fedex_status'),fedex_error:await getSetting(env.DB,'fedex_error'),ups_status:await getSetting(env.DB,'ups_status')});
    }
    if(request.method==='POST'&&url.pathname==='/discover'){
      if(env.DISCOVERY_MODE!=='imap')return json({error:'Not enabled'},404);
      if(!env.WRITE_KEY||env.WRITE_KEY===env.READ_KEY||request.headers.get('Authorization')!=='Bearer '+env.WRITE_KEY)return json({error:'Unauthorized'},401);
      const body=await request.text();if(body.length>32768)return json({error:'Too large'},413);
      let input;try{input=JSON.parse(body);}catch{return json({error:'Invalid JSON'},400);}
      if(!Array.isArray(input.packages)||input.packages.length>25)return json({error:'Invalid package batch'},400);
      for(const p of input.packages)if(!p||!validTracking(p.carrier,p.tracking_code)||typeof p.sender!=='string'||p.sender.length>150)return json({error:'Invalid package'},400);
      for(const p of input.packages)if(p.notification!==undefined&&!validNotification(p.notification,p.carrier,now()))return json({error:'Invalid notification'},400);
      for(const p of input.packages){
        const code=validTracking(p.carrier,p.tracking_code);
        await env.DB.prepare(`INSERT INTO packages(id,carrier,tracking_code,sender,first_seen) VALUES(?,?,?,?,?)
          ON CONFLICT(id) DO UPDATE SET sender=CASE WHEN packages.sender='' THEN excluded.sender ELSE packages.sender END`)
          .bind(p.carrier+':'+code,p.carrier,code,p.sender.replace(/[\x00-\x1f]/g,' ').trim(),now()).run();
        if(p.notification){await applyNotification(env.DB,{carrier:p.carrier,tracking_code:code,sender:p.sender},p.notification,env.DELIVERY_TIMEZONE||'UTC');await setSetting(env.DB,'email_'+p.carrier,'AVAILABLE');}
      }
      if(input.complete===true){await setSetting(env.DB,'last_discovery',now());await setSetting(env.DB,'discovery_status','CONNECTED');}
      return json({accepted:input.packages.length});
    }
    if(request.method!=='GET'||url.pathname!=='/status')return json({error:'Not found'},404);
    if(!env.READ_KEY||request.headers.get('Authorization')!=='Bearer '+env.READ_KEY)return json({error:'Unauthorized'},401);
    const rows=(await env.DB.prepare("SELECT * FROM packages WHERE archived=0 AND status!='delivered' ORDER BY first_seen ASC,id ASC").all()).results;
    const fedexStatus=await getSetting(env.DB,'fedex_status')||'NOT CONNECTED';
    const upsStatus=await getSetting(env.DB,'ups_status')||'NOT CONNECTED';
    const emailUps=await getSetting(env.DB,'email_UPS'),emailUsps=await getSetting(env.DB,'email_USPS');
    const legacy=env.ALLOW_PAID_TRACKING==='true'&&!!env.EASYPOST_API_KEY;
    const shipments=rows.map(row=>{
      let p;try{p=JSON.parse(row.normalized||'null');}catch{}
      return {...(p||{carrier:row.carrier,sender:row.sender,tracking_last4:row.tracking_code.slice(-4),status:'unknown',stage:-1,latest_message:'TRACKING PENDING'}),sender:row.sender,tracking_connected:p?.source==='EMAIL'||(row.carrier==='FEDEX'&&env.FEDEX_CLIENT_ID?fedexStatus==='CONNECTED':row.carrier==='UPS'&&env.UPS_CLIENT_ID?upsStatus==='CONNECTED':legacy),stale:!!row.error||!row.normalized||now()-row.checked_at>(p?.source==='EMAIL'?86400:3600)};
    });
    return json({schema_version:1,generated_at:Number(await getSetting(env.DB,'last_run'))||0,discovery_status:await getSetting(env.DB,'discovery_status')||'NOT CONNECTED',tracking_status:await getSetting(env.DB,'tracking_status')||'NOT CONNECTED',carrier_status:{FEDEX:fedexStatus,UPS:env.UPS_CLIENT_ID?upsStatus:legacy?'CONFIGURED':emailUps?'EMAIL UPDATES':'NOT CONNECTED',USPS:legacy?'CONFIGURED':emailUsps?'EMAIL UPDATES':'NOT CONNECTED'},shipments});
  }
};
