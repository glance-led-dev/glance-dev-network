GEOCODE_URL = "https://geocoding-api.open-meteo.com/v1/search"
WEATHER_URL = "https://api.open-meteo.com/v1/forecast"

COLORS = [
    "#b02a31",
    "#1a0aa6",
    "orange",
]

def _round_temperature(value):
    if value >= 0:
        return int(value + 0.5)

    return int(value - 0.5)


def _get_location(search):
    response = http.get(
        GEOCODE_URL,
        params={
            "name": search,
            "count": 1,
            "language": "en",
            "format": "json",
        },
        ttl_seconds=86400,
    )

    if response.get("status_code", 0) != 200:
        return None

    data = response.get("json")

    if data == None:
        return None

    results = data.get("results", [])

    if len(results) == 0:
        return None

    return results[0]


def _get_weather(latitude, longitude, unit):
    response = http.get(
        WEATHER_URL,
        params={
            "latitude": latitude,
            "longitude": longitude,
            "current": "temperature_2m,weather_code",
            "temperature_unit": unit,
            "timezone": "auto",
        },
        ttl_seconds=300,
    )

    if response.get("status_code", 0) != 200:
        return None

    data = response.get("json")

    if data == None:
        return None

    return data.get("current")


def _get_forecast(latitude, longitude, unit):
    response = http.get(
        WEATHER_URL,
        params={
            "latitude": latitude,
            "longitude": longitude,
            "daily": "weather_code,temperature_2m_max,temperature_2m_min",
            "temperature_unit": unit,
            "forecast_days": 1,
            "timezone": "auto",
        },
        ttl_seconds=300,
    )

    if response.get("status_code", 0) != 200:
        return None

    data = response.get("json")

    if data == None:
        return None

    return data.get("daily")


def _location_name(location, fallback):
    if location != None:
        name = location.get("name")

        if name != None and name != "":
            return name[:10].upper()

    return fallback.split(",")[0][:6].upper()


def _draw_error(c, y):
    c.text(
        "ERR",
        46,
        y,
        font="picopixel",
        color="red",
    )


def _draw_condition(c, code, x, y):
    if code == 0:
        c.bitmap([[0,0,1,1,0,0],[0,1,1,1,1,0],[1,1,1,1,1,1],[1,1,1,1,1,1],[0,1,1,1,1,0],[0,0,1,1,0,0]], x-1, y, "amber")
        return

    if code == 1 or code == 2:
       c.sprite("..A....\n.AAAB..\nAAABBB.\nAABBBBB\n.AAABB.\n..A....", x-2, y, legend={"A": "amber", "B": "white"})
       return

    if code == 3:
        c.sprite("..AA..\n.ABBA.\nABBBBA\nABABBA\n.A.AA.", x-1, y, legend={"A": "midgray", "B": "white"})
        return

    if code == 45 or code == 48:
        c.bitmap([[0,1,0,1,0,1],[1,0,1,0,1,0],[0,1,0,1,0,1],[1,0,1,0,1,0]], x-1, y, "grey")
        return

    if code >= 51 and code <= 67:
        c.sprite("..A....\n.AAAA..\nABAABA.\n..B..B.\n...B..B", x-2, y, legend={"A": "darkgray", "B": "blue"})
        return

    if code >= 71 and code <= 77:
        c.sprite(".AAAA.\nAAAAAA\nB.B.B.\n.B.B.B", x-1, y, legend={"A": "midgrey", "B": "white"})
        return

    if code >= 80 and code <= 82:
        c.sprite("..A....\n.AAAA..\nABAABA.\n..B..B.\n...B..B", x-2, y, legend={"A": "darkgray", "B": "blue"})
        return

    if code >= 85 and code <= 86:
        c.sprite(".AAAA.\nAAAAAA\nB.B.B.\n.B.B.B", x-1, y, legend={"A": "midgrey", "B": "white"})
        return

    if code >= 95:
        c.sprite(".AAAA.\nAAAAAA\n.B..B.\n..B..B", x-1, y, legend={"A": "darkgray", "B": "amber"})
        return

    c.sprite(".AAAA.\nAAAAAA\nB.B.B.\n.B.B.B", x-1, y, legend={"A": "midgrey", "B": "white"})


def _draw_city_row(
    c,
    city_search,
    y,
    unit,
    row_id,
):
    location = _get_location(city_search)

    display_name = _location_name(
        location,
        city_search,
    )

    c.text(
        display_name,
        1,
        y,
        font="picopixel",
        color=COLORS[row_id],
    )

    if location == None:
        _draw_error(c, y)
        return

    current = _get_weather(
        location.get("latitude"),
        location.get("longitude"),
        unit,
    )

    if current == None:
        _draw_error(c, y)
        return

    temperature = current.get("temperature_2m")

    if temperature == None:
        _draw_error(c, y)
        return

    weather_code = current.get(
        "weather_code",
        3,
    )

    temperature_text = (
        str(_round_temperature(temperature))
    )

    _draw_condition(
        c,
        weather_code,
        47,
        y,
    )

    c.text(
        temperature_text.upper(),
        54,
        y,
        font="picopixel",
        color="white",
    )


def _get_cities(ctx):
    return [
        ctx.inputs.get(
            "city1",
            "Melbourne",
        ),
        ctx.inputs.get(
            "city2",
            "London",
        ),
        ctx.inputs.get(
            "city3",
            "Barcelona, Spain",
        ),
    ]

def _draw_dividers(c):
    c.line(
        0,
        10,
        63,
        10,
        "#999",
    )

    c.line(
        0,
        21,
        63,
        21,
        "#999",
    )


def weather(c, ctx):
    c.fill("black")

    cities = _get_cities(ctx)
    unit = ctx.inputs.get(
        "units",
        "Fahrenheit",
    ).lower()

    _draw_city_row(
        c,
        cities[0],
        2,
        unit,
        0,
    )

    _draw_city_row(
        c,
        cities[1],
        13,
        unit,
        1,
    )

    _draw_city_row(
        c,
        cities[2],
        24,
        unit,
        2,
    )
    _draw_dividers(c)