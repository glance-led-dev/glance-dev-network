# Night Board — a board that dims itself after bedtime.
#
# The ticker's own brightness setting is one fixed level, so this app does
# the dimming in the drawing instead: every colour is passed through
# color.dim() during the night window (Dim from -> Bright again from), and
# drawn at full strength the rest of the day. Put it in a profile on its own
# and schedule that profile for the night, and the panel stays on all night
# without lighting up the room.
#
# Pages: the time, a verse for the day (rotates daily, no network), and the
# sober day count. Local time follows the Flip Clock pattern — a US zone
# dropdown resolved in-app, daylight saving applied automatically, so a
# dead API can never cost the board its clock or its dimming window.

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
DOW_FULL = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY",
            "SATURDAY", "SUNDAY"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

VERSES = [
    ["BE STILL AND KNOW THAT I AM GOD", "PSALM 46:10"],
    ["THE LORD IS MY SHEPHERD I SHALL NOT WANT", "PSALM 23:1"],
    ["HIS MERCIES NEVER COME TO AN END", "LAM 3:22"],
    ["YOUR WORD IS A LAMP TO MY FEET", "PSALM 119:105"],
    ["I CAN DO ALL THINGS THROUGH HIM", "PHIL 4:13"],
    ["THE JOY OF THE LORD IS MY STRENGTH", "NEH 8:10"],
    ["WAIT FOR THE LORD BE STRONG", "PSALM 27:14"],
    ["HE GIVES POWER TO THE FAINT", "ISAIAH 40:29"],
    ["CAST ALL YOUR ANXIETY ON HIM", "1 PETER 5:7"],
    ["MY GRACE IS SUFFICIENT FOR YOU", "2 COR 12:9"],
    ["BE STRONG AND COURAGEOUS", "JOSHUA 1:9"],
    ["THE LORD IS MY LIGHT AND MY SALVATION", "PSALM 27:1"],
]

US_ZONES = {"EASTERN": -300, "CENTRAL": -360, "MOUNTAIN": -420, "PACIFIC": -480}


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


def _nth_sunday(y, m, n):
    """Day of the month of the nth Sunday. 1970-01-01 was a Thursday."""
    wd = (days_from_civil(y, m, 1) + 4) % 7      # 0 = Sunday
    return 1 + (7 - wd) % 7 + 7 * (n - 1)


def offset_hours(ctx):
    """UTC offset for the chosen US zone, daylight saving already applied."""
    zone = str(ctx.inputs.get("timezone", "EASTERN")).strip().upper()
    std = US_ZONES.get(zone, -300)
    t = ctx.now.unix // 60
    y = ctx.now.year
    start = days_from_civil(y, 3, _nth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = days_from_civil(y, 11, _nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    off = std + 60 if (t >= start and t < end) else std
    return off / 60.0


def local(ctx):
    """ctx.now shifted onto the viewer's wall clock."""
    shifted = ctx.now.unix + int(offset_hours(ctx) * 3600)
    days = shifted // 86400
    secs = shifted % 86400
    weekday = (days + 3) % 7           # 1970-01-01 was a Thursday
    y = 1970
    for i in range(400):
        span = 366 if is_leap(y) else 365
        if days < span:
            break
        days -= span
        y += 1
    m = 0
    yd = days
    for i in range(12):
        span = MDAYS[m] + (1 if (m == 1 and is_leap(y)) else 0)
        if days < span:
            break
        days -= span
        m += 1
    return {"year": y, "month": m + 1, "day": days + 1, "weekday": weekday,
            "yday": yd + 1, "hour": secs // 3600,
            "minute": (secs % 3600) // 60}


def parse_hm(s):
    """'2230' (HHMM, no colon — input values cannot carry one) -> minutes
    since midnight. Falls back to 22:30 on junk."""
    t = str(s)
    if len(t) != 4 or not t.isdigit():
        return 22 * 60 + 30
    h = int(t[0:2])
    m = int(t[2:4])
    if h < 0 or h > 23 or m < 0 or m > 59:
        return 22 * 60 + 30
    return h * 60 + m


def night_pct(ctx, loc):
    """The brightness percent in force right now: night_pct inside the
    night window, 100 outside it. The window wraps midnight."""
    start = parse_hm(ctx.inputs.get("nightstart", "2230"))
    end = parse_hm(ctx.inputs.get("nightend", "0745"))
    now = loc["hour"] * 60 + loc["minute"]
    if start <= end:
        night = now >= start and now < end
    else:
        night = now >= start or now < end
    if not night:
        return 100
    p = str(ctx.inputs.get("nightpct", "25"))
    return int(p) if p.isdigit() else 25


def dim(col, pct):
    """A colour at pct% brightness (identity at 100)."""
    if pct >= 100:
        return col
    return color.dim(col, pct)


def h12(h):
    v = h % 12
    return 12 if v == 0 else v


def clock(c, ctx):
    loc = local(ctx)
    pct = night_pct(ctx, loc)
    accent = ctx.inputs.get("accent", "#E8B33A")

    c.fill("#04050A")
    c.text(DOW_FULL[loc["weekday"]], c.width // 2, 0, font = "4x5",
           color = dim("#8A8AA8", pct), align = "center")
    mm = loc["minute"]
    t = "%d:%s" % (h12(loc["hour"]), ("0" + str(mm)) if mm < 10 else str(mm))
    c.text_fit(t, c.width // 2, 7, ["10x16", "7x12"],
               color = dim("#FFFFFF", pct), align = "center", maxw = c.width - 2)
    ampm = "AM" if loc["hour"] < 12 else "PM"
    foot = "%s %d · %s" % (MON[loc["month"] - 1], loc["day"], ampm)
    c.text(foot, c.width // 2, 26, font = "4x5",
           color = dim(accent, pct), align = "center")


def wrap(text, per):
    """Greedy word wrap at `per` characters a line."""
    lines = []
    cur = ""
    for w in text.split(" "):
        if cur == "":
            cur = w
        elif len(cur) + 1 + len(w) <= per:
            cur = cur + " " + w
        else:
            lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    return lines


def verse(c, ctx):
    loc = local(ctx)
    pct = night_pct(ctx, loc)
    accent = ctx.inputs.get("accent", "#E8B33A")
    v = VERSES[(loc["yday"] - 1) % len(VERSES)]

    c.fill("#04050A")
    lines = wrap(v[0], 12)
    total = len(lines) * 6 - 1
    y = (c.height - 7 - total) // 2 + 6
    c.text(v[1], c.width // 2, 0, font = "4x5",
           color = dim(accent, pct), align = "center")
    for line in lines:
        c.text(line, c.width // 2, y, font = "4x5",
               color = dim("#FFFFFF", pct), align = "center")
        y += 6


DIGITS = "0123456789"


def parse_date(s):
    """A date setting -> [y, m, d]. Digits only, first eight, hand-checked."""
    ds = ""
    t = str(s)
    for i in range(len(t)):
        if DIGITS.find(t[i]) >= 0:
            ds = ds + t[i]
    if len(ds) < 8:
        return [2026, 1, 1]
    out = [int(ds[0:4]), int(ds[4:6]), int(ds[6:8])]
    if out[0] < 1900 or out[1] < 1 or out[1] > 12 or out[2] < 1 or out[2] > 31:
        return [2026, 1, 1]
    return out


def counter(c, ctx):
    loc = local(ctx)
    pct = night_pct(ctx, loc)
    accent = ctx.inputs.get("accent", "#E8B33A")
    start = parse_date(ctx.inputs.get("since", "2025-08-29"))
    n = days_from_civil(loc["year"], loc["month"], loc["day"]) - \
        days_from_civil(start[0], start[1], start[2])

    c.fill("#04050A")
    c.text("DAYS SOBER", c.width // 2, 0, font = "4x5",
           color = dim(accent, pct), align = "center")
    if n < 0:
        c.text_fit(fmt.commas(-n), c.width // 2, 6, ["16x20", "10x16", "7x12"],
                   color = dim("#8A8AA8", pct), align = "center",
                   maxw = c.width - 4)
        c.text("TO GO", c.width // 2, 26, font = "4x5",
               color = dim(accent, pct), align = "center")
        return
    c.text_fit(fmt.commas(n), c.width // 2, 6, ["16x20", "10x16", "7x12"],
               color = dim("#FFFFFF", pct), align = "center", maxw = c.width - 4)
    c.text("DAY BY DAY", c.width // 2, 27, font = "4x5",
           color = dim("#8A8AA8", pct), align = "center")
