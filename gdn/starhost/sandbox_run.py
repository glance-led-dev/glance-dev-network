"""Subprocess entry point: run one app.star and print its scene as JSON.

    python -m gdn.starhost.sandbox_run <app_dir> <inputs_json>

Running in a child process is what makes a hard wall-time kill possible (there is
no in-engine step cap), and in production it's where OS-level isolation (rlimits,
unprivileged user, no PHP credentials) is applied. The scene line is prefixed with
a marker so any app `print()` output on stdout can't be mistaken for the result.
"""
import json
import sys

MARKER = "__GDN_SCENE__"


def main() -> int:
    if len(sys.argv) < 2:
        print(MARKER + json.dumps({"ok": False, "error": "usage: sandbox_run <app_dir> [inputs_json]"}))
        return 2
    app_dir = sys.argv[1]
    try:
        inputs = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
    except json.JSONDecodeError:
        inputs = {}
    only_page = int(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3] else None
    now = None
    if len(sys.argv) > 4 and sys.argv[4]:
        import datetime
        try:
            now = datetime.datetime.fromisoformat(sys.argv[4])
            if now.tzinfo is None:
                now = now.replace(tzinfo=datetime.timezone.utc)
        except ValueError:
            now = None

    from .executor import run_star_app, StarError
    from ..scene import SceneError
    try:
        scene = run_star_app(app_dir, inputs, only_page=only_page, now=now)
        print(MARKER + json.dumps({"ok": True, "scene": scene}))
        return 0
    except SceneError as e:
        print(MARKER + json.dumps({"ok": False, "error": "; ".join(e.errors)}))
    except StarError as e:
        print(MARKER + json.dumps({"ok": False, "error": e.message}))
    except Exception as e:  # noqa: BLE001
        print(MARKER + json.dumps({"ok": False, "error": f"{type(e).__name__}: {e}"}))
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
