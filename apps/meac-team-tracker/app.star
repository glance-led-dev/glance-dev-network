# MEAC Team Tracker
# Live 192x32 Glance Scroll app
# Author: TAS

SCHEDULE_URL_PREFIX = "https://site.api.espn.com/apis/site/v2/sports/football/college-football/teams/"
SCHEDULE_URL_SUFFIX = "/schedule"

MEAC_PURPLE = "#342A7A"
MEAC_GOLD = "#FDBF57"
WHITE = "#FFFFFF"
GRAY = "#969696"
DARK_GRAY = "#505050"
BLACK = "#000000"
RED = "#FF3030"

MEAC_TEAMS = {
    "Delaware State": {
        "id": "2169",
        "abbr": "DSU",
        "logo": "delaware-state.png",
        "color": "#C8102E",
    },
    "Howard": {
        "id": "47",
        "abbr": "HOW",
        "logo": "howard.png",
        "color": "#0050A4",
    },
    "Morgan State": {
        "id": "2415",
        "abbr": "MORG",
        "logo": "morgan-state.png",
        "color": "#F76900",
    },
    "NC Central": {
        "id": "2428",
        "abbr": "NCCU",
        "logo": "nc-central.png",
        "color": "#9E1B32",
    },
    "Norfolk State": {
        "id": "2450",
        "abbr": "NORF",
        "logo": "norfolk-state.png",
        "color": "#007A33",
    },
    "SC State": {
        "id": "2569",
        "abbr": "SCST",
        "logo": "sc-state.png",
        "color": "#8B1E3F",
    },
}

TEAM_LOGOS = {
    # MEAC schools
    "47": "howard.png",
    "2169": "delaware-state.png",
    "2415": "morgan-state.png",
    "2428": "nc-central.png",
    "2450": "norfolk-state.png",
    "2569": "sc-state.png",

    # Known opponents
    "9": "arizona-state.png",
    "50": "florida-am.png",
    "58": "south-florida.png",
    "84": "indiana.png",
    "119": "towson.png",
    "151": "east-carolina.png",
    "219": "penn.png",
    "222": "villanova.png",
    "231": "furman.png",
    "257": "richmond.png",
    "258": "virginia.png",
    "2729": "william-mary.png",
    "295": "old-dominion.png",
    "399": "albany.png",
    "2010": "alabama-am.png",
    "2065": "bethune-cookman.png",
    "2097": "campbell.png",
    "2127": "charleston-southern.png",
    "2130": "chicago-state.png",
    "2241": "gardner-webb.png",
    "2261": "hampton.png",
    "2448": "nc-at.png",
    "2523": "robert-morris.png",
    "2619": "stony-brook.png",
    "2634": "tennessee-state.png",
    "2640": "texas-southern.png",
    "2643": "the-citadel.png",
}

TEAM_COLORS = {
    # MEAC schools
    "47": "#0050A4",
    "2169": "#C8102E",
    "2415": "#F76900",
    "2428": "#9E1B32",
    "2450": "#007A33",
    "2569": "#8B1E3F",

    # Known opponents
    "9": "#8C1D40",
    "50": "#F58220",
    "58": "#006747",
    "84": "#990000",
    "119": "#FFB81C",
    "151": "#592A8A",
    "219": "#011F5B",
    "222": "#003DA5",
    "231": "#582C83",
    "257": "#990000",
    "258": "#232D4B",
    "2729": "#115740",
    "295": "#003057",
    "399": "#46166B",
    "2010": "#6A1B2A",
    "2065": "#B9975B",
    "2097": "#F58025",
    "2127": "#003366",
    "2130": "#00653A",
    "2241": "#BF2F37",
    "2261": "#00529B",
    "2448": "#004684",
    "2523": "#14234B",
    "2619": "#990000",
    "2634": "#003B71",
    "2640": "#6A1B2A",
    "2643": "#5A8DB6",
}


def safe_text(value, fallback):
    if value == None or value == "":
        return fallback

    return str(value)


def safe_color(value, fallback):
    if value == None or value == "":
        return fallback

    value = str(value)

    if value[0:1] == "#":
        return value

    return "#" + value


def two_digits(value):
    if value < 10:
        return "0" + str(value)

    return str(value)


def civil_date_from_days(days):
    z = days + 719468

    if z >= 0:
        era = z // 146097
    else:
        era = (z - 146096) // 146097

    day_of_era = z - era * 146097

    year_of_era = (
        day_of_era
        - day_of_era // 1460
        + day_of_era // 36524
        - day_of_era // 146096
    ) // 365

    year = year_of_era + era * 400

    day_of_year = day_of_era - (
        365 * year_of_era
        + year_of_era // 4
        - year_of_era // 100
    )

    month_part = (5 * day_of_year + 2) // 153

    day = (
        day_of_year
        - (153 * month_part + 2) // 5
        + 1
    )

    if month_part < 10:
        month = month_part + 3
    else:
        month = month_part - 9

    if month <= 2:
        year = year + 1

    return [year, month, day]


def eastern_date_parts(ctx):
    if ctx.now.month >= 3 and ctx.now.month <= 11:
        utc_offset = -4
    else:
        utc_offset = -5

    shifted_unix = ctx.now.unix + utc_offset * 3600
    days = shifted_unix // 86400

    return civil_date_from_days(days)


def eastern_date(ctx):
    parts = eastern_date_parts(ctx)

    return (
        str(parts[0])
        + "-"
        + two_digits(parts[1])
        + "-"
        + two_digits(parts[2])
    )


def selected_team(ctx):
    selected_name = safe_text(
        ctx.inputs.get(
            "trackedteam",
            "NC Central",
        ),
        "NC Central",
    )

    return MEAC_TEAMS.get(
        selected_name,
        MEAC_TEAMS["NC Central"],
    )


def overall_record(competitor):
    records = competitor.get("records", [])

    for record in records:
        record_type = safe_text(
            record.get("type", ""),
            "",
        ).lower()

        record_name = safe_text(
            record.get("name", ""),
            "",
        ).lower()

        if (
            record_type == "total"
            or record_name == "overall"
            or record_name == "total"
        ):
            return safe_text(
                record.get("summary", "0-0"),
                "0-0",
            )

    if len(records) > 0:
        return safe_text(
            records[0].get("summary", "0-0"),
            "0-0",
        )

    return "0-0"


def find_competitor(competitors, side):
    for competitor in competitors:
        if competitor.get("homeAway", "") == side:
            return competitor

    return None


def make_team(competitor, fallback_color):
    if competitor == None:
        return {
            "id": "",
            "abbr": "TEAM",
            "score": "0",
            "record": "0-0",
            "color": fallback_color,
            "logo": "",
            "winner": False,
        }

    team = competitor.get("team", {})
    team_id = safe_text(team.get("id", ""), "")

    abbreviation = safe_text(
        team.get("abbreviation", "TEAM"),
        "TEAM",
    ).upper()

    score = safe_text(
        competitor.get("score", "0"),
        "0",
    )

    team_color = TEAM_COLORS.get(
        team_id,
        safe_color(
            team.get("color", ""),
            fallback_color,
        ),
    )

    return {
        "id": team_id,
        "abbr": abbreviation,
        "score": score,
        "record": overall_record(competitor),
        "color": team_color,
        "logo": TEAM_LOGOS.get(team_id, ""),
        "winner": competitor.get("winner", False),
    }


def scheduled_time(detail, is_today):
    text = safe_text(
        detail,
        "UPCOMING",
    ).upper()

    text = text.replace(" EDT", " ET")
    text = text.replace(" EST", " ET")

    parts = text.split(" - ")

    if is_today and len(parts) > 1:
        text = parts[len(parts) - 1]

    if not is_today:
        text = text.replace(" - ", " ")
        text = text.replace(":00 ", "")
        text = text.replace(" PM", "PM")
        text = text.replace(" AM", "AM")

    if text == "":
        return "UPCOMING"

    if len(text) > 12:
        return text[0:12]

    return text


def make_status(status, is_today):
    status_type = status.get("type", {})

    state = safe_text(
        status_type.get("state", "pre"),
        "pre",
    )

    detail = safe_text(
        status_type.get(
            "shortDetail",
            status_type.get("detail", ""),
        ),
        "",
    )

    detail_upper = detail.upper()
    period = status.get("period", 0)

    clock = safe_text(
        status.get("displayClock", ""),
        "",
    )

    if state == "post":
        if "OT" in detail_upper:
            return ["post", "FINAL/OT"]

        return ["post", "FINAL"]

    if state == "in":
        if "HALF" in detail_upper:
            return ["in", "HALF"]

        if period >= 1 and period <= 4:
            return [
                "in",
                "Q" + str(period) + " " + clock,
            ]

        if period > 4:
            return [
                "in",
                "OT " + clock,
            ]

        return ["in", "LIVE"]

    return [
        "pre",
        scheduled_time(
            detail,
            is_today,
        ),
    ]


def event_is_today(event, today):
    event_date = safe_text(
        event.get("date", ""),
        "",
    )

    return event_date[0:10] == today


def parse_event(event, today):
    competitions = event.get("competitions", [])

    if len(competitions) == 0:
        return None

    competition = competitions[0]
    competitors = competition.get("competitors", [])

    away_competitor = find_competitor(
        competitors,
        "away",
    )

    home_competitor = find_competitor(
        competitors,
        "home",
    )

    if (
        away_competitor == None
        or home_competitor == None
    ):
        return None

    is_today = event_is_today(
        event,
        today,
    )

    status = competition.get(
        "status",
        event.get("status", {}),
    )

    status_parts = make_status(
        status,
        is_today,
    )

    return {
        "away": make_team(
            away_competitor,
            MEAC_PURPLE,
        ),
        "home": make_team(
            home_competitor,
            DARK_GRAY,
        ),
        "state": status_parts[0],
        "status": status_parts[1],
        "today": is_today,
    }


def select_game(events, today):
    today_game = None
    live_game = None
    next_game = None

    for event in events:
        game = parse_event(
            event,
            today,
        )

        if game == None:
            continue

        if game["state"] == "in":
            live_game = game

        if game["today"]:
            today_game = game

        if (
            next_game == None
            and game["state"] == "pre"
        ):
            next_game = game

    if live_game != None:
        return live_game

    if today_game != None:
        return today_game

    return next_game


def fetch_tracked_game(ctx):
    team = selected_team(ctx)
    today = eastern_date(ctx)

    url = (
        SCHEDULE_URL_PREFIX
        + team["id"]
        + SCHEDULE_URL_SUFFIX
    )

    response = http.get(
        url,
        params={
            "season": str(ctx.now.year),
        },
        ttl_seconds=60,
    )

    if (
        response["status_code"] != 200
        or response["json"] == None
    ):
        return {
            "ok": False,
            "game": None,
            "team": team,
            "http": response["status_code"],
        }

    events = response["json"].get(
        "events",
        [],
    )

    game = select_game(
        events,
        today,
    )

    return {
        "ok": True,
        "game": game,
        "team": team,
        "http": 200,
    }


def intro(c, ctx):
    team = selected_team(ctx)

    c.fill(BLACK)

    c.image(
        team["logo"],
        4,
        0,
        w=32,
        h=32,
    )

    c.text(
        team["abbr"],
        42,
        1,
        font="7x12",
        color=team["color"],
    )

    c.text(
        "TEAM TRACKER",
        42,
        17,
        font="5x7",
        color=WHITE,
    )


def draw_letter_badge(
    c,
    abbreviation,
    team_color,
    x,
):
    c.rect(
        x,
        1,
        x + 29,
        30,
        fill=team_color,
    )

    c.rect(
        x + 2,
        3,
        x + 27,
        28,
        outline=WHITE,
    )

    c.text(
        abbreviation[0:4],
        x + 15,
        13,
        font="4x5",
        color=WHITE,
        align="center",
    )


def draw_team_mark(c, team, x):
    if team["logo"] != "":
        c.image(
            team["logo"],
            x,
            0,
            w=31,
            h=31,
        )
    else:
        draw_letter_badge(
            c,
            team["abbr"],
            team["color"],
            x,
        )


def no_upcoming_game(c, team):
    c.fill(BLACK)

    c.image(
        team["logo"],
        4,
        0,
        w=32,
        h=32,
    )

    c.text(
        team["abbr"],
        42,
        2,
        font="7x12",
        color=team["color"],
    )

    c.text(
        "NO GAME",
        42,
        17,
        font="5x7",
        color=WHITE,
    )


def feed_offline_page(
    c,
    team,
    http_status,
):
    c.fill(BLACK)

    c.image(
        team["logo"],
        4,
        0,
        w=32,
        h=32,
    )

    c.text(
        "LIVE FEED",
        42,
        3,
        font="7x12",
        color=WHITE,
    )

    c.text(
        "OFFLINE",
        42,
        17,
        font="7x12",
        color=RED,
    )

    c.text(
        str(http_status),
        188,
        26,
        font="4x5",
        color=GRAY,
        align="right",
    )


def score_colors(game, ctx):
    away_score_color = WHITE
    home_score_color = WHITE

    if game["state"] == "post":
        if game["away"]["winner"]:
            home_score_color = GRAY
        elif game["home"]["winner"]:
            away_score_color = GRAY

    effect = ctx.inputs.get(
        "scoreeffect",
        "team-colors",
    )

    if (
        effect == "flash"
        and game["state"] == "in"
        and ctx.now.second % 2 == 0
    ):
        away_score_color = MEAC_GOLD
        home_score_color = MEAC_GOLD

    return [
        away_score_color,
        home_score_color,
        effect,
    ]


def draw_game(c, ctx, game):
    c.fill(BLACK)

    colors = score_colors(
        game,
        ctx,
    )

    away_score_color = colors[0]
    home_score_color = colors[1]
    effect = colors[2]

    if effect == "scoreboard":
        c.rect(
            69,
            13,
            122,
            31,
            fill="#081018",
        )

    draw_team_mark(
        c,
        game["away"],
        0,
    )

    draw_team_mark(
        c,
        game["home"],
        161,
    )

    away_name_color = game["away"]["color"]
    home_name_color = game["home"]["color"]

    if game["state"] == "post":
        if game["away"]["winner"]:
            home_name_color = GRAY
        elif game["home"]["winner"]:
            away_name_color = GRAY

    c.text(
        game["away"]["abbr"],
        34,
        1,
        font="5x7",
        color=away_name_color,
    )

    c.text(
        game["home"]["abbr"],
        158,
        1,
        font="5x7",
        color=home_name_color,
        align="right",
    )

    c.text(
        game["away"]["record"],
        34,
        9,
        font="4x5",
        color=GRAY,
    )

    c.text(
        game["home"]["record"],
        158,
        9,
        font="4x5",
        color=GRAY,
        align="right",
    )

    if game["state"] == "post":
        status_color = WHITE
    else:
        status_color = MEAC_GOLD

    if (
        game["state"] == "pre"
        and not game["today"]
    ):
        status_font = "4x5"
        status_y = 4
    else:
        status_font = "5x7"
        status_y = 2

    c.text(
        game["status"],
        96,
        status_y,
        font=status_font,
        color=status_color,
        align="center",
    )

    c.text(
        game["away"]["score"],
        82,
        15,
        font="10x16",
        color=away_score_color,
        align="right",
    )

    c.text(
        game["home"]["score"],
        110,
        15,
        font="10x16",
        color=home_score_color,
    )

    c.line(
        95,
        14,
        95,
        29,
        MEAC_PURPLE,
    )

    c.line(
        96,
        14,
        96,
        29,
        MEAC_GOLD,
    )

    c.text(
        "-",
        96,
        19,
        font="5x7",
        color=GRAY,
        align="center",
    )


def game(c, ctx):
    result = fetch_tracked_game(ctx)

    if not result["ok"]:
        feed_offline_page(
            c,
            result["team"],
            result["http"],
        )
        return

    if result["game"] == None:
        no_upcoming_game(
            c,
            result["team"],
        )
        return

    draw_game(
        c,
        ctx,
        result["game"],
    )