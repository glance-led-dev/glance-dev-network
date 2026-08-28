# Ski Conditions
#
# DESIGN. Fresh snow is the number that gets people out of bed, so it leads:
# one hero readout on a flat near-black ground (the old vertical gradient was
# a full-color background that fought the apps either side of it in the
# rotation). The mountain carries the identity at the left, the resort/place
# name rides a pill that starts just past the NEW SNOW eyebrow and runs
# rightwards until it meets the temperature, and the temperature - the number
# that decides whether the snow is still there at lunchtime - is read at
# 16x20 on the right with what is still due underneath it.
#
# Scroll safe zone is x 10..182: every element is placed against SAFE_L /
# SAFE_R, and the right-hand column is measured FIRST so the hero is fitted
# into whatever is left. Resort names are the long string here, so the name is
# hard-clipped to the pill's measured budget rather than allowed to run past it.



SAFE_L = 10
SAFE_R = 182

# Font row heights - Starlark has no metrics call.
FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}

# No panel font carries a degree glyph (it measures 0 and draws nothing, which
# is how the temperature shipped as a bare "74"). These stand in for it: the
# 5px ring next to the 16x20 temperature, the 2px block next to 4x5/5x7. One
# ring per size, not per value - the sprite is sized to the font it rides.
DEG5 = """
.###.
#...#
#...#
#...#
.###.
"""
DEG2 = """
##
##
"""


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

    The two lines get explicit, non-overlapping bands - a 16px title centred
    on the panel ran straight through the line beneath it. On scroll widths
    they are measured against the safe zone (172px), not the full canvas.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    if c.width >= 128:
        maxw = SAFE_R - SAFE_L + 1
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        maxw = c.width - 6
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws - which is how a station name ended up running
    straight through the readout beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def temp_w(c, num, unit, font, art_w):
    """Width of the temperature block: number, degree mark, unit letter."""
    return (c.text_width(num, font) + 1 + art_w + 1 +
            c.text_width(unit, font))


def temp_draw(c, x, y, num, unit, font, art, art_w, color):
    c.text(num, x, y, font = font, color = color)
    nx = x + c.text_width(num, font) + 1
    c.sprite(art, nx, y + 1, color = color)
    c.text(unit, nx + art_w + 1, y, font = font, color = color)


def one(v):
    """One decimal place, e.g. 3.5 - the panel never shows more."""
    return str(int(v * 10) / 10.0)


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
                 ttl_seconds = 3600)
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
    nxt = soon if metric else soon / 2.54
    unit = "CM" if metric else "IN"
    col = "#DCF4FF" if today > 0 else "#5A6078"
    tnum = str(int(temp))
    tlet = "C" if metric else "F"
    place = g[2]
    if place == "":
        place = str(ctx.inputs.get("zip", "")).strip()

    c.fill("#05070E")

    if c.width >= 128:
        # Right column measured FIRST, because both the pill above it and the
        # hero beside it are fitted into what it leaves. Rows 5-24 carry the
        # 16x20 temperature, rows 26-30 the DUE line; the DUE line is the
        # wider of the two only when the temperature is short ("+120.5CM DUE"
        # is 57px at 4x5, "-40" with ring and F is 73px at 16x20).
        due = "+" + one(nxt) + unit + " DUE"
        dw = c.text_width(due, "4x5")
        tw = temp_w(c, tnum, tlet, "16x20", 5)
        rw = dw if dw > tw else tw
        tx = SAFE_R - tw + 1

        # Top band, y 0-10: eyebrow left, then the place pill starting 4px past
        # the end of NEW SNOW and growing rightwards. At 16x20 the temperature
        # reaches up into this band, so the pill stops 3px short of it rather
        # than running to SAFE_R, and the name is clipped to that run.
        c.text("NEW SNOW", SAFE_L, 1, font = "4x5", color = "#6E86A8")
        px = SAFE_L + c.text_width("NEW SNOW", "4x5") + 4
        # 6px of the pill is padding (pad=3 each side: at pad=2 the rounded
        # corner sat against the V of VAIL and read as part of the glyph),
        # so the text budget is the run to the temperature minus 6.
        pt = clip(c, place, "4x5", tx - 3 - px + 1 - 6)
        if pt != "":
            c.badge(pt, px, 0, color = "#05070E", bg = "#DCF4FF",
                    font = "4x5", pad = 3)

        temp_draw(c, tx, 5, tnum, tlet, "16x20", DEG5, 5, "#8FD4FF")
        c.text(due, SAFE_R, 26, font = "4x5", color = "#6E86A8",
               align = "right")

        # Identity art, bottom-aligned with the hero at y 28.
        c.image("MOUNTAIN.png", SAFE_L, 11, w = 24, h = 18)

        # The hero takes the run that is left, with a 6px gutter to the right
        # column, and drops a font rung rather than running into it: at 16x20
        # the temperature is wide enough that "0.0IN" already falls to 10x16,
        # and "120.5CM" beside "-40" falls again to 6x8. Only a 1-digit
        # temperature leaves the hero its own 16x20.
        hx = SAFE_L + 24 + 4
        h = _fit_clip(c, one(shown) + unit, ["16x20", "10x16", "6x8"],
                      SAFE_R - rw - 6 - hx + 1)
        c.text_stroke(h[1], hx, 29 - FONTH[h[0]], font = h[0], color = col,
                      stroke = "#05070E")
    else:
        # 64px: maximize the space. The art sits in the bottom-left corner and
        # the readouts are stroked, since a long value runs over it.
        c.image("MOUNTAIN.png", 1, 20, w = 16, h = 12)
        h = _fit_clip(c, one(shown) + unit, ["10x16", "6x8", "5x7"],
                      c.width - 4)
        c.text_stroke(h[1], c.width - 2, 1, font = h[0], color = col,
                      stroke = "#05070E", align = "right")
        tw = temp_w(c, tnum, tlet, "5x7", 2)
        temp_draw(c, c.width - 2 - tw, 24, tnum, tlet, "5x7", DEG2, 2,
                  "#8FD4FF")
