"""GDN starhost — run untrusted Starlark apps and produce a validated scene.

Public API:
    run_star_app(app_dir, inputs, now=None) -> scene          # in-process
    run_star_app_sandboxed(app_dir, inputs, timeout=30) -> scene  # subprocess + hard timeout
    StarError, StarTimeout
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Optional

try:
    import resource  # POSIX only; used to cap the render child's memory + CPU
except ImportError:  # non-POSIX (e.g. Windows dev) — the limits become a no-op
    resource = None

from .executor import StarError, app_page_count, esp_endpoint, run_star_app
from .sandbox_run import MARKER

__all__ = ["run_star_app", "run_star_app_sandboxed", "app_page_count",
           "esp_endpoint", "StarError", "StarTimeout"]


class StarTimeout(StarError):
    pass


# Per-render resource ceilings applied to the sandbox child on POSIX hosts (Linux
# in production), so one submitted app can't exhaust the render host — e.g. by
# building a giant list/string or decoding an oversized response — and take down
# every panel the instance serves. Tunable on the host without a code change:
#   GDN_MEM_LIMIT_MB   max address space per render, in MB (0 disables). Default 512.
#   GDN_CPU_LIMIT_S    max CPU-seconds per render         (0 disables). Default 25.
_MEM_LIMIT_MB = int(os.environ.get("GDN_MEM_LIMIT_MB", "512"))
_CPU_LIMIT_S = int(os.environ.get("GDN_CPU_LIMIT_S", "25"))


def _apply_limits():
    """Run in the forked child before exec (POSIX only). Sets the memory/CPU caps so
    the render process is killed if it exceeds them. Never raises: a limit that can't
    be set must not stop the render."""
    if resource is None:
        return
    try:
        if _MEM_LIMIT_MB > 0:
            n = _MEM_LIMIT_MB * 1024 * 1024
            resource.setrlimit(resource.RLIMIT_AS, (n, n))
        if _CPU_LIMIT_S > 0:
            resource.setrlimit(resource.RLIMIT_CPU, (_CPU_LIMIT_S, _CPU_LIMIT_S))
    except (ValueError, OSError):
        pass


def run_star_app_sandboxed(app_dir, inputs: Optional[dict] = None,
                           timeout: float = 30.0, only_page: Optional[int] = None,
                           now=None, return_logs: bool = False):
    """Run app.star in a child process with a hard wall-time kill. Returns the
    scene dict (or `(scene, logs)` when `return_logs=True`), or raises
    StarError/StarTimeout. This is how preview (and any server) stays alive even
    if an app contains an infinite loop. The default wall-time (30s) leaves room
    for `http.get` calls, which each carry their own 5s request timeout inside
    the child, so a slow endpoint fails cleanly in the app instead of getting the
    whole render killed. On POSIX hosts the child also runs under memory (RLIMIT_AS)
    and CPU (RLIMIT_CPU) caps so one app can't exhaust the host. `now` (a datetime or
    ISO string) time-travels `ctx.now`. `logs` are the app's own `print()` lines."""
    now_arg = "" if now is None else (now if isinstance(now, str) else now.isoformat())
    cmd = [sys.executable, "-W", "ignore", "-m", "gdn.starhost.sandbox_run",
           str(Path(app_dir).resolve()), json.dumps(inputs or {}),
           str(only_page) if only_page is not None else "",
           now_arg]
    # Apply the memory/CPU caps in the child on POSIX. MALLOC_ARENA_MAX keeps glibc
    # from reserving many 64MB arenas of virtual memory, which would otherwise make
    # the RLIMIT_AS cap fire (or fail to start) unpredictably on multi-core hosts.
    posix = os.name == "posix"
    child_env = {**os.environ, "MALLOC_ARENA_MAX": "2"} if posix else None
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout,
                              preexec_fn=_apply_limits if posix else None,
                              env=child_env)
    except subprocess.TimeoutExpired:
        raise StarTimeout(f"render timed out (>{timeout:g}s) — possible infinite loop")

    line = None
    for ln in (proc.stdout or "").splitlines():
        if ln.startswith(MARKER):
            line = ln[len(MARKER):]
    # the app's own print() output lands on stderr; keep it, drop interpreter noise
    logs = [ln for ln in (proc.stderr or "").splitlines()
            if ln.strip() and "RuntimeWarning" not in ln and not ln.startswith("<frozen")
            and "sys.modules" not in ln]
    if line is None:
        tail = (proc.stderr or proc.stdout or "no output")[-400:]
        raise StarError(f"sandbox produced no scene:\n{tail}")
    try:
        data = json.loads(line)
    except json.JSONDecodeError:
        raise StarError("sandbox returned malformed output")
    if not data.get("ok"):
        raise StarError(data.get("error", "unknown error"))
    return (data["scene"], logs) if return_logs else data["scene"]
