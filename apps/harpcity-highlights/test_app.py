"""Behavior tests through the real GDN Starlark runtime; all responses are fixtures."""
import datetime
import copy
import json
from pathlib import Path
from unittest.mock import patch
from gdn.starhost import run_star_app
from gdn.scene import render_scene

APP = Path(__file__).parent
DATA = {
 'league/123': {'sport': 'nfl', 'season': '2026'},
 'league/123/users': [{'user_id': 'a', 'metadata': {'team_name': 'Harpcity Highlights'}}, {'user_id': 'b', 'display_name': 'Opponent'}],
 'league/123/rosters': [{'roster_id': 1, 'owner_id': 'a', 'settings': {'wins': 2, 'losses': 1, 'ties': 0, 'fpts': 365, 'fpts_decimal': 42}}, {'roster_id': 2, 'owner_id': 'b', 'settings': {'wins': 1, 'losses': 2}}],
 'state/nfl': {'season': '2026', 'season_type': 'regular', 'week': 1},
 'league/123/matchups/1': [{'roster_id': 1, 'matchup_id': 1, 'points': 104.72, 'custom_points': None}, {'roster_id': 2, 'matchup_id': 1, 'points': 98.36, 'custom_points': None}],
}
def run(data=None, inputs=None):
    data = DATA if data is None else data
    def get(host, url, **kw):
        key = url.removeprefix('https://api.sleeper.app/v1/')
        value = data.get(key)
        return {'status_code': 200 if value is not None else 503, 'json': value, 'body': '', 'error': None}
    with patch('gdn.starhost.executor.HttpHost.get', get):
        scene = run_star_app(APP, {'rosterid': 0, 'teamname': 'Harpcity Highlights', **(inputs or {'leagueid': '123'})}, now=datetime.datetime(2026,9,12,12,tzinfo=datetime.timezone.utc))
        render_scene(scene, asset_dir=APP)
    return json.dumps(scene)

assert '104.72' in run() and 'LEADING BY 6.36' in run()
d = copy.deepcopy(DATA); d['league/123/matchups/1'][0]['custom_points'] = 0
assert 'TRAILING BY 98.36' in run(d)
d = copy.deepcopy(DATA); d['league/123/matchups/1'][0]['points'] = 98.36
assert 'TIED AT 98.36' in run(d)
d = copy.deepcopy(DATA); d['league/123/matchups/1'][0]['matchup_id'] = None
assert 'NO HEAD-TO-HEAD MATCHUP' in run(d)
d = copy.deepcopy(DATA); del d['league/123/matchups/1']
assert 'MATCHUP DATA UNAVAILABLE' in run(d)
d = copy.deepcopy(DATA); d['league/123/users'][1]['metadata'] = {'team_name':'Harpcity Highlights'}
assert 'SET EXACT TEAM OR ROSTER ID' in run(d)
assert '104.72' in run(d, {'leagueid': '123', 'rosterid': 1})
d = copy.deepcopy(DATA); d['state/nfl']['season'] = '2027'
assert 'SELECT A WEEK IN SETTINGS' in run(d)
assert '104.72' in run(d, {'leagueid':'123', 'week':1})
assert 'SLEEPER UNAVAILABLE' in run({})
assert 'WEEK MUST BE 0 TO 18' in run(inputs={'leagueid':'123', 'week':19})
assert 'USE NUMERIC LEAGUE ID' in run(inputs={'leagueid':'bad/link'})
print('12 behavior cases passed in GDN renderer (fixture data).')
