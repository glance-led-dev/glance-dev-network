# Commodities at a Glance
#
# Front-month futures for the things that get grown, raised, pumped and
# mined, three of them on a single page, each one a picture and a price.
#
# Prices come from Yahoo Finance's spark endpoint, which answers for every
# symbol in one request - one http.get for the whole panel, whichever three
# commodities are picked. Each symbol carries its own currency, and that is
# what makes the numbers right: the CME grains and livestock are quoted in
# US cents (Yahoo says "USX"), so corn comes back as 534.0 and has to be
# drawn as $5.34 a bushel, while live cattle comes back as 220.325 and is
# $220.33 the hundredweight - the same digits, a different unit. Crude,
# gold and cocoa are already dollars. Cross-checked against CNBC's quote
# service: corn 534.00 and -0.33% on both, to the cent.
#
# DESIGN. A market board built out of pictures. Each tile is a 16x16 piece
# of pixel art - a Holstein's head, an ear of corn in its husk, a soybean
# pod, a wheat head, an oil barrel with a drop coming off it, a gas flame,
# a stack of ingots that recolours itself for gold, silver and copper, a
# coffee bean, a sugar cube, a cotton boll, a cocoa pod, an orange - with
# the price beside it in 5x7, the unit under that in the smallest face the
# panel has, and the day's move under that in green or red. The picture is
# the label: no tile says CORN, because the corn is right there. White is
# the price, so green and red only ever mean the move. Three tiles on the
# one page, 56 px each, inside x 10..181.
#
# Cadence: refresh 600 with a matching ttl, the ten minutes asked for.
# Futures quotes from a free feed are delayed, which the chip row says.

SPARK = "https://query1.finance.yahoo.com/v7/finance/spark"
HEADERS = {"User-Agent": "glance-commodities (glance-led.dev)"}
TTL = 600

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FAINT = "#3E465A"
BRAND = "#F0B429"      # the chip: wheat gold
UP = "#2FE06F"
DOWN = "#FF4B4B"
FLAT = "#8A93A6"
OFFLINE = "#3C4043"

# --------------------------------------------------------------- pixel art
COW = """
..K..........K..
.KKK........KKK.
.KKKKKKKKKKKKKK.
KWWWWWWWWWWWWWWK
KWWKKWWWWWWKKWWK
KWWKKWWWWWWKKWWK
KWWWWWWWWWWWWWWK
KWWWWWWWWWWWWWWK
.KWWWPPPPPPWWWK.
.KWWPPPPPPPPWWK.
..KWPPKPPKPPWK..
..KWPPPPPPPPWK..
...KKPPPPPPKK...
.....KKKKKK.....
"""
HOG = """
..P..........P..
.PPP........PPP.
.PPPPPPPPPPPPPP.
PPPPPPPPPPPPPPPP
PPKKPPPPPPPPKKPP
PPKKPPPPPPPPKKPP
PPPPPPPPPPPPPPPP
PPPPPPPPPPPPPPPP
.PPPPSSSSSSPPPP.
.PPPSSSSSSSSPPP.
..PPSSKSSKSSPP..
..PPSSSSSSSSPP..
...PPSSSSSSPP...
.....PPPPPP.....
"""
CORN = """
......GGG.......
.....GGGGG......
....GYYYYYG.....
...GYOYYOYYG....
...GYYOYYOYG....
...GYOYYOYYG....
...GYYOYYOYG....
...GYOYYOYYG....
...GYYOYYOYG....
....GYOYYOG.....
....GGYYYGG.....
.....GGGGG......
......GGG.......
"""
SOY = """
.......LL.......
......LLLL......
.....LL..LL.....
.......LL.......
......LL........
...GGGGGGGGGG...
..GGGGGGGGGGGG..
.GGBBGGBBGGBBGG.
.GGBBGGBBGGBBGG.
..GGGGGGGGGGGG..
...GGGGGGGGGG...
"""
WHEAT = """
.......Y........
......YYY.......
.....YY.YY......
......YYY.......
.....YY.YY......
......YYY.......
.....YY.YY......
......YYY.......
.....YY.YY......
......YYY.......
.......S........
......SS........
.......S........
.....SSS........
.......S........
"""
BARREL = """
.............O..
............OOO.
.............O..
...KKKKKKKKKK...
..KDDDDDDDDDDK..
..KDDDDDDDDDDK..
..KKKKKKKKKKKK..
..KDDDDDDDDDDK..
..KDDDDDDDDDDK..
..KKKKKKKKKKKK..
..KDDDDDDDDDDK..
..KDDDDDDDDDDK..
...KKKKKKKKKK...
"""
FLAME = """
.......B........
......BBB.......
.....BBLBB......
....BBLLLBB.....
....BLLWLLB.....
...BBLLWLLBB....
...BLLLWLLLB....
...BLLLWLLLB....
...BBLLLLLBB....
....BBLLLBB.....
.....BBBBB......
"""
BARS = """
......GGGGGG....
.....GHHHHHHG...
.....GGGGGGGG...
...GGGGGG.......
..GHHHHHHG......
..GGGGGGGG......
..GGGGGGGGGGG...
.GHHHHHHHHHHHG..
.GGGGGGGGGGGGG..
"""
COFFEE = """
.....BBBBBB.....
...BBBBBBBBBB...
..BBBBLBBBBBBB..
..BBBBLLBBBBBB..
.BBBBBBLLBBBBBB.
.BBBBBBLLBBBBBB.
..BBBBBLLBBBBB..
..BBBBBBLBBBBB..
...BBBBBBBBBB...
.....BBBBBB.....
"""
SUGAR = """
....WWWWWWWW....
...WW......WW...
..WWWWWWWWWWWW..
..WCCCCCCCCCCW..
..WCCCCCCCCCCW..
..WCCCCCCCCCCW..
..WCCCCCCCCCCW..
..WCCCCCCCCCCW..
..WWWWWWWWWWWW..
"""
COTTON = """
.....WWWW.......
...WWWWWWWW.....
..WWWWWWWWWW....
.WWWW.WWWW.WWW..
.WWWWWWWWWWWWW..
..WWWWWWWWWWW...
...WWWWWWWWW....
....BBBBBBB.....
.....B.B.B......
......BBB.......
.......B........
"""
COCOA = """
......OOO.......
.....OORROO.....
....OORRRROO....
...OORRRRRROO...
...ORRORRORRO...
...ORRORRORRO...
...ORRORRORRO...
....OORRRROO....
.....OORROO.....
......OOO.......
"""
ORANGE = """
.......SS.......
......LLSS......
.....LLLL.......
....OOOOOOOO....
...OOAAOOAAOO...
..OOAAOOOOAAOO..
..OOOOOOOOOOOO..
..OOAAOOOOAAOO..
...OOAAOOAAOO...
....OOOOOOOO....
"""

# icon -> [art, legend]. Gold, silver and copper are one stack of ingots
# in three palettes, and the feeder calf is the cow in tan and cream.
ICONS = {
    "COW": [COW, {"K": "#14161C", "W": "#F2F4F8", "P": "#E39AA8"}],
    "CALF": [COW, {"K": "#4A2C16", "W": "#D9A86C", "P": "#E39AA8"}],
    "HOG": [HOG, {"P": "#F0A8B4", "S": "#D97E92", "K": "#14161C"}],
    "CORN": [CORN, {"G": "#3FA34D", "Y": "#FFD24A", "O": "#E0A424"}],
    "SOY": [SOY, {"L": "#3FA34D", "G": "#8FBF44", "B": "#5E8F2A"}],
    "WHEAT": [WHEAT, {"Y": "#E8C15A", "S": "#B08A38"}],
    "OATS": [WHEAT, {"Y": "#F0DCA8", "S": "#A89860"}],
    "BARREL": [BARREL, {"K": "#0E1014", "D": "#2A3038", "O": "#E8B04A"}],
    "FLAME": [FLAME, {"B": "#1F5BC4", "L": "#5CC8F0", "W": "#EAF7FF"}],
    "GOLD": [BARS, {"G": "#C89A20", "H": "#FFD75E"}],
    "SILVER": [BARS, {"G": "#8A93A6", "H": "#E2E8F0"}],
    "COPPER": [BARS, {"G": "#9A5423", "H": "#E08A4A"}],
    "COFFEE": [COFFEE, {"B": "#6B3A1E", "L": "#D8B08A"}],
    "SUGAR": [SUGAR, {"W": "#FFFFFF", "C": "#C7D2E0"}],
    "COTTON": [COTTON, {"W": "#F4F7FF", "B": "#8A6A3A"}],
    "COCOA": [COCOA, {"O": "#C4712A", "R": "#7A3E16"}],
    "ORANGE": [ORANGE, {"O": "#FF8A1F", "A": "#FFC46B", "L": "#3FA34D", "S": "#6B4A20"}],
}

# Dropdown label -> [Yahoo symbol, unit kind, icon].
#   BU    cents a bushel  -> dollars a bushel
#   CWT   cents a pound   -> dollars a hundredweight (the same digits)
#   CLB   cents a pound   -> dollars a pound above 100c, cents below
#   USD   already dollars, with the unit named per commodity
COMMODITIES = {
    "LIVE CATTLE": ["LE=F", "CWT", "COW"],
    "FEEDER CATTLE": ["GF=F", "CWT", "CALF"],
    "LEAN HOGS": ["HE=F", "CWT", "HOG"],
    "CORN": ["ZC=F", "BU", "CORN"],
    "SOYBEANS": ["ZS=F", "BU", "SOY"],
    "WHEAT": ["ZW=F", "BU", "WHEAT"],
    "OATS": ["ZO=F", "BU", "OATS"],
    "CRUDE OIL": ["CL=F", "BBL", "BARREL"],
    "NATURAL GAS": ["NG=F", "MMBTU", "FLAME"],
    "GOLD": ["GC=F", "OZ", "GOLD"],
    "SILVER": ["SI=F", "OZ", "SILVER"],
    "COPPER": ["HG=F", "LB", "COPPER"],
    "COFFEE": ["KC=F", "CLB", "COFFEE"],
    "SUGAR": ["SB=F", "CLB", "SUGAR"],
    "COTTON": ["CT=F", "CLB", "COTTON"],
    "COCOA": ["CC=F", "TON", "COCOA"],
    "ORANGE JUICE": ["OJ=F", "CLB", "ORANGE"],
}
SLOTS = ["slotone", "slottwo", "slotthree"]

# ------------------------------------------------------------- text tools
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

HEXD = "0123456789abcdef"

def ink_for(fill):
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

def is_num(v):
    return type(v) == "int" or type(v) == "float"

# ----------------------------------------------------------------- numbers
def group(n):
    """1234 -> 1,234 without fmt.commas, which wants an int and would round
    a float the wrong way for prices already reduced to whole dollars."""
    s = str(n)
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return out

def dec_str(v, places):
    """A float to a fixed-decimal string, rounded half up, without the
    float formatting Starlark does not have."""
    neg = v < 0
    x = -v if neg else v
    scale = 1
    for i in range(places):
        scale = scale * 10
    n = int(x * scale + 0.5)
    whole = n // scale
    out = group(whole)
    if places > 0:
        frac = str(n % scale)
        for i in range(places - len(frac)):
            frac = "0" + frac
        out = out + "." + frac
    return ("-" + out) if neg else out

def price_text(v, kind):
    """[price, unit]. The unit is what makes the number honest, so every
    tile carries one."""
    if kind == "BU":
        return ["$" + dec_str(v / 100.0, 2), "BUSHEL"]
    if kind == "CWT":
        return ["$" + dec_str(v, 2 if v < 100 else 1), "CWT"]
    if kind == "CLB":
        if v >= 100:
            return ["$" + dec_str(v / 100.0, 2), "LB"]
        return [dec_str(v, 2), "C/LB"]
    if kind == "OZ":
        return ["$" + dec_str(v, 2 if v < 100 else 0), "OZ"]
    if kind == "LB":
        return ["$" + dec_str(v, 2), "LB"]
    if kind == "BBL":
        return ["$" + dec_str(v, 2 if v < 100 else 1), "BBL"]
    if kind == "MMBTU":
        return ["$" + dec_str(v, 3 if v < 10 else 2), "MMBTU"]
    if kind == "TON":
        return ["$" + dec_str(v, 2 if v < 100 else 0), "TON"]
    return ["$" + dec_str(v, 2), ""]

def pct_text(p):
    if p > -0.05 and p < 0.05:
        return "UNCH"
    return ("+" if p > 0 else "-") + dec_str(p if p > 0 else -p, 2) + "%"

def pct_color(p):
    if p > -0.05 and p < 0.05:
        return FLAT
    return UP if p > 0 else DOWN

def clock(secs, offset):
    """Exchange-local wall clock from an epoch second and the feed's own
    gmtoffset, so there is no timezone rule to get wrong."""
    t = (secs + offset) % 86400
    h, m = t // 3600, (t % 3600) // 60
    ap = "P" if h >= 12 else "A"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + fmt.pad(m) + ap

# ------------------------------------------------------------------- feed
def picks(ctx):
    """The three slots, in order, as [label, symbol, kind, icon]; NONE and
    anything unknown drops out."""
    out = []
    for key in SLOTS:
        label = str(ctx.inputs.get(key, "NONE")).strip().upper()
        if label in COMMODITIES:
            e = COMMODITIES[label]
            out.append([label, e[0], e[1], e[2]])
        else:
            out.append(None)
    return out

def fetch(ctx, chosen):
    syms = []
    for p in chosen:
        if p != None and p[1] not in syms:
            syms.append(p[1])
    if len(syms) == 0:
        return {"ok": True, "quotes": {}, "asof": ""}
    r = http.get(SPARK, params = {"symbols": ",".join(syms), "range": "1d", "interval": "1d"},
                 headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return {"ok": False, "head": "PRICES OFFLINE", "sub": "RETRY IN 10 MIN"}
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "head": "PRICE FEED ERROR", "sub": "HTTP " + str(r["status_code"]) + " - RETRY SOON"}
    quotes = {}
    asof = ""
    for res in dig(r["json"], ["spark", "result"], []):
        sym = str(get(res, "symbol", ""))
        resp = get(res, "response", [])
        if type(resp) != "list" or len(resp) == 0:
            continue
        m = get(resp[0], "meta", {})
        price = get(m, "regularMarketPrice", None)
        if not is_num(price):
            continue
        prev = get(m, "chartPreviousClose", None)
        pct = get(m, "regularMarketChangePercent", None)
        if not is_num(pct):
            pct = ((price - prev) * 100.0 / prev) if (is_num(prev) and prev != 0) else 0.0
        quotes[sym] = {"price": price * 1.0, "pct": pct * 1.0}
        secs = get(m, "regularMarketTime", None)
        off = get(m, "gmtoffset", 0)
        if is_num(secs) and asof == "":
            asof = clock(int(secs), int(off) if is_num(off) else 0)
    return {"ok": True, "quotes": quotes, "asof": asof}

# ---------------------------------------------------------------- drawing
def chip_row(c, asof):
    w = c.badge("COMMODITIES", 10, 0, color = ink_for(BRAND), bg = BRAND, font = "4x5")
    x = 181
    if asof != "":
        stamp = asof + " DELAYED"
        c.text(stamp, x, 1, font = "4x5", color = DIM, align = "right")
        x = x - c.text_width(stamp, "4x5") - 5
    # Drawn whole or left off: a clipped "AT A GL" reads as a bug, and the
    # chip beside it already says what the app is.
    lx = 10 + w + 3
    if c.text_width("AT A GLANCE", "4x5") <= x - lx + 1:
        c.text("AT A GLANCE", lx, 1, font = "4x5", color = INK)

def tile(c, x, pick, q):
    """One 56 px cell: the art at x..x+15, then price, unit and move in the
    38 px beside it. 'CATTLE' is never written - the cow says it."""
    art = ICONS[pick[3]]
    c.sprite(art[0], x, 11, legend = art[1])
    tx = x + 18
    if q == None:
        c.text("--", tx, 9, font = "5x7", color = DIM)
        c.text("NO PRICE", tx, 17, font = "picopixel", color = FAINT)
        return
    pu = price_text(q["price"], pick[2])
    pf = fit(c, pu[0], ["5x7", "4x5"], 38)
    c.text(pf[1], tx, 9, font = pf[0], color = INK)
    c.text(clip(c, pu[1], "picopixel", 38), tx, 17, font = "picopixel", color = DIM)
    c.text(clip(c, pct_text(q["pct"]), "4x5", 38), tx, 23, font = "4x5", color = pct_color(q["pct"]))

def message(c, head, sub, head_color):
    """Even a failure keeps the chip and a piece of the art, so the panel
    still says whose page this is."""
    c.badge("COMMODITIES", 10, 0, color = ink_for(BRAND), bg = BRAND, font = "4x5")
    art = ICONS["CORN"]
    c.sprite(art[0], 10, 12, legend = art[1])
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 145)
    c.text(hf[1], 108, 11, font = hf[0], color = head_color, align = "center")
    sf = fit(c, sub, ["4x5", "picopixel"], 145)
    c.text(sf[1], 108, 23, font = sf[0], color = DIM, align = "center")

def board(c, ctx):
    chosen = picks(ctx)
    d = fetch(ctx, chosen)
    c.fill("black")
    if not d["ok"]:
        rail(c, OFFLINE)
        message(c, d["head"], d["sub"], "amber")
        return
    if chosen[0] == None and chosen[1] == None and chosen[2] == None:
        rail(c, BRAND)
        message(c, "NOTHING PICKED", "CHOOSE COMMODITIES IN SETTINGS", BRAND)
        return
    # The rail follows the board: green when the tiles are mostly up, red
    # when mostly down, so the edge reads before the numbers do.
    ups, downs = 0, 0
    for p in chosen:
        if p == None:
            continue
        q = d["quotes"].get(p[1], None)
        if q == None:
            continue
        if q["pct"] > 0.05:
            ups += 1
        elif q["pct"] < -0.05:
            downs += 1
    rail(c, UP if ups > downs else (DOWN if downs > ups else FLAT))
    chip_row(c, d["asof"])
    for i in range(3):
        p = chosen[i]
        if p == None:
            continue
        tile(c, 10 + i * 58, p, d["quotes"].get(p[1], None))

def pageone(c, ctx):
    board(c, ctx)
