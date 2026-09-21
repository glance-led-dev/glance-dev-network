# Liverpool FC Tracker
# 128x32 Glance app

BASE = "https://site.api.espn.com/apis/"

EPL_URL = BASE + "site/v2/sports/soccer/eng.1/scoreboard"
UCL_URL = BASE + "site/v2/sports/soccer/uefa.champions/scoreboard"
FA_CUP_URL = BASE + "site/v2/sports/soccer/eng.fa/scoreboard"
EFL_CUP_URL = BASE + "site/v2/sports/soccer/eng.league_cup/scoreboard"

EPL_STANDINGS_URL = (
    "https://site.api.espn.com/apis/v2/sports/soccer/eng.1/standings"
)

UCL_STANDINGS_URL = (
    "https://site.api.espn.com/apis/v2/sports/soccer/uefa.champions/standings"
)

LIVERPOOL_TEAM_ID = "364"
LIVERPOOL_SCHEDULE_URL = (
    "https://site.web.api.espn.com/apis/site/v2/sports/soccer/all/teams/"
    + LIVERPOOL_TEAM_ID
    + "/schedule"
)

ALL_SOCCER_SCOREBOARD_URL = (
    "https://site.api.espn.com/apis/site/v2/sports/soccer/all/scoreboard"
)

ALL_SOCCER_SUMMARY_URL = (
    "https://site.api.espn.com/apis/site/v2/sports/soccer/all/summary"
)

LIVERPOOL_RED = "#C8102E"
WHITE = "white"
BLACK = "black"
DIM = "gray"

LOGO = "Liverpool-logo.png"


EPL_CRESTS = {
    "ARS": "ARS22.png",
    "AVL": "AVL22.png",
    "BOU": "BOU22.png",
    "BRE": "BRE22.png",
    "BRI": "BRI22.png",
    "CFC": "CFC22.png",
    "COV": "COV22.png",
    "CRY": "CRY22.png",
    "EVE": "EVE22.png",
    "FUL": "FUL22.png",
    "HUL": "HUL22.png",
    "IPS": "IPS22.png",
    "LEE": "LEE22.png",
    "LIV": "LFC22.png",
    "MCI": "MCI22.png",
    "MUN": "MUN22.png",
    "NEW": "NEW22.png",
    "NFO": "NFO22.png",
    "SUN": "SUN22.png",
    "TOT": "TOT22.png",
}


TEAM_DISPLAY_NAMES = {
    "TOT": "Tottenham",
    "MUN": "Man United",
    "MCI": "Man City",
    "NFO": "Nott'm Forest",
    "NEW": "Newcastle",
    "BRI": "Brighton",
    "BOU": "Bournemouth",
    "CRY": "Crystal Palace",
    "COV": "Coventry",
    "IPS": "Ipswich",
    "LEE": "Leeds",
    "HUL": "Hull City",
}


TEAM_NAME_KEYS = {
    "arsenal": "ARS", "aston villa": "AVL",
    "afc bournemouth": "BOU", "bournemouth": "BOU",
    "brentford": "BRE", "brighton": "BRI",
    "brighton & hove albion": "BRI", "brighton and hove albion": "BRI",
    "chelsea": "CFC", "coventry city": "COV",
    "crystal palace": "CRY", "everton": "EVE", "fulham": "FUL",
    "hull city": "HUL", "ipswich town": "IPS",
    "leeds united": "LEE", "liverpool": "LIV",
    "liverpool fc": "LIV", "manchester city": "MCI",
    "manchester united": "MUN", "newcastle united": "NEW",
    "nottingham forest": "NFO", "sunderland": "SUN",
    "tottenham hotspur": "TOT", "tottenham": "TOT",
}

SHORT_TEAM_NAMES = {
    "paris saint-germain": "PSG",
    "paris saint germain": "PSG",
    "borussia dortmund": "Dortmund",
    "borussia monchengladbach": "M'gladbach",
    "bayer leverkusen": "Leverkusen",
    "atletico madrid": "Atletico",
    "atlético madrid": "Atletico",
    "sporting clube de portugal": "Sporting CP",
    "sporting lisbon": "Sporting CP",
    "wolverhampton wanderers": "Wolves",
    "west ham united": "West Ham",
    "sheffield united": "Sheff United",
    "sheffield wednesday": "Sheff Wed",
    "queens park rangers": "QPR",
    "red bull salzburg": "RB Salzburg",
    "eintracht frankfurt": "Frankfurt",
}


def opponent_key(opponent):
    name = str(get(opponent, "name", "")).strip().lower()
    if name in TEAM_NAME_KEYS:
        return TEAM_NAME_KEYS[name]
    abbr = str(get(opponent, "abbr", "")).strip().upper()
    aliases = {"CHE": "CFC", "BHA": "BRI", "B&H": "BRI", "NOT": "NFO", "LFC": "LIV"}
    return aliases.get(abbr, abbr)


def opponent_crest(opponent):
    abbr = opponent_key(opponent)

    if abbr in EPL_CRESTS:
        return EPL_CRESTS[abbr]

    return ""


def draw_opponent_crest(c, opponent, x, y, size):
    crest = opponent_crest(opponent)
    if crest == "":
        return
    # These navy crests lose their outlines against the panel's black background.
    if opponent_key(opponent) in ["TOT", "EVE"]:
        c.rect(x, y, x + size - 1, y + size - 1, fill=WHITE)
    c.image(crest, x, y, size, size)


def display_team_name(opponent):
    abbr = opponent_key(opponent)
    if abbr in TEAM_DISPLAY_NAMES:
        return TEAM_DISPLAY_NAMES[abbr]
    name = str(get(opponent, "name", "")).strip()
    if name == "":
        return abbr[:14] if abbr != "" else "OPPONENT"
    if len(name) <= 14:
        return name
    short = SHORT_TEAM_NAMES.get(name.lower(), "")
    if short != "":
        return short
    # ESPN short names are useful for unfamiliar cup/European opponents.
    short = str(get(opponent, "short_name", "")).strip()
    if short != "" and len(short) <= 14:
        return short
    if abbr != "" and len(abbr) <= 14:
        return abbr
    return name[:11].rstrip() + "..."


def get(obj, key, fallback=None):
    if type(obj) != "dict":
        return fallback
    value = obj.get(key, fallback)
    return fallback if value == None else value


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
    combined = text.lower()

    if "premier league" in combined or "eng.1" in combined:
        return "PREMIER LEAGUE"

    if "champions" in combined:
        return "CHAMPIONS LEAGUE"

    if "fa cup" in combined or "eng.fa" in combined:
        return "FA CUP"

    if (
        "league cup" in combined
        or "carabao" in combined
        or "eng.league_cup" in combined
    ):
        return "EFL CUP"

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


def is_liverpool_team(team):
    abbr = get(team, "abbr", "").upper()
    name = get(team, "name", "").lower()

    return (
        str(get(team, "id", "")) == LIVERPOOL_TEAM_ID
        or abbr == "LIV"
        or abbr == "LFC"
        or "liverpool" in name
    )


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


def draw_opponent_name(c, opponent, x, y, font, max_width, prefix=""):
    text = prefix + display_team_name(opponent).upper()
    if c.text_width(text, font) > max_width:
        font = "3x4"
    c.text(text, x, y, font=font, color=WHITE, align="center")


def normalize_events(data, competition_name):
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
                "score": score_text(get(competitor, "score", "")),
                "logo": get(team, "logo", ""),
            }

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


def days_from_civil(year, month, day):
    year = year - 1 if month <= 2 else year
    era = year // 400
    yoe = year - era * 400
    mp = month - 3 if month > 2 else month + 9
    doy = (153 * mp + 2) // 5 + day - 1
    return era * 146097 + yoe * 365 + yoe // 4 - yoe // 100 + doy - 719468


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


def find_next_liverpool_match(matches, now):
    next_match = None

    for match in matches:
        is_liverpool = (
            is_liverpool_team(match["home"])
            or is_liverpool_team(match["away"])
        )

        if not is_liverpool:
            continue

        if match["state"] == "post":
            continue

        if match["state"] == "in":
            continue

        minutes = minutes_until_match(
            match["date"],
            now,
        )

        if minutes == None or minutes <= 0:
            continue

        if next_match == None:
            next_match = match
            continue

        if match["date"] < next_match["date"]:
            next_match = match

    return next_match


def find_live_liverpool_match(matches, now):
    for match in matches:
        is_liverpool = (
            is_liverpool_team(match["home"])
            or is_liverpool_team(match["away"])
        )

        if not is_liverpool:
            continue

        if match["state"] == "post":
            continue

        if match["state"] == "in":
            return match

    return None


def find_last_liverpool_match(matches):
    last_match = None

    for match in matches:
        if match["state"] != "post":
            continue

        is_liverpool = (
            is_liverpool_team(match["home"])
            or is_liverpool_team(match["away"])
        )

        if not is_liverpool:
            continue

        if last_match == None:
            last_match = match
            continue

        if match["date"] > last_match["date"]:
            last_match = match

    return last_match


def liverpool_score(match):
    if is_liverpool_team(match["home"]):
        return match["home"]["score"]

    return match["away"]["score"]


def opponent_score(match):
    if is_liverpool_team(match["home"]):
        return match["away"]["score"]

    return match["home"]["score"]


def match_result(match):
    if liverpool_score(match) == "-" or opponent_score(match) == "-":
        return "FINAL"
    liverpool = int(liverpool_score(match))
    opponent = int(opponent_score(match))

    if liverpool > opponent:
        return "WIN"

    if liverpool < opponent:
        return "LOSS"

    return "DRAW"


def opponent_of(match):
    if is_liverpool_team(match["home"]):
        return match["away"]

    return match["home"]


def match_symbol(match):
    if is_liverpool_team(match["home"]):
        return "VS"

    return "@"


def draw_branding(c):
    c.rect(
        0,
        0,
        127,
        31,
        fill=BLACK,
    )

    c.rect(
        0,
        0,
        29,
        31,
        fill=WHITE,
    )

    c.image(
        LOGO,
        -4,
        0,
        35,
        33,
    )


def get_live_liverpool_matches(ctx):
    now = ctx.now

    today_date = (
        str(now.year)
        + pad2(now.month)
        + pad2(now.day)
    )

    matches = []

    # LIVE: single-day all-soccer scoreboard only.
    resp = http.get(
        ALL_SOCCER_SCOREBOARD_URL
        + "?dates="
        + today_date,
        ttl_seconds=60,
    )

    data = get(resp, "json", None)

    if data != None:
        matches = matches + normalize_events(
            data,
            "",
        )

    return matches


def get_next_liverpool_matches(ctx):
    matches = []

    # NEXT: Liverpool's all-competitions team schedule.
    resp = http.get(
        LIVERPOOL_SCHEDULE_URL
        + "?fixture=true",
        ttl_seconds=300,
    )

    data = get(resp, "json", None)

    if data != None:
        matches = matches + normalize_events(
            data,
            "",
        )

    return matches


def get_last_liverpool_match(ctx):
    now = ctx.now

    # Search one calendar day at a time, newest first. As soon as a
    # completed Liverpool match is found, stop searching older days.
    # Then use one event-summary request to recover the competition name.
    # Worst case: 7 scoreboard requests + 1 summary request = 8 total.
    for days_back in range(7):
        check_date = subtract_days(
            now.year,
            now.month,
            now.day,
            days_back,
        )

        date_text = (
            str(check_date[0])
            + pad2(check_date[1])
            + pad2(check_date[2])
        )

        resp = http.get(
            ALL_SOCCER_SCOREBOARD_URL
            + "?dates="
            + date_text,
            ttl_seconds=300,
        )

        data = get(resp, "json", None)

        if data == None:
            continue

        matches = normalize_events(
            data,
            "",
        )

        last_game = find_last_liverpool_match(
            matches
        )

        if last_game == None:
            continue

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

    return None


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
    if iso == None or len(iso) < 16:
        return None

    match_year = int(iso[0:4])
    match_month = int(iso[5:7])
    match_day = int(iso[8:10])
    match_hour = int(iso[11:13])

    match_hour = match_hour + offset

    if match_hour < 0:
        match_hour = match_hour + 24
        match_day = match_day - 1

        if match_day < 1:
            match_month = match_month - 1

            if match_month < 1:
                match_month = 12
                match_year = match_year - 1

            match_day = days_in_month(
                match_year,
                match_month,
            )

    elif match_hour >= 24:
        match_hour = match_hour - 24
        match_day = match_day + 1

        if match_day > days_in_month(
            match_year,
            match_month,
        ):
            match_day = 1
            match_month = match_month + 1

            if match_month > 12:
                match_month = 1
                match_year = match_year + 1

    local_year = now.year
    local_month = now.month
    local_day = now.day
    local_hour = now.hour + offset

    if local_hour < 0:
        local_hour = local_hour + 24
        local_day = local_day - 1

        if local_day < 1:
            local_month = local_month - 1

            if local_month < 1:
                local_month = 12
                local_year = local_year - 1

            local_day = days_in_month(
                local_year,
                local_month,
            )

    elif local_hour >= 24:
        local_hour = local_hour - 24
        local_day = local_day + 1

        if local_day > days_in_month(
            local_year,
            local_month,
        ):
            local_day = 1
            local_month = local_month + 1

            if local_month > 12:
                local_month = 1
                local_year = local_year + 1

    for i in range(366):
        check = add_days(
            local_year,
            local_month,
            local_day,
            i,
        )

        if (
            check[0] == match_year
            and check[1] == match_month
            and check[2] == match_day
        ):
            return i

    return None


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
    draw_branding(c)

    tzoffset = timezone_offset(ctx)
    now = ctx.now

    matches = get_live_liverpool_matches(ctx)

    live_game = find_live_liverpool_match(
        matches,
        now,
    )

    if live_game != None:
        opponent = opponent_of(live_game)
        crest = opponent_crest(opponent)

        competition = live_game["competition"]

        if competition == "CHAMPIONS LEAGUE":
            competition = "CHAMPIONS LG"

        score = (
            str(liverpool_score(live_game))
            + "-"
            + str(opponent_score(live_game))
        )

        c.text(
            competition,
            78,
            1,
            font="4x5",
            color=LIVERPOOL_RED,
            align="center",
        )

        draw_opponent_crest(c, opponent, 103, 5, 22)

        draw_opponent_name(c, opponent, 66 if crest != "" else 78,
                           8, "3x4", 70 if crest != "" else 96,
                           match_symbol(live_game) + " ")

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
            color=LIVERPOOL_RED,
            align="center",
        )

        return

    next_matches = get_next_liverpool_matches(ctx)

    next_game = find_next_liverpool_match(
        next_matches,
        now,
    )

    c.text(
        "NO LIVE MATCH",
        78,
        4,
        font="4x5",
        color=LIVERPOOL_RED,
        align="center",
    )

    if next_game == None:
        c.text(
            "NO UPCOMING",
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
    draw_branding(c)

    tzoffset = timezone_offset(ctx)
    now = ctx.now

    matches = get_next_liverpool_matches(ctx)

    next_game = find_next_liverpool_match(
        matches,
        now,
    )

    if next_game == None:
        c.text(
            "NEXT MATCH",
            78,
            4,
            font="5x7",
            color=LIVERPOOL_RED,
            align="center",
        )

        c.text(
            "NO FIXTURE",
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

    if competition == "CHAMPIONS LEAGUE":
        competition = "CHAMPIONS LG"

    crest = opponent_crest(opponent)

    c.text(
        competition,
        78,
        1,
        font="4x5",
        color=LIVERPOOL_RED,
        align="center",
    )

    c.text(
        symbol,
        55,
        11,
        font="4x5",
        color=LIVERPOOL_RED,
    )

    draw_opponent_crest(c, opponent, 31, 7, 22)

    draw_opponent_name(c, opponent, 90, 11, "4x5", 64)

    c.text(
        local_time[0] + " " + local_time[1],
        80,
        22,
        font="3x4",
        color=WHITE,
        align="center",
    )


def last_match(c, ctx):
    c.clear()
    draw_branding(c)

    last_game = get_last_liverpool_match(ctx)

    if last_game == None:
        c.text(
            "LAST MATCH",
            78,
            4,
            font="5x7",
            color=LIVERPOOL_RED,
            align="center",
        )

        c.text(
            "NO RESULT",
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

    if competition == "CHAMPIONS LEAGUE":
        competition = "CHAMPIONS LG"

    score = (
        str(liverpool_score(last_game))
        + "-"
        + str(opponent_score(last_game))
    )

    result = match_result(last_game)

    c.text(
        competition,
        78,
        1,
        font="4x5",
        color=LIVERPOOL_RED,
        align="center",
    )

    draw_opponent_crest(c, opponent, 102, 8, 20)

    draw_opponent_name(c, opponent, 78 if crest != "" else 78,
                       8, "3x4", 70 if crest != "" else 96)

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
        color=LIVERPOOL_RED,
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


def standing_stat(stats, name, fallback=0):
    for stat in stats:
        if get(stat, "name", "") == name:
            return get(stat, "value", fallback)

    return fallback


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


def find_liverpool_standing(data):
    groups = list_value(get(data, "children", []))

    for group in groups:
        standings = get(group, "standings", {})
        entries = list_value(get(standings, "entries", []))

        for entry in entries:
            team = get(entry, "team", {})

            if get(team, "abbreviation", "") == "LIV":
                stats = list_value(get(entry, "stats", []))

                return {
                    "rank": int(
                        standing_stat(
                            stats,
                            "rank",
                            0,
                        )
                    ),
                    "played": int(
                        standing_stat(
                            stats,
                            "gamesPlayed",
                            0,
                        )
                    ),
                    "wins": int(
                        standing_stat(
                            stats,
                            "wins",
                            0,
                        )
                    ),
                    "ties": int(
                        standing_stat(
                            stats,
                            "ties",
                            0,
                        )
                    ),
                    "losses": int(
                        standing_stat(
                            stats,
                            "losses",
                            0,
                        )
                    ),
                    "gd": standing_goal_difference(stats),
                    "points": int(
                        standing_stat(
                            stats,
                            "points",
                            0,
                        )
                    ),
                }

    return None


def ordinal_place(number):
    if number <= 0:
        return "--"
    suffix = "TH"
    if number % 100 not in [11, 12, 13]:
        suffix = {1: "ST", 2: "ND", 3: "RD"}.get(number % 10, "TH")
    return str(number) + suffix


def premier_league_table(c, ctx):
    c.clear()
    draw_branding(c)

    resp = http.get(
        EPL_STANDINGS_URL,
        ttl_seconds=900,
    )

    data = resp["json"]

    standing = find_liverpool_standing(data)

    if standing == None:
        c.text(
            "PREMIER LEAGUE",
            78,
            4,
            font="4x5",
            color=LIVERPOOL_RED,
            align="center",
        )

        c.text(
            "NO TABLE DATA",
            78,
            17,
            font="4x5",
            color=WHITE,
            align="center",
        )

        return

    record = (
        str(standing["wins"])
        + "-"
        + str(standing["ties"])
        + "-"
        + str(standing["losses"])
    )

    gd = goal_difference_text(standing["gd"])

    c.text(
        "PREMIER LEAGUE",
        78,
        1,
        font="4x5",
        color=LIVERPOOL_RED,
        align="center",
    )

    c.text(
        ordinal_place(standing["rank"]),
        58,
        10,
        font="6x8",
        color=WHITE,
        align="center",
    )

    c.text(
        str(standing["points"]) + " PTS",
        97,
        11,
        font="4x5",
        color=LIVERPOOL_RED,
        align="center",
    )

    c.text(
        record,
        58,
        22,
        font="4x5",
        color=WHITE,
        align="center",
    )

    c.text(
        "GD "
        + gd
        + " GP "
        + str(standing["played"]),
        99,
        22,
        font="4x5",
        color=WHITE,
        align="center",
    )


def champions_league_table(c, ctx):
    c.clear()
    draw_branding(c)

    resp = http.get(
        UCL_STANDINGS_URL,
        ttl_seconds=900,
    )

    data = resp["json"]

    standing = find_liverpool_standing(data)

    if standing == None:
        c.text(
            "CHAMPIONS LG",
            78,
            4,
            font="4x5",
            color=LIVERPOOL_RED,
            align="center",
        )

        c.text(
            "NO TABLE DATA",
            78,
            17,
            font="4x5",
            color=WHITE,
            align="center",
        )

        return

    record = (
        str(standing["wins"])
        + "-"
        + str(standing["ties"])
        + "-"
        + str(standing["losses"])
    )

    gd = goal_difference_text(standing["gd"])

    c.text(
        "CHAMPIONS LEAGUE",
        78,
        1,
        font="4x5",
        color=LIVERPOOL_RED,
        align="center",
    )

    c.text(
        ordinal_place(standing["rank"]),
        57,
        10,
        font="6x8",
        color=WHITE,
        align="center",
    )

    c.text(
        str(standing["points"]) + " PTS",
        97,
        11,
        font="4x5",
        color=LIVERPOOL_RED,
        align="center",
    )

    c.text(
        record,
        58,
        22,
        font="4x5",
        color=WHITE,
        align="center",
    )

    c.text(
        "GD "
        + gd
        + " GP "
        + str(standing["played"]),
        99,
        22,
        font="4x5",
        color=WHITE,
        align="center",
    )
