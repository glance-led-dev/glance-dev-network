URL = "https://site.api.espn.com/apis/site/v2/sports/football/cfl/scoreboard"


def active_games():
    resp = http.get(URL)

    if resp["status_code"] != 200:
        return []

    games = []

    for e in resp["json"]["events"]:
        if e["status"]["type"]["state"] == "in":
            games.append(e)

    return games


def draw_game(c, index):
    c.clear()

    games = active_games()

    if len(games) == 0:
        c.text("NO LIVE CFL", 2, 6, color="yellow")
        c.text("GAMES", 2, 18, color="yellow")
        return

    if index >= len(games):
        c.text("NO OTHER", 2, 6, color="blue")
        c.text("LIVE GAMES", 2, 18, color="blue")
        return

    game = games[index]

    away = game["competitions"][0]["competitors"][0]
    home = game["competitions"][0]["competitors"][1]

    status = game["status"]["type"]["shortDetail"]

    c.text(
        away["team"]["abbreviation"] + " " + away["score"],
        2,
        2
    )

    c.text(
        home["team"]["abbreviation"] + " " + home["score"],
        2,
        12
    )

    c.text(
        status,
        2,
        22,
        color="yellow"
    )


def game1(c, ctx):
    draw_game(c, 0)


def game2(c, ctx):
    draw_game(c, 1)