# Tempest Wx LED (64x32)
#
# Live conditions from your own WeatherFlow Tempest station (free personal
# access token from tempestwx.com > Settings > Data Authorizations) on a
# 64x32 panel - the small sibling of Tempest WX Graphic (192x32), sharing its
# data code:
#
#   1 now   a live sky scene: the sky follows the real time of day, the sun
#           and moon ride a small arc, clouds / rain / snow / fog / lightning
#           follow the conditions, and a house, tree or skyline matches where
#           the station is (US Census geocoder). The temperature (tenths), the
#           conditions, today's real high / low, and along the ground the
#           heat index / wind chill when one applies, else the next sunrise or
#           sunset
#   2 air   humidity, dew point, pressure + trend arrow, UV
#   3 wind  a compass dial: a red pointer on the ring at the side the wind is
#           coming from, an arc over the directions of the last 10 minutes,
#           the direction in the middle; speed, the Beaufort term, gust and
#           today's high gust
#   4 rain  a 2-inch rain gauge (bluer page and drops falling into the tube
#           while it's wet), today's rain and minutes of rain, last hour
#           (or the last lightning strike's distance), the month - becomes a
#           LIGHTNING card (distance, minutes ago) while a strike within 10
#           miles has happened in the last 30 minutes (NWS safety rules)
#
# NWS alerts (US): 57 event types (ALERT_STYLE), ranked by the NWS hazard-map
# priority. A warning (or civil emergency) takes over page 1 - name, until,
# the temperature, "+N" for more alerts - and puts hazard stripes on the
# edges of pages 2-4; watches / advisories / statements ride page 1's bottom
# strip. Page 1 also flags a station that's gone offline or a low battery.
#
# Data: WeatherFlow REST (station obs, device obs history, better_forecast),
# USNO (moon), NWS (alerts), US Census geocoder (scene) - all keyless beyond
# the user's own Tempest token. Everything is computed in F / mph / inches;
# the Units setting only converts what's printed.
#
# Typing DEMO as the token shows canned data for catalog previews.

CARDINAL_NAMES = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

WEEKDAY_NAMES = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

# ---------- small input helper ----------
# An unset/cleared input can come back as None even with a fallback given to
# ctx.inputs.get(), so coerce before using it (see apps/local-aqi, apps/stocks, etc).

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return v

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

def format3(value):
    neg = value < 0
    v = -value if neg else value
    thousandths = round_int(v * 1000)
    whole = thousandths // 1000
    frac = thousandths % 1000
    s = str(whole) + "." + pad_int(frac, 3)
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

def km_to_mi(km):
    return km * 0.621371

def mps_to_mph(mps):
    return mps * 2.23693629

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
def tempest_icon_to_cond(icon):
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

# ---------- DEMO sample data ----------
# Typing the literal token DEMO swaps every fetch below for these canned
# responses (a mild, partly cloudy afternoon with a storm cell nearby), so
# the catalog previews show the real layout instead of the setup message.
# A panel with no token at all still gets "SET API TOKEN". This never fires
# by accident - a real user has to type DEMO on purpose.

DEMO_TOKEN = "DEMO"

DEMO_TS = 1790192700  # 2:45 PM local at tz -300

DEMO_TZ_MIN = -300

def is_demo_token(token):
    return str(token).strip().upper() == DEMO_TOKEN

DEMO_OBSERVATION = {"status_code": 200, "json": {"obs": [{
    "timestamp": DEMO_TS,
    "air_temperature": 22.8,
    "relative_humidity": 58,
    "station_pressure": 1016.2,
    "pressure_trend": "rising",
    "precip_accum_local_day": 4.3,
    "precip_accum_last_1hr": 1.8,
    "precip_accum_local_yesterday_final": 14.7,
    "precip_minutes_local_day": 52,
    "precip_minutes_local_yesterday_final": 186,
    "lightning_strike_last_epoch": DEMO_TS - 12 * 60,
    "lightning_strike_last_distance": 11,
    "lightning_strike_count_last_1hr": 14,
    "lightning_strike_count_last_3hr": 41,
    "uv": 4.2,
    "solar_radiation": 512,
    "brightness": 61400,
}]}}

DEMO_BETTER_FORECAST = {"status_code": 200, "json": {"current_conditions": {
    "air_temperature": 22.8,
    "feels_like": 24.1,
    "dew_point": 14.1,
    "relative_humidity": 58,
    "station_pressure": 1015.6,
    "sea_level_pressure": 1016.2,
    "pressure_trend": "rising",
    "icon": "partly-cloudy-day",
    "wind_avg": 12,
    "wind_direction": 225,
    "wind_gust": 19,
}, "forecast": {"daily": [
    {"air_temp_high": 26.1, "air_temp_low": 16.7, "precip_probability": 40},
]}}}

# Positional obs_st rows: [epoch, lull, avg, gust, dir, interval, pressure,
# temp, rh, lux, uv, solar, rain_mm, precip_type, strike_dist, strike_count].
# Wind reads the day's max gust (index 3), lull (1) and average (2);
# rainfall2 sums the month's rain (index 12); lightning sums today's strikes
# (index 15).
DEMO_DEVICE_OBS = {"status_code": 200, "json": {"obs": [
    [DEMO_TS - 86400 * 9, 1.0, 2.1, 4.0, 200, 60, 1014.0, 19.0, 70, 0, 0, 0, 22.4, 1, 0, 0],
    [DEMO_TS - 86400 * 7, 1.1, 2.3, 4.4, 205, 60, 1013.0, 19.5, 72, 0, 0, 0, 6.1, 1, 0, 0],
    [DEMO_TS - 86400 * 4, 1.2, 2.6, 5.1, 210, 60, 1012.0, 20.0, 74, 0, 0, 0, 18.6, 1, 0, 0],
    [DEMO_TS - 86400, 0.8, 1.9, 3.8, 190, 60, 1011.0, 18.0, 88, 0, 0, 0, 14.7, 1, 0, 0],
    [DEMO_TS - 7200, 2.4, 4.6, 9.8, 230, 60, 1015.0, 22.0, 60, 0, 0, 0, 2.5, 1, 14, 46],
    [DEMO_TS - 600, 3.1, 5.4, 11.2, 225, 60, 1016.2, 22.8, 58, 0, 0, 0, 1.8, 1, 11, 41],
]}}

DEMO_STATION = {
    "token": DEMO_TOKEN,
    "demo": True,
    "station_id": 0,
    "device_id": 0,
    "name": "BACKYARD",
    "lat": 39.1,
    "lon": -94.6,
    "tz_offset_min": DEMO_TZ_MIN,
}

# ---------- network ----------

def fetch_stations(token):
    return http.get(
        "https://swd.weatherflow.com/swd/rest/stations",
        params = {"token": token},
        ttl_seconds = 3600,
    )

def fetch_observation(token, station_id):
    if is_demo_token(token):
        return DEMO_OBSERVATION
    return http.get(
        "https://swd.weatherflow.com/swd/rest/observations/station/" + str(station_id),
        params = {
            "token": token,
            "units_wind": "mph",
            "units_pressure": "inhg",
            "units_distance": "mi",
        },
        ttl_seconds = 60,
    )

def fetch_device_observations(token, device_id, time_start, time_end):
    if is_demo_token(token):
        return DEMO_DEVICE_OBS
    return http.get(
        "https://swd.weatherflow.com/swd/rest/observations/device/" + str(device_id),
        params = {
            "token": token,
            "time_start": str(time_start),
            "time_end": str(time_end),
        },
        ttl_seconds = 300,
    )

def fetch_better_forecast(token, station_id):
    if is_demo_token(token):
        return DEMO_BETTER_FORECAST
    return http.get(
        "https://swd.weatherflow.com/swd/rest/better_forecast",
        params = {
            "station_id": str(station_id),
            "token": token,
            "units_wind": "mph",
            "units_pressure": "mb",
        },
        ttl_seconds = 300,
    )

# US Naval Observatory's free, keyless astronomical data API - the almanac
# page's moon phase/illumination/moonrise/moonset all come from here (NWS
# and WeatherFlow have neither; hand-rolling low-precision lunar rise/set
# math was the alternative, and USNO is the actual government authority
# for this data anyway). tz is decimal hours (not minutes, unlike this
# app's own tz_offset_min) - passing it means every time in the response
# already comes back in local time, no epoch conversion needed.
def fetch_moon_almanac(date_str, lat, lon, tz_hours):
    return http.get(
        "https://aa.usno.navy.mil/api/rstt/oneday?date=" + date_str + "&coords=" + format4(lat) + "," + format4(lon) + "&tz=" + str(tz_hours),
        headers = {"User-Agent": "GDN-Tempest-Deluxe (glance-led-panel)"},
        ttl_seconds = 3600,
    )

def resolve_station(ctx):
    token = _s(ctx, "token", "")
    if not token:
        return None, "no token"
    if is_demo_token(token):
        return DEMO_STATION, None

    resp = fetch_stations(token)
    if resp["status_code"] in [401, 403]:
        return None, "auth failed"
    if resp["status_code"] != 200:
        return None, "unreachable"

    stations = resp["json"].get("stations", [])
    if len(stations) == 0:
        return None, "no stations"

    chosen = stations[0]

    devices = chosen.get("devices", [])
    device_id = None
    agl = 0.0
    for d in devices:
        if d.get("device_type", None) == "ST":
            device_id = d.get("device_id", None)
            agl = ((d.get("device_meta", {}) or {}).get("agl", 0.0)) or 0.0
            break
    if device_id == None and len(devices) > 0:
        device_id = devices[0].get("device_id", None)

    return {
        "token": token,
        "station_id": chosen.get("station_id"),
        "device_id": device_id,
        "name": chosen.get("public_name", None) or chosen.get("name", "STATION"),
        "lat": chosen.get("latitude", 0),
        "lon": chosen.get("longitude", 0),
        "tz_offset_min": chosen.get("timezone_offset_minutes", 0),
        # what the owner entered in the Tempest app: ground elevation + how
        # high the sensor is mounted (meters)
        "height_m": (((chosen.get("station_meta", {}) or {}).get("elevation", 0.0)) or 0.0) + agl,
    }, None

# ---------- WeatherSTAR 4000 palette + gradients ----------
# Ported straight from tempest-dashboard's own CSS custom properties rather
# than reinvented: --navy-deep #0a1250, --navy-panel #1a2d8f (body
# background, top-to-bottom), --orange #ff7a00 / --purple #6a1b9a (title
# bar, left-to-right - the CSS gradient is a 115deg diagonal, but at 8px
# tall a left-to-right approximation reads the same). This is the one
# visual swap from tempest-weather's amber/black day-night header - real
# WeatherSTAR title bars don't shift with time of day.

def rgb_to_hex(r, g, b):
    digits = "0123456789ABCDEF"
    r = 0 if r < 0 else (255 if r > 255 else r)
    g = 0 if g < 0 else (255 if g > 255 else g)
    b = 0 if b < 0 else (255 if b > 255 else b)
    return "#" + digits[r // 16] + digits[r % 16] + digits[g // 16] + digits[g % 16] + digits[b // 16] + digits[b % 16]


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

def format_minutes(minutes):
    if minutes < 60:
        return str(minutes) + " MIN"
    return str(minutes // 60) + "H " + pad_int(minutes % 60, 2) + "M"

def local_day_start(ts, tz_offset_min):
    return ts - ((ts + tz_offset_min * 60) % 86400)

# Setup / problem screen: the night-sky scene with two lines of plain words,
# instead of a bare error - it's the first thing a new owner sees.
def wrap_words(c, text, font, w):
    lines = [""]
    for word in text.split(" "):
        t = word if lines[-1] == "" else lines[-1] + " " + word
        if c.text_width(t, font) <= w or lines[-1] == "":
            lines[-1] = t
        else:
            lines.append(word)
    return lines

# The setup / problem screen: a night sky, the message word-wrapped over it.
def draw_error(c, line1, line2 = ""):
    top, bot = SKY_NIGHT
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix(top, bot, min(y, 26) / 26.0)))
    for st in MINI_STARS:
        c.pixel(st[0], st[1], "#c8d0ff" if (st[0] + st[1]) % 3 else "#6f78a8")
    mini_ground(c, False, "suburb")
    y = 1
    for ln in wrap_words(c, line1, "4x5", c.width - 4):
        stext(c, ln, 2, y, "4x5", "white")
        y += 7
    for ln in wrap_words(c, line2, "picopixel", c.width - 4):
        if y > 21:
            break
        stext(c, ln, 2, y, "picopixel", "#AACCFF")
        y += 6

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

def hex_to_rgb(hexcolor):
    return (int(hexcolor[1:3], 16), int(hexcolor[3:5], 16), int(hexcolor[5:7], 16))

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

# ---------- shared station load ----------

def load_station(c, ctx):
    station, err = resolve_station(ctx)
    if station == None:
        if err == "no token":
            draw_error(c, "ENTER YOUR TEMPEST TOKEN", "IN SETTINGS - OR TRY DEMO")
        elif err == "no stations":
            draw_error(c, "NO STATION ON THIS TOKEN", "ADD ONE IN THE TEMPEST APP")
        elif err == "unreachable":
            draw_error(c, "CANNOT REACH WEATHERFLOW", "TRYING AGAIN SHORTLY")
        else:
            draw_error(c, "TEMPEST TOKEN NOT ACCEPTED", "CHECK IT IN SETTINGS")
        return None
    return station

def strike_distance_color(mi):
    if mi <= 4:
        return "#FF0000"
    elif mi <= 8:
        return "#FF4400"
    elif mi <= 12:
        return "#FF8800"
    elif mi <= 16:
        return "amber"
    elif mi <= 20:
        return "#CCCC33"
    else:
        return "yellow"

def find_almanac_time(entries, phen):
    for e in entries:
        if e.get("phen") == phen:
            return e.get("time", None)
    return None

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

# ---------- drawing helpers for the full-bleed pages ----------

def mix(a, b, t):
    return (round_int(lerp(a[0], b[0], t)), round_int(lerp(a[1], b[1], t)), round_int(lerp(a[2], b[2], t)))

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

def stext(c, s, x, y, font, color, align = "left", shadow = "#06102a"):
    c.text_stroke(s, x, y, font = font, color = color, stroke = shadow, align = align)

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

# The big temperature's color: the normal temperature scale, except the cold
# end fades toward ice-white (from 40F down, fully icy by 15F) so a cold
# reading never sinks into a blue daytime sky.
ICE = (225, 240, 255)

def hero_color(f):
    base = gradient_at(TEMP_RAMP, f)
    if f >= 40:
        return hexc(base)
    return hexc(mix(base, ICE, clamp((40.0 - f) / 25.0, 0.0, 1.0) * 0.8))

TEMP_RAMP = [(0.0, (150, 80, 255)), (20.0, (70, 90, 255)), (32.0, (40, 140, 255)), (45.0, (0, 200, 230)), (58.0, (40, 215, 110)), (68.0, (200, 225, 40)), (76.0, (255, 190, 0)), (85.0, (255, 120, 0)), (95.0, (255, 50, 20)), (105.0, (230, 0, 60))]

def tcol(f):
    return hexc(gradient_at(TEMP_RAMP, f))

BG_TOP = (10, 16, 46)

BG_BOT = (3, 5, 18)

def draw_bg(c):
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix(BG_TOP, BG_BOT, y / 31.0)))

# ---------- DEMO data (catalog previews) ----------

DEMO_RISE = DEMO_TS - (14 * 3600 + 45 * 60) + (6 * 3600 + 58 * 60)

DEMO_SET = DEMO_TS - (14 * 3600 + 45 * 60) + (19 * 3600 + 4 * 60)

def demo_temp_c(epoch):
    local_h = ((epoch + DEMO_TZ_MIN * 60) % 86400) / 3600.0
    return 18.0 + 5.2 * math.sin((local_h - 9.0) / 24.0 * 2 * math.pi)

def demo_day_obs(day_start, ts):
    rows = []
    for i in range(int((ts - day_start) // 300) + 1):
        e = day_start + i * 300
        h = ((e + DEMO_TZ_MIN * 60) % 86400) / 3600.0
        avg = 1.2 + 3.6 * clamp(math.sin((h - 7.0) / 14.0 * math.pi), 0.0, 1.0) + 0.6 * math.sin(i * 1.7)
        d = 225 + 40 * math.sin(i * 0.37) + 25 * math.sin(i * 1.3)
        if h < 9:
            d = d - 120
        rain = 0.0
        dist = 0
        cnt = 0
        if h >= 12.5 and h < 14.6:
            rain = 0.08 + 0.12 * math.sin((h - 12.5) / 2.1 * math.pi)
        if h >= 11.9 and h < 14.6:
            cnt = int(1 + 3 * math.sin((h - 11.9) / 2.7 * math.pi) + (i % 3))
            dist = int(38 - (h - 11.9) * 10 + (i % 5) * 2)
        rows.append([e, avg * 0.6, avg, avg * 1.7 + 0.8 * math.sin(i * 2.1), int(d) % 360, 60, 1016.0, demo_temp_c(e), 60, 0, 0, 0, rain, 1 if rain > 0 else 0, dist, cnt])
    return rows

DEMO_ICONS = ["possibly-thunderstorm-day", "partly-cloudy-day", "partly-cloudy-day", "clear-day", "clear-night", "partly-cloudy-night", "clear-night", "clear-night"]

DEMO_POPS = [40, 30, 20, 10, 0, 0, 0, 0]

def demo_temp_shift(sec):
    # 0 through the first day's 3 PM, then linear between each day's 3 PM
    # anchor of (that day's high - the demo curve's own high, 23.2 C)
    k = (sec - 15 * 3600) / 86400.0
    if k <= 0:
        return 0.0
    i = int(k)
    a = 0.0 if i == 0 else DEMO_DAILY[min(i, len(DEMO_DAILY) - 1)][0] - 23.2
    b = DEMO_DAILY[min(i + 1, len(DEMO_DAILY) - 1)][0] - 23.2
    return a + (b - a) * (k - i)

# the demo forecast: from midnight of the demo day for 4 days (the hours
# after DEMO_TS keep DEMO_ICONS / DEMO_POPS; later days follow DEMO_DAILY)
def demo_hourly():
    out = []
    first = DEMO_TS - DEMO_TS % 3600 + 3600
    day0 = DEMO_TS - ((DEMO_TS + DEMO_TZ_MIN * 60) % 86400)
    for j in range(96):
        e = day0 + j * 3600
        i = (e - first) // 3600
        dn = j // 24
        lh = j % 24
        daytime = lh >= 7 and lh < 19
        dd = DEMO_DAILY[min(dn, len(DEMO_DAILY) - 1)]
        # the same daily swing every day, shifted toward each day's DEMO_DAILY
        # high (anchored at 3 PM, blended in between so there are no jumps)
        temp = demo_temp_c(e) + demo_temp_shift(e - day0)
        if i >= 0 and i < len(DEMO_ICONS):
            icon = DEMO_ICONS[i]
            pop = DEMO_POPS[i]
        elif dn == 0 or not daytime:
            icon = "clear-day" if daytime else ("partly-cloudy-night" if dd[3] >= 30 else "clear-night")
            pop = 0 if dn == 0 else dd[3] // 2
        else:
            icon = dd[2]
            pop = dd[3]
        out.append({
            "time": e,
            "air_temperature": temp,
            "icon": icon,
            "precip_probability": pop,
            "wind_avg": max(3.0, 12.0 - max(i, 0) * 1.1),
            "wind_gust": max(5.0, 18.0 - max(i, 0) * 1.3),
        })
    return out

DEMO_DAILY = [
    (26.1, 16.7, "possibly-thunderstorm-day", 40),
    (27.2, 17.8, "clear-day", 0),
    (25.0, 18.9, "partly-cloudy-day", 10),
    (22.2, 15.6, "rainy", 80),
    (19.4, 11.7, "cloudy", 30),
    (20.6, 10.0, "clear-day", 0),
    (23.3, 12.8, "partly-cloudy-day", 10),
]

def demo_daily():
    out = []
    day0 = DEMO_TS - ((DEMO_TS + DEMO_TZ_MIN * 60) % 86400)
    for i in range(len(DEMO_DAILY)):
        hi, lo, icon, pop = DEMO_DAILY[i]
        out.append({
            "day_start_local": day0 + i * 86400,
            "air_temp_high": hi,
            "air_temp_low": lo,
            "icon": icon,
            "precip_probability": pop,
            "sunrise": DEMO_RISE + i * 86400,
            "sunset": DEMO_SET + i * 86400 - i * 120,
        })
    return out

# ---------- where the station is: farm, house, town or city ----------
# US Census geocoder (keyless): the station's ZIP Code Tabulation Area gives
# its 2020 population and land area (people per square mile), and the
# Incorporated Places layer gives the town / city population, if any. The
# answer never really changes, so it's cached for 30 days. Outside the US (or
# on any failure) it falls back to the house.

def fetch_census_place(lat, lon):
    return http.get(
        "https://geocoding.geo.census.gov/geocoder/geographies/coordinates",
        params = {
            "x": format4(lon),
            "y": format4(lat),
            "benchmark": "Public_AR_Current",
            "vintage": "Census2020_Current",
            "layers": "Zip Code Tabulation Areas,Incorporated Places",
            "format": "json",
        },
        ttl_seconds = 2592000,
    )

SQ_M_PER_SQ_MI = 2589988.0

def classify_place(density, place_pop):
    if density >= 4000 or (place_pop >= 250000 and density >= 2500):
        return "city"
    if place_pop > 0 and place_pop < 100000 and density >= 250:
        return "town"
    if density >= 250:
        return "suburb"
    return "rural"

def station_place(station):
    if station.get("demo"):
        return "suburb"
    resp = fetch_census_place(station["lat"], station["lon"])
    if resp["status_code"] != 200:
        return "suburb"
    geo = ((resp["json"] or {}).get("result", {}) or {}).get("geographies", {}) or {}
    zl = geo.get("Zip Code Tabulation Areas", []) or []
    if len(zl) == 0:
        return "suburb"
    z = zl[0]
    pop = z.get("POP100", None)
    area = z.get("AREALAND", None)
    if pop == None or area == None or float(area) <= 0:
        return "suburb"
    density = pop / (float(area) / SQ_M_PER_SQ_MI)
    pl = geo.get("Incorporated Places", []) or []
    place_pop = (pl[0].get("POP100", 0) or 0) if len(pl) > 0 else 0
    return classify_place(density, place_pop)

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

def load_all_now(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return None
    fc = fetch_better_forecast(station["token"], station["station_id"])
    fcj = fc["json"] if fc["status_code"] == 200 else {}
    cur = fcj.get("current_conditions", {}) or {}
    obs_resp = fetch_observation(station["token"], station["station_id"])
    obs_list = obs_resp["json"].get("obs", []) if obs_resp["status_code"] == 200 else []
    obs = obs_list[0] if len(obs_list) > 0 else {}
    ts = obs.get("timestamp", 0)
    forecast = fcj.get("forecast", {}) or {}
    if station.get("demo"):
        hourly = demo_hourly()
        daily = demo_daily()
    else:
        hourly = forecast.get("hourly", []) or []
        daily = forecast.get("daily", []) or []
    # (DEMO testing only) clock=HH:MM moves the demo to another time of day,
    # icon=<tempest icon> swaps the current conditions
    if station.get("demo"):
        clk = _s(ctx, "clock", "")
        if len(clk) == 5:
            ts = local_day_start(ts, station["tz_offset_min"]) + int(clk[0:2]) * 3600 + int(clk[3:5]) * 60
            obs = dict(obs)
            obs["timestamp"] = ts
            obs["air_temperature"] = demo_temp_c(ts)
        ic = _s(ctx, "icon", "")
        if ic != "":
            cur = dict(cur)
            cur["icon"] = ic
            cur["conditions"] = ""

    # (DEMO testing only) farstorm=on pushes the demo storm 3x farther away
    far = station.get("demo") and _s(ctx, "farstorm", "off") == "on"
    if far:
        obs = dict(obs)
        obs["lightning_strike_last_distance"] = obs.get("lightning_strike_last_distance", 0) * 3
    temp_c = obs.get("air_temperature", None)
    if temp_c == None:
        temp_c = cur.get("air_temperature", 0.0)
    return {
        "ctx": ctx,
        "metric": _s(ctx, "units", "Imperial") == "Metric",
        "far": far,
        "station": station,
        "cur": cur,
        "obs": obs,
        "ts": ts,
        "hourly": hourly,
        "daily": daily,
        "temp": c_to_f(temp_c),
        "tz": station["tz_offset_min"],
    }

# ---------- units ----------
# Everything is computed in F / mph / inches / miles (the color scales and
# thresholds are all tuned in those units); only what's printed converts.

def demo_opt(d, key):
    # (DEMO testing only) extra inputs that force a scene, alert, etc. - ignored
    # for any real station
    return _s(d["ctx"], key, "") if d["station"].get("demo") else ""

def tdisp(d, f):
    return (f - 32.0) / 1.8 if d["metric"] else f

def spd(d, mph):
    return mph * 1.609344 if d["metric"] else mph

def spd_unit(d):
    return "KM/H" if d["metric"] else "MPH"

def rain_str(d, inches):
    if d["metric"]:
        mm = inches * 25.4
        return "0" if round_int(mm * 10) == 0 else format1(mm)
    return fmt_in(inches)

def rain_unit(d):
    return "MM" if d["metric"] else "IN"

def dist_str(d, mi):
    return format1(mi * 1.609344) if d["metric"] else format1(mi)

def dist_unit(d):
    return "KM" if d["metric"] else "MI"

def day_obs_rows(d):
    st = d["station"]
    day_start = local_day_start(d["ts"], d["tz"])
    if st.get("demo"):
        rows = demo_day_obs(day_start, d["ts"])
        if d.get("far"):
            rows = [r[:14] + [min(r[14] * 3, 40), r[15]] for r in rows]
        return day_start, rows
    if st["device_id"] == None or d["ts"] <= 0:
        return day_start, []
    # end of today (not "now") keeps the request the same all day, so it can
    # come from the cache between refreshes
    resp = fetch_device_observations(st["token"], st["device_id"], day_start, day_start + 86400)
    if resp["status_code"] != 200:
        return day_start, []
    return day_start, [r for r in resp["json"].get("obs", []) if len(r) > 7 and r[0] >= day_start]

def sun_times(d):
    daily = d["daily"]
    if len(daily) > 0 and daily[0].get("sunrise", None) != None:
        return daily[0]["sunrise"], daily[0]["sunset"]
    return None, None

# ---------- sky scene ----------

SKY_DAY = ((28, 98, 214), (150, 206, 255))

SKY_GOLD = ((44, 52, 140), (255, 146, 72))

SKY_TWI = ((12, 18, 64), (118, 66, 128))

SKY_NIGHT = ((2, 4, 16), (18, 26, 72))

GRAY_DAY = (96, 106, 122)

GRAY_NIGHT = (22, 25, 34)

def sky_state(ts, rise, sset):
    # returns (palette, is_day, t along the visible arc 0..1 or None)
    if rise == None:
        return SKY_DAY, True, 0.5
    if ts >= rise and ts <= sset:
        t = (ts - rise) / float(sset - rise)
        edge = min(ts - rise, sset - ts)
        if edge < 2400:
            return SKY_GOLD, True, t
        return SKY_DAY, True, t
    since = (ts - sset) if ts > sset else (ts + 86400 - sset)
    until = (rise - ts) if ts < rise else (rise + 86400 - ts)
    if since < 2400 or until < 2400:
        pal = SKY_TWI
    else:
        pal = SKY_NIGHT
    night_len = (rise + 86400) - sset
    t = since / float(night_len)
    return pal, False, clamp(t, 0.0, 1.0)

def arc_xy(t, x0, x1, y_base, h):
    return round_int(x0 + t * (x1 - x0)), round_int(y_base - math.sin(math.pi * t) * h)

def draw_puff(c, cx, cy, w, color):
    r = w // 4
    c.fill_circle(cx - r - 1, cy + 1, r, color)
    c.fill_circle(cx + r + 1, cy + 1, r, color)
    c.fill_circle(cx, cy - 1, r + 1, color)
    c.rect(cx - r - 1, cy + 1, cx + r + 1, cy + r + 1, fill = color)

# WeatherFlow's own rain-intensity tiers (mm/hr) - the same words as the
# Tempest dashboard (community.tempest.earth/t/rain-intensity-values/806)
RAIN_TIERS = [(0.25, "VERY LIGHT RAIN"), (1.0, "LIGHT RAIN"), (4.0, "MODERATE RAIN"), (16.0, "HEAVY RAIN"), (50.0, "VERY HEAVY RAIN")]

# Strikes (2+, so one false reading never counts) from the station's own
# lightning sensor: within 10 miles in the last 30 minutes is the NWS safety
# rule - the same one that turns the Rain page into STORM MODE - and anything
# else within 25 miles in the last 20 minutes is "lightning N miles away"
# (older than that, a distant storm has moved on or closed in).
STRIKES_MIN = 2

LIGHTNING_FAR_MI = 25.0

LIGHTNING_FAR_SEC = 20 * 60

# (strikes close by, strikes in the last 20 min within 25 mi, nearest of those mi)
def strike_summary(d):
    if demo_opt(d, "strikes") != "":
        n = int(demo_opt(d, "strikes"))
        mi = float(demo_opt(d, "strikemi") or "6")
        ago = float(demo_opt(d, "strikeago") or "5") * 60
        near = n if (mi <= STORM_NEAR_MI and ago <= STORM_QUIET_SEC) else 0
        far = n if (mi <= LIGHTNING_FAR_MI and ago <= LIGHTNING_FAR_SEC) else 0
        return near, far, mi
    day_start, rows = day_obs_rows(d)
    near = 0
    far = 0
    best = None
    for r in rows:
        if len(r) <= 15 or r[15] == None or r[15] <= 0 or r[14] == None:
            continue
        age = d["ts"] - r[0]
        mi = km_to_mi(r[14])
        if age <= STORM_QUIET_SEC and mi <= STORM_NEAR_MI:
            near += r[15]
        if age <= LIGHTNING_FAR_SEC and mi <= LIGHTNING_FAR_MI:
            far += r[15]
            if best == None or mi < best:
                best = mi
    return near, far, best

# What the Now page says and draws, from the station's own sensors first:
# (scene condition, words or None for WeatherFlow's text, rain level 0-6,
# distant bolt). In order:
#  1. 2+ strikes within 10 mi in the last 30 min: THUNDERSTORM if it's
#     raining here, T-STORM NEARBY if it's dry
#  2. 2+ strikes within 25 mi in the last 20 min: LIGHTNING 18 MI
#  3. WeatherFlow's own thunderstorm call (likely / possible) keeps its words
#  4. rain falling right now (the last minute's rain x 60 = an hourly rate):
#     the intensity words - unless it's 34F or colder, where the gauge can't
#     tell rain from sleet and WeatherFlow's call stands
#  5. otherwise WeatherFlow's text
def now_weather(d):
    icon = d["cur"].get("icon") or ""
    cond = tempest_icon_to_cond(icon)
    rate = (d["obs"].get("precip", 0.0) or 0.0) * 60.0
    if demo_opt(d, "rainmm") != "":
        rate = float(demo_opt(d, "rainmm"))
    level = 0
    label = None
    if rate > 0:
        level = 6
        label = "EXTREME RAIN"
        for k in range(len(RAIN_TIERS)):
            if rate < RAIN_TIERS[k][0]:
                level = k + 1
                label = RAIN_TIERS[k][1]
                break
    wet_cond = "Rain" if level > 0 else ("Clouds" if cond in ["Clear", "ClearNight", "PartlyCloudy", "PartlyCloudyNight"] else cond)
    near, far, far_mi = strike_summary(d)
    if near >= STRIKES_MIN:
        if level > 0:
            return "Thunderstorm", "THUNDERSTORM", level, False
        return "Clouds", "T-STORM NEARBY", 0, True
    if far >= STRIKES_MIN and far_mi != None:
        return wet_cond, "LIGHTNING " + dist_str_whole(d, far_mi) + " " + dist_unit(d), level, False
    if "thunderstorm" in icon:
        return ("Rain" if level > 0 and cond == "Clouds" else cond), None, level, False
    if level > 0 and cond not in ["Snow", "Sleet"] and d["temp"] > 34.0:
        return "Rain", label, level, False
    return cond, None, 0, False

def dist_str_whole(d, mi):
    return str(round_int(mi * 1.609344 if d["metric"] else mi))

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
    "Windy": "WINDY",
}

# Today's actual high / low so far from the station's own readings (and the
# current temp), with the epoch each happened. Used by the Now page's H / L.
def station_hilo(d, rows):
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

def moon_almanac_resp(d):
    st = d["station"]
    if st.get("demo"):
        return DEMO_SKY_ALMANAC
    lt = d["ts"] + d["tz"] * 60
    yy, mm, dd = civil_from_days(lt // 86400)
    return fetch_moon_almanac(str(yy) + "-" + pad_int(mm, 2) + "-" + pad_int(dd, 2), st["lat"], st["lon"], d["tz"] / 60.0)

# (arc position 0..1 or None when down, illuminated fraction, waxing) - or
# None if USNO is unavailable.
def moon_now(d):
    resp = moon_almanac_resp(d)
    if resp["status_code"] != 200:
        return None
    data = (resp["json"].get("properties", {}) or {}).get("data", {}) or {}
    ph = data.get("curphase", "") or ""
    fi = data.get("fracillum", "0%") or "0%"
    illum = int(fi.replace("%", "")) if "%" in fi else 0
    md = data.get("moondata", []) or []
    now_m = ((d["ts"] + d["tz"] * 60) % 86400) // 60
    t = moon_arc_t(now_m, find_almanac_time(md, "Rise"), find_almanac_time(md, "Set"), find_almanac_time(md, "Upper Transit"))
    return (t, illum / 100.0, "Waxing" in ph or ph == "First Quarter")

def hm_minutes(t):
    return int(t[0:2]) * 60 + int(t[3:5])

# Where the moon is along its rise-to-set arc right now (0..1), or None when
# it's below the horizon. USNO gives today's local rise / set / upper transit;
# when the moon rose yesterday or sets tomorrow, the missing end is estimated
# from the transit (transit is the midpoint), else a typical 12h25m pass.
MOON_PASS_MIN = 745

# Demo moon for this page: a waxing gibbous already up in the afternoon, so
# the catalog preview shows the daytime moon riding the arc with the sun.
DEMO_SKY_ALMANAC = {"status_code": 200, "json": {"properties": {"data": {
    "curphase": "Waxing Gibbous",
    "fracillum": "78%",
    "moondata": [{"phen": "Set", "time": "01:48"}, {"phen": "Rise", "time": "13:02"}, {"phen": "Upper Transit", "time": "19:20"}],
    "sundata": [{"phen": "Rise", "time": "06:58"}, {"phen": "Set", "time": "19:04"}],
}}}}

def moon_arc_t(now, rise, sset, trans):
    r = hm_minutes(rise) if rise != None else None
    st = hm_minutes(sset) if sset != None else None
    tr = hm_minutes(trans) if trans != None else None
    if r != None and st != None and r < st:
        if now >= r and now <= st:
            return (now - r) / float(st - r)
        return None
    if st != None and now <= st:
        dur = 2 * (st - tr) if (tr != None and tr < st) else MOON_PASS_MIN
        return clamp((now - (st - dur)) / float(dur), 0.0, 1.0)
    if r != None and now >= r:
        dur = 2 * (tr - r) if (tr != None and tr > r) else MOON_PASS_MIN
        return clamp((now - r) / float(dur), 0.0, 1.0)
    return None

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

# Station pressure -> sea level (standard-atmosphere reduction).
def sea_level_hpa(hpa, height_m, temp_c):
    ratio = 1.0 - (0.0065 * height_m) / (temp_c + 0.0065 * height_m + 273.15)
    return hpa / math.pow(ratio, 5.257)

def humidity_word(rh):
    if rh < 30:
        return "DRY"
    elif rh < 60:
        return "PLEASANT"
    elif rh < 80:
        return "HEAVY"
    return "DAMP"

# ---------- rain (+ lightning on the same timeline) ----------

def fmt_in(v):
    if round_int(v * 1000) == 0:
        return "0"
    s = format3(v)
    return s[1:] if s.startswith("0.") and v > 0 else s

def safe_col(col):
    return "#FFBF00" if col == "amber" else col

def month_rain(d):
    st = d["station"]
    if st.get("demo"):
        return 2.60, 5
    if st["device_id"] == None or d["ts"] <= 0:
        return None, None
    lt = d["ts"] + d["tz"] * 60
    yy, mm, dd = civil_from_days(lt // 86400)
    ms = days_from_civil(yy, mm, 1) * 86400 - d["tz"] * 60
    resp = fetch_device_observations(st["token"], st["device_id"], ms, local_day_start(d["ts"], d["tz"]) + 86400)
    if resp["status_code"] != 200:
        return None, None
    tot = 0.0
    days = {}
    for r in resp["json"].get("obs", []):
        if len(r) > 12 and r[12] != None:
            tot += r[12]
            if r[12] > 0:
                days[(r[0] + d["tz"] * 60) // 86400] = True
    return mm_to_in(tot), len(days)

# Storm mode, after the NWS lightning-safety rules: it turns on with a strike
# within 10 miles (about as far as thunder carries) and stays on until 30
# minutes pass with no strike that close. Farther strikes still show on the
# Rain timeline and LTG row, but don't take over the page.
STORM_NEAR_MI = 10.0

STORM_QUIET_SEC = 30 * 60

def storm_active(d):
    ts = d["ts"]
    obs = d["obs"]
    last_epoch = obs.get("lightning_strike_last_epoch", None)
    last_km = obs.get("lightning_strike_last_distance", None)
    if last_epoch != None and last_km != None and ts - last_epoch <= STORM_QUIET_SEC and km_to_mi(last_km) <= STORM_NEAR_MI:
        return True
    day_start, rows = day_obs_rows(d)
    for r in rows:
        if len(r) <= 15 or r[15] == None or r[15] <= 0 or r[14] == None:
            continue
        if ts - r[0] <= STORM_QUIET_SEC and km_to_mi(r[14]) <= STORM_NEAR_MI:
            return True
    return False

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
        headers = {"User-Agent": "GDN-Tempest-Deluxe (glance-led-panel)", "Accept": "application/geo+json"},
        ttl_seconds = 120,
    )

# Which NWS alerts the app shows (Chris's list, 10/2026 - see the Desktop
# "Tempest - NWS alerts to monitor.txt"): NWS map color (a few brightened to
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


# (DEMO testing only) canned alerts, picked with an "alert" input
MOCK_ALERTS = {
    "hurricane": ("Hurricane Warning", 43200, "Currituck County"),
    "ffwatch": ("Flash Flood Watch", 28800, "Currituck County"),
    "svrwatch": ("Severe Thunderstorm Watch", 14400, "Currituck County"),
    "coldwarn": ("Extreme Cold Warning", 36000, "Currituck County"),
    "ssw": ("Storm Surge Warning", 43200, "Currituck County"),
    "tornado": ("Tornado Warning", 3600, "Currituck County"),
    "svr": ("Severe Thunderstorm Warning", 2700, "Currituck County"),
    "winter": ("Winter Storm Warning", 86400, "Currituck County"),
    "flood": ("Flash Flood Warning", 10800, "Currituck County"),
    "tornadowatch": ("Tornado Watch", 21600, "Currituck County"),
    "heat": ("Heat Advisory", 18000, "Currituck County"),
    "fog": ("Dense Fog Advisory", 7200, "Currituck County"),
}

# Every active alert we show, most important first: takeover alerts before
# strip alerts (so a takeover is never hidden behind a watch or advisory),
# NWS priority within each. Items: (event, expires epoch, area). A DEMO
# "alert" input can name several mocks joined with "+".
def active_alerts(d):
    mock = demo_opt(d, "alert")
    raw = []
    if mock != "":
        for key in mock.split("+"):
            m = MOCK_ALERTS.get(key, None)
            if m != None:
                raw.append((m[0], d["ts"] + m[1], m[2]))
    elif not d["station"].get("demo"):
        st = d["station"]
        resp = fetch_nws_alerts(st["lat"], st["lon"])
        if resp["status_code"] == 200:
            for f in (resp["json"] or {}).get("features", []) or []:
                p = f.get("properties", {}) or {}
                ev = p.get("event", "") or ""
                if ev not in ALERT_STYLE:
                    continue
                ends = p.get("ends", None) or p.get("expires", None)
                raw.append((ev, iso_to_epoch(ends) if ends else None, (p.get("areaDesc", "") or "").split(";")[0]))
    # one entry per event type (the NWS can send several of the same)
    seen = {}
    out = []
    for r in sorted(raw, key = lambda r: (0 if ALERT_STYLE[r[0]][2] else 1, ALERT_ORDER.index(r[0]))):
        if r[0] in seen:
            continue
        seen[r[0]] = True
        out.append(r)
    return out

# The most important active alert: (event, expires epoch, area, how many) or None.
def top_alert(d):
    al = active_alerts(d)
    if len(al) == 0:
        return None
    return (al[0][0], al[0][1], al[0][2], len(al))

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

# ---------- station health ----------

OFFLINE_SEC = 30 * 60

LOW_BATTERY_V = 2.41

def station_health(d):
    mock = demo_opt(d, "health")
    if mock == "offline":
        return ("offline", d["ts"] - 3 * 3600 - 25 * 60)
    if mock == "battery":
        return ("battery", 2.38)
    if d["station"].get("demo"):
        return None
    now_unix = d["ctx"].now.unix if hasattr(d["ctx"], "now") else d["ts"]
    if d["ts"] > 0 and now_unix - d["ts"] > OFFLINE_SEC:
        return ("offline", d["ts"])
    day_start, rows = day_obs_rows(d)
    if len(rows) > 0 and len(rows[-1]) > 16 and rows[-1][16] != None and rows[-1][16] < LOW_BATTERY_V:
        return ("battery", rows[-1][16])
    return None

# ---------- warning edges on every other page ----------
# While a WARNING is active, pages 2-8 keep their data but get hazard stripes
# down both edges in the warning's color, so a glance at any page shows it.
EDGE_W = 2

def draw_warning_edges(c, color):
    for y in range(32):
        for x in range(EDGE_W):
            on = ((x + y) // 3) % 2 == 0
            c.pixel(x, y, color if on else "#000000")
            c.pixel(c.width - 1 - x, y, color if on else "#000000")

def warning_edges(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    a = top_alert(d)
    if a != None and ALERT_STYLE[a[0]][2]:
        draw_warning_edges(c, ALERT_STYLE[a[0]][0])


# ---------- the four 64x32 pages ----------

MINI_STARS = [(7, 3), (19, 9), (31, 2), (44, 12), (53, 5), (12, 17), (60, 19), (40, 6), (26, 14), (57, 11)]

def mini_ground(c, is_day, place):
    col = "#1f4a2a" if is_day else "#08160d"
    hi = "#2f6a3a" if is_day else "#0f2416"
    for x in range(c.width):
        c.line(x, 27, x, 31, col)
        c.pixel(x, 27, hi)
    # a small silhouette at the right edge, matching the 192's scene
    sil = "#16351f" if is_day else "#050c08"
    lit = "#FFD870"
    if place == "rural":
        c.line(59, 21, 59, 26, "#3a2a1a" if is_day else "#120c08")
        c.fill_circle(59, 20, 3, sil)
        c.fill_circle(53, 23, 2, sil)
    elif place == "city":
        for b in [(50, 18, 53), (54, 14, 57), (58, 20, 62)]:
            c.rect(b[0], b[1], b[2], 26, fill = sil)
            if not is_day:
                for wy in range(b[1] + 2, 26, 3):
                    c.pixel(b[0] + 1, wy, lit)
    elif place == "town":
        for b in [(51, 21, 55), (56, 18, 61)]:
            c.rect(b[0], b[1], b[2], 26, fill = sil)
            if not is_day:
                c.pixel(b[0] + 2, b[1] + 3, lit)
    else:
        c.rect(53, 22, 61, 26, fill = sil)
        c.fill_triangle(52, 22, 57, 18, 62, 22, sil)
        if not is_day:
            c.pixel(55, 24, lit)
            c.pixel(59, 24, lit)

def mini_sky(c, d):
    ts = d["ts"]
    rise, sset = sun_times(d)
    pal, is_day, t = sky_state(ts, rise, sset)
    cond, words_now, rain_level, far_bolt = now_weather(d)
    gray = 0.0
    if cond in ["Clouds", "Fog"]:
        gray = 0.65
    elif cond in ["Rain", "Sleet", "Snow", "Thunderstorm"]:
        gray = 0.75
    gtone = GRAY_DAY if is_day else GRAY_NIGHT
    top = mix(pal[0], gtone, gray)
    bot = mix(pal[1], gtone, gray)
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix(top, bot, min(y, 26) / 26.0)))
    if not is_day and gray < 0.5:
        for s in MINI_STARS:
            c.pixel(s[0], s[1], "#c8d0ff" if (s[0] + s[1]) % 3 else "#6f78a8")

    # the sun / moon ride a small arc on the right, behind the temperature's tenths
    cloud = "#F2F6FA" if is_day else "#3c4458"
    if gray > 0:
        cloud = "#AEB6C2" if is_day else "#2c3240"
        if gray >= 0.75:
            cloud = "#7c8492" if is_day else "#252a36"
    if gray < 0.5:
        m = moon_now(d)
        if m != None and m[0] != None:
            mx, my = arc_xy(m[0], 40, 60, 24, 18)
            draw_moon_phase(c, mx, my, 2, m[1], m[2], "#E8ECF8", hexc(mix(top, bot, my / 26.0)))
        if is_day and t != None:
            sx, sy = arc_xy(t, 40, 60, 24, 18)
            c.fill_circle(sx, sy, 4, hexc(mix(mix(top, bot, sy / 26.0), (255, 220, 120), 0.45)))
            c.fill_circle(sx, sy, 2, "#FFE070" if pal != SKY_GOLD else "#FFB040")
    puffs = []
    if cond in ["PartlyCloudy", "PartlyCloudyNight"]:
        puffs = [(50, 9, 12)]
    elif gray > 0:
        puffs = [(8, 3, 16), (31, 5, 18), (55, 3, 16)]
    for p in puffs:
        draw_puff(c, p[0], p[1], p[2], cloud)
    if cond in ["Rain", "Thunderstorm", "Sleet"]:
        n = [14, 6, 9, 14, 20, 28, 36][rain_level]
        ln = 3 if rain_level >= 4 else 2
        for i in range(n):
            x = (i * 37 + 11) % c.width
            y = 8 + (i * 7) % 16
            c.line(x, y, x - 1, y + ln, "#7fb4ff" if rain_level < 5 else "#a8ccff")
    if cond == "Snow":
        for i in range(18):
            c.pixel((i * 41 + 5) % c.width, 8 + (i * 11) % 17, "white")
    if cond == "Thunderstorm" or far_bolt:
        bc = "#FFF27A" if cond == "Thunderstorm" else "#E8D870"
        bx = 56
        c.line(bx + 2, 9, bx, 14, bc)
        c.line(bx, 14, bx + 3, 14, bc)
        c.line(bx + 3, 14, bx + 1, 19, bc)
    if cond == "Fog":
        for y in [12, 17, 22]:
            c.line(0, y, c.width - 1, y, "#9aa2ae")
    place = demo_opt(d, "place")
    if place == "":
        place = station_place(d["station"])
    mini_ground(c, is_day, place)
    return is_day, cond, words_now

MINI_ABBR = [("SEVERE THUNDERSTORM", "SVR TSTORM"), ("THUNDERSTORM", "TSTORM"), ("WINTER WEATHER", "WINTER WX"), ("STATEMENT", "STMT"), ("ADVISORY", "ADV"), ("WARNING", "WRN"), ("WATCH", "WTCH")]

def mini_abbrev(c, s, w):
    for ab in MINI_ABBR:
        if c.text_width(s, "picopixel") <= w:
            break
        s = s.replace(ab[0], ab[1])
    return s

def mini_banner(c, color, text):
    c.rect(0, 27, c.width - 1, 31, fill = color)
    s = mini_abbrev(c, text, c.width - 2)
    c.text(s, c.width // 2, 27, font = "picopixel", color = text_on(color), align = "center")

def mini_takeover(c, d, alert):
    ev, until, area, count = alert
    color, kind, _ = ALERT_STYLE[ev]
    base = hex_to_rgb(color)
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix((10, 10, 18), base, 0.28 - y * 0.006)))
    draw_warning_edges(c, color)
    words = ev.upper().split(" ")
    core = " ".join(words[:-1]) if len(words) > 1 else words[0]
    sub = words[-1] if len(words) > 1 else ""
    core = mini_abbrev(c, core, 56) if c.text_width(core, "4x5") > 56 else core
    f = fit_font(c, core, ["6x8", "5x7", "4x5", "picopixel"], 56)
    c.text(core, 32, 1, font = f, color = color, align = "center")
    c.text(sub, 32, 10, font = "5x7", color = "white", align = "center")
    u = until_text(until, d)
    c.text(u, 32, 18, font = fit_font(c, u, ["4x5", "picopixel"], 56), color = "white", align = "center")
    # the temperature stays on screen during a warning, bottom left
    tv = tdisp(d, d["temp"])
    temp_text(c, 4, 25, tv, "5x7", hero_color(d["temp"]), dec = True)
    al = active_alerts(d)
    if len(al) > 1:
        c.text("+" + str(len(al) - 1), c.width - 4, 26, font = "4x5", color = ALERT_STYLE[al[1][0]][0], align = "right")

def mini_now_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    # (DEMO testing only) force a temperature / wind for heat index / wind chill
    tf = demo_opt(d, "tempf")
    if tf != "":
        d["temp"] = float(tf)
        d["cur"] = dict(d["cur"])
        d["cur"]["wind_avg"] = float(demo_opt(d, "windmph") or "12")
    alert = top_alert(d)
    if alert != None and ALERT_STYLE[alert[0]][2]:
        mini_takeover(c, d, alert)
        return
    is_day, cond, words_now = mini_sky(c, d)
    sh = "#06102a"
    words = words_now
    if words == None:
        words = d["cur"].get("conditions", None)
        words = words.upper() if words else COND_WORDS.get(cond, "")
    if c.text_width(words, "picopixel") > 60:
        words = COND_WORDS.get(cond, words)
    stext(c, words, 1, 0, "picopixel", "white", shadow = sh)
    mini_hero(c, d, sh)
    if alert != None:
        mini_banner(c, ALERT_STYLE[alert[0]][0], alert[0].upper())
        return
    h = station_health(d)
    if h != None:
        mini_banner(c, "#5a6070" if h[0] == "offline" else "#E0A020", "STATION OFFLINE" if h[0] == "offline" else "LOW BATTERY")
        return
    # the ground strip: heat index / wind chill when one applies, otherwise
    # the next sunrise or sunset
    gs = "#06140a"
    ap = apparent(d)
    if ap != None:
        label, val = ap
        acol = "#FF9050" if label == "HEAT INDEX" else "#80D8FF"
        stext(c, "FEELS", 2, 27, "picopixel", acol, shadow = gs)
        temp_text(c, 2 + c.text_width("FEELS", "picopixel") + 2, 27, tdisp(d, val), "4x5", acol, shadow = gs, dec = True)
        return
    ev = mini_next_sun(d)
    if ev != None:
        stext(c, ev[0], 2, 27, "picopixel", "#FFD870" if ev[0] == "SUNRISE" else "#FFA050", shadow = gs)
        stext(c, ev[1], 2 + c.text_width(ev[0], "picopixel") + 3, 27, "4x5", "white", shadow = gs)

# The temperature: whole degrees in 8x12, a 2px dot, the tenths in 5x7 on the
# baseline, the degree mark after them at the top; today's actual high / low
# (station readings so far) stacked beside it.
def mini_hero(c, d, sh):
    f = tdisp(d, d["temp"])
    parts = format1(f).split(".")
    tenths = parts[1] if len(parts) > 1 else "0"
    # 3-character whole numbers (100+, or -10 and below) drop the tenths
    show_tenths = len(parts[0]) < 3
    col = hero_color(d["temp"])
    x = 2
    y = 8
    whole = parts[0]
    if whole.startswith("-"):
        # the 8x12 font's minus is a solid block upstream: draw a bar instead
        whole = whole[1:]
        c.rect(x - 1, y + 4, x + 5, y + 7, fill = sh)
        c.rect(x, y + 5, x + 4, y + 6, fill = col)
        x += 7
    c.text_stroke(whole, x, y, font = "8x12", color = col, stroke = sh, align = "left")
    fx = x + c.text_width(whole, "8x12") + 1
    if show_tenths:
        c.rect(fx - 1, y + 9, fx + 2, y + 12, fill = sh)
        c.rect(fx, y + 10, fx + 1, y + 11, fill = col)
        tx = fx + 3
        c.text_stroke(tenths, tx, y + 5, font = "5x7", color = col, stroke = sh, align = "left")
        dx = tx + c.text_width(tenths, "5x7") + 1
    else:
        dx = fx
    for o in OUTLINE8:
        draw_deg(c, dx + o[0], y + o[1], sh, False)
    draw_deg(c, dx, y, col, False)
    hx = dx + 6
    hi, lo, hi_t, lo_t = station_hilo(d, day_obs_rows(d)[1])
    if hi != None:
        # tenths on H / L only when they fit (a 100+ day or a below -9 night
        # needs the room)
        hs = tdisp(d, hi)
        ls = tdisp(d, lo)
        need = 6 + max(num_width(c, format1(hs), "4x5"), num_width(c, format1(ls), "4x5")) + 4
        dec = hx + need <= c.width - 1
        stext(c, "H", hx, 8, "4x5", "#FFD08A", shadow = sh)
        temp_text(c, hx + 6, 8, hs, "4x5", "#FFD08A", shadow = sh, dec = dec)
        stext(c, "L", hx, 15, "4x5", "#9CC8FF", shadow = sh)
        temp_text(c, hx + 6, 15, ls, "4x5", "#9CC8FF", shadow = sh, dec = dec)

def mini_pressure(d):
    cur = d["cur"]
    obs = d["obs"]
    mb = cur.get("sea_level_pressure", None)
    if mb == None and obs.get("station_pressure", None) != None:
        mb = sea_level_hpa(obs["station_pressure"], d["station"].get("height_m", 0.0), obs.get("air_temperature", 15.0) or 15.0)
    trend = cur.get("pressure_trend", "steady") or "steady"
    tc = "#40D070" if trend == "rising" else ("#FF8800" if trend == "falling" else "#9aa6c8")
    pstr = "--" if mb == None else (format1(mb) if d["metric"] else format2(hpa_to_inhg(mb)))
    return pstr, tc, trend

# 5x5 arrow: up / down / right (steady)
def mini_trend_arrow(c, x, y, trend, col):
    if trend == "rising":
        c.fill_triangle(x, y + 2, x + 2, y, x + 4, y + 2, col)
        c.rect(x + 2, y + 2, x + 2, y + 4, fill = col)
    elif trend == "falling":
        c.rect(x + 2, y, x + 2, y + 2, fill = col)
        c.fill_triangle(x, y + 2, x + 2, y + 4, x + 4, y + 2, col)
    else:
        c.rect(x, y + 2, x + 2, y + 2, fill = col)
        c.fill_triangle(x + 2, y, x + 4, y + 2, x + 2, y + 4, col)

def mini_air_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    cur = d["cur"]
    obs = d["obs"]
    lab = "#7f8fb8"
    R = c.width - 4
    rh = obs.get("relative_humidity", None)
    if rh == None:
        rh = cur.get("relative_humidity", 0)
    dp = c_to_f(cur.get("dew_point", 0.0))
    dwords, dcol = dew_words(dp)
    u = obs.get("uv", None)
    if u == None:
        u = cur.get("uv", 0.0)
    uwords, ucol = uv_words(u)
    pstr, tc, trend = mini_pressure(d)
    rows = [("HUMIDITY", humidity_word(rh), "#7fb4ff"), ("DEW PT", dwords, dcol), ("BARO", trend.upper(), tc), ("UV", uwords, ucol)]
    for k in range(4):
        y = 1 + k * 8
        c.text(rows[k][0], 3, y, font = "picopixel", color = lab, align = "left")
    # values, right-aligned in 5x7
    hs = str(round_int(rh)) + "%"
    c.text(hs, R, 1, font = "5x7", color = "white", align = "right")
    ds = format1(tdisp(d, dp))
    dw = num_width(c, ds, "5x7") + 4
    temp_text(c, R - dw + 1, 9, tdisp(d, dp), "5x7", tcol(dp), dec = True)
    pf = "5x7"
    pw = num_width(c, pstr, pf)
    num_text(c, R - 6 - pw + 1, 17 if pf == "5x7" else 18, pstr, pf, "white")
    mini_trend_arrow(c, R - 4, 18, trend, tc)
    c.text(str(round_int(u)), R, 25, font = "5x7", color = ucol, align = "right")
    for y in [8, 16, 24]:
        c.line(3, y, c.width - 4, y, "#141c40")

def mini_wind_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    day_start, rows = day_obs_rows(d)
    # today's top gust (the device history), for HI
    best = 0.0
    for r in rows:
        if r[3] != None and r[3] > best:
            best = r[3]
    speed = d["cur"].get("wind_avg", 0.0) or 0.0
    if demo_opt(d, "windmph") != "":
        speed = float(demo_opt(d, "windmph"))
        d["cur"] = dict(d["cur"])
        d["cur"]["wind_gust"] = speed * 1.5
    deg = d["cur"].get("wind_direction", 0) or 0
    if demo_opt(d, "winddeg") != "":
        sh = float(demo_opt(d, "winddeg")) - deg
        deg = float(demo_opt(d, "winddeg"))
        rows = [[r[0], r[1], r[2], r[3], (r[4] + sh) % 360 if r[4] != None else None] + r[5:] for r in rows]
    gust = d["cur"].get("wind_gust", 0.0) or 0.0
    col = "white" if speed == 0 else safe_col(wind_color(speed))
    wind_dial(c, d, rows, 13, 16, 12, deg, speed, col, "4x5")

    # 2px gaps everywhere (1px runs together on a real LED panel), and a clear
    # row between lines
    x0 = 28
    s = str(round_int(spd(d, speed)))
    # 3-digit speeds (hurricanes, km/h gales) step down a size to fit
    sf = "8x12" if len(s) < 3 else "6x8"
    c.text(s, x0, 0 if sf == "8x12" else 2, font = sf, color = col, align = "left")
    bx = x0 + c.text_width(s, sf) + 2
    u = spd_unit(d)
    if bx + c.text_width(u, "picopixel") > c.width - 3:
        u = u.replace("KM/H", "KPH")     # 64 px can't fit KM/H after 2 digits
    c.text(u, bx, 5, font = "picopixel", color = "#8fa0cc", align = "left")
    # the Beaufort term, one word a line (GENTLE / BREEZE)
    bw = beaufort(speed) if round_int(speed) > 0 else "CALM"
    parts = bw.split(" ")
    room = c.width - 3 - x0
    if len(parts) == 1 and c.text_width(parts[0], "picopixel") > room:
        # one long word (HURRICANE): split it over the two lines
        h = (len(parts[0]) + 1) // 2
        parts = [parts[0][:h], parts[0][h:]]
    for k in range(min(len(parts), 2)):
        c.text(parts[k], x0, 13 + k * 6, font = "picopixel", color = col, align = "left")
    # gust and today's high gust on one row: G 19  HI 21
    hi_g = max(mps_to_mph(best), gust)
    gs = str(round_int(spd(d, gust)))
    hs = str(round_int(spd(d, hi_g)))
    # normal: G 19  HI 21; 3-digit gusts tighten to G150 H150 in small digits
    tight = x0 + 3 + 2 + c.text_width(gs, "4x5") + 2 + 7 + 2 + c.text_width(hs, "4x5") - 1 > c.width - 3
    rowsg = [("G", gust, gs), ("H" if tight else "HI", hi_g, hs)]
    vf = "picopixel" if tight else "4x5"
    gap = 1 if tight else 2
    x = x0
    for row in rowsg:
        c.text(row[0], x, 26, font = "picopixel", color = "#7f8fb8", align = "left")
        x += c.text_width(row[0], "picopixel") + gap
        c.text(row[2], x, 26, font = vf, color = safe_col(wind_color(row[1])) if row[1] > 0 else "white", align = "left")
        x += c.text_width(row[2], vf) + 2

# The Rain page's backdrop: the usual night-blue, tinted bluer once it has
# rained today, with faint slanted rain streaks while it's raining (rain in
# the last hour).
def rain_bg(c, d):
    obs = d["obs"]
    today = obs.get("precip_accum_local_day", 0.0) or 0.0
    hr = obs.get("precip_accum_last_1hr", 0.0) or 0.0
    if today <= 0:
        draw_bg(c)
        return
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix((12, 26, 66), (3, 7, 24), y / 31.0)))

# Glass on the gauge: a dim highlight down the tube's left side, brighter
# where it's in the water.
def gauge_glass(c, x, x1, ty0, ty1, lvl, raining):
    c.line(x, ty0 + 1, x, ty1 - 1, "#1c2c60")
    if lvl < ty1:
        c.line(x, lvl + 1, x, ty1 - 1, "#a8d4ff")
    if raining:
        # drops falling into the tube, above the water
        for k in range(6):
            dx = x + 1 + (k * 3) % max(x1 - x - 1, 1)
            dy = ty0 + 2 + k * 4
            if dy + 2 < lvl - 1:
                c.line(dx, dy, dx, dy + 1, "#5ab0ff")

def mini_rain_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    if demo_opt(d, "storm") != "off" and storm_active(d):
        mini_storm(c, d)
        return
    rain_bg(c, d)
    obs = d["obs"]
    today_in = mm_to_in(obs.get("precip_accum_local_day", 0.0) or 0.0)
    tx0 = 3
    tx1 = 9
    ty0 = 2
    ty1 = 29
    cap = 50.0 / 25.4 if d["metric"] else 2.0
    c.rect(tx0, ty0, tx1, ty1, fill = "#0c1638")
    inner = ty1 - 1 - ty0
    lvl = ty1 - max(1, round_int(clamp(today_in / cap, 0.0, 1.0) * inner)) if today_in > 0 else ty1
    for y in range(lvl, ty1):
        c.line(tx0 + 1, y, tx1 - 1, y, hexc(mix((90, 170, 255), (20, 80, 220), (y - lvl) / float(max(ty1 - 1 - lvl, 1)))))
    if today_in > 0:
        c.line(tx0 + 1, lvl, tx1 - 1, lvl, "#ffffff" if today_in > cap else "#c8e4ff")
    gauge_glass(c, tx0 + 1, tx1 - 1, ty0, ty1, lvl, (obs.get("precip_accum_last_1hr", 0.0) or 0.0) > 0)
    c.line(tx0, ty0, tx0, ty1, "#5a6a9a")
    c.line(tx1, ty0, tx1, ty1, "#5a6a9a")
    c.line(tx0, ty1, tx1, ty1, "#5a6a9a")
    for k in range(1, 4):
        ty = ty1 - round_int(k / 4.0 * inner)
        c.line(tx1 - (3 if k == 2 else 1), ty, tx1 - 1, ty, "#8090c0")

    x0 = 13
    s = rain_str(d, today_in)
    if d["metric"] and today_in * 25.4 >= 99.95:
        s = str(round_int(today_in * 25.4))
    elif not d["metric"] and today_in >= 0.9995:
        s = format2(today_in)
    sw = num_text(c, x0, 2, s, "8x12", "white" if today_in == 0 else "#7fb4ff")
    c.text(rain_unit(d), x0 + sw + 2, 2, font = "picopixel", color = "#7f8fb8", align = "left")
    mins = obs.get("precip_minutes_local_day", None)
    if mins != None and mins > 0:
        c.text(format_minutes(mins), x0, 15, font = "picopixel", color = "#3399FF", align = "left")
    else:
        c.text("TODAY", x0, 15, font = "picopixel", color = "#7f8fb8", align = "left")

    hr = mm_to_in(obs.get("precip_accum_last_1hr", 0.0) or 0.0)
    rowsd = [("LAST HR", rain_str(d, hr), "#7fb4ff" if hr > 0 else "white")]
    last_epoch = obs.get("lightning_strike_last_epoch", None)
    dist_km = obs.get("lightning_strike_last_distance", None)
    ago = (d["ts"] - last_epoch) // 60 if last_epoch != None else None
    if ago != None and ago <= 180 and dist_km != None:
        rowsd = [("LTG", dist_str(d, km_to_mi(dist_km)) + dist_unit(d), safe_col(strike_distance_color(km_to_mi(dist_km))))]
    m_in, wet = month_rain(d)
    if m_in != None:
        m_s = rain_str(d, m_in)
        if not d["metric"]:
            m_s = "0" if round_int(m_in * 100) == 0 else format2(m_in)
            if m_s.startswith("0."):
                m_s = m_s[1:]
        rowsd.append(("MONTH", m_s, "#7fb4ff" if m_in > 0 else "white"))
    for k in range(len(rowsd)):
        lab, val, col = rowsd[k]
        y = 21 + k * 6
        c.text(lab, x0, y, font = "picopixel", color = "#7f8fb8", align = "left")
        c.text(val, c.width - 4, y, font = "4x5", color = col, align = "right")

def mini_storm(c, d):
    draw_bg(c)
    obs = d["obs"]
    last_epoch = obs.get("lightning_strike_last_epoch", None)
    dist_km = obs.get("lightning_strike_last_distance", None)
    mi = km_to_mi(dist_km or 0.0)
    col = safe_col(strike_distance_color(mi))
    # bolt
    bc = "#FFE040"
    c.fill_triangle(9, 2, 3, 15, 8, 15, bc)
    c.fill_triangle(7, 13, 12, 13, 4, 29, bc)
    c.text("LIGHTNING", 16, 1, font = "4x5", color = bc, align = "left")
    s = dist_str(d, mi)
    sw = c.text_width(s, "8x12")
    c.text(s, 16, 9, font = "8x12", color = col, align = "left")
    c.text(dist_unit(d), 16 + sw + 2, 9, font = "4x5", color = "#c8c8d0", align = "left")
    c.text("AWAY", 16 + sw + 2, 16, font = "picopixel", color = "#c8c8d0", align = "left")
    if last_epoch != None:
        ago = max(0, (d["ts"] - last_epoch) // 60)
        c.text(("JUST NOW" if ago < 1 else str(ago) + " MIN AGO"), 16, 23, font = "4x5", color = "white", align = "left")

def now(c, ctx):
    bc = buffered(c)
    mini_now_page(bc, ctx)
    bc.flush()

def air(c, ctx):
    bc = buffered(c)
    mini_air_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def wind(c, ctx):
    bc = buffered(c)
    mini_wind_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def rain(c, ctx):
    bc = buffered(c)
    mini_rain_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

# "7:04P" in the station's time zone
def mini_hm(epoch, d):
    local = epoch + d["tz"] * 60
    h = (local % 86400) // 3600
    m = (local % 3600) // 60
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + pad_int(m, 2) + ("A" if h < 12 else "P")

# The next sunrise or sunset: today's, or tomorrow's sunrise after dark.
def mini_next_sun(d):
    rise, sset = sun_times(d)
    if rise == None:
        return None
    ts = d["ts"]
    if ts < rise:
        return ("SUNRISE", mini_hm(rise, d))
    if ts < sset:
        return ("SUNSET", mini_hm(sset, d))
    daily = d["daily"]
    if len(daily) > 1 and daily[1].get("sunrise", None) != None:
        return ("SUNRISE", mini_hm(daily[1]["sunrise"], d))
    return ("SUNRISE", mini_hm(rise + 86400, d))


DIAL_SPREAD_MIN = 10

# A compass dial (after the Tempest app's wind gauge): a dark face with a warm
# ring, dim dots at the 16 points, ticks at N / E / S / W (north bright), an
# arc on the ring over the directions of the last DIAL_SPREAD_MIN minutes (in
# the wind's color), a red pointer on the ring at the side the wind is coming
# FROM, and the direction's letters in the middle.
def wind_dial(c, d, rows, cx, cy, R, deg, speed, col, font):
    c.fill_circle(cx, cy, R, "#0a1030")
    for k in range(120):
        a = math.radians(k * 3)
        # orange-red at the top fading to amber at the bottom
        t = (1.0 - math.cos(a)) / 2.0
        c.pixel(round_int(cx + R * math.sin(a)), round_int(cy - R * math.cos(a)), hexc(mix((232, 84, 40), (200, 150, 30), t)))
    for k in range(16):
        if k % 4 == 0:
            continue
        a = math.radians(k * 22.5)
        c.pixel(round_int(cx + (R - 3) * math.sin(a)), round_int(cy - (R - 3) * math.cos(a)), "#3a4570")
    c.line(cx, cy - R + 2, cx, cy - R + 4, "white")
    c.line(cx + R - 4, cy, cx + R - 2, cy, "#8090b8")
    c.line(cx, cy + R - 4, cx, cy + R - 2, "#8090b8")
    c.line(cx - R + 2, cy, cx - R + 4, cy, "#8090b8")
    if round_int(speed) == 0:
        c.fill_circle(cx, cy, 1, "#8fa0cc")
        return
    # the arc: how far the direction has swung in the last few minutes
    lo = 0.0
    hi = 0.0
    since = d["ts"] - DIAL_SPREAD_MIN * 60
    for r in rows:
        if r[0] < since or r[2] == None or r[4] == None or r[2] <= 0:
            continue
        off = ((r[4] - deg + 540) % 360) - 180
        lo = min(lo, off)
        hi = max(hi, off)
    lo = max(lo, -90.0) - 6
    hi = min(hi, 90.0) + 6
    a = lo
    for _ in range(64):
        if a > hi:
            break
        ar = math.radians(deg + a)
        for rr in [R, R - 1]:
            c.pixel(round_int(cx + rr * math.sin(ar)), round_int(cy - rr * math.cos(ar)), col)
        a += 3
    # the pointer: base on the ring, tip toward the middle
    fx = math.sin(math.radians(deg))
    fy = -math.cos(math.radians(deg))
    hw = 2.5 if R >= 14 else 2.0
    bx = cx + fx * (R - 1.5)
    by = cy + fy * (R - 1.5)
    tx = cx + fx * (R - 5.5)
    ty = cy + fy * (R - 5.5)
    fill_triangle(c, tx, ty, bx - fy * hw, by + fx * hw, bx + fy * hw, by - fx * hw, "#E8302A")
    dn = CARDINAL_NAMES[compass_index(deg)]
    c.text(dn, cx + 1, cy - (3 if font == "5x7" else 2), font = font, color = "#FF9A2E", align = "center")
