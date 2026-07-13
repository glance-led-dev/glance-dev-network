"""The GDN drawing surface.

`Canvas` is a thin, Pillow-backed mirror of Glance's PHP GD + drawText vocabulary
so existing app knowledge transfers directly:

    PHP                                   GDN (Python)
    ------------------------------------  ----------------------------------------
    imagefill(img, black)                 c.fill("black")
    imagesetpixel(img, x, y, col)         c.pixel(x, y, col)
    imagefilledrectangle(img,x0,y0,x1,y1) c.rect(x0, y0, x1, y1, fill=col)
    imagerectangle(img, x0,y0,x1,y1)      c.rect(x0, y0, x1, y1, outline=col)
    imageline(img, x0,y0,x1,y1, col)      c.line(x0, y0, x1, y1, col)
    drawText(img, s, x, y, align, col, f) c.text(s, x, y, font=f, color=col, align=align)
    drawTextWithStroke(...)               c.text_stroke(...)
    imagecopy / imagescale (PNG)          c.image("logo.png", x, y, w=.., h=..)

Coordinates are inclusive (like GD). The origin is top-left. Height is 32 by
default (the panel height); width is whatever the app declares (up to 384).
"""
from __future__ import annotations

from pathlib import Path
from typing import Optional

from PIL import Image

from .colors import Color, to_rgb
from .draw_helpers import DrawHelpers
from .fonts import char_width, get_glyphs

Align = str  # "left" | "center" | "right"


class Canvas(DrawHelpers):
    def __init__(
        self,
        width: int,
        height: int = 32,
        background: Color = "black",
        asset_dir: Optional[Path] = None,
    ):
        self.width = int(width)
        self.height = int(height)
        self.asset_dir = Path(asset_dir) if asset_dir else None
        self.img = Image.new("RGB", (self.width, self.height), to_rgb(background))
        self._px = self.img.load()

    # --- primitives ---------------------------------------------------------
    def fill(self, color: Color) -> "Canvas":
        rgb = to_rgb(color)
        self.img.paste(rgb, (0, 0, self.width, self.height))
        self._px = self.img.load()
        return self

    def pixel(self, x: int, y: int, color: Color) -> "Canvas":
        x, y = int(x), int(y)
        if 0 <= x < self.width and 0 <= y < self.height:
            self._px[x, y] = to_rgb(color)
        return self

    def rect(
        self,
        x0: int,
        y0: int,
        x1: int,
        y1: int,
        fill: Optional[Color] = None,
        outline: Optional[Color] = None,
    ) -> "Canvas":
        """Inclusive rectangle from (x0,y0) to (x1,y1), matching GD."""
        x0, y0, x1, y1 = int(x0), int(y0), int(x1), int(y1)
        if x1 < x0:
            x0, x1 = x1, x0
        if y1 < y0:
            y0, y1 = y1, y0
        if fill is not None:
            f = to_rgb(fill)
            for yy in range(max(0, y0), min(self.height, y1 + 1)):
                for xx in range(max(0, x0), min(self.width, x1 + 1)):
                    self._px[xx, yy] = f
        if outline is not None:
            o = to_rgb(outline)
            for xx in range(x0, x1 + 1):
                self.pixel(xx, y0, o)
                self.pixel(xx, y1, o)
            for yy in range(y0, y1 + 1):
                self.pixel(x0, yy, o)
                self.pixel(x1, yy, o)
        return self

    def line(self, x0: int, y0: int, x1: int, y1: int, color: Color) -> "Canvas":
        """Bresenham line, inclusive endpoints."""
        x0, y0, x1, y1 = int(x0), int(y0), int(x1), int(y1)
        c = to_rgb(color)
        dx = abs(x1 - x0)
        dy = -abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx + dy
        while True:
            self.pixel(x0, y0, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy
        return self

    # --- bitmap art ---------------------------------------------------------
    def bitmap(self, matrix, x: int, y: int, color: Color) -> "Canvas":
        """Draw a 2D array of 0/1 (like the PHP pixel-art triangles/icons)."""
        c = to_rgb(color)
        for ry, row in enumerate(matrix):
            for rx, on in enumerate(row):
                if on:
                    self.pixel(x + rx, y + ry, c)
        return self

    # --- text (mirrors drawText.php) ---------------------------------------
    def text(
        self,
        text: str,
        x: int,
        y: int,
        font: str = "5x7",
        color: Color = "white",
        align: Align = "left",
    ) -> "Canvas":
        x, y = int(x), int(y)
        glyphs = get_glyphs(font)
        c = to_rgb(color)

        total = 0
        for ch in text:
            if ch in glyphs and glyphs[ch]:
                total += char_width(glyphs, ch) + 1
        total = max(0, total - 1)

        if align == "center":
            x -= total // 2
        elif align == "right":
            x -= total
        x = max(0, x)  # matches drawText.php clamp

        for ch in text:
            g = glyphs.get(ch)
            if not g:
                continue
            for ry, row in enumerate(g):
                for rx, on in enumerate(row):
                    if on:
                        self.pixel(x + rx, y + ry, c)
            x += char_width(glyphs, ch) + 1
        return self

    def text_stroke(
        self,
        text: str,
        x: int,
        y: int,
        font: str = "5x7",
        color: Color = "white",
        stroke: Color = "black",
        thickness: int = 1,
        align: Align = "left",
    ) -> "Canvas":
        """Text with an outline for legibility (mirrors drawTextWithStroke)."""
        for dx in range(-thickness, thickness + 1):
            for dy in range(-thickness, thickness + 1):
                if dx == 0 and dy == 0:
                    continue
                self.text(text, x + dx, y + dy, font=font, color=stroke, align=align)
        self.text(text, x, y, font=font, color=color, align=align)
        return self

    def text_width(self, text: str, font: str = "5x7") -> int:
        from .fonts import text_width as _tw
        return _tw(font, text)

    # --- images -------------------------------------------------------------
    def image(
        self,
        source,
        x: int,
        y: int,
        w: Optional[int] = None,
        h: Optional[int] = None,
        resample: str = "nearest",
    ) -> "Canvas":
        """Paste a PNG/JPEG. Relative paths resolve against the app's folder.
        Transparency is respected. Default resize is nearest-neighbor (crisp pixels).
        """
        if isinstance(source, Image.Image):
            im = source
        else:
            p = Path(source)
            if not p.is_absolute() and self.asset_dir is not None:
                p = self.asset_dir / p
            im = Image.open(p)
        im = im.convert("RGBA")
        if (w is not None and w != im.width) or (h is not None and h != im.height):
            filt = Image.NEAREST if resample == "nearest" else Image.BILINEAR
            im = im.resize((w or im.width, h or im.height), filt)
        self.img.paste(im, (int(x), int(y)), im)  # alpha mask = the image itself
        self._px = self.img.load()
        return self

    # --- output -------------------------------------------------------------
    def save_png(self, path) -> str:
        self.img.save(path)
        return str(path)

    def to_png_bytes(self) -> bytes:
        import io
        buf = io.BytesIO()
        self.img.save(buf, format="PNG")
        return buf.getvalue()
