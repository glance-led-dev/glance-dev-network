# Heisman Trophy History
#
# Every Heisman Trophy winner since 1935, one at a time, plus the schools
# that have won it most. Static data - no network, nothing to go down.
#
#   winner  one winner per five minutes, as the trophy itself: the bronze
#           stiff-arm statue centred on a walnut pedestal, the winner's name
#           engraved on its brass plate; the year (a gold star beside it
#           when his team won the national title too) and the position
#           jersey in a spotlight on the left, the school logo in a
#           spotlight on the right.
#   plaque  the museum placard beside the statue, same winner: the full
#           name, the school and position, the school's trophy shelf (his
#           own wins lit - both of Griffin's) and one line of history, or
#           where the win ranks for his school ('3RD OF 7 NOTRE DAME').
#   count   the trophy case. For a school: one little statue per win with
#           the year under each (title years sparkle and turn gold), the
#           drought ('LAST 1987'), and the logo in the same right spotlight.
#           For a decade: its winners, logo over year. For ALL WINNERS: the
#           top five on a podium of walnut pedestals (gold / silver /
#           bronze plates with the count engraved), then a trophy shelf per
#           tied count (one little trophy per win under each logo), then a
#           BY POSITION frame - every winner as one coloured column.
#
# DESIGN. CENTER PEDESTAL. Page 1 is the trophy, not a row of facts: a
# 28 x 21 bronze stiff-arm statue stands dead centre on a walnut pedestal
# under its own warm spotlight, and the winner's name is engraved in dark
# letters on the pedestal's brass plate (the plate grows with the name, up
# to 92 px). Two smaller spotlights flank it like a museum case: the year in
# gold 9x12 on the left, the school logo at its authored 40 x 24 on the
# right. Symmetry is the point - nothing else on the panel is centred like
# this. Gold/bronze is the award's colour: statue, year, plate, counts,
# stars. School colour lives only in the logo and the jersey. Chicago, Yale
# and Princeton no longer play at the top level and have no logo in the
# set, so they get a block monogram in the school colour, named under it.
#
# Frames: refresh is 300 s and the winner shown is (unix // 300) mod the
# list, so ALL WINNERS walks the whole history every ~7.5 hours; the winner
# and plaque pages always show the same winner.

REFRESH = 300

# ------------------------------------------------------------------ layout
# 192 wide. Left spotlight x 6..47 (centre 27), pedestal centred on x 96
# (at most x 50..141, lip 49..142), right spotlight x 145..185 (logo
# x 145..184). 6 px of padding at both edges.
LX = 27
RX = 165
PED_C = 96
PED_MAX = 92
PED_MIN = 48
LOGO_X = 145
TX = 6
TR = 185
TW = TR - TX + 1

# ----------------------------------------------------------------- palette
GOLD = "#FFC62F"
INK = "#F4F7FF"
DIM = "#6E7A94"
NOTE = "#FFB45C"

# ----------------------------------------------------------------- winners
# [year, name, school key, position, note]. Notes are only facts that are
# part of the award's settled history; most winners have none.
WINNERS = [
    [1935, "JAY BERWANGER", "CHI", "HB", "THE FIRST WINNER"],
    [1936, "LARRY KELLEY", "YALE", "END", ""],
    [1937, "CLINT FRANK", "YALE", "HB", ""],
    [1938, "DAVEY O'BRIEN", "TCU", "QB", "TOP QB AWARD NOW BEARS HIS NAME"],
    [1939, "NILE KINNICK", "IOWA", "HB", "IOWA STADIUM IS NAMED FOR HIM"],
    [1940, "TOM HARMON", "MICH", "HB", ""],
    [1941, "BRUCE SMITH", "MINN", "HB", ""],
    [1942, "FRANK SINKWICH", "UGA", "HB", "FIRST WINNER FROM THE SEC"],
    [1943, "ANGELO BERTELLI", "ND", "QB", ""],
    [1944, "LES HORVATH", "OSU", "QB", ""],
    [1945, "DOC BLANCHARD", "ARMY", "FB", "ARMY'S MR. INSIDE"],
    [1946, "GLENN DAVIS", "ARMY", "HB", "ARMY'S MR. OUTSIDE"],
    [1947, "JOHNNY LUJACK", "ND", "QB", ""],
    [1948, "DOAK WALKER", "SMU", "HB", "TOP RB AWARD NOW BEARS HIS NAME"],
    [1949, "LEON HART", "ND", "END", "LAST LINEMAN TO WIN"],
    [1950, "VIC JANOWICZ", "OSU", "HB", ""],
    [1951, "DICK KAZMAIER", "PRIN", "HB", ""],
    [1952, "BILLY VESSELS", "OU", "HB", ""],
    [1953, "JOHNNY LATTNER", "ND", "HB", ""],
    [1954, "ALAN AMECHE", "WIS", "FB", "NICKNAMED THE HORSE"],
    [1955, "HOWARD CASSADY", "OSU", "HB", "BETTER KNOWN AS HOPALONG"],
    [1956, "PAUL HORNUNG", "ND", "QB", "ONLY WINNER FROM A LOSING TEAM"],
    [1957, "JOHN DAVID|CROW", "TAMU", "HB", "COACHED BY BEAR BRYANT"],
    [1958, "PETE DAWKINS", "ARMY", "HB", "LATER AN ARMY GENERAL"],
    [1959, "BILLY CANNON", "LSU", "HB", "HALLOWEEN PUNT RETURN VS OLE MISS"],
    [1960, "JOE BELLINO", "NAVY", "HB", ""],
    [1961, "ERNIE DAVIS", "SYR", "HB", "FIRST BLACK WINNER"],
    [1962, "TERRY BAKER", "ORST", "QB", "FIRST WINNER FROM THE WEST COAST"],
    [1963, "ROGER STAUBACH", "NAVY", "QB", ""],
    [1964, "JOHN HUARTE", "ND", "QB", ""],
    [1965, "MIKE GARRETT", "USC", "HB", "FIRST OF USC'S EIGHT"],
    [1966, "STEVE SPURRIER", "FLA", "QB", "LATER COACHED UF TO THE 1996 TITLE"],
    [1967, "GARY BEBAN", "UCLA", "QB", ""],
    [1968, "O.J. SIMPSON", "USC", "RB", ""],
    [1969, "STEVE OWENS", "OU", "RB", ""],
    [1970, "JIM PLUNKETT", "STAN", "QB", ""],
    [1971, "PAT SULLIVAN", "AUB", "QB", ""],
    [1972, "JOHNNY RODGERS", "NEB", "WR", ""],
    [1973, "JOHN CAPPELLETTI", "PSU", "RB", "DEDICATED IT TO HIS BROTHER JOEY"],
    [1974, "ARCHIE GRIFFIN", "OSU", "RB", "THE ONLY TWO-TIME WINNER"],
    [1975, "ARCHIE GRIFFIN", "OSU", "RB", "THE ONLY TWO-TIME WINNER"],
    [1976, "TONY DORSETT", "PITT", "RB", "FIRST TO 6,000 CAREER YARDS"],
    [1977, "EARL CAMPBELL", "TEX", "RB", "THE TYLER ROSE"],
    [1978, "BILLY SIMS", "OU", "RB", ""],
    [1979, "CHARLES WHITE", "USC", "RB", ""],
    [1980, "GEORGE ROGERS", "SC", "RB", ""],
    [1981, "MARCUS ALLEN", "USC", "RB", "FIRST 2,000-YARD SEASON"],
    [1982, "HERSCHEL WALKER", "UGA", "RB", ""],
    [1983, "MIKE ROZIER", "NEB", "RB", ""],
    [1984, "DOUG FLUTIE", "BC", "QB", "HAIL FLUTIE"],
    [1985, "BO JACKSON", "AUB", "RB", "ALSO A BASEBALL ALL-STAR"],
    [1986, "VINNY TESTAVERDE", "MIA", "QB", ""],
    [1987, "TIM BROWN", "ND", "WR", ""],
    [1988, "BARRY SANDERS", "OKST", "RB", "2,628 RUSHING YARDS"],
    [1989, "ANDRE WARE", "HOU", "QB", ""],
    [1990, "TY DETMER", "BYU", "QB", ""],
    [1991, "DESMOND HOWARD", "MICH", "WR", "STRUCK THE POSE VS OHIO STATE"],
    [1992, "GINO TORRETTA", "MIA", "QB", ""],
    [1993, "CHARLIE WARD", "FSU", "QB", "WENT ON TO PLAY IN THE NBA"],
    [1994, "RASHAAN SALAAM", "COLO", "RB", "2,055 RUSHING YARDS"],
    [1995, "EDDIE GEORGE", "OSU", "RB", ""],
    [1996, "DANNY WUERFFEL", "FLA", "QB", "COACHED BY 1966 WINNER SPURRIER"],
    [1997, "CHARLES WOODSON", "MICH", "CB", "FIRST DEFENSIVE STAR TO WIN"],
    [1998, "RICKY WILLIAMS", "TEX", "RB", ""],
    [1999, "RON DAYNE", "WIS", "RB", ""],
    [2000, "CHRIS WEINKE", "FSU", "QB", "OLDEST WINNER - AGE 28"],
    [2001, "ERIC CROUCH", "NEB", "QB", ""],
    [2002, "CARSON PALMER", "USC", "QB", ""],
    [2003, "JASON WHITE", "OU", "QB", ""],
    [2004, "MATT LEINART", "USC", "QB", ""],
    [2005, "REGGIE BUSH", "USC", "RB", "FORFEITED 2010 - RESTORED 2024"],
    [2006, "TROY SMITH", "OSU", "QB", ""],
    [2007, "TIM TEBOW", "FLA", "QB", "FIRST SOPHOMORE WINNER"],
    [2008, "SAM BRADFORD", "OU", "QB", ""],
    [2009, "MARK INGRAM", "ALA", "RB", "ALABAMA'S FIRST WINNER"],
    [2010, "CAM NEWTON", "AUB", "QB", "ONE SEASON AT AUBURN"],
    [2011, "ROBERT|GRIFFIN III", "BAY", "QB", "BAYLOR'S FIRST WINNER"],
    [2012, "JOHNNY MANZIEL", "TAMU", "QB", "FIRST FRESHMAN WINNER"],
    [2013, "JAMEIS WINSTON", "FSU", "QB", "SECOND STRAIGHT FRESHMAN WINNER"],
    [2014, "MARCUS MARIOTA", "ORE", "QB", "OREGON'S FIRST WINNER"],
    [2015, "DERRICK HENRY", "ALA", "RB", "2,219 RUSHING YARDS"],
    [2016, "LAMAR JACKSON", "LOU", "QB", "YOUNGEST WINNER EVER"],
    [2017, "BAKER MAYFIELD", "OU", "QB", "A FORMER WALK-ON"],
    [2018, "KYLER MURRAY", "OU", "QB", "ALSO A FIRST-ROUND MLB PICK"],
    [2019, "JOE BURROW", "LSU", "QB", "60 TOUCHDOWN PASSES"],
    [2020, "DEVONTA SMITH", "ALA", "WR", "FIRST WR TO WIN SINCE 1991"],
    [2021, "BRYCE YOUNG", "ALA", "QB", "ALABAMA'S FIRST QB WINNER"],
    [2022, "CALEB WILLIAMS", "USC", "QB", "RUNNER-UP MAX DUGGAN, TCU"],
    [2023, "JAYDEN DANIELS", "LSU", "QB", "RUNNER-UP MICHAEL PENIX JR., UW"],
    [2024, "TRAVIS HUNTER", "COLO", "WR/CB", "STARRED BOTH WAYS - WR AND CB"],
    [2025, "FERNANDO MENDOZA", "IU", "QB", "INDIANA'S FIRST WINNER - WENT 16-0"],
]

# Winners whose team also won the national title that season (heisman.com,
# "Heisman and national champion"): 18 of them. They wear a gold star.
CHAMPS = [1938, 1941, 1943, 1945, 1947, 1949, 1976, 1993, 1996, 1997, 2004,
          2009, 2010, 2013, 2015, 2019, 2020, 2025]

# Jersey colours per school: [fill, number ink]. LED-brightened versions of
# the home jersey (navy and maroon lifted so they read on black; Army's black
# jersey becomes charcoal so it doesn't vanish).
JERSEY_COL = {
    "ALA": ["#B01C34", "#FFFFFF"], "ARMY": ["#4A4A50", "#E8C66A"],
    "AUB": ["#E87722", "#000000"], "BAY": ["#1E7A4F", "#FFB81C"],
    "BC": ["#A0103A", "#E0C27A"], "BYU": ["#1B5CC0", "#FFFFFF"],
    "CHI": ["#A01830", "#FFFFFF"], "COLO": ["#CFB87C", "#000000"],
    "FLA": ["#1A4BD6", "#FF7A2E"], "FSU": ["#9A2B45", "#E0C890"],
    "HOU": ["#C8102E", "#FFFFFF"], "IOWA": ["#FFCD00", "#000000"],
    "IU": ["#B01020", "#FFFFFF"], "LOU": ["#C00018", "#FFFFFF"],
    "LSU": ["#5B2A9E", "#FDD023"], "MIA": ["#007A53", "#FF8A2E"],
    "MICH": ["#1B3F8A", "#FFCB05"], "MINN": ["#9A1B35", "#FFCC33"],
    "NAVY": ["#1B3A7A", "#D8C88A"], "ND": ["#C99700", "#000000"],
    "NEB": ["#E41C38", "#FFFFFF"], "OKST": ["#FF7300", "#000000"],
    "ORE": ["#1F7A3A", "#FEE123"], "ORST": ["#DC4405", "#FFFFFF"],
    "OSU": ["#C00000", "#FFFFFF"], "OU": ["#A8222A", "#FFF2DC"],
    "PITT": ["#1F4FC0", "#FFB81C"], "PRIN": ["#FF8F1F", "#000000"],
    "PSU": ["#1E3F80", "#FFFFFF"], "SC": ["#9A1020", "#FFFFFF"],
    "SMU": ["#CC0035", "#FFFFFF"], "STAN": ["#B01C1C", "#FFFFFF"],
    "SYR": ["#F76900", "#000000"], "TAMU": ["#7A1022", "#FFFFFF"],
    "TCU": ["#6A2BA8", "#FFFFFF"], "TEX": ["#BF5700", "#FFFFFF"],
    "UCLA": ["#2D68C4", "#F2C200"], "UGA": ["#BA0C2F", "#FFFFFF"],
    "USC": ["#A5162A", "#FFC72C"], "WIS": ["#C5050C", "#FFFFFF"],
    "YALE": ["#1F4A9A", "#FFFFFF"],
}

# key -> [dropdown / panel name, 40x24 logo, 24x18 logo]. Literal paths,
# because the lint checks every c.image argument exists. "" = no logo in the
# set; those schools draw MONOGRAM instead.
SCHOOLS = {
    "ALA": ["ALABAMA", "ALA.png", "S_ALA.png"],
    "ARMY": ["ARMY", "ARMY.png", "S_ARMY.png"],
    "AUB": ["AUBURN", "AUB.png", "S_AUB.png"],
    "BAY": ["BAYLOR", "BAY.png", "S_BAY.png"],
    "BC": ["BOSTON COLLEGE", "BC.png", "S_BC.png"],
    "BYU": ["BYU", "BYU.png", "S_BYU.png"],
    "CHI": ["CHICAGO", "", ""],
    "COLO": ["COLORADO", "COLO.png", "S_COLO.png"],
    "FLA": ["FLORIDA", "FLA.png", "S_FLA.png"],
    "FSU": ["FLORIDA STATE", "FSU.png", "S_FSU.png"],
    "HOU": ["HOUSTON", "HOU.png", "S_HOU.png"],
    "IOWA": ["IOWA", "IOWA.png", "S_IOWA.png"],
    "IU": ["INDIANA", "IU.png", "S_IU.png"],
    "LOU": ["LOUISVILLE", "LOU.png", "S_LOU.png"],
    "LSU": ["LSU", "LSU.png", "S_LSU.png"],
    "MIA": ["MIAMI", "MIA.png", "S_MIA.png"],
    "MICH": ["MICHIGAN", "MICH.png", "S_MICH.png"],
    "MINN": ["MINNESOTA", "MINN.png", "S_MINN.png"],
    "NAVY": ["NAVY", "NAVY.png", "S_NAVY.png"],
    "ND": ["NOTRE DAME", "ND.png", "S_ND.png"],
    "NEB": ["NEBRASKA", "NEB.png", "S_NEB.png"],
    "OKST": ["OKLAHOMA STATE", "OKST.png", "S_OKST.png"],
    "ORE": ["OREGON", "ORE.png", "S_ORE.png"],
    "ORST": ["OREGON STATE", "ORST.png", "S_ORST.png"],
    "OSU": ["OHIO STATE", "OSU.png", "S_OSU.png"],
    "OU": ["OKLAHOMA", "OU.png", "S_OU.png"],
    "PITT": ["PITT", "PITT.png", "S_PITT.png"],
    "PRIN": ["PRINCETON", "", ""],
    "PSU": ["PENN STATE", "PSU.png", "S_PSU.png"],
    "SC": ["SOUTH CAROLINA", "SC.png", "S_SC.png"],
    "SMU": ["SMU", "SMU.png", "S_SMU.png"],
    "STAN": ["STANFORD", "STAN.png", "S_STAN.png"],
    "SYR": ["SYRACUSE", "SYR.png", "S_SYR.png"],
    "TAMU": ["TEXAS A&M", "TAMU.png", "S_TAMU.png"],
    "TCU": ["TCU", "TCU.png", "S_TCU.png"],
    "TEX": ["TEXAS", "TEX.png", "S_TEX.png"],
    "UCLA": ["UCLA", "UCLA.png", "S_UCLA.png"],
    "UGA": ["GEORGIA", "UGA.png", "S_UGA.png"],
    "USC": ["USC", "USC.png", "S_USC.png"],
    "WIS": ["WISCONSIN", "WIS.png", "S_WIS.png"],
    "YALE": ["YALE", "", ""],
}

# Schools with no logo in the set: a block initial in the school colour.
MONOGRAM = {"CHI": ["C", "#C8323F"], "YALE": ["Y", "#3D7BFF"], "PRIN": ["P", "#FF8F1F"]}

BY_NAME = {SCHOOLS[k][0]: k for k in SCHOOLS}
DECADES = ["1930S", "1940S", "1950S", "1960S", "1970S", "1980S", "1990S", "2000S", "2010S", "2020S"]


# --------------------------------------------------------------- pixel art
# The statue, 28 x 21, facing left: stiff arm straight out with the palm
# up, ball tucked in the far arm, front knee up and shin hanging, the
# standing leg planted on its bronze base plate. H highlight, B bronze,
# D shadow, P base plate.
STATUE = """
...............HHHH.........
..............HBBBBD........
.............DHBBBBD........
.HH...........HBBBBD........
.HBD...........BBBD.........
.HBBHHHHHHHHBBBBBBBD........
..BBBBBBBBBBBBBBBBBBBD......
..DD.........BBBBBBHHBD.....
.............BBBBBBHHHBD....
.............BBBBBBHHHBD....
..............BBBBBBDDD.....
..............BBBBBBBD......
.............HBBBBBBBBD.....
........HHBBBBBBBB.BBBBD....
......HBBBBBBBBD....BBBD....
.....HBBBDDD........BBBD....
.....HBBD...........BBBD....
......BBBD..........BBBD....
.......BBBD........HBBBD....
........DDD.......HBBBBBD...
..........PPPPPPPPPPPPPPPPP.
"""
STATUE_LEG = {"H": "#FFE08A", "B": "#D9962E", "D": "#8A5A1E", "P": "#6A4418"}
STATUE_W = 28


# 9 x 12 statue for the trophy case - the big one in miniature.
MINI = """
.....HH..
....HBBD.
.....BD..
HBBBBBBD.
.....BBBD
.....BBD.
...HBBBD.
..HBD.BD.
..BD..BD.
.....BBD.
..SSSSSSS
..SSSSSSS
"""
MINI_LEG = {"H": "#FFE08A", "B": "#D9962E", "D": "#8A5A1E", "S": "#5A6478"}

# 5 x 7 trophy for the winner page's tally: the school's wins in a row,
# this one lit, the others dimmed.
TINY = """
.HH..
HBBD.
.BD..
BBBBD
..BD.
.BBD.
SSSSS
"""
TINY_ON = {"H": "#FFE08A", "B": "#FFC62F", "D": "#B07A1E", "S": "#8A94A8"}
TINY_OFF = {"H": "#7A5E2A", "B": "#6A4E1E", "D": "#3E2E12", "S": "#3A4356"}

# Stars for a same-season national title: 7 x 7 beside the winner's year,
# 5 x 5 beside a year in the decade class, 3 x 3 sparkle over a trophy in
# the case (where a cell can be 14 px).
STAR7 = """
...S...
..SSS..
SSSSSSS
.SSSSS.
..SSS..
.SS.SS.
.S...S.
"""
STAR5 = """
..S..
.SSS.
SSSSS
.SSS.
.S.S.
"""
STAR3 = """
.S.
SSS
.S.
"""
STAR_LEG = {"S": "#FFC62F"}

# BY POSITION: every winner as one column, 1935 -> 2025. Categorical order
# fixed: QB gold (the award's colour, and the modern era's), backs sky blue,
# receivers pink, linemen / defense grey.
POS_GROUPS = [
    ["QB", "#FFC62F", ["QB"]],
    ["RB", "#78DCFF", ["RB", "HB", "FB"]],
    ["WR", "#FF5FA8", ["WR", "WR/CB"]],
    ["END/CB", "#A8B2C8", ["END", "CB"]],
]


# Spotlights. A cone is drawn row by row, dim at the top and warmer toward
# the floor; the side pools end in a flat 3-row ellipse of light.
SPOT = ["#120B02", "#1A1104", "#241806"]
POOL = ["#3A280C", "#5A3E14", "#3A280C"]

# The pedestal: walnut block, bronze lip, brass nameplate with the name
# engraved dark into it.
WALNUT = "#3A2412"
WALNUT_HI = "#5E3C1E"
LIP = "#B07A2E"
BRASS = "#E0B04A"
ENGRAVE = "#1A0E02"

# --------------------------------------------------------------- selection
def mode(ctx):
    """[kind, value, label]: ALL, a decade, or a school key."""
    v = str(ctx.inputs.get("show", "ALL WINNERS")).strip().upper()
    if v in DECADES:
        return ["DECADE", v, v]
    if v in BY_NAME:
        return ["SCHOOL", BY_NAME[v], v]
    return ["ALL", "", "ALL WINNERS"]

def pick(ctx):
    m = mode(ctx)
    out = []
    for w in WINNERS:
        if m[0] == "DECADE" and str(w[0] // 10 * 10) + "S" != m[1]:
            continue
        if m[0] == "SCHOOL" and w[2] != m[1]:
            continue
        out.append(w)
    return [m, out]

def step(ctx):
    return ctx.now.unix // REFRESH

# ------------------------------------------------------------- text tools
# Lit rows per face, top-aligned.
INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}

# The big faces give '.' a full cell and a space another, so 'F. MENDOZA'
# drew in 10x16 with a 13 px hole after the F. In these faces every dot is
# hand-set: a 2 x 2 square on the baseline, 1 px after the letter, then
# 1 px before the next letter or a 5 px gap where a space followed
# ('J.D. CROW'), the way fantasy-injury-report sets its names.
TIGHT = ["10x16", "9x12", "8x10", "6x8"]

def seg_w(c, s, font):
    """Width of s (no apostrophes), with tight dots in the big faces."""
    if font not in TIGHT or s.find(".") < 0:
        return c.text_width(s, font) if s != "" else 0
    pieces = s.split(".")
    w = 0
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            w += 3 + (5 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        w += c.text_width(t, font) if t != "" else 0
    return w - (1 if s.endswith(".") else 0)

def seg_draw(c, s, x, y, font, color):
    if font not in TIGHT or s.find(".") < 0:
        if s != "":
            c.text(s, x, y, font = font, color = color)
        return
    base = y + INKH[font] - 1
    pieces = s.split(".")
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            c.rect(x + 1, base - 1, x + 2, base, fill = color)
            x += 3 + (5 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        if t != "":
            c.text(t, x, y, font = font, color = color)
            x += c.text_width(t, font)

def tw(c, s, font):
    """Width of s, counting an apostrophe as 3 px: no face has the glyph,
    so draw_text puts a 1 x 2 tick in a 3 px slot instead."""
    parts = s.split("'")
    w = 0
    for i in range(len(parts)):
        w += seg_w(c, parts[i], font)
        if i > 0:
            w += 3
    return w

def draw_text(c, s, x, y, font, color):
    parts = s.split("'")
    for i in range(len(parts)):
        if i > 0:
            c.rect(x + 1, y, x + 1, y + 1, fill = color)
            x += 3
        seg_draw(c, parts[i], x, y, font, color)
        x += seg_w(c, parts[i], font)

def clip(c, s, font, maxw):
    if tw(c, s, font) <= maxw:
        return s
    for k in range(len(s), 0, -1):
        t = s[:k].rstrip(" ,.-")
        if tw(c, t + "..", font) <= maxw:
            return t + ".."
    return ""

def name_forms(raw):
    """[full, initials + surname, surname]. The surname is the last word
    unless the data marks it with '|': 'ROBERT|GRIFFIN III' ->
    'R. GRIFFIN III', 'JOHN DAVID|CROW' -> 'J.D. CROW'."""
    if raw.find("|") >= 0:
        first, last = raw.split("|")[0], raw.split("|")[1]
    else:
        i = raw.rfind(" ")
        if i < 0:
            return [raw, raw, raw]
        first, last = raw[:i], raw[i + 1:]
    fs = [x for x in first.split(" ") if x != ""]
    ini = ".".join([x[:1] for x in fs]) + "."
    return [first + " " + last, ini + " " + last, last]


# ------------------------------------------------------------ shared chrome
def fit_name(c, full, maxw, order):
    """The first [form, font] in order that fits maxw. Forms: 0 full name,
    1 initials + surname, 2 surname. Last resort: the surname clipped."""
    f = name_forms(full)
    for o in order:
        if tw(c, f[o[0]], o[1]) <= maxw:
            return [f[o[0]], o[1]]
    last = order[len(order) - 1][1]
    return [clip(c, f[2], last, maxw), last]

def jersey(c, key, pos, x, y):
    """The position on a 9 px tall pixel jersey in the school's colours -
    sleeves, a neck notch - instead of a plain pill. Returns the last x it
    used."""
    col = JERSEY_COL.get(key, ["#34466E", INK])
    bw = c.text_width(pos, "4x5") + 5
    c.rect(x + 2, y, x + 1 + bw, y + 8, fill = col[0])
    c.rect(x, y + 1, x + 1, y + 4, fill = col[0])
    c.rect(x + 2 + bw, y + 1, x + 3 + bw, y + 4, fill = col[0])
    mid = x + 2 + bw // 2
    c.rect(mid - 1, y, mid, y, fill = "black")
    c.text(pos, x + 5, y + 3, font = "4x5", color = col[1])
    return x + 3 + bw

def jersey_w(c, pos):
    return c.text_width(pos, "4x5") + 9

def cone(c, cx, y0, y1, h0, h1):
    """A warm light cone centred on cx from y0 (half-width h0) to y1
    (half-width h1), three steps brighter toward the floor."""
    n = y1 - y0
    for y in range(y0, y1 + 1):
        k = y - y0
        h = h0 + (h1 - h0) * k // max(1, n)
        c.rect(cx - h, y, cx + h, y, fill = SPOT[min(2, k * 3 // (n + 1))])

def side_spot(c, cx):
    """A flanking spotlight: cone from the top, pool of light on the floor.
    Stays inside cx - 20 .. cx + 20."""
    cone(c, cx, 0, 27, 5, 17)
    c.rect(cx - 14, 28, cx + 14, 28, fill = POOL[0])
    c.rect(cx - 20, 29, cx + 20, 29, fill = POOL[1])
    c.rect(cx - 14, 30, cx + 14, 30, fill = POOL[2])

def pedestal(c, text, font):
    """The walnut pedestal centred on PED_C, y 21..31: a bronze lip, the
    block, and a brass plate with the text engraved in it. Width follows
    the text. Returns [x0, x1] of the block."""
    w = tw(c, text, font) if text != "" else 0
    pw = max(PED_MIN, min(PED_MAX, w + 12))
    x0 = PED_C - pw // 2
    x1 = x0 + pw - 1
    c.rect(x0 - 1, 21, x1 + 1, 21, fill = LIP)
    c.rect(x0, 22, x1, 31, fill = WALNUT)
    c.rect(x0, 22, x0, 31, fill = WALNUT_HI)
    # The plate: brass, 3 px of walnut each side, y 22..31.
    c.rect(x0 + 3, 22, x1 - 3, 31, fill = BRASS)
    if text != "":
        ty = 23 if INKH[font] >= 8 else 24
        draw_text(c, text, PED_C - w // 2, ty, font, ENGRAVE)
    return [x0, x1]

def logo_big(c, key, x, y):
    """The 40 x 24 logo at (x, y); a monogram school gets its letter in
    the school colour with the name under it."""
    s = SCHOOLS.get(key, None)
    if s == None:
        return
    if s[1] != "":
        c.image(s[1], x, y)
        return
    m = MONOGRAM[key]
    c.text(m[0], x + 20, y, font = "16x20_bold", color = m[1], align = "center")
    c.text(s[0], x + 20, y + 22, font = "4x5", color = INK, align = "center")

def logo_small(c, key, x, y):
    """The 24 x 18 logo at (x, y), or the monogram at 11x14."""
    s = SCHOOLS.get(key, None)
    if s == None:
        return
    if s[2] != "":
        c.image(s[2], x, y)
        return
    m = MONOGRAM[key]
    c.text(m[0], x + 12, y + 2, font = "11x14_bold", color = m[1], align = "center")

def empty(c, label):
    """A filter with no winners: an empty pedestal, the plate reading
    NO WINNERS - an answer, not an error."""
    c.fill("black")
    cone(c, PED_C, 0, 20, 3, 18)
    pedestal(c, "NO WINNERS", "6x8")
    t = clip(c, "IN THE " + label, "4x5", 80)
    c.text(t, PED_C, 8, font = "4x5", color = DIM, align = "center")

def current(ctx):
    """[mode, winner or None]: the winner both the winner and the plaque
    page show this refresh."""
    r = pick(ctx)
    if len(r[1]) == 0:
        return [r[0], None]
    return [r[0], r[1][step(ctx) % len(r[1])]]

# ------------------------------------------------------------- page: winner
def winner(c, ctx):
    r = current(ctx)
    w = r[1]
    if w == None:
        empty(c, r[0][2])
        return
    c.fill("black")

    # Centre: the statue under its own cone, on the pedestal. The name is
    # engraved on the plate: the full name when it fits in 6x8, else
    # initials + surname, then 5x7, then the surname alone.
    nm = fit_name(c, w[1], PED_MAX - 12, [[0, "6x8"], [1, "6x8"], [1, "5x7"], [2, "6x8"], [2, "5x7"]])
    cone(c, PED_C, 0, 20, 3, 18)
    c.sprite(STATUE, PED_C - STATUE_W // 2, 0, legend = STATUE_LEG)
    pedestal(c, nm[0], nm[1])

    # Left spotlight: the year in gold, then the title star (his team won
    # the national title too) and the position jersey, centred as a group.
    side_spot(c, LX)
    yr = str(w[0])
    c.text(yr, LX, 3, font = "9x12", color = GOLD, align = "center")
    champ = w[0] in CHAMPS
    gw = jersey_w(c, w[3]) + (10 if champ else 0)
    gx = LX - gw // 2
    if champ:
        c.sprite(STAR7, gx, 18, legend = STAR_LEG)
        gx += 10
    jersey(c, w[2], w[3], gx, 17)

    # Right spotlight: the logo at its authored 40 x 24.
    side_spot(c, RX)
    logo_big(c, w[2], LOGO_X, 2)

# ------------------------------------------------------------- page: plaque
# A brass-framed placard, x 6..185: full name + year, school + jersey +
# the school's trophy shelf, and one line of history.
FRAME = "#8A5A1E"
PLAQUE = "#160E04"

def ordinal(n):
    if n % 100 in [11, 12, 13]:
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

def plaque(c, ctx):
    r = current(ctx)
    w = r[1]
    if w == None:
        empty(c, r[0][2])
        return
    c.fill("black")
    c.rect(TX, 0, TR, 31, fill = FRAME)
    c.rect(TX + 1, 1, TR - 1, 30, fill = PLAQUE)
    L = TX + 5
    R = TR - 5

    # Row 1: year (and title star) at the right, the name filling the rest.
    yr = str(w[0])
    c.text(yr, R, 4, font = "6x8", color = GOLD, align = "right")
    yx = R - c.text_width(yr, "6x8")
    if w[0] in CHAMPS:
        c.sprite(STAR7, yx - 10, 4, legend = STAR_LEG)
        yx -= 10
    nm = fit_name(c, w[1], yx - 5 - L, [[0, "8x10"], [0, "6x8"], [1, "8x10"], [1, "6x8"], [2, "6x8"]])
    draw_text(c, nm[0], L, 3 if nm[1] == "8x10" else 4, nm[1], INK)

    # Row 2: school name, the position jersey, and at the right the
    # school's trophy shelf - every win of this player lit (Griffin's two).
    shelf = [x for x in WINNERS if x[2] == w[2]]
    sx = R - len(shelf) * 6 + 2
    for i in range(len(shelf)):
        c.sprite(TINY, sx + i * 6, 15, legend = TINY_ON if shelf[i][1] == w[1] else TINY_OFF)
    school = SCHOOLS[w[2]][0]
    jw = jersey_w(c, w[3])
    sn = clip(c, school, "5x7", sx - 4 - jw - 4 - L)
    draw_text(c, sn, L, 15, "5x7", GOLD)
    jersey(c, w[2], w[3], L + tw(c, sn, "5x7") + 4, 14)

    # Row 3: the history note, or where this win ranks for the school.
    if w[4] != "":
        draw_text(c, clip(c, w[4], "4x5", R - L + 1), L, 25, "4x5", NOTE)
    else:
        k = len([x for x in shelf if x[0] <= w[0]])
        n = len(shelf)
        t = school + "'S ONLY HEISMAN" if n == 1 else ordinal(k) + " OF " + str(n) + " " + school + " HEISMANS"
        draw_text(c, clip(c, t, "4x5", R - L + 1), L, 25, "4x5", DIM)

# -------------------------------------------------------------- page: count
def count(c, ctx):
    r = pick(ctx)
    m, ws = r[0], r[1]
    if len(ws) == 0:
        empty(c, m[2])
        return
    c.fill("black")
    if m[0] == "SCHOOL":
        trophy_case(c, m[1], ws)
    else:
        leaders(c, ctx, m, ws)

# The trophy case runs x 6..140; the logo stands in the right spotlight.
CR = 140
CW = CR - TX + 1

def trophy_case(c, key, ws):
    """One school: 'N HEISMANS', the drought, one statue per win with its
    year - and the logo in the same right-hand spotlight as page 1."""
    side_spot(c, RX)
    logo_big(c, key, LOGO_X, 2)
    n = len(ws)
    word = "HEISMAN" if n == 1 else "HEISMANS"
    c.text(str(n), TX, 0, font = "6x8", color = GOLD)
    wx = TX + c.text_width(str(n), "6x8") + 3
    c.text(word, wx, 1, font = "5x7", color = GOLD)
    # The drought ('LAST 1987') - the logo already says the school.
    if n >= 2:
        room = CR - (wx + c.text_width(word, "5x7") + 4) + 1
        c.text(clip(c, "LAST " + str(ws[n - 1][0]), "4x5", room), CR, 2, font = "4x5", color = DIM, align = "right")

    # The case, one statue per win. Up to two wins each cell is half the
    # case and carries the full year and the surname; three to five get
    # 4-digit years ('2009' is 19 px, so cells of 21+); six to eight get
    # 2-digit years in cells of 16.
    if n <= 2:
        cell = CW // 2
        for i in range(n):
            cx = TX + i * cell
            c.sprite(MINI, cx, 12, legend = MINI_LEG)
            c.text(str(ws[i][0]), cx + 12, 12, font = "4x5", color = GOLD)
            if ws[i][0] in CHAMPS:
                c.sprite(STAR5, cx + 13 + c.text_width(str(ws[i][0]), "4x5"), 12, legend = STAR_LEG)
            last = name_forms(ws[i][1])[2]
            f = fit(c, last, ["5x7", "4x5", "picopixel"], cell - 14)
            draw_text(c, f[1], cx + 12, 19, f[0], INK)
        return
    cell = min(28, CW // n)
    for i in range(n):
        cx = TX + i * cell
        mx = cx + (cell - 9) // 2
        c.sprite(MINI, mx, 10, legend = MINI_LEG)
        yy = str(ws[i][0]) if cell >= 21 else str(ws[i][0])[2:]
        champ = ws[i][0] in CHAMPS
        # A title year: a sparkle in the empty corner over the stiff arm,
        # and the year in gold.
        if champ:
            c.sprite(STAR3, mx, 9, legend = STAR_LEG)
        c.text(yy, cx + cell // 2, 25, font = "4x5", color = GOLD if champ else INK, align = "center")

def fit(c, text, fonts, maxw):
    for f in fonts:
        if tw(c, text, f) <= maxw:
            return [f, text]
    return [fonts[len(fonts) - 1], clip(c, text, fonts[len(fonts) - 1], maxw)]

def leaders(c, ctx, m, ws):
    """ALL WINNERS: the schools with two or more wins, ranked, four to a
    frame. A decade: its winners in order, logo over year - a decade's
    leaderboard is mostly a row of 1s, so the class photo says more."""
    if m[0] == "DECADE":
        decade_class(c, ctx, m, ws)
        return
    tally = {}
    order = []
    for w in ws:
        if w[2] not in tally:
            tally[w[2]] = 0
            order.append(w[2])
        tally[w[2]] += 1
    # Most wins first; ties keep the order of each school's first win.
    ranked = [k for k in sorted(order, key = lambda k: -tally[k]) if tally[k] >= 2]
    # Frames: the podium (the top five on metal pedestals), then one
    # trophy shelf per remaining count (at most four schools a shelf, split
    # evenly), then every winner by position.
    top = ranked[:5]
    shelves = []
    rest = ranked[5:]
    counts = []
    for k in rest:
        if tally[k] not in counts:
            counts.append(tally[k])
    for n in counts:
        grp = [k for k in rest if tally[k] == n]
        parts = (len(grp) + 3) // 4
        per = (len(grp) + parts - 1) // parts
        for i in range(0, len(grp), per):
            shelves.append([n, grp[i:i + per]])
    frames = 1 + len(shelves) + 1
    f = step(ctx) % frames
    if f == 0:
        podium(c, top, tally)
    elif f == frames - 1:
        by_position(c, ws)
    else:
        shelf(c, shelves[f - 1][0], shelves[f - 1][1])

# The podium. Metal plates by distinct count: gold, silver, bronze; below
# that the plain brass of page 1.
PLATE = ["#FFC62F", "#C8D0DC", "#D0843A"]
PLATE_HI = ["#FFE08A", "#EEF2F8", "#F0A860"]

def podium(c, top, tally):
    """The top five on walnut pedestals like page 1's: the leader in the
    middle on the tallest, the rest fanned out 2-1-3 style (4 far left,
    5 far right), each pedestal's height and plate metal set by the count
    engraved on it."""
    levels = []
    for k in top:
        if tally[k] not in levels:
            levels.append(tally[k])
    # Slot order across the panel for ranks 1..5.
    slots = [2, 1, 3, 0, 4]
    cell = 36
    x0 = PED_C - cell * 5 // 2
    for i in range(len(top)):
        k = top[i]
        n = tally[k]
        cx = x0 + slots[i] * cell + cell // 2
        # Lip row: 18 for the leader's count, 2 px lower per win behind,
        # never below 22 so the plate keeps room for its 6x8 numeral.
        lip = min(22, 18 + (tally[top[0]] - n) * 2)
        logo_small(c, k, cx - 12, lip - 18)
        # Pedestal: bronze lip, walnut block, metal plate, count engraved.
        c.rect(cx - 15, lip, cx + 14, lip, fill = LIP)
        c.rect(cx - 14, lip + 1, cx + 13, 31, fill = WALNUT)
        c.rect(cx - 14, lip + 1, cx - 14, 31, fill = WALNUT_HI)
        lv = levels.index(n)
        metal = PLATE[lv] if lv < 3 else BRASS
        c.rect(cx - 9, lip + 1, cx + 8, 31, fill = metal)
        c.rect(cx - 9, lip + 1, cx + 8, lip + 1, fill = PLATE_HI[lv] if lv < 3 else "#F0C868")
        c.text(str(n), cx, lip + 2 + (31 - lip - 9) // 2 - (1 if lip >= 22 else 0), font = "6x8", color = ENGRAVE, align = "center")

def shelf(c, n, keys):
    """A trophy-case shelf for every school tied on n wins: the count big
    and gold at the left, each logo standing on a long walnut shelf under
    with one little gold trophy per win on the shelf's
    front edge."""
    # Left: the count and what it counts.
    c.text(str(n), 26, 3, font = "10x16", color = GOLD, align = "center")
    c.text("HEISMANS", 26, 21, font = "4x5", color = GOLD, align = "center")
    c.text("EACH", 26, 27, font = "4x5", color = DIM, align = "center")
    # The shelf, x 50..186: lip at 20, walnut 21..31.
    sx0, sx1 = 50, TR
    cell = (sx1 - sx0 + 1) // len(keys)
    c.rect(sx0 - 1, 20, sx1 + 1, 20, fill = LIP)
    c.rect(sx0, 21, sx1, 31, fill = WALNUT)
    c.rect(sx0, 21, sx1, 21, fill = WALNUT_HI)
    for i in range(len(keys)):
        cx = sx0 + i * cell + cell // 2
        logo_small(c, keys[i], cx - 12, 2)
        # One trophy per win, centred under the logo.
        tx = cx - (n * 6 - 1) // 2
        for j in range(n):
            c.sprite(TINY, tx + j * 6, 23, legend = TINY_ON)

def decade_class(c, ctx, m, ws):
    """The decade's winners in order, five to a frame (balanced: the six
    2020s winners go 3 + 3), each a 24 x 18 logo over its year."""
    frames = (len(ws) + 4) // 5
    per = (len(ws) + frames - 1) // frames
    f = step(ctx) % frames
    show = ws[f * per:f * per + per]
    c.text("THE " + m[2], TX, 0, font = "4x5", color = GOLD)
    if frames > 1:
        c.text(str(f + 1) + "/" + str(frames), TR, 0, font = "4x5", color = DIM, align = "right")
    # Cells 34 px (5 x 34 = 170), centred as a group on the panel.
    cell = 34
    x0 = 96 - len(show) * cell // 2
    for i in range(len(show)):
        cx = x0 + i * cell
        logo_small(c, show[i][2], cx + 5, 8)
        yr = str(show[i][0])
        if show[i][0] in CHAMPS:
            # Star left of a gold year: the title came too.
            yw = c.text_width(yr, "4x5")
            c.sprite(STAR5, cx + 17 - yw // 2 - 7, 27, legend = STAR_LEG)
            c.text(yr, cx + 17, 27, font = "4x5", color = GOLD, align = "center")
        else:
            c.text(yr, cx + 17, 27, font = "4x5", color = INK, align = "center")

def by_position(c, ws):
    """Every winner as one column, 1935 at the left, 2025 at the right,
    coloured by position - the backs' era, then the quarterbacks' - with
    ticks every 20 years under it and the totals as a legend on the right."""
    x0 = TX + 2
    c.text("BY POSITION", TX, 0, font = "4x5", color = GOLD)
    y0, y1 = 8, 22
    grp = {}
    for g in POS_GROUPS:
        for p in g[2]:
            grp[p] = g
    tot = {g[0]: 0 for g in POS_GROUPS}
    first = WINNERS[0][0]
    for w in ws:
        g = grp.get(w[3], POS_GROUPS[3])
        tot[g[0]] += 1
        x = x0 + (w[0] - first) * 6 // 5
        c.rect(x, y0, x, y1, fill = g[1])
    last = WINNERS[len(WINNERS) - 1][0]
    # Ticks every 20 years, labelled '40 '60 '80 '00 '20.
    for yr in range(1940, last + 1, 20):
        x = x0 + (yr - first) * 6 // 5
        c.rect(x, y1 + 2, x, y1 + 3, fill = DIM)
        c.text(str(yr)[2:], x, 27, font = "4x5", color = DIM, align = "center")
    # Legend: swatch + label + total, two columns of two.
    lx = x0 + (last - first) * 6 // 5 + 8
    for i in range(len(POS_GROUPS)):
        g = POS_GROUPS[i]
        gx = lx + (i // 2) * 30
        gy = 9 + (i % 2) * 10
        c.rect(gx, gy, gx + 2, gy + 6, fill = g[1])
        lab = g[0] if g[0] != "END/CB" else "OTH"
        c.text(lab, gx + 5, gy + 1, font = "4x5", color = INK)
        c.text(str(tot[g[0]]), gx + 5 + c.text_width(lab, "4x5") + 2, gy, font = "5x7", color = GOLD)
