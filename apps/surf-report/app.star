# Surf Report
#
# Open-Meteo's marine model. Period matters as much as height —
# a four foot swell at fourteen seconds is a different ocean from
# four foot at six — so both get equal billing, and the verdict
# weighs them together rather than ranking on height alone.



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


COMPASS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]


def compass(deg):
    return COMPASS[int((deg % 360) / 45.0 + 0.5) % 8]


def verdict(ft, period):
    """Height and period together. Long-period swell at modest height beats
    short-period slop at the same height every time."""
    if ft < 1.0:
        return ["FLAT", "#5A6078"]
    score = ft * (1.0 + (period - 8.0) / 12.0 if period > 0 else 1.0)
    if score < 1.5:
        return ["SMALL", "#7FB6E8"]
    if score < 3.5:
        return ["FUN", "#4EE38A"]
    if score < 6.0:
        return ["SOLID", "#FFC53F"]
    return ["BIG", "#FF6B4A"]


def surf(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://marine-api.open-meteo.com/v1/marine",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "current": "wave_height,wave_period,wave_direction",
                           "timezone": "auto"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO SURF DATA", "NO CONNECTION")
        return
    cur = r["json"].get("current", {})
    if cur.get("wave_height", None) == None:
        nodata(c, "NO SWELL DATA", "TRY A COASTAL ZIP")
        return

    metres = float(cur.get("wave_height", 0) or 0)
    period = float(cur.get("wave_period", 0) or 0)
    deg = float(cur.get("wave_direction", 0) or 0)
    metric = str(ctx.inputs.get("units", "IMPERIAL")).upper() == "METRIC"
    height = metres if metric else metres * 3.28084
    unit = "M" if metric else "FT"
    v = verdict(metres * 3.28084, period)

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#04121E", "#0A2E4C",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("WAVE.png", 2, c.height - n + 4, w = n, h = n)

    if c.width >= 128:
        # Two columns, both filled top to bottom. Before, the height sat in a
        # 16x20 at the top left with the town tucked under it, and the right
        # held only a verdict and a swell line -- which left a dead block
        # through the middle of the panel and a bare strip along the bottom.
        #
        # The town moves into the right column so the three secondary readings
        # stack there (0-5, 7-22, 24-31), and the height takes whatever font
        # actually fits the space that leaves. It lands on 16x24 for a normal
        # reading instead of 16x20, so the hero number grows into the gap
        # rather than the gap staying empty.
        htxt = str(int(height * 10) / 10.0) + unit
        town = clip(c, g[2], "4x5", 70)
        rcol = c.text_width(v[0], "10x16")
        if c.text_width(town, "4x5") > rcol:
            rcol = c.text_width(town, "4x5")
        swell = str(int(period)) + "S " + compass(deg)
        if c.text_width(swell, "6x8") > rcol:
            rcol = c.text_width(swell, "6x8")

        c.text(town, c.width - 6, 0, font = "4x5", color = "#4E7A9C",
               align = "right")
        c.text(v[0], c.width - 6, 7, font = "10x16", color = v[1],
               align = "right")
        c.text(swell, c.width - 6, 24, font = "6x8", color = "#7FB6E8",
               align = "right")
        c.text_fit(htxt, 30, 3, ["19x28", "16x24", "16x20", "10x16"],
                   color = "#DCF0FF", maxw = c.width - rcol - 44)
    else:
        c.text_fit(str(int(height * 10) / 10.0) + unit, c.width - 2, 3,
                   ["16x20", "10x16"], color = "#DCF0FF", align = "right",
                   maxw = c.width - 20)
        c.text(str(int(period)) + "S " + compass(deg), c.width - 2, 25,
               font = "4x5", color = "#7FB6E8", align = "right")
