"""Warm render "zygote": imports everything once, then forks one child per render.

    python -m gdn.starhost.zygote <control_fd>

Started by forked.py (one per server worker). It loads the whole render stack up
front (see _warm.py), then loops on its control socket. Each request is a JSON
line plus one socket, passed over as a file descriptor; the zygote forks, and the
child applies the same RLIMIT_AS / RLIMIT_CPU caps as the subprocess path, runs
the app, writes its pid and then the result to that socket, and exits. The zygote
itself never runs app code. It exits when the server worker closes its end.
"""
import json
import os
import signal
import socket
import sys


def _render(out, req) -> None:
    """Runs in the forked child. Mirrors sandbox_run.main()."""
    from . import _apply_limits
    from .executor import StarError, run_star_app
    from ..scene import SceneError

    # pid first, so the server can kill this render if it overruns its wall time
    out.write(b"%d\n" % os.getpid())
    out.flush()
    _apply_limits()
    try:
        # validate=False: the server's render_scene() validates the scene in the
        # parent, which is the check that matters; doing it here too doubled the cost
        res = {"ok": True, "scene": run_star_app(req["app_dir"], req["inputs"],
                                                 only_page=req["only_page"], validate=False)}
    except SceneError as e:
        res = {"ok": False, "error": "; ".join(e.errors)}
    except StarError as e:
        res = {"ok": False, "error": e.message}
    except Exception as e:  # noqa: BLE001
        res = {"ok": False, "error": f"{type(e).__name__}: {e}"}
    out.write(json.dumps(res).encode("utf-8"))
    out.flush()


def main() -> int:
    ctl = socket.socket(fileno=int(sys.argv[1]))
    from . import _warm  # noqa: F401  (the expensive part, done once)
    signal.signal(signal.SIGCHLD, signal.SIG_IGN)  # finished renders are reaped automatically
    while True:
        try:
            msg, fds, _, _ = socket.recv_fds(ctl, 1 << 20, 1)
        except OSError:
            return 0
        if not msg:
            return 0  # the server worker went away
        if not fds:
            continue
        if os.fork() == 0:
            code = 1
            try:
                ctl.close()
                signal.signal(signal.SIGCHLD, signal.SIG_DFL)
                # app print()s and engine panics stay out of the server's log, as
                # they did when the subprocess path captured them
                devnull = os.open(os.devnull, os.O_WRONLY)
                os.dup2(devnull, 1)
                os.dup2(devnull, 2)
                with os.fdopen(fds[0], "wb") as out:
                    _render(out, json.loads(msg))
                code = 0
            finally:
                os._exit(code)  # never fall back into the zygote's loop
        os.close(fds[0])


if __name__ == "__main__":
    raise SystemExit(main())
