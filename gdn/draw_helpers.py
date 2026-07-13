"""Shared drawing helpers — one implementation, two surfaces.

`DrawHelpers` is a mixin inherited by BOTH `gdn.canvas.Canvas` (the trusted
Pillow renderer used by Python apps and the scene renderer) and
`gdn.starhost.recorder.Recorder` (the op recorder Starlark apps talk to).
Every helper here is a *composite*: it only ever calls the eight primitives
(`fill / pixel / rect / line / text / text_stroke / bitmap / image`) plus the
pure queries (`text_width`, `self.width`, `self.height`) that both classes
provide with identical signatures.

That single constraint is what keeps the trust boundary intact: on the
Recorder these helpers decompose into ordinary scene ops (no new op types, no
schema change, the render server needs no update), and on the Canvas they draw
the exact same pixels — so `gdn preview` and the panel always agree.

Helpers return `self` for chaining unless the return value is documented
(e.g. `badge` returns its width, `text_fit` the chosen font).
"""
from __future__ import annotations

import json as _json
import math as _math
import os as _os

from .colors import dim as _dim, to_rgb as _to_rgb  # noqa: F401  (re-exported for convenience)
from .fonts import font_height as _font_height, text_width as _font_text_width

_ICONS = None


def _load_icons():
    """Lazy-load the bundled 1-bit icon matrices from gdn/data/icons.json."""
    global _ICONS
    if _ICONS is None:
        try:
            with open(_os.path.join(_os.path.dirname(__file__), "data", "icons.json"),
                      encoding="utf-8") as f:
                _ICONS = _json.load(f)
        except Exception:  # noqa: BLE001
            _ICONS = {}
    return _ICONS

# 5x5 pixel-art glyphs for trend_arrow (same shapes the stock apps hand-roll).
_ARROW_UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1]]
_ARROW_DOWN = [[1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]
_ARROW_FLAT = [[0, 0, 0, 0, 0], [0, 0, 0, 1, 0], [1, 1, 1, 1, 1], [0, 0, 0, 1, 0], [0, 0, 0, 0, 0]]


# status_dot's vocabulary: the state words tiny dashboards actually use.
_STATUS_COLORS = {
    "ok": "green", "up": "green", "on": "green", "good": "green", "online": "green",
    "warn": "amber", "warning": "amber", "degraded": "amber", "idle": "amber",
    "error": "red", "err": "red", "down": "red", "bad": "red", "alert": "red",
    "fail": "red", "offline": "red",
    "off": "midgray", "none": "midgray", "unknown": "midgray",
}


def _norm_values(values, lo=None, hi=None):
    """Normalize a list of numbers to 0.0..1.0 (flat lists map to 0.5)."""
    vals = [float(v) for v in values]
    vlo = float(lo) if lo is not None else min(vals)
    vhi = float(hi) if hi is not None else max(vals)
    if vhi <= vlo:
        return [0.5 for _ in vals]
    return [max(0.0, min(1.0, (v - vlo) / (vhi - vlo))) for v in vals]


class DrawHelpers:
    # --- convenience ---------------------------------------------------------
    def clear(self):
        """Fill the whole canvas with black."""
        self.fill("black")
        return self

    # --- straight lines ------------------------------------------------------
    def hline(self, x, y, w, color):
        """Horizontal line starting at (x, y), `w` pixels wide."""
        w = int(w)
        if w > 0:
            self.line(x, y, int(x) + w - 1, y, color)
        return self

    def vline(self, x, y, h, color):
        """Vertical line starting at (x, y), `h` pixels tall."""
        h = int(h)
        if h > 0:
            self.line(x, y, x, int(y) + h - 1, color)
        return self

    # --- circles -------------------------------------------------------------
    def circle(self, cx, cy, r, color):
        """Circle outline centered on (cx, cy) with radius `r`."""
        cx, cy, r = int(cx), int(cy), int(r)
        if r < 0:
            return self
        if r == 0:
            self.pixel(cx, cy, color)
            return self
        pts = set()
        x, y, err = r, 0, 1 - r
        while x >= y:
            for dx, dy in ((x, y), (y, x), (-y, x), (-x, y),
                           (-x, -y), (-y, -x), (y, -x), (x, -y)):
                pts.add((cx + dx, cy + dy))
            y += 1
            if err < 0:
                err += 2 * y + 1
            else:
                x -= 1
                err += 2 * (y - x) + 1
        for px, py in sorted(pts, key=lambda p: (p[1], p[0])):
            self.pixel(px, py, color)
        return self

    def fill_circle(self, cx, cy, r, color):
        """Filled circle centered on (cx, cy) with radius `r`."""
        cx, cy, r = int(cx), int(cy), int(r)
        if r < 0:
            return self
        r2 = r * r
        for dy in range(-r, r + 1):
            dx = int((r2 - dy * dy) ** 0.5)
            self.hline(cx - dx, cy + dy, 2 * dx + 1, color)
        return self

    # --- triangles -----------------------------------------------------------
    def triangle(self, x0, y0, x1, y1, x2, y2, color):
        """Triangle outline through three points."""
        self.line(x0, y0, x1, y1, color)
        self.line(x1, y1, x2, y2, color)
        self.line(x2, y2, x0, y0, color)
        return self

    def fill_triangle(self, x0, y0, x1, y1, x2, y2, color):
        """Filled triangle through three points (scanline fill)."""
        pts = sorted(((int(x0), int(y0)), (int(x1), int(y1)), (int(x2), int(y2))),
                     key=lambda p: p[1])
        (ax, ay), (bx, by), (cx, cy) = pts
        if ay == cy:  # degenerate: all on one row
            xs = [ax, bx, cx]
            self.hline(min(xs), ay, max(xs) - min(xs) + 1, color)
            return self

        def _x_at(y, px, py, qx, qy):
            if qy == py:
                return px
            return px + (qx - px) * (y - py) / (qy - py)

        for y in range(ay, cy + 1):
            xa = _x_at(y, ax, ay, cx, cy)          # long edge a->c
            if y < by:
                xb = _x_at(y, ax, ay, bx, by)      # short edge a->b
            else:
                xb = _x_at(y, bx, by, cx, cy)      # short edge b->c
            lo, hi = (xa, xb) if xa <= xb else (xb, xa)
            lo, hi = int(round(lo)), int(round(hi))
            self.hline(lo, y, hi - lo + 1, color)
        return self

    # --- rounded rectangle ---------------------------------------------------
    def round_rect(self, x0, y0, x1, y1, r, fill=None, outline=None):
        """Rectangle with rounded corners (radius `r`). Like `rect`, coordinates
        are inclusive; pass `fill`, `outline`, or both."""
        x0, y0, x1, y1, r = int(x0), int(y0), int(x1), int(y1), int(r)
        if x1 < x0:
            x0, x1 = x1, x0
        if y1 < y0:
            y0, y1 = y1, y0
        w, h = x1 - x0 + 1, y1 - y0 + 1
        r = max(0, min(r, (min(w, h) - 1) // 2))
        if r == 0:
            self.rect(x0, y0, x1, y1, fill=fill, outline=outline)
            return self
        r2 = r * r
        if fill is not None:
            self.rect(x0, y0 + r, x1, y1 - r, fill=fill)
            for dy in range(1, r + 1):
                dx = int((r2 - dy * dy) ** 0.5)
                self.hline(x0 + r - dx, y0 + r - dy, (x1 - x0) - 2 * (r - dx) + 1, fill)
                self.hline(x0 + r - dx, y1 - r + dy, (x1 - x0) - 2 * (r - dx) + 1, fill)
        if outline is not None:
            self.hline(x0 + r, y0, w - 2 * r, outline)
            self.hline(x0 + r, y1, w - 2 * r, outline)
            self.vline(x0, y0 + r, h - 2 * r, outline)
            self.vline(x1, y0 + r, h - 2 * r, outline)
            pts = set()
            x, y, err = r, 0, 1 - r
            while x >= y:
                for dx, dy in ((x, y), (y, x)):
                    pts.add((x1 - r + dx, y1 - r + dy))   # bottom-right
                    pts.add((x0 + r - dx, y1 - r + dy))   # bottom-left
                    pts.add((x1 - r + dx, y0 + r - dy))   # top-right
                    pts.add((x0 + r - dx, y0 + r - dy))   # top-left
                y += 1
                if err < 0:
                    err += 2 * y + 1
                else:
                    x -= 1
                    err += 2 * (y - x) + 1
            for px, py in sorted(pts, key=lambda p: (p[1], p[0])):
                self.pixel(px, py, outline)
        return self

    # --- text layout ---------------------------------------------------------
    def text_center(self, text, y, font="5x7", color="white"):
        """Draw text horizontally centered on the whole canvas."""
        self.text(text, self.width // 2, y, font=font, color=color, align="center")
        return self

    def text_right(self, text, y, font="5x7", color="white", margin=0):
        """Draw text right-aligned against the canvas edge (minus `margin`)."""
        self.text(text, self.width - 1 - int(margin), y, font=font, color=color,
                  align="right")
        return self

    def text_wrapped(self, text, x, y, w, font="5x7", color="white",
                     line_gap=2, align="left", max_lines=8):
        """Word-wrap `text` into lines that fit width `w`, drawn from (x, y)
        downward. Returns the number of lines drawn."""
        words = str(text).split(" ")
        lines, cur = [], ""
        for word in words:
            cand = word if cur == "" else cur + " " + word
            if cur == "" or _font_text_width(font, cand) <= int(w):
                cur = cand
            else:
                lines.append(cur)
                cur = word
                if len(lines) >= int(max_lines):
                    cur = ""
                    break
        if cur != "" and len(lines) < int(max_lines):
            lines.append(cur)
        lh = _font_height(font) + int(line_gap)
        yy = int(y)
        for ln in lines:
            self.text(ln, x, yy, font=font, color=color, align=align)
            yy += lh
        return len(lines)

    def text_fit(self, text, x, y, fonts, color="white", align="left", maxw=0):
        """Draw `text` in the biggest font from the list `fonts` that fits
        `maxw` (default: canvas width). Returns the font name used."""
        mw = int(maxw) if int(maxw) > 0 else self.width
        chosen = fonts[len(fonts) - 1]
        for f in fonts:
            if _font_text_width(f, str(text)) <= mw:
                chosen = f
                break
        self.text(text, x, y, font=chosen, color=color, align=align)
        return chosen

    # --- tiny data widgets ---------------------------------------------------
    def progress_bar(self, x, y, w, h, pct, color="green", bg="darkgray",
                     border=None):
        """Horizontal progress bar. `pct` is 0-100. Optional 1px `border`."""
        x, y, w, h = int(x), int(y), int(w), int(h)
        if w <= 0 or h <= 0:
            return self
        pct = max(0.0, min(100.0, float(pct)))
        ix, iy, iw, ih = x, y, w, h
        if border is not None:
            self.rect(x, y, x + w - 1, y + h - 1, outline=border)
            ix, iy, iw, ih = x + 1, y + 1, w - 2, h - 2
            if iw <= 0 or ih <= 0:
                return self
        if bg is not None:
            self.rect(ix, iy, ix + iw - 1, iy + ih - 1, fill=bg)
        fw = int(round(iw * pct / 100.0))
        if fw > 0:
            self.rect(ix, iy, ix + fw - 1, iy + ih - 1, fill=color)
        return self

    def bars(self, values, x, y, w, h, color="green", gap=1,
             min_val=None, max_val=None):
        """Mini bar chart of `values` in the box (x, y, w, h), bars rising from
        the bottom. Values are scaled min..max (override with min_val/max_val)."""
        x, y, w, h = int(x), int(y), int(w), int(h)
        n = len(values)
        if n == 0 or w <= 0 or h <= 0:
            return self
        gap = max(0, int(gap))
        bw = max(1, (w - gap * (n - 1)) // n)
        norm = _norm_values(values, min_val, max_val)
        bottom = y + h - 1
        bx = x
        for v in norm:
            bh = max(1, int(round(v * h)))
            self.rect(bx, bottom - bh + 1, bx + bw - 1, bottom, fill=color)
            bx += bw + gap
            if bx > x + w - 1:
                break
        return self

    def sparkline(self, values, x, y, w, h, color="green", fill=None,
                  min_val=None, max_val=None):
        """Mini line chart of `values` in the box (x, y, w, h). Optional `fill`
        shades the area under the line. Values scale min..max by default."""
        x, y, w, h = int(x), int(y), int(w), int(h)
        n = len(values)
        if n == 0 or w <= 0 or h <= 0:
            return self
        norm = _norm_values(values, min_val, max_val)
        bottom = y + h - 1
        if n == 1:
            py = bottom - int(round(norm[0] * (h - 1)))
            self.hline(x, py, w, color)
            return self
        pts = []
        for i, v in enumerate(norm):
            px = x + int(round(i * (w - 1) / (n - 1)))
            py = bottom - int(round(v * (h - 1)))
            pts.append((px, py))
        if fill is not None:
            for cx in range(x, x + w):
                # linear interpolation of the polyline at column cx
                for (px0, py0), (px1, py1) in zip(pts, pts[1:]):
                    if px0 <= cx <= px1:
                        t = 0.0 if px1 == px0 else (cx - px0) / (px1 - px0)
                        cy = int(round(py0 + t * (py1 - py0)))
                        self.vline(cx, cy, bottom - cy + 1, fill)
                        break
        for (px0, py0), (px1, py1) in zip(pts, pts[1:]):
            self.line(px0, py0, px1, py1, color)
        return self

    def badge(self, text, x, y, color="black", bg="green", font="5x7", pad=2):
        """A filled pill with `text` inside, top-left at (x, y).
        Returns the badge's total width in pixels (for stacking)."""
        text = str(text)
        tw = self.text_width(text, font)
        th = _font_height(font)
        w = tw + 2 * int(pad)
        h = th + 2
        r = min(2, (h - 1) // 2)
        self.round_rect(x, y, int(x) + w - 1, int(y) + h - 1, r, fill=bg)
        self.text(text, int(x) + int(pad), int(y) + 1, font=font, color=color)
        return w

    def trend_arrow(self, x, y, direction, color=None):
        """A 5x5 up/down/flat arrow. `direction` is a number (>0 up, <0 down,
        0 flat) or "up"/"down"/"flat". Color defaults to green/red/gray."""
        if isinstance(direction, str):
            d = {"up": 1, "down": -1, "flat": 0}.get(direction.lower(), 0)
        else:
            d = (direction > 0) - (direction < 0)
        if d > 0:
            self.bitmap(_ARROW_UP, x, y, color or "green")
        elif d < 0:
            self.bitmap(_ARROW_DOWN, x, y, color or "red")
        else:
            self.bitmap(_ARROW_FLAT, x, y, color or "gray")
        return self

    # --- icons ---------------------------------------------------------------
    def icon(self, name, x, y, color="white", scale=1):
        """Draw a bundled icon by name (see the icon gallery in the docs). `scale`
        enlarges each pixel by an integer factor. An unknown name draws nothing."""
        m = _load_icons().get(str(name))
        if not m:
            return self
        scale = max(1, int(scale))
        if scale != 1:
            m = [[cell for cell in row for _ in range(scale)]
                 for row in m for _ in range(scale)]
        self.bitmap(m, x, y, color)
        return self

    # --- layout query --------------------------------------------------------
    def grid(self, cols, rows=1, pad=1):
        """Split the whole canvas into `cols`x`rows` evenly-spaced cells. Returns a
        list of cells (each a dict with x0,y0,x1,y1,w,h,cx,cy); draws nothing, so
        you use the returned boxes to place things without coordinate math."""
        cols, rows, pad = max(1, int(cols)), max(1, int(rows)), max(0, int(pad))
        cw = (self.width - pad * (cols - 1)) / cols
        ch = (self.height - pad * (rows - 1)) / rows
        cells = []
        for r in range(rows):
            for cix in range(cols):
                x0 = int(round(cix * (cw + pad)))
                y0 = int(round(r * (ch + pad)))
                x1 = int(round(x0 + cw - 1))
                y1 = int(round(y0 + ch - 1))
                cells.append({"x0": x0, "y0": y0, "x1": x1, "y1": y1,
                              "w": x1 - x0 + 1, "h": y1 - y0 + 1,
                              "cx": (x0 + x1) // 2, "cy": (y0 + y1) // 2})
        return cells

    # --- gradient ------------------------------------------------------------
    def gradient_rect(self, x0, y0, x1, y1, color_a, color_b, horizontal=True):
        """Fill a rectangle with a smooth blend from `color_a` to `color_b`
        (left-to-right by default, top-to-bottom when horizontal=False)."""
        x0, y0, x1, y1 = int(x0), int(y0), int(x1), int(y1)
        if x1 < x0:
            x0, x1 = x1, x0
        if y1 < y0:
            y0, y1 = y1, y0
        a, b = _to_rgb(color_a), _to_rgb(color_b)

        def lerp(t):
            return [int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3)]

        if horizontal:
            n = x1 - x0
            for i, xx in enumerate(range(x0, x1 + 1)):
                self.vline(xx, y0, y1 - y0 + 1, lerp(0 if n == 0 else i / n))
        else:
            n = y1 - y0
            for i, yy in enumerate(range(y0, y1 + 1)):
                self.hline(x0, yy, x1 - x0 + 1, lerp(0 if n == 0 else i / n))
        return self

    # --- string-art sprites ----------------------------------------------------
    def sprite(self, art, x, y, color="white", legend=None, scale=1):
        """Draw string pixel-art. `art` is rows separated by newlines (or a list
        of row strings); spaces and dots are empty, any other character lights a
        pixel in `color`. Pass `legend` (a dict of character to color) for
        multi-color art; a legend value of None turns that character off.
        Leading/trailing blank lines are ignored, so triple-quoted strings work
        as-is. `scale` enlarges each art pixel by a whole factor."""
        if isinstance(art, str):
            rows = art.strip("\n").split("\n")
        else:
            rows = [str(r) for r in art]
        h = len(rows)
        w = max((len(r) for r in rows), default=0)
        if h == 0 or w == 0:
            return self
        layers = {}  # hashable color key -> (color, 0/1 matrix)
        for ry in range(h):
            row = rows[ry]
            for rx in range(len(row)):
                ch = row[rx]
                if ch == " " or ch == ".":
                    continue
                col = color
                if legend is not None and ch in legend:
                    col = legend[ch]
                if col is None:
                    continue
                key = tuple(col) if isinstance(col, (list, tuple)) else col
                if key not in layers:
                    layers[key] = (col, [[0] * w for _ in range(h)])
                layers[key][1][ry][rx] = 1
        scale = max(1, int(scale))
        for key in sorted(layers, key=str):  # deterministic op order
            col, m = layers[key]
            if scale != 1:
                m = [[cell for cell in mrow for _ in range(scale)]
                     for mrow in m for _ in range(scale)]
            self.bitmap(m, x, y, col)
        return self

    # --- gauge -----------------------------------------------------------------
    def gauge(self, cx, cy, r, pct, color="green", bg="darkgray",
              label=None, label_color="white", font="4x5", thickness=3):
        """A semicircular dial gauge. The arc spans 180 degrees, sits on the
        line y = cy, and fills left-to-right: `pct` is 0-100. `r` is the outer
        radius, `thickness` the band depth. An optional `label` is drawn
        centered inside the dial, just above its base."""
        cx, cy, r = int(cx), int(cy), int(r)
        thickness = max(1, int(thickness))
        pct = max(0.0, min(100.0, float(pct)))
        pts = {}
        for rr in range(max(1, r - thickness + 1), r + 1):
            steps = max(24, rr * 6)
            for i in range(steps + 1):
                t = i / steps                       # 0.0 far left .. 1.0 far right
                a = _math.pi * (1.0 - t)
                px = cx + int(round(rr * _math.cos(a)))
                py = cy - int(round(rr * _math.sin(a)))
                pts[(px, py)] = color if (pct > 0 and t * 100.0 <= pct) else bg
        for (px, py) in sorted(pts, key=lambda p: (p[1], p[0])):
            self.pixel(px, py, pts[(px, py)])
        if label is not None:
            self.text(str(label), cx, cy - _font_height(font) + 1, font=font,
                      color=label_color, align="center")
        return self

    # --- label / value row -------------------------------------------------------
    def kv(self, x, y, key, value, w=0, font="4x7",
           key_color="gray", value_color="white", dots=None, gap=2):
        """One label/value row: `key` left-aligned at (x, y), `value`
        right-aligned at x + w - 1 (w=0 means the rest of the canvas). Pass a
        color as `dots` for a dotted leader between them. Returns the y of the
        next row, so rows stack:  y = c.kv(2, y, "WIND", "8 MPH")."""
        x, y = int(x), int(y)
        w = int(w) if int(w) > 0 else self.width - x
        key, value = str(key), str(value)
        self.text(key, x, y, font=font, color=key_color)
        self.text(value, x + w - 1, y, font=font, color=value_color, align="right")
        if dots is not None:
            ly = y + _font_height(font) - 2
            lx0 = x + self.text_width(key, font) + 3
            lx1 = x + w - 1 - self.text_width(value, font) - 3
            for lx in range(lx0, lx1 + 1, 2):
                self.pixel(lx, ly, dots)
        return y + _font_height(font) + int(gap)

    # --- big-number stat ---------------------------------------------------------
    def stat(self, value, label, x, y, w=0, color="white", label_color="gray",
             fonts=None, label_font="4x5", align="left", gap=1):
        """A big-number stat: a small `label` above a large `value`. The value
        uses the biggest font from `fonts` (default 16x20, 10x16, 8x12, 6x8)
        that fits in `w` pixels (w=0 sizes to the space available) AND in the
        panel space left below it, so a stat under a header shrinks to fit.
        With align="center"/"right", x is the center/right edge of both lines.
        Returns the font used for the value."""
        x, y = int(x), int(y)
        if int(w) > 0:
            mw = int(w)
        elif align == "right":
            mw = x + 1
        elif align == "center":
            mw = 2 * min(x, self.width - 1 - x) + 1
        else:
            mw = self.width - x
        self.text(str(label), x, y, font=label_font, color=label_color, align=align)
        vy = y + _font_height(label_font) + int(gap)
        flist = list(fonts or ["16x20", "10x16", "8x12", "6x8"])
        short_enough = [f for f in flist if vy + _font_height(f) <= self.height]
        flist = short_enough if short_enough else [flist[-1]]
        return self.text_fit(str(value), x, vy, flist,
                             color=color, align=align, maxw=mw)

    # --- header bar ----------------------------------------------------------
    def header(self, title, bg="green", color="black", font="5x7", icon=None):
        """A filled title bar across the top of the canvas with `title`
        centered in it. Optional `icon` (a c.icon name) sits at the left edge.
        Returns the y just below the bar, where your content starts."""
        th = _font_height(font)
        h = th + 2
        self.rect(0, 0, self.width - 1, h - 1, fill=bg)
        self.text(str(title), self.width // 2, 1, font=font, color=color,
                  align="center")
        if icon is not None:
            self.icon(icon, 2, max(0, (h - 8) // 2), color=color)
        return h + 1

    # --- status dot ------------------------------------------------------------
    def status_dot(self, x, y, status, r=2, label=None, font="5x7",
                   label_color=None):
        """A colored status dot centered on (x, y). `status` maps to a color:
        True / "ok" / "up" / "online" are green, "warn" is amber, False /
        "error" / "down" are red, "off" / "unknown" are midgray; anything else
        is used as a color directly. Optional `label` text sits to the right,
        vertically centered on the dot (defaulting to the dot's color)."""
        if isinstance(status, bool):
            col = "green" if status else "red"
        elif isinstance(status, str) and status.lower() in _STATUS_COLORS:
            col = _STATUS_COLORS[status.lower()]
        else:
            col = status
        x, y, r = int(x), int(y), max(1, int(r))
        self.fill_circle(x, y, r, col)
        if label is not None:
            self.text(str(label), x + r + 3, y - _font_height(font) // 2,
                      font=font, color=label_color if label_color is not None else col)
        return self

    # --- two-team scoreboard -----------------------------------------------------
    def scoreboard(self, home, away, home_score, away_score, status="",
                   home_color="yellow", away_color="cyan", score_color="white",
                   x=0, y=0, w=0):
        """A two-team score layout: team names in the top corners, big scores
        under them, and an optional `status` ("Q4", "FINAL", "7TH") centered at
        the top. Fills the whole canvas width by default; pass x/y/w to inset."""
        x, y = int(x), int(y)
        w = int(w) if int(w) > 0 else self.width - x
        cx = x + w // 2
        self.text(str(home).upper(), x + 2, y + 1, font="6x8", color=home_color)
        self.text(str(away).upper(), x + w - 3, y + 1, font="6x8",
                  color=away_color, align="right")
        score_fonts = ["10x16", "8x12", "6x8"]
        half = w // 2 - 6
        self.text_fit(str(home_score), x + 2, y + 12, score_fonts,
                      color=score_color, maxw=half)
        self.text_fit(str(away_score), x + w - 3, y + 12, score_fonts,
                      color=score_color, align="right", maxw=half)
        if status:
            self.text(str(status).upper(), cx, y + 2, font="4x5", color="gray",
                      align="center")
        self.text("-", cx, y + 16, font="6x8", color="midgray", align="center")
        return self

    # --- simple table --------------------------------------------------------
    def table(self, rows, x, y, w=0, font="4x5", color="white", colors=None,
              header_color=None, aligns=None, line_gap=2):
        """Lay out rows of text columns inside width `w` (w=0 means the rest of
        the canvas). Column widths come from the widest cell; the first column
        is left-aligned, the last right-aligned, and the leftover space spreads
        between them (override per column with `aligns`, e.g.
        ["left", "center", "right"]). `colors` styles whole rows (None entries
        fall back to `color`); `header_color` restyles row 0. Returns the y
        just below the last row."""
        x, y = int(x), int(y)
        cells = [[str(v) for v in r] for r in rows]
        cells = [r for r in cells if len(r) > 0]
        if not cells:
            return y
        w = int(w) if int(w) > 0 else self.width - x
        ncols = max(len(r) for r in cells)
        widths = [0] * ncols
        for r in cells:
            for j in range(len(r)):
                tw = self.text_width(r[j], font)
                if tw > widths[j]:
                    widths[j] = tw
        gap = max(1, (w - sum(widths)) // (ncols - 1)) if ncols > 1 else 0
        starts = [x]
        for j in range(1, ncols):
            starts.append(starts[j - 1] + widths[j - 1] + gap)
        lh = _font_height(font) + int(line_gap)
        yy = y
        for i, r in enumerate(cells):
            row_color = color
            if colors is not None and i < len(colors) and colors[i] is not None:
                row_color = colors[i]
            if i == 0 and header_color is not None:
                row_color = header_color
            for j in range(len(r)):
                al = "left"
                if aligns is not None and j < len(aligns):
                    al = aligns[j]
                elif j == ncols - 1 and ncols > 1:
                    al = "right"
                if al == "right":
                    right_edge = x + w - 1 if j == ncols - 1 else starts[j] + widths[j] - 1
                    self.text(r[j], right_edge, yy, font=font, color=row_color,
                              align="right")
                elif al == "center":
                    self.text(r[j], starts[j] + widths[j] // 2, yy, font=font,
                              color=row_color, align="center")
                else:
                    self.text(r[j], starts[j], yy, font=font, color=row_color)
            yy += lh
        return yy
