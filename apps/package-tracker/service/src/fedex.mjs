import {normalizeTracker} from './tracking.mjs';

const status = code => ({DL:'delivered',OD:'out_for_delivery',OC:'pre_transit',PU:'in_transit',IT:'in_transit',AR:'in_transit',DP:'in_transit',AF:'in_transit',FD:'in_transit',AD:'in_transit',LO:'in_transit',AP:'in_transit',AC:'in_transit',HL:'available_for_pickup',DE:'failure',CA:'cancelled',SE:'failure',RS:'return_to_sender'})[code] || 'unknown';
const address = a => ({city:a?.city,state:a?.stateOrProvinceCode,country:a?.countryCode});
const text = x => typeof x==='string'?x.trim().slice(0,300):'';
const clock = value => {
  const match=text(value).match(/T(\d{2}):(\d{2})/);
  if(!match || +match[1]>23 || +match[2]>59)return '';
  return `${+match[1]%12||12}:${match[2]} ${+match[1]>=12?'PM':'AM'}`;
};

export function normalizeFedex(result,record,timezone='UTC') {
  if(result?.error || result?.trackingNumberInfo?.trackingNumber!==record.tracking_code || !result.latestStatusDetail)throw Error('INVALID_FEDEX_RESULT');
  const latest=result.latestStatusDetail;
  const events=(Array.isArray(result.scanEvents)?result.scanEvents:[]).filter(e=>e && typeof e==='object');
  const dates=Array.isArray(result.dateAndTimes)?result.dateAndTimes:[];
  const window=result.estimatedDeliveryTimeWindow?.window||{};
  const expected=dates.find(d=>d.type==='ESTIMATED_DELIVERY')?.dateTime || window.ends || window.begins || '';
  const normalized=normalizeTracker({
    status:status(latest.derivedCode||latest.code),
    tracking_details:events.map(e=>({status:status(e.derivedStatusCode||e.eventType),status_detail:e.eventType==='PU'?'picked_up':'',message:e.eventDescription,datetime:e.date,tracking_location:address(e.scanLocation)})),
    carrier_detail:{est_delivery_date_local:expected,origin_tracking_location:address(result.shipperInformation?.address||result.originLocation?.locationContactAndAddress?.address),destination_tracking_location:address(result.recipientInformation?.address||result.lastUpdatedDestinationAddress)}
  },record,timezone);
  normalized.latest_message=text(latest.statusByLocale||latest.description)||normalized.latest_message;
  const start=clock(window.begins),end=clock(window.ends);
  normalized.delivery_window=start&&end?`${start}-${end}`:end?'BY '+end:'';
  if(!normalized.latest_location){const a=address(latest.scanLocation);normalized.latest_location=[a.city,a.state,a.country==='US'?'':a.country].filter(Boolean).join(', ');}
  return normalized;
}

export async function fedexToken(env,request) {
  const result=await request('https://apis.fedex.com/oauth/token',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded','User-Agent':'Glance-Package-Tracker/1.0','X-locale':'en_US'},body:new URLSearchParams({grant_type:'client_credentials',client_id:env.FEDEX_CLIENT_ID.trim(),client_secret:env.FEDEX_CLIENT_SECRET.trim()})});
  if(!result.access_token)throw Error('FEDEX_AUTH_FAILED');
  return result.access_token;
}

export async function fetchFedex(row,token,request,timezone) {
  const data=await request('https://apis.fedex.com/track/v1/trackingnumbers',{method:'POST',headers:{Authorization:'Bearer '+token,'Content-Type':'application/json','X-locale':'en_US'},body:JSON.stringify({includeDetailedScans:true,trackingInfo:[{trackingNumberInfo:{trackingNumber:row.tracking_code}}]})});
  const matches=(data.output?.completeTrackResults||[]).flatMap(x=>x.trackResults||[]).filter(x=>x.trackingNumberInfo?.trackingNumber===row.tracking_code);
  // Recycled/ambiguous numbers must not silently select someone else's shipment.
  if(matches.length!==1)throw Error('FEDEX_RESULT_AMBIGUOUS');
  return normalizeFedex(matches[0],row,timezone);
}
