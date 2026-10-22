# ISS Next Sighting (192x32)
#
# When and where to look up for the next naked-eye-visible passes of the
# International Space Station over a US zip code. 8 pages: an intro card,
# the next three sightings each paired with its own rise/peak/set
# directions (sighting/path, sighting2/path2, sighting3/path3 - #2/#3 are
# simply whichever visible passes come after #1 chronologically, not a
# ranking), and a crew roster. Each path page also draws the pass as an
# arc on a small sky map. The header on the six pass pages shows each
# pass's own local weekday, since a sighting found late at night is often
# actually "tomorrow" locally.
#
# Four lookups, all keyless except one:
#   1. zippopotam.us          - zip -> city, latitude, longitude
#   2. timeapi.io             - lat/lon -> the zip's time zone offsets and
#                                DST window, applied per pass
#   3. api.n2yo.com           - lat/lon -> the next 10 days of passes
#                                bright/high enough to actually see, with
#                                compass directions already worked out.
#                                Needs a free API key from n2yo.com.
#   4. ll.thespacedevs.com    - who's aboard right now. This is TheSpaceDevs'
#                                Launch Library, an actively-maintained
#                                aggregator - open-notify.org's astros.json
#                                looked keyless-simpler but turned out to be
#                                a frozen, years-stale snapshot. Querying
#                                the ISS's own spacestation record instead
#                                of a global "everyone in space" list also
#                                sidesteps Tiangong's crew and "Starman"
#                                (the mannequin in Musk's Roadster, which
#                                that other list genuinely counts).

NORAD_ISS = "25544"

# Expedition 1 docked 2000-11-02T00:00:00 UTC - continuous human presence
# on the ISS has held ever since.
ISS_CREWED_SINCE = 973123200

# Moon illumination - pure math, no lookup, no rate-limit risk. Synodic month
# length and a known new-moon reference epoch (2000-01-06 18:14 UTC) are the
# same constants the moon-phase app in this repo uses.
MOON_SYNODIC = 29.530588853
MOON_NEW_EPOCH = 947182440
TWO_PI = 6.283185307179586

WEEKDAYS_LONG = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# Rise/set/peak text colors on the path pages - mirrors the up/down/new
# trend-color language the sibling MLB leaderboard apps already use.
RISE_COLOR = "#2ECC71"
SET_COLOR = "#E74C3C"
PEAK_COLOR = "#FFD700"

def _icon(rows):
    # "#"/"." art -> the 0/1 matrices c.bitmap() actually expects. Starlark
    # strings aren't iterable (unlike Python), so index by position instead.
    return [[1 if row[i] == "#" else 0 for i in range(len(row))] for row in rows]

ISS_SOLAR = [
    "######",
    "#.#.#.",
    "#.#.#.",
    "#.#.#.",
    "######",
]
ISS_TRUSS = [
    "...",
    "...",
    "###",
    "...",
    "...",
]
ISS_HULL = [
    "...##...",
    "########",
    "########",
    "########",
    "...##...",
]
ISS_ICON = _icon([
    ISS_SOLAR[i] + ISS_TRUSS[i] + ISS_HULL[i] + ISS_TRUSS[i] + ISS_SOLAR[i]
    for i in range(5)
])

# Earth's limb for the crew page's bottom band: a shallow parabola, full
# height at the center column, tapering to a single pixel at each bottom
# corner - no arc/circle primitive exists here, only rect/text/bitmap, so
# this is computed once at load time the same way ISS_ICON is built.
def _earth_curve(width, height):
    half = (width - 1) / 2.0
    rows = []
    for r in range(height):
        row = []
        for x in range(width):
            xn = (x - half) / half
            top_row = int((height - 1) * xn * xn + 0.5)
            row.append(1 if r >= top_row else 0)
        rows.append(row)
    return rows

EARTH_CURVE_SHORT = _earth_curve(192, 6)
EARTH_COLOR = "#1E63B8"
LAND_COLOR = "#3E8E41"

# ---------- input ----------

def _s(ctx, key):
    # An unset input can come back as None, so coerce before .strip().
    v = ctx.inputs.get(key, "")
    if v == None:
        return ""
    return str(v).strip()

# ---------- formatting ----------

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

# ---------- position at an arbitrary instant between N2YO's given points ----------
# N2YO only gives az/el at startUTC/maxUTC/endUTC, not at startVisibility, so
# the rise direction has to be interpolated between the two points that
# straddle it.

COMPASS_NAMES = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                 "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

def compass_name(az):
    idx = int((az + 11.25) / 22.5) % 16
    return COMPASS_NAMES[idx]

def interp_az(az1, az2, t):
    # Shortest way around the circle, not straight arithmetic (350 -> 10
    # should sweep through 360/0, not back through 180).
    diff = az2 - az1
    if diff > 180.0:
        diff = diff - 360.0
    elif diff < -180.0:
        diff = diff + 360.0
    result = az1 + diff * t
    if result < 0.0:
        result = result + 360.0
    if result >= 360.0:
        result = result - 360.0
    return result

def interp_at(t_target, t0, az0, el0, t1, az1, el1):
    if t1 == t0:
        return az0, el0
    t = float(t_target - t0) / float(t1 - t0)
    if t < 0.0:
        t = 0.0
    if t > 1.0:
        t = 1.0
    return interp_az(az0, az1, t), el0 + (el1 - el0) * t

# Heavens-Above and Pollux Labs both cut visibility off at 10 deg elevation
# rather than N2YO's near-horizon endEl - below 10 deg, haze/buildings/trees
# usually swallow it anyway. Applied to both the rise and the set.
VISIBLE_EL_THRESHOLD = 10.0

def time_at_elevation(threshold, t0, el0, t1, el1):
    # el0 (at t0) is assumed >= el1 (at t1) - walking away from the peak.
    # t1 can be before t0 (the rising arm) - the interpolation still holds.
    if el0 <= threshold:
        return t0  # already at/below threshold by the peak - no descending arm above it
    if el1 >= threshold:
        return t1  # never actually crosses (shouldn't normally happen for the descending arm)
    frac = (el0 - threshold) / (el0 - el1)
    return int(float(t0) + frac * float(t1 - t0))

def duration_parts(secs, df, uf, udy):
    # "DURATION 9M 37S" with the M/S units in a smaller, bottom-aligned font.
    return [
        ("DURATION ", df, 0), (str(secs // 60), df, 0), ("1", "gap", 0), ("M", uf, udy),
        (" ", df, 0), (pad2(secs % 60), df, 0), ("1", "gap", 0), ("S", uf, udy),
    ]

# Path-page rows. The sighting page's time line mixes fonts (AM/PM smaller
# than the digits) via time_parts() + draw_mixed().
MAIN_FONT = "4x7"

def hms_ap(hour, minute, second):
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + pad2(minute) + ":" + pad2(second), ap

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
    return {
        "h": sod // 3600, "mi": (sod % 3600) // 60, "s": sod % 60,
        "wd": (days + 3) % 7, "y": y, "mo": mo, "d": d, "days": days,
    }

def bright_label(mag):
    # Real apparent-magnitude tiers (lower = brighter; Venus peaks around
    # -4.7, the ISS itself tops out near -3.9 on a great pass). Returns a
    # background color for the word. A straight linear RGB blend from gold
    # to dark slate put the middle tiers in a muddy olive-khaki band, so this
    # instead holds an amber hue at high saturation and only ramps value down
    # tier by tier - DAZZLING through VISIBLE all read as vivid warm colors,
    # and only FAINT/DIM actually desaturate toward gray/slate, matching how
    # a genuinely faint pass looks washed out rather than just less golden.
    if mag <= -4.0:
        return "DAZZLING", "#FFCC00"
    if mag <= -3.0:
        return "BRILLIANT", "#E6B000"
    if mag <= -2.0:
        return "VIVID", "#D19200"
    if mag <= -1.0:
        return "BRIGHT", "#BF7D0A"
    if mag <= 0.0:
        return "CLEAR", "#AD6A11"
    if mag <= 1.0:
        return "VISIBLE", "#94602C"
    if mag <= 2.5:
        return "FAINT", "#735845"
    return "DIM", "#464650"

# ---------- the lookups ----------
# Returns {"ok": True, ...} or {"ok": False, "title":..., "sub":...} so both
# pages render the same failure the same way.

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

def tz_info(lat, lon):
    # The zip's own time zone, plus this year's DST window, so a pass after
    # a DST change (inside the 10-day lookahead) still gets its own offset.
    t = http.get(
        "https://timeapi.io/api/TimeZone/coordinate",
        params = {"latitude": str(lat), "longitude": str(lon)},
        ttl_seconds = 3600,
    )
    if t["status_code"] != 200:
        return None
    j = t["json"]
    cur = j.get("currentUtcOffset", {}).get("seconds", None)
    if cur == None:
        return None
    info = {"cur": float(cur) / 3600.0, "std": None}
    dst = j.get("dstInterval")
    std = j.get("standardUtcOffset", {}).get("seconds", None)
    if j.get("hasDayLightSaving") and dst and std != None:
        info["std"] = float(std) / 3600.0
        info["dst"] = float(dst.get("dstOffsetToUtc", {}).get("seconds", cur)) / 3600.0
        info["dst_start"] = iso_utc_epoch(str(dst.get("dstStart", "")))
        info["dst_end"] = iso_utc_epoch(str(dst.get("dstEnd", "")))
    return info

def iso_utc_epoch(s):
    # "2026-11-01T06:00:00Z" -> unix seconds; None if it doesn't parse.
    if len(s) < 19:
        return None
    y = int(s[0:4])
    mo = int(s[5:7])
    d = int(s[8:10])
    return _days_from_civil(y, mo, d) * 86400 + int(s[11:13]) * 3600 + int(s[14:16]) * 60 + int(s[17:19])

def offset_at(tz, epoch):
    if tz == None:
        return None
    if tz["std"] == None or tz["dst_start"] == None or tz["dst_end"] == None:
        return tz["cur"]
    if epoch >= tz["dst_start"] and epoch < tz["dst_end"]:
        return tz["dst"]
    return tz["std"]

def fetch_passes(lat, lon, apikey):
    return http.get(
        "https://api.n2yo.com/rest/v1/satellite/visualpasses/" + NORAD_ISS + "/" +
            str(lat) + "/" + str(lon) + "/0/10/60/",
        params = {"apiKey": apikey},
        # Passes don't shift on short notice - stay well inside N2YO's rate limit.
        ttl_seconds = 1800,
    )

def fetch_cloud_cover(lat, lon):
    return http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": str(lat),
            "longitude": str(lon),
            "hourly": "cloud_cover",
            "timezone": "UTC",
            "forecast_days": "10",
        },
        ttl_seconds = 1800,
    )

def cloud_pct_at(resp, target_epoch, now_epoch):
    # The hourly array starts at today's UTC midnight (confirmed against the
    # live API), so the right hour is pure epoch arithmetic - no timestamp
    # parsing needed.
    if resp["status_code"] != 200:
        return None
    values = resp["json"].get("hourly", {}).get("cloud_cover", [])
    if not values:
        return None
    midnight = now_epoch - (now_epoch % 86400)
    idx = (target_epoch - midnight) // 3600
    if idx < 0 or idx >= len(values):
        return None
    return int(values[idx])

def cloud_color(pct):
    # Sky blue (clear) fading to gray (overcast) - what the sky actually
    # looks like, not a good/bad traffic-light read.
    if pct <= 20:
        return "skyblue"
    if pct <= 60:
        return "#87B9CB"
    return "gray"

def moon_phase_fraction(epoch):
    # 0.0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter.
    cycles = (float(epoch) - float(MOON_NEW_EPOCH)) / 86400.0 / MOON_SYNODIC
    p = cycles - float(int(cycles))
    if p < 0.0:
        p = p + 1.0
    return p

def moon_illumination_pct(p):
    illum = (1.0 - math.cos(TWO_PI * p)) / 2.0
    return int(illum * 100.0 + 0.5)

def _moon_lit(dx, dy, r, t, waxing):
    # Same terminator equation the sibling moon-phase app uses (an ellipse
    # whose half-width is t * w, t = cos(2*pi*phase)) - just at icon scale,
    # and fixed to the Northern-hemisphere view since this app is US-only.
    w = math.sqrt(float(r * r - dy * dy))
    x = float(dx)
    if waxing:
        return x >= t * w
    return x <= -t * w

MOON_LIT_COLOR = "#F7E7C1"
MOON_DARK_COLOR = "#23252E"
MOON_ICON_R = 4

def draw_moon_icon(c, cx, cy, r, p):
    t = math.cos(TWO_PI * p)
    waxing = p < 0.5
    rr = r * r
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > rr:
                continue
            color = MOON_LIT_COLOR if _moon_lit(dx, dy, r, t, waxing) else MOON_DARK_COLOR
            c.pixel(cx + dx, cy + dy, color)

# ---------- true visibility window (sun below the horizon, not just satellite geometry) ----------
# A pass can be well above 10 deg elevation and still be washed out by daylight
# if it happens close to dawn/dusk. This finds when the SUN crosses civil
# twilight (-6 deg) on the relevant side of the pass, using the same
# sunrise-equation family as the moon-phase/world-clock apps in this repo,
# plus an equation-of-time correction (they skip it; we need the extra
# accuracy here since some visible windows are only tens of seconds long).
# Verified against the `astral` library on two real passes: 26-37 sec off,
# in line with the precision we already accept elsewhere in this app.

def _days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def day_of_year(local_days, y, mo, d):
    return local_days - _days_from_civil(y, 1, 1) + 1

def solar_decl_eot(yday):
    b = math.radians(360.0 / 365.0 * (float(yday) - 81.0))
    decl = 23.45 * math.sin(b)
    eot = 9.87 * math.sin(2.0 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b)
    return decl, eot

def sun_hour_angle(lat, decl, target_el):
    cosw = (math.sin(math.radians(target_el)) - math.sin(math.radians(lat)) * math.sin(math.radians(decl))) / (math.cos(math.radians(lat)) * math.cos(math.radians(decl)))
    if cosw < -1.0:
        cosw = -1.0
    if cosw > 1.0:
        cosw = 1.0
    return math.degrees(math.acos(cosw)) / 15.0

def twilight_epoch(local_days, lat, lon, off_hours, yday, is_dawn):
    decl, eot = solar_decl_eot(yday)
    w = sun_hour_angle(lat, decl, -6.0)
    noon_local = 12.0 - lon / 15.0 + off_hours - eot / 60.0
    cross_local = noon_local - w if is_dawn else noon_local + w
    return int(float(local_days) * 86400.0 + cross_local * 3600.0 - off_hours * 3600.0)

def az_el_at(t, start_utc, start_az, start_el, max_utc, max_az, max_el, end_utc, end_az, end_el):
    if t <= max_utc:
        return interp_at(t, start_utc, start_az, start_el, max_utc, max_az, max_el)
    return interp_at(t, max_utc, max_az, max_el, end_utc, end_az, end_el)

CREW_GAP = 6

CREW_URL = "https://ll.thespacedevs.com/2.2.0/spacestation/4/"

# corquaid's people-in-space list is kept current by hand within hours of a
# crew change (TheSpaceDevs can lag by weeks) and already gives each
# person's flag and the expedition number. TheSpaceDevs is the fallback.
PEOPLE_URL = "https://corquaid.github.io/international-space-station-APIs/JSON/people-in-space.json"

def crew_from_people():
    r = http.get(PEOPLE_URL, ttl_seconds = 21600)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    names = []
    for p in r["json"].get("people", []):
        if p.get("iss") != True:
            continue
        code = str(p.get("flag_code", "")).upper()
        names.append((str(p.get("name", "")).upper(), code if code in FLAGS else None))
    if not names:
        return None
    exp = r["json"].get("iss_expedition")
    return names, ("EXPEDITION " + str(exp)) if exp != None else ""

def fetch_crew():
    # spacestation/4 is the ISS itself - onboard_crew/active_expeditions are
    # already scoped to it, so no filtering needed to exclude Tiangong's
    # crew or joke entries (this API also tracks "Starman", the mannequin
    # in Elon Musk's Roadster, as "in space"). People move on and off
    # station every few months, not by the hour.
    return http.get(CREW_URL, ttl_seconds = 86400)

def fetch_crew_stale():
    # Same URL -> same cache entry (ttl_seconds isn't part of the cache key,
    # only how fresh a hit has to be). TheSpaceDevs' anonymous tier throttles
    # hard, so if today's fetch just failed, reach back up to a month for
    # whatever last actually succeeded rather than showing a bare error -
    # the crew rarely changes day to day anyway.
    return http.get(CREW_URL, ttl_seconds = 2592000)

# Agencies that map to one country; anyone else (ESA, private crew) gets a
# one-time astronaut lookup for nationality, cached 30 days.
AGENCY_FLAGS = [
    ("AERONAUTICS AND SPACE ADMINISTRATION", "US"),
    ("ROSCOSMOS", "RU"),
    ("JAPAN AEROSPACE", "JP"),
    ("CANADIAN SPACE", "CA"),
    ("INDIAN SPACE", "IN"),
]
NATIONALITY_FLAGS = {
    "AMERICAN": "US", "RUSSIAN": "RU", "JAPANESE": "JP", "CANADIAN": "CA",
    "FRENCH": "FR", "GERMAN": "DE", "ITALIAN": "IT", "BRITISH": "GB",
    "DANISH": "DK", "SWEDISH": "SE", "INDIAN": "IN", "EMIRATI": "AE",
}

def flag_for(a):
    agency = str(a.get("agency", {}).get("name", "")).upper()
    for needle, code in AGENCY_FLAGS:
        if needle in agency:
            return code
    url = a.get("url")
    if url:
        r = http.get(str(url), ttl_seconds = 2592000)
        if r["status_code"] == 200:
            nat = str(r["json"].get("nationality", "")).upper()
            for word in nat.replace(",", " ").split(" "):
                if word in NATIONALITY_FLAGS:
                    return NATIONALITY_FLAGS[word]
    if "EUROPEAN SPACE" in agency:
        return "ESA"
    return None

def crew_names():
    people = crew_from_people()
    if people != None:
        return people
    r = fetch_crew()
    if r["status_code"] != 200:
        r = fetch_crew_stale()
        if r["status_code"] != 200:
            return None
    names = []
    seen = {}
    exps = r["json"].get("active_expeditions", [])
    for exp in exps:
        for c in exp.get("crew", []):
            a = c.get("astronaut", {})
            aid = a.get("id")
            if aid in seen:
                continue
            seen[aid] = True
            names.append((str(a.get("name", "")).upper(), flag_for(a)))
    exp_label = ""
    if exps:
        exp_label = str(exps[0].get("name", "")).upper()
    return names, exp_label

def evaluate_pass(p, loc, tz, cloud_resp, now):
    # N2YO's own "duration" is endUTC minus startVisibility, not startUTC -
    # startUTC is just the geometric horizon-rise instant, which can still
    # be too dim/low to actually see. Anchoring on startVisibility instead
    # is also just more correct for an app about when you can SEE it.
    start0 = int(p.get("startVisibility", p.get("startUTC", 0)))

    start_utc = int(p.get("startUTC", 0))
    max_utc = int(p.get("maxUTC", 0))
    end_utc = int(p.get("endUTC", 0))
    start_az_raw = float(p.get("startAz", 0))
    start_el_raw = float(p.get("startEl", 0))
    max_az_raw = float(p.get("maxAz", 0))
    max_el_raw = float(p.get("maxEl", 0))
    end_az_raw = float(p.get("endAz", 0))
    end_el_raw = float(p.get("endEl", 0))

    # Cut both arms off at the same real-world elevation threshold, rather
    # than N2YO's near-horizon points. startVisibility alone can sit right at
    # the horizon (0 deg) when the ISS rises already sunlit, so the start is
    # the later of that and the 10 deg crossing on the way up - found via the
    # same interpolation run peak-first, backwards along the rising arm.
    rise0 = time_at_elevation(VISIBLE_EL_THRESHOLD, max_utc, max_el_raw, start_utc, start_el_raw)
    if rise0 > start0:
        start0 = rise0
    end0 = time_at_elevation(VISIBLE_EL_THRESHOLD, max_utc, max_el_raw, end_utc, end_el_raw)

    # Further clamp to the sun's own -6 deg (civil twilight) crossing on
    # whichever side applies - a pass can be well above 10 deg elevation and
    # still be washed out by an approaching dawn or a lingering dusk. This is
    # now THE definition of start/end used everywhere below, not a separate
    # number - it's simply the most correct one we can get to.
    off = offset_at(tz, start0)
    start = start0
    end = end0
    washed_out = False
    if off != None:
        lt0 = local_from_epoch(start0, off)
        weekday = WEEKDAYS_LONG[lt0["wd"]] + " " + MONTHS[lt0["mo"] - 1] + " " + str(lt0["d"])
        yday = day_of_year(lt0["days"], lt0["y"], lt0["mo"], lt0["d"])
        if lt0["h"] < 12:
            dawn_epoch = twilight_epoch(lt0["days"], loc["lat"], loc["lon"], off, yday, True)
            end = start0 if dawn_epoch < start0 else (end0 if dawn_epoch > end0 else dawn_epoch)
        else:
            dusk_epoch = twilight_epoch(lt0["days"], loc["lat"], loc["lon"], off, yday, False)
            start = end0 if dusk_epoch > end0 else (start0 if dusk_epoch < start0 else dusk_epoch)
        washed_out = start >= end
    else:
        weekday = "???"

    if washed_out:
        return None

    cloud_pct = cloud_pct_at(cloud_resp, start, now)

    start_az, start_el = az_el_at(start, start_utc, start_az_raw, start_el_raw, max_utc, max_az_raw, max_el_raw, end_utc, end_az_raw, end_el_raw)
    final_end_az, final_end_el = az_el_at(end, start_utc, start_az_raw, start_el_raw, max_utc, max_az_raw, max_el_raw, end_utc, end_az_raw, end_el_raw)

    return {
        "ok": True,
        "city": loc["city"],
        "now": now,
        "off": off,
        "weekday": weekday,
        "cloud_pct": cloud_pct,
        "start": start,
        "end": end,
        "duration": end - start,
        "mag": float(p.get("mag", 5.0)),
        "start_az": compass_name(start_az),
        "start_az_deg": start_az,
        "start_el": start_el,
        "max_az": str(p.get("maxAzCompass", "")).upper(),
        "max_az_deg": max_az_raw,
        "max_el": max_el_raw,
        "end_az": compass_name(final_end_az),
        "end_az_deg": final_end_az,
        "end_el": final_end_el,
    }

SAMPLE_OFF = -4.0

# Shown instead of a "NO API KEY" card, so the catalog preview shows real
# pages. Fields: day offset, local start second-of-day, duration, magnitude,
# rise az/el, peak az/el, set az/el.
SAMPLE_PASSES = [
    (0, 21 * 3600 + 33 * 60 + 53, 577, -3.4, 292.4, 10.0, 210.7, 54.3, 135.2, 16.4),
    (1, 20 * 3600 + 45 * 60 + 12, 342, -1.6, 250.1, 10.0, 190.6, 28.8, 140.3, 10.0),
    (2, 21 * 3600 + 31 * 60 + 40, 418, 0.4, 315.9, 10.0, 30.2, 71.5, 105.8, 22.1),
]

def sample_sighting(ctx, index):
    now = ctx.now.unix
    days, sod, dur, mag, ra, re, ma, me, sa, se = SAMPLE_PASSES[index]
    start = now - (now + int(SAMPLE_OFF * 3600.0)) % 86400 + sod + days * 86400
    if start <= now:
        start += 86400
    lt = local_from_epoch(start, SAMPLE_OFF)
    return {
        "ok": True,
        "city": "NEW YORK, NY",
        "now": now,
        "off": SAMPLE_OFF,
        "weekday": WEEKDAYS_LONG[lt["wd"]] + " " + MONTHS[lt["mo"] - 1] + " " + str(lt["d"]),
        "cloud_pct": [42, 8, 85][index],
        "start": start,
        "end": start + dur,
        "duration": dur,
        "mag": mag,
        "start_az": compass_name(ra),
        "start_az_deg": ra,
        "start_el": re,
        "max_az": compass_name(ma),
        "max_az_deg": ma,
        "max_el": me,
        "end_az": compass_name(sa),
        "end_az_deg": sa,
        "end_el": se,
    }


def next_sighting(ctx, index = 0):
    zip = _s(ctx, "zip")
    key = _s(ctx, "apikey")

    if not key:
        return sample_sighting(ctx, index)
    if not zip:
        return {"ok": False, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}
    if not key:
        return {"ok": False, "title": "NO API KEY", "sub": "ADD ONE IN SETTINGS"}

    loc = geocode(zip)
    if not loc["ok"]:
        return loc

    r = fetch_passes(loc["lat"], loc["lon"], key)
    if r["status_code"] == 429:
        return {"ok": False, "title": "RATE LIMITED", "sub": "TRY AGAIN LATER"}
    if r["status_code"] != 200:
        return {"ok": False, "title": "API ERROR", "sub": "CODE " + str(r["status_code"])}

    body = r["json"]
    # N2YO reports a bad key as a 200 with an "error" field, not a 401.
    if body.get("error"):
        return {"ok": False, "title": "BAD API KEY", "sub": "CHECK YOUR SETTINGS"}

    now = ctx.now.unix
    passes = body.get("passes", [])

    # The response is cached for 30 min - drop anything that's already
    # ended by the time this particular render actually happens.
    upcoming = [p for p in passes if int(p.get("endUTC", 0)) > now]

    tz = tz_info(loc["lat"], loc["lon"])
    cloud_resp = fetch_cloud_cover(loc["lat"], loc["lon"])

    # Passes fully swallowed by twilight (evaluate_pass -> None) are skipped
    # outright rather than counted - "next 3 sightings" means next 3 you can
    # actually see, not next 3 the satellite happens to fly over.
    visible = []
    for p in upcoming:
        result = evaluate_pass(p, loc, tz, cloud_resp, now)
        if result != None:
            visible.append(result)
        if len(visible) > index:
            break

    if len(visible) <= index:
        # Not a real error - zip/key/API all worked fine, this slot just has
        # no visible pass right now. The page renders filler facts instead
        # of an error card (see draw_filler), so it still needs the city.
        # visible_count is the true total (the loop above only breaks early
        # once it has more than `index` results, so whenever it falls short
        # instead, it ran to completion and this is the real count) - callers
        # use it to tell "zero sightings at all" apart from "ran out partway"
        # and to know whether THIS is the first slot to come up short.
        return {"ok": False, "insufficient": True, "city": loc["city"], "visible_count": len(visible)}

    return visible[index]

# ---------- drawing ----------

def draw_mixed(c, x, y, parts, color, align = "left"):
    # Draws a row built from (text, font, y_offset) parts, each in its own
    # font - c.text() only takes one font per call, so a line mixing sizes
    # has to be assembled piece by piece like this. A ("N", "gap", 0) part
    # is N blank pixels.
    if align == "center":
        cur = x - parts_width(c, parts) // 2
    else:
        cur = x
    for text, font, dy in parts:
        if font != "gap":
            c.text(text, cur, y + dy, font = font, color = color, align = "left")
        cur += _part_w(c, text, font)

def _part_w(c, text, font):
    if font == "gap":
        return int(text)
    return c.text_width(text, font)

def truncate_to_width(c, text, font, max_width):
    # No while loops in this Starlark dialect (Bazel-style, bounded-loops-only),
    # so trim length-by-length with a plain for/range instead.
    if c.text_width(text, font) <= max_width:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i]
        if c.text_width(candidate, font) <= max_width:
            return candidate
    return ""

def draw_page_edges(c, left = True):
    # A 1px light line marking a clean page break while the kiosk scrolls
    # horizontally from one page to the next. Every page draws its own right
    # edge, but only page 1 (intro) also draws a left edge - otherwise a
    # page's right border and the next page's left border would double up
    # into a 2px-thick seam at every transition.
    if left:
        c.rect(0, 0, 0, c.height - 1, fill = "gray")
    c.rect(c.width - 1, 0, c.width - 1, c.height - 1, fill = "gray")

def _err(c, d):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "#0B2559")
    # Icon only, no text wordmark - matches the intro page, which doesn't
    # show one either.
    c.bitmap(ISS_ICON, (c.width - 26) // 2, 1, "cyan")

    # Stars in the gaps around the (variable-length, error-specific)
    # title/sub text - these bands are blank regardless of message length,
    # so no width-checking against the text itself is needed.
    c.rect(20, 9, 20, 9, fill = "white")
    c.rect(105, 10, 105, 10, fill = "gray")
    c.text(d["title"], 4, 12, font = "6x8", color = "orange")
    c.rect(60, 21, 60, 21, fill = "white")
    c.text(d["sub"], 4, 23, font = "4x5", color = "gray")
    c.rect(15, 29, 15, 29, fill = "gray")
    c.rect(115, 29, 115, 29, fill = "white")
    draw_page_edges(c, left = False)

# 5x7 on every page's header bar; the cap below truncates long cities.
HEADER_FONT = "5x7"
HEADER_Y = 1

def draw_header(c, tag, city, bar, tag_color = "cyan", city_color = "white", font = "picopixel", y = 2):
    c.rect(0, 0, c.width - 1, 8, fill = bar)
    c.text(tag, 3, y, font = font, color = tag_color, align = "left")

    # Always leave room past the tag - a city like "TRUTH OR CONSEQUENCES,
    # NM" (zip 87901) is long enough to run into it.
    cap = c.width - 9 - c.text_width(tag, font)
    shown_city = truncate_to_width(c, city, font, cap)
    c.text(shown_city, c.width - 3, y, font = font, color = city_color, align = "right")

# Shown instead of an error card when a slot simply has no visible pass in
# the next 10 days (0/1/2 sightings instead of 3) - zip/key/API all worked,
# so an error card would be misleading. Most important/recognizable facts
# first; each of the up to 6 filler pages (sighting/path x3) gets its own
# slice via page_number, so scrolling through several empty slots doesn't
# just repeat the same three lines. All checked to fit at picopixel width,
# using only glyphs picopixel has (no commas or apostrophes).
FILLER_FACTS = [
    "TRAVELS 17500 MPH",
    "ORBITS EARTH EVERY 90 MIN",
    "ORBITS ABOUT 254 MI UP",
    "LARGEST STRUCTURE IN SPACE",
    "CREWED NONSTOP SINCE NOV 2000",
    "SEES 16 SUNRISES A DAY",
    "SOLAR ARRAYS SPAN 356 FT",
    "BUILT BY 15 COUNTRIES",
    "FIRST PIECE LAUNCHED NOV 1998",
    "SIZE OF A FOOTBALL FIELD",
    "WEIGHS NEARLY 1 MILLION LBS",
    "TRAVELS 5 MILES PER SECOND",
    "CABIN VOLUME LIKE A 747 JET",
    "VISIBLE TO THE NAKED EYE",
    "3RD BRIGHTEST OBJECT IN SKY",
    "TOILET HAS A CURTAIN NOT A DOOR",
    "CREW EXERCISES 2 HRS A DAY",
    "RECYCLES URINE INTO WATER",
    "CIRCLES EARTH 15.5 TIMES A DAY",
    "FIRST MODULE WAS RUSSIAN ZARYA",
    "FIRST US MODULE WAS UNITY",
    "TOOK 42 FLIGHTS TO ASSEMBLE",
    "COST ABOUT $150 BILLION",
    "MOST EXPENSIVE THING EVER BUILT",
    "RUN BY 5 SPACE AGENCIES",
    "ASTRONAUTS FROM 20+ COUNTRIES",
    "FIRST CREW ARRIVED NOV 2 2000",
    "FIRST TOURIST: DENNIS TITO 2001",
    "LONGEST ISS STAY: 371 DAYS",
    "ROBOT ARM CANADARM2 IS 57 FT",
    "CUPOLA HAS 7 WINDOWS",
    "KIBO IS ITS LARGEST MODULE",
    "US EUROPE AND JAPAN EACH HAVE A LAB",
    "8 MILES OF WIRING ON BOARD",
    "52 COMPUTERS RUN THE STATION",
    "OVER 350000 SENSORS ON BOARD",
    "BIGGER THAN A 6-BEDROOM HOUSE",
    "HAS 2 BATHROOMS AND A GYM",
    "ORBIT TILTED 51.6 DEGREES",
    "FLIES OVER 90% OF ALL PEOPLE",
    "COAST TO COAST IN ABOUT 9 MIN",
    "ENGINES REBOOST IT AGAINST DRAG",
    "PLANNED TO DEORBIT AROUND 2030",
    "RECOVERS 98% OF ITS WATER",
    "MAKES OXYGEN BY SPLITTING WATER",
    "AIR KEPT AT SEA-LEVEL PRESSURE",
    "STATION CLOCKS RUN ON GMT",
    "ASTRONAUTS GROW UP TO 2 IN TALLER",
    "CREW HAS GROWN AND EATEN LETTUCE",
    "HAM RADIO LINKS CREW TO SCHOOLS",
    "3000+ EXPERIMENTS RUN ON BOARD",
    "SALT AND PEPPER COME AS LIQUIDS",
    "TORTILLAS BEAT BREAD - NO CRUMBS",
    "SHINES BY REFLECTED SUNLIGHT",
    "STEADY LIGHT - PLANES BLINK",
    "BEST SEEN NEAR DAWN OR DUSK",
    "CREW SLEEPS IN WALL-MOUNTED BAGS",
]

def draw_filler(c, city, page_number, headline = None, day = 0):
    c.fill("black")
    draw_header(c, "ISS FACT", city, "#0B2559", tag_color = "white", font = HEADER_FONT, y = HEADER_Y)

    y = 9
    if headline != None:
        # Only the very first slot to come up short carries this - it takes
        # one of the three line slots, so this page shows 2 facts instead of 3.
        c.text(headline, c.width // 2, y, font = "picopixel", color = "orange", align = "center")
        y += 8

    # Six filler slots x 3 facts, shifted by the day so the whole list rotates.
    start = (day * 18 + page_number * 3) % len(FILLER_FACTS)
    num_facts = 2 if headline != None else 3
    for i in range(num_facts):
        fact = FILLER_FACTS[(start + i) % len(FILLER_FACTS)]
        c.text(fact, c.width // 2, y, font = "picopixel", color = "gray", align = "center")
        y += 8
    draw_page_edges(c, left = False)

# No font here has a degree glyph, so it's a raised 3x3 ring.
DEGREE_MARK = _icon([
    ".#.",
    "#.#",
    ".#.",
])

def deg1(v):
    # One decimal place, rounded; 359.96 wraps to 0.0 rather than 360.0.
    t = int(float(v) * 10.0 + 0.5)
    return str(t // 10) + "." + str(t % 10)

def draw_look_row(c, y, verb, color, az, el):
    # Fixed columns (verb / compass point / elevation) so the three rows
    # line up. The 16-point compass name plus the sky map show direction;
    # "ELEVATION 90.0" plus the degree mark ends at x=131, clear of the
    # sky map's W label.
    c.text(verb, 3, y, font = MAIN_FONT, color = color, align = "left")
    c.text(az, 32, y, font = MAIN_FONT, color = color, align = "left")
    el_text = "ELEVATION " + deg1(el)
    c.text(el_text, 56, y, font = MAIN_FONT, color = color, align = "left")
    c.bitmap(DEGREE_MARK, 56 + c.text_width(el_text, MAIN_FONT) + 1, y, color)

# ---------- pages ----------

# Intro artwork: a multi-color station (sun-side wings lit brighter), a
# night-side Earth with city lights, and the sun rising over the limb.
ISS_ART = [
    "ggggg.ggggg...........................hhhhh.hhhhh",
    "GGGGG.GGGGG...........................HHHHH.HHHHH",
    "ggggg.ggggg...........................hhhhh.hhhhh",
    "GGGGG.GGGGG............mmM.......rrr..HHHHH.HHHHH",
    "ggggg.ggggg............mmM.......rrr..hhhhh.hhhhh",
    "GGGGG.GGGGG............mmM.......rrr..HHHHH.HHHHH",
    "..t.....t........mmmmmmmmMmmmmmm........t.....t..",
    "tttttttttttttttttmmmmmmmmMmmmmmmttttttttttttttttt",
    "..t.....t........MMMMMMmmMMMMMMM........t.....t..",
    "ggggg.ggggg..rrr.......mmM............hhhhh.hhhhh",
    "GGGGG.GGGGG..rrr.......mmM............HHHHH.HHHHH",
    "ggggg.ggggg..rrr.......mmM............hhhhh.hhhhh",
    "GGGGG.GGGGG...........................HHHHH.HHHHH",
    "ggggg.ggggg...........................hhhhh.hhhhh",
    "GGGGG.GGGGG...........................HHHHH.HHHHH",
]
ISS_LEGEND = {"g": "#C98F1E", "G": "#6A420C", "h": "#FFD45C", "H": "#A8701A", "t": "#B8C0CC", "m": "#F2F4F8", "M": "#8C95A3", "r": "#D8E8F4"}

INTRO_EARTH_CX = 112
INTRO_EARTH_CY = 189
INTRO_EARTH_R = 170
INTRO_SUN_X = 166

INTRO_STARS = [
    (3, 1, "#FFFFFF"), (19, 4, "#6E7891"), (44, 2, "#B8C2D9"), (52, 16, "#6E7891"),
    (61, 3, "#FFFFFF"), (64, 18, "#B8C2D9"), (8, 21, "#6E7891"), (126, 1, "#B8C2D9"),
    (131, 9, "#6E7891"), (122, 17, "#FFFFFF"), (188, 2, "#6E7891"), (183, 21, "#B8C2D9"),
    (47, 11, "#3E4660"), (58, 9, "#3E4660"), (127, 13, "#3E4660"), (2, 13, "#3E4660"),
    (36, 20, "#3E4660"), (69, 1, "#6E7891"), (137, 4, "#3E4660"), (110, 1, "#6E7891"),
    (28, 18, "#B8C2D9"), (190, 12, "#3E4660"), (176, 16, "#3E4660"),
]

CITY_COLORS = ["#FFD98A", "#FFB04A", "#B0722A", "#704818"]

def _city_lights():
    out = []
    seed = 7
    for i in range(70):
        seed = (seed * 1103515245 + 12345) % 2147483648
        x = 46 + (seed // 65536) % 130
        seed = (seed * 1103515245 + 12345) % 2147483648
        y = 20 + (seed // 65536) % 12
        out.append((x, y, CITY_COLORS[(seed // 4096) % 4]))
    return out

INTRO_CITIES = _city_lights()

def _limb_y(x):
    dx = float(x - INTRO_EARTH_CX)
    return INTRO_EARTH_CY - int(math.sqrt(float(INTRO_EARTH_R * INTRO_EARTH_R) - dx * dx) + 0.5)

def _mix(a, b, t):
    if t < 0.0:
        t = 0.0
    if t > 1.0:
        t = 1.0
    out = "#"
    for i in (1, 3, 5):
        va = int(a[i:i + 2], 16)
        vb = int(b[i:i + 2], 16)
        v = int(va + (vb - va) * t + 0.5)
        out += "0123456789ABCDEF"[v // 16] + "0123456789ABCDEF"[v % 16]
    return out

def _airglow(x):
    # Orbital sunrise: gold right at the sun, sky blue along the lit limb,
    # fading to deep navy on the far night side.
    d = x - INTRO_SUN_X
    if d < 0:
        d = -d
    if d < 10:
        return _mix("#FFE7A0", "#FF7A1A", d / 10.0)
    if d < 28:
        return _mix("#FF7A1A", "#4FB6FF", (d - 10) / 18.0)
    return _mix("#4FB6FF", "#123A8A", (d - 28) / 70.0)

def intro(c, ctx):
    c.fill("#000000")
    c.gradient_rect(0, 0, 191, 31, "#000000", "#06102A", horizontal = False)
    for x, y, col in INTRO_STARS:
        c.pixel(x, y, col)

    # The sun breaking over the limb, drawn before the Earth so the planet
    # hides its lower half.
    sy = _limb_y(INTRO_SUN_X)
    for r, col in [(10, "#1E0C02"), (8, "#4A1E05"), (6, "#93400B"), (5, "#E86A12"), (4, "#FF9A30"), (3, "#FFC15E"), (2, "#FFE9A8"), (1, "#FFFFFF")]:
        c.fill_circle(INTRO_SUN_X, sy, r, col)
    for dx, dy in [(1, -1), (-1, -1)]:
        for k in range(2, 10):
            c.pixel(INTRO_SUN_X + dx * k, sy + dy * k, _mix("#FFE9A8", "#000000", float(k) / 10.0))

    # Night-side Earth with a lit rim and two rows of airglow above it.
    for x in range(192):
        ly = _limb_y(x)
        if ly > 31:
            continue
        glow = _airglow(x)
        if ly - 2 >= 0:
            c.pixel(x, ly - 2, _mix("#000000", glow, 0.35))
        if ly - 1 >= 0:
            c.pixel(x, ly - 1, glow)
        c.pixel(x, ly, _mix(glow, "#0B1E45", 0.55))
        if ly + 1 <= 31:
            c.line(x, ly + 1, x, 31, "#081634")
    for x, y, col in INTRO_CITIES:
        if y > _limb_y(x) + 1 and (x - INTRO_SUN_X > 14 or INTRO_SUN_X - x > 14):
            c.pixel(x, y, col)

    # Lens flare across the horizon and a short vertical spike.
    c.gradient_rect(INTRO_SUN_X - 70, sy, INTRO_SUN_X - 2, sy, "#000000", "#FFE9A8")
    c.gradient_rect(INTRO_SUN_X + 2, sy, 191, sy, "#FFE9A8", "#3A2008")
    c.gradient_rect(INTRO_SUN_X, sy - 14, INTRO_SUN_X, sy - 2, "#000000", "#FFF3C8", horizontal = False)
    c.pixel(INTRO_SUN_X, sy, "#FFFFFF")

    # Orbit path: dotted arc concentric with the Earth, a fading trail
    # behind the station and a faint path ahead.
    iss_x = 76
    orbit_off = 10
    for x in range(0, 192, 3):
        if x > iss_x - 4 and x < iss_x + 52:
            continue
        y = _limb_y(x) - orbit_off
        if y < 0 or y > 31:
            continue
        if x < iss_x:
            col = _mix("#0E1830", "#7FD8FF", float(x - 40) / float(iss_x - 40))
        else:
            col = "#1C2A48"
        c.pixel(x, y, col)

    c.sprite(ISS_ART, iss_x, _limb_y(iss_x + 24) - orbit_off - 7, legend = ISS_LEGEND)

    c.text("ISS", 4, 3, font = "10x16_bold", color = "#FFFFFF", align = "left")
    c.text("UPCOMING", 4, 21, font = "4x5", color = "#7FD8FF", align = "left")
    c.text("SIGHTINGS", 4, 27, font = "4x5", color = "#7FD8FF", align = "left")
    draw_page_edges(c)

CLOUD_ICON = _icon([
    "..##.....",
    ".####.##.",
    "#########",
    "#########",
    ".#######.",
])

def time_parts(t1, t2, tf, uf):
    # Drop the repeated AM/PM when both ends fall in the same half of the day.
    a1, p1 = hms_ap(t1["h"], t1["mi"], t1["s"])
    a2, p2 = hms_ap(t2["h"], t2["mi"], t2["s"])
    if p1 == p2:
        return [(a1, tf, 0), ("2", "gap", 0), ("-", tf, 0), ("2", "gap", 0), (a2, tf, 0), (" ", tf, 0), (p2, uf, 3)]
    return [(a1, tf, 0), (" ", tf, 0), (p1, uf, 3), ("2", "gap", 0), ("-", tf, 0), ("2", "gap", 0), (a2, tf, 0), (" ", tf, 0), (p2, uf, 3)]

def parts_width(c, parts):
    w = 0
    for text, font, _dy in parts:
        w += _part_w(c, text, font)
    return w

BEST_STAR = _icon([
    "...#...",
    "...#...",
    "#######",
    ".#####.",
    "..###..",
    ".##.##.",
    "##...##",
])

def is_best_pass(ctx, index):
    # The brightest of the visible passes (ties -> higher peak). Only marked
    # when there are at least two to choose between.
    best = -1
    best_key = None
    count = 0
    for i in range(3):
        d = next_sighting(ctx, i)
        if not d["ok"]:
            break
        count += 1
        key = (d["mag"], -d["max_el"])
        if best_key == None or key < best_key:
            best_key = key
            best = i
    return count >= 2 and best == index

def draw_best_star(c, tag, color):
    c.bitmap(BEST_STAR, 3 + c.text_width(tag, HEADER_FONT) + 4, 1, color)

def draw_sighting_page(c, ctx, index, page_number):
    d = next_sighting(ctx, index)
    if not d["ok"]:
        if d.get("insufficient"):
            # index == visible_count exactly on the first slot to come up
            # short (see next_sighting) - every later slot is insufficient
            # too, but only this one, on its sighting page, gets the headline.
            headline = None
            if index == d["visible_count"]:
                if d["visible_count"] == 0:
                    headline = "NO SIGHTINGS IN NEXT 10 DAYS"
                else:
                    headline = "NO OTHER SIGHTINGS IN 10 DAYS"
            draw_filler(c, d["city"], page_number, headline = headline, day = ctx.now.unix // 86400)
        else:
            _err(c, d)
        return

    label, bg = bright_label(d["mag"])
    # No "STARTS IN X" countdown here - the data (and this render) is only
    # refreshed on the manifest's `refresh:` cadence, so a live countdown
    # would just freeze mid-count and read as wrong for most of that window.
    # (Peak elevation lives on the path pages instead - no need to repeat it
    # here too.)
    is_live = d["now"] >= d["start"] and d["now"] < d["end"]

    c.fill("black")
    if is_live:
        # A live pass gets an inverted, dazzling gold header instead of the
        # usual navy one - "look up now" should read at a glance, not just
        # from a single tinted line of text.
        draw_header(c, d["weekday"], d["city"], "#FFD700", tag_color = "black", city_color = "black", font = HEADER_FONT, y = HEADER_Y)
    else:
        # City name gets the header's full width, same as path pages - the
        # brightness cue already lives on the badge at the bottom of the page.
        draw_header(c, d["weekday"], d["city"], "#0B2559", tag_color = "white", font = HEADER_FONT, y = HEADER_Y)

    if is_best_pass(ctx, index):
        draw_best_star(c, d["weekday"], "#0B2559" if is_live else "#FFD700")

    if is_live:
        # A scatter of bright sparkle points in the header's top/bottom
        # border rows - the tag/city text (drawn at y=1, 7px tall) never
        # touches y=0 or y=8, so this stays clear regardless of how long
        # either string is.
        c.rect(15, 0, 15, 0, fill = "white")
        c.rect(60, 8, 60, 8, fill = "white")
        c.rect(100, 0, 100, 0, fill = "white")
        c.rect(35, 8, 35, 8, fill = "white")

    # Row 1: time window on the left, cloud + moon readouts on the right.
    # Row 2: duration and the brightness badge. Each text steps down to a
    # narrower font only when the widest cases (12:xx times, passes that
    # cross midnight, 10+ minute durations) would otherwise collide.
    if d["cloud_pct"] != None:
        cloud_str = str(d["cloud_pct"]) + "%"
        cloud_col = cloud_color(d["cloud_pct"])
    else:
        cloud_str = "N/A"
        cloud_col = "gray"
    moon_phase = moon_phase_fraction(d["start"])
    moon_str = str(moon_illumination_pct(moon_phase)) + "%"

    x_end = c.width - 3
    moon_x = x_end - c.text_width(moon_str, "4x7")
    moon_cx = moon_x - 3 - MOON_ICON_R
    cloud_x = moon_cx - MOON_ICON_R - 7 - c.text_width(cloud_str, "4x7")
    cloud_icon_x = cloud_x - 2 - len(CLOUD_ICON[0])
    c.text(moon_str, moon_x, 10, font = "4x7", color = "white", align = "left")
    draw_moon_icon(c, moon_cx, 13, MOON_ICON_R, moon_phase)
    c.text(cloud_str, cloud_x, 10, font = "4x7", color = cloud_col, align = "left")
    c.bitmap(CLOUD_ICON, cloud_icon_x, 11, cloud_col)

    time_color = "yellow" if is_live else "white"
    if d["off"] != None:
        t1 = local_from_epoch(d["start"], d["off"])
        t2 = local_from_epoch(d["end"], d["off"])
        for tf, uf in [("5x7", "3x4"), ("4x7", "3x4")]:
            parts = time_parts(t1, t2, tf, uf)
            if parts_width(c, parts) <= cloud_icon_x - 6 - 3:
                break
    else:
        parts = [("TIME UNKNOWN", "5x7", 0)]
    draw_mixed(c, 3, 10, parts, time_color)

    label_w = c.text_width(label, "5x7b")
    badge_x0 = x_end - label_w - 3
    c.rect(badge_x0, 21, x_end, 29, fill = bg)
    textcolor = "white" if brightness(bg) < 140 else "black"
    c.text(label, badge_x0 + 2, 22, font = "5x7b", color = textcolor, align = "left")

    for df, uf, udy, dy in [("7x10", "5x7", 3, 20), ("6x8", "4x5", 3, 21), ("4x7", "3x4", 3, 22)]:
        dur = duration_parts(d["duration"], df, uf, udy)
        if parts_width(c, dur) <= badge_x0 - 6 - 3:
            break
    draw_mixed(c, 3, dy, dur, "gray")
    draw_page_edges(c, left = False)

def sighting(c, ctx):
    draw_sighting_page(c, ctx, 0, 0)

def sighting2(c, ctx):
    draw_sighting_page(c, ctx, 1, 2)

def sighting3(c, ctx):
    draw_sighting_page(c, ctx, 2, 4)

SKY_RING = "#2A4A80"
SKY_LABEL = "#6F86B0"

def _arc_points(d, steps):
    # Rise -> peak -> set, interpolated in az/el between the three fixes.
    pts = []
    for i in range(steps + 1):
        t = float(i) / float(steps)
        if t <= 0.5:
            u = t * 2.0
            az = interp_az(float(d["start_az_deg"]), float(d["max_az_deg"]), u)
            el = d["start_el"] + (d["max_el"] - d["start_el"]) * u
        else:
            u = (t - 0.5) * 2.0
            az = interp_az(float(d["max_az_deg"]), float(d["end_az_deg"]), u)
            el = d["max_el"] + (d["end_el"] - d["max_el"]) * u
        pts.append((az, el, t))
    return pts

def _arc_color(t):
    if t < 0.15:
        return RISE_COLOR
    if t > 0.85:
        return SET_COLOR
    return PEAK_COLOR

def _rnd(v):
    return int(math.floor(v + 0.5))

def draw_sky_dome(c, cx, cy, r, d):
    # Sky map, N up / E right: ring = horizon, center = straight overhead.
    for i in range(72):
        a = math.radians(i * 5.0)
        c.pixel(cx + _rnd(math.sin(a) * r), cy - _rnd(math.cos(a) * r), SKY_RING)
    c.pixel(cx, cy, SKY_RING)
    c.pixel(cx, cy - r, "white")
    c.text("E", cx + r + 2, cy - 2, font = "3x4", color = SKY_LABEL, align = "left")
    c.text("W", cx - r - 5, cy - 2, font = "3x4", color = SKY_LABEL, align = "left")
    for az, el, t in _arc_points(d, 40):
        rr = float(r) * (90.0 - el) / 90.0
        a = math.radians(az)
        c.pixel(cx + _rnd(math.sin(a) * rr), cy - _rnd(math.cos(a) * rr), _arc_color(t))
    for az, el, col in [(d["start_az_deg"], d["start_el"], RISE_COLOR), (d["max_az_deg"], d["max_el"], PEAK_COLOR), (d["end_az_deg"], d["end_el"], SET_COLOR)]:
        rr = float(r) * (90.0 - el) / 90.0
        a = math.radians(float(az))
        x = cx + _rnd(math.sin(a) * rr)
        y = cy - _rnd(math.cos(a) * rr)
        c.rect(x - 1, y - 1, x + 1, y + 1, fill = col)

DOME_CX = 170

def draw_path_page(c, ctx, index, page_number):
    d = next_sighting(ctx, index)
    if not d["ok"]:
        if d.get("insufficient"):
            draw_filler(c, d["city"], page_number, day = ctx.now.unix // 86400)
        else:
            _err(c, d)
        return

    c.fill("black")
    draw_header(c, d["weekday"], d["city"], "#0B2559", tag_color = "white", font = HEADER_FONT, y = HEADER_Y)
    if is_best_pass(ctx, index):
        draw_best_star(c, d["weekday"], "#FFD700")
    draw_look_row(c, 9, "RISES", RISE_COLOR, d["start_az"], d["start_el"])
    draw_look_row(c, 17, "PEAKS", PEAK_COLOR, d["max_az"], d["max_el"])
    draw_look_row(c, 25, "SETS", SET_COLOR, d["end_az"], d["end_el"])
    draw_sky_dome(c, DOME_CX, 20, 11, d)
    draw_page_edges(c, left = False)

FLAG_W = 8
FLAG_GAP = 2

# 8x6 flags. Dark colors are lifted a little so they read on black.
FLAG_LEGEND = {
    "R": "#D52B1E", "W": "#FFFFFF", "B": "#1F4FB5", "N": "#1A2E6E",
    "G": "#169B62", "Y": "#FFCC00", "K": "#3A3A3A", "O": "#FF9933",
}
FLAGS = {
    "US": ["NWNRRRRR", "NNNWWWWW", "NWNRRRRR", "WWWWWWWW", "RRRRRRRR", "WWWWWWWW"],
    "RU": ["WWWWWWWW", "WWWWWWWW", "BBBBBBBB", "BBBBBBBB", "RRRRRRRR", "RRRRRRRR"],
    "JP": ["WWWWWWWW", "WWWRRWWW", "WWRRRRWW", "WWRRRRWW", "WWWRRWWW", "WWWWWWWW"],
    "CA": ["RRWWWWRR", "RRWWWWRR", "RRWRRWRR", "RRRRRRRR", "RRWWWWRR", "RRWWWWRR"],
    "FR": ["BBBWWRRR", "BBBWWRRR", "BBBWWRRR", "BBBWWRRR", "BBBWWRRR", "BBBWWRRR"],
    "IT": ["GGGWWRRR", "GGGWWRRR", "GGGWWRRR", "GGGWWRRR", "GGGWWRRR", "GGGWWRRR"],
    "DE": ["KKKKKKKK", "KKKKKKKK", "RRRRRRRR", "RRRRRRRR", "YYYYYYYY", "YYYYYYYY"],
    "GB": ["NNWRRWNN", "WWWRRWWW", "RRRRRRRR", "RRRRRRRR", "WWWRRWWW", "NNWRRWNN"],
    "DK": ["RRWRRRRR", "RRWRRRRR", "WWWWWWWW", "RRWRRRRR", "RRWRRRRR", "RRWRRRRR"],
    "SE": ["BBYBBBBB", "BBYBBBBB", "YYYYYYYY", "BBYBBBBB", "BBYBBBBB", "BBYBBBBB"],
    "IN": ["OOOOOOOO", "OOOOOOOO", "WWWBBWWW", "WWWBBWWW", "GGGGGGGG", "GGGGGGGG"],
    "AE": ["RRGGGGGG", "RRGGGGGG", "RRWWWWWW", "RRWWWWWW", "RRKKKKKK", "RRKKKKKK"],
    "ESA": ["NNNYNNNN", "NYNNNYNN", "NNNNNNNN", "YNNNNNYN", "NNNNNNNN", "NYNNNYNN"],
}

def _short(n, style):
    w = n.split(" ")
    if style == "initial":
        return w[0][:1] + ". " + w[len(w) - 1]
    return w[len(w) - 1]

def _item_w(c, item):
    w = c.text_width(item[0], "picopixel")
    if item[1] in FLAGS:
        w += FLAG_W + FLAG_GAP
    return w

def _pack(c, items, maxw):
    lines = []
    cur = []
    cw = 0
    for it in items:
        w = _item_w(c, it)
        add = w if not cur else w + CREW_GAP
        if cur and cw + add > maxw:
            lines.append(cur)
            cur = [it]
            cw = w
        else:
            cur.append(it)
            cw += add
    if cur:
        lines.append(cur)
    return lines

def fit_crew(c, names):
    # Full names when the roster fits on two lines, else "J. MEIR", else last names.
    lines = _pack(c, names, 184)
    if len(lines) <= 2:
        return lines
    lines = _pack(c, [(_short(n, "initial"), f) for n, f in names], 184)
    if len(lines) <= 2:
        return lines
    return _pack(c, [(_short(n, "last"), f) for n, f in names], 184)[:2]

def crew(c, ctx):
    res = crew_names()
    if res == None:
        _err(c, {"title": "CREW LOOKUP FAILED", "sub": "TRY AGAIN LATER"})
        return
    names, exp_label = res
    if not names:
        _err(c, {"title": "NO CREW DATA", "sub": "EMPTY RESPONSE"})
        return

    c.fill("black")
    draw_header(c, (exp_label + " CREW") if exp_label else "CREW", str(len(names)) + " ABOARD", "green", tag_color = "black", city_color = "black", font = HEADER_FONT, y = HEADER_Y)

    # Each name gets its flag in front, which also separates the names.
    lines = fit_crew(c, names)
    y = 11 if len(lines) == 2 else 15
    for line in lines:
        total = 0
        for i in range(len(line)):
            total += _item_w(c, line[i]) + (CREW_GAP if i > 0 else 0)
        x = (c.width - total) // 2
        for name, flag in line:
            if flag in FLAGS:
                c.sprite(FLAGS[flag], x, y - 1, legend = FLAG_LEGEND)
                x += FLAG_W + FLAG_GAP
            c.text(name, x, y, font = "picopixel", color = "white", align = "left")
            x += c.text_width(name, "picopixel") + CREW_GAP
        y += 8

    # Band starts at y26, below the two name lines (fit_crew never returns more).
    c.bitmap(EARTH_CURVE_SHORT, 0, 26, EARTH_COLOR)
    # Landmasses sized to fit inside _earth_curve(192, 6)'s parabola.
    c.rect(22, 29, 30, 30, fill = LAND_COLOR)
    c.rect(84, 26, 108, 28, fill = LAND_COLOR)
    c.rect(150, 28, 159, 29, fill = LAND_COLOR)

    days = (ctx.now.unix - ISS_CREWED_SINCE) // 86400
    c.text("ISS OCCUPIED " + str(days) + " DAYS STRAIGHT", c.width // 2, 27, font = "picopixel", color = "white", align = "center")
    draw_page_edges(c, left = False)

def path(c, ctx):
    draw_path_page(c, ctx, 0, 1)

def path2(c, ctx):
    draw_path_page(c, ctx, 1, 3)

def path3(c, ctx):
    draw_path_page(c, ctx, 2, 5)
