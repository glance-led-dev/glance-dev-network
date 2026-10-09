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
        if humidity >= 98 and depression <= 2:
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
    
     # ---- Unit preference FIRST ----
    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
 
    if "hybrid" in unit_pref:
      api_units  = "h"
      unit_label = "C"
      data_key   = "metric"
      pressure_u = "MB"
      wind_u     = "MPH"
      rain_u     = "MM"
    elif "celsius" in unit_pref:
      api_units  = "m"
      unit_label = "C"
      data_key   = "metric"
      pressure_u = "MB"
      wind_u     = "KM/H"
      rain_u     = "MM"
    else:
      api_units  = "e"
      unit_label = "F"
      data_key   = "imperial"
      pressure_u = "IN"
      wind_u     = "MPH"
      rain_u     = "IN"

    # ★ Fetch the observation AFTER units are decided
    obs = get_obs(ctx, api_units)

    c.fill("black")

    if not obs:
     # Header
     c.rect(0, 0, 191, 8, fill="red")
     c.text("PWS ERROR", 69, 1, font="5x7", color="black")
     c.image("wunderground.png", 4, 9, w=25, h=20)
     c.text("NO DATA FROM WEATHER UNDERGROUND", 32, 12, font="4x5", color="amber")
     c.text("ENTER API KEY + STATION ID", 32, 22, font="4x5", color="amber")
     return
 
    # ---- Data ----
    obs_data = obs.get(data_key, {})
    temp = int(obs_data.get("temp", 0) or 0)
    humidity = int(obs.get("humidity", 0) or 0)
    pressure   = obs_data.get("pressure", 0) or 0
    dewpt      = int(obs_data.get("dewpt", 0) or 0)
    heat_index = int(obs_data.get("heatIndex", temp) or temp)
    wind_chill = int(obs_data.get("windChill", temp) or temp)
    precip     = obs_data.get("precipRate", 0) or 0
    uv         = obs.get("uv", 0) or 0                     # UV is unit-independent

   
# Location
    if location:
        loc = location.upper()[:18]
    else:
        # 1. Try to grab the clean city name first
        # 2. Fall back to neighborhood if city is missing
        # 3. Fall back to "PWS" if everything is missing
        city_name = obs.get("city") or obs.get("neighborhood") or "Location N/A"
        loc = city_name.upper()[:18]

    
    # Feels-like logic
    if temp >= 70:
        feels = heat_index
        feels_label = "HEAT"
    else:
        feels = wind_chill
        feels_label = "CHILL"
    
    # ---- Day / Night ----
    is_day = True
    local_time = obs.get("obsTimeLocal", "")
    if len(local_time) >= 13:
        hour_str = local_time[11:13]
        if hour_str.isdigit():
            hour = int(hour_str)
            is_day = hour >= 6 and hour < 19

    # Add a variable name (like icon_img) to capture the 3rd returned value
    station = ctx.inputs.get("stationid", "")
    apikey  = ctx.inputs.get("apikey", "")
   
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

    # Flip text to white on dark backgrounds so it stays legible
    text_color = "black"
    if header_color in ["red", "purple", "0055ff", "5A636A"]:
        text_color = "white"

    # ==========================================
    # ---- Render Header ----
    # ==========================================
    c.rect(0, 0, 191, 8, fill=header_color)
    
    # Condition text on the left
    c.text(update_text, 3, 1, font="5x7", color=text_color)
    c.text_right(loc + " ", 2, font="4x5", color=text_color)

    
    # ---- Icon + Temperature ----
    c.image(icon_img, 3, 9, w=21, h=17)
    
    # After you have temp (already in the user’s unit)
    if unit_label == "C":
      # Convert displayed Celsius back to Fahrenheit for color logic
      temp_for_color = int(temp * 9 / 5 + 33)
    else:
      temp_for_color = temp

    # Now use the original Fahrenheit thresholds
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
    
    c.text(str(temp), 26, 10, font="7x14", color=temp_color)
    deg_x = 21 + len(str(temp)) * 10 + 2
    c.rect(deg_x, 11, deg_x+2, 13, fill=temp_color)

    # ---- Feels-like logic ----
    heat_index = int(obs.get("imperial", {}).get("heatIndex", temp))
    wind_chill = int(obs.get("imperial", {}).get("windChill", temp))

    # ---- Feels-like logic ----
    feels = None
    feels_color = "white"

    if heat_index > temp:
     feels = heat_index
    elif wind_chill < temp:
     feels = wind_chill
    else:
     feels = temp

    if feels != None:
      # Work in Fahrenheit for consistent thresholds
      if unit_label == "C":
        feels_f = int(feels * 9 / 5 + 32)
        temp_f  = int(temp * 9 / 5 + 32)
      else:
        feels_f = feels
        temp_f  = temp

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

    c.text("FEEL " + str(feels), 7, 26, font="4x5", color=feels_color)
    
    # ---- Dynamic colors ----
    # Air Pressure color
    if unit_label == "C":
    # mb
     if pressure >= 1020:
        pres_color = "puregreen"
     elif pressure >= 1010:
        pres_color = "skyblue"
     else:
        pres_color = "orange"
    else:
    # inHg
     if pressure >= 29.90:
        pres_color = "puregreen"
     elif pressure >= 29.80:
        pres_color = "skyblue"
     else:
        pres_color = "orange"

    # Humidity color
    if humidity >= 70:
     hum_color = "blue"
    elif humidity >= 40:
     hum_color = "green"
    elif humidity >= 10:
     hum_color = "amber"
    else:
     hum_color = "red" 

    # ---- Gauges ----
    # ---- Pressure gauge (works for both units) ----
    if unit_label == "C":          # metric / hybrid → mb
      # Map 980–1050 mb → 0–100
      pres_pct = int((pressure - 980) * 100 / 70)
    else:                          # imperial → inHg
      # Map 29.0–31.0 inHg → 0–100
      pres_pct = int((pressure - 29.0) * 50)

    pres_pct = max(0, min(100, pres_pct))   # clamp

    c.gauge(72, 31, 21, pres_pct, color=pres_color, label="")
    c.text("PRES", 62, 18, font="4x5", color=pres_color)
    pres_str = str(pressure)
    pres_x = 75 - (len(pres_str) * 3)     # 4x5 font is ~6 px wide, so half is 3
    c.text(pres_str, pres_x, 25, font="4x5", color="white")
    
    # Humidity gauge
    c.gauge(121, 31, 21, humidity, color=hum_color, label="")
    c.text("HUMID", 110, 18, font="4x5", color=hum_color)
    c.text(str(humidity) + "%", 115, 25, font="4x5", color="white")

    ago, ago_color = format_ago(obs, ctx)
    if not ago:
        local = obs.get("obsTimeLocal", "")
        if len(local) >= 16:
            ago = local[11:16]
            ago_color = "gray"
    if ago:
        x = 189 - len(ago) * 4 - 2
        if x < 0:
            x = 0
        c.text(ago, x, 26, font="4x5", color=ago_color)
    uv_color = "puregreen"
    if uv != None and uv >= 5:
      if uv >= 10:
        uv_color = "purple"
      elif uv >= 8:
        uv_color = "red"
      elif uv >= 5:
        uv_color = "orange"
      c.image("uv-index.png", 146, 8, w=20, h=17)
      c.text("UV", 165, 10, font="5x5", color=uv_color)
      c.text(str(int(uv)), 168, 16, font="7x12", color=uv_color)
    else:
        # Default: Dewpoint (icon + value)
        c.image("thermometer-raindrop.png", 146, 8, w=21, h=17)
        c.text("DEW", 163, 10, font="5x5", color="skyblue")
        c.text(str(dewpt), 165, 16, font="7x12", color="skyblue")
        dew_deg_x = 161 + len(str(dewpt)) * 9 + 1
        c.rect(dew_deg_x, 16, dew_deg_x+1, 17, fill="skyblue")
    if not ago:
        # fallback if .unix fails
        local = obs.get("obsTimeLocal", "")
        if len(local) >= 16:
            ago = local[11:16]

        
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
    # ---- Unit preference ----
    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
    
    if "hybrid" in unit_pref:
        api_units  = "h"
        data_key   = "metric"
        wind_u     = "MPH"
        unit_label = "C"          # still °C for temp, but wind stays mph in hybrid
    elif "celsius" in unit_pref:
        api_units  = "m"
        data_key   = "metric"
        wind_u     = "KM/H"
        unit_label = "C"
    else:
        api_units  = "e"
        data_key   = "imperial"
        wind_u     = "MPH"
        unit_label = "F"
    
    obs = get_obs(ctx, api_units)
    c.fill("black")
    
    if not obs:
        c.rect(0, 0, 191, 8, fill="red")
        c.text("PWS ERROR", 69, 1, font="5x7", color="black")
        c.text("NO DATA FROM WEATHER UNDERGROUND", 16, 12, font="4x5", color="amber")
        c.text("ENTER API KEY + STATION ID", 31, 22, font="4x5", color="amber")
        return
    
    obs_data = obs.get(data_key, {})
    speed = int(obs_data.get("windSpeed", 0) or 0)
    gust  = int(obs_data.get("windGust", 0) or 0)
    direction = int(obs.get("winddir", 0) or 0)
    
    speed_color = get_wind_color(speed, unit_label)
    gust_color  = get_wind_color(gust, unit_label)
    
    if speed == 0 and gust == 0:
        compass = "CALM"
    else:
        dirs = ["NORTH", "NNE", "NE", "ENE", "EAST", "ESE", "SE", "SSE",
                "SOUTH", "SSW", "SW", "WSW", "WEST", "WNW", "NW", "NNW"]
        compass = dirs[int((direction + 11.25) / 22.5) % 16]
    
    # Header
    c.rect(0, 0, 191, 8, fill="5A636A")
    header_text = "CURRENT WINDS"
    header_x = (192 - (len(header_text) * 6)) // 2
    c.text(header_text, header_x, 1, font="5x7", color="yellow")
    
    # Column 1 – Speed
    c.text("SPEED", 17, 11, font="5x7", color="skyblue")
    speed_str = str(speed)
    col1_total_w = (len(speed_str) * 7) + (len(wind_u) + 1) * 6
    col1_start_x = (62 - col1_total_w) // 2
    c.text(speed_str, col1_start_x, 20, font="7x12", color=speed_color)
    c.text(" " + wind_u, col1_start_x + len(speed_str) * 6, 20, font="6x8", color="gray")
    
    c.rect(63, 11, 64, 29, fill="yellow")
    
    # Column 2 – Gust
    c.text("GUST", 85, 11, font="5x7", color="skyblue")
    gust_str = str(gust)
    col2_total_w = (len(gust_str) * 7) + (len(wind_u) + 1) * 6
    col2_start_x = 65 + ((62 - col2_total_w) // 2)
    c.text(gust_str, col2_start_x, 20, font="7x12", color=gust_color)
    c.text(" " + wind_u, col2_start_x + len(gust_str) * 6, 20, font="6x8", color="gray")
    
    c.rect(128, 11, 129, 29, fill="yellow")
    
    # Column 3 – Direction
    c.text("DIRECTION", 134, 11, font="5x7", color="skyblue")
    compass_w = len(compass) * 7
    compass_x = 131 + ((60 - compass_w) // 2)
    c.text(compass, compass_x, 21, font="7x12", color="yellow")

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

# =============================================================================
# Rain helpers
# =============================================================================

def format_storm_time(local):
    if not local or len(local) < 16:
        return ""
    hour_str = local[11:13]
    minute = local[14:16]
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
    return str(hour) + ":" + minute + " " + ampm

def format_duration(mins):
    if mins <= 0:
        return ""
    if mins < 60:
        return str(mins) + " MIN"
    hours = mins // 60
    rem = mins % 60
    if rem == 0:
        return str(hours) + " HR"
    return str(hours) + " HR " + str(rem) + " MIN"

def pick_line(lines, seed):
    if len(lines) == 0:
        return ""
    i = seed % len(lines)
    if i < 0:
        i = 0
    return lines[i]

def get_storm_events(station, apikey, unit_label="F"):
    if not station or not apikey:
        return None

    units = "m" if unit_label == "C" else "e"
    key = "metric" if unit_label == "C" else "imperial"
    gap_min = 25

    url = "https://api.weather.com/v2/pws/observations/all/1day"
    params = {
        "stationId": station,
        "format": "json",
        "units": units,
        "apiKey": apikey,
        "numericPrecision": "decimal"
    }
    resp = http.get(url, params=params, ttl_seconds=180)
    if resp["status_code"] != 200:
        return None

    observations = resp["json"].get("observations", [])
    if len(observations) < 2:
        return None

    points = []
    for o in observations:
        block = o.get(key, {})
        rate = block.get("precipRate")
        if rate == None:
            rate = 0
        total = block.get("precipTotal")
        if total == None:
            total = 0
        points.append({
            "epoch": int(o.get("epoch", 0) or 0),
            "rate": float(rate),
            "total": float(total),
            "local": o.get("obsTimeLocal", "")
        })

    if len(points) < 2:
        return None

    storms = []
    cur = None
    last_wet_epoch = 0

    for p in points:
        if p["rate"] > 0:
            gap = 0
            if last_wet_epoch > 0:
                gap = (p["epoch"] - last_wet_epoch) // 60
            if cur == None or (last_wet_epoch > 0 and gap > gap_min):
                if cur != None:
                    storms.append(cur)
                cur = {
                    "start_epoch": p["epoch"],
                    "start_local": p["local"],
                    "end_epoch": p["epoch"],
                    "end_local": p["local"],
                    "peak": p["rate"],
                    "total_start": p["total"],
                    "total_end": p["total"]
                }
            else:
                cur["end_epoch"] = p["epoch"]
                cur["end_local"] = p["local"]
                if p["rate"] > cur["peak"]:
                    cur["peak"] = p["rate"]
                cur["total_end"] = p["total"]
            last_wet_epoch = p["epoch"]

    if cur != None:
        storms.append(cur)
    if len(storms) == 0:
        return None

    total_wet_min = 0
    for s in storms:
        d = (s["end_epoch"] - s["start_epoch"]) // 60
        if d > 0:
            total_wet_min = total_wet_min + d

    last = storms[len(storms) - 1]
    last_p = points[len(points) - 1]
    active = last_p["rate"] > 0 or (last_p["epoch"] - last["end_epoch"]) < 15 * 60

    storm_total = last["total_end"] - last["total_start"]
    if storm_total < 0:
        storm_total = last["total_end"]

    duration_min = (last["end_epoch"] - last["start_epoch"]) // 60
    if duration_min < 0:
        duration_min = 0

    return {
        "active": active,
        "start_local": format_storm_time(last["start_local"]),
        "end_local": format_storm_time(last["end_local"]),
        "duration_min": duration_min,
        "storm_total": storm_total,
        "peak_rate": last["peak"],
        "count_today": len(storms),
        "total_wet_min": total_wet_min
    }

def get_month_precip_max(station, apikey, unit_label, local_str):
    if not station or not apikey:
        return -1.0
    if not local_str or len(local_str) < 10:
        return -1.0

    year = local_str[0:4]
    month = local_str[5:7]
    day = local_str[8:10]
    if not year.isdigit() or not month.isdigit() or not day.isdigit():
        return -1.0

    start_date = year + month + "01"
    end_date = year + month + day
    units = "m" if unit_label == "C" else "e"
    key = "metric" if unit_label == "C" else "imperial"

    url = "https://api.weather.com/v2/pws/history/daily"
    params = {
        "stationId": station,
        "format": "json",
        "units": units,
        "startDate": start_date,
        "endDate": end_date,
        "apiKey": apikey,
        "numericPrecision": "decimal"
    }
    resp = http.get(url, params=params, ttl_seconds=3600)
    if resp["status_code"] != 200:
        return -1.0

    data = resp["json"]
    rows = data.get("observations", [])
    if len(rows) == 0:
        rows = data.get("summaries", [])

    max_p = -1.0
    for r in rows:
        block = r.get(key, {})
        p = block.get("precipTotal")
        if p == None:
            continue
        pf = float(p)
        if pf > max_p:
            max_p = pf
    return max_p

def rain_header(storm, rate, today, rain_u, seed, is_month_high):
    if today <= 0 and rate <= 0:
        return "RAIN MONITOR"

    if storm == None:
        return "RAIN MONITOR"

    active = storm["active"]
    count = storm["count_today"]
    start = storm["start_local"]
    end = storm["end_local"]
    dur = format_duration(storm["duration_min"])
    wet = format_duration(storm.get("total_wet_min", storm["duration_min"]))
    peak = storm.get("peak_rate", 0)

    # Live rain — no month-record lines
    if active and rate > 0:
        if count <= 1:
            lines = []
            if start and dur:
                lines.append("STARTED AT " + start + " - " + dur)
            if start:
                lines.append("STARTED AT " + start)
            if dur:
                lines.append("RAINING FOR " + dur)
            lines.append("FIRST STORM ONGOING - " + (dur if dur else "NOW"))
            if peak > 0:
                lines.append("STORM PEAK RATE " + str(peak))
            return pick_line(lines, seed)

        lines = []
        if start and dur:
            lines.append("RESUMED AT " + start + " - " + dur)
        if start:
            lines.append("RESUMED AT " + start)
        lines.append("STORM " + str(count) + " - " + (dur if dur else "NOW"))
        if start and dur:
            lines.append("STORM " + str(count) + " - " + start + " - " + dur)
        if peak > 0:
            lines.append("STORM " + str(count) + " - PEAK " + str(peak))
        lines.append("RAIN CONTINUES - " + (dur if dur else "NOW"))
        if wet:
            lines.append("WET " + wet + " TODAY")
        return pick_line(lines, seed)

    # Dry after rain — month record only here
    lines = []
    if end:
        lines.append("STORM ENDED AT " + end)
        lines.append("RAIN STOPPED - " + end)
    if count >= 1 and end:
        lines.append("STORM " + str(count) + " ENDED - " + end)
    if wet:
        lines.append("RAINED FOR ABOUT " + wet)
        lines.append("WET ABOUT " + wet + " TODAY")
    if start:
        lines.append("A PERIOD OF RAIN AT " + start)
    if start and end:
        lines.append("RAIN " + start + " - " + end)
    if count >= 2:
        lines.append(str(count) + " TOTAL STORMS TODAY")
        lines.append(str(count) + " RAIN PERIODS TODAY")
        if wet:
            lines.append(str(count) + " STORMS - WET " + wet)
        if dur:
            lines.append("LAST STORM - " + dur)
    if peak > 0:
        lines.append("STORM PEAK RATE " + str(peak))
    if count >= 1 and dur:
        lines.append("STORM " + str(count) + " DURATIONS - " + dur)

    if is_month_high:
        lines.append("WETTEST DAY THIS MONTH")
        lines.append("THIS MONTH RAIN RECORD")
        lines.append("WETTEST SO FAR THIS MONTH")

    if len(lines) == 0:
        return "RAIN MONITOR"
    return pick_line(lines, seed)

# =============================================================================
# Rain page (Scroll 192x32)
# =============================================================================

def rain(c, ctx):
    station = ctx.inputs.get("stationid", "")
    apikey = ctx.inputs.get("apikey", "")

    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
    if "hybrid" in unit_pref or "celsius" in unit_pref:
        api_units = "m" if "celsius" in unit_pref else "h"
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
        c.rect(0, 0, 191, 8, fill="red")
        c.text("PWS ERROR", 69, 1, font="5x7", color="black")
        c.text("NO DATA FROM WEATHER UNDERGROUND", 16, 12, font="4x5", color="amber")
        c.text("ENTER API KEY + STATION ID", 31, 22, font="4x5", color="amber")
        return

    url = "https://api.weather.com/v2/pws/observations/current"
    params = {
        "stationId": station,
        "format": "json",
        "units": api_units,
        "apiKey": apikey
    }
    resp = http.get(url, params=params, ttl_seconds=120)

    today = 0.0
    rate = 0.0
    local_str = ""

    if resp["status_code"] == 200:
        obs_list = resp["json"].get("observations", [])
        if len(obs_list) > 0:
            obs = obs_list[0]
            if obs:
                obs_data = obs.get(data_key, {})
                pt = obs_data.get("precipTotal")
                pr = obs_data.get("precipRate")
                today = float(pt) if pt != None else 0.0
                rate = float(pr) if pr != None else 0.0
                local_str = obs.get("obsTimeLocal", "") or ""

    if today <= 0.0 and rate <= 0.0:
        c.rect(0, 0, 191, 8, fill="0055ff")
        header_text = "RAIN MONITOR"
        header_x = (192 - len(header_text) * 6) // 2
        c.text(header_text, header_x, 1, font="5x7", color="white")
        msg = "NO RAIN DETECTED TODAY"
        msg_x = (192 - len(msg) * 7) // 2
        c.text(msg, msg_x, 16, font="6x8", color="cyan")
        return

    storm = get_storm_events(station, apikey, unit_label)

    month_max = get_month_precip_max(station, apikey, unit_label, local_str)
    is_month_high = False
    min_record = 12.7 if unit_label == "C" else 0.50
    if month_max >= 0 and today >= month_max and today >= min_record:
        is_month_high = True

    hist_url = "https://api.weather.com/v2/pws/observations/hourly/7day"
    hist_params = {
        "stationId": station,
        "format": "json",
        "units": api_units,
        "apiKey": apikey
    }
    hist_resp = http.get(hist_url, params=hist_params, ttl_seconds=300)

    rate_list = [0]
    total_list = [0]
    if hist_resp["status_code"] == 200:
        observations = hist_resp["json"].get("observations", [])
        recent12 = observations[-12:] if len(observations) >= 12 else observations
        total_list = []
        for o in recent12:
            v = o.get(data_key, {}).get("precipTotal")
            total_list.append(float(v) if v != None else 0.0)
        recent4 = observations[-4:] if len(observations) >= 4 else observations
        rate_list = []
        for o in recent4:
            v = o.get(data_key, {}).get("precipRate")
            rate_list.append(float(v) if v != None else 0.0)
    if len(total_list) == 0:
        total_list = [0]
    if len(rate_list) == 0:
        rate_list = [0]

    status_text, status_color = get_rain_status(rate, unit_label)

    seed = ctx.now.unix // 600
    if storm != None:
        seed = seed + storm["count_today"] * 3

    header_text = rain_header(storm, rate, today, rain_u, seed, is_month_high)
    header_text = header_text.upper()
    if len(header_text) > 30:
        header_text = header_text[:30]

    c.rect(0, 0, 191, 8, fill="0055ff")
    header_x = (192 - len(header_text) * 6) // 2
    if header_x < 2:
        header_x = 2
    c.text(header_text, header_x, 1, font="5x7", color="white")

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

    c.text("TODAY", 16, 11, font="5x7", color="skyblue")
    today_str = str(today)
    c.text(today_str, 11, 20, font="6x8", color=today_color)
    c.text(" " + rain_u, 10 + len(today_str) * 7, 20, font="4x5", color="gray")
    c.sparkline(total_list, 3, 28, 57, 4, color="skyblue")

    c.rect(63, 11, 64, 29, fill="0055ff")

    c.text("RATE", 84, 11, font="5x7", color="skyblue")
    rate_str = str(rate)
    c.text(rate_str, 77, 20, font="6x8", color=status_color)
    c.text(" " + rain_u, 76 + len(rate_str) * 7, 20, font="4x5", color="gray")
    c.sparkline(rate_list, 68, 28, 57, 4, color="skyblue")

    c.rect(128, 11, 129, 29, fill="0055ff")

    c.text("STORM", 145, 11, font="5x7", color="skyblue")
    storm_val = 0.0
    if storm != None:
        storm_val = storm["storm_total"]
        if storm_val < 0:
            storm_val = 0.0
    storm_str = str(storm_val)
    if len(storm_str) > 5:
        storm_str = storm_str[:5]

    st = storm_val / 25.4 if unit_label == "C" else storm_val
    if st >= 2.0:
        storm_color = "red"
    elif st >= 1.0:
        storm_color = "orange"
    elif st >= 0.25:
        storm_color = "amber"
    elif st > 0:
        storm_color = "puregreen"
    else:
        storm_color = "white"

    sw = len(storm_str) * 7
    sx = 125+ ((60 - sw) // 2)
    if sx < 130:
        sx = 130
    c.text(storm_str, sx, 20, font="6x8", color=storm_color)
    c.text(rain_u, sx + len(storm_str) * 7 + 1, 20, font="4x5", color="gray")


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
        c.rect(0, 0, 191, 8, fill="red")
        c.text("PWS ERROR", 69, 1, font="5x7", color="black")
        c.text("NO DATA FROM WEATHER UNDERGROUND", 16, 12, font="4x5", color="amber")
        c.text("ENTER API KEY + STATION ID", 31, 22, font="4x5", color="amber")
        return

    obs = get_obs(ctx, "e")
    if not obs:
        c.rect(0, 0, 191, 8, fill="red")
        c.text("PWS ERROR", 69, 1, font="5x7", color="black")
        c.text("NO DATA FROM WEATHER UNDERGROUND", 16, 12, font="4x5", color="amber")
        c.text("ENTER API KEY + STATION ID", 31, 22, font="4x5", color="amber")
        return

    lat = obs.get("lat")
    lon = obs.get("lon")
    alert_list = get_nws_alerts(lat, lon)

    # ---------- No active alerts ----------
    if len(alert_list) == 0:
        office = get_nws_office(lat, lon)
        c.round_rect(32, 1, 188, 30, 5, fill="green")
        c.round_rect(32, 1, 188, 30, 5, outline="puregreen")
        c.image("nws.png", 1, 2, w=30, h=27)
        c.text("THIS STATION IS ALL CLEAR", 35,4, font="5x7", color="black")
        if office:
            line2 = "NO ACTIVE ALERT FROM THE NWS IN " + office
        else:
            line2 = "NO ACTIVE ALERTS"
            
        # Render line2 with automatic text wrapping
        # Parameters: text, x, y, width, font, color
        c.text_wrapped(line2, 35, 13, 140, font="5x7", color="black")

        return
   # If any Tornado / Severe T-Storm WARNING exists, show single layout for that one
    # (even when other alerts are active)
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
        alert_list = [priority]  # force single-alert UI below

        # ---------- SINGLE ALERT layout ----------
    if len(alert_list) == 1:
        a = alert_list[0]
        event_name = a["event"].upper()[:27]
        fill_c = a["color"]
        edge_c = a["dark"]

        c.round_rect(0, 0, 191, 31, 0, fill=fill_c)
        c.round_rect(0, 0, 191, 31, 0, outline=edge_c)
        c.image(a["icon"], 164, 5, w=25, h=22)

        text_color = "black"
        if fill_c in ["#FF0000", "#8B0000", "#8B008B", "#C71585", "#DC143C", "#B22222", "#4B0082", "#FF4500"]:
            text_color = "white"

        # Line 1 – event name
        c.text(event_name, 3, 2, font="5x7", color=text_color)

        # Line 2 – UNTIL 4:53 PM  NWS NORMAN
        line2 = ""
        if a["expires_text"]:
            # expires_text is like "UNTIL 4:53 PM"
            line2 = a["expires_text"]
        if a["office"]:
            if line2:
                line2 = line2 + " - " + a["office"]
            else:
                line2 = "NWS " + a["office"]
        if len(line2) > 26:
            line2 = line2[:30]
        if line2:
            c.text(line2, 3, 11, font="4x5", color=text_color)

        # Line 3 – hazard with word wrap
        if a["hazard"]:
            c.text_wrapped(a["hazard"], 3, 18, 170, font="picopixel", color=text_color)
        return

    # ---------- MULTIPLE ALERTS layout (up to 3) ----------
    top = alert_list[0]
    header_color = top["color"]
    header_text_color = "black"
    if header_color in ["#FF0000", "#8B0000", "#8B008B", "#C71585", "#DC143C", "#B22222", "#4B0082"]:
        header_text_color = "white"

    c.rect(0, 0, 191, 6, fill=header_color)

    # Prefer points lookup for a reliable city/office name
    office = get_nws_office(lat, lon)
    if not office:
        office = top["office"]

    count = len(alert_list)
    if office:
        title = str(count) + " ACTIVE ALERT IN " + office
    else:
        title = str(count) + " ACTIVE ALERT FROM THE NWS"
    if len(title) > 38:
        title = title[:38]

    c.text_center(title, 1, font="4x5", color=header_text_color)

    y = 8
    idx = 1
    for a in alert_list:
        event_name = a["event"].upper()
        if len(event_name) > 25:
            event_name = event_name[:25]

        line = str(idx) + " " + event_name
        c.text(line, 2, y, font="4x5", color=a["color"])

        # Right side: 8/4 5:15AM
        exp = a.get("expires_short", "")
        if not exp and a["expires_text"]:
            exp = a["expires_text"].replace("UNTIL ", "")
        if exp:
            exp_x = 183 - len(exp) * 4 - 2
            if exp_x < 110:
                exp_x = 110
            c.text(exp, exp_x, y, font="4x5", color="gray")

        y = y + 8
        idx = idx + 1