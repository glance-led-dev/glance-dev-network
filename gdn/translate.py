"""Translate a Pixlet/tronbyt app into a GDN app scaffold.

GDN and Pixlet share the Starlark *language* but use different *rendering*:
Pixlet returns a `render.Root(...)` widget tree (auto-layout); GDN draws
immediately with `c` (explicit coordinates). So this is a PORTING ASSISTANT, not
a magic transpiler — it does the reliable mechanical parts:

  * extracts the Pixlet `schema` fields -> GDN manifest `inputs`
  * detects which render widgets / features are used (the hand-port checklist)
  * emits manifest.yaml + an app.star scaffold with the original preserved as a
    reference comment and a per-widget conversion checklist

The app's data/logic usually ports as-is; the render tree is what you rewrite.
"""
from __future__ import annotations

import re

_FIELD_RE = re.compile(
    r"schema\.(Text|Dropdown|Toggle|Color|Location|DateTime|Typeahead|"
    r"PhotoSelect|LocationBased|Generated)\s*\(")

_WIDGET_HINTS = {
    "Text": "c.text(s, x, y, font=, color=, align=)",
    "Row": "lay children out left-to-right by hand (track an x cursor)",
    "Column": "stack children top-to-bottom by hand (track a y cursor)",
    "Box": "c.rect(x0, y0, x1, y1, fill=) for the background",
    "Padding": "add to the child's x/y",
    "Image": "re-export the PNG into this folder, list it in assets:, c.image(...)",
    "WrappedText": "split into lines and c.text() each",
    "Marquee": "static c.text() for now (scrolling needs the animation phase)",
    "Animation": "not supported yet (animation phase) — draw a single static frame",
    "Sprite": "not supported yet — draw a static frame",
    "Stack": "draw children in order (later on top)",
    "Circle": "approximate with c.rect / c.pixel / c.bitmap",
    "Root": "the page itself — becomes def main(c, ctx)",
}


def _balanced(text: str, open_idx: int):
    """Return the substring inside the parens starting at `open_idx` ('(')."""
    depth = 0
    for i in range(open_idx, len(text)):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return text[open_idx + 1:i]
    return text[open_idx + 1:]


def _kw(body: str, key: str):
    m = re.search(key + r"""\s*=\s*["']([^"']*)["']""", body)
    return m.group(1) if m else None


def extract_inputs(src: str) -> list:
    inputs = []
    for m in _FIELD_RE.finditer(src):
        kind = m.group(1)
        body = _balanced(src, m.end() - 1)
        fid = _kw(body, "id")
        if not fid:
            continue
        name = _kw(body, "name") or fid
        default = _kw(body, "default")
        if kind == "Dropdown":
            opts = re.findall(r"""value\s*=\s*["']([^"']+)["']""", body)
            inputs.append({"key": fid, "type": "choice", "label": name,
                           "default": default, "choices": opts})
        elif kind == "Toggle":
            inputs.append({"key": fid, "type": "string", "label": name,
                           "default": (default or "false")})
        else:
            inputs.append({"key": fid, "type": "string", "label": name, "default": default})
    return inputs


def detect(src: str):
    widgets = {w for w in _WIDGET_HINTS if ("render." + w) in src}
    flags = set()
    if re.search(r"\bload\s*\(", src):
        flags.add("load() imports — inline or drop them")
    if "http." in src:
        flags.add("http.* — use GDN's http (declare hosts in manifest data:)")
    if "animation" in src.lower() or "Animation" in src:
        flags.add("animation — GDN v1 is static frames")
    if "secret." in src:
        flags.add("secret.* — request a named key in the manifest")
    return widgets, flags


def _inputs_yaml(inputs: list) -> str:
    if not inputs:
        return "  []"
    lines = []
    for i in inputs:
        lines.append(f"  - key: {i['key']}")
        lines.append(f"    type: {i['type']}")
        lines.append(f"    label: {i['label']}")
        if i.get("default") is not None:
            lines.append(f"    default: \"{i['default']}\"")
        if i.get("choices"):
            lines.append("    choices: [" + ", ".join('"' + str(c) + '"' for c in i["choices"]) + "]")
    return "\n".join(lines)


def translate_pixlet(src: str, app_id: str, width: int = 64):
    inputs = extract_inputs(src)
    widgets, flags = detect(src)

    manifest = f"""gdn: 1
id: {app_id}
version: 0.1.0
name: {app_id.replace('-', ' ').title()}
description: Ported from a Pixlet/tronbyt app by `gdn translate`.
entry: app.star

# Pixlet's native size is 64x32. GDN supports up to 384 wide — set yours.
width: {width}
height: 32
refresh: 60

pages: [main]

inputs:
{_inputs_yaml(inputs)}
"""

    checklist = "\n".join(
        f"#   - render.{w}  ->  {_WIDGET_HINTS.get(w, 'convert by hand')}"
        for w in sorted(widgets)) or "#   (no render.* widgets detected)"
    commented = "\n".join(("# " + ln).rstrip() for ln in src.splitlines())

    appstar = f'''# {app_id} — scaffolded by `gdn translate` from a Pixlet/tronbyt app.
#
# GDN and Pixlet share the Starlark language but render differently: Pixlet
# returns a render.Root(...) widget tree; GDN draws immediately with `c`. Your
# DATA/LOGIC usually ports as-is; the RENDER code must be rewritten by hand.
# See docs/PIXLET_COMPATIBILITY.md and docs/STARLARK_API.md.
#
# Read config with ctx.inputs["<id>"]  (was config.get / config.str).
#
# CONVERSION CHECKLIST — widgets found in the original:
{checklist}

def main(c, ctx):
    c.fill("black")
    c.text("PORT ME", c.width // 2, 12, font = "5x7", color = "yellow", align = "center")
    # TODO: rewrite the render tree (see the original below) as c.* draw calls.


# ============================================================================
# ORIGINAL PIXLET SOURCE (reference only — NOT executed)
# ============================================================================
{commented}
'''

    report = {"inputs": [i["key"] for i in inputs], "widgets": widgets, "flags": flags}
    return manifest, appstar, report
