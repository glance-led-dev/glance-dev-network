const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
let src = fs.readFileSync(path.join(__dirname, 'server.mjs'), 'utf8');
src = src.replace("import { createServer } from 'node:http';", '');
src = src.slice(0, src.indexOf('createServer(async (req, res) =>'));
src += '\nglobalThis.testAPI = {teamForTicker, selectionFor, statusFor, footballEvent, matchupFor, scoreFor, scoreboard, loadRows, render, stub(fn) { kalshiGet = fn; cache = {at:0, rows:null}; scoreCache.clear(); eventCache.clear(); }};';
const sandbox = {process:{env:{}}, Buffer, TextEncoder, Uint8Array, Uint32Array, Date, console};
vm.createContext(sandbox); vm.runInContext(src,sandbox);
const api = sandbox.testAPI;
const norm = x => JSON.parse(JSON.stringify(x));
const spread = (line=10.5, extra={}) => ({floor_strike:line, strike_type:'greater', ...extra});
const ticker = 'KXNFLSPREAD-26SEP13ATLPIT-PIT11';
let selected = api.selectionFor(ticker, spread(), false);
assert.equal(selected.label, 'ATL +10.5');
assert.deepEqual(norm(selected.team), {league:'NFL',code:'ATL'});
assert.equal(selected.market_team.code,'PIT');
assert.equal(selected.side_label,'SPREAD');
assert.equal(selected.line,10.5);
selected = api.selectionFor(ticker,spread(),true);
assert.equal(selected.label,'PIT -10.5');
assert.equal(selected.team.code,'PIT');
// Same behavior with the named team first in the event code.
assert.equal(api.selectionFor('KXNFLSPREAD-26SEP13PITATL-PIT11',spread(),false).label,'ATL +10.5');
// Opposing a college favorite displays the college opponent, including an alias.
assert.equal(api.selectionFor('KXNCAAFSPREAD-26SEP11MIZZKU-MIZZ5',spread(4.5),false).label,'KU +4.5');
assert.equal(api.selectionFor('KXNCAAFSPREAD-26SEP11MIZZKU-MIZZ5',spread(4.5),true).label,'MIZZ -4.5');
assert.equal(api.selectionFor('KXNCAAFSPREAD-26SEP13PITWVU-PIT11',spread(),false).team.league,'CFB');
// Greater-than integer boundaries cannot be displayed as push-capable whole lines.
assert.equal(api.selectionFor(ticker,spread(10),false).line,10.5);
assert.equal(api.selectionFor(ticker,spread(-2.5),false).line,-2.5);
assert.equal(api.selectionFor(ticker,spread(-2.5),true).line,2.5);
for (const m of [spread(null),spread('',{}),spread(10.5,{strike_type:'less'}),spread(undefined)]) {
 if(m.floor_strike===10.5 && m.strike_type==='greater') continue;
 assert.equal(api.selectionFor(ticker,m,false).team,null);
 assert.equal(api.selectionFor(ticker,m,false).line,null);
}
// Don't guess when the event format or team boundary is unknown or ambiguous.
for(const bad of ['KXNFLSPREAD-UNKNOWN-PIT11','KXNFLSPREAD-26SEP13DALATL-PIT11','KXNFLSPREAD-26SEP13PITATLPIT-PIT11']) {
 const row=api.selectionFor(bad,spread(),false);
 assert.equal(row.label,'NO PIT -10.5');assert.equal(row.team,null);assert.equal(row.line,null);
}
assert.equal(api.selectionFor(ticker,spread(10.5,{event_ticker:'KXNCAAFSPREAD-26SEP13ATLPIT'}),false).team,null);
// Totals are over/under, never an opposing team spread.
selected=api.selectionFor('KXNFLTOTAL-26SEP13CHICAR-98',spread(97.5),false);
assert.equal(selected.label,'UNDER 97.5');assert.equal(selected.team,null);
assert.equal(selected.market_kind,'total');
// A floor strike alone must not turn a non-sports binary market into OVER/UNDER.
selected=api.selectionFor('KXELECTION-26NOV-PIT',spread(),false);
assert.equal(selected.side_label,'NO');assert.equal(selected.market_kind,'binary');
assert.equal(selected.team,null);
assert.deepEqual(norm(api.statusFor({status:'closed'},true)),{settled:false,status_label:'CLOSED'});
assert.deepEqual(norm(api.statusFor({status:'determined',result:'yes'},true)),{settled:false,status_label:'PENDING'});
assert.equal(api.statusFor({status:'finalized',result:'no'},false).status_label,'WON');
assert.equal(api.statusFor({status:'settled',result:'yes'},false).status_label,'LOST');
assert.equal(api.statusFor({status:'active'},true).settled,false);

const quotes={status:'active',yes_bid_dollars:'0.37',yes_ask_dollars:'0.41',no_bid_dollars:'0.59',no_ask_dollars:'0.63',previous_yes_bid_dollars:'0.31',previous_yes_ask_dollars:'0.35'};
api.stub(async(_env,p)=>p==='/portfolio/positions'?{market_positions:[{ticker,position_fp:'-1.00'}]}:{market:{...spread(),...quotes}});
(async()=>{
 const env={KALSHI_LABELS:JSON.stringify({[ticker]:'PIT U10.5'})};
 const [row]=await api.loadRows(env);
 assert.equal(row.side,'NO');assert.equal(row.label,'ATL +10.5');
 assert.equal(row.custom_label,'PIT U10.5');assert.equal(row.team.code,'ATL');
 assert.equal(row.pct,61);assert.equal(row.delta,-6); // NO quote, NOT a second complement.
 const feed=JSON.parse((await api.render(env,false,{json:true})).body.toString());
 assert.equal(feed.rows[0].line,10.5); assert.equal(feed.rows[0].pct,61);
 // Missing NO quotes stay unavailable, not a fabricated probability.
 api.stub(async(_env,p)=>p==='/portfolio/positions'?{market_positions:[{ticker,position_fp:'-1'}]}:{market:{...spread(),status:'active'}});
 const missing=JSON.parse((await api.render({},false,{json:true})).body.toString());
 assert.equal(missing.rows[0].pct,null);
 const info=api.footballEvent('KXNFLTOTAL-26SEP13CHICAR-98',{});
 assert.equal(info.date,'20260913');
 assert.equal(api.footballEvent('KXNFLTOTAL-26FEB31CHICAR-98',{}),null);
 const matchup=await api.matchupFor({},info);
 assert.deepEqual(norm(matchup),[{league:'NFL',code:'CHI'},{league:'NFL',code:'CAR'}]);
 const fixture={events:[{id:'test-game',status:{period:3,displayClock:'8:42',type:{state:'in',name:'STATUS_IN_PROGRESS'}},competitions:[{competitors:[{team:{abbreviation:'CAR'},score:'10'},{team:{abbreviation:'CHI'},score:'21'}]}]}],fetched_at:100,stale:false};
 let game=api.scoreFor(fixture,matchup);
 assert.deepEqual(norm(game.scores),[21,10]);assert.equal(game.phase,'Q3 8:42');
 assert.equal(game.fetched_at,100);
 for(const [state,name,period,phase] of [['in','STATUS_HALFTIME',2,'HALF'],['pre','STATUS_SCHEDULED',0,'PREGAME'],['post','STATUS_FINAL',4,'FINAL'],['in','STATUS_DELAYED',3,'DELAY'],['in','STATUS_IN_PROGRESS',5,'OT1 8:42']]) {
  fixture.events[0].status={period,displayClock:'8:42',type:{state,name}};
  game=api.scoreFor(fixture,matchup);assert.equal(game.phase,phase);
  if(state==='pre')assert.deepEqual(norm(game.scores),[null,null]);
 }
 assert.equal(api.scoreFor({...fixture,events:[...fixture.events,...fixture.events]},matchup),null);
 assert.equal(api.scoreFor(fixture,[{league:'NFL',code:'PIT'},{league:'NFL',code:'ATL'}]),null);
 // Public data captured from ESPN: proves real response shape and score ordering.
 const samplePath=path.join(__dirname,'scoreboard.json');
 if(fs.existsSync(samplePath)) {
  const live=api.scoreFor({...JSON.parse(fs.readFileSync(samplePath)),fetched_at:100},matchup);
  assert.ok(live);assert.equal(live.source,'ESPN');assert.equal(live.scores.length,2);
 }
 let calls=0;
 sandbox.AbortSignal=AbortSignal;
 sandbox.fetch=async()=>{calls++;return {ok:true,json:async()=>({events:fixture.events})}};
 // Earlier tests have a failed request cached; reset before a clean fetch test.
 api.stub(async()=>({}));calls=0;
 await Promise.all([api.scoreboard(info),api.scoreboard(info)]);assert.equal(calls,1);
 const original=await api.scoreboard(info);
 const originalNow=Date.now();
 sandbox.Date=class extends Date {static now(){return originalNow+61000;}};
 sandbox.fetch=async()=>{throw new Error('offline')};
 const stale=await api.scoreboard(info);
 assert.equal(stale.stale,true);assert.equal(stale.fetched_at,original.fetched_at);
 sandbox.Date=Date;
 api.stub(async()=>({}));
 assert.equal(await api.scoreboard(info),null);
 // All positions, including a second portfolio page, survive beyond the old cap of six.
 let pageCalls=0;
 api.stub(async(_env,p,q)=>{
  if(p==='/portfolio/positions') {pageCalls++;return q.cursor ? {market_positions:[{ticker:'KXOTHER-X-9',position:1}]} : {cursor:'page2',market_positions:Array.from({length:8},(_,i)=>({ticker:'KXOTHER-X-'+i,position:1}))};}
  return {market:quotes};
 });
 const all=await api.loadRows({});assert.equal(all.length,9);assert.equal(pageCalls,2);assert.ok(all.every(r=>r.ticker));
 const allFeed=JSON.parse((await api.render({},false,{json:true})).body);
 assert.equal(allFeed.version,2);assert.equal(allFeed.count,9);assert.ok(allFeed.fetched_at);
 console.log('Passed: NFL/CFB YES/NO spread selection, opponent safety, actual thresholds, totals, custom labels, held-side prices and resolution states.');
 console.log('Passed: matchup resolution, score ordering, regulation/OT/halftime/pregame/final/delay, ambiguous games, scoreboard deduplication, pagination and versioned feed.');
})().catch(e=>{console.error(e);process.exitCode=1});
