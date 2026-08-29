# Sun Arc — where the sun actually is right now, and when it leaves.
#
# Page one draws the sun (or the moon, after dark) on its real arc between
# sunrise and sunset, over a sky whose colour tracks the sun's altitude. Page
# two gives the numbers: rise, set, and how much daylight today gained or lost
# against yesterday.
#
# Sunrise and sunset come from NOAA's solar position algorithm, computed from
# latitude, longitude and the day of year — no network, so the panel is never
# blank and never stale.
#
# Location comes from a US zip code: one cached lookup yields latitude and
# longitude for the solar maths, a second yields the DST-aware UTC offset used
# to print rise and set on your wall clock. ctx.now is UTC, which is exactly
# what the algorithm wants. If the lookup fails the app says so plainly instead
# of drawing a confidently wrong sun.

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

# altitude (degrees) -> [sky top, sky bottom]. Lerped between neighbours.
SKY = [
    [-18, [4, 4, 16], [10, 8, 30]],        # astronomical night
    [-6, [16, 12, 46], [58, 30, 74]],      # twilight
    [0, [70, 40, 92], [226, 116, 66]],     # horizon: purple over orange
    [8, [96, 132, 200], [242, 178, 120]],  # low sun
    [30, [58, 122, 214], [150, 200, 240]], # full day
    [70, [34, 104, 208], [126, 186, 238]],
]


def clamp(v, lo, hi):
    if v < lo:
        return lo
    return hi if v > hi else v


def lerp3(a, b, f):
    return [int(a[0] + (b[0] - a[0]) * f),
            int(a[1] + (b[1] - a[1]) * f),
            int(a[2] + (b[2] - a[2]) * f)]


def yday(y, m, d):
    n = d
    for i in range(m - 1):
        n += MDAYS[i]
    if m > 2 and ((y % 4 == 0 and y % 100 != 0) or y % 400 == 0):
        n += 1
    return n


def solar(n, lat, lon):
    """NOAA sunrise/sunset in UTC minutes, plus the solar declination.

    Returns [sunrise, sunset, declination, state] where state is 0 normally,
    1 for midnight sun and -1 for polar night — above the Arctic circle the
    hour-angle equation simply has no solution, and a panel there still has to
    show something sensible."""
    g = 2.0 * math.pi / 365.0 * (n - 1 + 0.5)
    eqtime = 229.18 * (0.000075
                       + 0.001868 * math.cos(g) - 0.032077 * math.sin(g)
                       - 0.014615 * math.cos(2 * g) - 0.040849 * math.sin(2 * g))
    decl = (0.006918
            - 0.399912 * math.cos(g) + 0.070257 * math.sin(g)
            - 0.006758 * math.cos(2 * g) + 0.000907 * math.sin(2 * g)
            - 0.002697 * math.cos(3 * g) + 0.00148 * math.sin(3 * g))

    latr = math.radians(lat)
    denom = math.cos(latr) * math.cos(decl)
    if denom > -0.000001 and denom < 0.000001:
        return [0, 1440, decl, 1]
    x = math.cos(math.radians(90.833)) / denom - math.tan(latr) * math.tan(decl)
    if x > 1.0:
        return [0, 0, decl, -1]
    if x < -1.0:
        return [0, 1440, decl, 1]
    ha = math.degrees(math.acos(x))
    return [720 - 4 * (lon + ha) - eqtime, 720 - 4 * (lon - ha) - eqtime, decl, 0]


def altitude(minutes, decl, lat, lon):
    """Solar altitude in degrees for a given UTC minute."""
    latr = math.radians(lat)
    ha = math.radians((minutes - 720) / 4.0 + lon)
    s = math.sin(latr) * math.sin(decl) + math.cos(latr) * math.cos(decl) * math.cos(ha)
    return math.degrees(math.asin(clamp(s, -1.0, 1.0)))


def sky_colors(alt):
    lo = SKY[0]
    hi = SKY[len(SKY) - 1]
    if alt <= lo[0]:
        return [lo[1], lo[2]]
    if alt >= hi[0]:
        return [hi[1], hi[2]]
    for i in range(len(SKY) - 1):
        a = SKY[i]
        b = SKY[i + 1]
        if alt >= a[0] and alt <= b[0]:
            f = (alt - a[0]) / (b[0] - a[0])
            return [lerp3(a[1], b[1], f), lerp3(a[2], b[2], f)]
    return [hi[1], hi[2]]


def hhmm(utc_minutes, off):
    m = int(utc_minutes + off * 60) % 1440
    h = m // 60
    suffix = "A" if h < 12 else "P"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return "%d:%s%s" % (h12, fmt.pad(m % 60), suffix)


def read(ctx):
    """[lat, lon, utc_offset, day_of_year, ok] for the configured zip."""
    n = yday(ctx.now.year, ctx.now.month, ctx.now.day)
    zip = str(ctx.inputs.get("zip", "")).strip()
    if zip == "":
        return [0.0, 0.0, 0.0, n, False]

    g = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if g["status_code"] != 200 or not g["json"]:
        return [0.0, 0.0, 0.0, n, False]
    places = g["json"].get("places", [])
    if not places:
        return [0.0, 0.0, 0.0, n, False]

    lat = clamp(float(places[0]["latitude"]), -89.0, 89.0)
    lon = clamp(float(places[0]["longitude"]), -180.0, 180.0)

    off = 0.0
    t = http.get(
        "https://timeapi.io/api/TimeZone/coordinate",
        params = {"latitude": places[0]["latitude"],
                  "longitude": places[0]["longitude"]},
        ttl_seconds = 3600,
    )
    if t["status_code"] == 200 and t["json"]:
        secs = t["json"].get("currentUtcOffset", {}).get("seconds", None)
        if secs != None:
            off = float(secs) / 3600.0
    return [lat, lon, off, n, True]


def no_location(c, ctx):
    """Shown when the zip is missing or the lookup is unreachable."""
    c.fill("#0A0810")
    big = "6x8" if c.width >= 128 else "4x5"
    c.text("NO LOCATION", c.width // 2, c.height // 2 - 8, font = big,
           color = "#FFD84A", align = "center")
    c.text("SET A ZIP CODE", c.width // 2, c.height // 2 + 2, font = "4x5",
           color = "#7C7C9C", align = "center")


def arc(c, ctx):
    v = read(ctx)
    if not v[4]:
        no_location(c, ctx)
        return
    lat = v[0]
    lon = v[1]
    n = v[3]

    s = solar(n, lat, lon)
    now = ctx.now.hour * 60 + ctx.now.minute
    alt = altitude(now, s[2], lat, lon)

    cols = sky_colors(alt)
    c.gradient_rect(0, 0, c.width - 1, c.height - 1, cols[0], cols[1],
                    horizontal = False)

    ground = c.height - 5
    c.rect(0, ground + 1, c.width - 1, c.height - 1, fill = "#120A18")
    c.hline(0, ground + 1, c.width, "#2A1A34")

    # The body rides a parabola between the horizons: day for the sun, and the
    # night gap for the moon, so something is always travelling.
    if s[3] == 0 and now >= s[0] and now <= s[1]:
        frac = (now - s[0]) / max(1.0, s[1] - s[0])
        body = "#FFD84A"
        glow = "#FFF3B0"
    elif s[3] == 1:
        frac = now / 1440.0
        body = "#FFD84A"
        glow = "#FFF3B0"
    else:
        night = (now - s[1]) % 1440
        span = (s[0] - s[1]) % 1440
        frac = night / max(1.0, span)
        body = "#E8E8F4"
        glow = "#FFFFFF"

    frac = clamp(frac, 0.0, 1.0)
    x = int(4 + frac * (c.width - 9))
    y = int(ground - 2 - math.sin(frac * math.pi) * (ground - 8))

    # Faint arc track so the position reads as progress, not a random dot.
    for i in range(0, c.width - 8, 4):
        f = i / float(c.width - 9)
        ty = int(ground - 2 - math.sin(f * math.pi) * (ground - 8))
        c.pixel(4 + i, ty, "#FFFFFF" if alt > 0 else "#5A5A80")

    # Black ring around the body so it separates from any sky color - the
    # pixel-art version of drawTextWithStroke (design guidelines, &sect;5).
    c.circle(x, y, 4, "black")
    c.fill_circle(x, y, 3, body)
    c.pixel(x - 1, y - 1, glow)

    label = "%s  %s" % (hhmm(s[0], v[2]), hhmm(s[1], v[2]))
    if s[3] == 1:
        label = "MIDNIGHT SUN"
    elif s[3] == -1:
        label = "POLAR NIGHT"
    c.text_stroke(label, c.width // 2, c.height - 6, font = "4x5",
                  color = "#FFFFFF", stroke = "#160C22", align = "center")


def times(c, ctx):
    v = read(ctx)
    if not v[4]:
        no_location(c, ctx)
        return
    lat = v[0]
    lon = v[1]
    off = v[2]
    n = v[3]

    s = solar(n, lat, lon)
    prev = solar(n - 1 if n > 1 else 365, lat, lon)

    c.fill("#0A0810")
    if s[3] != 0:
        c.text("MIDNIGHT SUN" if s[3] == 1 else "POLAR NIGHT", c.width // 2,
               c.height // 2 - 4, font = "6x8" if c.width >= 128 else "4x5",
               color = "#FFD84A", align = "center")
        return

    daymin = int(s[1] - s[0])
    delta = daymin - int(prev[1] - prev[0])
    sign = "+" if delta >= 0 else "-"
    dstr = "%s%d MIN" % (sign, abs(delta))

    if c.width >= 128:
        # Three columns. The rise/set figures are 10x16 and about 54px wide, so
        # the second column starts at 68 rather than mid-panel — centring it
        # ran the set time straight into the daylight readout.
        c.text("RISE", 6, 2, font = "4x5", color = "#7C7C9C")
        c.text(hhmm(s[0], off), 6, 9, font = "10x16", color = "#FFD84A")
        c.text("SET", 68, 2, font = "4x5", color = "#7C7C9C")
        c.text(hhmm(s[1], off), 68, 9, font = "10x16", color = "#FF8A3A")
        c.text("DAYLIGHT", c.width - 6, 2, font = "4x5", color = "#7C7C9C",
               align = "right")
        c.text(str(daymin // 60) + "H " + fmt.pad(daymin % 60) + "M", c.width - 6, 10,
               font = "6x8", color = "#FFFFFF", align = "right")
        c.text(dstr, c.width - 6, 21, font = "6x8", color = "#78DCFF",
               align = "right")
    else:
        c.text("RISE " + hhmm(s[0], off), 2, 1, font = "4x5", color = "#FFD84A")
        c.text("SET  " + hhmm(s[1], off), 2, 8, font = "4x5", color = "#FF8A3A")
        c.text(str(daymin // 60) + "H " + fmt.pad(daymin % 60) + "M", c.width // 2, 15,
               font = "6x8", color = "#FFFFFF", align = "center")
        c.text(dstr, c.width // 2, 25, font = "4x5", color = "#78DCFF",
               align = "center")
