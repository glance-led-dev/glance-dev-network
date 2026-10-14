# Rain Watch (192x32)
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

LEGEND = [["SPRINKLES", "#A9D6F5"], ["LIGHT", "#4AA3FF"], ["STEADY", "#2ECC71"], ["HEAVY", "#F2C14E"], ["DOWNPOUR", "#FF4C4C"], ["STORMS", "#B57BFF"]]

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

def chance_word(v):
    if v >= 70:
        return "LIKELY"
    if v >= 40:
        return "CHANCE OF"
    return "SLIGHT CHANCE OF"

# ---------- page 2: next 12 hours ----------

def next12(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        problem(c, "NO SUCH " + err if err != "ZIP LOOKUP DOWN" else "ZIP LOOKUP IS DOWN", "CHECK THE ZIP IN SETTINGS")
        return
    hours = nws_hours(loc)
    if hours == None or len(hours) < 12:
        problem(c, "NWS FORECAST UNAVAILABLE", "TRYING AGAIN SHORTLY")
        return
    hours = hours[:12]
    # the wettest stretch: the peak hour and its neighbors within 10 points
    peak = 0
    for i in range(12):
        if pop_of(hours[i]) > pop_of(hours[peak]):
            peak = i
    top = pop_of(hours[peak])
    if top < 20:
        summary = ["DRY FOR THE NEXT 12 HOURS", DIM]
    else:
        a = peak
        b = peak
        for _ in range(12):
            if a > 0 and pop_of(hours[a - 1]) >= top - 10:
                a -= 1
            else:
                break
        for _ in range(12):
            if b < 11 and pop_of(hours[b + 1]) >= top - 10:
                b += 1
            else:
                break
        k = kind(hours[peak].get("shortForecast", ""))
        span = clock(hours[a]["startTime"]) if a == b else clock(hours[a]["startTime"]).split(" ")[0] + "-" + clock(hours[b]["startTime"])
        if a != b and clock(hours[a]["startTime"]).split(" ")[1] != clock(hours[b]["startTime"]).split(" ")[1]:
            span = clock(hours[a]["startTime"]) + "-" + clock(hours[b]["startTime"])
        summary = [(k[0] + " " + chance_word(top) if top >= 70 else chance_word(top) + " " + k[0]) + " " + span, k[1]]
    c.text(summary[0], 6, 1, font = "4x5", color = summary[1])
    w = 14
    gap = 1
    x0 = 6
    base = 24
    for i in range(12):
        v = pop_of(hours[i])
        x = x0 + i * (w + gap)
        h = (v * 11 + 50) // 100          # tallest bar leaves room for its % label under the summary
        c.rect(x, base, x + w - 1, base, fill = "#2A3142")
        if h > 0:
            col = kind(hours[i].get("shortForecast", ""))[1] if v >= 20 else "#3A4A66"
            c.rect(x, base - h, x + w - 1, base, fill = col)
        if v >= 30 and i == peak:
            c.text(str(v) + "%", x + w // 2, base - h - 6, font = "4x5", color = INK, align = "center")
        if i % 3 == 0:
            lab = clock(hours[i]["startTime"]).replace(" AM", "A").replace(" PM", "P")
            c.text(lab, x, 26, font = "4x5", color = DIM)

# ---------- page 3: this week ----------

def week(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        problem(c, "NO SUCH " + err if err != "ZIP LOOKUP DOWN" else "ZIP LOOKUP IS DOWN", "CHECK THE ZIP IN SETTINGS")
        return
    m = meteo(loc)
    if m == None:
        problem(c, "FORECAST UNAVAILABLE", "TRYING AGAIN SHORTLY")
        return
    d = m["daily"]
    cols = 7
    w = (c.width - 12) // cols
    for i in range(cols):
        j = PAST_DAYS + i
        if j >= len(d["time"]):
            break
        x = 6 + i * w + w // 2
        p = d["precipitation_probability_max"][j] or 0
        amt = d["precipitation_sum"][j] or 0
        code = d["weather_code"][j] or 0
        name = "TODAY" if i == 0 else DAYS[weekday(d["time"][j])]
        c.text(name, x, 1, font = "4x5", color = INK if i == 0 else DIM, align = "center")
        if code >= 95:
            col = "#B57BFF"
        elif code in (71, 73, 75, 77, 85, 86):
            col = "#E6F2FF"
        elif amt >= 0.5:
            col = "#F2C14E"
        elif amt >= 0.1:
            col = "#2ECC71"
        elif amt >= 0.02:
            col = "#4AA3FF"
        else:
            col = DIM
        c.text(str(p) + "%", x, 10, font = "5x7", color = col if p >= 20 else DIM, align = "center")
        c.text(inches(amt) if amt >= 0.01 else "DRY", x, 22, font = "4x5", color = col if amt >= 0.01 else "#3A4A66", align = "center")

# ---------- page 4: rain totals ----------

def totals(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        problem(c, "NO SUCH " + err if err != "ZIP LOOKUP DOWN" else "ZIP LOOKUP IS DOWN", "CHECK THE ZIP IN SETTINGS")
        return
    m = meteo(loc)
    if m == None:
        problem(c, "RAIN TOTALS UNAVAILABLE", "TRYING AGAIN SHORTLY")
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
    week_t = so_far + total(past[PAST_DAYS - 6:])
    month_t = so_far + total(past[PAST_DAYS - 29:])
    stats = [["TODAY SO FAR", so_far], ["LAST 7 DAYS", week_t], ["LAST 30 DAYS", month_t]]
    w = (c.width - 12) // 3
    for i in range(3):
        x = 6 + i * w + w // 2
        c.text(stats[i][0], x, 1, font = "4x5", color = DIM, align = "center")
        val = inches(stats[i][1])
        vw = c.text_width(val, "7x12") + 3 + c.text_width("IN", "4x5")
        c.text(val, x - vw // 2, 8, font = "7x12", color = CHANCE if stats[i][1] >= 0.01 else DIM)
        c.text("IN", x - vw // 2 + c.text_width(val, "7x12") + 3, 15, font = "4x5", color = DIM)
    # streak: wet days in a row, or days since the last rain (0.01 in or more)
    days = past + [so_far]
    n = len(days)
    if days[-1] >= 0.01:
        run = 0
        for k in range(n):
            if days[n - 1 - k] >= 0.01:
                run += 1
            else:
                break
        line = "RAIN TODAY" if run == 1 else "RAIN " + str(run) + " DAYS IN A ROW"
    else:
        dry = 0
        for k in range(n):
            if days[n - 1 - k] < 0.01:
                dry += 1
            else:
                break
        if dry >= n:
            line = "NO RAIN IN OVER A MONTH"
        elif dry == 1:
            line = "LAST RAIN YESTERDAY"
        else:
            line = "DAY " + str(dry) + " WITHOUT RAIN"
    c.text(line, c.width // 2, 25, font = "4x5", color = INK, align = "center")

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

def words(c, place, head, head_color, sub, sub_color = INK, note = ""):
    x = MAP + 6
    w = c.width - x - 4
    c.text(place, x, 1, font = "4x5", color = DIM)
    if note != "" and c.text_width(place, "4x5") + 8 + c.text_width(note, "4x5") <= w:
        c.text(note, c.width - 4, 1, font = "4x5", color = INK, align = "right")
    c.text(head, x, 9, font = fit(c, head, ["6x8", "5x7", "4x5"], w), color = head_color)
    c.text(sub, x, 22, font = fit(c, sub, ["5x7", "4x5"], w), color = sub_color)

def problem(c, line1, line2):
    c.text(line1, c.width // 2, 8, font = "5x7", color = WARN, align = "center")
    c.text(line2, c.width // 2, 19, font = "4x5", color = DIM, align = "center")

# ---------- pages ----------

def now(c, ctx):
    loc, err = location(ctx)
    if loc == None:
        if err == "ZIP LOOKUP DOWN":
            problem(c, "ZIP LOOKUP IS DOWN", "TRYING AGAIN SHORTLY")
        else:
            problem(c, "NO SUCH " + err, "CHECK THE ZIP IN SETTINGS")
        return
    place = loc[0] + " " + loc[1]
    r = radar(loc)
    if r == None:
        draw_map(c, None, 0, 0)
        words(c, place, "RADAR UNAVAILABLE", DIM, "TRYING AGAIN SHORTLY", DIM)
        return
    draw_map(c, r["grid"], 0, 0)
    s = r["s"]
    if s != None:
        if s["over"] != -99:
            lv = level(s["over"])
            head = lv[0] + " OVERHEAD"
        else:
            lv = level(s["dbz"])
            head = lv[0] + " " + str(int(s["d"] * 0.621 + 0.5)) + " MI " + compass(s["dx"], s["dy"])
        mv = movement(r, meteo(loc))
        words(c, place, head, lv[1], mv[1], INK, mv[0])
        return
    ch = nws_chance(loc)
    if ch != None and ch[0] >= 30:
        head = ("STORMS" if ch[2] else "SHOWERS") + " POSSIBLE"
        words(c, place, head, CHANCE, str(ch[0]) + "% CHANCE BY " + clock(ch[1]) + " - NWS")
        return
    nxt = next_rain_day(loc)
    words(c, place, "DRY - NO RAIN NEARBY", DIM, nxt if nxt != None else "RADAR CLEAR FOR 35 MI")
