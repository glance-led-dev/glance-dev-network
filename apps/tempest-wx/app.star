# Tempest Weather — 64x32
#
#   now      temperature hero, dew point + pressure column, rainfall, wind
#   outlook  conditions now / +6h / tomorrow
#   alerts   active NWS watches, warnings and advisories, or an all-clear
#
# Three cached GETs per render. Every page reads the same cached responses,
# so the panel hits the network once per ttl window, not once per page.

WF_STATIONS = "https://swd.weatherflow.com/swd/rest/stations"
WF_FORECAST = "https://swd.weatherflow.com/swd/rest/better_forecast"
WF_DEVICE   = "https://swd.weatherflow.com/swd/rest/observations/device/"
NWS_ALERTS  = "https://api.weather.gov/alerts/active"

# The National Weather Service asks every caller to identify its application.
# This names the app, not the person running it - no user data goes to NWS
# beyond the coordinates being queried.
NWS_UA = "(glance-tempest-wx, https://glance-led.dev)"

# ---------------------------------------------------------------- palette

GRAY    = "gray"
MIDGRAY = "midgray"
DARK    = "darkgray"
WHITE   = "white"
ORANGE  = "orange"
CYAN    = "cyan"
SKY     = "skyblue"
GREEN   = "green"
RED     = "red"
YELLOW  = "yellow"
BLUE    = "blue"
BLACK   = "black"

HEXD = "0123456789abcdef"

def hx(v):
    v = int(v)
    if v < 0:
        v = 0
    if v > 255:
        v = 255
    return HEXD[v // 16] + HEXD[v % 16]

def mix(a, b, t):
    """Blend two "#rrggbb" strings. t runs 0.0 -> a, 1.0 -> b."""
    ar = int(a[1:3], 16)
    ag = int(a[3:5], 16)
    ab = int(a[5:7], 16)
    br = int(b[1:3], 16)
    bg = int(b[3:5], 16)
    bb = int(b[5:7], 16)
    return "#" + hx(ar + (br - ar) * t) + hx(ag + (bg - ag) * t) + hx(ab + (bb - ab) * t)

# Continuous temperature ramp, -20F to 105F. Cool hues below freezing,
# warm above; the steps are close enough together that the colour reads
# as a gradient rather than a set of bands.
TEMP_STOPS = [
    (-20, "#3c00b4"), (0, "#005aff"), (20, "#0096ff"), (32, "#00c8ff"),
    (45, "#00dcdc"), (55, "#00dc46"), (64, "#8cdc28"), (72, "#ffdc50"),
    (80, "#ffbf00"), (88, "#ff8c00"), (96, "#ff4600"), (105, "#ff0000"),
]

def temp_color(f):
    if f <= TEMP_STOPS[0][0]:
        return TEMP_STOPS[0][1]
    last = len(TEMP_STOPS) - 1
    if f >= TEMP_STOPS[last][0]:
        return TEMP_STOPS[last][1]
    for i in range(last):
        lo = TEMP_STOPS[i]
        hi = TEMP_STOPS[i + 1]
        if f >= lo[0] and f <= hi[0]:
            return mix(lo[1], hi[1], (f - lo[0]) / float(hi[0] - lo[0]))
    return WHITE

# Dew point reads in bands, not a gradient — the thresholds are the point.
def dew_color(f):
    if f < 40:
        return WHITE
    if f < 50:
        return GREEN
    if f < 60:
        return YELLOW
    if f < 70:
        return ORANGE
    return RED

def trend_color(t):
    if t == "rising":
        return GREEN
    if t == "falling":
        return SKY
    return GRAY

# ---------------------------------------------------------------- pixel art

DROP = """
..#..
.###.
.###.
#####
#####
.###.
"""

# The bundled fonts are ASCII, so a degree sign is drawn rather than typed.
DEG3 = "###\n#.#\n###"
DEG4 = ".##.\n#..#\n#..#\n.##."

def slack_gap(avail, used, gaps, base, cap):
    """Spread whatever room is left over the gaps, so a short row breathes
    instead of hugging the left edge. Returns the gap to use."""
    room = avail - used - base * gaps
    if room <= 0:
        return base
    extra = room // gaps
    if extra > cap:
        extra = cap
    return base + extra

def deg_w(ring):
    return 4 if ring == DEG4 else 3

def temp_left(c, x, y, s, font, col, ring):
    """Number plus its degree ring, left-aligned. Returns the width used."""
    c.text(s, x, y, font = font, color = col)
    w = c.text_width(s, font)
    c.sprite(ring, x + w + 1, y, color = col)
    return w + 1 + deg_w(ring)

def temp_right(c, x1, y, s, font, col, ring):
    w = c.text_width(s, font)
    x0 = x1 - (w + 1 + deg_w(ring)) + 1
    c.text(s, x0, y, font = font, color = col)
    c.sprite(ring, x0 + w + 1, y, color = col)

def temp_mid(c, x0b, x1b, y, s, font, col, ring):
    """Centred inside a column, and kept inside it: drops a font size before
    it would spill, then clamps. A 21px column is unforgiving."""
    span = x1b - x0b + 1
    f = font
    if c.text_width(s, f) + 1 + deg_w(ring) > span:
        f = "4x5"
    w = c.text_width(s, f)
    total = w + 1 + deg_w(ring)
    x = x0b + (span - total) // 2
    if x < x0b:
        x = x0b
    c.text(s, x, y, font = f, color = col)
    c.sprite(ring, x + w + 1, y, color = col)

def mid_fit(c, x0b, x1b, y, s, font, col):
    """Plain centred text, held inside a column the same way."""
    span = x1b - x0b + 1
    f = font
    if c.text_width(s, f) > span and f != "4x5":
        f = "4x5"
    t = clamp(c, s, span, f)
    x = x0b + (span - c.text_width(t, f)) // 2
    c.text(t, x, y, font = f, color = col)

def center_fit(c, s, y, font, col):
    """Never let a fixed caption outgrow the panel - it clips silently."""
    c.text_center(clamp(c, s, c.width, font), y, font = font, color = col)

UP5   = "..#..\n.###.\n#####\n..#..\n..#.."
DOWN5 = "..#..\n..#..\n#####\n.###.\n..#.."
FLAT5 = ".....\n#####\n.....\n#####\n....."

def trend_arrow5(t):
    """None means "not known" - the caller draws nothing rather than
    claiming the reading is steady."""
    if t == "rising":
        return UP5
    if t == "falling":
        return DOWN5
    if t == "steady":
        return FLAT5
    return None

# Eight 7x7 wind arrows. Diagonals are a solid triangular head with a
# diagonal shaft; at seven pixels a hollow head just reads as noise.
A_N  = "...#...\n..###..\n.#####.\n#######\n...#...\n...#...\n...#..."
A_S  = "...#...\n...#...\n...#...\n#######\n.#####.\n..###..\n...#..."
A_E  = "...#...\n....#..\n.....#.\n#######\n.....#.\n....#..\n...#..."
A_W  = "...#...\n..#....\n.#.....\n#######\n.#.....\n..#....\n...#..."
A_NE = "..#####\n...####\n....###\n...#.##\n..#...#\n.#.....\n#......"
A_NW = "#####..\n####...\n###....\n##.#...\n#...#..\n.....#.\n......#"
A_SE = "#......\n.#.....\n..#...#\n...#.##\n....###\n...####\n..#####"
A_SW = "......#\n.....#.\n#...#..\n##.#...\n###....\n####...\n#####.."

ARROWS = {"N": A_N, "NE": A_NE, "E": A_E, "SE": A_SE,
          "S": A_S, "SW": A_SW, "W": A_W, "NW": A_NW}

OPPOSITE = {"N": "S", "NE": "SW", "E": "W", "SE": "NW",
            "S": "N", "SW": "NE", "W": "E", "NW": "SE"}

TO_EIGHT = {"N": "N", "NNE": "NE", "NE": "NE", "ENE": "NE",
            "E": "E", "ESE": "SE", "SE": "SE", "SSE": "SE",
            "S": "S", "SSW": "SW", "SW": "SW", "WSW": "SW",
            "W": "W", "WNW": "NW", "NW": "NW", "NNW": "NW"}

def wind_arrow(cardinal, mode):
    eight = TO_EIGHT.get(cardinal.upper(), "N")
    if mode == "to":
        eight = OPPOSITE[eight]
    return ARROWS[eight]

# 12x12 condition icons. Legend: A amber, Y yellow, W white, G grey, B blue.
ICON_LEGEND = {"A": "amber", "Y": "yellow", "W": "white", "G": "gray", "B": "skyblue"}

I_SUN = """
......YY....
.Y...YY...Y.
..Y..YY..Y..
....AAAA....
...AAAAAA...
YY.AAAAAA.YY
YY.AAAAAA.YY
...AAAAAA...
....AAAA....
..Y..YY..Y..
.Y...YY...Y.
......YY....
"""

I_MOON = """
....WWWW....
..WW....WW..
.WW.......W.
.W..........
WW..........
WW..........
WW..........
WW..........
.W..........
.WW.......W.
..WW....WW..
....WWWW....
"""

I_CLOUD = """
............
............
....GGGG....
...GGGGGG...
.GGGGGGGGG..
GGGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
............
............
............
"""

I_PCDAY = """
............
..AA........
.AAAA.......
.AAAA..GGG..
..AA..GGGGG.
.....GGGGGGG
....GGGGGGGG
....GGGGGGG.
............
............
............
............
"""

I_PCNIGHT = """
............
..WW........
.W..W.......
.W.....GGG..
.W....GGGGG.
..WW.GGGGGGG
....GGGGGGGG
....GGGGGGG.
............
............
............
............
"""

I_RAIN = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
..B...B...B.
..B...B...B.
............
.B...B...B..
.B...B...B..
............
"""

I_SNOW = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
.W...W...W..
............
...W...W...W
............
.W...W...W..
............
"""

I_SLEET = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
.W...B...W..
............
...B...W...B
............
.W...B...W..
............
"""

I_STORM = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
......YY....
.....YY.....
....YY......
...YYYYY....
.....YY.....
....YY......
"""

I_FOG = """
............
............
..GGGGGGGG..
............
.GGGGGGGGGG.
............
GGGGGGGGGGGG
............
.GGGGGGGGGG.
............
..GGGGGGGG..
............
"""

I_WINDY = """
............
............
..WWWWWWW...
.W.......W..
.........W..
..WWWWWWW...
.W........W.
..........W.
...WWWWW....
............
............
............
"""

I_CH_RAIN = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
....B...B...
....B...B...
............
............
............
............
"""

I_CH_SNOW = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
....W...W...
............
......W.....
............
............
............
"""

I_CH_SLEET = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
....B...W...
....B.......
............
............
............
............
"""

I_CH_STORM = """
....GGGG....
..GGGGGGGG..
.GGGGGGGGGG.
GGGGGGGGGGGG
.GGGGGGGGGG.
............
......YY....
.....YY.....
....YYYY....
......YY....
............
............
"""

ICONS = {
    "clear-day": I_SUN, "clear-night": I_MOON, "cloudy": I_CLOUD,
    "partly-cloudy-day": I_PCDAY, "partly-cloudy-night": I_PCNIGHT,
    "rainy": I_RAIN, "snow": I_SNOW, "sleet": I_SLEET, "thunderstorm": I_STORM,
    # "possibly-" is a forecast chance, not an observation - drawn lighter so
    # the panel never shows falling rain beside a dull "not raining" drop
    "possibly-rainy-day": I_CH_RAIN, "possibly-rainy-night": I_CH_RAIN,
    "possibly-snow-day": I_CH_SNOW, "possibly-snow-night": I_CH_SNOW,
    "possibly-sleet-day": I_CH_SLEET, "possibly-sleet-night": I_CH_SLEET,
    "possibly-thunderstorm-day": I_CH_STORM, "possibly-thunderstorm-night": I_CH_STORM,
    "foggy": I_FOG, "windy": I_WINDY,
}

def icon_for(name):
    return ICONS.get(name, I_CLOUD)

# ---------------------------------------------------------------- data

def num(v, fallback):
    """.get(k, d) only covers a missing key; the API can also send null."""
    if v == None:
        return fallback
    return v

def txt(v, fallback):
    if v == None or v == "":
        return fallback
    return v

WS = " \t\r\n"

def trim(s):
    """An unset input arrives as None, not "". A pasted token arrives with
    a newline on the end. Both used to take the whole app down."""
    if s == None:
        return ""
    out = s
    for i in range(len(out)):
        if len(out) > 0 and out[0] in WS:
            out = out[1:]
        else:
            break
    for i in range(len(out)):
        if len(out) > 0 and out[len(out) - 1] in WS:
            out = out[0:len(out) - 1]
        else:
            break
    return out

def choice_of(ctx, key, fallback):
    """Same hazard on the dropdowns: unset reads as None, not as the default."""
    v = ctx.inputs.get(key, fallback)
    if v == None or v == "":
        return fallback
    return trim(v)

def num(v, fallback):
    """.get(k, d) only covers a missing key; the API can also send null."""
    if v == None:
        return fallback
    return v

def txt(v, fallback):
    if v == None or v == "":
        return fallback
    return v

def cache_key(unix, bucket):
    """Round the clock so a changing timestamp doesn't defeat the http cache."""
    return (unix // bucket) * bucket

def approx_dew_c(temp_c, rh):
    """Magnus without logarithms. Accurate to about a degree above 50% RH,
    and both ends of the comparison use it, so the sign of the change holds."""
    return temp_c - (100.0 - rh) / 5.0

def pick_device(devices):
    """Prefer a Tempest; fall back to an Air, which still carries the
    temperature and humidity the dew point trend needs."""
    for want in ["ST", "AR"]:
        for dv in devices:
            if dv.get("device_type", "") == want:
                return (str(dv.get("device_id", "")), want)
    return ("", "")

def token_of(ctx):
    return trim(ctx.inputs.get("apikey", ""))

def fetch_station(ctx):
    """One lookup gives the station's coordinates, its name and its devices,
    so the user never has to find a device id or type in latitude.
    Always returns a dict; "err" is empty only when everything worked."""
    token = token_of(ctx)
    if token == "":
        return {"err": "NO TOKEN"}

    resp = http.get(WF_STATIONS, params = {"token": token}, ttl_seconds = 21600)
    if resp["status_code"] == 0:
        return {"err": "NO REPLY"}
    if resp["status_code"] == 401 or resp["status_code"] == 403:
        return {"err": "BAD TOKEN"}
    if resp["status_code"] != 200:
        return {"err": "STATIONS " + str(resp["status_code"])}
    if resp["json"] == None:
        return {"err": "BAD REPLY"}

    stations = resp["json"].get("stations", None)
    if stations == None or len(stations) == 0:
        return {"err": "NO STATIONS"}

    want = trim(ctx.inputs.get("station", ""))
    chosen = stations[0]
    if want != "":
        for st in stations:
            if str(st.get("station_id", "")) == want:
                chosen = st

    device, dtype = pick_device(chosen.get("devices", []))
    return {
        "err": "",
        "id": str(chosen.get("station_id", "")),
        "lat": num(chosen.get("latitude", None), None),
        "lon": num(chosen.get("longitude", None), None),
        "name": txt(chosen.get("public_name", ""), txt(chosen.get("name", ""), "STATION")),
        "device": device,
        "dtype": dtype,
    }

def fetch_current(ctx, station):
    resp = http.get(WF_FORECAST, params = {
        "station_id": station["id"],
        "token": token_of(ctx),
        "units_temp": "f",
        "units_wind": "mph",
        "units_precip": "in",
        "units_pressure": "mb",
    }, ttl_seconds = 120)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    return resp["json"]

def fetch_history(ctx, station, ref):
    """Three hours of raw observations ending at the station's own last
    reading. Anchored to `ref` - the observation timestamp - rather than to
    the renderer's clock, so two renders of the same data agree."""
    if station["device"] == "":
        return (None, "")
    t = cache_key(ref, 300)
    resp = http.get(WF_DEVICE + station["device"], params = {
        "token": token_of(ctx),
        "time_start": str(t - 10800),
        "time_end": str(t),
    }, ttl_seconds = 300)
    if resp["status_code"] != 200 or resp["json"] == None:
        return (None, "")
    return (resp["json"].get("obs", None), resp["json"].get("type", ""))

# Tempest and Air log different columns. Only these three matter here.
OBS_COLS = {
    "obs_st": {"temp": 7, "rh": 8, "rain": 12},
    "obs_air": {"temp": 2, "rh": 3, "rain": -1},
}

def avg_dew_c(obs, cols, start, count):
    """Mean dew point and mean timestamp across a run of readings. One
    sample is noise; ten is a measurement. Returns None if nothing usable."""
    ti = cols["temp"]
    hi = cols["rh"]
    total = 0.0
    tstamp = 0.0
    n = 0
    for i in range(start, start + count):
        if i < 0 or i >= len(obs):
            continue
        row = obs[i]
        if len(row) <= hi:
            continue
        if row[ti] == None or row[hi] == None or row[0] == None:
            continue
        total = total + approx_dew_c(row[ti], row[hi])
        tstamp = tstamp + row[0]
        n = n + 1
    if n == 0:
        return None
    return [total / n, tstamp / n]

def dew_trend(obs, otype):
    """rising / falling / steady over three hours, from the station's own log.

    Averaged at both ends rather than sampled once, because a single
    reading either side made the arrow flip between renders. The deadband
    is 1.5F: a trend that oscillates is worse than no trend at all."""
    cols = OBS_COLS.get(otype, None)
    if cols == None or obs == None or len(obs) < 20:
        return "unknown"

    a = avg_dew_c(obs, cols, 0, 10)
    b = avg_dew_c(obs, cols, len(obs) - 10, 10)
    if a == None or b == None:
        return "unknown"

    # A RATE, not a total. Comparing totals meant a window that happened to
    # be shorter carried less change and could flip the arrow; degrees per
    # hour is the same number however much log came back.
    hours = (b[1] - a[1]) / 3600.0
    if hours < 1.0:
        return "unknown"
    rate = ((b[0] - a[0]) * 1.8) / hours

    if rate > 0.7:
        return "rising"
    if rate < -0.7:
        return "falling"
    return "steady"

# Precipitation icons that mean it is falling NOW. The "possibly-" variants
# are a forecast chance, not an observation, so they are deliberately absent.
FALLING = ["rainy", "snow", "sleet", "thunderstorm"]

def raining_now(icon):
    """Deliberately reads only the condition icon, never the rain gauge.

    The gauge is the more precise signal, but it comes from the device-history
    call, and a render that has not got that call back yet would disagree with
    one that has - the drop flipped bright/dull between two frames of the same
    moment. The icon arrives with the reading that draws the rest of the page,
    so every render sees the same answer."""
    return icon in FALLING

def read_station(ctx):
    station = fetch_station(ctx)
    if station["err"] != "":
        return {"err": station["err"]}

    data = fetch_current(ctx, station)
    if data == None:
        return {"err": "NO FORECAST"}

    cur = data.get("current_conditions", None)
    if cur == None:
        return {"err": "NO READINGS"}

    # the station's own observation time is the app's clock throughout
    ref = int(num(cur.get("time", None), ctx.now.unix))
    obs, otype = fetch_history(ctx, station, ref)
    icon = txt(cur.get("icon", "cloudy"), "cloudy")

    out = {
        "err": "",
        "ref": ref,
        "station": station,
        "temp": num(cur.get("air_temperature", 0), 0),
        "dew": num(cur.get("dew_point", 0), 0),
        "dew_trend": dew_trend(obs, otype),
        "rain": num(cur.get("precip_accum_local_day", 0), 0),
        "rain_y": num(cur.get("precip_accum_local_yesterday", 0), 0),
        "raining": raining_now(icon),
        "wind": num(cur.get("wind_avg", 0), 0),
        "gust": num(cur.get("wind_gust", 0), 0),
        "card": txt(cur.get("wind_direction_cardinal", "N"), "N"),
        "mb": num(cur.get("sea_level_pressure", 0), 0),
        "trend": txt(cur.get("pressure_trend", "steady"), "steady"),
        "icon": icon,
        "pp": num(cur.get("precip_probability", 0), 0),
    }

    # yesterday settles overnight once rain check has run; prefer the final
    fin = cur.get("precip_accum_local_yesterday_final", None)
    if fin != None and fin >= 0:
        out["rain_y"] = fin

    fc = data.get("forecast", {})
    out["hourly"] = fc.get("hourly", [])
    out["daily"] = fc.get("daily", [])
    return out

# ---------------------------------------------------------------- helpers

# The API is always asked for F / mph / in / mb, and everything is converted
# on the way to the panel. That keeps ONE source of truth for the colour
# rules: they are defined in Fahrenheit, so a Celsius reader still sees a
# muggy dew point turn orange at the same real-world humidity.
def to_c(f):
    return (f - 32.0) / 1.8

def to_mm(inches):
    return inches * 25.4

def to_kph(mph):
    return mph * 1.60934

def to_inhg(mb):
    return mb * 0.02953

def is_metric(ctx):
    return choice_of(ctx, "units", "imperial") == "metric"

def temp_str(f, metric):
    return f2s(to_c(f) if metric else f)

def fixed(v, places):
    """Starlark's % operator has no precision flag - only %s, %r, %d and %%.
    Decimals therefore get assembled by hand, rounding half up."""
    neg = v < 0
    if neg:
        v = -v
    scale = 1
    for i in range(places):
        scale = scale * 10
    n = int(v * scale + 0.5)
    whole = n // scale
    frac = n % scale
    out = str(whole)
    if places > 0:
        fs = str(frac)
        for i in range(places - len(fs)):
            fs = "0" + fs
        out = out + "." + fs
    if neg and n > 0:
        out = "-" + out
    return out

def rain_str(inches, metric):
    if metric:
        return fixed(to_mm(inches), 1)
    return fixed(inches, 2)

def rain_unit(metric):
    return "MM" if metric else "IN"

def wind_str(mph, metric):
    return f2s(to_kph(mph) if metric else mph)

def wind_unit(metric):
    return "KPH" if metric else "MPH"

def baro_str(mb, mode):
    if mode == "inhg":
        return fixed(to_inhg(mb), 2)
    return f2s(mb)

def f2s(v):
    return str(int(v + 0.5)) if v >= 0 else str(-int(-v + 0.5))

def hour12(h):
    suffix = "AM" if h < 12 else "PM"
    x = h % 12
    if x == 0:
        x = 12
    return str(x) + suffix

DOW = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

def dow_from_epoch(e):
    # 1 Jan 1970 was a Thursday; day_start_local is local midnight expressed
    # as UTC, which for every US offset still lands on the right UTC date.
    return DOW[((e // 86400) + 4) % 7]

def pick_hour(hourly, unix, hours):
    """The forecast entry nearest `hours` out.

    Two deliberate choices here. The target is anchored to the top of the
    current hour, so every render inside the same hour resolves to the same
    entry and the label cannot drift between frames. And it picks the
    NEAREST entry rather than the first one past the target, so the result
    does not depend on the array arriving in chronological order."""
    if hourly == None or len(hourly) == 0:
        return None
    target = ((unix // 3600) * 3600) + hours * 3600
    best = None
    best_gap = -1
    for h in hourly:
        t = h.get("time", None)
        if t == None:
            continue
        gap = t - target
        if gap < 0:
            gap = -gap
        if best_gap < 0 or gap < best_gap:
            best_gap = gap
            best = h
    return best

def clamp(c, s, maxw, font):
    """Never hand the renderer a string wider than the space it has; it
    clips silently, which looks like a bug rather than a truncation."""
    if c.text_width(s, font) <= maxw:
        return s
    for i in range(len(s)):
        cut = s[0:len(s) - i - 1]
        if c.text_width(cut, font) <= maxw:
            return cut
    return ""

# The hint line is 58px wide - fourteen characters in 4x5. Anything longer
# gets clamped, so every one of these is written to fit.
# Measured against a real panel render, not against my own font metrics:
# eleven characters is what reliably fits this line.
FIXES = {
    "NO TOKEN":    "ADD TOKEN",
    "BAD TOKEN":   "WRONG OR OLD",
    "NO REPLY":    "NO INTERNET",
    "BAD REPLY":   "TRY AGAIN",
    "NO STATIONS": "NONE ON KEY",
    "NO FORECAST": "CHECK ID",
    "NO READINGS": "IS IT ON?",
}

def fix_for(err):
    return FIXES.get(err, "CHECK TOKEN")

def nodata(c, what, fix):
    c.vline(0, 0, 32, RED)
    c.vline(1, 0, 32, color.dim(RED, 40))
    c.text("NO DATA", 5, 6, font = "5x7", color = RED)
    c.text(clamp(c, what, 58, "4x5"), 5, 16, font = "4x5", color = GRAY)
    c.text(clamp(c, fix, 58, "4x5"), 5, 23, font = "4x5", color = MIDGRAY)

def badge(c):
    c.rect(41, 26, 63, 31, fill = "amber")
    c.text("DEMO", 52, 27, font = "4x5", color = BLACK, align = "center")

def demo_now(c, metric, baro):
    """Sample numbers, plainly labelled, so an unconfigured panel still
    shows what the app does instead of sitting blank."""
    temp_left(c, 0, 0, temp_str(68, metric), "10x16", temp_color(68), DEG4)
    c.vline(31, 0, 15, MIDGRAY)
    c.sprite(UP5, 33, 1, color = dew_color(52))
    c.text("DP", 39, 1, font = "4x5", color = GRAY)
    temp_right(c, 63, 1, temp_str(52, metric), "4x5", dew_color(52), DEG3)
    c.sprite(FLAT5, 33, 9, color = GRAY)
    c.text(baro_str(1016, baro), 63, 9, font = "4x5", color = WHITE, align = "right")
    c.sprite(DROP, 0, 16, color = color.dim(SKY, 55))
    sample = rain_str(0, metric)
    c.text(sample, 7, 17, font = "4x5", color = color.dim(SKY, 42))
    c.text("Y", 30, 17, font = "4x5", color = MIDGRAY)
    c.text(sample, 35, 17, font = "4x5", color = GRAY)
    runit = rain_unit(metric)
    c.text(runit, 35 + c.text_width(sample, "4x5") + 3, 17, font = "4x5", color = MIDGRAY)
    badge(c)

def demo_outlook(c, metric, hours):
    icons = [I_PCDAY, I_CLOUD, I_SUN]
    temps = [68, 64, 74]
    labs = ["NOW", "+" + str(hours) + "H", "THU"]
    c.vline(21, 2, 28, DARK)
    c.vline(43, 2, 28, DARK)
    for i in range(3):
        mid = col_mid(i)
        mid_fit(c, COLS[i][0], COLS[i][1], 0, labs[i], "4x5", GRAY)
        c.sprite(icons[i], mid - 5, 6, color = WHITE, legend = ICON_LEGEND)
        temp_mid(c, COLS[i][0], COLS[i][1], 18, temp_str(temps[i], metric), "5x7",
                 temp_color(temps[i]), DEG3)
    badge(c)

def demo_alerts(c):
    c.vline(0, 0, 32, "amber")
    c.vline(1, 0, 32, color.dim("amber", 35))
    center_fit(c, "ADD YOUR", 4, "5x7", "amber")
    center_fit(c, "TEMPEST TOKEN", 14, "4x5", GRAY)
    center_fit(c, "IN SETTINGS", 21, "4x5", MIDGRAY)

# ---------------------------------------------------------------- page: now

def now(c, ctx):
    c.clear()
    if token_of(ctx) == "":
        demo_now(c, is_metric(ctx), choice_of(ctx, "baro", "mb"))
        return
    d = read_station(ctx)
    if d["err"] != "":
        nodata(c, d["err"], fix_for(d["err"]))
        return

    rail_x = 31
    metric = is_metric(ctx)

    # temperature hero. 10x16 nearly always; the ladder only drops to 7x16
    # when a minus sign or a third digit arrives. Colour comes from the
    # Fahrenheit value whatever the panel is displaying.
    tstr = temp_str(d["temp"], metric)
    tfont = "10x16"
    if c.text_width(tstr, "10x16") + 1 + deg_w(DEG4) > rail_x:
        tfont = "7x16"
    temp_left(c, 0, 0, tstr, tfont, temp_color(d["temp"]), DEG4)
    c.vline(rail_x, 0, 15, MIDGRAY)

    # dew point over pressure, arrows in a column, values right-aligned
    dc = dew_color(d["dew"])
    dew_arrow = trend_arrow5(d["dew_trend"])
    if dew_arrow != None:
        c.sprite(dew_arrow, 33, 1, color = dc)
    c.text("DP", 39, 1, font = "4x5", color = GRAY)
    temp_right(c, 63, 1, temp_str(d["dew"], metric), "4x5", dc, DEG3)

    baro_arrow = trend_arrow5(d["trend"])
    if baro_arrow != None:
        c.sprite(baro_arrow, 33, 9, color = trend_color(d["trend"]))
    c.text(baro_str(d["mb"], choice_of(ctx, "baro", "mb")), 63, 9,
           font = "4x5", color = WHITE, align = "right")

    # rainfall today then yesterday. The drop is bright while it is actually
    # coming down, dull otherwise.
    rain_c = SKY if d["rain"] > 0 else color.dim(SKY, 42)
    c.sprite(DROP, 0, 16, color = SKY if d["raining"] else color.dim(SKY, 55))

    today = rain_str(d["rain"], metric)
    yest = rain_str(d["rain_y"], metric)
    runit = rain_unit(metric)
    w_today = c.text_width(today, "4x5")
    w_y = c.text_width("Y", "4x5")
    w_yest = c.text_width(yest, "4x5")
    w_runit = c.text_width(runit, "4x5")

    # Measured against the real font, then shed from the least important
    # end: the unit first, then yesterday. Today's total always survives.
    x0 = 7
    show_yest = True
    show_runit = True
    parts = 0
    n_gaps = 0

    for attempt in range(3):
        parts = w_today
        n_gaps = 0
        if show_yest:
            parts = parts + w_y + w_yest
            n_gaps = n_gaps + 2
        if show_runit:
            parts = parts + w_runit
            n_gaps = n_gaps + 1
        if x0 + parts + n_gaps * 3 <= 64:
            break
        if show_runit:
            show_runit = False
        elif show_yest:
            show_yest = False

    gap = 3
    if n_gaps > 0:
        gap = slack_gap(64 - x0, parts, n_gaps, 3, 3)

    x = x0
    c.text(today, x, 17, font = "4x5", color = rain_c)
    x = x + w_today
    if show_yest:
        x = x + gap
        c.text("Y", x, 17, font = "4x5", color = MIDGRAY)
        x = x + w_y + gap
        c.text(yest, x, 17, font = "4x5", color = GRAY)
        x = x + w_yest
    if show_runit:
        c.text(runit, x + gap, 17, font = "4x5", color = MIDGRAY)

    # wind: direction, speed, gust, one shared unit.
    # Measured before drawing, because three-digit speeds do not fit: the
    # unit goes first, then the G, before anything would clip.
    # dead calm has no direction worth drawing and no gust worth labelling,
    # so the arrow is skipped too rather than pointing at nothing
    if d["wind"] < 0.5 and d["gust"] < 0.5:
        c.text("CALM", 8, 25, font = "4x5", color = GRAY)
        return

    c.sprite(wind_arrow(d["card"], choice_of(ctx, "arrow", "from")), 0, 24, color = CYAN)

    card = d["card"].upper()
    spd = wind_str(d["wind"], metric)
    gst = wind_str(d["gust"], metric)
    unit = wind_unit(metric)

    w_card = c.text_width(card, "4x5")
    w_spd = c.text_width(spd, "4x5")
    w_g = c.text_width("G", "4x5")
    w_gst = c.text_width(gst, "4x5")
    w_mph = c.text_width(unit, "4x5")

    # Shed from the least important end until it fits: the unit first, then
    # the G, then the gust. The gap count is counted, not assumed - guessing
    # it is what pushed MPH a pixel off the panel.
    avail = 64 - 8
    show_mph = True
    show_g = True
    show_gust = True
    parts = 0
    n_gaps = 1

    for attempt in range(4):
        parts = w_card + w_spd
        n_gaps = 1
        if show_gust:
            parts = parts + w_gst
            n_gaps = n_gaps + 1
            if show_g:
                parts = parts + w_g
                n_gaps = n_gaps + 1
        if show_mph:
            parts = parts + w_mph
            n_gaps = n_gaps + 1
        if parts + n_gaps * 3 <= avail:
            break
        if show_mph:
            show_mph = False
        elif show_g:
            show_g = False
        elif show_gust:
            show_gust = False

    gap = slack_gap(avail, parts, n_gaps, 3, 3)

    x = 8
    c.text(card, x, 25, font = "4x5", color = GRAY)
    x = x + w_card + gap
    c.text(spd, x, 25, font = "4x5", color = WHITE)
    x = x + w_spd + gap
    if show_gust:
        if show_g:
            c.text("G", x, 25, font = "4x5", color = GRAY)
            x = x + w_g + gap
        c.text(gst, x, 25, font = "4x5", color = ORANGE)
        x = x + w_gst + gap
    if show_mph:
        c.text(unit, x, 25, font = "4x5", color = GRAY)

# ------------------------------------------------------------ page: outlook

COLS = [(0, 20), (22, 42), (44, 63)]

def col_mid(i):
    return (COLS[i][0] + COLS[i][1]) // 2

def outlook(c, ctx):
    """Now, six hours out, and tomorrow."""
    hours = 6
    c.clear()
    if token_of(ctx) == "":
        demo_outlook(c, is_metric(ctx), hours)
        return
    d = read_station(ctx)
    if d["err"] != "":
        nodata(c, d["err"], fix_for(d["err"]))
        return

    nxt = pick_hour(d["hourly"], d["ref"], hours)
    tmr = d["daily"][1] if len(d["daily"]) > 1 else None

    labels = ["NOW", "+" + str(hours) + "H", "TMRW"]
    if nxt != None:
        labels[1] = hour12(int(num(nxt.get("local_hour", 0), 0)))
    if tmr != None:
        labels[2] = dow_from_epoch(int(num(tmr.get("day_start_local", d["ref"] + 86400),
                                           d["ref"] + 86400)))

    icons = [d["icon"],
             txt(nxt.get("icon", ""), "cloudy") if nxt != None else "cloudy",
             txt(tmr.get("icon", ""), "cloudy") if tmr != None else "cloudy"]
    probs = [d["pp"],
             num(nxt.get("precip_probability", 0), 0) if nxt != None else 0,
             num(tmr.get("precip_probability", 0), 0) if tmr != None else 0]
    temps = [d["temp"],
             num(nxt.get("air_temperature", None), d["temp"]) if nxt != None else d["temp"],
             num(tmr.get("air_temp_high", None), d["temp"]) if tmr != None else d["temp"]]

    c.vline(21, 2, 28, DARK)
    c.vline(43, 2, 28, DARK)

    for i in range(3):
        lo = COLS[i][0]
        hi = COLS[i][1]
        mid = col_mid(i)
        mid_fit(c, lo, hi, 0, labels[i], "4x5", GRAY)
        c.sprite(icon_for(icons[i]), mid - 5, 6, color = WHITE, legend = ICON_LEGEND)

        p = int(probs[i])
        pc = SKY if p >= 50 else (GRAY if p >= 20 else MIDGRAY)
        mid_fit(c, lo, hi, 19, str(p) + "%", "4x5", pc)

        temp_mid(c, lo, hi, 25, temp_str(temps[i], is_metric(ctx)), "5x7",
                 temp_color(temps[i]), DEG3)

# ------------------------------------------------------------- page: alerts

CLASSES = ["EMERGENCY", "WARNING", "WATCH", "ADVISORY", "STATEMENT"]

# NWS standard: warning red, watch yellow, advisory blue.
def alert_color(cls):
    if cls == "WARNING" or cls == "EMERGENCY":
        return RED
    if cls == "WATCH":
        return YELLOW
    if cls == "ADVISORY":
        return BLUE
    return GRAY

def on_fill(hexcolor):
    """Flip banner text to black once the fill gets bright."""
    if hexcolor == YELLOW:
        return BLACK
    return WHITE

def split_event(ev):
    """The last word of an NWS event name is always its class."""
    words = ev.upper().split(" ")
    words = [w for w in words if w != ""]
    if len(words) == 0:
        return ("ALERT", "")
    last = words[len(words) - 1]
    for cl in CLASSES:
        if last == cl:
            return (cl, " ".join(words[0:len(words) - 1]))
    return ("ALERT", " ".join(words))

ABBR = {
    "THUNDERSTORM": "TSTORM", "WEATHER": "WX", "COASTAL": "CSTL",
    "SPECIAL": "SPCL", "TEMPERATURE": "TEMP", "EXCESSIVE": "EXCESS",
}

def shorten(c, s, maxw, font):
    out = " ".join([ABBR.get(w, w) for w in s.split(" ")])
    if c.text_width(out, font) <= maxw:
        return out
    # trim a character at a time rather than guessing at an average width
    for i in range(len(out)):
        cut = out[0:len(out) - i - 1]
        if c.text_width(cut + ".", font) <= maxw:
            return cut + "."
    return ""

def wrap2(c, s, maxw, font):
    words = s.split(" ")
    lines = []
    cur = ""
    for w in words:
        if cur == "":
            cur = w
        elif c.text_width(cur + " " + w, font) <= maxw:
            cur = cur + " " + w
        else:
            lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    return lines[0:2]

def in_nws_area(lat, lon):
    """NWS only covers the US and its territories. Outside that the API
    answers with an empty list, which would read as a false all-clear."""
    if lat == None or lon == None:
        return False
    return lat >= 13.0 and lat <= 72.0 and lon >= -180.0 and lon <= -64.0

def fetch_alerts(ctx, station):
    if station == None or not in_nws_area(station.get("lat", None), station.get("lon", None)):
        return []
    point = str(station.get("lat", "")) + "," + str(station.get("lon", ""))
    resp = http.get(NWS_ALERTS, params = {"point": point}, headers = {
        "User-Agent": NWS_UA,
        "Accept": "application/geo+json",
    }, ttl_seconds = 180)
    if resp["status_code"] != 200 or resp["json"] == None:
        return []

    feats = resp["json"].get("features", None)
    if feats == None:
        return []

    found = []
    for f in feats:
        props = f.get("properties", None)
        if props == None:
            continue
        ev = props.get("event", "")
        if ev == "":
            continue
        cls, hazard = split_event(ev)
        found.append({"cls": cls, "hazard": hazard, "til": expiry(props.get("expires", ""))})

    # most urgent first, without needing a sort key function
    out = []
    for cl in CLASSES:
        for a in found:
            if a["cls"] == cl:
                out.append(a)
    for a in found:
        if a["cls"] not in CLASSES:
            out.append(a)
    return out

def all_digits(s):
    for ch in s.elems():
        if ch not in "0123456789":
            return False
    return len(s) > 0

def expiry(iso):
    """ISO 8601 local time from NWS, e.g. 2026-09-09T20:00:00-04:00."""
    if len(iso) < 16 or iso[10] != "T":
        return ""
    hh = iso[11:13]
    mm = iso[14:16]
    if not all_digits(hh) or not all_digits(mm):
        return ""
    h = int(hh)
    label = hour12(h)
    if mm == "00":
        return label
    return str(h % 12 if h % 12 != 0 else 12) + ":" + mm

def alerts(c, ctx):
    c.clear()
    if token_of(ctx) == "":
        demo_alerts(c)
        return

    station = fetch_station(ctx)
    if station["err"] != "":
        nodata(c, station["err"], fix_for(station["err"]))
        return

    # the place label defaults to the station's own name; the input overrides it
    town = clamp(c, trim(ctx.inputs.get("town", "")).upper(), 60, "4x5")
    if town == "":
        town = clamp(c, station["name"].upper(), 60, "4x5")

    live = fetch_alerts(ctx, station)

    if not in_nws_area(station.get("lat", None), station.get("lon", None)):
        c.vline(0, 0, 32, MIDGRAY)
        c.vline(1, 0, 32, color.dim(GRAY, 35))
        center_fit(c, "ALERTS", 3, "4x5", GRAY)
        center_fit(c, "US ONLY", 12, "5x7", GRAY)
        center_fit(c, town, 25, "4x5", MIDGRAY)
        return

    # ---- all-clear. A positive state, not an error screen.
    if len(live) == 0:
        c.vline(0, 0, 32, GREEN)
        c.vline(1, 0, 32, color.dim(GREEN, 35))
        center_fit(c, "NWS ALERTS", 3, "4x5", GRAY)
        center_fit(c, "NONE", 12, "5x7", GREEN)
        center_fit(c, town, 25, "4x5", MIDGRAY)
        return

    # ---- one alert: full-size banner
    if len(live) == 1:
        a = live[0]
        bg = alert_color(a["cls"])
        c.rect(0, 0, c.width - 1, 7, fill = bg)
        center_fit(c, a["cls"], 1, "5x7", on_fill(bg))

        lines = wrap2(c, a["hazard"], c.width, "5x7")
        if len(lines) > 0:
            center_fit(c, lines[0], 10, "5x7", WHITE)
        if len(lines) > 1:
            center_fit(c, lines[1], 18, "5x7", WHITE)
        if a["til"] != "":
            center_fit(c, "TIL " + a["til"], 26, "4x5", GRAY)
        return

    # ---- two or more: one colour-chipped row each, all visible at once
    shown = len(live)
    if shown > 5:
        shown = 5
    band = 32 // shown

    for i in range(shown):
        a = live[i]
        bg = alert_color(a["cls"])
        y0 = i * band
        c.rect(0, y0, 2, y0 + band - 2, fill = bg)

        tx = 5
        maxw = c.width - tx
        exp = ("TIL " + a["til"]) if a["til"] != "" else ""

        if band >= 15:
            hz = shorten(c, a["hazard"], maxw, "4x5")
            font = "5x7" if c.text_width(hz, "5x7") <= maxw else "4x5"
            c.text(hz, tx, y0 + 1, font = font, color = WHITE)
            if exp != "":
                c.text(exp, tx, y0 + 9, font = "4x5", color = GRAY)
        else:
            ty = y0 + (band - 1 - 5) // 2
            if ty < y0:
                ty = y0
            hz = shorten(c, a["hazard"], maxw, "4x5")
            # the expiry only earns its place if the whole name still fits
            room = False
            if band >= 9 and exp != "":
                need = c.text_width(hz, "4x5") + 3 + c.text_width(exp, "4x5")
                room = need <= maxw
            c.text(hz, tx, ty, font = "4x5", color = WHITE)
            if room:
                c.text(exp, 63, ty, font = "4x5", color = GRAY, align = "right")

    if len(live) > shown:
        c.text("+" + str(len(live) - shown), 63, 27, font = "4x5",
               color = GRAY, align = "right")
