"""The GDN scene (display list) — the trust boundary.

Untrusted Starlark apps never touch pixels; they emit a **scene**: a fully
declarative JSON document of draw ops. This module is the TRUSTED side — it
validates a scene against `data/scene.schema.json` plus semantic rules, then
renders it by dispatching each op onto the existing `Canvas` (our 37 real fonts,
our exact look). Nothing in a scene is ever interpreted as code, a path, or a URL
(the only file-ish field, `image.asset`, is checked against the manifest's asset
whitelist and resolved safely inside the bundle).

Public API:
    validate_scene(scene, *, manifest=None, asset_dir=None) -> normalized scene
    render_scene(scene, *, asset_dir=None) -> {page_name: Canvas}
    render_scene_pngs(scene, *, asset_dir=None) -> {page_name: png_bytes}
"""
from __future__ import annotations

import copy
import json
from functools import lru_cache
from pathlib import Path
from typing import Dict, List, Optional

from PIL import Image

from .canvas import Canvas
from .colors import to_rgb
from .fonts import list_fonts

SCENE_VERSION = 1
_SCHEMA_PATH = Path(__file__).resolve().parent / "data" / "scene.schema.json"
_MAX_SCENE_BYTES = 1 << 20          # 1 MiB
_MAX_ASSET_BYTES = 128 << 10        # 128 KiB
_MAX_ASSET_PIXELS = 384 * 64
_MAX_BITMAP_CELLS = 4096

# color fields per op (name of the field on the op dict)
_COLOR_FIELDS = {
    "fill": ["color"],
    "pixel": ["color"],
    "rect": ["fill", "outline"],
    "line": ["color"],
    "text": ["color"],
    "text_stroke": ["color", "stroke"],
    "bitmap": ["color"],
    "image": [],
}


class SceneError(ValueError):
    """Raised on an invalid scene. `.errors` lists every violation found."""

    def __init__(self, errors: List[str]):
        self.errors = errors
        super().__init__("; ".join(errors) if errors else "invalid scene")


@lru_cache(maxsize=1)
def _schema() -> dict:
    with _SCHEMA_PATH.open(encoding="utf-8") as fh:
        return json.load(fh)


@lru_cache(maxsize=1)
def _validator():
    from jsonschema import Draft202012Validator
    return Draft202012Validator(_schema())


@lru_cache(maxsize=1)
def _font_set() -> frozenset:
    return frozenset(list_fonts())


# --- asset resolution -------------------------------------------------------
def _resolve_asset(asset_dir: Optional[Path], asset: str, errors: List[str]) -> Optional[Path]:
    if asset_dir is None:
        errors.append(f"image op references asset {asset!r} but no asset_dir was given")
        return None
    if asset.startswith("/") or asset.startswith("\\") or ".." in asset.split("/"):
        errors.append(f"unsafe asset path: {asset!r}")
        return None
    base = Path(asset_dir).resolve()
    # Accept the asset next to app.star OR in an assets/ subfolder.
    p = None
    for cand in (base / asset, base / "assets" / asset):
        cr = cand.resolve()
        try:
            cr.relative_to(base)     # must stay inside the bundle
        except ValueError:
            continue
        if cr.is_file():
            p = cr
            break
    if p is None:
        errors.append(f"asset not found (looked in app folder and assets/): {asset!r}")
        return None
    if p.stat().st_size > _MAX_ASSET_BYTES:
        errors.append(f"asset too large (>128 KiB): {asset!r}")
        return None
    try:
        prev = Image.MAX_IMAGE_PIXELS
        Image.MAX_IMAGE_PIXELS = _MAX_ASSET_PIXELS
        try:
            with Image.open(p) as im:
                if im.format != "PNG":
                    errors.append(f"asset must be PNG: {asset!r}")
                    return None
                w, h = im.size
                if w * h > _MAX_ASSET_PIXELS or w > 384 or h > 64:
                    errors.append(f"asset dimensions too large: {asset!r} ({w}x{h})")
                    return None
        finally:
            Image.MAX_IMAGE_PIXELS = prev
    except Exception as e:  # noqa: BLE001
        errors.append(f"asset not a readable image: {asset!r} ({e})")
        return None
    return p


# --- validation -------------------------------------------------------------
def validate_scene(scene: dict, *, manifest: Optional[dict] = None,
                   asset_dir: Optional[Path] = None, check_pages: bool = True) -> dict:
    """Validate + normalize. Returns a NEW normalized scene (colors -> [r,g,b],
    defaults filled). Raises SceneError with every violation collected."""
    errors: List[str] = []

    # size guard
    try:
        raw = json.dumps(scene)
    except (TypeError, ValueError):
        raise SceneError(["scene is not JSON-serializable"])
    if len(raw.encode("utf-8")) > _MAX_SCENE_BYTES:
        raise SceneError(["scene exceeds 1 MiB"])

    # structural (JSON Schema) — bail before semantic checks if shape is wrong
    schema_errors = sorted(_validator().iter_errors(scene), key=lambda e: list(e.path))
    if schema_errors:
        for e in schema_errors[:50]:
            loc = "/".join(str(p) for p in e.path) or "<root>"
            errors.append(f"schema: {e.message} (at {loc})")
        raise SceneError(errors)

    norm = copy.deepcopy(scene)

    # app/manifest geometry
    if manifest is not None and "width" in manifest:
        if norm["app"]["width"] != int(manifest["width"]):
            errors.append(f"app.width {norm['app']['width']} != manifest width {manifest['width']}")

    # page names: unique, and match manifest order if provided
    names = [p["name"] for p in norm["pages"]]
    if len(names) != len(set(names)):
        errors.append(f"duplicate page names: {names}")
    mpages = manifest.get("pages") if manifest is not None else None
    if check_pages and isinstance(mpages, int):
        if len(names) != mpages:
            errors.append(f"scene has {len(names)} pages but manifest declares {mpages}")
    elif check_pages and mpages:
        if names != list(mpages):
            errors.append(f"pages {names} != manifest pages {list(mpages)}")

    manifest_assets = set(manifest.get("assets", [])) if manifest else None

    for page in norm["pages"]:
        # background default + normalize
        page["background"] = _norm_color(page.get("background", [0, 0, 0]),
                                         f"page {page['name']} background", errors)
        for i, op in enumerate(page["ops"]):
            where = f"page {page['name']} op[{i}] {op['op']}"
            # normalize color fields
            for field in _COLOR_FIELDS.get(op["op"], []):
                if field in op:
                    op[field] = _norm_color(op[field], f"{where}.{field}", errors)
            # per-op semantics + defaults
            if op["op"] in ("text", "text_stroke"):
                op.setdefault("font", "5x7")
                op.setdefault("align", "left")
                op["color"] = op.get("color") or [255, 255, 255]
                if op["font"] not in _font_set():
                    errors.append(f"{where}: unknown font {op['font']!r}")
                if op["op"] == "text_stroke":
                    op["stroke"] = op.get("stroke") or [0, 0, 0]
                    op.setdefault("thickness", 1)
            elif op["op"] == "bitmap":
                rows = op["rows"]
                width0 = len(rows[0])
                if any(len(r) != width0 for r in rows):
                    errors.append(f"{where}: bitmap rows must be rectangular")
                if sum(len(r) for r in rows) > _MAX_BITMAP_CELLS:
                    errors.append(f"{where}: bitmap exceeds {_MAX_BITMAP_CELLS} cells")
            elif op["op"] == "image":
                op["_path"] = _resolve_asset(asset_dir, op["asset"], errors)
                if manifest_assets is not None and op["asset"] not in manifest_assets:
                    errors.append(f"{where}: asset {op['asset']!r} not declared in manifest assets")

    if errors:
        raise SceneError(errors)
    return norm


def _norm_color(value, where: str, errors: List[str]):
    if value is None:
        return None
    try:
        return list(to_rgb(value))
    except (ValueError, TypeError) as e:
        errors.append(f"{where}: bad color {value!r} ({e})")
        return [0, 0, 0]


# --- rendering --------------------------------------------------------------
def render_scene(scene: dict, *, asset_dir: Optional[Path] = None) -> "Dict[str, Canvas]":
    """Validated scene -> one Canvas per page (page order). Pure op dispatch onto
    the trusted Canvas. Re-validates internally (never trusts its caller)."""
    scene = validate_scene(scene, asset_dir=asset_dir)
    width = scene["app"]["width"]
    height = scene["app"]["height"]
    out: "Dict[str, Canvas]" = {}
    for page in scene["pages"]:
        c = Canvas(width, height, background=tuple(page["background"]), asset_dir=asset_dir)
        for op in page["ops"]:
            _dispatch(c, op)
        out[page["name"]] = c
    return out


def render_scene_pngs(scene: dict, *, asset_dir: Optional[Path] = None) -> "Dict[str, bytes]":
    return {name: c.to_png_bytes() for name, c in render_scene(scene, asset_dir=asset_dir).items()}


def _tup(v):
    return tuple(v) if v is not None else None


def _dispatch(c: Canvas, op: dict) -> None:
    k = op["op"]
    if k == "fill":
        c.fill(_tup(op["color"]))
    elif k == "pixel":
        c.pixel(op["x"], op["y"], _tup(op["color"]))
    elif k == "rect":
        c.rect(op["x0"], op["y0"], op["x1"], op["y1"],
               fill=_tup(op.get("fill")), outline=_tup(op.get("outline")))
    elif k == "line":
        c.line(op["x0"], op["y0"], op["x1"], op["y1"], _tup(op["color"]))
    elif k == "text":
        c.text(op["text"], op["x"], op["y"], font=op["font"],
               color=_tup(op["color"]), align=op["align"])
    elif k == "text_stroke":
        c.text_stroke(op["text"], op["x"], op["y"], font=op["font"],
                      color=_tup(op["color"]), stroke=_tup(op["stroke"]),
                      thickness=op["thickness"], align=op["align"])
    elif k == "bitmap":
        c.bitmap(op["rows"], op["x"], op["y"], _tup(op["color"]))
    elif k == "image":
        src = op.get("_path") or op["asset"]
        c.image(src, op["x"], op["y"], w=op.get("w"), h=op.get("h"))
    else:  # unreachable after validation
        raise SceneError([f"unknown op {k!r}"])
