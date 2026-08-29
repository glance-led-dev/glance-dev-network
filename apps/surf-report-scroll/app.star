# Surf Report
#
# DESIGN. Three bands on a black ground, no gradient: an identity block on the
# left (a "SURF" title over a baked barrelling-wave sprite), the hero wave
# height in the middle, and a stack of secondary readings down the right edge.
#
# Period matters as much as height -- a four foot swell at fourteen seconds is
# a different ocean from four foot at six -- so both get equal billing, and the
# verdict weighs them together rather than ranking on height alone.
#
# The unit is not part of the hero any more: "FT" rides as two tiny 4x5 letters
# stacked against the right edge of the number, so the digits themselves get
# every pixel of the font ladder ("4.1FT" at 16x24 is 117px; "4.1" alone fits
# 19x28 in the same slot). Period and swell direction each carry their own
# pixel-art label -- a clock face and a compass arrow -- so neither number is a
# magic number, and the arrow can never disagree with the letters beside it
# because both come out of compass().


PAD = 10                      # scroll safe zone: content lives in x 10..181
GAP = 5                       # gap between the three bands
ICON = 7                      # every inline sprite is 7x7
ICON_GAP = 2                  # sprite -> its number
PAIR_GAP = 5                  # period pair -> direction pair
UNIT_GAP = 2                  # hero digits -> stacked unit letters
UNIT_H = 5                    # 4x5 ink height (the font reserves a 6th row)
TOWN_MAX = 62                 # 4x5 town clip; keeps the right column off the hero
PERIOD_MAX = 23               # 5x7 period clip ("14S" is 17px)

# Starlark has no font-metrics call, so the ink heights travel with the ladder.
# _fit_clip only ever picks on width, so each ladder is pre-trimmed to fonts
# whose ink also fits its band: 19x28 in the 32px wide hero, 10x16 in the 18px
# band a 64 panel has left between the title row and the swell row.
HERO_FONTS = ["19x28", "16x24", "16x20", "10x16"]
NARROW_HERO_FONTS = ["10x16", "6x8"]
HERO_INK = {"19x28": 28, "16x24": 24, "16x20": 20, "10x16": 15, "6x8": 8}

SEA = "#0F4A85"
BODY = "#1B6FB8"
MID = "#3FA0E0"
CREST = "#9BDDFF"
FOAM = "#FFFFFF"
TITLE_COL = "#BFE4FF"
HERO_COL = "#FFFFFF"
UNIT_COL = "#79BDE8"
TOWN_COL = "#7AA4C4"
ICON_COL = "#4E9BD8"
VALUE_COL = "#DCF0FF"

# A wave mid-barrel: spray off the lip, a dark tube punched through the
# shoulder, and two rows of flat water underneath to stand it on.
WAVE_ART = """
.......W..................
......W...W...............
.............W............
......WWWW................
.....WCCCCWW....W.........
.....CLLLLCCWW............
....WLBBBBLLCCWW..........
....CBBBBBBBLLCCW.........
...WLBD....BBBLLCW........
...CBD......BBBBLCW.......
...LBD......DDBBBLCW......
...BDD......DDDDBBLCW.....
...BDDD....DDDDDDBBLCW....
....DDDDDDDDDDDDDDBBLCW...
....DDDDDDDDDDDDDDDBBLCW..
....DDDDDDDDDDDDDDDDBBLCW.
.....DDDDDDDDDDDDDDDDBBLCW
.....DDDDDDDDDDDDDDDDDBBLC
......DDDDDDDDDDDDDDDDDBBL
......DDDDDDDDDDDDDDDDDDBB
.......DDDDDDDDDDDDDDDDDDB
LLCCLLLLLLLLCCLLLLLLCCLLLL
.BBBBBBBBBBBBBBBBBBBBBBBB.
..DDDDDDDDDDDDDDDDDDDDDD..
"""
WAVE_W = 26
WAVE_H = 24
WAVE_LEGEND = {"W": FOAM, "C": CREST, "L": MID, "B": BODY, "D": SEA}

# Period label: a clock face. Direction label: an arrow, drawn once pointing
# north and rotated for the other seven octants so all eight are the same shape.
CLOCK_ART = [
    "..###..",
    ".#...#.",
    "#..#..#",
    "#..##.#",
    "#.....#",
    ".#...#.",
    "..###..",
]
ARROW_N = [
    "...#...",
    "..###..",
    ".#####.",
    "#######",
    "..###..",
    "..###..",
    "..###..",
]
ARROW_NE = [
    "..#####",
    "...####",
    "....###",
    "...#.##",
    "..##..#",
    ".##....",
    "##.....",
]


def rot90(rows):
    """Rotate square string-art a quarter turn clockwise."""
    n = len(rows)
    out = []
    for r in range(n):
        line = ""
        for k in range(n):
            line += rows[n - 1 - k][r]
        out.append(line)
    return out


ARROW_E = rot90(ARROW_N)
ARROW_S = rot90(ARROW_E)
ARROW_W = rot90(ARROW_S)
ARROW_SE = rot90(ARROW_NE)
ARROW_SW = rot90(ARROW_SE)
ARROW_NW = rot90(ARROW_SW)
ARROWS = {"N": ARROW_N, "NE": ARROW_NE, "E": ARROW_E, "SE": ARROW_SE,
          "S": ARROW_S, "SW": ARROW_SW, "W": ARROW_W, "NW": ARROW_NW}


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


def swell_row(c, x, y, per, way):
    """[clock][period] [arrow][direction], left to right from x. 7px tall, the
    height of its sprites, so it can sit flush on the bottom edge."""
    pw = c.text_width(per, "5x7")
    c.sprite(CLOCK_ART, x, y, color = ICON_COL)
    c.text(per, x + ICON + ICON_GAP, y, font = "5x7", color = VALUE_COL)
    ax = x + ICON + ICON_GAP + pw + PAIR_GAP
    c.sprite(ARROWS[way], ax, y, color = ICON_COL)
    c.text(way, ax + ICON + ICON_GAP, y, font = "5x7", color = VALUE_COL)


def swell_row_w(c, per, way):
    return (ICON + ICON_GAP + c.text_width(per, "5x7") + PAIR_GAP +
            ICON + ICON_GAP + c.text_width(way, "5x7"))


def hero(c, num, unit, fonts, x, avail, y0, y1):
    """The wave height, as big as `avail` allows, with the unit stacked in 4x5
    against the digits' right edge. Centres itself in `avail` and in y0..y1.

    The unit column is measured, not assumed: "M" and "F"/"T" are all 4px in
    4x5, but taking the max keeps the group width honest if that ever changes."""
    uw = 0
    for i in range(len(unit)):
        w = c.text_width(unit[i], "4x5")
        if w > uw:
            uw = w
    fit = _fit_clip(c, num, fonts, avail - UNIT_GAP - uw)
    font = fit[0]
    txt = fit[1]
    nw = c.text_width(txt, font)
    ink = HERO_INK[font]
    nx = x + (avail - (nw + UNIT_GAP + uw)) // 2
    ny = y0 + (y1 - y0 + 1 - ink) // 2
    c.text(txt, nx, ny, font = font, color = HERO_COL)
    stack = len(unit) * UNIT_H + (len(unit) - 1)
    uy = ny + (ink - stack) // 2
    for i in range(len(unit)):
        c.text(unit[i], nx + nw + UNIT_GAP, uy + i * (UNIT_H + 1),
               font = "4x5", color = UNIT_COL)


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

    num = str(int(height * 10) / 10.0)
    per = clip(c, str(int(period)) + "S", "5x7", PERIOD_MAX)
    way = compass(deg)

    c.fill("#000000")

    if c.width >= 128:
        # Right column, right-aligned on x=182 so its last lit pixel is 181 and
        # the app keeps 10px of air at both edges. Bands 0-4 / 7-21 / 25-31 can
        # never touch: 4x5 inks 5 rows, 10x16 inks 15, and the swell row is
        # exactly as tall as its 7px sprites.
        right = c.width - PAD
        town = clip(c, g[2], "4x5", TOWN_MAX)
        sw = swell_row_w(c, per, way)
        rw = c.text_width(v[0], "10x16")
        if c.text_width(town, "4x5") > rw:
            rw = c.text_width(town, "4x5")
        if sw > rw:
            rw = sw

        c.text(town, right, 0, font = "4x5", color = TOWN_COL, align = "right")
        c.text(v[0], right, 7, font = "10x16", color = v[1], align = "right")
        swell_row(c, right - sw, c.height - ICON, per, way)

        # Identity block: title over art, both inside the left padding. The
        # title inks rows 1-5 and the art's highest spray pixel lands on row 8.
        c.text("SURF", PAD + (WAVE_W - c.text_width("SURF", "4x5")) // 2, 1,
               font = "4x5", color = TITLE_COL)
        c.sprite(WAVE_ART, PAD, c.height - WAVE_H, legend = WAVE_LEGEND)

        hx = PAD + WAVE_W + GAP
        hero(c, num, unit, HERO_FONTS, hx, right - rw - GAP - hx, 0,
             c.height - 1)
    else:
        # 64px: the wave art and the 10x16 verdict are dropped rather than
        # squeezed; the title still identifies the app, and every number keeps
        # its label. Bands: 1-5 title/verdict | 6-23 hero | 25-31 swell row.
        c.text("SURF", 2, 1, font = "4x5", color = TITLE_COL)
        c.text(v[0], c.width - 2, 1, font = "4x5", color = v[1],
               align = "right")
        hero(c, num, unit, NARROW_HERO_FONTS, 2, c.width - 4, 6, 23)
        swell_row(c, (c.width - swell_row_w(c, per, way)) // 2,
                  c.height - ICON, per, way)
