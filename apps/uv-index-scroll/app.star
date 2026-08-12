# UV Index
#
# UV index from Open-Meteo. The burn-time estimate is the standard
# rule of thumb for average untanned skin (about 200 divided by the
# index, in minutes) — useful as an order of magnitude, not as
# medical advice.



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


BANDS = [
    [0, "LOW", "#4EE38A"], [3, "MODERATE", "#F5C242"], [6, "HIGH", "#FF7A18"],
    [8, "VERY HIGH", "#FF3B3B"], [11, "EXTREME", "#B44EFF"],
]


def band(v):
    out = BANDS[0]
    for b in BANDS:
        if v >= b[0]:
            out = b
    return out


def now(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP CODE")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "hourly": "uv_index", "daily": "uv_index_max",
                           "timezone": "auto", "forecast_days": "1"},
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO UV DATA", "FEED UNREACHABLE")
        return

    j = r["json"]
    hourly = j.get("hourly", {}).get("uv_index", [])
    peak = j.get("daily", {}).get("uv_index_max", [0])
    peakv = float(peak[0] or 0) if len(peak) > 0 else 0.0

    # The feed is in local time, so the current hour indexes straight in.
    off = int(j.get("utc_offset_seconds", 0))
    hour = ((ctx.now.unix + off) % 86400) // 3600
    cur = 0.0
    if len(hourly) > hour and hourly[hour] != None:
        cur = float(hourly[hour])

    b = band(cur)
    burn = 0 if cur < 1 else int(200 / cur)

    c.fill("#0C0A06")
    if c.width >= 128:
        c.text("UV INDEX", 6, 2, font = "5x7", color = "#7A6A48")
        c.text(str(int(cur * 10) / 10.0), 6, 10, font = "16x20", color = b[2])
        c.text(b[1], c.width - 6, 3, font = "10x16", color = b[2],
               align = "right")
        c.text("PEAK " + str(int(peakv)), c.width - 6, 21, font = "5x7",
               color = "#8A7A58", align = "right")
        if burn > 0:
            c.text("BURN " + str(burn) + "M", 76, 21, font = "5x7",
                   color = "#C8B890")
    else:
        # 0-4 label | 5-24 figure | 26-30 band, row 31 left as margin.
        c.text("UV", c.width // 2, 0, font = "4x5", color = "#7A6A48",
               align = "center")
        c.text(str(int(cur)), c.width // 2, 5, font = "16x20", color = b[2],
               align = "center")
        c.text_fit(b[1], c.width // 2, 26, ["4x5", "3x4"], color = b[2],
                   align = "center", maxw = c.width - 2)
