# Recurring Reminder — a repeating day, on the wall.
#
# Generalized from Joel's Simlandi Flag (PR #962, closed Oct 22, 2026 as
# too personal for the community catalog). The maintainer's own suggestion:
# "a reminder that repeats every N days or weeks with a label you set."
# So: the user sets a label, an anchor date (any one occurrence), and an
# interval in days. Position in the cycle is the anchor delta modulo the
# interval, which works both directions. Due days shout; other days
# whisper a countdown and name the date that is coming.

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


def parse_interval(s):
    """An interval-in-days setting -> int, clamped to 1..365, default 14."""
    ds = ""
    t = str(s)
    for i in range(len(t)):
        if DIGITS.find(t[i]) >= 0:
            ds = ds + t[i]
    if len(ds) == 0:
        return 14
    n = int(ds)
    if n < 1:
        return 1
    if n > 365:
        return 365
    return n


def date_line(days):
    """'TUE NOV 3' for a days-since-epoch count."""
    ymd = civil_from_days(days)
    wd = WEEKDAYS[(days + 3) % 7]  # epoch day 0 was a Thursday
    return "%s %s %d" % (wd, MONTHS[ymd[1] - 1], ymd[2])


def reminder(c, ctx):
    label = str(ctx.inputs.get("label", "REMINDER"))
    anchor = parse_date(ctx.inputs.get("anchor", "2026-10-20"))
    interval = parse_interval(ctx.inputs.get("intervaldays", "14"))
    accent = ctx.inputs.get("accent", "#E8B33A")

    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    base = days_from_civil(anchor[0], anchor[1], anchor[2])
    until = (interval - (today - base) % interval) % interval

    c.fill("#08090D")

    if until == 0:
        c.text_fit(label, c.width // 2, 0, ["4x5", "3x4"],
                   color = "#8A8AA8", align = "center", maxw = c.width - 2)
        c.text_fit("TODAY", c.width // 2, 7, ["10x16", "7x12", "6x8"],
                   color = accent, align = "center", maxw = c.width - 2)
        c.text_fit(date_line(today), c.width // 2, 26, ["4x5", "3x4"],
                   color = "#FFFFFF", align = "center", maxw = c.width - 2)
        return

    c.text_fit("NEXT " + label, c.width // 2, 0, ["4x5", "3x4"],
               color = "#8A8AA8", align = "center", maxw = c.width - 2)
    c.text_fit(str(until), c.width // 2, 5, ["16x20", "10x16", "7x12"],
               color = "#FFFFFF", align = "center", maxw = c.width - 4)
    c.text_fit(date_line(today + until), c.width // 2, 26, ["4x5", "3x4"],
               color = accent, align = "center", maxw = c.width - 2)
