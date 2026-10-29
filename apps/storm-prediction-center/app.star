# SPC Convective Outlook - Glance Developer Network app (64x32)
#
# Data comes from the NWS GIS map services for the Storm Prediction Center
# (public, no key). Every page sends a point query, so the server returns only
# the outlook polygons that contain the user's location.
#
#   Outlooks: .../outlooks/SPC_wx_outlks/MapServer/<layer>/query
#   MDs:      .../outlooks/spc_mesoscale_discussion/MapServer/0/query

SPC = "https://mapservices.weather.noaa.gov/vector/rest/services/outlooks/SPC_wx_outlks/MapServer/"
MD = "https://mapservices.weather.noaa.gov/vector/rest/services/outlooks/spc_mesoscale_discussion/MapServer/0/query"

WHITE = "#FFFFFF"
GRAY = "#8A8A8A"
AMBER = "#FFB000"
RED = "#FF3B30"
PINK = "#FF7AC8"
DIM = "#444444"
ROWLINE = "#333333"

# CIG1 amber, CIG2 red, CIG3 pink (index 0 is unused)
CIG_COLORS = [WHITE, AMBER, RED, PINK]

# Map layer ids on the SPC service
CAT_LAYER = {1: 1, 2: 9, 3: 17}

# [label, probability layer, conditional intensity (CIG) layer]
HAZARDS = {
    1: [["TORN", 3, 2], ["WIND", 7, 6], ["HAIL", 5, 4]],
    2: [["TORN", 11, 10], ["WIND", 15, 14], ["HAIL", 13, 12]],
}

# category value (dn) -> [name, hero block color, text color on black]
CATS = {
    2: ["TSTM", "#C1E9C1", "#C1E9C1"],
    3: ["MRGL", "#0B7A2E", "#1FA84A"],
    4: ["SLGT", "#F6F700", "#F6F700"],
    5: ["ENH", "#FF9A00", "#FF9A00"],
    6: ["MDT", "#E81C1C", "#FF3B30"],
    8: ["HIGH", "#FF40FF", "#FF40FF"],
}
NO_TSTM = ["NO TSTM", "#A9D6F5", "#A9D6F5"]

# Equal-size category boxes on the Days 1-3 page (x range, inclusive)
BOX_X0 = 34
BOX_X1 = 62

BOLT = [
    [0, 0, 1, 1, 1],
    [0, 1, 1, 1, 0],
    [1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1],
    [0, 0, 0, 1, 1],
    [0, 0, 1, 1, 0],
    [0, 1, 1, 0, 0],
    [1, 1, 0, 0, 0],
]

# ---------------------------------------------------------------- helpers

def _is_num(s):
    if s == "":
        return False
    digits = 0
    dots = 0
    for i in range(len(s)):
        ch = s[i]
        if ch == "-" or ch == "+":
            if i != 0:
                return False
        elif ch == ".":
            dots += 1
            if dots > 1:
                return False
        elif ch.isdigit():
            digits += 1
        else:
            return False
    return digits > 0

def _short(s, decimals):
    if "." not in s:
        return s
    p = s.split(".")
    return p[0] + "." + p[1][:decimals]

def _where(ctx):
    raw = (ctx.inputs.get("location", "") or "").strip()
    if raw == "":
        return {"state": "demo"}
    parts = raw.replace(",", " ").split()
    if len(parts) != 2 or not _is_num(parts[0]) or not _is_num(parts[1]):
        return {"state": "bad"}
    lat = float(parts[0])
    lon = float(parts[1])
    if lat < 24.0 or lat > 50.0 or lon < -125.5 or lon > -66.0:
        return {"state": "us"}
    name = (ctx.inputs.get("placename", "") or "").strip().upper()
    if name == "":
        name = _short(parts[0], 2) + " " + _short(parts[1], 2)
    return {"state": "ok", "lat": parts[0], "lon": parts[1], "name": name}

def _hit(url, lat, lon, fields):
    resp = http.get(
        url,
        params = {
            "where": "1=1",
            "geometry": lon + "," + lat,
            "geometryType": "esriGeometryPoint",
            "inSR": "4326",
            "spatialRel": "esriSpatialRelIntersects",
            "outFields": fields,
            "returnGeometry": "false",
            "f": "json",
        },
        ttl_seconds = 600,
    )
    if resp["status_code"] != 200:
        return None
    body = resp["json"]
    if type(body) != "dict" or "features" not in body:
        return None
    return body["features"]

def _all_layer_ids():
    ids = []
    for day in CAT_LAYER:
        ids.append(str(CAT_LAYER[day]))
    for day in HAZARDS:
        for spec in HAZARDS[day]:
            ids.append(str(spec[1]))
            ids.append(str(spec[2]))
    return ",".join(ids)

# ONE request returns every outlook layer (categories, probabilities, CIG for
# Days 1-3) at the user's point. The GDN runner allows only 8 uncached requests
# per render, and every page reuses this same cached call.
# Result: {layer id: [attribute dict, ...]} or None when the fetch fails.
def _layers(w):
    lat = float(w["lat"])
    lon = float(w["lon"])
    resp = http.get(
        SPC + "identify",
        params = {
            "f": "json",
            "geometry": w["lon"] + "," + w["lat"],
            "geometryType": "esriGeometryPoint",
            "sr": "4326",
            "layers": "all:" + _all_layer_ids(),
            "tolerance": "1",
            "mapExtent": "%s,%s,%s,%s" % (str(lon - 0.01), str(lat - 0.01), str(lon + 0.01), str(lat + 0.01)),
            "imageDisplay": "400,400,96",
            "returnGeometry": "false",
            "returnFieldName": "true",
            "returnUnformattedValues": "true",
        },
        ttl_seconds = 600,
    )
    if resp["status_code"] != 200:
        return None
    body = resp["json"]
    if type(body) != "dict" or "results" not in body:
        return None
    out = {}
    for r in body["results"]:
        a = r.get("attributes")
        if a == None:
            continue
        lid = int(r["layerId"])
        if lid not in out:
            out[lid] = []
        out[lid].append(a)
    return out

def _attr(a, key):
    for k in [key, key.upper(), key + " value"]:
        if k in a:
            return a[k]
    return None

def _max_dn(attrs):
    best = 0
    for a in attrs:
        d = _attr(a, "dn")
        if d != None and int(d) > best:
            best = int(d)
    return best

def _cig_level(attrs):
    best = 0
    for a in attrs:
        lab = _attr(a, "label")
        lvl = 0
        if lab != None and str(lab).upper().startswith("CIG"):
            tail = str(lab)[3:]
            if tail.isdigit():
                lvl = int(tail)
        if lvl > best:
            best = lvl
    return best

def _cat(w, day):
    data = _layers(w)
    if data == None:
        return None
    return _max_dn(data.get(CAT_LAYER[day], []))

def _md_active(w):
    feats = _hit(MD, w["lat"], w["lon"], "name")
    return feats != None and len(feats) > 0

def _cat_info(dn):
    if dn == None or dn < 2:
        return NO_TSTM
    if dn in CATS:
        return CATS[dn]
    best = 2
    for k in CATS:
        if k <= dn and k > best:
            best = k
    return CATS[best]

def _center(c, s, y, color, font):
    c.text(s, (64 - c.text_width(s, font)) // 2, y, font = font, color = color)

def _clip(c, s, font, maxw):
    for n in range(len(s), 0, -1):
        if c.text_width(s[:n], font) <= maxw:
            return s[:n]
    return ""

def _font_height(font):
    return int(font.split("x")[1].split("_")[0])

# Two short lines: what happened, then what to do
def _msg(c, line1, color1, line2):
    c.fill("black")
    _center(c, line1, 8, color1, "5x7")
    _center(c, line2, 19, GRAY, "4x5")

def _no_data(c):
    _msg(c, "NO DATA", RED, "WILL RETRY")

# True when the page was drawn as an input problem message
def _gate(c, w):
    if w["state"] == "bad":
        _msg(c, "BAD LOC", RED, "USE LAT,LON")
        return True
    if w["state"] == "us":
        _msg(c, "US ONLY", RED, "LOWER 48")
        return True
    return False

def _pill(c, s):
    w = c.text_width(s, "4x5") + 6
    x0 = 63 - w
    c.rect(x0, 1, 62, 9, outline = AMBER)
    c.pixel(x0, 1, "black")
    c.pixel(62, 1, "black")
    c.pixel(x0, 9, "black")
    c.pixel(62, 9, "black")
    c.text(s, x0 + 3, 3, font = "4x5", color = AMBER)

# Hero text: largest solid face that fits, drawn white and filled with a black
# outline (the *_outline faces draw hollow letters, so they are not used).
def _hero(c, s, y0, y1):
    options = ["10x16", "7x12", "5x7"]
    font = options[2]
    for o in options:
        if c.text_width(s, o) <= 60:
            font = o
            break
    x = (64 - c.text_width(s, font)) // 2
    y = y0 + ((y1 - y0 + 1) - _font_height(font)) // 2
    c.text_stroke(s, x, y, font, WHITE, stroke = "black", thickness = 1)

# ------------------------------------------------------------------ pages

def title(c, ctx):
    w = _where(ctx)
    if _gate(c, w):
        return
    label = "DEMO"
    color = AMBER
    sub = "SET LOCATION"
    if w["state"] == "ok":
        label = w["name"]
        color = WHITE
        sub = "DAYS 1-3"
    c.fill("black")
    c.bitmap(BOLT, 3, 4, "#FFD400")
    c.bitmap(BOLT, 56, 4, "#FFD400")
    _center(c, "SPC", 1, WHITE, "5x7")
    _center(c, "OUTLOOK", 9, WHITE, "5x7")
    c.line(12, 17, 51, 17, DIM)
    _center(c, _clip(c, label, "4x5", 62).rstrip(" ,-"), 20, color, "4x5")
    _center(c, sub, 26, GRAY, "4x5")

def outlook(c, ctx):
    w = _where(ctx)
    if _gate(c, w):
        return
    if w["state"] == "demo":
        _msg(c, "DEMO", AMBER, "SET LOCATION")
        return
    cats = []
    for day in [1, 2, 3]:
        dn = _cat(w, day)
        if dn == None:
            _no_data(c)
            return
        cats.append(dn)
    c.fill("black")
    ys = [3, 13, 23]
    for i in range(3):
        info = _cat_info(cats[i])
        name = info[0]
        if name == NO_TSTM[0]:
            name = "NONE"
        s = _clip(c, name, "5x7", BOX_X1 - BOX_X0 - 3)
        # every category sits in an equal-size box in its own color, with the
        # name centered inside it in white with a black outline
        x = BOX_X0 + (BOX_X1 - BOX_X0 + 1 - c.text_width(s, "5x7")) // 2
        c.text("DAY %d" % (i + 1), 1, ys[i] + 1, font = "4x5", color = GRAY)
        c.rect(BOX_X0, ys[i] - 1, BOX_X1, ys[i] + 7, fill = info[1])
        c.text_stroke(s, x, ys[i], "5x7", WHITE, stroke = "black", thickness = 1)
    c.line(1, 11, 62, 11, ROWLINE)
    c.line(1, 21, 62, 21, ROWLINE)

def day1(c, ctx):
    w = _where(ctx)
    if _gate(c, w):
        return
    pill = ""
    dn = 4
    if w["state"] == "demo":
        pill = "DEMO"
    else:
        dn = _cat(w, 1)
        if dn == None:
            _no_data(c)
            return
        if _md_active(w):
            pill = "MD"
    c.fill("black")
    c.text("DAY 1", 1, 3, font = "4x5", color = GRAY)
    if pill != "":
        _pill(c, pill)
    info = _cat_info(dn)
    c.rect(1, 11, 62, 30, fill = info[1])
    _hero(c, info[0], 11, 30)

def _hazard(c, ctx, day):
    w = _where(ctx)
    if _gate(c, w):
        return
    if w["state"] == "demo":
        _msg(c, "DEMO", AMBER, "SET LOCATION")
        return
    data = _layers(w)
    if data == None:
        _no_data(c)
        return
    rows = []
    for spec in HAZARDS[day]:
        rows.append([spec[0], _max_dn(data.get(spec[1], [])), _cig_level(data.get(spec[2], []))])
    c.fill("black")
    c.text("DAY %d HAZARD" % day, 1, 1, font = "4x5", color = GRAY)
    ys = [8, 16, 24]
    for i in range(3):
        r = rows[i]
        c.text(r[0], 1, ys[i] + 1, font = "4x5", color = GRAY)
        c.text("%d%%" % r[1], 22, ys[i], font = "5x7", color = WHITE)
        if r[2] > 0:
            lvl = min(r[2], 3)
            t = "CIG%d" % lvl
            c.text(t, 63 - c.text_width(t, "4x5"), ys[i] + 1, font = "4x5", color = CIG_COLORS[lvl])

def hazard1(c, ctx):
    _hazard(c, ctx, 1)

def hazard2(c, ctx):
    _hazard(c, ctx, 2)
