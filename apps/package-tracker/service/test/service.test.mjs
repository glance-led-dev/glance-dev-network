import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {DatabaseSync} from 'node:sqlite';
import worker from '../src/worker.mjs';

test('scheduled Gmail discovery -> deduplicated tracker -> private feed -> delivered removal',async()=>{
 const database=new DatabaseSync(':memory:');
 database.exec(fs.readFileSync(new URL('../schema.sql',import.meta.url),'utf8'));
 const DB={prepare(sql){return {bind(...args){const statement=database.prepare(sql);return {first:async()=>statement.get(...args),all:async()=>({results:statement.all(...args)}),run:async()=>statement.run(...args)};},all:async()=>({results:database.prepare(sql).all()}),first:async()=>database.prepare(sql).get(),run:async()=>database.prepare(sql).run()};}};
 const env={DB,READ_KEY:'fixture-read',GOOGLE_CLIENT_ID:'fixture-client',GOOGLE_CLIENT_SECRET:'fixture-secret',GOOGLE_REFRESH_TOKEN:'fixture-refresh',EASYPOST_API_KEY:'fixture-provider',ALLOW_PAID_TRACKING:'true',DELIVERY_TIMEZONE:'UTC'};
 let delivered=false,created=0,failGmail=false,failTracking=false;
 const original=globalThis.fetch;
 globalThis.fetch=async(url,options={})=>{
  const u=new URL(url);
  if(u.hostname==='oauth2.googleapis.com')return failGmail?Response.json({error:'invalid_grant'},{status:400}):Response.json({access_token:'fixture-access'});
  if(u.hostname==='gmail.googleapis.com'){
   assert.equal(options.headers.Authorization,'Bearer fixture-access');
   if(u.pathname.endsWith('/messages'))return Response.json({messages:[{id:'m1'},{id:'m2'}]});
   return Response.json({payload:{mimeType:'text/plain',headers:[{name:'From',value:'Example Store <shipping@example.invalid>'}],body:{data:Buffer.from('UPS tracking number 1Z999AA10123456784. PRIVATE BODY MUST NOT BE STORED').toString('base64url')}}});
  }
  if(u.hostname==='api.easypost.com'){
   if(failTracking)return Response.json({error:'unavailable'},{status:503});
   if(options.method==='POST')created++;
   return Response.json({id:'trk_fixture',status:delivered?'delivered':'in_transit',tracking_details:[{status:'in_transit',message:'Departed facility',datetime:'2026-09-26T12:00:00Z',tracking_location:{city:'Austin',state:'TX'}}]});
  }
  throw Error('Unexpected external request');
 };
 const run=async()=>{let promise;await worker.scheduled({},env,{waitUntil(p){promise=p;}});await promise;};
 const status=async()=>(await worker.fetch(new Request('https://example.invalid/status',{headers:{Authorization:'Bearer fixture-read'}}),env)).json();
 try{
  await run();let feed=await status();assert.equal(created,1);assert.equal(feed.shipments.length,1);assert.equal(feed.shipments[0].sender,'Example Store');assert.equal(feed.shipments[0].tracking_last4,'6784');
  assert.ok(!JSON.stringify(feed).includes('1Z999'));assert.ok(!JSON.stringify(feed).includes('fixture-provider'));
  assert.ok(!JSON.stringify(database.prepare('SELECT * FROM packages').all()).includes('PRIVATE BODY'));
  await run();assert.equal(created,1);
  failGmail=true;failTracking=true;await run();feed=await status();assert.equal(feed.shipments.length,1);assert.equal(feed.shipments[0].stale,true);assert.equal(feed.discovery_status,'CHECK GMAIL CONNECTION');
  failGmail=false;failTracking=false;delivered=true;await run();feed=await status();assert.equal(feed.shipments.length,0);assert.equal(feed.discovery_status,'CONNECTED');
  env.DISCOVERY_MODE='imap';env.WRITE_KEY='fixture-write';
  const ingest=(body,key='fixture-write')=>worker.fetch(new Request('https://example.invalid/discover',{method:'POST',headers:{Authorization:'Bearer '+key},body:JSON.stringify(body)}),env);
  assert.equal((await ingest({packages:[]},'fixture-read')).status,401);
  assert.equal((await ingest({packages:[{carrier:'USPS',tracking_code:'bad',sender:'Shop'}]})).status,400);
  const input={packages:[{carrier:'USPS',tracking_code:'9400111899223856928499',sender:'Postal Store'}],complete:true};
  assert.equal((await ingest(input)).status,200);assert.equal((await ingest(input)).status,200);
  feed=await status();assert.equal(feed.shipments.length,1);assert.equal(feed.shipments[0].tracking_last4,'8499');assert.equal(feed.discovery_status,'CONNECTED');
 }finally{globalThis.fetch=original;database.close();}
});
