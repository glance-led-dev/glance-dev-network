# Quakes Near Me
#
# The same USGS feed as the global watch, but sorted by distance
# from your zip rather than by magnitude. A magnitude 3 forty miles
# away matters more to you than a magnitude 6 on the other side of
# the planet, which is the opposite of what a global list shows.



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


def haversine(lat1, lon1, lat2, lon2):
    """Great-circle distance in miles."""
    r = 3958.8
    p1 = math.radians(lat1)
    p2 = math.radians(lat2)
    dp = math.radians(lat2 - lat1)
    dl = math.radians(lon2 - lon1)
    a = math.sin(dp / 2) * math.sin(dp / 2) + \
        math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2)
    if a < 0:
        a = 0.0
    if a > 1:
        a = 1.0
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def magcolor(m):
    if m >= 5:
        return "#FF3B3B"
    if m >= 4:
        return "#FF9A4A"
    if m >= 3:
        return "#F5D64E"
    return "#6FD4FF"


def nearest(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson",
                 ttl_seconds = 900)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO QUAKE DATA", "NO CONNECTION")
        return
    feats = r["json"].get("features", [])
    if len(feats) == 0:
        nodata(c, "NO QUAKES", "NONE ABOVE M2.5")
        return

    best = None
    bestd = 0.0
    for f in feats:
        coords = f.get("geometry", {}).get("coordinates", [])
        if len(coords) < 2:
            continue
        d = haversine(g[0], g[1], float(coords[1]), float(coords[0]))
        if best == None or d < bestd:
            best = f
            bestd = d
    if best == None:
        nodata(c, "NO QUAKES", "NO POSITIONS")
        return

    pr = best["properties"]
    m = float(pr.get("mag", 0) or 0)
    place = str(pr.get("place", "")).upper()
    col = magcolor(m)
    mins = (ctx.now.unix - int(pr.get("time", 0) or 0) // 1000) // 60
    when = (str(mins) + "M AGO") if mins < 60 else \
           ((str(mins // 60) + "H AGO") if mins < 1440 else (str(mins // 1440) + "D AGO"))

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#120C06", "#2C1E10",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    c.image("CRACKED.png", 1, c.height - sz, w = sz, h = sz)

    if c.width >= 128:
        c.text("M" + str(int(m * 10) / 10.0), 30, 3, font = "16x20", color = col)
        c.text(fmt.commas(int(bestd)) + " MI", c.width - 6, 3, font = "10x16",
               color = "#FFD8A8", align = "right")
        c.text(clip(c, place, "5x7", c.width - 96) + "   " + when, c.width - 6,
               23, font = "5x7", color = "#C0A488", align = "right")
    else:
        c.text_fit("M" + str(int(m * 10) / 10.0), c.width - 2, 2,
                   ["16x20", "10x16"], color = col, align = "right",
                   maxw = c.width - 20)
        c.text_fit(str(int(bestd)) + "MI " + when, c.width - 2, 25,
                   ["4x5", "3x4"], color = "#FFD8A8", align = "right",
                   maxw = c.width - 20)
