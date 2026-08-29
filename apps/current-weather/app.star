WEEKDAY_NAMES = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
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
    sign = "-" if value < 0 else ""
    cents = round_int(abs(value) * 100)
    whole = cents // 100
    frac = cents % 100
    return sign + str(whole) + "." + pad_int(frac, 2)


def format4(value):
    sign = "-" if value < 0 else ""
    units = round_int(abs(value) * 10000)
    whole = units // 10000
    frac = units % 10000
    return sign + str(whole) + "." + pad_int(frac, 4)


def zip_str(v):
    if type(v) == "int":
        # A number input the user cleared arrives as 0. Treat that as unset so
        # main() shows "SET ZIP OR LAT/LON" rather than looking up "00000" and
        # reporting the far more alarming "ZIP LOOKUP FAILED".
        if v <= 0:
            return ""
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
            "daily": "weather_code,temperature_2m_max,temperature_2m_min,wind_gusts_10m_max",
            "temperature_unit": "fahrenheit",
            "wind_speed_unit": "mph",
            "timezone": "auto",
            "forecast_days": "4",
        },
        ttl_seconds=3600,
    )


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


def get_alert_features(lat, lon):
    resp = fetch_alerts(lat, lon)
    if resp["status_code"] != 200:
        return []
    return resp["json"].get("features", [])


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


def fetch_reverse_geo(lat, lon):
    return http.get(
        "https://api.weather.gov/points/" + str(lat) + "," + str(lon),
        headers={"User-Agent": "GDN-Weather-App (glance-led-panel)", "Accept": "application/geo+json"},
        ttl_seconds=2592000,
    )


def reverse_geocode_city(lat, lon):
    resp = fetch_reverse_geo(lat, lon)
    if resp["status_code"] != 200:
        return None
    rel = resp["json"]["properties"].get("relativeLocation", {}).get("properties", {})
    city = rel.get("city", None)
    state = rel.get("state", None)
    if city == None or state == None:
        return None
    return city + ", " + state


def get_location(c, ctx):
    lat_in = ctx.inputs.get("lat", "")
    lon_in = ctx.inputs.get("lon", "")
    lat_s = str(lat_in).strip() if lat_in != None else ""
    lon_s = str(lon_in).strip() if lon_in != None else ""

    if lat_s and lon_s:
        c.fill("#000000")
        lat_r = format4(float(lat_s))
        lon_r = format4(float(lon_s))
        city = reverse_geocode_city(lat_r, lon_r)
        if city == None:
            city = lat_r + ", " + lon_r
        return {"city": city, "lat": lat_r, "lon": lon_r}

    zip = zip_str(ctx.inputs.get("zip", ""))
    if not zip:
        draw_error(c, "set zip or lat/lon")
        return None

    loc = resolve_location(zip)
    c.fill("#000000")
    if loc == None:
        draw_error(c, "zip lookup failed")
        return None
    return loc


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
        return "#0066FF"
    elif h < 30:
        return "#00AAFF"
    elif h < 50:
        return "#33CC66"
    elif h < 60:
        return "amber"
    elif h < 70:
        return "#FF8800"
    elif h < 80:
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
    loc = get_location(c, ctx)
    if loc == None:
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
    temp_str = str(round_int(temp)) if temp != None else "--"
    temp_col = temp_color(temp) if temp != None else "#888888"
    c.text(temp_str, 46, 8, font = "16x24", color = temp_col, align = "left")

    unit_x = 46 + len(temp_str) * 16 + 2
    c.text("F".upper(), unit_x, 10, font = "5x7", color = temp_col, align = "left")

    feels = cur["apparent_temperature"]
    feels_str = (str(round_int(feels)) + "° F") if feels != None else "N/A"
    feels_col = temp_color(feels) if feels != None else "#888888"
    c.text("FEELS".upper(), 126, 9, font = "4x5", color = "#888888", align = "right")
    c.text("LIKE".upper(), 126, 15, font = "4x5", color = "#888888", align = "right")
    c.text(feels_str.upper(), 126, 22, font = "5x7", color = feels_col, align = "right")


def conditions(c, ctx):
    loc = get_location(c, ctx)
    if loc == None:
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    humidity = cur["relative_humidity_2m"]
    pressure_msl = cur["pressure_msl"]
    dew_point = cur["dew_point_2m"]

    humidity_str = (str(round_int(humidity)) + "%") if humidity != None else "N/A"
    humidity_col = humidity_color(humidity) if humidity != None else "#888888"
    c.text("HUMIDITY".upper(), 2, 11, font = "4x5", color = "white", align = "left")
    c.text(humidity_str.upper(), 126, 11, font = "4x5", color = humidity_col, align = "right")

    if pressure_msl != None:
        pressure_str = (format2(pressure_msl * 0.0295299830714) + " IN").upper()
    else:
        pressure_str = "N/A"
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

    dew_str = (str(round_int(dew_point)) + "° F") if dew_point != None else "N/A"
    dew_col = temp_color(dew_point) if dew_point != None else "#888888"
    c.text("DEW POINT".upper(), 2, 23, font = "4x5", color = "white", align = "left")
    c.text(dew_str.upper(), 126, 23, font = "4x5", color = dew_col, align = "right")


def wind(c, ctx):
    loc = get_location(c, ctx)
    if loc == None:
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

    dir_str = CARDINAL_NAMES[compass_index(deg)] if deg != None else "--"
    speed_str = (str(round_int(speed)) + " MPH") if speed != None else "N/A"
    wind_val = dir_str + " @ " + speed_str
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
    loc = get_location(c, ctx)
    if loc == None:
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

    jan1_days = days_from_civil(year, 1, 1)
    day_of_year = local_days - jan1_days

    recent_days = day_of_year if day_of_year <= 92 else 92
    if recent_days < day - 1:
        recent_days = day - 1

    today_total = 0.0
    month_total = 0.0
    year_total = 0.0

    # single fetch covers both the month-to-date and year-to-date (<=92 days) windows
    recent_resp = fetch_precip_recent(loc["lat"], loc["lon"], recent_days)
    if recent_resp["status_code"] == 200:
        values = recent_resp["json"]["daily"]["precipitation_sum"]
        year_total = sum_precip(values)
        month_values = values[len(values) - day:] if len(values) >= day else values
        month_total = sum_precip(month_values)
        if len(values) > 0 and values[-1] != None:
            today_total = values[-1]

    if day_of_year > 92:
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
    loc = get_location(c, ctx)
    if loc == None:
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
    loc = get_location(c, ctx)
    if loc == None:
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

        hi = str(round_int(maxs[i])) if maxs[i] != None else "--"
        lo = str(round_int(mins[i])) if mins[i] != None else "--"
        c.text((hi + "/" + lo).upper(), cx, 24, font = "5x7", color = "white", align = "center")


def draw_warning_page(c, ctx, index):
    loc = get_location(c, ctx)
    if loc == None:
        return

    w_resp = fetch_weather(loc["lat"], loc["lon"])
    if w_resp["status_code"] != 200:
        draw_error(c, "weather error")
        return

    cur = w_resp["json"]["current"]
    time_str = time_of_day_str(cur["time"])
    draw_header(c, loc["city"], time_str)

    features = get_alert_features(loc["lat"], loc["lon"])
    if index >= len(features):
        if index > 0 and len(features) > 0:
            c.text("NO ADDITIONAL".upper(), 64, 13, font = "4x5", color = "#888888", align = "center")
            c.text("ALERTS".upper(), 64, 19, font = "4x5", color = "#888888", align = "center")
        else:
            c.text("NO ACTIVE".upper(), 64, 13, font = "4x5", color = "#888888", align = "center")
            c.text("WARNINGS".upper(), 64, 19, font = "4x5", color = "#888888", align = "center")
        return

    props = features[index]["properties"]
    warning = {"event": props.get("event", "ALERT"), "expires": props.get("expires", None)}

    c.text(warning["event"].upper(), 64, 9, font = "4x5", color = alert_color(warning["event"]), align = "center")

    if warning["expires"] != None:
        expires_str = time_of_day_str(warning["expires"])
    else:
        expires_str = "UNKNOWN"

    c.text("EXPIRES".upper(), 2, 20, font = "4x5", color = alert_color(warning["event"]), align = "left")
    c.text(expires_str.upper(), 126, 20, font = "4x5", color = alert_color(warning["event"]), align = "right")


def warning_1(c, ctx):
    draw_warning_page(c, ctx, 0)


def warning_2(c, ctx):
    draw_warning_page(c, ctx, 1)
