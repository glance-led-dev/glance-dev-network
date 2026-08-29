# Market Hours
#
# Pure arithmetic, no feed. NYSE runs 9:30 to 16:00 Eastern on
# weekdays, and the market holidays are a short published list that
# is hardcoded here through 2027.
#
# A price feed needs a key and would duplicate the existing stocks
# app; what that app cannot tell you is whether the number you are
# looking at is live or four hours stale. This can, and it can
# never fail.



MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


def is_leap(y):
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


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


# NYSE full-day closures, YYYYMMDD.
HOLIDAYS = [
    "20260101", "20260119", "20260216", "20260403", "20260525", "20260619",
    "20260703", "20260907", "20261126", "20261225",
    "20270101", "20270118", "20270215", "20270326", "20270531", "20270618",
    "20270705", "20270906", "20271125", "20271224",
]


def civil_from_days(z):
    """Days since the Unix epoch -> (year, month, day)."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return y, m, d


def nth_sunday(y, month, nth):
    fd = (days_from_civil(y, month, 1) + 4) % 7
    first_sun = 1 + ((7 - fd) % 7)
    return first_sun + (nth - 1) * 7


def is_dst(y, mo, d, h):
    # US rule: second Sunday in March to first Sunday in November.
    start = nth_sunday(y, 3, 2)
    end = nth_sunday(y, 11, 1)
    if mo < 3 or mo > 11:
        return False
    if mo > 3 and mo < 11:
        return True
    if mo == 3:
        if d > start:
            return True
        if d < start:
            return False
        return h >= 2
    if d < end:
        return True
    if d > end:
        return False
    return h < 2


def eastern_offset(ctx):
    """The NYSE trades on US Eastern, so the offset was never a question worth
    asking: it is -5, plus an hour while daylight saving is in effect. This
    app already hardcodes the 9:30-16:00 session and the holiday calendar --
    asking the viewer to supply the offset, and to remember to change it every
    March and November, made a self-contained app depend on homework."""
    u = ctx.now.unix
    usecs = u % 86400
    uy, umo, ud = civil_from_days((u - usecs) // 86400)
    return -5 + (1 if is_dst(uy, umo, ud, usecs // 3600) else 0)


# 1px silhouette outline of BELL.png at its drawn 24x24 size, offset (-1,-1).
BELL_EDGE = """
..........................
..........####............
..........#..#............
.........##..##...........
........##....##..........
.......##......##.........
.......#........#.........
......##........##........
......#..........#........
.....##..........##.......
.....#............#.......
.....#............#.......
....##............##......
....#..............#......
....#..............#......
...##..............##.....
...#................#.....
..##................##....
..#..................#....
..#..................#....
..#######......#######....
........##....##..........
.........######...........
..........................
..........................
..........................
"""


def bell(c, ctx):
    off = eastern_offset(ctx)
    shifted = ctx.now.unix + int(off * 3600)
    days = shifted // 86400
    mins = (shifted % 86400) // 60
    weekday = (days + 3) % 7          # 0 = Monday

    y = 1970
    d = days
    for i in range(400):
        span = 366 if is_leap(y) else 365
        if d < span:
            break
        d -= span
        y += 1
    m = 0
    for i in range(12):
        span = MDAYS[m] + (1 if (m == 1 and is_leap(y)) else 0)
        if d < span:
            break
        d -= span
        m += 1
    stamp = str(y) + fmt.pad(m + 1) + fmt.pad(d + 1)

    holiday = stamp in HOLIDAYS
    weekend = weekday >= 5
    OPEN = 570                        # 9:30
    CLOSE = 960                       # 16:00

    if holiday or weekend:
        state = "CLOSED"
        col = "#FF7A5B"
        note = "MARKET HOLIDAY" if holiday else "WEEKEND"
        left = ""
    elif mins < OPEN:
        state = "PRE-MARKET"
        col = "#FFB03A"
        note = "OPENS IN"
        left = str((OPEN - mins) // 60) + "H " + str((OPEN - mins) % 60) + "M"
    elif mins < CLOSE:
        state = "OPEN"
        col = "#4EE38A"
        note = "CLOSES IN"
        left = str((CLOSE - mins) // 60) + "H " + str((CLOSE - mins) % 60) + "M"
    else:
        state = "AFTER HOURS"
        col = "#7FA8D8"
        note = "CLOSED FOR TODAY"
        left = ""

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0A0A12", "#1E1E2E",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    # Centred on the Scroll, which has the width to put text beside it. On
    # 64px the state needs a full-width row of its own along the bottom, so
    # the bell moves to the top-left to stay out of it.
    by = (c.height - sz) // 2 if c.width >= 128 else 1
    if c.width >= 128:
        # 1px black outline traced from the bell's own silhouette, so the art
        # carries the same black border as the stroked text.
        c.sprite(BELL_EDGE, 0, by - 1, color = "black")
    c.image("BELL.png", 1, by, w = sz, h = sz)

    if c.width >= 128:
        # The state used to share a row with the note: it was left-aligned at
        # x=28 with maxw = width - 110 (82px) and the note was right-aligned
        # with no limit at all. "AFTER HOURS" is 119px at 10x16 even after
        # text_fit picks its smallest option -- text_fit still draws when
        # nothing fits -- so it reached x=147 while "CLOSED FOR TODAY" started
        # at x=90, and the two printed through each other. Every state now gets
        # a row to itself, with the note underneath.
        if left != "":
            # OPEN / PRE-MARKET: the countdown is the answer, so it keeps the
            # big font and the state name gives way.
            sf = _fit_clip(c, state, ["10x16", "8x12", "6x8"], c.width - 34)
            c.text_stroke(sf[1], 28, 0, font = sf[0], color = col)
            c.text_stroke(note, 28, 18, font = "5x7", color = "#8A92AC")
            c.text_stroke(left, c.width - 6, 16, font = "10x16",
                          color = "#FFFFFF", align = "right")
        else:
            # CLOSED / AFTER HOURS: there is no countdown, so the state itself
            # is the message and takes the full width above the note.
            sf = _fit_clip(c, state, ["16x20", "10x16", "8x12"], c.width - 34)
            c.text_stroke(sf[1], 28, 2, font = sf[0], color = col)
            c.text_stroke(note, 28, 23, font = "6x8", color = "#8A92AC")
    else:
        # 64px had the same fault as the wide panel and worse: text_fit still
        # draws when even its smallest option overflows, so "AFTER HOURS" and
        # "CLOSED FOR TODAY" both ran off the panel and through the bell.
        # _fit_clip clips instead, and the state moves to its own full-width
        # row below the icon so it is not fighting for the 44px beside it.
        top = left
        if top == "":
            # The long notes are written for the Scroll. At 64px the state
            # already says the market is shut, so this only has to add what
            # the state does not: which kind of closure.
            if note == "MARKET HOLIDAY":
                top = "HOLIDAY"
            elif note == "WEEKEND":
                top = "WEEKEND"
        if top != "":
            tf = _fit_clip(c, top, ["6x8", "5x7", "4x5"], c.width - 20)
            c.text_stroke(tf[1], c.width - 2, 3, font = tf[0],
                          color = "#DCE0F0", align = "right")
        sf = _fit_clip(c, state, ["6x8", "5x7", "4x5"], c.width - 4)
        c.text_stroke(sf[1], c.width // 2, 20, font = sf[0], color = col,
                      align = "center")
