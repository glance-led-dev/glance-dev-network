"""A small pop-up GUI that generates a GDN app under `apps/`.

Run it with:  gdn generate       (or:  python -m gdn.yaml_generator)

A native desktop window (Tkinter, bundled with Python — no extra installs) opens.
Fill in the plain-English fields, add the settings your app needs, and click
"Generate" — it writes `apps/<id>/manifest.yaml` (and a starter `app.star`).

The YAML-building logic lives in `build_yaml()` — a pure function with no GUI
dependency, so it can be reused and tested on its own.
"""
from __future__ import annotations

import re
from typing import List, Dict

# The widget vocabulary the manifest's `app_input_type` accepts. "" = leave it out
# and let the preview form infer the widget from the data `type`.
APP_INPUT_TYPES = ["", "free-text", "dropdown", "selection", "checkbox",
                   "date", "date-past", "color"]
DATA_TYPES = ["string", "number", "choice"]
# app_input_type values for which a `choices:` list is meaningful.
CHOICE_WIDGETS = {"dropdown", "selection"}


def _scalar(v) -> str:
    """Render a YAML scalar, quoting when leaving it bare would change its meaning
    (numbers, zips with leading zeros, dates, `#hex`, values with YAML punctuation)."""
    s = str(v)
    risky = (s != s.strip() or s == ""
             or re.search(r'[:#\[\]{}&*?|<>=!%@`"\',]', s)
             or re.match(r'^[\d.+-]', s))       # starts number/date/version/sign
    if risky:
        return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'
    return s


def build_yaml(meta: Dict, inputs: List[Dict]) -> str:
    """Build a manifest.yaml string from metadata + a list of input dicts.

    meta keys:   id, name, author, description, entry, width, height, refresh,
                 pages (list[str]), version
    input keys:  key, type, app_input_type, label, default, choices (list), help
    """
    app_id = (meta.get("id") or "my-app").strip()
    out = [
        "gdn: 1",
        f"id: {app_id}",
        f"version: {meta.get('version') or '0.1.0'}",
        f"name: {meta.get('name') or app_id}",
        f"author: {meta.get('author') or 'your-name'}",
    ]
    if meta.get("description"):
        out.append(f"description: {meta['description']}")
    out += [
        f"entry: {meta.get('entry') or 'app.star'}",
        f"width: {int(meta.get('width') or 128)}",
        f"height: {int(meta.get('height') or 32)}",
        f"refresh: {int(meta.get('refresh') or 300)}",
    ]
    pages = [p for p in (meta.get("pages") or ["main"]) if str(p).strip()]
    out.append("pages: [" + ", ".join(pages) + "]")

    rows = [i for i in inputs if (i.get("key") or "").strip()]
    if rows:
        out.append("inputs:")
        for i in rows:
            key = i["key"].strip()
            out.append(f"  - key: {key}")
            out.append(f"    type: {i.get('type') or 'string'}")
            widget = (i.get("app_input_type") or "").strip()
            if widget:
                out.append(f"    app_input_type: {widget}")
            out.append(f"    label: {i.get('label') or key}")
            default = i.get("default")
            if default not in (None, ""):
                out.append(f"    default: {_scalar(default)}")
            choices = [c.strip() for c in (i.get("choices") or []) if str(c).strip()]
            if choices:
                out.append("    choices: [" + ", ".join(_scalar(c) for c in choices) + "]")
            if i.get("help"):
                out.append(f"    help: {i['help']}")
    return "\n".join(out) + "\n"


def build_appstar_stub(pages: List[str]) -> str:
    """A minimal, runnable app.star: one function per page that draws its name."""
    pages = [p for p in pages if str(p).strip()] or ["main"]
    blocks = []
    for p in pages:
        blocks.append(
            f'def {p}(c, ctx):\n'
            f'    c.fill("black")\n'
            f'    c.text("{p}", 4, 12, font="5x7", color="white")\n'
        )
    return "\n".join(blocks)


# --------------------------------------------------------------------------- GUI

# Palette + fonts for the window (light theme, indigo accent).
_C = {
    "bg": "#eef0f4", "card": "#ffffff", "border": "#d7dae2", "line": "#e7e9ef",
    "text": "#1f2430", "muted": "#8b90a0", "accent": "#4f46e5",
    "accent_hi": "#4338ca", "danger": "#e5484d",
    "yaml_bg": "#1e2030", "yaml_fg": "#c8d0e0",
    "y_key": "#7dd3fc", "y_str": "#a6e3a1", "y_num": "#fab387",
    "y_com": "#6c7393", "y_val": "#c4b5fd",
}
_F = {
    "ui": ("Segoe UI", 10), "ui_semi": ("Segoe UI Semibold", 10),
    "title": ("Segoe UI", 17, "bold"), "sub": ("Segoe UI", 10),
    "mini": ("Segoe UI", 8), "h2": ("Segoe UI Semibold", 11), "mono": ("Consolas", 10),
}


def _style(root):
    import tkinter as tk
    from tkinter import ttk
    style = ttk.Style(root)
    try:
        style.theme_use("clam")          # most themable ttk theme
    except tk.TclError:
        pass
    C, F = _C, _F
    style.configure(".", background=C["bg"], foreground=C["text"], font=F["ui"])
    style.configure("TFrame", background=C["bg"])
    style.configure("Card.TFrame", background=C["card"])
    style.configure("TLabel", background=C["bg"], foreground=C["text"])
    style.configure("Card.TLabel", background=C["card"], foreground=C["text"])
    style.configure("H2.TLabel", background=C["card"], foreground=C["text"], font=F["h2"])
    style.configure("Title.TLabel", background=C["bg"], font=F["title"])
    style.configure("Sub.TLabel", background=C["bg"], foreground=C["muted"], font=F["sub"])
    style.configure("Mini.TLabel", background=C["card"], foreground=C["muted"], font=F["mini"])
    style.configure("Hint.TLabel", background=C["card"], foreground=C["muted"], font=F["mini"])
    style.configure("TEntry", fieldbackground="#ffffff", bordercolor=C["border"],
                    lightcolor=C["border"], darkcolor=C["border"], insertcolor=C["text"])
    style.configure("TCombobox", fieldbackground="#ffffff", background="#ffffff",
                    bordercolor=C["border"], arrowcolor=C["muted"])
    style.map("TCombobox", fieldbackground=[("readonly", "#ffffff")])
    style.configure("TCheckbutton", background=C["bg"], foreground=C["muted"], font=F["mini"])
    # buttons
    style.configure("TButton", background="#e3e6ee", foreground=C["text"],
                    bordercolor=C["border"], focusthickness=0, padding=(12, 6))
    style.map("TButton", background=[("active", "#d5d9e6")])
    style.configure("Accent.TButton", background=C["accent"], foreground="#ffffff",
                    padding=(16, 8), font=F["ui_semi"])
    style.map("Accent.TButton", background=[("active", C["accent_hi"])])
    style.configure("Add.TButton", background=C["card"], foreground=C["accent"],
                    bordercolor=C["accent"], padding=(10, 5))
    style.map("Add.TButton", background=[("active", "#eef0ff")])
    style.configure("Ghost.TButton", background=C["card"], foreground=C["danger"],
                    bordercolor=C["card"], padding=(2, 0))
    style.map("Ghost.TButton", background=[("active", "#fdecec")])
    return style


def _highlight(txt):
    """Cheap YAML syntax coloring in the preview Text widget."""
    C = _C
    for tag in ("com", "key", "str", "num", "val"):
        txt.tag_remove(tag, "1.0", "end")
    txt.tag_config("com", foreground=C["y_com"])
    txt.tag_config("key", foreground=C["y_key"])
    txt.tag_config("str", foreground=C["y_str"])
    txt.tag_config("num", foreground=C["y_num"])
    txt.tag_config("val", foreground=C["y_val"])
    lines = txt.get("1.0", "end-1c").split("\n")
    for r, line in enumerate(lines, start=1):
        s = line.lstrip()
        if s.startswith("#"):
            txt.tag_add("com", f"{r}.0", f"{r}.end"); continue
        m = re.match(r'^(\s*(?:-\s*)?)([A-Za-z_][\w-]*):', line)
        if m:
            txt.tag_add("key", f"{r}.{m.start(2)}", f"{r}.{m.end(2)}")
        for mm in re.finditer(r'"[^"]*"', line):
            txt.tag_add("str", f"{r}.{mm.start()}", f"{r}.{mm.end()}")
        for mm in re.finditer(r'(?<![\w"])(-?\d+(?:\.\d+)?)(?![\w"])', line):
            txt.tag_add("num", f"{r}.{mm.start()}", f"{r}.{mm.end()}")
        for w in ("free-text", "dropdown", "selection", "checkbox",
                  "date-past", "date", "color"):
            for mm in re.finditer(r'(?<![\w-])' + re.escape(w) + r'(?![\w-])', line):
                txt.tag_add("val", f"{r}.{mm.start()}", f"{r}.{mm.end()}")


# Each metadata field: (label, key, example, prefilled?, plain-English explanation)
_META = [
    ("App id",      "id",          "local-aqi",              False, "becomes the folder name under apps/ — lowercase, hyphens, no spaces"),
    ("Name",        "name",        "Local AQI",              False, "the title people see when they add your app"),
    ("Author",      "author",      "your-name",              False, "your name or handle"),
    ("Description", "description", "Air quality for a zip.", False, "one short line describing what it shows"),
    ("Entry file",  "entry",       "app.star",               True,  "the code file that draws it — leave as app.star"),
    ("Width",       "width",       "128",                    True,  "panel width in pixels (up to 384)"),
    ("Height",      "height",      "32",                     True,  "always 32 — the panel is 32 pixels tall"),
    ("Refresh (s)", "refresh",     "3600",                   True,  "seconds between refreshes (3600 = once an hour)"),
    ("Pages",       "pages",       "main",                   True,  "screen names, comma-separated · the render URL ?page=1 is the first one"),
]

# Each input field: (row, col, concept label, example placeholder, char width)
_IN_TEXT = {
    "key":     (1, 0, "key · the name your code reads",   "zip",            14),
    "label":   (3, 0, "label · what the user sees",       "Zip code",       14),
    "default": (3, 1, "default · pre-filled value",       "90210",          12),
    "choices": (3, 2, "choices · options, comma-sep",     "metric, imperial", 16),
    "help":    (3, 3, "help · hint under the field",      "A US zip code.", 18),
}


def launch() -> int:
    try:
        import tkinter as tk
        from tkinter import ttk, messagebox
    except Exception:                                   # headless / no Tk
        print("Could not open a window: this Python has no Tkinter (GUI) support.\n"
              "Install a Python build that includes tk, or build the manifest by hand.")
        return 1

    from pathlib import Path
    C, F = _C, _F

    root = tk.Tk()
    root.title("GDN — app generator")
    root.geometry("1120x760")
    root.minsize(960, 640)
    root.configure(background=C["bg"])
    _style(root)

    meta_w: Dict[str, object] = {}       # field key -> Entry widget
    input_rows: List[dict] = []
    make_stub = tk.BooleanVar(value=True)

    def apps_dir() -> "Path":
        here = Path.cwd()
        for base in [here, *here.parents][:6]:
            if (base / "apps").is_dir():
                return base / "apps"
        return here / "apps"             # created on generate if missing

    # ---- placeholder-aware entry (grey example text that clears on focus) ----
    def ph_entry(parent, placeholder, width, value=""):
        e = ttk.Entry(parent, width=width)
        def show_ph():
            e._is_ph = True
            e.configure(foreground=C["muted"])
            e.delete(0, "end"); e.insert(0, placeholder)
        if value:
            e._is_ph = False
            e.configure(foreground=C["text"]); e.insert(0, value)
        else:
            show_ph()
        def on_in(_):
            if getattr(e, "_is_ph", False):
                e.delete(0, "end"); e.configure(foreground=C["text"]); e._is_ph = False
        def on_out(_):
            if not e.get().strip():
                show_ph()
            regen()
        e.bind("<FocusIn>", on_in)
        e.bind("<FocusOut>", on_out)
        e.bind("<KeyRelease>", regen)
        return e

    def val(w):
        return "" if getattr(w, "_is_ph", False) else w.get().strip()

    def collect():
        meta = {k: val(w) for k, w in meta_w.items()}
        meta["pages"] = [p.strip() for p in meta.get("pages", "").split(",") if p.strip()]
        for k, d in (("width", "128"), ("height", "32"), ("refresh", "3600")):
            meta[k] = meta.get(k) or d
        inputs = []
        for row in input_rows:
            inputs.append({
                "key": val(row["key"]),
                "type": row["type"].get(),
                "app_input_type": row["app_input_type"].get(),
                "label": val(row["label"]),
                "default": val(row["default"]),
                "choices": [c.strip() for c in val(row["choices"]).split(",") if c.strip()],
                "help": val(row["help"]),
            })
        return meta, inputs

    def regen(*_):
        meta, inputs = collect()
        try:
            text = build_yaml(meta, inputs)
        except Exception as e:
            text = f"# fix a field to generate\n# {e}"
        preview.delete("1.0", "end")
        preview.insert("1.0", text)
        _highlight(preview)
        app_id = meta.get("id") or "<app id>"
        gen_lbl.config(text=f"Generates:  apps/{app_id}/")

    # ---------------------------------------------------------------- layout
    head = ttk.Frame(root, padding=(18, 14, 18, 4))
    head.pack(fill="x")
    ttk.Label(head, text="Create a GDN app", style="Title.TLabel").pack(anchor="w")
    ttk.Label(head, text="Fill in the plain-English fields below. The grey text in each box is an "
                         "example. Click Generate and it writes a ready app into apps/.",
              style="Sub.TLabel", wraplength=1060, justify="left").pack(anchor="w")

    body = ttk.Frame(root, padding=(14, 6, 14, 14))
    body.pack(fill="both", expand=True)
    left = ttk.Frame(body)
    left.pack(side="left", fill="both", expand=True, padx=(0, 12))
    right = ttk.Frame(body)
    right.pack(side="right", fill="both")

    def card(parent, title):
        outer = tk.Frame(parent, background=C["border"], highlightbackground=C["border"],
                         highlightthickness=1)
        inner = ttk.Frame(outer, style="Card.TFrame", padding=12)
        inner.pack(fill="both", expand=True)
        if title:
            ttk.Label(inner, text=title, style="H2.TLabel").pack(anchor="w", pady=(0, 8))
        return outer, inner

    # ---- right pane (build first so regen can reference `preview`/`gen_lbl`) ----
    ttk.Label(right, text="This becomes apps/<id>/manifest.yaml", style="Sub.TLabel").pack(anchor="w")
    prev_wrap = tk.Frame(right, background=C["yaml_bg"], highlightthickness=1,
                         highlightbackground=C["border"])
    prev_wrap.pack(fill="both", expand=True, pady=(2, 8))
    preview = tk.Text(prev_wrap, width=46, height=28, wrap="none", relief="flat",
                      background=C["yaml_bg"], foreground=C["yaml_fg"],
                      insertbackground=C["yaml_fg"], font=F["mono"],
                      padx=12, pady=10, borderwidth=0)
    preview.pack(fill="both", expand=True)

    gen_lbl = ttk.Label(right, text="Generates:  apps/<app id>/", style="Sub.TLabel")
    gen_lbl.pack(anchor="w")
    bar = ttk.Frame(right)
    bar.pack(fill="x", pady=(4, 0))
    ttk.Checkbutton(bar, text="also write a starter app.star", variable=make_stub).pack(anchor="w")
    ttk.Button(bar, text="Generate app  →", style="Accent.TButton",
               command=lambda: generate()).pack(side="right", pady=(4, 0))
    ttk.Button(bar, text="Copy YAML", command=lambda: copy()).pack(side="right", padx=6, pady=(4, 0))

    # ---- metadata card ----
    meta_outer, meta_card = card(left, "About the app")
    meta_outer.pack(fill="x")
    grid = ttk.Frame(meta_card, style="Card.TFrame")
    grid.pack(fill="x")
    for r, (label, k, example, prefill, hint) in enumerate(_META):
        ttk.Label(grid, text=label, style="Card.TLabel").grid(row=r, column=0, sticky="w", pady=2)
        meta_w[k] = ph_entry(grid, example, 26, value=(example if prefill else ""))
        meta_w[k].grid(row=r, column=1, sticky="we", padx=8, pady=2)
        ttk.Label(grid, text=hint, style="Hint.TLabel").grid(row=r, column=2, sticky="w")
    grid.columnconfigure(1, weight=1)

    # ---- inputs section ----
    in_head = ttk.Frame(left)
    in_head.pack(fill="x", pady=(12, 2))
    ttk.Label(in_head, text="Settings the user fills in", style="Title.TLabel").pack(anchor="w")
    ttk.Label(in_head, text="Each of these becomes a box on the user's setup form when they add "
                            "your app — like a zip code or a color. Leave it empty if your app "
                            "needs no settings.",
              style="Sub.TLabel", wraplength=560, justify="left").pack(anchor="w")

    in_outer = tk.Frame(left, background=C["border"], highlightbackground=C["border"],
                        highlightthickness=1)
    in_outer.pack(fill="both", expand=True, pady=(6, 0))
    canvas = tk.Canvas(in_outer, highlightthickness=0, background=C["bg"])
    scroll = ttk.Scrollbar(in_outer, orient="vertical", command=canvas.yview)
    holder = ttk.Frame(canvas)
    holder.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    win = canvas.create_window((0, 0), window=holder, anchor="nw")
    canvas.bind("<Configure>", lambda e: canvas.itemconfig(win, width=e.width))
    canvas.configure(yscrollcommand=scroll.set)
    canvas.pack(side="left", fill="both", expand=True)
    scroll.pack(side="right", fill="y")

    ttk.Button(left, text="+  Add a setting", style="Add.TButton",
               command=lambda: add_input()).pack(anchor="w", pady=(8, 0))

    # ---------------------------------------------------------------- inputs
    def add_input(prefill=None):
        pf = prefill or {}
        outer = tk.Frame(holder, background=C["line"], highlightbackground=C["line"],
                         highlightthickness=1)
        outer.pack(fill="x", padx=6, pady=5)
        f = ttk.Frame(outer, style="Card.TFrame", padding=8)
        f.pack(fill="both", expand=True)
        row = {"frame": outer}
        row["type"] = tk.StringVar(value=pf.get("type", "string"))
        row["app_input_type"] = tk.StringVar(value=pf.get("app_input_type", "free-text"))

        def mini(txt, r, c):
            ttk.Label(f, text=txt, style="Mini.TLabel").grid(row=r, column=c, sticky="w", padx=3)

        def combo(var, r, c, values, w):
            cb = ttk.Combobox(f, textvariable=var, values=values, width=w, state="readonly")
            cb.grid(row=r, column=c, sticky="we", padx=3, pady=(0, 4))
            var.trace_add("write", regen)
            return cb

        # row A: key · widget · data-type · remove
        mini("key · the name your code reads", 0, 0)
        mini("widget · how the user enters it", 0, 1)
        mini("data type", 0, 2)
        row["key"] = ph_entry(f, "zip", 14, value=pf.get("key", ""))
        row["key"].grid(row=1, column=0, sticky="we", padx=3, pady=(0, 4))
        combo(row["app_input_type"], 1, 1, APP_INPUT_TYPES, 13)
        combo(row["type"], 1, 2, DATA_TYPES, 9)
        ttk.Button(f, text="✕ remove", style="Ghost.TButton",
                   command=lambda: (input_rows.remove(row), outer.destroy(), regen())
                   ).grid(row=1, column=3, sticky="e", padx=3)

        # row B: label · default · choices · help
        for name, (r, c, mlabel, example, w) in _IN_TEXT.items():
            mini(mlabel, r - 1, c)
            row[name] = ph_entry(f, example, w, value=pf.get(name, ""))
            row[name].grid(row=r, column=c, sticky="we", padx=3, pady=(0, 4))
        for c in range(4):
            f.columnconfigure(c, weight=1)

        def sync_choices(*_):
            on = row["app_input_type"].get() in CHOICE_WIDGETS
            row["choices"].configure(state="normal" if on else "disabled")
        row["app_input_type"].trace_add("write", sync_choices)
        sync_choices()

        input_rows.append(row)
        regen()

    # ---------------------------------------------------------------- actions
    def generate():
        meta, inputs = collect()
        app_id = meta.get("id", "").strip()
        if not re.match(r'^[a-z0-9][a-z0-9-]*$', app_id):
            messagebox.showerror(
                "Enter an App id first",
                "The App id becomes the folder name under apps/, so it must be\n"
                "lowercase letters, numbers and hyphens only — e.g. local-aqi.")
            return
        dest = apps_dir() / app_id
        if (dest / "manifest.yaml").exists():
            if not messagebox.askyesno(
                    "Already exists",
                    f"{dest}\nalready has a manifest.yaml.\n\nOverwrite it?"):
                return
        dest.mkdir(parents=True, exist_ok=True)
        (dest / "manifest.yaml").write_text(build_yaml(meta, inputs),
                                            encoding="utf-8", newline="\n")
        made = ["manifest.yaml"]
        star = dest / (meta.get("entry") or "app.star")
        if star.suffix == ".star" and not star.exists() and make_stub.get():
            star.write_text(build_appstar_stub(meta["pages"]),
                            encoding="utf-8", newline="\n")
            made.append(star.name)
        messagebox.showinfo(
            "App created",
            f"Created  apps/{app_id}/  with:\n  " + "\n  ".join(made) +
            f"\n\nSee it live:\n  gdn preview apps/{app_id}")

    def copy():
        root.clipboard_clear()
        root.clipboard_append(preview.get("1.0", "end-1c"))
        messagebox.showinfo("Copied", "manifest.yaml copied to the clipboard.")

    # one worked example row so the preview starts full and self-explanatory
    add_input({"key": "zip", "app_input_type": "free-text", "label": "Zip code",
               "default": "90210", "help": "A US zip code."})
    regen()
    root.mainloop()
    return 0


def main(argv=None) -> int:
    return launch()


if __name__ == "__main__":
    raise SystemExit(main())
