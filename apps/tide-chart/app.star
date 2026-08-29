# Tide Chart - nearest NOAA tide station within 50 mi of a US zip. (192x32)
#
# Flow (all keyless):
#   1. zippopotam.us     zip -> lat/lon
#   2. NOAA MDAPI        water-level stations (cached a day)
#   3. pick nearest      within SEARCH_MI; else "NO DATA AVAILABLE"
#   4. NOAA datagetter   high/low + hourly tide predictions
#
# Water-level stations (~300) stay under GDN's 1MB HTTP body cap. The full
# tide-prediction directory is ~2MB and gets truncated, so we use waterlevels
# and skip any station that has no astronomical predictions (Great Lakes).

SEARCH_MI = 50

STATIONS_URL = "https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations.json"
DATA_URL = "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter"

# ---------- helpers ----------

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _now_unix(ctx):
    u = getattr(ctx.now, "unix", None)
    if u != None:
        return int(u)
    return 0

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

def _ymd(unix, day_off):
    y, m, d = _civil_from_days(unix // 86400 + day_off)
    return str(y) + ("0" if m < 10 else "") + str(m) + ("0" if d < 10 else "") + str(d)

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def fmt12(hour, minute):
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + pad2(minute) + ap

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

def _miles(lat1, lon1, lat2, lon2):
    mlat = math.radians((lat1 + lat2) / 2.0)
    dy = (lat2 - lat1) * 69.17
    dx = (lon2 - lon1) * 69.17 * math.cos(mlat)
    return math.sqrt(dx * dx + dy * dy)

def _short_name(name):
    # "San Diego, CA" / "GALVESTON, Galveston Channel" -> short header label
    n = str(name or "").strip()
    if "," in n:
        n = n.split(",")[0]
    n = n.upper()
    if len(n) > 22:
        n = n[0:22]
    return n

def _parse_hilo(t):
    # "2026-08-09 08:30" -> [yyyy, mo, d, h, mi]
    parts = str(t).split(" ")
    if len(parts) != 2:
        return None
    ymd = parts[0].split("-")
    hm = parts[1].split(":")
    if len(ymd) != 3 or len(hm) < 2:
        return None
    return [int(ymd[0]), int(ymd[1]), int(ymd[2]), int(hm[0]), int(hm[1])]

def _local_stamp(parts, off_hours):
    # Approximate GMT unix for an LST/LDT wall time using the place's UTC offset.
    days = _days_from_civil(parts[0], parts[1], parts[2])
    sod = parts[3] * 3600 + parts[4] * 60
    return days * 86400 + sod - int(off_hours * 3600.0)

def _ft(v):
    # 3.948 -> "3.9FT", -0.57 -> "-0.6FT"
    n = float(v)
    # one decimal without relying on format specs Starlark may lack
    sign = ""
    if n < 0:
        sign = "-"
        n = -n
    whole = int(n)
    frac = int((n - float(whole)) * 10.0 + 0.5)
    if frac >= 10:
        whole = whole + 1
        frac = 0
    return sign + str(whole) + "." + str(frac) + "FT"

def _rel(stamp, now):
    # "IN 2H" / "IN 45M" / "2H AGO" — fills the middle of a schedule row.
    mins = (stamp - now) // 60
    if mins < 0:
        ago = -mins
        if ago < 60:
            return str(ago) + "M AGO"
        return str(ago // 60) + "H AGO"
    if mins < 60:
        return "IN " + str(mins) + "M"
    return "IN " + str(mins // 60) + "H"

# ---------- lookups ----------

def _geocode(zip):
    r = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if r["status_code"] != 200:
        return None
    places = r["json"].get("places", []) if r["json"] else []
    if not places:
        return None
    p = places[0]
    return {
        "lat": float(p["latitude"]),
        "lon": float(p["longitude"]),
        "city": str(p.get("place name", "")).upper(),
    }

def _utc_offset(lat, lon):
    # Same source world-clock uses; DST already applied.
    t = http.get(
        "https://timeapi.io/api/TimeZone/coordinate",
        params = {"latitude": str(lat), "longitude": str(lon)},
        ttl_seconds = 3600,
    )
    if t["status_code"] != 200 or not t["json"]:
        return 0.0
    cur = t["json"].get("currentUtcOffset", {})
    secs = cur.get("seconds", None)
    if secs == None:
        return 0.0
    return float(secs) / 3600.0

def _nearest_stations(lat, lon):
    r = http.get(
        STATIONS_URL,
        params = {"type": "waterlevels"},
        ttl_seconds = 86400,
    )
    if r["status_code"] != 200 or not r["json"]:
        return None

    stations = r["json"].get("stations", [])
    if not stations:
        return []

    # Coarse box first so we only run distance math on nearby candidates.
    dlat = float(SEARCH_MI) / 69.17 + 0.05
    # cos(lat) for lon degrees; clamp so high latitudes don't explode.
    clon = math.cos(math.radians(lat))
    if clon < 0.2:
        clon = 0.2
    dlon = float(SEARCH_MI) / (69.17 * clon) + 0.05

    found = []
    for s in stations:
        slat = s.get("lat", None)
        slon = s.get("lng", None)
        if slat == None or slon == None:
            continue
        slat = float(slat)
        slon = float(slon)
        if slat < lat - dlat or slat > lat + dlat:
            continue
        if slon < lon - dlon or slon > lon + dlon:
            continue
        d = _miles(lat, lon, slat, slon)
        if d <= float(SEARCH_MI):
            found.append({
                "id": str(s.get("id", "")),
                "name": str(s.get("name", "")),
                "dist": d,
            })

    # Selection sort by distance (Starlark has no list.sort / while).
    nfound = len(found)
    for i in range(nfound):
        best = i
        for j in range(i + 1, nfound):
            if found[j]["dist"] < found[best]["dist"]:
                best = j
        if best != i:
            tmp = found[i]
            found[i] = found[best]
            found[best] = tmp
    return found

def _predictions(station_id, begin, end, interval):
    r = http.get(
        DATA_URL,
        params = {
            "begin_date": begin,
            "end_date": end,
            "station": station_id,
            "product": "predictions",
            "datum": "MLLW",
            "time_zone": "lst_ldt",
            "interval": interval,
            "units": "english",
            "format": "json",
            "application": "glance-tide-chart",
        },
        ttl_seconds = 3600,
    )
    status = r["status_code"]
    body = r["json"]
    if status != 200 or not body:
        return None
    if "error" in body:
        return None
    preds = body.get("predictions", None)
    if preds == None:
        return None
    return preds

def _latest(station_id, product):
    # Latest observation for a met product. Missing sensors return a cached
    # 200+error body, so we won't keep re-hitting NOAA for stations that lack them.
    r = http.get(
        DATA_URL,
        params = {
            "date": "latest",
            "station": station_id,
            "product": product,
            "units": "english",
            "time_zone": "lst_ldt",
            "format": "json",
            "application": "glance-tide-chart",
        },
        ttl_seconds = 3600,
    )
    if r["status_code"] != 200 or not r["json"]:
        return None
    body = r["json"]
    if "error" in body:
        return None
    data = body.get("data", None)
    if not data or len(data) < 1:
        return None
    return data[0]

def _fmt_mph(v):
    n = float(v)
    return str(int(n + 0.5)) + "MPH"

def _fmt_f(v):
    n = float(v)
    return str(int(n + 0.5)) + "F"

def _station_met(station_id):
    # Wind + water only — leaves a request slot for NWS alerts on this page.
    # (GDN caps uncached http.get calls at 8 per render.)
    met = {
        "wind": None,
        "gust": None,
        "wdir": None,
        "water": None,
    }

    w = _latest(station_id, "wind")
    if w != None:
        s = w.get("s", None)
        g = w.get("g", None)
        dr = w.get("dr", None)
        if s != None and str(s) != "":
            met["wind"] = _fmt_mph(s)
        if g != None and str(g) != "":
            met["gust"] = _fmt_mph(g)
        if dr != None and str(dr) != "":
            met["wdir"] = str(dr)

    wt = _latest(station_id, "water_temperature")
    if wt != None and wt.get("v", None) != None:
        met["water"] = _fmt_f(wt["v"])

    return met

def _nws_alerts(lat, lon):
    # Active NWS alerts (marine + land) for the station point.
    r = http.get(
        "https://api.weather.gov/alerts/active",
        headers = {
            "User-Agent": "(glance-tide-chart, local-dev)",
            "Accept": "application/geo+json",
        },
        params = {"point": str(lat) + "," + str(lon)},
        ttl_seconds = 300,
    )
    if r["status_code"] != 200 or not r["json"]:
        return None

    feats = r["json"].get("features", [])
    if feats == None:
        feats = []

    warnings = []
    advisories = []
    watches = []
    others = []
    for f in feats:
        props = f.get("properties", {})
        if props == None:
            props = {}
        event = str(props.get("event", "ALERT")).upper()
        sev = str(props.get("severity", "")).upper()
        # Prefer short event name for the board.
        title = event
        if len(title) > 22:
            title = title[0:22]

        color = "yellow"
        if "WARNING" in event or sev == "EXTREME" or sev == "SEVERE":
            color = "red"
        elif "WATCH" in event:
            color = "orange"
        elif "ADVISORY" in event:
            color = "yellow"

        item = {"event": title, "sev": sev, "color": color}
        if "WARNING" in event:
            warnings.append(item)
        elif "ADVISORY" in event:
            advisories.append(item)
        elif "WATCH" in event:
            watches.append(item)
        else:
            others.append(item)

    ordered = warnings + advisories + watches + others
    return {"count": len(feats), "items": ordered}

def _station_by_id(sid):
    # Direct NOAA station record — used when the user enters a Station ID.
    r = http.get(
        "https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations/" + sid + ".json",
        ttl_seconds = 86400,
    )
    if r["status_code"] != 200 or not r["json"]:
        return None
    stations = r["json"].get("stations", [])
    if not stations:
        return None
    s = stations[0]
    lat = s.get("lat", None)
    lon = s.get("lng", None)
    if lat == None or lon == None:
        return None
    return {
        "id": str(s.get("id", sid)),
        "name": str(s.get("name", "")),
        "lat": float(lat),
        "lon": float(lon),
        "dist": 0.0,
    }

def _station_id(choice):
    """Pull the NOAA id out of a dropdown entry.

    The list shows "CA - San Diego (9410170)" because a bare 9410170 means
    nothing to anybody. Anything without a numeric id in trailing brackets --
    including the "Nearest to my zip code" entry, and any leftover blank from
    before this was a dropdown -- means fall back to the zip lookup.

    It used to be free text, which is why people pasted station ids off the
    NOAA map and got NOT FOUND: most of what that map shows is a current meter
    or a met station, and only about 237 gauges actually publish tide
    predictions. Those 237 are the whole of this list, so the failure cannot
    happen any more."""
    t = str(choice).strip()
    if t == "":
        return ""
    # A bare id still works. This was a free-text field until now, so anybody
    # who already had 8467150 saved keeps the station they chose instead of
    # being quietly moved to whatever is nearest their zip code.
    allnum = True
    for ch in t.elems():
        if ch < "0" or ch > "9":
            allnum = False
            break
    if allnum:
        return t
    if not t.endswith(")"):
        return ""
    i = t.rfind("(")
    if i < 0:
        return ""
    inner = t[i + 1:len(t) - 1].strip()
    if inner == "":
        return ""
    for ch in inner.elems():
        if ch < "0" or ch > "9":
            return ""
    return inner

# Returns {"ok": True, ...} or {"ok": False, "title":..., "sub":...}

def fetch(ctx):
    zip = _s(ctx, "zip", "")
    sid = _station_id(_s(ctx, "station", ""))

    now = _now_unix(ctx)
    begin = _ymd(now, 0)
    end = _ymd(now, 1)

    station = None
    hilo = None
    lat = 0.0
    lon = 0.0

    if sid:
        # Explicit station wins — zip is ignored completely.
        station = _station_by_id(sid)
        if station == None:
            return {"ok": False, "title": "BAD STATION", "sub": sid + " NOT FOUND"}
        lat = station["lat"]
        lon = station["lon"]
        hilo = _predictions(station["id"], begin, end, "hilo")
        if hilo == None or len(hilo) < 1:
            return {"ok": False, "title": "NO DATA AVAILABLE", "sub": "NO TIDE PREDICTIONS"}
    else:
        if not zip:
            return {"ok": False, "title": "NO LOCATION", "sub": "SET ZIP OR STATION ID"}

        place = _geocode(zip)
        if place == None:
            return {"ok": False, "title": "BAD ZIP", "sub": zip + " NOT FOUND"}

        lat = place["lat"]
        lon = place["lon"]

        cands = _nearest_stations(lat, lon)
        if cands == None:
            return {"ok": False, "title": "STATION ERROR", "sub": "NOAA LIST FAILED"}
        if not cands:
            return {"ok": False, "title": "NO DATA AVAILABLE", "sub": "NO STATION IN 50 MI"}

        # Prefer the closest station that actually publishes tide predictions.
        tries = len(cands)
        if tries > 3:
            tries = 3
        for i in range(tries):
            hilo = _predictions(cands[i]["id"], begin, end, "hilo")
            if hilo != None and len(hilo) > 0:
                station = cands[i]
                break

        if station == None or hilo == None:
            return {"ok": False, "title": "NO DATA AVAILABLE", "sub": "NO TIDE PREDICTIONS"}

    off = _utc_offset(lat, lon)

    hourly = _predictions(station["id"], begin, begin, "h")
    if hourly == None:
        hourly = []

    # Build tide rows, then pick the next HIGH and next LOW after now.
    tides = []
    for p in hilo:
        parts = _parse_hilo(p.get("t", ""))
        if parts == None:
            continue
        stamp = _local_stamp(parts, off)
        tides.append({
            "kind": str(p.get("type", "")).upper(),
            "ft": _ft(p.get("v", "0")),
            "label": fmt12(parts[3], parts[4]),
            "stamp": stamp,
            "y": parts[0],
            "mo": parts[1],
            "d": parts[2],
        })

    next_high = None
    next_low = None
    next_tide = None
    for row in tides:
        if row["stamp"] < now - 60:
            continue
        if next_tide == None:
            next_tide = row
        if row["kind"] == "H" and next_high == None:
            next_high = row
        if row["kind"] == "L" and next_low == None:
            next_low = row

    if next_tide == None and tides:
        next_tide = tides[0]
    if next_high == None:
        for row in tides:
            if row["kind"] == "H":
                next_high = row
                break
    if next_low == None:
        for row in tides:
            if row["kind"] == "L":
                next_low = row
                break

    heights = []
    for p in hourly:
        heights.append(float(p.get("v", "0")))

    # Local civil date + fraction of day.
    local = now + int(off * 3600.0)
    sod = local % 86400
    if sod < 0:
        sod = sod + 86400
    ly, lm, ld = _civil_from_days(local // 86400)

    # Today's H/L only (the board schedule).
    today = []
    for row in tides:
        if row["y"] == ly and row["mo"] == lm and row["d"] == ld:
            today.append(row)

    # Current height + rising/falling from the hourly curve.
    now_ft = ""
    trend = ""
    n = len(heights)
    if n >= 2:
        frac = float(sod) / 86400.0
        idx = frac * float(n - 1)
        i0 = int(idx)
        if i0 >= n - 1:
            i0 = n - 2
        i1 = i0 + 1
        t = idx - float(i0)
        now_h = heights[i0] + (heights[i1] - heights[i0]) * t
        now_ft = _ft(now_h)
        if heights[i1] > heights[i0] + 0.02:
            trend = "RISING"
        elif heights[i1] < heights[i0] - 0.02:
            trend = "FALLING"
        else:
            trend = "STEADY"

    return {
        "ok": True,
        "city": _short_name(station["name"]),
        "station": _short_name(station["name"]),
        "station_id": station["id"],
        "lat": lat,
        "lon": lon,
        "dist": int(station["dist"] + 0.5),
        "next": next_tide,
        "next_high": next_high,
        "next_low": next_low,
        "tides": tides,
        "today": today,
        "now_ft": now_ft,
        "trend": trend,
        "heights": heights,
        "day_frac": float(sod) / 86400.0,
    }

def _err(c, d, bar):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = bar)
    c.text("TIDE CHART", c.width // 2, 1, font = "5x7", color = "white", align = "center")
    c.text(d["title"], 4, 12, font = "6x8", color = "orange")
    c.text(d["sub"], 4, 23, font = "4x5", color = "gray")

def _tide_block(c, x, label, row, accent, now):
    # One half of the board: HIGH/LOW label, time + relative, height.
    c.text(label, x, 10, font = "4x5", color = accent)
    if row == None:
        c.text("--", x, 17, font = "6x8", color = "gray")
        c.text("--", x, 25, font = "5x7", color = "gray")
        return
    c.text(row["label"], x, 16, font = "6x8", color = "white")
    rel = _rel(row["stamp"], now)
    rx = x + c.text_width(row["label"], "6x8") + 3
    c.text(rel, rx, 18, font = "4x5", color = "yellow")
    c.text(row["ft"], x, 25, font = "5x7", color = accent)

# ---------- pages ----------

def tide(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        _err(c, d, "skyblue")
        return

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "#0A6E7A")

    now = _now_unix(ctx)

    # Header: [station] [RISE/FALL ft] ........ [XX MI or station id]
    # Measure right→left so a long station name never collides with status.
    sid_in = _station_id(_s(ctx, "station", ""))
    if sid_in:
        dist = d["station_id"]
    elif d["dist"] > 0:
        dist = str(d["dist"]) + " MI"
    else:
        dist = ""
    dist_w = 0
    if dist:
        dist_w = c.text_width(dist, "4x5")

    short = ""
    status = ""
    if d["trend"] and d["now_ft"]:
        short = d["trend"]
        if short == "RISING":
            short = "RISE"
        elif short == "FALLING":
            short = "FALL"
        status = short + " " + d["now_ft"]

    status_w = 0
    if status:
        status_w = c.text_width(status, "4x5")

    # Leave room for distance (+ gap) and optional status (+ gap).
    gap = 4
    reserved = dist_w + 6
    if status_w > 0:
        reserved = reserved + status_w + gap
    name_max = c.width - 6 - reserved
    if name_max < 40:
        # Ultra-tight: drop the ft, keep RISE/FALL only.
        if short:
            status = short
            status_w = c.text_width(status, "4x5")
            reserved = dist_w + 6 + status_w + gap
            name_max = c.width - 6 - reserved
    if name_max < 24:
        # Still too tight — hide status entirely.
        status = ""
        status_w = 0
        reserved = dist_w + 6
        name_max = c.width - 6 - reserved

    name = d["station"]
    sfont = fit_font(c, name, ["5x7", "4x5"], name_max)
    # Truncate if even 4x5 won't fit (no while in Starlark).
    for _i in range(20):
        if len(name) <= 3 or c.text_width(name, sfont) <= name_max:
            break
        name = name[0:len(name) - 1]

    c.text(name, 3, 1, font = sfont, color = "white")
    if status:
        sx = 3 + c.text_width(name, sfont) + gap
        c.text(status, sx, 2, font = "4x5", color = "yellow")
    if dist:
        c.text(dist, c.width - 3, 2, font = "4x5", color = "cyan", align = "right")

    mid = c.width // 2
    c.line(mid, 10, mid, 30, "#1A3A44")

    _tide_block(c, 3, "NEXT HIGH", d["next_high"], "cyan", now)
    _tide_block(c, mid + 4, "NEXT LOW", d["next_low"], "orange", now)

def today(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        _err(c, d, "blue")
        return

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "#143A66")
    c.text("TODAY", 3, 1, font = "5x7", color = "white")
    right = d["station"]
    if d["now_ft"]:
        right = d["now_ft"] + " " + d["station"]
    c.text(right, c.width - 3, 1, font = fit_font(c, right, ["5x7", "4x5"], 150),
           color = "cyan", align = "right")

    rows = d["today"]
    if not rows:
        rows = d["tides"]

    if not rows:
        c.text("NO TIDES TODAY", 4, 16, font = "6x8", color = "gray")
        return

    slots = []
    i = 0
    for row in rows:
        if i >= 4:
            break
        slots.append(row)
        i = i + 1

    now = _now_unix(ctx)
    next_i = -1
    j = 0
    for row in slots:
        if row["stamp"] >= now - 60 and next_i < 0:
            next_i = j
        j = j + 1

    # One tide per row: HIGH/LOW · time · relative · height.
    y = 9
    k = 0
    for row in slots:
        is_next = (k == next_i)
        past = row["stamp"] < now - 60

        if row["kind"] == "H":
            tag = "HIGH"
            accent = "cyan"
        else:
            tag = "LOW"
            accent = "orange"

        if past and not is_next:
            accent = "midgray"
            tcol = "midgray"
            rcol = "midgray"
        else:
            tcol = "white"
            rcol = "yellow" if is_next else "gray"

        if is_next:
            c.rect(0, y, c.width - 1, y + 5, fill = "#0A2030")
            c.rect(0, y, 1, y + 5, fill = "yellow")

        c.text(tag, 3, y, font = "4x5", color = accent)
        c.text(row["label"], 26, y, font = "4x5", color = tcol)
        c.text(_rel(row["stamp"], now), 68, y, font = "4x5", color = rcol)
        c.text(row["ft"], 154, y, font = "4x5", color = accent, align = "right")
        y = y + 6
        k = k + 1

    # Mini day curve in the leftover right strip — visual without owning the page.
    hs = d.get("heights", [])
    if len(hs) >= 2:
        left = 158
        right = c.width - 2
        top = 10
        bottom = 30
        lo = hs[0]
        hi = hs[0]
        for v in hs:
            if v < lo:
                lo = v
            if v > hi:
                hi = v
        span = hi - lo
        if span < 0.5:
            span = 0.5
        width = right - left
        height = bottom - top
        n = len(hs)
        prevx = None
        prevy = None
        for i in range(n):
            x = left + int(float(i) * float(width) / float(n - 1) + 0.5)
            y = bottom - int((hs[i] - lo) / span * float(height) + 0.5)
            if prevx != None:
                c.line(prevx, prevy, x, y, "#2A6A7A")
            prevx = x
            prevy = y
        frac = d.get("day_frac", 0.0)
        if frac < 0.0:
            frac = 0.0
        if frac > 1.0:
            frac = 1.0
        nx = left + int(frac * float(width) + 0.5)
        idx = frac * float(n - 1)
        i0 = int(idx)
        if i0 >= n - 1:
            i0 = n - 2
        t = idx - float(i0)
        nh = hs[i0] + (hs[i0 + 1] - hs[i0]) * t
        ny = bottom - int((nh - lo) / span * float(height) + 0.5)
        c.rect(nx - 1, ny - 1, nx + 1, ny + 1, fill = "yellow")

def conditions(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        _err(c, d, "orange")
        return

    met = _station_met(d["station_id"])
    alerts = _nws_alerts(d["lat"], d["lon"])

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "#3A2A10")
    c.text("CONDITIONS", 3, 1, font = "5x7", color = "white")
    c.text(d["station"], c.width - 3, 1, font = fit_font(c, d["station"], ["5x7", "4x5"], 110),
           color = "yellow", align = "right")

    # Met rows use 4x5 only so they clear the alert band below.
    has_met = False
    if met["wind"] != None:
        has_met = True
        wind = met["wind"]
        if met["wdir"] != None:
            wind = met["wdir"] + " " + wind
        c.text("WIND", 3, 10, font = "4x5", color = "gray")
        c.text(wind, 40, 10, font = "4x5", color = "cyan")
        if met["gust"] != None:
            gnum = met["gust"].replace("MPH", "")
            c.text("G" + gnum, 40 + c.text_width(wind, "4x5") + 4, 10,
                   font = "4x5", color = "skyblue")

    if met["water"] != None:
        has_met = True
        c.text("WATER", 3, 17, font = "4x5", color = "gray")
        c.text(met["water"], 40, 17, font = "4x5", color = "skyblue")

    if not has_met:
        c.text("NO STATION SENSORS", 3, 12, font = "4x5", color = "gray")

    # Alert band — 4x5 at y=26 fits under the met rows.
    if alerts == None:
        c.text("ALERTS UNAVAILABLE", 3, 26, font = "4x5", color = "orange")
        return

    if alerts["count"] == 0:
        c.text("ALL CLEAR", 3, 25, font = "5x7", color = "puregreen")
        return

    top = alerts["items"][0]
    label = top["event"]
    if top["sev"]:
        label = label + " " + top["sev"]
    if alerts["count"] > 1:
        label = label + " +" + str(alerts["count"] - 1)
    c.text(label, 3, 26, font = "4x5", color = top["color"])
