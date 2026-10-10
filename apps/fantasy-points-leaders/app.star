# Fantasy Points Leaders
#
# Who put up the most fantasy points - in the last week played, or over the
# season so far - at QB, RB, WR, TE, K and DEF, from Sleeper's stat feed.
#
#   podium     The top three at one position standing on a podium: second
#              on the left, first in the middle, third on the right. Each
#              club's 24 x 18 logo stands on a medal-coloured step (6, 4
#              and 2 rows tall), the points in the medal's colour beside
#              it and the surname above. The position, the week and the
#              scoring system sit to the left.
#   spotlight  One leader at a time: the club logo, then a pixel-art medal
#              with the rank on it, hung on a ribbon in the club's two
#              colours; the fantasy rank (WR1, T-K1 on a tie) with the week
#              and opponent (or points per game for a season), the player's
#              name as the hero, the points in the medal's colour on the
#              right, and the stat line that produced them underneath.
#
# DESIGN. A leaderboard should feel like a medal ceremony, so the colour
# carries the rank everywhere it appears: gold, silver and bronze for the
# podium places, slate for fourth and fifth. Ties share a rank and its
# medal (competition ranking), and two scores that would both round to 29.8
# are shown to two decimals so the medals never contradict the numbers. The
# podium reads as a picture before it reads as text - three steps of three
# heights, each with its club's logo standing on it. The spotlight's one
# memorable thing is the medal: a disc with the rank on it, hung on a
# club-coloured ribbon beside the 40 x 24 logo (shared with Fantasy Football
# News, never scaled).
# Everything stays inside x 8..184 so the app reads as its own unit between
# its neighbours on a scroll panel.
#
# Timing. refresh is 180 s: each refresh the spotlight moves to the next
# player (1-5 of one position, or with ALL the top three of each position in
# turn - a 54-minute lap) and the podium shows the same position the
# spotlight is on. Stat feeds are cached 30 minutes; the season state for
# an hour.
#
# Which week is "last week". Sleeper's state/nfl week is the week being
# played, and it rolls forward some time after Monday night. So the app asks
# for week - 1, except on Tuesday and Wednesday (US Eastern), when the state
# week may be the one that just finished: then it tries that week first and
# keeps it only if at least 16 teams have stats in it (a full week has 24+;
# a week that has not started has none), else it falls back to week - 1.

SLEEPER_STATE = "https://api.sleeper.app/v1/state/nfl"
SLEEPER_STATS = "https://api.sleeper.com/stats/nfl/"
HEADERS = {"User-Agent": "glance-fantasy-points-leaders (glance-led.dev)"}

STATE_TTL = 3600
STATS_TTL = 1800
REFRESH = 180

POSITIONS = ["QB", "RB", "WR", "TE", "K", "DEF"]
SCORING = {"PPR": ["pts_ppr", "PPR"], "HALF PPR": ["pts_half_ppr", "HALF"],
           "STANDARD": ["pts_std", "STD"]}

# ------------------------------------------------------------------ palette
INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
AMBER = "#FFBF00"

# rank -> [medal, highlight, shade]
MEDAL = {
    1: ["#FFC83D", "#FFE9A0", "#B8860B"],
    2: ["#C9D2DC", "#F2F5F8", "#7E8894"],
    3: ["#E0894A", "#F5B98C", "#9A5626"],
}
SLATE = ["#7C8CA8", "#A9B6CC", "#4A566C"]

def medal(rank):
    return MEDAL.get(rank, SLATE)

# Logos ship in assets/ at 40 x 24, keyed by ESPN abbreviation. Literal
# paths, so the publish lint can see every file the app draws.
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png",
    "SEA": "SEA.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
    "NFL": "NFL.png",
}

# The 24 x 18 set for the podium steps, same clubs, same codes.
LOGO_S = {
    "ARI": "S/ARI.png", "ATL": "S/ATL.png", "BAL": "S/BAL.png", "BUF": "S/BUF.png",
    "CAR": "S/CAR.png", "CHI": "S/CHI.png", "CIN": "S/CIN.png", "CLE": "S/CLE.png",
    "DAL": "S/DAL.png", "DEN": "S/DEN.png", "DET": "S/DET.png", "GB": "S/GB.png",
    "HOU": "S/HOU.png", "IND": "S/IND.png", "JAX": "S/JAX.png", "KC": "S/KC.png",
    "LV": "S/LV.png", "LAC": "S/LAC.png", "LAR": "S/LAR.png", "MIA": "S/MIA.png",
    "MIN": "S/MIN.png", "NE": "S/NE.png", "NO": "S/NO.png", "NYG": "S/NYG.png",
    "NYJ": "S/NYJ.png", "PHI": "S/PHI.png", "PIT": "S/PIT.png", "SF": "S/SF.png",
    "SEA": "S/SEA.png", "TB": "S/TB.png", "TEN": "S/TEN.png", "WSH": "S/WSH.png",
}

# abbr -> [accent, jersey]: the club's two colours, lifted where navy, black
# or deep purple would vanish on an LED (same values as Fantasy Football News).
TEAM_COLORS = {
    "ARI": ["#E0304F", "#F0F2F5"], "ATL": ["#E8243C", "#A5ACAF"],
    "BAL": ["#D0A52E", "#7B5CE8"], "BUF": ["#E8203A", "#2A6BFF"],
    "CAR": ["#19A6F0", "#B8BEC4"], "CHI": ["#FF5A1F", "#3F63C0"],
    "CIN": ["#FF6A1F", "#F0F2F5"], "CLE": ["#FF4E10", "#9A6433"],
    "DAL": ["#B0B7BC", "#3D7BFF"], "DEN": ["#FF5A14", "#3A6AB0"],
    "DET": ["#1C9BE8", "#B0B7BC"], "GB": ["#FFB612", "#2E8B57"],
    "HOU": ["#E8233C", "#3A5A8C"], "IND": ["#3D86E8", "#F0F2F5"],
    "JAX": ["#D7A22A", "#00A5B8"], "KC": ["#FFB612", "#FF2447"],
    "LV": ["#C4CACD", "#8A9196"], "LAC": ["#FFC20E", "#2AA8F0"],
    "LAR": ["#FFD100", "#2F6BFF"], "MIA": ["#FC6A12", "#00C2CC"],
    "MIN": ["#FFC62F", "#8F5BE8"], "NE": ["#E8203F", "#3A5A9C"],
    "NO": ["#D3BC8D", "#F0F2F5"], "NYG": ["#E8203F", "#2A5FE0"],
    "NYJ": ["#F0F2F5", "#1FA36E"], "PHI": ["#B0B7BC", "#0FA0A8"],
    "PIT": ["#FFB612", "#F0F2F5"], "SF": ["#D4B46A", "#E8201F"],
    "SEA": ["#69BE28", "#3A5A9C"], "TB": ["#F0263A", "#8A8580"],
    "TEN": ["#4B92DB", "#F0F2F5"], "WSH": ["#FFB612", "#B8323A"],
}

# Sleeper's team codes that differ from the logo set's.
TEAM_FIX = {"WAS": "WSH", "JAC": "JAX", "OAK": "LV", "SD": "LAC", "STL": "LAR", "LA": "LAR"}

# --------------------------------------------------------------- pixel art
# 10 x 12, drawn at 2x on the quiet screen: a cup with handles on a
# two-step base. G gold, H highlight, S shade, B base.
TROPHY = """
GGGGGGGGGG
GHHGGGGGSG
GHGGGGGGSG
.GHGGGGSG.
..GGGGSG..
...GGGG...
....GS....
....GS....
...GGGS...
..BBBBBB..
..BBBBBB..
.BBBBBBBB.
"""
# 9 x 7 football for the fail and quiet screens.
BALL = """
..DDDDD..
.DBBBBBD.
DBBWBWBBD
DBWWWWWBD
DBBWBWBBD
.DBBBBBD.
..DDDDD..
"""
BALL_LEG = {"D": "#5A2E0E", "B": "#A0522D", "W": "#FFFFFF"}

# ------------------------------------------------------------- text tools
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-/"

def clean(s):
    """Panel-safe uppercase. The fonts have no apostrophe, and a missing
    glyph is dropped silently, so it goes on purpose (JA'MARR -> JAMARR)."""
    out = ""
    for ch in str(s).upper().elems():
        if KEEP.find(ch) >= 0:
            out += ch
    return " ".join([w for w in out.split(" ") if w != ""])

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    """The largest font in the ladder that fits, then a hard clip."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

# Lit rows per face, top-aligned.
INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}

SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]
PARTICLE = ["ST.", "ST", "DE", "DI", "DA", "DU", "LA", "LE", "VAN", "VON", "DEL", "DOS"]

def name_forms(full):
    """[full, initial + last, last]. The last name keeps a particle
    ('ST. BROWN'); a suffix stays only in the full name."""
    parts = [p for p in full.split(" ") if p != ""]
    if len(parts) < 2:
        return [full, full, full]
    end = len(parts)
    if end >= 3 and parts[end - 1] in SUFFIX:
        end -= 1
    start = end - 1
    if start >= 2 and parts[start - 1] in PARTICLE:
        start -= 1
    last = " ".join(parts[start:end])
    return [full, parts[0][:1] + ". " + last, last]

def fmt_pts(v):
    """40.82 -> '40.8'; one decimal, the way every fantasy app shows it."""
    t = int(v * 10 + (0.5 if v >= 0 else -0.5))
    sign = "-" if t < 0 else ""
    t = -t if t < 0 else t
    return sign + str(t // 10) + "." + str(t % 10)

def fmt_cents(t):
    """2978 -> '29.78'."""
    sign = "-" if t < 0 else ""
    t = -t if t < 0 else t
    return sign + str(t // 100) + "." + ("0" if t % 100 < 10 else "") + str(t % 100)

def n(s, key):
    v = s.get(key, 0)
    if type(v) not in ["int", "float"]:
        return 0
    return int(v + 0.5) if v >= 0 else int(v - 0.5)

# ------------------------------------------------------------------ stats
def stat_parts(pos, s, season):
    """[number, label] pairs, most telling first, zeros left out. The page
    sheds them from the end until the line fits."""
    p = []
    def add(v, label, always = False):
        if v != 0 or always:
            p.append([str(v), label])
    if pos == "QB":
        # every touchdown, thrown or run, in one count: it is what made the score
        add(n(s, "pass_yd"), "YD", True)
        add(n(s, "pass_td") + n(s, "rush_td"), "TD")
        add(n(s, "pass_int"), "INT")
        if n(s, "rush_yd") >= 15:
            add(n(s, "rush_yd"), "RUSH YD")
    elif pos == "RB":
        add(n(s, "rush_yd"), "RUSH YD", True)
        add(n(s, "rush_td") + n(s, "rec_td"), "TD")
        add(n(s, "rec"), "REC")
        add(n(s, "rec_yd"), "REC YD")
    elif pos == "WR" or pos == "TE":
        add(n(s, "rec"), "REC", True)
        add(n(s, "rec_yd"), "YD", True)
        add(n(s, "rec_td") + n(s, "rush_td"), "TD")
        if n(s, "rush_yd") >= 10:
            add(n(s, "rush_yd"), "RUSH YD")
    elif pos == "K":
        p.append([str(n(s, "fgm")) + "/" + str(n(s, "fga")), "FG"])
        if n(s, "xpa") > 0:
            p.append([str(n(s, "xpm")) + "/" + str(n(s, "xpa")), "XP"])
        if n(s, "fgm_50p") > 0:
            add(n(s, "fgm_50p"), "50+")
        if not season and n(s, "fgm_lng") > 0:
            p.append([str(n(s, "fgm_lng")), "LONG"])
    elif pos == "DEF":
        add(n(s, "def_td") + n(s, "def_st_td"), "TD")
        add(n(s, "int"), "INT")
        add(n(s, "sack"), "SACK")
        if not season:
            add(n(s, "pts_allow"), "PA", True)
        add(n(s, "fum_rec"), "FR")
        add(n(s, "safe"), "SAFETY")
    return p

def parse_rows(rows, pos, key):
    out = []
    teams = {}
    for r in rows:
        if type(r) != "dict":
            continue
        s = r.get("stats", None)
        pl = r.get("player", None)
        if type(s) != "dict" or type(pl) != "dict":
            continue
        pts = s.get(key, None)
        if type(pts) not in ["int", "float"] or s.get("gp", 0) in [0, None]:
            continue
        team = str(r.get("team", "") or pl.get("team", "") or "")
        team = TEAM_FIX.get(team, team)
        teams[team] = True
        if pos == "DEF":
            # a defense is its team: the podium writes the club code
            nick = clean(pl.get("last_name", team))
            name = nick + " D/ST"
            forms = [name, name, nick, team if team != "" else nick]
        else:
            name = clean(str(pl.get("first_name", "")) + " " + str(pl.get("last_name", "")))
            if name == "":
                continue
            forms = name_forms(name)
            forms.append(forms[2])
        opp = clean(r.get("opponent", "") or "")
        out.append({"forms": forms, "team": team, "pts": float(pts), "stats": s,
                    "gp": n(s, "gp"), "opp": TEAM_FIX.get(opp, opp),
                    "cents": int(float(pts) * 100 + (0.5 if pts >= 0 else -0.5))})
    out = sorted(out, key = lambda x: x["cents"], reverse = True)
    return [rank_rows(out), len(teams)]

def rank_rows(rows):
    """Competition ranking, the way every fantasy app ranks: players on the
    same score share the better rank (16.0, 16.0, 16.0 are all K1) and the
    next one skips ahead. Each row also gets its display points: one
    decimal, or two when a neighbour would otherwise look tied with it
    (29.78 over 29.76 must not read 29.8 over 29.8 in different medals)."""
    out = []
    rank = 0
    for i, r in enumerate(rows):
        if i == 0 or r["cents"] != rows[i - 1]["cents"]:
            rank = i + 1
        tied = ((i > 0 and rows[i - 1]["cents"] == r["cents"]) or
                (i + 1 < len(rows) and rows[i + 1]["cents"] == r["cents"]))
        shown = fmt_pts(r["pts"])
        for j in [i - 1, i + 1]:
            if (j >= 0 and j < len(rows) and rows[j]["cents"] != r["cents"] and
                fmt_pts(rows[j]["pts"]) == shown):
                shown = fmt_cents(r["cents"])
        out.append(dict(r, rank = rank, tied = tied, shown = shown))
    return out

def get_stats(season, week, pos, key):
    """One position's rows for a week, or the season when week is 0.
    Returns [players, teams-with-stats] or None when the feed failed."""
    url = SLEEPER_STATS + season + ("/" + str(week) if week > 0 else "")
    r = http.get(url, params = {"season_type": "regular", "position[]": pos, "order_by": "pts_ppr"},
                 headers = HEADERS, ttl_seconds = STATS_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "list":
        return None
    return parse_rows(r["json"], pos, key)

def et_weekday(unix):
    """0 = Monday. US Eastern standard time is close enough: Monday night
    is final by 05:00 UTC Tuesday either way."""
    days = (unix - 5 * 3600) // 86400
    return (days + 3) % 7

def fetch(ctx, pos):
    """Everything a page needs for one position, or an error/empty screen."""
    sc = SCORING.get(str(ctx.inputs.get("scoring", "PPR")).strip().upper(), SCORING["PPR"])
    tf = str(ctx.inputs.get("timeframe", "LAST WEEK")).strip().upper()
    base = {"pos": pos, "score_label": sc[1]}

    st = http.get(SLEEPER_STATE, headers = HEADERS, ttl_seconds = STATE_TTL)
    if st["status_code"] == 0:
        return dict(base, ok = False, head = "SLEEPER OFFLINE", sub = "RETRY IN 3 MIN")
    if st["status_code"] != 200 or type(st["json"]) != "dict":
        return dict(base, ok = False, head = "SLEEPER ERROR", sub = "HTTP " + str(st["status_code"]) + " - RETRY SOON")
    j = st["json"]
    stype = str(j.get("season_type", ""))
    season = str(j.get("season", ""))
    week = j.get("week", 0)
    week = week if type(week) == "int" else 0

    # Offseason and preseason: last season's final table, whatever the
    # timeframe says - it is the only leaderboard there is.
    if stype not in ["regular", "post"]:
        prev = str(j.get("previous_season", ""))
        if prev == "":
            return dict(base, ok = False, head = "OFFSEASON", sub = "LEADERS RETURN IN WEEK 1")
        d = get_stats(prev, 0, pos, sc[0])
        if d == None:
            return dict(base, ok = False, head = "STATS FEED ERROR", sub = "RETRY IN 3 MIN")
        return dict(base, ok = True, players = d[0], when = prev + " FINAL", season = True)

    if stype == "post":
        week = 19    # the regular season is over; week 18 is its last

    if tf == "SEASON":
        d = get_stats(season, 0, pos, sc[0])
        if d == None:
            # The season WR feed is the largest Sleeper sends (~840 KB); if
            # it ever outgrows the 1 MB cap, show last week rather than go dark.
            tf = "LAST WEEK"
        elif len(d[0]) == 0:
            return dict(base, ok = True, players = [], when = "SEASON", season = True,
                        empty = ["SEASON JUST STARTING", "LEADERS AFTER WEEK 1"])
        else:
            return dict(base, ok = True, players = d[0], when = "SEASON", season = True, year = season)

    tries = [week - 1]
    wd = et_weekday(ctx.now.unix)
    if stype == "regular" and (wd == 1 or wd == 2):
        tries = [week, week - 1]
    for w in tries:
        if w < 1:
            continue
        d = get_stats(season, min(w, 18), pos, sc[0])
        if d == None:
            return dict(base, ok = False, head = "STATS FEED ERROR", sub = "RETRY IN 3 MIN")
        if d[1] >= 16 or (pos == "DEF" and len(d[0]) >= 16) or w == tries[len(tries) - 1]:
            if len(d[0]) == 0:
                break
            return dict(base, ok = True, players = d[0], when = "WEEK " + str(min(w, 18)), season = False)
    return dict(base, ok = True, players = [], when = "WEEK 1", season = False,
                empty = ["WEEK 1 UNDERWAY", "LEADERS AFTER MONDAY NIGHT"])

# --------------------------------------------------------------- rotation
def slot(ctx):
    """[position, rank index] for this refresh. With ALL, three refreshes
    per position (its top three), so the podium and the spotlight agree."""
    f = ctx.now.unix // REFRESH
    want = str(ctx.inputs.get("position", "ALL")).strip().upper()
    if want in POSITIONS:
        return [want, f % 5, False]
    s = f % (len(POSITIONS) * 3)
    return [POSITIONS[s // 3], s % 3, True]

# ------------------------------------------------------------ shared chrome
def fail_screen(c, d):
    c.fill("black")
    c.sprite(BALL, 12, 9, legend = BALL_LEG, scale = 2)
    # text centred on x 110 within 140 px: x 40..179, clear of the 2x ball
    # at x 12..29.
    hf = fit(c, d["head"], ["6x8", "5x7", "4x5"], 140)
    c.text(hf[1], 110, 8, font = hf[0], color = AMBER, align = "center")
    sf = fit(c, d["sub"], ["4x5"], 140)
    c.text(sf[1], 110, 20, font = sf[0], color = DIM, align = "center")

def quiet_screen(c, d):
    """Nothing ranked yet is an answer, not an error: green, and calm."""
    c.fill("black")
    c.sprite(TROPHY, 10, 4, legend = {"G": "#2A7A48", "H": GOOD, "S": "#1C5232", "B": "#3C4A5C"}, scale = 2)
    # text centred on x 110 within 140 px: x 40..179, clear of the trophy.
    hf = fit(c, d["empty"][0], ["6x8", "5x7", "4x5"], 140)
    c.text(hf[1], 110, 8, font = hf[0], color = GOOD, align = "center")
    sf = fit(c, d["empty"][1], ["4x5"], 140)
    c.text(sf[1], 110, 20, font = sf[0], color = DIM, align = "center")

def load_page(c, ctx):
    """[data, slot] or None when a fallback screen has been drawn."""
    sl = slot(ctx)
    d = fetch(ctx, sl[0])
    if not d["ok"]:
        fail_screen(c, d)
        return None
    if len(d["players"]) == 0:
        if "empty" not in d:
            d = dict(d, empty = ["NO " + sl[0] + " STATS YET", d["when"]])
        quiet_screen(c, d)
        return None
    return [d, sl]

# ------------------------------------------------------------- page: podium
# x 8..29 the legend column (position, week, scoring), then three columns
# with 2 px between them: 2nd x 32..79, 1st x 82..134, 3rd x 137..184, as a
# podium stands. Each column is the player's surname, then the club's
# 24 x 18 logo with the points in medal colour to its right, standing on a
# step lit along its top edge. The steps are 6, 4 and 2 rows tall, so the
# three columns step down from the middle like a real podium.
COLS = {2: [32, 48], 1: [82, 53], 3: [137, 48]}
LEG_X = 8
LEG_W = 22
WIN_W = 24
# medal rank -> [name y, stripe y, points fonts]
STEP = {1: [0, 26, ["6x8", "5x7", "4x5"]], 2: [2, 28, ["5x7", "4x5"]], 3: [4, 30, ["5x7", "4x5"]]}

# Surnames too long for a column even in 4x5, written the way a fantasy app
# abbreviates them rather than clipped mid-word.
SHORT = {"SMITH-NJIGBA": "S-NJIGBA", "MCLAUGHLIN": "MCLGHLIN",
         "EDWARDS-HELAIRE": "CEH", "VALDES-SCANTLING": "MVS"}

def squeeze(c, t, f, maxw):
    """Vowels out from the end, one at a time, until it fits:
    MCCAFFREY -> MCCAFFRY. The first letter always stays."""
    out = t
    for k in range(len(t) - 1, 0, -1):
        if c.text_width(out, f) <= maxw:
            break
        if "AEIOU".find(out[k]) >= 0:
            out = out[:k] + out[k + 1:]
    return out

def podium_name(c, nm, maxw):
    """The surname (a defense's club code) in 5x7, then 4x5; a known long
    one by its short form; a double-barrelled one as initial-hyphen-second
    ('S-NJIGBA') or its second half; then with vowels squeezed out from the
    end; a clip only as the last resort."""
    tries = [nm, SHORT.get(nm, nm)]
    if nm.find("-") > 0:
        h = nm.split("-")
        tries.append(h[0][:1] + "-" + h[len(h) - 1])
        tries.append(h[len(h) - 1])
    tries.append(squeeze(c, nm, "4x5", maxw))
    for t in tries:
        for f in ["5x7", "4x5"]:
            if c.text_width(t, f) <= maxw:
                return [f, t]
    return ["4x5", clip(c, nm, "4x5", maxw)]

def club(team):
    return TEAM_COLORS.get(team, ["#3A4356", DIM])

def podium(c, ctx):
    got = load_page(c, ctx)
    if got == None:
        return
    d = got[0]
    ps = d["players"]
    c.fill("black")

    # The legend column: position big, then when and how it was scored.
    # 'WEEK 18' is 34 px, so the week is written 'WK 18'; a season total
    # shows its year ('SEASON' is 29 px), '2025 FINAL' just the year.
    when = d["when"].replace("WEEK ", "WK ").replace(" FINAL", "")
    if when == "SEASON":
        when = d.get("year", "") or "SZN"
    pf = fit(c, d["pos"], ["9x12", "8x10", "6x8", "5x7"], LEG_W)
    c.text(pf[1], LEG_X, 3 + (12 - INKH[pf[0]]) // 2, font = pf[0], color = INK)
    c.text(clip(c, when, "4x5", LEG_W), LEG_X, 18, font = "4x5", color = DIM)
    c.text(d["score_label"], LEG_X, 25, font = "4x5", color = DIM)

    # Slots stand 2nd, 1st, 3rd. A tie lifts a slot to the shared rank, so
    # three kickers on 16.0 are three gold steps of the same height.
    for slotn in [1, 2, 3]:
        x0 = COLS[slotn][0]
        w = COLS[slotn][1]
        x1 = x0 + w - 1
        p = ps[slotn - 1] if slotn <= len(ps) else None
        rank = p["rank"] if p != None else slotn
        m = medal(rank)
        s = STEP[min(rank, 3)]
        # the step: a medal-coloured block, lit along its top edge
        c.rect(x0, s[1], x1, 31, fill = m[2])
        c.rect(x0, s[1], x1, s[1], fill = m[1])
        if s[1] + 1 <= 31:
            c.rect(x0 + 1, s[1] + 1, x1 - 1, 31, fill = m[0])
        if p == None:
            # an empty place keeps its rank, so the podium still stands
            c.text(str(rank), x0 + w // 2, s[0] + 8, font = "5x7", color = m[2], align = "center")
            continue
        # the club logo stands on the step, the score in medal colour beside it
        ly = s[1] - 18
        logo = LOGO_S.get(p["team"], "")
        tx0 = x0
        if logo != "":
            c.image(logo, x0, ly)
            tx0 = x0 + WIN_W
        aw = x1 - tx0
        pt = fit(c, p["shown"], s[2], aw)
        c.text(pt[1], tx0 + aw // 2 + 1, ly + (18 - INKH[pt[0]]) // 2,
               font = pt[0], color = m[0], align = "center")
        # 1 px clear of each column edge, so neighbouring names never run together
        nf = podium_name(c, p["forms"][3], w - 2)
        c.text(nf[1], x0 + w // 2, s[0] + (7 - INKH[nf[0]]) // 2, font = nf[0], color = INK,
               align = "center")

# ---------------------------------------------------------- page: spotlight
# x 8..47 the club logo, 40 x 24 at y 4; x 51..64 the medal on its ribbon.
# x 70..140 the chip row (rank, week and opponent) and the name as the hero;
# x 144..184 the points and the scoring. The stat line runs x 70..184 below.
# A season "112.6" or a tie-break "29.78" steps down from 10x16 to fit.
LOGO_X = 8
MEDAL_X = 51
TX = 70
TR = 140
TW = TR - TX + 1
PTS_L = 144
PTS_R = 184

# 14 x 26: a medal hung from the top edge on a ribbon in the club's colours
# (A accent, J jersey), through a clasp into a disc in the medal's colour
# (M face, H highlight, S rim). The rank is written on the disc.
MEDAL_ART = """
...AAJJJJAA...
...AAJJJJAA...
...AAJJJJAA...
...AAJJJJAA...
...AAJJJJAA...
...AAJJJJAA...
...AAJJJJAA...
...AAJJJJAA...
...AAJJJJAA...
....AJJJJA....
.....SSSS.....
.....S..S.....
....SSSSSS....
..SSMMMMMMSS..
.SMMHHMMMMMMS.
.SMHMMMMMMMMS.
SMHMMMMMMMMMMS
SMHMMMMMMMMMMS
SMMMMMMMMMMMMS
SMMMMMMMMMMMMS
SMMMMMMMMMMMMS
SMMMMMMMMMMMMS
.SMMMMMMMMMMS.
.SMMMMMMMMMMS.
..SSMMMMMMSS..
....SSSSSS....
"""

def stat_line(c, parts, x, y, maxw):
    """Numbers white, labels gray, 4 px between pairs; pairs are shed from
    the end until the line fits. Returns nothing - it only draws."""
    for keep in range(len(parts), 0, -1):
        w = 0
        for i in range(keep):
            w += c.text_width(parts[i][0] + " " + parts[i][1], "4x5") + (4 if i > 0 else 0)
        if w <= maxw:
            cx = x
            for i in range(keep):
                c.text(parts[i][0], cx, y, font = "4x5", color = INK)
                cx += c.text_width(parts[i][0] + " ", "4x5")
                c.text(parts[i][1], cx, y, font = "4x5", color = DIM)
                cx += c.text_width(parts[i][1], "4x5") + 4
            return

def spotlight(c, ctx):
    got = load_page(c, ctx)
    if got == None:
        return
    d = got[0]
    sl = got[1]
    ps = d["players"]
    idx = sl[1] % min(len(ps), 3 if sl[2] else 5)
    p = ps[idx]
    rank = p["rank"]
    m = medal(rank)
    tc = club(p["team"])
    c.fill("black")

    # the club logo opens the page, the medal hangs beside it
    c.image(LOGO.get(p["team"], "NFL.png"), LOGO_X, 4)
    c.sprite(MEDAL_ART, MEDAL_X, 0, legend = {"A": tc[0], "J": tc[1], "M": m[0], "H": m[1], "S": m[2]})
    c.text(str(rank), MEDAL_X + 7, 16, font = "5x7", color = "black", align = "center")

    # the score closes it on the right, in the medal's colour
    cx = (PTS_L + PTS_R + 1) // 2
    pt = fit(c, p["shown"], ["10x16", "9x12", "8x10"], PTS_R - PTS_L + 1)
    c.text(pt[1], cx, 1 + (15 - INKH[pt[0]]) // 2, font = pt[0], color = m[0], align = "center")
    c.text(d["score_label"] + " PTS", cx, 18, font = "4x5", color = DIM, align = "center")

    # chip row: the fantasy rank (WR1; T-K1 on a tie) in the medal colour,
    # then the richest context that fits, right-aligned to the text zone.
    tag = ("T-" if p["tied"] else "") + d["pos"] + str(rank)
    c.text(tag, TX, 1, font = "4x5", color = m[0])
    left = TX + c.text_width(tag, "4x5") + 4
    if d["season"]:
        yr = d["when"].replace(" FINAL", "") if d["when"].endswith(" FINAL") else ""
        ppg = (fmt_pts(p["pts"] / p["gp"]) + " PPG") if p["gp"] > 0 else ""
        metas = [ppg + "  " + str(p["gp"]) + " GP", ppg, yr]
        if yr != "":
            metas = [yr + "  " + ppg, ppg, yr]
    else:
        wk = d["when"].replace("WEEK ", "WK ")
        metas = [wk + " VS " + p["opp"], wk] if p["opp"] != "" else [wk]
    for mt in metas:
        mt = mt.strip()
        if mt != "" and c.text_width(mt, "4x5") <= TR - left + 1:
            c.text(mt, TR, 1, font = "4x5", color = DIM, align = "right")
            break

    # name hero, y 9..20
    forms = p["forms"]
    pick = None
    for o in [[0, "9x12"], [1, "9x12"], [2, "9x12"], [0, "8x10"], [1, "8x10"], [2, "8x10"],
              [1, "6x8"], [2, "6x8"], [2, "5x7"], [2, "4x5"]]:
        if c.text_width(forms[o[0]], o[1]) <= TW:
            pick = [forms[o[0]], o[1]]
            break
    if pick == None:
        pick = [clip(c, forms[2], "4x5", TW), "4x5"]
    c.text(pick[0], TX, 9 + (12 - INKH[pick[1]]) // 2, font = pick[1], color = INK)

    # the stat line runs the full width, under the score too
    stat_line(c, stat_parts(d["pos"], p["stats"], d["season"]), TX, 25, PTS_R - TX + 1)
