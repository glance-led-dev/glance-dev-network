# Math Clock
#
# Every hour and minute is rendered as an expression that evaluates to
# it. The expression is picked from the clock, so it is stable within
# a minute rather than flickering between renders.



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


def offset_hours(ctx):
    """Real UTC offset for the configured zip, DST already applied.

    Two cached hops: zip -> lat/lon, then lat/lon -> offset. Any failure falls
    back to UTC, so a dead API costs you the timezone, not the panel."""
    zip = str(ctx.inputs.get("zip", "")).strip()
    if zip == "":
        return 0.0
    g = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if g["status_code"] != 200 or not g["json"]:
        return 0.0
    places = g["json"].get("places", [])
    if not places:
        return 0.0
    t = http.get(
        "https://timeapi.io/api/TimeZone/coordinate",
        params = {"latitude": places[0]["latitude"],
                  "longitude": places[0]["longitude"]},
        ttl_seconds = 3600,
    )
    if t["status_code"] != 200 or not t["json"]:
        return 0.0
    secs = t["json"].get("currentUtcOffset", {}).get("seconds", None)
    if secs == None:
        return 0.0
    return float(secs) / 3600.0


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
            "yday": yd + 1, "hour": secs // 3600, "minute": (secs % 3600) // 60,
            "second": secs % 60, "secs": secs, "unix": shifted}


def h12(h):
    v = h % 12
    return 12 if v == 0 else v


def lcg(state):
    return (state * 1103515245 + 12345) % 2147483648


def seeded(n):
    return (n * 2654435761) % 2147483647 + 1


def expr(n, state):
    """A small expression equal to n. Falls back to the plain number."""
    forms = []
    for a in range(2, 13):
        if n % a == 0 and n // a > 1 and n // a < 13:
            forms.append(str(a) + "X" + str(n // a))
    for a in range(1, n):
        if n - a > 0 and a < 60 and n - a < 60:
            forms.append(str(a) + "+" + str(n - a))
            break
    if n < 59:
        forms.append(str(n + 1) + "-1")
    if len(forms) == 0:
        return str(n)
    return forms[(state // 512) % len(forms)]


def solve(c, ctx):
    t = local(ctx)
    state = seeded(t["unix"] // 60)
    hh = expr(h12(t["hour"]), state)
    state = lcg(state)
    mm = expr(t["minute"] if t["minute"] > 0 else 60, state)

    c.fill("#07060E")
    if c.width >= 128:
        c.text(hh, c.width // 2 - 8, 8, font = "16x20", color = "#FFD84A",
               align = "right")
        c.text(":", c.width // 2, 12, font = "10x16", color = "#5A5A78",
               align = "center")
        c.text(mm, c.width // 2 + 8, 8, font = "16x20", color = "#7FD4FF")
        c.text("SOLVE THE TIME", c.width // 2, 1, font = "4x5",
               color = "#4A4A66", align = "center")
    else:
        c.text_fit(hh, c.width // 2, 3, ["10x16", "7x12", "6x8"],
                   color = "#FFD84A", align = "center", maxw = c.width - 4)
        c.text_fit(mm, c.width // 2, 18, ["10x16", "7x12", "6x8"],
                   color = "#7FD4FF", align = "center", maxw = c.width - 4)
