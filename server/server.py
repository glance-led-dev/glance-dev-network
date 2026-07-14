"""GDN render service, a tiny web app for Render.com (or any Python host).


Run locally (from the repo root):  python server/server.py   -> http://localhost:8000/
On Render:                          gunicorn server.server:app
"""
import os
import threading
import time
from collections import defaultdict, deque
from pathlib import Path

from flask import Flask, Response, abort, g, jsonify, request
from werkzeug.middleware.proxy_fix import ProxyFix

from gdn.starhost import (StarError, StarTimeout, app_page_count, esp_endpoint,
                          run_star_app_sandboxed)
from gdn.scene import SceneError, render_scene

# This file is at <repo>/server/server.py, so the apps live one level up.
ROOT = Path(__file__).resolve().parent.parent
APPS = ROOT / "apps"

app = Flask(__name__)

# Render (and most hosts) sit a proxy in front of us, so the real caller IP is in
# X-Forwarded-For, not request.remote_addr. Trust exactly one proxy hop: this makes
# request.remote_addr the true client IP AND stops a caller from spoofing extra
# X-Forwarded-For entries to dodge the rate limiter.
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1)

# ---- per-IP rate limiting -------------------------------------------------
# One render = one sandboxed subprocess, so a flood of /render calls from a single
# IP can tie up the worker pool. Cap how many an IP may make per time window. It's
# an in-process sliding window (no Redis); with a single gunicorn worker that's an
# exact count, and with N workers the effective limit is about N x RATE_LIMIT,
# still a hard ceiling on abuse. Tune on the host without a code change:
#   RATE_LIMIT      max /render requests per IP per window (0 disables the limiter)
#   RATE_WINDOW     window length in seconds
#   RATE_ALLOWLIST  comma-separated IPs that skip the limit (e.g. your own backend)
RATE_LIMIT = int(os.environ.get("RATE_LIMIT", "120"))
RATE_WINDOW = float(os.environ.get("RATE_WINDOW", "60"))
RATE_ALLOWLIST = {ip.strip() for ip in os.environ.get("RATE_ALLOWLIST", "").split(",") if ip.strip()}

_hits = defaultdict(deque)      # ip -> deque of recent request timestamps
_hits_lock = threading.Lock()
_last_sweep = [0.0]


def _client_ip():
    return request.remote_addr or "unknown"


def _rate_check(ip, now):
    """Sliding-window counter. Returns (allowed, remaining, retry_after_seconds)."""
    cutoff = now - RATE_WINDOW
    with _hits_lock:
        dq = _hits[ip]
        while dq and dq[0] < cutoff:      # drop timestamps older than the window
            dq.popleft()
        if len(dq) >= RATE_LIMIT:
            retry = max(1, int(RATE_WINDOW - (now - dq[0])) + 1)
            allowed, remaining = False, 0
        else:
            dq.append(now)
            allowed, remaining, retry = True, RATE_LIMIT - len(dq), 0
        # keep memory bounded: every so often drop IPs idle for a whole window
        if now - _last_sweep[0] > RATE_WINDOW:
            _last_sweep[0] = now
            for k in [k for k, v in _hits.items() if k != ip and (not v or v[-1] < cutoff)]:
                del _hits[k]
    return allowed, remaining, retry


@app.before_request
def _rate_limit():
    # Only the render endpoint spawns a sandbox, so that's the only thing worth
    # throttling; health checks and the app list stay unlimited.
    if RATE_LIMIT <= 0 or not request.path.startswith("/render/"):
        return
    ip = _client_ip()
    if ip in RATE_ALLOWLIST:
        return
    allowed, remaining, retry = _rate_check(ip, time.time())
    g.rate_remaining = remaining
    if not allowed:
        resp = jsonify({"error": "rate limit exceeded, slow down",
                        "limit": RATE_LIMIT, "window_seconds": int(RATE_WINDOW)})
        resp.status_code = 429
        resp.headers["Retry-After"] = str(retry)
        return resp


@app.after_request
def _rate_headers(resp):
    if hasattr(g, "rate_remaining"):
        resp.headers["X-RateLimit-Limit"] = str(RATE_LIMIT)
        resp.headers["X-RateLimit-Remaining"] = str(g.rate_remaining)
    return resp


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
