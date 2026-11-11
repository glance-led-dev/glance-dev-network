

def main(c, ctx):
    userid = ctx.inputs.get("userid", "1394055510503735296")
    c.clear()
    c.text_center("FANTASY FOOTBALL", 1, font="6x8", color="green")
    c.text_center("SKOKIE FRESHMAN", 12, font="5x7", color="white")
    c.text_center("SLEEPER LIVE TRACKER", 23, font="4x5", color="yellow")

def starters1(c, ctx):
    c.fill("black")
    c.text_center("STARTERS1", 12, font="6x8", color="green")


def starters1(c, ctx):
    c.clear()

    resp = http.get("https://api.sleeper.app/v1/state/nfl")

    if resp["status_code"] != 200:
        c.text_center("SLEEPER ERROR", 12, font="5x7", color="red")
        return

    week = resp["json"].get("week", 10)
    season = resp["json"].get("season", "2026")

    players = [
        ("DAK PRESCOTT", "13276"),
        ("DERRICK HENRY", "3198"),
        ("AARON JONES", "8131"),
    ]

    c.text("PLAYERS", 1, 1, font="4x5", color="green")
    c.text("PTS", 103, 1, font="4x5", color="green")

    y = 10

    for name, player_id in players:
        stats_resp = http.get(
            "https://api.sleeper.com/stats/nfl/player/" + player_id,
            params={
                "season": str(season),
                "season_type": "regular",
                "grouping": "week"
            }
        )

        points = 0

        if stats_resp["status_code"] == 200:
            week_data = stats_resp["json"].get(str(week), {})
            if week_data != None:
                player_stats = week_data.get("stats", {})
                if player_stats != None:
                    points = player_stats.get("pts_ppr", 0)

        c.text(name, 1, y, font="4x5", color="white")
        c.text(str(points), 103, y, font="4x5", color="yellow")

        y = y + 8


def starters2(c, ctx):
    c.fill("black")
    c.text_center("STARTERS2", 12, font="6x8", color="green")

def starters2(c, ctx):
    c.clear()

    resp = http.get("https://api.sleeper.app/v1/state/nfl")

    if resp["status_code"] != 200:
        c.text_center("SLEEPER ERROR", 12, font="5x7", color="red")
        return

    week = resp["json"].get("week", 10)
    season = resp["json"].get("season", "2026")

    players = [
        ("RACHAAD WHITE", "2747"),
        ("OMAR COOPER", "3294"),
        ("JORDYN TYSON", "4199"),
    ]

    c.text("PLAYERS", 1, 1, font="4x5", color="green")
    c.text("PTS", 103, 1, font="4x5", color="green")

    y = 10

    for name, player_id in players:
        stats_resp = http.get(
            "https://api.sleeper.com/stats/nfl/player/" + player_id,
            params={
                "season": str(season),
                "season_type": "regular",
                "grouping": "week"
            }
        )

        points = 0

        if stats_resp["status_code"] == 200:
            week_data = stats_resp["json"].get(str(week), {})
            if week_data != None:
                player_stats = week_data.get("stats", {})
                if player_stats != None:
                    points = player_stats.get("pts_ppr", 0)

        c.text(name, 1, y, font="4x5", color="white")
        c.text(str(points), 103, y, font="4x5", color="yellow")

        y = y + 8



def starters3(c, ctx):
    c.clear()

    resp = http.get("https://api.sleeper.app/v1/state/nfl")

    if resp["status_code"] != 200:
        c.text_center("SLEEPER ERROR", 12, font="5x7", color="red")
        return

    week = resp["json"].get("week", 10)
    season = resp["json"].get("season", "2026")
    
    stats_resp = http.get(
    "https://api.sleeper.app/v1/stats/nfl/regular/"
    + str(season) + "/" + str(week)
)
    if stats_resp["status_code"] != 200:
        c.text_center("STATS ERROR", 12, font="5x7", color="red")
        return

    all_stats = stats_resp["json"]

    players = [
        ("ISAIAH LIKELY", "8136"),
        ("JASON MYERS", "13281"),
        ("SF 49ERS DEF", "TEAM_SF"),
    ]

    c.text("PLAYERS", 1, 1, font="4x5", color="green")
    c.text("PTS", 103, 1, font="4x5", color="green")

    y = 8

    for name, player_id in players:
        player_data = all_stats.get(player_id, {})

        if player_data == None:
            player_data = {}

        player_stats = player_data.get("stats", player_data)

        if player_stats == None:
            player_stats = {}

        points = player_stats.get("pts_ppr", 0)

        c.text(name, 1, y, font="4x5", color="white")
        c.text(str(points), 103, y, font="4x5", color="yellow")

        y = y + 8

def scoreboard(c, ctx):
    c.fill("black")
    c.text_center("SCOREBOARD", 12, font="6x8", color="green")

def scoreboard(c, ctx):
    c.clear()

    league_id = ctx.inputs.get("leagueid", "")

    if not league_id:
        c.text_center("MISSING LEAGUE ID", 12, font="5x7", color="red")
        return

    resp = http.get("https://api.sleeper.app/v1/state/nfl")

    if resp["status_code"] != 200:
        c.text_center("SLEEPER ERROR", 12, font="5x7", color="red")
        return

    week = resp["json"].get("week", 0)

    match = http.get(
        "https://api.sleeper.app/v1/league/" + league_id + "/matchups/" + str(week)
    )

    if match["status_code"] != 200:
        c.text_center("MATCHUP ERROR", 12, font="5x7", color="red")
        return

    my_matchup = None
    opponent = None

    for team in match["json"]:
        if team.get("roster_id") == 6:
            my_matchup = team

    if my_matchup != None:
        for team in match["json"]:
            if team.get("matchup_id") == my_matchup.get("matchup_id") and team.get("roster_id") != 6:
                opponent = team

    if my_matchup == None or opponent == None:
        c.text_center("NO MATCHUP", 12, font="5x7", color="red")
        return

    rosters_resp = http.get(
        "https://api.sleeper.app/v1/league/" + league_id + "/rosters"
    )
    users_resp = http.get(
        "https://api.sleeper.app/v1/league/" + league_id + "/users"
    )

    if rosters_resp["status_code"] != 200 or users_resp["status_code"] != 200:
        c.text_center("TEAM NAME ERROR", 12, font="5x7", color="red")
        return

    opponent_owner = ""

    for roster in rosters_resp["json"]:
        if roster.get("roster_id") == opponent.get("roster_id"):
            opponent_owner = roster.get("owner_id", "")

    opponent_name = "OPPONENT"

    for user in users_resp["json"]:
        if user.get("user_id") == opponent_owner:
            metadata = user.get("metadata", {})
            if metadata != None:
                opponent_name = metadata.get(
                    "team_name", user.get("display_name", "OPPONENT")
                )
            else:
                opponent_name = user.get("display_name", "OPPONENT")

    c.text_center("SKOKIE FRESHMAN", 1, font="5x7", color="green")
    c.text_center(str(my_matchup.get("points", 0)), 9, font="10x16", color="white")
    c.text_center(
        "VS " + str(opponent_name) + " " + str(opponent.get("points", 0)),
        26,
        font="4x5",
        color="yellow"
    )
