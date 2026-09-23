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
    "MNC": "MCI22.png",
    "MUN": "MUN22.png",
    "MAN": "MUN22.png",
    "BHA": "BRI22.png",
    "CHE": "CFC22.png",
    "NEW": "NEW22.png",
    "NFO": "NFO22.png",
    "SUN": "SUN22.png",
    "TOT": "TOT22.png",
}


# ESPN renamed Man City MCI -> MNC, Man United MUN -> MAN, Brighton BRI -> BHA
# and Chelsea CFC -> CHE for 2026-27. Both spellings are kept so the crest and
# the short name resolve whichever one the feed sends.
TEAM_DISPLAY_NAMES = {
    "TOT": "Tottenham",
    "MUN": "Man United",
    "MAN": "Man United",
    "MCI": "Man City",
    "MNC": "Man City",
    "NFO": "Nott'm Forest",
    "NEW": "Newcastle",
    "BRI": "Brighton",
    "BHA": "Brighton",
    "BOU": "Bournemouth",
}


def opponent_crest(opponent):
    abbr = opponent["abbr"]

    if abbr in EPL_CRESTS:
        return EPL_CRESTS[abbr]

    return ""


def display_team_name(opponent):
    abbr = opponent["abbr"]

    if abbr in TEAM_DISPLAY_NAMES:
        return TEAM_DISPLAY_NAMES[abbr]

    return opponent["name"]


def fitted_team_name(c, opponent, font, max_width, prefix=""):
    # "MANCHESTER CITY" centred over a 66px slot ran straight through the VS
    # beside it, and a Champions League opponent has no crest or short name
    # in the tables above at all. So the label is chosen by measuring: the
    # first of the short name, ESPN's short name, the full name and the
    # abbreviation that fits the slot is the one drawn.
    abbr = opponent["abbr"]

    candidates = []

    if abbr in TEAM_DISPLAY_NAMES:
        candidates.append(TEAM_DISPLAY_NAMES[abbr])

    candidates.append(opponent.get("short", ""))
    candidates.append(opponent["name"])
    candidates.append(abbr)

    for name in candidates:
        if name == "":
            continue

        label = (prefix + name).upper()

        if c.text_width(label, font) <= max_width:
            return label

    return (prefix + abbr).upper()


def get(obj, key, fallback=None):
    if obj == None:
        return fallback

    if key in obj:
        return obj[key]

    return fallback


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


def normalize_events(data, competition_name):
    matches = []

    events = get(data, "events", [])

    for event in events:
        competitions = get(event, "competitions", [])

        if len(competitions) == 0:
            continue

        competition = competitions[0]
        competitors = get(competition, "competitors", [])

        home = None
        away = None

        for competitor in competitors:
            side = get(competitor, "homeAway", "")
            team = get(competitor, "team", {})

            normalized = {
                "abbr": get(team, "abbreviation", ""),
                "name": get(team, "displayName", ""),
                "short": get(team, "shortDisplayName", ""),
                "score": get(competitor, "score", ""),
                "logo": get(team, "logo", ""),
            }

            if side == "home":
                home = normalized

            elif side == "away":
                away = normalized

        if home == None or away == None:
            continue

        status = get(event, "status", {})
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
            "home": home,
            "away": away,
            "state": state,
            "detail": detail,
            "date": get(event, "date", ""),
            "competition": competition_name,
        })

    return matches


def minutes_until_match(iso, now):
    if iso == None or len(iso) < 16:
        return None

    match_year = int(iso[0:4])
    match_month = int(iso[5:7])
    match_day = int(iso[8:10])
    match_hour = int(iso[11:13])
    match_minute = int(iso[14:16])

    day_difference = None

    for i in range(366):
        check = add_days(
            now.year,
            now.month,
            now.day,
            i,
        )

        if (
            check[0] == match_year
            and check[1] == match_month
            and check[2] == match_day
        ):
            day_difference = i
            break

    if day_difference == None:
        for i in range(1, 366):
            check = subtract_days(
                now.year,
                now.month,
                now.day,
                i,
            )

            if (
                check[0] == match_year
                and check[1] == match_month
                and check[2] == match_day
            ):
                day_difference = 0 - i
                break

    if day_difference == None:
        return None

    current_minutes = (
        now.hour * 60
        + now.minute
    )

    match_minutes = (
        day_difference * 1440
        + match_hour * 60
        + match_minute
    )

    return match_minutes - current_minutes


def find_next_liverpool_match(matches, now):
    next_match = None

    for match in matches:
        is_liverpool = (
            match["home"]["abbr"] == "LIV"
            or match["away"]["abbr"] == "LIV"
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
            match["home"]["abbr"] == "LIV"
            or match["away"]["abbr"] == "LIV"
        )

        if not is_liverpool:
            continue

        if match["state"] == "post":
            continue

        if match["state"] == "in":
            return match

        minutes = minutes_until_match(
            match["date"],
            now,
        )

        if (
            minutes != None
            and minutes <= 0
            and minutes > -180
        ):
            return match

    return None


def find_last_liverpool_match(matches):
    last_match = None

    for match in matches:
        if match["state"] != "post":
            continue

        is_liverpool = (
            match["home"]["abbr"] == "LIV"
            or match["away"]["abbr"] == "LIV"
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
    if match["home"]["abbr"] == "LIV":
        return match["home"]["score"]

    return match["away"]["score"]


def opponent_score(match):
    if match["home"]["abbr"] == "LIV":
        return match["away"]["score"]

    return match["home"]["score"]


def match_result(match):
    liverpool = int(liverpool_score(match))
    opponent = int(opponent_score(match))

    if liverpool > opponent:
        return "WIN"

    if liverpool < opponent:
        return "LOSS"

    return "DRAW"


def opponent_of(match):
    if match["home"]["abbr"] == "LIV":
        return match["away"]

    return match["home"]


def match_symbol(match):
    if match["home"]["abbr"] == "LIV":
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


def month_query(year, month):
    return "?dates=" + str(year) + pad2(month) + "&limit=100"


def get_liverpool_matches(ctx):
    # ESPN's soccer scoreboard stopped accepting a "dates=START-END" range
    # (it now answers 400 "Failed to get events endpoint"), which emptied the
    # live, next and last pages while the standings pages kept working. A
    # whole month ("dates=YYYYMM") is still accepted, so months are fetched
    # instead: the current one always, plus the previous month early in the
    # month and the next month late in it. That keeps at least two weeks in
    # view either side of today (Liverpool never go longer than that without
    # a match) within the sandbox cap of 8 requests per render: four
    # competitions x two months.
    now = ctx.now

    year = now.year
    month = now.month

    if now.day < 16:
        other_year = year
        other_month = month - 1
        if other_month < 1:
            other_month = 12
            other_year = year - 1
    else:
        other_year = year
        other_month = month + 1
        if other_month > 12:
            other_month = 1
            other_year = year + 1

    # The current month carries the live match, so it refreshes fastest.
    months = [
        [year, month, 60],
        [other_year, other_month, 300],
    ]

    competitions = [
        [EPL_URL, "PREMIER LEAGUE"],
        [UCL_URL, "CHAMPIONS LEAGUE"],
        [FA_CUP_URL, "FA CUP"],
        [EFL_CUP_URL, "EFL CUP"],
    ]

    matches = []

    for comp in competitions:
        for m in months:
            resp = http.get(
                comp[0] + month_query(m[0], m[1]),
                ttl_seconds=m[2],
            )

            if resp["status_code"] != 200:
                continue

            matches = matches + normalize_events(
                resp["json"],
                comp[1],
            )

    return matches


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

    matches = get_liverpool_matches(ctx)

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

        if crest != "":
            c.image(
                crest,
                103,
                5,
                22,
                22,
            )

        c.text(
            fitted_team_name(
                c,
                opponent,
                "3x4",
                74 if crest != "" else 100,
                match_symbol(live_game) + " ",
            ),
            65 if crest != "" else 78,
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

        detail = live_game["detail"]
        upper_detail = detail.upper()

        minutes = minutes_until_match(
            live_game["date"],
            now,
        )

        elapsed = None

        if minutes != None and minutes <= 0:
            elapsed = 0 - minutes

        # -------------------------
        # PENALTY SHOOTOUT
        # -------------------------

        if (
            "PEN" in upper_detail
            or "SHOOTOUT" in upper_detail
        ):
            detail = "PENS"

        # -------------------------
        # EXTRA TIME BREAK
        # -------------------------

        elif (
            "EXTRA" in upper_detail
            and "HALF" in upper_detail
        ):
            detail = "ET HT"

        # -------------------------
        # NORMAL HALFTIME
        # -------------------------

        elif (
            upper_detail == "HT"
            or upper_detail == "HALFTIME"
            or upper_detail == "HALF TIME"
        ):
            detail = "HT"

        # -------------------------
        # ESPN LIVE MINUTE
        # Examples:
        # 42'
        # 45+3'
        # 90'
        # 105+1'
        # -------------------------

        elif (
            detail != ""
            and "'" in detail
        ):
            minute_text = detail.replace(
                "'",
                "",
            )

            if elapsed == None:
                detail = (
                    minute_text
                    + " MIN"
                )

            elif elapsed < 60:
                detail = (
                    minute_text
                    + " MIN H1"
                )

            elif elapsed < 115:
                detail = (
                    minute_text
                    + " MIN H2"
                )

            elif elapsed < 135:
                detail = (
                    minute_text
                    + " MIN ET1"
                )

            else:
                detail = (
                    minute_text
                    + " MIN ET2"
                )

        # -------------------------
        # FALLBACK
        # Only used if ESPN does
        # not provide a minute.
        # -------------------------

        elif elapsed != None:
            if elapsed <= 45:
                detail = (
                    str(elapsed)
                    + " MIN H1"
                )

            elif elapsed < 60:
                detail = "HT"

            elif elapsed < 115:
                detail = (
                    str(elapsed - 15)
                    + " MIN H2"
                )

            elif elapsed < 135:
                detail = "ET1"

            elif elapsed < 140:
                detail = "ET HT"

            elif elapsed < 165:
                detail = "ET2"

            else:
                detail = "LIVE"

        else:
            detail = "LIVE"

        c.text(
            detail,
            78,
            25,
            font="4x5",
            color=LIVERPOOL_RED,
            align="center",
        )

        return

    next_game = find_next_liverpool_match(
        matches,
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

    matches = get_liverpool_matches(ctx)

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

    # The crest ends at x=52; the VS/@ sits three pixels clear of it, and the
    # name and the date line both start to its right so neither can touch it.
    c.text(
        symbol,
        56,
        11,
        font="4x5",
        color=LIVERPOOL_RED,
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
        fitted_team_name(c, opponent, "4x5", 62),
        97,
        11,
        font="4x5",
        color=WHITE,
        align="center",
    )

    c.text(
        local_time[0] + " " + local_time[1],
        90,
        22,
        font="4x5",
        color=WHITE,
        align="center",
    )


def last_match(c, ctx):
    c.clear()
    draw_branding(c)

    matches = get_liverpool_matches(ctx)

    last_game = find_last_liverpool_match(matches)

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

    if crest != "":
        c.image(
            crest,
            33,
            9,
            20,
            20,
        )

    c.text(
        fitted_team_name(
            c,
            opponent,
            "3x4",
            74 if crest != "" else 100,
        ),
        91 if crest != "" else 78,
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
        109,
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


def find_liverpool_standing(data):
    groups = get(data, "children", [])

    for group in groups:
        standings = get(group, "standings", {})
        entries = get(standings, "entries", [])

        for entry in entries:
            team = get(entry, "team", {})

            if get(team, "abbreviation", "") == "LIV":
                stats = get(entry, "stats", [])

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
                    "gd": int(
                        standing_stat(
                            stats,
                            "goalDifference",
                            0,
                        )
                    ),
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
    if number == 1:
        return "1ST"

    if number == 2:
        return "2ND"

    if number == 3:
        return "3RD"

    return str(number) + "TH"


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

    gd = str(standing["gd"])

    if standing["gd"] > 0:
        gd = "+" + gd

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

    gd = str(standing["gd"])

    if standing["gd"] > 0:
        gd = "+" + gd

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
