# College Football Stat Leaders
#
# The FBS leaderboards the Heisman race is argued over - passing yards,
# touchdowns and QB rating, rushing yards and touchdowns, receiving yards,
# catches and touchdowns, tackles, sacks and interceptions - one player per
# frame, from ESPN's college leaders feed
# (site.web.api.espn.com/apis/site/v3/.../leaders, limit=3: every
# category's top 3 in one ~510 KB call). A conference pick narrows the same
# call with ESPN's group id.
#
# DESIGN. The medal ceremony. A gold, silver or bronze medal hangs from the
# top edge of the panel on a ribbon in the stat family's colour, the rank
# struck on the disc, and under it the player's roster line - jersey number
# and position - like the back of a trading card. Then the school's logo at
# full 40 x 24, the thing a fan knows from across the room. The last name is
# the hero, underlined by a two-row sleeve stripe in the school's own two
# colours (the one memorable thing: every frame wears a different college
# jersey); first name and school sit under the stripe. On the right, set
# apart by black space, the number that put him there in 10x16 over a filled
# tab naming the stat (PASS YDS, REC TDS, SACKS...) in the family colour, so
# no number is ever unlabelled. The top row carries the family icon, the
# scope and week, and the race: "+53 ON #2" in gold for the leader, "-53 TO
# #1" for the chasers, "TIED FOR #1" when they share it.
#
# Palette: PASSING #4A9CFF, RUSHING #3CE0A0 (turf), RECEIVING #FF9A3C,
# DEFENSE #FF5AB4 - validated for colour-blind separation on black, and
# every family also carries its word and its icon. Gold #FFC72C belongs to
# the medal and the leader's margin only.
#
# Frames: refresh is 120 s and the frame steps every two minutes, through
# each chosen leaderboard's #1, #2 and #3. The feed is cached for 1800 s:
# college stats move on Saturdays, not by the minute. The Stat input picks a
# family (5 choices) rather than a single board, so 5 x 12 conference
# choices = 60 combinations stays under the 100 allowed at a 2-minute
# refresh.

LEADERS = "https://site.web.api.espn.com/apis/site/v3/sports/football/college-football/leaders"
HEADERS = {"User-Agent": "glance-college-football-stat-leaders (glance-led.dev)"}
TTL = 1800
FRAME_SECONDS = 120

# ------------------------------------------------------------------ layout
# 192 wide. Medal column x 7..18 (12 x 19 medal from y 0, roster lines under
# it, text up to 14 px wide centred on x 13 -> x 6..19), logo x 21..60
# (40 x 24 at y 4), text x 65..135, 5 px of black, stat x 141..185 (centre
# 163): 6 px of edge padding each side, at least 2 px of black between
# zones.
MEDAL_X = 7
MEDAL_CX = 13
LOGO_X = 21
LOGO_Y = 4
TX = 65
TR = 135
TW = TR - TX + 1
SX = 141
SR = 185
SW = SR - SX + 1
SCX = 163
EDGE_R = 185

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

# ESPN abbreviation -> logo. 40 x 24, drawn at the size it was authored.
LOGO = {
    "AFA": "AFA.png", "AKR": "AKR.png", "ALA": "ALA.png", "APP": "APP.png", "ARIZ": "ARIZ.png",
    "ARK": "ARK.png", "ARMY": "ARMY.png", "ARST": "ARST.png", "ASU": "ASU.png",
    "AUB": "AUB.png", "BALL": "BALL.png", "BAY": "BAY.png", "BC": "BC.png", "BGSU": "BGSU.png",
    "BOIS": "BOIS.png", "BUFF": "BUFF.png", "BYU": "BYU.png", "CAL": "CAL.png",
    "CCU": "CCU.png", "CIN": "CIN.png", "CLEM": "CLEM.png", "CLT": "CLT.png", "CMU": "CMU.png",
    "COLO": "COLO.png", "CONN": "CONN.png", "CSU": "CSU.png", "DEL": "DEL.png",
    "DUKE": "DUKE.png", "ECU": "ECU.png", "EMU": "EMU.png", "FAU": "FAU.png", "FIU": "FIU.png",
    "FLA": "FLA.png", "FRES": "FRES.png", "FSU": "FSU.png", "GASO": "GASO.png",
    "GAST": "GAST.png", "GT": "GT.png", "HAW": "HAW.png", "HOU": "HOU.png", "ILL": "ILL.png",
    "IOWA": "IOWA.png", "ISU": "ISU.png", "IU": "IU.png", "JMU": "JMU.png", "JXST": "JXST.png",
    "KENN": "KENN.png", "KENT": "KENT.png", "KSU": "KSU.png", "KU": "KU.png", "LIB": "LIB.png",
    "LOU": "LOU.png", "LSU": "LSU.png", "LT": "LT.png", "M-OH": "M-OH.png", "MASS": "MASS.png",
    "MD": "MD.png", "MEM": "MEM.png", "MIA": "MIA.png", "MICH": "MICH.png", "MINN": "MINN.png",
    "MISS": "MISS.png", "MIZ": "MIZ.png", "MOST": "MOST.png", "MRSH": "MRSH.png",
    "MSST": "MSST.png", "MSU": "MSU.png", "MTSU": "MTSU.png", "NAVY": "NAVY.png",
    "NCSU": "NCSU.png", "ND": "ND.png", "NDSU": "NDSU.png", "NEB": "NEB.png", "NEV": "NEV.png",
    "NIU": "NIU.png", "NMSU": "NMSU.png", "NU": "NU.png", "ODU": "ODU.png", "OHIO": "OHIO.png",
    "OKST": "OKST.png", "ORE": "ORE.png", "ORST": "ORST.png", "OSU": "OSU.png", "OU": "OU.png",
    "PITT": "PITT.png", "PSU": "PSU.png", "PUR": "PUR.png", "RICE": "RICE.png",
    "RUTG": "RUTG.png", "SAC": "SAC.png", "SC": "SC.png", "SDSU": "SDSU.png",
    "SHSU": "SHSU.png", "SJSU": "SJSU.png", "SMU": "SMU.png", "STAN": "STAN.png",
    "SYR": "SYR.png", "TA&M": "TAMU.png", "TCU": "TCU.png", "TEM": "TEM.png",
    "TENN": "TENN.png", "TEX": "TEX.png", "TLSA": "TLSA.png", "TOL": "TOL.png",
    "TROY": "TROY.png", "TTU": "TTU.png", "TULN": "TULN.png", "TXST": "TXST.png",
    "UAB": "UAB.png", "UCF": "UCF.png", "UCLA": "UCLA.png", "UGA": "UGA.png", "UK": "UK.png",
    "UL": "UL.png", "ULM": "ULM.png", "UNC": "UNC.png", "UNLV": "UNLV.png", "UNM": "UNM.png",
    "UNT": "UNT.png", "USA": "USA.png", "USC": "USC.png", "USF": "USF.png", "USM": "USM.png",
    "USU": "USU.png", "UTAH": "UTAH.png", "UTEP": "UTEP.png", "UTSA": "UTSA.png",
    "UVA": "UVA.png", "VAN": "VAN.png", "VT": "VT.png", "WAKE": "WAKE.png", "WASH": "WASH.png",
    "WIS": "WIS.png", "WKU": "WKU.png", "WMU": "WMU.png", "WSU": "WSU.png", "WVU": "WVU.png",
    "WYO": "WYO.png",
}

# --------------------------------------------------------------- pixel art
# The medal, hung from the top edge: a two-tone ribbon (R the stat family's
# colour, r a shade darker) over a 12 x 12 disc - L highlight, M metal,
# D shadow. The rank is struck on the disc in 5x7 black at (4, 10).
MEDAL = """
.RRR....rrr.
.RRR....rrr.
..RRR..rrr..
..RRR..rrr..
...RRRrrr...
....RRrr....
.....Rr.....
....LLLL....
..LLMMMMMM..
.LMMMMMMMMD.
.LMMMMMMMMD.
LMMMMMMMMMMD
LMMMMMMMMMMD
LMMMMMMMMMMD
LMMMMMMMMMMD
.MMMMMMMMMD.
.MMMMMMMMDD.
..DMMMMMDD..
....DDDD....
"""
METAL = {
    1: {"L": "#FFF0A0", "M": GOLD, "D": "#B8860B"},
    2: {"L": "#FFFFFF", "M": "#C4CCD8", "D": "#7A8494"},
    3: {"L": "#F7C08A", "M": "#D9883F", "D": "#8A5424"},
}

# Top-row icons, 7 rows tall. X takes the stat family's colour.
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

# Lit rows per face, top-aligned.
INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}

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
    """'1173' -> 11730, '6.5' -> 65; None for anything else. Margins are
    worked from the numbers on the panel, so QB rating 158.3 vs 154.2 reads
    '+4' (158 - 154), never a digit the viewer cannot see."""
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

def fmt_tenths(n):
    s = str(n // 10)
    if n % 10 != 0:
        s += "." + str(n % 10)
    return s

def margin(rows, i):
    """The race, from the frame's point of view: [text, colour]."""
    me = rows[i]
    t = tenths(me["shown"])
    if t == None or len(rows) < 2:
        return ["", DIM]
    if me["rank"] == 1:
        if len([r for r in rows if r["rank"] == 1]) > 1:
            return ["TIED FOR #1", GOLD]
        nxt = rows[1] if rows[0] == me else rows[0]
        u = tenths(nxt["shown"])
        if u == None or u >= t:
            return ["", DIM]
        return ["+" + fmt_tenths(t - u) + " ON #" + str(nxt["rank"]), GOLD]
    u = tenths(rows[0]["shown"])
    if u == None or u <= t:
        return ["", DIM]
    return ["-" + fmt_tenths(u - t) + " TO #1", SOFT]

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

def medal(c, rank, ribbon, x, y):
    leg = dict(METAL.get(rank, METAL[3]))
    leg["R"] = ribbon
    leg["r"] = color.dim(ribbon, 55)
    c.sprite(MEDAL, x, y, legend = leg)
    c.text(str(rank) if rank < 10 else "", x + 4, y + 10, font = "5x7", color = "black")

def logo(c, abbr, school, color, ico, icol):
    """The school's 40 x 24 logo. A school with no logo on file (a new FBS
    member) gets its abbreviation, boxed in its own colour, in the same
    footprint - never a blank."""
    f = LOGO.get(abbr, "")
    if f != "":
        c.image(f, LOGO_X, LOGO_Y)
        return
    name = clean(abbr if abbr != "" else school)
    if name == "":
        # No team on the row at all: the stat's own icon, 3x, fills the spot.
        icon(c, ico, icol, LOGO_X + 20 - icon_w(ico) * 3 // 2, LOGO_Y + 2, 3)
        return
    c.rect(LOGO_X, LOGO_Y, LOGO_X + 39, LOGO_Y + 23, outline = color)
    t = fit(c, name, ["10x16", "6x8", "5x7", "4x5"], 36)
    c.text(t[1], LOGO_X + 20, LOGO_Y + (24 - INKH[t[0]]) // 2, font = t[0], color = color, align = "center")

def centred(c, text, cx, y, col):
    """4x5 text centred on cx, clipped to the medal column (x 6..19)."""
    t = clip(c, text, "4x5", 14)
    c.text(t, cx - c.text_width(t, "4x5") // 2, y, font = "4x5", color = col)

def fail_screen(c, head, sub):
    c.fill("black")
    c.rect(6, 0, 7, 31, fill = OFFLINE)
    icon(c, "PASS", DIM, 14, 9, 2)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 145)
    c.text(hf[1], 111, 9, font = hf[0], color = "amber", align = "center")
    sf = fit(c, sub, ["4x5"], 145)
    c.text(sf[1], 111, 21, font = sf[0], color = DIM, align = "center")

def quiet_screen(c, head, sub):
    """No leaders is an answer, not an error: green, and calm."""
    c.fill("black")
    c.rect(6, 0, 7, 31, fill = GOOD)
    medal(c, 1, GOOD, 14, 6)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 150)
    c.text(hf[1], 108, 9, font = hf[0], color = GOOD, align = "center")
    sf = fit(c, sub, ["4x5"], 150)
    c.text(sf[1], 108, 21, font = sf[0], color = DIM, align = "center")

# ------------------------------------------------------------- page: leaders
def leaders(c, ctx):
    want = str(ctx.inputs.get("stat", "ALL STATS")).strip().upper()
    cats = [k for k in CATS if k[1] == want]
    if len(cats) == 0:
        cats = CATS
    conf = CONFS.get(str(ctx.inputs.get("conference", "ALL FBS")).strip().upper(), CONFS["ALL FBS"])

    d = load_boards(conf[0], cats)
    if not d["ok"]:
        fail_screen(c, d["head"], d["sub"])
        return

    # One frame per leader, board by board, in the order of CATS.
    frames = []
    for k in cats:
        rows = d["boards"].get(k[0], [])
        for i in range(len(rows)):
            frames.append([k, rows, i])
    if len(frames) == 0:
        head = "NO LEADERS YET" if len(cats) == len(CATS) else "NO " + cats[0][1] + " LEADERS YET"
        quiet_screen(c, head, "FIRST STATS ARRIVE AFTER KICKOFF")
        return
    f = frames[(ctx.now.unix // FRAME_SECONDS) % len(frames)]
    k = f[0]
    p = f[1][f[2]]
    col = k[3]

    c.fill("black")

    # Medal column: the medal hangs from the top edge; the roster line -
    # jersey number, then position - under it (y 20 and y 26, 1 px apart).
    medal(c, p["rank"], col, MEDAL_X, 0)
    if p["jersey"] != "":
        # picopixel: '#34' is 13 px; in 4x5 it is 15 and would overrun
        # the 14 px column into the logo.
        jn = "#" + p["jersey"]
        c.text(jn, MEDAL_CX - c.text_width(jn, "picopixel") // 2, 20, font = "picopixel", color = SOFT)
    if p["pos"] != "":
        centred(c, p["pos"], MEDAL_CX, 26, DIM)

    logo(c, p["abbr"], p["school"], p["color"], k[4], col)

    # Top row y 0..6, x 65..185: the family icon, the scope and week, and
    # the race right-aligned. When it runs short the week goes first -
    # unless it says FINAL (last season's numbers must always say so), then
    # the race goes instead.
    iw = icon_w(k[4])
    icon(c, k[4], col, TX, 0)
    mx = TX + iw + 4
    race = margin(f[1], f[2])
    metas = [conf[1]]
    if d["when"] != "":
        metas.append(d["when"])
    tries = [[metas, race[0]]]
    if len(metas) > 1:
        if metas[1].endswith("FINAL"):
            tries.append([metas, ""])
        else:
            tries.append([metas[:1], race[0]])
    tries.append([metas[:1], ""])
    for t in tries:
        line = "  ".join(t[0])
        rw = c.text_width(t[1], "4x5") if t[1] != "" else 0
        need = c.text_width(line, "4x5") + (rw + 5 if rw > 0 else 0)
        if mx + need - 1 <= EDGE_R or t == tries[len(tries) - 1]:
            c.text(clip(c, line, "4x5", EDGE_R - mx + 1), mx, 1, font = "4x5", color = DIM)
            if rw > 0:
                c.text(t[1], EDGE_R, 1, font = "4x5", color = race[1], align = "right")
            break

    # Hero: the last name, biggest face that fits x 65..135, centred on the
    # band y 9..20. 'UMANMIELEN' is 108 px at 10x16 and 87 px at 9x12, so
    # the ladder runs down to 6x8 before it clips.
    # A double-barrelled name too long for even 5x7 keeps its first barrel
    # whole ('VANDENBERGHE-SMITH' is 107 px at 5x7 -> 'VANDENBERGHE')
    # rather than losing letters off the end.
    last = p["last"]
    ladder = ["9x12", "8x10", "6x8", "5x7"]
    if c.text_width(last, "5x7") > TW:
        cut = max(last.rfind("-"), last.find(" "))
        if cut > 2 and c.text_width(last[:cut], "5x7") <= TW:
            last = last[:cut]
    nf = fit(c, last, ladder, TW)
    c.text(nf[1], TX, 9 + (12 - INKH[nf[0]]) // 2, font = nf[0], color = INK)

    # The sleeve stripe: two rows in the school's two colours, y 22..23,
    # as wide as the name (never shorter than 24 px), 1 px clear of the
    # name above and the line below.
    sw = max(24, c.text_width(nf[1], nf[0]))
    c.line(TX, 22, TX + sw - 1, 22, p["stripe"][0])
    c.line(TX, 23, TX + sw - 1, 23, p["stripe"][1])

    # Under it: first name and school (in its colour). The first name goes
    # first when room runs short, then the school shortens to ESPN's
    # abbreviation ('MISSISSIPPI ST' -> 'MSST').
    line_y = 25
    school = p["school"] if p["school"] != "" else clean(p["abbr"])
    for parts in [[[p["first"], SOFT], [school, p["color"]]], [[school, p["color"]]], [[clean(p["abbr"]), p["color"]]]]:
        keep = [q for q in parts if q[0] != ""]
        w = 5 * (len(keep) - 1)
        for q in keep:
            w += c.text_width(q[0], "4x5")
        if w <= TW:
            x = TX
            for q in keep:
                c.text(q[0], x, line_y, font = "4x5", color = q[1])
                x += c.text_width(q[0], "4x5") + 5
            break
        if parts[0][0] == clean(p["abbr"]):
            c.text(clip(c, parts[0][0], "4x5", TW), TX, line_y, font = "4x5", color = p["color"])

    # The number, set apart by 5 px of black: 10x16 for up to four digits
    # ('1173' is 41 px) at y 8..22, over a tab in the family colour naming
    # the stat (y 24..30; 'PASS YDS' is 43 px wide).
    sf = fit(c, p["shown"], ["10x16", "9x12", "6x8"], SW)
    c.text(sf[1], SCX, 8 + (15 - INKH[sf[0]]) // 2, font = sf[0], color = INK, align = "center")
    tw = c.text_width(k[2], "4x5") + 4
    c.badge(k[2], SCX - tw // 2, 24, color = "black", bg = col, font = "4x5")
