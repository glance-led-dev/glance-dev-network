# Weather Unrolled - a Glance Scroll app.
#
# DESIGN. The next 24 hours drawn as one moving scene, where the Scroll's own
# motion is the timeline: later hours arrive from the right. An opening card
# answers "what is today like?" in about two seconds (town, the most serious
# alert, a weather picture, the high and low on temperature-colored tiles,
# one headline). Then three joined pages draw the day itself: the sky moves
# from night through dawn to day, clouds and rain or snow by chance, pink for
# anything slippery, slanted rain and streaks for wind, the real sun and moon
# (with tonight's phase), a small town skyline that follows the seasons and
# collects snow, and National Weather Service alerts in their official map
# colors along the hour strip. A fixed blue-to-red temperature band runs along
# the bottom, so a color always means the same temperature. Words are kept to
# a few short labels, at most three per page, most important first.
#
# DATA. Every figure comes from the National Weather Service (one source for
# wind too). No API key. Four web requests per render:
#   1. ZIP -> latitude/longitude/town      (api.zippopotam.us, cached 1 day)
#   2. Point -> NWS forecast grid + zone    (api.weather.gov/points, 1 day)
#   3. Grid forecast data                   (api.weather.gov/gridpoints, 20 min,
#                                            matching the manifest's refresh)
#   4. Active alerts for the point          (api.weather.gov/alerts, 10 min)

UA = {"User-Agent": "(weather-unrolled glance app, github.com/glance-led-dev)", "Accept": "application/geo+json"}

HOURS = 24

# ---------------------------------------------------------------- time math

def days_from_civil(y, m, d):
    """Days since 1970-01-01 for a calendar date (proleptic Gregorian)."""
    if m <= 2:
        y = y - 1
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    """[year, month, day] for days since 1970-01-01."""
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
    return [y, m, d]

def to_int(s):
    n = 0
    for ch in s.elems():
        if ch >= "0" and ch <= "9":
            n = n * 10 + (ord(ch) - 48)
    return n

def parse_iso(s):
    """Unix seconds for '2026-11-25T12:00:00+00:00' (any +/-HH:MM offset)."""
    y = to_int(s[0:4])
    mo = to_int(s[5:7])
    d = to_int(s[8:10])
    h = to_int(s[11:13])
    mi = to_int(s[14:16])
    sec = to_int(s[17:19])
    t = days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60 + sec
    tail = s[19:]
    if len(tail) >= 6 and (tail[0] == "+" or tail[0] == "-"):
        off = to_int(tail[1:3]) * 3600 + to_int(tail[4:6]) * 60
        t = t - off if tail[0] == "+" else t + off
    return t

def parse_duration(s):
    """Seconds in an ISO-8601 duration such as 'PT15H', 'P1DT3H', 'P2D'."""
    total = 0
    num = 0
    in_time = False
    for ch in s.elems():
        if ch >= "0" and ch <= "9":
            num = num * 10 + (ord(ch) - 48)
        elif ch == "T":
            in_time = True
        elif ch == "D":
            total += num * 86400
            num = 0
        elif ch == "H":
            total += num * 3600
            num = 0
        elif ch == "M":
            total += (num * 60) if in_time else (num * 30 * 86400)
            num = 0
        elif ch == "S":
            total += num
            num = 0
        elif ch == "W":
            total += num * 7 * 86400
            num = 0
    return total

# ------------------------------------------------------------ time zones

# Standard-time offsets (hours) and whether daylight saving applies, for the
# zone names the Weather Service returns. Prefix rules catch the many
# Indiana/Kentucky/North Dakota sub-zones.
TZ = {
    "America/New_York": [-5, True], "America/Detroit": [-5, True],
    "America/Chicago": [-6, True], "America/Menominee": [-6, True],
    "America/Denver": [-7, True], "America/Boise": [-7, True],
    "America/Phoenix": [-7, False],
    "America/Los_Angeles": [-8, True],
    "America/Anchorage": [-9, True], "America/Juneau": [-9, True],
    "America/Sitka": [-9, True], "America/Nome": [-9, True],
    "America/Yakutat": [-9, True], "America/Metlakatla": [-9, True],
    "America/Adak": [-10, True],
    "Pacific/Honolulu": [-10, False],
    "America/Puerto_Rico": [-4, False], "America/St_Thomas": [-4, False],
    "Pacific/Guam": [10, False], "Pacific/Saipan": [10, False],
    "Pacific/Pago_Pago": [-11, False],
}

def tz_rule(name, lon):
    if name in TZ:
        return TZ[name]
    if name.startswith("America/Indiana/"):
        if name.endswith("Knox") or name.endswith("Tell_City"):
            return [-6, True]
        return [-5, True]
    if name.startswith("America/Kentucky/"):
        return [-5, True]
    if name.startswith("America/North_Dakota/"):
        return [-6, True]
    # Unknown zone: estimate from longitude, assume U.S. daylight saving.
    return [int(math.round(lon / 15.0)), True]

def nth_sunday(y, m, n):
    d1 = days_from_civil(y, m, 1)
    wd = (d1 + 4) % 7  # 0 = Sunday
    return d1 + (7 - wd) % 7 + 7 * (n - 1)

def utc_offset(t, rule):
    """Offset in seconds for unix time t under [std_hours, uses_dst]."""
    std = rule[0] * 3600
    if not rule[1]:
        return std
    y = civil_from_days((t + std) // 86400)[0]
    start = nth_sunday(y, 3, 2) * 86400 + 2 * 3600 - std
    end = nth_sunday(y, 11, 1) * 86400 + 2 * 3600 - (std + 3600)
    if t >= start and t < end:
        return std + 3600
    return std

def clock(t, rule):
    """'4:58PM' local time for unix t."""
    local = t + utc_offset(t, rule)
    h = (local // 3600) % 24
    m = (local // 60) % 60
    hh = h % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + ("0" if m < 10 else "") + str(m) + ("AM" if h < 12 else "PM")

def hour_label(h):
    if h == 0:
        return "MIDNIGHT"
    if h == 12:
        return "NOON"
    if h < 12:
        return str(h) + "AM"
    return str(h - 12) + "PM"

def short_hour(h):
    """'6AM' style, used in labels such as BY 6AM (no words, kept short)."""
    if h == 0:
        return "12AM"
    if h == 12:
        return "12PM"
    if h < 12:
        return str(h) + "AM"
    return str(h - 12) + "PM"

# ------------------------------------------------------------------- sun

def sun_elevation(t, lat, lon):
    """Sun's height above the horizon in degrees at unix time t."""
    n = t / 86400.0 + 2440587.5 - 2451545.0
    L = math.fmod(280.460 + 0.9856474 * n, 360.0)
    g = math.radians(math.fmod(357.528 + 0.9856003 * n, 360.0))
    lam = math.radians(L + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g))
    eps = math.radians(23.439 - 0.0000004 * n)
    ra = math.degrees(math.atan2(math.cos(eps) * math.sin(lam), math.cos(lam)))
    dec = math.asin(math.sin(eps) * math.sin(lam))
    gmst = math.fmod(18.697374558 + 24.06570982441908 * n, 24.0)
    ha = math.radians(gmst * 15.0 + lon - ra)
    la = math.radians(lat)
    s = math.sin(la) * math.sin(dec) + math.cos(la) * math.cos(dec) * math.cos(ha)
    if s > 1.0:
        s = 1.0
    if s < -1.0:
        s = -1.0
    return math.degrees(math.asin(s))

def light_of(elev, morning):
    if elev >= 0.0:
        return "DAY"
    if elev >= -6.0:
        return "DAWN" if morning else "DUSK"
    return "NIGHT"

# -------------------------------------------------------------- fetching

def get_json(url, ttl):
    r = http.get(url, headers = UA, ttl_seconds = ttl)
    if r["status_code"] != 200 or not r["json"]:
        return [r["status_code"], None]
    return [r["status_code"], r["json"]]

def clean_zip(raw):
    """The ZIP as typed, tidied: spaces removed, and a ZIP+4 such as
    15213-3890 trimmed to its first five digits."""
    z = raw.replace(" ", "")
    if len(z) == 10 and z[5] == "-":
        z = z[:5]
    return z

def geocode(zip):
    """[lat, lon, town, state] or an error word: ZIP_EMPTY, ZIP_FORMAT,
    ZIP (five digits but not a real ZIP) or ZIP_DOWN (lookup unreachable)."""
    if zip == "":
        return "ZIP_EMPTY"
    if len(zip) != 5:
        return "ZIP_FORMAT"
    for ch in zip.elems():
        if ch < "0" or ch > "9":
            return "ZIP_FORMAT"
    r = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if r["status_code"] == 404:
        return "ZIP"
    if r["status_code"] != 200 or not r["json"]:
        return "ZIP_DOWN"
    places = r["json"].get("places", [])
    if not places:
        return "ZIP"
    p = places[0]
    return [float(p["latitude"]), float(p["longitude"]),
            str(p.get("place name", "")).upper(),
            str(p.get("state abbreviation", "")).upper()]

def series(props, key):
    """[[start, end, value], ...] for one grid layer."""
    out = []
    layer = props.get(key, None)
    if layer == None:
        return out
    for v in layer.get("values", []):
        vt = str(v.get("validTime", ""))
        parts = vt.split("/")
        if len(parts) != 2:
            continue
        s = parse_iso(parts[0])
        out.append([s, s + parse_duration(parts[1]), v.get("value", None)])
    return out

def value_at(ser, t):
    for row in ser:
        if row[0] <= t and t < row[1]:
            return row[2]
    return None

def spread(ser, w0, w1):
    """Per-hour amounts (mm) for an accumulation layer, spread evenly over
    each forecast block, for the 24 hours starting at w0."""
    per = [0.0] * HOURS
    for row in ser:
        v = row[2]
        if v == None or v <= 0:
            continue
        span = row[1] - row[0]
        if span <= 0:
            continue
        for i in range(HOURS):
            a = w0 + i * 3600
            b = a + 3600
            lo = a if a > row[0] else row[0]
            hi = b if b < row[1] else row[1]
            if hi > lo:
                per[i] += v * (hi - lo) / span
    return per

RAINY = ["rain", "rain_showers", "drizzle", "thunderstorms"]
SNOWY = ["snow", "snow_showers", "blowing_snow"]
ICY = ["freezing_rain", "freezing_drizzle"]

def precip_kind(wx, temp_c):
    """RAIN, SNOW, MIX, SLEET or ICE for one hour's Weather Service types."""
    rain = False
    snow = False
    sleet = False
    ice = False
    for w in wx:
        if w in ICY:
            ice = True
        elif w == "sleet":
            sleet = True
        elif w in SNOWY:
            snow = True
        elif w in RAINY:
            rain = True
    if ice:
        return "ICE"
    if sleet:
        return "SLEET"
    if snow and rain:
        return "MIX"
    if snow:
        return "SNOW"
    if rain:
        return "RAIN"
    # No type named: decide by temperature (about 34F and below is snow).
    if temp_c != None and temp_c <= 1.0:
        return "SNOW"
    return "RAIN"

def precip_level(pop):
    if pop == None or pop < 40:
        return "NONE"
    if pop < 70:
        return "SCATTERED"
    return "STEADY"

# ---------------------------------------------------------------- alerts
#
# The National Weather Service's own ranking and map colors
# (weather.gov/help-map, checked Nov 25, 2026): [priority, fill, text color].
# Lower priority number = more serious. Colors too dark to read on the Scroll
# were brightened toward white; text is black or white for contrast.
# Left out on purpose: marine-only alerts (they cover water, not the town),
# outlooks and test/administrative messages, non-weather alerts, and the
# follow-up statements that only update a warning already being shown
# (Flash Flood Statement, Severe Weather Statement, Flood Statement).
ALERTS = {
    "Tsunami Warning": [1, "#FD6347", "#FFFFFF"],
    "Tornado Warning": [2, "#FF2626", "#FFFFFF"],
    "Extreme Wind Warning": [3, "#FF8C00", "#000000"],
    "Severe Thunderstorm Warning": [4, "#FFA500", "#000000"],
    "Flash Flood Warning": [5, "#AA4646", "#FFFFFF"],
    "Shelter In Place Warning": [8, "#FA8072", "#000000"],
    "Evacuation Immediate": [9, "#7FFF00", "#000000"],
    "Civil Danger Warning": [10, "#FFB6C1", "#000000"],
    "Nuclear Power Plant Warning": [11, "#7C46A4", "#FFFFFF"],
    "Radiological Hazard Warning": [12, "#7C46A4", "#FFFFFF"],
    "Hazardous Materials Warning": [13, "#7C46A4", "#FFFFFF"],
    "Fire Warning": [14, "#A0522D", "#FFFFFF"],
    "Civil Emergency Message": [15, "#FFB6C1", "#000000"],
    "Law Enforcement Warning": [16, "#C0C0C0", "#000000"],
    "Storm Surge Warning": [17, "#B524F7", "#FFFFFF"],
    "Hurricane Warning": [19, "#E13759", "#FFFFFF"],
    "Typhoon Warning": [20, "#E13759", "#FFFFFF"],
    "Blizzard Warning": [22, "#FF4500", "#FFFFFF"],
    "Snow Squall Warning": [23, "#CF3897", "#FFFFFF"],
    "Ice Storm Warning": [24, "#AA46AA", "#FFFFFF"],
    "Winter Storm Warning": [26, "#FF69B4", "#000000"],
    "Lake Effect Snow Warning": [27, "#008B8B", "#FFFFFF"],
    "Dust Storm Warning": [28, "#FFE4C4", "#000000"],
    "Blowing Dust Warning": [29, "#FFE4C4", "#000000"],
    "High Wind Warning": [30, "#DAA520", "#000000"],
    "Tropical Storm Warning": [31, "#BD4343", "#FFFFFF"],
    "Tsunami Advisory": [33, "#D2691E", "#FFFFFF"],
    "Tsunami Watch": [34, "#FF00FF", "#FFFFFF"],
    "Avalanche Warning": [35, "#1E90FF", "#FFFFFF"],
    "Earthquake Warning": [36, "#9C6036", "#FFFFFF"],
    "Volcano Warning": [37, "#4E6969", "#FFFFFF"],
    "Ashfall Warning": [38, "#A9A9A9", "#000000"],
    "Flood Warning": [39, "#00FF00", "#FFFFFF"],
    "Coastal Flood Warning": [40, "#228B22", "#FFFFFF"],
    "Lakeshore Flood Warning": [41, "#228B22", "#FFFFFF"],
    "Ashfall Advisory": [42, "#696969", "#FFFFFF"],
    "High Surf Warning": [43, "#228B22", "#FFFFFF"],
    "Extreme Heat Warning": [44, "#CF3897", "#FFFFFF"],
    "Tornado Watch": [45, "#FFFF00", "#000000"],
    "Severe Thunderstorm Watch": [46, "#DB7093", "#FFFFFF"],
    "Flash Flood Watch": [47, "#2E8B57", "#FFFFFF"],
    "Extreme Cold Warning": [50, "#6161FF", "#FFFFFF"],
    "Freeze Warning": [51, "#635A9C", "#FFFFFF"],
    "Red Flag Warning": [52, "#FF1493", "#FFFFFF"],
    "Storm Surge Watch": [53, "#DB7FF7", "#000000"],
    "Hurricane Watch": [54, "#FF00FF", "#FFFFFF"],
    "Typhoon Watch": [56, "#FF00FF", "#FFFFFF"],
    "Tropical Storm Watch": [57, "#F08080", "#000000"],
    "Tropical Cyclone Local Statement": [59, "#FFE4B5", "#000000"],
    "Winter Weather Advisory": [60, "#7B68EE", "#FFFFFF"],
    "Avalanche Advisory": [61, "#CD853F", "#FFFFFF"],
    "Cold Weather Advisory": [62, "#AFEEEE", "#000000"],
    "Heat Advisory": [63, "#FF7F50", "#000000"],
    "Flood Advisory": [64, "#00FF7F", "#000000"],
    "Coastal Flood Advisory": [65, "#7CFC00", "#000000"],
    "Lakeshore Flood Advisory": [66, "#7CFC00", "#000000"],
    "High Surf Advisory": [67, "#BA55D3", "#FFFFFF"],
    "Dense Fog Advisory": [68, "#708090", "#FFFFFF"],
    "Dense Smoke Advisory": [69, "#F0E68C", "#000000"],
    "Dust Advisory": [73, "#BDB76B", "#000000"],
    "Blowing Dust Advisory": [74, "#BDB76B", "#000000"],
    "Lake Wind Advisory": [75, "#D2B48C", "#000000"],
    "Wind Advisory": [76, "#D2B48C", "#000000"],
    "Frost Advisory": [77, "#6495ED", "#FFFFFF"],
    "Freezing Fog Advisory": [78, "#269393", "#FFFFFF"],
    "Local Area Emergency": [81, "#C0C0C0", "#000000"],
    "Winter Storm Watch": [82, "#4682B4", "#FFFFFF"],
    "Rip Current Statement": [83, "#40E0D0", "#000000"],
    "Beach Hazards Statement": [84, "#40E0D0", "#000000"],
    "Avalanche Watch": [86, "#F4A460", "#000000"],
    "Flood Watch": [89, "#2E8B57", "#FFFFFF"],
    "Coastal Flood Watch": [90, "#66CDAA", "#000000"],
    "Lakeshore Flood Watch": [91, "#66CDAA", "#000000"],
    "High Wind Watch": [92, "#B8860B", "#FFFFFF"],
    "Extreme Heat Watch": [93, "#A34646", "#FFFFFF"],
    "Extreme Cold Watch": [94, "#5F9EA0", "#FFFFFF"],
    "Freeze Watch": [95, "#00FFFF", "#000000"],
    "Fire Weather Watch": [96, "#FFDEAD", "#000000"],
    "Extreme Fire Danger": [97, "#E9967A", "#000000"],
    "Coastal Flood Statement": [99, "#6B8E23", "#FFFFFF"],
    "Lakeshore Flood Statement": [100, "#6B8E23", "#FFFFFF"],
    "Special Weather Statement": [101, "#FFE4B5", "#000000"],
    "Air Quality Alert": [103, "#808080", "#FFFFFF"],
    "Air Stagnation Advisory": [104, "#808080", "#FFFFFF"],
}

def alert_style(ev):
    """[priority, fill, text] for an event name, with a fallback for any new
    alert type the Weather Service adds later."""
    if ev in ALERTS:
        return ALERTS[ev]
    if ev.endswith("Warning"):
        return [150, "#FF4040", "#FFFFFF"]
    if ev.endswith("Watch"):
        return [160, "#FFD040", "#000000"]
    return [170, "#E8A040", "#000000"]

def alert_name(ev):
    """Uppercase display name. "T-STORM" only in Severe Thunderstorm alerts."""
    return ev.upper().replace("SEVERE THUNDERSTORM", "SEVERE T-STORM")

def alerts(lat, lon, w0):
    """Active alerts for the point, most serious first. Each is a dict with
    event, name, priority, fill, text, start, end (unix) and hours: a list of
    24 booleans marking the hours the alert is in effect."""
    url = "https://api.weather.gov/alerts/active?point=%s,%s" % (
        str(math.round(lat * 10000) / 10000.0), str(math.round(lon * 10000) / 10000.0))
    r = get_json(url, 600)
    if r[1] == None:
        return []
    merged = {}
    for f in r[1].get("features", []):
        pr = f.get("properties", {})
        ev = str(pr.get("event", ""))
        if ev == "" or (ev not in ALERTS and is_excluded(ev)):
            continue
        if str(pr.get("status", "Actual")) != "Actual":
            continue
        if str(pr.get("messageType", "")) == "Cancel":
            continue
        st = pr.get("onset", None) or pr.get("effective", None)
        en = pr.get("ends", None) or pr.get("expires", None)
        s0 = parse_iso(str(st)) if st else w0
        e0 = parse_iso(str(en)) if en else w0 + HOURS * 3600
        # Only alerts in effect at some point in the 24 hours shown. One that
        # starts later (say, an advisory for the day after tomorrow) waits.
        if e0 <= w0 or s0 >= w0 + HOURS * 3600:
            continue
        if ev in merged:
            m = merged[ev]
            m["start"] = s0 if s0 < m["start"] else m["start"]
            m["end"] = e0 if e0 > m["end"] else m["end"]
        else:
            sty = alert_style(ev)
            merged[ev] = {"event": ev, "name": alert_name(ev), "priority": sty[0],
                          "fill": sty[1], "text": sty[2], "start": s0, "end": e0}
    out = sorted(merged.values(), key = lambda m: m["priority"])
    for m in out:
        hrs = []
        for i in range(HOURS):
            a = w0 + i * 3600
            hrs.append(m["start"] < a + 3600 and m["end"] > a)
        m["hours"] = hrs
    return out

# Anything not in the table above that is clearly not a land weather alert.
EXCLUDED_WORDS = ["Marine", "Small Craft", "Gale", "Hazardous Seas", "Freezing Spray",
                  "Outlook", "Test", "Administrative", "Short Term Forecast",
                  "Child Abduction", "Blue Alert", "Telephone", "Hurricane Force Wind",
                  "Low Water", "Brisk Wind"]

def is_excluded(ev):
    if ev in ["Storm Warning", "Storm Watch", "Special Marine Warning",
              "Flash Flood Statement", "Severe Weather Statement", "Flood Statement"]:
        return True
    for w in EXCLUDED_WORDS:
        if w in ev:
            return True
    return False

# ------------------------------------------------------------------ moon
#
# Lunar position from the main terms of the standard lunar theory (Meeus,
# Astronomical Algorithms, ch. 47): rise and set within a few minutes.

def moon_alt(t, lat, lon):
    """Moon's apparent height above the horizon in degrees at unix time t."""
    d = t / 86400.0 + 2440587.5 - 2451545.0
    rad = math.pi / 180.0
    L = rad * (218.316 + 13.176396 * d)
    M = rad * (134.963 + 13.064993 * d)
    F = rad * (93.272 + 13.229350 * d)
    D = rad * (297.850 + 12.190749 * d)   # elongation from the sun
    Ms = rad * (357.529 + 0.98560028 * d)  # sun's mean anomaly
    l = L + rad * (6.289 * math.sin(M) + 1.274 * math.sin(2 * D - M) +
                   0.658 * math.sin(2 * D) + 0.214 * math.sin(2 * M) -
                   0.186 * math.sin(Ms) - 0.114 * math.sin(2 * F))
    b = rad * (5.128 * math.sin(F) + 0.281 * math.sin(M + F) +
               0.278 * math.sin(M - F) + 0.173 * math.sin(2 * D - F))
    dist = 385001.0 - 20905.0 * math.cos(M) - 3699.0 * math.cos(2 * D - M) - 2956.0 * math.cos(2 * D)
    e = rad * 23.4397
    ra = math.atan2(math.sin(l) * math.cos(e) - math.tan(b) * math.sin(e), math.cos(l))
    dec = math.asin(math.sin(b) * math.cos(e) + math.cos(b) * math.sin(e) * math.sin(l))
    H = rad * (280.16 + 360.9856235 * d + lon) - ra
    phi = rad * lat
    h = math.asin(math.sin(phi) * math.sin(dec) + math.cos(phi) * math.cos(dec) * math.cos(H))
    # The moon is close enough that where you stand shifts it (parallax).
    h = h - math.asin(6378.14 / dist) * math.cos(h)
    # Air bends light near the horizon (refraction).
    hh = h if h > 0 else 0.0
    h = h + 0.0002967 / math.tan(hh + 0.00312536 / (hh + 0.08901179))
    return h / rad

def moon_phase(t):
    """[age_days, illuminated_fraction, waxing] for unix time t."""
    syn = 29.530588853
    jd = t / 86400.0 + 2440587.5
    age = math.fmod(jd - 2451550.1, syn)
    if age < 0:
        age += syn
    frac = (1.0 - math.cos(2.0 * math.pi * age / syn)) / 2.0
    return [age, frac, age < syn / 2.0]

PHASE_NAMES = ["NEW MOON", "WAXING CRESCENT", "FIRST QUARTER", "WAXING GIBBOUS",
               "FULL MOON", "WANING GIBBOUS", "LAST QUARTER", "WANING CRESCENT"]

def phase_index(age):
    """0-7 (new, waxing crescent, first quarter ... waning crescent), matching
    the eight hand-drawn moon images."""
    return int(math.floor(age / 29.530588853 * 8.0 + 0.5)) % 8

def crossings(fn, lat, lon, w0, h0, step):
    """[[unix, rising], ...] when fn's height crosses h0 in the 24 hours."""
    out = []
    prev = fn(w0, lat, lon) - h0
    for k in range(1, HOURS * 3600 // step + 1):
        t = w0 + k * step
        cur = fn(t, lat, lon) - h0
        if (prev < 0) != (cur < 0):
            frac = prev / (prev - cur)
            out.append([int(t - step + frac * step), cur > prev])
        prev = cur
    return out

def forecast(ctx):
    """Everything the drawing needs, or {"error": WORD}.

    Error words: ZIP_EMPTY, ZIP_FORMAT, ZIP (not a real U.S. ZIP), ZIP_DOWN
    (the ZIP lookup could not be reached), OFFLINE (the Weather Service could
    not be reached), COVERAGE (the Weather Service has no forecast there),
    LATE (the forecast it sent does not reach the coming hours)."""
    zip = clean_zip(str(ctx.inputs.get("zip", "15213")).strip())
    g = geocode(zip)
    if type(g) == "string":
        return {"error": g, "zip": zip}
    lat = g[0]
    lon = g[1]
    pt = get_json("https://api.weather.gov/points/%s,%s" % (
        str(math.round(lat * 10000) / 10000.0), str(math.round(lon * 10000) / 10000.0)), 86400)
    if pt[1] == None:
        return {"error": "COVERAGE" if pt[0] == 404 else "OFFLINE", "zip": zip}
    pp = pt[1].get("properties", {})
    grid_url = pp.get("forecastGridData", None)
    if grid_url == None:
        return {"error": "COVERAGE", "zip": zip}
    gd = get_json(grid_url, 1200)
    if gd[1] == None:
        return {"error": "OFFLINE", "zip": zip}
    props = gd[1].get("properties", {})

    rule = tz_rule(str(pp.get("timeZone", "")), lon)
    now = ctx.now.unix
    w0 = now - now % 3600
    w1 = w0 + HOURS * 3600

    temp = series(props, "temperature")
    pop = series(props, "probabilityOfPrecipitation")
    gust = series(props, "windGust")
    wind = series(props, "windSpeed")
    sky = series(props, "skyCover")
    feel = series(props, "apparentTemperature")
    snow_hr = spread(series(props, "snowfallAmount"), w0, w1)
    ice_hr = spread(series(props, "iceAccumulation"), w0, w1)
    wxs = []
    for row in series(props, "weather"):
        kinds = []
        for w in (row[2] or []):
            k = w.get("weather", None)
            if k != None and k not in kinds:
                kinds.append(str(k))
        wxs.append([row[0], row[1], kinds])

    hours = []
    snow_run = 0.0
    ice_run = 0.0
    for i in range(HOURS):
        t = w0 + i * 3600
        local = t + utc_offset(t, rule)
        lh = (local // 3600) % 24
        tc = value_at(temp, t)
        p = value_at(pop, t)
        gk = value_at(gust, t)
        if gk == None:
            gk = value_at(wind, t)
        wx = value_at(wxs, t) or []
        fl = value_at(feel, t)
        elev = sun_elevation(t + 1800, lat, lon)
        snow_run += snow_hr[i]
        ice_run += ice_hr[i]
        hours.append({
            "t": t,
            "hour": lh,
            "label": hour_label(lh),
            "temp_c": tc,
            "pop": p if p != None else 0,
            "level": precip_level(p),
            "kind": precip_kind(wx, tc),
            "wx": wx,
            "gust_mph": int(math.round(gk * 0.621371)) if gk != None else 0,
            "sky": value_at(sky, t) or 0,
            "feels_c": fl if fl != None else tc,
            "thunder": "thunderstorms" in wx,
            "fog": ("fog" in wx) or ("freezing_fog" in wx),
            "moon": moon_alt(t + 1800, lat, lon),
            "sun": elev,
            "light": light_of(elev, lh < 12),
            "snow_mm": snow_hr[i],
            "ice_mm": ice_hr[i],
            "snow_total_mm": snow_run,
            "ice_total_mm": ice_run,
        })

    # Missing temperatures (rare) borrow the nearest known hour.
    # If the forecast it sent does not reach most of the coming hours (the
    # Weather Service's systems sometimes stall), say so rather than draw a
    # made-up day.
    known = [h["temp_c"] for h in hours if h["temp_c"] != None]
    if len(known) < HOURS // 2 or (hours[0]["temp_c"] == None and hours[1]["temp_c"] == None):
        return {"error": "LATE", "zip": zip}
    last = known[0]
    for h in hours:
        if h["temp_c"] == None:
            h["temp_c"] = last
        last = h["temp_c"]

    # When the last snow / ice of the day falls, for "BY 6AM" labels.
    snow_end = None
    ice_end = None
    for h in hours:
        if h["snow_mm"] > 0.05:
            snow_end = (h["hour"] + 1) % 24
        if h["ice_mm"] > 0.05:
            ice_end = (h["hour"] + 1) % 24

    peak = 0
    peak_i = 0
    for i in range(HOURS):
        if hours[i]["gust_mph"] > peak:
            peak = hours[i]["gust_mph"]
            peak_i = i

    temps = [h["temp_c"] for h in hours]
    hi_i = 0
    lo_i = 0
    for i in range(HOURS):
        if temps[i] > temps[hi_i]:
            hi_i = i
        if temps[i] < temps[lo_i]:
            lo_i = i

    # Feels-like: the hour where wind chill or heat differs most from the
    # real temperature. Shown only if it is at least 5 F (3 C) different.
    feels_i = None
    best = 0.0
    for i in range(HOURS):
        diff = hours[i]["feels_c"] - hours[i]["temp_c"]
        if diff < 0:
            diff = -diff
        if diff > best:
            best = diff
            feels_i = i
    if best * 9.0 / 5.0 < 5.0:
        feels_i = None

    # Sunrise/sunset (-0.833 degrees: the sun's edge, with refraction) and
    # moonrise/moonset (+0.133 degrees), found in 10-minute steps.
    suns = crossings(sun_elevation, lat, lon, w0, -0.833, 600)
    moons = crossings(moon_alt, lat, lon, w0, 0.133, 600)
    mp = moon_phase(w0 + 12 * 3600)

    town = str(ctx.inputs.get("town", "")).strip().upper()
    al = alerts(lat, lon, w0)
    # When the Weather Service last updated this forecast. Normally within
    # the last hour or two; older than 6 hours, the card says so.
    updated = None
    ut = props.get("updateTime", None)
    if ut != None and len(str(ut)) >= 19:
        updated = parse_iso(str(ut))
    return {
        "error": None,
        "updated": updated,
        "late": updated != None and now - updated > 6 * 3600,
        "town": town if town != "" else g[2],
        "state": g[3],
        "zip": zip,
        "lat": lat,
        "lon": lon,
        "rule": rule,
        "hours": hours,
        "hi_c": temps[hi_i],
        "lo_c": temps[lo_i],
        # Tags sit on the band at the hour; none at the very first or last
        # hour, where the NOW temperature or the page edge already covers it.
        "hi_i": hi_i if hi_i > 0 and hi_i < HOURS - 1 else None,
        "lo_i": lo_i if lo_i > 0 and lo_i < HOURS - 1 else None,
        "feels_i": feels_i,
        "snow_mm": hours[HOURS - 1]["snow_total_mm"],
        "ice_mm": hours[HOURS - 1]["ice_total_mm"],
        "snow_end": snow_end,
        "ice_end": ice_end,
        "peak_gust": peak,
        "peak_gust_i": peak_i,
        "alerts": al,
        "sun_events": suns,
        "moon_events": moons,
        "moon_age": mp[0],
        "moon_frac": mp[1],
        "moon_phase": phase_index(mp[0]),
        "moon_name": PHASE_NAMES[phase_index(mp[0])],
    }

# ----------------------------------------------------------------- units

def celsius(ctx):
    return str(ctx.inputs.get("units", "F")).upper().startswith("C")

def temp_num(ctx, tc):
    """Whole-degree temperature in the chosen unit. The font has no degree
    sign, so the drawing code adds a small pixel ring after the number."""
    if celsius(ctx):
        return int(math.round(tc))
    return int(math.round(tc * 9.0 / 5.0 + 32.0))

def temp_str(ctx, tc):
    return str(temp_num(ctx, tc))

def snow_str(ctx, mm):
    """Snow total: inches (or centimeters in Celsius); under 1 in is A COATING."""
    inches = mm / 25.4
    if inches < 1.0:
        return "A COATING"
    if celsius(ctx):
        return str(int(math.round(mm / 10.0))) + " CM"
    return str(int(math.round(inches))) + "\""

def ice_str(ctx, mm):
    if celsius(ctx):
        return "ICE " + str(int(math.round(mm))) + " MM"
    tenths = math.round(mm / 25.4 * 10.0) / 10.0
    if tenths < 0.1:
        tenths = 0.1
    s = str(tenths)
    if s.startswith("0"):
        s = s[1:]
    return "ICE " + s + "\""

# ======================================================== the scroll
#
# Three 192-pixel pages form one continuous 576-pixel strip: 24 pixels per
# hour, 8 hours per page. Rows: 0-6 hour strip, 7-23 sky, 24-31 temperature
# band. Every drawing step works in "global" x (0-575) and is shifted onto
# whichever page it lands on, so things that cross a page edge join cleanly.

PX_PER_HOUR = 24
PAGE_W = 192
SKY_TOP = 7
SKY_BOT = 23
BAND_TOP = 24
BG = (11, 12, 18)
END_X = 565          # last lit column of the whole strip (padded right end)
FADE_W = 16          # columns that fade to dark before END_X
SKY_BUDGET = 2400    # most drawing steps the sky may use on one page

def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v

def mix(a, b, f):
    f = clamp(f, 0.0, 1.0)
    return (a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f)

def q565(c):
    """Snap to the Scroll's real color depth so neighboring columns that look
    the same merge into one drawing step."""
    r = int(clamp(c[0], 0, 255)) // 8 * 8
    g = int(clamp(c[1], 0, 255)) // 4 * 4
    b = int(clamp(c[2], 0, 255)) // 8 * 8
    return (r, g, b)

def at_x(fc, key, gx):
    """An hourly value smoothly blended to column gx (hour centers at +12)."""
    u = (gx - PX_PER_HOUR / 2) / float(PX_PER_HOUR)
    i = int(math.floor(u))
    f = u - i
    i0 = clamp(i, 0, HOURS - 1)
    i1 = clamp(i + 1, 0, HOURS - 1)
    return fc["hours"][i0][key] * (1.0 - f) + fc["hours"][i1][key] * f

def fade(gx):
    """1.0 across the strip, easing to 0.0 at the padded right end."""
    if gx > END_X:
        return 0.0
    if gx > END_X - FADE_W:
        return (END_X - gx + 1) / float(FADE_W + 1)
    return 1.0

def dim_to_bg(c, k):
    return mix(BG, c, k)

# ----------------------------------------------------------------- sky color

NIGHT_TOP = (4, 6, 22)
NIGHT_BOT = (16, 22, 52)
TWI_TOP = (30, 34, 92)
TWI_BOT = (104, 62, 112)
GLOW_TOP = (52, 72, 152)
GLOW_BOT = (236, 124, 68)
DAY_TOP = (32, 84, 196)
DAY_BOT = (124, 172, 234)
GRAY_DAY_TOP = (104, 112, 128)
GRAY_DAY_BOT = (150, 156, 168)
GRAY_NIGHT_TOP = (14, 15, 22)
GRAY_NIGHT_BOT = (30, 32, 40)

def sky_rgb(elev, cover, wet, f):
    """Sky color at sun height `elev` (degrees), cloud cover 0-100, wet 0-1,
    and height f (0 = top of the sky, 1 = horizon)."""
    if elev <= -12.0:
        c = mix(NIGHT_TOP, NIGHT_BOT, f)
    elif elev <= -4.0:
        c = mix(mix(NIGHT_TOP, NIGHT_BOT, f), mix(TWI_TOP, TWI_BOT, f), (elev + 12.0) / 8.0)
    elif elev <= 3.0:
        # The low glow hugs the horizon: strongest in the bottom rows.
        g = mix(GLOW_TOP, GLOW_BOT, f * f)
        c = mix(mix(TWI_TOP, TWI_BOT, f), g, (elev + 4.0) / 7.0)
    elif elev <= 10.0:
        c = mix(mix(GLOW_TOP, GLOW_BOT, f * f), mix(DAY_TOP, DAY_BOT, f), (elev - 3.0) / 7.0)
    else:
        c = mix(DAY_TOP, DAY_BOT, f)
    # Cloud cover grays the sky; the light level decides which gray.
    light = clamp((elev + 6.0) / 12.0, 0.0, 1.0)
    gray = mix(mix(GRAY_NIGHT_TOP, GRAY_NIGHT_BOT, f), mix(GRAY_DAY_TOP, GRAY_DAY_BOT, f), light)
    k = clamp((cover - 45.0) / 55.0, 0.0, 1.0) * 0.85
    c = mix(c, gray, k)
    # Rain or snow on the way darkens it a little more.
    return mix(c, (c[0] * 0.6, c[1] * 0.6, c[2] * 0.66), wet)

def runs(c, off, y0, y1, colors):
    """Draw one row band as runs of equal color (one step per run)."""
    start = 0
    for x in range(1, PAGE_W + 1):
        if x == PAGE_W or colors[x] != colors[start]:
            if colors[start] != BG:
                c.rect(start, y0, x - 1, y1, fill = colors[start])
            start = x

def count_runs(colors):
    n = 0
    for x in range(PAGE_W):
        if (x == 0 or colors[x] != colors[x - 1]) and colors[x] != BG:
            n += 1
    return n

def draw_sky(c, fc, off):
    """One row at a time for a smooth gradient. If a page would need too
    many drawing steps (a twilight page with shifting clouds), pairs of rows
    share a color instead, which keeps every page well under the limit."""
    cols = []
    for x in range(PAGE_W):
        gx = off + x
        cols.append([at_x(fc, "sun", gx), at_x(fc, "sky", gx),
                     at_x(fc, "wet", gx), fade(gx)])
    n = SKY_BOT - SKY_TOP
    rows = []
    total = 0
    for y in range(SKY_TOP, SKY_BOT + 1):
        f = (y - SKY_TOP) / float(n)
        row = []
        for v in cols:
            if v[3] <= 0.0:
                row.append(BG)
            else:
                row.append(q565(dim_to_bg(sky_rgb(v[0], v[1], v[2], f), v[3])))
        rows.append(row)
        total += count_runs(row)
    step = 1 if total <= SKY_BUDGET else 2
    for j in range(0, len(rows), step):
        y0 = SKY_TOP + j
        runs(c, off, y0, min(y0 + step - 1, SKY_BOT), rows[j])

# -------------------------------------------------------------------- clouds

CLOUD_SIZES = {"WISP": [10, 3], "SMALL": [12, 4], "MEDIUM": [18, 5], "LARGE": [26, 6]}

# Every cloud image spelled out, so the catalog checker can match each
# drawing to its file.
CLOUD_FILES = {
    "WISP_DAY": "CLOUD_WISP_DAY.png",
    "WISP_GRAY": "CLOUD_WISP_GRAY.png",
    "WISP_DUSK": "CLOUD_WISP_DUSK.png",
    "WISP_NIGHT": "CLOUD_WISP_NIGHT.png",
    "WISP_STORM": "CLOUD_WISP_STORM.png",
    "SMALL_DAY": "CLOUD_SMALL_DAY.png",
    "SMALL_GRAY": "CLOUD_SMALL_GRAY.png",
    "SMALL_DUSK": "CLOUD_SMALL_DUSK.png",
    "SMALL_NIGHT": "CLOUD_SMALL_NIGHT.png",
    "SMALL_STORM": "CLOUD_SMALL_STORM.png",
    "MEDIUM_DAY": "CLOUD_MEDIUM_DAY.png",
    "MEDIUM_GRAY": "CLOUD_MEDIUM_GRAY.png",
    "MEDIUM_DUSK": "CLOUD_MEDIUM_DUSK.png",
    "MEDIUM_NIGHT": "CLOUD_MEDIUM_NIGHT.png",
    "MEDIUM_STORM": "CLOUD_MEDIUM_STORM.png",
    "LARGE_DAY": "CLOUD_LARGE_DAY.png",
    "LARGE_GRAY": "CLOUD_LARGE_GRAY.png",
    "LARGE_DUSK": "CLOUD_LARGE_DUSK.png",
    "LARGE_NIGHT": "CLOUD_LARGE_NIGHT.png",
    "LARGE_STORM": "CLOUD_LARGE_STORM.png",
}

def rand(n):
    """Repeatable pseudo-random number from n, so a cloud drawn for 3 PM
    stays put as the hours slide by instead of jumping every refresh."""
    v = (n * 1103515245 + 12345) % 2147483648
    v = (v * 1103515245 + 12345) % 2147483648
    return v // 65536

def cloud_tone(elev, wet, storm):
    if elev <= -5.0:
        return "NIGHT"
    if storm:
        return "STORM"
    if elev <= 4.0:
        return "DUSK"
    if wet:
        return "GRAY"
    return "DAY"

def draw_clouds(c, fc, off):
    for i in range(HOURS):
        h = fc["hours"][i]
        s = h["sky"]
        if h["level"] != "NONE" or h["thunder"]:
            s = max(s, 80)      # rain and snow always fall from clouds
        if s < 15:
            continue
        hour_no = h["t"] // 3600
        for k in range(3):
            r = rand(hour_no * 5 + k)
            if r % 100 >= s - k * 35:
                continue
            if s < 40:
                shape = "WISP" if r % 3 == 0 else "SMALL"
            elif s < 75:
                shape = ["SMALL", "MEDIUM", "MEDIUM", "WISP"][(r // 7) % 4]
            else:
                shape = ["MEDIUM", "LARGE", "LARGE", "SMALL"][(r // 7) % 4]
            w = CLOUD_SIZES[shape][0]
            ht = CLOUD_SIZES[shape][1]
            gx = i * PX_PER_HOUR + (r // 100) % PX_PER_HOUR - w // 2
            gy = SKY_TOP + 1 + (r // 2400) % (9 - ht // 2)
            # Stay clear of the faded right end.
            if gx + w > END_X - FADE_W or gx < 0:
                continue
            if gx + w <= off or gx >= off + PAGE_W:
                continue
            tone = cloud_tone(at_x(fc, "sun", gx + w // 2), h["pop"] >= 40 or s >= 85, h["thunder"])
            c.image(CLOUD_FILES[shape + "_" + tone], gx - off, gy)


# ======================================================= weather
#
# Rain, snow and the slippery kinds fall in two layers: a far layer of dim
# single dots behind the clouds and a near layer of bright streaks and
# flakes in front. Pink always means slippery (mix, sleet, freezing rain).
# Wind tilts falling rain at 25 mph and more at 35; streaks appear from 30.
# Every position comes from the clock hour, so nothing jumps on refresh.

RAIN_NEAR = (150, 200, 255)
SNOW_NEAR = (236, 244, 255)
PINK_NEAR = (255, 120, 200)
PRECIP_TOP = SKY_TOP + 4
SLIPPERY = ["MIX", "SLEET", "ICE"]

FLAKE = [[0, 1, 0], [1, 1, 1], [0, 1, 0]]
PELLET = [[1, 1], [1, 1]]
GUST_SNOW = [[1, 0], [0, 1]]

def slant(gust):
    if gust >= 35:
        return 2
    if gust >= 25:
        return 1
    return 0

def far_color(near, sky):
    return q565(mix(sky, near, 0.45))

def counts(level):
    """[near, far] items per hour."""
    if level == "STEADY":
        return [7, 9]
    if level == "SCATTERED":
        return [3, 4]
    return [0, 0]

def visible(gx, w, off):
    return gx + w > off and gx < off + PAGE_W and gx >= 0 and gx + w <= END_X - FADE_W

def precip_spots(fc, i, n, salt):
    """n repeatable [x, y] spots inside hour i."""
    h = fc["hours"][i]
    out = []
    hour_no = h["t"] // 3600
    for k in range(n):
        r = rand(hour_no * 97 + k * 13 + salt)
        x = i * PX_PER_HOUR + (k * PX_PER_HOUR) // max(n, 1) + r % (PX_PER_HOUR // max(n, 1) + 1)
        y = PRECIP_TOP + (r // 64) % (SKY_BOT - PRECIP_TOP - 1)
        out.append([x, y, r])
    return out

def sky_at(fc, gx, y):
    f = (y - SKY_TOP) / float(SKY_BOT - SKY_TOP)
    return sky_rgb(at_x(fc, "sun", gx), at_x(fc, "sky", gx), at_x(fc, "wet", gx), f)

def draw_far_precip(c, fc, off):
    for i in range(HOURS):
        h = fc["hours"][i]
        n = counts(h["level"])[1]
        if n == 0:
            continue
        for sp in precip_spots(fc, i, n, 7):
            gx = sp[0]
            if not visible(gx, 1, off):
                continue
            kind = h["kind"]
            if kind == "SNOW" or (kind == "MIX" and sp[2] % 2 == 0):
                near = SNOW_NEAR
            elif kind in SLIPPERY:
                near = PINK_NEAR
            else:
                near = RAIN_NEAR
            col = far_color(near, sky_at(fc, gx, sp[1]))
            if kind == "SNOW" or kind == "SLEET" or kind == "MIX":
                c.pixel(gx - off, sp[1], col)
            else:
                c.line(gx - off, sp[1], gx - off + (1 if slant(h["gust_mph"]) > 0 else 0), sp[1] + 1, col)

def draw_near_precip(c, fc, off):
    for i in range(HOURS):
        h = fc["hours"][i]
        n = counts(h["level"])[0]
        if n == 0:
            continue
        lean = slant(h["gust_mph"])
        kind = h["kind"]
        for sp in precip_spots(fc, i, n, 3):
            gx = sp[0]
            y = sp[1]
            pick = sp[2] % 2
            if kind == "SNOW" or (kind == "MIX" and pick == 0):
                if not visible(gx - 1, 3, off) or y + 2 > SKY_BOT:
                    continue
                if lean > 0 and sp[2] % 3 == 0:
                    c.bitmap(GUST_SNOW, gx - off, y, SNOW_NEAR)
                else:
                    c.bitmap(FLAKE, gx - 1 - off, y, SNOW_NEAR)
            elif kind == "SLEET" or kind == "MIX":
                if not visible(gx, 2, off) or y + 1 > SKY_BOT:
                    continue
                c.bitmap(PELLET, gx - off, y, PINK_NEAR)
            else:
                # Rain, or pink freezing rain: a 3-pixel streak, tilted by wind.
                col = PINK_NEAR if kind == "ICE" else RAIN_NEAR
                if not visible(gx, lean + 1, off) or y + 2 > SKY_BOT:
                    continue
                c.line(gx - off, y, gx - off + lean, y + 2, col)

def draw_wind(c, fc, off):
    """Horizontal streaks for gusts of 30 mph or more; more at 40."""
    for i in range(HOURS):
        h = fc["hours"][i]
        g = h["gust_mph"]
        if g < 30:
            continue
        n = 2 if g < 40 else 3
        hour_no = h["t"] // 3600
        for k in range(n):
            r = rand(hour_no * 31 + k * 7 + 5)
            ln = 5 + r % 5
            gx = i * PX_PER_HOUR + (k * PX_PER_HOUR) // n + (r // 8) % 6
            y = SKY_TOP + 3 + (r // 64) % 12
            if not visible(gx, ln + 4, off):
                continue
            col = q565(mix(sky_at(fc, gx, y), (220, 228, 240), 0.55))
            c.line(gx - off, y, gx - off + ln - 1, y, col)
            c.line(gx - off + ln + 1, y, gx - off + ln + 2, y, col)

def draw_lightning(c, fc, off):
    """One bolt in most thunderstorm hours, dropping from the cloud base."""
    for i in range(HOURS):
        h = fc["hours"][i]
        if not h["thunder"]:
            continue
        r = rand(h["t"] // 3600 * 17 + 11)
        if r % 4 == 3:
            continue
        gx = i * PX_PER_HOUR + 4 + r % 14
        if not visible(gx, 6, off):
            continue
        c.image(BOLT_FILES[r // 4 % 2], gx - off, SKY_BOT - 11)

BOLT_FILES = ["BOLT_A.png", "BOLT_B.png"]

FOG_FILES = {"DAY_A": "FOG_DAY_A.png", "DAY_B": "FOG_DAY_B.png",
             "NIGHT_A": "FOG_NIGHT_A.png", "NIGHT_B": "FOG_NIGHT_B.png"}

def draw_fog(c, fc, off):
    """A low, lumpy bank along the bottom of the sky in each foggy hour.
    Only the bottom rows reach the image edges, so neighboring foggy hours
    join into one bank and the first and last hours taper off."""
    for i in range(HOURS):
        h = fc["hours"][i]
        if not h["fog"]:
            continue
        gx = i * PX_PER_HOUR
        if not visible(gx, PX_PER_HOUR, off):
            continue
        r = rand(h["t"] // 3600 * 23 + 2)
        tone = "DAY" if h["sun"] > -3.0 else "NIGHT"
        c.image(FOG_FILES[tone + ("_A" if r % 2 == 0 else "_B")], gx - off, SKY_BOT - 6)


# ================================================= sky and land
#
# The sun at its real height for the season, the moon in its real phase and
# position, stars on clear nights, and a hand-drawn skyline along the bottom
# of the sky. Each skyline piece is pixel art below, drawn as one-color
# layers (one drawing step per color) so the colors can follow the light,
# the season and the snow.

GROUND_Y = SKY_BOT        # row 23: the ground line
LAND_BOT = SKY_BOT - 1    # skyline pieces stand on the ground line

# '#' body, 'L' leaves, 't' trunk, 'w' window. Snow caps are worked out
# automatically from the top edge of each body.
ART = {
    "HILL": [
        "........########..........",
        "....################......",
        "..######################..",
        "##########################",
    ],
    "PINE": [
        "..#..",
        "..#..",
        ".###.",
        ".###.",
        "#####",
        "..t..",
    ],
    "HOUSE": [
        "....#....",
        "...###...",
        "..#####..",
        ".#######.",
        ".#w###w#.",
        ".#######.",
    ],
    "BARN": [
        "...#####...",
        "..#######..",
        ".#########.",
        "###########",
        ".####w####.",
        ".###www###.",
        ".###www###.",
    ],
    "CHURCH": [
        ".....#.....",
        ".....#.....",
        "....###....",
        "....###....",
        "....#w#....",
        "...#####...",
        "..#######..",
        ".#########.",
        ".##w#w#w##.",
        ".#########.",
    ],
    "TOWER": [
        "....#....",
        "..#####..",
        ".#######.",
        ".#######.",
        ".#######.",
        "..#...#..",
        "..##.##..",
        "..#.#.#..",
        ".#.....#.",
    ],
    "TREE": [
        "..LLL..",
        ".LLLLL.",
        "LLLLLLL",
        "LLLLLLL",
        ".LLLLL.",
        "...t...",
        "...t...",
    ],
    "ROUND": [
        ".LLL.",
        "LLLLL",
        "LLLLL",
        ".LLL.",
        "..t..",
        "..t..",
    ],
    "BARE": [
        "#.#.#.#",
        ".#.#.#.",
        "#.###.#",
        ".#.#.#.",
        "...#...",
        "...#...",
        "...#...",
    ],
    "BARE_SMALL": [
        "#.#.#",
        ".###.",
        "..#..",
        "..#..",
        "..#..",
        "..#..",
    ],
}

def layer(rows, chars):
    out = []
    for r in rows:
        out.append([1 if ch in chars else 0 for ch in r.elems()])
    return out

def cap_layer(rows):
    """The top pixel of every column of the body: where snow settles."""
    h = len(rows)
    w = len(rows[0])
    out = [[0] * w for _ in range(h)]
    for x in range(w):
        for y in range(h):
            if rows[y][x] in "#L":
                out[y][x] = 1
                break
    return out

def build_sprites():
    s = {}
    for name in ART:
        rows = ART[name]
        s[name] = {
            "w": len(rows[0]),
            "h": len(rows),
            "body": layer(rows, "#w"),
            "leaf": layer(rows, "L"),
            "trunk": layer(rows, "t"),
            "win": layer(rows, "w"),
            "cap": cap_layer(rows),
            "has_leaf": "L" in "".join(rows),
            "has_win": "w" in "".join(rows),
            "has_trunk": "t" in "".join(rows),
        }
    return s

SPRITES = build_sprites()

# Far hills sit behind; the rest stand in front. Fixed places along the
# 576-pixel strip, all ending before the faded right end.
HILLS = [0, 74, 150, 228, 300, 378, 452, 520]
LANDMARKS = [
    [6, "PINE"], [20, "HOUSE"], [38, "TREE"], [54, "PINE"], [61, "PINE"],
    [80, "BARN"], [100, "ROUND"], [116, "CHURCH"], [142, "TREE"], [160, "HOUSE"],
    [178, "PINE"], [194, "TOWER"], [214, "ROUND"], [228, "HOUSE"], [246, "TREE"],
    [266, "PINE"], [273, "PINE"], [290, "HOUSE"], [310, "TREE"], [328, "BARN"],
    [350, "ROUND"], [366, "PINE"], [384, "HOUSE"], [402, "TREE"], [422, "CHURCH"],
    [446, "PINE"], [460, "HOUSE"], [478, "TREE"], [498, "TOWER"], [516, "PINE"],
    [528, "ROUND"],
]

NIGHT_LAND = (5, 6, 12)
DAY_COLORS = {
    "HILL": (30, 44, 56),
    "GROUND": (26, 32, 38),
    "PINE": (20, 56, 40),
    "HOUSE": (40, 44, 60),
    "BARN": (84, 34, 30),
    "CHURCH": (54, 54, 68),
    "TOWER": (58, 62, 76),
    "TRUNK": (46, 36, 30),
    "BARE": (44, 40, 40),
}
SEASON_LEAVES = {
    "SPRING": [(70, 128, 52), (86, 140, 60)],
    "SUMMER": [(28, 78, 36), (36, 90, 40)],
    "FALL": [(160, 72, 24), (176, 120, 28), (140, 40, 30)],
    "MIXED": [(28, 78, 36), (36, 90, 40)],
}
WINDOW_LIT = (252, 204, 84)
SNOW_DAY = (236, 240, 250)
SNOW_NIGHT = (116, 124, 150)

def season(fc):
    """Leaf season from the local date and place.

    Warm places (south of 31 degrees, and Hawaii) keep their leaves. The
    low desert Southwest and Southern California (Phoenix, Tucson, Las
    Vegas, Los Angeles, San Diego) mix evergreens like citrus and olive with
    mesquite, which goes bare for a few weeks after the first hard freeze:
    there the leafy trees stay green all winter and the mesquite-like trees
    go bare from about Dec 20 to mid-March, with no fall color. Everywhere
    else follows a four-season year."""
    t = fc["hours"][0]["t"]
    d = civil_from_days((t + utc_offset(t, fc["rule"])) // 86400)
    m = d[1]
    day = d[2]
    if fc["lat"] < 31.0 or fc["state"] == "HI":
        return "SUMMER"
    if fc["lat"] < 36.5 and fc["lon"] < -109.0:
        if (m == 12 and day >= 20) or m == 1 or m == 2 or (m == 3 and day <= 15):
            return "MIXED"
        if m == 3 or m == 4:
            return "SPRING"
        return "SUMMER"
    if m == 4 or m == 5:
        return "SPRING"
    if m >= 6 and m <= 9:
        return "SUMMER"
    if m == 10 or (m == 11 and day <= 15):
        return "FALL"
    return "WINTER"

def light_at(fc, gx):
    return clamp((at_x(fc, "sun", gx) + 6.0) / 12.0, 0.0, 1.0)

def land_color(fc, gx, day, depth):
    """A skyline color at column gx: the day color in daylight, a dark
    silhouette at night; far hills also take on a little of the sky."""
    c = mix(NIGHT_LAND, day, light_at(fc, gx))
    if depth > 0.0:
        c = mix(c, sky_at(fc, gx, GROUND_Y - 2), depth)
    return q565(c)

def snow_at(fc, gx):
    i = clamp(gx // PX_PER_HOUR, 0, HOURS - 1)
    return fc["hours"][i]["snow_total_mm"]

def snow_color(fc, gx):
    return q565(mix(SNOW_NIGHT, SNOW_DAY, light_at(fc, gx)))

def windows_on(fc, gx, salt):
    """Lights come on at dusk, most go off around 11 PM, a few come back on
    before dawn, and they go out once it is light."""
    if at_x(fc, "sun", gx) > -2.0:
        return False
    i = clamp(gx // PX_PER_HOUR, 0, HOURS - 1)
    hr = fc["hours"][i]["hour"]
    r = rand(salt * 41 + 9)
    if hr >= 16 and hr <= 22:
        return True
    if hr >= 5 and hr <= 8:
        return r % 2 == 0
    return r % 5 == 0

def draw_piece(c, fc, off, gx, name, salt, sea):
    sp = SPRITES[name]
    w = sp["w"]
    if gx + w <= off or gx >= off + PAGE_W:
        return
    x = gx - off
    y = LAND_BOT - sp["h"] + 1
    mid = gx + w // 2
    if name == "HILL":
        c.bitmap(sp["body"], x, y, land_color(fc, mid, DAY_COLORS["HILL"], 0.25))
    elif sp["has_leaf"]:
        leaves = SEASON_LEAVES[sea]
        c.bitmap(sp["trunk"], x, y, land_color(fc, mid, DAY_COLORS["TRUNK"], 0.0))
        c.bitmap(sp["leaf"], x, y, land_color(fc, mid, leaves[salt % len(leaves)], 0.0))
    else:
        c.bitmap(sp["body"], x, y, land_color(fc, mid, DAY_COLORS.get(name, DAY_COLORS["BARE"]), 0.0))
        if sp["has_trunk"]:
            c.bitmap(sp["trunk"], x, y, land_color(fc, mid, DAY_COLORS["TRUNK"], 0.0))
    if sp["has_win"] and windows_on(fc, mid, salt):
        c.bitmap(sp["win"], x, y, WINDOW_LIT)
    # Snow settles on roofs, pines and hilltops once half an inch has fallen.
    if snow_at(fc, mid) >= 12.0 and (name != "TREE" and name != "ROUND"):
        c.bitmap(sp["cap"], x, y, snow_color(fc, mid))

def draw_land(c, fc, off):
    sea = season(fc)
    for k in range(len(HILLS)):
        draw_piece(c, fc, off, HILLS[k], "HILL", k, sea)
    for k in range(len(LANDMARKS)):
        p = LANDMARKS[k]
        name = p[1]
        if (sea == "WINTER" or sea == "MIXED") and name == "TREE":
            name = "BARE"
        elif sea == "WINTER" and name == "ROUND":
            name = "BARE_SMALL"
        draw_piece(c, fc, off, p[0], name, k, sea)
    # The ground line, white once snow covers it (two rows from 2 inches).
    ground = []
    deep = []
    for x in range(PAGE_W):
        gx = off + x
        k = fade(gx)
        if k <= 0.0:
            ground.append(BG)
            deep.append(BG)
            continue
        sn = snow_at(fc, gx)
        col = snow_color(fc, gx) if sn >= 2.5 else land_color(fc, gx, DAY_COLORS["GROUND"], 0.0)
        ground.append(q565(dim_to_bg(col, k)))
        deep.append(q565(dim_to_bg(snow_color(fc, gx), k)) if sn >= 50.0 else BG)
    runs(c, off, GROUND_Y, GROUND_Y, ground)
    runs(c, off, GROUND_Y - 1, GROUND_Y - 1, deep)

# ---------------------------------------------------------------- sun

SUN_CORE = [
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
]
SUN_RAYS = [
    [0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0],
]
SUN_HALF = [
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
]

def height_row(elev):
    """Row for the center of the sun or moon: near the skyline when low,
    near the top of the sky when high (75 degrees or more)."""
    return int(clamp(19.0 - clamp(elev, 0.0, 75.0) / 75.0 * 8.0, 11.0, 19.0))

def draw_sun(c, fc, off):
    # The sun at its highest point in the window, at that real height.
    best = -1
    for i in range(HOURS):
        if fc["hours"][i]["sun"] > 2.0 and (best < 0 or fc["hours"][i]["sun"] > fc["hours"][best]["sun"]):
            best = i
    if best >= 0:
        h = fc["hours"][best]
        gx = clamp(best * PX_PER_HOUR + 12, 8, END_X - FADE_W - 8)
        cy = height_row(h["sun"])
        if h["sky"] < 90 and visible(gx - 4, 9, off):
            x = gx - off
            c.bitmap(SUN_RAYS, x - 4, cy - 4, (248, 160, 40))
            c.bitmap(SUN_CORE, x - 2, cy - 2, (255, 214, 64))
            c.pixel(x - 1, cy - 1, (255, 244, 180))

def draw_sunrise(c, fc, off):
    """A half sun peeking over the skyline at sunrise."""
    for e in fc["sun_events"]:
        if not e[1]:
            continue
        gx = (e[0] - fc["hours"][0]["t"]) * PX_PER_HOUR // 3600
        if gx < 6 or gx > END_X - FADE_W - 6:
            continue
        if visible(gx - 2, 5, off):
            c.bitmap(SUN_HALF, gx - 2 - off, LAND_BOT - 1, (250, 150, 52))

# --------------------------------------------------------------- moon

def moon_bitmaps(age):
    """Lit and dark parts of a 7-pixel moon for a moon `age` days old. The
    lit side is on the right while it grows, as seen from the U.S."""
    th = 2.0 * math.pi * age / 29.530589
    lit = []
    dark = []
    for y in range(7):
        lr = []
        dr = []
        dy = (y - 3.0) / 3.5
        for x in range(7):
            dx = (x - 3.0) / 3.5
            if dx * dx + dy * dy > 1.0:
                lr.append(0)
                dr.append(0)
                continue
            k = math.sqrt(max(0.0, 1.0 - dy * dy))
            if th <= math.pi:
                on = dx > k * math.cos(th)
            else:
                on = dx < -k * math.cos(th)
            lr.append(1 if on else 0)
            dr.append(0 if on else 1)
        lit.append(lr)
        dark.append(dr)
    return [lit, dark]

def draw_moon(c, fc, off):
    """The moon at its highest point while the sky is dark."""
    if fc["moon_frac"] < 0.03:
        return None
    best = -1
    for i in range(HOURS):
        h = fc["hours"][i]
        if h["sun"] < -6.0 and h["moon"] > 8.0 and (best < 0 or h["moon"] > fc["hours"][best]["moon"]):
            best = i
    if best < 0:
        return None
    h = fc["hours"][best]
    gx = clamp(best * PX_PER_HOUR + 12, 8, END_X - FADE_W - 8)
    cy = height_row(h["moon"])
    if h["sky"] >= 90:
        return [gx, cy]
    if visible(gx - 3, 7, off):
        bm = moon_bitmaps(fc["moon_age"])
        c.bitmap(bm[1], gx - 3 - off, cy - 3, (36, 40, 58))
        c.bitmap(bm[0], gx - 3 - off, cy - 3, (244, 238, 204))
    return [gx, cy]

# -------------------------------------------------------------- stars

STAR_PLUS = [[0, 1, 0], [1, 1, 1], [0, 1, 0]]

def draw_stars(c, fc, off, moon):
    for i in range(HOURS):
        h = fc["hours"][i]
        if h["sun"] > -8.0 or h["sky"] >= 50 or h["level"] != "NONE" or h["fog"]:
            continue
        n = 3 if h["sky"] < 20 else 1
        for k in range(n):
            r = rand(h["t"] // 3600 * 53 + k * 3 + 1)
            gx = i * PX_PER_HOUR + (k * PX_PER_HOUR) // n + r % (PX_PER_HOUR // n)
            y = SKY_TOP + 1 + (r // 32) % 7
            if moon != None and gx > moon[0] - 6 and gx < moon[0] + 6 and y > moon[1] - 6 and y < moon[1] + 6:
                continue
            if not visible(gx - 1, 3, off):
                continue
            if (r // 512) % 5 == 0:
                c.bitmap(STAR_PLUS, gx - 1 - off, y, (190, 200, 240))
            else:
                c.pixel(gx - off, y, (120, 130, 170) if (r // 256) % 2 == 0 else (200, 206, 236))


# ================================================== words on it
#
# Alert bands color the hour strip for exactly the hours each alert is in
# effect (the most serious one wins where they overlap). Labels sit in the
# sky on dark boxes with a 1-pixel gap around the text, at most three per
# page, chosen in this order: alerts, snow and ice totals, storms and
# slippery weather, feels-like, the peak gust, then fog. High and low tags
# sit on the temperature band.

HEXV = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
        "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15}

def hex_rgb(s):
    s = s.upper().lstrip("#")
    return (HEXV[s[0]] * 16 + HEXV[s[1]], HEXV[s[2]] * 16 + HEXV[s[3]], HEXV[s[4]] * 16 + HEXV[s[5]])

def alert_at(fc, i):
    """The most serious alert in effect during hour i, or None."""
    for m in fc["alerts"]:
        if m["hours"][i]:
            return m
    return None

def draw_alert_bands(c, fc, off):
    row = []
    for x in range(PAGE_W):
        gx = off + x
        k = fade(gx)
        m = alert_at(fc, clamp(gx // PX_PER_HOUR, 0, HOURS - 1))
        if m == None or k <= 0.0:
            row.append(BG)
        else:
            row.append(q565(dim_to_bg(hex_rgb(m["fill"]), k)))
    runs(c, off, 0, 6, row)

def strip_ink(fc, i, normal):
    m = alert_at(fc, i)
    if m == None:
        return normal
    return hex_rgb(m["text"])

def time_word(t, rule):
    """'8PM', or '7:45PM' when not on the hour."""
    s = clock(t, rule)
    if s.find(":00") > 0:
        s = s.replace(":00", "")
    return s

# ------------------------------------------------------------- labels

# A wide warning triangle with an exclamation point cut out of it, wider
# than any letter so it never reads as an "A".
WARN = [
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 0, 1, 0, 0],
    [0, 1, 1, 0, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 0, 1, 1, 1],
]
LABEL_ROWS = [SKY_TOP + 1, SKY_TOP + 8]     # box tops: rows 8 and 15
LABEL_H = 7
SLIP_INK = (255, 120, 200)
WHITE = (240, 242, 248)
GUST_INK = (248, 184, 64)
COLD_INK = (120, 210, 255)
HOT_INK = (255, 150, 90)

def label_width(c, lab):
    w = c.text_width(lab["text"], "4x5") + 2
    if lab.get("warn", False):
        w += 10
    if lab.get("degree", False):
        w += 4
    return w

def overlaps(placed, x0, x1, y):
    for p in placed:
        if p[2] == y and x0 <= p[1] + 4 and x1 >= p[0] - 4:
            return True
    return False

def plan_labels(c, fc, ctx):
    """Every label that could be shown, most important first. Each has a
    text, an hour to sit at, colors and a preferred row."""
    out = []
    H = fc["hours"]
    rule = fc["rule"]
    # 1. Alerts: the card names the most serious; the scroll names the next.
    if len(fc["alerts"]) >= 2:
        m = fc["alerts"][1]
        first = 0
        for i in range(HOURS):
            if m["hours"][i]:
                first = i
                break
        txt = m["name"]
        if m["end"] < H[0]["t"] + HOURS * 3600:
            txt += " UNTIL " + time_word(m["end"], rule)
        out.append({"text": txt, "i": first, "row": 0, "fill": hex_rgb(m["fill"]),
                    "ink": hex_rgb(m["text"]), "warn": True,
                    "more": len(fc["alerts"]) - 2, "short": m["name"]})
    # 2. Snow and ice totals, where they stop.
    if fc["snow_mm"] >= 2.5:
        last = 0
        for i in range(HOURS):
            if H[i]["snow_mm"] > 0.05:
                last = i
        txt = snow_str(ctx, fc["snow_mm"])
        if fc["snow_mm"] >= 25.4 and fc["snow_end"] != None:
            txt += " BY " + short_hour(fc["snow_end"])
        out.append({"text": txt, "i": last, "row": 1, "ink": WHITE, "end": True})
    if fc["ice_mm"] >= 0.25:
        last = 0
        for i in range(HOURS):
            if H[i]["ice_mm"] > 0.05:
                last = i
        out.append({"text": ice_str(ctx, fc["ice_mm"]), "i": last, "row": 1, "ink": SLIP_INK, "end": True})
    # 3. Storms and the start of snow or slippery weather.
    words = []
    for i in range(HOURS):
        if H[i]["thunder"] and "STORMS" not in words:
            words.append("STORMS")
            out.append({"text": "STORMS", "i": i, "row": 1, "ink": WHITE})
        if H[i]["level"] != "NONE":
            k = H[i]["kind"]
            if k != "RAIN" and k not in words:
                words.append(k)
                out.append({"text": k, "i": i, "row": 1, "ink": SLIP_INK if k in SLIPPERY else WHITE})
    # 4. Feels-like, when it is at least 5 F off the real temperature.
    if fc["feels_i"] != None:
        h = H[fc["feels_i"]]
        out.append({"text": "FEELS " + temp_str(ctx, h["feels_c"]), "i": fc["feels_i"], "row": 1,
                    "ink": COLD_INK if h["feels_c"] < h["temp_c"] else HOT_INK, "degree": True})
    # 5. The single peak gust.
    if fc["peak_gust"] >= 30:
        out.append({"text": "GUSTS " + (str(int(math.round(fc["peak_gust"] * 1.609))) if celsius(ctx) else str(fc["peak_gust"])), "i": fc["peak_gust_i"], "row": 0, "ink": GUST_INK})
    # 6. Fog.
    for i in range(HOURS):
        if H[i]["fog"]:
            out.append({"text": "FOG", "i": i, "row": 1, "ink": WHITE})
            break
    return out

def place_labels(c, fc, ctx):
    """Decide where every label goes on the whole strip (the same answer on
    every page, so the pages agree)."""
    placed = []
    per_page = [0, 0, 0]
    right = END_X - FADE_W
    for lab in plan_labels(c, fc, ctx):
        # A long alert label drops UNTIL, then +MORE, before giving up.
        tries = [lab]
        if lab.get("warn", False):
            tries.append(dict(lab, text = lab["short"]))
        done = False
        for cand in tries:
            w = label_width(c, cand)
            more = ""
            if cand.get("more", 0) > 0:
                more = "+" + str(cand["more"]) + " MORE"
            mw = (c.text_width(more, "4x5") + 3) if more else 0
            base = cand["i"] * PX_PER_HOUR + 2
            if cand.get("end", False):
                base = cand["i"] * PX_PER_HOUR + PX_PER_HOUR - w
            if base < 2:
                base = 2
            if base + w + mw > right:
                base = right - w - mw
            x0 = clear_of_joins(base, w + mw)
            x1 = x0 + w + mw - 1
            if x0 < 0 or x1 > right:
                continue
            pg = x0 // PAGE_W
            if (x1 // PAGE_W) != pg or per_page[pg] >= 3:
                continue
            for r in [cand["row"], 1 - cand["row"]]:
                y = LABEL_ROWS[r]
                if not overlaps(placed, x0, x1, y):
                    placed.append([x0, x1, y, cand, w, more])
                    per_page[pg] += 1
                    done = True
                    break
            if done:
                break
    return placed

def draw_labels(c, placed, off):
    for p in placed:
        x0 = p[0]
        if x0 < off or x0 >= off + PAGE_W:
            continue
        lab = p[3]
        w = p[4]
        y = p[2]
        x = x0 - off
        fill = lab.get("fill", BG)
        # A label pushed just past a page join starts at column 1; fill
        # column 0 too so no stray sliver of sky (or a snowflake) shows.
        c.rect(0 if x == 1 else x, y, x + w - 1, y + LABEL_H - 1, fill = fill)
        tx = x + 1
        if lab.get("warn", False):
            c.bitmap(WARN, tx, y + 1, lab["ink"])
            tx += 10
        c.text(lab["text"], tx, y + 1, font = "4x5", color = lab["ink"])
        if lab.get("degree", False):
            c.bitmap(DEGREE, tx + c.text_width(lab["text"], "4x5") + 1, y + 1, lab["ink"])
        if p[5]:
            mx = x + w + 1
            mw = c.text_width(p[5], "4x5") + 2
            c.rect(mx, y, mx + mw - 1, y + LABEL_H - 1, fill = BG)
            c.text(p[5], mx + 1, y + 1, font = "4x5", color = WHITE)

# ------------------------------------------------- high and low tags

ARROW_UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1]]
ARROW_DOWN = [[1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]

def plan_tags(c, fc, ctx):
    """[x0, x1, hour, is_high] for the high and low tags on the band."""
    out = []
    for pair in [[fc["hi_i"], True], [fc["lo_i"], False]]:
        i = pair[0]
        if i == None:
            continue
        s = temp_str(ctx, fc["hours"][i]["temp_c"])
        w = 6 + c.text_width(s, "5x5b") + 4 + 2
        x0 = i * PX_PER_HOUR + PX_PER_HOUR // 2 - w // 2
        # Keep clear of the NOW temperature, which always shows.
        now_end = 2 + c.text_width(temp_str(ctx, fc["hours"][0]["temp_c"]), "5x5b") + 4
        x0 = clamp(x0, now_end + 4, END_X - FADE_W - w)
        x0 = clear_of_joins(x0, w)
        out.append([x0, x0 + w - 1, i, pair[1], s])
    return out

def brighten(c0):
    return q565(mix(c0, (255, 255, 255), 0.25))

def draw_tags(c, fc, tags, off):
    for t in tags:
        if t[0] < off or t[0] >= off + PAGE_W:
            continue
        x = t[0] - off
        ink = brighten(temp_rgb(fc["hours"][t[2]]["temp_c"]))
        c.rect(x, BAND_TOP, x + t[1] - t[0], 31, fill = BG)
        c.bitmap(ARROW_UP if t[3] else ARROW_DOWN, x + 1, BAND_TOP + 2, ink)
        c.text(t[4], x + 7, BAND_TOP + 1, font = "5x5b", color = ink)
        c.bitmap(DEGREE, x + 7 + c.text_width(t[4], "5x5b") + 1, BAND_TOP + 1, ink)

# --------------------------------------------------------------- hour strip

STRIP_TEXT = (196, 200, 214)
TICK = (112, 118, 140)
NOW_TEXT = (240, 208, 72)

def clear_of_joins(gx, w):
    """The Scroll cannot draw text that starts off the left edge of a page
    (it slides it back on screen), so a word that would cross a page join
    moves just past the join instead."""
    for b in [PAGE_W, 2 * PAGE_W]:
        if gx < b and gx + w > b:
            return b + 1
    return gx

def labeled_hours(fc):
    """Hours that get a label: NOW, then every hour divisible by 3. A label
    too close to NOW, or into the padded end, is skipped."""
    out = [0]
    for i in range(1, HOURS):
        if fc["hours"][i]["hour"] % 3 == 0 and i * PX_PER_HOUR >= 40 and i * PX_PER_HOUR + 40 <= END_X - FADE_W:
            out.append(i)
    return out

def draw_strip(c, fc, off):
    # A small dot under every hour, a tick and label every third hour.
    for i in range(1, HOURS):
        gx = i * PX_PER_HOUR
        if gx >= off and gx < off + PAGE_W and gx <= END_X - FADE_W:
            c.pixel(gx - off, 6, strip_ink(fc, i, TICK))
    for i in labeled_hours(fc):
        gx = i * PX_PER_HOUR
        word = "NOW" if i == 0 else fc["hours"][i]["label"]
        w = c.text_width(word, "4x5")
        if gx >= off and gx < off + PAGE_W and i > 0:
            c.line(gx - off, 0, gx - off, 6, strip_ink(fc, i, TICK))
        tx = clear_of_joins(gx + 2, w)
        if tx >= off and tx < off + PAGE_W:
            ink = strip_ink(fc, clamp(tx // PX_PER_HOUR, 0, HOURS - 1), NOW_TEXT if i == 0 else STRIP_TEXT)
            c.text(word, tx - off, 1, font = "4x5", color = ink)

# ---------------------------------------------------- temperature band

# Fixed scale in Fahrenheit (Celsius users see the same colors).
TEMP_STOPS = [
    [-10, (112, 64, 184)],
    [10, (60, 70, 210)],
    [25, (40, 104, 228)],
    [32, (56, 150, 236)],
    [40, (52, 196, 208)],
    [48, (64, 204, 104)],
    [56, (168, 220, 64)],
    [64, (240, 220, 56)],
    [74, (248, 172, 44)],
    [84, (240, 112, 32)],
    [94, (224, 48, 32)],
    [104, (176, 24, 48)],
]

def temp_rgb(tc):
    tf = tc * 9.0 / 5.0 + 32.0
    if tf <= TEMP_STOPS[0][0]:
        return TEMP_STOPS[0][1]
    for j in range(1, len(TEMP_STOPS)):
        if tf <= TEMP_STOPS[j][0]:
            a = TEMP_STOPS[j - 1]
            b = TEMP_STOPS[j]
            return mix(a[1], b[1], (tf - a[0]) / float(b[0] - a[0]))
    return TEMP_STOPS[-1][1]

def is_light(c):
    return c[0] * 0.299 + c[1] * 0.587 + c[2] * 0.114 > 140

DEGREE = [[1, 1, 1], [1, 0, 1], [1, 1, 1]]

def draw_band(c, fc, ctx, off, tags):
    row = []
    for x in range(PAGE_W):
        gx = off + x
        k = fade(gx)
        row.append(BG if k <= 0.0 else q565(dim_to_bg(temp_rgb(at_x(fc, "temp_c", gx)), k)))
    runs(c, off, BAND_TOP, 31, row)
    for i in labeled_hours(fc):
        s = temp_str(ctx, fc["hours"][i]["temp_c"])
        w = c.text_width(s, "5x5b") + 4
        gx = clear_of_joins(i * PX_PER_HOUR + 2, w)
        if gx < off or gx >= off + PAGE_W:
            continue
        hidden = False
        for t in tags:
            if gx <= t[1] + 3 and gx + w >= t[0] - 3:
                hidden = True
        if hidden:
            continue
        ink = (0, 0, 0) if is_light(temp_rgb(at_x(fc, "temp_c", gx + w // 2))) else (255, 255, 255)
        c.text(s, gx - off, 25, font = "5x5b", color = ink)
        c.bitmap(DEGREE, gx - off + w - 3, 25, ink)

# ===================================================== the opening card
#
# The first page answers "what are the next 24 hours like?" in about two
# seconds: the town (and the most serious alert) on the top strip, a weather
# picture, the high and low on temperature-colored tiles, and one headline
# with a short second line.

CARD_X = 8          # the card is the app's left edge, so content starts at 8
CARD_R = 190        # last column used for text (the scroll follows on the right)
CARD_TOP = (12, 16, 36)
CARD_BOT = (22, 30, 70)
DRY_INK = (128, 228, 112)
RAIN_INK = (128, 196, 255)
STORM_INK = (255, 224, 64)
ICON_FILES = {
    "SUN": "ICON_SUN.png", "PARTLY": "ICON_PARTLY.png", "CLOUDY": "ICON_CLOUDY.png",
    "RAIN": "ICON_RAIN.png", "SNOW": "ICON_SNOW.png", "ICE": "ICON_ICE.png",
    "SLEET": "ICON_SLEET.png", "MIX": "ICON_MIX.png", "STORM": "ICON_STORM.png",
    "FOG": "ICON_FOG.png", "WIND": "ICON_WIND.png",
}
BIG_UP = [[0, 0, 0, 1, 0, 0, 0], [0, 0, 1, 1, 1, 0, 0], [0, 1, 1, 1, 1, 1, 0], [1, 1, 1, 1, 1, 1, 1]]
BIG_DOWN = [BIG_UP[3], BIG_UP[2], BIG_UP[1], BIG_UP[0]]
BIG_DEG = [[0, 1, 1, 0], [1, 0, 0, 1], [1, 0, 0, 1], [0, 1, 1, 0]]
HEAD_FONTS = [["9x12_bold", 12], ["8x10", 10], ["6x8", 8], ["5x7", 7], ["4x5", 5]]
INK_BLACK = (0, 0, 0)

def grow(m):
    """The bitmap one pixel bigger on every side: its black outline."""
    h = len(m)
    w = len(m[0])
    out = []
    for y in range(h + 2):
        row = []
        for x in range(w + 2):
            on = 0
            for dy in [-1, 0, 1]:
                for dx in [-1, 0, 1]:
                    yy = y - 1 + dy
                    xx = x - 1 + dx
                    if yy >= 0 and yy < h and xx >= 0 and xx < w and m[yy][xx]:
                        on = 1
            row.append(on)
        out.append(row)
    return out

BIG_UP_EDGE = grow(BIG_UP)
BIG_DOWN_EDGE = grow(BIG_DOWN)
BIG_DEG_EDGE = grow(BIG_DEG)

def fit(c, s, room, font):
    """s, shortened from the end until it fits in room pixels."""
    if c.text_width(s, font) <= room:
        return s
    for n in range(len(s) - 1, 0, -1):
        t = s[:n].rstrip(" ")
        if c.text_width(t, font) <= room:
            return t
    return ""

def gust_str(ctx, mph):
    if celsius(ctx):
        return str(int(math.round(mph * 1.609))) + " KM/H"
    return str(mph) + " MPH"

def span_words(fc, idx):
    """When something happens: ALL DAY, UNTIL 9AM, FROM 3PM or 3PM TO 9PM."""
    H = fc["hours"]
    a = idx[0]
    b = idx[-1]
    end_h = (H[b]["hour"] + 1) % 24
    if a == 0 and b == HOURS - 1:
        return "ALL DAY"
    if a == 0:
        return "UNTIL " + hour_label(end_h)
    if b == HOURS - 1:
        return "FROM " + hour_label(H[a]["hour"])
    return hour_label(H[a]["hour"]) + " TO " + hour_label(end_h)

def sky_words(fc):
    """How cloudy the daylight hours are, with the matching picture."""
    day = [h["sky"] for h in fc["hours"] if h["sun"] > 0]
    if not day:
        day = [h["sky"] for h in fc["hours"]]
    avg = 0
    for v in day:
        avg += v
    avg = avg / len(day)
    if avg < 25:
        return ["SUN", "SUNNY"]
    if avg < 50:
        return ["PARTLY", "MOSTLY SUNNY"]
    if avg < 80:
        return ["PARTLY", "MOSTLY CLOUDY"]
    return ["CLOUDY", "CLOUDY"]

def card_headline(ctx, fc):
    """[picture, headline, headline color, second line, second line has a
    degree sign]. Order: storms, snow total, ice, other wet weather, wind,
    then dry (with fog, feels-like or sky as the second line)."""
    H = fc["hours"]
    wet = [i for i in range(HOURS) if H[i]["level"] != "NONE"]
    storm = [i for i in wet if H[i]["thunder"]]
    if storm:
        return ["STORM", "STORMS", STORM_INK, span_words(fc, storm), False]
    if fc["snow_mm"] >= 25.4:
        sub = ""
        if fc["snow_end"] != None:
            sub = "BY " + hour_label(fc["snow_end"])
        return ["SNOW", "SNOW " + snow_str(ctx, fc["snow_mm"]), WHITE, sub, False]
    if fc["ice_mm"] >= 0.25:
        ice = [i for i in range(HOURS) if H[i]["ice_mm"] > 0.05]
        return ["ICE", ice_str(ctx, fc["ice_mm"]), SLIP_INK, span_words(fc, ice) if ice else "", False]
    if wet:
        kinds = [H[i]["kind"] for i in wet]
        if "ICE" in kinds:
            return ["ICE", "FREEZING RAIN", SLIP_INK, span_words(fc, [i for i in wet if H[i]["kind"] == "ICE"]), False]
        if "SLEET" in kinds:
            return ["SLEET", "SLEET", SLIP_INK, span_words(fc, [i for i in wet if H[i]["kind"] == "SLEET"]), False]
        if "MIX" in kinds:
            return ["MIX", "WINTRY MIX", SLIP_INK, span_words(fc, [i for i in wet if H[i]["kind"] == "MIX"]), False]
        snowy = [i for i in wet if H[i]["kind"] == "SNOW"]
        if len(snowy) * 2 >= len(wet):
            sub = "A COATING" if fc["snow_mm"] > 1.0 else span_words(fc, snowy)
            return ["SNOW", "SNOW", WHITE, sub, False]
        steady = len([i for i in wet if H[i]["level"] == "STEADY"]) > 0
        return ["RAIN", "RAIN" if steady else "SHOWERS", RAIN_INK, span_words(fc, wet), False]
    if fc["peak_gust"] >= 30:
        return ["WIND", "WINDY", GUST_INK, "GUSTS TO " + gust_str(ctx, fc["peak_gust"]), False]
    sk = sky_words(fc)
    fogs = [i for i in range(HOURS) if H[i]["fog"]]
    if fogs:
        return [sk[0], "DRY ALL DAY", DRY_INK, "FOG " + span_words(fc, fogs), False]
    if fc["feels_i"] != None:
        return [sk[0], "DRY ALL DAY", DRY_INK, "FEELS LIKE " + temp_str(ctx, H[fc["feels_i"]]["feels_c"]), True]
    if fc["peak_gust"] >= 20:
        return [sk[0], "DRY ALL DAY", DRY_INK, "GUSTS TO " + gust_str(ctx, fc["peak_gust"]), False]
    return [sk[0], "DRY ALL DAY", DRY_INK, sk[1], False]

def draw_card_strip(c, fc):
    town = fc["town"].upper()
    if fc["alerts"]:
        m = fc["alerts"][0]
        ink = hex_rgb(m["text"])
        c.rect(CARD_X - 2, 0, PAGE_W - 1, 6, fill = q565(hex_rgb(m["fill"])))
        c.bitmap(WARN, CARD_X, 1, ink)
        tx = CARD_X + 10
        name = fit(c, m["name"], CARD_R - tx + 1, "4x5")
        nw = c.text_width(name, "4x5")
        c.text(name, CARD_R - nw + 1, 1, font = "4x5", color = ink)
        # The town shows only when it fits whole; a cut-off name could read
        # as a different place. (A shorter name can be set in the settings.)
        if c.text_width(town, "4x5") <= CARD_R - nw - 8 - tx + 1:
            c.text(town, tx, 1, font = "4x5", color = ink)
        return
    right = "NEXT 24 HOURS"
    right_ink = TICK
    if fc["late"]:
        # An old forecast is still shown, but the card says how old.
        right = "FORECAST FROM " + time_word(fc["updated"], fc["rule"])
        right_ink = ERR_INK
    rw = c.text_width(right, "4x5")
    room = CARD_R - rw - 8 - CARD_X + 1
    if c.text_width(town, "4x5") > room:
        town = fit(c, town, CARD_R - CARD_X + 1, "4x5")
    else:
        c.text(right, CARD_R - rw + 1, 1, font = "4x5", color = right_ink)
    c.text(town, CARD_X, 1, font = "4x5", color = NOW_TEXT)

def tile_width(c, ctx, tc):
    return 11 + c.text_width(temp_str(ctx, tc), "10x15") + 8

def draw_tile(c, ctx, x, tc, up):
    """A temperature-colored tile: arrow, big number, degree ring."""
    s = temp_str(ctx, tc)
    w = tile_width(c, ctx, tc)
    col = temp_rgb(tc)
    c.rect(x, 9, x + w - 1, 30, fill = q565(col))
    c.rect(x, 9, x + w - 1, 30, outline = q565(mix(col, (0, 0, 0), 0.5)))
    c.bitmap(BIG_UP_EDGE if up else BIG_DOWN_EDGE, x + 2, 16, INK_BLACK)
    c.bitmap(BIG_UP if up else BIG_DOWN, x + 3, 17, WHITE)
    c.text_stroke(s, x + 11, 12, font = "10x15", color = WHITE, stroke = "#000000")
    dx = x + 11 + c.text_width(s, "10x15") + 1
    c.bitmap(BIG_DEG_EDGE, dx, 11, INK_BLACK)
    c.bitmap(BIG_DEG, dx + 1, 12, WHITE)

def text_with_marks(c, s, x, y, font, h, ink):
    """Text that may end in an inch mark, which the big fonts lack."""
    inch = s.endswith("\"") and font != "5x7" and font != "4x5"
    if inch:
        s = s[:-1]
    c.text(s, x, y, font = font, color = ink)
    if inch:
        mx = x + c.text_width(s, font) + 1
        mh = max(2, h // 3)
        c.rect(mx, y, mx, y + mh - 1, fill = ink)
        c.rect(mx + 2, y, mx + 2, y + mh - 1, fill = ink)

def draw_headline(c, ctx, fc, x0):
    hd = card_headline(ctx, fc)
    room = CARD_R - x0 + 1
    main = hd[1]
    font = HEAD_FONTS[-1]
    for f in HEAD_FONTS:
        if c.text_width(main.replace("\"", "  "), f[0]) <= room:
            font = f
            break
    main = fit(c, main, room, font[0])
    # The second line in its full wording, then shorter wordings, each tried
    # in three sizes; only if nothing fits is it cut short.
    extra = 4 if hd[4] else 0
    tries = [hd[3], hd[3].replace(" TO ", "-").replace("FEELS LIKE", "FEELS").replace("GUSTS TO", "GUSTS")]
    sub = ""
    sub_font = ["4x5", 5]
    found = False
    for t in tries:
        for f in [["5x7", 7], ["4x7", 7], ["4x5", 5]]:
            if not found and c.text_width(t, f[0]) + extra <= room:
                sub = t
                sub_font = f
                found = True
    if not found:
        sub = fit(c, tries[-1], room - extra, "4x5")
    total = font[1] + (3 + sub_font[1] if sub != "" else 0)
    y = 7 + (25 - total + 1) // 2
    text_with_marks(c, main, x0, y, font[0], font[1], hd[2])
    if sub != "":
        sy = y + font[1] + 3
        c.text(sub, x0, sy, font = sub_font[0], color = WHITE)
        if hd[4]:
            c.bitmap(DEGREE, x0 + c.text_width(sub, sub_font[0]) + 1, sy, WHITE)
    return hd[0]

def card(c, ctx):
    fc = forecast(ctx)
    if error_page(c, fc):
        return
    card_back(c)
    draw_card_strip(c, fc)
    x = CARD_X + 25
    draw_tile(c, ctx, x, fc["hi_c"], True)
    x += tile_width(c, ctx, fc["hi_c"]) + 2
    draw_tile(c, ctx, x, fc["lo_c"], False)
    x += tile_width(c, ctx, fc["lo_c"]) + 4
    icon = draw_headline(c, ctx, fc, x)
    c.image(ICON_FILES[icon], CARD_X, 9)

# ------------------------------------------------------- error screens
#
# When there is no forecast to draw, the card page explains what happened
# and what to do, in the card's own style, and the three scroll pages show
# a quiet, empty night skyline instead of repeating the message.

ERR_INK = (232, 176, 74)        # amber headline
ERR_SUB = (196, 200, 214)
REST_LAND = (26, 30, 48)
REST_TOP = (6, 8, 20)
REST_BOT = (14, 18, 40)

def error_words(fc):
    """[picture, headline, what to do, right side of the top strip]."""
    e = fc["error"]
    z = fc.get("zip", "")
    shown = ("ZIP " + z) if z != "" and len(z) <= 10 else ""
    if e == "ZIP_EMPTY":
        return ["PIN", "NO ZIP CODE YET", "ADD A 5-DIGIT ZIP IN THE SETTINGS", ""]
    if e == "ZIP_FORMAT":
        return ["PIN", "ZIP SHOULD BE 5 NUMBERS", "CHECK THE ZIP IN THE SETTINGS", shown]
    if e == "ZIP":
        return ["PIN", "ZIP " + z + " NOT FOUND", "CHECK THE ZIP IN THE SETTINGS", ""]
    if e == "COVERAGE":
        return ["PIN", "NO FORECAST FOR THIS ZIP", "TRY A NEARBY ZIP CODE", shown]
    if e == "ZIP_DOWN":
        return ["WAIT", "TOWN LOOKUP IS DOWN", "WILL TRY AGAIN SOON", shown]
    if e == "LATE":
        return ["WAIT", "FORECAST RUNNING LATE", "WILL TRY AGAIN SOON", shown]
    return ["WAIT", "WEATHER SERVICE IS DOWN", "WILL TRY AGAIN SOON", shown]

def card_back(c):
    c.fill(BG)
    for y in range(7, 32):
        c.rect(CARD_X - 2, y, PAGE_W - 1, y, fill = q565(mix(CARD_TOP, CARD_BOT, (y - 7) / 24.0)))

def error_card(c, fc):
    w = error_words(fc)
    card_back(c)
    # Top strip: the app's name, so a viewer knows what is speaking.
    right = w[3]
    rw = c.text_width(right, "4x5")
    c.text("WEATHER UNROLLED", CARD_X, 1, font = "4x5", color = NOW_TEXT)
    if right != "" and CARD_X + c.text_width("WEATHER UNROLLED", "4x5") + 8 + rw <= CARD_R:
        c.text(right, CARD_R - rw + 1, 1, font = "4x5", color = TICK)
    c.image(ERROR_ICONS[w[0]], CARD_X, 9)
    x0 = CARD_X + 30
    room = CARD_R - x0 + 1
    font = HEAD_FONTS[-1]
    for f in HEAD_FONTS:
        if c.text_width(w[1], f[0]) <= room:
            font = f
            break
    head = fit(c, w[1], room, font[0])
    sub_font = ["4x5", 5]
    for f in [["5x7", 7], ["4x7", 7]]:
        if c.text_width(w[2], f[0]) <= room:
            sub_font = f
            break
    sub = fit(c, w[2], room, sub_font[0])
    total = font[1] + 4 + sub_font[1]
    y = 7 + (25 - total + 1) // 2
    c.text(head, x0, y, font = font[0], color = ERR_INK)
    c.text(sub, x0, y + font[1] + 4, font = sub_font[0], color = ERR_SUB)

ERROR_ICONS = {"PIN": "ICON_PIN.png", "WAIT": "ICON_WAIT.png"}

def resting_page(c, off):
    """An empty night skyline: the scene with no weather in it."""
    c.fill(BG)
    for y in range(SKY_TOP, GROUND_Y):
        f = (y - SKY_TOP) / float(GROUND_Y - SKY_TOP)
        row = []
        for x in range(PAGE_W):
            k = fade(off + x)
            row.append(BG if k <= 0.0 else q565(dim_to_bg(mix(REST_TOP, REST_BOT, f), k)))
        runs(c, off, y, y, row)
    for k in range(len(HILLS)):
        rest_piece(c, off, HILLS[k], "HILL")
    for p in LANDMARKS:
        rest_piece(c, off, p[0], p[1])
    row = []
    for x in range(PAGE_W):
        k = fade(off + x)
        row.append(BG if k <= 0.0 else q565(dim_to_bg(REST_LAND, k)))
    runs(c, off, GROUND_Y, GROUND_Y, row)

def rest_piece(c, off, gx, name):
    sp = SPRITES[name]
    w = sp["w"]
    if gx + w <= off or gx >= off + PAGE_W or gx + w > END_X - FADE_W:
        return
    x = gx - off
    y = LAND_BOT - sp["h"] + 1
    for part in ["body", "leaf", "trunk"]:
        c.bitmap(sp[part], x, y, REST_LAND)

def error_page(c, fc, page = -1):
    """Draws the right error screen and returns True when the forecast
    failed. page -1 is the card; 0 to 2 are the scroll pages."""
    if fc["error"] == None:
        return False
    if page < 0:
        error_card(c, fc)
    else:
        resting_page(c, page * PAGE_W)
    return True

# ------------------------------------------------------------- the pages

def scroll_page(c, ctx, page):
    fc = forecast(ctx)
    if error_page(c, fc, page):
        return
    off = page * PAGE_W
    for h in fc["hours"]:
        # How much rain, snow or storm darkens the sky (0 to 1).
        h["wet"] = clamp((h["pop"] - 30.0) / 60.0, 0.0, 1.0) * 0.6 + (0.4 if h["thunder"] else 0.0)
    c.fill(BG)
    draw_sky(c, fc, off)
    moon = draw_moon(c, fc, off)
    draw_stars(c, fc, off, moon)
    draw_sun(c, fc, off)
    draw_far_precip(c, fc, off)
    draw_clouds(c, fc, off)
    draw_lightning(c, fc, off)
    draw_near_precip(c, fc, off)
    draw_wind(c, fc, off)
    draw_land(c, fc, off)
    draw_sunrise(c, fc, off)
    draw_fog(c, fc, off)
    draw_alert_bands(c, fc, off)
    draw_strip(c, fc, off)
    tags = plan_tags(c, fc, ctx)
    draw_band(c, fc, ctx, off, tags)
    draw_tags(c, fc, tags, off)
    draw_labels(c, place_labels(c, fc, ctx), off)

def sky1(c, ctx):
    scroll_page(c, ctx, 0)

def sky2(c, ctx):
    scroll_page(c, ctx, 1)

def sky3(c, ctx):
    scroll_page(c, ctx, 2)
