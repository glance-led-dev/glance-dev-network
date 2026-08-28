# Hex Clock
#
# HH:MM:SS reads directly as #RRGGBB, so the panel slowly walks the
# whole colour space over a day. The label flips between black and
# white depending on the background's luminance, so it stays legible
# at every hour instead of vanishing around the midpoints.



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


HEXD = "0123456789ABCDEF"


def hx(v):
    return HEXD[v // 16] + HEXD[v % 16]


def ink(r, g, b):
    """Black on light backgrounds, white on dark ones (Rec. 601 luma)."""
    return "#000000" if (r * 299 + g * 587 + b * 114) / 1000.0 > 140 else "#FFFFFF"


def parts(ctx):
    t = local(ctx)
    return [t["hour"], t["minute"], t["second"]]


def hex(c, ctx):
    p = parts(ctx)
    c.fill([p[0], p[1], p[2]])
    label = "#" + hx(p[0]) + hx(p[1]) + hx(p[2])
    col = ink(p[0], p[1], p[2])
    # 7x12 is deliberately absent from this list: it has no '#' glyph, so the
    # label would silently lose its leading character.
    c.text_fit(label, c.width // 2, (c.height - 20) // 2,
               ["16x20", "10x16", "6x8", "5x7"], color = col,
               align = "center", maxw = c.width - 6)


def channels(c, ctx):
    p = parts(ctx)
    names = ["R", "G", "B"]
    cols = ["#FF4444", "#44DD66", "#4488FF"]
    c.fill("#07070C")
    h = 6 if c.width >= 128 else 5
    gap = 3
    y = (c.height - (3 * h + 2 * gap)) // 2
    if c.width >= 128:
        # bars 20px shorter and the whole label/bar/value group centered on
        # the panel, per the audit rulings - same internal spacing.
        barw = c.width - 50
        total = 8 + barw + 4 + 9   # label+gap | bar | gap | 2-digit hex
        x0 = (c.width - total) // 2
        for i in range(3):
            yy = y + i * (h + gap)
            c.text(names[i], x0, yy - 1, font = "4x5", color = cols[i])
            c.progress_bar(x0 + 8, yy, barw, h, p[i] * 100.0 / 255.0,
                           color = cols[i], bg = "#181A24")
            c.text(hx(p[i]), x0 + total, yy - 1, font = "4x5",
                   color = "#C8D0E8", align = "right")
    else:
        for i in range(3):
            yy = y + i * (h + gap)
            c.text(names[i], 3, yy - 1, font = "4x5", color = cols[i])
            c.progress_bar(11, yy, c.width - 30, h, p[i] * 100.0 / 255.0,
                           color = cols[i], bg = "#181A24")
            c.text(hx(p[i]), c.width - 4, yy - 1, font = "4x5",
                   color = "#C8D0E8", align = "right")
