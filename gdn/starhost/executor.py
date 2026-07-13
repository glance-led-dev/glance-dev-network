"""Run an untrusted `app.star` and produce a validated scene.

Flow: load manifest v2 → resolve inputs → build a Starlark module wired with the
`c` recorder, a `ctx` context, a safe `math`, and host-side `http` (all host
callables) → eval the
user's app.star plus an auto-generated scaffold → call each page → collect the
scene → validate it. The scaffold is appended AFTER the user's code so app.star
line numbers in errors stay correct.
"""
from __future__ import annotations

import datetime
import math as _pymath
import re
from pathlib import Path
from typing import Optional

import starlark

from ..app import Input
from ..colors import dim as _color_dim
from ..runner import load_manifest
from ..scene import validate_scene
from .http_client import HttpHost, HttpLimit
from .recorder import Recorder, StarOpLimit


class StarError(Exception):
    """Compile/runtime error from an app.star (message is user-facing)."""

    def __init__(self, message: str):
        self.message = message
        super().__init__(message)


# safe pure-function math exposed to Starlark as a `math` struct
_MATH = {
    "_gdn_sin": _pymath.sin, "_gdn_cos": _pymath.cos, "_gdn_tan": _pymath.tan,
    "_gdn_asin": _pymath.asin, "_gdn_acos": _pymath.acos, "_gdn_atan2": _pymath.atan2,
    "_gdn_sqrt": _pymath.sqrt, "_gdn_pow": _pymath.pow, "_gdn_fmod": _pymath.fmod,
    "_gdn_radians": _pymath.radians, "_gdn_degrees": _pymath.degrees,
    "_gdn_floor": lambda x: int(_pymath.floor(x)),
    "_gdn_ceil": lambda x: int(_pymath.ceil(x)),
    "_gdn_round": lambda x: int(round(x)),
    "_gdn_abs": abs,
}


# composite drawing helpers inherited from DrawHelpers; exposed on `c` in the
# scaffold. They chain by returning the recorder itself, which Starlark can't
# hold — _void_self() converts that self-return to None at the boundary.
_HELPER_NAMES = [
    "clear", "hline", "vline", "circle", "fill_circle", "triangle",
    "fill_triangle", "round_rect", "text_center", "text_right",
    "text_wrapped", "text_fit", "progress_bar", "bars", "sparkline",
    "badge", "trend_arrow", "icon", "grid", "gradient_rect",
    "sprite", "gauge", "kv", "stat", "header", "status_dot",
    "scoreboard", "table",
]


def _void_self(rec, fn):
    def wrapped(*a, **kw):
        r = fn(*a, **kw)
        return None if r is rec else r
    return wrapped


def _dim(color, pct):
    """color.dim("green", 50) -> half-brightness green as [r, g, b]."""
    return list(_color_dim(color, pct))


def _pad(n, width=2):
    """Zero-pad an integer to `width` digits, e.g. pad(5) -> '05'."""
    return str(int(n)).zfill(int(width))


def _commas(n):
    """Group thousands, e.g. commas(1234567) -> '1,234,567'."""
    return "{:,}".format(int(n))


def _globals():
    ext = starlark.LibraryExtension
    return starlark.Globals.standard().extended_by(
        [ext.StructType, ext.Print, ext.Json, ext.Map, ext.Filter])


def _now_dict(dt: datetime.datetime) -> dict:
    return {
        "unix": int(dt.timestamp()), "year": dt.year, "month": dt.month, "day": dt.day,
        "hour": dt.hour, "minute": dt.minute, "second": dt.second,
        "weekday": dt.weekday(), "yday": dt.timetuple().tm_yday,
    }


def _resolve_inputs(manifest: dict, raw: dict) -> dict:
    resolved = {}
    for spec in (manifest.get("inputs") or []):
        i = Input(spec["key"], spec.get("type", "string"), spec.get("label", spec["key"]),
                  spec.get("default"), spec.get("choices"), spec.get("help", ""))
        resolved[i.key] = i.coerce(raw.get(i.key))
    for k, v in raw.items():
        resolved.setdefault(k, v)
    return resolved


def _scaffold(page_names: list) -> str:
    pages_map = ", ".join(f'"{n}": {n}' for n in page_names)
    return f'''
# ---- GDN scaffold (auto-generated; do not copy into your app) ----
c = struct(
    width=_gdn_w, height=_gdn_h,
    fill=_gdn_fill, pixel=_gdn_pixel, rect=_gdn_rect, line=_gdn_line,
    text=_gdn_text, text_stroke=_gdn_text_stroke, bitmap=_gdn_bitmap,
    image=_gdn_image, text_width=_gdn_text_width,
    text_wrapped=_gdn_text_wrapped, text_fit=_gdn_text_fit,
    clear=_gdn_clear, hline=_gdn_hline, vline=_gdn_vline,
    circle=_gdn_circle, fill_circle=_gdn_fill_circle,
    triangle=_gdn_triangle, fill_triangle=_gdn_fill_triangle,
    round_rect=_gdn_round_rect,
    text_center=_gdn_text_center, text_right=_gdn_text_right,
    progress_bar=_gdn_progress_bar, bars=_gdn_bars, sparkline=_gdn_sparkline,
    badge=_gdn_badge, trend_arrow=_gdn_trend_arrow,
    icon=_gdn_icon, grid=_gdn_grid, gradient_rect=_gdn_gradient_rect,
    sprite=_gdn_sprite, gauge=_gdn_gauge, kv=_gdn_kv, stat=_gdn_stat,
    header=_gdn_header, status_dot=_gdn_status_dot,
    scoreboard=_gdn_scoreboard, table=_gdn_table,
)
fmt = struct(pad=_gdn_pad, commas=_gdn_commas)
color = struct(
    dim=_gdn_dim,
    black="black", white="white", red="red", green="green",
    puregreen="puregreen", blue="blue", yellow="yellow", orange="orange",
    cyan="cyan", magenta="magenta", amber="amber", pink="pink",
    purple="purple", skyblue="skyblue",
    gray="gray", darkgray="darkgray", midgray="midgray",
)
math = struct(
    pi=3.141592653589793,
    sin=_gdn_sin, cos=_gdn_cos, tan=_gdn_tan, asin=_gdn_asin, acos=_gdn_acos,
    atan2=_gdn_atan2, sqrt=_gdn_sqrt, pow=_gdn_pow, fmod=_gdn_fmod,
    radians=_gdn_radians, degrees=_gdn_degrees, floor=_gdn_floor, ceil=_gdn_ceil,
    round=_gdn_round, abs=_gdn_abs,
)
http = struct(get=_gdn_http_get)
ctx = struct(
    inputs=_gdn_inputs, width=_gdn_w, height=_gdn_h,
    now=struct(unix=_gdn_now["unix"], year=_gdn_now["year"], month=_gdn_now["month"],
        day=_gdn_now["day"], hour=_gdn_now["hour"], minute=_gdn_now["minute"],
        second=_gdn_now["second"], weekday=_gdn_now["weekday"], yday=_gdn_now["yday"]),
)
_GDN_PAGES = {{ {pages_map} }}
def gdn_dispatch(_gdn_name):
    _gdn_begin_page(_gdn_name)
    _GDN_PAGES[_gdn_name](c, ctx)
'''


def _error_hint(text: str) -> str:
    """A short, kind, plain-English hint for the most common beginner errors."""
    low = text.lower()
    if "undefined:" in low or "not defined" in low or "not found" in low:
        return "check the spelling, or define the name before you use it"
    if "unknown color" in low:
        return 'use a color name like "green" or a hex like "#00FF00"'
    if "unknown font" in low:
        return 'use a bundled font like "5x7" (run gdn fonts to list them)'
    if ("unsupported binary operation" in low or "unsupported operand" in low) \
            and "string" in low and ("int" in low or "float" in low):
        return "you're mixing text and numbers; wrap the number in str(...)"
    if ("want" in low or "got" in low) and "argument" in low:
        return "wrong number of arguments; check the function's parameters"
    if "index out of range" in low or "list index" in low:
        return "you indexed past the end of a list; check its length first"
    if "not iterable" in low:
        return "you tried to loop over something that isn't a list"
    if "division by zero" in low:
        return "you divided by zero; guard the denominator"
    if "has no field or method" in low or "no such method" in low:
        return "that name isn't on that object; check the exact spelling in the docs"
    return ""


def _clean_error(msg: str) -> str:
    lines = [ln.strip() for ln in (msg or "").strip().splitlines() if ln.strip()]
    if not lines:
        return "starlark error"
    # Starlark puts the real message on an "error:" line and the source location
    # on a "-->" line; surface both.
    err = next((ln for ln in lines if ln.startswith("error:")), None)
    if err:
        loc = next((ln for ln in lines if ln.startswith("-->")), None)
        base = err + (f" ({loc[3:].strip()})" if loc else "")
    elif lines[0].startswith("Traceback"):
        # A host callable that raised (e.g. the op-limit) is wrapped as a Python
        # traceback; the useful part is the final "Type: message" line.
        base = lines[-1]
    else:
        base = lines[0]
    hint = _error_hint(" ".join(lines))
    return base + (f"  (hint: {hint})" if hint else "")


def run_star_app(app_dir, inputs: Optional[dict] = None, *,
                 now: Optional[datetime.datetime] = None,
                 only_page: Optional[int] = None) -> dict:
    """Execute app.star and return a validated (JSON-safe) scene dict.

    If `only_page` (1-based) is given, run just that one page — this is what the
    render server calls per request (e.g. ?page=1 -> the first page's image)."""
    app_dir = Path(app_dir).resolve()
    manifest = load_manifest(app_dir)
    app_id = str(manifest.get("id") or app_dir.name)
    width = int(manifest.get("width", 192))
    height = int(manifest.get("height", 32))
    refresh = int(manifest.get("refresh", 300))
    mpages = manifest.get("pages")
    if isinstance(mpages, int):
        # `pages: 2` -> functions page1, page2 (numbered convention)
        page_names = ["page%d" % i for i in range(1, mpages + 1)]
    else:
        page_names = list(mpages or [])
    if not page_names:
        raise StarError("manifest.yaml `pages:` must be a list of names or a page count")
    if only_page is not None:
        if only_page < 1 or only_page > len(page_names):
            raise StarError("page %d out of range (app has %d page(s))"
                            % (only_page, len(page_names)))
        run_names = [page_names[only_page - 1]]
    else:
        run_names = page_names

    src_path = app_dir / "app.star"
    if not src_path.exists():
        raise StarError(f"no app.star in {app_dir}")
    user_src = src_path.read_text(encoding="utf-8")

    # Clear, beginner-friendly error if a declared page has no matching function
    # (otherwise the failure points into the invisible auto-generated scaffold).
    for pname in page_names:
        if not re.search(r"(?m)^\s*def\s+" + re.escape(pname) + r"\s*\(", user_src):
            raise StarError(
                f"manifest lists page '{pname}' but app.star has no function for it. "
                f"Add:  def {pname}(c, ctx):")

    resolved = _resolve_inputs(manifest, inputs or {})
    if now is None:
        now = datetime.datetime.now(datetime.timezone.utc)

    rec = Recorder(width, height)
    m = starlark.Module()
    m.add_callable("_gdn_fill", rec.fill)
    m.add_callable("_gdn_pixel", rec.pixel)
    m.add_callable("_gdn_rect", rec.rect)
    m.add_callable("_gdn_line", rec.line)
    m.add_callable("_gdn_text", rec.text)
    m.add_callable("_gdn_text_stroke", rec.text_stroke)
    m.add_callable("_gdn_bitmap", rec.bitmap)
    m.add_callable("_gdn_image", rec.image)
    m.add_callable("_gdn_text_width", rec.text_width)
    m.add_callable("_gdn_begin_page", rec.begin_page)
    for name, fn in _MATH.items():
        m.add_callable(name, fn)
    for name in _HELPER_NAMES:
        m.add_callable("_gdn_" + name, _void_self(rec, getattr(rec, name)))
    m.add_callable("_gdn_dim", _dim)
    m.add_callable("_gdn_pad", _pad)
    m.add_callable("_gdn_commas", _commas)
    m.add_callable("_gdn_http_get", HttpHost().get)  # host does the network
    m["_gdn_w"] = width
    m["_gdn_h"] = height
    m["_gdn_inputs"] = resolved
    m["_gdn_now"] = _now_dict(now)

    full_src = user_src + "\n\n" + _scaffold(page_names)
    try:
        ast = starlark.parse(src_path.name, full_src)
        starlark.eval(m, ast, _globals())
        frozen = m.freeze()
        for name in run_names:
            frozen.call("gdn_dispatch", name)
    except (StarOpLimit, HttpLimit) as e:
        raise StarError(str(e))
    except starlark.StarlarkError as e:
        raise StarError(_clean_error(str(e)))
    except Exception as e:  # host callable raised (e.g. math domain), missing page fn, etc.
        raise StarError(f"{type(e).__name__}: {e}")

    scene = {
        "gdn_scene": 1,
        "app": {"id": app_id, "width": width, "height": height, "refresh": refresh},
        "pages": [{"name": p["name"], "title": p["name"], "ops": p["ops"]} for p in rec.pages],
    }
    validate_scene(scene, manifest=manifest, asset_dir=app_dir,
                   check_pages=only_page is None)  # raises SceneError if bad
    return scene  # raw (JSON-safe) scene; render_scene re-validates + draws


def app_page_count(app_dir) -> int:
    manifest = load_manifest(Path(app_dir))
    mpages = manifest.get("pages")
    return mpages if isinstance(mpages, int) else len(mpages or [])


def esp_endpoint(app_dir) -> str:
    """The `GDN:width:height:id:pages` descriptor the render server / panel uses."""
    app_dir = Path(app_dir)
    manifest = load_manifest(app_dir)
    return "GDN:%d:%d:%s:%d" % (int(manifest.get("width", 192)),
                                int(manifest.get("height", 32)),
                                str(manifest.get("id", app_dir.name)),
                                app_page_count(app_dir))
