# College Upset Watch
#
# The week's biggest college football upsets: an underdog's logo on the left,
# the ranked team it just knocked off on the right, the final score between
# them, and the betting line that says how unlikely it was.
#
#   upsets   one upset per frame, most shocking first. A tier pill (SHOCKER /
#            BIG UPSET / UPSET / RANKED FALLS) names how big it was, a ROAD
#            tag marks a road win, a pixel underdog beside "+16.5" is the
#            spread the winner was getting and "ML +575" its moneyline, and
#            a lightning strike in the tier colour splits the loser's logo.
#   carnage  the week in one glance: how many ranked teams fell, and the
#            logos of the fallen over rank badges in their tier colour.
#
# DESIGN. Graphics first. Both logos are on every card at their authored
# 40 x 24, never scaled, so the story reads from across the room before a
# word does: winner left, loser right, score in the middle in 10x16 with the
# winner's number lit and the loser's dimmed. The one memorable thing is the
# strike: a two-kink thunderbolt in the tier colour, cut into the fallen
# giant's crest by 1 px of black each side so it reads on maroon, orange or
# white logos alike. (Tried on the carnage page too: on 24 x 18 logos and on
# the 16x20 count it ate the identity, so there the badges carry the tier.)
# The words that remain are the ones a picture can't say: the tier, ROAD, the
# spread, the moneyline, the rank. The underdog sprite replaces "DOG"; the
# strike, the cracked badge and the falling arrow replace "LOST"; a gold
# crown is a chalk week where every favourite held. Tier colours climb with
# the shock - amber, orange, red - and a favoured winner over a ranked team
# (Louisville -3 over #16 SMU) is purple RANKED FALLS: news, but not an
# upset, so it only takes a frame in a week with fewer than two real upsets.
# A school picked in settings gets gold corner brackets round its logo
# wherever it appears, and its games lead the rotation.
#
# DATA. ESPN's default college scoreboard is the week's Top 25 slate (about
# 340 KB). Finals only - a game in progress is never shown. The current week
# is used once it has an upset on the board or half its games are final;
# before that (a Thursday, a Saturday morning) the previous week shows. CHALK
# WEEK is only called once every game on the slate is final; until then a
# quiet Saturday reads NO UPSETS YET / 10 OF 18 GAMES FINAL. A candidate is a
# final where a ranked team (ESPN's curatedRank: the AP poll until the first
# CFP ranking, then the CFP Top 25) lost to an unranked or lower-ranked one.
# ESPN's scoreboard drops the betting line once a game ends, so each
# candidate's closing line and moneyline come from the core odds endpoint
# (~7 KB, cached a day because a final's line never changes). Budget: 2
# scoreboards + at most 6 odds calls = 8.

SCOREBOARD = "https://site.web.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard"
ODDS = "https://sports.core.api.espn.com/v2/sports/football/leagues/college-football/events/{e}/competitions/{e}/odds"
HEADERS = {"User-Agent": "glance-college-upset-watch (glance-led.dev)"}

# refresh is 300: frames step every 5 minutes, and Saturday finals land
# within one frame of going final.
CURRENT_TTL = 600
PAST_TTL = 21600
ODDS_TTL = 86400
MAX_ODDS = 6
FRAME_SECONDS = 300

# ------------------------------------------------------------------ layout
# 192 wide. Winner logo x 8..47, loser logo x 144..183: 8 px edge padding,
# so a school's gold corner brackets (2 px outside its logo, x 6 / 185)
# still sit inside the safe zone. Middle zone x 52..139 between them with
# 4 px of black each side.
WL_X = 8
LL_X = 144
LOGO_Y = 1
MID_L = 52
MID_R = 139
MID_W = MID_R - MID_L + 1
MID_C = (MID_L + MID_R) // 2

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
LOSER = "#5C6680"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
GOLD = "#FFC933"
C_SHOCK = "#FF2D2D"
C_BIG = "#FF7A1A"
C_UPSET = "#FFBF00"
C_FELL = "#B18CFF"
C_DOG = "#FFBF00"
C_ROAD = "#78DCFF"

# tier -> [pill word, colour]
TIER = {
    "SHOCK": ["SHOCKER", C_SHOCK],
    "BIG": ["BIG UPSET", C_BIG],
    "UPSET": ["UPSET", C_UPSET],
    "FELL": ["RANKED FALLS", C_FELL],
}
TIER_ORDER = {"SHOCK": 0, "BIG": 1, "UPSET": 2, "FELL": 3}

# --------------------------------------------------------------- pixel art
# The fault line through the fallen giant's 40 x 24 logo: one x offset per
# row: a thunderbolt with two kinks (rows 7 and 15 step back right 6 and
# 5 px), top right of centre to bottom left.
CRACK_PATH = [26, 25, 24, 23, 22, 21, 20, 19, 25, 24, 23, 22, 21, 20, 19, 18, 23, 22, 21, 20, 19, 18, 17, 16]

# The underdog: tail up, ears back, snout to the right - he's the one who won.
DOG = """
........EE..
.......EEHH.
T......HHOHH
.T.BBBBBHHHN
..BBBBBBB...
..B.B..B.B..
..B.B..B.B..
"""
DOG_LEGEND = {"E": "#8A5424", "H": "#D9A05B", "O": "#2A1606", "N": "#3A2010",
              "T": "#D9A05B", "B": "#D9A05B"}
DOWN = """
.XXX.
.XXX.
XXXXX
.XXX.
..X..
"""
CROWN = """
X...X...X
XX.XXX.XX
XXXXXXXXX
XJXXJXXJX
XXXXXXXXX
"""
BALL = """
...DDDDD...
.DBBBBBBBD.
DBBWBWBWBBD
DBWWWWWWWBD
DBBWBWBWBBD
.DBBBBBBBD.
...DDDDD...
"""
BALL_LEGEND = {"D": "#5A2E0E", "B": "#A0522D", "W": "#FFFFFF"}

# ESPN team id -> hero logo (40 x 24), from _logos/ncaa/L.
LOGO_L = {
    "2005": "L/AFA.png",
    "2006": "L/AKR.png",
    "333": "L/ALA.png",
    "2026": "L/APP.png",
    "12": "L/ARIZ.png",
    "9": "L/ASU.png",
    "8": "L/ARK.png",
    "2032": "L/ARST.png",
    "349": "L/ARMY.png",
    "2": "L/AUB.png",
    "2050": "L/BALL.png",
    "239": "L/BAY.png",
    "68": "L/BOIS.png",
    "103": "L/BC.png",
    "189": "L/BGSU.png",
    "2084": "L/BUFF.png",
    "252": "L/BYU.png",
    "25": "L/CAL.png",
    "2117": "L/CMU.png",
    "2429": "L/CLT.png",
    "2132": "L/CIN.png",
    "228": "L/CLEM.png",
    "324": "L/CCU.png",
    "38": "L/COLO.png",
    "36": "L/CSU.png",
    "48": "L/DEL.png",
    "150": "L/DUKE.png",
    "151": "L/ECU.png",
    "2199": "L/EMU.png",
    "57": "L/FLA.png",
    "2226": "L/FAU.png",
    "2229": "L/FIU.png",
    "52": "L/FSU.png",
    "278": "L/FRES.png",
    "61": "L/UGA.png",
    "290": "L/GASO.png",
    "2247": "L/GAST.png",
    "59": "L/GT.png",
    "62": "L/HAW.png",
    "248": "L/HOU.png",
    "356": "L/ILL.png",
    "84": "L/IU.png",
    "2294": "L/IOWA.png",
    "66": "L/ISU.png",
    "55": "L/JXST.png",
    "256": "L/JMU.png",
    "2305": "L/KU.png",
    "2306": "L/KSU.png",
    "338": "L/KENN.png",
    "2309": "L/KENT.png",
    "96": "L/UK.png",
    "2335": "L/LIB.png",
    "309": "L/UL.png",
    "2348": "L/LT.png",
    "97": "L/LOU.png",
    "99": "L/LSU.png",
    "276": "L/MRSH.png",
    "120": "L/MD.png",
    "113": "L/MASS.png",
    "235": "L/MEM.png",
    "2390": "L/MIA.png",
    "193": "L/M-OH.png",
    "130": "L/MICH.png",
    "127": "L/MSU.png",
    "2393": "L/MTSU.png",
    "135": "L/MINN.png",
    "344": "L/MSST.png",
    "142": "L/MIZ.png",
    "2623": "L/MOST.png",
    "2426": "L/NAVY.png",
    "152": "L/NCSU.png",
    "158": "L/NEB.png",
    "2440": "L/NEV.png",
    "167": "L/UNM.png",
    "166": "L/NMSU.png",
    "153": "L/UNC.png",
    "2449": "L/NDSU.png",
    "249": "L/UNT.png",
    "2459": "L/NIU.png",
    "77": "L/NU.png",
    "87": "L/ND.png",
    "195": "L/OHIO.png",
    "194": "L/OSU.png",
    "201": "L/OU.png",
    "197": "L/OKST.png",
    "295": "L/ODU.png",
    "145": "L/MISS.png",
    "2483": "L/ORE.png",
    "204": "L/ORST.png",
    "213": "L/PSU.png",
    "221": "L/PITT.png",
    "2509": "L/PUR.png",
    "242": "L/RICE.png",
    "164": "L/RUTG.png",
    "16": "L/SAC.png",
    "2534": "L/SHSU.png",
    "21": "L/SDSU.png",
    "23": "L/SJSU.png",
    "2567": "L/SMU.png",
    "6": "L/USA.png",
    "2579": "L/SC.png",
    "58": "L/USF.png",
    "2572": "L/USM.png",
    "24": "L/STAN.png",
    "183": "L/SYR.png",
    "2628": "L/TCU.png",
    "218": "L/TEM.png",
    "2633": "L/TENN.png",
    "251": "L/TEX.png",
    "245": "L/TAM.png",
    "326": "L/TXST.png",
    "2641": "L/TTU.png",
    "2649": "L/TOL.png",
    "2653": "L/TROY.png",
    "2655": "L/TULN.png",
    "202": "L/TLSA.png",
    "5": "L/UAB.png",
    "2116": "L/UCF.png",
    "26": "L/UCLA.png",
    "41": "L/CONN.png",
    "2433": "L/ULM.png",
    "2439": "L/UNLV.png",
    "30": "L/USC.png",
    "254": "L/UTAH.png",
    "328": "L/USU.png",
    "2638": "L/UTEP.png",
    "2636": "L/UTSA.png",
    "238": "L/VAN.png",
    "258": "L/UVA.png",
    "259": "L/VT.png",
    "154": "L/WAKE.png",
    "264": "L/WASH.png",
    "265": "L/WSU.png",
    "277": "L/WVU.png",
    "98": "L/WKU.png",
    "2711": "L/WMU.png",
    "275": "L/WIS.png",
    "2751": "L/WYO.png",
}

# ESPN team id -> list logo (24 x 18), from _logos/ncaa/S.
LOGO_S = {
    "2005": "S/AFA.png",
    "2006": "S/AKR.png",
    "333": "S/ALA.png",
    "2026": "S/APP.png",
    "12": "S/ARIZ.png",
    "9": "S/ASU.png",
    "8": "S/ARK.png",
    "2032": "S/ARST.png",
    "349": "S/ARMY.png",
    "2": "S/AUB.png",
    "2050": "S/BALL.png",
    "239": "S/BAY.png",
    "68": "S/BOIS.png",
    "103": "S/BC.png",
    "189": "S/BGSU.png",
    "2084": "S/BUFF.png",
    "252": "S/BYU.png",
    "25": "S/CAL.png",
    "2117": "S/CMU.png",
    "2429": "S/CLT.png",
    "2132": "S/CIN.png",
    "228": "S/CLEM.png",
    "324": "S/CCU.png",
    "38": "S/COLO.png",
    "36": "S/CSU.png",
    "48": "S/DEL.png",
    "150": "S/DUKE.png",
    "151": "S/ECU.png",
    "2199": "S/EMU.png",
    "57": "S/FLA.png",
    "2226": "S/FAU.png",
    "2229": "S/FIU.png",
    "52": "S/FSU.png",
    "278": "S/FRES.png",
    "61": "S/UGA.png",
    "290": "S/GASO.png",
    "2247": "S/GAST.png",
    "59": "S/GT.png",
    "62": "S/HAW.png",
    "248": "S/HOU.png",
    "356": "S/ILL.png",
    "84": "S/IU.png",
    "2294": "S/IOWA.png",
    "66": "S/ISU.png",
    "55": "S/JXST.png",
    "256": "S/JMU.png",
    "2305": "S/KU.png",
    "2306": "S/KSU.png",
    "338": "S/KENN.png",
    "2309": "S/KENT.png",
    "96": "S/UK.png",
    "2335": "S/LIB.png",
    "309": "S/UL.png",
    "2348": "S/LT.png",
    "97": "S/LOU.png",
    "99": "S/LSU.png",
    "276": "S/MRSH.png",
    "120": "S/MD.png",
    "113": "S/MASS.png",
    "235": "S/MEM.png",
    "2390": "S/MIA.png",
    "193": "S/M-OH.png",
    "130": "S/MICH.png",
    "127": "S/MSU.png",
    "2393": "S/MTSU.png",
    "135": "S/MINN.png",
    "344": "S/MSST.png",
    "142": "S/MIZ.png",
    "2623": "S/MOST.png",
    "2426": "S/NAVY.png",
    "152": "S/NCSU.png",
    "158": "S/NEB.png",
    "2440": "S/NEV.png",
    "167": "S/UNM.png",
    "166": "S/NMSU.png",
    "153": "S/UNC.png",
    "2449": "S/NDSU.png",
    "249": "S/UNT.png",
    "2459": "S/NIU.png",
    "77": "S/NU.png",
    "87": "S/ND.png",
    "195": "S/OHIO.png",
    "194": "S/OSU.png",
    "201": "S/OU.png",
    "197": "S/OKST.png",
    "295": "S/ODU.png",
    "145": "S/MISS.png",
    "2483": "S/ORE.png",
    "204": "S/ORST.png",
    "213": "S/PSU.png",
    "221": "S/PITT.png",
    "2509": "S/PUR.png",
    "242": "S/RICE.png",
    "164": "S/RUTG.png",
    "16": "S/SAC.png",
    "2534": "S/SHSU.png",
    "21": "S/SDSU.png",
    "23": "S/SJSU.png",
    "2567": "S/SMU.png",
    "6": "S/USA.png",
    "2579": "S/SC.png",
    "58": "S/USF.png",
    "2572": "S/USM.png",
    "24": "S/STAN.png",
    "183": "S/SYR.png",
    "2628": "S/TCU.png",
    "218": "S/TEM.png",
    "2633": "S/TENN.png",
    "251": "S/TEX.png",
    "245": "S/TAM.png",
    "326": "S/TXST.png",
    "2641": "S/TTU.png",
    "2649": "S/TOL.png",
    "2653": "S/TROY.png",
    "2655": "S/TULN.png",
    "202": "S/TLSA.png",
    "5": "S/UAB.png",
    "2116": "S/UCF.png",
    "26": "S/UCLA.png",
    "41": "S/CONN.png",
    "2433": "S/ULM.png",
    "2439": "S/UNLV.png",
    "30": "S/USC.png",
    "254": "S/UTAH.png",
    "328": "S/USU.png",
    "2638": "S/UTEP.png",
    "2636": "S/UTSA.png",
    "238": "S/VAN.png",
    "258": "S/UVA.png",
    "259": "S/VT.png",
    "154": "S/WAKE.png",
    "264": "S/WASH.png",
    "265": "S/WSU.png",
    "277": "S/WVU.png",
    "98": "S/WKU.png",
    "2711": "S/WMU.png",
    "275": "S/WIS.png",
    "2751": "S/WYO.png",
}

# Dropdown label -> ESPN team id.
SCHOOLS = {
    "AIR FORCE": "2005",
    "AKRON": "2006",
    "ALABAMA": "333",
    "APP STATE": "2026",
    "ARIZONA": "12",
    "ARIZONA STATE": "9",
    "ARKANSAS": "8",
    "ARKANSAS STATE": "2032",
    "ARMY": "349",
    "AUBURN": "2",
    "BALL STATE": "2050",
    "BAYLOR": "239",
    "BOISE STATE": "68",
    "BOSTON COLLEGE": "103",
    "BOWLING GREEN": "189",
    "BUFFALO": "2084",
    "BYU": "252",
    "CALIFORNIA": "25",
    "CENTRAL MICHIGAN": "2117",
    "CHARLOTTE": "2429",
    "CINCINNATI": "2132",
    "CLEMSON": "228",
    "COASTAL CAROLINA": "324",
    "COLORADO": "38",
    "COLORADO STATE": "36",
    "DELAWARE": "48",
    "DUKE": "150",
    "EAST CAROLINA": "151",
    "EASTERN MICHIGAN": "2199",
    "FLORIDA": "57",
    "FLORIDA ATLANTIC": "2226",
    "FLORIDA INTERNATIONAL": "2229",
    "FLORIDA STATE": "52",
    "FRESNO STATE": "278",
    "GEORGIA": "61",
    "GEORGIA SOUTHERN": "290",
    "GEORGIA STATE": "2247",
    "GEORGIA TECH": "59",
    "HAWAI'I": "62",
    "HOUSTON": "248",
    "ILLINOIS": "356",
    "INDIANA": "84",
    "IOWA": "2294",
    "IOWA STATE": "66",
    "JACKSONVILLE STATE": "55",
    "JAMES MADISON": "256",
    "KANSAS": "2305",
    "KANSAS STATE": "2306",
    "KENNESAW STATE": "338",
    "KENT STATE": "2309",
    "KENTUCKY": "96",
    "LIBERTY": "2335",
    "LOUISIANA": "309",
    "LOUISIANA TECH": "2348",
    "LOUISVILLE": "97",
    "LSU": "99",
    "MARSHALL": "276",
    "MARYLAND": "120",
    "MASSACHUSETTS": "113",
    "MEMPHIS": "235",
    "MIAMI": "2390",
    "MIAMI (OH)": "193",
    "MICHIGAN": "130",
    "MICHIGAN STATE": "127",
    "MIDDLE TENNESSEE": "2393",
    "MINNESOTA": "135",
    "MISSISSIPPI STATE": "344",
    "MISSOURI": "142",
    "MISSOURI STATE": "2623",
    "NAVY": "2426",
    "NC STATE": "152",
    "NEBRASKA": "158",
    "NEVADA": "2440",
    "NEW MEXICO": "167",
    "NEW MEXICO STATE": "166",
    "NORTH CAROLINA": "153",
    "NORTH DAKOTA STATE": "2449",
    "NORTH TEXAS": "249",
    "NORTHERN ILLINOIS": "2459",
    "NORTHWESTERN": "77",
    "NOTRE DAME": "87",
    "OHIO": "195",
    "OHIO STATE": "194",
    "OKLAHOMA": "201",
    "OKLAHOMA STATE": "197",
    "OLD DOMINION": "295",
    "OLE MISS": "145",
    "OREGON": "2483",
    "OREGON STATE": "204",
    "PENN STATE": "213",
    "PITTSBURGH": "221",
    "PURDUE": "2509",
    "RICE": "242",
    "RUTGERS": "164",
    "SACRAMENTO STATE": "16",
    "SAM HOUSTON": "2534",
    "SAN DIEGO STATE": "21",
    "SAN JOSE STATE": "23",
    "SMU": "2567",
    "SOUTH ALABAMA": "6",
    "SOUTH CAROLINA": "2579",
    "SOUTH FLORIDA": "58",
    "SOUTHERN MISS": "2572",
    "STANFORD": "24",
    "SYRACUSE": "183",
    "TCU": "2628",
    "TEMPLE": "218",
    "TENNESSEE": "2633",
    "TEXAS": "251",
    "TEXAS A&M": "245",
    "TEXAS STATE": "326",
    "TEXAS TECH": "2641",
    "TOLEDO": "2649",
    "TROY": "2653",
    "TULANE": "2655",
    "TULSA": "202",
    "UAB": "5",
    "UCF": "2116",
    "UCLA": "26",
    "UCONN": "41",
    "UL MONROE": "2433",
    "UNLV": "2439",
    "USC": "30",
    "UTAH": "254",
    "UTAH STATE": "328",
    "UTEP": "2638",
    "UTSA": "2636",
    "VANDERBILT": "238",
    "VIRGINIA": "258",
    "VIRGINIA TECH": "259",
    "WAKE FOREST": "154",
    "WASHINGTON": "264",
    "WASHINGTON STATE": "265",
    "WEST VIRGINIA": "277",
    "WESTERN KENTUCKY": "98",
    "WESTERN MICHIGAN": "2711",
    "WISCONSIN": "275",
    "WYOMING": "2751",
}

# ------------------------------------------------------------- text tools
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-:;/&+%#!?()$@"

def clean(s):
    out = ""
    for ch in str(s).upper().elems():
        if KEEP.find(ch) >= 0:
            out += ch
    return out.strip()

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

HEXD = "0123456789abcdef"

def rgb(h):
    t = str(h).lower().lstrip("#")
    if len(t) != 6:
        return [110, 122, 148]
    return [HEXD.find(t[i]) * 16 + HEXD.find(t[i + 1]) for i in [0, 2, 4]]

def hexs(v):
    out = "#"
    for x in v:
        x = max(0, min(255, x))
        out += HEXD[x // 16] + HEXD[x % 16]
    return out

def lift(h):
    """A club colour bright enough to read as an outline on black: navy,
    maroon and black are scaled up until their brightest channel is 200."""
    v = rgb(h)
    m = max(v[0], v[1], v[2])
    if m < 40:
        return "#9AA3B2"
    if m >= 200:
        return hexs(v)
    return hexs([x * 200 // m for x in v])

def ink_for(fill):
    v = rgb(fill)
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def num(s, fallback = -1):
    t = str(s).strip()
    if t == "":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return int(t)

def spread_text(x):
    """16.5 -> '16.5', 10.0 -> '10'."""
    t = str(x)
    if t.endswith(".0"):
        t = t[:len(t) - 2]
    return t

# ------------------------------------------------------------------ feeds
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

def team_of(comp):
    t = get(comp, "team", {})
    rank = num(dig(comp, ["curatedRank", "current"], 99), 99)
    return {
        "id": str(get(t, "id", "")),
        "abbr": clean(get(t, "abbreviation", "")),
        "short": clean(get(t, "shortDisplayName", get(t, "location", ""))),
        "color": str(get(t, "color", "6e7a94")),
        "alt": str(get(t, "alternateColor", "")),
        "rank": rank if rank >= 1 and rank <= 25 else 99,
        "score": num(get(comp, "score", ""), -1),
        "winner": get(comp, "winner", False) == True,
        "side": str(get(comp, "homeAway", "")),
    }

def finals(j):
    """Every completed game in a scoreboard as [winner, loser, event id, ot]."""
    games = []
    for e in get(j, "events", []):
        comps = get(e, "competitions", [])
        if len(comps) == 0:
            continue
        cp = comps[0]
        st = dig(cp, ["status", "type"], {})
        if get(st, "completed", False) != True:
            continue
        cs = get(cp, "competitors", [])
        if len(cs) != 2:
            continue
        a = team_of(cs[0])
        b = team_of(cs[1])
        if a["winner"] == b["winner"] or a["score"] < 0 or b["score"] < 0:
            continue
        w = a if a["winner"] else b
        l = b if a["winner"] else a
        ot = str(get(st, "shortDetail", "")).upper().find("OT") >= 0
        neutral = get(cp, "neutralSite", False) == True
        games.append({"w": w, "l": l, "id": str(get(e, "id", "")), "ot": ot, "neutral": neutral})
    return games

def candidates(games):
    """A ranked team beaten by an unranked or lower-ranked one."""
    out = []
    for g in games:
        if g["l"]["rank"] < 99 and g["w"]["rank"] > g["l"]["rank"]:
            out.append(g)
    return out

def rank_gap(g):
    w = g["w"]["rank"] if g["w"]["rank"] < 99 else 30
    return w - g["l"]["rank"]

def closing_line(eid, w_side):
    """[dog points or -1 if the winner was favoured, found, winner's
    moneyline or 0]. Pick'em is 0 points."""
    r = http.get(ODDS.format(e = eid), headers = HEADERS, ttl_seconds = ODDS_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return [0, False, 0]
    items = get(r["json"], "items", [])
    for it in items:
        sp = get(it, "spread", None)
        if type(sp) not in ["float", "int"]:
            continue
        side = "homeTeamOdds" if w_side == "home" else "awayTeamOdds"
        ml = dig(it, [side, "moneyLine"], 0)
        ml = int(ml) if type(ml) in ["float", "int"] else 0
        home_fav = dig(it, ["homeTeamOdds", "favorite"], None)
        away_fav = dig(it, ["awayTeamOdds", "favorite"], None)
        pts = sp if sp >= 0 else -sp
        if pts == 0:
            return [0, True, ml]
        if home_fav == None and away_fav == None:
            # No flags: ESPN's spread is the home line, negative = home favoured.
            home_fav = sp < 0
            away_fav = not home_fav
        w_fav = home_fav if w_side == "home" else away_fav
        return [-1 if w_fav == True else pts, True, ml]
    return [0, False, 0]

def classify(g, line, found):
    if found and line < 0:
        return "FELL"
    if found and line >= 14:
        return "SHOCK"
    if found and line >= 7:
        return "BIG"
    if found:
        return "UPSET"
    # No line on record: judge by the ranks alone.
    if g["w"]["rank"] == 99 and g["l"]["rank"] <= 10:
        return "BIG"
    return "UPSET"

def prev_week(j):
    """[seasontype, week] of the week before this one, or None."""
    stype = num(dig(j, ["season", "type"], ""), 0)
    wk = num(dig(j, ["week", "number"], ""), 0)
    if stype == 2 and wk > 1:
        return [2, wk - 1]
    if stype == 3:
        lg = get(j, "leagues", [])
        cal = get(lg[0], "calendar", []) if len(lg) > 0 else []
        for part in cal:
            if type(part) == "dict" and str(get(part, "value", "")) == "2":
                ents = get(part, "entries", [])
                if len(ents) > 0:
                    return [2, num(get(ents[len(ents) - 1], "value", ""), 15)]
        return [2, 15]
    return None

def week_label(stype, wk):
    return "BOWLS" if stype == 3 else "WK " + str(wk)

def fetch_week(ctx):
    r = http.get(SCOREBOARD, headers = HEADERS, ttl_seconds = CURRENT_TTL)
    if r["status_code"] == 0:
        return {"ok": False, "head": "ESPN OFFLINE", "sub": "CHECKING AGAIN IN 5 MIN"}
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "head": "SCOREBOARD ERROR", "sub": "HTTP " + str(r["status_code"]) + " - RETRY SOON"}
    j = r["json"]
    stype = num(dig(j, ["season", "type"], ""), 0)
    wk = num(dig(j, ["week", "number"], ""), 0)
    if stype not in [2, 3]:
        return {"ok": True, "off": True}
    events = get(j, "events", [])
    games = finals(j)
    cands = candidates(games)
    use_current = len(cands) > 0 or (len(events) > 0 and len(games) * 2 >= len(events))
    if not use_current:
        pw = prev_week(j)
        if pw != None:
            r2 = http.get(SCOREBOARD, params = {"seasontype": str(pw[0]), "week": str(pw[1])},
                          headers = HEADERS, ttl_seconds = PAST_TTL)
            if r2["status_code"] == 200 and type(r2["json"]) == "dict":
                j = r2["json"]
                stype, wk = pw[0], pw[1]
                events = get(j, "events", [])
                games = finals(j)
                cands = candidates(games)
    if len(games) == 0:
        return {"ok": True, "off": False, "week": week_label(stype, wk), "games": 0,
                "events": len(events), "upsets": []}

    # Most promising first so the odds budget goes to the biggest stories.
    cands = sorted(cands, key = lambda g: -rank_gap(g))
    ups = []
    for i in range(len(cands)):
        g = cands[i]
        line, found, ml = 0, False, 0
        if i < MAX_ODDS:
            lf = closing_line(g["id"], g["w"]["side"])
            line, found, ml = lf[0], lf[1], lf[2]
        tier = classify(g, line, found)
        ups.append(dict(g, tier = tier, line = line, found = found, ml = ml))
    # "events" is the whole slate, "games" its finals: CHALK WEEK is only
    # called once games == events, never while Top 25 games are still on.
    return {"ok": True, "off": False, "week": week_label(stype, wk), "games": len(games),
            "events": len(events), "upsets": ups}

def severity(u):
    """Sort key: tier first, then the size of the line, then the rank gap."""
    return [TIER_ORDER[u["tier"]], -(u["line"] if u["found"] else 0), -rank_gap(u)]

def my_school(ctx):
    s = str(ctx.inputs.get("school", "NONE")).strip().upper()
    return SCHOOLS.get(s, "")

# ------------------------------------------------------------- drawing kit
def rail(c, color):
    # x 6..7: nothing lights x 0..5 or 186..191, so the app never runs
    # into its neighbours on a scroll wall.
    c.rect(6, 0, 7, 31, fill = color)

def logo(c, team, x, y, big):
    """The school's own logo, or - for an FCS school outside the set - a tidy
    box in its colour with its abbreviation, the same footprint."""
    table = LOGO_L if big else LOGO_S
    path = table.get(team["id"], "")
    w = 40 if big else 24
    h = 24 if big else 18
    if path != "":
        c.image(path, x, y)
        return
    col = lift(team["color"])
    c.round_rect(x + 1, y + 1, x + w - 2, y + h - 2, r = 3, outline = col)
    ab = team["abbr"] if team["abbr"] != "" else "FCS"
    f = fit(c, ab, ["8x10", "6x8", "5x7", "4x5"] if big else ["5x7", "4x5"], w - 6)
    fh = {"8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}[f[0]]
    c.text(f[1], x + w // 2, y + (h - fh) // 2, font = f[0], color = INK, align = "center")

def crack(c, path, x, y, color):
    """The strike that felled the giant: a 1 px lightning line in the tier
    colour down the loser's logo, cut out of it by 1 px of black each side
    so it reads on maroon, orange or white crests alike. path is one x
    offset per row; sideways steps are bridged so the bolt never breaks."""
    for i in range(len(path)):
        a = path[i]
        b = path[i]
        if i + 1 < len(path):
            a = min(a, path[i + 1])
            b = max(b, path[i + 1])
        c.rect(x + a - 1, y + i, x + b + 1, y + i, fill = "black")
    for i in range(len(path)):
        a = path[i]
        b = path[i]
        if i + 1 < len(path):
            a = min(a, path[i + 1])
            b = max(b, path[i + 1])
        c.rect(x + a, y + i, x + b, y + i, fill = color)

def brackets(c, x0, y0, x1, y1, color):
    """Gold corner brackets round a logo: this is your school."""
    for p in [[x0, y0, 1, 1], [x1, y0, -1, 1], [x0, y1, 1, -1], [x1, y1, -1, -1]]:
        c.line(p[0], p[1], p[0] + 3 * p[2], p[1], color)
        c.line(p[0], p[1], p[0], p[1] + 3 * p[3], color)

def rank_word(r):
    return "#" + str(r) if r < 99 else "UNRANKED"

def cracked_badge(c, rank, cx, y, fill = C_SHOCK):
    """The loser's rank on a badge in the tier colour with a black crack
    through its tail and a falling arrow beside it, centred on cx."""
    word = "#" + str(rank)
    tw = c.text_width(word, "4x5")
    # 2 px pad, the digits, then a 5 px tail that carries the crack, so the
    # crack never lands on a digit ('#7' lost its 7 when it ran through the
    # middle of the badge).
    bw = 2 + tw + 5
    total = bw + 2 + 5
    x = cx - total // 2
    c.rect(x, y, x + bw - 1, y + 6, fill = fill)
    c.text(word, x + 2, y + 1, font = "4x5", color = ink_for(fill))
    k = x + 2 + tw + 2
    for p in [[k, y], [k + 1, y + 1], [k, y + 2], [k - 1, y + 3], [k, y + 4], [k + 1, y + 5], [k + 1, y + 6]]:
        c.pixel(p[0], p[1], "black")
    c.sprite(DOWN, x + bw + 2, y + 1, legend = {"X": fill})

def fail_screen(c, head, sub):
    c.fill("black")
    rail(c, OFFLINE)
    c.sprite(BALL, 10, 12, legend = BALL_LEGEND)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 150)
    c.text(hf[1], 104, 8, font = hf[0], color = "amber", align = "center")
    sf = fit(c, sub, ["4x5", "picopixel"], 150)
    c.text(sf[1], 104, 21, font = sf[0], color = DIM, align = "center")

def calm_screen(c, head, sub, week, crown = False):
    """Good news or quiet news, never an error: the crown when every
    favourite held (chalk), a football while there is simply nothing yet."""
    c.fill("black")
    rail(c, GOOD)
    if crown:
        c.sprite(CROWN, 12, 11, legend = {"X": GOLD, "J": GOOD}, scale = 2)
    else:
        c.sprite(BALL, 10, 9, legend = BALL_LEGEND, scale = 2)
    # Head x 38..181 (y 5..20 in 10x16); the week sits bottom right on the
    # sub's row, measured first, so a 139 px 'NO UPSETS YET' never runs
    # into it (at the top right it touched the head's first row).
    hf = fit(c, head, ["10x16", "8x10", "6x8", "5x7"], 144)
    c.text(hf[1], 38, 5 if hf[0] == "10x16" else 8, font = hf[0], color = GOOD)
    right = 181
    if week != "":
        c.text(week, 181, 24, font = "4x5", color = DIM, align = "right")
        right = 181 - c.text_width(week, "4x5") - 4
    sf = fit(c, sub, ["4x5", "picopixel"], right - 38 + 1)
    c.text(sf[1], 38, 24, font = sf[0], color = DIM)

def quiet_week(c, d, all_done_sub):
    """No upsets on the board: CHALK WEEK only once the whole slate is final,
    otherwise the games are still being played."""
    if d["games"] >= d["events"]:
        calm_screen(c, "CHALK WEEK", all_done_sub, d["week"], True)
    else:
        calm_screen(c, "NO UPSETS YET",
                    str(d["games"]) + " OF " + str(d["events"]) + " GAMES FINAL", d["week"])

def is_real(u):
    return u["tier"] != "FELL"

# ------------------------------------------------------------- page: upsets
def upsets(c, ctx):
    d = fetch_week(ctx)
    if not d["ok"]:
        fail_screen(c, d["head"], d["sub"])
        return
    if d["off"]:
        calm_screen(c, "OFFSEASON", "UPSETS RETURN AT KICKOFF", "")
        return
    if d["games"] == 0:
        calm_screen(c, "NO FINALS YET", "UPSETS SHOW UP AS GAMES END", d["week"])
        return
    size = str(ctx.inputs.get("size", "ALL UPSETS")).strip().upper()
    real = [u for u in d["upsets"] if is_real(u)]
    if size == "BIG UPSETS ONLY":
        ups = [u for u in real if u["tier"] in ["SHOCK", "BIG"]]
    elif len(real) >= 2:
        # A favoured winner over a ranked team (Louisville -3 over #16 SMU)
        # is not an upset: it stays on carnage, and only fills the rotation
        # here in a week with fewer than two real upsets.
        ups = real
    else:
        ups = d["upsets"]
    if len(ups) == 0:
        if size == "BIG UPSETS ONLY" and len(real) > 0:
            # 'N SMALLER UPSETS - SET SIZE TO ALL' was 122 px in a 120 box.
            n = len(real)
            calm_screen(c, "NO BIG UPSETS", str(n) + (" SMALLER UPSET" if n == 1 else " SMALLER UPSETS") + " THIS WEEK", d["week"])
        else:
            quiet_week(c, d, "NO UPSETS IN " + str(d["games"]) + " FINALS")
        return
    mine = my_school(ctx)
    ups = sorted(ups, key = lambda u: [0 if mine != "" and (u["w"]["id"] == mine or u["l"]["id"] == mine) else 1] + severity(u))
    n = len(ups)
    idx = (ctx.now.unix // FRAME_SECONDS) % n
    draw_upset(c, ups[idx], idx, n, mine)

def draw_upset(c, u, idx, n, mine):
    c.fill("black")
    w, l = u["w"], u["l"]
    t = TIER[u["tier"]]

    # Logos: the winner left, the fallen giant right with a crack through it.
    logo(c, w, WL_X, LOGO_Y, True)
    logo(c, l, LL_X, LOGO_Y, True)
    crack(c, CRACK_PATH, LL_X, LOGO_Y, t[1])
    winner_tag = rank_word(w["rank"])
    c.text(winner_tag, WL_X + 20, 26, font = "4x5", color = GOOD, align = "center")
    cracked_badge(c, l["rank"], LL_X + 20, 25, t[1])
    if mine != "":
        if w["id"] == mine:
            brackets(c, WL_X - 2, 0, WL_X + 41, 31, GOLD)
        if l["id"] == mine:
            brackets(c, LL_X - 2, 0, LL_X + 41, 31, GOLD)

    # Chip row, right side measured first: the frame counter, then the tier
    # pill from the left, then a ROAD / NEUTRAL tag only if it keeps 3 px
    # clear of the counter ('BIG UPSET' + 'NEUTRAL' + '10/12' is 108 px in
    # an 88 px zone, so the tag is the piece that gives way).
    meta = str(idx + 1) + "/" + str(n) if n > 1 else ""
    mw = c.text_width(meta, "4x5") if meta != "" else 0
    x = MID_L
    x += c.badge(t[0], x, 0, color = ink_for(t[1]), bg = t[1], font = "4x5")
    if meta != "":
        c.text(meta, MID_R, 1, font = "4x5", color = DIM, align = "right")
    tag = ""
    if u["tier"] != "FELL":
        if u["neutral"]:
            tag = "NEUTRAL"
        elif w["side"] == "away":
            tag = "ROAD"
    if tag != "":
        right = MID_R - mw - 3 if mw > 0 else MID_R
        if x + 3 + c.text_width(tag, "4x5") <= right:
            c.text(tag, x + 3, 1, font = "4x5", color = C_ROAD if tag == "ROAD" else DIM)

    # Score hero: the winner's points lit, the loser's dimmed, a bar between.
    ws = str(w["score"])
    ls = str(l["score"])
    f = "10x16"
    gap = 4
    dash = 6
    total = c.text_width(ws, f) + gap + dash + gap + c.text_width(ls, f)
    if total > MID_W - 20:
        f = "8x10"
        total = c.text_width(ws, f) + gap + dash + gap + c.text_width(ls, f)
    x = MID_C - total // 2
    y = 9 if f == "10x16" else 12
    c.text(ws, x, y, font = f, color = INK)
    x += c.text_width(ws, f) + gap
    c.rect(x, y + 7, x + dash - 1, y + 8, fill = DIM)
    x += dash + gap
    c.text(ls, x, y, font = f, color = LOSER)
    x += c.text_width(ls, f)
    if u["ot"]:
        # Bottom-aligned with the digits, 3 px clear of the loser's score.
        c.text("OT", x + 3, y + (9 if f == "10x16" else 4), font = "4x5", color = DIM)

    # Bottom row: the underdog and his points, then the moneyline fans
    # quote ('ML +575'), or why it wasn't an upset.
    if u["found"] and u["line"] > 0:
        txt = "+" + spread_text(u["line"])
        tw = c.text_width(txt, "5x7")
        mlt = "+" + str(u["ml"]) if u["ml"] > 0 else ""
        mlw = 10 + 2 + c.text_width(mlt, "5x7") if mlt != "" else 0
        # '+27.5' and 'ML +2000' together are 87 px in the 88 px zone.
        dw = 12 + 2 + tw + (4 + mlw if mlw > 0 else 0)
        if dw > MID_W:
            mlw = 0
            dw = 12 + 2 + tw
        x0 = MID_C - dw // 2
        c.sprite(DOG, x0, 25, legend = DOG_LEGEND)
        c.text(txt, x0 + 14, 25, font = "5x7", color = C_DOG)
        if mlw > 0:
            mx = x0 + 14 + tw + 4
            c.text("ML", mx, 27, font = "4x5", color = DIM)
            c.text(mlt, mx + 12, 25, font = "5x7", color = INK)
    elif u["found"] and u["line"] == 0:
        c.text("PICK EM", MID_C, 26, font = "4x5", color = C_UPSET, align = "center")
    elif u["found"]:
        c.text("WINNER WAS FAVORED", MID_C, 26, font = "4x5", color = C_FELL, align = "center")
    else:
        c.text("NO LINE ON RECORD", MID_C, 26, font = "4x5", color = DIM, align = "center")

# ------------------------------------------------------------ page: carnage
def carnage(c, ctx):
    d = fetch_week(ctx)
    if not d["ok"]:
        fail_screen(c, d["head"], d["sub"])
        return
    if d["off"]:
        calm_screen(c, "OFFSEASON", "UPSETS RETURN AT KICKOFF", "")
        return
    if d["games"] == 0:
        calm_screen(c, "NO FINALS YET", "UPSETS SHOW UP AS GAMES END", d["week"])
        return
    fallen = sorted(d["upsets"], key = lambda u: u["l"]["rank"])
    if len(fallen) == 0:
        quiet_week(c, d, "EVERY RANKED TEAM WON")
        return
    mine = my_school(ctx)
    c.fill("black")
    rail(c, C_SHOCK)

    # Left: the count as the hero, split by the same fault line as the
    # upset card, labelled. Two digits in 16x20 are 33 px, which ran
    # 'RANKED' into the first logo slot; a 10+ week drops to 10x16.
    cnt = str(len(fallen))
    nf = "16x20" if len(fallen) < 10 else "10x16"
    ny = 3 if nf == "16x20" else 5
    c.text(cnt, 10, ny, font = nf, color = C_SHOCK)
    cw = c.text_width(cnt, nf)
    lx = 10 + cw + 3
    c.text("RANKED", lx, 4, font = "4x5", color = INK)
    c.text("TEAM" if len(fallen) == 1 else "TEAMS", lx, 10, font = "4x5", color = INK)
    c.text("FELL", lx, 16, font = "4x5", color = INK)
    c.text(d["week"], 10, 26, font = "4x5", color = DIM)

    # Right: the fallen, best-ranked first, 24 x 18 logos over badges in
    # their tier colour (red shocker, orange big, amber upset, purple a
    # favoured winner), so the row tells the story with no more words.
    # 30 px slots from x 64: a '#25' badge with its arrow is 28 px wide, so
    # at 29 the #16 arrow touched the #25 badge. The last slot ends at x 183.
    slots = 4
    x0 = 64
    step = 30
    show = fallen[:slots]
    extra = len(fallen) - len(show)
    if extra > 0:
        show = fallen[:slots - 1]
        extra = len(fallen) - len(show)
    used = len(show) + (1 if extra > 0 else 0)
    x0 = x0 + (4 - used) * step // 2
    for i in range(len(show)):
        u = show[i]
        x = x0 + i * step
        logo(c, u["l"], x, 3, False)
        cracked_badge(c, u["l"]["rank"], x + 12, 24, TIER[u["tier"]][1])
        if mine != "" and u["l"]["id"] == mine:
            # Round the logo only: full-height brackets touched the badge.
            brackets(c, x - 2, 1, x + 25, 21, GOLD)
    if extra > 0:
        x = x0 + len(show) * step
        c.text("+" + str(extra), x + 12, 8, font = "6x8", color = C_SHOCK, align = "center")
        c.text("MORE", x + 12, 18, font = "4x5", color = DIM, align = "center")
