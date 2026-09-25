# College Stadium Gameday
#
# The building a college football Saturday happens in: the stadium's name
# and nickname, how many it holds, when it opened, and the stories that
# make the place loud - record crowds, famous finishes, fans who arrive by
# boat, a crowd that registered on a seismograph.
#
#   stadium  The stadium card: school logo, a pixel-art stadium in the
#            school's colours, the nickname as the hero, the capacity with
#            its FBS size rank (or the record crowd), and a bronze plaque
#            with the year it opened.
#   gameday  One gameday story at a time, with an icon saying what kind of
#            story it is (NOISE, RECORD CROWD, ON THE WATER, FAMOUS PLAY...).
#
# DESIGN. Graphics first. The stadium is the star: a 52 x 26 three-quarter
# view drawn from string art - the rim of stands in the school's colours
# with a scatter of crowd dots, tiered rows on the near side, a mowed field
# with yard lines and end zones, an arched base below, and light towers
# standing over the corners. Four builds, each with a tell a fan can read
# from across the room: BOWL (a video board over the far stands), HORSESHOE
# (one end open, the scoreboard standing in the gap), DOUBLE (an upper deck
# ringing the bowl in the second school colour, a press box on top) and
# DOME (a ribbed roof with a highlight). Then the place itself: Neyland's
# orange-and-white checkerboard end zones, the hedge ring at Sanford, a
# crescent moon and stars over Death Valley, snowcapped peaks behind
# Boulder, the Academy, Provo and Salt Lake, a strip of water under the
# stadiums fans reach by boat or sit on a river, and Boise's blue field.
#
# The one loud element is the bronze dedication plaque hung on the base of
# every stadium - "EST 1927" - the way the real buildings carry their
# date. The school logo sits left at 40 x 24; the text column on the right
# is quiet: the official name (or the city) in the school's second colour,
# the nickname in white, then a crowd icon, the listed capacity and, for
# the 12 biggest, a gold "#1 IN FBS" pill. On alternate refreshes that row
# shows the record crowd instead ("REC 115,109 2013"); a stadium whose
# capacity we could not verify always shows its record (or its setting).
#
# The gameday page keeps the logo, adds a two-tone bar in the school's
# colours, and gives the story a 7 x 7 icon and a category pill so a viewer
# knows what kind of story it is before reading a word. Stories are sized
# to three lines of 5x7 in the 133 px text zone (4x5 when a line runs long);
# every story of every school is rendered and checked to fit without a cut.
#
# No network: the data below is baked in. ALL SCHOOLS changes school every
# 20 minutes so both pages always show the same school; a story changes on
# every refresh.

REFRESH = 120
SCHOOL_SECS = 1200

# ------------------------------------------------------------------ layout
LOGO_X = 6
LOGO_Y = 4
ART_X = 49         # 52 x 26 stadium, x 49..100
ART_Y = 3
TX = 103           # stadium text column x 103..185 (83 px); the art ends at x 99
TR = 185
GX = 53            # gameday text zone x 53..185 (133 px)
BAR_X = 48

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
ART = {"BOWL": BOWL, "HORSESHOE": HORSESHOE, "DOUBLE": DOUBLE, "DOME": DOME}

# 5 x 5 icons for the stadium card's numbers.
ICON_CROWD = """
.X.X.
XXXXX
.X.X.
XXXXX
XXXXX
"""
ICON_CAL = """
.X.X.
XXXXX
X...X
X.X.X
XXXXX
"""

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
    "MICHIGAN": "MICH.png",
    "PENN STATE": "PSU.png",
    "OHIO STATE": "OSU.png",
    "TEXAS A&M": "TAMU.png",
    "LSU": "LSU.png",
    "TENNESSEE": "TENN.png",
    "ALABAMA": "ALA.png",
    "TEXAS": "TEX.png",
    "GEORGIA": "UGA.png",
    "USC": "USC.png",
    "NEBRASKA": "NEB.png",
    "FLORIDA": "FLA.png",
    "AUBURN": "AUB.png",
    "OKLAHOMA": "OU.png",
    "CLEMSON": "CLEM.png",
    "NOTRE DAME": "ND.png",
    "WISCONSIN": "WIS.png",
    "OREGON": "ORE.png",
    "WASHINGTON": "WASH.png",
    "IOWA": "IOWA.png",
    "MICHIGAN STATE": "MSU.png",
    "FLORIDA STATE": "FSU.png",
    "MIAMI": "MIA.png",
    "OLE MISS": "MISS.png",
    "MISSISSIPPI STATE": "MSST.png",
    "ARKANSAS": "ARK.png",
    "SOUTH CAROLINA": "SC.png",
    "KENTUCKY": "UK.png",
    "TEXAS TECH": "TTU.png",
    "BAYLOR": "BAY.png",
    "KANSAS STATE": "KSU.png",
    "WEST VIRGINIA": "WVU.png",
    "UTAH": "UTAH.png",
    "BYU": "BYU.png",
    "ARIZONA STATE": "ASU.png",
    "STANFORD": "STAN.png",
    "CALIFORNIA": "CAL.png",
    "UCLA": "UCLA.png",
    "VIRGINIA TECH": "VT.png",
    "NORTH CAROLINA": "UNC.png",
    "SYRACUSE": "SYR.png",
    "ARMY": "ARMY.png",
    "NAVY": "NAVY.png",
    "BOISE STATE": "BOIS.png",
    "MINNESOTA": "MINN.png",
    "ILLINOIS": "ILL.png",
    "RUTGERS": "RUTG.png",
    "DUKE": "DUKE.png",
    "GEORGIA TECH": "GT.png",
    "PITTSBURGH": "PITT.png",
    "IOWA STATE": "ISU.png",
    "INDIANA": "IU.png",
    "COLORADO": "COLO.png",
    "TCU": "TCU.png",
    "MISSOURI": "MIZ.png",
    "OKLAHOMA STATE": "OKST.png",
    "PURDUE": "PUR.png",
    "AIR FORCE": "AFA.png",
}

KEYS = [s["key"] for s in SCHOOLS]
BY_KEY = {s["key"]: s for s in SCHOOLS}

# Size rank by listed capacity, sorted at load so a capacity edit re-ranks.
# Only the top 12 are shown: every FBS home stadium over 88,000 is in this
# table (Nebraska, 85,458, is next), so ranks 1-12 hold for the whole FBS,
# while lower ranks would be thrown off by stadiums the app doesn't carry.
RANK_MAX = 12
_BY_CAP = sorted([s for s in SCHOOLS if s["cap"] > 0], key = lambda s: -s["cap"])
RANK = {_BY_CAP[i]["key"]: i + 1 for i in range(len(_BY_CAP))}

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
PLAQUE_Y = 24      # y 24..30: art rows 21..27, the arched base under the seats

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

def school_mark(c, s):
    c.image(LOGOS[s["key"]], LOGO_X, LOGO_Y)

def stadium_art(c, s):
    key = s["key"]
    c.sprite(art_for(s), ART_X, ART_Y, legend = legend_for(s))
    # Under it: the lake or the river the fans come in on.
    if key in WATER:
        c.sprite(WAVES, ART_X, ART_Y + 26, legend = {"b": "#2A7FD8", "B": "#1A4FA0", "W": "#A8E4FF"})
    # The dedication plaque on the facade: bronze, "EST" and the year, hung
    # on the base of the bowl below the seats. (3x4 read as "FST" at 5x,
    # so both words are 4x5: 'EST 1927' is 34 px, 40 with the frame.)
    yr = str(s["open"])
    est_w = c.text_width("EST", "4x5")
    w = est_w + 3 + c.text_width(yr, "4x5") + 6
    px = ART_X + 26 - w // 2
    # The letters touched the bronze frame top and bottom and ran into it at
    # 1x, so the plaque is 9 rows (y 23..31) with a dark row either side of
    # the text, a dimmer frame, and bright gold letters.
    c.rect(px, PLAQUE_Y - 1, px + w - 1, PLAQUE_Y + 7, fill = "#160C02", outline = "#9A6A2A")
    c.text("EST", px + 3, PLAQUE_Y + 1, font = "4x5", color = "#F0B860")
    c.text(yr, px + 3 + est_w + 3, PLAQUE_Y + 1, font = "4x5", color = "#FFE9A8")

def stadium(c, ctx):
    s = pick_school(ctx)
    c.fill("black")
    school_mark(c, s)
    stadium_art(c, s)

    maxw = TR - TX + 1
    # The official name when the hero is a nickname and the name fits the
    # column; otherwise the city ('BRYANT-DENNY STADIUM' is 94 px here).
    top = s["city"]
    # The panel fonts have no "&" glyph, so a name carrying one ('JONES
    # AT&T STADIUM') falls back to the city too.
    if s["hero"] != s["name"] and s["name"].find("&") < 0 and c.text_width(s["name"], "4x5") <= maxw:
        top = s["name"]
    tcol = s["c"][1] if not is_whiteish(s["c"][1]) else s["c"][0]
    c.text(clip(c, top, "4x5", maxw), TX, 1, font = "4x5", color = tcol)

    # Hero band y 7..24: one line of 8x10 when it fits, else two of 6x8
    # (rows 7..14 and 16..23, so the numbers row at 25 keeps its 1 px gap),
    # else two of 5x7.
    hero = s["hero"]
    drawn = False
    for f in ["8x10", "7x10"]:
        if c.text_width(hero, f) <= maxw:
            c.text(hero, TX, 11, font = f, color = INK)
            drawn = True
            break
    if not drawn:
        for f, h in [["6x8", 8], ["5x7", 7]]:
            lines = hero_wrap(c, hero, f, maxw)
            if lines != None and len(lines) <= 2:
                y0 = 7 if len(lines) == 2 else 12
                for i in range(len(lines)):
                    c.text(lines[i], TX, y0 + i * (h + 1), font = f, color = INK)
                drawn = True
                break
    if not drawn:
        lines = wrap(c, hero, "4x5", maxw)
        for i in range(min(3, len(lines))):
            c.text(lines[i], TX, 7 + i * 6, font = "4x5", color = INK)

    # Numbers row y 26..30 (the rank pill fills 25..31). Two frames on the
    # refresh timer: the capacity with its FBS size rank, then the record
    # crowd. A stadium with no verified capacity shows its record every time.
    rec = s.get("rec")
    frame = (ctx.now.unix // REFRESH) % 2
    if rec != None and (s["cap"] <= 0 or frame == 1):
        c.text("REC", TX, 26, font = "4x5", color = DIM)
        x = TX + c.text_width("REC", "4x5") + 3
        c.text(commas(rec[0]), x, 26, font = "4x5", color = INK)
        x += c.text_width(commas(rec[0]), "4x5") + 3
        if x + c.text_width(str(rec[1]), "4x5") <= TR:
            c.text(str(rec[1]), x, 26, font = "4x5", color = DIM)
    elif s["cap"] > 0:
        # 'CROWD 102,780 #3 IN FBS' is 82 px: the icon (5) + 1, the number,
        # 2 px, then the pill - it overran the old 81 px column (x 105) and
        # fell back to a bare '#3', so the column now starts at x 103.
        # Ranks 10-12 carry five-digit capacities: '#10 IN FBS' fits too.
        c.sprite(ICON_CROWD, TX, 26, legend = {"X": tcol})
        x = TX + 6
        c.text(commas(s["cap"]), x, 26, font = "4x5", color = INK)
        x += c.text_width(commas(s["cap"]), "4x5") + 2
        rk = RANK.get(s["key"], 99)
        if rk <= RANK_MAX:
            label = "#" + str(rk) + " IN FBS"
            w = c.text_width(label, "4x5") + 4
            # A bare '#2' would be a magic number, so a pill that can't
            # say IN FBS is left off rather than shortened.
            if x + w - 1 <= TR:
                c.rect(x, 25, x + w - 1, 31, fill = "#FFD24A")
                c.text(label, x + 2, 26, font = "4x5", color = "black")
    else:
        # No number we could verify: the place instead of a hole.
        alt = s.get("tag", s["short"])
        if alt != top:
            c.text(clip(c, alt, "4x5", maxw), TX, 26, font = "4x5", color = DIM)

def gameday(c, ctx):
    s = pick_school(ctx)
    facts = s["facts"]
    n = len(facts)
    idx = (ctx.now.unix // REFRESH) % n
    f = facts[idx]
    kind = STORY_KIND[f[0]]
    c.fill("black")
    school_mark(c, s)
    p = s["c"][0]
    sec = s["c"][1]
    c.rect(BAR_X, 0, BAR_X, 31, fill = p)
    c.rect(BAR_X + 1, 0, BAR_X + 1, 31, fill = sec if not is_whiteish(sec) else "#D8DDE6")

    # Chip row y 0..6: the story's icon, the category pill in the school
    # colour, the stadium's short name when it fits whole, and the counter.
    leg = dict(ICON_FIXED)
    leg["X"] = kind[1]
    c.sprite(STORY_ICONS[f[0]], GX, 0, legend = leg)
    cnt = str(idx + 1) + "/" + str(n)
    c.text(cnt, TR, 1, font = "4x5", color = DIM, align = "right")
    px = GX + 10
    pw = c.text_width(kind[0], "4x5") + 4
    c.badge(kind[0], px, 0, color = ink_for(p), bg = p, font = "4x5")
    room = TR - c.text_width(cnt, "4x5") - 5 - (px + pw + 4)
    if c.text_width(s["short"], "4x5") <= room:
        c.text(s["short"], px + pw + 4, 1, font = "4x5", color = DIM)

    # The story: up to three lines of 5x7 across x 53..185; 4x5 is the
    # fallback, and every story ships sized for 5x7.
    maxw = TR - GX + 1
    lines = wrap(c, f[1], "5x7", maxw)
    if len(lines) <= 3:
        y0 = [0, 16, 12, 8][len(lines)]
        for i in range(len(lines)):
            c.text(lines[i], GX, y0 + i * 8, font = "5x7", color = INK)
        return
    lines = wrap(c, f[1], "4x5", maxw)
    for i in range(min(3, len(lines))):
        c.text(lines[i], GX, 10 + i * 7, font = "4x5", color = INK)
