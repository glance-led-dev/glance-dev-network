# Super Bowl History
#
# Every Super Bowl, I through LX, every franchise's trophy case, the MVP
# leaders and the countdown to the next game. The data is baked in:
# nothing is fetched, so the panel never has an offline screen to show.
#
#   game     One Super Bowl at a time: the champion's logo on the left with
#            confetti in its own colours, the runner-up's on the right, the
#            final score split by a pixel-art Lombardi Trophy. Under it, one
#            line a minute: the MVP, then the date and host city (plus the
#            club's old name - OAKLAND RAIDERS, BALTIMORE COLTS), then a
#            one-line story for the famous ones (WIDE RIGHT, 28-3, 18-0).
#            On a game's anniversary that game is pinned all day and says
#            ON THIS DAY IN 1967.
#   rings    One franchise's trophy case: a Lombardi for every Super Bowl it
#            reached, silver for a win and a shadow for a loss, standing on
#            a walnut shelf with each year on the plaque below, gold for a
#            title. Right of the case: TITLES, the count, and OF n trips.
#            Every other minute a club with a claim to fame shows it in
#            amber in place of its name (4 STRAIGHT SUPER BOWLS).
#   legends  The countdown to Super Bowl LXI (days to go, date, SoFi's
#            city) alternating with the MVP leaders, each MVP award drawn
#            as a medal - Brady's five in a row. A picked club sees its own
#            MVPs under its logo, with medal ribbons in its colours.
#
# DESIGN. The Lombardi Trophy is the app's signature and its label: a
# 9 x 20 silver cup, as tall as the scores, drawn where the eye lands -
# between the two scores, on the countdown, and as the 7 x 15 trophies of
# the shelf. Each page spends its boldness on one thing: the game page on
# the gold winning score against a slate losing one (who won reads from
# across the room before a word is read); the rings page on the trophy case
# - silver cups and grey shadows on a wooden shelf, gold years under the
# wins, so a 0-4 club's four grey cups say "so close" without a word; the
# legends page on the big day count, or on rows of medals. Pictures stand
# in for labels on the bottom line: a medal for the MVP, a calendar for the
# date, a map pin for the host city, a star for the story. Colour has one
# job each: gold = a title or the winner, slate = the runner-up, amber = an
# anniversary or a record, club colours only in the confetti and ribbons.
# Logos are the 40 x 24 club art, drawn at their own size, never scaled.
#
# Rotation: refresh is 60 s and each minute shows the next screen. The game
# page walks through (game, line) pairs, so every Super Bowl gets two or
# three consecutive minutes. Historic franchises use today's club logo
# (Baltimore Colts -> Colts, Oakland/LA Raiders -> Raiders, St. Louis Rams
# -> Rams, San Diego Chargers -> Chargers). Dates are the day of the game;
# "today" is taken on US Eastern standard time (UTC-5), where the games are
# scheduled.

# ------------------------------------------------------------------ layout
# 192 wide. Logos 40 x 24 at x 6..45 (winner) and 146..185 (runner-up), y
# 2..25. Center band x 50..141 carries the title (y 0..4) and the scores
# (y 6..25). The bottom line y 27..31 runs the full safe width, x 6..185,
# because the logos end at y 25.
L_X = 6
R_X = 146
LOGO_Y = 2
MID = 96          # trophy centre / centre of the panel
EDGE_L = 6
EDGE_R = 185

# ----------------------------------------------------------------- palette
GOLD = "#FFC83D"      # a title, the winning score
SLATE = "#7C8699"     # the runner-up
INK = "#F4F7FF"       # names
DIM = "#6E7A94"       # labels
HIST = "#FFB45C"      # amber: an anniversary, an old club name, a record
WOOD = "#A0692F"      # the shelf plank
WOOD_D = "#5C3A18"    # its shadow edge
PLATE = "#343C4C"     # a runner-up year's plate
PLATE_INK = "#A3ACBD" # and its digits

# Two club colours each, brightened where the real one is a navy or black
# that vanishes on an LED (Patriots navy -> silver, Raiders black -> white).
# Used only for the champion's confetti and the MVP medal ribbons.
CLUB_COL = {
    "ARI": ["#E0233E", "#FFFFFF"], "ATL": ["#E0233E", "#C9D1DC"], "BAL": ["#8A5CE6", "#D4AF37"],
    "BUF": ["#2F7BEF", "#E0233E"], "CAR": ["#0095DA", "#C9D1DC"], "CHI": ["#F26A1F", "#4A6CC0"],
    "CIN": ["#FB4F14", "#FFFFFF"], "CLE": ["#FF6A1F", "#A0692F"], "DAL": ["#3F7BE0", "#C9D1DC"],
    "DEN": ["#FB4F14", "#4A74C8"], "DET": ["#1A8FDB", "#C9D1DC"], "GB": ["#3CA04A", "#FFB612"],
    "HOU": ["#E0233E", "#4A6CC0"], "IND": ["#2F6FD0", "#FFFFFF"], "JAX": ["#1BA8B8", "#D7A22A"],
    "KC": ["#E31837", "#FFB81C"], "LV": ["#C9D1DC", "#FFFFFF"], "LAC": ["#1A9BE0", "#FFC20E"],
    "LAR": ["#2F6FE8", "#FFD100"], "MIA": ["#00B3BC", "#FC6A1E"], "MIN": ["#8A5CE6", "#FFC62F"],
    "NE": ["#E0233E", "#C9D1DC"], "NO": ["#D3BC8D", "#FFFFFF"], "NYG": ["#2F63D8", "#E0233E"],
    "NYJ": ["#2EAE63", "#FFFFFF"], "PHI": ["#1FA08E", "#C9D1DC"], "PIT": ["#FFB612", "#FFFFFF"],
    "SF": ["#E0233E", "#C8A96A"], "SEA": ["#69BE28", "#4A7FD8"], "TB": ["#E0233E", "#B0A89E"],
    "TEN": ["#4B9BE8", "#E0233E"], "WSH": ["#C8364D", "#FFB612"],
}

# ----------------------------------------------------------------- logos
# Literal paths, one per club (the linter needs literal asset names).
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

# Dropdown label -> abbreviation.
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
NAME = {TEAMS[k]: k for k in TEAMS}

# ------------------------------------------------------------------- games
# [numeral, date played (MON D YYYY), winner, pts, loser, pts, MVP, host city, overtime,
#  winner's name then (if relocated), loser's name then]
GAMES = [
    ["I", "JAN 15 1967", "GB", 35, "KC", 10, "BART STARR", "LOS ANGELES", False, "", ""],
    ["II", "JAN 14 1968", "GB", 33, "LV", 14, "BART STARR", "MIAMI", False, "", "OAKLAND RAIDERS"],
    ["III", "JAN 12 1969", "NYJ", 16, "IND", 7, "JOE NAMATH", "MIAMI", False, "", "BALTIMORE COLTS"],
    ["IV", "JAN 11 1970", "KC", 23, "MIN", 7, "LEN DAWSON", "NEW ORLEANS", False, "", ""],
    ["V", "JAN 17 1971", "IND", 16, "DAL", 13, "CHUCK HOWLEY", "MIAMI", False, "BALTIMORE COLTS", ""],
    ["VI", "JAN 16 1972", "DAL", 24, "MIA", 3, "ROGER STAUBACH", "NEW ORLEANS", False, "", ""],
    ["VII", "JAN 14 1973", "MIA", 14, "WSH", 7, "JAKE SCOTT", "LOS ANGELES", False, "", ""],
    ["VIII", "JAN 13 1974", "MIA", 24, "MIN", 7, "LARRY CSONKA", "HOUSTON", False, "", ""],
    ["IX", "JAN 12 1975", "PIT", 16, "MIN", 6, "FRANCO HARRIS", "NEW ORLEANS", False, "", ""],
    ["X", "JAN 18 1976", "PIT", 21, "DAL", 17, "LYNN SWANN", "MIAMI", False, "", ""],
    ["XI", "JAN 9 1977", "LV", 32, "MIN", 14, "FRED BILETNIKOFF", "PASADENA", False, "OAKLAND RAIDERS", ""],
    ["XII", "JAN 15 1978", "DAL", 27, "DEN", 10, "RANDY WHITE & HARVEY MARTIN", "NEW ORLEANS", False, "", ""],
    ["XIII", "JAN 21 1979", "PIT", 35, "DAL", 31, "TERRY BRADSHAW", "MIAMI", False, "", ""],
    ["XIV", "JAN 20 1980", "PIT", 31, "LAR", 19, "TERRY BRADSHAW", "PASADENA", False, "", ""],
    ["XV", "JAN 25 1981", "LV", 27, "PHI", 10, "JIM PLUNKETT", "NEW ORLEANS", False, "OAKLAND RAIDERS", ""],
    ["XVI", "JAN 24 1982", "SF", 26, "CIN", 21, "JOE MONTANA", "PONTIAC, MICH.", False, "", ""],
    ["XVII", "JAN 30 1983", "WSH", 27, "MIA", 17, "JOHN RIGGINS", "PASADENA", False, "", ""],
    ["XVIII", "JAN 22 1984", "LV", 38, "WSH", 9, "MARCUS ALLEN", "TAMPA", False, "LOS ANGELES RAIDERS", ""],
    ["XIX", "JAN 20 1985", "SF", 38, "MIA", 16, "JOE MONTANA", "STANFORD, CALIF.", False, "", ""],
    ["XX", "JAN 26 1986", "CHI", 46, "NE", 10, "RICHARD DENT", "NEW ORLEANS", False, "", ""],
    ["XXI", "JAN 25 1987", "NYG", 39, "DEN", 20, "PHIL SIMMS", "PASADENA", False, "", ""],
    ["XXII", "JAN 31 1988", "WSH", 42, "DEN", 10, "DOUG WILLIAMS", "SAN DIEGO", False, "", ""],
    ["XXIII", "JAN 22 1989", "SF", 20, "CIN", 16, "JERRY RICE", "MIAMI", False, "", ""],
    ["XXIV", "JAN 28 1990", "SF", 55, "DEN", 10, "JOE MONTANA", "NEW ORLEANS", False, "", ""],
    ["XXV", "JAN 27 1991", "NYG", 20, "BUF", 19, "OTTIS ANDERSON", "TAMPA", False, "", ""],
    ["XXVI", "JAN 26 1992", "WSH", 37, "BUF", 24, "MARK RYPIEN", "MINNEAPOLIS", False, "", ""],
    ["XXVII", "JAN 31 1993", "DAL", 52, "BUF", 17, "TROY AIKMAN", "PASADENA", False, "", ""],
    ["XXVIII", "JAN 30 1994", "DAL", 30, "BUF", 13, "EMMITT SMITH", "ATLANTA", False, "", ""],
    ["XXIX", "JAN 29 1995", "SF", 49, "LAC", 26, "STEVE YOUNG", "MIAMI", False, "", "SAN DIEGO CHARGERS"],
    ["XXX", "JAN 28 1996", "DAL", 27, "PIT", 17, "LARRY BROWN", "TEMPE, ARIZ.", False, "", ""],
    ["XXXI", "JAN 26 1997", "GB", 35, "NE", 21, "DESMOND HOWARD", "NEW ORLEANS", False, "", ""],
    ["XXXII", "JAN 25 1998", "DEN", 31, "GB", 24, "TERRELL DAVIS", "SAN DIEGO", False, "", ""],
    ["XXXIII", "JAN 31 1999", "DEN", 34, "ATL", 19, "JOHN ELWAY", "MIAMI", False, "", ""],
    ["XXXIV", "JAN 30 2000", "LAR", 23, "TEN", 16, "KURT WARNER", "ATLANTA", False, "ST. LOUIS RAMS", ""],
    ["XXXV", "JAN 28 2001", "BAL", 34, "NYG", 7, "RAY LEWIS", "TAMPA", False, "", ""],
    ["XXXVI", "FEB 3 2002", "NE", 20, "LAR", 17, "TOM BRADY", "NEW ORLEANS", False, "", "ST. LOUIS RAMS"],
    ["XXXVII", "JAN 26 2003", "TB", 48, "LV", 21, "DEXTER JACKSON", "SAN DIEGO", False, "", "OAKLAND RAIDERS"],
    ["XXXVIII", "FEB 1 2004", "NE", 32, "CAR", 29, "TOM BRADY", "HOUSTON", False, "", ""],
    ["XXXIX", "FEB 6 2005", "NE", 24, "PHI", 21, "DEION BRANCH", "JACKSONVILLE", False, "", ""],
    ["XL", "FEB 5 2006", "PIT", 21, "SEA", 10, "HINES WARD", "DETROIT", False, "", ""],
    ["XLI", "FEB 4 2007", "IND", 29, "CHI", 17, "PEYTON MANNING", "MIAMI GARDENS", False, "", ""],
    ["XLII", "FEB 3 2008", "NYG", 17, "NE", 14, "ELI MANNING", "GLENDALE, ARIZ.", False, "", ""],
    ["XLIII", "FEB 1 2009", "PIT", 27, "ARI", 23, "SANTONIO HOLMES", "TAMPA", False, "", ""],
    ["XLIV", "FEB 7 2010", "NO", 31, "IND", 17, "DREW BREES", "MIAMI GARDENS", False, "", ""],
    ["XLV", "FEB 6 2011", "GB", 31, "PIT", 25, "AARON RODGERS", "ARLINGTON, TEX.", False, "", ""],
    ["XLVI", "FEB 5 2012", "NYG", 21, "NE", 17, "ELI MANNING", "INDIANAPOLIS", False, "", ""],
    ["XLVII", "FEB 3 2013", "BAL", 34, "SF", 31, "JOE FLACCO", "NEW ORLEANS", False, "", ""],
    ["XLVIII", "FEB 2 2014", "SEA", 43, "DEN", 8, "MALCOLM SMITH", "EAST RUTHERFORD", False, "", ""],
    ["XLIX", "FEB 1 2015", "NE", 28, "SEA", 24, "TOM BRADY", "GLENDALE, ARIZ.", False, "", ""],
    ["50", "FEB 7 2016", "DEN", 24, "CAR", 10, "VON MILLER", "SANTA CLARA", False, "", ""],
    ["LI", "FEB 5 2017", "NE", 34, "ATL", 28, "TOM BRADY", "HOUSTON", True, "", ""],
    ["LII", "FEB 4 2018", "PHI", 41, "NE", 33, "NICK FOLES", "MINNEAPOLIS", False, "", ""],
    ["LIII", "FEB 3 2019", "NE", 13, "LAR", 3, "JULIAN EDELMAN", "ATLANTA", False, "", ""],
    ["LIV", "FEB 2 2020", "KC", 31, "SF", 20, "PATRICK MAHOMES", "MIAMI GARDENS", False, "", ""],
    ["LV", "FEB 7 2021", "TB", 31, "KC", 9, "TOM BRADY", "TAMPA", False, "", ""],
    ["LVI", "FEB 13 2022", "LAR", 23, "CIN", 20, "COOPER KUPP", "INGLEWOOD, CALIF.", False, "", ""],
    ["LVII", "FEB 12 2023", "KC", 38, "PHI", 35, "PATRICK MAHOMES", "GLENDALE, ARIZ.", False, "", ""],
    ["LVIII", "FEB 11 2024", "KC", 25, "SF", 22, "PATRICK MAHOMES", "LAS VEGAS", True, "", ""],
    ["LIX", "FEB 9 2025", "PHI", 40, "KC", 22, "JALEN HURTS", "NEW ORLEANS", False, "", ""],
    ["LX", "FEB 8 2026", "SEA", 29, "NE", 13, "KENNETH WALKER III", "SANTA CLARA", False, "", ""],
]

# The one MVP from the losing side gets a note, and counts for his club.
MVP_NOTE = {"V": "LOSING TEAM"}

# One-line stories for the famous games, the third bottom-line view. 4x5,
# at most 36 characters (the bottom line is 180 px). No apostrophes: 4x5
# has no glyph for one.
REPEAT = "BACK-TO-BACK CHAMPIONS"
STORY = {
    "I": "THE VERY FIRST SUPER BOWL",
    "II": REPEAT,
    "III": "NAMATH GUARANTEED IT",
    "VII": "PERFECT 17-0 SEASON",
    "VIII": REPEAT,
    "X": REPEAT,
    "XIV": REPEAT,
    "XXIV": "BIGGEST WIN EVER, BY 45",
    "XXV": "WIDE RIGHT, WON BY 1 POINT",
    "XXVIII": REPEAT,
    "XXXIII": REPEAT,
    "XXXIV": "LAST PLAY, 1 YARD SHORT",
    "XXXIX": REPEAT,
    "XLII": "STOPPED THE 18-0 PATRIOTS",
    "XLIX": "GOAL-LINE INTERCEPTION",
    "50": "NO ROMAN NUMERALS FOR 50",
    "LI": "1ST OT GAME, BACK FROM 28-3",
    "LII": "THE PHILLY SPECIAL",
    "LIII": "LOWEST SCORING EVER",
    "LV": "1ST TEAM TO WIN AT HOME",
    "LVIII": "2ND OT GAME, BACK-TO-BACK",
    "LX": "1ST RB MVP SINCE XXXII",
}

# A club's claim to fame, shown in amber in place of its name every other
# minute on the rings page. At most 109 px in 4x5 (21 characters).
CLAIM = {
    "NE": "MOST SUPER BOWL TRIPS",
    "PIT": "TIED FOR MOST TITLES",
    "BUF": "4 STRAIGHT SUPER BOWLS",
    "KC": "5 TRIPS IN 6 SEASONS",
    "MIN": "4 TRIPS IN 8 SEASONS",
    "GB": "WON THE FIRST TWO",
    "MIA": "PERFECT 17-0 SEASON",
    "SF": "WON ITS FIRST FIVE",
    "DAL": "3 TITLES IN 4 SEASONS",
    "DEN": "REPEAT CHAMPS 1998-99",
    "NYJ": "NAMATH GUARANTEED IT",
    "TB": "1ST TO WIN AT HOME",
    "NYG": "STOPPED 18-0 PATRIOTS",
}

# The next Super Bowl: LXI, Sunday Feb 14 2027, SoFi Stadium, Inglewood.
# After that day the countdown screen retires itself (and so does the
# latest champion's REIGNING CHAMPIONS tag) until the data is updated.
NEXT = ["LXI", 2027, 2, 14, "FEB 14 2027", "INGLEWOOD, CALIF."]

# ------------------------------------------------------------- pixel art
# 7 x 15 Lombardi Trophy: the ball upright on top, a short neck, the
# tapering three-sided stand, a base. W shine, S body, D shadow side.
TROPHY = """
..SSS..
.SWSSD.
.SWSSD.
.SWSSD.
.SWSSD.
..SSD..
...S...
...S...
..SSD..
..SSD..
..SSD..
.SSSDD.
.SSSDD.
SSSSDDD
DDDDDDD
"""
WIN_LEG = {"W": "#FFFFFF", "S": "#C9D1DC", "D": "#7F8A9C"}
LOSS_LEG = {"W": "#4A5366", "S": "#3A4252", "D": "#2A303C"}
TROPHY_W = 7

# 9 x 20 hero trophy for the game and countdown screens, as tall as the
# 16x20 digits.
TROPHY_BIG = """
...SSS...
..SWSSD..
..SWSSD..
.SWWSSSD.
.SWSSSSD.
.SWSSSSD.
..SWSSD..
..SSSSD..
...SSD...
....S....
....S....
...SSD...
...SSD...
...SSD...
..SSSDD..
..SSSDD..
..SSSDD..
.SSSSDDD.
SSSSSDDDD
DDDDDDDDD
"""
BIG_W = 9

def trophy(c, x, y, won):
    c.sprite(TROPHY, x, y, legend = WIN_LEG if won else LOSS_LEG)

# 5 x 5 line icons for the bottom row: they replace the words "MVP",
# "DATE", "HOST CITY" and "DID YOU KNOW".
MEDAL = """
R...B
.R.B.
.GGG.
GGWGG
.GGG.
"""
MEDAL_LEG = {"R": "#FF3B4E", "B": "#3D86FF", "G": GOLD, "W": "#FFF6C8"}
CAL = """
RRRRR
WWWWW
W.W.W
WWWWW
W.W.W
"""
CAL_LEG = {"R": "#FF3B4E", "W": "#C9D1DC"}
PIN = """
.PPP.
PP.PP
.PPP.
..P..
..P..
"""
PIN_LEG = {"P": "#2FE06F"}
STAR = """
..A..
.AAA.
AAAAA
.AAA.
.A.A.
"""
STAR_LEG = {"A": HIST}
ICONS = {"MEDAL": [MEDAL, MEDAL_LEG], "CAL": [CAL, CAL_LEG], "PIN": [PIN, PIN_LEG],
         "STAR": [STAR, STAR_LEG]}

# 13 x 18 hero medal for the MVP board: a two-strap ribbon (R, B - the
# club's colours when a club is picked) meeting at a clasp, a gold disc
# with a white star, shaded bottom-right.
MEDAL_BIG = """
RRR.......BBB
RRRR.....BBBB
.RRRR...BBBB.
..RRRR.BBBB..
...RRRBBBB...
....RRBBB....
....GGGGG....
..GGGGGGGGG..
.GGGGGWGGGGD.
.GGGGWWWGGGD.
GGWWWWWWWWWGD
GGGWWWWWWWGGD
GGGGWWWWWGGDD
.GGGWWGWWGGD.
.GGWWGGGWWGD.
..GGGGGGGGD..
...GGGGGDD...
.....DDD.....
"""
MEDAL_BIG_LEG = {"G": GOLD, "D": "#B8861E", "W": "#FFF6C8"}

# ------------------------------------------------------------- text tools
def fit(c, options, maxw):
    """options: [[text, font], ...] richest first; the first that fits wins,
    else the last one hard-clipped."""
    for o in options:
        if c.text_width(o[0], o[1]) <= maxw:
            return o
    last = options[len(options) - 1]
    t = last[0]
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], last[1]) <= maxw:
            return [t[:k], last[1]]
    return ["", last[1]]

# A run is [text, colour] or ["", "", icon]. Icons are 5 px wide and sit
# 3 px from the text they label; text runs are 5 px apart.
def run_w(c, r, font):
    return 5 if len(r) > 2 else c.text_width(r[0], font)

def runs_width(c, runs, font):
    w = 0
    for i in range(len(runs)):
        if i > 0:
            w += 3 if len(runs[i - 1]) > 2 else 5
        w += run_w(c, runs[i], font)
    return w

def draw_runs(c, runs, font, cx, y):
    x = cx - runs_width(c, runs, font) // 2
    for i in range(len(runs)):
        r = runs[i]
        if len(r) > 2:
            c.sprite(ICONS[r[2]][0], x, y, legend = ICONS[r[2]][1])
        else:
            c.text(r[0], x, y, font = font, color = r[1])
        x += run_w(c, r, font) + (3 if len(r) > 2 else 5)

def surname(name):
    parts = name.split(" ")
    if len(parts) >= 3 and parts[len(parts) - 1] in ["JR.", "III", "II"]:
        return parts[len(parts) - 2] + " " + parts[len(parts) - 1]
    return parts[len(parts) - 1]

def initial_last(name):
    parts = name.split(" ")
    if len(parts) < 2:
        return name
    return parts[0][:1] + ". " + surname(name)

# ------------------------------------------------------------ calendar
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def today(ctx):
    """Day number (days since 1970-01-01) on US Eastern standard time."""
    return (ctx.now.unix - 5 * 3600) // 86400

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def month_day(dn):
    """Day number -> "FEB 8", the same spelling as the GAMES dates."""
    z = dn + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return MONTHS[m - 1] + " " + str(d)

NEXT_DAY = days_from_civil(NEXT[1], NEXT[2], NEXT[3])

def md_of(g):
    return g[1][:len(g[1]) - 5]

def year_of(g):
    return g[1][len(g[1]) - 4:]

# -------------------------------------------------------------- selection
def picked(ctx):
    v = str(ctx.inputs.get("team", "ALL TEAMS")).strip().upper()
    return TEAMS.get(v, "")

def step(ctx):
    return ctx.now.unix // 60

# --------------------------------------------------------------- page: game
def mvp_runs(c, g):
    """The medal is the label: one per MVP (Super Bowl XII had two)."""
    name = g[6]
    note = MVP_NOTE.get(g[0], "")
    maxw = EDGE_R - EDGE_L + 1
    if name.find("&") >= 0:
        two = name.split(" & ")
        for f in [two, [surname(two[0]), surname(two[1])]]:
            runs = [["", "", "MEDAL"], [f[0], INK], ["", "", "MEDAL"], [f[1], INK]]
            if runs_width(c, runs, "4x5") <= maxw:
                return runs
    for f in [name, initial_last(name), surname(name)]:
        runs = [["", "", "MEDAL"], ["MVP", GOLD], [f, INK]]
        if note != "" and runs_width(c, runs + [["(" + note + ")", DIM]], "4x5") <= maxw:
            return runs + [["(" + note + ")", DIM]]
        if runs_width(c, runs, "4x5") <= maxw:
            return runs
    return [["", "", "MEDAL"], [surname(name), INK]]

def place_runs(c, g, anniv):
    when = [[("ON THIS DAY IN " + year_of(g)) if anniv else g[1], HIST if anniv else DIM]]
    if not anniv:
        when = [["", "", "CAL"]] + when
    runs = when + [["", "", "PIN"], [g[7], INK]]
    # ON THIS DAY IN 1985 + STANFORD, CALIF. is 186 px: drop the state.
    if runs_width(c, runs, "4x5") > EDGE_R - EDGE_L + 1:
        runs = when + [["", "", "PIN"], [g[7].split(",")[0], INK]]
    return runs

def then_runs(c, g):
    """A relocated club's name that day, on its own line: with the full
    date the place line has no room for it (JAN 29 1995 + MIAMI + OVER SAN
    DIEGO CHARGERS is 196 px)."""
    if g[9] != "":
        return [["WON AS THE", DIM], [g[9], HIST]]
    return [["OVER THE", DIM], [g[10], HIST]]

def story_runs(c, g):
    return [["", "", "STAR"], [fit(c, [[STORY[g[0]], "4x5"]], EDGE_R - EDGE_L - 7)[0], HIST]]

def game(c, ctx):
    c.fill("black")
    team = picked(ctx)
    mine = [i for i in range(len(GAMES)) if team == "" or GAMES[i][2] == team or GAMES[i][4] == team]
    if len(mine) == 0:
        never(c, team)
        return

    # A game's anniversary pins it for the whole (Eastern) day; several
    # games share some dates (four were played on Feb 3) and take turns.
    md = month_day(today(ctx))
    pinned = [i for i in mine if md_of(GAMES[i]) == md]
    anniv = len(pinned) > 0
    seq = []
    for i in (pinned if anniv else mine):
        # On an anniversary the date line comes first.
        views = [1, 0] if anniv else [0, 1]
        if GAMES[i][9] != "" or GAMES[i][10] != "":
            views.append(3)
        if GAMES[i][0] in STORY:
            views.append(2)
        for v in views:
            seq.append([i, v])
    s = seq[step(ctx) % len(seq)]
    g = GAMES[s[0]]

    c.image(LOGO[g[2]], L_X, LOGO_Y)
    c.image(LOGO[g[4]], R_X, LOGO_Y)
    # Confetti in the champion's colours, x 47..52 - the only black strip
    # between the logo (ends x 45) and a two-digit score (starts x 55).
    col = CLUB_COL.get(g[2], [GOLD, INK])
    spots = [[48, 3], [51, 6], [47, 9], [50, 12], [52, 15], [48, 18], [51, 21], [47, 24]]
    for k in range(len(spots)):
        c.pixel(spots[k][0], spots[k][1], GOLD if k % 3 == 2 else col[k % 2])

    # Title row; an overtime game says so in grey beside the numeral.
    title = [["SUPER BOWL " + g[0], GOLD]]
    if g[8]:
        title.append(["OT", DIM])
    draw_runs(c, title, "4x5", MID, 0)

    # Scores in 16x20 either side of the trophy; the winner's is the only
    # gold. '55' is 33 px, so a two-digit score spans x 55..87 on the left
    # and 105..137 on the right - clear of both logos (45 / 146).
    tx = MID - BIG_W // 2
    c.sprite(TROPHY_BIG, tx, 6, legend = WIN_LEG)
    c.text(str(g[3]), tx - 4, 6, font = "16x20", color = GOLD, align = "right")
    c.text(str(g[5]), tx + BIG_W + 4, 6, font = "16x20", color = SLATE)

    if s[1] == 0:
        runs = mvp_runs(c, g)
    elif s[1] == 1:
        runs = place_runs(c, g, anniv)
    elif s[1] == 3:
        runs = then_runs(c, g)
    else:
        runs = story_runs(c, g)
    draw_runs(c, runs, "4x5", MID, 27)

def never(c, team):
    """A club with no Super Bowl appearance: a fact, drawn calmly."""
    c.image(LOGO.get(team, "NFL.png"), L_X, 4)
    t = fit(c, [[NAME.get(team, ""), "5x7"], [NAME.get(team, ""), "4x5"]], EDGE_R - 52 + 1)
    c.text(t[0], 52, 4, font = t[1], color = INK)
    c.sprite(TROPHY, 52, 13, legend = LOSS_LEG)
    c.text("NO SUPER BOWL", 63, 14, font = "5x7", color = SLATE)
    c.text("APPEARANCES YET", 63, 23, font = "4x5", color = DIM)

# -------------------------------------------------------------- page: rings
# The trophy case: x 50..158, cups y 7..21 standing on a plank at y 22..23,
# a 9 x 7 plate per cup at y 24..30 carrying the two-digit year. The count
# column is x 160..185.
SHELF_L = 50
SHELF_R = 158
COL_C = 173

def record(team):
    trips = []
    for g in GAMES:
        if g[2] == team:
            trips.append([g, True])
        elif g[4] == team:
            trips.append([g, False])
    return trips

def order_all():
    """Every club, most titles first, then most trips, then name."""
    rows = []
    for abbr in NAME:
        trips = record(abbr)
        wins = len([t for t in trips if t[1]])
        rows.append([-wins, -len(trips), NAME[abbr], abbr])
    return [r[3] for r in sorted(rows)]

def claim(team, ctx):
    """The club's claim to fame; the latest champion is REIGNING CHAMPIONS
    until the next Super Bowl is played."""
    if team == GAMES[len(GAMES) - 1][2] and today(ctx) <= NEXT_DAY:
        return "REIGNING CHAMPIONS"
    return CLAIM.get(team, "")

def shelf(c, x0, x1):
    c.rect(x0, 22, x1, 22, fill = WOOD)
    c.rect(x0, 23, x1, 23, fill = WOOD_D)

def rings(c, ctx):
    c.fill("black")
    team = picked(ctx)
    if team == "":
        seq = []
        for abbr in order_all():
            seq.append([abbr, 0])
            if claim(abbr, ctx) != "":
                seq.append([abbr, 1])
        s = seq[step(ctx) % len(seq)]
    else:
        s = [team, step(ctx) % 2 if claim(team, ctx) != "" else 0]
    team = s[0]
    trips = record(team)
    wins = len([t for t in trips if t[1]])

    c.image(LOGO[team], L_X, 4)
    maxw = SHELF_R - SHELF_L + 1

    # Top row: the club, or (every other minute) its claim in amber.
    if s[1] == 1:
        c.text(fit(c, [[claim(team, ctx), "4x5"]], maxw)[0], SHELF_L, 0, font = "4x5", color = HIST)
    else:
        c.text(fit(c, [[NAME[team], "4x5"]], maxw)[0], SHELF_L, 0, font = "4x5", color = INK)

    if len(trips) == 0:
        shelf(c, SHELF_L, EDGE_R)
        trophy(c, SHELF_L, 7, False)
        c.text("NO SUPER BOWL", SHELF_L + 11, 8, font = "5x7", color = SLATE)
        c.text("APPEARANCES YET", SHELF_L + 11, 16, font = "4x5", color = DIM)
        c.text("THE WAIT GOES ON", SHELF_L, 25, font = "4x5", color = DIM)
        return

    # The case: one cup per trip, in order, centred on the plank. 10 px
    # apart leaves 3 px between plaques ('67' is 7 px, as wide as a cup;
    # at 9 px New England's years ran together as 8697020405...). A case
    # longer than 109 px (New England's 12 trips: 117 px) runs on under
    # the count column to x 166 and drops the OF n line, whose trips are
    # all on the shelf anyway; the 10x16 count starts at x 168.
    n = len(trips)
    w = n * 10 - 3
    wide = w > maxw
    right = 166 if wide else SHELF_R
    x0 = SHELF_L + (right - SHELF_L + 1 - w) // 2
    shelf(c, SHELF_L, right)
    for i in range(n):
        x = x0 + i * 10
        trophy(c, x, 7, trips[i][1])
        # A brass plate under each cup: gold with black digits for a title,
        # slate for a loss. Bare digits ran together ('91929394'); plates
        # keep each year its own tile with a 1 px gap.
        yy = year_of(trips[i][0])[2:]
        won = trips[i][1]
        c.rect(x - 1, 24, x + TROPHY_W, 30, fill = GOLD if won else PLATE)
        c.text(yy, x + (TROPHY_W - c.text_width(yy, "4x5")) // 2, 25, font = "4x5",
               color = "#000000" if won else PLATE_INK)

    # The count column: TITLES / the number / OF n (trips).
    head = "TITLE" if wins == 1 else "TITLES"
    big = str(wins)
    of = "OF " + str(n)
    hot = GOLD if wins > 0 else SLATE
    c.text(head, COL_C - c.text_width(head, "4x5") // 2, 0, font = "4x5", color = hot)
    c.text(big, COL_C - c.text_width(big, "10x16") // 2, 7, font = "10x16", color = hot)
    if not wide:
        c.text(of, COL_C - c.text_width(of, "4x5") // 2, 25, font = "4x5", color = DIM)

# ------------------------------------------------------------ page: legends
def legends(c, ctx):
    c.fill("black")
    team = picked(ctx)
    days = NEXT_DAY - today(ctx)
    screens = (["next"] if days >= 0 else []) + ["mvp"]
    if screens[step(ctx) % len(screens)] == "next":
        countdown(c, days)
    else:
        mvp_board(c, team)

def countdown(c, days):
    """SUPER BOWL LXI over the day count, the shield left, the cup right."""
    c.image(LOGO["NFL"], L_X, LOGO_Y)
    draw_runs(c, [["SUPER BOWL " + NEXT[0], GOLD]], "4x5", MID, 0)

    if days == 0:
        t = fit(c, [["TODAY", "16x20"], ["TODAY", "10x16"]], 92)
        c.text(t[0], MID - c.text_width(t[0], t[1]) // 2, 6, font = t[1], color = GOLD)
    else:
        big = str(days)
        lab = ["DAY" if days == 1 else "DAYS", "TO GO"]
        bw = c.text_width(big, "16x20")
        lw = max([c.text_width(l, "4x5") for l in lab])
        x = MID - (bw + 4 + lw) // 2
        c.text(big, x, 6, font = "16x20", color = INK)
        for i in range(2):
            c.text(lab[i], x + bw + 4, 14 + i * 6, font = "4x5", color = DIM)

    # The cup waits on the right, in a spray of gold.
    tx = R_X + 20 - BIG_W // 2
    c.sprite(TROPHY_BIG, tx, 4, legend = WIN_LEG)
    for p in [[-6, 5], [-4, 11], [-7, 17], [BIG_W + 5, 6], [BIG_W + 3, 13], [BIG_W + 6, 19]]:
        c.pixel(tx + p[0], 4 + p[1], GOLD)

    draw_runs(c, [["", "", "CAL"], [NEXT[4], DIM], ["", "", "PIN"], [NEXT[5], INK]], "4x5", MID, 27)

def mvp_tally(team):
    """[[name, awards]], most awards first, then the earliest."""
    order = []
    idx = {}
    for i in range(len(GAMES)):
        g = GAMES[i]
        club = g[4] if g[0] in MVP_NOTE else g[2]
        if team != "" and club != team:
            continue
        for who in g[6].split(" & "):
            if who in idx:
                order[idx[who]][1] += 1
            else:
                idx[who] = len(order)
                order.append([who, 1, i])
    rows = sorted([[-o[1], o[2], o[0]] for o in order])
    return [[r[2], -r[0]] for r in rows]

def mvp_board(c, team):
    """The medal left; the MVPs right, each award a medal under the name."""
    tally = mvp_tally(team)
    col = CLUB_COL.get(team, ["#FF3B4E", "#3D86FF"])
    leg = dict(MEDAL_BIG_LEG)
    leg["R"] = col[0]
    leg["B"] = col[1]
    lab = "MVPS" if len(tally) != 1 else "MVP"
    if team == "":
        # All clubs: the big medal is the hero and the label.
        c.sprite(MEDAL_BIG, 26 - 6, 1, legend = leg)
        c.text(lab, 26 - c.text_width(lab, "5x7") // 2, 22, font = "5x7", color = GOLD)
    else:
        # A club: its logo names whose MVPs these are; the ribbons below
        # wear its colours.
        c.image(LOGO[team], L_X, 1)
        c.text(lab, 26 - c.text_width(lab, "4x5") // 2, 26, font = "4x5",
               color = GOLD if len(tally) > 0 else SLATE)

    X0 = 52
    W = EDGE_R - X0 + 1
    if len(tally) == 0:
        c.text("NO SUPER BOWL MVP", X0, 7, font = "5x7", color = SLATE)
        c.text("STILL CHASING THE FIRST", X0, 18, font = "4x5", color = DIM)
        return

    # Names: the surname, or initial + surname when two share it (MANNING).
    last = {}
    for t in tally:
        sn = surname(t[0])
        last[sn] = last.get(sn, 0) + 1
    medal_leg = dict(MEDAL_LEG)
    medal_leg["R"] = col[0]
    medal_leg["B"] = col[1]

    # A leaderboard in two columns, read down then across, up to 4 rows:
    # the name, then one 5 x 5 medal per award in a column of their own.
    # The widest case, all clubs: MONTANA + Brady's five medals is 66 px
    # and E. MANNING + two is 63, so 66 + 5 + 63 = 134 fills x 52..185.
    # All clubs: the multiple winners only (six of them); a club: all its MVPs.
    items = [t for t in tally if t[1] > 1] if team == "" else tally[:8]
    rows = (len(items) + 1) // 2
    cols = [items[:rows], items[rows:]]
    GAP = 5
    geo = []
    for cl in cols:
        if len(cl) == 0:
            continue
        names = []
        for t in cl:
            nm = surname(t[0]) if last[surname(t[0])] == 1 else initial_last(t[0])
            names.append(fit(c, [[nm, "4x5"]], 54)[0])
        nw = max([c.text_width(nm, "4x5") for nm in names])
        mw = max([t[1] * 6 - 1 for t in cl])
        geo.append([cl, names, nw, nw + 3 + mw])
    # 5 px is the floor (all clubs); with room to spare the columns sit
    # up to 14 px apart so a medal never reads as the next name's.
    if len(geo) > 1:
        GAP = max(5, min(14, W - geo[0][3] - geo[1][3]))
    total = geo[0][3] + (GAP + geo[1][3] if len(geo) > 1 else 0)
    x = X0 + (W - total) // 2
    pitch = 8 if rows == 4 else 10
    top = (32 - (rows - 1) * pitch - 5) // 2
    for gcol in geo:
        for r in range(len(gcol[0])):
            y = top + r * pitch
            c.text(gcol[1][r], x, y, font = "4x5", color = INK)
            for m in range(gcol[0][r][1]):
                c.sprite(MEDAL, x + gcol[2] + 3 + m * 6, y, legend = medal_leg)
        x += gcol[3] + GAP
