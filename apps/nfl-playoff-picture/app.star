# NFL Playoff Picture
#
# If the season ended today: one conference's seven playoff seeds, drawn as
# the wild-card bracket they would make, and the teams chasing the last spot.
#
#   bracket  Seven club logos in bracket order - 1 | 2 7 | 3 6 | 4 5. The
#            top seed sits alone under a gold crown and BYE; each wild-card
#            pairing is tied together underneath by a bracket in the
#            conference colour. Each logo wears its seed as a tab on its
#            top-left corner, and its record stands alone under it.
#   hunt     The next three teams outside the field (seeds 8-10, skipping
#            any ESPN marks eliminated), each as the full-size club logo with
#            a column beside it: record, games back of the 7th seed (TIED
#            when level) and current streak.
#
# DESIGN. The bracket is the picture. Nothing on the first page is a list -
# the eye reads the pairings from the brackets before it reads a number,
# and the crowned logo on the left is the one team that rests. The
# conference is a pill in its own colour (AFC red, NFC blue) at the start of
# the title row, so which half of the league you are looking at is the
# first thing seen. The seed is a jersey-number tab on the logo's corner,
# never beside the record (a "2" next to "2-0" read as "22-0"): a solid tab
# is a division winner (gold for the bye, conference colour for 2-4), a bare
# tinted numeral a wild card (5-7) - which is why a 1-1 division leader can
# sit above a 2-0 wild card. Records are white; a record turns green once
# ESPN marks the club clinched (x, y, z or *). On the bracket a tie count is
# dimmed ("11-5" bright, "-1" dim) so two full-width tie records side by side
# still read as two. The right of the title row
# carries the table's state: CLINCHED with a green check once anyone has,
# "2025 FINAL" in gold when every club is flagged (ESPN serves last
# season's final table in the offseason, and the title becomes PLAYOFF
# FIELD), else the season year. On the hunt page the gold ticket is the last
# playoff spot, TIED is gold, and the streak is green for W, red for L -
# in September every chaser is TIED and the run is what tells them apart.
# The hunt page switches to the user's hand-tuned 40 x 24 logos, big enough
# to read from across the room, because three teams can afford the room
# seven cannot; the seed tab moves to the bottom-left corner there so it
# never lands next to the previous zone's record. The offline card shows a
# 2x football, the preseason card and FIELD IS SET a 2x Lombardi.
#
# Data: ESPN standings (site.web.api, one 160 KB call) carry every club's
# playoffSeed, record and clincher. Standings move once a week, so refresh
# and the cache are both 1800 s.

STANDINGS = "https://site.web.api.espn.com/apis/v2/sports/football/nfl/standings"
HEADERS = {"User-Agent": "glance-nfl-playoff-picture (glance-led.dev)"}
TTL = 1800

# ------------------------------------------------------------------ palette
INK = "#F4F7FF"
DIM = "#6E7A94"
GOLD = "#FFC62F"
CLINCH = "#2FE06F"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
LOSS = "#FF4A4A"
CONF_COLOR = {"AFC": "#E8203F", "NFC": "#2F6BFF"}
# Seed numerals 2-7 in a light tint of the conference colour, so a white
# record never runs into a white numeral ("2 2-0" read as "22-0").
SEED_TINT = {"AFC": "#FF7A8A", "NFC": "#86AEFF"}

# -------------------------------------------------------------------- logos
# Two authored sizes, never scaled at draw time: 24 x 18 for the seven-team
# bracket, the hand-tuned 40 x 24 set for the three-team hunt page.
LOGO_S = {
    "ARI": "S/ARI.png", "ATL": "S/ATL.png", "BAL": "S/BAL.png", "BUF": "S/BUF.png",
    "CAR": "S/CAR.png", "CHI": "S/CHI.png", "CIN": "S/CIN.png", "CLE": "S/CLE.png",
    "DAL": "S/DAL.png", "DEN": "S/DEN.png", "DET": "S/DET.png", "GB": "S/GB.png",
    "HOU": "S/HOU.png", "IND": "S/IND.png", "JAX": "S/JAX.png", "KC": "S/KC.png",
    "LAC": "S/LAC.png", "LAR": "S/LAR.png", "LV": "S/LV.png", "MIA": "S/MIA.png",
    "MIN": "S/MIN.png", "NE": "S/NE.png", "NO": "S/NO.png", "NYG": "S/NYG.png",
    "NYJ": "S/NYJ.png", "PHI": "S/PHI.png", "PIT": "S/PIT.png", "SEA": "S/SEA.png",
    "SF": "S/SF.png", "TB": "S/TB.png", "TEN": "S/TEN.png", "WSH": "S/WSH.png",
}
LOGO_L = {
    "ARI": "L/ARI.png", "ATL": "L/ATL.png", "BAL": "L/BAL.png", "BUF": "L/BUF.png",
    "CAR": "L/CAR.png", "CHI": "L/CHI.png", "CIN": "L/CIN.png", "CLE": "L/CLE.png",
    "DAL": "L/DAL.png", "DEN": "L/DEN.png", "DET": "L/DET.png", "GB": "L/GB.png",
    "HOU": "L/HOU.png", "IND": "L/IND.png", "JAX": "L/JAX.png", "KC": "L/KC.png",
    "LAC": "L/LAC.png", "LAR": "L/LAR.png", "LV": "L/LV.png", "MIA": "L/MIA.png",
    "MIN": "L/MIN.png", "NE": "L/NE.png", "NO": "L/NO.png", "NYG": "L/NYG.png",
    "NYJ": "L/NYJ.png", "PHI": "L/PHI.png", "PIT": "L/PIT.png", "SEA": "L/SEA.png",
    "SF": "L/SF.png", "TB": "L/TB.png", "TEN": "L/TEN.png", "WSH": "L/WSH.png",
}
ALIAS = {"WAS": "WSH", "LA": "LAR", "JAC": "JAX", "OAK": "LV", "SD": "LAC"}

# ------------------------------------------------------------------- layout
# Bracket page: seven 24 px cells from x 6 with 2 px between, so the last
# ends at x 185 - 6 px of edge padding each side. Title row y 0..4, logos
# y 6..23, bracket bars y 25, seed + record y 27..31.
CELL = 24
GAP = 2
X0 = 6
LOGO_Y = 6
BAR_Y = 25
REC_Y = 27
ORDER = [1, 2, 7, 3, 6, 4, 5]     # bracket order, left to right
PAIRS = [[1, 2], [3, 4], [5, 6]]  # cell indexes joined by a bar

# Hunt page: up to three zones of a 40 x 24 logo plus a text column of at
# least 17 px, 3 px apart: 3 * 58 + 2 * 3 = 180, x 6..185.
ZGAP = 3
COL_W = 17

CROWN = """
X.X.X
XXXXX
XXXXX
"""
# 5-row title-row icons, one per idea, so the row reads without its words:
# a football (the NFL playoffs - a 5 px Lombardi read as the letter I), a
# check (clinched), a target (the hunt) and a ticket (the last spot).
CHECK = """
....X
...XX
X.XX.
XXX..
.X...
"""
TARGET = """
.XXX.
X...X
X.X.X
X...X
.XXX.
"""
TICKET = """
XXXXXXXXX
XX.XXXXXX
.X.XXXXX.
XX.XXXXXX
XXXXXXXXX
"""
BALL_LEG = {"D": "#7A3E12", "B": "#B8652A", "W": "#FFFFFF"}

# 11 x 7 football for the offline card; 9 x 11 Lombardi for the quiet card.
BALL = """
...DDDDD...
.DBBBBBBBD.
DBBWBWBWBBD
DBWWWWWWWBD
DBBWBWBWBBD
.DBBBBBBBD.
...DDDDD...
"""
TROPHY_BIG = """
...XXX...
..XXXXX..
..XXXXX..
...XXX...
....X....
....X....
....X....
...XXX...
.YYYYYYY.
.YYYYYYY.
YYYYYYYYY
"""

# ---------------------------------------------------------------- helpers
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def num(s, fallback = 0):
    t = str(s).strip()
    if t.endswith(".0"):
        t = t[:len(t) - 2]
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    if t == "":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return -int(t) if neg else int(t)

def clip(c, text, font, maxw):
    t = str(text)
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    f = fonts[len(fonts) - 1]
    return [f, clip(c, text, f, maxw)]

HEXD = "0123456789abcdef"

def ink_for(fill):
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def record(t):
    r = str(t["w"]) + "-" + str(t["l"])
    return r + "-" + str(t["t"]) if t["t"] > 0 else r

# ------------------------------------------------------------------- data
def conference(ctx):
    v = str(ctx.inputs.get("conference", "AFC")).strip().upper()
    return v if v in CONF_COLOR else "AFC"

def fetch(conf):
    r = http.get(STANDINGS, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return {"ok": False, "head": "ESPN OFFLINE", "sub": "STANDINGS RETURN IN 30 MIN"}
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "head": "STANDINGS ERROR", "sub": "HTTP " + str(r["status_code"]) + " - RETRY SOON"}
    node = None
    for ch in get(r["json"], "children", []):
        if str(get(ch, "abbreviation", "")).upper() == conf:
            node = ch
    if node == None:
        return {"ok": False, "head": "NO " + conf + " STANDINGS", "sub": "ESPN SENT NONE - RETRY SOON"}
    teams = []
    played = 0
    for e in get(get(node, "standings", {}), "entries", []):
        abbr = str(get(get(e, "team", {}), "abbreviation", "")).upper()
        abbr = ALIAS.get(abbr, abbr)
        s = {}
        for st in get(e, "stats", []):
            s[str(get(st, "name", ""))] = get(st, "displayValue", get(st, "value", ""))
        seed = num(s.get("playoffSeed", ""), 99)
        t = {"abbr": abbr, "seed": seed, "w": num(s.get("wins", "")), "l": num(s.get("losses", "")),
             "t": num(s.get("ties", "")), "clinch": str(s.get("clincher", "")).strip().lower(),
             "streak": str(s.get("streak", "")).strip().upper()}
        played += t["w"] + t["l"] + t["t"]
        if seed >= 1 and seed <= 16 and abbr in LOGO_S:
            teams.append(t)
    teams = sorted(teams, key = lambda t: t["seed"])

    # A duplicated playoffSeed would leave a hole in the bracket; re-seat
    # every club by list order so seeds 1..n are always filled.
    for i in range(len(teams)):
        teams[i]["seed"] = i + 1

    # Every club flagged (clinched or eliminated) means the table is final -
    # ESPN serves last season's final standings from February to August.
    final = len(teams) > 0
    for t in teams:
        if t["clinch"] == "":
            final = False
    year = num(get(get(r["json"], "season", {}), "year", ""), 0)
    return {"ok": True, "teams": teams, "played": played, "final": final, "year": year}

def clinched(t):
    return t["clinch"] in ["x", "y", "z", "*"]

def eliminated(t):
    return t["clinch"] == "e"

# ----------------------------------------------------------------- screens
def rail(c, color):
    # x 6..7: nothing lights x 0..5 or 186..191, so the app never runs
    # into its neighbours on a scroll wall.
    c.rect(6, 0, 7, 31, fill = color)

def fail_screen(c, d):
    c.fill("black")
    rail(c, OFFLINE)
    c.sprite(BALL, 10, 9, legend = BALL_LEG, scale = 2)
    hf = fit(c, d["head"], ["6x8", "5x7", "4x5"], 150)
    c.text(hf[1], 110, 8, font = hf[0], color = "#E8B04A", align = "center")
    sf = fit(c, d["sub"], ["4x5", "picopixel"], 150)
    c.text(sf[1], 110, 21, font = sf[0], color = DIM, align = "center")

def quiet_screen(c, conf, head, sub):
    """Nothing to rank yet is an answer, not an error: green and calm."""
    c.fill("black")
    rail(c, GOOD)
    c.sprite(TROPHY_BIG, 10, 5, legend = {"X": "#D9DEE8", "Y": GOLD}, scale = 2)
    conf_pill(c, conf, 30, 13)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 130)
    c.text(hf[1], 118, 8, font = hf[0], color = GOOD, align = "center")
    sf = fit(c, sub, ["4x5", "picopixel"], 130)
    c.text(sf[1], 118, 21, font = sf[0], color = DIM, align = "center")

def conf_pill(c, conf, x, y):
    fill = CONF_COLOR[conf]
    c.badge(conf, x, y, color = ink_for(fill), bg = fill, font = "4x5")
    return c.text_width(conf, "4x5") + 4

def ready(c, ctx):
    """Fetch and route the failure and empty states. Returns the data only
    when there is a picture to draw."""
    conf = conference(ctx)
    d = fetch(conf)
    if not d["ok"]:
        fail_screen(c, d)
        return None
    if len(d["teams"]) < 7:
        fail_screen(c, {"head": "SEEDS NOT POSTED", "sub": "ESPN HAS NO " + conf + " SEEDS YET"})
        return None
    if d["played"] == 0:
        quiet_screen(c, conf, "NO GAMES PLAYED YET", "SEEDS ARE SET AFTER WEEK 1")
        return None
    d["conf"] = conf
    return d

# ------------------------------------------------------------ page: bracket
def cell_x(i):
    return X0 + i * (CELL + GAP)

def seed_badge(c, seed, x, y, conf):
    """The seed as a jersey-number tab on the logo's top-left corner, ringed
    in black so it never merges with the logo art. A solid tab = a division
    winner (gold for the bye, conference colour for 2-4); a bare tinted
    numeral on black = a wild card (5-7), so the two kinds of seed read
    apart without a legend."""
    t = str(seed)
    w = c.text_width(t, "4x5")
    c.rect(x, y, x + w + 3, y + 8, fill = "black")
    if seed == 1:
        c.rect(x + 1, y + 1, x + w + 2, y + 7, fill = GOLD)
        c.text(t, x + 2, y + 2, font = "4x5", color = "black")
    elif seed <= 4:
        c.rect(x + 1, y + 1, x + w + 2, y + 7, fill = CONF_COLOR[conf])
        c.text(t, x + 2, y + 2, font = "4x5", color = "white")
    else:
        c.text(t, x + 2, y + 2, font = "4x5", color = SEED_TINT[conf])

def title_row(c, d, x0, words):
    """Pill + title from x0; the right tag carries the table's state.
    Returns nothing - everything is measured against the right edge 185."""
    conf = d["conf"]
    x = x0 + conf_pill(c, conf, x0, 0) + 3
    if d["final"]:
        tag = [(str(d["year"]) + " FINAL") if d["year"] > 0 else "FINAL", GOLD, None]
    elif d["any_clinch"]:
        tag = ["CLINCHED", CLINCH, CHECK]
    else:
        tag = [(str(d["year"]) + " SEASON") if d["year"] > 0 else "THIS SEASON", DIM, None]
    right = 185
    tag_w = c.text_width(tag[0], "4x5")
    c.text(tag[0], right, 0, font = "4x5", color = tag[1], align = "right")
    if tag[2] != None:
        tag_w += 5 + 2
        c.sprite(tag[2], right - tag_w + 1, 0, legend = {"X": tag[1]})
    room = right - tag_w - 4 - x + 1
    for wd in words:
        if c.text_width(wd, "4x5") <= room:
            c.text(wd, x, 0, font = "4x5", color = INK)
            return

def bracket(c, ctx):
    d = ready(c, ctx)
    if d == None:
        return
    c.fill("black")
    conf = d["conf"]
    by_seed = {t["seed"]: t for t in d["teams"]}
    d["any_clinch"] = False
    for t in d["teams"]:
        if t["seed"] <= 7 and clinched(t):
            d["any_clinch"] = True

    # Over the top seed: crown + BYE in gold, centred on cell 0.
    bw = 5 + 2 + c.text_width("BYE", "4x5")
    bx = cell_x(0) + (CELL - bw) // 2
    c.sprite(CROWN, bx, 1, legend = {"X": GOLD})
    c.text("BYE", bx + 7, 0, font = "4x5", color = GOLD)

    # Bracket brackets: each wild-card pairing joined logo to logo by a bar
    # with a tick up into each logo, like a printed bracket; the bye seed
    # gets its own gold bracket.
    col = color.dim(CONF_COLOR[conf], 80)
    for p in PAIRS:
        a = cell_x(p[0]) + CELL // 2 - 1
        b = cell_x(p[1]) + CELL // 2 - 1
        c.rect(a, BAR_Y - 1, a, BAR_Y, fill = col)
        c.rect(b, BAR_Y - 1, b, BAR_Y, fill = col)
        c.rect(a, BAR_Y, b, BAR_Y, fill = col)
    g = color.dim(GOLD, 70)
    c.rect(cell_x(0) + 4, BAR_Y - 1, cell_x(0) + 4, BAR_Y, fill = g)
    c.rect(cell_x(0) + CELL - 5, BAR_Y - 1, cell_x(0) + CELL - 5, BAR_Y, fill = g)
    c.rect(cell_x(0) + 4, BAR_Y, cell_x(0) + CELL - 5, BAR_Y, fill = g)

    for i in range(7):
        t = by_seed.get(ORDER[i], None)
        if t == None:
            continue
        cx = cell_x(i)
        c.image(LOGO_S[t["abbr"]], cx, LOGO_Y)
        seed_badge(c, t["seed"], cx - 1, LOGO_Y + 1, conf)

        # The record stands alone under the cell - no numeral beside it.
        rc = CLINCH if clinched(t) else INK
        rf = fit(c, record(t), ["4x5", "picopixel"], CELL)
        rx = cx + (CELL - c.text_width(rf[1], rf[0])) // 2
        if t["t"] > 0 and rf[1] == record(t):
            # A tie record fills the whole cell, so two side by side
            # ("11-5-1 10-6-1") would read as one string: the tie count is
            # drawn dim, and the next record's bright wins start the break.
            head = str(t["w"]) + "-" + str(t["l"])
            tail = "-" + str(t["t"])
            gap = c.text_width(rf[1], rf[0]) - c.text_width(head, rf[0]) - c.text_width(tail, rf[0])
            c.text(head, rx, REC_Y, font = rf[0], color = rc)
            c.text(tail, rx + c.text_width(head, rf[0]) + gap, REC_Y, font = rf[0], color = color.dim(rc, 45))
        else:
            c.text(rf[1], rx, REC_Y, font = rf[0], color = rc)

    # Title last: the conference pill runs one row into the second logo's
    # top edge and must sit over it, not under.
    title_row(c, d, cell_x(1), ["PLAYOFF FIELD" if d["final"] else "PLAYOFF PICTURE", "PLAYOFFS"])

# --------------------------------------------------------------- page: hunt
def games_back(t, last):
    """Half-games behind the 7th seed. Ties cancel out of the formula."""
    return (last["w"] - t["w"]) + (t["l"] - last["l"])

def gb_text(h):
    return str(h // 2) + (".5" if h % 2 == 1 else "")

def hunt(c, ctx):
    d = ready(c, ctx)
    if d == None:
        return
    c.fill("black")
    conf = d["conf"]
    last = None
    chasers = []
    d["any_clinch"] = False
    for t in d["teams"]:
        if t["seed"] == 7:
            last = t
        elif t["seed"] >= 8 and not eliminated(t) and len(chasers) < 3:
            chasers.append(t)
        if t["seed"] <= 7 and clinched(t):
            d["any_clinch"] = True

    # Title row: pill + target + IN THE HUNT; the right tag is the last
    # playoff spot - a gold ticket, who holds it and at what record.
    x = X0 + conf_pill(c, conf, X0, 0) + 3
    c.sprite(TARGET, x, 0, legend = {"X": "#FF7A1F"})
    c.text("IN THE HUNT", x + 8, 0, font = "4x5", color = INK)
    if last != None:
        cut = "7TH " + last["abbr"] + " " + record(last)
        cw = c.text_width(cut, "4x5")
        c.text(cut, 185, 0, font = "4x5", color = GOLD, align = "right")
        c.sprite(TICKET, 185 - cw - 3 - 9 + 1, 0, legend = {"X": GOLD})

    if len(chasers) == 0 or last == None:
        c.sprite(TROPHY_BIG, 12, 8, legend = {"X": "#D9DEE8", "Y": GOLD}, scale = 2)
        c.text("FIELD IS SET", 104, 11, font = "6x8", color = GOOD, align = "center")
        c.text("EVERY OTHER " + conf + " TEAM IS OUT", 104, 23, font = "4x5", color = DIM, align = "center")
        return

    # Each zone is a 40 px logo plus a text column as wide as its widest
    # line (at least 17 px), so a tie record like 9-7-1 never clips. The
    # zones are centred as a group; the gap between them shrinks before
    # anything else gives.
    # Three wide tie records at once (10-6-1 x 3) cannot all fit: first the
    # dim GB units go, then the tie counts, then both - each step re-measures
    # every column so a line never runs into the next logo.
    cols = []
    for t in chasers:
        h = games_back(t, last)
        cols.append({"t": t, "h": h, "gb": "TIED" if h <= 0 else gb_text(h)})
    n = len(cols)
    body = 0
    for step in [[True, True], [True, False], [False, True], [False, False]]:
        body = 0
        for z in cols:
            t = z["t"]
            z["rec"] = record(t) if step[0] else str(t["w"]) + "-" + str(t["l"])
            z["unit"] = step[1] and z["h"] > 0
            gbw = c.text_width(z["gb"], "4x5") + (1 + c.text_width("GB", "3x4") if z["unit"] else 0)
            z["w"] = max(COL_W, c.text_width(z["rec"], "4x5"), gbw, c.text_width(t["streak"], "4x5"))
            body += 41 + z["w"]
        # Keep at least 2 px between zones so a line never touches the
        # next club's logo.
        if body + (n - 1) * 2 <= 180:
            break
    gap = max(0, min(ZGAP, (180 - body) // max(1, n - 1)))
    zx = X0 + (180 - body - (n - 1) * gap) // 2
    for z in cols:
        t = z["t"]
        c.image(LOGO_L[t["abbr"]], zx, 7)
        # Seed tab on the logo's bottom-left corner: the top-left would sit
        # right after the previous zone's record ("9-7-1 10" reads as one).
        seed_badge(c, t["seed"], zx - 1, 22, conf)
        tx = zx + 41
        c.text(z["rec"], tx, 8, font = "4x5", color = INK)

        # Games back of the 7th seed. Level on record reads TIED - the
        # chaser is out on nothing but a tiebreaker.
        if z["h"] <= 0:
            c.text("TIED", tx, 15, font = "4x5", color = GOLD)
        else:
            c.text(z["gb"], tx, 15, font = "4x5", color = GOLD if z["h"] <= 2 else INK)
            if z["unit"]:
                c.text("GB", tx + c.text_width(z["gb"], "4x5") + 1, 16, font = "3x4", color = DIM)

        # Streak: in September every chaser is TIED; the run is what differs.
        st = t["streak"]
        if len(st) >= 2 and st[0] in ["W", "L", "T"]:
            sc = CLINCH if st[0] == "W" else (LOSS if st[0] == "L" else DIM)
            c.text(st, tx, 22, font = "4x5", color = sc)
        zx += 41 + z["w"] + gap
