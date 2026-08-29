# Feels Like
#
# Apparent temperature is the number worth showing, but on its own
# it explains nothing. Dew point is what people feel as mugginess —
# above about 65F it is genuinely unpleasant regardless of what the
# thermometer says — so it gets named alongside.



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


def degree_mark(c, x, y, color):
    """Draw the degree ring. None of the bitmap fonts carry a U+00B0 glyph, so
    a literal "°" in a string measures 0px wide and draws nothing at all --
    the temperature silently rendered as a bare number. Radius 1 gives the 3x3
    ring that reads as a degree at LED scale."""
    c.circle(x + 1, y + 1, 1, color)


def draw_temp(c, x, y, val, font, color, unit):
    """Temperature + degree ring, drawn left-to-right from x. `unit` adds the
    F/C letter after the ring; pass "" on narrow panels, where the ring alone
    keeps the number in the big font. Returns the width drawn."""
    s = str(int(val))
    w = c.text_width(s, font)
    c.text(s, x, y, font = font, color = color)
    degree_mark(c, x + w + 1, y + 1, color)
    if unit != "":
        c.text(unit, x + w + 6, y + 1, font = "5x7", color = color)
    return temp_group_width(c, val, font, unit)


def temp_group_width(c, val, font, unit):
    w = c.text_width(str(int(val)), font) + 4
    if unit != "":
        w = w + 2 + c.text_width(unit, "5x7")
    return w


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


def mugginess(dewf):
    if dewf < 50:
        return ["DRY", "#7FB6E8"]
    if dewf < 60:
        return ["PLEASANT", "#4EE38A"]
    if dewf < 65:
        return ["STICKY", "#F5D64E"]
    if dewf < 70:
        return ["MUGGY", "#FF9A4A"]
    return ["OPPRESSIVE", "#FF5B5B"]


def feels(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    metric = str(ctx.inputs.get("units", "IMPERIAL")).upper() == "METRIC"
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "current": "temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m",
                           "temperature_unit": "celsius" if metric else "fahrenheit",
                           "timezone": "auto"},
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO WEATHER", "NO CONNECTION")
        return
    cur = r["json"].get("current", {})
    real = float(cur.get("temperature_2m", 0) or 0)
    app = float(cur.get("apparent_temperature", 0) or 0)
    rh = float(cur.get("relative_humidity_2m", 0) or 0)
    dew = float(cur.get("dew_point_2m", 0) or 0)
    dewf = dew if not metric else dew * 9 / 5 + 32
    m = mugginess(dewf)

    diff = app - real
    if diff >= 1:
        gap = "+" + str(int(diff)) + " WARMER"
    elif diff <= -1:
        gap = str(int(diff)) + " COLDER"
    else:
        gap = "AS IT LOOKS"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#140A0A", "#2E1A18",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("THERMO.png", 2, (c.height - n) // 2, w = n, h = n)

    unit = "C" if metric else "F"
    city = g[2]

    if c.width >= 128:
        # Header carries the city so the reading is anchored to a place; the app
        # is already called "Feels Like", so the city is the useful half. The
        # mugginess word can start as far left as x=104, so clip before it.
        head = city if city != "" else "FEELS LIKE"
        hf = _fit_clip(c, head, ["4x5"], 74)
        c.text(hf[1], 28, 2, font = hf[0], color = "#987070")
        draw_temp(c, 28, 8, app, "16x20", "#FFD0B0", unit)
        c.text_fit(m[0], c.width - 6, 3, ["10x16", "6x8"], color = m[1],
                   align = "right", maxw = c.width - 110)
        c.text(gap + "   " + str(int(rh)) + "% RH", c.width - 6, 23,
               font = "5x7", color = "#C0A098", align = "right")
    else:
        # 64px: the city gets the top strip, which is otherwise empty, and the
        # temperature drops to y=7 to make room for it.
        if city != "":
            cf = _fit_clip(c, city, ["4x5", "3x4"], c.width - 2)
            c.text(cf[1], c.width // 2, 0, font = cf[0], color = "#987070",
                   align = "center")
        # Ring only, no F/C: at 64px the letter would force the number down to
        # a smaller font, and the units setting is the user's own choice anyway.
        tfont = "16x20"
        if temp_group_width(c, app, tfont, "") > c.width - 22:
            tfont = "10x16"
        # city 0-4, temperature 6-25, word 27-31: no row is shared.
        tw = temp_group_width(c, app, tfont, "")
        draw_temp(c, c.width - 2 - tw, 6, app, tfont, "#FFD0B0", "")
        c.text_fit(m[0], c.width - 2, 27, ["4x5", "3x4"], color = m[1],
                   align = "right", maxw = c.width - 4)
