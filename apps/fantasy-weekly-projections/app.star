# Fantasy Weekly Projections
#
# This week's start-'em board: Sleeper's projected fantasy points for the
# top players at each position, one player per frame, ranked in the
# league's own scoring (PPR, half PPR or standard).
#
# DESIGN. A projection ladder. Page 1 is a staircase that falls from left
# to right across the whole panel: the top four at the position, one step
# each, the #1 step the tallest and gold, the rest in the position's colour
# (the one colour that tells QB from WR at a glance). Each step reads the way
# a stair does - the club crest (the 24 x 18 set, at its authored size)
# stands on the tread with the projected points beside it, the surname is
# printed along the tread's lit edge, and the riser below carries the rank
# numeral where the step is tall enough to hold one. Over each number a
# small marker: a green up-arrow when this week projects above the player's
# season average, an amber down-arrow when below, a chequered flag once his
# game is over, and the injury tag (Q, D, OUT, IR, PUP, SUS) in its alarm
# colour. Step widths follow the names, so a MCCAFFREY gets the room a LAMB
# does not need. The air over the low end of the stairs holds the header:
# the position in its colour, and the scoring and week.
# Page 2 is the spotlight, one step of the same staircase zoomed in: the
# player's crest stands centred on a single pedestal with the points cut
# into it (gold for #1). Left of it the player - rank pill, injury pill and
# tier (a gold star STUD, a green tick START, a sky diamond FLEX, sized to a
# 12-team league), first name over surname and the projected stat line;
# right of it the matchup - VS (home) or AT (away) and the game day beside
# the opponent's crest - and the verdict against the season average. Once
# the game is over the pedestal turns white and holds the actual points,
# with the real stat line and PROJ arrowed up or down underneath.
#
# Frames: refresh is 120 and each frame is one ladder. ALL steps QB, RB, WR,
# TE, K, DEF (the top four each, a 12-minute lap) and the spotlight walks the
# top 3 one lap at a time. A single position spotlights ranks 1 to 10 in turn
# (20 minutes), and the ladder shows whichever four - 1-4, 5-8 or 9-10 -
# hold the player in the spotlight.
#
# Requests per render: the Sleeper week, the schedule (27 KB), the position's
# projections, its season stats (the averages for all four steps come from
# the one feed) and, only when the spotlit player's game is over, its week
# stats: five at most, and the two pages share them through the cache.
# The WR feeds run 850-920 KB against a 1 MB cap, so
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
# Page 1, the ladder: four steps with a 1 px gap across x 6..185, each as
# wide as its logo + points or its surname needs, the spare shared out.
# Four, not five: a step is a 24 x 18 crest with the points beside it
# (24 + 1 + 18 = 43 px), and a fifth would not fit the width; stacking the
# points under the crest instead would leave no height for the stairs to fall.
STEPS = 4
LADDER_L = 6
LADDER_R = 185
NAME_CAP = 44                 # a longer surname sheds its suffix / first half
PTS_MAX = 18                  # "24.5" in 4x7; 100+ drops the tenth
TREAD = [18, 20, 23, 25]      # the top of each step; it runs to the floor
BAND_H = 7                    # the lit tread edge the surname is printed on
SM_W = 24                     # the crests stand at their authored 24 x 18
SM_H = 18
HEAD_R = 185

# Page 2, the spotlight: player | pedestal | matchup.
L_X = 6             # player block x 6..72
L_R = 72
PED_L = 76          # the pedestal x 76..115, y 19..31
PED_R = 115
PED_T = 19
PED_CX = 96
R_X = 120           # matchup block x 120..185
O_X = 161           # opponent crest x 161..184 (24 x 18), y 8..25
O_Y = 8
EDGE_R = 185

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FIRST = "#9AA3B2"     # the first name: quieter than the surname, brighter than a label
OFFLINE = "#3C4043"
GOLD = "#FFC62F"      # the #1 step
GOOD = "#2FE06F"
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

# Game over, 5 x 3: a strip of chequered flag.
FLAG = """
X.X.X
.X.X.
X.X.X
"""

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

FONTH = {"10x16": 16, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x7": 7, "4x5": 5, "3x4": 4}

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

def shade(fill, num, den):
    """The colour darkened to num/den - a step's riser under its lit tread."""
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return fill
    out = "#"
    for i in [1, 3, 5]:
        v = (HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1])) * num // den
        out += HEXD[v // 16] + HEXD[v % 16]
    return out

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
        if team not in SMALL or opp not in SMALL or pts <= 0:
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

def season_avgs(st, pos, key, pids):
    """player_id -> points per game played so far this regular season, for
    the ids asked for; a player with no games yet, or every player when the
    feed is unavailable / too large, is simply missing."""
    out = {}
    v = pull(SLEEPER_STATS + st["season"], {"season_type": "regular", "position[]": pos}, SEASON_TTL, "list")
    if v[0] != "ok":
        return out
    for x in v[1]:
        if type(x) != "dict":
            continue
        pid = str(get(x, "player_id", ""))
        if pid not in pids:
            continue
        s = get(x, "stats", {})
        gp = fnum(get(s, "gp", 0))
        if gp > 0:
            out[pid] = fnum(get(s, key, 0)) / gp
    return out

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
def message(c, head, sub, color, step_color):
    """The shared status card: an empty four-step staircase in the state
    colour with the football resting on the top step, then a head and a
    what-to-do line centred in the rest of the safe zone."""
    c.fill("black")
    for k in range(4):
        x = 8 + 11 * k
        t = 14 + 3 * k
        c.rect(x, t, x + 9, 25, fill = shade(step_color, 1, 2))
        c.rect(x, t, x + 9, t + 1, fill = step_color)
    c.sprite(BALL, 8, 6, legend = BALL_LEG)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 124)
    c.text(hf[1], 119, 8, font = hf[0], color = color, align = "center")
    sf = fit(c, sub, ["4x5"], 124)
    c.text(sf[1], 119, 21, font = sf[0], color = DIM, align = "center")

def frame_pick(ctx, want):
    """[position, spotlight rank index] for this frame. ALL: one position per
    frame, the spotlight one rank deeper each lap (top 3). One position: the
    spotlight walks its top 10."""
    f = ctx.now.unix // FRAME_SECONDS
    if want in POSITIONS:
        return [want, f % 10]
    return [POSITIONS[f % len(POSITIONS)], (f // len(POSITIONS)) % 3]

def board_data(ctx):
    """Everything both pages draw from: {msg: [head, sub, colour, step colour]}
    for a status screen, or the board for this frame."""
    want = str(ctx.inputs.get("position", "ALL")).strip().upper()
    sc = SCORING.get(str(ctx.inputs.get("scoring", "PPR")).strip().upper(), SCORING["PPR"])

    st = fetch_state()
    if not st["ok"]:
        return {"msg": [st["head"], st["sub"], "amber", OFFLINE]}
    if st["stype"] not in ["regular", "post"] or st["week"] < 1 or st["season"] == "":
        return {"msg": ["PRESEASON" if st["stype"] == "pre" else "OFFSEASON", "PROJECTIONS START WEEK 1", GOOD, GOOD]}

    pick = frame_pick(ctx, want)
    pos = pick[0]
    d = fetch_board(st, pos, sc[0])
    if not d["ok"] and d["big"] and want not in POSITIONS:
        # ALL: a feed over the cap costs one slot, not a screen - show the
        # next position instead.
        pos = POSITIONS[(POSITIONS.index(pos) + 1) % len(POSITIONS)]
        d = fetch_board(st, pos, sc[0])
    if not d["ok"]:
        return {"msg": [d["head"], d["sub"], "amber", OFFLINE]}
    rows = d["rows"]
    if len(rows) == 0:
        return {"msg": ["NO " + pos + " PROJECTIONS YET", week_label(st) + " - CHECK LATER", GOOD, GOOD]}
    n = min(len(rows), 3 if want not in POSITIONS else 10)
    spot = pick[1] % n
    # The ladder that holds the spotlit player: 1-4, 5-8 or 9-10 when one
    # position walks its top 10; ALL spotlights the top 3 on the top 4.
    first = (spot // STEPS) * STEPS
    return {"msg": None, "st": st, "sc": sc, "pos": pos, "rows": rows, "spot": spot,
            "first": first, "ladder": rows[first:min(first + STEPS, max(n, STEPS))],
            "games": fetch_games(st)}

def game_of(b, row):
    """[day, home, done] for a player's game, from the schedule; a bare VS
    with the projection's own date when the schedule is missing."""
    g = b["games"].get(row["game"], None)
    if g == None:
        return [weekday(row["date"]), True, False]
    return [g["day"], g["home"] == row["team"], g["done"]]

def rank_of(rows, idx):
    """[rank, tied] by the rounded number on screen, so two 9.3s are both T1."""
    mine = tenths(rows[idx]["pts"])
    above = 0
    tied = False
    for i in range(len(rows)):
        t = tenths(rows[i]["pts"])
        if t > mine:
            above += 1
        elif t == mine and i != idx:
            tied = True
    return [above + 1, tied]

def surname(c, last, fonts, maxw):
    """[font, text] for a surname in maxw: the largest font that fits, then
    shed a suffix (JR., III), then keep the second half of a double-barrelled
    name, then hard-clip."""
    lf = fit(c, last, fonts, maxw)
    if lf[1] != last:
        words = last.split(" ")
        if len(words) > 1 and words[len(words) - 1] in SUFFIX:
            last = " ".join(words[:len(words) - 1])
            lf = fit(c, last, fonts, maxw)
    if lf[1] != last and "-" in last:
        lf = fit(c, last.split("-")[-1], fonts, maxw)
    return lf

def step_color(b, i):
    """The true #1 is gold; every other step wears the position colour."""
    return GOLD if b["first"] + i == 0 else POS_COLOR[b["pos"]]

# ---------------------------------------------------------------- page 1
def board(c, ctx):
    b = board_data(ctx)
    if b["msg"] != None:
        message(c, b["msg"][0], b["msg"][1], b["msg"][2], b["msg"][3])
        return
    c.fill("black")
    pos = b["pos"]
    st = b["st"]
    rows = b["ladder"]
    avgs = season_avgs(st, pos, b["sc"][0], [r["id"] for r in rows])

    geo = steps_geo(c, rows)

    # The header, in the air over the low end of the stairs (from step 3
    # on, whose crest starts at y 5): the position in its colour at the
    # right edge, and the scoring, span and week in the 3x4 beside it.
    n = len(geo)
    head_x = geo[2][0] if n > 2 else geo[n - 1][0] + geo[n - 1][1] + 2
    pw = c.text_width(pos, "4x5")
    c.text(pos, HEAD_R - pw + 1, 0, font = "4x5", color = POS_COLOR[pos])
    wk = "WK " + str(st["week"]) if st["stype"] != "post" else week_label(st)
    span = ("#" + str(b["first"] + 1) + "-" + str(b["first"] + len(rows)) + " ") if b["first"] > 0 else ""
    room = HEAD_R - pw - 3 - head_x + 1
    head = ""
    for h in [span + b["sc"][1] + " PROJ " + wk, span + b["sc"][1] + " " + wk, span + b["sc"][1],
              b["sc"][1] + " " + wk, b["sc"][1]]:
        if c.text_width(h, "3x4") <= room:
            head = h
            break
    c.text(head, head_x, 0, font = "3x4", color = FIRST)

    for i in range(len(rows)):
        g = geo[i]
        step(c, b, i, rows[i], avgs, g[0], g[1], g[2])

def tread_name(c, row):
    """The surname for a tread, shortened the way the spotlight does it: a
    suffix (JR., III) goes first, then the first half of a double-barrelled
    name, but only when it would not fit a widened step anyway."""
    last = row["last"] if row["last"] != "" else (row["first"] if row["first"] != "" else row["team"])
    if c.text_width(last, "3x4") <= NAME_CAP:
        return last
    words = last.split(" ")
    if len(words) > 1 and words[len(words) - 1] in SUFFIX:
        last = " ".join(words[:len(words) - 1])
    if c.text_width(last, "3x4") > NAME_CAP and "-" in last:
        last = last.split("-")[-1]
    return last

def tread_points(c, row):
    num = one_dp(row["pts"])
    if c.text_width(num, "4x7") > PTS_MAX:
        num = whole(row["pts"])   # 100+ loses its tenth
    return num

def total(xs):
    t = 0
    for v in xs:
        t += v
    return t

def steps_geo(c, rows):
    """[x0, width, name] per step. Every step needs room for its logo and
    points (and the marker row over them), and for its surname in 3x4 at
    least; the panel's spare width is then shared out evenly (as if all four
    steps were there, so a short board leaves open air), and a surname
    gets the 4x5 font wherever its step is wide enough. Four very long names
    could overfill the panel: the longest is then shortened."""
    n = len(rows)
    names = []
    need = []
    base = []
    for r in rows:
        nm = tread_name(c, r)
        inj = INJ.get(r["inj"], None)
        bw = max(SM_W + 1 + c.text_width(tread_points(c, r), "4x7"),
                 SM_W + 1 + ARROW_W + 1 + (c.text_width(inj[1], "3x4") if inj != None else 0))
        names.append(nm)
        base.append(bw)
        need.append(max(bw, c.text_width(nm, "3x4")))
    room = LADDER_R - LADDER_L + 1 - (n - 1)
    for _ in range(40):
        if total(need) <= room:
            break
        k = 0
        for i in range(n):
            if need[i] - base[i] > need[k] - base[k]:
                k = i
        if need[k] <= base[k]:
            break
        need[k] = max(base[k], need[k] - 1)
    spare = room - total(need)
    out = []
    x = LADDER_L
    for i in range(n):
        w = need[i] + (spare // STEPS if spare > 0 else 0) + (1 if spare > 0 and i < spare % STEPS else 0)
        out.append([x, w, names[i]])
        x += w + 1
    return out

def step(c, b, i, row, avgs, x0, w, name):
    t = TREAD[i]
    col = step_color(b, i)
    x1 = x0 + w - 1

    # The step: lit tread edge, darker riser to the floor.
    c.rect(x0, t, x1, 31, fill = shade(col, 1, 3))
    c.rect(x0, t, x1, t + BAND_H - 1, fill = col)
    nf = fit(c, name, ["4x5", "3x4"], w)
    if nf[1] != name:
        # Only when four long names overfill the panel: an abbreviation
        # with a stop, never a bare cut.
        nf = ["3x4", clip(c, name, "3x4", w - 2) + "."]
    c.text(nf[1], x0 + w // 2, t + 1 + (5 - FONTH[nf[0]]) // 2, font = nf[0],
           color = ink_for(col), align = "center")

    # The rank on the riser, where the riser is tall enough to hold it.
    riser = 31 - (t + BAND_H) + 1
    rk = str(b["first"] + i + 1)
    for f in ["8x10", "6x8", "4x5"]:
        if FONTH[f] + 2 <= riser and c.text_width(rk, f) <= w - 4:
            c.text(rk, x0 + w // 2, t + BAND_H + 1 + (riser - 2 - FONTH[f]) // 2, font = f,
                   color = shade(col, 3, 4), align = "center")
            break

    # On the tread: the club logo and the points beside it, right-aligned.
    c.image(SMALL.get(row["team"], "KC_S.png"), x0, t - SM_H)
    num = tread_points(c, row)
    c.text(num, x1 - c.text_width(num, "4x7") + 1, t - 7, font = "4x7", color = GOLD if col == GOLD else INK)

    # Over the number: game over, or up / down on the season average, at
    # the number's left edge; the injury tag in its alarm colour at the right.
    inj = INJ.get(row["inj"], None)
    tw = c.text_width(inj[1], "3x4") if inj != None else 0
    mx = x1 - max(c.text_width(num, "4x7"), ARROW_W + 1 + tw) + 1
    if game_of(b, row)[2]:
        c.sprite(FLAG, mx, t - 11, legend = {"X": INK})
    elif row["id"] in avgs:
        up = tenths(row["pts"]) >= tenths(avgs[row["id"]])
        c.sprite(ARROW_UP if up else ARROW_DOWN, mx, t - 11, legend = {"X": UP if up else DOWN})
    if inj != None:
        c.text(inj[1], x1 - c.text_width(inj[1], "3x4") + 1, t - 12, font = "3x4", color = inj[2])

# ---------------------------------------------------------------- page 2
def spotlight(c, ctx):
    b = board_data(ctx)
    if b["msg"] != None:
        message(c, b["msg"][0], b["msg"][1], b["msg"][2], b["msg"][3])
        return
    st = b["st"]
    pos = b["pos"]
    sc = b["sc"]
    rows = b["rows"]
    idx = b["spot"]
    row = rows[idx]
    rt = rank_of(rows, idx)
    gm = game_of(b, row)
    wa = week_actual(st, pos, sc[0], row["id"]) if gm[2] else [-1.0, None]
    actual = wa[0]
    avg = -1.0
    if actual < 0:
        avg = season_avgs(st, pos, sc[0], [row["id"]]).get(row["id"], -1.0)
    col = GOLD if idx == 0 else POS_COLOR[pos]
    pedestal(c, row, pos, col, rt[0], rt[1], sc[1], st, gm, actual, wa[1], avg)

def pedestal(c, row, pos, col, rank, tied, scoring_word, st, gm, actual, played, avg):
    c.fill("black")
    pcol = POS_COLOR[pos]
    final = actual >= 0

    # Centre: the club logo standing on its pedestal, the points cut in.
    c.image(SMALL.get(row["team"], "KC_S.png"), PED_CX - 12, 0)
    ped = INK if final else col
    c.rect(PED_L, PED_T, PED_R, 31, fill = shade(ped, 3, 5))
    c.rect(PED_L + 1, PED_T + 1, PED_R - 1, 31, fill = ped)
    shown = actual if final else row["pts"]
    num = one_dp(shown)
    if c.text_width(num, "8x10") > PED_R - PED_L - 3:
        num = whole(shown)
    nf = fit(c, num, ["8x10", "6x8", "5x7"], PED_R - PED_L - 3)
    c.text(nf[1], PED_CX, PED_T + 2 + (10 - FONTH[nf[0]]) // 2, font = nf[0], color = ink_for(ped), align = "center")

    # Left: the player. Chip row - rank pill, injury pill, tier; when it gets
    # tight the rank pill drops the position word, then the injury shortens
    # to its letter, then the tier glyph goes (never the tier word).
    cut = TIER_CUT[pos]
    tier = ["STUD", C_STUD, STAR] if rank <= cut[0] else (["START", C_START, TICK] if rank <= cut[1] else ["FLEX", C_FLEX, DIAMOND])
    tier_w = ARROW_W + 2 + c.text_width(tier[0], "4x5")
    word_w = c.text_width(tier[0], "4x5")
    rk_num = ("T" if tied else "#") + str(rank)
    inj = INJ.get(row["inj"], None)
    if inj != None:
        plans = [[rk_num + " " + pos, inj[0], True], [rk_num, inj[0], True], [rk_num, inj[1], True],
                 [rk_num, inj[1], False]]
    else:
        plans = [[rk_num + " " + pos, None, True], [rk_num, None, True], [rk_num, None, False]]
    choice = plans[len(plans) - 1]
    for p in plans:
        w = pill_w(c, p[0]) + 3 + (pill_w(c, p[1]) + 3 if p[1] != None else 0) + (tier_w if p[2] else word_w)
        if L_X + w - 1 <= L_R:
            choice = p
            break
    pill(c, choice[0], pcol, L_X, 0)
    x = L_X + pill_w(c, choice[0]) + 3
    if choice[1] != None:
        pill(c, choice[1], inj[2], x, 0)
        x += pill_w(c, choice[1]) + 3
    if choice[2] and x + tier_w - 1 <= L_R:
        c.sprite(tier[2], x, 1, legend = {"X": tier[1]})
        c.text(tier[0], x + ARROW_W + 2, 1, font = "4x5", color = tier[1])
    elif x + word_w - 1 <= L_R:
        c.text(tier[0], x, 1, font = "4x5", color = tier[1])

    # First name over surname (a defense is city over nickname).
    first = row["first"]
    last = row["last"]
    if first == "" and last == "":
        last = row["team"]
    lw = L_R - L_X + 1
    ff = fit(c, first, ["5x7", "4x5"], lw)
    c.text(ff[1], L_X, 8 + (7 - FONTH[ff[0]]) // 2, font = ff[0], color = FIRST if pos != "DEF" else INK)
    lf = surname(c, last, ["8x10", "6x8", "5x7", "4x5"], lw)
    c.text(lf[1], L_X, 16 + (10 - FONTH[lf[0]]) // 2, font = lf[0], color = INK)

    # The line that makes the number: projected, or the real one once over.
    forms = stat_forms(pos, played if final and played != None else row["stats"])
    line = ""
    for form in forms:
        if c.text_width(form, "4x5") <= lw:
            line = form
            break
    if line == "":
        line = clip(c, forms[0], "4x5", lw)
    c.text(line, L_X, 27, font = "4x5", color = pcol)

    # Right: what the number is, the matchup, the verdict.
    c.text(scoring_word + (" FINAL" if final else " PROJ"), R_X, 1, font = "4x5", color = INK if final else DIM)
    at = "VS" if gm[1] else "AT"
    c.text(at, R_X, 13, font = "4x5", color = DIM)
    if gm[0] != "":
        c.text(gm[0], R_X + c.text_width(at, "4x5") + 4, 13, font = "4x5", color = pcol)
    c.image(SMALL.get(row["opp"], "KC_S.png"), O_X, O_Y)
    if final:
        verdict(c, "PROJ", row["pts"], tenths(actual) >= tenths(row["pts"]), 27)
    elif avg >= 0:
        verdict(c, "AVG", avg, tenths(row["pts"]) >= tenths(avg), 27)
    else:
        wk = "WK " + str(st["week"]) if st["stype"] != "post" else week_label(st)
        c.text(clip(c, wk, "4x5", EDGE_R - R_X + 1), R_X, 27, font = "4x5", color = DIM)

def verdict(c, word, value, beat, y):
    """Arrow + word + number; the arrow and the colour both say up or down,
    so it never rests on colour alone."""
    col = UP if beat else DOWN
    c.sprite(ARROW_UP if beat else ARROW_DOWN, R_X, y + 1, legend = {"X": col})
    c.text(word + " " + one_dp(value), R_X + ARROW_W + 2, y, font = "4x5", color = col)
