"""Local LED preview: render an app's pages and show them on a simulated panel.

Runs on the developer's machine, so any code the app runs during preview executes
locally (their risk, never Glance's servers). The same files (`app.py` +
`manifest.yaml`) drive this preview, the Studio GUI, and VS Code.
"""
from __future__ import annotations

import base64
import html
import webbrowser
from pathlib import Path
from typing import Dict, Optional

from .runner import format_error, load_app, load_manifest, render_all
from .scene import SceneError, render_scene
from .starhost import StarError, run_star_app_sandboxed
from . import rgb565


def _data_uri(png_bytes: bytes) -> str:
    return "data:image/png;base64," + base64.b64encode(png_bytes).decode("ascii")


def render_frames(app_dir, inputs: Optional[Dict[str, object]], now=None) -> dict:
    """Render an app's pages to data URIs. Routes .star apps through the Starlark
    sandbox and .py apps through the trusted Python path. Same response shape.
    `now` (an ISO string) time-travels `ctx.now` for testing date-driven apps."""
    app_dir = Path(app_dir)
    if (app_dir / "app.star").exists():
        return _render_frames_star(app_dir, inputs, now)
    return _render_frames_python(app_dir, inputs)


# Catalog preview images: 5x nearest-neighbor upscale, pages stacked with a small gap.
PREVIEW_SCALE = 5
PREVIEW_GAP = 6
PREVIEW_GAP_COLOR = (16, 16, 16)


def write_previews(app_dir, inputs=None, now=None):
    """Render every page and save it under the app's preview/ folder: preview/<page>.png
    at native LED resolution, plus preview/preview.png, a 5x poster of every page stacked
    vertically (the catalog thumbnail). Overwrites so the previews always match the current
    code. Returns the list of written Paths."""
    from PIL import Image
    app_dir = Path(app_dir)
    inputs = inputs or {}
    if (app_dir / "app.star").exists():
        scene = run_star_app_sandboxed(app_dir, inputs, now=now)
        canvases = render_scene(scene, asset_dir=app_dir)
        order = [p["name"] for p in scene["pages"]]
    else:
        app = load_app(app_dir)
        canvases = render_all(app, inputs=inputs, asset_dir=app_dir)
        order = [p.name for p in app.pages]

    out = app_dir / "preview"
    out.mkdir(parents=True, exist_ok=True)
    written, imgs = [], []
    for name in order:
        c = canvases[name]
        p = out / f"{name}.png"
        c.save_png(p)
        written.append(p)
        imgs.append(c.img.convert("RGB"))

    if imgs:
        s = PREVIEW_SCALE
        scaled = [im.resize((im.width * s, im.height * s), Image.NEAREST) for im in imgs]
        w = max(im.width for im in scaled)
        total_h = sum(im.height for im in scaled) + PREVIEW_GAP * (len(scaled) - 1)
        poster = Image.new("RGB", (w, total_h), PREVIEW_GAP_COLOR)
        y = 0
        for im in scaled:
            poster.paste(im, (0, y))
            y += im.height + PREVIEW_GAP
        pp = out / "preview.png"
        poster.save(pp)
        written.append(pp)
    return written


def _render_frames_star(app_dir: Path, inputs, now=None) -> dict:
    manifest = load_manifest(app_dir)
    app_meta = {
        "name": manifest.get("name", manifest.get("id", app_dir.name)),
        "width": int(manifest.get("width", 192)), "height": int(manifest.get("height", 32)),
        "refresh": int(manifest.get("refresh", 300)),
        "author": manifest.get("author", ""), "description": manifest.get("description", ""),
    }
    inputs_schema = [
        {"key": i["key"], "type": i.get("type", "string"), "label": i.get("label", i["key"]),
         "default": i.get("default"), "choices": i.get("choices"), "help": i.get("help", ""),
         "app_input_type": i.get("app_input_type")}
        for i in (manifest.get("inputs") or [])
    ]
    try:
        scene, logs = run_star_app_sandboxed(app_dir, inputs, now=now, return_logs=True)
        canvases = render_scene(scene, asset_dir=app_dir)
        pages = []
        for p in scene["pages"]:
            c = canvases[p["name"]]
            pages.append({"name": p["name"], "title": p.get("title", p["name"]),
                          "dataUri": _data_uri(c.to_png_bytes()), "w": c.width, "h": c.height,
                          "binEst": rgb565.estimate_bin_bytes(c.img)})
        return {"ok": True, "error": None, "app": app_meta, "inputs": inputs_schema,
                "pages": pages, "logs": logs}
    except (StarError, SceneError) as e:
        msg = e.message if isinstance(e, StarError) else "; ".join(e.errors)
        return {"ok": False, "error": msg, "app": app_meta, "inputs": inputs_schema,
                "pages": [], "logs": []}


def _render_frames_python(app_dir: Path, inputs: Optional[Dict[str, object]]) -> dict:
    """Trusted Python-path render (Glance's own first-party apps)."""
    try:
        app = load_app(app_dir)
        canvases = render_all(app, inputs=inputs, asset_dir=app_dir)
        pages = []
        for p in app.pages:
            c = canvases[p.name]
            pages.append({
                "name": p.name,
                "title": p.title,
                "dataUri": _data_uri(c.to_png_bytes()),
                "w": c.width,
                "h": c.height,
                "binEst": rgb565.estimate_bin_bytes(c.img),
            })
        return {
            "ok": True,
            "error": None,
            "app": {"name": app.name, "width": app.width, "height": app.height,
                    "refresh": app.refresh, "author": app.author,
                    "description": app.description},
            "inputs": [
                {"key": i.key, "type": i.type, "label": i.label,
                 "default": i.default, "choices": i.choices, "help": i.help,
                 "app_input_type": i.app_input_type}
                for i in app.inputs
            ],
            "pages": pages,
        }
    except Exception:  # noqa: BLE001
        return {"ok": False, "error": format_error(), "app": None,
                "inputs": [], "pages": []}


# --- HTML ------------------------------------------------------------------
_PAGE_CSS = """
:root { color-scheme: dark; }
* { box-sizing: border-box; }
body { margin: 0; font: 14px/1.5 -apple-system, Segoe UI, Roboto, sans-serif;
       background: #0b0d10; color: #e6e9ee; }
header { display: flex; align-items: baseline; gap: 14px; padding: 16px 22px;
         border-bottom: 1px solid #1e242c; position: sticky; top: 0; background: #0b0d10cc;
         backdrop-filter: blur(6px); z-index: 5; flex-wrap: wrap; }
header h1 { font-size: 17px; margin: 0; font-weight: 650; letter-spacing: .2px; }
header .meta { color: #7c8794; font-size: 12.5px; }
header .spacer { flex: 1; }
.wrap { display: flex; gap: 26px; padding: 22px; align-items: flex-start; }
.sidebar { width: 260px; flex: none; }
.card { background: #12161c; border: 1px solid #1e242c; border-radius: 12px; padding: 16px; }
.card h2 { font-size: 12px; text-transform: uppercase; letter-spacing: .8px;
           color: #7c8794; margin: 0 0 12px; font-weight: 600; }
label { display: block; font-size: 12px; color: #aab4bf; margin: 12px 0 4px; }
label:first-of-type { margin-top: 0; }
input, select { width: 100%; padding: 8px 10px; border-radius: 8px; border: 1px solid #2a3340;
        background: #0b0d10; color: #e6e9ee; font: inherit; }
.hint { color: #66707b; font-size: 11px; margin-top: 3px; }
button { margin-top: 16px; width: 100%; padding: 9px; border: 0; border-radius: 8px;
         background: #2f6df6; color: #fff; font: inherit; font-weight: 600; cursor: pointer; }
button:hover { background: #2559d6; }
.toggles { display: flex; gap: 14px; align-items: center; margin-top: 14px; font-size: 12px; color: #aab4bf; }
.toggles label { display: inline-flex; align-items: center; gap: 6px; margin: 0; }
.toggles input { width: auto; }
.panels { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 22px; }
.panel-card { }
.panel-head { display: flex; align-items: baseline; gap: 10px; margin-bottom: 10px; }
.panel-head .name { font-weight: 600; }
.panel-head .dims { color: #66707b; font-size: 12px; }
.screen-wrap { overflow-x: auto; padding: 18px; border-radius: 12px;
        background: radial-gradient(120% 140% at 50% 0%, #16191f 0%, #0a0b0d 100%);
        border: 1px solid #1e242c; }
.screen { position: relative; display: inline-block; line-height: 0;
          box-shadow: 0 0 44px rgba(60,120,255,.10), 0 0 0 1px #000 inset; border-radius: 3px; }
.screen img { image-rendering: pixelated; display: block; }
.screen.grid::after { content: ""; position: absolute; inset: 0; pointer-events: none;
   background-image:
     linear-gradient(to right, rgba(0,0,0,.34) 1px, transparent 1px),
     linear-gradient(to bottom, rgba(0,0,0,.34) 1px, transparent 1px);
   background-size: var(--cell) var(--cell); mix-blend-mode: multiply; }
.err { white-space: pre-wrap; font-family: ui-monospace, Menlo, Consolas, monospace;
       font-size: 12px; color: #ff9a9a; background: #1a0f10; border: 1px solid #5a2530;
       border-radius: 10px; padding: 16px; overflow-x: auto; }
.footnote { color: #66707b; font-size: 12px; padding: 4px 22px 26px; }
code { background: #12161c; padding: 1px 6px; border-radius: 5px; color: #cbd3dc; }
"""

_PAGE_JS = """
const SCALE = 7;
function frameHTML(p, grid) {
  const cls = grid ? 'screen grid' : 'screen';
  return `<div class="panel-card">
    <div class="panel-head"><span class="name">${p.title||p.name}</span>
      <span class="dims">${p.w}×${p.h} · ~${(p.binEst/1024).toFixed(1)} KB raw</span></div>
    <div class="screen-wrap"><div class="${cls}" style="--cell:${SCALE}px">
      <img src="${p.dataUri}" width="${p.w*SCALE}" height="${p.h*SCALE}"></div></div></div>`;
}
async function refresh() {
  const form = document.getElementById('inputs');
  const qs = new URLSearchParams(form ? new FormData(form) : undefined);
  const nowv = document.getElementById('nowfld').value;
  if (nowv) qs.set('now', nowv);
  const r = await fetch('frames.json?' + qs.toString());
  const data = await r.json();
  const panels = document.getElementById('panels');
  const grid = document.getElementById('grid').checked;
  const con = document.getElementById('console');
  const logs = data.logs || [];
  con.textContent = logs.join('\\n');
  con.style.display = logs.length ? 'block' : 'none';
  if (!data.ok) { panels.innerHTML = `<div class="err">${data.error.replace(/[&<>]/g,
      c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]))}</div>`; return; }
  panels.innerHTML = data.pages.map(p => frameHTML(p, grid)).join('');
  wireHover();
}
function wireHover() {
  const co = document.getElementById('coords');
  document.querySelectorAll('.screen img').forEach(img => {
    img.onmousemove = (e) => {
      const r = img.getBoundingClientRect();
      const x = Math.floor((e.clientX - r.left) / r.width * img.naturalWidth);
      const y = Math.floor((e.clientY - r.top) / r.height * img.naturalHeight);
      co.textContent = 'x ' + x + ', y ' + y;
    };
    img.onmouseleave = () => { co.textContent = ''; };
  });
}
function live() {
  const on = document.getElementById('livechk').checked;
  if (window._t) clearInterval(window._t);
  if (on) window._t = setInterval(refresh, 1200);
}
window.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('input[data-max="today"]').forEach(el => {
    el.max = new Date().toISOString().slice(0, 10);   // date-past: no future dates
  });
  refresh();
  document.getElementById('inputs')?.addEventListener('submit', e => { e.preventDefault(); refresh(); });
  document.getElementById('grid').addEventListener('change', refresh);
  document.getElementById('livechk').addEventListener('change', live);
  document.getElementById('nowfld').addEventListener('change', refresh);
});
"""


def _widget_for(i: dict) -> str:
    """Which UI control to render. The manifest's `app_input_type` wins; when it's
    absent we infer one from the legacy data `type` so old apps render unchanged."""
    w = (i.get("app_input_type") or "").strip().lower()
    if w:
        return w
    if i.get("type") == "choice" and i.get("choices"):
        return "dropdown"
    if i.get("type") == "number":
        return "number"
    return "free-text"


def _input_field(i: dict) -> str:
    key = html.escape(i["key"])
    label = html.escape(i["label"] or i["key"])
    default = "" if i["default"] is None else html.escape(str(i["default"]))
    hint = f'<div class="hint">{html.escape(i["help"])}</div>' if i.get("help") else ""
    choices = i.get("choices") or []
    widget = _widget_for(i)

    def _options():
        return "".join(
            f'<option {"selected" if str(c)==default else ""}>{html.escape(str(c))}</option>'
            for c in choices)

    if widget in ("dropdown", "selection") and choices:
        multiple = " multiple" if widget == "selection" else ""
        field = f'<select name="{key}"{multiple}>{_options()}</select>'
    elif widget == "checkbox":
        checked = "checked" if str(default).lower() in ("1", "true", "yes", "on") else ""
        field = f'<input type="checkbox" name="{key}" value="true" {checked}>'
    elif widget == "color":
        field = f'<input type="color" name="{key}" value="{default or "#ffffff"}">'
    elif widget in ("date", "date-past"):
        # date-past: a past date (birthday, count-up start) — cap the picker at today.
        cap = ' data-max="today"' if widget == "date-past" else ""
        field = f'<input type="date" name="{key}" value="{default}"{cap}>'
    elif widget == "number":
        field = f'<input type="number" name="{key}" value="{default}">'
    else:  # free-text and any unrecognized widget
        field = f'<input type="text" name="{key}" value="{default}">'
    return f'<label>{label}</label>{field}{hint}'


def preview_html(state: dict) -> str:
    app = state.get("app") or {"name": "GDN app", "width": 0, "height": 32, "refresh": 0}
    fields = "".join(_input_field(i) for i in state.get("inputs", []))
    form = (f'<form id="inputs"><div class="card"><h2>Inputs</h2>{fields}'
            f'<button type="submit">Render</button></div></form>'
            if fields else
            '<div class="card"><h2>Inputs</h2><div class="hint">This app declares no inputs.</div></div>')
    name = html.escape(app["name"])
    return f"""<!doctype html><html><head><meta charset="utf-8">
<title>{name} — GDN preview</title><style>{_PAGE_CSS}</style></head><body>
<header>
  <h1>{name}</h1>
  <span class="meta">{app['width']}×{app['height']} · refresh {app['refresh']}s</span>
  <span class="spacer"></span>
  <span class="meta" id="coords" style="min-width:78px"></span>
  <span class="meta">GDN preview</span>
</header>
<div class="wrap">
  <div class="sidebar">
    {form}
    <div class="toggles">
      <label><input type="checkbox" id="grid" checked> pixel grid</label>
      <label><input type="checkbox" id="livechk"> live</label>
      <label>now <input type="datetime-local" id="nowfld"></label>
    </div>
    <pre id="console" style="display:none;margin:10px 0 0;padding:8px 10px;background:#0a0d0c;border:1px solid #1c2420;border-radius:8px;color:#9fe0b0;font:12px/1.5 ui-monospace,Consolas,monospace;white-space:pre-wrap;max-height:150px;overflow:auto"></pre>
  </div>
  <div class="panels" id="panels"></div>
</div>
<div class="footnote">Edit <code>app.py</code> in VS Code or the Studio, then hit
  <b>Render</b> (or toggle <b>live</b>). Same files everywhere.</div>
<script>{_PAGE_JS}</script>
</body></html>"""


def create_server(app_dir: Path):
    from flask import Flask, Response, jsonify, request

    app_dir = Path(app_dir).resolve()
    server = Flask("gdn.preview")

    @server.get("/")
    def index():
        args = dict(request.args)
        now = args.pop("now", None) or None
        return preview_html(render_frames(app_dir, args, now=now))

    @server.get("/frames.json")
    def frames():
        args = dict(request.args)
        now = args.pop("now", None) or None
        return jsonify(render_frames(app_dir, args, now=now))

    return server


def serve(app_dir, host: str = "127.0.0.1", port: int = 8765, open_browser: bool = True):
    server = create_server(app_dir)
    url = f"http://{host}:{port}/"
    print(f"GDN preview: {url}   (Ctrl+C to stop)")
    if open_browser:
        try:
            webbrowser.open(url)
        except Exception:  # noqa: BLE001
            pass
    server.run(host=host, port=port, debug=False, use_reloader=False)
