# Garden Water
#
# Evapotranspiration is what the soil lost to the air; precipitation
# is what it got back. The difference over three days is a far
# better guide than 'has it rained today', which is the question
# most people ask and most people get wrong.
#
# DESIGN. A black panel with one picture and three lines of type.
# Left third: a hand-baked watering can, tipped over a sprout, on the
# 10px scroll safe-zone line -- the picture is the app's title, so a
# viewer scrolling past knows this is about the garden before reading
# a word. Right two thirds, one left rail at x=44: a quiet GARDEN chip
# with the town beside it, the verdict as the hero, then the working
# out -- sun took N, rain gave N -- in icons rather than the words
# LOST and RAIN, which did not fit next to the deficit.
#
# The gradient ground is gone. It was a vertical #08120C -> #1C3424
# wash, and on RGB565 the top half collapsed to black anyway while the
# bottom half lifted the footnote's contrast off it; a flat near-black
# is both cheaper and higher contrast, and it stops the app bleeding
# into whatever plays before and after it in the scroll sequence.

BG = "#050C07"           # flat near-black, a hint of green. No gradient.
CHIP_BG = "#173D28"      # identity chip: quiet, so the state color owns the eye
CHIP_FG = "#8FE9B4"
PLACE = "#6E8C78"
SUN_COL = "#E8B04A"      # what the air took
RAIN_COL = "#4FC3F7"     # what the sky gave

# The watering can: 30x28, drawn at x=10 so its leftmost lit pixel
# (the rim, the foot and the soil) sits exactly on the safe-zone line,
# and at y=3 so the soil line lands 1px clear of the bottom edge.
# Everything right of x=39 is text, so the art can never reach the type.
#
# The first cut of this drawing was a flat rectangle with a C handle on
# its left, which is the silhouette of a beer stein. Four things fixed it.
#
# One: the handle. A slab arch over a straight-sided drum reads as a bin
# or a briefcase, so the handle is a 1px wire bail, arched from shoulder
# to shoulder with daylight under it -- the shape a galvanised can has and
# a mug does not.
#
# Two: the silhouette above the barrel. A flat lid reads as a lid, so the
# top is a dome (9 wide, then 11, then the 13 of the barrel) with a small
# filling mouth on it, dark inside so it reads as open.
#
# Three: the shading. The old body was one flat blue with a highlight on
# its left edge. This one runs seven values across the 13px barrel --
# h n n m m m m k k k j j o -- so the tin turns like a cylinder instead of
# sitting there like a swatch, with a single darker row at r12 for the
# seam and the last two rows dropped a step for the shadow near the ground.
#
# Four: the ground. The old can hung in the air two-thirds up the panel
# with a separate strip of dirt under the sprout alone. The soil now runs
# all 30px and the can stands on it, in shadow (#52331D) where it sits and
# lit (#6B4326, with three #8A5A34 clods) where it does not.
#
# The spout is 3px where it leaves the can and 2px at the far end, and the
# rose flares one row proud of it so the join reads as a bell rather than
# a bend. Three streams fall from it onto the sprout, no two the same
# length, each with a #B7ECFF head -- the brightest pixels on the panel,
# which is where the eye should land.
#
# The whole spout, rose and stream assembly sits one row higher than it
# first did: the longest stream's head used to land on the row directly
# above the stem, so at 1x the water and the sprout fused into one blob of
# blue-green. Lifted a pixel, every stream now ends with a clear row of
# background under it and the sprout reads as a separate thing being
# watered rather than part of the pour.
CAN = """
.....hhhhhhh..................
...hh.......hh................
..h...........h...............
..h...........h...............
..h...........h...............
..h...hhhhh...h...............
..h..hjjjjjh..h...............
..h.hnnmmkkjo.h...............
..hhnnmmmkkjjoh...............
..hnnmmmmkkkjjo...............
..hnnmmmmkkkjjo...............
..hnnmmmmkkkjjo...............
..hnnkkkkkkkjjohh.............
..hnnmmmmkkkjjommhhh..........
..hnnmmmmkkkjjokkmmmhh...hhhhn
..hnnmmmmkkkjjo..kkkmmnnnnmmmn
..hnnmmmmkkkjjo.....kkkkknmmmm
..hnnmmmmkkkjjo..........nkjjj
..hnnmmmmkkkjjo..........w.w.w
..hnnmmmmkkkjjo..........w.W.w
..hnnmmmmkkkjjo..........W....
..hnnmmmmkkkjjo.......g.....g.
..hnnmmmmkkkjjo......gggGsGggg
..hnmkkkkkkjjjo........GGsGG..
..hkkkkkkkkjjjo..........s....
.hkkkkkkkkkkkkko.........s....
DDDDDDDDDDDDDDDDDeepeeepeeeepe
dddddddddddddddddddddddddddddd
"""

CAN_LEGEND = {
    "o": "#08202F",   # outline of the tin, reads as a hairline on black
    "j": "#123E66",   # the far side of the cylinder
    "k": "#1E5A8E",   # turning away from the light: seam, foot, collar
    "m": "#2F79B9",   # galvanised body
    "n": "#4A97DC",   # near the lit edge, and the raised bead
    "h": "#9AD8FA",   # lit left edge, rim, handle, top of the spout
    "w": "#4FC3F7",   # falling water
    "W": "#B7ECFF",   # the head of each stream -- brightest thing on the art
    "g": "#4EE38A",   # sprout leaves
    "G": "#1A7A47",   # the underside of each leaf
    "s": "#1F9B57",   # stem
    "e": "#6B4326",   # lit soil
    "p": "#8A5A34",   # a few lit clods, so the soil is not a painted bar
    "D": "#52331D",   # soil the can stands on -- shadowed, but still ground
    "d": "#3E2616",   # the cut face of the bed, under both
}

# 16x15 can for the 64px build: the same can with everything the size
# cannot carry taken out. The wire bail and the dome survive because they
# are what makes it a watering can; the sprout, the soil and the seam do
# not, because at nine pixels of body they would have been a green smear,
# a brown line and a wasted row. The spout keeps two drops so the picture
# still says watering rather than kettle.
CAN_NARROW = """
..hhhhh.........
.h.....h........
h.......h.......
h.......h.......
hhhhhhhhh.......
hkkkkkkko.......
hnnmmkkjo.......
hnnmmkkjo.......
hnnmmkkjohh.....
hnnkkkkjokkhh...
hnnmmkkjo..kkhhn
hnnmmkkjo....nmm
hnnmmkkjo....kjj
hkkkkkkko....w.w
.............W..
"""

# Icons in place of the words LOST and RAIN. "LOST 100MM   RAIN 100MM" is
# 138px at 5x7 and 115px at 4x5, and the footnote rail has 139px total
# with a 65px "999MM SHORT" already sitting in it, so the pair has to
# stay small.
#
# The first pass drew a plain sun and a plain teardrop, and a plain sun
# and a plain teardrop are nouns: WEATHER and WATER. The two numbers are
# not nouns. They are two processes -- what the air pulled out of the soil,
# and what the sky put back -- so each mark now shows its process running.
#
# EVAP is a bank of soil with three vapour trails lifting off it. The
# trails are drawn as wave, not as dither: two pixels straight, then two
# pixels stepped one column over, so at 1x each one holds together as a
# line that leans as it rises, where an every-other-pixel zigzag would have
# read as grit. The row of background between the trails and the soil is
# deliberate -- vapour that touches the ground is a plume of smoke, vapour
# that has left it is water going into the air, which is the number.
# A sun was tried here first and lost: at 7px the disc has to give up its
# rays to make room for the trails, and a rayless disc with wisps over it
# is a hot coal, not a sun. The colour still carries the warmth.
#
# RAINFALL is a cloud with three streaks under it, the middle one a row
# shorter than its neighbours. The stagger is the whole trick: three
# streaks of equal length read as a comb or a fringe, and one lifted row is
# enough to make them read as falling. They start on the cloud's bottom
# row, so the rain is leaving the cloud rather than hanging under it.
#
# Both are 7x7 in the footnote's seven rows, y 25-31. Widening the water
# mark from 5 to 7 cost a pixel the rail did not have, so the gap between
# the two pairs goes 6 -> 5: worst case is 71px of block against the 136
# available, leaving "999MM SHORT" its 65px at 5x7 exactly.
EVAP = """
.#.#.#.
.#.#.#.
#.#.#..
#.#.#..
.......
.#####.
#######
"""

RAINFALL = """
..###..
.#####.
#######
.#.#.#.
.#.#.#.
.#...#.
.......
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


def _mm(v):
    """A millimetre count clamped to three digits, so every string on the
    panel has a measurable worst case. Open-Meteo will not return four
    digits of daily rain, but the layout must not depend on that."""
    n = int(v + 0.5)
    if n < 0:
        n = 0
    if n > 999:
        n = 999
    return n


# Starlark has no font metrics call, so the heights the narrow branch
# centres against are carried by hand.
FONTH = {"10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}


def verdict(deficit):
    """[line, color, note, narrow_line] — one function, so the word and the
    color can never disagree about how thirsty the garden is.

    The fourth item is separate copy for 64px, not a clipped version of the
    first: "WATER SOON" is 108px at 10x16 and the 64 build has 45px, so it
    says SOON beside the can and lets the picture supply the verb."""
    if deficit <= 0:
        return ["NO NEED", "#4EE38A", str(_mm(-deficit)) + "MM SPARE",
                "NO NEED"]
    if deficit < 8:
        return ["NOT YET", "#A8E34E", str(_mm(deficit)) + "MM SHORT",
                "NOT YET"]
    if deficit < 16:
        return ["WATER SOON", "#F5D64E", str(_mm(deficit)) + "MM SHORT",
                "SOON"]
    return ["WATER NOW", "#FF7A4A", str(_mm(deficit)) + "MM SHORT", "NOW"]


def water(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "et0_fao_evapotranspiration,precipitation_sum",
                           "timezone": "auto", "past_days": "3",
                           "forecast_days": "1"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "NO CONNECTION")
        return
    d = r["json"].get("daily", {})
    ets = d.get("et0_fao_evapotranspiration", [])
    rain = d.get("precipitation_sum", [])

    lost = 0.0
    got = 0.0
    days = len(ets) if len(ets) < len(rain) else len(rain)
    if days == 0:
        nodata(c, "NO DATA", "EMPTY FEED")
        return
    for i in range(days):
        lost += float(ets[i] or 0)
        got += float(rain[i] or 0)

    v = verdict(lost - got)
    line = v[0]
    col = v[1]
    note = v[2]

    c.fill(BG)

    if c.width >= 128:
        # One left rail at x=44: art ends at x=39 (soil, the widest row),
        # so the 4px gutter is measured, not guessed. The rail is shared by
        # all three rows, which is what killed the old layout -- a
        # left-aligned verdict and a right-aligned note with no bound drew
        # through each other in every state, "WATER SOON" against
        # "14MM SHORT" included.
        X = 44
        RIGHT = c.width - 10          # 182: the scroll safe zone's right edge
        c.sprite(CAN, 10, 3, legend = CAN_LEGEND)

        # y 0-6 chip row. badge() sizes the pill around the ink, so a 4x5
        # GARDEN is 29 + 2*2 = 33px and 7px tall.
        bw = c.badge("GARDEN", X, 0, color = CHIP_FG, bg = CHIP_BG,
                     font = "4x5", pad = 2)
        if g[2]:
            # The town, clipped into whatever the chip left. "MOUNT
            # PLEASANT" is 67px at 4x5 against 102px available.
            p = _fit_clip(c, g[2], ["4x5"], RIGHT - (X + bw + 4) + 1)
            c.text(p[1], RIGHT, 1, font = "4x5", color = PLACE,
                   align = "right")

        # y 8-22 hero. "WATER SOON" is 108px at 10x16 against 139 available.
        h = _fit_clip(c, line, ["10x16", "6x8", "5x7"], RIGHT - X + 1)
        c.text(h[1], X, 8, font = h[0], color = col)

        # y 25-31 footnote. Right block first, then the note is fitted into
        # what is left of the rail -- the right side is measured first, so
        # the two can never meet.
        lt = str(_mm(lost)) + "MM"
        gt = str(_mm(got)) + "MM"
        block = (7 + 2 + c.text_width(lt, "4x5") + 5 +
                 7 + 2 + c.text_width(gt, "4x5"))
        sx = RIGHT - block + 1
        # icons y 25-31, their numbers y 26-30 so both centre on row 28
        c.sprite(EVAP, sx, 25, color = SUN_COL)
        c.text(lt, sx + 9, 26, font = "4x5", color = "#A8A182")
        dx = sx + 9 + c.text_width(lt, "4x5") + 5
        c.sprite(RAINFALL, dx, 25, color = RAIN_COL)
        c.text(gt, dx + 9, 26, font = "4x5", color = "#84AEC6")

        n = _fit_clip(c, note, ["5x7", "4x5"], sx - 3 - X)
        c.text(n[1], X, 25, font = n[0], color = col)
    else:
        # 64px: the can runs x 1-16 / y 2-16, so the headline gets x 18-62
        # (45px, a 2px buffer off the art) and the note the whole width
        # below it. The sun/rain footnote is dropped rather than squeezed --
        # its two icon+number pairs are 67px worst case against 62 of panel.
        c.sprite(CAN_NARROW, 1, 2, legend = CAN_LEGEND)
        h = _fit_clip(c, v[3], ["10x16", "6x8", "5x7"], c.width - 19)
        c.text(h[1], c.width - 2, 2 + (16 - FONTH[h[0]]) // 2, font = h[0],
               color = col, align = "right")
        n = _fit_clip(c, note, ["4x5"], c.width - 4)
        c.text(n[1], c.width - 2, 22, font = "4x5", color = col,
               align = "right")
