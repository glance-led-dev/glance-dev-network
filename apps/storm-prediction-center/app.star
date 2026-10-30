# SPC Convective Outlook - Glance Developer Network app (64x32 and 192x32)
#
# DESIGN. A storm cloud names the app; after that every page is the SPC's own
# color scale. The five risk levels (MRGL..HIGH) are drawn as a ladder whose
# lit rungs climb to today's level, the Days 1-3 cards wear the category fill,
# and the hazard columns are tornado / wind / hail art tinted by probability.
# Black ground everywhere; text on a colored card is stroked.
#
# Data, all public and keyless:
#   ZIP -> lat/lon/city: api.zippopotam.us/us/<zip>              (ttl 1 day)
#   Outlooks: .../outlooks/SPC_wx_outlks/MapServer/identify     (ttl 10 min)
#   MDs:      .../outlooks/spc_mesoscale_discussion/MapServer/0  (ttl 10 min)
# The outlook call is one identify request covering every layer, so a render
# costs at most three requests. refresh is 1800s; the 600s ttl keeps each
# refresh on fresh data.
#
# One app.star serves both builds: `if c.width >= 128` picks the wide layout.

SPC = "https://mapservices.weather.noaa.gov/vector/rest/services/outlooks/SPC_wx_outlks/MapServer/"
MD = "https://mapservices.weather.noaa.gov/vector/rest/services/outlooks/spc_mesoscale_discussion/MapServer/0/query"
ZIPAPI = "https://api.zippopotam.us/us/"
DEFAULT_ZIP = "73069"

WHITE = "#FFFFFF"
GRAY = "#8A8A8A"
LABEL = "#6E7A94"
AMBER = "#FFB000"
RED = "#FF3B30"
PINK = "#FF7AC8"
DIM = "#3A3A3A"
CARD_OFF = "#161616"
NODATA_BG = "#0B0C12"
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"

FONTH = {"10x16": 16, "7x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# CIG1 amber, CIG2 red, CIG3 pink (index 0 is unused)
CIG_COLORS = [WHITE, AMBER, RED, PINK]

# Map layer ids on the SPC service
CAT_LAYER = {1: 1, 2: 9, 3: 17}

# [label, probability layer, conditional intensity (CIG) layer]
HAZARDS = {
    1: [["TORN", 3, 2], ["WIND", 7, 6], ["HAIL", 5, 4]],
    2: [["TORN", 11, 10], ["WIND", 15, 14], ["HAIL", 13, 12]],
}

# category value (dn) -> [code, card fill, text color, full name, level 0-5]
CATS = {
    2: ["TSTM", "#C1E9C1", "#C1E9C1", "T-STORMS", 0],
    3: ["MRGL", "#0B7A2E", "#1FA84A", "MARGINAL", 1],
    4: ["SLGT", "#F6F700", "#F6F700", "SLIGHT", 2],
    5: ["ENH", "#FF9A00", "#FF9A00", "ENHANCED", 3],
    6: ["MDT", "#E81C1C", "#FF3B30", "MODERATE", 4],
    8: ["HIGH", "#FF40FF", "#FF40FF", "HIGH", 5],
}
NO_TSTM = ["NONE", CARD_OFF, GRAY, "NO STORMS", -1]

# ladder rung colors, level 1 (bottom) to 5 (top)
LEVEL_COLORS = ["#1FA84A", "#F6F700", "#FF9A00", "#FF3B30", "#FF40FF"]

WEEKDAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

# 22x18 storm cloud: L highlight, G body, D underside, Y bolt, B rain
CLOUD = """
........LLLL..........
......LLGGGGLL........
.....LGGGGGGGGL.LLL...
....LGGGGGGGGGGLGGGL..
..LLGGGGGGGGGGGGGGGGL.
.LGGGGGGGGGGGGGGGGGGGL
LGGGGGGGGGGGGGGGGGGGGL
LGGGGGGGGGGGGGGGGGGGGL
.DDDDDDDDDDDDDDDDDDDD.
..DDDDDDYYYYDDDDDDDD..
.......YYYY...........
......YYYY.....B...B..
.....YYYYYYY..B...B...
.........YY..B...B....
........YY............
.......YY.....B...B...
......YY.....B...B....
......Y...............
"""
CLOUD_LEGEND = {"L": "#D8DEE8", "G": "#8A93A3", "D": "#4E5664", "Y": "#FFD400", "B": "#4FA3FF"}

# 9x9 hazard glyphs, all drawn in one tint ("X")
GLYPH_W = 9
TORNADO = """
XXXXXXXXX
.XXXXXXX.
..XXXXXX.
..XXXXX..
...XXXX..
...XXX...
....XX...
...XX....
...X.....
"""
WIND = """
......XX.
XXXXXX..X
........X
XXXXXXXX.
.........
XXXXXXXX.
........X
......XX.
.........
"""
HAIL = """
.XXX.....
XXXXX....
XXXXX.XX.
.XXX.XXXX
.....XXXX
.XX...XX.
XXXX.....
XXXX.....
.XX......
"""
GLYPHS = {"TORN": TORNADO, "WIND": WIND, "HAIL": HAIL}

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

def _zip(ctx):
    z = str(ctx.inputs.get("zip", DEFAULT_ZIP) or "").strip()
    if z == "":
        z = DEFAULT_ZIP
    return z

# {"state": ok|bad|us|offline, "lat", "lon", "name"}
def _where(ctx):
    z = _zip(ctx)
    if len(z) != 5 or not z.isdigit():
        return {"state": "bad"}
    resp = http.get(ZIPAPI + z, ttl_seconds = 86400)
    if resp["status_code"] == 404:
        return {"state": "bad"}
    if resp["status_code"] != 200:
        return {"state": "offline"}
    body = resp["json"]
    if type(body) != "dict" or not body.get("places"):
        return {"state": "bad"}
    p = body["places"][0]
    lat = str(p.get("latitude", ""))
    lon = str(p.get("longitude", ""))
    if lat == "" or lon == "":
        return {"state": "bad"}
    flat = float(lat)
    flon = float(lon)
    if flat < 24.0 or flat > 50.0 or flon < -125.5 or flon > -66.0:
        return {"state": "us"}
    return {
        "state": "ok",
        "lat": lat,
        "lon": lon,
        "city": str(p.get("place name", "")).upper(),
        "st": str(p.get("state abbreviation", "")).upper(),
        "zip": z,
    }

# City and state when they fit, else the city alone, clipped with ".."
def _place(c, w, font, maxw):
    full = w["city"] + " " + w["st"]
    if c.text_width(full, font) <= maxw:
        return full
    if c.text_width(w["city"], font) <= maxw:
        return w["city"]
    return _clip(c, w["city"], font, maxw - c.text_width("..", font)).rstrip(" ,-") + ".."

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

# [[label, probability %, CIG level], ...] for one day
def _hazard_rows(data, day):
    rows = []
    for spec in HAZARDS[day]:
        rows.append([spec[0], _max_dn(data.get(spec[1], [])), _cig_level(data.get(spec[2], []))])
    return rows

# SPC probability palette, banded so the tint and the number never disagree
def _prob_color(p):
    if p <= 0:
        return DIM
    if p <= 2:
        return "#1FA84A"
    if p <= 5:
        return "#C8955A"
    if p <= 10:
        return "#F6F700"
    if p <= 15:
        return "#FF9A00"
    if p <= 30:
        return "#FF3B30"
    if p <= 45:
        return "#FF40FF"
    return "#A070FF"

def _days_from_civil(y, m, d):
    if m <= 2:
        y -= 1
    era = y // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

# SPC days run 12Z to 12Z, so before 12Z "Day 1" is still yesterday's UTC date
def _weekday(ctx, day):
    n = _days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    if ctx.now.hour < 12:
        n -= 1
    return WEEKDAYS[(n + day - 1 + 4) % 7]

def _clip(c, s, font, maxw):
    for n in range(len(s), 0, -1):
        if c.text_width(s[:n], font) <= maxw:
            return s[:n]
    return ""

def _fit(c, s, fonts, maxw):
    for f in fonts:
        if c.text_width(s, f) <= maxw:
            return [s, f]
    f = fonts[len(fonts) - 1]
    return [_clip(c, s, f, maxw), f]

# center s between x0 and x1 (inclusive)
def _ctext(c, s, x0, x1, y, font, color):
    c.text(s, x0 + (x1 - x0 + 1 - c.text_width(s, font)) // 2, y, font = font, color = color)

# Two short lines: what happened, then what to do
def _msg(c, line1, line2):
    c.fill(NODATA_BG)
    if c.width >= 128:
        c.sprite(CLOUD, 12, 7, legend = CLOUD_LEGEND)
        _ctext(c, line1, 40, 179, 7, "6x8", NODATA_TITLE)
        _ctext(c, line2, 40, 179, 19, "4x5", NODATA_SUB)
        return
    t = _fit(c, line1, ["6x8", "5x7", "4x5"], 62)
    _ctext(c, t[0], 0, 63, 8, t[1], NODATA_TITLE)
    _ctext(c, line2, 0, 63, 20, "4x5", NODATA_SUB)

# Resolves the location, or draws the matching message and returns None
def _gate(c, ctx):
    w = _where(ctx)
    if w["state"] == "bad":
        _msg(c, "BAD ZIP", "CHECK ZIP")
        return None
    if w["state"] == "us":
        _msg(c, "US ONLY", "LOWER 48")
        return None
    if w["state"] == "offline":
        _msg(c, "NO DATA", "WILL RETRY")
        return None
    return w

def _layers_or_msg(c, w):
    data = _layers(w)
    if data == None:
        _msg(c, "NO DATA", "WILL RETRY")
    return data

# Five rungs, bottom = MRGL; rungs at or below the level light up, the rest
# stay as dim slots so the whole scale is always readable.
def _ladder(c, x0, x1, y_top, y_bot, level):
    gap = 1
    h = (y_bot - y_top + 1 - 4 * gap) // 5
    for i in range(5):
        y1 = y_bot - i * (h + gap)
        y0 = y1 - h + 1
        if i < level:
            c.rect(x0, y0, x1, y1, fill = LEVEL_COLORS[i])
        else:
            c.rect(x0, y0, x1, y1, fill = CARD_OFF, outline = DIM)

def _pill(c, s, x1, y0, color):
    w = c.text_width(s, "4x5") + 6
    x0 = x1 - w + 1
    y1 = y0 + 8
    c.rect(x0, y0, x1, y1, outline = color)
    c.pixel(x0, y0, "black")
    c.pixel(x1, y0, "black")
    c.pixel(x0, y1, "black")
    c.pixel(x1, y1, "black")
    c.text(s, x0 + 3, y0 + 2, font = "4x5", color = color)
    return x0

# One Days 1-3 card: weekday over a category-colored tile over the code.
# The tile carries the SPC level (1-5), a bolt for general thunder, or a dash.
def _day_card(c, ctx, x0, x1, day, dn, tile_y0, tile_y1, digit_font):
    info = _cat_info(dn)
    wd = _weekday(ctx, day)
    _ctext(c, wd, x0, x1, 1, "4x5", WHITE if day == 1 else GRAY)
    if info[4] < 0:
        c.rect(x0, tile_y0, x1, tile_y1, fill = CARD_OFF, outline = DIM)
        cy = (tile_y0 + tile_y1) // 2
        c.line((x0 + x1) // 2 - 3, cy, (x0 + x1) // 2 + 3, cy, DIM)
    else:
        c.rect(x0, tile_y0, x1, tile_y1, fill = info[1])
        if info[4] == 0:
            c.bitmap(BOLT, (x0 + x1) // 2 - 2, (tile_y0 + tile_y1) // 2 - 3, "black")
        else:
            s = str(info[4])
            x = x0 + (x1 - x0 + 1 - c.text_width(s, digit_font)) // 2
            y = tile_y0 + (tile_y1 - tile_y0 + 1 - FONTH[digit_font]) // 2
            c.text_stroke(s, x, y, digit_font, WHITE, stroke = "black", thickness = 1)
    _ctext(c, info[0], x0, x1, tile_y1 + 2, "4x5", info[2])

# One hazard column: glyph tinted by probability, the percent, then CIG or a
# probability bar (scaled to 60%, the top of the SPC scale).
def _hazard_col(c, x0, x1, row, y_icon, y_pct, y_foot, pct_fonts):
    col = _prob_color(row[1])
    c.sprite(GLYPHS[row[0]], x0 + (x1 - x0 + 1 - GLYPH_W) // 2, y_icon, legend = {"X": col if row[1] > 0 else GRAY})
    s = "%d%%" % row[1]
    t = _fit(c, s, pct_fonts, x1 - x0 + 1)
    _ctext(c, t[0], x0, x1, y_pct, t[1], WHITE if row[1] > 0 else GRAY)
    if row[2] > 0:
        lvl = min(row[2], 3)
        _ctext(c, "CIG%d" % lvl, x0, x1, y_foot, "4x5", CIG_COLORS[lvl])
    else:
        c.rect(x0 + 1, y_foot + 2, x1 - 1, y_foot + 3, fill = CARD_OFF)
        fillw = (x1 - x0 - 1) * min(row[1], 60) // 60
        if fillw > 0:
            c.rect(x0 + 1, y_foot + 2, x0 + fillw, y_foot + 3, fill = col)

# ------------------------------------------------------------- 192 layouts

def _wide_overview(c, ctx, w):
    data = _layers_or_msg(c, w)
    if data == None:
        return
    c.fill("black")
    c.sprite(CLOUD, 10, 1, legend = CLOUD_LEGEND)

    # title beside the cloud; the place runs under both (x 10-86) so
    # 'OKLAHOMA CITY OK' (79px) only loses its state
    c.text("SPC", 36, 1, font = "10x16", color = WHITE)
    c.text("OUTLOOK", 36, 19, font = "4x5", color = AMBER)
    c.text(_place(c, w, "4x5", 77), 10, 26, font = "4x5", color = WHITE)

    # three cards, 28 wide with a 4px gap, ending at x 181
    for i in range(3):
        x0 = 90 + i * 32
        _day_card(c, ctx, x0, x0 + 27, i + 1, _max_dn(data.get(CAT_LAYER[i + 1], [])), 8, 23, "10x16")

def _wide_day(c, ctx, w, day):
    data = _layers_or_msg(c, w)
    if data == None:
        return
    info = _cat_info(_max_dn(data.get(CAT_LAYER[day], [])))
    md = day == 1 and _md_active(w)
    c.fill("black")

    _ladder(c, 10, 13, 1, 30, info[4])

    # text zone x 17-103: eyebrow, hero name, level. 'ENHANCED' is 87px at
    # 10x16, the widest name, so it ends exactly at x 103.
    c.text("DAY %d  %s" % (day, _weekday(ctx, day)), 17, 1, font = "4x5", color = LABEL)
    if md:
        _pill(c, "MD", 103, 0, AMBER)
    t = _fit(c, info[3], ["10x16", "7x12", "6x8"], 87)
    c.text(t[0], 17, 9 + (16 - FONTH[t[1]]) // 2, font = t[1], color = info[2])
    sub = "LEVEL %d OF 5" % info[4] if info[4] > 0 else ("GENERAL THUNDER" if info[4] == 0 else "NO T-STORMS")
    c.text(sub, 17, 26, font = "4x5", color = GRAY)

    c.vline(105, 1, 30, DIM)

    # hazard zone x 108-181, three 24px columns 1px apart; '45%' is 20px at 6x8
    rows = _hazard_rows(data, day)
    for i in range(3):
        x0 = 108 + i * 25
        _hazard_col(c, x0, x0 + 23, rows[i], 2, 13, 25, ["6x8", "5x7"])

# -------------------------------------------------------------- 64 layouts

def _narrow_title(c, w):
    c.fill("black")
    c.sprite(CLOUD, 1, 1, legend = CLOUD_LEGEND)
    _ctext(c, "SPC", 25, 63, 1, "10x16", WHITE)
    _ctext(c, "OUTLOOK", 25, 63, 19, "4x5", AMBER)
    _ctext(c, _place(c, w, "4x5", 62), 0, 63, 26, "4x5", WHITE)

def _narrow_outlook(c, ctx, data):
    c.fill("black")
    for i in range(3):
        x0 = 1 + i * 21
        _day_card(c, ctx, x0, x0 + 19, i + 1, _max_dn(data.get(CAT_LAYER[i + 1], [])), 8, 23, "7x12")

def _narrow_day1(c, ctx, w, data):
    info = _cat_info(_max_dn(data.get(CAT_LAYER[1], [])))
    c.fill("black")
    _ladder(c, 1, 5, 1, 30, info[4])
    c.text("DAY 1", 9, 1, font = "4x5", color = LABEL)
    if _md_active(w):
        _pill(c, "MD", 62, 0, AMBER)
    t = _fit(c, info[0], ["10x16", "7x12", "6x8"], 54)
    _ctext(c, t[0], 8, 63, 9 + (16 - FONTH[t[1]]) // 2, t[1], info[2])
    _ctext(c, _clip(c, info[3], "4x5", 54), 8, 63, 26, "4x5", GRAY)

def _narrow_hazard(c, ctx, data, day):
    c.fill("black")
    _ctext(c, "DAY %d HAZARDS" % day, 0, 63, 1, "4x5", LABEL)
    rows = _hazard_rows(data, day)
    for i in range(3):
        x0 = 1 + i * 21
        # '45%' is 20px at 6x8 and filled the 20px column edge to edge, so the
        # three numbers ran together; 5x7 leaves a gap between them
        _hazard_col(c, x0, x0 + 19, rows[i], 7, 17, 25, ["5x7", "4x5"])

# ------------------------------------------------------------------ pages
# 64 build: title, outlook, day1, hazard1, hazard2
# 192 build: overview, day1, day2
# Each page also answers at the other width, so either manifest works.

def title(c, ctx):
    w = _gate(c, ctx)
    if w == None:
        return
    if c.width >= 128:
        _wide_overview(c, ctx, w)
        return
    _narrow_title(c, w)

def overview(c, ctx):
    title(c, ctx)

def outlook(c, ctx):
    w = _gate(c, ctx)
    if w == None:
        return
    if c.width >= 128:
        _wide_overview(c, ctx, w)
        return
    data = _layers_or_msg(c, w)
    if data == None:
        return
    _narrow_outlook(c, ctx, data)

def day1(c, ctx):
    w = _gate(c, ctx)
    if w == None:
        return
    if c.width >= 128:
        _wide_day(c, ctx, w, 1)
        return
    data = _layers_or_msg(c, w)
    if data == None:
        return
    _narrow_day1(c, ctx, w, data)

def _hazard_page(c, ctx, day):
    w = _gate(c, ctx)
    if w == None:
        return
    if c.width >= 128:
        _wide_day(c, ctx, w, day)
        return
    data = _layers_or_msg(c, w)
    if data == None:
        return
    _narrow_hazard(c, ctx, data, day)

def hazard1(c, ctx):
    _hazard_page(c, ctx, 1)

def hazard2(c, ctx):
    _hazard_page(c, ctx, 2)

def day2(c, ctx):
    _hazard_page(c, ctx, 2)
