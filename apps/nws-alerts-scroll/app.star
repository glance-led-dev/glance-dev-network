# Weather Alerts
#
# Active alerts from api.weather.gov, coloured by severity so a
# warning never looks like an advisory from across the room. The
# quiet page is deliberately calm and green: on most days the useful
# information is that there is nothing to report.



def geo(ctx):
    """[lat, lon, place] for the configured zip, or None when unavailable."""
    zip = str(ctx.inputs.get("zip", "")).strip()
    if zip == "":
        return None
    g = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if g["status_code"] != 200 or not g["json"]:
        return None
    places = g["json"].get("places", [])
    if not places:
        return None
    p = places[0]
    return [float(p["latitude"]), float(p["longitude"]),
            str(p.get("place name", "")).upper()]


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


SEVERITY = {
    "EXTREME": ["#FF3B3B", 4], "SEVERE": ["#FF7A18", 3],
    "MODERATE": ["#F5C242", 2], "MINOR": ["#6FC7FF", 1], "UNKNOWN": ["#9AA0BC", 0],
}


def worst(features):
    """The most severe active alert, so the panel leads with what matters."""
    best = None
    rank = -1
    for f in features:
        pr = f.get("properties", {})
        sev = str(pr.get("severity", "UNKNOWN")).upper()
        r = SEVERITY.get(sev, SEVERITY["UNKNOWN"])[1]
        if r > rank:
            rank = r
            best = pr
    return best


def alert(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP CODE")
        return

    r = http.get("https://api.weather.gov/alerts/active",
                 params = {"point": str(g[0]) + "," + str(g[1])},
                 ttl_seconds = 300)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO ALERT DATA", "FEED UNREACHABLE")
        return

    feats = r["json"].get("features", [])
    if len(feats) == 0:
        c.fill("#06110A")
        c.text("NATIONAL WEATHER SERVICE", c.width // 2, 2, font = "4x5",
               color = "#3E6E52", align = "center")
        c.text("ALL CLEAR", c.width // 2, c.height // 2 - 8,
               font = "10x16" if c.width >= 128 else "6x8",
               color = "#4EE38A", align = "center")
        c.text(g[2] if g[2] != "" else "NO ACTIVE ALERTS", c.width // 2,
               c.height // 2 + 10, font = "4x5", color = "#3E6E52",
               align = "center")
        return

    pr = worst(feats)
    sev = str(pr.get("severity", "UNKNOWN")).upper()
    col = SEVERITY.get(sev, SEVERITY["UNKNOWN"])[0]
    event = str(pr.get("event", "ALERT")).upper()

    c.fill("#120608")
    c.rect(0, 0, c.width - 1, 6, fill = col)
    c.text(sev + (" - " + str(len(feats)) if len(feats) > 1 else ""),
           3, 1, font = "4x5", color = "#12060A")
    c.text("NATIONAL WEATHER SERVICE", c.width - 3, 1, font = "4x5",
           color = "#12060A", align = "right")
    block(c, event, 3, 9, c.width - 6, 21,
          ["10x16", "6x8", "5x7", "4x5"], col, 1)
