# Ported from the tidbyt/community "Big Clock" app (apps/bigclock/big_clock.star).
#
# ORIGINAL Pixlet: a large retro clock built from base64 PNG number images tinted
# by a render.Box, laid out in a render.Row (HH : MM) with a flashing separator,
# animated across a minute; the color fades between day/night using the sunrise
# module and the configured location. Supports 12/24h and a leading zero.
#
# `gdn translate` converted the schema (Location + toggles) and flagged
# sunrise/time/re/base64/json/load() and the Row/Box/Image/Animation widgets.
# Hand-finished for GDN (static 64x32): the base64 number images became a big
# bitmap FONT; ctx.now is UTC so time is computed from a UTC-offset input; the
# 12/24h + leading-zero LOGIC ports; the flashing separator is a static colon.
#
# The original's sunrise fade is restored here as a smooth interpolation across
# the day rather than a hard day/night switch -- same intent, no network call.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DOW = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

# Keyframes across the 1440 minutes of a day: [minute, [r,g,b]].
# Deep blue overnight, orange through both golden hours, warm white at noon.
KEYS = [
    [0,    [90, 120, 200]],
    [300,  [110, 135, 210]],
    [390,  [255, 168, 92]],    # sunrise
    [480,  [255, 226, 150]],
    [720,  [255, 248, 220]],   # noon
    [1020, [255, 230, 160]],
    [1110, [255, 150, 74]],    # sunset
    [1200, [140, 140, 215]],
    [1290, [95, 122, 202]],
    [1440, [90, 120, 200]],
]

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def _lerp(a, b, t):
    return int(a + (b - a) * t + 0.5)

def _hex(c):
    def hh(v):
        d = "0123456789ABCDEF"
        return d[v // 16] + d[v % 16]
    return "#" + hh(c[0]) + hh(c[1]) + hh(c[2])

def _color_at(mins):
    for i in range(len(KEYS) - 1):
        m0 = KEYS[i][0]
        m1 = KEYS[i + 1][0]
        if mins >= m0 and mins < m1:
            t = float(mins - m0) / float(m1 - m0)
            a = KEYS[i][1]
            b = KEYS[i + 1][1]
            return _hex([_lerp(a[0], b[0], t), _lerp(a[1], b[1], t), _lerp(a[2], b[2], t)])
    return _hex(KEYS[0][1])

def _dim(col, amt):
    # Pull a color toward black so the small text sits behind the big time.
    d = "0123456789ABCDEF"
    out = "#"
    for i in range(3):
        hi = d.index(col[1 + i * 2])
        lo = d.index(col[2 + i * 2])
        v = int((hi * 16 + lo) * amt)
        out = out + d[v // 16] + d[v % 16]
    return out

def _civil_from_days(z):
    # Days since 1970-01-01 -> (year, month, day), so the date matches the
    # OFFSET time rather than UTC.
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return y, m, d

def main(c, ctx):
    off = int(ctx.inputs.get("tz_offset", -5))
    fmt = ctx.inputs.get("hour_format", "24")
    lz = ctx.inputs.get("leading_zero", "no")

    local = ctx.now.unix + off * 3600
    secs = local % 86400
    hh = secs // 3600
    mm = (secs % 3600) // 60

    days = (local - secs) // 86400
    year, month, day = _civil_from_days(days)
    dow = DOW[(days + 4) % 7]

    ampm = ""
    if fmt == "12":
        ampm = "AM" if hh < 12 else "PM"
        h = hh % 12
        if h == 0:
            h = 12
    else:
        h = hh

    hh_str = pad2(h) if lz == "yes" else str(h)
    time_str = hh_str + ":" + pad2(mm)

    mins = hh * 60 + mm
    color = _color_at(mins)
    faint = _dim(color, 0.55)

    c.fill("black")

    # ----- top strip: day of week left, AM/PM right -----
    c.text(dow, 1, 1, font = "4x5", color = faint)
    if ampm != "":
        c.text(ampm, c.width - 1, 1, font = "4x5", color = faint, align = "right")

    # ----- the time, unchanged in size and position -----
    c.text(time_str, c.width // 2, 8, font = "10x16_bold", color = color, align = "center")

    # ----- date under it -----
    date_s = MONTHS[month - 1] + " " + str(day)
    c.text(date_s, c.width // 2, 25, font = "4x5", color = faint, align = "center")

    # ----- how far through the day, along the bottom edge -----
    filled = int((float(mins) / 1440.0) * float(c.width - 2) + 0.5)
    c.rect(1, 31, c.width - 2, 31, fill = "#1A1F2E")
    if filled > 0:
        c.rect(1, 31, 1 + filled, 31, fill = color)