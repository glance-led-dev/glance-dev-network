DAY = 86400

def _fmt2(x):
    neg = x < 0
    mag = -x if neg else x
    scaled = int(mag * 100 + 0.5)
    whole = scaled // 100
    frac = scaled - whole * 100
    frac_s = str(frac)
    if len(frac_s) < 2:
        frac_s = "0" + frac_s
    s = str(whole) + "." + frac_s
    if neg and scaled != 0:
        s = "-" + s
    return s

def _fetch_values(ctx, ts_id, days):
    end_unix = ctx.now.unix
    start_unix = end_unix - days * DAY

    end_s = _unix_to_iso(end_unix) + "Z"
    start_s = _unix_to_iso(start_unix) + "Z"

    url = "https://nhdes.rtiamanzi.org/api/timeseries/" + ts_id + "/values/"
    resp = http.get(url, params={"start": start_s, "end": end_s}, ttl_seconds=1800)

    if resp["status_code"] != 200:
        return None
    return resp["json"]

def _unix_to_iso(u):
    days = u // DAY
    secs = u % DAY
    y, m, d = _civil_from_days(days)
    hh = secs // 3600
    mm = (secs % 3600) // 60
    ss = secs % 60
    return (fmt.pad(y, width=4) + "-" + fmt.pad(m) + "-" + fmt.pad(d) +
            "T" + fmt.pad(hh) + ":" + fmt.pad(mm) + ":" + fmt.pad(ss))

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
    y = y + 1 if m <= 2 else y
    return y, m, d

# DESIGN. A lake cross-section is the app's identity: the water in the basin
# sits below (or above) a white full-pool mark on the shore, so the drawdown
# reads as a picture before the numbers do. Page 1 heroes the elevation, with
# the gap to full pool in the state color; page 2 is the 7-day line against
# the full-pool reference. Everything stays inside the SCROLL safe zone
# (x 10-181) so the app never merges with its neighbours.

L = 10    # safe-zone left edge
R = 181   # safe-zone right edge

GRAY = "#6E7A94"
BANK = "#6B4423"
GRASS = "#2E8B3A"
WATER = "#1E6FC8"
SURFACE = "#78DCFF"

def _records(raw):
    # Keep only readings with a numeric value; the feed can carry gaps.
    out = []
    if type(raw) != "list":
        return out
    for r in raw:
        if type(r) != "dict":
            continue
        v = r.get("num_value")
        dt = r.get("datetime")
        if type(v) in ("int", "float") and type(dt) == "string":
            out.append({"datetime": dt, "v": float(v)})
    return sorted(out, key = lambda r: r["datetime"])

def _num(s, fallback):
    # float() on a bad free-text value would kill the render.
    s = str(s).strip()
    if not s or s.count(".") > 1:
        return fallback
    body = s[1:] if s.startswith("-") else s
    if not body or body == ".":
        return fallback
    for ch in body.elems():
        if ch not in "0123456789.":
            return fallback
    return float(s)

def _inputs(ctx):
    ts_id = str(ctx.inputs.get("timeseriesid", "")).strip()
    normalpool = _num(ctx.inputs.get("normalpool", "250.4"), 250.4)
    return ts_id, normalpool

def _state(drawdown):
    # One function owns word + color so they can never disagree.
    if drawdown > 0.005:
        return "BELOW FULL", "amber"
    if drawdown < -0.005:
        return "ABOVE FULL", "skyblue"
    return "AT FULL POOL", "green"

def _nodata(c, title, sub):
    c.fill("#0B0C12")
    _lake(c, L, 0.5)
    cx = L + 24 + (R - L - 24) // 2
    c.text(title, cx - c.text_width(title, font = "6x8") // 2, 8, font = "6x8", color = "#E8B04A")
    c.text(sub, cx - c.text_width(sub, font = "4x5") // 2, 20, font = "4x5", color = "#6A7090")

def _lake(c, x0, drawdown):
    # 24x25 basin cross-section at x0..x0+23, y 4..28. Each row below the
    # full-pool mark (y 8) is a quarter foot of drawdown.
    full_y = 8
    water_y = full_y + int(drawdown / 0.25 + (0.5 if drawdown >= 0 else -0.5))
    water_y = max(5, min(26, water_y))
    for y in range(4, 29):
        inset = (y - 4) // 3 + 1
        if y == 28:
            inset = 12
        for x in range(x0, x0 + 24):
            off = x - x0
            bank = off < inset or off >= 24 - inset
            if bank:
                top = y == 4 or (off == inset - 1 or off == 24 - inset)
                c.pixel(x, y, GRASS if (y <= 5 and top) else BANK)
            elif y == water_y:
                c.pixel(x, y, SURFACE)
            elif y > water_y:
                c.pixel(x, y, WATER)
            elif y == full_y and off % 2 == 0:
                c.pixel(x, y, color.dim("white", 45))
    # Full-pool mark on both shores.
    for dx in (0, 1, 2, 21, 22, 23):
        c.pixel(x0 + dx, full_y, "white")

def level(c, ctx):
    c.clear()
    ts_id, normalpool = _inputs(ctx)
    if not ts_id or ts_id == "PASTE-REAL-UUID-HERE":
        _nodata(c, "NO GAUGE SET", "ENTER AMANZI TIMESERIES ID")
        return

    raw = _fetch_values(ctx, ts_id, 2)
    if raw == None:
        _nodata(c, "LAKE DATA OFFLINE", "NHDES FEED UNAVAILABLE")
        return
    recs = _records(raw)
    if not recs:
        _nodata(c, "NO RECENT READINGS", "GAUGE HAS NOT REPORTED")
        return

    elevation = recs[-1]["v"]
    drawdown = normalpool - elevation
    word, col = _state(drawdown)

    _lake(c, L, drawdown)

    # Middle zone x 38-124: title, hero elevation, unit.
    c.text("PAWTUCKAWAY LAKE", 38, 1, font = "4x5", color = GRAY)
    hero = _fmt2(elevation)
    c.text(hero, 38, 10, font = "10x16", color = "white")
    hx = 38 + c.text_width(hero, font = "10x16") + 3
    c.text("FT", hx, 10, font = "5x7", color = "white")
    c.text("ELEV", hx, 20, font = "4x5", color = GRAY)

    c.vline(128, 3, 28, color.dim("white", 25))

    # Right zone x 132-181: gap to full pool, in the state color.
    if word == "AT FULL POOL":
        c.text("AT FULL", 132, 8, font = "6x8", color = col)
        c.text("POOL", 132, 19, font = "6x8", color = col)
        return
    gap = _fmt2(drawdown if drawdown > 0 else -drawdown)
    c.trend_arrow(132, 3, -1 if drawdown > 0 else 1, color = col)
    c.text(gap, 140, 3, font = "7x12", color = col)
    gx = 140 + c.text_width(gap, font = "7x12") + 2
    if gx + 8 <= R:
        c.text("FT", gx, 10, font = "4x5", color = col)
    c.text(word, 132, 20, font = "5x7", color = GRAY)

def trend(c, ctx):
    c.clear()
    ts_id, normalpool = _inputs(ctx)
    if not ts_id or ts_id == "PASTE-REAL-UUID-HERE":
        _nodata(c, "NO GAUGE SET", "ENTER AMANZI TIMESERIES ID")
        return

    raw = _fetch_values(ctx, ts_id, 7)
    if raw == None:
        _nodata(c, "LAKE DATA OFFLINE", "NHDES FEED UNAVAILABLE")
        return
    recs = _records(raw)
    if not recs:
        _nodata(c, "NO RECENT READINGS", "GAUGE HAS NOT REPORTED")
        return

    elevations = [r["v"] for r in recs]
    current = elevations[-1]

    target_iso = _unix_to_iso(ctx.now.unix - DAY) + "Z"
    day_ago = elevations[0]
    for r in recs:
        if r["datetime"] >= target_iso:
            day_ago = r["v"]
            break
    diff = current - day_ago

    if diff > 0.01:
        arrow_dir, trend_col = 1, "green"
    elif diff < -0.01:
        arrow_dir, trend_col = -1, "amber"
    else:
        arrow_dir, trend_col = 0, GRAY

    hi = max(elevations)
    lo = min(elevations)
    # Pull the full-pool line into the chart when it is close enough to read.
    show_full = normalpool - hi <= 0.5 and lo - normalpool <= 0.5
    axis_max = max(hi, normalpool) if show_full else hi
    axis_min = min(lo, normalpool) if show_full else lo
    if axis_max - axis_min < 0.1:
        mid = (axis_max + axis_min) / 2
        axis_max, axis_min = mid + 0.05, mid - 0.05

    # Header row: title left, 24h change right.
    c.text("7-DAY LAKE LEVEL", L, 1, font = "4x5", color = GRAY)
    chg = ("+" if diff > 0.005 else "") + _fmt2(diff) + " FT / 24H"
    cw = c.text_width(chg, font = "4x5")
    c.text(chg, R - cw, 1, font = "4x5", color = trend_col)
    c.trend_arrow(R - cw - 8, 1, arrow_dir, color = trend_col)

    # Chart x 10-150, y 8-30; hi/lo labels in the column to its right.
    chart_x, chart_y, chart_w, chart_h = L, 8, 141, 23
    c.sparkline(elevations, chart_x, chart_y, chart_w, chart_h, color = SURFACE,
                fill = color.dim("skyblue", 30), min_val = axis_min, max_val = axis_max)
    if show_full:
        fy = chart_y + int((axis_max - normalpool) / (axis_max - axis_min) * (chart_h - 1) + 0.5)
        for x in range(chart_x, chart_x + chart_w, 3):
            c.pixel(x, fy, "white")
        # Label the dotted line; below it when there is room, else above.
        ly = fy + 2 if fy + 7 <= chart_y + chart_h else fy - 6
        c.text_stroke("FULL", chart_x + chart_w - 17, ly, font = "4x5", color = "white")

    c.vline(154, 8, 30, color.dim("white", 25))
    c.text("HIGH", 158, 8, font = "4x5", color = GRAY)
    c.text(_fmt2(hi), 158, 14, font = "4x5", color = "white")
    c.text("LOW", 158, 20, font = "4x5", color = GRAY)
    c.text(_fmt2(lo), 158, 26, font = "4x5", color = "white")