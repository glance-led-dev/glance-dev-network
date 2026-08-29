# Quake Watch
#
# The USGS 2.5+ feed for the last day. The headline page leads with
# the largest event rather than the newest — a magnitude 6 an hour
# ago matters more than a 2.6 a minute ago — and the list page shows
# the rest.



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


def feed():
    r = http.get("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson",
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        return None
    return r["json"].get("features", [])


def magcolor(m):
    if m >= 6.0:
        return "#FF3B3B"
    if m >= 5.0:
        return "#FF7A18"
    if m >= 4.0:
        return "#F5C242"
    return "#6FC7FF"


def ago(ctx, ms):
    mins = (ctx.now.unix - ms // 1000) // 60
    if mins < 60:
        return str(mins) + "M AGO"
    if mins < 1440:
        return str(mins // 60) + "H AGO"
    return str(mins // 1440) + "D AGO"


def biggest(c, ctx):
    feats = feed()
    if feats == None:
        nodata(c, "NO QUAKE DATA", "USGS UNREACHABLE")
        return
    if len(feats) == 0:
        nodata(c, "NO QUAKES", "NONE ABOVE M2.5")
        return

    top = feats[0]
    for f in feats:
        if float(f["properties"].get("mag", 0) or 0) > float(top["properties"].get("mag", 0) or 0):
            top = f
    pr = top["properties"]
    m = float(pr.get("mag", 0) or 0)
    place = str(pr.get("place", "")).upper()
    col = magcolor(m)

    c.fill("#0A0806")
    if c.width >= 128:
        c.text("LARGEST TODAY", 6, 2, font = "4x5", color = "#6A6050")
        c.text("M" + str(int(m * 10) / 10.0), 6, 9, font = "16x20", color = col)
        c.text(ago(ctx, pr.get("time", 0)), c.width - 6, 2, font = "4x5",
               color = "#6A6050", align = "right")
        block(c, place, 84, 9, c.width - 90, 22, ["6x8", "5x7", "4x5"],
              "#D8D8E8", 1)
    else:
        c.text("M" + str(int(m * 10) / 10.0), c.width // 2, 0, font = "16x20",
               color = col, align = "center")
        block(c, place, 2, 21, c.width - 4, 11, ["4x5"], "#D8D8E8", 1)


def recent(c, ctx):
    feats = feed()
    if feats == None:
        nodata(c, "NO QUAKE DATA", "USGS UNREACHABLE")
        return
    c.fill("#0A0806")
    n = 4 if c.width >= 128 else 3
    rows = len(feats) if len(feats) < n else n
    if rows == 0:
        nodata(c, "NO QUAKES", "NONE ABOVE M2.5")
        return
    h = c.height // n
    for i in range(rows):
        pr = feats[i]["properties"]
        m = float(pr.get("mag", 0) or 0)
        y = i * h + 1
        c.text("M" + str(int(m * 10) / 10.0), 2, y, font = "5x7",
               color = magcolor(m))
        if c.width >= 128:
            # The age column is fixed, so the place is clipped to the width
            # that is genuinely free rather than running underneath it.
            place = str(pr.get("place", "")).upper()
            avail = c.width - 44 - 46
            for k in range(len(place), 0, -1):
                if c.text_width(place[:k], "5x7") <= avail:
                    place = place[:k]
                    break
            c.text(place, 40, y, font = "5x7", color = "#B8B8C8")
            c.text(ago(ctx, pr.get("time", 0)), c.width - 4, y, font = "4x5",
                   color = "#6A6050", align = "right")
        else:
            c.text(ago(ctx, pr.get("time", 0)), c.width - 2, y, font = "4x5",
                   color = "#6A6050", align = "right")
