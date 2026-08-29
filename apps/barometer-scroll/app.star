# Barometer
#
# Pressure alone tells you little; the trend over three hours tells
# you a lot, which is why ships' barometers were read that way for
# two centuries. A fall of more than about 2 hPa in three hours is
# a genuine sign of weather on the way.



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


def _wrap2(c, text, font, maxw):
    """Split `text` into two lines at the word break that balances them best.

    Returns a one-item list when there is nothing to split on."""
    words = text.split(" ")
    if len(words) < 2:
        return [text]
    bw = -1
    ba = ""
    bb = ""
    for i in range(1, len(words)):
        a = " ".join(words[:i])
        b = " ".join(words[i:])
        w = c.text_width(a, font)
        wb = c.text_width(b, font)
        if wb > w:
            w = wb
        if bw < 0 or w < bw:
            bw = w
            ba = a
            bb = b
    return [ba, bb]


def _fit_wrap2(c, text, fonts, maxw):
    """[font, lines] for the largest font whose two wrapped lines fit maxw.

    Falls back to the smallest font and clips, so a phrase longer than any
    listed here still degrades to something that stays inside its column."""
    for f in fonts:
        lines = _wrap2(c, text, f, maxw)
        ok = True
        for ln in lines:
            if c.text_width(ln, f) > maxw:
                ok = False
        if ok:
            return [f, lines]
    f = fonts[len(fonts) - 1]
    out = []
    for ln in _wrap2(c, text, f, maxw):
        out.append(_fit_clip(c, ln, [f], maxw)[1])
    return [f, out]


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


def pressure(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "hourly": "pressure_msl", "past_hours": "6",
                           "forecast_hours": "1", "timezone": "auto"},
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO PRESSURE", "NO CONNECTION")
        return
    vals = r["json"].get("hourly", {}).get("pressure_msl", [])
    clean = []
    for v in vals:
        if v != None:
            clean.append(float(v))
    if len(clean) < 2:
        nodata(c, "NO PRESSURE", "EMPTY FEED")
        return

    now = clean[len(clean) - 1]
    back = clean[0] if len(clean) < 4 else clean[len(clean) - 4]
    delta = now - back

    if delta <= -2.0:
        trend = "FALLING FAST"
        col = "#FF5B5B"
        note = "WEATHER COMING"
    elif delta <= -0.7:
        trend = "FALLING"
        col = "#FF9A4A"
        note = "TURNING UNSETTLED"
    elif delta < 0.7:
        trend = "STEADY"
        col = "#6FD4FF"
        note = "NO BIG CHANGE"
    elif delta < 2.0:
        trend = "RISING"
        col = "#8FE38A"
        note = "SETTLING DOWN"
    else:
        trend = "RISING FAST"
        col = "#4EE38A"
        note = "CLEARING"

    sz = 24 if c.width >= 128 else 16
    dial_x = 7 if c.width >= 128 else 1
    c.image("GAUGE.png", dial_x, (c.height - sz) // 2, w = sz, h = sz)

    sign = "+" if delta >= 0 else ""
    change = sign + str(int(delta * 10) / 10.0) + " IN 3H"

    if c.width >= 128:
        # Everything sits in the column right of the dial, which now starts at
        # x=34 -- the whole layout is pulled 6px toward the middle, right edge
        # included (186 -> 180).
        #
        # Left stack: reading 0-15, trend 17-23, change 25-31, all inside the
        # 72px measured from x=34. Right column holds the outlook wrapped onto
        # two lines at y=17/25, right-aligned to 180 with 69px to play with.
        # The widest outlook word, "UNSETTLED", is 53px at 5x7, so the two
        # columns stay 24px apart even in the worst state.
        left = 34
        right = c.width - 12
        lw = 72
        rf = _fit_clip(c, str(int(now)) + " HPA", ["10x16", "6x8", "5x7"],
                       right - left + 1)
        c.text(rf[1], left, 0, font = rf[0], color = "#DCE4F4")
        tf = _fit_clip(c, trend, ["5x7", "4x5"], lw)
        c.text(tf[1], left, 17, font = tf[0], color = col)
        cf = _fit_clip(c, change, ["5x7", "4x5"], lw)
        c.text(cf[1], left, 25, font = cf[0], color = "#96A0B8")

        nf = _fit_wrap2(c, note, ["5x7", "4x5"], right - (left + lw + 6) + 1)
        lines = nf[1]
        if len(lines) < 2:
            c.text(lines[0], right, 21, font = nf[0], color = "#7F8CA8",
                   align = "right")
        else:
            c.text(lines[0], right, 17, font = nf[0], color = "#7F8CA8",
                   align = "right")
            c.text(lines[1], right, 25, font = nf[0], color = "#7F8CA8",
                   align = "right")
    else:
        c.text_fit(str(int(now)), c.width - 2, 3, ["16x20", "10x16"],
                   color = "#DCE4F4", align = "right", maxw = c.width - 20)
        # 4x5 only, never 3x4: that font has no space glyph, so "FALLING FAST"
        # would render as one run-on word. It fits 4x5 at 57px anyway.
        tf = _fit_clip(c, trend, ["4x5"], c.width - 4)
        c.text(tf[1], c.width - 2, 25, font = tf[0], color = col,
               align = "right")
