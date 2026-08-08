# Scotland Scores Classic v0.5.0
# Designed for one 64x32 Glance Classic panel.
#
# Normal screens:
#   - Six compact match rows, no large headers.
#   - Thin competition colour stripe only.
#   - LIVE combines Premiership, Scottish Cup, League Cup and Scotland.
#   - Red team abbreviation indicates a red card when the feed exposes one.
#
# Goal takeover:
#   - Stage 1: club-colour badge + GOAL + new score.
#   - Stage 2: scorer + minute + score.
#   - A recent scoring play takes over every page.
#
# Scotland:
#   - Saltire is the visual identifier instead of a text header.
#   - Live/result score or the next Scotland fixture.
#
# ESPN supplies live scoreboard + scoring-play detail.
# TheSportsDB is used only as a lightweight next-fixture fallback.

ESPN = "https://site.api.espn.com/apis/site/v2/sports/soccer"
TSDB = "https://www.thesportsdb.com/api/v1/json/123"

PREMIERSHIP = "sco.1"
SCOTTISH_CUP = "sco.tennents"
LEAGUE_CUP = "sco.cis"

WORLD_CUP = "fifa.world"
NATIONS = "uefa.nations"
FRIENDLIES = "fifa.friendly"

SCOTLAND_ESPN_ID = "580"
SCOTLAND_TSDB_ID = "136450"

TSDB_PREMIERSHIP = "4330"
TSDB_SCOTTISH_CUP = "4723"
TSDB_LEAGUE_CUP = "4888"

CLUB_LEAGUES = [PREMIERSHIP, SCOTTISH_CUP, LEAGUE_CUP]
NATIONAL_LEAGUES = [WORLD_CUP, NATIONS, FRIENDLIES]
WATCH_LEAGUES = [
    PREMIERSHIP,
    SCOTTISH_CUP,
    LEAGUE_CUP,
    WORLD_CUP,
    NATIONS,
    FRIENDLIES,
]

MONTHS = [
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC",
]

SALTIRE = [
    "WWBBBBBBBWW",
    "BWWWBBBWWWB",
    "BBWWWBWWWBB",
    "BBBWWWWWBBB",
    "BBWWWBWWWBB",
    "BWWWBBBWWWB",
    "WWBBBBBBBWW",
]

# On these common light club colours, black text is easier to read.
BLACK_TEXT_TEAMS = ["DUT", "LIV", "PAR"]

TABLE_ABBR = {
    "ABERDEEN": "ABE",
    "CELTIC": "CEL",
    "DUNDEE": "DUN",
    "DUNDEE UNITED": "DUT",
    "FALKIRK": "FAL",
    "HEART OF MIDLOTHIAN": "HEA",
    "HEARTS": "HEA",
    "HIBERNIAN": "HIB",
    "KILMARNOCK": "KIL",
    "LIVINGSTON": "LIV",
    "MOTHERWELL": "MOT",
    "RANGERS": "RAN",
    "ST MIRREN": "STM",
    "ST. MIRREN": "STM",
    "ST JOHNSTONE": "STJ",
    "ROSS COUNTY": "ROS",
}


def force_abbr3(s, fallback = "TEAM"):
    value = str(s).upper().replace(".", "").replace(" ", "")
    if len(value) >= 3:
        return value[:3]

    fb = initials(fallback)
    if len(fb) >= 3:
        return fb[:3]

    if len(value) == 2:
        return value + fb[:1]
    if len(value) == 1:
        extra = fb[:2]
        if len(extra) < 2:
            extra = "XX"
        return value + extra[:2]

    if len(fb) == 2:
        return fb + "X"
    if len(fb) == 1:
        return fb + "XX"
    return "XXX"


OPP_FLAG_SPRITES = {
    "ENGLAND": [
        "WWWWRWWWWWW",
        "WWWWRWWWWWW",
        "RRRRRRRRRRR",
        "WWWWRWWWWWW",
        "RRRRRRRRRRR",
        "WWWWRWWWWWW",
        "WWWWRWWWWWW",
    ],
    "WALES": [
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "GGGGGGGGGGG",
        "GGGGGGGGGGG",
        "GGGGGGGGGGG",
        "GGGGGGGGGGG",
    ],
    "NORTHERN IRELAND": [
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
    ],
    "REPUBLIC OF IRELAND": [
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
    ],
    "IRELAND": [
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
        "GGGWWWWOOOO",
    ],
    "NORWAY": [
        "RRRWWBBWWRR",
        "RRRWWBBWWRR",
        "WWWWBBWWWWW",
        "BBBBBBBBBBB",
        "WWWWBBWWWWW",
        "RRRWWBBWWRR",
        "RRRWWBBWWRR",
    ],
    "DENMARK": [
        "RRRWWRRRRRR",
        "RRRWWRRRRRR",
        "WWWWWWWWWWW",
        "RRRWWRRRRRR",
        "RRRWWRRRRRR",
        "RRRWWRRRRRR",
        "RRRWWRRRRRR",
    ],
    "SWEDEN": [
        "BBBBYBBBBBB",
        "BBBBYBBBBBB",
        "YYYYYYYYYYY",
        "BBBBYBBBBBB",
        "BBBBYBBBBBB",
        "BBBBYBBBBBB",
        "BBBBYBBBBBB",
    ],
    "FINLAND": [
        "WWWBBBBWWWW",
        "WWWBBBBWWWW",
        "BBBBBBBBBBB",
        "WWWBBBBWWWW",
        "WWWBBBBWWWW",
        "WWWBBBBWWWW",
        "WWWBBBBWWWW",
    ],
    "ICELAND": [
        "BBBWWRRWWBB",
        "BBBWWRRWWBB",
        "WWWWRRWWWWW",
        "RRRRRRRRRRR",
        "WWWWRRWWWWW",
        "BBBWWRRWWBB",
        "BBBWWRRWWBB",
    ],
    "GERMANY": [
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
    ],
    "FRANCE": [
        "BBBWWWWRRRR",
        "BBBWWWWRRRR",
        "BBBWWWWRRRR",
        "BBBWWWWRRRR",
        "BBBWWWWRRRR",
        "BBBWWWWRRRR",
        "BBBWWWWRRRR",
    ],
    "SPAIN": [
        "RRRRRRRRRRR",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
        "RRRRRRRRRRR",
    ],
    "ITALY": [
        "GGGWWWWRRRR",
        "GGGWWWWRRRR",
        "GGGWWWWRRRR",
        "GGGWWWWRRRR",
        "GGGWWWWRRRR",
        "GGGWWWWRRRR",
        "GGGWWWWRRRR",
    ],
    "NETHERLANDS": [
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
    ],
    "BELGIUM": [
        "BBBYYYYRRRR",
        "BBBYYYYRRRR",
        "BBBYYYYRRRR",
        "BBBYYYYRRRR",
        "BBBYYYYRRRR",
        "BBBYYYYRRRR",
        "BBBYYYYRRRR",
    ],
    "PORTUGAL": [
        "GGGGGRRRRRR",
        "GGGGGRRRRRR",
        "GGGGGRRRRRR",
        "GGGGGRRRRRR",
        "GGGGGRRRRRR",
        "GGGGGRRRRRR",
        "GGGGGRRRRRR",
    ],
    "POLAND": [
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
    ],
    "CROATIA": [
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
    ],
    "SWITZERLAND": [
        "RRRRRRRRRRR",
        "RRRWWWWWRRR",
        "RRRWWWWWRRR",
        "RWWWWWWWWWR",
        "RRRWWWWWRRR",
        "RRRWWWWWRRR",
        "RRRRRRRRRRR",
    ],
    "AUSTRIA": [
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
    ],
    "SLOVAKIA": [
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
    ],
    "SLOVENIA": [
        "WWWWWWWWWWW",
        "WWWWWWWWWWW",
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
    ],
    "UKRAINE": [
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
        "BBBBBBBBBBB",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
        "YYYYYYYYYYY",
    ],
    "TURKEY": [
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
        "RRRRRRRRRRR",
    ],
    "GREECE": [
        "BBBBBBBBBBB",
        "WWWWWWWWWWW",
        "BBBBBBBBBBB",
        "WWWWWWWWWWW",
        "BBBBBBBBBBB",
        "WWWWWWWWWWW",
        "BBBBBBBBBBB",
    ],
    "CZECHIA": [
        "BBBBWWWWWWW",
        "BBBBWWWWWWW",
        "BBBBWWWWWWW",
        "BBBBRRRRRRR",
        "BBBBRRRRRRR",
        "BBBBRRRRRRR",
        "BBBBRRRRRRR",
    ],
    "CZECH REPUBLIC": [
        "BBBBWWWWWWW",
        "BBBBWWWWWWW",
        "BBBBWWWWWWW",
        "BBBBRRRRRRR",
        "BBBBRRRRRRR",
        "BBBBRRRRRRR",
        "BBBBRRRRRRR",
    ],
}

FLAG_LEGEND = {
    "R": "#d81e05",
    "W": "white",
    "B": "#005eb8",
    "G": "#009b48",
    "Y": "#f6c800",
    "O": "#ff8c00",
}


def fetch_scoreboard(league):
    resp = http.get(
        ESPN + "/" + league + "/scoreboard",
        params = {"limit": "100"},
        ttl_seconds = 55,
    )
    if resp["status_code"] != 200 or resp["json"] == None:
        return []

    events = resp["json"].get("events", [])
    if events == None:
        return []
    return events


def fetch_all():
    packs = []
    for league in WATCH_LEAGUES:
        packs.append([league, fetch_scoreboard(league)])
    return packs


def pack_events(packs, league):
    for pack in packs:
        if pack[0] == league:
            return pack[1]
    return []


def first_comp(ev):
    comps = ev.get("competitions", [])
    if comps == None or len(comps) == 0:
        return None
    return comps[0]


def status_type(ev):
    comp = first_comp(ev)
    if comp == None:
        return {}
    status = comp.get("status", {})
    if status == None:
        return {}
    typ = status.get("type", {})
    if typ == None:
        return {}
    return typ


def match_state(ev):
    return str(status_type(ev).get("state", ""))


def is_live(ev):
    return match_state(ev) == "in"


def is_finished(ev):
    typ = status_type(ev)
    if typ.get("completed", False):
        return True
    return str(typ.get("state", "")) == "post"


def status_text(ev):
    comp = first_comp(ev)
    if comp == None:
        return ""

    status = comp.get("status", {})
    if status == None:
        status = {}
    typ = status.get("type", {})
    if typ == None:
        typ = {}
    s = str(typ.get("shortDetail", "")).upper()
    if s == "":
        s = str(typ.get("detail", "")).upper()
    return s


def display_clock(ev):
    comp = first_comp(ev)
    if comp == None:
        return ""
    status = comp.get("status", {})
    if status == None:
        return ""
    return str(status.get("displayClock", ""))


def home_away(ev):
    comp = first_comp(ev)
    if comp == None:
        return [None, None]

    competitors = comp.get("competitors", [])
    if competitors == None:
        return [None, None]

    home = None
    away = None

    for cp in competitors:
        side = str(cp.get("homeAway", ""))
        if side == "home":
            home = cp
        elif side == "away":
            away = cp

    if home == None and len(competitors) > 0:
        home = competitors[0]
    if away == None and len(competitors) > 1:
        away = competitors[1]

    return [home, away]


def team_dict(cp):
    if cp == None:
        return {}
    t = cp.get("team", {})
    if t == None:
        return {}
    return t


def initials(name):
    s = str(name).upper().replace(".", "")
    parts = s.split(" ")
    out = ""

    for p in parts:
        if p != "" and p != "FC":
            out = out + p[0]

    if len(out) >= 3:
        return out[:3]

    flat = s.replace(" ", "")
    if len(flat) >= 3:
        return flat[:3]
    return flat


def team_abbr(cp):
    t = team_dict(cp)
    a = str(t.get("abbreviation", "")).upper()
    name = str(t.get("displayName", "TEAM"))
    return force_abbr3(a, name)

def team_id(cp):
    if cp == None:
        return ""
    t = team_dict(cp)
    tid = str(t.get("id", ""))
    if tid != "":
        return tid
    return str(cp.get("id", ""))


def team_name(cp):
    return str(team_dict(cp).get("displayName", "TEAM"))


def score(cp):
    if cp == None:
        return "-"
    value = cp.get("score", "")
    if value == None or str(value) == "":
        return "-"
    return str(value)


def shootout_score(cp):
    if cp == None:
        return ""
    value = cp.get("shootoutScore", "")
    if value == None:
        return ""
    return str(value)


def hex_color(value, fallback):
    s = str(value)
    if s == "" or s == "None" or s == "NONE":
        return fallback
    if s[0:1] == "#":
        return s
    if len(s) == 6:
        return "#" + s
    return fallback


def team_primary(cp):
    return hex_color(team_dict(cp).get("color", ""), "#3566A8")


def badge_text_color(cp):
    abbr = team_abbr(cp)
    if abbr in BLACK_TEXT_TEAMS:
        return "black"
    return "white"


def leading_int(s):
    text = str(s)
    digits = ""
    started = False

    for i in range(len(text)):
        ch = text[i]
        if ch in "0123456789":
            digits = digits + ch
            started = True
        elif started:
            break

    if digits == "":
        return -1
    return int(digits)


def minute_value(clock_text):
    text = str(clock_text)
    if text == "":
        return -1

    parts = text.split("+")
    base = leading_int(parts[0])
    if base < 0:
        return -1

    extra = 0
    if len(parts) > 1:
        x = leading_int(parts[1])
        if x > 0:
            extra = x

    return base + extra


def detail_type_text(detail):
    typ = detail.get("type", {})
    if typ == None:
        return ""
    text = str(typ.get("text", "")).upper()
    if text == "":
        text = str(typ.get("name", "")).upper()
    return text


def team_has_red(ev, cp):
    if cp == None:
        return False

    comp = first_comp(ev)
    if comp == None:
        return False

    details = comp.get("details", [])
    if details == None:
        return False

    wanted = team_id(cp)

    for detail in details:
        text = detail_type_text(detail)
        if "RED" in text and "CARD" in text:
            dt_team = detail.get("team", {})
            if dt_team == None:
                dt_team = {}
            dt = str(dt_team.get("id", ""))
            if dt == wanted:
                return True

    return False


def recent_goal_detail(ev):
    if not is_live(ev):
        return None

    comp = first_comp(ev)
    if comp == None:
        return None

    current_min = minute_value(display_clock(ev))
    if current_min < 0:
        return None

    details = comp.get("details", [])
    if details == None:
        return None

    best = None
    best_min = -1

    for detail in details:
        if detail.get("scoringPlay", False):
            clk = detail.get("clock", {})
            if clk == None:
                clk = {}
            m = minute_value(clk.get("displayValue", ""))
            if m >= best_min:
                best = detail
                best_min = m

    if best == None or best_min < 0:
        return None

    age = current_min - best_min
    if age >= 0 and age <= 2:
        return [best, age]

    return None


def event_has_scotland(ev):
    sides = home_away(ev)

    for cp in sides:
        if cp != None:
            if team_id(cp) == SCOTLAND_ESPN_ID:
                return True
            if team_name(cp).upper() == "SCOTLAND":
                return True

    return False


def detail_team_competitor(ev, detail):
    comp = first_comp(ev)
    if comp == None:
        return None

    detail_team = detail.get("team", {})
    if detail_team == None:
        detail_team = {}
    wanted = str(detail_team.get("id", ""))

    competitors = comp.get("competitors", [])
    if competitors == None:
        return None

    for cp in competitors:
        if team_id(cp) == wanted:
            return cp

    return None


def scorer_last_name(detail):
    athletes = detail.get("athletesInvolved", [])
    if athletes == None or len(athletes) == 0:
        return ""

    name = str(athletes[0].get("displayName", "")).upper()
    if name == "":
        name = str(athletes[0].get("shortName", "")).upper()
    if name == "":
        return ""

    parts = name.split(" ")
    return parts[len(parts) - 1]


def goal_minute(detail):
    clk = detail.get("clock", {})
    if clk == None:
        return ""
    return str(clk.get("displayValue", ""))


def find_goal_alert(packs):
    for pack in packs:
        league = pack[0]
        events = pack[1]

        for ev in events:
            allowed = True
            if league in NATIONAL_LEAGUES and not event_has_scotland(ev):
                allowed = False

            if allowed:
                recent = recent_goal_detail(ev)
                if recent != None:
                    return [ev, recent[0], recent[1]]

    return None


def draw_scorer_name(c, name, y, color):
    s = str(name).upper()

    if len(s) <= 6:
        c.text_center(s, y, font = "8x12", color = color)
    elif len(s) <= 8:
        c.text_center(s, y + 2, font = "6x8", color = color)
    else:
        if len(s) > 12:
            s = s[:12]
        c.text_center(s, y + 2, font = "5x7", color = color)


def draw_goal_stage_one(c, ev, detail):
    sides = home_away(ev)
    home = sides[0]
    away = sides[1]

    scorer_team = detail_team_competitor(ev, detail)
    if scorer_team == None:
        scorer_team = home

    primary = team_primary(scorer_team)
    fg = badge_text_color(scorer_team)

    c.clear()

    # Oversized club identity.
    c.badge(
        team_abbr(scorer_team),
        1,
        8,
        color = fg,
        bg = primary,
        font = "8x12",
        pad = 2,
    )

    c.text("GOAL", 63, 2, font = "6x8", color = "amber", align = "right")
    c.text(
        score(home) + "-" + score(away),
        63,
        13,
        font = "8x12",
        color = "white",
        align = "right",
    )

    minute = goal_minute(detail)
    if minute != "":
        c.text(minute, 63, 27, font = "4x5", color = primary, align = "right")


def draw_goal_stage_two(c, ev, detail):
    sides = home_away(ev)
    home = sides[0]
    away = sides[1]

    scorer_team = detail_team_competitor(ev, detail)
    if scorer_team == None:
        scorer_team = home

    primary = team_primary(scorer_team)
    name = scorer_last_name(detail)
    minute = goal_minute(detail)

    c.clear()

    c.badge(
        team_abbr(scorer_team),
        1,
        1,
        color = badge_text_color(scorer_team),
        bg = primary,
        font = "4x5",
        pad = 1,
    )

    c.text(
        score(home) + "-" + score(away),
        63,
        0,
        font = "6x8",
        color = "white",
        align = "right",
    )

    if name != "":
        draw_scorer_name(c, name, 10, primary)
    else:
        c.text_center("GOAL", 12, font = "8x12", color = "amber")

    if minute != "":
        c.text_center(minute, 27, font = "4x5", color = "gray")


def goal_takeover(c, packs):
    alert = find_goal_alert(packs)
    if alert == None:
        return False

    ev = alert[0]
    detail = alert[1]
    age = alert[2]

    # First two match-minutes: impact screen. Third: scorer screen.
    if age <= 1:
        draw_goal_stage_one(c, ev, detail)
    else:
        draw_goal_stage_two(c, ev, detail)

    return True


def middle_text(ev):
    sides = home_away(ev)
    home = sides[0]
    away = sides[1]

    if is_live(ev) or is_finished(ev):
        hs = score(home)
        ascore = score(away)
        st = status_text(ev)

        hp = shootout_score(home)
        ap = shootout_score(away)

        if hp != "" and ap != "":
            return "P" + hp + "-" + ap

        if "PEN" in st:
            return "P" + hs + "-" + ascore

        if "AET" in st or "EXTRA" in st:
            return "E" + hs + "-" + ascore

        return hs + "-" + ascore

    return "VS"


def middle_color(ev):
    if is_live(ev):
        return "red"
    if is_finished(ev):
        return "white"
    return "gray"


def row_team_color(ev, cp):
    if team_has_red(ev, cp):
        return "red"
    return "white"


def draw_match_row(c, ev, y, xleft = 3, show_comp = False, league = ""):
    sides = home_away(ev)
    home = sides[0]
    away = sides[1]

    left = xleft

    if show_comp:
        code = "?"
        code_color = "gray"

        if league == PREMIERSHIP:
            code = "P"
            code_color = "cyan"
        elif league == SCOTTISH_CUP:
            code = "C"
            code_color = "amber"
        elif league == LEAGUE_CUP:
            code = "L"
            code_color = "green"
        else:
            code = "S"
            code_color = "#5B9BFF"

        c.text(code, 1, y, font = "4x5", color = code_color)
        left = 7

    c.text(
        team_abbr(home),
        left,
        y,
        font = "4x5",
        color = row_team_color(ev, home),
    )

    c.text(
        middle_text(ev),
        33,
        y,
        font = "4x5",
        color = middle_color(ev),
        align = "center",
    )

    c.text(
        team_abbr(away),
        63,
        y,
        font = "4x5",
        color = row_team_color(ev, away),
        align = "right",
    )


def ordered_events(events):
    live_items = []
    pre_items = []
    post_items = []

    for ev in events:
        if is_live(ev):
            live_items.append(ev)
        elif is_finished(ev):
            post_items.append(ev)
        else:
            pre_items.append(ev)

    out = []

    for ev in live_items:
        out.append(ev)
    for ev in pre_items:
        out.append(ev)
    for ev in post_items:
        out.append(ev)

    return out


def draw_six_rows(c, events, stripe_color, show_comp = False, league = ""):
    c.clear()
    c.vline(0, 0, 32, stripe_color)

    if len(events) == 0:
        return False

    ordered = ordered_events(events)
    ys = [1, 7, 13, 19, 25]

    count = len(ordered)
    if count > 5:
        count = 5

    for i in range(count):
        draw_match_row(
            c,
            ordered[i],
            ys[i],
            xleft = 3,
            show_comp = show_comp,
            league = league,
        )

    return True


def tsdb_next_league(league_id):
    resp = http.get(
        TSDB + "/eventsnextleague.php",
        params = {"id": league_id},
        ttl_seconds = 300,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    events = resp["json"].get("events", [])
    if events == None or len(events) == 0:
        return None

    return events[0]


def date_label(date_text):
    parts = str(date_text).split("-")
    if len(parts) != 3:
        return ""

    month = int(parts[1])
    day = int(parts[2])

    if month < 1 or month > 12:
        return ""

    return str(day) + " " + MONTHS[month - 1]


def plain_abbr(name):
    s = str(name).upper()
    if s == "SCOTLAND":
        return "SCO"
    return force_abbr3("", s)

def draw_next_fixture(c, ev, stripe_color):
    c.clear()
    c.vline(0, 0, 32, stripe_color)

    if ev == None:
        c.text_center("NO FIXTURE", 12, font = "5x7", color = "gray")
        return

    home = plain_abbr(ev.get("strHomeTeam", "HOME"))
    away = plain_abbr(ev.get("strAwayTeam", "AWAY"))
    d = date_label(ev.get("dateEvent", ""))

    c.text(home, 3, 3, font = "6x8", color = "white")
    c.text_center("V", 4, font = "4x5", color = "gray")
    c.text(away, 63, 3, font = "6x8", color = "white", align = "right")

    if d != "":
        c.text_center(d, 17, font = "6x8", color = stripe_color)
    else:
        c.text_center("NEXT", 17, font = "6x8", color = stripe_color)


def draw_competition_page(c, packs, league, stripe_color, tsdb_id):
    if global_takeover(c, packs):
        return

    events = pack_events(packs, league)

    if draw_six_rows(c, events, stripe_color):
        return

    draw_next_fixture(c, tsdb_next_league(tsdb_id), stripe_color)

def fetch_premiership_table():
    resp = http.get(
        "https://site.web.api.espn.com/apis/v2/sports/soccer/" + PREMIERSHIP + "/standings",
        params = {"type": "0", "level": "0"},
        ttl_seconds = 300,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return []

    data = resp["json"]
    children = data.get("children", [])
    if children == None or len(children) == 0:
        return []

    standings = children[0].get("standings", {})
    if standings == None:
        return []

    entries = standings.get("entries", [])
    if entries == None:
        return []

    return entries

def table_abbr(name):
    key = str(name).upper()

    labels = {
        "ABERDEEN": "ABERDEE",
        "CELTIC": "CELTIC",
        "DUNDEE": "DUNDEE",
        "DUNDEE UNITED": "DUNUTD",
        "FALKIRK": "FALKIRK",
        "HEART OF MIDLOTHIAN": "HEARTS",
        "HEARTS": "HEARTS",
        "HIBERNIAN": "HIBERNS",
        "KILMARNOCK": "KILMARN",
        "LIVINGSTON": "LIVINGS",
        "MOTHERWELL": "MOTHERW",
        "RANGERS": "RANGERS",
        "ST MIRREN": "STMIRRN",
        "ST. MIRREN": "STMIRRN",
        "ST JOHNSTONE": "STJNSTN",
        "ROSS COUNTY": "ROSCTY",
    }

    mapped = labels.get(key, None)
    if mapped != None:
        return mapped

    raw = str(name).upper().replace(" ", "")
    if len(raw) > 7:
        return raw[:7]
    return raw

def espn_table_team_name(entry):
    team = entry.get("team", {})
    if team == None:
        return ""

    name = str(team.get("displayName", ""))
    if name == "":
        name = str(team.get("name", ""))
    return name


def espn_table_points(entry):
    stats = entry.get("stats", [])
    if stats == None:
        return "-"

    for stat in stats:
        name = str(stat.get("name", "")).lower()
        short = str(stat.get("shortDisplayName", "")).upper()

        if name == "points" or short == "PTS":
            value = stat.get("value", None)
            if value == None:
                value = stat.get("displayValue", "-")

            s = str(value)

            # ESPN sometimes returns points as 0.0 / 4.0 / 12.0.
            if s.endswith(".0"):
                s = s[:-2]

            return s

    return "-"

def draw_table_row(c, entry, x, y, points_x):
    rank = str(entry.get("intRank", ""))
    name = str(entry.get("strTeam", ""))
    pts = str(entry.get("intPoints", ""))

    if rank == "":
        rank = "-"
    if pts == "":
        pts = "-"

    c.text(rank, x, y, font = "4x5", color = "gray")
    c.text(table_abbr(name), x + 7, y, font = "4x5", color = "white")
    c.text(pts, points_x, y, font = "4x5", color = "cyan", align = "right")


def draw_premiership_table(c, ctx):
    table = fetch_premiership_table()
    if len(table) == 0:
        return False

    c.clear()

    # Full 12-team Premiership table in four readable groups.
    group = ctx.now.minute % 4
    start = group * 3

    ys = [1, 12, 23]

    for i in range(3):
        idx = start + i
        if idx >= len(table) or idx >= 12:
            break

        entry = table[idx]
        rank = str(idx + 1)
        name = espn_table_team_name(entry)
        pts = espn_table_points(entry)

        c.text(rank, 1, ys[i] + 1, font = "4x5", color = "gray")
        c.text(table_abbr(name), 8, ys[i], font = "5x7", color = "white")
        c.text(pts, 63, ys[i], font = "5x7", color = "cyan", align = "right")

    return True

def live_games_from_packs(packs):
    out = []

    for pack in packs:
        league = pack[0]
        events = pack[1]

        for ev in events:
            if is_live(ev):
                if league in NATIONAL_LEAGUES:
                    if event_has_scotland(ev):
                        out.append([league, ev])
                else:
                    out.append([league, ev])

    return out


def upcoming_games_from_packs(packs):
    out = []

    for pack in packs:
        league = pack[0]
        events = pack[1]

        for ev in events:
            if not is_live(ev) and not is_finished(ev):
                if league in NATIONAL_LEAGUES:
                    if event_has_scotland(ev):
                        out.append([league, ev])
                else:
                    out.append([league, ev])

    return out


def draw_live_games_only(c, packs):
    games = live_games_from_packs(packs)
    if len(games) == 0:
        return False

    c.clear()

    ys = [1, 7, 13, 19, 25]
    count = len(games)
    if count > 5:
        count = 5

    for i in range(count):
        draw_match_row(
            c,
            games[i][1],
            ys[i],
            show_comp = True,
            league = games[i][0],
        )

    return True


def global_takeover(c, packs):
    # Highest priority: a just-scored goal takes over everything.
    if goal_takeover(c, packs):
        return True

    # Next priority: any monitored live match takes over every normal page.
    if draw_live_games_only(c, packs):
        return True

    return False


def draw_live(c, packs, ctx):
    if global_takeover(c, packs):
        return

    # Nothing live: this page is the rotating full Premiership table.
    if draw_premiership_table(c, ctx):
        return

    # Only if standings data is unavailable, fall back to upcoming fixtures.
    c.clear()
    upcoming = upcoming_games_from_packs(packs)

    if len(upcoming) > 0:
        c.text("NEXT", 2, 0, font = "4x5", color = "gray")

        ys = [7, 13, 19, 25]
        count = len(upcoming)
        if count > 4:
            count = 4

        for i in range(count):
            draw_match_row(
                c,
                upcoming[i][1],
                ys[i],
                show_comp = True,
                league = upcoming[i][0],
            )
        return

    draw_scotland_tsdb(c, tsdb_scotland_next())

def find_scotland_event(packs):
    fallback = None

    for pack in packs:
        league = pack[0]

        if league in NATIONAL_LEAGUES:
            for ev in pack[1]:
                if event_has_scotland(ev):
                    if is_live(ev):
                        return ev
                    if fallback == None:
                        fallback = ev

    return fallback


def draw_saltire(c):
    # 11x7 Saltire, same size as the opposition flag, with a clear white cross.
    c.sprite(
        SALTIRE,
        2,
        1,
        legend = {"B": "#005EB8", "W": "white"},
    )

def month_day_from_espn(ev):
    iso = str(ev.get("date", ""))
    if iso == "":
        return ""

    datepart = iso.split("T")[0]
    return date_label(datepart)


def time_from_espn(ev):
    iso = str(ev.get("date", ""))
    if "T" not in iso:
        return ""
    t = iso.split("T")[1]
    if len(t) >= 5:
        return t[:5]
    return ""


def stadium_from_espn(ev):
    comp = first_comp(ev)
    if comp == None:
        return ""

    venue = comp.get("venue", {})
    if venue == None:
        return ""

    name = str(venue.get("fullName", "")).upper()
    if name == "":
        name = str(venue.get("displayName", "")).upper()
    return name


def clip_label(text, n):
    s = str(text).upper()

    # Remove generic venue words first so the useful part survives on 64px.
    prefixes = [
        "STADION ",
        "STADIUM ",
        "ESTADIO ",
        "STADE ",
    ]

    for prefix in prefixes:
        if s.startswith(prefix):
            s = s[len(prefix):]

    # Pixel font is ASCII-oriented; clean common accented characters.
    s = s.replace("Ž", "Z")
    s = s.replace("Š", "S")
    s = s.replace("Č", "C")
    s = s.replace("Ć", "C")
    s = s.replace("É", "E")
    s = s.replace("Á", "A")
    s = s.replace("Ö", "O")
    s = s.replace("Ü", "U")

    if len(s) > n:
        return s[:n]
    return s

def time_from_tsdb(ev):
    t = str(ev.get("strTime", ""))
    if len(t) >= 5:
        return t[:5]
    return ""


def stadium_from_tsdb(ev):
    name = str(ev.get("strVenue", "")).upper()
    return name

def scotland_opponent(ev):
    sides = home_away(ev)
    home = sides[0]
    away = sides[1]

    if team_id(home) == SCOTLAND_ESPN_ID or team_name(home).upper() == "SCOTLAND":
        return away
    return home


def is_scotland_team(cp):
    if cp == None:
        return False
    if team_id(cp) == SCOTLAND_ESPN_ID:
        return True
    return team_name(cp).upper() == "SCOTLAND"


def opponent_display_name(cp):
    return team_name(cp).upper()


def opponent_flag_sprite(cp):
    name = opponent_display_name(cp)
    return OPP_FLAG_SPRITES.get(name, None)


def draw_opponent_flag(c, cp, x, y):
    sprite = opponent_flag_sprite(cp)
    if sprite != None:
        c.sprite(sprite, x, y, legend = FLAG_LEGEND)


def draw_scotland_espn(c, ev):
    c.clear()

    sides = home_away(ev)
    home = sides[0]
    away = sides[1]

    home_is_scotland = is_scotland_team(home)
    away_is_scotland = is_scotland_team(away)

    # Flags always follow actual fixture order: home left, away right.
    if home_is_scotland:
        draw_saltire(c)
        c.text("SCO", 7, 10, font = "4x5", color = "white", align = "center")
    else:
        draw_opponent_flag(c, home, 2, 1)
        c.text(team_abbr(home), 7, 10, font = "4x5", color = "white", align = "center")

    c.text("VS", 31, 10, font = "4x5", color = "gray", align = "center")

    if away_is_scotland:
        c.sprite(
            SALTIRE,
            51,
            1,
            legend = {"B": "#005EB8", "W": "white"},
        )
        c.text("SCO", 56, 10, font = "4x5", color = "white", align = "center")
    else:
        draw_opponent_flag(c, away, 51, 1)
        c.text(team_abbr(away), 56, 10, font = "4x5", color = "white", align = "center")

    if is_live(ev) or is_finished(ev):
        score_color = "#74A9FF"
        if is_live(ev):
            score_color = "red"

        c.text_center(
            score(home) + "-" + score(away),
            17,
            font = "8x12",
            color = score_color,
        )

        if is_live(ev):
            clock = display_clock(ev)
            if clock != "":
                c.text_center(clock, 28, font = "4x5", color = "red")
        else:
            c.text_center("FT", 28, font = "4x5", color = "gray")
        return

    date_text = month_day_from_espn(ev)
    time_text = time_from_espn(ev)
    lower = date_text
    if time_text != "":
        if lower != "":
            lower = lower + " " + time_text
        else:
            lower = time_text

    if lower != "":
        c.text_center(lower, 19, font = "4x5", color = "#74A9FF")
    else:
        c.text_center("NEXT", 19, font = "4x5", color = "#74A9FF")

    stad = clip_label(stadium_from_espn(ev), 14)
    if stad != "":
        c.text_center(stad, 26, font = "4x5", color = "gray")

def tsdb_scotland_next():
    resp = http.get(
        TSDB + "/eventsnext.php",
        params = {"id": SCOTLAND_TSDB_ID},
        ttl_seconds = 300,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    events = resp["json"].get("events", [])
    if events == None or len(events) == 0:
        return None

    return events[0]


def draw_scotland_tsdb(c, ev):
    c.clear()

    if ev == None:
        draw_saltire(c)
        c.text("SCO", 7, 10, font = "4x5", color = "white", align = "center")
        c.text("VS", 31, 10, font = "4x5", color = "gray", align = "center")
        c.text("XXX", 56, 10, font = "4x5", color = "gray", align = "center")
        return

    home = str(ev.get("strHomeTeam", ""))
    away = str(ev.get("strAwayTeam", ""))

    home_scotland = home.upper() == "SCOTLAND"
    away_scotland = away.upper() == "SCOTLAND"

    if home_scotland:
        draw_saltire(c)
        c.text("SCO", 7, 10, font = "4x5", color = "white", align = "center")
    else:
        home_pseudo = {"team": {"displayName": home}}
        draw_opponent_flag(c, home_pseudo, 2, 1)
        c.text(plain_abbr(home), 7, 10, font = "4x5", color = "white", align = "center")

    c.text("VS", 31, 10, font = "4x5", color = "gray", align = "center")

    if away_scotland:
        c.sprite(
            SALTIRE,
            51,
            1,
            legend = {"B": "#005EB8", "W": "white"},
        )
        c.text("SCO", 56, 10, font = "4x5", color = "white", align = "center")
    else:
        away_pseudo = {"team": {"displayName": away}}
        draw_opponent_flag(c, away_pseudo, 51, 1)
        c.text(plain_abbr(away), 56, 10, font = "4x5", color = "white", align = "center")

    lower = date_label(ev.get("dateEvent", ""))
    tm = time_from_tsdb(ev)
    if tm != "":
        if lower != "":
            lower = lower + " " + tm
        else:
            lower = tm

    if lower != "":
        c.text_center(lower, 19, font = "4x5", color = "#74A9FF")
    else:
        c.text_center("NEXT", 19, font = "4x5", color = "#74A9FF")

    stad = clip_label(stadium_from_tsdb(ev), 14)
    if stad != "":
        c.text_center(stad, 26, font = "4x5", color = "gray")

def combined_cup_items(packs):
    out = []

    for ev in pack_events(packs, SCOTTISH_CUP):
        out.append([SCOTTISH_CUP, ev])

    for ev in pack_events(packs, LEAGUE_CUP):
        out.append([LEAGUE_CUP, ev])

    return out


def ordered_combo(items):
    live_items = []
    pre_items = []
    post_items = []

    for item in items:
        ev = item[1]
        if is_live(ev):
            live_items.append(item)
        elif is_finished(ev):
            post_items.append(item)
        else:
            pre_items.append(item)

    out = []
    for item in live_items:
        out.append(item)
    for item in pre_items:
        out.append(item)
    for item in post_items:
        out.append(item)

    return out


def pseudo_pre_event(home, away):
    return {
        "competitions": [{
            "competitors": [
                {"team": {"displayName": home, "abbreviation": plain_abbr(home)}, "homeAway": "home"},
                {"team": {"displayName": away, "abbreviation": plain_abbr(away)}, "homeAway": "away"},
            ],
            "status": {"type": {"state": "pre"}}
        }]
    }


def draw_cup(c, packs):
    if global_takeover(c, packs):
        return

    items = combined_cup_items(packs)
    c.clear()

    if len(items) > 0:
        ordered = ordered_combo(items)

        c.text("CUP", 1, 0, font = "4x5", color = "amber")

        ys = [7, 13, 19, 25]
        count = len(ordered)
        if count > 4:
            count = 4

        for i in range(count):
            draw_match_row(
                c,
                ordered[i][1],
                ys[i],
                xleft = 3,
                show_comp = False,
            )
        return

    c.text("CUP", 1, 0, font = "4x5", color = "amber")

    row = 8

    sc = tsdb_next_league(TSDB_SCOTTISH_CUP)
    if sc != None:
        draw_match_row(
            c,
            pseudo_pre_event(
                sc.get("strHomeTeam", "HOME"),
                sc.get("strAwayTeam", "AWAY"),
            ),
            row,
            xleft = 3,
        )
        row += 8

    lc = tsdb_next_league(TSDB_LEAGUE_CUP)
    if lc != None and row <= 24:
        draw_match_row(
            c,
            pseudo_pre_event(
                lc.get("strHomeTeam", "HOME"),
                lc.get("strAwayTeam", "AWAY"),
            ),
            row,
            xleft = 3,
        )

def draw_scotland(c, packs):
    if global_takeover(c, packs):
        return

    ev = find_scotland_event(packs)
    if ev != None:
        draw_scotland_espn(c, ev)
        return

    draw_scotland_tsdb(c, tsdb_scotland_next())

def table(c, ctx):
    packs = fetch_all()
    draw_live(c, packs, ctx)

def premiership(c, ctx):
    packs = fetch_all()
    draw_competition_page(
        c,
        packs,
        PREMIERSHIP,
        "cyan",
        TSDB_PREMIERSHIP,
    )


def cup(c, ctx):
    packs = fetch_all()
    draw_cup(c, packs)

def scotland(c, ctx):
    packs = fetch_all()
    draw_scotland(c, packs)
