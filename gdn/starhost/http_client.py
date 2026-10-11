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
subprocess. Within one render, every URL is also memoized in memory — including
3xx/4xx/timeouts — because a six-page app that retries the same 404 once per
page would otherwise blow MAX_REQUESTS_PER_RUN. Disk cache stays 2xx-only so a
temporary outage is not stored for five minutes.
"""
from __future__ import annotations

import hashlib
import json as _json
import os
import random
import re
import time
from pathlib import Path
from urllib.parse import urlsplit

import requests

try:
    import fcntl  # POSIX only; used to serialise proxy-list refreshes across renders
except ImportError:  # non-POSIX (e.g. Windows dev) — the refresh lock becomes a no-op
    fcntl = None

# Hard per-attempt timeout: an API slower than this is treated as down. A live
# panel can't wait, so we fail fast rather than tie up a render worker. One
# logical http.get may retry across up to PROXY_ATTEMPTS proxies, so the worst-case
# wall time is REQUEST_TIMEOUT * PROXY_ATTEMPTS; keep their product below the
# sandbox wall-time in run_star_app_sandboxed so a slow endpoint fails cleanly
# inside the app instead of getting the whole render killed.
REQUEST_TIMEOUT = 4.0
DEFAULT_TTL = 300
# Cap huge responses; the body is truncated, which for a JSON feed means it
# stops parsing and the app sees nothing. 1 MB was under the size of feeds apps
# legitimately need: Citi Bike's GBFS station_status is ~0.96 MB today and
# station_information ~1.36 MB, so the first was one growth spurt from breaking
# and the second already did.
MAX_BODY_BYTES = 2_000_000
MAX_REQUESTS_PER_RUN = 8            # an app can't hammer an API in one render

CACHE_DIR = Path.home() / ".gdn" / "httpcache"

# ---- outbound proxy pool --------------------------------------------------
# All app http.get traffic egresses through a rotating proxy pool, so the render
# host itself never makes the outbound connection — a malicious app can't use
# http.get to reach the host's own network or cloud metadata. The pool is
# DOWNLOADED from the URL in the GDN_P environment variable (a provider
# "download list" link, kept as a host secret, never in the repo). If GDN_P is
# unset (e.g. local dev) the request goes out directly, unchanged. If GDN_P IS
# set but no usable list can be had, requests fail closed (status_code 0) rather
# than quietly egressing from the host's own IP.
#
# The list refresh has to survive the provider throttling its download link.
# Every render is a fresh subprocess, so when the cached list expires (or a
# deploy wipes it) dozens of concurrent renders would all re-download at once;
# the provider answers that burst with {"detail":"Request was throttled..."}.
# So: only one render refreshes at a time (a flock on _PROXY_LOCK; the rest keep
# using the stale list), a failed refresh keeps the last good list and retries
# after PROXY_RETRY, and only well-formed proxy lines are ever accepted — an
# error body must never become a "proxy" (2026-10-08 outage: one did, was cached
# for an hour, and every proxied request failed with InvalidURL).
PROXY_SRC = os.environ.get("GDN_P", "")
PROXY_TTL = 3600            # re-download the list at most hourly
PROXY_RETRY = 120           # after a failed refresh, wait this long before trying again
PROXY_LOCK_WAIT = 5.0       # cold start: how long a render waits for another's refresh
PROXY_ATTEMPTS = 3          # try this many different proxies before giving up
_PROXY_CACHE = CACHE_DIR / "proxies.json"
_PROXY_LOCK = CACHE_DIR / "proxies.lock"
_PROXY_HOST = re.compile(r"^[A-Za-z0-9.-]+$")
_PROXY_CRED = re.compile(r"^[^\s:@/]+$")


def _parse_proxy_lines(text: str) -> list:
    """Turn a provider list into requests-style proxy URLs. Accepts the two common
    formats: `host:port:user:pass` (authenticated) and `host:port`. Anything else —
    notably a provider error body — is dropped, never turned into a proxy."""
    out = []
    for line in text.splitlines():
        p = line.strip().split(":")
        if len(p) not in (2, 4) or not _PROXY_HOST.match(p[0]) or not p[1].isdigit():
            continue
        if len(p) == 4:
            if _PROXY_CRED.match(p[2]) and _PROXY_CRED.match(p[3]):
                out.append(f"http://{p[2]}:{p[3]}@{p[0]}:{p[1]}")
        else:
            out.append(f"http://{p[0]}:{p[1]}")
    return out


def _valid_proxy_url(url) -> bool:
    try:
        s = urlsplit(url)
        return (s.scheme == "http" and bool(_PROXY_HOST.match(s.hostname or ""))
                and s.port is not None)
    except (TypeError, ValueError):
        return False


def _read_proxy_cache():
    """(ts, proxies) from the disk cache, or (0.0, []) if missing/corrupt. Entries
    are re-validated so a list cached by an older build can't carry a bad line;
    any bad entry marks the whole file stale so it's replaced on this render."""
    try:
        entry = _json.loads(_PROXY_CACHE.read_text(encoding="utf-8"))
        raw = list(entry["proxies"])
        proxies = [p for p in raw if _valid_proxy_url(p)]
        return (float(entry["ts"]) if len(proxies) == len(raw) else 0.0), proxies
    except (OSError, ValueError, KeyError, TypeError):
        return 0.0, []


def _proxy_cache_fresh(ts: float, proxies: list) -> bool:
    # an empty list is only "fresh" for PROXY_RETRY: that's the failed-refresh
    # backoff, so renders don't hammer the provider while it's throttling us
    return time.time() - ts < (PROXY_TTL if proxies else PROXY_RETRY)


def _write_proxy_cache(ts: float, proxies: list) -> None:
    try:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        tmp = _PROXY_CACHE.with_name(f"proxies.{os.getpid()}.tmp")
        tmp.write_text(_json.dumps({"ts": ts, "proxies": proxies}), encoding="utf-8")
        os.replace(tmp, _PROXY_CACHE)  # atomic: concurrent readers never see half a file
    except OSError:
        pass


def _download_proxies() -> list:
    try:
        r = requests.get(PROXY_SRC, timeout=10)
    except requests.RequestException:
        return []
    return _parse_proxy_lines(r.text) if r.status_code == 200 else []


def _try_refresh_lock():
    """Non-blocking exclusive lock on _PROXY_LOCK. Returns a handle to release()
    (closing the file drops the flock), or None if another render holds it."""
    if fcntl is None:
        return True
    try:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        f = open(_PROXY_LOCK, "w")
    except OSError:
        return True  # can't lock at all -> refresh unlocked rather than never
    try:
        fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return f
    except OSError:
        f.close()
        return None


def _load_proxies() -> list:
    """Return the proxy pool (empty if GDN_P isn't set, or no usable list). Cached
    on disk for PROXY_TTL because every render is a fresh subprocess — without the
    disk cache we'd re-download the whole list from the provider on each render."""
    if not PROXY_SRC:
        return []
    ts, proxies = _read_proxy_cache()
    if _proxy_cache_fresh(ts, proxies):
        return proxies
    deadline = time.monotonic() + PROXY_LOCK_WAIT
    while True:
        lock = _try_refresh_lock()
        if lock is not None:
            break
        if proxies:
            return proxies  # another render is refreshing; the stale list still works
        if time.monotonic() >= deadline:
            return []
        time.sleep(0.2)
        ts, proxies = _read_proxy_cache()
        if _proxy_cache_fresh(ts, proxies):
            return proxies
    try:
        # re-read under the lock: whoever held it may have just refreshed
        ts, proxies = _read_proxy_cache()
        if _proxy_cache_fresh(ts, proxies):
            return proxies
        fresh = _download_proxies()
        if fresh:
            _write_proxy_cache(time.time(), fresh)
            return fresh
        # refresh failed: keep the last good list and back off PROXY_RETRY
        now = time.time()
        _write_proxy_cache(now - PROXY_TTL + PROXY_RETRY if proxies else now, proxies)
        return proxies
    finally:
        if lock is not True:
            lock.close()


# Hosts whose traffic must NOT go through the proxy pool. Government APIs
# (weather.gov, the NOAA/USGS/FDA families, navy.mil, tfl.gov.uk) block
# commercial proxy ranges, and the repeated blocks were getting the pool's
# IPs banned by the proxy provider — so government traffic egresses directly
# from the render host's own IP instead. The match is a strict hostname
# SUFFIX against registry-controlled zones (never a substring, so
# "metadata.gov.evil.com" cannot buy a direct connection), and redirects
# stay disabled in _fetch, so a .gov response can't bounce the direct
# request somewhere else.
DIRECT_SUFFIXES = (".gov", ".mil", ".gov.uk")


def _direct_host(url) -> bool:
    try:
        host = urlsplit(url).hostname or ""
    except ValueError:
        return False
    return host.lower().rstrip(".").endswith(DIRECT_SUFFIXES)


def _fetch(url, headers, params):
    """One logical GET, routed through the proxy pool with rotation + retry.
    Redirects are disabled so a public URL can't bounce the request to an internal
    address; a 3xx is handed back to the app as-is. Raises requests.RequestException
    only if every attempt fails (the caller turns that into status_code 0).
    Government hosts (DIRECT_SUFFIXES) skip the pool entirely — see above."""
    if _direct_host(url):
        # trust_env=False so a host-level HTTP(S)_PROXY environment variable
        # can't silently put this traffic back on a proxy — "direct" must
        # mean the render host's own IP, whatever the box's env looks like.
        with requests.Session() as s:
            s.trust_env = False
            return s.get(url, headers=headers, params=params,
                         timeout=REQUEST_TIMEOUT, allow_redirects=False)
    pool = _load_proxies()
    if PROXY_SRC and not pool:
        raise requests.RequestException("proxy pool unavailable (GDN_P list empty or throttled)")
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
        self._mem = {}

    def get(self, url, headers=None, params=None, ttl_seconds=DEFAULT_TTL) -> dict:
        if not isinstance(url, str) or not url.startswith(("http://", "https://")):
            raise ValueError("http.get: url must be a string starting with "
                             "http:// or https://")
        headers = _clean_str_dict(headers, "headers")
        params = _clean_str_dict(params, "params")
        ttl = int(ttl_seconds)

        # Kill switch for testing an app's no-network fallback (set by
        # `gdn mcp` render_app simulate_offline). Bypasses the cache too —
        # the point is to see what the panel shows when there's NO data.
        if os.environ.get("GDN_HTTP_OFFLINE"):
            return _response(0, "", error="offline (simulated)")

        key = _cache_key(url, params, headers)
        cached = _cache_read(key, ttl)
        if cached is not None:
            return _response(*cached)

        hit = self._mem.get(key)
        if hit is not None:
            return hit

        self._count += 1
        if self._count > MAX_REQUESTS_PER_RUN:
            raise HttpLimit(f"http limit: at most {MAX_REQUESTS_PER_RUN} "
                            "uncached requests per render")
        try:
            r = _fetch(url, headers, params)
        except requests.RequestException as e:
            # timeout / DNS / refused / all proxies failed — report, don't crash the render
            out = _response(0, "", error=f"{type(e).__name__}: {e}"[:300])
            self._mem[key] = out
            return out
        body = r.text[:MAX_BODY_BYTES]
        if 200 <= r.status_code < 300 and ttl > 0:
            _cache_write(key, r.status_code, body)
        out = _response(r.status_code, body)
        self._mem[key] = out
        return out
