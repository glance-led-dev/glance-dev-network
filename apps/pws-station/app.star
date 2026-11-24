# PWS Dashboard - Weather Underground personal station + NWS alerts. (192x32)
#
# Pages:
#   station — temp/feel/wind, P/H gauges, dew point
#   alerts  — active NWS alerts for the station lat/lon (or ALL CLEAR)
#
# WU:  GET .../v2/pws/observations/current  (+ .../all/1day for trends)
# NWS: GET https://api.weather.gov/alerts/active?point=lat,lon

# Tiny sun (9x9) and dewdrop (7x9) bitmaps for the station board.
SUN = [
    [0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 1, 0, 0, 1, 0],
    [0, 0, 1, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
    [1, 1, 0, 1, 1, 1, 0, 1, 1],
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 1, 0, 0],
    [0, 1, 0, 0, 1, 0, 0, 1, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0],
]
DROP = [
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 0, 0],
]

# Current-condition icons from TWC v3 observation iconCode.
CLOUD = [
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
]
RAINDROPS = [
    [0, 1, 0, 0, 1, 0, 0, 1, 0],
    [1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 0],
]
SNOWFLAKES = [
    [0, 1, 0, 0, 0, 0, 1, 0, 0],
    [1, 1, 1, 0, 0, 1, 1, 1, 0],
    [0, 1, 0, 0, 0, 0, 1, 0, 0],
]
LIGHTNING = [
    [0, 0, 1, 1, 0],
    [0, 0, 1, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 1, 0, 0, 0],
    [1, 1, 0, 0, 0],
]
FOG = [
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 0, 0],
]
MOON = [
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 1, 1, 1, 0, 0, 0, 0, 0],
    [0, 1, 1, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
]

# Slim chevron trends — read clearly at 5x5.
UP = [
    [0, 0, 1, 0, 0],
    [0, 1, 1, 1, 0],
    [1, 0, 1, 0, 1],
    [0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0],
]
DOWN = [
    [0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0],
    [1, 0, 1, 0, 1],
    [0, 1, 1, 1, 0],
    [0, 0, 1, 0, 0],
]
FLAT = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
]

# Panel chrome
LINE = "#2a3140"
MUTED = "#8b93a7"
ACCENT = "#5b8def"  # cool blue — not the humidity yellow
WINTER_BLUE = "#3f7fff"
WINTER_LIGHT = "#65d9ff"

# The comfort reading's word and colour come from one place, so the two can
# never disagree — an orange CHILL would be the board contradicting itself.
# Long phrase first, short fallback second, for the narrow slot left of the
# divider. Cold and calm both read light blue; only heat gets to be warm.
FEEL_BANDS = {
    "CHILL": ["WIND CHILL", "CHILL", WINTER_LIGHT],
    "HEAT": ["HEAT INDEX", "HEAT", "orange"],
    "FEEL": ["FEELS LIKE", "FEEL", WINTER_LIGHT],
}
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _f(v):
    if v == None:
        return 0.0
    return float(v)

def _i(v):
    return int(_f(v) + 0.5) if _f(v) >= 0 else int(_f(v) - 0.5)

def abs_f(x):
    return x if x >= 0 else -x

def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v

def upper(s):
    return str(s).upper()

def clip(c, text, font, maxw):
    # Longest prefix that actually fits, measured in glyphs rather than
    # counted in characters. Nothing in the draw API clips: a string one
    # pixel too wide loses that column silently and keeps going.
    t = str(text)
    if maxw <= 0:
        return ""
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit_clip(c, text, fonts, maxw):
    # [font, text] for the largest font that fits, hard-clipped if none do.
    # text_fit shrinks and then draws anyway when even its smallest option
    # overflows, which is how an alert name walks off the right edge.
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

def unit_block(obs, units):
    # WU nests readings under imperial / metric / uk_hybrid.
    if units == "m":
        block = obs.get("metric", None)
    else:
        block = obs.get("imperial", None)
    if block == None:
        return {}
    return block

def feel_temp(block, temp):
    # [which number it is, the number]. Prefer heat index when hot, wind
    # chill when cold, else the temperature itself.
    #
    # The name has to travel with the value. A 19-degree wind chill labelled
    # FEEL reads like the thermometer is broken, and the two are never both
    # true at once -- WU only fills heatIndex above about 80F and windChill
    # below about 50F, and returns the dry temperature for the other.
    hi = _f(block.get("heatIndex", temp))
    wc = _f(block.get("windChill", temp))
    if hi > temp + 0.5:
        return ["HEAT", hi]
    if wc < temp - 0.5:
        return ["CHILL", wc]
    return ["FEEL", temp]

def pressure_pct(pres, metric):
    # Map a typical range onto the 0-100 gauge.
    if metric:
        # mb / hPa ~ 980..1040
        return clamp((pres - 980.0) / 60.0 * 100.0, 0.0, 100.0)
    # inHg ~ 29.0..31.0
    return clamp((pres - 29.0) / 2.0 * 100.0, 0.0, 100.0)

def fmt_pres(pres, metric):
    if metric:
        return str(_i(pres))
    # two decimals for inHg
    cents = int(pres * 100 + 0.5)
    return str(cents // 100) + "." + (str(cents % 100) if cents % 100 >= 10 else "0" + str(cents % 100))

def cardinal(deg):
    # 8-point compass from degrees.
    dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    d = int(deg) % 360
    if d < 0:
        d = d + 360
    return dirs[int((d + 22.5) / 45.0) % 8]

def fmt_wind(speed, deg, metric):
    # Compact for the narrow wind column: "SW8" or "SW13".
    # The selected app units already determine mph vs km/h.
    #
    # At three digits the direction is dropped. "NW123" measures 24px at
    # 4x5 and the column holds 23, so it would cross the divider -- and
    # text_fit, having run out of ladder, draws it anyway. A hundred-plus
    # reading is the news; which way it is blowing can wait. Reachable in
    # km/h in any serious storm.
    dir = cardinal(deg)
    sp = str(_i(speed))
    if len(sp) >= 3:
        return sp
    return dir + sp

def fmt_local_datetime(obs, now):
    # PWS current supplies local observation time as YYYY-MM-DD HH:MM:SS.
    # It keeps this header in the station's timezone without another setting.
    s = str(obs.get("obsTimeLocal", ""))
    if len(s) >= 16:
        mo = int(s[5:7])
        day = int(s[8:10])
        hour = int(s[11:13])
        minute = s[14:16]
    else:
        mo = int(now.month)
        day = int(now.day)
        hour = int(now.hour)
        minute = str(now.minute)
        if len(minute) < 2:
            minute = "0" + minute
    suffix = "AM"
    if hour >= 12:
        suffix = "PM"
    hour12 = hour % 12
    if hour12 == 0:
        hour12 = 12
    return MONTHS[mo - 1] + " " + str(day) + " " + str(hour12) + ":" + minute + suffix

def severity_color(sev):
    s = upper(str(sev))
    if s == "EXTREME" or s == "SEVERE":
        return "red"
    if s == "MODERATE":
        return "orange"
    if s == "MINOR":
        return "yellow"
    return "cyan"

def alert_color(event, sev):
    e = upper(str(event))
    winter = (
        "WINTER" in e or
        "SNOW" in e or
        "ICE" in e or
        "FREEZ" in e or
        "BLIZZARD" in e or
        "COLD" in e
    )
    if winter:
        if "WARNING" in e:
            return WINTER_BLUE
        return WINTER_LIGHT
    if "WARNING" in e:
        return "red"
    if "WATCH" in e:
        return "yellow"
    if "ADVISORY" in e:
        return "orange"
    return severity_color(sev)

def short_alert_event(event):
    # Keep WARNING/WATCH/ADVISORY intact; shorten only long hazard names.
    s = upper(str(event))
    s = s.replace("SEVERE THUNDERSTORM", "SVR T-STORM")
    s = s.replace("HEAVY FREEZING SPRAY", "HVY FREEZE SPRAY")
    s = s.replace("HURRICANE FORCE WIND", "HURR FORCE WIND")
    s = s.replace("HAZARDOUS MATERIALS", "HAZMAT")
    s = s.replace("NUCLEAR POWER PLANT", "NUCLEAR PLANT")
    s = s.replace("RADIOLOGICAL HAZARD", "RAD HAZARD")
    s = s.replace("SHELTER IN PLACE", "SHELTER-IN-PLACE")
    s = s.replace("WINTER WEATHER", "WINTER WX")
    return s

def trend_dir(curr, prev, eps):
    # 1 = up, -1 = down, 0 = flat / unknown
    if prev == None:
        return 0
    d = curr - prev
    if d > eps:
        return 1
    if d < -eps:
        return -1
    return 0

def draw_trend(c, x, y, direction, up_color, down_color):
    # Skip flat — a dash next to readings looks like broken formatting.
    if direction > 0:
        c.bitmap(UP, x, y, up_color)
    elif direction < 0:
        c.bitmap(DOWN, x, y, down_color)

def draw_condition(c, x, y, code, night):
    # TWC icon codes: 3/4/37/38/47 storms; 5-18/35/41-43/46 winter;
    # 8-12/39/40/45 rain; 19-30/44 clouds; 31-36 mostly clear/sunny.
    if code in [0, 1, 2, 3, 4, 37, 38, 47]:
        c.bitmap(CLOUD, x, y, MUTED)
        c.bitmap(LIGHTNING, x + 3, y + 4, "yellow")
    elif code in [5, 6, 7, 13, 14, 15, 16, 17, 18, 35, 41, 42, 43, 46]:
        c.bitmap(CLOUD, x, y, MUTED)
        c.bitmap(SNOWFLAKES, x, y + 6, "white")
    elif code in [8, 9, 10, 11, 12, 39, 40, 45]:
        c.bitmap(CLOUD, x, y, MUTED)
        c.bitmap(RAINDROPS, x, y + 6, "cyan")
    elif code == 20:
        c.bitmap(FOG, x, y + 1, MUTED)
    elif night and code in [None, 31, 32, 33, 34]:
        c.bitmap(MOON, x, y, "#f0d24b")
    elif code in [19, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 44]:
        c.bitmap(CLOUD, x, y, MUTED)
    else:
        c.bitmap(SUN, x, y, "yellow")

def local_night(obs, now):
    # PWS local time is the reliable fallback when Currents On Demand is
    # unavailable. Keep the daytime icon through 8:59 PM.
    s = str(obs.get("obsTimeLocal", ""))
    if len(s) >= 13:
        hour = int(s[11:13])
    else:
        hour = int(now.hour)
    return hour >= 21 or hour < 6

def hist_vals(obs, units):
    # Rapid-history rows use *Avg fields inside imperial/metric.
    block = unit_block(obs, units)
    temp = block.get("tempAvg", block.get("temp", None))
    pres = block.get("pressureMax", block.get("pressure", None))
    # Prefer explicit trend when WU sends it.
    pt = block.get("pressureTrend", None)
    humid = obs.get("humidityAvg", obs.get("humidity", None))
    return {
        "temp": None if temp == None else _f(temp),
        "pres": None if pres == None else _f(pres),
        "humid": None if humid == None else _f(humid),
        "ptrend": None if pt == None else _f(pt),
        "epoch": _f(obs.get("epoch", 0)),
    }

def fetch_trends(key, station, units, curr_temp, curr_pres, curr_humid):
    # Compare current reading to ~1 hour earlier from rapid history.
    r = http.get(
        "https://api.weather.com/v2/pws/observations/all/1day",
        params = {
            "stationId": station,
            "format": "json",
            "units": units,
            "numericPrecision": "decimal",
            "apiKey": key,
        },
        ttl_seconds = 300,
    )
    if r["status_code"] != 200:
        return {"temp": 0, "pres": 0, "humid": 0}

    j = r["json"]
    if not j:
        return {"temp": 0, "pres": 0, "humid": 0}
    rows = j.get("observations", None)
    if rows == None or len(rows) < 2:
        return {"temp": 0, "pres": 0, "humid": 0}

    # History is usually oldest→newest; pick a row ~45–90 minutes before the latest.
    latest = hist_vals(rows[len(rows) - 1], units)
    target = latest["epoch"] - 3600
    if target < 0:
        target = 0
    prev = hist_vals(rows[0], units)
    best_dist = abs_f(prev["epoch"] - target)
    for i in range(len(rows) - 1):
        h = hist_vals(rows[i], units)
        dist = abs_f(h["epoch"] - target)
        if dist < best_dist:
            best_dist = dist
            prev = h

    # Pressure: WU sometimes sends pressureTrend on the latest row (+/0/-).
    if latest["ptrend"] != None and latest["ptrend"] != 0:
        pdir = 1 if latest["ptrend"] > 0 else -1
    else:
        pdir = trend_dir(curr_pres, prev["pres"], 0.02 if units != "m" else 0.3)

    # Temp eps: 0.3F / 0.2C; humidity eps: 1%
    t_eps = 0.2 if units == "m" else 0.3
    return {
        "temp": trend_dir(curr_temp, prev["temp"], t_eps),
        "pres": pdir,
        "humid": trend_dir(curr_humid, prev["humid"], 1.0),
    }

def fetch_modeled_conditions(lat, lon):
    # PWS hardware does not observe cloud cover. Open-Meteo supplies a current
    # WMO weather code at the station coordinates as a sky-condition cross-check.
    if lat == 0 and lon == 0:
        return {"icon": None, "phrase": "", "night": None}
    r = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": str(lat),
            "longitude": str(lon),
            "current": "weather_code,is_day",
            "timezone": "auto",
        },
        ttl_seconds = 300,
    )
    if r["status_code"] != 200:
        return {"icon": None, "phrase": "", "night": None}
    j = r["json"]
    if not j:
        return {"icon": None, "phrase": "", "night": None}
    current = j.get("current", None)
    if current == None:
        return {"icon": None, "phrase": "", "night": None}
    raw_code = current.get("weather_code", None)
    if raw_code == None:
        return {"icon": None, "phrase": "", "night": None}
    code = int(raw_code)
    is_day = int(current.get("is_day", 1)) == 1
    if code == 0 or code == 1:
        icon = 32 if is_day else 31
    elif code == 2 or code == 3:
        icon = 26
    elif code == 45 or code == 48:
        icon = 20
    elif code in [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]:
        icon = 12
    elif code in [71, 73, 75, 77, 85, 86]:
        icon = 16
    elif code in [95, 96, 99]:
        icon = 4
    else:
        icon = None
    return {"icon": icon, "phrase": "", "night": not is_day}

def fetch_conditions(key, lat, lon, units):
    # Cross-check TWC Currents On Demand against modeled sky cover. A modeled
    # cloud/fog/precip icon may replace an incorrect clear result.
    modeled = fetch_modeled_conditions(lat, lon)
    if lat == 0 and lon == 0:
        return modeled
    r = http.get(
        "https://api.weather.com/v3/wx/observations/current",
        params = {
            "geocode": str(lat) + "," + str(lon),
            "units": units,
            "language": "en-US",
            "format": "json",
            "apiKey": key,
        },
        ttl_seconds = 300,
    )
    if r["status_code"] != 200:
        return modeled
    j = r["json"]
    if not j:
        return modeled
    icon = j.get("iconCode", None)
    day_or_night_raw = j.get("dayOrNight", None)
    day_or_night = "" if day_or_night_raw == None else upper(str(day_or_night_raw))
    observed = {
        "icon": None if icon == None else int(icon),
        "phrase": str(j.get("wxPhraseLong", "")),
        "night": None if day_or_night == "" else day_or_night == "N",
    }
    if observed["icon"] == None:
        return modeled
    if observed["icon"] in [31, 32, 33, 34] and modeled["icon"] not in [None, 31, 32, 33, 34]:
        return modeled
    return observed

# ---------- fetch ----------

def fetch_pws(ctx):
    key = _s(ctx, "apikey", "")
    station = _s(ctx, "station", "").upper()
    units = _s(ctx, "units", "e").lower()
    label = upper(_s(ctx, "label", "MY STATION"))

    if not key:
        return {"ok": False, "title": "NO DATA", "sub": "ADD WU API KEY"}
    if not station:
        return {"ok": False, "title": "NO STATION", "sub": "SET STATION ID"}

    r = http.get(
        "https://api.weather.com/v2/pws/observations/current",
        params = {
            "stationId": station,
            "format": "json",
            "units": units,
            "numericPrecision": "decimal",
            "apiKey": key,
        },
        ttl_seconds = 300,
    )
    st = r["status_code"]
    if st == 401 or st == 403:
        return {"ok": False, "title": "BAD API KEY", "sub": "CHECK WU KEY"}
    if st == 404:
        return {"ok": False, "title": "BAD STATION", "sub": station + " NOT FOUND"}
    if st == 429:
        return {"ok": False, "title": "RATE LIMITED", "sub": "TRY AGAIN LATER"}
    if st != 200:
        return {"ok": False, "title": "WU ERROR", "sub": "HTTP " + str(st)}

    j = r["json"]
    if not j:
        return {"ok": False, "title": "NO DATA", "sub": "EMPTY RESPONSE"}

    # Expired / missing observations often come back as an errors object.
    if j.get("errors", None) != None:
        return {"ok": False, "title": "DATA EXPIRED", "sub": "STATION OFFLINE"}

    obs_list = j.get("observations", None)
    if obs_list == None or len(obs_list) == 0:
        return {"ok": False, "title": "NO OBS", "sub": "NO RECENT READING"}

    obs = obs_list[0]
    block = unit_block(obs, units)
    temp = _f(block.get("temp", 0))
    feelpair = feel_temp(block, temp)
    dew = _f(block.get("dewpt", 0))
    pres = _f(block.get("pressure", 0))
    precip_rate = _f(block.get("precipRate", 0))
    humid = _f(obs.get("humidity", 0))
    wind = _f(block.get("windSpeed", 0))
    # winddir lives on the observation root in WU current.
    wdir = _f(obs.get("winddir", block.get("winddir", 0)))
    metric = units == "m"
    trends = fetch_trends(key, station, units, temp, pres, humid)
    lat = _f(obs.get("lat", 0))
    lon = _f(obs.get("lon", 0))
    conditions = fetch_conditions(key, lat, lon, units)
    # The station's rain gauge is more local than the gridded condition icon.
    # Any positive precip rate overrides a clear/sun/moon response.
    if precip_rate > 0:
        freezing = temp <= 1 if metric else temp <= 34
        conditions["icon"] = 16 if freezing else 12
    # Product choice: don't switch clear-sky art to the moon before 9 PM,
    # even when Weather.com marks the period as night earlier.
    night = local_night(obs, ctx.now)

    return {
        "ok": True,
        "label": label,
        "temp": temp,
        "feel": feelpair[1],
        "feelkind": feelpair[0],
        "dew": dew,
        "pres": pres,
        "precip_rate": precip_rate,
        "humid": humid,
        "wind": wind,
        "wdir": wdir,
        "icon": conditions["icon"],
        "condition": conditions["phrase"],
        "night": night,
        "datetime": fmt_local_datetime(obs, ctx.now),
        "metric": metric,
        "lat": lat,
        "lon": lon,
        "station": str(obs.get("stationID", station)),
        "t_temp": trends["temp"],
        "t_pres": trends["pres"],
        "t_humid": trends["humid"],
    }

def fetch_alerts(lat, lon):
    if lat == 0 and lon == 0:
        return {"ok": False, "title": "NO LOCATION", "sub": "STATION HAS NO LAT/LON"}

    # weather.gov requires a descriptive User-Agent.
    point = str(lat) + "," + str(lon)
    r = http.get(
        "https://api.weather.gov/alerts/active",
        headers = {
            "User-Agent": "(glance-pws-station, reyos86@github)",
            "Accept": "application/geo+json",
        },
        params = {"point": point},
        ttl_seconds = 300,
    )
    st = r["status_code"]
    if st != 200:
        return {"ok": False, "title": "NWS ERROR", "sub": "HTTP " + str(st)}

    j = r["json"]
    if not j:
        return {"ok": False, "title": "NWS ERROR", "sub": "EMPTY RESPONSE"}

    feats = j.get("features", [])
    if feats == None:
        feats = []

    # Product priority requested for the board:
    # WARNING first, then ADVISORY, then WATCH, then everything else.
    warnings = []
    advisories = []
    watches = []
    others = []
    for i in range(len(feats)):
        props = feats[i].get("properties", {})
        if props == None:
            props = {}
        event = upper(str(props.get("event", "ALERT")))
        sev = str(props.get("severity", ""))
        headline = upper(str(props.get("headline", "")))
        title = short_alert_event(event)
        item = {
            "event": title,
            "sev": sev,
            "color": alert_color(event, sev),
            "headline": headline,
        }
        if "WARNING" in event:
            warnings.append(item)
        elif "ADVISORY" in event:
            advisories.append(item)
        elif "WATCH" in event:
            watches.append(item)
        else:
            others.append(item)

    ordered = warnings + advisories + watches + others
    return {"ok": True, "items": ordered[0:3], "count": len(feats)}

def draw_header(c, title, accent, center_text = ""):
    # Title only — no underline under the glyphs (that was crowding the letters).
    #
    # The stamp is measured first and the name is fitted into what is left.
    # A 12-character slice was close enough for "MY STATION", but it is the
    # glyphs that collide, not the characters: twelve wide ones at 5x7 run to
    # x=63, and a station named in a hurry can be anything.
    swid = 0
    if center_text != "":
        # Observation stamp, right-aligned 10 px in from the edge, same row.
        # The board refreshes every 30 minutes, so this is the as-of.
        stamp = "UPDATED: " + center_text
        swid = c.text_width(stamp, "4x5") + 4
        c.text(stamp, c.width - 10, 2, font = "4x5", color = MUTED,
               align = "right")
    c.text(clip(c, upper(str(title)), "5x7", c.width - 13 - swid), 3, 1,
           font = "5x7", color = "white")
    c.line(0, 11, c.width - 1, 11, LINE)

def _err(c, d, accent):
    c.fill("black")
    draw_header(c, "PWS DASH", accent)
    c.text(d["title"], 3, 15, font = "6x8", color = "orange")
    c.text(d["sub"], 3, 26, font = "4x5", color = MUTED)

# ---------- pages ----------

def station(c, ctx):
    d = fetch_pws(ctx)
    c.fill("black")
    if not d["ok"]:
        _err(c, d, ACCENT)
        return

    draw_header(c, d["label"], ACCENT, d["datetime"])

    # ---- Temp / wind / feel (left) ----
    # Larger temp at left; wind gets its own two rows at right.
    draw_condition(c, 2, 13, d["icon"], d["night"])
    tstr = str(_i(d["temp"]))
    c.text(tstr, 14, 13, font = "7x12", color = "#ff3344")
    deg_x = 14 + c.text_width(tstr, "7x12") + 2
    c.fill_circle(deg_x + 1, 14, 1, "white")
    draw_trend(c, deg_x + 5, 14, d["t_temp"], "#ff3344", "cyan")

    wtxt = fmt_wind(d["wind"], d["wdir"], d["metric"])
    c.text("WIND", 45, 13, font = "4x5", color = MUTED)
    c.text_fit(wtxt, 45, 19, ["5x7", "4x5"], color = "white", maxw = 23)
    # Comfort reading. The band carries the word and the colour together.
    #
    # It starts at x=3, not under the temperature at x=14: the condition art
    # above it stops at y=21, so the bottom row owns the icon column too.
    # That is what makes the full phrase possible -- "WIND CHILL -12" and
    # "HEAT INDEX 103" both measure 62px, and the 54 left beside the
    # temperature could only ever hold the short form.
    # Measured to x=68, one clear pixel short of the divider at x=70.
    band = FEEL_BANDS.get(d["feelkind"], FEEL_BANDS["FEEL"])
    fval = str(_i(d["feel"]))
    ftxt = band[0] + " " + fval
    if c.text_width(ftxt, "4x5") > 65:
        ftxt = band[1] + " " + fval
    c.text(clip(c, ftxt, "4x5", 65), 3, 27, font = "4x5", color = band[2])

    # Dividers
    c.line(70, 13, 70, 30, LINE)
    c.line(148, 13, 148, 30, LINE)

    # ---- Pressure + humidity ----
    # Labels sit BESIDE each arc. Readings sit BELOW at y=27.
    # These regions do not share pixels.
    pp = pressure_pct(d["pres"], d["metric"])
    hp = clamp(d["humid"], 0.0, 100.0)

    ptxt = fmt_pres(d["pres"], d["metric"])
    c.text("PRES", 74, 14, font = "4x5", color = MUTED)
    c.gauge(101, 21, 7, pp, color = "#3ecf6a", bg = "#1c212b",
            label = None, thickness = 2)
    c.text(ptxt, 92, 27, font = "4x5", color = "white", align = "center")
    draw_trend(c, 92 + c.text_width(ptxt, "4x5") // 2 + 3, 27,
               d["t_pres"], "#3ecf6a", "#ff3344")

    htxt = str(_i(d["humid"])) + "%"
    c.text("HUM", 112, 14, font = "4x5", color = MUTED)
    c.gauge(139, 21, 7, hp, color = "#f0d24b", bg = "#1c212b",
            label = None, thickness = 2)
    c.text(htxt, 126, 27, font = "4x5", color = "white", align = "center")
    draw_trend(c, 126 + c.text_width(htxt, "4x5") // 2 + 3, 27,
               d["t_humid"], "#f0d24b", "cyan")

    # ---- Dew: number first, label underneath (never on the digits) ----
    c.bitmap(DROP, 154, 14, "cyan")
    c.text(str(_i(d["dew"])), 166, 14, font = "7x12", color = "cyan")
    c.text("DEW", 170, 27, font = "4x5", color = MUTED, align = "center")

def alerts(c, ctx):
    d = fetch_pws(ctx)
    c.fill("black")
    if not d["ok"]:
        _err(c, d, "orange")
        return

    a = fetch_alerts(d["lat"], d["lon"])
    if not a["ok"]:
        _err(c, a, "orange")
        return

    if a["count"] == 0:
        draw_header(c, "ALERTS", "#3ecf6a")
        # y=14, not 15: a 12-row glyph at 15 ends on row 26 and the line
        # below starts on 27, leaving the two rows touching.
        c.text("ALL CLEAR", c.width // 2, 14, font = "7x12", color = "#3ecf6a",
               align = "center")
        c.text("NO ACTIVE WARNINGS", c.width // 2, 27, font = "4x5", color = MUTED,
               align = "center")
        return

    # Active alerts — rail color matches top severity
    top = a["items"][0]
    draw_header(c, "ALERTS (" + str(a["count"]) + ")", top["color"])

    # fit_clip, not text_fit: an unusually long event name reaching the end
    # of the ladder still draws, and the renderer loses the overflow without
    # saying so. The worst NWS names survive short_alert_event intact.
    t1 = fit_clip(c, top["event"], ["6x8", "5x7", "4x5"], c.width - 10)
    c.text(t1[1], 5, 14, font = t1[0], color = top["color"])
    if len(a["items"]) > 1:
        second = a["items"][1]
        t2 = fit_clip(c, second["event"], ["5x7", "4x5"], c.width - 10)
        c.text(t2[1], 5, 25, font = t2[0], color = second["color"])
