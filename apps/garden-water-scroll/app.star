# Garden Water
#
# Evapotranspiration is what the soil lost to the air; precipitation
# is what it got back. The difference over three days is a far
# better guide than 'has it rained today', which is the question
# most people ask and most people get wrong.



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


def water(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "et0_fao_evapotranspiration,precipitation_sum",
                           "timezone": "auto", "past_days": "3",
                           "forecast_days": "1"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "NO CONNECTION")
        return
    d = r["json"].get("daily", {})
    ets = d.get("et0_fao_evapotranspiration", [])
    rain = d.get("precipitation_sum", [])

    lost = 0.0
    got = 0.0
    days = len(ets) if len(ets) < len(rain) else len(rain)
    if days == 0:
        nodata(c, "NO DATA", "EMPTY FEED")
        return
    for i in range(days):
        lost += float(ets[i] or 0)
        got += float(rain[i] or 0)
    deficit = lost - got

    if deficit <= 0:
        line = "NO NEED"
        col = "#4EE38A"
        note = "RAIN COVERED IT"
    elif deficit < 8:
        line = "NOT YET"
        col = "#A8E34E"
        note = str(int(deficit)) + "MM SHORT"
    elif deficit < 16:
        line = "WATER SOON"
        col = "#F5D64E"
        note = str(int(deficit)) + "MM SHORT"
    else:
        line = "WATER NOW"
        col = "#FF7A4A"
        note = str(int(deficit)) + "MM SHORT"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#08120C", "#1C3424",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("WATERCAN.png", 2, 3, w = n, h = n)

    if c.width >= 128:
        c.text_fit(line, 30, 5, ["16x20", "10x16"], color = col,
                   maxw = c.width - 80)
        c.text(note, c.width - 6, 6, font = "6x8", color = "#9CBCA4",
               align = "right")
        c.text("LOST " + str(int(lost)) + "MM   RAIN " + str(int(got)) + "MM",
               c.width - 6, 24, font = "5x7", color = "#6E8C78",
               align = "right")
    else:
        c.text_fit(line, c.width - 2, 8, ["10x16", "6x8"], color = col,
                   align = "right", maxw = c.width - 20)
        c.text(note, c.width - 2, 25, font = "4x5", color = "#9CBCA4",
               align = "right")
