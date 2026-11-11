# BCHL Scores and Leaders — native GDN app. No user credentials required.
# Live data comes straight from HockeyTech, the BCHL's official stats feed
# (the same public key bchl.ca uses). Demo is opt-in.

FEED = "https://lscluster.hockeytech.com/feed/index.php"
FEED_KEY = {"key": "ca4e9e599d4dae55", "client_code": "bchl", "lang": "en", "fmt": "json"}
ROTATE = 300  # seconds per game or player; matches the manifest refresh

# The dropdown value is the club's full name. std is its standard-time UTC offset.
FEED_ZONES = {"America/Vancouver": -8, "America/Edmonton": -7}
DEFAULT_TEAM = "Alberni Valley Bulldogs"
TEAMS = {
    "Alberni Valley Bulldogs": {"id": "16", "code": "AV", "nick": "BULLDOGS", "std": -8},
    "Blackfalds Bulldogs": {"id": "82", "code": "BFB", "nick": "BULLDOGS", "std": -7},
    "Brooks Bandits": {"id": "81", "code": "BRK", "nick": "BANDITS", "std": -7},
    "Chilliwack Chiefs": {"id": "13", "code": "CHW", "nick": "CHIEFS", "std": -8},
    "Coquitlam Express": {"id": "9", "code": "COQ", "nick": "EXPRESS", "std": -8},
    "Cowichan Valley Capitals": {"id": "10", "code": "CV", "nick": "CAPITALS", "std": -8},
    "Cranbrook Bucks": {"id": "39", "code": "CRA", "nick": "BUCKS", "std": -7},
    "Langley Rivermen": {"id": "17", "code": "LAN", "nick": "RIVERMEN", "std": -8},
    "Nanaimo Clippers": {"id": "23", "code": "NAN", "nick": "CLIPPERS", "std": -8},
    "Okotoks Oilers": {"id": "87", "code": "OKO", "nick": "OILERS", "std": -7},
    "Powell River Kings": {"id": "8", "code": "PR", "nick": "KINGS", "std": -8},
    "Prince George Spruce Kings": {"id": "14", "code": "PG", "nick": "SPRUCE KINGS", "std": -8},
    "Salmon Arm Silverbacks": {"id": "20", "code": "SA", "nick": "SILVERBACKS", "std": -8},
    "Sherwood Park Crusaders": {"id": "88", "code": "SPC", "nick": "CRUSADERS", "std": -7},
    "Spruce Grove Saints": {"id": "89", "code": "SGS", "nick": "SAINTS", "std": -7},
    "Surrey Eagles": {"id": "11", "code": "SUR", "nick": "EAGLES", "std": -8},
    "Trail Smoke Eaters": {"id": "22", "code": "TRA", "nick": "SMOKE EATERS", "std": -8},
    "Vernon Vipers": {"id": "21", "code": "VER", "nick": "VIPERS", "std": -8},
    "Victoria Grizzlies": {"id": "18", "code": "VIC", "nick": "GRIZZLIES", "std": -8},
    "West Kelowna Warriors": {"id": "19", "code": "WK", "nick": "WARRIORS", "std": -8},
}

LEFT = 10
RIGHT = 181
WHITE = "#FFFFFF"
GRAY = "#8C8C8C"
DIM = "#5A5A5A"
RED = "#FF3B30"
AMBER = "#FFBF00"
GREEN = "#3DDC84"

DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# Official team marks, 28x28. Paths stay literal so the asset lint can see them.
LOGOS = {
    "8": "assets/logos/8.png",
    "9": "assets/logos/9.png",
    "10": "assets/logos/10.png",
    "11": "assets/logos/11.png",
    "13": "assets/logos/13.png",
    "14": "assets/logos/14.png",
    "16": "assets/logos/16.png",
    "17": "assets/logos/17.png",
    "18": "assets/logos/18.png",
    "19": "assets/logos/19.png",
    "20": "assets/logos/20.png",
    "21": "assets/logos/21.png",
    "22": "assets/logos/22.png",
    "23": "assets/logos/23.png",
    "39": "assets/logos/39.png",
    "81": "assets/logos/81.png",
    "82": "assets/logos/82.png",
    "87": "assets/logos/87.png",
    "88": "assets/logos/88.png",
    "89": "assets/logos/89.png",
}

# ---------- time (feed times are ISO with an offset; we show the picked team's zone)

def _days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _civil(days):
    z = days + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return (yoe + era * 400 + (1 if m <= 2 else 0), m, d)

def _sunday(y, m, nth):
    first = _days_from_civil(y, m, 1)
    return first + (7 - (first + 4) % 7) % 7 + 7 * (nth - 1)

def _local(unix, std):
    # Local seconds: DST runs 2 AM 2nd Sunday of March to 2 AM 1st Sunday of November.
    y = _civil(unix // 86400)[0]
    start = _sunday(y, 3, 2) * 86400 + (2 - std) * 3600
    end = _sunday(y, 11, 1) * 86400 + (1 - std) * 3600
    return unix + (std + 1 if start <= unix and unix < end else std) * 3600

def _parse_iso(s, zone):
    # "2026-10-30T19:00:00-06:00" -> unix seconds, or None. The feed's wall clock is right but
    # its offset stays on daylight time all year, so the game's named zone decides the offset.
    if type(s) != "string" or len(s) < 25:
        return None
    d = s[0:10].split("-")
    t = s[11:19].split(":")
    if len(d) != 3 or len(t) != 3:
        return None
    for part in d + t + [s[20:22], s[23:25]]:
        if not part.isdigit():
            return None
    offset = (int(s[20:22]) * 3600 + int(s[23:25]) * 60) * (-1 if s[19] == "-" else 1)
    local = _days_from_civil(int(d[0]), int(d[1]), int(d[2])) * 86400 + int(t[0]) * 3600 + int(t[1]) * 60
    std = FEED_ZONES.get(zone)
    if std == None:
        return local - offset
    start = _sunday(int(d[0]), 3, 2) * 86400 + 2 * 3600
    end = _sunday(int(d[0]), 11, 1) * 86400 + 2 * 3600
    return local - (std + 1 if start <= local and local < end else std) * 3600

def _day(unix, std):
    return _local(unix, std) // 86400

def _date_label(day):
    ymd = _civil(day)
    return DAYS[(day + 4) % 7] + " " + MONTHS[ymd[1] - 1] + " " + str(ymd[2])

def _clock(unix, std):
    secs = _local(unix, std) % 86400
    h = secs // 3600
    m = (secs % 3600) // 60
    return (str(h % 12 if h % 12 else 12) + ":" + ("0" if m < 10 else "") + str(m), "PM" if h >= 12 else "AM")

# ---------- feed

def _feed(params, ttl):
    query = dict(FEED_KEY)
    query.update(params)
    resp = http.get(FEED, headers = {}, params = query, ttl_seconds = ttl)
    if resp["status_code"] != 200:
        return None
    body = resp["json"]
    if type(body) != "dict" or type(body.get("SiteKit")) != "dict":
        return None
    return body["SiteKit"]

def _str(value):
    return str(value) if value != None else ""

def _num(value):
    s = _str(value)
    return int(s) if s.isdigit() else 0

def _game(raw):
    if type(raw) != "dict":
        return None
    unix = _parse_iso(raw.get("GameDateISO8601"), raw.get("Timezone"))
    away = _str(raw.get("VisitorID"))
    home = _str(raw.get("HomeID"))
    if unix == None or away == "" or home == "":
        return None
    text = _str(raw.get("GameStatusString")).upper()
    status = _str(raw.get("GameStatus"))
    if "FINAL" in text:
        state = "final"
        label = text
    elif status == "1" or status == "":
        state = "pre"
        label = ""
    else:
        state = "live"
        period = _str(raw.get("PeriodNameShort")).upper()
        period = "P" + period if period.isdigit() else period
        if _str(raw.get("Intermission")) == "1":
            label = "INT " + period
        else:
            label = period + " " + _str(raw.get("GameClock"))
    return {
        "unix": unix,
        "state": state,
        "label": label,
        "away": {
            "id": away,
            "code": _str(raw.get("VisitorCode")),
            "goals": _str(raw.get("VisitorGoals")),
            "record": "%d-%d-%d" % (_num(raw.get("VisitorWins")), _num(raw.get("VisitorRegulationLosses")), _num(raw.get("VisitorOTLosses")) + _num(raw.get("VisitorShootoutLosses"))),
        },
        "home": {
            "id": home,
            "code": _str(raw.get("HomeCode")),
            "goals": _str(raw.get("HomeGoals")),
            "record": "%d-%d-%d" % (_num(raw.get("HomeWins")), _num(raw.get("HomeRegulationLosses")), _num(raw.get("HomeOTLosses")) + _num(raw.get("HomeShootoutLosses"))),
        },
    }

def _games(params, ttl):
    query = {"feed": "modulekit", "view": "scorebar"}
    query.update(params)
    kit = _feed(query, ttl)
    if kit == None or type(kit.get("Scorebar")) != "list":
        return None
    games = []
    for raw in kit["Scorebar"]:
        game = _game(raw)
        if game != None:
            games.append(game)
    return sorted(games, key = lambda g: g["unix"])

def _stat(ctx):
    value = ctx.inputs.get("stat", "points")
    return value if value in ["points", "goals", "assists"] else "points"

def _scope(ctx):
    return "team" if ctx.inputs.get("scope", "league") == "team" else "league"

def _team(ctx):
    return TEAMS.get(ctx.inputs.get("team", DEFAULT_TEAM)) or TEAMS[DEFAULT_TEAM]

def _demo(ctx):
    return ctx.inputs.get("mode", "live") == "demo"

# ---------- drawing

def _fit(c, value, width, font):
    text = str(value).upper()
    if c.text_width(text, font = font) <= width:
        return text
    for length in range(len(text) - 1, -1, -1):
        short = text[:length].rstrip(" .") + "."
        if c.text_width(short, font = font) <= width:
            return short
    return ""

def _text(c, value, x, y, width, color, font = "5x7"):
    c.text(_fit(c, value, width, font), x, y, font = font, color = color)

def _center(c, value, center, y, width, color, font = "5x7"):
    text = _fit(c, value, width, font)
    c.text(text, center - c.text_width(text, font = font) // 2, y, font = font, color = color)

def _right(c, value, right, y, width, color, font = "5x7"):
    text = _fit(c, value, width, font)
    c.text(text, right + 1 - c.text_width(text, font = font), y, font = font, color = color)

def _logo(c, team, x, y):
    path = LOGOS.get(team["id"])
    if path != None:
        c.image(path, x, y, w = 28, h = 28)
    else:
        # New or renamed club: a framed code rather than some other team's mark.
        c.rect(x + 1, y + 1, x + 26, y + 26, outline = DIM)
        _center(c, team["code"], x + 14, y + 10, 24, GRAY)

def _notice(c, first, second, color):
    c.fill("black")
    c.text("BCHL", LEFT, 3, font = "10x16_bold", color = RED)
    _text(c, first, 58, 6, 124, color)
    _text(c, second, 58, 18, 124, GRAY)

def _match(c, game, tag, tag_color, pager, now, std):
    c.fill("black")
    away = game["away"]
    home = game["home"]
    _logo(c, away, LEFT, 2)
    _logo(c, home, RIGHT - 27, 2)

    # Team codes and records flank the score.
    c.text(_fit(c, away["code"], 26, "7x12"), 41, 3, font = "7x12", color = WHITE)
    _right(c, home["code"], 150, 3, 26, WHITE, "7x12")
    c.text(away["record"], 41, 18, font = "4x5", color = GRAY)
    _right(c, home["record"], 150, 18, 30, GRAY, "4x5")

    state = game["state"]
    if state == "pre":
        clock = _clock(game["unix"], std)
        width = c.text_width(clock[0], font = "10x16_bold") + 2 + c.text_width(clock[1], font = "4x5")
        x = 96 - width // 2
        c.text(clock[0], x, 3, font = "10x16_bold", color = WHITE)
        c.text(clock[1], x + width - c.text_width(clock[1], font = "4x5"), 13, font = "4x5", color = GRAY)
        day = _day(game["unix"], std)
        status = "TODAY " + ("PT" if std == -8 else "MT") if day == _day(now, std) else _date_label(day)
        status_color = AMBER
    else:
        ag = _num(away["goals"])
        hg = _num(home["goals"])
        live = state == "live"
        a_color = WHITE if live or ag >= hg else DIM
        h_color = WHITE if live or hg >= ag else DIM
        _right(c, away["goals"], 89, 1, 40, a_color, "16x20_bold")
        c.rect(93, 10, 98, 11, fill = GRAY)
        c.text(_fit(c, home["goals"], 40, "16x20_bold"), 103, 1, font = "16x20_bold", color = h_color)
        if live:
            status = game["label"]
            status_color = RED
        else:
            ymd = _civil(_day(game["unix"], std))
            status = game["label"] + " " + str(ymd[1]) + "/" + str(ymd[2])
            status_color = GRAY

    status = _fit(c, status, 68, "5x7")
    start = 96 - c.text_width(status, font = "5x7") // 2
    c.text(status, start, 24, font = "5x7", color = status_color)
    if state == "live":
        c.rect(start - 5, 26, start - 3, 28, fill = RED)

    # Footer corners: page identity on the left, pager on the right.
    c.text(tag, 41, 26, font = "4x5", color = tag_color)
    if pager:
        _right(c, pager, 150, 26, 20, DIM, "4x5")

def _pick_day(games, now, std):
    # Live games win; then today's slate; then yesterday's finals; then the next slate.
    live = [g for g in games if g["state"] == "live"]
    if live:
        return live
    today = _day(now, std)
    for wanted in [today, today - 1]:
        slate = [g for g in games if _day(g["unix"], std) == wanted]
        if slate and (wanted == today or [g for g in slate if g["state"] == "final"]):
            return slate
    upcoming = [g for g in games if _day(g["unix"], std) > today]
    if upcoming:
        first = _day(upcoming[0]["unix"], std)
        return [g for g in upcoming if _day(g["unix"], std) == first]
    if games:
        last = _day(games[-1]["unix"], std)
        return [g for g in games if _day(g["unix"], std) == last]
    return []

def scores(c, ctx):
    now = ctx.now.unix
    std = _team(ctx)["std"]
    if _demo(ctx):
        games = DEMO_GAMES
    else:
        games = _games({"numberofdaysback": "3", "numberofdaysahead": "3"}, 240)
    if games == None:
        _notice(c, "FEED UNAVAILABLE", "RETRY IN 5 MIN", AMBER)
        return
    slate = _pick_day(games, now, std)
    if not slate:
        _notice(c, "ALL CLEAR", "NO GAMES THIS WEEK", GREEN)
        return
    index = (now // ROTATE) % len(slate)
    tag = "DEMO" if _demo(ctx) else "BCHL"
    _match(c, slate[index], tag, AMBER if _demo(ctx) else RED, str(index + 1) + "/" + str(len(slate)), now, std)

def team(c, ctx):
    now = ctx.now.unix
    mine = _team(ctx)
    std = mine["std"]
    if _demo(ctx):
        games = [_demo_game(mine)]
    else:
        games = _games({"team_id": mine["id"], "numberofdaysback": "14", "numberofdaysahead": "14"}, 240)
    if games == None:
        _notice(c, "FEED UNAVAILABLE", "RETRY IN 5 MIN", AMBER)
        return
    games = [g for g in games if mine["id"] in [g["away"]["id"], g["home"]["id"]]]
    today = _day(now, std)
    live = [g for g in games if g["state"] == "live"]
    done = [g for g in games if g["state"] == "final"]
    ahead = [g for g in games if g["state"] == "pre"]
    if live:
        game, tag = live[0], "LIVE"
    elif done and _day(done[-1]["unix"], std) == today:
        game, tag = done[-1], "FINAL"
    elif ahead:
        game, tag = ahead[0], "NEXT"
    elif done:
        game, tag = done[-1], "LAST"
    else:
        _notice(c, "ALL CLEAR", "NO " + mine["code"] + " GAMES", GREEN)
        return
    if _demo(ctx):
        tag = "DEMO"
    _match(c, game, tag, AMBER if tag in ["NEXT", "DEMO"] else RED, mine["code"], now, std)

def leaders(c, ctx):
    stat = _stat(ctx)
    scope = _scope(ctx)
    mine = _team(ctx)
    if _demo(ctx):
        players = [dict(p) for p in DEMO_LEADERS]
        if scope == "team":
            for p in players:
                p.update({"team_id": mine["id"], "team_code": mine["code"]})
    else:
        params = {"feed": "modulekit", "view": "statviewtype", "type": "topscorers", "first": "0", "limit": "5", "sort": stat}
        if scope == "team":
            params["team_id"] = mine["id"]
        kit = _feed(params, 600)
        if kit == None or type(kit.get("Statviewtype")) != "list":
            _notice(c, "FEED UNAVAILABLE", "RETRY IN 5 MIN", AMBER)
            return
        players = [p for p in kit["Statviewtype"] if type(p) == "dict" and _str(p.get("team_id")) != ""]
    if not players:
        _notice(c, "ALL CLEAR", "SEASON STATS SOON", GREEN)
        return

    count = min(5, len(players))
    index = (ctx.now.unix // ROTATE) % count
    p = players[index]
    unit = {"points": "PTS", "goals": "GOALS", "assists": "ASSISTS"}[stat]

    c.fill("black")
    _logo(c, {"id": _str(p.get("team_id")), "code": _str(p.get("team_code"))}, LEFT, 2)

    value = _str(p.get(stat))
    _right(c, value, RIGHT, 1, 48, WHITE, "16x20_bold")
    _right(c, unit, RIGHT, 24, 48, GRAY, "4x5")
    value_left = RIGHT - c.text_width(value, font = "16x20_bold") - 4
    name_width = min(value_left, 140) - 41

    name = _str(p.get("shortname")) or _str(p.get("name"))
    font = "7x12" if c.text_width(name.upper(), font = "7x12") <= name_width else "5x7"
    _text(c, name, 41, 3 if font == "7x12" else 6, name_width, WHITE, font)

    rank = _str(p.get("rank")) or str(index + 1)
    where = mine["nick"] if scope == "team" else "BCHL"
    _text(c, "#" + rank + " " + where, 41, 17, name_width, AMBER)

    line = "%sG %sA %sGP" % (_str(p.get("goals")), _str(p.get("assists")), _str(p.get("games_played")))
    if stat == "points":
        line = line + " " + _str(p.get("team_code"))
    _text(c, line, 41, 26, name_width, GRAY, "4x5")

    # Rank pips: where this player sits in the top five.
    for i in range(count):
        x = RIGHT - 1 - (count - 1 - i) * 4
        c.rect(x - 1, 30, x, 31, fill = AMBER if i == index else DIM)
    if _demo(ctx):
        c.text("DEMO", 41 + name_width - c.text_width("DEMO", font = "4x5"), 26, font = "4x5", color = AMBER)

# Explicit demo mode only. Never used as a fallback for unavailable live data.
DEMO_GAMES = [
    {"unix": 1793300000, "state": "live", "label": "P2 08:42",
     "away": {"id": "14", "code": "PG", "goals": "3", "record": "9-3-1"},
     "home": {"id": "10", "code": "CV", "goals": "2", "record": "7-5-0"}},
    {"unix": 1793300000, "state": "pre", "label": "",
     "away": {"id": "21", "code": "VER", "goals": "0", "record": "8-4-1"},
     "home": {"id": "82", "code": "BFB", "goals": "0", "record": "6-7-0"}},
]

def _demo_game(mine):
    # The picked club at home against a sample visitor.
    visitor = DEMO_GAMES[0]["away"] if mine["id"] == "21" else DEMO_GAMES[1]["away"]
    return {"unix": 1793300000, "state": "pre", "label": "", "away": visitor,
            "home": {"id": mine["id"], "code": mine["code"], "goals": "0", "record": "6-7-0"}}

DEMO_LEADERS = [
    {"shortname": "A. Sample", "team_id": "87", "team_code": "OKO", "rank": "1",
     "points": "23", "goals": "9", "assists": "14", "games_played": "13"},
]
