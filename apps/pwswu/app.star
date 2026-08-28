# app.star - PWS Weather Underground (Version 2.0)

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
    Returns True if pressure has risen or fallen by 0.10 inHg
    within the last ~30 minutes.
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
    
    # Take the most recent readings (last ~30 min)
    # Most PWS report every 5 minutes → last 6–8 observations ≈ 30 min
    recent = observations[-8:] if len(observations) >= 8 else observations
    
    pressures = []
    for o in recent:
        imp = o.get("imperial", {})
        p = imp.get("pressure")
        if p == None:
            # fallback for some stations
            p = imp.get("pressureMax") or imp.get("pressureMin")
        if p != None:
            pressures.append(float(p))
    
    if len(pressures) < 2:
        return False
    
    # Biggest swing in the window
    high = max(pressures)
    low = min(pressures)
    swing = high - low
    
    # Trigger on ±0.10 inHg change
    if swing >= 0.007:
        return True
    
    return False

def had_recent_rain(station, apikey):
    """
    Returns True if there was any measurable rain in the last ~30 minutes.
    """
    url = "https://api.weather.com/v2/pws/observations/all/1day"
    params = {
        "stationId": station,
        "format": "json",
        "units": "e",          # we only care about > 0, so units don't matter much
        "apiKey": apikey
    }
    
    resp = http.get(url, params=params, ttl_seconds=180)
    
    if resp["status_code"] != 200:
        return False
    
    observations = resp["json"].get("observations", [])
    if len(observations) < 2:
        return False
    
    # Last ~30 min (most stations report every 5 min → last 6–8 records)
    recent = observations[-8:] if len(observations) >= 8 else observations
    
    for o in recent:
        rate = o.get("imperial", {}).get("precipRate") or o.get("metric", {}).get("precipRate") or 0
        if float(rate) > 0:
            return True
    
    return False

def get_conditions(obs, is_day, uv, station, apikey, unit_label="F"):
    # Pick the correct data object
    if unit_label == "C":
        data_key = "metric"
    else:
        data_key = "imperial"
    
    obs_data = obs.get(data_key, {})
    
    temp_val  = int(obs_data.get("temp", 70) or 70)
    humidity  = int(obs.get("humidity", 50) or 50)
    wind      = int(obs_data.get("windSpeed", 0) or 0)
    gust      = int(obs_data.get("windGust", 0) or 0)
    precipTotal = float(obs_data.get("precipTotal", 0) or 0)
    rate      = float(obs_data.get("precipRate", 0) or 0)
    pressure  = float(obs_data.get("pressure", 30.0) or 30.0)
    
    # Normalize temperature to Fahrenheit for all rule decisions
    if unit_label == "C":
        temp = int(temp_val * 9 / 5 + 32)
    else:
        temp = temp_val
    
    # Pressure: convert mb → inHg so existing thresholds still work
    if unit_label == "C":
        pressure = pressure * 0.02953          # mb to inHg
    
    # Wind: convert km/h → mph if needed (for the extreme wind rules)
    if unit_label == "C":
        wind = int(wind * 0.621371)
        gust = int(gust * 0.621371)
    
    # Rain rate: convert mm/h → in/h if needed
    if unit_label == "C":
        rate = rate / 25.4
        precipTotal = precipTotal / 25.4
    
    falling_pressure = get_pressure_trend(station, apikey)
    
    # 1. Extreme Anomalies
    if wind >= 40 and rate >= 0.50 and pressure <= 29.50:
        return "DANGEROUS", "tornado.png", "red"
    
    # 2. Thunderstorm Layer
    if (rate >= 0.15 or wind >= 20) and falling_pressure:
        return "SEVERE T-STORM", "thunderstorms-extreme-rain.png", "orange"
    if rate >= 0.05 and falling_pressure:
        return "THUNDERSTORM", "thunderstorms-overcast.png", "yellow"
    if rate > 0.0 and falling_pressure:
        return "THUNDERSTORM", "thunderstorms-rain.png", "yellow"
    if falling_pressure and rate == 0.0 and humidity > 75:
        return "OVERCAST", "extreme.png", "5A636A"
    
    # 3. Wind-Driven Rain
    if rate > 0.01 and wind >= 20 and not falling_pressure:
        return "WINDY RAIN", "umbrella-wind.png", "blue"
    
    # 4. Standard Liquid Precipitation
    if rate >= 0.15:
        return "HEAVY RAIN", "extreme-rain.png", "0055ff"
    if rate >= 0.05:
        return "RAINING", "rain.png", "blue"
    if rate >= 0.02:
        return "SHOWERS", "drizzle.png", "blue"
    if rate > 0.0:
        return "DRIZZLE", "raindrops.png", "blue"
   
    # 5. Frozen Precipitation
    if rate > 0.0 and temp >= 31 and temp <= 35:
        return "SLEET", "sleet.png", "blue"
    if rate == 0 and temp <= 32 and humidity >= 85 and falling_pressure:
        return "SNOWING", "snow.png", "blue"
    if rate == 0 and temp <= 32 and humidity >= 80:
        return "FLURRIES", "snow.png", "blue"
    
    # 6. Dry Environmental Anomalies
    if rate == 0 and wind >= 15:
        return "WINDY", "wind.png", "5A636A"
    if temp >= 90 and is_day and (humidity <= 39 or (uv != None and uv >= 5)):
        return "SUNNY AND HOT", "thermometer-sun.png", "amber"

    if rate == 0 and humidity >= 95 and not had_recent_rain(station, apikey):
      if is_day:
        return "FOGGY", "fog-day.png", "5A636A"
      else:
        return "FOGGY", "fog-night.png", "5A636A"
    
    # 7. Ambient Sky Guessing
    if pressure <= 29.70 and precipTotal >= 0.0 and humidity >= 65:
        return "OVERCAST", "overcast.png", "5A636A"
    if rate == 0 and humidity >= 65:
        return "CLOUDY", "cloudy.png", "5A636A"
    if rate == 0 and humidity >= 40 and humidity <= 65:
     if is_day:
        return "PARTLY CLOUDY", "partly-sun-day.png", "skyblue"
     else:
        return "PARTLY CLOUDY", "partly-cloudy-night.png", "skyblue"
    
    # Default fallback
    if is_day:
        return "SUNNY", "clear-day.png", "skyblue"
    else:
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
     c.image("WUnderground.png", 4, 9, w=25, h=20)
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
        loc = location.upper()[:16]
    else:
        # 1. Try to grab the clean city name first
        # 2. Fall back to neighborhood if city is missing
        # 3. Fall back to "PWS" if everything is missing
        city_name = obs.get("city") or obs.get("neighborhood") or "Location N/A"
        loc = city_name.upper()[:16]

    
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

    condition_text, icon_img, header_color = get_conditions(
    obs, is_day, uv, station, apikey, unit_label)
    
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
    c.text(update_text, 2, 1, font="5x7", color=text_color)
    
    # Location text on the right
    update_x = 192 - (len(loc) * 6) - 2
    c.text(loc, update_x, 1, font="5x7", color=text_color)

    
    # ---- Icon + Temperature ----
    c.image(icon_img, 2, 5, w=24, h=24)
    
    # After you have temp (already in the user’s unit)
    if unit_label == "C":
      # Convert displayed Celsius back to Fahrenheit for color logic
      temp_for_color = int(temp * 9 / 5 + 32)
    else:
      temp_for_color = temp

    # Now use the original Fahrenheit thresholds
    if temp_for_color > 99:
      temp_color = "purple"
    elif temp_for_color > 89:
      temp_color = "red"
    elif temp_for_color > 79:
      temp_color = "orange"
    elif temp_for_color > 59:
      temp_color = "green"
    elif temp_for_color > 33:
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

    # ---- Dynamic Right Column: UV Override (Threshold >= 5) ----
    if uv != None and uv >= 4:
        # Determine UV color threshold
        if uv >= 10:
            uv_color = "purple"
        elif uv >= 8:
            uv_color = "red"
        elif uv >= 5:
            uv_color = "orange"
        elif uv >= 3:
            uv_color = "yellow"
        else:
            uv_color = "puregreen"

    if uv != None and uv >= 5:
        # UV Index (icon + value matching dewpoint design)
        c.image("uv-index.png", 144, 9, w=24, h=24) # Replace with your UV icon asset name
        c.text("UV", 166, 10, font="5x5", color=uv_color)
        c.text(str(int(uv)), 168, 17, font="8x12", color=uv_color)
    else:
        # Default: Dewpoint (icon + value)
        c.image("thermometer-raindrop.png", 142, 11, w=24, h=24)
        c.text("DEW", 164, 10, font="5x5", color="skyblue")
        c.text(str(dewpt), 165, 17, font="8x12", color="skyblue")
        dew_deg_x = 165 + len(str(dewpt)) * 9 + 1
        c.rect(dew_deg_x, 18, dew_deg_x+1, 19, fill="skyblue")


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

def rain(c, ctx):
    station = ctx.inputs.get("stationid", "")
    apikey  = ctx.inputs.get("apikey", "")
    
    # ---- Unit preference ----
    unit_pref = str(ctx.inputs.get("temperatureunit", "Fahrenheit")).lower()
    
    if "hybrid" in unit_pref or "celsius" in unit_pref:
        api_units  = "m" if "celsius" in unit_pref else "h"
        data_key   = "metric"
        rain_u     = "MM"
        unit_label = "C"
    else:
        api_units  = "e"
        data_key   = "imperial"
        rain_u     = "IN"
        unit_label = "F"
    
    c.fill("black")
    
    if not station or not apikey:
        c.rect(0, 0, 191, 8, fill="red")
        c.text("PWS ERROR", 69, 1, font="5x7", color="black")
        c.text("NO DATA FROM WEATHER UNDERGROUND", 16, 12, font="4x5", color="amber")
        c.text("ENTER API KEY + STATION ID", 31, 22, font="4x5", color="amber")
        return
    
    # ---- Current observation ----
    url = "https://api.weather.com/v2/pws/observations/current"
    params = {
        "stationId": station,
        "format": "json",
        "units": api_units,
        "apiKey": apikey
    }
    resp = http.get(url, params=params, ttl_seconds=1800)
    
    today = 0.0
    rate  = 0.0
    
    if resp["status_code"] == 200:
        obs = resp["json"].get("observations", [{}])[0]
        if obs:
            obs_data = obs.get(data_key, {})
            today = float(obs_data.get("precipTotal", 0) or 0)
            rate  = float(obs_data.get("precipRate", 0) or 0)
    
    # ---- Early exit when no rain today ----
    if today <= 0.0 and rate <= 0.0:
        c.rect(0, 0, 191, 8, fill="0055ff")
        header_text = "RAIN MONITOR"
        header_x = (192 - (len(header_text) * 6)) // 2
        c.text(header_text, header_x, 1, font="5x7", color="white")
        
        msg = "NO RAIN DETECTED TODAY"
        msg_x = (192 - len(msg) * 7) // 2
        c.text(msg, msg_x, 16, font="6x8", color="cyan")
        return
    
    # ---- Historical data for sparklines ----
    hist_url = "https://api.weather.com/v2/pws/observations/hourly/7day"
    hist_params = {
        "stationId": station,
        "format": "json",
        "units": api_units,
        "apiKey": apikey
    }
    hist_resp = http.get(hist_url, params=hist_params, ttl_seconds=300)
    
    rate_list  = [0]
    total_list = [0]
    
    if hist_resp["status_code"] == 200:
        observations = hist_resp["json"].get("observations", [])
        
        recent12 = observations[-12:] if len(observations) >= 12 else observations
        total_list = []
        for o in recent12:
            total_list.append(float(o.get(data_key, {}).get("precipTotal", 0) or 0))
        
        recent4 = observations[-4:] if len(observations) >= 4 else observations
        rate_list = []
        for o in recent4:
            rate_list.append(float(o.get(data_key, {}).get("precipRate", 0) or 0))
    
    if len(total_list) == 0:
        total_list = [0]
    if len(rate_list) == 0:
        rate_list = [0]
    
    status_text, status_color = get_rain_status(rate, unit_label)
    
    # ---- Header ----
    c.rect(0, 0, 191, 8, fill="0055ff")
    header_text = "RAIN MONITOR"
    header_x = (192 - (len(header_text) * 6)) // 2
    c.text(header_text, header_x, 1, font="5x7", color="white")
    
    # Color for Today total (thresholds converted for mm)
    if unit_label == "C":
        t = today / 25.4          # work in inches for the color decision
    else:
        t = today
    
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
    
    # ---- Column 1: TODAY ----
    c.text("TODAY", 16, 11, font="5x7", color="skyblue")
    today_str = str(today)
    c.text(today_str, 10, 20, font="6x8", color=today_color)
    c.text(" " + rain_u, 10 + len(today_str)*7, 20, font="6x8", color="gray")
    c.sparkline(total_list, 3, 28, 57, 4, color="skyblue")
    
    c.rect(63, 11, 64, 29, fill="0055ff")
    
    # ---- Column 2: RATE ----
    c.text("RATE", 84, 11, font="5x7", color="skyblue")
    rate_str = str(rate)
    c.text(rate_str, 75, 20, font="6x8", color=status_color)
    c.text(" " + rain_u, 75 + len(rate_str)*7, 20, font="6x8", color="gray")
    c.sparkline(rate_list, 68, 28, 57, 4, color="skyblue")
    
    c.rect(128, 11, 129, 29, fill="0055ff")
    
    # ---- Column 3: STATUS ----
    c.text("STATUS", 141, 11, font="5x7", color="skyblue")
    status_w = len(status_text) * 6
    status_x = 126 + ((62 - status_w) // 2)
    c.text(status_text, status_x, 20, font="6x8", color=status_color)