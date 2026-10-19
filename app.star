# Columbia Countdown — days to the November trip, then just joy.
#
# Three seasons, all pure date arithmetic from ctx.now:
#   before Nov 5        a countdown in the Sobriety Counter's layout
#   Nov 5 through Nov 8 the panel simply says COLUMBIA!
#   after Nov 8         a quiet dash and TRIP DONE — a countdown that
#                       is over should stop counting.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

DIGITS = "0123456789"
FALLBACK_START = [2026, 11, 5]
FALLBACK_END = [2026, 11, 8]


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def parse_date(s, fallback):
    """A date setting -> [y, m, d]. Digits only, first eight, hand-checked."""
    ds = ""
    t = str(s)
    for i in range(len(t)):
        if DIGITS.find(t[i]) >= 0:
            ds = ds + t[i]
    if len(ds) < 8:
        return fallback
    out = [int(ds[0:4]), int(ds[4:6]), int(ds[6:8])]
    if out[0] < 1900 or out[1] < 1 or out[1] > 12 or out[2] < 1 or out[2] > 31:
        return fallback
    return out


def countdown(c, ctx):
    start = parse_date(ctx.inputs.get("start", "2026-11-05"), FALLBACK_START)
    end = parse_date(ctx.inputs.get("end", "2026-11-08"), FALLBACK_END)
    accent = ctx.inputs.get("accent", "#7CC4E8")

    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    first = days_from_civil(start[0], start[1], start[2])
    last = days_from_civil(end[0], end[1], end[2])

    c.fill("#08090D")

    if today < first:
        c.text_fit("DAYS TO COLUMBIA", c.width // 2, 0, ["4x5", "3x4"],
                   color = accent, align = "center", maxw = c.width - 2)
        c.text_fit(str(first - today), c.width // 2, 5,
                   ["16x20", "10x16", "7x12"], color = "#FFFFFF",
                   align = "center", maxw = c.width - 4)
        when = "%s %d %d" % (MONTHS[start[1] - 1], start[2], start[0])
        c.text_fit(when, c.width // 2, 26, ["4x5", "3x4"],
                   color = "#8A8AA8", align = "center", maxw = c.width - 2)
    elif today <= last:
        c.text_fit("NOV 5-8", c.width // 2, 1, ["4x5", "3x4"],
                   color = "#8A8AA8", align = "center", maxw = c.width - 2)
        c.text_fit("COLUMBIA!", c.width // 2, 9, ["6x8", "5x7", "4x5"],
                   color = accent, align = "center", maxw = c.width - 2)
        c.text_fit("SOUTH CAROLINA", c.width // 2, 25, ["4x5", "3x4"],
                   color = "#FFFFFF", align = "center", maxw = c.width - 2)
    else:
        c.text_fit("COLUMBIA", c.width // 2, 0, ["4x5", "3x4"],
                   color = accent, align = "center", maxw = c.width - 2)
        c.text("-", c.width // 2, 5, font = "16x20", color = "#FFFFFF",
               align = "center")
        c.text_fit("TRIP DONE", c.width // 2, 26, ["4x5", "3x4"],
                   color = "#8A8AA8", align = "center", maxw = c.width - 2)
