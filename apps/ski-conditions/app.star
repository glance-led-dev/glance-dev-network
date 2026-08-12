# Ski Conditions
#
# Fresh snow is the number that gets people out of bed, so it leads.
# The temperature beside it is the one that decides whether the snow
# will still be there at lunchtime.



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


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws — which is how a station name ended up running
    straight through the readout beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def snow(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    metric = str(ctx.inputs.get("units", "IMPERIAL")).upper() == "METRIC"
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "current": "temperature_2m",
                           "daily": "snowfall_sum,temperature_2m_min",
                           "temperature_unit": "celsius" if metric else "fahrenheit",
                           "timezone": "auto", "forecast_days": "3"},
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO SNOW DATA", "NO CONNECTION")
        return

    j = r["json"]
    temp = float(j.get("current", {}).get("temperature_2m", 0) or 0)
    daily = j.get("daily", {})
    fall = daily.get("snowfall_sum", [])
    # Open-Meteo reports snowfall in cm regardless of temperature unit.
    today = float(fall[0] or 0) if len(fall) > 0 else 0.0
    soon = 0.0
    for i in range(1, len(fall)):
        soon += float(fall[i] or 0)

    shown = today if metric else today / 2.54
    unit = "CM" if metric else "IN"
    col = "#DCF4FF" if today > 0 else "#5A6078"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0A1424", "#22354E",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("MOUNTAIN.png", 2, c.height - n + 3, w = n, h = n)

    if c.width >= 128:
        c.text("NEW SNOW", 30, 2, font = "4x5", color = "#6E86A8")
        c.text(str(int(shown * 10) / 10.0) + unit, 30, 8, font = "16x20",
               color = col)
        c.text(str(int(temp)) + "\u00B0", c.width - 6, 3, font = "16x20",
               color = "#8FD4FF", align = "right")
        nxt = soon if metric else soon / 2.54
        c.text("+" + str(int(nxt * 10) / 10.0) + unit + " DUE", c.width - 6, 24,
               font = "5x7", color = "#6E86A8", align = "right")
    else:
        c.text_fit(str(int(shown)) + unit, c.width - 2, 3, ["16x20", "10x16"],
                   color = col, align = "right", maxw = c.width - 20)
        c.text(str(int(temp)) + "\u00B0", c.width - 2, 25, font = "4x5",
               color = "#8FD4FF", align = "right")
