import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {DatabaseSync} from 'node:sqlite';
import {normalizeFedex} from '../src/fedex.mjs';
import worker,{refreshTracking} from '../src/worker.mjs';

const record={carrier:'FEDEX',tracking_code:'123456789012',sender:'Example Shop'};
const result={trackingNumberInfo:{trackingNumber:record.tracking_code},latestStatusDetail:{code:'OD',statusByLocale:'On vehicle for delivery'},scanEvents:[{date:'2026-09-26T08:00:00-04:00',eventType:'OD',eventDescription:'On vehicle',scanLocation:{city:'Dayton',stateOrProvinceCode:'OH',countryCode:'US'}}],dateAndTimes:[{type:'ESTIMATED_DELIVERY',dateTime:'2026-09-26T20:00:00-04:00'}],estimatedDeliveryTimeWindow:{window:{begins:'2026-09-26T12:00:00-04:00',ends:'2026-09-26T16:00:00-04:00'}},shipperInformation:{address:{city:'Austin',stateOrProvinceCode:'TX',streetLines:['PRIVATE STREET']}},recipientInformation:{address:{city:'Dayton',stateOrProvinceCode:'OH'}}};
test('FedEx preserves identity, delivery window, scan zone and coarse locations',()=>{
 const p=normalizeFedex(result,record,'America/New_York');
 assert.equal(p.tracking_last4,'9012');assert.equal(p.status,'out_for_delivery');assert.equal(p.stage,3);
 assert.equal(p.delivery_window,'12:00 PM-4:00 PM');assert.equal(p.expected_date,'SAT SEP 26');
 assert.equal(p.latest_location,'Dayton, OH');assert.match(p.scan_time,/8:00 AM EDT/);
 assert.ok(!JSON.stringify(p).includes('PRIVATE STREET'));assert.ok(!JSON.stringify(p).includes(record.tracking_code));
});
test('FedEx delays retain known progress and missing dates stay unknown',()=>{
 const p=normalizeFedex({...result,latestStatusDetail:{code:'DE',statusByLocale:'Delayed'},dateAndTimes:[],estimatedDeliveryTimeWindow:null},record);
 assert.equal(p.status,'failure');assert.equal(p.stage,3);assert.equal(p.expected_date,'');assert.equal(p.delivery_window,'');
 assert.throws(()=>normalizeFedex({...result,error:{code:'NOT_FOUND'}},record));
 assert.throws(()=>normalizeFedex(result,{...record,tracking_code:'999999999999'}));
});
test('direct FedEx schedule refreshes automatically, preserves failures, removes delivered and never calls paid providers',async()=>{
 const db=new DatabaseSync(':memory:');db.exec(fs.readFileSync(new URL('../schema.sql',import.meta.url),'utf8'));
 const DB={prepare(sql){return {bind(...args){const s=db.prepare(sql);return {first:async()=>s.get(...args),all:async()=>({results:s.all(...args)}),run:async()=>s.run(...args)};},all:async()=>({results:db.prepare(sql).all()})};}};
 const env={DB,DISCOVERY_MODE:'imap',READ_KEY:'read',WRITE_KEY:'write',FEDEX_CLIENT_ID:'fixture-client',FEDEX_CLIENT_SECRET:'fixture-secret',EASYPOST_API_KEY:'must-not-be-used'};
 const insert=db.prepare('INSERT INTO packages(id,carrier,tracking_code,sender,first_seen) VALUES(?,?,?,?,?)');
 insert.run('fx','FEDEX',record.tracking_code,record.sender,1);insert.run('ups','UPS','1Z999AA10123456784','Other Shop',0);
 const original=globalThis.fetch;let fail=false,delivered=false,authCalls=0,trackCalls=0;
 globalThis.fetch=async(url,options)=>{
  assert.equal(new URL(url).hostname,'apis.fedex.com');assert.equal(options.redirect,'manual');
  if(url.endsWith('/oauth/token')){authCalls++;assert.equal(options.body.get('grant_type'),'client_credentials');return Response.json({access_token:'fixture-token'});}
  trackCalls++;assert.equal(JSON.parse(options.body).trackingInfo[0].trackingNumberInfo.trackingNumber,record.tracking_code);
  if(fail)return Response.json({}, {status:503});
  return Response.json({output:{completeTrackResults:[{trackResults:[{...result,latestStatusDetail:delivered?{code:'DL',statusByLocale:'Delivered'}:result.latestStatusDetail}]}]}});
 };
 const call=key=>worker.fetch(new Request('https://example.invalid/refresh',{method:'POST',headers:{Authorization:'Bearer '+key}}),env);
 const feed=async()=>(await worker.fetch(new Request('https://example.invalid/status',{headers:{Authorization:'Bearer read'}}),env)).json();
 try{
  assert.equal((await call('read')).status,401);assert.equal(authCalls,0);
  assert.equal((await call('write')).status,200);let data=await feed();
  assert.equal(data.carrier_status.FEDEX,'CONNECTED');assert.equal(data.carrier_status.UPS,'NOT CONNECTED');
  assert.equal(data.shipments.find(p=>p.carrier==='UPS').tracking_connected,false);
  assert.equal(data.shipments.find(p=>p.carrier==='FEDEX').tracking_connected,true);
  fail=true;await call('write');data=await feed();assert.equal(data.shipments.find(p=>p.carrier==='FEDEX').stale,true);
  assert.equal(data.shipments.find(p=>p.carrier==='FEDEX').status,'out_for_delivery');
  fail=false;delivered=true;await call('write');data=await feed();assert.equal(data.shipments.length,1);assert.equal(data.shipments[0].carrier,'UPS');
  assert.equal(authCalls,3);assert.equal(trackCalls,3);
  delete env.FEDEX_CLIENT_ID;delete env.FEDEX_CLIENT_SECRET;
  await assert.rejects(refreshTracking(env),/TRACKING_NOT_CONNECTED/);
 }finally{globalThis.fetch=original;db.close();}
});
