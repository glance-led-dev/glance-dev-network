# Frost Watch
#
# One question, answered plainly: does anything need covering
# tonight? The thresholds are the ones gardeners actually use --
# frost forms around 36F because the air at thermometer height is
# warmer than the ground, and a hard freeze starts at 28F.
#
# DESIGN.
# Black ground, no gradient wash -- on a scroll strip the panel before
# and the panel after are already fighting for the eye, and a tinted
# fill only muddies the ice blues this app is built on.
#
# The app names itself with a nameplate down the far left: F R O S T set
# vertically in 4x5 icy blue between two 1px rails. It occupies x 1..8,
# which is chrome, not content -- content starts at x=15, six clear columns
# right of the rail, and ends at x=181, so the app reads as its own unit
# when a neighbour app is on the glass beside it.
#
# Inside that band, three zones left to right:
#   art    x 15..38  baked sprite: a frost crystal over a seedling. The
#                    leaf-edge pixels are their own legend key, so the
#                    same art grows white rime the moment the low drops
#                    into a frost band -- one glyph, two legends.
#   hero   x 42..    tonight's low at 16x20 with the degree ring + F/C.
#   verdict  ..181   band pill (c.badge) over the advice line, both
#                    right-aligned against x=181 and measured first.
# A 4x5 meta row rides above all three: "LOW TONIGHT" left (the label
# that keeps the big number from being a magic number) and the place
# name right (this is a location app, so the location is on the panel).


ICE = "#7FD4FF"        # nameplate letters + crystal identity
ICE_RAIL = "#2E6E96"   # the two flanking rails: present, but subordinate
RIME = "#DCF0FF"       # frost on the leaves, only in a frost band
META = "#5E7290"       # dim slate for the label
PLACE = "#8FA4C0"      # the place name reads one step brighter than META
ADVICE = "#8FA0BC"

# Nameplate geometry. 4x5 glyph ink is 4 columns wide, so the letters
# light x 3..6; a rail at x=1 and x=8 leaves exactly one dark column on
# each side of the letter column. Five letters of 5 ink rows with 1px
# gaps is 29 rows: they run y 1..29, one dark row above and two below,
# inside rails that run the full 32.
BAR_L = 1
LETTER_X = 3
BAR_R = 8
LETTER_TOP = 1
LETTER_STEP = 6

# The content safe zone: 10px in from both edges of a 192 panel.
PAD = 10

# The nameplate is chrome, so it needs air before the content starts or the
# label reads as a sixth letter hanging off the rail. Six dark columns --
# x 9..14 -- sit between the right rail (lit at x=8) and the first lit
# column of content, which is why content starts at x=15 rather than at PAD.
# The right edge is untouched: everything still ends at x=181.
NAMEPLATE_GAP = 6
CONTENT_X0 = BAR_R + 1 + NAMEPLATE_GAP

FONTH = {"16x20": 20, "10x16": 16, "5x7": 7, "4x5": 5}

# Meta row ink rows 1-5, content band rows 7-31.
META_Y = 1
BAND_Y = 7
GAP = 4                # horizontal breathing room between zones
ART_W = 24             # the baked sprite is 24x24; its soil ends on row 30
PILL_PAD = 3           # c.badge total width = text + 2*pad; 3 keeps the
                       # rounded corner off the first and last glyph column
ADVICE_BOT = 30        # last row the advice may light: the art's soil ends
                       # on row 30 too, so the two zones share a baseline
HERO_RING = 1          # degree ring radius. r=2 was tried under the 20px
                       # hero and read as a letter: "63" + a 5x5 ring + "F"
                       # came out looking like "63OF" at a glance.
# "HARD FREEZE" is the longest band word: 52px at 4x5 (58 as a pill) and
# 65px at 5x7 (71 as a pill). The hero keeps its 16x20 only while the
# verdict column still has room for the small pill plus a margin.
MIN_VERDICT_W = 66


# A frost crystal (8 arms, white core), a smaller one beside it, and a
# two-leaf seedling in soil. 'r' is the leaf's exposed top edge: green on
# a mild night, rime white once the low reaches a frost band.
ART = """
......B.................
..B...B...B.............
...B..B..B..............
....B.B.B........B.B.B..
.....BWB..........BBB...
.BBBBWWWBBBB.....BBWBB..
.....BWB..........BBB...
....B.B.B........B.B.B..
...B..B..B..............
..B...B...B.............
......B.................
...................rr...
.................rrGGg..
...............rrGGGGg..
............grrGGGGgg...
...rr.......gGGGgg......
..grrGG.....g...........
..grGGGGG...g...........
....ggGGGGGGg...........
............g...........
............g...........
............g...........
......EEEEEEEEEEEE......
....EEEEEEEEEEEEEEEE....
"""

# The 64 build gets the same scene at 16x16: one crystal, one sprout.
ART_NARROW = """
....B...........
.B..B..B........
..B.B.B.........
.BBBWBBB........
..B.B.B.........
.B..B..B........
....B...........
................
...........rrG..
.......g.rrGGg..
.......grrGGg...
..rr...g........
.grrGGGg........
...ggGGg........
..EEEEEEEEEEE...
.EEEEEEEEEEEEE..
"""


def art_legend(frosty):
    """The one legend swap that carries state into the art."""
    return {
        "B": ICE,
        "W": "#EAF7FF",
        "G": "#27C46B",
        "g": "#127A42",
        "E": "#5A3B22",
        "r": RIME if frosty else "#27C46B",
    }


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


def degree_mark(c, x, y, color, r):
    """Draw the degree ring, top-left of its box at (x, y). None of the bitmap
    fonts carry a U+00B0 glyph, so a literal "°" in a string measures 0px wide
    and draws nothing at all -- the temperature silently rendered as a bare
    number. r=1 gives the 3x3 ring that reads as a degree at LED scale."""
    c.circle(x + r, y + r, r, color)


def temp_group_width(c, s, font, unit, r):
    w = c.text_width(s, font) + 1 + (2 * r + 1)
    if unit != "":
        w = w + 2 + c.text_width(unit, "5x7")
    return w


def draw_temp(c, x, y, s, font, color, unit, r):
    """Temperature + degree ring, drawn left-to-right from x. `unit` adds the
    F/C letter after the ring; pass "" on narrow panels, where the ring alone
    keeps the number in the big font. Returns the width drawn."""
    w = c.text_width(s, font)
    c.text(s, x, y, font = font, color = color)
    degree_mark(c, x + w + 1, y + 1, color, r)
    if unit != "":
        c.text(unit, x + w + 2 * r + 4, y + 1, font = "5x7", color = color)
    return temp_group_width(c, s, font, unit, r)


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


def clip_dots(c, text, font, maxw):
    """Fit `text` to maxw, ending in ".." when anything was cut.

    Place names arrive from the geocoder with no length bound at all --
    "CHARLOTTE COURT HOUSE" is a real one -- so a bare character clip
    leaves a word looking half-rendered. The two dots say it was cut."""
    if c.text_width(text, font) <= maxw:
        return text
    room = maxw - c.text_width("..", font)
    if room <= 0:
        return _fit_clip(c, text, [font], maxw)[1]
    # rstrip: a cut that lands after a word left "COURT HOUSE .." with the
    # space still in it, which reads as a gap rather than a truncation.
    return _fit_clip(c, text, [font], room)[1].rstrip() + ".."


def wrap_lines(c, text, font, maxw, maxlines):
    """Greedy word wrap, hard-clipped, never more than `maxlines` lines.

    The advice strings are the widest thing on the right of the panel:
    "COVER TENDER PLANTS" is 90px at 4x5, and the room left of x=181
    shrinks as the hero number gets more digits. Wrapping is what keeps
    the string on the panel instead of clipping a word off the edge. When
    the block does drop a line the last one ends in ".." so the cut reads
    as deliberate rather than as a rendering fault."""
    lines = []
    cur = ""
    for w in text.split(" "):
        t = w if cur == "" else cur + " " + w
        if c.text_width(t, font) <= maxw:
            cur = t
        elif cur == "":
            lines.append(_fit_clip(c, w, [font], maxw)[1])
        else:
            lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    out = []
    for i in range(len(lines)):
        if len(out) < maxlines:
            out.append(_fit_clip(c, lines[i], [font], maxw)[1])
    if len(lines) > maxlines and len(out) > 0:
        last = len(out) - 1
        out[last] = clip_dots(c, out[last] + " " + lines[maxlines], font, maxw)
    return out


def nameplate(c):
    """F R O S T down the left edge between two rails.

    This is the app's context switch: the data alone (a number and a
    colour) never says "frost tracker", and on a shared scroll stream the
    viewer needs to know what they are looking at before they read it."""
    c.vline(BAR_L, 0, c.height, ICE_RAIL)
    c.vline(BAR_R, 0, c.height, ICE_RAIL)
    y = LETTER_TOP
    for ch in ["F", "R", "O", "S", "T"]:
        c.text(ch, LETTER_X, y, font = "4x5", color = ICE)
        y = y + LETTER_STEP


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands -- a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#000000")
    if c.width >= 128:
        nameplate(c)
        # Centred on the content zone, not on the panel: the nameplate
        # owns x 1..8 plus its 6px of air, so the panel's own midpoint is
        # off-centre here.
        x0 = CONTENT_X0
        x1 = c.width - 1 - PAD
        mid = (x0 + x1) // 2
        maxw = x1 - x0 + 1
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], mid, 4, font = t[0], color = "#E8B04A", align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], mid, 22, font = d[0], color = "#6A7090", align = "center")
    else:
        maxw = c.width - 6
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


def band(f):
    """Thresholds in Fahrenheit, the units the advice is written in."""
    if f <= 28:
        return ["HARD FREEZE", "#8FD4FF", "COVER EVERYTHING"]
    if f <= 32:
        return ["FREEZE", "#BFE6FF", "COVER TENDER PLANTS"]
    if f <= 36:
        return ["FROST RISK", "#DCF0FF", "COVER IF IN DOUBT"]
    if f <= 45:
        return ["CHILLY", "#8FE3B0", "NOTHING TO DO"]
    return ["MILD", "#6FE38A", "NOTHING TO DO"]


def draw_wide(c, shown, unit, b, city, frosty):
    """192-wide layout. Every x below is derived from the bounds or measured."""
    x0 = CONTENT_X0               # 15: first content column, 6px off the rail
    x1 = c.width - 1 - PAD        # 181: last content column

    # --- meta row (4x5, rows 1-5) -----------------------------------------
    label = "LOW TONIGHT"
    c.text(label, x0, META_Y, font = "4x5", color = META)
    place_x0 = x0 + c.text_width(label, "4x5") + GAP
    if city != "" and place_x0 < x1:
        p = clip_dots(c, city, "4x5", x1 - place_x0 + 1)
        c.text(p, x1, META_Y, font = "4x5", color = PLACE, align = "right")

    # --- art (rows 7-30) ---------------------------------------------------
    c.sprite(ART, x0, BAND_Y, legend = art_legend(frosty))

    # --- hero: 16x20 unless the verdict column would be squeezed ----------
    hero_x = x0 + ART_W + 3       # 3px of dark between art and the number
    tfont = "16x20"
    gw = temp_group_width(c, shown, tfont, unit, HERO_RING)
    if x1 - (hero_x + gw + GAP) + 1 < MIN_VERDICT_W:
        # A four-character low ("-105", or a metric "-40" plus the C) at
        # 16x20 leaves 63px right of it -- less than the 71px "HARD FREEZE"
        # needs as a pill, so the hero steps down instead of the word.
        tfont = "10x16"
        gw = temp_group_width(c, shown, tfont, unit, HERO_RING)
    band_h = c.height - BAND_Y
    hero_y = BAND_Y + (band_h - FONTH[tfont]) // 2
    draw_temp(c, hero_x, hero_y, shown, tfont, b[1], unit, HERO_RING)

    # --- verdict column: state pill on top, advice on the last rows -------
    # Both are right-aligned against x1 and measured before they are drawn;
    # the column's left bound is whatever the hero left over.
    vx0 = hero_x + gw + GAP
    vw = x1 - vx0 + 1
    if vw < 20:
        return

    pfont = "4x5"
    for f in ["5x7", "4x5"]:
        if c.text_width(b[0], f) + 2 * PILL_PAD <= vw:
            pfont = f
            break
    word = _fit_clip(c, b[0], [pfont], vw - 2 * PILL_PAD)
    pill_w = c.text_width(word[1], pfont) + 2 * PILL_PAD
    c.badge(word[1], x1 - pill_w + 1, hero_y, color = "black", bg = b[1],
            font = pfont, pad = PILL_PAD)
    pill_bot = hero_y + FONTH[pfont] + 1     # ink rows + 1px of pill each side

    # The advice sits on the panel's last usable row, level with the soil
    # under the art, and takes the biggest font whose wrapped block still
    # clears the pill by 2px.
    afont = "4x5"
    alines = []
    for f in ["5x7", "4x5"]:
        cand = wrap_lines(c, b[2], f, vw, 2)
        top = ADVICE_BOT - (len(cand) * FONTH[f] + len(cand) - 1) + 1
        if top >= pill_bot + 2:
            afont = f
            alines = cand
            break
    if len(alines) == 0:
        alines = wrap_lines(c, b[2], "4x5", vw, 1)
    ay = ADVICE_BOT - (len(alines) * FONTH[afont] + len(alines) - 1) + 1
    for i in range(len(alines)):
        c.text(alines[i], x1, ay + i * (FONTH[afont] + 1), font = afont,
               color = ADVICE, align = "right")


def draw_narrow(c, shown, b, city, frosty):
    """64-wide layout: art left, number right, band word on the last rows.

    No nameplate here -- 8 columns of 64 is an eighth of the panel, and the
    64 rule is to maximise the space, not to frame it.
    """
    c.sprite(ART_NARROW, 0, 8, legend = art_legend(frosty))
    if city != "":
        cf = clip_dots(c, city, "4x5", c.width - 2)
        c.text(cf, c.width // 2, 0, font = "4x5", color = META,
               align = "center")
    tfont = "16x20"
    if temp_group_width(c, shown, tfont, "", 1) > c.width - 22:
        tfont = "10x16"
    tw = temp_group_width(c, shown, tfont, "", 1)
    draw_temp(c, c.width - 2 - tw, 6, shown, tfont, b[1], "", 1)
    # 4x5 only, and against the full width. 3x4 has no space glyph, so
    # "HARD FREEZE" came out as "HARDFREEZE" -- and it was reaching that
    # fallback needlessly: maxw was width-20, leaving 44px, but the 20px
    # reserve is for the art and the art ends at row 23. Nothing else is
    # on rows 27-31, so the band word can have the panel. At width-4 it
    # gets 60px, and the longest word is 52px at 4x5.
    c.text_fit(b[0], c.width - 2, 27, ["4x5"], color = b[1],
               align = "right", maxw = c.width - 4)


def tonight(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "temperature_2m_min",
                           "temperature_unit": "fahrenheit",
                           "timezone": "auto", "forecast_days": "2"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "NO CONNECTION")
        return
    lows = r["json"].get("daily", {}).get("temperature_2m_min", [])
    if len(lows) == 0 or lows[0] == None:
        nodata(c, "NO FORECAST", "EMPTY FEED")
        return

    f = float(lows[0])
    b = band(f)
    metric = str(ctx.inputs.get("units", "IMPERIAL")).upper() == "METRIC"
    shown = str(int((f - 32) * 5 / 9)) if metric else str(int(f))

    # Black ground. The old vertical gradient tinted every ice blue on the
    # panel and bled into whatever app played next in the sequence.
    c.fill("#000000")

    frosty = f <= 36
    if c.width >= 128:
        nameplate(c)
        draw_wide(c, shown, "C" if metric else "F", b, g[2], frosty)
    else:
        draw_narrow(c, shown, b, g[2], frosty)
