# Season Clock
#
# The year as a ring with the four solstice and equinox marks. Dates
# are the usual astronomical approximations (Mar 20, Jun 21, Sep 22,
# Dec 21), which are within a day of the true instants.



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
        ttl_seconds = 14400,
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


# name, start month, start day, colour
SEASONS = [
    ["WINTER", 12, 21, "#7FC4FF"],
    ["SPRING", 3, 20, "#6EE38A"],
    ["SUMMER", 6, 21, "#FFC53F"],
    ["AUTUMN", 9, 22, "#FF8A4A"],
]


def season_index(t):
    md = t["month"] * 100 + t["day"]
    if md >= 1221 or md < 320:
        return 0
    if md < 621:
        return 1
    if md < 922:
        return 2
    return 3


def days_to_next(t):
    idx = season_index(t)
    nxt = SEASONS[(idx + 1) % 4]
    y = t["year"]
    if nxt[1] < t["month"] or (nxt[1] == t["month"] and nxt[2] < t["day"]):
        y += 1
    return days_from_civil(y, nxt[1], nxt[2]) \
        - days_from_civil(t["year"], t["month"], t["day"])


def wheel(c, ctx):
    t = local(ctx)
    idx = season_index(t)
    c.fill("#06070E")

    wide = c.width >= 128
    r = c.height // 2 - 3
    if wide:
        name0 = SEASONS[idx][0]
        nf0 = "16x20" if c.text_width(name0, "16x20") <= 96 else "10x16"
        total = (2 * r + 1) + 8 + c.text_width(name0, nf0) + 10 + \
            c.text_width("DAY " + str(t["yday"]), "6x8")
        cx = (c.width - total) // 2 + r
    else:
        cx = c.width // 2
    cy = c.height // 2
    yspan = 366.0 if is_leap(t["year"]) else 365.0
    frac = (t["yday"] - 1) / yspan

    steps = 60
    for i in range(steps):
        a = -math.pi / 2 + 2 * math.pi * i / steps
        f = i / float(steps)
        # tint each quarter of the ring with its season
        q = 0
        if f >= 0.22 and f < 0.47:
            q = 1
        elif f >= 0.47 and f < 0.72:
            q = 2
        elif f >= 0.72 and f < 0.97:
            q = 3
        col = SEASONS[q][3] if f <= frac else "#1C2130"
        c.pixel(cx + int(math.cos(a) * r), cy + int(math.sin(a) * r), col)

    a = -math.pi / 2 + 2 * math.pi * frac
    c.fill_circle(cx + int(math.cos(a) * r), cy + int(math.sin(a) * r), 1,
                  "#FFFFFF")
    if wide:
        # Wheel, season name and day counter measured as one container with
        # tightened gaps (8px, 10px) and centred on the panel. The wheel was
        # already drawn at cx, so the text hangs off it.
        name = SEASONS[idx][0]
        nfont = "16x20" if c.text_width(name, "16x20") <= 96 else "10x16"
        day = "DAY " + str(t["yday"])
        nx = cx + r + 8
        # Bottom-aligned on a shared baseline (row 25), whatever season name
        # or day count the year serves up.
        ny = 6 if nfont == "16x20" else 10
        c.text(name, nx, ny, font = nfont, color = SEASONS[idx][3])
        c.text(day, nx + c.text_width(name, nfont) + 10, 17, font = "6x8",
               color = "#6A7090")
    else:
        c.fill_circle(cx, cy, r - 3, "#0A0B12")
        c.text(SEASONS[idx][0], cx, cy - 2, font = "4x5",
               color = SEASONS[idx][3], align = "center")


def next(c, ctx):
    t = local(ctx)
    idx = season_index(t)
    nxt = SEASONS[(idx + 1) % 4]
    n = days_to_next(t)

    c.fill("#06070E")
    if c.width >= 128:
        # "27 DAYS TO AUTUMN" as one centred container: the count big, then
        # DAYS TO stacked over the season name.
        num = str(n)
        nw = c.text_width(num, "16x20")
        rw = max(c.text_width("DAYS TO", "4x5"), c.text_width(nxt[0], "10x16"))
        x0 = (c.width - (nw + 8 + rw)) // 2
        c.text(num, x0, 8, font = "16x20", color = "#FFFFFF")
        c.text("DAYS TO", x0 + nw + 8, 8, font = "4x5", color = "#6A7090")
        c.text(nxt[0], x0 + nw + 8, 15, font = "10x16", color = nxt[3])
    else:
        c.text(SEASONS[idx][0], c.width // 2, 0, font = "4x5",
               color = SEASONS[idx][3], align = "center")
        c.text_fit(str(n), c.width // 2, 6, ["16x20", "10x16"],
                   color = "#FFFFFF", align = "center", maxw = c.width - 4)
        c.text("TO " + nxt[0], c.width // 2, 27, font = "4x5", color = nxt[3],
               align = "center")
