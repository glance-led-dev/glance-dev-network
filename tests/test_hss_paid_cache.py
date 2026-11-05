import concurrent.futures
from contextlib import closing
import json
import multiprocessing
import os
from pathlib import Path
import sqlite3
import sys
import tempfile
import threading
import time
from types import SimpleNamespace
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from gdn.starhost import paid_hss_cache as paid
from gdn.starhost import http_client as http

URL = 'https://api.parse.bot' + paid.API_PATH + 'get_scoretracker'
HEADERS = {'X-API-Key':'SYNTHETIC-NOT-A-REAL-KEY', 'API-Snapshot-Version':'18',
           'X-Glance-Refresh':'tracker-live-v18-synthetic-game-600-100'}
PARAMS = {'game_url':'https://www.maxpreps.com/nc/football/game/synthetic/10-23-2026/?c=synthetic'}


def payload(status='live', a=14, h=7):
    return {'data':{'game':{'status':status,
            'away_team':{'school_name':'Synthetic Away','score':a},
            'home_team':{'school_name':'Synthetic Home','score':h}}}}


def raw(value=None, status=200):
    return SimpleNamespace(status_code=status, text=json.dumps(value if value is not None else payload()))


def process_request(db, count, gate):
    gate.wait(5)
    def fetch():
        with count.get_lock():
            count.value += 1
        time.sleep(.08)
        return raw()
    paid.get(db, URL, HEADERS, PARAMS, paid.YEAR, fetch, now=60000)


class PaidCacheTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='hss-paid-cache-test-')
        self.db = Path(self.temp.name) / 'guard.sqlite3'
        self.calls = 0
        self.value = payload()

    def tearDown(self):
        self.temp.cleanup()

    def fetch(self):
        self.calls += 1
        return raw(self.value)

    def get(self, now=60000, headers=None, params=None, fetch=None, ttl=paid.YEAR, seed=None, url=URL):
        return paid.get(self.db, url, headers or HEADERS, params or PARAMS, ttl,
                        fetch or self.fetch, now=now, seed=seed)

    def test_repeated_renders_share_one_call_and_fetch_timestamp(self):
        for n in range(30):
            result=self.get(60000+n)
            self.assertEqual(result['json'], self.value)
            self.assertEqual(result['fetched_at'],60000)
        self.assertEqual(self.calls,1)

    def test_refresh_label_changes_do_not_bypass_same_paid_slot(self):
        self.get()
        self.get(headers={**HEADERS,'X-Glance-Refresh':'tracker-live-v18-other-label-600-999'})
        self.assertEqual(self.calls,1)

    def test_next_ten_minute_slot_fetches_once(self):
        self.get(60000)
        self.get(60599)
        self.get(60600)
        self.get(60601)
        self.assertEqual(self.calls,2)

    def test_mixed_live_settings_do_not_bypass_cadence(self):
        for now, interval in ((60000,600),(60001,1800),(60002,300),(60003,600),(60004,1800),(60299,300)):
            self.get(now, headers={**HEADERS, 'X-Glance-Refresh': f'tracker-live-v17-game-{interval}-{int(now//interval)}'})
        self.assertEqual(self.calls, 1)
        self.get(60300, headers={**HEADERS, 'X-Glance-Refresh':'tracker-live-v17-game-300-201'})
        self.assertEqual(self.calls, 2)
        self.get(60301, headers=HEADERS)
        self.assertEqual(self.calls, 2)

    def test_all_live_intervals(self):
        for interval in (300,600,900,1200,1800):
            with self.subTest(interval=interval):
                self.db=Path(self.temp.name)/f'{interval}.sqlite3'
                self.calls=0
                h={**HEADERS,'X-Glance-Refresh':f'tracker-live-v18-game-{interval}-0'}
                self.get(0,headers=h);self.get(interval-1,headers=h);self.get(interval,headers=h)
                self.assertEqual(self.calls,2)

    def test_different_games_do_not_share_scores(self):
        self.get()
        self.get(params={'game_url':PARAMS['game_url']+'-other'})
        self.assertEqual(self.calls,2)

    def test_same_contest_url_variants_share_one_paid_request(self):
        contest='4868e353-4529-4abb-80df-294b825441f9'
        for value in (f'https://www.maxpreps.com/nc/football/game/one/?c={contest}',
                      f'https://www.maxpreps.com/nc/football/game/two/?tab=box-score&c={contest.upper()}',
                      f'http://maxpreps.com/nc/football/game/one/?c={contest}&tab=scoretracker#details'):
            self.get(params={'game_url':value})
        self.assertEqual(self.calls,1)

    def test_four_hour_and_later_recovery_phases_do_not_resume_recurring_polls(self):
        self.get()
        for phase,now in (('four-hour',74400),('five-hour',78000),('next-day',117600)):
            headers={**HEADERS,'X-Glance-Refresh':'tracker-recovery-v1-synthetic-game-'+phase}
            for offset in range(0,3600,300):self.get(now+offset,headers=headers)
        self.assertEqual(self.calls,3) # initial live + five-hour + next-day

    def test_different_api_keys_are_isolated(self):
        self.get()
        self.get(headers={**HEADERS,'X-API-Key':'SYNTHETIC-SECOND-ACCOUNT'})
        self.assertEqual(self.calls,2)

    def test_api_snapshot_isolation_in_hash(self):
        self.assertNotEqual(paid._key(URL,PARAMS,HEADERS,True),paid._key(URL,PARAMS,{**HEADERS,'API-Snapshot-Version':'19'},True))

    def test_concurrent_threads_reserve_before_fetch(self):
        gate=threading.Barrier(12)
        lock=threading.Lock()
        def fetch():
            with lock:self.calls+=1
            time.sleep(.06)
            return raw()
        def run(_):
            gate.wait()
            return self.get(fetch=fetch)
        with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
            list(pool.map(run,range(12)))
        self.assertEqual(self.calls,1)
        self.assertEqual(self.get()['json'],self.value)

    def test_concurrent_sandbox_processes_reserve_one_call(self):
        context=multiprocessing.get_context('fork')
        count=context.Value('i',0);gate=context.Event()
        processes=[context.Process(target=process_request,args=(self.db,count,gate)) for _ in range(8)]
        for process in processes:process.start()
        gate.set()
        for process in processes:
            process.join(8)
            self.assertEqual(process.exitcode,0)
        self.assertEqual(count.value,1)

    def test_final_survives_new_buckets_with_only_two_correction_checks(self):
        self.value=payload('final',28,21)
        for now in range(60000,60000+3*86400,300):
            result=self.get(now)
            self.assertEqual(result['json'],self.value)
        self.assertEqual(self.calls,3) # initial Final, +30m, +60m

    def test_both_correction_audits_can_update_quarter_scores(self):
        self.value=payload('final',28,21);self.get()
        self.value['data']['game']['away_team']['quarters']=[7,7,7,7]
        self.get(61800)
        self.value['data']['game']['home_team']['quarters']=[0,7,7,7]
        result=self.get(63600)
        self.assertEqual(result['json'],self.value)
        self.assertEqual(self.calls,3)

    def test_unusable_correction_does_not_erase_final(self):
        self.value=payload('final');original=self.get()
        self.value={'data':None}
        self.assertEqual(self.get(61800)['json'],original['json'])
        self.assertEqual(self.get(63600)['json'],original['json'])
        self.get(65000)
        self.assertEqual(self.calls,3)

    def test_timed_out_correction_is_not_retried(self):
        self.value=payload('final');original=self.get()
        def timeout():
            self.calls+=1
            raise TimeoutError()
        self.assertEqual(self.get(61800,fetch=timeout)['json'],original['json'])
        self.get(61801,fetch=timeout)
        self.assertEqual(self.calls,2)

    def test_provisional_final_reverting_to_live_resumes_checks(self):
        self.value=payload('final');self.get()
        self.value=payload('live');self.get(61800);self.get(62400)
        self.assertEqual(self.calls,3)

    def test_empty_final_is_never_frozen(self):
        self.value=payload('final',0,0)
        self.get();self.get(60600)
        self.assertEqual(self.calls,2)

    def test_final_without_scores_or_real_names_is_not_frozen(self):
        values=[payload('final'),payload('final')]
        values[0]['data']['game']['away_team'].pop('score')
        values[1]['data']['game']['away_team']['school_name']=''
        for i,value in enumerate(values):
            self.db=Path(self.temp.name)/f'invalid-{i}.sqlite3';self.calls=0;self.value=value
            self.get();self.get(60600)
            self.assertEqual(self.calls,2)

    def test_wrapper_and_camel_case_final(self):
        value={'response':{'result':{'gameStatus':'final','awayTeam':{'schoolName':'Synthetic Away','score':14},'homeTeam':{'schoolName':'Synthetic Home','score':7}}}}
        self.assertEqual(paid._state_kind({'status_code':200,'json':value}),'final')

    def test_placeholder_names_do_not_freeze_a_final(self):
        value=payload('final');value['data']['game']['home_team']['school_name']='TBD'
        self.assertIsNone(paid._state_kind({'status_code':200,'json':value}))

    def test_transport_timeout_spends_slot_without_retry(self):
        def timeout():
            self.calls+=1
            raise TimeoutError()
        for now in (60000,60001,60061,60599):self.get(now,fetch=timeout)
        self.assertEqual(self.calls,1)
        self.get(60600,fetch=timeout)
        self.assertEqual(self.calls,2)

    def test_timeout_reuses_last_good_score(self):
        original=self.get()
        def timeout():raise TimeoutError()
        result=self.get(60600,fetch=timeout)
        self.assertEqual(result['json'],original['json'])
        self.assertEqual(result['fetched_at'],60000)

    def test_auth_and_credit_errors_do_not_burst_retry(self):
        for status in (401,402,403,429,500):
            self.db=Path(self.temp.name)/f'error-{status}.sqlite3';self.calls=0
            def fail():
                self.calls+=1
                return raw({'error':'synthetic'},status)
            for now in (60000,60001,60061):self.get(now,fetch=fail)
            self.assertEqual(self.calls,1)

    def test_unavailable_cache_fails_closed_without_paid_fetch(self):
        self.db=Path('/dev/null/guard.sqlite3')
        self.assertEqual(self.get()['status_code'],0)
        self.assertEqual(self.calls,0)

    def test_corrupt_state_fails_closed(self):
        self.get()
        with closing(sqlite3.connect(self.db)) as db:
            db.execute('UPDATE paid_requests SET payload=?',('not-json',));db.commit()
        self.assertEqual(self.get()['status_code'],0)
        self.assertEqual(self.calls,1)

    def test_valid_json_but_invalid_state_fails_closed(self):
        self.get()
        for invalid in ([], None, 'text', {'pending_until':'bad'}, {'response':[]}, {'phases':4}):
            with self.subTest(state=invalid):
                with closing(sqlite3.connect(self.db)) as db:
                    db.execute('UPDATE paid_requests SET payload=?', (json.dumps(invalid),));db.commit()
                self.assertEqual(self.get()['status_code'], 0)
                self.assertEqual(self.calls, 1)

    def test_metadata_shared_for_original_ttl(self):
        url='https://api.parse.bot'+paid.API_PATH+'get_team_schedule'
        h={**HEADERS,'X-Glance-Refresh':'school-schedule-v13-synthetic-week-1'}
        for n in range(20):self.get(60000+n,url=url,headers=h)
        self.assertEqual(self.calls,1)
        self.get(60000+paid.YEAR+1,url=url,headers=h)
        self.assertEqual(self.calls,2)

    def test_metadata_new_week_gets_fresh_request(self):
        url='https://api.parse.bot'+paid.API_PATH+'get_team_schedule'
        for week in (1,1,2,2):self.get(url=url,headers={**HEADERS,'X-Glance-Refresh':f'school-schedule-v13-synthetic-week-{week}'})
        self.assertEqual(self.calls,2)

    def test_team_schedule_shared_between_tracked_school_and_opponent_streak(self):
        url='https://api.parse.bot'+paid.API_PATH+'get_team_schedule'
        for slot in ('school','opponent-streak'):
            self.get(url=url,headers={**HEADERS,'X-Glance-Refresh':f'{slot}-schedule-v13-synthetic-week-1'})
        self.assertEqual(self.calls,1)

    def test_matchup_pregame_and_final_remain_separate(self):
        url='https://api.parse.bot'+paid.API_PATH+'get_matchup'
        for phase in ('pregame','pregame','final','final'):
            self.get(url=url,headers={**HEADERS,'X-Glance-Refresh':f'matchup-v1-{phase}-synthetic'})
        self.assertEqual(self.calls,2)

    def test_existing_http_cache_can_seed_final_without_new_paid_call(self):
        body=json.dumps(payload('final'))
        self.assertEqual(self.get(seed=(200,body))['json'],payload('final'))
        self.assertEqual(self.calls,0)
        self.get(61800)
        self.assertEqual(self.calls,1)

    def test_no_key_or_raw_url_is_persisted(self):
        self.get()
        with closing(sqlite3.connect(self.db)) as db:records=str(db.execute('SELECT * FROM paid_requests').fetchall())
        self.assertNotIn(HEADERS['X-API-Key'],records)
        self.assertNotIn(PARAMS['game_url'],records)
        self.assertNotIn('X-API-Key',records)

    def test_policy_exact_host_endpoint_snapshot_and_labels(self):
        self.assertIsNotNone(paid.policy(URL,HEADERS))
        for u in (URL.replace('api.parse.bot','api.parse.bot.evil.example'),URL.replace('https:','http:'),URL+'/extra',URL.replace('get_scoretracker','other_endpoint')):
            self.assertIsNone(paid.policy(u,HEADERS))
        for changes in ({'X-API-Key':''},{'API-Snapshot-Version':'19'},{'X-Glance-Refresh':'unrelated-app'}):
            self.assertIsNone(paid.policy(URL,{**HEADERS,**changes}))

    def test_paid_fetch_uses_one_proxy_attempt_and_no_redirects(self):
        import requests
        with patch.object(http,'_load_proxies',return_value=['http://one.example:80','http://two.example:80']),patch.object(http.requests,'get',side_effect=requests.Timeout('synthetic')) as get:
            with self.assertRaises(requests.Timeout):http._fetch(URL,HEADERS,PARAMS,paid=True)
            self.assertEqual(get.call_count,1)
            self.assertEqual(get.call_args.kwargs['timeout'],12)
            self.assertFalse(get.call_args.kwargs['allow_redirects'])

    def test_unrelated_http_keeps_existing_retry_behavior(self):
        import requests
        with patch.object(http,'_load_proxies',return_value=['http://one.example:80','http://two.example:80']),patch.object(http.requests,'get',side_effect=requests.Timeout('synthetic')) as get:
            with self.assertRaises(requests.Timeout):http._fetch('https://example.com/data',{}, {})
            self.assertEqual(get.call_count,2)
            self.assertEqual(get.call_args.kwargs['timeout'],http.REQUEST_TIMEOUT)

    def test_http_host_uses_guard_across_fresh_render_instances(self):
        with patch.object(http,'CACHE_DIR',Path(self.temp.name)),patch.object(http,'_fetch',return_value=raw()) as fetch:
            for n in range(12):http.HttpHost().get(URL,headers=HEADERS,params=PARAMS,ttl_seconds=paid.YEAR)
            self.assertEqual(fetch.call_count,1)
            self.assertTrue(fetch.call_args.kwargs['paid'])

    def test_offline_mode_never_touches_paid_guard_or_network(self):
        with patch.dict(os.environ,{'GDN_HTTP_OFFLINE':'1'}),patch.object(paid,'get') as guard,patch.object(http,'_fetch') as fetch:
            self.assertEqual(http.HttpHost().get(URL,headers=HEADERS,params=PARAMS)['status_code'],0)
            guard.assert_not_called();fetch.assert_not_called()


if __name__=='__main__':unittest.main(verbosity=2)
