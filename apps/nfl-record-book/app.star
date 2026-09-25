# NFL Record Book
#
# The league's all-time records and famous firsts, one a minute. Nothing is
# fetched: the book is baked in below, and every entry was chosen because it
# still stands going into the 2026 season (or is a dated first that can never
# be broken). Records that fell recently or sit on a knife edge are left out.
#
# DESIGN. The record book as a gold-leaf plaque, graphics first. The
# holder's club sits on the left - its 40 x 24 logo on black - closed off by
# a 2 px rail in the chapter's colour. On the right, the chip row names the
# record: a pill with its scope (SEASON, CAREER, GAME, FIRST...) and what was
# counted, in white. Under it the number itself is the hero - big, gold, with
# its unit - cast as raised gold leaf, with a 1 px bronze copy down-right
# like the letters on a Hall of Fame plaque - and to its right, who holds it
# and when. Every other lap, the when line says how long the record has
# stood (STANDS 74 YRS, or NEW 2025), whenever that costs the row nothing.
# Units the title already names (CAREER SACKS 200) are dropped so the
# picture gets the room. Every record carries a
# picture: the chapter's object (football, cleat, glove, helmet, goalposts,
# Lombardi trophy, record book) or the record's own (stopwatch, thermometer,
# turkey, ring, TV, birthday cake), drawn at 2x between hero and holder
# whenever the row has room, and at 1x in the chip row when it does not. A
# head-to-head record draws the other club as its logo under a small VS
# instead of naming it. The number is the only gold on the panel, so the eye
# lands on it first; the name is the only large white.
#
# Frames: one record per minute (refresh 60), stepping through the book with
# a stride that is coprime to its length so consecutive minutes jump between
# chapters instead of reading one chapter in order. A small n/N counter says
# the rotation is deliberate. The Records dropdown picks the whole book, one
# chapter, or one club (its records plus the famous games it lost).

# ------------------------------------------------------------------ layout
# 192 wide. Logo x 6..45 (40 x 24 at y 4), rail x 48..49, text zone x 53..185:
# 6 px edge padding each side, and 3 px of black between the rail and text.
LOGO_X = 6
LOGO_Y = 4
RAIL_X = 48
TX = 53
TR = 185
TW = TR - TX + 1

GOLD = "#FFC53D"
BRONZE = "#8A4E00"
INK = "#F4F7FF"
DIM = "#6E7A94"

# chapter -> [colour, icon]
CHAPTER = {
    "PASSING": ["#5CB8FF", "BALL"],
    "RUSHING": ["#2FE06F", "CLEAT"],
    "RECEIVING": ["#FF9A1F", "GLOVE"],
    "DEFENSE": ["#FF4B4B", "HELMET"],
    "SPECIAL TEAMS": ["#C792FF", "POSTS"],
    "TEAM": ["#FFC53D", "TROPHY"],
    "ODDITIES": ["#FF7EB6", "BOOK"],
}
ORDER = ["PASSING", "RUSHING", "RECEIVING", "DEFENSE", "SPECIAL TEAMS", "TEAM", "ODDITIES"]

# Literal paths: the publish lint only resolves asset names it can read.
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CHI": "CHI.png", "CLE": "CLE.png", "DAL": "DAL.png", "DEN": "DEN.png",
    "DET": "DET.png", "GB": "GB.png", "IND": "IND.png", "KC": "KC.png",
    "LAC": "LAC.png", "LAR": "LAR.png", "LV": "LV.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYJ": "NYJ.png",
    "PIT": "PIT.png", "SF": "SF.png", "TEN": "TEN.png", "WSH": "WSH.png",
    "JAX": "JAX.png", "PHI": "PHI.png", "NFL": "NFL.png",
}

# --------------------------------------------------------------- the book
# [chapter, scope pill, what was counted, number, unit, holder, short holder,
#  when / detail, club]. A career record carries the club the holder is most
# tied to; historic clubs wear today's logo (the 1940 Washington team, the
# 1929 Chicago Cardinals, the 2006 San Diego Chargers). A "*" unit means
# degrees.
RECORDS = [
    # passing
    ["PASSING", "SEASON", "PASS YARDS", "5,477", "YDS", "PEYTON MANNING", "MANNING", "2013 BRONCOS", "DEN", 2013],
    ["PASSING", "SEASON", "TD PASSES", "55", "TD", "PEYTON MANNING", "MANNING", "2013 BRONCOS", "DEN", 2013],
    ["PASSING", "CAREER", "PASS YARDS", "89,214", "YDS", "TOM BRADY", "BRADY", "2000-2022", "NE", 2022],
    ["PASSING", "CAREER", "TD PASSES", "649", "TD", "TOM BRADY", "BRADY", "2000-2022", "NE", 2022],
    ["PASSING", "CAREER", "QB WINS", "251", "WINS", "TOM BRADY", "BRADY", "REGULAR SEASON", "NE", 2022],
    ["PASSING", "GAME", "PASS YARDS", "554", "YDS", "NORM VAN BROCKLIN", "VAN BROCKLIN", "1951 RAMS", "LAR", 1951],
    ["PASSING", "GAME", "TD PASSES", "7", "TD", "SID LUCKMAN", "LUCKMAN", "1943 FIRST OF 8", "CHI", 1943],
    ["PASSING", "SEASON", "PASSER RATING", "122.5", "", "AARON RODGERS", "RODGERS", "2011 PACKERS", "GB", 2011],
    ["PASSING", "STREAK", "TD PASS GAMES", "54", "GAMES", "DREW BREES", "BREES", "2009-12 SAINTS", "NO", 2012],
    ["PASSING", "STREAK", "STARTS AT QB", "297", "STARTS", "BRETT FAVRE", "FAVRE", "1992-2010", "GB", 2010],
    ["PASSING", "ROOKIE", "TD PASSES", "31", "TD", "JUSTIN HERBERT", "HERBERT", "2020 CHARGERS", "LAC", 2020],
    ["PASSING", "STREAK", "TD W/O INT", "28", "TD", "MATTHEW STAFFORD", "STAFFORD", "2025 RAMS", "LAR", 2025],
    # rushing
    ["RUSHING", "SEASON", "RUSH YARDS", "2,105", "YDS", "ERIC DICKERSON", "DICKERSON", "1984 RAMS", "LAR", 1984],
    ["RUSHING", "SEASON", "RUSH YDS+PLAYOFFS", "2,504", "YDS", "SAQUON BARKLEY", "BARKLEY", "2024 EAGLES", "PHI", 2024],
    ["RUSHING", "CAREER", "RUSH YARDS", "18,355", "YDS", "EMMITT SMITH", "E. SMITH", "1990-2004", "DAL", 2004],
    ["RUSHING", "CAREER", "RUSH TDS", "164", "TD", "EMMITT SMITH", "E. SMITH", "1990-2004", "DAL", 2004],
    ["RUSHING", "GAME", "RUSH YARDS", "296", "YDS", "ADRIAN PETERSON", "PETERSON", "2007 VIKINGS", "MIN", 2007],
    ["RUSHING", "SEASON", "RUSH TDS", "28", "TD", "LADAINIAN TOMLINSON", "TOMLINSON", "2006 CHARGERS", "LAC", 2006],
    ["RUSHING", "SEASON", "SCRIMMAGE YDS", "2,509", "YDS", "CHRIS JOHNSON", "C. JOHNSON", "2009 TITANS", "TEN", 2009],
    ["RUSHING", "FIRST", "2,000-YD YEAR", "2,003", "YDS", "O.J. SIMPSON", "SIMPSON", "1973 BILLS", "BUF", 0],
    ["RUSHING", "LONGEST", "RUN", "99", "YDS", "TONY DORSETT", "DORSETT", "1982 TIED 2018", "DAL", 1982],
    ["RUSHING", "SEASON", "QB RUSH YARDS", "1,206", "YDS", "LAMAR JACKSON", "L. JACKSON", "2019 RAVENS", "BAL", 2019],
    ["RUSHING", "GAME", "POINTS SCORED", "40", "PTS", "ERNIE NEVERS", "NEVERS", "1929 CARDINALS", "ARI", 1929],
    # receiving
    ["RECEIVING", "SEASON", "REC YARDS", "1,964", "YDS", "CALVIN JOHNSON", "C. JOHNSON", "2012 LIONS", "DET", 2012],
    ["RECEIVING", "CAREER", "REC YARDS", "22,895", "YDS", "JERRY RICE", "RICE", "1985-2004", "SF", 2004],
    ["RECEIVING", "CAREER", "RECEPTIONS", "1,549", "REC", "JERRY RICE", "RICE", "1985-2004", "SF", 2004],
    ["RECEIVING", "CAREER", "REC TDS", "197", "TD", "JERRY RICE", "RICE", "1985-2004", "SF", 2004],
    ["RECEIVING", "CAREER", "TOTAL TDS", "208", "TD", "JERRY RICE", "RICE", "1985-2004", "SF", 2004],
    ["RECEIVING", "SEASON", "RECEPTIONS", "149", "REC", "MICHAEL THOMAS", "M. THOMAS", "2019 SAINTS", "NO", 2019],
    ["RECEIVING", "SEASON", "REC TDS", "23", "TD", "RANDY MOSS", "MOSS", "2007 PATRIOTS", "NE", 2007],
    ["RECEIVING", "GAME", "REC YARDS", "336", "YDS", "FLIPPER ANDERSON", "ANDERSON", "1989 RAMS", "LAR", 1989],
    ["RECEIVING", "GAME", "RECEPTIONS", "21", "REC", "BRANDON MARSHALL", "MARSHALL", "2009 BRONCOS", "DEN", 2009],
    ["RECEIVING", "ROOKIE", "REC YARDS", "1,486", "YDS", "PUKA NACUA", "NACUA", "2023 RAMS", "LAR", 2023],
    ["RECEIVING", "SEASON", "TE REC YARDS", "1,416", "YDS", "TRAVIS KELCE", "KELCE", "2020 CHIEFS", "KC", 2020],
    # defense
    ["DEFENSE", "CAREER", "SACKS", "200", "", "BRUCE SMITH", "B. SMITH", "1985-2003", "BUF", 2003],
    ["DEFENSE", "GAME", "SACKS", "7", "", "DERRICK THOMAS", "D. THOMAS", "1990 CHIEFS", "KC", 1990],
    ["DEFENSE", "SEASON", "SACKS", "23", "", "MYLES GARRETT", "GARRETT", "2025 BROWNS", "CLE", 2025],
    ["DEFENSE", "LONGEST", "INT RETURN", "107", "YDS", "ED REED", "REED", "2008 RAVENS", "BAL", 2008],
    ["DEFENSE", "SEASON", "INTERCEPTIONS", "14", "INT", "NIGHT TRAIN LANE", "LANE", "1952 RAMS", "LAR", 1952],
    ["DEFENSE", "CAREER", "INTERCEPTIONS", "81", "INT", "PAUL KRAUSE", "KRAUSE", "1964-1979", "MIN", 1979],
    ["DEFENSE", "CAREER", "PICK-SIX TDS", "12", "TD", "ROD WOODSON", "WOODSON", "1987-2003", "PIT", 2003],
    # special teams
    ["SPECIAL TEAMS", "CAREER", "POINTS SCORED", "2,673", "PTS", "ADAM VINATIERI", "VINATIERI", "1996-2019", "IND", 2019],
    ["SPECIAL TEAMS", "CAREER", "FIELD GOALS", "599", "FG", "ADAM VINATIERI", "VINATIERI", "1996-2019", "IND", 2019],
    ["SPECIAL TEAMS", "SEASON", "FIELD GOALS", "44", "FG", "DAVID AKERS", "AKERS", "2011 49ERS", "SF", 2011],
    ["SPECIAL TEAMS", "LONGEST", "FIELD GOAL", "68", "YDS", "CAM LITTLE", "LITTLE", "2025 JAGUARS", "JAX", 2025],
    ["SPECIAL TEAMS", "GAME", "FIELD GOALS", "8", "FG", "ROB BIRONAS", "BIRONAS", "2007 TITANS", "TEN", 2007],
    ["SPECIAL TEAMS", "LONGEST", "PUNT", "98", "YDS", "STEVE ONEAL", "ONEAL", "1969 JETS", "NYJ", 1969],
    ["SPECIAL TEAMS", "CAREER", "PUNT RET TDS", "14", "TD", "DEVIN HESTER", "HESTER", "2006-14 BEARS/ATL", "CHI", 2014],
    ["SPECIAL TEAMS", "CAREER", "KICK RET TDS", "9", "TD", "CORDARRELLE PATTERSON", "PATTERSON", "SET 2022 FALCONS", "ATL", 2022],
    ["SPECIAL TEAMS", "SEASON", "ALL-PURPOSE YDS", "2,696", "YDS", "DARREN SPROLES", "SPROLES", "2011 SAINTS", "NO", 2011],
    ["SPECIAL TEAMS", "FIRST", "109-YARD PLAY", "109", "YDS", "ANTONIO CROMARTIE", "CROMARTIE", "2007 FG RETURN", "LAC", 0],
    # team
    ["TEAM", "ONLY", "PERFECT SEASON", "17-0", "", "1972 DOLPHINS", "DOLPHINS", "1972 SB VII CHAMPS", "MIA", 1972],
    ["TEAM", "SEASON", "POINTS SCORED", "606", "PTS", "2013 BRONCOS", "BRONCOS", "2013 SEASON", "DEN", 2013],
    ["TEAM", "GAME", "POINTS SCORED", "72", "PTS", "WASHINGTON", "WASHINGTON", "1966 VS GIANTS", "WSH", 1966],
    ["TEAM", "BIGGEST", "WIN EVER", "73-0", "", "1940 BEARS", "BEARS", "1940 TITLE GAME", "CHI", 1940],
    ["TEAM", "BIGGEST", "COMEBACK", "33", "PTS", "2022 VIKINGS", "VIKINGS", "2022 - WON 39-36", "MIN", 2022],
    ["TEAM", "MOST", "NFL TITLES", "13", "", "PACKERS", "PACKERS", "9 PRE-SB + 4 SB", "GB", 0],
    ["TEAM", "STREAK", "WINS W/ PLAYOFFS", "21", "WINS", "PATRIOTS", "PATRIOTS", "2003-2004", "NE", 2004],
    ["TEAM", "SUPER BOWL", "WIN MARGIN", "45", "PTS", "49ERS", "49ERS", "SB XXIV 55-10", "SF", 1990],
    ["TEAM", "SUPER BOWL", "COMEBACK", "25", "PTS", "PATRIOTS", "PATRIOTS", "SB LI DOWN 28-3", "NE", 2017],
    ["TEAM", "FIRST", "6-TIME SB CHAMP", "6", "", "STEELERS", "STEELERS", "SB XLIII 2009", "PIT", 0],
    # oddities
    ["ODDITIES", "LONGEST", "GAME PLAYED", "82:40", "", "DOLPHINS 27-24", "DOLPHINS", "2OT XMAS 1971", "MIA", 1971],
    ["ODDITIES", "COLDEST", "GAME PLAYED", "-13", "*F", "THE ICE BOWL", "ICE BOWL", "1967 GB 21-17", "GB", 1967],
    ["ODDITIES", "OLDEST", "PLAYER EVER", "48", "YRS", "GEORGE BLANDA", "BLANDA", "1975 RAIDERS", "LV", 1975],
    ["ODDITIES", "MOST", "GAMES PLAYED", "382", "", "MORTEN ANDERSEN", "ANDERSEN", "1982-2007", "NO", 2007],
    ["ODDITIES", "MOST", "COACHING WINS", "347", "", "DON SHULA", "SHULA", "WITH PLAYOFFS", "MIA", 1995],
    ["ODDITIES", "MOST", "SB RINGS", "7", "RINGS", "TOM BRADY", "BRADY", "6 NE + 1 TB", "NE", 2021],
    ["ODDITIES", "FIRST", "SUPER BOWL", "35-10", "", "PACKERS", "PACKERS", "1967 VS CHIEFS", "GB", 0],
    ["ODDITIES", "FIRST", "MONDAY NIGHT", "31-21", "", "BROWNS", "BROWNS", "1970 VS JETS", "CLE", 0],
    ["ODDITIES", "SINCE", "THANKSGIVING", "1934", "", "LIONS", "LIONS", "TURKEY DAY HOSTS", "DET", 0],
    ["ODDITIES", "FIRST", "WINLESS SEASON", "0-16", "", "2008 LIONS", "LIONS", "2008 SEASON", "DET", 0],
]

# --------------------------------------------------------------- pixel art
# At most 10 x 7, so every icon sits in the chip row (y 0..6). Each chapter
# has its own object - the ball for passing, a cleat for rushing, a glove for
# receiving, a helmet for defense, goalposts for special teams, the Lombardi
# trophy for team records, the closed record book itself (a gold star on
# its cover) for oddities - and some records carry their own picture in place of a word: a stopwatch for the
# longest game, a thermometer for the coldest, a turkey on Thanksgiving, a
# ring, a TV for Monday Night, a birthday cake for the oldest player.
# X takes the chapter's colour; every other letter is fixed.
PAL = {"X": "", "W": "#FFFFFF", "B": "#B0602D", "D": "#6B3414", "S": "#B8C0CC",
       "K": "#5A6478", "Y": "#FFC53D", "R": "#FF3D2E", "O": "#FF9A1F",
       "L": "#3D8BFF", "P": "#FF7EB6", "N": "#8A5A2B"}

ICON = {
    "BALL": """
...DDD...
.DBBBBBD.
DBBWBWBBD
DBWWWWWBD
DBBWBWBBD
.DBBBBBD.
...DDD...
""",
    "CLEAT": """
.XX......
.XWX.....
.XWWXX...
.XWWWXXX.
XXXXXXXXX
KKKKKKKKK
.S..S..S.
""",
    "GLOVE": """
..X.X.X..
..X.X.X.X
..X.X.X.X
X.XXXXXXX
XXXXXXXXX
.XXXXXXX.
..WWWWW..
""",
    "HELMET": """
..XXXXX...
.XXXXXXX..
XXWWXXXXX.
XXXXXX.SSS
XXXXXXXS.S
.XXXXXXSSS
...XX.....
""",
    "POSTS": """
Y.....Y
Y.....Y
Y.....Y
YYYYYYY
...Y...
...Y...
..KKK..
""",
    "TROPHY": """
..SSS..
.SSWSS.
.SWSSS.
..SSS..
...S...
..YYY..
.YYYYY.
""",
    "BOOK": """
.XXXXXXXX
XKXXXXXXW
XKXXYXXXW
XKXYYYXXW
XKXXYXXXW
XKXXXXXXW
.XXXXXXXX
""",
    "WATCH": """
...SSS...
....S....
..WWWWW..
.WW.W.WW.
.W..WWWW.
.WW...WW.
..WWWWW..
""",
    "THERMO": """
.SSS.
.S.S.
.SLS.
.SLS.
SLLLS
SLLLS
.SSS.
""",
    "TURKEY": """
.ROYOR....
ROYNYOR...
.NNNNN.RR.
NNNNNNNW..
.NNNNNN...
..NNNN....
..Y..Y....
""",
    "RING": """
...LWL...
....L....
..YYYYY..
.YY...YY.
.Y.....Y.
.YY...YY.
..YYYYY..
""",
    "TV": """
..K...K...
...K.K....
SSSSSSSSS.
SLLLLLLSK.
SLLLLLLSS.
SLLLLLLSK.
SSSSSSSSS.
""",
    "CAKE": """
.Y.Y.Y.
.R.R.R.
WWWWWWW
PPPPPPP
WWWWWWW
PPPPPPP
.......
""",
}

NL = "\n"

def icon_w(name):
    rows = ICON[name].strip(NL).split(NL)
    return max([len(r) for r in rows])

def draw_icon(c, name, col, x, y):
    leg = dict(PAL)
    leg["X"] = col
    c.sprite(ICON[name], x, y, legend = leg)

def draw_icon2(c, name, col, x, y):
    leg = dict(PAL)
    leg["X"] = col
    c.sprite(ICON[name], x, y, legend = leg, scale = 2)

# Pictures that replace a word, and opponents drawn as their logo. Keyed by
# "value|what": {"icon": ..., "opp": club, "when": detail without "VS X"}.
EXTRA = {
    "82:40|GAME PLAYED": {"icon": "WATCH", "opp": "KC", "when": "XMAS 1971"},
    "-13|GAME PLAYED": {"icon": "THERMO", "opp": "DAL", "when": "1967 - 21-17"},
    "48|PLAYER EVER": {"icon": "CAKE"},
    "7|SB RINGS": {"icon": "RING"},
    "1934|THANKSGIVING": {"icon": "TURKEY"},
    "31-21|MONDAY NIGHT": {"icon": "TV", "opp": "NYJ", "when": "SEPT 1970"},
    "35-10|SUPER BOWL": {"opp": "KC", "when": "JAN 1967"},
    "72|POINTS SCORED": {"opp": "NYG", "when": "1966 - 72-41"},
    "73-0|WIN EVER": {"opp": "WSH", "when": "1940 TITLE"},
    "33|COMEBACK": {"opp": "IND", "when": "2022 - 39-36"},
    "45|WIN MARGIN": {"opp": "DEN", "when": "SB XXIV"},
    "25|COMEBACK": {"opp": "ATL", "when": "SB LI - 28-3"},
    "17-0|PERFECT SEASON": {"opp": "WSH", "when": "SB VII WIN"},
}

VS_LOGO = {"KC": "vs-KC.png", "DAL": "vs-DAL.png", "NYJ": "vs-NYJ.png", "NYG": "vs-NYG.png",
           "WSH": "vs-WSH.png", "DEN": "vs-DEN.png", "ATL": "vs-ATL.png", "IND": "vs-IND.png"}

# ------------------------------------------------------------- text tools
HEXD = "0123456789abcdef"

def ink_for(fill):
    """Black type on a bright pill, white on a dark one (brightness 150)."""
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k].rstrip(" -"), font) <= maxw:
            return t[:k].rstrip(" -")
    return ""

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [text, f]
    last = fonts[len(fonts) - 1]
    return [clip(c, text, last, maxw), last]

# Lit rows per face, top-aligned.
INKH = {"16x20_bold": 20, "16x20": 20, "10x16_bold": 16, "10x16": 16, "9x12_bold": 12, "9x12": 12,
        "6x8": 8, "5x7b": 7, "5x7": 7, "4x5": 5}

# ----------------------------------------------------------------- picking
def stands(r, year):
    """'STANDS 75 YRS' from the year the record was set; 'NEW 2025' for one
    set last season. Dated firsts (year 0) can't be broken, so they get none."""
    if r[9] == 0:
        return ""
    age = year - r[9]
    if age <= 1:
        return "NEW " + str(r[9])
    return "STANDS " + str(age) + " YRS"

# The Records dropdown also picks a club: every record it holds, plus every
# head-to-head it was on the wrong end of (a Cowboys fan gets Emmitt, Dorsett
# and the Ice Bowl). Only clubs with two or more entries are offered, so a
# pick never freezes on one record. Keys match the manifest's options.
TEAM = {
    "PATRIOTS": "NE", "49ERS": "SF", "RAMS": "LAR", "PACKERS": "GB", "BRONCOS": "DEN",
    "SAINTS": "NO", "CHIEFS": "KC", "VIKINGS": "MIN", "DOLPHINS": "MIA", "CHARGERS": "LAC",
    "LIONS": "DET", "COWBOYS": "DAL", "BEARS": "CHI", "COMMANDERS": "WSH", "COLTS": "IND",
    "TITANS": "TEN", "STEELERS": "PIT", "BROWNS": "CLE", "BILLS": "BUF", "RAVENS": "BAL",
    "JETS": "NYJ", "FALCONS": "ATL",
}

def chapter_list(ctx):
    want = str(ctx.inputs.get("category", "ALL")).strip().upper()
    if want in CHAPTER:
        return [r for r in RECORDS if r[0] == want]
    if want in TEAM:
        club = TEAM[want]
        return [r for r in RECORDS if r[8] == club or EXTRA.get(r[3] + "|" + r[2], {}).get("opp", "") == club]
    return RECORDS

def gcd(a, b):
    for i in range(64):
        if b == 0:
            break
        a, b = b, a % b
    return a

def stride(n):
    """A step coprime to n, so the rotation visits every record once per
    lap while consecutive minutes land in different chapters."""
    for s in [11, 7, 13, 17, 5, 3]:
        if s < n and gcd(s, n) == 1:
            return s
    return 1

# ------------------------------------------------------------------- draws
def unit_w(c, unit):
    if unit == "":
        return 0
    if unit.startswith("*"):
        return 4 + c.text_width(unit[1:], "5x7")
    return c.text_width(unit, "5x7")

def draw_unit(c, unit, x, y, col):
    if unit.startswith("*"):
        # A 3 x 3 degree ring: no bundled face carries the glyph.
        c.rect(x, y, x + 2, y + 2, outline = col)
        c.text(unit[1:], x + 4, y, font = "5x7", color = col)
    else:
        c.text(unit, x, y, font = "5x7", color = col)

# Bold faces only, so the gold number has the same weight on every record.
HERO_FONTS = ["16x20_bold", "10x16_bold", "9x12_bold"]

# The hero faces draw "," "." and ":" as full-width cells ("89 , 214"), so
# they are drawn by hand as small square dots between the digit runs.
PUNCT = [",", ".", ":"]

def dot(font):
    return 3 if INKH[font] >= 20 else 2

def hero_runs(value):
    runs = []
    cur = ""
    for ch in value.elems():
        if ch in PUNCT:
            if cur != "":
                runs.append(cur)
                cur = ""
            runs.append(ch)
        else:
            cur += ch
    if cur != "":
        runs.append(cur)
    return runs

def hero_w(c, value, font):
    w = 0
    for r in hero_runs(value):
        w += dot(font) + 2 if r in PUNCT else c.text_width(r, font)
    return w

def draw_hero(c, value, font, x, y, col):
    """The number as raised gold leaf: a bronze copy 1 px down-right, then
    the gold on top, like the letters cast on a Hall of Fame plaque."""
    draw_face(c, value, font, x + 1, y + 1, BRONZE)
    return draw_face(c, value, font, x, y, col)

def draw_face(c, value, font, x, y, col):
    h = INKH[font]
    d = dot(font)
    for r in hero_runs(value):
        if r in PUNCT:
            px = x + 1
            if r == ":":
                c.rect(px, y + h // 3 - 1, px + d - 1, y + h // 3 + d - 2, fill = col)
                c.rect(px, y + 2 * h // 3, px + d - 1, y + 2 * h // 3 + d - 1, fill = col)
            else:
                c.rect(px, y + h - d, px + d - 1, y + h - 1, fill = col)
                if r == ",":
                    c.pixel(px, y + h, col)
            x += d + 2
        else:
            c.text(r, x, y, font = font, color = col)
            x += c.text_width(r, font)
    return x

def plan_body(c, r, when, right, icon, alt = ""):
    """Largest hero face first. Under each face, graphics beat words: the
    record's icon at 2x in the gap (5 px of black each side) is tried with
    every holder form before any form is tried without it. A 4x5 name is a
    last resort, after every hero face has had a readable one ("VAN
    BROCKLIN" in 4x5 beside a 16x20 "554" loses the who). The full name is
    6x8 or 5x7b, never thin 5x7 beside a bold surname on the next record."""
    value, unit, full, short = r[3], r[4], r[5], r[6]
    tw = right - TX + 1
    # Sized for the wider of the detail and its alternate, so the layout
    # holds still when the detail line swaps.
    ww = max(c.text_width(when, "4x5"), c.text_width(alt, "4x5"))
    uw = unit_w(c, unit)
    iw2 = icon_w(icon) * 2 + 10
    holders = [[full, "6x8"], [short, "6x8"], [full, "5x7b"], [short, "5x7b"]]
    for hf in HERO_FONTS:
        hw = hero_w(c, value, hf) + (2 + uw if uw > 0 else 0)
        for extra in [iw2, 6]:
            for ho in holders:
                rw = max(c.text_width(ho[0], ho[1]), ww)
                if hw + extra + rw <= tw:
                    return {"hf": hf, "hw": hw, "name": ho[0], "nf": ho[1], "when": when,
                            "rw": rw, "big": extra == iw2}
    # Nothing fits whole: smallest hero, 4x5 name, and clip the detail.
    hf = HERO_FONTS[len(HERO_FONTS) - 1]
    hw = hero_w(c, value, hf) + (2 + uw if uw > 0 else 0)
    room = tw - hw - 6
    return {"hf": hf, "hw": hw, "name": clip(c, short, "4x5", room), "nf": "4x5",
            "when": clip(c, when, "4x5", room), "rw": room, "big": False}

def chip_row(c, r, col, icon, cnt, show_icon = True):
    """Icon, scope pill, then what was counted in white. The counter is the
    first thing shed, then the title drops to 4x5, then it is clipped."""
    px = TX
    if show_icon:
        draw_icon(c, icon, col, TX, 0)
        px = TX + icon_w(icon) + 3
    c.badge(r[1], px, 0, color = ink_for(col), bg = col, font = "4x5")
    tx = px + c.text_width(r[1], "4x5") + 4 + 3
    cw = c.text_width(cnt, "4x5")
    for f in ["5x7", "4x5"]:
        for keep in [True, False]:
            # 7 px: text_width counts no trailing column, and 5 px read as touching
            # ("PICK-SIX TDS" against "5/5").
            room = (TR - cw - 7 if keep else TR) - tx + 1
            if c.text_width(r[2], f) <= room:
                if keep:
                    c.text(cnt, TR, 1, font = "4x5", color = DIM, align = "right")
                c.text(r[2], tx, 0 if f == "5x7" else 1, font = f, color = INK)
                return
    c.text(clip(c, r[2], "4x5", TR - tx + 1), tx, 1, font = "4x5", color = INK)

def record(c, ctx):
    book = chapter_list(ctx)
    n = len(book)
    k = ctx.now.unix // 60
    idx = (k * stride(n)) % n
    r = book[idx]
    ch = CHAPTER[r[0]]
    col = ch[0]
    c.fill("black")

    # Identity: the holder's club, closed off by the chapter's rail.
    c.image(LOGO.get(r[8], "NFL.png"), LOGO_X, LOGO_Y)
    c.rect(RAIL_X, 0, RAIL_X + 1, 31, fill = col)

    ex = EXTRA.get(r[3] + "|" + r[2], {})
    icon = ex.get("icon", ch[1])

    # A head-to-head record shows the other club as its 24 x 18 logo at the
    # right edge, under a small VS, and the text block ends 4 px before it.
    # y 14 leaves a 1 px row of black between the VS and the logo's top.
    right = TR
    when = ex.get("when", r[7])
    alt = stands(r, ctx.now.year)
    opp = ex.get("opp", "")
    if opp in VS_LOGO:
        ox = TR - 23
        c.image(VS_LOGO[opp], ox, 14)
        c.text("VS", ox + 12, 8, font = "4x5", color = DIM, align = "center")
        right = ox - 4

    # When there is room, the icon moves out of the chip row and into the gap
    # between hero and holder at 2x; otherwise it stays 1x in the chip row.
    # The "stands" line never costs the page anything: the layout sized for
    # it is used only when it matches the one sized for the detail alone.
    p = plan_body(c, r, when, right, icon)
    if alt != "":
        pa = plan_body(c, r, when, right, icon, alt)
        if pa["hf"] == p["hf"] and pa["name"] == p["name"] and pa["nf"] == p["nf"] and pa["big"] == p["big"]:
            p = pa
    gap_l = TX + p["hw"] + 5
    gap_r = right - p["rw"] - 5
    big = p["big"]
    chip_row(c, r, col, icon, str(idx + 1) + "/" + str(n), not big)
    if big:
        draw_icon2(c, icon, col, (gap_l + gap_r + 1) // 2 - icon_w(icon), 12)

    # Body y 9..28: gold hero left, holder right-aligned.
    hh = INKH[p["hf"]]
    hy = 9 + (20 - hh) // 2
    end = draw_hero(c, r[3], p["hf"], TX, hy, GOLD)
    if r[4] != "":
        draw_unit(c, r[4], end + 2, hy + hh - 7, color.dim(GOLD, 70))

    nh = INKH[p["nf"]]
    block = nh + 3 + 5
    ny = 9 + (20 - block) // 2
    c.text(p["name"], right, ny, font = p["nf"], color = INK, align = "right")
    # Every other lap through the book, the detail line says how long the
    # record has stood - what a fan says out loud.
    wy = ny + nh + 3
    if alt != "" and (k // n) % 2 == 1 and c.text_width(alt, "4x5") <= p["rw"]:
        yrs = alt.split(" ", 1)[1]
        c.text(yrs, right, wy, font = "4x5", color = color.dim(GOLD, 80), align = "right")
        c.text(alt.split(" ", 1)[0], right - c.text_width(yrs, "4x5") - 4, wy, font = "4x5", color = DIM, align = "right")
    else:
        c.text(p["when"], right, wy, font = "4x5", color = DIM, align = "right")
