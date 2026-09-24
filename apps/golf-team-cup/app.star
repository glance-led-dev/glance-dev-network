# Golf Team Cup (192x32) -- the Presidents Cup and the Ryder Cup, live.
#
# DESIGN. A broadcast score bug on a black ground. Page 1 is the hero: each
# side's pixel crest and big points total, the cup / session / live state in
# the middle, and a tug-of-war bar along the bottom -- each team's points fill
# in from its own end, and the gold gate in the middle is the winning line
# (first bar through it takes the cup). Pages 2-3 are the match board for the
# session that matters right now: one row per match, the leading side lit and
# the trailing side dimmed, with a status pill in the leader's colour.
#
#   DURING A CUP                     BETWEEN CUPS
#   1 cup     hero scoreboard        1 cup     countdown to the next cup
#   2 board1  matches, first half    2 board1  last cup's final score
#   3 board2  matches, second half   3 board2  roll of honour
#
# Data: ESPN's public golf API, no key. The PGA scoreboard says whether a cup
# is on this week; the leaderboard for that event carries the team points and
# every match (competitions[0][0] = the cup, competitions[1..] = one list of
# matches per session). Between cups the next dates and the older results come
# from small tables below; the most recent cup's final is re-read from ESPN.
#
# Every page keeps EDGE (4 px) clear on both sides so the app doesn't merge
# into its neighbours in the scroll stream.

EDGE = 4

SCOREBOARD_URL = "https://site.api.espn.com/apis/site/v2/sports/golf/pga/scoreboard"
LEADERBOARD_URL = "https://site.web.api.espn.com/apis/site/v2/sports/golf/leaderboard"

# ---------- palette ----------

BG = "#000000"
WHITE = "#F4F6FA"
SOFT = "#C3CBD8"
MUTED = "#7A8497"
DIM = "#4A5264"
LINE = "#232A36"
GOLD = "#FFC21A"
LIVE_RED = "#FF3344"

# Team identity: pri = pill / bar / tag colour (LED-bright), txt = text on
# pri, wash = the dark tint behind the team's half of the hero.
TEAMS = {
    "USA": {"name": "USA", "pri": "#E3202E", "txt": "#FFFFFF", "wash": "#2A0508"},
    "INTL": {"name": "INTL", "pri": "#6A36E6", "txt": "#FFFFFF", "wash": "#150A33"},
    "EUR": {"name": "EUROPE", "pri": "#1E50E6", "txt": "#FFFFFF", "wash": "#061233"},
}
UNKNOWN_TEAM = {"name": "TEAM", "pri": "#5A6272", "txt": "#FFFFFF", "wash": "#10131A"}

def team(abbr):
    return TEAMS.get(abbr, UNKNOWN_TEAM)

# ---------- pixel art ----------
# 13x16 crests, drawn with c.sprite. "." is empty.

CREST_USA = """
NNNNNNNNNNNNN
NWNNWNNWNNWNN
NNNWNNWNNWNWN
NWNNWNNWNNWNN
NNNNNNNNNNNNN
RWRWRWRWRWRWR
RWRWRWRWRWRWR
RWRWRWRWRWRWR
RWRWRWRWRWRWR
RWRWRWRWRWRWR
RWRWRWRWRWRWR
.WRWRWRWRWRW.
.WRWRWRWRWRW.
..RWRWRWRWR..
...WRWRWRW...
.....RWR.....
"""
CREST_USA_LEGEND = {"N": "#2346C8", "W": "#FFFFFF", "R": "#E3202E"}

CREST_INTL = """
GGGGGGGGGGGGG
GPPPPPPPPPPPG
GPPPPPYPPPPPG
GPPPPPYPPPPPG
GPPPPYYYPPPPG
GYYYYYYYYYYYG
GPYYYYYYYYYPG
GPPYYYYYYYPPG
GPPPYYYYYPPPG
GPPPYYPYYPPPG
GPPYYPPPYYPPG
.GPYPPPPPYPG.
.GPPPPPPPPPG.
..GPPPPPPPG..
...GGPPPGG...
.....GGG.....
"""
CREST_INTL_LEGEND = {"G": "#FFC21A", "P": "#5424C8", "Y": "#FFD84A"}

CREST_EUR = """
GGGGGGGGGGGGG
GBBBBBBBBBBBG
GBBBBYBYBBBBG
GBBYBBBBBYBBG
GBBBBBBBBBBBG
GBYBBBBBBBYBG
GBBBBBBBBBBBG
GBYBBBBBBBYBG
GBBBBBBBBBBBG
GBBYBBBBBYBBG
GBBBBYBYBBBBG
.GBBBBBBBBBG.
.GBBBBBBBBBG.
..GBBBBBBBG..
...GGBBBGG...
.....GGG.....
"""
CREST_EUR_LEGEND = {"G": "#FFC21A", "B": "#1840C8", "Y": "#FFD84A"}

CREST_W = 13
CREST_H = 16

def draw_crest(c, abbr, x, y):
    if abbr == "USA":
        c.sprite(CREST_USA, x, y, legend = CREST_USA_LEGEND)
    elif abbr == "INTL":
        c.sprite(CREST_INTL, x, y, legend = CREST_INTL_LEGEND)
    elif abbr == "EUR":
        c.sprite(CREST_EUR, x, y, legend = CREST_EUR_LEGEND)
    else:
        c.rect(x, y, x + CREST_W - 1, y + CREST_H - 5, fill = UNKNOWN_TEAM["pri"])

TROPHY = """
.GGGGGGG.
GGWGGGGGG
G.GGGGG.G
G.GGGGG.G
.GGGGGGG.
..GGGGG..
...GGG...
....G....
....G....
..DDDDD..
..DDDDD..
"""
TROPHY_LEGEND = {"G": "#FFC21A", "W": "#FFF1B8", "D": "#8A6A10"}

# Bitmap fonts have no "1/2" glyph, and cup scores live on half points, so
# the fraction is hand-drawn at the two sizes the app uses.
# HALF_BIG sits beside 16x20_bold digits (top-aligned, 20 px tall).
HALF_BIG = """
.XX......
XXX....XX
.XX...XX.
.XX..XX..
.XX.XX...
XXXXX....
...XX....
..XX.XXX.
.XX.XX.XX
XX....XX.
X....XX..
....XXXXX
"""
HALF_BIG_W = 9

# HALF_SMALL sits beside 5x7 digits (7 px tall).
HALF_SMALL = """
X...X
X..X.
X.X..
.X.XX
X...X
...X.
..XXX
"""
HALF_SMALL_W = 5

# ---------- text helpers ----------

ASCII_FOLD = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A", "Æ": "AE",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O", "Ø": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
    "Ç": "C", "Ñ": "N", "Ý": "Y", "ß": "SS",
    "’": "'", "‘": "'",
}

def up(s):
    t = str(s).upper()
    for k, v in ASCII_FOLD.items():
        t = t.replace(k, v)
    return t

def fit_text(c, text, font, max_w):
    if text == "" or c.text_width(text, font) <= max_w:
        return text
    for n in range(len(text) - 1, 0, -1):
        cand = text[:n].rstrip(" -/")
        if c.text_width(cand, font) <= max_w:
            return cand
    return ""

# Largest font first; within a font, the fullest wording that fits.
def fit_ladder(c, variants, fonts, max_w):
    for f in fonts:
        for v in variants:
            if c.text_width(v, f) <= max_w:
                return v, f
    f = fonts[len(fonts) - 1]
    return fit_text(c, variants[len(variants) - 1], f, max_w), f

# Lit glyph height per font, so rows that mix fonts can share a bottom edge.
FONT_H = {"16x20_bold": 20, "11x14_bold": 14, "6x8": 8, "5x7": 7, "3x7": 7, "4x5": 5, "picopixel": 5}

def top_for(font, bottom):
    return bottom - FONT_H[font] + 1

def pts_parts(v):
    # 9.5 -> ("9", True); 0.5 -> ("", True); 0 -> ("0", False)
    x = float(v)
    whole = int(x + 0.001)
    half = (x - whole) > 0.25
    if whole == 0 and half:
        return "", True
    return str(whole), half

def pts_plain(v):
    w, h = pts_parts(v)
    return w + (".5" if h else "")

# Width of a points total drawn with draw_points.
def points_width(c, v, font):
    w, h = pts_parts(v)
    tw = c.text_width(w, font) if w != "" else 0
    if h:
        hw = HALF_BIG_W if font == "16x20_bold" else HALF_SMALL_W
        tw = tw + (1 if w != "" else 0) + hw
    return tw

def draw_points(c, v, x, y, font, col):
    w, h = pts_parts(v)
    if w != "":
        c.text(w, x, y, font = font, color = col)
        x = x + c.text_width(w, font) + 1
    if h:
        if font == "16x20_bold":
            c.sprite(HALF_BIG, x, y + 1, color = col)
        else:
            c.sprite(HALF_SMALL, x, y, color = col)

# ---------- time ----------

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return y, m, d

def iso_unix(s):
    t = str(s)
    if len(t) < 10:
        return None
    y = int(t[0:4])
    mo = int(t[5:7])
    d = int(t[8:10])
    h = int(t[11:13]) if len(t) >= 16 else 0
    mi = int(t[14:16]) if len(t) >= 16 else 0
    return days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60

# Sunday-of-month helpers for the daylight-saving rules below.
def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    wd = (first + 4) % 7          # 0 = Sunday (1 Jan 1970 was a Thursday)
    return first + (7 - wd) % 7 + 7 * (n - 1)

def last_sunday(y, m):
    nm_y = y + 1 if m == 12 else y
    nm_m = 1 if m == 12 else m + 1
    last = days_from_civil(nm_y, nm_m, 1) - 1
    return last - (last + 4) % 7

# Zone -> (standard UTC offset in minutes, DST rule). The rules are computed
# here instead of asking a time API, so tee times and the countdown still come
# out right when the network is down.
ZONES = {
    "America/New_York": (-300, "us"),
    "America/Chicago": (-360, "us"),
    "America/Denver": (-420, "us"),
    "America/Phoenix": (-420, ""),
    "America/Los_Angeles": (-480, "us"),
    "Pacific/Honolulu": (-600, ""),
    "Europe/London": (0, "eu"),
    "Europe/Dublin": (0, "eu"),
    "Europe/Paris": (60, "eu"),
    "Africa/Johannesburg": (120, ""),
    "Asia/Dubai": (240, ""),
    "Asia/Tokyo": (540, ""),
    "Australia/Sydney": (600, "au"),
    "Pacific/Auckland": (720, "nz"),
}

def dst_active(rule, std, t):
    y, _, _ = civil_from_days(t // 86400)
    if rule == "us":
        start = nth_sunday(y, 3, 2) * 86400 + 7200 - std
        end = nth_sunday(y, 11, 1) * 86400 + 7200 - (std + 3600)
        return t >= start and t < end
    if rule == "eu":
        return t >= last_sunday(y, 3) * 86400 + 3600 and t < last_sunday(y, 10) * 86400 + 3600
    if rule == "au":
        on = nth_sunday(y, 10, 1) * 86400 + 7200 - std
        off = nth_sunday(y, 4, 1) * 86400 + 10800 - (std + 3600)
        return t >= on or t < off
    if rule == "nz":
        on = last_sunday(y, 9) * 86400 + 7200 - std
        off = nth_sunday(y, 4, 1) * 86400 + 10800 - (std + 3600)
        return t >= on or t < off
    return False

def zone_offset(ctx, t):
    tz = ctx.inputs.get("timezone", "America/New_York")
    std_min, rule = ZONES.get(tz, ZONES["America/New_York"])
    std = std_min * 60
    return std + (3600 if dst_active(rule, std, t) else 0)

def local_unix(ctx, t):
    return t + zone_offset(ctx, t)

def clock_text(ctx, t, compact):
    lt = local_unix(ctx, t)
    sod = lt % 86400
    h = sod // 3600
    m = (sod % 3600) // 60
    mm = ("0" + str(m)) if m < 10 else str(m)
    if ctx.inputs.get("clock", "12h") == "24h":
        return (("0" + str(h)) if h < 10 else str(h)) + ":" + mm
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + mm + ("" if compact else ("AM" if h < 12 else "PM"))

def day_name(ctx, t):
    return ["THU", "FRI", "SAT", "SUN", "MON", "TUE", "WED"][(local_unix(ctx, t) // 86400) % 7]

# ---------- cups we know about ----------
# Hardcoded so the between-cups screens work with no network. Update when a
# new venue/date is announced.
#   Ryder Cup 2027: Adare Manor, Co. Limerick -- matches Fri 17 - Sun 19 Sep
#   2027 (rydercup.com). Presidents Cup 2028: Kingston Heath, Melbourne --
#   dates not announced yet, so it shows as a year with no countdown.
# (name, kind, year, start (y,m,d) or None, end (y,m,d) or None, venue,
#  place, left team, right team, ESPN event id or "")
CUPS = [
    ("PRESIDENTS CUP", "presidents", 2026, (2026, 9, 24), (2026, 9, 27), "MEDINAH", "ILLINOIS", "USA", "INTL", "401824815"),
    ("RYDER CUP", "ryder", 2027, (2027, 9, 17), (2027, 9, 19), "ADARE MANOR", "IRELAND", "USA", "EUR", ""),
    ("PRESIDENTS CUP", "presidents", 2028, None, None, "KINGSTON HEATH", "AUSTRALIA", "USA", "INTL", ""),
]

# Roll of honour, newest first: (year, short cup name, winner, winner pts,
# loser, loser pts). The 2026 Presidents Cup joins from ESPN once it's final.
HISTORY = [
    (2025, "RYDER", "EUR", 15.0, "USA", 13.0),
    (2024, "PRES", "USA", 18.5, "INTL", 11.5),
    (2023, "RYDER", "EUR", 16.5, "USA", 11.5),
    (2022, "PRES", "USA", 17.5, "INTL", 12.5),
    (2021, "RYDER", "USA", 19.0, "EUR", 9.0),
]

def cup_window(cup):
    if cup[3] == None:
        return None, None
    s = days_from_civil(cup[3][0], cup[3][1], cup[3][2]) * 86400
    e = days_from_civil(cup[4][0], cup[4][1], cup[4][2]) * 86400 + 86400
    return s, e

# ---------- ESPN parsing ----------

def http_json(url, ttl, params = None):
    if params:
        r = http.get(url, params = params, ttl_seconds = ttl)
    else:
        r = http.get(url, ttl_seconds = ttl)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    return r["json"]

def is_cup_name(name):
    n = str(name).upper()
    return "PRESIDENTS CUP" in n or "RYDER CUP" in n

def cup_kind(name):
    return "ryder" if "RYDER" in str(name).upper() else "presidents"

# "Medinah CC (No. 3)" -> "MEDINAH", "Bethpage State Park (Black Course)" ->
# "BETHPAGE", "Adare Manor" stays.
def short_venue(name):
    t = up(name)
    if "(" in t:
        t = t[:t.index("(")]
    for suf in (" COUNTRY CLUB", " GOLF CLUB", " GOLF & COUNTRY CLUB", " STATE PARK", " CC", " GC", " G&CC", " CLUB"):
        if t.strip().endswith(suf):
            t = t.strip()[:-len(suf)]
    return t.strip()

DAY_SHORT = {"MONDAY": "MON", "TUESDAY": "TUE", "WEDNESDAY": "WED", "THURSDAY": "THU",
             "FRIDAY": "FRI", "SATURDAY": "SAT", "SUNDAY": "SUN"}

# "Thursday Four-Balls" -> ["THURSDAY FOUR-BALLS", "THU FOUR-BALLS", "FOUR-BALLS"]
# "Friday Morning Foursomes" -> [..., "FRI AM FOURSOMES", ...]
def session_variants(desc):
    full = up(desc).strip()
    short = full.replace("MORNING", "AM").replace("AFTERNOON", "PM")
    for k, v in DAY_SHORT.items():
        short = short.replace(k, v)
    words = short.split(" ")
    bare = " ".join(words[1:]) if len(words) > 1 and words[0] in DAY_SHORT.values() else short
    return [full, short, bare]

FORMAT_WORD = {"fourball": "FOUR-BALLS", "foursome": "FOURSOMES", "singles": "SINGLES", "single": "SINGLES"}

# "2 Up" -> "2 UP", "4 & 3" -> "4&3", "All Square" -> "AS".
def norm_label(s):
    t = up(s).strip()
    if t == "ALL SQUARE" or t == "A/S" or t == "AS":
        return "AS"
    t = t.replace(" & ", "&").replace(" &", "&").replace("& ", "&")
    t = t.replace("UP", " UP").replace("  ", " ").strip()
    t = t.replace("DN", " DN").replace("  ", " ").strip()
    return t

def side_names(comp):
    out = []
    for r in comp.get("roster", []) or []:
        a = r.get("athlete", {}) or {}
        ln = a.get("lastName", "") or ""
        if ln == "":
            dn = str(a.get("displayName", ""))
            ln = dn.split(" ")[-1] if dn != "" else ""
        if ln != "":
            out.append(up(ln))
    if len(out) == 0:
        a = comp.get("athlete", {}) or {}
        ln = a.get("lastName", "") or a.get("displayName", "")
        if ln != "":
            out.append(up(ln))
    return out

# One ESPN match -> a flat row the board draws. left/right follow the cup's
# own team order (USA first), not the per-match home/away order.
def parse_match(m, left_abbr, idx):
    comps = m.get("competitors", []) or []
    if len(comps) < 2:
        return None
    a = comps[0]
    b = comps[1]
    if str((b.get("team", {}) or {}).get("abbreviation", "")) == left_abbr:
        a, b = b, a
    st = str((((m.get("status", {}) or {}).get("type", {})) or {}).get("state", "pre"))
    row = {
        "idx": idx, "state": st,
        "left": side_names(a), "right": side_names(b),
        "lead": "", "label": "", "thru": 0, "tee": None, "final": False,
    }
    thru = 0
    for s in (a, b):
        t = (s.get("status", {}) or {}).get("thru", 0)
        if t != None and int(t) > thru:
            thru = int(t)
    row["thru"] = thru
    tee = (a.get("status", {}) or {}).get("teeTime", "") or m.get("date", "")
    row["tee"] = iso_unix(tee) if tee != "" else None

    sa = a.get("score", {}) or {}
    sb = b.get("score", {}) or {}
    da = up((a.get("status", {}) or {}).get("detail", "") or sa.get("displayValue", "") or "")
    db = up((b.get("status", {}) or {}).get("detail", "") or sb.get("displayValue", "") or "")

    if st == "post" or "&" in da or "&" in db:
        row["final"] = True
        row["state"] = "post"
        if sa.get("winner"):
            row["lead"] = "L"
            row["label"] = norm_label(sa.get("displayValue", "") or da)
        elif sb.get("winner"):
            row["lead"] = "R"
            row["label"] = norm_label(sb.get("displayValue", "") or db)
        else:
            row["label"] = "HALVED"
        if row["label"] in ("", "-"):
            row["label"] = "WON" if row["lead"] != "" else "HALVED"
        return row
    if st == "in":
        la = norm_label(da)
        lb = norm_label(db)
        if "UP" in la:
            row["lead"] = "L"
            row["label"] = la
        elif "UP" in lb:
            row["lead"] = "R"
            row["label"] = lb
        elif "DN" in la:
            row["lead"] = "R"
            row["label"] = la.replace("DN", "UP")
        elif "DN" in lb:
            row["lead"] = "L"
            row["label"] = lb.replace("DN", "UP")
        else:
            va = float(sa.get("value", 0) or 0)
            vb = float(sb.get("value", 0) or 0)
            if va > vb:
                row["lead"] = "L"
                row["label"] = str(int(va - vb)) + " UP"
            elif vb > va:
                row["lead"] = "R"
                row["label"] = str(int(vb - va)) + " UP"
            else:
                row["label"] = "AS"
    return row

# Points each side has won in a list of rows (halved = half each).
def session_points(rows):
    l = 0.0
    r = 0.0
    for m in rows:
        if not m["final"]:
            continue
        if m["lead"] == "L":
            l += 1.0
        elif m["lead"] == "R":
            r += 1.0
        else:
            l += 0.5
            r += 0.5
    return l, r

def parse_leaderboard(ctx, data):
    evs = data.get("events", []) or []
    if len(evs) == 0:
        return None
    ev = evs[0]
    comps = ev.get("competitions", []) or []
    if len(comps) == 0 or len(comps[0]) == 0:
        return None
    cup = comps[0][0]
    teams = cup.get("competitors", []) or []
    if len(teams) < 2:
        return None
    t0 = teams[0]
    t1 = teams[1]
    left = str((t0.get("team", {}) or {}).get("abbreviation", "USA"))
    right = str((t1.get("team", {}) or {}).get("abbreviation", "INTL"))
    # USA always on the left, whatever order ESPN lists the teams in.
    if right == "USA":
        t0, t1 = t1, t0
        left, right = right, left
    lp = float((t0.get("score", {}) or {}).get("value", 0) or 0)
    rp = float((t1.get("score", {}) or {}).get("value", 0) or 0)

    name = up(ev.get("name", "") or ev.get("shortName", ""))
    kind = cup_kind(name)
    total = 28.0 if kind == "ryder" else 30.0
    to_win = total / 2 + 0.5
    for n in cup.get("notes", []) or []:
        txt = up(n.get("text", ""))
        if "FIRST TEAM TO " in txt:
            num = txt.split("FIRST TEAM TO ")[1].split(" ")[0]
            if num.replace(".", "").isdigit():
                to_win = float(num)

    state = str((((cup.get("status", {}) or {}).get("type", {})) or {}).get("state", "") or
                (((ev.get("status", {}) or {}).get("type", {})) or {}).get("state", "pre"))
    winner = ""
    if (t0.get("score", {}) or {}).get("winner") or lp >= to_win:
        winner = left
    elif (t1.get("score", {}) or {}).get("winner") or rp >= to_win:
        winner = right

    sessions = []
    for i in range(1, len(comps)):
        lst = comps[i]
        if type(lst) != "list" or len(lst) == 0:
            continue
        desc = str(lst[0].get("description", "") or "")
        fmt_word = FORMAT_WORD.get(str((lst[0].get("type", {}) or {}).get("text", "")).lower(), "")
        if desc == "" or desc.lower() == "tournament":
            desc = fmt_word if fmt_word != "" else "MATCHES"
        rows = []
        for j in range(len(lst)):
            r = parse_match(lst[j], left, j)
            if r != None:
                rows.append(r)
        if len(rows) > 0:
            sessions.append({"name": desc, "rows": rows, "singles": fmt_word == "SINGLES" or len(rows[0]["left"]) == 1})

    venue = ""
    courses = ev.get("courses", []) or []
    if len(courses) > 0:
        venue = short_venue(courses[0].get("name", ""))
    y = ev.get("date", "")
    year = int(str(y)[0:4]) if len(str(y)) >= 4 else ctx.now.year
    return build_event_state(ctx, name, kind, year, venue, left, right, lp, rp, total, to_win, state, winner, sessions)

# Picks the session the board pages show and the line under the cup name.
def build_event_state(ctx, name, kind, year, venue, left, right, lp, rp, total, to_win, state, winner, sessions):
    now = ctx.now.unix
    cur = -1
    for i in range(len(sessions)):
        for m in sessions[i]["rows"]:
            if m["state"] == "in":
                cur = i
    live = cur >= 0
    nxt = -1
    if not live:
        last_played = -1
        for i in range(len(sessions)):
            played = False
            for m in sessions[i]["rows"]:
                if m["state"] != "pre":
                    played = True
            if played:
                last_played = i
        # The next session's pairings, once published and within 12 hours of
        # the first tee, take over from the last result.
        for i in range(last_played + 1, len(sessions)):
            first = first_tee(sessions[i]["rows"])
            if first != None and first - now < 12 * 3600:
                nxt = i
                break
        if nxt >= 0:
            cur = nxt
        elif last_played >= 0:
            cur = last_played
        elif len(sessions) > 0:
            cur = 0
    sess = sessions[cur] if cur >= 0 else None
    # Projection: every match on the course scored as it stands (all square
    # = a half each), on top of the points already banked.
    in_play = 0
    pl = 0.0
    pr = 0.0
    if sess != None and live:
        for m in sess["rows"]:
            if m["state"] == "in":
                in_play += 1
                if m["lead"] == "L":
                    pl += 1.0
                elif m["lead"] == "R":
                    pr += 1.0
                else:
                    pl += 0.5
                    pr += 0.5
    return {
        "mode": "event", "cup": name, "kind": kind, "year": year, "venue": venue,
        "left": left, "right": right, "lp": lp, "rp": rp, "total": total, "to_win": to_win,
        "state": state, "winner": winner if (state == "post" or winner != "") else "",
        "session": sess, "live": live, "in_play": in_play, "proj_l": pl, "proj_r": pr,
        "upcoming": (not live) and nxt >= 0,
    }

def first_tee(rows):
    best = None
    for m in rows:
        if m["tee"] != None and (best == None or m["tee"] < best):
            best = m["tee"]
    return best

# Finds this week's cup on the PGA scoreboard. Returns (event id or "", ok).
def find_cup_event():
    sb = http_json(SCOREBOARD_URL, 900)
    if sb == None:
        return "", False
    for e in sb.get("events", []) or []:
        if is_cup_name(e.get("name", "")):
            return str(e.get("id", "")), True
    return "", True

def fetch_event(ctx, event_id, ttl):
    data = http_json(LEADERBOARD_URL, ttl, params = {"league": "pga", "event": event_id})
    if data == None:
        return None
    return parse_leaderboard(ctx, data)

# The cup that most recently finished, from the table, with ESPN's final.
def last_cup_state(ctx):
    now = ctx.now.unix
    best = None
    for cup in CUPS:
        s, e = cup_window(cup)
        if e != None and e <= now and cup[9] != "":
            best = cup
    if best == None:
        return None
    st = fetch_event(ctx, best[9], 3600)
    if st == None or st["state"] != "post":
        return None
    return st

def next_cup(ctx):
    now = ctx.now.unix
    for cup in CUPS:
        s, e = cup_window(cup)
        if s == None:
            if cup[2] > civil_from_days(now // 86400)[0]:
                return cup
            continue
        if s > now:
            return cup
    return None

def live_cup_by_date(ctx):
    now = ctx.now.unix
    for cup in CUPS:
        s, e = cup_window(cup)
        if s != None and now >= s - 86400 and now < e + 86400:
            return cup
    return None

# ---------- state ----------

def get_state(ctx):
    dbg = str(ctx.inputs.get("_debug", ""))
    if dbg != "":
        mock = mock_state(ctx, dbg)
        if mock != None:
            return mock
    eid, ok = find_cup_event()
    if not ok:
        # No network. Inside a known cup's dates that means scores are
        # missing, not that nothing is on.
        cup = live_cup_by_date(ctx)
        if cup != None:
            return {"mode": "offline", "cup": cup[0], "year": cup[2], "venue": cup[5],
                    "left": cup[7], "right": cup[8]}
        return {"mode": "between", "last": None}
    if eid != "":
        st = fetch_event(ctx, eid, 90)
        if st != None:
            return st
        cup = live_cup_by_date(ctx)
        return {"mode": "offline", "cup": cup[0] if cup else "TEAM CUP", "year": cup[2] if cup else ctx.now.year,
                "venue": cup[5] if cup else "", "left": cup[7] if cup else "USA", "right": cup[8] if cup else "INTL"}
    return {"mode": "between", "last": last_cup_state(ctx)}

# ---------- mock data (`_debug`) ----------
# `_debug` is not a manifest input, so it is inert once shipped. Values:
#   live     Presidents Cup, Saturday foursomes mid-session (final/live/AS)
#   singles  Presidents Cup Sunday singles, 12 matches, mixed states
#   final    Presidents Cup won, singles results on the boards
#   pre      Day 1 morning: 0-0, Thursday four-ball pairings with tee times
#   ryder    Ryder Cup (EUR colours), Friday afternoon four-balls live
#   between  no cup this week: countdown, last result, roll of honour
#   offline  a cup is on but ESPN is unreachable
#   event:<id>  any real ESPN event, e.g. event:401734110 (2025 Ryder Cup)
#   last:<id>   the between-cups pages with that event as the last result

def mk(l, r, state, lead, label, thru, tee_min):
    return {"idx": 0, "state": state, "left": l, "right": r, "lead": lead, "label": label,
            "thru": thru, "tee": tee_min, "final": state == "post"}

def mock_state(ctx, dbg):
    now = ctx.now.unix
    base = now - now % 3600
    if dbg.startswith("event:"):
        # a real ESPN event by id, e.g. event:401734110 (2025 Ryder Cup)
        return fetch_event(ctx, dbg[len("event:"):], 3600)
    if dbg.startswith("last:"):
        return {"mode": "between", "last": fetch_event(ctx, dbg[len("last:"):], 3600)}
    if dbg == "between":
        last = mock_state(ctx, "final")
        return {"mode": "between", "last": last}
    if dbg == "offline":
        return {"mode": "offline", "cup": "PRESIDENTS CUP", "year": 2026, "venue": "MEDINAH",
                "left": "USA", "right": "INTL"}
    if dbg == "live":
        rows = [
            mk(["SCHEFFLER", "BURNS"], ["MATSUYAMA", "KIM"], "post", "L", "3&2", 16, None),
            mk(["SCHAUFFELE", "CANTLAY"], ["SCOTT", "LEE"], "in", "R", "1 UP", 15, None),
            mk(["MORIKAWA", "HENLEY"], ["IM", "AN"], "in", "", "AS", 11, None),
            mk(["DECHAMBEAU", "THOMAS"], ["CONNERS", "TAYLOR"], "in", "L", "2 UP", 8, None),
        ]
        for i in range(len(rows)):
            rows[i]["idx"] = i
        sess = {"name": "Saturday Afternoon Foursomes", "rows": rows, "singles": False}
        return build_event_state(ctx, "PRESIDENTS CUP", "presidents", 2026, "MEDINAH", "USA", "INTL",
                                 8.5, 6.5, 30.0, 15.5, "in", "", [sess])
    if dbg == "ryder":
        rows = [
            mk(["SCHEFFLER", "HENLEY"], ["MCILROY", "FLEETWOOD"], "in", "R", "2 UP", 13, None),
            mk(["SCHAUFFELE", "CANTLAY"], ["RAHM", "HATTON"], "in", "L", "1 UP", 12, None),
            mk(["MORIKAWA", "ENGLISH"], ["FITZPATRICK", "ABERG"], "in", "", "AS", 10, None),
            mk(["DECHAMBEAU", "BRADLEY"], ["MACINTYRE", "HOVLAND"], "pre", "", "", 0, base + 1200),
        ]
        for i in range(len(rows)):
            rows[i]["idx"] = i
        sess = {"name": "Friday Afternoon Four-Balls", "rows": rows, "singles": False}
        return build_event_state(ctx, "RYDER CUP", "ryder", 2027, "ADARE MANOR", "USA", "EUR",
                                 1.5, 2.5, 28.0, 14.5, "in", "", [sess])
    if dbg == "pre":
        rows = []
        pairs = [(["SCHEFFLER", "BURNS"], ["IM", "HOJGAARD"]), (["SCHAUFFELE", "CANTLAY"], ["MATSUYAMA", "KIM"]),
                 (["MORIKAWA", "HENLEY"], ["SCOTT", "LEE"]), (["DECHAMBEAU", "THOMAS"], ["BEZUIDENHOUT", "AN"]),
                 (["ENGLISH", "BRADLEY"], ["CONNERS", "TAYLOR"])]
        for i in range(len(pairs)):
            r = mk(pairs[i][0], pairs[i][1], "pre", "", "", 0, base + 3600 + i * 1080)
            r["idx"] = i
            rows.append(r)
        sess = {"name": "Thursday Four-Balls", "rows": rows, "singles": False}
        return build_event_state(ctx, "PRESIDENTS CUP", "presidents", 2026, "MEDINAH", "USA", "INTL",
                                 0.0, 0.0, 30.0, 15.5, "pre", "", [sess])
    if dbg == "singles" or dbg == "final":
        fin = dbg == "final"
        L = ["SCHEFFLER", "SCHAUFFELE", "MORIKAWA", "DECHAMBEAU", "CANTLAY", "HENLEY",
             "BURNS", "THOMAS", "ENGLISH", "BRADLEY", "SPIETH", "HOMA"]
        R = ["MATSUYAMA", "IM", "SCOTT", "KIM", "BEZUIDENHOUT", "HOJGAARD",
             "AN", "CONNERS", "TAYLOR", "LEE", "PENDRITH", "HADWIN"]
        live_rows = [
            ("post", "L", "3&2", 16), ("post", "R", "2&1", 17), ("post", "", "HALVED", 18),
            ("in", "L", "2 UP", 14), ("in", "R", "1 UP", 13), ("in", "", "AS", 12),
            ("in", "L", "4 UP", 11), ("in", "R", "2 UP", 10), ("in", "L", "1 UP", 9),
            ("in", "", "AS", 7), ("pre", "", "", 0), ("pre", "", "", 0),
        ]
        final_rows = [
            ("post", "L", "3&2", 16), ("post", "R", "2&1", 17), ("post", "", "HALVED", 18),
            ("post", "L", "1 UP", 18), ("post", "R", "4&3", 15), ("post", "L", "2&1", 17),
            ("post", "L", "5&4", 14), ("post", "R", "1 UP", 18), ("post", "L", "3&1", 17),
            ("post", "", "HALVED", 18), ("post", "L", "2 UP", 18), ("post", "R", "6&5", 13),
        ]
        spec = final_rows if fin else live_rows
        rows = []
        for i in range(12):
            s, lead, lab, thru = spec[i]
            r = mk([L[i]], [R[i]], s, lead, lab, thru, base + 1800 + i * 660 if s == "pre" else None)
            r["idx"] = i
            rows.append(r)
        sess = {"name": "Sunday Singles", "rows": rows, "singles": True}
        if fin:
            return build_event_state(ctx, "PRESIDENTS CUP", "presidents", 2026, "MEDINAH", "USA", "INTL",
                                     17.5, 12.5, 30.0, 15.5, "post", "USA", [sess])
        return build_event_state(ctx, "PRESIDENTS CUP", "presidents", 2026, "MEDINAH", "USA", "INTL",
                                 11.0, 10.0, 30.0, 15.5, "in", "", [sess])
    return None

# ---------- hero ----------

def cup_title_variants(name, year):
    return [name + " " + str(year), name]

# The tug-of-war bar with team tags at each end. Each side's points fill in
# from its own end; the unplayed middle stays dark. The gold gate is the
# winning line -- (to_win / total) of the way in from either end.
def draw_tug_bar(c, st, y):
    lt = team(st["left"])
    rt = team(st["right"])
    lab_l = st["left"]
    lab_r = st["right"]
    wl = c.text_width(lab_l, "4x5") + 5
    wr = c.text_width(lab_r, "4x5") + 5
    x0 = EDGE
    x1 = c.width - 1 - EDGE
    # tags
    c.rect(x0, y, x0 + wl - 1, y + 6, fill = lt["pri"])
    c.text(lab_l, x0 + 3, y + 1, font = "4x5", color = lt["txt"])
    c.rect(x1 - wr + 1, y, x1, y + 6, fill = rt["pri"])
    c.text(lab_r, x1 - 2, y + 1, font = "4x5", color = rt["txt"], align = "right")
    # track
    bx0 = x0 + wl + 2
    bx1 = x1 - wr - 2
    bw = bx1 - bx0 + 1
    by0 = y + 2
    by1 = y + 4
    c.rect(bx0, by0, bx1, by1, fill = LINE)
    total = st["total"]
    fl = int(bw * st["lp"] / total + 0.5)
    fr = int(bw * st["rp"] / total + 0.5)
    # Projected points (matches up right now) extend each bar in a dim tint.
    pl = int(bw * (st["lp"] + st.get("proj_l", 0.0)) / total + 0.5)
    pr = int(bw * (st["rp"] + st.get("proj_r", 0.0)) / total + 0.5)
    if pl > fl:
        c.rect(bx0 + fl, by0, bx0 + pl - 1, by1, fill = color.dim(lt["pri"], 40))
    if pr > fr:
        c.rect(bx1 - pr + 1, by0, bx1 - fr, by1, fill = color.dim(rt["pri"], 40))
    if fl > 0:
        c.rect(bx0, by0, bx0 + fl - 1, by1, fill = lt["pri"])
    if fr > 0:
        c.rect(bx1 - fr + 1, by0, bx1, by1, fill = rt["pri"])
    # winning gate
    gl = bx0 + int(bw * st["to_win"] / total + 0.5) - 1
    gr = bx1 - int(bw * st["to_win"] / total + 0.5) + 1
    for gx in (gl, gr):
        c.rect(gx, y, gx, y + 6, fill = GOLD)

# A dark tint of the team colour behind its crest, fading to black.
def draw_wash(c, abbr, side, y0, y1):
    t = team(abbr)
    w = 64
    if side == "L":
        c.gradient_rect(EDGE, y0, EDGE + w - 1, y1, t["wash"], BG)
    else:
        c.gradient_rect(c.width - EDGE - w, y0, c.width - EDGE - 1, y1, BG, t["wash"])

def draw_side(c, st, side):
    left = side == "L"
    abbr = st["left"] if left else st["right"]
    t = team(abbr)
    pts = st["lp"] if left else st["rp"]
    other = st["rp"] if left else st["lp"]
    x_crest = EDGE if left else c.width - EDGE - CREST_W
    # team wash: a dark tint under the crest and score, fading to black.
    draw_wash(c, abbr, side, 1, 22)
    draw_crest(c, abbr, x_crest, 4)
    pw = points_width(c, pts, "16x20_bold")
    col = WHITE if pts >= other else SOFT
    if st.get("winner", "") != "" and st["winner"] != abbr:
        col = MUTED
    if left:
        sx = x_crest + CREST_W + 5
    else:
        sx = x_crest - 5 - pw
    draw_points(c, pts, sx, 2, "16x20_bold", col)
    return (sx + pw) if left else sx

# Centre column: three rows (cup, session, status) between the two scores.
def draw_center(c, st, ctx, lx, rx, rows):
    cx = c.width // 2
    avail = 2 * min(cx - lx, rx - cx) - 6
    bottoms = [6, 13, 21]
    for i in range(len(rows)):
        variants, fonts, col = rows[i]
        if len(variants) == 0:
            continue
        txt, f = fit_ladder(c, variants, fonts, avail)
        if type(col) == "list":
            # [dot color, text color] -- a status dot before the text
            w = c.text_width(txt, f) + 5
            x = cx - w // 2
            c.rect(x, top_for(f, bottoms[i]) + 1, x + 2, top_for(f, bottoms[i]) + 3, fill = col[0])
            c.text(txt, x + 5, top_for(f, bottoms[i]), font = f, color = col[1])
        else:
            c.text(txt, cx, top_for(f, bottoms[i]), font = f, color = col, align = "center")

# Text colour for a team's name on black: the team colour, lifted where the
# pill colour is too dark to read as text.
TEXT_TINT = {"USA": "#FF4A55", "INTL": "#9A74FF", "EUR": "#5A86FF"}

def win_color(abbr):
    return TEXT_TINT.get(abbr, SOFT)

def status_row(ctx, st):
    sess = st.get("session")
    if st.get("winner", "") != "":
        w = st["winner"]
        return ([team(w)["name"] + " WINS", w + " WINS"], ["5x7", "4x5"], win_color(w))
    if st["live"]:
        venue = st.get("venue", "")
        return (["LIVE  " + venue, "LIVE"] if venue != "" else ["LIVE"], ["4x5"], [LIVE_RED, WHITE])
    if sess != None:
        ft = first_tee(sess["rows"])
        if st.get("upcoming") and ft != None and ft > ctx.now.unix:
            t = clock_text(ctx, ft, False)
            return (["FIRST TEE " + t, "TEE " + t], ["4x5"], SOFT)
        return (["SESSION COMPLETE", "COMPLETE"], ["4x5"], MUTED)
    return ([st.get("venue", "")], ["4x5"], MUTED)

def cup(c, ctx):
    st = get_state(ctx)
    c.fill(BG)
    if st["mode"] == "event":
        draw_hero(c, ctx, st)
    elif st["mode"] == "offline":
        draw_offline(c, st)
    else:
        draw_countdown(c, ctx)

def draw_hero(c, ctx, st):
    lx = draw_side(c, st, "L")
    rx = draw_side(c, st, "R")
    sess = st.get("session")
    if st.get("winner", "") != "":
        v = st.get("venue", "")
        sess_row = (["FINAL  " + v, "FINAL"] if v != "" else ["FINAL"], ["4x5"], SOFT)
    elif sess != None:
        sess_row = (session_variants(sess["name"]), ["4x5", "picopixel"], WHITE)
    else:
        sess_row = ([st.get("venue", "")], ["4x5"], MUTED)
    rows = [
        (cup_title_variants(st["cup"], st["year"]), ["4x5", "picopixel"], GOLD),
        sess_row,
        status_row(ctx, st),
    ]
    draw_center(c, st, ctx, lx, rx, rows)
    draw_tug_bar(c, st, 24)

def draw_offline(c, st):
    draw_wash(c, st["left"], "L", 1, 30)
    draw_wash(c, st["right"], "R", 1, 30)
    draw_crest(c, st["left"], EDGE, 8)
    draw_crest(c, st["right"], c.width - EDGE - CREST_W, 8)
    cx = c.width // 2
    c.text(st["cup"] + " " + str(st["year"]), cx, 5, font = "4x5", color = GOLD, align = "center")
    c.text("LIVE SCORING UNAVAILABLE", cx, 13, font = "4x5", color = WHITE, align = "center")
    c.text("RETRYING SHORTLY", cx, 21, font = "4x5", color = MUTED, align = "center")

# ---------- between cups ----------

def draw_countdown(c, ctx):
    nc = next_cup(ctx)
    cx = c.width // 2
    if nc == None:
        c.sprite(TROPHY, cx - 4, 4)
        c.text("NEXT CUP TO BE ANNOUNCED", cx, 22, font = "4x5", color = SOFT, align = "center")
        return
    draw_wash(c, nc[7], "L", 1, 30)
    draw_wash(c, nc[8], "R", 1, 30)
    draw_crest(c, nc[7], EDGE, 8)
    draw_crest(c, nc[8], c.width - EDGE - CREST_W, 8)
    lx = EDGE + CREST_W + 6
    rx = c.width - EDGE - CREST_W - 6
    s, e = cup_window(nc)
    if s != None:
        y, m, d = nc[3]
        today = local_unix(ctx, ctx.now.unix) // 86400
        days = days_from_civil(y, m, d) - today
        num = str(days) if days > 0 else "0"
        cap = "DAYS TO GO" if days != 1 else "DAY TO GO"
        when = MONTHS[m - 1] + " " + str(d) + "-" + str(nc[4][2]) + " " + str(y)
    else:
        num = str(nc[2])
        cap = "DATES TBA"
        when = ""
    nf = "16x20_bold"
    nw = c.text_width(num, nf)
    bw = max(nw, c.text_width(cap, "4x5"))
    venue = nc[5] + ", " + nc[6]
    # Two blocks (cup text | days) centred between the crests, split by a
    # hairline.
    span = rx - lx
    tmax = span - bw - 13
    v, vf = fit_ladder(c, [venue, nc[5]], ["4x5"], tmax)
    tw = max(c.text_width(nc[0], "6x8"), c.text_width(v, vf), c.text_width(when, "4x5"))
    tw = min(tw, tmax)
    x = lx + (span - (tw + 13 + bw)) // 2
    c.text(nc[0], x, top_for("6x8", 9), font = "6x8", color = GOLD)
    c.text(v, x, top_for("4x5", 18), font = vf, color = WHITE)
    c.text(fit_text(c, when if when != "" else str(nc[2]), "4x5", tw), x, top_for("4x5", 27), font = "4x5", color = MUTED)
    dx = x + tw + 6
    c.rect(dx, 2, dx, 27, fill = LINE)
    bx = dx + 7 + bw // 2
    c.text(num, bx, 1, font = nf, color = WHITE, align = "center")
    c.text(cap, bx, top_for("4x5", 27), font = "4x5", color = SOFT, align = "center")

def draw_last_result(c, ctx, last):
    if last == None:
        draw_history(c, None)
        return
    lx = draw_side(c, last, "L")
    rx = draw_side(c, last, "R")
    w = last.get("winner", "")
    rows = [
        (cup_title_variants(last["cup"], last["year"]), ["4x5", "picopixel"], GOLD),
        (["FINAL RESULT", "FINAL"], ["4x5"], SOFT),
        ([team(w)["name"] + " WINS", w + " WINS"] if w != "" else ["TIED"], ["5x7", "4x5"], win_color(w)),
    ]
    draw_center(c, last, ctx, lx, rx, rows)
    draw_tug_bar(c, last, 24)

# The cups still to come, as two cards: year, cup, venue, dates.
def draw_upcoming(c, ctx):
    now = ctx.now.unix
    ups = []
    for cup in CUPS:
        s, e = cup_window(cup)
        if (e != None and e > now) or (e == None and cup[2] >= civil_from_days(now // 86400)[0]):
            ups.append(cup)
    if len(ups) == 0:
        c.sprite(TROPHY, c.width // 2 - 4, 4)
        c.text("NEXT CUP TO BE ANNOUNCED", c.width // 2, 22, font = "4x5", color = SOFT, align = "center")
        return
    n = min(2, len(ups))
    gap = 9
    card_w = (c.width - 2 * EDGE - gap * (n - 1)) // n
    for i in range(n):
        cup = ups[i]
        x0 = EDGE + i * (card_w + gap)
        if i > 0:
            c.rect(x0 - 5, 3, x0 - 5, 28, fill = LINE)
        rt = team(cup[8])
        c.rect(x0, 3, x0 + 1, 28, fill = rt["pri"])
        tx = x0 + 5
        room = card_w - 5
        name, nf = fit_ladder(c, [cup[0]], ["5x7", "4x5"], room)
        c.text(name, tx, top_for(nf, 9), font = nf, color = WHITE)
        v, vf = fit_ladder(c, [cup[5] + ", " + cup[6], cup[5]], ["4x5"], room)
        c.text(v, tx, top_for("4x5", 18), font = vf, color = SOFT)
        yr = str(cup[2]) + " "
        c.text(yr, tx, top_for("4x5", 27), font = "4x5", color = GOLD)
        yw = c.text_width(yr, "4x5") + 1
        if cup[3] != None:
            rest = MONTHS[cup[3][1] - 1] + " " + str(cup[3][2]) + "-" + str(cup[4][2])
        else:
            rest = cup[6] if vf != "" and v == cup[5] else "DATES TBA"
        c.text(fit_text(c, rest, "4x5", room - yw), tx + yw, top_for("4x5", 27), font = "4x5", color = MUTED)

# Roll of honour: the last four cups as score cards, newest first. The cup
# that just finished (read from ESPN) leads when there is one.
def history_items(last):
    items = []
    if last != None and last.get("winner", "") != "":
        w = last["winner"]
        wl = w == last["left"]
        items.append((last["year"], "RYDER" if last["kind"] == "ryder" else "PRES",
                      w, last["lp"] if wl else last["rp"],
                      last["right"] if wl else last["left"], last["rp"] if wl else last["lp"]))
    for h in HISTORY:
        dup = False
        for it in items:
            if it[0] == h[0]:
                dup = True
        if not dup:
            items.append(h)
    return items

def draw_history(c, last):
    items = history_items(last)
    n = min(4, len(items))
    gap = 5
    card_w = (c.width - 2 * EDGE - gap * (n - 1)) // n
    for i in range(n):
        yr, cupn, win, wp, lose, lp = items[i]
        x0 = EDGE + i * (card_w + gap)
        x1 = x0 + card_w - 1
        if i > 0:
            c.rect(x0 - 3, 3, x0 - 3, 28, fill = LINE)
        c.text(str(yr), x0, 3, font = "4x5", color = GOLD)
        c.text(cupn, x1, 3, font = "picopixel", color = MUTED, align = "right")
        draw_result_line(c, win, wp, x0, x1, 11, True)
        draw_result_line(c, lose, lp, x0, x1, 21, False)

# One team's line on a card: colour tag with the abbreviation, points at the
# right edge (5x7 digits, hand-drawn half).
def draw_result_line(c, abbr, pts, x0, x1, y, won):
    t = team(abbr)
    tw = c.text_width(abbr, "4x5") + 4
    c.rect(x0, y, x0 + tw - 1, y + 6, fill = t["pri"] if won else color.dim(t["pri"], 35))
    c.text(abbr, x0 + 2, y + 1, font = "4x5", color = t["txt"] if won else SOFT)
    pw = small_points_width(c, pts)
    draw_points(c, pts, x1 - pw + 1, y, "5x7", WHITE if won else MUTED)

def small_points_width(c, v):
    w, h = pts_parts(v)
    tw = c.text_width(w, "5x7") if w != "" else 0
    if h:
        tw = tw + (1 if w != "" else 0) + HALF_SMALL_W
    return tw

# ---------- match board ----------

def label_for(ctx, m, compact):
    if m["state"] == "pre":
        if m["tee"] != None:
            return clock_text(ctx, m["tee"], compact)
        return "TBD"
    lab = m["label"]
    if compact:
        lab = lab.replace(" UP", "UP")
    return lab

def pill_color(st, m):
    if m["lead"] == "L":
        return team(st["left"])["pri"]
    if m["lead"] == "R":
        return team(st["right"])["pri"]
    return "#3A4252"

def name_colors(m):
    if m["state"] == "pre":
        return SOFT, SOFT
    if m["lead"] == "L":
        return WHITE, (DIM if m["final"] else MUTED)
    if m["lead"] == "R":
        return (DIM if m["final"] else MUTED), WHITE
    return SOFT, SOFT

# Name ladders for one side: "SCHEFFLER/BURNS" -> trims the longer name a
# letter at a time until it fits.
def side_text(c, names, font, max_w):
    if len(names) == 0:
        return "TBD"
    txt = "/".join(names)
    if c.text_width(txt, font) <= max_w:
        return txt
    cur = list(names)
    for _ in range(40):
        longest = 0
        for i in range(len(cur)):
            if len(cur[i]) > len(cur[longest]):
                longest = i
        if len(cur[longest]) <= 3:
            break
        cur[longest] = cur[longest][:len(cur[longest]) - 1].rstrip(" ")
        txt = "/".join(cur)
        if c.text_width(txt, font) <= max_w:
            return txt
    return fit_text(c, txt, font, max_w)

# Largest name font where every row on the page fits untrimmed.
def pick_name_font(c, rows, max_w):
    for f in ("4x5", "picopixel"):
        ok = True
        for m in rows:
            if c.text_width("/".join(m["left"]), f) > max_w or c.text_width("/".join(m["right"]), f) > max_w:
                ok = False
        if ok:
            return f
    return "picopixel"

# The status pill. Live: solid in the leader's colour (grey when all
# square) with a dark cap showing the hole the match is through. Final: the
# same colour dimmed, cap "F". Upcoming: an outlined tee time.
def draw_pill(c, ctx, st, m, x0, x1, y0, y1, compact):
    lab = label_for(ctx, m, compact)
    h = y1 - y0 + 1
    if m["state"] == "pre":
        c.rect(x0, y0, x1, y1, outline = "#3A4252")
        t, tf = fit_ladder(c, [lab], ["4x5", "picopixel"], x1 - x0 - 2)
        c.text(t, (x0 + x1 + 1) // 2, y0 + (h - 5) // 2, font = tf, color = SOFT, align = "center")
        return
    pc = pill_color(st, m)
    cap = 0
    if not compact:
        cap = 11 if m["state"] == "in" else 8
    fill = pc if not m["final"] else color.dim(pc, 45)
    c.rect(x0, y0, x1 - cap, y1, fill = fill)
    if cap > 0:
        c.rect(x1 - cap + 1, y0, x1, y1, fill = "#161B24")
        capt = str(m["thru"]) if m["state"] == "in" else "F"
        c.text(capt, x1 - cap // 2 + 1, y0 + (h - 5) // 2, font = "4x5", color = GOLD if m["final"] else SOFT, align = "center")
    room = x1 - cap - x0 - 2
    mid = (x0 + x1 - cap + 1) // 2
    if compact and m["final"] and m["lead"] == "":
        lab = "AS"
    lf = "5x7" if (not compact and h >= 9 and c.text_width(lab, "5x7") <= room) else "4x5"
    c.text(fit_text(c, lab, lf, room), mid, y0 + (h - FONT_H[lf]) // 2, font = lf, color = WHITE, align = "center")

def draw_pair_row(c, ctx, st, m, y0, y1, font):
    x0 = EDGE
    x1 = c.width - 1 - EDGE
    lt = team(st["left"])
    rt = team(st["right"])
    # team chips at each end
    c.rect(x0, y0, x0 + 1, y1, fill = lt["pri"] if m["lead"] != "R" or m["state"] == "pre" else color.dim(lt["pri"], 35))
    c.rect(x1 - 1, y0, x1, y1, fill = rt["pri"] if m["lead"] != "L" or m["state"] == "pre" else color.dim(rt["pri"], 35))
    pw = 40
    px0 = c.width // 2 - pw // 2
    px1 = px0 + pw - 1
    draw_pill(c, ctx, st, m, px0, px1, y0, y1, False)
    nl, nr = name_colors(m)
    max_w = px0 - 4 - (x0 + 4)
    fh = FONT_H[font]
    ty = y0 + (y1 - y0 + 1 - fh) // 2
    c.text(side_text(c, m["left"], font, max_w), x0 + 4, ty, font = font, color = nl)
    c.text(side_text(c, m["right"], font, max_w), x1 - 3, ty, font = font, color = nr, align = "right")

def draw_single_cell(c, ctx, st, m, x0, x1, y0, y1, font):
    lab = label_for(ctx, m, True)
    if m["final"] and m["lead"] == "":
        lab = "AS"
    pw = 17
    if m["state"] == "pre":
        pw = max(pw, min(24, c.text_width(lab, "4x5") + 4))
    cx = (x0 + x1 + 1) // 2
    px0 = cx - pw // 2
    px1 = px0 + pw - 1
    draw_pill(c, ctx, st, m, px0, px1, y0, y1, True)
    nl, nr = name_colors(m)
    fh = FONT_H[font]
    ty = y0 + (y1 - y0 + 1 - fh) // 2
    c.text(side_text(c, m["left"], font, px0 - 2 - x0), x0, ty, font = font, color = nl)
    c.text(side_text(c, m["right"], font, x1 - px1 - 2), x1, ty, font = font, color = nr, align = "right")

# Board order: live matches first, then finished, then upcoming, each in
# match order.
def board_rows(sess):
    rank = {"in": 0, "post": 1, "pre": 2}
    rows = list(sess["rows"])
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            a = rows[j]
            b = rows[j + 1]
            ka = rank.get(a["state"], 3) * 100 + a["idx"]
            kb = rank.get(b["state"], 3) * 100 + b["idx"]
            if ka > kb:
                rows[j] = b
                rows[j + 1] = a
    return rows

def draw_board(c, ctx, st, page):
    sess = st.get("session")
    if sess == None:
        c.text("PAIRINGS TO COME", c.width // 2, 13, font = "4x5", color = MUTED, align = "center")
        return
    rows = board_rows(sess)
    n = len(rows)
    singles = sess["singles"] and n > 6
    if singles:
        per = 6
        lo = page * per
        chunk = rows[lo:lo + per]
        if len(chunk) == 0:
            draw_session_summary(c, st, sess, 13)
            return
        col_w = (c.width - 2 * EDGE - 3) // 2
        name_w = (col_w - 17) // 2 - 2
        font = pick_name_font(c, chunk, name_w)
        for i in range(len(chunk)):
            col = i // 3
            x0 = EDGE if col == 0 else c.width - EDGE - col_w
            y0 = 1 + (i % 3) * 10
            draw_single_cell(c, ctx, st, chunk[i], x0, x0 + col_w - 1, y0, y0 + 8, font)
        # hairline between the two columns
        dx = c.width // 2
        c.rect(dx, 2, dx, 29, fill = LINE)
        return
    first = (n + 1) // 2
    chunk = rows[0:first] if page == 0 else rows[first:]
    max_w = c.width // 2 - 20 - (EDGE + 4) - 4
    font = pick_name_font(c, rows, max_w)
    slots = len(chunk)
    if page == 1 and slots < 3:
        slots = slots + 1     # room for the session summary line
    if slots == 0:
        draw_session_summary(c, st, sess, 13)
        return
    h = 9 if slots >= 3 else 11
    gap = 1 if slots >= 3 else 3
    total_h = slots * h + (slots - 1) * gap
    y = (32 - total_h) // 2
    for m in chunk:
        draw_pair_row(c, ctx, st, m, y, y + h - 1, font)
        y += h + gap
    if page == 1 and len(chunk) < slots:
        draw_session_summary(c, st, sess, y + (h - 5) // 2)

def draw_session_summary(c, st, sess, y):
    sl, sr = session_points(sess["rows"])
    name, f = fit_ladder(c, session_variants(sess["name"]), ["4x5"], 100)
    cx = c.width // 2
    lt = team(st["left"])
    rt = team(st["right"])
    lw = small4_width(c, sl)
    rw = small4_width(c, sr)
    label = name + "  "
    tw = c.text_width(label, "4x5")
    total = tw + c.text_width(st["left"] + " ", "4x5") + lw + c.text_width(" - ", "4x5") + rw + c.text_width(" " + st["right"], "4x5")
    x = cx - total // 2
    c.text(label, x, y, font = "4x5", color = MUTED)
    x += tw
    c.text(st["left"] + " ", x, y, font = "4x5", color = win_color(st["left"]))
    x += c.text_width(st["left"] + " ", "4x5")
    draw_small4(c, sl, x, y, WHITE)
    x += lw
    c.text(" - ", x, y, font = "4x5", color = MUTED)
    x += c.text_width(" - ", "4x5")
    draw_small4(c, sr, x, y, WHITE)
    x += rw
    c.text(" " + st["right"], x, y, font = "4x5", color = win_color(st["right"]))

# 4x5-sized points with a 5 px half glyph.
HALF_TINY = """
X..X
X.X.
.X..
X.XX
..XX
"""

def small4_width(c, v):
    w, h = pts_parts(v)
    tw = c.text_width(w, "4x5") if w != "" else 0
    if h:
        tw = tw + (1 if w != "" else 0) + 4
    return tw

def draw_small4(c, v, x, y, col):
    w, h = pts_parts(v)
    if w != "":
        c.text(w, x, y, font = "4x5", color = col)
        x += c.text_width(w, "4x5") + 1
    if h:
        c.sprite(HALF_TINY, x, y, color = col)

def board1(c, ctx):
    st = get_state(ctx)
    c.fill(BG)
    if st["mode"] == "event":
        draw_board(c, ctx, st, 0)
    elif st["mode"] == "offline":
        draw_history(c, None)
    else:
        draw_last_result(c, ctx, st.get("last"))

def board2(c, ctx):
    st = get_state(ctx)
    c.fill(BG)
    if st["mode"] == "event":
        draw_board(c, ctx, st, 1)
    elif st.get("last") != None:
        draw_history(c, st.get("last"))
    else:
        # board1 already showed the roll of honour; list what's coming.
        draw_upcoming(c, ctx)
