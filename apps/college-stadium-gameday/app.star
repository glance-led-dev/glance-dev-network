# College Stadium Gameday
#
# The building a college football Saturday happens in: the stadium's name
# and nickname, how many it holds, when it opened, and the stories that
# make the place loud - record crowds, famous finishes, fans who arrive by
# boat, a crowd that registered on a seismograph.
#
#   stadium  Stadium centre stage: the stadium drawn across the whole
#            panel in the school's colours, its nickname lit up on the video
#            board over the far stands, the school flag flying over the
#            right-hand stands, and signs on the base: the capacity (or the
#            record crowd) and a bronze plaque with the year it opened.
#   gameday  One gameday story at a time on the video board, with an icon
#            and a pill saying what kind of story it is (NOISE, RECORD
#            CROWD, ON THE WATER, FAMOUS PLAY...) and the stadium's name.
#
# DESIGN. STADIUM CENTER STAGE. The building is the whole picture, not a
# thumbnail beside a text column: there is no logo-left column on either
# page. The 52 x 26 three-quarter-view string art is widened in the middle
# of the field to 160 x 26 (x 16..175, y 6..31) - a long mowed field with
# yard lines, end zones at both ends, the rim of stands in the school's
# colours with a scatter of crowd dots, tiered near-side rows, an arched
# base and light towers over the corners. Four builds keep their tell:
# BOWL, HORSESHOE (open at the left end, the scoreboard in the gap), DOUBLE
# (an upper deck in the second school colour under a press box) and DOME
# (a ribbed roof). Then the place itself: Neyland's checkerboard end zones,
# the hedge ring at Sanford, a moon and stars over Death Valley, snowcapped
# peaks behind Boulder, the Academy, Provo and Salt Lake, water lapping at
# the base of the stadiums fans reach by boat, and Boise's blue field.
#
#   y0  .L.......[*=*=* THE BIG HOUSE *=*=*]..|[LOGO]..L.
#       ssssssss====||=================||=====|=[FLAG]ssss
#       sZZggWGggWGggWGggWGggWGggWGggWGggWGggWGggWGggZZs
#       SSSSSSSSSS[CAP 107,601]SSS[EST 1927]SSSSSSSSSSSSS
#   y31  EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
#
# The name people call the place is the hero, in white on the stadium's own
# video board: a black face with a school-colour frame studded with marquee
# bulbs, hung on two struts over the far stands - 6x8 when it fits, 5x7,
# then two balanced 5x7 lines broken after a space or a hyphen ('VAUGHT-' /
# 'HEMINGWAY'). The school logo (the authored 24 x 18 set, never scaled)
# is on a flag over the right end of the stands. The base carries a centred
# row of signs: 'CAP 107,601' (the label in the school colour) and the bronze
# dedication plaque 'EST 1927' - dim bronze frame, a dark row either side of
# bright gold 4x5 letters. On alternate refreshes the side signs show the
# record crowd ('REC 115,109' ... 'IN 2013'); a stadium
# whose capacity we could not verify always shows its record (or its
# setting, 'ABOVE THE HUDSON').
#
# The gameday page is the close-up of that board: its side rails in the
# school colour with bulbs, a header with the story's 7 x 7 icon, category
# pill and the official name (or city) in the second school colour, and the
# story in white across x 9..182 - three lines of 5x7 at most (4x5 when a
# line runs long); every story of every school is rendered and checked.
#
# No network: the data below is baked in. ALL SCHOOLS changes school every
# 20 minutes so both pages always show the same school; a story changes on
# every refresh.

REFRESH = 120
SCHOOL_SECS = 1200

# ------------------------------------------------------------------ layout
MID = 96           # the panel's centre column
# The 52-column string art is widened in the middle to 160 columns: art
# columns 20..31 (a 12-column slice - the yard-line and dome-rib periods,
# 4 and 6, both divide it) are repeated 9 more times. It is drawn x 16..175,
# y 6..31, so the stadium fills the panel's width and the whole lower half.
SLICE_A = 20
SLICE_B = 32
SLICE_N = 9
ART_W = 52 + (SLICE_B - SLICE_A) * SLICE_N
ART_X = MID - ART_W // 2
ART_Y = 6
# The video board hangs over the far stands, centred, no wider than x 39..153
# (inner 109 px), 3 px clear of the flag pole at x 157. The flag flies over
# the right end of the stands: cloth x 158..183, y 0..19, round the school
# logo drawn at its authored 24 x 18 (never scaled), pole down to y 21.
BOARD_L = 39
BOARD_R = 153
FLAG_POLE = 157
FLAG_X = 158
FLAG_W = 26
FLAG_H = 20
TL = 9             # gameday text zone x 9..182 (174 px), inside the board
TR = 182           # rails at x 6 and x 185 (every lit pixel stays in x 6..185)
RAIL_L = 6
RAIL_R = 185

INK = "#F4F7FF"
DIM = "#8A94A8"

# ------------------------------------------------------------- stadium art
BOWL = """
...LLL.............BBBBBBBBBBBBB...............LLL..
...LLL...........ssBbbbbbbbbbbbBss.............LLL..
....P.......sssdsssBbbbbbbbbbbbBdssscss.........P...
....P...sssscdsssssBBBBBBBBBBBBBsssssssssss.....P...
....P.ssscsssssssdsssssssscsssssssdsssssssscs...P...
....Psdsssssscsssssssssdsssssscsssssssssdssssss.P...
..sssssssssssscsdsggWGggWGggWGggWdssssssssssssssc...
.sdsssssssssssggWGggWGggWGggWGggWGggWsssssssssssss..
.sssscsssssdZZggWGggWGggWGggWGggWGggWGZcsssssdssss..
ssssssssssZZZZggWGggWGggWGggWGggWGggWGZZZssssssssss.
SSSSSSSSSdZZZZggWGggWGggWGggWGggWGggWGZZZSSdSSSSScS.
TdTTcTTTTTZZZZggWGggWGggWGggWGggWGggWGZZZTTTTTTTTTT.
ESSSdScSSSSSZZggWGggWGggWGggWGggWGggWGZScSSSSSSSSSE.
ETTTTTTcTTTTTTggWGggWGggWGggWGggWGggWTTTTcTTTTTTdTE.
EESdSSSSSSScSSSSSSggWGggWGggWGggWSSSSdSSSSSSScSSSEE.
EeEETTTdcTTTTTTTTTTTTTTTdcTTTTTTTTTTTTTTTdcTTTTEEeE.
EeEEEESSSSSSSSSSSScSSSdSSSSSSSSSSSScSSSdSSSSSEEEEeE.
EeEEeEEETTTTdTTTTcTTTTTTTTTTTdTTTTcTTTTTTTTEEEeEEeE.
.EEEeEEeEEEESSSSSSSScSSSSdSSSSSSSSSSScSEEEEeEEeEEE..
.EEEeEEeEEeEEEEEETTcTTTTTTTTTTTTdTEEEEEEeEEeEEeEEE..
..EEEEEeEEeEEeEEeEEEEEEEEEEEEEEEEEeEEeEEeEEeEEEEE...
....EEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeEEEEEE.....
......EEEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEEEEEE.......
........EEEEEEEEEEEeEEeEEeEEeEEeEEEEEEEEEEE.........
............EEEEEEEEEEEEEEEEEEEEEEEEEEE.............
.................EEEEEEEEEEEEEEEEE..................
"""
HORSESHOE = """
...LLL.........................................LLL..
...LLL...........ssscssssdssssssss.............LLL..
....P.......sssdssscssssssssssssdssscss.........P...
....P...sssscdssssssssssssssscdsssssssssss......P...
....P.ssscsssssssdsssssssscsssssssdsssssss......P...
....Psdsssssscsssssssssdsssssscsssssssssds...BBBPBB.
..sssssssssssscsdsggWGggWGggWGggWdssssssss...BbbbbB.
.sdsssssssssssggWGggWGggWGggWGggWGggWsssss...BbbbbB.
.sssscsssssdZZggWGggWGggWGggWGggWGggWGZcss...BbbbbB.
ssssssssssZZZZggWGggWGggWGggWGggWGggWGZZZs...BbbbbB.
SSSSSSSSSdZZZZggWGggWGggWGggWGggWGggWGZZZS...BBBBBB.
TdTTcTTTTTZZZZggWGggWGggWGggWGggWGggWGZZZT.....PP...
ESSSdScSSSSSZZggWGggWGggWGggWGggWGggWGZScS.....PP...
ETTTTTTcTTTTTTggWGggWGggWGggWGggWGggWTTTTc.....PP...
EESdSSSSSSScSSSSSSggWGggWGggWGggWSSSSdSSSS..........
EeEETTTdcTTTTTTTTTTTTTTTdcTTTTTTTTTTTTTTTd..........
EeEEEESSSSSSSSSSSScSSSdSSSSSSSSSSSScSSSdSS..........
EeEEeEEETTTTdTTTTcTTTTTTTTTTTdTTTTcTTTTTTT..........
.EEEeEEeEEEESSSSSSSScSSSSdSSSSSSSSSSScSEEE..........
.EEEeEEeEEeEEEEEETTcTTTTTTTTTTTTdTEEEEEEeE..........
..EEEEEeEEeEEeEEeEEEEEEEEEEEEEEEEEeEEeEEeE..........
....EEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeE..........
......EEEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEEE..........
........EEEEEEEEEEEeEEeEEeEEeEEeEEEEEEEEEE..........
............EEEEEEEEEEEEEEEEEEEEEEEEEEE.............
.................EEEEEEEEEEEEEEEEE..................
"""
DOUBLE = """
...LLL............KKKKKKKKKKKKKKK..............LLL..
...LLL...........RkkkkkkkkkkkkkkkR.............LLL..
....P.......RRRRRRRcRRRsssssRRRRRRRRcRR.........P...
....P...RRRRcRRsssssssssssssscdsssssRRRRRRR.....P...
....P.RRRcRssssssdsssssssscsssssssdsssssRRRcR...P...
....RRRRRsssscsssssssssdsssssscsssssssssdsRRRRR.....
..RRRRRssssssscsdsggWGggWGggWGggWdssssssssssRRRRc...
.RRRRsssssssssggWGggWGggWGggWGggWGggWsssssssssRRRR..
.RRRRcsssssdZZggWGggWGggWGggWGggWGggWGZcsssssdRRRR..
RRRRssssssZZZZggWGggWGggWGggWGggWGggWGZZZssssssRRRR.
RRRRSSSSSdZZZZggWGggWGggWGggWGggWGggWGZZZSSdSSSRRcR.
RRRRcTTTTTZZZZggWGggWGggWGggWGggWGggWGZZZTTTTTTRRRR.
ERRRRScSSSSSZZggWGggWGggWGggWGggWGggWGZScSSSSSRRRRE.
ERRRRTTcTTTTTTggWGggWGggWGggWGggWGggWTTTTcTTTTRRRRE.
EERRRSSSSSScSSSSSSggWGggWGggWGggWSSSSdSSSSSSScRRREE.
EeEERTTdcTTTTTTTTTTTTTTTdcTTTTTTTTTTTTTTTdcTTTREEeE.
EeEEEESSSSSSSSSSSScSSSdSSSSSSSSSSSScSSSdSSSSSEEEEeE.
EeEEeEEETTTTdTTTTcTTTTTTTTTTTdTTTTcTTTTTTTTEEEeEEeE.
.EEEeEEeEEEESSSSSSSScSSSSdSSSSSSSSSSScSEEEEeEEeEEE..
.EEEeEEeEEeEEEEEETTcTTTTTTTTTTTTdTEEEEEEeEEeEEeEEE..
..EEEEEeEEeEEeEEeEEEEEEEEEEEEEEEEEeEEeEEeEEeEEEEE...
....EEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeEEEEEE.....
......EEEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEEEEEE.......
........EEEEEEEEEEEeEEeEEeEEeEEeEEEEEEEEEEE.........
............EEEEEEEEEEEEEEEEEEEEEEEEEEE.............
.................EEEEEEEEEEEEEEEEE..................
"""
DOME = """
....................................................
.................RRRRRRRRRRRRRRRRR..................
............RRRRROOoOOOOOoOOOOOoOORRRRR.............
........RRRROoOOOOOohhhhhhhhhhhoOOOOOoORRRR.........
......RROOOOOohhhhhhhhhhhhhhhhhhOOOOOoOOOOORR.......
....RROoOOOhhhhhOOOoOOOOOoOOOOOoOOOOOoOOOOOoORR.....
..RROOOohhhhOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOORR...
.RROOOOhhhOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOORR..
.ROOOOhhhOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOR..
RoOOOhhhOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoR.
RoooohhoooooooooooooooooooooooooooooooooooooooooooR.
RoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoR.
EROOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOORE.
ERROOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOORRE.
EERROOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOORREE.
EeEERROoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOOoORREEeE.
EeEEEERROOOOOoOOOOOoOOOOOoOOOOOoOOOOOoOOOOORREEEEeE.
EeEEeEEERRRROoOOOOOoOOOOOoOOOOOoOOOOOoORRRREEEeEEeE.
.EEEeEEeEEEERRRRROOoOOOOOoOOOOOoOORRRRREEEEeEEeEEE..
.EEEeEEeEEeEEEEEERRRRRRRRRRRRRRRRREEEEEEeEEeEEeEEE..
..EEEEEeEEeEEeEEeEEEEEEEEEEEEEEEEEeEEeEEeEEeEEEEE...
....EEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeEEeEEEEEE.....
......EEEEEEEeEEeEEeEEeEEeEEeEEeEEeEEeEEEEEEE.......
........EEEEEEEEEEEeEEeEEeEEeEEeEEEEEEEEEEE.........
............EEEEEEEEEEEEEEEEEEEEEEEEEEE.............
.................EEEEEEEEEEEEEEEEE..................
"""
def mirror(art):
    rows = art.strip("\n").split("\n")
    return "\n" + "\n".join(["".join(reversed(list(r.elems()))) for r in rows]) + "\n"

# The horseshoe opens to the left: the school flag flies over the right-hand
# stands and would hide a scoreboard standing in a right-hand gap.
ART = {"BOWL": BOWL, "HORSESHOE": mirror(HORSESHOE), "DOUBLE": DOUBLE, "DOME": DOME}

# 7 x 7 story icons. "X" takes the category colour.
STORY_ICONS = {
    "NOISE": """
..X....
.XX..X.
XXX.X.X
XXX.X.X
XXX.X.X
.XX..X.
..X....
""",
    "CROWD": """
.X...X.
XXX.XXX
.X.X.X.
..XXX..
.XXXXX.
XXXXXXX
XXXXXXX
""",
    "WATER": """
...X...
...XX..
...XXX.
...X...
XXXXXXX
.XXXXX.
WW.WW.W
""",
    "OLYMPIC": """
..R.R..
.RYR...
..RYR..
.XXXXX.
..XXX..
...X...
...X...
""",
    "PLAY": """
.......
..DDD..
.DBWBD.
DBWWWBD
.DBWBD.
..DDD..
.......
""",
    "HISTORY": """
XXXXXXX
.X.X.X.
.X.X.X.
.X.X.X.
.X.X.X.
XXXXXXX
XXXXXXX
""",
    "CHEER": """
.....X.
...XXX.
XXXXXX.
XXXXXX.
XXXXXX.
...XXX.
.....X.
""",
    "MUSIC": """
..XXXXX
..X...X
..X...X
..X...X
XXX.XXX
XXX.XXX
.......
""",
    "FIELD": """
GWGGGWG
GWGGGWG
GWGGGWG
GWGGGWG
GWGGGWG
GWGGGWG
GWGGGWG
""",
}
STORY_KIND = {
    "NOISE": ["NOISE", "#FFB000"],
    "CROWD": ["RECORD CROWD", "#F4F7FF"],
    "WATER": ["ON THE WATER", "#78DCFF"],
    "OLYMPIC": ["WORLD STAGE", "#FFD24A"],
    "PLAY": ["FAMOUS PLAY", "#FF9A1F"],
    "HISTORY": ["HISTORY", "#C8CED8"],
    "CHEER": ["GAMEDAY", "#FF7EB6"],
    "MUSIC": ["SOUNDTRACK", "#C792FF"],
    "FIELD": ["THE FIELD", "#2FE06F"],
}
ICON_FIXED = {"R": "#FF3D00", "Y": "#FFE000", "D": "#5A2E0E", "B": "#A0522D", "W": "#FFFFFF",
              "G": "#1E9E3A"}

# ---------------------------------------------------------------- schools
# key -> school record. `logo` is the literal asset path (the lint wants
# literals). `name` is the official stadium name, `hero` the name people use.
# When the hero IS the stadium name, the line above it shows the city
# instead. `cap` is the listed capacity (0 = not shown), `open` the year it
# opened, `build` the art, `c` the school colours lifted for LEDs:
# [stands, second colour].
SCHOOLS = [
    {"key": "MICHIGAN", "name": "MICHIGAN STADIUM", "hero": "THE BIG HOUSE", "city": "ANN ARBOR, MI", "short": "BIG HOUSE", "cap": 107601, "rec": [115109, 2013], "open": 1927, "build": "BOWL", "c": ["#2F5FD8", "#FFCB05"],
     "facts": [["CROWD", "115,109 FANS VS NOTRE DAME IN 2013"], ["HISTORY", "DUG INTO THE GROUND - MOST SEATS SIT BELOW STREET LEVEL"], ["PLAY", "APP STATE STUNNED NO. 5 MICHIGAN HERE IN 2007"]]},
    {"key": "PENN STATE", "name": "BEAVER STADIUM", "hero": "HAPPY VALLEY", "city": "STATE COLLEGE, PA", "short": "BEAVER", "cap": 106304, "rec": [111030, 2024], "open": 1960, "build": "DOUBLE", "c": ["#3868D8", "#FFFFFF"],
     "facts": [["CHEER", "WHITE OUT: 100,000+ FANS DRESSED ALL IN WHITE"], ["CROWD", "111,030 FANS VS OHIO STATE IN 2024, A RECORD"], ["HISTORY", "TAKEN APART AND REBUILT ACROSS CAMPUS IN 1960"]]},
    {"key": "OHIO STATE", "name": "OHIO STADIUM", "hero": "THE HORSESHOE", "city": "COLUMBUS, OH", "short": "THE SHOE", "cap": 102780, "rec": [110045, 2016], "open": 1922, "build": "HORSESHOE", "c": ["#E0203F", "#B8BDC4"],
     "facts": [["CROWD", "110,045 FANS VS MICHIGAN IN 2016"], ["HISTORY", "ON THE NATIONAL REGISTER OF HISTORIC PLACES"], ["HISTORY", "BUCKEYE GROVE HAS A TREE FOR EVERY OSU ALL-AMERICAN"]]},
    {"key": "TEXAS A&M", "name": "KYLE FIELD", "hero": "HOME OF THE 12TH MAN", "city": "COLLEGE STATION", "short": "KYLE FIELD", "cap": 102733, "rec": [110633, 2014], "open": 1927, "build": "DOUBLE", "c": ["#A8283E", "#FFFFFF"],
     "facts": [["CROWD", "110,633 FANS VS OLE MISS IN 2014"], ["CHEER", "STUDENTS STAND ALL GAME, READY TO BE CALLED IN"], ["HISTORY", "1922: E. KING GILL LEFT THE STANDS TO SUIT UP"]]},
    {"key": "LSU", "name": "TIGER STADIUM", "hero": "DEATH VALLEY", "city": "BATON ROUGE, LA", "short": "TIGER STADIUM", "cap": 102321, "open": 1924, "build": "DOUBLE", "c": ["#7B45C8", "#FDD023"],
     "facts": [["NOISE", "1988: THE CROWD SHOOK A CAMPUS SEISMOGRAPH"], ["CHEER", "SATURDAY NIGHT IN DEATH VALLEY - MOST GAMES KICK OFF AFTER DARK"], ["HISTORY", "DORM ROOMS WERE BUILT INTO THE STANDS IN THE 1930S"]]},
    {"key": "TENNESSEE", "name": "NEYLAND STADIUM", "hero": "NEYLAND STADIUM", "city": "KNOXVILLE, TN", "short": "NEYLAND", "cap": 101915, "rec": [109061, 2004], "open": 1921, "build": "DOUBLE", "c": ["#FF8200", "#FFFFFF"],
     "facts": [["WATER", "THE VOL NAVY SAILS THE TENNESSEE RIVER TO TAILGATE"], ["CROWD", "109,061 FANS VS FLORIDA IN 2004"], ["MUSIC", "THE VOLS RUN THROUGH A T FORMED BY THE BAND"], ["CROWD", "156,990 SAW THE VOLS AT BRISTOL SPEEDWAY - NOT HERE - IN 2016"]]},
    {"key": "ALABAMA", "name": "BRYANT-DENNY STADIUM", "hero": "BRYANT-DENNY", "city": "TUSCALOOSA, AL", "short": "BRYANT-DENNY", "cap": 100077, "open": 1929, "build": "DOUBLE", "c": ["#D0203E", "#FFFFFF"],
     "facts": [["HISTORY", "BEAR BRYANT JOINED GEORGE DENNY ON THE NAME IN 1975"], ["CHEER", "THE TIDE ARRIVES ON THE WALK OF CHAMPIONS"], ["HISTORY", "STATUES OF TITLE-WINNING COACHES LINE THE WALK"]]},
    {"key": "TEXAS", "name": "DARRELL K ROYAL-TEXAS MEMORIAL STADIUM", "hero": "DKR STADIUM", "city": "AUSTIN, TX", "short": "DKR", "cap": 100119, "open": 1924, "build": "DOUBLE", "c": ["#E8763A", "#FFFFFF"],
     "facts": [["HISTORY", "BUILT AS A MEMORIAL TO TEXANS WHO SERVED IN WWI"], ["HISTORY", "RENAMED FOR COACH DARRELL K ROYAL IN 1996"], ["CHEER", "THE UT TOWER GLOWS ORANGE AFTER A WIN"]]},
    {"key": "GEORGIA", "name": "SANFORD STADIUM", "hero": "BETWEEN THE HEDGES", "city": "ATHENS, GA", "short": "SANFORD", "cap": 93033, "open": 1929, "build": "BOWL", "c": ["#E8203F", "#FFFFFF"],
     "facts": [["FIELD", "THE HEDGES WERE PLANTED FOR THE FIRST GAME IN 1929"], ["OLYMPIC", "HOSTED THE 1996 OLYMPIC SOCCER FINALS"], ["CHEER", "THE CHAPEL BELL RINGS AFTER EVERY BULLDOG WIN"]]},
    {"key": "USC", "name": "LOS ANGELES MEMORIAL COLISEUM", "hero": "THE COLISEUM", "city": "LOS ANGELES, CA", "short": "COLISEUM", "cap": 77500, "open": 1923, "build": "BOWL", "c": ["#C8283E", "#FFC72C"],
     "facts": [["OLYMPIC", "HOSTED THE 1932 AND 1984 OLYMPICS - AND 2028 IS NEXT"], ["HISTORY", "HOSTED THE FIRST SUPER BOWL IN 1967"], ["HISTORY", "A NATIONAL HISTORIC LANDMARK SINCE 1984"]]},
    {"key": "NEBRASKA", "name": "MEMORIAL STADIUM", "hero": "THE SEA OF RED", "city": "LINCOLN, NE", "short": "LINCOLN", "cap": 85458, "open": 1923, "build": "BOWL", "c": ["#E8203A", "#FFFFFF"],
     "facts": [["CROWD", "SOLD OUT EVERY GAME SINCE 1962 - AN NCAA RECORD"], ["CROWD", "ON GAMEDAY IT WOULD BE THE THIRD-BIGGEST CITY IN THE STATE"], ["MUSIC", "THE TUNNEL WALK HAS OPENED HOME GAMES SINCE 1994"]]},
    {"key": "FLORIDA", "name": "BEN HILL GRIFFIN STADIUM", "hero": "THE SWAMP", "city": "GAINESVILLE, FL", "short": "THE SWAMP", "cap": 88548, "open": 1930, "build": "BOWL", "c": ["#2A5BE0", "#FA4616"],
     "facts": [["HISTORY", "SPURRIER NAMED IT: ONLY GATORS GET OUT ALIVE"], ["FIELD", "THE FIELD WAS NAMED FOR STEVE SPURRIER IN 2016"], ["CHEER", "MR. TWO BITS LED HIS CHEER FOR ABOUT 60 YEARS"]]},
    {"key": "AUBURN", "name": "JORDAN-HARE STADIUM", "hero": "JORDAN-HARE", "city": "AUBURN, AL", "short": "JORDAN-HARE", "cap": 88043, "open": 1939, "build": "DOUBLE", "c": ["#3561B8", "#F26522"],
     "facts": [["PLAY", "KICK SIX: A MISSED FG RUN BACK TO BEAT BAMA IN 2013"], ["PLAY", "PRAYER AT JORDAN-HARE: A 73-YARD TD BEAT UGA IN 2013"], ["HISTORY", "NAMED FOR SHUG JORDAN IN 1973 - WHILE HE COACHED"]]},
    {"key": "OKLAHOMA", "name": "GAYLORD FAMILY OKLAHOMA MEMORIAL STADIUM", "hero": "PALACE ON THE PRAIRIE", "city": "NORMAN, OK", "short": "OWEN FIELD", "cap": 80126, "open": 1923, "build": "DOUBLE", "c": ["#D0202C", "#F0E6D2"],
     "facts": [["FIELD", "OWEN FIELD HONORS BENNIE OWEN, COACH 1905-1926"], ["HISTORY", "A MEMORIAL TO OKLAHOMANS WHO DIED IN WWI"], ["HISTORY", "HEISMAN PARK NEXT DOOR HONORS SOONER WINNERS"]]},
    {"key": "CLEMSON", "name": "MEMORIAL STADIUM", "hero": "DEATH VALLEY", "city": "CLEMSON, SC", "short": "CLEMSON", "cap": 81500, "open": 1942, "build": "BOWL", "c": ["#F56600", "#A070E0"],
     "facts": [["CHEER", "RUNNING DOWN THE HILL: THE MOST EXCITING 25 SECONDS"], ["HISTORY", "AN OPPOSING COACH NICKNAMED IT DEATH VALLEY"], ["HISTORY", "CLEMSON AND LSU BOTH PLAY IN A DEATH VALLEY"]]},
    {"key": "NOTRE DAME", "name": "NOTRE DAME STADIUM", "hero": "THE HOUSE ROCKNE BUILT", "city": "NOTRE DAME, IN", "short": "SOUTH BEND", "cap": 77622, "open": 1930, "build": "BOWL", "c": ["#3A64B0", "#D4A20A"],
     "facts": [["HISTORY", "KNUTE ROCKNE HELPED DESIGN IT FOR 1930"], ["CHEER", "PLAYERS SLAP THE PLAY LIKE A CHAMPION TODAY SIGN"], ["FIELD", "GRASS GAVE WAY TO FIELDTURF IN 2014"]]},
    {"key": "WISCONSIN", "name": "CAMP RANDALL STADIUM", "hero": "CAMP RANDALL", "city": "MADISON, WI", "short": "CAMP RANDALL", "cap": 76057, "open": 1917, "build": "DOUBLE", "c": ["#D82032", "#FFFFFF"],
     "facts": [["HISTORY", "BUILT ON A CIVIL WAR TRAINING CAMP FOR THE UNION"], ["MUSIC", "JUMP AROUND BEFORE THE 4TH QUARTER, SINCE 1998"], ["MUSIC", "THE 5TH QUARTER: THE BAND PLAYS ON AFTER THE GAME"]]},
    {"key": "OREGON", "name": "AUTZEN STADIUM", "hero": "AUTZEN STADIUM", "city": "EUGENE, OR", "short": "AUTZEN", "cap": 54000, "open": 1967, "build": "BOWL", "c": ["#1FA35A", "#FEE123"],
     "facts": [["CHEER", "IT NEVER RAINS IN AUTZEN STADIUM"], ["NOISE", "A SUNKEN BOWL WITH FANS RIGHT ON TOP OF THE FIELD"], ["CHEER", "THE DUCK RIDES IN ON A MOTORCYCLE BEFORE KICKOFF"], ["MUSIC", "FANS SING SHOUT BEFORE THE 4TH QUARTER"]]},
    {"key": "WASHINGTON", "name": "HUSKY STADIUM", "hero": "HUSKY STADIUM", "city": "SEATTLE, WA", "short": "SEATTLE", "cap": 72132, "open": 1920, "build": "HORSESHOE", "c": ["#8450E0", "#E8D3A2"],
     "facts": [["WATER", "SAILGATING: FANS ARRIVE BY BOAT ON LAKE WASHINGTON"], ["NOISE", "MEASURED AT 133.6 DECIBELS VS NEBRASKA IN 1992"], ["NOISE", "ROOFS OVER THE STANDS BOUNCE THE NOISE DOWN"]]},
    {"key": "IOWA", "name": "KINNICK STADIUM", "hero": "KINNICK STADIUM", "city": "IOWA CITY, IA", "short": "KINNICK", "cap": 69250, "open": 1929, "build": "BOWL", "c": ["#FFCD00", "#FFFFFF"],
     "facts": [["HISTORY", "NAMED FOR NILE KINNICK, 1939 HEISMAN WINNER"], ["CHEER", "THE WAVE: FANS WAVE TO KIDS AT THE HOSPITAL NEXT DOOR"], ["HISTORY", "THE VISITORS LOCKER ROOM IS PAINTED PINK"]]},
    {"key": "MICHIGAN STATE", "name": "SPARTAN STADIUM", "hero": "SPARTAN STADIUM", "city": "EAST LANSING, MI", "short": "EAST LANSING", "cap": 74866, "open": 1923, "build": "DOUBLE", "c": ["#2E9A62", "#FFFFFF"],
     "facts": [["PLAY", "LITTLE GIANTS: A FAKE FG BEAT NOTRE DAME IN OT, 2010"], ["CHEER", "THE SPARTAN WALK PASSES THE BRONZE SPARTAN STATUE"]]},
    {"key": "FLORIDA STATE", "name": "DOAK CAMPBELL STADIUM", "hero": "DOAK CAMPBELL", "city": "TALLAHASSEE, FL", "short": "DOAK", "cap": 67277, "rec": [84431, 2014], "open": 1950, "build": "DOUBLE", "c": ["#B03E5A", "#CEB888"],
     "facts": [["HISTORY", "WRAPPED IN BRICK ARCHES ALL THE WAY AROUND"], ["FIELD", "BOBBY BOWDEN FIELD SINCE 2004"], ["MUSIC", "THE WAR CHANT ROLLS AROUND THE STANDS"]]},
    {"key": "MIAMI", "name": "HARD ROCK STADIUM", "hero": "HARD ROCK STADIUM", "city": "MIAMI GARDENS, FL", "short": "HARD ROCK", "cap": 65326, "open": 1987, "build": "DOUBLE", "c": ["#F47321", "#1FA06A"],
     "facts": [["CHEER", "THE CANES RUN OUT THROUGH A CLOUD OF SMOKE"], ["HISTORY", "MIAMI PLAYED IN THE ORANGE BOWL UNTIL 2007"], ["HISTORY", "A 2016 CANOPY SHADES MOST OF THE SEATS"]]},
    {"key": "OLE MISS", "name": "VAUGHT-HEMINGWAY STADIUM", "hero": "VAUGHT-HEMINGWAY", "city": "OXFORD, MS", "short": "OXFORD", "cap": 64038, "open": 1915, "build": "BOWL", "c": ["#3868D0", "#E8203A"],
     "facts": [["CHEER", "THE GROVE: 10 ACRES OF TENTS AND CHANDELIERS"], ["CHEER", "THE TEAM WALKS THROUGH THE GROVE BEFORE GAMES"], ["HISTORY", "NAMED FOR COACH JOHNNY VAUGHT AND JUDGE HEMINGWAY"]]},
    {"key": "MISSISSIPPI STATE", "name": "DAVIS WADE STADIUM", "hero": "DAVIS WADE", "city": "STARKVILLE, MS", "short": "DAVIS WADE", "cap": 60311, "rec": [62945, 2014], "open": 1914, "build": "BOWL", "c": ["#B8304A", "#FFFFFF"],
     "facts": [["NOISE", "COWBELLS RING ALL GAME - LEGAL AGAIN SINCE 2010"], ["HISTORY", "OPENED IN 1914 - AMONG THE OLDEST IN THE FBS"]]},
    {"key": "ARKANSAS", "name": "DONALD W. REYNOLDS RAZORBACK STADIUM", "hero": "RAZORBACK STADIUM", "city": "FAYETTEVILLE, AR", "short": "FAYETTEVILLE", "cap": 76212, "open": 1938, "build": "DOUBLE", "c": ["#D8283E", "#FFFFFF"],
     "facts": [["NOISE", "CALLING THE HOGS: WOOO PIG SOOIE"], ["HISTORY", "THE HOGS ALSO PLAYED IN LITTLE ROCK UNTIL 2018"]]},
    {"key": "SOUTH CAROLINA", "name": "WILLIAMS-BRICE STADIUM", "hero": "WILLIAMS-BRICE", "city": "COLUMBIA, SC", "short": "COLUMBIA", "cap": 77559, "open": 1934, "build": "DOUBLE", "c": ["#C8203A", "#FFFFFF"],
     "facts": [["MUSIC", "THE TEAM ENTERS TO 2001: A SPACE ODYSSEY"], ["CHEER", "THE COCKABOOSE: 22 CABOOSES FOR TAILGATING"], ["MUSIC", "SANDSTORM SETS THE WHOLE STADIUM WAVING TOWELS"]]},
    {"key": "KENTUCKY", "name": "KROGER FIELD", "hero": "KROGER FIELD", "city": "LEXINGTON, KY", "short": "LEXINGTON", "cap": 61000, "open": 1973, "build": "BOWL", "c": ["#3868E8", "#FFFFFF"],
     "facts": [["HISTORY", "OPENED IN 1973 AS COMMONWEALTH STADIUM"], ["CHEER", "THE CAT WALK: PLAYERS WALK THROUGH THE FANS"]]},
    {"key": "TEXAS TECH", "name": "JONES AT&T STADIUM", "hero": "THE JONES", "city": "LUBBOCK, TX", "short": "LUBBOCK", "cap": 60229, "open": 1947, "build": "DOUBLE", "c": ["#E8202A", "#FFFFFF"],
     "facts": [["CHEER", "FANS THREW TORTILLAS AT KICKOFF - NOW A PENALTY"], ["HISTORY", "OPENED IN 1947 AS JONES STADIUM"]]},
    {"key": "BAYLOR", "name": "MCLANE STADIUM", "hero": "MCLANE STADIUM", "city": "WACO, TX", "short": "WACO", "cap": 45140, "open": 2014, "build": "BOWL", "c": ["#2E9A62", "#FFB81C"],
     "facts": [["WATER", "ON THE BRAZOS RIVER - FANS CAN ARRIVE BY BOAT"], ["CHEER", "FRESHMEN SPRINT ONTO THE FIELD IN THE BAYLOR LINE"]]},
    {"key": "KANSAS STATE", "name": "BILL SNYDER FAMILY STADIUM", "hero": "BILL SNYDER", "city": "MANHATTAN, KS", "short": "MANHATTAN", "cap": 50000, "open": 1968, "build": "BOWL", "c": ["#9A68E8", "#FFFFFF"],
     "facts": [["HISTORY", "NAMED FOR BILL SNYDER IN 2005 - THEN HE CAME BACK TO COACH"], ["MUSIC", "WABASH CANNONBALL: THE CROWD SWAYS SIDE TO SIDE"]]},
    {"key": "WEST VIRGINIA", "name": "MILAN PUSKAR STADIUM", "hero": "MOUNTAINEER FIELD", "city": "MORGANTOWN, WV", "short": "MORGANTOWN", "cap": 60000, "open": 1980, "build": "BOWL", "c": ["#EAAA00", "#4A7AD8"],
     "facts": [["MUSIC", "COUNTRY ROADS: SUNG BY TEAM AND FANS AFTER A WIN"], ["NOISE", "THE MOUNTAINEER FIRES HIS MUSKET AFTER A SCORE"]]},
    {"key": "UTAH", "name": "RICE-ECCLES STADIUM", "hero": "RICE-ECCLES", "city": "SALT LAKE CITY, UT", "short": "SALT LAKE", "cap": 51444, "open": 1927, "build": "BOWL", "c": ["#E8202A", "#FFFFFF"],
     "facts": [["OLYMPIC", "OPENED THE 2002 WINTER OLYMPICS"], ["NOISE", "THE MUSS: THE MIGHTY UTAH STUDENT SECTION"], ["HISTORY", "REBUILT IN 1998 ON THE OLD RICE STADIUM SITE"]]},
    {"key": "BYU", "name": "LAVELL EDWARDS STADIUM", "hero": "LAVELL EDWARDS", "city": "PROVO, UT", "short": "PROVO", "cap": 62073, "open": 1964, "build": "BOWL", "c": ["#3070E8", "#FFFFFF"],
     "facts": [["HISTORY", "RENAMED FOR COACH LAVELL EDWARDS IN 2000"], ["HISTORY", "Y MOUNTAIN AND ITS GIANT Y LOOM OVER THE STANDS"], ["HISTORY", "BYU NEVER PLAYS ON SUNDAY - A SCHOOL POLICY"]]},
    {"key": "ARIZONA STATE", "name": "MOUNTAIN AMERICA STADIUM", "hero": "MOUNTAIN AMERICA", "city": "TEMPE, AZ", "short": "TEMPE", "cap": 53599, "open": 1958, "build": "BOWL", "c": ["#D03A64", "#FFC627"],
     "facts": [["HISTORY", "BUILT BETWEEN TWO BUTTES IN TEMPE"], ["HISTORY", "HOSTED SUPER BOWL XXX IN 1996"], ["HISTORY", "KNOWN AS SUN DEVIL STADIUM UNTIL 2023"]]},
    {"key": "STANFORD", "name": "STANFORD STADIUM", "hero": "STANFORD STADIUM", "city": "STANFORD, CA", "short": "THE FARM", "cap": 50424, "open": 1921, "build": "BOWL", "c": ["#D0283C", "#FFFFFF"],
     "facts": [["HISTORY", "HOSTED SUPER BOWL XIX IN 1985"], ["HISTORY", "TORN DOWN AND REBUILT IN ABOUT 10 MONTHS IN 2006"], ["OLYMPIC", "HOSTED MATCHES AT THE 1994 WORLD CUP"]]},
    {"key": "CALIFORNIA", "name": "CALIFORNIA MEMORIAL STADIUM", "hero": "CAL MEMORIAL", "city": "BERKELEY, CA", "short": "BERKELEY", "cap": 0, "rec": [83000, 1947], "open": 1923, "build": "BOWL", "c": ["#3868D0", "#FFC72C"],
     "facts": [["HISTORY", "THE HAYWARD FAULT RUNS RIGHT UNDER THE STADIUM"], ["PLAY", "THE PLAY: 5 LATERALS THROUGH THE BAND BEAT STANFORD, 1982"], ["CHEER", "TIGHTWAD HILL: FANS WATCH FREE FROM THE HILLSIDE"]]},
    {"key": "UCLA", "name": "THE ROSE BOWL", "hero": "THE ROSE BOWL", "city": "PASADENA, CA", "short": "PASADENA", "cap": 89702, "open": 1922, "build": "BOWL", "c": ["#4A96E0", "#F2A900"],
     "facts": [["HISTORY", "A NATIONAL HISTORIC LANDMARK"], ["OLYMPIC", "FIVE SUPER BOWLS AND THE 1994 WORLD CUP FINAL"], ["HISTORY", "UCLA HAS PLAYED HOME GAMES HERE SINCE 1982"], ["CHEER", "THE 8-CLAP: EIGHT CLAPS, U-C-L-A, THEN FIGHT FIGHT FIGHT"]]},
    {"key": "VIRGINIA TECH", "name": "LANE STADIUM", "hero": "LANE STADIUM", "city": "BLACKSBURG, VA", "short": "BLACKSBURG", "cap": 65632, "open": 1965, "build": "DOUBLE", "c": ["#B84A68", "#F0702E"],
     "facts": [["MUSIC", "ENTER SANDMAN SETS THE WHOLE STADIUM JUMPING"], ["CHEER", "PLAYERS TOUCH HOKIE STONE ON THE WAY OUT"]]},
    {"key": "NORTH CAROLINA", "name": "KENAN STADIUM", "hero": "KENAN STADIUM", "city": "CHAPEL HILL, NC", "short": "CHAPEL HILL", "cap": 50500, "open": 1927, "build": "BOWL", "c": ["#7BAFD4", "#FFFFFF"],
     "facts": [["HISTORY", "SET IN A WOODED VALLEY RINGED BY TALL PINES"], ["HISTORY", "A GIFT FROM WILLIAM RAND KENAN JR. BUILT IT"]]},
    {"key": "SYRACUSE", "name": "JMA WIRELESS DOME", "hero": "THE DOME", "city": "SYRACUSE, NY", "short": "JMA DOME", "cap": 42784, "open": 1980, "build": "DOME", "c": ["#FF5A1F", "#4A78E0"],
     "facts": [["HISTORY", "THE BIGGEST DOME ON A COLLEGE CAMPUS"], ["HISTORY", "KNOWN AS THE CARRIER DOME UNTIL 2022"], ["HISTORY", "A FIXED ROOF REPLACED THE AIR-FILLED ONE IN 2020"]]},
    {"key": "ARMY", "name": "MICHIE STADIUM", "hero": "MICHIE STADIUM", "city": "WEST POINT, NY", "short": "WEST POINT", "tag": "ABOVE THE HUDSON", "cap": 0, "open": 1924, "build": "BOWL", "c": ["#D3BC8D", "#B0B7BC"],
     "facts": [["WATER", "SITS ABOVE THE HUDSON RIVER AT WEST POINT"], ["CROWD", "THE CORPS OF CADETS STANDS FOR THE WHOLE GAME"], ["CHEER", "PARACHUTISTS OFTEN DROP IN WITH THE GAME BALL"]]},
    {"key": "NAVY", "name": "NAVY-MARINE CORPS MEMORIAL STADIUM", "hero": "NAVY-MARINE CORPS", "city": "ANNAPOLIS, MD", "short": "ANNAPOLIS", "cap": 34000, "open": 1959, "build": "BOWL", "c": ["#4A6AC0", "#C5B783"],
     "facts": [["HISTORY", "THE STANDS CARRY NAMES OF NAVY AND MARINE BATTLES"], ["CROWD", "THE BRIGADE OF MIDSHIPMEN MARCHES ON BEFORE GAMES"]]},
    {"key": "BOISE STATE", "name": "ALBERTSONS STADIUM", "hero": "THE BLUE", "city": "BOISE, ID", "short": "ALBERTSONS", "cap": 36387, "open": 1970, "build": "BOWL", "c": ["#3068E8", "#FF6A1F"],
     "facts": [["FIELD", "BLUE TURF SINCE 1986 - THE FIRST NON-GREEN FIELD"], ["FIELD", "FANS CALL THE FIELD THE SMURF TURF"]]},
    {"key": "MINNESOTA", "name": "HUNTINGTON BANK STADIUM", "hero": "HUNTINGTON BANK", "city": "MINNEAPOLIS, MN", "short": "MINNEAPOLIS", "cap": 50805, "open": 2009, "build": "HORSESHOE", "c": ["#B83A68", "#FAB41C"],
     "facts": [["HISTORY", "2009: BACK ON CAMPUS AFTER 27 YEARS IN THE METRODOME"], ["HISTORY", "ONE END IS OPEN, LOOKING OUT AT DOWNTOWN"]]},
    {"key": "ILLINOIS", "name": "MEMORIAL STADIUM", "hero": "MEMORIAL STADIUM", "city": "CHAMPAIGN, IL", "short": "CHAMPAIGN", "cap": 60670, "open": 1923, "build": "DOUBLE", "c": ["#FF5F2A", "#4A7AD8"],
     "facts": [["PLAY", "1924: RED GRANGE, 4 TDS IN 12 MINUTES VS MICHIGAN"], ["HISTORY", "ITS COLUMNS NAME ILLINI WHO DIED IN WWI"]]},
    {"key": "RUTGERS", "name": "SHI STADIUM", "hero": "SHI STADIUM", "city": "PISCATAWAY, NJ", "short": "PISCATAWAY", "cap": 52454, "open": 1994, "build": "BOWL", "c": ["#E8203A", "#FFFFFF"],
     "facts": [["HISTORY", "RUTGERS PLAYED THE FIRST GAME, VS PRINCETON IN 1869"], ["HISTORY", "THE SCARLET KNIGHTS HAVE PLAYED HERE SINCE 1938"]]},
    {"key": "DUKE", "name": "WALLACE WADE STADIUM", "hero": "WALLACE WADE", "city": "DURHAM, NC", "short": "DURHAM", "cap": 35018, "open": 1929, "build": "HORSESHOE", "c": ["#3070E0", "#FFFFFF"],
     "facts": [["HISTORY", "HOSTED THE 1942 ROSE BOWL AFTER PEARL HARBOR"], ["HISTORY", "NAMED FOR COACH WALLACE WADE IN 1967"]]},
    {"key": "GEORGIA TECH", "name": "BOBBY DODD STADIUM", "hero": "BOBBY DODD", "city": "ATLANTA, GA", "short": "ATLANTA", "cap": 52113, "open": 1913, "build": "DOUBLE", "c": ["#C8B478", "#FFFFFF"],
     "facts": [["HISTORY", "THE OLDEST ON-CAMPUS STADIUM IN THE FBS"], ["PLAY", "TECH BEAT CUMBERLAND 222-0 HERE IN 1916"], ["CHEER", "THE RAMBLIN WRECK, A 1930 FORD, LEADS THEM OUT"]]},
    {"key": "PITTSBURGH", "name": "ACRISURE STADIUM", "hero": "ACRISURE STADIUM", "city": "PITTSBURGH, PA", "short": "NORTH SHORE", "cap": 68400, "open": 2001, "build": "DOUBLE", "c": ["#3868E8", "#FFB81C"],
     "facts": [["HISTORY", "PITT SHARES IT WITH THE PITTSBURGH STEELERS"], ["HISTORY", "KNOWN AS HEINZ FIELD UNTIL 2022"], ["WATER", "ON THE NORTH SHORE, WHERE THE RIVERS MEET"]]},
    {"key": "IOWA STATE", "name": "JACK TRICE STADIUM", "hero": "JACK TRICE", "city": "AMES, IA", "short": "AMES", "cap": 61500, "open": 1975, "build": "BOWL", "c": ["#D82A3E", "#FFC72A"],
     "facts": [["HISTORY", "NAMED FOR JACK TRICE, THE FIRST BLACK ATHLETE AT ISU"], ["HISTORY", "TRICE DIED OF INJURIES FROM A 1923 GAME"]]},
    {"key": "INDIANA", "name": "MEMORIAL STADIUM", "hero": "MEMORIAL STADIUM", "city": "BLOOMINGTON, IN", "short": "BLOOMINGTON", "cap": 53524, "open": 1960, "build": "BOWL", "c": ["#D8203A", "#FFFFFF"],
     "facts": [["HISTORY", "HOME OF THE 2025 NATIONAL CHAMPIONS, 16-0"], ["CHEER", "A LIMESTONE BOULDER HONORS COACH TERRY HOEPPNER"]]},
    {"key": "COLORADO", "name": "FOLSOM FIELD", "hero": "FOLSOM FIELD", "city": "BOULDER, CO", "short": "BOULDER", "cap": 50183, "open": 1924, "build": "BOWL", "c": ["#CFB87C", "#B8BDC4"],
     "facts": [["CHEER", "RALPHIE THE BISON CHARGES OUT BEFORE EACH HALF"], ["HISTORY", "5,360 FEET UP - THE THIRD-HIGHEST FIELD IN THE FBS"], ["MUSIC", "THE GRATEFUL DEAD PLAYED HERE IN 1972 AND 1980"]]},
    {"key": "TCU", "name": "AMON G. CARTER STADIUM", "hero": "AMON G. CARTER", "city": "FORT WORTH, TX", "short": "FORT WORTH", "cap": 0, "rec": [53294, 2023], "open": 1930, "build": "DOUBLE", "c": ["#8A50E0", "#FFFFFF"],
     "facts": [["CROWD", "53,294 FANS VS COLORADO IN 2023, A RECORD"], ["HISTORY", "REBUILT ALMOST FROM THE GROUND UP IN 2010-12"], ["HISTORY", "HOSTS THE ARMED FORCES BOWL EVERY YEAR"]]},
    {"key": "MISSOURI", "name": "MEMORIAL STADIUM", "hero": "FAUROT FIELD", "city": "COLUMBIA, MO", "short": "MIZZOU", "cap": 63609, "rec": [75298, 1980], "open": 1926, "build": "BOWL", "c": ["#F1B82D", "#B8BDC4"],
     "facts": [["FIELD", "FRESHMEN BUILT THE ROCK M ON THE NORTH HILL IN 1927"], ["HISTORY", "2026 IS ITS 100TH SEASON - WITH A NEW NORTH END ZONE"], ["CROWD", "75,298 FANS VS PENN STATE IN 1980"]]},
    {"key": "OKLAHOMA STATE", "name": "BOONE PICKENS STADIUM", "hero": "BOONE PICKENS", "city": "STILLWATER, OK", "short": "STILLWATER", "cap": 52305, "rec": [60218, 2013], "open": 1920, "build": "DOUBLE", "c": ["#FF7300", "#FFFFFF"],
     "facts": [["HISTORY", "THE OLDEST STADIUM IN THE BIG 12 - HOME SINCE 1920"], ["FIELD", "THE FIELD RUNS EAST-WEST TO BEAT THE PRAIRIE WIND"], ["HISTORY", "LEWIS FIELD UNTIL 2003, THEN NAMED FOR BOONE PICKENS"], ["CROWD", "60,218 FANS VS BAYLOR IN 2013"]]},
    {"key": "PURDUE", "name": "ROSS-ADE STADIUM", "hero": "ROSS-ADE", "city": "WEST LAFAYETTE, IN", "short": "ROSS-ADE", "cap": 61441, "rec": [71629, 1980], "open": 1924, "build": "HORSESHOE", "c": ["#CEB888", "#B8BDC4"],
     "facts": [["MUSIC", "THE BAND ROLLS OUT THE WORLDS LARGEST DRUM"], ["PLAY", "PURDUE ROUTED NO. 2 OHIO STATE 49-20 HERE IN 2018"], ["CROWD", "71,629 FANS VS INDIANA IN 1980"], ["HISTORY", "NAMED FOR DONORS DAVID ROSS AND GEORGE ADE"]]},
    {"key": "AIR FORCE", "name": "FALCON STADIUM", "hero": "FALCON STADIUM", "city": "USAF ACADEMY, CO", "short": "USAF ACADEMY", "cap": 0, "rec": [56409, 2002], "open": 1962, "build": "BOWL", "c": ["#3A70E0", "#B8BDC4"],
     "facts": [["HISTORY", "6,621 FEET UP - THE SECOND-HIGHEST FIELD IN THE FBS"], ["CROWD", "56,409 FANS VS NOTRE DAME IN 2002"], ["HISTORY", "THE ACADEMY HOLDS ITS GRADUATION HERE EACH SPRING"]]},
]

LOGOS = {
    "MICHIGAN": "S_MICH.png",
    "PENN STATE": "S_PSU.png",
    "OHIO STATE": "S_OSU.png",
    "TEXAS A&M": "S_TAMU.png",
    "LSU": "S_LSU.png",
    "TENNESSEE": "S_TENN.png",
    "ALABAMA": "S_ALA.png",
    "TEXAS": "S_TEX.png",
    "GEORGIA": "S_UGA.png",
    "USC": "S_USC.png",
    "NEBRASKA": "S_NEB.png",
    "FLORIDA": "S_FLA.png",
    "AUBURN": "S_AUB.png",
    "OKLAHOMA": "S_OU.png",
    "CLEMSON": "S_CLEM.png",
    "NOTRE DAME": "S_ND.png",
    "WISCONSIN": "S_WIS.png",
    "OREGON": "S_ORE.png",
    "WASHINGTON": "S_WASH.png",
    "IOWA": "S_IOWA.png",
    "MICHIGAN STATE": "S_MSU.png",
    "FLORIDA STATE": "S_FSU.png",
    "MIAMI": "S_MIA.png",
    "OLE MISS": "S_MISS.png",
    "MISSISSIPPI STATE": "S_MSST.png",
    "ARKANSAS": "S_ARK.png",
    "SOUTH CAROLINA": "S_SC.png",
    "KENTUCKY": "S_UK.png",
    "TEXAS TECH": "S_TTU.png",
    "BAYLOR": "S_BAY.png",
    "KANSAS STATE": "S_KSU.png",
    "WEST VIRGINIA": "S_WVU.png",
    "UTAH": "S_UTAH.png",
    "BYU": "S_BYU.png",
    "ARIZONA STATE": "S_ASU.png",
    "STANFORD": "S_STAN.png",
    "CALIFORNIA": "S_CAL.png",
    "UCLA": "S_UCLA.png",
    "VIRGINIA TECH": "S_VT.png",
    "NORTH CAROLINA": "S_UNC.png",
    "SYRACUSE": "S_SYR.png",
    "ARMY": "S_ARMY.png",
    "NAVY": "S_NAVY.png",
    "BOISE STATE": "S_BOIS.png",
    "MINNESOTA": "S_MINN.png",
    "ILLINOIS": "S_ILL.png",
    "RUTGERS": "S_RUTG.png",
    "DUKE": "S_DUKE.png",
    "GEORGIA TECH": "S_GT.png",
    "PITTSBURGH": "S_PITT.png",
    "IOWA STATE": "S_ISU.png",
    "INDIANA": "S_IU.png",
    "COLORADO": "S_COLO.png",
    "TCU": "S_TCU.png",
    "MISSOURI": "S_MIZ.png",
    "OKLAHOMA STATE": "S_OKST.png",
    "PURDUE": "S_PUR.png",
    "AIR FORCE": "S_AFA.png",
}

KEYS = [s["key"] for s in SCHOOLS]
BY_KEY = {s["key"]: s for s in SCHOOLS}

# Per-school art tells, each one a thing fans know the place by.
WATER = ["WASHINGTON", "TENNESSEE", "BAYLOR", "ARMY", "PITTSBURGH"]   # boats, rivers
PEAKS = ["COLORADO", "AIR FORCE", "BYU", "UTAH"]                        # the mountains behind
NIGHT = ["LSU"]                                                         # Saturday night
HEDGES = ["GEORGIA"]                                                    # between the hedges
CHECKER = ["TENNESSEE"]                                                 # checkerboard end zones
BLUE_TURF = ["BOISE STATE"]

# Backdrops, stamped into the empty corners of the stadium art (same 52
# columns). Mountains: a snowcapped peak behind each light tower.
MOUNTAINS = """
..........w.............................ww..........
.........wwM...........................MwwM.........
........MwwMM.........................MMwwMM........
.......MMMwMMM.......................MMMwMMMM.......
......MMMMMMMMM.....................MMMMMMMMMM......
.....MMMMMMMMMMM...................MMMMMMMMMMMM.....
....MMMMMMMMMMMMM.................MMMMMMMMMMMMMM....
"""
# Night: a crescent moon left of the far stands, stars to the right.
NIGHT_SKY = """
.......nn............................n..............
......n.....................................n.......
.......nn.......................................n...
.........................................n..........
"""
WAVES = """
.bbWbbbbbWbbbbbWbbbbbWbbbbbWbbbbbWbbbbbWbbbbbWbbbb.
bBBbBBBBBbBBBBBbBBBBBbBBBBBbBBBBBbBBBBBbBBBBBbBBBBb
"""
PLAQUE_Y = 24      # sign text y 24..28, the sign frames y 23..31: on the arched base

# ------------------------------------------------------------- text tools
HEXD = "0123456789abcdef"

def ink_for(fill):
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def is_whiteish(col):
    h = str(col).lower()
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return v[0] > 220 and v[1] > 220 and v[2] > 220

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def wrap(c, text, font, maxw):
    """Word-wrap into lines no wider than maxw (no line cap here: the caller
    decides whether the result fits)."""
    words = [w for w in str(text).split(" ") if w != ""]
    lines = []
    cur = ""
    for w in words:
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            cur = w if c.text_width(w, font) <= maxw else clip(c, w, font, maxw)
    if cur != "":
        lines.append(cur)
    return lines

def hero_wrap(c, text, font, maxw):
    """Wrap the hero name, breaking a hyphenated name after its hyphen
    ('VAUGHT-' / 'HEMINGWAY', 'WILLIAMS-' / 'BRICE'): plain wrap() cut the
    one long word to 'VAUGHT-HEMIN'. None when a piece still won't fit."""
    toks = []
    for w in [x for x in str(text).split(" ") if x != ""]:
        parts = w.split("-")
        for i in range(len(parts)):
            toks.append([parts[i] + ("-" if i < len(parts) - 1 else ""), " " if i == 0 else ""])
    lines = []
    cur = ""
    for t in toks:
        trial = t[0] if cur == "" else cur + t[1] + t[0]
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            cur = t[0]
    if cur != "":
        lines.append(cur)
    for ln in lines:
        if c.text_width(ln, font) > maxw:
            return None
    return lines

def commas(n):
    s = str(n)
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return out

# --------------------------------------------------------------- choosing
def pick_school(ctx):
    want = str(ctx.inputs.get("school", "ALL SCHOOLS")).strip().upper()
    if want in BY_KEY:
        return BY_KEY[want]
    return SCHOOLS[(ctx.now.unix // SCHOOL_SECS) % len(SCHOOLS)]

# ---------------------------------------------------------------- drawing
def legend_for(s):
    p = s["c"][0]
    sec = s["c"][1]
    field = ["#1E9E3A", "#17802E"]
    if s["key"] in BLUE_TURF:
        field = ["#2F6BE0", "#1F4FC0"]
    dot2 = color.dim(p, 50) if is_whiteish(sec) else sec
    leg = {
        "S": p, "T": color.dim(p, 82), "s": color.dim(p, 62),
        "c": "#F4F7FF", "d": dot2,
        "R": sec if not is_whiteish(sec) else "#D8DDE6",
        "E": color.dim(p, 38), "e": color.dim(p, 18),
        "G": field[0], "g": field[1], "W": "#E8F0E8",
        "Z": sec if not is_whiteish(sec) else color.dim(p, 75),
        "P": "#7A808C", "L": "#FFF6C8",
        "B": "#3C4250", "b": "#FFB000",
        "K": "#8C919B", "k": "#78C8FF",
        "O": "#C8CDD7", "o": "#8C91A0", "h": "#F0F4FA",
        # Georgia's hedge ring: privet green, darker than both field stripes.
        "H": "#0A5A1E",
        # Backdrops: slate mountains with snowcaps, and stars.
        "M": "#6A7898", "w": "#F0F4FF", "n": "#FFF6C8",
    }
    if s["key"] in CHECKER:
        # Neyland's end zones: orange and white squares.
        leg["Z"] = p
        leg["z"] = "#FFFFFF"
    if s["key"] in NIGHT:
        # Saturday night: the light towers burn brighter.
        leg["L"] = "#FFFFFF"
    return leg

FIELD_CH = "gGWZ"
STAND_CH = "sSTdc"

def backdrop_for(s):
    """Rows of what shows through the empty corners of the art: the
    mountains, the night sky, or nothing. The renderer paints a sprite's
    '.' too, so the backdrop is stamped into the art string rather than
    drawn underneath it."""
    rows = [""] * 26
    src = ""
    if s["key"] in PEAKS:
        src = MOUNTAINS
    elif s["key"] in NIGHT:
        src = NIGHT_SKY
    if src != "":
        m = src.strip("\n").split("\n")
        for r in range(len(m)):
            rows[r] = m[r]
    return rows

def art_for(s):
    """The build's string art, with the school's tell stamped in: the
    checkerboard end zones, the hedge ring, and the backdrop."""
    art = ART[s["build"]]
    checker = s["key"] in CHECKER
    hedges = s["key"] in HEDGES
    back = backdrop_for(s)
    rows = art.strip("\n").split("\n")
    out = []
    for r in range(len(rows)):
        row = rows[r]
        bk = back[r] if r < len(back) else ""
        chars = []
        for i in range(len(row)):
            ch = row[i]
            if s["build"] == "BOWL" and r <= 3 and (ch == "B" or ch == "b"):
                # The bowl's own little video board makes way for the big
                # marquee board drawn over the far stands.
                ch = "."
            if ch == ".":
                if i < len(bk):
                    ch = bk[i]
            elif checker and ch == "Z" and (r + i) % 2 == 0:
                ch = "z"
            elif hedges and STAND_CH.find(ch) >= 0:
                near = [
                    row[i - 1] if i > 0 else ".",
                    row[i + 1] if i + 1 < len(row) else ".",
                    rows[r - 1][i] if r > 0 else ".",
                    rows[r + 1][i] if r + 1 < len(rows) else ".",
                ]
                for n in near:
                    if n != "." and FIELD_CH.find(n) >= 0:
                        ch = "H"
                        break
            chars.append(ch)
        out.append("".join(chars))
    return "\n" + "\n".join(out) + "\n"

def widen(art):
    """Stretch 52-column string art to ART_W by repeating the slice of
    columns SLICE_A..SLICE_B-1 SLICE_N more times, in the middle of the
    field. Plain repetition would line the crowd dots up in columns every 12
    px, so in each repeat a dot is swapped for another cell of the same row's
    slice, and a seat here and there lights up as a dot."""
    rows = art.strip("\n").split("\n")
    w = SLICE_B - SLICE_A
    out = []
    for r in range(len(rows)):
        row = rows[r] + "." * (52 - len(rows[r]))
        sl = row[SLICE_A:SLICE_B]
        ext = []
        for k in range(SLICE_N):
            for j in range(w):
                ch = sl[j]
                if "cde".find(ch) >= 0:
                    ch = sl[(j + 5 * (k + 1) + r) % w]
                    if FIELD_CH.find(ch) >= 0 or ch == "z" or ch == "H":
                        ch = sl[j]
                elif "sSTE".find(ch) >= 0 and (k * 7 + j * 3 + r * 5) % 23 == 0:
                    ch = {"s": "c", "S": "c", "T": "d", "E": "e"}[ch]
                ext.append(ch)
        out.append(row[:SLICE_B] + "".join(ext) + row[SLICE_B:])
    return "\n" + "\n".join(out) + "\n"

def flag(c, s):
    """The school flag, flying over the right end of the stands: a grey pole
    from the top of the panel down into the stands and a black cloth edged
    in the school colour round the 24 x 18 logo (drawn unscaled)."""
    edge = s["c"][1] if not is_whiteish(s["c"][1]) else s["c"][0]
    c.rect(FLAG_POLE, 0, FLAG_POLE, 21, fill = "#9AA0AC")
    c.rect(FLAG_X, 0, FLAG_X + FLAG_W - 1, FLAG_H - 1, fill = "black", outline = edge)
    c.image(LOGOS[s["key"]], FLAG_X + 1, 1)

def stadium_art(c, s):
    # A bitmap op holds at most 4096 cells and 160 x 26 is 4160, so the art
    # goes down in two bands of 13 rows.
    rows = widen(art_for(s)).strip("\n").split("\n")
    leg = legend_for(s)
    c.sprite("\n" + "\n".join(rows[:13]) + "\n", ART_X, ART_Y, legend = leg)
    c.sprite("\n" + "\n".join(rows[13:]) + "\n", ART_X, ART_Y + 13, legend = leg)

    # The lake or the river the fans come in on, lapping at the foot of the
    # stadium.
    if s["key"] in WATER:
        c.sprite(widen(WAVES), ART_X, 30, legend = {"b": "#2A7FD8", "B": "#1A4FA0", "W": "#A8E4FF"})

def balance2(c, text, font, maxw, lines):
    """Re-break a two-line hero_wrap result at the break (after a space or a
    hyphen) that makes the longer line shortest: 'THE HOUSE' / 'ROCKNE
    BUILT' on a centred board, not 'THE HOUSE ROCKNE' / 'BUILT'."""
    if len(lines) != 2:
        return lines
    toks = []
    for w in [x for x in str(text).split(" ") if x != ""]:
        parts = w.split("-")
        for i in range(len(parts)):
            toks.append([parts[i] + ("-" if i < len(parts) - 1 else ""), " " if i == 0 else ""])
    best = lines
    bw = max(c.text_width(lines[0], font), c.text_width(lines[1], font))
    for k in range(1, len(toks)):
        a = toks[0][0]
        for t in toks[1:k]:
            a += t[1] + t[0]
        b = toks[k][0]
        for t in toks[k + 1:]:
            b += t[1] + t[0]
        wa = c.text_width(a, font)
        wb = c.text_width(b, font)
        if wa <= maxw and wb <= maxw and max(wa, wb) < bw:
            best = [a, b]
            bw = max(wa, wb)
    return best

def board_lines(c, hero):
    """The hero on the video board: [font, [lines]]. One line of 6x8 when it
    fits the board, else one of 5x7, else two lines of 5x7 broken after a
    hyphen or a space (hero_wrap: 'VAUGHT-' / 'HEMINGWAY'), else 4x5."""
    inner = BOARD_R - BOARD_L + 1 - 6
    for f in ["6x8", "5x7"]:
        if c.text_width(hero, f) <= inner:
            return [f, [hero]]
    lines = hero_wrap(c, hero, "5x7", inner)
    if lines != None and len(lines) <= 2:
        return ["5x7", balance2(c, hero, "5x7", inner, lines)]
    return ["4x5", wrap(c, hero, "4x5", inner)[:2]]

def video_board(c, s):
    """The stadium's video board, hung over the far stands on two struts:
    black face, a frame in the school colour studded with marquee bulbs,
    and the name people call the place in white."""
    p = s["c"][0]
    got = board_lines(c, s["hero"])
    f = got[0]
    lines = got[1]
    h = {"6x8": 8, "5x7": 7, "4x5": 5}[f]
    tw = 0
    for ln in lines:
        tw = max(tw, c.text_width(ln, f))
    bw = tw + 6
    if bw % 2 == 0:
        bw += 1
    x0 = MID - bw // 2
    x1 = x0 + bw - 1
    y1 = 2 + len(lines) * (h + 1)

    # struts from the board down into the far stands
    for sx in [x0 + 5, x1 - 5]:
        c.rect(sx, y1 + 1, sx, y1 + 3, fill = "#5A606C")
    c.rect(x0, 0, x1, y1, fill = "black", outline = p)
    bulb = "#FFF1B0"
    for x in range(x0, x1 + 1, 3):
        c.pixel(x, 0, bulb)
        c.pixel(x, y1, bulb)
    for y in range(0, y1 + 1, 3):
        c.pixel(x0, y, bulb)
        c.pixel(x1, y, bulb)
    for i in range(len(lines)):
        c.text(lines[i], MID, 2 + i * (h + 1), font = f, color = INK, align = "center")

def sign(c, x, w, fill, frame):
    c.rect(x, PLAQUE_Y - 1, x + w - 1, PLAQUE_Y + 7, fill = fill, outline = frame)

def facade(c, s, ctx):
    """Signs on the stadium's base, y 23..31: the crowd on the left, the
    bronze dedication plaque beside it. On alternate refreshes the left sign
    carries the record crowd and a right-hand one its year. The plaque keeps its contrast fix: 9 rows, a dark row
    either side of the 4x5 text, a dim bronze frame and bright gold letters
    ('EST' in 3x4 read as 'FST' at 5x)."""
    tcol = s["c"][1] if not is_whiteish(s["c"][1]) else s["c"][0]
    yr = str(s["open"])
    est_w = c.text_width("EST", "4x5")
    pw = est_w + 3 + c.text_width(yr, "4x5") + 6

    # What goes on the side signs: [kind, text].
    left = None
    right = None
    rec = s.get("rec")
    frame = (ctx.now.unix // REFRESH) % 2
    if rec != None and (s["cap"] <= 0 or frame == 1):
        left = ["rec", commas(rec[0])]
        right = ["year", "IN " + str(rec[1])]
    elif s["cap"] > 0:
        left = ["cap", commas(s["cap"])]
    else:
        # No number we could verify: the place instead of a hole.
        left = ["alt", s.get("tag", s["short"])]

    lw = 0
    if left != None:
        if left[0] == "cap" or left[0] == "rec":
            lw = c.text_width("CAP" if left[0] == "cap" else "REC", "4x5") + 3 + c.text_width(left[1], "4x5") + 6
        else:
            lw = c.text_width(left[1], "4x5") + 6
    rw = 0
    if right != None:
        rw = c.text_width(right[1], "4x5") + 6

    # The row of signs sits centred on the base; a side sign too wide for its
    # half pushes the row over rather than getting cut.
    total = (lw + 4 if lw > 0 else 0) + pw + (4 + rw if rw > 0 else 0)
    px = MID - total // 2 + (lw + 4 if lw > 0 else 0)
    if lw > 0 and px - 4 - lw < 8:
        px = 8 + lw + 4
    if rw > 0 and px + pw + 4 + rw - 1 > 183:
        px = 183 - rw - 4 - pw + 1

    if left != None:
        lx = px - 4 - lw
        sign(c, lx, lw, "#0A0D14", "#5A6478")
        if left[0] == "cap" or left[0] == "rec":
            # 'CAP 107,601' / 'REC 115,109': the label in the school's
            # colour
            lab = "CAP" if left[0] == "cap" else "REC"
            c.text(lab, lx + 3, PLAQUE_Y, font = "4x5", color = tcol if left[0] == "cap" else DIM)
            c.text(left[1], lx + 3 + c.text_width(lab, "4x5") + 3, PLAQUE_Y, font = "4x5", color = INK)
        else:
            c.text(left[1], lx + 3, PLAQUE_Y, font = "4x5", color = INK)

    sign(c, px, pw, "#160C02", "#9A6A2A")
    c.text("EST", px + 3, PLAQUE_Y, font = "4x5", color = "#F0B860")
    c.text(yr, px + 3 + est_w + 3, PLAQUE_Y, font = "4x5", color = "#FFE9A8")

    if right != None:
        rx = px + pw + 4
        sign(c, rx, rw, "#0A0D14", "#5A6478")
        c.text(right[1], rx + 3, PLAQUE_Y, font = "4x5", color = DIM)

def stadium(c, ctx):
    s = pick_school(ctx)
    c.fill("black")
    stadium_art(c, s)
    flag(c, s)
    video_board(c, s)
    facade(c, s, ctx)

def top_line(c, s, maxw):
    """The official name when the hero is a nickname and the name fits;
    otherwise the city. The panel fonts have no '&' glyph, so 'JONES AT&T
    STADIUM' falls back to the city too."""
    if s["hero"] != s["name"] and s["name"].find("&") < 0 and c.text_width(s["name"], "4x5") <= maxw:
        return s["name"]
    return s["city"]

def gameday(c, ctx):
    """Close up on the video board: its two side rails in the school colour
    with marquee bulbs, a header with the story's icon, category pill and
    the stadium's official name (or city) in the school's second colour,
    and the story in white across the full width."""
    s = pick_school(ctx)
    facts = s["facts"]
    n = len(facts)
    idx = (ctx.now.unix // REFRESH) % n
    f = facts[idx]
    kind = STORY_KIND[f[0]]
    c.fill("black")
    p = s["c"][0]
    sec = s["c"][1]
    tcol = sec if not is_whiteish(sec) else p

    for x in [RAIL_L, RAIL_R]:
        c.rect(x, 0, x, 31, fill = p)
        for y in range(1, 32, 3):
            c.pixel(x, y, "#FFF1B0")

    # Header y 0..6: icon, the category pill, the stadium name, the counter.
    leg = dict(ICON_FIXED)
    leg["X"] = kind[1]
    c.sprite(STORY_ICONS[f[0]], TL, 0, legend = leg)
    cnt = str(idx + 1) + "/" + str(n)
    c.text(cnt, TR, 1, font = "4x5", color = DIM, align = "right")
    px = TL + 10
    pw = c.text_width(kind[0], "4x5") + 4
    c.badge(kind[0], px, 0, color = ink_for(p), bg = p, font = "4x5")
    nx = px + pw + 4
    room = TR - c.text_width(cnt, "4x5") - 5 - nx
    top = top_line(c, s, room)
    if c.text_width(top, "4x5") > room:
        top = s["short"] if c.text_width(s["short"], "4x5") <= room else ""
    if top != "":
        c.text(top, nx, 1, font = "4x5", color = tcol)

    # The story: up to three lines of 5x7 across x 9..182; 4x5 is the
    # fallback, and every story ships sized for 5x7.
    maxw = TR - TL + 1
    lines = wrap(c, f[1], "5x7", maxw)
    if len(lines) <= 3:
        y0 = [0, 16, 12, 8][len(lines)]
        for i in range(len(lines)):
            c.text(lines[i], TL, y0 + i * 8, font = "5x7", color = INK)
        return
    lines = wrap(c, f[1], "4x5", maxw)
    for i in range(min(3, len(lines))):
        c.text(lines[i], TL, 10 + i * 7, font = "4x5", color = INK)
