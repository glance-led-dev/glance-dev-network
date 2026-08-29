# RSS Headlines
#
# Any feed URL. XML is scanned rather than parsed — there is no XML
# parser here — by walking <item> and <entry> blocks and lifting
# the first <title>. CDATA wrappers and the common HTML entities
# are unwrapped, which covers essentially every real feed.



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
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}


def wrap(c, words, font, maxw):
    """Greedily pack words into lines no wider than maxw."""
    lines = []
    cur = ""
    for w in words:
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


def block(c, text, x, y, maxw, maxh, fonts, color, gap):
    """Draw text at the largest font whose wrapped lines fit maxh."""
    words = str(text).upper().split(" ")
    for f in fonts:
        lines = wrap(c, words, f, maxw)
        if len(lines) * (FONTH[f] + gap) - gap <= maxh:
            for i in range(len(lines)):
                c.text(lines[i], x, y + i * (FONTH[f] + gap), font = f,
                       color = color)
            return len(lines)
    # Nothing fits: use the smallest face, draw what we can, and mark the
    # cut so a dropped tail reads as deliberate rather than as a bug.
    f = fonts[len(fonts) - 1]
    lines = wrap(c, words, f, maxw)
    n = maxh // (FONTH[f] + gap)
    if n > len(lines):
        n = len(lines)
    for i in range(n):
        line = lines[i]
        if i == n - 1 and n < len(lines):
            # `while` is a reserved keyword in Starlark even though the
            # language has no while loop, so this walks back with a for.
            for k in range(len(line), 0, -1):
                if c.text_width(line[:k] + "..", f) <= maxw:
                    line = line[:k]
                    break
            line = line + ".."
        c.text(line, x, y + i * (FONTH[f] + gap), font = f, color = color)
    return n


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

    c.fill("#0A0B10")
    c.rect(0, 0, c.width - 1, 6, fill = "#D8442C")
    c.text(label + " " + str(n + 1), 3, 1, font = "4x5", color = "#1A0604")

    sz = 16 if c.width >= 128 else 12
    c.image("NEWS.png", c.width - sz - 1, c.height - sz - 1, w = sz, h = sz)
    block(c, rows[n], 3, 9, c.width - sz - 8, 22,
          ["10x16", "6x8", "5x7", "4x5"], "#EDEFF6", 1)


def one(c, ctx):
    draw(c, ctx, 0)


def two(c, ctx):
    draw(c, ctx, 1)


def three(c, ctx):
    draw(c, ctx, 2)
