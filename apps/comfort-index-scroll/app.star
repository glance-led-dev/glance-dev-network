# Feels Like
#
# DESIGN. Black ground, three vertical slabs. Far left, a hand-baked
# thermometer whose mercury column rises with the apparent temperature and
# wears the mugginess band color, with two water drops beside it -- the art
# is the label, so the panel never has to spell out "HUMIDITY" or
# "TEMPERATURE". Middle slab: the city, then the one word that answers the
# question the app exists to answer (DRY .. OPPRESSIVE), in the same color as
# the mercury so the picture and the word can never disagree. Right slab: the
# FEELS LIKE label over the hero number. That slab tracks the text slab rather
# than the panel edge -- it sits exactly GAP (6px) past the text's widest lit
# column, and only when the text is long enough does it reach its stop, flush
# with the right margin. The left edge keeps EDGE (6px) of clear panel so the
# app reads as its own unit in the scroll sequence instead of merging with its
# neighbors.
#
# Apparent temperature is the number worth showing, but on its own it explains
# nothing. Dew point is what people feel as mugginess -- above about 65F it is
# genuinely unpleasant regardless of what the thermometer says -- so it gets
# named alongside.


# --- layout constants ------------------------------------------------------
# EDGE is the owner's spec: 6 clear pixels at BOTH ends of the strip before any
# content begins, so nothing here may draw at x < 6 or x > c.width - 7.
EDGE = 6

THERMO_W = 9          # glass sprite footprint (cols 0-8, ticks included)
THERMO_H = 24
DROPS_W = 7
DROPS_H = 18
ART_GAP = 2           # glass -> drops
COL_GAP = 4           # art block -> text column
GAP = 6               # text slab -> hero slab, measured lit pixel to lit pixel

# Vertical bands, wide. No band shares a row with another:
#   1-5   eyebrows (city left, FEELS LIKE right)   4x5
#   8-23  mugginess word (left) / 8-27 hero temp (right)
#   26-30 footnote (left of the hero only)
ROW_EYE = 1
ROW_BAND = 8
BAND_H = 16
ROW_FOOT = 26
ART_Y = 4             # thermometer rows 4-27: its bulb bottoms out level with
                      # the hero's last row, which is what ties the two slabs.

FONTH = {"16x20": 20, "10x16": 16, "8x12": 12, "7x10": 10, "6x8": 8,
         "5x7": 7, "4x5": 5, "3x4": 4}

# Dark columns at the right edge of a glyph's cell. text_width returns the cell
# advance, so a line ending in T, I or 1 measures 1px wider than its last lit
# column -- which would show up as a 7px gap where the design asks for 6.
TRIM = {
    "4x5": {"!": 2, "I": 1, "T": 1, "1": 1, ":": 1, "%": 1, "'": 1, ",": 1,
            "/": 1, "|": 1, "(": 1, ")": 1, ".": 1},
    "6x8": {":": 2, ".": 2, ")": 2, ",": 2, "#": 1, "(": 1, "/": 1},
    "7x10": {":": 3, "!": 3, ".": 2, "-": 1, "I": 1, "T": 1},
    "8x12": {"!": 3, ".": 3, "&": 1, "(": 1, ")": 1, "-": 1, ":": 1},
    "10x16": {",": 4, ":": 4, "!": 3, "*": 3, ".": 3, "+": 1, "-": 1},
}

# --- palette ---------------------------------------------------------------
INK = "#FFFFFF"       # the live number: white is the resting color
UNITINK = "#C6D0E4"   # degree ring + F/C, one step quieter than the number
LABEL = "#6E7A94"     # eyebrows
FOOT = "#7C879E"      # footnote
GLASS = "#98A2B8"
TICK = "#454C5E"
TUBE = "#1B1F29"      # unfilled tube: dark enough to read as empty glass
DROP = "#3A9AE0"
DROPLIT = "#CDE9FF"
DROPDIM = "#2C7AB4"

# --- pixel art -------------------------------------------------------------
# Thermometer glass, 9x24. Interior (cols 3-5, rows 1-14 plus the bulb) is left
# transparent so the mercury can be painted underneath it and show through.
# G = glass, T = graduation tick.
THERMO_GLASS = """
...GGG...
..G...G..
..G...G..
..G...G..
..G...GTT
..G...G..
..G...G..
..G...G..
..G...GTT
..G...G..
..G...G..
..G...G..
..G...GTT
..G...G..
..G...G..
..G...G..
.G.....G.
G.......G
G.......G
G.......G
G.......G
G.......G
.G.....G.
..GGGGG..
"""

# Bulb interior, drawn at ART_Y + 15. Always full -- a thermometer with an
# empty bulb reads as broken, not as cold.
THERMO_BULB = """
...MMM...
..MMMMM..
.MMMMMMM.
.MMMMMMM.
.MMMMMMM.
.MMMMMMM.
.MMMMMMM.
..MMMMM..
"""

# Water drops, 7x18. Says "humidity" without the word. The highlight is a 1px
# column on the upper-left of the belly, not a blob in the middle -- centred,
# it read as a hole punched through the drop.
DROPS = """
...D...
...D...
..DDD..
..DDD..
.DDDDD.
.HDDDD.
DHDDDDD
DDDDDDD
DDDDDDD
.DDDDD.
..DDD..
.......
.......
...e...
..eee..
.eeeee.
.eeeee.
..eee..
"""

# Degree marks. None of the bitmap fonts carry a U+00B0 glyph -- a literal "°"
# in a string measures 0px wide and draws nothing at all, so the temperature
# silently rendered as a bare number. These are the rings, sized to the font
# they sit beside.
DEG4 = """
.##.
#..#
#..#
.##.
"""
DEG3 = """
.#.
#.#
.#.
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


def _fit_place(c, text, font, maxw):
    """A place name clipped at a word boundary when the tail that goes is worth
    less than a third of the string, and hard-clipped when it is not.

    Zippopotam returns whatever the USPS has on file: "KING AND QUEEN COURT
    HOUSE" is 118px at 4x5, and the raw character cut left "KING AND QUEEN
    COURT HO" hanging mid-word next to the FEELS LIKE label."""
    if c.text_width(text, font) <= maxw:
        return text
    words = text.split(" ")
    for n in range(len(words) - 1, 0, -1):
        head = " ".join(words[:n])
        if c.text_width(head, font) <= maxw and len(head) * 3 >= len(text) * 2:
            return head
    t = text
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def lit_width(c, text, font):
    """Columns from a line's first lit pixel to its last.

    Not the same as text_width: a clipped string can end in a space, which
    measures 5px of nothing at 4x5, and several glyphs leave their last cell
    column dark. The slab gap is measured off lit pixels, so either would
    quietly widen it past the 6px the design calls for."""
    t = text.rstrip(" ")
    if t == "":
        return 0
    w = c.text_width(t, font)
    trim = TRIM.get(font, {})
    last = t[len(t) - 1]
    if last in trim:
        w = w - trim[last]
    if w < 0:
        return 0
    return w


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
    c.fill("#0B0C12")
    maxw = c.width - 2 * EDGE if c.width >= 128 else c.width - 6
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
    """[word, color] banded off the dew point, from one place, so the mercury,
    the word and its color can never disagree."""
    if dewf < 50:
        return ["DRY", "#7FB6E8"]
    if dewf < 60:
        return ["PLEASANT", "#4EE38A"]
    if dewf < 65:
        return ["STICKY", "#F5D64E"]
    if dewf < 70:
        return ["MUGGY", "#FF9A4A"]
    return ["OPPRESSIVE", "#FF5B5B"]


def mercury_level(appf):
    """Filled height, 0-14, of the tube's 14 interior rows (rows 1-14 of the
    glass). -20F sits at the bulb, 110F at the cap; outside that the column
    pins rather than drawing past the glass."""
    lvl = (int(appf) + 20) * 14 // 130
    if lvl < 0:
        lvl = 0
    if lvl > 14:
        lvl = 14
    return lvl


def thermometer(c, x, y, appf, color):
    """Glass + mercury at (x, y), 9x24. Mercury is painted first and the glass
    over it, so the column can never spill past the wall it is drawn inside."""
    lvl = mercury_level(appf)
    c.rect(x + 3, y + 1, x + 5, y + 14, fill = TUBE)
    if lvl > 0:
        c.rect(x + 3, y + 15 - lvl, x + 5, y + 14, fill = color)
    c.sprite(THERMO_BULB, x, y + 15, color = color)
    c.sprite(THERMO_GLASS, x, y, legend = {"G": GLASS, "T": TICK})


def draw_temp_wide(c, x, y, val, unit, color, ring):
    """`83` in 16x20 with the degree ring stacked over the unit letter to its
    right -- reads as 83degF while costing 8px of tail instead of 13. Draws
    nothing measured on the fly: `temp_width_wide` computes the same total up
    front so the whole group can be right-aligned before the first pixel."""
    s = str(int(val))
    w = c.text_width(s, "16x20")
    c.text(s, x, y, font = "16x20", color = color)
    c.sprite(DEG4, x + w + 2, y + 1, color = ring)
    c.text(unit, x + w + 2, y + FONTH["16x20"] - FONTH["6x8"], font = "6x8",
           color = ring)


def temp_width_wide(c, val, unit):
    """Total px of the hero group: digits + 2px gap + the wider of the 4px
    degree ring and the unit letter stacked under it."""
    tail = 4                                  # the degree ring
    uw = c.text_width(unit, "6x8")
    if uw > tail:
        tail = uw
    return c.text_width(str(int(val)), "16x20") + 2 + tail


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
    # The bands and the mercury scale are both Fahrenheit, so METRIC converts
    # for the thresholds and keeps Celsius only for what is printed.
    dewf = dew if not metric else dew * 9 / 5 + 32
    appf = app if not metric else app * 9 / 5 + 32
    m = mugginess(dewf)

    diff = app - real
    if diff >= 1:
        gap = "+" + str(int(diff)) + " WARMER"
    elif diff <= -1:
        gap = str(int(diff)) + " COLDER"
    else:
        gap = "AS IT LOOKS"

    c.fill("black")
    unit = "C" if metric else "F"
    # A location app always names its location: when the geocoder hands back a
    # blank place name, the zip the user typed is the location.
    city = g[2]
    if city == "":
        city = str(ctx.inputs.get("zip", "")).strip()

    if c.width >= 128:
        # Slabs: art 6-23 | text column 28.. | hero right-aligned to width-7.
        ax = EDGE
        dx = ax + THERMO_W + ART_GAP
        col = dx + DROPS_W + COL_GAP
        right = c.width - 1 - EDGE

        thermometer(c, ax, ART_Y, appf, m[1])
        # (24 - 18) // 2 = 3: the drops sit centred against the glass, rows
        # 7-24, so neither art can reach the other's rows or the text column.
        c.sprite(DROPS, dx, ART_Y + (THERMO_H - DROPS_H) // 2,
                 legend = {"D": DROP, "H": DROPLIT, "e": DROPDIM})

        # The right slab is one block -- FEELS LIKE over the hero -- as wide as
        # whichever of the two is wider, and MAXX (flush with the right margin)
        # is as far right as that block may ever sit. Both halves of the layout
        # are measured, never assumed: the hero is 41px on "85F" and 75px on
        # "-100F", and the label is 47px, so which one sets the block width
        # changes with the reading.
        lab = "FEELS LIKE"
        tgrp = temp_width_wide(c, app, unit)
        rw = c.text_width(lab, "4x5")
        if tgrp > rw:
            rw = tgrp
        maxx = right + 1 - rw

        # Every left-hand line is clipped to what still leaves GAP clear of
        # MAXX. Nothing on the left can push the hero past its stop, so a place
        # name loses its tail rather than the two slabs ever touching.
        room = maxx - GAP - col

        cf = _fit_place(c, city, "4x5", room)
        wf = _fit_clip(c, m[0], ["10x16", "8x12", "7x10", "6x8"], room)
        foot = gap + "   " + str(int(rh)) + "% RH"
        ff = _fit_clip(c, foot, ["4x5"], room)

        # The left slab is only as wide as its own widest lit column -- the
        # rating word, usually -- and the hero closes up to exactly GAP behind
        # it. Right-aligning the hero to the margin instead stranded 31px of
        # black between PLEASANT and the number on short place names.
        lw = lit_width(c, cf, "4x5")
        ww = lit_width(c, wf[1], wf[0])
        if ww > lw:
            lw = ww
        fw = lit_width(c, ff[1], "4x5")
        if fw > lw:
            lw = fw

        rx = maxx
        if lw > 0 and col + lw + GAP < maxx:
            rx = col + lw + GAP
        redge = rx + rw - 1

        draw_temp_wide(c, redge + 1 - tgrp, ROW_BAND, app, unit, INK, UNITINK)
        c.text(lab, redge + 1 - c.text_width(lab, "4x5"), ROW_EYE,
               font = "4x5", color = LABEL)

        c.text(cf, col, ROW_EYE, font = "4x5", color = LABEL)
        c.text(wf[1], col, ROW_BAND + (BAND_H - FONTH[wf[0]]) // 2,
               font = wf[0], color = m[1])
        c.text(ff[1], col, ROW_FOOT, font = "4x5", color = FOOT)
    else:
        # 64px: maximize the space. Thermometer hard left at x=1, city across
        # the top strip, hero right-aligned, word on the last row.
        # city 0-4 | temp 6-25 | word 27-31: no row is shared, and the art
        # (rows 6-29, cols 1-9) sits left of every one of them.
        thermometer(c, 1, 6, appf, m[1])
        if city != "":
            # 4x5 only, no 3x4 rung: 3x4 has no space glyph, so it turned
            # "KING AND QUEEN COURT HOUSE" into KINGANDQUEENCOURTHOUSE.
            cf = _fit_place(c, city, "4x5", c.width - 2)
            c.text(cf, c.width // 2, 0, font = "4x5", color = LABEL,
                   align = "center")
        # Ring only, no F/C: at 64px the letter would force the number down to
        # a smaller font, and the units setting is the user's own choice anyway.
        # 13px of the strip belongs to the art plus its buffer.
        tfont = "16x20"
        s = str(int(app))
        tw = c.text_width(s, tfont)
        if tw + 5 > c.width - 1 - 13:
            tfont = "10x16"
            tw = c.text_width(s, tfont)
        tx = c.width - 1 - (tw + 5)
        ty = 6 + (20 - FONTH[tfont]) // 2
        c.text(s, tx, ty, font = tfont, color = INK)
        c.sprite(DEG3, tx + tw + 2, ty + 1, color = UNITINK)
        wf = _fit_clip(c, m[0], ["4x5", "3x4"], c.width - 1 - 12)
        c.text(wf[1], c.width - 1, 27, font = wf[0], color = m[1],
               align = "right")
