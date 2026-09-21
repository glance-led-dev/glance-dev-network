# Serie A Tracked Team
#
# Version 1:
# - Last completed Serie A match
# - Next scheduled Serie A match
# - Current Serie A standing
#
# Data source: ESPN public soccer API

BASE = "https://site.api.espn.com/apis/"
SCORES = BASE + "site/v2/sports/soccer/ita.1/scoreboard"
TABLE = BASE + "v2/sports/soccer/ita.1/standings"

ACCENT = "#00AEEF"
TEXT = "white"
DIM = "gray"
TEAMS = {
    "ROM": {
        "display": "ROM",
        "espn_name": "AS Roma",
        "name": "ROMA",
        "color": "#8E1F2D",
        "crest": "italy_roma_64x64.football-logos.cc.png",
    },
    "ACM": {
        "display": "ACM",
        "espn_name": "AC Milan",
        "name": "MILAN",
        "color": "#FB090B",
        "crest": "italy_milan_64x64.football-logos.cc.png",
    },
    "INT": {
        "display": "INT",
        "espn_name": "Inter Milano",
        "name": "INTER",
        "color": "#0068A8",
        "crest": "italy_inter_64x64.football-logos.cc.png",
    },
    "JUV": {
        "display": "JUV",
        "espn_name": "Juventus Turin",
        "name": "JUVENTUS",
        "color": "#FFFFFF",
        "crest": "italy_juventus--white_64x64.football-logos.cc.png",
    },
    "NAP": {
        "display": "NAP",
        "espn_name": "SSC Napoli",
        "name": "NAPOLI",
        "color": "#12A0D7",
        "crest": "italy_napoli_64x64.football-logos.cc.png",
    },
    "ATA": {
        "display": "ATA",
        "espn_name": "Atalanta BC",
        "name": "ATALANTA",
        "color": "#1E71B8",
        "crest": "italy_atalanta_64x64.football-logos.cc.png",
    },
    "BFC": {
        "display": "BOL",
        "espn_name": "Bologna FC",
        "name": "BOLOGNA",
        "color": "#1A2F5B",
        "crest": "italy_bologna_64x64.football-logos.cc.png",
    },
    "CAG": {
        "display": "CAG",
        "espn_name": "Cagliari Calcio",
        "name": "CAGLIARI",
        "color": "#1B3768",
        "crest": "italy_cagliari_64x64.football-logos.cc.png",
    },
    "COM": {
        "display": "COM",
        "espn_name": "Como 1907",
        "name": "COMO",
        "color": "#005BAC",
        "crest": "italy_como-1907_64x64.football-logos.cc.png",
    },
    "FIO": {
        "display": "FIO",
        "espn_name": "ACF Fiorentina",
        "name": "FIORENTINA",
        "color": "#5B2C83",
        "crest": "italy_fiorentina_64x64.football-logos.cc.png",
    },
    "FRO": {
        "display": "FRO",
        "espn_name": "Frosinone Calcio",
        "name": "FROSINONE",
        "color": "#F2D61F",
        "crest": "italy_frosinone_64x64.football-logos.cc.png",
    },
    "GEN": {
        "display": "GEN",
        "espn_name": "Genoa CFC",
        "name": "GENOA",
        "color": "#C8102E",
        "crest": "italy_genoa_64x64.football-logos.cc.png",
    },
    "LAZ": {
        "display": "LAZ",
        "espn_name": "Lazio Rome",
        "name": "LAZIO",
        "color": "#87CEEB",
        "crest": "italy_lazio_64x64.football-logos.cc.png",
    },
    "LEC": {
        "display": "LEC",
        "espn_name": "US Lecce",
        "name": "LECCE",
        "color": "#F4D03F",
        "crest": "italy_lecce_64x64.football-logos.cc.png",
    },
    "MON": {
        "display": "MON",
        "espn_name": "AC Monza",
        "name": "MONZA",
        "color": "#E30613",
        "crest": "italy_monza_64x64.football-logos.cc.png",
    },
    "PAR": {
        "display": "PAR",
        "espn_name": "Parma Calcio",
        "name": "PARMA",
        "color": "#F4C430",
        "crest": "italy_parma_64x64.football-logos.cc.png",
    },
    "SAS": {
        "display": "SAS",
        "espn_name": "Sassuolo Calcio",
        "name": "SASSUOLO",
        "color": "#1FA12E",
        "crest": "italy_sassuolo_64x64.football-logos.cc.png",
    },
    "TOR": {
        "display": "TOR",
        "espn_name": "Torino FC",
        "name": "TORINO",
        "color": "#7A263A",
        "crest": "italy_torino_64x64.football-logos.cc.png",
    },
    "UDI": {
        "display": "UDI",
        "espn_name": "Udinese Calcio",
        "name": "UDINESE",
        "color": "#FFFFFF",
        "crest": "italy_udinese_64x64.football-logos.cc.png",
    },
    "VEN": {
        "display": "VEN",
        "espn_name": "Venezia FC",
        "name": "VENEZIA",
        "color": "#F58220",
        "crest": "italy_venezia_64x64.football-logos.cc.png",
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
    return str(ctx.inputs.get("team", "ROM")).strip().upper()

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

def internal_team_from_info(info):
    display_name = str(get(info, "displayName", "")).strip().lower()
    abbr = str(get(info, "abbreviation", "?")).upper()

    # Endpoint-specific ESPN aliases.
    aliases = {
        "BFC": {
            "names": ["bologna fc", "bologna"],
            "abbrs": ["BFC", "BOL"],
        },
        "COM": {
            "names": ["como 1907", "como"],
            "abbrs": ["COM", "COMO"],
        },
    }

    for key in aliases:
        alias = aliases[key]

        if display_name in alias["names"]:
            return key

        if abbr in alias["abbrs"]:
            return key

    for key in TEAMS:
        team_name = str(TEAMS[key].get("espn_name", "")).strip().lower()
        if team_name != "" and team_name == display_name:
            return key

    # Fallback to abbreviation if ESPN ever returns one matching our key.
    if abbr in TEAMS:
        return abbr

    return abbr


def espn_name(team):
    info = team_info(team)
    if "espn_name" in info:
        return info["espn_name"]
    return info["name"]


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
    "Europe/Rome": 120,
}


def zone_offset(ctx):
    zone = str(ctx.inputs.get("timezone", "America/Los_Angeles"))
    return TZ.get(zone, 0)


# ------------------------------------------------------------
# ESPN match data
# ------------------------------------------------------------

def score_value(competitor):
    raw = get(competitor, "score", 0)

    if type(raw) == "dict":
        display = get(raw, "displayValue", None)
        if display != None:
            return num(display, 0)

        value = get(raw, "value", None)
        if value != None:
            return num(value, 0)

        return 0

    return num(raw, 0)


def espn_team_id(team):
    target_name = str(espn_name(team)).strip().lower()

    url = BASE + "site/v2/sports/soccer/ita.1/teams"
    response = http.get(url, ttl_seconds = 86400)

    if response["status_code"] != 200 or response["json"] == None:
        return None

    sports = get(response["json"], "sports", [])
    if type(sports) != "list" or len(sports) == 0:
        return None

    leagues = get(sports[0], "leagues", [])
    if type(leagues) != "list" or len(leagues) == 0:
        return None

    for item in get(leagues[0], "teams", []):
        info = get(item, "team", {})
        display_name = str(get(info, "displayName", "")).strip().lower()

        if display_name == target_name:
            return str(get(info, "id", ""))

    return None


def parse_competition(comp, ctx):
    home = None
    away = None

    for competitor in get(comp, "competitors", []):
        team_obj = get(competitor, "team", {})

        side = {
            "abbr": internal_team_from_info(team_obj),
            "score": score_value(competitor),
        }

        if str(get(competitor, "homeAway", "")) == "home":
            home = side
        else:
            away = side

    if home == None or away == None:
        return None

    return {
        "home": home,
        "away": away,
        "start": parse_iso(
            str(get(comp, "date", "")),
            zone_offset(ctx),
        ),
    }


def read_schedule_events(ctx):
    team = team_selected(ctx)
    team_id = espn_team_id(team)

    if team_id == None or team_id == "":
        return None

    url = (
        BASE +
        "site/v2/sports/soccer/ita.1/teams/" +
        team_id +
        "/schedule?fixture=true"
    )

    response = http.get(url, ttl_seconds = 60)

    if response["status_code"] != 200 or response["json"] == None:
        return None

    events = []
    now_local = (ctx.now.unix // 60) + zone_offset(ctx)

    for event in get(response["json"], "events", []):
        comps = get(event, "competitions", [])

        if type(comps) != "list" or len(comps) == 0:
            continue

        comp = comps[0]
        parsed = parse_competition(comp, ctx)

        if parsed == None:
            continue

        if parsed["start"] == None:
            parsed["start"] = parse_iso(
                str(get(event, "date", "")),
                zone_offset(ctx),
            )

        if parsed["start"] == None:
            continue

        if parsed["start"] < now_local - 180:
            parsed["state"] = "post"
        elif parsed["start"] > now_local:
            parsed["state"] = "pre"
        else:
            parsed["state"] = "near"

        parsed["clock"] = ""
        events.append(parsed)

    return events


def read_live_events(ctx):
    now_days = ctx.now.unix // 86400
    today = civil_from_days(now_days)

    def pad2(n):
        return ("0" + str(n)) if n < 10 else str(n)

    today_key = (
        str(today[0]) +
        pad2(today[1]) +
        pad2(today[2])
    )

    response = http.get(
        SCORES + "?dates=" + today_key,
        ttl_seconds = 30
    )

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
            team_obj = get(competitor, "team", {})

            side = {
                "abbr": internal_team_from_info(team_obj),
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


def find_previous_match(ctx, team):
    now_days = ctx.now.unix // 86400

    def pad2(n):
        return ("0" + str(n)) if n < 10 else str(n)

    # Scan backward one day at a time. Seven requests keeps us under
    # Glance's 8-request-per-render cap and covers a normal Serie A week.
    for offset in range(0, 7):
        parts = civil_from_days(now_days - offset)

        date_key = (
            str(parts[0]) +
            pad2(parts[1]) +
            pad2(parts[2])
        )

        response = http.get(
            SCORES + "?dates=" + date_key,
            ttl_seconds = 300
        )

        if response["status_code"] != 200 or response["json"] == None:
            continue

        for event in get(response["json"], "events", []):
            comps = get(event, "competitions", [])

            if type(comps) != "list" or len(comps) == 0:
                continue

            comp = comps[0]

            home = None
            away = None

            for competitor in get(comp, "competitors", []):
                team_obj = get(competitor, "team", {})

                side = {
                    "abbr": internal_team_from_info(team_obj),
                    "score": num(get(competitor, "score", 0)),
                }

                if str(get(competitor, "homeAway", "")) == "home":
                    home = side
                else:
                    away = side

            if home == None or away == None:
                continue

            if not (
                home["abbr"] == team or
                away["abbr"] == team
            ):
                continue

            state = str(
                dig(event, ["status", "type", "state"], "")
            ).lower()

            if state != "post":
                continue

            return {
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
            }

    return None


def find_next_match(ctx, team):
    now_days = ctx.now.unix // 86400

    def pad2(n):
        return ("0" + str(n)) if n < 10 else str(n)

    # Glance allows at most 8 uncached HTTP requests per render.
    # Search 7 weekly windows = up to 49 days ahead,
    # using only 7 HTTP requests maximum.
    for week in range(0, 7):
        start_offset = week * 7
        end_offset = start_offset + 6

        start_parts = civil_from_days(
            now_days + start_offset
        )
        end_parts = civil_from_days(
            now_days + end_offset
        )

        start_key = (
            str(start_parts[0]) +
            pad2(start_parts[1]) +
            pad2(start_parts[2])
        )

        end_key = (
            str(end_parts[0]) +
            pad2(end_parts[1]) +
            pad2(end_parts[2])
        )

        date_range = start_key + "-" + end_key

        response = http.get(
            SCORES + "?dates=" + date_range,
            ttl_seconds = 300
        )

        if (
            response["status_code"] != 200 or
            response["json"] == None
        ):
            continue

        for event in get(
            response["json"],
            "events",
            []
        ):
            comps = get(
                event,
                "competitions",
                []
            )

            if (
                type(comps) != "list" or
                len(comps) == 0
            ):
                continue

            comp = comps[0]

            home = None
            away = None

            for competitor in get(
                comp,
                "competitors",
                []
            ):
                team_obj = get(
                    competitor,
                    "team",
                    {}
                )

                side = {
                    "abbr": internal_team_from_info(
                        team_obj
                    ),
                    "score": num(
                        get(
                            competitor,
                            "score",
                            0
                        )
                    ),
                }

                if str(
                    get(
                        competitor,
                        "homeAway",
                        ""
                    )
                ) == "home":
                    home = side
                else:
                    away = side

            if home == None or away == None:
                continue

            if not (
                home["abbr"] == team or
                away["abbr"] == team
            ):
                continue

            state = str(
                dig(
                    event,
                    [
                        "status",
                        "type",
                        "state",
                    ],
                    "",
                )
            ).lower()

            if state != "pre":
                continue

            return {
                "home": home,
                "away": away,
                "state": state,
                "clock": str(
                    dig(
                        event,
                        [
                            "status",
                            "type",
                            "detail",
                        ],
                        "",
                    )
                ).upper(),
                "start": parse_iso(
                    str(
                        get(
                            event,
                            "date",
                            "",
                        )
                    ),
                    zone_offset(ctx),
                ),
            }

    return None

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
    response = http.get(TABLE, ttl_seconds = 1800)

    if response["status_code"] != 200 or response["json"] == None:
        return None

    node = response["json"]

    if type(node) == "list":
        if len(node) == 0:
            return []
        node = node[0]

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
            "abbr": internal_team_from_info(
                get(entry, "team", {})
            ),

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

    # Serie A logo on the left.
    c.image("SERIEA.png", 4, 1, 30, 30)

    # Tracked team crest on the right.
    crest = team_crest(team)
    if crest != "":
        c.image(crest, 96, 2, 28, 28)

    # Smaller title text in the middle.
    c.text(
        "TRACKED",
        43,
        7,
        font = "5x7",
        color = "white"
    )

    c.text(
        "TEAM",
        53,
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
        c.text("LIVE", 6, 1, font = "3x4", color = accent)
      
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
        c.image(crest, 4, 6, 25, 25)

    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 101, 6, 25, 25)

    c.text("LIVE", 5, 1, font = "4x5", color = "green")

    c.text(
        display_team(team),
        31,
        12,
        font = "5x7",
        color = team_color(team)
    )

    score = str(team_score) + "-" + str(opponent_score)

    c.text(
        score,
        66,
        11,
        font = "6x8",
        color = TEXT,
        align = "center"
    )

    c.text(
        display_team(opponent["abbr"]),
        98,
        12,
        font = "5x7",
        color = team_color(opponent["abbr"]),
        align = "right"
    )

    c.text(
        live_minute(match),
        66,
        24,
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

    match = find_previous_match(ctx, team)

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
        c.image(crest, 4, 6, 25, 25)

    # Opponent crest on the far right.
    opponent_crest = team_crest(opponent["abbr"])
    if opponent_crest != "":
        c.image(opponent_crest, 101, 6, 25, 25)

    # Header.
    c.text("LAST", 5, 1, font = "3x4", color = accent)


    # Tracked team abbreviation.
    c.text(
        display_team(team),
        31,
        12,
        font = "5x7",
        color = team_color(team)
    )

    # Score.
    score = str(team_score) + "-" + str(opponent_score)

    c.text(
        score,
        66,
        11,
        font = "6x8",
        color = TEXT,
        align = "center"
    )

    # Opponent abbreviation, tucked just to the left of its crest.
    c.text(
        display_team(opponent["abbr"]),
        98,
        12,
        font = "5x7",
        color = team_color(opponent["abbr"]),
        align = "right"
    )

    # Match status.
    c.text(
        "FINAL",
        66,
        24,
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
        c.image(
            crest,
            4,
            6,
            25,
            25
        )

    # Pull the selected team's full Serie A schedule
    # and choose the nearest upcoming fixture.
    events = read_schedule_events(ctx)

    if events == None:
        match = None
    else:
        match = upcoming_match(
            events,
            team
        )

    if match == None:
        c.text(
            "NO MATCH FOUND",
            76,
            13,
            font = "5x7",
            color = DIM,
            align = "center"
        )
        return

    home = match["home"]
    away = match["away"]
    opponent = opponent_of(
        match,
        team
    )

    # Opponent crest on the right.
    opponent_crest = team_crest(
        opponent["abbr"]
    )

    if opponent_crest != "":
        c.image(
            opponent_crest,
            101,
            6,
            25,
            25
        )

    # Header.
    c.text(
        "NEXT",
        5,
        1,
        font = "3x4",
        color = accent
    )

    # Home / away indicator.
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

    # Opponent name.
    c.text(
        display_team(
            opponent["abbr"]
        ),
        59,
        9,
        font = "6x8",
        color = team_color(
            opponent["abbr"]
        )
    )

    # Date and kickoff time.
    when = (
        date_text(match["start"])
        + "  "
        + time_text(match["start"])
    )

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

    c.text("TABLE", 3, 1, font = "3x4", color = accent)

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
