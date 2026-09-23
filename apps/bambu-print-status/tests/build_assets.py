"""Offline conversion of reference artwork to native-resolution GDN PNG assets.

Device atlas: imagegen, guided by official product references (see assets/README.md).
No network access. Final assets are pre-sized, so GDN does not resample them.
"""
from pathlib import Path
import sys
from PIL import Image, ImageDraw, ImageEnhance, ImageOps

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets'
REF = OUT / 'references'


def device(atlas, box, name, size, stretch = False):
    im = atlas.crop(box).convert('RGB')
    mask = im.convert('L').point(lambda p: 255 if p > 25 else 0)
    im = im.crop(mask.getbbox())
    im = im.resize(size, Image.Resampling.LANCZOS) if stretch else ImageOps.contain(im, size, Image.Resampling.LANCZOS)
    im = ImageEnhance.Brightness(im).enhance(1.45)
    # Keep the black silhouette clean and lift body details for LED contrast.
    im = im.point(lambda p: 0 if p < 13 else min(255, (p//16)*16))
    canvas = Image.new('RGB', size)
    canvas.paste(im, ((size[0]-im.width)//2, size[1]-im.height))
    canvas.save(OUT / name)


# Wide, low geometric letterforms adapted to the product plate references.
# These are dedicated wordmark artwork, never a GDN/default font rendering.
GLYPHS = {
    'P': ['1111110','0000011','0000011','1111110','1100000','1100000','1100000'],
    '2': ['1111110','0000011','0000011','0111110','1100000','1100000','1111111'],
    'S': ['0111111','1100000','1100000','0111110','0000011','0000011','1111110'],
    'X': ['1100011','0110110','0011100','0001000','0011100','0110110','1100011'],
    'D': ['1111100','0000110','0000011','1100011','1100011','1100110','1111100'],
    'A': ['0011100','0110110','1100011','1100011','1111111','1100011','1100011'],
    'M': ['1100011','1110111','1111111','1101011','1100011','1100011','1100011'],
    'H': ['1100011','1100011','1100011','1111111','1100011','1100011','1100011'],
    'T': ['1111111','1111111','0011000','0011000','0011000','0011000','0011000'],
    'R': ['1111110','0000011','0000011','1111110','1101100','1100110','1100011'],
    'O': ['0111110','1100011','1100011','1100011','1100011','1100011','0111110'],
}


def wordmark(text, name):
    w = sum(4 if ch == ' ' else 9 for ch in text)-2
    im = Image.new('RGB', (w, 7))
    d = ImageDraw.Draw(im)
    x = 0
    for ch in text:
        if ch == ' ': x += 4; continue
        for y, row in enumerate(GLYPHS[ch]):
            for dx, bit in enumerate(row):
                if bit == '1': d.point((x+dx,y), fill='white')
        x += 9
    im.save(OUT / name)


def main():
    atlas = Image.open(REF / 'device-atlas.png')
    # Atlas is 1774x887; these crops isolate the four generated devices.
    for name, box, size in [
        ('p2s.png',(30,190,415,710),(25,30)),
        ('x2d.png',(440,190,935,710),(29,30)),
        ('p2s-mini.png',(30,190,415,710),(12,15)),
        ('x2d-mini.png',(440,190,935,710),(14,15)),
        ('ams-2-pro.png',(945,350,1460,710),(46,30)),
    ]:
        device(atlas, box, name, size)

    build_ht()

    logo = Image.open(REF/'logo-lockup.png').convert('RGBA')
    alpha = logo.getchannel('A')
    alpha = alpha.crop(alpha.getbbox())
    # Recolor the source's actual outlines; no substituted typeface.
    for name, size in [('bambu-logo.png',(55,16)), ('bambu-logo-large.png',(77,23))]:
        a = alpha.resize(size, Image.Resampling.LANCZOS).point(lambda p: 255 if p>=90 else 0)
        im = Image.new('RGB',size)
        white = Image.new('RGB',size,'white')
        im.paste(white,(0,0),a)
        d=ImageDraw.Draw(im)
        for y in range(size[1]):
            for x in range(round(size[0]*0.225)):
                if a.getpixel((x,y)): d.point((x,y),fill='#00AE42')
        im.save(OUT/name)
    out=Image.new('RGB',(11,15)); d=ImageDraw.Draw(out)
    # Pixel-snapped version of the four polygons in official splash_logo.svg.
    for polygon in [[(0,0),(4,0),(4,6),(0,8)],[(0,10),(4,8),(4,14),(0,14)],
                    [(6,0),(10,0),(10,6),(6,4)],[(6,6),(10,8),(10,14),(6,14)]]:
        d.polygon(polygon,fill='#00AE42')
    out.save(OUT/'bambu-symbol.png')
    repair_compact_logo()
    for text,name in [('P2S','p2s-wordmark.png'),('X2D','x2d-wordmark.png'),
                      ('AMS 2 PRO','ams-2-pro-wordmark.png'),('AMS HT','ams-ht-wordmark.png')]:
        wordmark(text,name)
    print('Built 13 local PNG assets.')


def build_ht():
    artwork = Image.open(REF / 'ams-ht-angled.png')
    device(artwork, (0, 0, artwork.width, artwork.height), 'ams-ht.png', (28,30), stretch = True)


def repair_compact_logo():
    # Preserve the existing wordmark; pixel-snap only the symbol's lost gaps.
    logo = Image.open(OUT / 'bambu-logo.png').convert('RGB')
    ImageDraw.Draw(logo).rectangle((0, 0, 12, 15), fill='black')
    logo.paste(Image.open(OUT / 'bambu-symbol.png'), (0, 0))
    logo.save(OUT / 'bambu-logo.png')


if __name__ == '__main__':
    if '--ht-only' in sys.argv:
        build_ht()
        repair_compact_logo()
    else:
        main()
