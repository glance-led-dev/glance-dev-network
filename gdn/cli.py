"""The `gdn` command-line interface.

    gdn new <name>       scaffold a new app folder from the example
    gdn preview [dir]    open the live LED preview (default: current folder)
    gdn studio [dir]     open the Studio: editor + live preview in one window
    gdn gifstudio [dir]  open the GIF Studio: turn PNGs into an animated .gif
    gdn build [dir]      render every page to PNG + .bin under build/
    gdn submit [dir]     validate, then open a pull request to publish the app
    gdn fonts            list the bundled bitmap fonts
    gdn version          print the version
"""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

from . import __version__, fonts, rgb565
from .runner import load_app, render_all

TEMPLATES = Path(__file__).resolve().parent / "templates"


def _slugify(name: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    return s or "my-app"


def _git_author() -> str:
    try:
        r = subprocess.run(["git", "config", "user.name"], capture_output=True,
                           text=True, timeout=3)
        return r.stdout.strip() or "your-name"
    except Exception:  # noqa: BLE001
        return "your-name"


def _personalize(dest: Path) -> None:
    """Fill the scaffolded manifest's id/name/author from the folder name + git, so
    a new app doesn't ship as `weather-ticker` / `your-name` (a real catalog clash)."""
    mf = dest / "manifest.yaml"
    if not mf.exists():
        return
    app_id = _slugify(dest.name)
    title = dest.name.replace("-", " ").replace("_", " ").strip().title() or app_id
    text = mf.read_text(encoding="utf-8")
    text = re.sub(r"(?m)^id:\s*.*$", f"id: {app_id}", text, count=1)
    text = re.sub(r"(?m)^name:\s*.*$", f"name: {title}", text, count=1)
    text = re.sub(r"(?m)^author:\s*.*$", f"author: {_git_author()}", text, count=1)
    mf.write_text(text, encoding="utf-8", newline="\n")


def cmd_new(args) -> int:
    tmpl = TEMPLATES / ("example" if getattr(args, "python", False) else "example-star")
    dest = Path(args.name).resolve()
    if dest.exists() and any(dest.iterdir()):
        print(f"error: {dest} already exists and is not empty", file=sys.stderr)
        return 1
    shutil.copytree(tmpl, dest, dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
    _personalize(dest)
    print(f"Created {dest}")
    p = args.name
    print("\nNext:")
    print(f"  1. Edit the drawing:   {p}/app.star")
    print(f"  2. See it live:        gdn studio {p}")
    print(f"  3. Check it renders:   gdn validate {p}")
    return 0


def cmd_generate(args) -> int:
    from .yaml_generator import launch
    return launch()


def cmd_check(args) -> int:
    from .check import run
    if getattr(args, "all", False):
        base = Path("apps")
        dirs = (sorted(p for p in base.iterdir() if (p / "manifest.yaml").exists())
                if base.is_dir() else [])
    else:
        dirs = [Path(args.dir)]
    if not dirs:
        print("no apps to check", file=sys.stderr)
        return 1
    return run(dirs)


def cmd_preview(args) -> int:
    from .preview import serve
    serve(Path(args.dir).resolve(), port=args.port, open_browser=not args.no_open)
    return 0


def cmd_studio(args) -> int:
    from .studio import serve
    serve(Path(args.dir).resolve(), port=args.port, open_browser=not args.no_open)
    return 0


def cmd_gifstudio(args) -> int:
    from .studio_gif import serve
    serve(args.dir, port=args.port, open_browser=not args.no_open)
    return 0


def _parse_now(s):
    """Parse an ISO datetime string (YYYY-MM-DD or with THH:MM) for --now, or None."""
    if not s:
        return None
    import datetime
    try:
        dt = datetime.datetime.fromisoformat(s)
        return dt.replace(tzinfo=datetime.timezone.utc) if dt.tzinfo is None else dt
    except ValueError:
        print(f"warning: --now {s!r} is not ISO (YYYY-MM-DD[THH:MM]); ignoring", file=sys.stderr)
        return None


def cmd_build(args) -> int:
    app_dir = Path(args.dir).resolve()
    out = Path(args.out).resolve() if args.out else app_dir / "build"
    out.mkdir(parents=True, exist_ok=True)

    inputs = {}
    for pair in args.input or []:
        if "=" in pair:
            k, v = pair.split("=", 1)
            inputs[k.strip()] = v
    if (app_dir / "app.star").exists():
        from .starhost import run_star_app
        from .scene import render_scene
        canvases = render_scene(run_star_app(app_dir, inputs, now=_parse_now(getattr(args, "now", None))),
                                asset_dir=app_dir)
    else:
        canvases = render_all(load_app(app_dir), inputs=inputs, asset_dir=app_dir)

    for name, c in canvases.items():
        png = out / f"{name}.png"
        binf = out / f"{name}.bin"
        c.save_png(png)
        rgb565.export_bin(c.img, binf)
        print(f"  {name:12s} {c.width}x{c.height}  {png.name}  {binf.name} "
              f"({binf.stat().st_size} bytes)")
    print(f"Built {len(canvases)} page(s) -> {out}")
    if rgb565._ENCODER is None:
        print("note: .bin is raw RGB565 (production RLE encoder not wired in yet).")
    return 0


def cmd_render(args) -> int:
    app_dir = Path(args.dir).resolve()
    if not (app_dir / "app.star").exists():
        print("error: `gdn render --page` is for Starlark (.star) apps", file=sys.stderr)
        return 1
    from .starhost import run_star_app_sandboxed, esp_endpoint, app_page_count
    from .scene import render_scene
    inputs = {}
    for pair in args.input or []:
        if "=" in pair:
            k, v = pair.split("=", 1)
            inputs[k.strip()] = v
    # sandboxed: mirrors what the render server does, and can't hang on a bad app
    scene = run_star_app_sandboxed(app_dir, inputs, only_page=args.page,
                                   now=_parse_now(getattr(args, "now", None)))
    canvases = render_scene(scene, asset_dir=app_dir)
    name, canvas = next(iter(canvases.items()))
    out = Path(args.out).resolve() if args.out else app_dir / "build" / f"page{args.page}.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save_png(out)
    print(f"page {args.page}/{app_page_count(app_dir)} ({name}) -> {out}")
    print(f"descriptor: {esp_endpoint(app_dir)}")
    return 0


def cmd_translate(args) -> int:
    import re as _re
    src_path = Path(args.file)
    if not src_path.exists():
        print(f"error: {src_path} not found", file=sys.stderr)
        return 1
    src = src_path.read_text(encoding="utf-8", errors="replace")
    app_id = args.id or _re.sub(r"[^a-z0-9]+", "-", src_path.stem.lower()).strip("-") or "ported-app"
    from .translate import translate_pixlet
    manifest, appstar, report = translate_pixlet(src, app_id, width=args.width)
    out = Path(args.out).resolve() if args.out else Path(app_id).resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "manifest.yaml").write_text(manifest, encoding="utf-8")
    (out / "app.star").write_text(appstar, encoding="utf-8")
    print(f"Scaffolded GDN app -> {out}")
    print(f"  inputs converted from schema: {report['inputs'] or 'none'}")
    print(f"  render widgets to port by hand: {', '.join(sorted(report['widgets'])) or 'none'}")
    if report["flags"]:
        print(f"  needs attention: {'; '.join(sorted(report['flags']))}")
    print("Open app.star — the original Pixlet code is kept as a reference comment with a")
    print("per-widget conversion checklist. Rewrite the render tree with c.*, then `gdn preview`.")
    return 0


def cmd_validate(args) -> int:
    from .starhost import run_star_app_sandboxed, StarError, StarTimeout, app_page_count
    from .scene import render_scene, SceneError
    if args.all:
        base = Path("apps")
        targets = sorted((p for p in base.iterdir() if (p / "app.star").exists())) if base.is_dir() else []
    else:
        targets = [Path(args.dir)]
    if not targets:
        print("no apps to validate", file=sys.stderr)
        return 1
    fails = 0
    for d in targets:
        d = d.resolve()
        if not (d / "app.star").exists():
            print(f"SKIP {d.name}: no app.star")
            continue
        try:
            pages = max(1, app_page_count(d))
            for pg in range(1, pages + 1):
                scene = run_star_app_sandboxed(d, {}, only_page=pg,
                                               now=_parse_now(getattr(args, "now", None)))
                render_scene(scene, asset_dir=d)   # full render == full validation
            print(f"PASS {d.name}  ({pages} page{'s' if pages != 1 else ''})")
        except (StarError, StarTimeout, SceneError) as e:
            msg = getattr(e, "message", None) or "; ".join(getattr(e, "errors", []) or [str(e)])
            print(f"FAIL {d.name}: {msg}")
            fails += 1
    print()
    if fails:
        print(f"{fails} app(s) failed validation.", file=sys.stderr)
        return 1
    print(f"All {len(targets)} app(s) valid.")
    return 0


def cmd_submit(args) -> int:
    from .submit import submit_via_fork, SubmitError, UPSTREAM
    d = Path(args.dir).resolve()
    if not (d / "app.star").exists():
        print(f"error: {d} has no app.star", file=sys.stderr)
        return 1
    # Validate first, the same check CI and the render service run.
    rc = cmd_validate(argparse.Namespace(all=False, dir=str(d), now=None))
    if rc != 0:
        print("Fix the validation errors above before submitting.", file=sys.stderr)
        return rc
    # Publishing creates a fork (if needed) and pushes with your GitHub sign-in.
    print(f"\nThis will publish '{d.name}': make sure you have a fork of {UPSTREAM},")
    print("push your app to it, and open a pull request, using your GitHub sign-in.")
    if not getattr(args, "yes", False):
        try:
            if input("Continue? [y/N] ").strip().lower() not in ("y", "yes"):
                print("Cancelled.")
                return 1
        except EOFError:
            print("Cancelled (no confirmation).", file=sys.stderr)
            return 1
    try:
        info = submit_via_fork(d, log=lambda m: print(f"  {m}"))
    except SubmitError as e:
        print(f"\n{e}", file=sys.stderr)
        return 1
    if info.get("created_fork"):
        print(f"\nCreated your fork {info['fork']}.")
    print(f"\nOpened your pull request:\n  {info['pr_url']}")
    try:
        import webbrowser
        webbrowser.open(info["pr_url"])
    except Exception:  # noqa: BLE001
        pass
    return 0


def cmd_fonts(args) -> int:
    names = fonts.list_fonts()
    print(f"{len(names)} bundled fonts:\n")
    for n in names:
        print(f"  {n:16s} h={fonts.font_height(n):2d}  ({len(fonts.get_glyphs(n))} glyphs)")
    return 0


def cmd_version(args) -> int:
    print(f"gdn {__version__}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="gdn", description="Glance Developer Network SDK")
    sub = p.add_subparsers(dest="cmd", required=True)

    n = sub.add_parser("new", help="scaffold a new app folder")
    n.add_argument("name", help="folder name for the new app")
    n.add_argument("--python", action="store_true",
                   help="scaffold the Python (trusted-path) template instead of Starlark")
    n.set_defaults(func=cmd_new)

    g = sub.add_parser("generate", help="open the manifest.yaml generator (GUI)")
    g.set_defaults(func=cmd_generate)

    ch = sub.add_parser("check", help="lint an app's manifest + app.star before publishing")
    ch.add_argument("dir", nargs="?", default=".", help="app folder (default: .)")
    ch.add_argument("--all", action="store_true", help="check every app under apps/")
    ch.set_defaults(func=cmd_check)

    pv = sub.add_parser("preview", help="live LED preview")
    pv.add_argument("dir", nargs="?", default=".", help="app folder (default: .)")
    pv.add_argument("--port", type=int, default=8765)
    pv.add_argument("--no-open", action="store_true", help="don't open a browser")
    pv.set_defaults(func=cmd_preview)

    st = sub.add_parser("studio", help="editor + preview GUI")
    st.add_argument("dir", nargs="?", default=".", help="app folder (default: .)")
    st.add_argument("--port", type=int, default=8766)
    st.add_argument("--no-open", action="store_true", help="don't open a browser")
    st.set_defaults(func=cmd_studio)

    gs = sub.add_parser("gifstudio", help="animated-GIF maker GUI (saves to gifs/)")
    gs.add_argument("dir", nargs="?", default=".", help="project folder (default: current)")
    gs.add_argument("--port", type=int, default=8767)
    gs.add_argument("--no-open", action="store_true", help="don't open a browser")
    gs.set_defaults(func=cmd_gifstudio)

    b = sub.add_parser("build", help="render pages to PNG + .bin")
    b.add_argument("dir", nargs="?", default=".", help="app folder (default: .)")
    b.add_argument("--out", default=None, help="output dir (default: <dir>/build)")
    b.add_argument("--input", action="append", metavar="KEY=VALUE",
                   help="set an input (repeatable)")
    b.add_argument("--now", default=None, metavar="ISO",
                   help="render as if it were this time, e.g. 2027-12-31T23:59")
    b.set_defaults(func=cmd_build)

    r = sub.add_parser("render", help="render ONE page to PNG (what the render server calls)")
    r.add_argument("dir", nargs="?", default=".", help="app folder (default: .)")
    r.add_argument("--page", type=int, default=1, help="1-based page number")
    r.add_argument("--input", action="append", metavar="KEY=VALUE", help="set an input (repeatable)")
    r.add_argument("--out", default=None, help="output PNG path")
    r.add_argument("--now", default=None, metavar="ISO",
                   help="render as if it were this time, e.g. 2027-12-31T23:59")
    r.set_defaults(func=cmd_render)

    t = sub.add_parser("translate", help="scaffold a GDN app from a Pixlet/tronbyt .star")
    t.add_argument("file", help="path to the Pixlet app .star file")
    t.add_argument("--out", default=None, help="output folder (default: ./<id>)")
    t.add_argument("--id", default=None, help="app id (default: from filename)")
    t.add_argument("--width", type=int, default=64, help="canvas width (Pixlet is 64; up to 384)")
    t.set_defaults(func=cmd_translate)

    va = sub.add_parser("validate", help="check that app(s) render + pass the safety validator")
    va.add_argument("dir", nargs="?", default=".", help="app folder (default: .)")
    va.add_argument("--all", action="store_true", help="validate every app under apps/")
    va.add_argument("--now", default=None, metavar="ISO",
                    help="validate as if it were this time, e.g. 2027-12-31T23:59")
    va.set_defaults(func=cmd_validate)

    su = sub.add_parser("submit", help="validate an app, then open a pull request to publish it")
    su.add_argument("dir", help="the app folder, e.g. apps/my-app")
    su.add_argument("-y", "--yes", action="store_true", help="skip the confirmation prompt")
    su.set_defaults(func=cmd_submit)

    f = sub.add_parser("fonts", help="list bundled bitmap fonts")
    f.set_defaults(func=cmd_fonts)

    v = sub.add_parser("version", help="print version")
    v.set_defaults(func=cmd_version)
    return p


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
