# Fantasy Weekly Projections
#
# This week's start-'em board: Sleeper's projected fantasy points for the
# top players at each position, one player per frame, ranked in the
# league's own scoring (PPR, half PPR or standard).
#
# DESIGN. A matchup card read left to right, with one loud thing on it: the
# number sits on a patch of turf. The player's club logo (the 40 x 24
# hand-drawn set) opens the card, closed off by a stripe in the position's
# colour - the one colour that tells QB from WR before a word is read. Then
# the hero: the projection in 10x16 chalk white on a dark-green field band
# with yard lines and hash marks, "PPR PROJ" above it, and under it the
# verdict against the player's season average - a green up-arrow "AVG 17.1"
# when this week is a step up, an amber down-arrow when it is a step down.
# Once the game is over the band reads FINAL: the actual points on the turf
# and the projection underneath, arrowed the same way.
# Then the player: a chip row with the rank pill (#1 RB in the position
# colour, T2 on a tie), an injury pill when Sleeper lists one (Q amber,
# D orange, OUT/IR red - the pill shortens before the tier is dropped), and
# the tier as a glyph plus a word, sized to a 12-team league: a gold star
# STUD, a green tick START, a sky diamond FLEX. First name over surname
# (a defense is city over nickname, long cities shortened), and the
# projected stat line in the position colour. The card closes on the
# opponent: "VS SUN" / "AT MON" (home or away, and the game day in the
# position colour) over their 24 x 18 logo, so the matchup reads as two
# crests facing each other across the field.
#
# Frames: refresh is 120 and each frame is one rank. A single position walks
# its top 10 (20 minutes); ALL steps QB, RB, WR, TE, K, DEF and goes one rank
# deeper each lap, top 3 each (36 minutes).
#
# Requests per render: the Sleeper week, the schedule (27 KB), the position's
# projections, its season stats (for the average) and, only when the game
# is over, its week stats. The WR feeds run 850-920 KB against a 1 MB cap, so
# any body over 1 MB is treated as too large: the average is simply left off,
# and a projections feed that is too large gets its own message (ALL skips
# on to the next position instead).

SLEEPER_STATE = "https://api.sleeper.app/v1/state/nfl"
SLEEPER_SCHED = "https://api.sleeper.app/schedule/nfl/"
SLEEPER_PROJ = "https://api.sleeper.com/projections/nfl/"
SLEEPER_STATS = "https://api.sleeper.com/stats/nfl/"
HEADERS = {"User-Agent": "glance-fantasy-weekly-projections (glance-led.dev)"}
STATE_TTL = 3600
SCHED_TTL = 1800
PROJ_TTL = 3600
SEASON_TTL = 21600
WEEK_TTL = 1800
FRAME_SECONDS = 120
MAX_BODY = 1000000   # the published http cap; the local SDK allows 2 MB

# ------------------------------------------------------------------ layout
# 192 wide, 6 px of edge padding each side.
LOGO_X = 6          # own logo x 6..45, y 4..27
LOGO_Y = 4
STRIPE_X = 48       # position stripe x 48..49
P_L = 51            # points column x 51..95
P_R = 95
P_CX = 73
TURF_T = 7          # the field band y 7..24
TURF_B = 24
N_X = 99            # name column x 99..156
N_R = 156
N_W = N_R - N_X + 1
CHIP_R = 155        # the chip row stops short of the divider
O_DIV = 158         # a hairline that closes the player off from the opponent
O_X = 161           # opponent logo x 161..184 (24 x 18), y 9..26
O_Y = 9
O_CX = 173
EDGE_R = 185

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FIRST = "#9AA3B2"     # the first name: quieter than the surname, brighter than a label
OFFLINE = "#3C4043"
DIV = "#2A3142"
GOOD = "#2FE06F"
TURF = "#0E4622"      # the field band
TURF_LINE = "#3E9A5A" # yard lines and hash marks: chalk, dimmed into the grass
UP = "#2FE06F"        # step up on the average / beat the projection
DOWN = "#FFBF00"      # step down

POS_COLOR = {"QB": "#FF6F9C", "RB": "#2EE6C8", "WR": "#5CB8FF", "TE": "#FFB45C",
             "K": "#C792FF", "DEF": "#B0BCCB"}
POSITIONS = ["QB", "RB", "WR", "TE", "K", "DEF"]

# Tier by positional rank, sized to a 12-team league: the top few at a spot
# are STUD, the rest of the weekly starters START, the next band FLEX.
# [stud through, start through]; RB and WR start two plus a flex each.
TIER_CUT = {"QB": [3, 12], "RB": [6, 24], "WR": [6, 24], "TE": [3, 12], "K": [3, 12], "DEF": [3, 12]}
C_STUD = "#FFC62F"
C_START = "#2FE06F"
C_FLEX = "#78DCFF"

# Sleeper injury_status -> [long tag, short tag, colour]; the long word is
# used when it fits beside the tier.
INJ = {
    "Questionable": ["QUES", "Q", "#FFBF00"],
    "Doubtful": ["DOUBT", "D", "#FF7A1F"],
    "Out": ["OUT", "OUT", "#FF2D2D"],
    "IR": ["IR", "IR", "#FF2D2D"],
    "PUP": ["PUP", "PUP", "#FF2D2D"],
    "Sus": ["SUSP", "SUS", "#FF7A1F"],
}

SCORING = {"PPR": ["pts_ppr", "PPR"], "HALF PPR": ["pts_half_ppr", "HALF"],
           "STANDARD": ["pts_std", "STD"]}

# A defense's first name is its city; these four overflow the name column.
SHORT_CITY = {"SAN FRANCISCO": "SAN FRAN", "PHILADELPHIA": "PHILLY",
              "JACKSONVILLE": "JAX", "INDIANAPOLIS": "INDY"}

SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]

# Playoff weeks as the league says them.
POST_WEEK = {1: "WILD CARD", 2: "DIVISIONAL", 3: "CONF CHAMP", 4: "SUPER BOWL"}

DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

# Logos, as literal paths so the asset lint can see every one.
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png", "CAR": "CAR.png",
    "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png", "DAL": "DAL.png", "DEN": "DEN.png",
    "DET": "DET.png", "GB": "GB.png", "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png",
    "KC": "KC.png", "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png", "NYJ": "NYJ.png",
    "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png", "SEA": "SEA.png", "TB": "TB.png",
    "TEN": "TEN.png", "WSH": "WSH.png", "NFL": "NFL.png",
}
SMALL = {
    "ARI": "ARI_S.png", "ATL": "ATL_S.png", "BAL": "BAL_S.png", "BUF": "BUF_S.png", "CAR": "CAR_S.png",
    "CHI": "CHI_S.png", "CIN": "CIN_S.png", "CLE": "CLE_S.png", "DAL": "DAL_S.png", "DEN": "DEN_S.png",
    "DET": "DET_S.png", "GB": "GB_S.png", "HOU": "HOU_S.png", "IND": "IND_S.png", "JAX": "JAX_S.png",
    "KC": "KC_S.png", "LV": "LV_S.png", "LAC": "LAC_S.png", "LAR": "LAR_S.png", "MIA": "MIA_S.png",
    "MIN": "MIN_S.png", "NE": "NE_S.png", "NO": "NO_S.png", "NYG": "NYG_S.png", "NYJ": "NYJ_S.png",
    "PHI": "PHI_S.png", "PIT": "PIT_S.png", "SF": "SF_S.png", "SEA": "SEA_S.png", "TB": "TB_S.png",
    "TEN": "TEN_S.png", "WSH": "WSH_S.png",
}

# Sleeper writes Washington as WAS; the logos are keyed WSH.
def club(abbr):
    a = str(abbr).strip().upper()
    return "WSH" if a == "WAS" else a

# ------------------------------------------------------------- pixel art
# A football, 11 x 7, for the status screens.
BALL = """
...DDDDD...
.DBBBBBBBD.
DBBWBWBWBBD
DBWWWWWWWBD
DBBWBWBWBBD
.DBBBBBBBD.
...DDDDD...
"""
BALL_LEG = {"D": "#5A2E0E", "B": "#A0522D", "W": "#FFFFFF"}

# Tier glyphs, 5 x 5, drawn in the tier colour beside the word.
STAR = """
..X..
.XXX.
XXXXX
.XXX.
.X.X.
"""
TICK = """
....X
...XX
X.XX.
XXX..
.X...
"""
DIAMOND = """
..X..
.XXX.
XXXXX
.XXX.
..X..
"""

# The verdict arrows, 5 x 3.
ARROW_UP = """
..X..
.XXX.
XXXXX
"""
ARROW_DOWN = """
XXXXX
.XXX.
..X..
"""
ARROW_W = 5

# ------------------------------------------------------------- text tools
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/&"

def clean(s):
    """Panel-safe uppercase: the fonts lack ' and accented letters, and a
    missing glyph is dropped silently, so JA'MARR is drawn JAMARR on purpose."""
    out = ""
    last_space = True
    for ch in str(s).upper().elems():
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

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    """Largest font in the ladder that fits, then hard-clip in the last."""
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    f = fonts[len(fonts) - 1]
    return [f, clip(c, text, f, maxw)]

FONTH = {"10x16": 16, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}

HEXD = "0123456789abcdef"

def ink_for(fill):
    """Black type on a bright pill, white on a dark one."""
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def pill(c, word, fill, x, y):
    c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")

def pill_w(c, word):
    return c.text_width(word, "4x5") + 4

# ---------------------------------------------------------------- numbers
def fnum(v):
    if type(v) == "float" or type(v) == "int":
        return float(v)
    return 0.0

def one_dp(v):
    """24.38 -> '24.4'; negatives are clamped to 0.0 (a projection below zero
    reads as a bug on a wall)."""
    t = int(v * 10 + 0.5) if v > 0 else 0
    return str(t // 10) + "." + str(t % 10)

def tenths(v):
    return int(v * 10 + 0.5) if v > 0 else 0

def whole(v):
    return str(int(v + 0.5)) if v > 0 else "0"

def stat_forms(pos, s):
    """The projected line behind the number, longest wording first; the
    caller keeps the first that fits."""
    g = lambda k: fnum(s.get(k, 0))
    if pos == "QB":
        tds = one_dp(g("pass_td"))
        return [whole(g("pass_yd")) + " PASS YD " + tds + " TD",
                whole(g("pass_yd")) + " PASS " + tds + " TD",
                whole(g("pass_yd")) + " YD " + tds + " TD"]
    if pos == "RB":
        tds = one_dp(g("rush_td") + g("rec_td"))
        return [whole(g("rush_yd")) + " YD " + one_dp(g("rec")) + " REC " + tds + " TD",
                whole(g("rush_yd")) + " RUSH " + one_dp(g("rec")) + " REC",
                whole(g("rush_yd")) + " YD " + one_dp(g("rec")) + " REC"]
    if pos == "WR" or pos == "TE":
        return [one_dp(g("rec")) + " REC " + whole(g("rec_yd")) + " YD " + one_dp(g("rec_td")) + " TD",
                one_dp(g("rec")) + " REC " + whole(g("rec_yd")) + " YD",
                whole(g("rec_yd")) + " REC YD"]
    if pos == "K":
        return [one_dp(g("fgm")) + " FG " + one_dp(g("xpm")) + " XP",
                one_dp(g("fgm")) + " FG"]
    if pos == "DEF":
        return [one_dp(g("sack")) + " SACK " + one_dp(g("int")) + " INT " + whole(g("pts_allow")) + " PA",
                one_dp(g("sack")) + " SACK " + whole(g("pts_allow")) + " PA",
                one_dp(g("sack")) + " SACKS"]
    return [""]

def weekday(date):
    """'2026-09-27' -> 'SUN' (Sakamoto), '' when the date is missing."""
    parts = str(date).split("-")
    if len(parts) != 3 or not parts[0].isdigit() or not parts[1].isdigit() or not parts[2].isdigit():
        return ""
    y = int(parts[0])
    m = int(parts[1])
    d = int(parts[2])
    if m < 1 or m > 12:
        return ""
    t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
    if m < 3:
        y -= 1
    return DAYS[(y + y // 4 - y // 100 + y // 400 + t[m - 1] + d) % 7]

# ------------------------------------------------------------------- feeds
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def pull(url, params, ttl, want):
    """[verdict, json]: verdict is ok / offline / big / bad. A body over the
    published 1 MB cap counts as too large even where the local SDK lets it
    through, so the panel behaves the same here and on Glance's servers."""
    r = http.get(url, params = params, headers = HEADERS, ttl_seconds = ttl)
    code = r["status_code"]
    if code == 0:
        return ["offline", None]
    if code != 200:
        return ["bad", code]
    body = r.get("body", "")
    if len(body) > MAX_BODY:
        return ["big", None]
    if type(r["json"]) != want:
        return ["big" if len(body) >= MAX_BODY - 1000 else "bad", 200]
    return ["ok", r["json"]]

def fetch_state():
    v = pull(SLEEPER_STATE, {}, STATE_TTL, "dict")
    if v[0] == "offline":
        return {"ok": False, "head": "SLEEPER OFFLINE", "sub": "RETRY IN A FEW MIN"}
    if v[0] != "ok":
        return {"ok": False, "head": "SLEEPER ERROR", "sub": "HTTP " + str(v[1]) + " - RETRY SOON"}
    j = v[1]
    week = int(fnum(get(j, "week", 0)))
    return {"ok": True, "season": str(get(j, "season", "")), "stype": str(get(j, "season_type", "")),
            "week": week}

def fetch_games(st):
    """game_id -> {home, day, done}; empty when the schedule is unavailable
    (the card then falls back to a plain VS with no day)."""
    v = pull(SLEEPER_SCHED + st["stype"] + "/" + st["season"], {}, SCHED_TTL, "list")
    out = {}
    if v[0] != "ok":
        return out
    for g in v[1]:
        if type(g) != "dict" or int(fnum(get(g, "week", 0))) != st["week"]:
            continue
        gid = str(get(g, "game_id", ""))
        if gid == "":
            continue
        out[gid] = {"home": club(get(g, "home", "")), "day": weekday(get(g, "date", "")),
                    "done": str(get(g, "status", "")) == "complete"}
    return out

def fetch_board(st, pos, key):
    """The position's projections, re-ranked by the chosen scoring. Rows with
    no club or no opponent (free agents, byes) are dropped."""
    v = pull(SLEEPER_PROJ + st["season"] + "/" + str(st["week"]),
             {"season_type": st["stype"], "position[]": pos, "order_by": key}, PROJ_TTL, "list")
    if v[0] == "offline":
        return {"ok": False, "big": False, "head": "SLEEPER OFFLINE", "sub": "RETRY IN A FEW MIN"}
    if v[0] == "big":
        return {"ok": False, "big": True, "head": pos + " FEED TOO LARGE", "sub": "TRY ANOTHER POSITION"}
    if v[0] != "ok":
        return {"ok": False, "big": False, "head": "PROJECTIONS ERROR", "sub": "HTTP " + str(v[1]) + " - RETRY SOON"}
    rows = []
    for x in v[1]:
        if type(x) != "dict":
            continue
        p = get(x, "player", {})
        s = get(x, "stats", {})
        if type(s) != "dict":
            s = {}
        team = club(get(x, "team", ""))
        opp = club(get(x, "opponent", ""))
        pts = fnum(s.get(key, 0))
        if team not in LOGO or team == "NFL" or opp not in SMALL or pts <= 0:
            continue
        if str(get(p, "position", pos)) != pos:
            continue
        first = clean(get(p, "first_name", ""))
        if pos == "DEF":
            first = SHORT_CITY.get(first, first)
        rows.append({"id": str(get(x, "player_id", "")), "first": first,
                     "last": clean(get(p, "last_name", "")),
                     "team": team, "opp": opp, "pts": pts, "stats": s,
                     "game": str(get(x, "game_id", "")), "date": str(get(x, "date", "")),
                     "inj": str(get(p, "injury_status", ""))})
    rows = sorted(rows, key = lambda row: -row["pts"])
    return {"ok": True, "rows": rows}

def season_avg(st, pos, key, pid):
    """The player's points per game played so far this regular season, or
    -1 when there is no history yet or the feed is unavailable / too large."""
    v = pull(SLEEPER_STATS + st["season"], {"season_type": "regular", "position[]": pos}, SEASON_TTL, "list")
    if v[0] != "ok":
        return -1.0
    for x in v[1]:
        if type(x) == "dict" and str(get(x, "player_id", "")) == pid:
            s = get(x, "stats", {})
            gp = fnum(get(s, "gp", 0))
            if gp <= 0:
                return -1.0
            return fnum(get(s, key, 0)) / gp
    return -1.0

def week_actual(st, pos, key, pid):
    """[actual points, actual stat dict] for this week, or [-1, None] when
    the player is not in the feed."""
    v = pull(SLEEPER_STATS + st["season"] + "/" + str(st["week"]),
             {"season_type": st["stype"], "position[]": pos}, WEEK_TTL, "list")
    if v[0] != "ok":
        return [-1.0, None]
    for x in v[1]:
        if type(x) == "dict" and str(get(x, "player_id", "")) == pid:
            s = get(x, "stats", {})
            if type(s) != "dict":
                return [0.0, {}]
            return [fnum(s.get(key, 0)), s]
    return [-1.0, None]

def week_label(st):
    if st["stype"] == "post":
        return POST_WEEK.get(st["week"], "PLAYOFFS")
    return "WEEK " + str(st["week"])

# -------------------------------------------------------------- screens
def message(c, head, sub, color, rail_color):
    """The shared status card: the football resting on the same patch of
    turf the card's number stands on, edged in the state colour, then a
    head and a what-to-do line centred in the safe zone."""
    c.fill("black")
    c.rect(8, TURF_T, 45, TURF_B, fill = TURF)
    c.rect(8, TURF_T, 45, TURF_T, fill = rail_color)
    c.rect(8, TURF_B, 45, TURF_B, fill = rail_color)
    for x in range(10, 45, 5):
        c.rect(x, TURF_T + 1, x, TURF_T + 1, fill = TURF_LINE)
        c.rect(x, TURF_B - 1, x, TURF_B - 1, fill = TURF_LINE)
    c.sprite(BALL, 16, 9, legend = BALL_LEG, scale = 2)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 128)
    c.text(hf[1], 117, 8, font = hf[0], color = color, align = "center")
    sf = fit(c, sub, ["4x5"], 128)
    c.text(sf[1], 117, 21, font = sf[0], color = DIM, align = "center")

def frame_pick(ctx, want, perpos_all, perpos_one):
    """[position, rank index] for this frame."""
    f = ctx.now.unix // FRAME_SECONDS
    if want in POSITIONS:
        return [want, f % perpos_one]
    return [POSITIONS[f % len(POSITIONS)], (f // len(POSITIONS)) % perpos_all]

# ---------------------------------------------------------------- page
def board(c, ctx):
    want = str(ctx.inputs.get("position", "ALL")).strip().upper()
    sc = SCORING.get(str(ctx.inputs.get("scoring", "PPR")).strip().upper(), SCORING["PPR"])

    st = fetch_state()
    if not st["ok"]:
        message(c, st["head"], st["sub"], "amber", OFFLINE)
        return
    if st["stype"] not in ["regular", "post"] or st["week"] < 1 or st["season"] == "":
        message(c, "PRESEASON" if st["stype"] == "pre" else "OFFSEASON", "PROJECTIONS START WEEK 1", GOOD, GOOD)
        return

    per_all = 3
    per_one = 10
    pick = frame_pick(ctx, want, per_all, per_one)
    pos = pick[0]
    d = fetch_board(st, pos, sc[0])
    if not d["ok"] and d["big"] and want not in POSITIONS:
        # ALL: a feed over the cap costs one slot, not a screen - show the
        # next position instead.
        pos = POSITIONS[(POSITIONS.index(pos) + 1) % len(POSITIONS)]
        d = fetch_board(st, pos, sc[0])
    if not d["ok"]:
        message(c, d["head"], d["sub"], "amber", OFFLINE)
        return
    rows = d["rows"]
    if len(rows) == 0:
        message(c, "NO " + pos + " PROJECTIONS YET", week_label(st) + " - CHECK LATER", GOOD, GOOD)
        return
    n = min(len(rows), per_all if want not in POSITIONS else per_one)
    idx = pick[1] % n
    row = rows[idx]

    # Rank by the rounded number on screen, so two 9.3s are both T1.
    mine = tenths(row["pts"])
    above = 0
    tied = False
    for i in range(len(rows)):
        t = tenths(rows[i]["pts"])
        if t > mine:
            above += 1
        elif t == mine and i != idx:
            tied = True
    rank = above + 1

    games = fetch_games(st)
    g = games.get(row["game"], None)
    day = g["day"] if g != None else weekday(row["date"])
    home = (g["home"] == row["team"]) if g != None else True
    done = g["done"] if g != None else False

    wa = week_actual(st, pos, sc[0], row["id"]) if done else [-1.0, None]
    actual = wa[0]
    avg = season_avg(st, pos, sc[0], row["id"]) if actual < 0 else -1.0

    card(c, row, pos, rank, tied, sc[1], st, day, home, actual, wa[1], avg)

def verdict(c, word, value, beat, y):
    """Arrow + word + number, centred in the points column; the arrow and the
    colour both say up or down, so it never rests on colour alone."""
    text = word + " " + one_dp(value)
    tw = c.text_width(text, "4x5")
    col = UP if beat else DOWN
    w = ARROW_W + 2 + tw
    x = P_CX - w // 2
    if x < P_L:
        x = P_L
    c.sprite(ARROW_UP if beat else ARROW_DOWN, x, y + 1, legend = {"X": col})
    c.text(text, x + ARROW_W + 2, y, font = "4x5", color = col)

def turf(c):
    """The field band: grass, chalk sidelines, a yard-line stub every 5 px
    along both edges (longer every 10), and the number stands mid-field."""
    c.rect(P_L, TURF_T, P_R, TURF_B, fill = TURF)
    c.rect(P_L, TURF_T, P_R, TURF_T, fill = TURF_LINE)
    c.rect(P_L, TURF_B, P_R, TURF_B, fill = TURF_LINE)
    for x in range(P_L + 2, P_R - 1, 5):
        h = 2 if (x - P_L - 2) % 10 == 0 else 1
        c.rect(x, TURF_T + 1, x, TURF_T + h, fill = TURF_LINE)
        c.rect(x, TURF_B - h, x, TURF_B - 1, fill = TURF_LINE)

def card(c, row, pos, rank, tied, scoring_word, st, day, home, actual, played, avg):
    c.fill("black")
    pcol = POS_COLOR[pos]
    final = actual >= 0

    # Own club, closed off by the position stripe.
    c.image(LOGO.get(row["team"], "NFL.png"), LOGO_X, LOGO_Y)
    c.rect(STRIPE_X, 0, STRIPE_X + 1, 31, fill = pcol)

    # Points column: what the number is, the number on the turf, the verdict.
    head = scoring_word + (" FINAL" if final else " PROJ")
    c.text(head, P_CX, 1, font = "4x5", color = INK if final else DIM, align = "center")
    turf(c)
    shown = actual if final else row["pts"]
    num = one_dp(shown)
    if c.text_width(num, "9x12") > P_R - P_L - 1:
        num = whole(shown)   # 100+ loses its tenth before it loses its size
    nf = fit(c, num, ["10x16", "9x12", "8x10"], P_R - P_L - 1)
    c.text_stroke(nf[1], P_CX, TURF_T + 1 + (16 - FONTH[nf[0]]) // 2, font = nf[0], color = INK,
                  stroke = "black", align = "center")
    if final:
        verdict(c, "PROJ", row["pts"], tenths(actual) >= tenths(row["pts"]), 27)
    elif avg >= 0:
        verdict(c, "AVG", avg, tenths(row["pts"]) >= tenths(avg), 27)
    else:
        wk = "WK " + str(st["week"]) if st["stype"] != "post" else week_label(st)
        if c.text_width(wk, "4x5") > P_R - P_L + 1:
            wk = "PLAYOFFS"
        c.text(wk, P_CX, 27, font = "4x5", color = DIM, align = "center")

    # Chip row: rank pill, injury pill (filled - it is the alarm), then the
    # tier as glyph + coloured word. When it gets tight the rank pill drops
    # the position word, then the injury shortens to its letter; the tier is
    # the last thing to go.
    cut = TIER_CUT[pos]
    tier = ["STUD", C_STUD, STAR] if rank <= cut[0] else (["START", C_START, TICK] if rank <= cut[1] else ["FLEX", C_FLEX, DIAMOND])
    tier_w = ARROW_W + 2 + c.text_width(tier[0], "4x5")
    rk_num = ("T" if tied else "#") + str(rank)
    inj = INJ.get(row["inj"], None)
    word_w = c.text_width(tier[0], "4x5")
    plans = []   # [rank pill, injury pill or None, draw the tier glyph]
    if inj != None:
        plans = [[rk_num + " " + pos, inj[0], True], [rk_num, inj[0], True], [rk_num, inj[1], True],
                 [rk_num, inj[1], False]]
    else:
        plans = [[rk_num + " " + pos, None, True], [rk_num, None, True]]
    choice = plans[len(plans) - 1]
    for p in plans:
        w = pill_w(c, p[0]) + 3 + (pill_w(c, p[1]) + 3 if p[1] != None else 0) + (tier_w if p[2] else word_w)
        if N_X + w - 1 <= CHIP_R:
            choice = p
            break
    pill(c, choice[0], pcol, N_X, 0)
    x = N_X + pill_w(c, choice[0]) + 3
    if choice[1] != None:
        pill(c, choice[1], inj[2], x, 0)
        x += pill_w(c, choice[1]) + 3
    if choice[2] and x + tier_w - 1 <= CHIP_R:
        c.sprite(tier[2], x, 1, legend = {"X": tier[1]})
        c.text(tier[0], x + ARROW_W + 2, 1, font = "4x5", color = tier[1])
    elif x + word_w - 1 <= CHIP_R:
        c.text(tier[0], x, 1, font = "4x5", color = tier[1])

    # First name over surname. A defense is city over nickname
    # ("KANSAS CITY" / "CHIEFS").
    first = row["first"]
    last = row["last"]
    if first == "" and last == "":
        last = row["team"]
    ff = fit(c, first, ["5x7", "4x5"], N_W)
    c.text(ff[1], N_X, 8 + (7 - FONTH[ff[0]]) // 2, font = ff[0], color = FIRST if pos != "DEF" else INK, align = "left")
    lf = fit(c, last, ["8x10", "6x8", "5x7", "4x5"], N_W)
    if lf[1] != last:
        # Too long even in 4x5: shed a suffix (JR., III) before hard-clipping.
        words = last.split(" ")
        if len(words) > 1 and words[len(words) - 1] in SUFFIX:
            last = " ".join(words[:len(words) - 1])
            lf = fit(c, last, ["8x10", "6x8", "5x7", "4x5"], N_W)
    if lf[1] != last and "-" in last:
        # Still too long: keep the second half of a double-barrelled name.
        lf = fit(c, last.split("-")[-1], ["8x10", "6x8", "5x7", "4x5"], N_W)
    c.text(lf[1], N_X, 16 + (10 - FONTH[lf[0]]) // 2, font = lf[0], color = INK)

    # The line that makes the number: projected, or the real one once the
    # game is over. It may run under the opponent's crest (which ends at
    # y 26) to x 185.
    lw = EDGE_R - N_X + 1
    forms = stat_forms(pos, played if final and played != None else row["stats"])
    line = ""
    for form in forms:
        if c.text_width(form, "4x5") <= lw:
            line = form
            break
    if line == "":
        line = clip(c, forms[0], "4x5", lw)
    c.text(line, N_X, 27, font = "4x5", color = pcol)

    # The opponent: VS (home) or AT (away; the 4x5 "@" reads as a Q) and the game day, over their crest.
    at = "VS" if home else "AT"
    aw = c.text_width(at, "4x5")
    dw = c.text_width(day, "4x5") if day != "" else 0
    total = aw + (4 + dw if dw > 0 else 0)
    ox = O_CX - total // 2
    if ox + total - 1 > EDGE_R:
        ox = EDGE_R - total + 1
    c.rect(O_DIV, 0, O_DIV, 25, fill = DIV)
    c.text(at, ox, 1, font = "4x5", color = DIM)
    if dw > 0:
        c.text(day, ox + aw + 4, 1, font = "4x5", color = pcol)
    c.image(SMALL.get(row["opp"], "KC_S.png"), O_X, O_Y)
