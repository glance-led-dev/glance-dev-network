# Simlandi Flag — shot day, on the wall.
#
# The shot runs on a 14-day cycle anchored to one known Tuesday
# (Oct 20, 2026; then Nov 3, Nov 17, ...). Everything is date
# arithmetic from ctx.now: position in the cycle is the anchor delta
# modulo 14, which works both directions, so the panel stays right
# even before the anchor date. Shot days shout; other days whisper a
# countdown and name the Tuesday that is coming.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
WEEKDAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

DIGITS = "0123456789"
FALLBACK = [2026, 10, 20]


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil_from_days(z):
    """[y, m, d] for a days-since-epoch count (Hinnant, inverse)."""
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
    return [y, m, d]


def parse_date(s):
    """A date setting -> [y, m, d]. Digits only, first eight, hand-checked."""
    ds = ""
    t = str(s)
    for i in range(len(t)):
        if DIGITS.find(t[i]) >= 0:
            ds = ds + t[i]
    if len(ds) < 8:
        return FALLBACK
    out = [int(ds[0:4]), int(ds[4:6]), int(ds[6:8])]
    if out[0] < 1900 or out[1] < 1 or out[1] > 12 or out[2] < 1 or out[2] > 31:
        return FALLBACK
    return out


def date_line(days):
    """'TUE NOV 3' for a days-since-epoch count."""
    ymd = civil_from_days(days)
    wd = WEEKDAYS[(days + 3) % 7]  # epoch day 0 was a Thursday
    return "%s %s %d" % (wd, MONTHS[ymd[1] - 1], ymd[2])


def shot(c, ctx):
    anchor = parse_date(ctx.inputs.get("anchor", "2026-10-20"))
    accent = ctx.inputs.get("accent", "#E8B33A")

    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    base = days_from_civil(anchor[0], anchor[1], anchor[2])
    until = (14 - (today - base) % 14) % 14

    c.fill("#08090D")

    if until == 0:
        c.text_fit("SIMLANDI", c.width // 2, 0, ["4x5", "3x4"],
                   color = "#8A8AA8", align = "center", maxw = c.width - 2)
        c.text_fit("SHOT DAY", c.width // 2, 7, ["10x16", "7x12", "6x8"],
                   color = accent, align = "center", maxw = c.width - 2)
        c.text_fit(date_line(today), c.width // 2, 26, ["4x5", "3x4"],
                   color = "#FFFFFF", align = "center", maxw = c.width - 2)
        return

    c.text_fit("NEXT SHOT", c.width // 2, 0, ["4x5", "3x4"],
               color = "#8A8AA8", align = "center", maxw = c.width - 2)
    c.text_fit(str(until), c.width // 2, 5, ["16x20", "10x16", "7x12"],
               color = "#FFFFFF", align = "center", maxw = c.width - 4)
    c.text_fit(date_line(today + until), c.width // 2, 26, ["4x5", "3x4"],
               color = accent, align = "center", maxw = c.width - 2)
