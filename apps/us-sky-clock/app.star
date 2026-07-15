# US Clock (192x32)
#
# ctx.now is UTC. A US zone is "UTC minus N hours", where N shifts by one for
# daylight saving. Steps: read UTC -> decide DST -> apply offset (rolling the
# date across midnight) -> draw a sky that matches the local time of day.
#
# The sky, the clock color, and the sun/moon all interpolate smoothly from a
# set of keyframes across the 1440 minutes of a day. Nothing is hard-cut.

WHITE = "#FFFFFF"
MUTED = "#8894AE"

ZONES = {
    "EASTERN":  [-5, True],
    "CENTRAL":  [-6, True],
    "MOUNTAIN": [-7, True],
    "ARIZONA":  [-7, False],
    "PACIFIC":  [-8, True],
    "ALASKA":   [-9, True],
    "HAWAII":   [-10, False],
}
ZONE_ABBR = {
    "EASTERN":  ["EST", "EDT"],
    "CENTRAL":  ["CST", "CDT"],
    "MOUNTAIN": ["MST", "MDT"],
    "ARIZONA":  ["MST", "MST"],
    "PACIFIC":  ["PST", "PDT"],
    "ALASKA":   ["AKST", "AKDT"],
    "HAWAII":   ["HST", "HST"],
}
DOW  = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MON  = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

DIVX = 112
SKY0 = 114

# ---------- time-of-day palette ----------
# Each keyframe: [minute, sky_top, sky_bottom, clock_color].
# Colors are [r,g,b]. We lerp between the two keyframes we're between.
KEYS = [
    [0,    [10, 14, 36],  [26, 38, 80],  [66, 105, 184]],   # deep night
    [300,  [24, 28, 62],  [60, 60, 110], [90, 120, 190]],   # pre-dawn
    [390,  [235, 140, 80],[120, 90, 140],[255, 168, 92]],   # sunrise (orange)
    [480,  [70, 150, 210],[150, 200, 230],[255, 240, 180]], # morning
    [720,  [44, 107, 173],[130, 185, 225],[255, 250, 232]], # noon
    [1020, [58, 135, 200],[140, 190, 228],[255, 240, 190]], # afternoon
    [1110, [232, 118, 68],[150, 92, 120], [255, 150, 74]],  # sunset (orange)
    [1200, [40, 38, 92],  [70, 62, 120],  [120, 120, 200]], # dusk
    [1290, [16, 20, 50],  [30, 40, 84],   [80, 110, 190]],  # night
    [1440, [10, 14, 36],  [26, 38, 80],   [66, 105, 184]],  # wrap to deep night
]

def _lerp(a, b, t):
    return int(a + (b - a) * t + 0.5)

def _mix(c1, c2, t):
    return [_lerp(c1[0], c2[0], t), _lerp(c1[1], c2[1], t), _lerp(c1[2], c2[2], t)]

def _hex(c):
    def hh(v):
        d = "0123456789ABCDEF"
        return d[v // 16] + d[v % 16]
    return "#" + hh(c[0]) + hh(c[1]) + hh(c[2])

def _palette(mins):
    # returns (top_rgb, bottom_rgb, clock_rgb) for a given minute of the day
    for i in range(len(KEYS) - 1):
        m0 = KEYS[i][0]
        m1 = KEYS[i + 1][0]
        if mins >= m0 and mins < m1:
            t = float(mins - m0) / float(m1 - m0)
            top = _mix(KEYS[i][1], KEYS[i + 1][1], t)
            bot = _mix(KEYS[i][2], KEYS[i + 1][2], t)
            clk = _mix(KEYS[i][3], KEYS[i + 1][3], t)
            return top, bot, clk
    return KEYS[0][1], KEYS[0][2], KEYS[0][3]

# ---------- reading ctx.now ----------

def _field(now, names, fallback):
    for n in names:
        v = getattr(now, n, None)
        if v != None:
            return int(v)
    return fallback

def _utc_parts(ctx):
    now = ctx.now
    return {
        "y":  _field(now, ["year"], 2026),
        "mo": _field(now, ["month"], 1),
        "d":  _field(now, ["day"], 1),
        "h":  _field(now, ["hour"], 0),
        "mi": _field(now, ["minute"], 0),
    }

# ---------- calendar ----------

def _leap(y):
    if y % 4 != 0:
        return False
    if y % 100 != 0:
        return True
    return y % 400 == 0

def _mdays(y, mo):
    if mo == 2 and _leap(y):
        return 29
    return MDAYS[mo - 1]

def _days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _dow_sun0(y, m, d):
    return (_days_from_civil(y, m, d) + 4) % 7

def _nth_sunday(y, month, nth):
    fd = _dow_sun0(y, month, 1)
    first_sun = 1 + ((7 - fd) % 7)
    return first_sun + (nth - 1) * 7

def _is_dst(y, mo, d, h):
    start = _nth_sunday(y, 3, 2)
    end = _nth_sunday(y, 11, 1)
    if mo < 3 or mo > 11:
        return False
    if mo > 3 and mo < 11:
        return True
    if mo == 3:
        if d > start:
            return True
        if d < start:
            return False
        return h >= 2
    if d < end:
        return True
    if d > end:
        return False
    return h < 2

def _shift(p, off):
    y = p["y"]
    mo = p["mo"]
    d = p["d"]
    h = p["h"] + off
    for _ in range(3):
        if h < 0:
            h = h + 24
            d = d - 1
            if d < 1:
                mo = mo - 1
                if mo < 1:
                    mo = 12
                    y = y - 1
                d = _mdays(y, mo)
        elif h >= 24:
            h = h - 24
            d = d + 1
            if d > _mdays(y, mo):
                d = 1
                mo = mo + 1
                if mo > 12:
                    mo = 1
                    y = y + 1
        else:
            break
    return {"y": y, "mo": mo, "d": d, "h": h, "mi": p["mi"]}

def _pad2(n):
    if n < 10:
        return "0" + str(n)
    return str(n)

def _hash(n):
    n = (n * 2654435761) % 2147483647
    n = (n ^ (n // 65536)) % 2147483647
    return n

# ---------- sky ----------

def _sky_color_at(top, bot, y):
    # the gradient color at row y (0..31), used both to paint the sky and to
    # sample the exact background behind the moon so its shadow bite is invisible
    t = float(y) / 31.0
    return _mix(top, bot, t)

def _draw_sky(c, top, bot):
    for y in range(32):
        col = _hex(_sky_color_at(top, bot, y))
        c.rect(SKY0, y, c.width - 1, y, fill=col)

def _draw_stars(c, seed, brightness):
    # brightness 0..1: how visible stars are (fade out near daylight)
    if brightness <= 0.0:
        return
    mx = 150
    my = 11
    for i in range(30):
        x = SKY0 + 1 + _hash(i * 3 + seed) % (c.width - SKY0 - 2)
        y = 1 + _hash(i * 7 + seed + 5) % 27
        if (x - mx) * (x - mx) + (y - my) * (y - my) < 100:
            continue
        b = _hash(i * 5 + seed + 9) % 3
        base = [58, 68, 106]
        if b == 1:
            base = [138, 150, 192]
        elif b == 2:
            base = [234, 238, 255]
        col = _mix([12, 16, 40], base, brightness)   # fade toward sky at dawn
        c.pixel(x, y, _hex(col))

def _draw_moon(c, top, bot, glow):
    # glow 0..1: how bright the moon is (fades near daylight)
    mx = 150
    my = 11
    r = 8
    lit = _mix([40, 46, 90], [233, 236, 247], glow)   # dim moon near dawn
    litc = _hex(lit)

    # lit disc
    c.fill_circle(mx, my, r, litc)

    # shadow bite: paint it in the SKY color sampled at the moon's rows, so the
    # bite reads as empty sky, not a second circle. Offset gives the crescent.
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > r * r:
                continue
            sx = dx - 5
            sy = dy + 2
            if sx * sx + sy * sy <= r * r:
                col = _sky_color_at(top, bot, my + dy)
                c.pixel(mx + dx, my + dy, _hex(col))

    # a few craters on the remaining lit crescent (left edge)
    craters = [[-4, -3], [-5, 2], [-3, 4], [-6, -1]]
    crat = _hex(_mix(lit, [0, 0, 0], 0.18))
    for cc in craters:
        sx = cc[0] - 5
        sy = cc[1] + 2
        if sx * sx + sy * sy > r * r:
            c.pixel(mx + cc[0], my + cc[1], crat)

def _draw_sun(c, glow):
    sx = 152
    sy = 10
    core = _mix([255, 180, 70], [255, 210, 90], glow)
    c.fill_circle(sx, sy, 8, _hex(core))
    c.fill_circle(sx, sy, 5, "#FFE79A")
    for a in [[0, -11], [0, 11], [-11, 0], [11, 0], [-8, -8], [8, -8], [-8, 8], [8, 8]]:
        c.pixel(sx + a[0], sy + a[1], "#FFDE7A")

def _draw_clouds(c, amt):
    if amt <= 0.0:
        return
    c.fill_circle(128, 28, 3, "#DCE8F2")
    c.fill_circle(132, 28, 4, "#EAF2FA")
    c.fill_circle(137, 29, 3, "#DCE8F2")
    c.fill_circle(170, 30, 3, "#CBD9E8")
    c.fill_circle(175, 30, 4, "#DCE8F2")

# ---------- page ----------

def clock(c, ctx):
    zone = ctx.inputs.get("zone", "EASTERN").upper()
    if zone not in ZONES:
        zone = "EASTERN"

    base = ZONES[zone][0]
    observes = ZONES[zone][1]

    p = _utc_parts(ctx)
    dst = observes and _is_dst(p["y"], p["mo"], p["d"], p["h"])
    off = base + (1 if dst else 0)
    t = _shift(p, off)

    mins = t["h"] * 60 + t["mi"]
    top, bot, clk = _palette(mins)
    clock_col = _hex(clk)

    # how "day" is it, 0..1, for fading stars/moon vs sun/clouds
    h = t["h"]
    if h >= 8 and h < 17:
        dayness = 1.0
    elif h >= 6 and h < 8:
        dayness = float(mins - 360) / 120.0        # 6:00->8:00 ramp up
    elif h >= 17 and h < 19:
        dayness = 1.0 - float(mins - 1020) / 120.0 # 17:00->19:00 ramp down
    else:
        dayness = 0.0
    if dayness < 0.0:
        dayness = 0.0
    if dayness > 1.0:
        dayness = 1.0
    nightness = 1.0 - dayness

    h12 = h
    ampm = "AM"
    if h12 >= 12:
        ampm = "PM"
    if h12 == 0:
        h12 = 12
    elif h12 > 12:
        h12 = h12 - 12

    time_s = str(h12) + ":" + _pad2(t["mi"])
    dow_name = DOW[(_dow_sun0(t["y"], t["mo"], t["d"]) + 6) % 7]
    date_s = dow_name + " " + MON[t["mo"] - 1] + " " + str(t["d"])
    abbr = ZONE_ABBR[zone][1 if dst else 0]

    c.fill("black")

    # ----- sky scene on the right -----
    _draw_sky(c, top, bot)
    _draw_stars(c, t["d"] * 17 + t["mo"] * 3, nightness)
    if dayness > 0.5:
        _draw_sun(c, dayness)
        _draw_clouds(c, dayness)
    else:
        _draw_moon(c, top, bot, nightness)

    # ----- divider -----
    c.rect(DIVX, 2, DIVX, 29, fill="#202636")

    # ----- left block: centered in the black region (x0 .. DIVX) -----
    # The time + AM/PM + zone form one row; measure its full width, then
    # center that row in the space left of the divider. Date centers under it.
    tw = c.text_width(time_s, "16x24")
    aw = c.text_width(ampm, "6x8")
    zw = c.text_width(abbr, "5x7")
    gap = 4
    label_w = aw
    if zw > aw:
        label_w = zw
    row_w = tw + gap + label_w          # full width of time + label column

    row_x = (DIVX - row_w) // 2         # left edge that centers the row
    if row_x < 2:
        row_x = 2

    c.text(time_s, row_x, 1, font="16x24", color=clock_col)

    lx = row_x + tw + gap
    c.text(ampm, lx, 3, font="6x8", color=clock_col)
    c.text(abbr, lx, 14, font="5x7", color=MUTED)

    # date centered under the whole row, 4x5, at y=27
    row_center = row_x + row_w // 2
    dw = c.text_width(date_s, "4x5")
    c.text(date_s, row_center - dw // 2, 27, font="4x5", color=MUTED)