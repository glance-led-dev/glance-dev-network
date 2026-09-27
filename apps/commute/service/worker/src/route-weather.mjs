import {get,clean,nearRoute,segmentDistance,weatherKind,ohgoSensorTime as sensorTime} from './core.mjs';
import {cached,json,currentWeather} from './providers.mjs';

// OHGO sensor dates currently omit offsets. Interpret those as Ohio local time,
// independently of the server timezone. Prefer the older occurrence at DST fold.
export {ohgoSensorTime as sensorTime} from './core.mjs';
const number=(v,min,max)=>Number.isFinite(v)&&v>=min&&v<=max?v:null;
const fresh=(at,now,minutes)=>Number.isFinite(at)&&at<=now+60000&&now-at<=minutes*60000;
export function roadSensors(payload,line,now){
  const records=get(payload,'results'),stamp=Date.parse(get(payload,'lastUpdated'));
  if(!Array.isArray(records)||!fresh(stamp,now,15)||(get(payload,'rejectedFilters')||[]).length)throw Error('INVALID_SENSOR_FEED');
  if(get(payload,'totalResultCount')>records.length)throw Error('INCOMPLETE_SENSOR_FEED');
  const sites=[];
  for(const r of records){
    const pt={lat:get(r,'latitude'),lon:get(r,'longitude')};
    if(!Number.isFinite(pt.lat)||!Number.isFinite(pt.lon)||!nearRoute(pt,line,.35))continue;
    const atmosphere=(get(r,'atmosphericSensors')||[]).filter(s=>fresh(sensorTime(get(s,'lastUpdate')),now,20)).map(s=>({temperatureF:number(get(s,'airTemperature'),-100,150),visibilityMiles:number(get(s,'visibility'),0,100),description:clean(get(s,'precipitation')||'CONDITIONS UNKNOWN',40),windMph:number(get(s,'averageWindSpeed'),0,200),observedAt:Math.floor(sensorTime(get(s,'lastUpdate'))/1000)}));
    const surfaces=(get(r,'surfaceSensors')||[]).filter(s=>fresh(sensorTime(get(s,'lastUpdate')),now,20)).map(s=>({name:clean(get(s,'name'),60),status:clean(get(s,'status')||'UNKNOWN',32),temperatureF:number(get(s,'surfaceTemperature'),-100,200),subsurfaceF:number(get(s,'subSurfaceTemperature'),-100,200),observedAt:Math.floor(sensorTime(get(s,'lastUpdate'))/1000)}));
    if(atmosphere.length||surfaces.length)sites.push({id:String(get(r,'id')),location:clean(get(r,'location'),100),source:'OHGO',scope:'NEAR ROUTE',atmosphere,surfaces});
  }
  return sites;
}
export function sampleRoute(line){
  if(line.length<2)return line;
  const lengths=line.slice(1).map((p,i)=>segmentDistance(p,line[i],line[i])),total=lengths.reduce((a,b)=>a+b,0);
  let walked=0,middle=line[0];
  for(let i=0;i<lengths.length;i++){
    if(walked+lengths[i]>=total/2){const f=lengths[i]?(total/2-walked)/lengths[i]:0;middle={lat:line[i].lat+(line[i+1].lat-line[i].lat)*f,lon:line[i].lon+(line[i+1].lon-line[i].lon)*f};break;}
    walked+=lengths[i];
  }
  return [line[0],middle,line.at(-1)];
}
export async function collectRouteWeather(lines,env,c,namespace,now,fetcher=fetch){
  let payload=null,ohgoState='unavailable';
  if(c.ohgo&&env.OHGO_KEY)try{
    payload=(await cached(env.COMMUTE,namespace+'weather-sensor-sites',300,now,()=>json('https://publicapi.ohgo.com/api/v1/weather-sensor-sites?page-all=true',{headers:{Authorization:'APIKEY '+env.OHGO_KEY}},fetcher))).value;
    ohgoState='ok';
  }catch{}
  const byRoute=[];
  for(const line of lines){
    const stations=new Map();let missing=0;
    // Actual route points, including the stop detour; repeated stations dedupe.
    for(const [index,p] of sampleRoute(line).entries()){
      try{
        const w=await currentWeather(p,env,namespace+'sample:'+p.lat.toFixed(3)+','+p.lon.toFixed(3)+':',now,fetcher);
        if(!w.stationPoint||!nearRoute(w.stationPoint,line,25))throw Error('STATION_TOO_FAR');
        const {stationPoint,...publicWeather}=w;
        stations.set(w.station,{...publicWeather,location:['NEAR START','NEAR MIDROUTE','NEAR DESTINATION'][index],maxAgeMinutes:45});
      }catch{missing++;}
    }
    let sensors=[];let sensorState=ohgoState;
    if(payload)try{sensors=roadSensors(payload,line,now);}catch{sensorState='unavailable';}
    byRoute.push({state:missing||sensorState!=='ok'?'partial':'ok',nwsState:missing===3?'unavailable':missing?'partial':'ok',ohgoState:sensorState,observations:[...stations.values()],sensors,checkedAt:Math.floor(now/1000)});
  }
  return {direct:byRoute[0],stop:byRoute[1]||null};
}
export function visibilityHazard(value){
  if(!Number.isFinite(value)||value<0)return 'none';
  return value<=.25?'severe':value<1?'warning':value<3?'attention':'none';
}
export function pavementHazard(road){
  const status=String(road?.status||'').toUpperCase(),temp=road?.temperatureF;
  if(/\b(ICE|ICY|FROZEN)\b/.test(status))return 'severe';
  if(/SNOW|SLUSH|FROST/.test(status))return 'warning';
  if(/WET|DAMP/.test(status)&&Number.isFinite(temp))return temp<=32?'warning':temp<=35?'attention':'none';
  return 'none';
}
export function conditionHazard(description){
  const text=String(description||'').toUpperCase();
  if(/THUNDER|FREEZING RAIN|FREEZING DRIZZLE|ICE PELLETS/.test(text))return 'warning';
  if(/SNOW|HEAVY RAIN|FOG/.test(text))return 'attention';
  return 'none';
}
export function weatherSummary(data,now){
  if(!data)return {state:'unavailable',temperatureLowF:null,temperatureHighF:null,visibilityMiles:null,description:'WEATHER UNKNOWN',kind:'unknown',road:null};
  data=structuredClone(data);
  data.observations=data.observations.filter(o=>fresh(o.observedAt*1000,now,45));
  data.sensors=data.sensors.map(s=>({...s,atmosphere:s.atmosphere.filter(o=>fresh(o.observedAt*1000,now,20)),surfaces:s.surfaces.filter(o=>fresh(o.observedAt*1000,now,20))})).filter(s=>s.atmosphere.length||s.surfaces.length);
  const obs=[...data.observations,...data.sensors.flatMap(s=>s.atmosphere.map(a=>({...a,source:'OHGO',location:s.location})))];
  const temperatures=obs.map(o=>o.temperatureF).filter(Number.isFinite),vis=obs.map(o=>o.visibilityMiles).filter(Number.isFinite);
  const rank={storm:0,snow:1,fog:2,rain:3,cloud:4,partly:5,sun:6,moon:7,unknown:8};
  const conditions=obs.filter(o=>o.source==='NWS'||!/^(NONE|UNKNOWN|CONDITIONS UNKNOWN)?$/.test(o.description)).map(o=>({...o,kind:o.kind||weatherKind(o.description)})).sort((a,b)=>rank[a.kind]-rank[b.kind]);
  const priority={severe:0,warning:1,attention:2,none:3};
  const roads=data.sensors.flatMap(s=>s.surfaces.map(r=>({...r,location:s.location,source:'OHGO',hazard:pavementHazard(r)}))).filter(r=>r.hazard!=='none'||(r.temperatureF!==null&&r.temperatureF<=35)).sort((a,b)=>priority[a.hazard]-priority[b.hazard]||(a.temperatureF??200)-(b.temperatureF??200));
  const visibilityMiles=vis.length?Math.min(...vis):null,description=conditions[0]?.description||'CONDITIONS UNKNOWN';
  return {...data,state:obs.length||data.sensors.length?data.state:'unavailable',temperatureLowF:temperatures.length?Math.round(Math.min(...temperatures)):null,temperatureHighF:temperatures.length?Math.round(Math.max(...temperatures)):null,visibilityMiles,visibilityHazard:visibilityHazard(visibilityMiles),description,conditionHazard:conditionHazard(description),kind:conditions[0]?.kind||'unknown',observedAt:obs.length||roads.length?Math.min(...obs.map(o=>o.observedAt),...roads.map(o=>o.observedAt)):null,road:roads[0]||null};
}
