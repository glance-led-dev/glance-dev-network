# RSS Headlines
#
# Any feed URL. XML is scanned rather than parsed — there is no XML
# parser here — by walking <item> and <entry> blocks and lifting
# the first <title>. CDATA wrappers and the common HTML entities
# are unwrapped, which covers essentially every real feed.



PAGES = 3  # matches `pages:` in the manifest; drives the masthead pips

NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do.

    text_fit alone was not enough here: when even its smallest option
    overflows it still draws, which ran these messages off a 64 panel."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands — a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5", "picopixel"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5", "picopixel"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


# Row pitch per face: glyph rows plus one blank row between lines. Measured
# from the font data, not guessed -- 4x5 is really six rows tall (the comma
# descends), and a wrong number here overlaps the line beneath.
PITCH = {"10x16": 17, "7x10": 12, "6x8": 9, "5x7": 8, "3x7": 8,
         "4x5": 7, "picopixel": 6}

# Headline ladder, widest face first, bottoming out at 4x5 -- the body face
# for this app. Each rung holds meaningfully more text than the one above it
# on a 64-wide panel: 10x16 ~5 chars, 6x8 ~19, 5x7 ~31, 4x5 ~36 over 3 lines.
HEAD_NARROW = ["10x16", "6x8", "5x7", "4x5"]
HEAD_WIDE = ["10x16", "7x10", "6x8", "5x7", "4x5"]

ELL = "..."  # the bitmap faces carry no single-glyph ellipsis


def trim_end(s):
    """Drop trailing spaces and dangling punctuation before an ellipsis."""
    for k in range(len(s), 0, -1):
        ch = s[k - 1]
        if ch != " " and ch != "," and ch != "-" and ch != ".":
            return s[:k]
    return ""


def ellipsize(c, line, font, maxw):
    """`line` cut back until it plus an ellipsis fits maxw."""
    for k in range(len(line), 0, -1):
        t = trim_end(line[:k]) + ELL
        if c.text_width(t, font) <= maxw:
            return t
    return ELL


def split_long(c, word, font, maxw):
    """A word wider than the column, chopped into pieces that each fit.

    Without this a single 40-character token -- a URL, a hashtag, a German
    compound -- runs straight off the panel, and the renderer clips it
    silently mid-glyph.
    """
    parts = []
    rest = word
    # `while` is a reserved keyword in Starlark even though the language has
    # no while loop, so this is a bounded for.
    for _i in range(24):
        if c.text_width(rest, font) <= maxw:
            parts.append(rest)
            return parts
        cut = 1
        for k in range(len(rest), 0, -1):
            if c.text_width(rest[:k], font) <= maxw:
                cut = k
                break
        parts.append(rest[:cut])
        rest = rest[cut:]
        if rest == "":
            return parts
    parts.append(rest)
    return parts


def wrap(c, text, font, maxw):
    """Greedily pack words into lines no wider than maxw."""
    lines = []
    cur = ""
    for raw in text.split(" "):
        if raw == "":
            continue
        for w in split_long(c, raw, font, maxw):
            trial = w if cur == "" else cur + " " + w
            if c.text_width(trial, font) <= maxw:
                cur = trial
            else:
                if cur != "":
                    lines.append(cur)
                cur = w
    if cur != "":
        lines.append(cur)
    return lines


def headline(c, text, x, y, maxw, maxh, fonts, color):
    """Fill the block with the whole headline at the largest face that holds it.

    Drops a rung at a time rather than clipping, so a short headline gets big
    type and a long one gets more, smaller lines -- as many as genuinely fit.
    Only when even the smallest face overruns does the tail get an ellipsis.
    """
    words = str(text).upper()
    face = fonts[len(fonts) - 1]
    lines = []
    done = False
    for f in fonts:
        rows = (maxh + 1) // PITCH[f]
        if rows < 1:
            continue
        cand = wrap(c, words, f, maxw)
        if len(cand) <= rows:
            face = f
            lines = cand
            done = True
            break
    if not done:
        face = fonts[len(fonts) - 1]
        rows = (maxh + 1) // PITCH[face]
        if rows < 1:
            rows = 1
        lines = wrap(c, words, face, maxw)
        if len(lines) > rows:
            lines = lines[:rows]
            lines[rows - 1] = ellipsize(c, lines[rows - 1], face, maxw)
    used = len(lines) * PITCH[face] - 1
    top = y + (maxh - used) // 2
    for i in range(len(lines)):
        c.text(lines[i], x, top + i * PITCH[face], font = face, color = color)
    return len(lines)


def masthead(c, label, n, total, h):
    """Source strip: feed name, headline number, then the page pips.

    Two different jobs, so two different marks. The number after the source
    names the headline itself -- NPR 2 is NPR's second story. The pips on the
    right are a count, filled up to the page you are on, so they read 1/3,
    2/3, 3/3 rather than as a jumping dot.

    The number is never the part that gets cut: a long source name is
    ellipsized to whatever room is left once the number and pips are booked.
    """
    c.rect(0, 0, c.width - 1, h - 1, fill = "#D8442C")
    pips = h // 3
    if pips < 2:
        pips = 2
    pw = total * 3 - 1
    py = (h - pips) // 2
    for i in range(total):
        px = c.width - 2 - pw + i * 3
        c.rect(px, py, px + 1, py + pips - 1,
               fill = "#2A0704" if i <= n else "#F0A091")

    # Three clear columns before the first pip, so a number pushed all the
    # way right by a long source name never reads as a fourth pip.
    maxw = c.width - 8 - pw
    face = "4x5" if h < 9 else "5x7"
    small = "picopixel" if h < 9 else "4x5"
    num = " " + str(n + 1)
    if c.text_width(label + num, face) > maxw:
        face = small
    room = maxw - c.text_width(num, face)
    if c.text_width(label, face) > room:
        label = ellipsize(c, label, face, room)
    c.text(label + num, 2, 1, font = face, color = "#2A0704")


ENTITIES = [["&amp;", "&"], ["&#39;", "'"], ["&apos;", "'"],
            ["&quot;", '"'], ["&lt;", "<"], ["&gt;", ">"], ["&nbsp;", " "]]


def strip_tags(s):
    out = ""
    depth = 0
    for i in range(len(s)):
        ch = s[i]
        if ch == "<":
            depth += 1
        elif ch == ">":
            if depth > 0:
                depth -= 1
        elif depth == 0:
            out += ch
    return out


def decode(s):
    out = s
    for e in ENTITIES:
        out = out.replace(e[0], e[1])
    return out


def titles(body, want):
    """First <title> inside each <item> or <entry>, up to `want`."""
    out = []
    rest = body
    for i in range(40):
        if len(out) >= want:
            break
        a = rest.find("<item")
        b = rest.find("<entry")
        if a < 0 and b < 0:
            break
        start = a if (a >= 0 and (b < 0 or a < b)) else b
        rest = rest[start + 5:]
        t = rest.find("<title")
        if t < 0:
            break
        seg = rest[t:]
        gt = seg.find(">")
        end = seg.find("</title>")
        if gt < 0 or end < 0:
            break
        raw = seg[gt + 1:end]
        raw = raw.replace("<![CDATA[", "").replace("]]>", "")
        out.append(decode(strip_tags(raw)).strip())
    return out


def draw(c, ctx, n):
    url = str(ctx.inputs.get("url", "")).strip()
    label = str(ctx.inputs.get("label", "NEWS")).strip().upper()
    if label == "":
        label = "NEWS"
    if url == "":
        nodata(c, "NO FEED", "SET A FEED URL")
        return
    r = http.get(url, ttl_seconds = 3600,
                 headers = {"User-Agent": "glance-dev-network (glance-led.com)"})
    if r["status_code"] != 200 or r["body"] == "":
        nodata(c, "NO FEED DATA", "CHECK THE URL")
        return

    rows = titles(r["body"], n + 1)
    if len(rows) <= n:
        nodata(c, "NO HEADLINE", "FEED TOO SHORT")
        return

    # Source strip on top, then the headline owns everything below it: full
    # panel width, vertically centred, wrapped to as many lines as fit.
    c.fill("#0A0B10")
    h = 10 if c.width >= 128 else 7
    masthead(c, label, n, PAGES, h)
    headline(c, rows[n], 2, h + 1, c.width - 4, c.height - h - 1,
             HEAD_WIDE if c.width >= 128 else HEAD_NARROW, "#EDEFF6")


def one(c, ctx):
    draw(c, ctx, 0)


def two(c, ctx):
    draw(c, ctx, 1)


def three(c, ctx):
    draw(c, ctx, 2)
