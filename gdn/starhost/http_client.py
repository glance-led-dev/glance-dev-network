"""Host-side HTTP for Starlark apps (the `http` struct in app.star).

Starlark code can't touch the network itself — `http.get(...)` lands here (via
`Module.add_callable`, exactly like the `c.*` draw calls) and the HOST performs
the real request with `requests`, then hands the response back into Starlark as
a plain dict. This keeps the sandbox intact: the app only ever sees data.

Contract (documented in getting-started/docs/reference/http.md — keep in sync):

    resp = http.get(url, headers = {}, params = {}, ttl_seconds = 300)
    resp["status_code"]  -> int   HTTP status, or 0 if the request never completed
    resp["body"]         -> str   response text ("" on transport failure)
    resp["json"]         -> decoded JSON value, or None if the body isn't JSON
    resp["error"]        -> None, or a short message when status_code is 0

Network trouble (timeout, DNS, refused connection) never crashes a render: the
app gets `status_code == 0` and decides what to draw. Only *programming* errors
(bad URL, non-dict headers) raise, so they surface as a clear StarError.

Responses with a 2xx status are cached on disk under ~/.gdn/httpcache keyed by
(url, params, headers) for `ttl_seconds`, so repeated renders don't refetch.
The cache is on disk (not in-process) because every sandboxed render is a fresh
subprocess.
"""
from __future__ import annotations

import hashlib
import json as _json
import os
import random
import time
from pathlib import Path

import requests

# Hard per-attempt timeout: an API slower than this is treated as down. A live
# panel can't wait, so we fail fast rather than tie up a render worker. One
# logical http.get may retry across up to PROXY_ATTEMPTS proxies, so the worst-case
# wall time is REQUEST_TIMEOUT * PROXY_ATTEMPTS; keep their product below the
# sandbox wall-time in run_star_app_sandboxed so a slow endpoint fails cleanly
# inside the app instead of getting the whole render killed.
REQUEST_TIMEOUT = 4.0
DEFAULT_TTL = 300
MAX_BODY_BYTES = 1_000_000          # cap huge responses; body is truncated
MAX_REQUESTS_PER_RUN = 8            # an app can't hammer an API in one render

CACHE_DIR = Path.home() / ".gdn" / "httpcache"

# ---- outbound proxy pool --------------------------------------------------
# All app http.get traffic egresses through a rotating proxy pool, so the render
# host itself never makes the outbound connection — a malicious app can't use
# http.get to reach the host's own network or cloud metadata. The pool is
# DOWNLOADED from the URL in the GDN_P environment variable (a provider
# "download list" link, kept as a host secret, never in the repo). If GDN_P is
# unset (e.g. local dev) the request goes out directly, unchanged.
PROXY_SRC = os.environ.get("GDN_P", "")
PROXY_TTL = 3600            # re-download the list at most hourly
PROXY_ATTEMPTS = 3          # try this many different proxies before giving up
_PROXY_CACHE = CACHE_DIR / "proxies.json"


def _parse_proxy_lines(text: str) -> list:
    """Turn a provider list into requests-style proxy URLs. Accepts the two common
    formats: `host:port:user:pass` (authenticated) and `host:port`."""
    out = []
    for line in text.splitlines():
        p = line.strip().split(":")
        if len(p) == 4:
            out.append(f"http://{p[2]}:{p[3]}@{p[0]}:{p[1]}")
        elif len(p) == 2:
            out.append(f"http://{p[0]}:{p[1]}")
    return out


def _load_proxies() -> list:
    """Return the proxy pool (empty if GDN_P isn't set). Cached on disk for
    PROXY_TTL because every render is a fresh subprocess — without the disk cache
    we'd re-download the whole list from the provider on each render."""
    if not PROXY_SRC:
        return []
    try:
        entry = _json.loads(_PROXY_CACHE.read_text(encoding="utf-8"))
        if time.time() - float(entry["ts"]) < PROXY_TTL and entry.get("proxies"):
            return list(entry["proxies"])
    except (OSError, ValueError, KeyError):
        pass  # missing / stale / corrupt -> re-download
    try:
        text = requests.get(PROXY_SRC, timeout=10).text
    except requests.RequestException:
        return []
    proxies = _parse_proxy_lines(text)
    try:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        _PROXY_CACHE.write_text(_json.dumps({"ts": time.time(), "proxies": proxies}),
                                encoding="utf-8")
    except OSError:
        pass
    return proxies


def _fetch(url, headers, params):
    """One logical GET, routed through the proxy pool with rotation + retry.
    Redirects are disabled so a public URL can't bounce the request to an internal
    address; a 3xx is handed back to the app as-is. Raises requests.RequestException
    only if every attempt fails (the caller turns that into status_code 0)."""
    pool = _load_proxies()
    chosen = random.sample(pool, min(PROXY_ATTEMPTS, len(pool))) if pool else [None]
    last = None
    for proxy in chosen:
        try:
            return requests.get(url, headers=headers, params=params,
                                timeout=REQUEST_TIMEOUT, allow_redirects=False,
                                proxies={"http": proxy, "https": proxy} if proxy else None)
        except requests.RequestException as e:
            last = e
    raise last if last is not None else requests.RequestException("no proxy available")


class HttpLimit(Exception):
    """Raised when an app makes more than MAX_REQUESTS_PER_RUN requests."""


def _clean_str_dict(value, what: str) -> dict:
    """Starlark hands us a dict (or None); normalize to {str: str} or raise."""
    if value is None:
        return {}
    if not isinstance(value, dict):
        raise ValueError(f"http.get: {what} must be a dict, got {type(value).__name__}")
    out = {}
    for k, v in value.items():
        if isinstance(v, bool):
            v = "true" if v else "false"
        out[str(k)] = str(v)
    return out


def _cache_key(url: str, params: dict, headers: dict) -> str:
    # headers (which may include an API key) are part of the key but are only
    # ever stored as a hash — the cache file never contains them.
    blob = _json.dumps(["GET", url, sorted(params.items()), sorted(headers.items())])
    return hashlib.sha256(blob.encode("utf-8")).hexdigest()


def _cache_read(key: str, ttl: int):
    if ttl <= 0:
        return None
    path = CACHE_DIR / (key + ".json")
    try:
        entry = _json.loads(path.read_text(encoding="utf-8"))
        if time.time() - float(entry["ts"]) < ttl:
            return int(entry["status_code"]), str(entry["body"])
    except (OSError, ValueError, KeyError):
        pass  # missing/corrupt cache entry == cache miss
    return None


def _cache_write(key: str, status_code: int, body: str) -> None:
    try:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        entry = {"ts": time.time(), "status_code": status_code, "body": body}
        (CACHE_DIR / (key + ".json")).write_text(_json.dumps(entry), encoding="utf-8")
    except OSError:
        pass  # a read-only disk shouldn't break a render


def _response(status_code: int, body: str, error=None) -> dict:
    try:
        decoded = _json.loads(body) if body else None
    except ValueError:
        decoded = None
    return {"status_code": int(status_code), "body": body, "json": decoded,
            "error": error}


class HttpHost:
    """One instance per app run (like Recorder); counts requests per render."""

    def __init__(self):
        self._count = 0

    def get(self, url, headers=None, params=None, ttl_seconds=DEFAULT_TTL) -> dict:
        if not isinstance(url, str) or not url.startswith(("http://", "https://")):
            raise ValueError("http.get: url must be a string starting with "
                             "http:// or https://")
        headers = _clean_str_dict(headers, "headers")
        params = _clean_str_dict(params, "params")
        ttl = int(ttl_seconds)

        key = _cache_key(url, params, headers)
        cached = _cache_read(key, ttl)
        if cached is not None:
            return _response(*cached)

        self._count += 1
        if self._count > MAX_REQUESTS_PER_RUN:
            raise HttpLimit(f"http limit: at most {MAX_REQUESTS_PER_RUN} "
                            "uncached requests per render")
        try:
            r = _fetch(url, headers, params)
        except requests.RequestException as e:
            # timeout / DNS / refused / all proxies failed — report, don't crash the render
            return _response(0, "", error=f"{type(e).__name__}: {e}"[:300])
        body = r.text[:MAX_BODY_BYTES]
        if 200 <= r.status_code < 300 and ttl > 0:
            _cache_write(key, r.status_code, body)
        return _response(r.status_code, body)
