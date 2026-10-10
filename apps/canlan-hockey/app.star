# Canlan Hockey
# Public ASHL team schedule + division standings
# 192x32

API_URL = "https://canlan-public-worker.mdarpino.workers.dev/api/team?v=6"

BLACK = "black"
WHITE = "white"
GRAY = "#888888"
GREEN = "#42E66C"
YELLOW = "#FFD84D"



def make_demo_logo(primary, secondary, variant):
    pixels = []

    for y in range(16):
        for x in range(16):
            dx = x - 7
            dy = y - 7
            color = ""

            if dx * dx + dy * dy <= 45:
                color = primary

            if variant == 0:
                if x == 7 or y == 7 or x == y or x + y == 14:
                    if x >= 3 and x <= 11 and y >= 3 and y <= 11:
                        color = secondary
            else:
                if (x == y and x >= 3 and x <= 11) or \
                   (x + y == 14 and x >= 3 and x <= 11):
                    color = secondary

            if color:
                pixels.append([x, y, color])

    return {"pixels": pixels}


def demo_stats(wins, losses, otl, points):
    return [
        {"abbr": "W", "value": wins},
        {"abbr": "L", "value": losses},
        {"abbr": "OTL", "value": otl},
        {"abbr": "PTS", "value": points},
    ]


def demo_standing(team_id, name, wins, losses, otl, points):
    return {
        "team": {
            "id": team_id,
            "name": name,
            "name_full": name,
        },
        "schedule": {
            "name": "ADULT SAFE HOCKEY LEAGUE",
        },
        "stats": demo_stats(wins, losses, otl, points),
    }


def demo_player(name, number, goals, assists):
    return {
        "name": name,
        "number": number,
        "goals": goals,
        "assists": assists,
        "points": goals + assists,
    }


def demo_data():
    return {
        "ok": True,
        "team": "demo-home",
        "logos": {
            "demo-home": make_demo_logo("#1261A0", "#FFFFFF", 0),
            "demo-away": make_demo_logo("#9B1C31", "#FFD84D", 1),
        },
        "games": {
            "data": [
                {
                    "game_status_id": 1,
                    "homeTeam": {
                        "id": "demo-home",
                        "name": "ICE WOLVES",
                        "name_full": "ICE WOLVES",
                    },
                    "visitingTeam": {
                        "id": "demo-away",
                        "name": "REDLINE",
                        "name_full": "REDLINE",
                    },
                    "facility": {
                        "name": "CANLAN SPORTS",
                    },
                    "venue": {
                        "name_full": "RINK 2",
                    },
                    "local_date_label": "SAT OCT 17",
                    "local_time": "8:15 PM",
                },
            ],
        },
        "standings": {
            "data": [
                demo_standing("demo-home", "ICE WOLVES", 8, 1, 1, 17),
                demo_standing("demo2", "NORTH STARS", 7, 2, 1, 15),
                demo_standing("demo3", "BREAKAWAY", 6, 3, 1, 13),
                demo_standing("demo4", "TOP SHELF", 6, 4, 0, 12),
                demo_standing("demo5", "BLUE LINE", 5, 4, 1, 11),
                demo_standing("demo6", "PUCK DYNASTY", 4, 5, 1, 9),
                demo_standing("demo7", "FIVE HOLE", 3, 6, 1, 7),
                demo_standing("demo8", "BENCH WARMERS", 2, 8, 0, 4),
            ],
        },
        "players": [
            demo_player("ALEX CARTER", 91, 12, 15),
            demo_player("RYAN MILLER", 19, 10, 14),
            demo_player("CHRIS MARTIN", 27, 9, 13),
            demo_player("MATT WILSON", 11, 8, 12),
            demo_player("JASON LEE", 88, 7, 11),
            demo_player("MIKE TURNER", 16, 6, 11),
            demo_player("DAN ROSS", 24, 7, 9),
            demo_player("ERIC YOUNG", 44, 5, 10),
            demo_player("ADAM KING", 9, 6, 8),
            demo_player("STEVE HALL", 22, 4, 9),
            demo_player("NICK BROWN", 17, 5, 7),
            demo_player("MARK DAVIS", 55, 3, 8),
            demo_player("KEVIN WHITE", 14, 4, 6),
            demo_player("PAUL GREEN", 33, 3, 6),
            demo_player("TOM CLARK", 7, 2, 6),
            demo_player("SAM WALKER", 18, 2, 5),
        ],
    }

def fetch_data(ctx):
    ashlurl = ctx.inputs.get("ashlurl", "")

    if not ashlurl:
        return demo_data()

    # Refresh and HTTP cache are intentionally both 8 hours.
    r = http.get(
        API_URL,
        params = {
            "url": ashlurl,
        },
        ttl_seconds = 28800,
    )

    if r["status_code"] != 200:
        return None

    data = r["json"]

    if data == None:
        return None

    if not data.get("ok", False):
        return None

    return data


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
        color = GREEN,
    )

    c.text_center(
        "ADD ASHL TEAM URL",
        13,
        font = "5x7",
        color = WHITE,
    )

    c.text_center(
        "CHECK APP SETTINGS",
        24,
        font = "4x5",
        color = GRAY,
    )


def stat_value(row, abbr):
    for stat in row.get("stats", []):
        if stat.get("abbr", "") == abbr:
            return stat.get("value", 0)

    return 0


def division_name(data):
    rows = data.get("standings", {}).get("data", [])

    if len(rows) > 0:
        return str(
            rows[0].get("schedule", {}).get("name", "")
        ).upper()

    return ""


def next_game(data):
    games = data.get("games", {}).get("data", [])
    team_id = data.get("team", "")

    for game in games:
        home = game.get("homeTeam", {})
        away = game.get("visitingTeam", {})

        involved = (
            home.get("id", "") == team_id or
            away.get("id", "") == team_id
        )

        if involved and game.get("game_status_id", 0) != 9:
            return game

    return None


# =========================================================
# PAGE 1 - NEXT GAME
# =========================================================

def team_logo_pixels(data, team):
    if data == None or team == None:
        return []

    team_id = str(team.get("id", "") or "")
    if not team_id:
        return []

    logos = data.get("logos", {}) or {}
    logo = logos.get(team_id, {}) or {}
    return logo.get("pixels", []) or []


def has_team_logo(data, team):
    return len(team_logo_pixels(data, team)) > 0


def draw_team_badge(c, data, team, x, y, outline):
    pixels = team_logo_pixels(data, team)

    if not pixels:
        return

    for pixel in pixels:
        if len(pixel) < 3:
            continue

        px = pixel[0]
        py = pixel[1]
        value = pixel[2]

        if px < 0 or px >= 16 or py < 0 or py >= 16:
            continue

        scaled_x = (px * 3) // 4
        scaled_y = (py * 3) // 4

        c.pixel(
            x + scaled_x,
            y + scaled_y,
            value,
        )


def schedule(c, ctx):
    data = fetch_data(ctx)

    if data == None:
        no_data(c, "CANLAN")
        return

    c.fill(BLACK)

    c.text(
        "NEXT GAME",
        3,
        1,
        font = "5x7",
        color = GREEN,
    )

    division = division_name(data)
    division_text, division_font = fit_text(
        c,
        division,
        ["4x5"],
        80,
    )

    c.text(
        division_text,
        189,
        2,
        font = division_font,
        color = GRAY,
        align = "right",
    )

    game = next_game(data)

    if game == None:
        c.text_center(
            "NO UPCOMING GAME",
            13,
            font = "6x8",
            color = WHITE,
        )

        c.text_center(
            "CHECK BACK LATER",
            24,
            font = "4x5",
            color = GRAY,
        )

        return

    team_id = data.get("team", "")
    home = game.get("homeTeam", {})
    away = game.get("visitingTeam", {})

    if home.get("id", "") == team_id:
        team_obj = home
        opponent_obj = away
        team_name = home.get("name_full", home.get("name", ""))
        opponent = away.get("name_full", away.get("name", ""))
        matchup = str(team_name) + " VS " + str(opponent)
    else:
        team_obj = away
        opponent_obj = home
        team_name = away.get("name_full", away.get("name", ""))
        opponent = home.get("name_full", home.get("name", ""))
        matchup = str(team_name) + " AT " + str(opponent)

    relation = "VS"

    if home.get("id", "") != team_id:
        relation = "AT"

    row_logo_y = 10
    row_text_y = 12
    row_relation_y = 13

    logo_size = 12
    logo_gap = 3

    left_start = 2
    left_end = 86
    right_start = 106
    right_end = 190

    left_slot_width = left_end - left_start + 1
    right_slot_width = right_end - right_start + 1

    team_has_logo = has_team_logo(data, team_obj)
    opponent_has_logo = has_team_logo(data, opponent_obj)

    team_text, team_font = fit_text(
        c,
        str(team_name),
        ["6x8", "5x7", "4x5"],
        80,
    )

    opponent_text, opponent_font = fit_text(
        c,
        str(opponent),
        ["6x8", "5x7", "4x5"],
        80,
    )

    team_text_width = c.text_width(
        team_text,
        font = team_font,
    )

    opponent_text_width = c.text_width(
        opponent_text,
        font = opponent_font,
    )

    team_block_width = team_text_width
    if team_has_logo:
        team_block_width = team_block_width + logo_size + logo_gap

    opponent_block_width = opponent_text_width
    if opponent_has_logo:
        opponent_block_width = opponent_block_width + logo_size + logo_gap

    team_block_x = left_start + max(
        0,
        (left_slot_width - team_block_width) // 2,
    )

    opponent_block_x = right_start + max(
        0,
        (right_slot_width - opponent_block_width) // 2,
    )

    if team_has_logo:
        draw_team_badge(
            c,
            data,
            team_obj,
            team_block_x,
            row_logo_y,
            GREEN,
        )

        c.text(
            team_text,
            team_block_x + logo_size + logo_gap,
            row_text_y,
            font = team_font,
            color = WHITE,
        )
    else:
        c.text(
            team_text,
            team_block_x,
            row_text_y,
            font = team_font,
            color = WHITE,
        )

    c.text_center(
        relation,
        row_relation_y,
        font = "4x5",
        color = GRAY,
    )

    if opponent_has_logo:
        draw_team_badge(
            c,
            data,
            opponent_obj,
            opponent_block_x,
            row_logo_y,
            GRAY,
        )

        c.text(
            opponent_text,
            opponent_block_x + logo_size + logo_gap,
            row_text_y,
            font = opponent_font,
            color = WHITE,
        )
    else:
        c.text(
            opponent_text,
            opponent_block_x,
            row_text_y,
            font = opponent_font,
            color = WHITE,
        )
    facility = str(
        game.get("facility", {}).get("name", "")
    ).upper()

    venue = str(
        game.get("venue", {}).get("name_full", "")
    ).upper()

    location = facility

    if not location:
        location = venue

    location_text, location_font = fit_text(
        c,
        location,
        ["5x7", "4x5"],
        100,
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

    detail_text, detail_font = fit_text(
        c,
        detail,
        ["5x7", "4x5"],
        130,
    )

    c.text(
        detail_text,
        3,
        24,
        font = detail_font,
        color = YELLOW,
    )

    c.text(
        location_text,
        189,
        24,
        font = location_font,
        color = GRAY,
        align = "right",
    )


# =========================================================
# STANDINGS
# =========================================================

def standing_row(c, row, rank, y, selected_team_id):
    team = row.get("team", {})

    name = str(
        team.get("name_full", team.get("name", ""))
    ).upper()

    wins = str(stat_value(row, "W"))
    losses = str(stat_value(row, "L"))
    otl = stat_value(row, "OTL")
    points = str(stat_value(row, "PTS"))

    color = WHITE

    if team.get("id", "") == selected_team_id:
        color = YELLOW

    record = wins + "-" + losses

    if otl > 0:
        record = record + "-" + str(otl)

    c.text(
        str(rank),
        2,
        y,
        font = "4x5",
        color = GRAY,
    )

    name_text, name_font = fit_text(
        c,
        name,
        ["4x5"],
        112,
    )

    c.text(
        name_text,
        13,
        y,
        font = name_font,
        color = color,
    )

    c.text(
        record,
        153,
        y,
        font = "4x5",
        color = color,
        align = "right",
    )

    c.text(
        points + " PTS",
        190,
        y,
        font = "4x5",
        color = color,
        align = "right",
    )


def standings_block(c, data, start):
    rows = data.get("standings", {}).get("data", [])
    selected_team_id = data.get("team", "")

    c.fill(BLACK)

    c.text(
        "STANDINGS",
        2,
        0,
        font = "4x5",
        color = GREEN,
    )

    c.text(
        "W-L   PTS",
        190,
        0,
        font = "4x5",
        color = GRAY,
        align = "right",
    )

    positions = [7, 13, 19, 25]

    for i in range(4):
        index = start + i

        if index < len(rows):
            standing_row(
                c,
                rows[index],
                index + 1,
                positions[i],
                selected_team_id,
            )


def standings_1(c, ctx):
    data = fetch_data(ctx)

    if data == None:
        no_data(c, "STANDINGS")
        return

    standings_block(c, data, 0)


def standings_2(c, ctx):
    data = fetch_data(ctx)

    if data == None:
        no_data(c, "STANDINGS")
        return

    standings_block(c, data, 4)
# =========================================================
# PLAYER STATS
# Four players per page, continuing in Worker order.
# Columns: Goals / Assists / Points
# =========================================================

def player_stat_row(c, player, rank, y):
    name = str(player.get("name", "")).upper()
    number = player.get("number", None)

    if number != None:
        name = name + " #" + str(number)

    name_text, name_font = fit_text(
        c,
        name,
        ["4x5"],
        135,
    )

    c.text(
        str(rank),
        2,
        y,
        font = "4x5",
        color = GRAY,
    )

    c.text(
        name_text,
        13,
        y,
        font = name_font,
        color = WHITE,
    )

    c.text(
        str(player.get("goals", 0)),
        158,
        y,
        font = "4x5",
        color = WHITE,
        align = "right",
    )

    c.text(
        str(player.get("assists", 0)),
        174,
        y,
        font = "4x5",
        color = WHITE,
        align = "right",
    )

    c.text(
        str(player.get("points", 0)),
        190,
        y,
        font = "4x5",
        color = YELLOW,
        align = "right",
    )


def player_stats_block(c, data, start):
    players = data.get("players", [])

    c.fill(BLACK)

    c.text(
        "PLAYER STATS",
        2,
        0,
        font = "4x5",
        color = GREEN,
    )

    c.text(
        "G",
        158,
        0,
        font = "4x5",
        color = GRAY,
        align = "right",
    )

    c.text(
        "A",
        174,
        0,
        font = "4x5",
        color = GRAY,
        align = "right",
    )

    c.text(
        "P",
        190,
        0,
        font = "4x5",
        color = GRAY,
        align = "right",
    )

    if len(players) == 0:
        c.text_center(
            "NO PLAYER STATS",
            13,
            font = "6x8",
            color = WHITE,
        )
        return

    if start >= len(players):
        c.text_center(
            "END OF ROSTER",
            13,
            font = "6x8",
            color = WHITE,
        )
        return

    positions = [7, 13, 19, 25]

    for i in range(4):
        index = start + i

        if index < len(players):
            player_stat_row(
                c,
                players[index],
                index + 1,
                positions[i],
            )


def player_stats_1(c, ctx):
    data = fetch_data(ctx)

    if data == None:
        no_data(c, "PLAYER STATS")
        return

    player_stats_block(c, data, 0)


def player_stats_2(c, ctx):
    data = fetch_data(ctx)

    if data == None:
        no_data(c, "PLAYER STATS")
        return

    player_stats_block(c, data, 4)


def player_stats_3(c, ctx):
    data = fetch_data(ctx)

    if data == None:
        no_data(c, "PLAYER STATS")
        return

    player_stats_block(c, data, 8)


def best_player(players, key):
    if len(players) == 0:
        return None

    best = players[0]
    best_value = best.get(key, 0)

    if best_value == None:
        best_value = 0

    for i in range(1, len(players)):
        player = players[i]
        value = player.get(key, 0)

        if value == None:
            value = 0

        if value > best_value:
            best = player
            best_value = value

    return best


def leader_summary_row(c, label, player, key, y):
    if player == None:
        return

    name = str(player.get("name", "") or "").upper()
    number = player.get("number", None)

    if number != None:
        name = name + " #" + str(number)

    name_text, name_font = fit_text(
        c,
        name,
        ["4x5"],
        118,
    )

    c.text(
        label,
        2,
        y,
        font = "4x5",
        color = GRAY,
    )

    c.text(
        name_text,
        42,
        y,
        font = name_font,
        color = WHITE,
    )

    c.text(
        str(player.get(key, 0)),
        190,
        y,
        font = "4x5",
        color = YELLOW,
        align = "right",
    )


def player_leaders_summary(c, data):
    players = data.get("players", []) or []

    c.fill(BLACK)

    c.text(
        "TEAM LEADERS",
        2,
        0,
        font = "4x5",
        color = GREEN,
    )

    if len(players) == 0:
        c.text_center(
            "NO PLAYER STATS",
            13,
            font = "6x8",
            color = WHITE,
        )
        return

    leader_summary_row(
        c,
        "PTS",
        best_player(players, "points"),
        "points",
        8,
    )

    leader_summary_row(
        c,
        "GOALS",
        best_player(players, "goals"),
        "goals",
        16,
    )

    leader_summary_row(
        c,
        "AST",
        best_player(players, "assists"),
        "assists",
        24,
    )

def player_stats_4(c, ctx):
    data = fetch_data(ctx)

    if data == None:
        no_data(c, "PLAYER STATS")
        return

    players = data.get("players", []) or []

    if len(players) > 12:
        player_stats_block(c, data, 12)
    else:
        player_leaders_summary(c, data)
