"""Retained SOR/NCAA WAB, direct-source recovery, and actual host request limits."""
import copy
import html
import json
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from gdn.starhost.executor import run_star_app
from gdn.starhost import http_client
from bracketology_fixture import approved_projection

APP = Path(__file__).resolve().parents[1] / 'apps/ncaa-bracketology'
STAMP = 1795287600


def snapshot():
    return {'season':'2026-27',
            'SOR':{'source':'ESPN','teams':{'356':['7',STAMP], '251':['20',STAMP]}},
            'WAB':{'source':'NCAA','as_of':'2026-11-20',
                   'teams':{'ILLINOIS':['+1.00',STAMP], 'TEXAS':['0.69',STAMP]}}}


class ResumeFallback(unittest.TestCase):
    def setUp(self):
        self.ns = {}
        exec(compile((APP/'app.star').read_text().replace('.elems()', ''), 'app.star', 'exec'), self.ns)
        self.ns.update(type=lambda v: 'string' if isinstance(v,str) else type(v).__name__,
                       json=SimpleNamespace(decode=json.loads))
        self.calls = []

    def sources(self, response_map=None):
        def get(url, **kwargs):
            self.calls.append(url)
            return (response_map or {}).get(url, {'status_code':503,'body':''})
        self.ns['http']=SimpleNamespace(get=get)

    def test_saved_values_survive_every_metric_source_being_offline_without_extra_fetches(self):
        self.sources()
        data=self.ns['your_team_resume']('ILL',include_wab=True,saved_records={'356':'5-1'},saved_resume=snapshot())
        self.assertEqual({k:data[k] for k in ['SOR','WAB','RECORD']},{'SOR':'7','WAB':'+1.00','RECORD':'5-1'})
        self.assertNotIn(self.ns['RESUME_WAB_URL'],self.calls)
        for url in self.ns['RESUME_SOR_URLS']:self.assertNotIn(url,self.calls)

    def test_prior_season_wrong_provider_bad_timestamp_and_ambiguous_school_are_rejected(self):
        for change in ['season','provider','timestamp','ambiguous','date']:
            saved=snapshot()
            if change=='season':saved['season']='2025-26'
            elif change=='provider':saved['WAB']['source']='TORVIK'
            elif change=='timestamp':saved['WAB']['teams']['ILLINOIS'][1]=0
            elif change=='ambiguous':
                saved['WAB']['teams'].update({'CONNECTICUT':['1.00',STAMP],'UCONN':['2.00',STAMP]})
            else:saved['WAB']['as_of']='2026-02-30'
            team='CONN' if change=='ambiguous' else 'ILL'
            self.assertNotIn('WAB',self.ns['saved_team_resume'](saved,team),change)

    def test_valid_signed_zero_and_rank_limits(self):
        for value in ['0','0.00','-2.15','+3.40','-12.345']:
            self.assertTrue(self.ns['valid_resume_metric']('WAB',value),value)
        for value in ['', '--', 0, 'NaN', '1.2.3', '.2', '2.', '100.00','７']:
            self.assertFalse(self.ns['valid_resume_metric']('WAB',value),value)
        for value in ['1','365','400']:self.assertTrue(self.ns['valid_resume_metric']('SOR',value))
        for value in ['0','401','007','７','--']:self.assertFalse(self.ns['valid_resume_metric']('SOR',value))

    def test_incomplete_us_table_recovers_from_uk_when_no_saved_value_exists(self):
        heading='"seasonDisplayName":"2026-27" Men\'s College Basketball Power Index 2026-27 "table":'
        us,uk=self.ns['RESUME_SOR_URLS']
        self.sources({us:{'status_code':200,'body':heading},uk:{'status_code':200,'body':heading+
            '"team":{"id":"356"},"stats":[{"name":"sorrank","value":"7"}]'}})
        data=self.ns['your_team_resume']('ILL',include_wab=True,saved_records={},saved_resume=None)
        self.assertEqual(data['SOR'],'7')
        self.assertIn(us,self.calls);self.assertIn(uk,self.calls)

    def test_all_us_sor_failure_types_try_uk_before_giving_up(self):
        heading='"seasonDisplayName":"2026-27" Men\'s College Basketball Power Index 2026-27 "table":'
        row='"team":{"id":"356"},"stats":[{"name":"sorrank","value":"7"}]'
        us,uk=self.ns['RESUME_SOR_URLS']
        for failed in [{'status_code':503}, {'status_code':403}, {'status_code':0},
                       {'status_code':200,'body':''},
                       {'status_code':200,'body':(heading+row).replace('2026-27','2025-26')},
                       {'status_code':200,'body':heading+row.replace('"356"','"251"')},
                       {'status_code':200,'body':heading+row.replace('"7"','"--"')}]:
            self.calls.clear()
            self.sources({us:failed,uk:{'status_code':200,'body':heading+row}})
            metrics=self.ns['your_team_resume']('ILL',include_wab=True,saved_records={'356':'5-1'})
            self.assertEqual(metrics['SOR'],'7')
            self.assertEqual([url for url in self.calls if url in [us,uk]],[us,uk])

    def feed(self, saved):
        projection=approved_projection(self.ns)
        projection['team_records']={'season':'2026-27','teams':{v:'5-1' for v in self.ns['RESUME_TEAM_IDS'].values()}}
        if saved is not None:projection['team_resume']=saved
        return '<tbody><tr><td>'+html.escape(json.dumps(projection))+'</td></tr></tbody>'

    def render(self, saved, team='Texas', view='My Team', feed_available=True):
        feed=self.feed(saved)
        urls=[]
        def fetch(url,headers,params):
            urls.append(url)
            available=feed_available and url==self.ns['APPROVED_FEED_URL']
            return SimpleNamespace(status_code=200 if available else 503,
                                   text=feed if available else '')
        # Real HttpHost memoization and the unchanged 8-request limit; no cache writes.
        with patch.object(http_client,'_cache_read',return_value=None), \
             patch.object(http_client,'_cache_write'), \
             patch.object(http_client,'_fetch',side_effect=fetch):
            scene=run_star_app(APP,{'view':view,'team':team})
        return scene,urls

    def test_actual_starlark_scene_keeps_metrics_after_source_failure_and_updates_only_the_value(self):
        saved=snapshot()
        first,urls=self.render(saved)
        self.assertEqual(len(first['pages']),5)
        self.assertNotIn(self.ns['RESUME_WAB_URL'],urls)
        for url in self.ns['RESUME_SOR_URLS']:self.assertNotIn(url,urls)
        updated=copy.deepcopy(saved);updated['SOR']['teams']['251'][0]='21'
        second,_=self.render(updated)
        self.assertNotEqual(first['pages'][1]['ops'],second['pages'][1]['ops'])
        for index in [0,2,3,4]:self.assertEqual(first['pages'][index],second['pages'][index])

    def test_missing_snapshot_cold_render_stays_within_request_limit(self):
        for saved in [None,{'season':'2025-26'}, {'season':'2026-27'}]:
            scene,urls=self.render(saved)
            self.assertEqual(len(scene['pages']),5)
            self.assertLessEqual(len(urls),8)
            self.assertIn(self.ns['RESUME_SOR_URLS'][1],urls)

    def test_opening_round_opponent_uses_the_retained_values_too(self):
        saved=snapshot()
        saved['SOR']['teams']['150']=['1',STAMP]
        saved['WAB']['teams']['DUKE']=['2.00',STAMP]
        first,urls=self.render(saved,team='Queens')
        changed=copy.deepcopy(saved);changed['SOR']['teams']['150'][0]='2'
        second,_=self.render(changed,team='Queens')
        self.assertNotEqual(first['pages'][3]['ops'],second['pages'][3]['ops'])
        self.assertLessEqual(len(urls),8)

    def test_total_feed_and_metric_outage_is_graceful_and_within_real_request_limit(self):
        scene,urls=self.render(None,feed_available=False)
        self.assertEqual(len(scene['pages']),5)
        self.assertEqual(len(urls),8)

    def test_partial_saved_records_do_not_exceed_budget_when_both_espn_hosts_fail(self):
        missing=self.feed(None).replace(html.escape('"5-1"'),html.escape('"--"'))
        with patch.object(self,'feed',return_value=missing):
            scene,urls=self.render(None)
        self.assertEqual(len(scene['pages']),5)
        self.assertEqual(len(urls),8)
        self.assertTrue(any('espn.co.uk' in url and '/standings/' in url for url in urls))


if __name__=='__main__':unittest.main()
