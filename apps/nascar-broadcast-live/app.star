# NASCAR - Broadcast Live (384x32).
#
# A real page rotation (not one page faking frames off the wall clock -- the
# panel requests one render per page in manifest order):
#
#   logo    - series wordmark
#   event   - race name / track / session, and flag / lap / stage while racing;
#             the next-race card between sessions
#   track   - the track shape, big
#   board1..board5 + feed1..feed2 - seven "flex" slots. While a race is live
#             they carry the full running order a screen at a time, then a
#             laps-led board and a pit-stop board. In practice/qualifying they
#             carry the timing order, then fastest-lap and biggest-movers
#             boards. Between sessions they carry the next-race card, the rest
#             of the schedule, and the last race's result.
#
# Data: NASCAR's public Content Feed CDN (cf.nascar.com) -- race_list_basic for
# the schedule, the live-feed for everything in-session (running order, laps
# led, pit stops, starting positions, best-lap speeds all come off the same
# feed, no extra endpoints).
#
# NOTE ON STATUS CODES: NASCAR's live feed exposes `status` (1 = running,
# 3 = retired/garage) and `is_on_track`. There is no confirmed distinct code
# for "spun but still running" or "pitting" -- those are inferred (status 1 +
# not on_track -> OFF; status 2 -> PIT) from the shape of the schema.

SERIES_IDS = {
    "NASCAR": 1,
    "NASCAR - O'Reilly": 2,
    "NASCAR - Trucks": 3,
}

SERIES_SHORT = {
    "NASCAR": "CUP",
    "NASCAR - O'Reilly": "ORS",
    "NASCAR - Trucks": "TRK",
}

FLAG_LABEL = {
    1: "GREEN",
    2: "YELLOW",
    3: "RED",
    4: "WHITE",
    5: "CHECKER",
    8: "WARMUP",
    9: "FINISH",
}

FLAG_COLOR = {
    1: "#22C55E",
    2: "#FACC15",
    3: "#EF4444",
    4: "#F8FAFC",
    5: "#E2E8F0",
    8: "#38BDF8",
    9: "#E2E8F0",
}

# Livery bg/text hex per car NUMBER (not driver) -- the same number gets
# reassigned to a different driver between seasons far more often than a team
# changes livery. Each series keeps its own table; never share one across
# series or a same-numbered car picks up the wrong colors.
NASCAR_DRIVER_COLOR = {
    "1": ("#00A4DA", "#204C85"),
    "2": ("#FFF200", "#006400"),
    "3": ("#C0C0C0", "#000000"),
    "4": ("#ECB11F", "#000000"),
    "5": ("#015998", "#FFFFFF"),
    "6": ("#009343", "#FFFFFF"),
    "7": ("#2475D1", "#72D669"),
    "9": ("#0A0094", "#FFC836"),
    "10": ("#FF4500", "#000000"),
    "11": ("#2D95E5", "#FFFFFF"),
    "12": ("#FFF200", "#000000"),
    "16": ("#000000", "#FDFF45"),
    "17": ("#FF6700", "#000000"),
    "19": ("#000000", "#FF5F1F"),
    "20": ("#EA0021", "#FFFFFF"),
    "21": ("#FFFFFF", "#D40000"),
    "22": ("#FFCF1D", "#ED1C24"),
    "23": ("#6138F5", "#04C785"),
    "24": ("#D91C2B", "#005596"),
    "33": ("#0A192F", "#CE714C"),
    "34": ("#FFE100", "#000000"),
    "35": ("#95D600", "#000000"),
    "38": ("#3472BD", "#32CD32"),
    "41": ("#505359", "#000000"),
    "42": ("#FFFFFF", "#235DAB"),
    "43": ("#D3AF37", "#6FBE4A"),
    "45": ("#D3D3D3", "#CF1A2B"),
    "47": ("#005A9C", "#FF5F1F"),
    "48": ("#650360", "#FFFFFF"),
    "51": ("#D3AF37", "#000000"),
    "54": ("#000000", "#95D600"),
    "60": ("#000000", "#50AD9A"),
    "71": ("#0058AA", "#81D9AC"),
    "77": ("#000080", "#E32227"),
    "88": ("#1E5BC6", "#F7C300"),
    "97": ("#1E5BC6", "#DC052D"),
}

ORS_DRIVER_COLOR = {
    "00": ("#FFCF1D", "#ED1C24"),
    "0": ("#0088D8", "#4BB92C"),
    "1": ("#FF5F1F", "#000000"),
    "02": ("#000096", "#4D9DFF"),
    "2": ("#FFFFFF", "#FF0000"),
    "07": ("#FE5000", "#000080"),
    "7": ("#ED1B24", "#FFFFFF"),
    "8": ("#EF4138", "#000000"),
    "17": ("#015998", "#FFFFFF"),
    "18": ("#666666", "#003E6F"),
    "19": ("#0047BA", "#D42E12"),
    "20": ("#FFF200", "#006400"),
    "21": ("#FFFFFF", "#015998"),
    "24": ("#FFFFFF", "#ED1B2E"),
    "26": ("#000000", "#52D1FF"),
    "27": ("#FEC85A", "#B82C0F"),
    "28": ("#4169E1", "#000000"),
    "31": ("#174A7C", "#FDB913"),
    "39": ("#FFFFFF", "#FF3131"),
    "41": ("#44C744", "#000000"),
    "44": ("#0205C7", "#CCFF00"),
    "45": ("#155289", "#FFE600"),
    "48": ("#006499", "#D62D2D"),
    "51": ("#D3AF37", "#000000"),
    "54": ("#FFDD42", "#FFFFFF"),
    "87": ("#FFFF73", "#FF0000"),
    "88": ("#FFFFFF", "#015998"),
    "92": ("#C9AC34", "#000000"),
    "96": ("#0055FF", "#000000"),
    "99": ("#00DE78", "#0004C7"),
}

TRUCK_DRIVER_COLOR = {
    "1": ("#0047BA", "#FFFFFF"),
    "2": ("#E41D38", "#160BE6"),
    "5": ("#FFFFFF", "#0047BA"),
    "7": ("#808080", "#FF5B00"),
    "9": ("#8B3A3A", "#000000"),
    "10": ("#0066CC", "#FFFFFF"),
    "11": ("#DB0020", "#FFFFFF"),
    "12": ("#EE2E24", "#000000"),
    "13": ("#000000", "#FF0000"),
    "14": ("#F6DE0F", "#000000"),
    "15": ("#89CFF0", "#FFFFFF"),
    "16": ("#FFFFFF", "#FF8D2E"),
    "17": ("#FF6600", "#000000"),
    "18": ("#003F72", "#F8981C"),
    "19": ("#0A0094", "#FFC836"),
    "22": ("#FFFFFF", "#000000"),
    "25": ("#000000", "#F6DE0F"),
    "26": ("#5D8AAA", "#A9A9A9"),
    "33": ("#FFF836", "#000000"),
    "34": ("#FFE100", "#000000"),
    "38": ("#8ACF00", "#000000"),
    "42": ("#FFFFFF", "#0000B8"),
    "44": ("#0000B8", "#32CD32"),
    "45": ("#C70000", "#0000B8"),
    "52": ("#006499", "#D62D2D"),
    "62": ("#FFFFFF", "#E30614"),
    "76": ("#8C8B88", "#FFBF00"),
    "77": ("#0058AA", "#81D9AC"),
    "81": ("#00396F", "#B5160B"),
    "88": ("#FFF200", "#000000"),
    "91": ("#FFC836", "#0A0094"),
    "98": ("#8C8B88", "#F0941C"),
    "99": ("#C71121", "#FFFFFF"),
}

# Playoff (chase) drivers get their position badge recolored per series
# instead of a " C" suffix crammed onto an already-tight name column.
CHASE_BADGE = {
    "NASCAR": ("#FACC15", "#000000"),
    "NASCAR - O'Reilly": ("#EF4444", "#FFFFFF"),
    "NASCAR - Trucks": ("#7DF9FF", "#FFFFFF"),
}

def pos_badge_colors(series, chase):
    if not chase:
        return "#000000", "#FFFFFF"
    return CHASE_BADGE.get(series, ("#000000", "#FFFFFF"))

MONTHS_FULL = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY",
               "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]

COLORS = {
    "bg": "#07090D",
    "panel": "#141A22",
    "line": "#2A3544",
    "text": "#F4F7FB",
    "muted": "#8B9BB0",
    "accent": "#FF6A00",
    "accent2": "#FFD166",
    "error": "#FF5D73",
}

GOLD = "#FFD700"

# Track-shape category per venue, keyed by CF's track_name text. Hand-built
# vector shapes by track TYPE (no licensed per-track NASCAR outline art
# exists), used only where there is no traced asset below.
TRACK_SHAPE = {
    "DAYTONA INTERNATIONAL SPEEDWAY": "trioval",
    "TALLADEGA SUPERSPEEDWAY": "trioval",
    "CHARLOTTE MOTOR SPEEDWAY": "quad",
    "ATLANTA MOTOR SPEEDWAY": "quad",
    "HOMESTEAD-MIAMI SPEEDWAY": "quad",
    "POCONO RACEWAY": "triangle",
    "INDIANAPOLIS MOTOR SPEEDWAY": "rect",
    "MARTINSVILLE SPEEDWAY": "paperclip",
    "BRISTOL MOTOR SPEEDWAY": "bullring",
    "RICHMOND RACEWAY": "bullring",
    "NORTH WILKESBORO SPEEDWAY": "bullring",
    "BOWMAN GRAY STADIUM": "quarter",
    "CIRCUIT OF THE AMERICAS": "roadcourse",
    "SONOMA RACEWAY": "roadcourse",
    "WATKINS GLEN INTERNATIONAL": "roadcourse",
    "LIME ROCK PARK": "roadcourse",
    "LUCAS OIL INDIANAPOLIS RACEWAY PARK": "roadcourse",
    "SAN DIEGO STREET COURSE": "street",
    "GRAND PRIX OF ST. PETERSBURG": "street",
}

# Real traced outlines -- (asset, native width, native height), pre-sized in
# Python so no runtime distortion. Only used on the big `track` page and the
# off-season cards; the live boards have no room for a raster outline.
NASCAR_TRACK_ASSET = {
    "CHARLOTTE MOTOR SPEEDWAY": ("track-charlotte.png", 51, 26),
    "CHICAGOLAND SPEEDWAY": ("track-chicagoland.png", 41, 26),
    "DAYTONA INTERNATIONAL SPEEDWAY": ("track-daytona.png", 52, 26),
    "TALLADEGA SUPERSPEEDWAY": ("track-talladega.png", 51, 26),
    "ATLANTA MOTOR SPEEDWAY": ("track-atlanta.png", 46, 26),
    "HOMESTEAD-MIAMI SPEEDWAY": ("track-homestead-miami.png", 54, 26),
    "POCONO RACEWAY": ("track-pocono.png", 43, 26),
    "INDIANAPOLIS MOTOR SPEEDWAY": ("track-indianapolis-oval.png", 53, 26),
    "MARTINSVILLE SPEEDWAY": ("track-martinsville.png", 60, 22),
    "BRISTOL MOTOR SPEEDWAY": ("track-bristol.png", 33, 26),
    "RICHMOND RACEWAY": ("track-richmond.png", 48, 26),
    "NORTH WILKESBORO SPEEDWAY": ("track-north-wilkesboro.png", 49, 26),
    "SONOMA RACEWAY": ("track-sonoma.png", 60, 22),
    "WATKINS GLEN INTERNATIONAL": ("track-watkins-glen.png", 56, 26),
    "LIME ROCK PARK": ("track-lime-rock.png", 41, 26),
    "LUCAS OIL INDIANAPOLIS RACEWAY PARK": ("track-lucas-oil-irp.png", 39, 26),
    "SAN DIEGO STREET COURSE": ("track-coronado.png", 36, 26),
    "DOVER MOTOR SPEEDWAY": ("track-dover.png", 49, 26),
    "ROCKINGHAM SPEEDWAY": ("track-rockingham.png", 50, 26),
    "IOWA SPEEDWAY": ("track-iowa-oval.png", 46, 26),
    "TEXAS MOTOR SPEEDWAY": ("track-texas.png", 44, 26),
    "KANSAS SPEEDWAY": ("track-kansas.png", 45, 26),
    "MICHIGAN INTERNATIONAL SPEEDWAY": ("track-michigan.png", 51, 26),
    "NASHVILLE SUPERSPEEDWAY": ("track-nashville.png", 47, 26),
    "LAS VEGAS MOTOR SPEEDWAY": ("track-las-vegas.png", 41, 26),
    "DARLINGTON RACEWAY": ("track-darlington.png", 51, 26),
    "WORLD WIDE TECHNOLOGY RACEWAY": ("track-wwt-raceway.png", 60, 24),
    "NEW HAMPSHIRE MOTOR SPEEDWAY": ("track-new-hampshire.png", 60, 24),
}

SHAPE_POINTS = {
    "oval": [(0.5, 0.0), (0.85, 0.15), (1.0, 0.5), (0.85, 0.85), (0.5, 1.0), (0.15, 0.85), (0.0, 0.5), (0.15, 0.15)],
    "trioval": [(0.5, 0.0), (0.9, 0.2), (1.0, 0.55), (0.75, 0.85), (0.35, 1.0), (0.05, 0.7), (0.05, 0.35), (0.25, 0.1)],
    "quad": [(0.35, 0.0), (0.7, 0.05), (1.0, 0.35), (0.95, 0.7), (0.65, 1.0), (0.3, 0.95), (0.0, 0.65), (0.05, 0.3)],
    "triangle": [(0.5, 0.0), (1.0, 0.75), (0.5, 1.0), (0.0, 0.75)],
    "rect": [(0.1, 0.05), (0.9, 0.05), (0.95, 0.5), (0.9, 0.95), (0.1, 0.95), (0.05, 0.5)],
    "paperclip": [(0.3, 0.0), (0.7, 0.0), (1.0, 0.2), (1.0, 0.35), (0.75, 0.5), (1.0, 0.65), (1.0, 0.8), (0.7, 1.0), (0.3, 1.0), (0.0, 0.8), (0.0, 0.65), (0.25, 0.5), (0.0, 0.35), (0.0, 0.2)],
    "bullring": [(0.5, 0.0), (0.95, 0.3), (0.95, 0.7), (0.5, 1.0), (0.05, 0.7), (0.05, 0.3)],
    "quarter": [(0.15, 0.1), (0.85, 0.1), (0.85, 0.9), (0.15, 0.9)],
    "roadcourse": [(0.1, 0.1), (0.4, 0.0), (0.6, 0.2), (0.5, 0.4), (0.9, 0.3), (1.0, 0.6), (0.7, 0.9), (0.4, 0.7), (0.2, 1.0), (0.0, 0.6)],
    "street": [(0.0, 0.2), (0.4, 0.0), (0.4, 0.3), (0.8, 0.3), (0.8, 0.0), (1.0, 0.2), (1.0, 0.8), (0.8, 1.0), (0.8, 0.5), (0.4, 0.5), (0.4, 1.0), (0.0, 0.8)],
}

SERIES_LOGO = {
    "NASCAR": ("nascar-logo.png", 128.0 / 22.0),
    "NASCAR - O'Reilly": ("oreilly-logo.png", 57.0 / 24.0),
    "NASCAR - Trucks": ("trucks-logo.png", 99.0 / 22.0),
}

# ---------- small helpers ----------

def safe_input(ctx, key, fallback):
    value = ctx.inputs.get(key, fallback)
    if value == None or value == "":
        return fallback
    return value

def clean_last(raw):
    name = str(raw).strip()
    if len(name) > 0 and name[0] == "*":
        name = name[1:].strip()
    cleaned = ""
    for i in range(len(name)):
        if name[i] == "(":
            break
        cleaned += name[i]
    name = cleaned.strip()
    if len(name) > 0 and name[len(name) - 1] == "#":
        name = name[:len(name) - 1].strip()
    return name.upper()

def mark_duplicate_names(rows):
    counts = {}
    for row in rows:
        n = row["name"]
        counts[n] = counts.get(n, 0) + 1
    for row in rows:
        if counts.get(row["name"], 0) <= 1:
            row["initial"] = ""
    return rows

def short_track(name):
    text = str(name).upper()
    text = text.replace(" INTERNATIONAL SPEEDWAY", "")
    text = text.replace(" MOTOR SPEEDWAY", "")
    text = text.replace(" SUPER SPEEDWAY", "")
    text = text.replace(" SUPERSPEEDWAY", "")
    text = text.replace(" RACEWAY", "")
    text = text.replace(" SPEEDWAY", "")
    if len(text) > 20:
        text = text[:20]
    return text

def short_race(name):
    text = str(name).upper()
    text = text.replace(" PRESENTED BY PPG", "")
    text = text.replace(" PRESENTED BY ", " ")
    text = text.replace(" POWERED BY ETHANOL", "")
    text = text.replace(" POWERED BY ", " ")
    text = text.replace(" AVAILABLE AT WALMART", "")
    text = text.replace(" AVAILABLE AT ", " ")
    at_idx = text.find(" AT ")
    if at_idx > 0:
        text = text[:at_idx]
    text = text.replace("  ", " ").strip()
    return text

def session_and_name(run_name):
    upper = str(run_name).upper()
    for kw in ("QUALIFYING", "PRACTICE"):
        idx = upper.find(kw)
        if idx > 0:
            return kw, upper[:idx].strip()
    return "RACE", upper

def fit_text(c, text, font, max_w):
    t = text
    for _ in range(60):
        if c.text_width(t, font) <= max_w or len(t) <= 3:
            return t
        cut = t.rfind(" ")
        t = t[:cut] if cut > 0 else t[:len(t) - 1]
    return t

def flag_color(state):
    return FLAG_COLOR.get(state, COLORS["muted"])

def draw_flag_bar(c, flag):
    is_checkered = flag == 5 or flag == 9
    if is_checkered:
        seg = 6
        num_segments = (c.width + seg - 1) // seg
        for i in range(num_segments):
            x = i * seg
            x2 = min(x + seg - 1, c.width - 1)
            c.rect(x, 0, x2, 1, fill = "#FFFFFF" if i % 2 == 0 else "#000000")
    else:
        c.rect(0, 0, c.width - 1, 1, fill = flag_color(flag))

def yiq_of(hex_color):
    h = hex_color.lstrip("#")
    r = int(h[0:2], 16)
    g = int(h[2:4], 16)
    b = int(h[4:6], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def best_text_color(hex_color):
    return "#111111" if yiq_of(hex_color) >= 150 else "#FFFFFF"

def driver_colors(num, series):
    table = NASCAR_DRIVER_COLOR
    if series == "NASCAR - O'Reilly":
        table = ORS_DRIVER_COLOR
    elif series == "NASCAR - Trucks":
        table = TRUCK_DRIVER_COLOR
    entry = table.get(str(num))
    if entry == None:
        return "#000000", "#FFFFFF"
    return entry

def http_json(url, ttl, params = None):
    if params:
        response = http.get(url, params = params, ttl_seconds = ttl)
    else:
        response = http.get(url, ttl_seconds = ttl)
    status = response["status_code"]
    if status != 200:
        return {"ok": False, "status": status}
    data = response["json"]
    if data == None:
        return {"ok": False, "status": status}
    return {"ok": True, "status": status, "data": data}

# ---------- local-time conversion (NASCAR's Eastern schedule -> panel local) ----------

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

def ordinal_suffix(day):
    if day == 11 or day == 12 or day == 13:
        return "TH"
    r = day % 10
    if r == 1:
        return "ST"
    if r == 2:
        return "ND"
    if r == 3:
        return "RD"
    return "TH"

def parse_iso(s):
    text = str(s)
    y = int(text[0:4])
    mo = int(text[5:7])
    d = int(text[8:10])
    h = int(text[11:13])
    mi = int(text[14:16])
    return y, mo, d, h, mi

def offset_seconds_for_zone(tz_name):
    r = http.get(
        "https://timeapi.io/api/TimeZone/zone",
        params = {"timeZone": tz_name},
        ttl_seconds = 3600,
    )
    if r["status_code"] != 200 or r["json"] == None:
        return None
    return r["json"].get("currentUtcOffset", {}).get("seconds", None)

def eastern_offset_seconds():
    off = offset_seconds_for_zone("America/New_York")
    return off if off != None else -18000

def panel_offset_seconds(ctx):
    tz_name = safe_input(ctx, "timezone", "America/New_York")
    return offset_seconds_for_zone(tz_name)

def _pad2(n):
    return ("0" + str(n)) if n < 10 else str(n)

def keep_until_end_of_day(ctx, end_unix):
    off = panel_offset_seconds(ctx)
    if off == None:
        off = 0
    local_end = end_unix + off
    local_day_start = (local_end // 86400) * 86400
    cutoff_local = local_day_start + 86399
    return cutoff_local - off

def format_ampm(lh, lm):
    ampm = "AM" if lh < 12 else "PM"
    h12 = lh % 12
    if h12 == 0:
        h12 = 12
    mm_txt = "0" + str(lm) if lm < 10 else str(lm)
    return str(h12) + ":" + mm_txt + ampm

def local_race_date(ctx, race_date_str):
    if race_date_str == "":
        return "TBD"
    y, mo, d, h, mi = parse_iso(race_date_str)
    naive_unix = _days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60
    et_off = eastern_offset_seconds()
    utc_unix = naive_unix - et_off
    panel_off = panel_offset_seconds(ctx)
    if panel_off == None:
        panel_off = et_off
    local_unix = utc_unix + panel_off
    ly, lmo, ld = _civil_from_days(local_unix // 86400)
    secs_of_day = local_unix % 86400
    lh = secs_of_day // 3600
    lm = (secs_of_day % 3600) // 60
    return MONTHS_FULL[lmo - 1][:3] + " " + str(ld) + ordinal_suffix(ld) + " " + format_ampm(lh, lm)

def local_race_daydate(ctx, race_date_str):
    # Date only (no time) -- for the compact schedule list.
    if race_date_str == "":
        return "TBD"
    y, mo, d, h, mi = parse_iso(race_date_str)
    naive_unix = _days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60
    et_off = eastern_offset_seconds()
    utc_unix = naive_unix - et_off
    panel_off = panel_offset_seconds(ctx)
    if panel_off == None:
        panel_off = et_off
    local_unix = utc_unix + panel_off
    ly, lmo, ld = _civil_from_days(local_unix // 86400)
    return MONTHS_FULL[lmo - 1][:3] + " " + str(ld)

# ---------- track drawing ----------

def draw_track_shape(c, shape, x, y, w, h, color):
    pts = SHAPE_POINTS.get(shape, SHAPE_POINTS["oval"])
    n = len(pts)
    scaled = []
    for i in range(n):
        px, py = pts[i]
        scaled.append((x + int(px * w), y + int(py * h)))
    for i in range(n):
        a = scaled[i]
        b = scaled[(i + 1) % n]
        c.line(a[0], a[1], b[0], b[1], color)

def draw_track_icon(c, track_name, x, y, w, h, color):
    shape = TRACK_SHAPE.get(str(track_name).upper(), "oval")
    draw_track_shape(c, shape, x, y, w, h, color)

def nascar_track_dims(track_name):
    entry = NASCAR_TRACK_ASSET.get(str(track_name).upper())
    if entry == None:
        return "", 26, 26
    return entry

def draw_nascar_track(c, track_name, asset, x, y, w, h):
    if asset != "":
        c.image(asset, x, y, w = w, h = h)
    else:
        draw_track_icon(c, track_name, x, y, w, h, COLORS["muted"])

def cap_track_dims(native_w, native_h, max_w, max_h):
    w, h = float(max_w), float(max_w) * float(native_h) / float(native_w)
    if h > max_h:
        h = float(max_h)
        w = float(max_h) * float(native_w) / float(native_h)
    return max(1, int(w + 0.5)), max(1, int(h + 0.5))

def series_logo_dims(series, max_w, max_h):
    asset, ratio = SERIES_LOGO.get(series, SERIES_LOGO["NASCAR"])
    w, h = float(max_w), float(max_w) / ratio
    if h > max_h:
        h = float(max_h)
        w = float(max_h) * ratio
    return asset, max(1, int(w + 0.5)), max(1, int(h + 0.5))

def draw_series_logo(c, series, x, y, w, h):
    asset, _, _ = series_logo_dims(series, w, h)
    c.image(asset, x, y, w = w, h = h)

# ---------- CF feed parsing ----------

def format_gap_time(delta):
    if delta == None:
        return ""
    value = float(delta)
    if value < 0:
        value = -value
    millis = int(value * 1000 + 0.5)
    secs_total = millis // 1000
    ms = millis % 1000
    if ms >= 100:
        ms_s = str(ms)
    elif ms >= 10:
        ms_s = "0" + str(ms)
    else:
        ms_s = "00" + str(ms)
    if secs_total >= 60:
        mins = secs_total // 60
        secs = secs_total % 60
        secs_s = str(secs) if secs >= 10 else "0" + str(secs)
        return "+" + str(mins) + ":" + secs_s + "." + ms_s
    return "+" + str(secs_total) + "." + ms_s

def gap_text(row, leader_laps, live_race):
    if row["pos"] == 1:
        return "", COLORS["accent2"]
    if row["status"] == 3:
        return "OUT", COLORS["muted"]
    if live_race:
        if row["status"] == 2:
            return "PIT", COLORS["accent2"]
        if row["status"] == 1 and not row["on_track"]:
            return "OFF", COLORS["error"]
        laps_down = leader_laps - row["laps"]
        if laps_down >= 2:
            return "-" + str(laps_down) + " LAPS", COLORS["muted"]
        if laps_down == 1:
            return "-1 LAP", COLORS["muted"]
    return format_gap_time(row["delta"]), COLORS["text"]

def series_key(name):
    return "series_" + str(SERIES_IDS.get(str(name), 1))

def _laps_led_total(car):
    total = 0
    for seg in car.get("laps_led", []):
        a = int(seg.get("start_lap", 0))
        b = int(seg.get("end_lap", 0))
        if b >= a:
            total += b - a + 1
    return total

def _pit_summary(stops):
    best = None
    cnt = 0
    for s in stops:
        dur = s.get("pit_stop_duration", 0)
        if dur and dur > 0:
            cnt += 1
            if best == None or dur < best:
                best = dur
    return best, cnt

def vehicle_rows(feed, series, live_race):
    vehicles = feed.get("vehicles", [])
    rows = []
    for car in vehicles:
        driver = car.get("driver", {})
        first = str(driver.get("first_name", "")).strip()
        rows.append({
            "pos": int(car.get("running_position", 0)),
            "num": str(car.get("vehicle_number", "?")),
            "name": clean_last(driver.get("last_name", driver.get("full_name", "?"))),
            "initial": first[0].upper() if first else "",
            "delta": car.get("delta", 0),
            "status": int(car.get("status", 0)),
            "on_track": bool(car.get("is_on_track", True)),
            "laps": int(car.get("laps_completed", 0)),
            "mfg": str(car.get("vehicle_manufacturer", "")),
            "chase": bool(driver.get("is_in_chase", False)),
            "start_pos": int(car.get("starting_position", 0)),
            "laps_led": _laps_led_total(car),
            "best_speed": float(car.get("best_lap_speed", 0) or 0),
            "best_lap_time": float(car.get("best_lap_time", 0) or 0),
            "pit_raw": car.get("pit_stops", []),
        })
    mark_duplicate_names(rows)
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            if rows[j]["pos"] > rows[j + 1]["pos"]:
                tmp = rows[j]
                rows[j] = rows[j + 1]
                rows[j + 1] = tmp

    leader_laps = rows[0]["laps"] if n > 0 else 0
    for row in rows:
        gap, _ = gap_text(row, leader_laps, live_race)
        row["gap"] = gap
        bg, txt_color = driver_colors(row["num"], series)
        row["bg"] = bg
        row["txt_color"] = txt_color
        pos_bg, pos_txt = pos_badge_colors(series, row["chase"])
        row["pos_bg"] = pos_bg
        row["pos_txt"] = pos_txt
    return rows

# ---------- state ----------

def fetch_schedule(ctx):
    series = safe_input(ctx, "series", "NASCAR")
    year = ctx.now.year
    resp = http_json("https://cf.nascar.com/cacher/" + str(year) + "/race_list_basic.json", 3600)
    if not resp["ok"]:
        return None, series, "CF " + str(resp["status"])
    return resp["data"], series, None

def _has_winner(race):
    w = race.get("winner_driver_id", 0)
    return not (w == None or w == 0 or w == "")

def pick_next(schedule, series):
    races = schedule.get(series_key(series), [])
    for race in races:
        if not _has_winner(race):
            return race
    return None

def pick_last_completed(schedule, series):
    races = schedule.get(series_key(series), [])
    last = None
    for race in races:
        if _has_winner(race):
            last = race
    return last

def upcoming_after_next(schedule, series, n):
    races = schedule.get(series_key(series), [])
    out = []
    seen_first = False
    for race in races:
        if _has_winner(race):
            continue
        if not seen_first:
            seen_first = True
            continue
        out.append(race)
        if len(out) >= n:
            break
    return out

# Temporary preview harness: `_debug` = "race" or "quali" returns a mock live
# state so the live boards can be rendered without a session in progress. Not a
# real manifest input, so it's inert once shipped. Remove once the live pages
# have been checked against an actual in-progress race.
def _mock_live(ctx, mode):
    specs = [
        (1, "24", "W", "BYRON", "Chv", False, 1, 0.0, 1, 1, 88, 181.4, 27.51),
        (2, "5", "K", "LARSON", "Chv", False, 2, 0.312, 1, 1, 42, 181.0, 27.60),
        (3, "9", "C", "ELLIOTT", "Chv", True, 4, 1.884, 1, 1, 5, 180.7, 27.65),
        (4, "11", "D", "HAMLIN", "Tyt", False, 3, 2.51, 1, 1, 61, 180.9, 27.62),
        (5, "19", "C", "BRISCOE", "Tyt", False, 8, 4.02, 1, 1, 0, 180.2, 27.71),
        (6, "22", "J", "LOGANO", "Frd", True, 6, 6.4, 1, 1, 12, 180.0, 27.75),
        (7, "1", "R", "CHASTAIN", "Chv", False, 12, 8.8, 1, 1, 0, 179.5, 27.80),
        (8, "45", "T", "REDDICK", "Tyt", False, 5, 10.1, 1, 1, 3, 179.8, 27.77),
        (9, "6", "B", "KESELOWSKI", "Frd", False, 9, 12.9, 1, 0, 0, 179.1, 27.90),
        (10, "12", "R", "BLANEY", "Frd", True, 7, 14.2, 3, 1, 8, 179.0, 27.92),
        (11, "20", "C", "BELL", "Tyt", True, 10, 15.6, 1, 1, 0, 178.9, 27.95),
        (12, "48", "A", "BOWMAN", "Chv", False, 14, 18.1, 1, 1, 0, 178.4, 28.01),
        (13, "17", "C", "BUESCHER", "Frd", False, 11, 19.9, 1, 1, 0, 178.2, 28.05),
        (14, "8", "K", "BUSCH", "Chv", False, 13, 22.4, 1, 1, 0, 178.0, 28.10),
        (15, "54", "T", "GIBBS", "Tyt", False, 16, 24.0, 1, 1, 0, 177.6, 28.15),
        (16, "23", "B", "WALLACE", "Tyt", True, 15, 26.7, 1, 1, 0, 177.2, 28.20),
        (17, "34", "T", "GILLILAND", "Frd", False, 18, 1, 1, 1, 0, 176.8, 28.25),
        (18, "3", "A", "DILLON", "Chv", False, 17, 1, 1, 1, 0, 176.5, 28.30),
        (19, "77", "C", "HOCEVAR", "Chv", False, 20, 1, 1, 0, 0, 176.0, 28.40),
        (20, "43", "E", "JONES", "Tyt", False, 19, 1, 3, 1, 0, 175.5, 28.50),
    ]
    rows = []
    for spec in specs:
        pos, num, ini, name, mfg, chase, start, delta, status, on_t, led, spd, blt = spec
        pit_raw = [{"pit_stop_duration": 12.9 + (pos % 5) * 0.4, "pit_in_lap_count": 88}] if mode == "race" and pos % 2 == 0 else []
        rows.append({
            "pos": pos, "num": num, "name": name, "initial": ini,
            "delta": delta, "status": status, "on_track": bool(on_t),
            "laps": 120 if status != 3 else 108, "mfg": mfg, "chase": chase,
            "start_pos": start, "laps_led": led if mode == "race" else 0,
            "best_speed": spd, "best_lap_time": blt, "pit_raw": pit_raw,
        })
    mark_duplicate_names(rows)
    is_race = mode == "race"
    for r in rows:
        g, _ = gap_text(r, 120, is_race)
        r["gap"] = g
        bg, tc = driver_colors(r["num"], safe_input(ctx, "series", "NASCAR"))
        r["bg"] = bg
        r["txt_color"] = tc
        pb, pt = pos_badge_colors(safe_input(ctx, "series", "NASCAR"), r["chase"])
        r["pos_bg"] = pb
        r["pos_txt"] = pt
    return {
        "mode": "live", "series": safe_input(ctx, "series", "NASCAR"),
        "session": "RACE" if is_race else "QUALIFYING", "is_race": is_race,
        "race_name": "COOK OUT SOUTHERN 500", "track_name": "DARLINGTON",
        "track_key": "DARLINGTON RACEWAY",
        "flag": 1 if is_race else 9, "lap": 120 if is_race else 0,
        "laps_total": 367 if is_race else 0, "laps_to_go": 247 if is_race else 0,
        "stage_num": 2 if is_race else 0, "rows": rows,
    }

def fetch_state(ctx):
    dbg = safe_input(ctx, "_debug", "")
    if dbg == "race" or dbg == "quali":
        return _mock_live(ctx, "race" if dbg == "race" else "quali")
    schedule, series, err = fetch_schedule(ctx)
    if err != None:
        return {"mode": "error", "title": "SCHEDULE ERROR", "sub": err}
    race = pick_next(schedule, series)
    last = pick_last_completed(schedule, series)
    if race == None and last == None:
        return {"mode": "error", "title": "NO RACE", "sub": "SCHEDULE EMPTY"}

    off_state = {
        "mode": "off",
        "series": series,
        "schedule": schedule,
        "has_next": race != None,
        "race_name": short_race(race.get("race_name", "SEASON DONE")) if race else "SEASON COMPLETE",
        "track_name": short_track(race.get("track_name", "")) if race else "",
        "track_key": str(race.get("track_name", "")) if race else "",
        "race_date": (race.get("race_date", race.get("date_scheduled", "")) if race else ""),
    }
    if race == None:
        return off_state

    series_id = int(race.get("series_id", SERIES_IDS.get(series, 1)))
    race_id = int(race.get("race_id", 0))
    live_url = ("https://cf.nascar.com/cacher/live/series_" + str(series_id) +
                "/" + str(race_id) + "/live-feed.json")
    live = http_json(live_url, 45)
    if not live["ok"]:
        return off_state

    feed = live["data"]
    lap = int(feed.get("lap_number", 0))
    flag = int(feed.get("flag_state", 0))
    session, base_name = session_and_name(feed.get("run_name", race.get("race_name", "RACE")))
    racing = lap > 0 or flag in (1, 2, 3, 4, 5, 9)

    has_results = len(feed.get("vehicles", [])) > 0
    race_date_str = race.get("race_date", race.get("date_scheduled", ""))
    within_grace = False
    if has_results and race_date_str != "":
        ry, rmo, rd, _, _ = parse_iso(race_date_str)
        scheduled_day_unix = _days_from_civil(ry, rmo, rd) * 86400
        within_grace = ctx.now.unix <= keep_until_end_of_day(ctx, scheduled_day_unix)
    if not racing and not within_grace:
        return off_state

    stage = feed.get("stage", {})
    is_race = session == "RACE" and racing
    return {
        "mode": "live",
        "series": series,
        "session": session,
        "is_race": is_race,
        "race_name": short_race(base_name),
        "track_name": short_track(feed.get("track_name", race.get("track_name", ""))),
        "track_key": str(feed.get("track_name", race.get("track_name", ""))),
        "flag": flag,
        "lap": lap,
        "laps_total": int(feed.get("laps_in_race", 0)),
        "laps_to_go": int(feed.get("laps_to_go", 0)),
        "stage_num": int(stage.get("stage_num", 0)),
        "rows": vehicle_rows(feed, series, is_race),
    }

def fetch_last_result(ctx):
    schedule, series, err = fetch_schedule(ctx)
    if err != None:
        return None
    race = pick_last_completed(schedule, series)
    if race == None:
        return None
    series_id = int(race.get("series_id", SERIES_IDS.get(series, 1)))
    race_id = int(race.get("race_id", 0))
    live = http_json("https://cf.nascar.com/cacher/live/series_" + str(series_id) +
                     "/" + str(race_id) + "/live-feed.json", 3600)
    top = []
    if live["ok"]:
        rows = vehicle_rows(live["data"], series, False)
        for r in rows[:5]:
            top.append((r["pos"], r["num"], r["name"], r["initial"]))
    return {
        "race_name": short_race(race.get("race_name", "RACE")),
        "track_name": short_track(race.get("track_name", "")),
        "comment": str(race.get("race_comments", "")),
        "top": top,
    }

# ---------- drawing: chrome + shared ----------

def draw_error(c, title, sub):
    c.fill(COLORS["bg"])
    c.rect(0, 0, c.width - 1, 9, fill = COLORS["panel"])
    c.image("checkered.png", 2, 1, w = 10, h = 8)
    c.text("NASCAR", 16, 2, font = "5x7", color = COLORS["accent"])
    c.text(str(title).upper(), 4, 14, font = "6x8", color = COLORS["error"])
    c.text(str(sub).upper(), 4, 24, font = "4x5", color = COLORS["muted"])

def draw_page_tab(c, label, color):
    w = c.text_width(label, "4x5") + 6
    c.rect(0, 0, w, 6, fill = color)
    c.text(label, 3, 1, font = "4x5", color = best_text_color(color))

def draw_driver_row_block(c, x0, x1, y0, y1, row):
    box_h = y1 - y0 + 1
    font = "5x7" if box_h >= 8 else "4x5"
    text_h = 7 if font == "5x7" else 6
    cy = y0 + (box_h - text_h) // 2

    gap_font = "4x5" if font == "5x7" else "picopixel"
    gap_text_h = 6 if gap_font == "4x5" else 5
    gap_cy = y0 + (box_h - gap_text_h) // 2

    pos_str = str(row["pos"]) + ")"
    pos_badge_w = c.text_width("40)", font) + 4
    c.rect(x0, y0, x0 + pos_badge_w - 1, y1, fill = row["pos_bg"])
    c.text(pos_str, x0 + 2, cy, font = font, color = row["pos_txt"])

    row_x0 = x0 + pos_badge_w + 1
    bg = row["bg"]
    txt_color = row["txt_color"]
    c.rect(row_x0, y0, x1, y1, fill = bg)

    num_str = str(row["num"])
    if len(num_str) < 2:
        num_str = " " * (2 - len(num_str)) + num_str
    prefix = num_str + " "
    who = (row["initial"] + "." + row["name"]) if row["initial"] else row["name"]

    gap = row.get("gap", "")
    gap_w = c.text_width(gap, gap_font) if gap != "" else 0
    reserve = (gap_w + 4) if gap_w > 0 else 0
    avail = (x1 - row_x0) - 6 - reserve
    who_max_w = avail - c.text_width(prefix, font)
    who = fit_text(c, who, font, who_max_w) if who_max_w > 0 else ""
    main = prefix + who
    c.text(main, row_x0 + 3, cy, font = font, color = txt_color)

    if gap != "":
        c.text(gap, x1 - 3, gap_cy, font = gap_font, color = txt_color, align = "right")

BOARD_COLS = 3
BOARD_ROWS = 4

def driver_grid_dims(avail_w, avail_h, num_cols = BOARD_COLS, rows_per_col = BOARD_ROWS):
    col_gap = 2
    col_w = (avail_w - col_gap * (num_cols - 1)) // num_cols
    row_h = avail_h // rows_per_col
    return num_cols, col_w, row_h

def board_capacity():
    return BOARD_COLS * BOARD_ROWS

def draw_driver_group(c, rows, start, col_x0, y0, y1):
    avail_w = c.width - col_x0
    avail_h = y1 - y0 + 1
    num_cols, col_w, row_h = driver_grid_dims(avail_w, avail_h)
    row_gap = 1 if row_h > 6 else 0
    idx = start
    for col in range(num_cols):
        cx0 = col_x0 + col * (col_w + 2)
        cx1 = cx0 + col_w - 1
        for row_i in range(BOARD_ROWS):
            if idx >= len(rows):
                return
            row = rows[idx]
            idx += 1
            ry0 = y0 + row_i * row_h
            ry1 = ry0 + row_h - 1 - row_gap
            draw_driver_row_block(c, cx0, cx1, ry0, ry1, row)

def draw_stat_group(c, items, col_x0, y0, y1, accent):
    # A generic single-line board, 3 per column: each item is
    # (rank_str, name, value_str, value_color) laid out rank | name ... value.
    avail_w = c.width - col_x0
    avail_h = y1 - y0 + 1
    num_cols, col_w, row_h = driver_grid_dims(avail_w, avail_h, 3, 3)
    bw = c.text_width("00", "4x5") + 4
    idx = 0
    for col in range(num_cols):
        cx0 = col_x0 + col * (col_w + 2)
        cx1 = cx0 + col_w - 1
        for row_i in range(3):
            if idx >= len(items):
                return
            rank_str, name, val, vcol = items[idx]
            idx += 1
            ry0 = y0 + row_i * row_h
            c.rect(cx0, ry0, cx0 + bw - 1, ry0 + 7, fill = accent)
            c.text(rank_str, cx0 + 2, ry0 + 1, font = "4x5", color = best_text_color(accent))
            vw = c.text_width(val, "4x5")
            c.text(val, cx1, ry0 + 1, font = "4x5", color = vcol, align = "right")
            nx = cx0 + bw + 3
            c.text(fit_text(c, name, "5x7", cx1 - nx - vw - 4), nx, ry0, font = "5x7", color = COLORS["text"])

# ---------- pages: fixed ----------

def logo(c, ctx):
    st = fetch_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
        return
    series = st["series"]
    tag = "LIVE" if st["mode"] == "live" else "NEXT UP"
    tcol = COLORS["error"] if st["mode"] == "live" else COLORS["muted"]
    _, logo_w, logo_h = series_logo_dims(series, c.width - 40, 19)
    logo_x = (c.width - logo_w) // 2
    logo_y = (28 - logo_h) // 2
    draw_series_logo(c, series, logo_x, logo_y, logo_w, logo_h)
    c.text(tag, c.width // 2, 27, font = "picopixel", color = tcol, align = "center")

def event(c, ctx):
    st = fetch_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
        return
    if st["mode"] == "off":
        _draw_next_card(c, ctx, st, big = True)
        return

    is_race = st["is_race"]
    session = st.get("session", "RACE")
    gap = 10
    track_asset, nw, nh = nascar_track_dims(st["track_key"])
    track_w, track_h = cap_track_dims(nw, nh, 40, 26)

    if is_race:
        status_w = 116
        text_w = c.width - track_w - status_w - gap * 3
    else:
        status_w = 0
        text_w = c.width - track_w - gap * 2

    total = text_w + gap + track_w + (gap + status_w if is_race else 0)
    margin = (c.width - total) // 2
    text_x0 = margin
    text_cx = text_x0 + text_w // 2
    track_x = text_x0 + text_w + gap
    track_y = (32 - track_h) // 2
    status_x0 = track_x + track_w + gap

    c.text(fit_text(c, st["race_name"], "6x8", text_w), text_cx, 1, font = "6x8", color = COLORS["text"], align = "center")
    c.text(fit_text(c, st["track_name"], "4x5", text_w), text_cx, 12, font = "4x5", color = COLORS["muted"], align = "center")
    c.text(fit_text(c, session, "5x7", text_w), text_cx, 21, font = "5x7", color = COLORS["accent2"], align = "center")

    draw_nascar_track(c, st["track_key"], track_asset, track_x, track_y, track_w, track_h)

    if is_race:
        sx = status_x0
        smw = c.width - sx - 2
        c.text(fit_text(c, FLAG_LABEL.get(st["flag"], "FLAG"), "6x8", smw), sx, 1, font = "6x8", color = flag_color(st["flag"]))
        lap_txt = "LAP " + str(st["lap"]) + "/" + str(st["laps_total"])
        c.text(fit_text(c, lap_txt, "4x5", smw), sx, 12, font = "4x5", color = COLORS["text"])
        stage_txt = "STAGE " + str(st["stage_num"]) + "/3" if st["stage_num"] > 0 else "FINAL STAGE"
        c.text(fit_text(c, stage_txt, "4x5", smw), sx, 21, font = "4x5", color = COLORS["accent2"])

def track(c, ctx):
    st = fetch_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
        return
    if st["mode"] == "off" and not st["has_next"]:
        c.text("SEASON COMPLETE", c.width // 2, 13, font = "6x8", color = COLORS["muted"], align = "center")
        return

    track_key = st["track_key"]
    track_name = st["track_name"]
    asset, nw, nh = nascar_track_dims(track_key)
    tw, th = cap_track_dims(nw, nh, 150, 30)
    tx = (c.width - tw) // 2 - 30
    ty = (32 - th) // 2
    draw_nascar_track(c, track_key, asset, tx, ty, tw, th)

    lx = tx + tw + 12
    c.text(fit_text(c, track_name, "6x8", c.width - lx - 2), lx, 6, font = "6x8", color = COLORS["text"])
    if st["mode"] == "live" and st.get("is_race"):
        c.text("LAP " + str(st["lap"]) + "/" + str(st["laps_total"]), lx, 17, font = "4x5", color = COLORS["muted"])
        if st.get("laps_to_go", 0) > 0:
            c.text(str(st["laps_to_go"]) + " TO GO", lx, 24, font = "4x5", color = COLORS["accent2"])
    else:
        c.text("THE TRACK", lx, 17, font = "4x5", color = COLORS["muted"])

# ---------- pages: flex slots ----------

def board1(c, ctx):
    _flex(c, ctx, 0)

def board2(c, ctx):
    _flex(c, ctx, 1)

def board3(c, ctx):
    _flex(c, ctx, 2)

def board4(c, ctx):
    _flex(c, ctx, 3)

def feed(c, ctx):
    _flex(c, ctx, 4)

FLEX_SLOTS = 5

def _flex_blocks(ctx, st):
    # Ordered content blocks for the five flex slots (board1..board4 + feed),
    # by state. Anything past the list wraps so no slot is ever blank.
    if st["mode"] == "error":
        return [("error", 0)]
    if st["mode"] == "off":
        return [("next", 0), ("sched", 0), ("result", 0)]

    cap = board_capacity()
    pages = max(1, (len(st["rows"]) + cap - 1) // cap)
    blocks = []
    for p in range(pages):
        blocks.append(("order", p))
    # The single feed slot alternates its two summaries each refresh -- it is
    # not paging a list, just showing whichever of two equally useful boards.
    tick = (ctx.now.unix // 120) % 2
    if st["is_race"]:
        blocks.append(("ledlaps", 0) if tick == 0 else ("pits", 0))
    else:
        blocks.append(("fastlap", 0) if tick == 0 else ("movers", 0))
    return blocks

def _flex(c, ctx, slot):
    st = fetch_state(ctx)
    c.fill(COLORS["bg"])
    blocks = _flex_blocks(ctx, st)
    kind, arg = blocks[slot % len(blocks)]

    if kind == "error":
        draw_error(c, st["title"], st["sub"])
    elif kind == "next":
        _draw_next_card(c, ctx, st, big = False)
    elif kind == "sched":
        _draw_schedule(c, ctx, st)
    elif kind == "result":
        _draw_last_result(c, ctx)
    elif kind == "order":
        _draw_order(c, ctx, st, arg)
    elif kind == "ledlaps":
        _draw_ledlaps(c, st)
    elif kind == "pits":
        _draw_pits(c, st)
    elif kind == "fastlap":
        _draw_fastlap(c, st)
    elif kind == "movers":
        _draw_movers(c, st)

def _draw_order(c, ctx, st, page):
    draw_flag_bar(c, st["flag"])
    draw_page_tab(c, "ORDER " + str(page + 1), COLORS["accent"])
    draw_driver_group(c, st["rows"], page * board_capacity(), 0, 8, 31)

def _draw_ledlaps(c, st):
    draw_page_tab(c, "LAPS LED", GOLD)
    ranked = sorted(st["rows"], key = lambda r: -r["laps_led"])
    ranked = [r for r in ranked if r["laps_led"] > 0][:9]
    if len(ranked) == 0:
        c.text("NO LAPS LED YET", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    items = []
    for i in range(len(ranked)):
        r = ranked[i]
        who = (r["initial"] + "." + r["name"]) if r["initial"] else r["name"]
        items.append((str(i + 1), who, str(r["laps_led"]), COLORS["accent2"]))
    draw_stat_group(c, items, 0, 8, 31, GOLD)

def _draw_pits(c, st):
    draw_page_tab(c, "PIT STOPS", "#38BDF8")
    entries = []
    for r in st["rows"]:
        best, cnt = _pit_summary(r.get("pit_raw", []))
        if best != None:
            entries.append((r, best, cnt))
    entries = sorted(entries, key = lambda e: e[1])[:9]
    if len(entries) == 0:
        c.text("NO GREEN-FLAG STOPS YET", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    items = []
    for i in range(len(entries)):
        r, dur, cnt = entries[i]
        who = (r["initial"] + "." + r["name"]) if r["initial"] else r["name"]
        items.append((str(i + 1), who, _sec(dur) + "S", "#7DD3FC"))
    draw_stat_group(c, items, 0, 8, 31, "#38BDF8")

def _draw_fastlap(c, st):
    draw_page_tab(c, "FAST LAP", "#A78BFA")
    ranked = [r for r in st["rows"] if r["best_speed"] > 0]
    ranked = sorted(ranked, key = lambda r: -r["best_speed"])[:9]
    if len(ranked) == 0:
        c.text("NO LAP TIMES YET", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    items = []
    for i in range(len(ranked)):
        r = ranked[i]
        who = (r["initial"] + "." + r["name"]) if r["initial"] else r["name"]
        val = _sec(r["best_lap_time"]) if r["best_lap_time"] > 0 else str(int(r["best_speed"]))
        items.append((str(i + 1), who, val, "#C4B5FD"))
    draw_stat_group(c, items, 0, 8, 31, "#A78BFA")

def _draw_movers(c, st):
    draw_page_tab(c, "MOVERS", "#22C55E")
    movers = []
    for r in st["rows"]:
        if r["start_pos"] > 0 and r["pos"] > 0:
            movers.append((r, r["start_pos"] - r["pos"]))
    movers = sorted(movers, key = lambda e: -e[1])[:9]
    if len(movers) == 0 or movers[0][1] <= 0:
        c.text("NO POSITIONS GAINED YET", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    items = []
    for i in range(len(movers)):
        r, delta = movers[i]
        who = (r["initial"] + "." + r["name"]) if r["initial"] else r["name"]
        sign = "+" + str(delta) if delta >= 0 else str(delta)
        col = "#22C55E" if delta >= 0 else COLORS["error"]
        items.append((str(r["pos"]), who, sign, col))
    draw_stat_group(c, items, 0, 8, 31, "#22C55E")

def _sec(v):
    v = float(v)
    whole = int(v)
    frac = int((v - whole) * 100 + 0.5)
    return str(whole) + "." + (("0" + str(frac)) if frac < 10 else str(frac))

# ---------- off-season cards ----------

def _draw_next_card(c, ctx, st, big):
    if not st["has_next"]:
        c.text("SEASON COMPLETE", c.width // 2, 8, font = "6x8", color = COLORS["muted"], align = "center")
        c.text("SEE YOU IN FEBRUARY", c.width // 2, 19, font = "4x5", color = COLORS["line"], align = "center")
        return
    date_color = safe_input(ctx, "datecolor", COLORS["accent2"])
    asset, nw, nh = nascar_track_dims(st["track_key"])
    tw, th = cap_track_dims(nw, nh, 52, 28)
    gap = 10
    text_w = c.width - tw - gap - 16
    total = text_w + gap + tw
    margin = (c.width - total) // 2
    tx0 = margin
    trx = tx0 + text_w + gap
    cx = tx0 + text_w // 2

    draw_nascar_track(c, st["track_key"], asset, trx, (32 - th) // 2, tw, th)
    if not big:
        draw_page_tab(c, "NEXT RACE", COLORS["accent"])
    c.text(fit_text(c, st["race_name"], "6x8", text_w), cx, 2, font = "6x8", color = COLORS["text"], align = "center")
    c.text(fit_text(c, st["track_name"], "4x5", text_w), cx, 13, font = "4x5", color = COLORS["muted"], align = "center")
    c.text(fit_text(c, local_race_date(ctx, st["race_date"]), "5x7", text_w), cx, 21, font = "5x7", color = date_color, align = "center")

def _draw_schedule(c, ctx, st):
    draw_page_tab(c, "SCHEDULE", COLORS["accent2"])
    races = upcoming_after_next(st["schedule"], st["series"], 3)
    if len(races) == 0:
        c.text("NO MORE RACES SCHEDULED", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    date_color = safe_input(ctx, "datecolor", COLORS["accent2"])
    dx = 4 + c.text_width("SEP 00", "5x7") + 8
    y = 8
    for r in races:
        dt = local_race_daydate(ctx, r.get("race_date", r.get("date_scheduled", "")))
        c.text(dt, 4, y, font = "5x7", color = date_color)
        nm = short_race(r.get("race_name", "RACE")) + "  -  " + short_track(r.get("track_name", ""))
        c.text(fit_text(c, nm, "5x7", c.width - dx - 4), dx, y, font = "5x7", color = COLORS["text"])
        y += 8

def _draw_last_result(c, ctx):
    draw_page_tab(c, "LAST RACE", "#E2E8F0")
    res = fetch_last_result(ctx)
    if res == None:
        c.text("NO RESULT AVAILABLE", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    c.text(fit_text(c, res["race_name"], "5x7", 180), 4, 8, font = "5x7", color = COLORS["text"])
    c.text(fit_text(c, res["track_name"], "picopixel", 180), 4, 16, font = "picopixel", color = COLORS["muted"])
    if len(res["top"]) > 0:
        x = 4
        y = 23
        for pos, num, name, initial in res["top"]:
            who = (initial + "." + name) if initial else name
            chip = str(pos) + " " + who
            w = c.text_width(chip, "picopixel") + 4
            if x + w > c.width - 2:
                break
            col = GOLD if pos == 1 else COLORS["muted"]
            c.text(chip, x, y, font = "picopixel", color = col)
            x += w + 3
    else:
        cmt = res["comment"]
        if cmt != "":
            c.text(fit_text(c, cmt.upper(), "4x5", c.width - 8), 4, 23, font = "4x5", color = COLORS["accent2"])
