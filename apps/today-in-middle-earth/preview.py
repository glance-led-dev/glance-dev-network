#!/usr/bin/env python3
"""Contact sheet to review the visual concept; GDN render is authoritative."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
CARDS = json.loads((ROOT / "app.star").read_text().splitlines()[2][8:])
DATES = ["03-15", "06-21", "02-29", "12-28", "05-14"]
SCALE = 6
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
SMALL = ImageFont.truetype(FONT, 6)
HERO = ImageFont.truetype(FONT, 14)
WHITE = "#ffffff"
AMBER = "#ffbf00"
GRAY = "#969696"


def draw_panel(card, story=False):
    lead, _, source, lines, font = card
    im = Image.new("RGB", (128, 32), "#000000")
    d = ImageDraw.Draw(im)
    d.line((4, 3, 4, 29), fill=AMBER)
    d.text((10, -1), "✦", font=SMALL, fill=AMBER)
    d.text((22, 0), "MIDDLE-EARTH", font=SMALL, fill=GRAY)
    d.line((10, 9, 118, 9), fill="#505050")
    if story:
        size = {"6x8": 9, "5x7": 7, "4x5": 6}[font]
        font_obj = ImageFont.truetype(FONT, size)
        y0, step = {"6x8": (9, 10), "5x7": (7, 8), "4x5": (8, 5)}[font]
        for i, line in enumerate(lines):
            d.text((10, y0 + i * step), line, font=font_obj, fill=WHITE)
    else:
        size = 14
        while size > 7 and d.textlength(lead, font=ImageFont.truetype(FONT, size)) > 108:
            size -= 1
        d.text((10, 10), lead, font=ImageFont.truetype(FONT, size), fill=WHITE)
        d.text((10, 25), source, font=SMALL, fill=AMBER)
    return im.resize((128 * SCALE, 32 * SCALE), Image.Resampling.NEAREST)


def main():
    width = 128 * SCALE
    sheet = Image.new("RGB", (width * 2 + 96, len(DATES) * (32 * SCALE + 64) + 44), "#101516")
    d = ImageDraw.Draw(sheet)
    label = ImageFont.truetype(FONT, 17)
    for i, day in enumerate(DATES):
        y = 40 + i * (32 * SCALE + 64)
        d.text((20, y - 27), f"{day}  /  WHEN", font=label, fill=AMBER)
        d.text((width + 76, y - 27), "STORY", font=label, fill=AMBER)
        sheet.paste(draw_panel(CARDS[day]), (20, y))
        sheet.paste(draw_panel(CARDS[day], True), (width + 76, y))
    out = ROOT / "concept_preview.png"
    sheet.save(out)
    print(out)


if __name__ == "__main__":
    main()
