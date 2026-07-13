"""The host-side draw recorder.

Every `c.*` call a Starlark app makes lands here (via `Module.add_callable`), and
each one appends exactly one op to the current page's op list. The recorder never
draws pixels — it only builds the declarative scene that `gdn.scene` later renders
on the trusted Canvas. This is the Starlark side of the trust boundary.
"""
from __future__ import annotations

from ..draw_helpers import DrawHelpers
from ..fonts import text_width as _font_text_width

MAX_OPS_PER_PAGE = 4096


class StarOpLimit(Exception):
    """Raised when an app emits more than MAX_OPS_PER_PAGE draw ops on one page."""


def _coord(v) -> int:
    return int(v)


def _color(v):
    # Starlark gives us a str ("white"/"#f80") or a (r,g,b) tuple/list.
    if isinstance(v, str):
        return v
    return [int(x) for x in v]


class Recorder(DrawHelpers):
    """Records primitive ops. Composite helpers (circle, badge, sparkline, …)
    come from DrawHelpers and decompose into these primitives at record time,
    so the scene format and its schema never grow new op types."""

    def __init__(self, width: int, height: int):
        self.width = int(width)
        self.height = int(height)
        self.pages: list[dict] = []
        self._cur: list | None = None
        self._count = 0

    # called by the scaffold's gdn_dispatch before each page function
    def begin_page(self, name):
        self._cur = []
        self._count = 0
        self.pages.append({"name": str(name), "ops": self._cur})

    def _emit(self, op: dict):
        if self._cur is None:
            raise StarOpLimit("draw call before any page was started")
        if self._count >= MAX_OPS_PER_PAGE:
            raise StarOpLimit(f"op limit ({MAX_OPS_PER_PAGE}) exceeded on a single page")
        self._cur.append(op)
        self._count += 1

    # --- the c.* API (kwargs mirror Canvas / drawText) ---
    def fill(self, color):
        self._emit({"op": "fill", "color": _color(color)})

    def pixel(self, x, y, color):
        self._emit({"op": "pixel", "x": _coord(x), "y": _coord(y), "color": _color(color)})

    def rect(self, x0, y0, x1, y1, fill=None, outline=None):
        op = {"op": "rect", "x0": _coord(x0), "y0": _coord(y0),
              "x1": _coord(x1), "y1": _coord(y1)}
        if fill is not None:
            op["fill"] = _color(fill)
        if outline is not None:
            op["outline"] = _color(outline)
        self._emit(op)

    def line(self, x0, y0, x1, y1, color):
        self._emit({"op": "line", "x0": _coord(x0), "y0": _coord(y0),
                    "x1": _coord(x1), "y1": _coord(y1), "color": _color(color)})

    def text(self, text, x, y, font="5x7", color="white", align="left"):
        self._emit({"op": "text", "text": str(text), "x": _coord(x), "y": _coord(y),
                    "font": str(font), "color": _color(color), "align": str(align)})

    def text_stroke(self, text, x, y, font="5x7", color="white", stroke="black",
                    thickness=1, align="left"):
        self._emit({"op": "text_stroke", "text": str(text), "x": _coord(x), "y": _coord(y),
                    "font": str(font), "color": _color(color), "stroke": _color(stroke),
                    "thickness": int(thickness), "align": str(align)})

    def bitmap(self, rows, x, y, color):
        pyrows = [[int(v) for v in r] for r in rows]
        self._emit({"op": "bitmap", "rows": pyrows, "x": _coord(x), "y": _coord(y),
                    "color": _color(color)})

    def image(self, asset, x, y, w=None, h=None):
        op = {"op": "image", "asset": str(asset), "x": _coord(x), "y": _coord(y)}
        if w is not None:
            op["w"] = int(w)
        if h is not None:
            op["h"] = int(h)
        self._emit(op)

    # pure query — no op emitted
    def text_width(self, text, font="5x7") -> int:
        return _font_text_width(str(font), str(text))
    # text_wrapped / text_fit and the other composite helpers (circle, badge,
    # sparkline, progress_bar, …) are inherited from DrawHelpers.
