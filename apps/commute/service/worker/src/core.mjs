export const clean = (s, n = 96) => String(s ?? '').toUpperCase().replace(/[^A-Z0-9 :+.,/'()%-]/g, ' ').replace(/\s+/g, ' ').trim().slice(0, n);
export const seconds = v => Number.isFinite(v) && v >= 0 ? v : null;
export function get(o, key) { return o?.[key] ?? o?.[key[0].toUpperCase() + key.slice(1)]; }
export function point(p) {
  const lat = p?.lat ?? p?.latitude, lon = p?.lon ?? p?.longitude;
  if (!Number.isFinite(lat) || !Number.isFinite(lon) || Math.abs(lat) > 90 || Math.abs(lon) > 180) throw Error('INVALID_LOCATION');
  return {lat, lon};
}
export function validateConfig(raw) {
  const c = typeof raw === 'string' ? JSON.parse(raw) : structuredClone(raw);
  if (!c || !c.origin || !c.destination) throw Error('SETUP_REQUIRED');
  for (const p of [c.origin, c.destination, ...(c.stop?.enabled ? [c.stop.location] : [])]) {
    if (p?.address) {
      if (typeof p.address !== 'string' || p.address.length < 6 || p.address.length > 300 || /ENTER YOUR|ENTER OPTIONAL/.test(p.address)) throw Error('INVALID_ADDRESS');
    } else point(p);
  }
  c.timeZone ||= 'America/New_York';
  new Intl.DateTimeFormat('en-US', {timeZone: c.timeZone}).format();
  for (const k of ['arriveBy', 'activeStart', 'activeEnd']) {
    c[k] ||= {arriveBy:'08:00', activeStart:'05:00', activeEnd:'10:00'}[k];
    if (!/^([01]\d|2[0-3]):[0-5]\d$/.test(c[k])) throw Error('INVALID_TIME');
  }
  c.days ??= [1,2,3,4,5];
  if (!Array.isArray(c.days) || !c.days.length || c.days.some(x => !Number.isInteger(x) || x < 0 || x > 6)) throw Error('INVALID_DAYS');
  c.outsideIntervalMinutes ??= 15;
  if (!Number.isInteger(c.outsideIntervalMinutes) || c.outsideIntervalMinutes < 1 || c.outsideIntervalMinutes > 60) throw Error('INVALID_INTERVAL');
  c.stop ??= {enabled:false};
  c.stop.durationMinutes ??= 5;
  if (typeof c.stop.enabled !== 'boolean' || !Number.isFinite(c.stop.durationMinutes) || c.stop.durationMinutes < 0 || c.stop.durationMinutes > 120) throw Error('INVALID_STOP');
  c.stop.name = clean(c.stop.name || 'STOP', 24);
  c.label = clean(c.label || 'WORK', 12);
  c.routeOptions ??= [];
  if (!Array.isArray(c.routeOptions) || c.routeOptions.length > 2) throw Error('INVALID_ROUTE_OPTIONS');
  for (const route of c.routeOptions) {
    if (!Array.isArray(route.via) || !route.via.length || route.via.length > 6) throw Error('INVALID_WAYPOINTS');
    route.via = route.via.map(point);
    route.name = clean(route.name || 'CUSTOM ROUTE', 40);
  }
  c.alertAreas ??= ['OH'];
  if (!Array.isArray(c.alertAreas) || !c.alertAreas.length || c.alertAreas.length > 5 || c.alertAreas.some(s => !/^[A-Z]{2}$/.test(s))) throw Error('INVALID_ALERT_AREAS');
  return c;
}
export function localParts(ms, zone) {
  return Object.fromEntries(new Intl.DateTimeFormat('en-US', {timeZone:zone, year:'numeric',month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit',second:'2-digit',hourCycle:'h23',weekday:'short'}).formatToParts(ms).filter(p => p.type !== 'literal').map(p => [p.type,p.value]));
}
export function intervalSeconds(c, ms) {
  const p = localParts(ms,c.timeZone), day = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'].indexOf(p.weekday), time = p.hour+':'+p.minute;
  const normal = c.activeStart < c.activeEnd;
  const inside = normal ? time >= c.activeStart && time < c.activeEnd : c.activeStart === c.activeEnd || time >= c.activeStart || time < c.activeEnd;
  // Overnight windows belong to their starting weekday.
  const owner = !normal && c.activeStart !== c.activeEnd && time < c.activeEnd ? (day+6)%7 : day;
  return inside && c.days.includes(owner) ? 60 : c.outsideIntervalMinutes*60;
}
export function clock(ms, zone) {
  if (!Number.isFinite(ms)) return '--';
  return new Intl.DateTimeFormat('en-US',{timeZone:zone,hour:'numeric',minute:'2-digit',hour12:true}).format(ms).replace(/\s/g,'').replace('AM','A').replace('PM','P');
}
export function arriveTarget(c, ms) {
  // Today's target remains today's even when late. Never silently roll to tomorrow.
  const p = localParts(ms,c.timeZone), [h,m] = c.arriveBy.split(':').map(Number);
  const desired = Date.UTC(+p.year,+p.month-1,+p.day,h,m);
  let guess = desired;
  for (let i=0;i<4;i++) {
    const q=localParts(guess,c.timeZone);
    const actual=Date.UTC(+q.year,+q.month-1,+q.day,+q.hour,+q.minute,+q.second);
    guess += desired-actual;
  }
  const q=localParts(guess,c.timeZone);
  if (q.hour+':'+q.minute !== c.arriveBy || q.day !== p.day) return null; // DST gap
  return guess;
}
export function roadIdentity(name) {
  const s=clean(name,80), i=s.match(/^(?:I[ -]?|INTERSTATE[ -]?)(\d{1,3})(?:\b|$)/);
  if (i) return {label:'I-'+i[1],kind:'interstate',number:i[1]};
  const us=s.match(/^US[ -]?(\d{1,3})(?:\b|$)/);
  if (us) return {label:'US-'+us[1],kind:'us',number:us[1]};
  const state=s.match(/^(?:OH|SR|STATE ROUTE)[ -]?(\d{1,3})(?:\b|$)/);
  if (state) return {label:'SR-'+state[1],kind:'state',number:state[1]};
  return {label:s || 'ROUTE UNNAMED',kind:'road',number:''};
}
export function routeName(route) {
  const stretches=(route.sections||[]).filter(s=>s.sectionType==='IMPORTANT_ROAD_STRETCH').sort((a,b)=>a.importantRoadStretchIndex-b.importantRoadStretchIndex);
  for(const s of stretches) {
    const name=s.roadNumbers?.[0]?.text || s.streetName?.text;
    if(name) return roadIdentity(name);
  }
  const ins=route.guidance?.instructions||[], lengths=new Map();
  for(let i=0;i<ins.length;i++) {
    const name=ins[i].roadNumbers?.[0] || ins[i].street;
    const length=Math.max(0,(ins[i+1]?.routeOffsetInMeters ?? route.summary?.lengthInMeters ?? 0)-(ins[i].routeOffsetInMeters||0));
    if(name) lengths.set(name,(lengths.get(name)||0)+length);
  }
  return roadIdentity([...lengths].sort((a,b)=>b[1]-a[1])[0]?.[0]);
}
export function normalizeRoute(raw) {
  const s=raw.summary||{};
  if(seconds(s.travelTimeInSeconds) === null) throw Error('INVALID_ROUTE');
  const polyline=(raw.legs||[]).flatMap(l=>(l.points||[]).map(point));
  if(polyline.length<2) throw Error('MISSING_ROUTE_GEOMETRY');
  return {road:routeName(raw),seconds:s.travelTimeInSeconds,normalSeconds:seconds(s.historicTrafficTravelTimeInSeconds),freeFlowSeconds:seconds(s.noTrafficTravelTimeInSeconds),distance:s.lengthInMeters,polyline,traffic:(raw.sections||[]).filter(s=>s.sectionType==='TRAFFIC').map(s=>({category:clean(s.simpleCategory||'TRAFFIC'),delay:seconds(s.delayInSeconds),start:s.startPointIndex,end:s.endPointIndex}))};
}
export function combineStop(a,b,dwell) {
  return {road:b.distance>=a.distance?b.road:a.road,seconds:a.seconds+b.seconds+dwell,normalSeconds:a.normalSeconds===null||b.normalSeconds===null?null:a.normalSeconds+b.normalSeconds+dwell,freeFlowSeconds:a.freeFlowSeconds===null||b.freeFlowSeconds===null?null:a.freeFlowSeconds+b.freeFlowSeconds+dwell,distance:a.distance+b.distance,polyline:[...a.polyline,...b.polyline],traffic:[...a.traffic,...b.traffic],stopSeconds:dwell};
}
export function publicRoute(r,c,now) {
  if(!r) return null;
  const target=arriveTarget(c,now), leave=target===null?null:target-r.seconds*1000;
  return {road:r.road,minutes:Math.ceil(r.seconds/60),seconds:r.seconds,normalMinutes:r.normalSeconds===null?null:Math.ceil(r.normalSeconds/60),delayMinutes:r.normalSeconds===null?null:Math.round((r.seconds-r.normalSeconds)/60),arrival:clock(now+r.seconds*1000,c.timeZone),leaveBy:clock(leave,c.timeZone),leaveAt:leave===null?null:Math.floor(leave/1000),late:target!==null&&now+r.seconds*1000>target,leaveByBasis:'CURRENT_ETA',stopMinutes:Math.round((r.stopSeconds||0)/60)};
}
export function selectCommuteRoute(candidates,previous,now){
  const sorted=[...candidates].sort((a,b)=>a.seconds-b.seconds),fastest=sorted[0];
  // Keep the previous road for sub-two-minute fluctuations, but only while it
  // was recently checked and is among the provider's currently valid routes.
  const prior=previous&&now/1000-previous.updatedAt>=0&&now/1000-previous.updatedAt<=180?sorted.find(r=>r.road.label===previous.direct?.road?.label):null;
  const direct=prior&&prior.seconds-fastest.seconds<120?prior:fastest;
  const alternatives=sorted.filter(r=>r!==direct),other=alternatives.find(r=>r.road.label!==direct.road.label);
  const difference=other?other.seconds-direct.seconds:null;
  return {direct,alternatives,recommendation:{kind:difference===null?'only':Math.abs(difference)<120?'similar':difference>0?'faster':'slower',minutes:difference===null?null:Math.floor(Math.abs(difference)/60),otherRoad:other?.road.label||null}};
}
// Route/corridor geometry, in kilometres. Nearby events are explicitly labelled NEAR ROUTE.
export function segmentDistance(p,a,b) {
  const xscale=111.32*Math.cos(p.lat*Math.PI/180), yscale=111.32;
  const ax=(a.lon-p.lon)*xscale, ay=(a.lat-p.lat)*yscale, bx=(b.lon-p.lon)*xscale, by=(b.lat-p.lat)*yscale;
  const dx=bx-ax,dy=by-ay,t=Math.max(0,Math.min(1,-(ax*dx+ay*dy)/(dx*dx+dy*dy||1)));
  return Math.hypot(ax+t*dx,ay+t*dy);
}
export function nearRoute(p,line,km=.35) { return line.some((v,i)=>i>0&&segmentDistance(p,line[i-1],v)<=km); }
function cross(a,b,c){return (b.lon-a.lon)*(c.lat-a.lat)-(b.lat-a.lat)*(c.lon-a.lon);}
function onSegment(a,b,p){return Math.abs(cross(a,b,p))<1e-10&&p.lon>=Math.min(a.lon,b.lon)-1e-10&&p.lon<=Math.max(a.lon,b.lon)+1e-10&&p.lat>=Math.min(a.lat,b.lat)-1e-10&&p.lat<=Math.max(a.lat,b.lat)+1e-10;}
export function intersects(a,b,c,d){ const x=cross(a,b,c),y=cross(a,b,d),z=cross(c,d,a),w=cross(c,d,b);return (x*y<0&&z*w<0)||onSegment(a,b,c)||onSegment(a,b,d)||onSegment(c,d,a)||onSegment(c,d,b); }
function inside(p,ring){let yes=false;for(let i=0,j=ring.length-1;i<ring.length;j=i++){const a={lon:ring[i][0],lat:ring[i][1]},b={lon:ring[j][0],lat:ring[j][1]};if(onSegment(a,b,p))return true;if((a.lat>p.lat)!==(b.lat>p.lat)&&p.lon<(b.lon-a.lon)*(p.lat-a.lat)/(b.lat-a.lat)+a.lon)yes=!yes;}return yes;}
export function polygonHits(line,geometry){
  const polys=geometry?.type==='Polygon'?[geometry.coordinates]:geometry?.type==='MultiPolygon'?geometry.coordinates:[];
  return polys.some(rings=>line.some(p=>inside(p,rings[0])&&!rings.slice(1).some(r=>inside(p,r)))||rings.some(r=>r.some((v,i)=>i>0&&line.some((p,j)=>j>0&&intersects(line[j-1],p,{lon:r[i-1][0],lat:r[i-1][1]},{lon:v[0],lat:v[1]})))));
}
export function linesNear(a,b,km=.35){return a.some(p=>nearRoute(p,b,km))||b.some(p=>nearRoute(p,a,km))||a.some((p,i)=>i>0&&b.some((q,j)=>j>0&&intersects(a[i-1],p,b[j-1],q)));}
export function weatherKind(text,isDay=true){
  const s=String(text||'').toLowerCase();
  if(/thunder|storm/.test(s))return 'storm';
  if(/snow|sleet|ice|freezing/.test(s))return 'snow';
  if(/rain|drizzle|shower/.test(s))return 'rain';
  if(/fog|mist|haze|smoke/.test(s))return 'fog';
  if(/partly|mostly sunny|mostly clear/.test(s))return 'partly';
  if(/cloud|overcast/.test(s))return 'cloud';
  if(/sunny|clear|fair/.test(s))return isDay?'sun':'moon';
  return 'unknown';
}
export function ohgoSensorTime(value){
  if(typeof value!=='string')return NaN;
  if(/(?:Z|[+-]\d\d:\d\d)$/i.test(value))return Date.parse(value);
  const m=value.match(/^(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)(?:\.\d+)?$/);
  if(!m)return NaN;
  const wall=Date.UTC(+m[1],+m[2]-1,+m[3],+m[4],+m[5],+m[6]);
  for(const hours of [4,5]){
    const candidate=wall+hours*3600e3,p=localParts(candidate,'America/New_York');
    if(p.year+'-'+p.month+'-'+p.day+'T'+p.hour+':'+p.minute+':'+p.second===value.slice(0,19))return candidate;
  }
  return NaN;
}

export function ohgoEvents(payload,line,kind,now){
  const results=get(payload,'results');if(!Array.isArray(results))throw Error('INVALID_OHGO');
  const stamp=Date.parse(get(payload,'lastUpdated'));
  if(!Number.isFinite(stamp)||now-stamp>15*60e3||stamp>now+60e3)throw Error('STALE_OHGO');
  if((get(payload,'rejectedFilters')||[]).length)throw Error('OHGO_FILTER_REJECTED');
  const events=[];
  for(const r of results){
    const start=Date.parse(get(r,'startDate')),end=Date.parse(get(r,'endDate'));
    if(start>now||end<=now)continue;
    const paths=[get(get(r,'roadClosureDetails'),'polyline'),...(get(r,'workZones')||[]).map(z=>get(z,'polyline'))].filter(Array.isArray).map(a=>a.filter(p=>Array.isArray(p)&&p.length>=2&&p.every(Number.isFinite)).map(p=>({lon:p[0],lat:p[1]})));
    const lat=get(r,'latitude'),lon=get(r,'longitude');
    if(!paths.some(p=>linesNear(p,line))&&!(Number.isFinite(lat)&&Number.isFinite(lon)&&nearRoute({lat,lon},line)))continue;
    let title=clean(get(r,'category')||kind),detail=clean(get(r,'description')||get(r,'location'),180),expires=null;
    const closed=/closed/i.test(get(r,'roadStatus')||get(r,'status')||'');
    if(kind==='delay'){
      const delay=get(r,'delayTime');
      if(!Number.isFinite(delay)||delay<=0)continue;
      title='TRAFFIC DELAY';detail=Math.ceil(delay)+' MIN SEGMENT DELAY';
      const speed=get(r,'currentAvgSpeed');if(Number.isFinite(speed))detail+=' / '+Math.round(speed)+' MPH';
      expires=new Date(stamp+180e3).toISOString();
    }
    if(kind==='slowdown'){
      title='DANGEROUS SLOWDOWN';
      const speed=get(r,'currentMPH'),normal=get(r,'normalMPH');
      if(Number.isFinite(speed)&&Number.isFinite(normal))detail=Math.round(speed)+' MPH / USUAL '+Math.round(normal)+' MPH';
      expires=new Date(stamp+180e3).toISOString();
    }
    if(kind==='surface'){
      const sensors=[...(get(r,'surfaceSensors')||[]),...(get(r,'atmosphericSensors')||[])].filter(s=>{const t=ohgoSensorTime(get(s,'lastUpdate'));return Number.isFinite(t)&&now-t<20*60e3&&t<=now+60e3;});
      const hazards=sensors.map(s=>get(s,'status')||get(s,'precipitation')||'').filter(s=>/snow|ice|frost|slush|wet|rain|flood/i.test(s));
      if(!hazards.length)continue;
      title='ROAD '+clean(hazards[0],20);detail=clean(get(r,'location'));expires=new Date(Math.min(...sensors.map(s=>ohgoSensorTime(get(s,'lastUpdate'))))+20*60e3).toISOString();
    }
    events.push({id:'ohgo-'+kind+'-'+get(r,'id'),title:closed?'ROAD CLOSED':kind==='construction'?'CONSTRUCTION':title,detail,road:clean(get(r,'routeName')||get(r,'location'),48),severity:closed||kind==='slowdown'?'Severe':['surface','delay','incident'].includes(kind)?'Moderate':'Minor',kind:closed?'closure':kind,scope:'NEAR ROUTE',source:'OHGO',expires:expires||(Number.isFinite(end)?new Date(end).toISOString():null)});
  }
  return events;
}
export function nwsEvents(features,line,now){
  return features.filter(f=>{
    const p=f.properties||{},expires=Date.parse(p.expires),onset=Date.parse(p.onset||p.effective);
    return p.status==='Actual'&&p.messageType!=='Cancel'&&Number.isFinite(expires)&&expires>now&&polygonHits(line,f.geometry);
  }).map(f=>({id:f.id||f.properties.id,title:clean(f.properties.event,64),detail:clean(f.properties.headline,180),severity:f.properties.severity,kind:'weather',scope:'ROUTE AREA',source:'NWS',expires:f.properties.expires}));
}
export function sortAlerts(events){const ranks={Extreme:0,Severe:1,Moderate:2,Minor:3,Unknown:4};return [...new Map(events.map(e=>[e.id,e])).values()].sort((a,b)=>(ranks[a.severity]??4)-(ranks[b.severity]??4)||(a.kind==='closure'?-1:0)-(b.kind==='closure'?-1:0));}
