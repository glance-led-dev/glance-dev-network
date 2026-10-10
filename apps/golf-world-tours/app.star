# Golf World Tours (192x32) -- a broadcast leaderboard for the tours the
# network's PGA Tour and LPGA apps don't cover: DP World Tour, PGA Tour
# Champions, Korn Ferry Tour and LIV Golf.
#
# DESIGN. Black ground, one colour identity per tour (emblem + chip colour +
# accent), score colours on golf's broadcast convention: red under par,
# white level, blue over. Every page keeps EDGE (4 px) clear left and right so
# the app reads as its own unit in the scroll stream.
#
#   STATE            event (hero)                  board1          board2
#   live / final     emblem, event, course, round  P1-8 (2 x 4)    P9-16
#                    + LEADER / CHAMPION box
#   pre (field set)  emblem, event, course, dates  last winner     event facts
#                    + FIRST TEE box
#   off / cancelled  emblem, next event            last winner     up next
#                    + STARTS box
#
# Data: ESPN's public golf feeds, no key.
#   scoreboard  site.api.espn.com/.../golf/<league>/scoreboard (~10-60 KB):
#               the current event id and the season calendar.
#   leaderboard site.web.api.espn.com/.../golf/leaderboard?league=&event=
#               (~3-260 KB): positions with ties, thru, tee times, round
#               scores, course/city, purse, defending champion.
# The leaderboard's competitor list is NOT in position order -- sort by
# sortOrder. Worst case is 1 scoreboard + 1 leaderboard + 3 look-backs for the
# last completed event + 1 time-zone lookup = 6 requests.
#
# `_debug` (not a declared input; pass it to render_app) = live / final / pre /
# off swaps in a mock state so each screen can be checked on any day.

SB_URL = "https://site.api.espn.com/apis/site/v2/sports/golf/%s/scoreboard"
LB_URL = "https://site.web.api.espn.com/apis/site/v2/sports/golf/leaderboard"

EDGE = 4

# One colour identity per tour. chip = the filled position chips and tags,
# accent = labels, tint = the near-black wash behind the hero box.
TOURS = {
    "DP World Tour": {
        "league": "eur",
        "name": "DP WORLD TOUR",
        "chip": "#1F63E0",
        "accent": "#46D2FF",
        "tint": "#071A3A",
        "logo": "assets/dpwt.png",
    },
    "PGA Tour Champions": {
        "league": "champions-tour",
        "name": "PGA TOUR CHAMPIONS",
        "chip": "#F2B532",
        "accent": "#FFD466",
        "tint": "#2A1C04",
        "logo": "assets/champions.png",
    },
    "Korn Ferry Tour": {
        "league": "ntw",
        "name": "KORN FERRY TOUR",
        "chip": "#1FA64A",
        "accent": "#B6F23A",
        "tint": "#062611",
        "logo": "assets/kornferry.png",
    },
    "LIV Golf": {
        "league": "liv",
        "name": "LIV GOLF",
        "chip": "#FF5A1F",
        "accent": "#FF8A4C",
        "tint": "#2A0E04",
        "logo": "assets/liv.png",
    },
}
DEFAULT_TOUR = "DP World Tour"

COL = {
    "bg": "#000000",
    "text": "#F4F7FB",
    "muted": "#8391A7",
    "dim": "#4A5568",
    "rule": "#262E3A",
    "zebra": "#0D1117",
    "under": "#FF3B3B",
    "level": "#F4F7FB",
    "over": "#6FA8FF",
    "live": "#22DD66",
    "warn": "#FFB020",
    "gold": "#FFD24A",
    "error": "#FF5D73",
}

# Lit glyph height per font; rows that mix fonts share a bottom edge.
FONT_H = {"6x8": 8, "5x7": 7, "4x7": 7, "4x5": 5, "picopixel": 5, "9x12_bold": 12}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DOW = ["THU", "FRI", "SAT", "SUN", "MON", "TUE", "WED"]  # 1970-01-01 was a Thursday

# Bitmap fonts have no accented glyphs and skip them silently (Højgaard would
# draw as HJGAARD). Fold to plain ASCII -- both cases, since upper() of a
# non-ASCII letter isn't guaranteed.
ASCII_FOLD = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A", "Æ": "AE",
    "á": "A", "à": "A", "â": "A", "ä": "A", "ã": "A", "å": "A", "æ": "AE",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E", "é": "E", "è": "E", "ê": "E", "ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I", "í": "I", "ì": "I", "î": "I", "ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O", "Ø": "O",
    "ó": "O", "ò": "O", "ô": "O", "ö": "O", "õ": "O", "ø": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U", "ú": "U", "ù": "U", "û": "U", "ü": "U",
    "Ç": "C", "ç": "C", "Ñ": "N", "ñ": "N", "Ý": "Y", "ý": "Y", "ß": "SS",
    "Š": "S", "š": "S", "Ž": "Z", "ž": "Z", "Č": "C", "č": "C", "Ć": "C", "ć": "C",
    "Ł": "L", "ł": "L", "Ś": "S", "ś": "S", "Ń": "N", "ń": "N", "Ř": "R", "ř": "R",
    "Đ": "D", "đ": "D", "Þ": "TH", "þ": "TH", "Ð": "D", "ð": "D",
    "’": "", "'": "", "‘": "", "“": "", "”": "", "\"": "", "–": "-", "—": "-",
}

NAME_SUFFIXES = ["JR.", "JR", "SR.", "SR", "II", "III", "IV"]

# Event-name shortening, tried in order until the name fits.
NAME_ABBR = [
    ("CHAMPIONSHIP", "CHAMP."),
    ("INTERNATIONAL", "INTL"),
    ("INVITATIONAL", "INVITE"),
    ("TOURNAMENT", "TOURN."),
    ("CLASSIC", "CLASSIC"),
]
SPONSOR_CUTS = [" - ", " PRESENTED BY ", " PRES. BY ", " PRES BY ", " HOSTED BY ", " POWERED BY ",
                " FOR THE ", " BENEFITING ", " BY "]

# ---------------------------------------------------------------- helpers

def tour_of(ctx):
    t = ctx.inputs.get("tour", DEFAULT_TOUR)
    if t in TOURS:
        return TOURS[t]
    for k, v in TOURS.items():
        if v["league"] == t:
            return v
    return TOURS[DEFAULT_TOUR]

def up(s):
    if s == None:
        return ""
    t = str(s)
    for k, v in ASCII_FOLD.items():
        if k in t:
            t = t.replace(k, v)
    return t.upper().strip()

def top_for(font, bottom):
    return bottom - FONT_H[font] + 1

def tw(c, s, font):
    return c.text_width(s, font) if s != "" else 0

# Largest font first; within a font the fullest wording that fits; past the
# last font, hard-clip the shortest wording with "..".
def fit_ladder(c, variants, fonts, max_w):
    for f in fonts:
        for v in variants:
            if v != "" and c.text_width(v, f) <= max_w:
                return v, f
    f = fonts[len(fonts) - 1]
    return clip(c, variants[len(variants) - 1], f, max_w), f

def clip(c, text, font, max_w):
    if text == "" or c.text_width(text, font) <= max_w:
        return text
    words = text.split(" ")
    for i in range(len(words) - 1, 0, -1):
        cand = " ".join(words[:i])
        if c.text_width(cand, font) <= max_w:
            if len(cand) * 10 >= len(text) * 7:
                return cand
            break
    for n in range(len(text) - 1, 0, -1):
        cand = text[:n].rstrip(" -.,") + ".."
        if c.text_width(cand, font) <= max_w:
            return cand
    return ""

def yiq(hex_color):
    h = hex_color.lstrip("#")
    if len(h) < 6:
        return 128
    return (int(h[0:2], 16) * 299 + int(h[2:4], 16) * 587 + int(h[4:6], 16) * 114) // 1000

def ink_on(fill):
    return "#000000" if yiq(fill) >= 140 else "#FFFFFF"

def score_color(s):
    if s.startswith("-"):
        return COL["under"]
    if s.startswith("+"):
        return COL["over"]
    if s == "E":
        return COL["level"]
    return COL["muted"]

def fetch(url, ttl, params = None):
    if params:
        r = http.get(url, params = params, ttl_seconds = ttl)
    else:
        r = http.get(url, ttl_seconds = ttl)
    if r["status_code"] != 200:
        return None
    return r["json"]

# ---------------------------------------------------------------- time

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

def iso_ok(s):
    t = str(s)
    return len(t) >= 10 and t[0:4].isdigit() and t[5:7].isdigit() and t[8:10].isdigit()

def iso_day(s):
    # "2026-09-24T07:00Z" -> day number (date part only; tour dates are local).
    t = str(s)
    if not iso_ok(t):
        return None
    return days_from_civil(int(t[0:4]), int(t[5:7]), int(t[8:10]))

def iso_unix(s):
    t = str(s)
    if not iso_ok(t):
        return None
    h = int(t[11:13]) if len(t) >= 16 and t[11:13].isdigit() else 0
    mi = int(t[14:16]) if len(t) >= 16 and t[14:16].isdigit() else 0
    return iso_day(t) * 86400 + h * 3600 + mi * 60

def md(day):
    y, m, d = civil_from_days(day)
    return MONTHS[m - 1] + " " + str(d)

def date_range(start_iso, end_iso):
    a = iso_day(start_iso)
    b = iso_day(end_iso)
    if a == None:
        return ""
    if b == None or b <= a:
        return md(a)
    ya, ma, da = civil_from_days(a)
    yb, mb, db = civil_from_days(b)
    if ma == mb:
        return MONTHS[ma - 1] + " " + str(da) + "-" + str(db)
    return md(a) + "-" + md(b)

def tz_offset(ctx):
    tz = ctx.inputs.get("timezone", "America/New_York")
    r = http.get("https://timeapi.io/api/TimeZone/zone", params = {"timeZone": tz}, ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        return 0, False
    off = r["json"].get("currentUtcOffset", {})
    if type(off) != "dict":
        return 0, False
    secs = off.get("seconds", None)
    if secs == None:
        return 0, False
    return int(secs), True

def clock(unix_local, with_ampm):
    s = unix_local % 86400
    h = s // 3600
    m = (s % 3600) // 60
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    t = str(h12) + ":" + ("0" + str(m) if m < 10 else str(m))
    if with_ampm:
        t = t + (" AM" if h < 12 else " PM")
    return t

# ---------------------------------------------------------------- names

def last_name(first, last, display):
    ln = up(last)
    if ln == "":
        parts = up(display).split(" ")
        ln = parts[len(parts) - 1] if parts else ""
        if ln in NAME_SUFFIXES and len(parts) >= 2:
            ln = parts[len(parts) - 2]
    words = ln.split(" ")
    if len(words) >= 2 and words[len(words) - 1] in NAME_SUFFIXES:
        ln = " ".join(words[:len(words) - 1])
    return ln

def name_variants(p, with_initial):
    ln = p["last"]
    out = []
    if with_initial and p["initial"] != "":
        out.append(p["initial"] + "." + ln)
    out.append(ln)
    if "-" in ln:
        out.append(ln.split("-")[0])
    if " " in ln:
        ws = ln.split(" ")
        out.append(ws[len(ws) - 1])
    return out

def mark_dupes(players):
    seen = {}
    for p in players:
        seen[p["last"]] = seen.get(p["last"], 0) + 1
    for p in players:
        p["dupe"] = seen.get(p["last"], 0) > 1

GENERIC_TAIL = ["CHAMPIONSHIP", "TOURNAMENT", "INVITATIONAL"]
BAD_LEAD = ["GOLF", "DE", "DU", "OF", "THE", "-", "AT", "&", "AND", "FOR", "BY"]
TOUR_PREFIX = ["LIV GOLF ", "DP WORLD TOUR "]

# Wordings carry a penalty: 1 per abbreviation, 2 for dropping the generic
# tail word, 4 per leading word dropped. Fonts add their own (FONT_COST);
# fit_event draws the cheapest combination that fits, so "CHILDRENS
# HOSPITAL" in 4x7 beats "HOSPITAL CHAMP." in 5x7.
def name_forms(ws, base_pen):
    s = " ".join(ws)
    out = [(s, base_pen)]
    for a, b in NAME_ABBR:
        if a in s and a != b:
            out.append((s.replace(a, b), base_pen + 1))
    if len(ws) >= 3 and ws[len(ws) - 1] in GENERIC_TAIL:
        out.append((" ".join(ws[:len(ws) - 1]), base_pen + 2))
    return out

def event_variants_pen(name):
    n = up(name)
    out = [(n, 0)]
    base = n
    for pre in TOUR_PREFIX:
        if base.startswith(pre) and len(base) > len(pre) + 3:
            base = base[len(pre):]
    for cut in SPONSOR_CUTS:
        i = base.find(cut)
        if i > 4:
            base = base[:i]
            break
    ws = [w for w in base.split(" ") if w != ""]
    out += name_forms(ws, 0)
    for k in (1, 2):
        if len(ws) - k >= 2 and ws[k] not in BAD_LEAD:
            out += name_forms(ws[k:], 4 * k)
    return out

def event_variants(name):
    seen = {}
    uniq = []
    for v, pen in sorted(event_variants_pen(name), key = lambda t: t[1]):
        if v != "" and not seen.get(v, False):
            seen[v] = True
            uniq.append(v)
    return uniq

FONT_COST = {"6x8": 0, "5x7": 2, "4x7": 4, "4x5": 7}

def fit_event(c, name, w):
    vs = event_variants_pen(name)
    full = len(vs[0][0])
    best = None
    for f in ["6x8", "5x7", "4x7", "4x5"]:
        for v, pen in vs:
            if f == "6x8" and len(v) * 100 < full * 70:
                continue
            if c.text_width(v, f) <= w:
                cost = pen + FONT_COST[f]
                if best == None or cost < best[2]:
                    best = (v, f, cost)
    if best != None:
        return best[0], best[1]
    return fit_ladder(c, event_variants(name), ["4x5"], w)

COURSE_ABBR = [
    ("GOLF AND COUNTRY CLUB", "G&CC"),
    ("GOLF & COUNTRY CLUB", "G&CC"),
    ("COUNTRY CLUB", "CC"),
    ("GOLF CLUB", "GC"),
    ("GOLF COURSE", "GC"),
    ("GOLF LINKS", "GL"),
]

def course_variants(name):
    out = [name]
    for pre in ("THE CLUB AT ", "THE COURSE AT ", "THE GOLF CLUB AT "):
        if name.startswith(pre):
            out.append(name[len(pre):])
    for a, b in COURSE_ABBR:
        if a in name:
            out.append(name.replace(a, b))
            break
    # "THE CARDINAL AT SAINT JOHNS" -> "THE CARDINAL" -> "CARDINAL"
    i = name.find(" AT ")
    if i > 3 and not name.startswith("THE CLUB AT "):
        head = name[:i]
        out.append(head)
        if head.startswith("THE ") and len(head) > 8:
            out.append(head[4:])
    return out

def short_course(name):
    t = up(name)
    i = t.find(" (")
    if i > 0:
        t = t[:i]
    return t

def short_money(display):
    digits = ""
    s = str(display)
    for i in range(len(s)):
        if s[i].isdigit():
            digits += s[i]
    if digits == "":
        return ""
    n = int(digits)
    if n >= 1000000:
        h = (n + 5000) // 10000  # hundredths of a million
        whole = h // 100
        frac = h % 100
        t = str(whole)
        if frac != 0:
            fs = ("0" + str(frac)) if frac < 10 else str(frac)
            if fs.endswith("0"):
                fs = fs[0]
            t = t + "." + fs
        return "$" + t + "M"
    if n >= 1000:
        return "$" + str(n // 1000) + "K"
    return "$" + str(n)

def place_of(course):
    addr = course.get("address", None) if course else None
    if addr == None or type(addr) != "dict":
        return ""
    city = up(addr.get("city", ""))
    st = up(addr.get("state", ""))
    country = up(addr.get("country", ""))
    if city == "":
        return country
    if country in ("USA", "UNITED STATES") and st != "":
        return city + ", " + st
    if country != "" and country != city:
        return city + ", " + country
    return city

# ---------------------------------------------------------------- data

def parse_player(comp, period, off, have_tz):
    st = comp.get("status", {}) or {}
    stype = (st.get("type", {}) or {}).get("name", "")
    ath = comp.get("athlete", {}) or {}
    disp = ath.get("displayName", "")
    first = up(disp).split(" ")[0] if disp else ""
    last = last_name("", ath.get("lastName", ""), disp)
    pos = up(((st.get("position", {}) or {}).get("displayName", "")))
    dv = up(st.get("displayValue", ""))
    if stype == "STATUS_CUT" or dv in ("CUT", "WD", "DQ", "MDF", "DNS"):
        pos = dv if dv in ("CUT", "WD", "DQ", "MDF", "DNS") else "CUT"
    total = up((comp.get("score", {}) or {}).get("displayValue", ""))
    if total == "" or total == "-":
        total = "E" if stype != "STATUS_SCHEDULED" or period > 1 else "-"
    thru_n = st.get("thru", 0) or 0
    thru = ""
    tee = ""
    if stype == "STATUS_FINISH" or thru_n >= 18 or dv == "F":
        thru = "F"
    elif stype == "STATUS_SCHEDULED" or thru_n == 0:
        tu = iso_unix(st.get("teeTime", ""))
        if tu != None and have_tz:
            tee = clock(tu + off, False)
        thru = tee if tee != "" else "-"
    else:
        thru = str(int(thru_n))
        if (st.get("startHole", 1) or 1) == 10:
            thru = thru + "*"
    if pos in ("CUT", "WD", "DQ", "MDF", "DNS"):
        thru = ""
    today = ""
    for ls in comp.get("linescores", []) or []:
        if ls.get("period", 0) == period and ls.get("displayValue", None) != None:
            today = up(ls.get("displayValue", ""))
    holes = int(thru_n) if thru_n else 0
    done = thru == "F"
    if done:
        holes = 18
    return {
        "holes": holes,
        "start_hole": int(st.get("startHole", 1) or 1),
        "done": done,
        "pos": pos if pos != "" else "-",
        "last": last,
        "initial": first[:1],
        "full": up(disp),
        "total": total,
        "thru": thru,
        "tee": tee,
        "today": today,
        "sort": comp.get("sortOrder", 9999) or 9999,
        "state": stype,
    }

def calendar_of(sb):
    lg = (sb.get("leagues", []) or [{}])
    if not lg:
        return []
    out = []
    for e in lg[0].get("calendar", []) or []:
        if type(e) != "dict":
            continue
        out.append({
            "id": str(e.get("id", "")),
            "name": e.get("label", ""),
            "start": e.get("startDate", ""),
            "end": e.get("endDate", ""),
        })
    return out

def upcoming(cal, today, skip_id):
    out = []
    for e in cal:
        d = iso_day(e["start"])
        if d != None and d >= today and e["id"] != skip_id:
            out.append(e)
    return sorted(out, key = lambda e: e["start"])

# The most recent calendar event that actually finished (cancelled ones are
# skipped), as {event, winner, score, margin, dates}.
def last_result(ctx, tour, cal, today, skip_id):
    past = []
    for e in cal:
        d = iso_day(e["end"])
        if d != None and d < today and e["id"] != skip_id:
            past.append(e)
    past = sorted(past, key = lambda e: e["end"], reverse = True)
    tries = 0
    for e in past:
        if tries >= 3:
            break
        tries += 1
        lb = fetch(LB_URL, 21600, {"league": tour["league"], "event": e["id"]})
        if lb == None:
            continue
        evs = lb.get("events", []) or []
        if not evs:
            continue
        ev = evs[0]
        stype = ((ev.get("status", {}) or {}).get("type", {}) or {})
        if not stype.get("completed", False):
            continue
        comps = ev.get("competitions", []) or []
        if not comps:
            continue
        players = sorted(comps[0].get("competitors", []) or [], key = lambda p: p.get("sortOrder", 9999) or 9999)
        if not players:
            continue
        w = parse_player(players[0], 0, 0, False)
        margin = ""
        if len(players) > 1:
            p2 = parse_player(players[1], 0, 0, False)
            if p2["pos"] in ("1", "T1") or w["pos"] == "T1":
                margin = "PLAYOFF"
            else:
                a = to_par_int(w["total"])
                b = to_par_int(p2["total"])
                if a != None and b != None and b > a:
                    margin = "BY " + str(b - a)
        return {
            "event": ev.get("name", e["name"]),
            "winner": w,
            "score": w["total"],
            "margin": margin,
            "dates": date_range(e["start"], e["end"]),
        }
    return None

def to_par_int(s):
    if s == "E":
        return 0
    t = s.lstrip("+")
    neg = t.startswith("-")
    t = t.lstrip("-")
    if t == "" or not t.isdigit():
        return None
    return -int(t) if neg else int(t)

def get_state(ctx, tour):
    dbg = ctx.inputs.get("_debug", "")
    if dbg != "" and dbg != None:
        return mock_state(ctx, tour, dbg)
    sb = fetch(SB_URL % tour["league"], 300)
    if sb == None:
        return {"mode": "error"}
    today = ctx.now.unix // 86400
    cal = calendar_of(sb)
    evs = sb.get("events", []) or []
    ev = None
    for e in evs:
        if ((e.get("status", {}) or {}).get("type", {}) or {}).get("state", "") == "in":
            ev = e
    if ev == None and evs:
        ev = evs[0]
    st = {"mode": "off", "cal": cal, "today": today, "players": [], "canceled": False,
          "event": "", "course": "", "place": "", "city": "", "dates": "", "start": "", "id": "",
          "round": 0, "rounds": 4, "status": "", "purse": "", "defending": "",
          "par": "", "yards": "", "field": 0, "note": ""}
    if ev != None:
        st["id"] = str(ev.get("id", ""))
        st["event"] = ev.get("name", "")
        st["start"] = ev.get("date", "")
        st["dates"] = date_range(ev.get("date", ""), ev.get("endDate", ""))
        etype = ((ev.get("status", {}) or {}).get("type", {}) or {})
        ename = etype.get("name", "")
        estate = etype.get("state", "")
        lb = fetch(LB_URL, 120 if estate == "in" else 600, {"league": tour["league"], "event": st["id"]})
        lev = None
        if lb != None and (lb.get("events", []) or []):
            lev = lb["events"][0]
        if lev != None:
            courses = lev.get("courses", []) or []
            host = courses[0] if courses else None
            for cc in courses:
                if cc.get("host", False):
                    host = cc
            if host != None:
                st["course"] = short_course(host.get("name", ""))
                st["place"] = place_of(host)
                st["city"] = up(((host.get("address", {}) or {}).get("city", "")))
                if (host.get("shotsToPar", 0) or 0) > 0:
                    st["par"] = str(host.get("shotsToPar"))
                if (host.get("totalYards", 0) or 0) > 0:
                    st["yards"] = str(host.get("totalYards"))
            st["purse"] = short_money(lev.get("displayPurse", ""))
            dc = ((lev.get("defendingChampion", {}) or {}).get("athlete", {}) or {}).get("displayName", "")
            st["defending"] = up(dc)
            st["rounds"] = ((lev.get("tournament", {}) or {}).get("numberOfRounds", 4)) or 4
            comps = lev.get("competitions", []) or []
            if comps:
                cst = comps[0].get("status", {}) or {}
                st["round"] = cst.get("period", 0) or 0
                ctype = (cst.get("type", {}) or {})
                if ctype.get("name", "") != "":
                    ename = ctype.get("name", ename)
                    estate = ctype.get("state", estate)
                raw = comps[0].get("competitors", []) or []
                st["field"] = len(raw)
                raw = sorted(raw, key = lambda p: p.get("sortOrder", 9999) or 9999)
                off, have_tz = 0, False
                if estate != "post" and raw:
                    off, have_tz = tz_offset(ctx)
                if estate == "pre":
                    # earliest tee time in the field, for the FIRST TEE box
                    first = None
                    for comp in raw:
                        tu = iso_unix((comp.get("status", {}) or {}).get("teeTime", ""))
                        if tu != None and (first == None or tu < first):
                            first = tu
                    if first != None and have_tz:
                        st["first_tee"] = first + off
                else:
                    ps = []
                    for comp in raw[:ROWS_PER_COL * 4]:
                        ps.append(parse_player(comp, st["round"], off, have_tz))
                    st["players"] = ps
        if ename in ("STATUS_CANCELED", "STATUS_POSTPONED"):
            st["mode"] = "off"
            st["canceled"] = True
            st["note"] = "CANCELLED" if ename == "STATUS_CANCELED" else "POSTPONED"
        elif estate == "in":
            st["mode"] = "live"
            if ename == "STATUS_PLAY_COMPLETE":
                st["status"] = "ROUND " + str(st["round"]) + " COMPLETE"
            elif ename == "STATUS_SUSPENDED":
                st["status"] = "PLAY SUSPENDED"
            elif ename == "STATUS_DELAYED":
                st["status"] = "WEATHER DELAY"
            else:
                st["status"] = "ROUND " + str(st["round"])
        elif estate == "post":
            st["mode"] = "final"
        elif st["field"] > 0:
            st["mode"] = "pre"
        else:
            st["mode"] = "off"
    return st

# ---------------------------------------------------------------- mock

MOCK_FIELD = {
    "eur": [
        ("1", "Tommy", "Fleetwood", "-14", "14", "-5"),
        ("T2", "Nicolai", "Højgaard", "-12", "F", "-4"),
        ("T2", "Ludvig", "Åberg", "-12", "16*", "-6"),
        ("4", "Matt", "Fitzpatrick", "-11", "F", "-2"),
        ("T5", "Rasmus", "Neergaard-Petersen", "-10", "12", "-3"),
        ("T5", "Tyrrell", "Hatton", "-10", "F", "-1"),
        ("T5", "Alex", "Fitzpatrick", "-10", "9*", "-4"),
        ("8", "Aaron", "Rai", "-9", "17", "-2"),
        ("T9", "Thomas", "Detry", "-8", "F", "E"),
        ("T9", "Sepp", "Straka", "-8", "13", "-1"),
        ("T9", "Mathieu", "Decottignies-Lafon", "-8", "11:40", ""),
        ("T12", "Shane", "Lowry", "-7", "F", "+1"),
        ("T12", "Thorbjørn", "Olesen", "-7", "15", "-2"),
        ("T12", "Adrián", "Otaegui", "-7", "12:05", ""),
        ("T15", "Frankie", "Capan III", "-6", "8", "+2"),
        ("T15", "Rory", "McIlroy", "-6", "F", "+3"),
    ],
    "champions-tour": [
        ("1", "Steve", "Stricker", "-11", "12", "-4"),
        ("2", "Bernhard", "Langer", "-10", "F", "-5"),
        ("T3", "Padraig", "Harrington", "-9", "15", "-3"),
        ("T3", "Ernie", "Els", "-9", "F", "-2"),
        ("T3", "Stewart", "Cink", "-9", "10*", "-4"),
        ("6", "Miguel Ángel", "Jiménez", "-8", "F", "E"),
        ("T7", "Retief", "Goosen", "-7", "14", "-2"),
        ("T7", "Jerry", "Kelly", "-7", "F", "-1"),
        ("T9", "Alex", "Čejka", "-6", "11", "-1"),
        ("T9", "Doug", "Barron", "-6", "F", "+1"),
        ("T9", "K.J.", "Choi", "-6", "7*", "-2"),
        ("T12", "Y.E.", "Yang", "-5", "F", "E"),
        ("T12", "Richard", "Bland", "-5", "13", "-1"),
        ("T12", "Ken", "Tanigawa", "-5", "1:10", ""),
        ("T15", "Paul", "Broadhurst", "-4", "F", "+2"),
        ("T15", "Colin", "Montgomerie", "-4", "9", "+1"),
    ],
    "ntw": [
        ("1", "Johnny", "Keefer", "-17", "13", "-6"),
        ("T2", "Adrien", "Dumont de Chassart", "-15", "F", "-3"),
        ("T2", "Pierceson", "Coody", "-15", "15", "-5"),
        ("4", "Frankie", "Capan III", "-14", "F", "-2"),
        ("T5", "John", "VanDerLaan", "-13", "11*", "-4"),
        ("T5", "Hamilton", "Coleman", "-13", "F", "-1"),
        ("7", "Tim", "Widing", "-12", "16", "-3"),
        ("T8", "Emilio", "González", "-11", "F", "E"),
        ("T8", "Neal", "Shipley", "-11", "9", "-2"),
        ("T8", "Jackson", "Suber", "-11", "12:20", ""),
        ("T11", "Chandler", "Blanchet", "-10", "F", "+1"),
        ("T11", "Kevin", "Velo", "-10", "14", "-1"),
        ("T11", "Ricky", "Castillo", "-10", "10", "E"),
        ("T14", "Trace", "Crowe", "-9", "F", "+2"),
        ("T14", "Rasmus", "Højgaard", "-9", "12:40", ""),
        ("T14", "Zach", "Bauchou", "-9", "6*", "+1"),
    ],
    "liv": [
        ("1", "Jon", "Rahm", "-15", "15", "-6"),
        ("2", "Bryson", "DeChambeau", "-13", "F", "-4"),
        ("T3", "Joaquín", "Niemann", "-12", "14", "-3"),
        ("T3", "Tyrrell", "Hatton", "-12", "F", "-5"),
        ("T3", "Cameron", "Smith", "-12", "12", "-2"),
        ("6", "Sergio", "García", "-11", "F", "-1"),
        ("T7", "Dustin", "Johnson", "-10", "13", "-3"),
        ("T7", "Brooks", "Koepka", "-10", "F", "E"),
        ("T9", "Talor", "Gooch", "-9", "16", "-2"),
        ("T9", "Louis", "Oosthuizen", "-9", "F", "+1"),
        ("T9", "Patrick", "Reed", "-9", "11", "-2"),
        ("T12", "Abraham", "Ancer", "-8", "F", "E"),
        ("T12", "Michael", "La Sasso", "-8", "10", "-1"),
        ("T12", "Carlos", "Ortiz", "-8", "F", "+1"),
        ("T15", "Bubba", "Watson", "-7", "9", "+2"),
        ("T15", "Paul", "Casey", "-7", "F", "+3"),
    ],
}

MOCK_EVENT = {
    "eur": ("Alfred Dunhill Links Championship", "St Andrews (Old Course)", "ST ANDREWS, SCOTLAND", "$5M", "72", "7318", "TYRRELL HATTON"),
    "champions-tour": ("SAS Championship", "Prestonwood Country Club", "CARY, NC", "$2.1M", "72", "7137", "DAVID TOMS"),
    "ntw": ("Nationwide Children's Hospital Championship", "OSU Golf Club (Scarlet Course)", "COLUMBUS, OH", "$1.5M", "71", "7455", "JOHN VANDERLAAN"),
    "liv": ("LIV Golf Indianapolis", "The Club at Chatham Hills", "WESTFIELD, IN", "$25M", "72", "7700", "SERGIO GARCIA"),
}

def mock_state(ctx, tour, mode):
    variant = mode
    if mode in ("complete", "suspended"):
        mode = "live"
    lg = tour["league"]
    today = ctx.now.unix // 86400
    ev = MOCK_EVENT[lg]
    players = []
    for row in MOCK_FIELD[lg]:
        pos, first, last, total, thru, todayv = row
        th = thru
        if mode == "final" or variant == "complete":
            th = "F"
        if mode == "live" and ":" in thru:
            th = thru
        holes = 0
        sh = 1
        if th == "F":
            holes = 18
        elif ":" not in th:
            holes = int(th.rstrip("*"))
            sh = 10 if th.endswith("*") else 1
        players.append({
            "holes": holes, "start_hole": sh, "done": th == "F",
            "pos": pos, "last": last_name("", last, first + " " + last),
            "initial": up(first)[:1], "full": up(first + " " + last),
            "total": total, "thru": th, "tee": "", "today": todayv, "sort": 0, "state": "",
        })
    def iso(d):
        y, m, dd = civil_from_days(d)
        return str(y) + "-" + ("0" if m < 10 else "") + str(m) + "-" + ("0" if dd < 10 else "") + str(dd) + "T07:00Z"
    cal = [
        {"id": "p2", "name": "Omega European Masters", "start": iso(today - 21), "end": iso(today - 18)},
        {"id": "p1", "name": "BMW PGA Championship", "start": iso(today - 7), "end": iso(today - 4)},
        {"id": "n1", "name": ev[0], "start": iso(today + 7), "end": iso(today + 10)},
        {"id": "n2", "name": "Open de España pres. by Madrid", "start": iso(today + 14), "end": iso(today + 17)},
        {"id": "n3", "name": "DP World India Championship", "start": iso(today + 21), "end": iso(today + 24)},
    ]
    st = {"mode": mode, "cal": cal, "today": today, "players": players, "canceled": False,
          "event": ev[0], "course": short_course(ev[1]), "place": ev[2],
          "dates": date_range(iso(today - 1), iso(today + 2)), "start": iso(today - 1), "id": "cur",
          "round": 3, "rounds": 4, "status": "ROUND 3", "purse": ev[3], "defending": ev[6],
          "par": ev[4], "yards": ev[5], "field": 144, "note": "", "mock": True}
    if lg == "champions-tour":
        st["round"] = 2
        st["rounds"] = 3
        st["status"] = "ROUND 2"
    if variant == "complete":
        st["status"] = "ROUND " + str(st["round"]) + " COMPLETE"
    if variant == "suspended":
        st["status"] = "PLAY SUSPENDED"
    if mode == "final":
        st["round"] = st["rounds"]
        st["status"] = "FINAL"
        for p in players:
            p["pos"] = p["pos"]
        players[0]["total"] = "-16"
    if mode == "pre":
        st["dates"] = date_range(iso(today), iso(today + 3))
        st["start"] = iso(today)
        st["round"] = 1
        st["players"] = []
        st["first_tee"] = today * 86400 + 7 * 3600 + 20 * 60
    if mode == "off":
        st["event"] = ""
        st["players"] = []
        st["id"] = ""
    return st

def mock_last(tour):
    ev = MOCK_EVENT[tour["league"]]
    w = {"pos": "1", "last": "HOJGAARD", "initial": "R", "full": "RASMUS HOJGAARD",
         "total": "-18", "thru": "F", "tee": "", "today": "", "sort": 0, "state": ""}
    return {"event": "BMW PGA Championship", "winner": w, "score": "-18", "margin": "BY 2",
            "dates": "SEP 17-20"}

# ---------------------------------------------------------------- chrome

def draw_error(c, tour, title, sub):
    c.fill(COL["bg"])
    c.image(tour["logo"], EDGE, 4)
    x = EDGE + 24 + 6
    maxw = c.width - EDGE - x
    c.text(clip(c, tour["name"], "4x5", maxw), x, 3, font = "4x5", color = tour["accent"])
    c.text(clip(c, title, "6x8", maxw), x, 12, font = "6x8", color = COL["error"])
    c.text(clip(c, sub, "4x5", maxw), x, 24, font = "4x5", color = COL["muted"])

def live_dot(c, x, y, col):
    # 5x5 round LED dot (corners knocked out), the height of a 4x5 line
    c.rect(x + 1, y, x + 3, y + 4, fill = col)
    c.rect(x, y + 1, x + 4, y + 3, fill = col)

def sep_dot(c, x, y, col):
    c.pixel(x, y, col)

def segs_width(c, segs):
    n = 0
    for t, col in segs:
        if t == "":
            continue
        if n > 0:
            n += 4
        n += c.text_width(t, "4x5")
    return n

# Row of 4x5 segments separated by 1-px dots: [(text, color)], left at x.
def draw_segments(c, segs, x, y, max_w):
    cx = x
    for i in range(len(segs)):
        t, col = segs[i]
        if t == "":
            continue
        if cx > x:
            sep_dot(c, cx + 1, y + 2, COL["dim"])
            cx += 4
        room = x + max_w - cx
        s = clip(c, t, "4x5", room)
        if s == "":
            break
        c.text(s, cx, y, font = "4x5", color = col)
        cx += c.text_width(s, "4x5")
    return cx

# ---------------------------------------------------------------- page 1: hero

BOX_W = 58

def event(c, ctx):
    tour = tour_of(ctx)
    st = get_state(ctx, tour)
    c.fill(COL["bg"])
    if st["mode"] == "error":
        draw_error(c, tour, "NO SIGNAL", "ESPN LEADERBOARD UNAVAILABLE")
        return

    # identity column
    c.image(tour["logo"], EDGE, 4)

    # hero box on the right, washed in the tour tint with a chip-colour spine
    bx0 = c.width - EDGE - BOX_W
    bx1 = c.width - EDGE - 1
    c.rect(bx0, 1, bx1, 30, fill = tour["tint"])
    c.rect(bx0, 1, bx0, 30, fill = tour["chip"])

    mx0 = EDGE + 24 + 5
    mw = bx0 - 5 - mx0

    mode = st["mode"]
    if mode in ("live", "final"):
        draw_event_block(c, tour, st, mx0, mw, st["event"])
        draw_leader_box(c, tour, st, bx0 + 5, bx1 - 3)
        return
    if mode == "pre":
        draw_event_block(c, tour, st, mx0, mw, st["event"])
        draw_start_box(c, tour, st, bx0 + 5, bx1 - 3, True)
        return

    # off: next event on the calendar (or season complete)
    nxt = upcoming(st["cal"], st["today"], st["id"] if st["canceled"] else "")
    if st["canceled"] and st["event"] != "":
        # the scheduled event was called off -- say so, then point forward
        cst = dict(st)
        cst["status"] = st["note"]
        draw_event_block(c, tour, cst, mx0, mw, st["event"])
        if nxt:
            n = nxt[0]
            draw_next_box(c, tour, n, st["today"], bx0 + 5, bx1 - 3)
        else:
            draw_tba_box(c, tour, bx0 + 5, bx1 - 3)
        return
    if nxt:
        n = nxt[0]
        nst = dict(st)
        if st["event"] == "" or up(st["event"]) != up(n["name"]):
            nst["course"] = ""
            nst["place"] = ""
        nst["dates"] = date_range(n["start"], n["end"])
        nst["status"] = "NEXT EVENT"
        draw_event_block(c, tour, nst, mx0, mw, n["name"])
        draw_next_box(c, tour, n, st["today"], bx0 + 5, bx1 - 3)
        return
    sst = dict(st)
    sst["status"] = "SEASON COMPLETE"
    sst["course"] = ""
    sst["place"] = ""
    sst["dates"] = ""
    draw_event_block(c, tour, sst, mx0, mw, "SEE YOU NEXT SEASON")
    draw_tba_box(c, tour, bx0 + 5, bx1 - 3)

def draw_event_block(c, tour, st, x, w, name):
    # row 1: tour mark
    c.text(clip(c, tour["name"], "4x5", w), x, 2, font = "4x5", color = tour["accent"])

    # row 2: event name, biggest font / fullest wording that fits
    nm, nf = fit_event(c, name, w)
    c.text(nm, x, top_for(nf, 16), font = nf, color = COL["text"])

    # row 3: course + place (or dates when there's no course yet)
    segs = []
    if st["course"] != "":
        cvs = course_variants(st["course"])
        pick = None
        for pl in [st["place"], st.get("city", "")]:
            if pl == "" or pick != None:
                continue
            for cv in cvs:
                cand = [(cv, COL["muted"]), (pl, COL["muted"])]
                if segs_width(c, cand) <= w:
                    pick = cand
                    break
        if pick == None:
            cv, _ = fit_ladder(c, cvs, ["4x5"], w)
            pick = [(cv, COL["muted"])]
        segs = pick
    elif st["place"] != "":
        segs = [(st["place"], COL["muted"])]
    elif st["dates"] != "":
        segs = [(st["dates"], COL["muted"])]
    draw_segments(c, segs, x, 19, w)

    # row 4: status line
    mode = st["mode"]
    y = 26
    if mode == "live":
        s = st["status"]
        col = COL["live"]
        if "SUSPENDED" in s or "DELAY" in s:
            col = COL["warn"]
        elif "COMPLETE" in s:
            col = COL["text"]
        cx = x
        if col == COL["live"]:
            live_dot(c, cx, y, col)
            cx += 8
        room = x + w - cx
        cands = []
        if st["rounds"] and "ROUND" in s and "COMPLETE" not in s:
            cands.append([(s + " OF " + str(st["rounds"]), col), (st["dates"], COL["muted"])])
        cands.append([(s, col), (st["dates"], COL["muted"])])
        if st["rounds"] and "ROUND" in s and "COMPLETE" not in s:
            cands.append([(s + " OF " + str(st["rounds"]), col)])
        cands.append([(s, col)])
        pick = cands[len(cands) - 1]
        for cand in cands:
            if segs_width(c, cand) <= room:
                pick = cand
                break
        draw_segments(c, pick, cx, y, room)
    elif mode == "final":
        draw_segments(c, [("FINAL", COL["gold"]), (st["dates"], COL["muted"])], x, y, w)
    elif mode == "pre":
        draw_segments(c, [(st["dates"], COL["text"]), (str(st["rounds"]) + " ROUNDS", COL["muted"])], x, y, w)
    else:
        scol = COL["error"] if st["status"] in ("CANCELLED", "POSTPONED") else tour["accent"]
        segs = [(st["status"], scol)]
        if st["status"] not in ("CANCELLED", "POSTPONED") and st["course"] != "" and st["dates"] != "":
            segs.append((st["dates"], COL["text"]))
        elif st["status"] == "NEXT EVENT" and st["dates"] != "" and st["place"] != "":
            segs.append((st["dates"], COL["text"]))
        elif st["dates"] != "":
            segs.append((st["dates"], COL["muted"]))
        draw_segments(c, segs, x, y, w)

def box_label(c, text, col, x0, x1):
    c.text(clip(c, text, "4x5", x1 - x0 + 1), x0, 3, font = "4x5", color = col)

def draw_leader_box(c, tour, st, x0, x1):
    ps = st["players"]
    final = st["mode"] == "final"
    if not ps:
        # event is on but the leaderboard feed didn't answer
        box_label(c, "CHAMPION" if final else "LEADER", COL["gold"] if final else tour["accent"], x0, x1)
        c.text("--", x0, 11, font = "9x12_bold", color = COL["muted"])
        c.text(clip(c, "NO SCORES", "4x5", x1 - x0 + 1), x0, 25, font = "4x5", color = COL["muted"])
        return
    p = ps[0]
    tied = len(ps) > 1 and ps[1]["pos"] == p["pos"] and p["pos"].startswith("T")
    label = "CHAMPION" if final else ("CO-LEAD" if tied else "LEADER")
    box_label(c, label, COL["gold"] if final else tour["accent"], x0, x1)
    w = x1 - x0 + 1
    variants = [p["full"], p["initial"] + ". " + p["last"], p["last"]] + name_variants(p, False)
    nm, nf = fit_ladder(c, variants, ["5x7", "4x7"], w)
    c.text(nm, x0, top_for(nf, 16), font = nf, color = COL["text"])
    # hero score
    sc = p["total"]
    c.text(sc, x0, 18, font = "9x12_bold", color = score_color(sc))
    sw = c.text_width(sc, "9x12_bold")
    # right of the score: THRU / today, or the margin on a final
    rx = x0 + sw + 3
    rw = x1 - rx + 1
    if final:
        m = st.get("margin", "")
        if m == "" and len(ps) > 1:
            a = to_par_int(p["total"])
            b = to_par_int(ps[1]["total"])
            if a != None and b != None and b > a:
                m = "BY " + str(b - a)
            elif a != None and b != None and b == a:
                m = "PLAYOFF"
        if m.startswith("BY "):
            c.text(clip(c, "WON", "4x5", rw), rx, 19, font = "4x5", color = COL["muted"])
            c.text(clip(c, m, "4x5", rw), rx, 25, font = "4x5", color = COL["text"])
        elif m != "":
            c.text(clip(c, m, "4x5", rw), rx, 25, font = "4x5", color = COL["text"])
        return
    th = p["thru"]
    if th == "F":
        top, bot = ("R" + str(st["round"])) if st["round"] else "TODAY", p["today"]
        botc = score_color(p["today"])
        if bot == "":
            top, bot, botc = "THRU", "F", COL["text"]
    elif ":" in th or th == "-":
        top, bot, botc = "TEES", th, COL["text"]
    else:
        top, bot, botc = "THRU", th, COL["text"]
    c.text(clip(c, top, "4x5", rw), rx, 19, font = "4x5", color = COL["muted"])
    c.text(clip(c, bot, "4x5", rw), rx, 25, font = "4x5", color = botc)

def draw_start_box(c, tour, st, x0, x1, pre):
    ft = st.get("first_tee", None)
    today = st["today"]
    sd = iso_day(st["start"])
    w = x1 - x0 + 1
    if ft != None:
        box_label(c, "FIRST TEE", tour["accent"], x0, x1)
        t = clock(ft, False)
        ampm = "AM" if (ft % 86400) < 43200 else "PM"
        c.text(t, x0, 9, font = "9x12_bold", color = COL["text"])
        tx = x0 + c.text_width(t, "9x12_bold") + 2
        if tx + c.text_width(ampm, "4x5") <= x1:
            c.text(ampm, tx, 16, font = "4x5", color = COL["text"])
        dd = ft // 86400
        wd = DOW[dd % 7]
        when = "TODAY" if dd == today else ("TOMORROW" if dd == today + 1 else wd + " " + md(dd))
        c.text(clip(c, when, "4x5", w), x0, 25, font = "4x5", color = COL["muted"])
        return
    draw_date_box(c, tour, sd, today, x0, x1, "STARTS")

def draw_next_box(c, tour, n, today, x0, x1):
    draw_date_box(c, tour, iso_day(n["start"]), today, x0, x1, "STARTS")

def draw_date_box(c, tour, sd, today, x0, x1, label):
    w = x1 - x0 + 1
    box_label(c, label, tour["accent"], x0, x1)
    if sd == None:
        c.text("TBA", x0, 12, font = "9x12_bold", color = COL["text"])
        return
    y, m, d = civil_from_days(sd)
    # month sits on the day number's baseline
    c.text(MONTHS[m - 1], x0, top_for("5x7", 20), font = "5x7", color = COL["text"])
    mw = c.text_width(MONTHS[m - 1], "5x7")
    c.text(str(d), x0 + mw + 3, 9, font = "9x12_bold", color = COL["text"])
    diff = sd - today
    if diff <= 0:
        when = "TODAY"
    elif diff == 1:
        when = "TOMORROW"
    else:
        when = "IN " + str(diff) + " DAYS"
    c.text(clip(c, when, "4x5", w), x0, 25, font = "4x5", color = COL["muted"])

def draw_tba_box(c, tour, x0, x1):
    box_label(c, "NEXT", tour["accent"], x0, x1)
    c.text("TBA", x0, 10, font = "9x12_bold", color = COL["text"])
    c.text(clip(c, "SCHEDULE", "4x5", x1 - x0 + 1), x0, 25, font = "4x5", color = COL["muted"])

# ---------------------------------------------------------------- boards

def board1(c, ctx):
    draw_board_page(c, ctx, 0)

def board2(c, ctx):
    draw_board_page(c, ctx, 1)

def draw_board_page(c, ctx, page):
    tour = tour_of(ctx)
    st = get_state(ctx, tour)
    c.fill(COL["bg"])
    if st["mode"] == "error":
        draw_error(c, tour, "NO SIGNAL", "ESPN LEADERBOARD UNAVAILABLE")
        return
    if st["mode"] in ("live", "final"):
        draw_leaderboard(c, tour, st, page * ROWS_PER_COL * 2)
        return
    if page == 0:
        res = mock_last(tour) if st.get("mock", False) else last_result(ctx, tour, st["cal"], st["today"], st["id"])
        draw_last_winner(c, tour, res)
        return
    if st["mode"] == "pre":
        draw_facts(c, tour, st)
        return
    skip = st["id"]
    nxt = upcoming(st["cal"], st["today"], skip)
    draw_schedule(c, tour, nxt)

# Two columns of three. Each row: position chip, name, to-par, and under the
# name a hole-by-hole strip -- 18 ticks, the holes played this round lit in
# the tour accent (a back-nine starter lights 10-18 first), the hole just
# finished in white. A completed round is a dim full strip; a player who
# hasn't teed off yet shows an empty one.
ROWS_PER_COL = 3

def dim_hex(hex_color, pct):
    h = hex_color.lstrip("#")
    r = int(h[0:2], 16) * pct // 100
    g = int(h[2:4], 16) * pct // 100
    b = int(h[4:6], 16) * pct // 100
    return "#" + hex2(r) + hex2(g) + hex2(b)

HEX = "0123456789ABCDEF"

def hex2(n):
    return HEX[n // 16] + HEX[n % 16]

def draw_hole_strip(c, p, tour, x0, x1, y):
    avail = x1 - x0 + 1
    step = (avail + 1) // 18
    if step < 2:
        step = 2
    tick = step - 1
    n = p.get("holes", 0)
    sh = p.get("start_hole", 1)
    done = p.get("done", False)
    lit = {}
    last = -1
    for k in range(n if n < 18 else 18):
        h = (sh - 1 + k) % 18
        lit[h] = True
        last = h
    for h in range(18):
        tx = x0 + h * step
        if done:
            col = dim_hex(tour["accent"], 32)
        elif h == last:
            col = "#FFFFFF"
        elif lit.get(h, False):
            col = tour["accent"]
        else:
            col = "#1E2632"
        c.rect(tx, y, tx + tick - 1, y, fill = col)

def draw_leaderboard(c, tour, st, start):
    per = ROWS_PER_COL * 2
    rows = st["players"][start:start + per]
    if not rows:
        msg = "FIELD ENDS HERE" if st["players"] else "SCORES UNAVAILABLE"
        c.text(msg, c.width // 2, 13, font = "5x7", color = COL["muted"], align = "center")
        return
    mark_dupes(st["players"])
    gut = 6
    col_w = (c.width - 2 * EDGE - gut) // 2
    xs = [EDGE, EDGE + col_w + gut]
    # shared column widths for the page, so every row lines up
    chip_w = 15
    for p in rows:
        chip_w = max(chip_w, c.text_width(p["pos"], "4x5") + 3)
    score_w = 0
    for p in rows:
        score_w = max(score_w, tw(c, p["total"], "5x7"))
    name_off = chip_w + 3
    name_w = col_w - name_off - score_w - 5
    # column divider
    dx = EDGE + col_w + gut // 2 - 1
    c.rect(dx, 1, dx, 29, fill = COL["rule"])
    for i in range(len(rows)):
        p = rows[i]
        col = i // ROWS_PER_COL
        r = i % ROWS_PER_COL
        x0 = xs[col]
        x1 = x0 + col_w - 1
        y = 1 + r * 10
        # position chip, the full row height (name + strip)
        out = p["pos"] in ("CUT", "WD", "DQ", "MDF", "DNS")
        fill = COL["dim"] if out else tour["chip"]
        c.rect(x0, y, x0 + chip_w - 1, y + 8, fill = fill)
        c.text(p["pos"], x0 + chip_w // 2 + (chip_w % 2), y + 2, font = "4x5", color = ink_on(fill), align = "center")
        # to-par, right edge
        c.text(p["total"], x1, y, font = "5x7", color = score_color(p["total"]), align = "right")
        # name: largest font / fullest wording that fits the slot
        v = name_variants(p, p.get("dupe", False))
        nm, nf = fit_ladder(c, v, ["5x7", "4x7"], name_w)
        c.text(nm, x0 + name_off, top_for(nf, y + 6), font = nf, color = COL["text"])
        if not out:
            draw_hole_strip(c, p, tour, x0 + name_off, x1, y + 8)

def draw_card_head(c, tour, label, right):
    lw = c.text_width(label, "4x5") + 5
    c.rect(EDGE, 0, EDGE + lw - 1, 6, fill = tour["chip"])
    c.text(label, EDGE + 3, 1, font = "4x5", color = ink_on(tour["chip"]))
    if right != "":
        rx = EDGE + lw + 4
        rt, _ = fit_ladder(c, event_variants(right), ["4x5"], c.width - EDGE - rx)
        c.text(rt, rx, 1, font = "4x5", color = COL["muted"])

def draw_last_winner(c, tour, res):
    if res == None:
        draw_card_head(c, tour, "LAST WINNER", "")
        c.image(tour["logo"], EDGE, 8)
        c.text("NO RESULT YET", EDGE + 30, 13, font = "5x7", color = COL["muted"])
        return
    draw_card_head(c, tour, "LAST WINNER", "")
    w = res["winner"]
    # trophy-side: big score boxed on the right
    sc = res["score"]
    sw = c.text_width(sc, "9x12_bold")
    bx1 = c.width - EDGE - 1
    bx0 = bx1 - max(sw, 34) - 8
    c.rect(bx0, 1, bx1, 30, fill = tour["tint"])
    c.rect(bx0, 1, bx0, 30, fill = tour["chip"])
    cx = (bx0 + 1 + bx1) // 2 + 1
    c.text(sc, cx, 5, font = "9x12_bold", color = score_color(sc), align = "center")
    m = res.get("margin", "")
    if m != "":
        mt = "WON " + m if m.startswith("BY ") else m
        c.text(clip(c, mt, "4x5", bx1 - bx0 - 3), cx, 22, font = "4x5", color = COL["muted"], align = "center")
    # left: name hero, event under it
    x = EDGE
    maxw = bx0 - 5 - x
    variants = [w["full"], w["initial"] + ". " + w["last"], w["last"]]
    nm, nf = fit_ladder(c, variants, ["10x16", "6x8", "5x7"], maxw)
    c.text(nm, x, top_for(nf, 23) if nf != "10x16" else 8, font = nf, color = COL["text"])
    ev, ef = fit_ladder(c, event_variants(res["event"]), ["4x5"], maxw - c.text_width(res["dates"], "4x5") - 5)
    ex = draw_segments(c, [(ev, tour["accent"]), (res["dates"], COL["muted"])], x, 26, maxw)

# This week's numbers as a row of stat tiles -- label over value, spread
# across the panel with hairline dividers. The defending champion's name
# shortens (full -> T. HATTON -> HATTON) before a tile is dropped.
def draw_facts(c, tour, st):
    draw_card_head(c, tour, "THIS WEEK", st["event"])
    tiles = []
    if st["defending"] != "":
        d = st["defending"]
        ws = d.split(" ")
        dv = [d]
        if len(ws) >= 2:
            dv.append(ws[0][:1] + ". " + ws[len(ws) - 1])
            dv.append(ws[len(ws) - 1])
        tiles.append(["DEFENDING", dv])
    if st["purse"] != "":
        tiles.append(["PURSE", [st["purse"]]])
    if st["par"] != "":
        tiles.append(["PAR", [st["par"]]])
    if st["yards"] != "":
        y = st["yards"]
        if len(y) > 3:
            y = y[:len(y) - 3] + "," + y[len(y) - 3:]
        tiles.append(["YARDS", [y]])
    if st["field"] > 0:
        tiles.append(["FIELD", [str(st["field"])]])
    if st["rounds"]:
        tiles.append(["ROUNDS", [str(st["rounds"])]])
    if not tiles:
        c.text("DETAILS TBA", EDGE, 13, font = "5x7", color = COL["muted"])
        return
    avail = c.width - 2 * EDGE
    vf = "6x8"
    # choose wording/tiles until they fit with at least 7 px between tiles
    for attempt in range(8):
        widths = []
        vals = []
        for t in tiles:
            lab, vs = t[0], t[1]
            v = vs[0]
            vals.append(v)
            widths.append(max(c.text_width(lab, "4x5"), c.text_width(v, vf)))
        need = 0
        for wv in widths:
            need += wv
        need += 7 * (len(tiles) - 1)
        if need <= avail:
            break
        # drop ROUNDS, then shorten the defending name, then drop tiles
        if tiles[len(tiles) - 1][0] == "ROUNDS":
            tiles = tiles[:len(tiles) - 1]
        elif tiles[0][0] == "DEFENDING" and len(tiles[0][1]) > 1:
            tiles[0][1] = tiles[0][1][1:]
        elif len(tiles) > 2:
            tiles = tiles[:len(tiles) - 1]
        else:
            vf = "5x7"
    n = len(tiles)
    spare = avail - (need - 7 * (n - 1))
    gap = spare // (n - 1) if n > 1 else 0
    x = EDGE
    for i in range(n):
        lab = tiles[i][0]
        v = clip(c, vals[i], vf, widths[i])
        c.text(lab, x, 11, font = "4x5", color = tour["accent"])
        c.text(v, x, top_for(vf, 26), font = vf, color = COL["text"])
        x += widths[i]
        if i < n - 1:
            lx = x + gap // 2
            c.rect(lx, 11, lx, 26, fill = COL["rule"])
            x += gap

def draw_schedule(c, tour, nxt):
    draw_card_head(c, tour, "UP NEXT", "")
    if not nxt:
        c.text("SEASON COMPLETE", EDGE, 11, font = "6x8", color = COL["text"])
        c.text("NEXT SCHEDULE TBA", EDGE, 23, font = "4x5", color = COL["muted"])
        return
    rows = nxt[:3]
    dw = 0
    for e in rows:
        dw = max(dw, c.text_width(date_range(e["start"], e["end"]), "4x5"))
    for i in range(len(rows)):
        e = rows[i]
        y = 8 + i * 8
        d = date_range(e["start"], e["end"])
        c.text(d, EDGE + dw, y + 1, font = "4x5", color = tour["accent"] if i == 0 else COL["muted"], align = "right")
        nx = EDGE + dw + 5
        nm, nf = fit_ladder(c, event_variants(e["name"]), ["5x7", "4x7", "4x5"], c.width - EDGE - nx)
        c.text(nm, nx, top_for(nf, y + 6), font = nf, color = COL["text"] if i == 0 else "#C9D2DE")
    if len(rows) < 3:
        y = 8 + len(rows) * 8
        c.text("SEASON ENDS", EDGE + dw + 5, y + 1, font = "4x5", color = COL["dim"])
