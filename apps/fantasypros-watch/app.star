def main(c, ctx):
    response = http.get(
        "https://www.rotowire.com/myleagues/api/nfl/get-matchup-analysis.php?leagueID=390883&teamID=10&week=1",
        ttl_seconds=60,
    )

    data = json.decode(response["body"])
    matchup = data["matchupInfo"]

    c.fill("black")

    c.text_center(
        "LA ONDA " + str(matchup["teamFpts"]),
        3,
        font="6x8",
        color="green",
    )

    c.text_center(
        "VS " + matchup["oppTeamName"] + " " + str(matchup["oppTeamFpts"]),
        13,
        font="5x7",
        color="white",
    )

    c.text_center(
        "WIN " + str(matchup["teamWinPercentage"]) + "%",
        23,
        font="5x7",
        color="yellow",
    )