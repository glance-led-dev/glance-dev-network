# Recurring Countdowns - days until one date that comes around every year. (64x32)
#
# DESIGN. One event per copy of the app: a blue title across the top, the
# event's picture on the left, and the day count as the hero on the right.
# On the day itself the picture and count give way to a green two-line
# greeting. To track several dates, add the app once per date.

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# zone -> [standard offset in minutes east of UTC, observes US daylight saving]
ZONES = {
    "EASTERN": [-300, True],
    "CENTRAL": [-360, True],
    "MOUNTAIN": [-420, True],
    "PACIFIC": [-480, True],
    "ALASKA": [-540, True],
    "HAWAII": [-600, False],
    "UTC": [0, False],
}

# type -> [title suffix, title when the name is blank, picture, greeting lines]
TYPES = {
    "BDAY": [" BDAY", "BIRTHDAY", "bday.png", ["HAPPY", "BIRTHDAY!"]],
    "ANNIV": [" ANNIV", "ANNIVERSARY", "anniv.png", ["HAPPY", "ANNIV!"]],
    "TRIP": [" TRIP", "TRIP", "trip.png", ["TIME", "TO GO!"]],
    "EVENT": ["", "MILESTONE", "trophy.png", ["IT'S", "TIME!"]],
}

def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

def mdays(y, m):
    if m == 2 and is_leap(y):
        return 29
    return MDAYS[m - 1]

def days_from_civil(y, m, d):
    """Days since 1970-01-01 (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    """[year, month, day] for a count of days since 1970-01-01."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return [y, m, d]

def nth_sunday(y, m, n):
    """Day of the month of the nth Sunday. 1970-01-01 was a Thursday."""
    wd = (days_from_civil(y, m, 1) + 4) % 7      # 0 = Sunday
    return 1 + (7 - wd) % 7 + 7 * (n - 1)

def text_input(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def digits(s):
    out = ""
    for i in range(len(s)):
        ch = s[i]
        if ch >= "0" and ch <= "9":
            out = out + ch
    return out

def local_today(ctx):
    """Today as days since 1970-01-01 on the viewer's wall clock.

    ctx.now is UTC, so without this the count would tick over (and the
    greeting would appear) at 7 or 8 PM Eastern the evening before.
    """
    zone = ZONES.get(text_input(ctx, "timezone", "EASTERN").upper(), ZONES["EASTERN"])
    std = zone[0]
    off = std
    if zone[1]:
        # US daylight saving: 2nd Sunday in March 02:00 -> 1st Sunday in November 02:00.
        y = ctx.now.year
        t = ctx.now.unix // 60
        start = days_from_civil(y, 3, nth_sunday(y, 3, 2)) * 1440 + 120 - std
        end = days_from_civil(y, 11, nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
        if t >= start and t < end:
            off = std + 60
    return (ctx.now.unix + off * 60) // 86400

def event_type(ctx):
    v = text_input(ctx, "event", "Birthday").upper()
    if v.startswith("B"):
        return "BDAY"
    if v.startswith("A"):
        return "ANNIV"
    if v.startswith("T"):
        return "TRIP"
    return "EVENT"

def target_month(ctx):
    v = text_input(ctx, "month", "June").upper()
    if len(v) >= 3 and v[0:3] in MONTHS:
        return MONTHS.index(v[0:3]) + 1
    n = digits(v)
    if n != "" and int(n) >= 1 and int(n) <= 12:
        return int(n)
    return 6

def target_day(ctx):
    n = digits(text_input(ctx, "day", "15"))
    if n == "":
        return 15
    return max(1, min(31, int(n)))

def days_until(ctx):
    """Whole days from today to the next time the month/day comes around."""
    today = local_today(ctx)
    year = civil_from_days(today)[0]
    m = target_month(ctx)
    d = target_day(ctx)

    # A day the month doesn't have (Feb 29 off a leap year, Apr 31) lands on
    # that month's last day, so every month/day combination counts down.
    target = days_from_civil(year, m, min(d, mdays(year, m)))
    if target < today:
        target = days_from_civil(year + 1, m, min(d, mdays(year + 1, m)))
    return target - today

def title_for(c, name, kind):
    """Name plus the type's suffix, with the name trimmed until it fits.

    The name is free text: 'GRANDMA BDAY' is 58px in 4x5 and fits the 64px
    panel, 'GRANDMOTHER BDAY' is 78px and would run off both edges, so the
    name gives up letters and the suffix stays readable.
    """
    suffix = kind[0]
    if name == "":
        return kind[1]
    for i in range(len(name)):
        title = name[0:len(name) - i].strip() + suffix
        if c.text_width(title, "4x5") <= c.width - 2:
            return title
    return kind[1]

def countdown(c, ctx):
    kind = TYPES[event_type(ctx)]
    name = text_input(ctx, "name", "").upper()
    days = days_until(ctx)

    # Title, rows 0-4.
    c.text(title_for(c, name, kind), 32, 0, font="4x5", color="#11A9ED", align="center")

    if days == 0:
        # 'HAPPY ANNIV!' on one line is 69px in 5x7 and lost its '!' off the
        # right edge, so the greeting is two centered lines.
        c.text(kind[3][0], 32, 10, font="5x7", color="green", align="center")
        c.text(kind[3][1], 32, 20, font="5x7", color="green", align="center")
        return

    # Left: the 30x18 picture, centered in the rows under the title.
    c.image(kind[2], 6, 11)

    # Right: the count, padded to three digits with dim zeros so the hero
    # stays in one place as the number shrinks.
    right_x = 36
    val = "%d" % days
    lead = "0" * (3 - len(val))
    if lead:
        c.text(lead, right_x, 15, font="6x8", color="gray", align="left")
    c.text(val, right_x + len(lead) * 6, 15, font="6x8", color="#FF3333", align="left")
    c.text("DAY" if days == 1 else "DAYS", right_x, 24, font="4x5", color="gray", align="left")
