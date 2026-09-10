# Tempest Deluxe (128x32)
#
# Same data as the sibling apps/tempest-weather (live conditions from the
# user's own WeatherFlow Tempest station, same free personal-access-token
# auth, same verified API gotchas - see that app's own header comment for
# the full list: station_pressure/wind_gust/lightning_strike_last_distance
# ignoring their units_* params, precip_accum_local_yesterday's stale-total
# issue, the device-obs positional array layout). This app is the visual
# reskin: WeatherSTAR 4000's actual look (navy body, orange->purple title
# bar - colors lifted from tempest-dashboard's own CSS custom properties:
# --navy-deep #0a1250, --navy-panel #1a2d8f, --orange #ff7a00, --purple
# #6a1b9a) instead of tempest-weather's amber/black day-night header, plus
# real graphics (compass rose, linear/vertical gauges, a radar-ping icon)
# on the pages that were plain label:value text rows there.

CARDINAL_NAMES = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
WEEKDAY_NAMES = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

SUN_BITMAP = [
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
]

CLOUD_BITMAP = [
    [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
]

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

# ---------- small input helper ----------
# An unset/cleared input can come back as None even with a fallback given to
# ctx.inputs.get(), so coerce before using it (see apps/local-aqi, apps/stocks, etc).

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return v

def _n(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return float(v)

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

def sea_level_pressure(station_inhg, elevation_ft, temp_c):
    elevation_m = elevation_ft * 0.3048
    ratio = 1.0 - (0.0065 * elevation_m) / (temp_c + 0.0065 * elevation_m + 273.15)
    return station_inhg / math.pow(ratio, 5.257)

def date_from_iso(iso_time):
    return (int(iso_time[0:4]), int(iso_time[5:7]), int(iso_time[8:10]))

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

# Same clock, single-letter suffix - for the almanac page's compact
# rise/set rows. USNO's "HH:MM" (always zero-padded, 24-hour, already in
# local time since the almanac fetch passes a tz param) parses by fixed
# slice rather than split() since the width never varies.
def hhmm24_to_12h_compact(time_str):
    if time_str == None:
        return "N/A"
    hour24 = int(time_str[0:2])
    minute = int(time_str[3:5])
    ampm = "A" if hour24 < 12 else "P"
    hour12 = hour24 % 12
    if hour12 == 0:
        hour12 = 12
    return str(hour12) + ":" + pad_int(minute, 2) + ampm

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

def tempest_icon_to_cond(icon):
    if icon == None:
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

def nws_to_cond(short_forecast):
    s = short_forecast.lower()
    if "thunderstorm" in s:
        return "Thunderstorm"
    elif "snow" in s or "flurries" in s:
        return "Snow"
    elif "sleet" in s or "freezing" in s or "ice" in s:
        return "Sleet"
    elif "rain" in s or "shower" in s or "drizzle" in s:
        return "Rain"
    elif "fog" in s or "haze" in s:
        return "Fog"
    elif "wind" in s:
        return "Windy"
    elif "sunny" in s or "clear" in s:
        return "Clear"
    elif "partly" in s or "mostly sunny" in s or "mostly clear" in s:
        return "PartlyCloudy"
    elif "cloud" in s or "overcast" in s:
        return "Clouds"
    else:
        return "Clouds"

def near_term_label(name):
    # Full spellings fit again now that the forecast page is 3 columns
    # (42px each) instead of 5 (25px each) - the old "AFT"/"TNGT"/"OVERNT"
    # abbreviations were forced by that tighter layout.
    n = name.lower()
    if "afternoon" in n:
        return "THIS PM"
    elif "tonight" in n:
        return "TONIGHT"
    elif "overnight" in n:
        return "OVERNIGHT"
    elif "today" in n:
        return "TODAY"
    else:
        return None

# ---------- network ----------

def fetch_stations(token):
    return http.get(
        "https://swd.weatherflow.com/swd/rest/stations",
        params = {"token": token},
        ttl_seconds = 3600,
    )

def fetch_observation(token, station_id):
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
    return http.get(
        "https://swd.weatherflow.com/swd/rest/better_forecast",
        params = {
            "station_id": str(station_id),
            "token": token,
            "units_wind": "mph",
            "units_pressure": "inhg",
        },
        ttl_seconds = 300,
    )

def fetch_nws_points(lat, lon):
    return http.get(
        "https://api.weather.gov/points/" + format4(lat) + "," + format4(lon),
        headers = {"User-Agent": "GDN-Tempest-Deluxe (glance-led-panel)", "Accept": "application/geo+json"},
        ttl_seconds = 2592000,
    )

def fetch_nws_forecast(url):
    return http.get(
        url,
        headers = {"User-Agent": "GDN-Tempest-Deluxe (glance-led-panel)", "Accept": "application/geo+json"},
        ttl_seconds = 3600,
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

    resp = fetch_stations(token)
    if resp["status_code"] != 200:
        return None, "auth failed"

    stations = resp["json"].get("stations", [])
    if len(stations) == 0:
        return None, "no stations"

    chosen = stations[0]

    devices = chosen.get("devices", [])
    device_id = None
    for d in devices:
        if d.get("device_type", None) == "ST":
            device_id = d.get("device_id", None)
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

STAR_ORANGE = (255, 122, 0)
STAR_PURPLE = (106, 27, 154)
STAR_DARK = (36, 21, 72)
BODY_TOP = (26, 45, 143)
BODY_BOTTOM = (10, 18, 80)
PANEL_BG = "#14142c"
GAUGE_BG = "#1a2f5c"

HEADER_STOPS = [(0.00, STAR_ORANGE), (0.32, STAR_ORANGE), (0.62, STAR_PURPLE), (0.88, STAR_DARK), (1.0, STAR_DARK)]

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

def draw_body_bg(c):
    # Per-row vertical gradient - only 32 draws, cheap enough for a true
    # smooth fade rather than a banded approximation.
    for y in range(32):
        t = y / 31.0
        r = round_int(lerp(BODY_TOP[0], BODY_BOTTOM[0], t))
        g = round_int(lerp(BODY_TOP[1], BODY_BOTTOM[1], t))
        b = round_int(lerp(BODY_TOP[2], BODY_BOTTOM[2], t))
        c.rect(0, y, 127, y, fill = rgb_to_hex(r, g, b))

def draw_header(c, name, time_str):
    for x in range(128):
        t = x / 127.0
        r, g, b = gradient_at(HEADER_STOPS, t)
        c.rect(x, 0, x, 7, fill = rgb_to_hex(r, g, b))
    name_font = fit_font(c, name.upper(), ["4x5", "picopixel"], 84)
    c.text(name.upper(), 2, 1, font = name_font, color = "white", align = "left")
    c.text(time_str.upper(), 126, 1, font = "4x5", color = "white", align = "right")
    c.line(0, 7, 127, 7, PANEL_BG)

def draw_header_centered(c, title):
    for x in range(128):
        t = x / 127.0
        r, g, b = gradient_at(HEADER_STOPS, t)
        c.rect(x, 0, x, 7, fill = rgb_to_hex(r, g, b))
    font = fit_font(c, title.upper(), ["4x5", "picopixel"], 124)
    c.text(title.upper(), 64, 1, font = font, color = "white", align = "center")
    c.line(0, 7, 127, 7, PANEL_BG)

# A 1px light line marking a clean page break while the kiosk scrolls
# horizontally between pages - same convention apps/mlb-playoff-picture
# uses. Only the very first page (conditions) draws a left edge too,
# otherwise a page's right border and the next page's left border would
# double up into a 2px-thick seam at every transition.
def draw_page_edges(c, left = True):
    if left:
        c.rect(0, 0, 0, c.height - 1, fill = "gray")
    c.rect(c.width - 1, 0, c.width - 1, c.height - 1, fill = "gray")

def draw_error(c, msg):
    draw_body_bg(c)
    c.text(msg.upper(), 4, 12, font = "5x7", color = "#FF4444", align = "left")

# ---------- graphic gauges (the new visual language for this app) ----------

def draw_linear_gauge(c, x0, x1, y, h, lo, hi, value, color, tick_values = None):
    # A horizontal fill-bar with a marker tick at the current value's
    # position - like a thermometer, not a cumulative bargraph (some of
    # these scales, e.g. pressure, aren't naturally "0 up to here").
    # tick_values (actual values, not fracs) draw small reference marks in
    # the 1px gap just above the bar.
    c.rect(x0, y, x1, y + h, fill = GAUGE_BG)
    frac = clamp((value - lo) / (hi - lo), 0.0, 1.0) if hi > lo else 0.0
    fill_x = x0 + round_int(frac * (x1 - x0))
    if fill_x > x0:
        c.rect(x0, y, fill_x, y + h, fill = color)
    c.line(fill_x, y, fill_x, y + h, "white")

    if tick_values != None:
        for tv in tick_values:
            tf = clamp((tv - lo) / (hi - lo), 0.0, 1.0) if hi > lo else 0.0
            tx = x0 + round_int(tf * (x1 - x0))
            c.line(tx, y - 1, tx, y, "white")

def draw_diamond(c, cx, cy, r, color):
    c.fill_triangle(cx - r, cy, cx, cy - r, cx + r, cy, color)
    c.fill_triangle(cx - r, cy, cx, cy + r, cx + r, cy, color)

# A small downward-pointing arrow, tip at (cx, tip_y) - used to point at a
# spot on a horizontal bar from above it, e.g. the thermometer's marker.
def draw_down_pointer(c, cx, tip_y, half_w, height, color):
    c.fill_triangle(cx, tip_y, cx - half_w, tip_y - height, cx + half_w, tip_y - height, color)

# A sideways thermometer, fixed 0-100F end to end - unlike
# draw_linear_gauge (one flat color, filled up to the value), every column
# here is painted with temp_color() for the value that column represents,
# so the whole 0-100 scale's color coding is visible at once rather than
# just the color at today's reading. A black-ringed white diamond marks
# where the actual reading falls along that scale.
def draw_thermometer_bar(c, x0, x1, y, h, value):
    lo = 0.0
    hi = 100.0
    frac = clamp((value - lo) / (hi - lo), 0.0, 1.0)
    fill_x = x0 + round_int(frac * (x1 - x0))

    # Color coding only fills up to the actual reading now - the rest of
    # the 0-100 track stays GAUGE_BG, same "unfilled" look every other
    # gauge in this app uses, instead of always painting the whole scale
    # regardless of where today's reading actually falls.
    for px in range(x0, x1 + 1):
        if px <= fill_x:
            t = (px - x0) / float(x1 - x0)
            v = lo + t * (hi - lo)
            c.line(px, y, px, y + h - 1, temp_color(v))
        else:
            c.line(px, y, px, y + h - 1, GAUGE_BG)
    c.rect(x0, y, x1, y + h - 1, outline = "white")

    # Marker is a small arrow pointing down at the bar from above, tip
    # touching its top edge - a black outline arrow behind a smaller white
    # one, same idea as the diamond it replaces (which straddled the bar)
    # but reads more clearly as "pointing at" a spot than "sitting on" one.
    draw_down_pointer(c, fill_x, y + 1, 3, 3, "black")
    draw_down_pointer(c, fill_x, y, 2, 2, "white")

def draw_vertical_gauge(c, x0, x1, y0, y1, lo, hi, value, color):
    c.rect(x0, y0, x1, y1, fill = GAUGE_BG)
    frac = clamp((value - lo) / (hi - lo), 0.0, 1.0) if hi > lo else 0.0
    fill_h = round_int(frac * (y1 - y0))
    if fill_h > 0:
        c.rect(x0, y1 - fill_h, x1, y1, fill = color)

def draw_compass(c, cx, cy, r, deg, needle_color, show_needle = True):
    c.fill_circle(cx, cy, r, PANEL_BG)
    c.fill_circle(cx, cy, r - 1, GAUGE_BG)
    for tick_deg in [0, 90, 180, 270]:
        rad = math.radians(tick_deg)
        x1 = cx + (r - 3) * math.sin(rad)
        y1 = cy - (r - 3) * math.cos(rad)
        x2 = cx + (r - 1) * math.sin(rad)
        y2 = cy - (r - 1) * math.cos(rad)
        c.line(round_int(x1), round_int(y1), round_int(x2), round_int(y2), "white")

    # A calm reading has no real direction to point at - skip the needle
    # (and its center hub) rather than show a stale/meaningless heading.
    if not show_needle:
        return
    rad = math.radians(deg)
    nx = cx + (r - 2) * math.sin(rad)
    ny = cy - (r - 2) * math.cos(rad)
    c.line(cx, cy, round_int(nx), round_int(ny), needle_color)
    c.fill_circle(cx, cy, 1, needle_color)

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

# A flag on a pole, gauging wind speed the way a real flag does: hangs
# limp and drooping when calm, swings up to fully horizontal once
# extended. The flag is a triangle pinned to the pole along its left edge
# (flag_top_y to flag_top_y + flag_h) with a tip that pivots around that
# edge's midpoint - straight down (mostly gravity, barely any reach) at
# frac=0, straight out to reach px (a taut pennant) at frac=1. frac is
# 0..1 - the wind page maps mph to it linearly, capped at 20mph (real
# flags read as "fully extended" by Beaufort force 5, ~19-24mph, so
# there's no visual gain in reserving headroom above that).
#
# droop_max is independent of reach (not derived from it) so a longer/
# taller flag doesn't also droop deeper at calm and risk running off the
# bottom of a 32px-tall canvas - it only ever hangs down droop_max px
# below the pin's midpoint, regardless of how far it reaches when windy.
def draw_wind_flag(c, pole_x, pole_top_y, pole_bottom_y, flag_top_y, flag_h, reach, droop_max, frac, color):
    c.pixel(pole_x, pole_top_y, "white")
    c.line(pole_x, pole_top_y, pole_x, pole_bottom_y, "#999999")

    pin_bottom_y = flag_top_y + flag_h - 1
    mid_y = flag_top_y + (flag_h - 1) / 2.0

    tip_dx = lerp(2.0, reach, frac)
    tip_dy = lerp(droop_max, 0.0, frac)
    tip_x = pole_x + tip_dx
    tip_y = mid_y + tip_dy

    fill_triangle(c, pole_x, flag_top_y, pole_x, pin_bottom_y, round_int(tip_x), round_int(tip_y), color)

# A round dial gauge (speedometer-style, 240-degree sweep from lower-left
# through top to lower-right) - shared by the current page's temp/humidity/
# pressure gauges. A colored progress ring (short radial ticks from the
# start of the sweep to the current reading) plus a needle at the exact
# value; tick_fracs are optional fixed reference marks (e.g. a real
# barometer's Stormy/Rain/Change/Fair/Very Dry points) drawn in plain white
# regardless of ring_color, so they read as scale markings, not data.
GAUGE_ANGLE_START = -120.0
GAUGE_ANGLE_END = 120.0

def gauge_angle(frac):
    return GAUGE_ANGLE_START + (GAUGE_ANGLE_END - GAUGE_ANGLE_START) * clamp(frac, 0.0, 1.0)

def draw_dial(c, cx, cy, r, frac, ring_color, tick_fracs, fill_ring = True, needle_color = "white"):
    c.fill_circle(cx, cy, r, PANEL_BG)
    c.fill_circle(cx, cy, r - 2, GAUGE_BG)

    end_ang = gauge_angle(frac)

    # The barometer dial skips this progress-ring fill entirely (fill_ring =
    # False) - a real barometer face doesn't light up as the needle moves,
    # so instead its needle itself is colored per the tick-mark zone it's
    # pointing into (see barometer_needle_color).
    #
    # This used to draw a radial line every 6 degrees, but at this radius
    # the gap between adjacent lines' outer ends is wider than the lines
    # are thick, leaving a ring of unlit GAUGE_BG speckles punched through
    # the color. Testing every pixel in the ring's bounding box against its
    # actual distance/angle from center fills the band solidly with no
    # gaps, regardless of angle step.
    if fill_ring:
        r_in = r - 3
        r_out = r - 1
        for dy in range(-r_out, r_out + 1):
            for dx in range(-r_out, r_out + 1):
                dist = math.sqrt(dx * dx + dy * dy)
                if dist < r_in - 0.5 or dist > r_out + 0.5:
                    continue
                ang = math.degrees(math.atan2(dx, -dy))
                if ang >= GAUGE_ANGLE_START and ang <= end_ang:
                    c.pixel(cx + dx, cy + dy, ring_color)

    if tick_fracs != None:
        for tf in tick_fracs:
            rad = math.radians(gauge_angle(tf))
            x1 = cx + (r - 3) * math.sin(rad)
            y1 = cy - (r - 3) * math.cos(rad)
            x2 = cx + r * math.sin(rad)
            y2 = cy - r * math.cos(rad)
            c.line(round_int(x1), round_int(y1), round_int(x2), round_int(y2), "white")

    rad = math.radians(end_ang)
    nx = cx + (r - 2) * math.sin(rad)
    ny = cy - (r - 2) * math.cos(rad)
    c.line(cx, cy, round_int(nx), round_int(ny), needle_color)
    c.fill_circle(cx, cy, 1, needle_color)

# Real household aneroid barometers mark these 5 points (Stormy/Rain/Change/
# Fair/Very Dry) at roughly 28.0/28.6/29.5/30.1/30.7 inHg - not a color scale,
# the actual printed gradations - so the pressure gauge uses these as its
# tick_fracs instead of the temp/humidity gauges' plain min/mid/max.
BAROMETER_LOW_IN = 28.0
BAROMETER_HIGH_IN = 30.7
BAROMETER_TICKS = [0.0, 0.222, 0.556, 0.778, 1.0]

# Which of the 4 bands between those tick marks the needle currently sits
# in - reusing pressure_color's actual palette (red -> orange -> amber ->
# green) so "stormy" still reads as red and "fair/very dry" still reads as
# green, just keyed to the tick fracs instead of raw inHg breakpoints.
def barometer_needle_color(frac):
    if frac < BAROMETER_TICKS[1]:
        return "#FF0000"
    elif frac < BAROMETER_TICKS[2]:
        return "#FF8800"
    elif frac < BAROMETER_TICKS[3]:
        return "amber"
    else:
        return "#33CC66"

def draw_gauge_column(c, col_left, col_width, label, value_str, frac, color, tick_fracs, trend = None, fill_ring = True, needle_color = "white"):
    r = 10
    cy = 20
    cx = col_left + r
    draw_dial(c, cx, cy, r, frac, color, tick_fracs, fill_ring = fill_ring, needle_color = needle_color)

    text_x = cx + r + 1
    avail_w = col_left + col_width - text_x
    c.text(label.upper(), text_x, 11, font = "picopixel", color = "white", align = "left")
    vfont = fit_font(c, value_str, ["4x5", "picopixel"], avail_w)
    value_upper = value_str.upper()
    c.text(value_upper, text_x, 18, font = vfont, color = color, align = "left")

    if trend != None:
        trend_letter = "R" if trend == "rising" else ("F" if trend == "falling" else "S")
        value_w = c.text_width(value_upper, vfont)
        trend_cx = text_x + value_w // 2
        c.text(trend_letter, trend_cx, 25, font = "4x5", color = "white", align = "center")

def draw_radar_ping(c, cx, cy, mi, color):
    # 3 concentric rings; the dot shrinks (and gets lost near the center)
    # as a strike gets farther away, grows toward filling the whole radar
    # as it gets closer - mi == None (no recent strike) reads as an empty
    # radar with just a center speck.
    c.fill_circle(cx, cy, 9, PANEL_BG)
    c.fill_circle(cx, cy, 6, GAUGE_BG)
    c.fill_circle(cx, cy, 3, "#2a3d6c")
    dot_r = clamp(4 - int(mi / 6.0), 1, 4) if mi != None else 1
    c.fill_circle(cx, cy, dot_r, color)

# Tempest only measures strike DISTANCE, not direction - so instead of a
# radar-style ping (which implies a direction it doesn't have), a small
# tree sits fixed at the bottom of the band and a bolt falls toward it
# from above. mi == None (no recent strike) draws the tree alone. A close
# strike zaps the treetop directly (bolt tip at the apex, frac == 0). As a
# strike gets farther away it's drawn hitting open ground off to the side
# of the tree instead - drifting right and its tip sliding down from the
# apex toward the trunk's own base height - rather than just shrinking in
# place, which used to read as a disconnected icon floating near the
# header at long range. Width/height still taper with distance too, but
# only mildly (MIN_W/MIN_H stay well above the point where the zigzag
# stops reading as a bolt), so the shape stays legible at every distance.
TREE_CANOPY_COLOR = "#2E7D32"
TREE_TRUNK_COLOR = "#5D4037"
TREE_BASE_DY = 11

def draw_tree(c, x0, y0):
    apex_x = x0 + 7
    for i in range(7):
        c.line(apex_x - i, y0 + i, apex_x + i, y0 + i, TREE_CANOPY_COLOR)
    c.rect(apex_x - 1, y0 + 7, apex_x + 1, y0 + TREE_BASE_DY, fill = TREE_TRUNK_COLOR)

def draw_variable_bolt(c, cx, y, w, h, color):
    mid = h // 2
    c.line(cx + w, y, cx - w, y + mid, color)
    c.line(cx - w, y + mid, cx + w, y + mid, color)
    c.line(cx + w, y + mid, cx, y + h, color)

STRIKE_ICON_MAX_MI = 20.0
STRIKE_BOLT_MAX_W = 4
STRIKE_BOLT_MIN_W = 3
STRIKE_BOLT_MAX_H = 12
STRIKE_BOLT_MIN_H = 8
STRIKE_DRIFT_MAX = 24

def draw_tree_strike(c, x0, y0, mi, color):
    draw_tree(c, x0, y0)
    if mi == None:
        return
    frac = clamp(mi / STRIKE_ICON_MAX_MI, 0.0, 1.0)
    w = round_int(STRIKE_BOLT_MAX_W - frac * (STRIKE_BOLT_MAX_W - STRIKE_BOLT_MIN_W))
    h = round_int(STRIKE_BOLT_MAX_H - frac * (STRIKE_BOLT_MAX_H - STRIKE_BOLT_MIN_H))
    apex_x = x0 + 7 + round_int(frac * STRIKE_DRIFT_MAX)
    bolt_bottom = round_int(lerp(y0, y0 + TREE_BASE_DY, frac))
    draw_variable_bolt(c, apex_x, bolt_bottom - h, w, h, color)

def draw_sun(c, x, y):
    c.bitmap(SUN_BITMAP, x, y, "amber")
    cx = x + 7
    cy = y + 7
    c.line(cx, cy - 9, cx, cy - 7, "amber")
    c.line(cx, cy + 7, cx, cy + 9, "amber")
    c.line(cx - 9, cy, cx - 7, cy, "amber")
    c.line(cx + 7, cy, cx + 9, cy, "amber")
    c.line(cx - 7, cy - 7, cx - 5, cy - 5, "amber")
    c.line(cx + 5, cy - 5, cx + 7, cy - 7, "amber")
    c.line(cx - 7, cy + 7, cx - 5, cy + 5, "amber")
    c.line(cx + 5, cy + 5, cx + 7, cy + 7, "amber")

def draw_cloud(c, x, y, color):
    c.bitmap(CLOUD_BITMAP, x, y, color)

def draw_partly_cloudy(c, x, y):
    c.bitmap(SUN_BITMAP, x + 6, y - 2, "amber")
    draw_cloud(c, x, y + 5, "#AAAAAA")

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

# A small sun/moon half-disk sitting on a horizon line, used by the
# almanac page's rise/set rows instead of plain up/down arrows. Same icon
# for both rise and set - a 3px radius is too small for an asymmetric
# "mostly up" vs "mostly down" version of this to read clearly, so which
# one it means comes from draw_almanac_row's left (rise) vs right (set)
# position instead of the icon's own shape.
# Rise time beside an up-arrow, set time stacked underneath beside a
# down-arrow - used to the right of the almanac page's sun/moon icons,
# which sit to the left of both lines rather than one icon per line.
def draw_almanac_block(c, text_x, y, rise_str, set_str, color):
    row_font = "4x5"
    draw_arrow_up(c, text_x, y, color)
    c.text(rise_str, text_x + 6, y, font = row_font, color = color, align = "left")
    draw_arrow_down(c, text_x, y + 8, color)
    c.text(set_str, text_x + 6, y + 8, font = row_font, color = color, align = "left")

def draw_partly_cloudy_night(c, x, y):
    draw_moon(c, x + 6, y - 2)
    draw_cloud(c, x, y + 5, "#AAAAAA")

def draw_rain(c, x, y):
    c.line(x + 4, y + 10, x + 3, y + 14, "#3399FF")
    c.line(x + 9, y + 10, x + 8, y + 14, "#3399FF")
    c.line(x + 14, y + 10, x + 13, y + 14, "#3399FF")

def draw_snow(c, x, y):
    c.pixel(x + 4, y + 11, "white")
    c.pixel(x + 9, y + 12, "white")
    c.pixel(x + 14, y + 11, "white")
    c.pixel(x + 6, y + 14, "white")
    c.pixel(x + 11, y + 14, "white")

def draw_sleet(c, x, y):
    draw_cloud(c, x, y, "#999999")
    c.line(x + 4, y + 10, x + 3, y + 13, "#3399FF")
    c.pixel(x + 9, y + 12, "white")
    c.line(x + 14, y + 10, x + 13, y + 13, "#3399FF")

def draw_bolt(c, x, y):
    c.line(x + 11, y + 9, x + 8, y + 15, "amber")
    c.line(x + 8, y + 15, x + 12, y + 15, "amber")
    c.line(x + 12, y + 15, x + 9, y + 21, "amber")

def draw_fog(c, x, y):
    draw_cloud(c, x, y, "#999999")
    c.line(x + 2, y + 10, x + 17, y + 10, "#CCCCCC")
    c.line(x, y + 12, x + 19, y + 12, "#CCCCCC")

def draw_windy(c, x, y):
    c.line(x + 2, y + 6, x + 14, y + 6, "#AAAAAA")
    c.line(x + 14, y + 6, x + 16, y + 4, "#AAAAAA")
    c.line(x, y + 10, x + 12, y + 10, "#AAAAAA")
    c.line(x + 12, y + 10, x + 14, y + 12, "#AAAAAA")
    c.line(x + 4, y + 14, x + 16, y + 14, "#AAAAAA")

def draw_arrow_up(c, x, y, color):
    c.line(x + 2, y, x + 2, y + 4, color)
    c.line(x, y + 2, x + 2, y, color)
    c.line(x + 4, y + 2, x + 2, y, color)

def draw_arrow_down(c, x, y, color):
    c.line(x + 2, y, x + 2, y + 4, color)
    c.line(x, y + 2, x + 2, y + 4, color)
    c.line(x + 4, y + 2, x + 2, y + 4, color)

def draw_arrow_flat(c, x, y, color):
    c.line(x, y + 2, x + 4, y + 2, color)

def draw_icon(c, cond, x, y):
    if cond == "Clear":
        draw_sun(c, x, y)
    elif cond == "ClearNight":
        draw_moon(c, x, y)
    elif cond == "PartlyCloudy":
        draw_partly_cloudy(c, x, y)
    elif cond == "PartlyCloudyNight":
        draw_partly_cloudy_night(c, x, y)
    elif cond == "Rain":
        draw_cloud(c, x, y, "#888888")
        draw_rain(c, x, y)
    elif cond == "Sleet":
        draw_sleet(c, x, y)
    elif cond == "Thunderstorm":
        draw_cloud(c, x, y, "#666666")
        draw_bolt(c, x, y)
    elif cond == "Snow":
        draw_cloud(c, x, y, "#AAAAAA")
        draw_snow(c, x, y)
    elif cond == "Fog":
        draw_fog(c, x, y)
    elif cond == "Windy":
        draw_windy(c, x, y)
    elif cond == "Clouds":
        draw_cloud(c, x, y, "#AAAAAA")
    else:
        draw_cloud(c, x, y, "#999999")

def icon_vextent(cond):
    if cond == "Clear":
        return (-2, 16)
    elif cond == "ClearNight":
        return (-2, 12)
    elif cond == "PartlyCloudy":
        return (-2, 13)
    elif cond == "PartlyCloudyNight":
        return (-4, 13)
    elif cond == "Rain" or cond == "Snow":
        return (0, 14)
    elif cond == "Sleet":
        return (0, 13)
    elif cond == "Thunderstorm":
        return (0, 21)
    elif cond == "Fog":
        return (0, 12)
    elif cond == "Windy":
        return (4, 14)
    else:
        return (0, 8)

def centered_icon_y(cond, band_top, band_bottom):
    top, bottom = icon_vextent(cond)
    band_mid = (band_top + band_bottom) // 2
    return band_mid - (top + bottom) // 2

# Horizontal counterpart to icon_vextent - approximate ink bounds (relative
# to the (x, y) origin passed to draw_big_icon) used only to fit/center the
# scaled-up icon on the quick-glance page.
def icon_hextent(cond):
    if cond == "Clear":
        return (-2, 16)
    elif cond == "ClearNight":
        return (0, 14)
    elif cond == "PartlyCloudy":
        return (0, 22)
    elif cond == "PartlyCloudyNight":
        return (0, 20)
    elif cond == "Windy":
        return (0, 16)
    else:
        return (0, 20)

# Scaled (fractional scale allowed) versions of the icon set above, used
# only on the quick-glance page where there's room (and no neighboring text
# row) to draw the condition icon much larger than everywhere else in the
# app. Every coordinate is rounded (round_int, not int(), to dodge the
# negative-truncation bug we hit before) since scale is rarely a clean
# integer - the tallest icons (thunderstorm's bolt) already use almost the
# whole content band at scale 1, so most conditions only get a fractional
# boost out of a 24-row budget.
def draw_bitmap_scaled(c, matrix, x, y, scale, color):
    for ry in range(len(matrix)):
        row = matrix[ry]
        y0 = round_int(y + ry * scale)
        y1 = round_int(y + (ry + 1) * scale) - 1
        if y1 < y0:
            y1 = y0
        for rx in range(len(row)):
            if row[rx]:
                x0 = round_int(x + rx * scale)
                x1 = round_int(x + (rx + 1) * scale) - 1
                if x1 < x0:
                    x1 = x0
                c.rect(x0, y0, x1, y1, fill = color)

def draw_big_sun(c, x, y, scale):
    draw_bitmap_scaled(c, SUN_BITMAP, x, y, scale, "amber")
    cx = x + 7 * scale
    cy = y + 7 * scale
    c.line(round_int(cx), round_int(cy - 9 * scale), round_int(cx), round_int(cy - 7 * scale), "amber")
    c.line(round_int(cx), round_int(cy + 7 * scale), round_int(cx), round_int(cy + 9 * scale), "amber")
    c.line(round_int(cx - 9 * scale), round_int(cy), round_int(cx - 7 * scale), round_int(cy), "amber")
    c.line(round_int(cx + 7 * scale), round_int(cy), round_int(cx + 9 * scale), round_int(cy), "amber")
    c.line(round_int(cx - 7 * scale), round_int(cy - 7 * scale), round_int(cx - 5 * scale), round_int(cy - 5 * scale), "amber")
    c.line(round_int(cx + 5 * scale), round_int(cy - 5 * scale), round_int(cx + 7 * scale), round_int(cy - 7 * scale), "amber")
    c.line(round_int(cx - 7 * scale), round_int(cy + 7 * scale), round_int(cx - 5 * scale), round_int(cy + 5 * scale), "amber")
    c.line(round_int(cx + 5 * scale), round_int(cy + 5 * scale), round_int(cx + 7 * scale), round_int(cy + 7 * scale), "amber")

def draw_big_cloud(c, x, y, scale, color):
    draw_bitmap_scaled(c, CLOUD_BITMAP, x, y, scale, color)

def draw_big_moon(c, x, y, scale):
    cx = x + 7 * scale
    cy = y + 5 * scale
    c.fill_circle(round_int(cx), round_int(cy), round_int(7 * scale), "#DDDDDD")
    c.fill_circle(round_int(cx - 3 * scale), round_int(cy - 2 * scale), round_int(7 * scale), BODY_BOTTOM_HEX)

def draw_big_partly_cloudy(c, x, y, scale):
    draw_big_sun(c, round_int(x + 6 * scale), round_int(y - 2 * scale), scale)
    draw_big_cloud(c, x, round_int(y + 5 * scale), scale, "#AAAAAA")

def draw_big_partly_cloudy_night(c, x, y, scale):
    draw_big_moon(c, round_int(x + 6 * scale), round_int(y - 2 * scale), scale)
    draw_big_cloud(c, x, round_int(y + 5 * scale), scale, "#AAAAAA")

def draw_big_rain(c, x, y, scale):
    c.line(round_int(x + 4 * scale), round_int(y + 10 * scale), round_int(x + 3 * scale), round_int(y + 14 * scale), "#3399FF")
    c.line(round_int(x + 9 * scale), round_int(y + 10 * scale), round_int(x + 8 * scale), round_int(y + 14 * scale), "#3399FF")
    c.line(round_int(x + 14 * scale), round_int(y + 10 * scale), round_int(x + 13 * scale), round_int(y + 14 * scale), "#3399FF")

def draw_big_snow(c, x, y, scale):
    c.pixel(round_int(x + 4 * scale), round_int(y + 11 * scale), "white")
    c.pixel(round_int(x + 9 * scale), round_int(y + 12 * scale), "white")
    c.pixel(round_int(x + 14 * scale), round_int(y + 11 * scale), "white")
    c.pixel(round_int(x + 6 * scale), round_int(y + 14 * scale), "white")
    c.pixel(round_int(x + 11 * scale), round_int(y + 14 * scale), "white")

def draw_big_sleet(c, x, y, scale):
    draw_big_cloud(c, x, y, scale, "#999999")
    c.line(round_int(x + 4 * scale), round_int(y + 10 * scale), round_int(x + 3 * scale), round_int(y + 13 * scale), "#3399FF")
    c.pixel(round_int(x + 9 * scale), round_int(y + 12 * scale), "white")
    c.line(round_int(x + 14 * scale), round_int(y + 10 * scale), round_int(x + 13 * scale), round_int(y + 13 * scale), "#3399FF")

def draw_big_bolt(c, x, y, scale):
    c.line(round_int(x + 11 * scale), round_int(y + 9 * scale), round_int(x + 8 * scale), round_int(y + 15 * scale), "amber")
    c.line(round_int(x + 8 * scale), round_int(y + 15 * scale), round_int(x + 12 * scale), round_int(y + 15 * scale), "amber")
    c.line(round_int(x + 12 * scale), round_int(y + 15 * scale), round_int(x + 9 * scale), round_int(y + 21 * scale), "amber")

def draw_big_fog(c, x, y, scale):
    draw_big_cloud(c, x, y, scale, "#999999")
    c.line(round_int(x + 2 * scale), round_int(y + 10 * scale), round_int(x + 17 * scale), round_int(y + 10 * scale), "#CCCCCC")
    c.line(x, round_int(y + 12 * scale), round_int(x + 19 * scale), round_int(y + 12 * scale), "#CCCCCC")

def draw_big_windy(c, x, y, scale):
    c.line(round_int(x + 2 * scale), round_int(y + 6 * scale), round_int(x + 14 * scale), round_int(y + 6 * scale), "#AAAAAA")
    c.line(round_int(x + 14 * scale), round_int(y + 6 * scale), round_int(x + 16 * scale), round_int(y + 4 * scale), "#AAAAAA")
    c.line(x, round_int(y + 10 * scale), round_int(x + 12 * scale), round_int(y + 10 * scale), "#AAAAAA")
    c.line(round_int(x + 12 * scale), round_int(y + 10 * scale), round_int(x + 14 * scale), round_int(y + 12 * scale), "#AAAAAA")
    c.line(round_int(x + 4 * scale), round_int(y + 14 * scale), round_int(x + 16 * scale), round_int(y + 14 * scale), "#AAAAAA")

def draw_big_icon(c, cond, x, y, scale):
    if cond == "Clear":
        draw_big_sun(c, x, y, scale)
    elif cond == "ClearNight":
        draw_big_moon(c, x, y, scale)
    elif cond == "PartlyCloudy":
        draw_big_partly_cloudy(c, x, y, scale)
    elif cond == "PartlyCloudyNight":
        draw_big_partly_cloudy_night(c, x, y, scale)
    elif cond == "Rain":
        draw_big_cloud(c, x, y, scale, "#888888")
        draw_big_rain(c, x, y, scale)
    elif cond == "Sleet":
        draw_big_sleet(c, x, y, scale)
    elif cond == "Thunderstorm":
        draw_big_cloud(c, x, y, scale, "#666666")
        draw_big_bolt(c, x, y, scale)
    elif cond == "Snow":
        draw_big_cloud(c, x, y, scale, "#AAAAAA")
        draw_big_snow(c, x, y, scale)
    elif cond == "Fog":
        draw_big_fog(c, x, y, scale)
    elif cond == "Windy":
        draw_big_windy(c, x, y, scale)
    elif cond == "Clouds":
        draw_big_cloud(c, x, y, scale, "#AAAAAA")
    else:
        draw_big_cloud(c, x, y, scale, "#999999")

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

# A scaled-down (scale < 1) version of the mini icon set above, used only
# for the "current conditions over the tree" spot on the lightning page -
# draw_mini_icon's own callers (the forecast page) stay untouched.
def draw_tiny_moon(c, x, y, scale):
    cx = round_int(x + 4 * scale)
    cy = round_int(y + 4 * scale)
    r = round_int(4 * scale)
    if r < 1:
        r = 1
    c.fill_circle(cx, cy, r, "#DDDDDD")
    c.fill_circle(cx - round_int(2 * scale), cy - round_int(1 * scale), r, BODY_BOTTOM_HEX)

def draw_tiny_icon(c, cond, x, y, scale):
    if cond == "Clear":
        draw_bitmap_scaled(c, MINI_SUN_BITMAP, round_int(x + 1 * scale), y, scale, "amber")
    elif cond == "ClearNight":
        draw_tiny_moon(c, round_int(x + 1 * scale), y, scale)
    elif cond == "PartlyCloudy":
        draw_bitmap_scaled(c, MINI_SUN_BITMAP, round_int(x + 4 * scale), round_int(y - 2 * scale), scale, "amber")
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, round_int(y + 3 * scale), scale, "#AAAAAA")
    elif cond == "PartlyCloudyNight":
        draw_tiny_moon(c, round_int(x + 4 * scale), round_int(y - 2 * scale), scale)
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, round_int(y + 3 * scale), scale, "#AAAAAA")
    elif cond == "Rain":
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, y, scale, "#888888")
        c.line(round_int(x + 3 * scale), round_int(y + 6 * scale), round_int(x + 2 * scale), round_int(y + 8 * scale), "#3399FF")
        c.line(round_int(x + 8 * scale), round_int(y + 6 * scale), round_int(x + 7 * scale), round_int(y + 8 * scale), "#3399FF")
    elif cond == "Sleet":
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, y, scale, "#999999")
        c.pixel(round_int(x + 3 * scale), round_int(y + 7 * scale), "#3399FF")
        c.pixel(round_int(x + 8 * scale), round_int(y + 7 * scale), "white")
    elif cond == "Thunderstorm":
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, y, scale, "#666666")
        c.line(round_int(x + 7 * scale), round_int(y + 6 * scale), round_int(x + 5 * scale), round_int(y + 8 * scale), "amber")
        c.line(round_int(x + 5 * scale), round_int(y + 8 * scale), round_int(x + 8 * scale), round_int(y + 8 * scale), "amber")
    elif cond == "Snow":
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, y, scale, "#AAAAAA")
        c.pixel(round_int(x + 3 * scale), round_int(y + 7 * scale), "white")
        c.pixel(round_int(x + 8 * scale), round_int(y + 7 * scale), "white")
        c.pixel(round_int(x + 5 * scale), round_int(y + 8 * scale), "white")
    elif cond == "Fog":
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, y, scale, "#999999")
        c.line(round_int(x + 1 * scale), round_int(y + 7 * scale), round_int(x + 10 * scale), round_int(y + 7 * scale), "#CCCCCC")
    elif cond == "Windy":
        c.line(round_int(x + 1 * scale), round_int(y + 4 * scale), round_int(x + 9 * scale), round_int(y + 4 * scale), "#AAAAAA")
        c.line(x, round_int(y + 7 * scale), round_int(x + 8 * scale), round_int(y + 7 * scale), "#AAAAAA")
    elif cond == "Clouds":
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, y, scale, "#AAAAAA")
    else:
        draw_bitmap_scaled(c, MINI_CLOUD_BITMAP, x, y, scale, "#999999")

def hex_to_rgb(hexcolor):
    return (int(hexcolor[1:3], 16), int(hexcolor[3:5], 16), int(hexcolor[5:7], 16))

def dim_hex(hexcolor, factor):
    r, g, b = hex_to_rgb(hexcolor)
    return rgb_to_hex(round_int(r * factor), round_int(g * factor), round_int(b * factor))

UV_BAND_LOWS = [0.0, 3.0, 6.0, 8.0, 11.0]
UV_BAND_COLORS = ["#00A000", "#DCC800", "#FF8800", "#DC0000", "#8833CC"]

SOLAR_BAND_LOWS = [0.0, 280.0, 560.0, 840.0, 1120.0]
SOLAR_BAND_COLORS = ["#663300", "#996600", "#CC9900", "#FFCC00", "#FFEE66"]

BRIGHT_BAND_LOWS = [0.0, 2000.0, 4000.0, 6000.0, 8000.0]
BRIGHT_BAND_COLORS = ["#334455", "#667788", "#99AABB", "#CCDDEE", "#FFFFFF"]

def draw_segment_gauge(c, label, value_str, band_lows, band_colors, value, x0, x1):
    cx = (x0 + x1) // 2
    c.text(label.upper(), cx, 9, font = "4x5", color = "white", align = "center")

    n = len(band_lows)
    bar_top = 15
    bar_bottom = 25
    seg_h = (bar_bottom - bar_top) // n

    lit_count = 0
    for low in band_lows:
        if value >= low:
            lit_count += 1

    for i in range(n):
        seg_top = bar_bottom - (i + 1) * seg_h
        seg_bottom = bar_bottom - i * seg_h - 1
        color = band_colors[i] if i < lit_count else dim_hex(band_colors[i], 0.15)
        c.rect(x0, seg_top, x1, seg_bottom, fill = color)

    value_color = band_colors[lit_count - 1] if lit_count > 0 else "#888888"
    c.text(value_str.upper(), cx, 26, font = "4x5", color = value_color, align = "center")

def pressure_color(inhg):
    if inhg < 29.000:
        return "#FF0000"
    elif inhg <= 29.800:
        return "#FF8800"
    elif inhg <= 30.200:
        return "amber"
    elif inhg <= 30.500:
        return "#33CC66"
    else:
        return "#0066FF"

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

def pressure_change_color(change):
    a = change if change >= 0 else -change
    if a <= 0.003:
        return "#33CC66"
    elif a <= 0.040:
        return "#AACC33"
    elif a <= 0.090:
        return "amber"
    elif a <= 0.180:
        return "#FF8800"
    else:
        return "#FF0000"

def temp_color(f):
    if f < 20:
        return "#0033FF"
    elif f < 32:
        return "#0066FF"
    elif f < 45:
        return "#00AAFF"
    elif f < 55:
        return "#00CCCC"
    elif f < 65:
        return "#33CC66"
    elif f < 75:
        return "amber"
    elif f < 85:
        return "#FF8800"
    elif f < 95:
        return "#FF4400"
    else:
        return "#FF0000"

def dew_point_color(temp, dew_point):
    spread = temp - dew_point
    if spread < 0:
        spread = 0
    if spread >= 20:
        return "#33CC66"
    elif spread >= 12:
        return "#AACC33"
    elif spread >= 6:
        return "amber"
    elif spread >= 3:
        return "#FF8800"
    else:
        return "#FF0000"

def last_strike_color(minutes_ago):
    if minutes_ago < 1:
        return "#FF0000"
    elif minutes_ago <= 14:
        return "#FF4400"
    elif minutes_ago <= 59:
        return "#FF8800"
    elif minutes_ago <= 299:
        return "amber"
    elif minutes_ago <= 2879:
        return "#33CC66"
    else:
        return "#0066FF"

def strikes_last_hour_color(count):
    if count <= 60:
        return "yellow"
    elif count <= 120:
        return "amber"
    elif count <= 180:
        return "#FF8800"
    elif count <= 300:
        return "#FF4400"
    else:
        return "#FF0000"

def strikes_last_3hr_color(count):
    if count <= 180:
        return "yellow"
    elif count <= 360:
        return "amber"
    elif count <= 540:
        return "#FF8800"
    elif count <= 900:
        return "#FF4400"
    else:
        return "#FF0000"

def rain_duration_color(minutes):
    if minutes <= 59:
        return "#99CCFF"
    elif minutes <= 179:
        return "#3399FF"
    elif minutes <= 359:
        return "#0066FF"
    elif minutes <= 719:
        return "#0033CC"
    else:
        return "#0022AA"

def rain_last_hour_color(inches):
    if inches <= 0.109:
        return "#0066FF"
    elif inches <= 0.309:
        return "#00CCCC"
    elif inches <= 1.009:
        return "amber"
    elif inches <= 2.099:
        return "#FF8800"
    else:
        return "#FF0000"

def rain_daily_color(inches):
    if inches <= 0.500:
        return "#0066FF"
    elif inches <= 1.000:
        return "#00CCCC"
    elif inches <= 2.000:
        return "amber"
    elif inches <= 3.000:
        return "#FF8800"
    else:
        return "#FF0000"

# Same shape as rain_daily_color, just scaled up for a month-to-date total
# (a stylistic scale, not a verified meteorological standard).
def rain_monthly_color(inches):
    if inches <= 2.500:
        return "#0066FF"
    elif inches <= 5.000:
        return "#00CCCC"
    elif inches <= 7.500:
        return "amber"
    elif inches <= 10.000:
        return "#FF8800"
    else:
        return "#FF0000"

def humidity_color(h):
    if h < 20:
        return "#0033FF"
    elif h < 35:
        return "#0066FF"
    elif h < 50:
        return "#00AAFF"
    elif h < 60:
        return "#00CCCC"
    elif h < 70:
        return "#33CC66"
    elif h < 80:
        return "amber"
    elif h < 90:
        return "#FF8800"
    elif h < 95:
        return "#FF4400"
    else:
        return "#FF0000"

# ---------- shared station load ----------

def load_station(c, ctx):
    station, err = resolve_station(ctx)
    if station == None:
        draw_body_bg(c)
        if err == "no token":
            draw_error(c, "set api token")
        elif err == "station not found":
            draw_error(c, "station not found")
        elif err == "no stations":
            draw_error(c, "no stations found")
        else:
            draw_error(c, "auth failed")
        return None
    return station

# ---------- pages ----------

def current(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    fc_resp = fetch_better_forecast(station["token"], station["station_id"])
    if fc_resp["status_code"] != 200:
        draw_error(c, "station error")
        return

    cur = fc_resp["json"].get("current_conditions", {})
    obs_resp = fetch_observation(station["token"], station["station_id"])
    obs_list = obs_resp["json"].get("obs", []) if obs_resp["status_code"] == 200 else []
    obs0 = obs_list[0] if len(obs_list) > 0 else {}
    ts = obs0.get("timestamp", 0)

    temp_raw = obs0.get("air_temperature", None)
    if temp_raw == None:
        temp_raw = cur.get("air_temperature", 0.0)
    temp = c_to_f(temp_raw)

    humidity = obs0.get("relative_humidity", None)
    if humidity == None:
        humidity = cur.get("relative_humidity", 0)
    humid_col = humidity_color(humidity)

    # Temp itself now lives on the conditions ("AT A GLANCE") page, so this
    # page swaps it out for dew point instead of showing the same reading
    # twice - humidity moves into temp's old (left) slot, dew point takes
    # humidity's old (middle) slot, pressure stays put.
    dew_point = c_to_f(cur.get("dew_point", temp_raw))
    dew_col = dew_point_color(temp, dew_point)

    # Same station_pressure/elevation handling as conditions() below -
    # kept in sync deliberately since both pages show the same reading.
    station_pressure_hpa = obs0.get("station_pressure", None)
    if station_pressure_hpa != None:
        station_pressure = hpa_to_inhg(station_pressure_hpa)
    else:
        station_pressure = cur.get("station_pressure", 0.0)
    elevation_ft = _n(ctx, "elevationft", 0.0)
    if elevation_ft > 0:
        pressure = sea_level_pressure(station_pressure, elevation_ft, obs0.get("air_temperature", cur.get("air_temperature", 0.0)))
    else:
        pressure = station_pressure

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, "CURRENT CONDITIONS", time_str)

    # 3 round dial gauges - temp and humidity are color-coded the same as
    # every other page in this app; pressure deliberately isn't (a real
    # barometer face doesn't recolor itself by reading), so its ring/needle
    # stay neutral and its tick marks are the actual Stormy/Rain/Change/
    # Fair/Very Dry gradations a household barometer prints, not a scale
    # we invented.
    humid_frac = clamp(humidity / 100.0, 0.0, 1.0)
    dew_frac = clamp(dew_point / 100.0, 0.0, 1.0)
    press_frac = clamp((pressure - BAROMETER_LOW_IN) / (BAROMETER_HIGH_IN - BAROMETER_LOW_IN), 0.0, 1.0)
    trend = obs0.get("pressure_trend", cur.get("pressure_trend", None))

    draw_gauge_column(c, 0, 43, "HUMID", str(round_int(humidity)) + "%", humid_frac, humid_col, None)
    draw_gauge_column(c, 43, 43, "DEWPT", format1(dew_point) + "F", dew_frac, dew_col, None)
    draw_gauge_column(c, 86, 42, "PRESS", format2(pressure), press_frac, "#AAAAAA", BAROMETER_TICKS, trend, fill_ring = False, needle_color = barometer_needle_color(press_frac))

    draw_page_edges(c, left = False)

# An optional "LABEL " prefix, then the value, then a smaller "F" riding a
# small gap to its right (about 2/3 the value font's height, not the exact
# half the wind page's "AT"/"MPH" pairing uses) - centered on cx as one
# unit. unit_dy nudges the smaller glyph down to sit mid-height against
# the taller value digits instead of top-aligned with them.
def draw_temp_reading(c, cx, y, label, value, value_font, unit_font, unit_dy, color):
    prefix = (label + " ") if label else ""
    value_str = format1(value)
    gap = 2
    prefix_w = c.text_width(prefix, value_font) if prefix else 0
    value_w = c.text_width(value_str, value_font)
    unit_w = c.text_width("F", unit_font)
    total_w = prefix_w + value_w + gap + unit_w
    x0 = round_int(cx - total_w / 2.0)
    if prefix:
        c.text(prefix, x0, y, font = value_font, color = color, align = "left")
    c.text(value_str, x0 + prefix_w, y, font = value_font, color = color, align = "left")
    c.text("F", x0 + prefix_w + value_w + gap, y + unit_dy, font = unit_font, color = color, align = "left")

def conditions(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    fc_resp = fetch_better_forecast(station["token"], station["station_id"])
    if fc_resp["status_code"] != 200:
        draw_error(c, "station error")
        return

    cur = fc_resp["json"].get("current_conditions", {})
    obs_resp = fetch_observation(station["token"], station["station_id"])
    obs_list = obs_resp["json"].get("obs", []) if obs_resp["status_code"] == 200 else []
    obs0 = obs_list[0] if len(obs_list) > 0 else {}

    temp_raw = obs0.get("air_temperature", None)
    if temp_raw == None:
        temp_raw = cur.get("air_temperature", 0.0)
    temp = c_to_f(temp_raw)

    feels_like = c_to_f(cur.get("feels_like", temp_raw))

    draw_body_bg(c)
    draw_header_centered(c, station["name"] + " AT A GLANCE")

    # The condition icon at whatever integer scale fills the left-hand box
    # without busting either the content band's height or its own width
    # budget - picked per-condition since a thunderstorm bolt's box is much
    # taller than a plain cloud's.
    cond = tempest_icon_to_cond(cur.get("icon"))
    vtop, vbot = icon_vextent(cond)
    htop, hbot = icon_hextent(cond)
    height1 = vbot - vtop
    width1 = hbot - htop

    band_top = 8
    band_bottom = 31
    icon_box_x0 = 3
    icon_box_w = 25

    scale = min(float(band_bottom - band_top + 1) / height1, float(icon_box_w) / width1)

    icon_x = round_int(icon_box_x0 + icon_box_w / 2.0 - (htop + hbot) * scale / 2.0)
    icon_y = round_int((band_top + band_bottom) / 2.0 - (vtop + vbot) * scale / 2.0)
    draw_big_icon(c, cond, icon_x, icon_y, scale)

    text_x0 = icon_box_x0 + icon_box_w + 3
    text_x1 = 126

    # Sideways thermometer up top - fixed 0-100F scale, full color coding
    # end to end, with a marker at today's actual reading. The actual
    # numeric readings still get printed underneath it (the marker alone
    # only gives an approximate read of where on the 0-100 scale it sits),
    # centered under the bar.
    # Bar nudged down from band_top + 2 to band_top + 3 to leave headroom
    # above it for the pointer arrow.
    draw_thermometer_bar(c, text_x0, text_x1, band_top + 3, 6, temp)
    text_cx = (text_x0 + text_x1) // 2

    if feels_like < temp:
        # Feels-cooler-than-actual (wind chill) is skipped rather than
        # shown - Chris wants that case to just be a bigger TEMP reading
        # instead of a TEMP/FEELS pair, unlike feels-hotter (heat index)
        # which is worth calling out.
        draw_temp_reading(c, text_cx, 20, "", temp, "10x10", "5x7", 2, temp_color(temp))
    else:
        draw_temp_reading(c, text_cx, 19, "TEMP", temp, "5x7", "4x5", 1, temp_color(temp))
        feels_str = "FEELS " + format1(feels_like) + "F"
        c.text(feels_str, text_cx, 27, font = "picopixel", color = temp_color(feels_like), align = "center")

    draw_page_edges(c, left = True)

def wind(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    fc_resp = fetch_better_forecast(station["token"], station["station_id"])
    if fc_resp["status_code"] != 200:
        draw_error(c, "station error")
        return

    cur = fc_resp["json"].get("current_conditions", {})
    obs_resp = fetch_observation(station["token"], station["station_id"])
    obs_list = obs_resp["json"].get("obs", []) if obs_resp["status_code"] == 200 else []
    ts = obs_list[0].get("timestamp", 0) if len(obs_list) > 0 else 0
    obs = obs_list[0] if len(obs_list) > 0 else {}

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, "WIND", time_str)

    speed = cur.get("wind_avg", 0.0)
    deg = cur.get("wind_direction", 0)
    gust = cur.get("wind_gust", None)
    idx = compass_index(deg)
    color = "white" if speed == 0 else wind_color(speed)

    # A real compass rose (needle at the live wind direction) replaces what
    # was a plain "N @ 5 MPH" text line - the single most iconic weather
    # graphic this app didn't have yet. Calm has no heading to point at,
    # so the needle is dropped rather than show a stale/meaningless one.
    cx, cy, r = 17, 20, 10
    draw_compass(c, cx, cy, r, deg, color, show_needle = speed != 0)

    dir_str = CARDINAL_NAMES[idx].upper()
    speed_str = str(round_int(speed))
    mid_cx = 63

    # DIR/SPEED shrinks to one small centered line at the top of the body,
    # freeing the rest of the column for the flag below - a flag reads
    # "how windy" at a glance in a way a number doesn't. Calm swaps it for
    # "NO WIND" since direction/speed are both meaningless at zero.
    top_line = "NO WIND" if speed == 0 else (dir_str + " " + speed_str + " MPH")
    c.text(top_line.upper(), mid_cx, 9, font = "4x5", color = color, align = "center")

    flag_h = 8
    reach = 22
    droop_max = 11
    pole_x = round_int(mid_cx - reach / 2.0)
    frac = clamp(speed / 20.0, 0.0, 1.0)
    draw_wind_flag(c, pole_x, 14, 30, 15, flag_h, reach, droop_max, frac, color)

    if gust != None:
        gust_val = str(round_int(gust)) + " MPH"
        gust_color = "white" if gust == 0 else wind_color(gust)
    else:
        gust_val = "N/A"
        gust_color = "#888888"
    c.text("GUST".upper(), 109, 9, font = "4x5", color = "white", align = "center")
    c.text(gust_val.upper(), 109, 15, font = "picopixel", color = gust_color, align = "center")

    # A true daily-high gust isn't a field the API hands back directly - it
    # has to be computed by pulling every device observation from local
    # midnight through now and taking the max of each row's wind_gust
    # (index 3 in the positional array - see fetch_device_observations'
    # header comment). That endpoint doesn't take a units_wind param at
    # all, so - same as the station obs endpoint - it's native m/s
    # regardless; converting with mps_to_mph below.
    best_gust_mps = None
    if station["device_id"] != None and ts > 0:
        day_start = ts - ((ts + station["tz_offset_min"] * 60) % 86400)
        dev_resp = fetch_device_observations(station["token"], station["device_id"], day_start, ts)
        if dev_resp["status_code"] == 200:
            for row in dev_resp["json"].get("obs", []):
                if len(row) <= 3:
                    continue
                g = row[3]
                if g != None and (best_gust_mps == None or g > best_gust_mps):
                    best_gust_mps = g

    if best_gust_mps != None:
        daily_high_mph = mps_to_mph(best_gust_mps)
        high_gust_val = str(round_int(daily_high_mph)) + " MPH"
        high_gust_color = "white" if daily_high_mph == 0 else wind_color(daily_high_mph)
    else:
        high_gust_val = "N/A"
        high_gust_color = "#888888"
    c.text("DAILY HI", 109, 20, font = "picopixel", color = "white", align = "center")
    c.text(high_gust_val.upper(), 109, 26, font = "picopixel", color = high_gust_color, align = "center")

    draw_page_edges(c, left = False)

def rainfall(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    obs_resp = fetch_observation(station["token"], station["station_id"])
    if obs_resp["status_code"] != 200:
        draw_error(c, "station error")
        return

    obs_list = obs_resp["json"].get("obs", [])
    if len(obs_list) == 0:
        draw_error(c, "no data")
        return
    obs = obs_list[0]
    ts = obs.get("timestamp", 0)

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, "RAIN", time_str)

    today_total = mm_to_in(obs.get("precip_accum_local_day", 0.0))
    today_color = "white" if today_total == 0 else rain_daily_color(today_total)

    c.text("TODAY'S RAIN", 2, 9, font = "4x5", color = "white", align = "left")
    c.text((format3(today_total) + " IN").upper(), 126, 9, font = "4x5", color = today_color, align = "right")
    draw_linear_gauge(c, 2, 126, 16, 3, 0.0, 5.0, today_total, today_color, [1.0, 2.0, 3.0, 4.0])

    last_hour_raw = obs.get("precip_accum_last_1hr", None)
    last_hour_total = mm_to_in(last_hour_raw) if last_hour_raw != None else None
    if last_hour_total == None:
        last_hour_color = "#888888"
        last_hour_str = "N/A"
    else:
        last_hour_color = "white" if last_hour_total == 0 else rain_last_hour_color(last_hour_total)
        last_hour_str = (format3(last_hour_total) + " IN").upper()

    c.text("LAST HOUR RAIN", 2, 21, font = "4x5", color = "white", align = "left")
    c.text(last_hour_str, 126, 21, font = "4x5", color = last_hour_color, align = "right")
    draw_linear_gauge(c, 2, 126, 28, 3, 0.0, 2.0, last_hour_total if last_hour_total != None else 0.0, last_hour_color, [0.5, 1.0, 1.5])

    draw_page_edges(c, left = False)

def rainfall2(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    obs_resp = fetch_observation(station["token"], station["station_id"])
    if obs_resp["status_code"] != 200:
        draw_error(c, "station error")
        return

    obs_list = obs_resp["json"].get("obs", [])
    if len(obs_list) == 0:
        draw_error(c, "no data")
        return
    obs = obs_list[0]
    ts = obs.get("timestamp", 0)

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, "RAIN HISTORY", time_str)

    yesterday_total = obs.get("precip_accum_local_yesterday_final", None)
    if yesterday_total == None:
        yesterday_total = obs.get("precip_accum_local_yesterday", None)
    yesterday_in = mm_to_in(yesterday_total) if yesterday_total != None else None
    if yesterday_in == None:
        yesterday_color = "#888888"
        yesterday_str = "N/A"
    else:
        yesterday_color = "white" if yesterday_in == 0 else rain_daily_color(yesterday_in)
        yesterday_str = (format3(yesterday_in) + " IN").upper()

    c.text("YESTERDAY'S RAIN", 2, 9, font = "4x5", color = "white", align = "left")
    c.text(yesterday_str, 126, 9, font = "4x5", color = yesterday_color, align = "right")
    draw_linear_gauge(c, 2, 126, 16, 3, 0.0, 5.0, yesterday_in if yesterday_in != None else 0.0, yesterday_color, [1.0, 2.0, 3.0, 4.0])

    # Not a field any endpoint hands back directly - summed from every
    # device observation's per-interval rain accumulation (index 12 in the
    # positional array: [epoch, wind_lull, wind_avg, wind_gust,
    # wind_direction, wind_interval, station_pressure, air_temperature,
    # relative_humidity, illuminance, uv, solar_radiation, rain_accum, ...])
    # from local midnight on the 1st of the month through now. That index
    # matches WeatherFlow's published obs_st schema but - unlike wind_gust
    # (index 3) and station_pressure (index 6), both confirmed against a
    # live station - hasn't been live-verified in this app; flag it if a
    # real reading looks wrong.
    monthly_total = None
    if station["device_id"] != None and ts > 0:
        local_epoch = ts + station["tz_offset_min"] * 60
        days_since_epoch = local_epoch // 86400
        y, m, d = civil_from_days(days_since_epoch)
        month_start_days = days_from_civil(y, m, 1)
        month_start_epoch = month_start_days * 86400 - station["tz_offset_min"] * 60
        dev_resp = fetch_device_observations(station["token"], station["device_id"], month_start_epoch, ts)
        if dev_resp["status_code"] == 200:
            total_mm = 0.0
            for row in dev_resp["json"].get("obs", []):
                if len(row) <= 12:
                    continue
                r = row[12]
                if r != None:
                    total_mm += r
            monthly_total = mm_to_in(total_mm)

    if monthly_total != None:
        monthly_color = "white" if monthly_total == 0 else rain_monthly_color(monthly_total)
        monthly_str = (format3(monthly_total) + " IN").upper()
    else:
        monthly_color = "#888888"
        monthly_str = "N/A"

    c.text("MONTHLY RAIN", 2, 21, font = "4x5", color = "white", align = "left")
    c.text(monthly_str, 126, 21, font = "4x5", color = monthly_color, align = "right")
    draw_linear_gauge(c, 2, 126, 28, 3, 0.0, 15.0, monthly_total if monthly_total != None else 0.0, monthly_color, [5.0, 10.0])

    draw_page_edges(c, left = False)

def uv(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    fc_resp = fetch_better_forecast(station["token"], station["station_id"])
    if fc_resp["status_code"] != 200:
        draw_error(c, "station error")
        return

    cur = fc_resp["json"].get("current_conditions", {})
    obs_resp = fetch_observation(station["token"], station["station_id"])
    obs_list = obs_resp["json"].get("obs", []) if obs_resp["status_code"] == 200 else []
    obs = obs_list[0] if len(obs_list) > 0 else {}
    ts = obs.get("timestamp", 0)

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, station["name"], time_str)

    uv_val = obs.get("uv", None)
    if uv_val == None:
        uv_val = cur.get("uv", None)
    if uv_val == None:
        uv_val = 0.0

    solar = obs.get("solar_radiation", None)
    if solar == None:
        solar = cur.get("solar_radiation", None)
    if solar == None:
        solar = 0.0

    brightness = obs.get("brightness", None)
    if brightness == None:
        brightness = cur.get("brightness", None)
    if brightness == None:
        brightness = 0.0

    draw_segment_gauge(c, "UV", format2(uv_val), UV_BAND_LOWS, UV_BAND_COLORS, uv_val, 2, 42)
    draw_segment_gauge(c, "SOLAR", str(round_int(solar)), SOLAR_BAND_LOWS, SOLAR_BAND_COLORS, solar, 45, 85)
    draw_segment_gauge(c, "BRIGHT", str(round_int(brightness)), BRIGHT_BAND_LOWS, BRIGHT_BAND_COLORS, brightness, 88, 126)

    draw_page_edges(c, left = False)

def draw_forecast_unavailable(c):
    c.text("FORECAST".upper(), 64, 13, font = "4x5", color = "#888888", align = "center")
    c.text("UNAVAILABLE".upper(), 64, 19, font = "4x5", color = "#888888", align = "center")

def forecast(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    obs_resp = fetch_observation(station["token"], station["station_id"])
    obs_list = obs_resp["json"].get("obs", []) if obs_resp["status_code"] == 200 else []
    ts = obs_list[0].get("timestamp", 0) if len(obs_list) > 0 else 0

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, station["name"], time_str)

    points_resp = fetch_nws_points(station["lat"], station["lon"])
    if points_resp["status_code"] != 200:
        draw_forecast_unavailable(c)
        return

    forecast_url = points_resp["json"].get("properties", {}).get("forecast", None)
    if forecast_url == None:
        draw_forecast_unavailable(c)
        return

    fc_resp = fetch_nws_forecast(forecast_url)
    if fc_resp["status_code"] != 200:
        draw_forecast_unavailable(c)
        return

    periods = fc_resp["json"].get("properties", {}).get("periods", [])
    if len(periods) == 0:
        draw_forecast_unavailable(c)
        return

    today_y, today_m, today_d = date_from_iso(periods[0]["startTime"])
    today_days = days_from_civil(today_y, today_m, today_d)

    # 3 columns (42px each) instead of the old 5 (25px each) - fewer
    # periods shown (today/tonight/tomorrow instead of ~2.5 days out) but
    # each one gets room for a full label, a colored temp, and a rain-
    # chance line when there's actually precip in the forecast, instead of
    # every column being squeezed down to a bare number.
    col_w = 128 // 3
    count = 0
    for p in periods:
        if count >= 3:
            break
        cx = count * col_w + col_w // 2
        count += 1

        y, m, d = date_from_iso(p["startTime"])
        key = days_from_civil(y, m, d)
        is_day = p.get("isDaytime", True)
        if key == today_days:
            label = near_term_label(p.get("name", ""))
            if label == None:
                label = "TODAY" if is_day else "TONIGHT"
        else:
            weekday = (key + 4) % 7
            label = WEEKDAY_NAMES[weekday] + (" NIGHT" if not is_day else "")
        label_font = fit_font(c, label.upper(), ["4x5", "picopixel"], col_w - 4)
        c.text(label.upper(), cx, 8, font = label_font, color = "white", align = "center")

        cond = nws_to_cond(p.get("shortForecast", ""))
        if not is_day:
            if cond == "Clear":
                cond = "ClearNight"
            elif cond == "PartlyCloudy":
                cond = "PartlyCloudyNight"
        draw_mini_icon(c, cond, cx - 6, 14)

        # Rain chance rides beside the temp ("80/60%") instead of its own
        # row underneath - frees up a whole row, which goes toward a
        # bigger font for both (5x7, was 4x5) and pushing the icon above
        # down clear of the label text.
        temp = p.get("temperature", None)
        temp_str = str(temp) if temp != None else "--"
        temp_col = temp_color(temp) if temp != None else "white"

        pop = p.get("probabilityOfPrecipitation", {}) or {}
        pop_val = pop.get("value", None)
        pop_str = ("/" + str(pop_val) + "%") if (pop_val != None and pop_val > 0) else None

        value_font = "5x7"
        temp_w = c.text_width(temp_str.upper(), value_font)
        pop_w = c.text_width(pop_str, value_font) if pop_str != None else 0
        x0 = round_int(cx - (temp_w + pop_w) / 2.0)
        c.text(temp_str.upper(), x0, 24, font = value_font, color = temp_col, align = "left")
        if pop_str != None:
            c.text(pop_str, x0 + temp_w, 24, font = value_font, color = "#3399FF", align = "left")

    draw_page_edges(c, left = False)

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

# Merged from the former separate lightning/lightning2 pages (GDN caps an
# app at 8 pages - this freed a slot for the rainfall/rainfall2 split
# instead). Strikes-last-hour and strikes-last-3hr got folded onto one
# row - 5 full "4x5" rows don't fit a 24-row content band (5x6=30), while
# 4 rows fit it exactly (4x6=24) with zero clipping or overlap.
STRIKE_RECENT_MAX_MIN = 30

def lightning(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    obs_resp = fetch_observation(station["token"], station["station_id"])
    if obs_resp["status_code"] != 200:
        draw_error(c, "station error")
        return

    obs_list = obs_resp["json"].get("obs", [])
    if len(obs_list) == 0:
        draw_error(c, "no data")
        return
    obs = obs_list[0]

    fc_resp = fetch_better_forecast(station["token"], station["station_id"])
    cur = fc_resp["json"].get("current_conditions", {}) if fc_resp["status_code"] == 200 else {}

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(obs.get("timestamp", 0), station["tz_offset_min"])
    draw_header(c, "LIGHTNING", time_str)

    last_epoch = obs.get("lightning_strike_last_epoch", None)
    distance_km = obs.get("lightning_strike_last_distance", None)
    distance_mi = km_to_mi(distance_km) if distance_km != None else None

    minutes_ago = None
    if last_epoch != None:
        minutes_ago = (obs.get("timestamp", 0) - last_epoch) // 60
        if minutes_ago < 1:
            last_str = "JUST NOW"
        elif minutes_ago < 60:
            last_str = str(minutes_ago) + " MIN AGO"
        elif minutes_ago < 2880:
            last_str = str(minutes_ago // 60) + " HR AGO"
        else:
            last_str = str(minutes_ago // 1440) + "+ DAYS AGO"
        ping_color = last_strike_color(minutes_ago)
    else:
        last_str = "NONE RECENT"
        ping_color = "#888888"

    if distance_mi != None:
        dist_color = strike_distance_color(distance_mi)
        dist_str = format1(distance_mi) + " MI"
    else:
        dist_color = "#888888"
        dist_str = "N/A"

    if minutes_ago != None and minutes_ago <= STRIKE_RECENT_MAX_MIN:
        # A tree with the bolt drawn some distance away from it (sliding
        # farther right the farther off the strike was) instead of the old
        # radar-ping dot - Tempest only measures strike distance, not
        # direction, so this doesn't pretend to show a direction either.
        draw_tree_strike(c, 3, 20, distance_mi, dist_color)
    else:
        # Nothing struck in the last 30 minutes - a bolt-over-the-tree
        # icon would be a stale/misleading image of an old strike, so show
        # the current weather instead.
        draw_tree(c, 3, 20)
        cond = tempest_icon_to_cond(cur.get("icon"))
        draw_tiny_icon(c, cond, 5, 11, 0.65)

    strikes_1hr = obs.get("lightning_strike_count_last_1hr", None)
    strikes_3hr = obs.get("lightning_strike_count_last_3hr", None)
    if strikes_1hr == None and strikes_3hr == None:
        strikes_str = "N/A"
        strikes_color = "#888888"
    else:
        strikes_str = (str(strikes_1hr) if strikes_1hr != None else "?") + " / " + (str(strikes_3hr) if strikes_3hr != None else "?")
        if strikes_1hr == None:
            strikes_color = "#888888"
        elif strikes_1hr == 0:
            strikes_color = "white"
        else:
            strikes_color = strikes_last_hour_color(strikes_1hr)

    c.text("LAST".upper(), 44, 8, font = "4x5", color = "white", align = "left")
    c.text(last_str.upper(), 126, 8, font = "4x5", color = ping_color, align = "right")

    c.text("DISTANCE".upper(), 44, 16, font = "4x5", color = "white", align = "left")
    c.text(dist_str.upper(), 126, 16, font = "4x5", color = dist_color, align = "right")

    c.text("LAST 1H/3H".upper(), 44, 24, font = "4x5", color = "white", align = "left")
    c.text(strikes_str.upper(), 126, 24, font = "4x5", color = strikes_color, align = "right")

    draw_page_edges(c, left = False)

def find_almanac_time(entries, phen):
    for e in entries:
        if e.get("phen") == phen:
            return e.get("time", None)
    return None

def almanac(c, ctx):
    station = load_station(c, ctx)
    if station == None:
        return

    obs_resp = fetch_observation(station["token"], station["station_id"])
    obs_list = obs_resp["json"].get("obs", []) if obs_resp["status_code"] == 200 else []
    ts = obs_list[0].get("timestamp", 0) if len(obs_list) > 0 else 0

    draw_body_bg(c)
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, "ALMANAC", time_str)

    # USNO wants the LOCAL calendar date (not the UTC one a bare epoch
    # would give) and a decimal-hours tz - same local_epoch//86400 pattern
    # rainfall2's monthly total uses for finding "today" in station time.
    tz_hours = station["tz_offset_min"] / 60.0
    local_epoch = ts + station["tz_offset_min"] * 60
    days_since_epoch = local_epoch // 86400
    yy, mm, dd = civil_from_days(days_since_epoch)
    date_str = str(yy) + "-" + pad_int(mm, 2) + "-" + pad_int(dd, 2)

    resp = fetch_moon_almanac(date_str, station["lat"], station["lon"], tz_hours)
    if resp["status_code"] != 200:
        draw_error(c, "almanac unavailable")
        return

    data = resp["json"].get("properties", {}).get("data", {})
    curphase = data.get("curphase", "")
    fracillum_str = data.get("fracillum", "0%")
    illum_pct = int(fracillum_str.replace("%", "")) if "%" in fracillum_str else 0
    illum_frac = illum_pct / 100.0
    is_waxing = "Waxing" in curphase or curphase == "First Quarter"

    moonrise = find_almanac_time(data.get("moondata", []), "Rise")
    moonset = find_almanac_time(data.get("moondata", []), "Set")
    sunrise = find_almanac_time(data.get("sundata", []), "Rise")
    sunset = find_almanac_time(data.get("sundata", []), "Set")

    sun_rise_str = hhmm24_to_12h_compact(sunrise)
    sun_set_str = hhmm24_to_12h_compact(sunset)
    moon_rise_str = hhmm24_to_12h_compact(moonrise)
    moon_set_str = hhmm24_to_12h_compact(moonset)

    # SUN block on the left (icon, rise time beside it, set time stacked
    # underneath - an up-arrow/down-arrow labels which is which now that
    # they're stacked instead of side by side) and a MOON block to its
    # right using the same pattern, but with the real phase-accurate disk
    # (draw_moon_phase) instead of a generic moon icon. Phase name and
    # illumination sit on their own row underneath, right-aligned so the
    # line ends flush with the page's right edge under the moon block.
    draw_big_sun(c, 4, 9, 0.75)
    draw_almanac_block(c, 21, 9, sun_rise_str, sun_set_str, "amber")

    draw_moon_phase(c, 68, 15, 7, illum_frac, is_waxing, "#EEEEEE", "#12122a")
    draw_almanac_block(c, 83, 9, moon_rise_str, moon_set_str, "#AACCFF")

    header_str = (curphase.upper() if curphase else "UNKNOWN") + "  " + str(illum_pct) + "%"
    header_font = fit_font(c, header_str, ["4x5", "picopixel"], 124)
    c.text(header_str, 126, 25, font = header_font, color = "white", align = "right")

    draw_page_edges(c, left = False)
