# ISS Next Sighting (128x32)
#
# When and where to look up for the next naked-eye-visible passes of the
# International Space Station over a US zip code. 8 pages: an intro card,
# the next three sightings each paired with its own rise/peak/set
# directions (sighting/path, sighting2/path2, sighting3/path3 - #2/#3 are
# simply whichever visible passes come after #1 chronologically, not a
# ranking), and a crew roster. The header on the six pass pages shows each
# pass's own local weekday, since a sighting found late at night is often
# actually "tomorrow" locally.
#
# Four lookups, all keyless except one:
#   1. zippopotam.us          - zip -> city, latitude, longitude
#   2. timeapi.io             - lat/lon -> the true UTC offset right now
#                                (DST folded in)
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

WEEKDAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0]]
DOWN = [[0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]
PEAK = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]

# Rise/set/peak icon colors on the path pages - mirrors the up/down/new
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

# Earth's limb for the intro page's bottom third: a shallow parabola, full
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

EARTH_CURVE = _earth_curve(128, 11)
EARTH_CURVE_SHORT = _earth_curve(128, 6)
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

def pad3(n):
    if n < 10:
        return "00" + str(n)
    if n < 100:
        return "0" + str(n)
    return str(n)

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
# usually swallow it anyway. This makes our end-of-visibility symmetric with
# the same real-world threshold startVisibility already lands close to.
VISIBLE_EL_THRESHOLD = 10.0

def time_at_elevation(threshold, t0, el0, t1, el1):
    # el0 (at t0) is assumed >= el1 (at t1) - descending from the peak.
    if el0 <= threshold:
        return t0  # already at/below threshold by the peak - no descending arm above it
    if el1 >= threshold:
        return t1  # never actually crosses (shouldn't normally happen for the descending arm)
    frac = (el0 - threshold) / (el0 - el1)
    return int(float(t0) + frac * float(t1 - t0))

def dhms_str(secs):
    if secs < 0:
        secs = 0
    d = secs // 86400
    rem = secs % 86400
    h = rem // 3600
    rem = rem % 3600
    m = rem // 60
    s = rem % 60
    if d > 0:
        return str(d) + "D " + pad2(h) + "H " + pad2(m) + "M " + pad2(s) + "S"
    if h > 0:
        return str(h) + "H " + pad2(m) + "M " + pad2(s) + "S"
    if m > 0:
        return str(m) + "M " + pad2(s) + "S"
    return str(s) + "S"

def duration_str(secs):
    return str(secs // 60) + "M " + pad2(secs % 60) + "S"

# The local-time line still mixes fonts (AM/PM smaller than the digits), so
# it builds a list of (text, font, y_offset) parts for draw_mixed() rather
# than a plain string - see UNIT_FONT/UNIT_DY below.
UNIT_FONT = "3x4"
UNIT_DY = 1

def hms_ap(hour, minute, second):
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + pad2(minute) + ":" + pad2(second), ap

def fmt12_range_parts(h1, mi1, s1, h2, mi2, s2):
    # Drop the repeated AM/PM when both ends fall in the same half of the day.
    t1, ap1 = hms_ap(h1, mi1, s1)
    t2, ap2 = hms_ap(h2, mi2, s2)
    if ap1 == ap2:
        return [
            (t1, "4x5", 0), (" - ", "4x5", 0), (t2, "4x5", 0),
            (" ", "4x5", 0), (ap2, UNIT_FONT, UNIT_DY),
        ]
    return [
        (t1, "4x5", 0), (" ", "4x5", 0), (ap1, UNIT_FONT, UNIT_DY),
        (" - ", "4x5", 0), (t2, "4x5", 0), (" ", "4x5", 0), (ap2, UNIT_FONT, UNIT_DY),
    ]

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
    # background color for the word - dark slate (dimmest) fading up to
    # gold (brightest), interpolated evenly across all 8 steps. Mirrors how
    # a faint vs. brilliant point of light actually looks, rather than
    # borrowing a red/green good-bad convention.
    if mag <= -4.0:
        return "DAZZLING", "#FFD700"
    if mag <= -3.0:
        return "BRILLIANT", "#E5C20B"
    if mag <= -2.0:
        return "VIVID", "#CAAE17"
    if mag <= -1.0:
        return "BRIGHT", "#B09922"
    if mag <= 0.0:
        return "CLEAR", "#95842E"
    if mag <= 1.0:
        return "VISIBLE", "#7B6F39"
    if mag <= 2.5:
        return "FAINT", "#605B45"
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

def utc_offset_hours(lat, lon):
    # The offset only changes twice a year, so an hour of cache is plenty.
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
            "forecast_days": "4",
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

def moon_illumination_pct(epoch):
    cycles = (float(epoch) - float(MOON_NEW_EPOCH)) / 86400.0 / MOON_SYNODIC
    p = cycles - float(int(cycles))
    if p < 0.0:
        p = p + 1.0
    illum = (1.0 - math.cos(TWO_PI * p)) / 2.0
    return int(illum * 100.0 + 0.5)

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

CREW_URL = "https://ll.thespacedevs.com/2.2.0/spacestation/4/"

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

def crew_names():
    r = fetch_crew()
    if r["status_code"] != 200:
        r = fetch_crew_stale()
        if r["status_code"] != 200:
            return None
    names = []
    seen = {}
    for exp in r["json"].get("active_expeditions", []):
        for c in exp.get("crew", []):
            a = c.get("astronaut", {})
            aid = a.get("id")
            if aid in seen:
                continue
            seen[aid] = True
            full = str(a.get("name", "")).upper()
            words = full.split(" ")
            names.append(words[len(words) - 1])
    return names

def wrap(c, words, font, maxw):
    lines = []
    cur = ""
    for w in words:
        trial = cur + " " + w if cur else w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines

# Builds the full display dict for one N2YO pass, or returns None if it's
# fully washed out (see next_sighting) - a washed-out pass isn't a sighting
# at all, so it's excluded rather than surfaced as an error card.
def evaluate_pass(p, loc, off, cloud_resp, now):
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

    # Symmetric with the start: cut the descending arm off at the same real-
    # world elevation threshold, rather than N2YO's near-horizon endUTC/endEl.
    end0 = time_at_elevation(VISIBLE_EL_THRESHOLD, max_utc, max_el_raw, end_utc, end_el_raw)

    # Further clamp to the sun's own -6 deg (civil twilight) crossing on
    # whichever side applies - a pass can be well above 10 deg elevation and
    # still be washed out by an approaching dawn or a lingering dusk. This is
    # now THE definition of start/end used everywhere below, not a separate
    # number - it's simply the most correct one we can get to.
    start = start0
    end = end0
    washed_out = False
    if off != None:
        lt0 = local_from_epoch(start0, off)
        weekday = WEEKDAYS[lt0["wd"]] + " " + str(lt0["mo"]) + "/" + str(lt0["d"])
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
        "start_az_deg": int(start_az + 0.5),
        "start_el": int(start_el + 0.5),
        "max_az": str(p.get("maxAzCompass", "")).upper(),
        "max_az_deg": int(float(p.get("maxAz", 0)) + 0.5),
        "max_el": int(p.get("maxEl", 0)),
        "end_az": compass_name(final_end_az),
        "end_az_deg": int(final_end_az + 0.5),
        "end_el": int(final_end_el + 0.5),
    }

def next_sighting(ctx, index = 0):
    zip = _s(ctx, "zip")
    key = _s(ctx, "apikey")

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

    off = utc_offset_hours(loc["lat"], loc["lon"])
    cloud_resp = fetch_cloud_cover(loc["lat"], loc["lon"])

    # Passes fully swallowed by twilight (evaluate_pass -> None) are skipped
    # outright rather than counted - "next 3 sightings" means next 3 you can
    # actually see, not next 3 the satellite happens to fly over.
    visible = []
    for p in upcoming:
        result = evaluate_pass(p, loc, off, cloud_resp, now)
        if result != None:
            visible.append(result)
        if len(visible) > index:
            break

    if len(visible) <= index:
        return {
            "ok": False,
            "title": "SIGHTING #" + str(index + 1),
            "sub": "ONLY " + str(len(visible)) + " VISIBLE IN 10 DAYS",
        }

    return visible[index]

# ---------- drawing ----------

def draw_mixed(c, x, y, parts, color, align = "left"):
    # Draws a row built from (text, font, y_offset) parts, each in its own
    # font - c.text() only takes one font per call, so a line mixing sizes
    # has to be assembled piece by piece like this.
    if align == "center":
        total = 0
        for text, font, _dy in parts:
            total += c.text_width(text, font)
        cur = x - total // 2
    else:
        cur = x
    for text, font, dy in parts:
        c.text(text, cur, y + dy, font = font, color = color, align = "left")
        cur += c.text_width(text, font)

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

def _err(c, d):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "#0B2559")
    # Icon, not the old "ISS SIGHTING" wordmark - the intro dropped that
    # text already, so keeping it only here read as a mismatched leftover.
    c.bitmap(ISS_ICON, 51, 1, "cyan")

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

def draw_header(c, tag, city, bar, tag_color = "cyan", max_city_width = None):
    # picopixel, not 4x5 - "weekday + month + day" plus a long city name no
    # longer fit side by side at 4x5 without colliding.
    c.rect(0, 0, c.width - 1, 8, fill = bar)
    c.text(tag, 3, 2, font = "picopixel", color = tag_color, align = "left")

    # Always leave room past the tag - a city like "TRUTH OR CONSEQUENCES,
    # NM" (zip 87901) is long enough to run into it even at picopixel.
    # Sighting pages additionally pass max_city_width to also clear the
    # brightness-tinted ISS icon sitting in the bar's center; whichever cap
    # is tighter wins.
    tag_gap_cap = c.width - 9 - c.text_width(tag, "picopixel")
    cap = tag_gap_cap if max_city_width == None else min(max_city_width, tag_gap_cap)
    shown_city = truncate_to_width(c, city, "picopixel", cap)
    c.text(shown_city, c.width - 3, 2, font = "picopixel", color = "white", align = "right")

def draw_word_badge(c, x_right, y, text, bg):
    # A filled rect sized to the word, right edge pinned at x_right. The
    # slate-to-gold scale spans dark to light, so pick whichever text color
    # actually contrasts against this particular fill.
    w = c.text_width(text, "4x5")
    x0 = x_right - w
    textcolor = "white" if brightness(bg) < 140 else "black"
    c.rect(x0 - 1, y, x_right, y + 5, fill = bg)
    c.text(text, x0, y, font = "4x5", color = textcolor, align = "left")

def draw_look_row(c, y, icon, icon_color, label, az, az_deg, el):
    c.bitmap(icon, 3, y, icon_color)
    c.text(label, 10, y, font = "4x5", color = "white", align = "left")
    # Fixed columns (rather than one right-aligned blob) so AZ/ELEV line up
    # row to row regardless of how many letters the compass point takes.
    c.text("AZ", 40, y, font = "4x5", color = "gray", align = "left")
    c.text(pad3(az_deg), 52, y, font = "4x5", color = "gray", align = "left")
    c.text(az, 69, y, font = "4x5", color = "gray", align = "left")
    c.text("ELEV", 90, y, font = "4x5", color = "gray", align = "left")
    c.text(str(el), 112, y, font = "4x5", color = "gray", align = "left")

# ---------- pages ----------

def intro(c, ctx):
    c.clear()
    c.text("ISS", 3, 4, font = "7x12", color = "white", align = "left")
    # one row down so the stack doesn't merge with the top edge
    c.text("NEXT", 102, 3, font = "4x5", color = "gray", align = "center")
    c.text("3", 102, 9, font = "4x5", color = "gray", align = "center")
    c.text("SIGHTINGS", 102, 15, font = "4x5", color = "gray", align = "center")
    c.bitmap(ISS_ICON, 51, 8, "cyan")
    # A handful of stars in the empty space around the text/icon (never
    # below y21 - the curve's own black background already reads as space
    # there, and would just hide them anyway).
    c.rect(5, 1, 5, 1, fill = "white")
    c.rect(63, 1, 63, 1, fill = "gray")
    c.rect(119, 1, 119, 1, fill = "white")
    c.rect(38, 6, 38, 6, fill = "gray")
    c.rect(40, 15, 40, 15, fill = "white")
    c.rect(78, 5, 78, 5, fill = "white")
    c.rect(78, 17, 78, 17, fill = "gray")
    c.rect(60, 18, 60, 18, fill = "gray")
    c.rect(2, 19, 2, 19, fill = "white")
    c.bitmap(EARTH_CURVE, 0, 21, EARTH_COLOR)
    # Landmasses spread across the limb, each sized to how much of the band
    # is actually earth at that x (the parabola leaves only 1-3 rows near
    # the corners vs the full 11 at center) - hand-placed with margin inside
    # that filled area so nothing pokes out past the ocean into black.
    c.rect(8, 29, 14, 31, fill = LAND_COLOR)
    c.rect(28, 24, 35, 27, fill = LAND_COLOR)
    c.rect(55, 21, 72, 26, fill = LAND_COLOR)
    c.rect(92, 25, 99, 28, fill = LAND_COLOR)
    c.rect(114, 29, 120, 31, fill = LAND_COLOR)

def draw_sighting_page(c, ctx, index):
    d = next_sighting(ctx, index)
    if not d["ok"]:
        _err(c, d)
        return

    label, bg = bright_label(d["mag"])

    c.fill("black")
    # 46px cap on the city text leaves the bar's center clear for the icon
    # below (icon spans x51-77, +2px margin) - see draw_header.
    draw_header(c, d["weekday"], d["city"], "#0B2559", max_city_width = 46)
    # Center of the header bar is otherwise empty (tag/city sit at the two
    # edges) - tinting the icon with the same brightness color as the badge
    # below reinforces dazzling-vs-faint right at a glance.
    c.bitmap(ISS_ICON, 51, 1, bg)

    starts_in = d["start"] - d["now"]
    is_live = starts_in <= 0 and d["now"] < d["end"]

    if is_live:
        headline = "VISIBLE NOW!"
        headline_color = "yellow"
    else:
        headline = "STARTS IN " + dhms_str(starts_in)
        headline_color = "white"
    c.text(headline, c.width // 2, 9, font = "4x5", color = headline_color, align = "center")

    if d["off"] != None:
        t1 = local_from_epoch(d["start"], d["off"])
        t2 = local_from_epoch(d["end"], d["off"])
        when_parts = fmt12_range_parts(t1["h"], t1["mi"], t1["s"], t2["h"], t2["mi"], t2["s"])
    else:
        when_parts = [("LOCAL TIME UNKNOWN", "4x5", 0)]
    draw_mixed(c, c.width // 2, 15, when_parts, "gray", align = "center")

    moon_pct = moon_illumination_pct(d["start"])
    if d["cloud_pct"] != None:
        cloud_line = "CLOUDS " + str(d["cloud_pct"]) + "% - MOON " + str(moon_pct) + "%"
        cloud_color_ = cloud_color(d["cloud_pct"])
    else:
        cloud_line = "CLOUDS N/A - MOON " + str(moon_pct) + "%"
        cloud_color_ = "gray"
    c.text(cloud_line, c.width // 2, 21, font = "picopixel", color = cloud_color_, align = "center")

    c.text("DURATION " + duration_str(d["duration"]), 3, 27, font = "4x5", color = "gray", align = "left")
    draw_word_badge(c, c.width - 3, 27, label, bg)

def sighting(c, ctx):
    draw_sighting_page(c, ctx, 0)

def sighting2(c, ctx):
    draw_sighting_page(c, ctx, 1)

def sighting3(c, ctx):
    draw_sighting_page(c, ctx, 2)

def draw_path_page(c, ctx, index):
    d = next_sighting(ctx, index)
    if not d["ok"]:
        _err(c, d)
        return

    c.fill("black")
    draw_header(c, d["weekday"], d["city"], "purple")

    # Stars in the thin gaps between rows (and after the last row) - these
    # bands never have text drawn in them regardless of row content, so
    # placement here needs no width-checking against anything.
    c.rect(20, 15, 20, 15, fill = "white")
    c.rect(105, 14, 105, 14, fill = "gray")
    c.rect(60, 23, 60, 23, fill = "white")
    c.rect(15, 30, 15, 30, fill = "gray")
    c.rect(115, 30, 115, 30, fill = "white")

    draw_look_row(c, 9, UP, RISE_COLOR, "RISE", d["start_az"], d["start_az_deg"], d["start_el"])
    draw_look_row(c, 17, PEAK, PEAK_COLOR, "PEAK", d["max_az"], d["max_az_deg"], d["max_el"])
    draw_look_row(c, 25, DOWN, SET_COLOR, "SET", d["end_az"], d["end_az_deg"], d["end_el"])

def crew(c, ctx):
    names = crew_names()
    if names == None:
        _err(c, {"title": "CREW LOOKUP FAILED", "sub": "TRY AGAIN LATER"})
        return
    if not names:
        _err(c, {"title": "NO CREW DATA", "sub": "EMPTY RESPONSE"})
        return

    c.fill("black")
    draw_header(c, "CREW", str(len(names)) + " ABOARD", "green", tag_color = "black")

    lines = wrap(c, names, "picopixel", 122)[:3]
    y = 10   # one row clear of the green header bar
    for line in lines:
        c.text(line, c.width // 2, y, font = "picopixel", color = "gray", align = "center")
        y += 6

    # Band starts at y26 - clear of even the worst case (3 name lines,
    # ending around y26) - so the curve never collides with the roster,
    # only with the days-aboard line drawn on top of it below.
    c.bitmap(EARTH_CURVE_SHORT, 0, 26, EARTH_COLOR)
    # Same idea as the intro's landmasses, scaled to this shorter 6-row
    # band - checked against _earth_curve(128, 6)'s parabola the same way.
    c.rect(15, 29, 20, 30, fill = LAND_COLOR)
    c.rect(55, 26, 72, 28, fill = LAND_COLOR)
    c.rect(100, 28, 106, 29, fill = LAND_COLOR)

    days = (ctx.now.unix - ISS_CREWED_SINCE) // 86400
    c.text("ISS OCCUPIED " + str(days) + " DAYS STRAIGHT", c.width // 2, 27, font = "picopixel", color = "white", align = "center")

def path(c, ctx):
    draw_path_page(c, ctx, 0)

def path2(c, ctx):
    draw_path_page(c, ctx, 1)

def path3(c, ctx):
    draw_path_page(c, ctx, 2)
