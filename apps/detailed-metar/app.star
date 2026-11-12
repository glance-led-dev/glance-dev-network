# Detailed METAR -- decoded airport weather for Glance LED V2 (64x32).
#
# A port of "DetailedMETAR" by SamuelSagarino, from the Tidbyt community app
# repository (now tronbyt/apps, apps/detailedmetar), licensed Apache-2.0.
# Ported to the Glance Developer Network by Whit McGhee.
#
# The layout, palette and wind dial follow the original pixel for pixel where
# Glance allows. Changes from the original:
#   - Glance has no animation, so the original's cycling cloud layers became a
#     second page (SKY). Page 1 shows the layer that sets the flight category
#     (the ceiling), plus a "+N" count of the layers on page 2.
#   - Page 2 adds visibility and the altimeter setting.
#   - Flight category comes from the feed's fltCat. The original computed its
#     own and used the HIGHEST broken/overcast layer as the ceiling, so a low
#     ceiling under a higher deck could read as VFR.
#   - Present weather is shown as the METAR code (+TSRA, -FZRA, BR). The
#     original's decoder labelled a thunderstorm at the field "in vicinity".
#   - Calm wind reads CALM, not "VRB @ / Calm".
#   - Temperatures are rounded from tenths, not truncated, so they match the
#     METAR and the Fahrenheit conversion is not off by up to 2 degrees.
#   - Wind can be shown in knots or mph.
#
# Data: aviationweather.gov (NOAA/NWS Aviation Weather Center). Free, no key.

AWC = "https://aviationweather.gov/api/data/metar?format=json&ids="

# METARs are issued hourly, with specials in between when conditions change.
# refresh in manifest.yaml is 600 s; TTL matches it.
TTL = 600

PI = 3.141592653589793
HEXD = "0123456789abcdef"
KT_TO_MPH = 1.15078

# ---- palette (the original's) --------------------------------------------
CAT_LINE = {"VFR": "#62f55f", "MVFR": "#8d87fa", "IFR": "#db3d5d", "LIFR": "#f25ce3"}
CAT_TEXT = {"VFR": "#87fa8b", "MVFR": "#73b8f5", "IFR": "#f5737c", "LIFR": "#e88bf0"}
GRAD = {
    "VFR": ["#9cff97", "#7bf777", "#3bbd38"],
    "MVFR": ["#b5b0ff", "#9f99ff", "#625dd0"],
    "IFR": ["#ff6d8d", "#f05778", "#c93453"],
    "LIFR": ["#ff8ff4", "#f777eb", "#cc36be"],
}
SECOND = "#8cada7"   # secondary text
FACE = [26, 26, 26]  # dial face, #1a1a1a
ORANGE = "#f0a13a"
DEWRED = "#db3d5d"
WINDRED = "#f5737c"
HINT = "#4f6360"     # labels, "+N" hint
RULE = "#1a1a1a"     # hairlines

# Anti-aliased coverage (0-100) of the original's 15 px dial ring and 13 px
# face, measured against Pixlet's rendering of the original app.
DIAL_RING = [
    [  0,   0,   0,   2,  36,  72,  94, 100,  94,  72,  36,   2,   0,   0,   0],
    [  0,   0,  16,  81, 100, 100, 100, 100, 100, 100, 100,  81,  16,   0,   0],
    [  0,  16,  91, 100, 100, 100, 100, 100, 100, 100, 100, 100,  91,  16,   0],
    [  2,  81, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  81,   2],
    [ 36, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  36],
    [ 72, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  72],
    [ 94, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  94],
    [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
    [ 94, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  94],
    [ 72, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  72],
    [ 36, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  36],
    [  2,  81, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  81,   2],
    [  0,  16,  91, 100, 100, 100, 100, 100, 100, 100, 100, 100,  91,  16,   0],
    [  0,   0,  16,  81, 100, 100, 100, 100, 100, 100, 100,  81,  16,   0,   0],
    [  0,   0,   0,   2,  36,  72,  94, 100,  94,  72,  36,   2,   0,   0,   0],
]
DIAL_FACE = [
    [  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0],
    [  0,   0,   0,   0,  25,  67,  92, 100,  92,  67,  25,   0,   0,   0,   0],
    [  0,   0,   2,  61, 100, 100, 100, 100, 100, 100, 100,  61,   2,   0,   0],
    [  0,   0,  61, 100, 100, 100, 100, 100, 100, 100, 100, 100,  61,   0,   0],
    [  0,  25, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  25,   0],
    [  0,  67, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  67,   0],
    [  0,  92, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  92,   0],
    [  0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,   0],
    [  0,  92, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  92,   0],
    [  0,  67, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  67,   0],
    [  0,  25, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  25,   0],
    [  0,   0,  61, 100, 100, 100, 100, 100, 100, 100, 100, 100,  61,   0,   0],
    [  0,   0,   2,  61, 100, 100, 100, 100, 100, 100, 100,  61,   2,   0,   0],
    [  0,   0,   0,   0,  25,  67,  92, 100,  92,  67,  25,   0,   0,   0,   0],
    [  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0],
]

# ---- small helpers ----------------------------------------------------------
def rgb(h):
    t = h.lower()
    if t.startswith("#"):
        t = t[1:]
    return [HEXD.index(t[0]) * 16 + HEXD.index(t[1]),
            HEXD.index(t[2]) * 16 + HEXD.index(t[3]),
            HEXD.index(t[4]) * 16 + HEXD.index(t[5])]

def hexc(r, g, b):
    out = "#"
    for v in [r, g, b]:
        v = int(v + 0.5)
        v = 0 if v < 0 else (255 if v > 255 else v)
        out += HEXD[v // 16] + HEXD[v % 16]
    return out

def fnum(v, fallback = None):
    """A number out of a JSON value that may be int, float, string or null.
    int()/float() raise on junk, and a raised error kills the render."""
    if v == None:
        return fallback
    if type(v) == "int" or type(v) == "float":
        return float(v)
    s = str(v).strip()
    if s == "" or s == "-" or s == ".":
        return fallback
    seen_dot = False
    for i in range(len(s)):
        ch = s[i]
        if ch == "-" and i == 0:
            continue
        if ch == "." and not seen_dot:
            seen_dot = True
            continue
        if ch < "0" or ch > "9":
            return fallback
    return float(s)

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, None)
    return fallback if v == None else v

def rnd(x):
    """Round half away from zero, as a METAR rounds tenths."""
    return int(x + 0.5) if x >= 0 else -int(-x + 0.5)

def fit(c, text, fonts, maxw):
    """[font, text]: the largest listed font that fits, else the smallest one
    hard-clipped. Nothing in the Glance API clips."""
    t = str(text)
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            return [f, t]
    f = fonts[len(fonts) - 1]
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], f) <= maxw:
            return [f, t[:k]]
    return [f, ""]

SMALL = ["4x5", "3x4"]

def fit_wx(c, wx, maxw):
    """fit() for a weather group: a clipped code loses whole two-letter codes,
    so -FZRAPL becomes -FZRA, never -FZRAP."""
    w = fit(c, wx, SMALL, maxw)
    if w[1] == wx:
        return w
    p = 2 if wx.startswith("VC") else (1 if wx[:1] in ["+", "-"] else 0)
    keep = p + ((len(w[1]) - p) // 2) * 2
    return fit(c, wx[:keep], SMALL, maxw)

# ---- data -------------------------------------------------------------------
def ceiling_of(layers):
    """Lowest broken, overcast or obscured (vertical visibility) layer, or -1.
    Scattered cloud has gaps and never forms a ceiling."""
    ceil = -1
    for L in layers:
        if L[0] in ["BKN", "OVC", "OVX"] and L[1] >= 0:
            if ceil < 0 or L[1] < ceil:
                ceil = L[1]
    return ceil

def vis_value(v):
    if str(v).strip().endswith("+"):
        return 10.0
    return fnum(v, 10.0)

def category(ceil, vis):
    """FAA flight categories, used only if the feed omits fltCat."""
    c = ceil if ceil >= 0 else 99999
    if c < 500 or vis < 1:
        return "LIFR"
    if c < 1000 or vis < 3:
        return "IFR"
    if c <= 3000 or vis <= 5:
        return "MVFR"
    return "VFR"

def decode(d):
    layers = []
    for cl in get(d, "clouds", []):
        cv = str(get(cl, "cover", "")).upper()
        if cv == "":
            continue
        layers.append([cv, int(fnum(get(cl, "base", None), -1))])
    vis = vis_value(get(d, "visib", "10+"))
    cat = str(get(d, "fltCat", "")).upper()
    if cat not in CAT_LINE:
        cat = category(ceiling_of(layers), vis)
    wdir = get(d, "wdir", None)
    wdir = "VRB" if str(wdir).upper() == "VRB" else int(fnum(wdir, 0))
    wx = str(get(d, "wxString", "")).strip().upper()
    return {
        "id": str(get(d, "icaoId", "")).upper(),
        "cat": cat,
        "temp": fnum(get(d, "temp", None)),
        "dewp": fnum(get(d, "dewp", None)),
        "wdir": wdir,
        "wspd": int(fnum(get(d, "wspd", 0), 0)),
        "wgst": int(fnum(get(d, "wgst", 0), 0)),
        "wx": wx.split(" ")[0] if wx != "" else "",
        "vis_raw": str(get(d, "visib", "")),
        "vis": vis,
        "altim": fnum(get(d, "altim", None)),
        "layers": layers,
        "ceil": ceiling_of(layers),
        "obs": int(fnum(get(d, "obsTime", 0), 0)),
    }

def clean_id(raw):
    s = str(raw).strip().upper()
    out = ""
    for i in range(len(s)):
        ch = s[i]
        if (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9"):
            out += ch
        elif ch != " ":
            return None
    return out

def read_report(ctx):
    """{"state": ok|setup|badcode|nostation|offline|error, ...}"""
    ids = clean_id(ctx.inputs.get("airport", ""))
    if ids == "":
        return {"state": "setup"}
    if ids == None or len(ids) != 4:
        return {"state": "badcode", "id": ids or ""}
    r = http.get(AWC + ids, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return {"state": "offline", "id": ids}
    if r["status_code"] == 204:
        return {"state": "nostation", "id": ids}
    if r["status_code"] != 200:
        return {"state": "error", "id": ids, "code": r["status_code"]}
    j = r["json"]
    if type(j) != "list" or len(j) == 0 or type(j[0]) != "dict":
        return {"state": "nostation", "id": ids}
    return {"state": "ok", "m": decode(j[0])}

# ---- the shared no-data card (catalog standard, narrow form) ---------------
def nodata(c, title, sub):
    c.fill("#0B0C12")
    maxw = c.width - 6
    t = fit(c, title, ["6x8", "5x7", "4x5"], maxw)
    c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A", align = "center")
    d = fit(c, sub, ["4x5"], maxw)
    c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090", align = "center")

def failed(c, st):
    s = st["state"]
    if s == "ok":
        return False
    if s == "setup":
        nodata(c, "NO AIRPORT", "ENTER ICAO")
    elif s == "badcode":
        nodata(c, "BAD CODE", "4 LETTERS")
    elif s == "nostation":
        nodata(c, "NO METAR", "CHECK " + st["id"])
    elif s == "offline":
        nodata(c, "NO DATA", "AWC OFFLINE")
    else:
        nodata(c, "NO DATA", "AWC ERR " + str(st["code"]))
    return True

# ---- formatting ---------------------------------------------------------------
def base_text(b):
    """Cloud base in feet. Above 10,000 ft a METAR reports bases to the
    nearest 1,000 ft, so "12K" is exact and keeps SCT and 12000 from
    running together on a 64-pixel row."""
    if b >= 10000 and b % 1000 == 0:
        return str(b // 1000) + "K"
    return str(b)

def layer_color(base):
    """Cloud base colour by the category it implies."""
    if base < 0:
        return SECOND
    if base < 500:
        return "#e88bf0"
    if base < 1000:
        return "#f5737c"
    if base <= 3000:
        return "#73b8f5"
    return SECOND

def vis_color(v):
    if v < 1:
        return "#e88bf0"
    if v < 3:
        return "#f5737c"
    if v <= 5:
        return "#73b8f5"
    return SECOND

def wind_color(m):
    """Thresholds are in knots whatever the display unit."""
    if m["wspd"] >= 30:
        return WINDRED
    if m["wspd"] >= 20:
        return ORANGE
    return SECOND

def speed_text(m, unit):
    def conv(k):
        return rnd(k * KT_TO_MPH) if unit == "MPH" else k
    s = str(conv(m["wspd"]))
    if m["wgst"] > 0:
        s += "G" + str(conv(m["wgst"]))
    return s + ("MPH" if unit == "MPH" else "KT")

def temp_text(m, units):
    t, d = m["temp"], m["dewp"]
    if t == None or d == None:
        return ["--/--", SECOND]
    tc, dc = rnd(t), rnd(d)
    col = SECOND
    if dc >= tc - 4 and dc <= tc + 4:
        col = ORANGE           # spread within 4 C: fog / low cloud watch
    if dc == tc:
        col = DEWRED           # saturated
    if units == "F":
        tc, dc = rnd(t * 9.0 / 5.0 + 32), rnd(d * 9.0 / 5.0 + 32)
    return [str(tc) + "/" + str(dc), col]

def age_text(ctx, m):
    if m["obs"] <= 0:
        return ["", SECOND]
    mins = (ctx.now.unix - m["obs"]) // 60
    if mins < 0:
        mins = 0
    col = ORANGE if mins > 90 else HINT       # dim: secondary; orange when stale (>90 min)
    if mins < 100:
        return [str(mins) + "MIN", col]
    if mins < 2880:
        return [str(mins // 60) + "HR", col]
    return [str(mins // 1440) + "DAY", col]

def vis_text(m):
    r = m["vis_raw"].strip()
    if r.endswith("+"):
        return r + "SM"
    v = m["vis"]
    FR = {0.125: "1/8", 0.25: "1/4", 0.5: "1/2", 0.75: "3/4"}
    if v in FR:
        return FR[v] + "SM"
    if v == int(v):
        return str(int(v)) + "SM"
    t = int(v * 10 + 0.5)
    return str(t // 10) + "." + str(t % 10) + "SM"

def altim_text(m):
    """Feed is hPa. US (K/P) stations get inches of mercury, as dialled into
    an altimeter there; everywhere else gets hPa."""
    a = m["altim"]
    if a == None or a <= 0:
        return "--"
    if m["id"].startswith("K") or m["id"].startswith("P"):
        h = int(a * 100.0 / 33.8639 + 0.5)
        return str(h // 100) + "." + fmt.pad(h % 100, 2)
    return str(int(a + 0.5))

# ---- wind dial (geometry ported from the original) -----------------------------
DX, DY = 25, 3   # the original's dial position

def draw_dial(c, cat):
    col = rgb(CAT_LINE[cat])
    for y in range(15):
        for x in range(15):
            ao = DIAL_RING[y][x] / 100.0
            ai = DIAL_FACE[y][x] / 100.0
            if ao == 0:
                continue
            p = [col[k] * ao * (1 - ai) + FACE[k] * ai for k in range(3)]
            c.pixel(DX + x, DY + y, hexc(p[0], p[1], p[2]))

def fill_px(x, y, ux, uy, ch2):
    if x == 7 and y == 7:
        return True
    hits = 0
    for sy in [0.2, 0.5, 0.8]:
        for sx in [0.2, 0.5, 0.8]:
            dx = x + sx - 7.5
            dy = y + sy - 7.5
            d2 = dx * dx + dy * dy
            if d2 > 56.25:
                continue
            dot = dx * ux + dy * uy
            if dot < 0:
                continue
            if dot * dot >= d2 * ch2:
                hits += 1
    return hits >= 4

def wedge_color(x, y, ux, uy, g, base):
    dx = x + 0.5 - 7.5
    dy = y + 0.5 - 7.5
    fwd = dx * ux + dy * uy
    lat = dx * (-uy) + dy * ux
    lat = -lat if lat < 0 else lat
    hi, mid, sh = g[0], g[1], g[2]
    if fwd >= 5.0:
        col = hi
    elif fwd >= 3.7:
        col = mid
    elif fwd >= 2.4:
        col = base
    else:
        col = sh
    if lat >= 1.9 and fwd >= 2.0:
        if col == hi:
            col = mid
        elif col == mid:
            col = base
        elif col == base:
            col = sh
    return col

def draw_wedge(c, m):
    """A wedge pointing to where the wind blows FROM, in 30-degree steps."""
    d = m["wdir"]
    if d == "VRB" or d == 0 or m["wspd"] <= 0:
        return
    q = ((d % 360 + 15) // 30) * 30 % 360
    th = q * PI / 180.0
    ux, uy = math.sin(th), -math.cos(th)
    ch = math.cos(32 * PI / 180.0)
    ch2 = ch * ch
    g = GRAD[m["cat"]]
    base = CAT_LINE[m["cat"]]
    for y in range(15):
        for x in range(15):
            if fill_px(x, y, ux, uy, ch2):
                c.pixel(DX + x, DY + y, wedge_color(x, y, ux, uy, g, base))

# ---- page 1: METAR -------------------------------------------------------------
def page_layer(m):
    """The one layer page 1 has room for: the ceiling, else the lowest."""
    L = m["layers"]
    if len(L) == 0:
        return None
    if m["ceil"] >= 0:
        for l in L:
            if l[1] == m["ceil"] and l[0] in ["BKN", "OVC", "OVX"]:
                return l
    return L[0]

def metar(c, ctx):
    c.fill("black")
    st = read_report(ctx)
    if failed(c, st):
        return
    m = st["m"]
    units = ctx.inputs.get("units", "F")
    wunit = ctx.inputs.get("windunits", "KT")
    cat = m["cat"]
    c.rect(0, 0, 63, 1, fill = CAT_LINE[cat])

    # Station and present weather (x 0-23)
    sid = fit(c, m["id"], ["5x7", "4x5"], 23)
    if m["wx"] != "":
        c.text(sid[1], 11, 3, font = sid[0], color = CAT_TEXT[cat], align = "center")
        c.rect(1, 11, 22, 11, fill = RULE)
        w = fit_wx(c, m["wx"], 24)
        c.text(w[1], 12, 12, font = w[0], color = CAT_TEXT[cat], align = "center")
    else:
        c.text(sid[1], 11, 6, font = sid[0], color = CAT_TEXT[cat], align = "center")

    # Wind dial
    draw_dial(c, cat)
    draw_wedge(c, m)

    # Temperature / dew point and report age (x 41-63)
    tt = temp_text(m, units)
    w = fit(c, tt[0], SMALL, 23)
    c.text(w[1], 52, 3, font = w[0], color = tt[1], align = "center")
    at = age_text(ctx, m)
    c.text(at[0], 52, 11, font = "3x4", color = at[1], align = "center")

    # Wind (bottom left)
    wc = wind_color(m)
    if m["wspd"] <= 0:
        c.text("WIND", 16, 19, font = "4x5", color = HINT, align = "center")
        c.text("CALM", 16, 26, font = "4x5", color = SECOND, align = "center")
    else:
        head = "VRB" if m["wdir"] == "VRB" else fmt.pad(m["wdir"], 3)
        c.text(head + " @", 16, 19, font = "4x5", color = wc, align = "center")
        w = fit(c, speed_text(m, wunit), SMALL, 33)
        c.text(w[1], 16, 26, font = w[0], color = wc, align = "center")

    # Cloud layer that sets the category (bottom right)
    L = page_layer(m)
    if L == None:
        c.text("CLR", 47, 19, font = "4x5", color = SECOND, align = "center")
    else:
        lc = layer_color(L[1])
        w = fit(c, L[0], SMALL, 15)
        c.text(w[1], 47, 19, font = w[0], color = lc, align = "center")
        if L[1] >= 0:
            c.text(base_text(L[1]), 47, 26, font = "4x5", color = lc, align = "center")
    extra = len(m["layers"]) - 1
    if extra > 0:
        c.text("+" + str(extra), 64, 19, font = "3x4", color = HINT, align = "right")

# ---- page 2: SKY ---------------------------------------------------------------
ROWS = [4, 11, 18, 25]

def sky(c, ctx):
    c.fill("black")
    st = read_report(ctx)
    if failed(c, st):
        return
    m = st["m"]
    c.rect(0, 0, 63, 1, fill = CAT_LINE[m["cat"]])

    L = m["layers"]
    if len(L) == 0:
        c.text("CLR", 0, ROWS[0], font = "4x5", color = SECOND)
    shown = L if len(L) <= 4 else L[:3]
    for i in range(len(shown)):
        cv, b = shown[i][0], shown[i][1]
        lc = layer_color(b)
        w = fit(c, cv, SMALL, 15)
        c.text(w[1], 0, ROWS[i], font = w[0], color = lc)
        if b >= 0:
            c.text(base_text(b), 37, ROWS[i], font = "4x5", color = lc, align = "right")
    if len(L) > 4:
        c.text("+" + str(len(L) - 3) + " MORE", 37, ROWS[3], font = "4x5",
               color = HINT, align = "right")

    c.rect(39, 4, 39, 28, fill = RULE)

    c.text("VIS", 52, ROWS[0], font = "4x5", color = HINT, align = "center")
    w = fit(c, vis_text(m), SMALL, 23)
    c.text(w[1], 52, ROWS[1], font = w[0], color = vis_color(m["vis"]), align = "center")
    c.text("ALT", 52, ROWS[2], font = "4x5", color = HINT, align = "center")
    c.text(altim_text(m), 52, ROWS[3], font = "4x5", color = SECOND, align = "center")