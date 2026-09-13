// Kalshi feed adapter for Prediction Market Ticker (Node 22).
// /?json=1 supplies the GDN app; / serves a separate legacy PNG preview.
// Host secrets: KALSHI_KEY_ID and PKCS#8 KALSHI_PRIVATE_KEY.
// Optional: KALSHI_LABELS (custom labels), KALSHI_CACHE_MS (refresh floor).

const PREFIX = '/trade-api/v2';
const W = 64; // layout width -- content is composed against this
const H = 32;
// Width of the legacy PNG endpoint. Keep 64 for a 64x32 panel.
const CANVAS_W = parseInt(process.env.PANEL_WIDTH ?? '', 10) || 64;
const ROTATE_MS = 8000; // ms per position when several are open
const DEFAULT_CACHE_MS = 15000; // upstream refresh floor; override with KALSHI_CACHE_MS

const WHITE = [255, 255, 255];
const DIM = [110, 110, 110];
const GREEN = [0, 210, 70];
const RED = [235, 45, 45];
const AMBER = [255, 170, 0];

// ---------------------------------------------------------------- font
// 5x7 uppercase bitmap. Each glyph is 7 rows; each row is 5 bits,
// bit 4 = leftmost column.
const FONT = {
  '0': [14, 17, 17, 17, 17, 17, 14],
  '1': [4, 12, 4, 4, 4, 4, 14],
  '2': [14, 17, 1, 2, 4, 8, 31],
  '3': [14, 17, 1, 6, 1, 17, 14],
  '4': [2, 6, 10, 18, 31, 2, 2],
  '5': [31, 16, 30, 1, 1, 17, 14],
  '6': [6, 8, 16, 30, 17, 17, 14],
  '7': [31, 1, 2, 4, 8, 8, 8],
  '8': [14, 17, 17, 14, 17, 17, 14],
  '9': [14, 17, 17, 15, 1, 2, 12],
  A: [14, 17, 17, 31, 17, 17, 17],
  B: [30, 17, 17, 30, 17, 17, 30],
  C: [14, 17, 16, 16, 16, 17, 14],
  D: [28, 18, 17, 17, 17, 18, 28],
  E: [31, 16, 16, 30, 16, 16, 31],
  F: [31, 16, 16, 30, 16, 16, 16],
  G: [14, 17, 16, 23, 17, 17, 14],
  H: [17, 17, 17, 31, 17, 17, 17],
  I: [14, 4, 4, 4, 4, 4, 14],
  J: [7, 2, 2, 2, 2, 18, 12],
  K: [17, 18, 20, 24, 20, 18, 17],
  L: [16, 16, 16, 16, 16, 16, 31],
  M: [17, 27, 21, 17, 17, 17, 17],
  N: [17, 17, 25, 21, 19, 17, 17],
  O: [14, 17, 17, 17, 17, 17, 14],
  P: [30, 17, 17, 30, 16, 16, 16],
  Q: [14, 17, 17, 17, 21, 18, 13],
  R: [30, 17, 17, 30, 20, 18, 17],
  S: [15, 16, 16, 14, 1, 1, 30],
  T: [31, 4, 4, 4, 4, 4, 4],
  U: [17, 17, 17, 17, 17, 17, 14],
  V: [17, 17, 17, 17, 17, 10, 4],
  W: [17, 17, 17, 17, 21, 27, 17],
  X: [17, 17, 10, 4, 10, 17, 17],
  Y: [17, 17, 10, 4, 4, 4, 4],
  Z: [31, 1, 2, 4, 8, 16, 31],
  ' ': [0, 0, 0, 0, 0, 0, 0],
  '-': [0, 0, 0, 14, 0, 0, 0],
  '.': [0, 0, 0, 0, 0, 12, 12],
  '+': [0, 4, 4, 31, 4, 4, 0],
  ':': [0, 0, 6, 6, 0, 6, 6],
  '/': [1, 1, 2, 4, 8, 16, 16],
  '%': [24, 25, 2, 4, 8, 19, 19],
  '\u00A2': [4, 14, 20, 20, 20, 14, 4], // cent sign
  '\u25B2': [0, 0, 4, 14, 31, 0, 0], // up triangle
  '\u25BC': [0, 0, 31, 14, 4, 0, 0], // down triangle
};

// ---------------------------------------------------------------- canvas
class Canvas {
  constructor(w, h) {
    this.w = w;
    this.h = h;
    this.px = new Uint8Array(w * h * 3);
  }
  set(x, y, c) {
    if (x < 0 || y < 0 || x >= this.w || y >= this.h) return;
    const i = (y * this.w + x) * 3;
    this.px[i] = c[0];
    this.px[i + 1] = c[1];
    this.px[i + 2] = c[2];
  }
  // returns the x position after the drawn string
  text(str, x, y, color, scale = 1) {
    let cx = x;
    for (const ch of str.toUpperCase()) {
      const g = FONT[ch] ?? FONT[' '];
      for (let row = 0; row < 7; row++) {
        for (let col = 0; col < 5; col++) {
          if (!(g[row] & (1 << (4 - col)))) continue;
          for (let dy = 0; dy < scale; dy++) {
            for (let dx = 0; dx < scale; dx++) {
              this.set(cx + col * scale + dx, y + row * scale + dy, color);
            }
          }
        }
      }
      cx += 6 * scale;
    }
    return cx;
  }
}

function textWidth(str, scale = 1) {
  return str.length * 6 * scale;
}

// ---------------------------------------------------------------- png
const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c >>> 0;
  }
  return t;
})();

function crc32(bytes) {
  let c = 0xffffffff;
  for (let i = 0; i < bytes.length; i++) {
    c = CRC_TABLE[(c ^ bytes[i]) & 0xff] ^ (c >>> 8);
  }
  return (c ^ 0xffffffff) >>> 0;
}

function u32(n) {
  return new Uint8Array([(n >>> 24) & 255, (n >>> 16) & 255, (n >>> 8) & 255, n & 255]);
}

function concat(arrays) {
  const total = arrays.reduce((s, a) => s + a.length, 0);
  const out = new Uint8Array(total);
  let o = 0;
  for (const a of arrays) {
    out.set(a, o);
    o += a.length;
  }
  return out;
}

function chunk(type, data) {
  const typeBytes = new TextEncoder().encode(type);
  const body = concat([typeBytes, data]);
  return concat([u32(data.length), body, u32(crc32(body))]);
}

async function deflate(bytes) {
  const cs = new CompressionStream('deflate'); // zlib wrapper, what PNG wants
  const writer = cs.writable.getWriter();
  writer.write(bytes);
  writer.close();
  return new Uint8Array(await new Response(cs.readable).arrayBuffer());
}

async function encodePNG(canvas, rgba = false) {
  const bpp = rgba ? 4 : 3;
  const stride = canvas.w * bpp;
  const raw = new Uint8Array((stride + 1) * canvas.h);

  for (let y = 0; y < canvas.h; y++) {
    const rowStart = y * (stride + 1);
    raw[rowStart] = 0; // filter type: none
    for (let x = 0; x < canvas.w; x++) {
      const src = (y * canvas.w + x) * 3;
      const dst = rowStart + 1 + x * bpp;
      raw[dst] = canvas.px[src];
      raw[dst + 1] = canvas.px[src + 1];
      raw[dst + 2] = canvas.px[src + 2];
      if (rgba) raw[dst + 3] = 255;
    }
  }

  const ihdr = concat([
    u32(canvas.w),
    u32(canvas.h),
    // colour type 6 = truecolour + alpha, 2 = truecolour
    new Uint8Array([8, rgba ? 6 : 2, 0, 0, 0]),
  ]);

  return concat([
    new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', await deflate(raw)),
    chunk('IEND', new Uint8Array(0)),
  ]);
}

// ---------------------------------------------------------------- kalshi
let signingKey = null;

async function getKey(pem) {
  if (signingKey) return signingKey;
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const der = Uint8Array.from(atob(b64), (ch) => ch.charCodeAt(0));
  signingKey = await crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSA-PSS', hash: 'SHA-256' },
    false,
    ['sign']
  );
  return signingKey;
}

async function kalshiGet(env, path, query = {}) {
  const host = env.KALSHI_HOST ?? 'https://external-api.kalshi.com';
  const fullPath = PREFIX + path;
  const timestamp = Date.now().toString();

  // Signed message is timestamp + METHOD + path, query string excluded.
  const key = await getKey(env.KALSHI_PRIVATE_KEY);
  const sig = await crypto.subtle.sign(
    { name: 'RSA-PSS', saltLength: 32 },
    key,
    new TextEncoder().encode(`${timestamp}GET${fullPath}`)
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)));

  const url = new URL(host + fullPath);
  for (const [k, v] of Object.entries(query)) url.searchParams.set(k, String(v));

  const res = await fetch(url, {
    headers: {
      'KALSHI-ACCESS-KEY': env.KALSHI_KEY_ID,
      'KALSHI-ACCESS-SIGNATURE': sigB64,
      'KALSHI-ACCESS-TIMESTAMP': timestamp,
      Accept: 'application/json',
    },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`${path} ${res.status} ${body.slice(0, 200)}`);
  }
  return res.json();
}

let cache = { at: 0, rows: null };

// Scoreboard requests contain only league/date, never portfolio or credentials.
const scoreCache = new Map();
const eventCache = new Map();
const TEAM_ALIASES = {"CFB:CALIF":"CFB:CAL","CFB:CLEMSON":"CFB:CLEM","CFB:GTECH":"CFB:GT","CFB:LOUIS":"CFB:LOU","CFB:PIT":"CFB:PITT","CFB:STANF":"CFB:STAN","CFB:VIR":"CFB:UVA","CFB:VA":"CFB:UVA","CFB:WF":"CFB:WAKE","CFB:UMD":"CFB:MD","CFB:MARY":"CFB:MD","CFB:NEBR":"CFB:NEB","CFB:NW":"CFB:NU","CFB:NWEST":"CFB:NU","CFB:OHST":"CFB:OSU","CFB:OREG":"CFB:ORE","CFB:RUT":"CFB:RUTG","CFB:UW":"CFB:WASH","CFB:WISC":"CFB:WIS","CFB:ARI":"CFB:ARIZ","CFB:AZ":"CFB:ARIZ","CFB:AZST":"CFB:ASU","CFB:COL":"CFB:COLO","CFB:CU":"CFB:COLO","CFB:IAST":"CFB:ISU","CFB:KAN":"CFB:KU","CFB:KST":"CFB:KSU","CFB:KSST":"CFB:KSU","CFB:OKSU":"CFB:OKST","CFB:TT":"CFB:TTU","CFB:TEXTCH":"CFB:TTU","CFB:BAMA":"CFB:ALA","CFB:UF":"CFB:FLA","CFB:GA":"CFB:UGA","CFB:MISSST":"CFB:MSST","CFB:MIZ":"CFB:MIZZ","CFB:MO":"CFB:MIZZ","CFB:OKLA":"CFB:OU","CFB:OLEMISS":"CFB:MISS","CFB:SCAR":"CFB:SC","CFB:SOCAR":"CFB:SC","CFB:TEN":"CFB:TENN","CFB:TEXAS":"CFB:TEX","CFB:TA&M":"CFB:TAMU","CFB:TXAM":"CFB:TAMU","CFB:TAM":"CFB:TAMU","CFB:TXA&M":"CFB:TAMU","CFB:VANDY":"CFB:VAN","CFB:VAND":"CFB:VAN","CFB:OREST":"CFB:ORST","CFB:WAZZU":"CFB:WSU","CFB:WSST":"CFB:WSU","NFL:GNB":"NFL:GB","NFL:JAC":"NFL:JAX","NFL:LVR":"NFL:LV","NFL:OAK":"NFL:LV","NFL:SD":"NFL:LAC","NFL:LA":"NFL:LAR","NFL:STL":"NFL:LAR","NFL:NWE":"NFL:NE","NFL:NOR":"NFL:NO","NFL:SFO":"NFL:SF","NFL:TAM":"NFL:TB","NFL:WAS":"NFL:WSH","CFB:MIAMI":"CFB:MIA","CFB:MIAFL":"CFB:MIA","CFB:IND":"CFB:IU","CFB:MIN":"CFB:MINN","CFB:NCST":"CFB:NCSU"};
const TEAM_CODES = {"NFL":["ARI","ATL","BAL","BUF","CAR","CHI","CIN","CLE","DAL","DEN","DET","GB","GNB","HOU","IND","JAC","JAX","KC","LA","LAC","LAR","LV","LVR","MIA","MIN","NE","NO","NOR","NWE","NYG","NYJ","OAK","PHI","PIT","SD","SEA","SF","SFO","STL","TAM","TB","TEN","WAS","WSH"],"CFB":["ALA","ARI","ARIZ","ARK","ASU","AUB","AZ","AZST","BAMA","BAY","BC","BYU","CAL","CALIF","CIN","CLEM","CLEMSON","COL","COLO","CU","DUKE","FLA","FSU","GA","GT","GTECH","HOU","IAST","ILL","IND","IOWA","ISU","IU","KAN","KSST","KST","KSU","KU","LOU","LOUIS","LSU","MARY","MD","MIA","MIAFL","MIAMI","MICH","MIN","MINN","MISS","MISSST","MIZ","MIZZ","MO","MSST","MSU","NCST","NCSU","ND","NEB","NEBR","NU","NW","NWEST","OHST","OKLA","OKST","OKSU","OLEMISS","ORE","OREG","OREST","ORST","OSU","OU","PIT","PITT","PSU","PUR","RUT","RUTG","SC","SCAR","SMU","SOCAR","STAN","STANF","SYR","TA&M","TAM","TAMU","TCU","TEN","TENN","TEX","TEXAS","TEXTCH","TT","TTU","TXA&M","TXAM","UCF","UCLA","UF","UGA","UK","UMD","UNC","USC","UTAH","UVA","UW","VA","VAN","VAND","VANDY","VIR","VT","WAKE","WASH","WAZZU","WF","WIS","WISC","WSST","WSU","WVU"]};
function canonical(league, code) {
  return TEAM_ALIASES[`${league}:${code}`]?.split(':')[1] || code;
}
function footballEvent(ticker, market) {
  const event = String(market.event_ticker || ticker.split('-').slice(0, -1).join('-')).toUpperCase();
  const match = event.match(/^(KXNFL|KXNCAAF|KXCFB)(?:GAME|SPREAD|TOTAL)-(\d{2})([A-Z]{3})(\d{2})([A-Z]+)$/);
  if (!match) return null;
  const month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'].indexOf(match[3]) + 1;
  if (!month) return null;
  const date = `20${match[2]}${String(month).padStart(2,'0')}${match[4]}`;
  const iso = `${date.slice(0,4)}-${date.slice(4,6)}-${date.slice(6,8)}`;
  const parsed = new Date(iso);
  if (isNaN(parsed) || parsed.toISOString().slice(0,10) !== iso) return null;
  return { event, league: match[1] === 'KXNFL' ? 'NFL' : 'CFB', date, pair: match[5] };
}
async function matchupFor(env, info) {
  const codes = TEAM_CODES[info.league] || [];
  const splits = codes.filter(a => info.pair.startsWith(a) && codes.includes(info.pair.slice(a.length)))
    .map(a => [a, info.pair.slice(a.length)]).filter(([a,b]) => a !== b);
  if (splits.length === 1) return splits[0].map(code => ({league:info.league, code}));
  // Unknown or ambiguous ticker encodings must be corroborated by event metadata.
  let entry = eventCache.get(info.event);
  if (!entry || Date.now() - entry.at > 60000) {
    const promise = kalshiGet(env, `/events/${info.event}`).then(r => r.event?.sub_title || '').catch(() => '');
    entry = {at:Date.now(), promise}; eventCache.set(info.event, entry);
    if (eventCache.size > 500) eventCache.delete(eventCache.keys().next().value);
  }
  const subtitle = await entry.promise;
  const match = subtitle.toUpperCase().match(/^([A-Z&]{2,8})\s+(?:VS\.?|AT|@)\s+([A-Z&]{2,8})(?:\s|$)/);
  if (!match || match[1] === match[2] || (match[1]+match[2]).replaceAll('&','') !== info.pair) return null;
  return [match[1],match[2]].map(code => ({league:info.league,code}));
}
async function scoreboard(info) {
  const key = `${info.league}:${info.date}`;
  let entry = scoreCache.get(key);
  if (entry && Date.now() - entry.at < 60000) return entry.promise;
  const previous = entry;
  const promise = (async () => {
    try {
      const sport = info.league === 'NFL' ? 'nfl' : 'college-football';
      const response = await fetch(`https://site.api.espn.com/apis/site/v2/sports/football/${sport}/scoreboard?dates=${info.date}&limit=1000${info.league === 'CFB' ? '&groups=80' : ''}`, {signal:AbortSignal.timeout(1800)});
      if (!response.ok) throw new Error('Scoreboard unavailable');
      const body = await response.json();
      if (!Array.isArray(body.events)) throw new Error('Invalid scoreboard');
      return {events:body.events, fetched_at:Math.floor(Date.now()/1000), stale:false};
    } catch {
      const old = previous ? await previous.promise : null;
      return old ? {...old, stale:true} : null;
    }
  })();
  entry = {at:Date.now(), promise}; scoreCache.set(key,entry);
  if (scoreCache.size > 100) scoreCache.delete(scoreCache.keys().next().value);
  return promise;
}
function scoreFor(board, matchup) {
  if (!board || !matchup) return null;
  const league = matchup[0].league;
  const matches = board.events.flatMap(e => (e.competitions || []).map(c => ({e,c}))).filter(({c}) =>
    c.competitors?.length === 2 && matchup.every(t => c.competitors.some(c => canonical(league,c.team?.abbreviation) === canonical(league,t.code))));
  if (matches.length !== 1) return null;
  const {e,c} = matches[0];
  const status = c.status || e.status || {};
  const state = status.type?.state;
  const name = status.type?.name || '';
  const period = Number(status.period) || 0;
  const clock = /^\d{1,2}:\d{2}$/.test(status.displayClock || '') ? status.displayClock : null;
  const phase = name === 'STATUS_HALFTIME' ? 'HALF' : name.includes('DELAY') ? 'DELAY'
    : name.includes('POSTPON') ? 'POSTP' : name.includes('CANCEL') ? 'CANCEL'
    : state === 'post' ? 'FINAL' : state === 'pre' ? 'PREGAME'
    : state === 'in' ? `${period > 4 ? 'OT'+(period-4) : 'Q'+period}${clock ? ' '+clock : ''}` : 'SCORE N/A';
  const scores = matchup.map(t => {
    const competitor = c.competitors.find(c => canonical(league,c.team?.abbreviation) === canonical(league,t.code));
    return state === 'in' || state === 'post' ? finiteValue(competitor.score) : null;
  });
  return {id:String(e.id), state, phase, period, clock, scores, source:'ESPN', fetched_at:board.fetched_at, stale:board.stale};
}
async function gameContext(env, ticker, market) {
  const info = footballEvent(ticker,market);
  if (!info) return {matchup:null, game:null};
  const [matchup,board] = await Promise.all([matchupFor(env,info),scoreboard(info)]);
  return {matchup,game:scoreFor(board,matchup)};
}

// Ticker suffix numbers are identifiers, not lines: PIT11 can mean >10.5.
function teamForTicker(ticker) {
  const value = String(ticker).toUpperCase();
  const series = value.split('-')[0];
  const league = series.startsWith('KXNFL') ? 'NFL'
    : series.startsWith('KXNCAAF') || series.startsWith('KXCFB') ? 'CFB' : null;
  const code = value.split('-').pop()?.match(/^([A-Z]+)(?:[0-9.]+)?$/)?.[1];
  return league && code ? { league, code } : null;
}

function opponentFor(ticker, market, named) {
  if (!named) return null;
  const event = String(market.event_ticker || String(ticker).split('-').slice(0, -1).join('-')).toUpperCase();
  const parts = event.split('-');
  if (parts.length !== 2 || parts[0] !== String(ticker).split('-')[0].toUpperCase()) return null;
  // Verified Kalshi football event form: series-YYMONDD<team1><team2>.
  const pair = parts[1].match(/^\d{2}[A-Z]{3}\d{2}([A-Z]+)$/)?.[1];
  if (!pair) return null;
  const candidates = [];
  if (pair.startsWith(named.code)) candidates.push(pair.slice(named.code.length));
  if (pair.endsWith(named.code)) candidates.push(pair.slice(0, -named.code.length));
  const valid = [...new Set(candidates.filter(code => /^[A-Z]{2,8}$/.test(code) && code !== named.code))];
  // Unknown or ambiguous event formats retain an explicit YES/NO display.
  return valid.length === 1 ? { league: named.league, code: valid[0] } : null;
}

function finiteValue(value) {
  if (value === null || value === undefined || value === '') return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function signedLine(n) {
  return `${n >= 0 ? '+' : '-'}${Math.abs(n)}`;
}

function selectionFor(ticker, market, yes) {
  const series = String(ticker).split('-')[0].toUpperCase();
  const named = teamForTicker(ticker);
  const side = yes ? 'YES' : 'NO';
  const base = { market_kind: 'binary', market_team: named, team: named, opponent: null, line: null, side_label: side };
  const fallback = String(market.title || market.yes_sub_title || ticker).split(/\s+/)[0].toUpperCase();
  base.label = `${yes ? '' : 'NOT '}${named?.code || fallback}`.slice(0, 20);

  const football = /^(KXNFL|KXNCAAF|KXCFB)/.test(series);
  const strike = finiteValue(market.floor_strike);
  const greater = market.strike_type === 'greater';
  if (football && series.endsWith('SPREAD')) {
    const opponent = opponentFor(ticker, market, named);
    const explicitOver = /wins? by (?:more than|over) /i.test(market.yes_sub_title || market.title || '');
    const supported = strike !== null && (greater || (!market.strike_type && explicitOver));
    // Football margins are whole points. >10 (or >10.5) needs an 11-point win,
    // so the equivalent no-push display is -10.5 / +10.5, never -10 / +10.
    const threshold = supported ? Math.floor(strike) + 0.5 : null;
    const displayTeam = yes ? named : opponent;
    if (threshold !== null && displayTeam && named) {
      const line = yes ? -threshold : threshold;
      return { ...base, market_kind: 'spread', team: displayTeam,
        opponent: yes ? opponent : named, line,
        label: `${displayTeam.code} ${signedLine(line)}`, side_label: 'SPREAD' };
    }
    // Do not imply a guessed opponent or turn a spread into a game total.
    return { ...base, market_kind: 'spread', team: yes ? named : null,
      label: threshold !== null && named
        ? `${side} ${named.code} ${signedLine(-threshold)}` : `${side} ${named?.code || 'SPREAD'}`,
      side_label: side };
  }
  if (football && series.endsWith('TOTAL') && strike !== null && greater) {
    const line = Math.floor(strike) + 0.5;
    return { ...base, market_kind: 'total', team: null, market_team: null,
      line, label: `${yes ? 'OVER' : 'UNDER'} ${line}`, side_label: yes ? 'OVER' : 'UNDER' };
  }
  return base;
}

function statusFor(market, yes) {
  const status = String(market.status || '').toLowerCase();
  const settled = ['settled', 'finalized'].includes(status);
  if (settled) {
    const result = String(market.result || '').toLowerCase();
    return { settled: true, status_label: ['yes', 'no'].includes(result)
      ? (result === (yes ? 'yes' : 'no') ? 'WON' : 'LOST') : 'SETTLED' };
  }
  return { settled: false, status_label: status === 'closed' ? 'CLOSED'
    : status === 'determined' ? 'PENDING'
    : ['inactive', 'initialized'].includes(status) ? 'PAUSED' : null };
}

async function loadRows(env) {
  const cacheMs = parseInt(env.KALSHI_CACHE_MS ?? '', 10) || DEFAULT_CACHE_MS;
  if (cache.rows && Date.now() - cache.at < cacheMs) return cache.rows;

  const positions = [];
  const seen = new Set();
  let cursor = '';
  do {
    const pos = await kalshiGet(env, '/portfolio/positions', {limit:200, ...(cursor ? {cursor} : {})});
    positions.push(...(pos.market_positions || []));
    cursor = pos.cursor || '';
    if (cursor && seen.has(cursor)) throw new Error('Repeated portfolio cursor');
    seen.add(cursor);
  } while (cursor);
  const held = positions.filter(
    (p) => (parseFloat(p.position_fp ?? p.position ?? 0) || 0) !== 0
  );

  let labels = {};
  try {
    labels = JSON.parse(env.KALSHI_LABELS ?? '{}');
  } catch {}

  const rows = [];
  async function positionRow(p) {
    const n = parseFloat(p.position_fp ?? p.position ?? 0);
    const r = await kalshiGet(env, `/markets/${p.ticker}`);
    const m = r.market ?? r;
    const yes = n > 0;

    // The market price IS the implied probability. Use the bid/ask midpoint
    // rather than the bid alone -- the bid is only one side of the spread.
    const mid = (bid, ask) => {
      const b = parseFloat(bid);
      const a = parseFloat(ask);
      if (isNaN(b) && isNaN(a)) return NaN;
      if (isNaN(a)) return b;
      if (isNaN(b)) return a;
      return (a + b) / 2;
    };

    const nowP = yes
      ? mid(m.yes_bid_dollars, m.yes_ask_dollars)
      : mid(m.no_bid_dollars, m.no_ask_dollars);

    const prevYes = mid(m.previous_yes_bid_dollars, m.previous_yes_ask_dollars);
    const prevP = yes ? prevYes : 1 - prevYes;

    const pct = Math.round(nowP * 100);
    const selection = selectionFor(p.ticker, m, yes);

    return {
      ...selection,
      ticker:p.ticker,
      ...await gameContext(env,p.ticker,m),
      label: selection.market_kind === 'spread' ? selection.label : labels[p.ticker] ?? selection.label,
      custom_label: labels[p.ticker] ?? null,
      side: yes ? 'YES' : 'NO',
      pct,
      delta: isNaN(prevP) ? null : pct - Math.round(prevP * 100),
      ...statusFor(m, yes),
    };
  }
  // Bound upstream concurrency while keeping every held position selectable.
  for (let i=0; i<held.length; i+=6) {
    rows.push(...await Promise.all(held.slice(i,i+6).map(positionRow)));
  }
  rows.sort((a,b) => a.ticker.localeCompare(b.ticker));

  cache = { at: Date.now(), rows };
  return rows;
}

// ---------------------------------------------------------------- draw
function drawRow(c, row) {
  // top line: short label, full width available
  c.text(row.label.slice(0, 10), 0, 0, DIM);

  // big probability, 2x scale, occupies y 11..24
  const value = `${row.pct}%`;
  const color = row.delta == null || row.delta === 0 ? WHITE : row.delta > 0 ? GREEN : RED;
  c.text(value, 0, 11, color, 2);

  // delta block on the right, vertically centred against the price
  if (row.delta != null && row.delta !== 0) {
    const arrow = row.delta > 0 ? '\u25B2' : '\u25BC';
    const block = arrow + String(Math.abs(row.delta));
    c.text(block, W - textWidth(block), 14, color);
  }

  // bottom strip: side, or settled flag
  c.text(row.settled ? 'SETTLED' : row.side, 0, 25, row.settled ? AMBER : DIM);
}

function drawMessage(c, top, bottom, color) {
  c.text(top, Math.max(0, (W - textWidth(top)) >> 1), 6, color);
  c.text(bottom, Math.max(0, (W - textWidth(bottom)) >> 1), 17, color);
}

// ---------------------------------------------------------------- handler
// The hosting proxy handles external HTTP/HTTPS; Node listens on PORT.
// The GDN app fetches /?json=1, not the legacy PNG endpoint.

import { createServer } from 'node:http';

const PORT = parseInt(process.env.PORT ?? '8080', 10);

async function render(env, debug, opts = {}) {
  if (opts.solid) {
    // Diagnostic: a flat colour block, no text, same encoder path.
    const c = new Canvas(CANVAS_W, H);
    for (let y = 0; y < H; y++) for (let x = 0; x < CANVAS_W; x++) c.set(x, y, RED);
    return { type: 'image/png', body: Buffer.from(await encodePNG(c, opts.rgba)) };
  }

  if (opts.json) {
    // For the GDN Starlark app: it fetches this and draws natively,
    // so the device never has to decode our PNG.
    try {
      const all = await loadRows(env);
      // Keep first-row rotation for older apps. Version 2 apps sort by ticker
      // and apply their own time-based rotation and selection settings.
      const n = all.length;
      const offset = n > 1 ? Math.floor(Date.now() / 60000) % n : 0;
      const rows = n > 1 ? all.slice(offset).concat(all.slice(0, offset)) : all;
      return {
        type: 'application/json',
        body: Buffer.from(JSON.stringify({ ok: true, version:2, fetched_at:Math.floor(cache.at/1000), count: n, rows })),
      };
    } catch (err) {
      return {
        type: 'application/json',
        body: Buffer.from(JSON.stringify({ ok: false, error: err.message, rows: [] })),
      };
    }
  }

  if (debug) {
    const out = {
      has_key_id: Boolean(env.KALSHI_KEY_ID),
      has_private_key: Boolean(env.KALSHI_PRIVATE_KEY),
      key_first_line: (env.KALSHI_PRIVATE_KEY ?? '').split('\n')[0],
    };
    try {
      cache = { at: 0, rows: null };
      out.rows = await loadRows(env);
    } catch (err) {
      out.rows = `FAILED: ${err.message}`;
    }
    return { type: 'application/json', body: Buffer.from(JSON.stringify(out, null, 2)) };
  }

  const c = new Canvas(CANVAS_W, H);
  try {
    const rows = await loadRows(env);
    if (rows.length === 0) drawMessage(c, 'NO OPEN', 'MARKETS', DIM);
    else drawRow(c, rows[Math.floor(Date.now() / ROTATE_MS) % rows.length]);
  } catch (err) {
    console.error(err.message);
    drawMessage(c, 'KALSHI', 'ERROR', RED);
  }
  return { type: 'image/png', body: Buffer.from(await encodePNG(c, opts.rgba)) };
}

createServer(async (req, res) => {
  const q = new URL(req.url, 'http://localhost').searchParams;
  const debug = q.has('debug');
  const opts = {
    solid: q.has('solid'),
    rgba: q.get('fmt') === 'rgba' || process.env.PNG_FORMAT === 'rgba',
    json: q.has('json'),
  };
  try {
    const { type, body } = await render(process.env, debug, opts);
    res.writeHead(200, { 'Content-Type': type, 'Cache-Control': 'no-store' });
    res.end(body);
  } catch (err) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end(String(err.message));
  }
}).listen(PORT, '0.0.0.0', () => {
  console.log(`listening on http://0.0.0.0:${PORT}`);
});
