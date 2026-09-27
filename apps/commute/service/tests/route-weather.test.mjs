import test from 'node:test';
import assert from 'node:assert/strict';
import {sensorTime,roadSensors,sampleRoute,weatherSummary,collectRouteWeather,visibilityHazard,pavementHazard,conditionHazard} from '../worker/src/route-weather.mjs';
const now=Date.parse('2026-01-12T12:00:00Z'),line=[{lat:40,lon:-84},{lat:40.2,lon:-84}];
const stamp=new Date(now-300e3).toISOString();
const site=()=>({id:'sample',latitude:40.1,longitude:-84,location:'SAMPLE HIGHWAY',atmosphericSensors:[{airTemperature:31,visibility:.5,precipitation:'Snow',lastUpdate:stamp}],surfaceSensors:[{name:'TEST LANE',status:'Ice',surfaceTemperature:29,subSurfaceTemperature:34,lastUpdate:stamp}]});
const payload=rows=>({lastUpdated:new Date(now).toISOString(),results:rows,totalResultCount:rows.length});
test('OHGO offsetless sensor times use Ohio local time in winter and summer',()=>{
  assert.equal(sensorTime('2026-01-12T06:55:00'),now-300e3);
  assert.equal(sensorTime('2026-09-27T00:55:03'),Date.parse('2026-09-27T04:55:03Z'));
  assert.equal(sensorTime('2026-09-27T04:55:03Z'),Date.parse('2026-09-27T04:55:03Z'));
  assert.ok(Number.isNaN(sensorTime('2026-03-08T02:30:00')));
});
test('OHGO sensor units remain Fahrenheit and miles; negative visibility is missing',()=>{
  const r=site();let s=roadSensors(payload([r]),line,now)[0];
  assert.equal(s.atmosphere[0].temperatureF,31);assert.equal(s.atmosphere[0].visibilityMiles,.5);assert.equal(s.surfaces[0].temperatureF,29);
  r.atmosphericSensors[0].visibility=-1;
  assert.equal(roadSensors(payload([r]),line,now)[0].atmosphere[0].visibilityMiles,null);
  r.atmosphericSensors[0].visibility=0;
  assert.equal(roadSensors(payload([r]),line,now)[0].atmosphere[0].visibilityMiles,0);
});
test('off-route, stale and future sensor observations do not become current conditions',()=>{
  const off=site();off.longitude=-83;
  const stale=site();stale.atmosphericSensors[0].lastUpdate=new Date(now-21*60e3).toISOString();stale.surfaceSensors[0].lastUpdate=new Date(now+120e3).toISOString();
  assert.deepEqual(roadSensors(payload([off,stale]),line,now),[]);
});
test('sampling follows route distance through a detour instead of endpoint midpoint',()=>{
  const route=[{lat:40,lon:-84},{lat:40.2,lon:-84},{lat:40.2,lon:-83.9}];
  const p=sampleRoute(route);assert.equal(p.length,3);assert.equal(p[1].lon,-84);assert.ok(p[1].lat>40.1);assert.deepEqual(p[2],route[2]);
});
test('summary shows low visibility, temperature range and reported ice with separate freshness',()=>{
  const sensors=roadSensors(payload([site()]),line,now);
  const d={state:'ok',observations:[{temperatureF:33,visibilityMiles:5,description:'Cloudy',kind:'cloud',observedAt:now/1000-600,source:'NWS'}],sensors};
  const w=weatherSummary(d,now);assert.equal(w.temperatureLowF,31);assert.equal(w.temperatureHighF,33);assert.equal(w.visibilityMiles,.5);assert.equal(w.kind,'snow');assert.equal(w.road.status,'ICE');
  const later=weatherSummary(d,now+21*60e3);assert.equal(later.road,null);assert.equal(later.temperatureLowF,33);
  assert.equal(weatherSummary(d,now+46*60e3).state,'unavailable');
});
test('cold dry pavement never becomes an inferred ice warning',()=>{
  const r=site();r.surfaceSensors[0].status='Dry';
  const w=weatherSummary({state:'ok',observations:[],sensors:roadSensors(payload([r]),line,now)},now);
  assert.equal(w.road.status,'DRY');assert.equal(w.road.temperatureF,29);
  assert.equal(w.road.hazard,'none');
});
test('hazard levels distinguish reduced visibility, reported road hazards and unknowns',()=>{
  for(const [value,expected] of [[null,'none'],[-1,'none'],[10,'none'],[3,'none'],[2,'attention'],[1,'attention'],[.75,'warning'],[.25,'severe'],[0,'severe']])assert.equal(visibilityHazard(value),expected);
  for(const [status,temperatureF,expected] of [['Dry',20,'none'],['Unknown',null,'none'],['Wet',34,'attention'],['Wet',31,'warning'],['Frost',31,'warning'],['Ice',29,'severe']])assert.equal(pavementHazard({status,temperatureF}),expected);
  assert.equal(conditionHazard('Freezing rain'),'warning');assert.equal(conditionHazard('Fog'),'attention');assert.equal(conditionHazard('Sunny'),'none');
});
test('a hazardous pavement reading outranks a colder dry sensor',()=>{
  const r=site();r.surfaceSensors=[{name:'DRY',status:'Dry',surfaceTemperature:20,lastUpdate:stamp},{name:'WET',status:'Wet',surfaceTemperature:31,lastUpdate:stamp}];
  const w=weatherSummary({state:'ok',observations:[],sensors:roadSensors(payload([r]),line,now)},now);
  assert.equal(w.road.name,'WET');assert.equal(w.road.hazard,'warning');
});
test('route collector samples both trips, deduplicates stations and converts NWS visibility',async()=>{
  const map=new Map(),kv={get:async k=>map.has(k)?JSON.parse(map.get(k)):null,put:async(k,v)=>map.set(k,v)};
  const env={COMMUTE:kv,NWS_USER_AGENT:'synthetic-test'};
  const f=async url=>{
    if(url.includes('/points/'))return Response.json({properties:{observationStations:'https://api.weather.gov/gridpoints/TEST/stations'}});
    if(url.endsWith('/stations'))return Response.json({features:[{id:'https://api.weather.gov/stations/TEST',geometry:{coordinates:[-84,40.1]}}]});
    return Response.json({geometry:{coordinates:[-84,40.1]},properties:{timestamp:stamp,temperature:{value:0,unitCode:'wmoUnit:degC'},visibility:{value:1609.344,unitCode:'wmoUnit:m'},textDescription:'Snow'}});
  };
  const r=await collectRouteWeather([line,line],env,{ohgo:false},'test:',now,f);
  for(const data of [r.direct,r.stop]){
    assert.equal(data.observations.length,1);assert.equal(data.observations[0].visibilityMiles,1);assert.equal(data.observations[0].temperatureF,32);assert.equal(data.ohgoState,'unavailable');
    assert.equal(weatherSummary(data,now).kind,'snow');assert.ok(!JSON.stringify(data).includes('stationPoint'));
  }
});
