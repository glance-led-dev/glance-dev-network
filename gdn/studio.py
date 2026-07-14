"""GDN Studio, a local web GUI: code editor + live LED preview, side by side.

The Studio edits the *same files on disk* (`app.star` / `app.py`, `manifest.yaml`)
that you'd open in VS Code, it's a convenience layer, never a walled garden. Save
in the Studio and the file changes on disk; edit in VS Code and hit Reload here.
Files are always the source of truth.

Routes (all bound to localhost):
    GET  /            the Studio page
    GET  /apps        list the apps in the apps/ folder (for the app picker)
    GET  /files       read an app's editable files (+ which ones are missing)
    POST /files       save edited files (writes restricted to the editable names)
    POST /new         scaffold a brand-new app folder (Create New App button)
    POST /starter     write a starter file into an app that's missing one
    GET  /frames.json render every page of the app (the live preview)
    GET  /validate    render-check + lint the app, with plain-language results
    POST /submit      validate, create a fork if needed, push the app, open a pull request
"""
from __future__ import annotations

# Let this file be launched directly, a double-click, `python studio.py`, or
# `python -m studio`, even though it lives inside the gdn package and imports its
# siblings. Run that way __package__ is empty and the relative imports below would
# fail, so re-enter through the real CLI (which resolves the package) and exit. This
# means every way a person might try to start it just works, instead of erroring.
if __name__ == "__main__" and not __package__:
    import os
    import sys
    _root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if _root not in sys.path:
        sys.path.insert(0, _root)
    try:
        from gdn.cli import main
    except ImportError:
        raise SystemExit(
            "Couldn't find the gdn package. Open Studio with:  gdn studio\n"
            "(run it from the project folder, the one that contains apps/).")
    raise SystemExit(main(["studio", *sys.argv[1:]]))

import html
import json
import re
import shutil
import webbrowser
from pathlib import Path

from .preview import render_frames

# The only files the Studio will ever read or write inside an app folder.
EDITABLE = ("app.star", "app.py", "manifest.yaml")

# Files a valid app must have; offered as one-click starters when missing.
REQUIRED = ("app.star", "manifest.yaml")


# The setting types the Create New App wizard offers, and how each maps onto a
# manifest input. Anything not in here falls back to a plain text box.
_NEW_SETTING_TYPES = {"free-text", "number", "dropdown", "selection",
                      "checkbox", "date", "date-past", "color"}


def _new_setting_yaml(i, spec):
    """One manifest input block for a starter setting the user picked in the wizard,
    with a sensible starter default for its type."""
    w = str(spec.get("type") or spec.get("app_input_type") or "free-text").strip().lower()
    if w not in _NEW_SETTING_TYPES:
        w = "free-text"
    label = str(spec.get("label") or "").strip() or f"Setting {i}"
    dtype = "choice" if w in ("dropdown", "selection") else ("number" if w == "number" else "string")
    rows = [f"  - key: setting_{i}",
            f"    type: {dtype}",
            f"    app_input_type: {w}",
            f"    label: {json.dumps(label)}"]   # json.dumps -> an always-valid YAML scalar
    if w in ("dropdown", "selection"):
        rows += ["    choices: [Option 1, Option 2, Option 3]", "    default: Option 1"]
    elif w == "checkbox":
        rows.append("    default: false")
    elif w == "number":
        rows.append("    default: 0")
    elif w == "color":
        rows.append('    default: "#00ff00"')
    else:  # free-text, date, date-past
        rows.append('    default: ""')
    return rows


# ============================================================================
# Toolbox: a font browser + a drawing-helper inventory. Each helper's preview is
# rendered from the EXACT snippet it inserts, so the picture can never drift from
# the code. (group, name, description, snippet, placeholder, preview_override)
# ============================================================================
_TOOLBOX_HELPERS = [
    ("Text", "c.text", "A line of text",
     'c.text("TEXT", 2, 12, font="6x8", color="white")', "TEXT", None),
    ("Text", "c.text_center", "Text centered left to right",
     'c.text_center("TITLE", 2, font="6x8", color="green")', "TITLE", None),
    ("Text", "c.text_right", "Text pinned to the right edge",
     'c.text_right("99", 2, font="6x8", color="white")', "99", None),
    ("Text", "c.text_stroke", "Text with an outline",
     'c.text_stroke("BOLD", 2, 12, font="6x8", color="white", stroke="black")', "BOLD", None),
    ("Text", "c.text_wrapped", "Text that wraps to a width",
     'c.text_wrapped("A LONGER MESSAGE", 2, 2, 60, font="5x7", color="white")', None, None),
    ("Text", "c.text_fit", "The biggest font that fits",
     'c.text_fit("BIG", 2, 6, ["16x20", "10x16", "8x12", "6x8"], color="white")', "BIG", None),

    ("Shapes & lines", "c.rect", "A rectangle, filled or outlined",
     'c.rect(2, 2, 40, 20, fill="green")', None, None),
    ("Shapes & lines", "c.round_rect", "A rounded rectangle",
     'c.round_rect(2, 2, 40, 22, 3, outline="green")', None, None),
    ("Shapes & lines", "c.line", "A straight line",
     'c.line(2, 2, 60, 28, "green")', None, None),
    ("Shapes & lines", "c.circle", "A circle outline",
     'c.circle(16, 16, 12, "green")', None, None),
    ("Shapes & lines", "c.fill_circle", "A filled circle",
     'c.fill_circle(16, 16, 12, "green")', None, None),
    ("Shapes & lines", "c.fill_triangle", "A filled triangle",
     'c.fill_triangle(2, 28, 32, 2, 60, 28, "green")', None, None),
    ("Shapes & lines", "c.gradient_rect", "A color gradient box",
     'c.gradient_rect(2, 2, 60, 28, "blue", "green")', None, None),
    ("Shapes & lines", "c.fill", "Fill the whole panel a color",
     'c.fill("black")', None, 'c.fill("green")'),

    ("Charts & data", "c.progress_bar", "A progress bar, 0 to 100",
     'c.progress_bar(2, 24, 60, 6, 65, color="green", border="gray")', "65", None),
    ("Charts & data", "c.bars", "A mini bar chart of a list",
     'c.bars([3, 7, 4, 9, 6, 8], 2, 8, 40, 20, color="green")', None, None),
    ("Charts & data", "c.sparkline", "A mini line chart of a list",
     'c.sparkline([3, 5, 2, 8, 6, 9, 7], 2, 8, 56, 18, color="green")', None, None),
    ("Charts & data", "c.gauge", "A semicircle dial, 0 to 100",
     'c.gauge(30, 26, 16, 72, color="green", label="72%")', "72", None),
    ("Charts & data", "c.trend_arrow", "An up, down, or flat arrow",
     'c.trend_arrow(4, 4, "up")', None, 'c.trend_arrow(28, 12, "up", color="green")'),
    ("Charts & data", "c.stat", "A big number with a label",
     'c.stat("128", "SCORE", 2, 2)', "128", None),
    ("Charts & data", "c.kv", "A label and value row",
     'c.kv(2, 4, "WIND", "8 MPH", w=60, dots="darkgray")', None, None),
    ("Charts & data", "c.table", "Rows and columns of text",
     'c.table([["TEAM", "PTS"], ["NYK", "112"], ["BOS", "104"]], 2, 2, w=60)', None, None),

    ("Widgets", "c.badge", "A filled pill label",
     'c.badge("LIVE", 2, 2, bg="red", color="white")', "LIVE", None),
    ("Widgets", "c.header", "A title bar across the top",
     'c.header("MY APP", bg="green", icon="star")', "MY APP", None),
    ("Widgets", "c.status_dot", "A colored status dot",
     'c.status_dot(6, 6, "ok", label="ONLINE")', "ONLINE", None),
    ("Widgets", "c.scoreboard", "A two-team score layout",
     'c.scoreboard("NYK", "BOS", 112, 104, status="FINAL")', None, None),

    ("Images & art", "c.image", "Draw a PNG from your app",
     'c.image("logo.png", 2, 2)', "logo.png",
     'c.round_rect(2, 2, 44, 28, 2, outline="gray")\nc.icon("sun", 18, 10, color="amber", scale=2)'),
    ("Images & art", "c.icon", "A built-in icon",
     'c.icon("heart", 2, 2, color="red", scale=2)', "heart",
     'c.icon("heart", 24, 8, color="red", scale=2)'),
    ("Images & art", "c.sprite", "Tiny pixel art from text",
     'c.sprite(".X.\\nXXX\\n.X.", 2, 2, color="green", scale=3)', None,
     'c.sprite(".X.\\nXXX\\n.X.", 24, 8, color="green", scale=4)'),
    ("Images & art", "c.bitmap", "Pixel art from a grid of 0s and 1s",
     'c.bitmap([[0,1,0],[1,1,1],[0,1,0]], 2, 2, "green")', None,
     'c.bitmap([[0,1,0],[1,1,1],[0,1,0]], 26, 12, "green")'),

    ("Layout", "c.grid", "Split the panel into even cells",
     'cells = c.grid(2, 1, pad=1)', None,
     'for g in c.grid(3, 2, pad=2):\n    c.rect(g["x0"], g["y0"], g["x1"], g["y1"], outline="green")'),
]

# Plain-language name for each argument, shown on hover and dropped in as a comment so
# people can see what every number and value means.
_TOOLBOX_ARGS = {
    "c.text": "text, x, y, font, color",
    "c.text_center": "text, y (top), font, color",
    "c.text_right": "text, y (top), font, color",
    "c.text_stroke": "text, x, y, font, color, outline color",
    "c.text_wrapped": "text, x, y, width, font, color",
    "c.text_fit": "text, x, y, fonts to try (biggest first), color",
    "c.rect": "left, top, right, bottom, fill color",
    "c.round_rect": "left, top, right, bottom, corner radius, outline color",
    "c.line": "x1, y1, x2, y2, color",
    "c.circle": "center x, center y, radius, color",
    "c.fill_circle": "center x, center y, radius, color",
    "c.fill_triangle": "x1, y1, x2, y2, x3, y3, color",
    "c.gradient_rect": "left, top, right, bottom, start color, end color",
    "c.fill": "color",
    "c.progress_bar": "x, y, width, height, percent (0-100), color, border color",
    "c.bars": "list of values, x, y, width, height, color",
    "c.sparkline": "list of values, x, y, width, height, color",
    "c.gauge": "center x, base y, radius, percent (0-100), color, label",
    "c.trend_arrow": "x, y, direction (up/down/flat)",
    "c.stat": "big value, small label, x, y",
    "c.kv": "x, y, label, value, width, dotted-leader color",
    "c.table": "rows (list of columns), x, y, width",
    "c.badge": "text, x, y, background color, text color",
    "c.header": "title, background color, icon name",
    "c.status_dot": "x, y, status (ok/warn/error), label",
    "c.scoreboard": "home team, away team, home score, away score, status",
    "c.image": "file name, x, y (top-left)",
    "c.icon": "icon name, x, y, color, scale",
    "c.sprite": "pixel-art text, x, y, color, scale",
    "c.bitmap": "grid of 0s and 1s, x, y, color",
    "c.grid": "columns, rows, padding",
}
_toolbox_cache = None


def _toolbox_payload():
    """Build (once, then cache) the toolbox data: a preview data-URI for every helper
    snippet and every font. The snippets are our own constant strings, never user input,
    so exec-ing them to render the preview is safe and keeps preview == inserted code."""
    global _toolbox_cache
    if _toolbox_cache is not None:
        return _toolbox_cache
    from .canvas import Canvas
    from .fonts import list_fonts, get_glyphs, font_height, text_width
    from .preview import _data_uri

    helpers = []
    for group, name, desc, snippet, ph, override in _TOOLBOX_HELPERS:
        c = Canvas(64, 32)
        try:
            exec(override or snippet, {"c": c})
        except Exception:  # noqa: BLE001
            pass
        helpers.append({"group": group, "name": name, "desc": desc, "snippet": snippet,
                        "ph": ph, "args": _TOOLBOX_ARGS.get(name, ""),
                        "img": _data_uri(c.to_png_bytes())})

    fonts = []
    for fname in list_fonts():
        g = get_glyphs(fname)
        sample = "".join(ch for ch in "ABC abc 0123" if g.get(ch)) or "".join(sorted(g)[:8]) or "?"
        h = max(1, int(font_height(fname)))
        w = max(1, int(text_width(fname, sample)))
        c = Canvas(w + 2, h + 2)
        try:
            c.text(sample, 1, 1, font=fname, color="white")
        except Exception:  # noqa: BLE001
            pass
        fonts.append({"name": fname, "h": h, "letters": bool(g.get("A")),
                      "img": _data_uri(c.to_png_bytes()), "iw": w + 2, "ih": h + 2})

    from .draw_helpers import _load_icons
    icons = []
    for iname, matrix in sorted(_load_icons().items()):
        if not matrix or not matrix[0]:
            continue
        ih, iw = len(matrix), len(matrix[0])
        s = 3 if max(iw, ih) <= 10 else 2
        c = Canvas(iw * s, ih * s)
        try:
            c.icon(iname, 0, 0, color="white", scale=s)
        except Exception:  # noqa: BLE001
            pass
        icons.append({"name": iname, "img": _data_uri(c.to_png_bytes()), "iw": iw * s, "ih": ih * s})

    from .colors import NAMED
    colors = [{"name": n, "hex": "#%02x%02x%02x" % tuple(NAMED[n][:3])} for n in sorted(NAMED)]

    _toolbox_cache = {"helpers": helpers, "fonts": fonts, "icons": icons, "colors": colors}
    return _toolbox_cache


def _scaffold_new_app(dest, slug, name, width, category, settings):
    """Write a fresh, working starter app tailored to the Create New App dialog: the
    chosen panel width, its category, and a list of starter settings (each a
    {"type", "label"} the user picked). Always starts from a working example so the
    new app renders on the very first Save, never a blank page."""
    dest.mkdir(parents=True, exist_ok=True)
    try:
        from .cli import _git_author
        author = _git_author() or "your-name"
    except Exception:  # noqa: BLE001
        author = "your-name"

    inputs = ""
    if settings:
        rows = ["inputs:"]
        for i, spec in enumerate(settings, start=1):
            rows += _new_setting_yaml(i, spec)
        inputs = "\n".join(rows) + "\n"

    (dest / "manifest.yaml").write_text(
        "gdn: 1\n"
        f"id: {slug}\n"
        "version: 0.1.0\n"
        # json.dumps -> a double-quoted scalar that's always valid YAML, so a name
        # or git author with a colon, '#', or quote in it can't corrupt the file.
        f"name: {json.dumps(name)}\n"
        f"author: {json.dumps(author)}\n"
        "description: A new Glance app.\n"
        f"category: {category}\n"
        "entry: app.star\n"
        f"width: {width}\n"
        "height: 32\n"
        "refresh: 300\n"
        "pages: [main]\n"
        + inputs, encoding="utf-8")

    title = "".join(ch for ch in name.upper() if ch not in '"\\')[:18] or "HELLO"
    lines = [
        f"# {name}: a new Glance app. Edit me!",
        "",
        "def main(c, ctx):",
        '    c.fill("black")',
        f'    c.text_center("{title}", 2, font="6x8", color="green")',
    ]
    if settings:
        lines += ['    msg = ctx.inputs.get("setting_1", "")',
                  "    if msg:",
                  '        c.text_center(str(msg).upper(), 16, font="5x7", color="white")']
    else:
        lines += ['    c.text_center("HELLO", 16, font="5x7", color="white")']
    (dest / "app.star").write_text("\n".join(lines) + "\n", encoding="utf-8")
    (dest / ".gitignore").write_text("build/\n*.gdnapp\n", encoding="utf-8")


# ============================================================================
# Styling, matches the GDN brand: dark, LED-green (#00FF00), Montserrat.
# ============================================================================
_CSS = """
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap');
:root {
  color-scheme: dark;
  --bg: #0a0d0c; --surface: #111614; --surface2: #0c100e;
  --border: #1c2420; --border2: #2a352e;
  --green: #00ff00; --green-soft: #2bff6e; --green-dark: #00220a;
  --text: #e6e9e7; --muted: #a7b0ab; --dim: #828d87;
  --red: #ff9a9a; --red-bg: #1a0f10; --red-border: #5a2530;
}
* { box-sizing: border-box; }
html, body { height: 100%; margin: 0; }
body { font: 13.5px/1.5 'Montserrat', system-ui, -apple-system, sans-serif;
       background: var(--bg); color: var(--text);
       display: flex; flex-direction: column; }
kbd { font: 600 10.5px 'JetBrains Mono', ui-monospace, Consolas, monospace;
      background: rgba(0,0,0,.28); border-radius: 4px; padding: 1px 5px; margin-left: 6px; }

/* ---- header -------------------------------------------------------- */
header { display: flex; align-items: center; gap: 12px; padding: 10px 16px;
         border-bottom: 1px solid rgba(0,255,0,.14); background: #0b0e0d; flex-wrap: wrap; }
.brand { display: flex; align-items: center; gap: 9px; font-weight: 800;
         font-size: 15px; letter-spacing: -.2px; }
.brand .dot { width: 11px; height: 11px; border-radius: 3px; background: var(--green);
              box-shadow: 0 0 14px rgba(0,255,0,.55); }
.applbl { display: flex; align-items: center; gap: 7px; font-size: 12px; color: var(--muted); }
select { padding: 6px 10px; border-radius: 8px; background: var(--surface);
         color: var(--text); border: 1px solid var(--border2); font: inherit;
         font-size: 12.5px; max-width: 230px; cursor: pointer; }
#appsel { padding: 6px 10px; border-radius: 8px; background: var(--surface); color: var(--text); border: 1px solid var(--border2); font: inherit; font-size: 12.5px; width: 205px; }
#appsel::placeholder { color: var(--dim); }
.appwrap { position: relative; display: inline-block; }
.appmenu { position: absolute; top: calc(100% + 4px); left: 0; z-index: 50; min-width: 205px; max-height: 320px; overflow-y: auto; background: var(--surface); border: 1px solid var(--border2); border-radius: 8px; padding: 4px; box-shadow: 0 12px 30px rgba(0,0,0,.5); }
.appitem { padding: 6px 9px; border-radius: 6px; font-size: 12.5px; color: var(--text); cursor: pointer; white-space: nowrap; }
.appitem:hover { background: var(--green-dark); color: var(--green-soft); }
.appitem.cur { color: var(--green-soft); }
.appitem.sel { background: var(--green-dark); color: var(--green-soft); }
.appmenu .none { padding: 6px 9px; color: var(--dim); font-size: 12px; }
button { padding: 7px 13px; border: 1px solid transparent; border-radius: 8px;
         font: inherit; font-size: 12.5px; font-weight: 600; cursor: pointer; white-space: nowrap; }
button.accent { background: var(--green); color: var(--green-dark); font-weight: 700;
                box-shadow: 0 0 16px rgba(0,255,0,.22); }
button.accent:hover { background: var(--green-soft); }
button.ghost { background: transparent; color: #cfd7d2; border-color: var(--border2); }
button.ghost:hover { border-color: rgba(43,255,110,.5); color: var(--green-soft); }
button.small { padding: 3px 10px; font-size: 12px; }
#tbxbtn { display: inline-flex; align-items: center; gap: 6px; background: var(--green-dark);
          color: var(--green-soft); border-color: rgba(43,255,110,.45); font-weight: 700; }
#tbxbtn:hover { background: rgba(0,255,0,.12); border-color: var(--green-soft); }
#tbxbtn kbd { margin-left: 2px; }
.tbxwrap { position: relative; }
.coach { position: absolute; top: calc(100% + 10px); left: 0; width: 250px; z-index: 30;
         background: var(--surface); border: 1px solid rgba(43,255,110,.45); border-radius: 10px;
         padding: 12px 14px; font-size: 12.5px; line-height: 1.5; color: var(--muted);
         box-shadow: 0 12px 30px rgba(0,0,0,.5), 0 0 20px rgba(0,255,0,.08); }
.coach b { display: block; color: var(--text); margin-bottom: 3px; }
.coach::before { content: ""; position: absolute; top: -6px; left: 26px; width: 10px; height: 10px;
                 background: var(--surface); transform: rotate(45deg);
                 border-left: 1px solid rgba(43,255,110,.45); border-top: 1px solid rgba(43,255,110,.45); }
.coach-btns { display: flex; gap: 8px; margin-top: 10px; }
#save { min-width: 172px; display: inline-flex; align-items: center; justify-content: center; }
.modal .mlabel { display: block; font-size: 12px; color: var(--muted); margin: 0 0 5px; }
.modal .mfull, .modal select { width: 100%; }
.card-head { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-bottom: 4px; }
.spacer { flex: 1; }
.status { font-size: 12px; color: var(--muted); padding: 5px 12px; border-radius: 999px;
          border: 1px solid var(--border); background: var(--surface2); max-width: 40vw;
          overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.status.ok  { color: var(--green-soft); border-color: rgba(43,255,110,.4); background: rgba(0,255,0,.07); }
.status.bad { color: var(--red); border-color: var(--red-border); }

/* ---- two panes ------------------------------------------------------ */
main { flex: 1; display: flex; min-height: 0; }
.left, .right { min-width: 0; display: flex; flex-direction: column; }
.left { flex: 1; min-width: 480px; }
.right { flex: 1.35; }
.left { border-right: 1px solid var(--border); }
.pane-head { display: flex; align-items: center; gap: 8px; padding: 8px 12px;
             border-bottom: 1px solid var(--border); background: #0b0e0d; flex-wrap: wrap; }
/* slim editor toolbar: the Toolbox + Reload live here so the top row (tabs + Save) never wraps */
.edbar { display: flex; align-items: center; gap: 10px; padding: 6px 12px;
         border-bottom: 1px solid var(--border); background: #0b0e0d; }
.edbar-hint { font-size: 11.5px; color: var(--dim); min-width: 0;
              overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

/* editor tabs: which file you're looking at */
.tabs { display: flex; gap: 4px; }
.tab { padding: 5px 12px; border-radius: 8px; font-size: 12.5px; cursor: pointer;
       color: var(--muted); border: 1px solid transparent; }
.tab:hover { color: var(--text); background: rgba(255,255,255,.03); }
.tab .sub { display: block; font-size: 10.5px; color: var(--dim); font-weight: 500; }
.tab.active { background: var(--surface); color: var(--text); border-color: var(--border2); }
.tab.active .sub { color: var(--green-soft); }
.tab.missing { opacity: .7; }

/* the "this file is missing" helper banner */
.banner { display: flex; align-items: center; gap: 10px; padding: 9px 14px;
          background: rgba(0,255,0,.05); border-bottom: 1px solid var(--border);
          font-size: 12.5px; color: var(--muted); flex-wrap: wrap; }
.banner b { color: var(--text); }
.banner button { padding: 5px 11px; font-size: 12px; }

/* the editor: a transparent textarea over a color-highlighted <pre> twin. Every metric
   that affects where a glyph lands MUST be identical on both, or the caret drifts. */
.edwrap { position: relative; flex: 1; min-height: 0; background: var(--surface2); }
#ed, #edhl { position: absolute; inset: 0; margin: 0; border: 0; box-sizing: border-box;
             padding: 14px 16px;
             font: 13px/1.55 'JetBrains Mono', ui-monospace, Consolas, monospace;
             font-variant-ligatures: none; letter-spacing: normal; tab-size: 4;
             white-space: pre-wrap; overflow-wrap: break-word; word-break: normal;
             direction: ltr; text-align: left; scrollbar-gutter: stable; }
#ed { z-index: 1; width: 100%; height: 100%; resize: none; outline: 0; overflow: auto;
      padding: 14px 16px 14px 68px;            /* 16 base + 46 gutter + 6 code gap = matches .hlc */
      background: transparent; color: transparent; caret-color: #d9e0dc;
      -webkit-text-fill-color: transparent; }
#ed::selection { background: rgba(0,255,0,.20); color: transparent; -webkit-text-fill-color: transparent; }
#edhl { z-index: 0; overflow: hidden; pointer-events: none; user-select: none; color: #d9e0dc; }
.hlrow { display: flex; }                     /* one row per source line, so numbers track wrapping */
.gutn { flex: 0 0 46px; box-sizing: border-box; padding-right: 12px; text-align: right;
        color: #566b60; user-select: none; border-right: 1px solid var(--border); }
.hlc { flex: 1 1 auto; min-width: 0; padding-left: 6px;
       white-space: pre-wrap; overflow-wrap: break-word; word-break: normal; }
.tk-str  { color: #9fe0b0; }                 /* strings, brand-console green */
.tk-com  { color: var(--dim); }              /* comments, dim */
.tk-kw   { color: #e8d48a; }                 /* def / if / for / return */
.tk-num  { color: #8ecdf5; }                 /* numbers */
.tk-call { color: var(--green-soft); }       /* c.text(...) calls pop in green */
.tk-fn   { color: #cdb4f8; }                 /* other calls: main(, len( */
.tk-key  { color: var(--green-soft); }       /* YAML keys */
#edhl .sq { text-decoration: underline wavy #ff5555; text-decoration-thickness: 1px;
            text-decoration-skip-ink: none; text-underline-offset: 3px; }  /* error squiggle */
.pane-foot.haslint { color: var(--red); }
.fixbtn { margin-left: 8px; padding: 1px 8px; font: 600 11px 'Montserrat', sans-serif;
          background: var(--green-dark); color: var(--green-soft); vertical-align: middle;
          border: 1px solid rgba(43,255,110,.45); border-radius: 6px; cursor: pointer; }
.fixbtn:hover { background: rgba(0,255,0,.12); }
/* autocomplete popup (optional) */
.acmenu { position: absolute; z-index: 12; min-width: 200px; max-width: 340px; max-height: 220px;
          overflow-y: auto; background: var(--surface); border: 1px solid var(--border2);
          border-radius: 8px; padding: 4px; box-shadow: 0 12px 30px rgba(0,0,0,.5);
          font: 12.5px 'JetBrains Mono', ui-monospace, monospace; }
.acit { display: flex; align-items: center; gap: 8px; padding: 4px 8px; border-radius: 6px;
        color: var(--text); cursor: pointer; white-space: nowrap; }
.acit.sel { background: var(--surface2); color: var(--green-soft); }
.acit .achint { margin-left: auto; color: var(--dim); font-size: 11px; padding-left: 14px; }
.acit .acsw { width: 12px; height: 12px; border-radius: 3px; border: 1px solid var(--border2); flex: 0 0 auto; }
body.dropping::after { content: "Drop your PNG to add it to this app"; position: fixed; inset: 0;
  z-index: 60; display: flex; align-items: center; justify-content: center;
  font: 700 18px 'Montserrat', sans-serif; color: var(--green-soft);
  background: rgba(0,20,5,.72); border: 3px dashed rgba(43,255,110,.6); pointer-events: none; }
/* pixel-art sprite editor */
.modal.spr { width: 480px; max-width: 92vw; }
.modal.spr h2 { margin: 0 0 4px; font-size: 18px; }
.sprsub { color: var(--muted); font-size: 12.5px; margin: 0 0 10px; }
.spr-toolbar { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin: 8px 0; }
.spr-pal { display: flex; flex-wrap: wrap; gap: 4px; }
.spr-sw { width: 20px; height: 20px; border-radius: 4px; border: 1px solid var(--border2); cursor: pointer; padding: 0; }
.spr-sw.sel { outline: 2px solid var(--green); outline-offset: 1px; }
.spr-sw.erase { background: repeating-linear-gradient(45deg,#333 0 4px,#111 4px 8px); }
#sprcanvas { display: block; margin: 8px auto; image-rendering: pixelated; background: #000;
  border: 1px solid var(--border2); border-radius: 6px; cursor: crosshair; touch-action: none; }
.pane-foot { padding: 6px 14px; border-top: 1px solid var(--border);
             font-size: 11.5px; color: var(--dim); }

/* ---- right pane: the live preview ----------------------------------- */
.right { background: #090b0a; }
.rhead { justify-content: flex-start; }
.ptitle { font-size: 12px; text-transform: uppercase; letter-spacing: .9px;
          color: var(--muted); font-weight: 700; }
.toggle { display: inline-flex; align-items: center; gap: 6px; font-size: 12px;
          color: var(--muted); cursor: pointer; }
.toggle input[type=checkbox] { accent-color: var(--green); }
.rhead input[type=datetime-local] { background: var(--surface2); color: var(--text);
       border: 1px solid var(--border2); border-radius: 6px; padding: 3px 6px;
       font: inherit; font-size: 12px; }
.coords { margin-left: auto; font: 600 11.5px 'JetBrains Mono', ui-monospace, monospace;
          color: var(--dim); white-space: nowrap; }
.coords.live { color: var(--green-soft); }
.rbody { flex: 1; overflow: auto; padding: 16px; position: relative; }
.sp { display: inline-block; width: 14px; height: 14px; border: 2px solid rgba(0,255,0,.25); border-top-color: var(--green); border-radius: 50%; animation: gspin .7s linear infinite; vertical-align: -2px; }
@keyframes gspin { to { transform: rotate(360deg); } }
.busy { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; gap: 10px; background: rgba(8,12,14,.6); color: #dfefe0; font-weight: 600; z-index: 6; }
button.accent.working { opacity: .9; cursor: progress; }
button.accent .sp { border-color: rgba(0,0,0,.3); border-top-color: #0b0f14; }
.rhint { font-size: 12px; color: var(--dim); margin: 0 0 14px; }

/* cards: inputs form + console */
.card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px;
        padding: 14px 16px; margin-bottom: 16px; }
.card-title { font-size: 11.5px; text-transform: uppercase; letter-spacing: .8px;
              color: var(--muted); font-weight: 700; margin-bottom: 2px; }
.card-hint { font-size: 11.5px; color: var(--dim); margin-bottom: 10px; }
.inputs { display: flex; flex-wrap: wrap; gap: 14px; }
.inputs .f { display: flex; flex-direction: column; gap: 4px; min-width: 130px; }
.inputs label { font-size: 11.5px; color: var(--muted); font-weight: 600; }
.inputs .help { font-size: 11.5px; color: var(--dim); max-width: 210px; }
.inputs input, .inputs select { padding: 6px 9px; border-radius: 7px;
       border: 1px solid var(--border2); background: var(--surface2); color: var(--text);
       font: inherit; font-size: 12.5px; }
.inputs input[type=color] { padding: 2px; width: 60px; height: 30px; }
.inputs input[type=checkbox] { width: 17px; height: 17px; accent-color: var(--green); }

/* each rendered page of the app */
.panel { margin-bottom: 20px; }
.panel .h { display: flex; gap: 10px; align-items: baseline; margin-bottom: 10px; }
.panel .h .name { font-weight: 700; font-size: 14px; }
.panel .h .dims { color: var(--muted); font-size: 12px; letter-spacing: .3px;
                  font-family: 'JetBrains Mono', ui-monospace, Consolas, monospace; }
.editimg { margin-left: 6px; padding: 2px 10px; font: 600 11px 'Montserrat', sans-serif;
           border-radius: 6px; border: 1px solid var(--border2); background: transparent;
           color: var(--muted); cursor: pointer; align-self: center; }
.editimg:hover { border-color: rgba(43,255,110,.5); color: var(--green-soft); }
.editimg.active { background: var(--green); color: var(--green-dark); border-color: var(--green);
                  box-shadow: 0 0 10px rgba(0,255,0,.25); }
.screen-wrap { overflow-x: auto; display: flex; justify-content: safe center; padding: 16px; border-radius: 12px;
        background: radial-gradient(120% 140% at 50% 0%, #131714 0%, #090b0a 100%);
        border: 1px solid var(--border); }
.screen { position: relative; display: inline-block; line-height: 0; border-radius: 3px;
          box-shadow: 0 0 40px rgba(0,255,0,.10); }
.screen img { image-rendering: pixelated; display: block; }
.screen.grid::after { content: ""; position: absolute; inset: 0; pointer-events: none;
   background-image: linear-gradient(to right, rgba(0,0,0,.34) 1px, transparent 1px),
     linear-gradient(to bottom, rgba(0,0,0,.34) 1px, transparent 1px);
   background-size: var(--cell) var(--cell); mix-blend-mode: multiply; }

/* draggable image-placement boxes, one per c.image() call.
   Outline (not border) so the box never shifts the geometry; the PNG ghost paints
   only while actually dragging, so a selected image is never drawn on top of itself. */
.imgbox { position: absolute; box-sizing: border-box; cursor: move; z-index: 5;
          outline: 1px dashed rgba(0,255,0,.6); outline-offset: -1px;
          background-size: 100% 100%; background-repeat: no-repeat; image-rendering: pixelated;
          background-image: none; opacity: 0; transition: opacity .1s; touch-action: none; }
.placing .imgbox { opacity: .6; }                                /* visible outline while the tool is open */
.imgbox:hover, .imgbox.sel { opacity: 1; }                       /* full outline on hover/select */
.imgbox.sel { outline-style: solid; outline-color: var(--green); }
.imgbox.drag { opacity: 1; outline-style: solid; outline-color: var(--green);
               background-image: var(--img); }                   /* show the PNG only while dragging */
.imgbox.locked { cursor: default; outline-color: rgba(255,255,255,.35); }
.imgbox::after { content: ""; position: absolute; inset: -6px; }   /* fat hit area for tiny sprites */
.imgbox .rz { position: absolute; right: -5px; bottom: -5px; width: 10px; height: 10px;
              background: var(--green); border: 1px solid #04210b; border-radius: 2px;
              cursor: nwse-resize; display: none; z-index: 2; }
.imgbox.sel .rz { display: block; }
.imgbox .imgx { position: absolute; top: -9px; right: -9px; width: 16px; height: 16px; z-index: 3;
                display: none; align-items: center; justify-content: center; cursor: pointer;
                background: var(--red-border); color: #fff; border-radius: 50%; font-size: 12px; line-height: 1; }
.imgbox.sel .imgx { display: flex; }
.pngpicks { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }

/* ---- Toolbox: font browser + helper inventory ---------------------- */
.modal.tbx { width: 820px; max-width: 94vw; height: min(620px, 88vh); padding: 0;
             display: flex; flex-direction: column; overflow: hidden; }
.tbx-head { display: flex; align-items: center; gap: 10px; padding: 12px 16px;
            border-bottom: 1px solid var(--border2); }
.tbx-title { font-weight: 800; font-size: 15px; }
.tbx-tabs { display: flex; gap: 4px; margin-left: 6px; }
.tbx-tab { padding: 4px 12px; border-radius: 8px; font: 600 12.5px 'Montserrat', sans-serif;
           border: 1px solid transparent; background: transparent; color: var(--muted); cursor: pointer; }
.tbx-tab:hover { color: var(--text); }
.tbx-tab.active { background: var(--surface2); color: var(--green-soft); border-color: var(--border2); }
.tbxdocs { padding: 4px 11px; border-radius: 8px; border: 1px solid var(--border2); color: #cfd7d2;
           font: 600 12px 'Montserrat', sans-serif; text-decoration: none; }
.tbxdocs:hover { border-color: rgba(43,255,110,.5); color: var(--green-soft); }
.tbx-body { flex: 1; overflow-y: auto; padding: 14px 16px; }
.tbx-loading { color: var(--dim); padding: 24px; text-align: center; }
.tbx-group { font-size: 11px; text-transform: uppercase; letter-spacing: .8px; color: var(--muted);
             font-weight: 700; margin: 16px 0 8px; }
.tbx-group:first-child { margin-top: 0; }
.tbx-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 10px; }
.tbx-tile { display: flex; flex-direction: column; gap: 4px; padding: 8px; text-align: left;
            background: var(--surface2); border: 1px solid var(--border2); border-radius: 10px; cursor: pointer; }
.tbx-tile:hover { border-color: rgba(43,255,110,.55); }
.tbx-tile img { width: 100%; height: 62px; object-fit: contain; background: #000; border-radius: 6px;
                image-rendering: pixelated; }
.tbx-tile .nm { font: 600 12px 'JetBrains Mono', ui-monospace, monospace; color: var(--green-soft); }
.tbx-tile .ds { font-size: 11px; color: var(--dim); }
.tbx-foot { padding: 9px 16px; border-top: 1px solid var(--border2); background: var(--surface2);
            font: 12px/1.4 'JetBrains Mono', ui-monospace, monospace; color: #cfe9d2;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tbx-frow { display: flex; align-items: center; gap: 12px; padding: 7px 6px; border-radius: 8px; cursor: pointer; }
.tbx-frow:hover { background: var(--surface2); }
.tbx-frow .fname { flex: 0 0 128px; font: 600 12px 'JetBrains Mono', ui-monospace, monospace; color: var(--text); }
.tbx-frow .fprev { flex: 1; min-width: 0; display: flex; align-items: center; gap: 10px; }
.tbx-frow .fprev img { background: #000; image-rendering: pixelated; border-radius: 4px; }
.tbx-frow .ftag { font-size: 10.5px; color: var(--dim); }
.tbx-frow .fchip { flex: 0 0 auto; font: 600 11px 'JetBrains Mono', ui-monospace, monospace; }

/* errors + console text */
.err { white-space: pre-wrap; font-family: 'JetBrains Mono', ui-monospace, monospace;
       font-size: 12px; color: var(--red); background: var(--red-bg);
       border: 1px solid var(--red-border); border-radius: 10px; padding: 14px; }
.err::before { content: "Something went wrong, here's the message:"; display: block;
       font-family: 'Montserrat', sans-serif; font-weight: 700; color: #ffc2c2;
       margin-bottom: 8px; }
#console { margin: 0; color: #9fe0b0; white-space: pre-wrap; max-height: 190px;
           overflow: auto; font: 12px/1.55 'JetBrains Mono', ui-monospace, monospace; }
#console .prob { color: var(--red); }
#console .tip { color: #e8d48a; }

/* ---- Create-New-App modal ------------------------------------------- */
.overlay { position: fixed; inset: 0; background: rgba(0,0,0,.62); display: flex;
           align-items: center; justify-content: center; z-index: 40; }
.modal { width: 420px; max-width: 92vw; max-height: 90vh; overflow-y: auto;
         background: var(--surface);
         border: 1px solid var(--border2); border-radius: 14px; padding: 22px 24px;
         box-shadow: 0 24px 70px rgba(0,0,0,.6), 0 0 0 1px rgba(0,255,0,.08); }
.modal h2 { margin: 0 0 6px; font-size: 16px; font-weight: 800; }
.modal p { margin: 0 0 14px; font-size: 12.5px; color: var(--muted); }
.modal input { width: 100%; padding: 9px 11px; border-radius: 8px; font: inherit;
         border: 1px solid var(--border2); background: var(--surface2); color: var(--text); }
.modal .slug { font: 11.5px 'JetBrains Mono', monospace; color: var(--green-soft);
         margin: 8px 0 0; min-height: 16px; }
.modal .mErr { font-size: 12px; color: var(--red); margin: 6px 0 0; min-height: 16px; }
.modal-btns { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
.modal .mhint { font-size: 11.5px; color: var(--dim); margin: 0 0 8px; }
.newsettings { display: flex; flex-direction: column; gap: 6px; margin: 0 0 8px; }
.setrow { display: flex; gap: 6px; align-items: center; }
.modal .setrow select { flex: 0 0 128px; width: auto; }
.modal .setrow input { flex: 1 1 auto; width: auto; min-width: 0; }
.setrow .setremove { flex: 0 0 auto; padding: 4px 10px; }

/* ---- Publish (Validate & Submit) modal ------------------------------ */
.modal ol.pubsteps { margin: 0 0 12px; padding-left: 20px; font-size: 12.5px;
         color: var(--muted); line-height: 1.5; }
.modal ol.pubsteps li { margin: 5px 0; }
.modal ol.pubsteps b { color: var(--text); font-weight: 700; }
.pubnote { font-size: 12px; color: var(--dim); margin: 0 0 12px; }
.pubagree { display: flex; gap: 9px; align-items: flex-start; font-size: 12.5px;
         color: var(--text); cursor: pointer; padding: 10px 12px; border-radius: 9px;
         border: 1px solid var(--border2); background: var(--surface2); }
.pubagree input { width: 16px; height: 16px; margin: 1px 0 0; flex: 0 0 auto;
         accent-color: var(--green); cursor: pointer; }
.pubprogress { font: 12px/1.5 'JetBrains Mono', ui-monospace, monospace;
         color: var(--green-soft); margin: 12px 0 0; display: flex; align-items: center; gap: 8px; }
.pubprogress .pubok { color: var(--green-soft); }
.pubprogress .pubok a { color: var(--green); text-decoration: underline; }
.importprev { max-width: 100%; image-rendering: pixelated; background: #000;
         border: 1px solid var(--border2); border-radius: 6px; padding: 6px; margin: 0 0 6px; display: block; }
[hidden] { display: none !important; }
"""


# ============================================================================
# Frontend logic, vanilla JS, no build step.
# ============================================================================
_JS = r"""
let files = {};        // filename -> current editor content
let missing = [];      // filenames not on disk for the open app
let currentApp = null; // app folder name
let appList = [];      // every app in apps/ (for the searchable picker)
let activeTab = 'app.star';
let pristine = {};     // last saved/loaded copy of `files`, for unsaved-change checks
let loadSeq = 0;       // drops out-of-order /files responses when switching apps fast
let renderSeq = 0;     // drops out-of-order /frames.json responses (stale previews)
let _inT;              // debounce timer for live edits to the settings form

const esc = s => String(s).replace(/[&<>"']/g, c =>
  ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const $ = id => document.getElementById(id);
const appQS = () => currentApp ? 'app=' + encodeURIComponent(currentApp) : '';
const slugify = s => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'my-app';
// named colors -> hex, so a color setting whose default is "red" doesn't show black
const COLOR_HEX = {white:'#ffffff', black:'#000000', red:'#ff0000', green:'#00ff00',
  blue:'#0000ff', yellow:'#ffff00', cyan:'#00ffff', orange:'#ffa500', magenta:'#ff00ff'};
// Live edits fire on every keystroke; wait for a pause so we don't launch a render
// (a whole sandbox subprocess) per character and race their responses.
function debouncedRender() { clearTimeout(_inT); _inT = setTimeout(() => render(), 180); }
// Have the current editor contents drifted from what's on disk?
function isDirty() {
  files[activeTab] = $('ed').value;
  return Object.keys(files).some(f => (files[f] || '') !== (pristine[f] || ''));
}

/* ---- syntax highlighting: a small regex tokenizer that paints a <pre> behind the
   textarea (whose own text is transparent), so the code shows color like an editor.
   Strings/comments come first so a '#' inside a string is not read as a comment. ---- */
const _STAR_TOKS = [
  ['str',  String.raw`"{3}[\s\S]*?(?:"{3}|$)|'{3}[\s\S]*?(?:'{3}|$)|"(?:\\.|[^"\\\n])*(?:"|$)|'(?:\\.|[^'\\\n])*(?:'|$)`],
  ['com',  String.raw`#[^\n]*`],
  ['kw',   String.raw`\b(?:def|lambda|if|elif|else|for|in|not|and|or|return|break|continue|pass|load|True|False|None)\b`],
  ['num',  String.raw`\b0[xX][0-9a-fA-F]+\b|\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b`],
  ['call', String.raw`\b[A-Za-z_]\w*(?:\s*\.\s*[A-Za-z_]\w*)+(?=\s*\()`],
  ['fn',   String.raw`\b[A-Za-z_]\w*(?=\s*\()`],
];
const _YAML_TOKS = [
  ['str', String.raw`"(?:\\.|[^"\\\n])*(?:"|$)|'(?:''|[^'\n])*(?:'|$)`],
  ['com', String.raw`(?:^|[ \t])#[^\n]*`],
  ['key', String.raw`^[ \t]*(?:-[ \t]+)?[A-Za-z_][\w.-]*(?=:(?:[ \t]|$))`],
  ['kw',  String.raw`\b(?:true|false|yes|no|null)\b`],
  ['num', String.raw`(?<![\w."'#-])-?\d+(?:\.\d+)?(?![\w-])`],
];
function _mkHl(toks) {
  const re = new RegExp(toks.map(([, s]) => '(' + s + ')').join('|'), 'gm');
  return (src, markLine) => {
    let rows = '', buf = '', line = 1, last = 0, m; re.lastIndex = 0;
    const flush = () => {                          // close the current line into its own numbered row
      const code = (line === markLine && buf) ? '<span class="sq">' + buf + '</span>' : buf;
      rows += '<div class="hlrow"><span class="gutn">' + line + '</span><span class="hlc">' + code + '</span></div>';
      buf = '';
    };
    const emit = (text, cls) => {                  // split so no span (or squiggle) crosses a newline
      const parts = text.split('\n');
      for (let i = 0; i < parts.length; i++) {
        if (i) { flush(); line++; }
        if (parts[i]) buf += cls ? '<span class="tk-' + cls + '">' + esc(parts[i]) + '</span>' : esc(parts[i]);
      }
    };
    while ((m = re.exec(src))) {
      if (m.index > last) emit(src.slice(last, m.index));
      let cls = 'fn';
      for (let i = 0; i < toks.length; i++) if (m[i + 1] !== undefined) { cls = toks[i][0]; break; }
      emit(m[0], cls);
      last = re.lastIndex;
      if (m[0].length === 0) re.lastIndex++;
    }
    emit(src.slice(last));
    flush();                                       // the final line (may be empty)
    return rows;
  };
}
const hlStar = _mkHl(_STAR_TOKS), hlYaml = _mkHl(_YAML_TOKS);
function paintHl() {
  const ed = $('ed'), hl = $('edhl'); if (!hl) return;
  const src = ed.value;
  const mk = (activeTab === 'app.star' && lintMark) ? lintMark.line : 0;
  hl.innerHTML = activeTab === 'manifest.yaml' ? hlYaml(src, 0) : hlStar(src, mk);
  hl.scrollTop = ed.scrollTop; hl.scrollLeft = ed.scrollLeft;
}

/* ---- live syntax check: a red squiggle under the first error line in app.star ---- */
let lintErr = null, lintMark = null, _lintT = null, _lintSeq = 0, _lintLast = null;
function scheduleLint() { clearTimeout(_lintT); _lintT = setTimeout(lintNow, 500); }
async function lintNow() {
  if (activeTab !== 'app.star') { lintErr = null; applyLint(); return; }
  const text = $('ed').value;
  if (text === _lintLast) { applyLint(); return; }
  const seq = ++_lintSeq;
  let d;
  try { d = await (await fetch('lint', {method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({file: 'app.star', text})})).json(); }
  catch (e) { return; }                                    // Studio unreachable: stay silent
  if (seq !== _lintSeq || $('ed').value !== text) return;  // superseded by newer text
  _lintLast = text;
  lintErr = (d.errors && d.errors[0]) || null;
  applyLint();
}
function caretLine() { const ed = $('ed'); return ed.value.slice(0, ed.selectionStart).split('\n').length; }
function applyLint() {
  const show = (lintErr && caretLine() !== lintErr.line) ? lintErr : null;   // don't nag the line you're typing
  if ((show && show.line) !== (lintMark && lintMark.line)) { lintMark = show; paintHl(); }
  const foot = $('edfoot'); if (!foot) return;
  if (lintErr) {
    const fix = _fixLabel(lintErr);
    foot.innerHTML = 'Line ' + lintErr.line + ': ' + esc(lintErr.msg) +
      (fix ? ' <button class="fixbtn" id="fixbtn">' + esc(fix) + '</button>' : '');
    const fb = $('fixbtn'); if (fb) fb.addEventListener('click', applyQuickFix);
  } else {
    foot.textContent = 'These are the real files on your computer, edit them here or in any other program.';
  }
  foot.classList.toggle('haslint', !!lintErr);
}
// Offer a one-click fix for the errors beginners hit most (today: indentation).
function _fixLabel(err) { return /indent/i.test(err.msg || '') ? 'Fix indentation' : null; }
function applyQuickFix() {
  if (!lintErr || !/indent/i.test(lintErr.msg || '')) return;
  const ed = $('ed'), lineNo = lintErr.line, lines = ed.value.split('\n');
  if (lineNo < 1 || lineNo > lines.length) return;
  let prev = '';
  for (let j = lineNo - 2; j >= 0; j--) { if (lines[j].trim()) { prev = lines[j]; break; } }
  const prevIndent = (prev.match(/^[ \t]*/) || [''])[0].replace(/\t/g, '    ');
  const want = /:\s*$/.test(prev) ? prevIndent + '    ' : prevIndent;   // inside a block, else match it
  const cur = lines[lineNo - 1], fixed = want + cur.replace(/^[ \t]+/, '');
  if (fixed === cur) { setStatus('That line looks right, the problem may be the line above.', 'bad'); return; }
  const start = lines.slice(0, lineNo - 1).reduce((a, l) => a + l.length + 1, 0);
  ed.focus(); ed.setSelectionRange(start, start + cur.length);
  document.execCommand('insertText', false, fixed);   // splice via execCommand to keep undo
  scheduleLint();
  setStatus('Fixed the indentation on line ' + lineNo + '.', 'ok');
}

function setStatus(msg, cls) {
  const el = $('status');
  el.textContent = msg; el.title = msg;
  el.className = 'status' + (cls ? ' ' + cls : '');
}

/* ---- the app picker -------------------------------------------------- */
async function loadApps(selectName) {
  try {
    const d = await (await fetch('apps')).json();
    // ?app=<name> in the address bar deep-links straight to that app
    const urlApp = new URLSearchParams(location.search).get('app');
    if (!currentApp) currentApp = (urlApp && d.apps.includes(urlApp)) ? urlApp : d.current;
    if (selectName) currentApp = selectName;
    appList = d.apps || [];
    $('appsel').value = currentApp;
  } catch (e) { /* single-app fallback: the picker just stays empty */ }
}

/* searchable app picker: a filter box plus a dropdown of every app in apps/ */
function appMenuHTML(filter) {
  const f = (filter || '').toLowerCase();
  const items = appList.filter(a => a.toLowerCase().includes(f));
  if (!items.length) return '<div class="none">No matching app</div>';
  return items.map(a =>
    `<div class="appitem ${a === currentApp ? 'cur' : ''}" role="option" data-app="${esc(a)}">${esc(a)}</div>`).join('');
}
function openAppMenu(filter) { const m = $('appmenu'); m.innerHTML = appMenuHTML(filter); m.hidden = false; }
function closeAppMenu() { $('appmenu').hidden = true; }
function pickApp(name) {
  closeAppMenu();
  if (name && name !== currentApp && appList.includes(name)) {
    if (isDirty() && !confirm('You have unsaved changes that will be lost. Switch app anyway?')) {
      $('appsel').value = currentApp; return;
    }
    currentApp = name; $('appsel').value = name; rebuildInputs(); loadFiles();
  } else { $('appsel').value = currentApp; }
}

/* ---- Add a setting: writes the YAML into manifest.yaml for you -------- */
function openInputModal() {
  ['inkey', 'inlabel', 'indefault', 'inchoices'].forEach(id => $(id).value = '');
  $('intype').value = 'free-text';
  $('inchoicewrap').hidden = true;
  $('inerr').textContent = '';
  $('inputmodal').hidden = false;
  $('inkey').focus();
}
function closeInputModal() { $('inputmodal').hidden = true; const b = $('addinput'); if (b) b.focus(); }
function yamlVal(v) {
  // Wrap anything YAML would misread, colons, '#', brackets, quotes, leading or
  // trailing spaces, and bool/null look-alikes (yes/no/on/off), in a safe
  // double-quoted scalar. Backslashes and quotes inside are escaped, not deleted.
  v = String(v);
  if (v === '' || v !== v.trim() || /[:#\[\]{}",'&*!|>%@`]/.test(v)
      || /^[-?]\s/.test(v) || /^(true|false|yes|no|on|off|null|~)$/i.test(v))
    return '"' + v.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
  return v;
}
function addInput() {
  const key = $('inkey').value.trim();
  const label = $('inlabel').value.trim() || key;
  const w = $('intype').value;
  const def = $('indefault').value.trim();
  if (!key) { $('inerr').textContent = 'Give the setting a name first.'; return; }
  if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(key)) {
    $('inerr').textContent = 'Name must be letters, numbers, or _, and start with a letter.'; return; }
  let m = files['manifest.yaml'] || '';
  // key is validated above, so it's safe to build a RegExp from it.
  if (new RegExp('^\\s*-\\s*key:\\s*' + key + '\\s*$', 'm').test(m)) {
    $('inerr').textContent = 'There is already a setting called "' + key + '".'; return; }
  const type = (w === 'dropdown' || w === 'selection') ? 'choice' : (w === 'number' ? 'number' : 'string');
  let block = '  - key: ' + key + '\n    type: ' + type +
              '\n    app_input_type: ' + w + '\n    label: ' + yamlVal(label) + '\n';
  if (w === 'dropdown' || w === 'selection') {
    const list = $('inchoices').value.split(',').map(s => s.trim()).filter(Boolean);
    if (!list.length) { $('inerr').textContent = 'Add at least one choice.'; return; }
    block += '    choices: [' + list.map(yamlVal).join(', ') + ']\n';
  }
  if (def) block += '    default: ' + yamlVal(def) + '\n';

  const inputsLine = /^inputs:[ \t]*(#.*)?$/m;   // tolerate a trailing comment
  if (inputsLine.test(m)) {
    m = m.replace(/^inputs:[ \t]*(#.*)?\r?\n/m, mm => mm + block);   // add under the existing list
  } else {
    m = m.replace(/\s*$/, '') + '\n\ninputs:\n' + block;            // no inputs yet, start the list
  }
  files['manifest.yaml'] = m;
  closeInputModal();
  switchTab('manifest.yaml');   // show the YAML that was written
  $('ed').value = m;
  save();                       // save + re-render so the new control appears
}

/* ---- the editor ------------------------------------------------------ */
async function loadFiles() {
  const seq = ++loadSeq;
  $('save').disabled = true;   // no saving until we know which app's files we hold
  try {
    const d = await (await fetch('files?' + appQS())).json();
    // A newer switch superseded us, or the response is for a different app: drop it,
    // so app A's files can never be written into app B's folder.
    if (seq !== loadSeq || (d.app && d.app !== currentApp)) return;
    files = d.files || {};
    pristine = JSON.parse(JSON.stringify(files));   // the on-disk baseline
    missing = d.missing || [];
    selKey = null; for (const k in assetDims) delete assetDims[k];   // fresh app, fresh images
    lintErr = lintMark = _lintLast = null;                           // and a fresh lint state
    // Only show the app.py tab for apps that actually use it (Python apps).
    $('tab-py').hidden = missing.includes('app.py');
    activeTab = !missing.includes('app.star') ? 'app.star'
              : !missing.includes('app.py') ? 'app.py' : 'app.star';
    $('ed').value = files[activeTab] || '';
    paintTabs();
    paintBanner();
    $('inputs').innerHTML = '';   // fresh app: don't carry the last app's values over
    rebuildInputs();
    await render(true);
    refreshDiskMtime();
  } catch (e) {
    if (seq === loadSeq) setStatus('Couldn’t open this app. Is Studio still running?', 'bad');
  } finally {
    if (seq === loadSeq) $('save').disabled = false;
  }
}

/* ---- auto-reload when the files change on disk (edited in VS Code, git pull, etc.) ---- */
let _diskMtime = 0, _diskNagged = false;
async function refreshDiskMtime() {
  try { const d = await (await fetch('mtime?' + appQS())).json(); _diskMtime = d.mtime || 0; _diskNagged = false; }
  catch (e) {}
}
async function pollDisk() {
  if (document.hidden) return;
  let d; try { d = await (await fetch('mtime?' + appQS())).json(); } catch (e) { return; }
  if (!d.mtime) return;
  if (!_diskMtime) { _diskMtime = d.mtime; return; }
  if (d.mtime > _diskMtime + 0.001) {
    if (!isDirty()) { await loadFiles(); setStatus('Reloaded, the files changed on disk.', 'ok'); }
    else if (!_diskNagged) { _diskNagged = true;
      setStatus('Heads up, these files changed on disk. Reload to see them (loses unsaved edits).', 'bad'); }
  }
}
function paintTabs() {
  document.querySelectorAll('.tab').forEach(t => {
    t.classList.toggle('active', t.dataset.f === activeTab);
    t.classList.toggle('missing', missing.includes(t.dataset.f));
  });
}
function switchTab(name) {
  files[activeTab] = $('ed').value;   // stash edits before switching
  activeTab = name;
  lintErr = lintMark = _lintLast = null;   // don't carry one tab's squiggle onto another
  $('ed').value = files[name] || '';
  paintTabs();
}
/* If a required file is missing, offer to create a working starter for it.
   (Apps built on app.py don't need an app.star, so we don't nag about it.) */
function paintBanner() {
  const need = ['manifest.yaml', 'app.star'].filter(f => missing.includes(f))
    .filter(f => f !== 'app.star' || missing.includes('app.py'));
  const b = $('banner');
  if (!need.length) { b.hidden = true; b.innerHTML = ''; return; }
  const what = f => f === 'manifest.yaml' ? 'the settings file every app needs'
                                          : 'the code that draws the screen';
  b.innerHTML = need.map(f =>
    `<span>This app has no <b>${f}</b>, ${what(f)}.</span>
     <button class="accent" onclick="createStarter('${f}')">Create it for me</button>`
  ).join('');
  b.hidden = false;
}
async function createStarter(fname) {
  try {
    const r = await fetch('starter?' + appQS(), {
      method: 'POST', headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({file: fname})});
    const d = await r.json();
    if (!d.ok) { setStatus(d.error, 'bad'); return; }
    setStatus('Added a starter ' + fname + ', edit away', 'ok');
    await loadFiles();
  } catch (e) { setStatus('Couldn’t reach the Studio server.', 'bad'); }
}

/* ---- saving ---------------------------------------------------------- */
async function save() {
  const btn = $('save'), lbl = btn.innerHTML;
  btn.disabled = true; btn.classList.add('working');
  btn.innerHTML = '<span class="sp"></span> Rendering&hellip;';
  try {
    files[activeTab] = $('ed').value;
    // Write only what actually changed. This never litters the folder with empty
    // extras, and it won't stomp a file you edited in another program but didn't
    // touch here (that file still matches `pristine`, so we skip it).
    const out = {};
    for (const f in files) {
      const cur = files[f] || '', was = pristine[f] || '';
      if (cur === was) continue;                          // untouched, leave it alone
      if (missing.includes(f) && !cur.trim()) continue;   // don't create an empty file
      out[f] = files[f];
    }
    setStatus('Saving…');
    const r = await fetch('files?' + appQS(), {method: 'POST',
      headers: {'Content-Type': 'application/json'}, body: JSON.stringify(out)});
    const d = await r.json();
    setStatus(d.ok ? 'Saved ✓' : ('Couldn’t save: ' + d.error), d.ok ? 'ok' : 'bad');
    if (d.ok) refreshDiskMtime();   // our own save moved the mtime; don't flag it as external
    if (d.ok) {
      missing = missing.filter(f => !(f in out));
      pristine = JSON.parse(JSON.stringify(files));   // this is the new on-disk baseline
    } else {
      showCheckResults({problems: [d.error]});          // full message, the pill truncates it
    }
    paintBanner();
    rebuildInputs();   // the manifest may have changed the inputs
    await render(true);
  } catch (e) {
    setStatus('Couldn’t save. Is Studio still running?', 'bad');
  } finally {
    btn.disabled = false; btn.classList.remove('working'); btn.innerHTML = lbl;
  }
}

/* ---- checking (Validate / Validate & Merge) --------------------------- */
function showCheckResults(d) {
  const lines = [];
  (d.problems || []).forEach(p => lines.push('<span class="prob">✗ ' + esc(p) + '</span>'));
  (d.tips || []).forEach(t => lines.push('<span class="tip">• ' + esc(t) + '</span>'));
  if (lines.length) {
    $('console').innerHTML = lines.join('\n');
    $('consolecard').hidden = false;
  }
}
async function runCheck(url, btn) {
  const other = btn.id === 'validate' ? $('mergebtn') : $('validate');
  const lbl = btn.innerHTML;
  btn.disabled = true; other.disabled = true;   // a check can take a few seconds
  btn.innerHTML = '<span class="sp"></span> Checking&hellip;';
  setStatus('Checking…');
  try {
    const d = await (await fetch(url + '?' + appQS())).json();
    setStatus(d.message, d.ok ? 'ok' : 'bad');
    showCheckResults(d);
  } catch (e) {
    setStatus('Couldn’t run the check. Is Studio still running?', 'bad');
  } finally {
    btn.disabled = false; other.disabled = false; btn.innerHTML = lbl;
  }
}
function validate() { return runCheck('validate', $('validate')); }
/* ---- Publish (Validate & Submit): confirm, then fork + push + PR ----- */
function openSubmitModal() {
  $('pubslug').textContent = currentApp || 'your app';
  $('submitagree').checked = false;
  $('submitagree').disabled = false;
  $('submitgo').disabled = true;
  $('submitgo').textContent = 'Publish';
  $('submitgo').onclick = doSubmit;
  $('submitcancel').hidden = false;
  $('submitcancel').disabled = false;
  $('submiterr').textContent = '';
  $('pubprogress').hidden = true; $('pubprogress').innerHTML = '';
  $('submitmodal').hidden = false;
}
function closeSubmitModal() { $('submitmodal').hidden = true; }
async function doSubmit() {
  $('submitgo').disabled = true; $('submitcancel').disabled = true; $('submitagree').disabled = true;
  $('submiterr').textContent = '';
  $('pubprogress').hidden = false;
  $('pubprogress').innerHTML = '<span class="sp"></span> Publishing&hellip; creating your fork the first time can take a few seconds.';
  setStatus('Publishing…');
  try {
    const d = await (await fetch('submit?' + appQS(), { method: 'POST' })).json();
    if (d.ok) {
      const link = d.pr_url ? ' <a href="' + esc(d.pr_url) + '" target="_blank" rel="noopener">View it on GitHub &#8599;</a>' : '';
      $('pubprogress').innerHTML = '<span class="pubok">Your pull request is open.' + link + '</span>';
      setStatus(d.message, 'ok');
      $('submitgo').textContent = 'Done'; $('submitgo').disabled = false; $('submitgo').onclick = closeSubmitModal;
      $('submitcancel').hidden = true;
    } else {
      $('pubprogress').hidden = true;
      $('submiterr').textContent = d.message || 'Publishing didn’t finish.';
      setStatus(d.message || 'Publishing didn’t finish.', 'bad');
      showCheckResults(d);
      $('submitcancel').disabled = false; $('submitagree').disabled = false;
      $('submitgo').disabled = !$('submitagree').checked;
    }
  } catch (e) {
    $('pubprogress').hidden = true;
    $('submiterr').textContent = 'Couldn’t reach Studio. Is it still running?';
    $('submitcancel').disabled = false; $('submitagree').disabled = false; $('submitgo').disabled = false;
  }
}

/* Download each rendered page as a crisp (nearest-neighbor upscaled) PNG. */
function savePng() {
  const imgs = document.querySelectorAll('#panels .screen img');
  if (!imgs.length) { setStatus('Render your app first, then Save PNG.', 'bad'); return; }
  imgs.forEach((img, i) => {
    const w = img.naturalWidth, h = img.naturalHeight;
    if (!w) return;
    const scale = Math.max(4, Math.floor(1024 / w));
    const cv = document.createElement('canvas'); cv.width = w * scale; cv.height = h * scale;
    const ctx = cv.getContext('2d'); ctx.imageSmoothingEnabled = false;
    ctx.drawImage(img, 0, 0, w * scale, h * scale);
    const nm = ((img.closest('.panel') && img.closest('.panel').querySelector('.name')
                 && img.closest('.panel').querySelector('.name').textContent) || 'panel')
                 .replace(/[^a-z0-9]+/gi, '-').toLowerCase().replace(/^-|-$/g, '') || 'panel';
    const a = document.createElement('a');
    a.href = cv.toDataURL('image/png');
    a.download = (imgs.length > 1 ? nm + '-' + (i + 1) : nm) + '.png';
    document.body.appendChild(a); a.click(); a.remove();
  });
  setStatus('Saved PNG' + (imgs.length > 1 ? 's' : '') + ' to your downloads.', 'ok');
}

/* ---- the inputs form -------------------------------------------------- */
/* Builds one control per input in the manifest, matching its app_input_type. */
function widgetFor(i) {
  const w = (i.app_input_type || '').trim().toLowerCase();
  if (w) return w;
  if (i.type === 'choice' && i.choices) return 'dropdown';
  if (i.type === 'number') return 'number';
  return 'free-text';
}
function inputField(i) {
  const val = i.default == null ? '' : String(i.default);
  const w = widgetFor(i);
  const key = esc(i.key);
  const opts = () => (i.choices || []).map(c =>
    `<option ${String(c) === val ? 'selected' : ''}>${esc(String(c))}</option>`).join('');
  if ((w === 'dropdown' || w === 'selection') && i.choices)
    return `<select name="${key}" ${w === 'selection' ? 'multiple size="3"' : ''}>${opts()}</select>`;
  if (w === 'checkbox') {
    const on = ['1', 'true', 'yes', 'on'].includes(val.toLowerCase());
    return `<input type="checkbox" name="${key}" ${on ? 'checked' : ''}>`;
  }
  if (w === 'color') {
    // A color input only accepts #rrggbb; map a named default (red) to hex and
    // fall back to white so it never silently shows black.
    let cv = String(val).trim().toLowerCase();
    if (COLOR_HEX[cv]) cv = COLOR_HEX[cv];
    if (!/^#[0-9a-f]{6}$/i.test(cv)) cv = '#ffffff';
    return `<input type="color" name="${key}" value="${cv}">`;
  }
  if (w === 'date' || w === 'date-past') {
    const cap = w === 'date-past' ? ` max="${new Date().toISOString().slice(0, 10)}"` : '';
    return `<input type="date" name="${key}" value="${esc(val)}"${cap}>`;
  }
  if (w === 'number') return `<input type="number" name="${key}" value="${esc(val)}">`;
  return `<input type="text" name="${key}" value="${esc(val)}">`;
}
function buildInputs(schema) {
  const box = $('inputs');
  // Keep whatever the user typed into the preview form across a rebuild, so a Save
  // (or adding a setting) doesn't snap every field back to its manifest default.
  const prev = {};
  box.querySelectorAll('[name]').forEach(el => {
    prev[el.name] = el.type === 'checkbox' ? el.checked : el.value;
  });
  box.innerHTML = (schema || []).map(i =>
    `<div class="f"><label>${esc(i.label || i.key)}</label>${inputField(i)}
     ${i.help ? `<span class="help">${esc(i.help)}</span>` : ''}</div>`).join('')
    || '<div class="help">No settings yet. Use the "+ Add setting" button to make one.</div>';
  box.dataset.built = 'yes';
  $('inputscard').hidden = false;
  box.querySelectorAll('[name]').forEach(el => {
    if (el.name in prev && !el.multiple) {
      if (el.type === 'checkbox') el.checked = prev[el.name]; else el.value = prev[el.name];
    }
    el.addEventListener('input', debouncedRender);
  });
}
function inputsQS() {
  const qs = new URLSearchParams();
  document.querySelectorAll('#inputs [name]').forEach(el => {
    // Always send true or false. If we sent nothing when unchecked, the server
    // would fall back to the default and a default-on box could never be turned off.
    if (el.type === 'checkbox') { qs.set(el.name, el.checked ? 'true' : 'false'); return; }
    if (el.multiple) {
      const picked = [...el.selectedOptions].map(o => o.value).join(',');
      if (picked) qs.set(el.name, picked);
      return;
    }
    qs.set(el.name, el.value);
  });
  return qs.toString();
}
function rebuildInputs() { $('inputs').dataset.built = 'no'; }

/* ---- the live preview -------------------------------------------------- */
async function render(showBusy) {
  const seq = ++renderSeq;
  const busy = showBusy ? $('busy') : null;
  if (busy) busy.hidden = false;
  try {
  const parts = [inputsQS(), appQS()];
  const nowv = $('nowfld').value;
  if (nowv) parts.push('now=' + encodeURIComponent(nowv));
  let d;
  try {
    d = await (await fetch('frames.json?' + parts.filter(Boolean).join('&'))).json();
  } catch (e) {
    if (seq === renderSeq)
      $('panels').innerHTML = '<div class="err">Couldn’t reach the Studio server. Is it still running?</div>';
    return;
  }
  if (seq !== renderSeq) return;   // a newer render already superseded this one

  if ($('inputs').dataset.built !== 'yes') buildInputs(d.inputs);

  // print() output from the app goes to the console card
  const logs = d.logs || [];
  $('console').textContent = logs.join('\n');
  if (!logs.length) $('console').textContent = 'Nothing printed yet. Add a print(...) to your code and it shows up here.';
  $('consolecard').hidden = false;

  const panels = $('panels');
  if (!d.ok) { placeStructSig = ''; panels.innerHTML = `<div class="err">${esc(d.error)}</div>`; return; }
  const grid = $('grid').checked;
  const hasImg = parseImages(starText()).length > 0;      // only offer "Edit images" if a PNG is drawn
  const avail = Math.max(220, panels.clientWidth - 36);   // room inside the pane
  // Zoom each page as big as fits (2-16x) so the whole panel is always visible.
  const scales = d.pages.map(p => Math.max(2, Math.min(16, Math.floor(avail / p.w))));
  const sig = (grid ? 'g|' : '') + d.pages.map((p, i) => p.name + ':' + p.w + 'x' + p.h + '@' + scales[i]).join('|');
  const imgs = panels.querySelectorAll('.screen img');
  if (sig === placeStructSig && imgs.length === d.pages.length) {
    d.pages.forEach((p, i) => { imgs[i].src = p.dataUri; });   // same layout: swap pixels, keep the image boxes
  } else {
    placeStructSig = sig;
    panels.innerHTML = d.pages.map((p, i) => {
      const scale = scales[i], cls = grid ? 'screen grid' : 'screen';
      // The raw page-function name ("sign") means nothing to a user; only label a panel when
      // it has a real title, or when there are several pages to tell apart.
      const label = (p.title && p.title !== p.name) ? p.title : (d.pages.length > 1 ? p.name : '');
      return `<div class="panel"><div class="h">${label ? `<span class="name">${esc(label)}</span>` : ''}
        <span class="dims">${p.w}×${p.h} pixels</span></div>
        <div class="screen-wrap"><div class="${cls}" style="--cell:${scale}px" data-page="${esc(p.name)}">
          <img src="${p.dataUri}" width="${p.w * scale}" height="${p.h * scale}"></div></div></div>`;
    }).join('');
    wireHover();
  }
  updateEditButtons(hasImg);
  attachPlacer(d.pages);   // reconcile the draggable image boxes with the fresh render
  } finally { if (busy) busy.hidden = true; }
}
/* Point at the preview and the readout shows which pixel is under the mouse. */
function wireHover() {
  const co = $('coords');
  document.querySelectorAll('.screen img').forEach(img => {
    img.onmousemove = e => {
      const r = img.getBoundingClientRect();
      co.textContent = 'x ' + Math.floor((e.clientX - r.left) / r.width * img.naturalWidth) +
                       ', y ' + Math.floor((e.clientY - r.top) / r.height * img.naturalHeight);
      co.classList.add('live');
    };
    img.onmouseleave = () => { co.textContent = 'x, y'; co.classList.remove('live'); };
  });
}

/* ==== Place an image: drag a PNG on the panel, the c.image(...) code follows ====
   Fable-audited rewrite: write-back is one deterministic text splice (no execCommand,
   so it can't strand the caret or no-op on delete), boxes are reconciled rather than
   destroyed mid-drag, the save is immediate on release, and the image ghost shows only
   while actually dragging (outline the rest of the time). */
let placed = [];          // c.image(...) calls parsed out of the current app.star
let placedByKey = {};     // key -> call, so a drag always uses the freshest spans
let selKey = null;        // which image is selected (a "file#n" key)
let lastPages = [];       // page list from the last render
let placeActive = false;  // is the Place-image tool open?
let placeStructSig = '';  // signature of the preview layout, for in-place pixel swaps
const assetDims = {};     // "app/file" -> {w, h} natural pixel size, cached
let _placeDrag = null;    // in-flight drag state
let _placeSaveT = null;   // debounce timer for arrow-key nudges
let _rebuildPending = false;
let _saveBusy = false, _saveDirty = false;   // serialize saves: no out-of-order writes
let _placeUndo = [];      // app.star snapshots for Ctrl+Z on a box
const cssEsc = s => (window.CSS && CSS.escape) ? CSS.escape(s) : String(s).replace(/[^\w-]/g, '\\$&');

function starText() { return activeTab === 'app.star' ? $('ed').value : (files['app.star'] || ''); }
function setPlaced(list) { placed = list; placedByKey = {}; list.forEach(c => { placedByKey[c.key] = c; }); }

// Find every single-line c.image("file", x, y[, w=..][, h=..]) call and the exact
// character spans of its number arguments, so a drag can rewrite just those numbers.
function parseImages(text) {
  const list = [];
  const defRe = /^[ \t]*def[ \t]+([A-Za-z_]\w*)[ \t]*\(/gm;
  const defs = []; let dm;
  while ((dm = defRe.exec(text))) defs.push({name: dm[1], at: dm.index});
  const pageOf = at => { let n = null; for (const d of defs) { if (d.at < at) n = d.name; else break; } return n; };
  const callRe = /([A-Za-z_]\w*)\.image\(\s*(["'])([^"'\n]*?)\2\s*,([^()\n]*)\)/g;
  const counts = {}; let m;
  while ((m = callRe.exec(text))) {
    const lineStart = text.lastIndexOf('\n', m.index) + 1;
    if (text.slice(lineStart, m.index).indexOf('#') !== -1) continue;   // commented out
    const file = m[3], argsRaw = m[4];
    const argsStart = m.index + m[0].length - argsRaw.length - 1;
    const nums = {x: null, y: null, w: null, h: null};
    const spans = {x: null, y: null, w: null, h: null};
    let positional = 0, editable = true, pm;
    const partRe = /[^,]+/g;
    while ((pm = partRe.exec(argsRaw))) {
      const piece = pm[0];
      const kw = piece.match(/^\s*([wh])\s*=\s*(-?\d+)\s*$/);
      const pos = piece.match(/^\s*(-?\d+)\s*$/);
      if (kw) {
        const s = argsStart + pm.index + piece.indexOf(kw[2]);
        nums[kw[1]] = parseInt(kw[2], 10); spans[kw[1]] = [s, s + kw[2].length];
      } else if (pos) {
        const key = ['x', 'y', 'w', 'h'][positional];
        if (key) { const s = argsStart + pm.index + piece.indexOf(pos[1]);
          nums[key] = parseInt(pos[1], 10); spans[key] = [s, s + pos[1].length]; }
        positional++;
      } else { if (positional < 2) editable = false; positional++; }
    }
    if (nums.x === null || nums.y === null) editable = false;
    const ord = (counts[file] = (counts[file] || 0) + 1);
    list.push({key: file + '#' + ord, file, recv: m[1], x: nums.x, y: nums.y,
      w: nums.w, h: nums.h, spans, callStart: m.index, callEnd: m.index + m[0].length,
      closeParen: m.index + m[0].length - 1, page: pageOf(m.index), editable});
  }
  return list;
}

function spliceText(text, edits) {
  edits = edits.slice().sort((a, b) => b.start - a.start);   // right-to-left keeps spans valid
  for (const e of edits) text = text.slice(0, e.start) + e.str + text.slice(e.end);
  return text;
}

// Deterministic write-back: splice the text, assign it straight to the editor value.
// This fires no input event, never moves focus, and empty-string edits (delete) just
// work, unlike the old multi-span execCommand that stranded the caret and corrupted.
function commitImageEdits(edits, immediate) {
  if (!edits.length) return;
  const before = starText();
  const t = spliceText(before, edits);
  if (t === before) return;                 // no-op (e.g. a plain click): don't dirty or save
  _placeUndo.push(before); if (_placeUndo.length > 25) _placeUndo.shift();
  files['app.star'] = t;
  if (activeTab === 'app.star') {
    const ed = $('ed'), sc = ed.scrollTop, had = document.activeElement === ed, ss = ed.selectionStart;
    ed.value = t; ed.scrollTop = sc;
    if (had) ed.setSelectionRange(ss, ss);
  }
  setPlaced(parseImages(t));
  refreshBoxes();
  schedulePlacementSave(immediate);
}
function placeUndo() {
  if (!_placeUndo.length) return;
  const before = _placeUndo.pop();
  files['app.star'] = before;
  if (activeTab === 'app.star') { const ed = $('ed'), sc = ed.scrollTop; ed.value = before; ed.scrollTop = sc; }
  setPlaced(parseImages(before)); refreshBoxes(); schedulePlacementSave(true);
  setStatus('Undid the last image change.', 'ok');
}
function schedulePlacementSave(immediate) {
  clearTimeout(_placeSaveT);
  if (immediate) savePlacement(); else _placeSaveT = setTimeout(savePlacement, 300);
}
async function savePlacement() {
  if (_saveBusy) { _saveDirty = true; return; }    // serialize -> no out-of-order disk writes
  _saveBusy = true;
  try {
    const body = files['app.star'];
    const r = await fetch('files?' + appQS(), {method: 'POST',
      headers: {'Content-Type': 'application/json'}, body: JSON.stringify({'app.star': body})});
    const d = await r.json();
    if (!d.ok) setStatus('Couldn’t save the move: ' + d.error, 'bad');
    else { pristine['app.star'] = body; await render(false); }   // quiet render, no busy overlay
  } catch (e) { setStatus('Couldn’t save the move. Is Studio running?', 'bad'); }
  finally { _saveBusy = false; if (_saveDirty) { _saveDirty = false; savePlacement(); } }
}

/* ---- the draggable overlay boxes ---- */
function screenFor(page) {
  const s = [...document.querySelectorAll('#panels .screen')];
  return s.find(x => x.dataset.page === page) || s[0] || null;
}
function scaleOf(scr) { return parseInt((scr.style.getPropertyValue('--cell') || '1').replace('px', ''), 10) || 1; }
function panelDims(scr) { const i = scr.querySelector('img'); return {w: i ? i.naturalWidth : 64, h: i ? i.naturalHeight : 32}; }
function effSize(call) {
  const d = assetDims[currentApp + '/' + call.file];
  return {w: call.w != null ? call.w : (d ? d.w : 16), h: call.h != null ? call.h : (d ? d.h : 16)};
}
function positionBox(box, call, scr) {
  const s = scaleOf(scr), z = effSize(call);
  box.style.left = (call.x * s) + 'px'; box.style.top = (call.y * s) + 'px';
  box.style.width = (z.w * s) + 'px'; box.style.height = (z.h * s) + 'px';
}
function createBox(call, scr) {
  const box = document.createElement('div');
  box.className = 'imgbox' + (call.editable ? '' : ' locked');
  box.tabIndex = 0; box.dataset.key = call.key; box._call = call;
  box.style.setProperty('--img', `url(asset?${appQS()}&file=${encodeURIComponent(call.file)})`);
  const rz = document.createElement('div'); rz.className = 'rz'; box.appendChild(rz);
  const x = document.createElement('div'); x.className = 'imgx'; x.textContent = '×'; x.title = 'Remove'; box.appendChild(x);
  positionBox(box, call, scr); scr.appendChild(box); wireBox(box);
  const dk = currentApp + '/' + call.file;
  if ((call.w == null || call.h == null) && !assetDims[dk]) {
    const probe = new Image();
    probe.onload = () => { assetDims[dk] = {w: probe.naturalWidth, h: probe.naturalHeight};
      const c2 = placedByKey[box.dataset.key]; if (box.isConnected && c2) positionBox(box, c2, box.closest('.screen')); };
    probe.src = 'asset?' + appQS() + '&file=' + encodeURIComponent(call.file);
  }
  return box;
}
function clearBoxes() { document.querySelectorAll('.imgbox').forEach(b => b.remove()); }
// Reconcile boxes with the parsed calls WITHOUT destroying nodes, so focus and an
// in-flight drag survive. A full clear+recreate only happens when a structural render
// rebuilt the screens under us.
function refreshBoxes() {
  if (!placeActive) { clearBoxes(); return; }
  if (_placeDrag) { _rebuildPending = true; return; }   // never disturb an active drag
  const have = {};
  document.querySelectorAll('.imgbox').forEach(b => { have[b.dataset.key] = b; });
  Object.keys(have).forEach(k => { if (!placedByKey[k]) have[k].remove(); });
  placed.forEach(call => {
    const scr = screenFor(call.page);
    const box = have[call.key];
    if (!scr) { if (box) box.remove(); return; }
    if (!box) createBox(call, scr);
    else { if (box.closest('.screen') !== scr) scr.appendChild(box);
           box._call = call; box.classList.toggle('locked', !call.editable); positionBox(box, call, scr); }
  });
  applySelection();
}
function applySelection() {
  document.querySelectorAll('.imgbox.sel').forEach(b => b.classList.remove('sel'));
  if (!selKey) return;
  const b = document.querySelector('.imgbox[data-key="' + cssEsc(selKey) + '"]');
  if (!b) return;
  b.classList.add('sel');
  const ae = document.activeElement;
  if (ae && ae.classList && ae.classList.contains('imgbox')) b.focus({preventScroll: true});
}
function attachPlacer(pages) {
  if (pages) lastPages = pages;
  setPlaced(parseImages(starText()));
  refreshBoxes();
}
function showPlaceCoord(d) {
  const co = $('coords'); co.classList.add('live');
  const call = placedByKey[d.key] || {file: ''};
  co.textContent = call.file + '  x ' + d.nx + ', y ' + d.ny + (d.mode === 'resize' ? '  ' + d.nw + '×' + d.nh : '');
}
function wireBox(box) {
  box.addEventListener('pointerdown', e => {
    const call = placedByKey[box.dataset.key]; if (!call) return;
    selKey = call.key; applySelection();
    if (e.target.classList.contains('imgx')) { deleteImage(call); return; }
    if (!call.editable) { revealImage(call); return; }
    e.preventDefault();
    try { box.setPointerCapture(e.pointerId); } catch (_) {}
    box.focus({preventScroll: true});
    const scr = box.closest('.screen'), dims = panelDims(scr), z = effSize(call);
    _placeDrag = {key: call.key, box, scale: scaleOf(scr),
      mode: e.target.classList.contains('rz') ? 'resize' : 'move',
      cx: e.clientX, cy: e.clientY, x0: call.x, y0: call.y, w0: z.w, h0: z.h,
      pw: dims.w, ph: dims.h, nx: call.x, ny: call.y, nw: z.w, nh: z.h, moved: false};
    box.classList.add('drag');
  });
  box.addEventListener('pointermove', e => {
    const d = _placeDrag; if (!d || d.box !== box) return;
    const dx = Math.round((e.clientX - d.cx) / d.scale), dy = Math.round((e.clientY - d.cy) / d.scale);
    if (!d.moved && dx === 0 && dy === 0) return;
    if (d.mode === 'move') {
      d.nx = Math.max(0, Math.min(Math.max(0, d.pw - d.w0), d.x0 + dx));   // keep the whole image on the panel
      d.ny = Math.max(0, Math.min(Math.max(0, d.ph - d.h0), d.y0 + dy));
      box.style.left = (d.nx * d.scale) + 'px'; box.style.top = (d.ny * d.scale) + 'px';
    } else {
      d.nw = Math.max(1, Math.min(d.pw, d.w0 + dx)); d.nh = Math.max(1, Math.min(d.ph, d.h0 + dy));
      box.style.width = (d.nw * d.scale) + 'px'; box.style.height = (d.nh * d.scale) + 'px';
    }
    d.moved = true; showPlaceCoord(d);
  });
  const finish = cancelled => {
    const d = _placeDrag; if (!d || d.box !== box) return;
    _placeDrag = null; box.classList.remove('drag');
    if (cancelled || !d.moved) {
      const call = placedByKey[box.dataset.key], scr = box.closest('.screen');
      if (call && scr) positionBox(box, call, scr);       // revert the visual, no write
    } else commitDrag(d);
    if (_rebuildPending) { _rebuildPending = false; refreshBoxes(); }
  };
  box.addEventListener('pointerup', () => finish(false));
  box.addEventListener('pointercancel', () => finish(true));
  box.addEventListener('lostpointercapture', () => finish(true));
  box.addEventListener('keydown', e => {
    if ((e.ctrlKey || e.metaKey) && (e.key === 'z' || e.key === 'Z')) { e.preventDefault(); placeUndo(); return; }
    const call = placedByKey[box.dataset.key]; if (!call || !call.editable) return;
    const step = e.shiftKey ? 8 : 1;
    const mv = {ArrowLeft: [-step, 0], ArrowRight: [step, 0], ArrowUp: [0, -step], ArrowDown: [0, step]}[e.key];
    if (mv) {
      e.preventDefault();
      const scr = box.closest('.screen'), dims = panelDims(scr), z = effSize(call);
      const nx = Math.max(0, Math.min(Math.max(0, dims.w - z.w), call.x + mv[0]));   // stay fully on the panel
      const ny = Math.max(0, Math.min(Math.max(0, dims.h - z.h), call.y + mv[1]));
      commitImageEdits([{start: call.spans.x[0], end: call.spans.x[1], str: String(nx)},
                        {start: call.spans.y[0], end: call.spans.y[1], str: String(ny)}], false);
    } else if (e.key === 'Delete' || e.key === 'Backspace') { e.preventDefault(); deleteImage(call); }
    else if (e.key === 'Escape') box.blur();
  });
}
function commitDrag(d) {
  const call = placedByKey[d.key]; if (!call || !call.editable) return;
  const edits = [];
  if (d.mode === 'move') {
    edits.push({start: call.spans.x[0], end: call.spans.x[1], str: String(d.nx)});
    edits.push({start: call.spans.y[0], end: call.spans.y[1], str: String(d.ny)});
  } else {
    const ins = [];   // handle w and h independently, insert only the missing kwargs
    if (call.spans.w) edits.push({start: call.spans.w[0], end: call.spans.w[1], str: String(d.nw)});
    else ins.push('w = ' + d.nw);
    if (call.spans.h) edits.push({start: call.spans.h[0], end: call.spans.h[1], str: String(d.nh)});
    else ins.push('h = ' + d.nh);
    if (ins.length) edits.push({start: call.closeParen, end: call.closeParen, str: ', ' + ins.join(', ')});
  }
  commitImageEdits(edits, true);   // immediate save on release
}
function revealImage(call) {
  switchTab('app.star'); const ed = $('ed'); ed.focus();
  ed.setSelectionRange(call.callStart, call.callEnd);
  const line = ed.value.slice(0, call.callStart).split('\n').length;
  ed.scrollTop = Math.max(0, (line - 3) * 20);
  setStatus(call.file + ' is positioned by code, edit it in app.star.', 'ok');
}
function defBodyWouldEmpty(text, s, e) {
  const nt = text.slice(0, s) + text.slice(e);
  const ms = [...nt.slice(0, s).matchAll(/^([ \t]*)def[ \t]+\w+[ \t]*\([^\n]*:[ \t]*$/gm)];
  if (!ms.length) return false;
  const def = ms[ms.length - 1], defIndent = def[1].length, bodyStart = def.index + def[0].length;
  for (const ln of nt.slice(bodyStart).split('\n')) {
    const tr = ln.trim();
    if (!tr || tr[0] === '#') continue;                          // blank or comment
    if ((ln.match(/^[ \t]*/)[0]).length <= defIndent) break;     // dedent = end of body
    return false;                                                // a real statement remains
  }
  return true;
}
function deleteImage(call) {
  const text = starText();
  const s = text.lastIndexOf('\n', call.callStart - 1) + 1;
  let e = text.indexOf('\n', call.callEnd); e = e === -1 ? text.length : e + 1;
  const indent = (text.slice(s).match(/^[ \t]*/) || [''])[0] || '    ';
  const str = defBodyWouldEmpty(text, s, e) ? indent + 'pass\n' : '';   // don't leave an empty def
  selKey = null;
  commitImageEdits([{start: s, end: e, str}], true);
  setStatus('Removed ' + call.file + '. Press Ctrl+Z on an image to undo.', 'ok');
}

/* ---- open/close the tool and insert a new image ---- */
// Both toggles (the header "Place image" and the per-panel "Edit images") reflect
// whether the tool is on.
function syncPlaceButtons() {
  $('placebtn').classList.toggle('accent', placeActive);
  document.querySelectorAll('.editimg').forEach(b => b.classList.toggle('active', placeActive));
}
// Put an "Edit images" button right next to the panel size, but only when the app
// actually draws a PNG, so people can jump straight into editing an existing image.
function updateEditButtons(hasImg) {
  document.querySelectorAll('#panels .panel .h').forEach(h => {
    let btn = h.querySelector('.editimg');
    if (hasImg && !btn) {
      btn = document.createElement('button');
      btn.className = 'editimg'; btn.type = 'button'; btn.textContent = 'Edit images';
      btn.title = 'Drag the pictures on this panel to move them';
      h.appendChild(btn);
    } else if (!hasImg && btn) { btn.remove(); }
    if (btn) btn.classList.toggle('active', placeActive);
  });
}
function openPlace() { placeActive = true; document.body.classList.add('placing'); $('placecard').hidden = false; syncPlaceButtons(); setPlaced(parseImages(starText())); refreshBoxes(); }
function closePlace() { placeActive = false; document.body.classList.remove('placing'); _placeDrag = null; $('placecard').hidden = true; $('placepick').hidden = true; selKey = null; syncPlaceButtons(); clearBoxes(); }
async function openInsertPicker() {
  let d;
  try { d = await (await fetch('pngs?' + appQS())).json(); } catch (e) { setStatus('Couldn’t list images.', 'bad'); return; }
  const pngs = d.pngs || [], wrap = $('placepick');
  wrap.innerHTML = pngs.length
    ? pngs.map(f => `<button class="ghost small pngpick" data-file="${esc(f)}">${esc(f)}</button>`).join('')
    : '<div class="help">No PNGs in this app yet. Add a .png to its assets folder, then reopen this.</div>';
  wrap.hidden = false;
}
function insertImage(file) {
  const text = starText();
  const page = (lastPages[0] && lastPages[0].name) || null;
  let insertAt = text.length, indent = '    ', recv = 'c';
  if (page) {
    const dm = new RegExp('^([ \\t]*)def[ \\t]+' + page + '[ \\t]*\\(([^)\\n]*)\\)[ \\t]*:', 'm').exec(text);
    if (dm) {
      recv = (dm[2].split(',')[0] || 'c').trim() || 'c';
      const bodyStart = dm.index + dm[0].length, after = text.slice(bodyStart);
      const nextDef = after.search(/\n[ \t]*def[ \t]/);
      insertAt = nextDef === -1 ? text.length : bodyStart + nextDef;
      const bl = after.match(/\n([ \t]+)\S/); if (bl) indent = bl[1];
    }
  }
  const pd = lastPages[0] ? {w: lastPages[0].w, h: lastPages[0].h} : {w: 64, h: 32};
  const dim = assetDims[currentApp + '/' + file], iw = dim ? dim.w : 16, ih = dim ? dim.h : 16;
  const x = Math.max(0, Math.floor((pd.w - iw) / 2)), y = Math.max(0, Math.floor((pd.h - ih) / 2));
  const pre = text.slice(0, insertAt), lead = (pre.length && !pre.endsWith('\n')) ? '\n' : '';
  const lineText = lead + indent + recv + '.image("' + file + '", ' + x + ', ' + y + ')\n';
  $('placepick').hidden = true;
  commitImageEdits([{start: insertAt, end: insertAt, str: lineText}], true);
  const mine = placed.filter(c => c.file === file); selKey = mine.length ? mine[mine.length - 1].key : null;
  applySelection();
  setStatus('Added ' + file + '. Drag it into place.', 'ok');
}

/* ---- drag-and-drop a PNG onto Studio to import it ---------------------- */
function declareAsset(name) {
  let m = files['manifest.yaml'] || '';
  const e = name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  if (new RegExp('^\\s*-\\s*' + e + '\\s*$', 'm').test(m)) return;                 // already a block item
  if (new RegExp('^assets:[ \\t]*\\[[^\\]]*' + e, 'm').test(m)) return;            // already in a flow list
  if (/^assets:[ \t]*\[/m.test(m))
    m = m.replace(/^(assets:[ \t]*\[)([^\]]*)(\])/m, (_, a, mid, z) => a + (mid.trim() ? mid + ', ' : '') + name + z);
  else if (/^assets:[ \t]*(#.*)?$/m.test(m))
    m = m.replace(/^assets:[ \t]*(#.*)?\r?\n/m, mm => mm + '  - ' + name + '\n');
  else
    m = m.replace(/\s*$/, '') + '\nassets:\n  - ' + name + '\n';
  files['manifest.yaml'] = m;
  if (activeTab === 'manifest.yaml') $('ed').value = m;                            // shim repaints the highlight
}
async function uploadDroppedImage(file) {
  if (missing.includes('app.star') && !missing.includes('app.py')) {
    setStatus('Drop-in images need an app.star app.', 'bad'); return; }
  setStatus('Adding ' + file.name + '…');
  const fd = new FormData(); fd.append('file', file);
  let d;
  try { d = await (await fetch('upload-image?' + appQS(), {method: 'POST', body: fd})).json(); }
  catch (e) { setStatus('Couldn’t upload. Is Studio still running?', 'bad'); return; }
  if (!d.ok) { setStatus(d.error, 'bad'); return; }
  assetDims[currentApp + '/' + d.name] = {w: d.w, h: d.h};     // so insertImage centers for the true size
  declareAsset(d.name);
  if (activeTab !== 'app.star') switchTab('app.star');
  if (!placeActive) openPlace();
  insertImage(d.name);                                          // centered c.image(...), selected to drag
  if ((files['manifest.yaml'] || '') !== (pristine['manifest.yaml'] || '')) {
    try {
      await fetch('files?' + appQS(), {method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({'manifest.yaml': files['manifest.yaml']})});
      pristine['manifest.yaml'] = files['manifest.yaml'];
    } catch (e) {}
  }
  setStatus('Added ' + d.name + (d.resized ? ' (shrunk to fit the panel)' : '') + '. Drag it into place.', 'ok');
}
/* Confirm before importing a dropped file, so a stray drag (e.g. while trying to move
   an image) can't silently copy a file into the app and add a draw call. */
let _pendingImport = null, _pendingImportURL = null;
function askImport(file) {
  _pendingImport = file;
  $('importname').textContent = file.name || 'this image';
  const pv = $('importpreview');
  if (_pendingImportURL) { URL.revokeObjectURL(_pendingImportURL); _pendingImportURL = null; }
  if (/^image\//.test(file.type || '')) {
    _pendingImportURL = URL.createObjectURL(file); pv.src = _pendingImportURL; pv.hidden = false;
  } else pv.hidden = true;
  $('importmodal').hidden = false;
}
function closeImport() {
  $('importmodal').hidden = true; _pendingImport = null;
  if (_pendingImportURL) { URL.revokeObjectURL(_pendingImportURL); _pendingImportURL = null; }
}
function confirmImport() {
  const f = _pendingImport;
  $('importmodal').hidden = true; _pendingImport = null;
  if (_pendingImportURL) { URL.revokeObjectURL(_pendingImportURL); _pendingImportURL = null; }
  if (f) uploadDroppedImage(f);
}

/* ---- pixel-art sprite editor (paints a grid, writes c.bitmap / c.sprite) ---- */
let sprGrid = [], sprW = 16, sprH = 16, sprColor = 'green', sprEdit = null, _sprDrag = null;
function sprColorHex(name) {
  const c = ((tbxData && tbxData.colors) || []).find(x => x.name === name);
  return c ? c.hex : (name === 'white' ? '#ffffff' : name === 'black' ? '#000000' : '#00dc46');
}
function sprAllocBlank(w, h) { sprGrid = []; for (let y = 0; y < h; y++) { sprGrid.push([]); for (let x = 0; x < w; x++) sprGrid[y].push(null); } sprW = w; sprH = h; }
function sprAlloc(w, h) {                 // resize, keeping the overlapping top-left region
  const old = sprGrid, ow = sprW, oh = sprH; sprGrid = [];
  for (let y = 0; y < h; y++) { sprGrid.push([]); for (let x = 0; x < w; x++) sprGrid[y].push((y < oh && x < ow && old[y]) ? old[y][x] : null); }
  sprW = w; sprH = h;
}
function sprCell() { return Math.max(6, Math.floor(Math.min(320 / sprW, 320 / sprH))); }
function drawSpr() {
  const cv = $('sprcanvas'); if (!cv) return;
  const cell = sprCell(); cv.width = sprW * cell; cv.height = sprH * cell;
  const ctx = cv.getContext('2d');
  ctx.fillStyle = '#000'; ctx.fillRect(0, 0, cv.width, cv.height);
  for (let y = 0; y < sprH; y++) for (let x = 0; x < sprW; x++)
    if (sprGrid[y][x]) { ctx.fillStyle = sprColorHex(sprGrid[y][x]); ctx.fillRect(x * cell, y * cell, cell, cell); }
  ctx.strokeStyle = 'rgba(255,255,255,.09)'; ctx.lineWidth = 1;
  for (let x = 0; x <= sprW; x++) { ctx.beginPath(); ctx.moveTo(x * cell + .5, 0); ctx.lineTo(x * cell + .5, cv.height); ctx.stroke(); }
  for (let y = 0; y <= sprH; y++) { ctx.beginPath(); ctx.moveTo(0, y * cell + .5); ctx.lineTo(cv.width, y * cell + .5); ctx.stroke(); }
}
function sprCellAt(e) {
  const cv = $('sprcanvas'), r = cv.getBoundingClientRect();
  const x = Math.floor((e.clientX - r.left) / (r.width / sprW)), y = Math.floor((e.clientY - r.top) / (r.height / sprH));
  return (x >= 0 && x < sprW && y >= 0 && y < sprH) ? { x, y } : null;
}
function renderSprPal() {
  const cols = (tbxData && tbxData.colors) || [{ name: 'white', hex: '#fff' }, { name: 'red', hex: '#f33' },
    { name: 'green', hex: '#0d4' }, { name: 'blue', hex: '#48f' }, { name: 'yellow', hex: '#fd4' }, { name: 'gray', hex: '#999' }];
  $('sprpal').innerHTML = cols.map(c =>
    `<button class="spr-sw${c.name === sprColor ? ' sel' : ''}" data-c="${esc(c.name)}" title="${esc(c.name)}" style="background:${c.hex}"></button>`).join('') +
    `<button class="spr-sw erase${sprColor === null ? ' sel' : ''}" data-c="" title="Eraser"></button>`;
}
function sprBounds() {
  let a = sprW, b = sprH, c = -1, d = -1;
  for (let y = 0; y < sprH; y++) for (let x = 0; x < sprW; x++) if (sprGrid[y][x]) { if (x < a) a = x; if (x > c) c = x; if (y < b) b = y; if (y > d) d = y; }
  return c < 0 ? null : { x0: a, y0: b, x1: c, y1: d };
}
function sprSerialize() {
  const bb = sprBounds();
  if (!bb) { $('sprerr').textContent = 'Paint at least one pixel first.'; return null; }
  const used = [], rows = [];
  for (let y = bb.y0; y <= bb.y1; y++) { const r = []; for (let x = bb.x0; x <= bb.x1; x++) { const c = sprGrid[y][x]; r.push(c); if (c && used.indexOf(c) < 0) used.push(c); } rows.push(r); }
  if (used.length === 1)
    return 'c.bitmap([' + rows.map(r => '[' + r.map(c => c ? 1 : 0).join(',') + ']').join(',') + '], 2, 2, "' + used[0] + '")';
  const ch = 'ABCDEFGHJKLMNPQRSTUVWZ';
  const art = rows.map(r => r.map(c => c ? ch[used.indexOf(c)] : '.').join('')).join('\\n');
  const leg = '{' + used.map((c, i) => '"' + ch[i] + '": "' + c + '"').join(', ') + '}';
  return 'c.sprite("' + art + '", 2, 2, legend=' + leg + ')';
}
function sprFindCall(text, caret) {
  const re = /([A-Za-z_]\w*)\.(bitmap|sprite)\(/g; let m;
  while ((m = re.exec(text))) {
    let i = re.lastIndex - 1, depth = 0, q = null;
    for (; i < text.length; i++) { const c = text[i];
      if (q) { if (c === q && text[i - 1] !== '\\') q = null; continue; }
      if (c === '"' || c === "'") q = c; else if (c === '(') depth++; else if (c === ')') { depth--; if (!depth) { i++; break; } } }
    const start = m.index, end = i, ls = text.lastIndexOf('\n', start) + 1;
    if (text.slice(ls, start).indexOf('#') >= 0) continue;
    if (caret >= start && caret <= end) return { start, end, kind: m[2], text: text.slice(start, end) };
  }
  return null;
}
function loadSprFromCall(call) {
  try {
    if (call.kind === 'bitmap') {
      const mm = /\.bitmap\(\s*(\[[\s\S]*?\])\s*,\s*-?\d+\s*,\s*-?\d+\s*,\s*["']([a-z]+)["']/.exec(call.text);
      if (!mm) return false;
      const mat = JSON.parse(mm[1]), col = mm[2], h = mat.length, w = Math.max.apply(null, mat.map(r => r.length));
      if (w > 32 || h > 32) return false;
      sprAllocBlank(Math.max(8, w), Math.max(8, h));
      for (let y = 0; y < h; y++) for (let x = 0; x < mat[y].length; x++) if (mat[y][x]) sprGrid[y][x] = col;
      sprColor = col;
    } else {
      const mm = /\.sprite\(\s*["']([\s\S]*?)["']\s*,\s*-?\d+\s*,\s*-?\d+\s*(?:,\s*color\s*=\s*["']([a-z]+)["'])?\s*(?:,\s*legend\s*=\s*(\{[^}]*\}))?/.exec(call.text);
      if (!mm) return false;
      const arr = mm[1].replace(/\\n/g, '\n').replace(/^\n+|\n+$/g, '').split('\n');
      const defc = mm[2] || 'white'; let leg = {};
      if (mm[3]) { try { leg = JSON.parse(mm[3].replace(/'/g, '"')); } catch (e) { return false; } }
      const h = arr.length, w = Math.max.apply(null, arr.map(r => r.length));
      if (w > 32 || h > 32) return false;
      sprAllocBlank(Math.max(8, w), Math.max(8, h)); let first = null;
      for (let y = 0; y < h; y++) { const row = arr[y]; for (let x = 0; x < row.length; x++) { const c = row[x]; if (c === ' ' || c === '.') continue; const col = leg[c] || defc; sprGrid[y][x] = col; if (!first) first = col; } }
      sprColor = first || defc;
    }
    sprEdit = { start: call.start, end: call.end };
    return true;
  } catch (e) { return false; }
}
function openSprModal() {
  sprEdit = null; $('sprerr').textContent = '';
  _tbCaret = (activeTab === 'app.star') ? $('ed').selectionStart : null;
  const call = (activeTab === 'app.star') ? sprFindCall($('ed').value, $('ed').selectionStart) : null;
  if (!(call && loadSprFromCall(call))) { sprAllocBlank(16, 16); sprColor = 'green'; sprEdit = null; }
  if (!tbxData) fetch('toolbox.json').then(r => r.json()).then(d => { tbxData = d; renderSprPal(); drawSpr(); }).catch(() => {});
  $('sprsize').value = sprW + 'x' + sprH;
  $('sprok').textContent = sprEdit ? 'Update code' : 'Insert code';
  renderSprPal(); $('sprmodal').hidden = false; drawSpr();
}
function closeSprModal() { $('sprmodal').hidden = true; sprEdit = null; }
function insertSprite() {
  const code = sprSerialize(); if (!code) return;
  if (sprEdit) {
    if (activeTab !== 'app.star') switchTab('app.star');
    const ed = $('ed'); ed.focus(); ed.setSelectionRange(sprEdit.start, sprEdit.end);
    document.execCommand('insertText', false, code); files['app.star'] = ed.value;
    closeSprModal(); setStatus('Updated your pixel art.', 'ok');
  } else { closeSprModal(); insertHelper(code, null); }
}

/* ---- Create New App ---------------------------------------------------- */
/* The Create New App dialog builds its starter settings as rows: one type dropdown
   and an optional label each, so people pick WHAT kind of setting, not just how many. */
const NEW_SETTING_TYPES = [
  ['free-text', 'Text box'], ['number', 'Number'], ['dropdown', 'Dropdown'],
  ['checkbox', 'Checkbox'], ['date', 'Date'], ['color', 'Color'],
];
function newSettingRow(type, label) {
  const opts = NEW_SETTING_TYPES.map(([v, t]) =>
    `<option value="${v}"${v === type ? ' selected' : ''}>${t}</option>`).join('');
  return `<div class="setrow">
    <select class="settype">${opts}</select>
    <input class="setlabel" placeholder="Label (optional)" maxlength="40" value="${esc(label || '')}">
    <button class="ghost small setremove" type="button" title="Remove this setting">&times;</button>
  </div>`;
}
function addSettingRow(type, label) {
  const box = $('newsettings');
  if (box.querySelectorAll('.setrow').length >= 8) return;   // manifest cap
  box.insertAdjacentHTML('beforeend', newSettingRow(type || 'free-text', label || ''));
}
function collectNewSettings() {
  return [...$('newsettings').querySelectorAll('.setrow')].map(r => ({
    type: r.querySelector('.settype').value,
    label: r.querySelector('.setlabel').value.trim(),
  }));
}
function openNewModal() {
  $('newerr').textContent = '';
  $('newname').value = '';
  $('newslug').textContent = '';
  $('newwidth').value = '128';
  $('newcat').value = 'Lifestyle';
  $('newsettings').innerHTML = '';
  addSettingRow('free-text', '');   // start with one text setting
  $('newmodal').hidden = false;
  $('newname').focus();
}
function closeNewModal() { $('newmodal').hidden = true; const b = $('newbtn'); if (b) b.focus(); }
async function createApp() {
  const name = $('newname').value.trim();
  if (!name) { $('newerr').textContent = 'Give your app a name first.'; return; }
  const body = {
    name: name,
    width: parseInt($('newwidth').value, 10) || 128,
    category: $('newcat').value,
    settings: collectNewSettings(),
  };
  try {
    const r = await fetch('new', {method: 'POST',
      headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body)});
    const d = await r.json();
    if (!d.ok) { $('newerr').textContent = d.error; return; }
    closeNewModal();
    currentApp = d.app;
    await loadApps(d.app);           // the new app appears in the picker, selected
    setStatus('Created ' + d.app + '. Open the Toolbox to add text, charts, and shapes.', 'ok');
    rebuildInputs();
    loadFiles();
  } catch (e) { $('newerr').textContent = "Couldn't reach the Studio server."; }
}

/* ==== Toolbox: fonts + drawing-helper inventory ==== */
let tbxData = null;    // {helpers, fonts} loaded once from /toolbox.json
let _tbCaret = null;   // editor caret position snapshot when the toolbox opened

const TBX_SEEN = 'gdnStudio.tbxSeen';
function tbxSeen() { try { return !!localStorage.getItem(TBX_SEEN); } catch (e) { return true; } }
function dismissTbxCoach(open) {
  try { localStorage.setItem(TBX_SEEN, '1'); } catch (e) {}
  const c = $('tbxcoach'); if (c) c.hidden = true;
  if (open) openToolbox();
}
async function openToolbox() {
  dismissTbxCoach(false);
  _tbCaret = (activeTab === 'app.star') ? $('ed').selectionStart : null;
  $('tbxmodal').hidden = false;
  if (!tbxData) {
    try { tbxData = await (await fetch('toolbox.json')).json(); }
    catch (e) { $('tbxbody').innerHTML = '<div class="tbx-loading">Couldn’t load the toolbox. Is Studio still running?</div>'; return; }
  }
  pickTbxTab('insert');
}
function closeToolbox() { $('tbxmodal').hidden = true; }
function pickTbxTab(tab) {
  document.querySelectorAll('.tbx-tab').forEach(t => t.classList.toggle('active', t.dataset.tab === tab));
  if (tab === 'fonts') renderTbxFonts();
  else if (tab === 'icons') renderTbxIcons();
  else renderTbxHelpers();
}
function renderTbxIcons() {
  if (!tbxData || !tbxData.icons || !tbxData.icons.length) {
    $('tbxbody').innerHTML = '<div class="tbx-loading">No icons found.</div>'; return; }
  $('tbxbody').innerHTML = '<div class="tbx-group">Built-in icons &middot; click to add c.icon(...)</div><div class="tbx-grid">' +
    tbxData.icons.map((ic, i) =>
      `<button class="tbx-tile" data-kind="icon" data-i="${i}">
        <img src="${ic.img}" alt=""><span class="nm">${esc(ic.name)}</span></button>`).join('') + '</div>';
}
function renderTbxHelpers() {
  if (!tbxData) return;
  const order = [], by = {};
  tbxData.helpers.forEach((h, i) => { if (!by[h.group]) { order.push(h.group); by[h.group] = []; } by[h.group].push(i); });
  $('tbxbody').innerHTML = order.map(g =>
    `<div class="tbx-group">${esc(g)}</div><div class="tbx-grid">` +
    by[g].map(i => { const h = tbxData.helpers[i];
      return `<button class="tbx-tile" data-kind="helper" data-i="${i}">
        <img src="${h.img}" alt=""><span class="nm">${esc(h.name)}</span>
        <span class="ds">${esc(h.desc)}</span></button>`; }).join('') + '</div>').join('');
}
function renderTbxFonts() {
  if (!tbxData) return;
  const groups = [['Small (8px and under)', f => f.h <= 8],
                  ['Medium (9 to 16px)', f => f.h > 8 && f.h <= 16],
                  ['Large (17px and up)', f => f.h > 16]];
  const idx = tbxData.fonts.map((f, i) => i);
  $('tbxbody').innerHTML = groups.map(([label, pred]) => {
    const list = idx.filter(i => pred(tbxData.fonts[i])).sort((a, b) => tbxData.fonts[a].h - tbxData.fonts[b].h);
    if (!list.length) return '';
    return `<div class="tbx-group">${esc(label)}</div>` + list.map(i => {
      const f = tbxData.fonts[i], s = f.h <= 8 ? 3 : f.h <= 16 ? 2 : 1;
      return `<div class="tbx-frow" data-kind="fontrow" data-i="${i}">
        <span class="fname">${esc(f.name)} &middot; ${f.h}px</span>
        <span class="fprev"><img src="${f.img}" width="${f.iw * s}" height="${f.ih * s}" alt="">
          ${f.letters ? '' : '<span class="ftag">numbers only</span>'}</span>
        <button class="ghost small fchip" data-kind="font" data-i="${i}">font=&quot;${esc(f.name)}&quot;</button>
      </div>`; }).join('');
  }).join('');
}
function tbxCaretPos() { const ed = $('ed'); return _tbCaret != null ? Math.min(_tbCaret, ed.value.length) : ed.value.length; }
// Drop a helper snippet in on its own line at the caret, indented like the code around
// it, and select the first placeholder so the user can just start typing.
function insertHelper(snippet, ph) {
  closeToolbox();
  if (activeTab !== 'app.star') switchTab('app.star');
  const ed = $('ed'); ed.focus();
  const pos = tbxCaretPos();
  const ls = ed.value.lastIndexOf('\n', pos - 1) + 1;
  let le = ed.value.indexOf('\n', pos); if (le === -1) le = ed.value.length;
  const line = ed.value.slice(ls, le);
  let base;
  if (line.trim() !== '') {                       // caret line has code: open a new line below it
    const indent = (line.match(/^[ \t]*/) || [''])[0];
    ed.setSelectionRange(le, le);
    document.execCommand('insertText', false, '\n' + indent + snippet);
    base = le + 1 + indent.length;
  } else {                                        // blank line: fill it, indent like the code above
    const above = ed.value.slice(0, ls).split('\n').reverse().find(l => l.trim() !== '');
    const indent = above ? (above.match(/^[ \t]*/) || [''])[0] : '    ';
    ed.setSelectionRange(ls, le);
    document.execCommand('insertText', false, indent + snippet);
    base = ls + indent.length;
  }
  files['app.star'] = ed.value;
  const at = ph ? snippet.indexOf(ph) : -1;
  if (at >= 0) ed.setSelectionRange(base + at, base + at + ph.length);
  setStatus('Added ' + snippet.split('(')[0] + '(...). Press Ctrl+S to see it.', 'ok');
}
function insertFontKwarg(name) {
  closeToolbox();
  if (activeTab !== 'app.star') switchTab('app.star');
  const ed = $('ed'); ed.focus();
  const pos = tbxCaretPos(); ed.setSelectionRange(pos, pos);
  document.execCommand('insertText', false, 'font="' + name + '"');
  files['app.star'] = ed.value;
  setStatus('Added font="' + name + '".', 'ok');
}

/* ================= optional autocomplete =================================
   Suggests helpers (c.*), font names, named colors, and manifest setting keys
   as you type. Off/on via the Suggestions toggle; insertion goes through
   execCommand so undo + highlighting + the linter all keep working. */
let acOn = true; const AC_KEY = 'gdnStudio.autocomplete';
try { acOn = localStorage.getItem(AC_KEY) !== '0'; } catch (e) {}
let acItems = [], acIdx = 0, acCtx = null;
const AC_COLORARGS = /\b(?:color|bg|fill|outline|stroke|dots|border|track|key_color|value_color|label_color|home_color|away_color|score_color|header_color|bar_color)\s*=\s*["']([a-z]*)$/;

function acInputKeys() {
  return [...new Set([...document.querySelectorAll('#inputs [name]')].map(e => e.name).filter(Boolean))];
}
function acMethodList() {
  if (!tbxData || !tbxData.helpers) return [];
  const seen = {}, out = [];
  tbxData.helpers.forEach(h => { const m = /^c\.([A-Za-z_]\w*)/.exec(h.name || '');
    if (m && !seen[m[1]]) { seen[m[1]] = 1; out.push({ name: m[1], args: h.args || '' }); } });
  return out;
}
function acInString(left) {           // is the caret inside an open quote on this line?
  let q = null;
  for (let i = 0; i < left.length; i++) { const c = left[i];
    if (q) { if (c === q) q = null; } else if (c === '"' || c === "'") q = c; else if (c === '#') return false; }
  return !!q;
}
function acDetect() {
  const ed = $('ed');
  if (activeTab !== 'app.star' || ed.selectionStart !== ed.selectionEnd) return null;
  const pos = ed.selectionStart, ls = ed.value.lastIndexOf('\n', pos - 1) + 1, left = ed.value.slice(ls, pos);
  let m;
  if ((m = /\bfont\s*=\s*["']([A-Za-z0-9_]*)$/.exec(left)) && tbxData && tbxData.fonts) {
    const items = tbxData.fonts.filter(f => f.name.toLowerCase().startsWith(m[1].toLowerCase()))
      .map(f => ({ label: f.name, insert: f.name, hint: f.h + 'px' }));
    return items.length ? { items, start: pos - m[1].length, end: pos } : null;
  }
  if ((m = /\bctx\s*\.\s*inputs\s*\.\s*get\(\s*["'](\w*)$/.exec(left))) {
    const items = acInputKeys().filter(k => k.toLowerCase().startsWith(m[1].toLowerCase()))
      .map(k => ({ label: k, insert: k, hint: 'setting' }));
    return items.length ? { items, start: pos - m[1].length, end: pos } : null;
  }
  if ((m = AC_COLORARGS.exec(left)) && tbxData && tbxData.colors) {
    const items = tbxData.colors.filter(c => c.name.startsWith(m[1]))
      .map(c => ({ label: c.name, insert: c.name, sw: c.hex }));
    return items.length ? { items, start: pos - m[1].length, end: pos } : null;
  }
  if (!acInString(left) && (m = /(?:^|[^\w."'])([A-Za-z_]\w*)\.(\w*)$/.exec(left)) && m[1] === 'c') {
    const items = acMethodList().filter(x => x.name.toLowerCase().startsWith(m[2].toLowerCase()))
      .map(x => ({ label: 'c.' + x.name, insert: x.name + '(', hint: x.args }));
    return items.length ? { items, start: pos - m[2].length, end: pos } : null;
  }
  return null;
}
function acHide() { acItems = []; acCtx = null; const el = $('acmenu'); if (el) el.hidden = true; }
function acCaretXY() {                // caret pixel position, read off the #edhl mirror
  const ed = $('ed'), hl = $('edhl'), pos = ed.selectionStart, before = ed.value.slice(0, pos);
  const line = before.split('\n').length, col = pos - (before.lastIndexOf('\n') + 1);
  const row = hl.querySelectorAll('.hlrow')[line - 1]; if (!row) return null;
  const hlc = row.querySelector('.hlc'); if (!hlc) return null;
  const w = document.createTreeWalker(hlc, NodeFilter.SHOW_TEXT);
  let acc = 0, node, target = null, off = 0;
  while ((node = w.nextNode())) { const len = node.textContent.length;
    if (acc + len >= col) { target = node; off = col - acc; break; } acc += len; }
  const r = document.createRange();
  if (target) { r.setStart(target, Math.min(off, target.textContent.length)); r.collapse(true); }
  else { r.selectNodeContents(hlc); r.collapse(false); }
  const rect = r.getClientRects()[0] || hlc.getBoundingClientRect();
  const wrap = hl.parentElement.getBoundingClientRect();
  return { left: rect.left - wrap.left, top: rect.bottom - wrap.top, wrapH: hl.parentElement.clientHeight };
}
function acPaint() {
  $('acmenu').innerHTML = acItems.map((it, i) =>
    `<div class="acit${i === acIdx ? ' sel' : ''}" data-i="${i}">` +
    (it.sw ? `<i class="acsw" style="background:${it.sw}"></i>` : '') +
    `<span class="acnm">${esc(it.label)}</span>` +
    (it.hint ? `<span class="achint">${esc(it.hint)}</span>` : '') + '</div>').join('');
}
function acShow(det) {
  acItems = det.items; acIdx = 0; acCtx = { start: det.start, end: det.end };
  const el = $('acmenu'); acPaint(); el.hidden = false;
  const xy = acCaretXY(); if (!xy) return;
  let top = xy.top + 2;
  if (top + el.offsetHeight > xy.wrapH) top = Math.max(2, xy.top - el.offsetHeight - 20);
  el.style.left = Math.max(2, xy.left) + 'px';
  el.style.top = top + 'px';
}
let _acFetching = false;
async function acEnsureData() {          // the fonts/colors/methods come from the toolbox payload
  if (tbxData || _acFetching) return; _acFetching = true;
  try { tbxData = await (await fetch('toolbox.json')).json(); } catch (e) {}
  _acFetching = false;
  if (acOn && document.activeElement === $('ed')) acOnInput();   // retry now that the data is here
}
function acOnInput() {
  if (!acOn) { acHide(); return; }
  if (!tbxData) acEnsureData();          // lazy-load once; this keystroke retries when it arrives
  const det = acDetect(); if (det) acShow(det); else acHide();
}
function acMove(d) {
  if (!acItems.length) return;
  acIdx = (acIdx + d + acItems.length) % acItems.length; acPaint();
  const sel = $('acmenu').querySelector('.acit.sel'); if (sel) sel.scrollIntoView({ block: 'nearest' });
}
function acAccept() {
  const it = acItems[acIdx]; if (!it || !acCtx) { acHide(); return; }
  const ed = $('ed'); ed.setSelectionRange(acCtx.start, acCtx.end);
  document.execCommand('insertText', false, it.insert);   // undoable; fires input -> highlight + lint
  acHide();
}

/* ---- wire everything up ------------------------------------------------ */
window.addEventListener('DOMContentLoaded', async () => {
  // #now=... in the address bar prefills time travel (set before the first render)
  if (location.hash.startsWith('#now='))
    $('nowfld').value = decodeURIComponent(location.hash.slice(5));

  // Wire every control up FIRST. If the first load is slow or the app's manifest is
  // broken, the buttons must still work, never a page that looks fine but does nothing.
  $('save').addEventListener('click', save);
  $('reload').addEventListener('click', () => {
    if (isDirty() && !confirm('Reloading will discard your unsaved changes. Reload from disk?')) return;
    rebuildInputs(); loadFiles();
  });
  $('validate').addEventListener('click', validate);
  $('mergebtn').addEventListener('click', openSubmitModal);
  $('pngbtn').addEventListener('click', savePng);
  setInterval(pollDisk, 2000);   // auto-reload when the files change on disk
  // Drag a PNG anywhere onto Studio to import it into the app.
  let _dragDepth = 0;
  ['dragenter', 'dragover'].forEach(ev => document.addEventListener(ev, e => {
    if (![...(e.dataTransfer ? e.dataTransfer.types : [])].includes('Files')) return;
    e.preventDefault(); if (e.dataTransfer) e.dataTransfer.dropEffect = 'copy';
    if (ev === 'dragenter') { _dragDepth++; document.body.classList.add('dropping'); }
  }));
  document.addEventListener('dragleave', () => { if (--_dragDepth <= 0) { _dragDepth = 0; document.body.classList.remove('dropping'); } });
  document.addEventListener('drop', e => {
    if (![...(e.dataTransfer ? e.dataTransfer.types : [])].includes('Files')) return;
    e.preventDefault(); _dragDepth = 0; document.body.classList.remove('dropping');
    const file = [...e.dataTransfer.files][0]; if (file) askImport(file);   // confirm before importing
  });
  $('importcancel').addEventListener('click', closeImport);
  $('importok').addEventListener('click', confirmImport);
  $('importmodal').addEventListener('click', e => { if (e.target === $('importmodal')) closeImport(); });
  $('newbtn').addEventListener('click', openNewModal);
  $('newok').addEventListener('click', createApp);
  $('newcancel').addEventListener('click', closeNewModal);
  $('newname').addEventListener('input', () =>
    { $('newslug').textContent = 'Folder: apps/' + slugify($('newname').value || ''); });
  $('newname').addEventListener('keydown', e => { if (e.key === 'Enter') createApp(); });
  $('newmodal').addEventListener('click', e => { if (e.target === $('newmodal')) closeNewModal(); });
  $('newaddsetting').addEventListener('click', () => addSettingRow('free-text', ''));
  $('newsettings').addEventListener('click', e => {
    const rm = e.target.closest('.setremove'); if (rm) rm.closest('.setrow').remove();
  });

  const asel = $('appsel');
  asel.addEventListener('focus', () => { openAppMenu(''); asel.select(); });
  asel.addEventListener('input', () => openAppMenu(asel.value));
  asel.addEventListener('blur', () => setTimeout(() => {
    closeAppMenu(); if (asel.value !== currentApp) asel.value = currentApp; }, 150));
  asel.addEventListener('keydown', e => {
    const menu = $('appmenu');
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      if (menu.hidden) openAppMenu(asel.value);
      const items = [...menu.querySelectorAll('.appitem')];
      if (!items.length) return;
      let idx = items.findIndex(it => it.classList.contains('sel'));
      idx = e.key === 'ArrowDown' ? Math.min(items.length - 1, idx + 1) : Math.max(0, idx - 1);
      items.forEach(it => it.classList.remove('sel'));
      items[idx].classList.add('sel'); items[idx].scrollIntoView({ block: 'nearest' });
    } else if (e.key === 'Enter') {
      e.preventDefault();
      const sel = menu.querySelector('.appitem.sel');
      const typed = asel.value.trim().toLowerCase();
      const exact = appList.find(a => a.toLowerCase() === typed);   // exact match wins over sort order
      if (sel) pickApp(sel.dataset.app);
      else if (exact) pickApp(exact);
      else { const first = menu.querySelector('.appitem'); if (first) pickApp(first.dataset.app); }
      asel.blur();
    } else if (e.key === 'Escape') { asel.value = currentApp; closeAppMenu(); asel.blur(); }
  });
  $('appmenu').addEventListener('mousedown', e => {
    const it = e.target.closest('.appitem'); if (it) { e.preventDefault(); pickApp(it.dataset.app); }
  });

  $('addinput').addEventListener('click', openInputModal);
  $('incancel').addEventListener('click', closeInputModal);
  $('inok').addEventListener('click', addInput);
  $('intype').addEventListener('change', () => {
    const w = $('intype').value;
    $('inchoicewrap').hidden = !(w === 'dropdown' || w === 'selection');
  });
  $('inputmodal').addEventListener('click', e => { if (e.target === $('inputmodal')) closeInputModal(); });
  // Enter in any Add-setting field adds it, mirroring the Create-app dialog.
  ['inkey', 'inlabel', 'indefault', 'inchoices'].forEach(id =>
    $(id).addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); addInput(); } }));
  // Escape closes whichever dialog is open.
  document.addEventListener('keydown', e => {
    if (e.key !== 'Escape') return;
    if (!$('newmodal').hidden) closeNewModal();
    if (!$('inputmodal').hidden) closeInputModal();
    if (!$('tbxmodal').hidden) closeToolbox();
    if (!$('sprmodal').hidden) closeSprModal();
    if (!$('submitmodal').hidden && !$('submitagree').disabled) closeSubmitModal();
    if (!$('importmodal').hidden) closeImport();
    if (!$('tbxcoach').hidden) dismissTbxCoach(false);
  });
  // Publish modal
  $('submitagree').addEventListener('change', () => { $('submitgo').disabled = !$('submitagree').checked; });
  $('submitcancel').addEventListener('click', closeSubmitModal);
  $('submitmodal').addEventListener('click', e => { if (e.target === $('submitmodal') && !$('submitagree').disabled) closeSubmitModal(); });
  // pixel-art sprite editor
  $('sprbtn').addEventListener('click', openSprModal);
  $('sprcancel').addEventListener('click', closeSprModal);
  $('sprok').addEventListener('click', insertSprite);
  $('sprclear').addEventListener('click', () => { sprAllocBlank(sprW, sprH); drawSpr(); });
  $('sprsize').addEventListener('change', () => { const p = $('sprsize').value.split('x').map(Number); sprAlloc(p[0], p[1]); drawSpr(); });
  $('sprpal').addEventListener('click', e => { const sw = e.target.closest('.spr-sw'); if (!sw) return; sprColor = sw.dataset.c || null; renderSprPal(); });
  $('sprmodal').addEventListener('click', e => { if (e.target === $('sprmodal')) closeSprModal(); });
  (function () {
    const scv = $('sprcanvas');
    scv.addEventListener('pointerdown', e => { const c = sprCellAt(e); if (!c) return; scv.setPointerCapture(e.pointerId);
      _sprDrag = { erase: sprColor === null || sprGrid[c.y][c.x] === sprColor }; sprGrid[c.y][c.x] = _sprDrag.erase ? null : sprColor; drawSpr(); });
    scv.addEventListener('pointermove', e => { if (!_sprDrag) return; const c = sprCellAt(e); if (c) { sprGrid[c.y][c.x] = _sprDrag.erase ? null : sprColor; drawSpr(); } });
    scv.addEventListener('pointerup', () => { _sprDrag = null; });
  })();

  $('grid').addEventListener('change', render);
  $('nowfld').addEventListener('change', render);
  let _rz; window.addEventListener('resize', () => { clearTimeout(_rz); _rz = setTimeout(render, 150); });
  $('nowclear').addEventListener('click', () => { $('nowfld').value = ''; render(); });
  $('placebtn').addEventListener('click', () => { placeActive ? closePlace() : openPlace(); });
  $('panels').addEventListener('click', e => {
    if (e.target.closest('.editimg')) { placeActive ? closePlace() : openPlace(); }
  });
  $('placeclose').addEventListener('click', closePlace);
  $('placeadd').addEventListener('click', openInsertPicker);
  $('placepick').addEventListener('click', e => {
    const b = e.target.closest('.pngpick'); if (b) insertImage(b.dataset.file);
  });
  // Two-way sync: hand-editing a coordinate in the code moves the box too. Programmatic
  // edits assign ed.value (which fires no input event), so this only sees real typing.
  let _pp; $('ed').addEventListener('input', () => {
    if (!placeActive || activeTab !== 'app.star' || _placeDrag) return;
    clearTimeout(_pp); _pp = setTimeout(() => { setPlaced(parseImages(starText())); refreshBoxes(); }, 250);
  });

  // Toolbox (fonts + helper inventory)
  $('tbxbtn').addEventListener('click', openToolbox);
  $('tbxcoachok').addEventListener('click', () => dismissTbxCoach(true));
  $('tbxcoachno').addEventListener('click', () => dismissTbxCoach(false));
  $('tbxclose').addEventListener('click', closeToolbox);
  $('tbxmodal').addEventListener('click', e => { if (e.target === $('tbxmodal')) closeToolbox(); });
  document.querySelectorAll('.tbx-tab').forEach(t => t.addEventListener('click', () => pickTbxTab(t.dataset.tab)));
  const withComment = (s, a) => a ? s + '   # ' + a : s;
  $('tbxbody').addEventListener('click', e => {
    const el = e.target.closest('[data-kind]'); if (!el || !tbxData) return;
    const i = parseInt(el.dataset.i, 10), kind = el.dataset.kind;
    if (kind === 'helper') { const h = tbxData.helpers[i]; insertHelper(withComment(h.snippet, h.args), h.ph); }
    else if (kind === 'icon') insertHelper('c.icon("' + tbxData.icons[i].name + '", 2, 2)   # x, y, color', null);
    else if (kind === 'font') insertFontKwarg(tbxData.fonts[i].name);
    else if (kind === 'fontrow') insertHelper(
      withComment('c.text("TEXT", 2, 12, font="' + tbxData.fonts[i].name + '", color="white")', 'text, x, y, font, color'), 'TEXT');
  });
  $('tbxbody').addEventListener('mouseover', e => {
    const t = e.target.closest('.tbx-tile'); if (!t || !tbxData) return;
    const i = parseInt(t.dataset.i, 10);
    $('tbxfoot').textContent = t.dataset.kind === 'icon'
      ? 'c.icon("' + tbxData.icons[i].name + '", 2, 2)'
      : withComment(tbxData.helpers[i].snippet, tbxData.helpers[i].args);
  });
  document.querySelectorAll('.tab').forEach(t =>
    t.addEventListener('click', () => switchTab(t.dataset.f)));
  const ed = $('ed');
  ed.addEventListener('keydown', e => {
    if (!$('acmenu').hidden && acItems.length) {           // autocomplete owns these keys while open
      if (e.key === 'ArrowDown') { e.preventDefault(); acMove(1); return; }
      if (e.key === 'ArrowUp') { e.preventDefault(); acMove(-1); return; }
      if (e.key === 'Enter' || e.key === 'Tab') { e.preventDefault(); acAccept(); return; }
      if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); acHide(); return; }
    }
    if ((e.ctrlKey || e.metaKey) && e.key === 's') { e.preventDefault(); if (!$('save').disabled) save(); }
    if ((e.ctrlKey || e.metaKey) && (e.key === 'b' || e.key === 'B')) { e.preventDefault(); openToolbox(); }
    // insertText keeps the browser's native undo stack intact (assigning .value wipes it).
    if (e.key === 'Tab') { e.preventDefault(); document.execCommand('insertText', false, '    '); }
  });
  // Syntax highlighting: repaint on every edit (typing, paste, execCommand) and keep the
  // colored layer scrolled with the textarea.
  ed.addEventListener('input', paintHl);
  ed.addEventListener('input', scheduleLint);
  ed.addEventListener('input', acOnInput);   // after paintHl, so the mirror is fresh when we measure
  ed.addEventListener('keyup', applyLint);    // a suppressed error appears once the caret leaves its line
  ed.addEventListener('click', applyLint);
  ed.addEventListener('scroll', () => { const hl = $('edhl'); hl.scrollTop = ed.scrollTop; hl.scrollLeft = ed.scrollLeft; acHide(); });
  ed.addEventListener('blur', () => setTimeout(acHide, 150));   // let a menu click land first
  $('acmenu').addEventListener('mousedown', e => {
    const it = e.target.closest('.acit'); if (!it) return;
    e.preventDefault(); acIdx = parseInt(it.dataset.i, 10); acAccept();
  });
  $('actoggle').checked = acOn;
  $('actoggle').addEventListener('change', () => {
    acOn = $('actoggle').checked;
    try { localStorage.setItem(AC_KEY, acOn ? '1' : '0'); } catch (e) {}
    if (!acOn) acHide();
  });
  // Programmatic `ed.value = ...` (loadFiles, switchTab, addInput, the placement tool) fires
  // no input event, so shim the value setter to repaint and re-lint too.
  const _edVal = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value');
  Object.defineProperty(ed, 'value', { configurable: true,
    get() { return _edVal.get.call(this); },
    set(v) { _edVal.set.call(this, v); paintHl(); scheduleLint(); acHide(); } });
  // Warn before closing the tab with unsaved edits.
  window.addEventListener('beforeunload', e => { if (isDirty()) { e.preventDefault(); e.returnValue = ''; } });

  // Now load the app, listeners are already live so a failure here can't brick the UI.
  try {
    await loadApps();
    await loadFiles();
  } catch (e) {
    setStatus('Couldn’t load your apps. Is Studio still running?', 'bad');
  }
  if (!tbxSeen()) { const c = $('tbxcoach'); if (c) c.hidden = false; }   // one-time Toolbox hint

  // Deep links (used by the docs + screenshots): #new opens the create dialog
  // (#new=Name prefills it), #validate / #merge run a check, #xy shows a sample readout.
  if (location.hash.startsWith('#new')) {
    openNewModal();
    const nm = location.hash.startsWith('#new=') ? decodeURIComponent(location.hash.slice(5)) : '';
    if (nm) { $('newname').value = nm; $('newslug').textContent = 'Folder: apps/' + slugify(nm); }
  }
  if (location.hash === '#validate') validate();
  if (location.hash === '#merge') validateMerge();
  if (location.hash === '#xy') {
    $('coords').textContent = 'x 96, y 14'; $('coords').classList.add('live');
  }
});
"""


# ============================================================================
# The page itself.
# ============================================================================
_HTML = """<!doctype html><html><head><meta charset="utf-8">
<title>Glance Dev Studio</title><style>__CSS__</style></head><body>

<header>
  <span class="brand"><span class="dot"></span> Glance Dev Studio</span>
  <label class="applbl">App
    <span class="appwrap">
      <input id="appsel" placeholder="Search apps&hellip;" autocomplete="off"
             title="Type to search your apps, or pick one from the list">
      <div class="appmenu" id="appmenu" role="listbox" hidden></div>
    </span>
  </label>
  <button class="ghost" id="newbtn"
          title="Start a brand-new app from a working example">+ Create New App</button>
  <span class="spacer"></span>
  <span class="status" id="status">Ready</span>
  <button class="ghost" id="validate"
          title="Check that every page of your app draws with no errors">Validate</button>
  <button class="ghost" id="mergebtn"
          title="Check your app, then open a pull request to submit it (the Glance team reviews and merges)">Validate &amp; Submit</button>
</header>

<main>
  <!-- LEFT: your code -->
  <section class="left">
    <div class="pane-head">
      <div class="tabs">
        <div class="tab active" data-f="app.star">app.star<span class="sub">the drawing</span></div>
        <div class="tab" data-f="manifest.yaml">manifest.yaml<span class="sub">the settings</span></div>
        <div class="tab" data-f="app.py" id="tab-py" hidden>app.py<span class="sub">python code</span></div>
      </div>
      <span class="spacer"></span>
      <button class="accent" id="save"
              title="Save your changes and redraw the preview">Save &amp; Render<kbd>Ctrl+S</kbd></button>
    </div>
    <div class="edbar">
      <span class="tbxwrap">
        <button class="ghost" id="tbxbtn"
                title="Browse fonts and drawing helpers, click one to add it to your code"><svg width="11" height="11" viewBox="0 0 12 12" aria-hidden="true"><path fill="currentColor" d="M0 0h5v5H0zM7 0h5v5H7zM0 7h5v5H0zM7 7h5v5H7z"/></svg>Toolbox<kbd>Ctrl+B</kbd></button>
        <div class="coach" id="tbxcoach" hidden>
          <b>Add things without typing code.</b>
          The Toolbox shows every font, chart, and shape with a picture. Click one and Studio
          drops the code in for you.
          <div class="coach-btns">
            <button class="accent small" id="tbxcoachok">Show me</button>
            <button class="ghost small" id="tbxcoachno">Got it</button>
          </div>
        </div>
      </span>
      <label class="toggle" title="Suggest helpers, fonts, colors, and settings as you type, turn it off any time"><input type="checkbox" id="actoggle"> Autocomplete</label>
      <span class="edbar-hint">Fonts, charts, and shapes, click to add them.</span>
      <span class="spacer"></span>
      <button class="ghost" id="sprbtn" title="Draw pixel art on a grid, Studio writes the code">Pixel art</button>
      <button class="ghost" id="reload"
              title="Re-read the files from your computer, use this if you changed them in another program">Reload</button>
    </div>
    <div class="banner" id="banner" hidden></div>
    <div class="edwrap">
      <pre id="edhl" aria-hidden="true"></pre>
      <textarea id="ed" spellcheck="false" autocomplete="off" autocapitalize="off"></textarea>
      <div id="acmenu" class="acmenu" role="listbox" hidden></div>
    </div>
    <div class="pane-foot" id="edfoot">These are the real files on your computer, edit them here or in any other program.</div>
  </section>

  <!-- RIGHT: the live preview -->
  <section class="right">
    <div class="pane-head rhead">
      <span class="ptitle">Live preview</span>
      <label class="toggle" title="Draw a faint line around every pixel">
        <input type="checkbox" id="grid" checked> Pixel grid</label>
      <label class="toggle" title="See what your app shows at a different date and time, great for clocks and countdowns">
        Time travel <input type="datetime-local" id="nowfld"></label>
      <button class="ghost small" id="nowclear" title="Back to right now">Now</button>
      <button class="ghost small" id="placebtn"
              title="Drop a PNG on the panel and drag it into place">Place image</button>
      <button class="ghost small" id="pngbtn"
              title="Download the panel as a crisp PNG image">Save PNG</button>
      <span class="coords" id="coords"
            title="Point at the preview to see which pixel is under your mouse">x, y</span>
    </div>
    <div class="rbody">
      <div class="busy" id="busy" hidden><span class="sp"></span> Rendering&hellip;</div>
      <div id="panels"><p class="rhint">Rendering your preview&hellip;</p></div>
      <div class="card" id="placecard" hidden>
        <div class="card-head">
          <span class="card-title">Place an image</span>
          <button class="ghost small" id="placeclose">Done</button>
        </div>
        <div class="card-hint">Drag an image on the panel to move it. Click one, then use the
          arrow keys to nudge it a pixel at a time (hold Shift for 8). Drag the green corner to
          resize. The code updates as you go.</div>
        <button class="ghost small" id="placeadd">+ Add an image</button>
        <div class="pngpicks" id="placepick" hidden></div>
      </div>
      <div class="card" id="inputscard" hidden>
        <div class="card-head">
          <span class="card-title">Your app&rsquo;s settings</span>
          <button class="ghost small" id="addinput" title="Add a setting without writing any YAML">+ Add setting</button>
        </div>
        <div class="card-hint">People fill these in when they add your app. Try different values, the preview updates as you type.</div>
        <div class="inputs" id="inputs" data-built="no"></div>
      </div>
      <div class="card" id="consolecard" hidden>
        <div class="card-title">Messages from your code</div>
        <div class="card-hint">Anything your code prints shows up here, plus details when you press Validate.</div>
        <pre id="console"></pre>
      </div>
    </div>
  </section>
</main>

<!-- Create-New-App dialog -->
<div class="overlay" id="newmodal" hidden>
  <div class="modal">
    <h2>Create a new app</h2>
    <p>Studio copies a working template app into a new folder, so you start from
       something that already runs, never a blank page. Set it up below, then edit it.</p>
    <label class="mlabel" for="newname">App name</label>
    <input id="newname" placeholder="e.g. My Weather" maxlength="60">
    <div class="slug" id="newslug"></div>
    <label class="mlabel" for="newwidth">Panel width</label>
    <select id="newwidth" class="mfull">
      <option value="64">64 x 32 (one panel)</option>
      <option value="128" selected>128 x 32 (two panels)</option>
      <option value="192">192 x 32 (three panels)</option>
      <option value="384">384 x 32 (six panels, the max)</option>
    </select>
    <label class="mlabel" for="newcat">Category</label>
    <select id="newcat" class="mfull">
      <option>Lifestyle</option><option>Sports</option><option>Finance</option>
      <option>Weather</option><option>Time</option><option>News</option>
      <option>Entertainment</option><option>Science</option><option>Fun</option>
      <option>Other</option>
    </select>
    <label class="mlabel">Settings to start with</label>
    <div class="mhint">Pick a type for each. You can add more, or fine-tune them, later.</div>
    <div class="newsettings" id="newsettings"></div>
    <button class="ghost small" id="newaddsetting" type="button">+ Add a setting</button>
    <div class="mErr" id="newerr"></div>
    <div class="modal-btns">
      <button class="ghost" id="newcancel">Cancel</button>
      <button class="accent" id="newok">Create app</button>
    </div>
  </div>
</div>

<!-- Add-setting dialog -->
<div class="overlay" id="inputmodal" hidden>
  <div class="modal">
    <h2>Add a setting</h2>
    <p>Choose the kind of control people see. Studio writes the YAML into your
       manifest.yaml, no typing required.</p>
    <label class="mlabel" for="inkey">Name (used in your code)</label>
    <input id="inkey" placeholder="e.g. zip" maxlength="40">
    <label class="mlabel" for="inlabel">Label people see</label>
    <input id="inlabel" placeholder="e.g. Zip code" maxlength="60">
    <label class="mlabel" for="intype">Type of control</label>
    <select id="intype" class="mfull">
      <option value="free-text">Text box</option>
      <option value="number">Number</option>
      <option value="dropdown">Dropdown (pick one)</option>
      <option value="selection">Multi-select (pick many)</option>
      <option value="checkbox">Checkbox (on / off)</option>
      <option value="date">Date</option>
      <option value="date-past">Date (past only)</option>
      <option value="color">Color</option>
    </select>
    <div id="inchoicewrap" hidden>
      <label class="mlabel" for="inchoices">Choices (comma separated)</label>
      <input id="inchoices" placeholder="e.g. red, green, blue">
    </div>
    <label class="mlabel" for="indefault">Default value (optional)</label>
    <input id="indefault" placeholder="optional">
    <div class="mErr" id="inerr"></div>
    <div class="modal-btns">
      <button class="ghost" id="incancel">Cancel</button>
      <button class="accent" id="inok">Add setting</button>
    </div>
  </div>
</div>

<!-- Toolbox: font browser + drawing-helper inventory -->
<div class="overlay" id="tbxmodal" hidden>
  <div class="modal tbx">
    <div class="tbx-head">
      <span class="tbx-title">Toolbox</span>
      <div class="tbx-tabs">
        <button class="tbx-tab active" data-tab="insert">Insert</button>
        <button class="tbx-tab" data-tab="icons">Icons</button>
        <button class="tbx-tab" data-tab="fonts">Fonts</button>
      </div>
      <span class="spacer"></span>
      <a class="tbxdocs" href="https://glance-led.dev" target="_blank" rel="noopener">Dev docs &#8599;</a>
      <button class="ghost small" id="tbxclose">Close</button>
    </div>
    <div class="tbx-body" id="tbxbody"><div class="tbx-loading">Loading the toolbox&hellip;</div></div>
    <div class="tbx-foot" id="tbxfoot">Hover a tile to see the code it adds. Click to drop it in at your cursor.</div>
  </div>
</div>

<div class="overlay" id="sprmodal" hidden>
  <div class="modal spr">
    <h2>Pixel art</h2>
    <p class="sprsub">Click or drag to paint. Click a filled pixel with the same color to erase it. Studio writes the code into your app.</p>
    <div class="spr-toolbar">
      <label class="mlabel">Grid
        <select id="sprsize">
          <option value="8x8">8 x 8</option>
          <option value="16x8">16 x 8</option>
          <option value="16x16" selected>16 x 16</option>
          <option value="24x16">24 x 16</option>
          <option value="32x16">32 x 16</option>
          <option value="32x32">32 x 32</option>
        </select></label>
      <div class="spr-pal" id="sprpal"></div>
      <button class="ghost small" id="sprclear" type="button">Clear</button>
    </div>
    <canvas id="sprcanvas" width="320" height="320"></canvas>
    <div class="mErr" id="sprerr"></div>
    <div class="modal-btns">
      <button class="ghost" id="sprcancel" type="button">Cancel</button>
      <button class="accent" id="sprok" type="button">Insert code</button>
    </div>
  </div>
</div>

<!-- Validate & Submit: explain what publishing does, get the OK, then do it -->
<div class="overlay" id="submitmodal" hidden>
  <div class="modal">
    <h2>Publish your app</h2>
    <p>You don't need to know git or how to fork, Studio does it all for you with the
       GitHub sign-in you already use. Here's what happens when you click Publish:</p>
    <ol class="pubsteps">
      <li>Make sure you have your own <b>fork</b> (your personal copy of the app catalog on
          GitHub), and <b>create one for you</b> if you don't have it yet.</li>
      <li>Commit <b id="pubslug">your app</b> and push it to your fork on its own branch.</li>
      <li>Open a <b>pull request</b> to add it to the app catalog.</li>
    </ol>
    <p class="pubnote">Nothing is merged automatically, the Glance team reviews every app.
       Your other files aren't touched, and you can publish more apps the same way with no
       re-setup.</p>
    <label class="pubagree"><input type="checkbox" id="submitagree">
      <span>I understand Studio will create a fork if needed and run these git and GitHub
      actions for me.</span></label>
    <div class="pubprogress" id="pubprogress" hidden></div>
    <div class="mErr" id="submiterr"></div>
    <div class="modal-btns">
      <button class="ghost" id="submitcancel" type="button">Cancel</button>
      <button class="accent" id="submitgo" type="button" disabled>Publish</button>
    </div>
  </div>
</div>

<!-- Confirm before importing a dropped image file -->
<div class="overlay" id="importmodal" hidden>
  <div class="modal">
    <h2>Import this image?</h2>
    <p>Studio will copy <b id="importname">this image</b> into this app's <code>assets/</code>
       folder and add a line to draw it. Only import images you meant to add to your app.</p>
    <img id="importpreview" class="importprev" alt="Dropped image preview" hidden>
    <div class="modal-btns">
      <button class="ghost" id="importcancel" type="button">Cancel</button>
      <button class="accent" id="importok" type="button">Import image</button>
    </div>
  </div>
</div>

<script>__JS__</script>
</body></html>"""


def studio_html(app_dir: Path) -> str:
    """The single-page Studio UI (the app name only seeds the title)."""
    page = _HTML.replace("__CSS__", _CSS).replace("__JS__", _JS)
    return page.replace("<title>Glance Dev Studio</title>",
                        f"<title>{html.escape(app_dir.name)}, Glance Dev Studio</title>")


# ============================================================================
# Flask server.
# ============================================================================
def create_server(app_dir: Path):
    from flask import Flask, Response, jsonify, request

    app_dir = Path(app_dir).resolve()

    def _looks_like_app(p):
        return ((p / "manifest.yaml").exists() or (p / "app.star").exists()
                or (p / "app.py").exists())

    def _find_apps_root(d):
        # New apps must always land in the project's apps/ folder, no matter where
        # Studio was launched from. Checked most-confident first.
        if d.name == "apps":
            return d                         # launched on the apps/ folder itself
        if d.parent.name == "apps":
            return d.parent                  # normal: launched on apps/<name>
        for p in [d] + list(d.parents):
            if (p / "apps").is_dir():
                return p / "apps"            # launched on the project root
            if p.name == "apps":
                return p
        return d.parent                      # last resort

    base = _find_apps_root(app_dir)  # the apps/ folder, for the picker + Create New App

    # A real app always lives directly inside apps/. If Studio was opened somewhere
    # that isn't (the project root, or the gdn package folder, which has its own
    # app.py), fall back to the first real app in apps/ so the editor has content and
    # we never try to render the SDK itself as if it were an app.
    if (app_dir.parent != base or not _looks_like_app(app_dir)) and base.is_dir():
        here = sorted(p for p in base.iterdir() if p.is_dir() and _looks_like_app(p))
        if here:
            app_dir = here[0]

    def _list_apps():
        """Every sibling folder that looks like an app (has a manifest or code)."""
        try:
            names = {p.name for p in base.iterdir()
                     if (p / "manifest.yaml").exists() or (p / "app.star").exists()
                     or (p / "app.py").exists()}
            names.add(app_dir.name)
            return sorted(names)
        except Exception:  # noqa: BLE001
            return [app_dir.name]

    def _resolve():
        """The app the request targets: ?app=<name> if it's a valid sibling, else the
        one the Studio was launched on. Never escapes the apps/ folder."""
        name = request.args.get("app")
        if name:
            cand = (base / name).resolve()
            if cand.parent == base and cand.is_dir():
                return cand
        return app_dir

    def _starter_dir():
        """The template that `gdn new` scaffolds from (the Starlark example)."""
        from .cli import TEMPLATES
        return TEMPLATES / "example-star"

    server = Flask("gdn.studio")

    @server.after_request
    def _no_cache(resp):
        # This is a local dev tool that gets restarted with new code often. Never let
        # the browser serve a stale page/script, or a restart silently runs old JS.
        resp.headers["Cache-Control"] = "no-store, must-revalidate"
        resp.headers["Pragma"] = "no-cache"
        return resp

    # ---- the page -----------------------------------------------------
    @server.get("/")
    def index():
        return studio_html(app_dir)

    # ---- app browsing + files ------------------------------------------
    @server.get("/apps")
    def apps():
        return jsonify({"apps": _list_apps(), "current": app_dir.name})

    @server.get("/files")
    def get_files():
        d = _resolve()
        contents, absent = {}, []
        for f in EDITABLE:
            if (d / f).exists():
                contents[f] = (d / f).read_text(encoding="utf-8")
            else:
                contents[f] = ""
                absent.append(f)
        return jsonify({"app": d.name, "files": contents, "missing": absent})

    @server.get("/mtime")
    def files_mtime():
        """Latest change-time of the editable files, so the browser can auto-reload
        when you edit them in another program."""
        d = _resolve()
        latest = 0.0
        for f in EDITABLE:
            try:
                latest = max(latest, (d / f).stat().st_mtime)
            except OSError:
                pass
        return jsonify({"mtime": latest})

    @server.post("/files")
    def save_files():
        d = _resolve()
        data = request.get_json(force=True, silent=True) or {}
        # Safety net against cross-app writes: never let one app's manifest be
        # saved into a different app's folder. If the incoming manifest carries
        # the id of another existing app, refuse. (This is what clobbered the
        # message app with countdown when duplicate Studios got confused.)
        man = data.get("manifest.yaml")
        if isinstance(man, str):
            mm = re.search(r'(?m)^id:[ \t]*([A-Za-z0-9_-]+)', man)
            incoming = mm.group(1) if mm else None
            if incoming and incoming != d.name and base.is_dir():
                others = {p.name for p in base.iterdir() if p.is_dir()}
                if incoming in others:
                    return jsonify({"ok": False, "error": (
                        f"That looks like the \"{incoming}\" app's manifest, not \"{d.name}\". "
                        f"Refusing to save it into the {d.name} folder. "
                        f"Re-select {d.name} in the app list, then save.")})
        try:
            for fname in EDITABLE:
                if fname in data and isinstance(data[fname], str):
                    # writes restricted to the whitelisted names in the app folder
                    (d / fname).write_text(data[fname], encoding="utf-8")
            return jsonify({"ok": True, "error": None})
        except Exception as e:  # noqa: BLE001
            return jsonify({"ok": False, "error": str(e)})

    # ---- image placement tool ------------------------------------------
    @server.get("/pngs")
    def pngs():
        """List the PNG files an app can draw (its assets/ folder, then its root),
        for the Place-image picker."""
        d = _resolve()
        found = []
        for folder in (d / "assets", d):
            if folder.is_dir():
                for p in sorted(folder.glob("*.png")):
                    if p.name not in found:
                        found.append(p.name)
        return jsonify({"pngs": found})

    @server.get("/asset")
    def asset():
        """Serve one PNG from an app's folder, for the draggable placement overlay.
        Only a bare filename is honored, so a request can't escape the app folder."""
        d = _resolve()
        name = Path(request.args.get("file", "")).name   # basename only, no traversal
        if not name.lower().endswith(".png"):
            return ("not a png", 404)
        for folder in (d / "assets", d):
            f = folder / name
            if f.is_file():
                return Response(f.read_bytes(), mimetype="image/png")
        return ("not found", 404)

    @server.post("/upload-image")
    def upload_image():
        """Save a dropped PNG into the app's assets/ folder, downscaled to fit the panel."""
        from PIL import Image
        import io
        d = _resolve()
        f = request.files.get("file")
        if f is None:
            return jsonify({"ok": False, "error": "No file arrived."})
        raw = f.read(8 * 1024 * 1024 + 1)                       # hard cap: 8 MB
        if len(raw) > 8 * 1024 * 1024:
            return jsonify({"ok": False, "error": "That image is over 8 MB. Use a smaller file."})
        try:
            im = Image.open(io.BytesIO(raw)); im.load()
        except Exception:  # noqa: BLE001
            return jsonify({"ok": False, "error": "That file isn't an image Studio can read."})
        if im.format != "PNG":
            return jsonify({"ok": False, "error": f"That's a {im.format or 'non-PNG'} file. "
                            "Panels use PNGs, re-export it as .png and drop it again."})
        stem = Path(f.filename or "image").stem
        name = re.sub(r"-{2,}", "-", re.sub(r"[^a-z0-9._-]+", "-", stem.lower())).strip("-.") or "image"
        from .runner import load_manifest
        try:
            m = load_manifest(d)
        except Exception:  # noqa: BLE001
            m = {}
        pw, ph = int(m.get("width", 192) or 192), int(m.get("height", 32) or 32)
        resized = False
        if im.width > pw or im.height > ph:                    # never bigger than the panel
            k = min(pw / im.width, ph / im.height)
            im = im.convert("RGBA").resize((max(1, round(im.width * k)),
                                            max(1, round(im.height * k))), Image.LANCZOS)
            resized = True
        folder = d / "assets"; folder.mkdir(exist_ok=True)
        final, n = f"{name}.png", 2
        while (folder / final).exists() or (d / final).exists():   # never overwrite; suffix instead
            final = f"{name}-{n}.png"; n += 1
        if resized:
            im.save(folder / final)
        else:
            (folder / final).write_bytes(raw)                  # keep original bytes if untouched
        return jsonify({"ok": True, "name": final, "w": im.width, "h": im.height, "resized": resized})

    @server.get("/toolbox.json")
    def toolbox():
        """The font browser + drawing-helper inventory, each with a rendered preview."""
        return jsonify(_toolbox_payload())

    # ---- Create New App -------------------------------------------------
    @server.post("/new")
    def new_app():
        """Scaffold apps/<slug>/ tailored to the Create New App dialog: the
        chosen panel width, category, and number of starter settings."""
        from .cli import _slugify
        data = request.get_json(force=True, silent=True) or {}
        name = str(data.get("name", "")).strip()
        if not name:
            return jsonify({"ok": False, "error": "Give your app a name first."})
        slug = _slugify(name)
        dest = base / slug
        # dest.iterdir() raises if a stray *file* named apps/<slug> exists, so test
        # is_file() first, otherwise the create dialog would 500 with no message.
        if dest.exists() and (dest.is_file() or any(dest.iterdir())):
            return jsonify({"ok": False,
                            "error": f'There is already an app called "{slug}", pick another name.'})
        try:
            width = int(data.get("width") or 128)
            width = 128 if (width < 1 or width > 384) else width
            category = str(data.get("category") or "Other").strip() or "Other"
            raw = data.get("settings")
            if isinstance(raw, list):
                specs = [s for s in raw if isinstance(s, dict)][:8]
            elif isinstance(raw, bool):
                specs = []
            elif isinstance(raw, int):            # legacy: a plain count of text settings
                specs = [{"type": "free-text"} for _ in range(max(0, min(8, raw)))]
            else:
                specs = []
            _scaffold_new_app(dest, slug, name, width, category, specs)
            return jsonify({"ok": True, "app": slug})
        except Exception as e:  # noqa: BLE001
            return jsonify({"ok": False, "error": f"Couldn't create the app: {e}"})

    @server.post("/starter")
    def starter_file():
        """Write one starter file (manifest.yaml or app.star) into an app that's
        missing it, the one-click fix behind the editor banner."""
        from .cli import _personalize
        d = _resolve()
        data = request.get_json(force=True, silent=True) or {}
        fname = str(data.get("file", ""))
        if fname not in REQUIRED:
            return jsonify({"ok": False, "error": f"Can't create {fname!r} here."})
        if (d / fname).exists():
            return jsonify({"ok": False, "error": f"{fname} already exists."})
        try:
            src = _starter_dir() / fname
            (d / fname).write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
            if fname == "manifest.yaml":
                _personalize(d)  # name the manifest after this folder, not the template
            return jsonify({"ok": True})
        except Exception as e:  # noqa: BLE001
            return jsonify({"ok": False, "error": str(e)})

    # ---- rendering + checking -------------------------------------------
    @server.get("/frames.json")
    def frames():
        """Render every page of the app, the live preview polls this."""
        inputs = {k: v for k, v in request.args.items() if k not in ("app", "now")}
        now = request.args.get("now") or None
        try:
            return jsonify(render_frames(_resolve(), inputs, now=now))
        except Exception as e:  # noqa: BLE001
            # A broken manifest.yaml (bad YAML, non-numeric width) throws before the
            # renderer's own try/except. Return it as a normal error the UI can show,
            # never a 500 HTML page that the front end can't parse.
            return jsonify({"ok": False, "error": f"Couldn't read this app: {e}",
                            "app": None, "inputs": [], "pages": [], "logs": []})

    @server.post("/lint")
    def lint():
        """Parse-only syntax check of the (unsaved) app.star buffer. Never runs the app,
        it's the same starlark.parse the renderer does before eval, ~1ms, so it's safe to
        call on every typing pause. Returns the first syntax/indentation error, if any."""
        import starlark
        data = request.get_json(force=True, silent=True) or {}
        text = data.get("text")
        if data.get("file") != "app.star" or not isinstance(text, str) or not text.strip():
            return jsonify({"errors": []})
        try:
            starlark.parse("app.star", text)
            return jsonify({"errors": []})
        except Exception as e:  # noqa: BLE001  (starlark.StarlarkError on a bad parse)
            s = str(e)
            loc = re.search(r"-->\s*app\.star:(\d+):(\d+)", s)
            msg = next((ln[6:].strip() for ln in s.splitlines() if ln.startswith("error:")), "syntax error")
            msg = re.sub(r"^Parse error:\s*", "", msg)
            msg = re.sub(r",?\s*expected one of.*$", "", msg)
            line = int(loc.group(1)) if loc else 1
            col = int(loc.group(2)) if loc else 1
            if msg == "incorrect indentation" and col > 1:
                lines = text.splitlines()
                if line <= len(lines) and col > len(lines[line - 1]):
                    line += 1
            return jsonify({"errors": [{"line": line, "col": col, "msg": msg}]})

    def _check(d: Path) -> dict:
        """Full check: does every page draw, and does the linter like the files?
        Returns plain-language results for the status pill + console."""
        from .check import check_app
        problems, tips = [], []
        try:
            res = render_frames(d, {})
        except Exception as e:  # noqa: BLE001
            res = {"ok": False, "error": f"Couldn't read this app: {e}", "pages": []}
        if not res.get("ok"):
            problems.append(str(res.get("error")))
        lint_errors, lint_warns = check_app(d)
        problems.extend(lint_errors)
        tips.extend(lint_warns)
        if problems:
            return {"ok": False, "message": "Problem found, details below",
                    "problems": problems, "tips": tips}
        n = len(res.get("pages", []))
        msg = f"Looks good, {n} page{'' if n == 1 else 's'} draw{'s' if n == 1 else ''} cleanly"
        if tips:
            msg += f" ({len(tips)} tip{'' if len(tips) == 1 else 's'} below)"
        return {"ok": True, "message": msg, "problems": [], "tips": tips}

    @server.get("/validate")
    def validate():
        d = _resolve()
        result = _check(d)
        if result.get("ok"):
            # Refresh the app's catalog preview images so preview/ always matches the code.
            try:
                from .preview import write_previews
                write_previews(d)
            except Exception:  # noqa: BLE001
                pass           # never fail validation because a preview couldn't be saved
        return jsonify(result)

    @server.post("/submit")
    def submit():
        # Validate, then create a fork (if needed), push the app, and open a pull
        # request, all through the developer's GitHub sign-in. The git/GitHub work is
        # in gdn/submit.py; the browser modal takes their OK before this runs.
        from .submit import submit_via_fork, SubmitError
        d = _resolve()
        result = _check(d)
        if not result["ok"]:
            result["message"] = "Fix this first, details below"
            return jsonify(result)
        try:
            info = submit_via_fork(d)
        except SubmitError as e:
            msg = str(e)
            return jsonify({"ok": False, "message": msg.split("\n", 1)[0], "problems": [msg]})
        except Exception as e:  # noqa: BLE001
            return jsonify({"ok": False, "message": f"Couldn't publish: {e}"})
        try:
            webbrowser.open(info["pr_url"])
        except Exception:  # noqa: BLE001
            pass
        forked = "Created your fork, then " if info.get("created_fork") else ""
        return jsonify({"ok": True,
                        "pr_url": info["pr_url"], "fork": info["fork"], "branch": info["branch"],
                        "message": f"{forked}opened your pull request on {info['fork']}."})

    return server


def serve(app_dir, host: str = "127.0.0.1", port: int = 8766, open_browser: bool = True):
    # Refuse to start a second copy on a port that's already serving. On Windows
    # two instances can share a port and route requests into a hung one, which
    # makes both appear frozen. Point the user at the running one instead.
    import socket
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as probe:
        probe.settimeout(0.3)
        if probe.connect_ex((host, port)) == 0:
            raise SystemExit(
                f"Glance Dev Studio already appears to be running at http://{host}:{port}/\n"
                "Open that in your browser, or stop the other one first (Ctrl+C in its\n"
                "terminal) and relaunch. Two copies on one port make both hang.")

    server = create_server(app_dir)
    url = f"http://{host}:{port}/"
    print(f"Glance Dev Studio: {url}   (Ctrl+C to stop)")
    if open_browser:
        try:
            webbrowser.open(url)
        except Exception:  # noqa: BLE001
            pass
    server.run(host=host, port=port, debug=False, use_reloader=False, threaded=True)
