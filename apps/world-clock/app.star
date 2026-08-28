# World Clock - local time, sunrise & sunset for a US zip code. (2 pages)
#
# Shows off: a config input (zip), two chained HTTP calls, real trig via the
# `math` module, and multi-page layout.
#
# You draw with `c` (mirrors the GDN Canvas) and read config from `ctx.inputs`.
# `ctx.now` is the current UTC time. Each page in manifest.yaml maps to a
# function `def <page>(c, ctx)`.
#
# Two lookups, both keyless:
#   1. zippopotam.us  - zip -> city, latitude, longitude
#   2. timeapi.io     - lat/lon -> the true UTC offset right now
# The offset comes from the tz database, so daylight saving is handled for
# every zone including the ones that opt out (Arizona, Hawaii). The clock
# itself is still computed locally from ctx.now, so it stays minute-accurate
# between refreshes without hammering either API.

WEEKDAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0]]
DOWN = [[0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]
GLASS = [[1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1]]
GLOBE = [[0, 1, 1, 1, 0], [1, 1, 0, 1, 1], [1, 0, 1, 0, 1], [1, 1, 0, 1, 1], [0, 1, 1, 1, 0]]

# ---------- input ----------

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

# ---------- calendar ----------

def _days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

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

# ---------- formatting ----------

def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v

def to_hm(h):
    # Fractional hours -> (hour, minute), wrapped into a day.
    h = math.fmod(h, 24.0)
    if h < 0:
        h = h + 24.0
    hour = int(h)
    return hour, int((h - hour) * 60.0)

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def fmt12(hour, minute):
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + pad2(minute), ap

def fit(c, s, font, maxw):
    # Longest-first truncation with a trailing dot, so a runaway city or zone
    # name shrinks instead of running off the panel (the renderer clips silently).
    if c.text_width(s, font) <= maxw:
        return s
    out = ""
    for i in range(len(s)):
        cand = s[:i + 1] + "."
        if c.text_width(cand, font) > maxw:
            break
        out = cand
    return out

def utc_str(off):
    # Fractional UTC offset -> "UTC-4" / "UTC+5:30".
    sign = "-" if off < 0 else "+"
    a = off if off >= 0 else -off
    h = int(a)
    m = int((a - h) * 60.0 + 0.5)
    s = "UTC" + sign + str(h)
    if m:
        s = s + ":" + pad2(m)
    return s

def zone_str(tj, off):
    # One generic label for every location: the live DST abbreviation while it is
    # actually in force, otherwise the raw offset. Never a per-city special case.
    if tj.get("isDayLightSavingActive", False):
        dst = tj.get("dstInterval", None)
        if dst:
            n = str(dst.get("dstName", "")).upper()
            if n:
                return n
    return utc_str(off)

# ---------- the lookups ----------
# Returns {"ok": True, ...} or {"ok": False, "title":..., "sub":...}

def place(ctx):
    zip = _s(ctx, "zip", "")
    if not zip:
        return {"ok": False, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}

    # Zip codes rarely move, so cache for a day.
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
    lat = float(p["latitude"])
    lon = float(p["longitude"])

    # The true offset for this spot right now, DST already applied.
    t = http.get(
        "https://timeapi.io/api/TimeZone/coordinate",
        params = {"latitude": str(lat), "longitude": str(lon)},
        # The offset only changes twice a year, so an hour of cache is plenty.
        ttl_seconds = 3600,
    )

    # ALWAYS check status_code before touching the json
    if t["status_code"] != 200:
        return {"ok": False, "title": "TZ ERROR", "sub": "CODE " + str(t["status_code"])}

    tj = t["json"]
    if not tj:
        return {"ok": False, "title": "NO DATA", "sub": "EMPTY RESPONSE"}

    cur = tj.get("currentUtcOffset", {})
    off_secs = cur.get("seconds", None)
    if off_secs == None:
        return {"ok": False, "title": "NO OFFSET", "sub": "UNEXPECTED REPLY"}

    off = float(off_secs) / 3600.0
    return {
        "ok": True,
        "city": city,
        "lat": lat,
        "lon": lon,
        "off": off,
        "zone": zone_str(tj, off),
    }

def local_parts(ctx, off_hours):
    # Everything -- clock, date, day-of-year -- comes off this one shifted
    # timestamp, so they can never disagree near midnight.
    local = ctx.now.unix + int(off_hours * 3600.0)
    sod = local % 86400
    days = (local - sod) // 86400
    y, mo, d = _civil_from_days(days)
    yday = days - _days_from_civil(y, 1, 1) + 1
    return {
        "h": sod // 3600,
        "mi": (sod % 3600) // 60,
        "y": y,
        "mo": mo,
        "d": d,
        "yday": yday,
        "wd": (days + 3) % 7,        # 0 = Monday, to match WEEKDAYS
    }

def sun_times(lat, lon, yday, off):
    # Sunrise/sunset as (hour, minute) local, via the sunrise equation.
    decl = 23.45 * math.sin(math.radians(360.0 / 365.0 * (yday - 81)))
    cosw = -math.tan(math.radians(lat)) * math.tan(math.radians(decl))
    w = math.degrees(math.acos(clamp(cosw, -1.0, 1.0))) / 15.0
    noon = 12.0 - lon / 15.0 + off
    return to_hm(noon - w), to_hm(noon + w)

def _err(c, d, bar):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = bar)
    c.text("WORLD CLOCK", c.width // 2, 1, font = "5x7", color = "white", align = "center")
    c.text(d["title"], 4, 12, font = "6x8", color = "orange")
    c.text(d["sub"], 4, 23, font = "4x5", color = "gray")

# ---------- pages ----------

def clock(c, ctx):
    info = place(ctx)
    if not info["ok"]:
        _err(c, info, "blue")
        return

    t = local_parts(ctx, info["off"])
    tstr, ap = fmt12(t["h"], t["mi"])

    # Day or night? Compare "now" to today's sunrise/sunset, then draw the icon.
    sunrise, sunset = sun_times(info["lat"], info["lon"], t["yday"], info["off"])
    now_min = t["h"] * 60 + t["mi"]
    is_day = now_min >= sunrise[0] * 60 + sunrise[1] and now_min < sunset[0] * 60 + sunset[1]

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text(fit(c, info["city"], "5x7", c.width - 4), c.width // 2, 1,
           font = "5x7", color = "white", align = "center")

    # Two containers -- [time + AM/PM] and [sun icon over date] -- with a 10px
    # buffer, the pair centred on the panel in the band under the banner.
    w_time = c.text_width(tstr, "16x20") + 3 + c.text_width(ap, "6x8")

    # Worst case (12:59 PM + a long date) still leaves a 10px margin each side.
    cap = c.width - 20 - w_time - 10
    if cap < 11:
        cap = 11
    date = fit(c, WEEKDAYS[t["wd"]] + " " + MONTHS[t["mo"] - 1] + " " + str(t["d"]),
               "4x5", cap)
    w_sd = c.text_width(date, "4x5")
    if w_sd < 11:
        w_sd = 11

    x = (c.width - (w_time + 10 + w_sd)) // 2
    if x < 5:
        x = 5

    # Band under the banner is y 9..31; the taller container (20px) sets the group.
    top = 9 + ((c.height - 9) - 20) // 2
    sd_x = x + w_time + 10
    sd_top = top + 1

    c.text(tstr, x, top, font = "16x20", color = "white")
    c.text(ap, x + c.text_width(tstr, "16x20") + 3, top + 2, font = "6x8", color = "yellow")

    # A custom PNG icon you dropped in this folder, listed under `assets:`.
    c.image("sun.png" if is_day else "moon.png", sd_x + (w_sd - 11) // 2, sd_top, w = 11, h = 11)
    c.text(date, sd_x + w_sd // 2, sd_top + 13, font = "4x5", color = "gray", align = "center")

def sun(c, ctx):
    info = place(ctx)
    if not info["ok"]:
        _err(c, info, "orange")
        return

    t = local_parts(ctx, info["off"])
    sunrise, sunset = sun_times(info["lat"], info["lon"], t["yday"], info["off"])
    sr, srap = fmt12(sunrise[0], sunrise[1])
    ss, ssap = fmt12(sunset[0], sunset[1])

    # Daylight length, straight off the same two times so they can't disagree.
    span = (sunset[0] * 60 + sunset[1]) - (sunrise[0] * 60 + sunrise[1])
    if span < 0:
        span = span + 1440
    daylen = str(span // 60) + "H " + pad2(span % 60) + "M"

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "orange")
    c.text(fit(c, info["city"], "5x7", c.width - 4), c.width // 2, 1,
           font = "5x7", color = "black", align = "center")

    # Left column keeps the wide 5x7 labels; the right column spells its labels
    # out in full in the narrow 3x7 face so DAYLIGHT / TIMEZONE say what they are
    # without pushing the values past the safe zone at x=182.
    _cell(c, 10, 11, UP, "yellow", "RISE", "5x7", 35, sr + " " + srap, 50)
    _cell(c, 10, 23, DOWN, "orange", "SET", "5x7", 35, ss + " " + ssap, 50)
    _cell(c, 98, 11, GLASS, "cyan", "DAYLIGHT", "3x7", 43, daylen, 41)
    _cell(c, 98, 23, GLOBE, "green", "TIMEZONE", "3x7", 43, info["zone"], 41)

def _cell(c, x, y, mark, color, label, lfont, vdx, value, maxw):
    # One data point: 5x5 mark, coloured label, white value. Values are fitted to
    # the column so a long zone name truncates rather than crossing the gutter.
    c.bitmap(mark, x, y + 1, color)
    c.text(fit(c, label, lfont, vdx - 10), x + 8, y, font = lfont, color = color)
    c.text(fit(c, value, "5x7", maxw), x + vdx, y, font = "5x7", color = "white")