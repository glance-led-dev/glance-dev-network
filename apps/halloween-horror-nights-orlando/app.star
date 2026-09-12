# Halloween Horror Nights Orlando for a Glance SCROLL panel (192x32).
#
# DESIGN. One park (Universal Studios Florida), one event, four pages, no
# licensed mascot (Jack the Clown and Dr. Oddfellow are Universal's
# trademarks) - so the scenery does the identifying. Page 1 is the title
# card: a moonlit haunted mansion on the left with its windows lit, the
# event name across the middle in HHN orange, and on the right a dead tree,
# a graveyard and bats crossing a full moon, with fog rolling along the
# bottom. Every other page opens with an orange HORROR NIGHTS chip, like its
# sibling Universal Orlando Parks app opens each park page with the park's
# chip. Page 2 keeps the mansion on the left and puts tonight's answer in
# the middle as one big bold word: OPEN NOW, TONIGHT, a count of nights
# until opening night, or OFF SEASON. Pages 3 and 4 split the ten haunted
# houses five to a page in two columns, each house wearing its standby
# minutes in a pill colored by how much it hurts. On nights with no event
# the house pages keep the mansion and say plainly when the gates open.
# Black ground throughout: it is the cheapest contrast there is, and the
# orange, the amber windows and the pale moon all read from across a room.
#
# Data: api.themeparks.wiki. /schedule's TICKETED_EVENT entries are
# individual HHN nights (one per date, not a season range), so "is it on
# tonight" and "how many nights until it is" both fall out of the same list.
# /live's haunted-house attractions carry externalId "hhn_haunted_house_*"
# with a normal STANDBY queue once the event is running. One park, two
# fetches. Eastern time is worked out here with no network call.

API = "https://api.themeparks.wiki/v1/entity/"
PARK_ID = "eb3f4560-2383-4a36-9152-6b3e5ed6bc57"   # Universal Studios Florida
TTL = 900                 # matches refresh: in the manifest

INK = "#F4F7FF"
DIM = "#6E7A94"
ORANGE = "#FF6A00"        # HHN's own accent
PURPLE = "#A86BFF"        # the countdown color, and the off-season one
OFFLINE = "#3C4043"
STRUCT = "darkgray"

# ---- geometry ----------------------------------------------------------------
# 6 px clear at both outer edges (x 6..185), like the sibling app. Chip row
# y 0..6, content band y 8..31. The small mansion stands at x 6..31.
EDGEL = 6
RZ_R = 185
ARTX = 6
ARTY = 8
ZONEL = 36                # text zone to the right of the small mansion
MIDX = (ZONEL + RZ_R) // 2

STATE_COLOR = {"open": "green", "tonight": ORANGE, "countdown": PURPLE,
               "offseason": PURPLE}

# ---- pixel art ---------------------------------------------------------------
# Moonlit purple-grays for the mansion: a silhouette drawn in near-black is
# invisible on real LED hardware, so the walls are a clear lavender-gray, the
# shadow side a step darker, the roofs lighter still, and the windows amber.
MANSION_LEG = {"M": "#6A6390", "m": "#3E3858", "R": "#8C86B0", "r": "#3E3858",
               "W": "#FFC94A", "D": "#0E0A16", "G": "#2A2440"}

# The title-card mansion: a gabled main house with a porch and a tall
# tower, 34 x 26.
MANSION = """
..........................RR......
.........................RRRR.....
........................RRRRRR....
.......................RRRRRRRR...
........mm............RRRRRRRRRR..
........mm...........rrrrrrrrrrrr.
........mm...R.........MMMMMMMmm..
........mm..RRR........MMMMMMMmm..
........mm.RRRRR.......MMMMMMMmm..
..........RRRRRRR......MMMWWWMmm..
.........RRRRRRRRR.....MMMWWWMmm..
........RRRRRRRRRRR....MMMWWWMmm..
.......RRRRRRRRRRRRR...MMMMMMMmm..
......rrrrrrrrrrrrrrr..MMMMMMMmm..
.......MMWWMMMMWWMm....MMMMMMMmm..
.......MMWWMMMMWWMm....MMMMMMMmm..
.......MMMMMMMMMMMm....MMMWWWMmm..
.......MMMMMMMMMMMm....MMMWWWMmm..
.....rrrrrrrrrrrrrrrr..MMMWWWMmm..
.....m.MMMMMDDMMMMm.m..MMMMMMMmm..
.....m.MMMMMDDMMMMm.m..MMMMMMMmm..
.....m.MMMMMDDMMMMm.m..MMMMMMMmm..
.....m.MMMMMDDMMMMm.m..MMMMMMMmm..
.....m.MMMMMDDMMMMm.m..MMMMMMMmm..
....mmmmmmmmmmmmmmmmmm.MMMMMMMmm..
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
"""

# The same house at page size, 26 x 23, standing on the content band.
MANSION_S = """
....................RR....
...................RRRR...
..................RRRRRR..
.................RRRRRRRR.
......mm........rrrrrrrrrr
......mm..R.......MMMMMmm.
......mm.RRR......MMMMMmm.
........RRRRR.....MMWWMmm.
.......RRRRRRR....MMWWMmm.
......RRRRRRRRR...MMMMMmm.
.....rrrrrrrrrrr..MMMMMmm.
......MWWMMWWMm...MMMMMmm.
......MWWMMWWMm...MMMMMmm.
......MMMMMMMMm...MMWWMmm.
......MMMMMMMMm...MMWWMmm.
....rrrrrrrrrrrr..MMMMMmm.
....m.MMMDDMMMmm..MMMMMmm.
....m.MMMDDMMMmm..MMMMMmm.
....m.MMMDDMMMmm..MMMMMmm.
....m.MMMDDMMMmm..MMMMMmm.
....m.MMMDDMMMmm..MMMMMmm.
...mmmmmmmmmmmmmm.MMMMMmm.
GGGGGGGGGGGGGGGGGGGGGGGGGG
"""

TREE_LEG = {"N": "#5E4E78"}
DEAD_TREE = """
N....N.......
.N...N...N...
..N.N...N....
...NN..N.....
N...NN.N.....
.N..NNN......
..NNNN..N....
....NN.N.....
....NNN......
....NN.......
....NN.......
....NN.......
...NNN.......
...NNNN......
..NNNNNN.....
"""

GRAVE_LEG = {"T": "#6E6A80", "t": "#3E3A50"}
TOMB_A = """
.TTT.
TTTTT
TTtTT
TTTTT
TTtTT
TTTTT
"""
TOMB_B = """
.TT.
TTTT
TTTT
TtTT
TTTT
"""
CROSS = """
..T..
..T..
TTTTT
..T..
..T..
..T..
..T..
"""

MOON_LEG = {"L": "#FFF0C8", "m": "#D8C89A"}
MOON = """
...LLLLL...
.LLLLLLLLL.
.LLLLmLLLL.
LLLLLLLLLLL
LLmLLLLLmLL
LLLLLLLLLLL
LLLLLLmLLLL
LLLLLLLLLLL
.LLmLLLLLL.
.LLLLLLLLL.
...LLLLL...
"""

BAT = """
#..#..#
#######
.##.##.
"""

def fog(c, y, offset):
    """A row of drifting dashes, in a gray clearly lighter than black so it
    reads as mist instead of vanishing."""
    for x in range(EDGEL + offset, RZ_R - 6, 11):
        c.hline(x, y, 7, "#4A4660")

def title_card(c):
    """The splash scene. Nothing here depends on the network."""
    c.sprite(MANSION, EDGEL, 5, legend = MANSION_LEG)
    # graveyard on the right: a dead tree, three stones, bats across the moon
    c.sprite(MOON, 172, 2, legend = MOON_LEG)
    c.sprite(BAT, 174, 6, color = "#100C18")
    c.sprite(BAT, 166, 3, color = "#6B4F9E")
    c.sprite(DEAD_TREE, 146, 8, legend = TREE_LEG)
    c.sprite(TOMB_A, 161, 25, legend = GRAVE_LEG)
    c.sprite(CROSS, 169, 24, legend = GRAVE_LEG)
    c.sprite(TOMB_B, 178, 26, legend = GRAVE_LEG)
    c.hline(144, 31, 42, "#2A2440")
    fog(c, 30, 0)
    fog(c, 31, 6)

def chip_row(c, label, chip_color, meta, meta_color):
    ink = "white" if chip_color in [PURPLE, OFFLINE] else "black"
    c.badge(label, EDGEL, 0, color = ink, bg = chip_color, font = "4x5")
    if meta != "":
        c.text(meta, RZ_R, 1, font = "4x5", color = meta_color, align = "right")

# ---- text kit (identical contract to the sibling app's) -------------------
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[:sp]
    return t

KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -&.'!:"

def clean_name(name):
    out = ""
    for ch in str(name).upper().elems():
        if KEEP.find(ch) >= 0:
            out = out + ch
    parts = []
    for p in out.split(" "):
        if p != "":
            parts.append(p)
    return " ".join(parts)

# The name people actually call each house, sized for a wait row: a house
# gets 66 px beside a 2-digit pill and 62 beside a 3-digit one. Only the
# houses with a promotional subtitle ("X Presents: Y") or a name wider than
# a row are shortened; the rest keep their real name. Anything unmatched is
# clipped at a word boundary.
HOUSE_NICKS = [
    ["BLOODENGUTZ", "BLOODENGUTZ"], ["ODDFELLOW", "ODDFELLOW"],
    ["MADLANDS", "MADLANDS"], ["INVASION", "INVASION"],
    ["OZZY", "OZZY OSBOURNE"], ["STRANGER THINGS", "STRANGER THINGS"],
    ["EVIL DEAD", "EVIL DEAD"],
]

def house_name(c, raw, room):
    t = clean_name(raw)
    for n in HOUSE_NICKS:
        if t.find(n[0]) >= 0:
            t = n[1]
            break
    if c.text_width(t, "4x5") <= room:
        return t
    # A house name that overflows is cut at its last whole word, whatever
    # that costs: "STRANGER" reads as a name, "STRANGER THING" reads as a
    # mistake. Only a single word that overflows is cut mid-word.
    t = clip(c, t, "4x5", room)
    sp = t.rfind(" ")
    if sp > 0:
        t = t[:sp]
    for _ in range(3):
        if len(t) > 0 and t[len(t) - 1] in [":", "-", ",", ".", "&", " ", "'"]:
            t = t[:len(t) - 1]
        else:
            break
    return t

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def lst(obj, key):
    v = get(obj, key, [])
    return v if type(v) == "list" else []

# ---- Eastern time, no network (same civil-calendar math as the sibling app) -
def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + 1 if m <= 2 else y, m, d]

def nth_sunday(y, m, n):
    wd = (days_from_civil(y, m, 1) + 3) % 7        # 0 = Monday
    first = 1 + ((6 - wd) % 7)
    return first + 7 * (n - 1)

def eastern_minutes(unix):
    """Minutes since the epoch on Orlando's wall clock. US rule: daylight
    time from the 2nd Sunday in March at 2 AM to the 1st Sunday in November
    at 2 AM, all compared in UTC."""
    t = unix // 60
    y = civil_from_days(t // 1440)[0]
    std = -300
    start = days_from_civil(y, 3, nth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = days_from_civil(y, 11, nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    off = std + 60 if t >= start and t < end else std
    return t + off

def two(v):
    return ("0" + str(v)) if v < 10 else str(v)

def date_key(ymd):
    return str(ymd[0]) + "-" + two(ymd[1]) + "-" + two(ymd[2])

def iso_minutes(value):
    t = str(value)
    if len(t) < 16:
        return -1
    return int(t[11:13]) * 60 + int(t[14:16])

def iso_ymd(value):
    """[y, m, d] out of an ISO stamp's own date, no timezone math needed:
    themeparks.wiki always hands back the park's local wall clock."""
    t = str(value)
    if len(t) < 10:
        return None
    return [int(t[0:4]), int(t[5:7]), int(t[8:10])]

def epoch_minutes_iso(value):
    """Absolute minutes on the same wall-clock scale as eastern_minutes(),
    so a closing time past midnight compares correctly against `now`."""
    ymd = iso_ymd(value)
    if ymd == None:
        return -1
    return days_from_civil(ymd[0], ymd[1], ymd[2]) * 1440 + iso_minutes(value)

def clock(value):
    m = iso_minutes(value)
    if m < 0:
        return ""
    h = m // 60
    mm = m % 60
    ap = "A" if h < 12 else "P"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    if mm == 0:
        return str(h12) + ap
    return str(h12) + ":" + two(mm) + ap

MONTH = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP",
         "OCT", "NOV", "DEC"]

def month_day(ymd):
    return MONTH[ymd[1]] + " " + str(ymd[2])

# ---- feed -------------------------------------------------------------------
def fetch(path):
    r = http.get(API + path, headers = {"accept": "application/json"},
                 ttl_seconds = TTL)
    if r["status_code"] != 200:
        return None
    return r["json"]

def is_hhn(entry):
    if get(entry, "type", "") != "TICKETED_EVENT":
        return False
    return str(get(entry, "description", "")).upper().find("HALLOWEEN") >= 0

def standby(entry):
    q = get(entry, "queue", {})
    sb = get(q, "STANDBY")
    if sb == None:
        return None
    w = get(sb, "waitTime")
    if w == None or type(w) != "int":
        return None
    if w < 0 or w > 300:
        return None
    return w

def read_hhn(ctx):
    """Everything the pages draw, display-ready, or {"online": False}."""
    dbg = str(ctx.inputs.get("_debugstate", "")).strip().lower()
    if dbg != "":
        return demo_state(dbg)

    live = fetch(PARK_ID + "/live")
    sched = fetch(PARK_ID + "/schedule")
    if live == None and sched == None:
        return {"online": False}

    rows = lst(live, "liveData")
    entries = lst(sched, "schedule")

    now_abs = eastern_minutes(ctx.now.unix)
    today = civil_from_days(now_abs // 1440)
    today_key = date_key(today)
    today_day = days_from_civil(today[0], today[1], today[2])
    time_of_day = now_abs % 1440

    nights = [e for e in entries if is_hhn(e)]
    tonight = None
    next_night = None
    for e in nights:
        d = get(e, "date", "")
        if d == today_key:
            tonight = e
        elif next_night == None and d > today_key:
            next_night = e

    houses = []
    for e in rows:
        ext = str(get(e, "externalId", ""))
        if ext.find("hhn_haunted_house") < 0:
            continue
        houses.append([standby(e), get(e, "name", "")])
    houses = sorted(houses, key = lambda r: -1 if r[0] == None else -r[0])

    # themeparks.wiki dates a night by the evening it starts ("2026-09-10",
    # 6:30P-2A), and the DEFAULT /schedule endpoint only lists today onward -
    # it drops that entry the instant the calendar date rolls to the 11th,
    # even though the houses are still OPERATING for another hour or two
    # (verified against the live feed, not assumed). So before 6 AM, look
    # yesterday up on the dated monthly endpoint instead, which still has it,
    # and check whether its real closing time has actually passed yet.
    if time_of_day < 360:
        yday = civil_from_days(now_abs // 1440 - 1)
        yesterday_key = date_key(yday)
        month_sched = fetch(PARK_ID + "/schedule/" + str(yday[0]) + "/" + two(yday[1]))
        last_night = None
        for e in lst(month_sched, "schedule"):
            if is_hhn(e) and get(e, "date", "") == yesterday_key:
                last_night = e
                break
        if last_night != None:
            close_abs = epoch_minutes_iso(get(last_night, "closingTime"))
            if now_abs < close_abs:
                return {
                    "online": True, "state": "open",
                    "hours": [clock(get(last_night, "openingTime")), clock(get(last_night, "closingTime"))],
                    "houses": houses,
                }

    if tonight != None:
        open_abs = epoch_minutes_iso(get(tonight, "openingTime"))
        return {
            "online": True, "state": "open" if now_abs >= open_abs else "tonight",
            "hours": [clock(get(tonight, "openingTime")), clock(get(tonight, "closingTime"))],
            "houses": houses,
        }

    if next_night != None:
        ymd = iso_ymd(get(next_night, "date") + "T00:00:00")
        night_day = days_from_civil(ymd[0], ymd[1], ymd[2])
        return {
            "online": True, "state": "countdown", "days": night_day - today_day,
            "date": month_day(ymd),
            "hours": [clock(get(next_night, "openingTime")), clock(get(next_night, "closingTime"))],
            "houses": [],
        }

    return {"online": True, "state": "offseason", "houses": []}

# Sample states for previewing every screen while off event nights:
# _debugstate = open | tonight | screamearly | countdown | offseason | offline.
DEMO_HOUSES = [
    [75, "Hellraiser"], [60, "Stranger Things 5"], [55, "Sinners"],
    [50, "INVASION: Alien Abduction"], [45, "Cybergoria"],
    [40, "Ozzy Osbourne: Prince of Darkness"], [35, "Evil Dead Burn"],
    [30, "MADLANDS: Caged Cannibals"], [25, "Jack & Oddfellow: Chaos & Control"],
    [20, "H.R. Bloodengutz Presents: A Halloween Fright-Tacular!"],
]

# Only the 3 houses Universal confirmed for the 2P Scream Early add-on are
# posting a wait; the rest still show "--" until general gates at 6:30P.
SCREAM_EARLY_HOUSES = [
    [25, "Stranger Things 5"], [20, "Hellraiser"],
    [15, "Jack & Oddfellow: Chaos & Control"],
    [None, "Sinners"], [None, "Ozzy Osbourne: Prince of Darkness"],
    [None, "Cybergoria"], [None, "MADLANDS: Caged Cannibals"],
    [None, "INVASION: Alien Abduction"], [None, "Evil Dead Burn"],
    [None, "H.R. Bloodengutz Presents: A Halloween Fright-Tacular!"],
]

def demo_state(dbg):
    if dbg == "offline":
        return {"online": False}
    if dbg == "open":
        return {"online": True, "state": "open", "hours": ["6:30P", "2A"], "houses": DEMO_HOUSES}
    if dbg == "screamearly":
        return {"online": True, "state": "tonight", "hours": ["6:30P", "2A"],
                "houses": SCREAM_EARLY_HOUSES}
    if dbg == "tonight":
        return {"online": True, "state": "tonight", "hours": ["6:30P", "2A"], "houses": []}
    if dbg == "countdown":
        return {"online": True, "state": "countdown", "days": 3, "date": "SEP 12",
                "hours": ["6:30P", "1A"], "houses": []}
    return {"online": True, "state": "offseason", "houses": []}

# ---- wait color (same bands as the sibling app) ------------------------------
def wait_color(w):
    if w == None:
        return DIM
    if w < 30:
        return "green"
    if w < 60:
        return "amber"
    if w < 90:
        return "orange"
    return "red"

# ---- drawing ------------------------------------------------------------------
def scream_early(st):
    """True once houses are posting real waits before the general 6:30P
    gate. Universal sells a paid "Scream Early" add-on that lets a handful
    of houses open as early as 2P, but that's not on any schedule endpoint
    we can fetch - it's confirmed here straight from the live feed (a house
    actually posting a wait), never assumed from a fixed clock time."""
    if st["state"] != "tonight":
        return False
    for row in st["houses"]:
        if row[0] != None:
            return True
    return False

def meta_for(st):
    """What the chip row says at the right edge, and in what color."""
    s = st["state"]
    if s == "open":
        return ["OPEN TIL " + st["hours"][1], "green"]
    if s == "tonight":
        if scream_early(st):
            return ["SCREAM EARLY", ORANGE]
        return ["GATES " + st["hours"][0], ORANGE]
    if s == "countdown":
        return ["NEXT " + st["date"], PURPLE]
    return ["", DIM]

def offline_page(c, label):
    c.sprite(MANSION_S, ARTX, ARTY, legend = MANSION_LEG)
    chip_row(c, label, OFFLINE, "", DIM)
    c.text("HHN DATA UNREACHABLE", MIDX, 11, font = "5x7", color = "amber",
           align = "center")
    c.text("WAITS RETURN NEXT REFRESH", MIDX, 23, font = "4x5", color = DIM,
           align = "center")

def splash(c, ctx):
    c.fill("black")
    title_card(c)
    # The name sits over the scene between the mansion and the graveyard,
    # in HHN orange. Left-aligned as a block so the three lines share an edge.
    c.text("HALLOWEEN", 48, 4, font = "6x8", color = ORANGE)
    c.text("HORROR NIGHTS", 48, 14, font = "6x8", color = ORANGE)
    c.text("UNIVERSAL ORLANDO", 48, 25, font = "4x5", color = DIM)

def tonight(c, ctx):
    """One big bold answer: is it on tonight?"""
    c.fill("black")
    st = read_hhn(ctx)
    if not st["online"]:
        offline_page(c, "HORROR NIGHTS")
        return
    c.sprite(MANSION_S, ARTX, ARTY, legend = MANSION_LEG)
    meta = meta_for(st)
    chip_row(c, "HORROR NIGHTS", ORANGE, meta[0], meta[1])
    color = STATE_COLOR[st["state"]]

    if st["state"] == "open":
        word, sub = "OPEN NOW", "GATES OPEN TIL " + st["hours"][1]
    elif st["state"] == "tonight":
        if scream_early(st):
            word, sub = "SCREAM EARLY", "GENERAL GATES AT " + st["hours"][0]
        else:
            word, sub = "TONIGHT", "GATES OPEN AT " + st["hours"][0]
    elif st["state"] == "countdown":
        word = str(st["days"]) + (" NIGHT" if st["days"] == 1 else " NIGHTS")
        sub = "TIL OPENING " + st["date"] + " " + st["hours"][0] + "-" + st["hours"][1]
    else:
        word, sub = "OFF SEASON", "SEE YOU NEXT FALL"
    # 10x16_bold fills the band: 16 rows at y 9, then the 4x5 line at y 27.
    # OFF SEASON is 109 px, the widest word, inside the 150 px zone.
    c.text(word, MIDX, 9, font = "10x16_bold", color = color, align = "center")
    c.text(sub, MIDX, 27, font = "4x5", color = DIM, align = "center")

# Five houses to a page in two columns of three rows, each with its minutes
# in a colored pill. The pill is measured first; the name gets what is left.
COLS = 2
ROWS = 3
GAP = 4

def house_row(c, x0, colw, y, w, name):
    mins = (str(w) + "M") if w != None else "--"
    pw = c.text_width(mins, "4x5") + 4
    px = x0 + colw - pw
    if w != None:
        # badge() sizes its pill around the text's own lit pixels, so a
        # dash (almost no vertical ink) would draw a much shorter, oddly
        # placed pill next to a full-height "45M" one - plain text avoids
        # that mismatch and reads as "nothing to highlight yet" anyway.
        col = wait_color(w)
        c.badge(mins, px, y, color = "white" if col == "red" else "black",
                bg = col, font = "4x5")
    else:
        c.text(mins, x0 + colw - c.text_width(mins, "4x5"), y + 1, font = "4x5",
               color = DIM)
    c.text(house_name(c, name, px - 3 - x0), x0, y + 1, font = "4x5", color = INK)

def house_cards(c, ctx, label, lo, hi, which):
    c.fill("black")
    st = read_hhn(ctx)
    if not st["online"]:
        offline_page(c, label)
        return

    page = st["houses"][lo:hi]
    # Show the grid whenever this page actually has a real wait to show -
    # which happens before the general "open" state during Scream Early,
    # when only a few houses are posting. A page with none yet (or a page
    # that's still all Scream Early no-shows) falls through to the messaging
    # below instead of a grid full of dashes.
    has_data = False
    for row in page:
        if row[0] != None:
            has_data = True
            break
    if has_data:
        meta = which + ("  TIL " + st["hours"][1] if st["state"] == "open" else "  SCREAM EARLY")
        chip_row(c, label, ORANGE, meta, DIM)
        colw = (RZ_R - EDGEL + 1 - GAP * (COLS - 1)) // COLS
        c.vline(EDGEL + colw + GAP // 2 - 1, 9, 22, STRUCT)
        for i in range(len(page)):
            col = i // ROWS
            slot = i % ROWS
            x0 = EDGEL + col * (colw + GAP)
            y = 8 + slot * 8
            house_row(c, x0, colw, y, page[i][0], page[i][1])
        return

    # No wait grid to show: keep the mansion, say when the gates open.
    c.sprite(MANSION_S, ARTX, ARTY, legend = MANSION_LEG)
    meta = meta_for(st)
    chip_row(c, label, ORANGE, meta[0], meta[1])
    if st["state"] == "open":
        head = "WAITS POSTING SOON" if lo == 0 else "THAT'S ALL OF THEM"
        sub = "CHECK BACK SHORTLY" if lo == 0 else "SEE PAGE 1"
        head_color = ORANGE
    elif st["state"] == "tonight":
        if scream_early(st):
            # The active Scream Early houses sort to the top and land on
            # page 1, so reaching this branch during Scream Early means
            # this specific page (2) just doesn't have one of them yet.
            head, sub, head_color = "SCREAM EARLY UNDERWAY", "SEE PAGE 1 FOR WAITS", ORANGE
        else:
            head, sub, head_color = "GATES OPEN AT " + st["hours"][0], "WAITS POST AT OPENING", ORANGE
    elif st["state"] == "countdown":
        head, sub, head_color = "NO EVENT TONIGHT", "NEXT NIGHT " + st["date"], PURPLE
    else:
        head, sub, head_color = "HHN RETURNS THIS FALL", "SEE YOU NEXT SEASON", PURPLE
    c.text(head, MIDX, 12, font = "5x7", color = head_color, align = "center")
    c.text(sub, MIDX, 23, font = "4x5", color = DIM, align = "center")

def houses1(c, ctx):
    house_cards(c, ctx, "HAUNTED HOUSES", 0, 5, "1 OF 2")

def houses2(c, ctx):
    house_cards(c, ctx, "MORE HOUSES", 5, 10, "2 OF 2")
