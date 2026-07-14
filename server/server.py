"""GDN render service, a tiny web app for Render.com (or any Python host).

Renders any published app to a live PNG:

    /render/<app_id>?page=1&zip=90210

This is the endpoint your panels / render pipeline call. It runs the app in the SAME
sandboxed subprocess used everywhere else, so a bad app can't hang it.

It lives in this repo alongside the SDK (gdn/) and the catalog (apps/), so Render deploys
it straight from here and picks up new apps automatically on every merge to main.

Run locally (from the repo root):  python server/server.py   -> http://localhost:8000/
On Render:                          gunicorn server.server:app
"""
import os
from pathlib import Path

from flask import Flask, Response, abort, jsonify, request

from gdn.starhost import (StarError, StarTimeout, app_page_count, esp_endpoint,
                          run_star_app_sandboxed)
from gdn.scene import SceneError, render_scene

# This file is at <repo>/server/server.py, so the apps live one level up.
ROOT = Path(__file__).resolve().parent.parent
APPS = ROOT / "apps"

app = Flask(__name__)


def _apps():
    if not APPS.is_dir():
        return []
    return sorted(p.name for p in APPS.iterdir() if (p / "app.star").exists())


@app.get("/healthz")
def healthz():
    return {"ok": True, "apps": len(_apps())}


@app.get("/api/apps")
def api_apps():
    return jsonify([
        {"id": a, "descriptor": esp_endpoint(APPS / a), "pages": app_page_count(APPS / a),
         "render": f"/render/{a}?page=1"}
        for a in _apps()
    ])


@app.get("/render/<app_id>")
def render(app_id):
    app_dir = APPS / app_id
    if not (app_dir / "app.star").exists():
        abort(404, description=f"no app '{app_id}'")
    try:
        page = int(request.args.get("page", 1))
    except ValueError:
        page = 1
    inputs = {k: v for k, v in request.args.items() if k != "page"}
    try:
        scene = run_star_app_sandboxed(app_dir, inputs, only_page=page)
        canvas = next(iter(render_scene(scene, asset_dir=app_dir).values()))
        return Response(canvas.to_png_bytes(), mimetype="image/png",
                        headers={"Cache-Control": "public, max-age=60"})
    except (StarError, StarTimeout) as e:
        return {"error": e.message}, 400
    except SceneError as e:
        return {"error": "; ".join(e.errors)}, 400


@app.get("/")
def home():
    return jsonify({
        "service": "GDN render",
        "apps": "/api/apps",
        "example": "/render/local-aqi?page=1&zip=90210",
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))
