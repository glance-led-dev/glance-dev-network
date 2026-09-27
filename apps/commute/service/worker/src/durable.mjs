import worker,{refresh,authorized} from './worker.mjs';
import {dashboard} from './dashboard.mjs';

// Chunk statewide feeds below SQLite's 2 MB row limit. Replacement is atomic.
export class SqliteCache {
  constructor(storage){
    this.storage=storage;this.sql=storage.sql;this.rowsWritten=0;
    this.sql.exec('CREATE TABLE IF NOT EXISTS cache (key TEXT NOT NULL, part INTEGER NOT NULL, value TEXT NOT NULL, expires INTEGER NOT NULL, PRIMARY KEY(key,part)) WITHOUT ROWID');
  }
  async get(key,type){
    const rows=[...this.sql.exec('SELECT value,expires FROM cache WHERE key=? ORDER BY part',key)];
    if(!rows.length||(rows[0].expires&&rows[0].expires<=Date.now()))return null;
    const value=rows.map(row=>row.value).join('');return type==='json'?JSON.parse(value):value;
  }
  async put(key,value,options={}){
    const expires=options.expirationTtl?Date.now()+options.expirationTtl*1000:0;
    this.storage.transactionSync(()=>{
      this.rowsWritten+=this.sql.exec('DELETE FROM cache WHERE key=?',key).rowsWritten||0;
      // 400K UTF-16 code units stay below 2 MB even for multibyte text.
      for(let offset=0,part=0;offset<value.length||part===0;offset+=400000,part++)this.rowsWritten+=this.sql.exec('INSERT INTO cache (key,part,value,expires) VALUES (?,?,?,?)',key,part,value.slice(offset,offset+400000),expires).rowsWritten||0;
    });
  }
  prune(){this.rowsWritten+=this.sql.exec('DELETE FROM cache WHERE expires>0 AND expires<=?',Date.now()).rowsWritten||0;}
}
export class CommuteService {
  constructor(state,env){
    this.state=state;this.env={...env,COMMUTE:new SqliteCache(state.storage)};
    state.blockConcurrencyWhile(async()=>{
      if(await state.storage.getAlarm()===null)await state.storage.setAlarm(Date.now()+1000);
    });
  }
  async fetch(request){
    const response=await worker.fetch(request,this.env);
    if(response.status!==200)return response;
    const data=await response.json();data.collector=await this.env.COMMUTE.get('collector-health','json');
    return Response.json(data,{headers:response.headers});
  }
  async alarm(){
    const started=Date.now();let completed=false;this.env.COMMUTE.rowsWritten=0;
    try{this.env.COMMUTE.prune();await refresh(this.env);completed=true;}
    catch{ /* Existing data ages out; never log secrets or provider URLs. */ }
    finally{
      await this.state.storage.setAlarm(Math.max(started+60000,Date.now()+1000));
      await this.env.COMMUTE.put('collector-health',JSON.stringify({completedAt:Math.floor(Date.now()/1000),completed,durationMs:Date.now()-started,storageRowsWritten:this.env.COMMUTE.rowsWritten+2}));
    }
  }
}
export default {
  async fetch(request,env){
    const path=new URL(request.url).pathname;
    if(path==='/'&&request.method==='GET')return dashboard();
    if(path!=='/status')return new Response('Not found',{status:404});
    if(request.method!=='GET')return new Response('Method not allowed',{status:405});
    // Reject strangers before they can start an object, alarm, or provider call.
    if(!await authorized(request,env.READ_KEY))return new Response('Unauthorized',{status:401});
    return env.SERVICE.get(env.SERVICE.idFromName('commute')).fetch(request);
  }
};
