"""Static layout checks for `gdn check` — draws that overflow the space given.

Nothing in the drawing API clips. `c.text()` draws wherever it is told, at
whatever width the string turns out to be, and `text_fit()` / a hand-rolled
`fit_font()` only choose a size: when even the smallest listed font still
overflows, they return it and the text draws anyway. So two habits go wrong
silently, and only in states nobody happened to look at:

  * a right-aligned draw with no width bound grows leftwards into whatever
    shares its row -- fine while the strings are short, wrong the day a
    longer one appears ("FALLING FAST", "DECENT BASE", "RAIN COVERED IT")
  * `3x4` is used as a last-resort size for text containing spaces. That font
    has no space glyph at all, so "HARD FREEZE" renders as HARDFREEZE.

Both are decidable ahead of time, because these apps keep a small vocabulary
of literal strings and draw one of them. This module resolves that
vocabulary, measures the widest member in its real font, and reports only
where two draws genuinely land on each other on this app's actual width.

Everything here is a warning. It is a static reading of a dynamic layout, so
it is deliberately quiet: a draw whose text cannot be resolved to literals is
skipped rather than guessed at.
"""
from __future__ import annotations

import re

from .fonts import font_height, text_width

_CALL = re.compile(r"c\.(text_fit|text_center|text_right|text)\s*\((?P<args>.*?)\)\s*$",
                   re.S | re.M)
_FONT = re.compile(r'"([0-9]+x[0-9]+(?:_bold|_scroll)?|picopixel)"')
# `if c.width >= 128:` and `if c.width >= 128 and rows == 1:` alike.
_WIDTH_IF = re.compile(r"if\s+c\.width\s*(>=|>|<|<=)\s*(\d+)\s*(?:and\b|or\b|:)")


def _split_args(s: str) -> list:
    out, depth, cur = [], 0, ""
    for ch in s:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def _kwarg(args: list, name: str):
    for a in args:
        m = re.match(r"^%s\s*=\s*(.+)$" % name, a, re.S)
        if m:
            return m.group(1).strip()
    return None


def _number(tok, width: int):
    """Resolve the handful of x/y forms these apps actually use."""
    if tok is None:
        return None
    t = tok.strip()
    if re.fullmatch(r"-?\d+", t):
        return int(t)
    m = re.fullmatch(r"c\.width\s*-\s*(\d+)", t)
    if m:
        return width - int(m.group(1))
    if re.fullmatch(r"c\.width\s*//\s*2", t):
        return width // 2
    return None


def _branch_ok(src: str, width: int) -> dict:
    """line number -> False when that line sits in a width branch this panel
    does not take. Wide and narrow layouts live in `if c.width >= 128:` and
    its `else:`, and never draw together; pairing across them invents
    collisions that cannot happen."""
    ok, stack = {}, []
    for i, ln in enumerate(src.split("\n"), 1):
        s, indent = ln.strip(), len(ln) - len(ln.lstrip())
        # A blank line measures as indent 0 and a comment sits wherever it was
        # typed, so treating either as code closed every open branch. One empty
        # line for breathing room inside `if c.width >= 128:` was enough to
        # make the whole rest of the branch look like it belonged to both
        # panels -- which is exactly when this map has to be right.
        if not s or s.startswith("#"):
            ok[i] = all(a for _, a in stack)
            continue
        while stack and indent <= stack[-1][0] and not s.startswith("else"):
            stack.pop()
        m = _WIDTH_IF.match(s)
        if m:
            op, n = m.group(1), int(m.group(2))
            stack.append((indent, {">=": width >= n, ">": width > n,
                                   "<": width < n, "<=": width <= n}[op]))
        # Only an `else:` at the width-`if`'s OWN indent belongs to it. A
        # deeper one closes some other `if` inside the branch -- an if/elif
        # chain picking a font, say -- and flipping the width frame there
        # marks the whole rest of the branch as belonging to the other panel.
        # That is how a wide-only draw got paired against a narrow-only one.
        elif s.startswith("else:") and stack and indent == stack[-1][0]:
            ind0, applies = stack.pop()
            stack.append((ind0, not applies))
        ok[i] = all(a for _, a in stack)
    return ok


def _literals(src: str, expr: str):
    """Every literal string this text argument can evaluate to, or None.

    None means "cannot tell" -- a computed string like str(n) + " MI" -- and
    the caller skips it. Guessing a width there is how a lint turns into
    noise nobody reads.
    """
    e = expr.strip()
    m = re.fullmatch(r'"([^"]*)"', e)
    if m:
        return [m.group(1)]
    m = re.fullmatch(r"([A-Za-z_][A-Za-z0-9_]*)", e)
    if m:
        v = re.escape(m.group(1))
        out = re.findall(r'^\s*%s\s*=\s*"([^"]*)"' % v, src, re.M)
        out += re.findall(r'%s\s*=\s*\[\s*"([^"]*)"' % v, src)
        return out or None
    # `b[0]` where `b = band(x)` and band() returns lists of literals. This is
    # the common shape for a word-plus-colour vocabulary -- ["HARD FREEZE",
    # "#8FD4FF", "COVER EVERYTHING"] -- and skipping it missed real bugs.
    m = re.fullmatch(r"([A-Za-z_][A-Za-z0-9_]*)\s*\[\s*(\d+)\s*\]", e)
    if m:
        var, idx = m.group(1), int(m.group(2))
        fn = re.search(r"^\s*%s\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(" % re.escape(var),
                       src, re.M)
        bodies = []
        if fn:
            fm = re.search(r"^def\s+%s\s*\(.*?(?=^def |\Z)" % re.escape(fn.group(1)),
                           src, re.M | re.S)
            if fm:
                bodies.append(fm.group(0))
        bodies.append(src)
        for body in bodies:
            out = []
            for lst in re.findall(r"return\s*\[([^\]]*)\]", body):
                items = re.findall(r'"([^"]*)"', lst)
                if len(items) > idx:
                    out.append(items[idx])
            if out:
                return out
    return None


def _widest(strings, fonts) -> int:
    best = 0
    for s in strings:
        for f in fonts:
            try:
                best = max(best, text_width(f, s))
            except Exception:  # noqa: BLE001 - unknown font name, not our problem here
                pass
    return best


def _height(fonts) -> int:
    hs = []
    for f in fonts:
        try:
            hs.append(font_height(f))
        except Exception:  # noqa: BLE001
            pass
    return max(hs) if hs else 8


def _fn_spans(src: str) -> list:
    """(first_line, last_line, name) for every top-level def."""
    spans, cur = [], None
    lines = src.splitlines()
    for i, ln in enumerate(lines, 1):
        m = re.match(r"^def\s+([A-Za-z_]\w*)\s*\(", ln)
        if m:
            if cur:
                spans.append((cur[0], i - 1, cur[1]))
            cur = (i, m.group(1))
    if cur:
        spans.append((cur[0], len(lines), cur[1]))
    return spans


def _fn_at(spans, line):
    for lo, hi, name in spans:
        if lo <= line <= hi:
            return name
    return ""


def _draws(src: str, width: int) -> list:
    ok = _branch_ok(src, width)
    spans = _fn_spans(src)
    out = []
    for m in _CALL.finditer(src):
        fn, args = m.group(1), _split_args(m.group("args"))
        line = src[:m.start()].count("\n") + 1
        if not ok.get(line, True):
            continue
        if fn in ("text", "text_fit"):
            if len(args) < 3:
                continue
            x, y = _number(args[1], width), _number(args[2], width)
        else:
            if len(args) < 2:
                continue
            x, y = None, _number(args[1], width)
        if y is None:
            continue
        align = _kwarg(args, "align")
        align = align.strip('"') if align else (
            "right" if fn == "text_right" else
            "center" if fn == "text_center" else "left")
        fonts_tok = args[3] if (fn == "text_fit" and len(args) > 3) else _kwarg(args, "font")
        out.append({
            "line": line, "fn": _fn_at(spans, line), "x": x, "y": y, "align": align,
            "fonts": _FONT.findall(fonts_tok) if fonts_tok else ["5x7"],
            "maxw": _number(_kwarg(args, "maxw"), width), "expr": args[0],
        })
    return out


def layout_warnings(src: str, width: int) -> list:
    """Warnings about text that can draw outside the room it was given."""
    warns = []
    draws = _draws(src, width)

    for left in draws:
        if left["align"] != "left" or left["x"] is None:
            continue
        for right in draws:
            # Two draws in different functions are two different PAGES and can
            # never be on the panel together. Comparing them reported a splash
            # screen's title as overlapping another page's body text, which is
            # a false alarm that teaches people to ignore the linter.
            if left["fn"] != right["fn"]:
                continue
            if right is left or right["align"] != "right" or right["x"] is None:
                continue
            lb = (left["y"], left["y"] + _height(left["fonts"]) - 1)
            rb = (right["y"], right["y"] + _height(right["fonts"]) - 1)
            if lb[1] < rb[0] or rb[1] < lb[0]:
                continue
            ls, rs = _literals(src, left["expr"]), _literals(src, right["expr"])
            if not ls or not rs:
                continue
            lw, rw = _widest(ls, left["fonts"]), _widest(rs, right["fonts"])
            if left["maxw"] is not None:
                lw = min(lw, left["maxw"])
            if right["maxw"] is not None:
                rw = min(rw, right["maxw"])
            over = (left["x"] + lw) - (right["x"] - rw)
            if over > 0:
                warns.append(
                    'line %d "%s" can reach x=%d while line %d "%s" starts at '
                    'x=%d -- they overlap by %dpx. Nothing clips: bound the '
                    'left draw to what the right one leaves, or give each its '
                    'own row.'
                    % (left["line"], max(ls, key=len)[:24], left["x"] + lw,
                       right["line"], max(rs, key=len)[:24], right["x"] - rw, over))

    for d in draws:
        if "3x4" not in d["fonts"]:
            continue
        lits = _literals(src, d["expr"])
        if not lits:
            continue
        multi = [s for s in lits if " " in s.strip()]
        if not multi:
            continue
        # 3x4 is only reached when nothing larger fits, so report the strings
        # that actually fall through to it -- not the whole vocabulary. One
        # member fitting the next size up says nothing about the others:
        # "SLOW BUT FINE" fits 4x5 at exactly 60px while "DRY AND BREEZY" is
        # 65px and drops, and checking "any" instead of "each" hid that.
        bigger = [f for f in d["fonts"] if f != "3x4"]
        if d["maxw"] is not None and bigger:
            multi = [s for s in multi if text_width(bigger[-1], s) > d["maxw"]]
        if not multi:
            continue
        warns.append(
            'line %d can draw "%s" in 3x4, which has no space glyph -- it '
            'renders as one run-on word. Widen the maxw so a larger font '
            'fits, or use a single-word string here.'
            % (d["line"], max(multi, key=len)[:24]))

    return warns
