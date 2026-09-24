# Tennis Scores - live ATP / WTA singles on a 64x32 panel.
#
# Started as a GDN port of M0ntyP's Pixlet ATP Tennis app
# (tidbyt/community apps/atptennis); redesigned for Glance.
#
# DESIGN. One match per page, drawn like a broadcast score bug so it reads
# from across the room. The tournament rides a strip in its own color
# (Wimbledon green, Roland Garros clay, US Open navy; 1000-level events get a
# gold name) with a tennis ball as the app's mark. The players get full 7 px
# rows with set scores in fixed columns on the right: white is a set won, gray
# a set lost, the set in play sits on a lit column, and a small ball marks the
# server. The footer carries the round on the left (a trophy for the final)
# and the match state on the right. Live matches come first, then today's
# results, then what is up next; between tournaments the pages become an
# UP NEXT card instead of going dark.
#
#   y 0-6    strip     ball + tournament
#   y 8-14   player 1  name ................ 6 3 5
#   y 17-23  player 2  name ................ 4 6 4
#   y 26-30  footer    round ............. o LIVE
#
# DATA. ESPN's scoreboard *header* feed (the score strip on espn.com): today's
# matches only, 50-150 KB. The full site scoreboard this app first read
# carries every draw of the event and reaches ~1.75 MB by the end of a Grand
# Slam - past the host's response cap - so the JSON arrived truncated and the
# app went blank exactly during the biggest tournaments.

FEED_URL = "https://site.web.api.espn.com/apis/v2/scoreboard/header"

# manifest.yaml refreshes every 300 s; the feed cache matches it, so each
# refresh sees new scores and the eight page draws share one fetch.
FEED_TTL = 300

PAGE_COUNT = 8
MAX_SETS = 5

TOURS = {
    "ATP": {"league": "atp", "slug": "mens-singles", "color": "#123C73"},
    "WTA": {"league": "wta", "slug": "womens-singles", "color": "#4E2C84"},
}

# (text in the ESPN event name, strip label, strip color)
SLAMS = [
    ("AUSTRALIAN OPEN", "AUS OPEN", "#0A6FC2"),
    ("ROLAND GARROS", "ROLAND GARROS", "#B4491F"),
    ("FRENCH OPEN", "ROLAND GARROS", "#B4491F"),
    ("WIMBLEDON", "WIMBLEDON", "#0B6138"),
    ("US OPEN", "US OPEN", "#0E2F7A"),
]

# Host cities of 1000-level events; their strip label is drawn in gold.
THOUSAND_CITIES = [
    "INDIAN WELLS", "MIAMI", "MIAMI GARDENS", "MONTE CARLO", "MONTE-CARLO",
    "MONACO", "MADRID", "ROME", "MONTREAL", "TORONTO", "CINCINNATI", "MASON",
    "SHANGHAI", "PARIS", "BEIJING", "WUHAN",
]

WHITE = "#FFFFFF"
GRAY = "#6E7A94"
BALL = "#D6F03A"
SEAM = "#F4F7E6"
LIVE = "green"
AMBER = "#E8B04A"
SKY = "skyblue"
GOLD = "#F2C84B"
CELL_LIVE = "#1B3352"
CELL_PAUSED = "#3D2E0C"
NODATA_BG = "#0B0C12"
NODATA_SUB = "#6A7090"

ROW1_Y = 8
ROW2_Y = 17
FOOT_Y = 26
SERVE_GUTTER = 5
SET_GAP = 2
NAME_GAP = 3  # wider than SET_GAP, or a full-width 'ALCARAZ' reads as part of the score
MIN_NAME_W = 24
DIGIT_W = {"5x7": 5, "4x7": 4}
NAME_FONTS = ["5x7", "4x7", "3x7"]
FONTH = {"6x8": 8, "5x7": 7, "4x7": 7, "3x7": 7, "4x5": 5, "picopixel": 5}

BALL_BODY = [
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
]
BALL_SEAM = [
    [0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0],
]
# 4x4, not a 3x3 plus: the plus read as '+' in front of 'LIVE' and names.
DOT = [
    [0, 1, 1, 0],
    [1, 1, 1, 1],
    [1, 1, 1, 1],
    [0, 1, 1, 0],
]
TROPHY = [
    [1, 1, 1, 1, 1, 1, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [0, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 0],
]

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

KIND_RANK = {"live": 0, "susp": 1, "delay": 2, "final": 3, "ret": 3, "wo": 3, "pre": 4}
FINAL_KINDS = ["final", "ret", "wo"]

ROUNDS = {
    "FINAL": "FINAL",
    "FINALS": "FINAL",
    "SEMIFINAL": "SF",
    "SEMIFINALS": "SF",
    "QUARTERFINAL": "QF",
    "QUARTERFINALS": "QF",
    "ROUND OF 16": "R16",
    "ROUND OF 32": "R32",
    "ROUND OF 64": "R64",
    "ROUND ROBIN": "RR",
    "QUALIFYING 1ST ROUND": "Q1",
    "QUALIFYING 2ND ROUND": "Q2",
    "QUALIFYING 3RD ROUND": "Q3",
    "QUALIFYING FINAL": "QUAL",
}

# Fonts only carry A-Z, digits and a little punctuation; an accented letter
# would draw as a gap ("S O PAULO"), so fold them before anything is measured.
FOLD = {
    "À": "A", "Á": "A", "Â": "A", "Ã": "A", "Ä": "A", "Å": "A", "Ā": "A", "Ă": "A", "Ą": "A",
    "Ç": "C", "Ć": "C", "Č": "C", "Ď": "D", "Đ": "D",
    "È": "E", "É": "E", "Ê": "E", "Ë": "E", "Ě": "E", "Ę": "E", "Ē": "E",
    "Ğ": "G", "Ì": "I", "Í": "I", "Î": "I", "Ï": "I", "İ": "I", "Ł": "L",
    "Ñ": "N", "Ń": "N", "Ň": "N",
    "Ò": "O", "Ó": "O", "Ô": "O", "Õ": "O", "Ö": "O", "Ø": "O", "Ő": "O",
    "Ř": "R", "Ś": "S", "Š": "S", "Ş": "S", "Ș": "S", "Ť": "T", "Ț": "T", "Ţ": "T",
    "Ù": "U", "Ú": "U", "Û": "U", "Ü": "U", "Ű": "U", "Ů": "U",
    "Ý": "Y", "Ÿ": "Y", "Ž": "Z", "Ź": "Z", "Ż": "Z", "ß": "SS",
}
ALLOWED = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -.'/"

# ---------------------------------------------------------------- safe reads

def dget(d, key):
    if type(d) != "dict":
        return {}
    v = d.get(key)
    return v if type(v) == "dict" else {}

def lget(d, key):
    if type(d) != "dict":
        return []
    v = d.get(key)
    return v if type(v) == "list" else []

def sget(d, key):
    if type(d) != "dict":
        return ""
    v = d.get(key)
    return v if type(v) == "string" else ""

def intval(v):
    if type(v) == "int":
        return v
    if type(v) == "float":
        return int(v)
    return 0

def clean(s):
    """Uppercase, accent-folded, font-safe text."""
    if type(s) != "string":
        return ""
    s = s.upper()
    for src in FOLD:
        if src in s:
            s = s.replace(src, FOLD[src])
    out = []
    for ch in s.elems():
        if ch in ALLOWED:
            out.append(ch)
    return " ".join("".join(out).split())

# ---------------------------------------------------------------- time

def _days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _atoi(s):
    n = 0
    for ch in s.elems():
        if ch < "0" or ch > "9":
            return 0
        n = n * 10 + (ord(ch) - 48)
    return n

def parse_iso(s):
    """'2026-09-15T13:35:00Z' -> unix seconds, 0 if unreadable."""
    if type(s) != "string" or len(s) < 16:
        return 0
    y, mo, d = _atoi(s[0:4]), _atoi(s[5:7]), _atoi(s[8:10])
    hh, mm = _atoi(s[11:13]), _atoi(s[14:16])
    if y == 0 or mo < 1 or mo > 12 or d < 1 or d > 31:
        return 0
    return _days_from_civil(y, mo, d) * 86400 + hh * 3600 + mm * 60

# ---------------------------------------------------------------- data

def fetch_feed(league):
    resp = http.get(FEED_URL, params = {"sport": "tennis", "league": league}, ttl_seconds = FEED_TTL)
    if resp["status_code"] != 200:
        return None
    data = resp["json"]
    if type(data) != "dict":
        return None
    return data

def feed_events(data):
    out = []
    for sp in lget(data, "sports"):
        for lg in lget(sp, "leagues"):
            for ev in lget(lg, "events"):
                if type(ev) == "dict":
                    out.append(ev)
    return out

def status_kind(ev):
    desc = sget(dget(dget(ev, "fullStatus"), "type"), "description").upper()
    if "CANCEL" in desc or "POSTPONE" in desc or "ABANDON" in desc:
        return ""
    if "SUSPEND" in desc:
        return "susp"
    if "DELAY" in desc:
        return "delay"
    if "RETIRE" in desc:
        return "ret"
    if "WALKOVER" in desc:
        return "wo"
    state = sget(ev, "status")
    if state == "in":
        return "live"
    if state == "post":
        return "final"
    if state == "pre":
        return "pre"
    return ""

def event_style(ev, tour):
    """(strip label, strip color, label color, tier) - tier 2 slam, 1 for 1000s."""
    name = clean(sget(ev, "name"))
    for key, label, col in SLAMS:
        if key in name:
            return (label, col, WHITE, 2)
    tour_color = TOURS[tour]["color"]
    if ev.get("major") == True and name != "":
        return (name, tour_color, WHITE, 2)
    # Split 'Chengdu, China PR' before clean(), which drops the comma.
    loc = sget(ev, "location")
    city = clean(loc[:loc.find(",")] if "," in loc else loc)
    if city == "":
        city = name if name != "" else "TENNIS"
    if city in THOUSAND_CITIES:
        return (city, tour_color, GOLD, 1)
    return (city, tour_color, WHITE, 0)

def round_code(ev):
    raw = ""
    for note in lget(ev, "notes"):
        raw = sget(note, "type")
        if raw != "":
            break
    raw = clean(raw)
    if " - " in raw:
        raw = raw[:raw.find(" - ")].strip()
    if raw in ROUNDS:
        return ROUNDS[raw]
    if raw.startswith("ROUND "):
        return "R" + raw[6:].strip()
    return raw

def player_name(cp):
    """Surname: 'lastName' when the feed has it, else 'J. SINNER' minus the initial."""
    name = clean(sget(cp, "lastName"))
    if name == "":
        name = clean(sget(cp, "shortName"))
        if name == "":
            name = clean(sget(cp, "displayName"))
            parts = name.split(" ")
            name = parts[len(parts) - 1] if len(parts) > 0 else ""
        if len(name) > 2 and name[1] == ".":
            name = name[2:].strip()
    return name

def score_text(v):
    if type(v) == "int" or type(v) == "float":
        n = int(v)
        return str(n) if n >= 0 and n < 100 else ""
    if type(v) == "string":
        return clean(v)[:2]
    return ""

def read_match(ev, now, slug, tour):
    if sget(dget(ev, "competitionType"), "slug") != slug:
        return None
    kind = status_kind(ev)
    if kind == "":
        return None

    cps = [cp for cp in lget(ev, "competitors") if type(cp) == "dict"]
    if len(cps) != 2:
        return None
    if intval(cps[0].get("order")) > intval(cps[1].get("order")):
        cps = [cps[1], cps[0]]
    n1 = player_name(cps[0])
    n2 = player_name(cps[1])
    if n1 == "" or n2 == "" or n1 == "TBD" or n2 == "TBD":
        return None

    ls1 = lget(cps[0], "linescores")
    ls2 = lget(cps[1], "linescores")
    sets = []
    for i in range(min(len(ls1), len(ls2))):
        a = ls1[i]
        b = ls2[i]
        if type(a) != "dict" or type(b) != "dict":
            continue
        sets.append({
            "s1": score_text(a.get("value")),
            "s2": score_text(b.get("value")),
            "w1": a.get("winner") == True,
            "w2": b.get("winner") == True,
        })
    if len(sets) > MAX_SETS:
        sets = sets[-MAX_SETS:]
    if kind == "pre" and len(sets) > 0:
        kind = "live"

    start = parse_iso(sget(ev, "date"))
    if kind in FINAL_KINDS and start > 0 and now - start > 36 * 3600:
        return None

    winner = 0
    if kind in FINAL_KINDS:
        if cps[0].get("winner") == True:
            winner = 1
        elif cps[1].get("winner") == True:
            winner = 2

    serving = 0
    if kind == "live":
        if cps[0].get("possession") == True:
            serving = 1
        elif cps[1].get("possession") == True:
            serving = 2

    label, color, label_color, tier = event_style(ev, tour)
    return {
        "kind": kind,
        "n1": n1,
        "n2": n2,
        "sets": sets,
        "winner": winner,
        "serving": serving,
        "start": start,
        "time_valid": ev.get("timeValid") != False,
        "round": round_code(ev),
        "label": label,
        "color": color,
        "label_color": label_color,
        "tier": tier,
    }

def sort_key(m):
    rank = KIND_RANK[m["kind"]]
    when = -m["start"] if rank == 3 else m["start"]
    return (rank, -m["tier"], when)

def pick(items, slot, now):
    """Item for page `slot`. Live matches hold the first pages; when there
    are more matches than pages, the rest rotate each refresh so every one
    gets its turn."""
    n = len(items)
    if n <= PAGE_COUNT:
        return items[slot % n]
    cycle = now // FEED_TTL
    nlive = 0
    for m in items:
        if KIND_RANK[m["kind"]] <= 1:
            nlive += 1
    if nlive >= PAGE_COUNT:
        return items[(slot + cycle * PAGE_COUNT) % nlive]
    if slot < nlive:
        return items[slot]
    free = PAGE_COUNT - nlive
    return items[nlive + (slot - nlive + cycle * free) % (n - nlive)]

def upcoming_events(events, slug, tour):
    seen = {}
    out = []
    for ev in events:
        if sget(dget(ev, "competitionType"), "slug") != slug or sget(ev, "status") != "pre":
            continue
        label, color, label_color, tier = event_style(ev, tour)
        if label in seen:
            continue
        seen[label] = True
        out.append({"label": label, "color": color, "date": sget(ev, "date")})
    return out

# ---------------------------------------------------------------- text fitting

def fit_clip(c, text, fonts, maxw):
    """Largest font that fits; else the last font, cut at a word when that
    keeps at least a third of the string, else cut by character. A word cut
    never ends on a 1-2 letter word: 'CALDAS DA RAINHA' -> 'CALDAS'."""
    for f in fonts:
        if c.text_width(text, font = f) <= maxw:
            return (text, f)
    f = fonts[len(fonts) - 1]
    words = text.split(" ")
    for k in range(len(words) - 1, 0, -1):
        if k > 1 and len(words[k - 1]) <= 2:
            continue
        t = " ".join(words[:k])
        if c.text_width(t, font = f) <= maxw:
            if len(t) * 3 >= len(text):
                return (t, f)
            break
    for i in range(len(text) - 1, 0, -1):
        t = text[:i].strip()
        if c.text_width(t, font = f) <= maxw:
            return (t, f)
    return ("", f)

def short_name(name):
    """Last word of a multi-part surname: 'MPETSHI PERRICARD' -> 'PERRICARD'."""
    parts = name.replace("-", " ").split(" ")
    return parts[len(parts) - 1]

def fit_names(c, n1, n2, maxw):
    """One font for both rows, so the two names share a baseline and size.
    Full surnames at the largest font first; then allow the last word of a
    compound surname; then hard-clip in 3x7 (the narrowest 7 px face)."""
    for f in NAME_FONTS:
        if c.text_width(n1, font = f) <= maxw and c.text_width(n2, font = f) <= maxw:
            return (f, n1, n2)
    s1 = short_name(n1)
    s2 = short_name(n2)
    for f in NAME_FONTS:
        t1 = n1 if c.text_width(n1, font = f) <= maxw else s1
        t2 = n2 if c.text_width(n2, font = f) <= maxw else s2
        if c.text_width(t1, font = f) <= maxw and c.text_width(t2, font = f) <= maxw:
            return (f, t1, t2)
    f = NAME_FONTS[len(NAME_FONTS) - 1]
    t1, _ = fit_clip(c, s1, [f], maxw)
    t2, _ = fit_clip(c, s2, [f], maxw)
    return (f, t1, t2)

def draw_centered(c, text, y, font, color):
    c.text(text, (c.width - c.text_width(text, font = font)) // 2, y, font = font, color = color)

# ---------------------------------------------------------------- drawing

def draw_ball(c, x, y):
    c.bitmap(BALL_BODY, x, y, BALL)
    c.bitmap(BALL_SEAM, x, y, SEAM)

def draw_strip(c, label, color, label_color):
    c.rect(0, 0, c.width - 1, 6, fill = color)
    draw_ball(c, 1, 1)

    # Plain text: every strip color is dark enough for white, and a black
    # stroke filled the whole 7 px strip, leaving slivers of color between
    # words. 'ROLAND GARROS' is 62 px in 4x5, past the 56 px from x 8, so the
    # ladder drops to picopixel (50 px) before anything is cut.
    x = 8
    text, font = fit_clip(c, label, ["4x5", "picopixel"], c.width - x)
    c.text(text, x, 1, font = font, color = label_color)

def set_columns(c, sets):
    """(digit font, sets shown, column widths, column right edges).

    Three sets of 5x7 (5 px digits, 2 px apart) take the right 19 px. A
    5-setter at that size would take 33 px and push even 'ALCARAZ' out of
    3x7, so 4-5 sets drop to 4x7 (28 px). Columns are measured rather than
    fixed, so a two-digit set ('10' in a match tiebreak) widens its own
    column instead of drawing through its neighbor; if that would leave the
    names under MIN_NAME_W, the oldest sets are dropped first."""
    n = len(sets)
    font = "5x7" if n <= 3 else "4x7"
    widths = []
    for s in sets:
        widths.append(max(c.text_width(s["s1"], font = font),
                          c.text_width(s["s2"], font = font), DIGIT_W[font]))
    first = 0
    for i in range(n):
        first = i
        used = SET_GAP * (n - i)
        for w in widths[i:]:
            used += w
        if c.width - used >= MIN_NAME_W:
            break
    rights = []
    x = c.width - 1
    for i in range(n - 1, first - 1, -1):
        rights.insert(0, x)
        x -= widths[i] + SET_GAP
    return (font, sets[first:], widths[first:], rights)

def draw_rows(c, m):
    kind = m["kind"]
    in_play = kind == "live" or kind == "susp" or kind == "delay"

    dfont, sets, widths, rights = set_columns(c, m["sets"])
    n = len(sets)
    scores_x0 = rights[0] - widths[0] + 1 if n > 0 else c.width

    # The set in play sits on a lit column running through both rows.
    if in_play and n > 0:
        c.rect(rights[n - 1] - widths[n - 1], ROW1_Y - 1, c.width - 1, ROW2_Y + 7,
               fill = CELL_LIVE if kind == "live" else CELL_PAUSED)

    for i in range(n):
        s = sets[i]
        current = in_play and i == n - 1
        for row in range(2):
            txt = s["s1"] if row == 0 else s["s2"]
            won = s["w1"] if row == 0 else s["w2"]
            other_won = s["w2"] if row == 0 else s["w1"]
            col = GRAY if (not current and other_won and not won) else WHITE
            c.text(txt, rights[i] - c.text_width(txt, font = dfont) + 1,
                   ROW1_Y if row == 0 else ROW2_Y, font = dfont, color = col)

    # Names end NAME_GAP px before the first score column; the serve gutter
    # is only reserved while a match is being played.
    x_name = SERVE_GUTTER if in_play else 0
    maxw = scores_x0 - NAME_GAP - x_name
    font, t1, t2 = fit_names(c, m["n1"], m["n2"], maxw)
    c.text(t1, x_name, ROW1_Y, font = font, color = GRAY if m["winner"] == 2 else WHITE)
    c.text(t2, x_name, ROW2_Y, font = font, color = GRAY if m["winner"] == 1 else WHITE)

    if m["serving"] == 1:
        c.bitmap(DOT, 0, ROW1_Y + 2, BALL)
    elif m["serving"] == 2:
        c.bitmap(DOT, 0, ROW2_Y + 2, BALL)

def state_label(m, now):
    k = m["kind"]
    if k == "live":
        return ("LIVE", LIVE)
    if k == "susp":
        return ("SUSP", AMBER)
    if k == "delay":
        return ("DELAY", AMBER)
    if k == "ret":
        return ("RET", GRAY)
    if k == "wo":
        return ("W/O", GRAY)
    if k == "final":
        return ("FINAL", GRAY)

    # Upcoming: a countdown needs no timezone, and the 5-minute refresh
    # keeps it honest.
    if not m["time_valid"] or m["start"] == 0:
        return ("LATER", SKY)
    mins = (m["start"] - now) // 60
    if mins <= 0:
        return ("SOON", SKY)
    if mins < 60:
        return ("IN %dM" % mins, SKY)
    if mins < 24 * 60:
        return ("IN %dH" % (mins // 60), SKY)
    return ("IN %dD" % (mins // 1440), SKY)

def draw_footer(c, m, now):
    # State first, measured against the right edge, so the round can never
    # run into it.
    label, color = state_label(m, now)
    lx = c.width - c.text_width(label, font = "4x5")
    c.text(label, lx, FOOT_Y, font = "4x5", color = color)
    left_limit = lx - 2
    if m["kind"] == "live":
        c.bitmap(DOT, lx - 6, FOOT_Y + 1, LIVE)
        left_limit = lx - 8

    rnd = m["round"]
    if rnd == "FINAL":
        # 7 px tall, so it rises a row above the footer text: y 25-31.
        c.bitmap(TROPHY, 0, FOOT_Y - 1, GOLD)
    elif rnd != "":
        text, font = fit_clip(c, rnd, ["4x5"], left_limit - 1)
        c.text(text, 0, FOOT_Y, font = font, color = GRAY)

def draw_match(c, m, now):
    draw_strip(c, m["label"], m["color"], m["label_color"])
    draw_rows(c, m)
    draw_footer(c, m, now)

def draw_next(c, tour, ev, now):
    """Between tournaments: the next event's name, big, and when it starts."""
    draw_strip(c, tour + " UP NEXT", ev["color"], WHITE)

    text, font = fit_clip(c, ev["label"], ["6x8", "5x7", "4x7", "3x7"], c.width - 2)
    draw_centered(c, text, 11 + (8 - FONTH[font]), font, WHITE)

    t = parse_iso(ev["date"])
    if t == 0:
        return
    days = t // 86400 - now // 86400
    iso = ev["date"]
    if days <= 0:
        when = "TODAY"
    elif days == 1:
        when = "TOMORROW"
    else:
        when = MONTHS[_atoi(iso[5:7]) - 1] + " " + str(_atoi(iso[8:10]))
    sub = "STARTS " + when
    if c.text_width(sub, font = "4x5") > c.width - 2:
        sub = when
    draw_centered(c, sub, 23, "4x5", GRAY)

def draw_quiet(c, tour):
    """Feed is fine, the tour just has nothing on today - not an error."""
    draw_strip(c, tour + " TOUR", TOURS[tour]["color"], WHITE)
    draw_centered(c, "NO MATCHES", 12, "5x7", WHITE)
    draw_centered(c, "TODAY", 22, "4x5", GRAY)

def nodata(c, title, sub):
    c.fill(NODATA_BG)
    draw_ball(c, (c.width - 5) // 2, 3)
    text, font = fit_clip(c, title, ["6x8", "5x7", "4x5"], c.width - 2)
    draw_centered(c, text, 11 + (8 - FONTH[font]) // 2, font, AMBER)
    text, font = fit_clip(c, sub, ["4x5"], c.width - 2)
    draw_centered(c, text, 23, font, NODATA_SUB)

# ---------------------------------------------------------------- pages

def draw_page(c, ctx, slot):
    c.fill("black")

    tour = ctx.inputs.get("tour", "ATP")
    tour = tour.strip().upper() if type(tour) == "string" else "ATP"
    if tour not in TOURS:
        tour = "ATP"
    cfg = TOURS[tour]

    data = fetch_feed(cfg["league"])
    if data == None:
        nodata(c, "NO SCORES", "RETRYING SOON")
        return

    now = ctx.now.unix
    events = feed_events(data)
    items = []
    for ev in events:
        m = read_match(ev, now, cfg["slug"], tour)
        if m != None:
            items.append(m)

    if len(items) == 0:
        upcoming = upcoming_events(events, cfg["slug"], tour)
        if len(upcoming) > 0:
            draw_next(c, tour, upcoming[slot % len(upcoming)], now)
        else:
            draw_quiet(c, tour)
        return

    items = sorted(items, key = sort_key)
    draw_match(c, pick(items, slot, now), now)

def p1(c, ctx):
    draw_page(c, ctx, 0)

def p2(c, ctx):
    draw_page(c, ctx, 1)

def p3(c, ctx):
    draw_page(c, ctx, 2)

def p4(c, ctx):
    draw_page(c, ctx, 3)

def p5(c, ctx):
    draw_page(c, ctx, 4)

def p6(c, ctx):
    draw_page(c, ctx, 5)

def p7(c, ctx):
    draw_page(c, ctx, 6)

def p8(c, ctx):
    draw_page(c, ctx, 7)
