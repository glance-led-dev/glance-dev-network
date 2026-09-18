"""Build an ignored, runnable Sleeper test copy; never edit source credentials."""
import argparse
import json
from pathlib import Path
import re
import shutil
import time
import requests

import yaml

APP = Path(__file__).resolve().parent
LOCAL = APP / '.gdn'


def prepare(username='', league_id='', league_wire=False, catalog=None):
    LOCAL.mkdir(exist_ok=True)
    cache = LOCAL / 'players.json'
    if catalog is None:
        if not cache.exists() or time.time() - cache.stat().st_mtime >= 86400:
            # Sleeper asks clients to fetch this large catalog at most daily.
            # This is a developer-side download, never a GLANCE render request.
            response = requests.get('https://api.sleeper.app/v1/players/nfl', timeout=60)
            response.raise_for_status()
            data = response.content
            parsed = json.loads(data)
            if not isinstance(parsed, dict) or not parsed:
                raise ValueError('Sleeper returned an empty or invalid player catalog')
            cache.write_bytes(data)
        catalog = json.loads(cache.read_text())
        until = int(cache.stat().st_mtime + 86400)
    else:
        until = int(time.time() + 86400)
    players = {}
    for pid, player in catalog.items():
        if not isinstance(player, dict):
            continue
        name = player.get('full_name') or ' '.join(filter(None, [player.get('first_name'), player.get('last_name')]))
        if not name:
            continue
        team = player.get('team') or ''
        team = {'WAS': 'WSH', 'JAC': 'JAX', 'LA': 'LAR'}.get(team, team)
        players[str(pid)] = {'name': name, 'position': player.get('position') or '', 'team': team}
    target = LOCAL / APP.name
    target.mkdir(exist_ok=True)
    shutil.copytree(APP / 'assets', target / 'assets', dirs_exist_ok=True)
    src = (APP / 'app.star').read_text()
    values = {'LOCAL_USERNAME': username, 'LOCAL_LEAGUE_ID': league_id,
              'LOCAL_PLAYERS': players, 'LOCAL_PLAYERS_UNTIL': until,
              'LOCAL_LEAGUE_WIRE': league_wire}
    for key, value in values.items():
        literal = repr(value) if isinstance(value, bool) else json.dumps(value, ensure_ascii=True)
        src = re.sub(r'^' + key + r' = .*$', lambda m: key + ' = ' + literal, src, flags=re.M)
    (target / 'app.star').write_text(src.replace('9x12', '8x12'))
    manifest = yaml.safe_load((APP / 'manifest.yaml').read_text())
    follow = next(i for i in manifest['inputs'] if i['key'] == 'follow')
    follow['choices'].insert(1, 'MY SLEEPER TEAM')
    if username and league_id:
        follow['default'] = 'MY SLEEPER TEAM'
    (target / 'manifest.yaml').write_text(yaml.safe_dump(manifest, sort_keys=False))
    return target


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--username', default='')
    parser.add_argument('--league-id', default='')
    parser.add_argument('--league-wire', action='store_true')
    args = parser.parse_args()
    if args.username and not re.fullmatch(r'[A-Za-z0-9_]+', args.username):
        parser.error('username must contain letters, digits or underscores')
    if args.league_id and not args.league_id.isdigit():
        parser.error('league ID must be numeric')
    if bool(args.username) != bool(args.league_id):
        parser.error('provide both username and league ID')
    if args.league_wire and not args.league_id:
        parser.error('--league-wire requires a league ID')
    print(prepare(args.username, args.league_id, args.league_wire))
