# ================================================================
# COMMUTE - GLANCE GDN app for a 64x32 panel
# AI-generated with ChatGPT at the request of the app author.
#
# Uses:
#   - HERE Geocoding & Search API v7 for worldwide address lookup
#     and IANA time-zone detection.
#   - HERE Routing API v8 for live/current traffic and typical
#     traffic for the current time of day.
#   - TimeAPI.io for the current UTC offset of each IANA zone.
#   - ctx.now for all date/time logic so GLANCE Studio Time Travel works.
#
# Setup:
#   Each installer supplies their own HERE Location Services API key.
#   No shared or hosted API service is required in this version.
#
# Time input note:
#   Enter times without a colon in GLANCE settings, for example
#   800 AM, 530 PM, 0800, or 1730.
# ================================================================


# -----------------------------
# Pixel art
# -----------------------------

HOME = [
    [0,0,0,0,1,0,0,0,0],
    [0,0,0,1,1,1,0,0,0],
    [0,0,1,1,1,1,1,0,0],
    [0,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,1,1,1],
    [0,1,1,1,1,1,1,1,0],
    [0,1,1,0,1,0,1,1,0],
    [0,1,1,0,1,0,1,1,0],
    [0,1,1,0,1,0,1,1,0],
]

OFFICE = [
    [1,1,1,1,1,1,1,1,1],
    [1,0,1,0,1,0,1,0,1],
    [1,0,1,0,1,0,1,0,1],
    [1,1,1,1,1,1,1,1,1],
    [1,0,1,0,1,0,1,0,1],
    [1,0,1,0,1,0,1,0,1],
    [1,1,1,1,1,1,1,1,1],
    [1,0,1,0,1,0,1,0,1],
    [1,1,1,0,1,0,1,1,1],
]

CALENDAR = [
    [0,1,0,0,0,0,0,1,0],
    [0,1,0,0,0,0,0,1,0],
    [1,1,1,1,1,1,1,1,1],
    [1,0,0,0,0,0,0,0,1],
    [1,0,1,0,1,0,1,0,1],
    [1,0,0,0,0,0,0,0,1],
    [1,0,1,0,1,0,1,0,1],
    [1,0,0,0,0,0,0,0,1],
    [1,1,1,1,1,1,1,1,1],
]

WARNING = [
    [0,0,0,1,0,0,0],
    [0,0,1,1,1,0,0],
    [0,1,1,1,1,1,0],
    [1,1,1,1,1,1,1],
    [1,1,1,0,1,1,1],
    [1,1,1,0,1,1,1],
    [1,1,1,1,1,1,1],
    [0,0,0,1,0,0,0],
]


# -----------------------------
# General helpers
# -----------------------------

def enabled(value):
    if value == True:
        return True
    text = str(value).lower()
    return text == "true" or text == "yes" or text == "on" or text == "1"


def pad2(value):
    if value < 10:
        return "0" + str(value)
    return str(value)


def date_text(y, m, d):
    return str(y) + "-" + pad2(m) + "-" + pad2(d)


def all_digits(value):
    # GLANCE Starlark strings are not directly iterable.
    # Strip every valid digit; anything left means the value was not numeric.
    if value == "":
        return False

    remaining = str(value)
    for digit in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
        remaining = remaining.replace(digit, "")

    return remaining == ""


def parse_clock(value):
    # Accepts: 8, 800, 0800, 17, 1730, 800 AM, 530PM.
    # Colons are removed here, but GLANCE settings should still be entered
    # without a colon because some GDN versions use ':' as a descriptor delimiter.
    raw = str(value).upper().replace(" ", "").replace(":", "").replace(".", "")
    suffix = ""

    if len(raw) >= 2:
        tail = raw[len(raw)-2:]
        if tail == "AM" or tail == "PM":
            suffix = tail
            raw = raw[:len(raw)-2]

    if not all_digits(raw):
        return -1

    hour = 0
    minute = 0

    if len(raw) <= 2:
        hour = int(raw)
    elif len(raw) == 3:
        hour = int(raw[:1])
        minute = int(raw[1:])
    elif len(raw) == 4:
        hour = int(raw[:2])
        minute = int(raw[2:])
    else:
        return -1

    if minute < 0 or minute > 59:
        return -1

    if suffix != "":
        if hour < 1 or hour > 12:
            return -1
        if suffix == "AM":
            if hour == 12:
                hour = 0
        else:
            if hour != 12:
                hour = hour + 12
    else:
        if hour < 0 or hour > 23:
            return -1

    return hour * 60 + minute


def format_clock(minutes, timeformat):
    value = minutes % 1440
    hour = value // 60
    minute = value % 60

    if timeformat == "24 hour":
        return pad2(hour) + ":" + pad2(minute)

    suffix = "A"
    display_hour = hour
    if hour >= 12:
        suffix = "P"
    if display_hour == 0:
        display_hour = 12
    elif display_hour > 12:
        display_hour = display_hour - 12

    return str(display_hour) + ":" + pad2(minute) + suffix


def buffer_value(text):
    if text == "5 minutes":
        return 5
    if text == "10 minutes":
        return 10
    if text == "15 minutes":
        return 15
    if text == "20 minutes":
        return 20
    if text == "30 minutes":
        return 30
    return 0


def iso_time_minutes(value):
    # HERE time example: 2026-09-07T17:31:00-05:00
    if value == None:
        return -1
    text = str(value)
    if len(text) < 16:
        return -1
    hh = text[11:13]
    mm = text[14:16]
    if not all_digits(hh) or not all_digits(mm):
        return -1
    return int(hh) * 60 + int(mm)


def api_datetime(y, m, d, minutes):
    value = minutes % 1440
    hh = value // 60
    mm = value % 60
    return date_text(y, m, d) + "T" + pad2(hh) + ":" + pad2(mm) + ":00"


# -----------------------------
# Date / weekday helpers
# -----------------------------

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def weekday(y, m, d):
    # Sunday=0, Monday=1, ... Saturday=6
    return (days_from_civil(y, m, d) + 4) % 7


def is_leap(y):
    if y % 400 == 0:
        return True
    if y % 100 == 0:
        return False
    return y % 4 == 0


def month_days(y, m):
    if m == 2:
        return 29 if is_leap(y) else 28
    if m == 4 or m == 6 or m == 9 or m == 11:
        return 30
    return 31


def nth_weekday(y, m, wanted, occurrence):
    first = weekday(y, m, 1)
    offset = (wanted - first + 7) % 7
    return 1 + offset + (occurrence - 1) * 7


def last_weekday(y, m, wanted):
    last = month_days(y, m)
    last_dow = weekday(y, m, last)
    return last - ((last_dow - wanted + 7) % 7)


def observed_fixed_daynum(y, m, d):
    daynum = days_from_civil(y, m, d)
    dow = weekday(y, m, d)
    if dow == 6:
        return daynum - 1
    if dow == 0:
        return daynum + 1
    return daynum


def is_workday(dow, monday, tuesday, wednesday, thursday, friday, saturday, sunday):
    if dow == 0:
        return sunday
    if dow == 1:
        return monday
    if dow == 2:
        return tuesday
    if dow == 3:
        return wednesday
    if dow == 4:
        return thursday
    if dow == 5:
        return friday
    return saturday


# -----------------------------
# U.S. federal holiday logic
# -----------------------------

def us_holiday(y, m, d, settings):
    today = days_from_civil(y, m, d)

    # Fixed-date holidays may be observed in an adjacent calendar year.
    for hy in [y - 1, y, y + 1]:
        if settings["newyear"] and today == observed_fixed_daynum(hy, 1, 1):
            return "NEW YEARS"
        if settings["juneteenth"] and today == observed_fixed_daynum(hy, 6, 19):
            return "JUNETEENTH"
        if settings["independence"] and today == observed_fixed_daynum(hy, 7, 4):
            return "JULY 4TH"
        if settings["veterans"] and today == observed_fixed_daynum(hy, 11, 11):
            return "VETERANS"
        if settings["christmas"] and today == observed_fixed_daynum(hy, 12, 25):
            return "CHRISTMAS"

    if settings["mlk"] and m == 1 and d == nth_weekday(y, 1, 1, 3):
        return "MLK DAY"
    if settings["presidents"] and m == 2 and d == nth_weekday(y, 2, 1, 3):
        return "PRESIDENTS"
    if settings["memorial"] and m == 5 and d == last_weekday(y, 5, 1):
        return "MEMORIAL"
    if settings["labor"] and m == 9 and d == nth_weekday(y, 9, 1, 1):
        return "LABOR DAY"
    if settings["columbus"] and m == 10 and d == nth_weekday(y, 10, 1, 2):
        return "COLUMBUS"
    if settings["thanksgiving"] and m == 11 and d == nth_weekday(y, 11, 4, 4):
        return "THANKSGIVING"

    return ""


def custom_day_off(y, m, d, dayoff1, dayoff2, dayoff3):
    today = date_text(y, m, d)
    return (
        (dayoff1 != "" and dayoff1 == today) or
        (dayoff2 != "" and dayoff2 == today) or
        (dayoff3 != "" and dayoff3 == today)
    )


# -----------------------------
# HERE + time APIs
# -----------------------------

def geocode(address, key):
    response = http.get(
        "https://geocode.search.hereapi.com/v1/geocode",
        params = {
            "q": address,
            "limit": 1,
            "show": "tz",
            "apiKey": key,
        },
        ttl_seconds = 604800,
    )

    if response["status_code"] != 200 or response["json"] == None:
        return None

    items = response["json"].get("items", [])
    if len(items) == 0:
        return None

    item = items[0]
    position = item.get("position", None)
    if position == None:
        return None

    lat = position.get("lat", None)
    lng = position.get("lng", None)
    if lat == None or lng == None:
        return None

    tz = ""
    timezone = item.get("timeZone", None)
    if timezone != None:
        tz = timezone.get("name", "")

    return {
        "coords": str(lat) + "," + str(lng),
        "timezone": tz,
    }


def timezone_offset_seconds(timezone):
    # Important: the Studio Time Travel control changes ctx.now.
    # Do not ask an external API for the current date/time here, because
    # that would ignore Time Travel and always return the real-world date.
    # We only ask TimeAPI.io for the zone's UTC offset, then apply that
    # offset to ctx.now below.
    if timezone == "":
        return None

    response = http.get(
        "https://timeapi.io/api/TimeZone/zone",
        params = {"timeZone": timezone},
        ttl_seconds = 3600,
    )

    if response["status_code"] != 200 or response["json"] == None:
        return None

    data = response["json"]
    offset = data.get("currentUtcOffset", None)
    if offset == None:
        return None

    seconds = offset.get("seconds", None)
    if seconds == None:
        return None

    return int(seconds)


def shift_date(y, m, d, delta):
    # UTC offsets can only move the local date by one day in either direction.
    if delta < 0:
        d = d - 1
        if d < 1:
            m = m - 1
            if m < 1:
                y = y - 1
                m = 12
            d = month_days(y, m)
    elif delta > 0:
        d = d + 1
        if d > month_days(y, m):
            d = 1
            m = m + 1
            if m > 12:
                m = 1
                y = y + 1

    return {
        "year": y,
        "month": m,
        "day": d,
    }


def local_time_from_ctx(ctx, offset_seconds):
    # ctx.now is the time source GLANCE Studio controls with Time Travel.
    # Shift that UTC snapshot into the requested local timezone.
    offset_minutes = offset_seconds // 60
    local_minutes = ctx.now.hour * 60 + ctx.now.minute + offset_minutes
    day_delta = 0

    if local_minutes < 0:
        local_minutes = local_minutes + 1440
        day_delta = -1
    elif local_minutes >= 1440:
        local_minutes = local_minutes - 1440
        day_delta = 1

    local_date = shift_date(
        ctx.now.year,
        ctx.now.month,
        ctx.now.day,
        day_delta,
    )

    return {
        "year": local_date["year"],
        "month": local_date["month"],
        "day": local_date["day"],
        "hour": local_minutes // 60,
        "minute": local_minutes % 60,
    }


def route(origin, destination, key, departure, arrival):
    params = {
        "transportMode": "car",
        "routingMode": "fast",
        "origin": origin,
        "destination": destination,
        "return": "summary,typicalDuration",
        "apiKey": key,
    }

    if departure != "":
        params["departureTime"] = departure
    if arrival != "":
        params["arrivalTime"] = arrival

    response = http.get(
        "https://router.hereapi.com/v8/routes",
        params = params,
        ttl_seconds = 240,
    )

    if response["status_code"] != 200 or response["json"] == None:
        return None

    routes = response["json"].get("routes", [])
    if len(routes) == 0:
        return None

    sections = routes[0].get("sections", [])
    if len(sections) == 0:
        return None

    live_seconds = 0
    typical_seconds = 0
    first_departure = ""
    last_arrival = ""

    for i in range(len(sections)):
        section = sections[i]
        summary = section.get("summary", {})
        duration = int(summary.get("duration", 0))
        typical = int(summary.get("typicalDuration", duration))
        live_seconds = live_seconds + duration
        typical_seconds = typical_seconds + typical

        if i == 0:
            dep = section.get("departure", {})
            first_departure = dep.get("time", "")

        arr = section.get("arrival", {})
        last_arrival = arr.get("time", last_arrival)

    live_minutes = (live_seconds + 30) // 60
    typical_minutes = (typical_seconds + 30) // 60

    return {
        "live": live_minutes,
        "typical": typical_minutes,
        "departure": first_departure,
        "arrival": last_arrival,
    }


def current_route(origin, destination, key):
    return route(origin, destination, key, "", "")


def arrival_route(origin, destination, key, when):
    return route(origin, destination, key, "", when)


def departure_route(origin, destination, key, when):
    return route(origin, destination, key, when, "")


# -----------------------------
# Drawing helpers
# -----------------------------

def traffic_color(current):
    if current == None:
        return "white"
    delta = current["live"] - current["typical"]
    if delta <= 2:
        return "green"
    if delta <= 7:
        return "amber"
    return "red"


def draw_error(c, title, detail):
    c.clear()
    c.bitmap(WARNING, 2, 11, color = "red")
    c.text(title.upper()[:10], 13, 5, font = "4x5", color = "red")
    c.text(detail.upper()[:12], 13, 18, font = "4x5", color = "white")


def draw_day_off(c, reason):
    c.clear()
    c.bitmap(CALENDAR, 2, 11, color = "green")
    c.text("NO COMMUTE", 14, 5, font = "4x5", color = "green")
    c.text(reason.upper()[:12], 14, 18, font = "4x5", color = "white")


def draw_bottom(c, current):
    if current == None:
        c.text_center("TRAFFIC N/A", 26, font = "4x5", color = "gray")
        return

    text = "NOW" + str(current["live"]) + " AVG" + str(current["typical"])
    c.text_center(text, 26, font = "4x5", color = traffic_color(current))


def draw_morning(c, work_name, arrival_minutes, leave_minutes, now_minutes, timeformat, current):
    c.clear()
    c.bitmap(OFFICE, 2, 11, color = "cyan")

    label = str(work_name).upper()[:5]
    if label == "":
        label = "WORK"
    c.text(label + " " + format_clock(arrival_minutes, timeformat), 13, 2, font = "4x5", color = "cyan")

    if leave_minutes < 0 or now_minutes >= leave_minutes:
        c.text("LEAVE NOW", 13, 12, font = "5x7", color = "red")
    else:
        c.text("LEAVE " + format_clock(leave_minutes, timeformat), 13, 12, font = "4x5", color = "white")

    draw_bottom(c, current)


def draw_return_leave(c, leave_minutes, home_minutes, now_minutes, timeformat, current):
    c.clear()
    c.bitmap(HOME, 2, 11, color = "cyan")

    if now_minutes >= leave_minutes:
        c.text("LEAVE NOW", 13, 2, font = "4x5", color = "red")
    else:
        c.text("LEAVE " + format_clock(leave_minutes, timeformat), 13, 2, font = "4x5", color = "cyan")

    if home_minutes >= 0:
        c.text("HOME " + format_clock(home_minutes, timeformat), 13, 12, font = "4x5", color = "white")
    else:
        c.text("TO HOME", 13, 12, font = "5x7", color = "white")

    draw_bottom(c, current)


def draw_return_arrive(c, home_target, leave_minutes, now_minutes, timeformat, current):
    c.clear()
    c.bitmap(HOME, 2, 11, color = "cyan")

    c.text("HOME " + format_clock(home_target, timeformat), 13, 2, font = "4x5", color = "cyan")

    if leave_minutes < 0 or now_minutes >= leave_minutes:
        c.text("LEAVE NOW", 13, 12, font = "5x7", color = "red")
    else:
        c.text("LEAVE " + format_clock(leave_minutes, timeformat), 13, 12, font = "4x5", color = "white")

    draw_bottom(c, current)


# -----------------------------
# Main
# -----------------------------

def main(c, ctx):
    c.clear()

    # Locations / mode
    home_address = ctx.inputs.get("home", "")
    work_address = ctx.inputs.get("work", "")
    work_name = ctx.inputs.get("workname", "WORK")
    panel_place = ctx.inputs.get("panelplace", "At home - show trip to work")

    # Schedule
    arrival_value = ctx.inputs.get("arrivalwork", "800 AM")
    buffer_choice = ctx.inputs.get("buffer", "10 minutes")
    return_mode = ctx.inputs.get("returnmode", "Leave work at")
    return_value = ctx.inputs.get("returntime", "500 PM")
    return_start_value = ctx.inputs.get("returnstart", "300 PM")

    # Time zones / display
    timeformat = ctx.inputs.get("timeformat", "12 hour")
    home_tz_override = ctx.inputs.get("hometimezone", "")
    work_tz_override = ctx.inputs.get("worktimezone", "")

    # Workdays
    monday = enabled(ctx.inputs.get("monday", True))
    tuesday = enabled(ctx.inputs.get("tuesday", True))
    wednesday = enabled(ctx.inputs.get("wednesday", True))
    thursday = enabled(ctx.inputs.get("thursday", True))
    friday = enabled(ctx.inputs.get("friday", True))
    saturday = enabled(ctx.inputs.get("saturday", False))
    sunday = enabled(ctx.inputs.get("sunday", False))

    # Holidays
    use_us_holidays = enabled(ctx.inputs.get("useusholidays", True))
    holiday_settings = {
        "newyear": enabled(ctx.inputs.get("newyear", True)),
        "mlk": enabled(ctx.inputs.get("mlk", True)),
        "presidents": enabled(ctx.inputs.get("presidents", True)),
        "memorial": enabled(ctx.inputs.get("memorial", True)),
        "juneteenth": enabled(ctx.inputs.get("juneteenth", True)),
        "independence": enabled(ctx.inputs.get("independence", True)),
        "labor": enabled(ctx.inputs.get("labor", True)),
        "columbus": enabled(ctx.inputs.get("columbus", True)),
        "veterans": enabled(ctx.inputs.get("veterans", True)),
        "thanksgiving": enabled(ctx.inputs.get("thanksgiving", True)),
        "christmas": enabled(ctx.inputs.get("christmas", True)),
    }

    dayoff1 = ctx.inputs.get("dayoff1", "")
    dayoff2 = ctx.inputs.get("dayoff2", "")
    dayoff3 = ctx.inputs.get("dayoff3", "")
    here_key = ctx.inputs.get("herekey", "")

    if home_address == "":
        draw_error(c, "SETUP", "ADD HOME")
        return
    if work_address == "":
        draw_error(c, "SETUP", "ADD WORK")
        return
    if here_key == "":
        draw_error(c, "SETUP", "ADD HERE KEY")
        return

    arrival_minutes = parse_clock(arrival_value)
    return_minutes = parse_clock(return_value)
    return_start = parse_clock(return_start_value)

    if arrival_minutes < 0:
        draw_error(c, "TIME", "BAD WORK TIME")
        return
    if return_minutes < 0:
        draw_error(c, "TIME", "BAD RETURN")
        return
    if return_start < 0:
        draw_error(c, "TIME", "BAD SWITCH")
        return

    extra_buffer = buffer_value(buffer_choice)

    # Geocode both locations. HERE also returns IANA time zones with show=tz.
    home = geocode(home_address, here_key)
    if home == None:
        draw_error(c, "LOCATION", "HOME NOT FOUND")
        return

    work = geocode(work_address, here_key)
    if work == None:
        draw_error(c, "LOCATION", "WORK NOT FOUND")
        return

    home_tz = home_tz_override if home_tz_override != "" else home["timezone"]
    work_tz = work_tz_override if work_tz_override != "" else work["timezone"]

    if home_tz == "":
        draw_error(c, "TIMEZONE", "HOME TZ")
        return
    if work_tz == "":
        draw_error(c, "TIMEZONE", "WORK TZ")
        return

    # Get only timezone offsets externally. The actual date/time comes from
    # ctx.now so the GLANCE Studio Time Travel control can drive the app.
    home_offset = timezone_offset_seconds(home_tz)
    work_offset = timezone_offset_seconds(work_tz)

    if home_offset == None or work_offset == None:
        draw_error(c, "TIME", "TIMEZONE API")
        return

    home_now = local_time_from_ctx(ctx, home_offset)
    work_now = local_time_from_ctx(ctx, work_offset)

    home_now_minutes = home_now["hour"] * 60 + home_now["minute"]
    work_now_minutes = work_now["hour"] * 60 + work_now["minute"]

    # Decide which direction this physical panel should show.
    going_home = False
    if panel_place == "At work - show trip home":
        going_home = True
    elif panel_place == "Auto - switch by time":
        going_home = work_now_minutes >= return_start

    # Workdays and holidays follow the work-location calendar.
    wy = work_now["year"]
    wm = work_now["month"]
    wd = work_now["day"]
    work_dow = weekday(wy, wm, wd)

    if not is_workday(work_dow, monday, tuesday, wednesday, thursday, friday, saturday, sunday):
        draw_day_off(c, "NOT WORKDAY")
        return

    if use_us_holidays:
        holiday = us_holiday(wy, wm, wd, holiday_settings)
        if holiday != "":
            draw_day_off(c, holiday)
            return

    if custom_day_off(wy, wm, wd, dayoff1, dayoff2, dayoff3):
        draw_day_off(c, "DAY OFF")
        return

    # ------------------------------------------------------------
    # Home -> Work
    # ------------------------------------------------------------
    if not going_home:
        current = current_route(home["coords"], work["coords"], here_key)
        if current == None:
            draw_error(c, "TRAFFIC", "NO ROUTE")
            return

        leave_minutes = -1

        # If the desired arrival has not already passed at work, ask HERE
        # to work backward from the desired arrival time.
        if work_now_minutes < arrival_minutes:
            planned_when = api_datetime(wy, wm, wd, arrival_minutes)
            planned = arrival_route(home["coords"], work["coords"], here_key, planned_when)
            if planned != None:
                api_leave = iso_time_minutes(planned["departure"])
                if api_leave >= 0:
                    leave_minutes = (api_leave - extra_buffer) % 1440

        draw_morning(
            c,
            work_name,
            arrival_minutes,
            leave_minutes,
            home_now_minutes,
            timeformat,
            current,
        )
        return

    # ------------------------------------------------------------
    # Work -> Home
    # ------------------------------------------------------------
    current = current_route(work["coords"], home["coords"], here_key)
    if current == None:
        draw_error(c, "TRAFFIC", "NO ROUTE")
        return

    if return_mode == "Arrive home by":
        leave_minutes = -1

        # Desired home arrival is interpreted in the home's local timezone.
        if home_now_minutes < return_minutes:
            planned_when = api_datetime(
                home_now["year"],
                home_now["month"],
                home_now["day"],
                return_minutes,
            )
            planned = arrival_route(work["coords"], home["coords"], here_key, planned_when)
            if planned != None:
                api_leave = iso_time_minutes(planned["departure"])
                if api_leave >= 0:
                    leave_minutes = (api_leave - extra_buffer) % 1440

        draw_return_arrive(
            c,
            return_minutes,
            leave_minutes,
            work_now_minutes,
            timeformat,
            current,
        )
        return

    # Default return mode: leave work at a target time and show expected home arrival.
    home_arrival = -1

    if work_now_minutes < return_minutes:
        planned_when = api_datetime(wy, wm, wd, return_minutes)
        planned = departure_route(work["coords"], home["coords"], here_key, planned_when)
        if planned != None:
            home_arrival = iso_time_minutes(planned["arrival"])
    else:
        # Target departure already passed. Use the live route's current arrival.
        home_arrival = iso_time_minutes(current["arrival"])

    draw_return_leave(
        c,
        return_minutes,
        home_arrival,
        work_now_minutes,
        timeformat,
        current,
    )
