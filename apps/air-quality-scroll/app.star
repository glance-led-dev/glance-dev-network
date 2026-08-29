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
    # "UNHEALTHY FOR SOME" cannot sit beside a 3-digit AQI at any readable
    # font, so this band says SENSITIVE.
    [101, "SENSITIVE", "#FF9A4A", "#1A0F06"],
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
                 ttl_seconds = 3600)
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
    # SKYLINE.png is 24x18; drawing it square stretched it and pushed its
    # bottom rows off-canvas, so it is drawn at its native 4:3 aspect and
    # sat on the bottom row.
    sw = 24 if c.width >= 128 else 16
    sh = 18 if c.width >= 128 else 12
    sx = 6 if c.width >= 128 else 2
    c.image("SKYLINE.png", sx, c.height - sh, w = sw, h = sh)

    city = g[2]

    if c.width >= 128:
        # Band label drops from y=4 to y=6 so rows 0-5 are clear right across
        # the panel; that frees a full-width header, where "US AQI" can keep
        # saying what the number is AND name the place it came from. 4x5 is the
        # smallest font usable here -- 3x4 has no space glyph, so multi-word
        # names run together in it.
        head = "US AQI"
        if city != "":
            head = head + " IN " + city
        hf = _fit_clip(c, head, ["4x5"], 172)
        c.text(hf[1], 10, 0, font = hf[0], color = "#7C8496")

        num = str(v)
        c.text(num, 34, 8, font = "16x20", color = b[2])

        # A/Q/I stacked in 4x5 beside the figure, naming the US EPA index.
        # It rides on the number's real width so 3 digits cannot run into it.
        lx = 34 + c.text_width(num, "16x20") + 3
        c.text("A", lx, 9, font = "4x5", color = "#7C8496")
        c.text("Q", lx, 15, font = "4x5", color = "#7C8496")
        c.text("I", lx, 21, font = "4x5", color = "#7C8496")

        # Right column starts clear of that label at every digit count.
        rw = 190 - (lx + 4 + 3)
        bf = _fit_clip(c, b[1], ["10x16", "6x8", "5x7", "4x5"], rw)
        c.text(bf[1], 190, 6, font = bf[0], color = b[2], align = "right")
        pmt = "PM2.5 " + str(int(pm * 10) / 10.0) + " UG/M3"
        pf = _fit_clip(c, pmt, ["5x7", "4x5"], rw)
        c.text(pf[1], 190, 23, font = pf[0], color = "#96A0B4",
               align = "right")
    else:
        # city 0-4, AQI 6-25, band word 27-31: no row is shared.
        if city != "":
            cf = _fit_clip(c, city, ["4x5", "3x4"], c.width - 2)
            c.text(cf[1], c.width // 2, 0, font = cf[0], color = "#7C8496",
                   align = "center")
        c.text_fit(str(v), c.width - 2, 6, ["16x20", "10x16"], color = b[2],
                   align = "right", maxw = c.width - 20)
        c.text_fit(b[1], c.width - 2, 27, ["4x5", "3x4"], color = b[2],
                   align = "right", maxw = c.width - 4)
