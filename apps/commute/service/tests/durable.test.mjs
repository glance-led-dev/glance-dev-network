import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import edge,{SqliteCache,CommuteService} from '../worker/src/durable.mjs';
function storage(){
 const db=new DatabaseSync(':memory:');
 return {sql:{exec(query,...params){const statement=db.prepare(query);return statement.columns().length?statement.all(...params):(statement.run(...params),[]);}},transactionSync(fn){db.exec('BEGIN');try{fn();db.exec('COMMIT');}catch(e){db.exec('ROLLBACK');throw e;}}};
}
test('SQLite cache atomically chunks a statewide payload larger than 2 MB and expires old values',async()=>{
 const s=storage(),cache=new SqliteCache(s),large=JSON.stringify({description:'\u00e9'.repeat(3400000)});
 await cache.put('feed',large,{expirationTtl:60});
 assert.equal((await cache.get('feed','json')).description.length,3400000);
 await cache.put('feed','{"new":true}');assert.deepEqual(await cache.get('feed','json'),{new:true});
 assert.equal([...s.sql.exec('SELECT * FROM cache WHERE key=?','feed')].length,1);
 await cache.put('expired','{}',{expirationTtl:-1});assert.equal(await cache.get('expired','json'),null);
 cache.prune();assert.equal([...s.sql.exec('SELECT * FROM cache WHERE key=?','expired')].length,0);
});
test('public requests cannot start collection or access the private object',async()=>{
 let calls=0;const env={READ_KEY:'test-secret-longer-than-24-chars',SERVICE:{idFromName:()=>1,get:()=>({fetch:()=>{calls++;return new Response('private');}})}};
 assert.equal((await edge.fetch(new Request('https://example.com/status'),env)).status,401);
 assert.equal((await edge.fetch(new Request('https://example.com/tick'),env)).status,404);assert.equal(calls,0);
 assert.equal((await edge.fetch(new Request('https://example.com/status',{headers:{Authorization:'Bearer '+env.READ_KEY}}),env)).status,200);assert.equal(calls,1);
});
test('alarm schedules the next collection even when configuration is unavailable',async()=>{
 const s=storage();let alarm=null;
 s.getAlarm=async()=>alarm;s.setAlarm=async time=>{alarm=time;};
 let ready;const state={storage:s,blockConcurrencyWhile:fn=>{ready=fn();}};
 const service=new CommuteService(state,{});await ready;
 assert.ok(alarm>Date.now());await service.alarm();assert.ok(alarm>=Date.now()+59000);
});
