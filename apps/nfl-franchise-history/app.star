# NFL Franchise History
#
# Every club's story on a felt pennant: where it came from, what it has won,
# and the stories its fans still tell.
#
#   legacy  The club's pennant. A felt pennant in club colours flies from a
#           wooden stick across the panel, the nickname stitched along it.
#           Above the tail: the home market, the year the club was founded
#           and the year of its last title. Under the tail stands the trophy
#           haul - one silver Lombardi per Super Bowl win, a dim ghost
#           Lombardi for every Super Bowl lost - with the SB record and a
#           bronze cup for NFL / AFL titles won outside a Super Bowl.
#   trivia  One frame per minute. Most frames are a true story from the
#           club's history, its year stitched on a short pennant; one is the
#           rivalry card (club pennant, the all-time series, the rival's
#           logo) and one is the club's most famous retired jersey.
#
# DESIGN. The hanging pennant is the one memorable thing: a 30 px tall felt
# triangle in the club's colour with a trim-coloured sleeve at the stick and
# a trim edge, flying from x 8 to a point at x 170. The nickname is stitched
# in ONE face per name - the biggest of 10x16 / 9x12 / 8x10 / 6x8 / 5x7 /
# 4x5 in which every letter, at its own place along the taper, clears the
# trim by a felt row - so short names (BILLS, RAMS, 49ERS) get 10x16 and
# long ones step down as a whole word, never letter by letter (a per-letter
# step-down read as mixed case). Every other item lives in the two black
# triangles the tapering cloth leaves free: market / EST / last title
# right-aligned above the tail, the Lombardis standing under the tip and the
# SB record and cup on the floor row beside them. Nothing sits at a fixed x:
# each row's left limit is computed from the cloth, so no text can touch the
# felt. No logo column - the club is its colours and its stitched name.
#
# Trophies: silver Lombardis for wins, dim ghosts for losses, so the Bills'
# four trips read as four ghosts rather than an empty case. They stand 6 px
# apart under the tip, 5 px when eight need the room; New England's twelve
# do not fit, so it shows its six wins and the record says 6-6. Clubs with
# no Super Bowl trip say so in the trophy spot.
#
# Trivia: the story frame is a short pennant (stick at x 6, tip x 74) with
# the story's year stitched in one face and the story in three lines of 5x7
# (4x7 when 5x7 needs a fourth line) beside the tail, DID YOU KNOW and 2x2
# frame pips on the top row. The rivalry frame keeps the club's short
# pennant (tip x 64, abbreviation stitched) facing the rival's logo, the
# W-L-T series between them. The legend frame is a pixel jersey in club
# colours.
#
# No network: everything is baked in, so there is nothing to fail. Super Bowl
# counts run through Super Bowl LX (February 2026); head-to-head series run
# through the 2025 season, playoffs included. Years are the year the game
# was played, so a Super Bowl belongs to the February it was won in.
#
# Frames: the trivia page rotates one frame per minute, and ALL TEAMS moves
# to the next club every 10 minutes (so the legacy pennant and the trivia
# beside it always agree). Hence refresh 60.

# ------------------------------------------------------------------ layout
POLE_X = 6          # the pennant stick, x 6..7
PX0 = 8             # the pennant's sleeve (wide end) starts here
SLEEVE = 4          # sleeve columns, x 8..11
TOP0 = 1            # the cloth spans rows 1..30 at the sleeve
BOT0 = 30
TIP = 170           # legacy pennant tip
TTIP = 74           # story pennant tip
RTIP = 64           # rivalry pennant tip (it carries only the abbreviation)
LET_X = 13          # first stitched letter (x 12 is the felt gap after the sleeve)
R = 185             # right edge of content (lit pixels stay in x 6..185)
STORY_X = 76        # story column x 76..185 (110 px)
RIVAL_X = 145       # rival logo, x 145..184

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#7A849C"
GOLD = "#FFC53D"
BRONZE = "#D98A3D"
PIP_OFF = "#3A4152"
WOOD = "#C08A4E"
WOOD_D = "#7A5028"

# Pennant cloth per club: [felt, stitched letters, trim]. Dark club colours
# are lifted so the cloth still reads as a shape on the LED; black clubs get
# a charcoal felt.
PEN = {
    "ARI": ["#B0142F", "#FFFFFF", "#FFC53D"], "ATL": ["#C8102E", "#FFFFFF", "#A5ACAF"],
    "BAL": ["#4B2CA0", "#FFC53D", "#FFC53D"], "BUF": ["#1F4FC8", "#FFFFFF", "#E8203F"],
    "CAR": ["#0077B8", "#FFFFFF", "#A5ACAF"], "CHI": ["#23407A", "#FF6A2A", "#FF6A2A"],
    "CIN": ["#E8480F", "#FFFFFF", "#FFFFFF"], "CLE": ["#7A4526", "#FF7A1F", "#FF7A1F"],
    "DAL": ["#244A8C", "#FFFFFF", "#B0B7BC"], "DEN": ["#E8480F", "#FFFFFF", "#2A4580"],
    "DET": ["#0070AE", "#FFFFFF", "#B0B7BC"], "GB": ["#1F6B45", "#FFB612", "#FFB612"],
    "HOU": ["#23407A", "#FFFFFF", "#E8233C"], "IND": ["#1F4FAE", "#FFFFFF", "#FFFFFF"],
    "JAX": ["#00808F", "#FFFFFF", "#D7A22A"], "KC": ["#D0142F", "#FFFFFF", "#FFB81C"],
    "LV": ["#3A3F45", "#D5DADD", "#A5ACAF"], "LAC": ["#0074B5", "#FFFFFF", "#FFC20E"],
    "LAR": ["#1F4FC8", "#FFD100", "#FFD100"], "MIA": ["#008089", "#FFFFFF", "#FC6A1C"],
    "MIN": ["#5C34A0", "#FFC62F", "#FFC62F"], "NE": ["#1F3D7A", "#FFFFFF", "#D0142F"],
    "NO": ["#3A3530", "#D3BC8D", "#D3BC8D"], "NYG": ["#1F3FA0", "#FFFFFF", "#D0142F"],
    "NYJ": ["#1A7A55", "#FFFFFF", "#FFFFFF"], "PHI": ["#0E6E73", "#FFFFFF", "#B0B7BC"],
    "PIT": ["#383C44", "#FFB612", "#FFB612"], "SF": ["#B8102A", "#FFFFFF", "#C9A866"],
    "SEA": ["#26468F", "#FFFFFF", "#69BE28"], "TB": ["#C20A0A", "#FFFFFF", "#FF7900"],
    "TEN": ["#3F80C8", "#FFFFFF", "#E8203F"], "WSH": ["#7E1C27", "#FFB612", "#FFB612"],
}

# ------------------------------------------------------------------ logos
# Literal paths: the publish lint needs to see every asset name. Only
# the clubs named as someone's rival (RIVAL below) are drawn.
LOGO = {
    "ARI": "assets/ARI.png", "ATL": "assets/ATL.png", "BAL": "assets/BAL.png",
    "BUF": "assets/BUF.png", "CHI": "assets/CHI.png", "CLE": "assets/CLE.png",
    "DAL": "assets/DAL.png", "DEN": "assets/DEN.png", "DET": "assets/DET.png",
    "GB": "assets/GB.png", "JAX": "assets/JAX.png", "KC": "assets/KC.png",
    "LV": "assets/LV.png", "LAR": "assets/LAR.png", "MIA": "assets/MIA.png",
    "NE": "assets/NE.png", "NO": "assets/NO.png", "NYJ": "assets/NYJ.png",
    "PHI": "assets/PHI.png", "PIT": "assets/PIT.png", "SF": "assets/SF.png",
    "SEA": "assets/SEA.png", "TEN": "assets/TEN.png",
}

# Club accent colours, lifted for the LED where the real one is too dark.
ACCENT = {
    "ARI": "#E0304F", "ATL": "#E8243C", "BAL": "#7B5CE8", "BUF": "#2A6BFF",
    "CAR": "#19A6F0", "CHI": "#FF5A1F", "CIN": "#FF6A1F", "CLE": "#FF4E10",
    "DAL": "#3D7BFF", "DEN": "#FF5A14", "DET": "#1C9BE8", "GB": "#FFB612",
    "HOU": "#E8233C", "IND": "#3D86E8", "JAX": "#00A5B8", "KC": "#FF2447",
    "LV": "#C4CACD", "LAC": "#2AA8F0", "LAR": "#FFD100", "MIA": "#00C2CC",
    "MIN": "#8F5BE8", "NE": "#E8203F", "NO": "#D3BC8D", "NYG": "#2A5FE0",
    "NYJ": "#1FA36E", "PHI": "#0FA0A8", "PIT": "#FFB612", "SF": "#E8201F",
    "SEA": "#69BE28", "TB": "#F0263A", "TEN": "#4B92DB", "WSH": "#B8323A",
}

# ------------------------------------------------------------------- data
# abbr -> [nickname, home market, founded, Super Bowl wins,
#          other league titles, "NFL" or "AFL", stories]
# Other titles are NFL or AFL championships the club won outside a Super Bowl
# win (pre-1966, or a 1966-69 league title followed by a Super Bowl loss).
# AAFC titles (Browns 1946-49) are left out, as the NFL does not count them.
# A story is [year or "", text]; every text fits three 5x7 lines at 133 px.
CLUBS = {
    "ARI": ["CARDINALS", "ARIZONA", 1898, 0, 2, "NFL", [
        ["1898", "STARTED IN CHICAGO: THE OLDEST RUNNING PRO FOOTBALL CLUB IN THE US"],
        ["1901", "FADED MAROON JERSEYS, CALLED CARDINAL RED, GAVE THEM THEIR NAME"],
        ["1988", "MOVED FROM CHICAGO TO ST. LOUIS IN 1960, THEN TO ARIZONA IN 1988"],
        ["1944", "MERGED WITH PITTSBURGH AS CARD-PITT AND WENT 0-10"],
        ["2002", "PAT TILLMAN TURNED DOWN A NEW CONTRACT TO JOIN THE ARMY RANGERS"],
        ["2006", "THEIR STADIUM ROLLS ITS GRASS FIELD OUTSIDE TO SOAK UP THE SUN"],
    ]],
    "ATL": ["FALCONS", "ATLANTA", 1965, 0, 0, "NFL", [
        ["1965", "A TEACHER NAMED THEM IN A CONTEST: THE FALCON IS PROUD AND DIGNIFIED"],
        ["2017", "LED 28-3 IN SUPER BOWL LI, THEN LOST THE FIRST SUPER BOWL IN OT"],
        ["1998", "THE DIRTY BIRDS WENT 14-2 AND REACHED SUPER BOWL XXXIII"],
        ["2006", "MICHAEL VICK BECAME THE FIRST QB TO RUN FOR 1,000 YARDS IN A SEASON"],
        ["1992", "DEION SANDERS PLAYED FOR THE FALCONS AND THE BRAVES AT ONCE"],
        ["2017", "THEIR STADIUM ROOF OPENS IN A PINWHEEL, LIKE A CAMERA LENS"],
    ]],
    "BAL": ["RAVENS", "BALTIMORE", 1996, 2, 0, "NFL", [
        ["1996", "NAMED FOR THE RAVEN, A POEM BY BALTIMORE WRITER EDGAR ALLAN POE"],
        ["1996", "THE OLD BROWNS MOVED HERE BUT LEFT THEIR NAME IN CLEVELAND"],
        ["2000", "THE 2000 DEFENSE GAVE UP JUST 165 POINTS, A 16-GAME RECORD"],
        ["2013", "JOHN HARBAUGH BEAT HIS BROTHER JIM IN SUPER BOWL XLVII"],
        ["2013", "SUPER BOWL XLVII WAS HALTED 34 MINUTES BY A POWER OUTAGE"],
        ["2021", "JUSTIN TUCKER WON AT DETROIT WITH A 66-YARD KICK OFF THE CROSSBAR"],
        ["2013", "RAY LEWIS WON SUPER BOWLS 12 YEARS APART: XXXV AND XLVII"],
    ]],
    "BUF": ["BILLS", "BUFFALO", 1959, 0, 2, "AFL", [
        ["1994", "THE ONLY TEAM TO PLAY IN FOUR SUPER BOWLS IN A ROW, 1991 TO 1994"],
        ["1993", "THE COMEBACK: RALLIED FROM 35-3 DOWN TO BEAT HOUSTON IN THE PLAYOFFS"],
        ["1965", "WON BACK-TO-BACK AFL TITLES IN 1964 AND 1965"],
        ["1991", "WIDE RIGHT: A 47-YARD MISS AT THE GUN COST THEM SUPER BOWL XXV"],
        ["1959", "NAMED FOR BUFFALO BILL CODY, BY WAY OF A 1940S BUFFALO BILLS TEAM"],
        ["2010", "BILLS MAFIA, NAMED ON TWITTER IN 2010, IS KNOWN FOR TABLE DIVES"],
    ]],
    "CAR": ["PANTHERS", "CAROLINA", 1993, 0, 0, "NFL", [
        ["1996", "REACHED THE NFC TITLE GAME IN 1996, ONLY THEIR SECOND SEASON"],
        ["2004", "LOST SUPER BOWL XXXVIII TO NEW ENGLAND ON A KICK WITH 4 SECONDS LEFT"],
        ["2015", "CAM NEWTON WON MVP AS THE 2015 TEAM WENT 15-1"],
        ["1995", "PLAYED THEIR FIRST SEASON AT CLEMSON WHILE THEIR STADIUM WAS BUILT"],
        ["2003", "WENT 1-15 IN 2001, THEN REACHED THE SUPER BOWL TWO SEASONS LATER"],
        ["1959", "FOUNDER JERRY RICHARDSON ONCE PLAYED FOR THE BALTIMORE COLTS"],
    ]],
    "CHI": ["BEARS", "CHICAGO", 1920, 1, 8, "NFL", [
        ["1920", "STARTED AS THE DECATUR STALEYS, A STARCH COMPANY TEAM"],
        ["1922", "NAMED BEARS BECAUSE THEY SHARED WRIGLEY FIELD WITH THE CUBS"],
        ["1940", "BEAT WASHINGTON 73-0 IN THE 1940 TITLE GAME, THE BIGGEST ROUT EVER"],
        ["1985", "RECORDED THE SUPER BOWL SHUFFLE, THEN WON SUPER BOWL XX"],
        ["1967", "GEORGE HALAS FOUNDED THE CLUB AND COACHED IT FOR 40 SEASONS"],
        ["1987", "WALTER PAYTON RETIRED AS THE NFL ALL-TIME RUSHING LEADER"],
    ]],
    "CIN": ["BENGALS", "CINCINNATI", 1967, 0, 0, "NFL", [
        ["1968", "PAUL BROWN FOUNDED THEM AFTER BEING FIRED BY THE TEAM NAMED FOR HIM"],
        ["1967", "NAMED FOR CINCINNATI BENGALS TEAMS OF THE 1930S AND 40S"],
        ["1982", "WON THE FREEZER BOWL IN A WIND CHILL OF 59 BELOW ZERO"],
        ["1968", "BILL WALSH SHAPED THE WEST COAST OFFENSE AS A BENGALS ASSISTANT"],
        ["2022", "HAVE PLAYED IN THREE SUPER BOWLS, LOSING TWO TO THE 49ERS"],
        ["2019", "JOE BURROW AND JAMARR CHASE WON A COLLEGE TITLE TOGETHER AT LSU"],
    ]],
    "CLE": ["BROWNS", "CLEVELAND", 1944, 0, 4, "NFL", [
        ["1945", "NAMED FOR THEIR FIRST COACH, PAUL BROWN"],
        ["1949", "WON ALL FOUR AAFC TITLES, 1946 TO 1949, BEFORE JOINING THE NFL"],
        ["1950", "WON THE NFL TITLE IN 1950, THEIR VERY FIRST NFL SEASON"],
        ["1965", "JIM BROWN LED THE NFL IN RUSHING IN 8 OF HIS 9 SEASONS"],
        ["2018", "AFTER GOING 0-16 IN 2017, FANS THREW A PERFECT SEASON PARADE"],
        ["1999", "RETURNED IN 1999 WITH THE NAME, COLORS AND RECORDS KEPT FROM 1995"],
    ]],
    "DAL": ["COWBOYS", "DALLAS", 1960, 5, 0, "NFL", [
        ["1960", "WENT 0-11-1 IN THEIR FIRST SEASON"],
        ["1988", "TOM LANDRY COACHED THEIR FIRST 29 SEASONS, 1960 TO 1988"],
        ["1975", "ROGER STAUBACH COINED THE HAIL MARY AFTER A PLAYOFF WIN"],
        ["2002", "EMMITT SMITH BECAME THE NFL ALL-TIME RUSHING LEADER"],
        ["1978", "NFL FILMS DUBBED THEM AMERICAS TEAM IN A 1978 HIGHLIGHT FILM"],
        ["1996", "WON THREE SUPER BOWLS IN FOUR SEASONS IN THE 1990S"],
    ]],
    "DEN": ["BRONCOS", "DENVER", 1959, 3, 0, "NFL", [
        ["1962", "FANS BURNED THE FIRST VERTICAL-STRIPED SOCKS IN A BONFIRE"],
        ["1987", "THE DRIVE: JOHN ELWAY WENT 98 YARDS TO TIE THE AFC TITLE GAME"],
        ["2013", "PEYTON MANNING THREW 55 TOUCHDOWN PASSES, AN NFL RECORD"],
        ["1999", "ELWAY RETIRED RIGHT AFTER BACK-TO-BACK SUPER BOWL WINS"],
        ["1960", "HAVE PLAYED HOME GAMES A MILE ABOVE SEA LEVEL SINCE 1960"],
        ["1977", "THE ORANGE CRUSH DEFENSE CARRIED THEM TO SUPER BOWL XII"],
    ]],
    "DET": ["LIONS", "DETROIT", 1929, 0, 4, "NFL", [
        ["1934", "BEGAN AS THE PORTSMOUTH SPARTANS IN OHIO, THEN MOVED TO DETROIT"],
        ["1934", "HAVE PLAYED ON THANKSGIVING EVERY YEAR SINCE 1934 BUT FOR WWII"],
        ["2008", "WENT 0-16 IN 2008, THE FIRST TEAM EVER TO DO IT"],
        ["1999", "BARRY SANDERS RETIRED JUST 1,457 YARDS SHORT OF THE RUSHING RECORD"],
        ["1934", "NAMED LIONS TO PAIR WITH BASEBALLS DETROIT TIGERS"],
        ["2012", "CALVIN JOHNSON PILED UP 1,964 RECEIVING YARDS IN ONE SEASON"],
    ]],
    "GB": ["PACKERS", "GREEN BAY", 1919, 4, 9, "NFL", [
        ["1919", "NAMED FOR THE INDIAN PACKING COMPANY, WHICH PAID FOR THEIR JERSEYS"],
        ["1923", "OWNED BY THEIR FANS - THE ONLY PUBLICLY OWNED TEAM IN THE NFL"],
        ["1967", "THE ICE BOWL: BEAT DALLAS AT 13 BELOW ON A LAST-SECOND QB SNEAK"],
        ["1970", "THE SUPER BOWL TROPHY IS NAMED FOR THEIR COACH, VINCE LOMBARDI"],
        ["1968", "WON THE FIRST TWO SUPER BOWLS EVER PLAYED"],
        ["1993", "THE LAMBEAU LEAP: PLAYERS JUMP INTO THE STANDS AFTER TDS"],
        ["1992", "BRETT FAVRE BEGAN A RUN OF 297 STRAIGHT STARTS IN GREEN BAY"],
    ]],
    "HOU": ["TEXANS", "HOUSTON", 1999, 0, 0, "NFL", [
        ["2002", "BEAT DALLAS IN THEIR FIRST GAME EVER"],
        ["1999", "BORN AFTER THE OILERS LEFT HOUSTON FOR TENNESSEE"],
        ["2015", "JJ WATT WON DEFENSIVE PLAYER OF THE YEAR THREE TIMES"],
        ["2002", "THEIR HOME WAS THE FIRST NFL STADIUM WITH A RETRACTABLE ROOF"],
        ["2002", "DAVID CARR WAS SACKED 76 TIMES AS A ROOKIE, AN NFL RECORD"],
        ["2012", "WON THEIR FIRST PLAYOFF GAME IN JANUARY 2012, OVER CINCINNATI"],
    ]],
    "IND": ["COLTS", "INDIANAPOLIS", 1953, 2, 3, "NFL", [
        ["1984", "LEFT BALTIMORE OVERNIGHT IN MAYFLOWER MOVING TRUCKS"],
        ["1958", "WON THE 1958 NFL TITLE IN OT, THE GREATEST GAME EVER PLAYED"],
        ["1960", "JOHNNY UNITAS THREW A TD PASS IN 47 STRAIGHT GAMES"],
        ["2009", "PEYTON MANNING WON FOUR MVP AWARDS AS A COLT"],
        ["2007", "WON SUPER BOWL XLI IN A MIAMI DOWNPOUR"],
        ["1969", "LOST SUPER BOWL III TO THE 18-POINT UNDERDOG JETS"],
    ]],
    "JAX": ["JAGUARS", "JACKSONVILLE", 1993, 0, 0, "NFL", [
        ["1996", "REACHED THE AFC TITLE GAME IN 1996, ONLY THEIR SECOND SEASON"],
        ["2014", "THEIR STADIUM HAS SWIMMING POOLS IN THE END ZONE STANDS"],
        ["1996", "THEIR STADIUM HOSTS FLORIDA VS GEORGIA, A COLLEGE RIVALRY"],
        ["2013", "HAVE PLAYED MORE GAMES IN LONDON THAN ANY OTHER NFL TEAM"],
        ["1999", "WENT 14-2 IN 1999 - ALL THREE LOSSES WERE TO TENNESSEE"],
        ["2018", "SACKSONVILLE LED NEW ENGLAND IN THE 4TH OF THE AFC TITLE GAME"],
    ]],
    "KC": ["CHIEFS", "KANSAS CITY", 1959, 4, 2, "AFL", [
        ["1963", "BEGAN AS THE DALLAS TEXANS AND MOVED TO KANSAS CITY IN 1963"],
        ["1963", "NAMED FOR KC MAYOR H. ROE BARTLE, NICKNAMED THE CHIEF"],
        ["1967", "PLAYED IN SUPER BOWL I, LOSING TO GREEN BAY"],
        ["1966", "FOUNDER LAMAR HUNT CAME UP WITH THE NAME SUPER BOWL"],
        ["2014", "ARROWHEAD HIT 142.2 DECIBELS, A RECORD FOR THE LOUDEST STADIUM"],
        ["2024", "WON BACK-TO-BACK SUPER BOWLS, LVII AND LVIII"],
        ["1990", "DERRICK THOMAS HAD 7 SACKS IN ONE GAME, AN NFL RECORD"],
    ]],
    "LV": ["RAIDERS", "LAS VEGAS", 1960, 3, 1, "AFL", [
        ["2020", "HAVE CALLED OAKLAND, LOS ANGELES AND LAS VEGAS HOME"],
        ["1972", "LOST TO THE IMMACULATE RECEPTION IN PITTSBURGH"],
        ["1978", "THE HOLY ROLLER: A FUMBLED-FORWARD TD THAT CHANGED THE RULES"],
        ["1981", "TOM FLORES, THE FIRST LATINO HEAD COACH TO WIN A SUPER BOWL"],
        ["1977", "BEAT MINNESOTA IN SUPER BOWL XI FOR THEIR FIRST LOMBARDI TROPHY"],
        ["1981", "WON SUPER BOWL XV AS A WILD CARD, THE FIRST TO DO IT"],
    ]],
    "LAC": ["CHARGERS", "LOS ANGELES", 1959, 0, 1, "AFL", [
        ["2017", "PLAYED ONE SEASON IN LA, THEN 56 IN SAN DIEGO BEFORE COMING BACK"],
        ["1982", "THE EPIC IN MIAMI: WON A 41-38 OVERTIME PLAYOFF CLASSIC"],
        ["2006", "LADAINIAN TOMLINSON SCORED 31 TOUCHDOWNS, AN NFL RECORD"],
        ["1964", "WON THE 1963 AFL TITLE, 51-10 OVER BOSTON"],
        ["1995", "THEIR ONE SUPER BOWL TRIP WAS A LOSS TO SAN FRANCISCO IN XXIX"],
        ["2020", "SHARE SOFI STADIUM WITH THE RAMS"],
    ]],
    "LAR": ["RAMS", "LOS ANGELES", 1936, 2, 2, "NFL", [
        ["2016", "STARTED IN CLEVELAND, THEN MOVED TO LA, ST. LOUIS AND BACK TO LA"],
        ["1948", "THE FIRST PRO TEAM TO PUT A LOGO ON ITS HELMETS: THE RAM HORNS"],
        ["2000", "THE GREATEST SHOW ON TURF WON SUPER BOWL XXXIV"],
        ["1999", "KURT WARNER WENT FROM GROCERY STOCKER TO SUPER BOWL MVP"],
        ["2022", "WON SUPER BOWL LVI IN THEIR OWN STADIUM"],
        ["1984", "ERIC DICKERSON RAN FOR 2,105 YARDS, THE SINGLE-SEASON RECORD"],
        ["2022", "THE ONLY CLUB TO WIN NFL TITLES FOR THREE DIFFERENT CITIES"],
    ]],
    "MIA": ["DOLPHINS", "MIAMI", 1965, 2, 0, "NFL", [
        ["1972", "WENT 17-0, THE ONLY PERFECT SEASON IN NFL HISTORY"],
        ["1995", "DON SHULA WON 347 GAMES, THE MOST BY ANY NFL COACH"],
        ["1984", "DAN MARINO THREW 48 TOUCHDOWN PASSES, THEN AN NFL RECORD"],
        ["1965", "FOUNDED BY LAWYER JOE ROBBIE AND ENTERTAINER DANNY THOMAS"],
        ["1974", "PLAYED IN THREE STRAIGHT SUPER BOWLS, WINNING VII AND VIII"],
        ["1985", "DAN MARINO PLAYED IN JUST ONE SUPER BOWL: XIX, A LOSS"],
    ]],
    "MIN": ["VIKINGS", "MINNESOTA", 1960, 0, 1, "NFL", [
        ["1971", "ALAN PAGE OF THE PURPLE PEOPLE EATERS WAS THE FIRST DEFENSIVE MVP"],
        ["1977", "HAVE PLAYED IN FOUR SUPER BOWLS: IV, VIII, IX AND XI"],
        ["2018", "MINNEAPOLIS MIRACLE: A 61-YARD PLAYOFF TD ON THE FINAL PLAY"],
        ["2010", "THE METRODOME ROOF CAVED IN UNDER SNOW, SENDING GAMES ELSEWHERE"],
        ["2007", "ADRIAN PETERSON RAN FOR 296 YARDS IN ONE GAME, AN NFL RECORD"],
        ["1998", "RANDY MOSS CAUGHT 17 TOUCHDOWN PASSES AS A ROOKIE"],
        ["1970", "WON THE 1969 NFL TITLE BEFORE LOSING SUPER BOWL IV"],
    ]],
    "NE": ["PATRIOTS", "NEW ENGLAND", 1959, 6, 0, "NFL", [
        ["1960", "BEGAN AS THE BOSTON PATRIOTS, A CHARTER TEAM OF THE AFL"],
        ["2000", "TOM BRADY WAS THE 199TH PICK OF THE 2000 DRAFT"],
        ["2007", "WENT 16-0, THEN LOST SUPER BOWL XLII TO THE GIANTS"],
        ["1982", "THE SNOWPLOW GAME: A PLOW CLEARED THE SPOT FOR THE WINNING KICK"],
        ["2017", "RALLIED FROM 28-3 DOWN TO WIN SUPER BOWL LI IN OVERTIME"],
        ["2002", "THE TUCK RULE SAVED THEM IN A SNOWY PLAYOFF WIN OVER OAKLAND"],
    ]],
    "NO": ["SAINTS", "NEW ORLEANS", 1966, 1, 0, "NFL", [
        ["1966", "AWARDED THEIR FRANCHISE ON ALL SAINTS DAY, NOVEMBER 1, 1966"],
        ["2006", "CAME HOME TO THE SUPERDOME AFTER KATRINA WITH A BLOCKED-PUNT TD"],
        ["2010", "OPENED THE 2ND HALF OF SUPER BOWL XLIV WITH A SURPRISE ONSIDE KICK"],
        ["1970", "TOM DEMPSEY KICKED A 63-YARD FIELD GOAL, A RECORD FOR 43 YEARS"],
        ["2012", "DREW BREES THREW A TD PASS IN 54 STRAIGHT GAMES"],
        ["1987", "THEIR 21ST SEASON, 1987, WAS THEIR FIRST WINNING ONE: 12-3"],
    ]],
    "NYG": ["GIANTS", "NEW YORK", 1925, 4, 4, "NFL", [
        ["1925", "TIM MARA BOUGHT THE FRANCHISE FOR 500 DOLLARS"],
        ["2008", "THE HELMET CATCH HELPED END NEW ENGLANDS PERFECT SEASON"],
        ["1986", "LAWRENCE TAYLOR WON MVP, ONE OF ONLY TWO DEFENDERS EVER"],
        ["2012", "BEAT NEW ENGLAND IN TWO SUPER BOWLS: XLII AND XLVI"],
        ["2010", "SHARE METLIFE STADIUM, IN NEW JERSEY, WITH THE JETS"],
        ["1934", "THE SNEAKERS GAME: WON THE TITLE ON ICE IN BASKETBALL SHOES"],
    ]],
    "NYJ": ["JETS", "NEW YORK", 1959, 1, 0, "NFL", [
        ["1960", "BEGAN AS THE NEW YORK TITANS OF THE AFL"],
        ["1969", "JOE NAMATH GUARANTEED A WIN IN SUPER BOWL III, THEN DELIVERED IT"],
        ["1963", "NAMED JETS FOR THE PLANES OVER THEIR HOME NEAR LAGUARDIA AIRPORT"],
        ["1967", "JOE NAMATH BECAME THE FIRST QB TO THROW FOR 4,000 YARDS IN A SEASON"],
        ["1968", "THE HEIDI GAME: TV CUT TO A MOVIE AS OAKLAND RALLIED TO WIN"],
        ["2012", "THE BUTT FUMBLE CAME ON THANKSGIVING NIGHT VS NEW ENGLAND"],
    ]],
    "PHI": ["EAGLES", "PHILADELPHIA", 1933, 2, 3, "NFL", [
        ["1933", "NAMED FOR THE BLUE EAGLE, THE SYMBOL OF FDRS NEW DEAL"],
        ["1943", "MERGED WITH PITTSBURGH FOR A SEASON AS THE STEAGLES"],
        ["2018", "THE PHILLY SPECIAL: THEIR QB CAUGHT A TD PASS IN SUPER BOWL LII"],
        ["2025", "WON SUPER BOWL LIX OVER KANSAS CITY, 40-22"],
        ["1968", "FANS FAMOUSLY BOOED AND SNOWBALLED SANTA CLAUS"],
        ["1960", "HANDED VINCE LOMBARDI THE ONLY PLAYOFF LOSS OF HIS CAREER"],
    ]],
    "PIT": ["STEELERS", "PITTSBURGH", 1933, 6, 0, "NFL", [
        ["1933", "BEGAN AS THE PITTSBURGH PIRATES, LIKE THE BASEBALL TEAM"],
        ["1972", "THE IMMACULATE RECEPTION: FRANCO HARRIS BEAT OAKLAND"],
        ["1962", "THEIR LOGO IS ON ONLY ONE SIDE OF THE HELMET"],
        ["1980", "CHUCK NOLL WON FOUR SUPER BOWLS IN SIX SEASONS"],
        ["1975", "FANS HAVE WAVED THE TERRIBLE TOWEL SINCE 1975"],
        ["1962", "THE LOGO COMES FROM THE STEELMARK OF THE US STEEL INDUSTRY"],
    ]],
    "SF": ["49ERS", "SAN FRANCISCO", 1944, 5, 0, "NFL", [
        ["1946", "KICKED OFF IN 1946, NAMED FOR THE GOLD RUSH PROSPECTORS OF 1849"],
        ["1982", "THE CATCH: MONTANA TO DWIGHT CLARK BEAT DALLAS"],
        ["2004", "JERRY RICE HOLDS THE NFL RECORD WITH 22,895 RECEIVING YARDS"],
        ["1995", "WON THEIR FIRST FIVE SUPER BOWLS BEFORE EVER LOSING ONE"],
        ["1950", "PLAYED IN THE AAFC FROM 1946, THEN JOINED THE NFL IN 1950"],
        ["1995", "STEVE YOUNG THREW 6 TD PASSES IN SUPER BOWL XXIX, A RECORD"],
    ]],
    "SEA": ["SEAHAWKS", "SEATTLE", 1974, 2, 0, "NFL", [
        ["2011", "THE BEAST QUAKE: FANS SHOOK A SEISMOMETER ON A LYNCH PLAYOFF TD"],
        ["2002", "PLAYED IN THE AFC FROM 1977 TO 2001 BEFORE MOVING TO THE NFC"],
        ["2014", "ROUTED DENVER 43-8 IN SUPER BOWL XLVIII"],
        ["2015", "LOST SUPER BOWL XLIX ON AN INTERCEPTION AT THE 1-YARD LINE"],
        ["2026", "BEAT NEW ENGLAND IN SUPER BOWL LX FOR THEIR SECOND TITLE"],
        ["1984", "RETIRED NO. 12 FOR THE 12TH MAN, FANS SO LOUD THEY COUNT AS A PLAYER"],
    ]],
    "TB": ["BUCCANEERS", "TAMPA BAY", 1974, 2, 0, "NFL", [
        ["1977", "LOST THEIR FIRST 26 GAMES"],
        ["1996", "WORE CREAMSICLE ORANGE AND BUCCO BRUCE UNTIL 1996"],
        ["2021", "WON SUPER BOWL LV AT HOME, THE FIRST TEAM TO DO IT"],
        ["1998", "A PIRATE SHIP IN THEIR STADIUM FIRES CANNONS AFTER SCORES"],
        ["2003", "JON GRUDEN BEAT HIS OLD TEAM, THE RAIDERS, IN SUPER BOWL XXXVII"],
        ["2021", "TOM BRADY WON HIS SEVENTH RING WITH THEM AT AGE 43"],
    ]],
    "TEN": ["TITANS", "TENNESSEE", 1959, 0, 2, "AFL", [
        ["1961", "BEGAN AS THE HOUSTON OILERS AND WON THE FIRST TWO AFL TITLES"],
        ["2000", "THE MUSIC CITY MIRACLE: A LATERAL ON A KICK RETURN BEAT BUFFALO"],
        ["2000", "THE TACKLE: STOPPED ONE YARD SHORT OF TYING SUPER BOWL XXXIV"],
        ["1998", "PLAYED IN MEMPHIS, THEN AT VANDERBILT, WHILE THEIR STADIUM WAS BUILT"],
        ["2020", "DERRICK HENRY RAN FOR 2,027 YARDS"],
        ["1990", "WARREN MOON THREW FOR 527 YARDS IN A SINGLE GAME"],
    ]],
    "WSH": ["COMMANDERS", "WASHINGTON", 1932, 3, 2, "NFL", [
        ["1932", "BEGAN AS THE BOSTON BRAVES, MOVING TO WASHINGTON IN 1937"],
        ["1992", "WON THREE SUPER BOWLS WITH THREE DIFFERENT STARTING QBS"],
        ["1988", "DOUG WILLIAMS, THE FIRST BLACK QB TO START AND WIN A SUPER BOWL"],
        ["1940", "LOST 73-0 TO THE BEARS IN THE 1940 NFL TITLE GAME"],
        ["2020", "PLAYED TWO SEASONS AS THE WASHINGTON FOOTBALL TEAM"],
        ["1943", "SAMMY BAUGH LED THE NFL IN PASSING, PUNTING AND INTERCEPTIONS"],
        ["1982", "THE HOGS OFFENSIVE LINE POWERED THEIR 1980S TITLE TEAMS"],
    ]],
}

ORDER = ["ARI", "ATL", "BAL", "BUF", "CAR", "CHI", "CIN", "CLE", "DAL", "DEN", "DET",
         "GB", "HOU", "IND", "JAX", "KC", "LV", "LAC", "LAR", "MIA", "MIN", "NE", "NO",
         "NYG", "NYJ", "PHI", "PIT", "SF", "SEA", "TB", "TEN", "WSH"]

# Dropdown label -> abbreviation.
PICK = {
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

# Super Bowls lost, through Super Bowl LX. With the wins in CLUBS these add
# up to 60 and 60.
SB_LOST = {
    "ARI": 1, "ATL": 2, "BAL": 0, "BUF": 4, "CAR": 2, "CHI": 1, "CIN": 3, "CLE": 0,
    "DAL": 3, "DEN": 5, "DET": 0, "GB": 1, "HOU": 0, "IND": 2, "JAX": 0, "KC": 3,
    "LV": 2, "LAC": 1, "LAR": 3, "MIA": 3, "MIN": 4, "NE": 6, "NO": 0, "NYG": 1,
    "NYJ": 0, "PHI": 3, "PIT": 2, "SF": 3, "SEA": 2, "TB": 0, "TEN": 1, "WSH": 2,
}

# The year the club's last NFL, AFL or Super Bowl title game was played
# (0 = never). The same convention as the story years, so Seattle's Super
# Bowl LX is 2026 on both pages. AAFC titles are left out.
LAST_TITLE = {
    "ARI": 1947, "ATL": 0, "BAL": 2013, "BUF": 1965, "CAR": 0, "CHI": 1986,
    "CIN": 0, "CLE": 1964, "DAL": 1996, "DEN": 2016, "DET": 1957, "GB": 2011,
    "HOU": 0, "IND": 2007, "JAX": 0, "KC": 2024, "LV": 1984, "LAC": 1964,
    "LAR": 2022, "MIA": 1974, "MIN": 1970, "NE": 2019, "NO": 2010, "NYG": 2012,
    "NYJ": 1969, "PHI": 2025, "PIT": 2009, "SF": 1995, "SEA": 2026, "TB": 2021,
    "TEN": 1961, "WSH": 1992,
}

# Rival -> all-time series from this club's side [W, L, T], playoffs
# included, through the 2025 season (every pair checked to have no 2026
# meeting counted). Washington is left out: each of its rivalries had
# already been played in 2026, so a clean through-2025 figure was not
# available.
RIVAL = {
    "ARI": ["LAR", 41, 53, 2], "ATL": ["NO", 58, 56, 0], "BAL": ["PIT", 27, 38, 0],
    "BUF": ["MIA", 61, 63, 1], "CAR": ["NO", 29, 34, 0], "CHI": ["GB", 98, 109, 6],
    "CIN": ["CLE", 56, 49, 0], "CLE": ["PIT", 65, 83, 1], "DAL": ["PHI", 75, 59, 0],
    "DEN": ["LV", 58, 73, 2], "DET": ["GB", 78, 108, 7], "GB": ["CHI", 109, 98, 6],
    "HOU": ["TEN", 24, 24, 0], "IND": ["NE", 32, 53, 0], "JAX": ["TEN", 28, 35, 0],
    "KC": ["LV", 76, 56, 2], "LV": ["KC", 56, 76, 2], "LAC": ["DEN", 58, 74, 1],
    "LAR": ["ARI", 53, 41, 2], "MIA": ["BUF", 63, 61, 1], "MIN": ["DET", 82, 45, 2],
    "NE": ["NYJ", 77, 56, 1], "NO": ["ATL", 56, 58, 0], "NYG": ["PHI", 90, 97, 2],
    "NYJ": ["NE", 56, 77, 1], "PHI": ["DAL", 59, 75, 0], "PIT": ["BAL", 38, 27, 0],
    "SF": ["SEA", 24, 33, 0], "SEA": ["SF", 33, 24, 0], "TB": ["NO", 28, 41, 0],
    "TEN": ["JAX", 35, 28, 0],
}

# One officially retired number per club: [first name, surname, number].
# Clubs with no confirmed retired number (Dallas and the Raiders do not
# retire numbers) are left out and simply skip the frame.
LEGEND = {
    "ARI": ["PAT", "TILLMAN", "40"], "BUF": ["JIM", "KELLY", "12"],
    "CAR": ["SAM", "MILLS", "51"], "CHI": ["WALTER", "PAYTON", "34"],
    "CIN": ["BOB", "JOHNSON", "54"], "CLE": ["JIM", "BROWN", "32"],
    "DEN": ["JOHN", "ELWAY", "7"], "DET": ["BOBBY", "LAYNE", "22"],
    "GB": ["BRETT", "FAVRE", "4"], "IND": ["JOHNNY", "UNITAS", "19"],
    "JAX": ["TONY", "BOSELLI", "71"], "KC": ["LEN", "DAWSON", "16"],
    "LAC": ["LADAINIAN", "TOMLINSON", "21"], "LAR": ["ERIC", "DICKERSON", "29"],
    "MIA": ["DAN", "MARINO", "13"], "MIN": ["FRAN", "TARKENTON", "10"],
    "NE": ["TOM", "BRADY", "12"], "NYG": ["LAWRENCE", "TAYLOR", "56"],
    "NYJ": ["JOE", "NAMATH", "12"], "PHI": ["BRIAN", "DAWKINS", "20"],
    "PIT": ["FRANCO", "HARRIS", "32"], "SF": ["JOE", "MONTANA", "16"],
    "SEA": ["STEVE", "LARGENT", "80"], "TB": ["LEE ROY", "SELMON", "63"],
    "TEN": ["EARL", "CAMPBELL", "34"], "WSH": ["SAMMY", "BAUGH", "33"],
}

# Jersey colours for that legend: [body, number, number outline ("" for
# none), sleeve stripe]. Dark club colours are lifted so the shirt still
# reads on black; Pittsburgh's black is a charcoal.
JERSEY = {
    "ARI": ["#C8102E", "#FFFFFF", "#000000", "#FFFFFF"],
    "BUF": ["#1F4FC8", "#FFFFFF", "#E8203F", "#E8203F"],
    "CAR": ["#0085CA", "#FFFFFF", "#101820", "#A5ACAF"],
    "CHI": ["#1C3363", "#FFFFFF", "#FF5A1F", "#FF5A1F"],
    "CIN": ["#FB4F14", "#FFFFFF", "#000000", "#000000"],
    "CLE": ["#6B3F24", "#FFFFFF", "#FF6A13", "#FF6A13"],
    "DEN": ["#FB4F14", "#1C2E5A", "#FFFFFF", "#1C2E5A"],
    "DET": ["#0076B6", "#FFFFFF", "#B0B7BC", "#FFFFFF"],
    "GB": ["#1F5C40", "#FFFFFF", "", "#FFB612"],
    "IND": ["#1F4FAE", "#FFFFFF", "", "#FFFFFF"],
    "JAX": ["#008A9E", "#FFFFFF", "#101820", "#D7A22A"],
    "KC": ["#E31837", "#FFFFFF", "", "#FFFFFF"],
    "LAC": ["#0080C6", "#FFFFFF", "#0B2B5C", "#FFC20E"],
    "LAR": ["#1F4FC8", "#FFFFFF", "#FFD100", "#FFD100"],
    "MIA": ["#008E97", "#FFFFFF", "#FC4C02", "#FC4C02"],
    "MIN": ["#6A3CB0", "#FFFFFF", "#FFC62F", "#FFC62F"],
    "NE": ["#1F3D7A", "#FFFFFF", "#C60C30", "#C60C30"],
    "NYG": ["#1F3FA0", "#FFFFFF", "#C8102E", "#C8102E"],
    "NYJ": ["#1A7A55", "#FFFFFF", "", "#FFFFFF"],
    "PHI": ["#0E6E73", "#FFFFFF", "#101820", "#B0B7BC"],
    "PIT": ["#34383F", "#FFB612", "", "#FFB612"],
    "SF": ["#C8102E", "#FFFFFF", "#101820", "#FFFFFF"],
    "SEA": ["#2A4FB0", "#FFFFFF", "#69BE28", "#69BE28"],
    "TB": ["#D50A0A", "#FFFFFF", "", "#FF7900"],
    "TEN": ["#4B92DB", "#FFFFFF", "#C8102E", "#C8102E"],
    "WSH": ["#8A1E2A", "#FFFFFF", "#FFB612", "#FFB612"],
}

# --------------------------------------------------------------- pixel art
# 5 x 12: the Lombardi Trophy - a football on its tip over a tapered stem
# and a stepped base. H highlight, S silver, D shadow side, B base.
LOMBARDI = """
..H..
.HSS.
.HSD.
.SSD.
..S..
..S..
..S..
.SSD.
.SSD.
.BBB.
BBBBB
BBBBB
"""
LOMBARDI_LEG = {"H": "#FFFFFF", "S": "#C9D1DA", "D": "#7F8A96", "B": "#56606B"}
# The same trophy for a Super Bowl lost: a dim ghost of the real thing.
GHOST_LEG = {"H": "#6A7384", "S": "#4C5463", "D": "#394050", "B": "#303644"}

# 5 x 5: a bronze championship cup for the pre-Super Bowl titles.
CUP = """
XXXXX
XXXXX
.XXX.
..X..
.XXX.
"""

# 28 x 22: a football jersey. B body, T trim (V collar and sleeve stripes).
# The number is drawn over the chest, x 4..23 is the torso.
JERSEY_ART = """
........BBBT....TBBB........
......BBBBBBT..TBBBBBB......
...BBBBBBBBBBTTBBBBBBBBBB...
..BBBBBBBBBBBBBBBBBBBBBBBB..
.BTBBBBBBBBBBBBBBBBBBBBBBTB.
BBTBBBBBBBBBBBBBBBBBBBBBBTBB
BBTBBBBBBBBBBBBBBBBBBBBBBTBB
BBTBBBBBBBBBBBBBBBBBBBBBBTBB
BBTBBBBBBBBBBBBBBBBBBBBBBTBB
.BTB.BBBBBBBBBBBBBBBBBB.BTB.
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
....BBBBBBBBBBBBBBBBBBBB....
"""

# ------------------------------------------------------------- text tools
INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x7": 7, "4x5": 5}

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def ladder(c, text, fonts, maxw):
    """The biggest font in the list that fits, else the last one (clipped)."""
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return f
    return fonts[-1]

def wrap(c, text, font, maxw):
    """Greedy word wrap. Returns every line - the caller decides whether the
    count fits, so a story that would need a fourth line can drop a size."""
    lines = []
    cur = ""
    for w in [w for w in str(text).split(" ") if w != ""]:
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
            continue
        if cur != "":
            lines.append(cur)
        cur = w if c.text_width(w, font) <= maxw else clip(c, w, font, maxw)
    if cur != "":
        lines.append(cur)
    return lines

HEXD = "0123456789abcdef"

def ink_for(fill):
    """Black type on a bright fill, white on a dark one."""
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

# ------------------------------------------------------------ which club
def club_for(ctx):
    pick = str(ctx.inputs.get("team", "ALL TEAMS")).strip().upper()
    if pick in PICK:
        return PICK[pick]
    # ALL TEAMS (or an unknown value): a new club every 10 minutes, the same
    # one on both pages.
    return ORDER[(ctx.now.unix // 600) % len(ORDER)]


def frames_for(abbr):
    """Stories first, then the rivalry card, then the retired jersey."""
    fr = [["story", f] for f in CLUBS[abbr][6]]
    if abbr in RIVAL:
        fr.append(["rival", RIVAL[abbr]])
    if abbr in LEGEND:
        fr.append(["legend", LEGEND[abbr]])
    return fr


# ------------------------------------------------------------ the pennant
STITCH = ["10x16", "9x12", "8x10", "6x8", "5x7", "4x5"]

def span(x, tip):
    """The rows [top, bottom] the cloth covers at column x for a pennant from
    the sleeve at PX0 to a point at tip (bottom < top: no cloth there). The
    cloth is symmetric about the centre of rows TOP0..BOT0."""
    n = BOT0 - TOP0 + 1
    mid = TOP0 + n // 2
    if x < PX0 or x > tip:
        return [mid, mid - 1]
    ln = tip - PX0
    h2 = (n * (tip - x) + ln) // (2 * ln)
    return [mid - h2, mid + h2 - 1]

def clear_from(tip, y0, y1):
    """The first column from which every column to the right keeps the rows
    y0..y1 plus a 1 px buffer clear of the cloth."""
    x = PX0
    for _ in range(tip - PX0 + 2):
        s = span(x, tip)
        if s[1] < s[0] or s[1] < y0 - 1 or s[0] > y1 + 1:
            return x
        x += 1
    return tip + 1

def pole(c):
    """The wooden stick with a gold knob."""
    c.rect(POLE_X, 2, POLE_X, 31, fill = WOOD)
    c.rect(POLE_X + 1, 2, POLE_X + 1, 31, fill = WOOD_D)
    c.rect(POLE_X, 0, POLE_X + 1, 1, fill = GOLD)

def cloth(c, abbr, tip):
    """Felt from the sleeve to the tip: sleeve columns in the trim colour, then
    felt with a one-pixel trim edge top and bottom."""
    p = PEN.get(abbr, ["#3A4152", INK, DIM])
    pole(c)
    for x in range(PX0, tip + 1):
        s = span(x, tip)
        if s[1] < s[0]:
            continue
        if x < PX0 + SLEEVE:
            c.line(x, s[0], x, s[1], p[2])
            continue
        c.line(x, s[0], x, s[1], p[0])
        c.pixel(x, s[0], p[2])
        c.pixel(x, s[1], p[2])

def stitch(c, text, tip, x, color):
    """Letter the cloth in ONE face: the biggest in STITCH for which every
    letter, at its own place along the taper, clears the trim by a felt row
    above and below. Letters are 1 px apart and centred on the cloth.
    Returns the x after the last letter."""
    n = BOT0 - TOP0 + 1
    t = str(text)
    for f in STITCH:
        y = TOP0 + (n - INKH[f]) // 2
        cx = x
        ok = True
        for ch in t.elems():
            w = 2 if ch == " " else c.text_width(ch, f)
            s = span(cx + w - 1, tip)
            if ch != " " and not (s[0] <= y - 2 and s[1] >= y + INKH[f] + 1):
                ok = False
                break
            cx += w + 1
        if ok or f == STITCH[-1]:
            if ok:
                c.text(t, x, y, font = f, color = color)
            return cx
    return x

def pips(c, n, cur, right, y, on):
    """n 2x2 squares ending at x = right; the current one lit."""
    x = right - (n * 3 - 1) + 1
    for i in range(n):
        c.rect(x + i * 3, y, x + i * 3 + 1, y + 1, fill = on if i == cur else PIP_OFF)

# ------------------------------------------------------------- page: legacy
def legacy(c, ctx):
    c.fill("black")
    abbr = club_for(ctx)
    d = CLUBS[abbr]
    p = PEN.get(abbr, ["#3A4152", INK, DIM])
    cloth(c, abbr, TIP)
    stitch(c, d[0], TIP, LET_X, p[1])

    # Above the tail, right-aligned: market, EST year; then the last title.
    x = R + 1
    yr = str(d[2])
    c.text(yr, x, 1, font = "4x5", color = GOLD, align = "right")
    x -= c.text_width(yr, "4x5") + 3
    c.text("EST", x, 1, font = "4x5", color = DIM, align = "right")
    x -= c.text_width("EST", "4x5") + 6
    lim = clear_from(TIP, 1, 5)
    mk = clip(c, d[1], "4x5", x - lim)
    if mk != "":
        c.text(mk, x, 1, font = "4x5", color = DIM, align = "right")

    last = LAST_TITLE.get(abbr, 0)
    if last > 0:
        ly = str(last)
        c.text(ly, R + 1, 7, font = "4x5", color = INK, align = "right")
        c.text("TITLE", R + 1 - c.text_width(ly, "4x5") - 3, 7, font = "4x5", color = DIM, align = "right")
    else:
        c.text("NO TITLE", R + 1, 7, font = "4x5", color = DIM, align = "right")

    # Under the tip: silver Lombardis for wins, then dim ghosts for losses.
    wins = d[3]
    lost = SB_LOST.get(abbr, 0)
    tx0 = clear_from(TIP, 19, 30)
    mid = (tx0 + R + 1) // 2
    n = wins + lost
    if n > 8:
        # Only New England (6-6): the wins alone, the record says the rest.
        n = wins
    left = mid
    if n > 0:
        pitch = 6 if (n - 1) * 6 + 5 <= R - tx0 + 1 else 5
        row = (n - 1) * pitch + 5
        left = mid - row // 2
        for i in range(n):
            c.sprite(LOMBARDI, left + i * pitch, 19, legend = LOMBARDI_LEG if i < wins else GHOST_LEG)
    else:
        # Right-aligned: the short line under the tip, the long one on the
        # floor row where the cloth is already out of the way.
        c.text("NEVER IN", R + 1, 19, font = "4x5", color = DIM, align = "right")
        c.text("A SUPER BOWL", R + 1, 25, font = "4x5", color = DIM, align = "right")
        left = R + 1 - c.text_width("A SUPER BOWL", "4x5")

    # On the floor row left of the trophies: the SB record (hugging them) and
    # a bronze cup for league titles won outside a Super Bowl.
    fl = clear_from(TIP, 26, 30)
    x = left - 4
    if n > 0:
        rec = str(wins) + "-" + str(lost)
        c.text(rec, x, 26, font = "4x5", color = INK, align = "right")
        x -= c.text_width(rec, "4x5") + 3
        c.text("SB", x, 26, font = "4x5", color = GOLD if wins > 0 else DIM, align = "right")
        x -= c.text_width("SB", "4x5") + 6
    if d[4] > 0:
        label = "+" + str(d[4]) + " " + d[5]
        w = c.text_width(label, "4x5")
        if x - w - 7 + 1 >= fl:
            c.text(label, x, 26, font = "4x5", color = BRONZE, align = "right")
            c.sprite(CUP, x - w - 7, 26, legend = {"X": BRONZE})

# ------------------------------------------------------------- page: trivia
def story(c, abbr, f):
    p = PEN.get(abbr, ["#3A4152", INK, DIM])
    cloth(c, abbr, TTIP)
    stitch(c, f[0] if f[0] != "" else "LORE", TTIP, LET_X, p[1])
    c.text("DID YOU KNOW", STORY_X, 1, font = "4x5", color = DIM)

    # Three lines of 5x7 when the story fits, else three of 4x7 (same height,
    # narrower), centred in the band y 8..30.
    tw = R - STORY_X + 1
    lines = wrap(c, f[1], "5x7", tw)
    font = "5x7"
    if len(lines) > 3:
        lines = wrap(c, f[1], "4x7", tw)
        font = "4x7"
    if len(lines) > 3:
        lines = lines[:3]
        lines[2] = clip(c, lines[2], font, tw - c.text_width("..", font)) + ".."
    h = len(lines) * 8 - 1
    y = 8 + (23 - h) // 2
    for i in range(len(lines)):
        c.text(lines[i], STORY_X, y + i * 8, font = font, color = INK)

def rivalry(c, abbr, r):
    """The club's short pennant facing the rival's logo, the all-time series
    between them."""
    rv = r[0]
    w, l, t = r[1], r[2], r[3]
    p = PEN.get(abbr, ["#3A4152", INK, DIM])
    cloth(c, abbr, RTIP)
    stitch(c, abbr, RTIP, LET_X, p[1])
    c.image(LOGO[rv], RIVAL_X, 4)

    zl = RTIP + 3
    zr = RIVAL_X - 4
    zm = (zl + zr + 1) // 2
    c.text("RIVAL", zl, 1, font = "4x5", color = GOLD)
    c.text("THRU 2025", zr, 1, font = "4x5", color = DIM, align = "right")
    rec = str(w) + "-" + str(l) + ("-" + str(t) if t > 0 else "")
    font = ladder(c, rec, ["10x16", "9x12", "8x10"], zr - zl + 1)
    c.text(rec, zm, 8 + (15 - INKH[font]) // 2, font = font, color = INK, align = "center")

    if w > l:
        msg, col = CLUBS[abbr][0] + " LEAD", PEN[abbr][2] if abbr in PEN else INK
    elif l > w:
        msg, col = CLUBS[rv][0] + " LEAD", ACCENT.get(rv, DIM)
    else:
        msg, col = "SERIES TIED", DIM
    c.text(clip(c, msg, "4x5", zr - zl + 1), zm, 26, font = "4x5", color = col, align = "center")

def legend(c, abbr, g):
    """The club's most famous retired number, on a pixel jersey."""
    j = JERSEY.get(abbr, [ACCENT.get(abbr, DIM), "#FFFFFF", "", "#FFFFFF"])
    jx, jy = 12, 6
    c.sprite(JERSEY_ART, jx, jy, legend = {"B": j[0], "T": j[3]})
    num = g[2]
    nf = ladder(c, num, ["8x10", "6x8"], 17)
    ny = jy + 10
    if j[2] != "":
        c.text_stroke(num, jx + 14, ny, font = nf, color = j[1], stroke = j[2], align = "center")
    else:
        c.text(num, jx + 14, ny, font = nf, color = j[1], align = "center")

    x = jx + 28 + 6
    tw = R - x + 1
    c.text("RETIRED NO. " + num, x, 1, font = "4x5", color = GOLD)
    c.text(clip(c, g[0], "5x7", tw), x, 8, font = "5x7", color = DIM)
    sf = ladder(c, g[1], ["10x16", "9x12", "8x10"], tw)
    c.text(clip(c, g[1], sf, tw), x, 16 + (15 - INKH[sf]) // 2, font = sf, color = INK)

def trivia(c, ctx):
    c.fill("black")
    abbr = club_for(ctx)
    fr = frames_for(abbr)
    n = len(fr)
    idx = (ctx.now.unix // 60) % n
    kind, data = fr[idx][0], fr[idx][1]
    on = PEN[abbr][2] if abbr in PEN else DIM

    if kind == "rival":
        rivalry(c, abbr, data)
        pips(c, n, idx, R - 2, 1, on)
    elif kind == "legend":
        legend(c, abbr, data)
        pips(c, n, idx, R, 2, on)
    else:
        story(c, abbr, data)
        pips(c, n, idx, R, 2, on)
