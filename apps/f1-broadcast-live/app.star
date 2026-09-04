# F1 - Broadcast Live (384x32).
#
# A real page rotation (the panel requests one render per page, in manifest
# order -- no single page faking frames off the wall clock):
#
#   logo    - the F1 wordmark
#   event   - grand prix / circuit / session, plus flag / lap / track weather
#             while running; the next-race card between sessions
#   track   - the circuit shape, big
#   board1..board2 + feed1..feed2 - four "flex" slots. While a session is live
#             they carry the full order a screen at a time (car #, driver, tyre
#             compound, gap to leader), then a race-control feed and a pit-stop
#             board. Between sessions they carry the next-race card, the rest of
#             the calendar, and the last grand prix's podium.
#
# Data: OpenF1 (api.openf1.org) for live timing, weather, stints, race control
# and pit stops -- free, no key. Jolpica-Ergast (api.jolpi.ca) for the schedule
# and last result. OpenF1 has no "current session" endpoint, so the app fetches
# the latest session and checks it is actually inside its live window (plus an
# end-of-day grace) before trusting it.

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

def fit_text(c, text, font, max_w):
    t = text
    for _ in range(60):
        if c.text_width(t, font) <= max_w or len(t) <= 3:
            return t
        cut = t.rfind(" ")
        t = t[:cut] if cut > 0 else t[:len(t) - 1]
    return t

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
                "AUTODROMO ", "AUTÓDROMO INTERNACIONAL ", "AUTÓDROMO ",
                "CIRCUIT DE BARCELONA-", "CIRCUIT DE ", "CIRCUIT PARK ",
                "CIRCUIT OF THE ", "CIRCUIT GILLES ", "CIRCUIT "):
        if t.startswith(pre):
            t = t[len(pre):]
    for suf in (" INTERNATIONAL CIRCUIT", " STREET CIRCUIT", " CITY CIRCUIT",
                " GRAND PRIX CIRCUIT", " RACE CIRCUIT", " CIRCUIT"):
        if t.endswith(suf):
            t = t[:-len(suf)]
    t = t.strip()
    if len(t) > 18:
        t = t[:18]
    return t

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

def keep_until_end_of_day(ctx, end_unix):
    off = panel_offset_seconds(ctx)
    local_end = end_unix + off
    local_day_start = (local_end // 86400) * 86400
    return local_day_start + 86399 - off

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
    if now_unix < start_unix or now_unix > keep_until_end_of_day(ctx, end_unix):
        return None

    session_key = session.get("session_key")
    session_type = str(session.get("session_type", "Race")).upper()
    circuit_short = str(session.get("circuit_short_name", ""))

    race_name = "GRAND PRIX"
    mresp = http_json("https://api.openf1.org/v1/meetings", 3600, params = {"meeting_key": str(session.get("meeting_key", ""))})
    if mresp["ok"] and len(mresp["data"]) > 0:
        race_name = str(mresp["data"][0].get("meeting_name", "GRAND PRIX")).upper()

    weather_txt = ""
    weather_cond = "DRY"
    wresp = http_json("https://api.openf1.org/v1/weather", 60, params = {"session_key": str(session_key)})
    if wresp["ok"] and len(wresp["data"]) > 0:
        w = wresp["data"][len(wresp["data"]) - 1]
        track_temp = w.get("track_temperature")
        if track_temp != None:
            rain = w.get("rainfall", 0)
            weather_cond = "RAIN" if rain and rain > 0 else "DRY"
            unit = safe_input(ctx, "tempunit", "C")
            temp_val = float(track_temp)
            if unit == "F":
                temp_val = temp_val * 9.0 / 5.0 + 32.0
            weather_txt = str(int(temp_val)) + unit + " " + weather_cond

    drivers = {}
    dresp = http_json("https://api.openf1.org/v1/drivers", 300, params = {"session_key": str(session_key)})
    if dresp["ok"]:
        for d in dresp["data"]:
            dn = d.get("driver_number")
            if dn != None:
                drivers[dn] = d

    cutoff = format_iso_utc(now_unix - 150)
    presp = http_json("https://api.openf1.org/v1/position?session_key=" + str(session_key) + "&date%3E" + cutoff, 15)
    positions = latest_by_driver(presp["data"]) if presp["ok"] else {}
    iresp = http_json("https://api.openf1.org/v1/intervals?session_key=" + str(session_key) + "&date%3E" + cutoff, 15)
    intervals = latest_by_driver(iresp["data"]) if iresp["ok"] else {}

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

    num2name = {}
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
        bg = ("#" + team_colour) if team_colour != "" else "#222222"
        compound = str(stints.get(dn, {}).get("compound", "")).upper()
        nm = last_name if last_name != "" else ("#" + str(dn))
        num2name[str(dn)] = nm

        rows.append({
            "pos": int(pos_entry.get("position", 0)),
            "num": str(dn),
            "initial": first_name[0].upper() if first_name else "",
            "name": nm,
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

    is_race = session_type == "RACE"
    return {
        "mode": "live",
        "session": session_type,
        "is_race": is_race,
        "race_name": race_name,
        "track_name": circuit_short.upper(),
        "track_key": circuit_key_from_short(circuit_short),
        "flag": flag_str,
        "lap": lap_num,
        "weather": weather_txt,
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
        "race_name": str(race.get("raceName", "GRAND PRIX")).upper(),
        "track_name": str(circuit.get("circuitName", "")).upper(),
        "circuit_id": str(circuit.get("circuitId", "")),
        "race_date": str(race.get("date", "")),
        "race_time": str(race.get("time", "")),
    }

def fetch_f1_schedule_after_next(ctx, n):
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
    return upcoming[1:1 + n]

def fetch_f1_last(ctx):
    resp = http_json("https://api.jolpi.ca/ergast/f1/current/last/results.json", 3600)
    if not resp["ok"]:
        return None
    races = resp["data"].get("MRData", {}).get("RaceTable", {}).get("Races", [])
    if len(races) == 0:
        return None
    race = races[0]
    top = []
    for x in race.get("Results", [])[:5]:
        drv = x.get("Driver", {})
        top.append((
            str(x.get("position", "")),
            str(drv.get("familyName", "")).upper(),
            str(x.get("Constructor", {}).get("name", "")).upper(),
        ))
    return {
        "race_name": str(race.get("raceName", "GRAND PRIX")).upper(),
        "circuit": str(race.get("Circuit", {}).get("circuitName", "")).upper(),
        "top": top,
    }

# ---------- pit stops / race control (OpenF1, feed pages) ----------

def fetch_pits(session_key):
    resp = http_json("https://api.openf1.org/v1/pit?session_key=" + str(session_key), 30)
    if not resp["ok"]:
        return {}
    best = {}
    cnt = {}
    for s in resp["data"]:
        dn = s.get("driver_number")
        dur = s.get("pit_duration")
        if dn == None:
            continue
        cnt[str(dn)] = cnt.get(str(dn), 0) + 1
        if dur != None and dur > 0:
            if str(dn) not in best or dur < best[str(dn)]:
                best[str(dn)] = dur
    return {"best": best, "cnt": cnt}

RC_KEEP = ["PENALTY", "INVESTIGAT", "DELETED", "NOTED", "SAFETY CAR",
           "BLACK", "DRS ", "PIT ", "STOP/GO", "REPRIMAND", "WARNING"]

def fetch_race_control(session_key):
    resp = http_json("https://api.openf1.org/v1/race_control?session_key=" + str(session_key), 20)
    if not resp["ok"]:
        return []
    msgs = []
    for e in resp["data"]:
        m = str(e.get("message", "")).upper().strip()
        if m == "":
            continue
        cat = str(e.get("category", ""))
        keep = cat == "SafetyCar" or cat == "Drs"
        for kw in RC_KEEP:
            if kw in m:
                keep = True
                break
        if keep:
            msgs.append((int(e.get("lap_number", 0) or 0), m))
    return msgs[-6:]

# ---------- top-level state ----------

def _mock_live(ctx, mode):
    TEAMS = [
        ("1", "M", "VERSTAPPEN", "#1E5BC6"),
        ("4", "L", "NORRIS", "#FF8000"),
        ("81", "O", "PIASTRI", "#FF8000"),
        ("16", "C", "LECLERC", "#DC0000"),
        ("44", "L", "HAMILTON", "#DC0000"),
        ("63", "G", "RUSSELL", "#00D2BE"),
        ("12", "A", "ANTONELLI", "#00D2BE"),
        ("22", "Y", "TSUNODA", "#1E5BC6"),
        ("14", "F", "ALONSO", "#006F62"),
        ("18", "L", "STROLL", "#006F62"),
        ("10", "P", "GASLY", "#0090FF"),
        ("7", "J", "DOOHAN", "#0090FF"),
        ("23", "A", "ALBON", "#005AFF"),
        ("55", "C", "SAINZ", "#005AFF"),
        ("27", "N", "HULKENBERG", "#C00000"),
        ("5", "G", "BORTOLETO", "#C00000"),
        ("30", "L", "LAWSON", "#2647D8"),
        ("6", "I", "HADJAR", "#2647D8"),
        ("87", "O", "BEARMAN", "#FFFFFF"),
        ("31", "E", "OCON", "#FFFFFF"),
    ]
    comps = ["SOFT", "MEDIUM", "HARD", "MEDIUM", "SOFT"]
    rows = []
    for i in range(len(TEAMS)):
        num, ini, name, col = TEAMS[i]
        gap = "" if i == 0 else format_gap_time(0.3 + i * 1.7)
        rows.append({
            "pos": i + 1, "num": num, "initial": ini, "name": name,
            "gap": gap if mode == "race" else format_gap_time(0.05 + i * 0.12),
            "bg": col, "txt_color": best_text_color(col),
            "pos_bg": "#000000", "pos_txt": "#FFFFFF",
            "compound": comps[i % len(comps)] if mode == "race" else "SOFT",
        })
    mark_duplicate_names(rows)
    is_race = mode == "race"
    return {
        "mode": "live", "session": "RACE" if is_race else "QUALIFYING",
        "is_race": is_race, "race_name": "SAO PAULO GRAND PRIX",
        "track_name": "INTERLAGOS", "track_key": "interlagos",
        "flag": "GREEN" if is_race else "CHEQUERED",
        "lap": 38 if is_race else 0,
        "weather": "31C DRY" if is_race else "24C DRY", "weather_cond": "DRY",
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
    c.rect(0, 0, c.width - 1, 9, fill = COLORS["panel"])
    c.image("checkered.png", 2, 1, w = 10, h = 8)
    c.text("FORMULA 1", 16, 2, font = "5x7", color = COLORS["accent"])
    c.text(str(title).upper(), 4, 14, font = "6x8", color = COLORS["error"])
    c.text(str(sub).upper(), 4, 24, font = "4x5", color = COLORS["muted"])

def draw_page_tab(c, label, color):
    w = c.text_width(label, "4x5") + 6
    c.rect(0, 0, w, 6, fill = color)
    c.text(label, 3, 1, font = "4x5", color = best_text_color(color))

def draw_flag_bar(c, flag):
    if flag == "CHEQUERED":
        seg = 6
        for i in range((c.width + seg - 1) // seg):
            x = i * seg
            c.rect(x, 0, min(x + seg - 1, c.width - 1), 1, fill = "#FFFFFF" if i % 2 == 0 else "#000000")
    else:
        c.rect(0, 0, c.width - 1, 1, fill = F1_FLAG_COLOR.get(flag, COLORS["muted"]))

BOARD_COLS = 3
BOARD_ROWS = 4

def board_capacity():
    return BOARD_COLS * BOARD_ROWS

def grid_dims(avail_w, num_cols):
    return (avail_w - 2 * (num_cols - 1)) // num_cols

def draw_driver_row_block(c, x0, x1, y0, y1, row):
    box_h = y1 - y0 + 1
    font = "5x7" if box_h >= 8 else "4x5"
    text_h = 7 if font == "5x7" else 6
    cy = y0 + (box_h - text_h) // 2
    gap_font = "4x5" if font == "5x7" else "picopixel"
    gap_h = 6 if gap_font == "4x5" else 5
    gap_cy = y0 + (box_h - gap_h) // 2

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
    who = (row["initial"] + "." + row["name"]) if row["initial"] else row["name"]

    gap = row.get("gap", "")
    gap_w = c.text_width(gap, gap_font) if gap != "" else 0
    reserve = (gap_w + 4) if gap_w > 0 else 0
    avail = (x1 - row_x0) - 6 - reserve - tire_reserve
    who_max = avail - c.text_width(prefix, font)
    who = fit_text(c, who, font, who_max) if who_max > 0 else ""
    c.text(prefix + who, row_x0 + 3, cy, font = font, color = txt_color)

    if tire != None:
        letter, tcol = tire
        tx0 = x1 - 3 - reserve - tire_w
        c.rect(tx0, y0, tx0 + tire_w - 1, y1, fill = "#000000")
        c.text(letter, tx0 + tire_w // 2, y0 + (box_h - 6) // 2, font = "4x5", color = tcol, align = "center")

    if gap != "":
        c.text(gap, x1 - 3, gap_cy, font = gap_font, color = txt_color, align = "right")

def draw_order_group(c, rows, start, y0, y1):
    avail_w = c.width
    col_w = grid_dims(avail_w, BOARD_COLS)
    row_h = (y1 - y0 + 1) // BOARD_ROWS
    row_gap = 1 if row_h > 6 else 0
    idx = start
    for col in range(BOARD_COLS):
        cx0 = col * (col_w + 2)
        cx1 = cx0 + col_w - 1
        for r in range(BOARD_ROWS):
            if idx >= len(rows):
                return
            ry0 = y0 + r * row_h
            draw_driver_row_block(c, cx0, cx1, ry0, ry0 + row_h - 1 - row_gap, rows[idx])
            idx += 1

def draw_stat_group(c, items, y0, y1, accent):
    col_w = grid_dims(c.width, 3)
    row_h = (y1 - y0 + 1) // 3
    bw = c.text_width("00", "4x5") + 4
    idx = 0
    for col in range(3):
        cx0 = col * (col_w + 2)
        cx1 = cx0 + col_w - 1
        for r in range(3):
            if idx >= len(items):
                return
            rank_str, name, val, vcol = items[idx]
            idx += 1
            ry0 = y0 + r * row_h
            c.rect(cx0, ry0, cx0 + bw - 1, ry0 + 7, fill = accent)
            c.text(rank_str, cx0 + 2, ry0 + 1, font = "4x5", color = best_text_color(accent))
            vw = c.text_width(val, "4x5")
            c.text(val, cx1, ry0 + 1, font = "4x5", color = vcol, align = "right")
            nx = cx0 + bw + 3
            c.text(fit_text(c, name, "5x7", cx1 - nx - vw - 4), nx, ry0, font = "5x7", color = COLORS["text"])

def _sec(v):
    v = float(v)
    whole = int(v)
    frac = int((v - whole) * 100 + 0.5)
    return str(whole) + "." + (("0" + str(frac)) if frac < 10 else str(frac))

# ---------- pages: fixed ----------

def logo(c, ctx):
    st = get_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
        return
    lw, lh = f1_logo_dims(c.width - 60, 18)
    c.image("f1-logo.png", (c.width - lw) // 2, (28 - lh) // 2, w = lw, h = lh)
    tag = "LIVE" if st["mode"] == "live" else "NEXT UP"
    tcol = COLORS["error"] if st["mode"] == "live" else COLORS["muted"]
    c.text(tag, c.width // 2, 27, font = "picopixel", color = tcol, align = "center")

def event(c, ctx):
    st = get_state(ctx)
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
    asset, nw, nh = track_asset_dims(st["track_key"])
    tw, th = cap_track_dims(nw, nh, 40, 26)

    show_status = is_race or st.get("weather", "") != ""
    status_w = 116 if show_status else 0
    text_w = c.width - tw - gap * (3 if show_status else 2) - status_w

    total = text_w + gap + tw + (gap + status_w if show_status else 0)
    margin = (c.width - total) // 2
    tx0 = margin
    tcx = tx0 + text_w // 2
    trx = tx0 + text_w + gap
    stx = trx + tw + gap

    c.text(fit_text(c, st["race_name"], "6x8", text_w), tcx, 1, font = "6x8", color = COLORS["text"], align = "center")
    c.text(fit_text(c, st["track_name"], "4x5", text_w), tcx, 12, font = "4x5", color = COLORS["muted"], align = "center")
    c.text(fit_text(c, session, "5x7", text_w), tcx, 21, font = "5x7", color = COLORS["accent2"], align = "center")

    draw_f1_track(c, asset, trx, (32 - th) // 2, tw, th)

    if show_status:
        smw = c.width - stx - 2
        fcol = F1_FLAG_COLOR.get(st["flag"], COLORS["muted"])
        c.text(fit_text(c, str(st["flag"]), "6x8", smw), stx, 1, font = "6x8", color = fcol)
        if is_race:
            c.text(fit_text(c, "LAP " + str(st["lap"]), "4x5", smw), stx, 12, font = "4x5", color = COLORS["text"])
        wtxt = st.get("weather", "")
        if wtxt != "":
            wcol = WEATHER_COLOR.get(st.get("weather_cond", ""), COLORS["accent2"])
            c.text(fit_text(c, wtxt, "4x5", smw), stx, 21, font = "4x5", color = wcol)

def track(c, ctx):
    st = get_state(ctx)
    c.fill(COLORS["bg"])
    if st["mode"] == "error":
        draw_error(c, st["title"], st["sub"])
        return
    asset, nw, nh = track_asset_dims(st["track_key"])
    tw, th = cap_track_dims(nw, nh, 150, 30)
    tx = (c.width - tw) // 2 - 30
    draw_f1_track(c, asset, tx, (32 - th) // 2, tw, th)
    lx = tx + tw + 12
    c.text(fit_text(c, st["track_name"], "6x8", c.width - lx - 2), lx, 6, font = "6x8", color = COLORS["text"])
    if st["mode"] == "live" and st.get("is_race"):
        c.text("LAP " + str(st["lap"]), lx, 17, font = "4x5", color = COLORS["muted"])
    else:
        c.text("THE CIRCUIT", lx, 17, font = "4x5", color = COLORS["muted"])

# ---------- pages: flex ----------

def board1(c, ctx):
    _flex(c, ctx, 0)

def board2(c, ctx):
    _flex(c, ctx, 1)

def feed1(c, ctx):
    _flex(c, ctx, 2)

def feed2(c, ctx):
    _flex(c, ctx, 3)

def _flex_blocks(ctx, st):
    if st["mode"] == "error":
        return [("error", 0)]
    if st["mode"] == "off":
        return [("next", 0), ("sched", 0), ("result", 0)]
    cap = board_capacity()
    pages = max(1, (len(st["rows"]) + cap - 1) // cap)
    blocks = []
    for p in range(pages):
        blocks.append(("order", p))
    blocks.append(("racecontrol", 0))
    if st["is_race"]:
        blocks.append(("pits", 0))
    return blocks

def _flex(c, ctx, slot):
    st = get_state(ctx)
    c.fill(COLORS["bg"])
    blocks = _flex_blocks(ctx, st)
    kind, arg = blocks[slot % len(blocks)]
    if kind == "error":
        draw_error(c, st["title"], st["sub"])
    elif kind == "next":
        _draw_next_card(c, ctx, st, big = False)
    elif kind == "sched":
        _draw_schedule(c, ctx)
    elif kind == "result":
        _draw_last(c, ctx)
    elif kind == "order":
        _draw_order(c, st, arg)
    elif kind == "racecontrol":
        _draw_racecontrol(c, st)
    elif kind == "pits":
        _draw_pits(c, st)

def _draw_order(c, st, page):
    draw_flag_bar(c, st["flag"])
    draw_page_tab(c, "ORDER " + str(page + 1), COLORS["accent"])
    draw_order_group(c, st["rows"], page * board_capacity(), 8, 31)

def _draw_racecontrol(c, st):
    draw_page_tab(c, "RACE CONTROL", COLORS["accent2"])
    if st.get("session_key", "mock") == "mock":
        msgs = [(37, "TRACK LIMITS - CAR 16 LAP TIME DELETED"),
                (36, "INCIDENT INVOLVING CARS 4 AND 81 NOTED"),
                (34, "SAFETY CAR IN THIS LAP")]
    else:
        msgs = fetch_race_control(st["session_key"])
    if len(msgs) == 0:
        c.text("NO MESSAGES", c.width // 2, 15, font = "5x7", color = COLORS["muted"], align = "center")
        return
    y = 8
    for lap, m in msgs[-3:]:
        tag = ("L" + str(lap) + " ") if lap > 0 else ""
        c.text(tag, 4, y, font = "4x5", color = COLORS["muted"])
        tx = 4 + c.text_width("L00 ", "4x5")
        c.text(fit_text(c, m, "4x5", c.width - tx - 4), tx, y, font = "4x5", color = COLORS["text"])
        y += 8

def _draw_pits(c, st):
    draw_page_tab(c, "PIT STOPS", "#38BDF8")
    if st.get("session_key", "mock") == "mock":
        c.text("2.4S  VERSTAPPEN", 6, 10, font = "5x7", color = COLORS["text"])
        c.text("2.6S  RUSSELL", 6, 20, font = "5x7", color = COLORS["text"])
        return
    pd = fetch_pits(st["session_key"])
    best = pd.get("best", {})
    if len(best) == 0:
        c.text("NO STOPS YET", c.width // 2, 15, font = "5x7", color = COLORS["muted"], align = "center")
        return
    pairs = sorted(best.items(), key = lambda kv: kv[1])[:9]
    items = []
    for i in range(len(pairs)):
        dn, dur = pairs[i]
        nm = st.get("num2name", {}).get(str(dn), "#" + str(dn))
        items.append((str(i + 1), nm, _sec(dur) + "S", "#7DD3FC"))
    draw_stat_group(c, items, 8, 31, "#38BDF8")

# ---------- off-season cards ----------

def _draw_next_card(c, ctx, st, big):
    date_color = safe_input(ctx, "datecolor", COLORS["accent2"])
    asset, nw, nh = track_asset_dims(st["track_key"])
    tw, th = cap_track_dims(nw, nh, 52, 28)
    gap = 10
    text_w = c.width - tw - gap - 16
    total = text_w + gap + tw
    margin = (c.width - total) // 2
    tx0 = margin
    trx = tx0 + text_w + gap
    cx = tx0 + text_w // 2
    draw_f1_track(c, asset, trx, (32 - th) // 2, tw, th)
    if not big:
        draw_page_tab(c, "NEXT RACE", COLORS["accent"])
    c.text(fit_text(c, st["race_name"], "6x8", text_w), cx, 2, font = "6x8", color = COLORS["text"], align = "center")
    c.text(fit_text(c, st["track_name"], "4x5", text_w), cx, 13, font = "4x5", color = COLORS["muted"], align = "center")
    c.text(fit_text(c, local_dt(ctx, st["race_date"], st.get("race_time", "")), "5x7", text_w), cx, 21, font = "5x7", color = date_color, align = "center")

def _draw_schedule(c, ctx):
    draw_page_tab(c, "CALENDAR", COLORS["accent2"])
    races = fetch_f1_schedule_after_next(ctx, 3)
    if len(races) == 0:
        c.text("NO RACES SCHEDULED", c.width // 2, 15, font = "5x7", color = COLORS["muted"], align = "center")
        return
    date_color = safe_input(ctx, "datecolor", COLORS["accent2"])
    dx = 4 + c.text_width("SEP 00", "5x7") + 8
    y = 8
    for r in races:
        dt = local_daydate(ctx, str(r.get("date", "")), str(r.get("time", "")))
        c.text(dt, 4, y, font = "5x7", color = date_color)
        nm = str(r.get("raceName", "GRAND PRIX")).upper().replace(" GRAND PRIX", " GP")
        c.text(fit_text(c, nm, "5x7", c.width - dx - 4), dx, y, font = "5x7", color = COLORS["text"])
        y += 8

def _draw_last(c, ctx):
    draw_page_tab(c, "LAST RACE", "#E2E8F0")
    res = fetch_f1_last(ctx)
    if res == None:
        c.text("NO RESULT AVAILABLE", c.width // 2, 15, font = "5x7", color = COLORS["muted"], align = "center")
        return
    c.text(fit_text(c, res["race_name"], "5x7", 200), 4, 8, font = "5x7", color = COLORS["text"])
    c.text(fit_text(c, short_circuit(res["circuit"]), "picopixel", 200), 4, 16, font = "picopixel", color = COLORS["muted"])
    x = 4
    for pos, name, team in res["top"]:
        chip = pos + " " + name
        w = c.text_width(chip, "picopixel") + 5
        if x + w > c.width - 2:
            break
        c.text(chip, x, 23, font = "picopixel", color = GOLD if pos == "1" else COLORS["muted"])
        x += w
