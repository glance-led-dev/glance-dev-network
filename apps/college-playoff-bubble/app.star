# College Playoff Bubble
#
# The 12-team College Football Playoff race, projected from the rankings.
#
#   bracket  one quarterfinal path per frame: the two first-round teams, a
#            bracket drawn under them, and the line running up into the
#            bye seed that waits for the winner (1 v 8/9, 2 v 7/10,
#            3 v 6/11, 4 v 5/12).
#   bubble   three frames: LAST 4 IN and FIRST 4 OUT with each team's
#            poll-points gap to the cut line, then the AUTO BIDS - the four
#            Power 4 champions and the best Group of 6 team.
#   myteam   your school: its seed and first-round opponent, or how far out
#            it is.
#
# FORMAT (the 2026 rules, CFP management committee, January 2026). 12 teams.
# Automatic places: the ACC, Big 12, Big Ten and SEC champions, whatever
# their ranking; the highest-ranked Group of 6 team (American, CUSA, MAC,
# MWC, Pac-12, Sun Belt), champion or not; and Notre Dame whenever it is
# ranked in the top 12. The other places (seven, or six when Notre Dame is
# locked in) go at large to the highest-ranked teams left. Seeding is
# straight by ranking - the top four get the first-round byes, and a
# qualifier ranked outside the top 12 takes the lowest seed. Seeds 5-8 host
# 12-9. The bracket is never reseeded.
#
# PROJECTION. Until the committee's own rankings appear (November), the AP
# poll stands in, and every page says PROJ so it never pretends to be the
# committee. The highest-ranked team of each Power 4 league is treated as
# its champion. The teams receiving votes are read too (in points order),
# so an unranked champion or Group of 6 team is still found; one that can't
# be found shows as a blank TBD shield. From Selection Day (the Sunday after
# the first Saturday in December, noon ET) the real field is set, so the
# app stops projecting and says so until the final poll.
#
# DESIGN. Graphics first: every team is its logo, never a name. The bracket
# is drawn as a bracket - ticks under the two first-round logos, joined,
# then one line running right and up into the bye seed's big logo. Gold
# belongs to the playoff itself: the CFP trophy in the tab, the BYE ticket,
# the crown on a Power 4 champion and the padlock on the other locks (the
# Group of 6 bid and Notre Dame). Green is IN and a rise in the poll, red is
# OUT and a fall, amber marks a projection. Numbers are seeds, ranks or
# poll-point gaps and always carry SEED, #, or a PTS GAP label.
#
# Frames advance one per refresh (300 s). The rankings change weekly, so
# the feed is cached for an hour.

RANKINGS = "https://site.web.api.espn.com/apis/site/v2/sports/football/college-football/rankings"
HEADERS = {"User-Agent": "glance-college-playoff-bubble (glance-led.dev)"}
FEED_TTL = 3600
STEP = 300          # seconds per frame; equals refresh in manifest.yaml

INK = "#F4F7FF"
DIM = "#6E7A94"
FAINT = "#2A3040"
LINE = "#8A94A8"
GOLD = "#FFC72C"
IN_C = "#2FE06F"
OUT_C = "#FF3B30"
PROJ_C = "#FFB000"
OFFLINE = "#3C4043"

P4 = {"SEC": True, "BIG TEN": True, "BIG 12": True, "ACC": True}
G6 = {"AMERICAN": True, "CUSA": True, "MAC": True, "MWC": True, "PAC-12": True, "SUN BELT": True}
NOTRE_DAME = "87"

# ESPN team id -> [school, nickname, conference, 40x24 logo, 24x18 logo].
# All 138 FBS programs. Paths are literals so the asset lint can see them;
# Texas A&M's logo is TAMU.png (an & in a file name is asking for trouble).
SCHOOLS = {
    "2005": ["AIR FORCE", "FALCONS", "MWC", "L/AFA.png", "S/AFA.png"],
    "2006": ["AKRON", "ZIPS", "MAC", "L/AKR.png", "S/AKR.png"],
    "333": ["ALABAMA", "CRIMSON TIDE", "SEC", "L/ALA.png", "S/ALA.png"],
    "2026": ["APP STATE", "MOUNTAINEERS", "SUN BELT", "L/APP.png", "S/APP.png"],
    "12": ["ARIZONA", "WILDCATS", "BIG 12", "L/ARIZ.png", "S/ARIZ.png"],
    "9": ["ARIZONA STATE", "SUN DEVILS", "BIG 12", "L/ASU.png", "S/ASU.png"],
    "8": ["ARKANSAS", "RAZORBACKS", "SEC", "L/ARK.png", "S/ARK.png"],
    "2032": ["ARKANSAS STATE", "RED WOLVES", "SUN BELT", "L/ARST.png", "S/ARST.png"],
    "349": ["ARMY", "BLACK KNIGHTS", "AMERICAN", "L/ARMY.png", "S/ARMY.png"],
    "2": ["AUBURN", "TIGERS", "SEC", "L/AUB.png", "S/AUB.png"],
    "2050": ["BALL STATE", "CARDINALS", "MAC", "L/BALL.png", "S/BALL.png"],
    "239": ["BAYLOR", "BEARS", "BIG 12", "L/BAY.png", "S/BAY.png"],
    "68": ["BOISE STATE", "BRONCOS", "PAC-12", "L/BOIS.png", "S/BOIS.png"],
    "103": ["BOSTON COLLEGE", "EAGLES", "ACC", "L/BC.png", "S/BC.png"],
    "189": ["BOWLING GREEN", "FALCONS", "MAC", "L/BGSU.png", "S/BGSU.png"],
    "2084": ["BUFFALO", "BULLS", "MAC", "L/BUFF.png", "S/BUFF.png"],
    "252": ["BYU", "COUGARS", "BIG 12", "L/BYU.png", "S/BYU.png"],
    "25": ["CALIFORNIA", "GOLDEN BEARS", "ACC", "L/CAL.png", "S/CAL.png"],
    "2117": ["CENTRAL MICHIGAN", "CHIPPEWAS", "MAC", "L/CMU.png", "S/CMU.png"],
    "2429": ["CHARLOTTE", "49ERS", "AMERICAN", "L/CLT.png", "S/CLT.png"],
    "2132": ["CINCINNATI", "BEARCATS", "BIG 12", "L/CIN.png", "S/CIN.png"],
    "228": ["CLEMSON", "TIGERS", "ACC", "L/CLEM.png", "S/CLEM.png"],
    "324": ["COASTAL CAROLINA", "CHANTICLEERS", "SUN BELT", "L/CCU.png", "S/CCU.png"],
    "38": ["COLORADO", "BUFFALOES", "BIG 12", "L/COLO.png", "S/COLO.png"],
    "36": ["COLORADO STATE", "RAMS", "PAC-12", "L/CSU.png", "S/CSU.png"],
    "48": ["DELAWARE", "BLUE HENS", "CUSA", "L/DEL.png", "S/DEL.png"],
    "150": ["DUKE", "BLUE DEVILS", "ACC", "L/DUKE.png", "S/DUKE.png"],
    "151": ["EAST CAROLINA", "PIRATES", "AMERICAN", "L/ECU.png", "S/ECU.png"],
    "2199": ["EASTERN MICHIGAN", "EAGLES", "MAC", "L/EMU.png", "S/EMU.png"],
    "57": ["FLORIDA", "GATORS", "SEC", "L/FLA.png", "S/FLA.png"],
    "2226": ["FLORIDA ATLANTIC", "OWLS", "AMERICAN", "L/FAU.png", "S/FAU.png"],
    "2229": ["FLORIDA INTERNATIONAL", "PANTHERS", "CUSA", "L/FIU.png", "S/FIU.png"],
    "52": ["FLORIDA STATE", "SEMINOLES", "ACC", "L/FSU.png", "S/FSU.png"],
    "278": ["FRESNO STATE", "BULLDOGS", "PAC-12", "L/FRES.png", "S/FRES.png"],
    "61": ["GEORGIA", "BULLDOGS", "SEC", "L/UGA.png", "S/UGA.png"],
    "290": ["GEORGIA SOUTHERN", "EAGLES", "SUN BELT", "L/GASO.png", "S/GASO.png"],
    "2247": ["GEORGIA STATE", "PANTHERS", "SUN BELT", "L/GAST.png", "S/GAST.png"],
    "59": ["GEORGIA TECH", "YELLOW JACKETS", "ACC", "L/GT.png", "S/GT.png"],
    "62": ["HAWAII", "RAINBOW WARRIORS", "MWC", "L/HAW.png", "S/HAW.png"],
    "248": ["HOUSTON", "COUGARS", "BIG 12", "L/HOU.png", "S/HOU.png"],
    "356": ["ILLINOIS", "FIGHTING ILLINI", "BIG TEN", "L/ILL.png", "S/ILL.png"],
    "84": ["INDIANA", "HOOSIERS", "BIG TEN", "L/IU.png", "S/IU.png"],
    "2294": ["IOWA", "HAWKEYES", "BIG TEN", "L/IOWA.png", "S/IOWA.png"],
    "66": ["IOWA STATE", "CYCLONES", "BIG 12", "L/ISU.png", "S/ISU.png"],
    "55": ["JACKSONVILLE STATE", "GAMECOCKS", "CUSA", "L/JXST.png", "S/JXST.png"],
    "256": ["JAMES MADISON", "DUKES", "SUN BELT", "L/JMU.png", "S/JMU.png"],
    "2305": ["KANSAS", "JAYHAWKS", "BIG 12", "L/KU.png", "S/KU.png"],
    "2306": ["KANSAS STATE", "WILDCATS", "BIG 12", "L/KSU.png", "S/KSU.png"],
    "338": ["KENNESAW STATE", "OWLS", "CUSA", "L/KENN.png", "S/KENN.png"],
    "2309": ["KENT STATE", "GOLDEN FLASHES", "MAC", "L/KENT.png", "S/KENT.png"],
    "96": ["KENTUCKY", "WILDCATS", "SEC", "L/UK.png", "S/UK.png"],
    "2335": ["LIBERTY", "FLAMES", "CUSA", "L/LIB.png", "S/LIB.png"],
    "309": ["LOUISIANA", "RAGIN CAJUNS", "SUN BELT", "L/UL.png", "S/UL.png"],
    "2348": ["LOUISIANA TECH", "BULLDOGS", "SUN BELT", "L/LT.png", "S/LT.png"],
    "97": ["LOUISVILLE", "CARDINALS", "ACC", "L/LOU.png", "S/LOU.png"],
    "99": ["LSU", "TIGERS", "SEC", "L/LSU.png", "S/LSU.png"],
    "276": ["MARSHALL", "THUNDERING HERD", "SUN BELT", "L/MRSH.png", "S/MRSH.png"],
    "120": ["MARYLAND", "TERRAPINS", "BIG TEN", "L/MD.png", "S/MD.png"],
    "113": ["MASSACHUSETTS", "MINUTEMEN", "MAC", "L/MASS.png", "S/MASS.png"],
    "235": ["MEMPHIS", "TIGERS", "AMERICAN", "L/MEM.png", "S/MEM.png"],
    "2390": ["MIAMI", "HURRICANES", "ACC", "L/MIA.png", "S/MIA.png"],
    "193": ["MIAMI (OH)", "REDHAWKS", "MAC", "L/M-OH.png", "S/M-OH.png"],
    "130": ["MICHIGAN", "WOLVERINES", "BIG TEN", "L/MICH.png", "S/MICH.png"],
    "127": ["MICHIGAN STATE", "SPARTANS", "BIG TEN", "L/MSU.png", "S/MSU.png"],
    "2393": ["MIDDLE TENNESSEE", "BLUE RAIDERS", "CUSA", "L/MTSU.png", "S/MTSU.png"],
    "135": ["MINNESOTA", "GOLDEN GOPHERS", "BIG TEN", "L/MINN.png", "S/MINN.png"],
    "344": ["MISSISSIPPI STATE", "BULLDOGS", "SEC", "L/MSST.png", "S/MSST.png"],
    "142": ["MISSOURI", "TIGERS", "SEC", "L/MIZ.png", "S/MIZ.png"],
    "2623": ["MISSOURI STATE", "BEARS", "CUSA", "L/MOST.png", "S/MOST.png"],
    "2426": ["NAVY", "MIDSHIPMEN", "AMERICAN", "L/NAVY.png", "S/NAVY.png"],
    "152": ["NC STATE", "WOLFPACK", "ACC", "L/NCSU.png", "S/NCSU.png"],
    "158": ["NEBRASKA", "CORNHUSKERS", "BIG TEN", "L/NEB.png", "S/NEB.png"],
    "2440": ["NEVADA", "WOLF PACK", "MWC", "L/NEV.png", "S/NEV.png"],
    "167": ["NEW MEXICO", "LOBOS", "MWC", "L/UNM.png", "S/UNM.png"],
    "166": ["NEW MEXICO STATE", "AGGIES", "CUSA", "L/NMSU.png", "S/NMSU.png"],
    "153": ["NORTH CAROLINA", "TAR HEELS", "ACC", "L/UNC.png", "S/UNC.png"],
    "2449": ["NORTH DAKOTA STATE", "BISON", "MWC", "L/NDSU.png", "S/NDSU.png"],
    "249": ["NORTH TEXAS", "MEAN GREEN", "AMERICAN", "L/UNT.png", "S/UNT.png"],
    "2459": ["NORTHERN ILLINOIS", "HUSKIES", "MWC", "L/NIU.png", "S/NIU.png"],
    "77": ["NORTHWESTERN", "WILDCATS", "BIG TEN", "L/NU.png", "S/NU.png"],
    "87": ["NOTRE DAME", "FIGHTING IRISH", "IND", "L/ND.png", "S/ND.png"],
    "195": ["OHIO", "BOBCATS", "MAC", "L/OHIO.png", "S/OHIO.png"],
    "194": ["OHIO STATE", "BUCKEYES", "BIG TEN", "L/OSU.png", "S/OSU.png"],
    "201": ["OKLAHOMA", "SOONERS", "SEC", "L/OU.png", "S/OU.png"],
    "197": ["OKLAHOMA STATE", "COWBOYS", "BIG 12", "L/OKST.png", "S/OKST.png"],
    "295": ["OLD DOMINION", "MONARCHS", "SUN BELT", "L/ODU.png", "S/ODU.png"],
    "145": ["OLE MISS", "REBELS", "SEC", "L/MISS.png", "S/MISS.png"],
    "2483": ["OREGON", "DUCKS", "BIG TEN", "L/ORE.png", "S/ORE.png"],
    "204": ["OREGON STATE", "BEAVERS", "PAC-12", "L/ORST.png", "S/ORST.png"],
    "213": ["PENN STATE", "NITTANY LIONS", "BIG TEN", "L/PSU.png", "S/PSU.png"],
    "221": ["PITTSBURGH", "PANTHERS", "ACC", "L/PITT.png", "S/PITT.png"],
    "2509": ["PURDUE", "BOILERMAKERS", "BIG TEN", "L/PUR.png", "S/PUR.png"],
    "242": ["RICE", "OWLS", "AMERICAN", "L/RICE.png", "S/RICE.png"],
    "164": ["RUTGERS", "SCARLET KNIGHTS", "BIG TEN", "L/RUTG.png", "S/RUTG.png"],
    "16": ["SACRAMENTO STATE", "HORNETS", "MAC", "L/SAC.png", "S/SAC.png"],
    "2534": ["SAM HOUSTON", "BEARKATS", "CUSA", "L/SHSU.png", "S/SHSU.png"],
    "21": ["SAN DIEGO STATE", "AZTECS", "PAC-12", "L/SDSU.png", "S/SDSU.png"],
    "23": ["SAN JOSE STATE", "SPARTANS", "MWC", "L/SJSU.png", "S/SJSU.png"],
    "2567": ["SMU", "MUSTANGS", "ACC", "L/SMU.png", "S/SMU.png"],
    "6": ["SOUTH ALABAMA", "JAGUARS", "SUN BELT", "L/USA.png", "S/USA.png"],
    "2579": ["SOUTH CAROLINA", "GAMECOCKS", "SEC", "L/SC.png", "S/SC.png"],
    "58": ["SOUTH FLORIDA", "BULLS", "AMERICAN", "L/USF.png", "S/USF.png"],
    "2572": ["SOUTHERN MISS", "GOLDEN EAGLES", "SUN BELT", "L/USM.png", "S/USM.png"],
    "24": ["STANFORD", "CARDINAL", "ACC", "L/STAN.png", "S/STAN.png"],
    "183": ["SYRACUSE", "ORANGE", "ACC", "L/SYR.png", "S/SYR.png"],
    "2628": ["TCU", "HORNED FROGS", "BIG 12", "L/TCU.png", "S/TCU.png"],
    "218": ["TEMPLE", "OWLS", "AMERICAN", "L/TEM.png", "S/TEM.png"],
    "2633": ["TENNESSEE", "VOLUNTEERS", "SEC", "L/TENN.png", "S/TENN.png"],
    "251": ["TEXAS", "LONGHORNS", "SEC", "L/TEX.png", "S/TEX.png"],
    "245": ["TEXAS A&M", "AGGIES", "SEC", "L/TAMU.png", "S/TAMU.png"],
    "326": ["TEXAS STATE", "BOBCATS", "PAC-12", "L/TXST.png", "S/TXST.png"],
    "2641": ["TEXAS TECH", "RED RAIDERS", "BIG 12", "L/TTU.png", "S/TTU.png"],
    "2649": ["TOLEDO", "ROCKETS", "MAC", "L/TOL.png", "S/TOL.png"],
    "2653": ["TROY", "TROJANS", "SUN BELT", "L/TROY.png", "S/TROY.png"],
    "2655": ["TULANE", "GREEN WAVE", "AMERICAN", "L/TULN.png", "S/TULN.png"],
    "202": ["TULSA", "GOLDEN HURRICANE", "AMERICAN", "L/TLSA.png", "S/TLSA.png"],
    "5": ["UAB", "BLAZERS", "AMERICAN", "L/UAB.png", "S/UAB.png"],
    "2116": ["UCF", "KNIGHTS", "BIG 12", "L/UCF.png", "S/UCF.png"],
    "26": ["UCLA", "BRUINS", "BIG TEN", "L/UCLA.png", "S/UCLA.png"],
    "41": ["UCONN", "HUSKIES", "IND", "L/CONN.png", "S/CONN.png"],
    "2433": ["UL MONROE", "WARHAWKS", "SUN BELT", "L/ULM.png", "S/ULM.png"],
    "2439": ["UNLV", "REBELS", "MWC", "L/UNLV.png", "S/UNLV.png"],
    "30": ["USC", "TROJANS", "BIG TEN", "L/USC.png", "S/USC.png"],
    "254": ["UTAH", "UTES", "BIG 12", "L/UTAH.png", "S/UTAH.png"],
    "328": ["UTAH STATE", "AGGIES", "PAC-12", "L/USU.png", "S/USU.png"],
    "2638": ["UTEP", "MINERS", "MWC", "L/UTEP.png", "S/UTEP.png"],
    "2636": ["UTSA", "ROADRUNNERS", "AMERICAN", "L/UTSA.png", "S/UTSA.png"],
    "238": ["VANDERBILT", "COMMODORES", "SEC", "L/VAN.png", "S/VAN.png"],
    "258": ["VIRGINIA", "CAVALIERS", "ACC", "L/UVA.png", "S/UVA.png"],
    "259": ["VIRGINIA TECH", "HOKIES", "ACC", "L/VT.png", "S/VT.png"],
    "154": ["WAKE FOREST", "DEMON DEACONS", "ACC", "L/WAKE.png", "S/WAKE.png"],
    "264": ["WASHINGTON", "HUSKIES", "BIG TEN", "L/WASH.png", "S/WASH.png"],
    "265": ["WASHINGTON STATE", "COUGARS", "PAC-12", "L/WSU.png", "S/WSU.png"],
    "277": ["WEST VIRGINIA", "MOUNTAINEERS", "BIG 12", "L/WVU.png", "S/WVU.png"],
    "98": ["WESTERN KENTUCKY", "HILLTOPPERS", "CUSA", "L/WKU.png", "S/WKU.png"],
    "2711": ["WESTERN MICHIGAN", "BRONCOS", "MAC", "L/WMU.png", "S/WMU.png"],
    "275": ["WISCONSIN", "BADGERS", "BIG TEN", "L/WIS.png", "S/WIS.png"],
    "2751": ["WYOMING", "COWBOYS", "MWC", "L/WYO.png", "S/WYO.png"],
}

SCHOOL_ID = {SCHOOLS[k][0]: k for k in SCHOOLS}

# Conference -> the short tag drawn beside a Power 4 champion's crown.
CONF_TAG = {"SEC": "SEC", "BIG TEN": "B10", "BIG 12": "B12", "ACC": "ACC",
            "AMERICAN": "AAC", "PAC-12": "P12", "MWC": "MWC", "SUN BELT": "SBC",
            "MAC": "MAC", "CUSA": "CUSA"}

# ------------------------------------------------------------------ pixel art
# The CFP trophy: a gold football on a stem and a stepped base.
TROPHY = """
..BBB..
.BBWBB.
.BBBBB.
..BBB..
...G...
..GGG..
...G...
..GGG..
.GGGGG.
"""
# 5 x 3 crown: a projected Power 4 champion.
CROWN = """
X.X.X
XXXXX
XXXXX
"""
# 5 x 6 padlock: the other locks - the Group of 6 bid and Notre Dame.
LOCK = """
.XXX.
X...X
X...X
XXXXX
XX.XX
XXXXX
"""
# 5 x 3 poll-movement chevrons.
UP = """
..X..
.XXX.
XXXXX
"""
DOWN = """
XXXXX
.XXX.
..X..
"""
# 25 x 9 admission ticket with notched ends: the first-round BYE.
TICKET = """
TTTTTTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTTTTTTTTTTTTTTTT
.TTTTTTTTTTTTTTTTTTTTTTT.
..TTTTTTTTTTTTTTTTTTTTT..
..TTTTTTTTTTTTTTTTTTTTT..
..TTTTTTTTTTTTTTTTTTTTT..
.TTTTTTTTTTTTTTTTTTTTTTT.
TTTTTTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTTTTTTTTTTTTTTTT
"""
# A blank 24 x 18 shield for a place the rankings cannot fill yet.
SHIELD_S = """
..XXXXXXXXXXXXXXXXXXXX..
.XX..................XX.
.X....................X.
.X....................X.
.X....................X.
.X....................X.
.X....................X.
.X....................X.
.X....................X.
.X....................X.
.XX..................XX.
..X..................X..
..XX................XX..
...XX..............XX...
....XX............XX....
.....XXX........XXX.....
.......XXX....XXX.......
.........XXXXXX.........
"""
ARROW_R = """
X..
XX.
XXX
XX.
X..
"""

# ------------------------------------------------------------------ helpers
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-&()/#"

def clean(s):
    out = ""
    for ch in str(s).upper().replace("É", "E").elems():
        if KEEP.find(ch) >= 0:
            out += ch
    return out.strip()

def clip(c, t, font, maxw):
    t = str(t)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        s = t[:k].rstrip(" -.(")
        if c.text_width(s, font) <= maxw:
            return s
    return ""

def fit(c, t, fonts, maxw):
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            return [t, f]
    last = fonts[len(fonts) - 1]
    return [clip(c, t, last, maxw), last]

INKH = {"16x20": 20, "10x16": 15, "9x12": 12, "6x8": 8, "5x7": 7, "4x5": 5, "picopixel": 5}

def num(v, fallback = 0):
    if type(v) == "int":
        return v
    if type(v) == "float":
        return int(v)
    t = str(v).strip()
    if t == "" or not t.isdigit():
        return fallback
    return int(t)

def get(obj, key, fallback = None):
    if type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def ordinal(n):
    if n % 100 >= 11 and n % 100 <= 13:
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

SHORTEN = [["INTERNATIONAL", "INTL"], [" STATE", " ST"], ["WESTERN ", "W "],
           ["EASTERN ", "E "], ["CENTRAL ", "C "], ["NORTHERN ", "N "],
           ["NORTH ", "N "], ["SOUTH ", "S "], ["MIDDLE ", "MID "],
           ["JACKSONVILLE", "JAX"], ["MASSACHUSETTS", "UMASS"]]

def short_name(t):
    for r in SHORTEN:
        t = t.replace(r[0], r[1])
    return t

def signed(n):
    return ("+" if n >= 0 else "-") + str(abs(n))

def frame(ctx, n):
    return (ctx.now.unix // STEP) % n

def rail(c, color):
    # x 6..7: nothing lights x 0..5 or 186..191, so the app never runs
    # into its neighbours on a scroll wall.
    c.rect(6, 0, 7, 31, fill = color)

def trophy(c, x, y, scale):
    c.sprite(TROPHY, x, y, legend = {"B": GOLD, "W": "#FFF3C4", "G": "#D9A21B"}, scale = scale)

def lock_icon(c, e, x, bottom):
    """The 5-wide mark of a locked place, its lowest row at `bottom`: a crown
    for a Power 4 champion, a padlock for the Group of 6 bid and Notre Dame."""
    if e == None or e["aq"] == "":
        return
    if e["aq"] == "P4":
        c.sprite(CROWN, x, bottom - 2, legend = {"X": GOLD})
    else:
        c.sprite(LOCK, x, bottom - 5, legend = {"X": GOLD})

def lock_tag(e):
    if e == None or e["aq"] == "":
        return ""
    if e["aq"] == "P4":
        return CONF_TAG.get(e["conf"], "")
    return "G6" if e["aq"] == "G6" else "IND"

def ticket(c, x, y):
    c.sprite(TICKET, x, y, legend = {"T": GOLD})
    c.text("BYE", x + 13, y + 2, font = "4x5", color = "black", align = "center")

def message(c, rail_col, head_col, head, sub):
    c.fill("black")
    rail(c, rail_col)
    trophy(c, 10, 7, 2)
    h = fit(c, head, ["6x8", "5x7", "4x5"], 150)
    c.text(h[0], 108, 8, font = h[1], color = head_col, align = "center")
    s = fit(c, sub, ["4x5", "picopixel"], 150)
    c.text(s[0], 108, 21, font = s[1], color = DIM, align = "center")

def small_logo(c, e, x, y):
    """24 x 18 logo at (x, y); a blank shield for a TBD place, or the
    school's short name for one outside the FBS set."""
    if e == None:
        c.sprite(SHIELD_S, x, y, legend = {"X": DIM})
        c.text("?", x + 12, y + 5, font = "5x7", color = DIM, align = "center")
    elif e["small"] != "":
        c.image(e["small"], x, y)
    else:
        c.text(clip(c, e["abbr"], "4x5", 24), x + 12, y + 7, font = "4x5", color = INK, align = "center")

def big_logo(c, e, x, y):
    if e == None:
        c.sprite(SHIELD_S, x + 8, y + 3, legend = {"X": DIM})
        c.text("?", x + 20, y + 8, font = "5x7", color = DIM, align = "center")
    elif e["logo"] != "":
        c.image(e["logo"], x, y)
    else:
        c.text(clip(c, e["abbr"], "5x7", 40), x + 20, y + 9, font = "5x7", color = INK, align = "center")

def rank_tag(e):
    return "#" + str(e["rank"]) if e != None and e["rank"] > 0 else "NR"

def rank_width(c, e, font):
    w = c.text_width(rank_tag(e), font)
    return w + 6 if e != None and e["move"] != 0 else w

def rank_move(c, e, x, y, font):
    """'#7' then a green rise / red fall chevron, from x; y is the text top."""
    t = rank_tag(e)
    c.text(t, x, y, font = font, color = INK)
    if e != None and e["move"] != 0:
        cx = x + c.text_width(t, font) + 1
        cy = y + (INKH[font] - 3) // 2
        if e["move"] > 0:
            c.sprite(UP, cx, cy, legend = {"X": IN_C})
        else:
            c.sprite(DOWN, cx, cy, legend = {"X": OUT_C})

# ------------------------------------------------------------------ dates
def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def selection_unix(season):
    """Selection Day: the Sunday after the first Saturday of December, with
    the bracket out at noon ET (17:00 UTC). 6 Dec 2026, 5 Dec 2027."""
    d1 = days_from_civil(season, 12, 1)
    wd = (d1 + 3) % 7        # 1 Jan 1970 was a Thursday; Monday = 0
    sat = d1 + (5 - wd) % 7
    return (sat + 1) * 86400 + 17 * 3600

def bracket_set(ctx):
    season = ctx.now.year if ctx.now.month >= 8 else ctx.now.year - 1
    return ctx.now.unix >= selection_unix(season) and (ctx.now.month == 12 or ctx.now.month <= 2)

# ------------------------------------------------------------------ data
def entry(x, pos, ranked):
    t = get(x, "team", {})
    tid = str(get(t, "id", ""))
    s = SCHOOLS.get(tid, None)
    rank = num(get(x, "current", 0)) if ranked else 0
    prev = num(get(x, "previous", 0))
    # ESPN gives every team receiving votes a "0-0" record; blank it.
    rec = clean(get(x, "recordSummary", ""))
    if rank == 0 or rec == "0-0":
        rec = ""
    return {"id": tid, "pos": pos,
            "name": s[0] if s != None else clean(get(t, "location", get(t, "nickname", ""))),
            "conf": s[2] if s != None else "",
            "logo": s[3] if s != None else "", "small": s[4] if s != None else "",
            "abbr": clean(get(t, "abbreviation", "")),
            "rank": rank,
            "move": prev - rank if rank > 0 and prev > 0 else 0,
            "points": num(get(x, "points", 0)),
            "record": rec,
            "aq": ""}

def pick_poll(j):
    """The committee's rankings when they exist, else the AP poll."""
    ap = None
    for p in get(j, "rankings", []):
        typ = str(get(p, "type", "")).lower()
        nm = str(get(p, "name", "")).upper()
        if typ == "cfp" or nm.find("PLAYOFF") >= 0:
            return [p, "CFP"]
        if typ == "ap" and ap == None:
            ap = p
    return [ap, "AP"]

def build(j):
    pp = pick_poll(j)
    poll, src = pp[0], pp[1]
    if poll == None:
        return {"empty": True}
    when = clean(get(get(poll, "occurrence", {}), "displayValue", ""))
    ranked = sorted([x for x in get(poll, "ranks", []) if num(get(x, "current", 0)) > 0],
                    key = lambda x: num(get(x, "current", 0)))
    if len(ranked) == 0:
        return {"empty": True}
    others = sorted(get(poll, "others", []), key = lambda x: -num(get(x, "points", 0)))
    order = [entry(ranked[i], i + 1, True) for i in range(len(ranked))]
    order += [entry(others[i], len(ranked) + i + 1, False) for i in range(len(others))]

    # The locks: the first team seen from each Power 4 league (its projected
    # champion), the first Group of 6 team seen, and Notre Dame in the top 12.
    champs = []
    seen = {}
    g6 = None
    nd = False
    for e in order:
        cf = e["conf"]
        if cf in P4 and cf not in seen:
            seen[cf] = True
            e["aq"] = "P4"
            champs.append(e)
        elif cf in G6 and g6 == None:
            e["aq"] = "G6"
            g6 = e
        elif e["id"] == NOTRE_DAME and e["pos"] <= 12:
            e["aq"] = "ND"
            nd = True
    locks = [e for e in order if e["aq"] != ""]

    # Five places are always held for the Power 4 champions and the Group of
    # 6 team, found or not; Notre Dame's lock takes one more.
    held = 5 + (1 if nd else 0)
    at_large = [e for e in order if e["aq"] == ""][:12 - held]
    field = sorted(locks + at_large, key = lambda e: e["pos"])
    in_ids = {e["id"]: True for e in field}
    # An unfound champion or Group of 6 team leaves a TBD place at the foot.
    seeds = field + [None for i in range(12 - len(field))]
    out = [e for e in order if e["id"] not in in_ids]

    # AUTO BIDS: the Power 4 champions in rank order, the G6 team last.
    auto = champs + [None for i in range(4 - len(champs))] + [g6]

    # The cut line in poll points: the last at-large team in vs the first
    # team out. The committee publishes no points, so then there is no gap.
    cut_in = at_large[len(at_large) - 1]["points"] if len(at_large) > 0 else 0
    cut_out = out[0]["points"] if len(out) > 0 else 0
    has_gap = src == "AP" and cut_in > 0 and cut_out > 0
    for e in at_large:
        e["gap"] = e["points"] - cut_out if has_gap else None
    for e in out:
        e["gap"] = e["points"] - cut_in if has_gap and e["points"] > 0 else None
    wk = when.replace("PRESEASON", "PRE").replace("WEEK ", "WK ")
    return {"empty": False, "src": src, "week": wk,
            "final": src == "AP" and when.find("FINAL") >= 0,
            "seeds": seeds, "auto": auto, "at_large": at_large, "out": out,
            "has_gap": has_gap}

def race(c, ctx):
    r = http.get(RANKINGS, headers = HEADERS, ttl_seconds = FEED_TTL)
    if r["status_code"] == 0:
        message(c, OFFLINE, "amber", "ESPN OFFLINE", "THE RACE RETURNS WHEN ESPN IS BACK")
        return None
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        message(c, OFFLINE, "amber", "RANKINGS FEED ERROR", "HTTP " + str(r["status_code"]) + " - RETRY SOON")
        return None
    d = build(r["json"])
    if d["empty"]:
        message(c, IN_C, IN_C, "NO RANKINGS YET", "THE RACE STARTS WITH THE PRESEASON POLL")
        return None
    if d["final"]:
        message(c, IN_C, IN_C, "SEASON COMPLETE", "BACK WITH THE PRESEASON POLL")
        return None
    if bracket_set(ctx):
        # ESPN drops the committee poll once the season rolls to the
        # postseason; a projection from the AP poll would contradict the
        # real, already-set field.
        message(c, GOLD, GOLD, "THE FIELD IS SET", "PLAYOFF UNDERWAY - BACK NEXT SEASON")
        return None
    return d

def source(d):
    return ("AP " if d["src"] == "AP" else "CFP ") + d["week"]

# ------------------------------------------------------------------ tab
# Every page opens with the same tab at x 6..28: the CFP trophy at 2x, then
# PROJ in amber (or CMTE in gold once the committee ranks), and page dots.
def tab(c, d, idx, n):
    trophy(c, 10, 0, 2)
    if d["src"] == "AP":
        c.text("PROJ", 17, 20, font = "4x5", color = PROJ_C, align = "center")
    else:
        c.text("CMTE", 17, 20, font = "4x5", color = GOLD, align = "center")
    if n > 1:
        x0 = 17 - (n * 4 - 1) // 2
        for i in range(n):
            c.rect(x0 + i * 4, 28, x0 + i * 4 + 2, 29, fill = GOLD if i == idx else FAINT)
    c.line(30, 1, 30, 30, FAINT)

# ------------------------------------------------------------------ bracket
# One quarterfinal path per frame. x 33..56 and 62..85 the two first-round
# logos (24 x 18), their seeds under them at y 20; the bracket at y 28..31:
# ticks, a join, then one line right along y 31 and up x 94 into the arrow
# at y 10 that points at the bye seed's 40 x 24 logo (x 100..139). Right of
# it: SEED and the big seed number, the lock mark and tag under SEED when
# the bye seed is a lock, the BYE ticket beneath.
FR_A = 33
FR_B = 62
HERO_X = 100
PATHS = [[1, 8, 9], [2, 7, 10], [3, 6, 11], [4, 5, 12]]

def seed_label(c, e, seed, cx, y):
    """'8' in 5x7 centred on cx, the crown or padlock to its left when the
    team is a lock."""
    s = str(seed)
    w = c.text_width(s, "5x7")
    x = cx - w // 2
    c.text(s, x, y, font = "5x7", color = INK)
    lock_icon(c, e, x - 7, y + 5)

def bracket(c, ctx):
    d = race(c, ctx)
    if d == None:
        return
    k = frame(ctx, 4)
    p = PATHS[k]
    s = d["seeds"]
    top, a, b = s[p[0] - 1], s[p[1] - 1], s[p[2] - 1]
    c.fill("black")
    tab(c, d, k, 4)

    ca, cb = FR_A + 12, FR_B + 12
    small_logo(c, a, FR_A, 0)
    small_logo(c, b, FR_B, 0)
    seed_label(c, a, p[1], ca, 20)
    seed_label(c, b, p[2], cb, 20)
    # The bracket: ticks, the join, the winner's line to the bye seed.
    m = (ca + cb) // 2
    c.line(ca, 28, ca, 29, LINE)
    c.line(cb, 28, cb, 29, LINE)
    c.line(ca, 29, cb, 29, LINE)
    c.line(m, 29, m, 31, LINE)
    c.line(m, 31, 94, 31, LINE)
    c.line(94, 12, 94, 31, LINE)
    c.sprite(ARROW_R, 95, 10, legend = {"X": LINE})

    big_logo(c, top, HERO_X, 0)
    if top != None and top["record"] != "":
        c.text(top["record"], HERO_X + 20, 27, font = "4x5", color = DIM, align = "center")
    # Right column x 144..185: SEED label, the number, the ticket.
    c.text("SEED", 144, 3, font = "4x5", color = DIM)
    c.text(str(p[0]), 176, 1, font = "10x16", color = GOLD, align = "center")
    tag = lock_tag(top)
    if tag != "":
        # A lock: its crown or padlock and league tag under SEED.
        lock_icon(c, top, 144, 14)
        c.text(tag, 151, 10, font = "4x5", color = GOLD)
    ticket(c, 152, 22)

# ------------------------------------------------------------------ bubble
# Three frames: LAST 4 IN (green), FIRST 4 OUT (red), AUTO BIDS (gold).
# The title stacks at x 36..80 with PTS GAP under it; the teams share
# x 82..185 evenly: the 24 x 18 logo, the rank with its poll movement, and
# the points gap to the cut line (or the record when the committee ranks).
def bubble(c, ctx):
    d = race(c, ctx)
    if d == None:
        return
    k = frame(ctx, 3)
    c.fill("black")
    tab(c, d, k, 3)
    if k == 2:
        auto_bids(c, d)
        return
    if k == 0:
        title, col, teams = ["LAST", "4 IN"], IN_C, d["at_large"][-4:]
    else:
        title, col, teams = ["FIRST", "4 OUT"], OUT_C, d["out"][:4]
    c.text(title[0], 58, 3, font = "5x7", color = col, align = "center")
    c.text(title[1], 58, 13, font = "5x7", color = col, align = "center")
    # Under the title, what the bottom row means: the points gap, or the
    # source poll when the rows carry records instead.
    foot = "PTS GAP" if d["has_gap"] else fit(c, source(d), ["4x5"], 44)[0]
    c.text(foot, 58, 25, font = "4x5", color = DIM, align = "center")
    if len(teams) == 0:
        c.text("NONE", 134, 12, font = "5x7", color = DIM, align = "center")
        return

    n = len(teams)
    sw = 104 // n
    for i in range(n):
        e = teams[i]
        cx = 82 + i * sw + sw // 2
        small_logo(c, e, cx - 12, 0)
        rank_move(c, e, cx - rank_width(c, e, "5x7") // 2, 20, "5x7")
        g = e.get("gap", None)
        if g != None:
            c.text(signed(g), cx, 27, font = "4x5", color = IN_C if g >= 0 else OUT_C, align = "center")
        elif e["record"] != "":
            c.text(e["record"], cx, 27, font = "4x5", color = DIM, align = "center")

def auto_bids(c, d):
    # Five locks need 26 px slots, so the title is a 2x crown with AUTO /
    # BIDS under it in 4x5, in a 19 px column. Each slot: the logo, the
    # crown + league (Power 4 champion) or padlock + G6, and the rank.
    c.sprite(CROWN, 37, 2, legend = {"X": GOLD}, scale = 2)
    c.text("AUTO", 42, 12, font = "4x5", color = GOLD, align = "center")
    c.text("BIDS", 42, 19, font = "4x5", color = GOLD, align = "center")
    teams = d["auto"]
    for i in range(len(teams)):
        e = teams[i]
        cx = 54 + i * 26 + 13
        small_logo(c, e, cx - 12, 0)
        if e != None:
            tag = lock_tag(e)
            w = c.text_width(tag, "4x5") + 7
            lock_icon(c, e, cx - w // 2, 24)
            c.text(tag, cx - w // 2 + 7, 20, font = "4x5", color = GOLD)
            c.text(rank_tag(e), cx, 27, font = "4x5", color = INK, align = "center")
        else:
            c.text("G6" if i == 4 else "TBD", cx, 20, font = "4x5", color = DIM, align = "center")

# ------------------------------------------------------------------ myteam
def status(d, tid):
    """{hero, col, detail, e, side, opp, gap} for the chosen school. side is
    what sits right of the hero: the first-round opponent's logo, the BYE
    ticket, or the points gap to the field."""
    seeds = d["seeds"]
    for i in range(12):
        e = seeds[i]
        if e != None and e["id"] == tid:
            sd = i + 1
            if sd <= 4:
                p = PATHS[sd - 1]
                return {"hero": "SEED " + str(sd), "col": GOLD, "e": e, "side": "bye",
                        "detail": "PLAYS " + str(p[1]) + "/" + str(p[2]) + " WINNER"}
            opp = 17 - sd
            where = "HOSTS SEED " if sd <= 8 else "AT SEED "
            return {"hero": "SEED " + str(sd), "col": IN_C, "e": e, "side": "opp",
                    "opp": seeds[opp - 1], "detail": where + str(opp)}
    for i in range(len(d["out"])):
        e = d["out"][i]
        if e["id"] == tid:
            side = "gap" if e["gap"] != None else ""
            if e["rank"] > 0:
                return {"hero": ordinal(i + 1) + " OUT", "col": PROJ_C if i < 4 else INK,
                        "e": e, "side": side,
                        "detail": "ON THE BUBBLE" if i < 4 else "OUTSIDE THE FIELD"}
            return {"hero": "UNRANKED", "col": DIM, "e": e, "side": side,
                    "detail": ordinal(i + 1) + " TEAM OUT"}
    return {"hero": "UNRANKED", "col": DIM, "e": None, "side": "",
            "detail": "NO VOTES IN THE POLL"}

# x 79..185: the name row with the rank, movement and record at its right;
# the hero status (lock mark + tag after it); the detail row with the
# source poll right-aligned when there is room. x 161..185 of the hero band
# holds the first-round opponent's logo, the BYE ticket, or the PTS gap.
TX = 79
TR = 185
SIDE_X = 161

def myteam(c, ctx):
    d = race(c, ctx)
    if d == None:
        return
    pick = str(ctx.inputs.get("school", "ALABAMA")).strip().upper()
    tid = SCHOOL_ID.get(pick, SCHOOL_ID["ALABAMA"])
    s = SCHOOLS[tid]
    st = status(d, tid)
    e = st["e"]
    c.fill("black")
    tab(c, d, 0, 1)
    c.image(s[3], 34, 4)

    # Name row: the rank, its chevron and the record measured first, right.
    rw = 0
    if e != None and e["rank"] > 0:
        rec = e["record"]
        recw = c.text_width(rec, "4x5") if rec != "" else 0
        rkw = rank_width(c, e, "4x5")
        rw = rkw + (recw + 4 if recw > 0 else 0)
        rank_move(c, e, TR - rw + 1, 2, "4x5")
        if recw > 0:
            c.text(rec, TR, 2, font = "4x5", color = DIM, align = "right")
    nw = TR - TX + 1 - (rw + 4 if rw > 0 else 0)
    nm = fit(c, s[0], ["6x8", "5x7"], nw)
    if c.text_width(nm[0], nm[1]) < c.text_width(s[0], nm[1]):
        # MISSISSIPPI STATE beside #24 3-0: the short form before any clip.
        nm = fit(c, short_name(s[0]), ["6x8", "5x7", "4x5"], nw)
    c.text(nm[0], TX, 1 + (8 - INKH[nm[1]]), font = nm[1], color = INK)

    # The side block, then the hero in what is left.
    side = st["side"]
    if side == "opp":
        small_logo(c, st["opp"], SIDE_X + 1, 8)
    elif side == "bye":
        ticket(c, SIDE_X, 12)
    elif side == "gap":
        g = fit(c, signed(e["gap"]), ["5x7", "4x5"], 25)
        c.text(g[0], SIDE_X + 12, 11, font = g[1], color = OUT_C, align = "center")
        c.text("PTS", SIDE_X + 12, 20, font = "4x5", color = DIM, align = "center")
    right = (SIDE_X - 3) if side != "" else TR
    tag = lock_tag(e)
    aqw = max(5, c.text_width(tag, "4x5")) + 3 if tag != "" else 0
    h = fit(c, st["hero"], ["10x16", "9x12", "6x8"], right - TX + 1 - aqw)
    c.text(h[0], TX, 10 + (15 - INKH[h[1]]) // 2, font = h[1], color = st["col"])
    if tag != "":
        ax = TX + c.text_width(h[0], h[1]) + 3
        lock_icon(c, e, ax, 15)
        c.text(tag, ax, 17, font = "4x5", color = GOLD)

    src = source(d)
    det = fit(c, st["detail"], ["4x5"], TR - TX + 1)[0]
    c.text(det, TX, 27, font = "4x5", color = DIM)
    if c.text_width(det, "4x5") + 12 + c.text_width(src, "4x5") <= TR - TX + 1:
        c.text(src, TR, 27, font = "4x5", color = "#4A5470", align = "right")
