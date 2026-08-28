# app.star - PWS Weather Underground

def get_obs(ctx, api_units="e"):
    station = ctx.inputs.get("stationid", "")
    apikey  = ctx.inputs.get("apikey", "")
    
    if not station or not apikey:
        return None
    
    url = "https://api.weather.com/v2/pws/observations/current"
    params = {
        "stationId": station,
        "format": "json",
        "units": api_units,          # ← use the passed value
        "apiKey": apikey
    }
    
    resp = http.get(url, params=params, ttl_seconds=1800)
    
    if resp["status_code"] != 200:
        return None
    
    data = resp["json"]
    observations = data.get("observations", [])
    if not observations:
        return None
    
    return observations[0]

def get_pressure_trend(station, apikey):
    """
    Returns True if pressure swung enough in the last ~30 minutes.
    """
    url = "https://api.weather.com/v2/pws/observations/all/1day"
    params = {
        "stationId": station,
        "format": "json",
        "units": "e",
        "apiKey": apikey
    }

    resp = http.get(url, params=params, ttl_seconds=180)
    if resp["status_code"] != 200:
        return False

    observations = resp["json"].get("observations", [])
    if len(observations) < 2:
        return False

    recent = observations[-8:] if len(observations) >= 8 else observations

    pressures = []
    for o in recent:
        imp = o.get("imperial", {})
        p = imp.get("pressure")
        if p == None:
            p = imp.get("pressureMax") or imp.get("pressureMin")
        if p != None:
            pressures.append(float(p))

    if len(pressures) < 2:
        return False

    high = max(pressures)
    low = min(pressures)
    swing = high - low

    if swing >= 0.03:
        return True
    return False


def had_recent_rain(station, apikey):
    """True if any precip rate > 0 in the last ~30 minutes."""
    url = "https://api.weather.com/v2/pws/observations/all/1day"
    params = {
        "stationId": station,
        "format": "json",
        "units": "e",
        "apiKey": apikey
    }

    resp = http.get(url, params=params, ttl_seconds=180)
    if resp["status_code"] != 200:
        return False

    observations = resp["json"].get("observations", [])
    if len(observations) < 2:
        return False

    recent = observations[-8:] if len(observations) >= 8 else observations

    for o in recent:
        rate = o.get("imperial", {}).get("precipRate") or o.get("metric", {}).get("precipRate") or 0
        if float(rate) > 0:
            return True
    return False


def rain_in_last_hour(station, apikey):
    """True if any precip rate > 0 in roughly the last ~60 minutes."""
    url = "https://api.weather.com/v2/pws/observations/all/1day"
    params = {
        "stationId": station,
        "format": "json",
        "units": "e",
        "apiKey": apikey
    }

    resp = http.get(url, params=params, ttl_seconds=180)
    if resp["status_code"] != 200:
        return False

    observations = resp["json"].get("observations", [])
    if len(observations) < 2:
        return False

    # ~12 samples if 5-min reports
    recent = observations[-12:] if len(observations) >= 12 else observations

    for o in recent:
        rate = o.get("imperial", {}).get("precipRate") or o.get("metric", {}).get("precipRate") or 0
        if float(rate) > 0:
            return True
    return False

def format_ago(obs, ctx):
    epoch = int(obs.get("epoch", 0) or 0)
    if epoch <= 0:
        return "", "gray"

    now_unix = ctx.now.unix
    diff = now_unix - epoch
    if diff < 0:
        diff = 0

    mins = diff // 60

    # 3+ hours → offline
    if mins >= 180:
        return "OFFLINE", "red"

    # 1+ hour → still show age, but red
    if mins >= 60:
        hours = mins // 60
        return str(hours) + " H AGO", "red"

    # Under 1 minute
    if mins < 1:
        if diff < 30:
            return "LIVE", "gray"
        return str(diff) + " S AGO", "gray"

    return str(mins) + " M AGO", "gray"

def get_conditions(obs, is_day, uv, station, apikey, unit_label,
                   nws_list, falling_pressure, recent_rain, rain_last_hour):
    # ---- Data by unit ----
    if unit_label == "C":
        data_key = "metric"
    else:
        data_key = "imperial"

    obs_data = obs.get(data_key, {})

    temp_val = int(obs_data.get("temp", 70) or 70)
    humidity = int(obs.get("humidity", 50) or 50)
    wind = int(obs_data.get("windSpeed", 0) or 0)
    gust = int(obs_data.get("windGust", 0) or 0)
    precipTotal = float(obs_data.get("precipTotal", 0) or 0)
    rate = float(obs_data.get("precipRate", 0) or 0)
    pressure = float(obs_data.get("pressure", 30.0) or 30.0)
    dew_val = int(obs_data.get("dewpt", temp_val) or temp_val)
    solar = obs.get("solarRadiation", None)

    # Normalize thresholds to °F / inHg / mph / in
    if unit_label == "C":
        temp = int(temp_val * 9 / 5 + 32)
        dew = int(dew_val * 9 / 5 + 32)
        pressure = pressure * 0.02953
        wind = int(wind * 0.621371)
        gust = int(gust * 0.621371)
        rate = rate / 25.4
        precipTotal = precipTotal / 25.4
    else:
        temp = temp_val
        dew = dew_val

    depression = temp - dew
    if depression < 0:
        depression = 0

    # UV / solar: 0 = no sensor, >= 1 = real sensor
    has_uv = False
    uv_val = 0.0
    if uv != None:
        uv_val = float(uv)
        if uv_val >= 1:
            has_uv = True

    has_solar = False
    solar_val = -1.0
    if solar != None:
        solar_val = float(solar)
        if solar_val >= 1:
            has_solar = True

    has_sun = has_uv or has_solar

    wind_eff = wind
    if gust > wind:
        wind_eff = gust

    sun_through = False
    if is_day:
        if (has_uv and uv_val >= 2) or (has_solar and solar_val >= 200):
            sun_through = True

    # Local date
    local = obs.get("obsTimeLocal", "")
    month = 0
    day = 0
    if len(local) >= 10:
        month_str = local[5:7]
        day_str = local[8:10]
        if month_str.isdigit() and day_str.isdigit():
            month = int(month_str)
            day = int(day_str)

    is_thanksgiving = (month == 11 and day >= 22 and day <= 28)

    # NWS flags
    has_tstorm_watch = False
    has_sws = False
    for a in nws_list:
        ev = (a.get("event") or "").upper()
        if "SEVERE THUNDERSTORM WATCH" in ev:
            has_tstorm_watch = True
        if "SPECIAL WEATHER STATEMENT" in ev or "SEVERE WEATHER STATEMENT" in ev:
            has_sws = True

    # Helpers (same style as stormy_pressure)
    stormy_pressure = falling_pressure and (rate > 0.0 or humidity >= 80 or wind_eff >= 15)

    is_outflow = (
        (has_sws)
        and wind_eff >= 25
        and rate < 0.10
        and (recent_rain or rain_last_hour)
    )

    # =========================================================
    # 0. NWS WARNINGS ONLY (no watches for bolt)
    # =========================================================
    for a in nws_list:
        ev = (a.get("event") or "").upper()
        if "WATCH" in ev:
            continue
        if "TORNADO WARNING" in ev:
            return "TORNADO WARNING", "tornado.png", "red"
        if "SEVERE THUNDERSTORM WARNING" in ev:
            if rate == 0.0:
                return "SEVERE T-STORM", "thunderstorms-bolt-extreme.png", "orange"
            return "SEVERE T-STORM", "rain-thunderstorms-bolt-extreme.png", "orange"

    # =========================================================
    # 1. Extreme anomalies
    # =========================================================
    if wind_eff >= 40 and rate >= 0.50 and pressure <= 29.50:
        return "DANGEROUS", "tornado.png", "red"

    # =========================================================
    # 2. Thunderstorm layer (sensors) — requires rain; Watch ignored here
    # =========================================================
    if rate >= 0.05 and stormy_pressure:
        if rate >= 0.30 or wind_eff >= 20:
            if sun_through:
                return "HEAVY T-STORM", "day-rain-thunderstorms.png", "yellow"
            return "HEAVY T-STORM", "rain-thunderstorms-extreme.png", "yellow"

        if (has_uv and uv_val >= 3) or (has_solar and solar_val >= 250):
            if temp <= 32:
                return "THUNDER SNOW", "day-snow-thunderstorms.png", "blue"
            return "THUNDERSTORM", "day-rain-thunderstorms.png", "yellow"

        if rate >= 0.20:
            return "THUNDERSTORM", "rain-thunderstorms-extreme.png", "yellow"
        if sun_through:
            return "THUNDERSTORM", "day-thunderstorms.png", "yellow"
        return "THUNDERSTORM", "rain-thunderstorms-overcast.png", "yellow"

    # Building overcast from pressure (day / very moist only)
    if falling_pressure and rate == 0.0:
        if humidity > 92 and depression <= 4:
            return "OVERCAST", "overcast-extreme.png", "#5A636A"
        if humidity > 88 and depression <= 5 and is_day:
            return "OVERCAST", "overcast.png", "#5A636A"

    # =========================================================
    # 3. SWS approach / depart + outflow
    # =========================================================
    if is_outflow:
        if humidity <= 75:
            return "OUTFLOW BOUNDARY", "wind-alert.png", "amber"
        return "STORM DEPARTING", "rain-thunderstorms.png", "yellow"

    if has_sws and rate == 0:
        if rain_last_hour:
            return "STORM DEPARTING", "rain-thunderstorms.png", "yellow"
        if is_day:
            return "STORM APPROACHING", "day-thunderstorms.png", "yellow"
        return "STORM APPROACHING", "rain-thunderstorms-overcast.png", "yellow"

    if has_sws and rate > 0:
        if rate >= 0.15:
            return "HEAVY T-STORM", "rain-thunderstorms-extreme.png", "yellow"
        return "THUNDERSTORM", "rain-thunderstorms-overcast.png", "yellow"

    # =========================================================
    # 4. Easter eggs (below storms)
    # =========================================================
    if month == 12 and day == 25:
        if rate > 0 and temp <= 35:
            return "MERRY CHRISTMAS", "christmas-tree.png", "green" # Icon Coming Soon
        if precipTotal >= 0.1 and temp <= 35:
            return "MERRY CHRISTMAS", "christmas-tree.png", "green"

    if month == 12 and day == 24 and not is_day and rate == 0 and humidity < 70:
        if pressure > 29.90:
            return "SILENT NIGHT", "star.png", "#447d8e"

    if month == 10 and day == 31 and not is_day:
        if humidity >= 90 or pressure <= 29.80:
            return "HALLOWEEN", "jack-o-lantern.png", "purple" # Icon Coming Soon

    if is_thanksgiving and is_day and rate == 0:
        if (has_uv and uv_val >= 4) or (has_solar and solar_val >= 300) or humidity < 65:
            return "HAPPY THANKSGIVING", "turkey.png", "#633f21" # Icon Coming Soon

    if month == 12 and rate > 0 and temp <= 34:
        return "SNOW DAY", "snowman.png", "#a0e6ec"

    if temp <= 32 and precipTotal >= 6.0 and (rate > 0 or humidity >= 80):
        return "SNOWBOUND", "snowflake.png", "#a0e6ec"

    if temp <= 10 and precipTotal >= 1.0 and rate == 0:
        return "DEEP FREEZE", "beanie.png", "purple"

    # wind-spinner: March–May only
    if month >= 3 and month <= 5 and rate == 0 and wind_eff >= 20:
        return "GUSTY", "wind-spinner.png", "#5A636A"

    if (is_day and rate == 0 and recent_rain and humidity >= 65
            and ((has_uv and uv_val >= 3) or (has_solar and solar_val >= 250))):
        return "RAINBOW", "rainbow.png", "purple"

    # =========================================================
    # 5. Wind-driven rain
    # =========================================================
    if rate > 0.01 and wind_eff >= 20 and not falling_pressure:
        return "WINDY RAIN", "umbrella-wind.png", "blue"

    # =========================================================
    # 6. Liquid precip (+ sun-through)
    # =========================================================
    if rate >= 0.15:
        return "HEAVY RAIN", "rain-extreme.png", "#0055ff"
    if rate >= 0.05:
        if sun_through:
            return "RAINING", "mostly-clear-day-rain.png", "blue"
        return "RAINING", "rain-overcast.png", "blue"
    if rate >= 0.02:
        if sun_through:
            return "SHOWERS", "mostly-clear-day-rain.png", "blue"
        return "SHOWERS", "rain.png", "blue"
    if rate > 0.0:
        if sun_through:
            return "DRIZZLE", "mostly-clear-day-rain.png", "blue"
        return "DRIZZLE", "drizzle.png", "blue"

    # 7. Frozen / near-freezing
    # =========================================================
    if rate > 0.0 and temp >= 31 and temp <= 36 and humidity >= 70:
        return "SLEET", "sleet-overcast.png", "blue"
    if rate > 0.0 and temp <= 32:
        if sun_through:
            return "SNOWING", "mostly-clear-day-snow.png", "blue"
        return "SNOWING", "snow-overcast.png", "blue"
    if rate > 0.0 and temp <= 34 and temp > 32:
        return "WINTRY MIX", "sleet-overcast.png", "blue"
    if rate == 0 and temp <= 32 and humidity >= 85 and falling_pressure:
        return "SNOWING", "snow-overcast.png", "blue"
    if rate == 0 and temp <= 32 and humidity >= 80:
        return "FLURRIES", "snow.png", "blue"

    # =========================================================
    # 8. Dry anomalies
    # =========================================================
    if rate == 0 and wind_eff >= 15:
        if (has_uv and uv_val >= 4) or (has_solar and solar_val >= 400):
            if is_day:
                return "BREEZY", "wind-sun.png", "skyblue"
            return "BREEZY", "wind-clear.png", "skyblue"

        if (not has_uv) and (not has_solar) and humidity <= 55 and pressure >= 29.90:
            if is_day:
                return "BREEZY", "wind-sun.png", "skyblue"
            return "BREEZY", "wind-clear.png", "skyblue"

        return "WINDY", "wind.png", "5A636A"

    if temp >= 90 and is_day and rate == 0:
        if has_sun:
            if (has_uv and uv_val >= 7) or (has_solar and solar_val >= 700):
                return "SUNNY AND HOT", "thermometer-sun.png", "amber"
        else:
            if temp >= 100 and humidity <= 40:
                return "SUNNY AND HOT", "thermometer-sun.png", "amber"

    # Strict fog (depression)
    if rate == 0 and wind_eff < 5:
        if humidity >= 99 and depression <= 2:
            return "FOGGY", "fog.png", "#5A636A"
        if humidity >= 97 and depression <= 1 and recent_rain:
            return "FOGGY", "fog.png", "#5A636A"

 # Night sky without sun sensors (do not put this in the T-Storm section)
    if not is_day and rate == 0:
        if humidity >= 92 and depression <= 3:
            return "OVERCAST", "overcast-extreme.png", "#5A636A"
        if humidity >= 87 and depression <= 4:
            return "OVERCAST", "overcast.png", "#5A636A"
        if humidity >= 80:
            return "MOSTLY CLEAR", "mostly-clear-night.png", "skyblue"
        if pressure >= 29.90:
            return "CLEAR", "clear-night.png", "skyblue"
        return "MOSTLY CLEAR", "mostly-clear-night.png", "skyblue"

    # =========================================================
    # 9. Sky — UV / solar only if reading >= 1
    # =========================================================
    if rate == 0:
        if has_uv:
            if uv_val >= 6:
                if is_day:
                    return "SUNNY", "clear-day.png", "skyblue"
                return "CLEAR", "clear-night.png", "skyblue"
            if uv_val >= 4:
                if is_day:
                    return "MOSTLY SUNNY", "mostly-clear-day.png", "skyblue"
                return "MOSTLY CLEAR", "mostly-clear-night.png", "skyblue"
            if uv_val >= 2:
                if is_day:
                    return "PARTLY CLOUDY", "partly-cloudy-day.png", "skyblue"
                return "PARTLY CLOUDY", "partly-cloudy-night.png", "skyblue"
            return "CLOUDY", "cloudy.png", "5A636A"

        if has_solar and is_day:
            if solar_val >= 600:
                return "SUNNY", "clear-day.png", "skyblue"
            if solar_val >= 300:
                return "MOSTLY SUNNY", "mostly-clear-day.png", "skyblue"
            if solar_val >= 100:
                return "PARTLY CLOUDY", "partly-cloudy-day.png", "skyblue"
            return "CLOUDY", "cloudy.png", "5A636A"

        # Night sky without sun sensors (humid-clear fix)
        if not is_day:
            if humidity >= 95 and depression <= 3:
                return "CLOUDY", "cloudy.png", "#5A636A"
            if humidity >= 80:
                return "MOSTLY CLEAR", "mostly-clear-night.png", "#skyblue"
            if pressure >= 29.90:
                return "CLEAR", "clear-night.png", "skyblue"
            return "MOSTLY CLEAR", "mostly-clear-night.png", "#skyblue"

    # =========================================================
    # 10. Day humidity / pressure guessing
    # =========================================================
    if pressure <= 29.70 and humidity >= 85:
        return "OVERCAST", "overcast.png", "#5A636A"
    if rate == 0 and humidity >= 80:
        return "CLOUDY", "cloudy.png", "#5A636A"
    if rate == 0 and humidity > 65 and humidity < 80:
        if is_day:
            return "PARTLY CLOUDY", "partly-cloudy-day.png", "skyblue"
        return "PARTLY CLOUDY", "partly-cloudy-night.png", "skyblue"
    if pressure > 29.90 and rate == 0 and humidity >= 45 and humidity < 65:
        if is_day:
            return "MOSTLY SUNNY", "mostly-clear-day.png", "skyblue"
        return "MOSTLY CLEAR", "mostly-clear-night.png", "skyblue"

    # =========================================================
    # Default
    # =========================================================
    if is_day:
        return "SUNNY", "clear-day.png", "skyblue"
    return "CLEAR", "clear-night.png", "skyblue"

def main(c, ctx):
    location = ctx.inputs.get("location", "")

    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
    if "celsius" in unit_pref:
        api_units = "m"
        unit_label = "C"
        data_key = "metric"
    else:
        api_units = "e"
        unit_label = "F"
        data_key = "imperial"

    obs = get_obs(ctx, api_units)
    c.fill("black")

    if not obs:
        c.rect(0, 0, 63, 6, fill="red")
        c.text_center("PWS ERROR", 1, font="4x5", color="black")
        c.image("WUnderground.png", 22, 18, w=19, h=14)
        c.text_center("ENTER API KEY", 8, font="4x5", color="amber")
        c.text_center("+ STATION ID", 14, font="4x5", color="amber")
        return

    obs_data = obs.get(data_key, {})
    temp = int(obs_data.get("temp", 0) or 0)
    heat_index = int(obs_data.get("heatIndex", temp) or temp)
    wind_chill = int(obs_data.get("windChill", temp) or temp)
    uv = obs.get("uv", 0) or 0

    if location:
        loc = location.upper()[:12]
    else:
        city_name = obs.get("city") or obs.get("neighborhood") or "PWS"
        loc = city_name.upper()[:12]

    is_day = True
    local_time = obs.get("obsTimeLocal", "")
    if len(local_time) >= 13:
        hour_str = local_time[11:13]
        if hour_str.isdigit():
            hour = int(hour_str)
            is_day = hour >= 6 and hour < 19

    station = ctx.inputs.get("stationid", "")
    apikey = ctx.inputs.get("apikey", "")

    nws_list = get_nws_alerts(obs.get("lat"), obs.get("lon"))
    falling_pressure = get_pressure_trend(station, apikey)
    recent_rain = had_recent_rain(station, apikey)
    rain_last_hour = rain_in_last_hour(station, apikey)

    epoch = int(obs.get("epoch", 0) or 0)
    age_min = 0
    if epoch > 0:
        age_min = (ctx.now.unix - epoch) // 60

    if age_min >= 60:
        condition_text = "OFFLINE"
        icon_img = "not-available.png"
        header_color = "red"
    else:
        condition_text, icon_img, header_color = get_conditions(
            obs, is_day, uv, station, apikey, unit_label,
            nws_list, falling_pressure, recent_rain, rain_last_hour
        )

    update_text = condition_text.upper()
    if len(update_text) > 13:
        update_text = update_text[:13]

    text_color = "black"
    if header_color in ["red", "purple", "0055ff", "5A636A", "#FF0000", "#8B0000"]:
        text_color = "white"

    # ---- Header (condition only; location optional later) ----
    c.rect(0, 0, 63, 6, fill=header_color)
    c.text(update_text, 1, 1, font="4x5", color=text_color)

    # Optional: tiny loc on header right if short
    # if len(loc) <= 4:
    #     c.text(loc, 63 - len(loc) * 4 - 1, 1, font="4x5", color=text_color)

    # ---- Icon ----
    c.image(icon_img, 35, 8, w=29, h=23)

    # ---- Temp color (your +33 preference for C) ----
    if unit_label == "C":
        temp_for_color = int(temp * 9 / 5 + 33)
    else:
        temp_for_color = temp

    if temp_for_color >= 90:
        temp_color = "red"
    elif temp_for_color >= 80:
        temp_color = "orange"
    elif temp_for_color >= 60:
        temp_color = "green"
    elif temp_for_color >= 33:
        temp_color = "skyblue"
    else:
        temp_color = "blue"

    # ---- Temperature ----
    temp_str = str(temp)
    c.text(temp_str, 2, 8, font="8x12", color=temp_color)
    deg_x = 7 + len(temp_str) * 7 + 1
    c.rect(deg_x, 9, deg_x + 1, 10, fill=temp_color)

    # ---- Feels-like ----
    feels = temp
    feels_color = "white"
    if heat_index > temp:
        feels = heat_index
    elif wind_chill < temp:
        feels = wind_chill

    if unit_label == "C":
        feels_f = int(feels * 9 / 5 + 32)
        temp_f = int(temp * 9 / 5 + 32)
    else:
        feels_f = feels
        temp_f = temp

    diff = feels_f - temp_f
    if diff < 0:
        diff = -diff
    if diff <= 5:
        feels_color = "white"
    elif feels_f > 69:
        feels_color = "orange"
    elif feels_f < 49:
        feels_color = "blue"
    else:
        feels_color = "white"

    c.text("FEEL " + str(feels), 2, 21, font="picopixel", color=feels_color)

        # ---- Location (left-aligned, was ago) ----
    c.text(loc, 2, 27, font="4x5", color="gray")

        
def get_wind_color(val, unit_label="F"):
    # Thresholds are in mph. Convert km/h → mph when needed.
    if unit_label == "C":
        val_mph = val * 0.621371
    else:
        val_mph = val
    
    if val_mph > 30:
        return "red"
    elif val_mph > 20:
        return "orange"
    elif val_mph > 13:
        return "amber"
    else:
        return "puregreen"

def wind(c, ctx):
    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
    if "celsius" in unit_pref:
        api_units = "m"
        data_key = "metric"
        wind_u = "MPH" if False else "KM/H"
        unit_label = "C"
    else:
        api_units = "e"
        data_key = "imperial"
        wind_u = "MPH"
        unit_label = "F"

    # cleaner unit pick
    if "celsius" in unit_pref:
        api_units = "m"
        data_key = "metric"
        wind_u = "KM/H"
        unit_label = "C"
    else:
        api_units = "e"
        data_key = "imperial"
        wind_u = "MPH"
        unit_label = "F"

    obs = get_obs(ctx, api_units)
    c.fill("black")

    if not obs:
        c.rect(0, 0, 63, 6, fill="red")
        c.text_center("PWS ERROR", 1, font="4x5", color="black")
        c.image("WUnderground.png", 22, 18, w=19, h=14)
        c.text_center("ENTER API KEY", 8, font="4x5", color="amber")
        c.text_center("+ STATION ID", 14, font="4x5", color="amber")
        return

    obs_data = obs.get(data_key, {})
    speed = int(obs_data.get("windSpeed", 0) or 0)
    gust = int(obs_data.get("windGust", 0) or 0)
    direction = int(obs.get("winddir", 0) or 0)

    speed_color = get_wind_color(speed, unit_label)
    gust_color = get_wind_color(gust, unit_label)

    if speed == 0 and gust == 0:
        compass = "CALM"
    else:
        dirs = ["NORTH", "NNE", "NE", "ENE", "EAST", "ESE", "SE", "SSE",
                "SOUTH", "SSW", "SW", "WSW", "WEST", "WNW", "NW", "NNW"]
        compass = dirs[int((direction + 11.25) / 22.5) % 16]

    # Header: WIND + DIR
    c.rect(0, 0, 63, 6, fill="5A636A")
    c.text("WIND", 1, 1, font="4x5", color="yellow")
    cx = 60 - len(compass) * 4 - 1
    if cx < 28:
        cx = 28
    c.text(compass, cx, 1, font="4x5", color="yellow")

        # SPEED row
    c.text("SPEED", 2, 10, font="4x5", color="skyblue")
    speed_str = str(speed)
    # right side: number + unit
    sw = len(speed_str) * 7 + 2 + len(wind_u) * 4
    sx = 63 - sw - 1
    if sx < 28:
        sx = 28
    c.text(speed_str, sx, 9, font="6x8", color=speed_color)
    c.text(wind_u, sx + len(speed_str) * 6 + 2, 10, font="4x5", color="gray")

    # GUST row
    c.text("GUST", 2, 22, font="4x5", color="skyblue")
    gust_str = str(gust)
    gw = len(gust_str) * 7 + 2 + len(wind_u) * 4
    gx = 63 - gw - 1
    if gx < 28:
        gx = 28
    c.text(gust_str, gx, 21, font="6x8", color=gust_color)
    c.text(wind_u, gx + len(gust_str) * 6 + 2, 22, font="4x5", color="gray")

def get_rain_status(rate, unit_label="F"):
    # Convert mm → inches for the decision if needed
    if unit_label == "C":
        rate_in = rate / 25.4
    else:
        rate_in = rate
    
    if rate_in >= 0.30:
        return "DOWNPOUR", "red"
    elif rate_in >= 0.15:
        return "HEAVY", "orange"
    elif rate_in >= 0.07:
        return "MODERATE", "amber"
    elif rate_in > 0:
        return "LIGHT", "puregreen"
    else:
        return "DRY", "white"

def rain(c, ctx):
    station = ctx.inputs.get("stationid", "")
    apikey = ctx.inputs.get("apikey", "")

    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
    if "celsius" in unit_pref:
        api_units = "m"
        data_key = "metric"
        rain_u = "MM"
        unit_label = "C"
    else:
        api_units = "e"
        data_key = "imperial"
        rain_u = "IN"
        unit_label = "F"

    c.fill("black")

    if not station or not apikey:
        c.rect(0, 0, 63, 6, fill="red")
        c.text_center("PWS ERROR", 1, font="4x5", color="black")
        c.image("WUnderground.png", 22, 18, w=19, h=14)
        c.text_center("ENTER API KEY", 8, font="4x5", color="amber")
        c.text_center("+ STATION ID", 14, font="4x5", color="amber")
        return

    url = "https://api.weather.com/v2/pws/observations/current"
    params = {
        "stationId": station,
        "format": "json",
        "units": api_units,
        "apiKey": apikey
    }
    resp = http.get(url, params=params, ttl_seconds=1800)

    today = 0.0
    rate = 0.0
    if resp["status_code"] == 200:
        obs = resp["json"].get("observations", [{}])[0]
        if obs:
            obs_data = obs.get(data_key, {})
            today = float(obs_data.get("precipTotal", 0) or 0)
            rate = float(obs_data.get("precipRate", 0) or 0)

    if today <= 0.0 and rate <= 0.0:
        c.rect(0, 0, 63, 6, fill="0055ff")
        c.text_center("RAIN", 1, font="4x5", color="white")
        c.text_center("NO RAIN", 11, font="5x7", color="cyan")
        c.text_center("TODAY", 19, font="5x7", color="cyan")
        return

    status_text, status_color = get_rain_status(rate, unit_label)

    t = today / 25.4 if unit_label == "C" else today
    if t >= 5.0:
        today_color = "red"
    elif t >= 2.0:
        today_color = "orange"
    elif t >= 1.0:
        today_color = "amber"
    elif t > 0:
        today_color = "puregreen"
    else:
        today_color = "white"

    # Shorten long numbers so they fit ~30px column
    today_str = str(today)
    rate_str = str(rate)
    if len(today_str) > 4:
        today_str = today_str[:4]
    if len(rate_str) > 4:
        rate_str = rate_str[:4]

    # Header
    c.rect(0, 0, 63, 6, fill="0055ff")
    c.text_center("RAIN", 1, font="4x5", color="white")

    # Labels
    c.text("TODAY", 3, 8, font="4x5", color="skyblue")
    c.text("RATE", 39, 8, font="4x5", color="skyblue")

    left_mid = 14
    right_mid = 47

    # TODAY
    today_w = len(today_str) * 5
    c.text(today_str, left_mid - today_w // 2, 15, font="5x5", color=today_color)
    unit_w = len(rain_u) * 4
    c.text(rain_u, left_mid - unit_w // 2, 23, font="4x5", color="gray")

    # RATE
    rate_w = len(rate_str) * 5
    c.text(rate_str, right_mid - rate_w // 2, 15, font="5x5", color=status_color)
    c.text(rain_u, right_mid - unit_w // 2, 23, font="4x5", color="gray")

    # Divider
    c.rect(31, 8, 32, 30, fill="0055ff")

def atmos(c, ctx):
    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
    if "celsius" in unit_pref:
        api_units = "m"
        unit_label = "C"
        data_key = "metric"
    else:
        api_units = "e"
        unit_label = "F"
        data_key = "imperial"

    obs = get_obs(ctx, api_units)
    c.fill("black")

    if not obs:
        c.rect(0, 0, 63, 6, fill="red")
        c.text_center("PWS ERROR", 1, font="4x5", color="black")
        c.image("WUnderground.png", 22, 18, w=19, h=14)
        c.text_center("ENTER API KEY", 8, font="4x5", color="amber")
        c.text_center("+ STATION ID", 14, font="4x5", color="amber")
        return

    obs_data = obs.get(data_key, {})
    pressure = obs_data.get("pressure", 0) or 0
    humidity = int(obs.get("humidity", 0) or 0)
    dewpt = int(obs_data.get("dewpt", 0) or 0)

    # Pressure color (match main)
    if unit_label == "C":
        if pressure >= 1020:
            pres_color = "puregreen"
        elif pressure >= 1010:
            pres_color = "skyblue"
        else:
            pres_color = "orange"
    else:
        if pressure >= 29.90:
            pres_color = "puregreen"
        elif pressure >= 29.80:
            pres_color = "skyblue"
        else:
            pres_color = "orange"

    if humidity >= 70:
        hum_color = "blue"
    elif humidity >= 40:
        hum_color = "green"
    elif humidity >= 10:
        hum_color = "amber"
    else:
        hum_color = "red"

    # Header
    c.rect(0, 0, 63, 6, fill="5A636A")
    c.text_center("ATMOSPHERE", 1, font="4x5", color="white")

    # PRES row
    c.text("PRES", 1, 9, font="4x5", color="white")
    pres_str = str(pressure)
    if len(pres_str) > 5:
        pres_str = pres_str[:5]
    pw = len(pres_str) * 6
    c.text(pres_str, 64 - pw - 2, 8, font="5x7", color=pres_color)

    # HUM row
    c.text("HUMIDITY", 1, 17, font="4x5", color="white")
    hum_str = str(humidity) + "%"
    hw = len(hum_str) * 6
    c.text(hum_str, 64 - hw - 2, 16, font="5x7", color=hum_color)

    # DEW row
    c.text("DEWPOINT", 1, 26, font="4x5", color="white")
    dew_str = str(dewpt)
    dw = len(dew_str) * 6
    c.text(dew_str, 64 - dw - 2, 25, font="5x7", color="skyblue")

def get_alert_style(event, severity):
    event = (event or "").upper()
    sev = (severity or "").upper()

    # (main_color, dark_color, icon)
    if "TORNADO WARNING" in event:
        return "#FF0000", "#8B0000", "tornado.png"
    if "SEVERE THUNDERSTORM WARNING" in event:
        return "#FFA500", "#CC7000", "code-yellow-thunderstorm.png"
    if "FLASH FLOOD WARNING" in event or "FLASH FLOOD STATEMENT" in event:
        return "#FF4444", "#8B0000", "water-alert.png"
    if "TORNADO WATCH" in event:
        return "#FFFF00", "#CCAA00", "tornado.png"
    if "SEVERE THUNDERSTORM WATCH" in event:
        return "#DB7093", "#8B3A5C", "code-yellow.png"
    if "FLASH FLOOD WATCH" in event or "FLOOD WATCH" in event:
        return "#2E8B57", "#145A32", "water-alert.png"
    if "WINTER STORM WARNING" in event:
        return "#FF69B4", "#C71585", "snowflake.png"
    if "BLIZZARD WARNING" in event:
        return "#FF4500", "#B22222", "wind-snow.png"
    if "ICE STORM WARNING" in event:
        return "#DA70D6", "#8B008B", "nws.png"
    if "WINTER WEATHER ADVISORY" in event:
        return "#7B68EE", "#483D8B", "snowflake.png"
    if "EXCESSIVE HEAT WARNING" in event or "EXTREME HEAT WARNING" in event:
        return "#FF69B4", "#C71585", "fire-alert.png"
    if "HEAT ADVISORY" in event:
        return "#FF7F50", "#CC5500", "thermometer-alert.png"
    if "RED FLAG WARNING" in event:
        return "#FF1493", "#8B0A50", "code-red.png"
    if "FLOOD WARNING" in event:
        return "#00FF00", "#008B00", "water-alert.png"
    if "HURRICANE WARNING" in event or "TYPHOON WARNING" in event:
        return "#DC143C", "#8B0000", "hurricane.png"
    if "TROPICAL STORM WARNING" in event:
        return "#FF6666", "#B22222", "hurricane.png"
    if "SEVERE WEATHER STATEMENT" in event:
        return "#00FFFF", "#008B8B", "lightning-bolt-extreme.png"
    if "SPECIAL WEATHER STATEMENT" in event or "MARINE WEATHER STATEMENT" in event:
        return "#FFE4B5", "#FFDAB9", "thunderstorms-overcast.png"
    if "DENSE FOG ADVISORY" in event:
        return "#A0A8B0", "#708090", "fog.png"
    if "WIND ADVISORY" in event or "LAKE WIND ADVISORY" in event:
        return "#FFD700", "#DAA520", "wind-black.png"
    if "HIGH WIND WARNING" in event:
        return "#DAA520", "#B8860B", "wind.png"
    if "FLOOD ADVISORY" in event:
        return "#00FF7F", "#00994C", "water-alert.png"
    if "BEACH HAZARDS STATEMENT" in event:
        return "#40E0D0", "#1998A8", "water-tide-high.png"
    if "AIR QUALITY ALERT" in event:
        return "#808080", "#545454", "pollen-alert.png"

    # Fallback by severity
    if sev == "EXTREME":
        return "#FF0000", "#8B0000", "nws.png"
    if sev == "SEVERE":
        return "#FFA500", "#CC7000", "nws.png"
    if sev == "MODERATE":
        return "#FFFF00", "#CCAA00", "nws.png"
    if sev == "MINOR":
        return "#7B68EE", "#483D8B", "nws.png"

    return "white", "gray", "nws.png"

def severity_rank(severity):
    sev = (severity or "").upper()
    if sev == "EXTREME":
        return 0
    if sev == "SEVERE":
        return 1
    if sev == "MODERATE":
        return 2
    if sev == "MINOR":
        return 3
    return 4


def format_expires(expires_str):
    # expires looks like "2026-08-02T16:53:00-05:00"
    if not expires_str or len(expires_str) < 16:
        return ""

    hour_str = expires_str[11:13]
    minute = expires_str[14:16]

    if not hour_str.isdigit():
        return ""

    hour = int(hour_str)
    ampm = "AM"

    if hour >= 12:
        ampm = "PM"
        if hour > 12:
            hour = hour - 12
    if hour == 0:
        hour = 12

    return "UNTIL " + str(hour) + ":" + minute + " " + ampm

def format_expires_short(expires_str):
    # "2026-08-04T05:15:00-05:00" → "8/4 5:15AM"
    if not expires_str or len(expires_str) < 16:
        return ""

    month_str = expires_str[5:7]
    day_str = expires_str[8:10]
    hour_str = expires_str[11:13]
    minute = expires_str[14:16]

    if not hour_str.isdigit():
        return ""

    # strip leading zeros from month/day
    month = int(month_str)
    day = int(day_str)
    hour = int(hour_str)

    ampm = "AM"
    if hour >= 12:
        ampm = "PM"
        if hour > 12:
            hour = hour - 12
    if hour == 0:
        hour = 12

    return str(month) + "/" + str(day) + " " + str(hour) + ":" + minute + ampm

def clean_alert_text(s):
    if not s:
        return ""
    s = s.replace("*", " ")
    s = s.replace("\n", " ")
    s = s.replace("\r", " ")
    s = s.replace("\t", " ")
    s = s.replace("  ", " ")
    s = s.replace("  ", " ")
    s = s.replace("  ", " ")
    return s.strip().upper()


def extract_what(description):
    if not description:
        return ""

    text = description
    upper = text.upper()

    # 1. PRIMARY TARGET: Search for the standard "WHAT..." block
    start = upper.find("IMPACTS...")
    
    # 2. BACKUP TARGET: If "WHAT..." is missing, search for "IMPACTS..." instead
    if start < 0:
        start = upper.find("IMPACT...")
        offset = 9 # Length of "IMPACTS..." to skip the header text cleanly
    else:
        offset = 10  # Length of "WHAT..."

    # 3. CRUNCH AND CLIP LAYER
    if start >= 0:
        # Cut the text right after our found keyword header block
        chunk = text[start + offset:]
        chunk_upper = chunk.upper()
        end = len(chunk)
        
        # Scan forward to slice off any trailing telegraph formatting categories
        for m in ["WHERE...", "WHEN...", "LOCATIONS IMPACTED INCLUDE...", "AFFECTED AREA...", "ADDITIONAL DETAILS...", "PRECAUTIONARY/PREPAREDNESS ACTIONS..."]:
            p = chunk_upper.find(m)
            if p >= 0 and p < end:
                end = p
        chunk = chunk[:end]
        return truncate_words(clean_alert_text(chunk), 100)

    # 4. FINAL FALLBACK: If both keywords are missing, grab the top headline text line
    first = text
    nl = text.find("\n")
    if nl >= 0:
        first = text[:nl]
    return truncate_words(clean_alert_text(first), 100)

def truncate_words(s, max_len):
    if not s:
        return ""
    if len(s) <= max_len:
        return s
    cut = s[:max_len]
    sp = cut.rfind(" ")
    if sp >= 12:
        return cut[:sp]
    return cut

def get_nws_alerts(lat, lon):
    if lat == None or lon == None:
        return []

    url = "https://api.weather.gov/alerts/active"
    params = {
        "point": str(lat) + "," + str(lon)
    }
    headers = {
        "User-Agent": "(GlancePWS, pws@example.com)",
        "Accept": "application/geo+json"
    }

    resp = http.get(url, params=params, headers=headers, ttl_seconds=300)

    if resp["status_code"] != 200:
        return []

    features = resp["json"].get("features", [])
    alerts = []

    for f in features:
        props = f.get("properties", {})
        event = props.get("event", "ALERT")
        severity = props.get("severity", "Unknown")
        headline = props.get("headline", "")
        expires = props.get("expires", "") or props.get("ends", "")
        description = props.get("description", "") or ""

        description = props.get("description", "") or ""
        hazard = extract_what(description)

        # Office name (e.g. "NWS Norman OK" → "NORMAN")
        sender = props.get("senderName", "") or ""
        office = ""
        if sender:
            office = sender.replace("NWS ", "").replace("Nws ", "")
            parts = office.split(" ")
            if len(parts) > 0:
                office = parts[0].upper()[:10]

        main_c, dark_c, icon = get_alert_style(event, severity)

        alerts.append({
            "event": event,
            "severity": severity,
            "headline": headline,
            "expires": expires,
            "expires_text": format_expires(expires),
            "expires_short": format_expires_short(expires),
            "hazard": hazard,
            "color": main_c,
            "dark": dark_c,
            "icon": icon,
            "rank": severity_rank(severity),
            "office": office })

    # Sort highest severity first
    n = len(alerts)
    for i in range(n):
        for j in range(n - 1):
            if alerts[j]["rank"] > alerts[j + 1]["rank"]:
                tmp = alerts[j]
                alerts[j] = alerts[j + 1]
                alerts[j + 1] = tmp

    if len(alerts) > 3:
        return [alerts[0], alerts[1], alerts[2]]
    return alerts

def get_nws_office(lat, lon):
    if lat == None or lon == None:
        return ""

    url = "https://api.weather.gov/points/" + str(lat) + "," + str(lon)
    headers = {
        "User-Agent": "(GlancePWS, pws@example.com)",
        "Accept": "application/geo+json"
    }

    resp = http.get(url, headers=headers, ttl_seconds=3600)
    if resp["status_code"] != 200:
        return ""

    props = resp["json"].get("properties", {})

    # 1) City from relativeLocation
    city = ""
    rel = props.get("relativeLocation", {})
    if rel:
        rel_props = rel.get("properties", {})
        city = rel_props.get("city", "") or ""
    if city:
        return city.upper()[:12]

    # 2) Fallback: 3-letter CWA office id (e.g. OUN)
    cwa = props.get("cwa", "") or ""
    if cwa:
        return cwa.upper()[:12]

    return ""
def format_expires_long(expires_str):
    # "2026-08-02T16:53:00-05:00" → "EXPIRES AT SUN 4:53 PM"
    if not expires_str or len(expires_str) < 16:
        return ""

    # Day of week from date (simple doomsday-style not available — use month/day string instead if needed)
    # Many alerts use local ISO; we show weekday only if we can parse safely
    hour_str = expires_str[11:13]
    minute = expires_str[14:16]
    if not hour_str.isdigit():
        return ""

    hour = int(hour_str)
    ampm = "AM"
    if hour >= 12:
        ampm = "PM"
        if hour > 12:
            hour = hour - 12
    if hour == 0:
        hour = 12

    # Optional: short date MM/DD
    month = expires_str[5:7]
    day = expires_str[8:10]
    return "EXPIRES AT " + month + "/" + day + " " + str(hour) + ":" + minute + " " + ampm

def alerts(c, ctx):
    c.fill("black")

    station = ctx.inputs.get("stationid", "")
    apikey = ctx.inputs.get("apikey", "")

    if not station or not apikey:
        c.rect(0, 0, 63, 6, fill="red")
        c.text_center("PWS ERROR", 1, font="4x5", color="black")
        c.image("WUnderground.png", 22, 18, w=19, h=14)
        c.text_center("ENTER API KEY", 8, font="4x5", color="amber")
        c.text_center("+ STATION ID", 14, font="4x5", color="amber")
        return

    obs = get_obs(ctx, "e")
    if not obs:
        c.rect(0, 0, 63, 6, fill="red")
        c.text_center("PWS ERROR", 1, font="4x5", color="black")
        c.image("WUnderground.png", 22, 18, w=19, h=14)
        c.text_center("ENTER API KEY", 8, font="4x5", color="amber")
        c.text_center("+ STATION ID", 14, font="4x5", color="amber")
        return

    lat = obs.get("lat")
    lon = obs.get("lon")
    alert_list = get_nws_alerts(lat, lon)

    # ---------- No active alerts ----------
    if len(alert_list) == 0:
        c.round_rect(0, 0, 63, 31, 0, fill="green")
        c.round_rect(0, 0, 63, 31, 0, outline="puregreen")
        c.text_wrapped("NO ALERTS FROM THE NWS OFFICE", 5, 6, 50, font="4x5", color="black")
        return

    # Priority: Tornado Warning, then Severe T-Storm Warning → single layout
    priority = None
    for a in alert_list:
        ev = (a.get("event") or "").upper()
        if "TORNADO WARNING" in ev:
            priority = a
            break
    if priority == None:
        for a in alert_list:
            ev = (a.get("event") or "").upper()
            if "SEVERE THUNDERSTORM WARNING" in ev:
                priority = a
                break
    if priority != None:
        alert_list = [priority]

    # ---------- SINGLE ALERT ----------
    if len(alert_list) == 1:
        a = alert_list[0]
        event_name = a["event"].upper()
        fill_c = a["color"]
        edge_c = a["dark"]

        c.round_rect(0, 0, 63, 31, 0, fill=fill_c)
        c.round_rect(0, 0, 63, 31, 0, outline=edge_c)

        text_color = "black"
        if fill_c in ["#FF0000", "#8B0000", "#8B008B", "#C71585", "#DC143C", "#B22222", "#4B0082", "#FF4500"]:
            text_color = "white"

        # Icon top-right (optional — remove if text needs full width)
        c.image(a["icon"], 42, 2, w=20, h=20)

        c.text_wrapped(event_name, 2, 2, 40, font="4x5", color=text_color)

        line2 = ""
        if a["expires_text"]:
            line2 = a["expires_text"]
        if a["office"]:
            if line2:
                line2 = line2 + " " + a["office"]
            else:
                line2 = "NWS " + a["office"]
        if len(line2) > 13:
            line2 = line2[:13]
        if line2:
            c.text(line2, 2, 26, font="4x5", color=text_color)
        return

    # ---------- MULTIPLE ALERTS (max 2) ----------
    if len(alert_list) > 2:
        alert_list = [alert_list[0], alert_list[1]]

    top = alert_list[0]
    header_color = top["color"]
    header_text_color = "black"
    if header_color in ["#FF0000", "#8B0000", "#8B008B", "#C71585", "#DC143C", "#B22222", "#4B0082"]:
        header_text_color = "white"

    c.rect(0, 0, 63, 6, fill=header_color)

    count = len(alert_list)
    title = str(count) + " ALERTS"
    c.text_center(title, 1, font="4x5", color=header_text_color)

    # Each alert: name + until under it  (~12 px block)
    y = 8
    for a in alert_list:
        event_name = a["event"].upper()
        if len(event_name) > 15:
            event_name = event_name[:13]

        c.text(event_name, 1, y, font="4x5", color=a["color"])

        exp = a.get("expires_short", "")
        if not exp and a.get("expires_text"):
            exp = a["expires_text"].replace("UNTIL ", "")
        if exp:
            if len(exp) > 14:
                exp = exp[:14]
            c.text(exp, 6, y + 6, font="4x5", color="gray")

        y = y + 12