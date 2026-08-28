# Mars Clock
#
# A Martian day is 39 minutes 35 seconds longer than ours, so Mars
# time drifts against Earth time all year. MSD and MTC come from the
# standard conversion off the Julian date.



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


def msd(unix):
    """Mars Sol Date from a Unix timestamp."""
    jd = unix / 86400.0 + 2440587.5
    return (jd - 2451549.5) / 1.02749125 + 44796.0 - 0.00096


def mtc(c, ctx):
    """Coordinated Mars Time — the prime meridian clock on Mars."""
    d = msd(ctx.now.unix)
    frac = d - int(d)
    hours = frac * 24.0
    h = int(hours)
    m = int((hours - h) * 60)

    c.fill("#160805")
    c.text("MARS TIME", c.width // 2, 2, font = "4x5", color = "#C4643A",
           align = "center")
    # On the Scroll the Earth clock owns a right-hand column and the Mars
    # figure is fitted to what remains; centring it ran the two together.
    if c.width >= 128:
        # squeezed 4px toward the center per the audit rulings
        c.text("EARTH UTC", c.width - 10, 8, font = "4x5", color = "#8A5A48",
               align = "right")
        c.text(fmt.pad(ctx.now.hour) + ":" + fmt.pad(ctx.now.minute),
               c.width - 10, 15, font = "10x16", color = "#B07A60",
               align = "right")
        c.text_fit(fmt.pad(h) + ":" + fmt.pad(m), 12, 9, ["16x20", "10x16"],
                   color = "#FF8A4A", maxw = c.width - 104)
    else:
        c.text_fit(fmt.pad(h) + ":" + fmt.pad(m), c.width // 2, 9,
                   ["16x20", "10x16", "6x8"], color = "#FF8A4A",
                   align = "center", maxw = c.width - 6)


def sol(c, ctx):
    d = msd(ctx.now.unix)
    c.fill("#160805")
    if c.width >= 128:
        # squeezed 4px toward the center per the audit rulings
        c.text("MARS SOL DATE", 10, 2, font = "5x7", color = "#C4643A")
        c.text("SOL LENGTH", c.width - 10, 4, font = "4x5", color = "#8A5A48",
               align = "right")
        c.text("24H 39M 35S", c.width - 10, 12, font = "6x8", color = "#E8C0A8",
               align = "right")
        c.text_fit(fmt.commas(int(d)), 10, 11, ["16x20", "10x16"],
                   color = "#FF8A4A", maxw = c.width - 104)
    else:
        c.text("SOL", c.width // 2, 1, font = "4x5", color = "#C4643A",
               align = "center")
        c.text_fit(str(int(d)), c.width // 2, 8, ["16x20", "10x16"],
                   color = "#FF8A4A", align = "center", maxw = c.width - 4)
        c.text("24H 39M", c.width // 2, 26, font = "4x5", color = "#E8C0A8",
               align = "center")
