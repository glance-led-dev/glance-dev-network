# ISS Next Sighting - small (64x32)
#
# The 64x32 sibling of apps/iss-sighting. Same pass lookups and math
# (twilight clamp, 10 deg cutoff, clouds, moon), just re-laid-out for half
# the width: the big app's one "sighting" page carries time range + clouds +
# moon + duration + brightness side by side, which can't fit in 64px, so
# each pass here gets three pages instead of two - WHEN (start time,
# duration, brightness), SKY (clouds + moon) and PATH (rise/peak/set).
# Kept to the single next pass (the big app shows three) and no crew page:
# 4 pages - intro, when, sky, path.
#
# Three lookups, all keyless except one:
#   1. zippopotam.us          - zip -> city, latitude, longitude
#   2. timeapi.io             - lat/lon -> the true UTC offset right now
#   3. api.n2yo.com           - lat/lon -> the next 10 days of visible
#                                passes. Needs a free API key from n2yo.com.
# See apps/iss-sighting/app.star for the longer write-up of each source.

NORAD_ISS = "25544"

# Moon illumination - pure math, no lookup, no rate-limit risk. Synodic month
# length and a known new-moon reference epoch (2000-01-06 18:14 UTC) are the
# same constants the moon-phase app in this repo uses.
MOON_SYNODIC = 29.530588853
MOON_NEW_EPOCH = 947182440
TWO_PI = 6.283185307179586

WEEKDAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

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

EARTH_CURVE = _earth_curve(64, 8)
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

def duration_str(secs):
    return str(secs // 60) + "M " + pad2(secs % 60) + "S"

# The local-time line still mixes fonts (AM/PM smaller than the digits), so
# it builds a list of (text, font, y_offset) parts for draw_mixed() rather
# than a plain string - see UNIT_FONT/UNIT_DY below.
MAIN_FONT = "4x7"
UNIT_FONT = "3x4"
# 4x7 and 4x5 share identical per-glyph widths (only height differs), so this
# was a safe drop-in bump from 4x5 for "a tad larger" text. UNIT_DY re-tuned
# to 3 (from 1) so the shorter AM/PM suffix still bottom-aligns against the
# now-taller main digits (7 rows vs 4).
UNIT_DY = 3

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
            (t1, MAIN_FONT, 0), (" - ", MAIN_FONT, 0), (t2, MAIN_FONT, 0),
            (" ", MAIN_FONT, 0), (ap2, UNIT_FONT, UNIT_DY),
        ]
    return [
        (t1, MAIN_FONT, 0), (" ", MAIN_FONT, 0), (ap1, UNIT_FONT, UNIT_DY),
        (" - ", MAIN_FONT, 0), (t2, MAIN_FONT, 0), (" ", MAIN_FONT, 0), (ap2, UNIT_FONT, UNIT_DY),
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

HEADER_BAR = "#0B2559"

def draw_mixed(c, x, y, parts, color, align = "left"):
    # c.text() only takes one font per call, so a line mixing sizes (big
    # digits, small AM/PM) is assembled piece by piece.
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

def draw_page_edges(c, left = True):
    # Same 1px page-break seam as the big app - only the intro draws a left
    # edge so neighbouring pages never double up into a 2px line.
    if left:
        c.rect(0, 0, 0, c.height - 1, fill = "gray")
    c.rect(c.width - 1, 0, c.width - 1, c.height - 1, fill = "gray")

def draw_header(c, tag, right, bar = HEADER_BAR, tag_color = "white", right_color = "cyan"):
    # No room for the city at 64px - "THU 9/24" alone is 31px in 3x7 - so
    # the right side carries a short page label (#1/SKY/PATH) instead.
    c.rect(0, 0, c.width - 1, 8, fill = bar)
    c.text(tag, 2, 1, font = "3x7", color = tag_color, align = "left")
    if right:
        c.text(right, c.width - 3, 1, font = "3x7", color = right_color, align = "right")

def draw_wrapped(c, text, font, color, y, line_h, max_lines):
    lines = wrap(c, text.split(" "), font, c.width - 4)[:max_lines]
    for line in lines:
        c.text(line, c.width // 2, y, font = font, color = color, align = "center")
        y += line_h
    return y

def _err(c, d):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = HEADER_BAR)
    c.bitmap(ISS_ICON, 21, 1, "cyan")
    y = draw_wrapped(c, d["title"], "4x7", "orange", 10, 8, 2)
    draw_wrapped(c, d["sub"], "picopixel", "gray", y + 1, 6, 2)
    draw_page_edges(c, left = False)

# Same fact list as the big app, but at 64px each one wraps across two or
# three lines, so a filler page shows a single fact.
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
    "TOILET CURTAIN, NOT A DOOR",
    "CREW EXERCISES 2 HRS A DAY",
    "RECYCLES URINE INTO WATER",
]

def draw_filler(c, ctx, page_number, headline = None):
    c.fill("black")
    draw_header(c, "ISS FACT", "")
    if headline != None:
        draw_wrapped(c, headline, "4x7", "orange", 10, 8, 3)
    else:
        # Only two fact pages remain, so rotate by day - otherwise a long
        # no-sightings stretch would show the same two facts every time.
        day = ctx.now.unix // 86400
        fact = FILLER_FACTS[(day * 2 + page_number) % len(FILLER_FACTS)]
        draw_wrapped(c, fact, "4x7", "gray", 10, 8, 3)
    draw_page_edges(c, left = False)

def get_pass(c, ctx, page_number, headline_page):
    # Shared "fetch or draw the fallback" step for all three pass pages.
    # Returns the pass dict, or None once a fallback page has been drawn.
    # With no visible pass in the next 10 days, the when page says so and
    # the sky/path pages show ISS facts instead of repeating it.
    d = next_sighting(ctx)
    if d["ok"]:
        return d
    if d.get("insufficient"):
        headline = "NO SIGHTINGS IN 10 DAYS" if headline_page else None
        draw_filler(c, ctx, page_number, headline = headline)
    else:
        _err(c, d)
    return None

def pass_header(c, d, right):
    # A live pass swaps the navy bar for gold on every page of that pass.
    is_live = d["now"] >= d["start"] and d["now"] < d["end"]
    if is_live:
        draw_header(c, d["weekday"], "NOW", bar = "#FFD700", tag_color = "black", right_color = "black")
    else:
        draw_header(c, d["weekday"], right)
    return is_live

# ---------- pages ----------

def intro(c, ctx):
    c.clear()
    c.text("ISS", 3, 3, font = "7x12", color = "white", align = "left")
    c.bitmap(ISS_ICON, 38, 5, "cyan")
    c.text("SIGHTINGS", 3, 14, font = "picopixel", color = "gray", align = "left")
    c.rect(33, 1, 33, 1, fill = "white")
    c.rect(59, 2, 59, 2, fill = "gray")
    c.rect(20, 21, 20, 21, fill = "gray")
    c.rect(46, 15, 46, 15, fill = "white")
    c.rect(55, 21, 55, 21, fill = "white")
    c.bitmap(EARTH_CURVE, 0, 24, EARTH_COLOR)
    c.rect(6, 29, 10, 31, fill = LAND_COLOR)
    c.rect(26, 25, 36, 28, fill = LAND_COLOR)
    c.rect(50, 28, 55, 30, fill = LAND_COLOR)
    draw_page_edges(c)

def sighting(c, ctx):
    d = get_pass(c, ctx, 0, True)
    if d == None:
        return
    c.fill("black")
    is_live = pass_header(c, d, "NEXT")

    if d["off"] != None:
        t = local_from_epoch(d["start"], d["off"])
        hms, ap = hms_ap(t["h"], t["mi"], t["s"])
        parts = [(hms, "5x7", 0), (" ", "3x7", 0), (ap, UNIT_FONT, UNIT_DY)]
    else:
        parts = [("TIME ?", "5x7", 0)]
    draw_mixed(c, c.width // 2, 10, parts, "yellow" if is_live else "white", align = "center")

    c.text("FOR " + duration_str(d["duration"]), c.width // 2, 18, font = "3x7", color = "gray", align = "center")

    # Brightness as a full-width bottom bar rather than a corner badge - it's
    # the one thing on this page that says "worth going outside for".
    label, bg = bright_label(d["mag"])
    c.rect(1, 25, c.width - 2, 31, fill = bg)
    textcolor = "white" if brightness(bg) < 140 else "black"
    c.text(label, c.width // 2, 26, font = "4x5", color = textcolor, align = "center")
    draw_page_edges(c, left = False)

CLOUD_ICON = _icon([
    "....###....",
    "..#######..",
    ".#########.",
    "###########",
    "###########",
    ".#########.",
])

def sky(c, ctx):
    d = get_pass(c, ctx, 1, False)
    if d == None:
        return
    c.fill("black")
    pass_header(c, d, "SKY")

    # Two columns, icon over number - the icons carry the "clouds"/"moon"
    # labels so the numbers can use the bigger font.
    if d["cloud_pct"] != None:
        pct = d["cloud_pct"]
        c.bitmap(CLOUD_ICON, 11, 12, cloud_color(pct))
        c.text(str(pct) + "%", 16, 22, font = "4x7", color = cloud_color(pct), align = "center")
    else:
        c.bitmap(CLOUD_ICON, 11, 12, "gray")
        c.text("N/A", 16, 22, font = "4x7", color = "gray", align = "center")

    phase = moon_phase_fraction(d["start"])
    draw_moon_icon(c, 47, 15, MOON_ICON_R, phase)
    c.text(str(moon_illumination_pct(phase)) + "%", 47, 22, font = "4x7", color = "white", align = "center")
    draw_page_edges(c, left = False)

def draw_degree(c, x, y, color):
    # No degree glyph in the bundled fonts - a hollow 3x3 ring does the job.
    c.rect(x, y, x + 2, y, fill = color)
    c.rect(x, y + 2, x + 2, y + 2, fill = color)
    c.pixel(x, y + 1, color)
    c.pixel(x + 2, y + 1, color)

def draw_look_row(c, y, verb, color, az, el):
    # Compass + elevation only - the raw azimuth degrees the big app shows
    # don't fit, and the 16-point compass name is what you actually use.
    c.text(verb, 2, y, font = "4x7", color = color, align = "left")
    c.text(az, 26, y, font = "4x7", color = color, align = "left")
    el_x = c.width - 7
    c.text(str(el), el_x, y, font = "4x7", color = color, align = "right")
    draw_degree(c, el_x + 1, y, color)

def path(c, ctx):
    d = get_pass(c, ctx, 2, False)
    if d == None:
        return
    c.fill("black")
    pass_header(c, d, "PATH")
    draw_look_row(c, 9, "RISE", RISE_COLOR, d["start_az"], d["start_el"])
    draw_look_row(c, 17, "PEAK", PEAK_COLOR, d["max_az"], d["max_el"])
    draw_look_row(c, 25, "SET", SET_COLOR, d["end_az"], d["end_el"])
    draw_page_edges(c, left = False)
