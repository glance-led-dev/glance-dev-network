"""Current-season, exact-ID record reads across both shared ESPN sources."""
import copy
import html
import json
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from gdn.starhost.executor import run_star_app
from gdn.starhost.http_client import HttpHost
from bracketology_fixture import approved_projection


APP = Path(__file__).resolve().parents[1] / 'apps/ncaa-bracketology/app.star'
TABLE = {
    'groups': {'headers': {'total': {'i': 1, 'd': 'Overall Record'}},
               'groups': [{'standings': [{'team': {'id': '356'}, 'stats': ['0-0', '3-1']},
                                        {'team': {'id': '248'}, 'stats': ['0-0', '3-0']}]}]},
    'page': {'season': '2027', 'group': '50', 'sport': 'basketball', 'pageType': 'standings'},
}


def response(*, uk=False, status=200, table=TABLE, season='2026-27'):
    heading = 'Tables' if uk else 'Standings'
    return {'status_code': status, 'body': f'<title>Men&#x27;s College Basketball {heading}, '
            f'{season} NCAA Division I {heading} - ESPN</title><script>'
            + json.dumps(table, separators=(',', ':')) + '</script>'}


class BracketologyRecords(unittest.TestCase):
    def setUp(self):
        self.ns = {}
        exec(compile(APP.read_text().replace('.elems()', ''), str(APP), 'exec'), self.ns)
        self.ns.update(type=lambda v: 'string' if isinstance(v, str) else type(v).__name__,
                       json=SimpleNamespace(decode=json.loads))

    def sources(self, us, uk):
        self.calls = []
        mapping = dict(zip([self.ns['RESUME_RECORDS_URL'], self.ns['RESUME_RECORDS_BACKUP_URL']], [us, uk]))

        def get(url, **kwargs):
            self.assertEqual(kwargs['ttl_seconds'], 3600)
            self.calls.append(url)
            return mapping.get(url, {'status_code': 0})

        self.ns['http'] = SimpleNamespace(get=get)
        return self.ns['current_team_record']

    def test_primary_preferred_without_second_fetch(self):
        self.assertEqual(self.sources(response(), response(uk=True))('356'), {'RECORD': '3-1'})
        self.assertEqual(self.calls, [self.ns['RESUME_RECORDS_URL']])

    def test_rate_limit_incomplete_200_and_missing_team_recover_from_uk(self):
        partial = copy.deepcopy(TABLE)
        partial['groups']['groups'][0]['standings'].pop(0)
        for us in (response(status=403), {'status_code': 200, 'body': ''}, response(table=partial)):
            lookup = self.sources(us, response(uk=True))
            self.assertEqual(lookup('356'), {'RECORD': '3-1'})
            self.assertEqual(lookup('248'), {'RECORD': '3-0'})
            self.assertEqual(set(self.calls), {self.ns['RESUME_RECORDS_URL'], self.ns['RESUME_RECORDS_BACKUP_URL']})

    def test_wrong_season_wrong_column_and_unknown_school_do_not_invent_records(self):
        bad = copy.deepcopy(TABLE)
        bad['groups']['headers']['total']['d'] = 'Conference Record'
        self.assertEqual(self.sources(response(status=503), response(uk=True, table=bad))('356'), {})
        self.assertEqual(self.sources(response(status=503), response(uk=True, season='2025-26'))('356'), {})
        self.assertEqual(self.sources(response(), response(uk=True))('unknown'), {})

    def test_valid_published_records_are_authoritative_without_direct_standings_reads(self):
        lookup = self.sources(response(status=503), response(status=503))
        saved = {'356':'3-1', '248':'0-0', '7':'--'}
        self.assertEqual(lookup('356', saved), {'RECORD':'3-1'})
        self.assertEqual(lookup('248', saved), {'RECORD':'0-0'})
        self.assertEqual(self.calls, [])

    def test_missing_or_invalid_saved_record_can_still_recover_from_uk(self):
        for saved in [{'248':'3-0'}, {'356':'--'}, {}]:
            lookup = self.sources(response(status=503), response(uk=True))
            self.assertEqual(lookup('356',saved),{'RECORD':'3-1'})
            self.assertEqual(self.calls,[self.ns['RESUME_RECORDS_URL'],self.ns['RESUME_RECORDS_BACKUP_URL']])

    def test_actual_my_team_scene_reads_retained_records_without_live_espn(self):
        projection = approved_projection(self.ns)
        team_id = self.ns['RESUME_TEAM_IDS']['TEX']
        urls = []

        def get(host, url, **kwargs):
            urls.append(url)
            if url == self.ns['APPROVED_FEED_URL']:
                return {'status_code':200, 'body':'<tbody><tr><td>' +
                        html.escape(json.dumps(projection)) + '</td></tr></tbody>'}
            return {'status_code':503}

        def render(record, season='2026-27'):
            projection['team_records'] = {'season':season, 'teams':{team_id:record}}
            with patch.object(HttpHost, 'get', get):
                return run_star_app(APP.parent, {'view':'My Team', 'team':'Texas'}, only_page=2)['pages'][0]['ops']

        first = render('3-1')
        updated = render('4-1')
        # This page draws text as per-glyph bitmaps. Only the first digit
        # changes when the record advances, not the bracket or other stats.
        self.assertEqual(len(first), len(updated))
        changes = [(old, new) for old, new in zip(first, updated) if old != new]
        self.assertEqual(len(changes), 1)
        self.assertEqual(changes[0][0]['y'], 13)
        self.assertEqual(changes[0][1]['y'], 13)
        self.assertNotIn(self.ns['RESUME_RECORDS_URL'], urls)
        self.assertNotIn(self.ns['RESUME_RECORDS_BACKUP_URL'], urls)
        self.assertNotEqual(first, render('3-1', '2025-26'))
        self.assertIn(self.ns['RESUME_RECORDS_URL'], urls)
