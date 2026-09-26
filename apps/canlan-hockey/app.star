# Canlan Hockey
# Make The Call - Friday 18+ D
# 192x32
# 12-player capacity

API_URL = "https://canlan-api-test.mdarpino.workers.dev/"

BLACK = "black"
WHITE = "white"
GRAY = "#888888"
GREEN = "#42E66C"
YELLOW = "#FFD84D"
BLUE = "#55A7FF"

TEAM_ID = "sYN03kWZcfswcNhy"


# =========================================================
# DATA
# =========================================================

def fetch_data():
    r = http.get(
        API_URL,
        ttl_seconds = 300
    )

    if r["status_code"] != 200:
        return None

    data = r["json"]

    if data == None:
        return None

    if not data.get("ok", False):
        return None

    return data


# =========================================================
# HELPERS
# =========================================================

def fit_text(c, text, fonts, maxw):
    text = str(text).upper()

    for font in fonts:
        if c.text_width(text, font = font) <= maxw:
            return text, font

    font = fonts[-1]

    for n in range(len(text), 0, -1):
        candidate = text[:n]

        if c.text_width(candidate, font = font) <= maxw:
            return candidate, font

    return "", font


def no_data(c, title):
    c.fill(BLACK)

    c.text(
        title,
        2,
        1,
        font = "5x7",
        color = GREEN
    )

    c.text_center(
        "NO DATA",
        13,
        font = "6x8",
        color = WHITE
    )

    c.text_center(
        "TRY AGAIN LATER",
        24,
        font = "4x5",
        color = GRAY
    )


# =========================================================
# PAGE 1 - NEXT GAME
# =========================================================

def schedule(c, ctx):
    data = fetch_data()

    if data == None:
        no_data(c, "NEXT GAME")
        return

    game = data.get("next_game")

    c.fill(BLACK)

    c.text(
        "NEXT GAME",
        3,
        1,
        font = "5x7",
        color = GREEN
    )

    c.text(
        "FRIDAY 18+ D",
        189,
        2,
        font = "4x5",
        color = GRAY,
        align = "right"
    )

    if not game:
        c.text_center(
            "NO UPCOMING GAME",
            13,
            font = "6x8",
            color = WHITE
        )

        c.text_center(
            "CHECK BACK LATER",
            24,
            font = "4x5",
            color = GRAY
        )

        return

    opponent = str(
        game.get("opponent", "")
    ).upper()

    home = game.get(
        "make_the_call_home",
        False
    )

    if home:
        matchup = "MAKE THE CALL VS " + opponent
    else:
        matchup = "MAKE THE CALL AT " + opponent

    matchup_text, matchup_font = fit_text(
        c,
        matchup,
        ["6x8", "5x7", "4x5"],
        186
    )

    c.text_center(
        matchup_text,
        11,
        font = matchup_font,
        color = WHITE
    )

    date_label = str(
        game.get("local_date_label", "")
    ).upper()

    time_label = str(
        game.get("local_time", "")
    ).upper()

    detail = date_label

    if time_label:
        if detail:
            detail = detail + "  "

        detail = detail + time_label

    c.text(
        detail,
        3,
        24,
        font = "5x7",
        color = YELLOW
    )

    location = str(
        game.get("location", "")
    ).upper()

    if "YORK" in location:
        location = "YORK"

    if not location:
        location = str(
            game.get("city", "")
        ).upper()

    location_text, location_font = fit_text(
        c,
        location,
        ["5x7", "4x5"],
        45
    )

    c.text(
        location_text,
        189,
        24,
        font = location_font,
        color = GRAY,
        align = "right"
    )


# =========================================================
# STANDINGS
# =========================================================

def standing_row(c, row, rank, y):
    name = str(
        row.get("team", "")
    ).upper()

    wins = str(
        row.get("w", 0)
    )

    losses = str(
        row.get("l", 0)
    )

    otl = row.get(
        "otl",
        0
    )

    points = str(
        row.get("pts", 0)
    )

    color = WHITE

    if row.get("team_id", "") == TEAM_ID:
        color = YELLOW

    record = wins + "-" + losses

    if otl > 0:
        record = record + "-" + str(otl)

    # Rank
    c.text(
        str(rank),
        2,
        y,
        font = "4x5",
        color = GRAY
    )

    # Full team name
    name_text, name_font = fit_text(
        c,
        name,
        ["4x5"],
        112
    )

    c.text(
        name_text,
        13,
        y,
        font = name_font,
        color = color
    )

    # Record
    c.text(
        record,
        153,
        y,
        font = "4x5",
        color = color,
        align = "right"
    )

    # Points
    c.text(
        points + " PTS",
        190,
        y,
        font = "4x5",
        color = color,
        align = "right"
    )


def standings_block(c, data, start):
    rows = data.get(
        "standings",
        []
    )

    c.fill(BLACK)

    c.text(
        "STANDINGS",
        2,
        0,
        font = "4x5",
        color = GREEN
    )

    c.text(
        "W-L   PTS",
        190,
        0,
        font = "4x5",
        color = GRAY,
        align = "right"
    )

    positions = [7, 13, 19, 25]

    for i in range(4):
        index = start + i

        if index < len(rows):
            standing_row(
                c,
                rows[index],
                index + 1,
                positions[i]
            )


# =========================================================
# PAGE 2 - STANDINGS 1-4
# =========================================================

def standings_1(c, ctx):
    data = fetch_data()

    if data == None:
        no_data(c, "STANDINGS")
        return

    standings_block(
        c,
        data,
        0
    )


# =========================================================
# PAGE 3 - STANDINGS 5-8
# =========================================================

def standings_2(c, ctx):
    data = fetch_data()

    if data == None:
        no_data(c, "STANDINGS")
        return

    standings_block(
        c,
        data,
        4
    )


# =========================================================
# PLAYER STATS
# 4 players/page
# 3 pages = 12 players
# =========================================================

def player_row(c, player, y):
    name = str(
        player.get("name", "")
    ).upper()

    goals = str(
        player.get("goals", 0)
    )

    assists = str(
        player.get("assists", 0)
    )

    points = str(
        player.get("points", 0)
    )

    name_text, name_font = fit_text(
        c,
        name,
        ["4x5"],
        123
    )

    c.text(
        name_text,
        2,
        y,
        font = name_font,
        color = WHITE
    )

    c.text(
        goals,
        143,
        y,
        font = "4x5",
        color = YELLOW,
        align = "center"
    )

    c.text(
        assists,
        166,
        y,
        font = "4x5",
        color = BLUE,
        align = "center"
    )

    c.text(
        points,
        189,
        y,
        font = "4x5",
        color = GREEN,
        align = "center"
    )


def players_block(c, data, start):
    players = data.get(
        "players",
        []
    )

    c.fill(BLACK)

    # Header
    c.text(
        "MAKE THE CALL",
        2,
        0,
        font = "4x5",
        color = GREEN
    )

    c.text(
        "G",
        143,
        0,
        font = "4x5",
        color = GRAY,
        align = "center"
    )

    c.text(
        "A",
        166,
        0,
        font = "4x5",
        color = GRAY,
        align = "center"
    )

    c.text(
        "P",
        189,
        0,
        font = "4x5",
        color = GRAY,
        align = "center"
    )

    # Four comfortably spaced player rows
    positions = [7, 13, 19, 25]

    for i in range(4):
        index = start + i

        if index < len(players):
            player_row(
                c,
                players[index],
                positions[i]
            )


# =========================================================
# PAGE 4 - PLAYERS 1-4
# =========================================================

def players_1(c, ctx):
    data = fetch_data()

    if data == None:
        no_data(c, "PLAYER STATS")
        return

    players_block(
        c,
        data,
        0
    )


# =========================================================
# PAGE 5 - PLAYERS 5-8
# =========================================================

def players_2(c, ctx):
    data = fetch_data()

    if data == None:
        no_data(c, "PLAYER STATS")
        return

    players_block(
        c,
        data,
        4
    )


# =========================================================
# PAGE 6 - PLAYERS 9-12
# =========================================================

def players_3(c, ctx):
    data = fetch_data()

    if data == None:
        no_data(c, "PLAYER STATS")
        return

    players_block(
        c,
        data,
        8
    )