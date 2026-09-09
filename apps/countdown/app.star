# Countdown - days remaining until an event. (128x32)
# Today is ctx.now shifted to Eastern; the target comes from the `date` input.

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

def mdays(y, m):
    if m == 2 and is_leap(y):
        return 29
    return MDAYS[m - 1]

def _days_from_civil(y, m, d):
    # Days since 1970-01-01. Subtracting two of these gives an exact day count
    # that accounts for leap years -- the old (year diff * 365) drifted by a day
    # for every Feb 29 between now and the target.
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _is_num(s):
    if len(s) == 0:
        return False
    for i in range(len(s)):
        if s[i] < "0" or s[i] > "9":
            return False
    return True

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

def _digits(s):
    out = ""
    for i in range(len(s)):
        ch = s[i]
        if ch >= "0" and ch <= "9":
            out = out + ch
    return out


def _target_date(ctx):
    """[year, month, day] from the date setting, or None if unusable.

    This used to be date.split("-") with all three parts required to be
    numeric, which assumed the value arrives as exactly "YYYY-MM-DD". The
    picker sends a full ISO stamp, and it does not survive the trip intact:

      saved      date-2026-08-14T01:12:57.000Z
      delivered  2026-08-14T01

    The render descriptor is colon-separated at the top level
    (GDN:W:H:app:pages:ttl:inputs), so the time's own colons end the value --
    it is cut at the first one. "14T01" then failed _is_num() and the panel
    showed SET DATE / YYYY-MM-DD, which reads as the date never having been
    saved at all.

    The day itself always survives that cut, since it sits before the "T", so
    reducing to digits and taking the first eight recovers it. That also
    accepts a plain "YYYY-MM-DD" unchanged.
    """
    ds = _digits(_s(ctx, "date", ""))
    if len(ds) < 8:
        return None
    ty = int(ds[0:4])
    tm = int(ds[4:6])
    td = int(ds[6:8])
    if tm < 1 or tm > 12 or td < 1 or td > mdays(ty, tm):
        return None
    return [ty, tm, td]


# ctx.now is UTC. The day flips at midnight Eastern, which is where this event
# lives, so the date is shifted by the Eastern offset with US daylight saving
# applied (2nd Sunday in March 02:00 -> 1st Sunday in November 02:00).


def _edfc(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def _enth_sunday(y, m, n):
    wd = (_edfc(y, m, 1) + 4) % 7      # 0 = Sunday; 1970-01-01 was a Thursday
    return 1 + (7 - wd) % 7 + 7 * (n - 1)


def eastern_offset_minutes(ctx):
    std = -300
    t = ctx.now.unix // 60
    y = ctx.now.year
    start = _edfc(y, 3, _enth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = _edfc(y, 11, _enth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    return std + 60 if (t >= start and t < end) else std


def days(c, ctx):
    event = _s(ctx, "event", "EVENT").upper()

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text(event, c.width // 2, 1, font = fit_font(c, event, ["5x7", "4x5"], c.width - 4), color = "white", align = "center")

    target_ymd = _target_date(ctx)
    if target_ymd == None:
        c.text("SET DATE", c.width // 2, 13, font = "6x8", color = "red", align = "center")
        c.text("PICK A DAY", c.width // 2, 24, font = "4x5", color = "gray", align = "center")
        return
    ty = target_ymd[0]
    tm = target_ymd[1]
    td = target_ymd[2]

    today = (ctx.now.unix + eastern_offset_minutes(ctx) * 60) // 86400
    left = _days_from_civil(ty, tm, td) - today
    target = MONTHS[tm - 1] + " " + str(td) + " " + str(ty)

    # ----- the two states with no number to show -----
    if left < 0:
        c.text("PASSED", c.width // 2, 12, font = "7x12", color = "gray", align = "center")
        c.text(target, c.width // 2, 26, font = "4x5", color = "#555a66", align = "center")
        return

    if left == 0:
        c.text("TODAY", c.width // 2, 12, font = "10x16", color = "yellow", align = "center")
        return

    # ----- the count -----
    # Closer events read hotter, so the color carries urgency at a glance.
    if left <= 7:
        col = "red"
    elif left <= 30:
        col = "orange"
    else:
        col = "yellow"

    num = str(left)

    # Number on the left, sized to leave room for the label column beside it.
    nfont = fit_font(c, num, ["16x20", "10x16", "7x12"], 78)
    nw = c.text_width(num, nfont)
    c.text(num, 5, 10, font = nfont, color = col)

    # Label column: unit on top, the actual target date under it, both left
    # aligned to the same edge so they read as one block.
    lx = 5 + nw + 6
    lw = c.width - lx - 4

    unit = "DAYS" if left != 1 else "DAY"
    c.text(unit, lx, 11, font = fit_font(c, unit, ["7x12", "6x8", "5x7"], lw), color = "white")
    c.text(target, lx, 25, font = fit_font(c, target, ["4x5", "picopixel"], lw), color = "gray")