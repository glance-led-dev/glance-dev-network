# Heisman Trophy History
#
# Every Heisman Trophy winner since 1935, one at a time, plus the schools
# that have won it most. Static data - no network, nothing to go down.
#
#   winner  one winner per five minutes: the year in gold (a gold star after
#           it when his team won the national title too), the position on a
#           pixel jersey in the school's colours, the school's trophy shelf
#           (his own wins lit - both of Griffin's), the name as the hero,
#           and one line of history when there is one worth telling.
#   count   the trophy case. For a school: one little trophy per win with
#           the year under each (title years sparkle and turn gold), and the
#           drought ('LAST 1987'). For a decade: its winners, logo over year.
#           For ALL WINNERS: the schools ranked by wins, four logos to a
#           frame with gold / silver / bronze medals for the top three
#           counts, then a BY POSITION frame - every winner as one coloured
#           column, 1935 to 2025, the backs' era giving way to the QBs'.
#
# DESIGN. The app's identity is the statue itself - a bronze stiff-arm,
# knee up, ball tucked, on a dark plinth, standing in a warm ceremony
# spotlight at the left edge of every page, so a viewer knows what the name
# beside it means before they read it. That lit statue is the one bold
# element; the rest stays quiet. Gold is the award's colour: the year, the
# counts, the trophies and the championship stars. The name is white on
# black. School colour lives only in the logo and the jersey. The logo sits
# between the statue and the name at its authored 40 x 24 (the trophy case
# uses the authored 24 x 18 set), never scaled at draw time. Chicago, Yale
# and Princeton no longer play at the top level and have no logo in the
# set, so they get a block monogram in the school's colour instead.
#
# Frames: refresh is 300 s and the winner shown is (unix // 300) mod the
# list, so ALL WINNERS walks the whole history every ~7.5 hours.

REFRESH = 300

# ------------------------------------------------------------------ layout
# 192 wide. Statue x 6..23, logo slot x 28..67 (40 x 24 at y 4), text zone
# x 72..185: 6 px of padding at both edges.
STATUE_X = 6
LOGO_X = 28
LOGO_Y = 4
TX = 72
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
# The statue, 18 x 28, facing left: stiff arm out, ball tucked in the far
# arm, front knee up, standing leg planted on the plinth. H highlight, B
# bronze, D shadow, S plinth, s plinth edge.
STATUE = """
..........HHH.....
.........HBBBD....
.........HBBBD....
..........BBD.....
..........BDD.....
..HHBBBBBBBBBBD...
.HD......BBBBBBD..
.........BBBBDDBD.
.........BBBBHHBD.
.........BBBBHHBD.
.........BBBBBDD..
..........BBBBD...
.........BBBBBD...
......HBBBBBBBD...
....HBBBBD..BBD...
....HBD.....BBD...
.....BD.....BBD...
.....BD.....BBD...
......BD....BBD...
......BBD...BBD...
.......DD..BBBD...
...........BBBBD..
..........HBBBBD..
.....SSSSSSSSSSSS.
.....SSSSSSSSSSSS.
....SSSSSSSSSSSSSS
....SSSSSSSSSSSSSS
....ssssssssssssss
"""
STATUE_LEG = {"H": "#FFE08A", "B": "#D9962E", "D": "#8A5A1E", "S": "#3A4356", "s": "#262C3A"}

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

# 7 x 8 medal: ribbon over a disc, for ranks 1-3 on the leaderboard.
MEDAL = """
R.....R
.R...R.
..RRR..
.MMMMM.
MMHMMMM
MHMMMMM
MMMMMMM
.MMMMM.
"""
MEDAL_COL = {1: "#FFC62F", 2: "#C8D0DC", 3: "#D0843A"}

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

# The ceremony spotlight behind the big statue: a warm cone, brighter at
# the plinth, fading toward the top.
SPOT = ["#221604", "#34230A", "#4A320E"]

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

def pick_name(c, full, maxw):
    """The biggest face first: across a room 'A. GRIFFIN' in 10x16 reads
    further than 'ARCHIE GRIFFIN' in 8x10 (which is 116 px, over the 114 px
    zone anyway). Full name, then initials + surname, then the surname."""
    f = name_forms(full)
    for o in [[0, "10x16"], [0, "9x12"], [1, "10x16"], [1, "9x12"], [2, "10x16"],
              [1, "8x10"], [2, "9x12"], [0, "6x8"], [1, "6x8"], [2, "6x8"]]:
        if tw(c, f[o[0]], o[1]) <= maxw:
            return [f[o[0]], o[1]]
    return [clip(c, f[2], "5x7", maxw), "5x7"]

# ------------------------------------------------------------ shared chrome
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

def statue(c):
    """The statue under a warm ceremony spotlight: a cone from the top of
    the panel widening to the plinth, three steps brighter toward the base,
    kept inside x 6..24 so the app edge stays clean."""
    cx = STATUE_X + 9
    for y in range(0, 25):
        h = 2 + y * 7 // 24
        c.rect(cx - h, y, cx + h, y, fill = SPOT[min(2, y // 9)])
    c.sprite(STATUE, STATUE_X, 2, legend = STATUE_LEG)

def logo_big(c, key, x, y):
    """The 40 x 24 logo in the slot at (x, y), or the monogram."""
    s = SCHOOLS.get(key, None)
    if s == None:
        return
    if s[1] != "":
        c.image(s[1], x, y)
        return
    m = MONOGRAM[key]
    c.text(m[0], x + 20, y, font = "16x24_bold", color = m[1], align = "center")

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
    """A filter with no winners: an answer, not an error."""
    c.fill("black")
    statue(c)
    c.text("NO WINNERS", 106, 8, font = "6x8", color = GOLD, align = "center")
    t = clip(c, "IN THE " + label, "4x5", 150)
    c.text(t, 106, 20, font = "4x5", color = DIM, align = "center")

# ------------------------------------------------------------- page: winner
def winner(c, ctx):
    r = pick(ctx)
    m, ws = r[0], r[1]
    if len(ws) == 0:
        empty(c, m[2])
        return
    w = ws[step(ctx) % len(ws)]
    has_note = w[4] != ""
    c.fill("black")
    statue(c)
    # With a note the logo rises to y 1..24 and the note runs as a caption
    # under it, x 28..185 (158 px): the longest, 'HALLOWEEN PUNT RETURN VS
    # OLE MISS', is 153 px and would never fit the 114 px text zone.
    logo_big(c, w[2], LOGO_X, 1 if has_note else LOGO_Y)

    # Row 1 (y 0..8): the year in gold 6x8, the position on a jersey, and
    # at the right the school's trophy shelf - one trophy per win, this one
    # lit. The logo already says the school, so the name only appears for
    # the three monogram schools, where the letter alone could be anyone.
    # A gold star after the year: his team won the national title too.
    yr = str(w[0])
    c.text(yr, TX, 0, font = "6x8", color = GOLD)
    jx = TX + c.text_width(yr, "6x8") + 4
    if w[0] in CHAMPS:
        c.sprite(STAR7, jx, 1, legend = STAR_LEG)
        jx += 11
    jend = jersey(c, w[2], w[3], jx, 0)
    # Every trophy of this player lights - Griffin's shelf lights '74 and
    # '75, the only double.
    shelf = [x for x in WINNERS if x[2] == w[2]]
    sx = TR - len(shelf) * 6 + 2
    for i in range(len(shelf)):
        c.sprite(TINY, sx + i * 6, 1, legend = TINY_ON if shelf[i][1] == w[1] else TINY_OFF)
    if SCHOOLS[w[2]][1] == "":
        room = sx - 4 - (jend + 4) + 1
        c.text(clip(c, SCHOOLS[w[2]][0], "4x5", room), sx - 4, 2, font = "4x5", color = DIM, align = "right")

    # The name is the hero: centred in y 10..24 over a note, y 10..30 alone.
    nm = pick_name(c, w[1], TW)
    band_h = 15 if has_note else 21
    y = 10 + (band_h - INKH[nm[1]]) // 2
    draw_text(c, nm[0], TX, y, nm[1], INK)
    if has_note:
        draw_text(c, clip(c, w[4], "4x5", TR - LOGO_X + 1), LOGO_X, 27, "4x5", NOTE)

# -------------------------------------------------------------- page: count
def count(c, ctx):
    r = pick(ctx)
    m, ws = r[0], r[1]
    if len(ws) == 0:
        empty(c, m[2])
        return
    c.fill("black")
    statue(c)
    if m[0] == "SCHOOL":
        trophy_case(c, m[1], ws)
    else:
        leaders(c, ctx, m, ws)

def trophy_case(c, key, ws):
    """One school: logo, 'N HEISMANS', and one trophy per win with its year."""
    logo_big(c, key, LOGO_X, LOGO_Y)
    n = len(ws)
    word = "HEISMAN" if n == 1 else "HEISMANS"
    c.text(str(n), TX, 0, font = "6x8", color = GOLD)
    wx = TX + c.text_width(str(n), "6x8") + 3
    c.text(word, wx, 1, font = "5x7", color = GOLD)
    # Right of the count: the drought ('LAST 1987') - the logo already says
    # the school. A monogram school has no logo, so it keeps its name.
    room = TR - (wx + c.text_width(word, "5x7") + 4) + 1
    if SCHOOLS[key][1] == "":
        tag = SCHOOLS[key][0]
    elif n >= 2:
        tag = "LAST " + str(ws[n - 1][0])
    else:
        tag = ""
    if tag != "":
        c.text(clip(c, tag, "4x5", room), TR, 2, font = "4x5", color = DIM, align = "right")

    # The case, one trophy per win. Up to two wins each cell is half the
    # zone and carries the full year and the surname; three to five get
    # 4-digit years ('2009' is 19 px, so cells of 21+); six to eight drop
    # to 2-digit years, because 8 x 14 px is all the 114 px zone holds.
    if n <= 2:
        cell = TW // 2
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
    cell = min(28, TW // n)
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
    # One more frame after the leaderboard: every winner by position.
    frames = (len(ranked) + 3) // 4 + 1
    f = step(ctx) % frames
    if f == frames - 1:
        by_position(c, ws)
        return
    show = ranked[f * 4:f * 4 + 4]
    # Medals go to the top three distinct counts (8 gold, 7 silver, 4
    # bronze), so Alabama's bronze shows even though its tag reads #5.
    levels = []
    for k in ranked:
        if tally[k] not in levels:
            levels.append(tally[k])

    c.text("MOST HEISMANS", 30, 0, font = "4x5", color = GOLD)
    if frames > 1:
        c.text(str(f + 1) + "/" + str(frames), TR, 0, font = "4x5", color = DIM, align = "right")

    # Cells 39 px wide from x 30: the 24 x 18 logo at y 6, the count in
    # 10x16 beside it, the rank ('#1', 'T2') under the logo. A dim rule
    # closes each cell - without it '[TEX] 2 [MIA] 2' reads as either
    # school's 2.
    for i in range(len(show)):
        k = show[i]
        cx = 30 + i * 39
        rank = 1 + len([x for x in ranked if tally[x] > tally[k]])
        tie = len([x for x in ranked if tally[x] == tally[k]]) > 1
        logo_small(c, k, cx, 6)
        c.text(str(tally[k]), cx + 26, 7, font = "10x16", color = INK)
        # The top three counts wear a medal in gold, silver or bronze.
        tag = ("T" if tie else "#") + str(rank)
        medal = levels.index(tally[k]) + 1
        if medal <= 3:
            tw_ = c.text_width(tag, "4x5")
            mx = cx + 12 - (tw_ + 9) // 2
            c.sprite(MEDAL, mx, 24, legend = {"R": "#E8203F", "M": MEDAL_COL[medal], "H": "#FFFFFF"})
            c.text(tag, mx + 9, 27, font = "4x5", color = MEDAL_COL[medal])
        else:
            c.text(tag, cx + 12, 27, font = "4x5", color = DIM, align = "center")
        if i < len(show) - 1:
            c.vline(cx + 37, 9, 29, "#2B3550")

def decade_class(c, ctx, m, ws):
    """The decade's winners in order, five to a frame (balanced: the six
    2020s winners go 3 + 3), each a 24 x 18 logo over its year."""
    frames = (len(ws) + 4) // 5
    per = (len(ws) + frames - 1) // frames
    f = step(ctx) % frames
    show = ws[f * per:f * per + per]
    c.text("THE " + m[2], 30, 0, font = "4x5", color = GOLD)
    if frames > 1:
        c.text(str(f + 1) + "/" + str(frames), TR, 0, font = "4x5", color = DIM, align = "right")
    # Cells 31 px from x 30 (5 x 31 = 155, ending at 184), centred as a group.
    cell = 31
    x0 = 30 + (155 - len(show) * cell) // 2
    for i in range(len(show)):
        cx = x0 + i * cell
        logo_small(c, show[i][2], cx + 3, 8)
        yr = str(show[i][0])
        if show[i][0] in CHAMPS:
            # Star left of a gold year: the title came too.
            yw = c.text_width(yr, "4x5")
            c.sprite(STAR5, cx + 15 - yw // 2 - 7, 27, legend = STAR_LEG)
            c.text(yr, cx + 15, 27, font = "4x5", color = GOLD, align = "center")
        else:
            c.text(yr, cx + 15, 27, font = "4x5", color = INK, align = "center")

def by_position(c, ws):
    """Every winner as one 1 px column, 1935 at the left, 2025 at the right,
    coloured by position - the backs' era, then the quarterbacks' - with
    decade ticks under it and the totals as a legend on the right."""
    c.text("BY POSITION", 30, 0, font = "4x5", color = GOLD)
    x0 = 30
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
        x = x0 + w[0] - first
        c.rect(x, y0, x, y1, fill = g[1])
    last = WINNERS[len(WINNERS) - 1][0]
    # Ticks every 20 years, labelled '40 '60 '80 '00 '20.
    for yr in range(1940, last + 1, 20):
        x = x0 + yr - first
        c.rect(x, y1 + 2, x, y1 + 3, fill = DIM)
        c.text(str(yr)[2:], x, 27, font = "4x5", color = DIM, align = "center")
    # Legend: swatch + label + total, two columns of two.
    lx = x0 + last - first + 8
    for i in range(len(POS_GROUPS)):
        g = POS_GROUPS[i]
        gx = lx + (i // 2) * 30
        gy = 9 + (i % 2) * 10
        c.rect(gx, gy, gx + 2, gy + 6, fill = g[1])
        lab = g[0] if g[0] != "END/CB" else "OTH"
        c.text(lab, gx + 5, gy + 1, font = "4x5", color = INK)
        c.text(str(tot[g[0]]), gx + 5 + c.text_width(lab, "4x5") + 2, gy, font = "5x7", color = GOLD)
