# Event Reminder - how many days until the next time something happens.
# (192x32)
#
# Built on event-milestone. Same two levels, same rotation over up to three
# slots, same measured layout -- but each slot is a SCHEDULE, not a date: a
# first occurrence plus a cadence (every day, every 2 or 3 days, weekly,
# every 2 weeks, monthly, yearly), and the count is always to the NEXT one.
#
#   upper   DAYS TO <TITLE>                             [next date]
#   lower   [theme art]  <count> DAYS         [cadence] / [month][week][day]
#
# The cadence sits under the next date -- "EVERY 2 WEEKS" is the one thing
# about a reminder the count alone cannot tell you -- and the three lamps sit
# under that, a strict cascade on how close the next one is: this month, then
# this week, then today. Each narrows the one to its left, so the lit run
# always starts at the left and its LENGTH is the reading. See lamp_states().
#
# The lamps are free here: at 23px they are narrower than every cadence label,
# so the right column reserves the same width either way and the count keeps
# its size.
#
# Day-based cadences step from the first occurrence in fixed strides, so the
# schedule never drifts. Monthly and yearly land on the same day-of-month (or
# the last day the month has -- a reminder set for the 31st still fires in
# February, on the 28th). See next_due().
#
# Pure date arithmetic from ctx.now. Nothing is fetched.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

DIGITS = "0123456789"
HEXCHARS = "0123456789ABCDEF"

INK = "#08090D"          # near-black ground, per the contrast rule
DIM = "#5E5E7A"          # the next date, and the cadence under it
MID = "#9A9AB8"          # secondary rows
STRUCT = "#1E2030"       # the unlit lamps

PAD = 8                  # scroll safe zone: neighbours slide past the edges
BAND = 8                 # lower level starts here, below the title row
ROTATE_EVERY = 60        # seconds one reminder holds the panel before the next

# The count block. 16x24 is deliberately NOT in the ladder: it is exactly as
# tall as the band, so it lands one row under the title with nothing below.
# Capping at 16x20 leaves two rows of air either side once the ink is centred.
HERO_FONTS = ["16x20", "10x16", "8x12"]
UNIT_FONT = "8x12"
ART_GAP = 6              # art to number
UNIT_GAP = 6             # number to unit
CLEAR = 4                # unit to the cadence column
CADENCE_Y = 8            # cadence text, right-aligned under the next date

# The three lamps, right-aligned under the cadence: 5 + 4 + 5 + 4 + 5 = 23.
# They cost the count nothing -- every cadence label is already wider than 23
# at 4x5, so the right column reserves that much either way.
MARKS_Y = 14
LAMP_SPAN = 23
MONTH_ON = "#E87722"     # orange: the next one lands this calendar month
WEEK_ON = "#3FA34D"      # green:  ...and inside this Monday-to-Sunday week
DAY_ON = "#2160AF"       # navy:   ...and it is today

# Ink heights, since Starlark cannot measure a glyph. For every face here the
# ink fills the full box.
FONT_INK = {"16x20": 20, "10x16": 16, "8x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# Cadence: dropdown label (lowercased) -> [stride in days, label on the panel].
# A stride of 0 means "calendar", handled by name in next_due().
CADENCE = {
    "every day": [1, "EVERY DAY"],
    "every 2 days": [2, "EVERY 2 DAYS"],
    "every 3 days": [3, "EVERY 3 DAYS"],
    "weekly": [7, "WEEKLY"],
    "every 2 weeks": [14, "EVERY 2 WEEKS"],
    "monthly": [0, "MONTHLY"],
    "yearly": [0, "YEARLY"],
}


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


def civil_from_days(z):
    """The inverse of days_from_civil: epoch day count -> [y, m, d]."""
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


# ----------------------------------------------------------------- pixel art
# Twenty themes, one 24x24 sprite slot. Ten are shared with event-milestone
# byte-for-byte; ten are new here. All emitted from the same generator.

WALKING = [
    "........................",
    "...........KKK..........",
    "..........KKKKK.........",
    ".........KKKKKKK........",
    ".........KKKKKKK........",
    ".........KKKKKKK........",
    "..........KKKKK.........",
    "...........KKK..........",
    "..........BBBBB.........",
    "..........BBBBBB........",
    ".........BBBBBBBB.......",
    "........BBBBBBBBBB......",
    ".......BBBBBBBB.BBB.....",
    "......BBB.BBBBB..BBB....",
    "......BB..BBBBB...BB....",
    "..........BBBBB.........",
    "..........BBBBB.........",
    "..........BB.BBB........",
    ".........BBB..BB........",
    "........BBB...BB........",
    "........BB....BB........",
    ".....KKKBB....BBB.......",
    ".......BB......KKK......",
    "...............BB.......",
]
WALKING_LEGEND = {"B": "#3FA34D", "K": "#F2C79A"}

DUMBBELL = [
    "........................",
    "........................",
    "........................",
    "........................",
    ".HHHH..............HHHH.",
    ".HHHH..............HHHH.",
    ".PPPP..............PPPP.",
    ".PPPP..............PPPP.",
    ".PPPP.HHH......HHH.PPPP.",
    ".PPPP.HHH......HHH.PPPP.",
    ".PPPP.PPP......PPP.PPPP.",
    ".PPPPBPPPBBBBBBPPPBPPPP.",
    ".PPPPBPPPBBBBBBPPPBPPPP.",
    ".PPPP.PPP......PPP.PPPP.",
    ".PPPP.PPP......PPP.PPPP.",
    ".PPPP.PPP......PPP.PPPP.",
    ".PPPP..............PPPP.",
    ".PPPP..............PPPP.",
    ".PPPP..............PPPP.",
    ".PPPP..............PPPP.",
    "........................",
    "........................",
    "........................",
    "........................",
]
DUMBBELL_LEGEND = {"B": "#D8DCE8", "H": "#9AA2B4", "P": "#5A6070"}

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

BILLIARDS = [
    "........................",
    "........................",
    "........................",
    "................KKK.....",
    "..............KKKKKKK...",
    ".......WWW...KKKKKKKKK..",
    "......WWWWW..KKKWWWKKK..",
    ".....WWWWWWWKKKWWWWWKKK.",
    ".....WWWWWWWKKKWWKWWKKK.",
    ".....WWWWWWWKKKWWWWWKKK.",
    "......WWWWW..KKKWWWKKK..",
    ".......WWW..TKKKKKKKKK..",
    "...........TTTKKKKKKK...",
    "..........TTT...KKK.....",
    ".........TTT............",
    "........TTT.............",
    ".......TTT..............",
    "......TTT...............",
    ".....TTT................",
    "....LLT.................",
    "...LLL..................",
    "..LLL...................",
    ".LLL....................",
    ".LL.....................",
]
BILLIARDS_LEGEND = {"K": "#22242E", "L": "#5A3A22", "T": "#C89A5A",
                     "W": "#F2F2F8"}

DART = [
    "........................",
    "........................",
    "..........KKKKK.....YY..",
    "........KKKKKKKKK...YYY.",
    "......KKKKWWWWWKKKK.SYYY",
    ".....KKKWWWWWWWWWKKS..YY",
    "....KKKWWWWRRRWWWWSKK...",
    "....KKWWWRRRRRRRWSWKK...",
    "...KKWWWRRRWWWRRSWWWKK..",
    "...KKWWRRWWWWWWSRRWWKK..",
    "..KKWWWRRWWGGGSWRRWWWKK.",
    "..KKWWRRWWGGGSGWWRRWWKK.",
    "..KKWWRRWWGGSGGWWRRWWKK.",
    "..KKWWRRWWGGGGGWWRRWWKK.",
    "..KKWWWRRWWGGGWWRRWWWKK.",
    "...KKWWRRWWWWWWWRRWWKK..",
    "...KKWWWRRRWWWRRRWWWKK..",
    "....KKWWWRRRRRRRWWWKK...",
    "....KKKWWWWRRRWWWWKKK...",
    ".....KKKWWWWWWWWWKKK....",
    "......KKKKWWWWWKKKK.....",
    "........KKKKKKKKK.......",
    "..........KKKKK.........",
    "........................",
]
DART_LEGEND = {"G": "#3FA34D", "K": "#22242E", "R": "#E0243C", "S": "#C9CCD8",
                "W": "#F2F2F8", "Y": "#FFD24A"}

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

FRISBEE = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    ".......HHHHHHHHHHH......",
    "....HHHHHHHHHHHHHHHHH...",
    "..HHHHHHHHHHHHHHHHHHHHH.",
    ".OOOOOOOOOOOOOOOOOOOOOOO",
    ".OOOOOOODDDDDDDDDOOOOOOO",
    ".OOOOOOOOOOOOOOOOOOOOOOO",
    "..OOOOOOOOOOOOOOOOOOOOO.",
    "....OOOOOOOOOOOOOOOOO...",
    ".......OOOOOOOOOOO......",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
]
FRISBEE_LEGEND = {"D": "#B0521A", "H": "#FF9A4A", "O": "#E8721E"}

ARCHERY = [
    "........................",
    "........................",
    "..............ST........",
    "..........TT..S.........",
    "........TT....S.........",
    ".......TT.....S.........",
    "......TT......S.........",
    ".....TT.......S.........",
    ".....TT.......S.........",
    "....TT........S.........",
    "...KTT........F.........",
    "..KKTT.......FS.........",
    "KKKKSSSSSSSSFSS.........",
    "..KKTT.......FS.........",
    "....TT........F.........",
    "....TT........S.........",
    ".....TT.......S.........",
    ".....TT.......S.........",
    "......TT......S.........",
    ".......TT.....S.........",
    "........TT....S.........",
    "..........TT..S.........",
    "..............ST........",
    "........................",
]
ARCHERY_LEGEND = {"F": "#E0243C", "K": "#9A9AB8", "S": "#C9CCD8", "T": "#8B5A2B"}

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

CLIMBING = [
    "........................",
    "...SSSSSSSSSSSSSSSSSS...",
    "...SSSSSSSSSSSSSSSSSS...",
    "...SSSSSSSSSSSSSSSSSS...",
    "...SSSRRSSSSSSSSSSSSS...",
    "...SSSRRSSKKKSSSSSSSS...",
    "...SSSSSSKKKKKYYSSSSS...",
    "...SSSSSSKKKKKYYSSSSS...",
    "...SSSSPPKKKKKSSSSSSS...",
    "...SSSSPPPKKKSSPPSSSS...",
    "...SSSSSPPPPPPPPPSSSS...",
    "...SSSSSSPPPPPPPSSSSS...",
    "...SSSSSSGPPPPSSSSSSS...",
    "...SSSSSSSPPPSSSSSSSS...",
    "...SSSSSSSPPPSSSBBSSS...",
    "...SSSSSSSPPPPSSBBSSS...",
    "...SSSSSSSPPPPSSSSSSS...",
    "...SSSSSSPPPPPPSSSSSS...",
    "...SSSOOPPPSSPPPSSSSS...",
    "...SSSOOPPSSSSPPSSSSS...",
    "...SSSSSPPSSSRPPSSSSS...",
    "...SSSSSSSSSSRRSSSSSS...",
    "...SSSSSSSSSSSSSSSSSS...",
    "........................",
]
CLIMBING_LEGEND = {"B": "#4EA8FF", "G": "#3FA34D", "K": "#F2C79A", "O": "#FF8A1E",
                    "P": "#E85AA8", "R": "#E0243C", "S": "#4A4E5C", "Y": "#FFD24A"}

TRASH = [
    "........................",
    "..........LLLL..........",
    "..........LLLL..........",
    "....LLLLLLLLLLLLLLLL....",
    "....LLLLLLLLLLLLLLLL....",
    "........................",
    ".....BBBBBBBBBBBBBB.....",
    ".....BBBBBBBBBBBBBB.....",
    ".....BBBBLBBLBBLBBB.....",
    ".....BBBBLBBLBBLBBB.....",
    "......BBBLBBLBBLBB......",
    "......BBBLBBLBBLBB......",
    "......BBBLBBLBBLBB......",
    "......BBBLBBLBBLBB......",
    "......BBBLBBLBBLBB......",
    "......BBBLBBLBBLBB......",
    "......BBBLBBLBBLBB......",
    "......BBBLBBLBBLBB......",
    ".......BBLBBLBBLB.......",
    ".......BBLBBLBBLB.......",
    ".......BBBBBBBBBB.......",
    "........................",
    "........................",
    "........................",
]
TRASH_LEGEND = {"B": "#3FA34D", "L": "#6E7A94"}

HOSPITAL = [
    "........................",
    "........................",
    "........................",
    "........................",
    "...WWWWWWWWWWWWWWWWWW...",
    "...WWWWWWWWWWWWWWWWWW...",
    "...WWWWWWWWWWWWWWWWWW...",
    "...WWWWWWWWWWWWWWWWWW...",
    "...WWWWWWRRRRRRWWWWWW...",
    "...WWWWWWRRRRRRWWWWWW...",
    "...WWWWWWRRRRRRWWWWWW...",
    "...WWWRRRRRRRRRRRRWWW...",
    "...WWWRRRRRRRRRRRRWWW...",
    "...WWWRRRRRRRRRRRRWWW...",
    "...WWWRRRRRRRRRRRRWWW...",
    "...WWWWWWRRRRRRWWWWWW...",
    "...WWWWWWRRRRRRWWWWWW...",
    "...WWWWWWRRRRRRWWWWWW...",
    "...WWWWWWWWWWWWWWWWWW...",
    "...WWDDDDWWWWWWDDDDWW...",
    "...WWDDDDWWWWWWDDDDWW...",
    "...WWDDDDWWWWWWDDDDWW...",
    "........................",
    "........................",
]
HOSPITAL_LEGEND = {"D": "#6E7A94", "R": "#E0243C", "W": "#F2F2F8"}

SCHOOL = [
    "........................",
    "............R...........",
    "...........RRR..........",
    ".........RRRRRRR........",
    "........RRWWYWRRR.......",
    "......RRRRWYYYRRRRR.....",
    ".....RRRRRWWYWRRRRRR....",
    "...RRRRRRRWWWWRRRRRRRR..",
    "........................",
    "....BBBBBBBBBBBBBBBB....",
    "....BBBBBBBBBBBBBBBB....",
    "....BBWWWBBBBBBWWWBB....",
    "....BBWWWBBBBBBWWWBB....",
    "....BBWWWBBBBBBWWWBB....",
    "....BBBBBBBBBBBBBBBB....",
    "....BBBBBBDDDDBBBBBB....",
    "....BBWWWBDDDDBWWWBB....",
    "....BBWWWBDDDDBWWWBB....",
    "....BBWWWBDDDDBWWWBB....",
    "....BBBBBBDDDDBBBBBB....",
    "....BBBBBBDDDDBBBBBB....",
    "....BBBBBBDDDDBBBBBB....",
    "........................",
    "........................",
]
SCHOOL_LEGEND = {"B": "#B5533A", "D": "#5A3A22", "R": "#C0392B", "W": "#9FD4F5",
                  "Y": "#FFD24A"}

RESTAURANT = [
    "........................",
    "........................",
    ".....S.S.S.....SSSS.....",
    ".....S.S.S.....SSSS.....",
    ".....S.S.S.....SSSS.....",
    ".....S.S.S....SSSSS.....",
    ".....S.S.S....SSSSS.....",
    ".....S.S.S....SSSSS.....",
    ".....SSSSS....SSSSS.....",
    ".....SSSSS....SSSSS.....",
    ".....SSSSS....SSSSS.....",
    ".......S.......SSSS.....",
    ".......S................",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    ".......S........SS......",
    "........................",
]
RESTAURANT_LEGEND = {"S": "#D8DCE8"}

# Every theme the dropdown offers, as [art, legend].
ART = {
    "walking": [WALKING, WALKING_LEGEND],
    "dumbbell": [DUMBBELL, DUMBBELL_LEGEND],
    "fishing": [FISHING, FISHING_LEGEND],
    "soccer": [SOCCER, SOCCER_LEGEND],
    "football": [FOOTBALL, FOOTBALL_LEGEND],
    "basketball": [BASKETBALL, BASKETBALL_LEGEND],
    "badminton": [BADMINTON, BADMINTON_LEGEND],
    "hockey": [HOCKEY, HOCKEY_LEGEND],
    "skiing": [SKIING, SKIING_LEGEND],
    "billiards": [BILLIARDS, BILLIARDS_LEGEND],
    "darts": [DART, DART_LEGEND],
    "golf": [GOLF, GOLF_LEGEND],
    "chess": [CHESS, CHESS_LEGEND],
    "frisbee": [FRISBEE, FRISBEE_LEGEND],
    "archery": [ARCHERY, ARCHERY_LEGEND],
    "bicycle": [BICYCLE, BICYCLE_LEGEND],
    "climbing": [CLIMBING, CLIMBING_LEGEND],
    "trash": [TRASH, TRASH_LEGEND],
    "hospital": [HOSPITAL, HOSPITAL_LEGEND],
    "school": [SCHOOL, SCHOOL_LEGEND],
    "restaurant": [RESTAURANT, RESTAURANT_LEGEND],
}

SCALE = 1
ART_W = 24               # every theme is one 24x24 sprite


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


# ----------------------------------------------------------------- schedule

def norm_cadence(value):
    t = str(value).strip().lower()
    if t in CADENCE:
        return t
    return "weekly"


def norm_theme(value):
    """A theme setting, lowercased, against the themes that actually exist."""
    t = str(value).strip().lower()
    if t in ART:
        return t
    return "walking"


def draw_theme(c, theme, x, y):
    a = ART.get(theme, ART["walking"])
    c.sprite(a[0], x, y, legend = a[1], scale = SCALE)
    return x + ART_W


def accent_of(ctx):
    return str(ctx.inputs.get("accent", "#4EA8FF")).strip()


def slots(ctx):
    """The configured reminders, in form order.

    A slot counts as configured when its DATE parses. A blank title falls back
    to the theme name, so a date and a theme alone still read as a reminder.
    Read out literally rather than by building "date" + i: the validator scans
    the source for each declared key and cannot see a computed name.
    """
    raw = [
        [ctx.inputs.get("title1", ""), ctx.inputs.get("date1", ""),
         ctx.inputs.get("repeat1", ""), ctx.inputs.get("theme1", ""),
         ctx.inputs.get("numcolor1", "")],
        [ctx.inputs.get("title2", ""), ctx.inputs.get("date2", ""),
         ctx.inputs.get("repeat2", ""), ctx.inputs.get("theme2", ""),
         ctx.inputs.get("numcolor2", "")],
        [ctx.inputs.get("title3", ""), ctx.inputs.get("date3", ""),
         ctx.inputs.get("repeat3", ""), ctx.inputs.get("theme3", ""),
         ctx.inputs.get("numcolor3", "")],
        [ctx.inputs.get("title4", ""), ctx.inputs.get("date4", ""),
         ctx.inputs.get("repeat4", ""), ctx.inputs.get("theme4", ""),
         ctx.inputs.get("numcolor4", "")],
        [ctx.inputs.get("title5", ""), ctx.inputs.get("date5", ""),
         ctx.inputs.get("repeat5", ""), ctx.inputs.get("theme5", ""),
         ctx.inputs.get("numcolor5", "")],
    ]
    out = []
    for r in raw:
        ymd = parse_date(r[1])
        if ymd == None:
            continue
        theme = norm_theme(r[3])
        name = str(r[0]).strip().upper()
        if name == "":
            name = theme.upper()
        out.append({"ymd": ymd, "cadence": norm_cadence(r[2]),
                    "theme": theme, "name": name,
                    "numcolor": str(r[4]).strip()})
    return out


def active_slot(ctx, total):
    if total <= 1:
        return 0
    return (ctx.now.unix // ROTATE_EVERY) % total


def next_due(ctx, ymd, cadence):
    """[days until the next occurrence, its date as [y, m, d]].

    Day strides count from the first occurrence in fixed steps, so a "every 3
    days" reminder started on a Monday stays on the same footing forever
    rather than drifting with each render. Calendar cadences land on the same
    day-of-month; a day the month does not have clamps to its last day.

    Before the first occurrence the answer is simply the first occurrence --
    a reminder set to start next Tuesday has nothing to repeat yet.
    """
    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    start = days_from_civil(ymd[0], ymd[1], ymd[2])
    if today <= start:
        return [start - today, ymd]

    stride = CADENCE[cadence][0]
    if stride > 0:
        k = (today - start + stride - 1) // stride
        nxt = start + k * stride
        return [nxt - today, civil_from_days(nxt)]

    if cadence == "monthly":
        y = ctx.now.year
        m = ctx.now.month
        for i in range(2):
            d = min(ymd[2], month_days(y, m))
            cand = days_from_civil(y, m, d)
            if cand >= today:
                return [cand - today, [y, m, d]]
            m += 1
            if m > 12:
                m = 1
                y += 1
        return [0, ymd]

    # yearly
    y = ctx.now.year
    for i in range(2):
        d = min(ymd[2], month_days(y, ymd[1]))
        cand = days_from_civil(y, ymd[1], d)
        if cand >= today:
            return [cand - today, [y, ymd[1], d]]
        y += 1
    return [0, ymd]


def short_date(ymd):
    """"SEP 14" -- the year is noise on something that repeats."""
    return "%s %d" % (MONTHS[ymd[1] - 1], ymd[2])


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


def lamp(c, x, y, on, color):
    """One 5x5 lamp at (x, y).

    Lit, the square is filled with its colour and rimmed with lift() of that
    same colour. All three are bright enough that lift() is the identity, so
    they draw as plain solid blocks and the rim costs nothing -- it is a
    guard, not a style: swap in a colour too dark for the ground and the lamp
    keeps a visible edge instead of vanishing into it.
    """
    if on:
        c.rect(x, y, x + 4, y + 4, fill = color, outline = lift(color))
    else:
        c.rect(x, y, x + 4, y + 4, outline = STRUCT)


def lamp_states(ctx, due_ymd):
    """[month, week, day] for the three lamps, as a strict cascade.

    Each narrows the one to its left, so the lit run always starts at the
    left and its LENGTH is the reading: nothing, then this month, then this
    week, then today.

    The nesting is structural rather than lucky. `due_ymd` is the NEXT
    occurrence, so it is never earlier than today; week and day are only
    computed once the month matches, and a due date that is today is
    necessarily inside today's own week.

    The year is checked as well as the month: a yearly reminder whose next
    turn is next September must not light the month lamp all through this
    one.
    """
    month = due_ymd[0] == ctx.now.year and due_ymd[1] == ctx.now.month

    week = False
    day = False
    if month:
        today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
        monday = today - ctx.now.weekday      # ctx.now.weekday: 0 = Monday
        d = days_from_civil(due_ymd[0], due_ymd[1], due_ymd[2])
        week = d <= monday + 6
        day = d == today
    return [month, week, day]


def marks(c, due_ymd, ctx):
    """The three lamps, under the cadence they qualify."""
    st = lamp_states(ctx, due_ymd)
    mx = c.width - PAD - LAMP_SPAN
    lamp(c, mx, MARKS_Y, st[0], MONTH_ON)
    lamp(c, mx + 9, MARKS_Y, st[1], WEEK_ON)
    lamp(c, mx + 18, MARKS_Y, st[2], DAY_ON)


# --------------------------------------------------------------------- page

def reminder(c, ctx):
    ink_accent = lift(accent_of(ctx))

    c.fill(INK)
    events = slots(ctx)

    if len(events) == 0:
        rail(c, "#E8B04A")
        message(c, "SET A DATE", "PICK WHEN IT FIRST HAPPENS")
        return

    ev = events[active_slot(ctx, len(events))]
    due = next_due(ctx, ev["ymd"], ev["cadence"])
    n = due[0]

    # The count colour belongs to the reminder, not the app, so it is
    # resolved per slot. lift() still guards a pick too dark to see.
    num_ink = lift(ev["numcolor"])

    rail(c, ink_accent)
    title_row(c, ev["name"], "DAYS TO ", short_date(due[1]))

    # Cadence under the next date, right-aligned. It occupies rows 8-12 on
    # the right, so the count group is capped to stop short of it.
    label = CADENCE[ev["cadence"]][1]
    right = c.width - 1 - PAD
    c.text(label, right, CADENCE_Y, font = "4x5", color = DIM, align = "right")
    marks(c, due[1], ctx)

    # The count clears whichever of the two is wider. Measuring only the
    # cadence would let the number run under the lamps on a short label like
    # WEEKLY, which is 30px against the lamps' 23 -- close enough that the
    # bug would not show up until someone picked YEARLY.
    col = c.text_width(label, "4x5")
    if LAMP_SPAN > col:
        col = LAMP_SPAN
    limit = right - col - CLEAR

    # Every state takes the slot's own colour. Leaving TODAY on the accent
    # meant a reminder set to pink turned blue on the one day it mattered.
    if n == 0:
        word = "TODAY"
        wcol = num_ink
        unit = ""
    else:
        word = fmt.commas(n)
        wcol = num_ink
        unit = "DAY" if n == 1 else "DAYS"

    x = draw_theme(c, ev["theme"], PAD, BAND) + ART_GAP
    uw = c.text_width(unit, UNIT_FONT) if unit != "" else 0
    ugap = UNIT_GAP if unit != "" else 0

    hf = fit(c, word, HERO_FONTS, limit - x - ugap - uw)
    hw = c.text_width(hf[1], hf[0])

    hh = ink_height(hf[0])
    hy = BAND + (c.height - BAND - hh) // 2
    c.text(hf[1], x, hy, font = hf[0], color = wcol)

    if unit != "":
        uy = hy + hh - ink_height(UNIT_FONT)
        c.text(unit, x + hw + UNIT_GAP, uy, font = UNIT_FONT, color = MID)
