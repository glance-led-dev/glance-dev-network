# Last Z Full Preparedness for a Glance panel (192x32).
#
# DESIGN. Last Z runs Full Preparedness on a fixed weekly grid: six 4-hour
# blocks a day, each block naming the one thing worth spending on. Two pages,
# like the sibling HHN app: a title card that names the event and carries the
# live block's art, then the block page itself. The block page answers
# "what is it right now" the way the sibling park apps answer "how
# busy is it" - the app name across the top with the next block right-aligned
# beside it, then a content band split by a hairline: hand-drawn pixel art on
# the left carrying the block's identity, and on the right the block name in
# the block's color with the two things worth spending listed under it, and in
# a right-hand column the countdown with a bar beneath it draining across the
# block. The art is the label - a lit bunker, a
# bubbling flask, a tank, a gold-braided commander, a camo helmet - so the name
# is confirmation, not the only clue.
#
# The art follows the house rule the Halloween Horror Nights app spells out:
# a silhouette drawn in near-black disappears on real LED hardware, so nothing
# here is black, and every material carries a lit tone over a tone one step
# darker, lit from the upper left. Curved and symmetric subjects - the flask and
# the helmet - are built the way wwe-champions builds its belts, from
# half-width profiles stamped as centered rows (see `span` below). The
# irregular ones - the base, the tank and the hero - stay hand-typed grids,
# since a profile only ever yields a smooth symmetric blob. One high-chroma
# accent per sprite - amber windows, a green brew, a gold headlight, a gold
# epaulette, camo mottling - is what the eye lands on first.
#
# Clock only. No network, so there is no offline screen to design: the grid is
# the data. Calendar hours are Apocalypse Time (UTC minus 2). Day 1 is Monday,
# day 7 is Sunday.

GRID = [
    ["SHELTER", "SCIENCE", "VEHICLE", "HERO", "ARMY", "VEHICLE"],
    ["SCIENCE", "HERO", "SHELTER", "ARMY", "VEHICLE", "SHELTER"],
    ["HERO", "ARMY", "SCIENCE", "VEHICLE", "SHELTER", "SCIENCE"],
    ["ARMY", "VEHICLE", "HERO", "SHELTER", "SCIENCE", "HERO"],
    ["VEHICLE", "SHELTER", "ARMY", "SCIENCE", "HERO", "ARMY"],
    ["SCIENCE", "VEHICLE", "HERO", "SHELTER", "ARMY", "HERO"],
    ["VEHICLE", "SHELTER", "ARMY", "SCIENCE", "HERO", "ARMY"],
]

LABEL = {
    "SHELTER": "SHELTER",
    "SCIENCE": "SCIENCE",
    "VEHICLE": "VEHICLE",
    "HERO": "HERO",
    "ARMY": "ARMY",
}

# What actually scores points in each block, from the Full Preparedness task
# categories in Bacon's Last Z guide: hero counts EXP and prime recruits,
# shelter counts construction speedups and structure power, army counts
# training speedups and troops built, science counts research and research
# speedups, vehicle counts boomers, modification blueprints and golden
# wrenches. Two lines each, most valuable first, spelled out in full.
SPEND = {
    "SHELTER": ["BUILD SPEEDUPS", "STRUCTURE POWER"],
    "SCIENCE": ["RESEARCH SPEEDUPS", "INCREASE TECH POWER"],
    "VEHICLE": ["KILL BOOMERS", "BLUEPRINTS + WRENCHES"],
    "HERO": ["CONSUME EXP", "PRIME RECRUITS"],
    "ARMY": ["TRAINING SPEEDUPS", "TRAIN TROOPS"],
}

COLOR = {
    "SHELTER": "#4FAE3F",
    "SCIENCE": "#63B3FF",
    "VEHICLE": "#F2C14E",
    "HERO": "#C9B6FF",
    "ARMY": "#FF8C00",
}

# ---- geometry ---------------------------------------------------------------
# 6 px clear at both outer edges, like the sibling Universal/HHN apps, so the
# app reads as its own unit in the rotation. Title row y 0..6, content band
# y 7..31. Art occupies x 6..31; the text zone is x 40..185 (146 px), 6 px
# clear of the right edge like the sibling 192-wide apps, and every task line -
# the longest is BLUEPRINTS + WRENCHES - fits it spelled out in full.
EDGEL = 6
RZ_R = 185
ARTX = 6
DIVX = 36
TX = 40
DIV2 = 140

DIM = "#6E7A94"
INK = "#F4F7FF"
STRUCT = "#2A2E3A"
TRACK = "#3A4050"

# ---- pixel art --------------------------------------------------------------
# Concrete-and-steel base with a watchtower. The lit windows are the accent;
# the tower breaks the silhouette so it is not just a box.
SHELTER_LEG = {"R": "#8A93A8", "r": "#4A5064", "W": "#6E7486", "w": "#3E4354",
               "L": "#FFC94A", "D": "#23262F", "S": "#8A7550", "s": "#5A4A30",
               "G": "#2E3342", "A": "#9AA4B8", "X": "#FF5A44"}
SHELTER_ART = """
....................X.....
....................A.....
.................RRRRRRR..
................rrrrrrrrr.
.................WWWWWwww.
.................WLLLWwww.
.......RRRRRRRR..WLLLWwww.
......RRRRRRRRRR.WWWWWwww.
.....RRRRRRRRRRRRWWWWWwww.
....rrrrrrrrrrrrrWWWWWwww.
....WWWWWWWWWWWwwWLLLWwww.
....WLLLWWWLLLWwwWLLLWwww.
....WLLLWWWLLLWwwWWWWWwww.
....WWWWWWWWWWWwwWWWWWwww.
....rrrrrrrrrrrrrWWWWWwww.
....WWWWWWWWWWWwwWWWWWwww.
....WWWWDDDDWWWwwWWWWWwww.
....WWWWDDDDWWWwwWWWWWwww.
....WWWWDDDDWWWwwWWWWWwww.
...SSSSSSSSSSSSSSSSSSSSss.
GGGGGGGGGGGGGGGGGGGGGGGGGG
"""

# Everything below is drawn the way the wwe-champions belts are: a shape is a
# list of half-widths, and `span` stamps it as centered rows so it is symmetric
# by construction. Drawing the same profile three times, each inset a pixel,
# gives a dark edge, a lit rim and a body fill for free - which is what makes
# the object read as solid instead of as a flat stamp. Hand-counted grids are
# kept for the subjects with no symmetry to exploit: the base, the tank, and
# the hero.

def span(c, x, y, widths, color):
    for row in range(len(widths)):
        half = widths[row]
        if half >= 0:
            c.hline(x - half, y + row, half * 2 + 1, color)

def inset(widths, n):
    """The same profile pulled in n px on every side: n narrower per row, and
    n rows off the top and bottom."""
    out = []
    for i in range(n, len(widths) - n):
        out.append(max(-1, widths[i] - n))
    return out

# A conical flask mid-brew. The glass is one clean wall between a dark edge and
# a hollow interior - no lit/shadow rail down both sides, which read as a
# crooked seam rather than as glass.
BK_EDGE = "#2A5A66"
BK_GLASS = "#BFE9F5"
BK_LIQ = "#35C46A"
BK_LIQ_LO = "#1C8A48"
BK_LIQ_HI = "#8CF0B4"
BK_BUB = "#DFFFF0"
BK_CORK = "#B07A3A"
BK_CORK_D = "#6E4A20"
BK_BENCH = "#3A4048"

def _art_science(c, ox, oy):
    cx = ox + 12
    prof = [2, 2, 2, 2, 2, 2] + [3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11] + [11]
    top = oy + 2
    span(c, cx, top, prof, BK_EDGE)
    span(c, cx, top + 1, inset(prof, 1), BK_GLASS)
    span(c, cx, top + 2, inset(prof, 2), "black")
    hollow = inset(prof, 2)
    surface = 7
    for i in range(len(hollow)):
        if i >= surface:
            col = BK_LIQ
            if i == surface:
                col = BK_LIQ_HI
            elif i >= len(hollow) - 2:
                col = BK_LIQ_LO
            half = hollow[i]
            c.hline(cx - half, top + 2 + i, half * 2 + 1, col)
    c.rect(cx - 3, oy, cx + 3, oy + 1, fill = BK_CORK)
    c.hline(cx - 3, oy + 1, 7, BK_CORK_D)
    c.pixel(cx - 4, oy + 15, BK_BUB)
    c.pixel(cx + 3, oy + 18, BK_BUB)
    c.pixel(cx - 1, oy + 19, BK_BUB)
    c.hline(ox, oy + 22, 26, BK_BENCH)

# A combat helmet: a dome over a flared brim, lit on the crown and shadowed
# along the brim, with camo mottling stamped over the finished dome.
HM_EDGE = "#2E3618"
HM_BODY = "#6E7A46"
HM_HI = "#96A668"
HM_LO = "#4A5430"
HM_HI2 = "#8E9C5E"

# Camo mottling: [x, y, run, tone] with tone 1 = light, 0 = dark. A 5px star
# here read as a house - roof, then a gap between its legs for a door - and
# the reference helmet was camo-patterned anyway.
CAMO = [
    [6, 3, 4, 0], [13, 2, 5, 0], [4, 7, 5, 0],
    [14, 7, 5, 0], [8, 11, 5, 0],
    [10, 5, 3, 1], [17, 5, 3, 1], [5, 12, 4, 1],
]

def _art_army(c, ox, oy):
    cx = ox + 12
    prof = [3, 5, 6, 7, 8, 9, 9, 10, 10, 11, 11, 11, 11, 11] + [12, 13, 13]
    span(c, cx, oy, prof, HM_EDGE)
    body = inset(prof, 1)
    span(c, cx, oy + 1, body, HM_BODY)
    for i in range(len(body)):
        half = body[i]
        if i < 4:
            c.hline(cx - half, oy + 1 + i, half * 2 + 1, HM_HI)
        elif i >= len(body) - 3:
            c.hline(cx - half, oy + 1 + i, half * 2 + 1, HM_LO)
    lip = len(body) - 3
    c.hline(cx - body[lip], oy + 1 + lip, body[lip] * 2 + 1, HM_BODY)
    for i in range(len(CAMO)):
        p = CAMO[i]
        col = HM_HI2 if p[3] == 1 else HM_LO
        c.hline(ox + p[0], oy + p[1], p[2], col)
        c.hline(ox + p[0] + 1, oy + p[1] + 1, max(1, p[2] - 1), col)

# A tracked tank, hull and turret stepped so the silhouette is unmistakable
# beside the truck-shaped icons every other app draws. Angular, so it stays a
# hand-typed grid; E is the dark olive edge that separates it from black.
TANK_LEG = {"E": "#26301A", "B": "#5C6638", "H": "#7E8A52", "D": "#3E4626",
            "T": "#3A3A3E", "t": "#24242A", "W": "#8A8A92", "R": "#FFC94A",
            "G": "#2E3342"}
TANK_ART = """
..........EEEEEEEEE.......
.........EHHHHHHHHHE......
........EHHHHHHHHHHHE.....
EEEEEEEEEBBBBBBBBBBBBE....
EHHHHHHHEBBBBBBBBBBBBE....
EBBBBBBBEBBBBBBBBBBBBE....
EEEEEEEEEBDDDDDDDDDDDE....
........EEEEEEEEEEEEEE....
..EEEEEEEEEEEEEEEEEEEEEE..
.EHHHHHHHHHHHHHHHHHHHHHHE.
.EBBBBBBBBBBBBBBBBBBBBBRE.
.EBBBBBBBBBBBBBBBBBBBBBBE.
.EDDDDDDDDDDDDDDDDDDDDDDE.
.EEEEEEEEEEEEEEEEEEEEEEEE.
.TTTTTTTTTTTTTTTTTTTTTTTT.
.TWWTTWWTTWWTTWWTTWWTTWWT.
.TTTTTTTTTTTTTTTTTTTTTTTT.
.tttttttttttttttttttttttt.
GGGGGGGGGGGGGGGGGGGGGGGGGG
"""

# The commander: peaked cap with a gold badge, gold braid across both
# shoulders, long hair falling from under the cap past the jaw onto the
# shoulders, red lips, and a collar open in a small gold-edged V. The hair runs
# only down the sides - the cap covers the top - so it never closes around the
# face into a hood, and it is mid-brown because a light hair mass on a black
# panel swallows the face. The row under the chin is skin shadow, which keeps
# the chin and the neckline from merging into one long pale column. A face,
# where ARMY is an object, so the two never read alike.
HERO_LEG = {"P": "#3A4470", "p": "#232A48", "U": "#2E3558", "u": "#1C2038",
            "Y": "#E8C24A", "y": "#A88420", "S": "#E0B084", "s": "#A87A50",
            "E": "#2A2420", "H": "#9A6C42", "h": "#6E4A32", "L": "#D42F3F"}
HERO_ART = """
..........................
........PPPPPPPP..........
.......PPPPPPPPPPp........
.......PPPPYYPPPPp........
......PPPPPYYPPPPPp.......
.....pppppppppppppp.......
......YYYYYYYYYYYYy.......
......HHSSSSSSSshh........
.....HHSSSSSSSSsshh.......
.....HHSESSSSESsshh.......
.....HHSESSSSESsshh.......
.....HHSSSSSSSSsshh.......
.....HHHSSSLLSSshhh.......
.....HHHSSSSSSSshhh.......
.....HHHHSSSSSshhhh.......
.....HHHHUssssUhhhh.......
......HHHYSSSSYhhh........
....UUHHHUYSSYUhhhUUu.....
..YYYUHHUUUYYUUUhhUYYYu...
.YYYYYUHUUUUUUUUhUYYYYYu..
.yyyYyUUUUUUUUUUUUyYyyyu..
...UUUUUUUUUUUUUUUUUUu....
...UUUUUUUUUUUUUUUUUUu....
"""

# Art that stands on something (the base, the flask's bench, the tank's ground
# row) is bottom-aligned to y31, and so is the hero, a bust cut off by the
# bottom edge; the helmet floats, so it centres in the band instead.
ART_Y = {"SHELTER": 11, "SCIENCE": 9, "VEHICLE": 13, "HERO": 9, "ARMY": 11}

# The Z from the game's logo, drawn rather than typed: the logo's red-orange,
# lit along its top edges and darkened along the bottom, with a scatter of its
# splatter. The title card sets it after LAST the way the logo does. ARTX_R
# reserves a 26px picture slot 6px off the right edge, mirroring the left
# picture, for a second title-card picture.
ARTX_R = RZ_R - 25
LOGO_W = 24
# The Z's bottom bar ends on its row 18; y3 lands that on LAST's bottom (y21).
# It stands taller than LAST, like the logo, where the Z dwarfs the word.
LOGO_TOP = 3
LOGO_GAP = 2
LOGO_LEG = {"R": "#E23B24", "O": "#FF7B3A", "D": "#8A1C12", "s": "#B02818"}
LOGO_ART = """
.......s....s...........
.......s.............s..
...OOOOOOOOOOOOOOOOOOO.s
..sRRRRRRRRRRRRRRRRRRRs.
ss.RRRRRRRRRRRRRRRRRRR..
...DDDDDDDDDDDDRRRRRRR..
...............ORRRRRD..
..............ORRRRRD...
.....s......ORRRRRD.....
....s......ORRRRRD......
.........ORRRRRD........
........ORRRRRD....s....
......ORRRRRD.......s...
.....ORRRRRD............
...ORRRRRD..............
...OOOOOOOOOOOOOOOOOOO..
..sRRRRRRRRRRRRRRRRRRRs.
.s.RRRRRRRRRRRRRRRRRRR.s
...DDDDDDDDDDDDDDDDDDD..
.........s.......s......
.................s......
"""

# The gold Zombie chest, in a three-quarter view: the lid's top face recedes
# up and to the right with the side face in shadow, two gunmetal bands wrap
# over the lid and down the front, and a square lock plate in the bands'
# gunmetal sits centred across the lid seam, with a 1px keyhole - the front is
# 21px wide so both can centre. A rounded gold plate hanging below the seam
# read as a tongue poking out of a mouth. The chest's claw emblem is left off:
# at this size its strokes merge into a checkerboard smudge. It stands on a
# floor row, bottom-aligned to y31 in the right slot like the tank on the left.
CHEST_Y = 13
CHEST_LEG = {
    "Y": "#FFE48A", "G": "#F2BE45", "g": "#C88A22", "o": "#9A6516",
    "d": "#5C3C0E", "B": "#9AA0AA", "b": "#6A6F78", "n": "#474B52",
    "K": "#3A2508", "z": "#5A4520",
}
CHEST_ART = """
.....GGGBBbGGGGGGGGGBBbGGG
....YYYBBbYYYYYYYYYBBbYYYo
...YYYBBbYYYYYYYYYBBbYYYoo
..YYYBBbYYYYYYYYYBBbYYYooo
.YYYBbnYYYYYYYYYBbnYYgoooo
.YGGBbnGGGGGGGGGBbnGGgoood
.YGGBbnGGGGGGGGGBbnGGgoodo
.YGGBbnGGBBBBbGGBbnGGgodoo
.YGGBbnGGBbbbnGGBbnGGgdooo
.ddddddddBbKbnddddddddoooo
.YGGBbnGGBbbbnGGBbnGGgoooo
.YGGBbnGGbnnnnGGBbnGGgoooo
.YGGBbnGGGGGGGGGBbnGGgoooo
.YGGBbnGGGGGGGGGBbnGGgoooo
.YGGBbnGGGGGGGGGBbnGGgooo.
.YGGBbnGGGGGGGGGBbnGGgoo..
.YGGBbnGGGGGGGGGBbnGGgo...
.gggBbngggggggggBbnggg....
.zzzzzzzzzzzzzzzzzzzzzzzzz
"""

def _draw_art(c, theme, x = ARTX):
    y = ART_Y[theme]
    if theme == "SHELTER":
        c.sprite(SHELTER_ART, x, y, legend = SHELTER_LEG)
    elif theme == "SCIENCE":
        _art_science(c, x, y)
    elif theme == "VEHICLE":
        c.sprite(TANK_ART, x, y, legend = TANK_LEG)
    elif theme == "HERO":
        c.sprite(HERO_ART, x, y, legend = HERO_LEG)
    else:
        _art_army(c, x, y)

# ---- calendar ---------------------------------------------------------------
def _is_leap_year(year):
    if year % 400 == 0:
        return True
    if year % 100 == 0:
        return False
    return year % 4 == 0

def _days_in_month(year, month):
    if month == 2:
        return 29 if _is_leap_year(year) else 28
    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30
    return 31

def _previous_day(year, month, day):
    day = day - 1
    if day < 1:
        month = month - 1
        if month < 1:
            month = 12
            year = year - 1
        day = _days_in_month(year, month)
    return [year, month, day]

def _day_of_week(year, month, day):
    offsets = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
    y = year
    if month < 3:
        y = y - 1
    return (y + y // 4 - y // 100 + y // 400 + offsets[month - 1] + day) % 7

def _apocalypse(now):
    year = now.year
    month = now.month
    day = now.day
    hour = now.hour
    minute = now.minute
    second = now.second
    hour = hour - 2
    if hour < 0:
        hour = hour + 24
        prev = _previous_day(year, month, day)
        year = prev[0]
        month = prev[1]
        day = prev[2]
    return [year, month, day, hour, minute, second]

def _dow_index(year, month, day):
    sun0 = _day_of_week(year, month, day)
    if sun0 == 0:
        return 6
    return sun0 - 1

def _block(hour):
    return hour // 4

def _theme(day_index, block):
    return GRID[day_index][block]

def _pad2(n):
    if n < 10:
        return "0" + str(n)
    return str(n)

def _remain(hour, minute, second):
    next_hour = (hour // 4 + 1) * 4
    if next_hour >= 24:
        next_hour = 24
    total = (next_hour - hour) * 3600 - minute * 60 - second
    if total < 0:
        total = 0
    h = total // 3600
    m = (total % 3600) // 60
    return [h, m, total]

# ---- pages ------------------------------------------------------------------
def _now_theme(ctx):
    at = _apocalypse(ctx.now)
    return _theme(_dow_index(at[0], at[1], at[2]), _block(at[3]))

def title(c, ctx):
    """The splash that precedes the block page in the scroll rotation. It
    names the event rather than repeating the block's numbers, and borrows the
    live block's art and color so the two pages read as one app."""
    theme = _now_theme(ctx)
    c.fill("black")
    _draw_art(c, theme)
    # The name is set the way the game's own logo sets it: LAST in white, then
    # the Z drawn large in the logo's red-orange instead of typed, with LAST's
    # bottom lined up on the Z's lower bar. LAST stays 11x14 - the 10x16 S
    # hooks at the bottom-left but not the top-right, so its top half reads as
    # a C. The pair centres in the gap between the two pictures.
    zl = ARTX + 26
    zone = ARTX_R - zl
    lw = c.text_width("LAST", "11x14")
    tx = zl + (zone - (lw + LOGO_GAP + LOGO_W)) // 2
    c.text("LAST", tx, 8, font = "11x14", color = INK)
    c.sprite(LOGO_ART, tx + lw + LOGO_GAP, LOGO_TOP, legend = LOGO_LEG)
    c.sprite(CHEST_ART, ARTX_R, CHEST_Y, legend = CHEST_LEG)
    sub = "FULL PREPAREDNESS"
    sx = zl + (zone - c.text_width(sub, "4x5")) // 2
    c.text(sub, sx, 25, font = "4x5", color = COLOR[theme])

def main(c, ctx):
    at = _apocalypse(ctx.now)
    year = at[0]
    month = at[1]
    day = at[2]
    hour = at[3]
    minute = at[4]
    second = at[5]

    day_i = _dow_index(year, month, day)
    block = _block(hour)
    theme = _theme(day_i, block)

    next_block = block + 1
    next_day_i = day_i
    if next_block > 5:
        next_block = 0
        next_day_i = (day_i + 1) % 7
    nxt = _theme(next_day_i, next_block)

    left = _remain(hour, minute, second)
    left_h = left[0]
    left_m = left[1]

    accent = COLOR[theme]
    left_t = left[2]
    c.fill("black")

    # Identity never waits on anything: name, then art, then the words.
    c.text("LAST Z FULL PREP", EDGEL, 1, font = "4x5", color = accent)
    c.text("NEXT " + LABEL[nxt], RZ_R, 1, font = "4x5", color = COLOR[nxt],
           align = "right")

    _draw_art(c, theme)
    c.vline(DIVX, 7, 25, STRUCT)

    # Middle column: the block name over the two things worth spending. It is
    # 98px wide because BLUEPRINTS + WRENCHES is, and it has the band's full
    # height to itself now that the bar sits under the countdown - which is
    # what lets the name go back up to 8x10.
    c.text(LABEL[theme], TX, 7, font = "8x10", color = accent)
    items = SPEND[theme]
    c.text(items[0], TX, 18, font = "4x5", color = DIM)
    c.text(items[1], TX, 24, font = "4x5", color = DIM)

    # Right column: the countdown as the hero, in the title card's 11x14 face,
    # the way Brightline gives its departure time the big type. H:MM is 43px,
    # exactly the width left between the second hairline and the edge.
    c.vline(DIV2, 7, 25, STRUCT)
    c.text("TIME LEFT", RZ_R, 7, font = "4x5", color = DIM, align = "right")
    remain = str(left_h) + ":" + _pad2(left_m)
    c.text(remain, RZ_R, 13, font = "11x14", color = INK, align = "right")

    # The bar drains across the 4-hour block directly under the countdown, so
    # the time and how much of the block is left read as one unit. It spans the
    # countdown's own 43px.
    barx = DIV2 + 3
    c.rect(barx, 28, RZ_R, 31, fill = TRACK)
    fill_w = left_t * (RZ_R - barx + 1) // 14400
    if fill_w < 1 and left_t > 0:
        fill_w = 1
    if fill_w > 0:
        c.rect(barx, 28, barx + fill_w - 1, 31, fill = accent)
