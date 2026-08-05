# Date & Time — local date, time, and current weather for a US zip code. (384x32, 1 page)
#
# One line, left to right: DATE | TIME | weather ICON + TEMP + CONDITION.
# Each section has its own configurable color. The whole line shares one font
# size/weight (user-selectable small/medium/large, normal/bold) and only
# drops a size if the full line — with real content — would overflow, so
# sizing stays consistent instead of each section picking its own.
#
# Four keyless lookups:
#   1. zippopotam.us  - zip -> latitude, longitude
#   2. timeapi.io     - lat/lon -> the true UTC offset right now (DST-aware)
#   3. open-meteo.com - lat/lon -> current temp, WMO weather code, day/night
#   4. moon phase (for the clear-night icon) computed locally, same synodic-
#      month math as the moon-phase app
# The clock itself is computed locally from ctx.now + the offset, so it stays
# minute-accurate between refreshes without hammering any API.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
MONTHS_FULL = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY",
               "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
WEEKDAYS_FULL = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY",
                  "SATURDAY", "SUNDAY"]

DIVIDER = "#444444"

# Compact weather glyphs, each <=9px tall so they sit on the one text line.
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

# ---------- input ----------

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

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

def local_parts(ctx, off_hours):
    # Date and clock both come off this one shifted timestamp, so they can
    # never disagree near midnight.
    local = ctx.now.unix + int(off_hours * 3600.0)
    sod = local % 86400
    days = (local - sod) // 86400
    y, mo, d = _civil_from_days(days)
    return {
        "h": sod // 3600,
        "mi": (sod % 3600) // 60,
        "y": y,
        "mo": mo,
        "d": d,
        "wd": (days + 3) % 7,  # 0 = Monday, matches WEEKDAYS_FULL
    }

# ---------- moon phase (same synodic-month math as the moon-phase app) ----------

SYNODIC = 29.530588853          # days, new moon to new moon
NEW_EPOCH = 947182440           # unix time of a known new moon: 2000-01-06 18:14 UTC

def _moon_phase(ctx):
    cycles = (float(ctx.now.unix) - float(NEW_EPOCH)) / 86400.0 / SYNODIC
    p = cycles - float(int(cycles))
    if p < 0.0:
        p = p + 1.0
    return p

def _moon_bitmap(p):
    # A 9x9 disc split by the real terminator ellipse, so the icon shows the
    # actual current phase (crescent/quarter/gibbous/full) rather than a
    # fixed crescent glyph.
    r = 4
    t = math.cos(2.0 * math.pi * p)
    waxing = p < 0.5
    grid = []
    for dy in range(-r, r + 1):
        row = []
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > r * r:
                row.append(0)
            else:
                w = math.sqrt(float(r * r - dy * dy))
                xf = float(dx)
                lit = (xf >= t * w) if waxing else (xf <= -t * w)
                row.append(1 if lit else 0)
        grid.append(row)
    return grid

# ---------- formatting ----------

def ordinal_suffix(d):
    if d >= 11 and d <= 13:
        return "TH"
    r = d % 10
    if r == 1:
        return "ST"
    if r == 2:
        return "ND"
    if r == 3:
        return "RD"
    return "TH"

def format_date(ctx, t):
    fmt = _s(ctx, "dateformat", "MM/DD/YYYY")
    mo2 = pad2(t["mo"])
    d2 = pad2(t["d"])
    y4 = str(t["y"])
    mon = MONTHS[t["mo"] - 1]
    if fmt == "DD/MM/YYYY":
        return d2 + "/" + mo2 + "/" + y4
    if fmt == "YYYY-MM-DD":
        return y4 + "-" + mo2 + "-" + d2
    if fmt == "MON DD, YYYY":
        return mon + " " + d2 + ", " + y4
    if fmt == "DD MON YYYY":
        return d2 + " " + mon + " " + y4
    if fmt == "WEDNESDAY, AUGUST 5TH":
        weekday = WEEKDAYS_FULL[t["wd"]]
        month = MONTHS_FULL[t["mo"] - 1]
        return weekday + ", " + month + " " + str(t["d"]) + ordinal_suffix(t["d"])
    return mo2 + "/" + d2 + "/" + y4

def format_time(ctx, t):
    if _s(ctx, "timeformat", "12") == "24":
        return pad2(t["h"]) + ":" + pad2(t["mi"]), ""
    hh = t["h"] % 12
    if hh == 0:
        hh = 12
    ap = "AM" if t["h"] < 12 else "PM"
    return str(hh) + ":" + pad2(t["mi"]), ap

# ---------- lookups ----------
# Each returns {"ok": True, ...} or {"ok": False, "title":..., "sub":...}

def geocode(ctx):
    zip = _s(ctx, "zip", "")
    if not zip:
        return {"ok": False, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}

    # Zip codes rarely move, so cache for a day.
    r = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if r["status_code"] == 404:
        return {"ok": False, "title": "BAD ZIP CODE", "sub": zip + " NOT FOUND"}
    if r["status_code"] != 200:
        return {"ok": False, "title": "LOOKUP ERROR", "sub": "CODE " + str(r["status_code"])}

    places = r["json"].get("places", [])
    if not places:
        return {"ok": False, "title": "BAD ZIP CODE", "sub": zip + " NOT FOUND"}

    p = places[0]
    return {"ok": True, "lat": float(p["latitude"]), "lon": float(p["longitude"])}

def tz_offset_hours(lat, lon):
    # The true offset for this spot right now, DST already applied. It only
    # changes twice a year, so an hour of cache is plenty.
    t = http.get(
        "https://timeapi.io/api/TimeZone/coordinate",
        params = {"latitude": str(lat), "longitude": str(lon)},
        ttl_seconds = 3600,
    )
    if t["status_code"] != 200:
        return None
    tj = t["json"]
    if not tj:
        return None
    off_secs = tj.get("currentUtcOffset", {}).get("seconds", None)
    if off_secs == None:
        return None
    return float(off_secs) / 3600.0

def fetch_weather(lat, lon):
    r = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": str(lat),
            "longitude": str(lon),
            "current": "temperature_2m,weather_code,is_day",
            "temperature_unit": "fahrenheit",
            "timezone": "auto",
        },
        ttl_seconds = 300,
    )
    if r["status_code"] != 200:
        return None
    j = r["json"]
    if not j:
        return None
    return j.get("current", None)

# ---------- weather icon + condition text ----------

RAIN_CODES = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
SNOW_CODES = [71, 73, 75, 77, 85, 86]

def _bmp(c, bitmap, x, y, color, scale):
    # Nearest-neighbor scale-up so the icon grows/shrinks with the chosen
    # text size instead of staying pinned at its native 9x9.
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

def draw_condition(c, code, is_day, phase, x, y, scale):
    if code == 0 or code == 1:
        if is_day:
            _bmp(c, SUN, x, y, "yellow", scale)
        else:
            _bmp(c, _moon_bitmap(phase), x, y, "skyblue", scale)
    elif code == 2:
        # Partly cloudy: sun or moon peeking out from behind the cloud.
        if is_day:
            _bmp(c, SUN, x, y, "yellow", scale)
        else:
            _bmp(c, _moon_bitmap(phase), x, y, "skyblue", scale)
        _bmp(c, CLOUD, x, y + 3 * scale, "gray", scale)
    elif code == 45 or code == 48:
        _bmp(c, FOG, x, y + scale, "gray", scale)
    elif code in RAIN_CODES:
        _bmp(c, CLOUD, x, y, "gray", scale)
        _bmp(c, RAINDROPS, x, y + 6 * scale, "cyan", scale)
    elif code in SNOW_CODES:
        _bmp(c, CLOUD, x, y, "gray", scale)
        _bmp(c, SNOWFLAKES, x, y + 6 * scale, "white", scale)
    elif code >= 95:
        _bmp(c, CLOUD, x, y, "gray", scale)
        _bmp(c, LIGHTNING, x + 2 * scale, y + 5 * scale, "amber", scale)
    else:
        # 3 = overcast, and any unmapped code.
        _bmp(c, CLOUD, x, y + 2 * scale, "gray", scale)

def condition_label(code, is_day):
    # Clear sky at night: moon icon, "CLEAR" text (same slot FOG etc. use).
    if code == 0:
        return "SUNNY" if is_day else "CLEAR"
    if code == 1:
        return "MOSTLY SUNNY" if is_day else "MOSTLY CLEAR"
    if code == 2:
        return "PARTLY CLOUDY"
    if code == 3:
        return "CLOUDY"
    if code == 45:
        return "FOG"
    if code == 48:
        return "ICY FOG"
    if code == 51:
        return "LIGHT DRIZZLE"
    if code == 53:
        return "DRIZZLE"
    if code == 55:
        return "HEAVY DRIZZLE"
    if code == 56:
        return "LIGHT FZ DRIZZLE"
    if code == 57:
        return "FZ DRIZZLE"
    if code == 61:
        return "LIGHT RAIN"
    if code == 63:
        return "RAIN"
    if code == 65:
        return "HEAVY RAIN"
    if code == 66:
        return "LIGHT FZ RAIN"
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
        return "LIGHT SHOWERS"
    if code == 81:
        return "SHOWERS"
    if code == 82:
        return "HEAVY SHOWERS"
    if code == 85:
        return "LIGHT SNOW SHW"
    if code == 86:
        return "SNOW SHOWERS"
    if code == 95:
        return "THUNDERSTORMS"
    if code == 96:
        return "STORM + HAIL"
    if code == 99:
        return "SEVERE STORMS"
    return "CLOUDY"

# ---------- page ----------
# One font for the whole line — date, time, and weather all match, per the
# user's small/medium/large + normal/bold choice. That choice is a ceiling:
# we only drop to the next size down if the *entire* line, with its real
# content, would overflow, so sizing stays internally consistent instead of
# each section picking its own font. The weather icon scales up in step.
# Bold is "faux bold" (redraw offset 1px right) so it works on every size,
# since only the larger bundled fonts ship a true _bold variant.

FONT_H = {"10x16": 16, "6x8": 8, "4x5": 6}
ICON_SCALE = {"10x16": 3, "6x8": 2, "4x5": 1}
SIZE_FONT = {"large": "10x16", "medium": "6x8", "small": "4x5"}

GAP = 10        # empty space on each side of a divider
MARGIN = 8      # minimum breathing room left over on the panel

def size_fallback_chain(pref):
    # Medium/small still auto-shrink to stay on-panel. Large is a hard
    # choice, not a ceiling: it always renders at full size, even if that
    # means the line runs past the panel edge and gets clipped.
    if pref == "large":
        return ["large"]
    if pref == "small":
        return ["small"]
    return ["medium", "small"]

def vcenter(h):
    return (32 - h) // 2

def tw(c, text, font, bold):
    w = c.text_width(text, font)
    return w + 1 if bold else w

def draw_text(c, text, x, y, font, color, bold):
    c.text(text, x, y, font = font, color = color)
    if bold:
        c.text(text, x + 1, y, font = font, color = color)

def line_width(c, font, bold, date_text, time_text, have_weather, temp_str, cond_text):
    icon_w = 9 * ICON_SCALE[font]
    if have_weather:
        temp_w = tw(c, temp_str, font, bold) + 3 + 4 + tw(c, "F", font, bold)
        weather_w = icon_w + 6 + temp_w + 10 + tw(c, cond_text, font, bold)
    else:
        weather_w = tw(c, "WEATHER N/A", font, bold)
    return (tw(c, date_text, font, bold) + GAP + 1 + GAP +
            tw(c, time_text, font, bold) + GAP + 1 + GAP + weather_w)

def main(c, ctx):
    c.fill("black")

    date_color = _s(ctx, "datecolor", "#FFFFFF")
    time_color = _s(ctx, "timecolor", "#FFFFFF")
    weather_color = _s(ctx, "weathercolor", "#FFFFFF")

    geo = geocode(ctx)
    if not geo["ok"]:
        c.text(geo["title"], c.width // 2, 10, font = "6x8", color = "white", align = "center")
        c.text(geo["sub"], c.width // 2, 20, font = "4x5", color = "white", align = "center")
        return

    off = tz_offset_hours(geo["lat"], geo["lon"])
    if off == None:
        c.text("TIMEZONE ERROR", c.width // 2, 10, font = "6x8", color = "white", align = "center")
        c.text("TRY AGAIN LATER", c.width // 2, 20, font = "4x5", color = "white", align = "center")
        return

    t = local_parts(ctx, off)

    date_text = format_date(ctx, t)
    time_str, ap = format_time(ctx, t)
    time_text = time_str + (" " + ap if ap else "")

    wx = fetch_weather(geo["lat"], geo["lon"])
    temp = wx.get("temperature_2m", None) if wx != None else None
    have_weather = temp != None

    phase = _moon_phase(ctx)

    if have_weather:
        code = int(wx.get("weather_code", 3))
        is_day = int(wx.get("is_day", 1)) == 1
        temp_i = int(temp + 0.5) if temp >= 0 else int(temp - 0.5)
        temp_str = str(temp_i)
        cond_text = condition_label(code, is_day)
    else:
        temp_str = ""
        cond_text = ""

    bold = _s(ctx, "fontweight", "normal") == "bold"
    chain = size_fallback_chain(_s(ctx, "fontsize", "medium"))

    # Pick the biggest size (within the user's chosen ceiling) that still
    # lets the whole line fit, so it only ever shrinks as one consistent unit.
    size = chain[len(chain) - 1]
    for s in chain:
        if line_width(c, SIZE_FONT[s], bold, date_text, time_text, have_weather, temp_str, cond_text) <= c.width - MARGIN:
            size = s
            break

    font = SIZE_FONT[size]
    font_h = FONT_H[font]
    icon_scale = ICON_SCALE[font]
    icon_w = 9 * icon_scale

    date_w = tw(c, date_text, font, bold)
    time_w = tw(c, time_text, font, bold)
    if have_weather:
        temp_w = tw(c, temp_str, font, bold) + 3 + 4 + tw(c, "F", font, bold)
        cond_w = tw(c, cond_text, font, bold)
        weather_w = icon_w + 6 + temp_w + 10 + cond_w
    else:
        weather_w = tw(c, "WEATHER N/A", font, bold)

    total = date_w + GAP + 1 + GAP + time_w + GAP + 1 + GAP + weather_w
    x = (c.width - total) // 2
    if x < 2:
        x = 2

    # ---- draw, left to right ----

    draw_text(c, date_text, x, vcenter(font_h), font, date_color, bold)
    x += date_w + GAP
    c.line(x, 5, x, 27, DIVIDER)
    x += 1 + GAP

    draw_text(c, time_text, x, vcenter(font_h), font, time_color, bold)
    x += time_w + GAP
    c.line(x, 5, x, 27, DIVIDER)
    x += 1 + GAP

    if not have_weather:
        draw_text(c, "WEATHER N/A", x, vcenter(font_h), font, weather_color, bold)
        return

    draw_condition(c, code, is_day, phase, x, vcenter(icon_w), icon_scale)
    x += icon_w + 6

    ty = vcenter(font_h)
    draw_text(c, temp_str, x, ty, font, weather_color, bold)
    deg_x = x + tw(c, temp_str, font, bold) + 3
    c.fill_circle(deg_x, ty + 1, 1, weather_color)
    draw_text(c, "F", deg_x + 4, ty, font, weather_color, bold)
    x += temp_w + 10

    draw_text(c, cond_text, x, vcenter(font_h), font, weather_color, bold)
