# College Football Stat Leaders
#
# The FBS leaderboards the Heisman race is argued over - passing yards,
# touchdowns and QB rating, rushing yards and touchdowns, receiving yards,
# catches and touchdowns, tackles, sacks and interceptions - one board per
# frame, from ESPN's college leaders feed
# (site.web.api.espn.com/apis/site/v3/.../leaders, limit=3: every
# category's top 3 in one ~510 KB call). A conference pick narrows the same
# call with ESPN's group id.
#
# DESIGN. The race chart. Each frame is one leaderboard run as a race: the
# top 3 are three bars growing left to right from gold / silver / bronze
# starting blocks, each bar painted in the school's own colour and tipped
# in its second colour (the jersey trim), the player's last name and
# position printed inside at the left and his number at the tip. From
# every tip hangs the school's 24 x 18 logo like a pennant, top-aligned
# with its bar, so the three pennants step down and back across the
# panel - the leader's at the right edge, the chasers behind him by how
# far they trail (at least a logo's width, so no two ever touch). Under
# the leader's pennant: the stat family's icon. In the corner the bars
# leave free: the board's name in the family colour (PASS YDS, QB RTG,
# CATCHES, SACKS...), the week, and the scope. No logo column on the left: the logos ride the race.
#
#   y 0-5    [1]MAIAVA QB ==========================1173|  +-USC--+
#   y 7-12   [2]ATKINSON QB ================1120|  +-ORST-+  |      |
#   y 14-19  [3]STOKES QB ======1053|  +-MEM--+  |      |  +------+
#   y 21-25  PASS YDS  WEEK 4       |      |  +------+   (ball)
#   y 27-31  FBS                    +------+
#
# Palette: PASSING #4A9CFF, RUSHING #3CE0A0 (turf), RECEIVING #FF9A3C,
# DEFENSE #FF5AB4 - validated for colour-blind separation on black, and
# every family also carries its word and its icon. Gold #FFC72C belongs to
# the #1 block only.
#
# Frames: refresh is 120 s and the frame steps every two minutes, one
# chosen leaderboard at a time. The feed is cached for 1800 s: college
# stats move on Saturdays, not by the minute. The Stat input picks a family
# (or TOUCHDOWNS: the pass, rush and receiving TD boards) rather than a
# single board, so 6 x 12 conference choices = 72 combinations stays under
# the 100 allowed at a 2-minute refresh.

LEADERS = "https://site.web.api.espn.com/apis/site/v3/sports/football/college-football/leaders"
HEADERS = {"User-Agent": "glance-college-football-stat-leaders (glance-led.dev)"}
TTL = 1800
FRAME_SECONDS = 120

# ------------------------------------------------------------------ layout
# 192 wide, x 6..185. Three bars stacked from the top, 6 rows each with a
# row of black between (y 0..5, 7..12, 14..19), all starting at x 6: a
# 6 px gold / silver / bronze rank block, a column of black, then the bar
# in the school's colour. Each school's 24 x 18 logo hangs from its bar's
# tip, top-aligned with the bar (y 0, 7, 14), so the three pennants step
# down and to the left: #1's right edge is x 185, and every logo sits at
# least 26 px left of the one above (24 px logo + 2 px of black), which is
# what keeps three 18-row logos apart in 32 rows. Bar i ends 2 px before
# its logo. Under #1's logo (x 162..185, y 20..31) the family icon; the
# corner under the bars (x 6 .. #3's logo - 2, y 21..31) holds
# the board name, scope and week.
EDGE_L = 6
EDGE_R = 185
RANK_W = 6
BAR_X = EDGE_L + RANK_W + 1
BAR_H = 6
BAR_Y = [0, 7, 14]
LOGO_W = 24
LOGO_H = 18
P1 = EDGE_R - LOGO_W + 1          # 162: #1's logo
SEP = LOGO_W + 2                  # the least a logo can sit behind the one ahead
BACK_MAX = 66                     # #3 sits 52 (2 x SEP) to 66 px behind #1 (x >= 96), so its bar still holds a name
L1CX = P1 + LOGO_W // 2           # 174: centre of the column under #1
HEAD_Y = [21, 27]

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
SOFT = "#B8C2D6"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
GOLD = "#FFC72C"

C_PASS = "#4A9CFF"
C_RUSH = "#3CE0A0"
C_REC = "#FF9A3C"
C_DEF = "#FF5AB4"

# ESPN category name -> [family (Stat input + chip), label on the tab under
# the number, family colour, icon]. Order is the rotation order.
CATS = [
    ["passingYards", "PASSING", "PASS YDS", C_PASS, "PASS"],
    ["passingTouchdowns", "PASSING", "PASS TDS", C_PASS, "TD"],
    ["quarterbackRating", "PASSING", "QB RTG", C_PASS, "STAR"],
    ["rushingYards", "RUSHING", "RUSH YDS", C_RUSH, "RUSH"],
    ["rushingTouchdowns", "RUSHING", "RUSH TDS", C_RUSH, "TD"],
    ["receivingYards", "RECEIVING", "REC YDS", C_REC, "GLOVE"],
    ["receptions", "RECEIVING", "CATCHES", C_REC, "GLOVE"],
    ["receivingTouchdowns", "RECEIVING", "REC TDS", C_REC, "TD"],
    ["totalTackles", "DEFENSE", "TACKLES", C_DEF, "HELMET"],
    ["sacks", "DEFENSE", "SACKS", C_DEF, "BURST"],
    ["interceptions", "DEFENSE", "INTS", C_DEF, "PICK"],
]

# Dropdown label -> [ESPN group id, short label for the top row].
CONFS = {
    "ALL FBS": ["80", "FBS"],
    "SEC": ["8", "SEC"],
    "BIG TEN": ["5", "BIG TEN"],
    "BIG 12": ["4", "BIG 12"],
    "ACC": ["1", "ACC"],
    "AMERICAN": ["151", "AMERICAN"],
    "MOUNTAIN WEST": ["17", "MWC"],
    "SUN BELT": ["37", "SUN BELT"],
    "MAC": ["15", "MAC"],
    "CONFERENCE USA": ["12", "C-USA"],
    "PAC-12": ["9", "PAC-12"],
    "INDEPENDENTS": ["18", "INDEP"],
}

# ESPN abbreviation -> logo. 24 x 18, drawn at the size it was authored.
LOGO = {
    "AFA": "S/AFA.png", "AKR": "S/AKR.png", "ALA": "S/ALA.png", "APP": "S/APP.png", "ARIZ": "S/ARIZ.png",
    "ARK": "S/ARK.png", "ARMY": "S/ARMY.png", "ARST": "S/ARST.png", "ASU": "S/ASU.png",
    "AUB": "S/AUB.png", "BALL": "S/BALL.png", "BAY": "S/BAY.png", "BC": "S/BC.png", "BGSU": "S/BGSU.png",
    "BOIS": "S/BOIS.png", "BUFF": "S/BUFF.png", "BYU": "S/BYU.png", "CAL": "S/CAL.png",
    "CCU": "S/CCU.png", "CIN": "S/CIN.png", "CLEM": "S/CLEM.png", "CLT": "S/CLT.png", "CMU": "S/CMU.png",
    "COLO": "S/COLO.png", "CONN": "S/CONN.png", "CSU": "S/CSU.png", "DEL": "S/DEL.png",
    "DUKE": "S/DUKE.png", "ECU": "S/ECU.png", "EMU": "S/EMU.png", "FAU": "S/FAU.png", "FIU": "S/FIU.png",
    "FLA": "S/FLA.png", "FRES": "S/FRES.png", "FSU": "S/FSU.png", "GASO": "S/GASO.png",
    "GAST": "S/GAST.png", "GT": "S/GT.png", "HAW": "S/HAW.png", "HOU": "S/HOU.png", "ILL": "S/ILL.png",
    "IOWA": "S/IOWA.png", "ISU": "S/ISU.png", "IU": "S/IU.png", "JMU": "S/JMU.png", "JXST": "S/JXST.png",
    "KENN": "S/KENN.png", "KENT": "S/KENT.png", "KSU": "S/KSU.png", "KU": "S/KU.png", "LIB": "S/LIB.png",
    "LOU": "S/LOU.png", "LSU": "S/LSU.png", "LT": "S/LT.png", "M-OH": "S/M-OH.png", "MASS": "S/MASS.png",
    "MD": "S/MD.png", "MEM": "S/MEM.png", "MIA": "S/MIA.png", "MICH": "S/MICH.png", "MINN": "S/MINN.png",
    "MISS": "S/MISS.png", "MIZ": "S/MIZ.png", "MOST": "S/MOST.png", "MRSH": "S/MRSH.png",
    "MSST": "S/MSST.png", "MSU": "S/MSU.png", "MTSU": "S/MTSU.png", "NAVY": "S/NAVY.png",
    "NCSU": "S/NCSU.png", "ND": "S/ND.png", "NDSU": "S/NDSU.png", "NEB": "S/NEB.png", "NEV": "S/NEV.png",
    "NIU": "S/NIU.png", "NMSU": "S/NMSU.png", "NU": "S/NU.png", "ODU": "S/ODU.png", "OHIO": "S/OHIO.png",
    "OKST": "S/OKST.png", "ORE": "S/ORE.png", "ORST": "S/ORST.png", "OSU": "S/OSU.png", "OU": "S/OU.png",
    "PITT": "S/PITT.png", "PSU": "S/PSU.png", "PUR": "S/PUR.png", "RICE": "S/RICE.png",
    "RUTG": "S/RUTG.png", "SAC": "S/SAC.png", "SC": "S/SC.png", "SDSU": "S/SDSU.png",
    "SHSU": "S/SHSU.png", "SJSU": "S/SJSU.png", "SMU": "S/SMU.png", "STAN": "S/STAN.png",
    "SYR": "S/SYR.png", "TA&M": "S/TAMU.png", "TCU": "S/TCU.png", "TEM": "S/TEM.png",
    "TENN": "S/TENN.png", "TEX": "S/TEX.png", "TLSA": "S/TLSA.png", "TOL": "S/TOL.png",
    "TROY": "S/TROY.png", "TTU": "S/TTU.png", "TULN": "S/TULN.png", "TXST": "S/TXST.png",
    "UAB": "S/UAB.png", "UCF": "S/UCF.png", "UCLA": "S/UCLA.png", "UGA": "S/UGA.png", "UK": "S/UK.png",
    "UL": "S/UL.png", "ULM": "S/ULM.png", "UNC": "S/UNC.png", "UNLV": "S/UNLV.png", "UNM": "S/UNM.png",
    "UNT": "S/UNT.png", "USA": "S/USA.png", "USC": "S/USC.png", "USF": "S/USF.png", "USM": "S/USM.png",
    "USU": "S/USU.png", "UTAH": "S/UTAH.png", "UTEP": "S/UTEP.png", "UTSA": "S/UTSA.png",
    "UVA": "S/UVA.png", "VAN": "S/VAN.png", "VT": "S/VT.png", "WAKE": "S/WAKE.png", "WASH": "S/WASH.png",
    "WIS": "S/WIS.png", "WKU": "S/WKU.png", "WMU": "S/WMU.png", "WSU": "S/WSU.png", "WVU": "S/WVU.png",
    "WYO": "S/WYO.png",
}

# --------------------------------------------------------------- pixel art
# The starting blocks: gold, silver, bronze.
METAL = {1: GOLD, 2: "#C4CCD8", 3: "#D9883F"}

# Header icons, 7 rows tall. X takes the stat family's colour.
ICONS = {
    # a thrown ball with speed lines
    "PASS": """
.......BB
.....BBWB
SS..BBWBB
...BBWBB.
SSBBWBB..
..BBBB...
SS.......
""",
    # a cleat
    "RUSH": """
..XX.....
..XXX....
..XXXX...
..XXXXX..
.XXXXXXXX
.XXXXXXXX
.K.K.K.K.
""",
    # two hands closing on the ball
    "GLOVE": """
X.......X
X..BBB..X
XXBBWBBXX
XXBWBBBXX
XXXBBBXXX
.XXXXXXX.
..XXXXX..
""",
    # the goalpost
    "TD": """
X.....X
X.....X
X.....X
XXXXXXX
...X...
...X...
...X...
""",
    # the passer rating: a star
    "STAR": """
...X...
...X...
XXXXXXX
.XXXXX.
..XXX..
.XX.XX.
.X...X.
""",
    # a tackle: the helmet, facemask forward
    "HELMET": """
..XXXX...
.XXXXXX..
XXXXXXXX.
XXXXX.KKK
XXXX..K.K
.XXX..KKK
..X......
""",
    # a sack: the burst
    "BURST": """
X..X..X
.X.X.X.
..XXX..
XXXXXXX
..XXX..
.X.X.X.
X..X..X
""",
    # a pick: the ball, and the arrow going the other way
    "PICK": """
..X......
.XX...BB.
XXXXXBWBB
.XX.BWBB.
..X.BBB..
.........
.........
""",
}
ICON_LEG = {"B": "#A0522D", "W": "#FFFFFF", "S": DIM, "K": SOFT}

# ------------------------------------------------------------- text tools
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-:;/&+%#!?()$@"

def clean(s):
    """Panel-safe uppercase: every font lacks ' and ", and a missing glyph
    drops silently, so they go on purpose (D'ANGELO -> DANGELO)."""
    out = ""
    last_space = True
    for ch in str(s).upper().elems():
        if KEEP.find(ch) < 0:
            continue
        if ch == " ":
            if last_space:
                continue
            last_space = True
        else:
            last_space = False
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
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]

def split_name(first, last, full):
    """[first, last]. ESPN keeps suffixes in lastName ('Durr Jr.'), which is
    right for the hero; a missing split falls back to the display name."""
    f = clean(first)
    l = clean(last)
    if l == "":
        parts = [p for p in clean(full).split(" ") if p != ""]
        if len(parts) == 0:
            return ["", ""]
        end = len(parts)
        if end >= 3 and parts[end - 1] in SUFFIX:
            return [" ".join(parts[:end - 2]), " ".join(parts[end - 2:])]
        return [" ".join(parts[:end - 1]), parts[end - 1]]
    return [f, l]

HEXD = "0123456789abcdef"

def hex_rgb(h):
    t = str(h).lower().strip().lstrip("#")
    if len(t) != 6:
        return None
    v = []
    for i in [0, 2, 4]:
        a = HEXD.find(t[i])
        b = HEXD.find(t[i + 1])
        if a < 0 or b < 0:
            return None
        v.append(a * 16 + b)
    return v

def to_hex(v):
    out = "#"
    for x in v:
        x = max(0, min(255, x))
        out += HEXD[x // 16] + HEXD[x % 16]
    return out

def lift(v):
    """Scale a club colour up until an LED shows it on black: ESPN's navy
    (00539b) comes out #0089FF, maroon (881c1c) #FF3434. A hue that is
    still dark to the eye (pure navy) takes a quarter of white."""
    m = max(v)
    if m == 0:
        return None
    if m < 200:
        v = [x * 255 // m for x in v]
    if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 < 90:
        v = [x + (255 - x) // 4 for x in v]
    return v

def is_pale(v):
    return min(v) > 180

def is_grey(v):
    return max(v) - min(v) < 40

def school_colors(primary, alternate):
    """[text colour, stripe colours]. The school's PRIMARY colour, not the
    brighter one: Duke is blue, Rutgers scarlet, Mississippi State maroon,
    even though their alternates are white or grey. The alternate only
    takes over when the primary is white, grey or near-black (Notre Dame
    062340 -> gold). The stripe keeps both colours as the jersey wears
    them, white included; a black alternate repeats the main colour."""
    p = hex_rgb(primary)
    a = hex_rgb(alternate)
    main = None
    for v in [p, a]:
        if v != None and max(v) >= 90 and not is_pale(v) and not is_grey(v):
            main = v
            break
    if main == None:
        for v in [p, a]:
            if v != None and max(v) >= 24 and not is_pale(v) and not is_grey(v):
                main = v
                break
    if main == None:
        return [SOFT, [SOFT, DIM]]
    other = a if main == p else p
    top = to_hex(lift(main))
    if other == None or max(other) < 40:
        return [top, [top, top]]
    second = [255, 255, 255] if is_pale(other) else lift(other)
    return [top, [top, to_hex(second)]]

def num_text(s):
    """'1,173' -> '1173' so four digits fit the stat zone; ESPN writes
    half sacks as '6.5', which stays."""
    return str(s).replace(",", "").strip()

def tenths(s):
    """'1173' -> 11730, '6.5' -> 65; None for anything else. The race gaps
    are worked from the numbers on the panel."""
    t = num_text(s)
    parts = t.split(".")
    if len(parts) > 2 or t == "":
        return None
    for q in parts:
        for ch in q.elems():
            if ch < "0" or ch > "9":
                return None
    whole = int(parts[0]) if parts[0] != "" else 0
    frac = 0
    if len(parts) == 2 and parts[1] != "":
        frac = int(parts[1][0])
    return whole * 10 + frac

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

def parse(j):
    """ESPN category name -> up to 3 leaders in ESPN's order, ties sharing
    a rank (6, 6, 4 sacks -> 1, 1, 3). ESPN's order is the ranking: QB
    rating lists qualified passers first, so an unqualified 119 behind a
    qualified 118 stays third."""
    boards = {}
    cats = dig(j, ["leaders", "categories"], [])
    if type(cats) != "list":
        return boards
    for cat in cats:
        name = str(get(cat, "name", ""))
        rows = []
        leaders_ = get(cat, "leaders", [])
        if type(leaders_) != "list":
            continue
        for l in leaders_:
            if len(rows) == 3:
                break
            a = get(l, "athlete", {})
            t = get(l, "team", {})
            nm = split_name(get(a, "firstName", ""), get(a, "lastName", ""), get(a, "displayName", ""))
            if nm[1] == "":
                continue
            shown = num_text(get(l, "displayValue", ""))
            if shown == "":
                continue
            val = get(l, "value", 0)
            cols = school_colors(get(t, "color", ""), get(t, "alternateColor", ""))
            jersey = clean(get(a, "jersey", ""))
            rows.append({
                "first": nm[0],
                "last": nm[1],
                "pos": clean(dig(a, ["position", "abbreviation"], "")),
                "jersey": jersey if len(jersey) <= 2 else "",
                "abbr": str(get(t, "abbreviation", "")),
                "school": clean(get(t, "shortDisplayName", get(t, "abbreviation", ""))),
                "color": cols[0],
                "stripe": cols[1],
                "value": val if type(val) in ["int", "float"] else 0,
                "shown": shown,
            })
        for n in range(len(rows)):
            if n > 0 and rows[n]["value"] == rows[n - 1]["value"]:
                rows[n]["rank"] = rows[n - 1]["rank"]
            else:
                rows[n]["rank"] = n + 1
        if len(rows) > 0:
            boards[name] = rows
    return boards

def fetch(group, season):
    params = {"limit": "3", "group": group}
    if season != "":
        params["season"] = season
    r = http.get(LEADERS, params = params, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return {"ok": False, "head": "ESPN OFFLINE", "sub": "LEADERS RETURN IN 30 MIN"}
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "head": "ESPN FEED ERROR", "sub": "HTTP " + str(r["status_code"]) + " - RETRY SOON"}
    j = r["json"]
    return {"ok": True, "boards": parse(j),
            "year": num(dig(j, ["currentSeason", "year"], ""), 0),
            "stype": num(dig(j, ["currentSeason", "type", "type"], ""), 0),
            "week": num(dig(j, ["currentSeason", "type", "week", "number"], ""), 0)}

def num(s, fallback = -1):
    t = str(s).strip()
    if t == "" or t == "None":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return int(t)

def load_boards(group, cats):
    """This season's boards; when none of the chosen stats has a leader yet
    (the offseason, or before week 1 is played) last season's final boards
    stand in, labelled FINAL - one extra request, only then."""
    d = fetch(group, "")
    if not d["ok"]:
        return d
    if has_any_board(d["boards"], cats):
        if d["stype"] == 3:
            d["when"] = "POSTSEASON"
        elif d["week"] > 0 and d["stype"] == 2:
            d["when"] = "WEEK " + str(d["week"])
        else:
            d["when"] = str(d["year"]) if d["year"] > 0 else ""
        return d
    if d["year"] > 2000:
        prev = fetch(group, str(d["year"] - 1))
        if prev["ok"] and has_any_board(prev["boards"], cats):
            prev["when"] = str(d["year"] - 1) + " FINAL"
            return prev
    d["when"] = ""
    return d

def has_any_board(boards, cats):
    for k in cats:
        if k[0] in boards:
            return True
    return False

# ------------------------------------------------------------ drawing bits
def icon(c, name, color, x, y, scale = 1):
    leg = dict(ICON_LEG)
    leg["X"] = color
    c.sprite(ICONS[name], x, y, legend = leg, scale = scale)

def icon_w(name):
    return max([len(r) for r in ICONS[name].strip("\n").split("\n")])

def ink_on(bg):
    """Black or white type for a bar: black on anything an LED lights
    brightly, white on the deeper lifted colours (#0089FF, #FF3434)."""
    v = hex_rgb(bg)
    if v == None:
        return "black"
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 120 else "white"

def rank_block(c, rank, y, fill = None):
    """The starting block: a gold, silver or bronze slab, the rank struck
    on it in black."""
    col = fill if fill != None else METAL.get(rank, METAL[3])
    c.rect(EDGE_L, y, EDGE_L + RANK_W - 1, y + BAR_H - 1, fill = col)
    if rank > 0 and rank < 10:
        t = str(rank)
        c.text(t, EDGE_L + (RANK_W - c.text_width(t, "4x5") + 1) // 2, y + 1, font = "4x5", color = "black")

def positions(rows):
    """Left x of each logo. #1 hangs at the right edge; the chasers sit
    back by their deficit - #3 between 52 and 66 px back as it trails by
    0 to 14 %, #2 placed between them by its share of that gap - never
    closer than 26 px to the logo ahead, so no two pennants touch. The
    numbers on the bars carry the exact values."""
    n = len(rows)
    t = [tenths(r["shown"]) for r in rows]
    top = t[0] if t[0] != None and t[0] > 0 else 0
    def frac(v):
        if top == 0 or v == None or v >= top:
            return 0
        return (top - v) * 100 // top
    last = n - 1
    back = [0, 0, 0]
    if n >= 2:
        extra = min(BACK_MAX - (last * SEP), frac(t[last]))
        back[last] = last * SEP + extra
    if n == 3:
        span = (t[0] - t[2]) if (t[0] != None and t[2] != None) else 0
        want = back[2] * (t[0] - t[1]) // span if span > 0 and t[1] != None else 0
        back[1] = max(SEP, min(back[2] - SEP, want))
    return [P1 - back[i] for i in range(n)]

def name_forms(last):
    """The last name as printed, then without a suffix ('SINGLETON JR.'
    -> 'SINGLETON'), then a double-barrelled name's first barrel
    ('VANDENBERGHE-SMITH' -> 'VANDENBERGHE')."""
    out = [last]
    parts = last.split(" ")
    if len(parts) >= 2 and parts[len(parts) - 1] in SUFFIX:
        out.append(" ".join(parts[:len(parts) - 1]))
    cut = max(last.rfind("-"), last.find(" "))
    if cut > 2:
        out.append(last[:cut])
    return out

def bar(c, p, y, x_end):
    """The school's bar, x BAR_X..x_end: body in its main colour, a 2 px
    tip in its second colour (the jersey trim). Inside, the last name at
    the left and the number at the tip - both 4x5 in black or white - and
    the position after the name when there is room."""
    body = p["color"]
    trim = p["stripe"][1]
    c.rect(BAR_X, y, x_end, y + BAR_H - 1, fill = body)
    tipw = 2 if trim != body else 0
    if tipw > 0:
        c.rect(x_end - 1, y, x_end, y + BAR_H - 1, fill = trim)
    ink = ink_on(body)
    vw = c.text_width(p["shown"], "4x5")
    vr = x_end - tipw - 2
    c.text(p["shown"], vr - vw + 1, y + 1, font = "4x5", color = ink)
    room = vr - vw - 4 - (BAR_X + 2) + 1
    name = ""
    for t in name_forms(p["last"]):
        if c.text_width(t, "4x5") <= room:
            name = t
            break
    if name == "":
        name = clip(c, p["last"], "4x5", room)
    if name == "":
        return
    c.text(name, BAR_X + 2, y + 1, font = "4x5", color = ink)
    used = c.text_width(name, "4x5")
    if p["pos"] != "" and name == p["last"]:
        pw = c.text_width(p["pos"], "4x5")
        if used + 4 + pw <= room:
            c.text(p["pos"], BAR_X + 2 + used + 4, y + 1, font = "4x5", color = ink)

def pennant(c, p, x, y, ico, icol):
    """The school's 24 x 18 logo hanging from the bar tip. No logo on file
    (a new FBS member): its abbreviation boxed in its own colour, same
    footprint. No team at all: the stat's icon."""
    f = LOGO.get(p["abbr"], "")
    if f != "":
        c.image(f, x, y)
        return
    name = clean(p["abbr"] if p["abbr"] != "" else p["school"])
    if name == "":
        icon(c, ico, icol, x + (LOGO_W - icon_w(ico)) // 2, y + 5)
        return
    c.rect(x, y, x + LOGO_W - 1, y + LOGO_H - 1, outline = p["color"])
    t = clip(c, name, "4x5", LOGO_W - 4)
    c.text(t, x + (LOGO_W - c.text_width(t, "4x5")) // 2, y + 6, font = "4x5", color = p["color"])

def header(c, k, scope, when, right):
    """The corner under the bars (x 6..right): the board's name in the
    family colour and the week on one line, the scope under it. Under #1's
    logo: the family icon."""
    col = k[3]
    maxw = right - EDGE_L + 1
    lab = k[2]
    lw = c.text_width(lab, "4x5")
    c.text(lab, EDGE_L, HEAD_Y[0], font = "4x5", color = col)
    if when != "":
        shorts = [when]
        if when.startswith("WEEK "):
            shorts.append("WK " + when[5:])
        elif when == "POSTSEASON":
            shorts.append("BOWLS")
        elif when.endswith(" FINAL") and len(when) == 10:
            shorts.append(when[2:])
        for w in shorts:
            if lw + 5 + c.text_width(w, "4x5") <= maxw:
                c.text(w, EDGE_L + lw + 5, HEAD_Y[0], font = "4x5", color = INK if when.endswith("FINAL") else DIM)
                break
    c.text(clip(c, scope, "4x5", maxw), EDGE_L, HEAD_Y[1], font = "4x5", color = SOFT)
    iw = icon_w(k[4])
    icon(c, k[4], col, L1CX - iw // 2, 22)

def empty_track(c, fill, head, sub, hcol):
    """The track with nobody on it: three blocks in one flat colour, the
    message beside them, and a dotted lane along the bottom from a ball."""
    c.fill("black")
    for i in range(3):
        rank_block(c, i + 1, BAR_Y[i], fill)
    cx = (BAR_X + 2 + EDGE_R) // 2
    maxw = EDGE_R - BAR_X - 2
    hf = fit(c, head, ["6x8", "5x7", "4x5"], maxw)
    c.text(hf[1], cx, 2, font = hf[0], color = hcol, align = "center")
    sf = fit(c, sub, ["4x5"], maxw)
    c.text(sf[1], cx, 13, font = sf[0], color = DIM, align = "center")
    icon(c, "PASS", fill, EDGE_L, 23)
    for x in range(EDGE_L + icon_w("PASS") + 3, EDGE_R + 1, 3):
        c.pixel(x, 26, fill)

def fail_screen(c, head, sub):
    empty_track(c, OFFLINE, head, sub, "amber")

def quiet_screen(c, head, sub):
    """No leaders is an answer, not an error: green, and calm."""
    empty_track(c, GOOD, head, sub, GOOD)

# ------------------------------------------------------------- page: leaders
def leaders(c, ctx):
    want = str(ctx.inputs.get("stat", "ALL STATS")).strip().upper()
    if want == "TOUCHDOWNS":
        cats = [k for k in CATS if k[0].endswith("Touchdowns")]
    else:
        cats = [k for k in CATS if k[1] == want]
    if len(cats) == 0:
        cats = CATS
    conf = CONFS.get(str(ctx.inputs.get("conference", "ALL FBS")).strip().upper(), CONFS["ALL FBS"])

    d = load_boards(conf[0], cats)
    if not d["ok"]:
        fail_screen(c, d["head"], d["sub"])
        return

    # One frame per leaderboard, in the order of CATS.
    frames = []
    for k in cats:
        rows = d["boards"].get(k[0], [])
        if len(rows) > 0:
            frames.append([k, rows[:3]])
    if len(frames) == 0:
        head = "NO LEADERS YET" if len(cats) == len(CATS) else "NO " + want + " LEADERS YET"
        quiet_screen(c, head, "FIRST STATS ARRIVE AFTER KICKOFF")
        return
    f = frames[(ctx.now.unix // FRAME_SECONDS) % len(frames)]
    k = f[0]
    rows = f[1]

    c.fill("black")
    xs = positions(rows)
    for i in range(len(rows)):
        p = rows[i]
        rank_block(c, p["rank"], BAR_Y[i])
        bar(c, p, BAR_Y[i], xs[i] - 3)
        pennant(c, p, xs[i], BAR_Y[i], k[4], k[3])
    header(c, k, conf[1], d["when"], xs[len(xs) - 1] - 3)
