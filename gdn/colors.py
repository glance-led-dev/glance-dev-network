"""Color parsing for GDN. Accepts (r,g,b) tuples, hex strings, or names and
normalizes to an (r, g, b) tuple of 0-255 ints.

LED panels only show what RGB565 can represent, so `quantize565()` lets tools
preview the *actual* on-panel color (5-6-5 bit depth) rather than the ideal RGB.
"""
from __future__ import annotations

from typing import Iterable, Union

Color = Union[str, Iterable[int]]

# A small, LED-friendly named palette. Names mirror common usage in the PHP apps.
NAMED = {
    "black": (0, 0, 0),
    "white": (255, 255, 255),
    "red": (255, 0, 0),
    "green": (0, 220, 70),      # the apps use a punchy green, not pure lime
    "puregreen": (0, 255, 0),
    "blue": (0, 90, 255),
    "yellow": (255, 220, 80),
    "orange": (255, 140, 0),
    "cyan": (0, 220, 220),
    "magenta": (255, 0, 200),
    "gray": (150, 150, 150),
    "grey": (150, 150, 150),
    "darkgray": (40, 40, 40),
    "darkgrey": (40, 40, 40),
    "midgray": (80, 80, 80),
    "midgrey": (80, 80, 80),
    "amber": (255, 191, 0),
    "pink": (255, 105, 180),
    "purple": (117, 33, 249),   # brand LED purple (#7521F9)
    "skyblue": (120, 220, 255), # brand LED light blue (#78DCFF)
}


def dim(color: Color, pct: int) -> tuple[int, int, int]:
    """Darken a color to `pct` percent of its brightness (0-100).
    dim("green", 50) is half-brightness green — handy for backgrounds/tracks."""
    r, g, b = to_rgb(color)
    p = max(0, min(100, int(pct))) / 100.0
    return (int(r * p), int(g * p), int(b * p))


def to_rgb(color: Color) -> tuple[int, int, int]:
    """Normalize any accepted color form to an (r, g, b) tuple."""
    if isinstance(color, str):
        c = color.strip().lower()
        if c in NAMED:
            return NAMED[c]
        if c.startswith("#"):
            c = c[1:]
        if len(c) == 3 and all(ch in "0123456789abcdef" for ch in c):
            return tuple(int(ch * 2, 16) for ch in c)  # type: ignore[return-value]
        if len(c) == 6 and all(ch in "0123456789abcdef" for ch in c):
            return (int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16))
        raise ValueError(
            f"unknown color {color!r}. Use a name ({', '.join(sorted(NAMED))}), "
            f"a hex code like '#ff8800', or (r, g, b).")
    seq = tuple(int(v) for v in color)
    if len(seq) != 3:
        raise ValueError(f"color tuple must be (r,g,b), got {color!r}")
    r, g, b = seq
    return (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)))


def quantize565(rgb: tuple[int, int, int]) -> tuple[int, int, int]:
    """Round-trip a color through RGB565 to show what the panel actually displays."""
    r, g, b = rgb
    r5 = (r & 0xF8)
    g6 = (g & 0xFC)
    b5 = (b & 0xF8)
    # replicate high bits into the low bits, matching how decoders expand 565->888
    r8 = r5 | (r5 >> 5)
    g8 = g6 | (g6 >> 6)
    b8 = b5 | (b5 >> 5)
    return (r8, g8, b8)
