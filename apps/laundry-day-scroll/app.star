# Laundry Day
#
# Drying is a race between evaporation and rain. Open-Meteo's
# reference evapotranspiration is exactly the quantity agronomists
# use for it, so it does the work here — with rain as an outright
# veto, because one shower undoes a whole afternoon.



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


def verdict(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "et0_fao_evapotranspiration,precipitation_probability_max,wind_speed_10m_max",
                           "timezone": "auto", "forecast_days": "1"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "NO CONNECTION")
        return
    d = r["json"].get("daily", {})

    def first(key):
        v = d.get(key, [])
        return float(v[0] or 0) if len(v) > 0 and v[0] != None else 0.0

    et = first("et0_fao_evapotranspiration")
    rain = first("precipitation_probability_max")
    wind = first("wind_speed_10m_max")

    if rain >= 50:
        line = "KEEP IT IN"
        col = "#FF5B5B"
        note = str(int(rain)) + "% RAIN"
    elif et >= 4.0 and rain < 20:
        line = "PERFECT"
        col = "#4EE38A"
        note = "DRY AND BREEZY"
    elif et >= 2.5:
        line = "WORTH IT"
        col = "#F5D64E"
        note = "SLOW BUT FINE"
    else:
        line = "USE THE DRYER"
        col = "#FF9A4A"
        note = "TOO DAMP"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0E1220", "#26304A",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("LAUNDRY.png", 2, 2, w = n, h = n)

    if c.width >= 128:
        c.text_fit(line, 30, 5, ["16x20", "10x16", "6x8"], color = col,
                   maxw = c.width - 70)
        c.text(note, c.width - 6, 6, font = "6x8", color = "#B0BCD4",
               align = "right")
        c.text("DRYING " + str(int(et * 10) / 10.0) + "MM   WIND "
               + str(int(wind)), c.width - 6, 24, font = "5x7",
               color = "#78849C", align = "right")
    else:
        c.text_fit(line, c.width - 2, 8, ["10x16", "6x8", "5x7"], color = col,
                   align = "right", maxw = c.width - 20)
        c.text_fit(note, c.width - 2, 25, ["4x5", "3x4"], color = "#B0BCD4",
                   align = "right", maxw = c.width - 4)
