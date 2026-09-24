"""Dependency-free behavioral checks. MCP validates/renders the real Starlark.
Run: py -3.14 apps/bambu-print-status/tests/check_behavior.py
This harness executes the Python-compatible subset, adapting only type/elems.
"""
from pathlib import Path
from types import SimpleNamespace
import datetime
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
ns = {'type': lambda v: {dict:'dict', list:'list', str:'string', int:'int', float:'float', bool:'bool', type(None):'NoneType'}.get(type(v), type(v).__name__)}
exec(compile(ROOT.joinpath('app.star').read_text().replace('.elems()', ''), 'app.star', 'exec'), ns)

class Canvas:
    def __init__(self): self.texts=[]; self.bars=[]; self.rects=[]; self.images=[]
    def fill(self,*a,**kw): pass
    def rect(self,*a,**kw): self.rects.append((a,kw))
    def line(self,*a,**kw): pass
    def text_width(self,s,font): return len(s)*(6 if font=='5x7' else 5)
    def text(self,s,*a,**kw): self.texts.append(s)
    def progress_bar(self,*a,**kw): self.bars.append((a,kw))
    def image(self,name,*a,**kw): self.images.append(name)

def render(data, **inputs):
    settings = {'endpoint': 'https://example.invalid/status', 'readkey': 'test-only-key'}
    settings.update(inputs)
    ctx = SimpleNamespace(inputs=settings, now=SimpleNamespace(unix=1800000000))
    c=Canvas()
    with patch.dict(ns, http=SimpleNamespace(get=Mock(return_value={'status_code': 200, 'json': data}))):
        ns['main'](c,ctx)
    return c

class Behavior(unittest.TestCase):
    def test_live_configuration_and_transport(self):
        for settings, expected in [
            ({}, ['PRINTER STATUS', 'SETUP REQUIRED', 'ADD ENDPOINT + KEY']),
            ({'endpoint': 'https://example.invalid/status'}, ['PRINTER STATUS', 'SETUP REQUIRED', 'ADD ENDPOINT + KEY']),
            ({'readkey': 'test-only-key'}, ['PRINTER STATUS', 'SETUP REQUIRED', 'ADD ENDPOINT + KEY']),
            ({'endpoint': 'http://example.invalid/status', 'readkey': 'test-only-key'}, ['PRINTER STATUS', 'INVALID ENDPOINT', 'HTTPS REQUIRED']),
            ({'endpoint': 'nonsense', 'readkey': 'test-only-key'}, ['PRINTER STATUS', 'INVALID ENDPOINT', 'HTTPS REQUIRED']),
        ]:
            get = Mock(side_effect=AssertionError('Unexpected network request'))
            with patch.dict(ns, http=SimpleNamespace(get=get)):
                c=Canvas(); ns['main'](c, SimpleNamespace(inputs=settings, now=SimpleNamespace(unix=1800000000)))
            self.assertEqual(c.texts, expected)
            get.assert_not_called()
        settings = {'endpoint': 'https://example.invalid/status', 'readkey': 'test-only-key'}
        for status in [0, 401, 500, 200]:
            response = {'status_code': status}
            if status == 200:
                response['json'] = ns['demo']('BOTH IDLE')
            get = Mock(return_value=response)
            with patch.dict(ns, http=SimpleNamespace(get=get)):
                c=Canvas(); ns['main'](c, SimpleNamespace(inputs=settings, now=SimpleNamespace(unix=1800000000)))
            get.assert_called_once_with(settings['endpoint'], headers={'x-api-key': settings['readkey']}, ttl_seconds=300)
            if status != 200:
                self.assertEqual(c.texts, ['PRINTER STATUS', 'NO PRINTER DATA', 'CHECK CONNECTION'])
            else:
                self.assertIn('READY', c.texts)
            self.assertNotIn(settings['endpoint'], ' '.join(c.texts))
            self.assertNotIn(settings['readkey'], ' '.join(c.texts))

    def test_every_demo_without_settings_or_network(self):
        # Read the actual catalog choices so newly added demos are covered too.
        line = next(line for line in ROOT.joinpath('manifest.yaml').read_text().splitlines() if 'choices: [Live,' in line)
        scenarios = line.split('[', 1)[1].split(']', 1)[0].split(', ')[1:]
        get = Mock(side_effect=AssertionError('Demo requested network data'))
        with patch.dict(ns, http=SimpleNamespace(get=get)):
            for scenario in scenarios:
                for mode in ['Auto', 'AMS', 'AMS 2 Pro', 'AMS HT', 'Summary', 'Diagnostics']:
                    ctx = SimpleNamespace(inputs={'demo': scenario, 'viewmode': mode}, now=SimpleNamespace(unix=1800000000))
                    c=Canvas(); ns['main'](c,ctx)
                    self.assertNotIn('DEMO', c.texts)
                    self.assertNotIn('SETUP REQUIRED', c.texts)
        get.assert_not_called()

    def test_idle_hides_old_jobs_and_zero_totals(self):
        data=ns['demo']('IDLE ZERO'); c=render(data)
        self.assertIn('READY',c.texts)
        self.assertIn('p2s.png',c.images)
        self.assertIn('x2d.png',c.images)
        self.assertFalse(any('CAT' in s or '0 PRINT' in s for s in c.texts))
    def test_dual_problem_retains_other_print(self):
        for scenario in ['BOTH PRINTING','PAUSED + PRINTING','ERROR + PRINTING','OFFLINE + PRINTING']:
            c=render(ns['demo'](scenario))
            self.assertIn('p2s-wordmark.png',c.images); self.assertIn('x2d-wordmark.png',c.images)
            self.assertIn('p2s-mini.png',c.images); self.assertIn('x2d-mini.png',c.images)
            self.assertEqual(len(c.bars),2)
    def test_complete_is_full(self):
        c=render(ns['demo']('PRINT FINISHED'))
        self.assertEqual(c.bars[0][0][4],100)
        self.assertIn('10:18P',c.texts)
        self.assertIn('COMPLETE',c.texts)
    def test_expired_event_returns_to_print(self):
        d=ns['demo']('PRINT STARTED'); d['event']['expires_at']=1
        self.assertNotIn('NEW PRINT STARTED',render(d).texts)
        d['event']['expires_at']=9999999999
        self.assertIn('NEW PRINT STARTED',render(d).texts)
    def test_iso_offsets(self):
        for v in ['2026-09-21T23:42:00Z','2026-09-21T23:42:00-04:00','2026-09-21T23:42:00+05:30']:
            self.assertEqual(ns['iso_epoch'](v),int(datetime.datetime.fromisoformat(v).timestamp()))
    def test_stale_and_malformed(self):
        self.assertIn('DATA STALE',render({'stale':True}).texts)
        for data in [None,{},[],{'printers':[]},{'printers':[None]}]:
            self.assertIn('NO PRINTER DATA',render(data).texts)
    def test_privacy_allowlist(self):
        d=ns['demo']('DIAGNOSTICS')
        d['diagnostics'].update({'token':'SENSITIVE','ip':'SENSITIVE','email':'SENSITIVE','serial':'SENSITIVE'})
        self.assertNotIn('SENSITIVE',' '.join(render(d,viewmode='Diagnostics').texts))
    def test_ams_ht_and_active_color(self):
        c=render(ns['demo']('AMS INVENTORY'),viewmode='AMS')
        self.assertIn('HT1',c.texts)
        a=render(ns['demo']('P2S PRINTING')).bars[0][1]['color']
        b=render(ns['demo']('MULTICOLOR CHANGE')).bars[0][1]['color']
        self.assertNotEqual(a,b)

    def test_single_slot_ht_loaded_empty_and_missing(self):
        d=ns['demo']('AMS HT')
        c=render(d,viewmode='AMS HT')
        self.assertIn('PETG-CF',c.texts)
        self.assertIn('ACTIVE',c.texts)
        self.assertIn('ams-ht.png',c.images)
        self.assertFalse(any(s in c.texts for s in ['A1','A2','A3','A4','HT1','DY1']))
        self.assertIn('NOT LOADED',render(ns['demo']('AMS HT EMPTY'),viewmode='AMS HT').texts)
        self.assertEqual(c.images,render(ns['demo']('AMS HT EMPTY'),viewmode='AMS HT').images)
        self.assertIn('x2d-wordmark.png',c.images)
        self.assertIn('LOADED',render(ns['demo']('AMS HT LOADED'),viewmode='AMS HT').texts)
        for p in d['printers']: p['ams_slots']=None
        self.assertIn('NO HT DATA',render(d,viewmode='AMS HT').texts)

    def test_ams_pro_excludes_ht_and_preserves_material(self):
        d=ns['demo']('AMS HT')
        c=render(d,viewmode='AMS 2 Pro')
        self.assertTrue(all(s in c.texts for s in ['A1','A2','A3','A4']))
        self.assertIn('ams-2-pro.png',c.images)
        self.assertIn('ams-2-pro-wordmark.png',c.images)
        self.assertIn('p2s-wordmark.png',c.images)
        self.assertIn('ACTIVE A2 / PLA',c.texts)
        self.assertNotIn('PETG-CF',c.texts)

    def test_nozzle_tracks_progress_not_time(self):
        p=ns['demo']('P2S PRINTING')['printers'][0]
        a,b=Canvas(),Canvas()
        ns['single'](a,p); ns['single'](b,p)
        self.assertEqual(a.rects,b.rects)
        self.assertEqual(a.texts,b.texts)
        self.assertTrue(any('11:42 PM' in s for s in a.texts))
        p['progress']=99; c=Canvas(); ns['single'](c,p)
        self.assertNotEqual(a.rects,c.rects)
        self.assertTrue(all(44<=r[0][0]<=r[0][2]<=181 for r in c.rects))

    def test_summary_retains_totals(self):
        d=ns['demo']('BOTH IDLE')
        c=render(d,viewmode='Summary')
        self.assertIn('3 PRINTS',c.texts)
        self.assertIn('11H 24M',c.texts)
        self.assertIn('bambu-logo-large.png',c.images)
        self.assertIn('P2S / X2D',c.texts)
    def test_clock_and_color_unknowns(self):
        self.assertEqual(ns['clock']('2026-09-21T23:42:00-04:00'),'11:42 PM')
        self.assertEqual(ns['clock'](None),'')
        self.assertEqual(ns['safe_color']('bad'),'green')
        self.assertNotEqual(ns['safe_color']('#000000'),'#000000')
    def test_paused_beats_start_event(self):
        d=ns['demo']('PRINT STARTED'); d['printers'][1]['state']='PAUSED'
        c=render(d)
        self.assertNotIn('NEW PRINT STARTED',c.texts)
        self.assertEqual(len(c.bars),2)

if __name__=='__main__': unittest.main()
