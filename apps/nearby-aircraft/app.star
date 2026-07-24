AIRCRAFT_API = "https://api.airplanes.live/v2/point/"
ZIP_API = "https://api.zippopotam.us/us/"
ROUTE_API = "https://api.adsbdb.com/v0/callsign/"

COLOR_BG = "#000000"
COLOR_PANEL = "#101010"
COLOR_BORDER = "#242424"
COLOR_WHITE = "#FFFFFF"
COLOR_GRAY = "#808080"
COLOR_GREEN = "#00FF66"
COLOR_CYAN = "#00DFFF"
COLOR_AMBER = "#FFB000"
COLOR_RED = "#FF3030"
COLOR_PURPLE = "#C060FF"

CARGO_PREFIXES = [
    "ABX",
    "AJT",
    "ATN",
    "BOX",
    "CAO",
    "CKS",
    "CLX",
    "FDX",
    "GTI",
    "NCR",
    "PAC",
    "UPS",
]

HELICOPTER_TYPES = [
    "A109",
    "A119",
    "A129",
    "A139",
    "A149",
    "A169",
    "A189",
    "B06",
    "B105",
    "B212",
    "B222",
    "B230",
    "B407",
    "B412",
    "B429",
    "CH47",
    "CH53",
    "EC20",
    "EC25",
    "EC30",
    "EC35",
    "EC45",
    "H125",
    "H130",
    "H135",
    "H145",
    "H160",
    "H175",
    "H225",
    "R22",
    "R44",
    "R66",
    "S55",
    "S58",
    "S61",
    "S64",
    "S76",
    "S92",
    "UH1",
    "UH60",
]

PLANE_N = [
    [0,0,1,0,0],
    [0,1,1,1,0],
    [1,0,1,0,1],
    [0,0,1,0,0],
    [0,1,0,1,0],
]

PLANE_NE = [
    [0,0,0,1,1],
    [0,0,1,1,0],
    [0,1,1,0,0],
    [1,1,1,1,0],
    [1,0,0,0,0],
]

PLANE_E = [
    [0,0,1,0,0],
    [0,0,1,1,0],
    [1,1,1,1,1],
    [0,0,1,1,0],
    [0,0,1,0,0],
]

PLANE_SE = [
    [1,0,0,0,0],
    [1,1,1,1,0],
    [0,1,1,0,0],
    [0,0,1,1,0],
    [0,0,0,1,1],
]

PLANE_S = [
    [0,1,0,1,0],
    [0,0,1,0,0],
    [1,0,1,0,1],
    [0,1,1,1,0],
    [0,0,1,0,0],
]

PLANE_SW = [
    [0,0,0,0,1],
    [0,1,1,1,1],
    [0,0,1,1,0],
    [0,1,1,0,0],
    [1,1,0,0,0],
]

PLANE_W = [
    [0,0,1,0,0],
    [0,1,1,0,0],
    [1,1,1,1,1],
    [0,1,1,0,0],
    [0,0,1,0,0],
]

PLANE_NW = [
    [1,1,0,0,0],
    [0,1,1,0,0],
    [0,0,1,1,0],
    [0,1,1,1,1],
    [0,0,0,0,1],
]


def _upper(value, fallback):
    if value == None:
        return fallback.upper()

    text = str(value).strip()

    if text == "":
        return fallback.upper()

    return text.upper()


def _round_number(value):
    if value == None:
        return 0

    if value < 0:
        return int(value - 0.5)

    return int(value + 0.5)


def _bool_input(value, fallback):
    if value == None:
        return fallback

    if value == True or value == False:
        return value

    text = str(value).strip().lower()

    if text in ["true", "1", "yes", "on"]:
        return True

    if text in ["false", "0", "no", "off"]:
        return False

    return fallback


def _two_digits(value):
    if value < 10:
        return "0" + str(value)

    return str(value)


def _three_digits(value):
    if value < 10:
        return "00" + str(value)

    if value < 100:
        return "0" + str(value)

    return str(value)


def _flag_set(flags, bit_value):
    if flags == None:
        return False

    value = int(flags)

    return ((value // bit_value) % 2) == 1


def _valid_zip(zipcode):
    if zipcode == None:
        return False

    zipcode = str(zipcode).strip()

    if len(zipcode) != 5:
        return False

    for index in range(5):
        character = zipcode[index]

        if character < "0" or character > "9":
            return False

    return True


def _lookup_zip(ctx):
    zipcode = str(ctx.inputs.get("zipcode", "")).strip()

    if not _valid_zip(zipcode):
        return {
            "ok": False,
            "error": "ENTER 5-DIGIT ZIP",
            "zipcode": zipcode,
        }

    response = http.get(
        ZIP_API + zipcode,
        headers={
            "Accept": "application/json",
        },
        ttl_seconds=86400,
    )

    if response["status_code"] != 200:
        return {
            "ok": False,
            "error": "ZIP NOT FOUND",
            "zipcode": zipcode,
        }

    data = response["json"]

    if data == None:
        return {
            "ok": False,
            "error": "ZIP DATA ERROR",
            "zipcode": zipcode,
        }

    places = data.get("places", [])

    if len(places) == 0:
        return {
            "ok": False,
            "error": "ZIP NOT FOUND",
            "zipcode": zipcode,
        }

    place = places[0]
    latitude = place.get("latitude", None)
    longitude = place.get("longitude", None)

    if latitude == None or longitude == None:
        return {
            "ok": False,
            "error": "ZIP DATA ERROR",
            "zipcode": zipcode,
        }

    city = _upper(place.get("place name", zipcode), zipcode)
    state = _upper(place.get("state abbreviation", ""), "")

    return {
        "ok": True,
        "zipcode": zipcode,
        "latitude": str(latitude),
        "longitude": str(longitude),
        "city": city,
        "state": state,
    }


def _parse_favorites(text):
    values = []

    if text == None:
        return values

    raw_items = str(text).split(",")

    for raw_item in raw_items:
        item = str(raw_item).strip().upper()

        if item != "":
            values.append(item)

    return values


def _callsign(aircraft):
    flight = aircraft.get("flight", None)

    if flight == None:
        return ""

    return str(flight).strip().upper()


def _registration(aircraft):
    registration = aircraft.get("r", None)

    if registration != None:
        registration = str(registration).strip()

        if registration != "":
            return registration.upper()

    callsign = _callsign(aircraft)

    if callsign != "":
        return callsign

    return _upper(aircraft.get("hex", "UNKNOWN"), "UNKNOWN")


def _is_favorite(aircraft, favorites):
    registration = _registration(aircraft)
    callsign = _callsign(aircraft)
    hex_code = _upper(aircraft.get("hex", ""), "")

    for favorite in favorites:
        if favorite == registration:
            return True

        if favorite == callsign:
            return True

        if favorite == hex_code:
            return True

    return False


def _is_grounded(aircraft):
    return aircraft.get("alt_baro", None) == "ground"


def _valid_aircraft(aircraft, airborne_only):
    if aircraft == None:
        return False

    if aircraft.get("lat", None) == None:
        return False

    if aircraft.get("lon", None) == None:
        return False

    if airborne_only and _is_grounded(aircraft):
        return False

    return True


def _distance_value(aircraft):
    distance = aircraft.get("dst", None)

    if distance == None:
        return 999999

    return distance


def _speed_mph(aircraft):
    ground_speed = aircraft.get("gs", None)

    if ground_speed == None:
        return None

    return ground_speed * 1.15078


def _altitude_value(aircraft):
    altitude = aircraft.get("alt_baro", None)

    if altitude == None or altitude == "ground":
        return None

    return altitude


def _age_value(aircraft):
    seen_pos = aircraft.get("seen_pos", None)

    if seen_pos != None:
        return seen_pos

    last_position = aircraft.get("lastPosition", None)

    if last_position != None:
        fallback_seen = last_position.get("seen_pos", None)

        if fallback_seen != None:
            return fallback_seen

    seen = aircraft.get("seen", None)

    if seen != None:
        return seen

    return None


def _track_dir(track):
    if track == None:
        return "?"

    heading = track % 360

    if heading >= 337.5 or heading < 22.5:
        return "N"

    if heading < 67.5:
        return "NE"

    if heading < 112.5:
        return "E"

    if heading < 157.5:
        return "SE"

    if heading < 202.5:
        return "S"

    if heading < 247.5:
        return "SW"

    if heading < 292.5:
        return "W"

    return "NW"


def _plane_bitmap(track):
    direction = _track_dir(track)

    if direction == "N":
        return PLANE_N

    if direction == "NE":
        return PLANE_NE

    if direction == "E":
        return PLANE_E

    if direction == "SE":
        return PLANE_SE

    if direction == "S":
        return PLANE_S

    if direction == "SW":
        return PLANE_SW

    if direction == "W":
        return PLANE_W

    if direction == "NW":
        return PLANE_NW

    return PLANE_E


def _is_military(aircraft):
    return _flag_set(aircraft.get("dbFlags", 0), 1)


def _is_interesting(aircraft):
    flags = aircraft.get("dbFlags", 0)

    return (
        _flag_set(flags, 2) or
        _flag_set(flags, 4) or
        _flag_set(flags, 8)
    )


def _callsign_prefix(callsign):
    if callsign == None:
        return ""

    callsign = str(callsign).strip().upper()
    prefix = ""
    for index in range(len(callsign)):
        character = callsign[index]

        if character >= "A" and character <= "Z":
            prefix = prefix + character
        else:
            break

    return prefix


def _is_cargo_callsign(callsign):
    prefix = _callsign_prefix(callsign)

    for cargo_prefix in CARGO_PREFIXES:
        if prefix == cargo_prefix:
            return True

    return False


def _is_helicopter(aircraft):
    category = _upper(aircraft.get("category", ""), "")

    if category == "A7":
        return True

    aircraft_type = _upper(aircraft.get("t", ""), "")

    for helicopter_type in HELICOPTER_TYPES:
        if aircraft_type == helicopter_type:
            return True

    description = _upper(aircraft.get("desc", ""), "")

    if "HELICOPTER" in description:
        return True

    if "ROTOR" in description:
        return True

    return False


def _compare_values_desc(left, right):
    if left > right:
        return -1

    if left < right:
        return 1

    return 0


def _compare_values_asc(left, right):
    if left < right:
        return -1

    if left > right:
        return 1

    return 0


def _compare_aircraft(left, right, sortmode, favorites):
    left_emergency = _is_emergency(left)
    right_emergency = _is_emergency(right)

    if left_emergency != right_emergency:
        if left_emergency:
            return -1

        return 1

    left_favorite = _is_favorite(left, favorites)
    right_favorite = _is_favorite(right, favorites)

    if left_favorite != right_favorite:
        if left_favorite:
            return -1

        return 1

    if sortmode == "FASTEST":
        speed_compare = _compare_values_desc(
            _speed_for_sort(left),
            _speed_for_sort(right),
        )

        if speed_compare != 0:
            return speed_compare

    elif sortmode == "HIGHEST":
        altitude_compare = _compare_values_desc(
            _altitude_for_sort(left),
            _altitude_for_sort(right),
        )

        if altitude_compare != 0:
            return altitude_compare

    elif sortmode == "FRESHEST":
        age_compare = _compare_values_asc(
            _age_for_sort(left),
            _age_for_sort(right),
        )

        if age_compare != 0:
            return age_compare

    elif sortmode == "CLOSEST":
        distance_compare = _compare_values_asc(
            _distance_for_sort(left),
            _distance_for_sort(right),
        )

        if distance_compare != 0:
            return distance_compare

    else:
        left_interest = _is_interesting(left)
        right_interest = _is_interesting(right)

        if left_interest != right_interest:
            if left_interest:
                return -1

            return 1

        left_military = _is_military(left)
        right_military = _is_military(right)

        if left_military != right_military:
            if left_military:
                return -1

            return 1

        age_compare = _compare_values_asc(
            _age_for_sort(left),
            _age_for_sort(right),
        )

        if age_compare != 0:
            return age_compare

    distance_compare = _compare_values_asc(
        _distance_for_sort(left),
        _distance_for_sort(right),
    )

    if distance_compare != 0:
        return distance_compare

    return _compare_values_desc(
        _speed_for_sort(left),
        _speed_for_sort(right),
    )


def _distance_for_sort(aircraft):
    return _distance_value(aircraft)


def _speed_for_sort(aircraft):
    speed = _speed_mph(aircraft)

    if speed == None:
        return -1

    return speed


def _altitude_for_sort(aircraft):
    altitude = _altitude_value(aircraft)

    if altitude == None:
        return -1

    return altitude


def _age_for_sort(aircraft):
    age = _age_value(aircraft)

    if age == None:
        return 999999

    return age


def _sort_aircraft(aircraft_list, sortmode, favorites):
    sorted_list = []

    for aircraft in aircraft_list:
        inserted = False
        for index in range(len(sorted_list)):
            if _compare_aircraft(
                aircraft,
                sorted_list[index],
                sortmode,
                favorites,
            ) < 0:
                sorted_list.insert(index, aircraft)
                inserted = True
                break

        if not inserted:
            sorted_list.append(aircraft)

    return sorted_list


def _fetch_aircraft(ctx):
    location = _lookup_zip(ctx)

    if not location["ok"]:
        return {
            "ok": False,
            "error": location["error"],
            "location": location,
            "aircraft": [],
        }

    radius = str(ctx.inputs.get("radius", "25")).strip()
    airborne_only = _bool_input(ctx.inputs.get("airborneonly", True), True)
    sortmode = _upper(ctx.inputs.get("sortmode", "INTERESTING"), "INTERESTING")
    favorites = _parse_favorites(ctx.inputs.get("favorites", ""))

    url = (
        AIRCRAFT_API +
        location["latitude"] + "/" +
        location["longitude"] + "/" +
        radius
    )

    response = http.get(
        url,
        headers={
            "Accept": "application/json",
        },
        ttl_seconds=210,
    )

    if response["status_code"] != 200:
        return {
            "ok": False,
            "error": "AIRCRAFT API " + str(response["status_code"]),
            "location": location,
            "aircraft": [],
        }

    data = response["json"]

    if data == None:
        return {
            "ok": False,
            "error": "NO AIRCRAFT DATA",
            "location": location,
            "aircraft": [],
        }

    raw_aircraft = data.get("ac", [])
    filtered = []

    for aircraft in raw_aircraft:
        if _valid_aircraft(aircraft, airborne_only):
            filtered.append(aircraft)

    return {
        "ok": True,
        "error": "",
        "location": location,
        "favorites": favorites,
        "sortmode": sortmode,
        "aircraft": _sort_aircraft(filtered, sortmode, favorites),
    }


def _empty_route():
    return {
        "found": False,
        "operator_code": "",
        "operator_name": "",
        "origin": "---",
        "destination": "---",
        "has_airline": False,
    }


def _airport_code(airport):
    if airport == None:
        return "---"

    iata = airport.get("iata_code", None)

    if iata != None and str(iata).strip() != "":
        return str(iata).strip().upper()[:4]

    icao = airport.get("icao_code", None)

    if icao != None and str(icao).strip() != "":
        return str(icao).strip().upper()[:4]

    return "---"


def _lookup_route(aircraft):
    callsign = _callsign(aircraft)

    if callsign == "":
        return _empty_route()

    response = http.get(
        ROUTE_API + callsign,
        headers={
            "Accept": "application/json",
        },
        ttl_seconds=1800,
    )

    if response["status_code"] != 200:
        return _empty_route()

    data = response["json"]

    if data == None:
        return _empty_route()

    route = data.get("response", None)

    if route == None:
        return _empty_route()

    airline = route.get("airline", None)
    operator_code = ""
    operator_name = ""

    if airline != None:
        icao_code = airline.get("icao", None)
        iata_code = airline.get("iata", None)
        airline_name = airline.get("name", None)

        if icao_code != None and str(icao_code).strip() != "":
            operator_code = str(icao_code).strip().upper()[:4]
        elif iata_code != None and str(iata_code).strip() != "":
            operator_code = str(iata_code).strip().upper()[:4]

        if airline_name != None and str(airline_name).strip() != "":
            operator_name = str(airline_name).strip().upper()

    return {
        "found": True,
        "operator_code": operator_code,
        "operator_name": operator_name,
        "origin": _airport_code(route.get("origin", None)),
        "destination": _airport_code(route.get("destination", None)),
        "has_airline": airline != None,
    }


def _aircraft_class(aircraft, route):
    if _is_military(aircraft):
        return "M"

    if _is_helicopter(aircraft):
        return "H"

    callsign = _callsign(aircraft)

    if _is_cargo_callsign(callsign):
        return "C"

    if route["has_airline"]:
        return "P"

    if callsign == "":
        return "G"

    if route["found"]:
        return "G"

    return "U"


def _class_color(class_letter):
    if class_letter == "M":
        return COLOR_GREEN

    if class_letter == "H":
        return COLOR_AMBER

    if class_letter == "P":
        return COLOR_CYAN

    if class_letter == "C":
        return COLOR_PURPLE

    if class_letter == "G":
        return COLOR_WHITE

    return COLOR_GRAY


def _operator_text(route, class_letter):
    operator_code = route.get("operator_code", "")

    if operator_code != "":
        return operator_code[:4]

    if class_letter == "M":
        return "MIL"

    if class_letter == "G":
        return "PVT"

    return "UNK"


def _compact_airport_code(code):
    text = _upper(code, "---")

    if text == "---":
        return ""

    if len(text) == 4:
        return text[1:4]

    if len(text) > 3:
        return text[:3]

    return text


def _route_text(route):
    origin = _compact_airport_code(route.get("origin", "---"))
    destination = _compact_airport_code(route.get("destination", "---"))

    if origin == "" and destination == "":
        return ""

    if origin == "":
        origin = "???"

    if destination == "":
        destination = "???"

    return origin + ">" + destination


def _class_label(class_letter):
    if class_letter == "M":
        return "MIL"

    if class_letter == "H":
        return "HELI"

    if class_letter == "C":
        return "CARGO"

    if class_letter == "P":
        return "AIR"

    if class_letter == "G":
        return "GEN"

    return "UNK"


def _compact_status_text(route, aircraft, class_letter):
    route_text = _route_text(route)

    if route_text != "":
        return route_text[:7]

    operator_code = route.get("operator_code", "")

    if operator_code != "":
        return operator_code[:4]

    callsign = _callsign(aircraft)

    if callsign != "" and callsign != _registration(aircraft):
        return callsign[:7]

    return _class_label(class_letter)


def _speed_short(aircraft):
    speed = _speed_mph(aircraft)

    if speed == None:
        return "??M"

    return str(_round_number(speed)) + "M"


def _speed_color(aircraft):
    speed = _speed_mph(aircraft)

    if speed == None:
        return COLOR_GRAY

    if speed < 150:
        return COLOR_GREEN

    if speed < 350:
        return COLOR_CYAN

    if speed < 500:
        return COLOR_AMBER

    return COLOR_RED


def _altitude_short(aircraft):
    altitude = aircraft.get("alt_baro", None)

    if altitude == "ground":
        return "GND"

    if altitude == None:
        return "ALT?"

    rounded = _round_number(altitude)

    if rounded < 10000:
        return str(rounded)

    return str(rounded // 1000) + "K"


def _altitude_color(aircraft):
    altitude = aircraft.get("alt_baro", None)

    if altitude == None or altitude == "ground":
        return COLOR_GRAY

    if altitude < 5000:
        return COLOR_GREEN

    if altitude < 18000:
        return COLOR_CYAN

    if altitude < 30000:
        return COLOR_AMBER

    return COLOR_PURPLE


def _altitude_panel_text(aircraft):
    altitude_text = _altitude_short(aircraft)
    climb = _vertical_indicator(aircraft)

    if climb == "^" or climb == "V":
        return climb + altitude_text

    return altitude_text


def _vertical_rate(aircraft):
    rate = aircraft.get("baro_rate", None)

    if rate == None:
        rate = aircraft.get("geom_rate", None)

    return rate


def _vertical_indicator(aircraft):
    rate = _vertical_rate(aircraft)

    if rate == None:
        return "-"

    if rate >= 300:
        return "^"

    if rate <= -300:
        return "V"

    return "="


def _track_short(aircraft):
    track = aircraft.get("track", None)

    if track == None:
        return "TRK?"

    return _three_digits(_round_number(track) % 360) + _track_dir(track)


def _distance_short(aircraft):
    distance = aircraft.get("dst", None)

    if distance == None:
        return "--N"

    rounded = _round_number(distance)

    if rounded > 999:
        return "999N"

    return str(rounded) + "N"


def _age_short(aircraft):
    age = _age_value(aircraft)

    if age == None:
        return "?S"

    rounded = _round_number(age)

    if rounded < 60:
        return str(rounded) + "S"

    minutes = rounded // 60

    if minutes < 100:
        return str(minutes) + "M"

    hours = minutes // 60

    if hours < 100:
        return str(hours) + "H"

    return "99H"


def _emergency_text(aircraft):
    squawk = _upper(aircraft.get("squawk", ""), "")
    emergency = _upper(aircraft.get("emergency", "NONE"), "NONE")

    if squawk == "7500":
        return "7500 HIJ"

    if squawk == "7600":
        return "7600 NORD"

    if squawk == "7700":
        return "7700 EMER"

    if emergency == "UNLAWFUL":
        return "UNLW " + _age_short(aircraft)

    if emergency == "NORDO":
        return "NORD " + _age_short(aircraft)

    if emergency == "GENERAL":
        return "EMER " + _age_short(aircraft)

    if emergency == "LIFEGUARD":
        return "MED " + _age_short(aircraft)

    if emergency == "MINFUEL":
        return "FUEL " + _age_short(aircraft)

    if emergency == "DOWNED":
        return "DOWN " + _age_short(aircraft)

    if emergency != "NONE":
        return "ALRT " + _age_short(aircraft)

    return ""


def _is_emergency(aircraft):
    return _emergency_text(aircraft) != ""


def _border_color(aircraft, favorites):
    if _is_emergency(aircraft):
        return COLOR_RED

    if _is_favorite(aircraft, favorites):
        return COLOR_AMBER

    if _is_interesting(aircraft):
        return COLOR_PURPLE

    return COLOR_BORDER


def _icon_color(aircraft, favorites, accent):
    if _is_emergency(aircraft):
        return COLOR_RED

    if _is_favorite(aircraft, favorites):
        return COLOR_AMBER

    if _is_interesting(aircraft):
        return COLOR_PURPLE

    return accent


def _status_color(aircraft, favorites):
    if _is_emergency(aircraft):
        return COLOR_RED

    if _is_favorite(aircraft, favorites):
        return COLOR_AMBER

    if _is_interesting(aircraft):
        return COLOR_PURPLE

    if _is_military(aircraft):
        return COLOR_GREEN

    return COLOR_GRAY


def _summary_top(registration):
    return {
        "reg": registration[:7].upper(),
    }


def _draw_message(c, accent, title, line1, line2):
    c.fill(COLOR_BG)
    c.rect(0, 0, 63, 31, fill=COLOR_BG, outline=COLOR_BORDER)
    c.rect(0, 0, 63, 8, fill=COLOR_PANEL)
    c.text(title[:10].upper(), 2, 1, font="5x7", color=accent)
    c.text(line1[:16].upper(), 2, 11, font="4x5", color=COLOR_WHITE)
    c.text(line2[:16].upper(), 2, 20, font="4x5", color=COLOR_GRAY)


def _draw_page(c, ctx, aircraft_index):
    accent = ctx.inputs.get("accent", COLOR_GREEN)
    result = _fetch_aircraft(ctx)

    if not result["ok"]:
        _draw_message(
            c,
            COLOR_RED,
            "AIRCRAFT",
            result["error"],
            "ZIP " + result["location"].get("zipcode", ""),
        )
        return

    aircraft_list = result["aircraft"]
    favorites = result["favorites"]
    location = result["location"]

    if aircraft_index >= len(aircraft_list):
        sortmode = result["sortmode"]
        _draw_message(
            c,
            accent,
            "NO PLANES",
            location["zipcode"] + " " + sortmode[:5],
            location["city"][:10] + " " + location["state"],
        )
        return

    aircraft = aircraft_list[aircraft_index]
    route = _lookup_route(aircraft)
    registration = _registration(aircraft)
    aircraft_type = _upper(aircraft.get("t", "TYPE"), "TYPE")
    class_letter = _aircraft_class(aircraft, route)
    class_color = _class_color(class_letter)
    top = _summary_top(registration)
    status_text = _compact_status_text(route, aircraft, class_letter)
    status_text_color = COLOR_WHITE
    border_color = _border_color(aircraft, favorites)
    icon_color = _icon_color(aircraft, favorites, accent)
    status_color = _status_color(aircraft, favorites)
    speed_text = _speed_short(aircraft)
    altitude_panel_text = _altitude_panel_text(aircraft)
    type_text = aircraft_type[:4].upper()
    emergency_text = _emergency_text(aircraft)

    if status_text == _class_label(class_letter):
        status_text_color = COLOR_GRAY

    c.fill(COLOR_BG)
    c.rect(0, 0, 63, 31, fill=COLOR_BG, outline=border_color)
    c.rect(0, 0, 63, 8, fill=COLOR_PANEL)

    c.rect(0, 3, 1, 4, fill=status_color)

    c.text_fit(
        top["reg"].upper(),
        4,
        1,
        ["5x7", "4x5"],
        color=COLOR_WHITE,
        maxw=49,
    )

    c.text_right(
        class_letter.upper(),
        1,
        font="4x5",
        color=class_color,
        margin=2,
    )

    c.text_center(
        status_text.upper(),
        10,
        font="4x5",
        color=status_text_color,
    )

    c.hline(1, 15, 62, COLOR_BORDER)

    c.bitmap(
        _plane_bitmap(aircraft.get("track", None)),
        1,
        17,
        color=icon_color,
    )

    c.text(
        speed_text.upper(),
        8,
        16,
        font="4x5",
        color=_speed_color(aircraft),
    )

    c.text_right(
        altitude_panel_text.upper(),
        16,
        font="4x5",
        color=_altitude_color(aircraft),
        margin=1,
    )

    if emergency_text != "":
        c.text(
            emergency_text[:13].upper(),
            2,
            23,
            font="4x5",
            color=COLOR_RED,
        )
    else:
        c.text(
            type_text,
            1,
            23,
            font="4x5",
            color=class_color,
        )
        c.text_center(
            _distance_short(aircraft).upper(),
            23,
            font="4x5",
            color=COLOR_CYAN,
        )
        c.text_right(
            _age_short(aircraft).upper(),
            23,
            font="4x5",
            color=COLOR_GRAY,
            margin=1,
        )


def aircraft1(c, ctx):
    _draw_page(c, ctx, 0)


def aircraft2(c, ctx):
    _draw_page(c, ctx, 1)


def aircraft3(c, ctx):
    _draw_page(c, ctx, 2)


def aircraft4(c, ctx):
    _draw_page(c, ctx, 3)
