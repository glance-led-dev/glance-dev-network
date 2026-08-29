# Snowpack
#
# Base depth is the number that decides whether a mountain is worth
# the drive — new snow on a thin base is still rocks. The seven-day
# change says whether the pack is building or going.



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


def depth(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "snow_depth_max", "timezone": "auto",
                           "past_days": "7", "forecast_days": "1"},
                 ttl_seconds = 7200)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO SNOW DATA", "NO CONNECTION")
        return
    vals = r["json"].get("daily", {}).get("snow_depth_max", [])
    clean = []
    for v in vals:
        if v != None:
            clean.append(float(v))
    if len(clean) == 0:
        nodata(c, "NO SNOW DATA", "NOT MODELLED")
        return

    # metres in the feed
    now_m = clean[len(clean) - 1]
    then_m = clean[0]
    inches = now_m * 39.3701
    change = (now_m - then_m) * 39.3701

    if inches < 1:
        col = "#5A6078"
        note = "BARE"
    elif inches < 12:
        col = "#8FD4FF"
        note = "THIN"
    elif inches < 36:
        col = "#DCF4FF"
        note = "DECENT BASE"
    else:
        col = "#FFFFFF"
        note = "DEEP"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0A1220", "#22344C",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    c.image("SLIDE.png", 1, c.height - sz, w = sz, h = sz)

    sign = "+" if change >= 0 else ""
    if c.width >= 128:
        # The band word is drawn first so the label and the depth can be given
        # what is actually left. It used to be a fixed 10x16 right-aligned with
        # no maxw, and "DECENT BASE" is 119px in that font -- it began at x=67
        # and ran back through both "BASE DEPTH" (ends x=77) and the depth
        # itself, whose maxw let it reach x=102.
        #
        # That is the 12-36 inch band, so the panel was broken for ordinary
        # midwinter snowpack while BARE, THIN and DEEP -- all short words --
        # looked perfectly fine. Capping the word at 90px keeps those three at
        # 10x16 and drops only the long one to 6x8, which buys back 43px.
        nf = _fit_clip(c, note, ["10x16", "6x8"], 90)
        c.text(nf[1], c.width - 6, 4, font = nf[0], color = col,
               align = "right")
        c.text("BASE DEPTH", 30, 2, font = "4x5", color = "#6E86A8")
        # The depth has two neighbours, not one. At 16x20 it spans rows 8-27,
        # so it shares rows with the band word above AND the 7-day line below,
        # and it has to clear whichever starts further left. A three-digit
        # depth beside a short word (120 IN / DEEP) cleared the word but ran
        # into the 7-day line.
        detail = sign + str(int(change)) + " IN 7 DAYS"
        room = c.width - 44 - c.text_width(nf[1], nf[0])
        below = c.width - 42 - c.text_width(detail, "5x7")
        if below < room:
            room = below
        c.text_fit(str(int(inches)) + " IN", 30, 8, ["16x20", "10x16"],
                   color = col, maxw = room)
        c.text(detail, c.width - 6, 23, font = "5x7", color = "#8AA4C0",
               align = "right")
    else:
        c.text_fit(str(int(inches)) + "IN", c.width - 2, 3, ["16x20", "10x16"],
                   color = col, align = "right", maxw = c.width - 20)
        c.text(sign + str(int(change)) + " 7D", c.width - 2, 25, font = "4x5",
               color = "#8AA4C0", align = "right")
