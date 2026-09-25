# NFL Team Leaders
#
# One club's season leaders, one category per page:
#
#   passing    the passer's yards, with his TDs and INTs
#   rushing    the rusher's yards, with his carries and TDs
#   receiving  the receiver's yards, with his catches and TDs
#   defense    the tackle, sack and interception leaders as a three-row board
#
# DESIGN. A broadcast stat graphic, read left to right: the club's logo (the
# hand-tuned 40 x 24 pixel-art set, drawn 1:1 - never scaled) with the season
# under it, then the nameplate, the number, and on the right a pixel-art
# player in the club's own uniform doing the job, his real jersey number over
# his helmet. The figure is the category label - the QB cocked to throw, the
# RB with the ball tucked, the WR high-pointing a catch (a tight end takes it
# into his chest, a back catches it on the run), the defender squared up
# facing the board - so nobody needs to read PASSING.
#
# The one loud thing is the nameplate: a leaning plate in the club's jersey
# colour across the top, the name knocked out of it in white (black on a
# bright jersey), like a TV lower third. Everything under it stays on black
# and quiet: the yards as a 16x20 hero, the unit in the club accent, the TDs
# and INTs in white - always both, '0 INT' included - and the player's league
# rank as a footnote ('5TH IN NFL', gold when he leads the league). The
# defense page trades the hero for a three-row board - label, player, number
# - and puts each number on its own small jersey-colour plate, the same lean
# as the nameplate; a shared lead shows as '+1' after the name.
#
# Data: ESPN's core API, teams/{id}/leaders (about 44 KB) names each leader by
# athlete $ref. A hero page adds one athlete call (name, jersey, position)
# and the league leaders call (top 32 per stat, about 240 KB) for the rank;
# the defense page adds three athlete calls. The host's 8-uncached-requests
# limit counts the WHOLE render (all four pages), and repeated URLs are free,
# so a cold render is: team leaders 1 + league leaders 1 + 6 athletes = 8.
# With the pre-season fallback the extra leaders call is paid for by skipping
# the rank (last season's rank is not the news), so it is 8 again.
# Before a club's first game the season has no leaders yet, so the app falls
# back to last season, and the year under the logo - in the club accent then
# - says which one it is.

CORE = "https://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/"
HEADERS = {"User-Agent": "glance-nfl-team-leaders (glance-led.dev)"}

# Leaders change after each game; refresh is 1800 s and the leaders call is
# cached for the same 1800 s. Names never change, so athletes are cached a day.
LEADERS_TTL = 1800
ATHLETE_TTL = 86400

# ------------------------------------------------------------------ layout
# 192 wide. Logo x 6..45 (40 x 24 at y 1) with the season in 4x5 centred
# under it at y 27; text zone x 52..185, so 6 px of edge padding each side
# and 6 px of black between logo and text.
LOGO_X = 6
LOGO_Y = 1
LOGO_CX = 26
TX = 52
R = 185
# Player zone x 164..185 (22 x 24 at y 8, the jersey number above it at
# y 0..6); the nameplate and text beside it stop at x 159, keeping 4 px of
# black before the figure.
PX = 164
PR = 159

INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
WHITE = "#F0F2F5"

FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5, "3x7": 7, "picopixel": 5}

# Defense-board names, largest first. 3x7 is the last step before a hard
# clip: behind a wide number ("14.5", "156") only about 41 px are left, and
# HUTCHINSON (47 px in 4x5) and SCHWESINGER (54) fit only in the condensed
# 3x7 (39 and 43 px).
DEF_NAME_FONTS = ["5x7", "4x5", "3x7"]

# ESPN team id and abbreviation, keyed by the dropdown label.
TEAMS = {
    "ARIZONA CARDINALS": ["22", "ARI"], "ATLANTA FALCONS": ["1", "ATL"],
    "BALTIMORE RAVENS": ["33", "BAL"], "BUFFALO BILLS": ["2", "BUF"],
    "CAROLINA PANTHERS": ["29", "CAR"], "CHICAGO BEARS": ["3", "CHI"],
    "CINCINNATI BENGALS": ["4", "CIN"], "CLEVELAND BROWNS": ["5", "CLE"],
    "DALLAS COWBOYS": ["6", "DAL"], "DENVER BRONCOS": ["7", "DEN"],
    "DETROIT LIONS": ["8", "DET"], "GREEN BAY PACKERS": ["9", "GB"],
    "HOUSTON TEXANS": ["34", "HOU"], "INDIANAPOLIS COLTS": ["11", "IND"],
    "JACKSONVILLE JAGUARS": ["30", "JAX"], "KANSAS CITY CHIEFS": ["12", "KC"],
    "LAS VEGAS RAIDERS": ["13", "LV"], "LOS ANGELES CHARGERS": ["24", "LAC"],
    "LOS ANGELES RAMS": ["14", "LAR"], "MIAMI DOLPHINS": ["15", "MIA"],
    "MINNESOTA VIKINGS": ["16", "MIN"], "NEW ENGLAND PATRIOTS": ["17", "NE"],
    "NEW ORLEANS SAINTS": ["18", "NO"], "NEW YORK GIANTS": ["19", "NYG"],
    "NEW YORK JETS": ["20", "NYJ"], "PHILADELPHIA EAGLES": ["21", "PHI"],
    "PITTSBURGH STEELERS": ["23", "PIT"], "SAN FRANCISCO 49ERS": ["25", "SF"],
    "SEATTLE SEAHAWKS": ["26", "SEA"], "TAMPA BAY BUCCANEERS": ["27", "TB"],
    "TENNESSEE TITANS": ["10", "TEN"], "WASHINGTON COMMANDERS": ["28", "WSH"],
}
DEFAULT_TEAM = "KANSAS CITY CHIEFS"

# Literal asset paths: the publish lint reads c.image() paths as literals.
LOGOS = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png",
    "SEA": "SEA.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
}

# abbr -> [accent, second]. Each club's own colours, with navy, black and
# deep purple lifted so they read on an LED (the same tuning as the logos).
# The accent carries the unit label and the category mark; the second draws
# the defense board's hairlines.
TEAM_COLOR = {
    "ARI": ["#FF3B5C", "#F0F2F5"], "ATL": ["#FF3348", "#A5ACAF"],
    "BAL": ["#9B7BFF", "#D0A52E"], "BUF": ["#3D7BFF", "#E8203A"],
    "CAR": ["#19A6F0", "#B8BEC4"], "CHI": ["#FF5A1F", "#5B7FD8"],
    "CIN": ["#FF6A1F", "#F0F2F5"], "CLE": ["#FF5A1F", "#B07A4A"],
    "DAL": ["#4D8BFF", "#B0B7BC"], "DEN": ["#FF6A1F", "#4F7FC8"],
    "DET": ["#2FA8F0", "#B0B7BC"], "GB": ["#FFB612", "#35A866"],
    "HOU": ["#FF3348", "#5B7FB8"], "IND": ["#4D95F0", "#F0F2F5"],
    "JAX": ["#1FC0D0", "#D7A22A"], "KC": ["#FF2447", "#FFB612"],
    "LV": ["#C4CACD", "#8A9196"], "LAC": ["#2AB0F8", "#FFC20E"],
    "LAR": ["#FFD100", "#4D82FF"], "MIA": ["#00C8D0", "#FC6A12"],
    "MIN": ["#A57BFF", "#FFC62F"], "NE": ["#FF3348", "#6A8AD0"],
    "NO": ["#D3BC8D", "#F0F2F5"], "NYG": ["#4D7BFF", "#FF3348"],
    "NYJ": ["#2FC080", "#F0F2F5"], "PHI": ["#1FB8B0", "#B0B7BC"],
    "PIT": ["#FFB612", "#F0F2F5"], "SF": ["#FF3B3B", "#D4B46A"],
    "SEA": ["#69BE28", "#6A8AD0"], "TB": ["#FF3348", "#B0A8A0"],
    "TEN": ["#4B92DB", "#F0F2F5"], "WSH": ["#FFB612", "#D8454E"],
}

# abbr -> [accent, jersey, helmet, pants]: the uniform the players wear,
# copied from Fantasy Football News so a club dresses the same in both apps.
TEAM_STYLE = {
    "ARI": ["#E0304F", "#E0304F", "#F0F2F5", "#F0F2F5"],
    "ATL": ["#E8243C", "#E8243C", "#A5ACAF", "#F0F2F5"],
    "BAL": ["#D0A52E", "#7B5CE8", "#7B5CE8", "#F0F2F5"],
    "BUF": ["#E8203A", "#2A6BFF", "#F0F2F5", "#F0F2F5"],
    "CAR": ["#19A6F0", "#19A6F0", "#B8BEC4", "#F0F2F5"],
    "CHI": ["#FF5A1F", "#3F63C0", "#3F63C0", "#F0F2F5"],
    "CIN": ["#FF6A1F", "#FF6A1F", "#FF6A1F", "#F0F2F5"],
    "CLE": ["#FF4E10", "#9A6433", "#FF4E10", "#F0F2F5"],
    "DAL": ["#B0B7BC", "#3D7BFF", "#B0B7BC", "#B0B7BC"],
    "DEN": ["#FF5A14", "#FF5A14", "#3A6AB0", "#F0F2F5"],
    "DET": ["#1C9BE8", "#1C9BE8", "#B0B7BC", "#B0B7BC"],
    "GB": ["#FFB612", "#2E8B57", "#FFB612", "#FFB612"],
    "HOU": ["#E8233C", "#3A5A8C", "#3A5A8C", "#F0F2F5"],
    "IND": ["#3D86E8", "#3D86E8", "#F0F2F5", "#F0F2F5"],
    "JAX": ["#D7A22A", "#00A5B8", "#D7A22A", "#F0F2F5"],
    "KC": ["#FFB612", "#FF2447", "#FF2447", "#F0F2F5"],
    "LV": ["#C4CACD", "#8A9196", "#C4CACD", "#C4CACD"],
    "LAC": ["#FFC20E", "#2AA8F0", "#F0F2F5", "#F0F2F5"],
    "LAR": ["#FFD100", "#2F6BFF", "#2F6BFF", "#FFD100"],
    "MIA": ["#FC6A12", "#00C2CC", "#F0F2F5", "#F0F2F5"],
    "MIN": ["#FFC62F", "#8F5BE8", "#8F5BE8", "#F0F2F5"],
    "NE": ["#E8203F", "#3A5A9C", "#B0B7BC", "#B0B7BC"],
    "NO": ["#D3BC8D", "#D3BC8D", "#D3BC8D", "#F0F2F5"],
    "NYG": ["#E8203F", "#2A5FE0", "#2A5FE0", "#D0D4DA"],
    "NYJ": ["#F0F2F5", "#1FA36E", "#1FA36E", "#F0F2F5"],
    "PHI": ["#B0B7BC", "#0FA0A8", "#0FA0A8", "#F0F2F5"],
    "PIT": ["#FFB612", "#FFB612", "#FFB612", "#F0F2F5"],
    "SF": ["#D4B46A", "#E8201F", "#D4B46A", "#D4B46A"],
    "SEA": ["#69BE28", "#3A5A9C", "#3A5A9C", "#F0F2F5"],
    "TB": ["#F0263A", "#F0263A", "#8A8580", "#F0F2F5"],
    "TEN": ["#4B92DB", "#4B92DB", "#F0F2F5", "#F0F2F5"],
    "WSH": ["#FFB612", "#B8323A", "#B8323A", "#FFB612"],
}

# --------------------------------------------------------------- pixel art
# The ball, for the offline card.
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

# The players: 22 x 24 at 1x, in the club's uniform. H helmet, T helmet
# stripe, M facemask, J jersey (j the far arm and side, a shade darker),
# N number, G gloves, P pants (p far leg), S socks (s far sock), K cleats,
# B ball, L laces. The offense faces right, into the page; the defense faces
# left, at them.
QB_ART = """
.BBB..................
BBLBB.................
BBLBB.....HHHHH.......
.BBBG....HHTTTHH......
....GJ..HHHHHHHHH.....
.....jJ.HHHHHHHMMM....
......jJHHH.HHHM.M....
.......jJHHHHHHMMM....
........jJHHHH........
........JJJJJJJJJJJGG.
.......jJJJJJJJJJJJGG.
.......jJJNNNJJJ......
.......jJJN.NJJ.......
.......jJJNNNJJ.......
........jJJJJJJ.......
........pPPPPPPP......
........ppPP.PPPP.....
.......pppP...PPPP....
......ppp......PPPP...
......sss.......SSS...
.....sss.........SSS..
.....sss..........SSS.
....KKKK..........KKKK
...KKKK............KKK
"""
RB_ART = """
..............HHHHH...
.............HHTTTHH..
............HHHHHHHHH.
............HHHHHHHMMM
............HHH.HHHM.M
.............HHHHHHMMM
..........JJJJHHHH....
........jJJJJJJJJJ....
.......jjJJJJJJJBBB...
......jj.JJJJJJBBLBB..
.....GG..JJNNNJBBLBB..
.........JJN.NJJBBB...
.........JJNNNJJGG....
..........JJJJJJ......
..........pPPPPPP.....
.........ppPPPPPPP....
........ppp...PPPP....
.......ppp.....PPPP...
......sss.......SSS...
.....sss.........SSS..
....sss...........SS..
...KKK............KKK.
..KKK..............KKK
......................
"""
WR_ART = """
...............BBB....
..............BBLBB...
.............BBBLBBB..
..............GBBBG...
.............GG...GG..
............jJ....JJ..
.....HHHHH.jJ.....JJ..
....HHTTTHHjJ....JJ...
...HHHHHHHHjJ...JJ....
...HHHHHHMMMJ..JJ.....
...HHH.HHM.MJJJJ......
....HHHHHMMMJJJ.......
.....jJJJJJJJJ........
....jjJJJJJJJ.........
....jjJJNNNJJ.........
....jjJJN.NJJ.........
.....jJJNNNJ..........
.....pPPPPPPP.........
.....ppPP..PPPP.......
....ppp......PPPP.....
...sss.........SSS....
..sss...........SS....
.KKK............KKK...
KKK..............KK...
"""
TE_ART = """
......................
......................
......................
.........HHHHH........
........HHTTTHH.......
.......HHHHHHHHH......
.......HHHHHHHMMM.....
.......HHH.HHHM.M.....
....jJJJHHHHHHMMM.....
..jjJJJJJJHHHH....BBB.
.jjJJJJJJJJJJJJJGBLLLB
.jjJJJJJJJJJJJJJG.BBB.
.jjJJJNNNJJ..JJJJ.....
..jJJJN.NJJ...........
..jJJJNNNJ............
..pPPPPPPPP...........
.ppPPPPPPPPP..........
.ppp....PPPPP.........
.ppp.....PPPPP........
.sss......PPPP........
.sss.......SSS........
.sss.......SSS........
KKKK.......KKKK.......
KKK.........KKKK......
"""
DEF_ART = """
......................
......................
.......HHHHH..........
......HHTTTHH.........
.....HHHHHHHHH........
....MMMHHHHHHH........
....M.MHHH.HHH........
....MMMHHHHHH.........
.GG....HHHHJJJJ.......
GGGJJJJJJJJJJJJj......
.GG.JJJJJJJJJJJJjj....
......JJNNNJJJ..jjj...
......JJN.NJJJ...GG...
.......JNNNJJ.........
.......PPPPPPp........
......PPPPPPPpp.......
.....PPPP...ppppp.....
....PPPP.....pppp.....
....SSS.......sss.....
....SSS.......sss.....
....SSS.......sss.....
...KKKK.......KKKK....
......................
......................
"""
# page -> the player doing that job. The receiving page dresses the figure
# for the leader's position: a tight end takes the ball into his chest, a
# back catches it on the run, anyone else high-points it like a wideout. The
# rushing page keeps the runner even for a scrambling QB - there the figure
# is the category label, and a QB winding up to throw would read PASSING.
PLAYER = {"passing": QB_ART, "rushing": RB_ART, "receiving": WR_ART, "defense": DEF_ART}
RECEIVER_ART = {"TE": TE_ART, "RB": RB_ART, "FB": RB_ART}

def figure_for(page, pos):
    if page == "receiving":
        return RECEIVER_ART.get(pos, WR_ART)
    return PLAYER[page]

# ------------------------------------------------------------- text tools
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/&#"

def clean(s):
    """Panel-safe uppercase: the fonts have no apostrophe, and a missing
    glyph is dropped silently, so it is removed on purpose (JA'MARR ->
    JAMARR) along with anything outside plain ASCII."""
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
    t = str(text)
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            return [f, t]
    f = fonts[len(fonts) - 1]
    return [f, clip(c, t, f, maxw)]

SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]
PARTICLE = ["ST.", "ST", "VAN", "VON", "DE", "DI", "DA", "DU", "LA", "LE", "DEL", "DOS", "DER", "DEN", "TER"]

def name_forms(full):
    """[full, initial + rest, surname, bare surname(, first half of a
    hyphenated one)], longest first. The surname keeps its particle and
    suffix: 'AMON-RA ST. BROWN' -> 'A. ST. BROWN' -> 'ST. BROWN', 'LUKAS
    VAN NESS' -> 'VAN NESS', 'TYRONE TRACY JR.' -> 'TRACY JR.'."""
    parts = [p for p in full.split(" ") if p != ""]
    if len(parts) < 2:
        return [full, full, full]
    n = len(parts)
    start = n - 1
    if n >= 3 and parts[n - 1] in SUFFIX:
        start = n - 2
    for k in range(3):
        if start >= 2 and parts[start - 1] in PARTICLE:
            start -= 1
    forms = [full, parts[0][:1] + ". " + " ".join(parts[1:]), " ".join(parts[start:])]
    # Last resorts before a hard clip, so a cut lands on a word: the surname
    # without its suffix, then the first half of a hyphenated one ('ZAVEN
    # COLLINS-WASHINGTON JR.' ends as 'COLLINS', not 'COLLINS-WA').
    end = n - 1 if parts[n - 1] in SUFFIX and n - 1 > start else n
    bare = " ".join(parts[start:end])
    forms.append(bare)
    if "-" in bare:
        forms.append(bare.split("-")[0])
    return forms

def pick_name(c, forms, fonts, maxw):
    """The biggest face first, then the shorter forms of the name."""
    for f in fonts:
        for n in forms:
            if c.text_width(n, f) <= maxw:
                return [n, f]
    f = fonts[len(fonts) - 1]
    return [clip(c, forms[len(forms) - 1], f, maxw), f]

def fmt_value(v):
    """Leader values arrive as floats: 36.0 -> '36', 4.5 sacks -> '4.5'."""
    if type(v) == "float" and v != int(v):
        tenths = int(v * 10 + 0.5)
        return str(tenths // 10) + "." + str(tenths % 10)
    return str(int(v))

# ------------------------------------------------------------------ data
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def season_year(now):
    """The NFL season is named for the year it starts: January's playoffs
    belong to last year's season."""
    return now.year if now.month >= 8 else now.year - 1

def fetch_leaders(team_id, year):
    """[status, category name -> top leader, category name -> how many
    others share his number]. status is 'ok', 'offline', 'error' or 'empty'
    (no season yet, or nobody has a stat)."""
    r = http.get(CORE + str(year) + "/types/2/teams/" + team_id + "/leaders",
                 headers = HEADERS, ttl_seconds = LEADERS_TTL)
    if r["status_code"] == 0:
        return ["offline", {}, {}]
    if r["status_code"] == 404:
        return ["empty", {}, {}]
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return ["error", {}, {}]
    cats = {}
    ties = {}
    for cat in get(r["json"], "categories", []):
        ls = get(cat, "leaders", [])
        if type(ls) != "list" or len(ls) == 0 or type(ls[0]) != "dict":
            continue
        name = str(get(cat, "name", ""))
        cats[name] = ls[0]
        top = get(ls[0], "value", None)
        n = 0
        for l in ls[1:]:
            if type(l) == "dict" and top != None and get(l, "value", None) == top:
                n += 1
        ties[name] = n
    return ["ok" if len(cats) > 0 else "empty", cats, ties]

def load_team(ctx):
    label = str(ctx.inputs.get("team", DEFAULT_TEAM)).strip().upper()
    if label not in TEAMS:
        label = DEFAULT_TEAM
    t = TEAMS[label]
    year = season_year(ctx.now)
    res = fetch_leaders(t[0], year)
    last = False
    if res[0] == "empty":
        # Before week 1 the new season has no leaders: show last season's.
        res = fetch_leaders(t[0], year - 1)
        if res[0] == "ok":
            year -= 1
            last = True
        elif res[0] != "empty":
            res = ["empty", {}, {}]
    words = label.split(" ")
    return {"status": res[0], "cats": res[1], "ties": res[2], "abbr": t[1],
            "year": year, "last": last, "nick": words[len(words) - 1]}

def athlete(leader):
    """{name, jersey, pos, id} from the leader's athlete $ref. A failed
    lookup costs the name, number and position, not the page."""
    out = {"name": "", "jersey": "", "pos": "", "id": ""}
    ref = str(get(get(leader, "athlete", {}), "$ref", ""))
    if ref == "":
        return out
    ref = ref.replace("http://", "https://")
    q = ref.find("?")
    if q > 0:
        ref = ref[:q]
    out["id"] = ref.split("/")[-1]
    r = http.get(ref, headers = HEADERS, ttl_seconds = ATHLETE_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return out
    j = r["json"]
    out["name"] = clean(get(j, "displayName", ""))
    jn = str(get(j, "jersey", ""))
    out["jersey"] = jn if jn.isdigit() and len(jn) <= 2 else ""
    out["pos"] = clean(get(get(j, "position", {}), "abbreviation", ""))
    return out

def ordinal(n):
    if n % 100 in [11, 12, 13]:
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

# Only a brag is shown: a team leader ranked outside the top 32 in the
# league ('56TH IN NFL') says nothing a fan wants to read.
RANK_MAX = 32

def league_rank(year, value, stat):
    """[rank, 'T-5TH'-style label] for a season total in one stat, or [0, '']
    outside the top 32. One league leaders call (top 32 per stat) serves all
    three hero pages, so the render stays inside the 8-request limit; the
    rank is 1 + the number of players ahead of this value, 'T-' when another
    player has the same number."""
    if type(value) not in ["int", "float"] or value <= 0:
        return [0, ""]
    r = http.get(CORE + str(year) + "/types/2/leaders?limit=" + str(RANK_MAX),
                 headers = HEADERS, ttl_seconds = LEADERS_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return [0, ""]
    for cat in get(r["json"], "categories", []):
        if get(cat, "name", "") != stat:
            continue
        vals = [get(l, "value", None) for l in get(cat, "leaders", [])]
        vals = [x for x in vals if type(x) in ["int", "float"]]
        if len(vals) == 0:
            return [0, ""]
        ahead = len([x for x in vals if x > value])
        same = len([x for x in vals if x == value])
        # Below the 32nd man, or not in a list that stops short of 32.
        if same == 0 and (len(vals) >= RANK_MAX or value < vals[len(vals) - 1]):
            return [0, ""]
        rk = ahead + 1
        if rk > RANK_MAX:
            return [0, ""]
        return [rk, ("T-" if same > 1 else "") + ordinal(rk)]
    return [0, ""]

# ------------------------------------------------------------ shared chrome
def logo_block(c, abbr, year, last):
    """The club's logo, and the season it is showing centred under it - in
    the club accent when it is last season's, so '2025' reads as meant."""
    c.image(LOGOS[abbr], LOGO_X, LOGO_Y)
    if year != None:
        c.text(str(year), LOGO_CX, 27, font = "4x5", color = accent(abbr)[0] if last else DIM, align = "center")

def accent(abbr):
    return TEAM_COLOR.get(abbr, ["#B0BCCB", DIM])

def player(c, art, abbr):
    """The player zone, x 164..185 at y 8: a 22 x 24 figure in the club's
    uniform doing this page's job. The helmet stripe is the first club
    colour that shows on the helmet (KC's red helmet takes the gold)."""
    st = TEAM_STYLE[abbr]
    stripe = WHITE
    for s in [st[0], st[3], WHITE]:
        if s != st[2]:
            stripe = s
            break
    leg = {"H": st[2], "T": stripe, "M": "#9AA3B2", "J": st[1], "j": color.dim(st[1], 60),
           "N": WHITE, "G": WHITE, "P": st[3], "p": color.dim(st[3], 60), "S": st[1],
           "s": color.dim(st[1], 60), "K": "#8A94A8", "B": "#A0522D", "L": "#FFFFFF"}
    c.sprite(art, PX, 8, legend = leg)

def plate(c, x0, x1, y0, h, fill):
    """A broadcast-graphic plate: a parallelogram leaning right like a TV
    lower third, 3 px of lean over its height, x0..x1 at its widest."""
    for i in range(h):
        s = (h - 1 - i) * 3 // (h - 1)
        c.line(x0 + s, y0 + i, x1 - 3 + s, y0 + i, color = fill)

def jersey_fill(abbr):
    return TEAM_STYLE[abbr][1]

def ink_for(fill):
    """Text on a plate: white, flipped to black once the fill is bright.
    The cut is luma 142, measured on the jersey table: it flips PIT's gold,
    NO's old gold and LV's silver (143, where white measured under 3:1) and
    keeps white on CIN's orange (142) and the light blues (LAC 138, MIA
    137), where white reads as the club's own numbers do."""
    h = fill.lstrip("#")
    r = int(h[0:2], 16)
    g = int(h[2:4], 16)
    b = int(h[4:6], 16)
    return "#000000" if (299 * r + 587 * g + 114 * b) // 1000 > 142 else WHITE

def fail_screen(c, head, sub):
    c.fill("black")
    c.rect(0, 0, 1, 31, fill = OFFLINE)
    c.sprite(BALL, 12, 12, legend = BALL_LEG)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 150)
    c.text(hf[1], 110, 8, font = hf[0], color = "amber", align = "center")
    sf = fit(c, sub, ["4x5", "picopixel"], 150)
    c.text(sf[1], 110, 20, font = sf[0], color = DIM, align = "center")

def quiet_screen(c, abbr, year, last, head, sub):
    """Nothing to show is an answer, not an error: green, and calm."""
    c.fill("black")
    logo_block(c, abbr, year, last)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], R - TX + 1)
    c.text(hf[1], TX, 8, font = hf[0], color = GOOD)
    sf = fit(c, sub, ["4x5", "picopixel"], R - TX + 1)
    c.text(sf[1], TX, 20, font = sf[0], color = DIM)

def guard(c, d):
    """Draws the error / empty screen and returns False when there is
    nothing to show."""
    if d["status"] == "offline":
        fail_screen(c, "ESPN OFFLINE", "LEADERS RETURN WHEN IT IS BACK")
        return False
    if d["status"] == "error":
        fail_screen(c, "ESPN STATS ERROR", "RETRY IN 30 MIN")
        return False
    if d["status"] == "empty":
        quiet_screen(c, d["abbr"], None, False, "NO STATS YET", "LEADERS APPEAR AFTER THE FIRST GAME")
        return False
    return True

# ------------------------------------------------------------ hero pages
# page -> [ESPN category, unit words (longest first), the parts of the
# displayValue line to show (always both, '0 INT' when ESPN leaves it out),
# fallback name, stat group, rank stat (a category of the league leaders)]
HERO = {
    "passing": ["passingLeader", ["PASS YDS", "YDS"], ["TD", "INT"], "PASSER", "passing", "passingYards"],
    "rushing": ["rushingLeader", ["RUSH YDS", "YDS"], ["CAR", "TD"], "RUSHER", "rushing", "rushingYards"],
    "receiving": ["receivingLeader", ["REC YDS", "YDS"], ["REC", "TD"], "RECEIVER", "receiving", "receivingYards"],
}

def extras(line, keep):
    """'52/77, 533 YDS, 6 TD' -> ['6 TD', '0 INT']. ESPN drops a zero part
    from the line, and a missing INT reads as missing data - a clean sheet
    is the brag, so every part in keep is shown, padded with 0."""
    found = {}
    for part in str(line).split(","):
        bits = clean(part).split(" ")
        if len(bits) == 2 and bits[1] in keep and bits[0].isdigit():
            found[bits[1]] = bits[0]
    return [found.get(k, "0") + " " + k for k in keep]

def row_width(c, parts, font, gap):
    w = gap * (len(parts) - 1)
    for p in parts:
        w += c.text_width(p, font)
    return w

def draw_row(c, parts, x, y, font, gap):
    for p in parts:
        c.text(p, x, y, font = font, color = INK)
        x += c.text_width(p, font) + gap

def hero_page(c, ctx, page):
    d = load_team(ctx)
    if not guard(c, d):
        return
    spec = HERO[page]
    leader = d["cats"].get(spec[0], None)
    if leader == None:
        quiet_screen(c, d["abbr"], d["year"], d["last"], "NO " + spec[3] + " YET", "NOBODY HAS " + spec[1][0] + " THIS SEASON")
        return
    col = accent(d["abbr"])
    who = athlete(leader)
    # Last season's rank (pre-season fallback) is skipped: it is not the
    # news, and its request is the one the fallback leaders call used up.
    rank = [0, ""] if d["last"] else league_rank(d["year"], get(leader, "value", None), spec[5])
    c.fill("black")
    logo_block(c, d["abbr"], d["year"], d["last"])

    # The nameplate, y 0..9 over x 50..159: the club's jersey colour as a
    # leaning broadcast plate with the name stroked white on it, then his
    # jersey number over the figure's head in the club accent (x 164..185,
    # y 0..6; the figure starts at y 8). 'AMON-RA ST. BROWN' is 118 px at
    # 6x8 and 98 px sit inside the plate's lean, so it becomes
    # 'A. ST. BROWN' at 6x8 rather than dropping a size.
    player(c, figure_for(page, who["pos"]), d["abbr"])
    plate(c, 50, PR, 0, 10, jersey_fill(d["abbr"]))
    full = who["name"]
    forms = name_forms(full) if full != "" else [d["nick"] + " " + spec[3]] * 3
    nm = pick_name(c, forms, ["6x8", "5x7"], PR - 5 - 55 + 1)
    c.text(nm[0], 55, 1 + (8 - FONTH[nm[1]]) // 2, font = nm[1], color = ink_for(jersey_fill(d["abbr"])))
    if who["jersey"] != "":
        c.text("#" + who["jersey"], PX + 11, 0, font = "5x7", color = col[0], align = "center")

    # Row 2 (y 11..30): yards as the hero, the unit and the rest of the line
    # stacked beside it, all inside x 52..159. No thousands comma: at 16x20
    # it draws as a 12 px hole ('1 ,401') and costs the stack its room.
    v = get(leader, "value", None)
    num = str(int(v)) if type(v) in ["float", "int"] else "0"
    stack = extras(get(leader, "displayValue", ""), spec[2])
    big = "16x20" if PR - (TX + c.text_width(num, "16x20") + 4) + 1 >= 30 else "10x16"
    c.text(num, TX, 11 if big == "16x20" else 13, font = big, color = INK)
    sx = TX + c.text_width(num, big) + 4
    sw = PR - sx + 1
    unit_w = 0
    for u in spec[1]:
        if c.text_width(u, "5x7") <= sw:
            c.text(u, sx, 11, font = "5x7", color = col[0])
            unit_w = c.text_width(u, "5x7")
            break

    # The stack under the unit, largest that fits: both parts on one 5x7
    # row, else one 4x5 row, else one part per 4x5 row. The league rank is
    # the footnote under them ('5TH IN NFL', gold when he leads the league)
    # and is dropped first: behind '4183' only 39 px are left and the TDs
    # and INTs matter more. Without a rank the row sits on the hero's
    # baseline (y 24 in 5x7, y 26 in 4x5).
    r = rank[1]
    rt = ""
    if r != "":
        for t in [r + " IN NFL", r + " NFL", r]:
            if c.text_width(t, "4x5") <= sw:
                rt = t
                break
    rcol = "#FFC83D" if rank[0] == 1 else INK
    if row_width(c, stack, "5x7", 5) <= sw:
        draw_row(c, stack, sx, 19 if rt != "" else 24, "5x7", 5)
        if rt != "":
            c.text(rt, sx, 27, font = "4x5", color = rcol)
    elif row_width(c, stack, "4x5", 4) <= sw:
        draw_row(c, stack, sx, 19 if rt != "" else 26, "4x5", 4)
        if rt != "":
            c.text(rt, sx, 26, font = "4x5", color = rcol)
    else:
        # Behind a 4-digit hero the footnote has no row, so the bare
        # ordinal rides the unit row when it fits ('YDS 1ST', 4x5 on the
        # 5x7 baseline).
        for i in range(len(stack)):
            c.text(clip(c, stack[i], "4x5", sw), sx, 19 + i * 7, font = "4x5", color = INK)
        if r != "" and unit_w > 0 and unit_w + 4 + c.text_width(r, "4x5") <= sw:
            c.text(r, sx + unit_w + 4, 13, font = "4x5", color = rcol)

def passing(c, ctx):
    hero_page(c, ctx, "passing")

def rushing(c, ctx):
    hero_page(c, ctx, "rushing")

def receiving(c, ctx):
    hero_page(c, ctx, "receiving")

# ------------------------------------------------------------ defense page
# [ESPN category, label]
DEF_ROWS = [
    ["totalTackles", "TKLS"],
    ["sacks", "SACKS"],
    ["interceptions", "INTS"],
]

def defense(c, ctx):
    d = load_team(ctx)
    if not guard(c, d):
        return
    col = accent(d["abbr"])
    rows = []
    for spec in DEF_ROWS:
        leader = d["cats"].get(spec[0], None)
        v = get(leader, "value", None)
        if type(v) not in ["float", "int"] or v <= 0:
            rows.append([spec[1], "", "0", 0])
        else:
            nm = athlete(leader)["name"]
            # A failed name lookup keeps the number: the row names the club.
            rows.append([spec[1], nm if nm != "" else "?" + d["nick"], fmt_value(v), d["ties"].get(spec[0], 0)])
    c.fill("black")
    logo_block(c, d["abbr"], d["year"], d["last"])

    # Three rows, y 0..9, 11..20, 22..31, beside the defender (x 52..159).
    # Each number sits on its own jersey-colour plate, stroked white - the
    # board's one loud thing - measured first and right-aligned at x 159 so
    # the three line up; the label is in the club accent from x 52, the
    # name 4 px after the widest label (a fixed x ran 'SACKS' into the
    # name) and clipped to what the plate leaves. A shared lead shows as
    # '+1' after the name: early in the season most of these are ties.
    player(c, DEF_ART, d["abbr"])
    fill = jersey_fill(d["abbr"])
    nx = TX + max([c.text_width(r[0], "4x5") for r in rows]) + 4
    for i in range(3):
        y = i * 11
        lab, name, val, tie = rows[i][0], rows[i][1], rows[i][2], rows[i][3]
        c.text(lab, TX, y + 3, font = "4x5", color = col[0])
        vw = c.text_width(val, "6x8")
        # The plate leans 3 px, so the number keeps 2 px of fill inside the
        # lean at both ends: x PR-4-vw .. PR-5, plate x PR-vw-9 .. PR.
        px0 = PR - vw - 9
        if val == "0":
            c.text(val, PR - 5, y + 1, font = "6x8", color = DIM, align = "right")
        else:
            plate(c, px0, PR, y, 10, fill)
            c.text(val, PR - 4 - vw, y + 1, font = "6x8", color = ink_for(fill))
        maxw = px0 - 3 - nx + 1
        if name == "":
            c.text(clip(c, "NONE YET", "4x5", maxw), nx, y + 3, font = "4x5", color = DIM)
            continue
        if name.startswith("?"):
            nm = pick_name(c, [name[1:]], DEF_NAME_FONTS, maxw)
            c.text(nm[0], nx, y + 1 + (8 - FONTH[nm[1]]) // 2, font = nm[1], color = DIM)
            continue
        # The '+N' tie tag gives way before the name is cut.
        tag = "+" + str(tie) if tie > 0 else ""
        tw = c.text_width(tag, "4x5") + 3 if tag != "" else 0
        forms = name_forms(name)
        nm = pick_name(c, forms, DEF_NAME_FONTS, maxw - tw)
        if tag != "" and nm[0] not in forms:
            tag = ""
            nm = pick_name(c, forms, DEF_NAME_FONTS, maxw)
        ny = y + 1 + (8 - FONTH[nm[1]]) // 2
        c.text(nm[0], nx, ny, font = nm[1], color = INK)
        if tag != "":
            c.text(tag, nx + c.text_width(nm[0], nm[1]) + 3, y + 3, font = "4x5", color = DIM)
