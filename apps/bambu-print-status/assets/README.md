# Local artwork

GDN draws these PNGs with the documented `c.image(name, x, y)` API. All 13
runtime files are declared in `manifest.yaml`, read locally, and pre-sized for
the 192x32 panel. GDN's scene validator requires PNG, at most 128 KiB per asset,
and dimensions no larger than 384x64. No image URL is fetched at runtime.
`c.bitmap(rows, x, y, color)` is also supported but unnecessary here.

| Files | Native size | Use |
| --- | --- | --- |
| `bambu-symbol.png` | 11x15 | Small status identity |
| `bambu-logo.png` | 55x16 | Compact lockup with pixel-snapped symbol |
| `bambu-logo-large.png` | 77x23 | Splash and summary, native resolution |
| `p2s.png`, `x2d.png` | 25x30, 29x30 | Single printer and idle |
| `p2s-mini.png`, `x2d-mini.png` | 12x15, 14x15 | Simultaneous printer rows |
| `p2s-wordmark.png`, `x2d-wordmark.png` | 25x7 | Model identity |
| `ams-2-pro.png` | 46x30 | Four-spool enclosure |
| `ams-ht.png` | 28x30 | Same single-spool hardware in every HT state |
| `ams-2-pro-wordmark.png` | 69x7 | AMS 2 Pro identity |
| `ams-ht-wordmark.png` | 47x7 | AMS HT identity |

The printer and loaded AMS artwork was generated with built-in imagegen using
the official product photos below as references, then cropped, downsampled,
contrast-adjusted and palette-reduced by `../tests/build_assets.py`. It is an
illustrative pixel adaptation, not an official product render. X2D has a wider
body, side vent and distinct toolhead. AMS HT has exactly one spool; AMS 2 Pro
has four. HT uses the same hardware silhouette for active, loaded and empty
states; state text and the material swatch convey availability. Model wordmarks are custom wide geometric pixel adaptations of the
product-plate typography, not text rendered using a stock GDN font.

The symbol is pixel-snapped from the four polygons in Bambu Studio's
[official splash SVG](https://github.com/bambulab/BambuStudio/blob/master/resources/images/splash_logo.svg).
The symbol-plus-wordmark assets recolor and reduce
[BambuLab logo.svg by Lwde](https://commons.wikimedia.org/wiki/File:BambuLab_logo.svg),
licensed [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
The two derived `bambu-logo*.png` assets are provided under that same license.
Their silhouettes are retained; the symbol is green and lettering white for
black-background LED legibility.

Official product references retained in `references/`:

- [P2S launch](https://blog.bambulab.com/the-icon-redefined-meet-the-p2s-a-completely-reengineered-version-of-the-ultra-productive-p1-series/): `p2s.jpg`, `ams2.jpg`.
- [X2D launch](https://blog.bambulab.com/xcellence-made-simple-bambu-lab-presents-the-x2d/): `x2d.jpg`.
- [AMS HT product image](https://store.bblcdn.com/s7/default/b71037a1b7d24706bfe10638ad85c01a/AMS_HT-compressed.jpg): `ht.jpg`.
- `device-atlas.png`: generated source atlas, retained for offline reproduction.
- `bambu-logo.svg`, `logo-lockup.png`: source logo artwork.

Reference originals are not declared runtime assets. Product imagery and brand
marks identify the respective Bambu Lab devices; no endorsement is implied.

## Device-atlas generation prompt

Built-in imagegen; four official product photos supplied in the above order.
Production pixel-art atlas on black, four separate devices left-to-right:
P2S without AMS, X2D without AMS, standalone AMS 2 Pro, standalone single AMS HT.
Front views with subtle right side edges, intended for 30-pixel height, bright
gray highlights on charcoal bodies. Preserve protruding upper-left touchscreens,
glass doors, toolheads, build plates and door handles. Distinguish X2D's wider
top beam and side vent. Show four spools under AMS 2 Pro's curved cover, with
four feeders below. Show one spool under AMS HT's tall rounded cover, a dark
rectangular lower body and small illuminated front display. No text, labels,
scene, external shadow, generic nested rectangles or four-slot HT. Neutral
gray palette and sparse green display pixels. Result cropped and converted
deterministically to the native sizes above.

## Animation

Final HT refinement source: `references/ams-ht-angled.png`, generated from
`ams-ht-wide.png` with built-in imagegen. Prompt: preserve the dark rectangular
base, tall translucent dome, one spool and front display; make the device
slightly narrower with a subtle three-quarter view and visible right side.
Keep bright silver highlights and a black background, no labels, optimized
for 28x30 pixels. The build script performs the final offline conversion.

`glance://reference/authoring` states that frames are still images and refresh
on the manifest timer. There is no supported local animation clock between
network refreshes. The nozzle marker encodes current progress and is time-invariant.
