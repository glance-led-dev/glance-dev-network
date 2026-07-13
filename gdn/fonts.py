"""Bitmap font access for GDN.

Fonts are the exact glyphs used by the LED panels, converted from the PHP
`bitmap_*.php` files into `data/fonts.json` (see tools/convert_fonts.py).

A font is a dict of {char: rows}, where rows is a list of rows and each row is a
list of 0/1 ints. Character advance width is `len(rows[0]) + 1`, matching
drawText.php exactly.
"""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

_DATA = Path(__file__).resolve().parent / "data" / "fonts.json"


@lru_cache(maxsize=1)
def _all() -> dict:
    with _DATA.open(encoding="utf-8") as fh:
        return json.load(fh)


def _normalize(name: str) -> str:
    n = name.strip()
    if n.startswith("bitmap_"):  # accept both "5x7" and "bitmap_5x7"
        n = n[len("bitmap_"):]
    return n


def list_fonts() -> list[str]:
    return sorted(_all().keys())


@lru_cache(maxsize=None)
def get_glyphs(name: str) -> dict:
    """Return {char: rows} for a font, or raise KeyError with a helpful message."""
    fonts = _all()
    key = _normalize(name)
    if key not in fonts:
        raise KeyError(
            f"font {name!r} not found. Available: {', '.join(sorted(fonts))}"
        )
    return fonts[key]["glyphs"]


def char_width(glyphs: dict, ch: str) -> int:
    """Pixel width of a glyph (0 if absent), not counting inter-char spacing."""
    g = glyphs.get(ch)
    if not g:
        return 0
    return len(g[0])


def text_width(name: str, text: str) -> int:
    """Total drawn width of `text`, mirroring drawText.php (1px between glyphs)."""
    glyphs = get_glyphs(name)
    total = 0
    for ch in text:
        if ch in glyphs and glyphs[ch]:
            total += len(glyphs[ch][0]) + 1
    return max(0, total - 1)


def font_height(name: str) -> int:
    """Row count of the font's tallest glyph (glyphs are uniform height in practice)."""
    glyphs = get_glyphs(name)
    return max((len(rows) for rows in glyphs.values() if rows), default=0)
