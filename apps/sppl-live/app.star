FEED_URL = "https://sppl.wtf/api/glance/data"
BG = "#06101D"
GOLD = "#C8A84B"
WHITE = "#FFFFFF"
MUTED = "#8EA0B8"
LINE = "#24364D"
BADGE = "#16314E"

TEAM_LOGOS = {
    "DPH": "team-dph.png",
    "FIG": "team-fig.png",
    "LONG": "team-long.png",
    "PP": "team-pp.png",
    "RHCP": "team-rhcp.png",
    "TPOD": "team-tpod.png",
}


def _feed():
    resp = http.get(FEED_URL, ttl_seconds = 60)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    data = resp["json"]
    if data.get("league") != "SPPL":
        return None
    return data


def _shell(c, section, meta):
    c.fill(BG)
    c.rect(0, 0, 46, 31, fill = "#030A12", outline = GOLD)
    c.image("sppl-shield.png", 2, 2, w = 42, h = 29)
    c.text(section, 49, 1, font = "4x5", color = GOLD)
    c.text(meta, 382, 1, font = "4x5", color = MUTED, align = "right")


def _badge(c, team, x, y, size):
    asset = TEAM_LOGOS.get(team)
    if asset != None:
        c.image(asset, x, y, w = size, h = size)
        return
    c.fill_circle(x + size // 2, y + size // 2, size // 2, BADGE)
    c.circle(x + size // 2, y + size // 2, size // 2, GOLD)
    label = team
    if len(label) > 2:
        label = label[:2]
    c.text(label, x + size // 2, y + size // 2 - 3, font = "4x5", color = WHITE, align = "center")


def _error(c, label):
    _shell(c, label, "")
    c.text("FEED TEMPORARILY UNAVAILABLE", 216, 11, font = "6x8", color = GOLD, align = "center")


def _score_page(c, start):
    data = _feed()
    if data == None:
        _error(c, "LIVE SCORES")
        return
    scores = data.get("scores", [])
    week = data.get("week", 1)
    _shell(c, "LIVE SCORES", "W" + str(week))
    if len(scores) <= start:
        c.text("WEEK " + str(week) + " MATCHUPS AWAITING DATA", 216, 11, font = "6x8", color = GOLD, align = "center")
        return
    left = 48
    block = 84
    for i in range(4):
        pos = start + i
        if pos >= len(scores):
            break
        game = scores[pos]
        x = left + i * block
        if i > 0:
            c.vline(x, 7, 30, color = LINE)
        away = str(game.get("away", "---"))
        home = str(game.get("home", "---"))
        _badge(c, away, x + 2, 7, 11)
        _badge(c, home, x + 2, 20, 11)
        c.text(away, x + 16, 9, font = "4x5", color = MUTED)
        c.text(home, x + 16, 22, font = "4x5", color = MUTED)
        c.text(str(game.get("awayScore", 0)), x + 79, 7, font = "5x7b", color = WHITE, align = "right")
        c.text(str(game.get("homeScore", 0)), x + 79, 20, font = "5x7b", color = WHITE, align = "right")


def _standings_page(c, start):
    data = _feed()
    if data == None:
        _error(c, "STANDINGS")
        return
    standings = data.get("standings", [])
    _shell(c, "STANDINGS", "2026")
    if len(standings) <= start:
        c.text("STANDINGS AWAITING RESULTS", 216, 11, font = "6x8", color = GOLD, align = "center")
        return
    left = 48
    block = 84
    for i in range(4):
        pos = start + i
        if pos >= len(standings):
            break
        team = standings[pos]
        x = left + i * block
        if i > 0:
            c.vline(x, 7, 30, color = LINE)
        label = str(team.get("team", "---"))
        _badge(c, label, x + 3, 7, 23)
        c.text("#" + str(team.get("rank", pos + 1)) + " " + label, x + 30, 8, font = "4x5", color = GOLD)
        record = str(team.get("wins", 0)) + "-" + str(team.get("losses", 0))
        ties = team.get("ties", 0)
        if ties:
            record += "-" + str(ties)
        c.text(record, x + 30, 15, font = "5x7b", color = WHITE)
        c.text(str(team.get("pointsFor", 0)) + " PF", x + 30, 25, font = "picopixel", color = MUTED)


def scores_one(c, ctx):
    _score_page(c, 0)


def scores_two(c, ctx):
    _score_page(c, 4)


def standings_one(c, ctx):
    _standings_page(c, 0)


def standings_two(c, ctx):
    _standings_page(c, 4)


def standings_three(c, ctx):
    _standings_page(c, 8)


def standings_four(c, ctx):
    _standings_page(c, 12)
