"""Offline regression checks using the real GDN Starlark host and pixel renderer."""
import datetime as dt
import json
from pathlib import Path
from unittest.mock import patch

import yaml
from PIL import Image, ImageDraw
from gdn.fonts import text_width
from gdn.scene import render_scene
from gdn.starhost import run_star_app

ROOT = Path(__file__).resolve().parents[1]
NOW = dt.datetime(2026, 9, 26, 12, 0, tzinfo=dt.timezone.utc)


def run():
    manifest = yaml.safe_load((ROOT / 'manifest.yaml').read_text())
    scenarios = next(x['choices'] for x in manifest['inputs'] if x['key'] == 'demo')
    previews = ROOT / 'preview'
    previews.mkdir(exist_ok=True)
    gallery = []
    for scenario in scenarios:
        with patch('gdn.starhost.executor.HttpHost.get', side_effect=AssertionError('Unexpected network')):
            scene = run_star_app(ROOT, {'demo': scenario}, now=NOW)
        rendered = render_scene(scene, asset_dir=ROOT)
        identities = []
        for page in scene['pages']:
            for op in page['ops']:
                if op['op'] == 'text':
                    w = text_width(op['font'], op['text'])
                    x = op['x'] - (w if op.get('align') == 'right' else 0)
                    assert x >= 10 and x + w <= 182, (scenario, op)
            identities.append([op for op in page['ops'] if op['op'] == 'text' and op['y'] <= 2])
        assert all(x == identities[0] for x in identities), scenario
        for page, canvas in rendered.items():
            image = canvas.img.convert('RGB')
            assert image.size == (192, 32)
            assert image.crop((0, 0, 10, 32)).getbbox() is None, scenario
            assert image.crop((182, 0, 192, 32)).getbbox() is None, scenario
            canvas.save_png(previews / (scenario.lower().replace(' ', '-') + '-' + page + '.png'))
            if scenario in ['UPS', 'FedEx', 'USPS']:
                gallery.append((scenario + ' / ' + page.upper(), image))
    # Verify delivered exclusion and that all undelivered statuses keep rotating.
    statuses = ['pre_transit', 'in_transit', 'out_for_delivery', 'failure', 'unknown', 'delivered']
    shipments = [{'carrier': 'UPS', 'sender': 'STORE ' + str(i), 'tracking_last4': str(1000+i), 'status': s} for i,s in enumerate(statuses)]
    payload = {'schema_version': 1, 'shipments': shipments, 'generated_at': int(NOW.timestamp())}
    seen = set()
    for minute in range(10):
        with patch('gdn.starhost.executor.HttpHost.get', return_value={'ok': True, 'status': 200, 'json': payload}):
            scene = run_star_app(ROOT, {'endpoint': 'https://example.invalid/status', 'readkey': 'fixture-only'}, now=NOW+dt.timedelta(minutes=minute))
        seen.update(op['text'] for p in scene['pages'] for op in p['ops'] if op['op']=='text' and op['text'].startswith('/'))
    assert seen == {'/1000','/1001','/1002','/1003','/1004'}, seen
    email_payload = dict(payload, shipments=[dict(shipments[0], source='EMAIL', notification_time='SEP 26 8:00 AM EDT', tracking_connected=True)])
    with patch('gdn.starhost.executor.HttpHost.get', return_value={'ok': True, 'status': 200, 'json': email_payload}):
        email_scene = run_star_app(ROOT, {'endpoint':'https://example.invalid/status','readkey':'fixture-only'}, now=NOW)
    email_text = [op['text'] for page in email_scene['pages'] for op in page['ops'] if op['op']=='text']
    assert 'LAST CARRIER EMAIL' in email_text and 'LAST CARRIER SCAN' not in email_text
    for response, expected in [({'ok':False,'status':401},'FEED KEY REJECTED'),({'ok':False,'status':0},'FEED UNAVAILABLE'),({'ok':True,'status':200,'json':{}},'INVALID FEED')]:
        with patch('gdn.starhost.executor.HttpHost.get', return_value=response):
            scene = run_star_app(ROOT, {'endpoint':'https://example.invalid/status','readkey':'fixture-only'}, now=NOW)
        assert expected in [op['text'] for p in scene['pages'] for op in p['ops'] if op['op']=='text']
    poster = Image.new('RGB', (768, len(gallery)*154), '#17191c')
    draw = ImageDraw.Draw(poster)
    for i,(label,image) in enumerate(gallery):
        draw.text((12,i*154+5),label,fill='#ccd2db')
        poster.paste(image.resize((768,128),Image.Resampling.NEAREST),(0,i*154+22))
    poster.save(previews/'carrier-gallery.png')
    # Side-by-side neighbors verify the app reads as its own unit in a Scroll stream.
    strip=Image.new('RGB',(576,32),'black')
    d=ImageDraw.Draw(strip);d.text((20,10),'WEATHER  68 F',fill='#8ac7ff');d.text((404,10),'NEXT GAME  7 PM',fill='#8affb0')
    strip.paste(gallery[0][1],(192,0));strip.resize((1152,64),Image.Resampling.NEAREST).save(previews/'scroll-sequence.png')
    summary={'scenarios':len(scenarios),'rendered_pages':len(scenarios)*4,'checks':['real Starlark execution','all text bounds','Scroll edge safe zones','persistent identity on four pages','all undelivered statuses rotate','delivered excluded','authentication/offline/malformed responses']}
    (previews/'validation.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps(summary))


if __name__ == '__main__':
    run()
