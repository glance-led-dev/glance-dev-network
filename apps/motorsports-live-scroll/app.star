# Motorsports Live — NASCAR Cup / O'Reilly / Trucks / Formula 1 live leaderboard (384x32).
#
# Data: NASCAR's public Content Feed CDN (cf.nascar.com), the same source the
# nascar-companion app uses. Car-number badges are the same bundled assets;
# manufacturer-color plates are the fallback for numbers with no badge art.
#
# Off-session, the next scheduled race is shown with its date/time converted
# from NASCAR's Eastern-time schedule into the install's chosen time zone
# (a dropdown -> timeapi.io's TimeZone/zone lookup) instead of "now".
#
# NOTE ON STATUS CODES: NASCAR's live feed exposes `status` (1 = running,
# 3 = retired/garage — confirmed against a finished race) and `is_on_track`.
# There is no confirmed distinct code for "spun/off-track but still in the
# race" or "pitting" — those are inferred (status 1 + not on_track -> OFF;
# status 2 -> PIT) from the shape of the schema, not verified against a live
# in-progress race. Worth double-checking once this runs during an actual race.

SERIES_IDS = {
    "NASCAR": 1,
    "NASCAR - O'Reilly": 2,
    "NASCAR - Trucks": 3,
}

SERIES_SHORT = {
    "NASCAR": "CUP",
    "NASCAR - O'Reilly": "ORS",
    "NASCAR - Trucks": "TRK",
    "Formula 1": "F1",
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

# F1's race_control feed reports flag state as text (OpenF1), not NASCAR's
# numeric codes -- separate string-keyed table rather than trying to map
# onto FLAG_COLOR/FLAG_LABEL's scheme.
F1_FLAG_COLOR = {
    "GREEN": "#22C55E",
    "YELLOW": "#FACC15",
    "DOUBLE YELLOW": "#FACC15",
    "RED": "#EF4444",
    "SAFETY CAR": "#FACC15",
    "VIRTUAL SAFETY CAR": "#FACC15",
    "CHEQUERED": "#E2E8F0",
    "CLEAR": "#22C55E",
}

# Current tire compound between name and gap on F1 rows: a small black chip
# (same visual language as the manufacturer marks) with the compound letter
# in its real broadcast color -- black bg keeps it legible regardless of the
# row's own livery color. OpenF1's stints endpoint gives the compound name.
TIRE_BADGE = {
    "SOFT": ("S", "#E32227"),
    "MEDIUM": ("M", "#FFD700"),
    "HARD": ("H", "#FFFFFF"),
    "INTERMEDIATE": ("I", "#22C55E"),
    "WET": ("W", "#2563EB"),
}

MFG_COLOR = {
    "TYT": "#E10600",
    "TOYOTA": "#E10600",
    "FRD": "#003478",
    "FORD": "#003478",
    "CHV": "#D4A017",
    "CHEVY": "#D4A017",
    "CHEVROLET": "#D4A017",
    "DOD": "#A6192E",
    "DODGE": "#A6192E",
    "RAM": "#A6192E",
}

# Manufacturer name shown between the driver name and the gap. Tried as a
# small logo mark first -- at an ~8-10px row height, real logos (even
# thresholded/dilated to a clean silhouette) read as abstract blobs, not
# recognizable brands. Plain text, colored for contrast against the row's
# own livery color (best_text_color), reads reliably at any size instead.
MFG_LABEL = {
    "TYT": "TOYOTA",
    "TOYOTA": "TOYOTA",
    "FRD": "FORD",
    "FORD": "FORD",
    "CHV": "CHEVY",
    "CHEVY": "CHEVY",
    "CHEVROLET": "CHEVY",
    "DOD": "RAM",
    "DODGE": "RAM",
    "RAM": "RAM",
}

# Livery bg/text hex per car NUMBER (not driver) -- sourced from
# Motorsport-driver-hex-list.xlsx -- since the same number gets reassigned to
# a different driver between seasons/races far more often than it changes
# team livery. O'Reilly/Trucks reuse Cup's numbers for entirely different
# teams, so each series keeps its own table; never share one across series.
#
# Both hexes come straight from the reference doc rather than a computed
# contrast color, so text reads as the team's real second brand color. Car
# 48 (O'Reilly) and 52 (Trucks) were logged in the doc with an identical
# bg/text hex (invisible text); both got a corrected pair straight from the
# user rather than the black/white fallback used for any car number missing
# from the table entirely.
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
# instead of a " C" suffix crammed onto an already-tight name column --
# reads at a glance without costing any width. Default (non-chase, or a
# series with no playoff concept like F1) is the plain black/white badge.
CHASE_BADGE = {
    "NASCAR": ("#FACC15", "#000000"),
    "NASCAR - O'Reilly": ("#EF4444", "#FFFFFF"),
    "NASCAR - Trucks": ("#7DF9FF", "#FFFFFF"),
}

def pos_badge_colors(series, chase):
    if not chase:
        return "#000000", "#FFFFFF"
    return CHASE_BADGE.get(series, ("#000000", "#FFFFFF"))

# 2026 F1 team colors -- stored for the live F1 leaderboard once that has a
# timing data source wired up (next-race card only for now).
F1_TEAM_COLOR = {
    "FERRARI": "#DC0000",
    "MERCEDES": "#00D2BE",
    "MCLAREN": "#FF8000",
    "RED BULL RACING": "#1E5BC6",
    "RACING BULLS": "#2647D8",
    "ALPINE": "#0090FF",
    "ASTON MARTIN": "#006F62",
    "AUDI": "#C00000",
    "CADILLAC": "#111111",
    "WILLIAMS": "#005AFF",
    "HAAS": "#FFFFFF",
}

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

# Track-shape category per venue, keyed by CF's track_name text. No licensed
# per-track outline art exists for NASCAR ovals (checked — the open SVG/GeoJSON
# circuit datasets available are F1-focused and barely cover NASCAR's venues),
# so these are hand-built vector shapes by track TYPE rather than traced real
# layouts: still distinctive (oval vs. paperclip vs. triangle vs. road course
# read differently at a glance) without an asset-licensing question.
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

# Real traced outlines, once the user sent full-track maps -- (asset, native
# width, native height), same pre-sized/no-runtime-distortion approach as
# F1_TRACK_ASSET. Only used on the off-season card (see draw_offseason); the
# live header's icon is too small (~11x8) for a raster outline to read at
# all, so it stays on the generic TRACK_SHAPE vector regardless.
# Charlotte and Chicagoland were only available as SVGs and this environment
# has no working SVG rasterizer (no system cairo library) -- both still fall
# back to their TRACK_SHAPE vector ("quad" / default "oval").
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
    # No fixed 6-char cap here (unlike the 384px build): the driver grid at
    # this width is always a single column (see driver_grid_dims -- 192px
    # avail_w never clears the 110px second-column threshold), so a row has
    # the full row width to itself instead of sharing it with neighboring
    # columns. fit_text below still shrinks/truncates if a name is long
    # enough to need it.
    return name.upper()

def mark_duplicate_names(rows):
    # Last name alone reads cleanest and leaves the most room before the gap
    # column -- the first-initial prefix ("W.BYRON") is only worth the space
    # it costs when two drivers in the current field actually share a last
    # name (e.g. Austin/Ty Dillon), so only those rows keep their initial.
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
    # The track ("... AT Richmond Raceway") is already shown on its own, so
    # drop it here rather than truncate mid-word once it's cut for width.
    at_idx = text.find(" AT ")
    if at_idx > 0:
        text = text[:at_idx]
    text = text.replace("  ", " ").strip()
    return text

def session_and_name(run_name):
    # The live feed folds session type into run_name itself (e.g. "IOWA CORN
    # 350 BUSCH POLE QUALIFYING") rather than exposing it as its own field --
    # pull the session keyword back out so it can be its own row instead of
    # buried in the race name text.
    upper = str(run_name).upper()
    for kw in ("QUALIFYING", "PRACTICE"):
        idx = upper.find(kw)
        if idx > 0:
            return kw, upper[:idx].strip()
    return "RACE", upper

def fit_text(c, text, font, max_w):
    # Shrink to whole words first (no mid-word cuts), then char-by-char only
    # if a single word still doesn't fit.
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
    # Checkered/finish gets an actual black-and-white checkered pattern
    # instead of the solid off-white FLAG_COLOR entry -- reads instantly as
    # "session over" rather than looking like just another flag color.
    # NASCAR's flag is numeric (5/9 = checkered/finish); F1's is a string
    # from OpenF1's race_control feed ("CHEQUERED").
    is_checkered = flag == 5 or flag == 9 or flag == "CHEQUERED"
    if is_checkered:
        seg = 6
        num_segments = (c.width + seg - 1) // seg
        for i in range(num_segments):
            x = i * seg
            x2 = min(x + seg - 1, c.width - 1)
            c.rect(x, 0, x2, 1, fill = "#FFFFFF" if i % 2 == 0 else "#000000")
    elif type(flag) == "string":
        c.rect(0, 0, c.width - 1, 1, fill = F1_FLAG_COLOR.get(flag, COLORS["muted"]))
    else:
        c.rect(0, 0, c.width - 1, 1, fill = flag_color(flag))

def yiq_of(hex_color):
    h = hex_color.lstrip("#")
    r = int(h[0:2], 16)
    g = int(h[2:4], 16)
    b = int(h[4:6], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def best_text_color(hex_color):
    # Standard YIQ perceived-brightness midpoint. (This used to sit at 210 --
    # pushed up so bright colors defaulted to white per earlier feedback --
    # but that let genuinely bright/saturated backgrounds like #95D600 or
    # Chevy's manufacturer gold (#D4A017) get white text that's hard to read.
    # Back at the standard midpoint now that sponsor pairs needing white on a
    # brighter color (e.g. Bass Pro yellow) go through their own secondary
    # hex in driver_colors() instead of this generic fallback.)
    return "#111111" if yiq_of(hex_color) >= 150 else "#FFFFFF"

def driver_colors(num, mfg, series):
    # Each series reuses car numbers for entirely different teams, so each
    # gets its own table (see their definitions) -- never share one across
    # series, or a same-numbered car picks up the wrong livery color. Keyed
    # by car number rather than driver since drivers swap cars far more
    # often than a car's own livery changes.
    table = NASCAR_DRIVER_COLOR
    if series == "NASCAR - O'Reilly":
        table = ORS_DRIVER_COLOR
    elif series == "NASCAR - Trucks":
        table = TRUCK_DRIVER_COLOR
    elif series != "NASCAR":
        bg = mfg_color(mfg)
        return bg, best_text_color(bg)

    entry = table.get(str(num))
    if entry == None:
        return "#000000", "#FFFFFF"
    return entry

def mfg_color(code):
    # COLORS["accent"] (orange) used to be the catch-all here, but at panel
    # scale it reads close enough to the caution-flag yellow that unmapped
    # cars looked like they were flashing the flag color. Plain black
    # instead, so "no known livery color" reads as no color, not a gray bar.
    return MFG_COLOR.get(str(code).upper(), "#000000")

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
    # A timezone dropdown (see manifest) is a direct IANA-zone lookup --
    # simpler and one fewer network hop than the old zip -> lat/lon
    # (zippopotam.us) -> coordinate -> UTC-offset (timeapi.io) chain.
    tz_name = safe_input(ctx, "timezone", "America/New_York")
    return offset_seconds_for_zone(tz_name)

def _pad2(n):
    return ("0" + str(n)) if n < 10 else str(n)

def format_iso_utc(unix_ts):
    # Reverse of parse_iso -- OpenF1's date-range filters (e.g. "date>...")
    # need a real timestamp, not the whole session history (position/
    # intervals are 4MB+ unfiltered for a full race; a filtered ~3min
    # window is a few KB).
    days = unix_ts // 86400
    secs_of_day = unix_ts % 86400
    y, mo, d = _civil_from_days(days)
    hh = secs_of_day // 3600
    mm = (secs_of_day % 3600) // 60
    ss = secs_of_day % 60
    return str(y) + "-" + _pad2(mo) + "-" + _pad2(d) + "T" + _pad2(hh) + ":" + _pad2(mm) + ":" + _pad2(ss)

def keep_until_end_of_day(ctx, end_unix):
    # Don't drop back to "no live session" (the next-event card) the instant
    # a session's raw end time passes -- keep showing its results through
    # 23:59:59 of the SAME LOCAL DAY (the panel's own timezone, not UTC) it
    # finished on.
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
    # NASCAR's schedule times are Eastern wall-clock with no offset in the
    # string, so: treat as Eastern -> true UTC -> the panel's own local day.
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

def local_race_datetime(ctx, date_str, time_str):
    # F1's schedule (unlike NASCAR's) gives true UTC directly (date + "HH:MM:SSZ"),
    # so this skips the Eastern-offset step in local_race_date above.
    if date_str == "":
        return "TBD"
    t = time_str if time_str != "" else "00:00:00Z"
    y, mo, d, h, mi = parse_iso(date_str + "T" + t)
    utc_unix = _days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60
    panel_off = panel_offset_seconds(ctx)
    if panel_off == None:
        panel_off = 0
    local_unix = utc_unix + panel_off
    ly, lmo, ld = _civil_from_days(local_unix // 86400)
    secs_of_day = local_unix % 86400
    lh = secs_of_day // 3600
    lm = (secs_of_day % 3600) // 60
    return MONTHS_FULL[lmo - 1][:3] + " " + str(ld) + ordinal_suffix(ld) + " " + format_ampm(lh, lm)

# ---------- track icon (vector shape by track type; see TRACK_SHAPE note above) ----------

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

# ---------- driver number badge (identical asset set to nascar-companion) ----------

def plate_label(num):
    label = str(num)
    if len(label) > 2:
        label = label[:2]
    return label

def draw_number_plate(c, x, y, num, mfg):
    bg = mfg_color(mfg)
    label = plate_label(num)
    tw = c.text_width(label, "4x5")
    w = tw + 4
    if w < 11:
        w = 11
    c.rect(x, y, x + w - 1, y + 6, fill = bg)
    c.rect(x, y, x + w - 1, y, fill = "#FFFFFF")
    c.text(label, x + w // 2, y + 1, font = "4x5", color = "#FFFFFF", align = "center")
    return w

def draw_car_badge_small(c, x, y, num, mfg, size = 10):
    n = str(num)
    s = int(size)
    if n == "1":
        c.image("car-1-sm.png", x, y, w = s, h = s)
        return s
    if n == "10":
        c.image("car-10-sm.png", x, y, w = s, h = s)
        return s
    if n == "11":
        c.image("car-11-sm.png", x, y, w = s, h = s)
        return s
    if n == "12":
        c.image("car-12-sm.png", x, y, w = s, h = s)
        return s
    if n == "16":
        c.image("car-16-sm.png", x, y, w = s, h = s)
        return s
    if n == "17":
        c.image("car-17-sm.png", x, y, w = s, h = s)
        return s
    if n == "19":
        c.image("car-19-sm.png", x, y, w = s, h = s)
        return s
    if n == "2":
        c.image("car-2-sm.png", x, y, w = s, h = s)
        return s
    if n == "20":
        c.image("car-20-sm.png", x, y, w = s, h = s)
        return s
    if n == "21":
        c.image("car-21-sm.png", x, y, w = s, h = s)
        return s
    if n == "22":
        c.image("car-22-sm.png", x, y, w = s, h = s)
        return s
    if n == "23":
        c.image("car-23-sm.png", x, y, w = s, h = s)
        return s
    if n == "24":
        c.image("car-24-sm.png", x, y, w = s, h = s)
        return s
    if n == "3":
        c.image("car-3-sm.png", x, y, w = s, h = s)
        return s
    if n == "33":
        c.image("car-33-sm.png", x, y, w = s, h = s)
        return s
    if n == "34":
        c.image("car-34-sm.png", x, y, w = s, h = s)
        return s
    if n == "35":
        c.image("car-35-sm.png", x, y, w = s, h = s)
        return s
    if n == "38":
        c.image("car-38-sm.png", x, y, w = s, h = s)
        return s
    if n == "4":
        c.image("car-4-sm.png", x, y, w = s, h = s)
        return s
    if n == "41":
        c.image("car-41-sm.png", x, y, w = s, h = s)
        return s
    if n == "42":
        c.image("car-42-sm.png", x, y, w = s, h = s)
        return s
    if n == "43":
        c.image("car-43-sm.png", x, y, w = s, h = s)
        return s
    if n == "45":
        c.image("car-45-sm.png", x, y, w = s, h = s)
        return s
    if n == "47":
        c.image("car-47-sm.png", x, y, w = s, h = s)
        return s
    if n == "48":
        c.image("car-48-sm.png", x, y, w = s, h = s)
        return s
    if n == "5":
        c.image("car-5-sm.png", x, y, w = s, h = s)
        return s
    if n == "51":
        c.image("car-51-sm.png", x, y, w = s, h = s)
        return s
    if n == "54":
        c.image("car-54-sm.png", x, y, w = s, h = s)
        return s
    if n == "6":
        c.image("car-6-sm.png", x, y, w = s, h = s)
        return s
    if n == "60":
        c.image("car-60-sm.png", x, y, w = s, h = s)
        return s
    if n == "62":
        c.image("car-62-sm.png", x, y, w = s, h = s)
        return s
    if n == "67":
        c.image("car-67-sm.png", x, y, w = s, h = s)
        return s
    if n == "7":
        c.image("car-7-sm.png", x, y, w = s, h = s)
        return s
    if n == "71":
        c.image("car-71-sm.png", x, y, w = s, h = s)
        return s
    if n == "77":
        c.image("car-77-sm.png", x, y, w = s, h = s)
        return s
    if n == "78":
        c.image("car-78-sm.png", x, y, w = s, h = s)
        return s
    if n == "88":
        c.image("car-88-sm.png", x, y, w = s, h = s)
        return s
    if n == "9":
        c.image("car-9-sm.png", x, y, w = s, h = s)
        return s
    if n == "97":
        c.image("car-97-sm.png", x, y, w = s, h = s)
        return s
    return draw_number_plate(c, x, y + 1, n, mfg)

# ---------- CF feed parsing ----------

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
        })
    mark_duplicate_names(rows)
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            if rows[j]["pos"] > rows[j + 1]["pos"]:
                tmp = rows[j]
                rows[j] = rows[j + 1]
                rows[j + 1] = tmp

    # bg/txt_color/gap computed once here rather than at draw time -- keeps
    # draw_driver_row_block series-agnostic (F1 rows get built the same way,
    # see fetch_f1_live, without NASCAR-specific lookups like driver_colors).
    leader_laps = rows[0]["laps"] if n > 0 else 0
    for row in rows:
        gap, _ = gap_text(row, leader_laps, live_race)
        row["gap"] = gap
        bg, txt_color = driver_colors(row["num"], row["mfg"], series)
        row["bg"] = bg
        row["txt_color"] = txt_color
        pos_bg, pos_txt = pos_badge_colors(series, row["chase"])
        row["pos_bg"] = pos_bg
        row["pos_txt"] = pos_txt
    return rows

def format_gap_time(delta):
    # Always millisecond precision ("+X.XXX") -- qualifying gaps are decided
    # by thousandths, so the old tenths/hundredths rounding was throwing away
    # the digits that actually separate two drivers. Past a minute (rare, but
    # possible for a practice/quali lap run under caution), switch to
    # "+M:SS.XXX" instead of letting the seconds count run unbounded.
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
    # PIT/OFF only mean anything while a race is actually underway. Outside
    # that -- qualifying/practice (cars are naturally "not on track" between
    # timed runs), or the race itself once it's over (session frozen at the
    # checkered flag) -- treat status/on_track as stale and always show the
    # real gap/time instead of a leftover PIT/OFF guess.
    if live_race:
        if row["status"] == 2:
            return "PIT", COLORS["accent2"]
        if row["status"] == 1 and not row["on_track"]:
            return "OFF", COLORS["error"]
        # "Laps down" is a race-only concept -- outside a live race,
        # laps_completed just reflects how many out/in/timed laps each car
        # happened to run (qualifying, practice, or a session that's already
        # over), so a lower count there doesn't mean anything and must not
        # be read as being lapped.
        laps_down = leader_laps - row["laps"]
        if laps_down >= 2:
            return "-" + str(laps_down) + " LAPS", COLORS["muted"]
        if laps_down == 1:
            return "-1 LAP", COLORS["muted"]
    return format_gap_time(row["delta"]), COLORS["text"]

def series_key(name):
    return "series_" + str(SERIES_IDS.get(str(name), 1))

# F1 has no live-timing source wired up yet (next-race card only; see PR
# notes) — Jolpica-Ergast (api.jolpi.ca), the community successor to the
# retired Ergast API, gives the next scheduled race and its circuit in one
# free, keyless call.
# circuit_id -> (asset filename, native width, native height). Each asset is
# pre-sized (antialiased downscale done in Python, not at render time -- a
# naive runtime resize of a detailed track outline turns to mush/blobs, see
# PR notes), so it's drawn at its own saved dimensions, not stretched into a
# fixed box the way the generic fallback shape is.
F1_TRACK_ASSET = {
    "albert_park": ("track-albert-park.png", 51, 26),
    "americas": ("track-americas.png", 36, 26),
    "bahrain": ("track-bahrain.png", 39, 26),
    "baku": ("track-baku.png", 40, 26),
    "catalunya": ("track-catalunya.png", 60, 19),
    "hungaroring": ("track-hungaroring.png", 24, 26),
    "imola": ("track-imola.png", 46, 26),
    "interlagos": ("track-interlagos.png", 42, 26),
    "istanbul": ("track-istanbul.png", 40, 26),
    "jeddah": ("track-jeddah.png", 44, 26),
    "losail": ("track-losail.png", 36, 26),
    "marina_bay": ("track-marina-bay.png", 40, 26),
    "miami": ("track-miami.png", 60, 23),
    "monaco": ("track-monaco.png", 39, 26),
    "monza": ("track-monza.png", 51, 26),
    "nurburgring": ("track-nurburgring.png", 28, 26),
    "red_bull_ring": ("track-red-bull-ring.png", 40, 26),
    "ricard": ("track-ricard.png", 59, 26),
    "rodriguez": ("track-rodriguez.png", 40, 26),
    "silverstone": ("track-silverstone.png", 26, 26),
    "villeneuve": ("track-villeneuve.png", 46, 26),
    "zandvoort": ("track-zandvoort.png", 30, 26),
}
FALLBACK_TRACK_W, FALLBACK_TRACK_H = 31, 26

def track_asset_dims(circuit_id):
    entry = F1_TRACK_ASSET.get(circuit_id)
    if entry == None:
        return "", FALLBACK_TRACK_W, FALLBACK_TRACK_H
    return entry

def fetch_f1_next(ctx):
    resp = http_json("https://api.jolpi.ca/ergast/f1/current/next.json", 3600)
    if not resp["ok"]:
        return {"ok": False, "title": "F1 SCHEDULE ERROR", "sub": "HTTP " + str(resp["status"])}
    races = resp["data"].get("MRData", {}).get("RaceTable", {}).get("Races", [])
    if len(races) == 0:
        return {"ok": False, "title": "NO RACE", "sub": "SEASON COMPLETE"}
    race = races[0]
    circuit = race.get("Circuit", {})
    return {
        "ok": True,
        "race_name": str(race.get("raceName", "RACE")).upper(),
        "track_name": str(circuit.get("circuitName", "")).upper(),
        "circuit_id": str(circuit.get("circuitId", "")),
        "race_date": str(race.get("date", "")),
        "race_time": str(race.get("time", "")),
    }

def latest_by_driver(entries):
    latest = {}
    for e in entries:
        dn = e.get("driver_number")
        if dn == None:
            continue
        latest[dn] = e
    return latest

def fetch_f1_live(ctx):
    # OpenF1 (free, verified working -- see PR notes; OCBLACKTOP's real-time
    # gap/position data is WebSocket/webhook-only and unreachable from this
    # platform's http.get-only sandbox). No "current session" endpoint
    # exists, so this fetches the latest session and checks it's actually
    # within its live window (plus the same end-of-day grace as NASCAR)
    # rather than trusting "latest" to mean "live right now."
    sresp = http_json("https://api.openf1.org/v1/sessions?session_key=latest", 30)
    if not sresp["ok"] or len(sresp["data"]) == 0:
        return None
    session = sresp["data"][0]

    sy, smo, sd, sh, smi = parse_iso(session.get("date_start", ""))
    ey, emo, ed, eh, emi = parse_iso(session.get("date_end", ""))
    start_unix = _days_from_civil(sy, smo, sd) * 86400 + sh * 3600 + smi * 60
    end_unix = _days_from_civil(ey, emo, ed) * 86400 + eh * 3600 + emi * 60
    now_unix = ctx.now.unix
    if now_unix < start_unix or now_unix > keep_until_end_of_day(ctx, end_unix):
        return None

    session_key = session.get("session_key")
    session_type = str(session.get("session_type", "Race")).upper()
    circuit_short = str(session.get("circuit_short_name", ""))

    race_name = "RACE"
    mresp = http_json("https://api.openf1.org/v1/meetings", 3600, params = {"meeting_key": str(session.get("meeting_key", ""))})
    if mresp["ok"] and len(mresp["data"]) > 0:
        race_name = str(mresp["data"][0].get("meeting_name", "RACE")).upper()

    weather_txt = ""
    wresp = http_json("https://api.openf1.org/v1/weather", 60, params = {"session_key": str(session_key)})
    if wresp["ok"] and len(wresp["data"]) > 0:
        w = wresp["data"][len(wresp["data"]) - 1]
        track_temp = w.get("track_temperature")
        if track_temp != None:
            rain = w.get("rainfall", 0)
            cond = "RAIN" if rain and rain > 0 else "DRY"
            weather_txt = str(int(track_temp)) + "C " + cond

    drivers = {}
    dresp = http_json("https://api.openf1.org/v1/drivers", 300, params = {"session_key": str(session_key)})
    if dresp["ok"]:
        for d in dresp["data"]:
            dn = d.get("driver_number")
            if dn != None:
                drivers[dn] = d

    # Full-session position/intervals are 4MB+ (checked against a real race)
    # -- a recent-only window keeps this to a few KB per render.
    cutoff = format_iso_utc(now_unix - 150)
    presp = http_json("https://api.openf1.org/v1/position?session_key=" + str(session_key) + "&date%3E" + cutoff, 15)
    positions = latest_by_driver(presp["data"]) if presp["ok"] else {}
    iresp = http_json("https://api.openf1.org/v1/intervals?session_key=" + str(session_key) + "&date%3E" + cutoff, 15)
    intervals = latest_by_driver(iresp["data"]) if iresp["ok"] else {}

    # Stints are keyed by stint_number, not a timestamp, but the API returns
    # them in stint order -- the last one seen per driver is their current
    # tire (latest_by_driver just keeps overwriting as it walks the array).
    tresp = http_json("https://api.openf1.org/v1/stints?session_key=" + str(session_key), 60)
    stints = latest_by_driver(tresp["data"]) if tresp["ok"] else {}

    # race_control doubles as the flag-state source (most recent Track-scope
    # Flag message) and a rough current-lap indicator (its own lap_number) --
    # OpenF1 has no direct "total race laps" field, so lap shows without a
    # "/total", unlike NASCAR's "LAP X/Y".
    flag_str = "GREEN"
    lap_num = 0
    rcresp = http_json("https://api.openf1.org/v1/race_control?session_key=" + str(session_key), 15)
    if rcresp["ok"]:
        for e in rcresp["data"]:
            ln = e.get("lap_number")
            if ln != None:
                lap_num = int(ln)
            if e.get("category") == "Flag" and e.get("scope") == "Track" and e.get("flag") != None:
                flag_str = str(e.get("flag")).upper()

    rows = []
    for dn, pos_entry in positions.items():
        driver = drivers.get(dn, {})
        interval_entry = intervals.get(dn, {})
        gap_raw = interval_entry.get("gap_to_leader")
        gap_str = ""
        if gap_raw != None:
            gap_str = gap_raw if type(gap_raw) == "string" else format_gap_time(gap_raw)

        last_name = str(driver.get("last_name", "")).upper()
        first_name = str(driver.get("first_name", ""))
        team_colour = str(driver.get("team_colour", ""))
        bg = ("#" + team_colour) if team_colour != "" else "#000000"
        compound = str(stints.get(dn, {}).get("compound", "")).upper()

        rows.append({
            "pos": int(pos_entry.get("position", 0)),
            "num": str(dn),
            "initial": first_name[0].upper() if first_name else "",
            "name": last_name if last_name != "" else "?",
            "chase": False,
            "gap": gap_str,
            "bg": bg,
            "txt_color": best_text_color(bg),
            "pos_bg": "#000000",
            "pos_txt": "#FFFFFF",
            "compound": compound,
        })

    mark_duplicate_names(rows)
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            if rows[j]["pos"] > rows[j + 1]["pos"]:
                tmp = rows[j]
                rows[j] = rows[j + 1]
                rows[j + 1] = tmp

    return {
        "ok": True,
        "live": True,
        "series": "Formula 1",
        "race_name": race_name,
        "session": session_type,
        "track_name": circuit_short.upper(),
        "track_key": circuit_short.lower().replace(" ", "_"),
        "flag": flag_str,
        "lap": lap_num,
        "weather": weather_txt,
        "rows": rows,
    }

def draw_f1_track(c, asset, circuit_id, x, y, w, h):
    if asset != "":
        c.image(asset, x, y, w = w, h = h)
    else:
        # No traced outline for this circuit yet -- generic road-course shape,
        # same fallback style as NASCAR's untraced venues.
        draw_track_shape(c, "roadcourse", x, y, w, h, COLORS["muted"])

# ---------- shared "next race" card (logo, 3-line info, track shape) ----------
# One layout for every series' off-session screen: a compact, centered group
# rather than pinned to the panel edges, so it reads as one card regardless
# of how much of the 384px width is unused.

def next_race_layout(c, logo_w, logo_h, text_w, track_w, track_h, gap = 10):
    total = logo_w + gap + text_w + gap + track_w
    margin = (c.width - total) // 2
    logo_x = margin
    logo_y = (32 - logo_h) // 2
    text_x0 = logo_x + logo_w + gap
    text_x1 = text_x0 + text_w
    track_x = text_x1 + gap
    track_y = (32 - track_h) // 2
    return logo_x, logo_y, text_x0, text_x1, track_x, track_y

def draw_next_race_text(c, ctx, text_x0, text_w, race_name, sub_name, date_text):
    date_color = safe_input(ctx, "datecolor", COLORS["accent2"])
    cx = text_x0 + text_w // 2
    c.text(fit_text(c, race_name, "5x7", text_w), cx, 2, font = "5x7", color = COLORS["text"], align = "center")
    c.text(fit_text(c, sub_name, "4x5", text_w), cx, 12, font = "4x5", color = COLORS["muted"], align = "center")
    c.text(fit_text(c, date_text, "5x7", text_w), cx, 21, font = "5x7", color = date_color, align = "center")

# Off-season "next race" event frame's track-shape box: no logo competing
# here (that's its own frame -- see draw_series_logo_frame), just text, so
# the track shape gets real size.
EVENT_TRACK_MAX_W = 48
EVENT_TRACK_MAX_H = 28

def draw_offseason_f1_event(c, state, ctx):
    # Second of two off-season "next race" frames (F1): race name/track/
    # date plus the track shape, no logo -- see draw_series_logo_frame for
    # that, and live() for how the two are cycled.
    c.fill(COLORS["bg"])

    track_asset, native_w, native_h = track_asset_dims(state["circuit_id"])
    track_w, track_h = cap_track_dims(native_w, native_h, EVENT_TRACK_MAX_W, EVENT_TRACK_MAX_H)
    gap = 8
    text_w = c.width - track_w - gap - 8
    total = text_w + gap + track_w
    margin = (c.width - total) // 2
    text_x0 = margin
    track_x = text_x0 + text_w + gap
    track_y = (32 - track_h) // 2

    draw_f1_track(c, track_asset, state["circuit_id"], track_x, track_y, track_w, track_h)

    when = local_race_datetime(ctx, state["race_date"], state["race_time"])
    draw_next_race_text(c, ctx, text_x0, text_w, state["race_name"], state["track_name"], when)

def fetch_schedule(ctx):
    series = safe_input(ctx, "series", "NASCAR")
    year = ctx.now.year
    resp = http_json("https://cf.nascar.com/cacher/" + str(year) + "/race_list_basic.json", 3600)
    if not resp["ok"]:
        return None, series, {"ok": False, "title": "SCHEDULE ERROR", "sub": "CF " + str(resp["status"])}
    return resp["data"], series, None

def pick_next(schedule, series):
    races = schedule.get(series_key(series), [])
    for race in races:
        winner = race.get("winner_driver_id", 0)
        if winner == None or winner == 0 or winner == "":
            return race
    return None

def fetch_state(ctx):
    schedule, series, err = fetch_schedule(ctx)
    if err != None:
        return err
    race = pick_next(schedule, series)
    if race == None:
        return {"ok": False, "title": "NO RACE", "sub": "SCHEDULE EMPTY"}

    series_id = int(race.get("series_id", SERIES_IDS.get(series, 1)))
    race_id = int(race.get("race_id", 0))
    live_url = ("https://cf.nascar.com/cacher/live/series_" + str(series_id) +
                "/" + str(race_id) + "/live-feed.json")
    live = http_json(live_url, 45)

    off_state = {
        "ok": True,
        "live": False,
        "series": series,
        "race_name": short_race(race.get("race_name", "RACE")),
        "track_name": short_track(race.get("track_name", "")),
        "track_key": str(race.get("track_name", "")),
        "race_date": race.get("race_date", race.get("date_scheduled", "")),
    }
    if not live["ok"]:
        return off_state

    feed = live["data"]
    lap = int(feed.get("lap_number", 0))
    flag = int(feed.get("flag_state", 0))
    session, base_name = session_and_name(feed.get("run_name", race.get("race_name", "RACE")))

    racing = lap > 0 or flag in (1, 2, 3, 4, 5, 9)

    # A finished session (practice, qualifying, or the race itself) still has
    # meaningful results worth keeping on screen -- don't fall back to the
    # next-race card just because the race-oriented lap/flag check above says
    # nothing's "racing" anymore. That holds through 23:59:59 local on the
    # scheduled race day (NASCAR's feed doesn't expose an explicit session-
    # completion timestamp, so the scheduled day is the best available anchor).
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
    return {
        "ok": True,
        "live": True,
        "series": series,
        "race_name": short_race(base_name),
        "session": session,
        "track_name": short_track(feed.get("track_name", race.get("track_name", ""))),
        "track_key": str(feed.get("track_name", race.get("track_name", ""))),
        "flag": flag,
        "lap": lap,
        "laps_total": int(feed.get("laps_in_race", 0)),
        "stage_num": int(stage.get("stage_num", 0)),
        "rows": vehicle_rows(feed, series, session == "RACE" and racing),
    }

# ---------- drawing ----------

def draw_error(c, title, sub):
    c.fill(COLORS["bg"])
    c.rect(0, 0, c.width - 1, 9, fill = COLORS["panel"])
    c.image("checkered.png", 2, 1, w = 10, h = 8)
    c.text("MOTORSPORTS", 16, 2, font = "5x7", color = COLORS["accent"])
    c.text(title, 4, 14, font = "6x8", color = COLORS["error"])
    c.text(sub, 4, 24, font = "4x5", color = COLORS["muted"])

# Real series/sponsor wordmarks (recolored for a dark panel -- NASCAR's is
# white instead of its native black) in place of the checkered+abbreviation
# placeholder. Width/height ratios match each asset's actual pixel size.
SERIES_LOGO = {
    "NASCAR": ("nascar-logo.png", 128.0 / 22.0),
    "NASCAR - O'Reilly": ("oreilly-logo.png", 57.0 / 24.0),
    "NASCAR - Trucks": ("trucks-logo.png", 99.0 / 22.0),
    "Formula 1": ("f1-logo.png", 90.0 / 24.0),
}

def series_logo_dims(series, max_w, max_h):
    # Contain-fit within the box (like the mockup's drawLogo helper) instead
    # of one fixed height for every series: NASCAR's wordmark is wide and
    # thin so it's width-capped, but Trucks/O'Reilly are close to square and
    # were sitting well short of the available height under a shared fixed
    # height -- this lets each maximize on its own terms.
    asset, ratio = SERIES_LOGO.get(series, SERIES_LOGO["NASCAR"])
    w, h = float(max_w), float(max_w) / ratio
    if h > max_h:
        h = float(max_h)
        w = float(max_h) * ratio
    return asset, max(1, int(w + 0.5)), max(1, int(h + 0.5))

def cap_track_dims(native_w, native_h, max_w, max_h):
    # Same contain-fit as series_logo_dims: at this width the track shape's
    # native size (up to ~59px on wide circuits) crowds out the race
    # name/status text, so it's shrunk to a small fixed-size icon instead of
    # dropped -- present, but no longer competing with the text for room.
    w, h = float(max_w), float(max_w) * float(native_h) / float(native_w)
    if h > max_h:
        h = float(max_h)
        w = float(max_h) * float(native_w) / float(native_h)
    return max(1, int(w + 0.5)), max(1, int(h + 0.5))

def draw_series_logo(c, series, x, y, w, h):
    asset, _, _ = series_logo_dims(series, w, h)
    c.image(asset, x, y, w = w, h = h)

def draw_series_logo_box(c, series, x, y, w, h):
    # Same checkered-flag + abbreviation mark as the live header's badge
    # (draw_series_badge), just laid out to fill a box instead of hugging a
    # top-left corner -- NASCAR has no full wordmark asset the way F1 does.
    icon_y = y + (h - 8) // 2
    c.image("checkered.png", x, icon_y, w = 10, h = 8)
    text_y = y + (h - 7) // 2
    c.text(SERIES_SHORT.get(series, "CUP"), x + 13, text_y, font = "5x7", color = COLORS["accent"])

def fit_row_budget(c, fixed_w, gap, shares, floor = 18):
    # Splits whatever width is left after `fixed_w` (the track shape, which
    # is a per-venue native size) and the gaps between `len(shares)` other
    # sections, proportioned by `shares` -- so the row always stays on-panel
    # instead of running past the edge the way the fixed pixel budgets below
    # (tuned for a 384px panel) do on a narrower one. Order of the returned
    # widths matches the order of `shares`.
    total_share = 0.0
    for s in shares:
        total_share += s
    budget = c.width - fixed_w - gap * len(shares) - 4
    if budget < floor * len(shares):
        budget = floor * len(shares)
    sizes = []
    used = 0
    for i in range(len(shares) - 1):
        w = max(floor, int(budget * shares[i] / total_share))
        sizes.append(w)
        used += w
    sizes.append(max(floor, budget - used))
    return sizes

def draw_offseason_event(c, state, ctx):
    # Second of two off-season "next race" frames: race name/track/date
    # plus the track shape, no logo -- see draw_series_logo_frame for that,
    # and live() for how the two are cycled.
    c.fill(COLORS["bg"])

    track_asset, native_w, native_h = nascar_track_dims(state["track_key"])
    track_w, track_h = cap_track_dims(native_w, native_h, EVENT_TRACK_MAX_W, EVENT_TRACK_MAX_H)
    gap = 8
    text_w = c.width - track_w - gap - 8
    total = text_w + gap + track_w
    margin = (c.width - total) // 2
    text_x0 = margin
    track_x = text_x0 + text_w + gap
    track_y = (32 - track_h) // 2

    draw_nascar_track(c, state["track_key"], track_asset, track_x, track_y, track_w, track_h)

    date_text = local_race_date(ctx, state["race_date"])
    draw_next_race_text(c, ctx, text_x0, text_w, state["race_name"], state["track_name"], date_text)

def draw_series_logo_frame(c, series):
    # The logo-only frame shared by both the off-season "next race" card and
    # the live-session header (see draw_offseason_event/draw_offseason_f1_event
    # and draw_live_details, plus live() for how all of these are cycled).
    # Nothing else competes for width here, so it's as big as the panel
    # allows.
    c.fill(COLORS["bg"])
    _, logo_w, logo_h = series_logo_dims(series, c.width - 16, 30)
    logo_x = (c.width - logo_w) // 2
    logo_y = (32 - logo_h) // 2
    draw_series_logo(c, series, logo_x, logo_y, logo_w, logo_h)

# Live-session details frame's track-shape box: smaller than the off-season
# event frame's since the status column (flag/lap/stage) also needs room
# here on a race.
DETAILS_TRACK_MAX_W = 40
DETAILS_TRACK_MAX_H = 26

def draw_live_details(c, state, ctx):
    # Second of two live-session frames: race name, track/circuit, session
    # type, the track shape, and (on a race) flag/lap/stage-or-weather --
    # no logo, that's its own frame (see draw_series_logo_frame). Driver
    # rows get their own frames after this one (see live()).
    c.fill(COLORS["bg"])

    is_f1 = state["series"] == "Formula 1"
    session = state.get("session", "RACE")
    is_race = session == "RACE"
    gap = 8

    if is_f1:
        track_asset, native_w, native_h = track_asset_dims(state["track_key"])
    else:
        track_asset, native_w, native_h = nascar_track_dims(state["track_key"])
    track_w, track_h = cap_track_dims(native_w, native_h, DETAILS_TRACK_MAX_W, DETAILS_TRACK_MAX_H)

    # Flag/lap/(stage or weather) only mean anything once the race itself is
    # underway -- practice and qualifying don't have any of the three, so
    # that column (and the width it would've used) drops out entirely and
    # the rest recenters into the space.
    if is_race:
        text_w, status_w = fit_row_budget(c, track_w, gap, [130.0, 115.0])
    else:
        text_w = c.width - track_w - gap - 8
        status_w = 0

    total = text_w + gap + track_w + (gap + status_w if is_race else 0)
    margin = (c.width - total) // 2
    text_x0 = margin
    text_cx = text_x0 + text_w // 2
    track_x = text_x0 + text_w + gap
    track_y = (32 - track_h) // 2
    status_x0 = track_x + track_w + gap

    race_name = fit_text(c, state["race_name"], "5x7", text_w)
    c.text(race_name, text_cx, 2, font = "5x7", color = COLORS["text"], align = "center")
    track_name = fit_text(c, state["track_name"], "4x5", text_w)
    c.text(track_name, text_cx, 12, font = "4x5", color = COLORS["muted"], align = "center")
    session_txt = fit_text(c, session, "5x7", text_w)
    c.text(session_txt, text_cx, 21, font = "5x7", color = COLORS["accent2"], align = "center")

    if is_f1:
        draw_f1_track(c, track_asset, state["track_key"], track_x, track_y, track_w, track_h)
    else:
        draw_nascar_track(c, state["track_key"], track_asset, track_x, track_y, track_w, track_h)

    if is_race:
        sx = status_x0 + 2
        status_max_w = c.width - sx - 2
        if is_f1:
            flag_str = state["flag"]
            c.text(fit_text(c, flag_str, "5x7", status_max_w), sx, 2, font = "5x7", color = F1_FLAG_COLOR.get(flag_str, COLORS["muted"]))
            c.text(fit_text(c, "LAP " + str(state["lap"]), "4x5", status_max_w), sx, 12, font = "4x5", color = COLORS["text"])
            weather_txt = state.get("weather", "")
            if weather_txt != "":
                c.text(fit_text(c, weather_txt, "4x5", status_max_w), sx, 21, font = "4x5", color = COLORS["accent2"])
        else:
            c.text(fit_text(c, FLAG_LABEL.get(state["flag"], "FLAG"), "5x7", status_max_w), sx, 2, font = "5x7", color = flag_color(state["flag"]))
            c.text(fit_text(c, "LAP " + str(state["lap"]) + "/" + str(state["laps_total"]), "4x5", status_max_w), sx, 12, font = "4x5", color = COLORS["text"])
            stage_txt = "STAGE " + str(state["stage_num"]) + "/3" if state["stage_num"] > 0 else "STAGE -"
            c.text(fit_text(c, stage_txt, "4x5", status_max_w), sx, 21, font = "4x5", color = COLORS["accent2"])

def draw_driver_row_block(c, x0, x1, y0, y1, row):
    # bg/txt_color/gap are precomputed once when the row list is built (see
    # vehicle_rows for NASCAR, fetch_f1_live for F1) rather than derived here
    # -- keeps this drawing code series-agnostic instead of coupled to
    # NASCAR-specific lookups (driver_colors, gap_text) that don't apply to
    # F1's different data shape.
    box_h = y1 - y0 + 1
    font = "5x7" if box_h >= 8 else "4x5"
    text_h = 7 if font == "5x7" else 6
    cy = y0 + (box_h - text_h) // 2

    # Gap gets one size step down from the name -- just enough to read as a
    # secondary, less important number rather than competing with the name.
    gap_font = "4x5" if font == "5x7" else "picopixel"
    gap_text_h = 6 if gap_font == "4x5" else 5
    gap_cy = y0 + (box_h - gap_text_h) // 2

    # Position gets its own fixed-width badge, independent of the row's
    # livery color so running order always reads at a glance -- black/white
    # normally, recolored per series (see CHASE_BADGE) when the driver is in
    # the playoffs, instead of a " C" suffix competing with the name for
    # width.
    pos_str = str(row["pos"]) + ")"
    pos_badge_w = c.text_width("40)", font) + 4
    c.rect(x0, y0, x0 + pos_badge_w - 1, y1, fill = row["pos_bg"])
    c.text(pos_str, x0 + 2, cy, font = font, color = row["pos_txt"])

    # Real sponsor/team color as the rest of the row's background (see
    # motorsports-color-reference.md) with a computed contrast text color,
    # rather than a black row + small manufacturer-color badge.
    row_x0 = x0 + pos_badge_w + 1
    bg = row["bg"]
    txt_color = row["txt_color"]
    c.rect(row_x0, y0, x1, y1, fill = bg)

    # A small badge between name and gap: the manufacturer mark (NASCAR) or
    # the current tire compound letter (F1) -- whichever the row carries.
    # Reserved as its own slot, same pattern as the gap reserve below, so
    # the name shrinks to make room instead of the badge overlapping it.
    badge_w = 0
    badge_kind = None
    badge_letter = None
    badge_color = None
    mfg_label = MFG_LABEL.get(str(row.get("mfg", "")).upper())
    compound_entry = TIRE_BADGE.get(str(row.get("compound", "")).upper())
    if compound_entry != None:
        badge_kind = "tire"
        badge_letter, badge_color = compound_entry
        badge_w = c.text_width(badge_letter, "4x5") + 4
    elif mfg_label != None:
        badge_kind = "mfg"
        badge_letter = mfg_label
        # Fixed to "TOYOTA"'s width (the longest label) rather than each
        # label's own width, so the gap column lines up in the same spot
        # on every row regardless of which manufacturer it is -- the name
        # is what gives up room to make this consistent, not the alignment.
        badge_w = c.text_width("TOYOTA", gap_font)
    badge_reserve = (badge_w + 6) if badge_kind != None else 0

    # "24 W.BYRON   +0.29" -- car# initial.LASTNAME, then the gap. Playoff
    # status shows on the position badge above instead of a name suffix. No
    # "#" before the car number: that glyph is silently missing from 5x7
    # (confirmed with measure_text).
    #
    # The name is fit_text'd on its OWN, separate from the "num " prefix:
    # fit_text only ever cuts whole words at a space, and "W.BYRON" has none,
    # so if it were folded into one long string that didn't quite fit, the
    # entire name -- not just the tail of it -- would vanish (a real bug,
    # caught by an actual driver's name disappearing at panel-realistic
    # widths). Fitting the name alone still shrinks it letter by letter once
    # nothing else is left to cut.
    num_str = str(row["num"])
    if len(num_str) < 2:
        num_str = " " * (2 - len(num_str)) + num_str
    prefix = num_str + " "
    who = (row["initial"] + "." + row["name"]) if row["initial"] else row["name"]

    gap = row["gap"]
    gap_w = c.text_width(gap, gap_font) if gap != "" else 0
    reserve = (gap_w + 4) if gap_w > 0 else 0
    avail = (x1 - row_x0) - 6 - reserve - badge_reserve
    who_max_w = avail - c.text_width(prefix, font)
    who = fit_text(c, who, font, who_max_w) if who_max_w > 0 else ""
    main = prefix + who

    c.text(main, row_x0 + 3, cy, font = font, color = txt_color)

    if badge_kind == "tire":
        # Tire compound keeps its own black chip -- it needs to read as a
        # distinct status marker regardless of livery color, not blend into
        # the row like the manufacturer name does.
        badge_x0 = x1 - 3 - reserve - badge_w
        c.rect(badge_x0, y0, badge_x0 + badge_w - 1, y1, fill = "#000000")
        letter_h = 6
        c.text(badge_letter, badge_x0 + badge_w // 2, y0 + (box_h - letter_h) // 2, font = "4x5", color = badge_color, align = "center")
    elif badge_kind == "mfg":
        badge_x0 = x1 - 3 - reserve - badge_w
        c.text(badge_letter, badge_x0, gap_cy, font = gap_font, color = best_text_color(bg))

    if gap != "":
        c.text(gap, x1 - 3, gap_cy, font = gap_font, color = txt_color, align = "right")

def driver_grid_dims(avail_w, avail_h, target_col_w = 110, rows_per_col = 3):
    # Auto-fit as many "groups of three" (stacked columns) side by side as
    # comfortably fit, instead of always drawing exactly one column that
    # stretches the full available width regardless of how much room there is.
    num_cols = max(1, avail_w // target_col_w)
    col_gap = 2
    col_w = (avail_w - col_gap * (num_cols - 1)) // num_cols
    row_h = avail_h // rows_per_col
    return num_cols, col_w, row_h

def driver_group_capacity(c, col_x0, y0, y1):
    num_cols, _, _ = driver_grid_dims(c.width - col_x0, y1 - y0 + 1)
    return num_cols * 3

def draw_driver_group(c, rows, start, col_x0, y0, y1):
    avail_w = c.width - col_x0
    avail_h = y1 - y0 + 1
    num_cols, col_w, row_h = driver_grid_dims(avail_w, avail_h)
    # A 1px gap between rows when there's slack to spare -- otherwise
    # same-colored neighbors (two similarly-yellow sponsor liveries, say)
    # blend into one block. Only when row_h leaves room: the header-on case
    # is already an exact fit for 4x5 with nothing to give up.
    row_gap = 1 if row_h > 6 else 0
    idx = start
    for col in range(num_cols):
        cx0 = col_x0 + col * (col_w + 2)
        cx1 = cx0 + col_w - 1
        for row_i in range(3):
            if idx >= len(rows):
                return
            row = rows[idx]
            idx += 1
            ry0 = y0 + row_i * row_h
            ry1 = ry0 + row_h - 1 - row_gap
            draw_driver_row_block(c, cx0, cx1, ry0, ry1, row)

# ---------- temporary preview harness (mock live data; see PR notes) ----------
# Lets `render_app` show live-session layouts (race, qualifying, next-race
# card) without a real session in progress, via _debugsession ("race" default,
# "quali", or "upcoming") plus _debuggroup to pick the frame. Neither is a
# real input -- no manifest entry, so both are inert once shipped. Remove
# once live rendering has been checked against an actual in-progress race.

def _mock_row(pos, num, initial, name, delta, status, on_track, laps, mfg, chase):
    return {"pos": pos, "num": num, "initial": initial, "name": name, "delta": delta,
            "status": status, "on_track": on_track, "laps": laps, "mfg": mfg, "chase": chase}

def _mock_rows(deltas, statuses, on_tracks, laps, live_race):
    specs = [
        (1, "24", "W", "BYRON", "Chv", False),
        (2, "5", "K", "LARSON", "Chv", False),
        (3, "9", "C", "ELLIOTT", "Chv", True),
        (4, "11", "D", "HAMLIN", "Tyt", False),
        (5, "19", "C", "BRISCOE", "Tyt", False),
        (6, "22", "J", "LOGANO", "Frd", True),
        (7, "1", "R", "CHASTAIN", "Chv", False),
        (8, "45", "T", "REDDICK", "Tyt", False),
        (9, "6", "B", "KESELOWSKI", "Frd", False),
    ]
    rows = [
        _mock_row(pos, num, initial, name, deltas[i], statuses[i], on_tracks[i], laps[i], mfg, chase)
        for i, (pos, num, initial, name, mfg, chase) in enumerate(specs)
    ]
    mark_duplicate_names(rows)
    leader_laps = rows[0]["laps"]
    for row in rows:
        gap, _ = gap_text(row, leader_laps, live_race)
        row["gap"] = gap
        bg, txt_color = driver_colors(row["num"], row["mfg"], "NASCAR")
        row["bg"] = bg
        row["txt_color"] = txt_color
        pos_bg, pos_txt = pos_badge_colors("NASCAR", row["chase"])
        row["pos_bg"] = pos_bg
        row["pos_txt"] = pos_txt
    return rows

def _mock_state(session_mode = "race"):
    if session_mode == "upcoming":
        return {
            "ok": True, "live": False, "series": "NASCAR",
            "race_name": "COCA-COLA 600", "track_name": "CHARLOTTE",
            "track_key": "CHARLOTTE MOTOR SPEEDWAY", "race_date": "2026-08-16T19:00:00",
        }

    if session_mode == "quali":
        deltas = [0, 0.052, 0.184, 0.201, 0.310, 0.412, 0.498, 0.687, 0.734]
        statuses = [1, 1, 1, 1, 1, 1, 1, 1, 1]
        on_tracks = [True] * 9
        laps = [1] * 9
        rows = _mock_rows(deltas, statuses, on_tracks, laps, False)
        return {
            "ok": True, "live": True, "series": "NASCAR",
            "race_name": "BRICKYARD 400", "session": "QUALIFYING", "track_name": "INDIANAPOLIS",
            "track_key": "INDIANAPOLIS MOTOR SPEEDWAY",
            "flag": 9, "lap": 0, "laps_total": 0, "stage_num": 0, "rows": rows,
        }

    deltas = [0, 0.287, 5.72, 0, 9.8, 12.4, 0, 0, 0]
    statuses = [1, 1, 1, 2, 1, 1, 3, 1, 1]
    on_tracks = [True, True, True, True, True, True, False, True, False]
    laps = [160, 160, 160, 160, 160, 160, 140, 158, 155]
    rows = _mock_rows(deltas, statuses, on_tracks, laps, True)
    return {
        "ok": True, "live": True, "series": "NASCAR",
        "race_name": "BRICKYARD 400", "session": "RACE", "track_name": "INDIANAPOLIS",
        "track_key": "INDIANAPOLIS MOTOR SPEEDWAY",
        "flag": 1, "lap": 100, "laps_total": 160, "stage_num": 3, "rows": rows,
    }

def live(c, ctx):
    series = safe_input(ctx, "series", "NASCAR")
    debug_group = safe_input(ctx, "_debuggroup", "")
    debug_session = safe_input(ctx, "_debugsession", "race")
    group_idx = int(debug_group) if debug_group != "" else None

    if series == "Formula 1":
        # No mock harness for F1 (debug_group is ignored here for fetching --
        # OpenF1 was exercised directly against real live/recent session
        # data instead -- but it still picks which of the 2 off-season
        # frames shows, same as the live path below).
        state = fetch_f1_live(ctx)
        if state == None:
            next_state = fetch_f1_next(ctx)
            if not next_state["ok"]:
                draw_error(c, next_state["title"], next_state["sub"])
                return
            off_idx = group_idx if group_idx != None else (ctx.now.unix // 60) % 2
            if off_idx == 0:
                draw_series_logo_frame(c, "Formula 1")
            else:
                draw_offseason_f1_event(c, next_state, ctx)
            return
    else:
        state = _mock_state(debug_session) if debug_group != "" else fetch_state(ctx)
        if not state["ok"]:
            draw_error(c, state["title"], state["sub"])
            return
        if not state["live"]:
            off_idx = group_idx if group_idx != None else (ctx.now.unix // 60) % 2
            if off_idx == 0:
                draw_series_logo_frame(c, state["series"])
            else:
                draw_offseason_event(c, state, ctx)
            return

    # From here on, NASCAR and F1 share the same layout: logo alone for
    # frame 0 (draw_series_logo_frame), race details (name/track/session,
    # track shape, flag/lap/stage-or-weather) for frame 1 (draw_live_details),
    # then full-width auto-fit driver columns for every frame after, cycling
    # the whole field in as few frames as fit allows.
    rows = state["rows"]
    if len(rows) == 0:
        draw_live_details(c, state, ctx)
        return

    cap1 = driver_group_capacity(c, 0, 3, 31)
    total_frames = 2
    if cap1 > 0:
        total_frames = 2 + (len(rows) + cap1 - 1) // cap1

    if group_idx == None:
        group_idx = (ctx.now.unix // 60) % total_frames

    if group_idx == 0:
        draw_series_logo_frame(c, state["series"])
    elif group_idx == 1:
        draw_live_details(c, state, ctx)
    else:
        c.fill(COLORS["bg"])
        draw_flag_bar(c, state["flag"])
        start = (group_idx - 2) * cap1
        draw_driver_group(c, rows, start, 0, 3, 31)

