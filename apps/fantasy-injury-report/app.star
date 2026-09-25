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
# DESIGN. An X-ray lightbox is the whole show. The centre of the strip is
# a landscape lightbox - a glowing 1 px rim, two clips on top - holding a
# dark-blue film with a full-body skeleton lying across it, head on the
# left: skull, collarbones, ribs round the spine, arms at the sides, pelvis,
# femurs, knees, shins, feet. The bone that is hurt glows in the status
# colour with a dim halo round it: red for OUT and IR, orange for DOUBTFUL,
# amber for QUESTIONABLE. You read WHERE he is hurt before you read a word.
# The club logo (24 x 18, drawn at its authored size) sits in the film's
# top-right corner, and the
# film's bottom edge carries the caption, as a radiograph is labelled: the
# player's name in bone white on the left, the body part in the status
# colour on the right. Left of the lightbox, the status as a rubber stamp
# (a frame in the status colour with a few pixels of ink missing), with the
# position pill, a white game-day pill (MNF, TNF, SAT - the classic lineup
# trap) and the n/N counter under it. Right of it, the number that makes
# this news matter ("PROJ 14.3", or "PPG 11.9" for a player who is out),
# with the matchup ("VS CHI") or the injury itself ("SURGERY") under it.
# An undisclosed injury puts a "?" on the ribs and says how fresh the news
# is ("UPD 3H AGO"). Offline, empty and offseason screens keep all three
# zones: a stamp (ERROR / CLEAR / OFF / PRE), the film with a grey or an
# all-green skeleton and the news as its caption, and a number.
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
# 192 wide, three zones, 6 px of edge padding each side.
#   x   6..43   the stamp (y 0..13), position / game-day pills (y 16), n/N (y 25)
#   x  46..147  the lightbox: a lit 1 px rim, the film x 47..146 y 1..30.
#               Skeleton 71 x 19 at x 49..119 y 2..20, the 24 x 18 club
#               logo at x 121..144 y 3..20 (1 px clear of the skeleton, the
#               clip and the caption), the caption (name
#               left, body part right) along the bottom edge y 22..29.
#   x 150..185  the number: label y 2, value y 8..19, matchup / note y 25.
STAMP_X0 = 6
STAMP_X1 = 43
BOX_X0 = 46
BOX_X1 = 147
FILM_X0 = BOX_X0 + 1
FILM_X1 = BOX_X1 - 1
BODY_X = 49
BODY_Y = 2
MINI_X = 121             # 24 x 18 logo, x 121..144
MINI_Y = 3
MINI_W = 24
MINI_H = 18
CAP_X0 = 49
CAP_X1 = 144
CAP_W = CAP_X1 - CAP_X0 + 1
NUM_X0 = 150
NUM_X1 = 185
NUM_W = NUM_X1 - NUM_X0 + 1
NUM_MID = (NUM_X0 + NUM_X1 + 1) // 2

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
GOOD = "#2FE06F"
C_OUT = "#FF2D2D"
C_DOUBT = "#FF7A1F"
C_QUES = "#FFBF00"
XRAY_BG = "#0A1A33"
XRAY_EDGE = "#1E3A66"
BONE = "#A8C8F0"
LIGHT = "#D6E6FF"        # the lightbox glowing round the film
CLIP = "#56627A"         # the two film clips on the top rim
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

# Logos ship as 24 x 18 PNGs named by ESPN abbreviation, drawn unscaled.
# Literal file names, because the publish lint cannot follow a built-up
# path. No team (the message screens, an unknown club) gets the NFL tile.
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png",
    "SEA": "SEA.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
}

# Sleeper abbreviations that differ from the logo set.
ALIAS = {"WAS": "WSH", "JAC": "JAX", "LA": "LAR", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# ----------------------------------------------------------- the skeleton
# 71 x 19: a full-body front view lying on the film, head on the left, as a
# radiograph is hung on a landscape lightbox. Each region is its own letter
# so any one of them can light up: H skull, N neck, S collarbones and
# shoulders, C ribs, B spine and lower back, A upper arm, E elbow, F forearm
# (both bones), W wrist, P hand, G pelvis and hip, T femur (thigh), K knee,
# L shin (tibia and fibula), X ankle, O foot. The holes (eye sockets, the
# gaps between ribs and between the leg bones) show the film.
BODY = """
.........................EFFFFFFFFFWPPP................................
............SAAAAAAAAAAAAE.........WP..................................
...........SS............EFFFFFFFFFWPPP...............................O
...........S.............................GG..........................OO
..HHHH.....S......CC.CC.CC.CC...........GGGG.............KK..........OO
.HHHHHHH...S..CC.C..C..C..C..CC.........GG.GGTTTTTTTTTTTTKKLLLLLLLLLXOO
HHH..HHHH..S..C..C..C..C..C..C..........G..GGTTTTTTTTTTTTKK.........XO.
HH...HH.H..S.C..C..C..C..C..C...........GG..G............KKLLLLLLLLLXO.
HHH.HHHHH..S.C..C..C..C..C..C....B.B.B...GG.G..........................
HHHHHH.HHNNBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBGGGG..........................
HHH.HHHHH..S.C..C..C..C..C..C....B.B.B...GG.G..........................
HH...HH.H..S.C..C..C..C..C..C...........GG..G............KKLLLLLLLLLXO.
HHH..HHHH..S..C..C..C..C..C..C..........G..GGTTTTTTTTTTTTKK.........XO.
.HHHHHHH...S..CC.C..C..C..C..CC.........GG.GGTTTTTTTTTTTTKKLLLLLLLLLXOO
..HHHH.....S......CC.CC.CC.CC...........GGGG.............KK..........OO
...........S.............................GG..........................OO
...........SS............EFFFFFFFFFWPPP...............................O
............SAAAAAAAAAAAAE.........WP..................................
.........................EFFFFFFFFFWPPP................................
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

def lightbox(c, part, col, team, mode = "injury"):
    """The hero, x 46..147: a lightbox glowing in a 1 px rim round a
    dark-blue film held by two clips, the skeleton lying across it in bone
    blue with the hurt bone in the status colour and a halo round it, and
    the club logo in the film's top-right corner (an "NFL" tile when there
    is no club). Mode
    "healthy" lights every bone (the all-clear), "plain" draws the whole
    skeleton in `col` (grey when offline)."""
    c.rect(BOX_X0, 0, BOX_X1, 31, fill = XRAY_BG, outline = LIGHT)
    for cx in [BOX_X0 + 12, BOX_X1 - 15]:
        c.rect(cx, 0, cx + 3, 1, fill = CLIP)
    lit = REGIONS if mode == "healthy" else ("" if mode == "plain" else lit_regions(part))
    leg = {"h": HALO.get(col, XRAY_EDGE)}
    for r in REGIONS.elems():
        leg[r] = col if lit.find(r) >= 0 or mode == "plain" else BONE
    c.sprite(glow_sprite("" if mode == "healthy" else lit), BODY_X, BODY_Y, legend = leg)
    if team in LOGO:
        c.image(LOGO[team], MINI_X, MINI_Y)
    else:
        # The league tile: the 40 x 24 shield would not fit the corner.
        c.rect(MINI_X, MINI_Y, MINI_X + MINI_W - 1, MINI_Y + MINI_H - 1, outline = XRAY_EDGE)
        c.text("NFL", MINI_X + MINI_W // 2, MINI_Y + (MINI_H - 7) // 2, font = "5x7", color = BONE, align = "center")
    if lit == "" and mode == "injury":
        # Undisclosed: a big "?" over the ribs, since there is nothing to point at.
        c.text_stroke("?", BODY_X + 18, BODY_Y + 5, font = "8x10", color = col, stroke = XRAY_BG)

def stamp(c, words, col):
    """The status as a rubber stamp, x 6..43 y 0..13: a 1 px frame in the
    status colour with the word centred inside, the biggest face that fits,
    and a few pixels of the frame missing where the ink did not take."""
    c.rect(STAMP_X0, 0, STAMP_X1, 13, outline = col)
    for w in [[STAMP_X0 + 5, 0], [STAMP_X0 + 6, 0], [STAMP_X1, 4], [STAMP_X1 - 9, 13], [STAMP_X0, 10]]:
        c.pixel(w[0], w[1], "black")
    room = STAMP_X1 - STAMP_X0 - 5    # 2 px of paper each side of the word
    pick = ["4x5", clip(c, words[len(words) - 1], "4x5", room)]
    done = False
    for f in ["8x10", "6x8", "5x7", "4x5"]:
        for w in words:
            if not done and c.text_width(w, f) <= room:
                pick = [f, w]
                done = True
    y = 1 + (13 - INKH[pick[0]]) // 2
    c.text(pick[1], (STAMP_X0 + STAMP_X1 + 1) // 2, y, font = pick[0], color = col, align = "center")

def number_zone(c, top, big, big_col, bottom, bottom_col):
    """x 150..185: a small label, the number, and a line under it."""
    if top != "":
        tf = fit(c, top, ["4x5", "3x4"], NUM_W)
        c.text(tf[1], NUM_MID, 2, font = tf[0], color = DIM, align = "center")
    bf = ["5x7", big]
    for f in ["9x12", "8x10", "6x8", "5x7"]:
        if bf[0] == "5x7" and tight_w(c, big, f) <= NUM_W:
            bf = [f, big]
            if f != "5x7":
                break
    bw = tight_w(c, bf[1], bf[0])
    tight_text(c, bf[1], NUM_MID - bw // 2, 8 + (12 - INKH[bf[0]]) // 2, bf[0], big_col)
    if bottom != "":
        lf = fit(c, bottom, ["4x5", "3x4"], NUM_W)
        c.text(lf[1], NUM_MID, 25 if lf[0] == "4x5" else 26, font = lf[0], color = bottom_col, align = "center")

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
INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5, "3x4": 4}

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
def caption_fit(c, options):
    """The first wording that fits the film's caption line in 6x8 or 5x7,
    else the first that fits in 4x5."""
    for t in options:
        for f in ["6x8", "5x7"]:
            if c.text_width(t, f) <= CAP_W:
                return [f, t]
    for t in options:
        if c.text_width(t, "4x5") <= CAP_W:
            return ["4x5", t]
    return ["4x5", clip(c, options[len(options) - 1], "4x5", CAP_W)]

def caption_y(font):
    """Bottom-align every caption face on y 29."""
    return 30 - INKH[font]

def message(c, stamp_words, stamp_col, caps, cap_col, top, big, big_col, bottom, mode, box_col):
    """Error, empty and offseason keep the same three zones, so the app still
    reads as itself: a stamp, the lightbox (grey skeleton when the data is
    down, every bone green for the all-clear) with the news as the film's
    caption, and a number on the right."""
    c.fill("black")
    stamp(c, stamp_words, stamp_col)
    lightbox(c, "", box_col, "NFL", mode)
    cf = caption_fit(c, caps)
    c.text(cf[1], CAP_X0, caption_y(cf[0]), font = cf[0], color = cap_col)
    number_zone(c, top, big, big_col, bottom, INK)

def gametime(c, ctx):
    page(c, ctx, "gametime")

def out(c, ctx):
    page(c, ctx, "out")

def pills(c, p):
    """Position pill and, off a Sunday, the white game-day pill (MNF, TNF,
    SAT - the classic lineup trap) under the stamp."""
    x = STAMP_X0
    pill(c, p["pos"], POS_COLOR.get(p["pos"], DIM), x, 16)
    x += pill_w(c, p["pos"]) + 2
    if p["day"] != "" and x + pill_w(c, p["day"]) - 1 <= STAMP_X1:
        pill(c, p["day"], DAY_PILL, x, 16)

def bottom_right(c, p, which, d):
    """Gametime: the matchup. Out: the injury itself (SURGERY, FRACTURE),
    else the week."""
    if which == "gametime":
        return "VS " + p["opp"] if p["opp"] != "" else week_label(d)
    n = p["note"]
    if n != "":
        if c.text_width(n, "4x5") <= NUM_W:
            return n
        if NOTE_SHORT.get(n, "") != "" and c.text_width(NOTE_SHORT[n], "4x5") <= NUM_W:
            return NOTE_SHORT[n]
        if c.text_width(n.split(" ")[0], "4x5") <= NUM_W:
            return n.split(" ")[0]
    return week_label(d)

# Caption name forms and faces, best first: [form index, font].
CAP_NAME = [[0, "6x8"], [1, "6x8"], [0, "5x7"], [1, "5x7"], [2, "6x8"], [2, "5x7"],
            [3, "6x8"], [3, "5x7"], [2, "4x5"], [3, "4x5"]]

def page(c, ctx, which):
    d = fetch(ctx, which)
    if not d["ok"]:
        code = d["head"] == "SLEEPER ERROR"
        message(c, ["ERROR"], C_QUES, [d["head"]], "amber",
                "HTTP" if code else "RETRY", d["sub"].split(" ")[1] if code else "2", INK,
                "RETRY" if code else "MINUTES", "plain", DIM)
        return
    if d["off"]:
        if d["pre"]:
            message(c, ["PRE"], BONE, ["PRESEASON", "PRE"], INK, "STARTS", "WK1", INK, "", "plain", BONE)
        else:
            message(c, ["OFF"], BONE, ["OFFSEASON", "OFF"], INK, "RETURNS", "WK1", INK, "", "plain", BONE)
        return
    ps = d["players"]
    if len(ps) == 0:
        who = d["pos"] + "S" if d["pos"] != "ALL" else "PLAYERS"
        wk = week_label(d)
        if which == "gametime":
            message(c, ["CLEAR"], GOOD, ["NO GAME-TIME CALLS", "NO CALLS"], GOOD,
                    who, "0", GOOD, wk, "healthy", GOOD)
        else:
            message(c, ["CLEAR"], GOOD, ["NOBODY RULED OUT", "NONE OUT"], GOOD,
                    who, "0", GOOD, wk, "healthy", GOOD)
        return

    idx = (ctx.now.unix // 120) % len(ps)
    p = ps[idx]
    stv = STATUS[p["status"]]
    col = stv[2]
    team = p["team"] if p["team"] in LOGO else "NFL"
    c.fill("black")

    # Left: the stamp, the pills, the n/N counter.
    stamp(c, [stv[0], MID_WORD.get(stv[0], stv[1]), stv[1]], col)
    pills(c, p)
    c.text(str(idx + 1) + "/" + str(len(ps)), STAMP_X0, 25, font = "4x5", color = DIM)

    # Centre: the film.
    lightbox(c, p["part"], col, team)

    # Right: the number that makes this news matter.
    word = "PROJ" if which == "gametime" else "PPG"
    tag = SCORING_TAG[d["scoring"]]
    label = word + (" " + tag if tag != "" else "")
    if c.text_width(label, "4x5") > NUM_W:
        label = word
    number_zone(c, label, one_decimal(p["val"]), INK, bottom_right(c, p, which, d), INK)

    # The caption along the film's bottom edge: the name left in bone
    # white, the body part right in the status colour ("KNEE - MENISCUS",
    # else the part before the dash). Undisclosed: how fresh the news is
    # ("UPD 3H AGO") instead. The name gets the biggest face first.
    undisclosed = p["part"] == "" or p["part"] == "UNDISCLOSED"
    if undisclosed:
        parts = (["UPD " + p["age"] + " AGO"] if p["age"] != "" else []) + ["UNDISCLOSED", "UNDISC"]
        if p["note"] != "":
            parts = [p["note"]] + parts
    else:
        parts = [p["part"]]
        if p["part"].find(" - ") > 0:
            parts.append(p["part"][:p["part"].find(" - ")])
    forms = name_forms(p["name"])
    pick = None
    for nm in CAP_NAME:
        nw = tight_w(c, forms[nm[0]], nm[1])
        for t in parts:
            for f in ["5x7", "4x5"]:
                if pick == None and nw + 4 + c.text_width(t, f) <= CAP_W:
                    pick = [nm, f, t]
    if pick == None:
        nm = [3, "4x5"]
        room = CAP_W - tight_w(c, forms[3], "4x5") - 4
        pick = [nm, "4x5", clip(c, parts[len(parts) - 1], "4x5", room)]
    nm = pick[0]
    tight_text(c, forms[nm[0]], CAP_X0, caption_y(nm[1]), nm[1], INK)
    c.text(pick[2], CAP_X1, caption_y(pick[1]), font = pick[1], color = col, align = "right")
