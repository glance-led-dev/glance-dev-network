# Event Milestone - how long since something happened, or how long until it
# does. (192x32)
#
# Up to three events, taking turns. Two levels:
#
#   upper   DAYS SINCE <EVENT>                          [event date]
#   lower   [theme art]  <count> DAYS               [month][week][day] lamps
#
# A date in the future counts DOWN and the head reads DAYS TO instead. The
# direction lives in the title only: underneath, a countdown is just a number
# of days, so it takes the same unit and the same colour as a count up. Saying
# it twice -- "DAYS TO WEDDING" over "114 DAYS AWAY" -- reads as a warning
# rather than a countdown. Today keeps the SINCE head and shows TODAY.
#
# Because a future date is a supported case, the date inputs are declared
# `date` and not `date-past`: date-past caps the picker at today, which would
# put the whole countdown half of the app out of reach.
#
# Everything runs from the left edge of the safe zone: the art at PAD, the
# number after it, the unit after that. The count takes the largest face that
# still clears the lamps, and the ladder drops it a size for a number long
# enough to need the room.
#
# Vertically the count is CENTRED in the band and the unit sits on its
# baseline -- not hung from BAND with the unit on its own centre, which put the
# number one row under the title with eight dead rows beneath it and left
# "DAYS" floating two rows low. See HERO_FONTS and ink_height().
#
# Forty themes share one 24x24 sprite slot; see ART and draw_theme().
#
# The three lamps under the date are the anniversary at a glance, as a strict
# cascade: orange for the whole of the event's month, green once the
# anniversary is in this Monday-to-Sunday week, navy on the day itself. Each
# narrows the one before it, so the lit run always starts at the left and its
# LENGTH is the reading. Off is drawn as an outline, not left blank -- see
# marks() and lamp_states().
#
# Up to five events rotate, time-multiplexed inside one page rather than split
# across manifest pages, because `pages` is a fixed list: five pages would take
# five turns in the scroll whether or not the user filled in five events.
# Frames rotate over the events that actually exist -- see slots().
#
# Colour is the user's: each slot carries its own `numcolor` for the count,
# and one `accent` dresses the rail. Both are drawn on the near-black ground,
# so both go through lift().
#
# Pure date arithmetic from ctx.now. Nothing is fetched, so there is no stale
# or empty screen to design around -- only a date the user has not set yet.
#
# Chrome follows the scroll house kit (github-pulse-scroll): an accent rail and
# a measured content band. This app plays between two others in the scroll
# sequence, so nothing is drawn outside x PAD..c.width-1-PAD.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

DIGITS = "0123456789"
HEXCHARS = "0123456789ABCDEF"

INK = "#08090D"          # near-black ground, per the contrast rule
DIM = "#5E5E7A"          # the date under the title
MID = "#9A9AB8"          # secondary rows
STRUCT = "#1E2030"       # the unlit lamps

PAD = 8                  # scroll safe zone: neighbours slide past the edges
BAND = 8                 # lower level starts here, below the title row
ROTATE_EVERY = 60        # seconds one event holds the panel before the next

# The anniversary lamps: three 5x5 blocks, 4px apart, right-aligned under the
# date. 5 + 4 + 5 + 4 + 5 = 23 wide, ending at c.width-1-PAD (see marks_x).
# Left to right they narrow: the month, the week, then the day itself.
MONTH_ON = "#E87722"     # orange: today is in the event's month
WEEK_ON = "#3FA34D"      # green:  the anniversary falls in this week
DAY_ON = "#2160AF"       # navy:   today is the anniversary itself
#
# MONTH_ON is the brand orange exactly. DAY_ON is NOT the brand navy #0C2340,
# which cannot be used here: its luminance is 31 against a ground of 9 and an
# unlit outline of 33, so it renders darker than an unlit lamp and reads
# inverted. #2160AF is that same navy at a brightness the panel can show --
# the channel ratios are 0.19:0.55:1.00 either way, so it is the same hue,
# lifted, not a different colour.
MARKS_Y = 8

# The count block. 16x24 is deliberately NOT in the ladder: it is exactly as
# tall as the band, so it lands one row under the title with nothing below,
# which reads top-heavy. Capping at 16x20 leaves two rows of air either side
# once the ink is centred. The gaps are 6 rather than 8 to buy back the three
# pixels that were pushing a five-digit count down to 10x16.
HERO_FONTS = ["16x20", "10x16", "8x12"]
UNIT_FONT = "6x8"        # not 8x12: see the note on LAMP_SPAN
ART_GAP = 6              # art to number
UNIT_GAP = 6             # number to unit
CLEAR = 4                # unit to the lamps
LAMP_SPAN = 23           # three 5x5 lamps, 4px apart
#
# The third lamp costs the count 9px of width, which is exactly enough to push
# a five-digit figure off 16x20 and down to 10x16. The unit gives that back
# instead: "DAYS" is 35px at 8x12 and 27px at 6x8, and the number is the hero
# -- shrinking the label it is already sitting next to costs far less than
# shrinking the figure itself.

# Ink heights, since Starlark cannot measure a glyph. Verified against
# gdn/data/fonts.json: for every face here the ink fills the full box, so
# these are the box heights -- but the number is what the layout centres on,
# so it is named rather than assumed.
FONT_INK = {"16x20": 20, "10x16": 16, "8x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}


def ink_height(font):
    return FONT_INK.get(font, 8)


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm).

    Subtracting two of these is an exact day count. A (year diff * 365)
    approximation drifts by a day for every Feb 29 in between, which for an
    event a few decades back is a visibly wrong number.
    """
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)


def month_days(y, m):
    if m == 2:
        return 29 if is_leap(y) else 28
    return [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]


def parse_date(s):
    """A date setting -> [y, m, d], or None when it is unusable.

    Starlark has no exceptions, so the value is checked by hand before it is
    used. The picker sends a full ISO stamp and it does not arrive intact: the
    render descriptor is colon-separated at the top level
    (GDN:W:H:app:pages:ttl:inputs), so the time's own colons end the value and
    it is cut at the first one -- "1969-07-20T01:12:57.000Z" is delivered as
    "1969-07-20T01".

    Reducing to digits and taking the first eight accepts the full stamp, that
    truncated form, and a plain YYYY-MM-DD alike. The day always survives the
    cut because it sits before the "T".
    """
    ds = ""
    t = str(s)
    for i in range(len(t)):
        if DIGITS.find(t[i]) >= 0:
            ds = ds + t[i]
    if len(ds) < 8:
        return None

    y = int(ds[0:4])
    m = int(ds[4:6])
    d = int(ds[6:8])
    if y < 1000 or m < 1 or m > 12 or d < 1 or d > month_days(y, m):
        return None
    return [y, m, d]


def _hexval(ch):
    return HEXCHARS.find(ch.upper())


# ----------------------------------------------------------------- pixel art
# Authored at 24x24 -- the icon module the layout grammar already uses, and
# the full height of the lower level.
#
# The first cut was 12x12 drawn at scale 2, on the theory that chunky reads
# better at 30 feet. At that size a mortarboard is a white blob over a box and
# the ring is an oval with a dot: the shapes stopped being recognisable long
# before the pixels stopped being visible. Same footprint, four times the
# detail, and the panel resolves 1px strokes fine -- the fonts are 1px.
#
# The bundled icon set is 8x8 one-bit shapes -- its ring is an outline circle,
# a washer rather than a wedding ring -- and has nothing for most of these, so
# all forty themes are drawn here instead, in colour and to one style.
#
# They were authored with a small generator that draws into a 24x24 char grid
# from primitives -- discs, swept polygons, half-ellipse domes -- rather than
# by counting dots by hand, and it asserts every sprite is 24x24 with no
# character missing from its legend before emitting. What ships is the emitted
# array; the generator is dev scaffolding and lives outside the repo.

RING = [
    "........................",
    "..........GGGG..........",
    ".........G....G.........",
    "........G......G........",
    ".........G....G.........",
    "..........G..G..........",
    "...........GG...........",
    "........########........",
    "......##........##......",
    ".....#............#.....",
    "....#..............#....",
    "....#..............#....",
    "...#................#...",
    "...#................#...",
    "...#................#...",
    "...#................#...",
    "....#..............#....",
    "....#..............#....",
    ".....#............#.....",
    "......##........##......",
    "........########........",
    "........................",
    "........................",
    "........................",
]

CAKE = [
    ".......F..F..F..........",
    ".......C..C..C..........",
    ".......C..C..C..........",
    ".......TTTTTTTTTT.......",
    "......TTTTTTTTTTTT......",
    "......TTTTTTTTTTTT......",
    "......##########SS......",
    "......##########SS......",
    "......##########SS......",
    "......##########SS......",
    "....TTTTTTTTTTTTTTTT....",
    "...TTTTTTTTTTTTTTTTTT...",
    "...TTTTTTTTTTTTTTTTTT...",
    "...################SS...",
    "...################SS...",
    "...################SS...",
    "...################SS...",
    "...################SS...",
    "...################SS...",
    "..PPPPPPPPPPPPPPPPPPPP..",
    "..PPPPPPPPPPPPPPPPPPPP..",
    "........................",
    "........................",
    "........................",
]


CAP = [
    "........................",
    "........................",
    "...........##...........",
    ".........######.........",
    ".......##########.......",
    ".....##############.....",
    "...##################...",
    ".######################.",
    "...##################..T",
    ".....##############....T",
    ".......##########......T",
    ".......#........#......T",
    ".......#........#......T",
    ".......#........#......T",
    ".......#........#....TTT",
    ".......#........#....TTT",
    ".......#........#....TTT",
    ".......##......##.......",
    "........########........",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
]


# A legend value of None turns that character off, so one art string can carry
# detail that a single-colour draw simply drops.
RING_LEGEND = {"G": "#FFFFFF", "#": "#E8C44A"}
CAKE_LEGEND = {"F": "#FFB020", "C": "#FFF6E0", "T": "#FFF0F5",
               "#": "#E85AA8", "S": "#A8306E", "P": "#C9CCD8"}
CAP_LEGEND = {"#": "#F2F2F8", "T": "#E8C44A"}

HOUSE = [
    "........................",
    "............R...........",
    "...........RRR..........",
    "..........RRRRR.........",
    ".........RRRRRRR........",
    "........RRRRRRRRR.......",
    "......RRRRRRRRRRRRR.....",
    ".....RRRRRRRRRRRRRRR....",
    "....RRRRRRRRRRRRRRRRR...",
    "...RRRRRRRRRRRRRRRRRRR..",
    "........................",
    "....WWWWWWWWWWWWWWWW....",
    "....WWWWWWWWWWWWWWWW....",
    "....WWGGGGWWWWGGGGWW....",
    "....WWGGGGWWWWGGGGWW....",
    "....WWGGGGWWWWGGGGWW....",
    "....WWWWWWDDDDWWWWWW....",
    "....WWWWWWDDDDWWWWWW....",
    "....WWWWWWDDDDWWWWWW....",
    "....WWWWWWDDDDWWWWWW....",
    "....WWWWWWDDDDWWWWWW....",
    "........................",
    "........................",
    "........................",
]

HOUSE_LEGEND = {"D": "#8B5A2B", "G": "#6FB7E8", "R": "#C0392B", "W": "#E8D8B0"}

CAR = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "......BBBBBBBBBBB.......",
    ".....BBGGGGGGGGGBB......",
    ".....BBGGGGGGGGGBB......",
    "....BBBGGGGGGGGGBBB.....",
    "....BBBGGGGGGGGGBBB.....",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBKKKBBBBBBBBKKKBBBB.",
    ".BBBKKKKKBBBBBBKKKKKBBB.",
    ".BBKKKKKKKBBBBKKKKKKKBB.",
    "...KKKSKKK....KKKSKKK...",
    "...KKKKKKK....KKKKKKK...",
    "....KKKKK......KKKKK....",
    ".....KKK........KKK.....",
    "........................",
    "........................",
    "........................",
]

CAR_LEGEND = {"B": "#E03A3A", "G": "#9FD4F5", "K": "#3A3A44", "S": "#C9CCD8"}

BICYCLE = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "................HHHH....",
    ".........SSSS.....H.....",
    "..........FFFFF...H.....",
    ".........F.F...F..H.....",
    "....WWW..F..F..F.WHW....",
    "..WWWWWWF....F.WFWHWWW..",
    ".WWWW.WFWW....FFFWHWWWW.",
    ".WW...F.WW....WWFFH..WW.",
    "WWW...F.WWW..WWW.FH..WWW",
    "WW...F...WW..WW...H...WW",
    "WWW.....WWW..WWW.....WWW",
    ".WW.....WW....WW.....WW.",
    ".WWWW.WWWW....WWWW.WWWW.",
    "..WWWWWWW......WWWWWWW..",
    "....WWW..........WWW....",
    "........................",
    "........................",
    "........................",
]

BICYCLE_LEGEND = {"F": "#4EA8FF", "H": "#C9CCD8",
                   "S": "#8B5A2B", "W": "#C9CCD8"}

YACHT = [
    "........................",
    "........................",
    "............M...........",
    "...........SM...........",
    "..........SSM...........",
    "..........SSMS..........",
    ".........SSSMSS.........",
    "........SSSSMSSS........",
    ".......SSSSSMSSS........",
    ".......SSSSSMSSSS.......",
    "......SSSSSSMSSSSS......",
    ".....SSSSSSSMSSSSSS.....",
    "....SSSSSSSSMSSSSSS.....",
    "....SSSSSSSSMSSSSSSS....",
    "............M...........",
    "............M...........",
    "..HHHHHHHHHHHHHHHHHHHHH.",
    "...HHHHHHHHHHHHHHHHHHH..",
    "....HHHHHHHHHHHHHHHHH...",
    "....HHHHHHHHHHHHHHHH....",
    "........................",
    "........................",
    "WWWWWWWWWWWWWWWWWWWWWWWW",
    "........................",
]

YACHT_LEGEND = {"H": "#E03A3A", "M": "#9A9AB8", "S": "#FFFFFF", "W": "#2160AF"}

DEPART = [
    "........................",
    "........................",
    "........................",
    "......BB................",
    "......BBB...........A...",
    ".......BBB.........AAA..",
    ".......BBBB.......AAAAA.",
    "..BB....BBBB.......AAA..",
    "..BBB....BBBB......AAA..",
    "BBBBBBBBBBBBBBBB...AAA..",
    "BBBBBBBBBBBBBBBBB..AAA..",
    "BBBBBBBBBBBBBBBB...AAA..",
    "..BBB....BBBB...........",
    "..BB....BBBB............",
    ".......BBBB.............",
    ".......BBB..............",
    "......BBB...............",
    "......BB................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
]

DEPART_LEGEND = {"A": "#3FA34D", "B": "#E8E8F0"}

ARRIVE = [
    "........................",
    "........................",
    "........................",
    "......BB................",
    "......BBB..........AAA..",
    ".......BBB.........AAA..",
    ".......BBBB........AAA..",
    "..BB....BBBB.......AAA..",
    "..BBB....BBBB......AAA..",
    "BBBBBBBBBBBBBBBB..AAAAA.",
    "BBBBBBBBBBBBBBBBB..AAA..",
    "BBBBBBBBBBBBBBBB....A...",
    "..BBB....BBBB...........",
    "..BB....BBBB............",
    ".......BBBB.............",
    ".......BBB..............",
    "......BBB...............",
    "......BB................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
]

ARRIVE_LEGEND = {"A": "#4EA8FF", "B": "#E8E8F0"}

TREE = [
    "........................",
    "........................",
    "...........LLL..........",
    ".........LLLLLLL........",
    "........LLLLLLLLL.......",
    ".......LLLLLLLLLLL......",
    ".......LLLLLLLLLLL......",
    "......LLLLLLLLLLLLL.....",
    "......LLLLLLLLLLLLL.....",
    "....LLLLLLLLLLLLLLLLL...",
    "....LLLLLLLLLLLLLLLLL...",
    "...LLLLLLLLLLLLLLLLLLL..",
    "...LLLLLLLLLLLLLLLLLLL..",
    "...LLLLLLLLLLLLLLLLLLL..",
    "....LLLLLLLLLLLLLLLLL...",
    "....LLLLLLLTTTLLLLLLL...",
    "......LLL..TTT..LLL.....",
    "...........TTT..........",
    "...........TTT..........",
    "...........TTT..........",
    "...........TTT..........",
    "...........TTT..........",
    "........................",
    "........................",
]

TREE_LEGEND = {"L": "#3FA34D", "T": "#8B5A2B"}

FLOWER = [
    "........................",
    "........................",
    "...........PPP..........",
    "..........PPPPP.........",
    ".........PPPPPPP........",
    ".......PPPPPPPPPPP......",
    "......PPPPPPPPPPPPP.....",
    ".....PPPPPPCCCPPPPPP....",
    ".....PPPPPCCCCCPPPPP....",
    ".....PPPPPCCCCCPPPPP....",
    "......PPPPCCCCCPPPP.....",
    ".......PPPPCCCPPPP......",
    ".......PPPPPPPPPPP......",
    ".......PPPPPPPPPPP......",
    "........PPPPPPPPP.......",
    "......S..PPPSPPP........",
    "......SSSS..SS..........",
    "......SSSSSSSS..........",
    ".......SSSS.SS..........",
    "............SS..........",
    "............SS..........",
    "............SS..........",
    "............SS..........",
    "........................",
]

FLOWER_LEGEND = {"C": "#FFD24A", "P": "#E85AA8", "S": "#3FA34D"}

BEACH = [
    "........................",
    "........................",
    "........................",
    ".LL.....LL..............",
    ".LLL...LLL..............",
    "LLLLL.LLL...............",
    "LLLLLLLLLLLLL...........",
    "..LLLLLLLLLLL...........",
    "....LNLNL...............",
    "....TTLLLLL.............",
    "....TT..LLLL............",
    "....TTT...LL......H.....",
    ".....TT..........HHHH...",
    ".....TT..........HHH....",
    ".....TT.........HHHH....",
    ".....TT........HHHH.....",
    ".....TT.......HHHH......",
    ".....TTT......HHHHHHHHH.",
    "......TT.......HHHHHHHH.",
    "......TT.......H.....H..",
    "......TT................",
    "SSSSSSSSSSSSSSSSSSSSSSSS",
    "SSSSSSSSSSSSSSSSSSSSSSSS",
    "........................",
]

BEACH_LEGEND = {"H": "#E8B04A", "L": "#3FA34D", "N": "#6B4423",
                 "S": "#E8D8B0", "T": "#8B5A2B"}

MOUNTAINS = [
    "........................",
    "........................",
    "..................UUU...",
    ".................UUUUU..",
    "........W.......UUUUUUU.",
    ".......WWW......UUUUUUU.",
    ".......WWW......UUUUUUU.",
    "......WWWWW......UUUUU..",
    "......WWWWW.......UUU...",
    ".....MMMMMMM.....W......",
    ".....MMMMMMMM...WWW.....",
    "....MMMMMMMMM...WWW.....",
    "....MMMMMMMMMM.MMMMM....",
    "...MMMMMMMMMMMMMMMMM....",
    "...MMMMMMMMMMMMMMMMMM...",
    "..MMMMMMMMMMMMMMMMMMMM..",
    "..MMMMMMMMMMMMMMMMMMMM..",
    ".MMMMMMMMMMMMMMMMMMMMMM.",
    ".MMMMMMMMMMMMMMMMMMMMMM.",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
]

MOUNTAINS_LEGEND = {"M": "#6E7A94", "U": "#FFD24A", "W": "#FFFFFF"}

TORII = [
    "........................",
    "........................",
    "........................",
    "........................",
    "..RRRRRRRRRRRRRRRRRRRR..",
    "..RRDDDDDDDDDDDDDDDDRR..",
    "..RRRRRRRRRRRRRRRRRRRR..",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    "....RRRRRRRDDRRRRRRR....",
    "....RRRRRRRDDRRRRRRR....",
    "....RRRRRRRDDRRRRRRR....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    ".....RRRR......RRRR.....",
    "........................",
    "........................",
]

TORII_LEGEND = {"D": "#7A1F1F", "R": "#E03A3A"}

PAGODA = [
    "........................",
    "............R...........",
    "..........RRRRR.........",
    ".........RRRRRRR........",
    "........RRRRRRRRR.......",
    "........................",
    ".........BBBBBB.........",
    ".........BBBBBB.........",
    ".......RRRRRRRRRRR......",
    "......RRRRRRRRRRRRR.....",
    ".....RRRRRRRRRRRRRRR....",
    "....RRRRRRRRRRRRRRRRR...",
    "........................",
    ".......BBBBBBBBBB.......",
    ".......BBBBBBBBBB.......",
    "......RRRRRRRRRRRRR.....",
    ".....RRRRRRRRRRRRRRR....",
    "....RRRRRRRRRRRRRRRRR...",
    "..RRRRRRRRRRRRRRRRRRRRR.",
    "........................",
    "......BBBBDDDDBBBB......",
    "......BBBBDDDDBBBB......",
    "......BBBBDDDDBBBB......",
    "........................",
]

PAGODA_LEGEND = {"B": "#E8D8B0", "D": "#8B5A2B", "R": "#C0392B"}

HEART = [
    "........................",
    "........................",
    "........................",
    "........................",
    ".......RRR....RRR.......",
    ".....RRRRRRRRRRRRRR.....",
    ".....RRRRRRRRRRRRRR.....",
    "....RRRRRRRRRRRRRRRR....",
    "....RRRRRRRRRRRRRRRR....",
    "...RRRRRRRRRRRRRRRRRR...",
    "....RRRRRRRRRRRRRRRR....",
    "....RRRRRRRRRRRRRRRR....",
    ".....RRRRRRRRRRRRRR.....",
    "......RRRRRRRRRRRR......",
    ".......RRRRRRRRRRR......",
    "........RRRRRRRRR.......",
    "........RRRRRRRR........",
    ".........RRRRRRR........",
    "..........RRRRR.........",
    "..........RRRR..........",
    "...........RRR..........",
    "........................",
    "........................",
    "........................",
]

HEART_LEGEND = {"R": "#E0243C"}

COUPLE_MF = [
    "........................",
    "........................",
    "........................",
    "..HHHHHHHHH.....KKK.....",
    "..HHHHHHHHH....KKKKK....",
    "..HKKKKKKKH...KKKKKKK...",
    "..HKKKKKKKH...KKKKKKK...",
    "..HKKKKKKKH...KKKKKKK...",
    "..H.KKKKK.H....KKKKK....",
    "..H..KKK..H.....KKK.....",
    "..H..KKK..H.....KKK.....",
    ".....KKK........KKK.....",
    "...PPPPPPP....BBBBBBB...",
    "..PPPPPPPPP..BBBBBBBBB..",
    "..PPPPPPPPP..BBBBBBBBB..",
    ".PPPPPPPPPPPBBBBBBBBBBB.",
    ".PPPPPPPPPPPBBBBBBBBBBB.",
    ".PPPPPPPPPPPBBBBBBBBBBB.",
    ".PPPPPPPPPPPBBBBBBBBBBB.",
    ".PPPPPPPPPPPBBBBBBBBBBB.",
    ".PPPPPPPPPPPBBBBBBBBBBB.",
    "........................",
    "........................",
    "........................",
]

COUPLE_MF_LEGEND = {"B": "#4EA8FF", "H": "#5A3A22", "K": "#F2C79A",
                     "P": "#E85AA8"}

COUPLE_MM = [
    "........................",
    "........................",
    "........................",
    ".....KKK........KKK.....",
    "....KKKKK......KKKKK....",
    "...KKKKKKK....KKKKKKK...",
    "...KKKKKKK....KKKKKKK...",
    "...KKKKKKK....KKKKKKK...",
    "....KKKKK......KKKKK....",
    ".....KKK........KKK.....",
    ".....KKK........KKK.....",
    ".....KKK........KKK.....",
    "...BBBBBBB....BBBBBBB...",
    "..BBBBBBBBB..BBBBBBBBB..",
    "..BBBBBBBBB..BBBBBBBBB..",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    ".BBBBBBBBBBBBBBBBBBBBBB.",
    "........................",
    "........................",
    "........................",
]

COUPLE_MM_LEGEND = {"B": "#4EA8FF", "K": "#F2C79A"}

COUPLE_FF = [
    "........................",
    "........................",
    "........................",
    "..HHHHHHHHH..HHHHHHHHH..",
    "..HHHHHHHHH..HHHHHHHHH..",
    "..HKKKKKKKH..HKKKKKKKH..",
    "..HKKKKKKKH..HKKKKKKKH..",
    "..HKKKKKKKH..HKKKKKKKH..",
    "..H.KKKKK.H..H.KKKKK.H..",
    "..H..KKK..H..H..KKK..H..",
    "..H..KKK..H..H..KKK..H..",
    ".....KKK........KKK.....",
    "...PPPPPPP....PPPPPPP...",
    "..PPPPPPPPP..PPPPPPPPP..",
    "..PPPPPPPPP..PPPPPPPPP..",
    ".PPPPPPPPPPPPPPPPPPPPPP.",
    ".PPPPPPPPPPPPPPPPPPPPPP.",
    ".PPPPPPPPPPPPPPPPPPPPPP.",
    ".PPPPPPPPPPPPPPPPPPPPPP.",
    ".PPPPPPPPPPPPPPPPPPPPPP.",
    ".PPPPPPPPPPPPPPPPPPPPPP.",
    "........................",
    "........................",
    "........................",
]

COUPLE_FF_LEGEND = {"H": "#5A3A22", "K": "#F2C79A", "P": "#E85AA8"}

GIRL = [
    "........HHHHHHHHH.......",
    "........HHHHHHHHH.......",
    "..........KKKKK.........",
    "........HKKKKKKKH.......",
    "........HKKKKKKKH.......",
    "........HKKKKKKKH.......",
    "........H.KKKKK.H.......",
    "...........KKK..........",
    "..........PPPPP.........",
    "........PPPPPPPPP.......",
    "........PPPPPPPPP.......",
    "........PPPPPPPPP.......",
    "........PPPPPPPPP.......",
    "........PPPPPPPPP.......",
    "..........PPPPP.........",
    ".........PPPPPPP........",
    ".........PPPPPPP........",
    "........PPPPPPPPP.......",
    "........................",
    "..........KK.KK.........",
    "..........KK.KK.........",
    "..........KK.KK.........",
    "........................",
    "........................",
]

GIRL_LEGEND = {"H": "#5A3A22", "K": "#F2C79A", "P": "#E85AA8"}

BOY = [
    "........................",
    "...........KKK..........",
    "..........KKKKK.........",
    ".........KKKKKKK........",
    ".........KKKKKKK........",
    ".........KKKKKKK........",
    "..........KKKKK.........",
    "...........KKK..........",
    "..........BBBBB.........",
    "........BBBBBBBBB.......",
    "........BBBBBBBBB.......",
    "........BBBBBBBBB.......",
    "........BBBBBBBBB.......",
    "........BBBBBBBBB.......",
    "..........BBBBB.........",
    "..........BB.BB.........",
    "..........BB.BB.........",
    "..........BB.BB.........",
    "..........BB.BB.........",
    "..........BB.BB.........",
    "..........BB.BB.........",
    "..........BB.BB.........",
    "........................",
    "........................",
]

BOY_LEGEND = {"B": "#4EA8FF", "K": "#F2C79A"}

CAMPFIRE = [
    "........................",
    "........................",
    "........................",
    "............F...........",
    "...........FFF..........",
    "...........FFF..........",
    "..........FFFFF.........",
    "..........FFYFF.........",
    ".........FFYYYFF........",
    ".........FFYYYFF........",
    "........FFYYYYYFF.......",
    "........FFYYYYYFF.......",
    ".......FFYYYYYYYFF......",
    ".........FYYYYYF........",
    "..........FFFFF.........",
    "........................",
    "........................",
    "...LLLL...........LLLL..",
    "...LLLLLLLLLLLLLLLLLLL..",
    "......LLLLLLLLLLLLL.....",
    "...LLLLLLLLLLLLLLLLLLL..",
    "...LLLL...........LLLL..",
    "........................",
    "........................",
]

CAMPFIRE_LEGEND = {"F": "#FF6A1E", "L": "#8B5A2B", "Y": "#FFD24A"}

HELICOPTER = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "..SSSSSSSSSSSSSSSSSSSSS.",
    "..SSSSSSSSSSSSSSSSSSSSS.",
    "...........SS...........",
    "........BBBSS.......BB..",
    "......BBBBBBB.......BB..",
    ".....BBBBBBBBB......BB..",
    ".....WWWWWWWBB......BB..",
    "....BWWWWWWWBBBBBBBBBBB.",
    "....WWWWWWWWBBBBBBBBBBB.",
    "....WWWWWWWWBBBBBBBBBBB.",
    ".....BBBBBBBBB..........",
    ".....BBBBBBBBB..........",
    "......BSBBBBS...........",
    "......SSSSSSSSS.........",
    "......SSSSSSSSS.........",
    "........................",
    "........................",
    "........................",
    "........................",
]

HELICOPTER_LEGEND = {"B": "#4EA8FF", "S": "#C9CCD8", "W": "#9FD4F5"}

PARAGLIDER = [
    "........................",
    "........................",
    "........................",
    ".........YYYGGGG........",
    "......OOOYYYGGGGBBB.....",
    ".....OOOOYYYGGGGBBBB....",
    "...RROOOOYYYGGGGBBBBVV..",
    "...RROOOOYYYGGGGBBBBVV..",
    "..RRROOOOYYYGGGGBBBBVVV.",
    "..RRROOOOYYYGGGGBBBBVVV.",
    "..RRROOOOYYYGGGGBBBBVVV.",
    "..SRROOOSYYYGGGGSBBBVVS.",
    "...S....S.......S....S..",
    "....S....S.....S....S...",
    ".....S...S.....S...S....",
    "......S...S...S...S.....",
    ".......SS.S...S.SS......",
    ".........S.S.S.S........",
    "..........SS.SS.........",
    "...........SSS..........",
    "............S...........",
    "........................",
    "........................",
    "........................",
]

PARAGLIDER_LEGEND = {"B": "#4EA8FF", "G": "#3FA34D", "O": "#FF8A1E",
                      "R": "#E0243C", "S": "#9A9AB8", "V": "#9B59B6",
                      "Y": "#FFD24A"}

FISHING = [
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..................S.....",
    "..........F....S..S.....",
    ".........FFF....SS......",
    ".........FFF............",
    "F......FFFFFF...........",
    "FF...FFFFFFFFF..........",
    ".FFFFFFFFFFFFEF.........",
    ".FFFFFFFFFFFFFFF........",
    ".FFFFFFFFFFFFFF.........",
    "FF.FFFFFFFFFFFF.........",
    ".....FFFFFFFFF..........",
    "........................",
    "........................",
]

FISHING_LEGEND = {"E": "#08090D", "F": "#4EA8FF", "S": "#C9CCD8"}

RUNNER = [
    "........................",
    "...............KKK......",
    "..............KKKKK.....",
    ".............KKKKKKK....",
    ".............KKKKKKK....",
    ".............KKKKKKK....",
    "..............KKKKK.....",
    "...............KKK..BB..",
    "...........BBBBBBB..BB..",
    "...........BBBBBBB..BB..",
    "..........BBBBBBBBBBBBB.",
    "........BBBBBBBBBBBBBBB.",
    "......BBBBBBBBBBB..BBBB.",
    "......BBB.BBBBBBB....BB.",
    "......BB..BBBBBBB.......",
    "......BBB..BB.BBB.......",
    ".......BB.BBB.BBBBB.....",
    ".......BB.BB....BBBBB...",
    ".......BBBBB......BBB...",
    "......BBBBB........BB...",
    "..BBBBBBBB........BBB...",
    "..BBBBB...........BB....",
    "..................BB....",
    "..................BB....",
]

RUNNER_LEGEND = {"B": "#FF8A1E", "K": "#F2C79A"}

GOLD = [
    "........................",
    ".......AAAAA.CCCCC......",
    ".......AAAAA.CCCCC......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    ".........AACCCCC........",
    "...........MMM..........",
    ".........MMMMMMM........",
    "........MMMHHHMMM.......",
    ".......MMHHHHHHHMM......",
    ".......MMHHHHHHHMM......",
    "......MMHHHHHHHHHMM.....",
    "......MMHHHHHHHHHMM.....",
    "......MMHHHHHHHHHMM.....",
    ".......MMHHHHHHHMM......",
    ".......MMHHHHHHHMM......",
    "........MMMHHHMMM.......",
    ".........MMMMMMM........",
    "...........MMM..........",
    "........................",
    "........................",
]

GOLD_LEGEND = {"A": "#E0243C", "C": "#4EA8FF", "H": "#E0A81E", "M": "#FFD24A"}

SILVER = [
    "........................",
    ".......AAAAA.CCCCC......",
    ".......AAAAA.CCCCC......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    ".........AACCCCC........",
    "...........MMM..........",
    ".........MMMMMMM........",
    "........MMMHHHMMM.......",
    ".......MMHHHHHHHMM......",
    ".......MMHHHHHHHMM......",
    "......MMHHHHHHHHHMM.....",
    "......MMHHHHHHHHHMM.....",
    "......MMHHHHHHHHHMM.....",
    ".......MMHHHHHHHMM......",
    ".......MMHHHHHHHMM......",
    "........MMMHHHMMM.......",
    ".........MMMMMMM........",
    "...........MMM..........",
    "........................",
    "........................",
]

SILVER_LEGEND = {"A": "#E0243C", "C": "#4EA8FF", "H": "#A8AEC0", "M": "#D8DCE8"}

BRONZE = [
    "........................",
    ".......AAAAA.CCCCC......",
    ".......AAAAA.CCCCC......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    "........AAAACCCCC.......",
    ".........AACCCCC........",
    "...........MMM..........",
    ".........MMMMMMM........",
    "........MMMHHHMMM.......",
    ".......MMHHHHHHHMM......",
    ".......MMHHHHHHHMM......",
    "......MMHHHHHHHHHMM.....",
    "......MMHHHHHHHHHMM.....",
    "......MMHHHHHHHHHMM.....",
    ".......MMHHHHHHHMM......",
    ".......MMHHHHHHHMM......",
    "........MMMHHHMMM.......",
    ".........MMMMMMM........",
    "...........MMM..........",
    "........................",
    "........................",
]

BRONZE_LEGEND = {"A": "#E0243C", "C": "#4EA8FF", "H": "#9C5F22", "M": "#CD7F32"}

SOCCER = [
    "........................",
    "...........KKK..........",
    "..........KKKKK.........",
    "..........KKKKK.........",
    "........WWKKKKKWW.......",
    "......WWWWWKKKWWWWW.....",
    ".....WWWWWWWWWWWWWWW....",
    ".....WWWWWWWKWWWWWWW....",
    "....WWWWWWWKKKWWWWWWW...",
    "...KKKWWWKKKKKKKWWWKKK..",
    "..KKKKKWKKKKKKKKKWKKKKK.",
    "..KKKKKWKKKKKKKKKWKKKKK.",
    "..KKKKKWKKKKKKKKKWKKKKK.",
    "...KKKWWWKKKKKKKWWWKKK..",
    "...WWWWWWKKKKKKKWWWWWW..",
    "....WWWWWWWWWWWWWWWWW...",
    "....WWWWWWWWWWWWWWWWW...",
    ".....WWWWWWWWWWWWWWW....",
    ".....WKKKWWWWWWWKKKW....",
    ".....KKKKKWWWWWKKKKK....",
    ".....KKKKKWWWWWKKKKK....",
    ".....KKKKKWWWWWKKKKK....",
    "......KKK.......KKK.....",
    "........................",
]

SOCCER_LEGEND = {"K": "#22242E", "W": "#F2F2F8"}

FOOTBALL = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "..........BBBBB.........",
    "........BBBBBBBBB.......",
    "......BBBBBBBBBBBBB.....",
    "....BBBBBBBBBBBBBBBBB...",
    "...BBBBBBWBWBWBWBBBBBB..",
    "..BBBBBBBWBWBWBWBBBBBBB.",
    "..BBBBBBWWWWWWWWWBBBBBB.",
    "..BBBBBBBWBWBWBWBBBBBBB.",
    "...BBBBBBWBWBWBWBBBBBB..",
    "....BBBBBBBBBBBBBBBBB...",
    "......BBBBBBBBBBBBB.....",
    "........BBBBBBBBB.......",
    "..........BBBBB.........",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
]

FOOTBALL_LEGEND = {"B": "#8B4513", "W": "#F2F2F8"}

BASKETBALL = [
    "........................",
    "........................",
    "........................",
    "..........OOKOO.........",
    ".....K..OOOOKOOOO..K....",
    "......KOOOOOKOOOOOK.....",
    ".....OKOOOOOKOOOOOKO....",
    ".....OOKOOOOKOOOOKOO....",
    "....OOOOKOOOKOOOKOOOO...",
    "....OOOOKOOOKOOOKOOOO...",
    "...OOOOOOKOOKOOKOOOOOO..",
    "...OOOOOOKOOKOOKOOOOOO..",
    "...KKKKKKKKKKKKKKKKKKK..",
    "...OOOOOOKOOKOOKOOOOOO..",
    "...OOOOOOKOOKOOKOOOOOO..",
    "....OOOOKOOOKOOOKOOOO...",
    "....OOOOKOOOKOOOKOOOO...",
    ".....OOKOOOOKOOOOKOO....",
    ".....OOKOOOOKOOOOKOO....",
    "......KOOOOOKOOOOOK.....",
    ".....K..OOOOKOOOO..K....",
    "..........OOKOO.........",
    "........................",
    "........................",
]

BASKETBALL_LEGEND = {"K": "#22242E", "O": "#E8721E"}

BADMINTON = [
    "........................",
    "........................",
    "...WSWWWSWWWSWWWSWWWSW..",
    "...WSWWWSWWWSWWWSWWWSW..",
    "....WSWWSWWWSWWWSWWSW...",
    "....WSWWSWWWSWWSWWWSW...",
    ".....WSWWSWWSWWSWWSW....",
    ".....WSWWSWWSWWSWWSW....",
    "......SWWSWWSWWSWSW.....",
    "......WSWSWWSWSWWSW.....",
    ".......SWSWWSWSWSW......",
    ".......SWSWWSWSWSW......",
    "........SWSWSWSSW.......",
    "........SWSWSSWSW.......",
    ".........SSWSSSW........",
    ".........CCCCCCC........",
    ".........CCCCCCC........",
    ".........CCCCCCC........",
    ".........CCCCCCC........",
    ".........CCCCCCC........",
    ".........CCCCCCC........",
    "..........CCCCC.........",
    "...........CCC..........",
    "........................",
]

BADMINTON_LEGEND = {"C": "#D9A066", "S": "#C9CCD8", "W": "#F2F2F8"}

VOLLEYBALL = [
    "........................",
    "........................",
    "........................",
    "..........WWBWW.........",
    "........WWWWBWWWW.......",
    "......WWWWWWBWWWWWW.....",
    ".....WWWWWWWBWWWWWWW....",
    "....BWWWWWWWBWWWWWWW....",
    "....WBBBWWWWBWWWWWWWW...",
    "....WWWWBWWWBWWWWWWWB...",
    "...WWWWWWBBBBWWWWBBBWW..",
    "...WWWWWWWWWBWWWBWWWWW..",
    "...WWWWWWWWWBBBBWWWWWW..",
    "...WWWWWWWWWBWWWBWWWWW..",
    "...WWWWWWBBBBWWWWBBBWW..",
    "....WWWWBWWWBWWWWWWWB...",
    "....WBBBWWWWBWWWWWWWW...",
    "....BWWWWWWWBWWWWWWW....",
    ".....WWWWWWWBWWWWWWW....",
    "......WWWWWWBWWWWWW.....",
    "........WWWWBWWWW.......",
    "..........WWBWW.........",
    "........................",
    "........................",
]

VOLLEYBALL_LEGEND = {"B": "#2160AF", "W": "#F2F2F8"}

HOCKEY = [
    "........................",
    "........................",
    ".....TT.................",
    ".....TT.................",
    "......TT................",
    "......TT................",
    "......TT................",
    "......TT................",
    ".......TT...............",
    ".......TT...............",
    ".......TT...............",
    "........TT..............",
    "........TT..............",
    "........TT..............",
    "........TT..............",
    ".........TT.............",
    ".........TTTTTTTTTT.....",
    ".........TTTTTTTTTT.KKK.",
    ".........TTTTTTTTTTKKKKK",
    "...................KKKKK",
    "...................KKKKK",
    "IIIIIIIIIIIIIIIIIIIIIIII",
    "IIIIIIIIIIIIIIIIIIIIIIII",
    "........................",
]

HOCKEY_LEGEND = {"I": "#6FB7E8", "K": "#22242E", "T": "#C89A5A"}

SKIING = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    ".....................RR.",
    "........SSSSS.......RRR.",
    "........SSSSS.....RRRR..",
    "..RRRRRRRRRRRRRRRRRRR...",
    "..RRRRRRRRRRRRRRRRR.....",
    "........................",
    "........................",
    "........................",
    ".....................BB.",
    "........SSSSS.......BBB.",
    "........SSSSS.....BBBB..",
    "..BBBBBBBBBBBBBBBBBBB...",
    "..BBBBBBBBBBBBBBBBB.....",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
]

SKIING_LEGEND = {"B": "#4EA8FF", "R": "#E0243C", "S": "#C9CCD8"}

CHESS = [
    "........................",
    "...........WWW..........",
    "...........WWW..........",
    ".........WWWWWWW........",
    ".........WWWWWWW........",
    "...........WWW..........",
    "..........WWWWW.........",
    ".........WWWWWWW........",
    ".........WWWWWWW........",
    ".........WWWWWWW........",
    ".........WWWWWWW........",
    ".........WWWWWWW........",
    ".........WWWWWWW........",
    "........WDDDDDDDW.......",
    "........WDDDDDDDW.......",
    "........WWWWWWWWW.......",
    "........WWWWWWWWW.......",
    ".......WWWWWWWWWWW......",
    ".......WWWWWWWWWWW......",
    "........................",
    ".....WWWWWWWWWWWWWWW....",
    ".....WWWWWWWWWWWWWWW....",
    ".....WWWWWWWWWWWWWWW....",
    "........................",
]

CHESS_LEGEND = {"D": "#9A9AB8", "W": "#F2F2F8"}

GOLF = [
    "........................",
    "........................",
    "...............RS.......",
    ".............RRRS.......",
    "..........RRRRRRS.......",
    "........RRRRRRRRS.......",
    "......RRRRRRRRRRS.......",
    "........RRRRRRRRS.......",
    "..........RRRRRRS.......",
    ".............RRRS.......",
    "...............SS.......",
    "...............SS.......",
    "...............SS.......",
    "...............SS.......",
    "...............SS.......",
    "...............SS.......",
    "......WWW......SS.......",
    ".....WWWWW.....SS.......",
    ".....WWWWW.....SS.......",
    "..GGGWWWWWGGGGGGGGGGGGG.",
    "...GGGWWWGGGGGGGGGGGGG..",
    "....GGGGGGGGGGGGGGGG....",
    "........................",
    "........................",
]

GOLF_LEGEND = {"G": "#3FA34D", "R": "#E0243C", "S": "#C9CCD8", "W": "#F2F2F8"}

TROPHY = [
    "........................",
    "........................",
    "......MMMMMMMMMMMMM.....",
    "...MMMMMMMMMMMMMMMMMMM..",
    "..MMMMMMMMMMMMMMMMMMMMM.",
    ".MMM.MMMMMMMMMMMMMMM.MMM",
    ".MM...MMMMMMMMMMMMM...MM",
    ".MMM.MMMMMMMMMMMMMMM.MMM",
    "..MMMMMMMMMMMMMMMMMMMMM.",
    "...MMM.MMMMMMMMMMM.MMM..",
    "........MMMMMMMMM.......",
    "........MMMMMMMMM.......",
    "........................",
    "...........MMM..........",
    "...........MMM..........",
    "...........MMM..........",
    "...........MMM..........",
    ".......MMMMMMMMMMM......",
    ".......MMMMMMMMMMM......",
    ".......MMMMMMMMMMM......",
    ".....HHHHHHHHHHHHHHH....",
    ".....HHHHHHHHHHHHHHH....",
    ".....HHHHHHHHHHHHHHH....",
    "........................",
]

TROPHY_LEGEND = {"H": "#8B5A2B", "M": "#FFD24A"}

PODIUM = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........WWWWWWWW........",
    "........MMMMMMMM........",
    "........MMMMMMMM........",
    "........MMMMMMMM........",
    "........MMMMMMMM........",
    "........MMMMMMMM........",
    ".WWWWWWWMMMMMMMM........",
    ".SSSSSSSMMMMMMMM........",
    ".SSSSSSSMMMMMMMM........",
    ".SSSSSSSMMMMMMMMWWWWWWW.",
    ".SSSSSSSMMMMMMMMCCCCCCC.",
    ".SSSSSSSMMMMMMMMCCCCCCC.",
    ".SSSSSSSMMMMMMMMCCCCCCC.",
    ".SSSSSSSMMMMMMMMCCCCCCC.",
    ".SSSSSSSMMMMMMMMCCCCCCC.",
    ".SSSSSSSMMMMMMMMCCCCCCC.",
    ".SSSSSSSMMMMMMMMCCCCCCC.",
    "........................",
]

PODIUM_LEGEND = {"C": "#CD7F32", "M": "#FFD24A", "S": "#D8DCE8", "W": "#FFFFFF"}

# Every theme the dropdown offers, as [art, legend]. A dict rather than a
# chain of branches: fifteen themes is too many to read as elifs, and
# norm_theme() can validate a saved value straight against the keys.
ART = {
    "wedding": [RING, RING_LEGEND],
    "birthday": [CAKE, CAKE_LEGEND],
    "graduation": [CAP, CAP_LEGEND],
    "house": [HOUSE, HOUSE_LEGEND],
    "car": [CAR, CAR_LEGEND],
    "bicycle": [BICYCLE, BICYCLE_LEGEND],
    "yacht": [YACHT, YACHT_LEGEND],
    "departure": [DEPART, DEPART_LEGEND],
    "arrival": [ARRIVE, ARRIVE_LEGEND],
    "tree": [TREE, TREE_LEGEND],
    "flower": [FLOWER, FLOWER_LEGEND],
    "beach": [BEACH, BEACH_LEGEND],
    "mountains": [MOUNTAINS, MOUNTAINS_LEGEND],
    "torii gate": [TORII, TORII_LEGEND],
    "pagoda": [PAGODA, PAGODA_LEGEND],
    "heart": [HEART, HEART_LEGEND],
    "couple": [COUPLE_MF, COUPLE_MF_LEGEND],
    "couple blue": [COUPLE_MM, COUPLE_MM_LEGEND],
    "couple pink": [COUPLE_FF, COUPLE_FF_LEGEND],
    "girl": [GIRL, GIRL_LEGEND],
    "boy": [BOY, BOY_LEGEND],
    "campfire": [CAMPFIRE, CAMPFIRE_LEGEND],
    "helicopter": [HELICOPTER, HELICOPTER_LEGEND],
    "paraglider": [PARAGLIDER, PARAGLIDER_LEGEND],
    "fishing": [FISHING, FISHING_LEGEND],
    "running": [RUNNER, RUNNER_LEGEND],
    "gold medal": [GOLD, GOLD_LEGEND],
    "silver medal": [SILVER, SILVER_LEGEND],
    "bronze medal": [BRONZE, BRONZE_LEGEND],
    "soccer": [SOCCER, SOCCER_LEGEND],
    "football": [FOOTBALL, FOOTBALL_LEGEND],
    "basketball": [BASKETBALL, BASKETBALL_LEGEND],
    "badminton": [BADMINTON, BADMINTON_LEGEND],
    "volleyball": [VOLLEYBALL, VOLLEYBALL_LEGEND],
    "hockey": [HOCKEY, HOCKEY_LEGEND],
    "skiing": [SKIING, SKIING_LEGEND],
    "chess": [CHESS, CHESS_LEGEND],
    "golf": [GOLF, GOLF_LEGEND],
    "trophy": [TROPHY, TROPHY_LEGEND],
    "podium": [PODIUM, PODIUM_LEGEND],
}

SCALE = 1
ART_W = 24               # every theme is one 24x24 sprite


def norm_theme(value):
    """A theme setting, lowercased, against the themes that actually exist.

    The dropdown hands back the label as typed in the manifest ("Torii Gate"),
    but a value saved before a theme existed -- or before this input existed at
    all -- arrives as something not in ART, so the fallback has to be a real
    theme rather than an error state.
    """
    t = str(value).strip().lower()
    if t in ART:
        return t
    return "wedding"


def draw_theme(c, theme, x, y):
    """Draw the theme's art with its top-left at (x, y). Returns the x just
    past it, so the layout never hard-codes a width the art might change.
    """
    a = ART.get(theme, ART["wedding"])
    c.sprite(a[0], x, y, legend = a[1], scale = SCALE)
    return x + ART_W


def _hex2(v):
    return HEXCHARS[v // 16] + HEXCHARS[v % 16]


def lift(bg):
    """The accent, lightened until it reads as text on the near-black ground.

    The accent is the user's to choose and it is drawn on the near-black
    ground -- rail, eyebrow, progress bar -- so a dark pick disappears: a navy
    "#101044" rendered every one of those invisible. Anything below a
    luminance of 70 is scaled up to roughly 110, which keeps the hue the user
    chose and spends only the brightness needed to see it.
    """
    h = str(bg).replace("#", "")
    if len(h) != 6:
        return bg
    for i in range(6):
        if _hexval(h[i]) < 0:
            return bg
    r = _hexval(h[0]) * 16 + _hexval(h[1])
    g = _hexval(h[2]) * 16 + _hexval(h[3])
    b = _hexval(h[4]) * 16 + _hexval(h[5])
    lum = (299 * r + 587 * g + 114 * b) // 1000
    if lum >= 70:
        return bg
    if lum < 8:
        return "#8A8AA8"       # near-black accent has no hue worth keeping
    r = min(255, r * 110 // lum)
    g = min(255, g * 110 // lum)
    b = min(255, b * 110 // lum)
    return "#" + _hex2(r) + _hex2(g) + _hex2(b)


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw`. Nothing in the drawing API
    clips -- a glyph past the edge is silently dropped -- so an unbounded
    string is cut here, deliberately, before it is drawn."""
    s = str(text)
    if c.text_width(s, font) <= maxw:
        return s
    for n in range(len(s), 0, -1):
        if c.text_width(s[0:n], font) <= maxw:
            return s[0:n]
    return ""


def clip_words(c, text, font, maxw):
    """clip(), but backed up to the last whole word -- unless that costs more
    than 30% of what fit. An event called "THE DAY THE MUSIC DIED" cut to "THE
    DAY THE" has lost the words that identify it; an obviously-clipped "THE DAY
    THE MUSIC DIE" reads better than a tidy cut that says nothing."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[0:sp]
    return t


def fit(c, text, fonts, maxw):
    """[font, clipped text] for the largest listed font that fits.

    text_fit shrinks the font but still draws when even its smallest option
    overflows, so the clip is applied here rather than trusted to the helper.
    """
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]


def accent_of(ctx):
    return str(ctx.inputs.get("accent", "#4EA8FF")).strip()


def slots(ctx):
    """The configured events, in form order.

    A slot counts as configured when its DATE parses -- the date is the only
    field the app cannot invent. A name is optional and falls back to the
    theme, so filling in nothing but a date still gives "DAYS SINCE BIRTHDAY"
    rather than a blank title.

    Slots the user left empty are dropped here rather than drawn as an error.
    That is the whole reason the rotation is built on frames instead of
    manifest pages: `pages` is a fixed list, so five pages means five turns in
    the scroll whether or not the user filled in five events, and the empty
    ones would each take their slot on the wall to say nothing.

    Read out literally rather than by building "date" + i. The validator
    scans the source for each declared key, so a computed name reads to it as
    a setting the app never uses and fails the app.
    """
    raw = [
        [ctx.inputs.get("event1", ""), ctx.inputs.get("date1", ""),
         ctx.inputs.get("theme1", ""), ctx.inputs.get("numcolor1", "")],
        [ctx.inputs.get("event2", ""), ctx.inputs.get("date2", ""),
         ctx.inputs.get("theme2", ""), ctx.inputs.get("numcolor2", "")],
        [ctx.inputs.get("event3", ""), ctx.inputs.get("date3", ""),
         ctx.inputs.get("theme3", ""), ctx.inputs.get("numcolor3", "")],
        [ctx.inputs.get("event4", ""), ctx.inputs.get("date4", ""),
         ctx.inputs.get("theme4", ""), ctx.inputs.get("numcolor4", "")],
        [ctx.inputs.get("event5", ""), ctx.inputs.get("date5", ""),
         ctx.inputs.get("theme5", ""), ctx.inputs.get("numcolor5", "")],
    ]
    out = []
    for r in raw:
        ymd = parse_date(r[1])
        if ymd == None:
            continue
        theme = norm_theme(r[2])
        name = str(r[0]).strip().upper()
        if name == "":
            name = theme.upper()
        out.append({"ymd": ymd, "theme": theme, "name": name,
                    "numcolor": str(r[3]).strip()})
    return out


def active_slot(ctx, total):
    """Which event this render shows.

    Rotating on the wall clock rather than on a counter means every render is
    a pure function of the time -- there is no state to keep between refreshes,
    and the panel lands on the next event each time the scroll comes back
    round to this app.
    """
    if total <= 1:
        return 0
    return (ctx.now.unix // ROTATE_EVERY) % total


def days_since(ctx, ymd):
    """Days since `ymd`.

    Negative means the chosen day has not arrived. That is a real state worth
    naming rather than clamping to 0 -- a clamped 0 is indistinguishable from
    an event that happened today, so a mis-set date would look correct.
    """
    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    return today - days_from_civil(ymd[0], ymd[1], ymd[2])


def pretty_date(ymd):
    return "%s %d %d" % (MONTHS[ymd[1] - 1], ymd[2], ymd[0])


# ------------------------------------------------------------------- chrome

def rail(c, color):
    c.rect(0, 0, 1, c.height - 1, fill = color)


def title_row(c, event, head, right):
    """The upper level: "<HEAD><EVENT>" and the date, right-aligned.

    `head` is "DAYS SINCE " or "DAYS TO " -- the caller decides, because only
    it knows which side of today the date falls on.

    Drawn from y=0 so the row ends at 6 and the lower level can start at 8
    with a clear row between them. Hung off y=1 instead, the 5x7 title ends on
    row 7 and the art's top row touches it.

    The head is the fixed part, so only the event name is allowed to shrink or
    clip -- cutting the phrase itself would leave "DAYS SIN".
    """
    c.text(head, PAD, 1, font = "4x5", color = MID)
    x = PAD + c.text_width(head, "4x5")

    if right != "":
        c.text(right, c.width - 1 - PAD, 1, font = "4x5", color = DIM,
               align = "right")
        rw = c.text_width(right, "4x5") + 6
    else:
        rw = 0

    avail = c.width - PAD - rw - x

    # The name gets a font ladder, not just a clip. Even with the dots gone
    # the fixed label and the date leave only about 60px, and "GRADUATION" in
    # 5x7 wants 59: clipping alone silently ate the S off "MASTERS", which is
    # a different word rather than an obviously shortened one. Dropping a size
    # keeps every letter, and clip_words is still there for names no size fits.
    nf = fit(c, event, ["5x7", "4x5"], avail)
    font = nf[0]
    c.text(clip_words(c, event, font, avail), x,
           0 if font == "5x7" else 1, font = font, color = "white")


def message(c, head, sub, head_color = "#E8B04A"):
    """The one screen every non-counting state shares.

    A 16x24 head fills the band and leaves nowhere below it for the sub, which
    put the instruction ABOVE the thing it explains -- it read as a caption for
    the row above. 16x20 costs four pixels of head and buys the sub its proper
    place underneath.
    """
    c.text(clip(c, head, "16x20", c.width - 2 * PAD), c.width // 2, 4,
           font = "16x20", color = head_color, align = "center")
    if sub != "":
        c.text(clip(c, sub, "4x5", c.width - 2 * PAD), c.width // 2, 26,
               font = "4x5", color = MID, align = "center")


def marks_x(c):
    return c.width - PAD - LAMP_SPAN


def lamp(c, x, y, on, color):
    """One 5x5 anniversary lamp at (x, y).

    Lit, the square is filled with its colour and rimmed with lift() of that
    same colour. Both lamps are bright enough that lift() is the identity, so
    both draw as plain solid blocks and the rim costs nothing -- it is a guard,
    not a style: swap in a colour too dark for the ground and the lamp keeps a
    visible edge instead of disappearing into it.
    """
    if on:
        c.rect(x, y, x + 4, y + 4, fill = color, outline = lift(color))
    else:
        c.rect(x, y, x + 4, y + 4, outline = STRUCT)


def anniversary(ctx, ymd):
    """This year's occurrence of the event's date, as [y, m, d].

    Feb 29 clamps to the 28th in a common year, so a leap-day anniversary
    still has a day to land on.
    """
    y = ctx.now.year
    d = ymd[2]
    if d > month_days(y, ymd[1]):
        d = month_days(y, ymd[1])
    return [y, ymd[1], d]


def lamp_states(ctx, ymd):
    """[month, week, day] for the three lamps, as a strict cascade.

    Each lamp narrows the one to its left, so week can never light without
    month, nor day without week. That is not decoration -- it is what makes
    the row readable at a glance: the lit run always starts at the left, so
    how MANY are lit tells you how close the anniversary is without having to
    remember which colour means what.

    Getting there meant fixing two lamps, not adding one. The first versions
    asked different KINDS of question -- month and day compared today against
    the event's month/day, while week asked whether the anniversary landed in
    a window -- and predicates of different kinds cannot nest. So week lit
    without month whenever a week straddled a month end (Mon 31 Aug for a
    1 Sep event), and day lit on its own on the 1st of every month, months
    away from any anniversary.
    """
    ann = anniversary(ctx, ymd)
    month = ctx.now.month == ymd[1]

    week = False
    day = False
    if month:
        today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
        monday = today - ctx.now.weekday      # ctx.now.weekday: 0 = Monday
        a = days_from_civil(ann[0], ann[1], ann[2])
        week = a >= monday and a <= monday + 6
        day = ctx.now.day == ann[2]
    return [month, week, day]


def marks(c, ymd, ctx):
    """The three anniversary lamps, sitting under the date they qualify.

    They narrow left to right: orange for the whole of the event's month,
    green once the anniversary is in this Monday-to-Sunday week, navy on the
    day itself. See lamp_states() for why they are a cascade.

    Off is drawn as an outline rather than left blank. A lamp that vanishes
    when it is off leaves nothing to say a lamp was ever there.
    """
    st = lamp_states(ctx, ymd)
    mx = marks_x(c)
    lamp(c, mx, MARKS_Y, st[0], MONTH_ON)
    lamp(c, mx + 9, MARKS_Y, st[1], WEEK_ON)
    lamp(c, mx + 18, MARKS_Y, st[2], DAY_ON)


# --------------------------------------------------------------------- page

def since(c, ctx):
    # The accent is made safe to draw AS ink on the black ground once, here,
    # because every use of it on this page is ink -- the rail and the lamps.
    ink_accent = lift(accent_of(ctx))

    c.fill(INK)
    events = slots(ctx)

    # Not one usable date across all three slots: say what is wrong and what to
    # do, and dress the rail in the warning colour rather than the accent so
    # the state is never contradicted by its own chrome.
    if len(events) == 0:
        rail(c, "#E8B04A")
        message(c, "SET A DATE", "PICK A DAY FOR THIS EVENT")
        return

    ev = events[active_slot(ctx, len(events))]
    n = days_since(ctx, ev["ymd"])

    # The count colour belongs to the event, not the app, so it is resolved
    # per slot. lift() still guards a pick too dark for the black ground.
    num_ink = lift(ev["numcolor"])

    # A date in the future counts DOWN, and the title says so. The direction
    # lives in the head rather than in the body: once the title reads "DAYS TO
    # WEDDING", the count underneath is just a number of days like any other,
    # so it takes the unit and the colour the past case uses. Spelling it out
    # twice -- "DAYS TO WEDDING" over "114 DAYS AWAY" -- says the same thing in
    # two registers and reads as a warning rather than a countdown.
    #
    # Today belongs to neither side, and gets its own word rather than a drawn
    # zero. It keeps the SINCE head: the day is here, not still ahead.
    # Every state takes the slot's own colour. Leaving TODAY on the accent
    # meant an event set to pink turned blue on the one day it mattered.
    if n == 0:
        head = "DAYS SINCE "
        word = "TODAY"
        wcol = num_ink
        unit = ""
    elif n < 0:
        head = "DAYS TO "
        word = fmt.commas(-n)
        wcol = num_ink
        unit = "DAY" if n == -1 else "DAYS"
    else:
        head = "DAYS SINCE "
        word = fmt.commas(n)
        wcol = num_ink
        unit = "DAY" if n == 1 else "DAYS"

    rail(c, ink_accent)
    title_row(c, ev["name"], head, pretty_date(ev["ymd"]))

    # Anniversary lamps, under the date they qualify.
    marks(c, ev["ymd"], ctx)

    # ----- the count, from the left -----------------------------------------
    # The art sits at PAD and the number follows it. The count has to stop
    # short of the lamps: they sit in rows 8-12 on the right, and the number is
    # tall enough to run straight under them.
    x = draw_theme(c, ev["theme"], PAD, BAND) + ART_GAP

    uw = c.text_width(unit, UNIT_FONT) if unit != "" else 0
    ugap = UNIT_GAP if unit != "" else 0

    hf = fit(c, word, HERO_FONTS, marks_x(c) - CLEAR - x - ugap - uw)
    hw = c.text_width(hf[1], hf[0])

    # Centre the number's ink in the band rather than hanging it from BAND.
    # Drawn at BAND a 16-row face left one row under the title and eight dead
    # rows below it -- top-heavy, and the panel looked half empty.
    hh = ink_height(hf[0])
    hy = BAND + (c.height - BAND - hh) // 2
    c.text(hf[1], x, hy, font = hf[0], color = wcol)

    # The unit sits on the number's baseline, not on its own centre. "2,643"
    # and "DAYS" are one phrase and read as one only when their bottoms line
    # up; centring the smaller face left it hanging two rows low.
    if unit != "":
        uy = hy + hh - ink_height(UNIT_FONT)
        c.text(unit, x + hw + UNIT_GAP, uy, font = UNIT_FONT, color = MID)
