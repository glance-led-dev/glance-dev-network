# MFL Live Scores
# Version 1.0.0
#
# Community app for Glance LED.
#
# User pastes an MFL league home URL:
#
# https://www46.myfantasyleague.com/2026/home/38420
#
# The app extracts:
#   - MFL server
#   - season
#   - league ID
#
# Then retrieves:
#   - league information
#   - weekly schedule
#   - live scoring
#
# Display:
#
# COX ROCKS W1
#
# NJIGBA       91.7
# MAYE-BE      84.3
#
#  78%          24%


# ==================================================
# DATE HELPERS
# ==================================================

MONTH_START = [
    0,
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
]


def day_of_year(month, day):
    return MONTH_START[month] + day


def season_week(ctx, season):
    # NFL Week 1 normally starts in early September.
    #
    # 2026 begins September 9.
    #
    # For future seasons this approximate calculation
    # keeps the community app usable, while the
    # schedule endpoint remains the source of matchup
    # information.

    month = ctx.now.month
    day = ctx.now.day

    today = day_of_year(
        month,
        day,
    )

    # 2026 anchor.
    #
    # This can be updated in future app versions as
    # NFL schedules are released.

    week1_start = day_of_year(
        9,
        9,
    )

    if today < week1_start:
        return "1"

    days_since = (
        today - week1_start
    )

    week = (
        days_since // 7
    ) + 1

    if week < 1:
        week = 1

    if week > 18:
        week = 18

    return str(week)


# ==================================================
# PARSE MFL URL
# ==================================================

def parse_league_url(ctx):
    value = ctx.inputs.get(
        "leagueurl",
        "",
    )

    value = value.strip()

    if value == "":
        return {
            "error": "ENTER URL",
        }

    parts = value.split("/")

    # Expected:
    #
    # 0 https:
    # 1
    # 2 www46.myfantasyleague.com
    # 3 2026
    # 4 home
    # 5 38420

    if len(parts) < 6:
        return {
            "error": "BAD URL",
        }

    host = parts[2]
    season = parts[3]

    leagueid = (
        parts[5]
        .split("#")[0]
        .split("?")[0]
    )

    if "myfantasyleague.com" not in host:
        return {
            "error": "NOT MFL",
        }

    if leagueid == "":
        return {
            "error": "NO ID",
        }

    return {
        "error": None,
        "host": host,
        "season": season,
        "leagueid": leagueid,
    }


# ==================================================
# SAFE INTEGER
# ==================================================

def number_value(value):
    if value == None:
        return 0

    text = str(value)

    if text == "":
        return 0

    return int(text)


# ==================================================
# SCORE FORMATTING
# ==================================================

def format_score(score):
    if score == None:
        return "--.-"

    text = str(score)

    if "." not in text:
        return text

    parts = text.split(".")

    if len(parts) != 2:
        return text

    whole = parts[0]
    decimal = parts[1]

    if len(decimal) > 1:
        decimal = decimal[:1]

    return whole + "." + decimal


# ==================================================
# TEAM NAME HELPERS
# ==================================================

def clean_word(word):
    word = word.upper()

    # Remove some common punctuation that wastes
    # precious LED pixels.

    word = word.replace(",", "")
    word = word.replace("!", "")
    word = word.replace("?", "")
    word = word.replace(".", "")

    return word


def useful_word(word):
    word = clean_word(word)

    stopwords = [
        "",
        "A",
        "AN",
        "THE",
        "OF",
        "TO",
        "IN",
        "ON",
        "AT",
        "IS",
        "IT",
        "ITS",
        "IM",
        "I'M",
        "YOU",
        "YOUR",
        "MY",
        "ME",
        "WE",
        "OUR",
        "AND",
        "OR",
        "BUT",
        "IF",
        "NOW",
        "WHAT",
        "THAT",
        "THIS",
        "BE",
        "BEEN",
        "ARE",
        "WAS",
        "NOT",
        "DONT",
        "DON'T",
        "KNOW",
    ]

    return word not in stopwords


def smart_short_name(name, abbrev):
    name = name.upper()

    # If MFL has supplied a useful 4-8 character
    # abbreviation, prefer it.

    if abbrev != None:

        short = abbrev.upper()

        if (
            len(short) >= 4
            and len(short) <= 8
        ):
            return short

    words = name.split(" ")

    useful = []

    for word in words:

        word = clean_word(word)

        if useful_word(word):
            useful.append(word)

    # A single meaningful word is usually an
    # excellent fantasy-team label.

    if len(useful) == 1:
        return useful[0]

    # Prefer a useful word that is 4-8 chars.
    #
    # Starting at the beginning works well for names
    # such as:
    #
    # FANNIN THE FLAMES OF LOVE -> FANNIN

    for word in useful:

        if (
            len(word) >= 4
            and len(word) <= 8
        ):
            return word

    # Otherwise use the final useful word.

    if len(useful) > 0:
        return useful[
            len(useful) - 1
        ]

    return name


def fit_team_name(
    c,
    name,
    abbrev,
    max_width,
):
    name = name.upper()

    # First choice: full team name.

    if c.text_width(
        name,
        font = "5x7",
    ) <= max_width:

        return [
            name,
            "5x7",
        ]

    if c.text_width(
        name,
        font = "4x5",
    ) <= max_width:

        return [
            name,
            "4x5",
        ]

    # Second choice: smart abbreviation.

    short = smart_short_name(
        name,
        abbrev,
    )

    if c.text_width(
        short,
        font = "5x7",
    ) <= max_width:

        return [
            short,
            "5x7",
        ]

    if c.text_width(
        short,
        font = "4x5",
    ) <= max_width:

        return [
            short,
            "4x5",
        ]

    # Final fallback: progressively clip.

    for length in range(
        len(short),
        0,
        -1,
    ):

        candidate = (
            short[:length]
            + ".."
        )

        if c.text_width(
            candidate,
            font = "4x5",
        ) <= max_width:

            return [
                candidate,
                "4x5",
            ]

    return [
        "?",
        "4x5",
    ]


# ==================================================
# TEAM COMPLETION
# ==================================================

def completion_percent(
    seconds_remaining,
    starter_count,
    live_available,
):
    if not live_available:
        return 0

    starters = number_value(
        starter_count
    )

    if starters <= 0:
        return 0

    remaining = number_value(
        seconds_remaining
    )

    total_seconds = (
        starters * 3600
    )

    completed = (
        total_seconds
        - remaining
    )

    if completed < 0:
        completed = 0

    if completed > total_seconds:
        completed = total_seconds

    pct = (
        completed * 100
    ) // total_seconds

    if pct < 0:
        pct = 0

    if pct > 100:
        pct = 100

    return pct


# ==================================================
# FETCH MFL
# ==================================================

def load_mfl(ctx):
    parsed = parse_league_url(ctx)

    if parsed["error"] != None:
        return {
            "error": parsed["error"],
        }

    host = parsed["host"]
    season = parsed["season"]
    leagueid = parsed["leagueid"]

    week = season_week(
        ctx,
        season,
    )

    base = (
        "https://"
        + host
        + "/"
        + season
        + "/export"
    )

    league_url = (
        base
        + "?TYPE=league"
        + "&L=" + leagueid
        + "&JSON=1"
    )

    schedule_url = (
        base
        + "?TYPE=schedule"
        + "&L=" + leagueid
        + "&W=" + week
        + "&JSON=1"
    )

    live_url = (
        base
        + "?TYPE=liveScoring"
        + "&L=" + leagueid
        + "&W=" + week
        + "&JSON=1"
    )

    league_resp = http.get(
        league_url,
        ttl_seconds = 900,
    )

    if league_resp["status_code"] != 200:

        return {
            "error":
                "LEAGUE "
                + str(
                    league_resp[
                        "status_code"
                    ]
                ),
        }

    if league_resp["json"] == None:

        return {
            "error": "LEAGUE DATA",
        }

    schedule_resp = http.get(
        schedule_url,
        ttl_seconds = 300,
    )

    if schedule_resp["status_code"] != 200:

        return {
            "error":
                "SCHED "
                + str(
                    schedule_resp[
                        "status_code"
                    ]
                ),
        }

    if schedule_resp["json"] == None:

        return {
            "error": "SCHED DATA",
        }

    # Live scoring is optional.
    #
    # If unavailable before the season starts,
    # the rest of the app must still render.

    live_resp = http.get(
        live_url,
        ttl_seconds = 60,
    )

    league_data = (
        league_resp["json"]
    )

    schedule_data = (
        schedule_resp["json"]
    )

    league = league_data[
        "league"
    ]

    league_name = league.get(
        "name",
        "MFL",
    )

    # ==================================================
    # STARTER COUNT
    # ==================================================

    starter_count = "0"

    starters = league.get(
        "starters"
    )

    if starters != None:

        starter_count = starters.get(
            "count",
            "0",
        )

    # ==================================================
    # TEAM INFORMATION
    # ==================================================

    team_names = {}
    team_abbrevs = {}

    franchises = (
        league["franchises"]
        ["franchise"]
    )

    for franchise in franchises:

        fid = franchise["id"]

        team_names[fid] = (
            franchise.get(
                "name",
                fid,
            )
        )

        team_abbrevs[fid] = (
            franchise.get(
                "abbrev"
            )
        )

    # ==================================================
    # LIVE SCORING
    # ==================================================

    live_scores = {}

    live_available = False

    if live_resp["status_code"] == 200:

        live_json = (
            live_resp["json"]
        )

        if live_json != None:

            live_root = (
                live_json.get(
                    "liveScoring"
                )
            )

            if live_root != None:

                live_matchups = (
                    live_root.get(
                        "matchup"
                    )
                )

                if live_matchups != None:

                    for live_matchup in live_matchups:

                        live_teams = (
                            live_matchup[
                                "franchise"
                            ]
                        )

                        for live_team in live_teams:

                            fid = (
                                live_team["id"]
                            )

                            live_scores[fid] = {
                                "score":
                                    live_team.get(
                                        "score"
                                    ),

                                "remaining":
                                    live_team.get(
                                        "gameSecondsRemaining",
                                        "0",
                                    ),
                            }

                    live_available = True

    # ==================================================
    # WEEKLY MATCHUPS
    # ==================================================

    schedule = schedule_data.get(
        "schedule"
    )

    if schedule == None:

        return {
            "error": "NO SCHEDULE",
        }

    weekly = schedule.get(
        "weeklySchedule"
    )

    if weekly == None:

        return {
            "error": "NO WEEK",
        }

    raw_matchups = weekly.get(
        "matchup"
    )

    if raw_matchups == None:

        return {
            "error": "NO MATCHUPS",
        }

    matchups = []

    for matchup in raw_matchups:

        teams = matchup[
            "franchise"
        ]

        away = None
        home = None

        for team in teams:

            fid = team["id"]

            if team.get(
                "isHome",
                "0",
            ) == "1":

                home = fid

            else:

                away = fid

        if (
            away != None
            and home != None
        ):

            total_seconds = (
                number_value(
                    starter_count
                )
                * 3600
            )

            away_score = None
            home_score = None

            away_remaining = (
                total_seconds
            )

            home_remaining = (
                total_seconds
            )

            if live_scores.get(
                away
            ) != None:

                away_score = (
                    live_scores[away][
                        "score"
                    ]
                )

                away_remaining = (
                    live_scores[away][
                        "remaining"
                    ]
                )

            if live_scores.get(
                home
            ) != None:

                home_score = (
                    live_scores[home][
                        "score"
                    ]
                )

                home_remaining = (
                    live_scores[home][
                        "remaining"
                    ]
                )

            away_pct = (
                completion_percent(
                    away_remaining,
                    starter_count,
                    live_available,
                )
            )

            home_pct = (
                completion_percent(
                    home_remaining,
                    starter_count,
                    live_available,
                )
            )

            matchups.append({
                "away":
                    team_names.get(
                        away,
                        away,
                    ),

                "away_abbrev":
                    team_abbrevs.get(
                        away
                    ),

                "away_score":
                    away_score,

                "away_pct":
                    away_pct,

                "home":
                    team_names.get(
                        home,
                        home,
                    ),

                "home_abbrev":
                    team_abbrevs.get(
                        home
                    ),

                "home_score":
                    home_score,

                "home_pct":
                    home_pct,
            })

    return {
        "error": None,
        "league_name":
            league_name,
        "week":
            week,
        "matchups":
            matchups,
    }


# ==================================================
# DRAW ERROR
# ==================================================

def draw_error(c, message):
    c.clear()

    c.text_center(
        "MFL SCORES",
        2,
        font = "5x7",
        color = "amber",
    )

    fitted = fit_team_name(
        c,
        message,
        None,
        62,
    )

    c.text_center(
        fitted[0],
        16,
        font = fitted[1],
        color = "red",
    )


# ==================================================
# DRAW MATCHUP
# ==================================================

def draw_matchup(
    c,
    ctx,
    matchup_index,
):
    c.clear()

    data = load_mfl(ctx)

    if data["error"] != None:

        draw_error(
            c,
            data["error"],
        )

        return

    matchups = data[
        "matchups"
    ]

    if matchup_index >= len(
        matchups
    ):

        c.text_center(
            "NO MATCHUP",
            12,
            font = "5x7",
            color = "gray",
        )

        return

    matchup = matchups[
        matchup_index
    ]

    # ==================================================
    # HEADER
    # ==================================================

    header = (
        data[
            "league_name"
        ].upper()
        + " W"
        + data["week"]
    )

    fitted_header = (
        fit_team_name(
            c,
            header,
            None,
            62,
        )
    )

    c.text_center(
        fitted_header[0],
        0,
        font =
            fitted_header[1],
        color = "amber",
    )

    # ==================================================
    # COLUMNS
    # ==================================================

    team_left = 1
    team_width = 38
    score_right = 63

    # ==================================================
    # AWAY TEAM
    # ==================================================

    away_fit = fit_team_name(
        c,
        matchup["away"],
        matchup[
            "away_abbrev"
        ],
        team_width,
    )

    c.text(
        away_fit[0],
        team_left,
        9,
        font = away_fit[1],
        color = "white",
    )

    c.text(
        format_score(
            matchup[
                "away_score"
            ]
        ),
        score_right,
        8,
        font = "5x7",
        color = "green",
        align = "right",
    )

    # ==================================================
    # HOME TEAM
    # ==================================================

    home_fit = fit_team_name(
        c,
        matchup["home"],
        matchup[
            "home_abbrev"
        ],
        team_width,
    )

    c.text(
        home_fit[0],
        team_left,
        19,
        font = home_fit[1],
        color = "white",
    )

    c.text(
        format_score(
            matchup[
                "home_score"
            ]
        ),
        score_right,
        18,
        font = "5x7",
        color = "green",
        align = "right",
    )

    # ==================================================
    # COMPLETION %
    # ==================================================

    away_pct = (
        str(
            matchup[
                "away_pct"
            ]
        )
        + "%"
    )

    home_pct = (
        str(
            matchup[
                "home_pct"
            ]
        )
        + "%"
    )

    # Left team's percentage

    c.text(
        away_pct,
        7,
        27,
        font = "4x5",
        color = "gray",
    )

    # Right team's percentage

    c.text(
        home_pct,
        43,
        27,
        font = "4x5",
        color = "gray",
    )


# ==================================================
# PAGES
# ==================================================

def game1(c, ctx):
    draw_matchup(
        c,
        ctx,
        0,
    )


def game2(c, ctx):
    draw_matchup(
        c,
        ctx,
        1,
    )


def game3(c, ctx):
    draw_matchup(
        c,
        ctx,
        2,
    )


def game4(c, ctx):
    draw_matchup(
        c,
        ctx,
        3,
    )


def game5(c, ctx):
    draw_matchup(
        c,
        ctx,
        4,
    )


def game6(c, ctx):
    draw_matchup(
        c,
        ctx,
        5,
    )