# Bundesliga Tracked Team
#
# Version 1:
# - Last completed Bundesliga match
# - Next scheduled Bundesliga match
# - Current Bundesliga standing
#
# Data source: ESPN public soccer API

BASE = "https://site.api.espn.com/apis/"
SCORES = BASE + "site/v2/sports/soccer/ger.1/scoreboard"
TABLE = BASE + "v2/sports/soccer/ger.1/standings"

ACCENT = "#FDE100"
TEXT = "white"
DIM = "gray"
TEAMS = {
    "DOR": {
        "display": "BVB",
        "name": "DORTMUND",
        "color": "#FDE100",
        "crest": "DOR22.png",
    },
    "MUN": {
        "display": "FCB",
        "name": "BAYERN",
        "color": "#DC052D",
        "crest": "MUN22.png",
    },
    "B04": {
        "display": "B04",
        "name": "LEVERKUSEN",
        "color": "#E32221",
        "crest": "B0422.png",
    },
    "RBL": {
        "display": "RBL",
        "name": "LEIPZIG",
        "color": "#DD0741",
        "crest": "RBL22.png",
    },
    "VFB": {
        "display": "VFB",
        "name": "STUTTGART",
        "color": "#E32219",
        "crest": "VFB22.png",
    },
    "SGE": {
        "display": "SGE",
        "name": "FRANKFURT",
        "color": "#E1000F",
        "crest": "SGE22.png",
    },
    "SCF": {
        "display": "SCF",
        "name": "FREIBURG",
        "color": "#E30613",
        "crest": "SCF22.png",
    },
    "TSG": {
        "display": "TSG",
        "name": "HOFFENHEIM",
        "color": "#1961AC",
        "crest": "TSG22.png",
    },
    "BMG": {
        "display": "BMG",
        "name": "GLADBACH",
        "color": "#FFFFFF",
        "crest": "BMG22.png",
    },
    "M05": {
        "display": "M05",
        "name": "MAINZ",
        "color": "#C31431",
        "crest": "M0522.png",
    },
    "FCU": {
        "display": "FCU",
        "name": "UNION",
        "color": "#EB1923",
        "crest": "FCU22.png",
    },
    "SVW": {
        "display": "SVW",
        "name": "BREMEN",
        "color": "#1D9053",
        "crest": "SVW22.png",
    },
    "FCA": {
        "display": "FCA",
        "name": "AUGSBURG",
        "color": "#BA3733",
        "crest": "FCA22.png",
    },
    "KOE": {
        "display": "KOE",
        "name": "COLOGNE",
        "color": "#ED1C24",
        "crest": "KOE22.png",
    },
    "HSV": {
        "display": "HSV",
        "name": "HAMBURG",
        "color": "#0A3F86",
        "crest": "HSV22.png",
    },
    "S04": {
        "display": "S04",
        "name": "SCHALKE",
        "color": "#004D9D",
        "crest": "S0422.png",
    },
    "SCP": {
        "display": "SCP",
        "name": "PADERBORN",
        "color": "#005CA9",
        "crest": "SCP22.png",
    },
    "ELV": {
        "display": "ELV",
        "name": "ELVERSBERG",
        "color": "#E30613",
        "crest": "ELV22.png",
    },
}


# ------------------------------------------------------------
# Basic helpers
# ------------------------------------------------------------

TEAM_ALIASES = {
    "DOR": ["borussia dortmund", "dortmund", "bvb"],
    "MUN": ["bayern munich", "bayern münchen", "bayern munchen", "bayern muenchen", "fc bayern münchen", "fc bayern munich", "bayern", "fcb", "bay"],
    "B04": ["bayer leverkusen", "bayer 04 leverkusen", "leverkusen", "lev"],
    "RBL": ["rb leipzig", "rasenballsport leipzig", "leipzig"],
    "VFB": ["vfb stuttgart", "stuttgart", "stu"],
    "SGE": ["eintracht frankfurt", "frankfurt", "fra"],
    "SCF": ["sc freiburg", "freiburg", "fre"],
    "TSG": ["tsg hoffenheim", "tsg 1899 hoffenheim", "1899 hoffenheim", "hoffenheim", "hof"],
    "BMG": ["borussia monchengladbach", "borussia mönchengladbach", "borussia moenchengladbach", "borussia m'gladbach", "mönchengladbach", "gladbach"],
    "M05": ["mainz", "mainz 05", "1. fsv mainz 05", "fsv mainz 05", "mai"],
    "FCU": ["union berlin", "1. fc union berlin", "fc union berlin", "uni", "unb"],
    "SVW": ["werder bremen", "sv werder bremen", "bremen", "bre"],
    "FCA": ["fc augsburg", "augsburg", "aug"],
    "KOE": ["fc cologne", "cologne", "fc köln", "1. fc köln", "1. fc koln", "fc koln", "köln", "koln", "kol"],
    "HSV": ["hamburg sv", "hamburger sv", "hamburg", "ham"],
    "S04": ["schalke 04", "fc schalke 04", "schalke", "sch"],
    "SCP": ["sc paderborn 07", "sc paderborn", "paderborn", "paderborn 07", "pad"],
    "ELV": ["sv elversberg", "sv 07 elversberg", "elversberg"],
}


def list_value(value):
    return value if type(value) == "list" else []


def internal_team_from_info(info):
    name = str(get(info, "displayName", get(info, "name", ""))).strip().lower()
    abbr = str(get(info, "abbreviation", "?")).strip().upper()
    for key in TEAM_ALIASES:
        if name in TEAM_ALIASES[key]:
            return key
    if abbr in TEAMS:
        return abbr
    for key in TEAM_ALIASES:
        if abbr.lower() in TEAM_ALIASES[key] or abbr == TEAMS[key]["display"]:
            return key
    return abbr


def read_match_events(data, ctx, fixtures=False):
    raw = get(data, "events", None)
    if type(raw) != "list":
        return None
    events = []
    now_local = ctx.now.unix // 60 + zone_offset(ctx)
    for event in raw:
        comps = list_value(get(event, "competitions", []))
        if len(comps) == 0:
            continue
        comp = comps[0]
        parsed = parse_competition(comp, ctx)
        if parsed == None:
            continue
        event_start = parse_iso(get(event, "date", ""), zone_offset(ctx))
        if event_start != None:
            parsed["start"] = event_start
        status = get(comp, "status", get(event, "status", {}))
        status_type = get(status, "type", {})
        state = str(get(status_type, "state", "")).lower()
        status_name = str(get(status_type, "name", "")).upper()
        # A dated fixture without status may be upcoming, never assumed final.
        if state == "" and status_name == "" and fixtures and parsed["start"] != None and parsed["start"] > now_local:
            state = "pre"
        if status_name in ["STATUS_POSTPONED", "STATUS_CANCELED", "STATUS_CANCELLED", "STATUS_SUSPENDED", "STATUS_ABANDONED"]:
            state = "unavailable"
        if state == "pre" and (parsed["start"] == None or parsed["start"] <= now_local):
            continue
        if state == "post" and parsed["start"] == None:
            continue
        parsed["state"] = state
        parsed["clock"] = str(get(status_type, "shortDetail", get(status_type, "detail", get(status, "displayClock", ""))))
        events.append(parsed)
    return events


def signed_stat_number(value):
    if type(value) == "int":
        return value
    if type(value) == "float":
        return int(value) if value == int(value) else None
    if type(value) != "string":
        return None
    text = value.strip().replace("−", "-")
    if text == "":
        return None
    digits = text[1:] if text[0] in ["+", "-"] else text
    if digits == "":
        return None
    for ch in digits.elems():
        if ch < "0" or ch > "9":
            return None
    return int(text)


def named_standing_number(stats, names, abbreviation=""):
    for name in names:
        for stat in list_value(stats):
            if get(stat, "name", "") == name:
                value = signed_stat_number(get(stat, "value", None))
                if value == None:
                    value = signed_stat_number(get(stat, "displayValue", None))
                if value != None:
                    return value
    if abbreviation != "":
        for stat in list_value(stats):
            if str(get(stat, "abbreviation", "")).upper() == abbreviation:
                value = signed_stat_number(get(stat, "value", None))
                if value == None:
                    value = signed_stat_number(get(stat, "displayValue", None))
                if value != None:
                    return value
    return None


def standing_goal_difference(stats):
    gd = named_standing_number(
        stats, ["pointDifferential", "goalDifference", "goalDifferential"], "GD",
    )
    if gd != None:
        return gd
    goals_for = named_standing_number(stats, ["pointsFor", "goalsFor"], "GF")
    goals_against = named_standing_number(stats, ["pointsAgainst", "goalsAgainst"], "GA")
    if goals_for != None and goals_against != None:
        return goals_for - goals_against
    return None


def goal_difference_text(value):
    if value == None:
        return "--"
    return ("+" if value > 0 else "") + str(value)


def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    value = obj.get(key, fallback)
    return fallback if value == None else value


def dig(obj, path, fallback = None):
    current = obj
    for key in path:
        if current == None or type(current) != "dict":
            return fallback
        current = current.get(key, None)
    return fallback if current == None else current


def num(value, fallback = 0):
    text = str(value).strip()

    digits = ""
    for ch in text.elems():
        if ch >= "0" and ch <= "9":
            digits += ch

    if digits == "":
        return fallback

    return int(digits)


def team_selected(ctx):
    return str(ctx.inputs.get("team", "DOR")).strip().upper()

def team_info(team):
    if team in TEAMS:
        return TEAMS[team]

    return {
        "display": team,
        "name": team,
        "color": ACCENT,
    }


def display_team(team):
    return team_info(team)["display"]


def team_color(team):
    return team_info(team)["color"]

def team_crest(team):
    info = team_info(team)
    if "crest" in info:
        return info["crest"]
    return ""

def opponent_of(match, team):
    if match["home"]["abbr"] == team:
        return match["away"]
    return match["home"]

def live_minute(match):
    detail = str(match.get("clock", "")).upper()
    if "PEN" in detail or "SHOOTOUT" in detail:
        return "PENS"
    if "HALFTIME" in detail or "HALF TIME" in detail or detail == "HT":
        return "HT"
    digits = ""
    for ch in detail.elems():
        if (ch >= "0" and ch <= "9") or (ch == "+" and digits != ""):
            digits += ch
        elif digits != "":
            break
    return digits + "'" if digits != "" else "LIVE"

def draw_team_rail(c, team):
    c.rect(0, 0, 1, 31, fill = team_color(team))

def draw_end_rail(c, team):
    c.rect(126, 0, 127, 31, fill = team_color(team))

def ordinal(n):
    if n == 1:
        return "1ST"
    if n == 2:
        return "2ND"
    if n == 3:
        return "3RD"
    return str(n) + "TH"

# ------------------------------------------------------------
# Time helpers
# ------------------------------------------------------------

MONTHS = [
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC",
]


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


def parse_iso(value, offset_minutes):
    text = str(value).strip()

    if len(text) < 16:
        return None

    digits = text[0:4] + text[5:7] + text[8:10] + text[11:13] + text[14:16]
    for ch in digits.elems():
        if ch < "0" or ch > "9":
            return None
    y = int(text[0:4])
    mo = int(text[5:7])
    d = int(text[8:10])
    hh = int(text[11:13])
    mm = int(text[14:16])

    if y < 1970 or mo < 1 or mo > 12 or d < 1 or hh > 23 or mm > 59:
        return None
    leap = y % 400 == 0 or (y % 4 == 0 and y % 100 != 0)
    month_days = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if d > month_days[mo - 1]:
        return None

    mins = days_from_civil(y, mo, d) * 1440
    mins += hh * 60 + mm

    if not (text.endswith("Z") or text.endswith("+00:00")):
        return None
    return mins + offset_minutes


def date_text(mins):
    if mins == None:
        return "DATE TBD"

    day = mins // 1440
    parts = civil_from_days(day)

    return MONTHS[parts[1] - 1] + " " + str(parts[2])


def time_text(mins):
    if mins == None:
        return "TIME TBD"

    tod = mins % 1440
    hour = tod // 60
    minute = tod % 60

    suffix = "P" if hour >= 12 else "A"

    hour = hour % 12
    if hour == 0:
        hour = 12

    minute_text = str(minute)
    if minute < 10:
        minute_text = "0" + minute_text

    return str(hour) + ":" + minute_text + suffix


# Simple timezone support for Version 1.
#
# These are September offsets, which is fine for our first proof-of-concept.
# Once everything works, we'll copy the full DST-aware timezone system from
# the NWSL app.

TZ = {
    "America/Los_Angeles": -420,
    "America/Denver": -360,
    "America/Chicago": -300,
    "America/New_York": -240,
    "UTC": 0,
    "Europe/Berlin": 120,
}


def zone_offset(ctx):
    zone = str(ctx.inputs.get("timezone", "America/Los_Angeles"))
    return TZ.get(zone, 0)


# ------------------------------------------------------------
# ESPN match data
# ------------------------------------------------------------

def score_value(competitor):
    raw = get(competitor, "score", None)
    if type(raw) == "dict":
        raw = get(raw, "displayValue", get(raw, "value", None))
    value = signed_stat_number(raw)
    return value if value != None and value >= 0 else "-"


def espn_team_id(team):
    response = http.get(BASE + "site/v2/sports/soccer/ger.1/teams", ttl_seconds=86400)
    if get(response, "status_code", 0) != 200:
        return None
    sports = list_value(get(get(response, "json", {}), "sports", []))
    if len(sports) == 0:
        return None
    leagues = list_value(get(sports[0], "leagues", []))
    if len(leagues) == 0:
        return None
    for item in list_value(get(leagues[0], "teams", [])):
        info = get(item, "team", {})
        if internal_team_from_info(info) == team:
            return str(get(info, "id", ""))
    return None


def parse_competition(comp, ctx):
    home = None
    away = None
    for competitor in list_value(get(comp, "competitors", [])):
        side = {
            "abbr": internal_team_from_info(get(competitor, "team", {})),
            "score": score_value(competitor),
        }
        location = get(competitor, "homeAway", "")
        if location == "home":
            home = side
        elif location == "away":
            away = side
    if home == None or away == None:
        return None
    return {"home": home, "away": away,
            "start": parse_iso(get(comp, "date", ""), zone_offset(ctx))}


def read_schedule_events(ctx, fixtures=False):
    team_id = espn_team_id(team_selected(ctx))
    if team_id == None or team_id == "":
        return None
    url = BASE + "site/v2/sports/soccer/ger.1/teams/" + team_id + "/schedule"
    if fixtures:
        url += "?fixture=true"
    response = http.get(url, ttl_seconds=300)
    if get(response, "status_code", 0) != 200:
        return None
    return read_match_events(get(response, "json", {}), ctx, fixtures)


def read_live_events(ctx):
    today = civil_from_days(ctx.now.unix // 86400)
    date_key = str(today[0]) + ("0" + str(today[1]))[-2:] + ("0" + str(today[2]))[-2:]
    response = http.get(SCORES + "?dates=" + date_key, ttl_seconds=30)
    if get(response, "status_code", 0) != 200:
        return None
    return read_match_events(get(response, "json", {}), ctx)


def find_next_match(ctx, team):
    events = read_schedule_events(ctx, fixtures=True)
    if events == None:
        return None
    return upcoming_match(events, team)


def read_events(ctx):
    return read_schedule_events(ctx)


def previous_match(events, team):
    best = None

    for event in events:
        involved = (
            event["home"]["abbr"] == team or
            event["away"]["abbr"] == team
        )

        if not involved:
            continue

        if event["state"] != "post":
            continue

        if best == None or event["start"] > best["start"]:
            best = event

    return best


def upcoming_match(events, team):
    best = None

    for event in events:
        involved = (
            event["home"]["abbr"] == team or
            event["away"]["abbr"] == team
        )

        if not involved:
            continue

        if event["state"] != "pre":
            continue

        if best == None or event["start"] < best["start"]:
            best = event

    return best

def live_match_for(events, team):
    for event in events:
        involved = (
            event["home"]["abbr"] == team or
            event["away"]["abbr"] == team
        )

        if involved and event["state"] == "in":
            return event

    return None

# ------------------------------------------------------------
# ESPN standings
# ------------------------------------------------------------

def read_table():
    response = http.get(TABLE, ttl_seconds=1800)
    if get(response, "status_code", 0) != 200 or get(response, "json", None) == None:
        return None
    node = response["json"]
    if type(node) == "list":
        node = node[0] if len(node) > 0 else {}
    children = list_value(get(node, "children", []))
    nodes = children if len(children) > 0 else [node]
    rows = []
    for group in nodes:
        for entry in list_value(dig(group, ["standings", "entries"], [])):
            stats = list_value(get(entry, "stats", []))
            def stat_text(names):
                value = named_standing_number(stats, names)
                return value if value != None else "--"
            rank = named_standing_number(stats, ["rank"])
            rows.append({
                "abbr": internal_team_from_info(get(entry, "team", {})),
                "name": str(dig(entry, ["team", "displayName"], "")).upper(),
                "rank": rank if rank != None and rank > 0 else len(rows) + 1,
                "points": stat_text(["points"]),
                "wins": stat_text(["wins"]),
                "draws": stat_text(["ties", "draws"]),
                "losses": stat_text(["losses"]),
                "gd": goal_difference_text(standing_goal_difference(stats)),
            })
    return rows

# ------------------------------------------------------------
# TITLE PAGE
# ------------------------------------------------------------

def title(c, ctx):
    c.fill("black")

    team = team_selected(ctx)
    accent = team_color(team)

    # Opening rail.
    draw_team_rail(c, team)

    # Bundesliga logo on the left.
    c.image("BUNDESLIGA.png", 4, 2)

    # Tracked team crest on the right.
    crest = team_crest(team)
    if crest != "":
        c.image(crest.replace("22.png", "28.png"), 96, 2)

    # Smaller title text in the middle.
    c.text(
        "BUNDESLIGA",
        35,
        7,
        font = "5x7",
        color = "white"
    )

    c.text(
        "TRACKED TEAM",
        36,
        18,
        font = "4x5",
        color = accent
    )

# ------------------------------------------------------------
# LIVE MATCH
# ------------------------------------------------------------

def live_match(c, ctx):
    c.fill("black")

    team = team_selected(ctx)
    accent = team_color(team)
    draw_team_rail(c, team)

    events = read_live_events(ctx)

    if events == None:
        c.text_center("DATA OFFLINE", 13, font = "5x7", color = "red")
        return

    match = live_match_for(events, team)

    if match == None:
        c.text("LIVE", 6, 1, font = "4x5", color = accent)
        c.text(
            display_team(team),
            121,
            1,
            font = "4x5",
            color = accent,
            align = "right"
        )
        c.text_center(
            "NO LIVE MATCH",
            13,
            font = "5x7",
            color = DIM
        )
        return

    home = match["home"]
    away = match["away"]
    opponent = opponent_of(match, team)

    if home["abbr"] == team:
        team_score = home["score"]
        opponent_score = away["score"]
    else:
        team_score = away["score"]
        opponent_score = home["score"]

    crest = team_crest(team)
    if crest != "":
        c.image(crest, 4, 8)

    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 102, 8)

    c.text("LIVE", 5, 1, font = "4x5", color = "green")

    c.text(
        display_team(team),
        31,
        10,
        font = "5x7",
        color = team_color(team)
    )

    score = str(team_score) + "-" + str(opponent_score)

    c.text(
        score,
        66,
        9,
        font = "6x8",
        color = TEXT,
        align = "center"
    )

    c.text(
        display_team(opponent["abbr"]),
        98,
        10,
        font = "5x7",
        color = team_color(opponent["abbr"]),
        align = "right"
    )

    c.text(
        live_minute(match),
        66,
        22,
        font = "4x5",
        color = "green",
        align = "center"
    )

# ------------------------------------------------------------
# PAGE 1 — LAST MATCH
# ------------------------------------------------------------

def last_match(c, ctx):
    c.fill("black")

    team = team_selected(ctx)
    accent = team_color(team)
    draw_team_rail(c, team)

    events = read_events(ctx)

    if events == None:
        c.text_center("DATA OFFLINE", 13, font = "5x7", color = "red")
        return

    match = previous_match(events, team)

    if match == None:
        c.text_center("NO RECENT MATCH", 13, font = "5x7", color = DIM)
        return

    home = match["home"]
    away = match["away"]
    opponent = opponent_of(match, team)

    # Work out the score from the tracked team's point of view.
    if home["abbr"] == team:
        team_score = home["score"]
        opponent_score = away["score"]
    else:
        team_score = away["score"]
        opponent_score = home["score"]

    # Tracked team crest on the left.
    crest = team_crest(team)
    if crest != "":
        c.image(crest, 4, 8)

    # Opponent crest on the far right.
    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 102, 8)

    # Header.
    c.text("LAST", 5, 1, font = "4x5", color = accent)

    c.text(
        display_team(team),
        121,
        1,
        font = "4x5",
        color = team_color(team),
        align = "right"
)

    # Tracked team abbreviation.
    c.text(
        display_team(team),
        31,
        10,
        font = "5x7",
        color = team_color(team)
    )

    # Score.
    score = str(team_score) + "-" + str(opponent_score)

    c.text(
        score,
        66,
        9,
        font = "6x8",
        color = TEXT,
        align = "center"
    )

    # Opponent abbreviation, tucked just to the left of its crest.
    c.text(
        display_team(opponent["abbr"]),
        98,
        10,
        font = "5x7",
        color = team_color(opponent["abbr"]),
        align = "right"
    )

    # Match status.
    c.text(
        "FINAL",
        66,
        22,
        font = "4x5",
        color = DIM,
        align = "center"
    )


# ------------------------------------------------------------
# PAGE 2 — NEXT MATCH
# ------------------------------------------------------------

def next_match(c, ctx):
    c.fill("black")

    team = team_selected(ctx)
    accent = team_color(team)
    draw_team_rail(c, team)

    crest = team_crest(team)
    if crest != "":
        c.image(crest, 4, 8)

    events = read_schedule_events(ctx, fixtures=True)
    match = upcoming_match(events, team) if events != None else None

    if match == None:
        c.text_center("DATA OFFLINE" if events == None else "NO MATCH FOUND", 13, font = "5x7", color = DIM)
        return

    home = match["home"]
    away = match["away"]
    opponent = opponent_of(match, team)

    # Opponent crest on the right.
    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 102, 8)

    # Header.
    c.text("NEXT", 5, 1, font = "4x5", color = accent)

    # Keep the tracked club visible in the upper-right.
    c.text(
        display_team(team),
        121,
        1,
        font = "4x5",
        color = team_color(team),
        align = "right"
    )

    # Home/away label and opponent.
    if home["abbr"] == team:
        prefix = "VS"
    else:
        prefix = "@"

    c.text(
        prefix,
        45,
        10,
        font = "4x7",
        color = DIM
    )

    c.text(
        display_team(opponent["abbr"]),
        59,
        9,
        font = "6x8",
        color = team_color(opponent["abbr"])
    )

    # Date and kickoff time.
    when = date_text(match["start"]) + "  " + time_text(match["start"])

    c.text(
        when,
        37,
        22,
        font = "4x5",
        color = accent
    )


# ------------------------------------------------------------
# PAGE 3 — STANDING
# ------------------------------------------------------------

def standing(c, ctx):
    c.fill("black")

    team = team_selected(ctx)
    accent = team_color(team)
    draw_team_rail(c, team)
    draw_end_rail(c, team)

    crest = team_crest(team)
    if crest != "":
        c.image(crest, 9, 6)

    crest = team_crest(team)
    if crest != "":
        c.image(crest, 97, 6)

    rows = read_table()

    c.text("TABLE", 3, 1, font = "4x5", color = accent)
    c.text(display_team(team), 121, 1, font = "4x5",
       color = team_color(team), align = "right")

    if rows == None:
        c.text_center("DATA OFFLINE", 13, font = "5x7", color = "red")
        return

    club = None
    position = 0

    for i in range(len(rows)):
        if rows[i]["abbr"] == team:
            club = rows[i]
            position = rows[i]["rank"]
            break

    if club == None:
        c.text_center("TEAM NOT FOUND", 13, font = "5x7", color = "red")
        return

    place = ordinal(position)

    record = (
        str(club["wins"]) + "-" +
        str(club["draws"]) + "-" +
        str(club["losses"]) + " " +
        "GD" + str(club["gd"])
    )

    points = str(club["points"]) + " PTS"

    c.text_center(place, 5, font = "6x8", color = TEXT)
    c.text_center(record, 16, font = "4x5", color = accent)
    c.text_center(points, 24, font = "4x5", color = TEXT)