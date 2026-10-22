# Sobriety Counter — days sober, counted from the day it started.
#
# Page one is the number, big enough to read across a room. Page two breaks
# the streak into weeks and names the next milestone and how far off it is —
# the part that pulls you through a hard week.
#
# Pure date arithmetic from ctx.now — no network, so it cannot show a stale
# or empty screen. Date parsing and the day-count algorithm follow the same
# approach as the stock Days Since app (the date picker can deliver a full
# ISO stamp that arrives truncated, so the date is reduced to its first
# eight digits before use).

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

MILESTONES = [7, 30, 60, 90, 180, 270, 365, 500, 730, 1000, 1500, 2000,
              2500, 3000, 3650, 5000, 7500, 10000]


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


DIGITS = "0123456789"
FALLBACK = [2026, 1, 1]


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


def streak(ctx):
    """[days, start]. Days is negative when the start date has not happened."""
    start = parse_date(ctx.inputs.get("since", "2025-08-29"))
    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    return [today - days_from_civil(start[0], start[1], start[2]), start]


def next_milestone(n):
    """[milestone, days_to_go] for the first milestone past n."""
    for m in MILESTONES:
        if n < m:
            return [m, m - n]
        if n == m:
            return [m, 0]
    return [n, 0]


def count(c, ctx):
    n = streak(ctx)[0]
    label = ctx.inputs.get("label", "DAYS SOBER").upper()
    accent = ctx.inputs.get("accent", "#E8B33A")

    c.fill("#08090D")

    if n < 0:
        c.text_fit(label, c.width // 2, 0, ["4x5", "3x4"], color = accent,
                   align = "center", maxw = c.width - 2)
        c.text_fit(fmt.commas(-n), c.width // 2, 5, ["16x20", "10x16", "7x12"],
                   color = "#8A8AA8", align = "center", maxw = c.width - 4)
        c.text("TO GO", c.width // 2, 26, font = "4x5",
               color = "#E8B33A", align = "center")
        return

    # 0-4 label | 6-25 figure | 27-31 the creed
    c.text_fit(label, c.width // 2, 0, ["4x5", "3x4"], color = accent,
               align = "center", maxw = c.width - 2)
    c.text_fit(fmt.commas(n), c.width // 2, 6, ["16x20", "10x16", "7x12"],
               color = "#FFFFFF", align = "center", maxw = c.width - 4)
    c.text_fit("DAY BY DAY", c.width // 2, 27, ["4x5", "3x4"],
               color = "#8A8AA8", align = "center", maxw = c.width - 2)


def detail(c, ctx):
    s = streak(ctx)
    n = s[0]
    start = s[1]
    accent = ctx.inputs.get("accent", "#E8B33A")

    c.fill("#08090D")
    if n < 0:
        c.text("STARTS", c.width // 2, 4, font = "6x8", color = "#FFFFFF",
               align = "center")
        c.text("%s %d %d" % (MONTHS[start[1] - 1], start[2], start[0]),
               c.width // 2, 16, font = "5x7", color = accent, align = "center")
        return

    since = "%s %d %d" % (MONTHS[start[1] - 1], start[2], start[0])
    weeks = n // 7
    ms = next_milestone(n)

    # 0-4 date | 9-16 weeks | 19-26 next milestone
    c.text(since, c.width // 2, 0, font = "4x5", color = accent,
           align = "center")
    c.text(str(weeks) + " WEEKS", c.width // 2, 9, font = "6x8",
           color = "#FFFFFF", align = "center")
    if ms[1] == 0:
        line = fmt.commas(ms[0]) + " TODAY!"
    else:
        line = "%s IN %d" % (fmt.commas(ms[0]), ms[1])
    c.text_fit(line, c.width // 2, 20, ["5x7", "4x5", "3x4"],
               color = "#E8B33A", align = "center", maxw = c.width - 2)
