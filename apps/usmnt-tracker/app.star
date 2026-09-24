# National Team Tracker
# 128x32 Glance app

RECENT_MATCH_DAYS = 90
TEAM_SCHEDULE_URL = "https://site.api.espn.com/apis/site/v2/sports/soccer/all/teams/"

ALL_SOCCER_SCOREBOARD_URL = (
    "https://site.api.espn.com/apis/site/v2/sports/soccer/all/scoreboard"
)

ALL_SOCCER_SUMMARY_URL = (
    "https://site.api.espn.com/apis/site/v2/sports/soccer/all/summary"
)

WHITE = "white"
BLACK = "black"
DIM = "gray"

DEFAULT_TEAM = "USA"

# ESPN men's national team IDs, each with its shield badge. accent is
# the heading color, picked to stay readable on the black panel.
TEAMS = {
    "USA": {"id": "660", "badge": "assets/USA.png", "name": "United States", "accent": "#d42339"},
    "MEX": {"id": "203", "badge": "assets/MEX.png", "name": "Mexico", "accent": "#22b573"},
    "CAN": {"id": "206", "badge": "assets/CAN.png", "name": "Canada", "accent": "#ed2224"},
    "CRC": {"id": "214", "badge": "assets/CRC.png", "name": "Costa Rica", "accent": "#ce1126"},
    "PAN": {"id": "2659", "badge": "assets/PAN.png", "name": "Panama", "accent": "#d21034"},
    "JAM": {"id": "1038", "badge": "assets/JAM.png", "name": "Jamaica", "accent": "#348b42"},
    "HAI": {"id": "2654", "badge": "assets/HAI.png", "name": "Haiti", "accent": "#3d6fe8"},
    "CUW": {"id": "11678", "badge": "assets/CUW.png", "name": "Curacao", "accent": "#3d6fe8"},
    "ARG": {"id": "202", "badge": "assets/ARG.png", "name": "Argentina", "accent": "#74acdf"},
    "BRA": {"id": "205", "badge": "assets/BRA.png", "name": "Brazil", "accent": "#fee000"},
    "URU": {"id": "212", "badge": "assets/URU.png", "name": "Uruguay", "accent": "#55b5e5"},
    "COL": {"id": "208", "badge": "assets/COL.png", "name": "Colombia", "accent": "#fbd632"},
    "ECU": {"id": "209", "badge": "assets/ECU.png", "name": "Ecuador", "accent": "#ffdd00"},
    "PAR": {"id": "210", "badge": "assets/PAR.png", "name": "Paraguay", "accent": "#ea2300"},
    "PER": {"id": "211", "badge": "assets/PER.png", "name": "Peru", "accent": "#cb292e"},
    "CHI": {"id": "207", "badge": "assets/CHI.png", "name": "Chile", "accent": "#d3362a"},
    "ENG": {"id": "448", "badge": "assets/ENG.png", "name": "England", "accent": "#ea1f29"},
    "FRA": {"id": "478", "badge": "assets/FRA.png", "name": "France", "accent": "#4d6fe8"},
    "ESP": {"id": "164", "badge": "assets/ESP.png", "name": "Spain", "accent": "#c60b1e"},
    "GER": {"id": "481", "badge": "assets/GER.png", "name": "Germany", "accent": "#00ced1"},
    "POR": {"id": "482", "badge": "assets/POR.png", "name": "Portugal", "accent": "#da291c"},
    "NED": {"id": "449", "badge": "assets/NED.png", "name": "Netherlands", "accent": "#fb5d00"},
    "BEL": {"id": "459", "badge": "assets/BEL.png", "name": "Belgium", "accent": "#e30613"},
    "ITA": {"id": "162", "badge": "assets/ITA.png", "name": "Italy", "accent": "#4d6fe8"},
    "CRO": {"id": "477", "badge": "assets/CRO.png", "name": "Croatia", "accent": "#ff0000"},
    "SUI": {"id": "475", "badge": "assets/SUI.png", "name": "Switzerland", "accent": "#ff0000"},
    "AUT": {"id": "474", "badge": "assets/AUT.png", "name": "Austria", "accent": "#d72b2c"},
    "DEN": {"id": "479", "badge": "assets/DEN.png", "name": "Denmark", "accent": "#d02a3e"},
    "SWE": {"id": "466", "badge": "assets/SWE.png", "name": "Sweden", "accent": "#fecb00"},
    "NOR": {"id": "464", "badge": "assets/NOR.png", "name": "Norway", "accent": "#c8102e"},
    "POL": {"id": "471", "badge": "assets/POL.png", "name": "Poland", "accent": "#dc143c"},
    "TUR": {"id": "465", "badge": "assets/TUR.png", "name": "Turkiye", "accent": "#ef3340"},
    "SCO": {"id": "580", "badge": "assets/SCO.png", "name": "Scotland", "accent": "#5577dd"},
    "WAL": {"id": "578", "badge": "assets/WAL.png", "name": "Wales", "accent": "#e70000"},
    "IRL": {"id": "476", "badge": "assets/IRL.png", "name": "Ireland", "accent": "#20b070"},
    "JPN": {"id": "627", "badge": "assets/JPN.png", "name": "Japan", "accent": "#4d6fe8"},
    "KOR": {"id": "451", "badge": "assets/KOR.png", "name": "South Korea", "accent": "#ce2028"},
    "IRN": {"id": "469", "badge": "assets/IRN.png", "name": "Iran", "accent": "#da0000"},
    "AUS": {"id": "628", "badge": "assets/AUS.png", "name": "Australia", "accent": "#ffcd00"},
    "KSA": {"id": "655", "badge": "assets/KSA.png", "name": "Saudi Arabia", "accent": "#2eaa60"},
    "QAT": {"id": "4398", "badge": "assets/QAT.png", "name": "Qatar", "accent": "#c0406f"},
    "JOR": {"id": "2917", "badge": "assets/JOR.png", "name": "Jordan", "accent": "#e70000"},
    "UZB": {"id": "2570", "badge": "assets/UZB.png", "name": "Uzbekistan", "accent": "#3d9be8"},
    "MAR": {"id": "2869", "badge": "assets/MAR.png", "name": "Morocco", "accent": "#df2027"},
    "SEN": {"id": "654", "badge": "assets/SEN.png", "name": "Senegal", "accent": "#20b060"},
    "TUN": {"id": "659", "badge": "assets/TUN.png", "name": "Tunisia", "accent": "#d20300"},
    "EGY": {"id": "2620", "badge": "assets/EGY.png", "name": "Egypt", "accent": "#d20300"},
    "ALG": {"id": "624", "badge": "assets/ALG.png", "name": "Algeria", "accent": "#4f9a44"},
    "GHA": {"id": "4469", "badge": "assets/GHA.png", "name": "Ghana", "accent": "#fbd632"},
    "CIV": {"id": "4789", "badge": "assets/CIV.png", "name": "Ivory Coast", "accent": "#ff8200"},
    "NGA": {"id": "657", "badge": "assets/NGA.png", "name": "Nigeria", "accent": "#20b060"},
    "RSA": {"id": "467", "badge": "assets/RSA.png", "name": "South Africa", "accent": "#ffb81c"},
    "CPV": {"id": "2597", "badge": "assets/CPV.png", "name": "Cape Verde", "accent": "#ef3340"},
    "NZL": {"id": "2666", "badge": "assets/NZL.png", "name": "New Zealand", "accent": "#ffffff"},
}


def selected_team(ctx):
    code = str(ctx.inputs.get("team", DEFAULT_TEAM)).upper()
    if code not in TEAMS:
        code = DEFAULT_TEAM
    team = dict(TEAMS[code])
    team["code"] = code
    return team


def schedule_url(team):
    return TEAM_SCHEDULE_URL + team["id"] + "/schedule"


NATION_FLAGS = {
    # Add 22x22 or 32x32 PNG flag/crest assets here as desired.
    # Examples:
    # "MEX": "MEX22.png",
    # "CAN": "CAN22.png",
    # "BRA": "BRA22.png",
    # "ARG": "ARG22.png",
}


TEAM_DISPLAY_NAMES = {
    "CRC": "Costa Rica",
    "SLV": "El Salvador",
    "HON": "Honduras",
    "JAM": "Jamaica",
    "TRI": "Trinidad",
    "TTO": "Trinidad",
    "KOR": "S. Korea",
    "KSA": "Saudi Arabia",
    "ENG": "England",
    "NED": "Netherlands",
}


def opponent_crest(opponent):
    abbr = opponent["abbr"]

    if abbr in NATION_FLAGS:
        return NATION_FLAGS[abbr]

    return ""


def display_team_name(opponent):
    abbr = str(get(opponent, "abbr", "")).upper()
    name = TEAM_DISPLAY_NAMES.get(abbr, str(get(opponent, "name", "")))
    if name != "" and len(name) <= 14:
        return name
    short = str(get(opponent, "short_name", ""))
    if short != "" and len(short) <= 14:
        return short
    if abbr != "":
        return abbr[:14]
    return name[:11] + "..." if name != "" else "OPPONENT"


def get(obj, key, fallback=None):
    if type(obj) != "dict":
        return fallback
    value = obj.get(key, fallback)
    return fallback if value == None else value


def pad2(n):
    return ("0" + str(n)) if n < 10 else str(n)


def days_in_month(year, month):
    if month == 2:
        leap = (
            year % 400 == 0
            or (year % 4 == 0 and year % 100 != 0)
        )

        return 29 if leap else 28

    if month in [4, 6, 9, 11]:
        return 30

    return 31


def add_days(year, month, day, count):
    for i in range(count):
        day = day + 1

        if day > days_in_month(year, month):
            day = 1
            month = month + 1

            if month > 12:
                month = 1
                year = year + 1

    return [year, month, day]


def subtract_days(year, month, day, count):
    for i in range(count):
        day = day - 1

        if day < 1:
            month = month - 1

            if month < 1:
                month = 12
                year = year - 1

            day = days_in_month(
                year,
                month,
            )

    return [year, month, day]


def simple_date_text(iso):
    if iso == None or len(iso) < 10:
        return ""

    month_names = {
        "01": "JAN",
        "02": "FEB",
        "03": "MAR",
        "04": "APR",
        "05": "MAY",
        "06": "JUN",
        "07": "JUL",
        "08": "AUG",
        "09": "SEP",
        "10": "OCT",
        "11": "NOV",
        "12": "DEC",
    }

    month = iso[5:7]
    day = iso[8:10]

    if day[0] == "0":
        day = day[1:]

    return month_names.get(month, month) + " " + day


def format_time_12(hour, minute):
    suffix = "AM"

    if hour >= 12:
        suffix = "PM"

    display_hour = hour % 12

    if display_hour == 0:
        display_hour = 12

    return (
        str(display_hour)
        + ":"
        + pad2(minute)
        + " "
        + suffix
    )


def local_match_datetime(iso, offset):
    if iso == None or len(iso) < 16:
        return ["", ""]

    year = int(iso[0:4])
    month = int(iso[5:7])
    day = int(iso[8:10])
    hour = int(iso[11:13])
    minute = int(iso[14:16])

    hour = hour + offset

    if hour < 0:
        hour = hour + 24
        day = day - 1

        if day < 1:
            month = month - 1

            if month < 1:
                month = 12
                year = year - 1

            day = days_in_month(year, month)

    elif hour >= 24:
        hour = hour - 24
        day = day + 1

        if day > days_in_month(year, month):
            day = 1
            month = month + 1

            if month > 12:
                month = 1
                year = year + 1

    months = {
        1: "JAN",
        2: "FEB",
        3: "MAR",
        4: "APR",
        5: "MAY",
        6: "JUN",
        7: "JUL",
        8: "AUG",
        9: "SEP",
        10: "OCT",
        11: "NOV",
        12: "DEC",
    }

    date_text = months[month] + " " + str(day)
    time_text = format_time_12(hour, minute)

    return [date_text, time_text]


def competition_name_from_text(text, fallback=""):
    combined = str(text).lower()

    if "fifa.worldq" in combined or "world_cup_qual" in combined:
        return "WORLD CUP QUAL"

    if (
        "world cup" in combined
        or "fifa.world" in combined
    ):
        if (
            "qualif" in combined
            or "qualification" in combined
            or "world_cup_qual" in combined
        ):
            return "WORLD CUP QUAL"

        return "FIFA WORLD CUP"

    if (
        "nations league" in combined
        or "concacaf.nations.league" in combined
    ):
        return "NATIONS LEAGUE"

    if (
        "gold cup" in combined
        or "concacaf.gold" in combined
    ):
        return "GOLD CUP"

    if (
        "copa america" in combined
        or "conmebol.america" in combined
    ):
        return "COPA AMERICA"

    if (
        "friendly" in combined
        or "international friendly" in combined
    ):
        return "FRIENDLY"

    return fallback

def competition_name_from_event(data, event, fallback=""):
    # ESPN's all-soccer scoreboard does not consistently put league
    # metadata directly on each event. Build a broad metadata string
    # from the event/competition first, then match the event UID against
    # the response-level league list when necessary.
    league = get(event, "league", {})
    competition_list = list_value(get(event, "competitions", []))
    competition = {}

    if len(competition_list) > 0:
        competition = competition_list[0]

    competition_type = get(competition, "type", {})
    season = get(event, "season", {})

    metadata = (
        get(league, "name", "")
        + " "
        + get(league, "slug", "")
        + " "
        + get(league, "abbreviation", "")
        + " "
        + get(event, "name", "")
        + " "
        + get(event, "shortName", "")
        + " "
        + get(competition, "name", "")
        + " "
        + get(competition, "description", "")
        + " "
        + get(competition_type, "text", "")
        + " "
        + get(competition_type, "abbreviation", "")
        + " "
        + get(season, "slug", "")
    )

    detected = competition_name_from_text(
        metadata,
        "",
    )

    if detected != "":
        return detected

    event_uid = get(event, "uid", "")
    leagues = list_value(get(data, "leagues", []))

    for response_league in leagues:
        league_uid = get(response_league, "uid", "")

        if (
            event_uid != ""
            and league_uid != ""
            and league_uid in event_uid
        ):
            league_text = (
                get(response_league, "name", "")
                + " "
                + get(response_league, "slug", "")
                + " "
                + get(response_league, "abbreviation", "")
            )

            detected = competition_name_from_text(
                league_text,
                "",
            )

            if detected != "":
                return detected

            league_name = get(
                response_league,
                "name",
                "",
            )

            if league_name != "":
                return league_name.upper()

    if fallback != "":
        return fallback

    league_name = get(league, "name", "")

    if league_name != "":
        return league_name.upper()

    return "MATCH"


def competition_name_from_summary(data, fallback=""):
    # Match-summary responses normally expose richer league metadata
    # than the broad all-soccer scoreboard. Prefer header.league, then
    # inspect the header competition/season text as a fallback.
    header = get(data, "header", {})
    league = get(header, "league", {})
    competitions = list_value(get(header, "competitions", []))
    competition = {}

    if len(competitions) > 0:
        competition = competitions[0]

    competition_type = get(competition, "type", {})
    season = get(header, "season", {})

    metadata = (
        get(league, "name", "")
        + " "
        + get(league, "slug", "")
        + " "
        + get(league, "abbreviation", "")
        + " "
        + get(header, "name", "")
        + " "
        + get(header, "shortName", "")
        + " "
        + get(competition, "name", "")
        + " "
        + get(competition, "description", "")
        + " "
        + get(competition_type, "text", "")
        + " "
        + get(competition_type, "abbreviation", "")
        + " "
        + get(season, "slug", "")
    )

    detected = competition_name_from_text(
        metadata,
        "",
    )

    if detected != "":
        return detected

    league_name = get(league, "name", "")

    if league_name != "":
        return league_name.upper()

    return fallback


def is_my_team(team):
    # Set by normalize_events from the ESPN ID, which keeps women's and
    # youth sides that share a name from matching.
    return get(team, "mine", False) == True


def normalize_events(data, competition_name, team_id):
    matches = []

    events = list_value(get(data, "events", []))

    for event in events:
        competitions = list_value(get(event, "competitions", []))

        if len(competitions) == 0:
            continue

        competition = competitions[0]
        competitors = list_value(get(competition, "competitors", []))

        home = None
        away = None

        for competitor in competitors:
            side = get(competitor, "homeAway", "")
            team = get(competitor, "team", {})

            normalized = {
                "id": str(get(team, "id", "")),
                "abbr": get(team, "abbreviation", ""),
                "name": get(team, "displayName", ""),
                "short_name": get(team, "shortDisplayName", ""),
                "winner": get(competitor, "winner", None),
                "score": score_text(get(competitor, "score", "")),
                "logo": get(team, "logo", ""),
            }
            normalized["mine"] = normalized["id"] == team_id

            if side == "home":
                home = normalized

            elif side == "away":
                away = normalized

        if home == None or away == None:
            continue

        status = get(competition, "status", get(event, "status", {}))
        status_type = get(status, "type", {})

        state = get(
            status_type,
            "state",
            "",
        )

        detail = get(
            status_type,
            "shortDetail",
            get(
                status_type,
                "detail",
                "",
            ),
        )

        matches.append({
            "id": get(event, "id", ""),
            "home": home,
            "away": away,
            "state": state,
            "status_name": str(get(status_type, "name", "")).upper(),
            "detail": detail,
            "period": get(status, "period", 0),
            "date": get(event, "date", get(competition, "date", "")),
            "competition": competition_name_from_event(
                data,
                event,
                competition_name,
            ),
        })

    return matches


def minutes_until_match(iso, now):
    if type(iso) != "string" or len(iso) < 16:
        return None
    digits = iso[0:4] + iso[5:7] + iso[8:10] + iso[11:13] + iso[14:16]
    for ch in digits.elems():
        if ch < "0" or ch > "9":
            return None
    year = int(iso[0:4])
    month = int(iso[5:7])
    day = int(iso[8:10])
    hour = int(iso[11:13])
    minute = int(iso[14:16])
    if month < 1 or month > 12 or hour > 23 or minute > 59:
        return None
    if day < 1 or day > days_in_month(year, month):
        return None
    # ESPN's event dates are UTC (Z). Explicit zero offsets are equivalent.
    if not (iso.endswith("Z") or iso.endswith("+00:00")):
        return None
    match_minutes = days_from_civil(year, month, day) * 1440 + hour * 60 + minute
    return match_minutes - now.unix // 60


def find_next_team_match(matches, now):
    best = None
    best_minutes = None
    for match in list_value(matches):
        if not (is_my_team(match["home"]) or is_my_team(match["away"])):
            continue
        if match["state"] not in ["", "pre"]:
            continue
        if match["status_name"] in ["STATUS_POSTPONED", "STATUS_CANCELED", "STATUS_CANCELLED", "STATUS_SUSPENDED", "STATUS_ABANDONED"]:
            continue
        minutes = minutes_until_match(match["date"], now)
        if minutes == None or minutes <= 0:
            continue
        if best == None or minutes < best_minutes:
            best = match
            best_minutes = minutes
    return best


def find_live_team_match(matches, now):
    for match in list_value(matches):
        if (is_my_team(match["home"]) or is_my_team(match["away"])) and match["state"] == "in":
            return match
    return None


def find_last_team_match(matches):
    last_match = None

    for match in list_value(matches):
        if match["state"] != "post":
            continue

        is_team_ = (
            is_my_team(match["home"])
            or is_my_team(match["away"])
        )

        if not is_team_:
            continue

        if last_match == None:
            last_match = match
            continue

        if match["date"] > last_match["date"]:
            last_match = match

    return last_match


def team_score(match):
    if is_my_team(match["home"]):
        return match["home"]["score"]

    return match["away"]["score"]


def opponent_score(match):
    if is_my_team(match["home"]):
        return match["away"]["score"]

    return match["home"]["score"]


def match_result(match):
    usa = match["home"] if is_my_team(match["home"]) else match["away"]
    opponent = opponent_of(match)
    if usa["score"] == "-" or opponent["score"] == "-":
        return "FINAL"
    if int(usa["score"]) > int(opponent["score"]):
        return "WIN"
    if int(usa["score"]) < int(opponent["score"]):
        return "LOSS"
    # A tied match can have a winner after a penalty shootout.
    if get(usa, "winner", None) == True:
        return "WIN"
    if get(opponent, "winner", None) == True:
        return "LOSS"
    return "DRAW"


def opponent_of(match):
    if is_my_team(match["home"]):
        return match["away"]

    return match["home"]


def match_symbol(match):
    if is_my_team(match["home"]):
        return "VS"

    return "@"


def draw_branding(c, team):
    c.rect(0, 0, 127, 31, fill=BLACK)
    c.image(team["badge"], 1, 0, 28, 32)


def get_live_team_matches(ctx, team):
    matches = []
    successes = 0
    # Yesterday's UTC fixture can still be in progress after midnight.
    for days_back in range(2):
        day = subtract_days(ctx.now.year, ctx.now.month, ctx.now.day, days_back)
        key = str(day[0]) + pad2(day[1]) + pad2(day[2])
        resp = http.get(ALL_SOCCER_SCOREBOARD_URL + "?dates=" + key, ttl_seconds=60)
        data = get(resp, "json", None)
        if get(resp, "status_code", 0) == 200 and type(get(data, "events", None)) == "list":
            successes += 1
            matches += normalize_events(data, "", team["id"])
    return matches if successes > 0 else None


def get_team_schedule(ctx, team):
    resp = http.get(schedule_url(team) + "?fixture=true", ttl_seconds=300)
    data = get(resp, "json", None)
    if get(resp, "status_code", 0) != 200 or type(get(data, "events", None)) != "list":
        return None
    return normalize_events(data, "", team["id"])


def get_last_team_match(ctx, team):
    # ESPN's all-soccer team schedule behaves differently depending on
    # whether fixture=true is present:
    #
    #   ?fixture=true  -> upcoming fixtures
    #   no query       -> completed matches
    #
    # For Last Match, request the completed-match schedule directly.
    resp = http.get(
        schedule_url(team),
        ttl_seconds=300,
    )

    data = get(resp, "json", None)

    if get(resp, "status_code", 0) != 200 or type(get(data, "events", None)) != "list":
        return {"offline": True}

    matches = normalize_events(
        data,
        "",
        team["id"],
    )

    recent = []
    for match in matches:
        age = minutes_until_match(match["date"], ctx.now)
        if age != None and age <= 0 and age >= -RECENT_MATCH_DAYS * 1440:
            recent.append(match)

    last_game = find_last_team_match(
        recent
    )

    if last_game == None:
        return None

    event_id = get(
        last_game,
        "id",
        "",
    )

    if event_id != "":
        summary_resp = http.get(
            ALL_SOCCER_SUMMARY_URL
            + "?event="
            + event_id,
            ttl_seconds=300,
        )

        summary_data = get(
            summary_resp,
            "json",
            None,
        )

        if summary_data != None:
            last_game["competition"] = (
                competition_name_from_summary(
                    summary_data,
                    last_game["competition"],
                )
            )

    return last_game

def timezone_offset(ctx):
    timezone = ctx.inputs.get(
        "timezone",
        "pacific",
    )

    offsets = {
        "pacific": -7,
        "mountain": -6,
        "central": -5,
        "eastern": -4,
        "alaska": -8,
        "hawaii": -10,
        "utc": 0,
        "uk": 1,
        "central_europe": 2,
        "eastern_europe": 3,
        "turkey": 3,
        "iceland": 0,
    }

    if timezone in offsets:
        return offsets[timezone]

    return -7


def days_until_match(iso, offset, now):
    minutes = minutes_until_match(iso, now)
    if minutes == None:
        return None
    local_now = now.unix // 60 + offset * 60
    return (local_now + minutes) // 1440 - local_now // 1440


def match_countdown_text(minutes):
    if minutes == None:
        return "MATCH TODAY"

    if minutes <= 0:
        return "STARTING SOON"

    hours = minutes // 60
    mins = minutes % 60

    if hours == 0:
        return (
            "MATCH IN "
            + str(mins)
            + " MIN"
        )

    return (
        "MATCH IN "
        + str(hours)
        + "H "
        + str(mins)
        + "M"
    )


def live_match(c, ctx):
    c.clear()
    team = selected_team(ctx)
    draw_branding(c, team)

    tzoffset = timezone_offset(ctx)
    now = ctx.now

    matches = get_live_team_matches(ctx, team)

    live_game = find_live_team_match(
        matches,
        now,
    )

    if live_game != None:
        opponent = opponent_of(live_game)
        crest = opponent_crest(opponent)

        competition = live_game["competition"]

        if competition == "FIFA WORLD CUP":
            competition = "WORLD CUP"

        score = (
            str(team_score(live_game))
            + "-"
            + str(opponent_score(live_game))
        )

        c.text(
            competition,
            78,
            1,
            font="4x5",
            color=team["accent"],
            align="center",
        )

        if crest != "":
            c.image(
                crest,
                103,
                5,
                22,
                22,
            )

        c.text(
            match_symbol(live_game)
            + " "
            + display_team_name(opponent).upper(),
            78,
            8,
            font="3x4",
            color=WHITE,
            align="center",
        )

        c.text(
            score,
            78,
            15,
            font="5x7",
            color=WHITE,
            align="center",
        )

        detail = live_detail(live_game)

        c.text(
            detail,
            78,
            25,
            font="4x5",
            color=team["accent"],
            align="center",
        )

        return

    next_matches = get_team_schedule(ctx, team)

    next_game = find_next_team_match(
        next_matches,
        now,
    )

    c.text(
        "DATA OFFLINE" if matches == None else "NO LIVE MATCH",
        78,
        4,
        font="4x5",
        color=team["accent"],
        align="center",
    )

    if next_game == None:
        c.text(
            "DATA OFFLINE" if next_matches == None else "NO UPCOMING",
            78,
            17,
            font="4x5",
            color=WHITE,
            align="center",
        )

        return

    days = days_until_match(
        next_game["date"],
        tzoffset,
        now,
    )

    if days == None:
        countdown = "NEXT MATCH SOON"

    elif days == 0:
        minutes = minutes_until_match(
            next_game["date"],
            now,
        )

        countdown = match_countdown_text(
            minutes
        )

    elif days == 1:
        countdown = "MATCH TOMORROW"

    else:
        countdown = (
            "NEXT MATCH IN "
            + str(days)
            + " DAYS"
        )

    c.text(
        countdown,
        79,
        17,
        font="4x5",
        color=WHITE,
        align="center",
    )

def next_match(c, ctx):
    c.clear()
    team = selected_team(ctx)
    draw_branding(c, team)

    tzoffset = timezone_offset(ctx)
    now = ctx.now

    matches = get_team_schedule(ctx, team)

    next_game = find_next_team_match(
        matches,
        now,
    )

    if next_game == None:
        c.text(
            "NEXT MATCH",
            78,
            4,
            font="5x7",
            color=team["accent"],
            align="center",
        )

        c.text(
            "DATA OFFLINE" if matches == None else "NO FIXTURE",
            78,
            18,
            font="4x5",
            color=WHITE,
            align="center",
        )

        return

    opponent = opponent_of(next_game)
    symbol = match_symbol(next_game)

    local_time = local_match_datetime(
        next_game["date"],
        tzoffset,
    )

    competition = next_game["competition"]

    if competition == "FIFA WORLD CUP":
        competition = "WORLD CUP"

    crest = opponent_crest(opponent)

    c.text(
        competition,
        78,
        1,
        font="4x5",
        color=team["accent"],
        align="center",
    )

    c.text(
        symbol,
        56,
        11,
        font="4x5",
        color=team["accent"],
    )

    if crest != "":
        c.image(
            crest,
            31,
            8,
            22,
            22,
        )

    c.text(
        display_team_name(opponent).upper(),
        92,
        11,
        font="4x5",
        color=WHITE,
        align="center",
    )

    c.text(
        local_time[0] + " " + local_time[1],
        78,
        22,
        font="4x5",
        color=WHITE,
        align="center",
    )


def last_match(c, ctx):
    c.clear()
    team = selected_team(ctx)
    draw_branding(c, team)

    last_game = get_last_team_match(ctx, team)

    if last_game == None or get(last_game, "offline", False):
        c.text(
            "LAST MATCH",
            78,
            4,
            font="5x7",
            color=team["accent"],
            align="center",
        )

        c.text(
            "DATA OFFLINE" if get(last_game, "offline", False) else "NO RECENT MATCH",
            78,
            18,
            font="4x5",
            color=WHITE,
            align="center",
        )

        return

    opponent = opponent_of(last_game)
    crest = opponent_crest(opponent)

    competition = last_game["competition"]

    if competition == "FIFA WORLD CUP":
        competition = "WORLD CUP"

    score = (
        str(team_score(last_game))
        + "-"
        + str(opponent_score(last_game))
    )

    result = match_result(last_game)

    c.text(
        competition,
        78,
        1,
        font="4x5",
        color=team["accent"],
        align="center",
    )

    if crest != "":
        c.image(
            crest,
            102,
            8,
            20,
            20,
        )

    c.text(
        display_team_name(opponent).upper(),
        78,
        8,
        font="3x4",
        color=WHITE,
        align="center",
    )

    c.text(
        score,
        78,
        15,
        font="5x7",
        color=WHITE,
        align="center",
    )

    c.text(
        result,
        46,
        16,
        font="4x5",
        color=team["accent"],
        align="center",
    )

    c.text(
        simple_date_text(last_game["date"]),
        78,
        25,
        font="3x4",
        color=WHITE,
        align="center",
    )


def list_value(value):
    return value if type(value) == "list" else []

def score_text(value):
    if type(value) == "dict":
        value = get(value, "displayValue", get(value, "value", ""))
    if type(value) == "float":
        return str(int(value))
    text = str(value).strip() if value != None else ""
    if text == "":
        return "-"
    for ch in text.elems():
        if ch < "0" or ch > "9":
            return "-"
    return text

def days_from_civil(year, month, day):
    year = year - 1 if month <= 2 else year
    era = year // 400
    yoe = year - era * 400
    mp = month - 3 if month > 2 else month + 9
    doy = (153 * mp + 2) // 5 + day - 1
    return era * 146097 + yoe * 365 + yoe // 4 - yoe // 100 + doy - 719468

def live_detail(match):
    detail = str(get(match, "detail", "")).upper()
    period = get(match, "period", 0)
    if "PEN" in detail or "SHOOTOUT" in detail:
        return "PENS"
    if "EXTRA" in detail and "HALF" in detail:
        return "ET HT"
    if detail in ["HT", "HALFTIME", "HALF TIME"]:
        return "HT"
    minute = detail.replace("'", "").replace("’", "").strip()
    valid = minute != ""
    for ch in minute.elems():
        if (ch < "0" or ch > "9") and ch != "+":
            valid = False
    if valid:
        phase = {1: " H1", 2: " H2", 3: " ET1", 4: " ET2"}.get(period, "")
        return minute + " MIN" + phase
    return "LIVE"
