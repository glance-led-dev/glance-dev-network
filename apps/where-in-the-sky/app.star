# Where in the Sky is... (128x32)
#
# Which direction and how high above the horizon to look for a chosen planet
# or the Moon from a US zip code, right now - or, if it isn't visible right
# now, the next date/time it will be along with that same direction/height.
#
# Everything is computed - there's no keyless planet-position API: Keplerian
# elements for Mercury-Neptune (Standish 2006, JPL, valid 1800-2050) and
# Meeus's abbreviated lunar theory for the Moon. Accurate to about an
# arcminute (planets) and a few arcminutes (Moon); checked against USNO
# rise/set times to within 2-6 minutes.
#
# "Visible" means at least 10 deg up (higher for Uranus/Neptune) and, for
# planets, the Sun below civil twilight (-6 deg). The Moon has no twilight
# requirement.
#
# Two keyless lookups: zip -> lat/lon, and lat/lon -> UTC offset.

# ---------- orbital elements (Standish 2006, epoch J2000) ----------
# Each planet: (a0, aRate, e0, eRate, i0, iRate, L0, LRate, peri0, periRate, node0, nodeRate)
# a = semi-major axis (AU), e = eccentricity, i = inclination (deg),
# L = mean longitude (deg), peri = longitude of perihelion (deg),
# node = longitude of ascending node (deg); each is value0 + rate*T where T
# is Julian centuries since J2000.0. Earth isn't a selectable body but is
# needed to convert every other body's heliocentric position to geocentric.
KEPLER = {
    "mercury": (0.38709927, 0.00000037, 0.20563593, 0.00001906, 7.00497902, -0.00594749, 252.25032350, 149472.67411175, 77.45779628, 0.16047689, 48.33076593, -0.12534081),
    "venus": (0.72333566, 0.00000390, 0.00677672, -0.00004107, 3.39467605, -0.00078890, 181.97909950, 58517.81538729, 131.60246718, 0.00268329, 76.67984255, -0.27769418),
    "earth": (1.00000261, 0.00000562, 0.01671123, -0.00004392, -0.00001531, -0.01294668, 100.46457166, 35999.37244981, 102.93768193, 0.32327364, 0.0, 0.0),
    "mars": (1.52371034, 0.00001847, 0.09339410, 0.00007882, 1.84969142, -0.00813131, -4.55343205, 19140.30268499, -23.94362959, 0.44441088, 49.55953891, -0.29257343),
    "jupiter": (5.20288700, -0.00011607, 0.04838624, -0.00013253, 1.30439695, -0.00183714, 34.39644051, 3034.74612775, 14.72847983, 0.21252668, 100.47390909, 0.20469106),
    "saturn": (9.53667594, -0.00125060, 0.05386179, -0.00050991, 2.48599187, 0.00193609, 49.95424423, 1222.49362201, 92.59887831, -0.41897216, 113.66242448, -0.28867794),
    "uranus": (19.18916464, -0.00196176, 0.04725744, -0.00004397, 0.77263783, -0.00242939, 313.23810451, 428.48202785, 170.95427630, 0.40805281, 74.01692503, 0.04240589),
    "neptune": (30.06992276, 0.00026291, 0.00859048, 0.00005105, 1.77004347, 0.00035372, -55.12002969, 218.45945325, 44.96476227, -0.32241464, 131.78422574, -0.00508664),
}

OBLIQUITY0 = 23.43929111  # obliquity of the ecliptic at J2000, degrees
OBLIQUITY1 = -0.0130042  # per Julian century - higher-order terms are negligible here

BODY_COLOR = {
    "Moon": "#D8D8D0",
    "Mercury": "#9E9E9E",
    "Venus": "#EADFB4",
    "Mars": "#C1440E",
    "Jupiter": "#C8A165",
    "Saturn": "#DCC98A",
    "Uranus": "#9FE3E0",
    "Neptune": "#5B7FE3",
}

# Below about 10 deg, trees, buildings and haze block the view almost
# everywhere, so nothing counts as visible until it clears 10 deg, and a
# window ends when it sinks back under 10 deg. Uranus (at the naked-eye
# limit) and Neptune (past it) need a dark, high placement, so they get
# higher floors.
HORIZON_MIN = 10.0
BODY_ALT_MIN = {
    "Uranus": 20.0,
    "Neptune": 25.0,
}

SUN_TWILIGHT_MAX = -6.0  # civil twilight - the sky-darkness threshold planets need; the Moon doesn't use this
SEARCH_DAYS = 120  # how far ahead to look for the next visible window
# 1100 sec (~18.3 min) on purpose: a step that divides the day evenly samples
# the same clock times every day and can miss a narrow daily window for
# weeks. 1100 drifts a few minutes per day, so it can't get stuck.
COARSE_STEP_SEC = 1100
FINE_STEP_SEC = 300  # 5 minutes - refinement once the coarse pass brackets the transition

# ---------- small input helper ----------

def _s(ctx, key, fallback = ""):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

# ---------- time ----------

def norm360(x):
    x = math.fmod(x, 360.0)
    if x < 0.0:
        x = x + 360.0
    return x

def jd_from_unix(unix_ts):
    return float(unix_ts) / 86400.0 + 2440587.5

def julian_centuries(jd):
    return (jd - 2451545.0) / 36525.0

# ---------- orbital mechanics ----------

def solve_kepler(m_deg, e):
    # Newton's method - 8 iterations converges to well under a second of arc
    # for every eccentricity in KEPLER (all comfortably below 0.25).
    m = math.radians(norm360(m_deg))
    if m > math.pi:
        m = m - 2.0 * math.pi
    big_e = m
    for _ in range(8):
        delta = (big_e - e * math.sin(big_e) - m) / (1.0 - e * math.cos(big_e))
        big_e = big_e - delta
    return big_e

def heliocentric_xyz(name, t):
    a0, a1, e0, e1, i0, i1, l0, l1, peri0, peri1, node0, node1 = KEPLER[name]
    a = a0 + a1 * t
    e = e0 + e1 * t
    i = i0 + i1 * t
    l = l0 + l1 * t
    peri = peri0 + peri1 * t
    node = node0 + node1 * t

    big_e = solve_kepler(l - peri, e)
    xp = a * (math.cos(big_e) - e)
    yp = a * math.sqrt(1.0 - e * e) * math.sin(big_e)

    w = math.radians(peri - node)
    om = math.radians(node)
    ii = math.radians(i)
    cosw = math.cos(w)
    sinw = math.sin(w)
    coso = math.cos(om)
    sino = math.sin(om)
    cosi = math.cos(ii)
    sini = math.sin(ii)

    x = (coso * cosw - sino * sinw * cosi) * xp + (-coso * sinw - sino * cosw * cosi) * yp
    y = (sino * cosw + coso * sinw * cosi) * xp + (-sino * sinw + coso * cosw * cosi) * yp
    z = (sinw * sini) * xp + (cosw * sini) * yp
    return x, y, z

def ecl_to_eq(x, y, z, t):
    eps = math.radians(OBLIQUITY0 + OBLIQUITY1 * t)
    coseps = math.cos(eps)
    sineps = math.sin(eps)
    xe = x
    ye = y * coseps - z * sineps
    ze = y * sineps + z * coseps
    r = math.sqrt(xe * xe + ye * ye + ze * ze)
    ra = norm360(math.degrees(math.atan2(ye, xe)))
    dec = math.degrees(math.asin(clamp(ze / r, -1.0, 1.0)))
    return ra, dec, r

def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v

def sun_radec(t):
    ex, ey, ez = heliocentric_xyz("earth", t)
    return ecl_to_eq(-ex, -ey, -ez, t)

def planet_radec(key, t):
    px, py, pz = heliocentric_xyz(key, t)
    ex, ey, ez = heliocentric_xyz("earth", t)
    ra, dec, r = ecl_to_eq(px - ex, py - ey, pz - ez, t)
    return ra, dec, r  # r here is geocentric distance in AU

# Meeus's abbreviated lunar theory (~15 largest terms of ELP2000) - good to
# roughly 10' in longitude, 4' in latitude, 40 km in distance. The Moon
# orbits Earth, not the Sun, so it gets its own formula rather than a
# KEPLER-table entry.
def moon_radec(t):
    lp = norm360(218.3164477 + 481267.88123421 * t)
    m = norm360(134.9633964 + 477198.8675055 * t)
    msun = norm360(357.5291092 + 35999.0502909 * t)
    d = norm360(297.8501921 + 445267.1114034 * t)
    f = norm360(93.2720950 + 483202.0175233 * t)

    mr = math.radians(m)
    msunr = math.radians(msun)
    dr = math.radians(d)
    fr = math.radians(f)

    lon = lp + 6.289 * math.sin(mr) - 1.274 * math.sin(mr - 2.0 * dr) + 0.658 * math.sin(2.0 * dr) - \
        0.186 * math.sin(msunr) - 0.059 * math.sin(2.0 * mr - 2.0 * dr) - \
        0.057 * math.sin(mr - 2.0 * dr + msunr) + 0.053 * math.sin(mr + 2.0 * dr) + \
        0.046 * math.sin(2.0 * dr - msunr) + 0.041 * math.sin(mr - msunr) - \
        0.035 * math.sin(dr) - 0.031 * math.sin(mr + msunr) - \
        0.015 * math.sin(2.0 * fr - 2.0 * dr) + 0.011 * math.sin(mr - 4.0 * dr)

    lat = 5.128 * math.sin(fr) + 0.281 * math.sin(mr + fr) + 0.278 * math.sin(mr - fr) + \
        0.173 * math.sin(2.0 * dr - fr) + 0.055 * math.sin(2.0 * dr - mr + fr) + \
        0.046 * math.sin(2.0 * dr - mr - fr) + 0.033 * math.sin(2.0 * dr + fr) + \
        0.017 * math.sin(2.0 * mr + fr)

    dist_km = 385000.56 - 20905.36 * math.cos(mr) - 3699.11 * math.cos(2.0 * dr - mr) - \
        2955.97 * math.cos(2.0 * dr) - 569.93 * math.cos(2.0 * mr) + \
        246.16 * math.cos(2.0 * dr - 2.0 * mr) - 152.14 * math.cos(2.0 * dr + mr) - \
        170.73 * math.cos(dr)

    lonr = math.radians(norm360(lon))
    latr = math.radians(lat)
    x = math.cos(latr) * math.cos(lonr)
    y = math.cos(latr) * math.sin(lonr)
    z = math.sin(latr)
    ra, dec, _ = ecl_to_eq(x, y, z, t)
    return ra, dec, dist_km

# ---------- sidereal time / alt-az ----------

def gmst_deg(jd):
    t = julian_centuries(jd)
    g = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0
    return norm360(g)

def alt_az(ra, dec, lat, lon, jd):
    lst = norm360(gmst_deg(jd) + lon)
    ha = norm360(lst - ra)
    har = math.radians(ha)
    decr = math.radians(dec)
    latr = math.radians(lat)

    sin_alt = math.sin(decr) * math.sin(latr) + math.cos(decr) * math.cos(latr) * math.cos(har)
    alt = math.degrees(math.asin(clamp(sin_alt, -1.0, 1.0)))

    cos_az = (math.sin(decr) - math.sin(math.radians(alt)) * math.sin(latr)) / (math.cos(math.radians(alt)) * math.cos(latr))
    az = math.degrees(math.acos(clamp(cos_az, -1.0, 1.0)))
    if math.sin(har) > 0.0:
        az = 360.0 - az
    return alt, az

COMPASS_NAMES = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                 "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

def compass_name(az):
    idx = int((az + 11.25) / 22.5) % 16
    return COMPASS_NAMES[idx]

# ---------- body state ----------

def body_key(body):
    return body.lower()

def angular_sep(ra1, dec1, ra2, dec2):
    r1, d1, r2, d2 = math.radians(ra1), math.radians(dec1), math.radians(ra2), math.radians(dec2)
    cos_sep = math.sin(d1) * math.sin(d2) + math.cos(d1) * math.cos(d2) * math.cos(r1 - r2)
    return math.degrees(math.acos(clamp(cos_sep, -1.0, 1.0)))

# Moon illumination from the Sun-Moon angle: 0 at new, 1 at full.
def illum_from_elong(elong_deg):
    return (1.0 - math.cos(math.radians(elong_deg))) / 2.0

# In daylight a Moon below this illumination is too thin to pick out.
MOON_DAYLIGHT_ILLUM_MIN = 0.10
# Below 3% lit (the day or so either side of new Moon) the crescent is a
# hairline next to the Sun - not a naked-eye sight, day or night.
MOON_ILLUM_MIN = 0.03

# Uranus (mag ~5.7) is at the naked-eye limit; Neptune (mag ~7.8) is past it.
OPTICS_HINT = {
    "Uranus": "BINOCULARS HELP",
    "Neptune": "TELESCOPE NEEDED",
}

def state_at(body, lat, lon, unix_ts):
    jd = jd_from_unix(unix_ts)
    t = julian_centuries(jd)
    if body == "Moon":
        ra, dec, dist = moon_radec(t)
    else:
        ra, dec, dist = planet_radec(body_key(body), t)
    alt, az = alt_az(ra, dec, lat, lon, jd)
    sun_ra, sun_dec, _ = sun_radec(t)
    sun_alt, sun_az = alt_az(sun_ra, sun_dec, lat, lon, jd)
    elong = angular_sep(ra, dec, sun_ra, sun_dec)
    return alt, az, sun_alt, dist, elong, sun_az

# Venus is bright enough to spot in daylight when well clear of the Sun's
# glare. Every other planet needs a dark sky.
DAYLIGHT_ELONG_MIN = {
    "Venus": 20.0,
}

def alt_min_for(body):
    return BODY_ALT_MIN.get(body, HORIZON_MIN)

def is_visible(body, alt, sun_alt, elong):
    if alt < alt_min_for(body):
        return False
    if body == "Moon":
        illum = illum_from_elong(elong)
        if sun_alt > 0.0:
            return illum >= MOON_DAYLIGHT_ILLUM_MIN
        return illum >= MOON_ILLUM_MIN
    if sun_alt <= SUN_TWILIGHT_MAX:
        return True
    daylight_min = DAYLIGHT_ELONG_MIN.get(body)
    return daylight_min != None and elong >= daylight_min

# Visible only through the daylight exception above (Venus): a harder
# sighting, flagged as "LOOK CAREFULLY".
def is_hard_daylight(body, sun_alt):
    return body in DAYLIGHT_ELONG_MIN and sun_alt > SUN_TWILIGHT_MAX

# Coarse pass to find the first visible step, then a 5-minute pass to refine it.
def find_next_visible(body, lat, lon, now_unix):
    total_coarse = (SEARCH_DAYS * 86400) // COARSE_STEP_SEC
    prev_t = now_unix
    for i in range(1, total_coarse + 1):
        t = now_unix + i * COARSE_STEP_SEC
        alt, az, sun_alt, dist, elong, sun_az = state_at(body, lat, lon, t)
        if is_visible(body, alt, sun_alt, elong):
            lo = prev_t
            hi = t
            fine_steps = (hi - lo) // FINE_STEP_SEC
            found_t = hi
            found_alt = alt
            found_az = az
            for j in range(1, fine_steps + 1):
                ft = lo + j * FINE_STEP_SEC
                if ft >= hi:
                    break
                fa, fz, fs, _, fe, _ = state_at(body, lat, lon, ft)
                if is_visible(body, fa, fs, fe):
                    found_t = ft
                    found_alt = fa
                    found_az = fz
                    break
            return {"unix": found_t, "alt": found_alt, "az": found_az}
        prev_t = t
    return None

# Same search for the end of a window (visible -> not visible), over the
# full SEARCH_DAYS horizon.
def find_visible_end(body, lat, lon, start_unix):
    total_coarse = (SEARCH_DAYS * 86400) // COARSE_STEP_SEC
    prev_t = start_unix
    for i in range(1, total_coarse + 1):
        t = start_unix + i * COARSE_STEP_SEC
        alt, az, sun_alt, dist, elong, sun_az = state_at(body, lat, lon, t)
        if not is_visible(body, alt, sun_alt, elong):
            lo = prev_t
            hi = t
            fine_steps = (hi - lo) // FINE_STEP_SEC
            found_t = hi
            for j in range(1, fine_steps + 1):
                ft = lo + j * FINE_STEP_SEC
                if ft >= hi:
                    break
                fa, fz, fs, _, fe, _ = state_at(body, lat, lon, ft)
                if not is_visible(body, fa, fs, fe):
                    found_t = ft
                    break
            return found_t
        prev_t = t
    return None  # still visible past the search horizon - rare, just omit the "until" line

# ---------- distance formatting ----------

MILES_PER_AU = 92955807.3
MILES_PER_KM = 0.621371

def commas(n):
    s = str(n)
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return out

# Moon in plain miles ("238,855 MI AWAY"), planets in millions or billions.
def distance_label(body, dist):
    if body == "Moon":
        return commas(int(dist * MILES_PER_KM + 0.5)) + " MI AWAY"
    miles = dist * MILES_PER_AU
    if miles >= 1000000000.0:
        tenths = int(miles / 100000000.0 + 0.5)
        return str(tenths // 10) + "." + str(tenths % 10) + " BILLION MI AWAY"
    return str(int(miles / 1000000.0 + 0.5)) + " MILLION MI AWAY"

# Sun altitude color: daylight / twilight / night.
def sun_state_color(sun_alt):
    if sun_alt > 0.0:
        return "#F4C542"
    if sun_alt > SUN_TWILIGHT_MAX:
        return "#C97A3D"
    return "#4A5AA8"

# Plain-language sky state: what the Sun means for seeing the target.
def sun_state_label(sun_alt):
    if sun_alt > 0.0:
        return "SUN UP - DAYLIGHT"
    if sun_alt > SUN_TWILIGHT_MAX:
        return "SUN DOWN - TWILIGHT"
    return "SUN DOWN - DARK SKY"

# ---------- keyless lookups (same calls apps/iss-sighting already makes) ----------

def geocode(zip):
    r = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if r["status_code"] == 404:
        return {"ok": False, "title": "BAD ZIP", "sub": zip + " NOT FOUND"}
    if r["status_code"] != 200:
        return {"ok": False, "title": "LOOKUP ERROR", "sub": "CODE " + str(r["status_code"])}
    places = r["json"].get("places", [])
    if not places:
        return {"ok": False, "title": "BAD ZIP", "sub": zip + " NOT FOUND"}
    p = places[0]
    city = str(p.get("place name", "")).upper()
    state = str(p.get("state abbreviation", "")).upper()
    return {
        "ok": True,
        "city": city + ", " + state if state else city,
        "lat": float(p["latitude"]),
        "lon": float(p["longitude"]),
    }

def utc_offset_hours(lat, lon):
    t = http.get(
        "https://timeapi.io/api/TimeZone/coordinate",
        params = {"latitude": str(lat), "longitude": str(lon)},
        ttl_seconds = 3600,
    )
    if t["status_code"] != 200:
        return None
    off = t["json"].get("currentUtcOffset", {}).get("seconds", None)
    if off == None:
        return None
    return float(off) / 3600.0

# ---------- local date/time formatting ----------

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

def local_from_epoch(epoch_utc, off_hours):
    local = epoch_utc + int(off_hours * 3600.0)
    sod = local % 86400
    days = (local - sod) // 86400
    y, mo, d = _civil_from_days(days)
    return {"h": sod // 3600, "mi": (sod % 3600) // 60, "wd": (days + 3) % 7, "mo": mo, "d": d, "days": days}

WEEKDAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def hms_ap(hour, minute):
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + pad2(minute) + " " + ap

# A window as start-end: same day drops the repeated AM/PM
# ("7:35-9:12 PM"); a window past midnight shows both dates.
def format_period(off, start_unix, end_unix):
    lt1 = local_from_epoch(start_unix, off)
    lt2 = local_from_epoch(end_unix, off)
    t1 = hms_ap(lt1["h"], lt1["mi"])
    t2 = hms_ap(lt2["h"], lt2["mi"])
    d1 = str(lt1["mo"]) + "/" + str(lt1["d"])
    if lt1["days"] == lt2["days"]:
        ap1 = "AM" if lt1["h"] < 12 else "PM"
        ap2 = "AM" if lt2["h"] < 12 else "PM"
        t1_show = t1[:len(t1) - 3] if ap1 == ap2 else t1
        return WEEKDAYS[lt1["wd"]] + " " + d1 + " " + t1_show + "-" + t2
    d2 = str(lt2["mo"]) + "/" + str(lt2["d"])
    return d1 + " " + t1 + " - " + d2 + " " + t2

def format_until(off, now_unix, end_unix):
    lt_now = local_from_epoch(now_unix, off)
    lt_end = local_from_epoch(end_unix, off)
    t = hms_ap(lt_end["h"], lt_end["mi"])
    if lt_now["days"] == lt_end["days"]:
        return "UNTIL " + t
    return "UNTIL " + str(lt_end["mo"]) + "/" + str(lt_end["d"]) + " " + t

# ---------- drawing ----------

# A time line that won't fit at 4x5 switches to "11:24P-10/2 1:24P" style.
def fit_times(c, text, max_w):
    if c.text_width(text, "4x5") <= max_w:
        return text
    return text.replace(" - ", "-").replace(" AM", "A").replace(" PM", "P")

def draw_page_edges(c, left = True):
    if left:
        c.rect(0, 0, 0, c.height - 1, fill = "gray")
    c.rect(c.width - 1, 0, c.width - 1, c.height - 1, fill = "gray")

def draw_header(c, body, city, accent):
    c.rect(0, 0, c.width - 1, 8, fill = "#101018")
    c.text(body.upper(), 3, 1, font = "6x8", color = accent, align = "left")
    cap = c.width - 6 - c.text_width(body.upper(), "6x8")
    shown = city
    for i in range(len(city), 0, -1):
        candidate = city[:i]
        if c.text_width(candidate, "picopixel") <= cap:
            shown = candidate
            break
    c.text(shown, c.width - 3, 2, font = "picopixel", color = "gray", align = "right")


# Polar sky dome: azimuth around the circle (North up), altitude from the
# rim (horizon) to the center (overhead). Below-horizon clamps to the rim.
CARDINAL_TICKS = [(0, "N"), (90, "E"), (180, "S"), (270, "W")]

def draw_cardinal_label(c, cx, cy, r, az_deg, letter):
    # Inset 5px so letters don't touch the rim or clip off the top.
    label_r = r - 5
    rad = math.radians(az_deg)
    lx = cx + label_r * math.sin(rad)
    ly = cy - label_r * math.cos(rad)
    c.text(letter, int(lx + 0.5), int(ly + 0.5) - 2, font = "picopixel", color = "#8A94A8", align = "center")

def sky_dot_pos(cx, cy, r, az, alt):
    frac = clamp(1.0 - alt / 90.0, 0.0, 1.0)
    rr = r * frac
    rad = math.radians(az)
    x = cx + rr * math.sin(rad)
    y = cy - rr * math.cos(rad)
    return int(x + 0.5), int(y + 0.5)

# Side view: a person on the ground and a sightline at the altitude angle.
# alt None draws the person with no sightline.
def draw_ground_person(c, x0, y0, length, alt, color):
    c.line(x0 - 4, y0, x0 + length + 8, y0, color = "#4A3B28")
    body_h = 4
    c.line(x0, y0, x0, y0 - body_h, color = color)
    head_cy = y0 - body_h - 2
    c.fill_circle(x0, head_cy, 2, color)
    if alt == None:
        return
    rad = math.radians(max(0.0, alt))
    ex = x0 + length * math.cos(rad)
    ey = head_cy - length * math.sin(rad)
    c.line(x0, head_cy, int(ex + 0.5), int(ey + 0.5), color = color)

def draw_err(c, title, sub):
    c.fill("black")
    c.text(title, 4, 12, font = "5x7", color = "orange", align = "left")
    c.text(sub, 4, 21, font = "4x5", color = "gray", align = "left")
    draw_page_edges(c, left = True)

def _load(ctx):
    body = _s(ctx, "body", "Moon")
    if body not in BODY_COLOR:
        body = "Moon"
    zip = _s(ctx, "zip")
    if not zip:
        return body, None, {"ok": False, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}
    loc = geocode(zip)
    return body, loc, None

# ---------- pages ----------

def look(c, ctx):
    body, loc, err = _load(ctx)
    if err != None:
        draw_err(c, err["title"], err["sub"])
        return
    if not loc["ok"]:
        draw_err(c, loc["title"], loc["sub"])
        return

    accent = BODY_COLOR[body]
    now = ctx.now.unix
    alt, az, sun_alt, dist, elong, _ = state_at(body, loc["lat"], loc["lon"], now)
    visible = is_visible(body, alt, sun_alt, elong)

    c.fill("black")
    draw_header(c, body, loc["city"], accent)

    off = utc_offset_hours(loc["lat"], loc["lon"])

    if visible:
        if is_hard_daylight(body, sun_alt):
            c.text("DAYLIGHT", 64, 10, font = "6x8", color = "orange", align = "center")
            c.text("LOOK CAREFULLY", 64, 19, font = "5x7", color = "gray", align = "center")
        else:
            c.text("LOOK " + compass_name(az), 64, 10, font = "6x8", color = "white", align = "center")
            c.text(str(int(alt + 0.5)) + " DEG UP", 64, 19, font = "5x7", color = accent, align = "center")
        end_t = find_visible_end(body, loc["lat"], loc["lon"], now)
        if end_t != None and off != None:
            c.text(fit_times(c, format_until(off, now, end_t), 120), 64, 27, font = "4x5", color = "gray", align = "center")
        else:
            c.text(compass_name(az) + " " + str(int(az + 0.5)) + " DEG", 64, 27, font = "4x5", color = "gray", align = "center")
    else:
        nxt = find_next_visible(body, loc["lat"], loc["lon"], now)
        # 1px gap between stacked lines.
        c.text("NOT VISIBLE NOW", 4, 10, font = "4x5", color = "gray", align = "left")
        if nxt == None:
            c.text("NO WINDOW IN NEXT " + str(SEARCH_DAYS) + " DAYS", 4, 16, font = "4x5", color = "gray", align = "left")
        elif off == None:
            c.text("NEXT VISIBLE TIME UNKNOWN", 4, 16, font = "4x5", color = "gray", align = "left")
        else:
            end_t = find_visible_end(body, loc["lat"], loc["lon"], nxt["unix"])
            if end_t != None:
                period = format_period(off, nxt["unix"], end_t)
            else:
                lt = local_from_epoch(nxt["unix"], off)
                period = WEEKDAYS[lt["wd"]] + " " + str(lt["mo"]) + "/" + str(lt["d"]) + " " + hms_ap(lt["h"], lt["mi"])
            c.text(fit_times(c, period, 120), 4, 16, font = "4x5", color = "white", align = "left")
            nxt_sun_alt = state_at(body, loc["lat"], loc["lon"], nxt["unix"])[2]
            suffix = " (DAYLIGHT)" if is_hard_daylight(body, nxt_sun_alt) else ""
            c.text(compass_name(nxt["az"]) + " AT " + str(int(nxt["alt"] + 0.5)) + " DEG UP" + suffix, 4, 22, font = "4x5", color = accent, align = "left")
    draw_page_edges(c, left = True)

def info(c, ctx):
    body, loc, err = _load(ctx)
    if err != None:
        draw_err(c, err["title"], err["sub"])
        return
    if not loc["ok"]:
        draw_err(c, loc["title"], loc["sub"])
        return

    accent = BODY_COLOR[body]
    now = ctx.now.unix
    alt, az, sun_alt, dist, elong, _ = state_at(body, loc["lat"], loc["lon"], now)

    c.fill("black")
    draw_header(c, body, loc["city"], accent)

    # 1px gap between stacked lines (4x5 renders 5px tall).
    c.text(distance_label(body, dist), 4, 10, font = "4x5", color = "white", align = "left")
    c.text(sun_state_label(sun_alt), 4, 16, font = "4x5", color = sun_state_color(sun_alt), align = "left")

    optics = OPTICS_HINT.get(body)
    if body == "Moon":
        third = str(int(illum_from_elong(elong) * 100.0 + 0.5)) + "% ILLUMINATED"
        third_color = "white"
    elif optics != None:
        third = optics
        third_color = "orange"
    else:
        third = str(int(elong + 0.5)) + " DEG FROM SUN"
        third_color = "gray"
    c.text(third, 4, 22, font = "4x5", color = third_color, align = "left")
    draw_page_edges(c, left = False)

def aim(c, ctx):
    body, loc, err = _load(ctx)
    if err != None:
        draw_err(c, err["title"], err["sub"])
        return
    if not loc["ok"]:
        draw_err(c, loc["title"], loc["sub"])
        return

    accent = BODY_COLOR[body]
    now = ctx.now.unix
    alt, az, sun_alt, dist, elong, sun_az = state_at(body, loc["lat"], loc["lon"], now)

    # Not visible now: aim at where it will be when its next window opens,
    # so the sightline never points below the horizon.
    when = ""
    if not is_visible(body, alt, sun_alt, elong):
        nxt = find_next_visible(body, loc["lat"], loc["lon"], now)
        if nxt == None:
            alt = None
        else:
            alt, az, sun_alt, dist, elong, sun_az = state_at(body, loc["lat"], loc["lon"], nxt["unix"])
            off = utc_offset_hours(loc["lat"], loc["lon"])
            if off != None:
                lt = local_from_epoch(nxt["unix"], off)
                lt_now = local_from_epoch(now, off)
                t = hms_ap(lt["h"], lt["mi"])
                when = t if lt["days"] == lt_now["days"] else WEEKDAYS[lt["wd"]] + " " + t

    c.fill("black")

    # Polar sky dome: N/E/S/W letters inside the rim, a crosshair at the
    # zenith, a white dot for the body and a yellow dot for the Sun (only
    # when it's up).
    cx = 16
    cy = 16
    r = 15
    c.circle(cx, cy, r, "#3A3F4B")
    for cardinal in CARDINAL_TICKS:
        draw_cardinal_label(c, cx, cy, r, cardinal[0], cardinal[1])
    c.line(cx - 1, cy, cx + 1, cy, color = "#5A6070")
    c.line(cx, cy - 1, cx, cy + 1, color = "#5A6070")

    if alt == None:
        # No window in the search horizon: no dot, no sightline.
        c.text("NOT UP", 36, 11, font = "5x7", color = "gray", align = "left")
        c.text(str(SEARCH_DAYS) + " DAYS", 36, 19, font = "4x5", color = "gray", align = "left")
        draw_ground_person(c, 90, 30, 22, None, accent)
        draw_page_edges(c, left = False)
        return

    if sun_alt > 0.0:
        sun_x, sun_y = sky_dot_pos(cx, cy, r, sun_az, sun_alt)
        c.fill_circle(sun_x, sun_y, 1, "yellow")
    obj_x, obj_y = sky_dot_pos(cx, cy, r, az, alt)
    c.fill_circle(obj_x, obj_y, 1, "white")

    # Heading, azimuth and angle as text between the dome and the person;
    # for a future window the time replaces the azimuth line. Centered as a
    # block, with a 1px gap between lines.
    text_x = 34
    second = (str(int(az + 0.5)) + " DEG", "4x5", "gray")
    if when != "":
        f = "4x5" if c.text_width(when, "4x5") <= 48 else "picopixel"
        second = (when, f, "white")
    lines = [
        (compass_name(az), "5x7", accent),
        second,
        (str(int(alt + 0.5)) + " DEG UP", "4x5", accent),
    ]
    line_heights = [7, 5, 5]
    total_h = len(lines) - 1
    for h in line_heights:
        total_h += h
    y = (c.height - total_h) // 2
    for i in range(len(lines)):
        text, font, color = lines[i]
        c.text(text, text_x, y, font = font, color = color, align = "left")
        y += line_heights[i] + 1

    draw_ground_person(c, 90, 30, 22, alt, accent)

    draw_page_edges(c, left = False)
