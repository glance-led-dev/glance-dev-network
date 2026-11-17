# Detailed METAR
#
# DESIGN. The latest airport observation, one idea per page, with the flight
# category carried on every page as a coloured header strip (the original
# app's top stripe, grown into a header). Each page leads with one hero:
#
#   METAR  the flight category word (VFR / MVFR / IFR / LIFR) beside a
#          pixel-art picture of the sky, and the one value that set the
#          category: the ceiling or the visibility, whichever is worse.
#   TEMP   temperature as the hero, dew point beside it (amber when the two
#          are close, red when equal: the air is saturated and fog forms),
#          and the altimeter setting.
#   WIND   a compass dial with the original's wedge pointing to where the wind
#          comes from, and the speed as the hero; gust and bearing below.
#   SKY    the cloud layers, lowest first, the ceiling in the category colour,
#          then visibility and present weather.
#
# The header strip is the same on every page: a black airplane and the ICAO
# code on the left (location and identity), the page name on the right (the
# observation time in UTC, e.g. 2053Z, on the METAR page). Black on a bright LED colour: contrast is
# 6:1 or better for all four categories (WCAG ratio, black text).
#
# Based on DetailedMETAR by SamuelSagarino (Tidbyt community apps, now
# tronbyt/apps, apps/detailedmetar, Apache-2.0). Rebuilt for the GDN design
# guidelines: one hero per page, every number labelled, LED-tuned colours,
# pixel-perfect art with no anti-aliasing, and designed error / empty states.
# Fixes carried from the first port: the category comes from the feed's
# fltCat (the original took the HIGHEST broken/overcast layer as the
# ceiling), a thunderstorm at the field is not "in vicinity", calm wind reads
# CALM, and temperatures are rounded from tenths, not truncated.
#
# Grid (64x32), the same on every page:
#   y 0-6    header strip, category colour; 4x5 black text on rows 1-5
#   y 7-8    gap
#   y 9-23   hero (10x16 ink is 15 rows); pixel art may use y 8-24
#   y 24-25  gap
#   y 26-30  footer row, 4x5: grey label left, white value right
# SKY is a list instead: four 4x5 rows at y 8, 14, 20, 26.
#
# States. Live; empty (calm wind reads CALM in green, a cloudless sky reads
# NO CLOUDS in green); error (the shared no-data card, one message per cause:
# no airport, malformed code, no report, NWS unreachable, HTTP error, bad
# data). The feed is free and keyless, so there is no demo state.
#
# Data: aviationweather.gov (NOAA/NWS Aviation Weather Center), no key.

AWC = "https://aviationweather.gov/api/data/metar?format=json&ids="

# manifest refresh is 900 s; the fetch's ttl matches it.
TTL = 900

KT_TO_MPH = 1.15078
PI = 3.141592653589793

# ---- colour ---------------------------------------------------------------
# FAA flight-category colours, LED-tuned. Contrast of black text on each
# (WCAG): VFR 11.3, MVFR 6.3, IFR 5.3, LIFR 6.1, unknown 4.9.
CATS = {
    "VFR": "#00DC46",    # GDN named green
    "MVFR": "#2B8CFF",
    "IFR": "#FF0000",    # GDN named red
    "LIFR": "#FF00C8",   # GDN named magenta
}
NOCAT = "#6E7A94"        # no category in the report

INK = "white"            # live values
LABEL = "gray"           # labels: (150,150,150), 6.9:1 on black
RING = "#505A66"         # dial ring: structure, not text
OK = "green"
WARN = "amber"
ALARM = "red"

FONTH = {"10x16": 16, "9x12_bold": 12, "9x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# ---- layout ---------------------------------------------------------------
STRIP_H = 7      # header strip rows 0-6
TOP = 8          # first content row (lists, dial)
HERO = 9         # hero top: 15 rows of ink (y 9-23), 2 clear rows either side
FOOT = 26        # footer row (4x5 ends at y 30)
RIGHT = 62       # right edge for right-aligned text (1 px margin)

# ---- pixel art --------------------------------------------------------------
# Header airplane, top view, drawn in black on the strip.
PLANE = [
    "..#..",
    ".###.",
    "#####",
    "..#..",
    ".###.",
]

ICON_LEGEND = {
    "y": "#FFDC50",   # sun (GDN named yellow)
    "m": "#FFECAA",   # moon
    "w": "#EBF0F5",   # fair-weather cloud
    "g": "#AAB2BE",   # overcast / rain cloud
    "b": "#78DCFF",   # rain (GDN named skyblue)
    "s": "white",     # snow
    "l": "#FFBF00",   # lightning (GDN named amber)
    "f": "gray",      # fog bands
}

# Sky pictures, at native size. Each is drawn centred in the zone right
# of the category word (x 45-63, y 8-24).

SUN = [
    ".......y.......",
    ".......y.......",
    "..y.........y..",
    "...y.......y...",
    ".....yyyyy.....",
    "....yyyyyyy....",
    "....yyyyyyy....",
    "yy..yyyyyyy..yy",
    "....yyyyyyy....",
    "....yyyyyyy....",
    ".....yyyyy.....",
    "...y.......y...",
    "..y.........y..",
    ".......y.......",
    ".......y.......",
]

MOON = [
    ".....mm......",
    "...mmm.......",
    "..mmm........",
    ".mmmm........",
    ".mmmm........",
    "mmmmm........",
    "mmmmm........",
    "mmmmmm.......",
    ".mmmmmm......",
    ".mmmmmmm...m.",
    "..mmmmmmmmm..",
    "...mmmmmmm...",
    ".....mmm.....",
]

PARTSUN = [
    "............y....",
    ".........y.....y.",
    "...........yyy...",
    "..........yyyyy..",
    "........y.yyyyy.y",
    "..........yyyyy..",
    "...........yyy...",
    "......wwww.....y.",
    ".....wwwwww......",
    "..ww.wwwwwww.....",
    ".wwwwwwwwwwwww...",
    "wwwwwwwwwwwwwww..",
    "wwwwwwwwwwwwwwww.",
    "wwwwwwwwwwwwwwww.",
    ".wwwwwwwwwwwwww..",
]

PARTMOON = [
    "...........mm....",
    ".........mmm.....",
    ".........mmm.....",
    "........mmmm.....",
    "........mmmm.....",
    "........mmmm.....",
    "...........mmm...",
    "......wwww..mmmm.",
    ".....wwwwww..m...",
    "..ww.wwwwwww.....",
    ".wwwwwwwwwwwww...",
    "wwwwwwwwwwwwwww..",
    "wwwwwwwwwwwwwwww.",
    "wwwwwwwwwwwwwwww.",
    ".wwwwwwwwwwwwww..",
]

CLOUD = [
    "......gggg......",
    ".....gggggg.....",
    "..gg.ggggggg....",
    ".ggggggggggggg..",
    "ggggggggggggggg.",
    "gggggggggggggggg",
    "gggggggggggggggg",
    ".gggggggggggggg.",
]

RAIN = [
    "......gggg......",
    ".....gggggg.....",
    "..gg.ggggggg....",
    ".ggggggggggggg..",
    "ggggggggggggggg.",
    "gggggggggggggggg",
    "gggggggggggggggg",
    ".gggggggggggggg.",
    "................",
    "..b....b....b...",
    ".b....b....b....",
    "................",
    "....b....b....b.",
    "...b....b....b..",
]

SNOW = [
    "......gggg......",
    ".....gggggg.....",
    "..gg.ggggggg....",
    ".ggggggggggggg..",
    "ggggggggggggggg.",
    "gggggggggggggggg",
    "gggggggggggggggg",
    ".gggggggggggggg.",
    "................",
    "..s......s......",
    ".sss....sss.....",
    "..s......s......",
    ".....s......s...",
    "....sss....sss..",
    ".....s......s...",
]

FREEZE = [
    "......gggg......",
    ".....gggggg.....",
    "..gg.ggggggg....",
    ".ggggggggggggg..",
    "ggggggggggggggg.",
    "gggggggggggggggg",
    "gggggggggggggggg",
    ".gggggggggggggg.",
    "................",
    "..b......s....b.",
    ".b......sss..b..",
    ".........s......",
    "....s.......b...",
    "...sss.....b....",
    "....s...........",
]

STORM = [
    "......gggg......",
    ".....gggggg.....",
    "..gg.ggggggg....",
    ".ggggggggggggg..",
    "ggggggggggggggg.",
    "gggggggggggggggg",
    "gggggggggggggggg",
    ".gggggggggggggg.",
    "................",
    "........lll.....",
    ".......lll......",
    "......lllll.....",
    "........ll......",
    ".......ll.......",
    "......l.........",
]

FOG = [
    "ffffffffffffff..",
    "................",
    "..ffffffffffffff",
    "................",
    "ffffffffffffff..",
    "................",
    "..ffffffffffffff",
    "................",
    "ffffffffffffff..",
]

# ---- safe readers -------------------------------------------------------------
# A raised error kills the whole render, so every value out of the feed comes
# through one of these.

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def fnum(v, fallback = None):
    """A number out of a JSON value that may be int, float, string or null."""
    if v == None:
        return fallback
    if type(v) == "int" or type(v) == "float":
        return float(v)
    t = str(v).strip()
    if t == "":
        return fallback
    dot = False
    for i in range(len(t)):
        ch = t[i]
        if (ch == "-" or ch == "+") and i == 0:
            continue
        if ch == "." and not dot:
            dot = True
            continue
        if ch < "0" or ch > "9":
            return fallback
    if t in ["-", "+", ".", "-.", "+."]:
        return fallback
    return float(t)

def rnd(x):
    """Round half away from zero, the way a METAR rounds tenths."""
    return int(x + 0.5) if x >= 0 else -int(-x + 0.5)

def commas(n):
    s = str(n)
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return out

# ---- text fitting ---------------------------------------------------------------

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw`. Nothing in the API clips."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    """[font, text]: the largest listed font that fits, hard-clipped if none do."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

def draw_deg(c, x, y, color, big = False):
    """The fonts have no degree sign. Small: 3x3 ring. Big: 4x4 ring."""
    if big:
        c.line(x + 1, y, x + 2, y, color)
        c.line(x + 1, y + 3, x + 2, y + 3, color)
        c.line(x, y + 1, x, y + 2, color)
        c.line(x + 3, y + 1, x + 3, y + 2, color)
    else:
        c.pixel(x + 1, y, color)
        c.pixel(x, y + 1, color)
        c.pixel(x + 2, y + 1, color)
        c.pixel(x + 1, y + 2, color)

def deg_width(c, s, font):
    """Width of a number plus a small degree mark."""
    return c.text_width(s, font) + 1 + 3

def label_value(c, label, value, y, vcolor = INK):
    """Footer / list row: grey label at the left, value right-aligned.
    The value is measured first; the label gets what is left."""
    vw = c.text_width(value, "4x5")
    if vw > RIGHT - 1:
        value = clip(c, value, "4x5", RIGHT - 1)
        vw = c.text_width(value, "4x5")
    c.text(value, RIGHT, y, font = "4x5", color = vcolor, align = "right")
    room = RIGHT - vw - 3 - 1
    if label != "" and room > 0:
        c.text(clip(c, label, "4x5", room), 1, y, font = "4x5", color = LABEL)

# ---- shared screens ----------------------------------------------------------------

NODATA_FONTS = ["6x8", "5x7", "4x5"]

def nodata(c, title, sub):
    """The shared no-data card, narrow form: amber title on rows 5-12,
    slate detail on rows 18-22, on bands that can never overlap."""
    c.fill("#0B0C12")
    maxw = c.width - 6
    t = fit(c, title, NODATA_FONTS, maxw)
    c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A", align = "center")
    d = fit(c, sub, ["4x5"], maxw)
    c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090", align = "center")

def fail(c, st):
    s = st["state"]
    if s == "ok":
        return False
    if s == "setup":
        nodata(c, "NO AIRPORT", "ADD A CODE")
    elif s == "badcode":
        nodata(c, "BAD CODE", "USE 4 LETTERS")
    elif s == "nostation":
        nodata(c, "NO REPORT", "CHECK " + clip(c, st["id"], "4x5", 30))
    elif s == "offline":
        nodata(c, "NO DATA", "NWS OFFLINE")
    elif s == "httperr":
        nodata(c, "NWS ERROR", "HTTP " + str(st["code"]))
    else:
        nodata(c, "BAD DATA", "FROM NWS")
    return True

def header(c, m, right):
    """Category-coloured strip: airplane + ICAO left, page word right.
    Plane x 1-5, ICAO from x 7 (4 chars = 20 px, to x 26); the right word
    ends at x 62; the widest right word, "SKY +9", is 26 px (x 37-62)."""
    col = CATS[m["cat"]] if m["cat"] in CATS else NOCAT
    c.rect(0, 0, c.width - 1, STRIP_H - 1, fill = col)
    c.sprite(PLANE, 1, 1, color = "black")
    c.text(clip(c, m["id"], "4x5", 21), 7, 1, font = "4x5", color = "black")
    c.text(clip(c, right, "4x5", 33), RIGHT, 1, font = "4x5", color = "black",
           align = "right")
    return col

# ---- the feed -----------------------------------------------------------------------

def valid_id(s):
    if len(s) != 4:
        return False
    for i in range(4):
        ch = s[i]
        letter = ch >= "A" and ch <= "Z"
        digit = ch >= "0" and ch <= "9"
        if not (letter or (digit and i > 0)):
            return False
    return True

def fetch(ctx):
    ids = str(ctx.inputs.get("airport", "")).strip().upper().replace(" ", "")
    st = {"state": "ok", "id": ids}
    if ids == "":
        st["state"] = "setup"
        return st
    if not valid_id(ids):
        st["state"] = "badcode"
        return st
    r = http.get(AWC + ids, ttl_seconds = TTL)
    sc = r["status_code"]
    if sc == 0:
        st["state"] = "offline"
        return st
    if sc == 204:
        st["state"] = "nostation"
        return st
    if sc != 200:
        st["state"] = "httperr"
        st["code"] = sc
        return st
    j = r["json"]
    if j == None and str(r["body"]).strip() == "":
        st["state"] = "nostation"
        return st
    if type(j) != "list":
        st["state"] = "baddata"
        return st
    if len(j) == 0:
        st["state"] = "nostation"
        return st
    d = j[0]
    if type(d) != "dict":
        st["state"] = "baddata"
        return st
    st["m"] = decode(d, ids)
    return st

def decode(d, ids):
    layers = []
    clouds = get(d, "clouds", [])
    if type(clouds) == "list":
        for cl in clouds:
            if type(cl) != "dict":
                continue
            cv = str(get(cl, "cover", "")).strip().upper()
            if cv == "":
                continue
            b = fnum(get(cl, "base", None), None)
            layers.append([cv, int(b) if b != None else -1])

    # The ceiling is the LOWEST broken, overcast or obscured layer.
    ceil = -1
    for L in layers:
        if L[0] in ["BKN", "OVC", "OVX"] and L[1] >= 0:
            if ceil < 0 or L[1] < ceil:
                ceil = L[1]

    wdir = get(d, "wdir", None)
    wd = None
    vrb = False
    if str(wdir).strip().upper() == "VRB":
        vrb = True
    else:
        n = fnum(wdir, None)
        if n != None:
            wd = int(n) % 360

    vraw = get(d, "visib", None)
    cat = str(get(d, "fltCat", "")).strip().upper()
    return {
        "id": str(get(d, "icaoId", ids)).strip().upper(),
        "cat": cat if cat in CATS else "",
        "temp": fnum(get(d, "temp", None), None),
        "dewp": fnum(get(d, "dewp", None), None),
        "wdir": wd,
        "vrb": vrb,
        "wspd": fnum(get(d, "wspd", None), None),
        "wgst": fnum(get(d, "wgst", None), None),
        "visraw": "" if vraw == None else str(vraw).strip(),
        "vis": fnum(str(vraw).replace("+", "") if vraw != None else None, None),
        "altim": fnum(get(d, "altim", None), None),
        "wx": str(get(d, "wxString", "")).strip().upper(),
        "raw": str(get(d, "rawOb", "")).strip().upper(),
        "layers": layers,
        "ceil": ceil,
        "obs": int(fnum(get(d, "obsTime", 0), 0)),
        "lat": fnum(get(d, "lat", None), None),
        "lon": fnum(get(d, "lon", None), None),
    }

# ---- formatting ------------------------------------------------------------------------

FRAC = {1: "1/8", 2: "1/4", 3: "3/8", 4: "1/2", 5: "5/8", 6: "3/4", 7: "7/8"}

def vis_text(m):
    """Statute miles as pilots write them: 10+, 3, 1 1/2, 1/4."""
    raw = m["visraw"]
    if raw.endswith("+"):
        return raw + " SM"
    v = m["vis"]
    if v == None or v < 0:
        return "--"
    whole = int(v)
    e = int((v - whole) * 8 + 0.5)
    if e == 8:
        whole += 1
        e = 0
    if e == 0:
        out = str(whole)
    elif whole == 0:
        out = FRAC[e]
    else:
        out = str(whole) + " " + FRAC[e]
    return out + " SM"

def base_text(b):
    return "--" if b < 0 else commas(b) + " FT"

def altim_text(m):
    """The setting pilots dial in, in the station's own unit: the raw report
    says A3002 (inches) or Q1013 (hectopascals). Falls back to the feed's hPa."""
    for tok in m["raw"].split(" "):
        if len(tok) == 5 and (tok[0] == "A" or tok[0] == "Q"):
            n = fnum(tok[1:], None)
            if n != None and tok[1:].isdigit():
                v = int(n)
                if tok[0] == "A":
                    return str(v // 100) + "." + str(v % 100 + 100)[1:] + " IN"
                return str(v) + " HPA"
    a = m["altim"]
    if a == None or a <= 0:
        return "--"
    return str(rnd(a)) + " HPA"

def obs_time(obs):
    """When the report was observed, in UTC, as the METAR itself writes it
    (2053Z). A fixed time, not an age: the page is drawn once per refresh and
    then shown for up to 15 minutes, so "17M AGO" would go stale on the
    panel, and Studio's sequence preview (which renders now, +1 and +2
    minutes) splits a per-minute age into METAR 1/2, 2/2 turns."""
    if obs <= 0:
        return "METAR"
    return str((obs // 3600) % 24 + 100)[1:] + str((obs // 60) % 60 + 100)[1:] + "Z"

def wx_codes(c, wx, maxw, font):
    """Present weather clipped at whole groups, never mid-code."""
    out = ""
    for tok in wx.split(" "):
        if tok == "":
            continue
        trial = tok if out == "" else out + " " + tok
        if c.text_width(trial, font) > maxw:
            break
        out = trial
    if out == "" and wx != "":
        out = clip(c, wx.split(" ")[0], font, maxw)
    return out

# ---- category arithmetic --------------------------------------------------------------
# Only used to pick WHICH value explains the category; the category itself is
# the feed's fltCat.

def cig_rank(ft):
    if ft < 0:
        return 0
    if ft < 500:
        return 3
    if ft < 1000:
        return 2
    if ft <= 3000:
        return 1
    return 0

def vis_rank(sm):
    if sm == None:
        return -1
    if sm < 1:
        return 3
    if sm < 3:
        return 2
    if sm <= 5:
        return 1
    return 0

# ---- sky picture ----------------------------------------------------------------------

def is_night(m, unix):
    """Sun below the horizon at the station (NOAA low-precision solar position).
    No coordinates: assume day."""
    if m["lat"] == None or m["lon"] == None:
        return False
    rad = PI / 180.0
    d = unix / 86400.0 - 10957.5
    L = 280.460 + 0.9856474 * d
    g = (357.528 + 0.9856003 * d) * rad
    lam = (L + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g)) * rad
    eps = (23.439 - 0.0000004 * d) * rad
    ra = math.atan2(math.cos(eps) * math.sin(lam), math.cos(lam))
    dec = math.asin(math.sin(eps) * math.sin(lam))
    gmst = 280.46061837 + 360.98564736629 * d
    ha = (gmst + m["lon"]) * rad - ra
    phi = m["lat"] * rad
    alt = math.asin(math.sin(phi) * math.sin(dec) +
                    math.cos(phi) * math.cos(dec) * math.cos(ha))
    return alt < -0.833 * rad

def sky_icon(m, night):
    """Present weather first (strongest wins), then cloud cover.
    Vicinity groups (VCSH, VCTS) describe weather near the field, not at it."""
    toks = [t for t in m["wx"].split(" ") if t != "" and not t.startswith("VC")]
    w = " ".join(toks)
    if "TS" in w:
        return STORM
    if "FZRA" in w or "FZDZ" in w:
        return FREEZE
    for k in ["SN", "SG", "PL", "GS", "GR", "IC"]:
        if k in w:
            return SNOW
    for k in ["RA", "DZ", "SH", "UP"]:
        if k in w:
            return RAIN
    for k in ["FG", "BR", "HZ", "FU", "DU", "SA", "VA"]:
        if k in w:
            return FOG
    worst = 0
    rank = {"FEW": 1, "SCT": 2, "BKN": 3, "OVC": 4, "OVX": 4}
    for L in m["layers"]:
        r = rank[L[0]] if L[0] in rank else 0
        if r > worst:
            worst = r
    if worst >= 3:
        return CLOUD
    if worst == 2:
        return PARTMOON if night else PARTSUN
    return MOON if night else SUN

# ---- page 1: METAR ----------------------------------------------------------------------

def metar(c, ctx):
    c.fill("black")
    st = fetch(ctx)
    if fail(c, st):
        return
    m = st["m"]
    col = header(c, m, obs_time(m["obs"]))

    # Hero: the category word. "MVFR" is the worst case at 43 px (x 1-43),
    # which leaves x 45-63 for the sky picture.
    word = m["cat"] if m["cat"] != "" else "N/A"
    c.text(word, 1, HERO, font = "10x16", color = col)

    art = sky_icon(m, is_night(m, ctx.now.unix))
    aw = len(art[0])
    ah = len(art)
    c.sprite(art, 54 - aw // 2, 16 - ah // 2, legend = ICON_LEGEND)

    # Footer: the value that set the category. A tie goes to the ceiling.
    cr = cig_rank(m["ceil"])
    vr = vis_rank(m["vis"])
    if m["ceil"] >= 0 and cr >= vr:
        label_value(c, "CIG", base_text(m["ceil"]), FOOT)
    elif vr >= 0:
        label_value(c, "VIS", vis_text(m), FOOT)
    else:
        label_value(c, "CIG", "NONE", FOOT)

# ---- page 2: WIND -----------------------------------------------------------------------

DIAL_X = 9       # dial centre; radius 8 spans x 1-17, y 8-24
DIAL_Y = 16
DIAL_R = 8

def wind_band(kt):
    """[word, colour] by knots, so the colour never disagrees with the value."""
    if kt < 1:
        return ["CALM", OK]
    if kt < 20:
        return ["", INK]
    if kt < 30:
        return ["STRONG", WARN]
    return ["SEVERE", ALARM]

def dial(c, bearing, col):
    """A compass ring with N/E/S/W ticks and a solid wedge pointing to where
    the wind comes FROM, as on the original. Every pixel is either on or off:
    no anti-aliasing, no blending."""
    c.circle(DIAL_X, DIAL_Y, DIAL_R, RING)
    for p in [[0, -1], [1, 0], [0, 1], [-1, 0]]:
        c.pixel(DIAL_X + p[0] * DIAL_R, DIAL_Y + p[1] * DIAL_R, INK)
    if bearing == None:
        return
    rad = PI / 180.0
    for dy in range(-DIAL_R + 1, DIAL_R):
        for dx in range(-DIAL_R + 1, DIAL_R):
            dist2 = dx * dx + dy * dy
            if dist2 > 48 or dist2 == 0:
                continue
            a = math.atan2(dx, -dy) / rad   # 0 = north, clockwise
            diff = (a - bearing + 540.0) % 360.0 - 180.0
            if diff >= -30 and diff <= 30:
                c.pixel(DIAL_X + dx, DIAL_Y + dy, col)
    c.pixel(DIAL_X, DIAL_Y, col)

def wind(c, ctx):
    c.fill("black")
    st = fetch(ctx)
    if fail(c, st):
        return
    m = st["m"]
    col = header(c, m, "WIND")
    mph = str(ctx.inputs.get("windunit", "KNOTS")).strip().upper() == "MPH"
    unit = "MPH" if mph else "KT"

    spd = m["wspd"]
    calm = spd != None and rnd(spd) == 0
    dial(c, None if (calm or m["vrb"] or spd == None) else m["wdir"], col)

    # Hero, right of the dial: x 20-62 (43 px). "CALM" is 43 px at 10x16.
    # The worst speed, "105" + "MPH", is 50 px at 10x16 + 5x7, so the
    # ladder steps down until it fits.
    x0 = 20
    room = RIGHT - x0 + 1
    if spd == None:
        c.text("--", x0, HERO, font = "10x16", color = LABEL)
    elif calm:
        c.text("CALM", x0, HERO, font = "10x16", color = OK)
    else:
        v = rnd(spd * KT_TO_MPH) if mph else rnd(spd)
        b = wind_band(spd)
        s = str(v)
        for pair in [["10x16", "5x7"], ["10x16", "4x5"], ["9x12_bold", "4x5"], ["6x8", "4x5"]]:
            w = c.text_width(s, pair[0]) + 2 + c.text_width(unit, pair[1])
            if w <= room or pair[0] == "6x8":
                # smaller fallbacks sit on the same baseline as the 10x16
                y = HERO + FONTH["10x16"] - FONTH[pair[0]]
                c.text(s, x0, y, font = pair[0], color = b[1])
                # unit sits on the number's baseline
                ux = x0 + c.text_width(s, pair[0]) + 2
                uy = y + FONTH[pair[0]] - 1 - FONTH[pair[1]]
                c.text(unit, ux, uy, font = pair[1], color = LABEL)
                break

    # Footer: bearing under the dial, gust at the right.
    if m["vrb"] and not calm:
        c.text("VRB", 1, FOOT, font = "4x5", color = INK)
    elif m["wdir"] != None and not calm and spd != None:
        s = str(m["wdir"] + 1000)[1:]
        c.text(s, 1, FOOT, font = "4x5", color = INK)
        draw_deg(c, 1 + c.text_width(s, "4x5") + 1, FOOT, INK)
    g = m["wgst"]
    if g != None and rnd(g) > 0 and not calm:
        gv = rnd(g * KT_TO_MPH) if mph else rnd(g)
        gs = str(gv)
        c.text(gs, RIGHT, FOOT, font = "4x5", color = wind_band(g)[1], align = "right")
        c.text("GUST", RIGHT - c.text_width(gs, "4x5") - 3, FOOT, font = "4x5",
               color = LABEL, align = "right")

# ---- page 3: TEMP -----------------------------------------------------------------------

def spread_band(tc, dc):
    """[word, colour] for the temperature / dew point spread in whole C.
    Within 4 C the air is close to saturation; equal means fog or cloud."""
    sp = rnd(tc) - rnd(dc)
    if sp <= 0:
        return ["SATURATED", ALARM]
    if sp <= 4:
        return ["CLOSE", WARN]
    return ["", INK]

def to_unit(c_val, fahr):
    return rnd(c_val * 9.0 / 5.0 + 32.0) if fahr else rnd(c_val)

def temp(c, ctx):
    c.fill("black")
    st = fetch(ctx)
    if fail(c, st):
        return
    m = st["m"]
    header(c, m, "TEMP")
    fahr = str(ctx.inputs.get("tempunit", "FAHRENHEIT")).strip().upper() != "CELSIUS"
    u = "F" if fahr else "C"

    # Hero: temperature, big degree ring, unit letter. Worst case "104" or
    # "-40": 32 + 2 + 4 + 1 + 5 = 44 px, x 1-44.
    if m["temp"] == None:
        c.text("--", 1, HERO, font = "10x16", color = LABEL)
    else:
        s = str(to_unit(m["temp"], fahr))
        w = c.text_width(s, "10x16")
        c.text(s, 1, HERO, font = "10x16", color = INK)
        draw_deg(c, 1 + w + 1, HERO, INK, big = True)
        c.text(u, 1 + w + 1 + 4 + 1, HERO, font = "5x7", color = INK)

    # Dew point, right column, right-aligned at x 62. Worst case "-12" plus
    # the degree ring is 16 px, x 47-62: 2 px clear of the widest hero.
    c.text("DEW", RIGHT, HERO + 1, font = "4x5", color = LABEL, align = "right")
    if m["dewp"] == None:
        c.text("--", RIGHT, HERO + 8, font = "4x5", color = LABEL, align = "right")
    else:
        ds = str(to_unit(m["dewp"], fahr))
        dcol = INK if m["temp"] == None else spread_band(m["temp"], m["dewp"])[1]
        dw = deg_width(c, ds, "4x5")
        x = RIGHT - dw + 1
        c.text(ds, x, HERO + 8, font = "4x5", color = dcol)
        draw_deg(c, x + c.text_width(ds, "4x5") + 1, HERO + 8, dcol)

    label_value(c, "BARO", altim_text(m), FOOT)

# ---- page 4: SKY --------------------------------------------------------------------------

ROWS = [TOP, TOP + 6, TOP + 12, FOOT]

def sky(c, ctx):
    c.fill("black")
    st = fetch(ctx)
    if fail(c, st):
        return
    m = st["m"]
    col = CATS[m["cat"]] if m["cat"] in CATS else NOCAT

    tail = []
    tail.append(["VIS", vis_text(m)])
    if m["wx"] != "":
        tail.append(["WX", m["wx"]])
    slots = len(ROWS) - len(tail)

    real = [L for L in m["layers"] if L[0] not in ["CLR", "SKC", "NSC", "NCD", "CAVOK"]]
    shown = real
    if len(real) > slots:
        shown = real[:slots]
        ci = -1
        for i in range(len(real)):
            if real[i][1] == m["ceil"] and real[i][0] in ["BKN", "OVC", "OVX"]:
                ci = i
                break
        if ci >= slots:
            shown = real[:slots - 1] + [real[ci]]
    hidden = len(real) - len(shown)

    header(c, m, "SKY +" + str(hidden) if hidden > 0 else "SKY")

    row = 0
    if len(real) == 0:
        # Empty state: a cloudless sky is good news, not a missing value.
        c.text("NO CLOUDS", 1, ROWS[0], font = "4x5", color = OK)
        row = 1
    ceil_done = False
    for L in shown:
        is_ceil = (not ceil_done) and L[1] == m["ceil"] and L[0] in ["BKN", "OVC", "OVX"]
        if is_ceil:
            ceil_done = True
        word = "VV" if L[0] == "OVX" else L[0]
        bt = base_text(L[1])
        c.text(bt, RIGHT, ROWS[row], font = "4x5", color = INK, align = "right")
        c.text(clip(c, word, "4x5", RIGHT - c.text_width(bt, "4x5") - 4), 1,
               ROWS[row], font = "4x5", color = col if is_ceil else INK)
        row += 1

    for t in tail:
        if row >= len(ROWS):
            break
        if t[0] == "WX":
            v = wx_codes(c, t[1], RIGHT - 1 - c.text_width("WX", "4x5") - 3, "4x5")
            label_value(c, "WX", v, ROWS[row])
        else:
            label_value(c, t[0], t[1], ROWS[row])
        row += 1