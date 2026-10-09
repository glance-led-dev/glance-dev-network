# Tempest Weather
#
# Layout is anchored to c.width rather than a hardcoded 128, so the same file
# serves the 128 panel and the 192 SCROLL. Every right-hand column, rule and
# gauge measures back from the panel edge; nothing assumes a width.
#
# Live conditions from the user's own WeatherFlow Tempest station, via
# WeatherFlow's free-for-owners REST API (swd.weatherflow.com). Requires a
# personal access token from tempestwx.com > Settings > Data Authorizations.
#
# VERIFICATION NOTE: extensively live-tested against a real station and
# fixed up based on that. Confirmed bugs, now fixed: /observations/station's
# station_pressure, wind_gust, and lightning_strike_last_distance all ignore
# their units_* query params and return native hPa/m-s/km regardless (see
# hpa_to_inhg/mps_to_mph/km_to_mi call sites); precip_accum_local_yesterday
# can be a stale pre-revision total (see precip_accum_local_yesterday_final
# handling in rainfall()). Still not independently cross-verified: the
# /observations/device array layout beyond index 6 (station_pressure) - used
# for the 3hr pressure-change feature, see fetch_device_observations() - and
# the NWS shortForecast/name text-matching in nws_to_cond()/near_term_label().
# If a page shows "N/A" or an implausible value, check those first.

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
    # Strip the sign first, like format1/format4 - floor-division of a
    # negative int splits (whole, frac) wrong (e.g. -136 // 1000 == -1, not
    # 0), which silently corrupted every negative reading this formatted.
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
    # Used for signed lat/lon - unlike format2/format3, must not rely on
    # floor-division of a negative int (e.g. -751234 // 10000 == -76, not
    # -75), so it strips the sign first like format1 does.
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

# Reduces a raw station-pressure reading to sea level using the station's
# elevation and current temperature (NWS/hypsometric approximation - the
# same method WeatherFlow's own sea_level_pressure field is believed to use,
# but computed here from a user-supplied elevation instead of WeatherFlow's
# on-file value, in case that's wrong).
def sea_level_pressure(station_inhg, elevation_ft, temp_c):
    elevation_m = elevation_ft * 0.3048
    ratio = 1.0 - (0.0065 * elevation_m) / (temp_c + 0.0065 * elevation_m + 273.15)
    return station_inhg / math.pow(ratio, 5.257)

def date_from_iso(iso_time):
    return (int(iso_time[0:4]), int(iso_time[5:7]), int(iso_time[8:10]))

def days_from_civil(y, m, d):
    # Howard Hinnant's civil-date -> days-since-epoch (1970-01-01).
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v

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

def day_of_year(y, m, d):
    return days_from_civil(y, m, d) - days_from_civil(y, 1, 1) + 1

def sun_arc_brightness(lat, lon, yday, off_hours, local_hour):
    # Sunrise-equation solar elevation approximation (same formula
    # apps/world-clock uses for its own sunrise/sunset display) - returns
    # 0 outside daylight hours, ramping smoothly up to 1 at solar noon via
    # a half-sine arc across the daylight span.
    decl = 23.45 * math.sin(math.radians(360.0 / 365.0 * (yday - 81)))
    cosw = clamp(-math.tan(math.radians(lat)) * math.tan(math.radians(decl)), -1.0, 1.0)
    w = math.degrees(math.acos(cosw)) / 15.0
    noon = 12.0 - lon / 15.0 + off_hours
    sunrise = noon - w
    sunset = noon + w
    if local_hour < sunrise or local_hour > sunset or sunset <= sunrise:
        return 0.0
    t = (local_hour - sunrise) / (sunset - sunrise)
    return clamp(math.sin(math.pi * t), 0.0, 1.0)

def header_colors(station, epoch):
    tz_offset_min = station["tz_offset_min"]
    local_epoch = epoch + tz_offset_min * 60
    secs_of_day = local_epoch % 86400
    days = (local_epoch - secs_of_day) // 86400
    local_hour = secs_of_day / 3600.0
    y, m, d = civil_from_days(days)
    yday = day_of_year(y, m, d)
    brightness = sun_arc_brightness(station["lat"], station["lon"], yday, tz_offset_min / 60.0, local_hour)
    level = round_int(brightness * 255)
    bg_color = rgb_to_hex(level, level, 0)
    text_color = "black" if brightness > 0.5 else "white"
    return bg_color, text_color

def fit_font(c, text, options, maxw):
    # Picks the largest font that fits, so a wide value (e.g. a negative or
    # 3-digit temp) never runs into a neighboring fixed-position element.
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

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
    # NWS forecast periods carry no icon field worth parsing (it's a URL
    # image path, not a stable vocabulary) - shortForecast text like "Chance
    # Rain Showers" or "Mostly Sunny" is the reliable classifier instead.
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

# Compact forms of NWS's own period names for today's period(s) - "This
# Afternoon"/"Rest Of Today" etc measure 44-67px at the label font, well
# over the ~40px a forecast column can hold, so these are abbreviated
# instead of shown verbatim. Returns None for anything unrecognized so the
# caller can fall back to a generic label.
def near_term_label(name):
    n = name.lower()
    if "afternoon" in n:
        return "THIS PM"
    elif "tonight" in n:
        return "TONIGHT"
    elif "overnight" in n:
        return "OVERNITE"
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
    # units_temp is deliberately omitted: WeatherFlow rounds its own C->F
    # conversion to whole degrees, throwing away the decimal precision we
    # want. Native units_temp (Celsius) keeps full precision - see c_to_f().
    # units_precip is also omitted: every precip_accum_* field this app reads
    # ignores it and always comes back in native mm - confirmed live for
    # today, yesterday, and last-hour totals. Converted client-side instead,
    # see mm_to_in().
    return http.get(
        "https://swd.weatherflow.com/swd/rest/observations/station/" + str(station_id),
        params = {
            "token": token,
            "units_wind": "mph",
            "units_pressure": "inhg",
            "units_distance": "mi",
        },
        ttl_seconds = 900,
    )

def fetch_device_observations(token, device_id, time_start, time_end):
    # VERIFICATION NOTE: unlike the station-level endpoints above, this
    # device-level endpoint returns "obs" as an array of positional-value
    # arrays, not named-field dicts - per WeatherFlow's published Swagger
    # docs the station_pressure value sits at index 6:
    # [epoch, wind_lull, wind_avg, wind_gust, wind_direction,
    #  wind_sample_interval, station_pressure, air_temperature, ...].
    # Not verified live. Also likely subject to the same ignore-units-params
    # behavior already confirmed on the station obs endpoint - not passing
    # units_pressure here at all, converting from hPa unconditionally.
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
    # units_temp omitted for the same reason as fetch_observation() above.
    # units_precip omitted too, though not currently proven for this specific
    # endpoint - no precip field is read from better_forecast today, so this
    # is just staying consistent/honest rather than a confirmed fix here.
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
        headers = {"User-Agent": "GDN-Tempest-Weather (glance-led-panel)", "Accept": "application/geo+json"},
        ttl_seconds = 2592000,
    )

def fetch_nws_forecast(url):
    return http.get(
        url,
        headers = {"User-Agent": "GDN-Tempest-Weather (glance-led-panel)", "Accept": "application/geo+json"},
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

    # Tempest sensor's device_id (device_type "ST") is needed for the
    # historical-observation lookup pressure-change uses, since the
    # station-level obs/forecast endpoints only carry current readings.
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

# ---------- drawing helpers ----------

def draw_header(c, name, time_str, station, epoch):
    bg_color, text_color = header_colors(station, epoch)
    c.rect(0, 0, c.width - 1, 6, fill = bg_color)
    c.text(name.upper(), 2, 1, font = "4x5", color = text_color, align = "left")
    c.text(time_str.upper(), c.width - 2, 1, font = "4x5", color = text_color, align = "right")
    c.line(0, 7, c.width - 1, 7, "#333333")

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
    c.fill_circle(cx - 3, cy - 2, 7, "#000000")

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


# (top, bottom) pixel extent of each big icon, relative to the y anchor passed
# to draw_icon - these shapes vary a lot in height (a plain cloud is 9px tall,
# a thunderstorm's bolt reaches 21px below its anchor), so centering the icon
# in its content band means each condition needs its own anchor offset.
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

# Half-scale icon set for the 3-column forecast page - the full-size icons
# above (up to 20px wide, 21px tall for a thunderbolt) don't fit a ~42px
# column alongside a weekday label and hi/lo text.
def draw_mini_sun(c, x, y):
    c.bitmap(MINI_SUN_BITMAP, x, y, "amber")

def draw_mini_cloud(c, x, y, color):
    c.bitmap(MINI_CLOUD_BITMAP, x, y, color)

def draw_mini_partly_cloudy(c, x, y):
    c.bitmap(MINI_SUN_BITMAP, x + 4, y - 2, "amber")
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
    if cond == "Clear" or cond == "ClearNight":
        draw_mini_sun(c, x + 1, y)
    elif cond == "PartlyCloudy" or cond == "PartlyCloudyNight":
        draw_mini_partly_cloudy(c, x, y)
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

def rgb_to_hex(r, g, b):
    digits = "0123456789ABCDEF"
    r = 0 if r < 0 else (255 if r > 255 else r)
    g = 0 if g < 0 else (255 if g > 255 else g)
    b = 0 if b < 0 else (255 if b > 255 else b)
    return "#" + digits[r // 16] + digits[r % 16] + digits[g // 16] + digits[g % 16] + digits[b // 16] + digits[b % 16]

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

# Fixed 5-tier band scales for the segmented meter (see draw_segment_gauge
# below). Each metric's colors are hand-picked rather than sampled off a
# continuous low->high lerp: a lerp anchored at a near-black "zero" made the
# bottom (already-lit) bands nearly indistinguishable from the dimmed,
# not-yet-reached ones at low readings - confirmed by rendering solar=40 and
# brightness=300, both of which looked almost entirely dark. Fixed, clearly
# saturated colors per tier avoid that regardless of how low the reading is.

# Standard EPA UV Index scale (Low/Moderate/High/Very High/Extreme) - these
# specific 5 colors are the widely recognized ones for UV specifically.
UV_BAND_LOWS = [0.0, 3.0, 6.0, 8.0, 11.0]
UV_BAND_COLORS = ["#00A000", "#DCC800", "#FF8800", "#DC0000", "#8833CC"]

SOLAR_BAND_LOWS = [0.0, 280.0, 560.0, 840.0, 1120.0]
SOLAR_BAND_COLORS = ["#663300", "#996600", "#CC9900", "#FFCC00", "#FFEE66"]

BRIGHT_BAND_LOWS = [0.0, 2000.0, 4000.0, 6000.0, 8000.0]
BRIGHT_BAND_COLORS = ["#334455", "#667788", "#99AABB", "#CCDDEE", "#FFFFFF"]

def hex_to_rgb(hexcolor):
    return (int(hexcolor[1:3], 16), int(hexcolor[3:5], 16), int(hexcolor[5:7], 16))

def dim_hex(hexcolor, factor):
    r, g, b = hex_to_rgb(hexcolor)
    return rgb_to_hex(round_int(r * factor), round_int(g * factor), round_int(b * factor))

# Multi-color segmented meter, like a hardware LED bargraph: 5 stacked bands,
# each keeping its OWN band color when lit (not recolored to match the
# current value), dimmed to ~15% brightness when not yet reached. Replaces
# the single-flat-color fill this page used to have.
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

def draw_error(c, msg):
    c.fill("#000000")
    c.text(msg.upper(), 4, 12, font = "5x7", color = "red", align = "left")

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
    if mph < 6:
        return "#0033FF"
    elif mph < 11:
        return "#0066FF"
    elif mph < 18:
        return "#00AAFF"
    elif mph < 27:
        return "#00CCCC"
    elif mph < 35:
        return "#33CC66"
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
    # Colors by dew point depression (temp - dew point), not an absolute
    # dew point value - a small spread means the air is nearly saturated
    # (feels muggy) regardless of the actual temperature, so e.g. 90/88F
    # and 70/68F both read as "red" even though one is much hotter.
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
        c.fill("#000000")
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

    # Prefer the live observation's temp/feels_like over better_forecast's
    # current_conditions, which is forecast-pipeline-smoothed and can lag
    # well behind the station's actual live reading (same reasoning as the
    # station_pressure/uv/solar/brightness preference elsewhere in this file).
    temp_raw = obs0.get("air_temperature", None)
    if temp_raw == None:
        temp_raw = cur.get("air_temperature", 0.0)
    temp = c_to_f(temp_raw)
    temp_col = temp_color(temp)

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, ts)
    c.line(0, 8, c.width - 1, 8, temp_col)

    cond = tempest_icon_to_cond(cur.get("icon", None))
    icon_y = centered_icon_y(cond, 9, 31)
    draw_icon(c, cond, 4, icon_y)

    temp_str = format1(temp)
    temp_font = fit_font(c, temp_str, ["16x24", "10x16", "7x12"], 48)
    font_height = {"16x24": 24, "10x16": 16, "7x12": 12}[temp_font]
    temp_y = 9 + (24 - font_height) // 2
    c.text(temp_str, 34, temp_y, font = temp_font, color = temp_col, align = "left")

    unit_x = 34 + c.text_width(temp_str, temp_font) + 2
    c.text("F".upper(), unit_x, temp_y + 1, font = "5x7", color = temp_col, align = "left")

    # HUMIDITY is the widest label in this column, so it defines the shared
    # center that FEELS and both values line up under.
    humidity_label = "HUMIDITY".upper()
    column_center = c.width - 2 - c.text_width(humidity_label, "4x5") // 2

    feels_raw = obs0.get("feels_like", None)
    if feels_raw == None:
        feels_raw = cur.get("feels_like", None)
    feels = c_to_f(feels_raw) if feels_raw != None else temp
    feels_str = format1(feels) + "F"
    feels_label = "FEELS".upper()
    c.text(feels_label, column_center, 9, font = "4x5", color = "white", align = "center")
    c.text(feels_str.upper(), column_center, 15, font = "4x5", color = temp_color(feels), align = "center")

    humidity = obs0.get("relative_humidity", None)
    if humidity == None:
        humidity = cur.get("relative_humidity", 0)
    humidity_str = (str(round_int(humidity)) + "%").upper()
    c.text(humidity_label, column_center, 21, font = "4x5", color = "white", align = "center")
    c.text(humidity_str, column_center, 27, font = "4x5", color = humidity_color(humidity), align = "center")

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
    ts = obs0.get("timestamp", 0)

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, ts)

    # station_pressure/pressure_trend come from the raw station observation
    # feed (2-min cache), not better_forecast's current_conditions (5-min
    # cache, forecast-pipeline-smoothed) - the observation feed tracks the
    # Tempest app's own live reading much more closely. This endpoint ignores
    # units_pressure=inhg and always returns hPa regardless (confirmed live:
    # a raw reading of 1022.00 showed up where ~30.19 inHg was expected) -
    # same units-param-ignoring behavior already confirmed for units_precip
    # on this endpoint, see rainfall() below. Converting manually.
    station_pressure_hpa = obs0.get("station_pressure", None)
    if station_pressure_hpa != None:
        station_pressure = hpa_to_inhg(station_pressure_hpa)
    else:
        station_pressure = cur.get("station_pressure", 0.0)
    # The setting key must be letters and digits only: input values ride a
    # key-value_key-value render descriptor, so an underscore in the KEY is a
    # delimiter and the value never arrives. Under the old `elevation_ft` this
    # read 0.0 for everybody, which silently disabled the sea-level correction
    # below -- a station at 5,000ft reported raw station pressure as if it were
    # sea level.
    elevation_ft = _n(ctx, "elevationft", 0.0)
    if elevation_ft > 0:
        pressure = sea_level_pressure(station_pressure, elevation_ft, obs0.get("air_temperature", cur.get("air_temperature", 0.0)))
    else:
        pressure = station_pressure
    dew_point = c_to_f(cur.get("dew_point", 0.0))
    temp = c_to_f(cur.get("air_temperature", 0.0))

    pressure_str = (format3(pressure) + " IN").upper()
    c.text("PRESSURE".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text(pressure_str, 119, 11, font = "4x5", color = pressure_color(pressure), align = "right")

    trend = obs0.get("pressure_trend", cur.get("pressure_trend", None))
    if trend == "rising":
        draw_arrow_up(c, c.width - 6, 11, "white")
    elif trend == "falling":
        draw_arrow_down(c, c.width - 6, 11, "white")
    elif trend == "steady":
        draw_arrow_flat(c, c.width - 6, 11, "white")

    # 3hr-ago comparison point for the pressure-change row below. Neither
    # obs endpoint exposes a ready-made delta, so this pulls historical
    # samples from the device-level endpoint (see fetch_device_observations)
    # and diffs the one closest to the 3hr mark against the current
    # station_pressure computed above. index 6 (station_pressure, hPa)
    # confirmed live via a raw-array debug dump: a full +/- 5 min window of
    # samples traced a smooth, physically sane pressure curve at that index.
    # +/- 5 min window around the 3hr-ago mark so multiple samples land in
    # it (station reports roughly once a minute) - picking the CLOSEST one
    # rather than always the window's first sample matters when the window
    # is sparse or lopsided (e.g. a data gap), which earlier picked a sample
    # far enough from the true 3hr mark to produce a wildly-wrong reading.
    # If even the closest sample is >10 min from the target, treat the
    # reading as unavailable rather than diff against a stale/unrelated one.
    change_str = "N/A"
    change_color = "#888888"
    if station["device_id"] != None and ts > 0:
        target = ts - 3 * 3600
        dev_resp = fetch_device_observations(station["token"], station["device_id"], target - 300, target + 300)
        if dev_resp["status_code"] == 200:
            dev_obs = dev_resp["json"].get("obs", [])

            best_row = None
            best_offset = 0
            for row in dev_obs:
                if len(row) <= 6:
                    continue
                offset = row[0] - target
                abs_offset = offset if offset >= 0 else -offset
                if best_row == None or abs_offset < best_offset:
                    best_row = row
                    best_offset = abs_offset

            if best_row != None and best_offset < 600:
                past_pressure = hpa_to_inhg(best_row[6])
                change = station_pressure - past_pressure
                sign = "+" if change >= 0 else ""
                change_str = (sign + format3(change) + " IN").upper()
                change_color = pressure_change_color(change)

    c.text("PRESS CHG 3HR".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text(change_str, c.width - 2, 17, font = "4x5", color = change_color, align = "right")

    c.text("DEW POINT".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text((format1(dew_point) + "F").upper(), c.width - 2, 23, font = "4x5", color = dew_point_color(temp, dew_point), align = "right")

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

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, ts)

    speed = cur.get("wind_avg", 0.0)
    deg = cur.get("wind_direction", 0)
    gust = cur.get("wind_gust", None)
    idx = compass_index(deg)

    wind_val = CARDINAL_NAMES[idx] + " @ " + str(round_int(speed)) + " MPH"
    wind_color_val = "white" if speed == 0 else wind_color(speed)
    c.text("CURRENT WIND".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text(wind_val.upper(), c.width - 2, 11, font = "4x5", color = wind_color_val, align = "right")

    if gust != None:
        gust_val = str(round_int(gust)) + " MPH"
        gust_color = "white" if gust == 0 else wind_color(gust)
    else:
        gust_val = "N/A"
        gust_color = "#888888"
    c.text("GUSTING UP TO".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text(gust_val.upper(), c.width - 2, 17, font = "4x5", color = gust_color, align = "right")

    # Same units-param-ignoring behavior as station_pressure/precip on this
    # endpoint (see conditions()/rainfall()) - confirmed live: a true ~5 MPH
    # gust showed up here as "2 MPH", matching 5 mph converted to m/s (2.24).
    # Raw value is native m/s regardless of units_wind=mph; converting here.
    daily_high_gust_mps = obs.get("wind_gust", None)
    if daily_high_gust_mps != None:
        high_gust_mph = mps_to_mph(daily_high_gust_mps)
        high_gust_val = str(round_int(high_gust_mph)) + " MPH"
        high_gust_color = "white" if high_gust_mph == 0 else wind_color(high_gust_mph)
    else:
        high_gust_val = "N/A"
        high_gust_color = "#888888"
    c.text("LATEST OBS GUST".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text(high_gust_val.upper(), c.width - 2, 23, font = "4x5", color = high_gust_color, align = "right")

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

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(obs.get("timestamp", 0), station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, obs.get("timestamp", 0))

    # Every precip_accum_* field on this endpoint ignores units_precip=in and
    # comes back in native mm regardless - confirmed live for both today
    # (1.97 shown vs 0.08in actual, matching 1.97mm) and yesterday (2.26 vs
    # 0.08in, matching 2.26mm). Converting all three ourselves.
    today_total = mm_to_in(obs.get("precip_accum_local_day", 0.0))
    last_hour_raw = obs.get("precip_accum_last_1hr", None)

    # WeatherFlow revises the previous day's rain total after the fact (rain
    # vs. other precip-type reclassification) - precip_accum_local_yesterday
    # can be a stale pre-revision estimate (confirmed live: showed 0.081in
    # when tempestwx.com had already revised 8/12 to 0.17in). Prefer the
    # _final field once it's available; fall back to the non-final one for
    # days it hasn't been computed yet.
    yesterday_total = obs.get("precip_accum_local_yesterday_final", None)
    if yesterday_total == None:
        yesterday_total = obs.get("precip_accum_local_yesterday", None)

    today_color = "white" if today_total == 0 else rain_daily_color(today_total)
    c.text("RAIN TODAY".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text((format3(today_total) + " IN").upper(), c.width - 2, 11, font = "4x5", color = today_color, align = "right")

    last_hour_in = mm_to_in(last_hour_raw) if last_hour_raw != None else None
    last_hour_str = (format3(last_hour_in) + " IN") if last_hour_in != None else "N/A"
    if last_hour_in == None:
        last_hour_color = "#888888"
    elif last_hour_in == 0:
        last_hour_color = "white"
    else:
        last_hour_color = rain_last_hour_color(last_hour_in)
    c.text("RAIN LAST HOUR".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text(last_hour_str.upper(), c.width - 2, 17, font = "4x5", color = last_hour_color, align = "right")

    yesterday_in = mm_to_in(yesterday_total) if yesterday_total != None else None
    yesterday_str = (format3(yesterday_in) + " IN") if yesterday_in != None else "N/A"
    if yesterday_in == None:
        yesterday_color = "#888888"
    elif yesterday_in == 0:
        yesterday_color = "white"
    else:
        yesterday_color = rain_daily_color(yesterday_in)
    c.text("RAIN YESTERDAY".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text(yesterday_str.upper(), c.width - 2, 23, font = "4x5", color = yesterday_color, align = "right")

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

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, ts)

    # Prefer the raw observation's live sensor values over better_forecast's
    # current_conditions, which can lag/differ (confirmed for uv earlier).
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
    draw_segment_gauge(c, "BRIGHT", str(round_int(brightness)), BRIGHT_BAND_LOWS, BRIGHT_BAND_COLORS, brightness, 88, c.width - 2)

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

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(ts, station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, ts)

    # The forecast itself comes from the NWS (api.weather.gov), not
    # WeatherFlow - a station's own better_forecast is model-derived, while
    # the NWS forecast is the official human-issued one for the station's
    # location. Two calls: /points/{lat},{lon} resolves the station's
    # forecast office grid (cached a month, it never moves), then that
    # office's own /forecast URL returns the actual periods.
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

    # NWS periods are ~12hr day/night blocks (shorter for the first one if
    # we're partway through it) - showing the raw next 3 periods (not
    # grouped into day/lo-hi pairs) covers roughly the next 36 hours instead
    # of the next 3 calendar days.
    col_w = c.width // 3
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
            label = WEEKDAY_NAMES[weekday] + (" NITE" if not is_day else "")
        c.text(label.upper(), cx, 8, font = "4x5", color = "white", align = "center")

        cond = nws_to_cond(p.get("shortForecast", ""))
        draw_mini_icon(c, cond, cx - 6, 14)

        temp = p.get("temperature", None)
        temp_str = str(temp) if temp != None else "--"
        c.text(temp_str.upper(), cx, 24, font = "5x7", color = "white", align = "center")

def lightning2(c, ctx):
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

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(obs.get("timestamp", 0), station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, obs.get("timestamp", 0))

    last_epoch = obs.get("lightning_strike_last_epoch", None)
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
        last_color = last_strike_color(minutes_ago)
    else:
        last_str = "NONE RECENT"
        last_color = "#888888"
    c.text("LAST STRIKE".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text(last_str.upper(), c.width - 2, 11, font = "4x5", color = last_color, align = "right")

    # Same units-param-ignoring behavior as station_pressure/precip/wind_gust
    # on this endpoint - confirmed live: a true 22-25mi strike showed up here
    # as "39 MI" (39 * 0.621371 = 24.2mi). Raw value is native km regardless
    # of units_distance=mi; converting here.
    distance_km = obs.get("lightning_strike_last_distance", None)
    if distance_km != None:
        distance = km_to_mi(distance_km)
        dist_color = strike_distance_color(distance)
        dist_str = format1(distance) + " MI"
    else:
        dist_color = "#888888"
        dist_str = "N/A"
    c.text("STRIKE DISTANCE".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text(dist_str.upper(), c.width - 2, 17, font = "4x5", color = dist_color, align = "right")

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

    c.fill("#000000")
    time_str = epoch_to_local_hhmm(obs.get("timestamp", 0), station["tz_offset_min"])
    draw_header(c, station["name"], time_str, station, obs.get("timestamp", 0))

    rain_minutes = obs.get("precip_minutes_local_day", None)
    strikes_1hr = obs.get("lightning_strike_count_last_1hr", None)
    strikes_3hr = obs.get("lightning_strike_count_last_3hr", None)

    if rain_minutes == None:
        rain_minutes_str = "N/A"
        rain_minutes_color = "#888888"
    elif rain_minutes == 0:
        rain_minutes_str = "0 M"
        rain_minutes_color = "white"
    elif rain_minutes > 59:
        rain_minutes_str = str(rain_minutes // 60) + " H " + str(rain_minutes % 60) + " M"
        rain_minutes_color = rain_duration_color(rain_minutes)
    else:
        rain_minutes_str = str(rain_minutes) + " M"
        rain_minutes_color = rain_duration_color(rain_minutes)
    c.text("RAIN DURATION TODAY".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text(rain_minutes_str.upper(), c.width - 2, 11, font = "4x5", color = rain_minutes_color, align = "right")

    if strikes_1hr == None:
        strikes_1hr_str = "N/A"
        strikes_1hr_color = "#888888"
    elif strikes_1hr == 0:
        strikes_1hr_str = "NONE"
        strikes_1hr_color = "white"
    else:
        strikes_1hr_str = str(strikes_1hr)
        strikes_1hr_color = strikes_last_hour_color(strikes_1hr)
    c.text("STRIKES - LAST HOUR".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text(strikes_1hr_str.upper(), c.width - 2, 17, font = "4x5", color = strikes_1hr_color, align = "right")

    if strikes_3hr == None:
        strikes_3hr_str = "N/A"
        strikes_3hr_color = "#888888"
    elif strikes_3hr == 0:
        strikes_3hr_str = "NONE"
        strikes_3hr_color = "white"
    else:
        strikes_3hr_str = str(strikes_3hr)
        strikes_3hr_color = strikes_last_3hr_color(strikes_3hr)
    c.text("STRIKES - LAST 3 HRS".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text(strikes_3hr_str.upper(), c.width - 2, 23, font = "4x5", color = strikes_3hr_color, align = "right")
