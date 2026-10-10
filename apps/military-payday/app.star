# Military Payday Countdown
#
# DESIGN. Army black and gold: a black ground, a stack of pixel-art bills on
# the left as the app's identity (the cash is the label, no title needed),
# the days-left count as the one gold hero, and the actual pay date on the
# right so "3 DAYS" never has to be decoded. On payday the count gives way
# to a gold PAYDAY.
#
# Pay rule (DFAS): mid-month pay on the 15th, end-of-month pay on the 1st.
# When either lands on a weekend or a federal holiday, it posts the business
# day before -- so the 1st is often paid on the last weekday of the month
# before. No network: it's all calendar math, so it can never go offline.

BG = "#000000"
GOLD = "#FFC72C"
DIMGOLD = "#6B5310"
LABEL = "#8C8C8C"

DOW = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# zone -> [standard offset in minutes east of UTC, daylight-saving rule]
ZONES = {
    "EASTERN": [-300, "US"], "CENTRAL": [-360, "US"], "MOUNTAIN": [-420, "US"],
    "ARIZONA": [-420, ""], "PACIFIC": [-480, "US"], "ALASKA": [-540, "US"],
    "HAWAII": [-600, ""], "EUROPE": [60, "EU"], "KUWAIT": [180, ""],
    "KOREA": [540, ""], "JAPAN": [540, ""], "GUAM": [600, ""],
}


def dfc(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil(z):
    """[y, m, d] for a day number (inverse of dfc)."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]


def wday(z):
    """0 = Sunday. 1970-01-01 was a Thursday."""
    return (z + 4) % 7


def nth_wd(y, m, wd, n):
    """Day number of the nth weekday `wd` of a month (n = -1 for the last)."""
    if n < 0:
        nxt = dfc(y + 1, 1, 1) if m == 12 else dfc(y, m + 1, 1)
        last = nxt - 1
        return last - (wday(last) - wd) % 7
    first = dfc(y, m, 1)
    return first + (wd - wday(first)) % 7 + 7 * (n - 1)


def offset_min(zone, unix):
    z = ZONES.get(zone, ZONES["EASTERN"])
    std = z[0]
    mins = unix // 60
    y = civil(unix // 86400)[0]
    if z[1] == "US":
        # 2nd Sunday of March 02:00 local -> 1st Sunday of November 02:00.
        start = nth_wd(y, 3, 0, 2) * 1440 + 120 - std
        end = nth_wd(y, 11, 0, 1) * 1440 + 120 - std - 60
        if mins >= start and mins < end:
            return std + 60
    elif z[1] == "EU":
        # Last Sunday of March 01:00 UTC -> last Sunday of October 01:00 UTC.
        start = nth_wd(y, 3, 0, -1) * 1440 + 60
        end = nth_wd(y, 10, 0, -1) * 1440 + 60
        if mins >= start and mins < end:
            return std + 60
    return std


def observed(z):
    """A fixed-date holiday on Saturday is observed Friday, Sunday -> Monday."""
    w = wday(z)
    if w == 6:
        return z - 1
    if w == 0:
        return z + 1
    return z


def holidays(y):
    """Federal holidays (observed) for year y, as day numbers."""
    return [
        observed(dfc(y, 1, 1)),
        nth_wd(y, 1, 1, 3),        # MLK Day
        nth_wd(y, 2, 1, 3),        # Washington's Birthday
        nth_wd(y, 5, 1, -1),       # Memorial Day
        observed(dfc(y, 6, 19)),
        observed(dfc(y, 7, 4)),
        nth_wd(y, 9, 1, 1),        # Labor Day
        nth_wd(y, 10, 1, 2),       # Columbus Day
        observed(dfc(y, 11, 11)),
        nth_wd(y, 11, 4, 4),       # Thanksgiving
        observed(dfc(y, 12, 25)),
        observed(dfc(y + 1, 1, 1)),  # a Saturday New Year is observed Dec 31
    ]


def pay_date(y, m, d):
    """The day pay actually posts for a nominal 1st / 15th."""
    z = dfc(y, m, d)
    hol = holidays(y) + holidays(y - 1)
    for i in range(7):
        if wday(z) != 0 and wday(z) != 6 and z not in hol:
            break
        z -= 1
    return z


def next_payday(today):
    """[day number, nominal day (1 or 15)] of the next payday on or after today."""
    ymd = civil(today)
    y = ymd[0]
    m = ymd[1]
    for i in range(3):
        for nd in [1, 15]:
            z = pay_date(y, m, nd)
            if z >= today:
                return [z, nd]
        m += 1
        if m > 12:
            m = 1
            y += 1
    return [today, 1]


def bill(c, x, y, edge, fill, mark):
    """One 26x14 pixel-art banknote: framed, corner pips, oval with a $."""
    c.rect(x, y, x + 25, y + 13, fill = fill, outline = edge)
    for p in [[x + 2, y + 2], [x + 23, y + 2], [x + 2, y + 11], [x + 23, y + 11]]:
        c.pixel(p[0], p[1], edge)
    c.circle(x + 13, y + 7, 5, edge)
    c.text("$", x + 11, y + 4, font = "4x7", color = mark)


def cash(c, x, y):
    """Two bills fanned: the back one dim, the front one bright."""
    bill(c, x + 4, y, "#1F6B2E", "#06200C", "#1F6B2E")
    bill(c, x, y + 4, "#3DDC5A", "#0B3A16", GOLD)


def payday(c, ctx):
    zone = str(ctx.inputs.get("timezone", "CENTRAL")).strip().upper()
    now = ctx.now.unix + offset_min(zone, ctx.now.unix) * 60
    today = now // 86400
    nxt = next_payday(today)
    days = nxt[0] - today
    ymd = civil(nxt[0])

    c.fill(BG)
    # Bills span x 6..35, y 7..24: centred in the 32 rows, inside the 6px pad.
    cash(c, 6, 7)

    right = c.width - 7
    date = "%d %s" % (ymd[2], MON[ymd[1] - 1])
    if days == 0:
        # Payday: the count gives way to the word. "PAYDAY" is 63px at 10x16,
        # centred in the 84px between the bills (x 37) and the pad (x 121).
        mid = (37 + right) // 2
        c.text("PAYDAY", mid, 5, font = "10x16", color = GOLD, align = "center")
        c.text("TODAY " + DOW[wday(nxt[0])] + " " + date, mid, 24, font = "4x5",
               color = LABEL, align = "center")
        return

    # Hero: the count, in its own 33px column (x 39..72; "17" is the worst
    # case). DAYS sits under it rather than beside, because beside it ran
    # into the date column whenever the count went to two digits.
    num = str(days)
    hx = 39 + (33 - c.text_width(num, "16x24")) // 2
    c.text(num, hx, 1, font = "16x24", color = GOLD)
    c.text("DAY" if days == 1 else "DAYS", 56, 26, font = "4x5", color = LABEL,
           align = "center")

    # The date column, x 78..121. "30 OCT" is 38px at 6x8; every date is
    # that shape (3-letter day, 1-2 digit date, month). When the nominal
    # 1st/15th falls on a weekend or holiday the label turns gold EARLY PAY
    # (42px) so a 30 OCT payday doesn't read as a mistake.
    if ymd[2] != nxt[1]:
        c.text("EARLY PAY", right, 3, font = "4x5", color = GOLD, align = "right")
    else:
        c.text("PAYDAY", right, 3, font = "4x5", color = DIMGOLD, align = "right")
    c.text(DOW[wday(nxt[0])], right, 11, font = "6x8", color = "white",
           align = "right")
    c.text(date, right, 21, font = "6x8", color = "white", align = "right")
