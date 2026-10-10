import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {DatabaseSync} from 'node:sqlite';
import worker from '../src/worker.mjs';
test('email fallback rejects invalid batches, orders notifications, and removes delivered without resurrection',async()=>{
 const db=new DatabaseSync(':memory:');db.exec(fs.readFileSync(new URL('../schema.sql',import.meta.url),'utf8'));
 const DB={prepare(sql){return {bind(...a){const s=db.prepare(sql);return {first:async()=>s.get(...a),all:async()=>({results:s.all(...a)}),run:async()=>s.run(...a)};},all:async()=>({results:db.prepare(sql).all()})};}};
 const env={DB,DISCOVERY_MODE:'imap',READ_KEY:'read',WRITE_KEY:'write'};
 const now=Math.floor(Date.now()/1000),p={carrier:'USPS',tracking_code:'9400111899223856928499',sender:'Example Store'};
 const n={status:'in_transit',message:'IN TRANSIT',notified_at:now-60,expected_date:'',delivery_window:''};
 const ingest=packages=>worker.fetch(new Request('https://example.invalid/discover',{method:'POST',headers:{Authorization:'Bearer write'},body:JSON.stringify({packages,complete:true})}),env);
 const feed=async()=>(await worker.fetch(new Request('https://example.invalid/status',{headers:{Authorization:'Bearer read'}}),env)).json();
 try{
  assert.equal((await ingest([{...p,notification:n},{...p,notification:{...n,message:'PRIVATE ARBITRARY TEXT'}}])).status,400);
  assert.equal(db.prepare('SELECT count(*) AS n FROM packages').get().n,0);
  assert.equal((await ingest([{...p,notification:n}])).status,200);
  let data=await feed();assert.equal(data.shipments[0].source,'EMAIL');assert.equal(data.shipments[0].scan_time,'');assert.equal(data.shipments[0].tracking_connected,true);
  assert.ok(!JSON.stringify(data).includes(p.tracking_code));
  await ingest([{...p,notification:{...n,notified_at:now-120,status:'unknown',message:'DELIVERY EXPECTED'}}]);
  assert.equal((await feed()).shipments[0].status,'in_transit');
  await ingest([{...p,notification:{...n,notified_at:now,status:'delivered',message:'DELIVERED'}}]);
  assert.equal((await feed()).shipments.length,0);
  await ingest([{...p,notification:{...n,notified_at:now+1}}]);
  assert.equal((await feed()).shipments.length,0);
 }finally{db.close();}
});
