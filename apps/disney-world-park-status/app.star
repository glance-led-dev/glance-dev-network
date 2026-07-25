API_BASE = "https://api.themeparks.wiki/v1/entity/"

MAGIC_KINGDOM_ID = "75ea578a-adc8-4116-a54d-dccb60765ef9"
EPCOT_ID = "47f90d2c-e191-4239-a466-5892ef59a88b"
HOLLYWOOD_STUDIOS_ID = "288747d1-8b4f-4a64-867e-ea7c9b27bad8"
ANIMAL_KINGDOM_ID = "1c84a229-8862-4648-9c71-378ddd2c7693"


# ---------------------------------------------------------
# CUSTOM PARK-NAME BITMAPS
#
# Every character is 5 pixels tall.
# Character widths vary so I and L do not waste space,
# while M and W have enough room to look natural.
# ---------------------------------------------------------

MAGIC_BITMAP = [
    [1,0,0,0,1, 0, 0,1,0, 0,0,1,1,1, 0,1, 0,0,1,1],
    [1,1,0,1,1, 0, 1,0,1, 0,1,0,0,0, 0,1, 0,1,0,0],
    [1,0,1,0,1, 0, 1,1,1, 0,1,0,1,1, 0,1, 0,1,0,0],
    [1,0,0,0,1, 0, 1,0,1, 0,1,0,0,1, 0,1, 0,1,0,0],
    [1,0,0,0,1, 0, 1,0,1, 0,0,1,1,0, 0,1, 0,0,1,1],
]


KINGDOM_BITMAP = [
    [1,0,0,1, 0,1, 0,1,0,0,1, 0,0,1,1,1, 0,1,1,0, 0,1,1,1, 0,1,0,0,0,1],
    [1,0,1,0, 0,1, 0,1,1,0,1, 0,1,0,0,0, 0,1,0,1, 0,1,0,1, 0,1,1,0,1,1],
    [1,1,0,0, 0,1, 0,1,0,1,1, 0,1,0,1,1, 0,1,0,1, 0,1,0,1, 0,1,0,1,0,1],
    [1,0,1,0, 0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1,0,1, 0,1,0,1, 0,1,0,0,0,1],
    [1,0,0,1, 0,1, 0,1,0,0,1, 0,0,1,1,0, 0,1,1,0, 0,1,1,1, 0,1,0,0,0,1],
]


EPCOT_BITMAP = [
    [1,1,1, 0,1,1,1,0, 0,0,1,1, 0,1,1,1, 0,1,1,1],
    [1,0,0, 0,1,0,0,1, 0,1,0,0, 0,1,0,1, 0,0,1,0],
    [1,1,0, 0,1,1,1,0, 0,1,0,0, 0,1,0,1, 0,0,1,0],
    [1,0,0, 0,1,0,0,0, 0,1,0,0, 0,1,0,1, 0,0,1,0],
    [1,1,1, 0,1,0,0,0, 0,0,1,1, 0,1,1,1, 0,0,1,0],
]


HOLLYWOOD_BITMAP = [
    [1,0,1, 0,1,1,1, 0,1,0,0, 0,1,0,0, 0,1,0,1, 0,1,0,0,0,1, 0,1,1,1, 0,1,1,1, 0,1,1,0],
    [1,0,1, 0,1,0,1, 0,1,0,0, 0,1,0,0, 0,1,0,1, 0,1,0,0,0,1, 0,1,0,1, 0,1,0,1, 0,1,0,1],
    [1,1,1, 0,1,0,1, 0,1,0,0, 0,1,0,0, 0,0,1,0, 0,1,0,1,0,1, 0,1,0,1, 0,1,0,1, 0,1,0,1],
    [1,0,1, 0,1,0,1, 0,1,0,0, 0,1,0,0, 0,0,1,0, 0,1,0,1,0,1, 0,1,0,1, 0,1,0,1, 0,1,0,1],
    [1,0,1, 0,1,1,1, 0,1,1,1, 0,1,1,1, 0,0,1,0, 0,0,1,0,1,0, 0,1,1,1, 0,1,1,1, 0,1,1,0],
]


STUDIOS_BITMAP = [
    [0,1,1,1, 0,1,1,1, 0,1,0,1, 0,1,1,0, 0,1, 0,1,1,1, 0,0,1,1,1],
    [1,0,0,0, 0,0,1,0, 0,1,0,1, 0,1,0,1, 0,1, 0,1,0,1, 0,1,0,0,0],
    [0,1,1,0, 0,0,1,0, 0,1,0,1, 0,1,0,1, 0,1, 0,1,0,1, 0,1,1,1,0],
    [0,0,0,1, 0,0,1,0, 0,1,0,1, 0,1,0,1, 0,1, 0,1,0,1, 0,0,0,0,1],
    [1,1,1,0, 0,0,1,0, 0,1,1,1, 0,1,1,0, 0,1, 0,1,1,1, 0,1,1,1,0],
]


ANIMAL_BITMAP = [
    [0,1,0, 0,1,0,0,1, 0,1, 0,1,0,0,0,1, 0,0,1,0, 0,1,0,0],
    [1,0,1, 0,1,1,0,1, 0,1, 0,1,1,0,1,1, 0,1,0,1, 0,1,0,0],
    [1,1,1, 0,1,0,1,1, 0,1, 0,1,0,1,0,1, 0,1,1,1, 0,1,0,0],
    [1,0,1, 0,1,0,0,1, 0,1, 0,1,0,0,0,1, 0,1,0,1, 0,1,0,0],
    [1,0,1, 0,1,0,0,1, 0,1, 0,1,0,0,0,1, 0,1,0,1, 0,1,1,1],
]


# ---------------------------------------------------------
# DATE HELPERS
# ---------------------------------------------------------

def _is_leap_year(year):
    if year % 400 == 0:
        return True

    if year % 100 == 0:
        return False

    return year % 4 == 0


def _days_in_month(year, month):
    if month == 2:
        if _is_leap_year(year):
            return 29

        return 28

    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30

    return 31


def _two_digits(value):
    if value < 10:
        return "0" + str(value)

    return str(value)


def _date_key(year, month, day):
    return (
        str(year)
        + "-"
        + _two_digits(month)
        + "-"
        + _two_digits(day)
    )


def _next_day(year, month, day):
    day = day + 1

    if day > _days_in_month(year, month):
        day = 1
        month = month + 1

        if month > 12:
            month = 1
            year = year + 1

    return [year, month, day]


def _previous_day(year, month, day):
    day = day - 1

    if day < 1:
        month = month - 1

        if month < 1:
            month = 12
            year = year - 1

        day = _days_in_month(year, month)

    return [year, month, day]


def _day_of_week(year, month, day):
    offsets = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]

    adjusted_year = year

    if month < 3:
        adjusted_year = adjusted_year - 1

    return (
        adjusted_year
        + adjusted_year // 4
        - adjusted_year // 100
        + adjusted_year // 400
        + offsets[month - 1]
        + day
    ) % 7


def _second_sunday_in_march(year):
    first_day = _day_of_week(year, 3, 1)
    first_sunday = 1

    if first_day != 0:
        first_sunday = 8 - first_day

    return first_sunday + 7


def _first_sunday_in_november(year):
    first_day = _day_of_week(year, 11, 1)

    if first_day == 0:
        return 1

    return 8 - first_day


def _is_eastern_daylight_time(year, month, day, utc_hour):
    start_day = _second_sunday_in_march(year)
    end_day = _first_sunday_in_november(year)

    if month < 3 or month > 11:
        return False

    if month > 3 and month < 11:
        return True

    if month == 3:
        if day > start_day:
            return True

        if day < start_day:
            return False

        return utc_hour >= 7

    if month == 11:
        if day < end_day:
            return True

        if day > end_day:
            return False

        return utc_hour < 6

    return False


def _eastern_date(now):
    year = now.year
    month = now.month
    day = now.day
    utc_hour = now.hour

    offset = 5

    if _is_eastern_daylight_time(year, month, day, utc_hour):
        offset = 4

    local_hour = utc_hour - offset

    if local_hour < 0:
        previous = _previous_day(year, month, day)
        year = previous[0]
        month = previous[1]
        day = previous[2]

    return [year, month, day]


# ---------------------------------------------------------
# API HELPERS
# ---------------------------------------------------------

def _get_json(url, ttl):
    response = http.get(
        url,
        headers = {
            "accept": "application/json",
        },
        ttl_seconds = ttl,
    )

    if response["status_code"] != 200:
        return None

    return response["json"]


def _get_live_data(park_id):
    data = _get_json(
        API_BASE + park_id + "/live",
        300,
    )

    if data == None:
        return []

    return data.get("liveData", [])


def _get_schedule(park_id):
    data = _get_json(
        API_BASE + park_id + "/schedule",
        1800,
    )

    if data == None:
        return []

    return data.get("schedule", [])


def _find_operating_hours(schedule, date_key):
    for entry in schedule:
        if entry.get("date", "") != date_key:
            continue

        if entry.get("type", "") == "OPERATING":
            return entry

    return None


def _time_from_iso(value):
    if value == None:
        return "--"

    text = str(value)

    if len(text) < 16:
        return "--"

    hour = int(text[11:13])
    minute = text[14:16]

    suffix = "A"

    if hour >= 12:
        suffix = "P"

    display_hour = hour % 12

    if display_hour == 0:
        display_hour = 12

    if minute == "00":
        return str(display_hour) + suffix

    return str(display_hour) + ":" + minute + suffix


def _hours_text(hours):
    if hours == None:
        return "CLOSED"

    opening = _time_from_iso(hours.get("openingTime"))
    closing = _time_from_iso(hours.get("closingTime"))
    print(opening + "-" + closing)

    return opening + "-" + closing


# ---------------------------------------------------------
# CROWD CALCULATION
# ---------------------------------------------------------

def _standby_wait(entry):
    queue = entry.get("queue", {})

    if queue == None:
        return None

    standby = queue.get("STANDBY")

    if standby == None:
        return None

    wait_time = standby.get("waitTime")

    if wait_time == None:
        return None

    return wait_time


def _crowd_data(live_data):
    highest_wait = -1
    second_highest_wait = -1

    total_display_wait = 0
    display_wait_count = 0

    wait_count = 0
    operating_count = 0

    for entry in live_data:
        if entry.get("entityType", "") != "ATTRACTION":
            continue

        if entry.get("status", "") != "OPERATING":
            continue

        operating_count = operating_count + 1

        wait_time = _standby_wait(entry)

        if wait_time == None:
            continue

        if wait_time < 0 or wait_time > 300:
            continue

        wait_count = wait_count + 1

        # Only waits above five minutes are included
        # in the overall displayed average.
        if wait_time > 5:
            total_display_wait = total_display_wait + wait_time
            display_wait_count = display_wait_count + 1

        # Track the two longest waits for crowd level.
        if wait_time > highest_wait:
            second_highest_wait = highest_wait
            highest_wait = wait_time

        elif wait_time > second_highest_wait:
            second_highest_wait = wait_time

    load_wait = 0

    if second_highest_wait >= 0:
        load_wait = (
            highest_wait
            + second_highest_wait
        ) // 2

    elif highest_wait >= 0:
        load_wait = highest_wait

    display_wait = 0

    if display_wait_count > 0:
        display_wait = (
            total_display_wait
            // display_wait_count
        )

    return [
        operating_count,
        wait_count,
        load_wait,
        display_wait,
    ]

def _crowd_level(average_wait):
    if average_wait <= 40:
        return [1, "LIGHT", "green"]

    if average_wait <=60:
        return [2, "MILD", "#8FD14F"]

    if average_wait <= 75:
        return [3, "BUSY", "amber"]

    if average_wait <= 90:
        return [4, "HEAVY", "orange"]

    return [5, "PACKED", "red"]

def _draw_crowd_meter(c, load_wait, display_wait):
    crowd = _crowd_level(load_wait)

    level = crowd[0]
    label = crowd[1]
    color = crowd[2]

    c.text(
        label.upper(),
        1,
        14,
        font = "5x5",
        color = color,
    )

    bar_heights = [3, 5, 7, 9, 11]

    for index in range(5):
        x0 = 5 + index * 5
        height = bar_heights[index]
        y0 = 30 - height

        fill_color = "#252525"

        if index < level:
            fill_color = color

        c.rect(
            x0,
            y0,
            x0 + 2,
            30,
            fill = fill_color,
        )

    #c.text(
    #    str(display_wait).upper(),
    #    27,
    #    24,
    #    font = "4x5",
    #    color = "white",
    #)

    #c.text(
    #    "M",
    #    37,
    #    24,
    #    font = "5x5",
    #    color = "#888888",
    #)

# ---------------------------------------------------------
# PARK ARTWORK
# ---------------------------------------------------------
def _draw_castle(c, color):
    c.sprite(
        "..........PRRR......\n..........P.RRR.....\n..........P.........\n..........T.........\n.........TTT........\n.........TTT....P...\n........TTTTT...PRR.\n........BBBBB...P.RR\n........BBBBB...P...\n........BBWBB...T...\n....P...BWWWB...T...\n....P...BWWWB..TTT..\n....PRR.BWWWB.TTTTT.\n....P.RRBBBBB.EBBBBB\n....T...BBBBBBEBBBBB\n....T...BBBBBBEBBBBB\n...TTT..BBBBBBEBBBBB\n...BBB.BBBBBBBEBBBBB\n...BBB.BBBBBBBEBBBBB\n..BBBBEBBBBBBBEBBBBB\n..BBBBEBBBBBBBEBBBBB\n..BBBBEBBBDDBBBBBBBB\n..BBBBBBBDDDDBBBBBBB\n..BBBBBBDDDDDDBBBBBB\n..BBBBBBDDDDDDBBBBBB\n..BBBBBBDDDDDDBBBBBB\n..BBBBBBDDDDDDBBBBBB\n..BBBBBBBBBBBBBBBBBB\n",
        43,
        2,
        legend = {
            "R": "#E31B36",
            "P": "#8A9299",
            "T": "#17758A",
            "B": "#2557a8",
            "W": "#DDF5FF",
            "D": "#0A5068",
            "E": "#0f3470"
        },
    )

def _draw_epcot(c, color):
    c.sprite(
        ".......SSSSSS.......\n.....SSSSMMSSSS.....\n....SSMSSSSSSMSS....\n...SMSSSSSSSSSSMS...\n..SSSSMSSMMSSMSSSS..\n.SSSSSSSMSSMSSSSSSS.\n.SSSMSSSSSSSSSSSMSS.\nSMSSSSSSSSSSSSSSSSMS\nSSSSSSSMSSSSMSSSSSSS\nSSMSSSSSSSSSSSSSSMSS\nSSSSSSSSSSSSSSSSSSSS\nSSSSSSSMSSSSMSSSSSSS\n.SSSMSSSSSSSSSSSMSS.\n.SSSSSSSMSSMSSSSSSS.\n..SSSSMSSMMSSMSSSS..\n...SMSSSSSSSSSSMS...\n....SSMSSSSSSMSS....\n.....SSSSMMSSSS.....\n.......SSSSSS.......\n......BBBBBBBB......\n.....BBCCCCCCBB.....\n....BBCCCCCCCCBB....\n...BBBBCCCCCCBBBB...\n",
        43,
        5,
        legend = {
            "S": "#DCEBF2",
            "M": "#AFC4CE",
            "B": "#244E60",
            "C": "#8EA8B5",
        },
    )
def _draw_tower(c, color):
    c.sprite(
        "..EEEE........EEEE..\n.EEEEEE......EEEEEE.\nEEEEEEEE....EEEEEEEE\nEEEEEEEE....EEEEEEEE\n.EEEEEE......EEEEEE.\n..EEEE........EEEE..\n....MMMMMMMMMMMM....\n...MMMMMMMMMMMMMM...\n...MMMMMMMMMMMMMM...\n...BCCCCCCCCCCCCB...\n...BCCCCCCCCCCCCB...\n...BCCCCCCCCCCCCB...\n.BBBBBBBBBBBBBBBBBB.\n..DDDDDDDDDDDDDDDD..\n...DDDDDDDDDDDDDD...\n...D.....DD.....D...\n..DD.....DD.....DD..\n..D......DD......D..\n.D.......DD.......D.\n",
        43,
        7,
        legend = {
            "E": "#4E555B",
            "M": "#333333",
            "B": "#C9CDD0",
            "C": "#F4F4F4",
            "D": "#707980",
        },
    )

def _draw_tree(c, color):
    c.sprite(
        "............GGGGGG............\n.........GGGGGGGGGGGG.........\n.......GGGGGGHGGGGGGGGG.......\n.....GGGGGGGGGGGGHGGGGGGG.....\n....GGGHGGGGGGGGGGGGGGGGGG....\n...GGGGGGGGHGGGGGGGGHGGGGGG...\n..GGGGGGGGGGGGGGGGGGGGGGGGGG..\n.GGGGGHGGGGGGGGGGGGGGGGHGGGGG.\n.GGGGGGGGGGGHGGGGGGGGGGGGGGGG.\n..GGGGGGGGGGGGGGGGHGGGGGGGGG..\n...GGHGGGGGGGGGGGGGGGGGGGGG...\n....GGGGGGGGHGGGGGGGGGGGGG....\n.......GGGGGGGGGGGGGGGG.......\n..........BBBBBBBBBB..........\n...........BBBBBBBB...........\n..........BBBBBBBBBB..........\n.........BBBB....BBBB.........\n........BBBB......BBBB........\n.......BBBB........BBBB.......\n",
        34,
        3,
        legend = {
            "G": "#4FAE3F",
            "H": "#76C95A",
            "B": "#87522E",
        },
    )

def _draw_art(c, art_type, color):
    if art_type == "CASTLE":
        _draw_castle(c, color)
    elif art_type == "EPCOT":
        _draw_epcot(c, color)
    elif art_type == "TOWER":
        _draw_tower(c, color)
    else:
        _draw_tree(c, color)


# ---------------------------------------------------------
# CUSTOM PARK-NAME DRAWING
# ---------------------------------------------------------

def _draw_park_name(c, park_name):
    if park_name == "MAGIC_KINGDOM":
        c.bitmap(
            MAGIC_BITMAP,
            1,
            1,
            "white",
        )

        c.bitmap(
            KINGDOM_BITMAP,
            1,
            7,
            "white",
        )

    elif park_name == "EPCOT":
        c.bitmap(
            EPCOT_BITMAP,
            1,
            1,
            "white",
        )

    elif park_name == "HOLLYWOOD_STUDIOS":
        c.bitmap(
            HOLLYWOOD_BITMAP,
            1,
            1,
            "white",
        )

        c.bitmap(
            STUDIOS_BITMAP,
            1,
            7,
            "white",
        )

    else:
        c.bitmap(
            ANIMAL_BITMAP,
            1,
            1,
            "white",
        )

        c.bitmap(
            KINGDOM_BITMAP,
            1,
            7,
            "white",
        )


# ---------------------------------------------------------
# CLOSED DISPLAY
# ---------------------------------------------------------

def _draw_closed(c, today_hours, tomorrow_hours):
    c.text(
        "CLOSED",
        1,
        14,
        font = "5x7",
        color = "red",
    )

    if today_hours != None:
        c.text(
            _hours_text(today_hours).upper(),
            1,
            24,
            font = "4x5",
            color = "white",
        )
    elif tomorrow_hours != None:
        c.text(
            ("TMR " + _hours_text(tomorrow_hours)).upper(),
            1,
            24,
            font = "4x5",
            color = "amber",
        )
    else:
        c.text(
            "NO HOURS",
            1,
            24,
            font = "4x5",
            color = "#888888",
        )


# ---------------------------------------------------------
# MAIN PARK DRAWING
# ---------------------------------------------------------

def _draw_park(
    c,
    ctx,
    park_name,
    park_id,
    art_type,
    art_color,
):
    c.fill("black")

    eastern = _eastern_date(ctx.now)

    year = eastern[0]
    month = eastern[1]
    day = eastern[2]

    tomorrow = _next_day(year, month, day)

    today_key = _date_key(year, month, day)

    tomorrow_key = _date_key(
        tomorrow[0],
        tomorrow[1],
        tomorrow[2],
    )

    live_data = _get_live_data(park_id)
    schedule = _get_schedule(park_id)

    _draw_park_name(
        c,
        park_name,
    )

    _draw_art(
        c,
        art_type,
        art_color,
    )

    if len(live_data) == 0 and len(schedule) == 0:
        c.text(
            "NO DATA",
            1,
            17,
            font = "5x7",
            color = "red",
        )
        return

    today_hours = _find_operating_hours(
        schedule,
        today_key,
    )

    tomorrow_hours = _find_operating_hours(
        schedule,
        tomorrow_key,
    )

    crowd_data = _crowd_data(live_data)

    operating_count = crowd_data[0]
    wait_count = crowd_data[1]
    load_wait = crowd_data[2]
    display_wait = crowd_data[3]

    if operating_count >= 3 and wait_count >= 2:
        _draw_crowd_meter(
            c,
            load_wait,
            display_wait,
        )
    else:
        _draw_closed(
            c,
            today_hours,
            tomorrow_hours,
        )


# ---------------------------------------------------------
# PAGES
# ---------------------------------------------------------

def magic_kingdom(c, ctx):
    _draw_park(
        c,
        ctx,
        "MAGIC_KINGDOM",
        MAGIC_KINGDOM_ID,
        "CASTLE",
        "#63B3FF",
    )


def epcot(c, ctx):
    _draw_park(
        c,
        ctx,
        "EPCOT",
        EPCOT_ID,
        "EPCOT",
        "#765CFF",
    )


def hollywood_studios(c, ctx):
    _draw_park(
        c,
        ctx,
        "HOLLYWOOD_STUDIOS",
        HOLLYWOOD_STUDIOS_ID,
        "TOWER",
        "#E6B84A",
    )


def animal_kingdom(c, ctx):
    _draw_park(
        c,
        ctx,
        "ANIMAL_KINGDOM",
        ANIMAL_KINGDOM_ID,
        "TREE",
        "#55B84A",
    )