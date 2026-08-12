# Frost Watch
#
# One question, answered plainly: does anything need covering
# tonight? The thresholds are the ones gardeners actually use —
# frost forms around 36F because the air at thermometer height is
# warmer than the ground, and a hard freeze starts at 28F.



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


def band(f):
    """Thresholds in Fahrenheit, the units the advice is written in."""
    if f <= 28:
        return ["HARD FREEZE", "#8FD4FF", "COVER EVERYTHING"]
    if f <= 32:
        return ["FREEZE", "#BFE6FF", "COVER TENDER PLANTS"]
    if f <= 36:
        return ["FROST RISK", "#DCF0FF", "COVER IF IN DOUBT"]
    if f <= 45:
        return ["CHILLY", "#8FE3B0", "NOTHING TO DO"]
    return ["MILD", "#6FE38A", "NOTHING TO DO"]


def tonight(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "temperature_2m_min",
                           "temperature_unit": "fahrenheit",
                           "timezone": "auto", "forecast_days": "2"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "NO CONNECTION")
        return
    lows = r["json"].get("daily", {}).get("temperature_2m_min", [])
    if len(lows) == 0 or lows[0] == None:
        nodata(c, "NO FORECAST", "EMPTY FEED")
        return

    f = float(lows[0])
    b = band(f)
    metric = str(ctx.inputs.get("units", "IMPERIAL")).upper() == "METRIC"
    shown = str(int((f - 32) * 5 / 9)) if metric else str(int(f))

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#050A16", "#12203A",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("FROST.png", 2, (c.height - n) // 2, w = n, h = n)

    if c.width >= 128:
        c.text("TONIGHT LOW", 30, 2, font = "4x5", color = "#5E7290")
        c.text(shown + "\u00B0", 30, 8, font = "16x20", color = b[1])
        c.text(b[0], c.width - 6, 4, font = "10x16", color = b[1],
               align = "right")
        c.text(b[2], c.width - 6, 23, font = "5x7", color = "#7C90AC",
               align = "right")
    else:
        c.text_fit(shown + "\u00B0", c.width - 2, 2, ["16x20", "10x16"],
                   color = b[1], align = "right", maxw = c.width - 20)
        c.text_fit(b[0], c.width - 2, 25, ["4x5", "3x4"], color = b[1],
                   align = "right", maxw = c.width - 20)
