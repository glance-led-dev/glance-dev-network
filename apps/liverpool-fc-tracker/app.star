# Soccer Club Tracker
# 128x32 Glance app: any club in any league ESPN covers.
# Pages: current/next match, last result, league table.

SITE = "https://site.api.espn.com/apis/site/v2/sports/soccer/"
WEB = "https://site.web.api.espn.com/apis/site/v2/sports/soccer/all/teams/"
STANDINGS = "https://site.api.espn.com/apis/v2/sports/soccer/"

# Setting value -> [ESPN league code, name shown on the table page].
LEAGUES = {
    "premier_league": ["eng.1", "PREMIER LEAGUE"],
    "championship": ["eng.2", "CHAMPIONSHIP"],
    "la_liga": ["esp.1", "LA LIGA"],
    "serie_a": ["ita.1", "SERIE A"],
    "bundesliga": ["ger.1", "BUNDESLIGA"],
    "ligue_1": ["fra.1", "LIGUE 1"],
    "eredivisie": ["ned.1", "EREDIVISIE"],
    "primeira_liga": ["por.1", "PRIMEIRA LIGA"],
    "scottish_premiership": ["sco.1", "PREMIERSHIP"],
    "belgian_pro_league": ["bel.1", "PRO LEAGUE"],
    "super_lig": ["tur.1", "SUPER LIG"],
    "mls": ["usa.1", "MLS"],
    "liga_mx": ["mex.1", "LIGA MX"],
    "brasileirao": ["bra.1", "BRASILEIRAO"],
    "argentina_primera": ["arg.1", "LIGA PROFESIONAL"],
    "j1_league": ["jpn.1", "J1 LEAGUE"],
    "a_league": ["aus.1", "A-LEAGUE"],
    "womens_super_league": ["eng.w.1", "WOMEN'S SUPER LG"],
    "nwsl": ["usa.nwsl", "NWSL"],
}

# Standard offset in hours and the daylight-saving rule each zone follows.
ZONES = {
    "pacific": [-8, "us"],
    "mountain": [-7, "us"],
    "central": [-6, "us"],
    "eastern": [-5, "us"],
    "alaska": [-9, "us"],
    "hawaii": [-10, ""],
    "utc": [0, ""],
    "uk": [0, "eu"],
    "central_europe": [1, "eu"],
    "eastern_europe": [2, "eu"],
    "turkey": [3, ""],
    "iceland": [0, ""],
}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

ACCENTS = {
    "á": "a", "à": "a", "â": "a", "ä": "a", "ã": "a", "å": "a",
    "é": "e", "è": "e", "ê": "e", "ë": "e",
    "í": "i", "ì": "i", "î": "i", "ï": "i",
    "ó": "o", "ò": "o", "ô": "o", "ö": "o", "õ": "o", "ø": "o",
    "ú": "u", "ù": "u", "û": "u", "ü": "u",
    "ñ": "n", "ç": "c", "ş": "s", "ğ": "g", "ı": "i", "ß": "ss",
    "Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U", "Ü": "U", "Ö": "O", "Ñ": "N",
}

GREY = "#8A8A8A"
DIM_CHIP = "#505050"
WIN = "green"
LOSS = "red"
DRAW = "amber"
LIVE = "red"


# ---------- small helpers ----------

def get(obj, key, fallback = None):
    if type(obj) != "dict":
        return fallback
    value = obj.get(key, fallback)
    return fallback if value == None else value

def first(value):
    return value[0] if type(value) == "list" and len(value) > 0 else {}

def fold(text):
    out = ""
    for ch in str(text).elems():
        out += ACCENTS.get(ch, ch)
    return out

def display(text):
    # Panel fonts are ASCII uppercase; fold accents so "Atlético" still draws.
    return fold(text).upper()

def norm(text):
    text = fold(text).lower()
    out = ""
    for ch in text.elems():
        out += ch if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") else " "
    words = [w for w in out.split(" ") if w != "" and w not in ["fc", "afc", "cf", "sc", "the"]]
    return " ".join(words)

def score_text(value):
    if type(value) == "dict":
        value = get(value, "displayValue", get(value, "value", ""))
    if type(value) == "float":
        return str(int(value))
    text = str(value).strip() if value != None else ""
    return text if text != "" and text.isdigit() else "-"

def fit(c, text, font, small, width):
    return font if c.text_width(text, font) <= width else small


# ---------- colors ----------

def hex_brightness(hexcolor):
    h = str(hexcolor).lstrip("#")
    if len(h) != 6:
        return -1
    digits = "0123456789abcdef"
    vals = []
    for i in [0, 2, 4]:
        hi = digits.find(h[i].lower())
        lo = digits.find(h[i + 1].lower())
        if hi < 0 or lo < 0:
            return -1
        vals.append(hi * 16 + lo)
    return (vals[0] * 299 + vals[1] * 587 + vals[2] * 114) // 1000

def on_color(color):
    # Plain text on a filled bar: black on light colors, white on dark ones.
    return "black" if hex_brightness(color) >= 140 else "white"

def team_color(team):
    # ESPN's primary color, unless it is too dark to read on an LED panel.
    for key in ["color", "alternateColor"]:
        value = str(get(team, key, ""))
        b = hex_brightness(value)
        if b >= 45:
            return "#" + value.lstrip("#")
    return DIM_CHIP


# ---------- time ----------

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    return era * 146097 + yoe * 365 + yoe // 4 - yoe // 100 + doy - 719468

def civil_from_days(z):
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return [y, m, d]

def weekday(days):
    return (days + 4) % 7  # 0 = Sunday

def nth_sunday(y, m, n):
    d1 = days_from_civil(y, m, 1)
    return d1 + (7 - weekday(d1)) % 7 + 7 * (n - 1)

def last_sunday(y, m):
    dn = days_from_civil(y, m + 1, 1) - 1 if m < 12 else days_from_civil(y + 1, 1, 1) - 1
    return dn - weekday(dn)

def utc_minutes(iso):
    # ESPN dates look like 2026-10-11T15:30Z.
    if type(iso) != "string" or len(iso) < 16:
        return None
    digits = iso[0:4] + iso[5:7] + iso[8:10] + iso[11:13] + iso[14:16]
    if not digits.isdigit():
        return None
    days = days_from_civil(int(iso[0:4]), int(iso[5:7]), int(iso[8:10]))
    return days * 1440 + int(iso[11:13]) * 60 + int(iso[14:16])

def offset_minutes(zone, utc):
    info = ZONES.get(zone, ZONES["pacific"])
    std = info[0] * 60
    year = civil_from_days(utc // 1440)[0]
    dst = False
    if info[1] == "us":
        start = nth_sunday(year, 3, 2) * 1440 + 120 - std
        end = nth_sunday(year, 11, 1) * 1440 + 120 - (std + 60)
        dst = utc >= start and utc < end
    elif info[1] == "eu":
        start = last_sunday(year, 3) * 1440 + 60
        end = last_sunday(year, 10) * 1440 + 60
        dst = utc >= start and utc < end
    return std + (60 if dst else 0)

def local_parts(utc, zone):
    local = utc + offset_minutes(zone, utc)
    days = local // 1440
    ymd = civil_from_days(days)
    mins = local % 1440
    return {"days": days, "month": ymd[1], "day": ymd[2], "wd": weekday(days), "hour": mins // 60, "minute": mins % 60}

def clock_text(p):
    h = p["hour"] % 12
    h = 12 if h == 0 else h
    m = p["minute"]
    return str(h) + ":" + ("0" if m < 10 else "") + str(m) + ("PM" if p["hour"] >= 12 else "AM")

def date_text(p):
    return MONTHS[p["month"] - 1] + " " + str(p["day"])


# ---------- data ----------

def find_team(league, query):
    resp = http.get(SITE + league + "/teams", ttl_seconds = 86400)
    if resp["status_code"] != 200:
        return None, "offline", []
    teams = [get(e, "team", {}) for e in get(first(get(first(get(resp["json"], "sports", [])), "leagues", [])), "teams", [])]
    if len(teams) == 0:
        return None, "offline", []
    q = norm(query)
    if q == "":
        return None, "missing", teams
    for t in teams:
        names = [get(t, k, "") for k in ["abbreviation", "displayName", "shortDisplayName", "name", "location", "nickname"]]
        if q in [norm(n) for n in names]:
            return t, "", teams
    for t in teams:
        if q in norm(get(t, "displayName", "")) or q in norm(get(t, "location", "")):
            return t, "", teams
    return None, "missing", teams

def side(competitor, league_teams):
    team = get(competitor, "team", {})
    tid = str(get(team, "id", ""))
    colored = team
    for t in league_teams:
        if str(get(t, "id", "")) == tid:
            colored = t
    return {
        "id": tid,
        "abbr": display(get(team, "abbreviation", "???"))[:4],
        "color": team_color(colored),
        "score": score_text(get(competitor, "score", "")),
        "home": get(competitor, "homeAway", "") == "home",
    }

def normalize(event, league_teams):
    comp = first(get(event, "competitions", []))
    sides = [side(x, league_teams) for x in get(comp, "competitors", [])]
    if len(sides) != 2:
        return None
    if not sides[0]["home"] and sides[1]["home"]:
        sides = [sides[1], sides[0]]
    status = get(comp, "status", get(event, "status", {}))
    stype = get(status, "type", {})
    return {
        "home": sides[0],
        "away": sides[1],
        "state": get(stype, "state", ""),
        "short": display(get(stype, "shortDetail", "")),
        "clock": display(get(status, "displayClock", "")),
        "utc": utc_minutes(get(event, "date", "")),
        "competition": competition_name(get(event, "league", {})),
    }

def competition_name(league):
    name = display(get(league, "abbreviation", get(league, "shortName", get(league, "name", ""))))
    for prefix in ["UEFA ", "ENGLISH ", "SPANISH ", "ITALIAN ", "GERMAN ", "FRENCH "]:
        if name.startswith(prefix):
            name = name[len(prefix):]
    return name

def next_or_live(team, league):
    resp = http.get(SITE + league + "/teams/" + team["id"], ttl_seconds = 60)
    if resp["status_code"] != 200:
        return None, "offline"
    return first(get(get(resp["json"], "team", {}), "nextEvent", [])), ""

def last_result(team):
    resp = http.get(WEB + team["id"] + "/schedule", ttl_seconds = 900)
    if resp["status_code"] != 200:
        return None, "offline"
    best = None
    best_date = ""
    for event in get(resp["json"], "events", []):
        comp = first(get(event, "competitions", []))
        if get(get(get(comp, "status", {}), "type", {}), "state", "") != "post":
            continue
        date = get(event, "date", "")
        if date > best_date:
            best = event
            best_date = date
    return best, ""


# ---------- drawing ----------

def chip(c, x, y, s, highlight):
    # A 30x13 scorebug chip in the club's own color.
    c.rect(x, y, x + 29, y + 12, fill = s["color"])
    for px in [[x, y], [x + 29, y], [x, y + 12], [x + 29, y + 12]]:
        c.pixel(px[0], px[1], "black")
    font = fit(c, s["abbr"], "5x7", "4x5", 26)
    c.text_stroke(s["abbr"], x + 15, y + (3 if font == "5x7" else 4), font = font, color = "white", align = "center")
    if highlight:
        c.line(x + 3, y + 14, x + 26, y + 14, "white")

def heading(c, text, color = GREY):
    font = fit(c, text, "4x5", "3x4", 116)
    c.text(text, 64, 1, font = font, color = color, align = "center")

def footer(c, text, color):
    font = fit(c, text, "4x5", "3x4", 116)
    c.text(text, 64, 26, font = font, color = color, align = "center")

def message(c, top, bottom, top_color = "white"):
    c.clear()
    c.text(top, 64, 8, font = fit(c, top, "5x7", "4x5", 116), color = top_color, align = "center")
    c.text(bottom, 64, 20, font = fit(c, bottom, "4x5", "3x4", 116), color = GREY, align = "center")

def error_screen(c, reason, ctx):
    if reason == "missing":
        message(c, "TEAM NOT FOUND", "CHECK TEAM + LEAGUE", "red")
    else:
        message(c, "NO SCORES DATA", "ESPN UNAVAILABLE", "amber")

def result_of(match, team_id):
    mine = match["home"] if match["home"]["id"] == team_id else match["away"]
    theirs = match["away"] if mine == match["home"] else match["home"]
    if mine["score"] == "-" or theirs["score"] == "-":
        return ["FULL TIME", "white"]
    a = int(mine["score"])
    b = int(theirs["score"])
    if a > b:
        return ["WIN", WIN]
    if a < b:
        return ["LOSS", LOSS]
    return ["DRAW", DRAW]

def draw_fixture(c, match, team_id, center, center_font, bottom, bottom_color):
    heading(c, match["competition"])
    chip(c, 6, 9, match["home"], match["home"]["id"] == team_id)
    chip(c, 92, 9, match["away"], match["away"]["id"] == team_id)
    font = fit(c, center, center_font, "5x7", 52)
    h = 12 if font == center_font and center_font == "scoretext" else 7
    c.text(center, 64, 9 + (13 - h) // 2, font = font, color = "white", align = "center")
    footer(c, bottom, bottom_color)

def score_line(match):
    return match["home"]["score"] + "-" + match["away"]["score"]

def setup(c, ctx):
    league = LEAGUES.get(ctx.inputs.get("league", "premier_league"), LEAGUES["premier_league"])
    team, err, teams = find_team(league[0], ctx.inputs.get("team", "Liverpool"))
    return league, team, err, teams


# ---------- pages ----------

def match(c, ctx):
    c.clear()
    league, team, err, teams = setup(c, ctx)
    if team == None:
        error_screen(c, err, ctx)
        return
    event, err = next_or_live(team, league[0])
    if err != "":
        error_screen(c, err, ctx)
        return
    m = normalize(event, teams) if event else None
    if m == None:
        message(c, display(get(team, "shortDisplayName", "")), "NO UPCOMING MATCH")
        return
    tid = str(team["id"])
    zone = ctx.inputs.get("timezone", "pacific")
    if m["state"] == "in":
        detail = m["short"] if m["short"] in ["HT", "FT", "ET", "PENS"] else m["clock"]
        draw_fixture(c, m, tid, score_line(m), "scoretext", "LIVE  " + detail, LIVE)
    elif m["state"] == "post":
        r = result_of(m, tid)
        draw_fixture(c, m, tid, score_line(m), "scoretext", "FULL TIME  " + r[0], r[1])
    elif m["utc"] == None:
        draw_fixture(c, m, tid, "VS", "5x7", "TIME TBD", "white")
    else:
        kick = local_parts(m["utc"], zone)
        today = local_parts(ctx.now.unix // 60, zone)
        gap = kick["days"] - today["days"]
        if gap == 0:
            when = "TODAY"
        elif gap == 1:
            when = "TOMORROW"
        elif gap < 7:
            when = DAYS[kick["wd"]] + " " + date_text(kick)
        else:
            when = date_text(kick) + "  IN " + str(gap) + " DAYS"
        draw_fixture(c, m, tid, clock_text(kick), "5x7", when, "white")

def last_match(c, ctx):
    c.clear()
    league, team, err, teams = setup(c, ctx)
    if team == None:
        error_screen(c, err, ctx)
        return
    event, err = last_result(team)
    if err != "":
        error_screen(c, err, ctx)
        return
    m = normalize(event, teams) if event else None
    if m == None:
        message(c, display(get(team, "shortDisplayName", "")), "NO RESULTS YET")
        return
    tid = str(team["id"])
    r = result_of(m, tid)
    when = date_text(local_parts(m["utc"], ctx.inputs.get("timezone", "pacific"))) if m["utc"] != None else ""
    draw_fixture(c, m, tid, score_line(m), "scoretext", r[0] + "  " + when, r[1])

def stat(entry, name):
    for s in get(entry, "stats", []):
        if get(s, "name", "") == name:
            v = get(s, "value", None)
            if type(v) in ["int", "float"]:
                return int(v)
            d = str(get(s, "displayValue", "")).replace("+", "")
            if d.lstrip("-").isdigit():
                return int(d)
    return 0

def ordinal(n):
    if n <= 0:
        return "--"
    suffix = "TH"
    if n % 100 not in [11, 12, 13]:
        suffix = {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")
    return str(n) + suffix

def table(c, ctx):
    c.clear()
    league, team, err, teams = setup(c, ctx)
    if team == None:
        error_screen(c, err, ctx)
        return
    resp = http.get(STANDINGS + league[0] + "/standings", ttl_seconds = 1800)
    if resp["status_code"] != 200:
        error_screen(c, "offline", ctx)
        return
    tid = str(team["id"])
    rows = []
    group_name = ""
    for group in get(resp["json"], "children", []):
        entries = get(get(group, "standings", {}), "entries", [])
        if tid in [str(get(get(e, "team", {}), "id", "")) for e in entries]:
            rows = sorted(entries, key = lambda e: stat(e, "rank"))
            group_name = display(get(group, "abbreviation", ""))
    idx = -1
    for i, e in enumerate(rows):
        if str(get(get(e, "team", {}), "id", "")) == tid:
            idx = i
    if idx < 0:
        message(c, league[1], "NO TABLE YET")
        return

    me = rows[idx]
    color = team_color(team)

    # Left: position hero with points and record.
    title = league[1]
    if group_name in ["EAST", "WEST"] or group_name.startswith("GROUP"):
        title = title + " " + group_name
    c.text(title, 6, 1, font = fit(c, title, "4x5", "3x4", 58), color = GREY)
    c.text(ordinal(stat(me, "rank")), 6, 9, font = "scoretext", color = "white")
    c.text(str(stat(me, "points")) + " PTS", 6, 26, font = "4x5", color = color)

    # Right: four-row slice of the table around the team.
    start = max(0, min(idx - 1, len(rows) - 4))
    for n in range(4):
        i = start + n
        if i >= len(rows):
            break
        e = rows[i]
        y = 1 + n * 8
        abbr = display(get(get(e, "team", {}), "abbreviation", ""))[:4]
        is_me = i == idx
        rank = str(stat(e, "rank"))
        pts = str(stat(e, "points"))
        if is_me:
            c.rect(66, y - 1, 121, y + 5, fill = color)
        ink = on_color(color) if is_me else "white"
        dim = ink if is_me else GREY
        c.text(rank, 76, y, font = "4x5", color = dim, align = "right")
        c.text(abbr, 80, y, font = "4x5", color = ink)
        c.text(pts, 119, y, font = "4x5", color = dim, align = "right")
