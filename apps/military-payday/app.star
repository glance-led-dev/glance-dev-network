# Military Payday Countdown
#
# DESIGN. Army black and gold: a black ground, a gold-strapped brick of cash
# on the left as the app's identity (the cash is the label, no title needed),
# the days-left count as the one gold hero, and the actual pay date on the
# right so "3 DAYS" never has to be decoded. Along the bottom, the pay period
# as a row of day cells filling in gold toward a green payday. On payday the
# count gives way to a gold PAYDAY.
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


def prev_payday(nxt):
    """The payday before day number `nxt` -- the start of the pay period."""
    ymd = civil(nxt)
    y = ymd[0]
    m = ymd[1] + 1
    if m > 12:
        m = 1
        y += 1
    best = nxt - 16
    for i in range(4):
        for nd in [1, 15]:
            z = pay_date(y, m, nd)
            if z < nxt and z > best:
                best = z
        m -= 1
        if m < 1:
            m = 12
            y -= 1
    return best


def cash(c, x, y):
    """A 26x22 brick of cash, strapped: the top bill's face (y..y+12), the
    stacked bill edges below it (y+14..y+21), and a gold currency strap with
    the $ running down the middle of both."""
    c.rect(x, y, x + 25, y + 12, fill = "#0B3A16", outline = "#3DDC5A")
    c.rect(x + 2, y + 2, x + 23, y + 10, outline = "#1F8A36")
    for p in [[x + 4, y + 4], [x + 21, y + 4], [x + 4, y + 8], [x + 21, y + 8]]:
        c.pixel(p[0], p[1], "#3DDC5A")

    # The edges of the bills underneath, light and dark in turn, each layer
    # a pixel narrower so the brick reads as a pile rather than a box.
    for i in range(4):
        col = "#2FB54A" if i % 2 == 0 else "#145A24"
        c.line(x + 1 + i // 2, y + 14 + 2 * i, x + 24 - i // 2, y + 14 + 2 * i, col)
        c.line(x + 1 + i // 2, y + 15 + 2 * i, x + 24 - i // 2, y + 15 + 2 * i, col)
    c.line(x, y + 13, x + 25, y + 13, "#06200C")

    # The strap, x+10..x+15, over face and edges alike.
    c.rect(x + 10, y - 1, x + 15, y + 22, fill = GOLD)
    c.line(x + 15, y - 1, x + 15, y + 22, "#B8860B")
    c.text("$", x + 11, y + 3, font = "4x7", color = "black")


def track(c, prev, nxt, today):
    """The pay period as a row of day cells along the bottom: days gone in
    gold, today in white, days to come dim, and payday itself green."""
    n = nxt - prev
    span = c.width - 12
    w = (span - (n - 1)) // n
    x = 6 + (span - (n * w + n - 1)) // 2
    for i in range(1, n + 1):
        day = prev + i
        if day == nxt:
            col = "#3DDC5A"
        elif day < today:
            col = GOLD
        elif day == today:
            col = "white"
        else:
            col = "#2A2410"
        c.rect(x, 29, x + w - 1, 30, fill = col)
        x += w + 1


def payday(c, ctx):
    zone = str(ctx.inputs.get("timezone", "CENTRAL")).strip().upper()
    now = ctx.now.unix + offset_min(zone, ctx.now.unix) * 60
    today = now // 86400
    nxt = next_payday(today)
    days = nxt[0] - today
    ymd = civil(nxt[0])
    early = ymd[2] != nxt[1]

    c.fill(BG)
    # The cash brick, x 6..31, y 2..25 with the strap's overhang.
    cash(c, 6, 3)

    right = c.width - 7
    date = "%d %s" % (ymd[2], MON[ymd[1] - 1])
    if days == 0:
        # Payday: the count gives way to the word. "PAYDAY" is 63px at 10x16,
        # centred in the 84px between the brick (x 37) and the pad (x 121).
        mid = (37 + right) // 2
        c.text("PAYDAY", mid, 3, font = "10x16", color = GOLD, align = "center")
        c.text(DOW[wday(nxt[0])] + " " + date, mid, 22, font = "5x7",
               color = "white", align = "center")
        # Gold glints off the brick's corners.
        for p in [[3, 2], [34, 5], [2, 26], [35, 24]]:
            c.pixel(p[0], p[1], GOLD)
            c.pixel(p[0] - 1, p[1], "#6B5310")
            c.pixel(p[0] + 1, p[1], "#6B5310")
            c.pixel(p[0], p[1] - 1, "#6B5310")
            c.pixel(p[0], p[1] + 1, "#6B5310")
        return

    # Two columns under one eyebrow row (y 2..6): the count under DAYS,
    # centred on x 54 so "17" (33px at 16x20) spans 38..70, clear of the
    # brick; the date under PAYDAY / EARLY PAY, right-aligned to the pad.
    # Both bottom out on y 27, a pixel above the track.
    mid = 54
    c.text("DAY" if days == 1 else "DAYS", mid, 2, font = "4x5",
           color = LABEL, align = "center")
    c.text(str(days), mid, 8, font = "16x20", color = GOLD, align = "center")

    # "30 OCT" is 38px at 6x8. When the nominal 1st/15th falls on a weekend
    # or holiday the eyebrow turns gold EARLY PAY (42px, x 80..121) so a
    # 30 OCT payday doesn't read as a mistake.
    if early:
        c.text("EARLY PAY", right, 2, font = "4x5", color = GOLD, align = "right")
    else:
        c.text("PAYDAY", right, 2, font = "4x5", color = LABEL, align = "right")
    c.text(DOW[wday(nxt[0])], right, 10, font = "6x8", color = "white",
           align = "right")
    c.text(date, right, 20, font = "6x8", color = "white", align = "right")

    # The pay period, last payday to this one, along the bottom (y 29..30).
    track(c, prev_payday(nxt[0]), nxt[0], today)
