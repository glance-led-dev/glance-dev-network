# ============================================================
# PILOT BOARD
# KTKI + KADS live aviation weather
#
# Runway true bearings:
# KTKI 18 = 182 true / 36 = 002 true
# KADS 16 = 160 true / 34 = 340 true
# ============================================================

METAR_URL = "https://aviationweather.gov/api/data/metar"


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

def safe(d, key, fallback = None):
    if d == None or type(d) != "dict":
        return fallback

    v = d.get(key, fallback)

    if v == None:
        return fallback

    return v


def fmt_num(v):
    if v == None:
        return "--"

    s = str(v)

    if s.endswith(".0"):
        s = s[:-2]

    return s


def pad2(v):
    if v == None:
        return "--"

    n = int(v)

    if n < 10:
        return "0" + str(n)

    return str(n)


def pad3(v):
    if v == None:
        return "---"

    n = int(v)

    if n < 10:
        return "00" + str(n)

    if n < 100:
        return "0" + str(n)

    return str(n)


def abs_num(v):
    if v < 0:
        return -v

    return v


def category_color(cat):
    cat = str(cat).upper()

    if cat == "VFR":
        return "green"

    if cat == "MVFR":
        return "#009CFF"

    if cat == "IFR":
        return "red"

    if cat == "LIFR":
        return "#FF4FCB"

    return "gray"


# ------------------------------------------------------------
# METAR formatting
# ------------------------------------------------------------

def wind_text(m):
    speed = safe(m, "wspd", None)
    gust = safe(m, "wgst", None)
    direction = safe(m, "wdir", None)

    if speed == None:
        return "---"

    if int(speed) == 0:
        return "CALM"

    if direction == None:
        out = "VRB/" + pad2(speed)
    else:
        out = pad3(direction) + "/" + pad2(speed)

    if gust != None:
        out += "G" + fmt_num(gust)

    return out


def visibility_text(m):
    vis = safe(m, "visib", None)

    if vis == None:
        return "--"

    v = fmt_num(vis)

    if v == "10":
        return "10+"

    return v


def altimeter_text(m):
    alt = safe(m, "altim", None)

    if alt == None:
        return "--.--"

    a = int(float(str(alt)) * 100 + 0.5)
    hundredths = int(a * 2953 / 100000 + 0.5)

    whole = hundredths // 100
    frac = hundredths % 100

    return str(whole) + "." + pad2(frac)


# ------------------------------------------------------------
# Temperature / Dewpoint
# AWC = Celsius. Display = Fahrenheit.
# ------------------------------------------------------------

def c_to_f(v):
    if v == None:
        return None

    c = float(str(v))
    f = (c * 9.0 / 5.0) + 32.0

    if f >= 0:
        return int(f + 0.5)

    return int(f - 0.5)


def temp_f_text(v):
    f = c_to_f(v)

    if f == None:
        return "--"

    return str(f)


def temp_dew_f_text(m):
    return (
        temp_f_text(safe(m, "temp", None))
        + "/"
        + temp_f_text(safe(m, "dewp", None))
    )


# ------------------------------------------------------------
# Ceiling
# ------------------------------------------------------------

def ceiling_text(m):
    clouds = safe(m, "clouds", None)

    if clouds == None or type(clouds) != "list":
        return "---"

    lowest = None
    lowest_cover = ""

    for layer in clouds:
        cover = str(safe(layer, "cover", "")).upper()
        base = safe(layer, "base", None)

        if cover == "BKN" or cover == "OVC" or cover == "VV":
            if base != None:
                h = int(base)

                if lowest == None or h < lowest:
                    lowest = h
                    lowest_cover = cover

    if lowest != None:
        hundreds = int(lowest / 100)

        if hundreds < 10:
            htxt = "00" + str(hundreds)
        elif hundreds < 100:
            htxt = "0" + str(hundreds)
        else:
            htxt = str(hundreds)

        return lowest_cover + htxt

    for layer in clouds:
        cover = str(safe(layer, "cover", "")).upper()

        if cover == "CLR" or cover == "SKC":
            return "CLR"

    for layer in clouds:
        cover = str(safe(layer, "cover", "")).upper()

        if cover == "FEW" or cover == "SCT":
            return "NO CIG"

    return "CLR"


# ------------------------------------------------------------
# Angle helpers
# ------------------------------------------------------------

def angle_difference(a, b):
    d = a - b

    if d > 180:
        d = d - 360

    if d < -180:
        d = d + 360

    return d


def favored_runway(wind_dir, heading_a, name_a, heading_b, name_b):
    diff_a = abs_num(angle_difference(wind_dir, heading_a))
    diff_b = abs_num(angle_difference(wind_dir, heading_b))

    if diff_a <= diff_b:
        return {
            "name": name_a,
            "heading": heading_a,
            "angle": diff_a,
        }

    return {
        "name": name_b,
        "heading": heading_b,
        "angle": diff_b,
    }


# ------------------------------------------------------------
# Wind component approximation
# ------------------------------------------------------------

def component_factors(angle):
    a = int(angle + 0.5)

    if a <= 2:
        return [100, 0]
    if a <= 7:
        return [100, 9]
    if a <= 12:
        return [98, 17]
    if a <= 17:
        return [97, 26]
    if a <= 22:
        return [94, 34]
    if a <= 27:
        return [91, 42]
    if a <= 32:
        return [87, 50]
    if a <= 37:
        return [82, 57]
    if a <= 42:
        return [77, 64]
    if a <= 47:
        return [71, 71]
    if a <= 52:
        return [64, 77]
    if a <= 57:
        return [57, 82]
    if a <= 62:
        return [50, 87]
    if a <= 67:
        return [42, 91]
    if a <= 72:
        return [34, 94]
    if a <= 77:
        return [26, 97]
    if a <= 82:
        return [17, 98]
    if a <= 87:
        return [9, 100]

    return [0, 100]


def wind_components(speed, angle):
    factors = component_factors(angle)

    head = int((speed * factors[0] + 50) / 100)
    cross = int((speed * factors[1] + 50) / 100)

    return {
        "head": head,
        "cross": cross,
    }


# ------------------------------------------------------------
# Live METAR
# ------------------------------------------------------------

def read_metars(ctx):
    result = {
        "KTKI": None,
        "KADS": None,
        "state": "ok",
    }

    r = http.get(
        METAR_URL,
        params = {
            "ids": "KTKI,KADS",
            "format": "json",
        },
        ttl_seconds = 300,
    )

    if r["status_code"] != 200:
        result["state"] = "offline"
        return result

    data = r["json"]

    if data == None or type(data) != "list":
        result["state"] = "offline"
        return result

    for m in data:
        station = str(safe(m, "icaoId", "")).upper()

        if station == "KTKI":
            result["KTKI"] = m

        if station == "KADS":
            result["KADS"] = m

    return result


# ------------------------------------------------------------
# WEATHER PAGE
# ------------------------------------------------------------

def weather_page(c, ctx, airport):
    c.fill("black")

    data = read_metars(ctx)
    m = data[airport]

    c.text(
        airport,
        2,
        1,
        font = "5x7",
        color = "white",
    )

    if data["state"] == "offline":
        c.text_center(
            "NO WEATHER DATA",
            13,
            font = "5x7",
            color = "red",
        )
        return

    if m == None:
        c.text_center(
            "METAR UNAVAILABLE",
            13,
            font = "4x5",
            color = "gray",
        )
        return

    cat = str(safe(m, "fltCat", "---")).upper()

    c.text(
        cat,
        126,
        1,
        font = "5x7",
        color = category_color(cat),
        align = "right",
    )

    c.text(
        "WND",
        2,
        11,
        font = "4x5",
        color = "gray",
    )

    c.text(
        wind_text(m),
        23,
        10,
        font = "5x7",
        color = "white",
    )

    c.text(
        "VIS",
        91,
        11,
        font = "4x5",
        color = "gray",
    )

    c.text(
        visibility_text(m),
        111,
        10,
        font = "5x7",
        color = "white",
    )

    c.text(
        "CIG",
        2,
        20,
        font = "4x5",
        color = "gray",
    )

    c.text(
        ceiling_text(m),
        23,
        20,
        font = "4x5",
        color = "white",
    )

    c.text(
        "T/D",
        77,
        20,
        font = "4x5",
        color = "gray",
    )

    c.text(
        temp_dew_f_text(m),
        99,
        20,
        font = "4x5",
        color = "white",
    )

    c.text(
        "ALT",
        2,
        27,
        font = "4x5",
        color = "gray",
    )

    c.text(
        altimeter_text(m),
        23,
        27,
        font = "4x5",
        color = "white",
    )


# ------------------------------------------------------------
# Sustained + gust wind components
#
# Example:
#
# FAV 18
# HW 7/13
# XW 1/3
#
# If no gust:
#
# HW 7KT
# XW 1KT
# ------------------------------------------------------------

def draw_components(c, m, fav, x):
    speed = safe(m, "wspd", None)
    gust = safe(m, "wgst", None)

    if speed == None:
        return

    steady = wind_components(
        int(speed),
        fav["angle"],
    )

    c.text(
        "FAV " + fav["name"],
        x,
        11,
        font = "4x5",
        color = "green",
    )

    if gust != None and int(gust) > int(speed):
        gust_comp = wind_components(
            int(gust),
            fav["angle"],
        )

        hw_text = (
            "HW "
            + str(steady["head"])
            + "/"
            + str(gust_comp["head"])
        )

        xw_text = (
            "XW "
            + str(steady["cross"])
            + "/"
            + str(gust_comp["cross"])
        )

    else:
        hw_text = "HW " + str(steady["head"]) + "KT"
        xw_text = "XW " + str(steady["cross"]) + "KT"

    c.text(
        hw_text,
        x,
        19,
        font = "4x5",
        color = "white",
    )

    c.text(
        xw_text,
        x,
        26,
        font = "4x5",
        color = "white",
    )


# ------------------------------------------------------------
# KTKI RUNWAY
#
# Current published true bearings:
# RWY 18 = 182 true
# RWY 36 = 002 true
#
# METAR wind is true, so use true runway bearings.
# ------------------------------------------------------------

def draw_ktki_runway(c, m):
    direction = safe(m, "wdir", None)
    speed = safe(m, "wspd", None)

    c.text(
        "KTKI",
        2,
        1,
        font = "5x7",
        color = "white",
    )

    c.text(
        wind_text(m),
        126,
        1,
        font = "5x7",
        color = "white",
        align = "right",
    )

    fav = None

    if direction != None and speed != None and int(speed) > 0:
        fav = favored_runway(
            float(direction),
            182.0,
            "18",
            2.0,
            "36",
        )

    color36 = "gray"
    color18 = "gray"

    if fav != None:
        if fav["name"] == "36":
            color36 = "green"
        else:
            color18 = "green"

    # Slight 2-degree east-of-north orientation.
    # At 32px resolution this is essentially vertical.
    c.line(43, 10, 43, 29, "gray")
    c.line(49, 10, 49, 29, "gray")

    c.line(46, 11, 46, 14, "white")
    c.line(46, 17, 46, 20, "white")
    c.line(46, 23, 46, 26, "white")

    c.text(
        "36",
        31,
        9,
        font = "4x5",
        color = color36,
    )

    c.text(
        "18",
        51,
        26,
        font = "4x5",
        color = color18,
    )

    if fav == None:
        c.text(
            "FAV --",
            72,
            12,
            font = "4x5",
            color = "gray",
        )

        c.text(
            "CALM/VRB",
            72,
            21,
            font = "4x5",
            color = "white",
        )

        return

    draw_components(
        c,
        m,
        fav,
        72,
    )


# ------------------------------------------------------------
# KADS RUNWAY
#
# Current published true bearings:
# RWY 16 = 160 true
# RWY 34 = 340 true
#
# North = top.
# ------------------------------------------------------------

def draw_kads_runway(c, m):
    direction = safe(m, "wdir", None)
    speed = safe(m, "wspd", None)

    c.text(
        "KADS",
        2,
        1,
        font = "5x7",
        color = "white",
    )

    c.text(
        wind_text(m),
        126,
        1,
        font = "5x7",
        color = "white",
        align = "right",
    )

    fav = None

    if direction != None and speed != None and int(speed) > 0:
        fav = favored_runway(
            float(direction),
            160.0,
            "16",
            340.0,
            "34",
        )

    color34 = "gray"
    color16 = "gray"

    if fav != None:
        if fav["name"] == "34":
            color34 = "green"
        else:
            color16 = "green"

    # 340/160 true orientation
    c.line(38, 9, 45, 29, "gray")
    c.line(44, 7, 51, 27, "gray")

    c.line(42, 10, 43, 13, "white")
    c.line(44, 16, 45, 19, "white")
    c.line(46, 22, 47, 25, "white")

    c.text(
        "34",
        25,
        7,
        font = "4x5",
        color = color34,
    )

    c.text(
        "16",
        52,
        26,
        font = "4x5",
        color = color16,
    )

    if fav == None:
        c.text(
            "FAV --",
            75,
            12,
            font = "4x5",
            color = "gray",
        )

        c.text(
            "CALM/VRB",
            75,
            21,
            font = "4x5",
            color = "white",
        )

        return

    draw_components(
        c,
        m,
        fav,
        75,
    )


# ------------------------------------------------------------
# Runway page
# ------------------------------------------------------------

def runway_page(c, ctx, airport):
    c.fill("black")

    data = read_metars(ctx)
    m = data[airport]

    if data["state"] == "offline" or m == None:
        c.text(
            airport,
            2,
            1,
            font = "5x7",
            color = "white",
        )

        c.text_center(
            "NO WIND DATA",
            14,
            font = "5x7",
            color = "red",
        )

        return

    if airport == "KTKI":
        draw_ktki_runway(c, m)
    else:
        draw_kads_runway(c, m)


# ------------------------------------------------------------
# SR22T PIXEL ART
#
# Tiny blue/white side-profile airplane.
# Designed specifically for 128x32.
# ------------------------------------------------------------

def draw_sr22t(c):
    blue = "#008CFF"
    white = "white"
    dark = "#333333"

    # Tail / vertical stabilizer
    c.line(3, 10, 3, 22, blue)
    c.line(4, 11, 7, 16, blue)
    c.line(5, 12, 8, 16, blue)

    # Upper fuselage
    c.line(6, 16, 31, 16, blue)
    c.line(8, 15, 28, 15, blue)

    # Lower white fuselage
    c.line(5, 17, 34, 17, white)
    c.line(8, 18, 31, 18, white)

    # Nose
    c.line(31, 15, 36, 16, blue)
    c.line(31, 18, 36, 17, white)

    # Cockpit / cabin
    c.line(15, 13, 24, 13, blue)
    c.line(13, 14, 26, 14, blue)

    c.line(16, 14, 22, 14, dark)
    c.line(17, 13, 21, 13, dark)

    # Low wing
    c.line(16, 18, 26, 22, white)
    c.line(17, 18, 29, 21, blue)

    # Horizontal tail
    c.line(2, 17, 10, 17, white)

    # Nose / prop
    c.line(36, 13, 36, 20, "gray")
    c.line(35, 16, 38, 16, "gray")

    # Wheels
    c.line(14, 19, 14, 22, "gray")
    c.line(29, 18, 29, 22, "gray")

    c.line(12, 22, 16, 22, white)
    c.line(27, 22, 31, 22, white)


# ============================================================
# PAGES
# ============================================================

def main(c, ctx):
    c.fill("black")

    # Tiny blue/white SR22T
    draw_sr22t(c)

    # Title shifted right to make room for aircraft
    c.text(
        "PILOT BOARD",
        44,
        5,
        font = "6x8",
        color = "green",
    )

    c.line(
        44,
        15,
        123,
        15,
        "gray",
    )

    c.text(
        "KTKI  •  KADS",
        51,
        20,
        font = "5x7",
        color = "white",
    )


def ktki_wx(c, ctx):
    weather_page(
        c,
        ctx,
        "KTKI",
    )


def ktki_rwy(c, ctx):
    runway_page(
        c,
        ctx,
        "KTKI",
    )


def kads_wx(c, ctx):
    weather_page(
        c,
        ctx,
        "KADS",
    )


def kads_rwy(c, ctx):
    runway_page(
        c,
        ctx,
        "KADS",
    )