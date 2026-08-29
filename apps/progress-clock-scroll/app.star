# Progress Clock
#
# Time as completion rather than as digits. The dial page puts the day
# on a 12-hour ring so the shape of the afternoon is visible at a
# glance from across the room.



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


def spans(ctx):
    t = local(ctx)
    yspan = 366.0 if is_leap(t["year"]) else 365.0
    return [
        ["HOUR", (t["minute"] * 60.0 + t["second"]) * 100.0 / 3600.0],
        ["DAY", t["secs"] * 100.0 / 86400.0],
        ["YEAR", (t["yday"] - 1 + t["secs"] / 86400.0) * 100.0 / yspan],
    ]


SHORT = ["HR", "DY", "YR"]


def bars(c, ctx):
    accent = ctx.inputs.get("accent", "#39D98A")
    rows = spans(ctx)
    c.fill("#07080E")
    h = 6 if c.width >= 128 else 5
    gap = 4
    y = (c.height - (3 * h + 2 * gap)) // 2
    wide = c.width >= 128
    lw = 29 if wide else 17
    rw = 33 if wide else 20
    lx = 5 if wide else 2
    px = c.width - 9 if wide else c.width - 2
    for i in range(3):
        yy = y + i * (h + gap)
        label = rows[i][0] if wide else SHORT[i]
        c.text(label, lx, yy - 1, font = "4x5", color = "#6A7090")
        c.progress_bar(lw, yy, c.width - lw - rw, h, rows[i][1],
                       color = accent, bg = "#181C26")
        c.text(str(int(rows[i][1])) + "%", px, yy - 1, font = "4x5",
               color = "#C8D0E8", align = "right")


def dial(c, ctx):
    """The day drawn as a 12-hour ring, filled to the current time."""
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#39D98A")
    c.fill("#07080E")

    # On the Scroll the ring gets its own column so nothing is drawn over it;
    # on the 64 there is no room beside it, so the reading sits on a filled
    # disc that gives it a background of its own.
    wide = c.width >= 128
    r = c.height // 2 - 3
    if wide:
        # Ring, time and the AM/day column measured as one container -
        # current internal offsets kept - and centred on the panel.
        t0 = local(ctx)
        lab0 = str(h12(t0["hour"])) + ":" + fmt.pad(t0["minute"])
        tw0 = c.text_width(lab0, "16x20")
        total = (2 * r + 1) + 12 + tw0 + 5 + 18
        cx = (c.width - total) // 2 + r
    else:
        cx = c.width // 2
    cy = c.height // 2
    frac = ((t["hour"] % 12) * 3600.0 + t["minute"] * 60.0 + t["second"]) / 43200.0

    steps = 48
    for i in range(steps):
        a = -math.pi / 2 + 2 * math.pi * i / steps
        col = accent if i < int(frac * steps) else "#20242F"
        c.pixel(cx + int(math.cos(a) * r), cy + int(math.sin(a) * r), col)
        c.pixel(cx + int(math.cos(a) * (r - 1)), cy + int(math.sin(a) * (r - 1)), col)

    label = str(h12(t["hour"])) + ":" + fmt.pad(t["minute"])
    if wide:
        # The AM/PM + day column rides directly off the end of the time,
        # wherever the digit count puts it.
        tx = cx + r + 12
        c.text(label, tx, 6, font = "16x20", color = "#FFFFFF")
        ex = tx + c.text_width(label, "16x20") + 5
        c.text("AM" if t["hour"] < 12 else "PM", ex, 6, font = "6x8",
               color = accent)
        c.text(DOW[t["weekday"]], ex, 17, font = "6x8", color = "#6A7090")
    else:
        c.fill_circle(cx, cy, r - 3, "#0B0D14")
        c.text(label, cx, cy - 3, font = "6x8", color = "#FFFFFF",
               align = "center")
