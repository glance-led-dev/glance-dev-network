const carrierDomains = {UPS:'ups.com',FEDEX:'fedex.com',USPS:'usps.com'};
const carrierNames = {UPS:'UPS',FEDEX:'FedEx',USPS:'USPS'};
export const providerCarrier = carrier => carrierNames[carrier];
const text = value => typeof value === 'string' ? value.replace(/\s+/g,' ').trim().slice(0,300) : '';
const atDomain = (host,domain) => host===domain || host.endsWith('.'+domain);

export function validTracking(carrier, value) {
  const code=String(value||'').replace(/[\s-]/g,'').toUpperCase();
  if(carrier==='UPS') return /^1Z[A-Z0-9]{16}$/.test(code)?code:null;
  if(carrier==='FEDEX') return /^(\d{12}|\d{15}|\d{20}|\d{22})$/.test(code)?code:null;
  if(carrier==='USPS') return /^(\d{20,22}|[A-Z]{2}\d{9}US)$/.test(code)?code:null;
  return null;
}

export function extractTracking(body) {
  // Parse data only. Do not follow links, execute HTML, or treat email as instructions.
  const result=new Map();
  const add=(carrier,value)=>{const code=validTracking(carrier,value);if(code)result.set(carrier+':'+code,{carrier,tracking_code:code});};
  const decoded=String(body||'').replace(/&amp;/gi,'&').replace(/&#(?:x26|38);/gi,'&');
  for(const match of decoded.matchAll(/https?:\/\/[^\s<>"']+/gi)) {
    let url;try{url=new URL(match[0]);}catch{continue;}
    const carrier=Object.keys(carrierDomains).find(c=>atDomain(url.hostname.toLowerCase(),carrierDomains[c]));
    if(!carrier)continue;
    for(const [key,value] of url.searchParams)if(/^(tracknum|tracknums|tracknumbers|trackingnumber|trackingnumbers|tracking_id|trknbr|track|tlabels|loc)$/i.test(key)) {
      for(const token of value.split(/[;,\s]+/))add(carrier,token);
    }
    // UPS and FedEx sometimes encode the tracking code in a path segment.
    for(const token of url.pathname.split('/'))add(carrier,token);
  }
  for(const match of decoded.matchAll(/\b1Z[A-Z0-9]{16}\b/gi))add('UPS',match[0]);
  // Numeric IDs need a nearby carrier AND tracking label; dates/order numbers are not enough.
  const plain=decoded.replace(/<[^>]*>/g,' ').replace(/&nbsp;/gi,' ');
  for(const match of plain.matchAll(/\b(FedEx|USPS)\b[^\r\n]{0,45}?\btracking(?:\s+(?:number|no\.?|id))?\s*[:#-]?\s*([A-Z]{2}\d{9}US|\d{12,22})\b/gi))add(match[1].toUpperCase(),match[2]);
  return [...result.values()];
}

function decode(data){try{return new TextDecoder().decode(Uint8Array.from(atob(data.replace(/-/g,'+').replace(/_/g,'/')),c=>c.charCodeAt(0)));}catch{return '';}}
export function gmailBody(payload) {
  const parts=[];
  function walk(p,depth=0){if(!p||depth>12||p.filename)return;if(['text/plain','text/html'].includes(p.mimeType)&&p.body?.data)parts.push(decode(p.body.data));for(const child of p.parts||[])walk(child,depth+1);}
  walk(payload);return parts.join('\n').slice(0,500000);
}

export function senderName(payload) {
  const from=payload?.headers?.find(h=>h.name.toLowerCase()==='from')?.value||'';
  const address=(from.match(/<([^>]+)>/)?.[1]||from).trim().toLowerCase();
  const domain=address.split('@')[1]||'';
  if(Object.values(carrierDomains).some(d=>atDomain(domain,d)))return '';
  // A merchant email display name is evidence of the notification sender, not package contents.
  const display=from.includes('<')?from.slice(0,from.indexOf('<')).replace(/^"|"$/g,'').trim():'';
  return text(display);
}

const stageByStatus={pre_transit:0,in_transit:2,out_for_delivery:3,available_for_pickup:3,delivered:4};
const stageByDetail={label_created:0,received_at_origin_facility:1,picked_up:1,received_at_destination_facility:2,out_for_delivery:3,delivered:4};
export function location(value){if(!value||typeof value!=='object')return '';return [...new Set([text(value.city),text(value.state),text(value.country)==='US'?'':text(value.country)].filter(Boolean))].join(', ');}
function dateLabel(date){const match=text(date).match(/^\d{4}-\d{2}-\d{2}/);if(!match)return '';const value=new Date(match[0]+'T12:00:00Z');return Number.isNaN(+value)?'':new Intl.DateTimeFormat('en-US',{timeZone:'UTC',weekday:'short',month:'short',day:'numeric'}).format(value).replace(/,/g,'').toUpperCase();}
function clockLabel(value){const match=text(value).match(/^(\d{2}):(\d{2})/);if(!match)return '';const h=+match[1],m=+match[2];if(h>23||m>59)return '';return `${h%12||12}:${String(m).padStart(2,'0')} ${h>=12?'PM':'AM'}`;}
function scanLabel(value, timezone){const date=new Date(value);if(!value||Number.isNaN(+date))return '';return new Intl.DateTimeFormat('en-US',{timeZone:timezone,month:'short',day:'numeric',hour:'numeric',minute:'2-digit',timeZoneName:'short'}).format(date).replace(/,/g,'').toUpperCase();}

export function normalizeTracker(tracker, record, timezone='UTC') {
  const details=(Array.isArray(tracker.tracking_details)?tracker.tracking_details:[]).filter(x=>x&&typeof x==='object');
  const ordered=details.slice().sort((a,b)=>(Date.parse(a.datetime)||0)-(Date.parse(b.datetime)||0));
  const latest=ordered.at(-1)||{};
  const cd=tracker.carrier_detail||{};
  let stage=-1;
  for(const event of [...ordered,tracker])stage=Math.max(stage,stageByDetail[event.status_detail]??stageByStatus[event.status]??-1);
  const expected=dateLabel(cd.est_delivery_date_local||tracker.est_delivery_date);
  const time=clockLabel(cd.est_delivery_time_local);
  return {
    carrier:record.carrier,sender:text(record.sender),tracking_last4:record.tracking_code.slice(-4),
    status:text(tracker.status)||'unknown',stage,
    expected_date:expected,delivery_window:time?'BY '+time:'',
    latest_message:text(latest.message)||text(tracker.status_detail).replace(/_/g,' ')||text(tracker.status).replace(/_/g,' '),
    latest_location:location(latest.tracking_location),scan_time:scanLabel(latest.datetime,timezone),
    origin:location(cd.origin_tracking_location)||text(cd.origin_location),
    destination:location(cd.destination_tracking_location)||text(cd.destination_location),
  };
}
