"""Opt-in HSS paid-request guard for one shared GDN render host.

SQLite reservations coordinate threads AND sandbox subprocesses. Deployments
with multiple hosts must put this policy behind a cluster-wide transactional
store; independent local databases do not provide a global spending limit.
No API key, request headers or raw request URL is persisted, only a hash.
"""
from __future__ import annotations

import hashlib
import json
import re
import sqlite3
import time
import uuid
from pathlib import Path
from urllib.parse import urlsplit, parse_qs

YEAR = 365 * 86400
FAILURE_BACKOFF = 60
API_PATH = '/scraper/e0a033cc-4c08-49d5-8417-81682c9b3dbf/'
PREFIXES = {
    'get_team_schedule': ('school-schedule-v13-', 'opponent-streak-schedule-v13-'),
    'get_matchup': ('matchup-v1-',),
    'get_live_and_upcoming_games': ('game-day-confirm-v1-',),
    'get_scoretracker': ('tracker-', 'exact-url-v5-', 'exact-url-v6-'),
    'get_scoretracker_by_id': ('tracker-',),
}


def policy(url, headers):
    try:
        u = urlsplit(url)
        h = {str(k).lower(): str(v) for k, v in headers.items()}
        endpoint = u.path.removeprefix(API_PATH)
        if (u.scheme != 'https' or u.netloc != 'api.parse.bot' or
                not u.path.startswith(API_PATH) or endpoint not in PREFIXES or
                not h.get('x-api-key') or h.get('api-snapshot-version') != '18'):
            return None
        label = h.get('x-glance-refresh', '')
        if not label.startswith(PREFIXES[endpoint]):
            return None
        scoretracker = endpoint in ('get_scoretracker', 'get_scoretracker_by_id')
        m = re.search(r'-(300|600|900|1200|1800)-\d+$', label)
        phase = None
        if label.startswith('tracker-recovery-v1-'):
            phase = next((p for p in ('four-hour','five-hour','next-day') if label.endswith('-'+p)), None)
        elif label.startswith('tracker-final-'):
            phase = 'schedule-final'
        elif label.startswith('tracker-undated-'):
            phase = 'undated'
        return {'scoretracker': scoretracker, 'interval': int(m[1]) if m else 600, 'phase': phase}
    except (TypeError, ValueError):
        return None


def _key(url, params, headers, scoretracker):
    h = {str(k).lower(): str(v) for k, v in headers.items()}
    params = dict(params)
    # A shared MaxPreps contest UUID is stronger identity than display slugs,
    # query ordering, or the selected Scoretracker/Boxscore tab.
    try:
        game = urlsplit(str(params.get('game_url', '')))
        ids = parse_qs(game.query).get('c', [])
        if (game.scheme in ('https','http') and game.netloc.lower() in ('www.maxpreps.com','maxpreps.com')
                and '/game/' in game.path and len(ids) == 1):
            params['game_url'] = 'maxpreps-contest:' + str(uuid.UUID(ids[0]))
    except (TypeError, ValueError):
        pass
    if scoretracker:
        h.pop('x-glance-refresh', None)
    elif url.endswith('/get_team_schedule'):
        week = re.search(r'-week-(-?\d+)$', h.get('x-glance-refresh',''))
        if week:
            h['x-glance-refresh'] = 'hss-schedule-week-' + week[1]
    elif url.endswith('/get_matchup'):
        phase = 'final' if h.get('x-glance-refresh','').startswith('matchup-v1-final-') else 'pregame'
        h['x-glance-refresh'] = 'hss-matchup-' + phase
    raw = json.dumps(['GET', url, sorted(params.items()), sorted(h.items())], sort_keys=True)
    return hashlib.sha256(raw.encode()).hexdigest()


def _response(status, body, now, error=None):
    try:
        decoded = json.loads(body) if body else None
    except (TypeError, ValueError):
        decoded = None
    return {'status_code': status, 'body': body, 'json': decoded,
            'error': error, 'fetched_at': int(now)}


def _game(value):
    queue = [(value, 0)]
    for _ in range(200):
        if not queue:
            break
        node, depth = queue.pop(0)
        if depth > 6:
            continue
        if isinstance(node, dict):
            away = node.get('away_team', node.get('awayTeam', node.get('away')))
            home = node.get('home_team', node.get('homeTeam', node.get('home')))
            if isinstance(away, dict) and isinstance(home, dict):
                return node, away, home
            if 'awayScore' in node and 'homeScore' in node:
                return node, {'score': node['awayScore'], 'school_name': node.get('awayName')}, {'score': node['homeScore'], 'school_name': node.get('homeName')}
            for name in ('game', 'scoretracker', 'scoreTracker', 'liveGame', 'live_game',
                         'header', 'scoreboard', 'data', 'result', 'response', 'body', 'games', 'events'):
                if name in node:
                    queue.append((node[name], depth + 1))
        elif isinstance(node, list):
            queue.extend((item, depth + 1) for item in node[:20])
    return None


def _state_kind(response):
    found = _game(response.get('json'))
    if response.get('status_code') != 200 or not found:
        return None
    node, away, home = found
    names = [str(t.get('school_name', t.get('schoolName', t.get('name', '')))).strip() for t in (away, home)]
    scores = [str(t.get('score', '')) for t in (away, home)]
    if (not all(names) or any(n.upper() in ('HOME','AWAY','TBD','UNKNOWN') for n in names)
            or names[0].casefold() == names[1].casefold()):
        return None
    if not all(re.fullmatch(r'\d{1,3}', s) for s in scores):
        return None
    status = str(node.get('status', node.get('gameStatus', node.get('game_status', '')))).lower()
    if status == 'final':
        return 'final' if any(int(s) > 0 for s in scores) else None
    return 'live' if status in ('live', 'in progress', 'in_progress', 'delayed', 'suspended') else None


def _read_state(payload):
    state = json.loads(payload)
    if not isinstance(state, dict):
        raise ValueError('Invalid paid-request state')
    for name in ('pending_until', 'retry_after', 'last_attempt', 'final_at'):
        value = state.get(name)
        if value is not None and (isinstance(value, bool) or not isinstance(value, (int, float))):
            raise ValueError('Invalid paid-request timestamp')
    for name in ('audits', 'phases'):
        if name in state and (not isinstance(state[name], list) or not all(isinstance(v, str) for v in state[name])):
            raise ValueError('Invalid paid-request checkpoints')
    saved = state.get('response')
    if saved is not None and (not isinstance(saved, dict) or
            not isinstance(saved.get('fetched_at'), (int, float)) or
            not isinstance(saved.get('status_code'), int) or
            not isinstance(saved.get('body'), str)):
        raise ValueError('Invalid paid-request response')
    return state


def get(db_path, url, headers, params, ttl, fetcher, now=None, seed=None):
    """Reserve once before I/O; never retry an uncertain billable request.

    `fetcher` must itself make AT MOST ONE network attempt. All failures in
    reservation/storage fail closed rather than bypassing spending protection.
    """
    rule = policy(url, headers)
    if not rule:
        raise ValueError('Not an HSS paid request')
    now = time.time() if now is None else float(now)
    key = _key(url, params, headers, rule['scoretracker'])
    db = None
    saved = None
    lease = uuid.uuid4().hex
    try:
        path = Path(db_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        db = sqlite3.connect(path, timeout=0.5, isolation_level=None)
        db.execute('PRAGMA busy_timeout=500')
        db.execute('CREATE TABLE IF NOT EXISTS paid_requests (identity TEXT PRIMARY KEY, touched REAL NOT NULL, payload TEXT NOT NULL)')
        db.execute('CREATE INDEX IF NOT EXISTS paid_requests_touched ON paid_requests (touched)')
        db.execute('BEGIN IMMEDIATE')
        row = db.execute('SELECT payload FROM paid_requests WHERE identity=?', (key,)).fetchone()
        state = _read_state(row[0]) if row else {}
        saved = state.get('response')
        if saved and now - saved.get('fetched_at', 0) > YEAR:
            state, saved = {}, None
        if not saved and seed:
            saved = _response(seed[0], seed[1], now)
            state['response'] = saved
            state['slot'] = f"{rule['interval']}/{int(now // rule['interval'])}"
            if _state_kind(saved) == 'final':
                state['final_at'] = now
        audit = None
        if rule['scoretracker']:
            final_at = state.get('final_at')
            if final_at is not None:
                audit = next((str(delay) for delay in (1800, 3600)
                              if now >= final_at + delay and str(delay) not in state.get('audits', [])), None)
                if audit is None:
                    if not row:
                        db.execute('INSERT OR REPLACE INTO paid_requests VALUES (?, ?, ?)', (key, now, json.dumps(state)))
                    db.execute('COMMIT')
                    db.close()
                    return saved
            slot = f"{rule['interval']}/{int(now // rule['interval'])}"
            phase = rule['phase']
            waiting = state.get('slot') == slot or (audit is None and phase is not None and phase in state.get('phases', []))
            # Two installations may use the same key/game but different live
            # intervals. Alternating their slot labels must not force a paid
            # fetch on every render. The requested cadence also applies to the
            # last actual attempt, regardless of which installation made it.
            if audit is None and phase is None and state.get('last_attempt') is not None:
                waiting = waiting or now < state['last_attempt'] + rule['interval']
            # The four-hour checkpoint reads the most recent known score; it
            # need not spend a new credit just because the live window closed.
            if audit is None and phase == 'four-hour' and saved:
                waiting = True
        else:
            waiting = saved is not None and now - saved.get('fetched_at', 0) < max(0, min(int(ttl), YEAR))
        waiting = waiting or now < state.get('pending_until', 0) or now < state.get('retry_after', 0)
        if waiting:
            if not row and saved:
                db.execute('INSERT OR REPLACE INTO paid_requests VALUES (?, ?, ?)', (key, now, json.dumps(state)))
            db.execute('COMMIT')
            db.close()
            return saved or _response(0, '', now, 'Paid update already attempted or in progress')
        state.update(lease=lease, pending_until=now + FAILURE_BACKOFF, last_attempt=now)
        if rule['scoretracker']:
            state['slot'] = slot
            if rule['phase'] is not None:
                state['phases'] = list(dict.fromkeys(state.get('phases', []) + [rule['phase']]))
            if audit is not None:
                state['audits'] = state.get('audits', []) + [audit]
        # Reservation is durable BEFORE sending a potentially billable request.
        db.execute('INSERT OR REPLACE INTO paid_requests VALUES (?, ?, ?)', (key, now, json.dumps(state)))
        db.execute('COMMIT')
    except (OSError, sqlite3.Error, ValueError, TypeError):
        if db:
            db.close()
        return saved or _response(0, '', now, 'Paid-request cache unavailable; no paid request sent')

    try:
        raw = fetcher()
        response = _response(int(raw.status_code), raw.text[:2000000], now)
    except Exception as error:
        # A timeout may still have consumed a provider credit. The reservation
        # remains spent for this live bucket; do not rotate proxies and retry.
        response = _response(0, '', now, type(error).__name__)
    kind = _state_kind(response)
    success = 200 <= response['status_code'] < 300
    usable = success and (not rule['scoretracker'] or kind is not None)
    try:
        db.execute('BEGIN IMMEDIATE')
        row = db.execute('SELECT payload FROM paid_requests WHERE identity=?', (key,)).fetchone()
        current = _read_state(row[0]) if row else {}
        if current.get('lease') == lease:
            current['pending_until'] = 0
            current['retry_after'] = 0 if success else now + FAILURE_BACKOFF
            if usable:
                current['response'] = response
                if kind == 'final':
                    current.setdefault('final_at', now)
                elif kind == 'live':
                    # A provisional Final reverted: resume bounded live checks.
                    current.pop('final_at', None)
                    current.pop('audits', None)
            db.execute('UPDATE paid_requests SET touched=?, payload=? WHERE identity=?', (now, json.dumps(current), key))
        db.execute('DELETE FROM paid_requests WHERE touched < ?', (now - YEAR,))
        db.execute('COMMIT')
    except (sqlite3.Error, TypeError, ValueError):
        # Do not retry the fetch if persistence fails after sending it.
        pass
    finally:
        db.close()
    return response if usable or not saved else saved
