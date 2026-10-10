# Internet Outages
#
# Where the internet is down right now: a world map with the affected
# countries lit, and the worst-hit places ranked.
#
# Data: IODA, the Internet Outage Detection and Analysis project at
# Georgia Tech (api.ioda.inetintel.cc.gatech.edu), public and keyless.
# IODA watches three independent signals - BGP routing withdrawals, active
# probing of address blocks, and darknet background traffic - and scores a
# place when all of them fall below what its own history predicts. The
# summary endpoint returns only the places currently scoring, so a quiet
# world is an empty list, not fifty zeroes.
#
# The score is IODA's own: it folds how far below normal a place fell
# together with how long it stayed there, which is why a short national
# blackout and a long partial one can land near each other. It ranks; it
# is not a percentage of people offline, and the panel never implies it is.
#
# DESIGN. The map is the story. Equirectangular, the whole planet from 84
# north to 58 south rasterised to 80 x 32 - Antarctica cropped, since it
# is a white stripe that tells you nothing about the internet - drawn as a
# single dim sprite so the land is context, not content. The outages are
# then struck onto it as 2 px marks at each country's centre, amber to red
# by severity, worst drawn last so it wins the pixel when two neighbours
# are both dark. There is no per-country sprite here: 177 countries cannot
# each own a character, so the map is one silhouette and the marks are
# placed from a table of centres computed from the same projection.
#
# A quiet world is the normal state, so the panel treats it as a result
# and not an empty screen: the map stays dim, the rail goes green, and it
# says so.
#
# Cadence: refresh 900, matching the ttl.

API = "https://api.ioda.inetintel.cc.gatech.edu/v2/outages/summary"
HEADERS = {"User-Agent": "glance-internet-outages (glance-led.dev)"}
TTL = 900

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FAINT = "#3E465A"
LAND = "#24405E"        # the world, as context
SEA = "#0A0E16"
OK = "#2FE06F"
OFFLINE = "#3C4043"
RAMP = ["#FFC219", "#FF8A1F", "#FF3B21"]

WINDOWS = {"6 HOURS": [21600, "6H"], "24 HOURS": [86400, "24H"],
           "3 DAYS": [259200, "3D"], "7 DAYS": [604800, "7D"]}

# --------------------------------------------------------------- the world
# Equirectangular, 84N to 58S, 80 x 32. One character: the land is a
# backdrop and every outage is drawn on top of it.
WORLD = """
..................###################.....####....#.........###.................
.............#######################......####.......##.....######....###.......
#....#......############...#########.........#.....##..####################.....
##.#######################..#######........#####################################
##########################..####..###....#######################################
...#################..####...##........#.######################################.
...###....##################..........##.###############################..###...
..........##################..........##################################..#.....
............#################..........#################################........
............#############.............################################.##.......
............############..............##################################........
.............##########..............##############################.###.........
..............#########..............###############################............
...............####..##.............###############################.............
.....#..........#####.####..........#################..##########.#.............
..................####..............################....###..####.##............
....................#######.........################....##...####.##............
.....................########........##############......##..##..####...........
......................#######.............#########..........########...........
......................##########..........########............############......
......................###########.........#######..............#############....
......................##########..........#######.................##.###.#.#....
.......................#########..........##########...............######....#.#
........................########..........######.##..............#########..#...
........................#######............#####.##..............#########......
........................######.............#####.................##########.....
........................#####...............###..................#########....#.
.......................#####...........................................###....##
.......................###..............................................#....##.
.......................###.............................#.....................#..
.......................##.#............................#........................
........................##......................................................
"""
MAP_X = 10
MAP_W = 80

# Country centre in map cells, from the same projection as the art.
AT = {"AE": [52, 13], "AF": [55, 11], "AL": [44, 9], "AM": [50, 9], "AO": [43, 21],
      "AR": [25, 27], "AT": [42, 8], "AU": [69, 24], "AZ": [50, 9], "BA": [43, 8],
      "BD": [60, 13], "BE": [40, 7], "BF": [39, 16], "BG": [45, 9], "BI": [46, 19],
      "BJ": [40, 16], "BN": [65, 17], "BO": [25, 22], "BR": [27, 21], "BS": [22, 13],
      "BT": [60, 12], "BW": [45, 23], "BY": [46, 6], "BZ": [20, 15], "CA": [19, 4],
      "CD": [45, 19], "CF": [44, 17], "CG": [43, 19], "CH": [41, 8], "CI": [38, 17],
      "CL": [24, 28], "CM": [42, 17], "CN": [63, 10], "CO": [23, 17], "CR": [21, 16],
      "CU": [22, 14], "CY": [47, 11], "CZ": [43, 7], "DE": [42, 7], "DJ": [49, 16],
      "DK": [42, 6], "DO": [24, 14], "DZ": [40, 12], "EC": [22, 19], "EE": [45, 5],
      "EG": [47, 12], "EH": [37, 13], "ER": [48, 15], "ES": [39, 9], "ET": [48, 16],
      "FI": [45, 4], "FJ": [61, 22], "FK": [26, 30], "GA": [42, 19], "GB": [39, 6],
      "GE": [49, 9], "GH": [39, 17], "GL": [30, 2], "GM": [36, 15], "GN": [37, 16],
      "GQ": [42, 18], "GR": [45, 10], "GT": [19, 15], "GW": [36, 16], "GY": [26, 17],
      "HN": [20, 15], "HR": [43, 8], "HT": [23, 14], "HU": [44, 8], "ID": [66, 19],
      "IE": [38, 6], "IL": [47, 11], "IN": [58, 13], "IQ": [49, 11], "IR": [51, 11],
      "IS": [35, 4], "IT": [42, 9], "JM": [22, 14], "JO": [48, 11], "JP": [70, 10],
      "KE": [48, 18], "KG": [56, 9], "KH": [63, 16], "KP": [68, 9], "KR": [68, 10],
      "KW": [50, 12], "KZ": [54, 8], "LA": [63, 14], "LB": [47, 11], "LK": [57, 17],
      "LR": [37, 17], "LS": [46, 25], "LT": [45, 6], "LU": [41, 7], "LV": [45, 6],
      "LY": [43, 12], "MA": [37, 12], "MD": [46, 8], "ME": [44, 9], "MG": [50, 22],
      "MK": [44, 9], "ML": [38, 15], "MM": [61, 14], "MN": [63, 8], "MR": [37, 14],
      "MW": [47, 21], "MX": [17, 13], "MY": [64, 18], "MZ": [47, 22], "NA": [43, 23],
      "NC": [76, 23], "NE": [41, 15], "NG": [41, 16], "NI": [21, 15], "NL": [41, 7],
      "NP": [58, 12], "NZ": [78, 28], "OM": [52, 14], "PA": [22, 17], "PE": [23, 20],
      "PG": [73, 20], "PH": [67, 16], "PK": [55, 11], "PL": [44, 7], "PR": [25, 14],
      "PS": [47, 11], "PT": [38, 9], "PY": [27, 24], "QA": [51, 13], "RO": [45, 8],
      "RS": [44, 9], "RU": [57, 5], "RW": [46, 19], "SA": [49, 13], "SB": [75, 20],
      "SD": [46, 16], "SE": [43, 4], "SI": [43, 8], "SK": [44, 7], "SL": [37, 16],
      "SN": [36, 15], "SO": [50, 17], "SR": [27, 18], "SS": [46, 17], "SV": [20, 15],
      "SY": [48, 11], "SZ": [46, 24], "TD": [43, 16], "TG": [40, 16], "TH": [62, 15],
      "TJ": [55, 10], "TL": [67, 20], "TM": [52, 10], "TN": [42, 11], "TR": [47, 10],
      "TT": [26, 16], "TZ": [47, 20], "UA": [46, 7], "UG": [47, 18], "UY": [27, 26],
      "UZ": [54, 9], "VE": [25, 17], "VN": [63, 15], "VU": [77, 22], "YE": [50, 15],
      "ZA": [45, 25], "ZM": [46, 21], "ZW": [46, 23],
      # The United States centre computed from the boundary data lands in
      # the Pacific, because Alaska drags it west; this is the contiguous
      # centre instead. France, Norway, Taiwan, Hong Kong and Singapore
      # carry no ISO code in that data and are placed here by hand.
      "US": [18, 10], "FR": [40, 8], "NO": [42, 4], "TW": [66, 13],
      "HK": [65, 14], "SG": [63, 19], "XK": [44, 9], "MP": [74, 14],
      "CV": [33, 15], "TO": [80, 23], "NF": [77, 25], "MU": [53, 23],
      "IM": [38, 6], "MT": [43, 11], "BH": [51, 12], "MV": [56, 18]}

# IODA writes jurisdictions out in full; the panel needs them short.
SHORT = {
    "SYRIAN ARAB REPUBLIC": "SYRIA", "RUSSIAN FEDERATION": "RUSSIA", "VIET NAM": "VIETNAM",
    "NORTHERN MARIANA ISLANDS": "N MARIANA IS", "NORFOLK ISLAND": "NORFOLK IS",
    "LAO PEOPLES DEMOCRATIC REPUBLIC": "LAOS", "DEMOCRATIC REPUBLIC OF THE CONGO": "DR CONGO",
    "UNITED STATES OF AMERICA": "UNITED STATES", "UNITED STATES": "UNITED STATES",
    "UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND": "UNITED KINGDOM",
    "IRAN ISLAMIC REPUBLIC OF": "IRAN", "BOLIVIA PLURINATIONAL STATE OF": "BOLIVIA",
    "VENEZUELA BOLIVARIAN REPUBLIC OF": "VENEZUELA", "TANZANIA UNITED REPUBLIC OF": "TANZANIA",
    "KOREA DEMOCRATIC PEOPLES REPUBLIC OF": "NORTH KOREA", "KOREA REPUBLIC OF": "SOUTH KOREA",
    "MOLDOVA REPUBLIC OF": "MOLDOVA", "PALESTINE STATE OF": "PALESTINE",
    "TAIWAN PROVINCE OF CHINA": "TAIWAN", "CONGO THE DEMOCRATIC REPUBLIC OF THE": "DR CONGO",
    "MICRONESIA FEDERATED STATES OF": "MICRONESIA", "CENTRAL AFRICAN REPUBLIC": "CAR",
    "UNITED ARAB EMIRATES": "UAE", "DOMINICAN REPUBLIC": "DOMINICAN REP",
    "EQUATORIAL GUINEA": "EQ GUINEA", "PAPUA NEW GUINEA": "PAPUA NEW GUIN",
    "TURKS AND CAICOS ISLANDS": "TURKS/CAICOS", "BRITISH VIRGIN ISLANDS": "BR VIRGIN IS",
    "SAINT VINCENT AND THE GRENADINES": "ST VINCENT", "TRINIDAD AND TOBAGO": "TRINIDAD",
    "BOSNIA AND HERZEGOVINA": "BOSNIA", "SOUTH SUDAN": "SOUTH SUDAN",
}

# ------------------------------------------------------------- text tools
def pick(c, options, font, maxw):
    """The first whole phrase that fits. A heading is never cut mid-word:
    BY SEVERITY trimmed to BY SEVERIT is not a phrase, so one that will not
    fit gives way to a shorter whole one rather than losing its last letters."""
    for t in options:
        if c.text_width(t, font) <= maxw:
            return t
    return ""

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

def dig(obj, path, fallback = None):
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -/"

def clean(s):
    """Panel-safe uppercase. Brackets and commas are not in the keep set,
    so IRAN (ISLAMIC REPUBLIC OF) arrives here as IRAN ISLAMIC REPUBLIC OF
    and CONGO, THE DEMOCRATIC REPUBLIC OF THE keeps the words that tell it
    apart from its neighbour of almost the same name."""
    t = str(s).upper()
    out, last_space = "", True
    for ch in t.elems():
        if KEEP.find(ch) < 0:
            continue
        if ch == " ":
            if last_space:
                continue
            last_space = True
        else:
            last_space = False
        out += ch
    return out.strip()

def display_name(s):
    """The full name, then the short form when there is one. The table is
    keyed on the cleaned name, so it has to be consulted after cleaning
    and before anything is measured."""
    n = clean(s)
    return SHORT.get(n, n)

def name_or_code(c, name, code, font, maxw):
    """A name is never cut into a different place: NORTHERN MARIANA
    ISLANDS clipped to NORTHERN MARIAN is not a country, so a name that
    will not fit falls back to its two-letter code."""
    if c.text_width(name, font) <= maxw:
        return name
    if code != "" and c.text_width(code, font) <= maxw:
        return code
    return clip(c, name, font, maxw)

def compact(n):
    if n < 1000:
        return str(n)
    if n < 999500:
        return str((n + 500) // 1000) + "K"
    tenths = (n + 50000) // 100000
    return str(tenths // 10) + "." + str(tenths % 10) + "M"

def band(score, lo, hi):
    # Every place scoring the same is not every place at the maximum, so a
    # spread of zero paints the middle of the ramp, not the top of it.
    if hi <= lo:
        return RAMP[1]
    i = (score - lo) * 3 // (hi - lo)
    return RAMP[2 if i > 2 else (0 if i < 0 else i)]

# ------------------------------------------------------------------- feed
def fetch(ctx, scoped):
    wlabel = str(ctx.inputs.get("window", "24 HOURS")).strip().upper()
    if wlabel not in WINDOWS:
        wlabel = "24 HOURS"
    win = WINDOWS[wlabel]
    scope = str(ctx.inputs.get("scope", "COUNTRIES")).strip().upper()
    if scope != "REGIONS":
        scope = "COUNTRIES"
    # The map is always countries: a region code cannot be placed on a
    # world map this size. The ranking honours the setting.
    kind = "region" if (scoped and scope == "REGIONS") else "country"
    base = {"win": win[1], "scope": scope, "kind": kind}

    until = ctx.now.unix
    r = http.get(API, params = {"from": str(until - win[0]), "until": str(until),
                                "entityType": kind, "limit": "200"},
                 headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return dict(base, ok = False, head = "IODA OFFLINE", sub = "RETRY IN 15 MIN")
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return dict(base, ok = False, head = "OUTAGE FEED ERROR",
                    sub = "HTTP " + str(r["status_code"]) + " - RETRY LATER")
    rows = get(r["json"], "data", [])
    if type(rows) != "list":
        return dict(base, ok = False, head = "OUTAGE FEED ERROR", sub = "UNEXPECTED ANSWER")

    hits = []
    for row in rows:
        score = dig(row, ["scores", "overall"], None)
        if type(score) != "int" and type(score) != "float":
            continue
        s = int(score)
        if s <= 0:
            continue
        name = display_name(dig(row, ["entity", "name"], ""))
        if name == "":
            continue
        hits.append({"name": name, "code": str(dig(row, ["entity", "code"], "")).upper(),
                     "score": s, "events": get(row, "event_cnt", 0)})
    for i in range(1, len(hits)):
        k = i
        for step in range(i):
            if k > 0 and hits[k]["score"] > hits[k - 1]["score"]:
                hits[k], hits[k - 1] = hits[k - 1], hits[k]
                k -= 1
    lo = hits[len(hits) - 1]["score"] if len(hits) > 0 else 0
    hi = hits[0]["score"] if len(hits) > 0 else 0
    return dict(base, ok = True, hits = hits, lo = lo, hi = hi)

# ---------------------------------------------------------------- chrome
def fail_screen(c, d):
    c.fill("black")
    rail(c, OFFLINE)
    leg = {"#": FAINT}
    c.sprite(WORLD, MAP_X, 0, legend = leg)
    hf = fit(c, d["head"], ["6x8", "5x7", "4x5"], 172)
    c.text(hf[1], 96, 10, font = hf[0], color = "amber", align = "center")
    sf = fit(c, d["sub"], ["4x5", "picopixel"], 172)
    c.text(sf[1], 96, 22, font = sf[0], color = DIM, align = "center")

# ----------------------------------------------------------- page: the map
def worldmap(c, ctx):
    d = fetch(ctx, False)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    c.sprite(WORLD, MAP_X, 0, legend = {"#": LAND})
    hits = d["hits"]
    tx = 94

    if len(hits) == 0:
        rail(c, OK)
        pill(c, "ALL CLEAR", OK, tx, 0)
        c.text("NO OUTAGES", tx, 12, font = "6x8", color = OK)
        # The column beside the map is 88 px, too narrow for the long form
        # at 7 DAYS, so the phrase shortens a step at a time instead.
        c.text(pick(c, ["DETECTED IN THE LAST " + d["win"], "IN THE LAST " + d["win"],
                        "LAST " + d["win"], d["win"]], "4x5", 88),
               tx, 24, font = "4x5", color = DIM)
        return

    worst = hits[0]
    rail(c, band(worst["score"], d["lo"], d["hi"]))

    # Least severe first, so the worst wins the pixel where two countries
    # sit a cell apart.
    for i in range(len(hits) - 1, -1, -1):
        h = hits[i]
        spot = AT.get(h["code"], None)
        if spot == None:
            continue
        x, y = MAP_X + spot[0], spot[1]
        col = band(h["score"], d["lo"], d["hi"])
        c.rect(x, y, x + 1 if x + 1 < MAP_X + MAP_W else x, y + 1 if y < 31 else y, fill = col)

    w = pill(c, "OUTAGES", RAMP[2], tx, 0)
    c.text(d["win"], 181, 1, font = "4x5", color = DIM, align = "right")
    # Name y 8..15, severity and events y 17..21, the count y 23..27: the
    # label and the value shared a row before and ran through each other.
    nm = name_or_code(c, worst["name"], worst["code"], "6x8", 88)
    nf = fit(c, nm, ["6x8", "5x7", "4x5"], 88)
    c.text(nf[1], tx, 8, font = nf[0], color = INK)
    sev = "SEV " + compact(worst["score"])
    c.text(sev, tx, 17, font = "4x5", color = INK)
    ev = worst["events"]
    if type(ev) == "int" and ev > 0:
        c.text(str(ev) + (" EVENT" if ev == 1 else " EVENTS"), tx + c.text_width(sev, "4x5") + 5,
               17, font = "4x5", color = DIM)
    n = len(hits)
    c.text(str(n) + (" PLACE HIT" if n == 1 else " PLACES HIT"), tx, 23, font = "4x5", color = DIM)

# --------------------------------------------------------- page: the worst
def worst(c, ctx):
    d = fetch(ctx, True)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    hits = d["hits"]
    if len(hits) == 0:
        rail(c, OK)
        pill(c, "ALL CLEAR", OK, 10, 0)
        c.text("NO OUTAGES DETECTED", 96, 12, font = "6x8", color = OK, align = "center")
        c.text("IN THE LAST " + d["win"] + " ANYWHERE IN THE WORLD", 96, 24, font = "4x5",
               color = DIM, align = "center")
        return

    rail(c, band(hits[0]["score"], d["lo"], d["hi"]))
    w = pill(c, "WORST OUTAGES", RAMP[2], 10, 0)
    x = 10 + w + 3
    right = d["win"] + ("  " + str(len(hits)) + " HIT")
    c.text(right, 181, 1, font = "4x5", color = DIM, align = "right")
    # A three digit hit count squeezes this heading, so it drops the scope
    # word first and the whole heading last.
    c.text(pick(c, ["BY SEVERITY  " + d["kind"].upper(), "BY SEVERITY", "BY SEV", ""], "4x5",
                181 - c.text_width(right, "4x5") - 5 - x + 1), x, 1, font = "4x5", color = INK)

    # Four rows on a 6 px pitch: rank, place, severity bar, score.
    shown = hits[:4]
    for i in range(len(shown)):
        h = shown[i]
        y = 8 + i * 6
        sc = compact(h["score"])
        sw = c.text_width(sc, "4x5")
        col = band(h["score"], d["lo"], d["hi"])
        c.text(str(i + 1), 10, y, font = "4x5", color = col)
        c.text(name_or_code(c, h["name"], h["code"], "4x5", 71), 16, y, font = "4x5", color = INK)
        bx, bmax = 90, 181 - sw - 5 - 90
        bw = bmax * h["score"] // d["hi"] if d["hi"] > 0 else 0
        if bw > 0:
            c.rect(bx, y, bx + bw - 1, y + 4, fill = col)
        c.text(sc, 181, y, font = "4x5", color = DIM, align = "right")
