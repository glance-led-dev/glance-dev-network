"""GDN starhost — run untrusted Starlark apps and produce a validated scene.

Public API:
    run_star_app(app_dir, inputs, now=None) -> scene          # in-process
    run_star_app_sandboxed(app_dir, inputs, timeout=30) -> scene  # subprocess + hard timeout
    StarError, StarTimeout
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Optional

from .executor import StarError, app_page_count, esp_endpoint, run_star_app
from .sandbox_run import MARKER

__all__ = ["run_star_app", "run_star_app_sandboxed", "app_page_count",
           "esp_endpoint", "StarError", "StarTimeout"]


class StarTimeout(StarError):
    pass


def run_star_app_sandboxed(app_dir, inputs: Optional[dict] = None,
                           timeout: float = 30.0, only_page: Optional[int] = None,
                           now=None, return_logs: bool = False):
    """Run app.star in a child process with a hard wall-time kill. Returns the
    scene dict (or `(scene, logs)` when `return_logs=True`), or raises
    StarError/StarTimeout. This is how preview (and any server) stays alive even
    if an app contains an infinite loop. The default wall-time (30s) leaves room
    for `http.get` calls, which each carry their own 10s request timeout inside
    the child, so a slow endpoint fails cleanly in the app instead of getting the
    whole render killed. `now` (a datetime or ISO string) time-travels `ctx.now`.
    `logs` are the app's own `print()` lines."""
    now_arg = "" if now is None else (now if isinstance(now, str) else now.isoformat())
    cmd = [sys.executable, "-W", "ignore", "-m", "gdn.starhost.sandbox_run",
           str(Path(app_dir).resolve()), json.dumps(inputs or {}),
           str(only_page) if only_page is not None else "",
           now_arg]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
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
