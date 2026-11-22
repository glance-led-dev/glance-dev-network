"""Keep play-in metadata visible, measured, and on the panel."""
from pathlib import Path
import unittest

from gdn.canvas import Canvas

APP = Path(__file__).resolve().parents[1] / 'apps/ncaa-bracketology'


class Round32Layout(unittest.TestCase):
    def setUp(self):
        self.ns = {}
        exec(compile((APP / 'app.star').read_text().replace('.elems()', ''), 'app.star', 'exec'), self.ns)
        self.ns['type'] = lambda value: 'string' if isinstance(value, str) else type(value).__name__
        self.projection = {key: self.ns[key] for key in
                           ['TEAM_OVERALL_SEEDS', 'YOUR_TEAM_SAMPLE_SLOTS',
                            'OPENING_ROUND_AUTO', 'OPENING_ROUND_AT_LARGE']}

    def draw(self, pair, seed, single, record, reverse=False):
        ns = self.ns
        metrics = {'RECORD': record, 'NET': '365', '_season': '26-27'}
        ns['your_team_resume'] = lambda *a, **k: metrics.copy()
        self.projection['YOUR_TEAM_SAMPLE_SLOTS'] = {'TEST|' + str(seed): pair}
        # All scenarios exercise real logo widths, not square placeholders.
        c = Canvas(192, asset_dir=APP / 'assets')
        text, logos, lines = [], [], []
        original_text, original_mark = ns['your_team_text'], ns['your_team_mark']

        def capture_text(canvas, value, x, y, font='4x5', color='white', align='left'):
            lo, hi = ns['your_team_text_edges'](canvas, value, font, x, align)
            text.append((str(value), lo, hi, y, {'6x8': 8, '5x7': 7, '3x4': 4}.get(font, 5), color))
            return original_text(canvas, value, x, y, font, color, align)

        def capture_mark(canvas, code, x, y, w, h):
            logos.append((code, x + ns['SWEET_SINGLE_LEFT_INK'][code],
                          x + ns['SWEET_SINGLE_RIGHT_INK'][code]))
            return original_mark(canvas, code, x, y, w, h)

        original_line = c.line
        c.line = lambda x0, y0, x1, y1, **kw: (lines.append((x0, x1)), original_line(x0, y0, x1, y1, **kw))[-1]
        ns['your_team_text'], ns['your_team_mark'] = capture_text, capture_mark
        try:
            game = [seed, 'TBD', 6, single] if reverse else [6, single, seed, 'TBD']
            ns['your_team_round32_candidates'](self.projection, c, game, 'TEST')
        finally:
            ns['your_team_text'], ns['your_team_mark'] = original_text, original_mark
        return c, text, logos, lines

    def test_all_approved_pairs_keep_seed_record_net_and_overall_on_both_sides(self):
        pairs = list(self.projection['YOUR_TEAM_SAMPLE_SLOTS'].items())
        for key, pair in pairs:
            for record in ['--', '0-0', '9-2', '33-12']:
                for reverse in [False, True]:
                    with self.subTest(pair=pair, record=record, reverse=reverse):
                        c, text, logos, lines = self.draw(pair, int(key.split('|')[1]), 'MICH', record, reverse)
                        # The old fallback has no per-school OVR or NET labels.
                        self.assertEqual(sum(t[0] == 'OVR' for t in text), 2)
                        self.assertEqual(sum(t[0] == 'NET' for t in text), 3)
                        self.assertEqual(sum(t[0] == '365' for t in text), 3)
                        self.assertEqual(sum(t[0] == record for t in text), 3)
                        self.assertFalse(any(t[0] in pair for t in text))
                        for label, lo, hi, y, height, color in text:
                            self.assertGreaterEqual(lo, 0, label)
                            self.assertLess(hi, 191, label)
                            self.assertLessEqual(y + height, 32, label)
                        for _, lo, hi in logos:
                            self.assertGreaterEqual(lo, 0)
                            self.assertLess(hi, 191)
                        # Text on the same row needs at least one blank pixel.
                        for i, first in enumerate(text):
                            for second in text[i + 1:]:
                                if first[3] != second[3]:
                                    continue
                                self.assertTrue(first[2] + 1 < second[1] or second[2] + 1 < first[1],
                                                (first, second))

    def test_widest_native_logos_and_four_letter_single_do_not_drop_metadata(self):
        for single in ['WICH', 'NHVN', 'BAMA', 'MICH']:
            for seed in [1, 11, 16]:
                with self.subTest(single=single, seed=seed):
                    _, text, _, _ = self.draw(['SDSU', 'USU'], seed, single, '33-12')
                    self.assertEqual(sum(t[0] == 'OVR' for t in text), 2)
                    self.assertEqual(sum(t[0] == 'NET' for t in text), 3)

    def test_sor_requires_current_season_exact_team_and_valid_rank(self):
        prefix = '"seasonDisplayName":"2026-27" Men\'s College Basketball Power Index 2026-27 "table":'
        row = '"team":{"id":"356"},"stats":[{"name":"sorrank","value":"7"}]'
        self.assertEqual(self.ns['resume_sor'](prefix + row, '356'), {'SOR': '7'})
        for body, team in [(prefix + row, '251'), (row, '356'),
                           ((prefix + row).replace('2026-27', '2025-26'), '356'),
                           (prefix + row.replace('"7"', '"--"'), '356')]:
            self.assertEqual(self.ns['resume_sor'](body, team), {})

    def test_wab_does_not_use_last_seasons_table(self):
        body = '<figure>Through Games Apr. 06 2026</figure><table><tr><th>School</th><th>WAB</th></tr><tr><td>Illinois</td><td>8.41</td></tr></table>'
        self.assertEqual(self.ns['resume_wab'](body, 'ILL'), {})
        self.assertEqual(self.ns['resume_wab'](body.replace('Apr. 06 2026', 'Dec. 01 2026'), 'ILL')['WAB'], '8.41')


if __name__ == '__main__':
    unittest.main()
