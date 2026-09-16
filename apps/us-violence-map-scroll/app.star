# US Violence Map
#
# A heat map of the United States, the jurisdictions carrying the highest
# rates, and where your own state sits - from CDC provisional mortality
# data, which is the only public source that hands back every state in a
# single request.
#
#   heatmap  every state shaded by its rate, with the scale beside it
#   toplist  the five highest rates, with bars, against the national rate
#   mystate  your state alone on the map, with its rank and its change
#
# Data. CDC Mapping Injury, Overdose, and Violence, the state file
# (data.cdc.gov/resource/fpsi-y8tj) for all 51 jurisdictions and the
# national file (t6u2-f84c) for the country. Rates are deaths per 100,000
# people over the most recent twelve months CDC has published, which runs
# some months behind today because death records take time to certify.
# A rate CDC suppresses - the count is too small to publish safely - comes
# back as -999 and is drawn as NR, never as a zero, and never ranked.
#
# The FBI Crime Data Explorer was the first choice, violent crime being the
# more familiar measure, but it needs a key and answers for one state per
# request: fifty states would be fifty requests against a budget of eight.
#
# DESIGN. The map is the app. It is a real Albers projection of the lower
# 48 rasterised to 52 x 32 - the panel's full height - where every state is
# its own character in one sprite, so a single legend recolours the whole
# country each render. Alaska and Hawaii cannot be drawn at this size
# without reading as part of the mainland, so they sit beside the map as
# two labelled squares; DC is the single pixel between Maryland and
# Virginia. The ramp runs deep blue through teal, amber and orange to red,
# built from the data's own low and high so it works whether the numbers
# run 1 to 15 or 5 to 60. White is kept for the one state you asked about.
#
# Cadence: refresh 86400 with a matching ttl. CDC republishes monthly.

STATE_URL = "https://data.cdc.gov/resource/fpsi-y8tj.json"
NATL_URL = "https://data.cdc.gov/resource/t6u2-f84c.json"
HEADERS = {"User-Agent": "glance-us-violence-map (glance-led.dev)"}
TTL = 86400

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FAINT = "#3E465A"
NR = "#1C2230"          # no rate published
BRAND = "#5CC8F0"
OFFLINE = "#3C4043"
# cold to hot, five bands
RAMP = ["#2A4A7A", "#2E9BA8", "#E8C15A", "#F07B2A", "#FF3B3B"]

# --------------------------------------------------------------- the map
# Albers equal-area conic, lower 48 plus DC, one character per state.
# Rhode Island and DC are a single cell each: at 52 px wide they lose every
# cell to their neighbours, so each is placed at its own centroid.
USA = """
......................ppp..................II.......
......................ppp.................III.......
.....................ppppp...............IIII.......
.....................ppppppp............IIII........
.................ppppppppppppQQQQQ......IIII........
................pppppppppppppQQQQQWA.IIIIII.........
................pppppppppppppQQWWWWAIIIIIII.........
...........Bdd.ppppppppppppppQQWWWAAAAJJJJ..........
........BBBBBddddddppppppppppQQWWWAAAAJJJJJ.........
.......BBBBBBddddddpppppppppCCCWWWAAAJJJJJmm........
....DDDBBBBBBddddddppppiiiiiCCCCWWAAAJJJJmmm........
....DDDBBBBBBddddddpppiiiiiiCCCCWWAAAJJJmmmmf.......
...DDDDDBBBBBddddddpppiiiiiiCCCCooooooofmmfffff.....
.DDDDDDaBBBBBdddddddiiiiiiiiXXXXXooooooofffffff.....
.DDDDDDaBBBBBddEEEEEOOOOOOOOXXXXXPPPPPPssffffff.....
.DDDDDaaaqqqqqEEEEEEEOOOOOOOXXXXLLMPPPPPusssssf.....
DDDDDaaaaqqqqqEEEEEEEOOOOOOOXXXXLLMMMPPuuusssss.....
DDDDDaaaaqqqqqEEEEEEEOOOOOOXXXXLLLMMMhhhuuussSS.....
DDDDaaaaaqqqqqEEEEEEEZZZZZZXXXNLLLMMMhhhhuuuHSG.....
DDDDaaaaaqqqqqEEEwwZZZZZZZNNNNNLLLMMMhhhhkkkkkc.....
DDDDaaaaaaqqwwwwwwwZZZZZZZNNNNNNLLMUUhhhhkkkkkce....
DDDDaaaaaaqKwwwwwwwZZZZZnnNNNNNvvv.UUUU.kkkkkkeee...
DDDDaajKKKKKKwwwwwwnnnnnnnVVVVvvvvUUUUU..eeeeeeFlT..
DDDjjjjjKKKKKwwwwwwnnnnnnnVVVvvvvvUUUUU..eeeeeeTTTT.
jjjjjjjjKKKKKwwwwYYnnnnnnnVVVvvvvvvUUU.....eeeerbR..
jjjjjjjjKKKYYYYYYYYYggggggVVVvvvvUUUUU......eerrbR..
.jjjjjjjjKYYYYYYYYYgggggggVVVVvUUUUUU.......eerrRRR.
.jjjjjjtKKYYYYYYYYYYggggggVVVVVVUU.............bRRRR
..jttttttKYYYYYYYYYYgggggVVVVVV.U...............RRRR
..tttttttKYYYYYYYYYYggg....V....................RRR.
..tttttttKYYY...................................RRR.
..ttttttt...........................................
"""
MAP_W = 52
CELL = {"A": "AL", "B": "AZ", "C": "AR", "D": "CA", "E": "CO", "F": "CT", "G": "DE", "H": "DC",
        "I": "FL", "J": "GA", "K": "ID", "L": "IL", "M": "IN", "N": "IA", "O": "KS", "P": "KY",
        "Q": "LA", "R": "ME", "S": "MD", "T": "MA", "U": "MI", "V": "MN", "W": "MS", "X": "MO",
        "Y": "MT", "Z": "NE", "a": "NV", "b": "NH", "c": "NJ", "d": "NM", "e": "NY", "f": "NC",
        "g": "ND", "h": "OH", "i": "OK", "j": "OR", "k": "PA", "l": "RI", "m": "SC", "n": "SD",
        "o": "TN", "p": "TX", "q": "UT", "r": "VT", "s": "VA", "t": "WA", "u": "WV", "v": "WI",
        "w": "WY"}

# CDC writes the jurisdiction out in full; the panel wants it short.
ABBR = {
    "ALABAMA": "AL", "ALASKA": "AK", "ARIZONA": "AZ", "ARKANSAS": "AR", "CALIFORNIA": "CA",
    "COLORADO": "CO", "CONNECTICUT": "CT", "DELAWARE": "DE", "DISTRICT OF COLUMBIA": "DC",
    "FLORIDA": "FL", "GEORGIA": "GA", "HAWAII": "HI", "IDAHO": "ID", "ILLINOIS": "IL",
    "INDIANA": "IN", "IOWA": "IA", "KANSAS": "KS", "KENTUCKY": "KY", "LOUISIANA": "LA",
    "MAINE": "ME", "MARYLAND": "MD", "MASSACHUSETTS": "MA", "MICHIGAN": "MI", "MINNESOTA": "MN",
    "MISSISSIPPI": "MS", "MISSOURI": "MO", "MONTANA": "MT", "NEBRASKA": "NE", "NEVADA": "NV",
    "NEW HAMPSHIRE": "NH", "NEW JERSEY": "NJ", "NEW MEXICO": "NM", "NEW YORK": "NY",
    "NORTH CAROLINA": "NC", "NORTH DAKOTA": "ND", "OHIO": "OH", "OKLAHOMA": "OK", "OREGON": "OR",
    "PENNSYLVANIA": "PA", "RHODE ISLAND": "RI", "SOUTH CAROLINA": "SC", "SOUTH DAKOTA": "SD",
    "TENNESSEE": "TN", "TEXAS": "TX", "UTAH": "UT", "VERMONT": "VT", "VIRGINIA": "VA",
    "WASHINGTON": "WA", "WEST VIRGINIA": "WV", "WISCONSIN": "WI", "WYOMING": "WY",
}
# Names that do not fit a table column at 4x5.
SHORT = {"DISTRICT OF COLUMBIA": "DC", "SOUTH CAROLINA": "S CAROLINA",
         "NORTH CAROLINA": "N CAROLINA", "SOUTH DAKOTA": "S DAKOTA", "NORTH DAKOTA": "N DAKOTA",
         "WEST VIRGINIA": "W VIRGINIA", "NEW HAMPSHIRE": "N HAMPSHIRE",
         "MASSACHUSETTS": "MASS", "RHODE ISLAND": "RHODE ISL"}

# Dropdown label -> [CDC intent, pill word]
METRICS = {
    "HOMICIDE": ["All_Homicide", "HOMICIDE"],
    "FIREARM HOMICIDE": ["FA_Homicide", "GUN HOMICIDE"],
    "FIREARM DEATHS": ["FA_Deaths", "GUN DEATHS"],
    "DRUG OVERDOSE": ["Drug_OD", "OVERDOSE"],
}

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

def pill(c, word, fill, x, y):
    return c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

# ----------------------------------------------------------------- numbers
def to_rate(s):
    """CDC sends the rate as text - 14.60000000000000, or -999 when it is
    suppressed. Returns tenths as an integer, or None for suppressed, so
    the arithmetic stays exact."""
    t = str(s).strip()
    if t == "":
        return None
    neg = t.startswith("-")
    if neg:
        t = t[1:]
    parts = t.split(".")
    whole, frac = parts[0], (parts[1] if len(parts) > 1 else "0")
    for ch in whole.elems():
        if ch < "0" or ch > "9":
            return None
    if whole == "":
        return None
    tenths = int(whole) * 10
    if len(frac) > 0 and frac[0] >= "0" and frac[0] <= "9":
        tenths += int(frac[0])
    if neg:
        return None          # -999 is CDC saying: too few to publish
    return tenths

def rate_text(tenths):
    return str(tenths // 10) + "." + str(tenths % 10)

def signed_text(tenths):
    if tenths == 0:
        return "0.0"
    return ("+" if tenths > 0 else "-") + rate_text(tenths if tenths > 0 else -tenths)

def band_color(tenths, lo, hi):
    """Which of the five ramp colours a rate falls in, scaled to the data
    on the panel right now so the map works for any measure."""
    if tenths == None:
        return NR
    if hi <= lo:
        return RAMP[2]
    i = (tenths - lo) * 5 // (hi - lo)
    if i > 4:
        i = 4
    if i < 0:
        i = 0
    return RAMP[i]

# ------------------------------------------------------------------- feed
def fetch(ctx, with_year):
    label = str(ctx.inputs.get("metric", "HOMICIDE")).strip().upper()
    if label not in METRICS:
        label = "HOMICIDE"
    m = METRICS[label]
    home = str(ctx.inputs.get("homestate", "FLORIDA")).strip().upper()
    if home not in ABBR:
        home = "FLORIDA"
    base = {"metric": m[1], "home": home, "homeab": ABBR[home]}

    r = http.get(STATE_URL, params = {"intent": m[0], "period": "TTM", "$limit": "60"},
                 headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return dict(base, ok = False, head = "CDC DATA OFFLINE", sub = "RETRY TOMORROW")
    if r["status_code"] != 200 or type(r["json"]) != "list":
        return dict(base, ok = False, head = "CDC FEED ERROR",
                    sub = "HTTP " + str(r["status_code"]) + " - RETRY LATER")

    rates, order, window = {}, [], ""
    for row in r["json"]:
        nm = str(get(row, "name", "")).upper()
        if nm not in ABBR:
            continue
        ab = ABBR[nm]
        rates[ab] = to_rate(get(row, "rate", ""))
        order.append([ab, nm])
        if window == "":
            window = str(get(row, "ttm_date_range", ""))
    if len(order) == 0:
        return dict(base, ok = False, head = "NO CDC DATA YET", sub = "THE FEED CAME BACK EMPTY")

    # The national figure is context, not the story: losing it costs a line.
    natl = None
    n = http.get(NATL_URL, params = {"intent": m[0], "type": "TTM"}, headers = HEADERS,
                 ttl_seconds = TTL)
    if n["status_code"] == 200 and type(n["json"]) == "list" and len(n["json"]) > 0:
        natl = to_rate(get(n["json"][0], "rate", ""))

    # Last full calendar year, for the change on the third page.
    year = {}
    if with_year:
        y = http.get(STATE_URL, params = {"intent": m[0], "period": "2024", "$limit": "60"},
                     headers = HEADERS, ttl_seconds = TTL)
        if y["status_code"] == 200 and type(y["json"]) == "list":
            for row in y["json"]:
                nm = str(get(row, "name", "")).upper()
                if nm in ABBR:
                    year[ABBR[nm]] = to_rate(get(row, "rate", ""))

    live = [t for t in rates.values() if t != None]
    lo = min(live) if len(live) > 0 else 0
    hi = max(live) if len(live) > 0 else 0
    ranked = [[ab, rates[ab]] for ab in rates if rates[ab] != None]
    for i in range(1, len(ranked)):
        k = i
        for step in range(i):
            if k > 0 and ranked[k][1] > ranked[k - 1][1]:
                ranked[k], ranked[k - 1] = ranked[k - 1], ranked[k]
                k -= 1
    names = {}
    for pair in order:
        names[pair[0]] = pair[1]
    return dict(base, ok = True, rates = rates, ranked = ranked, names = names, lo = lo, hi = hi,
                natl = natl, year = year, window = window)

def window_text(window):
    """'May, 2025 to April, 2026' -> '12 MO TO APR 2026'."""
    t = str(window).upper()
    i = t.find(" TO ")
    if i < 0:
        return "LATEST 12 MONTHS"
    tail = t[i + 4:].replace(",", "")
    bits = [b for b in tail.split(" ") if b != ""]
    if len(bits) < 2:
        return "LATEST 12 MONTHS"
    return "12 MO TO " + bits[0][:3] + " " + bits[1]

# ---------------------------------------------------------------- drawing
def draw_map(c, d, solo):
    """The whole country in one sprite: the legend carries a colour per
    state, so 49 shapes cost one draw. `solo` lights a single state."""
    leg = {}
    for ch in CELL:
        ab = CELL[ch]
        if solo != "":
            leg[ch] = INK if ab == solo else NR
        else:
            leg[ch] = band_color(d["rates"].get(ab, None), d["lo"], d["hi"])
    c.sprite(USA, 10, 0, legend = leg)

def swatch(c, x, y, ab, d, wide):
    """Alaska and Hawaii, which cannot be drawn in place at this size."""
    col = band_color(d["rates"].get(ab, None), d["lo"], d["hi"])
    c.rect(x, y, x + 4, y + 4, fill = col)
    c.text(ab, x + 6, y, font = "4x5", color = DIM)
    if wide:
        t = d["rates"].get(ab, None)
        c.text(rate_text(t) if t != None else "NR", x + 17, y, font = "4x5", color = INK)

def fail_screen(c, d):
    c.fill("black")
    rail(c, OFFLINE)
    leg = {}
    for ch in CELL:
        leg[ch] = FAINT
    c.sprite(USA, 10, 0, legend = leg)
    hf = fit(c, d["head"], ["6x8", "5x7", "4x5"], 112)
    c.text(hf[1], 124, 10, font = hf[0], color = "amber", align = "center")
    sf = fit(c, d["sub"], ["4x5", "picopixel"], 112)
    c.text(sf[1], 124, 22, font = sf[0], color = DIM, align = "center")

# ------------------------------------------------------------ page: map
def heatmap(c, ctx):
    d = fetch(ctx, False)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    draw_map(c, d, "")

    # Text column x 66..181. The map owns the full height at the left, so
    # the chip row starts here rather than at x 10.
    tx = 66
    w = pill(c, d["metric"], BRAND, tx, 0)
    c.text("PER 100K", tx + w + 3, 1, font = "4x5", color = DIM)
    c.text(clip(c, window_text(d["window"]), "picopixel", 116), tx, 8, font = "picopixel", color = FAINT)

    # The ramp, drawn as it is used, with the two numbers that anchor it.
    for i in range(5):
        c.rect(tx + i * 13, 14, tx + i * 13 + 11, 18, fill = RAMP[i])
    c.text(rate_text(d["lo"]), tx, 20, font = "picopixel", color = DIM)
    c.text(rate_text(d["hi"]), tx + 64, 20, font = "picopixel", color = DIM, align = "right")

    if d["natl"] != None:
        c.text("US", tx + 74, 14, font = "4x5", color = DIM)
        c.text(rate_text(d["natl"]), tx + 74, 20, font = "5x7", color = INK)

    # Alaska and Hawaii live beside the map, labelled, because at 52 px
    # wide they would read as part of the mainland.
    swatch(c, tx, 26, "AK", d, True)
    swatch(c, tx + 40, 26, "HI", d, True)

# --------------------------------------------------------- page: top list
def toplist(c, ctx):
    d = fetch(ctx, False)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    rail(c, RAMP[4])
    w = pill(c, d["metric"], BRAND, 10, 0)
    edge = 181
    if d["natl"] != None:
        us = "US " + rate_text(d["natl"])
        c.text(us, 181, 1, font = "4x5", color = DIM, align = "right")
        edge = 181 - c.text_width(us, "4x5") - 5
    # The title steps down a wording rather than being cut mid-word.
    tx = 10 + w + 3
    for title in ["HIGHEST RATES PER 100K", "HIGHEST RATES", "HIGHEST"]:
        if c.text_width(title, "4x5") <= edge - tx + 1:
            c.text(title, tx, 1, font = "4x5", color = INK)
            break

    # Two columns: ranks 1-3 at the left, 4-5 at the right. Each row is a
    # line of text with a bar under it, on an 8 px pitch, so rows keep a
    # 1 px gap and the bar never touches the name above it.
    top = d["ranked"][:5]
    for i in range(len(top)):
        ab, tenths = top[i][0], top[i][1]
        col = 0 if i < 3 else 1
        x = 10 + col * 90
        y = 8 + (i % 3) * 8
        full = d["names"].get(ab, ab)
        name = SHORT.get(full, full)
        val = rate_text(tenths)
        vw = c.text_width(val, "4x5")
        room = 82 - 8 - vw - 4
        # "WASHINGTON DC" cut to "WASHINGTON" is a different state, so a
        # name that will not fit is replaced by its abbreviation, not cut.
        if c.text_width(name, "4x5") > room:
            name = ab
        c.text(str(i + 1), x, y, font = "4x5", color = RAMP[4] if i == 0 else DIM)
        c.text(clip(c, name, "4x5", room), x + 8, y, font = "4x5", color = INK)
        c.text(val, x + 82, y, font = "4x5", color = INK, align = "right")
        bw = 82 * tenths // d["hi"] if d["hi"] > 0 else 0
        if bw > 0:
            c.rect(x, y + 6, x + bw - 1, y + 7, fill = band_color(tenths, d["lo"], d["hi"]))

    if len(top) < 5:
        c.text("ONLY " + str(len(top)) + " REPORTED", 100, 24, font = "4x5", color = DIM)

# -------------------------------------------------------- page: my state
def mystate(c, ctx):
    d = fetch(ctx, True)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    ab = d["homeab"]
    mine = d["rates"].get(ab, None)
    draw_map(c, d, ab)

    tx = 66
    w = pill(c, ab, BRAND, tx, 0)
    nx = 182
    if d["natl"] != None:
        us = "US " + rate_text(d["natl"])
        c.text(us, 181, 1, font = "4x5", color = DIM, align = "right")
        nx = 181 - c.text_width(us, "4x5") - 5
    c.text(clip(c, SHORT.get(d["home"], d["home"]), "4x5", nx - (tx + w + 3)), tx + w + 3, 1,
           font = "4x5", color = INK)

    if mine == None:
        c.text("NOT REPORTED", tx, 12, font = "6x8", color = DIM)
        c.text("CDC SUPPRESSES SMALL COUNTS", tx, 24, font = "picopixel", color = FAINT)
        return

    # The rate is the hero; rank, nation and the year-over-year change are
    # the three things that tell you what it means.
    c.text(rate_text(mine), tx, 9, font = "10x16", color = INK)
    hx = tx + c.text_width(rate_text(mine), "10x16") + 4
    c.text("PER", hx, 10, font = "picopixel", color = DIM)
    c.text("100K", hx, 17, font = "picopixel", color = DIM)

    rank = 0
    for i in range(len(d["ranked"])):
        if d["ranked"][i][0] == ab:
            rank = i + 1
    # The change is drawn first and the rank fitted to what is left, so the
    # two can never run through each other. Down is the good direction for
    # every measure on this panel, so a fall is green and a rise is red.
    edge = 181
    prev = d["year"].get(ab, None)
    if prev != None:
        ch = mine - prev
        yr = signed_text(ch) + " VS 2024"
        c.text(yr, 181, 26, font = "4x5", color = RAMP[4] if ch > 0 else RAMP[1], align = "right")
        edge = 181 - c.text_width(yr, "4x5") - 5
    line = ("RANK " + str(rank) + " OF " + str(len(d["ranked"]))) if rank > 0 else "UNRANKED"
    c.text(clip(c, line, "4x5", edge - tx + 1), tx, 26, font = "4x5", color = INK)
