# Snowpack
#
# DESIGN. This is Ski Conditions' twin and it now wears the same clothes, so
# the two read as one family when they play back to back: flat near-black
# ground (#05070E - the old vertical gradient was a full-color background
# that fought the apps either side of it in the rotation), a 4x5 eyebrow at
# the top left saying what the big number is, the place name in a c.badge
# pill that starts just off the eyebrow and runs right, identity art at the
# left, one hero readout stroked against the ground, and a right column that is
# measured FIRST so the hero is fitted into whatever is left over.
#
# The payload is the only thing that differs. Ski Conditions answers "did it
# snow"; Snowpack answers "is there anything under it": base depth is the
# hero, the band word (BARE / THIN / DECENT BASE / DEEP) takes the right
# column's readout slot in the depth's own colour, and the seven-day change
# rides the small line beneath it - the same place the sibling puts what is
# still due.
#
# Scroll safe zone is x 10..182: every element is placed against SAFE_L /
# SAFE_R. Place names are the long string here ("VILLAGE OF GROSSE POINTE
# SHORES" is 146px at 4x5, past anything the pill can hold), so the name is
# clipped to its measured budget.



SAFE_L = 10
SAFE_R = 182

# Last column the place pill may light. The band word is drawn right-aligned
# on SAFE_R, so its final glyph ends one column short of it; the pill stops
# on that same column and the name is clipped to suit.
PILL_R = SAFE_R - 1

# Font row heights - Starlark has no metrics call.
FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}

GROUND = "#05070E"
EYEBROW = "#6E86A8"
DETAIL = "#8AA4C0"

# "DECENT BASE" is the long band word: 180px at 16x20 and still 119px at
# 10x16, and at that width it walks straight back through the hero. Capping
# the word at 70px keeps BARE / THIN / DEEP (43px) in the big 10x16 and drops
# only the long one to 5x7 (65px), which leaves the hero 76px - enough for an
# ordinary "35IN" at 16x20 (67px). Uncapped, the 12-36 inch band - i.e. the
# whole of midwinter - was the broken one while the short words looked fine.
WORD_CAP = 70


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


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws - which is how a basin name ended up running
    straight through the readout beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands - a 16px title centred
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


def band(inches):
    """[word, colour] from one function, so the word and the colour can
    never disagree. The colour dresses the hero, exactly as the sibling's
    snow total is dressed by whether anything fell."""
    if inches < 1:
        return ["BARE", "#5A6078"]
    if inches < 12:
        return ["THIN", "#8FD4FF"]
    if inches < 36:
        return ["DECENT BASE", "#DCF4FF"]
    return ["DEEP", "#FFFFFF"]


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
    b = band(inches)
    sign = "+" if change >= 0 else ""
    place = g[2]
    if place == "":
        place = str(ctx.inputs.get("zip", "")).strip()

    c.fill(GROUND)

    if c.width >= 128:
        # Top band, y 0-6: eyebrow left, then the place pill starting 4px off
        # the end of the eyebrow and growing right. Its last column may reach
        # PILL_R - the column where the right-aligned band word's final glyph
        # ends - and the name is clipped to whatever budget that leaves, so a
        # long place stops dead in line with the word instead of running on.
        c.text("BASE DEPTH", SAFE_L, 1, font = "4x5", color = EYEBROW)
        px = SAFE_L + c.text_width("BASE DEPTH", "4x5") + 4
        # 6px of the pill is padding (pad=3 each side: at pad=2 the rounded
        # corner sat against the V of VAIL and read as part of the glyph).
        pt = clip(c, place, "4x5", PILL_R - px - 5)
        if pt != "":
            c.badge(pt, px, 0, color = GROUND, bg = "#DCF4FF", font = "4x5",
                    pad = 3)

        # Right column measured first: the band word sits in the readout slot
        # and the seven-day line under it, and the wider of the two is what
        # the hero has to clear. "-393 IN 7 DAYS" is the worst change line at
        # 63px in 4x5.
        nf = _fit_clip(c, b[0], ["10x16", "6x8", "5x7"], WORD_CAP)
        nw = c.text_width(nf[1], nf[0])
        detail = sign + str(int(change)) + " IN 7 DAYS"
        dw = c.text_width(detail, "4x5")
        rw = dw if dw > nw else nw

        # The word is bottom-aligned on row 23 whichever rung it lands on, so
        # the small line below it always keeps its 2px of air.
        c.text_stroke(nf[1], SAFE_R, 24 - FONTH[nf[0]], font = nf[0],
                      color = b[1], stroke = GROUND, align = "right")
        c.text_stroke(detail, SAFE_R, 26, font = "4x5", color = DETAIL,
                      stroke = GROUND, align = "right")

        # Identity art - one generic slope for every zip - bottom-aligned
        # with the hero at y 28.
        c.image("SLIDE.png", SAFE_L, 11, w = 24, h = 18)

        hx = SAFE_L + 24 + 4
        h = _fit_clip(c, str(int(inches)) + "IN", ["16x20", "10x16", "6x8"],
                      SAFE_R - rw - 4 - hx + 1)
        c.text_stroke(h[1], hx, 29 - FONTH[h[0]], font = h[0], color = b[1],
                      stroke = GROUND)
    else:
        # 64px: maximize the space. The art sits in the bottom-left corner and
        # the readouts are stroked, since a long value runs over it.
        c.image("SLIDE.png", 1, 20, w = 16, h = 12)
        h = _fit_clip(c, str(int(inches)) + "IN", ["10x16", "6x8", "5x7"],
                      c.width - 4)
        c.text_stroke(h[1], c.width - 2, 1, font = h[0], color = b[1],
                      stroke = GROUND, align = "right")
        # Shorter copy, not clipped copy: the seven-day change becomes "/7D".
        line = _fit_clip(c, b[0] + " " + sign + str(int(change)) + "/7D",
                         ["4x5"], c.width - 4)
        c.text_stroke(line[1], c.width - 2, 25, font = line[0], color = DETAIL,
                      stroke = GROUND, align = "right")
