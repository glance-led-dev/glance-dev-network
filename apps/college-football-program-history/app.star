# College Football Program History
#
# A trophy room for 39 major FBS programs. No network: everything below is
# baked in and checked by hand.
#
#   legacy     the trophy shelf - one gold cup on the shelf for every claimed
#              national title and one bronze stiff-arm statue for every
#              Heisman, engraved counts on the shelf's walnut lip, the
#              school and mascot on the wall above, and the school's felt
#              banner hanging at the right with its logo and first season.
#   tradition  the same wall with a framed plaque on it: one story from the
#              program's history at a time, rotating by the minute - players,
#              coaches, titles, trophies, rivalries, streaks. The story's
#              name is a school-colour tag on the frame's top rail. A story
#              that names another program shows that program's logo on the
#              plaque, facing the school's own banner (the Iron Bowl plaque
#              carries Auburn beside the Bama banner). Otherwise a pixel icon
#              - a bell, a jug, an axe, a wagon, a turnover chain - drawn in
#              the school's own colours where the object has none.
#
# DESIGN. The archetype is a TROPHY ROOM: the counts are objects you can
# see, not numbers. The shelf runs the whole panel (x 6..185, top y 23)
# and the school's banner hangs full height in front of its right end
# (x 158..185): the logo at its authored 24 x 18 (never scaled) in a window
# picked to contrast with it - cream for dark marks, near-black for bright
# ones - over the first season and a swallowtail. Nothing lights outside
# x 6..185. Cups are 5 px on a 6 px pitch with 2 px more after every fifth,
# so a long row counts in fives; statues are 6 px on a 7 px pitch. Built
# for the worst case, Alabama's 18 claimed titles: 113 px of cups, a 6 px
# gap, 4 statues ending at x 153, 4 px short of the banner. The statues and
# their lip plate share a right edge placed so neither collides with the
# cups or the cup plate. A zero is one grey ghost on the shelf - an empty
# spot, not a missing one. The logo never sits at the left. Titles are the
# program's own CLAIMED count - the honest word for a sport that crowned
# champions by poll for a century. Counts run through the 2025 season;
# conferences are the 2026 line-up. The home stadium stays in the data
# (and in college-stadium-gameday, which owns stadium lore) but no longer
# has a row on the panel: the shelf needs it.
#
# Stadium and gameday lore lives in college-stadium-gameday and most Heisman
# stories in heisman-trophy-history, so this app keeps to program history and
# at most one Heisman story per school - the three can share a wall.
#
# With "ALL - ROTATE" the school changes every 10 minutes (a stride of 7
# through the list, so neighbours in the alphabet don't follow each other)
# and the story changes every minute, so both pages always show the same
# school at the same time.

SCHOOL_SECONDS = 600

# --------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
GOLD = "#FFC233"
GOLD_D = "#B07A10"
BRONZE = "#E09A55"
BRONZE_D = "#8A5A2B"
BASE = "#9AA3B2"
GOLD_W = "#FFF1B8"
GHOST = "#3C4452"
GHOST_T = "#A08868"
WOOD_TOP = "#C8894A"
WOOD_EDGE = "#8A5A2B"
WOOD = "#3E2614"
LIP_T = "#E8C9A0"
PLAQUE = "#24170C"

# --------------------------------------------------------------- layout
# The wall runs x 8..153; the banner hangs full height at x 158..185,
# in front of the shelf's right end; nothing lights outside x 6..185. The shelf top is
# y 23 with the walnut lip under it to the bottom row.
WALL_X = 8
WALL_R = 153
BAN_X0 = 158
BAN_X1 = 185
SHELF_Y = 23
SHELF_X0 = 6
SHELF_X1 = 185
GROUP_GAP = 6

# Literal paths: the lint only accepts asset names it can see.
LOGOS = {
    "ALA": "ALA.png", "AUB": "AUB.png", "UGA": "UGA.png", "FLA": "FLA.png", "LSU": "LSU.png",
    "TENN": "TENN.png", "TEX": "TEX.png", "OU": "OU.png", "TAMU": "TAMU.png", "MISS": "MISS.png",
    "ARK": "ARK.png", "SC": "SC.png", "MICH": "MICH.png", "OSU": "OSU.png", "PSU": "PSU.png",
    "NEB": "NEB.png", "USC": "USC.png", "ORE": "ORE.png", "WASH": "WASH.png", "UCLA": "UCLA.png",
    "MINN": "MINN.png", "IU": "IU.png", "WIS": "WIS.png", "CLEM": "CLEM.png", "FSU": "FSU.png",
    "MIA": "MIA.png", "VT": "VT.png", "STAN": "STAN.png", "GT": "GT.png", "PITT": "PITT.png",
    "SYR": "SYR.png", "COLO": "COLO.png", "BYU": "BYU.png", "TCU": "TCU.png", "TTU": "TTU.png",
    "ND": "ND.png", "BOIS": "BOIS.png", "ARMY": "ARMY.png", "NAVY": "NAVY.png",
}

# The 24 x 18 set for the banner, drawn at its authored size.
BANNER_LOGOS = {
    "ALA": "S_ALA.png", "AUB": "S_AUB.png", "UGA": "S_UGA.png", "FLA": "S_FLA.png", "LSU": "S_LSU.png",
    "TENN": "S_TENN.png", "TEX": "S_TEX.png", "OU": "S_OU.png", "TAMU": "S_TAMU.png", "MISS": "S_MISS.png",
    "ARK": "S_ARK.png", "SC": "S_SC.png", "MICH": "S_MICH.png", "OSU": "S_OSU.png", "PSU": "S_PSU.png",
    "NEB": "S_NEB.png", "USC": "S_USC.png", "ORE": "S_ORE.png", "WASH": "S_WASH.png", "UCLA": "S_UCLA.png",
    "MINN": "S_MINN.png", "IU": "S_IU.png", "WIS": "S_WIS.png", "CLEM": "S_CLEM.png", "FSU": "S_FSU.png",
    "MIA": "S_MIA.png", "VT": "S_VT.png", "STAN": "S_STAN.png", "GT": "S_GT.png", "PITT": "S_PITT.png",
    "SYR": "S_SYR.png", "COLO": "S_COLO.png", "BYU": "S_BYU.png", "TCU": "S_TCU.png", "TTU": "S_TTU.png",
    "ND": "S_ND.png", "BOIS": "S_BOIS.png", "ARMY": "S_ARMY.png", "NAVY": "S_NAVY.png",
}

# ---------------------------------------------------------------- data
# [dropdown label, logo, school, mascot, first season, claimed national
#  titles, Heisman winners (awards), home line (not drawn - see DESIGN), accent, second colour,
#  conference (2026), [[headline, story, icon, opponent logo or ""], ...]]
# Colours are each school's own, lifted where a navy or maroon would vanish
# on an LED. No apostrophes anywhere - the panel fonts have none.
#
# The stories are PROGRAM history - players, coaches, titles, trophies,
# rivalries, streaks. Stadium and gameday lore (the 12th Man, Jump Around,
# the Grove, Enter Sandman...) belongs to college-stadium-gameday, and each
# school keeps at most one Heisman story (heisman-trophy-history has the
# rest). A story that names another program carries its logo.
S = [
    ["ALABAMA", "ALA", "ALABAMA", "CRIMSON TIDE", 1892, 18, 4, "BRYANT-DENNY", "#E8304F", "#D8DDE4", "SEC", [
        ["CRIMSON TIDE", "A WRITER NAMED THE TIDE AFTER A 1907 GAME PLAYED IN RED MUD", "BOOK", ""],
        ["BEAR BRYANT", "PAUL BEAR BRYANT WON 6 NATIONAL TITLES IN 25 SEASONS AT BAMA", "CLIP", ""],
        ["NICK SABAN", "SABAN WON 6 NATIONAL TITLES AT ALABAMA FROM 2009 TO 2020", "CLIP", ""],
        ["BIG AL", "IN 1930 A SPORTSWRITER CALLED THE TEAM THE RED ELEPHANTS", "BOOK", ""],
        ["IRON BOWL", "NAMED FOR BIRMINGHAM AND ITS STEEL MILLS", "BALL", "AUB"],
    ]],
    ["AUBURN", "AUB", "AUBURN", "TIGERS", 1892, 2, 3, "JORDAN-HARE", "#FF7A1F", "#3F63C0", "SEC", [
        ["TOOMERS CORNER", "FANS ROLL THE OAKS AT TOOMERS CORNER WITH TOILET PAPER AFTER WINS", "TREE", ""],
        ["WAR EAGLE", "WAR EAGLE IS THE BATTLE CRY, NOT THE MASCOT - THE TEAM ARE TIGERS", "BIRD", ""],
        ["2010 TITLE", "CAM NEWTON AND THE 14-0 TIGERS BEAT OREGON 22-19", "CUP", "ORE"],
        ["SHUG JORDAN", "SHUG JORDAN WON THE 1957 TITLE AND 176 GAMES AT AUBURN", "CLIP", ""],
        ["OLDEST RIVALRY", "FIRST PLAYED IN 1892 - THE DEEP SOUTHS OLDEST RIVALRY", "BALL", "UGA"],
    ]],
    ["GEORGIA", "UGA", "GEORGIA", "BULLDOGS", 1892, 4, 2, "SANFORD STADIUM", "#FF2A3F", "#D8DDE4", "SEC", [
        ["UGA", "EVERY UGA MASCOT SINCE 1956 COMES FROM ONE LINE OF WHITE BULLDOGS", "PAW", ""],
        ["VINCE DOOLEY", "DOOLEY WON 201 GAMES FROM 1964 TO 1988 AND THE 1980 TITLE", "CLIP", ""],
        ["BACK TO BACK", "GEORGIA WON NATIONAL TITLES IN 2021 AND 2022", "CUP", ""],
        ["HERSCHEL", "HERSCHEL WALKER RAN TO THE 1982 HEISMAN TROPHY", "HEISMAN", ""],
        ["COCKTAIL PARTY", "THE WORLDS LARGEST OUTDOOR COCKTAIL PARTY", "BALL", "FLA"],
    ]],
    ["FLORIDA", "FLA", "FLORIDA", "GATORS", 1906, 3, 3, "THE SWAMP", "#FF5A1F", "#3F74E8", "SEC", [
        ["GATORADE", "GATORADE WAS INVENTED AT FLORIDA IN 1965 FOR THE FOOTBALL TEAM", "BOTTLE", ""],
        ["SPURRIER", "SPURRIER WON THE 1966 HEISMAN AND COACHED UF TO THE 1996 TITLE", "HEISMAN", ""],
        ["1996 REMATCH", "FELL 24-21, THEN WON THE TITLE REMATCH 52-20", "CUP", "FSU"],
        ["URBAN MEYER", "MEYER COACHED FLORIDA TO NATIONAL TITLES IN 2006 AND 2008", "CLIP", ""],
        ["2006 TITLE", "THE GATORS ROUTED NO. 1 OHIO STATE 41-14 FOR THE TITLE", "CUP", "OSU"],
    ]],
    ["LSU", "LSU", "LSU", "TIGERS", 1893, 4, 3, "DEATH VALLEY", "#FDD023", "#9A6BF0", "SEC", [
        ["MIKE THE TIGER", "A LIVE TIGER NAMED MIKE HAS BEEN THE LSU MASCOT SINCE 1936", "PAW", ""],
        ["2007 TITLE", "THE ONLY TWO-LOSS BCS CHAMPION: 38-24 OVER OHIO STATE", "CUP", "OSU"],
        ["BILLY CANNON", "HIS 89-YARD PUNT RETURN BEAT OLE MISS ON HALLOWEEN, 1959", "BALL", "MISS"],
        ["2019", "JOE BURROW THREW 60 TD PASSES AS LSU WENT 15-0 AND WON IT ALL", "CUP", ""],
        ["HEISMAN QBS", "JOE BURROW WON IN 2019, JAYDEN DANIELS IN 2023", "HEISMAN", ""],
    ]],
    ["TENNESSEE", "TENN", "TENNESSEE", "VOLUNTEERS", 1891, 6, 0, "NEYLAND STADIUM", "#FF8A1F", "#F4F7FF", "SEC", [
        ["ROCKY TOP", "A 1967 BLUEGRASS SONG, NOW THE MOST PLAYED TUNE IN NEYLAND", "NOTE", ""],
        ["1998 TITLE", "13-0 AND THE FIRST BCS TITLE, 23-16 OVER FLORIDA STATE", "CUP", "FSU"],
        ["CHECKERBOARD", "ORANGE AND WHITE CHECKERBOARD END ZONES DATE TO 1964", "STADIUM", ""],
        ["THIRD SATURDAY", "THE ALABAMA GAME: THE THIRD SATURDAY IN OCTOBER", "BALL", "ALA"],
        ["SMOKEY", "A BLUETICK COONHOUND NAMED SMOKEY HAS LED THE VOLS SINCE 1953", "PAW", ""],
    ]],
    ["TEXAS", "TEX", "TEXAS", "LONGHORNS", 1893, 4, 2, "DKR MEMORIAL", "#F07A30", "#F4F7FF", "SEC", [
        ["BEVO", "BEVO, A LIVE LONGHORN STEER, HAS BEEN THE MASCOT SINCE 1916", "HORNS", ""],
        ["HOOK EM", "THE HOOK EM HORNS HAND SIGN DEBUTED AT A 1955 PEP RALLY", "HORNS", ""],
        ["VINCE YOUNG", "HIS LATE TD BEAT USC IN THE ROSE BOWL FOR THE 2005 TITLE", "CUP", "USC"],
        ["RED RIVER", "TEXAS AND OKLAHOMA MEET IN DALLAS DURING THE STATE FAIR", "BALL", "OU"],
        ["EARL CAMPBELL", "THE TYLER ROSE RAN TO THE 1977 HEISMAN TROPHY", "HEISMAN", ""],
    ]],
    ["OKLAHOMA", "OU", "OKLAHOMA", "SOONERS", 1895, 7, 7, "OWEN FIELD", "#E8304F", "#F4E9D0", "SEC", [
        ["SOONER SCHOONER", "A COVERED WAGON PULLED BY TWO PONIES, BOOMER AND SOONER", "WAGON", ""],
        ["47 STRAIGHT", "OU WON 47 IN A ROW, 1953 TO 1957, UNTIL NOTRE DAME WON 7-0", "BALL", "ND"],
        ["SOONERS", "SETTLERS WHO SLIPPED IN EARLY TO CLAIM LAND IN THE 1889 LAND RUN", "BOOK", ""],
        ["BUD WILKINSON", "HE WON 3 NATIONAL TITLES IN THE 1950S", "CLIP", ""],
        ["HEISMAN QBS", "BACK TO BACK: BAKER MAYFIELD IN 2017, KYLER MURRAY IN 2018", "HEISMAN", ""],
    ]],
    ["TEXAS A&M", "TAMU", "TEXAS A&M", "AGGIES", 1894, 3, 2, "KYLE FIELD", "#C0405A", "#F4F7FF", "SEC", [
        ["JUNCTION BOYS", "1954: BEAR BRYANT RAN A BRUTAL 10-DAY CAMP IN JUNCTION, TEXAS", "CLIP", ""],
        ["MIDNIGHT YELL", "FANS PRACTICE THEIR YELLS AT MIDNIGHT BEFORE HOME GAMES", "MEGA", ""],
        ["REVEILLE", "A ROUGH COLLIE, THE HIGHEST RANKING MEMBER OF THE CORPS OF CADETS", "PAW", ""],
        ["YELL LEADERS", "A&M HAS YELL LEADERS, NOT CHEERLEADERS", "MEGA", ""],
        ["JOHNNY FOOTBALL", "MANZIEL WAS THE FIRST FRESHMAN TO WIN THE HEISMAN, IN 2012", "HEISMAN", ""],
    ]],
    ["OLE MISS", "MISS", "OLE MISS", "REBELS", 1893, 3, 0, "VAUGHT-HEMINGWAY", "#FF304A", "#4F7FE8", "SEC", [
        ["EGG BOWL", "OLE MISS AND MISSISSIPPI STATE PLAY FOR THE GOLDEN EGG, SINCE 1927", "CUP", ""],
        ["NUMBER 18", "ARCHIE MANNING WORE 18, SO THE CAMPUS SPEED LIMIT IS 18 MPH", "JERSEY", ""],
        ["HOTTY TODDY", "THE REBEL CHEER - AND THE WAY OLE MISS FANS SAY HELLO", "MEGA", ""],
        ["JOHNNY VAUGHT", "VAUGHT COACHED OLE MISS TO 6 SEC TITLES", "CLIP", ""],
        ["THE MANNINGS", "ARCHIE WAS QB FROM 1968 TO 1970, HIS SON ELI FROM 2000 TO 2003", "JERSEY", ""],
    ]],
    ["ARKANSAS", "ARK", "ARKANSAS", "RAZORBACKS", 1894, 1, 0, "RAZORBACK STADIUM", "#E8304F", "#F4F7FF", "SEC", [
        ["GOLDEN BOOT", "A GOLD TROPHY SHAPED LIKE THE TWO STATES, SINCE 1996", "CUP", "LSU"],
        ["RAZORBACKS", "A 1909 COACH SAID HIS TEAM PLAYED LIKE A BAND OF WILD RAZORBACK HOGS", "BOOK", ""],
        ["TUSK", "THE LIVE MASCOT IS A RUSSIAN BOAR NAMED TUSK", "PAW", ""],
        ["1964", "THE 1964 HOGS WENT 11-0 AND CLAIMED THE NATIONAL TITLE", "CUP", ""],
        ["BIG SHOOTOUT", "1969: NO. 1 TEXAS WON 15-14 WITH NIXON IN THE STANDS", "BALL", "TEX"],
    ]],
    ["SOUTH CAROLINA", "SC", "SOUTH CAROLINA", "GAMECOCKS", 1892, 0, 1, "WILLIAMS-BRICE", "#E0304F", "#F4F7FF", "SEC", [
        ["GAMECOCKS", "NAMED FOR GENERAL THOMAS SUMTER, THE FIGHTING GAMECOCK", "BIRD", ""],
        ["SPURRIER", "STEVE SPURRIER WENT 11-2 THREE YEARS RUNNING, 2011 TO 2013", "CLIP", ""],
        ["THE HIT", "CLOWNEYS HELMET-POPPING HIT, 2013 OUTBACK BOWL", "HELMET", "MICH"],
        ["PALMETTO BOWL", "THE CLEMSON GAME, FIRST PLAYED IN 1896", "BALL", "CLEM"],
        ["GEORGE ROGERS", "THE TAILBACK WON THE SCHOOLS ONLY HEISMAN IN 1980", "HEISMAN", ""],
    ]],
    ["MICHIGAN", "MICH", "MICHIGAN", "WOLVERINES", 1879, 12, 3, "THE BIG HOUSE", "#FFCB05", "#4F74E0", "BIG TEN", [
        ["2023 TITLE", "THE 15-0 WOLVERINES BEAT WASHINGTON 34-13 FOR THE TITLE", "CUP", "WASH"],
        ["WINGED HELMET", "FRITZ CRISLER BROUGHT THE WINGED HELMET TO MICHIGAN IN 1938", "HELMET", ""],
        ["THE GAME", "MICHIGAN VS OHIO STATE, PLAYED SINCE 1897", "BALL", "OSU"],
        ["1,000 WINS", "IN 2023 MICHIGAN BECAME THE FIRST PROGRAM TO WIN 1,000 GAMES", "CUP", ""],
        ["THE BANNER", "PLAYERS LEAP TO TOUCH THE GO BLUE BANNER RUNNING ONTO THE FIELD", "STADIUM", ""],
    ]],
    ["OHIO STATE", "OSU", "OHIO STATE", "BUCKEYES", 1890, 9, 7, "THE HORSESHOE", "#FF2A3F", "#B8C0C8", "BIG TEN", [
        ["SCRIPT OHIO", "THE BAND SPELLS OHIO IN SCRIPT AND A SOUSAPHONE DOTS THE I", "DRUM", ""],
        ["BUCKEYE LEAVES", "PLAYERS EARN BUCKEYE LEAF STICKERS FOR THEIR HELMETS", "HELMET", ""],
        ["ARCHIE GRIFFIN", "THE ONLY TWO-TIME HEISMAN WINNER: 1974 AND 1975", "HEISMAN", ""],
        ["GOLD PANTS", "BEAT MICHIGAN AND EACH PLAYER GETS A GOLD PANTS CHARM", "CUP", "MICH"],
        ["FIRST PLAYOFF", "BEAT OREGON 42-20 TO WIN THE FIRST PLAYOFF, 2014", "CUP", "ORE"],
        ["2024 TITLE", "BEAT NOTRE DAME 34-23 TO WIN THE 12-TEAM PLAYOFF", "CUP", "ND"],
    ]],
    ["PENN STATE", "PSU", "PENN STATE", "NITTANY LIONS", 1887, 2, 1, "BEAVER STADIUM", "#4F7FE8", "#F4F7FF", "BIG TEN", [
        ["1986 TITLE", "PENN STATE BEAT NO. 1 MIAMI 14-10 IN THE FIESTA BOWL", "CUP", "MIA"],
        ["NITTANY LION", "NAMED FOR MOUNT NITTANY, WHICH LOOKS DOWN ON CAMPUS", "PAW", ""],
        ["WE ARE", "ONE SIDE YELLS WE ARE, THE OTHER ANSWERS PENN STATE", "MEGA", ""],
        ["JOE PATERNO", "46 SEASONS AS HEAD COACH, 1966 TO 2011 - TITLES IN 1982 AND 1986", "CLIP", ""],
        ["CAPPELLETTI", "JOHN CAPPELLETTI WON THE 1973 HEISMAN TROPHY", "HEISMAN", ""],
    ]],
    ["NEBRASKA", "NEB", "NEBRASKA", "CORNHUSKERS", 1890, 5, 3, "MEMORIAL STADIUM", "#FF2A3F", "#F4F7FF", "BIG TEN", [
        ["GAME OF THE CENTURY", "1971: NO. 1 NEBRASKA BEAT NO. 2 OKLAHOMA 35-31", "BALL", "OU"],
        ["BLACKSHIRTS", "STARTING DEFENDERS EARN BLACK PRACTICE JERSEYS", "JERSEY", ""],
        ["TOM OSBORNE", "OSBORNE WON 3 TITLES IN 4 YEARS: 1994, 1995 AND 1997", "CLIP", ""],
        ["1995 TITLE", "THE HUSKERS ROUTED FLORIDA 62-24 IN THE FIESTA BOWL", "CUP", "FLA"],
        ["HEISMANS", "JOHNNY RODGERS 1972, MIKE ROZIER 1983, ERIC CROUCH 2001", "HEISMAN", ""],
    ]],
    ["USC", "USC", "USC", "TROJANS", 1888, 11, 8, "THE COLISEUM", "#E8304A", "#FFC72C", "BIG TEN", [
        ["TRAVELER", "A WHITE HORSE NAMED TRAVELER GALLOPS AFTER EVERY USC SCORE", "HORSE", ""],
        ["JOHN MCKAY", "MCKAY WON 4 NATIONAL TITLES: 1962, 1967, 1972 AND 1974", "CLIP", ""],
        ["VICTORY BELL", "USC AND UCLA PLAY FOR A BELL FROM AN OLD LOCOMOTIVE", "BELL", "UCLA"],
        ["TOMMY TROJAN", "THE STATUE IS WRAPPED IN DUCT TAPE BEFORE THE UCLA GAME", "HELMET", ""],
        ["TAILBACK U", "O.J. SIMPSON, CHARLES WHITE AND MARCUS ALLEN WON HEISMANS", "HEISMAN", ""],
    ]],
    ["OREGON", "ORE", "OREGON", "DUCKS", 1894, 0, 1, "AUTZEN STADIUM", "#FEE123", "#2FC46A", "BIG TEN", [
        ["THE DUCK", "THE MASCOT IS DONALD DUCK, BY A HANDSHAKE DEAL WITH DISNEY", "BIRD", ""],
        ["PHIL KNIGHT", "THE NIKE CO-FOUNDER RAN TRACK AT OREGON", "BOOK", ""],
        ["TITLE GAMES", "OREGON PLAYED FOR THE NATIONAL TITLE AFTER THE 2010 AND 2014 SEASONS", "BALL", ""],
        ["MARIOTA", "MARCUS MARIOTA WON OREGONS FIRST HEISMAN IN 2014", "HEISMAN", ""],
    ]],
    ["WASHINGTON", "WASH", "WASHINGTON", "HUSKIES", 1889, 2, 0, "HUSKY STADIUM", "#9A6BF0", "#E8D3A2", "BIG TEN", [
        ["PENIX", "PENIX LED UW TO 14-0 IN 2023 BEFORE LOSING THE FINAL", "BALL", "MICH"],
        ["THE WAVE", "UW CLAIMS THE CROWD WAVE WAS BORN AT HUSKY STADIUM IN 1981", "MEGA", ""],
        ["DON JAMES", "THE DAWGFATHER WENT 12-0 IN 1991 AND SHARED THE TITLE", "CLIP", ""],
        ["DUBS", "THE LIVE MASCOT IS AN ALASKAN MALAMUTE NAMED DUBS", "PAW", ""],
    ]],
    ["UCLA", "UCLA", "UCLA", "BRUINS", 1919, 1, 1, "THE ROSE BOWL", "#4FA8F0", "#FFD100", "BIG TEN", [
        ["VICTORY BELL", "UCLA AND USC PLAY FOR THE BELL, SINCE 1942", "BELL", "USC"],
        ["JACKIE ROBINSON", "HE STARRED AT UCLA IN 1939 AND 1940, YEARS BEFORE BASEBALL", "JERSEY", ""],
        ["1954", "RED SANDERS TEAM WENT 9-0 FOR THE UCLA NATIONAL TITLE", "CUP", ""],
        ["GARY BEBAN", "THE QUARTERBACK WON THE 1967 HEISMAN", "HEISMAN", ""],
        ["THE 8-CLAP", "EIGHT CLAPS, THEN U-C-L-A, THEN FIGHT FIGHT FIGHT", "MEGA", ""],
    ]],
    ["MINNESOTA", "MINN", "MINNESOTA", "GOLDEN GOPHERS", 1882, 7, 1, "HUNTINGTON BANK", "#E0405A", "#FFCC33", "BIG TEN", [
        ["LITTLE BROWN JUG", "PLAYED FOR SINCE 1909 - MICHIGAN LEFT IT BEHIND IN 1903", "CUP", "MICH"],
        ["PAUL BUNYANS AXE", "MINNESOTA AND WISCONSIN PLAY FOR AN AXE", "AXE", "WIS"],
        ["BERNIE BIERMAN", "HE WON 5 NATIONAL TITLES IN THE 1930S AND 1940S", "CLIP", ""],
        ["SKI-U-MAH", "THE GOPHER BATTLE CRY SINCE THE 1880S", "MEGA", ""],
        ["BRUCE SMITH", "THE HALFBACK WON THE 1941 HEISMAN", "HEISMAN", ""],
    ]],
    ["INDIANA", "IU", "INDIANA", "HOOSIERS", 1887, 1, 1, "MEMORIAL STADIUM", "#E8304A", "#F4F7FF", "BIG TEN", [
        ["OLD OAKEN BUCKET", "INDIANA AND PURDUE HAVE PLAYED FOR A WATER BUCKET SINCE 1925", "CUP", ""],
        ["CIGNETTI", "CURT CIGNETTI TOOK A 3-9 TEAM TO 11-2 IN HIS FIRST YEAR, 2024", "CLIP", ""],
        ["2025 TITLE", "IU WENT 16-0 AND BEAT MIAMI 27-21 FOR ITS FIRST NATIONAL TITLE", "CUP", "MIA"],
        ["MENDOZA", "FERNANDO MENDOZA WON THE 2025 HEISMAN, THE FIRST IN IU HISTORY", "HEISMAN", ""],
        ["HOOSIER", "NOBODY AGREES WHERE THE WORD HOOSIER CAME FROM", "BOOK", ""],
    ]],
    ["WISCONSIN", "WIS", "WISCONSIN", "BADGERS", 1889, 0, 2, "CAMP RANDALL", "#E8304A", "#F4F7FF", "BIG TEN", [
        ["BARRY ALVAREZ", "ALVAREZ WON THREE ROSE BOWLS, IN 1994, 1999 AND 2000", "CLIP", ""],
        ["RON DAYNE", "HE WON THE 1999 HEISMAN AS THE FBS CAREER RUSHING LEADER", "HEISMAN", ""],
        ["MELVIN GORDON", "HE RAN FOR 408 YARDS AGAINST NEBRASKA IN 2014", "JERSEY", "NEB"],
        ["PAUL BUNYANS AXE", "MINNESOTA SINCE 1890 - THE MOST PLAYED RIVALRY IN THE FBS", "AXE", "MINN"],
        ["JONATHAN TAYLOR", "6,174 RUSHING YARDS IN JUST THREE SEASONS, 2017 TO 2019", "JERSEY", ""],
    ]],
    ["CLEMSON", "CLEM", "CLEMSON", "TIGERS", 1896, 3, 0, "DEATH VALLEY", "#FF7A1F", "#9A6BF0", "ACC", [
        ["HOWARDS ROCK", "A ROCK FROM DEATH VALLEY, CALIFORNIA. PLAYERS RUB IT FOR LUCK", "ROCK", ""],
        ["2016 TITLE", "WATSON THREW THE WINNING TD WITH ONE SECOND LEFT, 35-31", "CUP", "ALA"],
        ["1981", "DANNY FORDS TEAM WENT 12-0 FOR CLEMSONS FIRST TITLE", "CUP", ""],
        ["DABO", "DABO SWINNEY WON NATIONAL TITLES IN 2016 AND 2018", "CLIP", ""],
        ["TIGER PAW", "THE ORANGE PAW LOGO FIRST APPEARED IN 1970", "PAW", ""],
    ]],
    ["FLORIDA STATE", "FSU", "FLORIDA STATE", "SEMINOLES", 1947, 3, 3, "DOAK CAMPBELL", "#E0405A", "#D8BE88", "ACC", [
        ["OSCEOLA", "OSCEOLA RIDES RENEGADE TO MIDFIELD AND PLANTS A FLAMING SPEAR", "FLAME", ""],
        ["BOBBY BOWDEN", "BOWDEN WON NATIONAL TITLES AT FSU IN 1993 AND 1999", "CLIP", ""],
        ["WIRE TO WIRE", "IN 1999 FSU WAS FIRST TO SPEND A WHOLE SEASON AP NO. 1", "CUP", ""],
        ["WIDE RIGHT", "1991: A LATE FSU KICK SAILED WIDE RIGHT AND MIAMI WON 17-16", "BALL", "MIA"],
        ["HEISMANS", "CHARLIE WARD 1993, CHRIS WEINKE 2000, JAMEIS WINSTON 2013", "HEISMAN", ""],
    ]],
    ["MIAMI", "MIA", "MIAMI", "HURRICANES", 1926, 5, 2, "HARD ROCK STADIUM", "#FF7A1F", "#1FC47A", "ACC", [
        ["THE U", "MIAMI WON 5 NATIONAL TITLES FROM 1983 TO 2001", "CUP", ""],
        ["1983 TITLE", "MIAMI UPSET NO. 1 NEBRASKA 31-30 IN THE ORANGE BOWL", "CUP", "NEB"],
        ["TURNOVER CHAIN", "IN 2017 MIAMI STARTED GIVING A GOLD CHAIN FOR EVERY TAKEAWAY", "CHAIN", ""],
        ["SEBASTIAN", "THE IBIS, SAID TO BE THE LAST TO FLEE AND FIRST BACK AFTER A STORM", "BIRD", ""],
        ["58 STRAIGHT", "MIAMI WON 58 HOME GAMES IN A ROW AT THE ORANGE BOWL, 1985-1994", "STADIUM", ""],
    ]],
    ["VIRGINIA TECH", "VT", "VIRGINIA TECH", "HOKIES", 1892, 0, 0, "LANE STADIUM", "#FF7A2F", "#C0405A", "ACC", [
        ["FRANK BEAMER", "BEAMER COACHED HIS ALMA MATER FOR 29 SEASONS AND WON 238 GAMES", "CLIP", ""],
        ["BRUCE SMITH", "THE NFL ALL-TIME SACK LEADER PLAYED HIS COLLEGE BALL AT VT", "JERSEY", ""],
        ["BEAMERBALL", "FRANK BEAMERS TEAMS WERE FAMOUS FOR BLOCKING KICKS", "BALL", ""],
        ["HOKIE", "THE WORD COMES FROM THE OLD HOKIE CHEER, WRITTEN IN 1896", "BOOK", ""],
        ["MICHAEL VICK", "VICK LED THE 11-0 HOKIES TO THE 1999 TITLE GAME VS FSU", "JERSEY", "FSU"],
    ]],
    ["STANFORD", "STAN", "STANFORD", "CARDINAL", 1891, 2, 1, "STANFORD STADIUM", "#E8304A", "#F4F7FF", "ACC", [
        ["THE PLAY", "1982: CAL LATERALED 5 TIMES THROUGH THE STANFORD BAND TO WIN", "BALL", ""],
        ["THE TREE", "THE MASCOT IS A TREE - THE CARDINAL IS A COLOR, NOT A BIRD", "TREE", ""],
        ["THE BIG GAME", "STANFORD AND CAL PLAY THE BIG GAME FOR THE STANFORD AXE", "AXE", ""],
        ["FIRST ROSE BOWL", "STANFORD PLAYED MICHIGAN IN THE FIRST ROSE BOWL, IN 1902", "STADIUM", "MICH"],
        ["JIM PLUNKETT", "THE QUARTERBACK WON THE 1970 HEISMAN", "HEISMAN", ""],
    ]],
    ["GEORGIA TECH", "GT", "GEORGIA TECH", "YELLOW JACKETS", 1892, 4, 0, "BOBBY DODD", "#D8C27A", "#F4F7FF", "ACC", [
        ["1990 TITLE", "TECH WENT 11-0-1 AND SHARED THE NATIONAL TITLE WITH COLORADO", "CUP", "COLO"],
        ["JOHN HEISMAN", "THE MAN THE TROPHY IS NAMED FOR COACHED TECH FROM 1904 TO 1919", "HEISMAN", ""],
        ["MEGATRON", "CALVIN JOHNSON WON THE 2006 BILETNIKOFF AWARD AT TECH", "JERSEY", ""],
        ["WRONG WAY", "1929 ROSE BOWL: CALS ROY RIEGELS RAN THE WRONG WAY. TECH WON 8-7", "BALL", ""],
        ["OLD-FASHIONED HATE", "THE GEORGIA GAME IS CLEAN, OLD-FASHIONED HATE", "BALL", "UGA"],
    ]],
    ["PITT", "PITT", "PITTSBURGH", "PANTHERS", 1890, 9, 1, "ACRISURE STADIUM", "#FFB81C", "#4F7FE8", "ACC", [
        ["TONY DORSETT", "DORSETT WON THE 1976 HEISMAN AND PITT WON THE TITLE", "HEISMAN", ""],
        ["BACKYARD BRAWL", "PITT AND WEST VIRGINIA HAVE FOUGHT IT OUT SINCE 1895", "BALL", ""],
        ["SWEET CAROLINE", "THE WHOLE STADIUM SINGS IT BEFORE THE 4TH QUARTER", "NOTE", ""],
        ["CATHEDRAL", "THE CATHEDRAL OF LEARNING IS LIT GOLD AFTER A WIN", "TOWER", ""],
        ["DAN MARINO", "MARINO WAS THE PANTHERS QUARTERBACK FROM 1979 TO 1982", "JERSEY", ""],
    ]],
    ["SYRACUSE", "SYR", "SYRACUSE", "ORANGE", 1889, 1, 1, "THE DOME", "#FF7A1F", "#4F7FE8", "ACC", [
        ["1959", "BEN SCHWARTZWALDERS TEAM WENT 11-0 AND WON THE NATIONAL TITLE", "CUP", ""],
        ["ERNIE DAVIS", "IN 1961 HE BECAME THE FIRST BLACK PLAYER TO WIN THE HEISMAN", "HEISMAN", ""],
        ["NUMBER 44", "WORN BY JIM BROWN, ERNIE DAVIS AND FLOYD LITTLE - RETIRED IN 2005", "JERSEY", ""],
        ["OTTO", "THE MASCOT IS OTTO THE ORANGE - A WALKING, SMILING ORANGE", "BOOK", ""],
    ]],
    ["COLORADO", "COLO", "COLORADO", "BUFFALOES", 1890, 1, 2, "FOLSOM FIELD", "#E0C888", "#F4F7FF", "BIG 12", [
        ["RALPHIE", "A LIVE BUFFALO CHARGES THE FIELD WITH FIVE HANDLERS RUNNING BESIDE", "HORNS", ""],
        ["1990", "BILL MCCARTNEYS BUFFS SHARED THE 1990 NATIONAL TITLE", "CUP", ""],
        ["FIFTH DOWN", "1990: A MISCOUNTED FIFTH DOWN GAVE CU THE WIN AT MISSOURI", "BALL", ""],
        ["MIRACLE", "1994: KORDELL STEWARTS HAIL MARY BEAT MICHIGAN", "BALL", "MICH"],
        ["HEISMANS", "RASHAAN SALAAM IN 1994, TRAVIS HUNTER IN 2024", "HEISMAN", ""],
    ]],
    ["BYU", "BYU", "BYU", "COUGARS", 1922, 1, 1, "LAVELL EDWARDS", "#4F84F0", "#F4F7FF", "BIG 12", [
        ["1984", "BYU WENT 13-0 AND WON THE 1984 NATIONAL TITLE", "CUP", ""],
        ["TY DETMER", "THE QUARTERBACK WON THE 1990 HEISMAN", "HEISMAN", ""],
        ["LAVELL EDWARDS", "THE STADIUM NAMESAKE WON 257 GAMES AS BYU HEAD COACH", "CLIP", ""],
        ["QB FACTORY", "JIM MCMAHON AND STEVE YOUNG BOTH PLAYED QUARTERBACK AT BYU", "JERSEY", ""],
        ["COSMO", "COSMO THE COUGAR HAS BEEN THE MASCOT SINCE 1953", "PAW", ""],
    ]],
    ["TCU", "TCU", "TCU", "HORNED FROGS", 1896, 2, 1, "AMON G. CARTER", "#9A5CF0", "#F4F7FF", "BIG 12", [
        ["HORNED FROG", "A HORNED FROG IS A LIZARD, NOT A FROG", "BOOK", ""],
        ["DAVEY OBRIEN", "THE QUARTERBACK WON THE 1938 HEISMAN", "HEISMAN", ""],
        ["ROSE BOWL", "THE 13-0 FROGS BEAT WISCONSIN 21-19, JAN 2011", "CUP", "WIS"],
        ["2022", "TCU REACHED THE COLLEGE FOOTBALL PLAYOFF TITLE GAME", "BALL", ""],
        ["SAMMY BAUGH", "SLINGIN SAMMY STARRED AT TCU BEFORE HIS HALL OF FAME NFL CAREER", "JERSEY", ""],
    ]],
    ["TEXAS TECH", "TTU", "TEXAS TECH", "RED RAIDERS", 1925, 0, 0, "JONES AT&T", "#FF2A3F", "#F4F7FF", "BIG 12", [
        ["MASKED RIDER", "A MASKED RIDER GALLOPS A BLACK HORSE ONTO THE FIELD", "HORSE", ""],
        ["GUNS UP", "FANS SALUTE WITH THE GUNS UP HAND SIGN", "MEGA", ""],
        ["2025 BIG 12", "TECH BEAT BYU 34-7 FOR ITS FIRST BIG 12 TITLE", "CUP", "BYU"],
        ["CRABTREE", "2008: CRABTREES TD BEAT NO. 1 TEXAS WITH ONE SECOND LEFT", "BALL", "TEX"],
        ["AIR RAID", "MIKE LEACH RAN HIS AIR RAID OFFENSE AT TECH FROM 2000 TO 2009", "CLIP", ""],
    ]],
    ["NOTRE DAME", "ND", "NOTRE DAME", "FIGHTING IRISH", 1887, 11, 7, "ND STADIUM", "#E0B530", "#4F74E0", "INDEP.", [
        ["TOUCHDOWN JESUS", "THE WORD OF LIFE MURAL LOOMS OVER THE NORTH END ZONE", "STADIUM", ""],
        ["CATHOLICS VS CONVICTS", "1988: BEAT NO. 1 MIAMI 31-30 ON THE WAY TO A 12-0 TITLE", "BALL", "MIA"],
        ["THE GIPPER", "ROCKNE: WIN ONE FOR THE GIPPER - VS ARMY, 1928", "MEGA", "ARMY"],
        ["FOUR HORSEMEN", "THE 1924 BACKFIELD, NAMED BY SPORTSWRITER GRANTLAND RICE", "HORSE", ""],
        ["GOLD HELMETS", "THE HELMET PAINT IS MIXED WITH GOLD FROM THE GOLDEN DOME", "HELMET", ""],
    ]],
    ["BOISE STATE", "BOIS", "BOISE STATE", "BRONCOS", 1933, 0, 0, "THE BLUE", "#4F8AF0", "#FF7A1F", "PAC-12", [
        ["CHRIS PETERSEN", "PETERSEN WENT 92-12 AS BOISE STATE HEAD COACH, 2006 TO 2013", "CLIP", ""],
        ["STATUE OF LIBERTY", "2007 FIESTA BOWL: A TRICK PLAY BEAT OKLAHOMA IN OVERTIME", "BALL", "OU"],
        ["FIESTA BOWLS", "BOISE STATE HAS WON THE FIESTA BOWL THREE TIMES", "CUP", ""],
        ["ASHTON JEANTY", "HE RAN FOR 2,601 YARDS IN 2024, SECOND ONLY TO BARRY SANDERS", "JERSEY", ""],
    ]],
    ["ARMY", "ARMY", "ARMY", "BLACK KNIGHTS", 1890, 3, 3, "MICHIE STADIUM", "#E0C888", "#B8C0C8", "AMERICAN", [
        ["ARMY-NAVY", "CADETS AND MIDSHIPMEN FIRST MET ON THE FIELD IN 1890", "BALL", "NAVY"],
        ["MR. INSIDE & OUTSIDE", "DOC BLANCHARD AND GLENN DAVIS WON HEISMANS IN 1945 AND 1946", "HEISMAN", ""],
        ["SING SECOND", "BOTH TEAMS SING BOTH ALMA MATERS - THE WINNER SINGS LAST", "NOTE", ""],
        ["THE MULE", "THE MASCOT IS A MULE, THE ARMYS OLD PACK ANIMAL", "HORSE", ""],
        ["CIC TROPHY", "ARMY, NAVY AND AIR FORCE PLAY FOR THE COMMANDER IN CHIEFS TROPHY", "CUP", ""],
    ]],
    ["NAVY", "NAVY", "NAVY", "MIDSHIPMEN", 1879, 1, 2, "NAVY-MARINE CORPS", "#E0C888", "#4F74E0", "AMERICAN", [
        ["BILL THE GOAT", "A GOAT NAMED BILL HAS BEEN NAVYS MASCOT SINCE 1893", "HORNS", ""],
        ["STAUBACH", "ROGER STAUBACH WON THE 1963 HEISMAN BEFORE SERVING IN THE NAVY", "HEISMAN", ""],
        ["14 STRAIGHT", "NAVY BEAT ARMY 14 YEARS IN A ROW, 2002 TO 2015", "BALL", "ARMY"],
        ["KEENAN REYNOLDS", "THE QB SCORED 88 TOUCHDOWNS FROM 2012 TO 2015, AN FBS RECORD", "JERSEY", ""],
    ]],
]

ALL = "ALL - ROTATE"
BY_LABEL = {s[0]: s for s in S}

# ------------------------------------------------------------ pixel art
# Tradition icons, drawn at 1x in the icon zone (x 163..185). X takes the
# school's accent, S its second colour; the rest are fixed so a bell is
# always gold and a tree always green.
ICONS = {
    "CUP": ["""
.YYYYYYYYYYY.
YYYWWYYYYYYYY
Y.YWYYYYYYY.Y
Y.YWYYYYYYY.Y
YY.YYYYYYY.YY
.YYYYYYYYYYY.
..YYYYYYYYY..
...DYYYYYD...
.....YYY.....
.....YYY.....
....DDDDD....
...XXXXXXX...
...XXXXXXX...
..DDDDDDDDD..
""", {"Y": "#FFC233", "W": "#FFF1B8", "D": "#B07A10"}],
    "HEISMAN": ["""
.........XXX...
........XXXXX..
........XXXXX..
.........XXX...
.XXXXXXXXXXXX..
XX......XXXXBB.
........XXXBBB.
........XXXXB..
.........XXX...
........XXXXX..
.......XX...XX.
......XX.....XX
.....XX.......X
....XX........X
.....X.........
.PPPPPPPPPPPP..
.DDDDDDDDDDDD..
""", {"X": "#E09A55", "B": "#7A4A20", "P": "#9AA3B2", "D": "#5A6270"}],
    "BELL": ["""
.......WW.......
......YYYY......
.....YYYYYY.....
....YWYYYYYY....
....YWYYYYYY....
....YWYYYYYY....
...YWYYYYYYYY...
...YWYYYYYYYY...
..YYYYYYYYYYYY..
.YYYYYYYYYYYYYY.
DDDDDDDDDDDDDDDD
.......DD.......
.......DD.......
""", {"Y": "#FFC233", "W": "#FFF1B8", "D": "#B07A10"}],
    "NOTE": ["""
.....XXXXXXXXXXX
.....XXXXXXXXXXX
.....X.........X
.....X.........X
.....X.........X
.....X.........X
.....X.........X
.....X.........X
..XXXX......XXXX
.XXXXX.....XXXXX
.XXXXX.....XXXXX
..XXX.......XXX.
""", {}],
    "DRUM": ["""
W..............W
.W............W.
..W..........W..
...WWWWWWWWWW...
..XXXXXXXXXXXX..
.WWWWWWWWWWWWWW.
.XSXXSXXSXXSXXX.
.XXSXXSXXSXXSXX.
.XSXXSXXSXXSXXX.
.XXSXXSXXSXXSXX.
.WWWWWWWWWWWWWW.
..XXXXXXXXXXXX..
""", {"W": "#F4F7FF"}],
    "MEGA": ["""
............XX..
..........XXXX..
........XXXXXX..
WWWWWXXXXXXXXX..
WWWWWXXXXXXXXX.S
WWWWWXXXXXXXXX..
WWWWWXXXXXXXXX.S
WWWWWXXXXXXXXX..
.WW.....XXXXXX.S
.WW.......XXXX..
.WW.........XX..
""", {"W": "#F4F7FF", "S": "#6E7A94"}],
    "PAW": ["""
....XXX..XXX....
....XXX..XXX....
....XXX..XXX....
XXX..........XXX
XXX...XXXX...XXX
XXX..XXXXXX..XXX
....XXXXXXXX....
...XXXXXXXXXX...
...XXXXXXXXXX...
...XXXXXXXXXX...
....XXXXXXXX....
.....XX..XX.....
""", {}],
    "HORSE": ["""
......WW........
.....WWWW.......
....WWWWWWW.....
...WWKWWWWWW....
..WWWWWWWWWWS...
.WWWWWWW.WWWSS..
WWWWWW...WWWWSS.
WWWW.....WWWWWS.
.........WWWWWWS
.........WWWWWWS
........WWWWWWW.
........WWWWWWW.
.......WWWWWWWW.
""", {"W": "#F4F7FF", "K": "#1A1A1A", "S": "X"}],
    "BIRD": ["""
X..............X
XX............XX
XXX..........XXX
.XXX...WW...XXX.
.XXXX.WWKW.XXXX.
..XXXXWWWYXXXX..
...XXXXWWXXXX...
....XXXXXXXX....
.....XXXXXX.....
......XXXX......
.....YY..YY.....
""", {"W": "#F4F7FF", "K": "#1A1A1A", "Y": "#FFC233"}],
    "HORNS": ["""
X..............X
XX............XX
.XX..........XX.
..XXX......XXX..
...XXXWWWWXXX...
.....WWWWWW.....
.....WKWWKW.....
.....WWWWWW.....
......WWWW......
......WWWW......
.......WW.......
""", {"W": "#F4F7FF", "K": "#1A1A1A"}],
    "ROCK": ["""
.....SSSSS......
...SSWSSSSSS....
..SSWSSSSSSSS...
.SSSSSSSSSSSSS..
.SSSSSSSSSSSSSS.
SSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSDD
SSSSSSSSSSSSDDDD
.DDSSSSSSSSDDDD.
.XXXXXXXXXXXXXX.
XXXXXXXXXXXXXXXX
""", {"S": "#A7AFBC", "W": "#E8ECF2", "D": "#6B7383"}],
    "TREE": ["""
......GGGG......
....GGGGGGGG....
...GGGLGGGGGG...
..GGGGGGGGLGGG..
..GGLGGGGGGGGG..
.GGGGGGGGGGGGGG.
.GGGGGGLGGGGGGG.
..GGGGGGGGGGGG..
...GGGGGGGGGG...
......BBBB......
......BBBB......
......BBBB......
....BBBBBBBB....
""", {"G": "#2FC46A", "L": "#8BF0A8", "B": "#A0522D"}],
    "BOAT": ["""
.......W........
.......WX.......
.......WXX......
.......WXXX.....
.......WXXXX....
.......WXXXXX...
.......WXXXXXX..
.......W........
WWWWWWWWWWWWWWWW
.WWWWWWWWWWWWWW.
..WWWWWWWWWWWW..
BB.BB.BB.BB.BB.B
""", {"W": "#F4F7FF", "B": "#3F8BFF"}],
    "WAGON": ["""
....WWWWWWWW....
..WWWWWWWWWWWW..
.WWWWWWWWWWWWWW.
.WWWWWWWWWWWWWW.
.W.W.W.W.W.W.W..
.XXXXXXXXXXXXXX.
.XXXXXXXXXXXXXX.
..KKK......KKK..
.K.K.K....K.K.K.
..KKK......KKK..
""", {"W": "#F4F7FF", "K": "#C8A070"}],
    "HELMET": ["""
.....XXXXXXX....
...XXXXXXXXXXX..
..XXXSSSXXXXXXX.
.XXXXXXXSSXXXXX.
.XXXXXXXXXXXXXX.
XXXXXXXXXXXXXXX.
XXXXXXX.XXXXXXXG
XXXXXX.K.XXXXGGG
XXXXXXX.XXXXXG.G
.XXXXXXXXXXXXGGG
..XXXXXXXXXXXG.G
....XXXXXXX..GG.
""", {"K": "#1A1A1A", "G": "#9AA3B2"}],
    "BALL": ["""
.....DDDDDD.....
...DDBBBBBBDD...
..DBBBBBBBBBBD..
.DBBBWBWBWBWBBD.
DBBBWWWWWWWWWBBD
.DBBBWBWBWBWBBD.
..DBBBBBBBBBBD..
...DDBBBBBBDD...
.....DDDDDD.....
""", {"D": "#5A2E0E", "B": "#A0522D", "W": "#FFFFFF"}],
    "STADIUM": ["""
.W............W.
.WW..........WW.
.WWW........WWW.
XXXXXXXXXXXXXXXX
XSSSSSSSSSSSSSSX
XSXSXSXSXSXSXSSX
XSSSSSSSSSSSSSSX
XXXXXXXXXXXXXXXX
GGGGGGGGGGGGGGGG
GGWGGGGWWGGGGWGG
GGGGGGGGGGGGGGGG
""", {"W": "#FFF1B8", "G": "#2FC46A"}],
    "FLAME": ["""
.......R........
......RR.....R..
.....RRR....RR..
....RROR...RRR..
...RROORR.RRRR..
..RROOYORRRORR..
..ROOYYYOORORR..
.RROYYWYYOOORR..
.ROOYWWWYYOORR..
.ROYYWWWWYYOR...
..ROYYWWWYYOR...
...RRRRRRRRR....
""", {"R": "#FF3D00", "O": "#FF9100", "Y": "#FFE000", "W": "#FFF6C8"}],
    "CHAIN": ["""
Y..............Y
DY............YD
.Y............Y.
.DY..........YD.
..Y..........Y..
..DY........YD..
...YD......DY...
....YDY..YDY....
......YXXY......
.....XXXXXX.....
.....XWXXWX.....
.....XXWWXX.....
......XXXX......
""", {"Y": "#FFC233", "D": "#B07A10", "W": "#FFF1B8"}],
    "AXE": ["""
.......SSSS.....
......SSSSSS....
.....SSSSSSSB...
.....SSSSSSBBB..
......SSSSSSBBB.
.......SSSSBBB..
..........BBB...
.........BBB....
........BBB.....
.......BBB......
......BBB.......
.....BBB........
....BBB.........
""", {"S": "#C8D0DA", "B": "#A0522D"}],
    "TOWER": ["""
.......YY.......
......YYYY......
......WWWW......
.....WWWWWW.....
.....WYWWYW.....
.....WWWWWW.....
.....WYWWYW.....
.....WWWWWW.....
.....WYWWYW.....
.....WWWWWW.....
....WWWWWWWW....
...WWWWWWWWWW...
.WWWWWWWWWWWWWW.
""", {"W": "X", "Y": "#FFF1B8"}],
    "TRAIN": ["""
..XXXXXXXXXXXX..
.XXXXXXXXXXXXXX.
.XWWXXWWXXWWXXX.
.XWWXXWWXXWWXXX.
.XXXXXXXXXXXXXX.
.XXXXXXXXXXXXXX.
SSSSSSSSSSSSSSSS
..KKK......KKK..
.K.K.K....K.K.K.
..KKK......KKK..
GGGGGGGGGGGGGGGG
""", {"W": "#FFF1B8", "K": "#9AA3B2", "G": "#6E7A94"}],
    "TENT": ["""
.......XX.......
......XXXX......
.....XXWWXX.....
....XXWWWWXX....
...XXWWWWWWXX...
..XXWWWWWWWWXX..
.XXWWWWWWWWWWXX.
XXXXXXXXXXXXXXXX
.W............W.
.W............W.
.W............W.
""", {"W": "#F4F7FF"}],
    "BOOK": ["""
.WWWWWW..WWWWWW.
WWXXXWWWWWXXXWWW
WWWWWWWWWWWWWWWW
WWXXXXWWWWXXXXWW
WWWWWWWWWWWWWWWW
WWXXXWWWWWXXXXWW
WWWWWWWWWWWWWWWW
WWXXXXWWWWXXXWWW
WWWWWWWWWWWWWWWW
SSSSSSSSSSSSSSSS
""", {"W": "#F4F7FF", "S": "X"}],
    "CLIP": ["""
......GGGG......
.BBBBBGGGGBBBBB.
.BWWWWWWWWWWWWB.
.BWXWXWWWWOOWWB.
.BWWXWWWWOWWOWB.
.BWXWXWWWWOOWWB.
.BWWWWWWWWWWWWB.
.BWWWWWWXWWWWWB.
.BWWWWWXXXXXWWB.
.BWWWWWWXWWWWWB.
.BWWWWWWWWWWWWB.
.BBBBBBBBBBBBBB.
""", {"G": "#9AA3B2", "B": "#A0522D", "W": "#F4F7FF", "O": "#3F63C0"}],
    "JERSEY": ["""
...XXX....XXX...
.XXXXXXXXXXXXXX.
XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXX
XXX.XXXXXXXX.XXX
....XSSXXSSX....
....XXSXXXSX....
....XXSXXSXX....
....XXSXXXSX....
....XSSSXSSX....
....XXXXXXXX....
....XXXXXXXX....
""", {}],
    "BOTTLE": ["""
......WWWW......
......SSSS......
.....GGGGGG.....
....GGGGGGGG....
....GGWGGGGG....
....GGWGGGGG....
....SSSSSSSS....
....SWSSSWSS....
....SSSSSSSS....
....GGWGGGGG....
....GGWGGGGG....
....GGGGGGGG....
.....GGGGGG.....
""", {"G": "#2FE06F", "W": "#C8FFD8", "S": "#FF7A1F"}],
}

# Conference marks, hand-drawn at 1x from the official logos and at most
# 10 tall so they sit on the wall line (y 0..9) clear of the Heisman
# statues' heads at y 11. Dark marks are lifted for the LED: the B1G's
# black B goes white, the SEC and American navies go a brighter blue.
# The FBS independents have no mark of their own, so Notre Dame keeps the
# word.
CONF_ART = {
    "SEC": ["""
...GGGGGGGGG...
.GGNNNNNNNNNGG.
GNWWWNWWWNWWWNG
GNWNNNWNNNWNNNG
GNWWWNWWWNWNNNG
GNNNWNWNNNWNNNG
GNNNWNWNNNWNNNG
GNWWWNWWWNWWWNG
.GGNNNNNNNNNGG.
...GGGGGGGGG...
""", {"G": "#E8B92E", "N": "#2A4FB0", "W": "#F4F7FF"}],
    "BIG TEN": ["""
WWWW..BBB..BBBB
WW.WW..BB.BB...
WW.WW..BB.BB...
WWWW...BB.BB.BB
WW.WW..BB.BB..B
WW.WW..BB.BB..B
WW.WW..BB.BB..B
WWWW...BB..BBBB
""", {"W": "#F4F7FF", "B": "#1FA0F0"}],
    "ACC": ["""
....BBB...BBBB..BBBB
..BB.BB.BB....BB....
..BB.BB.BB....BB....
.BBBBB.BB....BB.....
.BB.BB.BB....BB.....
BB.BB.BB....BB......
BB.BB..BBBB..BBBB...
....................
BBBBBBBBBBBBBBBBBB..
""", {"B": "#3A6BF0"}],
    "BIG 12": ["""
WWWWWWWWWWWWWWWWW
.WWWWWWWWWWWWWWW.
..WW...WW.WW.WW..
...WW.WW..WW.WW..
....WWW...WW.WW..
...WW.WW..WW.WW..
..WW...WW.WW.WW..
.WWWWWWWWWWWWWWW.
WWWWWWWWWWWWWWWWW
""", {"W": "#F4F7FF"}],
    "PAC-12": ["""
KKKKKKKKKKK
K.........K
K..W..WW..K
K.WW....W.K
K..W...W..K
K..W..W...K
K.WWW.WWW.K
.K.......K.
..K.....K..
...KKKKK...
""", {"K": "#B8C0C8", "W": "#F4F7FF"}],
    "AMERICAN": ["""
....NNN....
...NNNNN...
...NN.NN...
..NNR.RNN..
..NRRRRRN..
.NN.RRR.NN.
.NNNR.RNNN.
NN.......NN
NN.......NN
NNN.....NNN
""", {"N": "#4F74E0", "R": "#FF2A3F"}],
}

def conf_dims(name):
    rows = CONF_ART[name][0].strip("\n").split("\n")
    return [max([len(r) for r in rows]), len(rows)]

# ------------------------------------------------------------- helpers
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-:;/&+%#!?()$@"

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

def wrap(c, text, font, maxw, maxlines):
    """Word-wrap into at most `maxlines`. Returns [lines, fits]; a cut ends
    in '..' so it reads as deliberate."""
    words = [w for w in str(text).split(" ") if w != ""]
    lines = []
    cur = ""
    for w in words:
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
            continue
        if cur != "":
            lines.append(cur)
        cur = w
    if cur != "":
        lines.append(cur)
    ok = len(lines) <= maxlines
    for ln in lines:
        if c.text_width(ln, font) > maxw:
            ok = False
    if ok:
        return [lines, True]
    lines = lines[:maxlines]
    last = lines[len(lines) - 1]
    for k in range(len(last)):
        t = last[:len(last) - k].rstrip(" ,.;:-")
        if c.text_width(t + "..", font) <= maxw:
            lines[len(lines) - 1] = t + ".."
            break
    return [[clip(c, ln, font, maxw) for ln in lines], False]

HEXD = "0123456789abcdef"

def ink_for(fill):
    h = str(fill).lower()
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def pick_school(ctx):
    want = str(ctx.inputs.get("school", ALL)).strip().upper()
    if want in BY_LABEL:
        return BY_LABEL[want]
    n = len(S)
    return S[((ctx.now.unix // SCHOOL_SECONDS) * 7) % n]

# ------------------------------------------------------------ the room
# Both pages are the same wall. On the right, from a brass rod at y 0, hangs
# the school's felt banner: school-colour felt, a window with the logo at
# its authored 24 x 18, the year the program first played, a swallowtail.

# The window behind the logo is chosen per logo for contrast: dark for
# logos drawn to sit on black (bright or light marks), cream for the dark
# ones (Alabama's crimson A, Oklahoma's crimson OU, Penn State's navy lion)
# that would sink into a dark field. Picked by measuring every 24 x 18 logo
# against both fields. The window is a pixel wider than the logo on each
# side, so a mark in the banner's own colour keeps its edge.
LIGHT_WINDOW = {
    "ALA": True, "ARK": True, "AUB": True, "BOIS": True, "BYU": True, "IU": True,
    "LSU": True, "MISS": True, "OU": True, "PITT": True, "PSU": True, "SC": True,
    "STAN": True, "SYR": True, "TAMU": True, "TCU": True, "TTU": True, "UCLA": True,
    "USC": True, "VT": True, "WASH": True, "WIS": True,
}
WINDOW_LIGHT = "#EEE8DA"
WINDOW_DARK = "#0E1016"

def felt_banner(c, s):
    """The banner hangs full height in front of the shelf's right end:
    a brass rod, school-colour felt, a 26 x 20 window with the 24 x 18
    logo, the first season, and a swallowtail. x 158..185, y 0..30."""
    c.rect(BAN_X0, 0, BAN_X1, 0, fill = GOLD_D)
    c.rect(BAN_X0, 1, BAN_X1, 27, fill = s[8])
    win = WINDOW_LIGHT if LIGHT_WINDOW.get(s[1], False) else WINDOW_DARK
    c.rect(BAN_X0 + 1, 1, BAN_X1 - 1, 20, fill = win)
    c.image(BANNER_LOGOS[s[1]], BAN_X0 + 2, 2)
    c.text(str(s[4]), (BAN_X0 + BAN_X1 + 1) // 2, 22, font = "4x5", color = ink_for(s[8]), align = "center")
    # the swallowtail: two points hanging off the bottom edge
    for i in range(3):
        c.rect(BAN_X0 + i, 28 + i, BAN_X0 + 12 - i, 28 + i, fill = s[8])
        c.rect(BAN_X1 - 12 + i, 28 + i, BAN_X1 - i, 28 + i, fill = s[8])

# ---------------------------------------------------------- page: legacy
def draw_icon(c, name, s, x, y, dim = False):
    """A tradition icon at 1x with the school's colours filled in."""
    e = ICONS[name]
    leg = {}
    for k in e[1]:
        v = e[1][k]
        leg[k] = s[8] if v == "X" else v
    leg.setdefault("X", s[8])
    leg.setdefault("S", s[9])
    if dim:
        leg = {k: GHOST for k in leg}
    c.sprite(e[0], x, y, legend = leg)

def icon_dims(name):
    rows = ICONS[name][0].strip("\n").split("\n")
    return [max([len(r) for r in rows]), len(rows)]

# The shelf objects. A national-title cup is 5 wide and 8 tall on a pitch of
# 6, with 2 px more after every fifth cup so a long row still counts at a
# glance (Alabama's 18 read as 5 5 5 3). A Heisman is the stiff-arm pose, 6
# wide and 12 tall on a pitch of 7, standing on a grey plinth.
CUP = """
YYYYY
DWYYD
.WYY.
.YYY.
..Y..
..Y..
.YYY.
DDDDD
"""
CUP_W = 5
CUP_P = 6

STATUE = """
...XX.
...XX.
XXXXX.
...XXX
...XBB
...XX.
..XXX.
.XX.X.
X...X.
X....X
.PPPP.
PPPPPP
"""
STATUE_W = 6
STATUE_P = 7

def row_width(n, pitch, w):
    if n == 0:
        return w
    return (n - 1) * pitch + w + ((n - 1) // 5) * 2

def draw_row(c, sprite, legend, n, x, pitch, h):
    """n objects standing on the shelf top (last row y 23) from x; zero
    draws one ghost - the spot on the shelf that is waiting."""
    y = SHELF_Y - h
    if n == 0:
        c.sprite(sprite, x, y, legend = {k: GHOST for k in legend})
        return
    for i in range(n):
        c.sprite(sprite, x + i * pitch + (i // 5) * 2, y, legend = legend)

def engrave(c, x, num, words, lit, none):
    """Lip plate: the count in the trophy's metal, the words in pale wood."""
    c.text(num, x, SHELF_Y + 3, font = "4x5", color = GHOST_T if none else lit)
    c.text(words, x + c.text_width(num + " ", "4x5"), SHELF_Y + 3, font = "4x5", color = GHOST_T if none else LIP_T)

def legacy(c, ctx):
    s = pick_school(ctx)
    c.fill("black")

    # The wall line: SCHOOL MASCOT, conference right-aligned before the
    # banner. Richest form that fits: both in 5x7, both in 4x5, the school
    # and the mascot's last word (MINNESOTA GOPHERS) in 5x7 then 4x5, and
    # only then the school alone.
    conf = s[10]
    if conf in CONF_ART:
        d = conf_dims(conf)
        c.sprite(CONF_ART[conf][0], WALL_R - d[0] + 1, (10 - d[1]) // 2, legend = CONF_ART[conf][1])
        cfw = d[0]
    else:
        c.text(conf, WALL_R, 2, font = "4x5", color = DIM, align = "right")
        cfw = c.text_width(conf, "4x5")
    room = WALL_R - cfw - 5 - WALL_X + 1
    school, mascot = s[2], s[3]
    short = mascot.split(" ")[-1]
    placed = False
    for pair in [[mascot, "5x7"], [mascot, "4x5"], [short, "5x7"], [short, "4x5"]]:
        m, f = pair[0], pair[1]
        if c.text_width(school + " " + m, f) <= room:
            y = 1 if f == "5x7" else 2
            c.text(school, WALL_X, y, font = f, color = s[8])
            c.text(m, WALL_X + c.text_width(school + " ", f), y, font = f, color = INK)
            placed = True
            break
    if not placed:
        sf = fit(c, school, ["5x7", "4x5"], room)
        c.text(sf[1], WALL_X, 1 if sf[0] == "5x7" else 2, font = sf[0], color = s[8])

    # The shelf: a lit top edge, then the walnut lip with its plates.
    c.rect(SHELF_X0, SHELF_Y, SHELF_X1, SHELF_Y, fill = WOOD_TOP)
    c.rect(SHELF_X0, SHELF_Y + 1, SHELF_X1, 31, fill = WOOD)
    c.rect(SHELF_X0, SHELF_Y + 1, SHELF_X1, SHELF_Y + 1, fill = WOOD_EDGE)

    titles, heis = s[5], s[6]
    tnum = str(titles)
    twords = "CLAIMED TITLE" if titles == 1 else "CLAIMED TITLES"
    hnum = str(heis)
    hwords = "HEISMAN" if heis == 1 else "HEISMANS"

    # Cups and their plate start at the left. The Heisman statues and their
    # plate are right-aligned to one edge R, the first x where the statues
    # clear the cups and the plate clears the cup plate, both by 6 px.
    # Worst case Alabama: 18 cups (113 px) + 6 + 4 statues ends at R 153,
    # 4 px short of the banner (x 158); its plate slides left under the
    # cups' spare lip. USC's 8 statues end at 146.
    cw = row_width(titles, CUP_P, CUP_W)
    cpw = c.text_width(tnum + " " + twords, "4x5")
    sw = row_width(heis, STATUE_P, STATUE_W)
    hpw = c.text_width(hnum + " " + hwords, "4x5")
    r = max(WALL_X + cw - 1 + GROUP_GAP + sw, WALL_X + cpw - 1 + GROUP_GAP + hpw)
    hx = r - sw + 1

    draw_row(c, CUP, {"Y": GOLD, "W": GOLD_W, "D": GOLD_D}, titles, WALL_X, CUP_P, 8)
    draw_row(c, STATUE, {"X": BRONZE, "B": BRONZE_D, "P": BASE}, heis, hx, STATUE_P, 12)
    engrave(c, WALL_X, tnum, twords, GOLD, titles == 0)
    engrave(c, r - hpw + 1, hnum, hwords, BRONZE, heis == 0)

    # The banner last: it hangs in front of the shelf's right end.
    felt_banner(c, s)

# ------------------------------------------------------- page: tradition
# The same wall, the banner in the same place, and a framed plaque filling
# the rest: a gold frame (x 6..153, y 3..31) whose top rail runs behind the
# story's name tag and the counter. Inside, three lines of story and, at
# the right, the story's icon - or, when the story names another program,
# that program's logo, so the plaque faces the school's own banner.
PL_X0 = 6
PL_X1 = 153
PL_TOP = 3
TX = PL_X0 + 3
ICON_CX = 143
OPP_X = PL_X1 - 41

def tradition(c, ctx):
    s = pick_school(ctx)
    facts = s[11]
    n = len(facts)
    idx = (ctx.now.unix // 60) % n
    head, body, icon, opp = facts[idx][0], facts[idx][1], facts[idx][2], facts[idx][3]
    c.fill("black")
    felt_banner(c, s)

    # The frame and the plaque's walnut face.
    c.rect(PL_X0, PL_TOP, PL_X1, 31, fill = PLAQUE, outline = GOLD_D)

    # Counter sits on the top rail at the right, the name tag on the left.
    counter = str(idx + 1) + "/" + str(n)
    cw = c.text_width(counter, "4x5")
    cx = PL_X1 - 3 - cw + 1
    c.rect(cx - 2, 0, PL_X1 - 1, 6, fill = "black")
    c.text(counter, cx, 1, font = "4x5", color = DIM)
    room = cx - 2 - 3 - (PL_X0 + 3) - 4
    word = clip(c, head, "4x5", room)
    ww = c.text_width(word, "4x5")
    c.rect(PL_X0 + 2, 0, PL_X0 + 2 + ww + 3, 6, fill = s[8])
    c.text(word, PL_X0 + 4, 1, font = "4x5", color = ink_for(s[8]))

    # The art: the opponent's logo or the story's icon, inside the plaque.
    if opp in LOGOS:
        c.image(LOGOS[opp], OPP_X, 7)
        right = OPP_X - 4
    else:
        d = icon_dims(icon)
        draw_icon(c, icon, s, ICON_CX - d[0] // 2, 8 + (23 - d[1]) // 2)
        right = ICON_CX - 8 - 3
    fw = right - TX + 1

    # Story: three lines in 5x7, then the narrower 4x7 (same height, a pixel
    # less per letter), and only then four lines of 4x5.
    for f in ["5x7", "4x7"]:
        w = wrap(c, body, f, fw, 3)
        if w[1]:
            for i in range(len(w[0])):
                c.text(w[0][i], TX, 8 + i * 8, font = f, color = INK)
            return
    w = wrap(c, body, "4x5", fw, 4)
    for i in range(len(w[0])):
        c.text(w[0][i], TX, 7 + i * 6, font = "4x5", color = INK)
