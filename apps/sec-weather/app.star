
# SEC WEATHER
# All 16 Southeastern Conference universities
# Eight scoreboard pages, 192 x 32 pixels, two schools per page
# Open-Meteo current weather and today's high/low, cached for 15 minutes
#
# Each 96 px half:
#   y0   STADIUM NAME
#   y8   [ LOGO 40x24 ][ SKY 24x24 ]  78°
#                                     88/70

BLACK = "#000000"
WHITE = "#FFFFFF"
DIM = "#3A3F4A"
HIGH = "#FF8A3D"
LOW = "#5DB8FF"
SLASH = "#6A7080"

# Each entry: school, stadium, school color, latitude, longitude, logo.
# Coordinates are the stadiums. Nearby schools appear together in pairs.
SCHOOLS = [
    ("ARKANSAS", "RAZORBACK", "#D71920", "36.0680", "-94.1789", "ARK.png"),
    ("MISSOURI", "FAUROT FIELD", "#F1B82D", "38.9358", "-92.3331", "MIZ.png"),
    ("OKLAHOMA", "OWEN FIELD", "#D71920", "35.2059", "-97.4423", "OU.png"),
    ("TEXAS", "DKR MEMORIAL", "#E8763A", "30.2837", "-97.7323", "TEX.png"),
    ("TEXAS A&M", "KYLE FIELD", "#B8384E", "30.6100", "-96.3403", "TAMU.png"),
    ("LSU", "TIGER STADIUM", "#9A60E8", "30.4120", "-91.1838", "LSU.png"),
    ("OLE MISS", "THE VAUGHT", "#E8203A", "34.3619", "-89.5343", "MISS.png"),
    ("MISS STATE", "DAVIS WADE", "#C04060", "33.4564", "-88.7936", "MSST.png"),
    ("ALABAMA", "BRYANT-DENNY", "#D71920", "33.2083", "-87.5504", "ALA.png"),
    ("AUBURN", "JORDAN-HARE", "#F68032", "32.6024", "-85.4891", "AUB.png"),
    ("GEORGIA", "SANFORD", "#F04444", "33.9497", "-83.3733", "UGA.png"),
    ("TENNESSEE", "NEYLAND", "#FF8200", "35.9550", "-83.9250", "TENN.png"),
    ("VANDERBILT", "FIRSTBANK", "#D6B56D", "36.1440", "-86.8090", "VAN.png"),
    ("KENTUCKY", "KROGER FIELD", "#4A80FF", "38.0220", "-84.5052", "UK.png"),
    ("FLORIDA", "THE SWAMP", "#3985FF", "29.6500", "-82.3486", "FLA.png"),
    ("SOUTH CAROLINA", "WILLIAMS-BRICE", "#C8203A", "33.9730", "-81.0192", "SC.png"),
]

# Weather sprites, 24 x 24. Day and night versions where the sky shows.
ICONS = {
    "clear-day": "clear-day.png",
    "clear-night": "clear-night.png",
    "partly-day": "partly-sun-day.png",
    "partly-night": "partly-cloudy-night.png",
    "overcast": "overcast.png",
    "fog-day": "fog-day.png",
    "fog-night": "fog-night.png",
    "drizzle": "drizzle.png",
    "rain": "rain.png",
    "heavy-rain": "extreme-rain.png",
    "sleet": "sleet.png",
    "snow": "snow.png",
    "storm": "thunderstorms-rain.png",
    "big-storm": "thunderstorms-extreme-rain.png",
}

def whole_temp(value):
    if value >= 0:
        return int(value + 0.5)
    return int(value - 0.5)


def icon_key(code, day):
    if code == 0:
        return "clear-day" if day == 1 else "clear-night"
    if code == 1 or code == 2:
        return "partly-day" if day == 1 else "partly-night"
    if code == 3:
        return "overcast"
    if code == 45 or code == 48:
        return "fog-day" if day == 1 else "fog-night"
    if code == 56 or code == 57 or code == 66 or code == 67:
        return "sleet"
    if code >= 51 and code <= 55:
        return "drizzle"
    if code == 65 or code == 82:
        return "heavy-rain"
    if (code >= 61 and code <= 64) or code == 80 or code == 81:
        return "rain"
    if (code >= 71 and code <= 77) or code == 85 or code == 86:
        return "snow"
    if code == 95:
        return "storm"
    if code >= 96:
        return "big-storm"
    return "overcast"


def temp_color(t):
    if t >= 95:
        return "#FF4A3D"
    if t >= 85:
        return "#FF9A3D"
    if t >= 70:
        return "#FFE070"
    if t >= 50:
        return WHITE
    if t >= 33:
        return "#9FD8FF"
    return "#5DB8FF"


def get_weather():
    latitudes = []
    longitudes = []
    for school in SCHOOLS:
        latitudes.append(school[3])
        longitudes.append(school[4])

    resp = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": ",".join(latitudes),
            "longitude": ",".join(longitudes),
            "current": "temperature_2m,weather_code,is_day",
            "daily": "temperature_2m_max,temperature_2m_min",
            "forecast_days": "1",
            "temperature_unit": "fahrenheit",
            "timezone": "auto",
        },
        ttl_seconds = 900,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    data = resp["json"]
    if type(data) != "list" or len(data) != 16:
        return None

    result = []
    for item in data:
        current = item.get("current")
        daily = item.get("daily") or {}
        if current == None or current.get("temperature_2m") == None:
            result.append(None)
            continue
        highs = daily.get("temperature_2m_max") or [None]
        lows = daily.get("temperature_2m_min") or [None]
        result.append({
            "temp": whole_temp(current["temperature_2m"]),
            "code": int(current.get("weather_code") or 0),
            "day": int(current.get("is_day") or 0),
            "high": whole_temp(highs[0]) if highs[0] != None else None,
            "low": whole_temp(lows[0]) if lows[0] != None else None,
        })
    return result


def draw_degree(c, x, y, col):
    c.pixel(x + 1, y, col)
    c.pixel(x, y + 1, col)
    c.pixel(x + 2, y + 1, col)
    c.pixel(x + 1, y + 2, col)


def draw_school(c, ox, school, weather):
    # Header: stadium name.
    c.text(school[1], ox + 1, 0, font = "5x7", color = WHITE)

    # Team logo, authored at 40 x 24.
    c.image(school[5], ox, 8)

    right = ox + 94

    if weather == None:
        c.rect(right - 25, 15, right - 17, 16, fill = SLASH)
        c.rect(right - 13, 15, right - 5, 16, fill = SLASH)
        draw_degree(c, right - 2, 9, SLASH)
        c.text("NO DATA", right, 26, font = "4x5", color = SLASH, align = "right")
        return

    c.image(ICONS[icon_key(weather["code"], weather["day"])], ox + 41, 8)

    t = weather["temp"]
    s = str(t)
    font = "10x14" if len(s) <= 2 else "7x12"
    tc = temp_color(t)
    c.text(s, right - 4, 9, font = font, color = tc, align = "right")
    draw_degree(c, right - 2, 9, tc)

    if weather["high"] != None and weather["low"] != None:
        hi = str(weather["high"])
        lo = str(weather["low"])
        w_lo = c.text_width(lo, "4x5")
        c.text(lo, right, 26, font = "4x5", color = LOW, align = "right")
        c.text("/", right - w_lo - 1, 26, font = "4x5", color = SLASH, align = "right")
        w_sl = c.text_width("/", "4x5")
        c.text(hi, right - w_lo - w_sl - 2, 26, font = "4x5", color = HIGH, align = "right")


def draw_pair(c, weather, pair_index):
    c.fill(BLACK)
    c.rect(95, 0, 95, 31, fill = DIM)

    left_index = pair_index * 2
    right_index = left_index + 1
    left_weather = None
    right_weather = None

    if weather != None:
        left_weather = weather[left_index]
        right_weather = weather[right_index]

    draw_school(c, 0, SCHOOLS[left_index], left_weather)
    draw_school(c, 96, SCHOOLS[right_index], right_weather)


def main(c, ctx):
    draw_pair(c, get_weather(), 0)


def page2(c, ctx):
    draw_pair(c, get_weather(), 1)


def page3(c, ctx):
    draw_pair(c, get_weather(), 2)


def page4(c, ctx):
    draw_pair(c, get_weather(), 3)


def page5(c, ctx):
    draw_pair(c, get_weather(), 4)


def page6(c, ctx):
    draw_pair(c, get_weather(), 5)


def page7(c, ctx):
    draw_pair(c, get_weather(), 6)


def page8(c, ctx):
    draw_pair(c, get_weather(), 7)
