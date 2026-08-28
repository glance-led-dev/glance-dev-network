# Hurricane Tracker (Scroll)
#
# DESIGN. Black ground, one 120px cyclone watermark bled off the top and the
# bottom of the strip, and the storm itself read as two rows of stroked type
# held inside a 6px safe zone on both edges. The watermark is the app's
# identity at a glance -- you know it is the hurricane app before you read a
# word -- and it wears the storm's own category color, so the panel's mood
# tracks the storm without shouting. Nothing is flush to the edge: the strip
# has to read as its own unit with neighbour apps playing either side of it.
#
# The National Hurricane Center's live storm list. Most of the year it is
# empty, and that is the answer people want -- so the quiet state is a
# deliberate all-clear rather than a blank panel.
#
# Category comes from the Saffir-Simpson thresholds applied to the intensity
# in knots, which is what the feed actually carries.


# --- layout constants ------------------------------------------------------
# Scroll safe zone: 6px clear at both edges (guidelines allow 6-10). Every
# edge-adjacent draw is measured against these, never hand-placed, because the
# renderer clips silently and a clipped glyph looks like a font bug.
PAD = 6
ICON_GAP = 2          # icon to text: the 1px stroke halo, then 1px clear
GAP = 3               # between two measured blocks on the same row
STROKE = 1            # text_stroke halo, 1px on every side of the glyph box

# Row bands. Text is vertically centred inside its band by measured font
# height, so a name that drops from 10x16 to 6x8 stays on the row's axis
# instead of sticking to the top of it.
TOP_Y, TOP_H = 2, 18  # y 2..19 (with the halo)
BOT_Y, BOT_H = 21, 10 # y 21..30 - one blank row between the two bands

CAT_MAXW = 72         # see storms()

# Starlark has no font metrics call, so the heights used here are carried.
FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}

NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]

BG = "black"          # the flat ground - cheapest high contrast there is
CLEAR = "#4EE38A"     # all-clear green, also the watermark tint when calm

# --- the watermark ---------------------------------------------------------
# The standard meteorological cyclone symbol: eyed disc, two trailing arms.
# Baked at 40x40 and drawn at scale 3 = 120px wide, which is wider than the
# panel is tall, so the top and bottom of the disc run off the canvas on
# purpose (the renderer clips them silently, which is the effect we want).
GHOST_SCALE = 3       # 40 * 3 = 120px on scroll
GHOST_SCALE_N = 2     # 40 * 2 = 80px on a 64 panel
GHOST_ART_W = 40

# The renderer has no alpha channel, so "low opacity" is drawn as a dark
# variant of the accent over black - on a black ground color.dim(col, pct) is
# arithmetically the same thing as compositing `col` at pct% opacity.
# 5% was the brief; at 5% a "TROP STORM" cyan lands on (5, 10, 12), which the
# panel's RGB565 quantiser rounds to (0, 8, 8) and a review PNG shows as flat
# black. 10% keeps it a whisper - still darker than any glyph on the panel -
# while surviving the quantiser, so the symbol actually reads.
GHOST_PCT = 10

HURRICANE = """
........................................
........................................
........................................
........................................
........................................
........................................
........................................
........................................
......................#####.............
...................###########..........
.................###############........
................#################.......
...............###################......
...............####################.....
..............######################....
.#............##########......#######...
.##...........#########.........#####...
.##...........##########.........#####..
.###..........#####..###..........####..
.###..........####....###..........###..
..###..........###....####..........###.
..####..........###..#####..........###.
..#####.........##########...........##.
...#####.........#########...........##.
...#######......##########............#.
....######################..............
.....####################...............
......###################...............
.......#################................
........###############.................
..........###########...................
.............#####......................
........................................
........................................
........................................
........................................
........................................
........................................
........................................
........................................
"""


def ghost(c, accent):
    """Draw the cyclone watermark, centred, before any content.

    Expanded as run-length rectangles rather than handed to c.sprite: at
    scale 3 the art is 120x120 and a single bitmap op is capped at 32 rows /
    4096 cells, so one sprite call is rejected outright. Walking the rows also
    lets the two thirds of the disc that fall off the top and the bottom of a
    32px panel cost nothing at all.
    """
    scale = GHOST_SCALE if c.width >= 128 else GHOST_SCALE_N
    w = GHOST_ART_W * scale
    x0 = (c.width - w) // 2
    y0 = (c.height - w) // 2
    col = color.dim(accent, GHOST_PCT)
    rows = HURRICANE.strip().split("\n")
    for ry in range(len(rows)):
        ytop = y0 + ry * scale
        if ytop + scale <= 0 or ytop >= c.height:
            continue
        row = rows[ry]
        start = -1
        for rx in range(len(row) + 1):
            lit = rx < len(row) and row[rx] != "."
            if lit and start < 0:
                start = rx
            if not lit and start >= 0:
                c.rect(x0 + start * scale, ytop,
                       x0 + rx * scale - 1, ytop + scale - 1, fill = col)
                start = -1


def band_y(top, h, font):
    """Top y that centres `font` inside a band `h` px tall starting at `top`."""
    return top + (h - FONTH[font]) // 2


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
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    # The safe zone is a scroll rule; a 64 keeps its old 2px margins so the
    # error copy has every pixel of the panel to fit in.
    edge = PAD if c.width >= 128 else 2
    maxw = c.width - 2 * edge - 2 * STROKE
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text_stroke(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
                      stroke = "black", align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
                      stroke = "black", align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text_stroke(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
                      stroke = "black", align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
                      stroke = "black", align = "center")


def category(kt):
    """Saffir-Simpson from sustained wind in knots.

    [wide label, color, 64 label]. The 64 gets its own wording rather than a
    clipped copy of the wide one: "TROP STORM" is 59px at 5x7 and a 64 panel
    has 45px of room beside the icon, so it would lose its last two letters.
    """
    if kt >= 137:
        return ["CAT 5", "#FF3B6B", "CAT 5"]
    if kt >= 113:
        return ["CAT 4", "#FF5B3B", "CAT 4"]
    if kt >= 96:
        return ["CAT 3", "#FF8A3A", "CAT 3"]
    if kt >= 83:
        return ["CAT 2", "#FFB03A", "CAT 2"]
    if kt >= 64:
        return ["CAT 1", "#F5D64E", "CAT 1"]
    if kt >= 34:
        return ["TROP STORM", "#6FD4FF", "STORM"]
    return ["TROP DEPR", "#8FA8C8", "DEPR"]


def basin_label(s):
    """Short basin tag for the storm.

    The feed does not always carry `basin` - the CurrentStorms.json records
    seen live have no such key at all - and the old code pasted the empty
    string onto the end of the wind readout, which left the right-aligned row
    ending ~20px short of the edge with three dangling spaces. The storm id
    ("ep092026") always carries the basin in its first two characters, so it
    is the reliable source. The tag shares the bottom row with the overflow
    count, and the worst case is real: "200 MPH  C PACIFIC" is 125px at 6x8,
    107px at 5x7, against the 107px left beside a "+9 MORE" - so it lands on
    5x7 exactly, and has 4x5 under it if a wider basin word ever appears.
    """
    b = str(s.get("basin", "")).upper()
    if b == "":
        b = str(s.get("id", "")).upper()[:2]
    if b.startswith("AL") or b.startswith("AT"):
        return "ATLANTIC"
    if b.startswith("EP"):
        return "E PACIFIC"
    if b.startswith("CP"):
        return "C PACIFIC"
    return ""


def storms(c, ctx):
    r = http.get("https://www.nhc.noaa.gov/CurrentStorms.json", ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        # Two short uppercase lines, and the 64 gets its own second line
        # rather than a clipped "NO CONNECTI".
        nodata(c, "NO NHC DATA",
               "NO CONNECTION" if c.width >= 128 else "OFFLINE")
        return

    active = r["json"].get("activeStorms", [])
    n = len(active)

    if n == 0:
        # Empty is not an error: green watermark, green all-clear.
        c.fill(BG)
        ghost(c, CLEAR)
        # Both lines are written for the Scroll, so the 64 gets its own
        # shorter wording rather than a clipped version of this one.
        maxw = c.width - 2 * PAD - 2 * STROKE
        if c.width >= 128:
            t = _fit_clip(c, "NO ACTIVE STORMS", ["10x16", "6x8"], maxw)
            c.text_stroke(t[1], c.width // 2, band_y(TOP_Y, TOP_H, t[0]),
                          font = t[0], color = CLEAR, stroke = "black",
                          align = "center")
            sub = _fit_clip(c, "ATLANTIC AND PACIFIC CLEAR", ["4x5"], maxw)
            c.text_stroke(sub[1], c.width // 2, band_y(BOT_Y, BOT_H, "4x5"),
                          font = "4x5", color = "#357A5E", stroke = "black",
                          align = "center")
        else:
            c.text_stroke("NO STORMS", c.width // 2, 8, font = "6x8",
                          color = CLEAR, stroke = "black", align = "center")
            c.text_stroke("ALL CLEAR", c.width // 2, 20, font = "4x5",
                          color = "#357A5E", stroke = "black", align = "center")
        return

    s = active[0]
    name = str(s.get("name", "")).upper()
    kt = int(float(s.get("intensity", 0) or 0))
    cat = category(kt)
    mph = int(kt * 1.15078)
    wind = str(mph) + " MPH"
    bl = basin_label(s)
    if bl != "":
        wind = wind + "  " + bl

    c.fill(BG)
    ghost(c, cat[1])

    # The catalog ships this asset as a real 24x24 and a real 16x16 rather
    # than scaling one file. On the scroll it starts at the safe-zone edge; on
    # a 64, where the rule is to maximize the space, it keeps its old x = 1.
    sz = 24 if c.width >= 128 else 16
    ix = PAD if c.width >= 128 else 1
    c.image("HURRICANE.png", ix, (c.height - sz) // 2, w = sz, h = sz)

    if c.width >= 128:
        # Left edge: the icon sits at x = PAD, so the first lit pixel on the
        # panel is column 6 (it used to be column 1, which merged with
        # whatever app plays before this one in the sequence).
        # Right edge: `right` is the last column content may use, and
        # align="right" draws leftward from the anchor, so the anchor is
        # right + 1. Both edges therefore keep exactly PAD dark columns.
        tx = PAD + sz + ICON_GAP
        right = c.width - 1 - PAD
        anchor = right + 1

        # The category is drawn first so the name can be given whatever room is
        # actually left. Before, the name was allowed to reach x=120 (maxw =
        # width - 100) while the category was right-aligned with no limit at
        # all: "TROP STORM" is 107px at 10x16, so it started at x=79 and the
        # two drew through each other for 41px. "CAT 5" is only 53px, which is
        # why the overlap showed up on tropical storms and not on hurricanes.
        #
        # Capping the category at 72px keeps "CAT n" big and drops the two long
        # spelled-out labels to 6x8, which buys the name back ~38px.
        cf = _fit_clip(c, cat[0], ["10x16", "6x8"], CAT_MAXW)
        catw = c.text_width(cf[1], cf[0])
        c.text_stroke(cf[1], anchor, band_y(TOP_Y, TOP_H, cf[0]),
                      font = cf[0], color = cat[1], stroke = "black",
                      align = "right")

        # Name budget: what is left between the icon and the category, less
        # both stroke halos and a 3px gap. The budget is why ICON_GAP is 2 and
        # not 3: "SEBASTIEN" and "GABRIELLE" are the longest names on the NHC
        # lists at 96px in 10x16, and beside a 53px "CAT 5" that leaves the
        # hero exactly 96px to live in. One more pixel of padding and every
        # nine-letter storm drops to 6x8 for nothing. Beside the 69px
        # "TROP STORM" there is only 80px, so those do step down - deliberately,
        # measured, never clipped mid-word.
        nmax = right + 1 - tx - catw - GAP - 2 * STROKE
        nf = _fit_clip(c, name, ["10x16", "6x8", "5x7"], nmax)
        c.text_stroke(nf[1], tx, band_y(TOP_Y, TOP_H, nf[0]), font = nf[0],
                      color = "#FFFFFF", stroke = "black")

        # Bottom row: overflow count on the left, wind and basin on the right.
        # The count is measured first because it is the fixed-width half.
        morew = 0
        if n > 1:
            more = "+" + str(n - 1) + " MORE"
            morew = c.text_width(more, "5x7")
            c.text_stroke(more, tx, band_y(BOT_Y, BOT_H, "5x7"), font = "5x7",
                          color = "#A8788C", stroke = "black")
        wmax = right + 1 - tx - morew - GAP - 2 * STROKE
        wf = _fit_clip(c, wind, ["6x8", "5x7", "4x5"], wmax)
        c.text_stroke(wf[1], anchor, band_y(BOT_Y, BOT_H, wf[0]),
                      font = wf[0], color = "#E8A8B8", stroke = "black",
                      align = "right")
    else:
        # 64 maximizes the space instead of padding it: a 1px margin, the
        # short category wording, and no basin at all rather than a squeezed
        # one. Text starts 2px past the icon so the stroke halo still leaves
        # the 1px buffer the guidelines want between type and pixel art.
        m = 1
        anchor = c.width - m
        tx = ix + sz + 1 + STROKE
        nmax = anchor - tx
        nf = _fit_clip(c, name, ["6x8", "5x7", "4x5"], nmax)
        c.text_stroke(nf[1], anchor, 1, font = nf[0], color = "#FFFFFF",
                      stroke = "black", align = "right")
        cf = _fit_clip(c, cat[2], ["10x16", "6x8", "5x7"], nmax)
        c.text_stroke(cf[1], anchor, 11, font = cf[0], color = cat[1],
                      stroke = "black", align = "right")
        c.text_stroke(str(mph) + "MPH", anchor, 25, font = "4x5",
                      color = "#E8A8B8", stroke = "black", align = "right")
