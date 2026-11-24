# Rain Watch Small (64x32)
#
# The 64x32 edition of Rain Watch: the same keyless data on four pages sized
# for a 64-wide panel (radar now, next 12 hours, this week, rain totals).
#
# Live rain around a US zip code: what's falling nearest, how far away, how
# hard, and whether it's closing in or moving off, with a 70-mile radar map.
#
# NOW. RainViewer's latest radar frame (free, no key) centered on the zip,
# cropped to 35 miles each side and passed through images.weserv.nl as an
# uncompressed base64 PNG, since http.get only carries text. Each pixel's
# color maps to a reflectivity (dBZ) from RainViewer's Universal Blue color
# table, and dBZ to a word: SPRINKLES, LIGHT, STEADY, HEAVY, DOWNPOUR, STORMS.
# Under 18 dBZ is radar noise and ignored.
#
# COMING OR GOING. The frames 20 and 40 minutes back give a trend: the
# nearest rain's distance (least-squares slope) and how much rain is around.
# Ten-minute frames at this zoom are too coarse to track a storm's heading
# reliably, but distance and coverage over 40 minutes say what a viewer wants
# to know: closing in (with an arrival estimate), moving away, holding, or
# drying up.
#
# NOTHING ON RADAR. A model forecast can miss a shower that's already
# forming, so a clear radar alone never says dry: the NWS hourly forecast's
# chance of rain over the next three hours comes first, then Open-Meteo's
# week ahead for the next likely rain day.

# RainViewer Universal Blue color -> dBZ
DBZ = {'636159': -10, '66635a': -9, '69665c': -8, '6c685d': -7, '6f6b5f': -6, '726e61': -5, '757062': -4, '787364': -3, '7c7565': -2, '7f7867': -1, '827b69': 0, '857d6a': 1, '88806c': 2, '8b826d': 3, '8e856f': 4, '928871': 5, '9e9375': 6, 'aa9e79': 7, 'b6a97e': 8, 'c2b482': 9, 'cec087': 10, 'd2c48b': 11, 'd6c88f': 12, 'dacc93': 13, 'ded097': 14, '88ddee': 15, '6cd1eb': 16, '51c5e8': 17, '36bae5': 18, '1baee2': 19, '00a3e0': 20, '009ad5': 21, '0091ca': 22, '0088bf': 23, '007fb4': 24, '0077aa': 25, '0070a3': 26, '00699c': 27, '006295': 28, '005b8e': 29, '005588': 30, '005180': 31, '004e78': 32, '004a70': 33, '004768': 34, 'ffee00': 35, 'ffe000': 36, 'ffd200': 37, 'ffc500': 38, 'ffb700': 39, 'ffaa00': 40, 'ff9f00': 41, 'ff9500': 42, 'ff8b00': 43, 'ff8100': 44, 'ff4400': 45, 'f23600': 46, 'e62800': 47, 'd91b00': 48, 'cd0d00': 49, 'c10000': 50, 'a80000': 51, '8f0000': 52, '760000': 53, '5d0000': 54, 'ffaaff': 55, 'ff9fff': 56, 'ff95ff': 57, 'ff8bff': 58, 'ff81ff': 59, 'ff77ff': 60, 'ff6cff': 61, 'ff62ff': 62, 'ff58ff': 63, 'ff4eff': 64, 'ffffff': 65, '00ff00': 75, 'cfffff': -10, 'ceffff': -9, 'cdffff': -8, 'ccffff': -7, 'cbffff': -6, 'caffff': -4, 'c9ffff': -3, 'c8ffff': -2, 'c7ffff': -1, 'c6ffff': 1, 'c5ffff': 2, 'c4ffff': 3, 'c3ffff': 4, 'c2ffff': 6, 'c1ffff': 7, 'c0ffff': 8, 'bfffff': 9, 'b8f8ff': 11, 'b2f2ff': 12, 'abebff': 13, 'a5e5ff': 14, '9fdfff': 15, '98d8ff': 16, '92d2ff': 17, '8bcbff': 18, '85c5ff': 19, '7fbfff': 20, '78b8ff': 21, '72b2ff': 22, '6babff': 23, '65a5ff': 24, '5f9fff': 25, '5b9bff': 26, '5898ff': 27, '5595ff': 28, '5292ff': 29, '4f8fff': 30, '4b8bff': 31, '4888ff': 32, '4585ff': 33, '4282ff': 34, '3f7fff': 35, '3b7bff': 36, '3878ff': 37, '3575ff': 38, '3272ff': 39, '2f6fff': 40, '2b6bff': 41, '2868ff': 42, '2565ff': 43, '2262ff': 44, '1f5fff': 45, '1b5bff': 46, '1858ff': 47, '1555ff': 48, '1252ff': 49, '0f4fff': 50, '0c4bff': 51, '0948ff': 52, '0645ff': 53, '0242ff': 54, '003fff': 55, '003bff': 56, '0038ff': 57, '0035ff': 58, '0032ff': 59, '002fff': 60, '002bff': 61, '0028ff': 62, '0025ff': 63, '0022ff': 64, '001fff': 65, '001bff': 66, '0018ff': 67, '0015ff': 68, '0012ff': 69, '000fff': 70, '000cff': 71, '0009ff': 72, '0006ff': 73, '0002ff': 74, '0000ff': 75}

ZIP_URL = "https://api.zippopotam.us/us/"
RADAR_INDEX = "https://api.rainviewer.com/public/weather-maps.json"
PROXY = "https://images.weserv.nl/"
USER_AGENT = "GDN-RainWatch (glance-led-panel)"

CROP = 114           # z7 radar px around the zip, about 1 km each: 35 mi out
KM_PER_PX = 0.99
MIN_DBZ = 18
OVERHEAD_PX = 8      # rain within about 5 mi counts as overhead
MAP = 32

INK = "#F4F7FF"
DIM = "#6E7A94"
CLEAR_BG = "#0B1020"
CHANCE = "#7CC4FF"
WARN = "#E8B04A"

DIRS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
DAY_NAMES = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]


def level(dbz):
    if dbz >= 55:
        return ["STORMS", "#B57BFF"]
    if dbz >= 45:
        return ["DOWNPOUR", "#FF4C4C"]
    if dbz >= 38:
        return ["HEAVY RAIN", "#F2C14E"]
    if dbz >= 30:
        return ["STEADY RAIN", "#2ECC71"]
    if dbz >= 23:
        return ["LIGHT RAIN", "#4AA3FF"]
    return ["SPRINKLES", "#A9D6F5"]

# ---------- PNG decoding (base64 text -> rows of #RRGGBB) ----------
# Same decoder as sxm-now-playing: the proxy returns an uncompressed PNG, so
# its zlib stream is stored blocks and decoding is base64 + unfiltering rows.

B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
B64_VAL = {B64[i]: i for i in range(64)}

def b64_bytes(text):
    out = []
    acc = 0
    bits = 0
    for ch in text.elems():
        v = B64_VAL.get(ch)
        if v == None:
            continue
        acc = (acc << 6 | v) & 0xFFFFFF
        bits += 6
        if bits >= 8:
            bits -= 8
            out.append((acc >> bits) & 0xFF)
    return out

def _u32(b, i):
    return (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3]

def png_pixels(b):
    # Returns rows of "#RRGGBB" for an 8-bit RGB/RGBA PNG with stored
    # deflate blocks, or None for anything else.
    if len(b) < 33 or b[1] != 80 or b[2] != 78 or b[3] != 71:
        return None
    w = _u32(b, 16)
    h = _u32(b, 20)
    if b[24] != 8 or (b[25] != 2 and b[25] != 6) or b[28] != 0:
        return None
    bpp = 3 if b[25] == 2 else 4
    z = []
    i = 8
    for _ in range(64):
        if i + 8 > len(b):
            break
        n = _u32(b, i)
        if b[i + 4] == 73 and b[i + 5] == 68 and b[i + 6] == 65 and b[i + 7] == 84:
            z += b[i + 8:i + 8 + n]
        i += 12 + n
    raw = []
    j = 2
    for _ in range(4096):
        if j + 5 > len(z):
            break
        hdr = z[j]
        if (hdr >> 1) & 3 != 0:
            return None
        ln = z[j + 1] | (z[j + 2] << 8)
        raw += z[j + 5:j + 5 + ln]
        j += 5 + ln
        if hdr & 1:
            break
    stride = w * bpp
    if len(raw) < h * (stride + 1):
        return None
    rows = []
    prev = [0] * stride
    for y in range(h):
        f = raw[y * (stride + 1)]
        line = raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)]
        cur = []
        for k in range(stride):
            a = cur[k - bpp] if k >= bpp else 0
            up = prev[k]
            if f == 0:
                v = line[k]
            elif f == 1:
                v = line[k] + a
            elif f == 2:
                v = line[k] + up
            elif f == 3:
                v = line[k] + (a + up) // 2
            else:
                ul = prev[k - bpp] if k >= bpp else 0
                pp = a + up - ul
                pa = abs(pp - a)
                pb = abs(pp - up)
                pc = abs(pp - ul)
                v = line[k] + (a if pa <= pb and pa <= pc else (up if pb <= pc else ul))
            cur.append(v & 0xFF)
        rows.append(["#" + _hex2(cur[x * bpp]) + _hex2(cur[x * bpp + 1]) + _hex2(cur[x * bpp + 2]) for x in range(w)])
        prev = cur
    return rows

def _hex2(n):
    s = "0123456789ABCDEF"
    return s[n // 16] + s[n % 16]

# ---------- small helpers ----------

def total(xs):
    t = 0.0
    for v in xs:
        t += v
    return t

def fit(c, s, fonts, w):
    for f in fonts:
        if c.text_width(s, f) <= w:
            return f
    return fonts[-1]

def compass(dx, dy):
    ang = math.degrees(math.atan2(dx, -dy))
    return DIRS[int(((ang + 360 + 22.5) % 360) // 45)]

def weekday(date):
    # Monday = 0 for a "YYYY-MM-DD" date (days-from-civil).
    y = int(date[0:4])
    m = int(date[5:7])
    d = int(date[8:10])
    if m <= 2:
        y -= 1
    era = y // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    days = era * 146097 + doe - 719468
    return (days + 3) % 7

def clock(iso):
    # "2026-10-11T18:00:00-04:00" -> "6 PM"
    h = int(iso[11:13])
    return str(h % 12 if h % 12 else 12) + (" AM" if h < 12 else " PM")

# ---------- location ----------

def location(ctx):
    z = str(ctx.inputs.get("zip", "10101")).strip()
    if len(z) != 5 or not z.isdigit():
        return None, "ZIP " + z
    resp = http.get(ZIP_URL + z, ttl_seconds = 2592000)
    if resp["status_code"] == 0:
        return None, "ZIP LOOKUP DOWN"
    j = resp["json"]
    if resp["status_code"] != 200 or j == None or len(j.get("places", [])) == 0:
        return None, "ZIP " + z
    p = j["places"][0]
    return [p["place name"].upper(), p["state abbreviation"], float(p["latitude"]), float(p["longitude"])], None

# ---------- radar ----------

def frame(host, path, lat, lon):
    src = host[8:] + path + "/256/7/" + str(lat) + "/" + str(lon) + "/0/0_0.png"
    off = str(128 - CROP // 2)
    resp = http.get(
        PROXY,
        headers = {"User-Agent": USER_AGENT},
        params = {"url": src, "cx": off, "cy": off, "cw": str(CROP), "ch": str(CROP), "output": "png", "l": "0", "encoding": "base64"},
        ttl_seconds = 3600,
    )
    body = resp.get("body", "")
    if resp["status_code"] != 200 or not body.startswith("data:image/png;base64,"):
        return None
    rows = png_pixels(b64_bytes(body[22:]))
    if rows == None or len(rows) < CROP:
        return None
    grid = []
    for y in range(CROP):
        g = []
        for x in range(CROP):
            v = DBZ.get(rows[y][x][1:].lower())
            g.append(v if v != None and v >= MIN_DBZ else -99)
        grid.append(g)
    return grid

def stats(grid):
    # Nearest echo, strongest within OVERHEAD_PX, and how many km2 of rain
    # inside the 35-mile circle.
    c0 = CROP // 2
    near = None
    over = -99
    n = 0
    for y in range(CROP):
        for x in range(CROP):
            v = grid[y][x]
            if v == -99:
                continue
            dx = x - c0
            dy = y - c0
            d2 = dx * dx + dy * dy
            if d2 > c0 * c0:
                continue
            n += 1
            if near == None or d2 < near[0]:
                near = [d2, dx, dy, v]
            if d2 <= OVERHEAD_PX * OVERHEAD_PX and v > over:
                over = v
    if near == None:
        return None
    return {"d": math.sqrt(near[0]) * KM_PER_PX, "dx": near[1], "dy": near[2], "dbz": near[3], "over": over, "n": n}

def radar(loc):
    idx = http.get(RADAR_INDEX, headers = {"User-Agent": USER_AGENT}, ttl_seconds = 300)
    if idx["status_code"] != 200 or idx["json"] == None:
        return None
    j = idx["json"]
    past = j.get("radar", {}).get("past", [])
    if len(past) == 0:
        return None
    now = frame(j["host"], past[-1]["path"], loc[2], loc[3])
    if now == None:
        return None
    hist = []
    for lag in (4, 2):
        if len(past) > lag:
            g = frame(j["host"], past[-1 - lag]["path"], loc[2], loc[3])
            if g != None:
                hist.append([(past[-1]["time"] - past[-1 - lag]["time"]) / 60.0, stats(g)])
    return {"grid": now, "s": stats(now), "hist": hist}

def radar_trend(r):
    # [slope of the nearest rain's distance in km/min (negative = closing),
    #  growth word, have history?] from the frames 20 and 40 minutes back.
    s = r["s"]
    pts = [[-h[0], h[1]["d"], h[1]["n"]] for h in r["hist"] if h[1] != None] + [[0.0, s["d"], s["n"]]]
    if len(pts) < 2:
        return [0.0, "", False]
    mt = total([q[0] for q in pts]) / len(pts)
    md = total([q[1] for q in pts]) / len(pts)
    den = total([(q[0] - mt) * (q[0] - mt) for q in pts])
    slope = total([(q[0] - mt) * (q[1] - md) for q in pts]) / den if den > 0 else 0.0
    area = s["n"] * 1.0 / pts[0][2] if pts[0][2] > 0 else 1.0
    grow = ""
    if area < 0.75:
        grow = "DRYING UP"
    elif area > 1.33:
        grow = "BUILDING"
    return [slope, grow, True]

def trend(r):
    # Words from the radar alone: is the rain coming or going?
    s = r["s"]
    t = radar_trend(r)
    slope = t[0]
    grow = t[1]
    if not t[2]:
        return "JUST SHOWED UP ON RADAR"
    if s["over"] != -99:
        return ("RAIN AROUND YOU IS " + grow) if grow != "" else "NOT LETTING UP YET"
    if slope < -0.05:
        eta = int(s["d"] / -slope + 0.5)
        if eta > 120:
            return "SLOWLY CLOSING IN" + (" - " + grow if grow != "" else "")
        return "CLOSING IN - HERE IN ABOUT " + (str(eta) + " MIN" if eta < 90 else "2 HRS")
    if slope > 0.05:
        return "MOVING AWAY" + (" AND " + grow if grow != "" else "")
    return "HOLDING ITS DISTANCE" + (" - " + grow if grow != "" else "")

# ---------- which way it's moving ----------
# Rain mostly rides the winds between about 5,000 and 18,000 ft, so the mean
# of the 850, 700 and 500 hPa winds (Open-Meteo, current hour) gives its
# heading. Storms tend to run a bit slower than that mean wind, hence 0.8.
STEER_LEVELS = ["850", "700", "500"]
STEER_FACTOR = 0.8

def steering(m):
    # [vx, vy] in km/min (+x east, +y south) the rain is moving, or None
    cur = m.get("current", {}) if m != None else {}
    sx = 0.0
    sy = 0.0
    n = 0
    for lv in STEER_LEVELS:
        spd = cur.get("wind_speed_" + lv + "hPa")
        frm = cur.get("wind_direction_" + lv + "hPa")
        if spd == None or frm == None:
            continue
        toward = math.radians(frm + 180)
        kmmin = spd * 1.609 / 60.0
        sx += kmmin * math.sin(toward)
        sy += -kmmin * math.cos(toward)
        n += 1
    if n == 0:
        return None
    return [sx / n * STEER_FACTOR, sy / n * STEER_FACTOR]

DIRWORD = {"N": "NORTH", "NE": "NORTHEAST", "E": "EAST", "SE": "SOUTHEAST", "S": "SOUTH", "SW": "SOUTHWEST", "W": "WEST", "NW": "NORTHWEST"}

def movement(r, m):
    # [heading text for the top row, words for the bottom line]; falls back
    # to the radar trend when the winds are missing or disagree with it.
    s = r["s"]
    v = steering(m)
    if v == None:
        return ["", trend(r)]
    spd = math.sqrt(v[0] * v[0] + v[1] * v[1])
    mph = int(spd * 60 / 1.609 + 0.5)
    if mph < 4:
        return ["BARELY MOVING", trend(r)]
    head = compass(v[0], v[1]) + " " + str(mph) + " MPH"
    t = radar_trend(r)
    grow = t[1]
    if s["over"] != -99:
        return [head, ("RAIN AROUND YOU IS " + grow) if grow != "" else "NOT LETTING UP YET"]
    rx = s["dx"] * KM_PER_PX
    ry = s["dy"] * KM_PER_PX
    ux = v[0] / spd
    uy = v[1] / spd
    along = rx * ux + ry * uy            # < 0: the rain is moving toward the zip
    if along >= 0:
        if t[2] and t[0] < -0.05:
            return [head, trend(r)]
        return [head, "MOVING AWAY" + (" AND " + grow if grow != "" else "")]
    if t[2] and t[0] > 0.05:
        return [head, trend(r)]
    # closest point of the rain's track to the zip
    px = rx - along * ux
    py = ry - along * uy
    miss = math.sqrt(px * px + py * py)
    if miss > 8:
        return [head, "PASSING TO YOUR " + DIRWORD[compass(px, py)]]
    eta = int(-along / spd + 0.5)
    if eta > 120:
        return [head, "HEADED YOUR WAY - HOURS OUT"]
    return [head, "HEADED YOUR WAY - ABOUT " + (str(eta) + " MIN" if eta < 90 else "2 HRS")]

# ---------- forecasts for a clear radar ----------

def nws_chance(loc):
    # [best % in the next 3 hours, its hour, thunder?] or None
    periods = nws_hours(loc)
    if periods == None:
        return None
    best = None
    for p in periods[:3]:
        v = pop_of(p)
        if best == None or v > best[0]:
            best = [v, p["startTime"], "THUNDER" in p.get("shortForecast", "").upper()]
    return best

def next_rain_day(loc):
    m = meteo(loc)
    if m == None:
        return None
    d = m["daily"]
    t = d.get("time", [])
    for i in range(PAST_DAYS + 1, len(t)):
        if (d["precipitation_probability_max"][i] or 0) >= 40 and (d["precipitation_sum"][i] or 0) >= 0.02:
            return "NEXT RAIN LIKELY " + ("TOMORROW" if i == PAST_DAYS + 1 else DAY_NAMES[weekday(t[i])])
    return "NO RAIN LIKELY THIS WEEK"

# ---------- shared forecast data ----------
# One Open-Meteo call feeds the week, the totals and page 1's next-rain line:
# 31 days back (totals, dry streak), hourly (today so far) and 7 days ahead.
PAST_DAYS = 31

def meteo(loc):
    resp = http.get("https://api.open-meteo.com/v1/forecast", params = {
        "latitude": str(loc[2]), "longitude": str(loc[3]),
        "daily": "precipitation_sum,precipitation_probability_max,weather_code",
        "hourly": "precipitation",
        "current": "precipitation,wind_speed_850hPa,wind_direction_850hPa,wind_speed_700hPa,wind_direction_700hPa,wind_speed_500hPa,wind_direction_500hPa",
        "wind_speed_unit": "mph",
        "past_days": str(PAST_DAYS), "forecast_days": "7",
        "timezone": "auto", "precipitation_unit": "inch"}, ttl_seconds = 1800)
    if resp["status_code"] != 200 or resp["json"] == None or resp["json"].get("daily") == None:
        return None
    return resp["json"]

def nws_hours(loc):
    # The NWS hourly periods (local times), or None.
    pts = http.get("https://api.weather.gov/points/" + str(loc[2]) + "," + str(loc[3]), headers = {"User-Agent": USER_AGENT}, ttl_seconds = 2592000)
    if pts["status_code"] != 200 or pts["json"] == None:
        return None
    url = pts["json"].get("properties", {}).get("forecastHourly")
    if url == None:
        return None
    hr = http.get(url, headers = {"User-Agent": USER_AGENT}, ttl_seconds = 1800)
    if hr["status_code"] != 200 or hr["json"] == None:
        return None
    return hr["json"].get("properties", {}).get("periods", [])

def inches(x):
    # 0.32 -> "0.32", 12.4 -> "12.4"; rain is never negative.
    n = int(x * 100 + 0.5)
    if n >= 1000:
        n = (n + 5) // 10
        return str(n // 10) + "." + str(n % 10)
    return str(n // 100) + "." + ("0" if n % 100 < 10 else "") + str(n % 100)

def pop_of(p):
    return (p.get("probabilityOfPrecipitation") or {}).get("value") or 0

def kind(text):
    # [word, color] for an NWS short forecast
    t = text.upper()
    if "THUNDER" in t:
        return ["STORMS", "#B57BFF"]
    if "FREEZING" in t or "SLEET" in t or "ICE" in t:
        return ["ICE", "#FF77FF"]
    if "SNOW" in t or "FLURR" in t:
        return ["SNOW", "#E6F2FF"]
    if "DRIZZLE" in t:
        return ["DRIZZLE", "#A9D6F5"]
    return ["RAIN", "#4AA3FF"]

# ---------- 64x32 layout ----------

SHORT = {"STORMS": "STORMS", "DOWNPOUR": "DELUGE", "HEAVY RAIN": "HEAVY", "STEADY RAIN": "STEADY", "LIGHT RAIN": "LIGHT", "SPRINKLES": "MIST"}
ARROW = {"N": [0, -1], "NE": [1, -1], "E": [1, 0], "SE": [1, 1], "S": [0, 1], "SW": [-1, 1], "W": [-1, 0], "NW": [-1, -1]}

def problem(c, line1, line2):
    c.text(line1, 32, 8, font = fit(c, line1, ["5x7", "4x5"], 62), color = WARN, align = "center")
    c.text(line2, 32, 19, font = "4x5", color = DIM, align = "center")

def zip_problem(c, err):
    if err == "ZIP LOOKUP DOWN":
        problem(c, "ZIP DOWN", "RETRY SOON")
    else:
        problem(c, "BAD ZIP", "CHECK SETUP")

def status(text):
    # the 192 app's bottom line, cut to a word or two
    t = text
    if "HERE IN ABOUT" in t or "HEADED YOUR WAY - ABOUT" in t:
        n = t.split("ABOUT ")[1]
        return ["IN " + n.replace(" MIN", "M").replace(" HRS", "H"), WARN]
    if "HOURS OUT" in t or "SLOWLY CLOSING" in t:
        return ["COMING", WARN]
    if "PASSING TO YOUR" in t:
        return ["MISSES", DIM]
    if "MOVING AWAY" in t:
        return ["GOING", "#2ECC71"]
    if "DRYING UP" in t:
        return ["FADING", "#2ECC71"]
    if "BUILDING" in t:
        return ["BUILDS", WARN]
    if "NOT LETTING UP" in t:
        return ["STAYS", INK]
    if "HOLDING" in t:
        return ["PARKED", DIM]
    if "JUST SHOWED UP" in t:
        return ["NEW", INK]
    return ["", INK]

def arrow(c, x, y, d, col):
    # 5x5 arrow pointing from the zip toward the rain
    v = ARROW[d]
    for i in range(-2, 3):
        c.rect(x + v[0] * i, y + v[1] * i, x + v[0] * i, y + v[1] * i, fill = col)
    hx = x + v[0] * 2
    hy = y + v[1] * 2
    if v[0] == 0 or v[1] == 0:
        px = v[1]
        py = v[0]
        c.rect(hx - v[0] - px, hy - v[1] - py, hx - v[0] - px, hy - v[1] - py, fill = col)
        c.rect(hx - v[0] + px, hy - v[1] + py, hx - v[0] + px, hy - v[1] + py, fill = col)
    else:
        c.rect(hx - v[0], hy, hx - v[0], hy, fill = col)
        c.rect(hx, hy - v[1], hx, hy - v[1], fill = col)

def ring(c):
    # faint 35-mile circle on a clear map
    for a in range(0, 360, 8):
        x = int(16 + 15 * math.cos(math.radians(a)) + 0.5)
        y = int(16 + 15 * math.sin(math.radians(a)) + 0.5)
        c.rect(x - 1, y - 1, x - 1, y - 1, fill = "#22304E")

def side(c, lines):
    # right-hand column beside the 32x32 map: [text, fonts, color, y]
    for ln in lines:
        c.text(ln[0], 48, ln[3], font = fit(c, ln[0], ln[1], 31), color = ln[2], align = "center")

# ---------- page 1: radar now ----------

def now(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        zip_problem(c, err)
        return
    r = radar(loc)
    if r == None:
        draw_map(c, None, 0, 0)
        side(c, [["RADAR", ["5x7"], DIM, 8], ["DOWN", ["5x7"], DIM, 18]])
        return
    draw_map(c, r["grid"], 0, 0)
    s = r["s"]
    if s != None:
        mv = movement(r, meteo(loc))
        st = status(mv[1])
        if s["over"] != -99:
            lv = level(s["over"])
            side(c, [[SHORT[lv[0]], ["5x7", "4x5"], lv[1], 1], ["HERE", ["6x8"], INK, 10], [st[0], ["4x5"], st[1], 25]])
            return
        lv = level(s["dbz"])
        d = compass(s["dx"], s["dy"])
        mi = str(int(s["d"] * 0.621 + 0.5))
        side(c, [[SHORT[lv[0]], ["5x7", "4x5"], lv[1], 1], [mi + " MI", ["6x8", "5x7"], INK, 10]])
        arrow(c, 40, 22, d, lv[1])
        c.text(d, 46, 18, font = "5x7", color = INK)
        if st[0] != "":
            c.text(st[0], 48, 27, font = fit(c, st[0], ["4x5"], 31), color = st[1], align = "center")
        return
    ch = nws_chance(loc)
    if ch != None and ch[0] >= 30:
        ring(c)
        side(c, [["STORMS" if ch[2] else "SHOWER", ["5x7", "4x5"], CHANCE, 1], [str(ch[0]) + "%", ["6x8"], CHANCE, 10], ["BY " + clock(ch[1]).replace(" ", ""), ["4x5"], DIM, 25]])
        return
    nxt = next_rain_day(loc)
    day = ""
    if nxt != None and nxt.startswith("NEXT RAIN LIKELY "):
        day = nxt[17:20] if nxt[17:] != "TOMORROW" else "TMRW"
    ring(c)
    if day != "":
        side(c, [["DRY", ["6x8"], DIM, 1], ["NEXT", ["4x5"], DIM, 14], [day, ["5x7"], CHANCE, 22]])
    else:
        side(c, [["DRY", ["6x8"], DIM, 1], ["ALL", ["4x5"], DIM, 14], ["WEEK", ["5x7"], DIM, 22]])

# ---------- page 3: this week ----------

def day_color(amt, code):
    if code >= 95:
        return "#B57BFF"
    if code in (71, 73, 75, 77, 85, 86):
        return "#E6F2FF"
    if amt >= 0.5:
        return "#F2C14E"
    if amt >= 0.1:
        return "#2ECC71"
    if amt >= 0.02:
        return "#4AA3FF"
    return DIM

def week(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        zip_problem(c, err)
        return
    m = meteo(loc)
    if m == None:
        problem(c, "NO FORECAST", "RETRY SOON")
        return
    d = m["daily"]
    wet = None
    base = 23
    for i in range(7):
        j = PAST_DAYS + i
        if j >= len(d["time"]):
            break
        p = d["precipitation_probability_max"][j] or 0
        amt = d["precipitation_sum"][j] or 0
        col = day_color(amt, d["weather_code"][j] or 0)
        x = 1 + i * 9
        h = (p * 14 + 50) // 100
        c.rect(x, base, x + 6, base, fill = "#2A3142")
        if h > 0:
            c.rect(x, base - h, x + 6, base, fill = col if p >= 20 else "#3A4A66")
        c.text(DAYS[weekday(d["time"][j])][0], x + 3, 26, font = "4x5", color = INK if i == 0 else DIM, align = "center")
        if amt >= 0.02 and (wet == None or amt > wet[1]):
            wet = [i, amt, col, DAYS[weekday(d["time"][j])]]
    if wet == None:
        c.text("DRY WEEK", 32, 1, font = "4x5", color = DIM, align = "center")
    else:
        c.text(("TODAY" if wet[0] == 0 else wet[3]) + " " + inches(wet[1]) + " IN", 32, 1, font = "4x5", color = wet[2], align = "center")

# ---------- page 4: rain totals ----------

def totals(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        zip_problem(c, err)
        return
    m = meteo(loc)
    if m == None:
        problem(c, "NO TOTALS", "RETRY SOON")
        return
    d = m["daily"]
    now_t = m.get("current", {}).get("time", "")
    today = now_t[:10]
    hr = m.get("hourly", {})
    so_far = 0.0
    ht = hr.get("time", [])
    hp = hr.get("precipitation", [])
    for i in range(len(ht)):
        if ht[i][:10] == today and ht[i][:13] <= now_t[:13]:
            so_far += hp[i] or 0
    past = [(d["precipitation_sum"][j] or 0) for j in range(PAST_DAYS)]
    rows = [["TODAY", so_far], ["7 DAYS", so_far + total(past[PAST_DAYS - 6:])], ["30 DAYS", so_far + total(past[PAST_DAYS - 29:])]]
    for i in range(3):
        y = i * 8
        c.text(rows[i][0], 1, y + 2, font = "4x5", color = DIM)
        c.text(inches(rows[i][1]), 63, y, font = "5x7", color = CHANCE if rows[i][1] >= 0.01 else DIM, align = "right")
    days = past + [so_far]
    n = len(days)
    if days[-1] >= 0.01:
        run = 0
        for k in range(n):
            if days[n - 1 - k] >= 0.01:
                run += 1
            else:
                break
        line = ["RAIN TODAY" if run == 1 else "WET " + str(run) + " DAYS", CHANCE]
    else:
        dry = 0
        for k in range(n):
            if days[n - 1 - k] < 0.01:
                dry += 1
            else:
                break
        line = ["DRY 30+ DAYS" if dry >= n else ("DRY 1 DAY" if dry == 1 else "DRY " + str(dry) + " DAYS"), INK]
    c.text(line[0], 32, 26, font = "4x5", color = line[1], align = "center")
# ---------- drawing ----------

def shrink(grid):
    # MAP x MAP cells, each the strongest echo in its block of the radar
    # crop, so a small shower still shows up on the map.
    out = []
    for my in range(MAP):
        y0 = my * CROP // MAP
        y1 = (my + 1) * CROP // MAP
        row = []
        for mx in range(MAP):
            x0 = mx * CROP // MAP
            x1 = (mx + 1) * CROP // MAP
            best = -99
            for y in range(y0, y1):
                for x in range(x0, x1):
                    if grid[y][x] > best:
                        best = grid[y][x]
            row.append(level(best)[1] if best != -99 else None)
        out.append(row)
    return out

def draw_map(c, grid, x0, y0):
    c.rect(x0, y0, x0 + MAP - 1, y0 + MAP - 1, fill = CLEAR_BG)
    if grid != None:
        cells = shrink(grid)
        for y in range(MAP):
            row = cells[y]
            x = 0
            for _ in range(MAP):
                if x >= MAP:
                    break
                if row[x] == None:
                    x += 1
                    continue
                e = x
                for _ in range(MAP):
                    if e + 1 < MAP and row[e + 1] == row[x]:
                        e += 1
                    else:
                        break
                c.rect(x0 + x, y0 + y, x0 + e, y0 + y, fill = row[x])
                x = e + 1
    m = MAP // 2
    c.rect(x0 + m - 1, y0 + m - 1, x0 + m, y0 + m, fill = "#FFFFFF")

# ---------- page 2: next 12 hours (NWS chance of rain, % gauge) ----------

TINY = {
    "0": ["111", "101", "101", "101", "111"],
    "1": ["1", "1", "1", "1", "1"],
    "2": ["111", "001", "111", "100", "111"],
    "3": ["111", "001", "111", "001", "111"],
    "4": ["101", "101", "111", "001", "001"],
    "5": ["111", "100", "111", "001", "111"],
    "6": ["111", "100", "111", "101", "111"],
    "7": ["111", "001", "001", "001", "001"],
    "8": ["111", "101", "111", "101", "111"],
    "9": ["111", "101", "111", "001", "111"],
    "%": ["101", "001", "010", "100", "101"],
}

def tiny(c, text, right, y, col):
    # hand-drawn 3x5 digits, right-aligned at x = right
    w = 0
    for ch in text.elems():
        w += len(TINY[ch][0]) + 1
    x = right - w + 2
    for ch in text.elems():
        g = TINY[ch]
        for r in range(5):
            for k in range(len(g[r])):
                if g[r][k] == "1":
                    c.rect(x + k, y + r, x + k, y + r, fill = col)
        x += len(g[0]) + 1

def gauge(c, x, top, base):
    # % scale on the left plus a baseline under the bars
    c.rect(x, top, x, base + 1, fill = "#3A4A66")
    c.rect(x, base + 1, 63, base + 1, fill = "#3A4A66")
    mid = (top + base) // 2
    c.rect(x - 1, top, x, top, fill = DIM)
    c.rect(x - 1, mid, x, mid, fill = DIM)
    tiny(c, "100%", x - 3, top - 2, DIM)
    tiny(c, "50%", x - 3, mid - 2, DIM)

def hour_label(iso):
    return clock(iso).replace(" AM", "A").replace(" PM", "P")

def next12(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        zip_problem(c, err)
        return
    hours = nws_hours(loc)
    if hours == None or len(hours) < 12:
        problem(c, "NO NWS", "RETRY SOON")
        return
    hours = hours[:12]
    peak = 0
    for i in range(12):
        if pop_of(hours[i]) > pop_of(hours[peak]):
            peak = i
    top = pop_of(hours[peak])
    if top < 20:
        c.text("DRY 12 HRS", 38, 0, font = "4x5", color = DIM, align = "center")
    else:
        k = kind(hours[peak].get("shortForecast", ""))
        c.text(str(top) + "% AT " + hour_label(hours[peak]["startTime"]), 38, 0, font = "4x5", color = k[1], align = "center")
    base = 23
    gauge(c, 15, 8, base)
    for i in range(12):
        v = pop_of(hours[i])
        x = 17 + i * 4
        h = (v * 15 + 50) // 100
        if h > 0:
            col = kind(hours[i].get("shortForecast", ""))[1] if v >= 20 else "#3A4A66"
            c.rect(x, base - h + 1, x + 2, base, fill = col)
        if i % 6 == 0:
            c.text(hour_label(hours[i]["startTime"]), x, 26, font = "4x5", color = DIM)
