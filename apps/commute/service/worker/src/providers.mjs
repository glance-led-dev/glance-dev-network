import {point,normalizeRoute,combineStop,clean,weatherKind,ohgoEvents,nwsEvents,polygonHits,get} from './core.mjs';

export async function json(url,options={},fetcher=fetch){
  const u=new URL(url);
  if(u.protocol!=='https:')throw Error('HTTPS_REQUIRED');
  // Workers supports manual/follow, but not the browser's redirect:error mode.
  // Treat redirects as failures so credentials never follow a Location header.
  const response=await fetcher(u.toString(),{...options,redirect:'manual',signal:AbortSignal.timeout(12000)});
  if(!response.ok)throw Error(response.status===429?'RATE_LIMITED':'PROVIDER_HTTP_'+response.status);
  return response.json();
}
export async function cached(kv,key,ttl,now,load){
  const old=await kv.get(key,'json');
  if(old&&now-old.at>=0&&now-old.at<ttl*1000)return old;
  const fresh={at:now,value:await load()};
  await kv.put(key,JSON.stringify(fresh),{expirationTtl:Math.max(ttl*2,60)});
  return fresh;
}
export async function resolveLocation(location,key,kv,cacheKey,now,fetcher=fetch){
  if(!location.address)return point(location);
  const entry=await cached(kv,cacheKey,86400*7,now,async()=>{
    const u=new URL('https://api.tomtom.com/search/2/geocode/'+encodeURIComponent(location.address)+'.json');
    u.search=new URLSearchParams({key,limit:'2',countrySet:'US'});
    const data=await json(u,{},fetcher),results=data.results||[];
    if(!results.length||!['Point Address','Address Range'].includes(results[0].type))throw Error('ADDRESS_NEEDS_COORDINATES');
    if(results[1]&&Math.abs(results[0].score-results[1].score)<.5)throw Error('ADDRESS_AMBIGUOUS');
    return point({lat:results[0].position?.lat,lon:results[0].position?.lon});
  });
  return entry.value;
}
export async function routes(origin,destination,key,departure,fetcher=fetch,via=[]){
  const locations=[origin,...via,destination].map(p=>`${p.lat},${p.lon}`).join(':');
  const u=new URL(`https://api.tomtom.com/routing/1/calculateRoute/${locations}/json`);
  u.search=new URLSearchParams({key,traffic:'true',routeType:'fastest',travelMode:'car',maxAlternatives:'2',alternativeType:'anyRoute',computeTravelTimeFor:'all',instructionsType:'text',language:'en-US',departAt:new Date(departure).toISOString()});
  u.searchParams.append('sectionType','traffic');u.searchParams.append('sectionType','importantRoadStretch');
  const data=await json(u,{},fetcher);
  if(!Array.isArray(data.routes)||!data.routes.length)throw Error('NO_ROUTE');
  return data.routes.map(normalizeRoute).sort((a,b)=>a.seconds-b.seconds);
}
export async function routeChoices(origin,destination,key,departure,options,fetcher=fetch){
  const results=await Promise.allSettled([routes(origin,destination,key,departure,fetcher),...options.map(o=>routes(origin,destination,key,departure,fetcher,o.via))]);
  const successes=results.filter(r=>r.status==='fulfilled').flatMap(r=>r.value);
  if(!successes.length){
    const reason=results[0].reason?.message||'';
    if(/^(PROVIDER_HTTP_\d{3}|RATE_LIMITED|INVALID_ROUTE|MISSING_ROUTE_GEOMETRY)$/.test(reason))throw Error(reason);
    throw Error('NO_ROUTE');
  }
  const unique=new Map();
  for(const r of successes){const k=JSON.stringify(r.polyline);if(!unique.has(k)||unique.get(k).seconds>r.seconds)unique.set(k,r);}
  return {routes:[...unique.values()].sort((a,b)=>a.seconds-b.seconds),partial:results.some(r=>r.status==='rejected')};
}
export async function stopRoute(origin,stop,destination,dwell,key,now,fetcher=fetch){
  // Query the second leg at the actual predicted post-stop departure, not "now".
  const first=(await routes(origin,stop,key,now,fetcher))[0];
  const second=(await routes(stop,destination,key,now+(first.seconds+dwell)*1000,fetcher))[0];
  return combineStop(first,second,dwell);
}
function nwsURL(value){const u=new URL(value);if(u.protocol!=='https:'||u.hostname!=='api.weather.gov')throw Error('INVALID_NWS_URL');return u.toString();}
function nwsOptions(agent){return {headers:{'User-Agent':agent,Accept:'application/geo+json'}};}
export async function currentWeather(origin,env,namespace,now,fetcher=fetch){
  if(!env.NWS_USER_AGENT)throw Error('NWS_SETUP_REQUIRED');
  const options=nwsOptions(env.NWS_USER_AGENT),kv=env.COMMUTE;
  const meta=await cached(kv,namespace+'nws-point',86400,now,()=>json(`https://api.weather.gov/points/${origin.lat.toFixed(4)},${origin.lon.toFixed(4)}`,options,fetcher));
  const stations=await cached(kv,namespace+'stations',86400,now,()=>json(nwsURL(meta.value.properties.observationStations),options,fetcher));
  // The nearest listed station can be offline or report only once an hour.
  // Try nearby alternatives while preserving the same observation-age limit.
  let station,obs,p,at,feature;
  for(const candidate of (stations.value.features||[]).slice(0,4)){
    try{
      const observation=await cached(kv,namespace+'weather:'+candidate.id,300,now,()=>json(nwsURL(candidate.id+'/observations/latest'),options,fetcher));
      const properties=observation.value.properties||{},timestamp=Date.parse(properties.timestamp);
      if(!Number.isFinite(timestamp)||now-timestamp>45*60e3||timestamp>now+60e3)continue;
      station=candidate.id;obs=observation;p=properties;at=timestamp;feature=candidate;break;
    }catch{ /* Try the next nearby station; no provider URLs enter logs. */ }
  }
  if(!obs)throw Error('WEATHER_UNAVAILABLE');
  const degrees=p.temperature?.value;
  const kind=weatherKind(p.textDescription,!String(p.icon).includes('/night/'));
  const v=p.visibility?.value,unit=p.visibility?.unitCode;
  const visibilityMiles=Number.isFinite(v)&&v>=0?(unit==='wmoUnit:m'?v/1609.344:unit==='wmoUnit:km'?v/1.609344:unit==='wmoUnit:mi'?v:null):null;
  const coords=obs.value.geometry?.coordinates||feature.geometry?.coordinates;
  return {kind,description:clean(p.textDescription,40),temperatureF:Number.isFinite(degrees)?Math.round(degrees*9/5+32):null,visibilityMiles,station,stationPoint:Array.isArray(coords)?{lon:coords[0],lat:coords[1]}:null,observedAt:Math.floor(at/1000),checkedAt:Math.floor(obs.at/1000),basis:'OBSERVATION',location:'NEAR START',source:'NWS'};
}
export async function weatherAlerts(lines,env,c,namespace,now,fetcher=fetch){
  if(!env.NWS_USER_AGENT)throw Error('NWS_SETUP_REQUIRED');
  const options=nwsOptions(env.NWS_USER_AGENT);
  const response=await cached(env.COMMUTE,namespace+'nws-alerts',60,now,()=>json('https://api.weather.gov/alerts/active?area='+c.alertAreas.join(','),options,fetcher));
  if(!Array.isArray(response.value.features))throw Error('INVALID_NWS_ALERTS');
  const features=response.value.features;
  const expanded=[];let unresolved=0,zoneCount=0;
  for(const f of features){
    const p=f.properties||{},expires=Date.parse(p.expires);
    if(p.status!=='Actual'||p.messageType==='Cancel'||!Number.isFinite(expires)||expires<=now)continue;
    if(f.geometry){expanded.push(f);continue;}
    // Many watches/advisories have no polygon; use their official zone geometry.
    const zones=p.affectedZones||[];
    if(!zones.length){unresolved++;continue;}
    const polygons=[];
    for(const zone of zones){
      if(++zoneCount>100){unresolved++;break;}
      try{
        const z=await cached(env.COMMUTE,'zone:'+nwsURL(zone),86400*7,now,()=>json(nwsURL(zone),options,fetcher));
        const geometry=z.value.geometry;
        if(lines.some(line=>polygonHits(line,geometry))){
          if(geometry.type==='Polygon')polygons.push(geometry.coordinates);
          else if(geometry.type==='MultiPolygon')polygons.push(...geometry.coordinates);
        }
      }catch{unresolved++;}
    }
    if(polygons.length)expanded.push({...f,geometry:{type:'MultiPolygon',coordinates:polygons}});
  }
  return {byRoute:lines.map(line=>nwsEvents(expanded,line,now)),state:unresolved?'partial':'ok',checkedAt:Math.floor(response.at/1000),coverage:c.alertAreas.join(',')};
}
export async function roadEvents(lines,env,c,namespace,now,fetcher=fetch){
  if(!c.ohgo)return {byRoute:lines.map(()=>[]),state:'disabled',checkedAt:null,coverage:'NOT ENABLED'};
  if(!env.OHGO_KEY)throw Error('OHGO_SETUP_REQUIRED');
  // Fetch statewide geometry, so a work-zone whose marker is outside the corridor
  // is still found when its line intersects the selected route. No bounding-box claim.
  const endpoints=[['incidents','incident'],['construction','construction'],['travel-delays','delay'],['dangerous-slowdowns','slowdown'],['weather-sensor-sites','surface']];
  const settled=await Promise.allSettled(endpoints.map(async([name,kind])=>{
    const u='https://publicapi.ohgo.com/api/v1/'+name+'?page-all=true';
    const r=await cached(env.COMMUTE,namespace+name,kind==='surface'?300:kind==='construction'?120:60,now,()=>json(u,{headers:{Authorization:'APIKEY '+env.OHGO_KEY}},fetcher));
    const total=get(r.value,'totalResultCount'),results=get(r.value,'results');
    if(Number.isFinite(total)&&Array.isArray(results)&&total>results.length)throw Error('INCOMPLETE_OHGO');
    return {byRoute:lines.map(line=>ohgoEvents(r.value,line,kind,now)),at:r.at};
  }));
  const good=settled.filter(s=>s.status==='fulfilled').map(s=>s.value);
  if(!good.length)throw Error('OHGO_UNAVAILABLE');
  return {byRoute:lines.map((_,i)=>good.flatMap(g=>g.byRoute[i])),state:good.length===endpoints.length?'ok':'partial',checkedAt:Math.floor(Math.min(...good.map(g=>g.at))/1000),feeds:Object.fromEntries(settled.map((r,i)=>[endpoints[i][0],r.status==='fulfilled'?{state:'ok',checkedAt:Math.floor(r.value.at/1000)}:{state:'unavailable'}])),coverage:'ODOT MONITORED ROADS'};
}
export async function countyAlerts(lines,env,c,namespace,now,fetcher=fetch){
  if(!c.countyAdvisoryFeed)throw Error('COUNTY_FEED_NOT_CONFIGURED');
  // A configured adapter must preserve an official source, timestamp, expiry and
  // county polygon. Weather or snowfall is never converted into a legal level.
  const r=await cached(env.COMMUTE,namespace+'county',120,now,()=>json(c.countyAdvisoryFeed,{},fetcher));
  if(!Array.isArray(r.value.advisories))throw Error('INVALID_COUNTY_FEED');
  const byRoute=lines.map(()=>[]);
  for(const a of r.value.advisories){
    const updated=Date.parse(a.updatedAt),expires=Date.parse(a.expires);
    if(!Number.isInteger(a.level)||a.level<0||a.level>3||!a.county||!a.authority||!a.geometry||!Number.isFinite(updated)||updated>now+60e3||now-updated>30*60e3||!Number.isFinite(expires)||expires<=now)throw Error('STALE_OR_INVALID_COUNTY_FEED');
    const source=new URL(a.sourceUrl);if(source.protocol!=='https:')throw Error('INVALID_COUNTY_SOURCE');
    if(a.level===0)continue;
    lines.forEach((line,i)=>{if(polygonHits(line,a.geometry))byRoute[i].push({id:'county-'+clean(a.county),title:'SNOW LEVEL '+a.level,detail:clean(a.county+' COUNTY / '+a.authority,120),severity:a.level===3?'Extreme':a.level===2?'Severe':'Moderate',kind:'snowlevel',scope:'COUNTY',source:clean(a.authority,48),sourceUrl:source.toString(),expires:a.expires});});
  }
  return {byRoute,state:'ok',checkedAt:Math.floor(r.at/1000),coverage:'CONFIGURED COUNTIES ONLY'};
}
