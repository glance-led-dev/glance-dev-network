# DESIGN. NHL standings for the conference picked in settings. Each section
# opens on a title card whose NHL shield and conference badge are hand-drawn
# sprite art (pixel-crisp, no downscaled logos), followed by a GP/W/L/OTL/PTS/RW
# table with a team logo and a brand-color rail on every row.

TEAM_LOGOS = {
    # Western Conference
    "ANA": "ducks_glance_tiny.png",
    "CGY": "flames_glance_tiny.png",
    "EDM": "oilers_glance_tiny.png",
    "LAK": "kings_glance_tiny.png",
    "SJS": "sharks_glance_tiny.png",
    "SEA": "kraken_glance_tiny.png",
    "VAN": "canucks_glance_tiny.png",
    "VGK": "golden_knights_glance_tiny.png",
    "CHI": "blackhawks_glance_tiny.png",
    "COL": "avalanche_glance_tiny.png",
    "DAL": "stars_glance_tiny.png",
    "MIN": "wild_glance_tiny.png",
    "NSH": "predators_glance_tiny.png",
    "STL": "blues_glance_tiny.png",
    "UTA": "mammoth_glance_tiny.png",
    "WPG": "jets_glance_tiny.png",
    # Eastern Conference
    "BOS": "bruins_glance_tiny.png",
    "BUF": "sabres_glance_tiny.png",
    "DET": "red_wings_glance_tiny.png",
    "FLA": "panthers_glance_tiny.png",
    "MTL": "canadiens_glance_tiny.png",
    "OTT": "senators_glance_tiny.png",
    "TBL": "lightning_glance_tiny.png",
    "TOR": "maple_leafs_glance_tiny.png",
    "CAR": "hurricanes_glance_tiny.png",
    "CBJ": "blue_jackets_glance_tiny.png",
    "NJD": "devils_glance_tiny.png",
    "NYI": "islanders_glance_tiny.png",
    "NYR": "rangers_glance_tiny.png",
    "PHI": "flyers_glance_tiny.png",
    "PIT": "penguins_glance_tiny.png",
    "WSH": "capitals_glance_tiny.png",
}


TEAM_ACCENTS = {
    # Western Conference
    "ANA": "#F47A38",
    "CGY": "#D2001C",
    "EDM": "#FF4C00",
    "LAK": "#A2AAAD",
    "SJS": "#006D75",
    "SEA": "#68A2B9",
    "VAN": "#00843D",
    "VGK": "#B4975A",
    "CHI": "#CF0A2C",
    "COL": "#6F263D",
    "DAL": "#006847",
    "MIN": "#154734",
    "NSH": "#FFB81C",
    "STL": "#002F87",
    "UTA": "#69B3E7",
    "WPG": "#004C97",
    # Eastern Conference
    "BOS": "#FFB81C",
    "BUF": "#FCB514",
    "DET": "#CE1126",
    "FLA": "#C8102E",
    "MTL": "#AF1E2D",
    "OTT": "#C52032",
    "TBL": "#0057B8",
    "TOR": "#1E5AA8",
    "CAR": "#CE1126",
    "CBJ": "#CE1126",
    "NJD": "#CE1126",
    "NYI": "#F47D30",
    "NYR": "#0038A8",
    "PHI": "#F74902",
    "PIT": "#FCB514",
    "WSH": "#C8102E",
}


# Hand-drawn 21x24 NHL shield: S silver rim and stripes, s bevel, K field,
# W the slanted N-H-L.
NHL_SHIELD = """
S.........S.........S
SS.......SsS.......SS
SsSS...SSsKsSS...SSsS
SsssSSSssKKKssSSSsssS
SsKKsssKKKKKKKSSsKKsS
SsKKKKKKKKKKSSKKKKKsS
SsKKKKKKKKSSKKKKKKKsS
SsKKKKKKSSKKKWKKKKKsS
SsKKKKSSKKKKKWKKKKKsS
SsKKSSKKKWKWKWKKKKKsS
SsSSKKKKKWKWKWKKKKKsS
SSKKWKKWKWWWKWWWKKSSS
SsKKWWKWKWKWKKKKSSKsS
.SsKWKWWKWKWKKSSKKsS.
.SsKWKKWKKKKSSKKKKsS.
..SsWKKWKKSSKKKKKsS..
...SsKKKSSKKKKKKsS...
....SsSSKKKKKKKsS....
.....SsKKKKKKKsS.....
......SsKKKKKsS......
.......SsKKKsS.......
........SsKsS........
.........SsS.........
..........S..........
"""

NHL_LEGEND = {"S": "#D8D8D8", "s": "#6E6E6E", "K": "#000000", "W": "#FFFFFF"}

# Hand-drawn 23x24 conference badge: S silver trim and banner, d dark edge,
# B conference field, W stars. The W / E letter is drawn over it.
CONFERENCE_SHIELD = """
...SSSSSSSSSSSSSSSSS...
..SdddddddddddddddddS..
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
.SdBBBBBBBBBBBBBBBBBdS.
SSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSS
...SdBBBBBBBBBBBBBdS...
....SdBBBBBBBBBBBdS....
.....SdBWBBBBBWBdS.....
......SdBBBWBBBdS......
.......SdBBBBBdS.......
........SdBBBdS........
.........SdBdS.........
..........SdS..........
...........S...........
"""

LETTER_W = """
XX.........XX
XX.........XX
.XX..XXX..XX.
.XX..XXX..XX.
.XX.XX.XX.XX.
..XXX...XXX..
..XXX...XXX..
..XX.....XX..
"""

LETTER_E = """
XXXXXXXXX
XXXXXXXXX
XX.......
XXXXXXX..
XXXXXXX..
XX.......
XXXXXXXXX
XXXXXXXXX
"""


CONFERENCES = {
    "Western": {
        "abbrev": "W",
        "name": "WESTERN",
        "short": "WEST",
        "divisions": [["P", "PACIFIC"], ["C", "CENTRAL"]],
        "band": "#4591C7",
        "mid": "#165991",
        "edge": "#092D4E",
        "light": "#B8CDDC",
        "fill": "#1F6FB8",
        "letter": LETTER_W,
        "letter_width": 13,
    },
    "Eastern": {
        "abbrev": "E",
        "name": "EASTERN",
        "short": "EAST",
        "divisions": [["A", "ATLANTIC"], ["M", "METROPOLITAN"]],
        "band": "#D6414F",
        "mid": "#9B1B2A",
        "edge": "#4A0D15",
        "light": "#E4BCC1",
        "fill": "#C8102E",
        "letter": LETTER_E,
        "letter_width": 9,
    },
}


def get_conference(ctx):
    return CONFERENCES.get(
        ctx.inputs.get("conference", "Western"),
        CONFERENCES["Western"],
    )


def get_nhl_standings():
    # /standings/now is a 307 redirect to the current standings date, so read
    # that date here: the live table in season, the final table in the
    # offseason. It moves at most daily, hence the hour-long ttl.
    season = http.get(
        "https://api-web.nhle.com/v1/standings-season",
        ttl_seconds=3600,
    )

    if season["status_code"] != 200:
        return []

    if season["json"] == None:
        return []

    date = season["json"].get("currentDate")

    if date == None:
        return []

    # The table's ttl matches the manifest's 300s refresh.
    resp = http.get(
        "https://api-web.nhle.com/v1/standings/" + date,
        ttl_seconds=300,
    )

    if resp["status_code"] != 200:
        return []

    if resp["json"] == None:
        return []

    return resp["json"].get("standings", [])


def get_division(standings, conference, division):
    teams = []

    for team in standings:
        if team["conferenceAbbrev"] == conference["abbrev"]:
            if team["divisionAbbrev"] == division:
                teams.append(team)

    teams = sorted(
        teams,
        key=lambda team: team["divisionSequence"],
    )

    return teams[:3]


def get_wildcard(standings, conference):
    teams = []

    for team in standings:
        if team["conferenceAbbrev"] == conference["abbrev"]:
            if team["wildcardSequence"] == 1 or team["wildcardSequence"] == 2:
                teams.append(team)

    teams = sorted(
        teams,
        key=lambda team: team["wildcardSequence"],
    )

    return teams[:2]


def get_hunt(standings, conference):
    teams = []

    for team in standings:
        if team["conferenceAbbrev"] == conference["abbrev"]:
            if team["divisionSequence"] > 3:
                if team["wildcardSequence"] != 1:
                    if team["wildcardSequence"] != 2:
                        teams.append(team)

    teams = sorted(
        teams,
        key=lambda team: team["conferenceSequence"],
    )

    return teams[:3]


def draw_conference_shield(c, conference, x, y):
    c.sprite(
        CONFERENCE_SHIELD,
        x,
        y,
        legend={
            "S": "#D8D8D8",
            "d": conference["edge"],
            "B": conference["fill"],
            "W": "#FFFFFF",
        },
    )

    # Outline the letter in the dark edge color so it separates from the field.
    letter_x = x + 11 - conference["letter_width"] // 2

    for dx, dy in [[-1, 0], [1, 0], [0, -1], [0, 1]]:
        c.sprite(
            conference["letter"],
            letter_x + dx,
            y + 3 + dy,
            color=conference["edge"],
        )

    c.sprite(
        conference["letter"],
        letter_x,
        y + 3,
        color="white",
    )


def draw_header(c):
    c.text(
        "TEAM",
        19,
        0,
        font="4x5",
        color="white",
    )

    c.text(
        "GP",
        51,
        0,
        font="4x5",
        color="white",
    )

    c.text(
        "W",
        72,
        0,
        font="4x5",
        color="white",
    )

    c.text(
        "L",
        89,
        0,
        font="4x5",
        color="white",
    )

    c.text(
        "OTL",
        104,
        0,
        font="4x5",
        color="white",
    )

    c.text(
        "PTS",
        137,
        0,
        font="4x5",
        color="yellow",
    )

    c.text(
        "RW",
        168,
        0,
        font="4x5",
        color="yellow",
    )

    c.line(
        0,
        6,
        181,
        6,
        "white",
    )


def draw_team_row(c, team, rank, y):
    if team == None:
        return

    abbreviation = team["teamAbbrev"]["default"]
    logo = TEAM_LOGOS.get(abbreviation)
    accent = TEAM_ACCENTS.get(abbreviation, "white")

    c.rect(
        0,
        y,
        2,
        y + 6,
        fill=accent,
    )

    c.text(
        str(rank),
        4,
        y,
        font="4x5",
        color=accent,
    )

    if logo != None:
        c.image(
            logo,
            10,
            y - 1,
        )

    c.text(
        abbreviation[:3],
        19,
        y,
        font="5x7",
        color="white",
    )

    c.text(
        str(team["gamesPlayed"]),
        51,
        y,
        font="5x7",
        color="white",
    )

    c.text(
        str(team["wins"]),
        72,
        y,
        font="5x7",
        color="white",
    )

    c.text(
        str(team["losses"]),
        89,
        y,
        font="5x7",
        color="white",
    )

    c.text(
        str(team["otLosses"]),
        104,
        y,
        font="5x7",
        color="white",
    )

    c.text(
        str(team["points"]),
        137,
        y,
        font="5x7",
        color="yellow",
    )

    c.text(
        str(team["regulationWins"]),
        168,
        y,
        font="5x7",
        color="yellow",
    )


def draw_separator(c, team, y, logo_below=True):
    color = "white"

    if team != None:
        color = TEAM_ACCENTS.get(team["teamAbbrev"]["default"], "white")

    if not logo_below:
        c.line(
            0,
            y,
            181,
            y,
            color,
        )
        return

    # Leave x 9-18 open: the next row's 8px logo (x 10-17, starting one row
    # above its text) sits on this line and chopped it into dashes.
    c.line(
        0,
        y,
        8,
        y,
        color,
    )

    c.line(
        19,
        y,
        181,
        y,
        color,
    )


def draw_three_rows(c, teams):
    c.fill("black")

    draw_header(c)

    for i in range(3):
        team = None

        if i < len(teams):
            team = teams[i]

        draw_team_row(
            c,
            team,
            i + 1,
            8 + i * 8,
        )

        if i < 2:
            draw_separator(
                c,
                team,
                15 + i * 8,
            )


def draw_division_title(c, conference, index):
    c.fill("black")

    draw_conference_shield(
        c,
        conference,
        14,
        4,
    )

    c.rect(52, 1, 191, 14, fill=conference["mid"])
    c.rect(52, 15, 191, 16, fill=conference["edge"])
    c.rect(52, 17, 191, 30, fill=conference["light"])

    # 'METROPOLITAN' is 105px in 8x10 (107 with stroke); the bar is 140 wide.
    c.text_stroke(
        conference["divisions"][index][1],
        121,
        3,
        font="8x10",
        color="white",
        stroke=conference["edge"],
        align="center",
    )

    c.text_stroke(
        "DIVISION",
        121,
        19,
        font="8x10",
        color="white",
        stroke=conference["edge"],
        align="center",
    )


def conference(c, ctx):
    conf = get_conference(ctx)

    c.fill("black")

    c.rect(0, 0, 191, 1, fill=conf["band"])
    c.hline(0, 2, 192, conf["mid"])
    c.hline(0, 29, 192, conf["mid"])
    c.rect(0, 30, 191, 31, fill=conf["band"])

    c.sprite(
        NHL_SHIELD,
        11,
        4,
        legend=NHL_LEGEND,
    )

    # 'WESTERN' / 'EASTERN' are 82px in 11x14_bold: x 55-136, clear of both
    # shields (x 11-31 and 159-181).
    c.text(
        conf["name"],
        96,
        5,
        font="11x14_bold",
        color="white",
        align="center",
    )

    c.text(
        "CONFERENCE",
        96,
        21,
        font="5x7",
        color=conf["band"],
        align="center",
    )

    draw_conference_shield(
        c,
        conf,
        159,
        4,
    )


def division1_title(c, ctx):
    draw_division_title(c, get_conference(ctx), 0)


def division1(c, ctx):
    conf = get_conference(ctx)

    draw_three_rows(
        c,
        get_division(get_nhl_standings(), conf, conf["divisions"][0][0]),
    )


def division2_title(c, ctx):
    draw_division_title(c, get_conference(ctx), 1)


def division2(c, ctx):
    conf = get_conference(ctx)

    draw_three_rows(
        c,
        get_division(get_nhl_standings(), conf, conf["divisions"][1][0]),
    )


def wildcard_title(c, ctx):
    conf = get_conference(ctx)

    c.fill("black")

    draw_conference_shield(
        c,
        conf,
        20,
        4,
    )

    c.rect(64, 0, 191, 14, fill=conf["mid"])
    c.rect(64, 15, 191, 16, fill=conf["edge"])
    c.rect(64, 17, 191, 31, fill=conf["mid"])

    c.text_stroke(
        conf["short"],
        128,
        2,
        font="8x10",
        color="white",
        stroke=conf["edge"],
        align="center",
    )

    c.text_stroke(
        "WILD CARD",
        128,
        19,
        font="8x10",
        color="white",
        stroke=conf["edge"],
        align="center",
    )


def wildcard(c, ctx):
    teams = get_wildcard(get_nhl_standings(), get_conference(ctx))

    team1 = None
    team2 = None

    if len(teams) > 0:
        team1 = teams[0]

    if len(teams) > 1:
        team2 = teams[1]

    c.fill("black")

    draw_header(c)

    draw_team_row(
        c,
        team1,
        1,
        10,
    )

    # Rows sit at y 10 and 22, so the logo below starts at y 21, clear of this line.
    draw_separator(
        c,
        team1,
        19,
        logo_below=False,
    )

    draw_team_row(
        c,
        team2,
        2,
        22,
    )


def hunt(c, ctx):
    draw_three_rows(
        c,
        get_hunt(get_nhl_standings(), get_conference(ctx)),
    )
