# Date & Weather — local date and today's weather for a US zip code. (192x32, 2 pages)
#
# DESIGN. The date is the anchor. TODAY puts the weekday over a big 10x16 date
# on the left, so the panel reads as a date app first rather than as another
# weather app, and gives the right zone to the weather at a glance: the place,
# the drawn condition, a 10x16 temperature, today's high, low, and humidity
# in a column, and the condition by name. SKY shows the next six hours, three
# over three, each an hour, drawn condition, temperature, and chance of rain,
# with sunrise stacked over sunset on the right.
#
# No clock: the app re-renders every 15 minutes (refresh 900), and a time
# drawn at that rate would sit up to 15 minutes stale. Sunrise and sunset are
# fixed times for the day, so the slow refresh never makes them wrong.
#
# Temperatures show in F or C (a dropdown). Colors come from two dropdowns
# (date, weather); the current temperature always takes weather-map colors by
# value, white at its coldest. The place name and labels are gray, the
# dividers dim gray.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
WEEKDAYS_FULL = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY",
                  "SATURDAY", "SUNDAY"]

# Content lives in x 4..187: a narrow margin still sets the app apart from a
# neighbouring app on the glass, and gives the weather the extra width.
LEFT = 4
RIGHT = 187
GAP = 6              # empty space on each side of a divider
DIVIDER = "#444444"  # dim gray rule between zones; fixed, not a setting
LABEL = "#969696"    # gray, for the place name and the SKY labels
MOON_LIT = "#FFF4C8"   # the moon's lit side, a pale cream
MOON_MARE = "#9C9682"  # the dark seas on the lit side
MOON_DIM = "#2C2C30"   # the moon's unlit side

# Compact weather glyphs, drawn at 2x (18px) beside the temperature.
SUN = [
    [0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 1, 0, 0, 1, 0],
    [0, 0, 1, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
    [1, 1, 0, 1, 1, 1, 0, 1, 1],
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 1, 0, 0],
    [0, 1, 0, 0, 1, 0, 0, 1, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0],
]
CLOUD = [
    [0, 0, 0, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
]
# A low cloud for partly cloudy nights: it covers only the bottom of the moon,
# so the phase still reads above it.
LOW_CLOUD = [
    [0, 0, 0, 0, 0, 1, 1, 0, 0],
    [0, 1, 1, 0, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
]
RAINDROPS = [
    [0, 1, 0, 0, 1, 0, 0, 1, 0],
    [1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 0],
]
SNOWFLAKES = [
    [0, 1, 0, 0, 0, 0, 1, 0, 0],
    [1, 1, 1, 0, 0, 1, 1, 1, 0],
    [0, 1, 0, 0, 0, 0, 1, 0, 0],
]
LIGHTNING = [
    [0, 0, 1, 1, 0],
    [0, 0, 1, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 1, 0, 0, 0],
    [1, 1, 0, 0, 0],
]
FOG = [
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 0, 0],
]

# The degree mark. No bitmap font carries U+00B0, and a 1px dot beside a
# 10x16 digit reads as dirt, so it is a drawn ring matched to the digit stroke.
RING = [
    [0, 1, 1, 1, 0],
    [1, 1, 0, 1, 1],
    [1, 0, 0, 0, 1],
    [1, 1, 0, 1, 1],
    [0, 1, 1, 1, 0],
]

# SKY icons, 1x: a half sun with rays on a gray horizon, yellow for sunrise and orange
# for sunset. (An up/down arrow stacked on the sun read as a cross on a grave.)
SUN_RAYS = [
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
    [1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1],
]
HORIZON = [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]

# ---------- input ----------

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

# The five named colors the color dropdowns offer. Anything else -- like a hex
# saved back when these were color wheels -- falls back to white.
TEXT_COLORS = {"White": "#FFFFFF", "Amber": "#FFBF00", "Green": "#00DC46",
               "Cyan": "#00DCDC", "Red": "#FF0000"}

def _color(ctx, key):
    return TEXT_COLORS.get(_s(ctx, key, "White"), "#FFFFFF")

# Meteorological temperature colors: the 10-degree bands of a TV/NWS
# temperature map, Fahrenheit, white when bitter cold, then purple through
# blue, green, yellow and orange to red when hot.
TEMP_BANDS = [
    [-10, "#FFFFFF"],   # below -10
    [0, "#CC66FF"],     # -10 to -1
    [10, "#9966FF"],    # 0s
    [20, "#3366FF"],    # 10s
    [32, "#3399FF"],    # 20s to freezing
    [40, "#33CCFF"],    # 32-39
    [50, "#33FFCC"],    # 40s
    [60, "#33FF66"],    # 50s
    [70, "#99FF33"],    # 60s
    [80, "#FFFF33"],    # 70s
    [90, "#FFAA00"],    # 80s
    [100, "#FF5500"],   # 90s
]
TEMP_HOT = "#FF0000"    # 100 and up

def temp_scale_color(f):
    for band in TEMP_BANDS:
        if f < band[0]:
            return band[1]
    return TEMP_HOT

# ---------- calendar ----------

def _civil_from_days(z):
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return y, m, d

def local_parts(ctx, off_hours):
    # Shift to the zip's local time first, so the date turns over at local
    # midnight rather than UTC midnight.
    local = ctx.now.unix + int(off_hours * 3600.0)
    sod = local % 86400
    days = (local - sod) // 86400
    y, mo, d = _civil_from_days(days)
    return {
        "y": y,
        "mo": mo,
        "d": d,
        "wd": (days + 3) % 7,  # 0 = Monday, matches WEEKDAYS_FULL
    }

def format_date(ctx, t):
    # Choices are written as an example date. The long formats saved before
    # the 192 redesign (MM/DD/YYYY and friends) map onto their short form.
    fmt = _s(ctx, "dateformat", "SEP 14")
    mon = MONTHS[t["mo"] - 1]
    if fmt == "09/14" or fmt.startswith("MM/DD"):
        return pad2(t["mo"]) + "/" + pad2(t["d"])
    if fmt == "14/09" or fmt.startswith("DD/MM"):
        return pad2(t["d"]) + "/" + pad2(t["mo"])
    if fmt == "14 SEP" or fmt.startswith("DD MON"):
        return str(t["d"]) + " " + mon
    return mon + " " + str(t["d"])

# ---------- moon phase (same synodic-month math as the moon-phase app) ----------

SYNODIC = 29.530588853          # days, new moon to new moon
NEW_EPOCH = 947182440           # unix time of a known new moon: 2000-01-06 18:14 UTC

def _moon_phase(ctx):
    cycles = (float(ctx.now.unix) - float(NEW_EPOCH)) / 86400.0 / SYNODIC
    p = cycles - float(int(cycles))
    if p < 0.0:
        p = p + 1.0
    return p

def _moon_bitmaps(p):
    # A 9x9 disc split by the real terminator ellipse, so the icon shows the
    # actual current phase (crescent/quarter/gibbous/full) rather than a
    # fixed crescent glyph. Returns [lit part, whole disc].
    # Radius 4.5 rounds the disc (rows 5, 7, 9 ... 9, 7, 5 wide); at 4 its
    # edge-centre pixels stuck out as points.
    r = 4
    rr = 20.25
    t = math.cos(2.0 * math.pi * p)
    waxing = p < 0.5
    lit_grid = []
    disc_grid = []
    for dy in range(-r, r + 1):
        lit_row = []
        disc_row = []
        for dx in range(-r, r + 1):
            if float(dx * dx + dy * dy) > rr:
                lit_row.append(0)
                disc_row.append(0)
            else:
                w = math.sqrt(rr - float(dy * dy))
                xf = float(dx)
                lit = (xf >= t * w) if waxing else (xf <= -t * w)
                lit_row.append(1 if lit else 0)
                disc_row.append(1)
        lit_grid.append(lit_row)
        disc_grid.append(disc_row)
    return [lit_grid, disc_grid]

# The near side's dark seas on the 9x9 disc, roughly where they sit on the
# real moon: Imbrium upper left, Serenitatis and Tranquillitatis upper right,
# Procellarum down the left, Fecunditatis and Nubium lower. They are drawn on
# the lit part only, so more of the face fills in as the moon waxes.
MARIA = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 0, 1, 1, 0, 0],
    [0, 1, 1, 0, 0, 1, 1, 1, 0],
    [0, 1, 0, 0, 0, 0, 1, 1, 0],
    [0, 1, 1, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
]

def _moon(c, phase, x, y, scale):
    # The unlit side is drawn dim: a few days from new moon the lit sliver
    # alone read as a stray bracket, not a moon.
    grids = _moon_bitmaps(phase)
    lit = grids[0]
    seas = [[lit[r][k] * MARIA[r][k] for k in range(9)] for r in range(9)]
    _bmp(c, grids[1], x, y, MOON_DIM, scale)
    _bmp(c, lit, x, y, MOON_LIT, scale)
    _bmp(c, seas, x, y, MOON_MARE, scale)

# ---------- lookups ----------

def geocode(ctx):
    # {"ok": True, lat, lon, place, state}, or {"ok": False, ...}. "fatal" marks
    # a zip the user has to fix; a network failure is not fatal, so the date
    # still draws.
    zip = _s(ctx, "zip", "")
    if not zip:
        return {"ok": False, "fatal": True, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}

    # Zip codes rarely move, so cache for a day.
    r = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if r["status_code"] == 404:
        return {"ok": False, "fatal": True, "title": "BAD ZIP CODE", "sub": zip.upper() + " NOT FOUND"}
    if r["status_code"] != 200:
        return {"ok": False, "fatal": False}

    places = r["json"].get("places", [])
    if not places:
        return {"ok": False, "fatal": True, "title": "BAD ZIP CODE", "sub": zip.upper() + " NOT FOUND"}

    p = places[0]
    return {
        "ok": True,
        "lat": float(p["latitude"]),
        "lon": float(p["longitude"]),
        "place": str(p.get("place name", "")).upper(),
        "state": str(p.get("state abbreviation", "")).upper(),
    }

# The date's UTC offset rides along with the weather: Open-Meteo answers with
# the zip's utc_offset_seconds (timezone=auto, DST applied), so there is no time
# API and no second input. What follows is the FALLBACK for when the weather
# feed is down -- Eastern, worked out locally -- so a dead feed costs the
# weather, not the date.
#
# US daylight saving: 2nd Sunday in March 02:00 -> 1st Sunday in November 02:00.
EASTERN_STD = -300   # minutes east of UTC

def _dfc(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _nth_sunday(y, m, n):
    """Day of the month of the nth Sunday. 1970-01-01 was a Thursday."""
    wd = (_dfc(y, m, 1) + 4) % 7      # 0 = Sunday
    return 1 + (7 - wd) % 7 + 7 * (n - 1)

def offset_hours(ctx):
    """Fallback offset (US Eastern), daylight saving already applied."""
    std = EASTERN_STD
    t = ctx.now.unix // 60
    y = ctx.now.year
    start = _dfc(y, 3, _nth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = _dfc(y, 11, _nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    off = std + 60 if (t >= start and t < end) else std
    return off / 60.0

def fetch_weather(lat, lon):
    r = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": str(lat),
            "longitude": str(lon),
            "current": "temperature_2m,relative_humidity_2m,weather_code,is_day,cloud_cover",
            "hourly": "temperature_2m,weather_code,precipitation_probability,is_day,cloud_cover",
            "daily": "temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset",
            "forecast_days": "2",   # so late-evening hours reach past midnight
            "temperature_unit": "fahrenheit",
            "timezone": "auto",
        },
        ttl_seconds = 900,    # matches refresh: 900 in manifest.yaml
    )
    if r["status_code"] != 200:
        return None
    j = r["json"]
    if not j:
        return None
    return j

def fetch_all(ctx):
    # Both pages start here; the second page's calls come back from the cache.
    geo = geocode(ctx)
    wxj = fetch_weather(geo["lat"], geo["lon"]) if geo["ok"] else None
    off = offset_hours(ctx)
    if wxj != None and wxj.get("utc_offset_seconds", None) != None:
        off = float(wxj["utc_offset_seconds"]) / 3600.0
    return geo, wxj, local_parts(ctx, off)

def _first(d, key):
    # Today's value from one of Open-Meteo's daily arrays, or None.
    if d == None:
        return None
    arr = d.get(key, None)
    if arr == None or len(arr) == 0:
        return None
    return arr[0]

def whole(v):
    return int(v + 0.5) if v >= 0 else int(v - 0.5)

def deg(ctx, f):
    # Weather arrives in Fahrenheit; show it whole in the chosen unit. The
    # color scale always reads the Fahrenheit value, so 20C is 68F's color.
    if _s(ctx, "units", "F") == "C":
        return whole((f - 32) * 5 / 9)
    return whole(f)

def sun_time(s):
    # Local ISO time under timezone=auto: "2026-09-14T06:32" -> "6:32".
    if s == None or len(s) < 16:
        return "--"
    h = int(s[11]) * 10 + int(s[12]) if s[11].isdigit() and s[12].isdigit() else -1
    if h < 0:
        return "--"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + s[14:16]

def hour_label(s):
    # "2026-09-14T15:00" -> "3P"; "PM" ran into the next cell.
    h = int(s[11:13])
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ("A" if h < 12 else "P")

def next_hours(wxj, n):
    # The n hours after the current one, from Open-Meteo's hourly arrays
    # (local times under timezone=auto). Each is
    # [label, temp, code, rain, is_day, cloud cover %].
    cur = wxj.get("current", None)
    hourly = wxj.get("hourly", None)
    if cur == None or hourly == None:
        return []
    now = str(cur.get("time", ""))[:13]
    times = hourly.get("time", [])
    start = -1
    for i in range(len(times)):
        if str(times[i])[:13] == now:
            start = i + 1
            break
    if start < 0:
        return []
    out = []
    for i in range(start, min(start + n, len(times))):
        t = hourly["temperature_2m"][i]
        code = hourly["weather_code"][i]
        rain = hourly["precipitation_probability"][i]
        if t == None or code == None:
            continue
        cover = hourly.get("cloud_cover", [])
        out.append([hour_label(str(times[i])), t, int(code),
                    rain, int(hourly["is_day"][i] or 0) == 1,
                    cover[i] if i < len(cover) else None])
    return out

# ---------- weather icon + condition text ----------

# Open-Meteo has no "mostly cloudy" code: 3 covers everything from mostly
# cloudy to overcast. Below this cloud cover (the NWS overcast line, 7/8 of
# the sky) a code 3 night still lets the moon through.
OVERCAST_COVER = 88

def mostly_cloudy(code, cover):
    return code == 3 and cover != None and cover < OVERCAST_COVER

RAIN_CODES = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
SNOW_CODES = [71, 73, 75, 77, 85, 86]

def _bmp(c, bitmap, x, y, color, scale):
    for ry in range(len(bitmap)):
        row = bitmap[ry]
        for rx in range(len(row)):
            if not row[rx]:
                continue
            if scale <= 1:
                c.pixel(x + rx, y + ry, color)
            else:
                c.rect(x + rx * scale, y + ry * scale,
                       x + rx * scale + scale - 1, y + ry * scale + scale - 1,
                       fill = color)

def draw_condition(c, code, is_day, phase, cover, x, y, scale):
    # Every glyph stays inside 9 rows x scale, so nothing reaches the
    # condition text drawn one gap below the icon.
    if code == 0 or code == 1:
        if is_day:
            _bmp(c, SUN, x, y, "yellow", scale)
        else:
            _moon(c, phase, x, y, scale)
    elif code == 2:
        # Partly cloudy: sun peeking out from behind the cloud, or the moon
        # over a low cloud.
        if is_day:
            _bmp(c, SUN, x, y, "yellow", scale)
            _bmp(c, CLOUD, x, y + 3 * scale, "gray", scale)
        else:
            _moon(c, phase, x, y, scale)
            _bmp(c, LOW_CLOUD, x, y + 5 * scale, "gray", scale)
    elif mostly_cloudy(code, cover) and not is_day:
        # Mostly cloudy at night: the cloud rides higher, so only the top of
        # the moon shows over it.
        _moon(c, phase, x, y, scale)
        _bmp(c, CLOUD, x, y + 2 * scale, "gray", scale)
    elif code == 45 or code == 48:
        _bmp(c, FOG, x, y + scale, "gray", scale)
    elif code in RAIN_CODES:
        _bmp(c, CLOUD, x, y, "gray", scale)
        _bmp(c, RAINDROPS, x, y + 6 * scale, "cyan", scale)
    elif code in SNOW_CODES:
        _bmp(c, CLOUD, x, y, "gray", scale)
        _bmp(c, SNOWFLAKES, x, y + 6 * scale, "white", scale)
    elif code >= 95:
        # The bolt starts inside the cloud: at row 5 its 5 rows ran to row 9,
        # one past the 9-row box and into the condition text.
        _bmp(c, CLOUD, x, y, "gray", scale)
        _bmp(c, LIGHTNING, x + 2 * scale, y + 4 * scale, "amber", scale)
    else:
        # 3 = overcast, and any unmapped code.
        _bmp(c, CLOUD, x, y + 2 * scale, "gray", scale)

def condition_label(code, is_day, cover):
    # Each fits the ~54px left of the humidity on TODAY's bottom row.
    # Clear sky at night: moon icon, "CLEAR" text (same slot FOG etc. use).
    if code == 0:
        return "SUNNY" if is_day else "CLEAR"
    if code == 1:
        return "MOSTLY SUN" if is_day else "MOSTLY CLR"
    if code == 2:
        return "PTLY CLOUDY"
    if mostly_cloudy(code, cover) and not is_day:
        return "MOSTLY CLDY"
    if code == 3:
        return "CLOUDY"
    if code == 45:
        return "FOG"
    if code == 48:
        return "ICY FOG"
    if code == 51:
        return "LT DRIZZLE"
    if code == 53:
        return "DRIZZLE"
    if code == 55:
        return "HVY DRIZZLE"
    if code == 56:
        return "LT FZ DRZL"
    if code == 57:
        return "FZ DRIZZLE"
    if code == 61:
        return "LIGHT RAIN"
    if code == 63:
        return "RAIN"
    if code == 65:
        return "HEAVY RAIN"
    if code == 66:
        return "LT FZ RAIN"
    if code == 67:
        return "FZ RAIN"
    if code == 71:
        return "LIGHT SNOW"
    if code == 73:
        return "SNOW"
    if code == 75:
        return "HEAVY SNOW"
    if code == 77:
        return "SNOW GRAINS"
    if code == 80:
        return "LT SHOWERS"
    if code == 81:
        return "SHOWERS"
    if code == 82:
        return "HVY SHOWERS"
    if code == 85:
        return "LT SNOW SHW"
    if code == 86:
        return "SNOW SHWRS"
    if code == 95:
        return "T-STORMS"
    if code == 96:
        return "STORM + HAIL"
    if code == 99:
        return "SVR STORMS"
    return "CLOUDY"

# ---------- text helpers ----------

def clip(c, text, font, maxw):
    # Nothing in the API clips, so anything from a feed goes through here.
    if c.text_width(text, font) <= maxw:
        return text
    for n in range(len(text) - 1, 0, -1):
        s = text[:n].rstrip() + ".."
        if c.text_width(s, font) <= maxw:
            return s
    return ""

def place_text(c, geo, maxw):
    # 'RANCHO SANTA MARGARITA, CA' is 119px at 4x5, past the ~90px weather
    # zone: drop the state first, then clip the town.
    full = geo["place"] + ", " + geo["state"]
    if c.text_width(full, "4x5") <= maxw:
        return full
    return clip(c, geo["place"], "4x5", maxw)

def nodata(c, title, sub):
    cx = (LEFT + RIGHT + 1) // 2
    w = RIGHT - LEFT + 1
    c.text(clip(c, title, "6x8", w), cx, 10, font = "6x8", color = "white", align = "center")
    c.text(clip(c, sub, "4x5", w), cx, 20, font = "4x5", color = LABEL, align = "center")

def left_zone_w(c):
    # Sized to the widest date any day can produce, so the divider and the
    # weather zone stay put from one day to the next.
    w = c.text_width("WEDNESDAY", "5x7")
    for m in MONTHS:
        w = max(w, c.text_width(m + " 30", "10x16"), c.text_width("30 " + m, "10x16"))
    return w

# ---------- pages ----------

def today(c, ctx):
    c.fill("black")
    geo, wxj, t = fetch_all(ctx)
    if not geo["ok"] and geo["fatal"]:
        nodata(c, geo["title"], geo["sub"])
        return

    # Left zone: weekday (5x7, y 3-9) over the big date (10x16, y 12-27).
    date_color = _color(ctx, "datecolor")
    lw = left_zone_w(c)
    cx = LEFT + lw // 2
    c.text(WEEKDAYS_FULL[t["wd"]], cx, 3, font = "5x7", color = date_color, align = "center")
    c.text(format_date(ctx, t), cx, 12, font = "10x16", color = date_color, align = "center")

    dx = LEFT + lw + GAP
    c.line(dx, 3, dx, 28, DIVIDER)
    rx = dx + 1 + GAP
    rw = RIGHT - rx + 1

    cur = wxj.get("current", None) if wxj != None else None
    temp = cur.get("temperature_2m", None) if cur != None else None
    if temp == None:
        c.text("NO WEATHER", rx + rw // 2, 12, font = "6x8", color = LABEL, align = "center")
        return

    # Right zone rows: place y 1-5 · icon y 7-24 beside the 10x16 temperature
    # (y 8-23) and high/low/humidity · condition y 26-30.
    weather_color = _color(ctx, "weathercolor")
    c.text(place_text(c, geo, rw), rx, 1, font = "4x5", color = LABEL)

    code = int(cur.get("weather_code", 3))
    is_day = int(cur.get("is_day", 1)) == 1
    cover = cur.get("cloud_cover", None)
    draw_condition(c, code, is_day, _moon_phase(ctx), cover, rx, 7, 2)

    tcolor = temp_scale_color(whole(temp))
    ts = str(deg(ctx, temp))
    tx = rx + 18 + 4
    c.text(ts, tx, 8, font = "10x16", color = tcolor)
    ring_x = tx + c.text_width(ts, "10x16") + 1
    _bmp(c, RING, ring_x, 8, tcolor, 1)

    # High, low, and humidity share one right-hand column at an even 8px
    # pitch: labels right-aligned on HUM's M, values left-aligned after them.
    # The column is sized for "HUM 100%"; the condition gets everything left
    # of it.
    col = max(RIGHT + 1 - c.text_width("HUM 100%", "4x5"), ring_x + len(RING[0]) + 4)
    daily = wxj.get("daily", None)
    hi = _first(daily, "temperature_2m_max")
    lo = _first(daily, "temperature_2m_min")
    rows = []
    if hi != None and lo != None:
        rows.append(["H", str(deg(ctx, hi)), 10])
        rows.append(["L", str(deg(ctx, lo)), 18])
    hum = cur.get("relative_humidity_2m", None)
    if hum != None:
        rows.append(["HUM", str(whole(hum)) + "%", 26])
    vx = RIGHT + 1 - c.text_width("100%", "4x5")
    for row in rows:
        c.text(row[0], vx - 2 - c.text_width(row[0], "4x5"), row[2],
               font = "4x5", color = LABEL)
        c.text(row[1], vx, row[2], font = "4x5", color = "white")
    cw = (col - 4 - rx) if hum != None else rw

    c.text(clip(c, condition_label(code, is_day, cover), "4x5", cw), rx, 26,
           font = "4x5", color = weather_color)


# A 3x3 degree ring for the small hourly temperatures.
RING_SMALL = [
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1],
]

def hour_cell(c, ctx, h, phase, x, y):
    # One hour, 15px tall from y: the hour over its drawn condition (1x, 9x9)
    # on the left; the 5x7 temperature over the 4x5 chance of rain beside it.
    c.text(h[0], x, y, font = "4x5", color = LABEL)
    draw_condition(c, h[2], h[4], phase, h[5], x, y + 6, 1)
    tx = x + c.text_width("12A", "4x5") + 2
    ts = str(deg(ctx, h[1]))
    c.text(ts, tx, y + 1, font = "5x7", color = "white")
    _bmp(c, RING_SMALL, tx + c.text_width(ts, "5x7") + 1, y + 1, "white", 1)
    rain = "--" if h[3] == None else str(whole(h[3])) + "%"
    c.text(rain, tx, y + 10, font = "4x5", color = "cyan")

def sun_row(c, label, value, x, y, sun_color):
    # One stacked sun row, 14px tall from y: the horizon icon, then the gray
    # label over the 6x8 time in the sun's own color.
    _bmp(c, SUN_RAYS, x, y + 4, sun_color, 1)
    _bmp(c, HORIZON, x, y + 9, "gray", 1)
    tx = x + len(SUN_RAYS[0]) + 3
    c.text(label, tx, y, font = "4x5", color = LABEL)
    c.text(value, tx, y + 6, font = "6x8", color = LABEL if value == "--" else sun_color)

def sky(c, ctx):
    c.fill("black")
    geo, wxj, t = fetch_all(ctx)
    if not geo["ok"] and geo["fatal"]:
        nodata(c, geo["title"], geo["sub"])
        return

    daily = wxj.get("daily", None) if wxj != None else None
    if daily == None:
        nodata(c, "NO WEATHER", "CHECK BACK SOON")
        return

    # Right zone, sized to its widest text: sunrise stacked over sunset.
    sw = len(SUN_RAYS[0]) + 3 + max(c.text_width("SUNRISE", "4x5"), c.text_width("10:15", "6x8"))
    rx = RIGHT - sw + 1
    dx = rx - GAP - 1
    c.line(dx, 3, dx, 28, DIVIDER)
    sun_row(c, "SUNRISE", sun_time(_first(daily, "sunrise")), rx, 1, "yellow")
    sun_row(c, "SUNSET", sun_time(_first(daily, "sunset")), rx, 17, "orange")

    # Left zone: the next six hours, three over three. Each row is 15px
    # tall; the second starts at 17, leaving 2px between them and ending on
    # the panel's last row.
    hours = next_hours(wxj, 6)
    lw = dx - GAP - LEFT
    if not hours:
        c.text("NO FORECAST", LEFT + lw // 2, 13, font = "4x5", color = LABEL, align = "center")
        return
    # Columns spread so the third ends one gap before the divider, the
    # spare width going between them rather than all to the right.
    phase = _moon_phase(ctx)
    cellw = c.text_width("12A", "4x5") + 2 + c.text_width("100", "5x7") + 1 + len(RING_SMALL[0])
    cw = (lw - cellw) // 2
    for i in range(len(hours)):
        hour_cell(c, ctx, hours[i], phase, LEFT + (i % 3) * cw, 0 if i < 3 else 17)
