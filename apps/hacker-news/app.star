# Hacker News
#
# The official Firebase API. One story per page so each headline gets
# the whole panel rather than being crushed into a list.
#
# An app may make only 8 http.get calls per render, and the id list
# costs one of them, so four story pages is the safe ceiling.



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


def story(n):
    """The nth top story, or None."""
    r = http.get("https://hacker-news.firebaseio.com/v0/topstories.json",
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        return None
    ids = r["json"]
    if len(ids) <= n:
        return None
    s = http.get("https://hacker-news.firebaseio.com/v0/item/" + str(ids[n]) + ".json",
                 ttl_seconds = 1800)
    if s["status_code"] != 200 or not s["json"]:
        return None
    return s["json"]


def draw(c, ctx, n):
    it = story(n)
    if it == None:
        nodata(c, "NO STORIES", "HN UNREACHABLE")
        return

    title = str(it.get("title", "")).upper()
    score = int(it.get("score", 0) or 0)
    comments = int(it.get("descendants", 0) or 0)

    c.fill("#0E0A06")
    c.rect(0, 0, c.width - 1, 6, fill = "#FF6600")
    c.text("HN " + str(n + 1), 3, 1, font = "4x5", color = "#1A0E04")
    # The 64 panel has no room for the full meta line beside the rank.
    meta = str(score) + " PTS   " + str(comments) + " COMMENTS"         if c.width >= 128 else str(score) + "P"
    c.text(meta, c.width - 3, 1, font = "4x5", color = "#1A0E04",
           align = "right")
    block(c, title, 3, 9, c.width - 6, 21, ["10x16", "6x8", "5x7", "4x5"],
          "#F0E6DC", 1)


def one(c, ctx):
    draw(c, ctx, 0)


def two(c, ctx):
    draw(c, ctx, 1)


def three(c, ctx):
    draw(c, ctx, 2)


def four(c, ctx):
    draw(c, ctx, 3)
