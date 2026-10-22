# Substack Latest — the newest essay title, from the feed.
#
# A one-feed, one-title sibling of rss-headlines: the XML is scanned
# rather than parsed (there is no XML parser here) by walking <item>
# and <entry> blocks and lifting the first <title>, with CDATA and the
# common HTML entities unwrapped — the established pattern in this
# repo. The title then fills the panel at the largest face that holds
# it whole, the way rss-headlines draws its headlines.
#
# Like every network app here it renders a sensible panel with the
# network down (that is how the publish-time validator sees it):
# NO FEED DATA, never a blank wall.

UA = {"User-Agent": "glance-dev-network (glance-led.com)"}
GOLD = "#E8B33A"
WHITE = "#EDEFF6"
DIM = "#6A7090"
BG = "#08090D"

PITCH = {"6x8": 9, "5x7": 8, "4x5": 7, "3x4": 5}
FACES = ["6x8", "5x7", "4x5", "3x4"]
ELL = "..."  # the bitmap faces carry no single-glyph ellipsis

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


def first_title(body):
    """The <title> of the first <item> or <entry> in the feed, or ''."""
    a = body.find("<item")
    b = body.find("<entry")
    if a < 0 and b < 0:
        return ""
    start = a if (a >= 0 and (b < 0 or a < b)) else b
    rest = body[start + 5:]
    t = rest.find("<title")
    if t < 0:
        return ""
    seg = rest[t:]
    gt = seg.find(">")
    end = seg.find("</title>")
    if gt < 0 or end < 0:
        return ""
    raw = seg[gt + 1:end]
    raw = raw.replace("<![CDATA[", "").replace("]]>", "")
    return decode(strip_tags(raw)).strip()


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
    """A word wider than the column, chopped into pieces that fit."""
    parts = []
    rest = word
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


def title_block(c, text, x, y, maxw, maxh):
    """The title at the largest face that holds it, centred as a block."""
    face = FACES[len(FACES) - 1]
    lines = []
    done = False
    for f in FACES:
        rows = (maxh + 1) // PITCH[f]
        if rows < 1:
            continue
        cand = wrap(c, text, f, maxw)
        if len(cand) <= rows:
            face = f
            lines = cand
            done = True
            break
    if not done:
        face = FACES[len(FACES) - 1]
        rows = (maxh + 1) // PITCH[face]
        if rows < 1:
            rows = 1
        lines = wrap(c, text, face, maxw)
        if len(lines) > rows:
            lines = lines[:rows]
            lines[rows - 1] = ellipsize(c, lines[rows - 1], face, maxw)
    used = len(lines) * PITCH[face] - 1
    top = y + (maxh - used) // 2
    for i in range(len(lines)):
        c.text(lines[i], x, top + i * PITCH[face], font = face,
               color = WHITE, align = "center")


def nodata(c, title, sub):
    c.fill(BG)
    c.text_fit(title, c.width // 2, 5, ["6x8", "5x7", "4x5"],
               color = GOLD, align = "center", maxw = c.width - 2)
    c.text_fit(sub, c.width // 2, 19, ["4x5", "3x4"], color = DIM,
               align = "center", maxw = c.width - 2)


def latest(c, ctx):
    url = str(ctx.inputs.get("url", "")).strip()
    label = str(ctx.inputs.get("label", "SUBSTACK")).strip().upper()
    if label == "":
        label = "SUBSTACK"
    if url == "":
        nodata(c, "NO FEED", "SET A FEED URL")
        return
    r = http.get(url, ttl_seconds = 3600, headers = UA)
    if r["status_code"] != 200 or r["body"] == "":
        nodata(c, "NO FEED DATA", "CHECK THE URL")
        return
    title = first_title(r["body"])
    if title == "":
        nodata(c, "NO TITLE", "FEED TOO SHORT")
        return
    c.fill(BG)
    c.text_fit(label, c.width // 2, 1, ["4x5", "3x4"], color = GOLD,
               align = "center", maxw = c.width - 2)
    title_block(c, title.upper(), c.width // 2, 9, c.width - 4,
                c.height - 10)
