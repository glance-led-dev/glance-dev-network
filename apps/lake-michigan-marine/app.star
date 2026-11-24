
# Chicago NWI Marine Conditions v0.5.4
# Full replacement for GLANCE GDN, 128x32.
# Two cyan anchors on every slide header.
# All eight pages and NOAA/NWS logic preserved.
# No imports or try/except.

WIND_MAX = 3600
TEMP_MAX = 14400

NDBC_URL = "https://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt"
NDBC_HISTORY = "https://www.ndbc.noaa.gov/data/5day2/"
LOT_URL = "https://tgftp.nws.noaa.gov/data/raw/fz/fzus53.klot.nsh.lot.txt"
IWX_URL = "https://tgftp.nws.noaa.gov/data/raw/fz/fzus53.kiwx.nsh.iwx.txt"
OPEN_URL = "https://tgftp.nws.noaa.gov/data/raw/fz/fzus63.kmkx.glf.lm.txt"
ALERT_URL = "https://api.weather.gov/alerts/active?zone=LMZ740,LMZ741,LMZ742,LMZ743,LMZ744,LMZ745,LMZ046,LMZ043,LMZ777,LMZ779,LMZ080"

NOAA_HEADERS = {
    "User-Agent": "Chicago-NWI-Marine/0.5.4",
    "Accept": "text/plain",
}
NWS_HEADERS = {
    "User-Agent": "Chicago-NWI-Marine/0.5.4",
    "Accept": "application/geo+json",
}

WIND_ALL = [
    "CMTI2", "CHII2", "CNII2",
    "45198", "45174", "45170",
]
BUOY_ALL = [
    "45214", "45198", "45174", "45170",
]
LOT_ZONES = [
    "LMZ740", "LMZ741", "LMZ742",
    "LMZ743", "LMZ744", "LMZ745",
]
IWX_ZONES = ["LMZ046", "LMZ043"]
OPEN_ZONES = ["LMZ777", "LMZ779", "LMZ080"]
NEAR_ZONES = LOT_ZONES + IWX_ZONES
ALL_ZONES = NEAR_ZONES + OPEN_ZONES
OUTLOOK_PAGES = 4

WIND_CHOICES = {
    "Calumet Harbor": "CMTI2",
    "Chicago Crib": "CHII2",
    "Navy Pier": "CNII2",
    "Chicago Buoy": "45198",
    "Wilmette Buoy": "45174",
    "Mich City Buoy": "45170",
}

BUOY_CHOICES = {
    "Spotter": "45214",
    "Chicago Buoy": "45198",
    "Wilmette Buoy": "45174",
    "Mich City Buoy": "45170",
}

ZONE_CHOICES = {
    "LMZ740": "LMZ740",
    "LMZ741": "LMZ741",
    "LMZ742": "LMZ742",
    "LMZ743": "LMZ743",
    "LMZ744": "LMZ744",
    "LMZ745": "LMZ745",
    "LMZ046": "LMZ046",
    "LMZ043": "LMZ043",
    "LMZ777": "LMZ777",
    "LMZ779": "LMZ779",
    "LMZ080": "LMZ080",
}


# SETTINGS

def _enabled(ctx, key):
    v = str(ctx.inputs.get(key, "true")).lower()
    return (
        v == "true"
        or v == "yes"
        or v == "on"
        or v == "1"
    )


def _pick(
    ctx, key, default, mapping,
    all_label, all_codes
):
    raw = ctx.inputs.get(key, default)
    if raw == None:
        raw = default

    chosen = []
    for name in str(raw).split(","):
        name = name.strip()
        if name == all_label:
            return all_codes
        code = mapping.get(name)
        if code != None and code not in chosen:
            chosen.append(code)

    if len(chosen) == 0:
        return [mapping[default]]
    return chosen


def _winds(ctx):
    return _pick(
        ctx, "wind",
        "Calumet Harbor",
        WIND_CHOICES,
        "All",
        WIND_ALL
    )


def _buoys(ctx):
    return _pick(
        ctx, "buoy",
        "Spotter",
        BUOY_CHOICES,
        "All",
        BUOY_ALL
    )


def _zone_select(ctx, key, default):
    raw = ctx.inputs.get(key, default)
    if raw == None:
        raw = default

    selected = []

    for name in str(raw).split(","):
        name = name.strip()

        if name == "All":
            return ALL_ZONES

        if name == "Nearshore":
            for code in NEAR_ZONES:
                if code not in selected:
                    selected.append(code)

        elif name == "Offshore":
            for code in OPEN_ZONES:
                if code not in selected:
                    selected.append(code)

        elif (
            name == "All six NWS areas"
            or name == "All six forecast areas"
        ):
            for code in LOT_ZONES:
                if code not in selected:
                    selected.append(code)

        elif name == "Same as warnings":
            for code in _warnings_zones(ctx):
                if code not in selected:
                    selected.append(code)

        else:
            code = ZONE_CHOICES.get(name)
            if code != None and code not in selected:
                selected.append(code)

    if len(selected) == 0:
        return [ZONE_CHOICES[default]]

    result = []
    for code in ALL_ZONES:
        if code in selected:
            result.append(code)
    return result


def _warnings_zones(ctx):
    return _zone_select(
        ctx, "wzones",
        "LMZ742"
    )


def _forecast_zones(ctx):
    return _zone_select(
        ctx, "fzones",
        "LMZ743"
    )


# LOCATION LABELS

def _station_label(code):
    return {
        "CMTI2": "CALUMET HARBOR",
        "CHII2": "CHICAGO CRIB",
        "CNII2": "NAVY PIER",
        "45198": "CHICAGO BUOY",
        "45174": "WILMETTE BUOY",
        "45170": "MICH CITY BUOY",
    }.get(code, "SELECTED STATION")


def _zone_label(code):
    return {
        "LMZ740": "WINTHROP-WILMETTE",
        "LMZ741": "WILMETTE-N ISLAND",
        "LMZ742": "N ISLAND-CALUMET",
        "LMZ743": "CALUMET-GARY",
        "LMZ744": "GARY-BURNS HBR",
        "LMZ745": "BURNS-MICH CITY",
        "LMZ046": "MICH CITY-NEW BUFF",
        "LMZ043": "NEW BUFF-ST JOSEPH",
        "LMZ777": "OFF WIN-WILMETTE",
        "LMZ779": "OFF WIL-MICH CITY",
        "LMZ080": "OFF MICH CITY-ST JOE",
    }.get(code, code)


def _zone_short(code):
    return {
        "LMZ740": "WIN-WIL",
        "LMZ741": "WIL-NI",
        "LMZ742": "NI-CAL",
        "LMZ743": "CAL-GRY",
        "LMZ744": "GRY-BH",
        "LMZ745": "BH-MCY",
        "LMZ046": "MCY-NB",
        "LMZ043": "NB-SJ",
        "LMZ777": "WIN-WIL O",
        "LMZ779": "WIL-MCY O",
        "LMZ080": "MCY-SJ O",
    }.get(code, code)


# DRAWING HELPERS

def _fit(c, label, font, width):
    for n in range(len(label), -1, -1):
        if c.text_width(
            label[:n], font=font
        ) <= width:
            return label[:n]
    return ""


# 7x7 anchor icons. Both sides of every slide header.

ANCHOR_ICON = [
    [0, 0, 1, 1, 1, 0, 0],
    [0, 0, 1, 0, 1, 0, 0],
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0],
    [1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 1],
    [0, 1, 1, 1, 1, 1, 0],
]


def _anchors(c):
    c.bitmap(
        ANCHOR_ICON, 1, 0,
        color="cyan"
    )
    c.bitmap(
        ANCHOR_ICON, 120, 0,
        color="cyan"
    )


def _header(c, title, color, font):
    # Header text is restricted to the space between
    # the two 7x7 anchors.
    c.text(
        _fit(c, title, font, 104),
        12, 0,
        font=font,
        color=color
    )


def _off(c, section):
    c.fill("black")
    _anchors(c)
    _header(
        c, "CHICAGO NWI MARINE",
        "green", "4x7"
    )
    c.line(0, 9, 127, 9, "darkgray")
    c.text(
        section + " OFF",
        2, 15,
        font="5x7",
        color="darkgray"
    )


def _digits(value):
    if value == "":
        return False

    for i in range(len(value)):
        if value[i] < "0" or value[i] > "9":
            return False
    return True


def _num(value):
    if value == "" or value == "MM" or value == "-":
        return None

    digits = 0
    dots = 0

    for i in range(len(value)):
        ch = value[i]

        if ch >= "0" and ch <= "9":
            digits += 1
        elif ch == ".":
            dots += 1
        elif ch == "-" and i == 0:
            pass
        else:
            return None

    if digits == 0 or dots > 1:
        return None

    return float(value)


# DATE AND TIME HELPERS

def _leap(y):
    return y % 4 == 0 and (
        y % 100 != 0 or y % 400 == 0
    )


def _month_days(y, m):
    if m == 2:
        return 29 if _leap(y) else 28

    if m == 4 or m == 6 or m == 9 or m == 11:
        return 30

    return 31


def _epoch(y, m, d, h, minute):
    days = 0

    for yr in range(1970, y):
        days += 366 if _leap(yr) else 365

    for mo in range(1, m):
        days += _month_days(y, mo)

    return (
        (days + d - 1) * 86400
        + h * 3600
        + minute * 60
    )


def _year_month(now):
    days = now // 86400

    for y in range(1970, 2200):
        size = 366 if _leap(y) else 365

        if days < size:
            for m in range(1, 13):
                size = _month_days(y, m)

                if days < size:
                    return y, m
                days -= size

            return y, 12
        days -= size

    return 2199, 12


def _age(cols, start, now):
    if len(cols) < start + 5:
        return None

    for i in range(start, start + 5):
        if not _digits(cols[i]):
            return None

    y = int(cols[start])
    m = int(cols[start + 1])
    d = int(cols[start + 2])
    h = int(cols[start + 3])
    minute = int(cols[start + 4])

    if y < 2020 or m < 1 or m > 12:
        return None

    if (
        d < 1
        or d > _month_days(y, m)
        or h > 23
        or minute > 59
    ):
        return None

    age = now - _epoch(
        y, m, d, h, minute
    )

    return age if age >= -120 else None


def _product_age(body, now):
    lines = body.split("\n")
    if len(lines) == 0:
        return None

    hdr = lines[0].split()

    if (
        len(hdr) < 3
        or len(hdr[2]) != 6
        or not _digits(hdr[2])
    ):
        return None

    day = int(hdr[2][:2])
    hour = int(hdr[2][2:4])
    minute = int(hdr[2][4:6])

    y, m = _year_month(now)

    months = [
        (y, m),
        (y - 1, 12)
        if m == 1 else (y, m - 1),
    ]

    best = None

    for year, month in months:
        if (
            day < 1
            or day > _month_days(year, month)
            or hour > 23
            or minute > 59
        ):
            continue

        age = now - _epoch(
            year, month, day, hour, minute
        )

        if age >= -600:
            if best == None or age < best:
                best = age

    return best


# UNITS AND COMPASS

def _kts(mps):
    return str(
        int(mps * 1.943844 + 0.5)
    )


def _ft(meters):
    tenth = int(meters * 32.8084 + 0.5)
    return (
        str(tenth // 10)
        + "."
        + str(tenth % 10)
    )


def _fahr(celsius):
    return str(
        int(celsius * 1.8 + 32.5)
    )


def _cardinal(deg):
    names = [
        "N", "NNE", "NE", "ENE",
        "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW",
        "W", "WNW", "NW", "NNW",
    ]
    return names[
        ((deg * 2 + 22) // 45) % 16
    ]


def _arrow(c, x, y, deg):
    # Wind points toward its source direction.
    dirs = [
        (0, -1), (1, -1),
        (1, 0), (1, 1),
        (0, 1), (-1, 1),
        (-1, 0), (-1, -1),
    ]

    ux, uy = dirs[
        ((deg + 22) // 45) % 8
    ]

    cx = x + 6
    cy = y + 4

    px = cx + ux * 5
    py = cy + uy * 3

    bx = px - ux * 3
    by = py - uy * 2

    c.line(
        cx - ux * 4, cy - uy * 3,
        px, py, "cyan"
    )

    c.line(
        px, py,
        bx - uy * 2, by + ux * 2,
        "cyan"
    )

    c.line(
        px, py,
        bx + uy * 2, by - ux * 2,
        "cyan"
    )


# NOAA OBSERVATIONS

def _ndbc(now):
    result = {
        "status": 0,
        "stations": {},
    }

    r = http.get(
        NDBC_URL,
        headers=NOAA_HEADERS,
        ttl_seconds=300
    )

    result["status"] = r["status_code"]

    if result["status"] != 200:
        return result

    if not r["body"].startswith("#STN"):
        result["status"] = -1
        return result

    targets = WIND_ALL + ["45214"]

    for line in r["body"].split("\n"):
        cols = line.strip().split()

        if (
            len(cols) < 19
            or cols[0] not in targets
        ):
            continue

        age = _age(cols, 3, now)
        if age == None:
            continue

        obs = {
            "age": age,
            "dir": None,
            "wind": None,
            "gust": None,
            "wave": None,
            "water": None,
        }

        if age <= WIND_MAX:
            direction = _num(cols[8])
            speed = _num(cols[9])
            gust = _num(cols[10])
            wave = _num(cols[11])

            if (
                direction != None
                and direction >= 0
                and direction <= 360
            ):
                obs["dir"] = int(direction)

            if (
                speed != None
                and speed >= 0
                and speed < 100
            ):
                obs["wind"] = speed

            if (
                gust != None
                and gust >= 0
                and gust < 100
            ):
                obs["gust"] = gust

            if (
                wave != None
                and wave >= 0
                and wave < 50
            ):
                obs["wave"] = wave

        if age <= TEMP_MAX:
            water = _num(cols[18])

            if (
                water != None
                and water > -10
                and water < 50
            ):
                obs["water"] = water

        previous = result["stations"].get(
            cols[0]
        )

        if (
            previous == None
            or age < previous["age"]
        ):
            result["stations"][cols[0]] = obs

    return result


def _freshest(stations, codes, field, limit):
    selected = None
    code_out = ""

    for code in codes:
        obs = stations.get(code)

        if (
            obs == None
            or obs["age"] > limit
            or obs[field] == None
        ):
            continue

        if (
            selected == None
            or obs["age"] < selected["age"]
        ):
            code_out = code
            selected = obs

    return code_out, selected


def _missing(data, codes, limit):
    if data["status"] != 200:
        return "FEED ERR"

    for code in codes:
        obs = data["stations"].get(code)

        if (
            obs != None
            and obs["age"] > limit
        ):
            return "STALE"

    return "NO DATA"


# WATER TEMPERATURE HISTORY

def _history_temp(code, now):
    r = http.get(
        NDBC_HISTORY + code + "_5day.txt",
        headers=NOAA_HEADERS,
        ttl_seconds=300
    )

    if r["status_code"] != 200:
        return None

    best = None

    for line in r["body"].split("\n")[:120]:
        cols = line.strip().split()

        if (
            len(cols) < 15
            or not _digits(cols[0])
        ):
            continue

        age = _age(cols, 0, now)

        if age == None or age > TEMP_MAX:
            continue

        water = _num(cols[14])

        if (
            water == None
            or water <= -10
            or water >= 50
        ):
            continue

        if best == None or age < best["age"]:
            best = {
                "age": age,
                "water": water,
            }

    return best


def _history_budget(ctx):
    fixed = 1

    if _enabled(ctx, "warn"):
        fixed += 1

    if _enabled(ctx, "fcst"):
        selected = _forecast_zones(ctx)

        for source in [
            LOT_ZONES, IWX_ZONES, OPEN_ZONES
        ]:
            for code in selected:
                if code in source:
                    fixed += 1
                    break

    budget = 8 - fixed

    if budget < 0:
        return 0

    return budget


def _water(ctx, data):
    codes = _buoys(ctx)

    code, obs = _freshest(
        data["stations"],
        codes,
        "water",
        TEMP_MAX
    )

    if obs != None:
        return code, obs

    budget = _history_budget(ctx)

    for buoy in codes[:budget]:
        item = _history_temp(
            buoy, ctx.now.unix
        )

        if item != None:
            if (
                obs == None
                or item["age"] < obs["age"]
            ):
                code = buoy
                obs = item

    return code, obs


# NWS FORECAST PARSING

def _zone_codes(line):
    if not line.startswith("LMZ"):
        return []

    codes = []
    parts = line.split("-")

    for part in parts:
        if part.startswith("LMZ"):
            part = part[3:]

        if ">" in part:
            pair = part.split(">")

            if (
                len(pair) == 2
                and len(pair[0]) == 3
                and len(pair[1]) == 3
                and _digits(pair[0])
                and _digits(pair[1])
            ):
                first = int(pair[0])
                last = int(pair[1])

                if last >= first and last - first < 30:
                    for number in range(
                        first, last + 1
                    ):
                        code = (
                            "LMZ"
                            + (
                                "0"
                                if number < 100
                                else ""
                            )
                            + str(number)
                        )

                        if (
                            code in ALL_ZONES
                            and code not in codes
                        ):
                            codes.append(code)

        elif len(part) == 3 and _digits(part):
            code = "LMZ" + part

            if (
                code in ALL_ZONES
                and code not in codes
            ):
                codes.append(code)

    return codes


def _parse_product(body, now):
    age = _product_age(body, now)

    if age == None or age > 86400:
        return {
            "status": "STALE",
            "groups": [],
        }

    if (
        "Marine Forecast" not in body
        and "OPEN LAKE FORECAST" not in body
    ):
        return {
            "status": "NO DATA",
            "groups": [],
        }

    groups = []
    current = None

    for line in body.split("\n"):
        row = line.strip()

        if row.startswith("LMZ"):
            codes = _zone_codes(row)

            if len(codes) > 0:
                current = {
                    "zones": codes,
                    "periods": [],
                }
                groups.append(current)
            else:
                current = None

            continue

        if row == "$$":
            current = None
            continue

        if current == None:
            continue

        if (
            row.startswith(".")
            and not row.startswith("...")
        ):
            marker = row.find("...", 1)

            if marker > 1 and marker < 45:
                name = row[1:marker].strip()

                if (
                    name != ""
                    and name.upper() != "SYNOPSIS"
                ):
                    current["periods"].append({
                        "name": name,
                        "text": row[
                            marker + 3:
                        ].strip(),
                    })
                    continue

        if (
            row != ""
            and len(current["periods"]) > 0
        ):
            i = len(current["periods"]) - 1
            current["periods"][i]["text"] += (
                " " + row
            )

    return {
        "status": (
            "OK"
            if len(groups) > 0
            else "NO DATA"
        ),
        "groups": groups,
    }


def _group_title(codes, published):
    if len(codes) == 1:
        return _zone_label(codes[0])

    if (
        "LMZ779" in published
        or "LMZ777" in published
        or "LMZ080" in published
    ):
        return "SOUTH OPEN LAKE"

    chicago = False
    indiana = False

    for code in codes:
        if code in [
            "LMZ740", "LMZ741", "LMZ742"
        ]:
            chicago = True

        if code in [
            "LMZ743", "LMZ744", "LMZ745"
        ]:
            indiana = True

    if chicago and indiana:
        return "CHICAGO/INDIANA"

    if chicago:
        return "CHICAGO SHORE"

    if indiana:
        return "INDIANA SHORE"

    if (
        "LMZ046" in published
        or "LMZ043" in published
    ):
        return "MICH CITY-ST JOSEPH"

    return _zone_label(codes[0])


def _read_forecasts(ctx):
    selected = _forecast_zones(ctx)
    outputs = []

    sources = [
        (LOT_URL, LOT_ZONES),
        (IWX_URL, IWX_ZONES),
        (OPEN_URL, OPEN_ZONES),
    ]

    for url, coverage in sources:
        wanted = []

        for code in selected:
            if code in coverage:
                wanted.append(code)

        if len(wanted) == 0:
            continue

        r = http.get(
            url,
            headers=NOAA_HEADERS,
            ttl_seconds=600
        )

        if r["status_code"] != 200:
            parsed = {
                "status": "FEED ERR",
                "groups": [],
            }
        else:
            parsed = _parse_product(
                r["body"],
                ctx.now.unix
            )

        covered = []

        for group in parsed["groups"]:
            matches = []

            for code in wanted:
                if code in group["zones"]:
                    matches.append(code)
                    covered.append(code)

            if (
                len(matches) > 0
                and len(group["periods"]) > 0
            ):
                outputs.append({
                    "title": _group_title(
                        matches,
                        group["zones"]
                    ),
                    "zones": matches,
                    "periods": group["periods"],
                    "error": "",
                })

        for code in wanted:
            if code not in covered:
                outputs.append({
                    "title": _zone_label(code),
                    "zones": [code],
                    "periods": [],
                    "error": (
                        parsed["status"]
                        if parsed["status"] != "OK"
                        else "NO FORECAST"
                    ),
                })

    return outputs


# FORECAST TEXT HELPERS

def _first_direction(text):
    words = [
        ("northwest", "NW"),
        ("northeast", "NE"),
        ("southwest", "SW"),
        ("southeast", "SE"),
        ("north", "N"),
        ("south", "S"),
        ("east", "E"),
        ("west", "W"),
    ]

    lower = text.lower()
    first = len(lower) + 1
    chosen = ""

    for word, short in words:
        at = lower.find(word)

        if at >= 0 and at < first:
            first = at
            chosen = short

    return chosen


def _numbers(text, units, maximum):
    words = (
        text.lower()
        .replace(",", " ")
        .replace(".", " ")
        .split()
    )

    found = []

    for i in range(1, len(words)):
        if (
            words[i] in units
            and _digits(words[i - 1])
        ):
            found.append(words[i - 1])

            if len(found) >= maximum:
                break

    return found


def _high(values):
    best = None

    for value in values:
        number = int(value)

        if best == None or number > best:
            best = number

    return best


def _wind_info(text):
    lower = text.lower()
    end = lower.find("waves")

    wind = (
        text
        if end < 0
        else text[:end]
    )

    glower = wind.lower()
    gust_at = glower.find("gust")

    main = (
        wind
        if gust_at < 0
        else wind[:gust_at]
    )

    gust_text = (
        ""
        if gust_at < 0
        else wind[gust_at:]
    )

    speeds = _numbers(
        main,
        ["kt", "kts", "knots", "knot"],
        12
    )

    peak = _high(speeds)

    gust = _high(
        _numbers(
            gust_text,
            ["kt", "kts", "knots", "knot"],
            3
        )
    )

    direction = _first_direction(main)
    at = main.lower().find("becoming")

    if at < 0:
        at = main.lower().find("veering")

    later = (
        _first_direction(main[at + 8:])
        if at >= 0
        else ""
    )

    if (
        later != ""
        and later != direction
        and direction != ""
    ):
        direction += "-" + later

    if "variable" in main.lower():
        direction = "VAR"

    if peak == None:
        label = "WIND NOT STATED"

    else:
        label = (
            (
                direction + " "
                if direction != ""
                else ""
            )
            + str(peak)
            + "KT"
        )

        if "or less" in main.lower():
            label = (
                (
                    direction + " "
                    if direction != ""
                    else ""
                )
                + "UP TO "
                + str(peak)
                + "KT"
            )

    if gust != None:
        label += " G" + str(gust)

    change = ""

    if (
        at >= 0
        and later != ""
        and direction != ""
    ):
        change = "WIND TURNS " + later

    elif "increasing" in main.lower():
        change = "WINDS INCREASING"

    elif (
        "diminishing" in main.lower()
        or "decreasing" in main.lower()
    ):
        change = "WINDS DECREASING"

    return label, change


def _wave_pair(text):
    words = (
        text.lower()
        .replace(",", " ")
        .replace(".", " ")
        .split()
    )

    for i in range(1, len(words)):
        if words[i] in ["ft", "feet", "foot"]:
            if _digits(words[i - 1]):
                hi = words[i - 1]
                lo = hi

                if (
                    i >= 3
                    and words[i - 2] == "to"
                    and _digits(words[i - 3])
                ):
                    lo = words[i - 3]

                if lo != hi:
                    return lo + "-" + hi

                return hi

    return ""


def _wave_info(text):
    lower = text.lower()
    at = lower.find("waves")

    if at < 0:
        return "--", ""

    block = lower[at:]
    first = _wave_pair(block)

    if first == "":
        return "--", ""

    if "or less" in block[:45]:
        value = first + "FT OR LESS"
    else:
        value = first + "FT"

    trend = ""

    for token, caption in [
        ("building to", "WAVES BUILD TO "),
        ("increasing to", "WAVES BUILD TO "),
        ("subsiding to", "WAVES EASE TO "),
        ("decreasing to", "WAVES EASE TO "),
    ]:
        pos = block.find(token)

        if pos >= 0:
            next_wave = _wave_pair(
                block[pos + len(token):]
            )

            if next_wave != "":
                trend = caption + next_wave + "FT"

            break

    occ = block.find("occasion")

    if occ >= 0:
        extra = _wave_pair(block[occ:])

        if extra != "":
            if trend != "":
                trend += " OCC " + extra
            else:
                trend = (
                    "OCCASIONAL WAVES "
                    + extra
                    + "FT"
                )

    return value, trend


def _weather(text):
    lower = text.lower()

    chance = (
        "slight chance" in lower
        or "chance" in lower
        or "isolated" in lower
    )

    likely = (
        "likely" in lower
        and "advisory will likely" not in lower
    )

    scattered = "scattered" in lower

    if "thunderstorm" in lower:
        label = "THUNDERSTORMS"

    elif (
        "freezing spray" in lower
        or "freezing rain" in lower
        or "ice accumulation" in lower
    ):
        label = "FREEZING CONDITIONS"

    elif "fog" in lower:
        label = "FOG"

    elif (
        "snow" in lower
        and (
            "rain" in lower
            or "shower" in lower
        )
    ):
        label = "RAIN/SNOW"

    elif "snow" in lower:
        label = "SNOW"

    elif (
        "rain" in lower
        or "shower" in lower
        or "drizzle" in lower
    ):
        label = "RAIN"

    elif "partly sunny" in lower:
        label = "PARTLY SUNNY"

    elif "partly cloudy" in lower:
        label = "PARTLY CLOUDY"

    elif "mostly cloudy" in lower:
        label = "MOSTLY CLOUDY"

    elif "cloudy" in lower:
        label = "CLOUDY"

    elif "mostly sunny" in lower:
        label = "MOSTLY SUNNY"

    elif "sunny" in lower:
        label = "SUNNY"

    elif "clear" in lower:
        label = "CLEAR"

    else:
        label = "WIND & WAVE FORECAST"

    if chance:
        label += " POSSIBLE"

    elif (
        likely
        and label not in [
            "MOSTLY CLOUDY",
            "CLOUDY",
        ]
    ):
        label += " LIKELY"

    elif (
        scattered
        and label == "RAIN/SNOW"
    ):
        label = "SCATTERED RAIN/SNOW"

    return label


def _period_label(name):
    upper = name.upper().strip()

    if (
        "TODAY" in upper
        or "THIS AFTERNOON" in upper
        or "THIS MORNING" in upper
    ):
        return "TODAY"

    if (
        "TONIGHT" in upper
        or "OVERNIGHT" in upper
        or "THIS EVENING" in upper
    ):
        return "TONIGHT"

    days = [
        ("MONDAY", "MON"),
        ("TUESDAY", "TUE"),
        ("WEDNESDAY", "WED"),
        ("THURSDAY", "THU"),
        ("FRIDAY", "FRI"),
        ("SATURDAY", "SAT"),
        ("SUNDAY", "SUN"),
    ]

    for whole, short in days:
        if whole in upper:
            if "NIGHT" in upper:
                return short + " NIGHT"
            return short

    return "FORECAST"


def _wave_forecast(ctx):
    selected = _forecast_zones(ctx)
    url = LOT_URL
    wanted = LOT_ZONES

    for code in selected:
        if code in IWX_ZONES:
            url = IWX_URL
            wanted = IWX_ZONES
            break

        if code in LOT_ZONES:
            break

        if code in OPEN_ZONES:
            url = OPEN_URL
            wanted = OPEN_ZONES
            break

    r = http.get(
        url,
        headers=NOAA_HEADERS,
        ttl_seconds=600
    )

    if r["status_code"] != 200:
        return ""

    data = _parse_product(
        r["body"],
        ctx.now.unix
    )

    if data["status"] != "OK":
        return ""

    for group in data["groups"]:
        good = False

        for code in selected:
            if (
                code in group["zones"]
                and code in wanted
            ):
                good = True

        if (
            good
            and len(group["periods"]) > 0
        ):
            for period in group["periods"]:
                if (
                    _period_label(
                        period["name"]
                    ) == "TODAY"
                ):
                    wave, trend = _wave_info(
                        period["text"]
                    )
                    if wave != "--":
                        return wave

            wave, trend = _wave_info(
                group["periods"][0]["text"]
            )

            if wave != "--":
                return wave

    return ""


# PAGE 1 - CURRENT CONDITIONS

def conditions(c, ctx):
    if not _enabled(ctx, "cond"):
        _off(c, "CONDITIONS")
        return

    c.fill("black")
    _anchors(c)

    data = _ndbc(ctx.now.unix)
    wind_ids = _winds(ctx)
    buoy_ids = _buoys(ctx)

    wind_id, wind = _freshest(
        data["stations"],
        wind_ids,
        "wind",
        WIND_MAX
    )

    wave_id, wave = _freshest(
        data["stations"],
        buoy_ids,
        "wave",
        WIND_MAX
    )

    water_id, water = _water(ctx, data)

    if wind != None:
        heading = (
            _station_label(wind_id)
            + " "
            + str(wind["age"] // 60)
            + "M"
        )
    else:
        heading = "SELECTED WIND UNAVAIL"

    _header(
        c, heading,
        "green" if wind != None else "amber",
        "4x7"
    )

    c.line(0, 8, 127, 8, "darkgray")
    c.line(64, 9, 64, 31, "darkgray")

    # LEFT: WIND

    c.text(
        "WIND", 2, 11,
        font="4x7",
        color="white"
    )

    if wind != None:
        speed = _kts(wind["wind"]) + "KT"
        speed_font = "4x7"

        if wind["dir"] != None:
            bearing = _cardinal(wind["dir"])

            arrow_x = 21
            bearing_x = 35

            if len(bearing) == 3:
                arrow_x = 19
                bearing_x = 31
                speed_font = "3x7"

            bearing_end = (
                bearing_x
                + c.text_width(
                    bearing,
                    font="3x7"
                )
            )

            speed_start = (
                62
                - c.text_width(
                    speed,
                    font=speed_font
                )
            )

            if speed_start < bearing_end + 2:
                speed_font = "3x7"

                speed_start = (
                    62
                    - c.text_width(
                        speed,
                        font=speed_font
                    )
                )

            _arrow(
                c, arrow_x, 10,
                wind["dir"]
            )

            if speed_start >= bearing_end + 2:
                c.text(
                    bearing,
                    bearing_x, 11,
                    font="3x7",
                    color="cyan"
                )

        c.text(
            _fit(
                c, speed,
                speed_font, 24
            ),
            62, 11,
            font=speed_font,
            align="right",
            color="green"
        )

    else:
        c.text(
            _fit(
                c,
                _missing(
                    data, wind_ids, WIND_MAX
                ),
                "3x7", 35
            ),
            62, 11,
            font="3x7",
            align="right",
            color="amber"
        )

    # LEFT: GUST

    c.text(
        "GUST", 2, 21,
        font="4x7",
        color="white"
    )

    if wind != None and wind["gust"] != None:
        gust = _kts(wind["gust"]) + "KT"
    else:
        gust = "--"

    c.text(
        _fit(c, gust, "4x7", 34),
        62, 21,
        font="4x7",
        align="right",
        color=(
            "amber"
            if gust != "--"
            else "darkgray"
        )
    )

    # RIGHT: WAVE HEIGHT

    label = "WAVE"

    if wave != None:
        value = _ft(wave["wave"]) + "FT"

    else:
        value = ""

        if _enabled(ctx, "fcst"):
            value = _wave_forecast(ctx)

            if value != "":
                label = "WAVE FCST"

        if value == "":
            value = _missing(
                data, buoy_ids, WIND_MAX
            )

    if (
        label == "WAVE FCST"
        and "FT OR LESS" in value
    ):
        value = value.replace(
            "FT OR LESS", "FT MAX"
        )

    label_font = (
        "3x7"
        if label == "WAVE FCST"
        else "4x7"
    )

    label_width = c.text_width(
        label, font=label_font
    )

    available = (
        126 - 68 - label_width - 3
    )

    if (
        c.text_width(
            value, font="4x7"
        ) <= available
    ):
        wavefont = "4x7"
    else:
        wavefont = "3x7"

    c.text(
        label,
        68, 11,
        font=label_font,
        color=(
            "amber"
            if label == "WAVE FCST"
            else "white"
        )
    )

    c.text(
        _fit(
            c, value,
            wavefont, available
        ),
        126, 11,
        font=wavefont,
        align="right",
        color=(
            "cyan"
            if wave != None
            or label == "WAVE FCST"
            else "amber"
        )
    )

    # RIGHT: WATER TEMPERATURE

    c.text(
        "WATER",
        68, 21,
        font="4x7",
        color="white"
    )

    if water != None:
        temp = (
            _fahr(water["water"])
            + "F"
        )

        old = water["age"] > WIND_MAX

        if old:
            temp += (
                " "
                + str(
                    water["age"] // 3600
                )
                + "H"
            )

        color = (
            "amber"
            if old
            else "cyan"
        )

    else:
        temp = _missing(
            data, buoy_ids, TEMP_MAX
        )
        color = "amber"

    font = (
        "4x7"
        if c.text_width(
            temp, font="4x7"
        ) <= 29
        else "3x7"
    )

    c.text(
        _fit(c, temp, font, 31),
        126, 21,
        font=font,
        align="right",
        color=color
    )


# WARNING HELPERS

def _rank(severity):
    return {
        "Extreme": 4,
        "Severe": 3,
        "Moderate": 2,
        "Minor": 1,
    }.get(severity, 0)


def _alerts(zones):
    data = {
        "error": False,
        "by_zone": {},
        "bulletins": [],
    }

    for code in zones:
        data["by_zone"][code] = []

    r = http.get(
        ALERT_URL,
        headers=NWS_HEADERS,
        ttl_seconds=300
    )

    if (
        r["status_code"] != 200
        or r["json"] == None
    ):
        data["error"] = True
        return data

    seen = {}

    for feature in r["json"].get(
        "features", []
    ):
        props = feature.get(
            "properties", {}
        )

        event = (
            props.get("event", "")
            or ""
        )

        if event == "":
            continue

        geo = (
            props.get("geocode", {})
            or {}
        )

        affected = (
            geo.get("UGC", [])
            or []
        )

        if len(affected) == 0:
            for url in props.get(
                "affectedZones", []
            ):
                bits = url.split("/")
                affected.append(
                    bits[len(bits) - 1]
                )

        matches = []

        for code in zones:
            if code in affected:
                matches.append(code)

        if len(matches) == 0:
            continue

        ident = (
            feature.get("id", "")
            or props.get("id", "")
            or (
                event
                + "|"
                + (
                    props.get(
                        "description", ""
                    )
                    or ""
                )
            )
        )

        item = seen.get(ident)

        if item == None:
            item = {
                "event": event,
                "severity": (
                    props.get(
                        "severity", ""
                    )
                    or ""
                ),
                "description": (
                    props.get(
                        "description", ""
                    )
                    or ""
                ),
                "zones": [],
            }

            seen[ident] = item
            data["bulletins"].append(item)

        for code in matches:
            if code not in item["zones"]:
                item["zones"].append(code)
                data["by_zone"][
                    code
                ].append(item)

    return data


def _best(items):
    chosen = None
    highest = -1

    for item in items:
        level = _rank(
            item["severity"]
        )

        if (
            chosen == None
            or level > highest
        ):
            chosen = item
            highest = level

    return chosen


def _event_code(event):
    if event.startswith("Small Craft"):
        return "SCA"

    if event.startswith("Gale"):
        return "GALE"

    if event.startswith("Storm"):
        return "STORM"

    if event.startswith("Dense Fog"):
        return "FOG"

    if event.startswith("Special Marine"):
        return "SMW"

    return "WARN"


def _alert_color(status):
    if status == "NONE":
        return "green"

    if status == "N/A":
        return "amber"

    return "red"


def _alert_group(item):
    name = _zone_short(
        item["zones"][0]
    )

    if len(item["zones"]) > 1:
        name += (
            "+"
            + str(
                len(item["zones"]) - 1
            )
        )

    return name


# PAGE 2: WARNINGS BY AREA

def advisories(c, ctx):
    if not _enabled(ctx, "warn"):
        _off(c, "WARNINGS")
        return

    c.fill("black")
    _anchors(c)

    zones = _warnings_zones(ctx)
    data = _alerts(zones)
    count = len(zones)

    if count > 6:
        batch = (
            (ctx.now.unix // 300)
            % ((count + 5) // 6)
        )

        shown = zones[
            batch * 6:batch * 6 + 6
        ]

        title = (
            "LAKE WARN "
            + str(batch + 1)
            + "/"
            + str((count + 5) // 6)
        )

    else:
        shown = zones
        title = "LAKE WARNINGS"

    _header(
        c, title, "amber", "5x7"
    )

    c.line(0, 8, 127, 8, "darkgray")

    if len(shown) > 2:
        c.line(
            64, 9, 64, 31,
            "darkgray"
        )

        for i in range(len(shown)):
            zone = shown[i]
            item = _best(
                data["by_zone"][zone]
            )

            if data["error"]:
                status = "N/A"
            elif item == None:
                status = "NONE"
            else:
                status = _event_code(
                    item["event"]
                )

            x = (
                2 if i < 3 else 66
            )

            right = (
                62 if i < 3 else 126
            )

            y = 10 + (i % 3) * 7

            c.text(
                _zone_short(zone),
                x, y,
                font="4x5",
                color="white"
            )

            c.text(
                status,
                right, y,
                font="4x5",
                align="right",
                color=_alert_color(
                    status
                )
            )

        return

    for i in range(len(shown)):
        zone = shown[i]
        item = _best(
            data["by_zone"][zone]
        )

        if data["error"]:
            status = "N/A"
        elif item == None:
            status = "NONE"
        else:
            status = _event_code(
                item["event"]
            )

        y = 11 + i * 10

        c.text(
            _fit(
                c,
                _zone_label(zone),
                "4x7", 92
            ),
            2, y,
            font="4x7",
            color="white"
        )

        c.text(
            status,
            126, y,
            font="5x7",
            align="right",
            color=_alert_color(
                status
            )
        )


# WARNING DETAIL HELPERS

def _section(description, name):
    marker = "* " + name + "..."
    start = description.find(marker)

    if start < 0:
        marker = name + "..."
        start = description.find(marker)

    if start < 0:
        return ""

    value = description[
        start + len(marker):
    ]

    end = value.find("\n\n")

    if end >= 0:
        value = value[:end]

    end = value.find("* ")

    if end >= 0:
        value = value[:end]

    return " ".join(
        value.split()
    ).strip(" .")


def _alert_wave_parts(what):
    at = what.lower().find(
        "occasion"
    )

    normal = (
        what
        if at < 0
        else what[:at]
    )

    extra = (
        ""
        if at < 0
        else what[at:]
    )

    waves = _numbers(
        normal,
        ["ft", "foot", "feet"],
        6
    )

    high = _numbers(
        extra,
        ["ft", "foot", "feet"],
        1
    )

    wave = (
        waves[len(waves) - 1]
        if len(waves) > 0
        else ""
    )

    unusual = (
        high[0]
        if len(high) > 0
        else ""
    )

    return wave, unusual


def _when(value):
    value = value.upper()
    at = value.find("UNTIL ")

    if at < 0:
        at = value.find(
            "THROUGH "
        )

    if at >= 0:
        value = value[at:]

    changes = [
        ("UNTIL ", "TIL "),
        ("THROUGH ", "THRU "),
        (" MONDAY", " MON"),
        (" TUESDAY", " TUE"),
        (" WEDNESDAY", " WED"),
        (" THURSDAY", " THU"),
        (" FRIDAY", " FRI"),
        (" SATURDAY", " SAT"),
        (" SUNDAY", " SUN"),
        (" AM", "AM"),
        (" PM", "PM"),
    ]

    for old, new in changes:
        value = value.replace(
            old, new
        )

    return (
        value
        if value != ""
        else "CHECK NWS END TIME"
    )


def _alert_lines(item):
    what = _section(
        item["description"],
        "WHAT"
    )

    when = _section(
        item["description"],
        "WHEN"
    )

    winds = _numbers(
        what,
        ["kt", "kts", "knot", "knots"],
        2
    )

    wave, high = _alert_wave_parts(
        what
    )

    if len(winds) > 0:
        wind = (
            "WIND "
            + _first_direction(what)
            + " "
            + winds[0]
            + "KT"
        )

        if (
            len(winds) > 1
            and "gust" in what.lower()
        ):
            wind += " G" + winds[1]

    else:
        wind = (
            "WAVES-ONLY WARNING"
            if wave != ""
            else "WIND NOT GIVEN"
        )

    waves = (
        "WAVES " + wave + "FT"
        if wave != ""
        else "SEE NWS DETAILS"
    )

    if high != "":
        waves += " OCC" + high + "FT"

    return (
        wind,
        waves,
        _when(when)
    )


def _alert_brief(item):
    what = _section(
        item["description"], "WHAT"
    )

    winds = _numbers(
        what,
        ["kt", "kts", "knot", "knots"],
        1
    )

    wave, high = _alert_wave_parts(
        what
    )

    if len(winds) > 0:
        result = (
            _first_direction(what)
            + winds[0]
            + "KT"
        )
    else:
        result = ""

    if wave != "":
        result += (
            "/"
            if result != ""
            else "WAV"
        )

        result += wave

        if high != "":
            result += "/" + high

        result += "FT"

    return (
        result
        if result != ""
        else "SEE NWS"
    )


# PAGE 3: ACTIVE WARNING LIST

def alert_list(c, ctx):
    if not _enabled(ctx, "warn"):
        _off(c, "WARNINGS")
        return

    c.fill("black")
    _anchors(c)

    data = _alerts(
        _warnings_zones(ctx)
    )

    items = data["bulletins"]

    if len(items) == 0:
        _header(
            c,
            "MARINE WARNINGS",
            "amber", "5x7"
        )

        msg = (
            "NWS DATA UNAVAILABLE"
            if data["error"]
            else "NO ACTIVE WARNINGS"
        )

        c.text(
            msg,
            2, 14,
            font="5x7",
            color=(
                "amber"
                if data["error"]
                else "green"
            )
        )
        return

    _header(
        c,
        "ACTIVE WARNINGS "
        + str(len(items)),
        "amber", "5x7"
    )

    visible = (
        4 if len(items) <= 4 else 3
    )

    for i in range(len(items)):
        if i >= visible:
            break

        item = items[i]

        label = (
            _alert_group(item)
            + " "
            + _event_code(item["event"])
            + " "
            + _alert_brief(item)
        )

        c.text(
            _fit(c, label, "4x5", 124),
            2, 9 + i * 6,
            font="4x5",
            color="red"
        )

    if len(items) > visible:
        c.text(
            "+"
            + str(len(items) - visible)
            + " MORE",
            2, 27,
            font="4x5",
            color="amber"
        )


# PAGE 4: WARNING DETAILS

def details(c, ctx):
    if not _enabled(ctx, "warn"):
        _off(c, "WARNINGS")
        return

    c.fill("black")
    _anchors(c)

    data = _alerts(
        _warnings_zones(ctx)
    )

    chosen = _best(
        data["bulletins"]
    )

    if chosen == None:
        _header(
            c,
            "WARNING DETAILS",
            "amber", "5x7"
        )

        msg = (
            "NWS DATA UNAVAILABLE"
            if data["error"]
            else "NO ACTIVE WARNINGS"
        )

        c.text(
            msg,
            2, 14,
            font="5x7",
            color=(
                "amber"
                if data["error"]
                else "green"
            )
        )
        return

    title = (
        _alert_group(chosen)
        + " "
        + _event_code(
            chosen["event"]
        )
    )

    wind, waves, when = _alert_lines(
        chosen
    )

    _header(
        c, title,
        "amber", "4x7"
    )

    c.text(
        _fit(c, wind, "4x7", 124),
        2, 8,
        font="4x7",
        color="cyan"
    )

    c.text(
        _fit(c, waves, "4x7", 124),
        2, 16,
        font="4x7",
        color="cyan"
    )

    c.text(
        _fit(c, when, "4x7", 124),
        2, 24,
        font="4x7",
        color="white"
    )


# ADAPTIVE FORECAST PERIODS

def _period_focus(ctx):
    value = str(ctx.inputs.get("period", "Auto"))

    allowed = {
        "Auto": "Auto (adaptive)",
        "Today": "Today",
        "Tonight": "Tonight",
        "Tomorrow": "Tomorrow",
        "Tmrw Night": "Tomorrow Night",
        "Rotate": "Rotate periods",
    }

    return allowed.get(value.strip(), "Auto (adaptive)")


def _is_night(name):
    upper = name.upper()

    return (
        "NIGHT" in upper
        or "OVERNIGHT" in upper
        or "EVENING" in upper
    )


def _is_today(name):
    upper = name.upper()

    return (
        (
            "TODAY" in upper
            or "AFTERNOON" in upper
            or "THIS MORNING" in upper
            or "REST OF THE DAY" in upper
        )
        and not _is_night(name)
    )


def _start_period(periods, focus):
    if (
        focus == "Auto (adaptive)"
        or focus == "Rotate periods"
    ):
        return 0

    if focus == "Today":
        for i in range(len(periods)):
            if _is_today(
                periods[i]["name"]
            ):
                return i
        return None

    if focus == "Tonight":
        for i in range(len(periods)):
            if _is_night(
                periods[i]["name"]
            ):
                return i
        return None

    first_night = -1

    for i in range(len(periods)):
        if _is_night(
            periods[i]["name"]
        ):
            first_night = i
            break

    if first_night < 0:
        return None

    tomorrow = -1

    for i in range(
        first_night + 1,
        len(periods)
    ):
        if not _is_night(
            periods[i]["name"]
        ):
            tomorrow = i
            break

    if focus == "Tomorrow":
        if tomorrow >= 0:
            return tomorrow
        return None

    if (
        focus == "Tomorrow Night"
        and tomorrow >= 0
    ):
        for i in range(
            tomorrow + 1,
            len(periods)
        ):
            if _is_night(
                periods[i]["name"]
            ):
                return i

    return None


def _forecast_slots(groups, now, focus):
    count = len(groups)

    if count == 0:
        return []

    slots = []

    if count >= OUTLOOK_PAGES:
        if count > OUTLOOK_PAGES:
            start_group = (
                (now // 300) % count
            )
        else:
            start_group = 0

        if focus == "Rotate periods":
            rotation = (
                (now // 300) % 4
            )
        else:
            rotation = 0

        for page in range(
            OUTLOOK_PAGES
        ):
            idx = (
                start_group + page
            ) % count

            group = groups[idx]
            periods = group["periods"]

            start = _start_period(
                periods, focus
            )

            if focus == "Rotate periods":
                if rotation < len(periods):
                    start = rotation
                else:
                    start = None

            slots.append({
                "group": group,
                "period": start,
                "group_num": idx + 1,
                "group_total": count,
            })

        return slots

    # Fewer than four distinct forecast groups.

    for phase in range(
        OUTLOOK_PAGES
    ):
        for i in range(count):
            if len(slots) >= OUTLOOK_PAGES:
                return slots

            group = groups[i]
            periods = group["periods"]

            start = _start_period(
                periods, focus
            )

            if start == None:
                if phase == 0:
                    slots.append({
                        "group": group,
                        "period": None,
                        "group_num": i + 1,
                        "group_total": count,
                    })

            elif (
                start + phase < len(periods)
                or (
                    phase == 0
                    and len(periods) == 0
                )
            ):
                slots.append({
                    "group": group,
                    "period": start + phase,
                    "group_num": i + 1,
                    "group_total": count,
                })

    return slots


# PAGES 5-8: MARINE OUTLOOK

def _outlook(c, ctx, page):
    if not _enabled(ctx, "fcst"):
        _off(c, "FORECAST")
        return

    c.fill("black")
    _anchors(c)

    groups = _read_forecasts(ctx)

    slots = _forecast_slots(
        groups,
        ctx.now.unix,
        _period_focus(ctx)
    )

    if len(slots) == 0:
        c.text(
            "FORECAST UNAVAILABLE",
            2, 12,
            font="5x7",
            color="amber"
        )
        return

    index = page - 1

    if index >= len(slots):
        c.text(
            "NO ADDITIONAL PERIOD",
            2, 12,
            font="4x7",
            color="amber"
        )
        return

    slot = slots[index]
    group = slot["group"]
    title = group["title"]

    if slot["group_total"] > OUTLOOK_PAGES:
        title += (
            " "
            + str(slot["group_num"])
            + "/"
            + str(slot["group_total"])
        )

    else:
        visible_for_group = 0

        for other in slots:
            if (
                other["group_num"]
                == slot["group_num"]
            ):
                visible_for_group += 1

        if visible_for_group > 1:
            ordinal = 1

            for other in slots[:index]:
                if (
                    other["group_num"]
                    == slot["group_num"]
                ):
                    ordinal += 1

            title += (
                " "
                + str(ordinal)
                + "/"
                + str(visible_for_group)
            )

    _header(
        c, title,
        "amber", "4x7"
    )

    c.line(
        0, 8, 127, 8,
        "darkgray"
    )

    if (
        group["error"] != ""
        or len(group["periods"]) == 0
    ):
        msg = (
            group["error"]
            if group["error"] != ""
            else "NO FORECAST"
        )

        c.text(
            _fit(c, msg, "5x7", 124),
            2, 14,
            font="5x7",
            color="amber"
        )
        return

    if slot["period"] == None:
        c.text(
            "PERIOD NOT AVAILABLE",
            2, 14,
            font="4x7",
            color="amber"
        )
        return

    period = group["periods"][
        slot["period"]
    ]

    time = _period_label(
        period["name"]
    )

    weather = _weather(
        period["text"]
    )

    sca_possible = (
        "small craft advisory will likely be needed"
        in period["text"].lower()
    )

    wind, wind_change = _wind_info(
        period["text"]
    )

    waves, wave_change = _wave_info(
        period["text"]
    )

    weather_line = (
        time + ": " + weather
    )

    wind_line = (
        wind
        + "  WAVES "
        + waves
    )

    detail_line = (
        wave_change
        if wave_change != ""
        else wind_change
    )

    if sca_possible:
        detail_line = (
            "SMALL CRAFT ADVISORY POSSIBLE"
        )

    elif detail_line == "":
        detail_line = (
            "NWS MARINE FORECAST"
        )

    if (
        "POSSIBLE" in weather
        or "THUNDER" in weather
        or "SNOW" in weather
        or "RAIN" in weather
        or "FOG" in weather
    ):
        weather_color = "amber"
    else:
        weather_color = "white"

    if (
        "EASE" in detail_line
        or "DECREAS" in detail_line
    ):
        detail_color = "green"

    elif (
        "BUILD" in detail_line
        or "INCREAS" in detail_line
        or "ADVISORY" in detail_line
    ):
        detail_color = "amber"

    else:
        detail_color = "white"

    c.text(
        _fit(
            c, weather_line,
            "4x5", 124
        ),
        2, 10,
        font="4x5",
        color=weather_color
    )

    c.text(
        _fit(
            c, wind_line,
            "4x5", 124
        ),
        2, 17,
        font="4x5",
        color="cyan"
    )

    c.text(
        _fit(
            c, detail_line,
            "4x5", 124
        ),
        2, 24,
        font="4x5",
        color=detail_color
    )


def outlook1(c, ctx):
    _outlook(c, ctx, 1)


def outlook2(c, ctx):
    _outlook(c, ctx, 2)


def outlook3(c, ctx):
    _outlook(c, ctx, 3)


def outlook4(c, ctx):
    _outlook(c, ctx, 4)
