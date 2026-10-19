
# SEC WEATHER
# All 16 Southeastern Conference universities
# Eight scoreboard pages, 192 x 32 pixels
# Open-Meteo current weather, cached for 15 minutes

BLACK = "#000000"
WHITE = "#FFFFFF"
GRAY = "#777777"
GOLD = "#FFD34E"

# Each entry: school, city, school color, latitude, longitude.
# Nearby schools appear together in consecutive pairs.
SCHOOLS = [
    ("ARKANSAS", "FAYETTEVILLE", "#D71920", "36.0626", "-94.1574"),
    ("MISSOURI", "COLUMBIA", "#F1B82D", "38.9517", "-92.3341"),
    ("OKLAHOMA", "NORMAN", "#D71920", "35.2226", "-97.4395"),
    ("TEXAS", "AUSTIN", "#BF5700", "30.2672", "-97.7431"),
    ("TEXAS A&M", "COLLEGE STATION", "#963B49", "30.6280", "-96.3344"),
    ("LSU", "BATON ROUGE", "#8750D0", "30.4515", "-91.1871"),
    ("OLE MISS", "OXFORD", "#CE1126", "34.3665", "-89.5192"),
    ("MISS STATE", "STARKVILLE", "#A04455", "33.4504", "-88.8184"),
    ("ALABAMA", "TUSCALOOSA", "#D71920", "33.2098", "-87.5692"),
    ("AUBURN", "AUBURN", "#F68032", "32.6099", "-85.4808"),
    ("GEORGIA", "ATHENS", "#F04444", "33.9519", "-83.3576"),
    ("TENNESSEE", "KNOXVILLE", "#FF8200", "35.9606", "-83.9207"),
    ("VANDERBILT", "NASHVILLE", "#D6B56D", "36.1627", "-86.7816"),
    ("KENTUCKY", "LEXINGTON", "#338BFF", "38.0406", "-84.5037"),
    ("FLORIDA", "GAINESVILLE", "#3985FF", "29.6516", "-82.3248"),
    ("SOUTH CAROLINA", "COLUMBIA", "#A32638", "34.0007", "-81.0348"),
]

def whole_temp(value):
    if value >= 0:
        return int(value + 0.5)
    return int(value - 0.5)


def condition(code, day):
    if code == 0:
        if day == 1:
            return "SUNNY"
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
            "temperature_unit": "fahrenheit",
            "timezone": "auto",
        },
        ttl_seconds = 900,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    data = resp["json"]
    if len(data) != 16:
        return None

    result = []
    for item in data:
        current = item["current"]
        result.append({
            "temp": whole_temp(current["temperature_2m"]),
            "code": int(current["weather_code"]),
            "day": int(current["is_day"]),
        })
    return result


def draw_school(c, x, school, weather):
    c.text(school[0], x, 1, font="5x7", color=school[2])
    c.text(school[1], x, 10, font="5x7", color=WHITE)

    if weather == None:
        c.text("--", x, 18, font="10x14", color=WHITE)
        c.text("NO DATA", x + 35, 21, font="5x7", color=GOLD)
        return

    c.text(str(weather["temp"]), x, 18, font="10x14", color=WHITE)
    c.text(condition(weather["code"], weather["day"]),
           x + 35, 21, font="5x7", color=GOLD)


def draw_pair(c, weather, pair_index):
    c.fill(BLACK)
    c.rect(95, 0, 95, 31, fill=GRAY)

    left_index = pair_index * 2
    right_index = left_index + 1
    left_weather = None
    right_weather = None

    if weather != None:
        left_weather = weather[left_index]
        right_weather = weather[right_index]

    draw_school(c, 3, SCHOOLS[left_index], left_weather)
    draw_school(c, 99, SCHOOLS[right_index], right_weather)


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
