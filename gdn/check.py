"""`gdn check` — a friendly pre-flight lint for a GDN app.

Catches the common mistakes before you render or submit: a bad or mismatched `id`,
a placeholder `author`, a too-fast `refresh`, undeclared or unused assets, a page
with no matching function, and lowercase text in the UPPERCASE-only fonts. Plain
messages, exits non-zero only on real errors (warnings don't fail).
"""
from __future__ import annotations

import re
from pathlib import Path

from .runner import load_manifest

_KNOWN_KEYS = {
    "gdn", "id", "version", "name", "author", "description", "entry",
    "width", "height", "refresh", "pages", "inputs", "assets", "category",
}


def check_app(app_dir) -> tuple:
    """Return (errors, warnings) message lists for one app folder."""
    app_dir = Path(app_dir)
    errors, warns = [], []
    if not (app_dir / "manifest.yaml").exists():
        return ([f"no manifest.yaml in {app_dir.name}"], [])
    try:
        m = load_manifest(app_dir)
    except Exception as e:  # noqa: BLE001
        return ([f"manifest is not valid YAML ({e})"], [])

    app_id = str(m.get("id", "")).strip()
    if not app_id:
        errors.append("missing `id`")
    else:
        if not re.match(r"^[a-z0-9][a-z0-9-]*$", app_id):
            errors.append(f"`id` must be lowercase letters, digits, and hyphens (got {app_id!r})")
        if app_id != app_dir.name:
            warns.append(f"`id` ({app_id}) doesn't match the folder name ({app_dir.name})")

    if not str(m.get("name", "")).strip():
        warns.append("missing `name` (the title users see)")
    author = str(m.get("author", "")).strip()
    if not author or author.lower() == "your-name":
        warns.append("`author` is still the placeholder `your-name`")
    if not str(m.get("description", "")).strip():
        warns.append("missing `description` (a one-line summary)")

    try:
        w, h = int(m.get("width", 0)), int(m.get("height", 0))
        if not (1 <= w <= 384):
            errors.append(f"`width` must be 1-384 (got {w})")
        if h != 32:
            warns.append(f"`height` is normally 32 (got {h})")
    except (TypeError, ValueError):
        errors.append("`width`/`height` must be numbers")
    try:
        refresh = int(m.get("refresh", 0))
        if refresh and refresh < 60:
            warns.append(f"`refresh` {refresh}s is very fast; 60s+ is easier on data sources")
    except (TypeError, ValueError):
        warns.append("`refresh` should be a number of seconds")

    for k in m:
        if k not in _KNOWN_KEYS:
            warns.append(f"unknown manifest key `{k}` (typo?)")

    star = app_dir / "app.star"
    if star.exists():
        src = star.read_text(encoding="utf-8")
        pages = m.get("pages") or []
        names = pages if isinstance(pages, list) else [f"page{i + 1}" for i in range(int(pages or 0))]
        for pn in names:
            if not re.search(r"(?m)^\s*def\s+" + re.escape(str(pn)) + r"\s*\(", src):
                errors.append(f"page `{pn}` has no matching `def {pn}(c, ctx):` in app.star")
        declared = set(m.get("assets") or [])
        used = set(re.findall(r"""c\.image\(\s*['"]([^'"]+)['"]""", src))
        for a in sorted(used - declared):
            errors.append(f"draws `{a}` but it's not listed under `assets:`")
        for a in sorted(declared - used):
            warns.append(f"asset `{a}` is declared but never drawn")
        # Every declared setting must actually be read in the code. Settings are read as
        # ctx.inputs.get("key") / ctx.inputs["key"], so the key appears as a quoted string;
        # if it never does, the setting is dead and confuses people who fill it in.
        for i in (m.get("inputs") or []):
            k = str(i.get("key", "")).strip() if isinstance(i, dict) else ""
            ait = str(i.get("app_input_type", "")).strip().lower() if isinstance(i, dict) else ""
            # Input keys ride the render descriptor (key-value_key-value), so '_' and '-'
            # are delimiters: a key containing them never routes to the app. Hard error for
            # api-key inputs (their value MUST arrive); a warning for any other input.
            if k and not re.match(r"^[a-zA-Z][a-zA-Z0-9]*$", k):
                safe = re.sub(r"[^a-zA-Z0-9]", "", k) or "setting"
                msg = (f"input key `{k}` must be letters and digits only, starting with a letter "
                       f"(no '_' or '-'): those are render-descriptor delimiters, so a value under "
                       f"this key never reaches the app. Rename it, e.g. `{safe}`.")
                (errors if ait == "api-key" else warns).append(msg)
            if k and not re.search(r"""['"]""" + re.escape(k) + r"""['"]""", src):
                errors.append(f"setting `{k}` is declared but never used in app.star "
                              f'(read it with ctx.inputs.get("{k}"), or remove it from the manifest)')
        for lit in re.findall(r"""c\.text[a-z_]*\(\s*['"]([^'"]*)['"]""", src):
            if any(ch.islower() for ch in lit):
                warns.append(f'text "{lit}" has lowercase; fonts are UPPERCASE-only, call .upper()')
                break
    return (errors, warns)


def run(app_dirs) -> int:
    total_err = 0
    for d in app_dirs:
        d = Path(d)
        errors, warns = check_app(d)
        tag = "FAIL" if errors else ("WARN" if warns else "PASS")
        print(f"{tag}  {d.name}")
        for e in errors:
            print(f"   x  {e}")
        for w in warns:
            print(f"   !  {w}")
        total_err += len(errors)
    print()
    print(f"{'FAILED' if total_err else 'OK'}: {total_err} error(s) across {len(app_dirs)} app(s)")
    return 1 if total_err else 0
