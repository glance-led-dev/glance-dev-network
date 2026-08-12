OUTLINE_COLOR = "white"

BLACK_COLOR = "#111111"
DARK_GRAY_COLOR = "#222222"
GRAY_COLOR = "#333333"
MID_GRAY_COLOR = "#444444"
LIGHT_GRAY_COLOR = "#666666"


# -------------------------------------------------
# 45 x 30 SOURCE SPRITES
#
# A = USER-SELECTED JEEP COLOR
# K = VERY DARK / BLACK
# D = DARK GRAY
# G = GRAY
# M = MID GRAY
# L = LIGHT GRAY
# . = TRANSPARENT
# -------------------------------------------------

TOP_ON_SPRITE = [
    ".............................................",
    ".............................................",
    ".............................................",
    "..............KK.............................",
    ".......KKKKLMGMGMMMMMKKKK....................",
    ".......KGGGGGGKKKKKKKKKKKK...................",
    ".......MGKKKKKKGGAKKKKKKAAK..................",
    "......KGGKLLLLLKGALLLLLLKKL..................",
    ".KKKK.GGLLLKLLLKGAMLLLLMKLKL.................",
    ".KLKKKMKLLLLKLLKGAGMLLLMKGKAKK...............",
    ".KMKKMGKGGGGGGGGGAKKKKKKKKAKKAAAAKKKK........",
    ".KMGKKKKKKKKKKKKKAKKAAAAAKKKKAAAAAAAAAAAK....",
    ".MMMGKAALKKLAAAAAAKKAAAAAAKKKAAAAAAAAAKKKK...",
    ".MKMGKAKGGGGGMKAAAAAAAAAAAKKAAAAKLLLLLLLAA...",
    ".KMGKAAGKKKKKKGGAAAAAAAAAAAKAAAKGGGGGGGKLA...",
    ".KGKKAGGKKKKKKGLAAAAAAAAAAAKAAALGKKGKKKMLK...",
    ".KMKKAGKLLMMKKKGKKAAAAAAAKAKAALGKKLKKLKKKAKK.",
    "..KMMKMKMGGGMLKKLAAAAAAAAAAAAKGKKMKGGGMKMLLL.",
    "...KMMKKKLLLKMLKGKAAAAAAAKAAALGKKMGLKLMLKGGG.",
    "......KLKKMKLGKKGGGGGGMGMMMMMKKKMGLGMKGMGKK..",
    "......KKKMKMMKMGKKKKKKKKKKKKKKKKMGKMKGLMKKK..",
    "......MGKKKKGKGGK.............KLMKKKGKLMK....",
    "......KGLMKMLMGK...............KKGKMKMKMG....",
    ".......KMGMMGKK.................KKMMLMMG.....",
    "........KMKKKK...................KKMMGK......",
    ".........KKK.......................KKK.......",
    ".............................................",
    ".............................................",
    ".............................................",
    ".............................................",
]


TOP_OFF_SPRITE = [
    ".............................................",
    ".............................................",
    ".............................................",
    ".............................................",
    "...........KKKKK.......KKK...................",
    "........KGDDDKDDAGGKGGGGAA...................",
    "........GKKD....AK......KKK..................",
    "........M.K.....AMK......AA..................",
    "..MMMG..KKM....KAGK.....KKAK.................",
    ".KMKMD.KKMMK...GAKM....K.GKAK................",
    ".MKDGDKAGGKM...KAGM....DGDMAAAAAAAAAKK.......",
    ".DMDDDAAKKKKKKKKAKMM....KDGAAAAAAAAAAAKAA....",
    ".KMDKGAAAAAAAAAAAKGM.....DAAAAAAAAAAKKKAKK...",
    ".MMGKGAAMGGMMMKAAAGKGGK.KKAAAAAKMMMMMMMKMA...",
    ".MDMKDAKKDDDKGMAAAKKDMM.KKAAAAKGGKKKKKAMKK...",
    ".KKMMGAGDDDKMDGMAAMGGGGKDKAAAAMGDMDDDKKKAKK..",
    ".KGKMMKGMGMDKKKGKAKKGGGDDDAAAMGDDKMGMKDKAAM..",
    "..MMGGGKGGGGMDKGMAAKKKKKKAAAAGKDMMGKGMKDMGKG.",
    "...MGGGMGKMMGGDKGKAAAAAAAAAAMGDMMGKMKGDDMGKG.",
    "....KKKGMKKMMGDKKGGGGGGGGMMMMDDDDKMKMMMKKDK..",
    "......KMMMKMMKDDDKDDDDDDDKDDK.KGGMKKMGDKK....",
    "......KMKMMMKKGK..............KDGKGMKKGK.....",
    "......KDMMMKMGDM..............KMGMMMMMDM.....",
    ".......KMGGGMDM................KGMGMMDM......",
    "........KGMGDD..................KDGMGD.......",
    ".........KKK......................KMKK.......",
    ".............................................",
    ".............................................",
    ".............................................",
    ".............................................",
]


# -------------------------------------------------
# SPRITE HELPERS
# -------------------------------------------------

def make_sprite_mask(rows, character):
    bitmap = []

    for row in rows:
        pixels = []

        for i in range(len(row)):
            if row[i] == character:
                pixels.append(1)
            else:
                pixels.append(0)

        bitmap.append(pixels)

    return bitmap


def make_regular_outline_mask(rows):
    bitmap = []

    height = len(rows)

    if height == 0:
        return bitmap

    width = len(rows[0])

    for y in range(height):
        output_row = []

        for x in range(width):

            if rows[y][x] != ".":
                output_row.append(0)
                continue

            neighbor_found = False

            for dy in range(-1, 2):

                if neighbor_found:
                    break

                ny = y + dy

                if ny < 0:
                    continue

                if ny >= height:
                    continue

                for dx in range(-1, 2):

                    if dx == 0 and dy == 0:
                        continue

                    nx = x + dx

                    if nx < 0:
                        continue

                    if nx >= width:
                        continue

                    if rows[ny][nx] != ".":
                        neighbor_found = True
                        break

            if neighbor_found:
                output_row.append(1)
            else:
                output_row.append(0)

        bitmap.append(output_row)

    return bitmap


def make_exterior_outline_mask(rows):
    normal_outline = make_regular_outline_mask(
        rows
    )

    height = len(rows)

    if height == 0:
        return normal_outline

    width = len(rows[0])

    row_first = []
    row_last = []

    for y in range(height):
        first = -1
        last = -1

        for x in range(width):

            if rows[y][x] != ".":
                if first == -1:
                    first = x

                last = x

        row_first.append(first)
        row_last.append(last)


    col_first = []
    col_last = []

    for x in range(width):
        first = -1
        last = -1

        for y in range(height):

            if rows[y][x] != ".":
                if first == -1:
                    first = y

                last = y

        col_first.append(first)
        col_last.append(last)


    output = []

    for y in range(height):
        output_row = []

        for x in range(width):

            if normal_outline[y][x] == 0:
                output_row.append(0)
                continue

            inside_row = False
            inside_column = False

            if (
                row_first[y] >= 0
                and x > row_first[y]
                and x < row_last[y]
            ):
                inside_row = True

            if (
                col_first[x] >= 0
                and y > col_first[x]
                and y < col_last[x]
            ):
                inside_column = True


            if (
                inside_row
                and inside_column
            ):
                output_row.append(0)

            else:
                output_row.append(1)

        output.append(output_row)

    return output


# -------------------------------------------------
# TEMPERATURE UNIT HELPERS
# -------------------------------------------------

def get_temp_unit(ctx):
    unit = str(
        ctx.inputs["tempunit"]
    )

    if unit == "C":
        return "C"

    return "F"


def get_open_meteo_temp_unit(ctx):
    if get_temp_unit(ctx) == "C":
        return "celsius"

    return "fahrenheit"


# -------------------------------------------------
# TIME INPUT HELPERS
# -------------------------------------------------

def time_choice_to_hour(value):
    times = {
        "5 AM": 5,
        "6 AM": 6,
        "7 AM": 7,
        "8 AM": 8,
        "9 AM": 9,
        "10 AM": 10,
        "11 AM": 11,
        "12 PM": 12,
        "1 PM": 13,
        "2 PM": 14,
        "3 PM": 15,
        "4 PM": 16,
        "5 PM": 17,
        "6 PM": 18,
        "7 PM": 19,
        "8 PM": 20,
        "9 PM": 21,
        "10 PM": 22,
        "11 PM": 23,
    }

    return times.get(
        str(value),
        8
    )


def get_selected_hours(ctx):
    start_hour = time_choice_to_hour(
        ctx.inputs["starttime"]
    )

    end_hour = time_choice_to_hour(
        ctx.inputs["endtime"]
    )

    return {
        "start": start_hour,
        "end": end_hour,
    }


def time_window_is_valid(ctx):
    hours = get_selected_hours(
        ctx
    )

    return (
        hours["end"]
        > hours["start"]
    )


# -------------------------------------------------
# LOCAL DAY / MESSAGE HELPERS
# -------------------------------------------------

def get_local_day_number(
    ctx,
    utc_offset_seconds
):
    local_unix = (
        ctx.now.unix
        + utc_offset_seconds
    )

    return (
        local_unix
        // 86400
    )


def get_message_index(
    ctx,
    count,
    utc_offset_seconds
):
    if count <= 0:
        return 0

    local_day = get_local_day_number(
        ctx,
        utc_offset_seconds
    )

    return (
        local_day
        % count
    )


# -------------------------------------------------
# WEATHER
# -------------------------------------------------

def get_forecast(ctx):
    zip_code = str(
        ctx.inputs["zip"]
    )

    geo_url = (
        "https://geocoding-api.open-meteo.com/v1/search"
        + "?name="
        + zip_code
        + "&count=1"
        + "&language=en"
        + "&format=json"
        + "&countryCode=US"
    )

    geo_response = http.get(
        geo_url,
        ttl_seconds=86400
    )

    if geo_response["status_code"] != 200:
        return None

    if geo_response["json"] == None:
        return None

    geo_data = geo_response[
        "json"
    ]

    results = geo_data.get(
        "results",
        []
    )

    if len(results) == 0:
        return None

    location = results[0]

    latitude = location.get(
        "latitude",
        0
    )

    longitude = location.get(
        "longitude",
        0
    )

    city = location.get(
        "name",
        zip_code
    )

    temperature_unit = get_open_meteo_temp_unit(
        ctx
    )

    weather_url = (
        "https://api.open-meteo.com/v1/forecast"
        + "?latitude="
        + str(latitude)
        + "&longitude="
        + str(longitude)
        + "&hourly=temperature_2m"
        + ",precipitation_probability"
        + ",wind_speed_10m"
        + "&daily=temperature_2m_max"
        + "&temperature_unit="
        + temperature_unit
        + "&wind_speed_unit=mph"
        + "&timezone=auto"
        + "&forecast_days=7"
    )

    weather_response = http.get(
        weather_url,
        ttl_seconds=1800
    )

    if weather_response["status_code"] != 200:
        return None

    if weather_response["json"] == None:
        return None

    weather_data = weather_response[
        "json"
    ]

    hourly = weather_data.get(
        "hourly",
        {}
    )

    daily = weather_data.get(
        "daily",
        {}
    )

    hourly_times = hourly.get(
        "time",
        []
    )

    temperatures = hourly.get(
        "temperature_2m",
        []
    )

    rain_chances = hourly.get(
        "precipitation_probability",
        []
    )

    wind_speeds = hourly.get(
        "wind_speed_10m",
        []
    )

    dates = daily.get(
        "time",
        []
    )

    utc_offset_seconds = int(
        weather_data.get(
            "utc_offset_seconds",
            0
        )
    )

    if len(hourly_times) == 0:
        return None

    if len(dates) == 0:
        return None

    return {
        "city": city,
        "hourly_times": hourly_times,
        "temperatures": temperatures,
        "rain": rain_chances,
        "wind": wind_speeds,
        "dates": dates,
        "utc_offset_seconds": utc_offset_seconds,
    }


# -------------------------------------------------
# SELECTED TIME-WINDOW WEATHER
# -------------------------------------------------

def get_window_weather(
    forecast,
    date,
    start_hour,
    end_hour
):
    hourly_times = forecast[
        "hourly_times"
    ]

    temperatures = forecast[
        "temperatures"
    ]

    rain_chances = forecast[
        "rain"
    ]

    wind_speeds = forecast[
        "wind"
    ]

    max_temp = None
    max_rain = None
    max_wind = None

    for i in range(
        len(hourly_times)
    ):
        timestamp = hourly_times[i]

        parts = timestamp.split(
            "T"
        )

        if len(parts) != 2:
            continue

        point_date = parts[0]

        if point_date != date:
            continue

        time_parts = parts[1].split(
            ":"
        )

        if len(time_parts) < 1:
            continue

        hour = int(
            time_parts[0]
        )

        if hour < start_hour:
            continue

        if hour > end_hour:
            continue

        if i >= len(temperatures):
            continue

        if i >= len(rain_chances):
            continue

        if i >= len(wind_speeds):
            continue

        temp_value = temperatures[i]
        rain_value = rain_chances[i]
        wind_value = wind_speeds[i]

        if temp_value == None:
            continue

        if rain_value == None:
            continue

        if wind_value == None:
            continue

        temp = int(
            temp_value
        )

        rain = int(
            rain_value
        )

        wind = int(
            wind_value
        )


        if max_temp == None:
            max_temp = temp

        elif temp > max_temp:
            max_temp = temp


        if max_rain == None:
            max_rain = rain

        elif rain > max_rain:
            max_rain = rain


        if max_wind == None:
            max_wind = wind

        elif wind > max_wind:
            max_wind = wind


    if max_temp == None:
        return None

    if max_rain == None:
        return None

    if max_wind == None:
        return None

    return {
        "temp": max_temp,
        "rain": max_rain,
        "wind": max_wind,
    }


# -------------------------------------------------
# TOP-OFF DECISION
# -------------------------------------------------

def is_top_off(
    temp,
    rain,
    wind,
    ctx
):
    min_temp = int(
        ctx.inputs["mintemp"]
    )

    max_temp = int(
        ctx.inputs["maxtemp"]
    )

    max_rain = int(
        ctx.inputs["maxrain"]
    )

    max_wind = int(
        ctx.inputs["maxwind"]
    )

    return (
        temp >= min_temp
        and temp <= max_temp
        and rain <= max_rain
        and wind <= max_wind
    )


# -------------------------------------------------
# TOP-OFF MESSAGES
# -------------------------------------------------

def get_top_off_message(
    ctx,
    utc_offset_seconds
):
    messages = [
        "TAKE IT OFF",
        "OPEN IT UP",
        "LOSE THE TOP",
        "GO TOPLESS",
        "AIR IT OUT",
    ]

    index = get_message_index(
        ctx,
        len(messages),
        utc_offset_seconds
    )

    return messages[
        index
    ]


# -------------------------------------------------
# TOP-ON MESSAGE
# -------------------------------------------------

def get_top_on_message(
    temp,
    rain,
    wind,
    ctx,
    utc_offset_seconds
):
    min_temp = int(
        ctx.inputs["mintemp"]
    )

    max_temp = int(
        ctx.inputs["maxtemp"]
    )

    max_rain = int(
        ctx.inputs["maxrain"]
    )

    max_wind = int(
        ctx.inputs["maxwind"]
    )

    temp_unit = get_temp_unit(
        ctx
    )

    best_key = "none"
    best_miss = 0
    best_score = -1


    if temp < min_temp:
        miss = (
            min_temp
            - temp
        )

        if min_temp > 0:
            score = (
                miss
                * 100
                // min_temp
            )
        else:
            score = miss

        if score > best_score:
            best_score = score
            best_key = "cold"
            best_miss = miss


    if temp > max_temp:
        miss = (
            temp
            - max_temp
        )

        if max_temp > 0:
            score = (
                miss
                * 100
                // max_temp
            )
        else:
            score = miss

        if score > best_score:
            best_score = score
            best_key = "hot"
            best_miss = miss


    if rain > max_rain:
        miss = (
            rain
            - max_rain
        )

        if max_rain > 0:
            score = (
                miss
                * 100
                // max_rain
            )
        else:
            score = (
                miss
                * 100
            )

        if score > best_score:
            best_score = score
            best_key = "rain"
            best_miss = miss


    if wind > max_wind:
        miss = (
            wind
            - max_wind
        )

        if max_wind > 0:
            score = (
                miss
                * 100
                // max_wind
            )
        else:
            score = (
                miss
                * 100
            )

        if score > best_score:
            best_score = score
            best_key = "wind"
            best_miss = miss


    if best_key == "cold":
        messages = [
            "COLD BY "
            + str(best_miss)
            + temp_unit,

            "TOO COLD "
            + str(best_miss)
            + temp_unit,

            "NEED "
            + str(best_miss)
            + temp_unit
            + " MORE",
        ]

    elif best_key == "hot":
        messages = [
            "HOT BY "
            + str(best_miss)
            + temp_unit,

            "TOO HOT "
            + str(best_miss)
            + temp_unit,

            "OVER BY "
            + str(best_miss)
            + temp_unit,
        ]

    elif best_key == "rain":
        messages = [
            "RAIN +"
            + str(best_miss)
            + "%",

            "TOO WET "
            + str(best_miss)
            + "%",

            "WET BY "
            + str(best_miss)
            + "%",
        ]

    elif best_key == "wind":
        messages = [
            "WIND +"
            + str(best_miss)
            + "MPH",

            "TOO WINDY "
            + str(best_miss),

            "WINDY +"
            + str(best_miss),
        ]

    else:
        messages = [
            "KEEP IT ON",
            "LEAVE IT ON",
            "BUTTON IT UP",
        ]

    index = get_message_index(
        ctx,
        len(messages),
        utc_offset_seconds
    )

    return messages[
        index
    ]


# -------------------------------------------------
# JEEP DRAWING
# -------------------------------------------------

def draw_sprite_layers(
    c,
    sprite,
    x,
    y,
    accent_color
):
    c.bitmap(
        make_sprite_mask(
            sprite,
            "K"
        ),
        x,
        y,
        BLACK_COLOR
    )

    c.bitmap(
        make_sprite_mask(
            sprite,
            "D"
        ),
        x,
        y,
        DARK_GRAY_COLOR
    )

    c.bitmap(
        make_sprite_mask(
            sprite,
            "G"
        ),
        x,
        y,
        GRAY_COLOR
    )

    c.bitmap(
        make_sprite_mask(
            sprite,
            "M"
        ),
        x,
        y,
        MID_GRAY_COLOR
    )

    c.bitmap(
        make_sprite_mask(
            sprite,
            "L"
        ),
        x,
        y,
        LIGHT_GRAY_COLOR
    )

    c.bitmap(
        make_sprite_mask(
            sprite,
            "A"
        ),
        x,
        y,
        accent_color
    )


def draw_jeep_top_on(
    c,
    x,
    y,
    accent_color
):
    c.bitmap(
        make_regular_outline_mask(
            TOP_ON_SPRITE
        ),
        x,
        y,
        OUTLINE_COLOR
    )

    draw_sprite_layers(
        c,
        TOP_ON_SPRITE,
        x,
        y,
        accent_color
    )


def draw_jeep_top_off(
    c,
    x,
    y,
    accent_color
):
    c.bitmap(
        make_exterior_outline_mask(
            TOP_OFF_SPRITE
        ),
        x,
        y,
        OUTLINE_COLOR
    )

    draw_sprite_layers(
        c,
        TOP_OFF_SPRITE,
        x,
        y,
        accent_color
    )


# -------------------------------------------------
# WEEK PAGE 4 x 6 LETTERS
# -------------------------------------------------

LETTER_O = [
    [0,1,1,0],
    [1,0,0,1],
    [1,0,0,1],
    [1,0,0,1],
    [1,0,0,1],
    [0,1,1,0],
]


LETTER_N = [
    [1,0,0,1],
    [1,1,0,1],
    [1,1,0,1],
    [1,0,1,1],
    [1,0,1,1],
    [1,0,0,1],
]


LETTER_F = [
    [1,1,1,1],
    [1,0,0,0],
    [1,0,0,0],
    [1,1,1,0],
    [1,0,0,0],
    [1,0,0,0],
]


def draw_week_on(
    c,
    x,
    y,
    color
):
    c.bitmap(
        LETTER_O,
        x,
        y,
        color
    )

    c.bitmap(
        LETTER_N,
        x + 5,
        y,
        color
    )


def draw_week_off(
    c,
    x,
    y,
    color
):
    c.bitmap(
        LETTER_O,
        x,
        y,
        color
    )

    c.bitmap(
        LETTER_F,
        x + 5,
        y,
        color
    )

    c.bitmap(
        LETTER_F,
        x + 10,
        y,
        color
    )


# -------------------------------------------------
# INVALID TIME DISPLAY
# -------------------------------------------------

def draw_time_error(
    c,
    accent_color
):
    c.text(
        "CHECK TIMES",
        26,
        4,
        font="8x12",
        color=accent_color
    )

    c.text(
        "END AFTER START",
        28,
        20,
        font="5x7",
        color="white"
    )


# -------------------------------------------------
# MAIN PAGE
# -------------------------------------------------

def main(c, ctx):
    c.clear()

    accent_color = str(
        ctx.inputs["jeepcolor"]
    )

    temp_unit = get_temp_unit(
        ctx
    )

    if not time_window_is_valid(
        ctx
    ):
        draw_time_error(
            c,
            accent_color
        )

        return


    forecast = get_forecast(
        ctx
    )

    if forecast == None:
        c.text(
            "NO FORECAST",
            36,
            4,
            font="8x12",
            color=accent_color
        )

        c.text(
            "CHECK ZIP",
            36,
            20,
            font="5x7",
            color="white"
        )

        return


    dates = forecast[
        "dates"
    ]

    if len(dates) == 0:
        c.text(
            "NO FORECAST",
            36,
            4,
            font="8x12",
            color=accent_color
        )

        return


    selected_hours = get_selected_hours(
        ctx
    )

    weather = get_window_weather(
        forecast,
        dates[0],
        selected_hours["start"],
        selected_hours["end"]
    )

    if weather == None:
        c.text(
            "NO WINDOW",
            36,
            4,
            font="8x12",
            color=accent_color
        )

        c.text(
            "TRY TIMES",
            36,
            20,
            font="5x7",
            color="white"
        )

        return


    temp = weather[
        "temp"
    ]

    rain = weather[
        "rain"
    ]

    wind = weather[
        "wind"
    ]

    utc_offset_seconds = forecast[
        "utc_offset_seconds"
    ]


    top_off = is_top_off(
        temp,
        rain,
        wind,
        ctx
    )


    if top_off:
        status = "TOP OFF"

        message = get_top_off_message(
            ctx,
            utc_offset_seconds
        )

        draw_jeep_top_off(
            c,
            0,
            1,
            accent_color
        )

    else:
        status = "TOP ON"

        message = get_top_on_message(
            temp,
            rain,
            wind,
            ctx,
            utc_offset_seconds
        )

        draw_jeep_top_on(
            c,
            0,
            1,
            accent_color
        )


    c.text(
        status,
        50,
        1,
        font="8x12",
        color=accent_color
    )

    c.text(
        message,
        50,
        14,
        font="5x7",
        color="white"
    )


    weather_text = (
        str(temp)
        + temp_unit
        + " "
        + str(rain)
        + "% "
        + str(wind)
        + "MPH"
    )


    c.text(
        weather_text,
        50,
        24,
        font="5x7",
        color=accent_color
    )


# -------------------------------------------------
# WEEK PAGE
# -------------------------------------------------

def week(c, ctx):
    c.clear()

    accent_color = str(
        ctx.inputs["jeepcolor"]
    )

    temp_unit = get_temp_unit(
        ctx
    )


    if not time_window_is_valid(
        ctx
    ):
        draw_time_error(
            c,
            accent_color
        )

        return


    forecast = get_forecast(
        ctx
    )

    if forecast == None:
        c.text(
            "NO FORECAST",
            4,
            4,
            font="8x12",
            color=accent_color
        )

        c.text(
            "CHECK ZIP",
            4,
            20,
            font="5x7",
            color="white"
        )

        return


    dates = forecast[
        "dates"
    ]


    selected_hours = get_selected_hours(
        ctx
    )

    start_hour = selected_hours[
        "start"
    ]

    end_hour = selected_hours[
        "end"
    ]


    day_names = [
        "M",
        "T",
        "W",
        "T",
        "F",
        "S",
        "S",
    ]


    def day_of_week(
        y,
        m,
        d
    ):
        if m < 3:
            m = (
                m + 12
            )

            y = (
                y - 1
            )

        k = (
            y % 100
        )

        j = (
            y // 100
        )

        h = (
            d
            + (
                13
                * (m + 1)
            )
            // 5
            + k
            + k // 4
            + j // 4
            + 5 * j
        ) % 7

        return (
            h + 5
        ) % 7


    for i in range(7):

        if i >= len(dates):
            break


        raw_date = dates[
            i
        ]


        weather = get_window_weather(
            forecast,
            raw_date,
            start_hour,
            end_hour
        )


        if weather == None:
            continue


        temp = weather[
            "temp"
        ]

        rain = weather[
            "rain"
        ]

        wind = weather[
            "wind"
        ]


        top_off = is_top_off(
            temp,
            rain,
            wind,
            ctx
        )


        parts = raw_date.split(
            "-"
        )


        if len(parts) == 3:
            year = int(
                parts[0]
            )

            month = int(
                parts[1]
            )

            day = int(
                parts[2]
            )


            dow = day_of_week(
                year,
                month,
                day
            )


            day_name = day_names[
                dow
            ]

        else:
            day_name = "?"


        column_x = (
            i * 18
        )


        c.text(
            day_name,
            column_x + 7,
            0,
            font="5x7",
            color="white"
        )


        if top_off:
            draw_week_off(
                c,
                column_x + 2,
                10,
                accent_color
            )

        else:
            draw_week_on(
                c,
                column_x + 4,
                10,
                "white"
            )


        # Celsius values are normally 1-2 digits.
        # Fahrenheit values are normally 2-3.
        if temp >= 100:
            temp_x = (
                column_x + 1
            )

        elif temp <= -10:
            temp_x = (
                column_x + 1
            )

        else:
            temp_x = (
                column_x + 4
            )


        c.text(
            str(temp),
            temp_x,
            23,
            font="5x7",
            color=accent_color
        )