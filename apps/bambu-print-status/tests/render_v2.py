"""Render every demo through the real Starlark host; write only app previews."""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1]))

import yaml
from PIL import Image, ImageDraw
from gdn.preview import write_previews
from gdn.scene import render_scene, validate_scene
from gdn.starhost import run_star_app_sandboxed


def main():
    manifest = yaml.safe_load((ROOT / 'manifest.yaml').read_text())
    scenarios = next(i['choices'] for i in manifest['inputs'] if i['key'] == 'demo')[1:]
    out = ROOT / 'preview' / 'scenarios'
    out.mkdir(parents=True, exist_ok=True)
    images = {}
    for scenario in scenarios:
        scene = run_star_app_sandboxed(ROOT, {'demo': scenario}, now='2026-09-23T20:00:00Z')
        validate_scene(scene, manifest=manifest, asset_dir=ROOT)
        canvas = render_scene(scene, asset_dir=ROOT)['main']
        assert canvas.img.size == (192, 32), scenario
        # Enforce Scroll's safe zone on actual rendered pixels.
        assert canvas.img.convert('RGB').crop((0, 0, 10, 32)).getbbox() is None, scenario
        assert canvas.img.convert('RGB').crop((182, 0, 192, 32)).getbbox() is None, scenario
        images[scenario] = canvas.img.convert('RGB')
        canvas.save_png(out / (scenario.lower().replace(' ', '-').replace('+', 'and') + '.png'))
    selected = ['SPLASH', 'BOTH IDLE', 'P2S PRINTING', 'X2D PRINTING', 'BOTH PRINTING',
                'AMS 2 PRO', 'AMS HT', 'AMS HT LOADED', 'AMS HT EMPTY', 'PRINT FINISHED', 'ERROR', 'DAILY SUMMARY']
    poster = Image.new('RGB', (768, len(selected)*152), '#101010')
    draw = ImageDraw.Draw(poster)
    for i, scenario in enumerate(selected):
        draw.text((12, i*152+4), scenario, fill='white')
        poster.paste(images[scenario].resize((768, 128), Image.Resampling.NEAREST), (0, i*152+20))
    poster.save(ROOT / 'preview' / 'branded-v2.png')
    write_previews(ROOT, inputs={'demo': 'P2S PRINTING', 'viewmode': 'Auto'}, now='2026-09-23T20:00:00Z')
    print(f'Rendered {len(scenarios)} demos; 192x32 bounds and Scroll safe zones passed. Previews updated.')


if __name__ == '__main__':
    main()
