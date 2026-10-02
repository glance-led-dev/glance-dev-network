import {normalizeTracker} from './tracking.mjs';
const labels={delivered:'DELIVERED',out_for_delivery:'OUT FOR DELIVERY',failure:['DELAYED','DELIVERY ATTEMPTED'],in_transit:'IN TRANSIT',unknown:'DELIVERY EXPECTED'};
export function validNotification(n,carrier,now){
 if(!['UPS','USPS'].includes(carrier)||!n||typeof n!=='object')return false;
 const allowed=labels[n.status];
 if(!allowed||!(Array.isArray(allowed)?allowed.includes(n.message):allowed===n.message))return false;
 if(!Number.isSafeInteger(n.notified_at)||n.notified_at<=0||n.notified_at>now+300)return false;
 if(typeof n.expected_date!=='string'||!/^$|^\d{4}-\d{2}-\d{2}$/.test(n.expected_date))return false;
 if(n.expected_date&&(Number.isNaN(Date.parse(n.expected_date))||new Date(n.expected_date).toISOString().slice(0,10)!==n.expected_date))return false;
 return typeof n.delivery_window==='string'&&/^$|^BY (?:[1-9]|1[0-2]):[0-5]\d [AP]M$/.test(n.delivery_window);
}
export async function applyNotification(db,record,n,timezone){
 const id=record.carrier+':'+record.tracking_code;
 const row=await db.prepare('SELECT * FROM packages WHERE id=?').bind(id).first();
 let old;try{old=JSON.parse(row.normalized||'null');}catch{}
 // API results take precedence; delivered is terminal. Duplicate mail is a no-op.
 const previous=old?.notification_at||0;
 const enrich=previous===n.notified_at&&row.status===n.status&&!old.expected_date&&!!n.expected_date;
 if(row.status==='delivered'||(old&&old.source!=='EMAIL')||(previous>=n.notified_at&&!enrich))return;
 const value=normalizeTracker({status:n.status,est_delivery_date:n.expected_date},record,timezone);
 value.latest_message=n.message;value.delivery_window=n.delivery_window;
 value.source='EMAIL';value.notification_at=n.notified_at;
 value.notification_time=new Intl.DateTimeFormat('en-US',{timeZone:timezone,month:'short',day:'numeric',hour:'numeric',minute:'2-digit',timeZoneName:'short'}).format(new Date(n.notified_at*1000)).replace(/,/g,'').toUpperCase();
 value.stage=Math.max(value.stage,old?.stage??-1);
 await db.prepare('UPDATE packages SET status=?,normalized=?,checked_at=?,error=NULL WHERE id=?').bind(value.status,JSON.stringify(value),n.notified_at,id).run();
}
