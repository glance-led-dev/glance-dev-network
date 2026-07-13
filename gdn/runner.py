"""Load a GDN app folder and render its pages.

Keeps files as the source of truth: `app.py` + `manifest.yaml` on disk are what
both the CLI/preview and the Studio GUI operate on. The module is re-imported on
every load so edits (from VS Code or the GUI) show up immediately.
"""
from __future__ import annotations

import importlib.util
import sys
import traceback
from pathlib import Path
from typing import Dict, Optional

import yaml

from .app import App, Input
from .canvas import Canvas

_LOAD_SEQ = 0  # gives each import a unique module name (no Date/random needed)


def load_manifest(app_dir: Path) -> dict:
    mf = Path(app_dir) / "manifest.yaml"
    if not mf.exists():
        mf = Path(app_dir) / "manifest.yml"
    if not mf.exists():
        return {}
    with mf.open(encoding="utf-8") as fh:
        return yaml.safe_load(fh) or {}


def _apply_manifest(app: App, manifest: dict) -> App:
    if not manifest:
        return app
    if "name" in manifest:
        app.name = str(manifest["name"])
    if "width" in manifest:
        app.width = int(manifest["width"])
    if "height" in manifest:
        app.height = int(manifest["height"])
    if "refresh" in manifest:
        app.refresh = int(manifest["refresh"])
    if "author" in manifest:
        app.author = str(manifest["author"])
    if "description" in manifest:
        app.description = str(manifest["description"])
    if "inputs" in manifest and manifest["inputs"]:
        app.inputs = [
            Input(
                key=i["key"],
                type=i.get("type", "string"),
                label=i.get("label", i["key"]),
                default=i.get("default"),
                choices=i.get("choices"),
                help=i.get("help", ""),
            )
            for i in manifest["inputs"]
        ]
    return app


def load_app(app_dir) -> App:
    """Import app.py from the folder and return its `app` (App instance),
    with manifest.yaml values overlaid."""
    global _LOAD_SEQ
    app_dir = Path(app_dir).resolve()
    entry = app_dir / "app.py"
    if not entry.exists():
        raise FileNotFoundError(f"no app.py in {app_dir}")

    _LOAD_SEQ += 1
    mod_name = f"gdn_userapp_{_LOAD_SEQ}"
    spec = importlib.util.spec_from_file_location(mod_name, entry)
    module = importlib.util.module_from_spec(spec)

    added = str(app_dir) not in sys.path
    if added:
        sys.path.insert(0, str(app_dir))
    try:
        sys.modules[mod_name] = module
        spec.loader.exec_module(module)  # type: ignore[union-attr]
    finally:
        sys.modules.pop(mod_name, None)
        if added and str(app_dir) in sys.path:
            sys.path.remove(str(app_dir))

    app = getattr(module, "app", None)
    if not isinstance(app, App):
        raise TypeError(f"{entry} must define `app = App(...)`")

    return _apply_manifest(app, load_manifest(app_dir))


def render_page(
    app: App,
    page_name: Optional[str] = None,
    inputs: Optional[Dict[str, object]] = None,
    asset_dir: Optional[Path] = None,
    background="black",
) -> Canvas:
    page = app.get_page(page_name)
    resolved = app.resolve_inputs(inputs)
    canvas = Canvas(app.width, app.height, background=background, asset_dir=asset_dir)
    page.fn(canvas, resolved)
    return canvas


def render_all(
    app: App,
    inputs: Optional[Dict[str, object]] = None,
    asset_dir: Optional[Path] = None,
) -> "Dict[str, Canvas]":
    return {
        p.name: render_page(app, p.name, inputs=inputs, asset_dir=asset_dir)
        for p in app.pages
    }


def format_error() -> str:
    return traceback.format_exc()
