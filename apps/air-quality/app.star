# Air Quality
#
# Open-Meteo's air quality model, which needs no key. The skyline
# behind the number fades into the haze colour as AQI climbs, so
# the panel reads as bad air before you have read the figure.
#
# Bands and colours follow the US EPA scale.



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
    [0, "GOOD", "#4EE38A", "#0A1410"],
    [51, "MODERATE", "#F5D64E", "#171406"],
    [101, "UNHEALTHY FOR SOME", "#FF9A4A", "#1A0F06"],
    [151, "UNHEALTHY", "#FF5B5B", "#1A0808"],
    [201, "VERY UNHEALTHY", "#C86BE8", "#140818"],
    [301, "HAZARDOUS", "#B4304A", "#160408"],
]


def band(v):
    out = BANDS[0]
    for b in BANDS:
        if v >= b[0]:
            out = b
    return out


def aqi(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://air-quality-api.open-meteo.com/v1/air-quality",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "current": "us_aqi,pm2_5", "timezone": "auto"},
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO AIR DATA", "NO CONNECTION")
        return
    cur = r["json"].get("current", {})
    if cur.get("us_aqi", None) == None:
        nodata(c, "NO AQI", "NOT MODELLED HERE")
        return

    v = int(float(cur.get("us_aqi", 0) or 0))
    pm = float(cur.get("pm2_5", 0) or 0)
    b = band(v)

    # Haze the sky toward the band colour as the air worsens.
    c.gradient_rect(0, 0, c.width - 1, c.height - 1, b[3], b[2] if v > 100 else "#1A2230",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("SKYLINE.png", 2, c.height - n + 4, w = n, h = n)

    if c.width >= 128:
        c.text("US AQI", 30, 2, font = "4x5", color = "#7C8496")
        c.text(str(v), 30, 8, font = "16x20", color = b[2])
        c.text_fit(b[1], c.width - 6, 4, ["10x16", "6x8", "5x7"], color = b[2],
                   align = "right", maxw = c.width - 96)
        c.text("PM2.5 " + str(int(pm * 10) / 10.0), c.width - 6, 23,
               font = "5x7", color = "#96A0B4", align = "right")
    else:
        c.text_fit(str(v), c.width - 2, 3, ["16x20", "10x16"], color = b[2],
                   align = "right", maxw = c.width - 20)
        c.text_fit(b[1], c.width - 2, 25, ["4x5", "3x4"], color = b[2],
                   align = "right", maxw = c.width - 4)
