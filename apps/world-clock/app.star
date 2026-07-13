# World Clock — local time, sunrise & sunset for a US zip code. (2 pages)
#
# Shows off: a config input (zip), a bundled lookup table, real trig via the
# `math` module, and multi-page layout. Runs fully offline — no API needed.
#
# You draw with `c` (mirrors the GDN Canvas) and read config from `ctx.inputs`.
# `ctx.now` is the current UTC time. Each page in manifest.yaml maps to a
# function `def <page>(c, ctx)`.

# zip -> (city, latitude, longitude, utc_offset_std_hours, observes_dst)
ZIPS = {
    "10001": ("NEW YORK", 40.75, -74.00, -5, True),
    "02108": ("BOSTON", 42.36, -71.06, -5, True),
    "33101": ("MIAMI", 25.77, -80.19, -5, True),
    "60601": ("CHICAGO", 41.88, -87.62, -6, True),
    "73301": ("AUSTIN", 30.27, -97.74, -6, True),
    "80202": ("DENVER", 39.74, -104.99, -7, True),
    "85001": ("PHOENIX", 33.45, -112.07, -7, False),
    "90210": ("BEVERLY HILLS", 34.07, -118.40, -8, True),
    "94103": ("SAN FRANCISCO", 37.77, -122.42, -8, True),
    "98101": ("SEATTLE", 47.61, -122.33, -8, True),
    "99501": ("ANCHORAGE", 61.22, -149.90, -9, True),
    "96813": ("HONOLULU", 21.31, -157.86, -10, False),
}
DEFAULT = ("UNKNOWN", 39.0, -98.0, -6, True)

WEEKDAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0]]
DOWN = [[0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]

def lookup(zip):
    return ZIPS.get(zip, DEFAULT)

def offset(info, month):
    """UTC offset including a rough US daylight-saving window (Mar–Nov)."""
    base = info[3]
    if info[4] and month >= 3 and month <= 11:
        return base + 1
    return base

def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v

def to_hm(h):
    """Fractional hours -> (hour, minute), wrapped into a day."""
    h = math.fmod(h, 24.0)
    if h < 0:
        h = h + 24.0
    hour = int(h)
    return hour, int((h - hour) * 60.0)

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def fmt12(hour, minute):
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + pad2(minute), ap

def local_time(ctx, off):
    secs = ctx.now.unix + off * 3600
    sod = secs % 86400
    return sod // 3600, (sod % 3600) // 60

def sun_times(info, yday, off):
    """Sunrise/sunset as (hour, minute) local, via the sunrise equation."""
    lat = info[1]
    lon = info[2]
    decl = 23.45 * math.sin(math.radians(360.0 / 365.0 * (yday - 81)))
    cosw = -math.tan(math.radians(lat)) * math.tan(math.radians(decl))
    w = math.degrees(math.acos(clamp(cosw, -1.0, 1.0))) / 15.0
    noon = 12.0 - lon / 15.0 + off
    return to_hm(noon - w), to_hm(noon + w)

def clock(c, ctx):
    info = lookup(ctx.inputs["zip"])
    off = offset(info, ctx.now.month)
    lh, lm = local_time(ctx, off)
    tstr, ap = fmt12(lh, lm)

    # Day or night? Compare "now" to today's sunrise/sunset, then draw the icon.
    sunrise, sunset = sun_times(info, ctx.now.yday, off)
    now_min = lh * 60 + lm
    is_day = now_min >= sunrise[0] * 60 + sunrise[1] and now_min < sunset[0] * 60 + sunset[1]

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text(info[0], c.width // 2, 1, font = "5x7", color = "white", align = "center")

    # A custom PNG icon you dropped in this folder, listed under `assets:`.
    c.image("sun.png" if is_day else "moon.png", c.width - 13, 10, w = 11, h = 11)

    c.text(tstr, 3, 11, font = "16x20", color = "white")
    c.text(ap, 6 + c.text_width(tstr, "16x20"), 13, font = "6x8", color = "yellow")

    date = WEEKDAYS[ctx.now.weekday] + " " + MONTHS[ctx.now.month - 1] + " " + str(ctx.now.day)
    c.text(date, c.width - 3, 25, font = "4x5", color = "gray", align = "right")

def sun(c, ctx):
    info = lookup(ctx.inputs["zip"])
    off = offset(info, ctx.now.month)
    sunrise, sunset = sun_times(info, ctx.now.yday, off)
    sr, srap = fmt12(sunrise[0], sunrise[1])
    ss, ssap = fmt12(sunset[0], sunset[1])

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "orange")
    c.text(info[0], c.width // 2, 1, font = "5x7", color = "black", align = "center")

    c.bitmap(UP, 4, 12, "yellow")
    c.text("RISE", 13, 12, font = "5x7", color = "yellow")
    c.text(sr + " " + srap, 46, 12, font = "5x7", color = "white")

    c.bitmap(DOWN, 4, 22, "orange")
    c.text("SET", 13, 22, font = "5x7", color = "orange")
    c.text(ss + " " + ssap, 46, 22, font = "5x7", color = "white")
