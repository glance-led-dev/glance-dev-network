import {validateConfig,intervalSeconds,publicRoute,sortAlerts,clock,clean,selectCommuteRoute} from './core.mjs';
import {resolveLocation,routeChoices,stopRoute,currentWeather,weatherAlerts,roadEvents,countyAlerts} from './providers.mjs';
import {dashboard} from './dashboard.mjs';
import {collectRouteWeather,weatherSummary} from './route-weather.mjs';

export async function hash(value){return [...new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(value)))].map(b=>b.toString(16).padStart(2,'0')).join('');}
export async function authorized(request,key){
  if(typeof key!=='string'||key.length<24)return false;
  const received=request.headers.get('Authorization')||'';
  const [a,b]=await Promise.all([hash(received),hash('Bearer '+key)]);let diff=0;
  for(let i=0;i<a.length;i++)diff|=a.charCodeAt(i)^b.charCodeAt(i);
  return diff===0;
}
function response(data,status=200){return Response.json(data,{status,headers:{'Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff'}});}
function source(result){return result.status==='fulfilled'?{state:result.value.state||'ok',checkedAt:result.value.checkedAt||null,coverage:result.value.coverage||null,...(result.value.feeds?{feeds:result.value.feeds}:{})}:{state:'unavailable',checkedAt:null};}
async function updateAdvisories(snapshot,geometry,env,c,namespace,now,fetcher){
  if(!geometry?.lines?.length)return snapshot;
  const [nws,roads,county,weather]=await Promise.allSettled([weatherAlerts(geometry.lines,env,c,namespace,now,fetcher),roadEvents(geometry.lines,env,c,namespace,now,fetcher),countyAlerts(geometry.lines,env,c,namespace,now,fetcher),currentWeather(geometry.lines[0][0],env,namespace,now,fetcher)]);
  const alertsFor=i=>sortAlerts([nws,roads,county].flatMap(r=>r.status==='fulfilled'?(r.value.byRoute[i]||[]):[]));
  const routeWeather=await collectRouteWeather(geometry.lines,env,c,namespace,now,fetcher).catch(()=>snapshot.routeWeather||null);
  return {...snapshot,weather:weather.status==='fulfilled'?weather.value:snapshot.weather,routeWeather,alertRouteBasis:'LAST CALCULATED ROUTE',alerts:{direct:alertsFor(0),stop:geometry.lines.length>1?alertsFor(1):[]},sources:{...snapshot.sources,weather:source(weather),weatherAlerts:source(nws),roads:source(roads),county:source(county)}};
}
export async function refresh(env,now=Date.now(),fetcher=fetch){
  const upstream=fetcher,deadline=AbortSignal.timeout(45000);
  fetcher=async(url,options={})=>{
    // Cloudflare and Node do not expose identical AbortSignal helpers.
    const controller=new AbortController(),signals=[deadline,...(options.signal?[options.signal]:[])];
    const abort=()=>controller.abort();
    for(const signal of signals){if(signal.aborted)abort();else signal.addEventListener('abort',abort,{once:true});}
    try{return await upstream(url,{...options,signal:controller.signal});}
    finally{for(const signal of signals)signal.removeEventListener('abort',abort);}
  };
  const c=validateConfig(env.CONFIG_JSON);
  if(!env.TOMTOM_KEY||!env.READ_KEY||env.READ_KEY.length<24)throw Error('SETUP_REQUIRED');
  const namespace=(await hash(env.CONFIG_JSON)).slice(0,20)+':';
  const old=await env.COMMUTE.get(namespace+'snapshot','json');
  const every=intervalSeconds(c,now);
  const retryEvery=old?.state==='ok'?every:Math.min(every,300);
  if(old&&old.updatedAt>0&&now/1000-old.attemptAt<retryEvery-5){
    const geometry=await env.COMMUTE.get(namespace+'geometry','json');
    const updated=await updateAdvisories(old,geometry,env,c,namespace,now,fetcher);
    await env.COMMUTE.put(namespace+'snapshot',JSON.stringify(updated));return updated;
  }
  // Do not expose provider exception text, URLs, credentials or user addresses.
  let locations;
  try{
    locations=await Promise.all([resolveLocation(c.origin,env.TOMTOM_KEY,env.COMMUTE,namespace+'origin',now,fetcher),resolveLocation(c.destination,env.TOMTOM_KEY,env.COMMUTE,namespace+'destination',now,fetcher),c.stop.enabled?resolveLocation(c.stop.location,env.TOMTOM_KEY,env.COMMUTE,namespace+'stop',now,fetcher):null]);
  }catch{
    const failure={schema:1,state:'setup',message:'CHECK LOCATIONS',attemptAt:Math.floor(now/1000),updatedAt:0};
    await env.COMMUTE.put(namespace+'snapshot',JSON.stringify(failure));return failure;
  }
  const [origin,destination,stop]=locations;
  const results=await Promise.allSettled([routeChoices(origin,destination,env.TOMTOM_KEY,now,c.routeOptions,fetcher),stop?stopRoute(origin,stop,destination,c.stop.durationMinutes*60,env.TOMTOM_KEY,now,fetcher):Promise.resolve(null)]);
  if(results[0].status!=='fulfilled'){
    const reason=results[0].reason?.message||'';
    let failure={...(old||{schema:1,updatedAt:0}),state:'unavailable',message:'TRAFFIC UNAVAILABLE',trafficError:/^(PROVIDER_HTTP_\d{3}|RATE_LIMITED|INVALID_ROUTE|MISSING_ROUTE_GEOMETRY|NO_ROUTE)$/.test(reason)?reason:'PROVIDER_UNAVAILABLE',attemptAt:Math.floor(now/1000)};
    failure=await updateAdvisories(failure,await env.COMMUTE.get(namespace+'geometry','json'),env,c,namespace,now,fetcher);
    await env.COMMUTE.put(namespace+'snapshot',JSON.stringify(failure));return failure;
  }
  const candidates=results[0].value.routes,choice=selectCommuteRoute(candidates,old,now),direct=choice.direct,via=results[1].status==='fulfilled'?results[1].value:null;
  const selected=[direct,...(via?[via]:[])],lines=selected.map(r=>r.polyline);
  // Private geometry never goes into the public status response; it lets alerts
  // continue on the last calculated route during a routing-provider outage.
  await env.COMMUTE.put(namespace+'geometry',JSON.stringify({lines}),{expirationTtl:86400});
  const supplemental=await Promise.allSettled([currentWeather(origin,env,namespace,now,fetcher),weatherAlerts(lines,env,c,namespace,now,fetcher),roadEvents(lines,env,c,namespace,now,fetcher),countyAlerts(lines,env,c,namespace,now,fetcher)]);
  const [weather,nws,roads,county]=supplemental;
  const alertsFor=i=>sortAlerts([nws,roads,county].flatMap(r=>r.status==='fulfilled'?r.value.byRoute[i]:[]));
  const snapshot={schema:1,state:'ok',updatedAt:Math.floor(now/1000),attemptAt:Math.floor(now/1000),intervalSeconds:every,label:c.label,timeZone:c.timeZone,checkedTime:clock(now,c.timeZone),arriveBy:c.arriveBy,stopName:c.stop.name,stopEnabled:c.stop.enabled,stopState:results[1].status==='rejected'?'unavailable':via?'ok':'disabled',direct:publicRoute(direct,c,now),stop:publicRoute(via,c,now),addedMinutes:via?Math.round((via.seconds-direct.seconds)/60):null,alternatives:candidates.slice(1).map(r=>publicRoute(r,c,now)),weather:weather.status==='fulfilled'?weather.value:{kind:'unknown',description:'WEATHER UNAVAILABLE',temperatureF:null},sources:{traffic:{state:'ok',checkedAt:Math.floor(now/1000),source:'TomTom'},weather:source(weather),weatherAlerts:source(nws),roads:source(roads),county:source(county)},alerts:{direct:alertsFor(0),stop:via?alertsFor(1):[]},attribution:'TRAFFIC: TOMTOM | WEATHER: NWS | OHIO ROADS: OHGO'};
  snapshot.comparisonPartial=results[0].value.partial;
  snapshot.alternatives=choice.alternatives.map(r=>publicRoute(r,c,now));
  snapshot.recommendation=choice.recommendation;
  snapshot.routeWeather=await collectRouteWeather(lines,env,c,namespace,now,fetcher).catch(()=>null);
  const waze=p=>'https://waze.com/ul?'+new URLSearchParams({ll:p.lat+','+p.lon,navigate:'yes',utm_source:'glance_commute'});
  snapshot.navigation={destination:waze(destination),stop:stop?waze(stop):null};
  await env.COMMUTE.put(namespace+'snapshot',JSON.stringify(snapshot));return snapshot;
}
export function statusView(snapshot,now=Date.now(),arrival=null){
  const value=structuredClone(snapshot),age=Math.max(0,Math.floor(now/1000)-(value.updatedAt||0));
  value.ageSeconds=age;
  value.stale=age>180||value.state!=='ok'||value.updatedAt>now/1000+30;
  value.routeWeather={direct:weatherSummary(value.routeWeather?.direct,now),stop:weatherSummary(value.routeWeather?.stop,now)};
  if(value.state==='ok'&&value.timeZone){
    const target=/^([01]\d|2[0-3]):[0-5]\d$/.test(arrival||'')?arrival:value.arriveBy;
    value.arriveBy=target;
    for(const key of ['direct','stop']){
      const r=value[key];
      if(r&&Number.isFinite(r.seconds)){
        const timing=publicRoute({road:r.road,seconds:r.seconds,normalSeconds:null,freeFlowSeconds:null},{arriveBy:target,timeZone:value.timeZone},now);
        for(const field of ['arrival','leaveBy','leaveAt','late'])r[field]=timing[field];
      }
    }
  }
  for(const key of ['direct','stop'])if(value.alerts?.[key])value.alerts[key]=value.alerts[key].filter(a=>!a.expires||Date.parse(a.expires)>now);
  if(value.weather?.observedAt&&now/1000-value.weather.observedAt>45*60){value.weather={kind:'unknown',description:'WEATHER STALE',temperatureF:null};if(value.sources?.weather)value.sources.weather.state='unavailable';}
  // Coverage ages independently; a valid ETA is not evidence that alerts were checked.
  for(const [k,ttl] of [['weatherAlerts',180],['roads',420],['county',240]]){
    const s=value.sources?.[k];if(s?.checkedAt&&now/1000-s.checkedAt>ttl)s.state='unavailable';
  }
  return value;
}
export default {
  async fetch(request,env){
    const path=new URL(request.url).pathname;
    if(path==='/'&&request.method==='GET')return dashboard();
    if(path!=='/status')return response({error:'NOT_FOUND'},404);
    if(request.method!=='GET')return response({error:'METHOD_NOT_ALLOWED'},405);
    if(!await authorized(request,env.READ_KEY))return response({error:'UNAUTHORIZED'},401);
    if(!env.CONFIG_JSON||!env.COMMUTE)return response({schema:1,state:'setup',message:'CONFIGURE WORKER'},503);
    const namespace=(await hash(env.CONFIG_JSON)).slice(0,20)+':';
    const snapshot=await env.COMMUTE.get(namespace+'snapshot','json');
    if(!snapshot)return response({schema:1,state:'setup',message:'WAIT FOR FIRST CHECK'},503);
    return response(statusView(snapshot,Date.now(),new URL(request.url).searchParams.get('arriveby')));
  },
  async scheduled(controller,env,ctx){
    ctx.waitUntil(refresh(env).catch(async()=>{
      // A config failure changes the namespace; an older route is never served for it.
      // Runtime failures are visible through snapshot age without logging secrets.
    }));
  }
};
