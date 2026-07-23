GEOCODE_URL = "https://geocoding-api.open-meteo.com/v1/search"
WEATHER_URL = "https://api.open-meteo.com/v1/forecast"

COLORS = [
    "#b02a31",
    "#1a0aa6",
    "orange",
]


SUN = [
    [0, 1, 0, 1, 0],
    [1, 0, 1, 0, 1],
    [0, 1, 1, 1, 0],
    [1, 0, 1, 0, 1],
    [0, 1, 0, 1, 0],
]

CLOUD = [
    [0, 0, 1, 0, 0],
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
]

PARTLY_CLOUDY = [
    [0, 1, 0, 0, 0],
    [1, 0, 1, 1, 0],
    [0, 1, 1, 1, 1],
    [0, 1, 1, 1, 1],
    [0, 0, 1, 1, 0],
]

RAIN = [
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
    [1, 0, 1, 0, 1],
    [0, 1, 0, 1, 0],
]

SNOW = [
    [0, 1, 0, 1, 0],
    [1, 0, 1, 0, 1],
    [0, 1, 1, 1, 0],
    [1, 0, 1, 0, 1],
    [0, 1, 0, 1, 0],
]

FOG = [
    [1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1],
]

STORM = [
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
    [0, 0, 1, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 1, 0, 0, 0],
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
            "daily": (
                "weather_code,"
                + "temperature_2m_max,"
                + "temperature_2m_min"
            ),
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


def _nickname(value, fallback):
    if value == None or value == "":
        return fallback[:6].upper()

    return value[:6].upper()


def _draw_condition(c, code, x, y):
    if code == 0:
        c.bitmap(
            SUN,
            x,
            y,
            "amber",
        )
        return

    if code == 1 or code == 2:
        c.bitmap(
            PARTLY_CLOUDY,
            x,
            y,
            "amber",
        )
        return

    if code == 3:
        c.bitmap(
            CLOUD,
            x,
            y,
            "white",
        )
        return

    if code == 45 or code == 48:
        c.bitmap(
            FOG,
            x,
            y,
            "white",
        )
        return

    if code >= 51 and code <= 67:
        c.bitmap(
            RAIN,
            x,
            y,
            "#38BDF8",
        )
        return

    if code >= 71 and code <= 77:
        c.bitmap(
            SNOW,
            x,
            y,
            "white",
        )
        return

    if code >= 80 and code <= 82:
        c.bitmap(
            RAIN,
            x,
            y,
            "#38BDF8",
        )
        return

    if code >= 85 and code <= 86:
        c.bitmap(
            SNOW,
            x,
            y,
            "white",
        )
        return

    if code >= 95:
        c.bitmap(
            STORM,
            x,
            y,
            "amber",
        )
        return

    c.bitmap(
        CLOUD,
        x,
        y,
        "white",
    )


def _draw_city_row(
    c,
    city_search,
    nickname,
    y,
    unit,
    unit_letter,
    row_id,
):
    display_name = _nickname(
        nickname,
        city_search.split(",")[0],
    )

    c.text(
        display_name,
        1,
        y,
        font="5x7",
        color=COLORS[row_id],
    )

    location = _get_location(city_search)

    if location == None:
        c.text(
            "ERR",
            48,
            y,
            font="5x7",
            color="red",
        )
        return

    current = _get_weather(
        location.get("latitude"),
        location.get("longitude"),
        unit,
    )

    if current == None:
        c.text(
            "ERR",
            48,
            y,
            font="5x7",
            color="red",
        )
        return

    temperature = current.get("temperature_2m")
    weather_code = current.get("weather_code", 3)

    if temperature == None:
        c.text(
            "ERR",
            48,
            y,
            font="5x7",
            color="red",
        )
        return

    rounded_temperature = _round_temperature(temperature)

    temperature_text = (
        str(rounded_temperature)
        + unit_letter
    )

    _draw_condition(
        c,
        weather_code,
        34,
        y,
    )

    c.text(
        temperature_text.upper(),
        41,
        y,
        font="5x7",
        color="white",
    )


def _draw_forecast_row(
    c,
    city_search,
    nickname,
    y,
    unit,
    row_id,
):
    display_name = _nickname(
        nickname,
        city_search.split(",")[0],
    )

    c.text(
        display_name,
        1,
        y,
        font="5x7",
        color=COLORS[row_id],
    )

    location = _get_location(city_search)

    if location == None:
        c.text(
            "ERR",
            47,
            y,
            font="4x5",
            color="red",
        )
        return

    daily = _get_forecast(
        location.get("latitude"),
        location.get("longitude"),
        unit,
    )

    if daily == None:
        c.text(
            "ERR",
            47,
            y,
            font="4x5",
            color="red",
        )
        return

    high_values = daily.get(
        "temperature_2m_max",
        [],
    )

    low_values = daily.get(
        "temperature_2m_min",
        [],
    )

    code_values = daily.get(
        "weather_code",
        [],
    )

    if len(high_values) == 0:
        c.text(
            "ERR",
            47,
            y,
            font="4x5",
            color="red",
        )
        return

    if len(low_values) == 0:
        c.text(
            "ERR",
            47,
            y,
            font="4x5",
            color="red",
        )
        return

    high_temperature = _round_temperature(
        high_values[0],
    )

    low_temperature = _round_temperature(
        low_values[0],
    )

    weather_code = 3

    if len(code_values) > 0:
        weather_code = code_values[0]

    forecast_text = (
        str(high_temperature)
        + ":"
        + str(low_temperature)
    )

    _draw_condition(
        c,
        weather_code,
        32,
        y,
    )

    c.text(
        forecast_text.upper(),
        39,
        y,
        font="4x7",
        color="white",
    )


def _get_inputs(ctx):
    return {
        "city1": ctx.inputs.get(
            "city1",
            "Melbourne, Florida",
        ),
        "nickname1": ctx.inputs.get(
            "nickname1",
            "HOME",
        ),
        "city2": ctx.inputs.get(
            "city2",
            "London, England",
        ),
        "nickname2": ctx.inputs.get(
            "nickname2",
            "LONDON",
        ),
        "city3": ctx.inputs.get(
            "city3",
            "Barcelona, Spain",
        ),
        "nickname3": ctx.inputs.get(
            "nickname3",
            "BCN",
        ),
        "units": ctx.inputs.get(
            "units",
            "Fahrenheit",
        ),
    }


def _get_unit_settings(units):
    if units == "Celsius":
        return {
            "unit": "celsius",
            "letter": "C",
        }

    return {
        "unit": "fahrenheit",
        "letter": "F",
    }


def weather(c, ctx):
    c.fill("black")

    inputs = _get_inputs(ctx)

    unit_settings = _get_unit_settings(
        inputs.get("units"),
    )

    unit = unit_settings.get("unit")
    unit_letter = unit_settings.get("letter")

    _draw_city_row(
        c,
        inputs.get("city1"),
        inputs.get("nickname1"),
        2,
        unit,
        unit_letter,
        0,
    )

    c.hline(
        0,
        63,
        10,
        "#333333",
    )

    _draw_city_row(
        c,
        inputs.get("city2"),
        inputs.get("nickname2"),
        13,
        unit,
        unit_letter,
        1,
    )

    c.hline(
        0,
        63,
        21,
        "#333333",
    )

    _draw_city_row(
        c,
        inputs.get("city3"),
        inputs.get("nickname3"),
        24,
        unit,
        unit_letter,
        2,
    )


def forecast(c, ctx):
    c.fill("black")

    inputs = _get_inputs(ctx)

    unit_settings = _get_unit_settings(
        inputs.get("units"),
    )

    unit = unit_settings.get("unit")

    _draw_forecast_row(
        c,
        inputs.get("city1"),
        inputs.get("nickname1"),
        2,
        unit,
        0,
    )

    c.hline(
        0,
        63,
        10,
        "#333333",
    )

    _draw_forecast_row(
        c,
        inputs.get("city2"),
        inputs.get("nickname2"),
        13,
        unit,
        1,
    )

    c.hline(
        0,
        63,
        21,
        "#333333",
    )

    _draw_forecast_row(
        c,
        inputs.get("city3"),
        inputs.get("nickname3"),
        24,
        unit,
        2,
    )