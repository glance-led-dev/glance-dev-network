# Trash Day
#
# No network at all — a weekly schedule plus an alternating-week
# rule, which is how nearly every kerbside collection actually
# works. The alternation is anchored to the ISO week number so it
# stays correct across a year boundary rather than drifting.
#
# The evening before is what matters, so the panel flips to
# TONIGHT after 4pm on the day before collection.



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


DAYS = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY",
        "SUNDAY"]


def local_parts(ctx):
    off = float(ctx.inputs.get("utcoffset", 0) or 0)
    shifted = ctx.now.unix + int(off * 3600)
    days = shifted // 86400
    return [days, (days + 3) % 7, (shifted % 86400) // 3600]


def wanted(mode, week):
    if mode == "EVERY WEEK":
        return True
    if mode == "ALTERNATE WEEKS":
        return week % 2 == 0
    return False


def bins(c, ctx):
    target = str(ctx.inputs.get("day", "MONDAY")).upper()
    if target not in DAYS:
        target = "MONDAY"
    ti = DAYS.index(target)

    p = local_parts(ctx)
    days = p[0]
    weekday = p[1]
    hour = p[2]
    week = days // 7

    ahead = (ti - weekday) % 7
    tonight = (ahead == 1 and hour >= 16) or (ahead == 0 and hour < 16)

    if ahead == 0:
        when = "TODAY"
    elif ahead == 1:
        when = "TONIGHT" if hour >= 16 else "TOMORROW"
    else:
        when = "IN " + str(ahead) + " DAYS"

    show = [["BINTRASH", True]]
    show.append(["BINRECYCLE",
                 wanted(str(ctx.inputs.get("recycling", "NEVER")).upper(),
                        week + (1 if ahead > 0 else 0))])
    show.append(["BINYARD",
                 wanted(str(ctx.inputs.get("yard", "NEVER")).upper(),
                        week + (1 if ahead > 0 else 0))])

    live = []
    for s in show:
        if s[1]:
            live.append(s[0])

    urgent = tonight or ahead == 0
    c.gradient_rect(0, 0, c.width - 1, c.height - 1,
                    "#161006" if urgent else "#080A10",
                    "#3A2408" if urgent else "#161A26", horizontal = False)

    sz = 22 if c.width >= 128 else 15
    x = 2
    for nm in live:
        y = c.height - sz - 1
        if nm == "BINTRASH":
            c.image("BINTRASH.png", x, y, w = sz, h = sz)
        elif nm == "BINRECYCLE":
            c.image("BINRECYCLE.png", x, y, w = sz, h = sz)
        else:
            c.image("BINYARD.png", x, y, w = sz, h = sz)
        x += sz + 2

    col = "#FFB03A" if urgent else "#8FA8D0"
    if c.width >= 128:
        c.text_fit(when, c.width - 6, 2, ["16x20", "10x16"], color = col,
                   align = "right", maxw = c.width - x - 10)
        c.text(target, c.width - 6, 24, font = "6x8", color = "#7C88A8",
               align = "right")
    else:
        c.text_fit(when, c.width - 2, 1, ["10x16", "6x8", "5x7"], color = col,
                   align = "right", maxw = c.width - 4)
