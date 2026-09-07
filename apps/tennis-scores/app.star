# ATP Tennis — GDN port of the Pixlet app by M0ntyP.
#
# Original: https://github.com/tidbyt/community  (apps/atptennis)
# Ported to the Glance Developer Network. Data logic follows the original;
# the render tree is rewritten as c.* draw calls.
#
# Layout (64x32):
#   y 0-4    title bar (tournament city/name)
#   y 6-17   match 1  (two player rows)
#   y 18     divider
#   y 20-31  match 2  (two player rows)

SCORES_URL = "https://site.api.espn.com/apis/site/v2/sports/tennis/%s/scoreboard"

TOURS = {
    "ATP": ("atp", "mens-singles"),
    "WTA": ("wta", "womens-singles"),
}

SLAM_NAMES = ["AUSTRALIAN OPEN", "ROLAND GARROS", "FRENCH OPEN", "WIMBLEDON", "US OPEN"]
MASTERS_NAMES = [
    "INDIAN WELLS", "MIAMI", "MONTE-CARLO", "MONTE CARLO", "MADRID",
    "ROME", "ITALIAN OPEN", "CANADIAN", "TORONTO", "MONTREAL",
    "CINCINNATI", "SHANGHAI", "PARIS",
]

SLAM_COLORS = [
    ("AUSTRALIAN OPEN", "#0091d2"),
    ("WIMBLEDON", "#006633"),
    ("ROLAND GARROS", "#c84e1e"),
    ("FRENCH OPEN", "#c84e1e"),
    ("US OPEN", "#022686"),
]
DEFAULT_TITLE_BG = "#203764"
MASTERS_GOLD = "#d1b358"

def _matches_any(name, names):
    up = name.upper()
    for n in names:
        if n in up:
            return True
    return False

def is_slam(ev):
    return _matches_any(ev.get("name", ""), SLAM_NAMES)

def is_masters(ev):
    return _matches_any(ev.get("name", ""), MASTERS_NAMES)

SERVING = "green"
SUSPENDED = "skyblue"
SET_WON = "yellow"

FONT = "4x5"
FONT_NARROW = "3x4"
ROW_H = 6
SET_W = 6
NAME_X = 3
MAX_SETS = 5

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
    if type(s) != "string" or len(s) < 16:
        return 0
    y, mo, d = _atoi(s[0:4]), _atoi(s[5:7]), _atoi(s[8:10])
    hh, mm = _atoi(s[11:13]), _atoi(s[14:16])
    if y == 0 or mo == 0 or d == 0:
        return 0
    return _days_from_civil(y, mo, d) * 86400 + hh * 3600 + mm * 60

def hours_since(iso, now_unix):
    t = parse_iso(iso)
    return 999999 if t == 0 else (now_unix - t) / 3600.0

def fetch(tour_slug, ttl):
    resp = http.get(SCORES_URL % tour_slug, ttl_seconds = ttl)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    return resp["json"]

def find_event(data, tid):
    for ev in data.get("events", []):
        if ev.get("id") == tid:
            return ev
    return None

def is_running(ev, now):
    start = parse_iso(ev.get("date", ""))
    end = parse_iso(ev.get("endDate", ""))
    if start > 0 and now < start:
        return False
    if end > 0 and now > end:
        return False
    return len(ev.get("groupings", [])) > 0

def tier(ev):
    if is_slam(ev):
        return 2
    if is_masters(ev):
        return 1
    return 0

def choose_event(data, tid, now, slug):
    if tid != "" and tid != "auto":
        return find_event(data, tid)

    best = None
    best_key = (-1, -1, -1)
    for ev in data.get("events", []):
        if not is_running(ev, now):
            continue
        n = len(collect(ev, now, True, slug)) + len(collect(ev, now, False, slug))
        key = (1 if n > 0 else 0, tier(ev), n)
        if key > best_key:
            best_key = key
            best = ev
    return best

def singles_grouping(ev, slug_want):
    groups = ev.get("groupings", [])
    if len(groups) == 0:
        return None
    for g in groups:
        if g.get("grouping", {}).get("slug", "") == slug_want:
            return g
    return groups[0]

def score_str(v):
    if type(v) == "int":
        return str(v)
    if type(v) == "float":
        return str(int(v))
    return str(v)

def read_match(comp):
    cs = comp.get("competitors", [])
    if len(cs) < 2:
        return None

    a1 = cs[0].get("athlete", {})
    a2 = cs[1].get("athlete", {})
    n1 = a1.get("shortName", "")
    n2 = a2.get("shortName", "")
    if n1 == "" or n2 == "":
        return None

    desc = comp.get("status", {}).get("type", {}).get("description", "")

    ls1 = cs[0].get("linescores", [])
    ls2 = cs[1].get("linescores", [])
    sets = []
    for i in range(min(len(ls1), len(ls2))):
        sets.append({
            "s1": score_str(ls1[i].get("value", 0)),
            "s2": score_str(ls2[i].get("value", 0)),
            "w1": ls1[i].get("winner", False) == True,
            "w2": ls2[i].get("winner", False) == True,
        })

    serving = 0
    if "possession" in cs[0]:
        serving = 1 if cs[0]["possession"] == True else 2

    return {
        "live": False,
        "n1": n1.upper(),
        "n2": n2.upper(),
        "sets": sets,
        "serving": serving,
        "suspended": desc == "Suspended",
        "date": comp.get("date", ""),
    }

def collect(ev, now_unix, want_live, slug):
    g = singles_grouping(ev, slug)
    if g == None:
        return []

    out = []
    for comp in g.get("competitions", []):
        desc = comp.get("status", {}).get("type", {}).get("description", "")
        cs = comp.get("competitors", [])
        if len(cs) < 2:
            continue

        scored = len(cs[0].get("linescores", [])) > 0
        live = desc == "In Progress" or desc == "Suspended" or (desc == "Scheduled" and scored)
        done = desc == "Final" or desc == "Retired" or desc == "Walkover"

        if (live if want_live else done) and hours_since(comp.get("date", ""), now_unix) < 24:
            m = read_match(comp)
            if m != None:
                m["live"] = want_live
                out.append(m)
    return out

def title_text(ev, slug):
    if is_slam(ev):
        return ev.get("name", "TENNIS").upper()
    g = singles_grouping(ev, slug)
    if g != None:
        comps = g.get("competitions", [])
        if len(comps) > 0:
            venue = comps[0].get("venue", {}).get("fullName", "")
            if "," in venue:
                return venue[:venue.index(",")].upper()
            if venue != "":
                return venue.upper()
    return ev.get("name", "TENNIS").upper()

def draw_title(c, text, ev):
    bg = DEFAULT_TITLE_BG
    name = ev.get("name", "").upper()
    for key, col in SLAM_COLORS:
        if key in name:
            bg = col
            break
    fg = MASTERS_GOLD if is_masters(ev) else "white"
    c.rect(0, 0, c.width - 1, 4, fill = bg)
    tf = FONT
    if c.text_width(text, font = tf) > c.width - 2 and text.find(" ") == -1:
        tf = FONT_NARROW
    c.text(text, c.width // 2, 0, font = tf, color = fg, align = "center")

def narrow(c):
    return c.width <= 64

def score_font(c):
    return FONT

def set_w(c):
    return 5 if narrow(c) else SET_W

def match_winner(m):
    """1 or 2 for whichever player won more sets, 0 if undetermined.

    Counted across the FULL set list, not draw_match's display slice
    (m["sets"][-MAX_SETS:]) — a 5-set match must still resolve correctly
    from all 5, not just whichever ones happen to be shown. Works for
    retirements too: a retiree who lost at least one completed set still
    correctly colors the survivor, since that's real set-win data, not a
    guess. Zero completed sets (rare — e.g. injury before set 1 finishes)
    returns 0, which draw_match treats as "no color", not a wrong guess.
    """
    w1 = 0
    w2 = 0
    for s in m["sets"]:
        if s["w1"]:
            w1 += 1
        if s["w2"]:
            w2 += 1
    if w1 > w2:
        return 1
    if w2 > w1:
        return 2
    return 0

def draw_match(c, m, y):
    """Two rows: name left, set scores right-aligned in fixed columns."""
    sets = m["sets"][-MAX_SETS:]
    n = len(sets)
    sw = set_w(c)
    sf = score_font(c)
    name_max = c.width - n * sw - NAME_X - 2

    # Name colour priority: suspended overrides everything (paused, no
    # winner yet); live-and-serving highlights the server; a genuinely
    # finished match colors the winner's name the same yellow a won set
    # uses, instead of leaving both names white once it's over.
    if m["suspended"]:
        c1 = SUSPENDED
        c2 = SUSPENDED
    elif m["live"]:
        c1 = "green" if m["serving"] == 1 else "white"
        c2 = "green" if m["serving"] == 2 else "white"
    else:
        winner = match_winner(m)
        c1 = SET_WON if winner == 1 else "white"
        c2 = SET_WON if winner == 2 else "white"

    t1, f1 = fit_name(c, m["n1"], name_max)
    t2, f2 = fit_name(c, m["n2"], name_max)
    c.text(t1, NAME_X, y, font = f1, color = c1)
    c.text(t2, NAME_X, y + ROW_H, font = f2, color = c2)

    for i in range(n):
        x = c.width - (n - i) * sw + 1
        c.text(sets[i]["s1"], x, y, font = sf,
               color = SET_WON if sets[i]["w1"] else "white")
        c.text(sets[i]["s2"], x, y + ROW_H, font = sf,
               color = SET_WON if sets[i]["w2"] else "white")

def surname(s):
    if len(s) > 2 and s[1] == ".":
        return s[2:].strip()
    return s

def last_word(s):
    parts = surname(s).split(" ")
    return parts[len(parts) - 1]

def fit_name(c, s, max_px):
    wide_opts = [surname(s), last_word(s)] if narrow(c) else [s, surname(s), last_word(s)]
    for text in wide_opts:
        if c.text_width(text, font = FONT) <= max_px:
            return (text, FONT)

    word = last_word(s)
    if c.text_width(word, font = FONT_NARROW) <= max_px:
        return (word, FONT_NARROW)

    for i in range(len(word), 0, -1):
        if c.text_width(word[:i], font = FONT_NARROW) <= max_px:
            return (word[:i], FONT_NARROW)
    return ("", FONT_NARROW)

def message(c, lines, color = "white"):
    f = FONT
    y = 10
    for line in lines:
        c.text(line, c.width // 2, y, font = f, color = color, align = "center")
        y += ROW_H + 1

PER_PAGE = 2
PAGE_COUNT = 8

def all_matches(ev, now, slug):
    return collect(ev, now, True, slug) + collect(ev, now, False, slug)

def draw_slice(c, ctx, slot):
    c.fill("black")

    tid = ctx.inputs.get("tourneyid", "auto").strip()
    tour = ctx.inputs.get("tour", "ATP").strip().upper()
    tour_slug, group_slug = TOURS.get(tour, TOURS["ATP"])

    data = fetch(tour_slug, 60)
    if data == None:
        message(c, ["NO DATA"], "red")
        return

    now = ctx.now.unix
    ev = choose_event(data, tid, now, group_slug)
    if ev == None:
        if tid != "" and tid != "auto":
            message(c, ["TOURNAMENT", "NOT FOUND"], "gray")
        else:
            message(c, ["NO ACTIVE", "EVENTS"], "gray")
        return

    draw_title(c, title_text(ev, group_slug)[:24], ev)

    matches = all_matches(ev, now, group_slug)
    if len(matches) == 0:
        message(c, ["NO MATCHES", "TODAY"], "gray")
        return

    slices = (len(matches) + PER_PAGE - 1) // PER_PAGE
    start = (slot % slices) * PER_PAGE

    first = matches[start]
    draw_match(c, first, 6)
    mark(c, 6, first["live"])

    if start + 1 < len(matches):
        second = matches[start + 1]
        c.line(0, 18, c.width - 1, 18, "darkgray")
        draw_match(c, second, 20)
        mark(c, 20, second["live"])

def mark(c, y, is_live):
    if is_live:
        c.line(0, y, 0, y + ROW_H * 2 - 2, "green")

def p1(c, ctx):
    draw_slice(c, ctx, 0)

def p2(c, ctx):
    draw_slice(c, ctx, 1)

def p3(c, ctx):
    draw_slice(c, ctx, 2)

def p4(c, ctx):
    draw_slice(c, ctx, 3)

def p5(c, ctx):
    draw_slice(c, ctx, 4)

def p6(c, ctx):
    draw_slice(c, ctx, 5)

def p7(c, ctx):
    draw_slice(c, ctx, 6)

def p8(c, ctx):
    draw_slice(c, ctx, 7)