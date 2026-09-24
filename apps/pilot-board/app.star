# ============================================================
# PILOT BOARD
#
# DESIGN. One page per airport, and the picture is the answer. On the
# left, a 27px compass holds the field's real runways at their true
# headings, and a skyblue arrow flies in from the direction the wind is
# blowing from. The best-aligned runway is drawn in white, the rest dim,
# so "which way are we landing" reads before any text does.
#
# On the right, four rows from loud to quiet: the airport and a filled
# flight-category chip; the wind as the hero; the favored runway with its
# headwind and crosswind (the crosswind turns amber near the pilot's
# personal limit and red past it); then visibility, ceiling, altimeter
# and temperature/dewpoint.
#
# Runways come from aviationweather.gov's airport feed, so any airport
# with published runways works. No hand-coded headings.
# ============================================================

METAR_URL = "https://aviationweather.gov/api/data/metar"
AIRPORT_URL = "https://aviationweather.gov/api/data/airport"

DEG = 3.141592653589793 / 180.0

# Safe zone: 6px of padding at both outer edges of the 128-wide strip.
EDGEL = 6
EDGER = 121

# Compass. A 13px ring centered at (20, 16) spans x 7-33, y 3-29.
CX = 20
CY = 16
RING = 13

# Text column starts one ring-width plus a 4px gutter right of the compass.
TX = 38

LABEL = "#6E7A94"
RING_COL = "#2A3242"
TICK_COL = "#6E7A94"
RWY_DIM = "#505A6E"
RWY_FAV = "white"
WIND_COL = "skyblue"

NODATA_BG = "#0B0C12"
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"

# ------------------------------------------------------------
# Small helpers
# ------------------------------------------------------------

def num(v):
    """A feed number, or None. The feed mixes ints, floats and strings
    like "10+" and "VRB", so every read goes through here."""
    if v == None:
        return None
    t = type(v)
    if t == "int" or t == "float":
        return float(v)
    s = str(v).strip().replace("+", "")
    if s == "":
        return None
    for ch in s.elems():
        if not (ch.isdigit() or ch == "." or ch == "-"):
            return None
    return float(s)

def iround(v):
    if v >= 0:
        return int(v + 0.5)
    return -int(-v + 0.5)

def pad(n, w):
    s = str(n)
    for _ in range(w - len(s)):
        s = "0" + s
    return s

def get(d, key):
    if d == None or type(d) != "dict":
        return None
    return d.get(key)

def bool_input(v, fallback):
    """Checkboxes arrive as a bool from Studio and as text from the app."""
    if v == None:
        return fallback
    if v == True or v == False:
        return v
    s = str(v).strip().lower()
    if s in ["true", "1", "yes", "on"]:
        return True
    if s in ["false", "0", "no", "off"]:
        return False
    return fallback

def clip(c, s, font, maxw):
    if c.text_width(s, font) <= maxw:
        return s
    for k in range(len(s) - 1, 0, -1):
        if c.text_width(s[:k], font) <= maxw:
            return s[:k]
    return ""

def fit_font(c, s, fonts, maxw):
    for f in fonts:
        if c.text_width(s, f) <= maxw:
            return f
    return fonts[-1]

def clean_id(raw):
    """ICAO code from whatever the pilot typed. A bare three-letter US
    code (TKI) gets its K, since both feeds only know the ICAO form."""
    s = ""
    for ch in str(raw).strip().upper().elems():
        if ch.isalnum():
            s += ch
    if len(s) == 3 and s.isalpha():
        s = "K" + s
    return s[:4]

# ------------------------------------------------------------
# Data
# ------------------------------------------------------------

def airport_ids(ctx):
    a1 = clean_id(ctx.inputs.get("airport1", "KTKI"))
    a2 = clean_id(ctx.inputs.get("airport2", ""))
    return [a1, a2]

def fetch(ctx):
    """One METAR call and one airport call cover both pages. The METAR
    ttl matches refresh (300s); runways change about never, so a day."""
    ids = [i for i in airport_ids(ctx) if len(i) >= 3]
    out = {"state": "ok", "metar": {}, "apt": {}}
    if len(ids) == 0:
        out["state"] = "setup"
        return out

    q = ",".join(ids)
    r = http.get(METAR_URL, params = {"ids": q, "format": "json"}, ttl_seconds = 300)
    if r["status_code"] == 204:
        return out
    if r["status_code"] != 200 or type(r["json"]) != "list":
        out["state"] = "offline"
        return out
    for m in r["json"]:
        sid = str(get(m, "icaoId") or "").upper()
        if sid != "":
            out["metar"][sid] = m

    a = http.get(AIRPORT_URL, params = {"ids": q, "format": "json"}, ttl_seconds = 86400)
    if a["status_code"] == 200 and type(a["json"]) == "list":
        for ap in a["json"]:
            sid = str(get(ap, "icaoId") or "").upper()
            if sid != "":
                out["apt"][sid] = ap
    return out

def runways(ap):
    """[{a, b, hdg}] where hdg is the true heading of end a. The feed's
    alignment is the heading of the first-listed end ("16/34" -> 160).
    Helipads and runways without an alignment are skipped."""
    out = []
    for rw in get(ap, "runways") or []:
        rid = str(get(rw, "id") or "")
        h = num(get(rw, "alignment"))
        if "/" not in rid or h == None:
            continue
        ends = rid.split("/")
        out.append({"a": ends[0], "b": ends[1], "hdg": h})
    return out

def angle_off(wind, hdg):
    d = (wind - hdg) % 360.0
    if d > 180:
        d = 360.0 - d
    return d

def favored(rwys, wdir):
    """The runway end most into the wind, across every runway."""
    best = None
    for i, rw in enumerate(rwys):
        for end, hdg in [(rw["a"], rw["hdg"]), (rw["b"], (rw["hdg"] + 180.0) % 360.0)]:
            off = angle_off(wdir, hdg)
            if best == None or off < best["off"]:
                best = {"name": end, "hdg": hdg, "off": off, "idx": i}
    return best

def components(speed, off):
    """Headwind and crosswind, rounded to whole knots."""
    return [iround(speed * math.cos(off * DEG)), iround(abs(speed * math.sin(off * DEG)))]

# ------------------------------------------------------------
# Formatting
# ------------------------------------------------------------

def wind_str(m):
    spd = num(get(m, "wspd"))
    if spd == None:
        return "WIND --"
    if spd < 1:
        return "CALM"
    d = num(get(m, "wdir"))
    head = "VRB" if d == None else pad(iround(d), 3)
    s = head + "/" + pad(iround(spd), 2)
    g = num(get(m, "wgst"))
    if g != None and g > spd:
        s += "G" + pad(iround(g), 2)
    return s

def vis_str(m):
    raw = str(get(m, "visib") or "").strip()
    v = num(raw)
    if v == None:
        return ""
    # US reports cap at "10+" and write it 10SM; overseas 9999 arrives as
    # "6+", where the plus is the only sign it means six or more.
    if v >= 10:
        return str(iround(v)) + "SM"
    if raw.endswith("+"):
        return str(iround(v)) + "+SM"
    if v == int(v):
        return str(int(v)) + "SM"
    return str(v) + "SM"

def ceiling_str(m):
    lowest = None
    cover = ""
    for layer in get(m, "clouds") or []:
        cv = str(get(layer, "cover") or "").upper()
        b = num(get(layer, "base"))
        if cv in ["BKN", "OVC", "VV", "OVX"] and b != None:
            if lowest == None or b < lowest:
                lowest = b
                cover = "VV" if cv == "OVX" else cv
    if lowest != None:
        return cover + pad(int(lowest / 100), 3)
    cv = str(get(m, "cover") or "").upper()
    if cv in ["FEW", "SCT"]:
        return "NO CIG"
    if cv in ["CLR", "SKC", "CAVOK"]:
        return cv
    return ""

def alt_str(m, units):
    hpa = num(get(m, "altim"))
    if hpa == None:
        return ""
    if units == "HPA":
        return "Q" + str(iround(hpa))
    inhg = iround(hpa * 2.953)
    return "A" + pad(inhg, 4)

def temp_strs(m, units):
    """[temp/dew, temp] so the header can fall back to temperature alone."""
    t = num(get(m, "temp"))
    d = num(get(m, "dewp"))
    if t == None:
        return ["", ""]
    if units == "F":
        t = t * 9.0 / 5.0 + 32.0
        d = None if d == None else d * 9.0 / 5.0 + 32.0
    s = str(iround(t))
    if d == None:
        return [s + units, s + units]
    return [s + "/" + str(iround(d)) + units, s + units]

def category(m):
    """[word, fill, ink] from one table, so the chip and its word can never
    disagree. Ink flips to black on the bright green fill."""
    cat = str(get(m, "fltCat") or "").upper()
    if cat == "VFR":
        return ["VFR", "green", "black"]
    if cat == "MVFR":
        return ["MVFR", "#2F6FDC", "white"]
    if cat == "IFR":
        return ["IFR", "red", "white"]
    if cat == "LIFR":
        return ["LIFR", "magenta", "white"]
    return ["", "", ""]

def xw_color(xw, limit):
    if limit == None:
        return "white"
    if xw > limit:
        return "red"
    if xw >= limit - 3:
        return "amber"
    return "white"

# ------------------------------------------------------------
# Compass
# ------------------------------------------------------------

def polar(r, bearing):
    a = bearing * DEG
    return [CX + r * math.sin(a), CY - r * math.cos(a)]

def draw_runway(c, hdg, col, half):
    """A 3px-wide bar through the center at a true heading, plotted pixel
    by pixel so diagonal runways stay solid instead of combing apart."""
    a = hdg * DEG
    fx, fy = math.sin(a), -math.cos(a)
    px, py = -fy, fx
    seen = {}
    steps = int(half * 2 * 2)
    for i in range(steps + 1):
        t = -half + i * 0.5
        for k in [-1.0, 0.0, 1.0]:
            x = iround(CX + fx * t + px * k)
            y = iround(CY + fy * t + py * k)
            key = x * 100 + y
            if key not in seen:
                seen[key] = True
                c.pixel(x, y, col)

def draw_wind_arrow(c, wdir):
    """Wind is named for where it comes FROM, so the arrow starts on the
    ring at that bearing and points in toward the field."""
    tail = polar(RING + 1, wdir)
    # Tip stops at radius 5 so the head stays clear of the runway bar.
    tip = polar(5, wdir)
    c.line(iround(tail[0]), iround(tail[1]), iround(tip[0]), iround(tip[1]), WIND_COL)
    # Head: two barbs swept back toward the ring.
    for s in [-1, 1]:
        b = polar(8, wdir + s * 28)
        c.line(iround(tip[0]), iround(tip[1]), iround(b[0]), iround(b[1]), WIND_COL)

def draw_compass(c, rwys, fav, wdir, calm):
    c.circle(CX, CY, RING, RING_COL)
    for b in [0, 90, 180, 270]:
        p1 = polar(RING, b)
        p2 = polar(RING - 2, b)
        c.line(iround(p1[0]), iround(p1[1]), iround(p2[0]), iround(p2[1]), TICK_COL)
    # North gets a white pip so the picture has an up.
    n = polar(RING, 0)
    c.pixel(iround(n[0]), iround(n[1]), "white")

    drawn = {}
    for i, rw in enumerate(rwys):
        if fav != None and i == fav["idx"]:
            continue
        k = iround(rw["hdg"]) % 180
        if k not in drawn:
            drawn[k] = True
            draw_runway(c, rw["hdg"], RWY_DIM, 9)
    if fav != None:
        draw_runway(c, fav["hdg"], RWY_FAV, 9)
    elif len(rwys) > 0 and len(drawn) == 0:
        draw_runway(c, rwys[0]["hdg"], RWY_DIM, 9)

    if wdir != None and not calm:
        draw_wind_arrow(c, wdir)

# ------------------------------------------------------------
# Screens
# ------------------------------------------------------------

def nodata(c, title, sub):
    c.fill(NODATA_BG)
    f = fit_font(c, title, ["6x8", "5x7", "4x5"], EDGER - EDGEL)
    c.text_center(clip(c, title, f, EDGER - EDGEL), 8, font = f, color = NODATA_TITLE)
    c.text_center(clip(c, sub, "4x5", EDGER - EDGEL), 20, font = "4x5", color = NODATA_SUB)

def segs(c, parts, x, y, font):
    """Draw [text, color] runs left to right with a 1px join; returns x."""
    for p in parts:
        c.text(p[0], x, y, font = font, color = p[1])
        x += c.text_width(p[0], font) + 1
    return x

def segs_width(c, parts, font):
    w = 0
    for p in parts:
        w += c.text_width(p[0], font) + 1
    return w - 1

GAP = 3

def row_width(c, groups, font):
    w = 0
    for g in groups:
        w += segs_width(c, g, font) + GAP
    return w - GAP

def row_fit(c, groups, maxw, font):
    """Shed groups from the end until the row fits."""
    keep = [g for g in groups if len(g) > 0]
    for _ in range(len(keep)):
        if row_width(c, keep, font) <= maxw:
            break
        keep = keep[:-1]
    return keep

def first_fit(c, candidates, maxw, font):
    """The first candidate row that fits whole; the last one, shed, if
    none does."""
    for cand in candidates:
        if row_width(c, cand, font) <= maxw:
            return cand
    return row_fit(c, candidates[-1], maxw, font)

def draw_row(c, groups, y, font):
    x = TX
    for g in groups:
        x = segs(c, g, x, y, font) + GAP - 1

def airport_page(c, ctx, which):
    ids = airport_ids(ctx)
    icao = ids[which]
    if len(icao) < 3:
        icao = ids[0]
    if len(icao) < 3:
        nodata(c, "ADD AN AIRPORT", "SET AN ICAO CODE LIKE KTKI")
        return

    data = fetch(ctx)
    if data["state"] == "offline":
        nodata(c, "NO WEATHER DATA", "TRYING AGAIN IN 5 MIN")
        return
    m = data["metar"].get(icao)
    if m == None:
        nodata(c, "NO METAR FOR " + icao, "CHECK THE ICAO CODE")
        return

    c.fill("black")

    tempu = str(ctx.inputs.get("tempunits", "F")).upper()
    tempu = "C" if tempu == "C" else "F"
    altu = str(ctx.inputs.get("altunits", "INHG")).upper()
    showg = bool_input(ctx.inputs.get("gusts", True), True)
    limit = num(ctx.inputs.get("xwlimit", "15"))

    spd = num(get(m, "wspd"))
    gst = num(get(m, "wgst"))
    wdir = num(get(m, "wdir"))
    calm = spd == None or spd < 1

    rwys = runways(data["apt"].get(icao))
    fav = None
    if wdir != None and not calm and len(rwys) > 0:
        fav = favored(rwys, wdir)

    draw_compass(c, rwys, fav, wdir, calm)

    # Row 1 (y 1-7): airport + category chip. The chip is measured first
    # and the ICAO is clipped into whatever is left.
    cat = category(m)
    chipx = EDGER + 1
    if cat[0] != "":
        cw = c.text_width(cat[0], "4x5") + 4
        chipx = EDGER - cw + 1
        c.round_rect(chipx, 0, EDGER, 8, 1, fill = cat[1])
        c.text(cat[0], chipx + 2, 2, font = "4x5", color = cat[2])
    c.text(clip(c, icao, "5x7", chipx - TX - 2), TX, 1, font = "5x7", color = "white")

    # Temperature rides in the header, right-aligned against the chip:
    # the 4-row column has no room for it below ("10SM BKN035 A3003 95F"
    # is 98px against 84). Dewpoint drops first when "-12/-15C" won't fit
    # between the ICAO (24px at 5x7) and the chip.
    icao_end = TX + c.text_width(icao, "5x7")
    room = chipx - 3 - (icao_end + 4)
    for t in temp_strs(m, tempu):
        if t != "" and c.text_width(t, "4x5") <= room:
            c.text(t, chipx - 3 - c.text_width(t, "4x5"), 2, font = "4x5", color = "white")
            break

    # Row 2 (y 10-17): the wind, the hero. "130/10G18" is 62px at 6x8,
    # which leaves room for a KT unit before the right edge.
    w = wind_str(m)
    wf = fit_font(c, w, ["6x8", "5x7"], EDGER - TX - 10)
    c.text(w, TX, 10, font = wf, color = "white")
    if w != "CALM" and spd != None:
        c.text("KT", TX + c.text_width(w, wf) + 2, 13, font = "4x5", color = LABEL)

    # Row 3 (y 20-24): favored runway and its components.
    if fav != None:
        steady = components(spd, fav["off"])
        hw = str(steady[0])
        xw = str(steady[1])
        hwg = hw
        worst = steady[1]
        if showg and gst != None and gst > spd:
            gc = components(gst, fav["off"])
            hwg += "/" + str(gc[0])
            xw += "/" + str(gc[1])
            worst = gc[1]
        rwy = [fav["name"], "green"]
        xwg = [["XW", LABEL], [xw, xw_color(worst, limit)]]

        # Crosswind is the reason the row exists, so it is never shed.
        # "RWY01L HW12/20 XW15/25" is 103px against 84: lose the RWY
        # label first, then the headwind gust, then the headwind.
        cands = [
            [[["RWY", LABEL], rwy], [["HW", LABEL], [hwg, "white"]], xwg],
            [[rwy], [["HW", LABEL], [hwg, "white"]], xwg],
            [[rwy], [["HW", LABEL], [hw, "white"]], xwg],
            [[rwy], xwg],
        ]
    elif calm:
        cands = [[[["CALM", LABEL], ["ANY RUNWAY", "green"]]]]
    elif len(rwys) == 0:
        cands = [[[["NO RUNWAY DATA", LABEL]]]]
    else:
        cands = [[[["VARIABLE WIND", LABEL]]]]
    draw_row(c, first_fit(c, cands, EDGER - TX, "4x5"), 20, "4x5")

    # Row 4 (y 26-30): conditions, shed from the right when they overflow.
    row4 = [
        [[vis_str(m), "white"]] if vis_str(m) != "" else [],
        [[ceiling_str(m), "white"]] if ceiling_str(m) != "" else [],
        [[alt_str(m, altu), "white"]] if alt_str(m, altu) != "" else [],
    ]
    draw_row(c, row_fit(c, row4, EDGER - TX, "4x5"), 26, "4x5")

# ============================================================
# PAGES
# ============================================================

def airport1(c, ctx):
    airport_page(c, ctx, 0)

def airport2(c, ctx):
    airport_page(c, ctx, 1)
