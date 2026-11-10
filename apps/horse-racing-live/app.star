# Horse Racing Live -- the next race off, the latest result and the day's
# big race, on a 192x32 SCROLL panel.
#
# DESIGN. Fan research: racing fans follow the next race to the off (with
# the favourite's price), check results the moment they are official, and
# care most about the big days (Derby, Breeders' Cup, Cheltenham, Royal
# Ascot). So:
#   next     the next race off in your region, counted down to the second
#            stage the track reports (AT THE POST, LOADING, LIVE, PHOTO
#            FINISH), with the field size and the favourite's odds
#   result   the latest official result: the winner big, with saddle-cloth
#            number, odds, jockey and trainer, then 2nd and 3rd
#   feature  today's biggest race (Grade/Group 1 first) with the favourite,
#            Sporting Life's tip and, once it's run, the winner
# Every runner wears its North American saddle-cloth colour (1 red, 2
# white, 3 blue, 4 yellow...), the colours on every US tote board.
#
# Data, keyless (Sporting Life's racecard feed):
#   sportinglife.com/api/horse-racing/racing/racecards/<YYYY-MM-DD>
#       every meeting and race for a UK date, with each race's stage
#   sportinglife.com/api/horse-racing/race/<id>
#       one race: runners, jockeys, trainers, odds, finishing positions
# Race times are UK local time (Europe/London), so they are converted to
# UTC with the British Summer Time rule.

CARDS_URL = "https://www.sportinglife.com/api/horse-racing/racing/racecards/"
RACE_URL = "https://www.sportinglife.com/api/horse-racing/race/"
JSON_HEADERS = {
    "Accept": "application/json",
    "User-Agent": "Glance-GDN horse-racing-live (github.com/glance-led-dev/glance-dev-network)",
}

REGIONS = {
    "USA": ["USA"],
    "UK AND IRELAND": ["ENG", "Scot", "Wale", "Eire", "Nort"],
    "WORLDWIDE": [],
}

COLORS = {
    "bg": "#000000",
    "text": "#F4F7FB",
    "label": "#8A93A6",
    "dim": "#4B5563",
    "hair": "#1E2430",
    "gold": "#FFB020",
    "live": "#EF4444",
    "amber": "#F59E0B",
    "win": "#22C55E",
    "error": "#E8B04A",
    "error_sub": "#6A7090",
}

# North American saddle cloths: [cloth, number] by program number.
CLOTHS = {
    1: ["#E21B23", "#FFFFFF"],
    2: ["#FFFFFF", "#000000"],
    3: ["#1D4ED8", "#FFFFFF"],
    4: ["#FACC15", "#000000"],
    5: ["#16A34A", "#FFFFFF"],
    6: ["#000000", "#FACC15"],
    7: ["#F97316", "#000000"],
    8: ["#F472B6", "#000000"],
    9: ["#2DD4BF", "#000000"],
    10: ["#7E22CE", "#FFFFFF"],
    11: ["#9CA3AF", "#DC2626"],
    12: ["#84CC16", "#000000"],
    13: ["#8B5A2B", "#FFFFFF"],
    14: ["#881337", "#FACC15"],
    15: ["#BDB76B", "#000000"],
    16: ["#7DD3FC", "#DC2626"],
    17: ["#1E3A8A", "#FFFFFF"],
    18: ["#166534", "#FACC15"],
    19: ["#2563EB", "#DC2626"],
    20: ["#C026D3", "#FACC15"],
}

PRE_OFF = ["DORMANT", "DELAYED", "PARADING", "GOINGDOWN", "ATTHEPOST",
           "GOINGBEHIND", "GOINGINSTALLS", "UNDERORDERS"]
RUNNING = ["OFF", "FALSESTART"]
FINISHING = ["FINISHED", "PHOTOGRAPH"]
RESULTED = ["RESULT", "WEIGHEDIN", "AMENDEDRESULT"]
VOID = ["RACEVOID", "ABANDONED"]

STAGE_WORDS = {
    "DELAYED": "DELAYED",
    "PARADING": "PARADING",
    "GOINGDOWN": "GOING TO POST",
    "ATTHEPOST": "AT THE POST",
    "GOINGBEHIND": "LOADING",
    "GOINGINSTALLS": "LOADING",
    "UNDERORDERS": "UNDER ORDERS",
    "OFF": "RUNNING",
    "FALSESTART": "FALSE START",
    "FINISHED": "FINISHED",
    "PHOTOGRAPH": "PHOTO FINISH",
}

# Page 1's identity: a racehorse at full gallop, the jockey crouched over
# its neck -- red helmet, gold silks with a red stripe, white breeches,
# boot in the stirrup -- clear of the horse's back so the rider reads.
HORSE = """
....................CCC.........
...................CCCCCC.......
...............SSRRSSSFF.D......
..............SSSRRSSS..D.D.....
............WWWSSRRS.S.DHHHHH...
.............WWWWW....SDHHHDHH..
.................B...DDFHH.HHHH.
................B...DDHHH...HHH.
...DD..........B...DHHHH........
..D..DD...HHNNNNHHHHHH..........
.DD..DDHHHHHNNNNHHHHHHH.........
D......HHHHHNNNNHHHHHHH.........
.......HHHHHHHHHHHHHHHH.........
........HHHHHHHHHHHHHH..........
........HHHH......HHHH..........
.......HH..HH.....HH.HH.........
......HH...HH......HH.HH........
.....HH.....HH.....HH..HH.......
....DD......DD......DD..DD......
"""
HORSE_LEGEND = {"H": "#A65A2A", "D": "#4A2610", "N": "#FFFFFF", "C": "#E5322D", "F": "#F2C29B",
                "S": "#FFB020", "R": "#E5322D", "W": "#FFFFFF", "B": "#9CA3AF"}

# Page 3's identity: the trophy.
TROPHY = """
.GGGGGGGGG.
GG.GGGGG.GG
G..GGGGG..G
G..GGGGG..G
.G.GGGGG.G.
..GGGGGGG..
...GGGGG...
....GGG....
.....G.....
.....G.....
....GGG....
..GGGGGGG..
..GGGGGGG..
"""

LEFT = 10
RIGHT = 181


# ---- helpers -------------------------------------------------------------

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
    # Drop whole words from the end until it fits; never end mid-word.
    words = [w for w in str(text).split(" ") if w != ""]
    for n in range(len(words), 0, -1):
        trial = " ".join(words[:n]).rstrip(":,-&")
        if c.text_width(trial, font) <= max_w:
            return trial
    return clip(c, text, font, max_w)


def wrap2(c, text, font, max_w):
    # Up to two lines, broken at words; the second line clipped at a word.
    words = [w for w in str(text).split(" ") if w != ""]
    used = 0
    for n in range(1, len(words) + 1):
        if c.text_width(" ".join(words[:n]), font) > max_w:
            break
        used = n
    if used == 0:
        return [clip(c, text, font, max_w), ""]
    rest = " ".join(words[used:])
    return [" ".join(words[:used]), clip_words(c, rest, font, max_w) if rest != "" else ""]


def pad2(n):
    return ("0" if n < 10 else "") + str(n)


# ---- UK time ---------------------------------------------------------------

def days_from_civil(y, m, d):
    # [y, m, d] -> days since 1970-01-01 (Howard Hinnant's algorithm).
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


def last_sunday(y, m):
    # Day number of the last Sunday of month m (m is March or October).
    z = days_from_civil(y, m, 31)
    return z - (z + 4) % 7  # 1970-01-01 was a Thursday; (z + 4) % 7 == 0 is Sunday


def bst(unix):
    # British Summer Time: 01:00 UTC on the last Sunday of March until
    # 01:00 UTC on the last Sunday of October.
    y = civil_from_days(unix // 86400)[0]
    start = last_sunday(y, 3) * 86400 + 3600
    end = last_sunday(y, 10) * 86400 + 3600
    return unix >= start and unix < end


def uk_day(unix):
    # Day number of the UK calendar date at this moment.
    return (unix + (3600 if bst(unix) else 0)) // 86400


def day_string(z):
    ymd = civil_from_days(z)
    return str(ymd[0]) + "-" + pad2(ymd[1]) + "-" + pad2(ymd[2])


def uk_to_unix(date, time):
    # "2026-11-09", "17:10" (UK local) -> unix seconds.
    p = str(date).split("-")
    t = str(time).split(":")
    if len(p) != 3 or len(t) < 2:
        return 0
    local = days_from_civil(int(p[0]), int(p[1]), int(p[2])) * 86400 + int(t[0]) * 3600 + int(t[1]) * 60
    return local - 3600 if bst(local - 3600) else local


def countdown(secs):
    if secs < 60:
        return "DUE"
    mins = secs // 60
    if mins < 60:
        return str(mins) + " MIN"
    return str(mins // 60) + "H " + pad2(mins % 60) + "M"


def ago(secs):
    mins = max(0, secs) // 60
    if mins < 1:
        return "JUST NOW"
    if mins < 60:
        return str(mins) + " MIN AGO"
    return str(mins // 60) + "H AGO"


# ---- odds --------------------------------------------------------------------

def odds_parts(s):
    p = str(s or "").strip().split("/")
    if len(p) != 2 or not p[0].isdigit() or not p[1].isdigit() or int(p[1]) == 0:
        return None
    return [int(p[0]), int(p[1])]


def odds_value(s):
    # Fractional odds as a sortable number (x1000); unknown odds sort last.
    p = odds_parts(s)
    if p == None:
        return 999999999
    return p[0] * 1000 // p[1]


def fmt_odds(s, style, us_track):
    p = odds_parts(s)
    if p == None:
        return str(s or "").upper()
    if style == "DECIMAL":
        h = (p[0] * 1000 // p[1] + 5) // 10 + 100  # hundredths, rounded
        return str(h // 100) + "." + pad2(h % 100)
    us = style == "US STYLE" or (style == "TRACK STYLE" and us_track)
    if p[0] == p[1]:
        return "EVEN" if us else "EVS"
    return str(p[0]) + ("-" if us else "/") + str(p[1])


# ---- racecards ------------------------------------------------------------------

def is_trotting(name):
    # French cards include trotting (attele / monte); this app is for gallopers.
    n = str(name).lower()
    return n.endswith("- attele") or n.endswith("- monte") or n.endswith("attele") or n.endswith("monte")


def grade_of(name):
    # "G1", "G2", "G3", "L" (Listed) or "".
    n = " " + str(name).lower().replace("(", " ").replace(")", " ").replace("-", " ") + " "
    for g in ["1", "2", "3"]:
        for word in [" grade " + g + " ", " group " + g + " ", " g" + g + " ", " grade i" + ("i" * (int(g) - 1)) + " "]:
            if word in n:
                return "G" + g
    if " listed " in n:
        return "L"
    return ""


def clean_name(name):
    # "Race 4 - Breeders' Cup Filly & Mare Sprint - Grade 1" -> "BREEDERS' CUP FILLY & MARE SPRINT"
    n = str(name).strip()
    if n.startswith("Race ") and " - " in n:
        n = n[n.find(" - ") + 3:]
    for cut in [" Presented By ", " presented by ", " Sponsored By "]:
        if cut in n:
            n = n[:n.find(cut)]
    # Drop "(...)" notes (grade, GBB Race, Class, registered names).
    out = ""
    depth = 0
    for ch in n.elems():
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth = max(0, depth - 1)
        elif depth == 0:
            out += ch
    n = out
    for tail in [" - Grade 1", " - Grade 2", " - Grade 3", " - Group 1", " - Group 2", " - Group 3", " - Listed"]:
        if n.endswith(tail):
            n = n[:len(n) - len(tail)]
    return " ".join([w for w in n.split(" ") if w != ""]).upper()


def region_input(ctx):
    r = str(ctx.inputs.get("region", "USA")).upper()
    return r if r in REGIONS else "USA"


def odds_input(ctx):
    o = str(ctx.inputs.get("odds", "TRACK STYLE")).upper()
    return o if o in ["TRACK STYLE", "US STYLE", "UK STYLE", "DECIMAL"] else "TRACK STYLE"


def races_from(card, region):
    # Flatten one racecard day into races for the region, numbered per meeting.
    out = []
    allowed = REGIONS[region]
    for m in (card or []):
        ms = m.get("meeting_summary") or {}
        course = ms.get("course") or {}
        country = str((course.get("country") or {}).get("short_name") or "")
        if len(allowed) > 0 and country not in allowed:
            continue
        races = sorted(m.get("races") or [], key = lambda r: str(r.get("date") or "") + str(r.get("time") or ""))
        num = 0
        for r in races:
            if bool(r.get("hidden", False)) or is_trotting(r.get("name")):
                continue
            num += 1
            out.append({
                "id": str((r.get("race_summary_reference") or {}).get("id") or ""),
                "course": str(course.get("name") or r.get("course_name") or "").upper(),
                "us": country == "USA",
                "num": num,
                "raw_name": str(r.get("name") or ""),
                "name": clean_name(r.get("name") or ""),
                "grade": grade_of(r.get("name") or ""),
                "class": str(r.get("race_class") or ""),
                "unix": uk_to_unix(r.get("date"), r.get("time")),
                # When it actually went off ("17:14:54"), once it has.
                "off": uk_to_unix(r.get("date"), r.get("off_time")) if r.get("off_time") else 0,
                "stage": str(r.get("race_stage") or "DORMANT"),
                "rides": int(r.get("ride_count") or 0),
                "distance": str(r.get("distance") or "").upper(),
                "surface": str((r.get("course_surface") or {}).get("surface") or "").upper(),
                "verdict": str(r.get("verdict") or ""),
            })
    return out


def load_races(now, region, want_tomorrow):
    # Today's UK card, plus yesterday's while North American night racing
    # (UK date already rolled over) can still be running or just resulted.
    today = uk_day(now)
    races = []
    ok = False
    for z in [today - 1, today]:
        card = get_json(CARDS_URL + day_string(z), 60 if z == today else 120)
        if card != None:
            ok = True
            races += races_from(card, region)
    if want_tomorrow:
        upcoming = [r for r in races if r["stage"] in PRE_OFF and r["unix"] >= now - 1800]
        if len(upcoming) == 0:
            card = get_json(CARDS_URL + day_string(today + 1), 600)
            if card != None:
                races += races_from(card, region)
    return [ok, races]


def race_detail(rid, ttl):
    d = get_json(RACE_URL + rid, ttl) if rid != "" else None
    return d if type(d) == "dict" else None


def runners(detail):
    return [x for x in (detail.get("rides") or []) if str(x.get("ride_status") or "RUNNER") == "RUNNER"]


def favourite(detail):
    rs = runners(detail)
    for x in rs:
        if str(((x.get("betting") or {}).get("favourite") or {}).get("betting_favourite") or "") != "":
            return x
    best = None
    for x in rs:
        if odds_value((x.get("betting") or {}).get("current_odds")) == 999999999:
            continue
        if best == None or odds_value(x["betting"]["current_odds"]) < odds_value(best["betting"]["current_odds"]):
            best = x
    return best


def placed(detail, pos):
    for x in runners(detail):
        if int(x.get("finish_position") or 0) == pos:
            return x
    return None


def tip_of(verdict):
    # Sporting Life's verdict ends with an ordered list of picks; take the first.
    v = str(verdict)
    i = v.find("<li>")
    if i < 0:
        return ""
    v = v[i + 4:]
    j = v.find("</li>")
    if j >= 0:
        v = v[:j]
    out = ""
    depth = 0
    for ch in v.elems():
        if ch == "<":
            depth = 1
        elif ch == ">":
            depth = 0
        elif depth == 0:
            out += ch
    # "POETS WHISPER (IRE)" -> "POETS WHISPER"
    if " (" in out:
        out = out[:out.find(" (")]
    return out.strip().upper()


def horse_name(x):
    n = str(((x or {}).get("horse") or {}).get("name") or "").upper()
    if " (" in n:
        n = n[:n.find(" (")]
    return n


def person(x, key):
    return str(((x or {}).get(key) or {}).get("name") or "").upper()


def initial_surname(name):
    # "EMMANUEL ESQUIVEL" -> "E ESQUIVEL"; "D E SHEEHY" stays.
    w = [p for p in str(name).split(" ") if p != ""]
    if len(w) < 2 or len(w[0]) == 1:
        return " ".join(w)
    return w[0][0] + " " + " ".join(w[1:])


CLASS_SCORE = {"1": 65, "2": 50, "3": 45, "4": 40, "5": 30, "6": 20, "7": 15}


def race_tier(r):
    # How big a race is: graded/group first, then US stakes and the British
    # and Irish class (1 best). Plain "Stakes" is not a sign in Britain,
    # where novice and maiden races are called stakes too.
    g = r["grade"]
    n = r["raw_name"].lower()
    if g == "G1":
        return 100
    if g == "G2":
        return 90
    if g == "G3":
        return 80
    if g == "L":
        return 70
    if r["us"]:
        if "stakes" in n or "derby" in n or "handicap" in n:
            return 60
        if "allowance" in n:
            return 40
        if "maiden special" in n:
            return 35
        if "claiming" in n:
            return 10
        return 25
    return CLASS_SCORE.get(r["class"], 25)


def is_big(r):
    return race_tier(r) >= 60


# ---- drawing pieces --------------------------------------------------------------

def cloth(c, x, y, num, font):
    # A saddle cloth: the number on its standard colour; returns its width.
    n = int(num or 0)
    pal = CLOTHS.get(n, ["#4B5563", "#FFFFFF"])
    label = str(n) if n > 0 else "-"
    h = 7 if font == "4x5" else 9
    w = c.text_width(label, font) + 4
    c.rect(x, y, x + w - 1, y + h - 1, fill = pal[0])
    if n == 6:
        # A black cloth would vanish on the black panel; frame it.
        c.rect(x, y, x + w - 1, y + h - 1, outline = "#6B7280")
    c.text(label, x + 2, y + 1, font = font, color = pal[1])
    return w


def header(c, x, word, word_col, label, right, right_col, live):
    if live:
        c.fill_circle(x + 2, 3, 2, COLORS["live"])
        x += 7
    c.text(word, x, 1, font = "4x5", color = word_col)
    x += c.text_width(word, "4x5") + 4
    right_w = c.text_width(right, "4x5") if right != "" else 0
    if right != "":
        c.text(right, RIGHT, 1, font = "4x5", color = right_col, align = "right")
    c.text(clip_words(c, label, "4x5", RIGHT - right_w - 5 - x), x, 1, font = "4x5", color = COLORS["label"])


def runner_line(c, x, y, prefix, prefix_col, x_ride, odds, odds_col, name_col):
    # [PREFIX] [cloth] HORSE NAME ............ ODDS
    if prefix != "":
        c.text(prefix, x, y + 1, font = "4x5", color = prefix_col)
        x += c.text_width(prefix, "4x5") + 3
    x += cloth(c, x, y - 1, x_ride.get("cloth_number"), "5x7") + 3
    odds_w = 0
    if odds != "":
        c.text(odds, RIGHT, y, font = "5x7", color = odds_col, align = "right")
        odds_w = c.text_width(odds, "5x7") + 5
    c.text(clip_words(c, horse_name(x_ride), "5x7", RIGHT - odds_w - x), x, y, font = "5x7", color = name_col)


def facts_line(c, x, y, facts, max_x):
    # Short facts with clear gaps between them; stop at the first that won't fit.
    for f in facts:
        if f == "":
            continue
        w = c.text_width(f, "4x5")
        if x + w > max_x:
            break
        c.text(f, x, y, font = "4x5", color = COLORS["label"])
        x += w + 7


def money(amount, currency):
    # 12000 USD -> "$12K"; 5446 GBP -> "5.4K GBP".
    a = int(amount)
    if a >= 1000000:
        tenths = (a + 50000) // 100000
        num = str(tenths // 10) + ("." + str(tenths % 10) if tenths % 10 != 0 and tenths < 100 else "") + "M"
    elif a >= 10000:
        num = str((a + 500) // 1000) + "K"
    elif a >= 1000:
        tenths = (a + 50) // 100
        num = str(tenths // 10) + ("." + str(tenths % 10) if tenths % 10 != 0 else "") + "K"
    else:
        num = str(a)
    return "$" + num if currency == "USD" else num + " " + currency


def purse(detail):
    # The prize fund: every paid place added up.
    total = 0
    cur = ""
    for p in ((detail or {}).get("prizes") or {}).get("prize") or []:
        parts = str(p.get("prize") or "").split(" ")
        if len(parts) == 2:
            total += int(float(parts[0]))
            cur = parts[1]
    return "PURSE " + money(total, cur) if total > 0 else ""


def race_tag(r):
    return r["course"] + " R" + str(r["num"])


def draw_message(c, title, sub, art):
    if art == "horse":
        c.sprite(HORSE, LEFT, 11, legend = {"D": COLORS["hair"]}, color = COLORS["dim"])
        x = LEFT + 35
    else:
        c.sprite(TROPHY, LEFT + 2, 12, color = COLORS["dim"])
        x = LEFT + 20
    c.text(clip_words(c, title, "6x8", RIGHT - x), x, 9, font = "6x8", color = COLORS["error"])
    c.text(clip_words(c, sub, "4x5", RIGHT - x), x, 21, font = "4x5", color = COLORS["error_sub"])


def offline(c, art, what):
    draw_message(c, "RACING DATA OFFLINE", what + " RETURN WHEN IT IS BACK", art)


# ---- page 1: next race off ------------------------------------------------------

def pick_next(races, now):
    # A race at the track right now (running, photo, unofficial finish) comes
    # first; then the soonest race still to go.
    live = [r for r in races if (r["stage"] in RUNNING or r["stage"] in FINISHING) and r["unix"] >= now - 3600]
    if len(live) > 0:
        return sorted(live, key = lambda r: r["unix"])[len(live) - 1]
    upcoming = [r for r in races if r["stage"] in PRE_OFF and r["unix"] >= now - 1800]
    if len(upcoming) == 0:
        return None
    return sorted(upcoming, key = lambda r: r["unix"])[0]


def next(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    region = region_input(ctx)
    style = odds_input(ctx)
    got = load_races(now, region, True)
    if not got[0]:
        offline(c, "horse", "RACES")
        return
    r = pick_next(got[1], now)
    if r == None:
        draw_message(c, "NO RACES SCHEDULED", "BACK WITH THE NEXT RACECARD", "horse")
        return

    stage = r["stage"]
    running = stage in RUNNING
    if running:
        word = "LIVE"
        word_col = COLORS["live"]
        right = STAGE_WORDS.get(stage, "")
        right_col = COLORS["live"]
    elif stage in FINISHING:
        word = "JUST RUN"
        word_col = COLORS["amber"]
        right = STAGE_WORDS.get(stage, "")
        right_col = COLORS["amber"]
    else:
        word = "NEXT OFF"
        word_col = COLORS["gold"]
        if stage != "DORMANT":
            right = STAGE_WORDS.get(stage, "")
            right_col = COLORS["amber"]
        else:
            right = countdown(r["unix"] - now)
            right_col = COLORS["text"]
    header(c, LEFT, word, word_col, race_tag(r), right, right_col, running)

    c.sprite(HORSE, LEFT, 11, legend = HORSE_LEGEND)
    x = LEFT + 35

    c.text(clip_words(c, r["name"], "5x7", RIGHT - x), x, 8, font = "5x7", color = COLORS["text"])

    detail = race_detail(r["id"], 60)
    field = len(runners(detail)) if detail != None else r["rides"]
    facts_line(c, x, 16, [r["grade"], r["distance"], r["surface"],
                          str(field) + " RUNNERS" if field > 0 else "", purse(detail)], RIGHT)

    fav = favourite(detail) if detail != None else None
    if fav != None:
        odds = fmt_odds((fav.get("betting") or {}).get("current_odds"), style, r["us"])
        runner_line(c, x, 24, "FAV", COLORS["gold"], fav, odds, COLORS["gold"], COLORS["text"])
    else:
        c.text("ODDS SOON", x, 25, font = "4x5", color = COLORS["dim"])


# ---- page 2: latest result ----------------------------------------------------------

def result(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    region = region_input(ctx)
    style = odds_input(ctx)
    got = load_races(now, region, False)
    if not got[0]:
        offline(c, "trophy", "RESULTS")
        return
    done = [r for r in got[1] if r["stage"] in RESULTED and r["unix"] <= now]
    if len(done) == 0:
        draw_message(c, "NO RESULTS YET", "BACK AFTER THE FIRST RACE", "trophy")
        return
    r = sorted(done, key = lambda r: r["unix"])[len(done) - 1]
    detail = race_detail(r["id"], 120)
    win = placed(detail, 1) if detail != None else None
    if win == None:
        offline(c, "trophy", "RESULTS")
        return

    # Only official results reach this page (US "official", UK "weighed in").
    word = "AMENDED RESULT" if r["stage"] == "AMENDEDRESULT" else "RESULT"
    header(c, LEFT, word, COLORS["win"], race_tag(r), ago(now - (r["off"] if r["off"] > 0 else r["unix"])), COLORS["label"], False)

    # The winner: big cloth, name, odds.
    n = int(win.get("cloth_number") or 0)
    pal = CLOTHS.get(n, ["#4B5563", "#FFFFFF"])
    label = str(n) if n > 0 else "-"
    lw = c.text_width(label, "7x10")
    bw = max(lw + 6, 15)
    c.rect(LEFT, 8, LEFT + bw - 1, 22, fill = pal[0])
    if n == 6:
        c.rect(LEFT, 8, LEFT + bw - 1, 22, outline = "#6B7280")
    c.text(label, LEFT + (bw - lw) // 2, 11, font = "7x10", color = pal[1])

    x = LEFT + bw + 5
    odds = fmt_odds((win.get("betting") or {}).get("current_odds"), style, r["us"])
    odds_w = c.text_width(odds, "6x8") + 6 if odds != "" else 0
    if odds != "":
        c.text(odds, RIGHT, 9, font = "6x8", color = COLORS["gold"], align = "right")
    name = horse_name(win)
    # 6x8 has no apostrophe ("HE'S A SHOOTER"), so those names use 5x7.
    font = "6x8" if c.text_width(name, "6x8") <= RIGHT - odds_w - x and "'" not in name else "5x7"
    c.text(clip_words(c, name, font, RIGHT - odds_w - x), x, 9 if font == "6x8" else 10, font = font, color = COLORS["text"])

    # Jockey, then trainer if there is room: dim labels, names in grey.
    jx = x
    for item in [["JOCKEY", initial_surname(person(win, "jockey"))], ["TRAINER", initial_surname(person(win, "trainer"))]]:
        if item[1] == "":
            continue
        need = c.text_width(item[0], "4x5") + 4 + c.text_width(item[1], "4x5")
        if jx + need > RIGHT:
            break
        c.text(item[0], jx, 18, font = "4x5", color = COLORS["dim"])
        c.text(item[1], jx + c.text_width(item[0], "4x5") + 4, 18, font = "4x5", color = COLORS["label"])
        jx += need + 8

    # 2nd and 3rd across the bottom; a long 3rd keeps its first words.
    px = LEFT
    for pos in [2, 3]:
        p = placed(detail, pos)
        if p == None:
            continue
        lead = "2ND" if pos == 2 else "3RD"
        room = RIGHT - px
        name = horse_name(p)
        fixed = c.text_width(lead, "4x5") + 3 + c.text_width(str(p.get("cloth_number") or "-"), "4x5") + 7
        if fixed + c.text_width(name, "4x5") > room:
            name = clip_words(c, name, "4x5", room - fixed)
            if pos == 3 and (name == "" or c.text_width(name, "4x5") > room - fixed):
                break
        c.text(lead, px, 26, font = "4x5", color = COLORS["dim"])
        px += c.text_width(lead, "4x5") + 3
        px += cloth(c, px, 25, p.get("cloth_number"), "4x5") + 3
        c.text(name, px, 26, font = "4x5", color = COLORS["text"])
        px += c.text_width(name, "4x5") + 7


# ---- page 3: today's big race -------------------------------------------------------

def pick_feature(pool, now):
    # Among the day's top-tier races (every Grade 1 on Breeders' Cup or
    # Cheltenham day): a winner from the last 30 minutes first, then the next
    # one to run, then the last one run. So the page walks through a big
    # day race by race, and the biggest race's result holds the evening.
    top = max([race_tier(r) for r in pool])
    tier = sorted([r for r in pool if race_tier(r) == top], key = lambda r: r["unix"])
    just = [r for r in tier if r["stage"] in RESULTED and now - r["unix"] >= 0 and now - r["unix"] < 1800]
    if len(just) > 0:
        return just[len(just) - 1]
    ahead = [r for r in tier if r["stage"] not in RESULTED]
    if len(ahead) > 0:
        return ahead[0]
    return tier[len(tier) - 1]


def feature(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    region = region_input(ctx)
    style = odds_input(ctx)
    got = load_races(now, region, False)
    if not got[0]:
        offline(c, "trophy", "BIG RACES")
        return
    today = uk_day(now)
    # Today's races (UK date), or the night's North American card still
    # being run under yesterday's date.
    pool = [r for r in got[1] if r["stage"] not in VOID and r["unix"] >= (today * 86400 - 3600 * 6)]
    if len(pool) == 0:
        draw_message(c, "NO RACES TODAY", "BACK WITH THE NEXT RACECARD", "trophy")
        return
    r = pick_feature(pool, now)
    big = is_big(r)

    done = r["stage"] in RESULTED
    if done:
        right = "OFFICIAL" if r["us"] else "WEIGHED IN"
        right_col = COLORS["win"]
    elif r["stage"] in RUNNING:
        right = "RUNNING"
        right_col = COLORS["live"]
    elif r["stage"] != "DORMANT":
        right = STAGE_WORDS.get(r["stage"], "")
        right_col = COLORS["amber"]
    else:
        right = "IN " + countdown(r["unix"] - now) if r["unix"] - now >= 60 else "DUE"
        right_col = COLORS["text"]
    header(c, LEFT, "BIG RACE" if big else "TOP RACE", COLORS["gold"], race_tag(r), right, right_col, r["stage"] in RUNNING)

    c.sprite(TROPHY, LEFT + 2, 12, color = COLORS["gold"])
    x = LEFT + 20

    # Grade badge, then the race name over up to two lines.
    name_x = x
    if r["grade"] != "":
        bw = c.text_width(r["grade"], "4x5") + 4
        c.rect(x, 7, x + bw - 1, 13, fill = COLORS["gold"])
        c.text(r["grade"], x + 2, 8, font = "4x5", color = "#000000")
        name_x = x + bw + 4
    detail = race_detail(r["id"], 120 if done else 60)

    lines = wrap2(c, r["name"], "5x7", RIGHT - name_x)
    c.text(lines[0], name_x, 7, font = "5x7", color = COLORS["text"])
    if lines[1] != "":
        c.text(lines[1], x, 15, font = "5x7", color = COLORS["text"])
    else:
        # Room for a facts line: Sporting Life's tip before the off, else the race facts.
        tip = tip_of(r["verdict"]) if not done else ""
        field = len(runners(detail)) if detail != None else r["rides"]
        if tip != "":
            c.text("TIP", x, 16, font = "4x5", color = COLORS["gold"])
            c.text(clip_words(c, tip, "4x5", RIGHT - x - 16), x + 16, 16, font = "4x5", color = COLORS["text"])
        else:
            facts_line(c, x, 16, [r["distance"], r["surface"],
                                  str(field) + " RUNNERS" if field > 0 else "", purse(detail)], RIGHT)

    if detail == None:
        return
    if done:
        win = placed(detail, 1)
        if win != None:
            odds = fmt_odds((win.get("betting") or {}).get("current_odds"), style, r["us"])
            runner_line(c, x, 24, "WON", COLORS["win"], win, odds, COLORS["gold"], COLORS["text"])
            return
    fav = favourite(detail)
    if fav != None:
        odds = fmt_odds((fav.get("betting") or {}).get("current_odds"), style, r["us"])
        runner_line(c, x, 24, "FAV", COLORS["gold"], fav, odds, COLORS["gold"], COLORS["text"])
