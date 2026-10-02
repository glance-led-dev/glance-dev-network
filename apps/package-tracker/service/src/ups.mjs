import {normalizeTracker} from './tracking.mjs';
const address=a=>({city:a?.city,state:a?.stateProvince,country:a?.countryCode||a?.country});
const date=v=>/^\d{8}$/.test(v||'')?`${v.slice(0,4)}-${v.slice(4,6)}-${v.slice(6,8)}`:'';
function clock(v){const s=String(v||'').padStart(6,'0');return /^\d{6}$/.test(s)&&+s.slice(0,2)<24&&+s.slice(2,4)<60?`${s.slice(0,2)}:${s.slice(2,4)}:${s.slice(4,6)}`:'';}
function stamp(a){const d=date(a.gmtDate),t=a.gmtTime?clock(a.gmtTime):'';if(d&&t)return `${d}T${t}Z`;const ld=date(a.date),lt=a.time?clock(a.time):'';return ld&&lt&&/^[+-]\d\d:\d\d$/.test(a.gmtOffset||'')?`${ld}T${lt}${a.gmtOffset}`:'';}
function status(s={}){
 if(s.type==='D')return 'delivered';
 if(s.code==='OT'||/^out for delivery\b/i.test(s.simplifiedTextDescription||s.description||''))return 'out_for_delivery';
 return {M:'pre_transit',P:'in_transit',I:'in_transit',X:'failure'}[s.type]||'unknown';
}
function displayClock(v){const t=clock(v);if(!v||!t)return '';const h=+t.slice(0,2);return `${h%12||12}:${t.slice(3,5)} ${h>=12?'PM':'AM'}`;}
export function normalizeUps(p,record,timezone='UTC'){
 if(p.trackingNumber!==record.tracking_code||p.suppressionIndicators?.includes('DETAIL'))throw Error('INVALID_UPS_RESULT');
 const activities=Array.isArray(p.activity)?p.activity:[];
 let current=p.currentStatus||activities[0]?.status;
 if(!current)throw Error('UPS_STATUS_MISSING');
 const latestStatus=activities[0]?.status;
 // Production currentStatus may contain only a numeric code and description.
 // Use the matching latest activity's typed status instead of losing delivery state.
 if(!current.type&&latestStatus&&[latestStatus.statusCode,latestStatus.code].includes(current.code))current={...latestStatus,...current};
 const dates=Array.isArray(p.deliveryDate)?p.deliveryDate:[];
 const expected=dates.find(d=>d.type==='RDD')||dates.find(d=>d.type==='SDD');
 const addresses=Array.isArray(p.packageAddress)?p.packageAddress:[];
 const tracker={status:status(current),est_delivery_date:date(expected?.date),tracking_details:activities.slice().reverse().map(a=>({status:status(a.status),status_detail:a.status?.type==='P'?'picked_up':'',message:a.status?.description,datetime:stamp(a),tracking_location:address(a.location?.address)})),carrier_detail:{origin_tracking_location:address(addresses.find(a=>a.type==='ORIGIN')?.address),destination_tracking_location:address(addresses.find(a=>a.type==='DESTINATION')?.address)}};
 const value=normalizeTracker(tracker,record,timezone);
 // UPS activities are newest-first even when a timestamp has no UTC offset.
 const latest=activities[0];
 value.latest_message=String(current.description||current.simplifiedTextDescription||value.latest_message).slice(0,300);
 if(latest&&!stamp(latest))value.scan_time='';
 const window=p.deliveryTime||{},start=displayClock(window.startTime),end=displayClock(window.endTime);
 if(value.expected_date){
  if(['EDW','CDW','IDW'].includes(window.type)&&start&&end)value.delivery_window=start+'-'+end;
  else if(window.type==='CMT'&&end)value.delivery_window='BY '+end;
  else if(window.type==='EOD')value.delivery_window='BY END OF DAY';
 }
 value.source='UPS API';return value;
}
export async function upsToken(env,request){
 const response=await request('https://onlinetools.ups.com/security/v1/oauth/token',{method:'POST',headers:{Authorization:'Basic '+btoa(env.UPS_CLIENT_ID.trim()+':'+env.UPS_CLIENT_SECRET.trim()),'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({grant_type:'client_credentials'})});
 if(!response.access_token)throw Error('UPS_AUTH_FAILED');return response.access_token;
}
export async function fetchUps(record,token,request,timezone){
 const result=await request('https://onlinetools.ups.com/api/track/v1/details/'+encodeURIComponent(record.tracking_code)+'?locale=en_US&returnSignature=false&returnPOD=false',{headers:{Authorization:'Bearer '+token,transId:crypto.randomUUID(),transactionSrc:'GlancePackageTracker'}});
 const matches=(result.trackResponse?.shipment||[]).flatMap(s=>s.package||[]).filter(p=>p.trackingNumber===record.tracking_code);
 if(matches.length!==1)throw Error('UPS_RESULT_AMBIGUOUS');return normalizeUps(matches[0],record,timezone);
}
