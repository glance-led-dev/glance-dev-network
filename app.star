# Day 500 Countdown — the forward-looking twin of the Sobriety Counter.
#
# The counter looks back at the streak; this panel looks ahead at the
# milestone: how many days stand between today and day 500. Pure date
# arithmetic from ctx.now — no network. Date parsing and the day-count
# algorithm follow the Sobriety Counter (and the stock Days Since app):
# a date setting is reduced to its first eight digits before use.
#
# After the date passes the panel does not go blank or negative: it
# reads 500+ and names the streak day underneath, so the wall keeps
# telling the truth the morning after the party too.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

DIGITS = "0123456789"
FALLBACK = [2027, 1, 11]


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


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


def countdown(c, ctx):
    target = parse_date(ctx.inputs.get("target", "2027-01-11"))
    label = ctx.inputs.get("label", "DAYS TO 500").upper()
    accent = ctx.inputs.get("accent", "#E8B33A")

    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    goal = days_from_civil(target[0], target[1], target[2])
    left = goal - today
    when = "%s %d %d" % (MONTHS[target[1] - 1], target[2], target[0])

    c.fill("#08090D")

    if left > 0:
        # 0-4 label | 5-24 figure | 26-30 the date it lands
        c.text_fit(label, c.width // 2, 0, ["4x5", "3x4"], color = accent,
                   align = "center", maxw = c.width - 2)
        c.text_fit(fmt.commas(left), c.width // 2, 5, ["16x20", "10x16", "7x12"],
                   color = "#FFFFFF", align = "center", maxw = c.width - 4)
        c.text_fit(when, c.width // 2, 26, ["4x5", "3x4"],
                   color = "#8A8AA8", align = "center", maxw = c.width - 2)
    elif left == 0:
        c.text_fit(label, c.width // 2, 0, ["4x5", "3x4"], color = accent,
                   align = "center", maxw = c.width - 2)
        c.text_fit("500", c.width // 2, 5, ["16x20", "10x16", "7x12"],
                   color = accent, align = "center", maxw = c.width - 4)
        c.text_fit("TODAY!", c.width // 2, 26, ["4x5", "3x4"],
                   color = "#FFFFFF", align = "center", maxw = c.width - 2)
    else:
        # The milestone is behind us: the streak did not stop at 500.
        # Day one was the target's eve minus 499 — the streak day today
        # is 500 plus the days since the milestone date.
        c.text_fit("DAYS SOBER", c.width // 2, 0, ["4x5", "3x4"],
                   color = accent, align = "center", maxw = c.width - 2)
        c.text_fit("500+", c.width // 2, 5, ["16x20", "10x16", "7x12"],
                   color = "#FFFFFF", align = "center", maxw = c.width - 4)
        c.text_fit("DAY " + fmt.commas(500 - left), c.width // 2, 26,
                   ["4x5", "3x4"], color = "#8A8AA8", align = "center",
                   maxw = c.width - 2)
