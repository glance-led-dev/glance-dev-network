"""Fixture tests using the real GDN Starlark executor and scene renderer."""
import datetime
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from gdn.starhost.executor import run_star_app
from gdn.scene import render_scene

APP = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('prepare_local', APP / 'prepare_local.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class SleeperTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.catalog = {
            '1': {'full_name': 'A.J. Brown', 'position': 'WR', 'team': 'PHI'},
            '2': {'full_name': 'Brian Robinson Jr.', 'position': 'RB', 'team': 'WAS'},
            '3': {'full_name': 'Other Player', 'position': 'QB', 'team': 'BUF'},
            '4': {'full_name': 'Free Agent', 'position': 'RB', 'team': None},
        }
        self.rosters = [
            {'owner_id': 'owner', 'players': ['1'], 'reserve': ['2'], 'taxi': None},
            {'owner_id': None, 'players': ['3'], 'reserve': None, 'taxi': ['5']},
        ]
        self.titles = ['AJ Brown: Cleared for Sunday', 'Brian Robinson: Back at practice', 'Other Player: Ready to play']
        self.calls = []
        self.offline = False
        self.username = 'fixture'
        self.league_wire = True

    def run_app(self, inputs=None, catalog=None):
        with patch.object(setup, 'LOCAL', Path(self.temp.name)):
            target = setup.prepare(self.username, '123', self.league_wire, self.catalog if catalog is None else catalog)
        if getattr(self, 'expired', False):
            source = target / 'app.star'
            import re
            source.write_text(re.sub(r'LOCAL_PLAYERS_UNTIL = [0-9]+', 'LOCAL_PLAYERS_UNTIL = 1', source.read_text()))
        def request(url, headers=None, params=None, ttl_seconds=None):
            self.calls.append((url, ttl_seconds))
            unique = set(u for u, _ in self.calls)
            self.assertLessEqual(len(unique), 8, 'cold-cache budget across both pages')
            payload = None
            body = ''
            status = 200
            if 'rotowire' in url:
                body = '<rss>' + ''.join('<item><title>' + t + '</title><description>Update</description></item>' for t in self.titles) + '</rss>'
            elif '/user/' in url:
                payload = {'user_id': 'owner'}
            elif url.endswith('/rosters'):
                payload = self.rosters
                if self.offline:
                    status = 0
            elif '/trending/' in url:
                payload = [{'player_id': p, 'count': 100} for p in ['1', '2', '3', '5', '4', '6', '7', '8', '9', '10']]
            elif url.endswith('state/nfl'):
                payload = {'week': 2, 'season': '2026', 'season_type': 'regular'}
            elif '/research/' in url:
                payload = {}
            elif '/players/nfl/' in url:
                payload = {'first_name': 'Fallback', 'last_name': 'Player', 'position': 'QB', 'team': 'BUF'}
            elif 'espn' in url:
                payload = {'injuries': []}
            else:
                self.fail(url)
            return {'status_code': status, 'json': payload, 'body': body, 'error': None}
        with patch('gdn.starhost.executor.HttpHost.get', side_effect=request):
            scene = run_star_app(target, inputs or {}, now=datetime.datetime(2026, 9, 18, 12, tzinfo=datetime.timezone.utc))
            render_scene(scene, asset_dir=target)
        return json.dumps(scene)

    def test_matching_metadata_and_available_wire(self):
        text = self.run_app()
        self.assertIn('AVAILABLE IN LEAGUE', text)
        self.assertNotIn('OTHER PLAYER', text)
        self.assertTrue('BROWN' in text or 'ROBINSON' in text)
        self.assertIn('AGENT', text)
        self.assertIn(('https://api.sleeper.app/v1/user/fixture', 21600), self.calls)
        self.assertIn(('https://api.sleeper.app/v1/league/123/rosters', 600), self.calls)

    def test_scans_beyond_original_twelve_items(self):
        self.titles = ['Other Player: Update'] * 15 + ['AJ Brown: Cleared']
        self.assertIn('BROWN', self.run_app())

    def test_no_matches(self):
        self.titles = ['Other Player: Update']
        self.assertIn('ALL QUIET', self.run_app())

    def test_roster_outage_fails_closed(self):
        self.offline = True
        text = self.run_app()
        self.assertIn('ROSTERS UNAVAILABLE', text)
        self.assertNotIn('AVAILABLE IN LEAGUE', text)

    def test_invalid_rosters(self):
        self.rosters = [{'players': 'wrong'}]
        self.assertIn('INVALID ROSTER DATA', self.run_app())

    def test_missing_owner(self):
        self.rosters[0]['owner_id'] = 'someone-else'
        self.assertIn('NO OWNED ROSTER', self.run_app())

    def test_null_and_empty_roster(self):
        self.rosters[0].update(players=None, reserve=None)
        self.assertIn('ALL QUIET', self.run_app())

    def test_incomplete_catalog(self):
        del self.catalog['1']
        self.assertIn('PLAYER SNAPSHOT INCOMPLETE', self.run_app())

    def test_ambiguous_names_omitted(self):
        self.catalog['99'] = dict(self.catalog['1'])
        self.titles = ['AJ Brown: Cleared']
        self.assertIn('ALL QUIET', self.run_app())

    def test_expired_snapshot(self):
        self.expired = True
        self.assertIn('REFRESH PLAYER SNAPSHOT', self.run_app())

    def test_missing_players_field_fails_closed(self):
        self.rosters = [{'owner_id': 'owner'}]
        text = self.run_app()
        self.assertIn('INVALID ROSTER DATA', text)
        self.assertNotIn('AVAILABLE IN LEAGUE', text)

    def test_drops_still_filter_occupied(self):
        text = self.run_app({'wire': 'DROPS'})
        self.assertIn('AVAILABLE IN LEAGUE', text)
        self.assertIn('DROPS', text)
        self.assertTrue(any('/trending/drop' in u for u, _ in self.calls))

    def test_default_and_team_modes_budget(self):
        self.username = ''
        self.league_wire = False
        self.assertNotIn('AVAILABLE IN LEAGUE', self.run_app({'follow': 'ALL NFL', 'position': 'TE'}, {}))
        self.assertEqual(len(set(u for u, _ in self.calls)), 8)
        self.assertFalse(any('/rosters' in u or '/user/' in u for u, _ in self.calls))
        self.calls = []
        self.run_app({'follow': 'PHILADELPHIA EAGLES', 'position': 'TE'}, {})
        self.assertEqual(len(set(u for u, _ in self.calls)), 8)

    def test_personalized_position_filter_budget(self):
        self.run_app({'follow': 'MY SLEEPER TEAM', 'position': 'TE'})
        self.assertLessEqual(len(set(u for u, _ in self.calls)), 8)

    def test_sleeper_settings_override_local_defaults(self):
        self.run_app({'follow': 'MY SLEEPER TEAM', 'sleeperusername': 'different',
                      'sleeperleagueid': '456', 'leaguewire': True})
        self.assertIn(('https://api.sleeper.app/v1/user/different', 21600), self.calls)
        self.assertIn(('https://api.sleeper.app/v1/league/456/rosters', 600), self.calls)

    def test_league_wire_can_be_disabled_with_settings(self):
        self.league_wire = False
        text = self.run_app({'follow': 'ALL NFL', 'sleeperleagueid': '456', 'leaguewire': False})
        self.assertNotIn('AVAILABLE IN LEAGUE', text)
        self.assertFalse(any('/rosters' in url for url, _ in self.calls))

    def test_league_wire_rejects_invalid_league_id(self):
        text = self.run_app({'follow': 'ALL NFL', 'sleeperleagueid': 'wrong', 'leaguewire': True})
        self.assertIn('INVALID LEAGUE ID', text)
        self.assertFalse(any('/rosters' in url for url, _ in self.calls))


if __name__ == '__main__':
    unittest.main()
