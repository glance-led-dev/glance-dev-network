# Tempest WX Graphic (192x32)
#
# Live conditions from your own WeatherFlow Tempest station (free personal
# access token from tempestwx.com > Settings > Data Authorizations), drawn as
# full-bleed graphics - no title bars, every page uses all 32 rows:
#
#   1 now     a live sky scene: the sky follows the real time of day, the sun
#             and moon ride their real arcs, clouds / rain / snow / fog /
#             lightning follow the conditions, and the horizon matches where
#             the station is (farm, houses, town or city, from the US Census
#             geocoder's population density for the station's ZIP). Big
#             temperature, conditions, today's real high / low with times,
#             heat index / wind chill (NWS formulas) when one applies.
#   2 air     humidity, dew point (with a comfort word), pressure + trend, UV
#   3 wind    wind rose of today's directions, speed, direction, the Beaufort
#             term (GENTLE / BREEZE), gust, today's high gust, and the last
#             4 hours as 15-minute bars (average + top gust; station readings
#             only - no forecast)
#   4 rain    a 2-inch rain gauge, today's rain and minutes of rain, a 24-hour
#             rain + lightning timeline with today's strike count, last hour /
#             yesterday / month / rain days / last strike - becomes a 3-hour
#             lightning strike map (STORM MODE) while a strike within 10 miles
#             has happened in the last 30 minutes (NWS safety rules)
#   5 today   24-hour temperature curve: measured so far, then the forecast
#             eased in from the current reading; high / low labels
#   6 hourly  next 8 hours with rain chance (WeatherFlow's own forecast)
#   7 forecast  4 NWS-style 12-hour periods (this afternoon / tonight / Mon /
#             Mon night) from WeatherFlow's hourly forecast (FORECAST_PERIODS)
#   8 sky     the sun's arc and the moon at its real position and phase,
#             sunrise / sunset / daylight and its change vs yesterday, moon
#             rise / set (USNO), the phase name and the next new / quarter /
#             full moon, and a horizon matching the Now page's scene
#
# NWS alerts (US): 57 hand-picked event types (ALERT_STYLE), ranked by the
# NWS hazard-map priority. A warning (or civil emergency) takes over page 1,
# names the next active alert, and puts hazard stripes on the edges of pages
# 2-8; watches / advisories / statements ride a strip along page 1's bottom.
# Station health: page 1 also flags a station that's gone offline (no report
# for 30+ min) or a low battery.
#
# Data: WeatherFlow REST (station obs, device obs history, better_forecast),
# USNO (moon), NWS (alerts), US Census geocoder (scene) - all keyless beyond
# the user's own Tempest token. Pressure is WeatherFlow's processed sea-level
# value (some stations' raw sensor reads badly off). Everything is computed in
# F / mph / inches; the Units setting only converts what's printed.
#
# Typing DEMO as the token shows canned data for catalog previews.

CARDINAL_NAMES = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

WEEKDAY_NAMES = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

MONTH_NAMES = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

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

def format_minutes(minutes):
    if minutes < 60:
        return str(minutes) + " MIN"
    return str(minutes // 60) + "H " + pad_int(minutes % 60, 2) + "M"

def local_day_start(ts, tz_offset_min):
    return ts - ((ts + tz_offset_min * 60) % 86400)

# Setup / problem screen: the night-sky scene with two lines of plain words,
# instead of a bare error - it's the first thing a new owner sees.
def draw_error(c, line1, line2 = ""):
    top, bot = SKY_NIGHT
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix(top, bot, min(y, 27) / 27.0)))
    for st in STARS:
        c.pixel(st[0], st[1], "#c8d0ff" if (st[0] + st[1]) % 3 else "#6f78a8")
    draw_ground(c, False, "suburb")
    f1 = fit_font(c, line1, ["5x7", "4x5"], 140)
    stext(c, line1, 4, 6, f1, "white")
    if line2 != "":
        f2 = fit_font(c, line2, ["4x5", "picopixel"], 140)
        stext(c, line2, 4, 16, f2, "#AACCFF")

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

# ---------- shared station load ----------

def load_station(c, ctx):
    station, err = resolve_station(ctx)
    if station == None:
        if err == "no token":
            draw_error(c, "ENTER YOUR TEMPEST TOKEN", "IN SETTINGS - OR TRY DEMO")
        elif err == "no stations":
            draw_error(c, "NO STATION ON THIS TOKEN", "ADD ONE IN THE TEMPEST APP")
        elif err == "unreachable":
            draw_error(c, "CAN'T REACH WEATHERFLOW", "TRYING AGAIN SHORTLY")
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

# The Now page's hero temperature: the whole degrees huge, then the degree
# mark at the top and the tenths smaller underneath it.
def hero_temp(c, x, y, f, color, shadow):
    s = format1(f)
    parts = s.split(".")
    ip = parts[0]
    fp = parts[1] if len(parts) > 1 else "0"
    w = c.text_width(ip, "16x20")
    fx = x + w + 3
    # full dark outline (all 8 directions) so the color reads on any sky
    for o in OUTLINE8:
        draw_deg(c, fx + 4 + o[0], y + o[1], shadow, True)
    c.rect(fx - 1, y + 17, fx + 2, y + 20, fill = shadow)
    c.text_stroke(ip, x, y, font = "16x20", color = color, stroke = shadow, align = "left")
    c.text_stroke(fp, fx + 3, y + 8, font = "8x12", color = color, stroke = shadow, align = "left")
    draw_deg(c, fx + 4, y, color, True)
    c.rect(fx, y + 18, fx + 1, y + 19, fill = color)
    return w + 3 + 3 + c.text_width(fp, "8x12")

# The big temperature's color: the normal temperature scale, except the cold
# end fades toward ice-white (from 40F down, fully icy by 15F) so a cold
# reading never sinks into a blue daytime sky.
ICE = (225, 240, 255)

def hero_color(f):
    base = gradient_at(TEMP_RAMP, f)
    if f >= 40:
        return hexc(base)
    return hexc(mix(base, ICE, clamp((40.0 - f) / 25.0, 0.0, 1.0) * 0.8))

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

BG_TOP = (10, 16, 46)

BG_BOT = (3, 5, 18)

def draw_bg(c):
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix(BG_TOP, BG_BOT, y / 31.0)))

def tag(c, s, x = 1, y = 1, align = "left"):
    c.text(s, x, y, font = "picopixel", color = "#7f8fb8", align = align)

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

STARS = [(7, 3), (19, 9), (31, 2), (44, 12), (53, 5), (66, 15), (78, 3), (90, 9), (101, 2), (113, 13), (124, 6), (137, 2), (146, 11), (158, 4), (169, 14), (181, 7), (188, 2), (12, 17), (60, 19), (95, 18), (130, 19), (175, 18), (40, 6), (84, 14), (151, 16)]

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

# The Tempest itself, as it really looks: a flat rain cap, a small gap, the
# white body with its dark sensor window, on a thin white mast. top = the
# cap's row; the mast runs down to base (skipped when base <= the body).
def draw_tempest_unit(c, px, top, is_day):
    white = "#eef2f6" if is_day else "#6a707a"
    shade = "#c4ccd6" if is_day else "#4e545e"
    c.line(px - 2, top, px + 2, top, white)
    c.pixel(px, top + 1, shade)
    c.rect(px - 1, top + 2, px + 1, top + 5, fill = white)
    c.line(px - 1, top + 2, px + 1, top + 2, shade)
    c.pixel(px, top + 3, "#2a3038")
    c.pixel(px, top + 4, "#2a3038")

def draw_tempest_pole(c, px, top, base, is_day):
    if base > top + 6:
        c.line(px, top + 6, px, base, "#d8dee6" if is_day else "#585e68")
    draw_tempest_unit(c, px, top, is_day)

# Photo-1 style mount: a wooden post with the white arm curving up and out.
def draw_tempest_post(c, px, is_day):
    wood = "#5a3a26" if is_day else "#1c120c"
    arm = "#d8dee6" if is_day else "#585e68"
    c.rect(px, 19, px + 1, 28, fill = wood)
    c.pixel(px - 1, 20, arm)
    c.pixel(px - 2, 19, arm)
    c.pixel(px - 3, 18, arm)
    c.line(px - 3, 15, px - 3, 17, arm)
    draw_tempest_unit(c, px - 3, 9, is_day)

def draw_house(c, hx, is_day, roof = None):
    body = "#3b2a22" if is_day else "#120c0a"
    c.rect(hx, 22, hx + 9, 28, fill = body)
    c.fill_triangle(hx - 1, 22, hx + 4, 17, hx + 10, 22, roof if roof != None else ("#5a2a22" if is_day else "#1a0e0c"))
    c.rect(hx + 2, 24, hx + 3, 25, fill = "#ffcc55" if not is_day else "#9fc6e8")
    c.rect(hx + 6, 24, hx + 7, 28, fill = "#20140f")

def draw_tree(c, x, is_day):
    c.line(x, 23, x, 28, "#4a3220" if is_day else "#120c08")
    c.fill_circle(x, 21, 3, "#2f7a3a" if is_day else "#0c2012")

def draw_rural(c, is_day):
    # fence, red barn with a gambrel roof, and a silo
    post = "#8a7050" if is_day else "#2a2018"
    for x in range(140, 158, 4):
        c.line(x, 25, x, 28, post)
    c.line(140, 26, 157, 26, post)
    barn = "#a8322a" if is_day else "#2a0e0c"
    trim = "#f0e8e0" if is_day else "#3a3430"
    c.rect(158, 21, 172, 28, fill = barn)
    c.fill_triangle(157, 21, 160, 17, 165, 17, barn)
    c.fill_triangle(165, 17, 170, 17, 173, 21, barn)
    c.rect(160, 17, 170, 21, fill = barn)
    c.line(160, 17, 170, 17, trim)
    c.rect(163, 23, 167, 28, fill = trim)
    c.line(163, 23, 167, 28, barn)
    c.line(167, 23, 163, 28, barn)
    silo = "#b8c0c8" if is_day else "#2a2e34"
    c.rect(175, 13, 179, 28, fill = silo)
    c.fill_circle(177, 13, 2, "#d8dde4" if is_day else "#3a3e44")
    draw_tempest_post(c, 186, is_day)

def draw_suburb(c, is_day):
    draw_house(c, 146, is_day, "#2a3a5a" if is_day else "#0e1220")
    draw_tree(c, 160, is_day)
    draw_house(c, 165, is_day)
    # mounted on the roof peak of the right-hand house
    draw_tempest_pole(c, 169, 8, 17, is_day)

def draw_town(c, is_day):
    shades = ["#6a4a3a", "#4a5a6a", "#7a6a4a"] if is_day else ["#140e0c", "#0e1218", "#16140e"]
    win = "#9fc6e8" if is_day else "#ffcc55"
    tops = [21, 19, 22]
    for k in range(3):
        x0 = 142 + k * 8
        c.rect(x0, tops[k], x0 + 7, 28, fill = shades[k])
        c.rect(x0 + 1, tops[k], x0 + 6, tops[k], fill = "#2a2a2a" if is_day else "#060606")
        for wy in range(tops[k] + 2, 26, 3):
            c.pixel(x0 + 2, wy, win)
            c.pixel(x0 + 5, wy, win)
    # church with steeple and cross
    ch = "#e8e4dc" if is_day else "#24221e"
    c.rect(167, 20, 177, 28, fill = ch)
    c.fill_triangle(166, 20, 172, 16, 178, 20, "#6a6a72" if is_day else "#16161a")
    c.rect(170, 12, 174, 17, fill = ch)
    c.fill_triangle(170, 12, 172, 7, 174, 12, "#6a6a72" if is_day else "#16161a")
    c.line(172, 4, 172, 7, "#c8a040")
    c.line(171, 5, 173, 5, "#c8a040")
    c.rect(171, 24, 173, 28, fill = "#4a3020" if is_day else "#0c0806")
    c.pixel(172, 14, "#ffcc55" if not is_day else "#4a5a6a")
    draw_tempest_pole(c, 185, 13, 28, is_day)

CITY_TOWERS = [(140, 6, 22), (147, 5, 20), (153, 7, 21), (161, 6, 12), (168, 8, 7), (177, 6, 14), (184, 7, 10)]

def draw_city(c, is_day):
    for k in range(len(CITY_TOWERS)):
        x0, w, top = CITY_TOWERS[k]
        body = ["#3a4a64", "#4a5670", "#34405a"][k % 3] if is_day else ["#0c1220", "#101828", "#0a0f1c"][k % 3]
        c.rect(x0, top, x0 + w - 1, 28, fill = body)
        for wy in range(top + 2, 27, 2):
            for wx in range(x0 + 1, x0 + w - 1, 2):
                if is_day:
                    if (wx + wy) % 4 == 0:
                        c.pixel(wx, wy, "#8fb4d8")
                elif (wx * 7 + wy * 3 + k) % 5 < 2:
                    c.pixel(wx, wy, "#ffd060")
    # the Tempest on the tallest roof, with an antenna light
    draw_tempest_pole(c, 172, 0, 6, is_day)
    c.pixel(169, 6, "#ff3030")

def draw_ground(c, is_day, place = "suburb"):
    col = "#1f4a2a" if is_day else "#08160d"
    hi = "#2f6a3a" if is_day else "#0f2416"
    for x in range(c.width):
        h = 27 + round_int(1.3 * math.sin(x / 15.0) + 0.8 * math.sin(x / 6.1 + 1.0))
        c.line(x, h, x, 31, col)
        c.pixel(x, h, hi)

    # What sits on the horizon depends on where the station is: a farm, a
    # neighborhood, a small town, or a city skyline - with the Tempest on its
    # pole (or on the tallest roof) in every one.
    if place == "rural":
        draw_rural(c, is_day)
    elif place == "town":
        draw_town(c, is_day)
    elif place == "city":
        draw_city(c, is_day)
    else:
        draw_suburb(c, is_day)

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

def draw_sky_scene(c, d):
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
        c.rect(0, y, c.width - 1, y, fill = hexc(mix(top, bot, min(y, 27) / 27.0)))

    if not is_day and gray < 0.5:
        for s in STARS:
            c.pixel(s[0], s[1], "#c8d0ff" if (s[0] + s[1]) % 3 else "#6f78a8")

    sx, sy = arc_xy(t, 126, c.width - 5, 25, 18)

    # clouds
    cloud = "#F2F6FA" if is_day else "#3c4458"
    if gray > 0:
        cloud = "#AEB6C2" if is_day else "#2c3240"
        if gray >= 0.75:
            cloud = "#7c8492" if is_day else "#252a36"
    puffs = []
    if cond in ["PartlyCloudy", "PartlyCloudyNight"]:
        puffs = [(140, 11, 16), (180, 6, 18)]
    elif gray > 0:
        puffs = [(14, 4, 22), (48, 6, 26), (86, 3, 22), (120, 6, 26), (158, 4, 24), (186, 6, 20)]
    for p in puffs:
        draw_puff(c, p[0], p[1], p[2], cloud)

    if gray < 0.5:
        m = moon_now(d)
        if m != None and m[0] != None:
            mx, my = arc_xy(m[0], 126, c.width - 5, 25, 18)
            draw_moon_phase(c, mx, my, 3, m[1], m[2], "#E8ECF8" if not is_day else "#F4F6FA", hexc(mix(top, bot, my / 27.0)))
        if is_day:
            glow = hexc(mix(mix(top, bot, sy / 27.0), (255, 220, 120), 0.45))
            c.fill_circle(sx, sy, 5, glow)
            c.fill_circle(sx, sy, 3, "#FFE070" if pal != SKY_GOLD else "#FFB040")

    if cond in ["Rain", "Thunderstorm", "Sleet"]:
        # how hard it's raining sets how many streaks and how long they are
        n = [40, 14, 24, 40, 60, 85, 110][rain_level]
        ln = 3 if rain_level >= 4 else 2
        for i in range(n):
            x = (i * 37 + 11 + (i // 40) * 5) % c.width
            y = 10 + (i * 7 + (i // 40) * 3) % 14
            c.line(x, y, x - 1, y + ln, "#7fb4ff" if rain_level < 5 else "#a8ccff")
    if far_bolt:
        # a storm close by but not here: a small bolt low over the horizon
        bx = 118
        c.line(bx + 2, 13, bx, 17, "#E8D870")
        c.line(bx, 17, bx + 3, 17, "#E8D870")
        c.line(bx + 3, 17, bx + 1, 21, "#E8D870")
    if cond == "Snow":
        for i in range(50):
            c.pixel((i * 41 + 5) % c.width, 9 + (i * 11) % 17, "white")
    if cond == "Thunderstorm":
        # in the open sky left of the scenery (every scene's buildings start
        # at x 140), so the bolt never hits a house
        bx = 124
        c.line(bx + 3, 10, bx, 16, "#FFF27A")
        c.line(bx, 16, bx + 4, 16, "#FFF27A")
        c.line(bx + 4, 16, bx + 1, 23, "#FFF27A")
    if cond == "Fog":
        for y in [12, 16, 20, 24]:
            c.line(0, y, c.width - 1, y, "#9aa2ae")

    # (DEMO testing only) a "place" input forces a scene
    place = demo_opt(d, "place")
    if place == "":
        place = station_place(d["station"])
    draw_ground(c, is_day, place)
    return is_day, cond, words_now

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

def now_page(c, ctx):
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
        draw_alert_takeover(c, d, alert)
        return
    is_day, cond, words_now = draw_sky_scene(c, d)
    sh = "#06102a"
    w = hero_temp(c, 4, 2, tdisp(d, d["temp"]), hero_color(d["temp"]), sh)
    words = words_now
    if words == None:
        words = d["cur"].get("conditions", None)
        words = words.upper() if words else COND_WORDS.get(cond, "")
    tx = 4 + w + 6
    stext(c, words, tx, 2, "5x7", "white", shadow = sh)
    # the station's ACTUAL high / low so far (exact minute); the Today page
    # carries the forecast-aware day high / low
    hi, lo, hi_t, lo_t = station_hilo(d, day_obs_rows(d)[1])
    x = tx
    if hi != None:
        hw = when_label(hi_t, d)
        lw = when_label(lo_t, d)
        stext(c, "H", x, 12, "4x5", "#FFD08A", shadow = sh)
        stext(c, hw, x, 18, "picopixel", "#FFE8C0", shadow = sh)
        x += max(5 + temp_text(c, x + 5, 12, tdisp(d, hi), "4x5", "#FFD08A", shadow = sh, dec = True), c.text_width(hw, "picopixel")) + 5
        stext(c, "L", x, 12, "4x5", "#9CC8FF", shadow = sh)
        stext(c, lw, x, 18, "picopixel", "#D0E4FF", shadow = sh)
        x += max(5 + temp_text(c, x + 5, 12, tdisp(d, lo), "4x5", "#9CC8FF", shadow = sh, dec = True), c.text_width(lw, "picopixel")) + 5
    # heat index / wind chill (NWS formulas) only when one actually applies,
    # stacked like H / L: the value, with its name small underneath
    ap = apparent(d)
    if ap != None:
        label, val = ap
        acol = "#FF9050" if label == "HEAT INDEX" else "#80D8FF"
        temp_text(c, x, 12, tdisp(d, val), "4x5", acol, shadow = sh, dec = True)
        stext(c, label, x, 18, "picopixel", acol, shadow = sh)

    # the clock, then the station's name, along the ground
    clock = epoch_to_local_hhmm(d["ts"], d["tz"])
    gcol = "white" if is_day else "#8aa890"
    stext(c, clock, 4, 26, "4x5", gcol, shadow = "#06140a")
    name = (d["station"].get("name", "") or "").upper()
    nx = 4 + c.text_width(clock, "4x5") + 6
    if name != "" and nx + c.text_width(name, "picopixel") < 150:
        stext(c, name, nx, 26, "picopixel", "#c8e0c8" if is_day else "#6a8a70", shadow = "#06140a")

    alert_b = alert
    if alert_b != None:
        bcol = ALERT_STYLE[alert_b[0]][0]
        draw_banner(c, bcol, alert_b[0].upper() + "  " + until_text(alert_b[1], d))
    else:
        h = station_health(d)
        if h != None:
            draw_health_banner(c, d, h)

# ---------- today's temperature curve ----------

def when_label(epoch, d):
    local = epoch + d["tz"] * 60
    h = (local % 86400) // 3600
    m = (local % 3600) // 60
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    ap = "A" if h < 12 else "P"
    if epoch > d["ts"]:
        return str(h12) + ap
    return str(h12) + ":" + pad_int(m, 2) + ap

# A temperature with its time beside it (time smaller and dimmer), centered
# on cx but kept inside the page.
def temp_when(c, cx, y, f, when, color, when_color):
    s = format1(f)
    tw = num_width(c, s, "4x5") + 4
    ww = c.text_width(when, "picopixel")
    total = tw + 2 + ww
    x0 = clamp(cx - total // 2, 4, c.width - 4 - total)
    temp_text(c, x0, y, f, "4x5", color, dec = True)
    c.text(when, x0 + tw + 2, y, font = "picopixel", color = when_color, align = "left")

def boxes_overlap(a, b):
    return a[0] <= b[2] and b[0] <= a[2] and a[1] <= b[3] and b[1] <= a[3]

# A temp_when label centered near column cx, as close to it as it can go
# while staying clear of the curve (tops = the curve's top row per column)
# and of the given boxes. Returns the box it took (with a 1px margin).
def place_temp_when(c, tops, boxes, cx, f, when, color, when_color):
    W = c.width
    s = format1(f)
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

# The day as W columns, midnight to midnight: measured temps so far (the
# station's own readings), then the hourly forecast for the rest of the day.
# hi / lo are the day's high and low for the Today graph - the actual extreme
# readings so far combined with whatever the forecast still expects (a
# forecast time is a whole hour, an actual one has minutes).
def day_curve(d, W):
    day_start, rows = day_obs_rows(d)
    span = 86400.0 / W
    sums = [0.0] * W
    cnts = [0] * W
    hi, lo, hi_t, lo_t = station_hilo(d, rows)
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
        c.line(i, y + 1, i, 26, dim_hex(col, 0.42 if past else 0.16))
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
        cond = tempest_icon_to_cond(h.get("icon"))
        draw_mini_icon(c, cond, cx - 6, 9)
        f = c_to_f(h.get("air_temperature", 0.0))
        temp_text_centered(c, cx, 20, tdisp(d, f), "5x7", tcol(f))
        pop = h.get("precip_probability", 0) or 0
        if pop > 0:
            bw = round_int((cw - 8) * pop / 100.0)
            c.rect(x0 + 4, 29, x0 + cw - 4, 30, fill = "#14204a")
            c.rect(x0 + 4, 29, x0 + 4 + max(bw, 1), 30, fill = "#3399FF")



# ---------- forecast periods (This Afternoon / Tonight / Mon / Mon Night) ----------
# NWS-style 12-hour periods built from WeatherFlow's hourly forecast: day
# periods run 6 AM - 6 PM (with the high), nights 6 PM - 6 AM (with the low).
# Rain chance = the highest hourly chance in the period; the icon and words =
# the most significant weather in it, where anything "likely" outranks any
# "possibly-" hour (a possible-only period gets a plain cloud and CHC words).

RAINDROP_BITMAP = [
    [0, 0, 1, 0, 0],
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
]

PERIOD_RANK = {"Thunderstorm": 9, "Snow": 8, "Sleet": 7, "Rain": 6, "Fog": 5, "Windy": 4, "Clouds": 3, "PartlyCloudy": 2, "Clear": 1}

PRECIP_CONDS = ["Thunderstorm", "Snow", "Sleet", "Rain"]

# shorter words for narrow columns
PERIOD_SHORT = {"PTLY CLOUDY": "PT CLOUDY", "T-STORMS": "TSTMS", "CHC T-STORMS": "CHC TSTMS"}

PERIOD_WORDS = {
    "Thunderstorm": "T-STORMS",
    "Snow": "SNOW",
    "Sleet": "SLEET",
    "Rain": "RAIN",
    "Fog": "FOG",
    "Windy": "WINDY",
    "Clouds": "CLOUDY",
    "PartlyCloudy": "PTLY CLOUDY",
    "Clear": "SUNNY",
}

def base_cond(icon):
    # the condition an icon names, ignoring "possibly-" and day / night
    if icon == None:
        return "Clouds"
    ic = icon[len("possibly-"):] if icon.startswith("possibly-") else icon
    cond = tempest_icon_to_cond(ic)
    if cond == "PartlyCloudyNight":
        return "PartlyCloudy"
    if cond == "ClearNight":
        return "Clear"
    return cond

def forecast_periods(d, today_hi, n = 4):
    tz = d["tz"]
    ts = d["ts"]
    day0 = local_day_start(ts, tz)
    today_n = (day0 + tz * 60) // 86400
    h = ((ts + tz * 60) % 86400) // 3600
    spans = []
    if h < 6:
        spans.append((ts, day0 + 6 * 3600, "OVERNIGHT", False))
    elif h < 18:
        spans.append((ts, day0 + 18 * 3600, "TODAY" if h < 12 else "THIS AFT", True))
    else:
        spans.append((ts, day0 + 30 * 3600, "TONIGHT", False))
    for _ in range(n - 1):
        st = spans[-1][1]
        is_day = ((st + tz * 60) % 86400) // 3600 == 6
        dn = (st + tz * 60) // 86400
        wd = WEEKDAY_NAMES[(dn + 4) % 7]
        if is_day:
            name = "TODAY" if dn == today_n else wd
        else:
            name = "TONIGHT" if dn == today_n else wd + " NIGHT"
        spans.append((st, st + 12 * 3600, name, is_day))

    out = []
    for k in range(len(spans)):
        st, en, name, is_day = spans[k]
        temps = []
        pop = 0
        best = None
        best_rank = -1
        best_pp = None
        lo_t = st if k > 0 else ts - 3599
        for hr in d["hourly"]:
            t = hr.get("time", 0)
            # a night's low counts through 7 AM (the coldest hour is often
            # right around 6), like the NWS does
            if not is_day and t >= en and t <= en + 3600 and hr.get("air_temperature", None) != None:
                temps.append(c_to_f(hr["air_temperature"]))
            if t < lo_t or t >= en:
                continue
            if hr.get("air_temperature", None) != None:
                temps.append(c_to_f(hr["air_temperature"]))
            pop = max(pop, hr.get("precip_probability", 0) or 0)
            ic = hr.get("icon", None)
            cond = base_cond(ic)
            poss = ic != None and ic.startswith("possibly")
            r = PERIOD_RANK.get(cond, 3) + (0 if poss else 100)
            if r > best_rank:
                best_rank = r
                best = (cond, poss)
            if poss and cond in PRECIP_CONDS and (best_pp == None or PERIOD_RANK[cond] > PERIOD_RANK[best_pp]):
                best_pp = cond
        if k == 0:
            # the period under way also counts the current reading / sky
            temps.append(d["temp"])
            if best == None:
                best = (base_cond(d["cur"].get("icon", None)), (d["cur"].get("icon", "") or "").startswith("possibly"))
        if len(temps) == 0 or best == None:
            break
        if is_day:
            val = max(temps)
            if k == 0 and today_hi != None and name != "OVERNIGHT":
                val = today_hi
        else:
            val = min(temps)
        # a 30%+ chance of rain (or storms / snow) says so even when most of
        # the period is just cloudy: "CHC RAIN"
        if not best[1] and best[0] not in PRECIP_CONDS and pop >= 30 and best_pp != None:
            best = (best_pp, True)
        cond, poss = best
        words = PERIOD_WORDS.get(cond, "CLOUDY")
        icon_cond = cond
        if poss:
            icon_cond = "Clouds"
            words = "CHC " + words
        elif not is_day and cond == "Clear":
            words = "CLEAR"
        if not is_day and icon_cond == "Clear":
            icon_cond = "ClearNight"
        if not is_day and icon_cond == "PartlyCloudy":
            icon_cond = "PartlyCloudyNight"
        out.append({"name": name, "day": is_day, "temp": val, "pop": pop, "cond": icon_cond, "words": words})
    return out

FORECAST_PERIODS = 4

def forecast_page(c, ctx):
    n = FORECAST_PERIODS
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    W = c.width
    day_start, vals, last_past, hi, lo, hi_t, lo_t = day_curve(d, W)
    pers = forecast_periods(d, hi, n)
    cw = W // n
    xoff = (W - cw * n) // 2
    for i in range(min(n, len(pers))):
        p = pers[i]
        x0 = xoff + i * cw
        cx = x0 + cw // 2
        if i > 0:
            c.line(x0, 2, x0, 29, "#18214a")
        nm = p["name"]
        c.text(nm, cx, 1, font = fit_font(c, nm, ["4x5", "picopixel"], cw - 3), color = "#FFD08A" if i == 0 else "white", align = "center")
        tcolr = tcol(p["temp"]) if p["day"] else "#9CC8FF"
        pc = p["pop"]
        # icon, then the high (day) or low (night, always light blue); with 4
        # periods there's room to label them HI / LO
        if n <= 4:
            draw_mini_icon(c, p["cond"], x0 + 5, 11)
            tx = x0 + 21
            c.text("HI" if p["day"] else "LO", tx, 10, font = "picopixel", color = "#7f8fb8", align = "left")
            temp_text(c, tx + 9, 8, tdisp(d, p["temp"]), "5x7", tcolr)
        else:
            draw_mini_icon(c, p["cond"], x0 + 3, 11)
            tx = x0 + 17
            temp_text(c, tx + 1, 8, tdisp(d, p["temp"]), "5x7", tcolr)
        # rain chance (nothing at all when it's 0%)
        if pc > 0:
            c.bitmap(RAINDROP_BITMAP, tx, 17, "#3399FF")
            c.text(str(pc) + "%", tx + 7, 17, font = "4x5", color = "#7fb4ff", align = "left")
        w = p["words"]
        if c.text_width(w, "picopixel") > cw - 3:
            w = PERIOD_SHORT.get(w, w)
        c.text(w, cx, 25, font = fit_font(c, w, ["4x5", "picopixel"], cw - 3), color = "#a8b4d8", align = "center")

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

def wind_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    day_start, rows = day_obs_rows(d)
    sect_sum = [0.0] * 16
    sect_n = [0] * 16
    W = c.width
    # the graph: 16 bars x 4px, right-aligned 4px from the edge
    nb = 16
    pitch = 4
    gx0 = W - 4 - nb * pitch + 1
    best = 0.0
    for r in rows:
        if r[2] == None or r[4] == None:
            continue
        s = compass_index(r[4])
        sect_sum[s] += r[2]
        sect_n[s] += 1
        if r[3] != None and r[3] > best:
            best = r[3]

    cx = 18
    cy = 16
    R = 14
    c.circle(cx, cy, R, "#1c2650")
    # inner ring = exactly half the top direction's wind (petals are scaled so
    # today's biggest direction touches the outer ring)
    c.circle(cx, cy, R // 2, "#18214a")
    mx = max(sect_sum + [0.001])
    for s in range(16):
        if sect_sum[s] <= 0:
            continue
        L = max(1.0, R * sect_sum[s] / mx)
        ang = s * 22.5
        a0 = math.radians(ang - 6)
        a1 = math.radians(ang + 6)
        mean_mph = mps_to_mph(sect_sum[s] / sect_n[s])
        col = wind_color(mean_mph)
        if col == "amber":
            col = "#FFBF00"
        fill_triangle(c, cx, cy, cx + L * math.sin(a0), cy - L * math.cos(a0), cx + L * math.sin(a1), cy - L * math.cos(a1), col)
    c.pixel(cx, cy - R, "white")

    speed = d["cur"].get("wind_avg", 0.0) or 0.0
    if demo_opt(d, "windmph") != "":
        speed = float(demo_opt(d, "windmph"))
        d["cur"] = dict(d["cur"])
        d["cur"]["wind_gust"] = speed * 1.5
    deg = d["cur"].get("wind_direction", 0) or 0
    gust = d["cur"].get("wind_gust", 0.0) or 0.0
    col = "white" if speed == 0 else wind_color(speed)
    if col == "amber":
        col = "#FFBF00"
    if speed > 0:
        rad = math.radians(deg)
        c.line(cx, cy, round_int(cx + (R - 1) * math.sin(rad)), round_int(cy - (R - 1) * math.cos(rad)), "white")
    c.fill_circle(cx, cy, 1, "white")

    s = str(round_int(spd(d, speed)))
    c.text(s, 38, 4, font = "16x20", color = col, align = "left")
    sw = c.text_width(s, "16x20")
    # top line: direction + unit; under it the Beaufort term in the larger
    # font, one word per line (GENTLE / BREEZE)
    bx = 38 + sw + 3
    ux = bx
    if round_int(speed) > 0:
        dn = CARDINAL_NAMES[compass_index(deg)]
        c.text(dn, bx, 2, font = "5x7", color = "white", align = "left")
        ux = bx + c.text_width(dn, "5x7") + 3
    c.text(spd_unit(d), ux, 4, font = "4x5", color = "#8fa0cc", align = "left")
    bw = beaufort(speed) if round_int(speed) > 0 else "CALM"
    parts = bw.split(" ")
    room = gx0 - 3 - bx
    bf = "5x7"
    for wpart in parts:
        if c.text_width(wpart, "5x7") > room:
            bf = "4x5"
    for k in range(len(parts)):
        c.text(parts[k], bx, 10 + k * 8, font = bf, color = col, align = "left")
    c.text("GUST " + str(round_int(spd(d, gust))), 38, 26, font = "4x5", color = wind_color(gust) if gust > 0 else "white", align = "left")
    # today's high gust can't be below the gust happening right now (the
    # device history lags the latest observation by a few minutes)
    hi_g = max(mps_to_mph(best), gust)
    c.text("HI " + str(round_int(spd(d, hi_g))), 38 + 44, 26, font = "4x5", color = wind_color(hi_g) if hi_g > 0 else "white", align = "left")

    # the graph: the last 6 hours as 12 half-hour candles - body up to the
    # average wind (in its wind color), a thin wick down to the lull, and a
    # white cap at that half hour's top gust. Today's readings only, so
    # before 6 AM the slots before midnight stay empty.
    ts = d["ts"]
    nb = 12
    pitch = 5
    bs = 1800
    x0 = W - 4 - nb * pitch + 1
    t0 = ts - ((ts + d["tz"] * 60) % bs) - (nb - 1) * bs
    a_sum = [0.0] * nb
    a_n = [0] * nb
    g_max = [0.0] * nb
    l_min = [99.0] * nb
    for r in rows:
        if r[2] == None:
            continue
        k = (r[0] - t0) // bs
        if k < 0 or k >= nb:
            continue
        a_sum[k] += r[2]
        a_n[k] += 1
        if r[3] != None and r[3] > g_max[k]:
            g_max[k] = r[3]
        if r[1] != None and r[1] < l_min[k]:
            l_min[k] = r[1]
    # height scaled to the window's top gust (at least 10 mph, so a light
    # breeze doesn't look like a gale)
    top = gust
    for k in range(nb):
        top = max(top, mps_to_mph(g_max[k]))
    gmax = max(top * 1.1, 10.0)
    yt = 8
    yb = 24
    for k in range(nb):
        x = x0 + k * pitch
        c.line(x, yb + 1, x + pitch - 2, yb + 1, "#2a3566")
        if a_n[k] == 0:
            continue
        av = mps_to_mph(a_sum[k] / a_n[k])
        gv = max(mps_to_mph(g_max[k]), av)
        lv = min(mps_to_mph(l_min[k]), av) if l_min[k] < 99.0 else 0.0
        ya = round_int(yb - av / gmax * (yb - yt))
        yg = round_int(yb - gv / gmax * (yb - yt))
        yl = round_int(yb - lv / gmax * (yb - yt))
        cc = safe_col(wind_color(av))
        c.line(x + 1, yg, x + 1, yb, "#3a4680")
        c.line(x + 2, yg, x + 2, yb, "#3a4680")
        if ya <= yb:
            c.rect(x, ya, x + 3, yb, fill = dim_hex(cc, 0.75))
            c.line(x, ya, x + 3, ya, cc)
            c.rect(x + 1, yl, x + 2, yb, fill = dim_hex(cc, 0.40))
        if yg < ya:
            c.line(x, yg, x + 3, yg, "#d8def8")
    # every other clock hour under the candles, NOW at the right
    lab_col = "#55628f"
    c.text("NOW", W - 4, 27, font = "picopixel", color = lab_col, align = "right")
    now_x = W - 4 - c.text_width("NOW", "picopixel") - 3
    for k in range(nb):
        local = t0 + k * bs + d["tz"] * 60
        if local % 3600 != 0:
            continue
        h = (local % 86400) // 3600
        x = x0 + k * pitch
        c.pixel(x + 1, 25, "#2a3566")
        if h % 2 != 0:
            continue
        lab = str(12 if h % 12 == 0 else h % 12) + ("A" if h < 12 else "P")
        if x + c.text_width(lab, "picopixel") < now_x:
            c.text(lab, x, 27, font = "picopixel", color = lab_col, align = "left")
    tag(c, "LAST 6 HOURS", W - 4, 1, "right")

# ---------- almanac math (no web requests) ----------

# Length of daylight (seconds) for the local day containing epoch, from the
# standard sunrise equation (sun's center 0.833 deg below the horizon). Only
# used for the day-to-day CHANGE, so both days come from the same formula.
def day_length_sec(epoch, lat, lon):
    jd = epoch / 86400.0 + 2440587.5
    n = math.floor(jd - 2451545.0 + 0.0008) + 0.0008
    js = n - lon / 360.0
    m = (357.5291 + 0.98560028 * js) % 360.0
    cc = 1.9148 * math.sin(math.radians(m)) + 0.02 * math.sin(math.radians(2 * m)) + 0.0003 * math.sin(math.radians(3 * m))
    lam = (m + cc + 180.0 + 102.9372) % 360.0
    sd = math.sin(math.radians(lam)) * math.sin(math.radians(23.4397))
    cd = math.sqrt(1.0 - sd * sd)
    cw = (math.sin(math.radians(-0.833)) - math.sin(math.radians(lat)) * sd) / (math.cos(math.radians(lat)) * cd)
    if cw <= -1.0:
        return 86400.0
    if cw >= 1.0:
        return 0.0
    return 2.0 * math.degrees(math.acos(cw)) / 360.0 * 86400.0

# The next principal moon phase after epoch: (name, epoch). Meeus,
# Astronomical Algorithms ch. 49 (the main periodic terms - good to a few
# minutes).
MOON_PHASE_NAMES = ["NEW", "FIRST QTR", "FULL", "LAST QTR"]

def moon_phase_jde(k, q):
    t = k / 1236.85
    jde = 2451550.09766 + 29.530588861 * k + 0.00015437 * t * t - 0.00000015 * t * t * t + 0.00000000073 * t * t * t * t
    e = 1.0 - 0.002516 * t - 0.0000074 * t * t
    mm = math.radians(2.5534 + 29.1053567 * k - 0.0000014 * t * t - 0.00000011 * t * t * t)
    mp = math.radians(201.5643 + 385.81693528 * k + 0.0107582 * t * t + 0.00001238 * t * t * t - 0.000000058 * t * t * t * t)
    f = math.radians(160.7108 + 390.67050284 * k - 0.0016118 * t * t - 0.00000227 * t * t * t + 0.000000011 * t * t * t * t)
    om = math.radians(124.7746 - 1.56375588 * k + 0.0020672 * t * t + 0.00000215 * t * t * t)
    s = math.sin
    if q == 0 or q == 2:
        a = -0.4072 if q == 0 else -0.40614
        b = 0.17241 if q == 0 else 0.17302
        cr = (a * s(mp) + b * e * s(mm) + (0.01608 if q == 0 else 0.01614) * s(2 * mp) +
              (0.01039 if q == 0 else 0.01043) * s(2 * f) + (0.00739 if q == 0 else 0.00734) * e * s(mp - mm) -
              (0.00514 if q == 0 else 0.00515) * e * s(mp + mm) + (0.00208 if q == 0 else 0.00209) * e * e * s(2 * mm) -
              0.00111 * s(mp - 2 * f) - 0.00057 * s(mp + 2 * f) + 0.00056 * e * s(2 * mp + mm) -
              0.00042 * s(3 * mp) + 0.00042 * e * s(mm + 2 * f) + 0.00038 * e * s(mm - 2 * f) -
              0.00024 * e * s(2 * mp - mm) - 0.00017 * s(om) - 0.00007 * s(mp + 2 * mm) +
              0.00004 * s(2 * mp - 2 * f) + 0.00004 * s(3 * mm) + 0.00003 * s(mp + mm - 2 * f) +
              0.00003 * s(2 * mp + 2 * f) - 0.00003 * s(mp + mm + 2 * f) + 0.00003 * s(mp - mm + 2 * f) -
              0.00002 * s(mp - mm - 2 * f) - 0.00002 * s(3 * mp + mm) + 0.00002 * s(4 * mp))
    else:
        cr = (-0.62801 * s(mp) + 0.17172 * e * s(mm) - 0.01183 * e * s(mp + mm) + 0.00862 * s(2 * mp) +
              0.00804 * s(2 * f) + 0.00454 * e * s(mp - mm) + 0.00204 * e * e * s(2 * mm) -
              0.0018 * s(mp - 2 * f) - 0.0007 * s(mp + 2 * f) - 0.0004 * s(3 * mp) -
              0.00034 * e * s(2 * mp - mm) + 0.00032 * e * s(mm + 2 * f) + 0.00032 * e * s(mm - 2 * f) -
              0.00028 * e * e * s(mp + 2 * mm) + 0.00027 * e * s(2 * mp + mm) - 0.00017 * s(om) -
              0.00005 * s(mp - mm - 2 * f) + 0.00004 * s(2 * mp + 2 * f) - 0.00004 * s(mp + mm + 2 * f) +
              0.00004 * s(mp - 2 * mm) + 0.00003 * s(mp + mm - 2 * f) + 0.00003 * s(3 * mm) +
              0.00002 * s(2 * mp - 2 * f) + 0.00002 * s(mp - mm + 2 * f) - 0.00002 * s(3 * mp + mm))
        w = 0.00306 - 0.00038 * e * math.cos(mm) + 0.00026 * math.cos(mp) - 0.00002 * math.cos(mp - mm) + 0.00002 * math.cos(mp + mm) + 0.00002 * math.cos(2 * f)
        cr += w if q == 1 else -w
    # JDE is Terrestrial Time; ~69 s ahead of UT
    return jde + cr - 69.0 / 86400.0

def next_moon_phase(epoch):
    jd = epoch / 86400.0 + 2440587.5
    k0 = math.floor((jd - 2451550.09766) / 29.530588861) - 1
    for i in range(16):
        q = i % 4
        k = k0 + i // 4 + q / 4.0
        j = moon_phase_jde(k, q)
        if j > jd:
            return MOON_PHASE_NAMES[q], int((j - 2440587.5) * 86400.0)
    return None, None


# ---------- Sun & Moon page horizon ----------
# Low silhouettes standing on the horizon at both ends of the arc (where the
# sun rises and sets), matching the Now page's farm / houses / town / city.
# They stay out of the data: the moon legend (top left), the phase text (top
# right) and the daylight change (center) all sit above them.

def sky_house(c, x, w, h, col, roof):
    # a house body w wide, h tall standing on the horizon (y 23), peaked roof
    c.rect(x, 24 - h, x + w - 1, 23, fill = col)
    c.fill_triangle(x - 1, 24 - h, x + w // 2, 24 - h - roof, x + w, 24 - h, col)

def sky_tree(c, x, r, col):
    c.fill_circle(x, 23 - r, r, col)
    c.line(x, 23 - r, x, 23, col)

def sky_windows(c, pts, is_day):
    if is_day:
        return
    for p in pts:
        c.pixel(p[0], p[1], "#ffcc55" if (p[0] + p[1]) % 3 else "#c89a40")

def draw_sky_horizon(c, place, is_day, bot):
    col = hexc(mix(bot, (0, 0, 0), 0.62 if is_day else 0.55))
    W = c.width
    if place == "rural":
        # left: a farmhouse among trees; right: barn with gambrel roof + silo
        sky_tree(c, 3, 2, col)
        sky_house(c, 8, 7, 3, col, 2)
        sky_tree(c, 19, 2, col)
        sky_tree(c, 23, 3, col)
        sky_windows(c, [(10, 22), (13, 22)], is_day)
        for x in range(W - 30, W - 21, 3):
            c.line(x, 21, x, 23, col)
        c.line(W - 30, 22, W - 21, 22, col)
        bx = W - 19
        c.rect(bx, 19, bx + 9, 23, fill = col)
        c.fill_triangle(bx - 1, 19, bx + 2, 16, bx + 5, 16, col)
        c.fill_triangle(bx + 4, 16, bx + 7, 16, bx + 10, 19, col)
        c.rect(bx + 2, 16, bx + 7, 19, fill = col)
        c.rect(W - 7, 14, W - 4, 23, fill = col)
        c.fill_circle(W - 6, 14, 1, col)
        sky_windows(c, [(bx + 4, 21)], is_day)
    elif place == "town":
        sky_house(c, 1, 6, 3, col, 2)
        c.rect(9, 19, 15, 23, fill = col)
        sky_house(c, 18, 6, 5, col, 2)
        sky_windows(c, [(3, 22), (11, 21), (13, 22), (20, 21)], is_day)
        # right: shops and a church steeple
        c.rect(W - 30, 19, W - 23, 23, fill = col)
        c.rect(W - 22, 17, W - 16, 23, fill = col)
        c.rect(W - 14, 19, W - 6, 23, fill = col)
        c.fill_triangle(W - 15, 19, W - 10, 17, W - 5, 19, col)
        c.rect(W - 12, 15, W - 8, 18, fill = col)
        c.fill_triangle(W - 12, 15, W - 10, 13, W - 8, 15, col)
        sky_windows(c, [(W - 28, 21), (W - 25, 21), (W - 20, 19), (W - 18, 21), (W - 10, 16)], is_day)
    elif place == "city":
        towers = [(0, 5, 19), (6, 4, 20), (11, 6, 19), (18, 5, 15), (W - 29, 6, 16), (W - 22, 4, 14), (W - 17, 6, 15), (W - 10, 5, 13), (W - 4, 4, 17)]
        lit = []
        for t in towers:
            x0, w, top = t
            c.rect(x0, top, x0 + w - 1, 23, fill = col)
            for wy in range(top + 2, 23, 2):
                for wx in range(x0 + 1, x0 + w - 1, 2):
                    if (wx * 7 + wy * 3) % 5 == 0:
                        lit.append((wx, wy))
        sky_windows(c, lit, is_day)
    else:
        # suburb: houses and trees
        sky_house(c, 1, 7, 3, col, 2)
        sky_tree(c, 12, 2, col)
        sky_house(c, 16, 7, 4, col, 3)
        sky_windows(c, [(3, 22), (6, 22), (18, 21)], is_day)
        sky_house(c, W - 30, 7, 4, col, 3)
        sky_tree(c, W - 19, 3, col)
        sky_house(c, W - 13, 8, 5, col, 3)
        sky_windows(c, [(W - 28, 21), (W - 10, 20), (W - 7, 21)], is_day)

# ---------- sun & moon arc ----------

def sky_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    ts = d["ts"]
    rise, sset = sun_times(d)
    pal, is_day, t = sky_state(ts, rise, sset)
    top = mix(pal[0], (0, 0, 0), 0.35)
    bot = mix(pal[1], (0, 0, 0), 0.35)
    for y in range(24):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix(top, bot, y / 23.0)))
    for y in range(24, 32):
        c.rect(0, y, c.width - 1, y, fill = "#05070f")
    c.line(0, 24, c.width - 1, 24, "#3a4878")

    x0 = 28
    x1 = c.width - 29
    for i in range(0, 101):
        tt = i / 100.0
        x, y = arc_xy(tt, x0, x1, 24, 20)
        if is_day and tt <= t:
            c.pixel(x, y, "#FFC040")
        elif i % 3 == 0:
            c.pixel(x, y, "#6a5a3a")
    # text goes under the sun and moon (they pass through these spots late
    # in their arcs, and the real sky wins)
    mresp = moon_almanac_resp(d)
    if mresp["status_code"] == 200:
        mph = ((mresp["json"].get("properties", {}) or {}).get("data", {}) or {}).get("curphase", "") or ""
        if mph != "":
            stext(c, mph.upper(), c.width - 3, 1, "picopixel", "#e0e6ff", align = "right")
    # how much daylight today gained or lost vs yesterday, under the arc
    st = d["station"]
    if st.get("lat") != None and st.get("lon") != None:
        noon = local_day_start(ts, d["tz"]) + 12 * 3600
        dsec = round_int(day_length_sec(noon, st["lat"], st["lon"]) - day_length_sec(noon - 86400, st["lat"], st["lon"]))
        a = abs(dsec)
        ch = (str(a // 60) + "M " + pad_int(a % 60, 2) + "S") if a >= 60 else (str(a) + "S")
        stext(c, ("-" if dsec < 0 else "+") + ch + " VS YESTERDAY", c.width // 2, 17, "picopixel", "#c0c8e8", align = "center")

    # the moon's phase name and the next new / quarter / full moon, top right
    nm, ne = next_moon_phase(ts)
    if nm != None:
        lt = ne + d["tz"] * 60
        ny, nmo, ndd = civil_from_days(lt // 86400)
        s1 = nm + " " + MONTH_NAMES[nmo - 1] + " " + str(ndd)
        if c.text_width(s1, "picopixel") > 55:
            s1 = nm + " " + str(nmo) + "/" + str(ndd)
        stext(c, s1, c.width - 3, 7, "picopixel", "#AACCFF", align = "right")
    if is_day:
        sx, sy = arc_xy(t, x0, x1, 24, 20)
        c.fill_circle(sx, sy, 4, hexc(mix(mix(top, bot, sy / 23.0), (255, 210, 110), 0.5)))
        c.fill_circle(sx, sy, 2, "#FFE070")


    # moon: a legend in the top-left corner (phase disk, % lit, moonrise and
    # moonset), plus the moon itself on the arc at its real position whenever
    # it's above the horizon - day or night.
    resp = moon_almanac_resp(d)
    if resp["status_code"] == 200:
        data = (resp["json"].get("properties", {}) or {}).get("data", {}) or {}
        ph = data.get("curphase", "") or ""
        fi = data.get("fracillum", "0%") or "0%"
        illum = int(fi.replace("%", "")) if "%" in fi else 0
        waxing = "Waxing" in ph or ph == "First Quarter"
        md = data.get("moondata", []) or []
        mrise = find_almanac_time(md, "Rise")
        mset = find_almanac_time(md, "Set")
        mtrans = find_almanac_time(md, "Upper Transit")

        draw_moon_phase(c, 9, 6, 5, illum / 100.0, waxing, "#EEF0F8", "#1a1f38")
        stext(c, str(illum) + "%", 9, 13, "picopixel", "#e0e6ff", align = "center")
        mc = "#AACCFF"
        for row in [(1, mrise, True), (8, mset, False)]:
            y, tstr, up = row
            for o in OUTLINE8:
                if up:
                    draw_arrow_up(c, 17 + o[0], y + o[1], "#06102a")
                else:
                    draw_arrow_down(c, 17 + o[0], y + o[1], "#06102a")
            if up:
                draw_arrow_up(c, 17, y, mc)
            else:
                draw_arrow_down(c, 17, y, mc)
            stext(c, hhmm24_to_12h_compact(tstr) if tstr != None else "--", 23, y, "picopixel", mc)

        now_m = ((ts + d["tz"] * 60) % 86400) // 60
        mt = moon_arc_t(now_m, mrise, mset, mtrans)
        if mt != None:
            ax, ay = arc_xy(mt, x0, x1, 24, 20)
            c.circle(ax, ay, 4, "#2a3050")
            draw_moon_phase(c, ax, ay, 3, illum / 100.0, waxing, "#EEF0F8", "#1a1f38")

    # the horizon, drawn last so a rising / setting sun or moon goes behind it
    place = demo_opt(d, "place")
    if place == "":
        place = station_place(d["station"])
    draw_sky_horizon(c, place, is_day, bot)

    # the ground bar goes on top of everything, so a sun or moon on the
    # horizon is cut off at the line instead of smudging the times
    c.rect(0, 25, c.width - 1, 31, fill = "#05070f")
    c.line(0, 24, c.width - 1, 24, "#3a4878")
    if rise != None:
        draw_arrow_up(c, 4, 26, "#FFC040")
        c.text(epoch_to_local_hhmm(rise, d["tz"]).replace(" AM", "A").replace(" PM", "P"), 10, 26, font = "4x5", color = "#FFC040", align = "left")
        st_s = epoch_to_local_hhmm(sset, d["tz"]).replace(" AM", "A").replace(" PM", "P")
        c.text(st_s, c.width - 4, 26, font = "4x5", color = "#FF9040", align = "right")
        draw_arrow_down(c, c.width - 4 - c.text_width(st_s, "4x5") - 6, 26, "#FF9040")
        dl = (sset - rise) // 60
        c.text(str(dl // 60) + "H " + pad_int(dl % 60, 2) + "M OF DAYLIGHT", c.width // 2, 26, font = "4x5", color = "white", align = "center")

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

# ---------- air: humidity / dew point / pressure / UV ----------

def draw_droplet(c, cx, top, h, frac, fill, empty):
    # teardrop: a point at the top widening into a round bottom
    r = h * 3 // 8
    cy = top + h - r - 1
    level = round_int(top + h - 1 - frac * (h - 1))
    for y in range(top, top + h):
        if y < cy:
            hw = round_int((y - top) / float(max(cy - top, 1)) * r)
        else:
            dy = y - cy
            hw = round_int(math.sqrt(max(r * r - dy * dy, 0)))
        col = fill if y >= level else empty
        c.line(cx - hw, y, cx + hw, y, col)

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

def air_col(c, x0, w, label, value, vcol, words, wcol, icon_w):
    cx = x0 + w // 2
    c.text(label, cx, 1, font = "picopixel", color = "#7f8fb8", align = "center")
    vw = num_width(c, value, "8x12")
    vx = x0 + icon_w + (w - icon_w - vw) // 2
    num_text(c, vx, 9, value, "8x12", vcol)
    c.text(words, cx, 26, font = fit_font(c, words, ["4x5", "picopixel"], w - 1), color = wcol, align = "center")
    return vx, vw

def air_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    draw_bg(c)
    cur = d["cur"]
    obs = d["obs"]

    # humidity
    rh = obs.get("relative_humidity", None)
    if rh == None:
        rh = cur.get("relative_humidity", 0)
    air_col(c, 3, 41, "HUMIDITY", str(round_int(rh)) + "%", "white", humidity_word(rh), "#7fb4ff", 13)
    draw_droplet(c, 10, 8, 15, rh / 100.0, "#3399FF", "#1a2a5a")

    # dew point
    dp = c_to_f(cur.get("dew_point", 0.0))
    words, wcol = dew_words(dp)
    ds = format1(tdisp(d, dp))
    dw = num_width(c, ds, "8x12") + 5
    dx = 44 + (44 - dw) // 2
    c.text("DEW POINT", 66, 1, font = "picopixel", color = "#7f8fb8", align = "center")
    num_text(c, dx, 9, ds, "8x12", tcol(dp))
    draw_deg(c, dx + dw - 4, 9, tcol(dp), True)
    c.text(words, 66, 26, font = fit_font(c, words, ["4x5", "picopixel"], 42), color = wcol, align = "center")

    # pressure (WeatherFlow's processed sea-level value) + trend arrow
    mb = cur.get("sea_level_pressure", None)
    if mb == None and obs.get("station_pressure", None) != None:
        # fallback: the raw sensor, brought to sea level with the elevation and
        # mounting height the owner set in the Tempest app
        mb = sea_level_hpa(obs["station_pressure"], d["station"].get("height_m", 0.0), obs.get("air_temperature", 15.0) or 15.0)
    p = hpa_to_inhg(mb) if mb != None else 0.0
    trend = cur.get("pressure_trend", "steady") or "steady"
    tc = "#40D070" if trend == "rising" else ("#FF8800" if trend == "falling" else "#9aa6c8")
    pstr = "--" if mb == None else (format1(mb) if d["metric"] else format2(p))
    air_col(c, 88, 60, "PRESSURE", pstr, "white", trend.upper(), tc, 10)
    ax = 94
    if trend == "rising":
        c.fill_triangle(ax - 4, 14, ax, 9, ax + 4, 14, tc)
        c.rect(ax - 1, 14, ax + 1, 20, fill = tc)
    elif trend == "falling":
        c.rect(ax - 1, 9, ax + 1, 15, fill = tc)
        c.fill_triangle(ax - 4, 15, ax, 20, ax + 4, 15, tc)
    else:
        c.rect(ax - 4, 12, ax + 2, 14, fill = tc)
        c.fill_triangle(ax + 2, 10, ax + 5, 13, ax + 2, 16, tc)

    # UV
    u = obs.get("uv", None)
    if u == None:
        u = cur.get("uv", 0.0)
    words, wcol = uv_words(u)
    air_col(c, 148, 41, "UV INDEX", str(round_int(u)), wcol, words, wcol, 14)
    sx = 157
    sy = 14
    c.fill_circle(sx, sy, 3, wcol)
    for k in range(8):
        a = math.radians(k * 45)
        c.line(round_int(sx + 5 * math.sin(a)), round_int(sy - 5 * math.cos(a)), round_int(sx + 6 * math.sin(a)), round_int(sy - 6 * math.cos(a)), wcol)

    for x in [44, 88, 148]:
        c.line(x, 4, x, 28, "#18214a")

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

def rain_page(c, ctx):
    d = load_all(c, ctx)
    if d == None:
        return
    # (DEMO testing only) storm=off forces the normal rain page
    if demo_opt(d, "storm") != "off" and storm_active(d):
        lightning_body(c, d)
        return
    draw_bg(c)
    obs = d["obs"]
    today_in = mm_to_in(obs.get("precip_accum_local_day", 0.0) or 0.0)

    # rain gauge tube
    tx0 = 4
    tx1 = 12
    ty0 = 2
    ty1 = 29
    # a fixed 2-inch gauge (50 mm in Metric), ticks every quarter: .5 / 1 / 1.5 in
    # (the middle one longer). Any rain shows at least 1px of water; past the
    # top, the tube is full with a bright cap so it doesn't read as exactly 2.
    cap = 50.0 / 25.4 if d["metric"] else 2.0
    c.rect(tx0, ty0, tx1, ty1, fill = "#0c1638")
    inner = ty1 - 1 - ty0
    lvl = ty1 - max(1, round_int(clamp(today_in / cap, 0.0, 1.0) * inner)) if today_in > 0 else ty1
    for y in range(lvl, ty1):
        c.line(tx0 + 1, y, tx1 - 1, y, hexc(mix((90, 170, 255), (20, 80, 220), (y - lvl) / float(max(ty1 - 1 - lvl, 1)))))
    if today_in > 0:
        c.line(tx0 + 1, lvl, tx1 - 1, lvl, "#ffffff" if today_in > cap else "#c8e4ff")
    c.line(tx0, ty0, tx0, ty1, "#5a6a9a")
    c.line(tx1, ty0, tx1, ty1, "#5a6a9a")
    c.line(tx0, ty1, tx1, ty1, "#5a6a9a")
    for k in range(1, 4):
        ty = ty1 - round_int(k / 4.0 * inner)
        c.line(tx1 - (4 if k == 2 else 2), ty, tx1 - 1, ty, "#8090c0")

    s = rain_str(d, today_in)
    # 1 in+ (100 mm+) drops a decimal so the unit still fits before the graph
    if d["metric"] and today_in * 25.4 >= 99.95:
        s = str(round_int(today_in * 25.4))
    elif not d["metric"] and today_in >= 0.9995:
        s = format2(today_in)
    sw = num_text(c, 17, 3, s, "8x12", "white" if today_in == 0 else "#7fb4ff")
    c.text(rain_unit(d), 17 + sw + 2, 3, font = "4x5", color = "#7f8fb8", align = "left")
    c.text("TODAY", 17, 17, font = "4x5", color = "#7f8fb8", align = "left")
    mins = obs.get("precip_minutes_local_day", None)
    if mins != None and mins > 0:
        c.text(format_minutes(mins), 17, 24, font = "4x5", color = "#3399FF", align = "left")

    # today's timeline: rain bars from the bottom, lightning marks from the top
    day_start, rows = day_obs_rows(d)
    gx0 = 60
    gx1 = 132
    gw = gx1 - gx0
    span = 86400.0 / gw
    rain = [0.0] * gw
    strikes = [0] * gw
    for r in rows:
        i = int((r[0] - day_start) / span)
        if i < 0 or i >= gw:
            continue
        if len(r) > 12 and r[12] != None:
            rain[i] += r[12]
        if len(r) > 15 and r[15] != None:
            strikes[i] += r[15]
    now_i = int((d["ts"] - day_start) / span)
    # graph rows 6-24 (rain bars up from 24, strike marks down from 6), hour
    # labels under it, and today's strike count above it on lightning days
    gt = 6
    gb = 24
    c.rect(gx0, gt, gx1 - 1, gb, fill = "#080e2a")
    for hh in [6, 12, 18]:
        x = gx0 + hh * gw // 24
        for y in range(gt + 1, gb, 3):
            c.pixel(x, y, "#1c2650")
        c.text(["6A", "NOON", "6P"][hh // 6 - 1], x, 26, font = "picopixel", color = "#55628f", align = "center")
    rmax = max(rain + [0.5])
    smax = max(strikes + [1])
    for i in range(gw):
        if rain[i] > 0:
            h = max(1, round_int(rain[i] / rmax * 11))
            c.line(gx0 + i, gb - h, gx0 + i, gb, "#3399FF")
        if strikes[i] > 0:
            h = max(1, round_int(strikes[i] / float(smax) * 5))
            c.line(gx0 + i, gt, gx0 + i, gt + h - 1, "#FFE040")
    if now_i >= 0 and now_i < gw:
        c.line(gx0 + now_i, gt, gx0 + now_i, gb, "#3a4878")
    c.line(gx0, gb + 1, gx1 - 1, gb + 1, "#2a3566")
    n_str = 0
    for k in strikes:
        n_str += k
    if n_str > 0:
        c.text(str(n_str) + (" STRIKE" if n_str == 1 else " STRIKES") + " TODAY", gx1 - 1, 0, font = "picopixel", color = "#FFE040", align = "right")

    # stats column
    sx = 136
    sx1 = c.width - 4
    y_in = obs.get("precip_accum_local_yesterday_final", None)
    if y_in == None:
        y_in = obs.get("precip_accum_local_yesterday", 0.0)
    y_in = mm_to_in(y_in or 0.0)
    hr = mm_to_in(obs.get("precip_accum_last_1hr", 0.0) or 0.0)
    rowsd = [("LAST HR", rain_str(d, hr), "#7fb4ff" if hr > 0 else "white"), ("YEST", rain_str(d, y_in), "#7fb4ff" if y_in > 0 else "white")]
    m_in, wet = month_rain(d)
    if m_in != None:
        # the month total to hundredths (thousandths add nothing over a month)
        m_s = rain_str(d, m_in)
        if not d["metric"]:
            m_s = "0" if round_int(m_in * 100) == 0 else format2(m_in)
            if m_s.startswith("0."):
                m_s = m_s[1:]
        rowsd.append(("MONTH", m_s, "#7fb4ff" if m_in > 0 else "white"))
        rowsd.append(("RAIN DAYS", str(wet), "#7fb4ff" if wet > 0 else "white"))

    last_epoch = obs.get("lightning_strike_last_epoch", None)
    dist_km = obs.get("lightning_strike_last_distance", None)
    ago = (d["ts"] - last_epoch) // 60 if last_epoch != None else None
    if ago != None and ago <= 180 and dist_km != None:
        rowsd.append(("LTG", dist_str(d, km_to_mi(dist_km)) + dist_unit(d), safe_col(strike_distance_color(km_to_mi(dist_km)))))
    else:
        rowsd.append(("LTG", "NONE", "#7f8fb8"))
    for k in range(len(rowsd)):
        lab, val, col = rowsd[k]
        # 5 rows, 6px apart, ending 2px above the bottom edge; label and value
        # share a top line
        y = 1 + k * 6
        c.text(lab, sx, y, font = "picopixel", color = "#7f8fb8", align = "left")
        c.text(val, sx1, y, font = "4x5", color = col, align = "right")

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

def lightning_body(c, d):
    draw_bg(c)
    obs = d["obs"]
    ts = d["ts"]
    day_start, rows = day_obs_rows(d)
    gx0 = 4
    gx1 = 136
    gy0 = 8
    gy1 = 28
    max_mi = 25.0
    win = 3 * 3600
    # distance guides: 5 / 10 / 15 / 20 mi, or 10 / 20 / 30 km
    if d["metric"]:
        guides = [(10 / 1.609344, "10KM"), (20 / 1.609344, ""), (30 / 1.609344, "30KM")]
    else:
        guides = [(5.0, ""), (10.0, "10MI"), (15.0, ""), (20.0, "20MI")]
    for g in guides:
        mi, lab = g
        y = round_int(gy1 - mi / max_mi * (gy1 - gy0))
        for x in range(gx0, gx1, 3):
            c.pixel(x, y, "#1c2650")
        if lab != "":
            c.text(lab, gx1 + 2, y - 2, font = "picopixel", color = "#55628f", align = "left")
    c.line(gx0, gy1 + 1, gx1, gy1 + 1, "#2a3566")
    total = 0
    has_strikes = False
    for r in rows:
        if len(r) <= 15 or r[15] == None or r[15] <= 0 or r[14] == None:
            continue
        age = ts - r[0]
        if age < 0 or age > win:
            continue
        total += r[15]
        has_strikes = True
        mi = km_to_mi(r[14])
        x = round_int(gx1 - age / float(win) * (gx1 - gx0))
        y = round_int(gy1 - clamp(mi / max_mi, 0.0, 1.0) * (gy1 - gy0))
        rr = 1 if r[15] < 4 else 2
        c.fill_circle(x, y, rr, safe_col(strike_distance_color(mi)))

    rx = 158
    cx = (rx + c.width - 4) // 2
    rw_max = c.width - 4 - rx
    c.line(rx - 2, 3, rx - 2, 28, "#18214a")
    last_epoch = obs.get("lightning_strike_last_epoch", None)
    dist_km = obs.get("lightning_strike_last_distance", None)
    if total == 0:
        c.text("NO LIGHTNING", (gx0 + gx1) // 2, 9, font = "5x7", color = "#7f8fb8", align = "center")
        c.text("IN THE LAST 3 HOURS", (gx0 + gx1) // 2, 19, font = "4x5", color = "#55628f", align = "center")
        if last_epoch != None:
            lt = last_epoch + d["tz"] * 60
            yy, mm, dd = civil_from_days(lt // 86400)
            c.text("LAST", cx, 3, font = "picopixel", color = "#7f8fb8", align = "center")
            c.text(MONTH_NAMES[mm - 1], cx, 11, font = "5x7", color = "white", align = "center")
            c.text(str(dd), cx, 20, font = "5x7", color = "white", align = "center")
        return
    c.text("LAST 3 HOURS", gx0, 0, font = "picopixel", color = "#FFE040", align = "left")
    # today's rain total rides the label row, since storms bring both
    rain_in = mm_to_in(obs.get("precip_accum_local_day", 0.0) or 0.0)
    rs = rain_str(d, rain_in) + " " + rain_unit(d)
    rw = c.text_width(rs, "4x5")
    c.text(rs, gx1, 1, font = "4x5", color = "#7fb4ff" if rain_in > 0 else "white", align = "right")
    c.text("RAIN", gx1 - rw - 3, 1, font = "picopixel", color = "#7f8fb8", align = "right")
    c.text(str(total), cx, 2, font = "8x12", color = "#FFE040", align = "center")
    c.text("STRIKES", cx, 15, font = "picopixel", color = "#7f8fb8", align = "center")
    if last_epoch != None:
        ago = (ts - last_epoch) // 60
        ag = "NOW" if ago < 1 else str(ago) + "M AGO"
        c.text(ag, cx, 21, font = fit_font(c, ag, ["4x5", "picopixel"], rw_max), color = safe_col(last_strike_color(ago)), align = "center")
    if dist_km != None:
        ds = dist_str(d, km_to_mi(dist_km)) + " " + dist_unit(d)
        c.text(ds, cx, 27, font = fit_font(c, ds, ["4x5", "picopixel"], rw_max), color = safe_col(strike_distance_color(km_to_mi(dist_km))), align = "center")

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

def draw_alert_icon(c, kind, x, y, color):
    if kind == "tornado":
        widths = [20, 18, 15, 13, 11, 9, 8, 6, 5, 4, 3, 2, 2, 1]
        sway = [0, 1, 1, 2, 2, 3, 3, 3, 2, 2, 1, 1, 2, 3]
        for i in range(len(widths)):
            w = widths[i]
            cx = x + 10 + sway[i]
            c.line(cx - w // 2, y + 2 + i, cx + w // 2, y + 2 + i, "#B8B8C8" if i % 2 == 0 else "#8A8A9A")
    elif kind == "tstorm":
        draw_icon(c, "Thunderstorm", x, y - 2)
    elif kind == "snow":
        cx = x + 10
        cy = y + 9
        for a in [0, 60, 120]:
            r = math.radians(a)
            dx = round_int(8 * math.sin(r))
            dy = round_int(8 * math.cos(r))
            c.line(cx - dx, cy - dy, cx + dx, cy + dy, "white")
        c.fill_circle(cx, cy, 1, color)
    elif kind == "flood":
        for k in range(3):
            yy = y + 6 + k * 4
            for i in range(20):
                c.pixel(x + i, yy + round_int(1.2 * math.sin((i + k * 2) / 2.0)), "#3399FF" if k < 2 else "#66BBFF")
        c.rect(x + 4, y + 1, x + 9, y + 5, fill = "#8a6a50")
        c.fill_triangle(x + 3, y + 1, x + 6, y - 2, x + 10, y + 1, "#a04030")
    elif kind == "hurricane":
        cx = x + 10
        cy = y + 9
        c.circle(cx, cy, 3, "white")
        c.line(cx, cy - 3, cx + 7, cy - 7, "white")
        c.line(cx, cy + 3, cx - 7, cy + 7, "white")
        c.fill_circle(cx, cy, 1, color)
    elif kind == "heat":
        draw_sun(c, x + 3, y + 2)
    elif kind == "wind":
        draw_windy(c, x + 2, y + 2)
    elif kind == "fog":
        draw_fog(c, x, y + 3)
    else:
        c.fill_circle(x + 10, y + 9, 7, color)
        c.text("!", x + 10, y + 6, font = "5x7", color = "black", align = "center")

def text_on(color):
    r, g, b = hex_to_rgb(color)
    return "black" if (r * 299 + g * 587 + b * 114) / 1000 > 150 else "white"

# A warning takes over the whole Now page.
def draw_alert_takeover(c, d, alert):
    ev, until, area, count = alert
    color, kind, _ = ALERT_STYLE[ev]
    base = hex_to_rgb(color)
    for y in range(32):
        c.rect(0, y, c.width - 1, y, fill = hexc(mix((10, 10, 18), base, 0.28 - y * 0.006)))
    # hazard stripes down both edges
    for y in range(32):
        for x in range(5):
            on = ((x + y) // 3) % 2 == 0
            c.pixel(x, y, color if on else "#000000")
            c.pixel(c.width - 1 - x, y, color if on else "#000000")
    draw_alert_icon(c, kind, 9, 6, color)
    # "FLASH FLOOD" / "WARNING"; names without "Warning" (Evacuation
    # Immediate, Civil Emergency Message...) put their last word underneath
    words = ev.upper().split(" ")
    core = " ".join(words[:-1]) if len(words) > 1 else words[0]
    sub = words[-1] if len(words) > 1 else ""
    f = fit_font(c, core, ["8x12", "6x8", "5x7", "4x5"], 118)
    c.text(core, 36, 2 if f == "8x12" else 4, font = f, color = color, align = "left")
    c.text(sub, 36, 16, font = "5x7", color = "white", align = "left")
    c.text(until_text(until, d), 36, 25, font = "4x5", color = "white", align = "left")
    rx = c.width - 8
    tv = tdisp(d, d["temp"])
    temp_text(c, rx - num_width(c, format1(tv), "5x7") - 4, 3, tv, "5x7", "white", dec = True)
    c.text(area.upper(), rx, 16, font = fit_font(c, area.upper(), ["4x5", "picopixel"], 48), color = "#c8c8d0", align = "right")
    # the next alert by name (in its own color), plus a count of any more
    al = active_alerts(d)
    if len(al) > 1:
        more = (" +" + str(len(al) - 2)) if len(al) > 2 else ""
        room = rx - (36 + c.text_width(until_text(until, d), "4x5") + 6)
        s2 = "+ " + al[1][0].upper() + more
        for ab in [("THUNDERSTORM", "TSTORM"), ("STATEMENT", "STMT"), ("ADVISORY", "ADV"), ("WARNING", "WRN"), ("+ ", "+")]:
            if c.text_width(s2, "picopixel") <= room:
                break
            s2 = s2.replace(ab[0], ab[1])
        c.text(s2, rx, 26, font = "picopixel", color = ALERT_STYLE[al[1][0]][0], align = "right")

# Watches / advisories / health notices ride a strip along the bottom.
def draw_banner(c, color, text):
    c.rect(0, 26, c.width - 1, 31, fill = color)
    f = fit_font(c, text, ["4x5", "picopixel"], c.width - 4)
    c.text(text, c.width // 2, 26 if f == "4x5" else 27, font = f, color = text_on(color), align = "center")

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

def draw_health_banner(c, d, h):
    if h[0] == "offline":
        draw_banner(c, "#5a6070", "STATION OFFLINE - LAST REPORT " + epoch_to_local_hhmm(h[1], d["tz"]))
    else:
        draw_banner(c, "#E0A020", "STATION BATTERY LOW - " + format2(h[1]) + "V")

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

def now(c, ctx):
    bc = buffered(c)
    now_page(bc, ctx)
    bc.flush()

def air(c, ctx):
    bc = buffered(c)
    air_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def today(c, ctx):
    bc = buffered(c)
    today_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def hourly(c, ctx):
    bc = buffered(c)
    hourly_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def forecast(c, ctx):
    bc = buffered(c)
    forecast_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def wind(c, ctx):
    bc = buffered(c)
    wind_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def sky(c, ctx):
    bc = buffered(c)
    sky_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()

def rain(c, ctx):
    bc = buffered(c)
    rain_page(bc, ctx)
    warning_edges(bc, ctx)
    bc.flush()
