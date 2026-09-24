# F1 - Broadcast Live (192x32).
#
# DESIGN. A broadcast timing graphic on a black ground. The F1 mark shares a
# page with the grand prix it announces, so the app identifies itself without
# spending a whole page on a logo. Every other page is a board: position,
# livery-coloured driver, gap, tyre. All pages keep EDGE (4 px) clear on both
# sides so the boards don't merge into the apps before and after this one in
# the scroll stream.
#
# A real page rotation (the panel requests one render per page, in manifest
# order -- no single page faking frames off the wall clock). Two rotations off
# one fixed 4-page manifest. Field is 22 cars (11 teams x 2 since the 2026
# grid expansion). The order board holds 8/page on a 192 panel, 9/page on
# 384/640:
#
#   BETWEEN SESSIONS                LIVE SESSION
#   1 event  F1 mark + next race    1 event  F1 mark + LIVE, flag/lap/temp
#   2 last race  P1-8 / P1-12       2 order  P1-8 / P1-9
#   3 last race  P9-16 / P13-22     3 order  P9-16 / P10-18
#   4 calendar                      4 order  P17-22 / P19-22
#
# On a 192 panel, order1-2's last-race pages cover P1-16 only -- P17-22 don't
# have a between-sessions slot (order3 is needed for the calendar instead of
# a third last-race page). On 384/640, order1-2 already covers the full
# 22-car field (12+12), so nothing is missed there.
#
# Data: OpenF1 (api.openf1.org) for live timing, weather and stints -- free, no
# key; no "current session" endpoint, so the app checks the latest session is
# actually inside its live window (plus a post-session grace). Jolpica-Ergast
# (api.jolpi.ca) for the calendar and the last result.

# OpenF1's race_control feed reports flag state as text, not a numeric code.
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

# OpenF1's weather feed only exposes a binary rainfall flag -- DRY/RAIN are the
# only two conditions it can actually back up.
WEATHER_COLOR = {
    "DRY": "#FACC15",
    "RAIN": "#38BDF8",
}

# Current tyre compound: a small black chip with the compound letter in its
# real broadcast color, legible regardless of the row's livery color.
TIRE_BADGE = {
    "SOFT": ("S", "#E32227"),
    "MEDIUM": ("M", "#FFD700"),
    "HARD": ("H", "#FFFFFF"),
    "INTERMEDIATE": ("I", "#22C55E"),
    "WET": ("W", "#2563EB"),
}

# Team livery hex, keyed by Jolpica/Ergast constructorId. Live rows get their
# colour straight from OpenF1's team_colour field; the between-sessions LAST
# RACE board has no OpenF1 data, so it maps the Jolpica constructorId here to
# put each driver's name in the team colour. Same values the mock board uses.
F1_TEAM_COLOR = {
    "red_bull": "#1E5BC6",
    "mclaren": "#FF8000",
    "ferrari": "#DC0000",
    "mercedes": "#00D2BE",
    "aston_martin": "#006F62",
    "alpine": "#0090FF",
    "williams": "#005AFF",
    "rb": "#2647D8",
    "racing_bulls": "#2647D8",
    "alphatauri": "#2647D8",
    "sauber": "#C00000",
    "kick_sauber": "#C00000",
    "audi": "#C00000",
    "haas": "#B6BABD",
    "cadillac": "#C8102E",
}

def team_color(constructor_id, fallback):
    return F1_TEAM_COLOR.get(str(constructor_id).lower().strip(), fallback)

# Name/gap text on the live and post-session livery rows. Keyed by a
# lowercase substring of OpenF1's team_name (or the mock's team id).
# Mercedes' teal sat right on the black/white cutoff and came out white;
# Alpine gets its BWT pink on the blue, like the car. Everyone else keeps
# the usual black-or-white-by-brightness pick.
F1_TEAM_TEXT = {
    "mercedes": "#000000",
    "alpine": "#FF87BC",
}

def row_text_color(team_name, bg):
    t = str(team_name).lower()
    for k, v in F1_TEAM_TEXT.items():
        if k in t:
            return v
    return best_text_color(bg)

MONTHS_FULL = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY",
               "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]

COLORS = {
    "bg": "#07090D",
    "panel": "#141A22",
    "line": "#2A3544",
    "text": "#F4F7FB",
    "muted": "#8B9BB0",
    "accent": "#E10600",
    "accent2": "#FFD166",
    "error": "#FF5D73",
}

GOLD = "#FFD700"

# Clear columns at the left and right edge of every page.
EDGE = 4

# F1 mark on the event page: 44x12 keeps the 90:24 artwork's ratio and is as
# wide as the NEXT RACE tag under it (41 px in 4x5).
LOGO_W, LOGO_H = 44, 12

# `datecolor` dropdown -> hex; default yellow. "accent" is the app's amber.
# Yellow is pure #FFFF00 rather than the palette's #FFDC50, which is too
# close to the amber accent to tell apart on the panel.
DATE_COLORS = {
    "accent": "#FFD166",
    "red": "#FF0000",
    "green": "#00DC46",
    "blue": "#005AFF",
    "white": "#FFFFFF",
    "yellow": "#FFFF00",
    "magenta": "#FF00C8",
    "cyan": "#00DCDC",
}

# Bitmap fonts have no accented glyphs and skip them silently -- "Hülkenberg"
# drew as HLKENBERG. Fold to plain ASCII after upper-casing.
ASCII_FOLD = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O", "Ø": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
    "Ç": "C", "Ñ": "N",
}

# The narrow event page runs circuit + session on one 92 px row.
SESSION_SHORT = {"QUALIFYING": "QUALI"}

# Lit glyph height per font, measured off the rendered previews. Rows that mix
# fonts share a bottom edge: draw each at top_for(font, row_bottom).
FONT_H = {"6x8": 8, "5x7": 7, "4x5": 5, "picopixel": 5}

def top_for(font, bottom):
    return bottom - FONT_H[font] + 1

# Broadcast abbreviations for flag states that outgrow their slot. A plain
# word-cut would turn VIRTUAL SAFETY CAR into "VIRTUAL SAFETY" -- a different
# state -- so these swap in whole instead.
FLAG_SHORT = {
    "VIRTUAL SAFETY CAR": "VSC",
    "SAFETY CAR": "SC",
    "DOUBLE YELLOW": "DBL YELLOW",
}

# How long past a session's scheduled end fetch_f1_live still treats it as
# "just finished" rather than falling back to the between-sessions cards.
F1_GRACE_SECONDS = 6 * 3600

# circuit_id / circuit_short_name -> (asset, native width, native height).
# Each asset is pre-sized in Python so it is drawn at its own dimensions, not
# stretched into a fixed box.
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

# circuit_short_name (from OpenF1 sessions) -> circuit_id (Jolpica/asset key).
CIRCUIT_ALIAS = {
    "melbourne": "albert_park",
    "sakhir": "bahrain",
    "jeddah": "jeddah",
    "shanghai": "shanghai",
    "suzuka": "suzuka",
    "miami": "miami",
    "imola": "imola",
    "monte carlo": "monaco",
    "monaco": "monaco",
    "catalunya": "catalunya",
    "barcelona": "catalunya",
    "montreal": "villeneuve",
    "spielberg": "red_bull_ring",
    "silverstone": "silverstone",
    "spa-francorchamps": "spa",
    "spa": "spa",
    "budapest": "hungaroring",
    "hungaroring": "hungaroring",
    "zandvoort": "zandvoort",
    "monza": "monza",
    "baku": "baku",
    "singapore": "marina_bay",
    "marina bay": "marina_bay",
    "austin": "americas",
    "mexico city": "rodriguez",
    "interlagos": "interlagos",
    "sao paulo": "interlagos",
    "las vegas": "las_vegas",
    "lusail": "losail",
    "losail": "losail",
    "yas marina": "yas_marina",
    "abu dhabi": "yas_marina",
}

SHAPE_POINTS = {
    "roadcourse": [(0.1, 0.1), (0.4, 0.0), (0.6, 0.2), (0.5, 0.4), (0.9, 0.3), (1.0, 0.6), (0.7, 0.9), (0.4, 0.7), (0.2, 1.0), (0.0, 0.6)],
}

# ---------- small helpers ----------

def safe_input(ctx, key, fallback):
    value = ctx.inputs.get(key, fallback)
    if value == None or value == "":
        return fallback
    return value

# Every API string goes through here before it's drawn. Prefer ending on a
# whole word ("MIAMI INTERNATIONAL" from "... AUTODROME") unless that throws
# away more than ~30% of the characters; otherwise cut mid-word and end on
# ".." so the cut reads as deliberate. "" only when not even ".." fits.
def fit_text(c, text, font, max_w):
    if text == "" or c.text_width(text, font) <= max_w:
        return text
    words = text.split(" ")
    for i in range(len(words) - 1, 0, -1):
        cand = " ".join(words[:i])
        if c.text_width(cand, font) <= max_w:
            if len(cand) * 10 >= len(text) * 7:
                return cand
            break
    for n in range(len(text) - 1, 0, -1):
        cand = text[:n].rstrip(" -") + ".."
        if c.text_width(cand, font) <= max_w:
            return cand
    return ""

# Largest font first; within a font, the fullest wording that fits. Past the
# last font, hard-clip the shortest wording.
def fit_ladder(c, variants, fonts, max_w):
    for f in fonts:
        for v in variants:
            if c.text_width(v, f) <= max_w:
                return v, f
    f = fonts[len(fonts) - 1]
    return fit_text(c, variants[len(variants) - 1], f, max_w), f

# "SAUDI ARABIAN GRAND PRIX" -> "SAUDI ARABIAN GP" -> "SAUDI ARABIAN"; a
# hyphenated name also tries its first half (BARCELONA-CATALUNYA -> BARCELONA).
def race_variants(name):
    out = [name]
    if name.endswith(" GRAND PRIX"):
        base = name[:len(name) - len(" GRAND PRIX")]
        out.append(base + " GP")
        out.append(base)
        if "-" in base:
            out.append(base.split("-")[0])
    return out

def up(s):
    t = str(s).upper()
    for k, v in ASCII_FOLD.items():
        t = t.replace(k, v)
    return t

def pick_date_color(ctx):
    v = str(safe_input(ctx, "datecolor", "yellow")).strip().lower()
    return DATE_COLORS.get(v, DATE_COLORS["yellow"])

def yiq_of(hex_color):
    h = hex_color.lstrip("#")
    if len(h) < 6:
        return 128
    r = int(h[0:2], 16)
    g = int(h[2:4], 16)
    b = int(h[4:6], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def best_text_color(hex_color):
    return "#111111" if yiq_of(hex_color) >= 150 else "#FFFFFF"

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

def clean_name(raw):
    return str(raw).strip().upper()

def short_circuit(name):
    t = str(name).upper()
    for pre in ("AUTODROMO NAZIONALE DI ", "AUTODROMO INTERNAZIONALE ",
                "AUTODROMO INTERNACIONAL ", "AUTODROMO ",
                "CIRCUIT DE BARCELONA-", "CIRCUIT DE ", "CIRCUIT PARK ",
                "CIRCUIT OF THE ", "CIRCUIT GILLES ", "CIRCUIT "):
        if t.startswith(pre):
            t = t[len(pre):]
    for suf in (" INTERNATIONAL CIRCUIT", " STREET CIRCUIT", " CITY CIRCUIT",
                " GRAND PRIX CIRCUIT", " RACE CIRCUIT", " CIRCUIT",
                " INTERNATIONAL AUTODROME", " AUTODROME"):
        if t.endswith(suf):
            t = t[:-len(suf)]
    # No character cap here -- the drawing side measures and truncates to the
    # pixels it actually has.
    return t.strip()

def mark_duplicate_names(rows):
    counts = {}
    for row in rows:
        n = row["name"]
        counts[n] = counts.get(n, 0) + 1
    for row in rows:
        if counts.get(row["name"], 0) <= 1:
            row["initial"] = ""
    return rows

# ---------- time ----------

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
    h = int(text[11:13]) if len(text) >= 16 else 0
    mi = int(text[14:16]) if len(text) >= 16 else 0
    return y, mo, d, h, mi

def offset_seconds_for_zone(tz_name):
    r = http.get("https://timeapi.io/api/TimeZone/zone",
                 params = {"timeZone": tz_name}, ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    return r["json"].get("currentUtcOffset", {}).get("seconds", None)

def panel_offset_seconds(ctx):
    tz_name = safe_input(ctx, "timezone", "Europe/London")
    off = offset_seconds_for_zone(tz_name)
    return off if off != None else 0

def _pad2(n):
    return ("0" + str(n)) if n < 10 else str(n)

def format_iso_utc(unix_ts):
    days = unix_ts // 86400
    secs_of_day = unix_ts % 86400
    y, mo, d = _civil_from_days(days)
    hh = secs_of_day // 3600
    mm = (secs_of_day % 3600) // 60
    ss = secs_of_day % 60
    return str(y) + "-" + _pad2(mo) + "-" + _pad2(d) + "T" + _pad2(hh) + ":" + _pad2(mm) + ":" + _pad2(ss)

def format_ampm(lh, lm):
    ampm = "AM" if lh < 12 else "PM"
    h12 = lh % 12
    if h12 == 0:
        h12 = 12
    mm_txt = "0" + str(lm) if lm < 10 else str(lm)
    return str(h12) + ":" + mm_txt + ampm

def local_dt(ctx, date_str, time_str):
    # F1's schedule gives true UTC (date + "HH:MM:SSZ").
    if date_str == "":
        return "TBD"
    t = time_str if time_str != "" else "00:00:00Z"
    y, mo, d, h, mi = parse_iso(date_str + "T" + t)
    utc_unix = _days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60
    local_unix = utc_unix + panel_offset_seconds(ctx)
    ly, lmo, ld = _civil_from_days(local_unix // 86400)
    secs_of_day = local_unix % 86400
    lh = secs_of_day // 3600
    lm = (secs_of_day % 3600) // 60
    return MONTHS_FULL[lmo - 1][:3] + " " + str(ld) + ordinal_suffix(ld) + " " + format_ampm(lh, lm)

def local_daydate(ctx, date_str, time_str):
    if date_str == "":
        return "TBD"
    t = time_str if time_str != "" else "00:00:00Z"
    y, mo, d, h, mi = parse_iso(date_str + "T" + t)
    utc_unix = _days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60
    local_unix = utc_unix + panel_offset_seconds(ctx)
    ly, lmo, ld = _civil_from_days(local_unix // 86400)
    return MONTHS_FULL[lmo - 1][:3] + " " + str(ld)

def _today_days(ctx):
    return ctx.now.unix // 86400

# ---------- track drawing ----------

def draw_track_shape(c, shape, x, y, w, h, color):
    pts = SHAPE_POINTS.get(shape, SHAPE_POINTS["roadcourse"])
    n = len(pts)
    scaled = []
    for i in range(n):
        px, py = pts[i]
        scaled.append((x + int(px * w), y + int(py * h)))
    for i in range(n):
        a = scaled[i]
        b = scaled[(i + 1) % n]
        c.line(a[0], a[1], b[0], b[1], color)

def track_asset_dims(circuit_id):
    entry = F1_TRACK_ASSET.get(str(circuit_id))
    if entry == None:
        return "", FALLBACK_TRACK_W, FALLBACK_TRACK_H
    return entry

def circuit_key_from_short(short_name):
    s = str(short_name).lower().strip()
    if s in CIRCUIT_ALIAS:
        return CIRCUIT_ALIAS[s]
    return s.replace(" ", "_").replace("-", "_")

def draw_f1_track(c, asset, x, y, w, h):
    if asset != "":
        c.image(asset, x, y, w = w, h = h)
    else:
        draw_track_shape(c, "roadcourse", x, y, w, h, COLORS["muted"])

def cap_track_dims(native_w, native_h, max_w, max_h):
    w, h = float(max_w), float(max_w) * float(native_h) / float(native_w)
    if h > max_h:
        h = float(max_h)
        w = float(max_h) * float(native_w) / float(native_h)
    return max(1, int(w + 0.5)), max(1, int(h + 0.5))

def f1_logo_dims(max_w, max_h):
    ratio = 90.0 / 24.0
    w, h = float(max_w), float(max_w) / ratio
    if h > max_h:
        h = float(max_h)
        w = float(max_h) * ratio
    return max(1, int(w + 0.5)), max(1, int(h + 0.5))

# ---------- gaps ----------

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

def latest_by_driver(entries):
    latest = {}
    for e in entries:
        dn = e.get("driver_number")
        if dn == None:
            continue
        latest[dn] = e
    return latest

def _last_scalar(v):
    # Qualifying's session_result carries gap_to_leader/duration as a
    # [Q1, Q2, Q3] array (nulls past a driver's last segment); Practice and
    # Race hand back a plain number. Either way, the last non-null entry is
    # the value for a driver's most advanced segment.
    if v == None:
        return None
    if type(v) == "list":
        for i in range(len(v) - 1, -1, -1):
            if v[i] != None:
                return v[i]
        return None
    return v

def _f1_row(dn, driver, pos, gap_str, stints):
    last_name = up(driver.get("last_name", ""))
    first_name = str(driver.get("first_name", ""))
    team_colour = str(driver.get("team_colour", ""))
    bg = ("#" + team_colour) if team_colour != "" else "#222222"
    compound = str(stints.get(dn, {}).get("compound", "")).upper()
    nm = last_name if last_name != "" else ("#" + str(dn))
    acr = str(driver.get("name_acronym", "")).upper()
    return {
        "pos": pos,
        "num": str(dn),
        "initial": first_name[0].upper() if first_name else "",
        "name": nm,
        "acr": acr if acr != "" else nm[:3],
        "gap": gap_str,
        "bg": bg,
        "txt_color": row_text_color(driver.get("team_name", ""), bg),
        "pos_bg": "#000000",
        "pos_txt": "#FFFFFF",
        "compound": compound,
    }

# ---------- live state (OpenF1) ----------

def fetch_f1_live(ctx):
    sresp = http_json("https://api.openf1.org/v1/sessions?session_key=latest", 30)
    if not sresp["ok"] or len(sresp["data"]) == 0:
        return None
    session = sresp["data"][0]

    sy, smo, sd, sh, smi = parse_iso(session.get("date_start", ""))
    ey, emo, ed, eh, emi = parse_iso(session.get("date_end", ""))
    start_unix = _days_from_civil(sy, smo, sd) * 86400 + sh * 3600 + smi * 60
    end_unix = _days_from_civil(ey, emo, ed) * 86400 + eh * 3600 + emi * 60
    now_unix = ctx.now.unix
    # A per-viewer local-midnight grace (like NASCAR's) needs a timezone
    # lookup, and fetch_f1_live already spends its full 8-call http budget on
    # OpenF1 data alone -- one more call over the limit fails validation. A
    # flat post-session window approximates "still today" without the call.
    if now_unix < start_unix or now_unix > end_unix + F1_GRACE_SECONDS:
        return None

    session_key = session.get("session_key")
    session_type = str(session.get("session_type", "Race")).upper()
    circuit_short = str(session.get("circuit_short_name", ""))

    race_name = "GRAND PRIX"
    mresp = http_json("https://api.openf1.org/v1/meetings", 3600, params = {"meeting_key": str(session.get("meeting_key", ""))})
    if mresp["ok"] and len(mresp["data"]) > 0:
        race_name = up(mresp["data"][0].get("meeting_name", "GRAND PRIX"))

    temp_txt = ""
    unit = safe_input(ctx, "tempunit", "C")
    weather_cond = "DRY"
    wresp = http_json("https://api.openf1.org/v1/weather", 60, params = {"session_key": str(session_key)})
    if wresp["ok"] and len(wresp["data"]) > 0:
        w = wresp["data"][len(wresp["data"]) - 1]
        air_temp = w.get("air_temperature")
        if air_temp != None:
            rain = w.get("rainfall", 0)
            weather_cond = "RAIN" if rain and rain > 0 else "DRY"
            temp_val = float(air_temp)
            if unit == "F":
                temp_val = temp_val * 9.0 / 5.0 + 32.0
            temp_txt = str(int(temp_val))

    drivers = {}
    dresp = http_json("https://api.openf1.org/v1/drivers", 300, params = {"session_key": str(session_key)})
    if dresp["ok"]:
        for d in dresp["data"]:
            dn = d.get("driver_number")
            if dn != None:
                drivers[dn] = d

    tresp = http_json("https://api.openf1.org/v1/stints?session_key=" + str(session_key), 60)
    stints = latest_by_driver(tresp["data"]) if tresp["ok"] else {}

    flag_str = "GREEN"
    lap_num = 0
    rcresp = http_json("https://api.openf1.org/v1/race_control?session_key=" + str(session_key), 20)
    if rcresp["ok"]:
        for e in rcresp["data"]:
            ln = e.get("lap_number")
            if ln != None:
                lap_num = int(ln)
            if e.get("category") == "Flag" and e.get("scope") == "Track" and e.get("flag") != None:
                flag_str = str(e.get("flag")).upper()

    is_race = session_type == "RACE"
    # Once the chequered flag falls, OpenF1 stops emitting new /position and
    # /intervals entries -- cars parked in the garage don't change track
    # position. The recency filter below (last 150s) then matches nothing for
    # the rest of the post-session grace window, leaving the board blank. Fall
    # back to /session_result -- the same stable final-classification endpoint
    # Practice/Qualifying already use -- once the session's scheduled end has
    # passed.
    session_over = now_unix > end_unix
    num2name = {}
    rows = []

    if is_race and not session_over:
        # Race: /position is the real running order and /intervals is the real
        # gap to the leader -- both are meaningful mid-race.
        cutoff = format_iso_utc(now_unix - 150)
        presp = http_json("https://api.openf1.org/v1/position?session_key=" + str(session_key) + "&date%3E" + cutoff, 15)
        positions = latest_by_driver(presp["data"]) if presp["ok"] else {}
        iresp = http_json("https://api.openf1.org/v1/intervals?session_key=" + str(session_key) + "&date%3E" + cutoff, 15)
        intervals = latest_by_driver(iresp["data"]) if iresp["ok"] else {}

        for dn, pos_entry in positions.items():
            interval_entry = intervals.get(dn, {})
            gap_raw = interval_entry.get("gap_to_leader")
            gap_str = ""
            if gap_raw != None:
                # OpenF1 hands back a number of seconds for cars on the lead
                # lap and a string ("+1 LAP" / "+2 LAPS") for lapped cars --
                # pass the string straight through so the board shows laps
                # down, not a time.
                gap_str = str(gap_raw).upper().strip() if type(gap_raw) == "string" else format_gap_time(gap_raw)
            row = _f1_row(dn, drivers.get(dn, {}), int(pos_entry.get("position", 0)), gap_str, stints)
            num2name[str(dn)] = row["name"]
            rows.append(row)
    else:
        # Practice/Qualifying (still running): /position is raw track order,
        # not a real classification -- it can put a driver through five
        # positions in fifteen minutes as cars cycle through out-laps and
        # in-laps. What "standings" mean here is the best-lap-time ranking,
        # which is what session_result carries (and it updates live, mid-
        # session, too). A finished Race (session_over, still within the
        # post-session grace) lands here too, since its /position feed has
        # gone stale -- session_result is also the final classification.
        # Qualifying's gap_to_leader/duration come back as a [Q1, Q2, Q3]
        # array; the last non-null entry is a driver's most advanced segment.
        # A finished Race's gap_to_leader is a plain number for lead-lap
        # finishers but a string ("+1 LAP" / "+2 LAPS") for lapped ones.
        rresp = http_json("https://api.openf1.org/v1/session_result?session_key=" + str(session_key), 15)
        last_pos = 0
        for res in (rresp["data"] if rresp["ok"] else []):
            dn = res.get("driver_number")
            if dn == None:
                continue
            if res.get("dnf"):
                gap_str = "DNF"
            elif res.get("dsq"):
                gap_str = "DSQ"
            elif res.get("dns"):
                gap_str = "DNS"
            else:
                gap_raw = _last_scalar(res.get("gap_to_leader"))
                if gap_raw == None:
                    gap_str = ""
                elif type(gap_raw) == "string":
                    gap_str = gap_raw.upper().strip()
                else:
                    gap_str = format_gap_time(gap_raw)
            # A retired driver's session_result position is null (OpenF1
            # only ranks classified finishers) -- session_result still lists
            # them in classification order after the numbered rows, so keep
            # counting on from the last real position seen.
            pos_raw = res.get("position")
            last_pos = int(pos_raw) if pos_raw != None else last_pos + 1
            row = _f1_row(dn, drivers.get(dn, {}), last_pos, gap_str, stints)
            num2name[str(dn)] = row["name"]
            rows.append(row)

    mark_duplicate_names(rows)
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            if rows[j]["pos"] > rows[j + 1]["pos"]:
                tmp = rows[j]
                rows[j] = rows[j + 1]
                rows[j + 1] = tmp

    return {
        "mode": "live",
        "session": session_type,
        "is_race": is_race,
        "race_name": race_name,
        "track_name": up(circuit_short),
        "track_key": circuit_key_from_short(circuit_short),
        "flag": flag_str,
        "lap": lap_num,
        "temp": temp_txt,
        "temp_unit": unit,
        "weather_cond": weather_cond,
        "rows": rows,
        "session_key": str(session_key),
        "num2name": num2name,
    }

# ---------- schedule / last result (Jolpica) ----------

def fetch_f1_next(ctx):
    resp = http_json("https://api.jolpi.ca/ergast/f1/current/next.json", 1800)
    if not resp["ok"]:
        return {"ok": False, "title": "F1 SCHEDULE ERROR", "sub": "HTTP " + str(resp["status"])}
    races = resp["data"].get("MRData", {}).get("RaceTable", {}).get("Races", [])
    if len(races) == 0:
        return {"ok": False, "title": "NO RACE", "sub": "SEASON COMPLETE"}
    race = races[0]
    circuit = race.get("Circuit", {})
    return {
        "ok": True,
        "race_name": up(race.get("raceName", "GRAND PRIX")),
        "track_name": up(circuit.get("circuitName", "")),
        "circuit_id": str(circuit.get("circuitId", "")),
        "race_date": str(race.get("date", "")),
        "race_time": str(race.get("time", "")),
    }


def fetch_f1_last(ctx):
    resp = http_json("https://api.jolpi.ca/ergast/f1/current/last/results.json", 3600)
    if not resp["ok"]:
        return None
    races = resp["data"].get("MRData", {}).get("RaceTable", {}).get("Races", [])
    if len(races) == 0:
        return None
    race = races[0]
    results = race.get("Results", [])
    leader_laps = int(results[0].get("laps", 0)) if len(results) > 0 else 0
    top = []
    for x in results:  # order1/order2 page through this, capped at 16 there
        drv = x.get("Driver", {})
        pos = str(x.get("position", ""))
        t = str(x.get("Time", {}).get("time", ""))
        status = str(x.get("status", ""))
        if pos == "1":
            gap = ""                      # the winner's full race time doesn't fit the 2-col board
        elif "Lap" in status:             # Jolpica: "Lapped" (or classic "+1 Lap")
            down = leader_laps - int(x.get("laps", leader_laps))
            gap = ("+" + str(down) + (" LAP" if down == 1 else " LAPS")) if down > 0 else "LAPPED"
        elif status != "Finished" and status != "":
            gap = "DNF"
        elif t != "":
            gap = t                       # others: "+11.536"
        else:
            gap = ""
        tcol = team_color(x.get("Constructor", {}).get("constructorId", ""), COLORS["text"])
        top.append((pos, up(drv.get("familyName", "")), gap, tcol))
    return {
        "race_name": up(race.get("raceName", "GRAND PRIX")),
        "circuit": up(race.get("Circuit", {}).get("circuitName", "")),
        "top": top,
    }

# ---------- calendar (Jolpica) ----------

def fetch_f1_upcoming(ctx):
    # Not-yet-run rounds this season. current.json is one keyless call, cached
    # an hour.
    resp = http_json("https://api.jolpi.ca/ergast/f1/current.json", 3600)
    if not resp["ok"]:
        return []
    races = resp["data"].get("MRData", {}).get("RaceTable", {}).get("Races", [])
    today = _today_days(ctx)
    upcoming = []
    for r in races:
        ds = str(r.get("date", ""))
        if ds == "":
            continue
        y, mo, d, _, _ = parse_iso(ds + "T00:00")
        if _days_from_civil(y, mo, d) >= today:
            upcoming.append(r)
    return upcoming

# ---------- top-level state ----------

def _mock_live(ctx, mode):
    TEAMS = [
        ("1", "M", "VERSTAPPEN", "#1E5BC6", "red bull"),
        ("4", "L", "NORRIS", "#FF8000", "mclaren"),
        ("81", "O", "PIASTRI", "#FF8000", "mclaren"),
        ("16", "C", "LECLERC", "#DC0000", "ferrari"),
        ("44", "L", "HAMILTON", "#DC0000", "ferrari"),
        ("63", "G", "RUSSELL", "#00D2BE", "mercedes"),
        ("12", "A", "ANTONELLI", "#00D2BE", "mercedes"),
        ("22", "Y", "TSUNODA", "#1E5BC6", "red bull"),
        ("14", "F", "ALONSO", "#006F62", "aston martin"),
        ("18", "L", "STROLL", "#006F62", "aston martin"),
        ("10", "P", "GASLY", "#0090FF", "alpine"),
        ("7", "J", "DOOHAN", "#0090FF", "alpine"),
        ("23", "A", "ALBON", "#005AFF", "williams"),
        ("55", "C", "SAINZ", "#005AFF", "williams"),
        ("27", "N", "HULKENBERG", "#C00000", "sauber"),
        ("5", "G", "BORTOLETO", "#C00000", "sauber"),
        ("30", "L", "LAWSON", "#2647D8", "racing bulls"),
        ("6", "I", "HADJAR", "#2647D8", "racing bulls"),
        ("87", "O", "BEARMAN", "#B6BABD", "haas"),
        ("31", "E", "OCON", "#B6BABD", "haas"),
        ("2", "S", "PEREZ", "#C8102E", "cadillac"),
        ("77", "V", "BOTTAS", "#C8102E", "cadillac"),
    ]
    comps = ["SOFT", "MEDIUM", "HARD", "MEDIUM", "SOFT"]
    rows = []
    for i in range(len(TEAMS)):
        num, ini, name, col, team = TEAMS[i]
        if i == 0:
            gap = ""
        elif i >= 20:
            gap = "+2 LAPS"
        elif i >= 18:
            gap = "+1 LAP"
        else:
            gap = format_gap_time(0.3 + i * 1.7)
        rows.append({
            "pos": i + 1, "num": num, "initial": ini, "name": name,
            "acr": name[:3],
            "gap": gap if mode == "race" else format_gap_time(0.05 + i * 0.12),
            "bg": col, "txt_color": row_text_color(team, col),
            "pos_bg": "#000000", "pos_txt": "#FFFFFF",
            "compound": comps[i % len(comps)] if mode == "race" else "SOFT",
        })
    mark_duplicate_names(rows)
    is_race = mode == "race"
    # Air temp respects the tempunit dropdown, same as the live path.
    tc = 29 if is_race else 24
    unit = safe_input(ctx, "tempunit", "C")
    tv = int(tc * 9.0 / 5.0 + 32) if unit == "F" else tc
    return {
        "mode": "live", "session": "RACE" if is_race else "QUALIFYING",
        "is_race": is_race, "race_name": "SAO PAULO GRAND PRIX",
        "track_name": "INTERLAGOS", "track_key": "interlagos",
        "flag": "GREEN" if is_race else "CHEQUERED",
        "lap": 38 if is_race else 0,
        "temp": str(tv), "temp_unit": unit, "weather_cond": "DRY",
        "rows": rows, "session_key": "mock", "num2name": {},
    }

# `_debug` = "race" / "quali" returns a mock live state so the live boards can
# be rendered without a session in progress. Not a real manifest input, so it
# is inert once shipped. Remove once checked against an actual live session.
def get_state(ctx):
    dbg = safe_input(ctx, "_debug", "")
    if dbg == "race" or dbg == "quali":
        return _mock_live(ctx, "race" if dbg == "race" else "quali")
    live = fetch_f1_live(ctx)
    if live != None:
        return live
    nxt = fetch_f1_next(ctx)
    if not nxt["ok"]:
        return {"mode": "error", "title": nxt["title"], "sub": nxt["sub"]}
    return {
        "mode": "off",
        "race_name": nxt["race_name"],
        "track_name": short_circuit(nxt["track_name"]),
        "track_key": nxt["circuit_id"],
        "race_date": nxt["race_date"],
        "race_time": nxt["race_time"],
        "has_next": True,
    }

# ---------- drawing: chrome + rows ----------

def draw_error(c, title, sub):
    c.fill(COLORS["bg"])
    c.rect(EDGE, 0, c.width - 1 - EDGE, 9, fill = COLORS["panel"])
    c.image("checkered.png", EDGE + 2, 1, w = 10, h = 8)
    c.text("FORMULA 1", EDGE + 16, 2, font = "5x7", color = COLORS["accent"])
    maxw = c.width - 2 * EDGE
    c.text(fit_text(c, str(title).upper(), "6x8", maxw), EDGE, 14, font = "6x8", color = COLORS["error"])
    c.text(fit_text(c, str(sub).upper(), "4x5", maxw), EDGE, 24, font = "4x5", color = COLORS["muted"])

def draw_page_tab(c, label, color):
    w = c.text_width(label, "4x5") + 6
    c.rect(EDGE, 0, EDGE + w, 6, fill = color)
    c.text(label, EDGE + 3, 1, font = "4x5", color = best_text_color(color))

def draw_flag_bar(c, flag):
    x1 = c.width - 1 - EDGE
    if flag == "CHEQUERED":
        seg = 6
        for i in range((x1 - EDGE + seg) // seg):
            x = EDGE + i * seg
            c.rect(x, 0, min(x + seg - 1, x1), 1, fill = "#FFFFFF" if i % 2 == 0 else "#000000")
    else:
        c.rect(EDGE, 0, x1, 1, fill = F1_FLAG_COLOR.get(flag, COLORS["muted"]))

# 192 can't hold three driver rows across, so the board runs 2 columns x 4 rows
# there and 3 x 3 on 384/640. Either way a page holds 8-9 cars, so 3 order
# pages still cover the 22-car grid (11 teams x 2 cars).
def board_cols_rows(width):
    if width >= 320:
        return 3, 3
    return 2, 4

def board_capacity(width):
    cols, rows = board_cols_rows(width)
    return cols * rows

def grid_dims(avail_w, num_cols):
    return (avail_w - 2 * (num_cols - 1)) // num_cols

def draw_driver_row_block(c, x0, x1, y0, y1, row):
    box_h = y1 - y0 + 1
    font = "5x7" if box_h >= 8 else "4x5"
    text_h = 7 if font == "5x7" else 6
    cy = y0 + (box_h - text_h) // 2
    gap_font = "4x5" if font == "5x7" else "picopixel"
    # Gap and tyre letter share the name's bottom edge. Centring each font in
    # the 7 px box on its own put picopixel 1 px below the 4x5 name.
    row_bottom = cy + FONT_H[font] - 1
    gap_cy = top_for(gap_font, row_bottom)

    pos_str = str(row["pos"]) + ")"
    pos_w = c.text_width("20)", font) + 4
    c.rect(x0, y0, x0 + pos_w - 1, y1, fill = row["pos_bg"])
    c.text(pos_str, x0 + 2, cy, font = font, color = row["pos_txt"])

    row_x0 = x0 + pos_w + 1
    bg = row["bg"]
    txt_color = row["txt_color"]
    c.rect(row_x0, y0, x1, y1, fill = bg)

    tire = TIRE_BADGE.get(str(row.get("compound", "")).upper())
    tire_w = (c.text_width("M", "4x5") + 4) if tire != None else 0
    tire_reserve = (tire_w + 3) if tire != None else 0

    num_str = str(row["num"])
    if len(num_str) < 2:
        num_str = " " * (2 - len(num_str)) + num_str
    prefix = num_str + " "
    # Narrow boards use the broadcast 3-letter code (VER, NOR, ...) instead of
    # the full surname -- a 95px column can't hold "VERSTAPPEN" plus a gap.
    if c.width < 320:
        who = row.get("acr", "") or row["name"]
    else:
        who = (row["initial"] + "." + row["name"]) if row["initial"] else row["name"]

    gap = row.get("gap", "")
    gap_w = c.text_width(gap, gap_font) if gap != "" else 0
    reserve = (gap_w + 4) if gap_w > 0 else 0
    avail = (x1 - row_x0) - 6 - reserve - tire_reserve
    who_max = avail - c.text_width(prefix, font)
    who = fit_text(c, who, font, who_max) if who_max > 0 else ""
    c.text(prefix + who, row_x0 + 3, cy, font = font, color = txt_color)

    # Order across the row's right side: ... GAP  [TIRE]. The tire chip runs
    # flush to the row's right edge -- its black fill covers the livery color
    # all the way out, so nothing coloured shows past it -- and the gap is
    # right-aligned just left of it.
    if gap != "":
        c.text(gap, x1 - 3 - tire_reserve, gap_cy, font = gap_font, color = txt_color, align = "right")

    if tire != None:
        letter, tcol = tire
        tx0 = x1 - tire_w
        c.rect(tx0, y0, x1, y1, fill = "#000000")
        c.text(letter, tx0 + tire_w // 2, top_for("4x5", row_bottom), font = "4x5", color = tcol, align = "center")

def draw_order_group(c, rows, start, y0, y1):
    cols, nrows = board_cols_rows(c.width)
    col_w = grid_dims(c.width - 2 * EDGE, cols)
    row_h = (y1 - y0 + 1) // nrows
    row_gap = 1 if row_h > 6 else 0
    idx = start
    for col in range(cols):
        cx0 = EDGE + col * (col_w + 2)
        cx1 = cx0 + col_w - 1
        for r in range(nrows):
            if idx >= len(rows):
                return
            ry0 = y0 + r * row_h
            draw_driver_row_block(c, cx0, cx1, ry0, ry0 + row_h - 1 - row_gap, rows[idx])
            idx += 1

# ---------- pages: fixed ----------

# The F1 mark and the grand prix share one page. The mark (with a NEXT RACE
# or LIVE tag under it) holds the left, the circuit outline the right, and
# three text rows centre between them. 192: EDGE 4 + logo 44 + 6 + text 92 +
# 6 + circuit 36 + EDGE 4. 384/640: the same group centred with the text
# capped at 150, plus the live flag / lap / temp column after the circuit.
def event(c, ctx):
    st = get_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
        return
    live = st["mode"] == "live"
    wide = c.width >= 320
    status_w = 116 if (live and wide) else 0
    gap = 10 if wide else 6
    asset, nw, nh = track_asset_dims(st["track_key"])
    tw, th = cap_track_dims(nw, nh, 52 if wide else 36, 28 if wide else 26)
    fixed = LOGO_W + gap + gap + tw + (gap + status_w if status_w > 0 else 0)
    text_w = min(c.width - 2 * EDGE - fixed, 150)
    x0 = (c.width - fixed - text_w) // 2

    draw_logo_block(c, x0, live)
    tx0 = x0 + LOGO_W + gap
    cx = tx0 + text_w // 2
    trx = tx0 + text_w + gap
    draw_f1_track(c, asset, trx, (32 - th) // 2, tw, th)

    name, nf = fit_ladder(c, race_variants(st["race_name"]), ["6x8", "5x7", "4x5"], text_w)
    # Row bottoms on this page: 9 (race / flag), 16 (circuit / lap),
    # 27 (date / flag row / session / temp / the logo tag).
    c.text(name, cx, top_for(nf, 9), font = nf, color = COLORS["text"], align = "center")

    if not live:
        c.text(fit_text(c, st["track_name"], "4x5", text_w), cx, 12, font = "4x5", color = COLORS["muted"], align = "center")
        when = local_dt(ctx, st["race_date"], st.get("race_time", ""))
        wf = "5x7" if c.text_width(when, "5x7") <= text_w else "4x5"
        c.text(fit_text(c, when, wf, text_w), cx, top_for(wf, 27), font = wf, color = pick_date_color(ctx), align = "center")
        return

    session = st.get("session", "RACE")
    if not wide:
        draw_session_row(c, st["track_name"], SESSION_SHORT.get(session, session), cx, text_w, 12)
        draw_status_row(c, st, cx, text_w, 21)
        return

    c.text(fit_text(c, st["track_name"], "4x5", text_w), cx, 12, font = "4x5", color = COLORS["muted"], align = "center")
    c.text(fit_text(c, session, "5x7", text_w), cx, 21, font = "5x7", color = COLORS["accent2"], align = "center")
    stx = trx + tw + gap
    fcol = F1_FLAG_COLOR.get(st["flag"], COLORS["muted"])
    flag_raw = str(st["flag"])
    flag, ff = fit_ladder(c, [flag_raw, FLAG_SHORT.get(flag_raw, flag_raw)], ["6x8", "5x7"], status_w)
    c.text(flag, stx, top_for(ff, 9), font = ff, color = fcol)
    if st["is_race"]:
        c.text(fit_text(c, "LAP " + str(st["lap"]), "4x5", status_w), stx, 12, font = "4x5", color = COLORS["text"])
    if st.get("temp", "") != "":
        draw_temp(c, st, stx, top_for("4x5", 27), True)

def draw_logo_block(c, x, live):
    lw, lh = f1_logo_dims(LOGO_W, LOGO_H)
    # Tag bottom-aligns with the third text row (bottom 27); the mark's 11 lit
    # rows sit at 8-18, 4 px above it.
    c.image("f1-logo.png", x + (LOGO_W - lw) // 2, 8, w = lw, h = lh)
    tag = "LIVE" if live else "NEXT RACE"
    tcol = COLORS["error"] if live else COLORS["muted"]
    c.text(tag, x + LOGO_W // 2, top_for("4x5", 27), font = "4x5", color = tcol, align = "center")

# Circuit (gray) then session (amber), centred. The session is the one that
# matters live, so it keeps its width and a long circuit is truncated into
# what's left ("SPA-FRANCORCHAMPS" is 84 px on its own); under 20 px left, the
# circuit is dropped -- the outline beside the text still shows it.
def draw_session_row(c, track, session, cx, max_w, y):
    sw = c.text_width(session, "4x5")
    tw = c.text_width(track, "4x5") if track != "" else 0
    if tw > 0 and tw + 6 + sw > max_w:
        room = max_w - sw - 6
        track = fit_text(c, track, "4x5", room) if room >= 20 else ""
        tw = c.text_width(track, "4x5") if track != "" else 0
    if tw == 0:
        c.text(fit_text(c, session, "4x5", max_w), cx, y, font = "4x5", color = COLORS["accent2"], align = "center")
        return
    x = cx - (tw + 6 + sw) // 2
    c.text(track, x, y, font = "4x5", color = COLORS["muted"])
    c.text(session, x + tw + 6, y, font = "4x5", color = COLORS["accent2"])

def temp_suffix(st, with_cond):
    return st["temp_unit"] + (" " + st["weather_cond"] if with_cond else "")

def temp_width(c, st, with_cond):
    return c.text_width(st["temp"], "4x5") + 5 + c.text_width(temp_suffix(st, with_cond), "4x5")

# No bitmap font has a degree glyph (4x5 skips "°" silently), so the degree
# sign is a 3x3 ring drawn 1 px after the digits.
def draw_temp(c, st, x, y, with_cond):
    col = WEATHER_COLOR.get(st.get("weather_cond", ""), COLORS["accent2"])
    c.text(st["temp"], x, y, font = "4x5", color = col)
    dx = x + c.text_width(st["temp"], "4x5") + 1
    c.rect(dx, y, dx + 2, y + 2, fill = col)
    c.rect(dx + 1, y + 1, dx + 1, y + 1, fill = COLORS["bg"])
    c.text(temp_suffix(st, with_cond), dx + 4, y, font = "4x5", color = col)

# Flag, lap and air temp on one centred row. When it's short, drop the
# DRY/RAIN word first, then the temperature, then the lap:
# "SAFETY CAR" (57 px) + "LAP 38" (27 px) + 5 already fills the 92 px zone.
def draw_status_row(c, st, cx, max_w, y):
    flag = str(st["flag"])
    fcol = F1_FLAG_COLOR.get(flag, COLORS["muted"])
    fw = c.text_width(flag, "5x7")
    lap = ("LAP " + str(st["lap"])) if st["is_race"] else ""
    lap_w = (5 + c.text_width(lap, "4x5")) if lap != "" else 0
    if fw + lap_w > max_w and flag in FLAG_SHORT:
        flag = FLAG_SHORT[flag]
        fw = c.text_width(flag, "5x7")
    options = []
    if st.get("temp", "") != "":
        options.append((lap, True, True))
        options.append((lap, True, False))
    options.append((lap, False, False))
    options.append(("", False, False))
    lap_s, with_temp, with_cond, total = "", False, False, fw
    for opt in options:
        lap_s, with_temp, with_cond = opt
        total = fw
        if lap_s != "":
            total += 5 + c.text_width(lap_s, "4x5")
        if with_temp:
            total += 5 + temp_width(c, st, with_cond)
        if total <= max_w:
            break
    if total > max_w:
        flag = fit_text(c, flag, "5x7", max_w)
        total = c.text_width(flag, "5x7")
    x = cx - total // 2
    # LAP and temp (4x5) share the 5x7 flag's bottom edge.
    small_y = top_for("4x5", y + FONT_H["5x7"] - 1)
    c.text(flag, x, y, font = "5x7", color = fcol)
    x += c.text_width(flag, "5x7") + 5
    if lap_s != "":
        c.text(lap_s, x, small_y, font = "4x5", color = COLORS["text"])
        x += c.text_width(lap_s, "4x5") + 5
    if with_temp:
        draw_temp(c, st, x, small_y, with_cond)

# ---------- pages: running order ----------
# Two rotations off one fixed 4-page manifest. Between sessions: next race,
# last race x2, calendar. Live: event, then the order 8 cars a screen at a
# time (P1-8 / P9-16 / P17-22).

def order1(c, ctx):
    st = get_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
    elif st["mode"] == "live":
        _draw_running_order(c, st, 0)
    else:
        _draw_last_page(c, ctx, 0)

def order2(c, ctx):
    st = get_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
    elif st["mode"] == "live":
        _draw_running_order(c, st, 1)
    else:
        _draw_last_page(c, ctx, 1)

def order3(c, ctx):
    st = get_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
    elif st["mode"] == "live":
        _draw_running_order(c, st, 2)
    else:
        _draw_calendar(c, ctx, 0)

def _draw_running_order(c, st, page):
    draw_flag_bar(c, st["flag"])
    lo = page * board_capacity(c.width)
    # No "ORDER P1-8" tab: the position badge on every row already says what
    # this page is and which range it covers.
    if lo >= len(st["rows"]):
        c.text("--", c.width // 2, 14, font = "6x8", color = COLORS["muted"], align = "center")
        return
    draw_order_group(c, st["rows"], lo, 8, 31)

# ---------- off-season cards ----------

# order3's single CALENDAR page, showing the grands prix after the next one.
# 384/640: two columns of three (6). 192: one column of four (4), so a full
# "GRAND PRIX" name never has to truncate.
def cal_per_page(width):
    return 6 if width >= 320 else 4

def _draw_calendar(c, ctx, skip):
    date_color = pick_date_color(ctx)
    draw_page_tab(c, "CALENDAR", date_color)
    upcoming = fetch_f1_upcoming(ctx)
    per = cal_per_page(c.width)
    # up[0] is the immediate next race -- that's already the `event` page.
    races = upcoming[1 + skip:1 + skip + per]
    if len(races) == 0:
        c.text("SEASON COMPLETE" if skip == 0 else "END OF CALENDAR", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    ncols = 2 if c.width >= 320 else 1
    rows_per = per // ncols
    line_h = 8 if c.width >= 320 else 6
    col_w = grid_dims(c.width - 2 * EDGE, ncols)
    for i in range(len(races)):
        r = races[i]
        cx0 = EDGE + (i // rows_per) * (col_w + 2)
        ry = 8 + (i % rows_per) * line_h
        dt = local_daydate(ctx, str(r.get("date", "")), str(r.get("time", "")))
        c.text(dt, cx0, ry, font = "4x5", color = date_color)
        dx = cx0 + c.text_width("SEP 00", "4x5") + 5
        nm = up(r.get("raceName", "GRAND PRIX"))
        c.text(fit_text(c, nm, "4x5", cx0 + col_w - dx - 2), dx, ry, font = "4x5", color = COLORS["text"])

# LAST RACE across order1-2: 384/640 fits 12/page (three columns of four), so
# both pages together already cover the full 22-car field. 192 fits 8/page
# (two columns of four), so order1-2 cover P1-16 -- order3 is needed for the
# single CALENDAR page instead of a third LAST RACE page, so P17-22 aren't
# shown between sessions (they still appear live, on order3, during a race).
def _draw_last_page(c, ctx, page):
    draw_page_tab(c, "LAST RACE", "#E2E8F0")
    res = fetch_f1_last(ctx)
    if res == None:
        c.text("NO RESULT AVAILABLE", c.width // 2, 14, font = "5x7", color = COLORS["muted"], align = "center")
        return
    tabx = EDGE + c.text_width("LAST RACE", "4x5") + 10
    c.text(fit_text(c, res["race_name"], "picopixel", c.width - EDGE - tabx), tabx, 1, font = "picopixel", color = COLORS["muted"])

    ncols = 3 if c.width >= 320 else 2
    per_page = ncols * 4
    top = res["top"]
    lo = page * per_page
    if lo >= len(top):
        c.text("--", c.width // 2, 18, font = "6x8", color = COLORS["muted"], align = "center")
        return

    col_w = grid_dims(c.width - 2 * EDGE, ncols)
    # Positions right-justify in a two-digit slot, names start 2 px after it,
    # so "9" and "16" share one right edge and every name lines up.
    slot_w = c.text_width("00", "4x5")
    pw = slot_w + 2
    hi = min(lo + per_page, len(top))
    for i in range(lo, hi):
        pos, name, gap, name_color = top[i]
        j = i - lo
        cx0 = EDGE + (j // 4) * (col_w + 2)
        cx1 = cx0 + col_w - 1
        ry = 8 + (j % 4) * 6
        c.text(pos, cx0 + slot_w - c.text_width(pos, "4x5"), ry, font = "4x5", color = GOLD if pos == "1" else COLORS["accent2"])
        gw = 0
        if gap != "":
            gw = c.text_width(gap, "picopixel")
            c.text(gap, cx1, top_for("picopixel", ry + FONT_H["4x5"] - 1), font = "picopixel", color = COLORS["muted"], align = "right")
        # Driver name in the team's livery colour (falls back to white if the
        # constructorId isn't in the table).
        c.text(fit_text(c, name, "4x5", cx1 - cx0 - pw - gw - 3), cx0 + pw, ry, font = "4x5", color = name_color)
