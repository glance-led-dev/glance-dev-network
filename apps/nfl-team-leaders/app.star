# NFL Team Leaders
#
# One club's season leaders, one category per page:
#
#   passing    the passer's yards, with his TDs and INTs
#   rushing    the rusher's yards, with his carries and TDs
#   receiving  the receiver's yards, with his catches and TDs
#   defense    the tackle, sack and interception leaders as a three-row board
#
# DESIGN. Every page is a trading card. The panel is one framed card in the
# club's jersey colour (x 6..185, a 1 px frame), split like a horizontal
# Topps card: on the left a photo window behind a 2 px jersey-colour mat, on
# the right the card's stat side on black. The one memorable thing is the
# player in the window: a 22 x 24 pixel-art figure in the club's uniform,
# drawn 1:1 and centred in the photo, standing on a strip of turf under a night-sky gradient, lit by a halo. He is doing the page's job - the QB cocked to
# throw, the RB with the ball tucked, the WR high-pointing a catch (a tight
# end takes it into his chest, a back catches it on the run), the defender
# squared up - so nobody needs to read PASSING. The window's left column carries the rest of the card
# furniture: the club logo small in the top corner (the authored 24 x 18
# set, drawn 1:1 - logos are never scaled) and his real jersey number under
# it in the club's trim ("foil") colour.
#
# The stat side is the card's nameplate: a plate in the club's trim
# ("foil") colour across the top with the player's name knocked out of it
# and a small stamp at its right end - his league rank ('5TH IN NFL'), or
# the card year when there is no rank ('2025 SEASON' on last season's card).
# Under it his yards in 10x16, the unit in the club accent and the rest of
# the line beside it (always both parts, '0 INT' included). The defense card
# trades the plate for a three-row board - label, player, number on a small
# leaning foil plate - with '+1' after a shared lead, and carries the card
# year under the logo instead of a jersey number.
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
# back to last season, and the card year says which one it is.

CORE = "https://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/"
HEADERS = {"User-Agent": "glance-nfl-team-leaders (glance-led.dev)"}

# Leaders change after each game; refresh is 1800 s and the leaders call is
# cached for the same 1800 s. Names never change, so athletes are cached a day.
LEADERS_TTL = 1800
ATHLETE_TTL = 86400

# ------------------------------------------------------------------ layout
# 192 wide. The card is x 6..185, y 0..31 (1 px frame in the jersey colour,
# 6 px of edge padding each side). The photo window's mat fills x 7..73,
# y 1..30 in the jersey colour; the glass inside it is x 9..71, y 2..29 with
# the turf in its bottom three rows. The stat side is x 75..184 on black,
# text x 77..182.
CARD_X0 = 6
CARD_X1 = 185
MAT_X1 = 73
GX0 = 9
GX1 = 71
# The figure is centred on x 54 in the glass right of the logo column.
FIG_CX = 54
GY0 = 2
GY1 = 29
SX0 = 75
TX = 77
R = 182

INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
WHITE = "#F0F2F5"
GOLD = "#FFC83D"
SKY_TOP = "#1B2A4A"
SKY_LOW = "#070B14"
HALO = "#2A3C66"
TURF = "#1F7A36"
TURF_LOW = "#12501F"

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

# The authored 24 x 18 small set, drawn 1:1 as the card's corner badge.
SMALL_LOGOS = {
    "ARI": "S_ARI.png", "ATL": "S_ATL.png", "BAL": "S_BAL.png", "BUF": "S_BUF.png",
    "CAR": "S_CAR.png", "CHI": "S_CHI.png", "CIN": "S_CIN.png", "CLE": "S_CLE.png",
    "DAL": "S_DAL.png", "DEN": "S_DEN.png", "DET": "S_DET.png", "GB": "S_GB.png",
    "HOU": "S_HOU.png", "IND": "S_IND.png", "JAX": "S_JAX.png", "KC": "S_KC.png",
    "LV": "S_LV.png", "LAC": "S_LAC.png", "LAR": "S_LAR.png", "MIA": "S_MIA.png",
    "MIN": "S_MIN.png", "NE": "S_NE.png", "NO": "S_NO.png", "NYG": "S_NYG.png",
    "NYJ": "S_NYJ.png", "PHI": "S_PHI.png", "PIT": "S_PIT.png", "SF": "S_SF.png",
    "SEA": "S_SEA.png", "TB": "S_TB.png", "TEN": "S_TEN.png", "WSH": "S_WSH.png",
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


# The players: 22 x 24 at 1x, drawn 1:1 (a 5:4 stretch to 26 x 30 was tried
# and read lumpy), in the club's uniform. H helmet, T helmet stripe, M
# facemask, J jersey (j the far arm and side, a shade darker), N number, G
# gloves, P pants (p far leg), S socks (s far sock), K cleats, B ball, L
# laces. Blank rows are trimmed at draw time, so each figure stands on the
# turf.
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

# ------------------------------------------------------------ the card
def accent(abbr):
    return TEAM_COLOR.get(abbr, ["#B0BCCB", DIM])

def jersey_fill(abbr):
    return TEAM_STYLE[abbr][1]

def rgb(h):
    h = h.lstrip("#")
    return [int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)]

def far(a, b):
    """Two colours an LED shows as clearly different (RGB distance)."""
    x = rgb(a)
    y = rgb(b)
    return abs(x[0] - y[0]) + abs(x[1] - y[1]) + abs(x[2] - y[2]) >= 150

def foil(abbr):
    """The card's second colour - the nameplate, the jersey number, the
    defense plates: the club's trim (KC gold on the red card, BUF red on the
    blue) unless it is too close to the jersey (CIN's orange trim on an
    orange jersey), then the club accent, then white."""
    j = jersey_fill(abbr)
    for f in [TEAM_STYLE[abbr][0], TEAM_COLOR[abbr][1], TEAM_COLOR[abbr][0], WHITE]:
        if far(f, j):
            return f
    return WHITE

def ink_for(fill):
    """Text on a plate: white, flipped to black once the fill is bright.
    The cut is luma 142, measured on the club colours: it flips gold, old
    gold and silver (143, where white measured under 3:1) and keeps white on
    CIN's orange (142) and the light blues (LAC 138, MIA 137)."""
    x = rgb(fill)
    return "#000000" if (299 * x[0] + 587 * x[1] + 114 * x[2]) // 1000 > 142 else WHITE

def card(c, frame):
    """The empty card: the 1 px frame, the photo window's mat and glass (a
    night sky over three rows of turf) and the black stat side."""
    c.fill("black")
    c.round_rect(CARD_X0, 0, CARD_X1, 31, 2, outline = frame)
    c.rect(CARD_X0 + 1, 1, MAT_X1, 30, fill = frame)
    c.gradient_rect(GX0, GY0, GX1, GY1 - 3, SKY_TOP, SKY_LOW, horizontal = False)
    c.rect(GX0, GY1 - 2, GX1, GY1 - 2, fill = TURF_LOW)
    c.rect(GX0, GY1 - 1, GX1, GY1 - 1, fill = TURF)
    c.rect(GX0, GY1, GX1, GY1, fill = TURF_LOW)

def halo(c):
    """The photo's light: a soft disc behind the figure."""
    c.fill_circle(FIG_CX, 14, 12, HALO)

def trim(art):
    """The art's rows without the blank ones above and below the figure."""
    rows = [r for r in art.strip("\n").split("\n")]
    lit = [i for i in range(len(rows)) if rows[i].replace(".", "") != ""]
    return rows[lit[0]:lit[len(lit) - 1] + 1]

def player(c, art, abbr):
    """The figure, drawn 1:1 and centred on x 54 in front of the halo, his
    cleats on the turf a row above the mat. The helmet stripe is the first club
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
    halo(c)
    rows = trim(art)
    w = max([len(r) for r in rows])
    c.sprite(rows, FIG_CX - w // 2, GY1 - len(rows), legend = leg)

def corner_marks(c, abbr, number, year, last):
    """The card furniture in the window's left column (x 11..34): the club
    logo small in the top corner - the authored 24 x 18 set, drawn 1:1 -
    and under it the jersey number (foil, 5x7) on a hero card, or the card
    year (4x5, in the foil colour when it is last season's) on the defense
    card."""
    c.image(SMALL_LOGOS[abbr], GX0 + 2, GY0)
    if number != "":
        c.text("#" + number, GX0 + 2, GY0 + 19, font = "5x7", color = foil(abbr))
    elif year != None:
        c.text(str(year), GX0 + 2, GY0 + 21, font = "4x5", color = foil(abbr) if last else INK)

def plate(c, x0, x1, y0, h, fill):
    """A leaning plate like a card's foil stamp: 3 px of lean over its
    height, x0..x1 at its widest."""
    for i in range(h):
        s = (h - 1 - i) * 3 // (h - 1)
        c.line(x0 + s, y0 + i, x1 - 3 + s, y0 + i, color = fill)

def fail_screen(c, head, sub):
    """A card turned face down: a grey frame, the ball in the window."""
    card(c, OFFLINE)
    c.sprite(BALL, (GX0 + GX1) // 2 - 5, 12, legend = BALL_LEG)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], R - TX + 1)
    c.text(hf[1], TX, 6, font = hf[0], color = "amber")
    lines = two_lines(c, sub, "4x5", R - TX + 1)
    for i in range(len(lines)):
        c.text(lines[i], TX, 17 + i * 7, font = "4x5", color = DIM)

def two_lines(c, text, font, maxw):
    """The text on one line, or broken at a word onto two (each clipped)."""
    if c.text_width(text, font) <= maxw:
        return [text]
    words = text.split(" ")
    for k in range(len(words) - 1, 0, -1):
        first = " ".join(words[:k])
        if c.text_width(first, font) <= maxw:
            return [first, clip(c, " ".join(words[k:]), font, maxw)]
    return [clip(c, text, font, maxw)]

def quiet_screen(c, abbr, year, last, head, sub):
    """Nothing to show is an answer, not an error: the club's card with the
    full-size logo in the window, and a calm green line."""
    card(c, jersey_fill(abbr))
    c.image(LOGOS[abbr], (GX0 + GX1) // 2 - 19, GY0 + 1)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], R - TX + 1)
    c.text(hf[1], TX, 3, font = hf[0], color = GOOD)
    lines = two_lines(c, sub, "4x5", R - TX + 1)
    for i in range(len(lines)):
        c.text(lines[i], TX, 13 + i * 6, font = "4x5", color = DIM)
    if year != None:
        c.text(str(year), TX, 25, font = "4x5", color = foil(abbr) if last else INK)

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

def rank_forms(r):
    return [r + " IN NFL", r + " NFL", r] if r != "" else []

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
    f = foil(d["abbr"])
    card(c, jersey_fill(d["abbr"]))
    corner_marks(c, d["abbr"], who["jersey"], d["year"], d["last"])
    player(c, figure_for(page, who["pos"]), d["abbr"])

    # The nameplate, y 1..10 across the stat side (x 75..184, into the
    # frame): the foil colour with the name knocked out of it at x 77, and
    # a 4x5 stamp right-aligned at x 182. 'AMON-RA ST. BROWN' is 118 px in
    # 6x8, so it is 'A. ST. BROWN' (83).
    c.rect(SX0, 1, CARD_X1 - 1, 10, fill = f)
    ink = ink_for(f)
    full = who["name"]
    forms = name_forms(full) if full != "" else [d["nick"] + " " + spec[3]] * 3
    room = R - TX + 1
    # The stamp is the league rank, or - with no rank to show (pre-season
    # fallback, or outside the top 32) - the card year.
    rforms = rank_forms(rank[1])
    if rforms == []:
        rforms = [str(d["year"]) + " SEASON", str(d["year"])] if d["last"] else [str(d["year"])]
    # Name and stamp share the plate, like a card's: the name in 6x8 (full,
    # else initial + surname) with the longest stamp that fits beside it
    # ('5TH IN NFL' -> '5TH NFL' -> '5TH'), then the same in 5x7. Only when
    # neither form fits beside any stamp does the stamp leave (a rank then
    # rides the unit row) and the name take the whole plate. Last season's
    # card must say so: there the name may fall to the bare surname first.
    nm = None
    rt = ""
    names = forms if d["last"] else forms[:2]
    for font in ["6x8", "5x7"]:
        for n in names:
            for t in rforms:
                if c.text_width(n, font) + c.text_width(t, "4x5") + 6 <= room:
                    nm = [n, font]
                    rt = t
                    break
            if nm != None:
                break
        if nm != None:
            break
    if nm == None:
        nm = pick_name(c, forms, ["6x8", "5x7"], room)
    c.text(nm[0], TX, 2 + (8 - FONTH[nm[1]]) // 2, font = nm[1], color = ink)
    if rt != "":
        c.text(rt, R, 4, font = "4x5", color = ink, align = "right")

    # Under the plate (y 14..28): the yards in 10x16, then the unit in the
    # club accent and the rest of the line stacked beside it, largest face
    # that fits. No thousands comma: it draws as a hole ('1 ,401').
    v = get(leader, "value", None)
    num = str(int(v)) if type(v) in ["float", "int"] else "0"
    stack = extras(get(leader, "displayValue", ""), spec[2])
    c.text(num, TX, 14, font = "10x16", color = INK)
    sx = TX + c.text_width(num, "10x16") + 5
    sw = R - sx + 1
    unit_w = 0
    for u in spec[1]:
        if c.text_width(u, "5x7") <= sw:
            c.text(u, sx, 14, font = "5x7", color = col[0])
            unit_w = c.text_width(u, "5x7")
            break
    placed = False
    for fs in [["5x7", 5, 22], ["4x5", 4, 24], ["3x7", 3, 22]]:
        if row_width(c, stack, fs[0], fs[1]) <= sw:
            draw_row(c, stack, sx, fs[2], fs[0], fs[1])
            placed = True
            break
    if not placed:
        c.text(clip(c, " ".join(stack), "3x7", sw), sx, 22, font = "3x7", color = INK)

    # A rank the plate had no room for rides the unit row, right-aligned
    # (gold when he leads the league), or is dropped.
    if rt == "" and rank[1] != "":
        for t in rforms:
            if unit_w + 5 + c.text_width(t, "4x5") <= sw:
                c.text(t, R, 15, font = "4x5", color = GOLD if rank[0] == 1 else INK, align = "right")
                break

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
    f = foil(d["abbr"])
    card(c, jersey_fill(d["abbr"]))
    corner_marks(c, d["abbr"], "", d["year"], d["last"])
    player(c, DEF_ART, d["abbr"])

    # Three rows on the stat side, y 2..10, 12..20, 22..30. Each number sits
    # on its own small leaning foil plate (5x7, 1 px of fill above and
    # below), measured first and right-aligned so the three line up and
    # end at x 183, a pixel clear of the frame; the label is in the club
    # accent from x 77, the name 4 px after the widest label and clipped to
    # what the plate leaves. A shared lead shows as '+1' after the name.
    ink = ink_for(f)
    px1 = CARD_X1 - 2
    nx = TX + max([c.text_width(r[0], "4x5") for r in rows]) + 4
    for i in range(3):
        y = 2 + i * 10
        lab, name, val, tie = rows[i][0], rows[i][1], rows[i][2], rows[i][3]
        c.text(lab, TX, y + 2, font = "4x5", color = col[0])
        vw = c.text_width(val, "5x7")
        # The number keeps 2 px of fill inside the lean at both ends.
        px0 = px1 - vw - 8
        if val == "0":
            c.text(val, px1 - 4, y + 1, font = "5x7", color = DIM, align = "right")
        else:
            plate(c, px0, px1, y, 9, f)
            c.text(val, px1 - 4 - vw, y + 1, font = "5x7", color = ink)
        maxw = px0 - 3 - nx + 1
        if name == "":
            c.text(clip(c, "NONE YET", "4x5", maxw), nx, y + 2, font = "4x5", color = DIM)
            continue
        if name.startswith("?"):
            nm = pick_name(c, [name[1:]], DEF_NAME_FONTS, maxw)
            c.text(nm[0], nx, y + 1 + (7 - FONTH[nm[1]]) // 2, font = nm[1], color = DIM)
            continue
        # The '+N' tie tag gives way before the name is cut.
        tag = "+" + str(tie) if tie > 0 else ""
        tw = c.text_width(tag, "4x5") + 3 if tag != "" else 0
        forms = name_forms(name)
        nm = pick_name(c, forms, DEF_NAME_FONTS, maxw - tw)
        if tag != "" and nm[0] not in forms:
            tag = ""
            nm = pick_name(c, forms, DEF_NAME_FONTS, maxw)
        c.text(nm[0], nx, y + 1 + (7 - FONTH[nm[1]]) // 2, font = nm[1], color = INK)
        if tag != "":
            c.text(tag, nx + c.text_width(nm[0], nm[1]) + 3, y + 2, font = "4x5", color = DIM)
