# Wind Report
#
# Gusts matter more than the average for most people who care about
# wind, so they sit beside it rather than behind a second page.
# The Beaufort description is the plain-language version.



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


COMPASS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
BEAUFORT = [
    [1, "CALM", "#5A6078"], [4, "LIGHT AIR", "#7FB6E8"],
    [8, "LIGHT BREEZE", "#6FD4C8"], [13, "GENTLE", "#4EE38A"],
    [19, "MODERATE", "#A8E34E"], [25, "FRESH", "#F5D64E"],
    [32, "STRONG", "#FF9A4A"], [39, "NEAR GALE", "#FF6B4A"],
    [47, "GALE", "#FF3B3B"], [64, "STORM", "#C83BE8"],
]


def beaufort(mph):
    out = BEAUFORT[0]
    for b in BEAUFORT:
        if mph >= b[0]:
            out = b
    return out


def wind(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    metric = str(ctx.inputs.get("units", "IMPERIAL")).upper() == "METRIC"
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "current": "wind_speed_10m,wind_gusts_10m,wind_direction_10m",
                           "wind_speed_unit": "kmh" if metric else "mph",
                           "timezone": "auto"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO WIND DATA", "NO CONNECTION")
        return
    cur = r["json"].get("current", {})
    speed = float(cur.get("wind_speed_10m", 0) or 0)
    gust = float(cur.get("wind_gusts_10m", 0) or 0)
    deg = float(cur.get("wind_direction_10m", 0) or 0)
    mph = speed if not metric else speed * 0.621371
    b = beaufort(mph)
    unit = "KMH" if metric else "MPH"
    card = COMPASS[int((deg % 360) / 45.0 + 0.5) % 8]

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#08131C", "#1E3648",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("WINDSOCK.png", 2, 3, w = n, h = n)

    if c.width >= 128:
        c.text(str(int(speed)), 30, 6, font = "16x20", color = b[2])
        c.text(unit, 30 + c.text_width(str(int(speed)), "16x20") + 3, 19,
               font = "5x7", color = "#7C90A8")
        c.text_fit(b[1], c.width - 6, 3, ["10x16", "6x8", "5x7"], color = b[2],
                   align = "right", maxw = c.width - 110)
        c.text("GUST " + str(int(gust)) + "   " + card, c.width - 6, 22,
               font = "6x8", color = "#A8BCD0", align = "right")
    else:
        c.text_fit(str(int(speed)), c.width - 2, 3, ["16x20", "10x16"],
                   color = b[2], align = "right", maxw = c.width - 20)
        c.text("G" + str(int(gust)) + " " + card, c.width - 2, 25,
               font = "4x5", color = "#A8BCD0", align = "right")
