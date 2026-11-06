"""Regression checks for the approved font profile and ESPN request headers."""
from pathlib import Path
from types import SimpleNamespace
import unittest

APP = Path(__file__).resolve().parents[1] / 'apps/ncaa-bracketology'


class BracketologyCompatibility(unittest.TestCase):
    def setUp(self):
        self.ns = {}
        exec(compile((APP / 'app.star').read_text().replace('.elems()', ''), 'app.star', 'exec'), self.ns)

    def test_old_host_uses_the_approved_bitmap_shapes_and_advances(self):
        for font in self.ns['APPROVED_FONT_GLYPHS']:
            calls = []
            c = SimpleNamespace(text_width=lambda *a: 15,
                                bitmap=lambda rows,x,y,**kw:calls.append((rows,x,y)),
                                text=lambda *a,**kw:self.fail('Old-host text must use pinned glyphs'))
            self.ns['app_text'](c, 'MIW', 10, 2, font, 'white')
            glyphs = self.ns['APPROVED_FONT_GLYPHS'][font]
            self.assertEqual([a[0] for a in calls], [glyphs[ch] for ch in 'MIW'])
            self.assertEqual(calls[1][1], 10 + len(glyphs['M'][0]) + 1)
            self.assertEqual(calls[2][1], calls[1][1] + len(glyphs['I'][0]) + 1)

    def test_espn_reads_keep_browser_headers_and_hourly_cache(self):
        calls = []
        self.ns['http'] = SimpleNamespace(get=lambda url,**kw:(calls.append((url,kw)) or {'status_code':503,'body':''}))
        self.ns['your_team_resume']('ILL', include_wab=True)
        espn = [kw for url,kw in calls if 'www.espn.com/' in url]
        self.assertEqual(len(espn), 2)
        for kw in espn:
            self.assertEqual(kw['headers']['User-Agent'], 'Mozilla/5.0')
            self.assertEqual(kw['ttl_seconds'], 3600)
