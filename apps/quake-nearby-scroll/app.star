# Quakes Near Me
#
# The same USGS feed as the global watch, but sorted by distance
# from your zip rather than by magnitude. A magnitude 3 forty miles
# away matters more to you than a magnitude 6 on the other side of
# the planet, which is the opposite of what a global list shows.
#
# DESIGN. The panel reads left to right as one sentence: a title rail
# ("QUAKE" stacked between two hairline bars) names the app the instant it
# scrolls on, cracked ground carries the identity art, the magnitude is the
# hero, and the whole point of the app -- how far away it was, from where --
# sits in its own column on the right. Every zone has a hard x range and every
# string is measured into it, so nothing can grow into its neighbour.
#
# Zones on 192x32 (last usable column is 185: 6px of edge padding each side,
# matching the 6px of padding in front of the rail bar at x=6):
#     0..15    rail      bars x6 / x13, 4x5 letters x8..11
#     17..40   art       CRACKED.png at its authored 24x18
#     44..113  main      magnitude hero (16x20)
#     117      divider   1px hairline
#     121..185 meta      distance + MI + the user's town
#     17..185  footer    quake place (left) + time ago (right)


# --- layout ------------------------------------------------------------------
# The old wide layout stacked a 16x20 hero at y=3 (rows 3-22) directly on top
# of a 5x7 row at y=23 (rows 23-29): zero clear rows, so "M2.4" and
# "10 KM NNW OF COR" ran into each other. Worse, the two top-row values were
# both drawn at hand-picked x: "M10.0" is 84px at 16x20 (x30-113) and
# "12,450 MI" is 96px at 10x16 (right-aligned to x90), a 24px overlap the day
# a far quake showed up. Every band below is measured, not guessed.
RAIL_BAR_L = 6          # 6px of dead space to x=0 -- the app's left edge buffer
RAIL_TXT_X = 8          # 4x5 glyphs are 4 wide -> x8..11, 1px clear of each bar
RAIL_BAR_R = 13
RAIL_WORD = "QUAKE"
RAIL_LH = 5             # every glyph of QUAKE in 4x5 is exactly 5 rows of ink
RAIL_GAP = 1            # 1px between stacked letters (5*5 + 4*1 = 29 rows)

ART_X = 17
ART_Y = 2
ART_W = 24              # CRACKED.png is authored 24x18 and is drawn at
ART_H = 18              # native size -- no rescale, so no soft pixels

MAIN_X = 44
MAIN_W = 70             # "M9.5" (the largest quake ever recorded) is 67px at
                        # 16x20; "M10.0" is 84 and drops a rung to 10x16
DIV_X = 117
DIV_Y = 1
DIV_H = 22
META_X = 121
RIGHT = 186             # align="right" anchor: drawn text ends at RIGHT-1 = 185

UNIT = "MI"
UNIT_FONT = "4x5"
UNIT_INK = 5            # 4x5 letter ink height, used to sit MI on the number
DIST_FONTS = ["10x16", "8x12", "6x8"]
# bottom row of digit ink per font, so the MI label baselines with the number
INK_BOT = {"10x16": 14, "8x12": 11, "6x8": 7}

HERO_Y = 1              # 16x20 hero occupies rows 1..20
DIST_Y = 1              # 10x16 number occupies rows 1..15 of ink
TOWN_Y = 18             # 4x5, rows 18..22 -- 2 clear rows under the number
FOOT_Y = 24             # 5x7, rows 24..30 -- 1 clear row under the town,
                        # 1 clear row above the bottom edge
FOOT_GAP = 5            # place -> time gutter; 1px reads as one run-on word
                        # at 30ft, so the footer buys itself a word space

COL_HERO_BG_A = "#120C06"
COL_HERO_BG_B = "#2C1E10"
COL_RAIL_TEXT = "white"
COL_DIVIDER = "#4A3520"
COL_VALUE = "white"     # live numbers rest at white; colour means magnitude
COL_LABEL = "#9C8874"
COL_PLACE = "#D8BFA2"


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


def rail(c, bar_color):
    """QUAKE spelled downward between two 1px bars, hard against the left edge.

    This is the app's context switch: on a scroll wall an unknown app plays
    before this one, and a bare magnitude tells a viewer nothing about what
    they are looking at. The bars wear the magnitude colour so the rail states
    the app AND its severity in the same 8 columns."""
    n = len(RAIL_WORD)
    h = n * RAIL_LH + (n - 1) * RAIL_GAP        # 29 rows
    y0 = (c.height - h) // 2                    # 1 -> rows 1..29
    c.vline(RAIL_BAR_L, y0, h, bar_color)
    c.vline(RAIL_BAR_R, y0, h, bar_color)
    for i in range(n):
        c.text(RAIL_WORD[i], RAIL_TXT_X, y0 + i * (RAIL_LH + RAIL_GAP),
               font = UNIT_FONT, color = COL_RAIL_TEXT)


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands -- a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail, centred on the space right of the rail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    if c.width >= 128:
        rail(c, "#E8B04A")
        cx = (ART_X + RIGHT - 1) // 2           # 101, centre of the free space
        maxw = 2 * (cx - ART_X)                 # 168, symmetric about cx
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], cx, 4, font = t[0], color = "#E8B04A", align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], cx, 22, font = d[0], color = "#6A7090", align = "center")
    else:
        maxw = c.width - 6
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


def clip_dots(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`, ending in ".."
    whenever anything was dropped.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws — which is how a station name ended up running
    straight through the readout beside it. The trailing dots matter too: a
    bare character clip turned "CORCORAN" into "CORCORA", which reads as a
    typo rather than as a truncation."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        p = t[:k]
        # "PAPUA NEW .." and "SEVERO-KURILSK,.." both read as broken
        # punctuation, so a dangling separator comes off before the dots.
        for _ in range(3):
            if p.endswith(" ") or p.endswith(",") or p.endswith("-"):
                p = p[:len(p) - 1]
        if p == "":
            continue
        s = p + ".."
        if c.text_width(s, font) <= maxw:
            return s
    return ""


def locality(place):
    """The town half of a USGS place string.

    USGS writes "10 KM NNW OF CORCORAN, CALIFORNIA". The leading offset is the
    quake's distance from the nearest town, which on this panel sits three
    inches from the distance to YOU and reads as a contradiction -- and it
    costs 60px of the footer, enough to clip the town name that actually
    matters. Keep the locality; the number on the right is the app's."""
    p = str(place).upper()
    i = p.rfind(" OF ")
    if i >= 0:
        return p[i + 4:]
    return p


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
                 ttl_seconds = 3600)
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
    place = locality(pr.get("place", ""))
    col = magcolor(m)
    mins = (ctx.now.unix - int(pr.get("time", 0) or 0) // 1000) // 60
    when = (str(mins) + "M AGO") if mins < 60 else \
           ((str(mins // 60) + "H AGO") if mins < 1440 else (str(mins // 1440) + "D AGO"))
    mag = "M" + str(int(m * 10) / 10.0)
    dist = fmt.commas(int(bestd))

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, COL_HERO_BG_A,
                    COL_HERO_BG_B, horizontal = False)

    if c.width >= 128:
        rail(c, col)
        c.image("CRACKED.png", ART_X, ART_Y, w = ART_W, h = ART_H)
        c.vline(DIV_X, DIV_Y, DIV_H, COL_DIVIDER)

        # hero: magnitude, the one thing sized for a 30ft read
        mf = _fit_clip(c, mag, ["16x20", "10x16"], MAIN_W)
        c.text(mf[1], MAIN_X, HERO_Y, font = mf[0], color = col)

        # meta column: the distance is the app's thesis, so it keeps its own
        # column and its own unit label rather than sharing the hero row.
        uw = c.text_width(UNIT, UNIT_FONT)
        num_right = RIGHT - uw - 2                  # 175 -> number ends at 174
        df = _fit_clip(c, dist, DIST_FONTS, num_right - META_X)
        c.text(df[1], num_right, DIST_Y, font = df[0], color = COL_VALUE,
               align = "right")
        c.text(UNIT, RIGHT, DIST_Y + INK_BOT[df[0]] - (UNIT_INK - 1),
               font = UNIT_FONT, color = COL_LABEL, align = "right")

        # ...and directly under it, where it is measured FROM: a distance with
        # no origin is a magic number.
        c.text(clip_dots(c, g[2], UNIT_FONT, RIGHT - META_X), RIGHT, TOWN_Y,
               font = UNIT_FONT, color = COL_LABEL, align = "right")

        # footer: right side measured first, then the place clipped into the
        # rest, so a long USGS description can never reach the time.
        tw = c.text_width(when, "5x7")
        c.text(when, RIGHT, FOOT_Y, font = "5x7", color = COL_LABEL,
               align = "right")
        c.text(clip_dots(c, place, "5x7", RIGHT - tw - FOOT_GAP - ART_X),
               ART_X, FOOT_Y,
               font = "5x7", color = COL_PLACE)
    else:
        c.image("CRACKED.png", 1, c.height - 16, w = 16, h = 12)
        c.text_fit(mag, c.width - 2, 2, ["16x20", "10x16"], color = col,
                   align = "right", maxw = c.width - 20)
        c.text_fit(str(int(bestd)) + "MI " + when, c.width - 2, 25,
                   ["4x5", "3x4"], color = COL_PLACE, align = "right",
                   maxw = c.width - 20)
