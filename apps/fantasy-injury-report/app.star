# Fantasy Injury Report
#
# The week's injury report, sorted the way a fantasy manager needs it: the
# hurt players who matter most first.
#
#   gametime  The decisions still to make: QUESTIONABLE and DOUBTFUL players
#             from Sleeper's weekly projections (three requests: WR, RB,
#             QB with TE), ranked by this week's projected points. A player whose game
#             has already been played drops off, so Sunday night shows only
#             the Monday night calls left.
#   out       The holes in lineups: players ruled OUT this week first, then
#             IR / PUP moves from the last 14 days, from Sleeper's season
#             stats, ranked by points per game - what a manager loses by
#             starting without him. (Sleeper projects an OUT player at
#             nothing, so projections cannot rank them.)
#
# Both pages list players worth at least 5 points (projected, or per game),
# at most 8 of them.
#
# DESIGN. An X-ray film on a lightbox. The right edge of the strip is a
# dark-blue viewing box with a pixel skeleton in it - skull, collarbones,
# ribs round the spine, pelvis, femurs, knees, shins, feet - and the bone
# that is hurt glows in the status colour with a dim halo round it: red for
# OUT and IR, orange for DOUBTFUL, amber for QUESTIONABLE. You read WHERE
# he is hurt before you read a word. On the left, the club's logo with the
# matchup ("VS CHI") under it on the gametime page, or the injury itself
# ("SURGERY") on the out page, closed off by a two-tone bar in the club's
# colours. Between them, on black: the chip row (status, position, and a
# white game-day pill - MNF, TNF, SAT - when the game is not on a Sunday,
# the classic lineup trap), the player's name as the hero, and a footer
# with the body part (in the status colour) on the left and the number
# that makes this news matter ("PROJ 14.3", or "PPG 11.9" for a player who
# is out) on the right. An undisclosed injury shows a "?" on the film and
# how fresh the news is ("UPD 3H AGO").
#
# Frames: one player every two minutes with an n/N counter, which is why
# refresh is 120 (the floor for an app that fetches live data) while the
# projections are cached for 30 minutes and the season stats
# and NFL state for an hour.

SLEEPER_STATE = "https://api.sleeper.app/v1/state/nfl"
SLEEPER_PROJ = "https://api.sleeper.com/projections/nfl/"
SLEEPER_STATS = "https://api.sleeper.com/stats/nfl/"
HEADERS = {"User-Agent": "glance-fantasy-injury-report (glance-led.dev)"}

STATE_TTL = 3600
PROJ_TTL = 1800
STATS_TTL = 3600
MAX_PLAYERS = 8
MIN_VALUE = 5.0          # projected points, or points per game
IR_FRESH_DAYS = 14       # IR / PUP moves older than this are old news

# ------------------------------------------------------------------ layout
# 192 wide. Logo x 6..45 (40 x 24 at y 0), matchup under it at y 26, team
# bar x 47..48, text x 52..151, lightbox x 156..185 with the 17 x 29
# skeleton at x 163. 6 px of edge padding each side.
LOGO_X = 6
BAR_X = 47
TX = 52
TR = 151
TW = TR - TX + 1
BOX_X0 = 156
BOX_X1 = 185
BODY_X = 163
BODY_Y = 2

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
C_OUT = "#FF2D2D"
C_DOUBT = "#FF7A1F"
C_QUES = "#FFBF00"
XRAY_BG = "#0A1A33"
XRAY_EDGE = "#1E3A66"
BONE = "#A8C8F0"
DAY_PILL = "#F4F7FF"

POS_COLOR = {"QB": "#FF6F9C", "RB": "#2EE6C8", "WR": "#5CB8FF", "TE": "#FFB45C"}

# Sleeper designation -> [pill word, short word, colour, group].
STATUS = {
    "OUT": ["OUT", "OUT", C_OUT, "OUT"],
    "IR": ["INJURED RESERVE", "IR", C_OUT, "OUT"],
    "PUP": ["PUP LIST", "PUP", C_OUT, "OUT"],
    "DOUBTFUL": ["DOUBTFUL", "DOUBT", C_DOUBT, "GTD"],
    "QUESTIONABLE": ["QUESTIONABLE", "QUES", C_QUES, "GTD"],
}

# A middle-length status word, tried before the short one.
MID_WORD = {"INJURED RESERVE": "INJ RESERVE"}

# The halo round a lit bone: the status colour at about 55 %.
HALO = {C_OUT: "#8C1818", C_DOUBT: "#8C440F", C_QUES: "#8C6A00", GOOD: "#1A8240"}

# Logos ship as 40 x 24 PNGs named by ESPN abbreviation. Literal file names,
# because the publish lint cannot follow a built-up path.
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png",
    "SEA": "SEA.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
    "NFL": "NFL.png",
}

# Club [accent, jersey] for the bar, navy and black lifted so they read on
# an LED.
CLUB = {
    "ARI": ["#E0304F", "#E0304F"], "ATL": ["#E8243C", "#A5ACAF"], "BAL": ["#D0A52E", "#7B5CE8"],
    "BUF": ["#E8203A", "#2A6BFF"], "CAR": ["#19A6F0", "#B8BEC4"], "CHI": ["#FF5A1F", "#3F63C0"],
    "CIN": ["#FF6A1F", "#F0F2F5"], "CLE": ["#FF4E10", "#9A6433"], "DAL": ["#B0B7BC", "#3D7BFF"],
    "DEN": ["#FF5A14", "#3A6AB0"], "DET": ["#1C9BE8", "#B0B7BC"], "GB": ["#FFB612", "#2E8B57"],
    "HOU": ["#E8233C", "#3A5A8C"], "IND": ["#3D86E8", "#F0F2F5"], "JAX": ["#D7A22A", "#00A5B8"],
    "KC": ["#FFB612", "#FF2447"], "LV": ["#C4CACD", "#8A9196"], "LAC": ["#FFC20E", "#2AA8F0"],
    "LAR": ["#FFD100", "#2F6BFF"], "MIA": ["#FC6A12", "#00C2CC"], "MIN": ["#FFC62F", "#8F5BE8"],
    "NE": ["#E8203F", "#3A5A9C"], "NO": ["#D3BC8D", "#8A8580"], "NYG": ["#E8203F", "#2A5FE0"],
    "NYJ": ["#F0F2F5", "#1FA36E"], "PHI": ["#B0B7BC", "#0FA0A8"], "PIT": ["#FFB612", "#8A8580"],
    "SF": ["#D4B46A", "#E8201F"], "SEA": ["#69BE28", "#3A5A9C"], "TB": ["#F0263A", "#8A8580"],
    "TEN": ["#4B92DB", "#F0F2F5"], "WSH": ["#FFB612", "#B8323A"],
}

# Sleeper abbreviations that differ from the logo set.
ALIAS = {"WAS": "WSH", "JAC": "JAX", "LA": "LAR", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# ----------------------------------------------------------- the skeleton
# 17 x 29, front view, drawn as bones. Each region is its own letter so any
# one of them can light up: H skull, N neck, S collarbones and shoulders,
# C ribs, B spine and lower back, A upper arm, E elbow, F forearm, W wrist,
# P hand, G pelvis and hip, T femur (thigh), K knee, L shin, X ankle,
# O foot. The holes (eye sockets, the gaps between ribs) show the film.
BODY = """
......HHHHH......
.....HHHHHHH.....
.....H..H..H.....
.....HHHHHHH.....
......HH.HH......
.......HHH.......
........N........
...SSSSSNSSSSS...
..SS.CCCBCCC.SS..
..A.C...B...C.A..
..A..CCCBCCC..A..
..A.C...B...C.A..
..A..CCCBCCC..A..
..E....BBB....E..
.F.....BBB.....F.
.F....GGGGG....F.
W....GG.B.GG....W
P....GGGGGGG....P
.....TT...TT.....
.....TT...TT.....
.....TT...TT.....
.....TT...TT.....
....KKKK.KKKK....
.....LL...LL.....
.....LL...LL.....
.....LL...LL.....
.....XX...XX.....
....OOO...OOO....
...OOO.....OOO...
"""
REGIONS = "HNSCBAEFWPGTKLXO"
ROWS = [r for r in BODY.strip().split("\n")]

# Body-part words -> regions, checked in order: the first match lights.
# Longer words that contain a shorter one come first ("forearm" before
# "arm", "lower leg" before "leg"). An unknown or undisclosed part lights
# nothing and the film shows a question mark instead.
PARTS = [
    ["concussion", "H"], ["head", "H"], ["face", "H"], ["eye", "H"], ["jaw", "H"],
    ["neck", "N"], ["stinger", "N"],
    ["shoulder", "S"], ["collarbone", "S"], ["clavicle", "S"], ["ac joint", "S"],
    ["upper body", "SCBA"], ["lower body", "GTKLXO"],
    ["pectoral", "C"], ["chest", "C"], ["rib", "C"], ["sternum", "C"],
    ["oblique", "B"], ["abdom", "B"], ["core", "B"], ["back", "B"], ["spine", "B"],
    ["kidney", "B"], ["illness", "CB"], ["covid", "CB"],
    ["forearm", "F"], ["elbow", "E"], ["wrist", "W"],
    ["bicep", "A"], ["tricep", "A"], ["arm", "A"],
    ["thumb", "P"], ["finger", "P"], ["hand", "P"],
    ["hamstring", "T"], ["quad", "T"], ["thigh", "T"],
    ["groin", "G"], ["hip", "G"], ["glute", "G"], ["pelvis", "G"], ["adductor", "G"],
    ["knee", "K"], ["acl", "K"], ["mcl", "K"], ["meniscus", "K"], ["patella", "K"],
    ["lower leg", "L"], ["calf", "L"], ["shin", "L"], ["fibula", "L"], ["tibia", "L"], ["leg", "L"],
    ["achilles", "X"], ["ankle", "X"],
    ["foot", "O"], ["toe", "O"], ["heel", "O"], ["plantar", "O"], ["lisfranc", "O"],
]

def lit_regions(part):
    t = str(part).lower()
    for p in PARTS:
        if t.find(p[0]) >= 0:
            return p[1]
    return ""

def glow_sprite(lit):
    """The skeleton with every empty pixel next to a lit bone (8 ways) turned
    into 'h', the halo."""
    if lit == "":
        return BODY
    h = len(ROWS)
    out = []
    for y in range(h):
        row = ROWS[y]
        line = ""
        for x in range(len(row)):
            ch = row[x]
            if ch == ".":
                near = False
                for dy in [-1, 0, 1]:
                    for dx in [-1, 0, 1]:
                        yy = y + dy
                        xx = x + dx
                        if not near and yy >= 0 and yy < h and xx >= 0 and xx < len(ROWS[yy]):
                            n = ROWS[yy][xx]
                            if n != "." and lit.find(n) >= 0:
                                near = True
                if near:
                    ch = "h"
            line += ch
        out.append(line)
    return "\n".join(out)

def lightbox(c, part, col, mode = "injury"):
    """The X-ray box, x 156..185: a dark-blue film, a brighter frame, the
    skeleton in bone blue with the hurt bone in the status colour and a
    halo round it. Mode "healthy" lights every bone (the all-clear),
    "plain" draws the whole skeleton in `col` (grey when offline)."""
    c.rect(BOX_X0, 0, BOX_X1, 31, fill = XRAY_BG, outline = XRAY_EDGE)
    lit = REGIONS if mode == "healthy" else ("" if mode == "plain" else lit_regions(part))
    leg = {"h": HALO.get(col, XRAY_EDGE)}
    for r in REGIONS.elems():
        leg[r] = col if lit.find(r) >= 0 or mode == "plain" else BONE
    c.sprite(glow_sprite("" if mode == "healthy" else lit), BODY_X, BODY_Y, legend = leg)
    if lit == "" and mode == "injury":
        # Undisclosed: a stroked "?" over the ribs, since there is nothing to point at.
        c.text_stroke("?", BODY_X + 6, BODY_Y + 9, font = "5x7", color = col, stroke = "black")

# ------------------------------------------------------------- text tools
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-:;/&+%#!?()$@"

def clean(s):
    """Panel-safe uppercase: the fonts lack ' and ", and a missing glyph is
    dropped silently, so they go on purpose (JA'MARR -> JAMARR)."""
    out = ""
    last_space = True
    for ch in str(s).upper().elems():
        if ch == "\n" or ch == "\t" or ch == "_":
            ch = " "
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
            return t[:k].rstrip(" -")
    return ""

def fit(c, text, fonts, maxw):
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

# Lit rows per face, top-aligned.
INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}

SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]
PARTICLE = ["ST.", "ST", "DE", "DI", "DA", "DU", "LA", "LE", "VAN", "VON", "DEL", "DOS"]

def name_forms(full):
    """[full, initial + last, last, last without suffix]. 'Last' keeps a
    particle (ST. BROWN) and a suffix (HARRISON JR.) while there is room."""
    parts = [p for p in full.split(" ") if p != ""]
    if len(parts) < 2:
        return [full, full, full, full]
    end = len(parts)
    suffix = ""
    if end >= 3 and parts[end - 1] in SUFFIX:
        suffix = parts[end - 1]
        end -= 1
    start = end - 1
    if start >= 2 and parts[start - 1] in PARTICLE:
        start -= 1
    bare = " ".join(parts[start:end])
    last = bare + (" " + suffix if suffix != "" else "")
    return [full, parts[0][:1] + ". " + last, last, bare]

def dot_w(font):
    return 2 if font in ["10x16", "9x12", "8x10"] else 1

def tight_w(c, text, font):
    """Width of `text` with every '.' set tight. The big faces give '.' a
    full cell and a space another, so 'D. SMITH' drew in 10x16 with a
    13 px hole after the D; here the dot is 1-2 px with 1 px before it and
    a dot-and-3 px gap after when a space followed."""
    pieces = str(text).split(".")
    dw = dot_w(font)
    w = 0
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            w += 1 + dw + (dw + 3 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        w += c.text_width(t, font) if t != "" else 0
    return w - (1 if str(text).endswith(".") else 0)

def tight_text(c, text, x, y, font, col):
    pieces = str(text).split(".")
    dw = dot_w(font)
    base = y + INKH[font] - 1
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            c.rect(x + 1, base - dw + 1, x + dw, base, fill = col)
            x += 1 + dw + (dw + 3 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        if t != "":
            c.text(t, x, y, font = font, color = col)
            x += c.text_width(t, font)

def pick_name(c, forms, maxw):
    """The biggest face first: the last name alone in 10x16 reads further
    than the full name in 8x10. Returns [form index, font]."""
    order = [[0, "10x16"], [1, "10x16"], [2, "10x16"], [0, "9x12"], [1, "9x12"], [2, "9x12"],
             [3, "10x16"], [3, "9x12"], [1, "8x10"], [2, "8x10"], [3, "8x10"],
             [2, "6x8"], [3, "6x8"], [3, "5x7"]]
    for o in order:
        if tight_w(c, forms[o[0]], o[1]) <= maxw:
            return o
    return [-1, "5x7"]

HEXD = "0123456789abcdef"

def ink_for(fill):
    """Black type on a bright pill, white on a dark one (brightness 150)."""
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def pill(c, word, fill, x, y):
    c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")

def pill_w(c, word):
    return c.text_width(word, "4x5") + 4

def one_decimal(v):
    n = int(v * 10 + 0.5) if v >= 0 else 0
    return str(n // 10) + "." + str(n % 10)

# ------------------------------------------------------------------ dates
def civil_days(y, m, d):
    """Days since 1970-01-01 for a Gregorian date (Hinnant's algorithm)."""
    y = y - (1 if m <= 2 else 0)
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def date_days(s):
    """'2026-09-28' -> day number, or -1."""
    p = str(s).split("-")
    if len(p) != 3 or not (p[0].isdigit() and p[1].isdigit() and p[2].isdigit()):
        return -1
    return civil_days(int(p[0]), int(p[1]), int(p[2]))

# Kickoff weekday -> the pill word. Sunday is the default and gets none.
DAY_WORD = ["", "MNF", "TUE", "WED", "TNF", "FRI", "SAT"]

def day_tag(days):
    if days < 0:
        return ""
    return DAY_WORD[(days + 4) % 7]   # 1970-01-01 was a Thursday; 0 = Sunday

def ago(now_unix, ms):
    """News age from Sleeper's ms timestamp: '3H' / '2D', or ''."""
    if type(ms) not in ["int", "float"] or ms <= 0:
        return ""
    s = now_unix - int(ms) // 1000
    if s < 0:
        s = 0
    if s < 3600:
        return "1H"
    if s < 48 * 3600:
        return str(s // 3600) + "H"
    return str(s // 86400) + "D"

ROMAN = [[10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]]

def roman(n):
    out = "L" if n >= 50 else ""
    n = n - 50 if n >= 50 else n
    for i in range(10):
        for r in ROMAN:
            if n >= r[0]:
                out += r[1]
                n -= r[0]
                break
    return out

def week_label(d):
    """'WEEK 3', or the playoff round (Sleeper numbers them 1-4 or 19-22)."""
    w = d["week"]
    if d.get("stype", "") != "post":
        return "WEEK " + str(w)
    r = w - 18 if w >= 19 else w
    if r <= 1:
        return "WILDCARD"
    if r == 2:
        return "DIVISION"
    if r == 3:
        return "CONF RD"
    yr = int(d["season"]) if str(d.get("season", "")).isdigit() else 0
    return "SB " + roman(yr - 1965) if yr > 1966 and yr < 2066 else "SUPER BOWL"

# Injury notes -> a short word that fits under the logo (40 px of 4x5).
NOTE_SHORT = {"DISLOCATED": "DISLOC", "DISLOCATION": "DISLOC", "INFLAMMATION": "INFLAMED",
              "HYPEREXTENSION": "HYPEREXT", "CONCUSSION": "CONCUSS"}

# ------------------------------------------------------------------ feeds
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

# Designations that are not injuries: an inactive backup or a player away
# for family reasons has nothing to show on an X-ray.
NOT_INJURY = ["personal", "rest",
              "not injury related", "not injury related - personal", "suspension"]

SCORING = {"PPR": "pts_ppr", "HALF PPR": "pts_half_ppr", "STANDARD": "pts_std"}
SCORING_TAG = {"PPR": "", "HALF PPR": "HALF", "STANDARD": "STD"}

def status_key(s):
    t = str(s).strip().upper()
    if t in ["OUT", "IR", "PUP", "DOUBTFUL", "QUESTIONABLE"]:
        return t
    if t.startswith("PUP"):
        return "PUP"
    return ""

def settings(ctx):
    pos = str(ctx.inputs.get("position", "ALL")).strip().upper()
    if pos not in ["QB", "RB", "WR", "TE"]:
        pos = "ALL"
    sc = str(ctx.inputs.get("scoring", "PPR")).strip().upper()
    if sc not in SCORING:
        sc = "PPR"
    return {"pos": pos, "scoring": sc}

def num(v):
    return float(v) if type(v) in ["int", "float"] else 0.0

def fetch(ctx, which):
    """which "gametime": projections, QUESTIONABLE / DOUBTFUL, ranked by
    projected points, games already played dropped. which "out": season
    stats, OUT first then IR / PUP moves from the last 14 days, ranked by
    points per game. Either way: state + at most 3 requests, so both pages
    together stay inside the 8 uncached requests a render may make even
    when every cache has expired (1 + 3 + 3)."""
    s = settings(ctx)
    st = http.get(SLEEPER_STATE, headers = HEADERS, ttl_seconds = STATE_TTL)
    if st["status_code"] == 0:
        return dict(s, ok = False, head = "SLEEPER OFFLINE", sub = "RETRY IN 2 MIN")
    if st["status_code"] != 200 or type(st["json"]) != "dict":
        return dict(s, ok = False, head = "SLEEPER ERROR", sub = "HTTP " + str(st["status_code"]) + " - RETRY SOON")
    season = str(get(st["json"], "season", ""))
    stype = str(get(st["json"], "season_type", ""))
    week = int(num(get(st["json"], "week", 0)))
    if stype not in ["regular", "post"] or week < 1 or season == "":
        return dict(s, ok = True, off = True, pre = stype == "pre", players = [], week = week)

    key = SCORING[s["scoring"]]
    now = ctx.now.unix
    today = civil_days(ctx.now.year, ctx.now.month, ctx.now.day)
    want = ["QUESTIONABLE", "DOUBTFUL"] if which == "gametime" else ["OUT", "IR", "PUP"]
    if which == "gametime":
        url = SLEEPER_PROJ + season + "/" + str(week)
        stype_q = stype
        ttl = PROJ_TTL
    else:
        # Regular-season totals even in January: a playoff game or two says
        # little about what a player was worth.
        url = SLEEPER_STATS + season
        stype_q = "regular"
        ttl = STATS_TTL
    # WR alone is ~860 KB and RB ~480 KB against a 1 MB cap, so they go on
    # their own; QB and TE share one request (~640 KB).
    groups = [["QB", "TE"], ["RB"], ["WR"]] if s["pos"] == "ALL" else [[s["pos"]]]
    players = []
    failed = 0
    for grp in groups:
        # params values are single strings, so the repeated position[] key
        # goes in the URL itself
        q = "?" + "&".join(["position[]=" + g for g in grp])
        r = http.get(url + q, params = {"season_type": stype_q, "order_by": key},
                     headers = HEADERS, ttl_seconds = ttl)
        if r["status_code"] != 200 or type(r["json"]) != "list":
            failed += 1
            continue
        for row in r["json"]:
            pl = get(row, "player", {})
            # The feed matches on any fantasy position, so a WR can turn up
            # in the TE list: file each player under his own position.
            p = str(get(pl, "position", ""))
            if p not in grp:
                continue
            sk = status_key(get(pl, "injury_status", ""))
            if sk not in want:
                continue
            stats = get(row, "stats", {})
            if which == "gametime":
                val = num(get(stats, key, 0))
            else:
                gp = num(get(stats, "gp", 0))
                val = num(get(stats, key, 0)) / gp if gp >= 1 else 0.0
            if val < MIN_VALUE:
                continue
            part = str(get(pl, "injury_body_part", "")).lower()
            if part in NOT_INJURY or part.startswith("coach"):
                continue
            news = get(pl, "news_updated", 0)
            news_s = int(num(news)) // 1000
            gday = -1
            if which == "gametime":
                # Sleeper keeps QUESTIONABLE on until Tuesday: once the game
                # day has passed, the decision has been made.
                gday = date_days(get(row, "date", ""))
                if gday >= 0 and gday < today:
                    continue
            elif sk != "OUT":
                # IR / PUP from week 1 would top the list until January.
                if news_s <= 0 or now - news_s > IR_FRESH_DAYS * 86400:
                    continue
            team = str(get(row, "team", get(pl, "team", "")))
            name = clean(str(get(pl, "first_name", "")) + " " + str(get(pl, "last_name", "")))
            if name == "":
                continue
            opp = str(get(row, "opponent", ""))
            players.append({
                "name": name, "pos": p, "status": sk, "val": val,
                "team": ALIAS.get(team, team), "opp": clean(ALIAS.get(opp, opp)),
                "part": clean(get(pl, "injury_body_part", "")),
                "note": clean(get(pl, "injury_notes", "")),
                "age": ago(now, news), "day": day_tag(gday),
                "rank": 0 if sk == "OUT" or which == "gametime" else 1,
            })
    if failed == len(groups):
        return dict(s, ok = False, head = "SLEEPER DATA OFFLINE", sub = "RETRY IN 2 MIN")
    players = sorted(players, key = lambda x: (x["rank"], -x["val"]))[:MAX_PLAYERS]
    return dict(s, ok = True, off = False, players = players, week = week, stype = stype, season = season)

# ------------------------------------------------------------ the screens
def message(c, bar_col, head, head_col, subs, mode, box_col):
    """Error, empty and offseason share one card: the lightbox stays (so the
    app still reads as itself), the words sit centred in the text zone.
    `subs` lists wordings longest first; the first that fits wins."""
    c.fill("black")
    c.image(LOGO["NFL"], LOGO_X, 4)
    c.rect(BAR_X, 0, BAR_X + 1, 31, fill = bar_col)
    lightbox(c, "", box_col, mode)
    mid = (TX + TR) // 2
    hf = fit(c, head, ["6x8", "5x7", "4x5"], TW)
    c.text(hf[1], mid, 8, font = hf[0], color = head_col, align = "center")
    sub = subs[len(subs) - 1]
    for t in subs:
        if c.text_width(t, "4x5") <= TW:
            sub = t
            break
    c.text(clip(c, sub, "4x5", TW), mid, 21, font = "4x5", color = DIM, align = "center")

def gametime(c, ctx):
    page(c, ctx, "gametime")

def out(c, ctx):
    page(c, ctx, "out")

def chips(c, p, stv, col, count):
    """Status pill, position pill and (off a Sunday) the game-day pill on
    the left; the n/N counter right. The counter always stays: the status
    word shortens first, then the day pill goes, then the position."""
    cw = c.text_width(count, "4x5")
    right = TR - cw - 4
    mid = MID_WORD.get(stv[0], stv[1])
    tries = [[stv[0], True, True], [mid, True, True], [stv[1], True, True],
             [stv[0], True, False], [mid, True, False], [stv[1], True, False], [stv[1], False, False]]
    pick = tries[len(tries) - 1]
    for t in tries:
        w = pill_w(c, t[0])
        if t[1]:
            w += 2 + pill_w(c, p["pos"])
        if t[2]:
            if p["day"] == "":
                continue
            w += 2 + pill_w(c, p["day"])
        if TX + w - 1 <= right:
            pick = t
            break
    c.text(count, TR, 1, font = "4x5", color = DIM, align = "right")
    x = TX
    pill(c, pick[0], col, x, 0)
    x += pill_w(c, pick[0]) + 2
    if pick[1]:
        pill(c, p["pos"], POS_COLOR.get(p["pos"], DIM), x, 0)
        x += pill_w(c, p["pos"]) + 2
    if pick[2]:
        pill(c, p["day"], DAY_PILL, x, 0)

def under_logo(c, p, which, d):
    """Gametime: the matchup. Out: the injury itself (SURGERY, FRACTURE),
    else the week."""
    if which == "gametime":
        t = "VS " + p["opp"] if p["opp"] != "" else week_label(d)
        col = INK
    else:
        t = ""
        n = p["note"]
        if n != "":
            if c.text_width(n, "4x5") <= 40:
                t = n
            elif NOTE_SHORT.get(n, "") != "":
                t = NOTE_SHORT[n]
            elif c.text_width(n.split(" ")[0], "4x5") <= 40:
                t = n.split(" ")[0]
        col = INK
        if t == "":
            t = week_label(d)
    c.text(clip(c, t, "4x5", 40), LOGO_X + 20, 26, font = "4x5", color = col, align = "center")

def page(c, ctx, which):
    d = fetch(ctx, which)
    if not d["ok"]:
        message(c, OFFLINE, d["head"], "amber", [d["sub"]], "plain", DIM)
        return
    if d["off"]:
        if d["pre"]:
            message(c, DIM, "PRESEASON", INK, ["INJURY REPORT STARTS WEEK 1", "BACK IN WEEK 1"], "plain", BONE)
        else:
            message(c, DIM, "OFFSEASON", INK, ["INJURY REPORT RETURNS WEEK 1", "BACK IN WEEK 1"], "plain", BONE)
        return
    ps = d["players"]
    if len(ps) == 0:
        who = d["pos"] + "S" if d["pos"] != "ALL" else "PLAYERS"
        wk = week_label(d)
        if which == "gametime":
            message(c, GOOD, "NO GAME-TIME CALLS", GOOD,
                    ["NO " + who + " QUESTIONABLE - " + wk, "NO " + who + " QUESTIONABLE", "ALL CLEAR"], "healthy", GOOD)
        else:
            message(c, GOOD, "NOBODY RULED OUT", GOOD,
                    ["NO FANTASY " + who + " OUT - " + wk, "NO " + who + " OUT - " + wk, "ALL CLEAR"], "healthy", GOOD)
        return

    idx = (ctx.now.unix // 120) % len(ps)
    p = ps[idx]
    stv = STATUS[p["status"]]
    col = stv[2]
    c.fill("black")

    # Left: logo, the matchup or the injury under it, then the club bar.
    team = p["team"] if p["team"] in CLUB else "NFL"
    c.image(LOGO[team], LOGO_X, 0)
    club = CLUB.get(team, ["#3A4356", DIM])
    c.rect(BAR_X, 0, BAR_X, 31, fill = club[0])
    c.rect(BAR_X + 1, 0, BAR_X + 1, 31, fill = club[1])
    under_logo(c, p, which, d)

    # Right: the X-ray.
    lightbox(c, p["part"], col)

    chips(c, p, stv, col, str(idx + 1) + "/" + str(len(ps)))

    # Hero: the name, centred in the band y 8..22.
    forms = name_forms(p["name"])
    nm = pick_name(c, forms, TW)
    ny = 8 + (15 - INKH[nm[1]]) // 2
    if nm[0] < 0:
        c.text(clip(c, forms[3], "5x7", TW), TX, ny, font = "5x7", color = INK)
    else:
        tight_text(c, forms[nm[0]], TX, ny, nm[1], INK)

    # Footer y 25..31: the number right (measured first), its label left of
    # it, the body part in whatever is left.
    val = one_decimal(p["val"])
    vw = c.text_width(val, "5x7")
    c.text(val, TR, 25, font = "5x7", color = INK, align = "right")
    word = "PROJ" if which == "gametime" else "PPG"
    undisclosed = p["part"] == "" or p["part"] == "UNDISCLOSED"
    lx = TR - vw - 3
    tag = SCORING_TAG[d["scoring"]]
    label = word + (" " + tag if tag != "" else "")
    first = p["part"] if not undisclosed else "UPD " + p["age"] + " AGO"
    if TX + c.text_width(first, "5x7") + 4 + c.text_width(label, "4x5") > lx:
        label = word
    c.text(label, lx, 27, font = "4x5", color = DIM, align = "right")
    room = lx - c.text_width(label, "4x5") - 4 - TX

    # "KNEE - MENISCUS": the whole phrase if it fits (5x7, then 4x5), else
    # the part before the dash. Undisclosed: how fresh the news
    # is ("UPD 3H AGO"), since there is no part to name.
    if undisclosed:
        parts = (["UPD " + p["age"] + " AGO"] if p["age"] != "" else []) + ["UNDISCLOSED", "UNDISC"]
        if p["note"] != "":
            parts = [p["note"]] + parts
    else:
        parts = [p["part"]]
        if p["part"].find(" - ") > 0:
            parts.append(p["part"][:p["part"].find(" - ")])
    pf = None
    for t in parts:
        for f in ["5x7", "4x5"]:
            if pf == None and c.text_width(t, f) <= room:
                pf = [f, t]
    if pf == None:
        pf = ["4x5", clip(c, parts[len(parts) - 1], "4x5", room)]
    c.text(pf[1], TX, 25 if pf[0] == "5x7" else 27, font = pf[0], color = col)
