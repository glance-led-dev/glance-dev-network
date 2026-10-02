import test from 'node:test';
import assert from 'node:assert/strict';
import {normalizeUps,upsToken,fetchUps} from '../src/ups.mjs';
const record={carrier:'UPS',tracking_code:'1Z999AA10123456784',sender:'Example Store'};
const p={trackingNumber:record.tracking_code,currentStatus:{type:'I',code:'OT',description:'Out for Delivery'},activity:[{date:'20260926',time:'080000',gmtOffset:'-04:00',location:{address:{city:'Dayton',stateProvince:'OH',country:'US',addressLine1:'PRIVATE STREET'}},status:{type:'I',code:'OT',description:'Out for Delivery'}}],deliveryDate:[{type:'SDD',date:'20260927'},{type:'RDD',date:'20260928'}],deliveryTime:{type:'EDW',startTime:'140000',endTime:'180000'},packageAddress:[{type:'ORIGIN',address:{city:'Austin',stateProvince:'TX'}},{type:'DESTINATION',address:{city:'Dayton',stateProvince:'OH'}}]};
test('UPS maps package identity, rescheduled delivery window, scan timezone, and only coarse addresses',()=>{
 const n=normalizeUps(p,record,'America/New_York');
 assert.equal(n.status,'out_for_delivery');assert.equal(n.stage,3);assert.equal(n.expected_date,'MON SEP 28');assert.equal(n.delivery_window,'2:00 PM-6:00 PM');assert.match(n.scan_time,/8:00 AM EDT/);assert.equal(n.latest_location,'Dayton, OH');
 assert.ok(!JSON.stringify(n).includes('PRIVATE STREET'));assert.ok(!JSON.stringify(n).includes(record.tracking_code));
 assert.throws(()=>normalizeUps({...p,trackingNumber:'wrong'},record));
 assert.equal(normalizeUps({...p,currentStatus:{type:'D'},deliveryDate:[{type:'DEL',date:'20260926'}]},record).expected_date,'');
 assert.equal(normalizeUps({...p,activity:[{...p.activity[0],gmtOffset:''}]},record).scan_time,'');
 assert.equal(normalizeUps({...p,currentStatus:{code:'011',description:'Delivered'},activity:[{...p.activity[0],status:{type:'D',code:'KB',statusCode:'011'}}]},record).status,'delivered');
});
test('UPS authenticates automatically, requests no proof/signature, rejects ambiguous results',async()=>{
 let calls=0;
 const request=async(url,options)=>{calls++;assert.equal(new URL(url).hostname,'onlinetools.ups.com');
  if(url.includes('/oauth/')){assert.equal(options.body.get('grant_type'),'client_credentials');return {access_token:'fixture-token'};}
  assert.equal(options.headers.Authorization,'Bearer fixture-token');assert.match(url,/returnSignature=false&returnPOD=false/);return {trackResponse:{shipment:[{package:[p]}]}};
 };
 const token=await upsToken({UPS_CLIENT_ID:'fixture',UPS_CLIENT_SECRET:'fixture'},request);
 assert.equal((await fetchUps(record,token,request,'UTC')).status,'out_for_delivery');assert.equal(calls,2);
 await assert.rejects(fetchUps(record,token,async()=>({trackResponse:{shipment:[{package:[p,p]}]}})),/AMBIGUOUS/);
});
