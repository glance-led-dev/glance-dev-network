"""RGB565 conversion and .bin export.

Mirrors the PHP apps' pixel packing exactly:
    rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)

The panels ultimately consume an RLE-compressed .bin produced server-side by
Glance's `compressAndSaveImageData()` (helperFunctions/RLEbinary.php), which is
not part of this repo. Until that encoder is wired in, `export_raw_bin()` writes
an *uncompressed* RGB565 buffer and `estimate_bin_bytes()` reports the raw size
(the RLE output will be smaller). Set a real encoder with `set_bin_encoder()`.
"""
from __future__ import annotations

from typing import Callable, List, Optional

from PIL import Image

_ENCODER: Optional[Callable[[List[int]], bytes]] = None


def set_bin_encoder(fn: Callable[[List[int]], bytes]) -> None:
    """Register the production RLE encoder: fn(list_of_uint16) -> bytes."""
    global _ENCODER
    _ENCODER = fn


def to_rgb565_list(img: Image.Image) -> List[int]:
    """Row-major list of uint16 RGB565 values (matches image_to_rgb565)."""
    im = img.convert("RGB")
    px = im.load()
    w, h = im.size
    out: List[int] = []
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            out.append(((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3))
    return out


def to_rgb565_bytes(img: Image.Image, byte_order: str = "big") -> bytes:
    """Packed RGB565 buffer. ESP decoders usually read big-endian (MSB first)."""
    vals = to_rgb565_list(img)
    if byte_order == "big":
        return b"".join(v.to_bytes(2, "big") for v in vals)
    return b"".join(v.to_bytes(2, "little") for v in vals)


def estimate_bin_bytes(img: Image.Image) -> int:
    """Uncompressed RGB565 size (w*h*2). RLE .bin will be <= this."""
    w, h = img.size
    return w * h * 2


def export_bin(img: Image.Image, path) -> str:
    """Write a .bin. Uses the registered RLE encoder if present, else raw RGB565."""
    if _ENCODER is not None:
        data = _ENCODER(to_rgb565_list(img))
    else:
        data = to_rgb565_bytes(img, "big")
    with open(path, "wb") as fh:
        fh.write(data)
    return str(path)
