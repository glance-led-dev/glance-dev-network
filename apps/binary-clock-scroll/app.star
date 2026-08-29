# Binary Clock
#
# BCD gives a column per decimal digit of the time, the way a classic
# binary desk clock does. DATE is the other half of the calendar in the
# same language: one row per unit, day / month / year, in plain binary.



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


BITS = [8, 4, 2, 1]


def dot(c, x, y, r, on, accent):
    if on:
        c.fill_circle(x, y, r, accent)
    else:
        c.circle(x, y, r, "#1E2233")


def bcd(c, ctx):
    """One column per decimal digit, lit dots reading downward as 8-4-2-1."""
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#3FC8FF")
    digits = [t["hour"] // 10, t["hour"] % 10, t["minute"] // 10,
              t["minute"] % 10, t["second"] // 10, t["second"] % 10]

    c.fill("#05070E")
    r = 2 if c.width >= 128 else 1
    step = 2 * r + 3
    block = 6 * step + 2 * (2 * r + 2)
    # The dot cluster alone leaves most of a 192 panel empty, so the Scroll
    # also carries the plain reading to check yourself against. Dots and
    # clock travel as one centred group with a tight gutter -- widest the
    # reading ever gets is "23:59", so the group width never grows.
    plain = fmt.pad(t["hour"]) + ":" + fmt.pad(t["minute"])
    pw = c.text_width(plain, "16x20")
    left = (c.width - block) // 2
    if c.width >= 128:
        left = (c.width - (block + 10 + pw)) // 2
    x0 = left + r
    y0 = (c.height - 4 * step) // 2 + r + 3

    for i in range(6):
        x = x0 + i * step + (i // 2) * (2 * r + 2)
        for b in range(4):
            dot(c, x, y0 + b * step, r, digits[i] // BITS[b] % 2 == 1, accent)
    # Each label sits centred on the pair of columns it names, so the letter
    # tracks its own two digits no matter how the block is placed. The 4x5
    # cap is parked just clear of the top dot row, never on top of it.
    lab_y = y0 - r - 5
    if lab_y < 0:
        lab_y = 0
    for g in range(3):
        first = x0 + 2 * g * step + g * (2 * r + 2)
        c.text(["H", "M", "S"][g], first + (step + 1) // 2, lab_y,
               font = "4x5", color = "#4A5068", align = "center")
    if c.width >= 128:
        c.text(plain, left + block + 10 + pw, 7, font = "16x20",
               color = "#22304A", align = "right")


def date(c, ctx):
    """The date in binary: one row per unit, day / month / year."""
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#3FC8FF")
    rows = [["D", t["day"], 5], ["M", t["month"], 4], ["Y", t["year"] % 100, 7]]

    c.fill("#05070E")
    r = 2 if c.width >= 128 else 1
    step = 2 * r + 3
    # Year is the widest row at 7 bits, so it sets the block width.
    block = 6 * step + 2 * r + 1
    lab = c.text_width("D", "4x5") + 3

    # Longest reading is a fixed ten characters ("WED 25 SEP"), but measure
    # anyway and drop a font rung if it ever outgrows the safe zone.
    plain = DOW[t["weekday"]] + " " + fmt.pad(t["day"]) + " " + MON[t["month"] - 1]
    font = "8x12"
    pw = c.text_width(plain, font)
    if lab + block + 10 + pw > c.width - 20:
        font = "6x8"
        pw = c.text_width(plain, font)

    left = (c.width - (lab + block)) // 2
    if c.width >= 128:
        left = (c.width - (lab + block + 10 + pw)) // 2
    x0 = left + lab + r
    y0 = (c.height - 2 * step - 2 * r - 1) // 2 + r

    for i in range(3):
        val = rows[i][1]
        nbits = rows[i][2]
        y = y0 + i * step
        c.text(rows[i][0], left, y - 2, font = "4x5", color = "#4A5068")
        for b in range(nbits):
            place = nbits - 1 - b
            p = 1
            for k in range(place):
                p = p * 2
            dot(c, x0 + b * step, y, r, val // p % 2 == 1, accent)
    if c.width >= 128:
        c.text(plain, left + lab + block + 10,
               (c.height - (12 if font == "8x12" else 8)) // 2,
               font = font, color = "#2E4066")
