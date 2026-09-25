# NFL Division Race
#
# The four clubs of your team's division, in standings order, and a card
# for your team: record, place, games behind or magic number, playoff seed,
# streak, point differential.
#
#   race  A hanging division banner (AFC red / NFC blue, gold once the
#         title is decided), then all four logos left to right, first place
#         to fourth, each with its record and streak under it. Whoever is in
#         first has the record in gold. Your club's record sits on a
#         navy nameplate.
#   team  The banner, your club's logo, its record as the hero, where it
#         stands in the division above it, and four labelled numbers on
#         the right.
#
# DESIGN. The race page is a starting grid: nothing but the four clubs
# lined up in order, because the order IS the news. Four 40 x 24 logos take
# 166 of the panel's 192 pixels, so the division name cannot sit beside
# them as a line of text. It hangs down the left edge instead as the thing
# every stadium has in its rafters: a division banner, swallow-tailed, in
# the conference's colour, with AFC cut out of it in black and a star
# under it, and the direction in white beside it. When the division is
# clinched (or the season is over) the banner turns gold - that is the one
# loud moment the page saves itself for. Under the logos, the record in
# white (gold for first place) and the streak beside it, green W / red L,
# so four records read as four trends. Your club's record sits on a navy
# nameplate, like a broadcast lower third (a plate behind the whole logo
# swallowed the dark logos - Jets, Colts, Texans). The team page keeps
# the banner and swaps the grid for one club: its logo, the record in
# 16x20 as the thing you read from across the room, the place in the
# header (gold when leading, a gold trophy once the title is won, red when
# out of the race), and SEED / STRK / DIFF plus GB (chasing) or MAGIC
# (leading) on the right, green when they help and red when they hurt.
# Logos are the 40 x 24 pixel art from Fantasy Football News, drawn at
# their authored size.
#
# Data: ESPN's standings with level=3 (conference -> division -> four
# entries) and seasontype=2, so preseason records never count. ESPN does
# NOT sort a finished season (2025's AFC West comes back LAC, KC, LV, DEN
# with 14-3 Denver last), so the rows are sorted here by playoff seed,
# which is a full conference ranking with ESPN's tiebreaks already applied.
# One call, 160 KB, cached for the 1800 s refresh.

STANDINGS = "https://site.web.api.espn.com/apis/v2/sports/football/nfl/standings"
HEADERS = {"User-Agent": "glance-nfl-division-race (glance-led.dev)"}
TTL = 1800
GAMES = 17     # regular-season games per club

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
GOLD = "#FFC62F"
GOOD = "#2FE06F"
BAD = "#FF4A3D"
OFFLINE = "#3C4043"
SPOT = "#22346A"   # the nameplate under your club
# Conference banners. AFC is a deeper red than BAD so the banner never
# reads as an alarm; NFC is lifted from the league's navy, which is too
# dark to light an LED.
CONF_COLOR = {"AFC": "#D8202E", "NFC": "#2F6BFF"}

# ------------------------------------------------------------------ layout
# Banner x 6..12 with the conference cut out of it; the direction runs
# beside it in white at x 14..18 ("W" is 5 wide). Nothing lights x 0..5 or
# 186..191, so the app never runs into its neighbours on a scroll wall. A first try cut both
# words into one 14 px banner, and the two columns read across as
# "AW / FE / CS" - the direction has to look different to read down.
# Logos: 40 px cells at x 20, 62, 104, 146 with 2 px of black between
# them, so the grid spans x 20..185: 1 px clear of the direction letters,
# 6 px of padding at the right edge.
BAN_L = 6
BAN_R = 12
BAN_CX = 9           # conference letters x 7..10, star x 7..11
DIR_CX = 16          # direction letters x 14..18
CELL_X = [20, 62, 104, 146]
CELL_W = 40
REC_Y = 25     # record row under the 24 px logos (y 0..23), 1 px clear

# Team card: the same banner, the logo in the first grid cell (x 20..59),
# text from x 64, stat block x 146..185.
CARD_TX = 64
STAT_L = 146
STAT_R = 185

# Dropdown label -> ESPN abbreviation.
TEAMS = {
    "ARIZONA CARDINALS": "ARI", "ATLANTA FALCONS": "ATL", "BALTIMORE RAVENS": "BAL",
    "BUFFALO BILLS": "BUF", "CAROLINA PANTHERS": "CAR", "CHICAGO BEARS": "CHI",
    "CINCINNATI BENGALS": "CIN", "CLEVELAND BROWNS": "CLE", "DALLAS COWBOYS": "DAL",
    "DENVER BRONCOS": "DEN", "DETROIT LIONS": "DET", "GREEN BAY PACKERS": "GB",
    "HOUSTON TEXANS": "HOU", "INDIANAPOLIS COLTS": "IND", "JACKSONVILLE JAGUARS": "JAX",
    "KANSAS CITY CHIEFS": "KC", "LAS VEGAS RAIDERS": "LV", "LOS ANGELES CHARGERS": "LAC",
    "LOS ANGELES RAMS": "LAR", "MIAMI DOLPHINS": "MIA", "MINNESOTA VIKINGS": "MIN",
    "NEW ENGLAND PATRIOTS": "NE", "NEW ORLEANS SAINTS": "NO", "NEW YORK GIANTS": "NYG",
    "NEW YORK JETS": "NYJ", "PHILADELPHIA EAGLES": "PHI", "PITTSBURGH STEELERS": "PIT",
    "SAN FRANCISCO 49ERS": "SF", "SEATTLE SEAHAWKS": "SEA", "TAMPA BAY BUCCANEERS": "TB",
    "TENNESSEE TITANS": "TEN", "WASHINGTON COMMANDERS": "WSH",
}

# Literal asset paths (the lint checks each c.image argument exists).
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png", "CAR": "CAR.png",
    "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png", "DAL": "DAL.png", "DEN": "DEN.png",
    "DET": "DET.png", "GB": "GB.png", "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png",
    "KC": "KC.png", "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png", "NYJ": "NYJ.png",
    "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png", "SEA": "SEA.png", "TB": "TB.png",
    "TEN": "TEN.png", "WSH": "WSH.png", "NFL": "NFL.png",
}

# ESPN has used both spellings for a few clubs over the years.
ALIAS = {"WAS": "WSH", "LA": "LAR", "JAC": "JAX", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# 5 x 5 star cut out of the banner under the conference letters.
STAR = """
..X..
XXXXX
.XXX.
.X.X.
X...X
"""

# 7 x 6 trophy beside the header when the division is won.
TROPHY = """
XXXXXXX
X.XXX.X
.XXXXX.
..XXX..
...X...
..XXX..
"""

# ------------------------------------------------------------------ helpers
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def num(s, fallback = 0):
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    if t == "":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return -int(t) if neg else int(t)

def fnum(v, fallback = 0.0):
    if type(v) == "int" or type(v) == "float":
        return float(v)
    return fallback

def clip(c, text, font, maxw):
    t = str(text)
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

def ordinal(n):
    return {1: "1ST", 2: "2ND", 3: "3RD"}.get(n, str(n) + "TH")

def logo(c, abbr, x, y):
    c.image(LOGO.get(abbr, LOGO["NFL"]), x, y)

# ------------------------------------------------------------------ feed
def parse_entry(e):
    s = {}
    v = {}
    for st in get(e, "stats", []):
        k = str(get(st, "name", ""))
        s[k] = str(get(st, "displayValue", ""))
        v[k] = get(st, "value", None)
    abbr = str(get(get(e, "team", {}), "abbreviation", "")).upper()
    abbr = ALIAS.get(abbr, abbr)
    w, l, t = num(s.get("wins", "0")), num(s.get("losses", "0")), num(s.get("ties", "0"))
    rec = str(w) + "-" + str(l) + ("-" + str(t) if t > 0 else "")
    # A row with no gamesBehind stat is never "first" (an entry with its
    # stats missing must not claim a tie for the lead).
    gb = s.get("gamesBehind", "?").strip()
    gp = w + l + t
    pct = fnum(v.get("winPercent"), (w + 0.5 * t) / gp if gp > 0 else 0.0)
    sk = s.get("streak", "").strip().upper()
    if len(sk) < 2 or not (sk.startswith("W") or sk.startswith("L") or sk.startswith("T")):
        sk = ""
    return {
        "abbr": abbr, "rec": rec, "w": w, "l": l, "t": t, "gp": gp, "pct": pct,
        "gb": gb, "gbv": fnum(v.get("gamesBehind"), 0.0 if gb in ["-", "0"] else 99.0),
        "first": gb == "-" or gb == "0",
        "streak": sk,
        "seed": num(s.get("playoffSeed", "0")),
        "diff": s.get("pointDifferential", s.get("differential", "")).strip(),
        "div": s.get("divisionRecord", "").strip(),
    }

def order(rows):
    """Standings order. playoffSeed (1-16) is a whole-conference ranking
    with ESPN's tiebreaks applied, so within a division it sorts the four
    clubs exactly - and ESPN's own entry order cannot be trusted once a
    season is over. Without seeds: fewest games behind, best win %."""
    if len(rows) > 0 and min([r["seed"] for r in rows]) > 0:
        return sorted(rows, key = lambda r: r["seed"])
    return sorted(rows, key = lambda r: (r["gbv"], -r["pct"]))

def standing(rows):
    """Adds the race state to the sorted rows of one division:
    played (most games by any club), final, clinched, and per row
    lead (in first), champ, place label, out (eliminated), magic."""
    played = max([r["gp"] for r in rows]) if len(rows) > 0 else 0
    final = len(rows) > 1 and min([r["gp"] for r in rows]) >= GAMES
    seeded = min([r["seed"] for r in rows]) > 0
    top = rows[0]
    second = rows[1] if len(rows) > 1 else None
    firsts = len([r for r in rows if r["first"]])
    # Decided: nobody can reach the leader's wins, or the season is over
    # and the winner is known (a seed 1-4, or one club alone in first).
    clinched = False
    if played > 0 and second != None:
        clinched = top["w"] > second["w"] + (GAMES - second["gp"])
        if final and (seeded or firsts == 1):
            clinched = True
    leader_w = top["w"]
    for i in range(len(rows)):
        r = rows[i]
        r["champ"] = clinched and i == 0
        r["lead"] = played > 0 and ((r["first"] and not clinched) or r["champ"])
        r["out"] = played > 0 and i > 0 and (clinched or r["w"] + (GAMES - r["gp"]) < leader_w)
        r["magic"] = 0
        if played == 0:
            r["place"] = ""
        elif r["champ"] or (r["lead"] and ((seeded and r["seed"] <= 4) or firsts == 1)):
            r["place"] = "1ST"
        elif r["lead"]:
            r["place"] = "T-1ST"
        else:
            r["place"] = ordinal(i + 1)
        if i == 0 and second != None and played > 0 and not clinched:
            # Leader's wins plus the runner-up's losses that end the race.
            r["magic"] = GAMES + 1 - r["w"] - second["l"]
    return {"played": played, "final": final, "clinched": clinched}

def fetch():
    r = http.get(STANDINGS, params = {"level": "3", "seasontype": "2"}, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return {"ok": False, "head": "ESPN OFFLINE", "sub": "STANDINGS BACK SOON"}
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "head": "STANDINGS ERROR", "sub": "HTTP " + str(r["status_code"]) + " - RETRY SOON"}
    divs = []
    for conf in get(r["json"], "children", []):
        cabbr = str(get(conf, "abbreviation", "")).upper()
        for dv in get(conf, "children", []):
            name = str(get(dv, "name", "")).upper()
            rows = [parse_entry(e) for e in get(get(dv, "standings", {}), "entries", [])]
            rows = order([x for x in rows if x["abbr"] != ""])
            if len(rows) == 0:
                continue
            parts = name.split(" ")
            direction = parts[len(parts) - 1] if len(parts) > 1 else name
            if cabbr == "" and len(parts) > 1:
                cabbr = parts[0]
            divs.append({"conf": cabbr, "dir": direction, "name": name, "rows": rows, "state": standing(rows)})
    return {"ok": True, "divs": divs}

def find(ctx):
    """[state, division, index of your team] for the dropdown's team."""
    label = str(ctx.inputs.get("team", "KANSAS CITY CHIEFS")).strip().upper()
    abbr = TEAMS.get(label, "KC")
    d = fetch()
    if not d["ok"]:
        return [d, None, -1]
    for dv in d["divs"]:
        for i in range(len(dv["rows"])):
            if dv["rows"][i]["abbr"] == abbr:
                return [d, dv, i]
    return [d, None, -1]

# ------------------------------------------------------------------ screens
def rail(c, color):
    # x 6..7: the first two columns inside the safe zone.
    c.rect(6, 0, 7, 31, fill = color)

def message(c, color, head, sub, head_color):
    c.fill("black")
    rail(c, color)
    logo(c, "NFL", 10, 4)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 128)
    c.text(hf[1], 118, 9, font = hf[0], color = head_color, align = "center")
    sf = fit(c, sub, ["4x5", "picopixel"], 128)
    c.text(sf[1], 118, 21, font = sf[0], color = DIM, align = "center")

def trouble(c, st, dv):
    """True when a fail / empty screen was drawn instead of the page."""
    if not st["ok"]:
        message(c, OFFLINE, st["head"], st["sub"], "amber")
        return True
    if len(st["divs"]) == 0:
        # An empty table is the calm answer between seasons, not an error.
        message(c, GOOD, "NO STANDINGS YET", "THE RACE STARTS AT KICKOFF", GOOD)
        return True
    if dv == None:
        message(c, OFFLINE, "TEAM NOT LISTED", "PICK YOUR TEAM AGAIN", "amber")
        return True
    return False

# ------------------------------------------------------------------ page: race
def banner(c, conf, direction, won):
    """The division down the left edge: a rafter banner in the conference
    colour (gold once the title is decided) with a swallow tail at the
    foot, the conference cut out of it in black and a star under it, and
    the direction beside it in white, one 4x5 letter every 6 px."""
    col = GOLD if won else CONF_COLOR.get(conf, DIM)
    c.rect(BAN_L, 0, BAN_R, 31, fill = col)
    c.rect(BAN_L + 2, 31, BAN_R - 2, 31, fill = "black")
    c.pixel(BAN_CX, 30, "black")
    for i in range(min(len(conf), 3)):
        c.text(conf[i], BAN_CX, 1 + i * 6, font = "4x5", color = "black", align = "center")
    c.sprite(STAR, BAN_CX - 2, 20, legend = {"X": "black"})
    for i in range(min(len(direction), 5)):
        c.text(direction[i], DIR_CX, 1 + i * 6, font = "4x5", color = INK, align = "center")

def race(c, ctx):
    got = find(ctx)
    st, dv, me = got[0], got[1], got[2]
    if trouble(c, st, dv):
        return
    c.fill("black")
    rows = dv["rows"]
    state = dv["state"]
    banner(c, dv["conf"], dv["dir"], state["clinched"])
    for i in range(min(len(rows), 4)):
        x0 = CELL_X[i]
        row = rows[i]
        if i == me:
            # A nameplate under your club, not a plate behind its logo: a
            # full-height navy plate swallowed the dark logos (Jets green,
            # Colts / Texans / Giants navy all but vanished on it).
            c.rect(x0, REC_Y - 1, x0 + CELL_W - 1, 31, fill = SPOT)
        logo(c, row["abbr"], x0, 0)
        col = GOLD if row["lead"] else INK
        # Record + streak, centred as one group inside the cell with 1 px
        # spare at each side (38 px), so neighbouring cells' numbers never
        # run together across the 2 px gutter. "11-6" (5x7, 23) + 2 +
        # "L11" (4x5, 13) = 38 fits. A tie steps down: "9-7-1" is 29 in
        # 5x7, so with "W3" it takes 4x5 (21); "10-6-1" + a streak cannot
        # fit even in 4x5 (25 + 2 + 14), so it keeps the 5x7 record alone.
        sk = row["streak"] if state["played"] > 0 else ""
        sw = c.text_width(sk, "4x5") if sk != "" else 0
        gap = 2 if sk != "" else 0
        f = None
        if sk != "":
            for fnt in ["5x7", "4x5"]:
                if f == None and c.text_width(row["rec"], fnt) + gap + sw <= CELL_W - 2:
                    f = [fnt, row["rec"]]
        if f == None:
            sk, sw, gap = "", 0, 0
            f = fit(c, row["rec"], ["5x7", "4x5"], CELL_W - 2)
        w = c.text_width(f[1], f[0])
        total = w + (gap + sw if sk != "" else 0)
        left = x0 + (CELL_W - total) // 2
        ry = REC_Y if f[0] == "5x7" else REC_Y + 2   # both end on y 31
        c.text(f[1], left, ry, font = f[0], color = col)
        if sk != "":
            skc = GOOD if sk.startswith("W") else (BAD if sk.startswith("L") else DIM)
            # Bottom-aligned with the record's baseline (y 31).
            c.text(sk, left + w + gap, REC_Y + 2, font = "4x5", color = skc)

# ------------------------------------------------------------------ page: team
def stat_row(c, y, label, value, color):
    c.text(label, STAT_L, y, font = "4x5", color = DIM)
    v = clip(c, value, "4x5", STAT_R - STAT_L - c.text_width(label, "4x5") - 3)
    c.text(v, STAT_R, y, font = "4x5", color = color, align = "right")

def team(c, ctx):
    got = find(ctx)
    st, dv, me = got[0], got[1], got[2]
    if trouble(c, st, dv):
        return
    c.fill("black")
    row = dv["rows"][me]
    state = dv["state"]
    played = state["played"]
    banner(c, dv["conf"], dv["dir"], state["clinched"])
    logo(c, row["abbr"], CELL_X[0], 4)

    # Header y 1..5: the race state left, division record right. The
    # banner already names the division, so the header only says where
    # the club stands in it.
    right = ""
    if row["div"] != "" and played > 0:
        right = "DIV " + row["div"]
        c.text(right, STAT_R, 1, font = "4x5", color = DIM, align = "right")
    room = STAT_R - CARD_TX + 1 - (c.text_width(right, "4x5") + 5 if right != "" else 0)
    hx = CARD_TX
    if played == 0:
        head, hc = "KICKOFF SOON", INK
    elif row["champ"]:
        # The banner already says which division; the trophy says won.
        head, hc = "CHAMPIONS" if state["final"] else "CLINCHED", GOLD
        c.sprite(TROPHY, hx, 0, legend = {"X": GOLD})
        hx += 9
        room -= 9
    elif row["out"] and not state["final"]:
        head, hc = "OUT OF THE RACE", BAD
    elif state["final"]:
        head, hc = "FINAL: " + row["place"] + " PLACE", INK
    else:
        head = row["place"] + " PLACE"
        hc = GOLD if row["lead"] else INK
    c.text(clip(c, head, "4x5", room), hx, 1, font = "4x5", color = hc)

    # Hero: the record, as large as the space before the stat block allows
    # (x 64..143, 80 px). "10-6" is 67 px in 16x20; a tied "10-6-1" is 101
    # px, so it drops to 10x16 (63 px).
    hf = fit(c, row["rec"], ["16x20", "10x16", "6x8"], STAT_L - 3 - CARD_TX)
    hy = {"16x20": 9, "10x16": 11}.get(hf[0], 15)
    c.text(hf[1], CARD_TX, hy, font = hf[0], color = GOLD if row["champ"] else INK)

    # Stat block, four labelled rows at y 8 / 14 / 20 / 26 (1 px apart).
    seed = row["seed"]
    if seed > 0 and played > 0:
        stat_row(c, 8, "SEED", "#" + str(seed), GOOD if seed <= 7 else DIM)
    else:
        stat_row(c, 8, "SEED", "-", DIM)
    sk = row["streak"] if played > 0 else ""
    stat_row(c, 14, "STRK", sk if sk != "" else "-",
             GOOD if sk.startswith("W") else (BAD if sk.startswith("L") else DIM))
    df = row["diff"] if played > 0 else ""
    dn = num(df, 0)
    stat_row(c, 20, "DIFF", df if df != "" else "-", GOOD if dn > 0 else (BAD if dn < 0 else DIM))
    # The race number: MAGIC for the leader (wins by it + losses by the
    # runner-up that settle the division), GB for everyone chasing.
    if played == 0 or row["champ"]:
        stat_row(c, 26, "GB", "-", DIM)
    elif me == 0 and row["magic"] > 0:
        stat_row(c, 26, "MAGIC", str(row["magic"]), GOLD if row["magic"] <= 4 else INK)
    else:
        gb = row["gb"] if row["gb"] not in ["", "0", "?"] else "-"
        stat_row(c, 26, "GB", gb, BAD if row["out"] and not state["final"] else INK)
