# Where in the Sky is... (192x32)
#
# Which direction and how high above the horizon to look for a chosen planet
# or the Moon from a US zip code, right now - or, if it isn't visible right
# now, the next date/time it will be along with that same direction/height.
# "Best Tonight" (the default) picks the brightest planet up tonight, else
# the Moon. Other pages: rise / highest / set, the next four nights, every
# naked-eye body on tonight's sky, each body's window tonight, the Moon's
# phase, and close passes coming up.
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

# Cheap per-day screen so the search can skip days that can't work: the
# body's highest point (upper culmination, 90 - |lat - dec|) must clear its
# floor, and for planets that need a dark sky the Sun's lowest point (lower
# culmination, |lat + dec| - 90) must reach twilight. Declinations are
# taken at both ends of the day with a margin (the Moon moves ~5 deg/day),
# so a False here is never wrong. Without this, a midnight-sun location
# scans all SEARCH_DAYS step by step and the render times out.
def day_could_be_visible(body, lat, t0):
    tc0 = julian_centuries(jd_from_unix(t0))
    tc1 = julian_centuries(jd_from_unix(t0 + 86400))
    d0 = radec_of(body, tc0)[1]
    d1 = radec_of(body, tc1)[1]
    margin = 6.0 if body == "Moon" else 1.0
    best_dec = clamp(lat, min(d0, d1) - margin, max(d0, d1) + margin)
    if 90.0 - abs(lat - best_dec) < alt_min_for(body):
        return False
    if body == "Moon" or body in DAYLIGHT_ELONG_MIN:
        return True
    s0 = sun_radec(tc0)[1]
    s1 = sun_radec(tc1)[1]
    sun_dec = clamp(-lat, min(s0, s1) - 0.5, max(s0, s1) + 0.5)
    return abs(lat + sun_dec) - 90.0 <= SUN_TWILIGHT_MAX

# Coarse pass to find the first visible step, then a 5-minute pass to refine it.
def find_next_visible(body, lat, lon, now_unix):
    prev_t = now_unix
    for day in range(SEARCH_DAYS):
        i_first = (day * 86400) // COARSE_STEP_SEC + 1
        i_last = ((day + 1) * 86400) // COARSE_STEP_SEC
        if not day_could_be_visible(body, lat, now_unix + day * 86400):
            prev_t = now_unix + i_last * COARSE_STEP_SEC
            continue
        found = _scan_day(body, lat, lon, now_unix, i_first, i_last, prev_t)
        if found != None:
            return found
        prev_t = now_unix + i_last * COARSE_STEP_SEC
    return None

def _scan_day(body, lat, lon, now_unix, i_first, i_last, prev_t):
    for i in range(i_first, i_last + 1):
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

# Same search for the end of a window (visible -> not visible), over
# END_SEARCH_DAYS - long enough for any ordinary window; a body that stays
# up longer (polar night) just drops the "until" line.
END_SEARCH_DAYS = 7

def find_visible_end(body, lat, lon, start_unix):
    total_coarse = (END_SEARCH_DAYS * 86400) // COARSE_STEP_SEC
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

# ---------- Best Tonight ----------

AUTO = "Best Tonight"
# Brightest first: the planet to suggest when several are up tonight.
BEST_ORDER = ["Venus", "Jupiter", "Mars", "Saturn", "Mercury"]
SKY_BODIES = ["Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn"]

def dark_time(loc, now):
    # tonight's first full darkness (Sun 12 deg down), or now if it's dark
    for i in range(0, 200):
        t = now + i * 600
        sun_alt = state_at("Moon", loc["lat"], loc["lon"], t)[2]
        if sun_alt <= -12.0:
            return t
    return now

def night_window(body, loc, start, steps, step_sec):
    # first visible stretch from start: (on_unix, on_az, last_visible_unix)
    on = None
    last = None
    for k in range(steps):
        t = start + k * step_sec
        alt, az, sun_alt, dist, elong, _ = state_at(body, loc["lat"], loc["lon"], t)
        if is_visible(body, alt, sun_alt, elong):
            if on == None:
                on = (t, az)
            last = t
        elif on != None:
            break
    return on, last

def best_tonight(loc, now):
    # The brightest planet up in the evening (dusk to midnight), else the
    # brightest up later in the night, else the Moon.
    start = dark_time(loc, now) - 3600
    late = None
    for b in BEST_ORDER:
        on, _ = night_window(b, loc, start, 14 * 3, 1200)
        if on == None:
            continue
        if on[0] - start <= 5 * 3600:
            return b
        if late == None:
            late = b
    return late if late != None else "Moon"

def _load(ctx):
    body = _s(ctx, "body", AUTO)
    if body != AUTO and body not in BODY_COLOR:
        body = AUTO
    zip = _s(ctx, "zip")
    if not zip:
        return body, False, None, {"ok": False, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}
    loc = geocode(zip)
    if not loc["ok"]:
        return body, False, loc, None
    auto = body == AUTO
    if auto:
        body = best_tonight(loc, ctx.now.unix)
    return body, auto, loc, None

def page_setup(c, ctx):
    # (body, auto, loc, off) or None after drawing the error page
    body, auto, loc, err = _load(ctx)
    if err != None:
        draw_err(c, err["title"], err["sub"])
        return None
    if not loc["ok"]:
        draw_err(c, loc["title"], loc["sub"])
        return None
    off = utc_offset_hours(loc["lat"], loc["lon"])
    return body, auto, loc, off

def body_header(c, body, auto, city, accent):
    draw_header(c, body, city, accent)
    if auto:
        x = 3 + c.text_width(body.upper(), "6x8") + 4
        c.text("BEST TONIGHT", x, 2, font = "picopixel", color = "#F5C542")

def mini_header(c, title, right, color):
    c.rect(0, 0, c.width - 1, 6, fill = "#101018")
    c.text(title, 3, 1, font = "4x5", color = color)
    c.text(right, c.width - 3, 1, font = "4x5", color = "gray", align = "right")

def hm_short(lt):
    # "9:40P" / "12A"
    hh = lt["h"] % 12
    if hh == 0:
        hh = 12
    return str(hh) + (":" + pad2(lt["mi"]) if lt["mi"] else "") + ("A" if lt["h"] < 12 else "P")

def day_hm(off, unix, now):
    # "9:40P" today, else "SAT 9:40P"
    lt = local_from_epoch(unix, off)
    if lt["days"] == local_from_epoch(now, off)["days"]:
        return hm_short(lt)
    return WEEKDAYS[lt["wd"]] + " " + hm_short(lt)

DIR_WORDS = ["NORTH", "NORTHEAST", "EAST", "SOUTHEAST", "SOUTH", "SOUTHWEST", "WEST", "NORTHWEST"]

def plain_direction(az, alt):
    # "LOW IN THE EAST" / "HALFWAY UP IN THE SW" / "HIGH IN THE SOUTH"
    word = DIR_WORDS[int(norm360(az + 22.5) // 45.0) % 8]
    height = "LOW" if alt < 25.0 else ("HIGH" if alt >= 55.0 else "UP")
    return height + " IN THE " + word

# ---------- planet sprites ----------

# Each body is drawn per pixel as a lit sphere (light from the upper left,
# quantized to hard tones - no anti-aliasing) with its own surface: Jupiter's
# bands and red spot, Saturn's rings, Mars's polar cap, the Moon's maria and
# phase. The same function draws a 22px hero and a 7px list bullet.
PLANET_TONES = {
    # (shadow, base, highlight)
    "Moon": ((70, 70, 66), (176, 176, 168), (232, 230, 220)),
    "Mercury": ((60, 58, 56), (140, 136, 130), (196, 192, 186)),
    "Venus": ((120, 104, 60), (226, 206, 150), (250, 240, 205)),
    "Mars": ((96, 30, 8), (193, 68, 14), (232, 120, 60)),
    "Jupiter": ((110, 80, 46), (200, 161, 101), (238, 214, 170)),
    "Saturn": ((120, 104, 60), (220, 201, 138), (246, 232, 186)),
    "Uranus": ((50, 120, 125), (130, 215, 215), (200, 245, 245)),
    "Neptune": ((24, 40, 120), (60, 100, 220), (130, 165, 245)),
}

def _rgb_scale(rgb, k):
    return (min(255, int(rgb[0] * k)), min(255, int(rgb[1] * k)), min(255, int(rgb[2] * k)))

def _noise(x, y):
    # cheap deterministic texture, 0-16
    return (x * 37 + y * 91 + x * y * 13 + (x * x) % 7) % 17

# Dark patches as (u, v, radius) on the unit disc: the Moon's big maria
# (Imbrium, Serenitatis, Tranquillitatis, Procellarum, Nubium), Mercury's craters.
CRATERS = {
    "Moon": [(-0.25, -0.35, 0.28), (0.15, -0.30, 0.20), (0.30, 0.0, 0.24), (-0.50, 0.05, 0.25), (-0.15, 0.45, 0.17)],
    "Mercury": [(-0.35, -0.30, 0.18), (0.30, -0.45, 0.12), (0.20, 0.25, 0.20), (-0.40, 0.40, 0.12), (0.55, 0.0, 0.10)],
}

def _surface(body, u, v, x, y, tones):
    # Base color at sphere coordinates u (right) / v (down), each -1..1.
    shadow, base, hi = tones
    if body == "Jupiter":
        band = int((v + 1.0) * 4.5)
        col = base if band % 2 == 0 else _rgb_scale(base, 0.72)
        if abs(v) < 0.12:
            col = hi
        du, dv = (u - 0.30) / 0.30, (v - 0.38) / 0.16
        if du * du + dv * dv <= 1.0:
            col = (200, 80, 50)
        return col
    if body == "Saturn":
        return base if int((v + 1.0) * 3.5) % 2 == 0 else _rgb_scale(base, 0.86)
    if body == "Mars":
        if v < -0.72:
            return (240, 240, 235)
        return _rgb_scale(base, 0.75) if _noise(x, y) < 4 else base
    if body == "Venus":
        return hi if int((v + u * 0.4 + 1.0) * 3.0) % 2 == 0 else base
    if body == "Mercury" or body == "Moon":
        for cu, cv, cr in CRATERS[body]:
            du, dv = u - cu, v - cv
            if du * du + dv * dv <= cr * cr:
                return _rgb_scale(base, 0.66)
        return base
    if body == "Neptune":
        du, dv = (u + 0.25) / 0.20, (v - 0.25) / 0.11
        if du * du + dv * dv <= 1.0:
            return (20, 30, 90)
        return hi if abs(v + 0.35) < 0.08 else base
    return base

def _ring_pixel(rx, ry, r, tilt):
    # inside Saturn's ring band? (ellipse annulus, flattened by tilt)
    a = rx / r
    b = ry / (r * tilt)
    d = a * a + b * b
    return d >= 1.55 * 1.55 and d <= 2.2 * 2.2

def draw_body(c, body, cx, cy, r, phase = None, dim = 1.0):
    # phase: (illuminated fraction, waxing) for the Moon - unlit side drawn dark
    tones = PLANET_TONES[body]
    if dim != 1.0:
        tones = (_rgb_scale(tones[0], dim), _rgb_scale(tones[1], dim), _rgb_scale(tones[2], dim))
    ring = None
    if body == "Saturn":
        ring = ((214, 190, 120), 0.32)
    elif body == "Uranus" and r >= 6:
        ring = ((110, 170, 175), 0.32)
    if ring != None:
        rc = _rgb_scale(ring[0], dim)
        span = int(r * 2.2) + 1
        hh = int(r * ring[1] * 2.2) + 1
        for ry in range(-hh, hh + 1):
            for rx in range(-span, span + 1):
                # back half of the ring is hidden behind the globe
                if _ring_pixel(rx, ry, r, ring[1]) and not (ry < 0 and rx * rx + ry * ry <= r * r):
                    c.pixel(cx + rx, cy + ry, rc if (rx + ry) % 5 != 0 else _rgb_scale(rc, 0.7))
    rr = r * r + r  # rounder disc edge at small radii
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            d2 = dx * dx + dy * dy
            if d2 > rr:
                continue
            if ring != None and dy > 0 and _ring_pixel(dx, dy, r, ring[1]):
                continue  # front half of the ring crosses the globe
            u = float(dx) / r
            v = float(dy) / r
            nz = math.sqrt(max(0.0, 1.0 - (u * u + v * v)))
            lit = -0.55 * u - 0.45 * v + 0.70 * nz
            col = _surface(body, u, v, cx + dx, cy + dy, tones)
            if lit > 0.80:
                col = _rgb_scale(col, 1.18)
            elif lit < 0.15:
                col = tones[0]
            elif lit < 0.40:
                col = _rgb_scale(col, 0.72)
            if phase != None:
                f, waxing = phase
                w = math.sqrt(max(0.0, r * r - dy * dy))
                edge = w * (1.0 - 2.0 * f)
                on = dx >= edge if waxing else dx <= -edge
                if not on:
                    col = (36, 36, 40)
            c.pixel(cx + dx, cy + dy, col)

# A few fixed dim stars behind a sprite zone.
STARS = [(2, 3), (11, 26), (5, 17), (30, 2), (36, 28), (24, 30), (39, 9), (1, 25), (17, 1), (33, 21)]

def draw_stars(c, x0):
    for sx, sy in STARS:
        c.pixel(x0 + sx, sy, "#3C4258" if (sx + sy) % 3 else "#6A7290")

def draw_compass(c, cx, cy, r, az, accent):
    c.circle(cx, cy, r, "#3A3F4B")
    c.text("N", cx + 1, cy - r - 6, font = "picopixel", color = "#8A94A8", align = "center")
    rad = math.radians(az)
    tx = cx + (r - 2) * math.sin(rad)
    ty = cy - (r - 2) * math.cos(rad)
    c.line(cx, cy, int(tx + 0.5), int(ty + 0.5), color = accent)
    c.fill_circle(int(tx + 0.5), int(ty + 0.5), 1, accent)
    c.pixel(cx, cy, "white")

def moon_phase_now(lat, lon, unix):
    e0 = state_at("Moon", lat, lon, unix)[4]
    e1 = state_at("Moon", lat, lon, unix + 3600)[4]
    return illum_from_elong(e0), e1 > e0

# ---------- pages ----------

# Look: sprite of the body left, where to look in the middle, a compass
# needle at the bearing right. Inside the scroll safe zone (x 6-185).
def look(c, ctx):
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
    accent = BODY_COLOR[body]
    now = ctx.now.unix
    alt, az, sun_alt, dist, elong, _ = state_at(body, loc["lat"], loc["lon"], now)
    visible = is_visible(body, alt, sun_alt, elong)
    c.fill("black")
    draw_stars(c, 4)
    phase = moon_phase_now(loc["lat"], loc["lon"], now) if body == "Moon" else None
    draw_body(c, body, 26, 16, 11 if body != "Saturn" else 8, phase = phase, dim = 1.0 if visible else 0.45)

    tx = 46
    c.text(body.upper(), tx, 1, font = "6x8", color = accent)
    x = tx + c.text_width(body.upper(), "6x8") + 4
    if auto:
        c.text("BEST TONIGHT", x, 2, font = "picopixel", color = "#F5C542")
        x += c.text_width("BEST TONIGHT", "picopixel") + 4
    # Full "NEW YORK CITY, NY", else drop the state, else whole words.
    city = loc["city"]
    words = city.split(",")[0].split(" ")
    tries = [city] + [" ".join(words[:n]) for n in range(len(words), 0, -1)]
    for cand in tries:
        if c.text_width(cand, "picopixel") <= 185 - x:
            c.text(cand, 185, 2, font = "picopixel", color = "gray", align = "right")
            break

    if visible:
        c.text("LOOK " + compass_name(az), tx, 11, font = "10x16", color = "white")
        foot = str(int(alt + 0.5)) + " DEG UP"
        c.text(foot, tx, 27, font = "4x5", color = accent)
        fx = tx + c.text_width(foot, "4x5") + 6
        if is_hard_daylight(body, sun_alt):
            c.text("DAYLIGHT - LOOK CAREFULLY", fx, 27, font = "4x5", color = "orange")
        else:
            end_t = find_visible_end(body, loc["lat"], loc["lon"], now)
            if end_t != None and off != None:
                c.text("UNTIL " + day_hm(off, end_t, now), fx, 27, font = "4x5", color = "gray")
        draw_compass(c, 175, 21, 7, az, accent)
        return

    nxt = find_next_visible(body, loc["lat"], loc["lon"], now)
    if nxt == None or off == None:
        c.text("NOT UP", tx, 11, font = "10x16", color = "gray")
        msg = "NONE IN THE NEXT " + str(SEARCH_DAYS) + " DAYS" if nxt == None else "NEXT TIME UNKNOWN"
        c.text(msg, tx, 27, font = "4x5", color = "gray")
        return
    c.text("NEXT", tx, 11, font = "10x16", color = "gray")
    c.text(hm_short(local_from_epoch(nxt["unix"], off)), tx + c.text_width("NEXT ", "10x16"), 11, font = "10x16", color = "white")
    lt = local_from_epoch(nxt["unix"], off)
    day = WEEKDAYS[lt["wd"]] + " " + str(lt["mo"]) + "/" + str(lt["d"])
    c.text(day, tx, 27, font = "4x5", color = "white")
    fx = tx + c.text_width(day, "4x5") + 6
    nxt_sun_alt = state_at(body, loc["lat"], loc["lon"], nxt["unix"])[2]
    where = compass_name(nxt["az"]) + " " + str(int(nxt["alt"] + 0.5)) + " DEG UP"
    if is_hard_daylight(body, nxt_sun_alt):
        where += " IN DAYLIGHT"
    c.text(where, fx, 27, font = "4x5", color = accent)
    draw_compass(c, 175, 21, 7, nxt["az"], "#5A6070")

def aim(c, ctx):
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
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
            if off != None:
                when = "AT " + day_hm(off, nxt["unix"], now)
    c.fill("black")
    cx, cy, r = 16, 16, 15
    c.circle(cx, cy, r, "#3A3F4B")
    for cardinal in CARDINAL_TICKS:
        draw_cardinal_label(c, cx, cy, r, cardinal[0], cardinal[1])
    c.line(cx - 1, cy, cx + 1, cy, color = "#5A6070")
    c.line(cx, cy - 1, cx, cy + 1, color = "#5A6070")
    if alt == None:
        c.text("NOT UP", 38, 9, font = "5x7", color = "gray")
        c.text("IN THE NEXT " + str(SEARCH_DAYS) + " DAYS", 38, 18, font = "4x5", color = "gray")
        draw_ground_person(c, 150, 30, 26, None, accent)
        draw_page_edges(c, left = False)
        return
    if sun_alt > 0.0:
        sx, sy = sky_dot_pos(cx, cy, r, sun_az, sun_alt)
        c.fill_circle(sx, sy, 1, "yellow")
    ox, oy = sky_dot_pos(cx, cy, r, az, alt)
    c.fill_circle(ox, oy, 1, "white")
    lines = [
        (plain_direction(az, alt), "5x7", accent, 7),
        (when if when != "" else "RIGHT NOW", "4x5", "white" if when != "" else "gray", 5),
        (compass_name(az) + " " + str(int(az + 0.5)) + " DEG  -  " + str(int(alt + 0.5)) + " DEG UP", "4x5", "gray", 5),
    ]
    total = len(lines) - 1
    for ln in lines:
        total += ln[3]
    y = (c.height - total) // 2
    for text, font, color, h in lines:
        c.text(text, 38, y, font = font, color = color)
        y += h + 1
    draw_ground_person(c, 150, 30, 26, alt, accent)
    draw_page_edges(c, left = False)

def pass_around(body, loc, now):
    # The above-horizon pass that contains now, else the next one:
    # (rise, peak_time, peak_alt, peak_az, set, rise_az, set_az); None if none.
    step = 600
    start = now - 14 * 3600
    prev_up = None
    rise, rise_az = None, None
    peak = (None, -90.0, 0.0)
    for k in range(0, 44 * 6):
        t = start + k * step
        alt, az, _, _, _, _ = state_at(body, loc["lat"], loc["lon"], t)
        up = alt > 0.0
        if prev_up != None and up and not prev_up:
            rise, rise_az = t, az
            peak = (t, alt, az)
        if up and rise != None and alt > peak[1]:
            peak = (t, alt, az)
        if prev_up != None and prev_up and not up and rise != None:
            if t >= now:
                return (rise, peak[0], peak[1], peak[2], t, rise_az, az)
            rise = None
        prev_up = up
    return None

def rise_set(c, ctx):
    # Rise, highest point and set for the pass now or next, plus the
    # distance, the sky state and (Moon) how lit it is.
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
    accent = BODY_COLOR[body]
    now = ctx.now.unix
    c.fill("black")
    body_header(c, body, auto, loc["city"], accent)
    alt, az, sun_alt, dist, elong, _ = state_at(body, loc["lat"], loc["lon"], now)
    p = pass_around(body, loc, now)
    if p == None or off == None:
        c.text("NO RISE OR SET IN THE NEXT DAY", 4, 14, font = "4x5", color = "gray")
    else:
        rows = [
            ("RISES", day_hm(off, p[0], now), compass_name(p[5]), "white"),
            ("HIGH", day_hm(off, p[1], now), compass_name(p[3]) + " " + str(int(p[2] + 0.5)) + " UP", accent),
            ("SETS", day_hm(off, p[4], now), compass_name(p[6]), "white"),
        ]
        for i, (label, when, where, col) in enumerate(rows):
            y = 10 + i * 7
            c.text(label, 4, y, font = "4x5", color = "gray")
            c.text(when, 32, y, font = "4x5", color = col)
            c.text(where, 80, y, font = "4x5", color = col)
    c.line(116, 10, 116, 30, color = "#2A2E38")
    c.text(distance_label(body, dist).replace(" AWAY", ""), 120, 10, font = "4x5", color = "white")
    c.text(sun_state_label(sun_alt).replace("SUN DOWN - ", "").replace("SUN UP - ", ""), 120, 17, font = "4x5", color = sun_state_color(sun_alt))
    optics = OPTICS_HINT.get(body)
    if body == "Moon":
        c.text(str(int(illum_from_elong(elong) * 100.0 + 0.5)) + "% LIT", 120, 24, font = "4x5", color = "white")
    elif optics != None:
        c.text(optics.split(" ")[0], 120, 24, font = "4x5", color = "orange")
    draw_page_edges(c, left = False)

def timeline(c, ctx):
    # Four nights, 6 PM to 6 AM: a bar wherever the body is visible.
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
    accent = BODY_COLOR[body]
    c.fill("black")
    mini_header(c, body.upper() + " - NEXT 4 NIGHTS", "6P    12A    6A", accent)
    if off == None:
        c.text("LOCAL TIME UNKNOWN", 96, 16, font = "4x5", color = "gray", align = "center")
        return
    lt = local_from_epoch(ctx.now.unix, off)
    six_pm = (lt["days"] * 86400 + 18 * 3600) - int(off * 3600.0)
    x0 = 20
    span = c.width - x0 - 4
    steps = 48
    seen = False
    for n in range(4):
        y = 8 + n * 6
        c.text(WEEKDAYS[(lt["wd"] + n) % 7], 3, y, font = "4x5", color = "#F5C542" if n == 0 else "gray")
        c.rect(x0, y, x0 + span, y + 4, fill = "#15171C")
        for k in range(steps):
            t = six_pm + n * 86400 + k * (12 * 3600 // steps)
            alt, az, sun_alt, dist, elong, _ = state_at(body, loc["lat"], loc["lon"], t)
            if is_visible(body, alt, sun_alt, elong):
                seen = True
                c.rect(x0 + k * span // steps, y, x0 + (k + 1) * span // steps - 1, y + 4, fill = accent)
    mid = x0 + span // 2
    c.line(mid, 8, mid, 31, color = "#2A2E38")
    if not seen:
        msg = "NOT VISIBLE THESE NIGHTS"
        w = c.text_width(msg, "4x5") + 6
        c.rect(mid - w // 2, 15, mid + w // 2, 23, fill = "black")
        c.text(msg, mid, 17, font = "4x5", color = "gray", align = "center")

def sky_tonight(c, ctx):
    # Every naked-eye body on one dome at tonight's first darkness.
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
    t = dark_time(loc, ctx.now.unix)
    c.fill("black")
    cx, cy, r = 16, 16, 15
    c.circle(cx, cy, r, "#3A3F4B")
    for cardinal in CARDINAL_TICKS:
        draw_cardinal_label(c, cx, cy, r, cardinal[0], cardinal[1])
    up = []
    for b in SKY_BODIES:
        alt, az, sun_alt, dist, elong, _ = state_at(b, loc["lat"], loc["lon"], t)
        if is_visible(b, alt, sun_alt, elong):
            x, y = sky_dot_pos(cx, cy, r, az, alt)
            c.fill_circle(x, y, 1, BODY_COLOR[b])
            up.append((alt, b, az))
    up = sorted(up, reverse = True)
    c.text("TONIGHT'S SKY", 38, 1, font = "4x5", color = "#F5C542")
    if off != None:
        c.text("AT " + hm_short(local_from_epoch(t, off)), c.width - 3, 1, font = "4x5", color = "gray", align = "right")
    if not up:
        c.text("NOTHING UP YET", 38, 14, font = "5x7", color = "gray")
        return
    for i, (alt, b, az) in enumerate(up[:6]):
        x = 38 + (i // 3) * 78
        y = 9 + (i % 3) * 8
        c.fill_circle(x + 2, y + 3, 2, BODY_COLOR[b])
        c.text(b.upper(), x + 7, y, font = "5x7", color = BODY_COLOR[b])
        c.text(compass_name(az) + " " + str(int(alt + 0.5)), x + 76, y + 1, font = "4x5", color = "gray", align = "right")

def up_tonight(c, ctx):
    # Each body's viewing window between dusk and dawn.
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
    start = dark_time(loc, ctx.now.unix) - 3600
    c.fill("black")
    mini_header(c, "UP TONIGHT", loc["city"], "#F5C542")
    for i, b in enumerate(SKY_BODIES):
        on, last = night_window(b, loc, start, 14 * 6, 600)
        x = 3 + (i // 3) * 95
        y = 9 + (i % 3) * 8
        c.text(b.upper(), x, y, font = "4x5", color = BODY_COLOR[b] if on != None else "#4A4F5B")
        if on == None or off == None:
            c.text("NOT UP", x + 89, y, font = "4x5", color = "#4A4F5B", align = "right")
        else:
            a = hm_short(local_from_epoch(on[0], off))
            e = hm_short(local_from_epoch(last, off))
            if a[-1] == e[-1]:
                a = a[:-1]     # "2:39-6:49A" when both are AM or both PM
            span = a + "-" + e
            c.text(span, x + 89, y, font = "4x5", color = "white", align = "right")
    c.line(95, 8, 95, 31, color = "#2A2E38")

def moon_phase(c, ctx):
    # Drawn Moon lit to its phase, % lit, next full and new Moon.
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
    now = ctx.now.unix
    e0 = state_at("Moon", loc["lat"], loc["lon"], now)[4]
    e1 = state_at("Moon", loc["lat"], loc["lon"], now + 3600)[4]
    waxing = e1 > e0
    f = illum_from_elong(e0)
    c.fill("black")
    cx, cy, r = 16, 16, 13
    for dy in range(-r, r + 1):
        w = math.sqrt(max(0.0, r * r - dy * dy))
        c.line(int(cx - w + 0.5), cy + dy, int(cx + w + 0.5), cy + dy, color = "#24262C")
        edge = w * (1.0 - 2.0 * f)
        xa, xb = (cx + edge, cx + w) if waxing else (cx - w, cx - edge)
        if xb > xa:
            c.line(int(xa + 0.5), cy + dy, int(xb + 0.5), cy + dy, color = "#E8E4D0")
    if f >= 0.98:
        name = "FULL MOON"
    elif f <= 0.02:
        name = "NEW MOON"
    elif abs(f - 0.5) < 0.04:
        name = "FIRST QUARTER" if waxing else "LAST QUARTER"
    elif f < 0.5:
        name = "WAXING CRESCENT" if waxing else "WANING CRESCENT"
    else:
        name = "WAXING GIBBOUS" if waxing else "WANING GIBBOUS"
    c.text(name, 36, 2, font = "5x7", color = "#E8E4D0")
    c.text(str(int(f * 100 + 0.5)) + "% LIT", 36, 11, font = "4x5", color = "white")
    # next full and new: the Sun-Moon angle's next peak and trough
    full_t, new_t = None, None
    prev = e0
    rising = waxing
    for k in range(1, 30 * 8):
        t = now + k * 3 * 3600
        e = state_at("Moon", loc["lat"], loc["lon"], t)[4]
        if rising and e < prev and full_t == None:
            full_t = t - 3 * 3600
            rising = False
        elif not rising and e > prev and new_t == None:
            new_t = t - 3 * 3600
            rising = True
        prev = e
        if full_t != None and new_t != None:
            break
    if off != None:
        for i, (label, t, col) in enumerate((("FULL", full_t, "#F5C542"), ("NEW", new_t, "gray"))):
            if t != None:
                lt = local_from_epoch(t, off)
                c.text(label + " " + WEEKDAYS[lt["wd"]] + " " + str(lt["mo"]) + "/" + str(lt["d"]), 36 + i * 78, 20, font = "4x5", color = col)

def radec_of(b, t):
    if b == "Moon":
        ra, dec, _ = moon_radec(t)
    else:
        ra, dec, _ = planet_radec(body_key(b), t)
    return ra, dec

EVENT_SEP = {"Moon": 5.0}    # how close counts as a close pass, deg (planet pairs: 3)

def sky_events(c, ctx):
    # Close passes between the Moon and the planets (and planet pairs) in
    # the next 30 days, skipping any too near the Sun to see.
    got = page_setup(c, ctx)
    if got == None:
        return
    body, auto, loc, off = got
    now = ctx.now.unix
    c.fill("black")
    mini_header(c, "SKY EVENTS", "NEXT 30 DAYS", "#F5C542")
    pairs = []
    for i in range(len(SKY_BODIES)):
        for j in range(i + 1, len(SKY_BODIES)):
            pairs.append((SKY_BODIES[i], SKY_BODIES[j]))
    prev = {}
    falling = {}
    events = []
    step = 3 * 3600
    for k in range(0, 30 * 8):
        t = now + k * step
        tc = julian_centuries(jd_from_unix(t))
        pos = {b: radec_of(b, tc) for b in SKY_BODIES}
        sra, sdec, _ = sun_radec(tc)
        for a, b in pairs:
            key = a + b
            sep = angular_sep(pos[a][0], pos[a][1], pos[b][0], pos[b][1])
            if key in prev:
                if sep > prev[key] and falling.get(key, False):
                    limit = EVENT_SEP.get(a, 3.0)
                    clear = angular_sep(pos[a][0], pos[a][1], sra, sdec) > 20.0 and angular_sep(pos[b][0], pos[b][1], sra, sdec) > 20.0
                    if prev[key] <= limit and clear:
                        events.append((t - step, a, b, prev[key]))
                falling[key] = sep < prev[key]
            prev[key] = sep
    events = sorted(events)
    if not events or off == None:
        c.text("NO CLOSE PASSES COMING UP", 96, 16, font = "4x5", color = "gray", align = "center")
        return
    for i, (t, a, b, sep) in enumerate(events[:3]):
        y = 9 + i * 8
        lt = local_from_epoch(t, off)
        c.text(WEEKDAYS[lt["wd"]] + " " + str(lt["mo"]) + "/" + str(lt["d"]), 3, y + 1, font = "4x5", color = "gray")
        x = 48
        c.text(a.upper(), x, y, font = "5x7", color = BODY_COLOR[a])
        x += c.text_width(a.upper(), "5x7") + 4
        c.text("+", x, y, font = "5x7", color = "gray")
        x += 10
        c.text(b.upper(), x, y, font = "5x7", color = BODY_COLOR[b])
        c.text(str(int(sep + 0.5)) + " DEG APART", c.width - 4, y + 1, font = "4x5", color = "white", align = "right")
