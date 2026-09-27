import test from 'node:test';
import assert from 'node:assert/strict';
import {validateConfig,intervalSeconds,arriveTarget,clock,roadIdentity,routeName,normalizeRoute,combineStop,publicRoute,nearRoute,polygonHits,intersects,weatherKind,ohgoEvents,nwsEvents,sortAlerts,selectCommuteRoute} from '../worker/src/core.mjs';
import {json,routes,stopRoute,routeChoices,resolveLocation,currentWeather,weatherAlerts,roadEvents,countyAlerts} from '../worker/src/providers.mjs';
import worker,{refresh,statusView,hash} from '../worker/src/worker.mjs';

const now=Date.parse('2026-09-28T11:00:00Z'); // Monday 07:00 EDT
test('provider redirects are rejected with the Workers-compatible manual mode',async()=>{
 let calls=0;
 await assert.rejects(json('https://example.com/data',{headers:{Authorization:'private'}},async(url,options)=>{
   calls++;assert.equal(options.redirect,'manual');
   return new Response(null,{status:302,headers:{Location:'https://other.example.com'}});
 }),/PROVIDER_HTTP_302/);
 assert.equal(calls,1);
});
test('weather falls back from a stale nearest station to a fresh nearby station',async()=>{
  const kv=new KV();
  const fetcher=async url=>{
    const path=new URL(url).pathname;
    if(path.startsWith('/points/'))return Response.json({properties:{observationStations:'https://api.weather.gov/gridpoints/TEST/stations'}});
    if(path.endsWith('/stations'))return Response.json({features:['OLD','FRESH'].map(id=>({id:'https://api.weather.gov/stations/'+id}))});
    return Response.json({geometry:{coordinates:[-84,40]},properties:{timestamp:new Date(now-(path.includes('/OLD/')?3600000:60000)).toISOString(),temperature:{value:20},textDescription:'Clear'}});
  };
  const result=await currentWeather({lat:40,lon:-84},{COMMUTE:kv,NWS_USER_AGENT:'test'},'test:',now,fetcher);
  assert.equal(result.station,'https://api.weather.gov/stations/FRESH');
  assert.equal(result.temperatureF,68);
});
const config=()=>validateConfig({origin:{lat:40,lon:-84},destination:{lat:40.1,lon:-84},timeZone:'America/New_York',stop:{enabled:true,location:{lat:40.02,lon:-84},name:'COFFEE',durationMinutes:5},ohgo:true});
const line=[{lat:40,lon:-84},{lat:40.1,lon:-84}];
const polygon={type:'Polygon',coordinates:[[[-84.01,40.04],[-83.99,40.04],[-83.99,40.06],[-84.01,40.06],[-84.01,40.04]]]};
const raw=(duration=1440,name='I-675')=>({summary:{travelTimeInSeconds:duration,historicTrafficTravelTimeInSeconds:duration-180,noTrafficTravelTimeInSeconds:duration-300,lengthInMeters:15000},sections:[{sectionType:'IMPORTANT_ROAD_STRETCH',importantRoadStretchIndex:0,roadNumbers:[{text:name}]}],legs:[{points:line.map(p=>({latitude:p.lat,longitude:p.lon}))}]});
class KV{map=new Map();async get(k,type){const v=this.map.get(k);return v?(type==='json'?JSON.parse(v):v):null;}async put(k,v){this.map.set(k,v);}}
const payload=results=>({lastUpdated:new Date(now).toISOString(),results,totalResultCount:results.length});
const alert=(overrides={})=>({id:'weather-1',geometry:polygon,properties:{status:'Actual',messageType:'Alert',event:'Tornado Warning',severity:'Extreme',onset:new Date(now-60000).toISOString(),expires:new Date(now+600000).toISOString(),headline:'Synthetic warning',...overrides}});
const env=()=>({CONFIG_JSON:JSON.stringify(config()),TOMTOM_KEY:'synthetic-provider',READ_KEY:'synthetic-read-token-long-enough',NWS_USER_AGENT:'Commute tests',OHGO_KEY:'synthetic-ohgo',COMMUTE:new KV()});
function mock(fetches=[]){return async(value,options)=>{
  const u=new URL(value);fetches.push({url:u,options});
  if(u.hostname==='api.tomtom.com')return Response.json({routes:[raw(1440),raw(1680,'WILMINGTON PIKE')]});
  if(u.pathname.startsWith('/points/'))return Response.json({properties:{observationStations:'https://api.weather.gov/gridpoints/TEST/stations'}});
  if(u.pathname.endsWith('/stations'))return Response.json({features:[{id:'https://api.weather.gov/stations/TEST'}]});
  if(u.pathname.endsWith('/observations/latest'))return Response.json({properties:{timestamp:new Date(now).toISOString(),temperature:{value:20,unitCode:'wmoUnit:degC'},textDescription:'Clear',icon:'https://api.weather.gov/icons/land/day/skc'}});
  if(u.pathname==='/alerts/active')return Response.json({features:[alert()]});
  if(u.hostname==='publicapi.ohgo.com')return Response.json(payload([]));
  throw Error('UNEXPECTED_REQUEST');
};}

test('config rejects invalid inputs and defaults stop duration to five minutes',()=>{
  assert.equal(validateConfig({...config(),stop:{enabled:false}}).stop.durationMinutes,5);
  for(const bad of [{origin:{lat:100,lon:1}},{arriveBy:'25:00'},{outsideIntervalMinutes:0},{days:[8]},{stop:{enabled:true,durationMinutes:-2}}])assert.throws(()=>validateConfig({...config(),...bad}));
});
test('one-minute commute cadence, slower outside and weekends',()=>{
  const c=config();assert.equal(intervalSeconds(c,now),60);assert.equal(intervalSeconds(c,now+5*3600e3),900);assert.equal(intervalSeconds(c,now-86400e3),900);
});
test('overnight commute belongs to previous starting day',()=>{
  const c={...config(),days:[1],activeStart:'22:00',activeEnd:'02:00'};
  assert.equal(intervalSeconds(c,Date.parse('2026-09-29T05:00:00Z')),60);
  assert.equal(intervalSeconds(c,Date.parse('2026-09-28T05:00:00Z')),900);
});
test('target uses local date, handles winter/summer and stays late today',()=>{
  const c=config();assert.equal(new Date(arriveTarget(c,now)).toISOString(),'2026-09-28T12:00:00.000Z');
  assert.equal(new Date(arriveTarget(c,Date.parse('2026-01-05T12:00:00Z'))).toISOString(),'2026-01-05T13:00:00.000Z');
  assert.ok(arriveTarget(c,now+3*3600e3)<now+3*3600e3);
  assert.equal(arriveTarget({...c,arriveBy:'02:30'},Date.parse('2026-03-08T06:00:00Z')),null);
});
test('road shields are identified from actual provider road names',()=>{
  assert.equal(roadIdentity('I 675').kind,'interstate');assert.equal(roadIdentity('US-35').kind,'us');assert.equal(roadIdentity('OH 725').kind,'state');assert.equal(roadIdentity('Wilmington Pike').kind,'road');
  assert.equal(routeName(raw()).label,'I-675');
});
test('important stretches outrank incidental roads; instructions provide fallback',()=>{
  const r=raw();r.sections.push({sectionType:'IMPORTANT_ROAD_STRETCH',importantRoadStretchIndex:2,streetName:{text:'LOCAL ROAD'}});assert.equal(routeName(r).label,'I-675');
  r.sections=[];r.guidance={instructions:[{street:'SIDE ST',routeOffsetInMeters:0},{street:'WILMINGTON PIKE',routeOffsetInMeters:50}]};assert.equal(routeName(r).label,'WILMINGTON PIKE');
});
test('bad duration and missing geometry never become zero-minute route',()=>{
  const r=raw();r.summary.travelTimeInSeconds=null;assert.throws(()=>normalizeRoute(r));r.summary.travelTimeInSeconds=0;r.legs=[];assert.throws(()=>normalizeRoute(r));
});
test('stop combines both driving legs and dwell exactly once',()=>{
  const r=combineStop(normalizeRoute(raw(480)),normalizeRoute(raw(1260)),300);
  assert.equal(r.seconds,2040);assert.equal(publicRoute(r,config(),now).minutes,34);assert.equal(r.stopSeconds,300);
});
test('normal is historical traffic baseline, not free-flow or stop time',()=>{
  const r=publicRoute(normalizeRoute(raw()),config(),now);assert.equal(r.delayMinutes,3);assert.equal(r.normalMinutes,21);assert.equal(r.leaveBy,'7:36A');assert.equal(r.arrival,'7:24A');
  const missing=normalizeRoute(raw());missing.normalSeconds=null;assert.equal(publicRoute(missing,config(),now).delayMinutes,null);
});
test('corridor checks segments, not just endpoints or a bounding box',()=>{
  assert.ok(nearRoute({lat:40.05,lon:-84.001},line));assert.equal(nearRoute({lat:40.05,lon:-83.98},line),false);assert.ok(polygonHits(line,polygon));
  assert.equal(intersects({lat:0,lon:0},{lat:0,lon:1},{lat:0,lon:2},{lat:0,lon:3}),false);
});
test('polygon holes do not become affected areas',()=>{
  const g={type:'Polygon',coordinates:[[[0,0],[10,0],[10,10],[0,10],[0,0]],[[2,2],[8,2],[8,8],[2,8],[2,2]]]};
  assert.equal(polygonHits([{lat:3,lon:3},{lat:4,lon:4}],g),false);
});
test('weather icons distinguish storm, snow, rain, fog and unknown',()=>{
  for(const [input,want] of [['Thunderstorms','storm'],['Freezing rain','snow'],['Rain','rain'],['Fog','fog'],['Overcast','cloud'],['Partly cloudy','partly'],['Clear','sun'],['','unknown']])assert.equal(weatherKind(input),want);
  assert.equal(weatherKind('Clear',false),'moon');
});
test('OHGO filters off-route and inactive construction, including PascalCase',()=>{
  const r={Id:'1',Latitude:40.05,Longitude:-84,Description:'Lane restriction',RouteName:'TEST ROAD',StartDate:new Date(now-1000).toISOString(),EndDate:new Date(now+60000).toISOString()};
  assert.equal(ohgoEvents({LastUpdated:new Date(now).toISOString(),Results:[r]},line,'construction',now).length,1);
  assert.equal(ohgoEvents(payload([{...r,Longitude:-83}]),line,'construction',now).length,0);
  assert.equal(ohgoEvents(payload([{...r,StartDate:new Date(now+1000).toISOString()}]),line,'construction',now).length,0);
});
test('OHGO finds a crossing work-zone even when its marker is distant',()=>{
  const r={id:'1',latitude:41,longitude:-84,workZones:[{polyline:[[-84.02,40.05],[-83.98,40.05]]}]};
  assert.equal(ohgoEvents(payload([r]),line,'construction',now).length,1);
});
test('stale OHGO response is not a no-alert result',()=>assert.throws(()=>ohgoEvents({lastUpdated:new Date(now-3600e3).toISOString(),results:[]},line,'incident',now)));
test('surface conditions require fresh individual sensor readings',()=>{
  const r={id:'s',latitude:40.05,longitude:-84,surfaceSensors:[{status:'Ice',lastUpdate:new Date(now).toISOString()}]};
  assert.equal(ohgoEvents(payload([r]),line,'surface',now)[0].title,'ROAD ICE');r.surfaceSensors[0].lastUpdate=new Date(now-3600e3).toISOString();assert.equal(ohgoEvents(payload([r]),line,'surface',now).length,0);
});
test('weather alerts include issued upcoming advisories but exclude expired, test and canceled events',()=>{
  const invalid=[{expires:new Date(now-1).toISOString()},{status:'Test'},{messageType:'Cancel'}];
  assert.equal(nwsEvents([alert(),...invalid.map(alert)],line,now).length,1);
  assert.equal(nwsEvents([alert({onset:new Date(now+3600e3).toISOString()})],line,now).length,1);
  assert.equal(sortAlerts([{id:'c',severity:'Minor'},{id:'w',severity:'Extreme'}])[0].id,'w');
});
test('OHGO delays are segment minutes and slowdowns preserve reported speeds',()=>{
  const record={id:'x',latitude:40.05,longitude:-84,delayTime:4.2,currentAvgSpeed:20,currentMPH:15,normalMPH:65};
  assert.match(ohgoEvents(payload([record]),line,'delay',now)[0].detail,/5 MIN SEGMENT DELAY/);
  const a=ohgoEvents(payload([record]),line,'slowdown',now)[0];assert.equal(a.severity,'Severe');assert.match(a.detail,/15 MPH \/ USUAL 65 MPH/);
});
test('NWS multi-zone alert matches direct and detour in separate polygons',async()=>{
  const second=line.map(p=>({...p,lon:p.lon+1}));
  const other={type:'Polygon',coordinates:polygon.coordinates.map(r=>r.map(([x,y])=>[x+1,y]))};
  const a=alert();a.geometry=null;a.properties.affectedZones=['https://api.weather.gov/zones/forecast/ONE','https://api.weather.gov/zones/forecast/TWO'];
  const r=await weatherAlerts([line,second],env(),config(),'z:',now,async url=>Response.json(url.includes('/alerts/')?{features:[a]}:{geometry:url.endsWith('ONE')?polygon:other}));
  assert.equal(r.byRoute[0].length,1);assert.equal(r.byRoute[1].length,1);
});
test('warnings refresh during a traffic outage and outside traffic polling window',async()=>{
  const e=env();e.CONFIG_JSON=JSON.stringify({...config(),activeStart:'09:00',activeEnd:'10:00'});
  await refresh(e,now,mock());const calls=[];
  const s=await refresh(e,now+60000,mock(calls));
  assert.equal(s.updatedAt,now/1000);assert.equal(s.sources.weatherAlerts.checkedAt,(now+60000)/1000);
  assert.ok(!calls.some(c=>c.url.hostname==='api.tomtom.com'));
  const e2=env();await refresh(e2,now,mock());
  const failed=await refresh(e2,now+60000,async(url,options)=>new URL(url).hostname==='api.tomtom.com'?new Response('',{status:503}):mock()(url,options));
  assert.equal(failed.state,'unavailable');assert.equal(failed.sources.weatherAlerts.state,'ok');assert.equal(failed.alerts.direct[0].title,'TORNADO WARNING');
});
test('current weather refreshes outside traffic hours without requesting another route',async()=>{
  const e=env();e.CONFIG_JSON=JSON.stringify({...config(),activeStart:'09:00',activeEnd:'10:00',outsideIntervalMinutes:60});
  await refresh(e,now,mock());const calls=[];
  const fetcher=async(url,options)=>{
    if(new URL(url).pathname.endsWith('/observations/latest'))return Response.json({properties:{timestamp:new Date(now+360000).toISOString(),temperature:{value:10},textDescription:'Rain'}});
    return mock(calls)(url,options);
  };
  const s=await refresh(e,now+360000,fetcher);
  assert.equal(s.weather.temperatureF,50);assert.equal(s.weather.kind,'rain');
  assert.equal(s.updatedAt,now/1000);assert.ok(!calls.some(c=>c.url.hostname==='api.tomtom.com'));
});
test('provider uses traffic, alternatives, guidance and all baselines',async()=>{
  let u;await routes(line[0],line[1],'synthetic',now,async url=>{u=new URL(url);return Response.json({routes:[raw()]});});
  assert.equal(u.searchParams.get('traffic'),'true');assert.equal(u.searchParams.get('computeTravelTimeFor'),'all');assert.equal(u.searchParams.get('maxAlternatives'),'2');assert.ok(u.searchParams.getAll('sectionType').includes('importantRoadStretch'));
});
test('stop leg departs after first leg and five minute pause',async()=>{
  const calls=[];const result=await stopRoute(line[0],{lat:40.02,lon:-84},line[1],300,'synthetic',now,async url=>{calls.push(new URL(url));return Response.json({routes:[raw(calls.length===1?480:1260)]});});
  assert.equal(result.seconds,2040);assert.equal(Date.parse(calls[1].searchParams.get('departAt')),now+780e3);
});
test('configured route waypoints are compared and failed comparisons are explicit',async()=>{
  const seen=[];const r=await routeChoices(line[0],line[1],'synthetic',now,[{via:[{lat:40.04,lon:-83.99}]}],async url=>{seen.push(url);return seen.length===1?Response.json({routes:[raw()]}):new Response('',{status:503});});assert.equal(r.partial,true);assert.equal(r.routes.length,1);assert.match(seen[1],/40.04,-83.99/);
});
test('ambiguous geocoding requires a precise location',async()=>{
  await assert.rejects(resolveLocation({address:'Synthetic address'},'synthetic',new KV(),'x',now,async()=>Response.json({results:[{type:'Point Address',score:10,position:{lat:40,lon:-84}},{type:'Point Address',score:9.9}]})),/AMBIGUOUS/);
});
test('weather alerts resolve null geometries using official affected zones',async()=>{
  const e=env();const a=alert();a.geometry=null;a.properties.affectedZones=['https://api.weather.gov/zones/forecast/TEST'];
  const r=await weatherAlerts([line],e,config(),'t:',now,async url=>Response.json(url.includes('/alerts/')?{features:[a]}:{geometry:polygon}));assert.equal(r.byRoute[0].length,1);assert.equal(r.state,'ok');
});
test('a missing county feed never synthesizes a snow emergency level',async()=>{
  await assert.rejects(countyAlerts([line],env(),config(),'t:',now),/NOT_CONFIGURED/);
});
test('county feed requires provenance, expiry, freshness and route intersection',async()=>{
  const a={county:'SYNTHETIC',authority:'TEST SHERIFF',sourceUrl:'https://example.gov/advisories',level:2,updatedAt:new Date(now).toISOString(),expires:new Date(now+300e3).toISOString(),geometry:polygon};
  const c={...config(),countyAdvisoryFeed:'https://example.gov/feed'};
  const r=await countyAlerts([line],env(),c,'t:',now,async()=>Response.json({advisories:[a]}));assert.equal(r.byRoute[0][0].title,'SNOW LEVEL 2');
  a.expires=new Date(now-1).toISOString();await assert.rejects(countyAlerts([line],env(),c,'t:',now,async()=>Response.json({advisories:[a]})));
});
test('end-to-end refresh has safe public data, separate stop, weather and severity',async()=>{
  const e=env(),calls=[];const s=await refresh(e,now,mock(calls));
  assert.equal(s.state,'ok');assert.equal(s.direct.minutes,24);assert.equal(s.stop.minutes,53);assert.equal(s.addedMinutes,29);assert.equal(s.weather.temperatureF,68);assert.equal(s.alerts.direct[0].title,'TORNADO WARNING');assert.equal(s.sources.county.state,'unavailable');
  const serialized=JSON.stringify(s);assert.ok(!serialized.includes(e.TOMTOM_KEY));assert.ok(!serialized.includes(e.READ_KEY));assert.ok(!serialized.includes('polyline'));assert.ok(!serialized.includes('origin'));
  assert.equal(new URL(s.navigation.destination).hostname,'waze.com');
  const previous=calls.length;await refresh(e,now+20000,mock(calls));assert.equal(calls.length,previous);
});
test('traffic outage retains old timestamp and marks ETA unusable',async()=>{
  const e=env();await refresh(e,now,mock());const s=await refresh(e,now+60000,async()=>new Response('',{status:503}));assert.equal(s.updatedAt,now/1000);assert.equal(s.state,'unavailable');assert.equal(statusView(s,now+60000).stale,true);
});
test('supplemental feed failure preserves ETA but does not claim clear coverage',async()=>{
  const e=env();const s=await refresh(e,now,async(url,o)=>new URL(url).hostname==='api.tomtom.com'?mock()(url,o):new Response('',{status:503}));assert.equal(s.state,'ok');assert.equal(s.sources.weatherAlerts.state,'unavailable');assert.equal(s.sources.roads.state,'unavailable');assert.equal(s.weather.kind,'unknown');
});
test('stale snapshot and expired warnings are invalidated on read',async()=>{
  const s=await refresh(env(),now,mock());assert.equal(statusView(s,now+181e3).stale,true);assert.equal(statusView(s,now+601e3).alerts.direct.length,0);
});
test('arrival selector recomputes deadlines for 8:15 and 8:30',async()=>{
  const s=await refresh(env(),now,mock());assert.equal(statusView(s,now,'08:15').direct.leaveBy,'7:51A');assert.equal(statusView(s,now,'08:30').direct.leaveBy,'8:06A');assert.equal(statusView(s,now,'99:00').arriveBy,'08:00');
});
test('status is authenticated; query tokens cannot substitute for bearer key',async()=>{
  const e=env();assert.equal((await worker.fetch(new Request('https://example.com/status?key='+e.READ_KEY),e)).status,401);
  assert.equal((await worker.fetch(new Request('https://example.com/status',{headers:{Authorization:'Bearer '+e.READ_KEY}}),e)).status,503);
  assert.equal((await worker.fetch(new Request('https://example.com/',{method:'GET'}),e)).headers.get('Content-Type'),'text/html; charset=utf-8');
});
test('changing configuration cannot leak a previously configured commute',async()=>{
  const e=env();await refresh(e,now,mock());e.CONFIG_JSON=JSON.stringify({...config(),label:'NEW'});
  const r=await worker.fetch(new Request('https://example.com/status',{headers:{Authorization:'Bearer '+e.READ_KEY}}),e);assert.equal(r.status,503);
});
test('departure deadline uses the exact arrival target with no added cushion',()=>{
  const r=publicRoute(normalizeRoute(raw(1440)),config(),now);
  assert.equal(r.leaveAt,Date.parse('2026-09-28T11:36:00Z')/1000);
  assert.equal(r.leaveAt*1000+1440e3,arriveTarget(config(),now));
});
test('small traffic fluctuations retain the prior route while meaningful savings switch it',()=>{
  const prior={updatedAt:now/1000,direct:{road:{label:'I-675'}}};
  const highway=normalizeRoute(raw(1440)),local=normalizeRoute(raw(1380,'WILMINGTON PIKE'));
  assert.equal(selectCommuteRoute([local,highway],prior,now+60000).direct.road.label,'I-675');
  assert.equal(selectCommuteRoute([local,highway],prior,now+60000).recommendation.kind,'similar');
  local.seconds=1320;
  assert.equal(selectCommuteRoute([local,highway],prior,now+60000).direct.road.label,'WILMINGTON PIKE');
  assert.equal(selectCommuteRoute([local],prior,now).direct.road.label,'WILMINGTON PIKE');
  local.seconds=1380;
  assert.equal(selectCommuteRoute([local,highway],prior,now+181000).direct.road.label,'WILMINGTON PIKE');
});
