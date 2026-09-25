# NFL Record Book
#
# The league's all-time records and famous firsts, one a minute. Nothing is
# fetched: the book is baked in below, and every entry was chosen because it
# still stands going into the 2026 season (or is a dated first that can never
# be broken). Records that fell recently or sit on a knife edge are left out.
#
# DESIGN. The panel IS the record book, lying open, inset on black (nothing
# lit outside x 6..185). A leather cover in the chapter's colour frames two
# parchment pages; a dark spine runs down the middle with the paper shading
# into the fold on both sides. The LEFT page is the entry: what was counted,
# who holds it in black ink, and when in sepia - every other lap, how long
# the record has stood (STANDS 74 YRS, or NEW 2025) whenever that fits. By
# the fold a picture is pasted in on a black plate: the chapter's object at
# 2x, or for a head-to-head the other club's logo under a small VS. The
# RIGHT page is the number: a black silk bookmark ribbon hangs from the
# head of the spine carrying the holder's club logo, cut with a swallowtail,
# and beside it the record itself - big, pressed into the paper in the
# chapter's ink - over a tab with its scope (SEASON, CAREER, FIRST...). The
# only dark shapes on the paper are the ribbon, the plate, the number and
# the ink, so the eye goes logo -> number -> name.
#
# Frames: one record per minute (refresh 60), stepping through the book with
# a stride that is coprime to its length so consecutive minutes jump between
# chapters instead of reading one chapter in order. A small n/N folio in the
# left page's corner says the rotation is deliberate. The Records dropdown
# picks the whole book, one chapter, or one club (its records plus the
# famous games it lost).

# ------------------------------------------------------------------ layout
# 192 wide, and nothing lit outside x 6..185: the book is inset on black.
# Cover x 6 / 185, rows 0 and 31. Left page x 7..94 (edge line x 7), spine
# x 95..96, right page x 97..184 (edge line x 184), pages y 1..29 with the
# page stack at y 30. Left-page text x 10..89. The ribbon (40 x 24 logo +
# 1 px selvedge) hangs against the spine at x 97..138 from y 0; the number
# owns x 141..182.
BOOK_L = 6
BOOK_R = 185
LP_L = 10
LP_R = 89
RIB_X = 97
NUM_L = 141
NUM_R = 182
SPINE_X = 95

PAPER = "#DCCB9C"
EDGE = "#A38F60"
SHADE = ["#C9B787", "#AE9B6B", "#86744A"]
SPINE = "#3B2914"
INK = "#1B1208"
SEPIA = "#5C4524"
PRESS = "#B09B69"

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
    ["TEAM", "SB", "WIN MARGIN", "45", "PTS", "49ERS", "49ERS", "SB XXIV 55-10", "SF", 1990],
    ["TEAM", "SB", "COMEBACK", "25", "PTS", "PATRIOTS", "PATRIOTS", "SB LI DOWN 28-3", "NE", 2017],
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
# At most 10 x 7, so every icon fits the head row at 1x (y 2..8) and the plate at 2x. Each chapter
# has its own object - the ball for passing, a cleat for rushing, a glove for
# receiving, a helmet for defense, goalposts for special teams, the Lombardi
# trophy for team records, the closed record book itself (a gold star on
# its cover) for oddities - and some records carry their own picture in place of a word: a stopwatch for the
# longest game, a thermometer for the coldest, a turkey on Thanksgiving, a
# ring, a TV for Monday Night, a birthday cake for the oldest player.
# X takes the chapter's colour (its dark ink on paper); every other letter is fixed.
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
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k].rstrip(" -"), font) <= maxw:
            return t[:k].rstrip(" -")
    return ""

# Lit rows per face, top-aligned.
INKH = {"16x20_bold": 20, "16x20": 20, "6x16": 16, "3x7": 7, "10x16_bold": 16, "10x16": 16, "9x12_bold": 12, "9x12": 12,
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
def draw_spread(c, col):
    """The open book: chapter-coloured leather, two parchment pages shading
    into the fold, the spine down the middle and the page stack below."""
    cover = color.dim(col, 60)
    c.fill("black")
    c.rect(BOOK_L, 0, BOOK_R, 31, fill = cover)
    c.rect(BOOK_L + 1, 1, SPINE_X - 1, 29, fill = PAPER)
    c.rect(SPINE_X + 2, 1, BOOK_R - 1, 29, fill = PAPER)
    # The page block: edges of the leaves under the open ones.
    c.rect(BOOK_L + 2, 30, SPINE_X - 2, 30, fill = EDGE)
    c.rect(SPINE_X + 3, 30, BOOK_R - 2, 30, fill = EDGE)
    c.rect(BOOK_L + 1, 1, BOOK_L + 1, 29, fill = EDGE)
    c.rect(BOOK_R - 1, 1, BOOK_R - 1, 29, fill = EDGE)
    # Paper darkening into the gutter, both sides of the spine.
    for i in range(3):
        c.rect(SPINE_X - 3 + i, 1, SPINE_X - 3 + i, 29, fill = SHADE[i])
        c.rect(SPINE_X + 4 - i, 1, SPINE_X + 4 - i, 29, fill = SHADE[i])
    # The leaves curl down into the fold at the head.
    c.rect(SPINE_X - 2, 1, SPINE_X - 1, 1, fill = cover)
    c.rect(SPINE_X + 2, 1, SPINE_X + 3, 1, fill = cover)
    c.rect(SPINE_X, 0, SPINE_X + 1, 31, fill = SPINE)

def draw_ribbon(c, x, w, h, logo, edge):
    """A black silk bookmark from the top edge: selvedge in `edge`, the logo
    on it, and a swallowtail cut 4 rows deep under the logo."""
    c.rect(x, 0, x + w - 1, h - 1, fill = "black")
    c.rect(x, 0, x, h - 1, fill = edge)
    c.rect(x + w - 1, 0, x + w - 1, h - 1, fill = edge)
    mid = x + w // 2
    for i in range(4):
        y = h + i
        cut = 1 + 3 * i
        c.rect(x, y, mid - cut - 1, y, fill = "black")
        c.rect(mid + cut, y, x + w - 1, y, fill = "black")
        c.pixel(x, y, edge)
        c.pixel(x + w - 1, y, edge)
    c.image(logo, x + 1, 1)

# The hero faces draw "," "." and ":" as full-width cells ("89 , 214"), so
# they are drawn by hand as small square dots between the digit runs. Bold
# faces first; the tall condensed 6x16 is the last resort for 22,895.
HERO_FONTS = ["16x20_bold", "10x16_bold", "9x12_bold", "6x16"]
PUNCT = [",", ".", ":"]

def dot(font):
    return 3 if INKH[font] >= 20 else 2

def punct(font):
    # 6x16 has no "-" glyph either.
    return PUNCT + ["-"] if font == "6x16" else PUNCT

def hero_runs(value, font):
    runs = []
    cur = ""
    for ch in value.elems():
        if ch in punct(font):
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
    for r in hero_runs(value, font):
        w += (dot(font) * 2 if r == "-" else dot(font)) + 2 if r in punct(font) else c.text_width(r, font)
    return w

def draw_face(c, value, font, x, y, col):
    h = INKH[font]
    d = dot(font)
    for r in hero_runs(value, font):
        if r == "-":
            c.rect(x + 1, y + h // 2 - 1, x + 2 * d, y + h // 2, fill = col)
            x += 2 * d + 2
        elif r in PUNCT:
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

def draw_hero(c, value, font, x, y, col):
    """Pressed into the page: a pale copy 1 px down-right catches the light
    under the ink, like type bitten into thick paper."""
    draw_face(c, value, font, x + 1, y + 1, PRESS)
    return draw_face(c, value, font, x, y, col)

# A unit is dropped only when the title already says it (PASS YARDS 5,477).
IMPLIED = {"YDS": ["YARD", "YDS", "-YD"], "TD": ["TD"], "REC": ["RECEPTION"],
           "INT": ["INTERCEPTION"], "FG": ["FIELD GOALS"], "WINS": ["WINS"],
           "PTS": ["POINTS"], "RINGS": ["RINGS"], "GAMES": ["GAMES"], "STARTS": ["STARTS"]}

def implied(unit, title):
    for w in IMPLIED.get(unit, []):
        if w in title:
            return True
    return False

def unit_w(c, unit, font):
    if unit == "":
        return 0
    if unit.startswith("*"):
        return 4 + c.text_width(unit[1:], font)
    return c.text_width(unit, font)

def draw_unit(c, unit, x, y, col, font):
    if unit.startswith("*"):
        # A 3 x 3 degree ring: no bundled face carries the glyph.
        c.rect(x, y, x + 2, y + 2, outline = col)
        c.text(unit[1:], x + 4, y, font = font, color = col)
    else:
        c.text(unit, x, y, font = font, color = col)

def plan_number(c, value, unit, title):
    """Largest face first. Under each face the unit sits beside the number
    (5x7, then 4x5), or is dropped when the title already says it."""
    room = NUM_R - NUM_L + 1
    for hf in HERO_FONTS:
        hw = hero_w(c, value, hf)
        if hw > room:
            continue
        if unit == "":
            return {"hf": hf, "hw": hw, "uf": ""}
        for uf in ["5x7", "4x5"]:
            if hw + 2 + unit_w(c, unit, uf) <= room:
                return {"hf": hf, "hw": hw, "uf": uf}
        if implied(unit, title):
            return {"hf": hf, "hw": hw, "uf": ""}
    print("PROBE number-fallback " + value)
    hf = HERO_FONTS[len(HERO_FONTS) - 1]
    return {"hf": hf, "hw": hero_w(c, value, hf), "uf": ""}

def draw_number(c, r, ink):
    """The number centred on the right page, with the scope tab (SEASON,
    CAREER, FIRST...) under it: 23 / SEASON."""
    p = plan_number(c, r[3], r[4], r[2])
    hh = INKH[p["hf"]]
    uw = unit_w(c, r[4], p["uf"]) if p["uf"] != "" else 0
    gw = p["hw"] + (2 + uw if uw > 0 else 0)
    x = NUM_L + (NUM_R - NUM_L + 1 - gw) // 2
    y = 2 + (20 - hh) // 2
    end = draw_hero(c, r[3], p["hf"], x, y, ink)
    if uw > 0:
        draw_unit(c, r[4], end + 2, y + hh - INKH[p["uf"]], SEPIA, p["uf"])
    pw = c.text_width(r[1], "4x5") + 4
    if pw > NUM_R - NUM_L + 1:
        print("PROBE scope-wide " + r[1])
    c.badge(r[1], NUM_L + (NUM_R - NUM_L + 1 - pw) // 2, 23, color = PAPER, bg = ink, font = "4x5")


# Left page rows (ink tops): head 2, name 11 (6x8) / 12 (7 px faces), when 22
# (21 in 3x7). The plate - a black picture pasted in by the fold - is
# x 64..89, y 10..29: the other club for a head-to-head, else the chapter's
# picture at 2x.
PLATE_X = LP_R - 25
PLATE_Y = 10
HEAD_TRIES = [["5x7", True], ["4x5", True], ["5x7", False], ["4x5", False], ["3x7", True], ["3x7", False]]
NAME_Y = {"6x8": 11, "5x7b": 12, "4x5": 13}

def draw_head(c, r, ink, icon, cnt, with_icon):
    """What was counted (after the chapter's picture when the plate is not
    drawn), then the folio. The folio goes first, then the picture, before
    the title shrinks to 4x5 and then 3x7."""
    zone = LP_R - LP_L + 1
    iw = icon_w(icon) + 3
    pick = None
    for t in (HEAD_TRIES if with_icon else [["5x7", False], ["4x5", False], ["3x7", False]]):
        w = (iw if t[1] else 0) + c.text_width(r[2], t[0])
        if w <= zone:
            pick = [t[1], t[0], w]
            break
    if pick == None:
        print("PROBE head-clipped " + r[2])
        pick = [False, "3x7", zone]
    x = LP_L
    if pick[0]:
        draw_icon(c, icon, ink, x, 2)
        x += iw
    ty = 3 if pick[1] == "4x5" else 2
    c.text(clip(c, r[2], pick[1], LP_R - x + 1), x, ty, font = pick[1], color = INK)
    if pick[2] + 6 + c.text_width(cnt, "4x5") <= zone:
        c.text(cnt, LP_R, 3, font = "4x5", color = SEPIA, align = "right")

def fit_name(c, r, room):
    for t in [[r[5], "6x8"], [r[6], "6x8"], [r[5], "5x7b"], [r[6], "5x7b"], [r[6], "4x5"]]:
        if c.text_width(t[0], t[1]) <= room:
            return t
    return None

def fit_when(c, when, room):
    for f in ["4x5", "3x7"]:
        if c.text_width(when, f) <= room:
            return [when, f]
    return None

def draw_when(c, when, f, alt, show_alt, ink, room):
    """The when line, or - every other lap - how long the record has stood,
    whenever that fits the room the when line already had."""
    if show_alt and alt != "":
        lab = alt.split(" ", 1)[0]
        yrs = alt.split(" ", 1)[1]
        for af in ["4x5", "3x7"]:
            gap = 4 if af == "4x5" else 3
            if c.text_width(lab, af) + gap + c.text_width(yrs, af) <= room:
                ay = 22 if af == "4x5" else 21
                c.text(lab, LP_L, ay, font = af, color = SEPIA)
                c.text(yrs, LP_L + c.text_width(lab, af) + gap, ay, font = af, color = ink)
                return
    c.text(when, LP_L, 22 if f == "4x5" else 21, font = f, color = SEPIA)

def draw_plate(c, col, opp, icon):
    c.rect(PLATE_X, PLATE_Y, PLATE_X + 25, PLATE_Y + 19, fill = "black", outline = col)
    if opp != "":
        c.image(VS_LOGO[opp], PLATE_X + 1, PLATE_Y + 1)
    else:
        draw_icon2(c, icon, col, PLATE_X + 13 - icon_w(icon), PLATE_Y + 3)

def plan_left(c, r, ex):
    """Graphics first: the plate is tried with every holder form before any
    form is tried without it. A head-to-head tries the plate with the VS,
    then without it; when neither fits, the plain when line (which names
    the other club in words) replaces it."""
    opp = ex.get("opp", "")
    tries = []
    if opp in VS_LOGO:
        tries.append(["opp", PLATE_X - 3 - c.text_width("VS", "4x5") - 4, ex["when"]])
        tries.append(["opp", PLATE_X - 4, ex["when"]])
    else:
        tries.append(["icon", PLATE_X - 4, ex.get("when", r[7])])
    tries.append(["", LP_R, r[7]])
    for i in range(len(tries)):
        t = tries[i]
        room = t[1] - LP_L + 1
        nm = fit_name(c, r, room)
        wh = fit_when(c, t[2], room)
        if nm != None and wh != None:
            vs = t[0] == "opp" and i == 0
            if opp in VS_LOGO and t[0] == "":
                print("PROBE opp-dropped " + r[3])
            return {"plate": t[0], "vs": vs, "room": room, "name": nm, "when": wh}
    print("PROBE left-clipped " + r[6] + " / " + r[7])
    room = LP_R - LP_L + 1
    return {"plate": "", "vs": False, "room": room,
            "name": [clip(c, r[6], "4x5", room), "4x5"], "when": [clip(c, r[7], "3x7", room), "3x7"]}

def record(c, ctx):
    book = chapter_list(ctx)
    n = len(book)
    k = ctx.now.unix // 60
    idx = (k * stride(n)) % n
    r = book[idx]
    ch = CHAPTER[r[0]]
    col = ch[0]
    ink = color.dim(col, 45)
    ex = EXTRA.get(r[3] + "|" + r[2], {})
    icon = ex.get("icon", ch[1])

    draw_spread(c, col)

    # Right page: the holder's club on the bookmark, the number beside it.
    draw_ribbon(c, RIB_X, 42, 26, LOGO.get(r[8], "NFL.png"), col)
    draw_number(c, r, ink)

    # Left page: head row, then holder and when beside the plate.
    p = plan_left(c, r, ex)
    draw_head(c, r, ink, icon, str(idx + 1) + "/" + str(n), p["plate"] == "")
    if p["plate"] != "":
        draw_plate(c, col, ex.get("opp", "") if p["plate"] == "opp" else "", icon)
    if p["vs"]:
        c.text("VS", PLATE_X - 3, 18, font = "4x5", color = SEPIA, align = "right")
    c.text(p["name"][0], LP_L, NAME_Y[p["name"][1]], font = p["name"][1], color = INK)
    draw_when(c, p["when"][0], p["when"][1], stands(r, ctx.now.year), (k // n) % 2 == 1, ink, p["room"])
