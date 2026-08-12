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


def bell(c, ctx):
    off = float(ctx.inputs.get("utcoffset", -4) or -4)
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
    c.image("BELL.png", 1, (c.height - sz) // 2, w = sz, h = sz)

    if c.width >= 128:
        c.text_fit(state, 28, 3, ["16x20", "10x16"], color = col,
                   maxw = c.width - 110)
        c.text(note, c.width - 6, 5, font = "5x7", color = "#8A92AC",
               align = "right")
        if left != "":
            c.text(left, c.width - 6, 14, font = "10x16", color = "#FFFFFF",
                   align = "right")
    else:
        c.text_fit(state, c.width - 2, 3, ["10x16", "6x8", "5x7"], color = col,
                   align = "right", maxw = c.width - 20)
        c.text_fit(left if left != "" else note, c.width - 2, 22,
                   ["6x8", "4x5"], color = "#DCE0F0", align = "right",
                   maxw = c.width - 20)
