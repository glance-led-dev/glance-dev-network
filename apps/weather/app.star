WEEKDAY_NAMES = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
WAXING_PHASES = ["New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous"]
MOON_LIT = "#F7E7C1"
MOON_DARK = "#23252E"
MOON_CRATER = "#DBC49B"
CARDINAL_NAMES = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
CARDINAL_VECTORS = [
    (0, -8),
    (6, -6),
    (8, 0),
    (6, 6),
    (0, 8),
    (-6, 6),
    (-8, 0),
    (-6, -6),
]

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


# ---- pure-math / formatting helpers (no round(), no %-width specifiers, no while) ----

def civil_from_days(z):
    # Howard Hinnant's days-since-epoch -> (year, month, day). z = days since 1970-01-01.
    z = z + 719468
    era = (z // 146097) if z >= 0 else ((z - 146096) // 146097)
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = (mp + 3) if mp < 10 else (mp - 9)
    if m <= 2:
        y = y + 1
    return (y, m, d)


def days_from_civil(y, m, d):
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def compass_index(deg):
    return int((deg + 22.5) // 45) % 8


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


def format2(value):
    cents = round_int(value * 100)
    whole = cents // 100
    frac = cents % 100
    return str(whole) + "." + pad_int(frac, 2)


def zip_str(v):
    if v == None:
        return ""
    if type(v) == "int":
        return pad_int(v, 5)
    return str(v).strip()


def time_of_day_str(iso_time):
    hour24 = int(iso_time[11:13])
    minute = int(iso_time[14:16])
    ampm = "AM" if hour24 < 12 else "PM"
    hour12 = hour24 % 12
    if hour12 == 0:
        hour12 = 12
    return str(hour12) + ":" + pad_int(minute, 2) + " " + ampm


def date_from_iso(iso_time):
    return (int(iso_time[0:4]), int(iso_time[5:7]), int(iso_time[8:10]))


def strip_pct(s):
    if len(s) > 0 and s[-1] == "%":
        return s[:-1]
    return s


def fmt_hhmm_24(hhmm):
    # USNO returns bare 24h "HH:MM" strings (no date), unlike Open-Meteo's ISO times.
    if hhmm == None:
        return "N/A"
    hour24 = int(hhmm[0:2])
    minute = int(hhmm[3:5])
    ampm = "AM" if hour24 < 12 else "PM"
    hour12 = hour24 % 12
    if hour12 == 0:
        hour12 = 12
    return str(hour12) + ":" + pad_int(minute, 2) + " " + ampm


def wmo_to_cond(code):
    if code == 0 or code == 1:
        return "Clear"
    elif code == 3:
        return "Clouds"
    elif code == 45 or code == 48:
        return "Fog"
    elif code in (51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82):
        return "Rain"
    elif code in (71, 73, 75, 77, 85, 86):
        return "Snow"
    elif code in (95, 96, 99):
        return "Thunderstorm"
    else:
        return "Clouds"


def sum_precip(values):
    total = 0.0
    for v in values:
        if v != None:
            total += v
    return total


# ---- network (all keyless) ----

def fetch_zip_geo(zip):
    return http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds=2592000)


def fetch_weather(lat, lon):
    return http.get(
        "https://api.open-meteo.com/v1/forecast",
        params={
            "latitude": lat,
            "longitude": lon,
            "current": "temperature_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,wind_gusts_10m,uv_index,relative_humidity_2m,dew_point_2m,pressure_msl",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min,wind_gusts_10m_max,sunrise,sunset",
            "temperature_unit": "fahrenheit",
            "wind_speed_unit": "mph",
            "timezone": "auto",
            "forecast_days": "4",
        },
        ttl_seconds=3600,
    )


def fetch_moon_data(lat, lon, date_str, tz_hours):
    return http.get(
        "https://aa.usno.navy.mil/api/rstt/oneday",
        params={"date": date_str, "coords": str(lat) + "," + str(lon), "tz": str(tz_hours)},
        headers={"User-Agent": "GDN-Weather-App (glance-led-panel)"},
        ttl_seconds=3600,
    )


def find_phen_time(entries, phen):
    for e in entries:
        if e.get("phen", "") == phen:
            return e.get("time", None)
    return None


def fetch_air_quality(lat, lon):
    return http.get(
        "https://air-quality-api.open-meteo.com/v1/air-quality",
        params={"latitude": lat, "longitude": lon, "current": "us_aqi", "timezone": "auto"},
        ttl_seconds=3600,
    )


def fetch_precip_recent(lat, lon, past_days):
    return http.get(
        "https://api.open-meteo.com/v1/forecast",
        params={
            "latitude": lat,
            "longitude": lon,
            "daily": "precipitation_sum",
            "past_days": str(past_days),
            "forecast_days": "1",
            "timezone": "auto",
            "precipitation_unit": "inch",
        },
        ttl_seconds=3600,
    )


def fetch_precip_archive(lat, lon, start_date, end_date):
    return http.get(
        "https://archive-api.open-meteo.com/v1/archive",
        params={
            "latitude": lat,
            "longitude": lon,
            "daily": "precipitation_sum",
            "start_date": start_date,
            "end_date": end_date,
            "timezone": "auto",
            "precipitation_unit": "inch",
        },
        ttl_seconds=21600,
    )


def fetch_pressure_history(lat, lon):
    return http.get(
        "https://api.open-meteo.com/v1/forecast",
        params={
            "latitude": lat,
            "longitude": lon,
            "hourly": "pressure_msl",
            "past_days": "1",
            "forecast_days": "1",
            "timezone": "auto",
        },
        ttl_seconds=3600,
    )


def pressure_trend(lat, lon, current_iso_time):
    resp = fetch_pressure_history(lat, lon)
    if resp["status_code"] != 200:
        return None

    hourly = resp["json"]["hourly"]
    times = hourly["time"]
    pressures = hourly["pressure_msl"]

    current_hour = current_iso_time[0:13]
    idx = -1
    for i in range(len(times)):
        if times[i][0:13] == current_hour:
            idx = i
            break
    if idx == -1 or idx < 3:
        return None

    now_p = pressures[idx]
    past_p = pressures[idx - 3]
    if now_p == None or past_p == None:
        return None

    diff = now_p - past_p
    if diff >= 1.0:
        return "rising"
    elif diff <= -1.0:
        return "falling"
    else:
        return "flat"


def fetch_alerts(lat, lon):
    return http.get(
        "https://api.weather.gov/alerts/active",
        params={"point": str(lat) + "," + str(lon)},
        headers={"User-Agent": "GDN-Weather-App (glance-led-panel)", "Accept": "application/geo+json"},
        ttl_seconds=3600,
    )


def alert_color(event):
    if "Warning" in event:
        return "red"
    elif "Watch" in event:
        return "#FF8800"
    elif "Advisory" in event:
        return "amber"
    else:
        return "#3399FF"


def get_warnings(lat, lon, limit):
    resp = fetch_alerts(lat, lon)
    if resp["status_code"] != 200:
        return []
    features = resp["json"].get("features", [])
    warnings = []
    for i in range(limit):
        if i >= len(features):
            break
        props = features[i]["properties"]
        warnings.append({"event": props.get("event", "ALERT"), "expires": props.get("expires", None)})
    return warnings


def resolve_location(zip):
    resp = fetch_zip_geo(zip)
    if resp["status_code"] != 200:
        return None
    places = resp["json"].get("places", [])
    if len(places) == 0:
        return None
    place = places[0]
    city = place["place name"] + ", " + place["state abbreviation"]
    return {"city": city, "lat": place["latitude"], "lon": place["longitude"]}


# ---- drawing helpers ----

def draw_header(c, city, time_str):
    c.text(city.upper(), 2, 1, font = "4x5", color = "white", align = "left")
    c.text(time_str.upper(), 126, 1, font = "4x5", color = "white", align = "right")
    c.line(0, 7, 127, 7, "#333333")


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


def draw_bolt(c, x, y):
    c.line(x + 11, y + 9, x + 8, y + 15, "amber")
    c.line(x + 8, y + 15, x + 12, y + 15, "amber")
    c.line(x + 12, y + 15, x + 9, y + 21, "amber")


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
    elif cond == "Rain":
        draw_cloud(c, x, y, "#888888")
        draw_rain(c, x, y)
    elif cond == "Thunderstorm":
        draw_cloud(c, x, y, "#666666")
        draw_bolt(c, x, y)
    elif cond == "Snow":
        draw_cloud(c, x, y, "#AAAAAA")
        draw_snow(c, x, y)
    elif cond == "Clouds":
        draw_cloud(c, x, y, "#AAAAAA")
    else:
        draw_cloud(c, x, y, "#999999")


def draw_mini_sun(c, x, y):
    c.bitmap(MINI_SUN_BITMAP, x, y, "amber")


def draw_mini_cloud(c, x, y, color):
    c.bitmap(MINI_CLOUD_BITMAP, x, y, color)


def draw_mini_rain(c, x, y):
    c.line(x + 3, y + 6, x + 2, y + 8, "#3399FF")
    c.line(x + 8, y + 6, x + 7, y + 8, "#3399FF")


def draw_mini_snow(c, x, y):
    c.pixel(x + 3, y + 7, "white")
    c.pixel(x + 8, y + 7, "white")
    c.pixel(x + 5, y + 8, "white")


def draw_mini_bolt(c, x, y):
    c.line(x + 7, y + 6, x + 5, y + 8, "amber")
    c.line(x + 5, y + 8, x + 8, y + 8, "amber")


def draw_mini_icon(c, cond, x, y):
    if cond == "Clear":
        draw_mini_sun(c, x + 1, y)
    elif cond == "Rain":
        draw_mini_cloud(c, x, y, "#888888")
        draw_mini_rain(c, x, y)
    elif cond == "Thunderstorm":
        draw_mini_cloud(c, x, y, "#666666")
        draw_mini_bolt(c, x, y)
    elif cond == "Snow":
        draw_mini_cloud(c, x, y, "#AAAAAA")
        draw_mini_snow(c, x, y)
    elif cond == "Clouds":
        draw_mini_cloud(c, x, y, "#AAAAAA")
    else:
        draw_mini_cloud(c, x, y, "#999999")


def draw_compass(c, cx, cy, deg):
    c.rect(cx - 9, cy - 9, cx + 9, cy + 9, outline = "#555555")

    c.text("N".upper(), cx, cy - 9 + 1, font = "4x5", color = "#888888", align = "center")
    c.text("S".upper(), cx, cy + 9 - 6, font = "4x5", color = "#888888", align = "center")
    c.text("E".upper(), cx + 6, cy - 2, font = "4x5", color = "#888888", align = "center")
    c.text("W".upper(), cx - 6, cy - 2, font = "4x5", color = "#888888", align = "center")

    idx = compass_index(deg)
    dx, dy = CARDINAL_VECTORS[idx]
    c.line(cx, cy, cx + dx, cy + dy, "red")
    c.pixel(cx + dx, cy + dy, "red")


def draw_gauge(c, label, display_str, value_scaled, max_scaled, color, x0, y0, y1):
    c.text(label.upper(), x0, y0, font = "5x7", color = "white", align = "left")
    c.text(display_str.upper(), x0, y0 + 9, font = "7x12", color = color, align = "left")

    bar_x0 = x0 + 36
    bar_x1 = bar_x0 + 8
    c.rect(bar_x0, y0, bar_x1, y1, outline = "#555555")

    bar_h = y1 - y0
    fill_h = (bar_h * value_scaled) // max_scaled
    if fill_h > bar_h:
        fill_h = bar_h
    if fill_h < 0:
        fill_h = 0
    if fill_h > 0:
        fill_top = y1 - fill_h
        c.rect(bar_x0 + 1, fill_top, bar_x1 - 1, y1 - 1, fill = color)


def _moon_is_lit(dx, dy, r, t, waxing):
    # Terminator is an ellipse whose half-width at row dy is t * w, w = half-width
    # of the disc at that row. t = cos(2*pi*phase); waxing sweeps the lit edge in
    # from the right, waning retreats it toward the left.
    w = math.sqrt(float(r * r - dy * dy))
    x = float(dx)
    if waxing:
        return x >= t * w
    return x <= -t * w


def draw_moon_disc(c, cx, cy, r, t, waxing):
    rr = r * r
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > rr:
                continue
            if _moon_is_lit(dx, dy, r, t, waxing):
                c.pixel(cx + dx, cy + dy, MOON_LIT)
            else:
                c.pixel(cx + dx, cy + dy, MOON_DARK)

    for cr in [(-3, -3, 1), (2, 1, 1), (-1, 3, 1), (3, -4, 1)]:
        ox, oy, cr_r = cr
        for dy in range(oy - cr_r, oy + cr_r + 1):
            for dx in range(ox - cr_r, ox + cr_r + 1):
                if (dx - ox) * (dx - ox) + (dy - oy) * (dy - oy) > cr_r * cr_r:
                    continue
                if dx * dx + dy * dy > rr:
                    continue
                if _moon_is_lit(dx, dy, r, t, waxing):
                    c.pixel(cx + dx, cy + dy, MOON_CRATER)


def draw_error(c, msg):
    c.fill("#000000")
    c.text(msg.upper(), 4, 12, font = "5x7", color = "red", align = "left")


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


def uv_color(v):
    if v < 3:
        return "green"
    elif v < 6:
        return "amber"
    elif v < 8:
        return "#FF8800"
    elif v < 11:
        return "red"
    else:
        return "#8833CC"


def aqi_color(v):
    if v <= 50:
        return "green"
    elif v <= 100:
        return "amber"
    elif v <= 150:
        return "#FF8800"
    elif v <= 200:
        return "red"
    elif v <= 300:
        return "#8833CC"
    else:
        return "#660033"


# ---- pages ----

def current(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    cond = wmo_to_cond(cur["weather_code"])
    draw_icon(c, cond, 4, 10)

    temp = cur["temperature_2m"]
    temp_str = str(round_int(temp))
    temp_col = temp_color(temp)
    c.text(temp_str, 46, 8, font = "16x24", color = temp_col, align = "left")

    unit_x = 46 + len(temp_str) * 16 + 2
    c.text("F".upper(), unit_x, 10, font = "5x7", color = temp_col, align = "left")

    feels = cur["apparent_temperature"]
    feels_str = str(round_int(feels)) + "° F"
    c.text("FEELS".upper(), 126, 9, font = "4x5", color = "#888888", align = "right")
    c.text("LIKE".upper(), 126, 15, font = "4x5", color = "#888888", align = "right")
    c.text(feels_str.upper(), 126, 22, font = "5x7", color = temp_color(feels), align = "right")


def conditions(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    humidity = cur["relative_humidity_2m"]
    pressure = cur["pressure_msl"] * 0.0295299830714
    dew_point = cur["dew_point_2m"]

    c.text("HUMIDITY".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text((str(round_int(humidity)) + "%").upper(), 126, 11, font = "4x5", color = humidity_color(humidity), align = "right")

    pressure_str = (format2(pressure) + " IN").upper()
    c.text("PRESSURE".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text(pressure_str, 119, 17, font = "4x5", color = "white", align = "right")

    trend = pressure_trend(loc["lat"], loc["lon"], cur["time"])
    if trend != None:
        if trend == "rising":
            draw_arrow_up(c, 122, 17, "white")
        elif trend == "falling":
            draw_arrow_down(c, 122, 17, "white")
        else:
            draw_arrow_flat(c, 122, 17, "white")

    c.text("DEW POINT".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text((str(round_int(dew_point)) + "° F").upper(), 126, 23, font = "4x5", color = temp_color(dew_point), align = "right")


def wind(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    speed = cur["wind_speed_10m"]
    deg = cur["wind_direction_10m"]
    gust = cur.get("wind_gusts_10m", None)
    idx = compass_index(deg)

    wind_val = CARDINAL_NAMES[idx] + " @ " + str(round_int(speed)) + " MPH"
    c.text("CURRENT WIND".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text(wind_val.upper(), 126, 11, font = "4x5", color = "white", align = "right")

    if gust != None:
        gust_val = str(round_int(gust)) + " MPH"
    else:
        gust_val = "N/A"
    c.text("GUSTING UP TO".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text(gust_val.upper(), 126, 17, font = "4x5", color = "white", align = "right")

    daily = w_resp["json"].get("daily", {})
    high_gust_list = daily.get("wind_gusts_10m_max", [])
    if len(high_gust_list) > 0 and high_gust_list[0] != None:
        high_gust_val = str(round_int(high_gust_list[0])) + " MPH"
    else:
        high_gust_val = "N/A"
    c.text("DAILY HIGH GUST".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text(high_gust_val.upper(), 126, 23, font = "4x5", color = "#888888", align = "right")


def rainfall(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    year, month, day = date_from_iso(cur["time"])
    local_days = days_from_civil(year, month, day)

    today_total = 0.0
    month_total = 0.0
    month_resp = fetch_precip_recent(loc["lat"], loc["lon"], day - 1)
    if month_resp["status_code"] == 200:
        values = month_resp["json"]["daily"]["precipitation_sum"]
        month_total = sum_precip(values)
        if len(values) > 0 and values[-1] != None:
            today_total = values[-1]

    jan1_days = days_from_civil(year, 1, 1)
    day_of_year = local_days - jan1_days

    year_total = 0.0
    if day_of_year <= 92:
        recent_resp = fetch_precip_recent(loc["lat"], loc["lon"], day_of_year)
        if recent_resp["status_code"] == 200:
            year_total = sum_precip(recent_resp["json"]["daily"]["precipitation_sum"])
    else:
        recent_resp = fetch_precip_recent(loc["lat"], loc["lon"], 92)
        if recent_resp["status_code"] == 200:
            year_total = sum_precip(recent_resp["json"]["daily"]["precipitation_sum"])

        older_end_days = local_days - 93
        oy, om, od = civil_from_days(older_end_days)
        start_date = pad_int(year, 4) + "-01-01"
        end_date = pad_int(oy, 4) + "-" + pad_int(om, 2) + "-" + pad_int(od, 2)
        archive_resp = fetch_precip_archive(loc["lat"], loc["lon"], start_date, end_date)
        if archive_resp["status_code"] == 200:
            year_total += sum_precip(archive_resp["json"]["daily"]["precipitation_sum"])

    c.text("DAILY RAIN".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text((format2(today_total) + " IN").upper(), 126, 11, font = "4x5", color = "white", align = "right")

    c.text("MONTHLY RAIN".upper(), 2, 17, font = "4x5", color = "white", align = "left")
    c.text((format2(month_total) + " IN").upper(), 126, 17, font = "4x5", color = "white", align = "right")

    c.text("YEARLY RAIN".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text((format2(year_total) + " IN").upper(), 126, 23, font = "4x5", color = "white", align = "right")


def uv_aqi(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    uv_val = cur.get("uv_index", 0.0)
    if uv_val == None:
        uv_val = 0.0

    aqi_val = 0
    aqi_resp = fetch_air_quality(loc["lat"], loc["lon"])
    if aqi_resp["status_code"] == 200:
        raw_aqi = aqi_resp["json"]["current"].get("us_aqi", 0)
        if raw_aqi != None:
            aqi_val = round_int(raw_aqi)

    uv_scaled = round_int(uv_val * 10)
    draw_gauge(c, "UV", str(round_int(uv_val)), uv_scaled, 110, uv_color(uv_val), 4, 11, 30)
    draw_gauge(c, "AQI", str(aqi_val), aqi_val, 300, aqi_color(aqi_val), 68, 11, 30)


def forecast(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    data = w_resp["json"]
    cur = data["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    daily = data["daily"]
    times = daily["time"]
    codes = daily["weather_code"]
    maxs = daily["temperature_2m_max"]
    mins = daily["temperature_2m_min"]

    col_w = 128 // 3
    count = 0
    for i in range(1, 4):
        if i >= len(times):
            break
        y, m, d = date_from_iso(times[i])
        days_epoch = days_from_civil(y, m, d)
        weekday = (days_epoch + 4) % 7
        cx = count * col_w + col_w // 2
        count += 1

        c.text(WEEKDAY_NAMES[weekday].upper(), cx, 8, font = "4x5", color = "white", align = "center")

        cond = wmo_to_cond(codes[i])
        draw_mini_icon(c, cond, cx - 6, 14)

        hi = str(round_int(maxs[i]))
        lo = str(round_int(mins[i]))
        c.text((hi + "/" + lo).upper(), cx, 24, font = "5x7", color = "white", align = "center")


def draw_warning_row(c, warning, y):
    c.text(warning["event"].upper(), 2, y, font = "picopixel", color = alert_color(warning["event"]), align = "left")

    if warning["expires"] != None:
        expires_str = time_of_day_str(warning["expires"])
    else:
        expires_str = "UNKNOWN"
    c.text(("EXP " + expires_str).upper(), 126, y, font = "picopixel", color = "white", align = "right")


def warnings(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    alerts = get_warnings(loc["lat"], loc["lon"], 2)
    if len(alerts) == 0:
        c.text("NO ACTIVE".upper(), 64, 14, font = "picopixel", color = "#888888", align = "center")
        c.text("WARNINGS".upper(), 64, 20, font = "picopixel", color = "#888888", align = "center")
        return

    draw_warning_row(c, alerts[0], 9)
    if len(alerts) > 1:
        draw_warning_row(c, alerts[1], 21)


def astro(c, ctx):
    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip code")
        return

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    data = w_resp["json"]
    cur = data["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    daily = data.get("daily", {})
    sunrise_list = daily.get("sunrise", [])
    sunset_list = daily.get("sunset", [])
    sunrise_str = time_of_day_str(sunrise_list[0]) if len(sunrise_list) > 0 else "N/A"
    sunset_str = time_of_day_str(sunset_list[0]) if len(sunset_list) > 0 else "N/A"

    year, month, day = date_from_iso(cur["time"])
    date_param = pad_int(year, 4) + "-" + pad_int(month, 2) + "-" + pad_int(day, 2)
    tz_hours = data.get("utc_offset_seconds", 0) // 3600

    moonrise_str = "N/A"
    moonset_str = "N/A"
    pct_str = "--%"
    t = 0.0
    waxing = True

    moon_resp = fetch_moon_data(loc["lat"], loc["lon"], date_param, tz_hours)
    if moon_resp["status_code"] == 200:
        props = moon_resp["json"].get("properties", {}).get("data", {})
        moondata = props.get("moondata", [])
        moonrise_str = fmt_hhmm_24(find_phen_time(moondata, "Rise"))
        moonset_str = fmt_hhmm_24(find_phen_time(moondata, "Set"))

        illum_pct = int(strip_pct(props.get("fracillum", "0%")))
        pct_str = str(illum_pct) + "%"
        waxing = props.get("curphase", "") in WAXING_PHASES
        t = 1.0 - 2.0 * (float(illum_pct) / 100.0)

    draw_moon_disc(c, 13, 18, 8, t, waxing)
    c.text(pct_str.upper(), 13, 27, font = "4x5", color = "amber", align = "center")

    c.text("SUNRISE".upper(), 30, 9, font = "4x5", color = "white", align = "left")
    c.text(sunrise_str.upper(), 126, 9, font = "4x5", color = "white", align = "right")

    c.text("SUNSET".upper(), 30, 15, font = "4x5", color = "white", align = "left")
    c.text(sunset_str.upper(), 126, 15, font = "4x5", color = "white", align = "right")

    c.text("MOONRISE".upper(), 30, 21, font = "4x5", color = "#8894AE", align = "left")
    c.text(moonrise_str.upper(), 126, 21, font = "4x5", color = "#8894AE", align = "right")

    c.text("MOONSET".upper(), 30, 27, font = "4x5", color = "#8894AE", align = "left")
    c.text(moonset_str.upper(), 126, 27, font = "4x5", color = "#8894AE", align = "right")