# Sleeps Till Christmas for a Glance SCROLL panel (192x32).
#
# DESIGN. A black winter night framed by the two things that say Christmas
# from across a room: a string of colored bulbs sagging along the top of the
# app and a bank of snow along the bottom. Your chosen character (a tree by
# default) stands on the snow at the left, the number of sleeps until the 25th
# is the hero in the middle, and on the right Santa's sleigh crosses the moon
# above a lit-up cottage. Snow drifts to new spots every refresh. On Christmas
# morning the count gives way to a greeting.
#
# Everything is computed from ctx.now, so the panel always has something to
# show. The date is worked out in the reader's own time zone, so the count
# rolls at their midnight rather than at 7 PM. No network, no error screen.

# ---- geometry ---------------------------------------------------------------
# The app's outer edges keep 8 px clear so it reads as its own unit between the
# apps that play before and after it on a scroll panel.
EDGEL = 8
EDGER = 183

WIREY = 0            # the light string hangs from the very top row
SNOWY = 29           # first full row of snow; drift bumps sit on row 28
GROUND = 28          # the row characters stand on

HEROX = 8            # every hero is 23 px wide, standing at x 8..30
ZONEL = 35           # the number and its labels live between these two...
ZONER = 151          # ...117 px, which is exactly what "364 SLEEPS TIL CHRISTMAS"
                     # needs at 16x20 + 6x8 (50 + 4 + 62 = 116). The lead
                     # reindeer starts at x 153, one clear column past it.

GREEN = "#00DC46"
SNOW1 = "#F0F8FF"    # top of the snow bank
SNOW2 = "#A8CCF0"
SNOW3 = "#4A70A8"
LABEL = "#9CB4D8"    # the quiet blue-gray for "SLEEPS TIL"

# One legend for every sprite, so a color means the same thing everywhere.
LEG = {
    "G": GREEN,        # tree green
    "g": "#0A8A30",    # tree shadow
    "Y": "#FFD23F",    # gold: star, bells, bows, lit windows
    "R": "#FF2A2A",    # red
    "r": "#A01818",    # dark red (roof edge, hat band)
    "B": "#3A8DFF",    # blue
    "M": "#FF3FD0",    # magenta bauble
    "W": "white",
    "K": "#101010",    # coal: eyes, buttons, mouths (sits on white or tan)
    "O": "#FF8C00",    # carrot
    "N": "#8B5A2B",    # brown: trunk, reindeer, cottage wall
    "n": "#5C3A1A",    # dark brown: hooves, chimney
    "P": "#FFC9A8",    # skin
    "T": "#D2955A",    # gingerbread
    "t": "#C8A070",    # reindeer muzzle
    "S": "#3E4657",    # slate: boots, belt, top hat
    "d": "#2A1608",    # cottage door
    "c": "#6E7A94",    # bulb cap, chimney smoke
    "m": "#CFBF80",    # moon craters
    "L": "#F4E8B4",    # moon
}

# ---- pixel art ----------------------------------------------------------------
# Heroes are all 23 wide x 23 tall so any of them stands in the same footprint:
# x 8..30, y 6..28, one row under the bulbs and feet on the drift row.

TREE = """
...........Y...........
.........YYYYY.........
..........YYY..........
..........GGG..........
.........GGRGG.........
........GGGGBGG........
.......GGYGGGGGG.......
......WGGGGMGGGGW......
.........ggggg.........
........GGGRGGG........
.......GGGGGGBGG.......
......GGYGGGGGGGG......
.....GGGGGGGMGGGGG.....
....WGGGRGGGGGGGGGW....
........ggggggg........
.......GGGGBGGGG.......
......GGGGGGGGYGG......
.....GGRGGGGGGGGGG.....
....GGGGGGGMGGGGGGG....
...GGGGYGGGGGGBGGGG....
..WGGGGGGGGGGGGGGGGGW..
..........NNN..........
..........NNN..........
"""

SANTA = """
.............WW........
..........RRRWW........
.........RRRRR.........
........RRRRRRR........
.......RRRRRRRRR.......
......WWWWWWWWWWW......
.......PPPPPPPPP.......
.......PPKPPPKPP.......
.......PPPPPPPPP.......
......WWWPPPPPWWW......
.....WWWWWWKWWWWWW.....
.....WWWWWWWWWWWWW.....
......WWWWWWWWWWW......
.......WWWWWWWWW.......
....RRRRWWWWWRRRR......
...RRRRRRRRWRRRRRRR....
...RRRRRRRRRRRRRRRR....
..WWRRRRRRRRRRRRRRWW...
..GGRRRRRRRRRRRRRRGG...
....SSSSSSSYSSSSSS.....
....RRRRRRRRRRRRRR.....
....WWWWWWWWWWWWWW.....
.....SSSS....SSSS......
"""

SNOWMAN = """
........SSSSSSS........
........SSSSSSS........
........SrrrrrS........
......SSSSSSSSSSS......
.......WWWWWWWWW.......
......WWWWWWWWWWW......
......WWWKWWWKWWW......
......WWWWWOOWWWW......
......WWKWWWWWKWW......
.......WWKKKKKWW.......
........WWWWWWW........
......RRRRRRRRRRR......
.......RRRRRRRRRRR.....
......WWWWWWWWWWWRR....
.....WWWWWWWWWWWWWR....
..N..WWWWWWKWWWWWW..N..
...NNWWWWWWWWWWWWWNN...
.....WWWWWWKWWWWWW.....
....WWWWWWWWWWWWWWW....
...WWWWWWWWKWWWWWWWW...
...WWWWWWWWWWWWWWWWW...
...WWWWWWWWWWWWWWWWW...
....WWWWWWWWWWWWWWW....
"""

REINDEER = """
...N.N.........N.N.....
...NNN.........NNN.....
....NN.........NN......
....N.N.......N.N......
.....NN.......NN.......
......NNNNNNNNN........
...nn.NNNNNNNNN.nn.....
...nnNNNNNNNNNNNnn.....
.....NNWKNNNWKNN.......
.....NNNNNNNNNNN.......
......NNNNNNNNN........
......NtttttttN........
.......tttRRttt........
.......ttRRRRtt........
........tttttt.........
.........NNNN..........
........RRRRRR.........
......NNNNYNNNNN.......
.....NNNNNNNNNNNN......
.....NNNNNNNNNNNN......
.....NNNNNNNNNNNN......
.....NN.NN..NN.NN......
.....nn.nn..nn.nn......
"""

GINGERBREAD = """
........TTTTTTT........
.......TTTTTTTTT.......
......TTWTWTWTWTT......
......TTTKTTTKTTT......
......TTTTTTTTTTT......
......TTWTTTTTWTT......
.......TTWWWWWTT.......
........TTTTTTT........
....TTTTTTTTTTTTTTT....
...TTTTTTTTRTTTTTTTT...
...TWWTTTTTTTTTTTWWT...
...TWWTTTTTGTTTTTWWT...
....TTTTTTTTTTTTTTT....
.......TTTTRTTTT.......
.......TTTTTTTTT.......
.......TTTTGTTTT.......
.......TTTTTTTTT.......
......TTTTTTTTTTT......
......TTTTT.TTTTT......
.....TTTTTT.TTTTTT.....
.....TTTTTT.TTTTTT.....
.....TWWTTT.TTTWWT.....
.....TWWTTT.TTTWWT.....
"""

HEROES = {
    "TREE": TREE,
    "SANTA": SANTA,
    "SNOWMAN": SNOWMAN,
    "REINDEER": REINDEER,
    "GINGERBREAD": GINGERBREAD,
}

MOON = """
...LLLLL...
.LLLLLLLLL.
.LLLLmLLLL.
LLLLLLLLLLL
LLmLLLLLmLL
LLLLLLLLLLL
LLLLLLmLLLL
LLLLLLLLLLL
.LLmLLLLLL.
.LLLLLLLLL.
...LLLLL...
"""

# The team flies right to left, toward the character. One reindeer sprite is
# drawn twice; the sleigh carries Santa's hat and a gold runner.
DEER = """
N.N....
.NN....
.NNNNNN
..NNNNN
..N..N.
..N..N.
"""
SLEIGH = """
.....WRR.
.....PRR.
.R...RRRR
.RR.RRRRR
.RRRRRRRR
..RRRRRR.
.YYYYYYYY
"""

COTTAGE = """
......W......
.....WWW.nn..
....WWWWWnn..
...WWWWWWWWW.
..rrrrrrrrrrr
..NNNNNNNNNNN
..NYYNNNNNYYN
..NYYNNddNYYN
..NNNNNddNNNN
..NNNNNddNNNN
"""

PINE = """
...W...
..GGG..
.WGgGW.
..GGG..
.GGgGG.
WGGGGGW
.GgGgG.
GGGGGGG
...N...
"""

GIFT = """
.Y.Y.
..Y..
RRYRR
YYYYY
RRYRR
"""

BULB = """
.c.
XXX
XXX
.X.
"""
BULB_COLORS = ["#FF2A2A", GREEN, "#FFD23F", "#3A8DFF", "#FF3FD0"]

FLAKE = """
.W.
WWW
.W.
"""

# ---- date arithmetic -------------------------------------------------------
def days_from_civil(y, m, d):
    """Days since 1970-01-01 (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + 1 if m <= 2 else y, m, d]

def weekday(z):
    """0 = Monday .. 6 = Sunday. Day 0 (1970-01-01) was a Thursday."""
    return (z + 3) % 7

# ---- time zones ------------------------------------------------------------
# ctx.now is UTC. A countdown that rolls over at 7 PM in New York is wrong for
# a child checking the panel before bed, so the reader picks their city and the
# offset (daylight saving included) is worked out here, with no network call.
# Same table and rules as the catalog's other zone-aware apps.
#
# zone -> [standard offset in minutes, DST rule]
#   0 none  1 United States  2 Europe  3 Australia (southern)
#   4 New Zealand  5 Egypt  6 Israel
TZ = {
    "Pacific/Honolulu": [-600, 0],
    "America/Anchorage": [-540, 1],
    "America/Los_Angeles": [-480, 1],
    "America/Phoenix": [-420, 0],
    "America/Denver": [-420, 1],
    "America/Chicago": [-360, 1],
    "America/Mexico_City": [-360, 0],
    "America/New_York": [-300, 1],
    "America/Bogota": [-300, 0],
    "America/Halifax": [-240, 1],
    "America/Sao_Paulo": [-180, 0],
    "America/Argentina/Buenos_Aires": [-180, 0],
    "UTC": [0, 0],
    "Europe/Lisbon": [0, 2],
    "Europe/Dublin": [0, 2],
    "Europe/London": [0, 2],
    "Europe/Madrid": [60, 2],
    "Europe/Paris": [60, 2],
    "Europe/Amsterdam": [60, 2],
    "Europe/Berlin": [60, 2],
    "Europe/Rome": [60, 2],
    "Europe/Stockholm": [60, 2],
    "Europe/Warsaw": [60, 2],
    "Africa/Lagos": [60, 0],
    "Europe/Athens": [120, 2],
    "Europe/Helsinki": [120, 2],
    "Africa/Johannesburg": [120, 0],
    "Europe/Moscow": [180, 0],
    "Africa/Nairobi": [180, 0],
    "Asia/Dubai": [240, 0],
    "Asia/Karachi": [300, 0],
    "Asia/Kolkata": [330, 0],
    "Asia/Dhaka": [360, 0],
    "Asia/Bangkok": [420, 0],
    "Asia/Jakarta": [420, 0],
    "Asia/Shanghai": [480, 0],
    "Asia/Singapore": [480, 0],
    "Asia/Hong_Kong": [480, 0],
    "Australia/Perth": [480, 0],
    "Asia/Tokyo": [540, 0],
    "Asia/Seoul": [540, 0],
    "Australia/Adelaide": [570, 3],
    "Australia/Brisbane": [600, 0],
    "Australia/Sydney": [600, 3],
    "Australia/Melbourne": [600, 3],
    "Pacific/Auckland": [720, 4],
    "Atlantic/Reykjavik": [0, 0],
    "Europe/Kyiv": [120, 2],
    "Europe/Istanbul": [180, 0],
    "Africa/Cairo": [120, 5],
    "Asia/Jerusalem": [120, 6],
    "Asia/Manila": [480, 0],
}

def nth_sunday(y, m, n):
    """Day of the month of the nth Sunday, or the last one when n is -1."""
    if n == -1:
        last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
        if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
            last = 29
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    first = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return first + 7 * (n - 1)

def last_dow(y, m, dow):
    """Day of the month of the last given weekday (0 = Monday)."""
    last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
    if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
        last = 29
    return last - ((weekday(days_from_civil(y, m, last)) - dow) % 7)

def _utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(zone, t):
    """Minutes east of UTC for `zone` at the UTC instant `t` (minutes since
    the epoch). Every comparison is done in UTC so the local-time
    discontinuity at a changeover never has to be reasoned about."""
    z = TZ[zone] if zone in TZ else TZ["UTC"]
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    if rule == 1:
        start = _utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
        end = _utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 2:
        start = _utcmin(y, 3, nth_sunday(y, 3, -1), 1)
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 1)
        return std + 60 if t >= start and t < end else std
    if rule == 5:
        start = _utcmin(y, 4, last_dow(y, 4, 4), 0) - std
        end = _utcmin(y, 10, last_dow(y, 10, 4), 0) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 6:
        start = _utcmin(y, 3, nth_sunday(y, 3, -1) - 2, 2) - std
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    # Southern hemisphere: summer straddles New Year, so the test is inverted.
    m0 = 10 if rule == 3 else 9
    n0 = 1 if rule == 3 else -1
    start = _utcmin(y, m0, nth_sunday(y, m0, n0), 2) - std
    end = _utcmin(y, 4, nth_sunday(y, 4, 1), 3) - std - 60
    return std if t >= end and t < start else std + 60

def local_today(ctx):
    """[y, m, d] on the reader's wall clock."""
    zone = str(ctx.inputs.get("timezone", "America/New_York")).strip()
    mins = ctx.now.unix // 60 + zone_offset_at(zone, ctx.now.unix // 60)
    return civil_from_days(mins // 1440)

def sleeps_left(ctx):
    """Nights until December 25. Zero on the day itself; the week after
    Christmas already counts toward next year's."""
    t = local_today(ctx)
    today = days_from_civil(t[0], t[1], t[2])
    xmas = days_from_civil(t[0], 12, 25)
    if today > xmas:
        xmas = days_from_civil(t[0] + 1, 12, 25)
    return xmas - today

# ---- scene -----------------------------------------------------------------
def snow(c):
    """A bank of snow along the bottom, lit on top and shaded underneath, with
    drift bumps on the row the characters stand on. It stops 8 px short of both
    edges, like the light string, so the two frame the app as one unit."""
    w = EDGER - EDGEL + 1
    c.hline(EDGEL, SNOWY, w, SNOW1)
    c.hline(EDGEL, SNOWY + 1, w, SNOW2)
    c.hline(EDGEL, SNOWY + 2, w, SNOW3)
    # Bumps every 9 px, offset so no two line up with a bulb above them.
    for x in range(EDGEL + 3, EDGER - 2, 9):
        c.hline(x, GROUND, 3, SNOW1)
        c.pixel(x + 1, GROUND - 1, SNOW1)

def lights(c):
    """The string of bulbs. The wire sags one row between bulbs; each bulb
    hangs from a high point on a gray cap. Colors repeat red, green, gold,
    blue, magenta, the way a box of C9s does."""
    wire = "#0E5A24"
    first = EDGEL + 5
    pitch = 11
    for x in range(EDGEL, EDGER + 1):
        near = (x - first) % pitch
        if near > pitch // 2:
            near = pitch - near
        c.pixel(x, WIREY if near <= 2 else WIREY + 1, wire)
    i = 0
    for bx in range(first, EDGER - 1, pitch):
        c.sprite(BULB, bx - 1, WIREY + 1, legend = {"c": LEG["c"],
                                                    "X": BULB_COLORS[i % 5]})
        i += 1

def moon_and_sleigh(c):
    """Full moon in the top right corner with the team crossing in front of
    it, nose down toward the character on the far side of the panel."""
    # The moon sits high so its top half stays clear; the sleigh crosses its
    # lower half and the runner reads as a silhouette against the disc.
    c.sprite(MOON, 172, 4, legend = LEG)
    c.sprite(DEER, 153, 8, legend = LEG)
    c.sprite(DEER, 160, 7, legend = LEG)
    c.sprite(SLEIGH, 167, 7, legend = LEG)
    # reins: lead deer to second deer, second deer to the sleigh
    c.pixel(160, 10, LEG["n"])
    c.pixel(167, 10, LEG["n"])

def village(c):
    """A lit cottage with smoke from the chimney, a snow-tipped pine and a
    present left on the doorstep, all standing on the snow."""
    c.sprite(COTTAGE, 154, 19, legend = LEG)
    # smoke: one clear row above the chimney (y 20), drifting up and right,
    # stopping short of the second reindeer's hooves at y 12.
    c.pixel(164, 18, LEG["c"])
    c.pixel(165, 16, LEG["c"])
    c.pixel(164, 14, LEG["c"])
    c.sprite(PINE, 170, 20, legend = LEG)
    c.sprite(GIFT, 179, 24, legend = {"R": LEG["B"], "Y": LEG["Y"]})

def hero(c, who):
    art = HEROES[who] if who in HEROES else TREE
    c.sprite(art, HEROX, 6, legend = LEG)

# Snow in the air: (x, y, big). Every slot keeps a clear column from the text
# zone (x 35..151) and from every sprite, whichever hero is chosen, and a
# different two-thirds of them light each day so the flurry drifts between
# refreshes without ever landing on anything.
#   x 32 is the gap between the hero (ends x 30) and the number (starts x 35);
#   a big flake there spans x 31..33, one column clear of both.
#   x 153 is the gap past the label; y 16 sits under the lead reindeer (ends
#   y 13) and above the cottage (starts y 19).
FLAKES = [
    (32, 8, 1), (32, 17, 0), (32, 24, 1),
    (153, 16, 0), (169, 16, 1), (157, 16, 0),
    (178, 19, 0), (181, 17, 0), (183, 21, 0),
]

def flurry(c, seed):
    for i in range(len(FLAKES)):
        if (i + seed) % 3 == 0:
            continue
        f = FLAKES[i]
        if f[2] == 1:
            c.sprite(FLAKE, f[0] - 1, f[1] - 1, legend = LEG)
        else:
            c.pixel(f[0], f[1], SNOW2)

# ---- the page ----------------------------------------------------------------
def countdown(c, ctx):
    c.fill("black")
    who = str(ctx.inputs.get("hero", "TREE")).strip().upper()
    unit = str(ctx.inputs.get("unit", "SLEEPS")).strip().upper()
    accent = ctx.inputs.get("accent", "#FF2A2A")

    n = sleeps_left(ctx)

    snow(c)
    lights(c)
    moon_and_sleigh(c)
    village(c)
    hero(c, who)
    flurry(c, n)

    cx = (ZONEL + ZONER) // 2

    # Christmas morning: the count steps aside for the greeting. 6x8 over 9x12
    # is 8 + 2 + 12 = 22 rows, which is the whole band between bulbs and snow.
    if n == 0:
        c.text("MERRY", cx, 6, font = "6x8", color = GREEN, align = "center")
        c.text("CHRISTMAS", cx, 16, font = "9x12", color = accent, align = "center")
        return

    # Number first, then the two-line label to its right. Everything is
    # measured so the block centers in the zone at any count: "364" is 50 px at
    # 16x20, CHRISTMAS is 62 px at 6x8, and with a 4 px gap that is 116 of the
    # zone's 117 px. Two digits leave 9 px each side.
    numstr = str(n)
    numw = c.text_width(numstr, "16x20")
    if unit == "DAYS":
        word = "DAY" if n == 1 else "DAYS"
    else:
        word = "SLEEP" if n == 1 else "SLEEPS"
    top = word + " TIL"
    labw = c.text_width("CHRISTMAS", "6x8")
    x0 = cx - (numw + 4 + labw) // 2
    lx = x0 + numw + 4

    c.text(numstr, x0, 6, font = "16x20", color = "white")
    c.text(top, lx, 9, font = "4x5", color = LABEL)
    c.text("CHRISTMAS", lx, 16, font = "6x8", color = accent)
