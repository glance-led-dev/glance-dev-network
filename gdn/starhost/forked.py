"""Fast sandboxed render for the web server: fork each render from a warm parent.

run_star_app_sandboxed() starts a brand-new interpreter per render, which then
imports Pillow, PyYAML, requests, starlark and jsonschema, parses the 1.1MB
fonts.json and builds the scene validator before the app runs a single line.
For a clock that setup is nearly all of the ~0.5 CPU-second a render costs, and
at ~11 renders/s it is what pins the render host's CPU.

Here the setup happens ONCE, in a zygote process (zygote.py, one per server
worker), and each render is a fork of it. The isolation is the same as before:
the render still runs in its own child process, under the same RLIMIT_AS /
RLIMIT_CPU caps, with a hard wall-time kill. The zygote is single-threaded, so
forking it is safe even though the server worker that asks for the render runs
threads.

POSIX only. Elsewhere (Windows dev), or with GDN_FORK_RENDER=0 on the host, this
falls back to run_star_app_sandboxed() unchanged.
"""
from __future__ import annotations

import json
import os
import signal
import socket
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import Optional

from . import StarError, StarTimeout, run_star_app_sandboxed

_lock = threading.Lock()
_zygote = None   # (Popen, control socket)


def _enabled() -> bool:
    return os.name == "posix" and os.environ.get("GDN_FORK_RENDER", "1") != "0"


def _start_zygote():
    ours, theirs = socket.socketpair(socket.AF_UNIX, socket.SOCK_SEQPACKET)
    # MALLOC_ARENA_MAX: same reason as the subprocess path (keeps RLIMIT_AS sane)
    env = {**os.environ, "MALLOC_ARENA_MAX": "2"}
    proc = subprocess.Popen(
        [sys.executable, "-W", "ignore", "-m", "gdn.starhost.zygote", str(theirs.fileno())],
        pass_fds=[theirs.fileno()], env=env)
    theirs.close()
    return proc, ours


def _stop_zygote() -> None:
    global _zygote
    if _zygote is not None:
        proc, ctl = _zygote
        ctl.close()
        proc.kill()
        proc.wait()
        _zygote = None


def _send(req: bytes, fd: int) -> None:
    """Hand one render to the zygote, (re)starting it if it isn't running."""
    global _zygote
    with _lock:
        for attempt in (1, 2):
            if _zygote is None or _zygote[0].poll() is not None:
                _stop_zygote()
                _zygote = _start_zygote()
            try:
                socket.send_fds(_zygote[1], [req], [fd])
                return
            except OSError:
                _stop_zygote()
                if attempt == 2:
                    raise StarError("render zygote unavailable")


def run_star_app_forked(app_dir, inputs: Optional[dict] = None,
                        timeout: float = 30.0, only_page: Optional[int] = None) -> dict:
    """Same contract as run_star_app_sandboxed(app_dir, inputs, timeout, only_page):
    returns the scene dict or raises StarError / StarTimeout."""
    if not _enabled():
        return run_star_app_sandboxed(app_dir, inputs, timeout=timeout, only_page=only_page)

    req = json.dumps({"app_dir": str(Path(app_dir).resolve()), "inputs": inputs or {},
                      "only_page": only_page}).encode("utf-8")
    mine, theirs = socket.socketpair()
    try:
        _send(req, theirs.fileno())
        theirs.close()  # the child holds the only other end, so its exit reads as EOF

        deadline = time.monotonic() + timeout
        buf = bytearray()
        while True:
            left = deadline - time.monotonic()
            if left <= 0:
                pid = buf.split(b"\n", 1)[0]
                if b"\n" in buf and pid.isdigit():
                    try:
                        os.kill(int(pid), signal.SIGKILL)
                    except OSError:
                        pass
                raise StarTimeout(f"render timed out (>{timeout:g}s) — possible infinite loop")
            mine.settimeout(left)
            try:
                chunk = mine.recv(1 << 16)
            except socket.timeout:
                continue
            if not chunk:
                break
            buf += chunk
    finally:
        mine.close()
        theirs.close()

    _, _, body = bytes(buf).partition(b"\n")
    if not body:
        # killed before it could answer, e.g. by the RLIMIT_CPU / RLIMIT_AS caps
        raise StarError("sandbox produced no scene (render process was killed)")
    try:
        data = json.loads(body)
    except json.JSONDecodeError:
        raise StarError("sandbox returned malformed output")
    if not data.get("ok"):
        raise StarError(data.get("error", "unknown error"))
    return data["scene"]
