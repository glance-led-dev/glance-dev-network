# Weather Report (192x32)
#
# Estimated conditions and forecast for any US ZIP, no weather station or key needed:
# a flat, bold page for each subject instead of a drawn scene.
#
#   1 now       color block, temperature, high / low, and what's next (rain
#               coming or ending, a freeze). Feels-like shows only when it's
#               3 degrees or more off. A warning takes the whole page in the
#               NWS color; a watch or advisory rides a strip along the bottom.
#   2 air       humidity, dew point, pressure + trend, UV, air quality
#   3 wind      an arrow flying with the wind, speed, gusts
#   4 rain      today, 7 days, 30 days, and the next 24 hours' top chance
#   5 today     24-hour temperature line, solid so far, dotted ahead
#   6 hourly    next 8 hours
#   7 forecast  5 days on one color scale; TONIGHT takes over after sunset
#   8 sky       sunrise, sunset, daylight, moon phase
#
# Data: Open-Meteo (forecast model + air quality, an estimate for the ZIP's
# center, not a measurement), Zippopotam (ZIP), NWS (alerts), USNO (moon).

#
# full-bleed graphics - no title bars, every page uses all 32 rows:
#
#   1 now     a live sky scene: the sky follows the real time of day, the sun
#             and moon ride their real arcs, clouds / rain / snow / fog /
#             lightning follow the conditions, and the horizon matches where
#             temperature, conditions, today's real high / low with times,
#             heat index / wind chill (NWS formulas) when one applies.
#   2 air     humidity, dew point (with a comfort word), pressure + trend, UV
#   3 wind    compass dial (red pointer at the side the wind comes from, an
#             arc over the last 10 minutes' directions), speed, the Beaufort
#             term (GENTLE / BREEZE), gust, today's high gust, and the last
#             6 hours: an arrow each hour pointing to where the wind came
#             only - no forecast)
#   4 rain    a 2-inch rain gauge (bluer page, a rain cloud and drops falling
#             into the tube while it's wet), today's rain and minutes of rain, a 24-hour
#             rain + lightning timeline with today's strike count, last hour /
#             yesterday / month / rain days / last strike - becomes a 3-hour
#             lightning strike map (STORM MODE) while a strike within 10 miles
#             has happened in the last 30 minutes (NWS safety rules)
#   5 today   24-hour temperature curve: measured so far, then the forecast
#             eased in from the current reading; high / low labels
#   7 forecast  4 NWS-style 12-hour periods (this afternoon / tonight / Mon /
#   8 sky     the sun's arc and the moon at its real position and phase,
#             sunrise / sunset / daylight and its change vs yesterday, moon
#             rise / set (USNO), the phase name and the next new / quarter /
#             full moon, and a horizon matching the Now page's scene
#
# NWS alerts (US): 57 hand-picked event types (ALERT_STYLE), ranked by the
# NWS hazard-map priority. A warning (or civil emergency) takes over page 1,
# names the next active alert, and puts hazard stripes on the edges of pages
# 2-8; watches / advisories / statements ride a strip along page 1's bottom.
# for 30+ min) or a low battery.
#
# USNO (moon), NWS (alerts), US Census geocoder (scene) - all keyless beyond
# F / mph / inches; the Units setting only converts what's printed.
#
CARDINAL_NAMES = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

WEEKDAY_NAMES = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

MINI_SUN_BITMAP = [
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
]

MINI_CLOUD_BITMAP = [
    [0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
]

# ---------- pure-math / formatting helpers (no round(), no while) ----------
def compass_index(deg):
    return int((deg + 11.25) // 22.5) % 16

def round_int(x):
    if x >= 0:
        return int(x + 0.5)
    else:
        return int(x - 0.5)

def pad_int(n, width):
    s = str(n)
    sign = ""
    if s[0] == "-":
        sign = "-"
        s = s[1:]
    for i in range(width):
        if len(s) >= width:
            break
        s = "0" + s
    return sign + s

def format1(value):
    neg = value < 0
    v = -value if neg else value
    tenths = round_int(v * 10)
    whole = tenths // 10
    frac = tenths % 10
    s = str(whole) + "." + str(frac)
    if neg and (whole != 0 or frac != 0):
        s = "-" + s
    return s

def format2(value):
    neg = value < 0
    v = -value if neg else value
    cents = round_int(v * 100)
    whole = cents // 100
    frac = cents % 100
    s = str(whole) + "." + pad_int(frac, 2)
    if neg and (whole != 0 or frac != 0):
        s = "-" + s
    return s

def format4(value):
    neg = value < 0
    v = -value if neg else value
    tenthousandths = round_int(v * 10000)
    whole = tenthousandths // 10000
    frac = tenthousandths % 10000
    s = str(whole) + "." + pad_int(frac, 4)
    if neg and (whole != 0 or frac != 0):
        s = "-" + s
    return s

def c_to_f(celsius):
    return celsius * 1.8 + 32.0

def mm_to_in(mm):
    return mm / 25.4

def hpa_to_inhg(hpa):
    return hpa * 0.0295299830714

def days_from_civil(y, m, d):
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    # Howard Hinnant's days-since-epoch -> civil-date, the inverse of
    # days_from_civil() above.
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = (mp + 3) if mp < 10 else (mp - 9)
    if m <= 2:
        y = y + 1
    return y, m, d

def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v

def epoch_to_local_hhmm(epoch, tz_offset_min):
    local_epoch = epoch + tz_offset_min * 60
    secs_of_day = local_epoch % 86400
    hour24 = secs_of_day // 3600
    minute = (secs_of_day % 3600) // 60
    ampm = "AM" if hour24 < 12 else "PM"
    hour12 = hour24 % 12
    if hour12 == 0:
        hour12 = 12
    return str(hour12) + ":" + pad_int(minute, 2) + " " + ampm

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

# "possibly-rainy" / "possibly-thunderstorm" etc. are a chance, not what's
# expected: they draw as plain clouds everywhere (the Now page's words still
# say POSSIBLE; Hourly's blue bar shows the chance), so rain or a bolt always
# means it's likely.
def icon_cond(icon):
    if icon == None or icon.startswith("possibly"):
        return "Clouds"
    if "thunderstorm" in icon:
        return "Thunderstorm"
    if "sleet" in icon:
        return "Sleet"
    if "snow" in icon:
        return "Snow"
    if "rain" in icon:
        return "Rain"
    if "fog" in icon:
        return "Fog"
    if "windy" in icon:
        return "Windy"
    if "partly-cloudy" in icon:
        if "night" in icon:
            return "PartlyCloudyNight"
        return "PartlyCloudy"
    if "clear" in icon:
        if "night" in icon:
            return "ClearNight"
        return "Clear"
    return "Clouds"

# US Naval Observatory's free, keyless astronomical data API - the almanac
# page's moon phase/illumination/moonrise/moonset all come from here (NWS
# math was the alternative, and USNO is the actual government authority
# for this data anyway). tz is decimal hours (not minutes, unlike this
# app's own tz_offset_min) - passing it means every time in the response
# already comes back in local time, no epoch conversion needed.
def fetch_moon_almanac(date_str, lat, lon, tz_hours):
    return http.get(
        "https://aa.usno.navy.mil/api/rstt/oneday?date=" + date_str + "&coords=" + format4(lat) + "," + format4(lon) + "&tz=" + str(tz_hours),
        headers = {"User-Agent": "GDN-Weather-Report (glance-led-panel)"},
        ttl_seconds = 3600,
    )

# ---------- WeatherSTAR 4000 palette + gradients ----------
# than reinvented: --navy-deep #0a1250, --navy-panel #1a2d8f (body
# background, top-to-bottom), --orange #ff7a00 / --purple #6a1b9a (title
# bar, left-to-right - the CSS gradient is a 115deg diagonal, but at 8px
# tall a left-to-right approximation reads the same). This is the one
# WeatherSTAR title bars don't shift with time of day.
def rgb_to_hex(r, g, b):
    digits = "0123456789ABCDEF"
    r = 0 if r < 0 else (255 if r > 255 else r)
    g = 0 if g < 0 else (255 if g > 255 else g)
    b = 0 if b < 0 else (255 if b > 255 else b)
    return "#" + digits[r // 16] + digits[r % 16] + digits[g // 16] + digits[g % 16] + digits[b // 16] + digits[b % 16]

BODY_BOTTOM = (10, 18, 80)

def lerp(a, b, t):
    return a + (b - a) * t

def gradient_at(stops, t):
    if t <= stops[0][0]:
        r, g, b = stops[0][1]
        return round_int(r), round_int(g), round_int(b)
    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        if t <= t1:
            frac = (t - t0) / (t1 - t0) if t1 > t0 else 0.0
            return (
                round_int(lerp(c0[0], c1[0], frac)),
                round_int(lerp(c0[1], c1[1], frac)),
                round_int(lerp(c0[2], c1[2], frac)),
            )
    r, g, b = stops[len(stops) - 1][1]
    return round_int(r), round_int(g), round_int(b)

def local_day_start(ts, tz_offset_min):
    return ts - ((ts + tz_offset_min * 60) % 86400)

# Scanline fill for an arbitrary triangle - c only offers rect/line/circle
# primitives, so this is what draw_wind_flag's pivoting tip needs. Sorts
# the 3 points by y by hand (only ever 3 of them, not worth a general sort)
# then, per row, intersects the long edge (top->bottom) against whichever
# of the two short edges (top->mid, mid->bottom) spans that row.
def edge_x(x0, y0, x1, y1, y):
    if y1 == y0:
        return x0
    return x0 + (x1 - x0) * (y - y0) / float(y1 - y0)

def fill_triangle(c, x0, y0, x1, y1, x2, y2, color):
    pts = [(x0, y0), (x1, y1), (x2, y2)]
    for i in range(2):
        for j in range(2 - i):
            if pts[j][1] > pts[j + 1][1]:
                pts[j], pts[j + 1] = pts[j + 1], pts[j]
    ax, ay = pts[0]
    bx, by = pts[1]
    cx, cy = pts[2]
    for y in range(round_int(ay), round_int(cy) + 1):
        x_ac = edge_x(ax, ay, cx, cy, y)
        if y < by:
            x_other = edge_x(ax, ay, bx, by, y)
        else:
            x_other = edge_x(bx, by, cx, cy, y)
        x_left = x_ac if x_ac < x_other else x_other
        x_right = x_other if x_ac < x_other else x_ac
        c.line(round_int(x_left), y, round_int(x_right), y, color)

def draw_moon(c, x, y):
    cx = x + 7
    cy = y + 5
    c.fill_circle(cx, cy, 7, "#DDDDDD")
    c.fill_circle(cx - 3, cy - 2, 7, BODY_BOTTOM_HEX)

BODY_BOTTOM_HEX = rgb_to_hex(BODY_BOTTOM[0], BODY_BOTTOM[1], BODY_BOTTOM[2])

# A true phase-accurate moon disk (almanac page's centerpiece) - not the
# fixed two-circle crescent cutout draw_moon/draw_mini_moon use, since
# those only ever draw one fixed shape. For each row of the disk, the
# terminator sits at rx*(1-2*illum_frac) (rx = that row's half-width);
# illum_frac 0 -> terminator at the outer edge (sliver lit), 1 -> at the
# far edge (fully lit). Which side is lit flips between waxing (right)
# and waning (left) via `sign`. A dim rim circle keeps the disk's full
# outline visible even near New Moon, when it'd otherwise nearly vanish
# into the navy body background.
def draw_moon_phase(c, cx, cy, r, illum_frac, is_waxing, lit_color, dark_color):
    sign = 1.0 if is_waxing else -1.0
    term = 1.0 - 2.0 * clamp(illum_frac, 0.0, 1.0)
    r2 = r * r
    for dy in range(-r, r + 1):
        under = r2 - dy * dy
        if under < 0:
            continue
        rx = math.sqrt(under)
        rx_i = int(rx)
        boundary = rx * term
        for dx in range(-rx_i, rx_i + 1):
            lit = (sign * dx) >= boundary
            c.pixel(cx + dx, cy + dy, lit_color if lit else dark_color)
    c.circle(cx, cy, r, "#555577")

def draw_mini_sun(c, x, y):
    c.bitmap(MINI_SUN_BITMAP, x, y, "amber")

def draw_mini_moon(c, x, y):
    cx = x + 4
    cy = y + 4
    c.fill_circle(cx, cy, 4, "#DDDDDD")
    c.fill_circle(cx - 2, cy - 1, 4, BODY_BOTTOM_HEX)

def draw_mini_cloud(c, x, y, color):
    c.bitmap(MINI_CLOUD_BITMAP, x, y, color)

def draw_mini_partly_cloudy(c, x, y):
    c.bitmap(MINI_SUN_BITMAP, x + 4, y - 2, "amber")
    draw_mini_cloud(c, x, y + 3, "#AAAAAA")

def draw_mini_partly_cloudy_night(c, x, y):
    draw_mini_moon(c, x + 4, y - 2)
    draw_mini_cloud(c, x, y + 3, "#AAAAAA")

def draw_mini_rain(c, x, y):
    c.line(x + 3, y + 6, x + 2, y + 8, "#3399FF")
    c.line(x + 8, y + 6, x + 7, y + 8, "#3399FF")

def draw_mini_snow(c, x, y):
    c.pixel(x + 3, y + 7, "white")
    c.pixel(x + 8, y + 7, "white")
    c.pixel(x + 5, y + 8, "white")

def draw_mini_sleet(c, x, y):
    draw_mini_cloud(c, x, y, "#999999")
    c.pixel(x + 3, y + 7, "#3399FF")
    c.pixel(x + 8, y + 7, "white")

def draw_mini_bolt(c, x, y):
    c.line(x + 7, y + 6, x + 5, y + 8, "amber")
    c.line(x + 5, y + 8, x + 8, y + 8, "amber")

def draw_mini_fog(c, x, y):
    draw_mini_cloud(c, x, y, "#999999")
    c.line(x + 1, y + 7, x + 10, y + 7, "#CCCCCC")

def draw_mini_windy(c, x, y):
    c.line(x + 1, y + 4, x + 9, y + 4, "#AAAAAA")
    c.line(x, y + 7, x + 8, y + 7, "#AAAAAA")

def draw_mini_icon(c, cond, x, y):
    if cond == "Clear":
        draw_mini_sun(c, x + 1, y)
    elif cond == "ClearNight":
        draw_mini_moon(c, x + 1, y)
    elif cond == "PartlyCloudy":
        draw_mini_partly_cloudy(c, x, y)
    elif cond == "PartlyCloudyNight":
        draw_mini_partly_cloudy_night(c, x, y)
    elif cond == "Rain":
        draw_mini_cloud(c, x, y, "#888888")
        draw_mini_rain(c, x, y)
    elif cond == "Sleet":
        draw_mini_sleet(c, x, y)
    elif cond == "Thunderstorm":
        draw_mini_cloud(c, x, y, "#666666")
        draw_mini_bolt(c, x, y)
    elif cond == "Snow":
        draw_mini_cloud(c, x, y, "#AAAAAA")
        draw_mini_snow(c, x, y)
    elif cond == "Fog":
        draw_mini_fog(c, x, y)
    elif cond == "Windy":
        draw_mini_windy(c, x, y)
    elif cond == "Clouds":
        draw_mini_cloud(c, x, y, "#AAAAAA")
    else:
        draw_mini_cloud(c, x, y, "#999999")

def hex_to_rgb(hexcolor):
    return (int(hexcolor[1:3], 16), int(hexcolor[3:5], 16), int(hexcolor[5:7], 16))

def dim_hex(hexcolor, factor):
    r, g, b = hex_to_rgb(hexcolor)
    return rgb_to_hex(round_int(r * factor), round_int(g * factor), round_int(b * factor))

def wind_color(mph):
    # Each step is a distinct hue rather than another shade of blue (the
    # old 3 lowest bands - #0033FF/#0066FF/#00AAFF - all read as "blue" on
    # an LED panel and were easy to confuse at a glance).
    if mph < 6:
        return "#3366CC"
    elif mph < 11:
        return "#00CCFF"
    elif mph < 18:
        return "#00CC88"
    elif mph < 27:
        return "#33CC33"
    elif mph < 35:
        return "#CCCC00"
    elif mph < 45:
        return "amber"
    elif mph < 55:
        return "#FF8800"
    elif mph < 66:
        return "#FF4400"
    else:
        return "#FF0000"

# ---------- batched drawing ----------
# GDN checks every draw op one at a time (a few ms each), and these pages draw
# thousands of single pixels and short lines - slow enough to time out a
# render on a slow PC. buffered(c) is a stand-in for c: small shapes are
# painted into a pixel buffer (with the same rasterizing as GDN's canvas), and
# the buffer goes out as a few rects / bitmaps per color whenever text or a big
# rect is drawn and at the end of the page, so the picture is pixel-for-pixel
# the same with far fewer ops.
BIG_RECT = 64

def _flush_group(c, col, ps):
    # ps = buffer keys (y * 512 + x) of every pixel of this color
    xs = sorted({p % 512: True for p in ps}.keys())
    # split far-apart clusters so one color used in two places doesn't make a
    # huge mostly-empty bitmap
    bounds = []
    lo = xs[0]
    prev = xs[0]
    for x in xs[1:]:
        if x - prev > 6:
            bounds.append((lo, prev))
            lo = x
        prev = x
    bounds.append((lo, prev))
    for b in bounds:
        rows = {}
        for p in ps:
            x = p % 512
            if x >= b[0] and x <= b[1]:
                y = p // 512
                if y in rows:
                    rows[y].append(x)
                else:
                    rows[y] = [x]
        ys = sorted(rows.keys())
        # horizontal runs per row, merged downward into rects when a run has
        # the same span as the one right above it
        rects = []
        open_r = {}
        for y in ys:
            rx = sorted(rows[y])
            runs = []
            s = rx[0]
            e = rx[0]
            for x in rx[1:]:
                if x == e + 1:
                    e = x
                else:
                    runs.append((s, e))
                    s = x
                    e = x
            runs.append((s, e))
            new_open = {}
            for r in runs:
                o = open_r.get(r, None)
                if o != None and o[3] == y - 1:
                    o[3] = y
                    new_open[r] = o
                else:
                    nr = [r[0], y, r[1], y]
                    rects.append(nr)
                    new_open[r] = nr
            open_r = new_open
        y0 = ys[0]
        y1 = ys[-1]
        cells = (b[1] - b[0] + 1) * (y1 - y0 + 1)
        # a bitmap cell costs ~1/40 of an op to check
        if len(rects) > 1 and cells <= 4096 and 1 + cells / 40.0 < len(rects):
            grid = []
            for y in range(y0, y1 + 1):
                row = [0] * (b[1] - b[0] + 1)
                for x in rows.get(y, []):
                    row[x - b[0]] = 1
                grid.append(row)
            c.bitmap(grid, b[0], y0, col)
        else:
            for r in rects:
                c.rect(r[0], r[1], r[2], r[3], fill = col)

def buffered(c):
    W = c.width
    H = 32
    st = {"fb": {}, "cols": {}}

    def put(x, y, col):
        x = int(x)
        y = int(y)
        if x >= 0 and x < W and y >= 0 and y < H:
            k = str(col)
            st["cols"][k] = col
            st["fb"][y * 512 + x] = k

    def flush():
        fb = st["fb"]
        if len(fb) == 0:
            return
        groups = {}
        for p, k in fb.items():
            if k in groups:
                groups[k].append(p)
            else:
                groups[k] = [p]
        for k, ps in groups.items():
            _flush_group(c, st["cols"][k], ps)
        st["fb"] = {}

    def pixel(x, y, color):
        put(x, y, color)

    def line(x0, y0, x1, y1, color):
        x0 = int(x0)
        y0 = int(y0)
        x1 = int(x1)
        y1 = int(y1)
        dx = abs(x1 - x0)
        dy = -abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx + dy
        for _ in range(dx - dy + 1):
            put(x0, y0, color)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def rect(x0, y0, x1, y1, fill = None, outline = None):
        x0 = int(x0)
        y0 = int(y0)
        x1 = int(x1)
        y1 = int(y1)
        if x1 < x0:
            x0, x1 = x1, x0
        if y1 < y0:
            y0, y1 = y1, y0
        if fill != None and (x1 - x0 + 1) * (y1 - y0 + 1) >= BIG_RECT:
            # big fills (backgrounds, panels) go straight out
            flush()
            c.rect(x0, y0, x1, y1, fill = fill)
        elif fill != None:
            for yy in range(max(0, y0), min(H, y1 + 1)):
                for xx in range(max(0, x0), min(W, x1 + 1)):
                    put(xx, yy, fill)
        if outline != None:
            for xx in range(x0, x1 + 1):
                put(xx, y0, outline)
                put(xx, y1, outline)
            for yy in range(y0, y1 + 1):
                put(x0, yy, outline)
                put(x1, yy, outline)

    def circle(cx, cy, r, color):
        cx = int(cx)
        cy = int(cy)
        r = int(r)
        if r < 0:
            return
        if r == 0:
            put(cx, cy, color)
            return
        x = r
        y = 0
        err = 1 - r
        for _ in range(r + 2):
            if x < y:
                break
            for o in ((x, y), (y, x), (-y, x), (-x, y), (-x, -y), (-y, -x), (y, -x), (x, -y)):
                put(cx + o[0], cy + o[1], color)
            y += 1
            if err < 0:
                err += 2 * y + 1
            else:
                x -= 1
                err += 2 * (y - x) + 1

    def hline(x, y, w, color):
        w = int(w)
        if w > 0:
            line(x, y, int(x) + w - 1, y, color)

    def fill_circle(cx, cy, r, color):
        cx = int(cx)
        cy = int(cy)
        r = int(r)
        if r < 0:
            return
        r2 = r * r
        for dy in range(-r, r + 1):
            dx = int(math.sqrt(r2 - dy * dy))
            hline(cx - dx, cy + dy, 2 * dx + 1, color)

    def fill_tri(x0, y0, x1, y1, x2, y2, color):
        pts = sorted([(int(x0), int(y0)), (int(x1), int(y1)), (int(x2), int(y2))], key = lambda p: p[1])
        ax, ay = pts[0]
        bx, by = pts[1]
        cx, cy = pts[2]
        if ay == cy:
            lo = min(ax, bx, cx)
            hline(lo, ay, max(ax, bx, cx) - lo + 1, color)
            return

        def x_at(y, px, py, qx, qy):
            if qy == py:
                return px
            return px + (qx - px) * (y - py) / (qy - py)

        for y in range(ay, cy + 1):
            xa = x_at(y, ax, ay, cx, cy)
            if y < by:
                xb = x_at(y, ax, ay, bx, by)
            else:
                xb = x_at(y, bx, by, cx, cy)
            lo = xa if xa <= xb else xb
            hi = xb if xa <= xb else xa
            lo = math.round(lo)
            hi = math.round(hi)
            hline(lo, y, hi - lo + 1, color)

    def bitmap(rows, x, y, color):
        for ry in range(len(rows)):
            row = rows[ry]
            for rx in range(len(row)):
                if row[rx]:
                    put(x + rx, y + ry, color)

    def text(s, x, y, font = "5x7", color = "white", align = "left"):
        flush()
        c.text(s, x, y, font = font, color = color, align = align)

    def text_stroke(s, x, y, font = "5x7", color = "white", stroke = "black", thickness = 1, align = "left"):
        flush()
        c.text_stroke(s, x, y, font = font, color = color, stroke = stroke, thickness = thickness, align = align)

    return struct(
        width = W,
        height = H,
        pixel = pixel,
        line = line,
        rect = rect,
        circle = circle,
        fill_circle = fill_circle,
        fill_triangle = fill_tri,
        bitmap = bitmap,
        text = text,
        text_stroke = text_stroke,
        text_width = c.text_width,
        flush = flush,
        memo = {},
    )

def hexc(rgb):
    return rgb_to_hex(rgb[0], rgb[1], rgb[2])

def draw_deg(c, x, y, color, big = False):
    if big:
        c.line(x + 1, y, x + 2, y, color)
        c.line(x + 1, y + 3, x + 2, y + 3, color)
        c.line(x, y + 1, x, y + 2, color)
        c.line(x + 3, y + 1, x + 3, y + 2, color)
    else:
        c.pixel(x + 1, y, color)
        c.pixel(x, y + 1, color)
        c.pixel(x + 2, y + 1, color)
        c.pixel(x + 1, y + 2, color)

# Small text over the sky scene gets a full 1px dark outline (drawn at all 8
# offsets), not just a drop shadow, so it stays readable on a bright sky.
OUTLINE8 = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]

FONT_H = {"4x5": 5, "5x7": 7, "6x8": 8, "8x12": 12, "16x20": 20, "picopixel": 5}

# Draws a number string, but with a 1-2px dot for "." instead of the font's
# full-width period glyph (these fonts are monospaced, so "." would cost a
# whole digit's width). Returns the width drawn.
# stroke = outline color: the digits get a 1px outline (one text_stroke op) and
# the dots get theirs drawn as shapes first.
def num_text(c, x, y, s, font, color, stroke = None):
    h = FONT_H.get(font, 7)
    dot = 2 if h >= 12 else 1
    parts = s.split(".")
    if stroke != None:
        cx = x
        for k in range(len(parts)):
            if k > 0:
                c.rect(cx - 1, y + h - dot - 1, cx + dot, y + h, fill = stroke)
                cx += dot + 1
            if parts[k] != "":
                cx += c.text_width(parts[k], font) + 1
    cx = x
    for k in range(len(parts)):
        if k > 0:
            c.rect(cx, y + h - dot, cx + dot - 1, y + h - 1, fill = color)
            cx += dot + 1
        if parts[k] != "":
            if stroke != None:
                c.text_stroke(parts[k], cx, y, font = font, color = color, stroke = stroke, align = "left")
            else:
                c.text(parts[k], cx, y, font = font, color = color, align = "left")
            cx += c.text_width(parts[k], font) + 1
    return cx - x - 1

def num_width(c, s, font):
    h = FONT_H.get(font, 7)
    dot = 2 if h >= 12 else 1
    w = 0
    parts = s.split(".")
    for k in range(len(parts)):
        if k > 0:
            w += dot + 1
        if parts[k] != "":
            w += c.text_width(parts[k], font) + 1
    return w - 1

# Number (one decimal when dec) + hand-drawn degree mark, left-aligned at x.
# Returns total width.
def temp_text(c, x, y, f, font, color, shadow = None, big = False, dec = False):
    s = format1(f) if dec else str(round_int(f))
    w = num_width(c, s, font)
    if shadow != None:
        for o in OUTLINE8:
            draw_deg(c, x + w + 1 + o[0], y + o[1], shadow, big)
    num_text(c, x, y, s, font, color, stroke = shadow)
    draw_deg(c, x + w + 1, y, color, big)
    return w + (5 if big else 4)

def temp_text_centered(c, cx, y, f, font, color):
    s = str(round_int(f))
    w = c.text_width(s, font) + 4
    temp_text(c, cx - w // 2, y, f, font, color)

def hour_label(epoch, tz_min):
    h = ((epoch + tz_min * 60) % 86400) // 3600
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ("A" if h < 12 else "P")

TEMP_RAMP = [(0.0, (150, 80, 255)), (20.0, (70, 90, 255)), (32.0, (40, 140, 255)), (45.0, (0, 200, 230)), (58.0, (40, 215, 110)), (68.0, (200, 225, 40)), (76.0, (255, 190, 0)), (85.0, (255, 120, 0)), (95.0, (255, 50, 20)), (105.0, (230, 0, 60))]

def tcol(f):
    return hexc(gradient_at(TEMP_RAMP, f))

# ---------- shared loaders ----------
# Each page (and its warning edges) loads the data once: buffered(c) carries a
# memo, so a failed request isn't retried within the page - GDN allows only 8
# uncached requests per render, and failures are never cached.
def load_all(c, ctx):
    memo = getattr(c, "memo", None)
    if memo != None and "d" in memo:
        return memo["d"]
    d = load_all_now(c, ctx)
    if memo != None:
        memo["d"] = d
    return d

def tdisp(d, f):
    return (f - 32.0) / 1.8 if d["metric"] else f

def sun_times(d):
    daily = d["daily"]
    if len(daily) > 0 and daily[0].get("sunrise", None) != None:
        return daily[0]["sunrise"], daily[0]["sunset"]
    return None, None

# A temperature with its time beside it (time smaller and dimmer), centered
# on cx but kept inside the page.
def temp_when(c, cx, y, f, when, color, when_color):
    s = str(round_int(f))
    tw = num_width(c, s, "4x5") + 4
    ww = c.text_width(when, "picopixel")
    total = tw + 2 + ww
    x0 = clamp(cx - total // 2, 4, c.width - 4 - total)
    temp_text(c, x0, y, f, "4x5", color)
    c.text(when, x0 + tw + 2, y, font = "picopixel", color = when_color, align = "left")

def boxes_overlap(a, b):
    return a[0] <= b[2] and b[0] <= a[2] and a[1] <= b[3] and b[1] <= a[3]

# A temp_when label centered near column cx, as close to it as it can go
# while staying clear of the curve (tops = the curve's top row per column)
# and of the given boxes. Returns the box it took (with a 1px margin).
def place_temp_when(c, tops, boxes, cx, f, when, color, when_color):
    W = c.width
    s = str(round_int(f))
    tw = num_width(c, s, "4x5") + 4
    total = tw + 2 + c.text_width(when, "picopixel")
    for step in range(W // 2):
        for sgn in [1, -1]:
            if step == 0 and sgn == -1:
                continue
            x0 = clamp(cx - total // 2 + sgn * step * 2, 4, W - 4 - total)
            mn = 99
            for x in range(max(0, x0 - 1), min(W, x0 + total + 1)):
                mn = min(mn, tops[x])
            y = min(mn - 6, 20)
            if y < 1:
                continue
            box = (x0 - 1, y - 1, x0 + total, y + 5)
            hit = False
            for b in boxes:
                if boxes_overlap(box, b):
                    hit = True
            if not hit:
                temp_when(c, x0 + total // 2, y, f, when, color, when_color)
                return box
    x0 = clamp(cx - total // 2, 4, W - 4 - total)
    temp_when(c, cx, 1, f, when, color, when_color)
    return (x0 - 1, 0, x0 + total, 6)

# current temp), with the epoch each happened. Used by the Now page's H / L.
def day_hilo(d, rows):
    hi = d["temp"]
    lo = d["temp"]
    hi_t = d["ts"]
    lo_t = d["ts"]
    for r in rows:
        if r[7] == None:
            continue
        f = c_to_f(r[7])
        if f > hi:
            hi = f
            hi_t = r[0]
        if f < lo:
            lo = f
            lo_t = r[0]
    return hi, lo, hi_t, lo_t

# The day as W columns, midnight to midnight: measured temps so far (the
# hi / lo are the day's high and low for the Today graph - the actual extreme
# readings so far combined with whatever the forecast still expects (a
# forecast time is a whole hour, an actual one has minutes).
def day_curve(d, W):
    day_start, rows = day_obs_rows(d)
    span = 86400.0 / W
    sums = [0.0] * W
    cnts = [0] * W
    hi, lo, hi_t, lo_t = day_hilo(d, rows)
    for r in rows:
        if r[7] == None:
            continue
        i = int((r[0] - day_start) / span)
        if i >= 0 and i < W:
            sums[i] += r[7]
            cnts[i] += 1
    vals = [None] * W
    last_past = -1
    for i in range(W):
        if cnts[i] > 0:
            vals[i] = c_to_f(sums[i] / cnts[i])
            last_past = i

    day_end = day_start + 86400
    # the forecast is shifted onto the current reading (so it doesn't jump at
    # "now") and that shift fades out over the next 3 hours
    pts = [(d["ts"], d["temp"])]
    bias = None
    for h in d["hourly"]:
        t = h.get("time", 0)
        if t > d["ts"] and h.get("air_temperature", None) != None:
            f = c_to_f(h["air_temperature"])
            if bias == None:
                bias = d["temp"] - f
            f += bias * max(0.0, 1.0 - (t - d["ts"]) / 10800.0)
            pts.append((t, f))
            if t < day_end:
                if f > hi:
                    hi = f
                    hi_t = t
                if f < lo:
                    lo = f
                    lo_t = t
    for i in range(last_past + 1, W):
        e = day_start + (i + 0.5) * span
        for k in range(len(pts) - 1):
            if pts[k][0] <= e and e <= pts[k + 1][0]:
                f = (e - pts[k][0]) / float(pts[k + 1][0] - pts[k][0])
                vals[i] = lerp(pts[k][1], pts[k + 1][1], f)
                break

    prev = None
    for i in range(W):
        if vals[i] == None:
            vals[i] = prev
        else:
            prev = vals[i]
    if prev == None:
        return day_start, vals, last_past, None, None, None, None
    return day_start, vals, last_past, hi, lo, hi_t, lo_t

def today_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    W = c.width
    span = 86400.0 / W
    day_start, vals, last_past, hi, lo, hi_t, lo_t = day_curve(d, W)
    if hi == None:
        return
    rng = max(hi - lo, 6.0)
    mid = (hi + lo) / 2.0
    top_v = mid + rng / 2.0
    bot_v = mid - rng / 2.0
    y_top = 9
    y_bot = 26

    def ypos(v):
        return round_int(y_bot - (v - bot_v) / (top_v - bot_v) * (y_bot - y_top))

    # hour grid
    for hh in [6, 12, 18]:
        gx = hh * W // 24
        for gy in range(8, 29, 2):
            c.pixel(gx, gy, "#1c2650")
        c.text(["6A", "NOON", "6P"][hh // 6 - 1], gx, 27, font = "picopixel", color = "#55628f", align = "center")

    hi_i = 0
    lo_i = 0
    for i in range(W):
        v = vals[i]
        if v == None:
            continue
        if v > vals[hi_i]:
            hi_i = i
        if v < vals[lo_i]:
            lo_i = i
        y = ypos(v)
        # color by the nearest half degree: neighboring columns then share a
        # color and batch into far fewer ops (no visible change)
        col = tcol(round_int(v * 2) / 2.0)
        past = i <= last_past
        if past:
            c.pixel(i, y, col)
            c.pixel(i, y - 1, dim_hex(col, 0.5))
        elif i % 2 == 0:
            c.pixel(i, y, dim_hex(col, 0.8))

    # now marker
    if last_past >= 0:
        ny = ypos(vals[last_past])
        c.fill_circle(last_past, ny, 2, "white")
    # hi / lo labels: both sit ABOVE the curve (below it is the filled graph),
    # high enough to clear the curve across the label's whole width, and slide
    # sideways if that spot hits the title, the other label or the now dot
    tops = [99] * W
    for i in range(W):
        if vals[i] != None:
            tops[i] = ypos(vals[i]) - 1
    if last_past >= 0:
        for i in range(last_past - 3, last_past + 4):
            if i >= 0 and i < W:
                tops[i] = min(tops[i], ny - 3)
    boxes = [(3, 0, 4 + c.text_width("TEMP TODAY", "picopixel"), 6)]
    hb = place_temp_when(c, tops, boxes, hi_i, tdisp(d, hi), when_label(hi_t, d), "#FFD08A", "#b09060")
    boxes.append(hb)
    place_temp_when(c, tops, boxes, lo_i, tdisp(d, lo), when_label(lo_t, d), "#9CC8FF", "#6a88b0")
    tag(c, "TEMP TODAY", 4)

# ---------- hourly ----------
def hourly_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    hrs = [h for h in d["hourly"] if h.get("time", 0) > d["ts"]]
    n = 8
    cw = c.width // n
    for i in range(min(n, len(hrs))):
        h = hrs[i]
        x0 = i * cw
        cx = x0 + cw // 2
        if i > 0:
            c.line(x0, 3, x0, 28, "#18214a")
        c.text(hour_label(h["time"], d["tz"]), cx, 1, font = "4x5", color = "#8fa0cc", align = "center")
        cond = icon_cond(h.get("icon"))
        draw_mini_icon(c, cond, cx - 6, 9)
        f = c_to_f(h.get("air_temperature", 0.0))
        temp_text_centered(c, cx, 20, tdisp(d, f), "5x7", tcol(f))
        pop = h.get("precip_probability", 0) or 0
        if pop > 0:
            bw = round_int((cw - 8) * pop / 100.0)
            c.rect(x0 + 4, 29, x0 + cw - 4, 30, fill = "#14204a")
            c.rect(x0 + 4, 29, x0 + 4 + max(bw, 1), 30, fill = "#3399FF")

PERIOD_RANK = {"Thunderstorm": 9, "Snow": 8, "Sleet": 7, "Rain": 6, "Fog": 5, "Windy": 4, "Clouds": 3, "PartlyCloudy": 2, "Clear": 1}

FORECAST_PERIODS = 4

# ---------- wind rose ----------
# Beaufort scale names (mph thresholds)
BEAUFORT = [(1, "CALM"), (4, "LIGHT AIR"), (8, "LIGHT BREEZE"), (13, "GENTLE BREEZE"), (19, "MODERATE BREEZE"),
            (25, "FRESH BREEZE"), (32, "STRONG BREEZE"), (39, "NEAR GALE"), (47, "GALE"), (55, "STRONG GALE"),
            (64, "STORM"), (73, "VIOLENT STORM")]

def beaufort(mph):
    for b in BEAUFORT:
        if mph < b[0]:
            return b[1]
    return "HURRICANE"

def dew_words(f):
    if f < 50:
        return "DRY", "#9CC8FF"
    elif f < 56:
        return "COMFY", "#40D070"
    elif f < 61:
        return "HUMID", "#C8E028"
    elif f < 66:
        return "STICKY", "#FFBF00"
    elif f < 71:
        return "MUGGY", "#FF8000"
    return "OPPRESSIVE", "#FF3020"

def uv_words(u):
    if u < 3:
        return "LOW", "#40D070"
    elif u < 6:
        return "MODERATE", "#E0D020"
    elif u < 8:
        return "HIGH", "#FF8800"
    elif u < 11:
        return "VERY HIGH", "#FF3030"
    return "EXTREME", "#B050FF"

def humidity_word(rh):
    if rh < 30:
        return "DRY"
    elif rh < 60:
        return "PLEASANT"
    elif rh < 80:
        return "HEAVY"
    return "DAMP"

def safe_col(col):
    return "#FFBF00" if col == "amber" else col

# ---------- heat index / wind chill (NWS formulas, ported from the dashboard) ----------
# Rothfusz regression with NWS's low-humidity and high-humidity adjustments.
def heat_index_f(t, r):
    hi = (-42.379 + 2.04901523 * t + 10.14333127 * r - 0.22475541 * t * r -
          0.00683783 * t * t - 0.05481717 * r * r + 0.00122874 * t * t * r +
          0.00085282 * t * r * r - 0.00000199 * t * t * r * r)
    if r < 13 and t >= 80 and t <= 112:
        hi -= ((13 - r) / 4.0) * math.sqrt((17 - abs(t - 95.0)) / 17.0)
    elif r > 85 and t >= 80 and t <= 87:
        hi += ((r - 85) / 10.0) * ((87 - t) / 5.0)
    return hi

# NWS 2001 wind chill.
def wind_chill_f(t, mph):
    v16 = math.pow(mph, 0.16)
    return 35.74 + 0.6215 * t - 35.75 * v16 + 0.4275 * t * v16

# ("HEAT INDEX" | "WIND CHILL", value) only inside each formula's valid range,
# else None - a mild day shows neither.
def apparent(d):
    t = d["temp"]
    rh = d["obs"].get("relative_humidity", None)
    if rh == None:
        rh = d["cur"].get("relative_humidity", None)
    mph = d["cur"].get("wind_avg", 0.0) or 0.0
    if t >= 80 and rh != None:
        return ("HEAT INDEX", heat_index_f(t, rh))
    if t <= 50 and mph > 3:
        return ("WIND CHILL", wind_chill_f(t, mph))
    return None

# ---------- NWS alerts ----------
def fetch_nws_alerts(lat, lon):
    return http.get(
        "https://api.weather.gov/alerts/active",
        params = {"point": format4(lat) + "," + format4(lon)},
        headers = {"User-Agent": "GDN-Weather-Report (glance-led-panel)", "Accept": "application/geo+json"},
        ttl_seconds = 120,
    )

# read on an LED panel), the icon to draw, and whether it takes over the Now
# page (True) or rides the strip along its bottom (False). Anything not here is
# ignored. Marine and beach-zone alerts never reach a land point, so they're
# left out. The NWS renamed "Excessive Heat" to "Extreme Heat" in 2025.
ALERT_STYLE = {
    "Tornado Warning": ("#FF0000", "tornado", True),
    "Extreme Wind Warning": ("#FF8C00", "wind", True),
    "Severe Thunderstorm Warning": ("#FFA500", "tstorm", True),
    "Flash Flood Warning": ("#E02828", "flood", True),
    "Flash Flood Statement": ("#E04040", "flood", False),
    "Severe Weather Statement": ("#00E0E0", "tstorm", False),
    "Shelter In Place Warning": ("#FA8072", "info", True),
    "Evacuation Immediate": ("#7FFF00", "info", True),
    "Civil Danger Warning": ("#FFB6C1", "info", True),
    "Hazardous Materials Warning": ("#9A4BE0", "info", True),
    "Fire Warning": ("#C0703D", "info", True),
    "Civil Emergency Message": ("#FFB6C1", "info", True),
    "Storm Surge Warning": ("#B524F7", "flood", True),
    "Hurricane Warning": ("#DC143C", "hurricane", True),
    "Blizzard Warning": ("#FF4500", "snow", True),
    "Snow Squall Warning": ("#E040A0", "snow", True),
    "Ice Storm Warning": ("#C080FF", "snow", True),
    "Winter Storm Warning": ("#FF69B4", "snow", True),
    "High Wind Warning": ("#DAA520", "wind", True),
    "Tropical Storm Warning": ("#B22222", "hurricane", True),
    "Flood Warning": ("#00E040", "flood", False),
    "Coastal Flood Warning": ("#22B022", "flood", True),
    "Extreme Heat Warning": ("#E0309A", "heat", True),
    "Tornado Watch": ("#FFFF00", "tornado", False),
    "Severe Thunderstorm Watch": ("#E07090", "tstorm", False),
    "Flash Flood Watch": ("#3CB371", "flood", False),
    "Flood Statement": ("#00E040", "flood", False),
    "Extreme Cold Warning": ("#3A6BFF", "snow", True),
    "Freeze Warning": ("#7B6FD8", "snow", False),
    "Red Flag Warning": ("#FF1493", "info", False),
    "Storm Surge Watch": ("#DB7FF7", "flood", False),
    "Hurricane Watch": ("#FF00FF", "hurricane", False),
    "Tropical Storm Watch": ("#F08080", "hurricane", False),
    "Tropical Cyclone Local Statement": ("#FFE4B5", "hurricane", False),
    "Winter Weather Advisory": ("#7B68EE", "snow", False),
    "Cold Weather Advisory": ("#AFEEEE", "snow", False),
    "Heat Advisory": ("#FF7F50", "heat", False),
    "Flood Advisory": ("#00FF7F", "flood", False),
    "Coastal Flood Advisory": ("#7CFC00", "flood", False),
    "Dense Fog Advisory": ("#8A9AAA", "fog", False),
    "Dense Smoke Advisory": ("#F0E68C", "fog", False),
    "Dust Advisory": ("#BDB76B", "fog", False),
    "Wind Advisory": ("#D2B48C", "wind", False),
    "Frost Advisory": ("#6495ED", "snow", False),
    "Freezing Fog Advisory": ("#20A0A0", "fog", False),
    "Local Area Emergency": ("#C0C0C0", "info", True),
    "Winter Storm Watch": ("#5A9AE0", "snow", False),
    "Flood Watch": ("#3CB371", "flood", False),
    "Coastal Flood Watch": ("#66CDAA", "flood", False),
    "High Wind Watch": ("#B8860B", "wind", False),
    "Extreme Heat Watch": ("#C04040", "heat", False),
    "Extreme Cold Watch": ("#5F9EA0", "snow", False),
    "Freeze Watch": ("#00E0E0", "snow", False),
    "Fire Weather Watch": ("#FFDEAD", "info", False),
    "911 Telephone Outage": ("#C0C0C0", "info", False),
    "Coastal Flood Statement": ("#8BAE33", "flood", False),
    "Special Weather Statement": ("#FFE4B5", "info", False),
}

# Priority when several are active: the NWS's own hazard-map priority
# (weather.gov/help-map), filtered to the alerts above - so e.g. a Tornado
# Watch outranks a Freeze Warning, and a Severe Weather / Flash Flood Statement
# (an update to an active warning) ranks right behind its warning. ALERT_STYLE
# is written in this same order.
ALERT_ORDER = ["Tornado Warning", "Extreme Wind Warning", "Severe Thunderstorm Warning", "Flash Flood Warning", "Flash Flood Statement", "Severe Weather Statement", "Shelter In Place Warning", "Evacuation Immediate", "Civil Danger Warning", "Hazardous Materials Warning", "Fire Warning", "Civil Emergency Message", "Storm Surge Warning", "Hurricane Warning", "Blizzard Warning", "Snow Squall Warning", "Ice Storm Warning", "Winter Storm Warning", "High Wind Warning", "Tropical Storm Warning", "Flood Warning", "Coastal Flood Warning", "Extreme Heat Warning", "Tornado Watch", "Severe Thunderstorm Watch", "Flash Flood Watch", "Flood Statement", "Extreme Cold Warning", "Freeze Warning", "Red Flag Warning", "Storm Surge Watch", "Hurricane Watch", "Tropical Storm Watch", "Tropical Cyclone Local Statement", "Winter Weather Advisory", "Cold Weather Advisory", "Heat Advisory", "Flood Advisory", "Coastal Flood Advisory", "Dense Fog Advisory", "Dense Smoke Advisory", "Dust Advisory", "Wind Advisory", "Frost Advisory", "Freezing Fog Advisory", "Local Area Emergency", "Winter Storm Watch", "Flood Watch", "Coastal Flood Watch", "High Wind Watch", "Extreme Heat Watch", "Extreme Cold Watch", "Freeze Watch", "Fire Weather Watch", "911 Telephone Outage", "Coastal Flood Statement", "Special Weather Statement"]

# ISO 8601 with offset (2026-10-03T19:45:00-04:00) -> epoch seconds
def iso_to_epoch(s):
    if s == None or len(s) < 19:
        return None
    days = days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10]))
    secs = days * 86400 + int(s[11:13]) * 3600 + int(s[14:16]) * 60 + int(s[17:19])
    if len(s) >= 25:
        sign = -1 if s[19] == "-" else 1
        secs -= sign * (int(s[20:22]) * 3600 + int(s[23:25]) * 60)
    return secs

def until_text(epoch, d):
    if epoch == None:
        return ""
    s = epoch_to_local_hhmm(epoch, d["tz"])
    if epoch - d["ts"] > 20 * 3600:
        lt = epoch + d["tz"] * 60
        s = WEEKDAY_NAMES[((lt // 86400) + 4) % 7] + " " + s
    return "UNTIL " + s

def text_on(color):
    r, g, b = hex_to_rgb(color)
    return "black" if (r * 299 + g * 587 + b * 114) / 1000 > 150 else "white"

# Watches / advisories / health notices ride a strip along the bottom.
def draw_banner(c, color, text):
    c.rect(0, 26, c.width - 1, 31, fill = color)
    f = fit_font(c, text, ["4x5", "picopixel"], c.width - 4)
    c.text(text, c.width // 2, 26 if f == "4x5" else 27, font = f, color = text_on(color), align = "center")

# ---------- location + weather ----------

DEFAULT_ZIP = "27949"
PANEL = "#0B1020"
LABEL = "#8A96B8"
WEEK = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
WET = ["Rain", "Sleet", "Snow", "Thunderstorm"]
WET_WORD = {"Rain": "RAIN", "Sleet": "SLEET", "Snow": "SNOW", "Thunderstorm": "STORMS"}
COND_WORDS = {
    "Clear": "CLEAR",
    "ClearNight": "CLEAR",
    "PartlyCloudy": "PARTLY CLOUDY",
    "PartlyCloudyNight": "PARTLY CLOUDY",
    "Clouds": "CLOUDY",
    "Rain": "RAIN",
    "Sleet": "SLEET",
    "Snow": "SNOW",
    "Thunderstorm": "T-STORMS",
    "Fog": "FOG",
}

def zip_str(v):
    if v == None:
        return DEFAULT_ZIP
    if type(v) == "float":
        v = int(v)
    if type(v) == "int":
        return pad_int(v, 5)
    return str(v).strip()

def wmo_icon(code, is_day):
    sfx = "-day" if is_day else "-night"
    if code in [0, 1]:
        return "clear" + sfx
    if code == 2:
        return "partly-cloudy" + sfx
    if code in [45, 48]:
        return "foggy"
    if code in [56, 57, 66, 67]:
        return "sleet"
    if code >= 95:
        return "thunderstorm"
    if (code >= 71 and code <= 77) or code in [85, 86]:
        return "snow"
    if code >= 51:
        return "rainy"
    return "cloudy"

def fetch_zip(zip):
    return http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 2592000)

def fetch_weather(lat, lon):
    return http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": str(lat),
            "longitude": str(lon),
            "current": "temperature_2m,relative_humidity_2m,dew_point_2m,weather_code,is_day,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,uv_index,precipitation",
            "hourly": "temperature_2m,precipitation_probability,precipitation,weather_code,is_day,pressure_msl",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset",
            "wind_speed_unit": "mph",
            "timezone": "auto",
            "timeformat": "unixtime",
            "past_days": "30",
            "forecast_days": "7",
        },
        ttl_seconds = 540,
    )

def fetch_aqi(lat, lon):
    return http.get(
        "https://air-quality-api.open-meteo.com/v1/air-quality",
        params = {"latitude": str(lat), "longitude": str(lon), "current": "us_aqi"},
        ttl_seconds = 3600,
    )

def draw_problem(c, line1, line2):
    c.rect(0, 0, c.width - 1, 31, fill = PANEL)
    c.text(line1, c.width // 2, 8, font = "5x7", color = "#F2C14E", align = "center")
    c.text(line2, c.width // 2, 19, font = "4x5", color = LABEL, align = "center")

def load_all_now(c, ctx):
    ts = ctx.now.unix
    zip = zip_str(ctx.inputs.get("zip", DEFAULT_ZIP))
    geo = fetch_zip(zip)
    places = (geo["json"] or {}).get("places", []) if geo["status_code"] == 200 else []
    if len(places) == 0:
        draw_problem(c, "ZIP NOT FOUND", "CHECK THE ZIP SETTING: " + zip)
        return None
    lat = float(places[0]["latitude"])
    lon = float(places[0]["longitude"])
    resp = fetch_weather(lat, lon)
    w = resp["json"] if resp["status_code"] == 200 else None
    if w == None or w.get("current", None) == None or w.get("hourly", None) == None:
        draw_problem(c, "WEATHER OFFLINE", "TRYING AGAIN SOON")
        return None
    aq = fetch_aqi(lat, lon)
    aqi = None
    if aq["status_code"] == 200:
        aqi = (aq["json"] or {}).get("current", {}).get("us_aqi", None)
    tz = w["utc_offset_seconds"] // 60
    cu = w["current"]
    h = w["hourly"]
    times = h["time"]
    day0 = local_day_start(ts, tz)
    hourly = []
    rows = []
    press_then = None
    today = 0.0
    r7 = 0.0
    r30 = 0.0
    for i in range(len(times)):
        t = times[i]
        v = h["temperature_2m"][i]
        if v == None:
            continue
        hourly.append({
            "time": t,
            "air_temperature": v,
            "icon": wmo_icon(h["weather_code"][i] or 0, h["is_day"][i] == 1),
            "precip_probability": h["precipitation_probability"][i] or 0,
        })
        if t <= ts - 10800 and h["pressure_msl"][i] != None:
            press_then = h["pressure_msl"][i]
        # the day so far, eased between the hours so the curve doesn't step
        if t + 3600 > day0 and t <= ts and i + 1 < len(times) and h["temperature_2m"][i + 1] != None:
            for k in range(4):
                e = t + k * 900
                if e >= day0 and e <= ts:
                    rows.append([e, 0, 0, 0, 0, 0, 0, v + (h["temperature_2m"][i + 1] - v) * k / 4.0])
        if t <= ts:
            mm = h["precipitation"][i] or 0.0
            if t >= day0:
                today += mm
            if t > ts - 7 * 86400:
                r7 += mm
            r30 += mm
    dd = w["daily"]
    daily = []
    for i in range(len(dd["time"])):
        if dd["time"][i] >= day0 - 3600 and dd["temperature_2m_max"][i] != None:
            daily.append({
                "day_start_local": dd["time"][i],
                "air_temp_high": dd["temperature_2m_max"][i],
                "air_temp_low": dd["temperature_2m_min"][i],
                "icon": wmo_icon(dd["weather_code"][i] or 0, True),
                "precip_probability": dd["precipitation_probability_max"][i] or 0,
                "sunrise": dd["sunrise"][i],
                "sunset": dd["sunset"][i],
            })
    mb = cu["pressure_msl"]
    trend = "steady"
    if press_then != None and mb - press_then >= 0.7:
        trend = "rising"
    elif press_then != None and press_then - mb >= 0.7:
        trend = "falling"
    return {
        "metric": False,
        "lat": lat,
        "lon": lon,
        "name": places[0]["place name"],
        "cur": {
            "icon": wmo_icon(cu["weather_code"] or 0, cu["is_day"] == 1),
            "day_icon": wmo_icon(cu["weather_code"] or 0, True),
            "wind_avg": cu["wind_speed_10m"] or 0.0,
            "wind_gust": cu["wind_gusts_10m"] or 0.0,
            "wind_direction": cu["wind_direction_10m"] or 0,
            "dew_point": cu["dew_point_2m"],
            "sea_level_pressure": mb,
            "pressure_trend": trend,
        },
        "obs": {"relative_humidity": cu["relative_humidity_2m"], "uv": cu["uv_index"] or 0.0},
        "ts": ts,
        "tz": tz,
        "hourly": hourly,
        "daily": daily,
        "temp": c_to_f(cu["temperature_2m"]),
        "rows": rows,
        "aqi": aqi,
        "rain": (today, r7, r30),
    }

def day_obs_rows(d):
    return local_day_start(d["ts"], d["tz"]), d["rows"]

def active_alerts(d):
    resp = fetch_nws_alerts(d["lat"], d["lon"])
    raw = []
    if resp["status_code"] == 200:
        for f in (resp["json"] or {}).get("features", []) or []:
            p = f.get("properties", {}) or {}
            ev = p.get("event", "") or ""
            if ev not in ALERT_STYLE:
                continue
            ends = p.get("ends", None) or p.get("expires", None)
            raw.append((ev, iso_to_epoch(ends) if ends else None))
    return sorted(raw, key = lambda r: (0 if ALERT_STYLE[r[0]][2] else 1, ALERT_ORDER.index(r[0])))

def top_alert(d):
    al = active_alerts(d)
    return al[0] if len(al) > 0 else None

def moon_data(d):
    lt = d["ts"] + d["tz"] * 60
    yy, mm, dd = civil_from_days(lt // 86400)
    resp = fetch_moon_almanac(str(yy) + "-" + pad_int(mm, 2) + "-" + pad_int(dd, 2), d["lat"], d["lon"], d["tz"] / 60.0)
    if resp["status_code"] != 200:
        return None
    return ((resp["json"] or {}).get("properties", {}) or {}).get("data", None)

# ---------- icons + flat color ----------

def draw_bg(c):
    c.rect(0, 0, c.width - 1, 31, fill = PANEL)

def tag(c, s, x = 1, y = 1, align = "left"):
    c.text(s, x, y, font = "picopixel", color = "#7f8fb8", align = align)

def cond_color(cond, is_day):
    if cond in ["Rain", "Sleet"]:
        return "#27406E"
    if cond == "Thunderstorm":
        return "#44286C"
    if cond == "Snow":
        return "#5F78A0"
    if cond in ["Clouds", "Fog"]:
        return "#4C586E" if is_day else "#262C3A"
    return "#1B66C9" if is_day else "#141B48"

def big_cloud(c, cx, cy, col):
    c.fill_circle(cx - 5, cy + 1, 4, col)
    c.fill_circle(cx + 1, cy - 2, 5, col)
    c.fill_circle(cx + 6, cy + 1, 3, col)
    c.rect(cx - 8, cy + 1, cx + 8, cy + 4, fill = col)

def big_sun(c, cx, cy, r):
    c.fill_circle(cx, cy, r, "#FFD23C")
    for k in range(8):
        a = math.radians(k * 45)
        c.line(round_int(cx + (r + 2) * math.sin(a)), round_int(cy - (r + 2) * math.cos(a)), round_int(cx + (r + 4) * math.sin(a)), round_int(cy - (r + 4) * math.cos(a)), "#FFD23C")

def big_icon(c, cond, cx, cy, is_day, bg):
    if cond == "Clear":
        big_sun(c, cx, cy, 6)
    elif cond == "ClearNight":
        c.fill_circle(cx, cy, 8, "#E8ECF8")
        c.fill_circle(cx + 4, cy - 2, 7, bg)
    elif cond == "PartlyCloudy":
        big_sun(c, cx + 4, cy - 4, 4)
        big_cloud(c, cx - 1, cy + 4, "#E8EEF6")
    elif cond == "PartlyCloudyNight":
        c.fill_circle(cx + 5, cy - 5, 5, "#E8ECF8")
        c.fill_circle(cx + 8, cy - 7, 5, bg)
        big_cloud(c, cx - 1, cy + 4, "#AEB8CC")
    elif cond == "Fog":
        for y in [-6, -2, 2, 6]:
            c.line(cx - 9, cy + y, cx + 9, cy + y, "#C8D0DC")
    else:
        big_cloud(c, cx, cy - 3, "#D8DFEA" if is_day else "#8A96AC")
        if cond in ["Rain", "Thunderstorm", "Sleet"]:
            for k in range(4):
                x = cx - 6 + k * 4
                c.line(x, cy + 4, x - 1, cy + 7, "#66B2FF")
        if cond == "Snow":
            for k in range(4):
                c.pixel(cx - 6 + k * 4, cy + 5 + (k % 2) * 2, "white")
        if cond == "Thunderstorm":
            c.line(cx + 2, cy + 2, cx - 1, cy + 6, "#FFE040")
            c.line(cx - 1, cy + 6, cx + 2, cy + 6, "#FFE040")
            c.line(cx + 2, cy + 6, cx, cy + 10, "#FFE040")

# ---------- page 1: now ----------

def hour_words(epoch, d):
    return epoch_to_local_hhmm(epoch, d["tz"]).replace(":00", "")

def freeze_line(d, hrs):
    if d["temp"] <= 32:
        return "BELOW FREEZING NOW"
    rise = None
    for x in d["daily"]:
        if rise == None and x["sunrise"] > d["ts"]:
            rise = x["sunrise"]
    for h in hrs:
        if c_to_f(h["air_temperature"]) <= 32:
            if rise != None and h["time"] <= rise:
                return "FREEZING TONIGHT"
            return "FREEZING BY " + hour_words(h["time"], d)
    return None

def next_line(d):
    hrs = [h for h in d["hourly"] if h["time"] > d["ts"]][:24]
    cond = icon_cond(d["cur"]["icon"])
    if cond in WET:
        for h in hrs:
            if icon_cond(h["icon"]) not in WET:
                return WET_WORD[cond] + " ENDING ABOUT " + hour_words(h["time"], d)
        return WET_WORD[cond] + " NEXT 24 HRS"
    for h in hrs:
        hc = icon_cond(h["icon"])
        if hc in WET or h["precip_probability"] >= 50:
            return WET_WORD.get(hc, "RAIN") + " AROUND " + hour_words(h["time"], d)
    return freeze_line(d, hrs) or "DRY NEXT 24 HRS"

def warning_page(c, d, alert):
    ev, until = alert
    color = ALERT_STYLE[ev][0]
    ink = text_on(color)
    c.rect(0, 0, c.width - 1, 31, fill = color)
    c.fill_triangle(5, 26, 25, 26, 15, 6, ink)
    c.text("!", 15, 14, font = "5x7", color = color, align = "center")
    c.text(ev.upper(), 32, 4, font = fit_font(c, ev.upper(), ["6x8", "5x7", "4x5"], c.width - 35), color = ink)
    c.text(until_text(until, d), 32, 14, font = "5x7", color = ink)
    c.text("NOW " + str(round_int(d["temp"])) + " - " + d["name"].upper(), 32, 24, font = "4x5", color = ink)

def draw_city(c, d, x, y):
    # right-aligned, in the smaller font or clipped if the name runs long
    name = d["name"].upper()
    room = RIGHT_X - x
    font = fit_font(c, name, ["4x5", "picopixel"], room)
    for n in range(len(name), 0, -1):
        if c.text_width(name[:n], font) <= room:
            # a long name stops at a whole word
            cut = name[:n] if n == len(name) or name[n] == " " or " " not in name[:n] else name[:name[:n].rfind(" ")]
            c.text(cut.strip(), RIGHT_X, y, font = font, color = "#C4CEE4", align = "right")
            return

def now_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    icon = d["cur"]["icon"]
    cond = icon_cond(icon)
    is_day = "night" not in icon
    alert = top_alert(d)
    if alert != None and ALERT_STYLE[alert[0]][2]:
        warning_page(c, d, alert)
        return
    bg = cond_color(cond, is_day)
    c.rect(0, 0, c.width - 1, 31, fill = bg)
    # an advisory strip takes the bottom row, so everything moves up
    up = 0 if alert == None else 4
    if alert == None:
        big_icon(c, cond, 15, 15, is_day, bg)
    else:
        draw_mini_icon(c, cond, 9, 6)
    s = str(round_int(d["temp"]))
    w = c.text_width(s, "16x20")
    c.text(s, 32, 6 - up, font = "16x20", color = "white")
    draw_deg(c, 33 + w + 1, 6 - up, "white", True)
    x = 32 + w + 11
    words = COND_WORDS.get(cond, "")
    ap = apparent(d)
    if ap != None and abs(ap[1] - d["temp"]) >= 3:
        feels = "FEELS " + str(round_int(ap[1]))
        if words == "PARTLY CLOUDY":
            words = "PT CLOUDY"
        room = RIGHT_X - (x + c.text_width(words, "6x8") + 4)
        c.text(feels, RIGHT_X, 4, font = fit_font(c, feels, ["5x7", "4x5"], room), color = "#80D8FF" if ap[0] == "WIND CHILL" else "#FFB070", align = "right")
    c.text(words, x, 4, font = "6x8", color = "white")
    _a, _b, _c, hi, lo, _h, _l = day_curve(d, c.width)
    if hi != None:
        hl = "H" + str(round_int(hi)) + " L" + str(round_int(lo))
        c.text(hl, x, 14, font = "5x7", color = "#E6ECF8")
        draw_city(c, d, x + c.text_width(hl, "5x7") + 6, 15)
    if alert != None:
        draw_banner(c, ALERT_STYLE[alert[0]][0], alert[0].upper() + "  " + until_text(alert[1], d))
    else:
        c.text(next_line(d), x, 24, font = "4x5", color = "#FFE08A")

# ---------- page 2: air ----------

RIGHT_X = 188

def aqi_words(a):
    if a <= 50:
        return "GOOD", "#40D070"
    if a <= 100:
        return "MODERATE", "#E0D020"
    if a <= 150:
        return "SENSITIVE", "#FF8800"
    if a <= 200:
        return "UNHEALTHY", "#FF3030"
    return "VERY POOR", "#B050FF"

def air_cell(c, x0, w, label, value, vcol, word, wcol):
    cx = x0 + w // 2
    c.text(label, cx, 2, font = "4x5", color = LABEL, align = "center")
    c.text(value, cx, 11, font = "6x8", color = vcol, align = "center")
    c.text(word, cx, 23, font = "picopixel", color = wcol, align = "center")

def air_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    obs = d["obs"]
    cur = d["cur"]
    rh = obs["relative_humidity"] or 0
    dp = c_to_f(cur["dew_point"] or 0.0)
    dw, dc = dew_words(dp)
    trend = cur["pressure_trend"]
    tc = "#40D070" if trend == "rising" else ("#FF8800" if trend == "falling" else LABEL)
    uw, uc = uv_words(obs["uv"])
    air_cell(c, 0, 38, "HUMID", str(round_int(rh)) + "%", "white", humidity_word(rh), "#7fb4ff")
    air_cell(c, 38, 38, "DEW PT", str(round_int(dp)), tcol(dp), dw, dc)
    air_cell(c, 76, 40, "PRESS", format2(hpa_to_inhg(cur["sea_level_pressure"])), "white", trend.upper(), tc)
    air_cell(c, 116, 38, "UV", str(round_int(obs["uv"])), uc, uw, uc)
    if d["aqi"] != None:
        aw, ac = aqi_words(d["aqi"])
        air_cell(c, 154, 38, "AQI", str(d["aqi"]), ac, aw, ac)
    else:
        air_cell(c, 154, 38, "AQI", "--", LABEL, "", LABEL)

# ---------- page 3: wind ----------

def wind_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    cur = d["cur"]
    speed = cur["wind_avg"]
    deg = cur["wind_direction"]
    col = "white" if speed < 1 else safe_col(wind_color(speed))
    # the arrow flies with the wind: tail where it comes from, head where it's going
    if round_int(speed) > 0:
        fx = math.sin(math.radians(deg))
        fy = -math.cos(math.radians(deg))
        cx = 16
        cy = 15
        tipx = round_int(cx - fx * 11)
        tipy = round_int(cy - fy * 11)
        for o in [(0, 0), (1, 0), (0, 1), (1, 1)]:
            c.line(round_int(cx + fx * 11) + o[0], round_int(cy + fy * 11) + o[1], tipx + o[0], tipy + o[1], col)
            for sgn in [1, -1]:
                c.line(tipx + o[0], tipy + o[1], round_int(tipx + fx * 6 - sgn * fy * 5) + o[0], round_int(tipy + fy * 6 + sgn * fx * 5) + o[1], col)
    s = str(round_int(speed))
    c.text(s, 36, 6, font = "16x20", color = col)
    c.text("MPH", 36 + c.text_width(s, "16x20") + 4, 19, font = "5x7", color = LABEL)
    x = 104
    c.text("FROM " + CARDINAL_NAMES[compass_index(deg)], x, 4, font = "5x7", color = "white")
    c.text("GUSTS " + str(round_int(cur["wind_gust"])), x, 13, font = "5x7", color = "white")
    c.text(beaufort(speed) if round_int(speed) > 0 else "CALM", x, 23, font = "5x7", color = col)

# ---------- page 4: rain ----------

def rain2(v):
    n = round_int(v * 100)
    if n == 0:
        return "0"
    t = str(n // 100) + "." + pad_int(n % 100, 2)
    return t[1:] if n < 100 else t

def rain_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    today, r7, r30 = d["rain"]
    best = 0
    for h in [h for h in d["hourly"] if h["time"] > d["ts"]][:24]:
        best = max(best, h["precip_probability"])
    cells = [("TODAY", rain2(mm_to_in(today)), "IN"), ("7 DAYS", rain2(mm_to_in(r7)), "IN"), ("30 DAYS", rain2(mm_to_in(r30)), "IN"), ("NEXT 24H", str(best) + "%", "CHANCE")]
    w = c.width // 4
    for i in range(4):
        cx = i * w + w // 2
        c.text(cells[i][0], cx, 2, font = "4x5", color = LABEL, align = "center")
        c.text(cells[i][1], cx, 10, font = "8x12", color = "#FFFFFF" if i == 3 else "#66BBFF", align = "center")
        c.text(cells[i][2], cx, 24, font = "4x5", color = LABEL, align = "center")
        if i > 0:
            c.line(i * w, 4, i * w, 27, "#1A2340")

# ---------- page 5: today ----------
# Hourly data, so the labels are whole hours and whole degrees.

def when_label(epoch, d):
    local = epoch + d["tz"] * 60 + 1800
    h = (local % 86400) // 3600
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ("A" if h < 12 else "P")

# ---------- page 7: forecast ----------

def pop_bar(c, x0, w, pop):
    if pop > 0:
        c.rect(x0 + 3, 29, x0 + w - 3, 30, fill = "#14204a")
        c.rect(x0 + 3, 29, x0 + 3 + max((w - 6) * pop // 100, 1), 30, fill = "#3399FF")

def tonight_cell(c, d, x0, w, ahead):
    night = ahead[:12]
    low = 999.0
    pop = 0
    for h in night:
        low = min(low, c_to_f(h["air_temperature"]))
        pop = max(pop, h["precip_probability"])
    c.text("TONIGHT", x0 + w // 2, 1, font = "4x5", color = "#8fa0cc", align = "center")
    if len(night) > 0:
        draw_mini_icon(c, icon_cond(night[0]["icon"]), x0 + 2, 11)
        c.text("LOW", x0 + 26, 9, font = "4x5", color = "#8fa0cc", align = "center")
        temp_text(c, x0 + 18, 17, tdisp(d, low), "5x7", tcol(low))
    pop_bar(c, x0, w, pop)

def rest_of_day_icon(d, day, ahead):
    # the worst of the daylight left, not the whole day's code
    icon = d["cur"]["day_icon"]
    best = -1
    for h in ahead:
        if h["time"] < day["sunset"]:
            rk = PERIOD_RANK.get(icon_cond(h["icon"]), 1)
            if rk > best:
                best = rk
                icon = h["icon"]
    return icon

def forecast_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    days = d["daily"][:5]
    if len(days) == 0:
        return
    hi_all = -999.0
    lo_all = 999.0
    for x in days:
        hi_all = max(hi_all, c_to_f(x["air_temp_high"]))
        lo_all = min(lo_all, c_to_f(x["air_temp_low"]))
    ahead = [h for h in d["hourly"] if h["time"] > d["ts"]]
    cw = c.width // 5
    y0 = 8
    y1 = 26
    for i in range(len(days)):
        x = days[i]
        x0 = i * cw
        if i > 0:
            c.line(x0, 2, x0, 29, "#18214a")
        if i == 0 and d["ts"] >= x["sunset"]:
            tonight_cell(c, d, x0, cw, ahead)
            continue
        dn = ((x["day_start_local"] + d["tz"] * 60) // 86400 + 4) % 7
        c.text("TODAY" if i == 0 else WEEK[dn], x0 + cw // 2, 1, font = "4x5", color = "#8fa0cc", align = "center")
        draw_mini_icon(c, icon_cond(rest_of_day_icon(d, x, ahead) if i == 0 else x["icon"]), x0 + 2, 11)
        hi = c_to_f(x["air_temp_high"])
        lo = c_to_f(x["air_temp_low"])
        rng = max(hi_all - lo_all, 1.0)
        yh = round_int(y1 - (hi - lo_all) / rng * (y1 - y0))
        yl = round_int(y1 - (lo - lo_all) / rng * (y1 - y0))
        bx = x0 + 17
        c.rect(bx, y0, bx + 2, y1, fill = "#0e1838")
        for y in range(yh, yl + 1):
            c.line(bx, y, bx + 2, y, tcol(lo + (hi - lo) * (yl - y) / float(max(yl - yh, 1))))
        temp_text(c, bx + 5, 8, tdisp(d, hi), "5x7", tcol(hi))
        temp_text(c, bx + 5, 19, tdisp(d, lo), "5x7", tcol(lo))
        pop_bar(c, x0, cw, x["precip_probability"])

# ---------- page 8: sky ----------

def sky_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    rise, sset = sun_times(d)
    if rise != None:
        dl = (sset - rise) // 60
        rows = [("SUNRISE", epoch_to_local_hhmm(rise, d["tz"]), "#FFC040"), ("SUNSET", epoch_to_local_hhmm(sset, d["tz"]), "#FF9040"), ("DAYLIGHT", str(dl // 60) + "H " + pad_int(dl % 60, 2) + "M", "white")]
        for i in range(3):
            y = 3 + i * 9
            c.text(rows[i][0], 5, y, font = "5x7", color = LABEL)
            c.text(rows[i][1], 104, y, font = "5x7", color = rows[i][2], align = "right")
    c.line(112, 4, 112, 27, "#1A2340")
    data = moon_data(d)
    if data != None:
        ph = data.get("curphase", "") or ""
        fi = data.get("fracillum", "0%") or "0%"
        illum = int(fi.replace("%", "")) if "%" in fi else 0
        draw_moon_phase(c, 127, 15, 8, illum / 100.0, "Waxing" in ph or ph == "First Quarter", "#E8ECF8", "#1A2138")
        parts = ph.upper().split(" ")
        c.text(parts[0], 141, 6, font = "5x7", color = "white")
        c.text(parts[1] if len(parts) > 1 else "", 141, 14, font = "5x7", color = "white")
        c.text(str(illum) + "% LIT", 141, 23, font = "4x5", color = LABEL)

# ---------- pages ----------

def page(c, ctx, draw):
    bc = buffered(c)
    draw(bc, ctx)
    bc.flush()

def now(c, ctx):
    page(c, ctx, now_page)

def air(c, ctx):
    page(c, ctx, air_page)

def wind(c, ctx):
    page(c, ctx, wind_page)

def rain(c, ctx):
    page(c, ctx, rain_page)

def today(c, ctx):
    page(c, ctx, today_page)

def hourly(c, ctx):
    page(c, ctx, hourly_page)

def forecast(c, ctx):
    page(c, ctx, forecast_page)

def sky(c, ctx):
    page(c, ctx, sky_page)
