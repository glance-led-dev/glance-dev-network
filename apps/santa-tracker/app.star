# Santa Tracker -- Santa's sleigh on your wall: the countdown to takeoff,
# his Christmas Eve flight live, city by city, and when he reaches your
# house. 192x32 SCROLL, built for kids.
#
# THE YEAR, IN THREE SEASONS (every time is UTC):
#   countdown   Dec 26 / Jan 6 -> Dec 24 10:00   days (then hours) to takeoff,
#               sleeps till Christmas, the elves' daily North Pole report
#   live        Dec 24 10:00 -> Dec 25 11:00     where Santa is now, presents
#               delivered, his next stop, and the countdown to your house
#   home        Dec 25 11:00 -> Jan 5            Santa's back at the North
#               Pole; the final present count; merry Christmas
#
# PAGES
#   sleigh     Santa, his sack of presents and the reindeer (Rudolph leading,
#              nose glowing). The reindeer swap gallop poses each refresh.
#   home       your house and tree: sleeps till Christmas; on Christmas Eve
#              the countdown to Santa reaching where you live; presents under
#              the tree once he has been
#   northpole  an elf at the candy-cane pole: the elves' report and the toy
#              workshop's progress; on Christmas Eve, the journey stop by stop
#
# DATA. Google's Santa Tracker route (keyless): 420 stops, each with its
# arrival and departure, city, region and running presents total. The
# route is timed for one Christmas Eve, so every time is shifted onto this
# year's takeoff. It is only fetched while Santa is flying.

ROUTE_URL = "https://firebasestorage.googleapis.com/v0/b/santa-tracker-firebase.appspot.com/o/route%2Fsanta_en.json?alt=media"
JSON_HEADERS = {
    "Accept": "application/json",
    "User-Agent": "Glance-GDN santa-tracker (github.com/glance-led-dev/glance-dev-network)",
}

TAKEOFF_HOUR = 10          # Dec 24, 10:00 UTC
FLIGHT_SECONDS = 25 * 3600  # back home Dec 25, 11:00 UTC

COLORS = {
    "bg": "#000000",
    "text": "#F4F7FB",
    "label": "#8A93A6",
    "dim": "#4B5563",
    "red": "#FF3B30",
    "green": "#34D058",
    "gold": "#FFC233",
    "snow": "#DCE6F5",
    "sky_star": "#5A6B8C",
    "live": "#FF3B30",
}

# Where you live -> [nearest route stop, standard UTC offset (min), DST].
# The stop is the one closest to the area's largest metro.
AREAS = {
    "ALABAMA": ["montgomery", -360, True],
    "ALASKA": ["anchorage", -540, True],
    "ARIZONA": ["phoenix", -420, False],
    "ARKANSAS": ["fayetteville", -360, True],
    "CALIFORNIA": ["los_angeles", -480, True],
    "COLORADO": ["boulder", -420, True],
    "CONNECTICUT": ["new_haven", -300, True],
    "DELAWARE": ["wilmington", -300, True],
    "DISTRICT OF COLUMBIA": ["washington", -300, True],
    "FLORIDA": ["orlando", -300, True],
    "GEORGIA": ["atlanta", -300, True],
    "HAWAII": ["waipahu", -600, False],
    "IDAHO": ["boise", -420, True],
    "ILLINOIS": ["chicago", -360, True],
    "INDIANA": ["indianapolis", -300, True],
    "IOWA": ["cedar_rapids", -360, True],
    "KANSAS": ["tulsa", -360, True],
    "KENTUCKY": ["louisville", -300, True],
    "LOUISIANA": ["new_orleans", -360, True],
    "MAINE": ["maine", -300, True],
    "MARYLAND": ["baltimore", -300, True],
    "MASSACHUSETTS": ["boston", -300, True],
    "MICHIGAN": ["detroit", -300, True],
    "MINNESOTA": ["minneapolis", -360, True],
    "MISSISSIPPI": ["jackson", -360, True],
    "MISSOURI": ["st_louis", -360, True],
    "MONTANA": ["missoula", -420, True],
    "NEBRASKA": ["lincoln", -360, True],
    "NEVADA": ["las_vegas", -480, True],
    "NEW HAMPSHIRE": ["manchester", -300, True],
    "NEW JERSEY": ["new_york", -300, True],
    "NEW MEXICO": ["roswell", -420, True],
    "NEW YORK": ["new_york", -300, True],
    "NORTH CAROLINA": ["raleigh", -300, True],
    "NORTH DAKOTA": ["fargo", -360, True],
    "OHIO": ["columbus", -300, True],
    "OKLAHOMA": ["tulsa", -360, True],
    "OREGON": ["portland", -480, True],
    "PENNSYLVANIA": ["wilmington", -300, True],
    "RHODE ISLAND": ["newport", -300, True],
    "SOUTH CAROLINA": ["charleston", -300, True],
    "SOUTH DAKOTA": ["sioux_falls", -360, True],
    "TENNESSEE": ["nashville", -360, True],
    "TEXAS": ["dallas", -360, True],
    "UTAH": ["salt_lake_city", -420, True],
    "VERMONT": ["burlington", -300, True],
    "VIRGINIA": ["newport_news", -300, True],
    "WASHINGTON": ["seattle", -480, True],
    "WEST VIRGINIA": ["charleston_wv", -300, True],
    "WISCONSIN": ["milwaukee", -360, True],
    "WYOMING": ["laramie", -420, True],
    "ALBERTA": ["calgary", -420, True],
    "BRITISH COLUMBIA": ["vancouver", -480, True],
    "MANITOBA": ["winnipeg", -360, True],
    "NEW BRUNSWICK": ["st_john", -240, True],
    "NEWFOUNDLAND AND LABRADOR": ["grand_falls-windsor", -210, True],
    "NORTHWEST TERRITORIES": ["echo_bay", -420, True],
    "NOVA SCOTIA": ["dartmouth", -240, True],
    "NUNAVUT": ["iqaluit", -300, True],
    "ONTARIO": ["toronto", -300, True],
    "PRINCE EDWARD ISLAND": ["charlottetown", -240, True],
    "QUEBEC": ["montreal", -300, True],
    "SASKATCHEWAN": ["saskatoon", -360, False],
    "YUKON": ["sitka", -420, False],
}

# The route spells cities in their own languages; the panel fonts are A-Z.
FOLD = {
    "á": "A", "à": "A", "â": "A", "ä": "A", "ã": "A", "å": "A", "ā": "A",
    "é": "E", "è": "E", "ê": "E", "ë": "E", "ē": "E",
    "í": "I", "ì": "I", "î": "I", "ï": "I", "ī": "I", "İ": "I", "ı": "I",
    "ó": "O", "ò": "O", "ô": "O", "ö": "O", "õ": "O", "ø": "O", "ō": "O",
    "ú": "U", "ù": "U", "û": "U", "ü": "U", "ū": "U",
    "ç": "C", "Ç": "C", "ş": "S", "Ş": "S", "ñ": "N", "ğ": "G", "ž": "Z", "š": "S",
    "ʻ": "", "‘": "", "’": "'",
}

# The elves' report, a new line each hour before Christmas Eve.
ELF_REPORT = [
    ["ELVES", "WRAPPING PRESENTS"],
    ["REINDEER", "FLIGHT PRACTICE"],
    ["RUDOLPH'S NOSE", "FULLY CHARGED"],
    ["NICE LIST", "CHECKED TWICE"],
    ["THE SLEIGH", "GETTING POLISHED"],
    ["MRS. CLAUS", "BAKING COOKIES"],
    ["THE WORKSHOP", "HAMMERS HUMMING"],
    ["LETTERS TO SANTA", "BEING READ"],
    ["SANTA'S MAP", "PLANNING THE ROUTE"],
    ["THE TOY SACK", "BEING PACKED"],
    ["SANTA'S SUIT", "FRESHLY PRESSED"],
    ["THE REINDEER", "EATING CARROTS"],
]

# ---- sprites ---------------------------------------------------------------
# Shaded in three tones (highlight, base, shadow) with glows on the lights.
# Frames are stills; the only change between refreshes is the reindeer's
# gallop pose, and each pose is a complete picture on its own.

SANTA = """
.Ww...........
wWW..hhR......
.w..hRRRRr....
...hRRRRRRr...
..WWWWWWWWWw..
...FFFFFKFF...
...FcFFFFFnF..
..wWWWWWWWWW..
.hRWWWWWWWWRR.
hRRRwWWWWWRRMM
RRRRRwWWWRRRMM
RRRRRRwWRRRRr.
bbbbbbgbbbbbb.
"""
SANTA_LEGEND = {
    "R": "#E0261C", "r": "#A3150F", "h": "#FF5A4A",
    "W": "#FFFFFF", "w": "#C9D3DF",
    "F": "#F6C7A1", "c": "#F08A7A", "K": "#1A1A1A", "n": "#E8907E",
    "M": "#2F6B2F", "b": "#2A2A2A", "g": "#FFD45A",
}

# The sack: a wrapped present and a teddy bear peeking out.
SACK = """
....Y...TT.T.
.BBBYBB.TTTT.
.BBBYBB.TKTK.
.bBBYBb..TTT.
.SSSSSSSSSS..
SSsSSSSSSSSs.
sSSSSSSSSSss.
"""
SACK_LEGEND = {
    "Y": "#FFD45A", "B": "#3B82F6", "b": "#1E40AF",
    "T": "#B9773F", "K": "#2A1A0E",
    "S": "#B07A45", "s": "#7A4F28",
}

SLEIGH = """
GG..........................gG..
hRG........................gRRG.
hRRGGGGGGGGGGGGGGGGGGGGGGGGgRRG.
hRRRRRRRRRRRRRRRRRRRRRRRRRRRRG..
hRRRRRRRRRRRRRRRRRRRRRRRRRRRG...
.rRRRRRgGgRRRRRRRRRgGgRRRRRG....
..rrrrrrrrrrrrrrrrrrrrrrrrG.....
....g.........g.........g.......
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGgG.
..............................gG
"""
SLEIGH_LEGEND = {
    "G": "#FFD45A", "g": "#C98E1E",
    "R": "#D42A20", "r": "#8C140E", "h": "#FF5A4A",
}

DEER = ["""
...........a...a..
..........aA..aA..
...........AaAA...
............AA....
...........HHHH...
...........HKHHHH.
...........hHHHHHN
..t.......CCHHh...
.tTBBBBBBBCgBH....
tTBBBBBBBBCBB.....
.bBBBBBBBBBBB.....
..bbcccccccbb.....
..bB.Bb...bB.Bb...
.bB...Bb.bB...Bb..
.k.....k.k.....k..
""", """
...........a...a..
..........aA..aA..
...........AaAA...
............AA....
...........HHHH...
...........HKHHHH.
...........hHHHHHN
..t.......CCHHh...
.tTBBBBBBBCgBH....
tTBBBBBBBBCBB.....
.bBBBBBBBBBBB.....
..bbcccccccbb.....
...bBB....bBB.....
...b.Bb...b.Bb....
...k..k...k..k....
"""]
DEER_LEGEND = {
    "a": "#B89664", "A": "#E9CF9E",
    "H": "#9A5E2E", "h": "#6A3B1A", "K": "#111111", "N": "#2A1A0E",
    "C": "#D42A20", "g": "#FFD45A",
    "B": "#8E5528", "b": "#5E3519", "T": "#F4ECDD", "t": "#CFC2AA",
    "c": "#D8B98F", "k": "#2A1A0E",
}
RUDOLPH_LEGEND = dict(DEER_LEGEND, N = "#FF2A2A")

MOON = """
..mMM..
.mMMMM.
mMMd...
mMM....
mMMd...
.mMMMM.
..mMM..
"""
MOON_LEGEND = {"M": "#F5E7B0", "m": "#C9B97E", "d": "#D8C98E"}

# A log cabin: snowy roof, string lights, icicles, lit windows, wreath,
# chimney smoke.
HOUSE = """
...............ss..........
..............s..s.........
.............s.............
................CC..........
................CC..........
.........SSSSSSSWWS........
.......SSSSSSSSSSSSSS......
.....SSSSSSSSSSSSSSSSSS....
...SSSSSSSSSSSSSSSSSSSSSS..
..sSSSSSSSSSSSSSSSSSSSSSSs.
..LrLgLbLyLrLgLbLyLrLgLbLy.
..i.i..i...i..i...i.i..i...
...PPPPPPPPPPPPPPPPPPPPP...
...ppppppppppppppppppppp...
...PwwwwPPPPeGePPPPwwwwP...
...PwOOwPPPGrRrGPPPwOOwP...
...PwwwwPPPPGeGPPPPwwwwP...
...PwOOwPPPPDDDPPPPwOOwP...
...PwwwwPPPPDDkPPPPwwwwP...
...ppppppppPDDDPpppppppp...
"""
HOUSE_LEGEND = {
    "s": "#8A93A6", "C": "#A33A2A",
    "S": "#FFFFFF", "W": "#FFFFFF",
    "L": "#3A2A1A", "r": "#FF3B30", "g": "#34D058", "b": "#4A8BFF", "y": "#FFD54A",
    "i": "#9FD3FF",
    "P": "#9A6A42", "p": "#6E4A2C",
    "w": "#5A3A20", "O": "#FFD54A",
    "G": "#1F9D4A", "e": "#2FB35A", "R": "#FF3B30",
    "D": "#C0392B", "k": "#FFD54A",
}
# Once Santa has been, everyone's asleep: windows dark, lights dimmed.
HOUSE_ASLEEP = dict(HOUSE_LEGEND, O = "#2A3550", r = "#7A1D18", g = "#1A6A2C", b = "#25467F", y = "#7F6A25")

TREE = """
......y......
.....yYy.....
......y......
.....gGg.....
....gGGGd....
.....GrG.....
....gGGGGd...
...gGbGGGGd..
....GGGyGd...
...gGGGGGGd..
..gGyGGGrGGd.
...GGGGGGGd..
..gGrGGGbGGd.
.gGGGGGyGGGGd
......t......
......t......
"""
TREE_LEGEND = {
    "y": "#7F6A25", "Y": "#FFE27A",
    "g": "#3FCB6A", "G": "#1F9D4A", "d": "#12592B",
    "r": "#FF3B30", "b": "#4A8BFF",
    "t": "#7A4F28",
}

PRESENTS = """
.Y.......Y...
RYR..g..BYB..
RYR.GYG.BYB..
rYr.GYG.bYb..
"""
PRESENTS_LEGEND = {"Y": "#FFD54A", "R": "#FF3B30", "r": "#B3221B", "B": "#4A8BFF", "b": "#2A5AC0",
                "G": "#34D058", "g": "#FFD54A", "P": "#C026D3"}

ELF = """
........Y..
.......GG..
......GGG..
....gGGGG..
...gGGGGG..
..RRRRRRR..
.EFFFFFFFE.
..FKFFFKF..
..FcFFFcF..
...FFmFF...
..gGGGGGg..
.FgGGYGGgF.
..gGGGGGg..
...Rw.wR...
...wR.Rw...
..GGG.GGG..
.G.......G.
"""
ELF_LEGEND = {
    "Y": "#FFD45A", "G": "#2FB35A", "g": "#1E8A44",
    "R": "#E0261C", "w": "#FFFFFF",
    "F": "#F6C7A1", "E": "#E9A982", "K": "#1A1A1A", "c": "#F08A7A", "m": "#B3221B",
}

PRESENT_ICON = """
.Y.Y.
RRYRR
RRYRR
rrYrr
"""
PRESENT_ICON_LEGEND = {"Y": "#FFD54A", "R": "#FF3B30", "r": "#B3221B"}

LEFT = 10
RIGHT = 181


# ---- helpers ---------------------------------------------------------------

def get_json(url, ttl):
    resp = http.get(url, headers = JSON_HEADERS, ttl_seconds = ttl)
    return resp["json"] if resp["status_code"] == 200 else None


def clip(c, text, font, max_w):
    text = str(text)
    for _i in range(64):
        if len(text) <= 1 or c.text_width(text, font) <= max_w:
            break
        text = text[:len(text) - 1]
    return text.strip()


def clip_words(c, text, font, max_w):
    words = [w for w in str(text).split(" ") if w != ""]
    for n in range(len(words), 0, -1):
        trial = " ".join(words[:n]).rstrip(":,-")
        if c.text_width(trial, font) <= max_w:
            return trial
    return clip(c, text, font, max_w)


def fold(text):
    out = ""
    for ch in str(text).elems():
        if ch in FOLD:
            out += FOLD[ch]
        elif ord(ch) < 128:
            out += ch
    return out.upper()


def commas(n):
    s = str(int(n))
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return out


def pad2(n):
    return ("0" if n < 10 else "") + str(n)


def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil_from_days(z):
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return [y, m, d]


def nth_sunday(y, m, n):
    # Day number of the nth Sunday of a month.
    first = days_from_civil(y, m, 1)
    return first + (7 - (first + 4) % 7) % 7 + (n - 1) * 7


def local_offset(unix, area):
    # UTC offset in seconds for the area (US/Canada daylight saving rule:
    # 2nd Sunday of March to 1st Sunday of November, at 2am local).
    a = AREAS.get(area)
    std = (a[1] if a != None else -300) * 60
    if a != None and not a[2]:
        return std
    y = civil_from_days(unix // 86400)[0]
    start = nth_sunday(y, 3, 2) * 86400 + 7200 - std
    end = nth_sunday(y, 11, 1) * 86400 + 7200 - (std + 3600)
    return std + 3600 if unix >= start and unix < end else std


def hm(secs):
    secs = max(0, secs)
    mins = (secs + 59) // 60
    if mins < 60:
        return str(mins) + " MIN"
    return str(mins // 60) + "H " + pad2(mins % 60) + "M"


# ---- the season -------------------------------------------------------------

def takeoff_for(year):
    return days_from_civil(year, 12, 24) * 86400 + TAKEOFF_HOUR * 3600


def season(now):
    # ["countdown" | "live" | "home", takeoff unix for the relevant Christmas]
    ymd = civil_from_days(now // 86400)
    t = takeoff_for(ymd[0])
    if ymd[1] == 1 and ymd[2] <= 5:
        return ["home", takeoff_for(ymd[0] - 1)]
    if now < t:
        return ["countdown", t]
    if now < t + FLIGHT_SECONDS:
        return ["live", t]
    return ["home", t]


def load_route(takeoff):
    # The stops, with times shifted onto this year's takeoff.
    data = get_json(ROUTE_URL, 21600)
    stops = (data or {}).get("destinations") if type(data) == "dict" else None
    if stops == None or len(stops) < 3:
        return None
    shift = takeoff - int(stops[0]["departure"]) // 1000
    out = []
    for s in stops:
        out.append({
            "id": str(s.get("id") or ""),
            "city": fold(s.get("city") or ""),
            "region": fold(s.get("region") or ""),
            "arrive": int(s.get("arrival") or 0) // 1000 + shift,
            "depart": int(s.get("departure") or 0) // 1000 + shift,
            "presents": int(s.get("presentsDelivered") or 0),
        })
    return out


def position(stops, now):
    # [index of the last stop reached, True if Santa is there right now]
    last = 0
    for i in range(len(stops)):
        if stops[i]["arrive"] <= now:
            last = i
        else:
            break
    return [last, now < stops[last]["depart"]]


def presents_now(stops, now):
    # The running total, counted up smoothly between stops.
    p = position(stops, now)
    i = p[0]
    if p[1] or i + 1 >= len(stops):
        return stops[i]["presents"]
    a = stops[i]
    b = stops[i + 1]
    span = max(1, b["arrive"] - a["depart"])
    done = max(0, now - a["depart"])
    return a["presents"] + (b["presents"] - a["presents"]) * done // span


def short_region(c, region, font, max_w):
    # "NEW YORK, NY, USA" -> as is if it fits, else the last part ("USA").
    if c.text_width(region, font) <= max_w:
        return region
    parts = [p.strip() for p in region.split(",")]
    return clip_words(c, parts[len(parts) - 1], font, max_w)


# ---- inputs -------------------------------------------------------------------

def names_input(ctx):
    n = str(ctx.inputs.get("names", "NONE")).strip().upper()
    if n == "" or n in ["NONE", "N/A", "NA", "-"]:
        return ""
    return fold(n)


def area_input(ctx):
    a = str(ctx.inputs.get("home", "NONE")).strip().upper()
    return a if a in AREAS else ""


# ---- shared drawing -------------------------------------------------------------

def twinkle(c, now, spots):
    # A few stars; each refresh lights a different half.
    flip = (now // 300) % 2
    for i in range(len(spots)):
        s = spots[i]
        on = (i + flip) % 2 == 0
        c.pixel(s[0], s[1], COLORS["text"] if on else COLORS["sky_star"])
        if on and i % 3 == 0:
            for d in [[-1, 0], [1, 0], [0, -1], [0, 1]]:
                c.pixel(s[0] + d[0], s[1] + d[1], COLORS["sky_star"])


def draw_team(c, x, y, frame):
    # The moon, Santa in his sleigh with the sack, and the reindeer team;
    # Rudolph leads, nose aglow.
    c.sprite(MOON, x + 36, y, legend = MOON_LEGEND)
    c.sprite(SACK, x + 1, y + 5, legend = SACK_LEGEND)
    c.sprite(SANTA, x + 9, y + 1, legend = SANTA_LEGEND)
    c.sprite(SLEIGH, x, y + 11, legend = SLEIGH_LEGEND)
    deer = DEER[frame % 2]
    c.line(x + 30, y + 13, x + 43, y + 15, "#C98E1E")
    c.line(x + 50, y + 13, x + 60, y + 13, "#C98E1E")
    c.sprite(deer, x + 33, y + 6, legend = DEER_LEGEND)
    c.sprite(deer, x + 52, y + 4, legend = RUDOLPH_LEGEND)
    nx = x + 69
    ny = y + 10
    for d in [[-1, 0], [1, 0], [0, -1], [0, 1]]:
        c.pixel(nx + d[0], ny + d[1], "#8A1010")
    for d in [[1, -1], [1, 1], [2, 0]]:
        c.pixel(nx + d[0], ny + d[1], "#4A0808")
    c.pixel(nx, ny, "#FF6A5A")


def draw_pole(c, x, y, h):
    # A 5px candy cane: highlight edge, stripes, shadow edge; gold ball on top.
    c.fill_circle(x + 2, y + 2, 2, COLORS["gold"])
    c.pixel(x + 1, y + 1, "#FFF3B0")
    for r in range(h):
        for col in range(5):
            red = (r + col) % 6 < 3
            px = "#E0261C" if red else "#FFFFFF"
            if col == 0:
                px = "#FF6A5A" if red else "#FFFFFF"
            if col == 4:
                px = "#8C140E" if red else "#A9B4C2"
            c.pixel(x + col, y + 5 + r, px)


def big_line(c, x, y, number, unit, color):
    # A big number in 10x16 with its unit beside it in 6x8.
    c.text(number, x, y, font = "10x16", color = color)
    w = c.text_width(number, "10x16")
    if unit != "":
        c.text(unit, x + w + 4, y + 8, font = "6x8", color = color)


def text_fit(c, text, x, y, max_w, fonts, color):
    # The biggest font in the list that fits; apostrophes skip 6x8.
    for f in fonts:
        if f == "6x8" and "'" in text:
            continue
        if c.text_width(text, f) <= max_w:
            c.text(text, x, y + (1 if f == "5x7" and fonts[0] == "6x8" else 0), font = f, color = color)
            return f
    f = fonts[len(fonts) - 1]
    c.text(clip_words(c, text, f, max_w), x, y, font = f, color = color)
    return f


def live_header(c, x, label):
    c.fill_circle(x + 2, 3, 2, COLORS["live"])
    c.text("LIVE", x + 7, 1, font = "4x5", color = COLORS["live"])
    c.text(label, x + 7 + c.text_width("LIVE", "4x5") + 4, 1, font = "4x5", color = COLORS["label"])


# ---- page 1: the sleigh ------------------------------------------------------------

SKY = [[12, 2], [31, 3], [58, 1], [76, 3], [64, 29], [22, 30], [44, 29], [81, 26]]


def sleigh(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    s = season(now)
    frame = (now // 300) % 2
    twinkle(c, now, SKY)
    draw_team(c, LEFT, 5, frame)
    x = LEFT + 76
    room = RIGHT - x

    if s[0] == "countdown":
        left = s[1] - now
        c.text("SANTA TAKES OFF IN", x, 1, font = "4x5", color = COLORS["label"])
        if left >= 86400:
            days = (left + 86399) // 86400
            big_line(c, x, 8, str(days), "DAY" if days == 1 else "DAYS", COLORS["text"])
        else:
            c.text(hm(left), x, 8, font = "10x16", color = COLORS["gold"])
        c.text(clip_words(c, "FROM THE NORTH POLE", "4x5", room), x, 26, font = "4x5", color = COLORS["green"])
        return

    stops = load_route(s[1])
    if s[0] == "home":
        c.text("MERRY CHRISTMAS!", x, 1, font = "4x5", color = COLORS["red"])
        text_fit(c, "SANTA IS HOME", x, 8, room, ["6x8", "5x7"], COLORS["text"])
        c.text("PRESENTS DELIVERED", x, 18, font = "4x5", color = COLORS["label"])
        total = stops[len(stops) - 1]["presents"] if stops != None else 0
        if total > 0:
            c.sprite(PRESENT_ICON, x, 25, legend = PRESENT_ICON_LEGEND)
            c.text(commas(total), x + 8, 25, font = "5x7", color = COLORS["gold"])
        else:
            c.text("BILLIONS!", x, 25, font = "5x7", color = COLORS["gold"])
        return

    # Live: where Santa is right now.
    if stops == None:
        live_header(c, x, "CHRISTMAS EVE")
        text_fit(c, "SANTA IS FLYING!", x, 9, room, ["6x8", "5x7"], COLORS["text"])
        c.text(clip_words(c, "DELIVERING PRESENTS AROUND THE WORLD", "4x5", room), x, 20, font = "4x5", color = COLORS["green"])
        return
    p = position(stops, now)
    i = p[0]
    here = p[1] or i + 1 >= len(stops)
    st = stops[i] if here else stops[i + 1]
    if i == 0 and here:
        live_header(c, x, "TAKING OFF")
    else:
        live_header(c, x, "SANTA IS IN" if here else "FLYING TO")
    text_fit(c, st["city"], x, 8, room, ["6x8", "5x7", "4x5"], COLORS["text"])
    c.text(short_region(c, st["region"], "4x5", room), x, 17, font = "4x5", color = COLORS["green"])
    c.sprite(PRESENT_ICON, x, 25, legend = PRESENT_ICON_LEGEND)
    c.text(commas(presents_now(stops, now)), x + 8, 25, font = "5x7", color = COLORS["gold"])


# ---- page 2: your house ---------------------------------------------------------------

def draw_house(c, visited):
    c.sprite(HOUSE, LEFT - 2, 10, legend = HOUSE_ASLEEP if visited else HOUSE_LEGEND)
    c.sprite(TREE, LEFT + 26, 14, legend = TREE_LEGEND)
    c.rect(LEFT, 30, LEFT + 39, 30, fill = COLORS["snow"])
    c.rect(LEFT + 2, 31, LEFT + 37, 31, fill = "#8A93A6")
    if visited:
        c.sprite(PRESENTS, LEFT + 26, 26, legend = PRESENTS_LEGEND)


def greeting(names):
    return "HI " + names + "!" if names != "" else "HO HO HO!"


def home(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    s = season(now)
    names = names_input(ctx)
    area = area_input(ctx)
    x = LEFT + 46
    room = RIGHT - x
    twinkle(c, now, [[LEFT + 2, 3], [LEFT + 34, 2], [LEFT + 8, 8], [LEFT + 40, 9]])

    if s[0] == "countdown":
        draw_house(c, False)
        local = now + local_offset(now, area)
        today = local // 86400
        ymd = civil_from_days(today)
        xmas = days_from_civil(ymd[0], 12, 25)
        sleeps = xmas - today
        c.text(clip_words(c, greeting(names), "4x5", room), x, 1, font = "4x5", color = COLORS["gold"])
        if sleeps <= 1:
            text_fit(c, "TONIGHT'S THE NIGHT!", x, 9, room, ["5x7", "4x5"], COLORS["text"])
            c.text(clip_words(c, "SANTA IS ON HIS WAY", "4x5", room), x, 20, font = "4x5", color = COLORS["green"])
            return
        big_line(c, x, 8, str(sleeps), "SLEEPS", COLORS["text"])
        c.text("TILL CHRISTMAS", x, 26, font = "4x5", color = COLORS["red"])
        return

    if s[0] == "home":
        draw_house(c, True)
        c.text(clip_words(c, greeting(names), "4x5", room), x, 1, font = "4x5", color = COLORS["gold"])
        text_fit(c, "MERRY CHRISTMAS!", x, 9, room, ["6x8", "5x7"], COLORS["red"])
        c.text(clip_words(c, "SANTA HAS BEEN!", "4x5", room), x, 20, font = "4x5", color = COLORS["green"])
        return

    # Live: when does Santa reach us?
    stops = load_route(s[1])
    target = None
    label = area if area != "" else "NORTH AMERICA"
    if stops != None:
        for st in stops:
            if area != "" and st["id"] == AREAS[area][0]:
                target = st
                break
            if area == "" and (st["region"].endswith("USA") or st["region"].endswith("CANADA") or st["region"].endswith("UNITED STATES")):
                target = st
                break
    if target == None:
        draw_house(c, False)
        c.text(clip_words(c, greeting(names), "4x5", room), x, 1, font = "4x5", color = COLORS["gold"])
        text_fit(c, "SANTA IS COMING!", x, 9, room, ["6x8", "5x7"], COLORS["text"])
        c.text(clip_words(c, "GET TO BED EARLY TONIGHT", "4x5", room), x, 20, font = "4x5", color = COLORS["green"])
        return

    left = target["arrive"] - now
    if left <= 0:
        draw_house(c, True)
        c.text(clip_words(c, greeting(names), "4x5", room), x, 1, font = "4x5", color = COLORS["gold"])
        text_fit(c, "SANTA HAS BEEN", x, 8, room, ["6x8", "5x7"], COLORS["text"])
        text_fit(c, "TO " + label + "!", x, 17, room, ["5x7", "4x5"], COLORS["green"])
        c.text(clip_words(c, "CHECK UNDER THE TREE", "4x5", room), x, 26, font = "4x5", color = COLORS["gold"])
        return
    draw_house(c, False)
    c.text(clip_words(c, "SANTA REACHES " + label + " IN", "4x5", room), x, 1, font = "4x5", color = COLORS["label"])
    c.text(hm(left), x, 8, font = "10x16", color = COLORS["gold"])
    if left <= 3600:
        bed = ("TIME FOR BED, " + names + "!") if names != "" else "TIME FOR BED!"
        c.text(clip_words(c, bed, "4x5", room), x, 26, font = "4x5", color = COLORS["red"])
    else:
        p = position(stops, now)
        c.text(clip_words(c, "HE'S OVER " + stops[p[0]]["city"], "4x5", room), x, 26, font = "4x5", color = COLORS["green"])


# ---- page 3: the North Pole ------------------------------------------------------------

def progress(c, x, y, w, frac_num, frac_den, color):
    c.rect(x, y, x + w - 1, y + 4, outline = COLORS["dim"])
    fill = (w - 2) * frac_num // max(1, frac_den)
    if fill > 0:
        c.rect(x + 1, y + 1, x + fill, y + 3, fill = color)


def toys_meter(c, x, room, pct):
    label = "TOYS READY"
    lw = c.text_width(label, "4x5")
    pw = c.text_width("99%", "4x5")
    c.text(label, x, 25, font = "4x5", color = COLORS["label"])
    progress(c, x + lw + 4, 25, room - lw - pw - 8, pct, 100, COLORS["red"])
    c.text(str(pct) + "%", RIGHT, 25, font = "4x5", color = COLORS["text"], align = "right")


def northpole(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    s = season(now)
    draw_pole(c, LEFT, 1, 26)
    c.sprite(ELF, LEFT + 6, 14, legend = ELF_LEGEND)
    x = LEFT + 21
    room = RIGHT - x

    if s[0] == "countdown":
        c.text("NORTH POLE REPORT", x, 1, font = "4x5", color = COLORS["gold"])
        item = ELF_REPORT[(now // 3600) % len(ELF_REPORT)]
        text_fit(c, item[0], x, 8, room, ["6x8", "5x7"], COLORS["text"])
        c.text(clip_words(c, item[1], "4x5", room), x, 17, font = "4x5", color = COLORS["green"])
        # Toys ready: the year since last Christmas, as a workshop meter.
        last = takeoff_for(civil_from_days(s[1] // 86400)[0] - 1) + FLIGHT_SECONDS
        done = now - last
        span = s[1] - last
        toys_meter(c, x, room, min(99, max(1, done * 100 // max(1, span))))
        return

    if s[0] == "home":
        c.text("NORTH POLE REPORT", x, 1, font = "4x5", color = COLORS["gold"])
        text_fit(c, "ELVES ARE SLEEPING", x, 8, room, ["6x8", "5x7"], COLORS["text"])
        c.text(clip_words(c, "ZZZ... SEE YOU NEXT CHRISTMAS", "4x5", room), x, 18, font = "4x5", color = COLORS["green"])
        toys_meter(c, x, room, 0)
        return

    stops = load_route(s[1])
    if stops == None:
        c.text("SANTA'S JOURNEY", x, 1, font = "4x5", color = COLORS["gold"])
        text_fit(c, "ON HIS WAY!", x, 9, room, ["6x8", "5x7"], COLORS["text"])
        c.text(clip_words(c, "THE ELVES ARE CHEERING HIM ON", "4x5", room), x, 20, font = "4x5", color = COLORS["green"])
        return
    total = len(stops) - 2  # takeoff and landing are the North Pole
    p = position(stops, now)
    done = min(total, max(0, p[0]))
    c.text("SANTA'S JOURNEY", x, 1, font = "4x5", color = COLORS["gold"])
    text_fit(c, "STOP " + commas(done) + " OF " + commas(total), x, 8, room, ["6x8", "5x7"], COLORS["text"])
    progress(c, x, 17, room, done, total, COLORS["green"])
    if p[0] + 1 < len(stops):
        nxt = stops[p[0] + 1]
        when = hm(nxt["arrive"] - now)
        ww = c.text_width(when, "4x5")
        c.text("NEXT", x, 25, font = "4x5", color = COLORS["label"])
        c.text(when, RIGHT, 25, font = "4x5", color = COLORS["gold"], align = "right")
        nx = x + c.text_width("NEXT", "4x5") + 4
        c.text(clip_words(c, nxt["city"], "4x5", RIGHT - ww - 5 - nx), nx, 25, font = "4x5", color = COLORS["text"])
