# OZARKS WEATHER
# Local weather, regional conditions, Ozarks Outlook,
# and official National Weather Service alerts.


# ------------------------------------------------------------
# COLORS
# ------------------------------------------------------------

FOREST = "#274E2A"
GOLD = "#FFD34E"
SKY = "#B9E6FF"
WHITE = "#FFFFFF"
BLACK = "#000000"

ALERT_RED = "#B82020"
ALERT_ORANGE = "#C96A18"


# ------------------------------------------------------------
# WEATHER HELPERS
# ------------------------------------------------------------

def whole_temp(value):
    if value >= 0:
        return int(value + 0.5)

    return int(value - 0.5)


def condition(code):
    if code == 0:
        return "CLEAR"

    if code == 1 or code == 2:
        return "P CLOUDY"

    if code == 3:
        return "CLOUDY"

    if code == 45 or code == 48:
        return "FOG"

    if code >= 51 and code <= 57:
        return "DRIZZLE"

    if code >= 61 and code <= 67:
        return "RAIN"

    if code >= 71 and code <= 77:
        return "SNOW"

    if code >= 80 and code <= 82:
        return "SHOWERS"

    if code >= 85 and code <= 86:
        return "SNOW"

    if code >= 95:
        return "STORMS"

    return "WEATHER"


def is_precip(code):
    if code >= 51 and code <= 67:
        return True

    if code >= 71 and code <= 77:
        return True

    if code >= 80 and code <= 86:
        return True

    if code >= 95:
        return True

    return False


def is_storm(code):
    return code >= 95


def is_snow(code):
    if code >= 71 and code <= 77:
        return True

    if code >= 85 and code <= 86:
        return True

    return False


# ------------------------------------------------------------
# LOCAL LOCATION
# ------------------------------------------------------------

def get_local_location(ctx):
    zip_code = str(ctx.inputs.get("zip", "72662"))

    resp = http.get(
        "https://geocoding-api.open-meteo.com/v1/search",
        params = {
            "name": zip_code,
            "count": "1",
            "language": "en",
            "format": "json",
            "countryCode": "US",
        },
        ttl_seconds = 86400,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return {
            "status": "unavailable",
        }

    data = resp["json"]

    if "results" not in data or len(data["results"]) == 0:
        return {
            "status": "invalid",
        }

    result = data["results"][0]

    return {
        "status": "ok",
        "latitude": str(result["latitude"]),
        "longitude": str(result["longitude"]),
    }


# ------------------------------------------------------------
# LOCAL WEATHER
# ------------------------------------------------------------

def get_local_weather(location):
    resp = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": location["latitude"],
            "longitude": location["longitude"],
            "current": "temperature_2m,weather_code",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min",
            "temperature_unit": "fahrenheit",
            "timezone": "America/Chicago",
            "forecast_days": "2",
        },
        ttl_seconds = 300,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    data = resp["json"]

    return {
        "temp": whole_temp(data["current"]["temperature_2m"]),
        "code": int(data["current"]["weather_code"]),
        "hi": whole_temp(data["daily"]["temperature_2m_max"][0]),
        "lo": whole_temp(data["daily"]["temperature_2m_min"][0]),
        "tomorrow_code": int(data["daily"]["weather_code"][1]),
        "tomorrow_hi": whole_temp(data["daily"]["temperature_2m_max"][1]),
        "tomorrow_lo": whole_temp(data["daily"]["temperature_2m_min"][1]),
    }


# ------------------------------------------------------------
# NWS LOCAL ALERTS
# ------------------------------------------------------------

def get_local_alert(location):
    resp = http.get(
        "https://api.weather.gov/alerts/active",
        params = {
            "point": location["latitude"] + "," + location["longitude"],
        },
        headers = {
            "User-Agent": "OzarksWeather/0.1",
            "Accept": "application/geo+json",
        },
        ttl_seconds = 300,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    data = resp["json"]

    if "features" not in data:
        return None

    features = data["features"]

    if len(features) == 0:
        return None

    best = None
    best_priority = 0

    for feature in features:
        props = feature["properties"]
        event = props["event"]

        if event == None:
            event = "WEATHER ALERT"

        priority = 1

        if "Advisory" in event:
            priority = 2

        if "Watch" in event:
            priority = 3

        if "Warning" in event:
            priority = 4

        if event == "Tornado Warning":
            priority = 5

        if priority > best_priority:
            best_priority = priority
            best = {
                "event": event,
                "priority": priority,
            }

    return best


def alert_label(event):
    if event == "Tornado Warning":
        return "TORNADO WARNING"

    if event == "Severe Thunderstorm Warning":
        return "SEVERE T-STORM WARNING"

    if event == "Flash Flood Warning":
        return "FLASH FLOOD WARNING"

    if event == "Flood Warning":
        return "FLOOD WARNING"

    if event == "Winter Storm Warning":
        return "WINTER STORM WARNING"

    if event == "Ice Storm Warning":
        return "ICE STORM WARNING"

    if event == "Tornado Watch":
        return "TORNADO WATCH"

    if event == "Severe Thunderstorm Watch":
        return "SEVERE T-STORM WATCH"

    if event == "Winter Storm Watch":
        return "WINTER STORM WATCH"

    if event == "Flood Watch":
        return "FLOOD WATCH"

    if event == "Wind Advisory":
        return "WIND ADVISORY"

    if event == "Heat Advisory":
        return "HEAT ADVISORY"

    if event == "Dense Fog Advisory":
        return "DENSE FOG ADVISORY"

    return event.upper()


# ------------------------------------------------------------
# NWS REGIONAL SEVERE-WEATHER AWARENESS
# ------------------------------------------------------------

def regional_alert_priority(event):
    if event == "Tornado Warning":
        return 4

    if event == "Severe Thunderstorm Warning":
        return 3

    if event == "Tornado Watch":
        return 2

    if event == "Severe Thunderstorm Watch":
        return 1

    return 0


def regional_alert_label(event):
    if event == "Tornado Warning":
        return "TORNADO IN REGION"

    if event == "Severe Thunderstorm Warning":
        return "SEVERE WX IN REGION"

    if event == "Tornado Watch":
        return "TORNADO WATCH IN REGION"

    if event == "Severe Thunderstorm Watch":
        return "SEVERE WATCH IN REGION"

    return None


def alert_matches_region(area_desc, state):
    if area_desc == None:
        return False

    if state == "MO":
        areas = [
            "Barry", "Barton", "Butler", "Carter", "Cedar",
            "Christian", "Crawford", "Dade", "Dallas", "Dent",
            "Douglas", "Greene", "Howell", "Iron", "Jasper",
            "Laclede", "Lawrence", "Madison", "Maries", "McDonald",
            "Newton", "Oregon", "Ozark", "Phelps", "Polk",
            "Pulaski", "Reynolds", "Ripley", "Shannon", "St. Francois",
            "Stone", "Taney", "Texas", "Washington", "Webster", "Wright",
        ]

    elif state == "AR":
        areas = [
            "Baxter", "Benton", "Boone", "Carroll", "Crawford",
            "Franklin", "Fulton", "Independence", "Izard", "Johnson",
            "Madison", "Marion", "Newton", "Pope", "Searcy",
            "Sebastian", "Sharp", "Stone", "Van Buren", "Washington",
        ]

    else:
        areas = [
            "Adair", "Cherokee", "Delaware", "Mayes", "Ottawa",
            "Sequoyah",
        ]

    for area in areas:
        if area in area_desc:
            return True

    return False


def get_regional_alert():
    best = None
    best_priority = 0

    for state in ["MO", "AR", "OK"]:
        resp = http.get(
            "https://api.weather.gov/alerts/active",
            params = {
                "area": state,
            },
            headers = {
                "User-Agent": "OzarksWeather/0.1",
                "Accept": "application/geo+json",
            },
            ttl_seconds = 300,
        )

        if resp["status_code"] != 200 or resp["json"] == None:
            continue

        data = resp["json"]

        if "features" not in data:
            continue

        for feature in data["features"]:
            props = feature["properties"]
            event = props["event"]
            area_desc = props["areaDesc"]

            if event == None:
                continue

            priority = regional_alert_priority(event)

            if priority == 0:
                continue

            if not alert_matches_region(area_desc, state):
                continue

            if priority > best_priority:
                best_priority = priority
                best = {
                    "event": event,
                    "priority": priority,
                }

    return best


# ------------------------------------------------------------
# REGIONAL WEATHER NETWORK
#
# 0  Springfield MO
# 1  Joplin MO
# 2  Harrison AR
# 3  Top of Rock / Ridgedale MO
# 4  Fayetteville AR
# 5  Tahlequah OK
# 6  Mountain View AR
# 7  West Plains MO
# 8  Mountain Home AR
# 9  Bentonville AR
# 10 Branson MO
# 11 Rogers AR
# 12 Lebanon MO
# 13 Batesville AR
# 14 Grove OK
# 15 Ozark MO
# 16 Rolla MO
# 17 Salem MO
# 18 Farmington MO
# 19 Poplar Bluff MO
# 20 Marshall AR
# 21 Clinton AR
# 22 Jasper AR
# 23 Eureka Springs AR
# 24 Siloam Springs AR
# 25 Huntsville AR
# 26 Ava MO
# 27 Eminence MO
# ------------------------------------------------------------

def get_regional_weather():
    resp = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": "37.2090,37.0842,36.2298,36.5320,36.0626,35.9154,35.8684,36.7281,36.3353,36.3729,36.6437,36.3320,37.6806,35.7698,36.5937,37.0209,37.9514,37.6456,37.7809,36.7570,35.9090,35.5915,36.0087,36.4012,36.1881,36.0862,36.9519,37.1506",
            "longitude": "-93.2923,-94.5133,-93.1077,-93.2770,-94.1574,-94.9699,-92.1177,-91.8524,-92.3852,-94.2088,-93.2185,-94.1185,-92.6638,-91.6409,-94.7691,-93.2060,-91.7713,-91.5356,-90.4218,-90.3929,-92.6313,-92.4604,-93.1866,-93.7379,-94.5405,-93.7413,-92.6604,-91.3576",
            "current": "temperature_2m,weather_code",
            "hourly": "temperature_2m,weather_code,precipitation_probability",
            "forecast_hours": "12",
            "temperature_unit": "fahrenheit",
            "timezone": "America/Chicago",
        },
        ttl_seconds = 300,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    data = resp["json"]
    weather = []

    for item in data:
        weather.append({
            "temp": whole_temp(item["current"]["temperature_2m"]),
            "code": int(item["current"]["weather_code"]),
            "hourly_temp": item["hourly"]["temperature_2m"],
            "hourly_code": item["hourly"]["weather_code"],
            "hourly_pop": item["hourly"]["precipitation_probability"],
        })

    return weather


# ------------------------------------------------------------
# OZARKS OUTLOOK
# ------------------------------------------------------------

def build_outlook(weather):
    if weather == None or len(weather) == 0:
        return None

    low_temp = weather[0]["temp"]
    high_temp = weather[0]["temp"]

    current_precip = 0
    current_storms = 0

    future_precip_locations = 0
    future_storm_locations = 0
    future_snow_locations = 0

    west_precip = 0
    east_precip = 0

    future_low = weather[0]["temp"]
    future_high = weather[0]["temp"]

    location_index = 0

    for item in weather:
        temp = item["temp"]
        code = item["code"]

        if temp < low_temp:
            low_temp = temp

        if temp > high_temp:
            high_temp = temp

        if is_precip(code):
            current_precip += 1

        if is_storm(code):
            current_storms += 1

        location_has_precip = False
        location_has_storm = False
        location_has_snow = False

        hour_index = 0

        for hourly_code in item["hourly_code"]:
            code_value = int(hourly_code)

            if is_precip(code_value):
                location_has_precip = True

            if is_storm(code_value):
                location_has_storm = True

            if is_snow(code_value):
                location_has_snow = True

            if hour_index < len(item["hourly_pop"]):
                pop = item["hourly_pop"][hour_index]

                if pop != None and pop >= 50:
                    location_has_precip = True

            hour_index += 1

        for hourly_temp in item["hourly_temp"]:
            temp_value = whole_temp(hourly_temp)

            if temp_value < future_low:
                future_low = temp_value

            if temp_value > future_high:
                future_high = temp_value

        if location_has_precip:
            future_precip_locations += 1

            # Western Ozarks sampling points.
            if location_index == 1 or \
               location_index == 4 or \
               location_index == 5 or \
               location_index == 9 or \
               location_index == 11 or \
               location_index == 14 or \
               location_index == 23 or \
               location_index == 24 or \
               location_index == 25:
                west_precip += 1
            else:
                east_precip += 1

        if location_has_storm:
            future_storm_locations += 1

        if location_has_snow:
            future_snow_locations += 1

        location_index += 1

    # Thresholds adjusted for the expanded 28-location network.

    if future_storm_locations >= 6:
        summary = "STORMS DEVELOPING"

    elif future_storm_locations > 0:
        summary = "STORMS POSSIBLE"

    elif future_snow_locations > 0:
        summary = "SNOW POSSIBLE"

    elif future_precip_locations >= 14:
        summary = "RAIN SPREADING"

    elif west_precip >= 5 and west_precip > east_precip:
        summary = "SHOWERS WEST"

    elif east_precip >= 7 and east_precip > west_precip:
        summary = "SHOWERS EAST"

    elif future_precip_locations > 0:
        summary = "SCATTERED SHOWERS"

    elif current_storms > 0:
        summary = "STORMS IN REGION"

    elif current_precip > 0:
        summary = "SHOWERS ENDING"

    else:
        current_mid = (low_temp + high_temp) // 2
        future_mid = (future_low + future_high) // 2

        if future_mid <= current_mid - 8:
            summary = "COOLER AHEAD"

        elif future_mid >= current_mid + 8:
            summary = "WARMING UP"

        elif future_high >= 90:
            summary = "HOT & DRY"

        else:
            summary = "QUIET WEATHER"

    return {
        "summary": summary,
        "low": future_low,
        "high": future_high,
    }


# ------------------------------------------------------------
# DRAWING HELPERS
# ------------------------------------------------------------

def header(c, title):
    c.rect(
        0,
        0,
        c.width - 1,
        8,
        fill = FOREST,
    )

    c.text(
        title,
        c.width // 2,
        1,
        font = "5x7",
        color = GOLD,
        align = "center",
    )


def draw_alert(c, alert, city_label):
    c.fill(BLACK)

    alert_color = ALERT_ORANGE

    if alert["priority"] >= 4:
        alert_color = ALERT_RED

    c.rect(
        0,
        0,
        c.width - 1,
        8,
        fill = alert_color,
    )

    c.text(
        "NWS WEATHER ALERT",
        c.width // 2,
        1,
        font = "5x7",
        color = WHITE,
        align = "center",
    )

    c.text(
        alert_label(alert["event"]),
        c.width // 2,
        12,
        font = "5x7",
        color = GOLD,
        align = "center",
    )

    c.text(
        city_label,
        c.width // 2,
        22,
        font = "5x7",
        color = WHITE,
        align = "center",
    )


def regional_pair(c, left_name, left_wx, right_name, right_wx):
    c.fill(BLACK)

    header(c, "AROUND THE OZARKS")

    c.text(
        left_name,
        4,
        10,
        font = "5x7",
        color = SKY,
    )

    if left_wx == None:
        c.text("--", 4, 18, font = "10x14", color = GOLD)
        c.text("NO DATA", 35, 21, font = "5x7", color = WHITE)
    else:
        c.text(
            str(left_wx["temp"]),
            4,
            18,
            font = "10x14",
            color = GOLD,
        )

        c.text(
            condition(left_wx["code"]),
            35,
            21,
            font = "5x7",
            color = WHITE,
        )

    c.text(
        right_name,
        100,
        10,
        font = "5x7",
        color = SKY,
    )

    if right_wx == None:
        c.text("--", 100, 18, font = "10x14", color = GOLD)
        c.text("NO DATA", 131, 21, font = "5x7", color = WHITE)
    else:
        c.text(
            str(right_wx["temp"]),
            100,
            18,
            font = "10x14",
            color = GOLD,
        )

        c.text(
            condition(right_wx["code"]),
            131,
            21,
            font = "5x7",
            color = WHITE,
        )


def regional_item(weather, index):
    if weather == None:
        return None

    if index >= len(weather):
        return None

    return weather[index]


# ------------------------------------------------------------
# PAGE 1
# LOCAL WEATHER / LOCAL NWS ALERT
# ------------------------------------------------------------

def current(c, ctx):
    city_label = str(ctx.inputs.get("city", "OMAHA AR")).upper()
    location = get_local_location(ctx)

    if location["status"] == "invalid":
        c.fill(BLACK)

        header(c, "OZARKS WEATHER")

        c.text(
            "CHECK ZIP",
            c.width // 2,
            17,
            font = "5x7",
            color = GOLD,
            align = "center",
        )

        return

    if location["status"] == "unavailable":
        c.fill(BLACK)

        header(c, "OZARKS WEATHER")

        c.text(
            "LOCAL DATA UNAVAILABLE",
            c.width // 2,
            17,
            font = "5x7",
            color = WHITE,
            align = "center",
        )

        return

    alert = get_local_alert(location)

    if alert != None:
        draw_alert(c, alert, city_label)
        return

    c.fill(BLACK)

    wx = get_local_weather(location)

    header(c, "OZARKS WEATHER")

    c.text(
        city_label,
        4,
        10,
        font = "5x7",
        color = SKY,
    )

    if wx == None:
        c.text("--", 4, 18, font = "10x14", color = GOLD)

        c.text(
            "NO DATA",
            c.width - 4,
            21,
            font = "5x7",
            color = WHITE,
            align = "right",
        )

        return

    c.text(
        str(wx["temp"]),
        4,
        18,
        font = "10x14",
        color = GOLD,
    )

    c.text(
        condition(wx["code"]),
        c.width - 4,
        11,
        font = "5x7",
        color = WHITE,
        align = "right",
    )

    c.text(
        "H %d  L %d" % (wx["hi"], wx["lo"]),
        c.width - 4,
        22,
        font = "5x7",
        color = SKY,
        align = "right",
    )


# ------------------------------------------------------------
# PAGE 2
# OZARKS TOMORROW
# ------------------------------------------------------------

def forecast(c, ctx):
    c.fill(BLACK)

    location = get_local_location(ctx)

    header(c, "OZARKS TOMORROW")

    if location["status"] == "invalid":
        c.text(
            "CHECK ZIP",
            c.width // 2,
            17,
            font = "5x7",
            color = GOLD,
            align = "center",
        )
        return

    if location["status"] == "unavailable":
        c.text(
            "LOCAL DATA UNAVAILABLE",
            c.width // 2,
            17,
            font = "5x7",
            color = WHITE,
            align = "center",
        )
        return

    wx = get_local_weather(location)

    if wx == None:
        c.text(
            "FORECAST UNAVAILABLE",
            c.width // 2,
            17,
            font = "5x7",
            color = WHITE,
            align = "center",
        )
        return

    c.text(
        condition(wx["tomorrow_code"]),
        c.width // 2,
        11,
        font = "5x7",
        color = WHITE,
        align = "center",
    )

    c.text(
        "H %d  L %d" % (
            wx["tomorrow_hi"],
            wx["tomorrow_lo"],
        ),
        c.width // 2,
        22,
        font = "5x7",
        color = SKY,
        align = "center",
    )


# ------------------------------------------------------------
# PAGE 3
# Springfield / Joplin
# ------------------------------------------------------------

def around1(c, ctx):
    weather = get_regional_weather()

    regional_pair(
        c,
        "SPRINGFIELD",
        regional_item(weather, 0),
        "JOPLIN",
        regional_item(weather, 1),
    )


# ------------------------------------------------------------
# PAGE 4
# Rolla / West Plains
# ------------------------------------------------------------

def around2(c, ctx):
    weather = get_regional_weather()

    regional_pair(
        c,
        "ROLLA",
        regional_item(weather, 16),
        "WEST PLAINS",
        regional_item(weather, 7),
    )


# ------------------------------------------------------------
# PAGE 5
# Harrison / Branson
# ------------------------------------------------------------

def around3(c, ctx):
    weather = get_regional_weather()

    regional_pair(
        c,
        "HARRISON",
        regional_item(weather, 2),
        "BRANSON",
        regional_item(weather, 10),
    )


# ------------------------------------------------------------
# PAGE 6
# Fayetteville / Batesville
# ------------------------------------------------------------

def around4(c, ctx):
    weather = get_regional_weather()

    regional_pair(
        c,
        "FAYETTEVILLE",
        regional_item(weather, 4),
        "BATESVILLE",
        regional_item(weather, 13),
    )


# ------------------------------------------------------------
# PAGE 7
# OZARKS OUTLOOK
# ------------------------------------------------------------

def outlook(c, ctx):
    c.fill(BLACK)

    weather = get_regional_weather()
    outlook_data = build_outlook(weather)
    regional_alert = get_regional_alert()

    header(c, "OZARKS OUTLOOK")

    if outlook_data == None:
        c.text(
            "REGIONAL DATA UNAVAILABLE",
            c.width // 2,
            18,
            font = "5x7",
            color = WHITE,
            align = "center",
        )

        return

    summary = outlook_data["summary"]
    summary_color = WHITE

    if regional_alert != None:
        summary = regional_alert_label(regional_alert["event"])
        summary_color = GOLD

    c.text(
        summary,
        c.width // 2,
        11,
        font = "5x7",
        color = summary_color,
        align = "center",
    )

    c.text(
        "12H REGION RANGE %d-%d" % (
            outlook_data["low"],
            outlook_data["high"],
        ),
        c.width // 2,
        21,
        font = "5x7",
        color = SKY,
        align = "center",
    )