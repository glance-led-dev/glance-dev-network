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

    if detail.find("HALFTIME") >= 0 or detail == "HT":
        return "HT"

    digits = ""

    for ch in detail.elems():
        if ch >= "0" and ch <= "9":
            digits += ch
        elif digits != "":
            break

    if digits != "":
        return digits + "'"

    return "LIVE"

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

    y = num(text[0:4], -1)
    mo = num(text[5:7], -1)
    d = num(text[8:10], -1)
    hh = num(text[11:13], -1)
    mm = num(text[14:16], -1)

    if y < 1970 or mo < 1 or d < 1 or hh < 0 or mm < 0:
        return None

    mins = days_from_civil(y, mo, d) * 1440
    mins += hh * 60 + mm

    if text.endswith("Z"):
        mins += offset_minutes

    return mins


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

def read_events(ctx):
    #
    # ESPN accepts a date range on the scoreboard endpoint.
    # We ask for a broad range surrounding now so we can find
    # both the previous and upcoming match.
    #

    now_days = ctx.now.unix // 86400

    past = civil_from_days(now_days - 21)
    future = civil_from_days(now_days + 35)

    def pad2(n):
        return ("0" + str(n)) if n < 10 else str(n)


    start = (
        str(past[0]) +
        pad2(past[1]) +
        pad2(past[2])
    )

    end = (
        str(future[0]) +
        pad2(future[1]) +
        pad2(future[2])
    )

    url = SCORES + "?dates=" + start + "-" + end

    response = http.get(url, ttl_seconds = 60)

    if response["status_code"] != 200 or response["json"] == None:
        return None

    events = []

    for event in get(response["json"], "events", []):
        comps = get(event, "competitions", [])

        if type(comps) != "list" or len(comps) == 0:
            continue

        comp = comps[0]

        home = None
        away = None

        for competitor in get(comp, "competitors", []):
            side = {
                "abbr": str(
                    dig(competitor, ["team", "abbreviation"], "?")
                ).upper(),
                "score": num(get(competitor, "score", 0)),
            }

            if str(get(competitor, "homeAway", "")) == "home":
                home = side
            else:
                away = side

        if home == None or away == None:
            continue

        state = str(
            dig(event, ["status", "type", "state"], "")
        ).lower()

        events.append({
            "home": home,
            "away": away,
            "state": state,
            "clock": str(
                dig(event, ["status", "type", "detail"], "")
            ).upper(),
            "start": parse_iso(
                str(get(event, "date", "")),
                zone_offset(ctx),
            ),
        })

    return events


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
    response = http.get(TABLE, ttl_seconds = 1800)

    if response["status_code"] != 200 or response["json"] == None:
        return None

    node = response["json"]

    children = get(node, "children", [])

    if type(children) == "list" and len(children) > 0:
        node = children[0]

    rows = []

    for entry in dig(node, ["standings", "entries"], []):
        stats = {}

        for stat in get(entry, "stats", []):
            stats[str(get(stat, "name", ""))] = str(
                get(stat, "displayValue", "")
            )

        rows.append({
            "abbr": str(
                dig(entry, ["team", "abbreviation"], "?")
            ).upper(),

            "name": str(
                dig(entry, ["team", "displayName"], "")
            ).upper(),

            "points": num(stats.get("points", "0")),
            "wins": num(stats.get("wins", "0")),
            "draws": num(stats.get("ties", "0")),
            "losses": num(stats.get("losses", "0")),
            "gd": stats.get("pointDifferential", "0"),
        })

    rows = sorted(rows, key = lambda row: -row["points"])

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
    c.image("BUNDESLIGA.png", 5, 6, 22, 22)

    # Tracked team crest on the right.
    crest = team_crest(team)
    if crest != "":
        c.image(crest, 101, 4, 22, 22)

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

    events = read_events(ctx)

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
        c.image(crest, 4, 8, 22, 22)

    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 103, 8, 22, 22)

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
        c.image(crest, 4, 8, 22, 22)

    # Opponent crest on the far right.
    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 103, 8, 22, 22)

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
        c.image(crest, 4, 8, 22, 22)

    events = read_events(ctx)

    if events == None:
        c.text_center("DATA OFFLINE", 13, font = "5x7", color = "red")
        return

    match = upcoming_match(events, team)

    if match == None:
        c.text_center("NO MATCH FOUND", 13, font = "5x7", color = DIM)
        return

    home = match["home"]
    away = match["away"]
    opponent = opponent_of(match, team)

    # Opponent crest on the right.
    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 103, 8, 22, 22)

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
        c.image(crest, 12, 8, 19, 19)

    crest = team_crest(team)
    if crest != "":
        c.image(crest, 95, 8, 19, 19)

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
            position = i + 1
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