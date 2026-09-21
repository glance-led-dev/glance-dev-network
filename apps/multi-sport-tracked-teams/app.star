BASE = "https://site.api.espn.com/apis/"
NFL_URL = BASE + "site/v2/sports/football/nfl/scoreboard"
MLB_URL = BASE + "site/v2/sports/baseball/mlb/scoreboard"
NBA_URL = BASE + "site/v2/sports/basketball/nba/scoreboard"
NHL_URL = BASE + "site/v2/sports/hockey/nhl/scoreboard"
MLS_URL = BASE + "site/v2/sports/soccer/usa.1/scoreboard"

TEXT = "white"
DIM = "gray"
ACCENT = "#00AEEF"


NFL_TEAMS = {
    "ARI": {
        "api": "ARI",
        "color": "#97233F",
        "crest": "arizona-cardinals_small_square.png",
    },
    "ATL": {
        "api": "ATL",
        "color": "#A71930",
        "crest": "atlanta-falcons_small_square.png",
    },
    "BAL": {
        "api": "BAL",
        "color": "#241773",
        "crest": "baltimore-ravens_small_square.png",
    },
    "BUF": {
        "api": "BUF",
        "color": "#00338D",
        "crest": "buffalo-bills_small_square.png",
    },
    "CAR": {
        "api": "CAR",
        "color": "#0085CA",
        "crest": "carolina-panthers_small_square.png",
    },
    "CHI": {
        "api": "CHI",
        "color": "#C83803",
        "crest": "chicago-bears_small_square.png",
    },
    "CIN": {
        "api": "CIN",
        "color": "#FB4F14",
        "crest": "cincinnati-bengals_small_square.png",
    },
    "CLE": {
        "api": "CLE",
        "color": "#FF3C00",
        "crest": "cleveland-browns_small_square.png",
    },
    "DAL": {
        "api": "DAL",
        "color": "#003594",
        "crest": "dallas-cowboys_small_square.png",
    },
    "DEN": {
        "api": "DEN",
        "color": "#FB4F14",
        "crest": "denver-broncos_small_square.png",
    },
    "DET": {
        "api": "DET",
        "color": "#0076B6",
        "crest": "detroit-lions_small_square.png",
    },
    "GB": {
        "api": "GB",
        "color": "#203731",
        "crest": "green-bay-packers_small_square.png",
    },
    "HOU": {
        "api": "HOU",
        "color": "#03202F",
        "crest": "houston-texans_small_square.png",
    },
    "IND": {
        "api": "IND",
        "color": "#002C5F",
        "crest": "indianapolis-colts_small_square.png",
    },
    "JAX": {
        "api": "JAC",
        "color": "#00A5B5",
        "crest": "jacksonville-jaguars_small_square.png",
    },
    "KC": {
        "api": "KC",
        "color": "#E31837",
        "crest": "kansas-city-chiefs_small_square.png",
    },
    "LV": {
        "api": "LV",
        "color": "#A5ACAF",
        "crest": "las-vegas-raiders_small_square.png",
    },
    "LAC": {
        "api": "LAC",
        "color": "#0080C6",
        "crest": "los-angeles-chargers_small_square.png",
    },
    "LAR": {
        "api": "LAR",
        "color": "#003594",
        "crest": "los-angeles-rams_small_square.png",
    },
    "MIA": {
        "api": "MIA",
        "color": "#008E97",
        "crest": "miami-dolphins_small_square.png",
    },
    "MIN": {
        "api": "MIN",
        "color": "#4F2683",
        "crest": "minnesota-vikings_small_square.png",
    },
    "NE": {
        "api": "NE",
        "color": "#002244",
        "crest": "new-england-patriots_small_square.png",
    },
    "NO": {
        "api": "NO",
        "color": "#D3BC8D",
        "crest": "new-orleans-saints_small_square.png",
    },
    "NYG": {
        "api": "NYG",
        "color": "#0B2265",
        "crest": "new-york-giants_small_square.png",
    },
    "NYJ": {
        "api": "NYJ",
        "color": "#125740",
        "crest": "new-york-jets_small_square.png",
    },
    "PHI": {
        "api": "PHI",
        "color": "#004C54",
        "crest": "philadelphia-eagles_small_square.png",
    },
    "PIT": {
        "api": "PIT",
        "color": "#FFB612",
        "crest": "pittsburgh-steelers_small_square.png",
    },
    "SEA": {
        "api": "SEA",
        "color": "#69BE28",
        "crest": "seattle-seahawks_small_square.png",
    },
    "SF": {
        "api": "SF",
        "color": "#AA0000",
        "crest": "san-francisco-49ers_small_square.png",
    },
    "TB": {
        "api": "TB",
        "color": "#D50A0A",
        "crest": "tampa-bay-buccaneers_small_square.png",
    },
    "TEN": {
        "api": "TEN",
        "color": "#4B92DB",
        "crest": "tennessee-titans_small_square.png",
    },
    "WSH": {
        "api": "WSH",
        "color": "#5A1414",
        "crest": "washington-commanders_small_square.png",
    },
}
MLB_TEAMS = {
    "ARI": {
        "api": "ARI",
        "color": "#A71930",
        "crest": "arizona-diamondbacks_small_square.png",
    },
    "ATH": {
        "api": "ATH",
        "color": "#003831",
        "crest": "athletics_small_square.png",
    },
    "ATL": {
        "api": "ATL",
        "color": "#CE1141",
        "crest": "atlanta-braves_small_square.png",
    },
    "BAL": {
        "api": "BAL",
        "color": "#DF4601",
        "crest": "baltimore-orioles_small_square.png",
    },
    "BOS": {
        "api": "BOS",
        "color": "#BD3039",
        "crest": "boston-red-sox_small_square.png",
    },
    "CHC": {
        "api": "CHC",
        "color": "#0E3386",
        "crest": "chicago-cubs_small_square.png",
    },
    "CHW": {
        "api": "CHW",
        "color": "#FFFFFF",
        "crest": "chicago-white-sox_small_square.png",
    },
    "CIN": {
        "api": "CIN",
        "color": "#C6011F",
        "crest": "cincinnati-reds_small_square.png",
    },
    "CLE": {
        "api": "CLE",
        "color": "#E31937",
        "crest": "cleveland-guardians_small_square.png",
    },
    "COL": {
        "api": "COL",
        "color": "#8A8D8F",
        "crest": "colorado-rockies_small_square.png",
    },
    "DET": {
        "api": "DET",
        "color": "#FA4616",
        "crest": "detroit-tigers_small_square.png",
    },
    "HOU": {
        "api": "HOU",
        "color": "#EB6E1F",
        "crest": "houston-astros_small_square.png",
    },
    "KC": {
        "api": "KC",
        "color": "#004687",
        "crest": "kansas-city-royals_small_square.png",
    },
    "LAA": {
        "api": "LAA",
        "color": "#BA0021",
        "crest": "los-angeles-angels_small_square.png",
    },
    "LAD": {
        "api": "LAD",
        "color": "#005A9C",
        "crest": "los-angeles-dodgers_small_square.png",
    },
    "MIA": {
        "api": "MIA",
        "color": "#00A3E0",
        "crest": "miami-marlins_small_square.png",
    },
    "MIL": {
        "api": "MIL",
        "color": "#FFC52F",
        "crest": "milwaukee-brewers_small_square.png",
    },
    "MIN": {
        "api": "MIN",
        "color": "#D31145",
        "crest": "minnesota-twins_small_square.png",
    },
    "NYM": {
        "api": "NYM",
        "color": "#FF5910",
        "crest": "new-york-mets_small_square.png",
    },
    "NYY": {
        "api": "NYY",
        "color": "#FFFFFF",
        "crest": "new-york-yankees_small_square.png",
    },
    "PHI": {
        "api": "PHI",
        "color": "#E81828",
        "crest": "philadelphia-phillies_small_square.png",
    },
    "PIT": {
        "api": "PIT",
        "color": "#FDB827",
        "crest": "pittsburgh-pirates_small_square.png",
    },
    "SD": {
        "api": "SD",
        "color": "#FFC425",
        "crest": "san-diego-padres_small_square.png",
    },
    "SEA": {
        "api": "SEA",
        "color": "#00A0A8",
        "crest": "seattle-mariners_small_square.png",
    },
    "SF": {
        "api": "SF",
        "color": "#FD5A1E",
        "crest": "san-francisco-giants_small_square.png",
    },
    "STL": {
        "api": "STL",
        "color": "#C41E3A",
        "crest": "st-louis-cardinals_small_square.png",
    },
    "TB": {
        "api": "TB",
        "color": "#8FBCE6",
        "crest": "tampa-bay-rays_small_square.png",
    },
    "TEX": {
        "api": "TEX",
        "color": "#C0111F",
        "crest": "texas-rangers_small_square.png",
    },
    "TOR": {
        "api": "TOR",
        "color": "#134A8E",
        "crest": "toronto-blue-jays_small_square.png",
    },
    "WSH": {
        "api": "WSH",
        "color": "#AB0003",
        "crest": "washington-nationals_small_square.png",
    },
}
NBA_TEAMS = {
    "ATL": {
        "api": "ATL",
        "color": "#E03A3E",
        "crest": "atlanta-hawks_small_square.png",
    },
    "BOS": {
        "api": "BOS",
        "color": "#007A33",
        "crest": "boston-celtics_small_square.png",
    },
    "BKN": {
        "api": "BKN",
        "color": "#FFFFFF",
        "crest": "brooklyn-nets_small_square.png",
    },
    "CHA": {
        "api": "CHA",
        "color": "#1D1160",
        "crest": "charlotte-hornets_small_square.png",
    },
    "CHI": {
        "api": "CHI",
        "color": "#CE1141",
        "crest": "chicago-bulls_small_square.png",
    },
    "CLE": {
        "api": "CLE",
        "color": "#860038",
        "crest": "cleveland-cavaliers_small_square.png",
    },
    "DAL": {
        "api": "DAL",
        "color": "#00538C",
        "crest": "dallas-mavericks_small_square.png",
    },
    "DEN": {
        "api": "DEN",
        "color": "#FEC524",
        "crest": "denver-nuggets_small_square.png",
    },
    "DET": {
        "api": "DET",
        "color": "#C8102E",
        "crest": "detroit-pistons_small_square.png",
    },
    "GSW": {
        "api": "GS",
        "color": "#1D428A",
        "crest": "golden-state-warriors_small_square.png",
    },
    "HOU": {
        "api": "HOU",
        "color": "#CE1141",
        "crest": "houston-rockets_small_square.png",
    },
    "IND": {
        "api": "IND",
        "color": "#FDBB30",
        "crest": "indiana-pacers_small_square.png",
    },
    "LAC": {
        "api": "LAC",
        "color": "#C8102E",
        "crest": "la-clippers_small_square.png",
    },
    "LAL": {
        "api": "LAL",
        "color": "#FDB927",
        "crest": "los-angeles-lakers_small_square.png",
    },
    "MEM": {
        "api": "MEM",
        "color": "#5D76A9",
        "crest": "memphis-grizzlies_small_square.png",
    },
    "MIA": {
        "api": "MIA",
        "color": "#98002E",
        "crest": "miami-heat_small_square.png",
    },
    "MIL": {
        "api": "MIL",
        "color": "#00471B",
        "crest": "milwaukee-bucks_small_square.png",
    },
    "MIN": {
        "api": "MIN",
        "color": "#78BE20",
        "crest": "minnesota-timberwolves_small_square.png",
    },
    "NOP": {
        "api": "NO",
        "color": "#0C2340",
        "crest": "new-orleans-pelicans_small_square.png",
    },
    "NYK": {
        "api": "NY",
        "color": "#F58426",
        "crest": "new-york-knicks_small_square.png",
    },
    "OKC": {
        "api": "OKC",
        "color": "#007AC1",
        "crest": "oklahoma-city-thunder_small_square.png",
    },
    "ORL": {
        "api": "ORL",
        "color": "#0077C0",
        "crest": "orlando-magic_small_square.png",
    },
    "PHI": {
        "api": "PHI",
        "color": "#006BB6",
        "crest": "philadelphia-76ers_small_square.png",
    },
    "PHX": {
        "api": "PHX",
        "color": "#E56020",
        "crest": "phoenix-suns_small_square.png",
    },
    "POR": {
        "api": "POR",
        "color": "#E03A3E",
        "crest": "portland-trail-blazers_small_square.png",
    },
    "SAC": {
        "api": "SAC",
        "color": "#5A2D81",
        "crest": "sacramento-kings_small_square.png",
    },
    "SAS": {
        "api": "SA",
        "color": "#C4CED4",
        "crest": "san-antonio-spurs_small_square.png",
    },
    "TOR": {
        "api": "TOR",
        "color": "#CE1141",
        "crest": "toronto-raptors_small_square.png",
    },
    "UTA": {
        "api": "UTAH",
        "color": "#F9A01B",
        "crest": "utah-jazz_small_square.png",
    },
    "WAS": {
        "api": "WSH",
        "color": "#002B5C",
        "crest": "washington-wizards_small_square.png",
    },
}
NHL_TEAMS = {
    "ANA": {
        "api": "ANA",
        "color": "#FC4C02",
        "crest": "anaheim-ducks-logo.png",
    },
    "BOS": {
        "api": "BOS",
        "color": "#FFB81C",
        "crest": "boston-bruins-5-logo-png-transparent.png",
    },
    "BUF": {
        "api": "BUF",
        "color": "#003087",
        "crest": "buffalo-sabres-logo.png",
    },
    "CGY": {
        "api": "CGY",
        "color": "#D2001C",
        "crest": "calgary-flames-logo.png",
    },
    "CAR": {
        "api": "CAR",
        "color": "#CC0000",
        "crest": "carolina-hurricanes-logo.png",
    },
    "CHI": {
        "api": "CHI",
        "color": "#CF0A2C",
        "crest": "chicago-blackhawks-logo.png",
    },
    "COL": {
        "api": "COL",
        "color": "#6F263D",
        "crest": "colorado-avalanche-logo.png",
    },
    "CBJ": {
        "api": "CBJ",
        "color": "#002654",
        "crest": "Columbus-Blue-Jackets-Logo-2007-500x313.png",
    },
    "DAL": {
        "api": "DAL",
        "color": "#006847",
        "crest": "dallas-stars-logo.png",
    },
    "DET": {
        "api": "DET",
        "color": "#CE1126",
        "crest": "detroit-red-wings-logo.png",
    },
    "EDM": {
        "api": "EDM",
        "color": "#FF4C00",
        "crest": "Edmonton-Oilers-Logo-500x313.png",
    },
    "FLA": {
        "api": "FLA",
        "color": "#C8102E",
        "crest": "florida-panthers-logo.png",
    },
    "LAK": {
        "api": "LA",
        "color": "#A2AAAD",
        "crest": "los-angeles-kings-logo.png",
    },
    "MIN": {
        "api": "MIN",
        "color": "#154734",
        "crest": "minnesota-wild-logo.png",
    },
    "MTL": {
        "api": "MTL",
        "color": "#AF1E2D",
        "crest": "Montreal-Canadiens-Logo-500x313.png",
    },
    "NSH": {
        "api": "NSH",
        "color": "#FFB81C",
        "crest": "nashville-predators-logo.png",
    },
    "NJD": {
        "api": "NJ",
        "color": "#CE1126",
        "crest": "New-Jersey-Devils-Logo-500x313.png",
    },
    "NYI": {
        "api": "NYI",
        "color": "#00539B",
        "crest": "new-york-islanders-logo.png",
    },
    "NYR": {
        "api": "NYR",
        "color": "#0038A8",
        "crest": "new-york-rangers-logo.png",
    },
    "OTT": {
        "api": "OTT",
        "color": "#DA1A32",
        "crest": "ottawa-senators-logo.png",
    },
    "PHI": {
        "api": "PHI",
        "color": "#F74902",
        "crest": "philadelphia-flyers-logo.png",
    },
    "PIT": {
        "api": "PIT",
        "color": "#FCB514",
        "crest": "pittsburgh-penguins-logo.png",
    },
    "SJS": {
        "api": "SJ",
        "color": "#006D75",
        "crest": "san-jose-sharks-logo.png",
    },
    "SEA": {
        "api": "SEA",
        "color": "#99D9D9",
        "crest": "Seattle-Kraken-Logo-648x400.png",
    },
    "STL": {
        "api": "STL",
        "color": "#002F87",
        "crest": "st-louis-blues-logo.png",
    },
    "TBL": {
        "api": "TB",
        "color": "#002868",
        "crest": "Tampa-Bay-Lightning-Logo-500x312.png",
    },
    "TOR": {
        "api": "TOR",
        "color": "#003E7E",
        "crest": "toronto-maple-leafs-logo.png",
    },
    "UTA": {
        "api": "UTA",
        "color": "#71AFE5",
        "crest": "Utah-Mammoth-Logo-500x281.png",
    },
    "VAN": {
        "api": "VAN",
        "color": "#00843D",
        "crest": "vancouver-canucks-logo.png",
    },
    "VGK": {
        "api": "VGK",
        "color": "#B4975A",
        "crest": "vegas-golden-knights-logo.png",
    },
    "WSH": {
        "api": "WSH",
        "color": "#C8102E",
        "crest": "Washington-Capitals-Logo-640x400.png",
    },
    "WPG": {
        "api": "WPG",
        "color": "#041E42",
        "crest": "winnipeg-jets-logo.png",
    },
}
MLS_TEAMS = {
    "ATL": {
        "api": "ATL",
        "color": "#80000A",
        "crest": "usa_atlanta-united_64x64.football-logos.cc.png",
    },
    "ATX": {
        "api": "ATX",
        "color": "#00B140",
        "crest": "usa_austins-fc_64x64.football-logos.cc.png",
    },
    "CHI": {
        "api": "CHI",
        "color": "#A50021",
        "crest": "usa_chicago-fire-fc_64x64.football-logos.cc.png",
    },
    "CIN": {
        "api": "CIN",
        "color": "#F05323",
        "crest": "usa_fc-cincinnati_64x64.football-logos.cc.png",
    },
    "CLT": {
        "api": "CLT",
        "color": "#1A85C8",
        "crest": "usa_charlotte-fc_64x64.football-logos.cc.png",
    },
    "CLB": {
        "api": "CLB",
        "color": "#FEDD00",
        "crest": "usa_columbus-crew_64x64.football-logos.cc.png",
    },
    "COL": {
        "api": "COL",
        "color": "#862633",
        "crest": "usa_colorado-rapids_64x64.football-logos.cc.png",
    },
    "DAL": {
        "api": "DAL",
        "color": "#E81F3E",
        "crest": "usa_fc-dallas_64x64.football-logos.cc.png",
    },
    "DCU": {
        "api": "DC",
        "color": "#EF3E42",
        "crest": "usa_dc-united_64x64.football-logos.cc.png",
    },
    "HOU": {
        "api": "HOU",
        "color": "#F68712",
        "crest": "usa_houston-dynamo_64x64.football-logos.cc.png",
    },
    "LA": {
        "api": "LA",
        "color": "#00245D",
        "crest": "usa_la-galaxy_64x64.football-logos.cc.png",
    },
    "LAFC": {
        "api": "LAFC",
        "color": "#C39E6D",
        "crest": "usa_los-angeles-fc_64x64.football-logos.cc.png",
    },
    "MIA": {
        "api": "MIA",
        "color": "#F7B5CD",
        "crest": "usa_inter-miami-cf_64x64.football-logos.cc.png",
    },
    "MIN": {
        "api": "MIN",
        "color": "#8CD2F4",
        "crest": "usa_minnesota-united-fc_64x64.football-logos.cc.png",
    },
    "MTL": {
        "api": "MTL",
        "color": "#0033A0",
        "crest": "usa_cf-montreal_64x64.football-logos.cc.png",
    },
    "NSH": {
        "api": "NSH",
        "color": "#F9E11E",
        "crest": "usa_nashville-sc_64x64.football-logos.cc.png",
    },
    "NE": {
        "api": "NE",
        "color": "#0A2240",
        "crest": "usa_new-england-revolution_64x64.football-logos.cc.png",
    },
    "NYC": {
        "api": "NYC",
        "color": "#6CACE4",
        "crest": "usa_new-york-city-fc_64x64.football-logos.cc.png",
    },
    "RBNY": {
        "api": "RBNY",
        "color": "#ED1E36",
        "crest": "usa_new-york-red-bulls_64x64.football-logos.cc.png",
    },
    "ORL": {
        "api": "ORL",
        "color": "#61259E",
        "crest": "usa_orlando-city_64x64.football-logos.cc.png",
    },
    "PHI": {
        "api": "PHI",
        "color": "#071B2C",
        "crest": "usa_philadelphia-union_64x64.football-logos.cc.png",
    },
    "POR": {
        "api": "POR",
        "color": "#004812",
        "crest": "usa_portland-timbers_64x64.football-logos.cc.png",
    },
    "RSL": {
        "api": "RSL",
        "color": "#B30838",
        "crest": "usa_real-salt-lake_64x64.football-logos.cc.png",
    },
    "SD": {
        "api": "SD",
        "color": "#00AEEF",
        "crest": "usa_san-diego-fc_64x64.football-logos.cc.png",
    },
    "SEA": {
        "api": "SEA",
        "color": "#5D9732",
        "crest": "usa_seattle-sounders-fc_64x64.football-logos.cc.png",
    },
    "SJ": {
        "api": "SJ",
        "color": "#0067B1",
        "crest": "usa_san-jose-earthquakes_64x64.football-logos.cc.png",
    },
    "SKC": {
        "api": "SKC",
        "color": "#91B0D5",
        "crest": "usa_sporting-kansas-city_64x64.football-logos.cc.png",
    },
    "STL": {
        "api": "STL",
        "color": "#E10098",
        "crest": "usa_st-louis-city-sc_64x64.football-logos.cc.png",
    },
    "TOR": {
        "api": "TOR",
        "color": "#B81137",
        "crest": "usa_toronto-fc_64x64.football-logos.cc.png",
    },
    "VAN": {
        "api": "VAN",
        "color": "#00245E",
        "crest": "usa_vancouver-whitecaps-fc_64x64.football-logos.cc.png",
    },
}

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    value = obj.get(key, fallback)
    return fallback if value == None else value


def dig(obj, keys, fallback = None):
    value = obj

    for key in keys:
        if value == None:
            return fallback

        if type(value) != "dict":
            return fallback

        if key not in value:
            return fallback

        value = value[key]

    return value


def selected_nfl_team(ctx):
    return str(ctx.inputs.get("nflteam", "SEA")).strip().upper()


def team_color(team):
    if team in NFL_TEAMS:
        return NFL_TEAMS[team]["color"]

    return ACCENT


def nfl_api_team(team):
    if team in NFL_TEAMS:
        return NFL_TEAMS[team]["api"]

    return team

def nfl_display_team(api_team):
    for team in NFL_TEAMS:
        if NFL_TEAMS[team]["api"] == api_team:
            return team

    return api_team


def nfl_team_crest(team):
    if team in NFL_TEAMS:
        return NFL_TEAMS[team]["crest"]

    return ""

def selected_mlb_team(ctx):
    return str(ctx.inputs.get("mlbteam", "SEA")).strip().upper()


def mlb_api_team(team):
    if team in MLB_TEAMS:
        return MLB_TEAMS[team]["api"]

    return team

def mlb_display_team(api_team):
    for team in MLB_TEAMS:
        if MLB_TEAMS[team]["api"] == api_team:
            return team

    return api_team


def mlb_team_crest(team):
    if team in MLB_TEAMS:
        return MLB_TEAMS[team]["crest"]

    return ""

def mlb_team_color(team):
    if team in MLB_TEAMS:
        return MLB_TEAMS[team]["color"]

    return ACCENT

def selected_nba_team(ctx):
    return str(ctx.inputs.get("nbateam", "POR")).strip().upper()


def nba_api_team(team):
    if team in NBA_TEAMS:
        return NBA_TEAMS[team]["api"]

    return team

def nba_display_team(api_team):
    for team in NBA_TEAMS:
        if NBA_TEAMS[team]["api"] == api_team:
            return team

    return api_team


def nba_team_crest(team):
    if team in NBA_TEAMS:
        return NBA_TEAMS[team]["crest"]

    return ""

def nba_team_color(team):
    if team in NBA_TEAMS:
        return NBA_TEAMS[team]["color"]

    return ACCENT

def selected_nhl_team(ctx):
    return str(ctx.inputs.get("nhlteam", "SEA")).strip().upper()


def nhl_api_team(team):
    if team in NHL_TEAMS:
        return NHL_TEAMS[team]["api"]

    return team

def nhl_display_team(api_team):
    for team in NHL_TEAMS:
        if NHL_TEAMS[team]["api"] == api_team:
            return team

    return api_team


def nhl_team_crest(team):
    if team in NHL_TEAMS:
        return NHL_TEAMS[team]["crest"]

    return ""

def nhl_team_color(team):
    if team in NHL_TEAMS:
        return NHL_TEAMS[team]["color"]

    return ACCENT

def selected_mls_team(ctx):
    return str(ctx.inputs.get("mlsteam", "SEA")).strip().upper()


def mls_api_team(team):
    if team in MLS_TEAMS:
        return MLS_TEAMS[team]["api"]

    return team

def mls_display_team(api_team):
    for team in MLS_TEAMS:
        if MLS_TEAMS[team]["api"] == api_team:
            return team

    return api_team


def mls_team_crest(team):
    if team in MLS_TEAMS:
        return MLS_TEAMS[team]["crest"]

    return ""

def mls_team_color(team):
    if team in MLS_TEAMS:
        return MLS_TEAMS[team]["color"]

    return ACCENT

def draw_left_rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)


def read_nfl_events(ctx):
    return read_sport_events(ctx, "nfl", selected_nfl_team(ctx))


def nfl_live_match(events, team):
    return select_match(events, nfl_api_team(team), "in")


def nfl_next_match(events, team):
    return select_match(events, nfl_api_team(team), "pre")


def opponent_of(match, api_team):
    if match["home"]["abbr"] == api_team:
        return match["away"]

    return match["home"]


def tracked_score(match, api_team):
    if match["home"]["abbr"] == api_team:
        return match["home"]["score"]

    return match["away"]["score"]


def opponent_score(match, api_team):
    if match["home"]["abbr"] == api_team:
        return match["away"]["score"]

    return match["home"]["score"]


def nfl_location_symbol(match, team):
    api_team = nfl_api_team(team)

    if match["home"]["abbr"] == api_team:
        return "VS"

    return "@"


def simple_date_text(iso, ctx=None):
    minutes = parse_iso(iso, 0)
    if minutes == None:
        return "DATE TBD"
    if ctx != None:
        minutes += local_offset(minutes, ctx.inputs.get("timezone", "America/Los_Angeles"))
    parts = civil_from_days(minutes // 1440)
    return MONTHS[parts[1] - 1] + " " + str(parts[2])


def title(c, ctx):
    c.clear()

    # Keep input references for manifest validation
    nfl = ctx.inputs.get("nflteam", "SEA")
    mlb = ctx.inputs.get("mlbteam", "SEA")
    nba = ctx.inputs.get("nbateam", "POR")
    nhl = ctx.inputs.get("nhlteam", "SEA")
    mls = ctx.inputs.get("mlsteam", "SEA")
    timezone = ctx.inputs.get("timezone", "America/Los_Angeles")

    # NFL
    draw_crest(c,
        "NFL22.png",
        4,
        0,
        22,
        22,
    )

    # MLB
    draw_crest(c,
        "MLB22.png",
        29,
        0,
        22,
        22,
    )

    # NBA
    draw_crest(c,
        "Jerry-West-the-NBA-Logo-500x281.png",
        49,
        -4,
        30,
        30,
    )

    # NHL
    draw_crest(c,
        "nhl-1-logo-png-transparent.png",
        75,
        0,
        22,
        22,
    )

    # MLS
    draw_crest(c,
        "MLS22.png",
        102,
        2,
        20,
        20,
    )

    c.text_center(
        "TRACKED TEAMS",
        23,
        font = "5x7",
        color = ACCENT,
    )


def nfl_page(c, ctx):
    c.clear()

    team = selected_nfl_team(ctx)
    color = team_color(team)

    draw_left_rail(c, color)

    c.text(
        "NFL",
        111,
        1,
        font = "4x5",
        color = color,
    )

    events = read_nfl_events(ctx)

    if events == None:
        c.text_center(
            "NFL DATA OFFLINE",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    live = nfl_live_match(
        events,
        team,
    )

    if live != None:
        c.text("LIVE", 4, 0, font = "3x4", color = color)
        api_team = nfl_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = nfl_display_team(
            opponent["abbr"]
        )

        # Selected team crest
        draw_crest(c,
            nfl_team_crest(team),
            17,
            4,
            22,
            22,
        )

        # Opponent crest
        draw_crest(c,
            nfl_team_crest(opponent_team),
            89,
            4,
            22,
            22,
        )

        # Small abbreviation below selected crest
        c.text(
            team,
            28,
            25,
            font = "4x5",
            color = color,
            align = "center",
        )

        # Small abbreviation below opponent crest
        c.text(
            opponent_team,
            108,
            25,
            font = "4x5",
            color = TEXT,
            align = "center",
        )

        score = (
            tracked_score(live, api_team) +
            "-" +
            opponent_score(live, api_team)
        )

        c.text(
            score,
            64,
            10,
            font = "6x8",
            color = TEXT,
            align = "center",
        )

        c.text_center(
            live["detail"],
            22,
            font = "4x5",
            color = color,
        )

        return

    next_match = nfl_next_match(
        events,
        team,
    )

    if next_match == None:
        c.text_center(
            "NO UPCOMING GAME",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    api_team = nfl_api_team(team)

    opponent = opponent_of(
        next_match,
        api_team,
    )

    opponent_team = nfl_display_team(
        opponent["abbr"]
    )

    if next_match["home"]["abbr"] == api_team:
        symbol = "VS"
    else:
        symbol = "@"

    # Selected team crest
    draw_crest(c,
        nfl_team_crest(team),
        17,
        4,
        22,
        22,
    )

    # Opponent crest
    draw_crest(c,
        nfl_team_crest(opponent_team),
        89,
        4,
        22,
        22,
    )

    # Small abbreviation below selected crest
    c.text(
        team,
        28,
        25,
        font = "4x5",
        color = color,
        align = "center",
    )

    # Small abbreviation below opponent crest
    c.text(
        opponent_team,
        100,
        25,
        font = "4x5",
        color = TEXT,
        align = "center",
    )

    c.text(
        symbol,
        64,
        10,
        font = "6x8",
        color = TEXT,
        align = "center",
    )

    c.text_center(
        simple_date_text(
            next_match["date"], ctx
        ),
        22,
        font = "4x5",
        color = color,
    )


def mlb_page(c, ctx):
    c.clear()

    team = selected_mlb_team(ctx)
    color = mlb_team_color(team)

    draw_left_rail(c, color)

    c.text(
        "MLB",
        111,
        1,
        font = "4x5",
        color = color,
    )

    events = read_mlb_events(
        ctx,
        team,
    )

    if events == None:
        c.text_center(
            "MLB DATA OFFLINE",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    live = mlb_live_match(
        events,
        team,
    )

    if live != None:
        c.text("LIVE", 4, 0, font = "3x4", color = color)
        api_team = mlb_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = mlb_display_team(
            opponent["abbr"]
        )

        draw_crest(c,
            mlb_team_crest(team),
            17,
            6,
            20,
            20,
        )

        draw_crest(c,
            mlb_team_crest(opponent_team),
            106,
            6,
            20,
            20,
        )

        c.text(
            team,
            14,
            27,
            font = "4x5",
            color = color,
            align = "center",
        )

        c.text(
            opponent_team,
            114,
            27,
            font = "4x5",
            color = TEXT,
            align = "center",
        )

        score = (
            tracked_score(live, api_team) +
            "-" +
            opponent_score(live, api_team)
        )

        c.text(
            score,
            64,
            10,
            font = "6x8",
            color = TEXT,
            align = "center",
        )

        c.text_center(
            live["detail"],
            22,
            font = "4x5",
            color = color,
        )

        return

    next_match = mlb_next_match(
        events,
        team,
    )

    if next_match == None:
        c.text_center(
            "NO UPCOMING GAME",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    api_team = mlb_api_team(team)

    opponent = opponent_of(
        next_match,
        api_team,
    )

    opponent_team = mlb_display_team(
        opponent["abbr"]
    )

    if next_match["home"]["abbr"] == api_team:
        symbol = "VS"
    else:
        symbol = "@"

    draw_crest(c,
        mlb_team_crest(team),
        18,
        2,
        21,
        21,
    )

    draw_crest(c,
        mlb_team_crest(opponent_team),
        89,
        2,
        21,
        21,
    )

    c.text(
        team,
        28,
        25,
        font = "4x5",
        color = color,
        align = "center",
    )

    c.text(
        opponent_team,
        100,
        25,
        font = "4x5",
        color = TEXT,
        align = "center",
    )

    c.text(
        symbol,
        64,
        10,
        font = "6x8",
        color = TEXT,
        align = "center",
    )

    c.text_center(
        simple_date_text(
            next_match["date"], ctx
        ),
        22,
        font = "4x5",
        color = color,
    )

def pad2(n):
    return ("0" + str(n)) if n < 10 else str(n)


def add_days(year, month, day, count):
    month_days = {
        1: 31,
        2: 28,
        3: 31,
        4: 30,
        5: 31,
        6: 30,
        7: 31,
        8: 31,
        9: 30,
        10: 31,
        11: 30,
        12: 31,
    }

    for i in range(count):
        day = day + 1

        if day > month_days[month]:
            day = 1
            month = month + 1

            if month > 12:
                month = 1
                year = year + 1

    return [year, month, day]

def read_mlb_events(ctx, team):
    return read_sport_events(ctx, "mlb", team)

def mlb_live_match(events, team):
    return select_match(events, mlb_api_team(team), "in")


def mlb_next_match(events, team):
    return select_match(events, mlb_api_team(team), "pre")

def read_nba_events(ctx, team):
    return read_sport_events(ctx, "nba", team)


def nba_live_match(events, team):
    return select_match(events, nba_api_team(team), "in")


def nba_next_match(events, team):
    return select_match(events, nba_api_team(team), "pre")

def nba_page(c, ctx):
    c.clear()

    team = selected_nba_team(ctx)
    color = nba_team_color(team)

    draw_left_rail(c, color)

    c.text(
        "NBA",
        111,
        1,
        font = "4x5",
        color = color,
    )

    events = read_nba_events(
        ctx,
        team,
    )

    if events == None:
        c.text_center(
            "NBA DATA OFFLINE",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    live = nba_live_match(
        events,
        team,
    )

    if live != None:
        c.text("LIVE", 4, 0, font = "3x4", color = color)
        api_team = nba_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = nba_display_team(
            opponent["abbr"]
        )

        draw_crest(c,
            nba_team_crest(team),
            17,
            3,
            22,
            22,
        )

        draw_crest(c,
            nba_team_crest(opponent_team),
            89,
            3,
            22,
            22,
        )

        c.text(
            team,
            28,
            25,
            font = "4x5",
            color = color,
            align = "center",
        )

        c.text(
            opponent_team,
            100,
            25,
            font = "4x5",
            color = TEXT,
            align = "center",
        )

        score = (
            tracked_score(live, api_team) +
            "-" +
            opponent_score(live, api_team)
        )

        c.text(
            score,
            64,
            10,
            font = "6x8",
            color = TEXT,
            align = "center",
        )

        c.text_center(
            live["detail"],
            22,
            font = "4x5",
            color = color,
        )

        return

    next_match = nba_next_match(
        events,
        team,
    )

    if next_match == None:
        c.text_center(
            "NO UPCOMING GAME",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    api_team = nba_api_team(team)

    opponent = opponent_of(
        next_match,
        api_team,
    )

    opponent_team = nba_display_team(
        opponent["abbr"]
    )

    if next_match["home"]["abbr"] == api_team:
        symbol = "VS"
    else:
        symbol = "@"

    draw_crest(c,
        nba_team_crest(team),
        17,
        3,
        22,
        22,
    )

    draw_crest(c,
        nba_team_crest(opponent_team),
        89,
        3,
        22,
        22,
    )

    c.text(
        team,
        28,
        25,
        font = "4x5",
        color = color,
        align = "center",
    )

    c.text(
        opponent_team,
        100,
        25,
        font = "4x5",
        color = TEXT,
        align = "center",
    )

    c.text(
        symbol,
        64,
        10,
        font = "6x8",
        color = TEXT,
        align = "center",
    )

    c.text_center(
        simple_date_text(
            next_match["date"], ctx
        ),
        22,
        font = "4x5",
        color = color,
    )

def read_nhl_events(ctx, team):
    return read_sport_events(ctx, "nhl", team)


def nhl_live_match(events, team):
    return select_match(events, nhl_api_team(team), "in")


def nhl_next_match(events, team):
    return select_match(events, nhl_api_team(team), "pre")


def nhl_page(c, ctx):
    c.clear()

    team = selected_nhl_team(ctx)
    color = nhl_team_color(team)

    draw_left_rail(c, color)

    c.text(
        "NHL",
        111,
        1,
        font = "4x5",
        color = color,
    )

    events = read_nhl_events(
        ctx,
        team,
    )

    if events == None:
        c.text_center(
            "NHL DATA OFFLINE",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    live = nhl_live_match(
        events,
        team,
    )

    if live != None:
        c.text("LIVE", 4, 0, font = "3x4", color = color)
        api_team = nhl_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = nhl_display_team(
            opponent["abbr"]
        )

        draw_crest(c,
            nhl_team_crest(team),
            17,
            3,
            22,
            22,
        )

        draw_crest(c,
            nhl_team_crest(opponent_team),
            88,
            3,
            22,
            22,
        )

        c.text(
            team,
            28,
            25,
            font = "4x5",
            color = color,
            align = "center",
        )

        c.text(
            opponent_team,
            100,
            25,
            font = "4x5",
            color = TEXT,
            align = "center",
        )

        score = (
            tracked_score(live, api_team) +
            "-" +
            opponent_score(live, api_team)
        )

        c.text(
            score,
            64,
            10,
            font = "6x8",
            color = TEXT,
            align = "center",
        )

        c.text_center(
            live["detail"],
            22,
            font = "4x5",
            color = color,
        )

        return

    next_match = nhl_next_match(
        events,
        team,
    )

    if next_match == None:
        c.text_center(
            "NO UPCOMING GAME",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    api_team = nhl_api_team(team)

    opponent = opponent_of(
        next_match,
        api_team,
    )

    opponent_team = nhl_display_team(
        opponent["abbr"]
    )

    if next_match["home"]["abbr"] == api_team:
        symbol = "VS"
    else:
        symbol = "@"

    draw_crest(c,
        nhl_team_crest(team),
        17,
        3,
        22,
        22,
    )

    draw_crest(c,
        nhl_team_crest(opponent_team),
        88,
        3,
        22,
        22,
    )

    c.text(
        team,
        28,
        25,
        font = "4x5",
        color = color,
        align = "center",
    )

    c.text(
        opponent_team,
        100,
        25,
        font = "4x5",
        color = TEXT,
        align = "center",
    )

    c.text(
        symbol,
        64,
        10,
        font = "6x8",
        color = TEXT,
        align = "center",
    )

    c.text_center(
        simple_date_text(
            next_match["date"], ctx
        ),
        22,
        font = "4x5",
        color = color,
    )

def read_mls_events(ctx, team):
    return read_sport_events(ctx, "mls", team)


def mls_live_match(events, team):
    return select_match(events, mls_api_team(team), "in")


def mls_next_match(events, team):
    return select_match(events, mls_api_team(team), "pre")

def mls_page(c, ctx):
    c.clear()

    team = selected_mls_team(ctx)
    color = mls_team_color(team)

    draw_left_rail(c, color)

    c.text(
        "MLS",
        109,
        1,
        font = "4x5",
        color = color,
    )

    events = read_mls_events(
        ctx,
        team,
    )

    if events == None:
        c.text_center(
            "MLS DATA OFFLINE",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    live = mls_live_match(
        events,
        team,
    )

    if live != None:
        c.text("LIVE", 4, 0, font = "3x4", color = color)
        api_team = mls_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = mls_display_team(
            opponent["abbr"]
        )

        draw_crest(c,
            mls_team_crest(team),
            17,
            2,
            22,
            22,
        )

        draw_crest(c,
            mls_team_crest(opponent_team),
            88,
            2,
            22,
            22,
        )

        c.text(
            team,
            28,
            25,
            font = "4x5",
            color = color,
            align = "center",
        )

        c.text(
            opponent_team,
            108,
            25,
            font = "4x5",
            color = TEXT,
            align = "center",
        )

        score = (
            tracked_score(live, api_team) +
            "-" +
            opponent_score(live, api_team)
        )

        c.text(
            score,
            64,
            10,
            font = "6x8",
            color = TEXT,
            align = "center",
        )

        c.text_center(
            live["detail"],
            22,
            font = "4x5",
            color = color,
        )

        return

    next_match = mls_next_match(
        events,
        team,
    )

    if next_match == None:
        c.text_center(
            "NO UPCOMING GAME",
            13,
            font = "5x7",
            color = DIM,
        )
        return

    api_team = mls_api_team(team)

    opponent = opponent_of(
        next_match,
        api_team,
    )

    opponent_team = mls_display_team(
        opponent["abbr"]
    )

    if next_match["home"]["abbr"] == api_team:
        symbol = "VS"
    else:
        symbol = "@"

    draw_crest(c,
        mls_team_crest(team),
        18,
        3,
        20,
        20,
    )

    draw_crest(c,
        mls_team_crest(opponent_team),
        89,
        3,
        20,
        20,
    )

    c.text(
        team,
        28,
        25,
        font = "4x5",
        color = color,
        align = "center",
    )

    c.text(
        opponent_team,
        100,
        25,
        font = "4x5",
        color = TEXT,
        align = "center",
    )

    c.text(
        symbol,
        64,
        10,
        font = "6x8",
        color = TEXT,
        align = "center",
    )

    c.text_center(
        simple_date_text(
            next_match["date"], ctx
        ),
        22,
        font = "4x5",
        color = color,
    )

# Verified team IDs from ESPN and MLB team feeds (September 2026).
TEAM_IDS = {'nfl': {'ARI': '22', 'ATL': '1', 'BAL': '33', 'BUF': '2', 'CAR': '29', 'CHI': '3', 'CIN': '4', 'CLE': '5', 'DAL': '6', 'DEN': '7', 'DET': '8', 'GB': '9', 'HOU': '34', 'IND': '11', 'JAX': '30', 'KC': '12', 'LV': '13', 'LAC': '24', 'LAR': '14', 'MIA': '15', 'MIN': '16', 'NE': '17', 'NO': '18', 'NYG': '19', 'NYJ': '20', 'PHI': '21', 'PIT': '23', 'SEA': '26', 'SF': '25', 'TB': '27', 'TEN': '10', 'WSH': '28'}, 'nba': {'ATL': '1', 'BOS': '2', 'BKN': '17', 'CHA': '30', 'CHI': '4', 'CLE': '5', 'DAL': '6', 'DEN': '7', 'DET': '8', 'GSW': '9', 'HOU': '10', 'IND': '11', 'LAC': '12', 'LAL': '13', 'MEM': '29', 'MIA': '14', 'MIL': '15', 'MIN': '16', 'NOP': '3', 'NYK': '18', 'OKC': '25', 'ORL': '19', 'PHI': '20', 'PHX': '21', 'POR': '22', 'SAC': '23', 'SAS': '24', 'TOR': '28', 'UTA': '26', 'WAS': '27'}, 'nhl': {'ANA': '25', 'BOS': '1', 'BUF': '2', 'CGY': '3', 'CAR': '7', 'CHI': '4', 'COL': '17', 'CBJ': '29', 'DAL': '9', 'DET': '5', 'EDM': '6', 'FLA': '26', 'LAK': '8', 'MIN': '30', 'MTL': '10', 'NSH': '27', 'NJD': '11', 'NYI': '12', 'NYR': '13', 'OTT': '14', 'PHI': '15', 'PIT': '16', 'SJS': '18', 'SEA': '124292', 'STL': '19', 'TBL': '20', 'TOR': '21', 'UTA': '129764', 'VAN': '22', 'VGK': '37', 'WSH': '23', 'WPG': '28'}, 'mls': {'ATL': '18418', 'ATX': '20906', 'CHI': '182', 'CIN': '18267', 'CLT': '21300', 'CLB': '183', 'COL': '184', 'DAL': '185', 'DCU': '193', 'HOU': '6077', 'LA': '187', 'LAFC': '18966', 'MIA': '20232', 'MIN': '17362', 'MTL': '9720', 'NSH': '18986', 'NE': '189', 'NYC': '17606', 'RBNY': '190', 'ORL': '12011', 'PHI': '10739', 'POR': '9723', 'RSL': '4771', 'SD': '22529', 'SEA': '9726', 'SJ': '191', 'SKC': '186', 'STL': '21812', 'TOR': '7318', 'VAN': '9727'}, 'mlb': {'ARI': '109', 'ATH': '133', 'ATL': '144', 'BAL': '110', 'BOS': '111', 'CHC': '112', 'CHW': '145', 'CIN': '113', 'CLE': '114', 'COL': '115', 'DET': '116', 'HOU': '117', 'KC': '118', 'LAA': '108', 'LAD': '119', 'MIA': '146', 'MIL': '158', 'MIN': '142', 'NYM': '121', 'NYY': '147', 'PHI': '143', 'PIT': '134', 'SD': '135', 'SEA': '136', 'SF': '137', 'STL': '138', 'TB': '139', 'TEX': '140', 'TOR': '141', 'WSH': '120'}}
SPORT_TEAMS = {"nfl": NFL_TEAMS, "mlb": MLB_TEAMS, "nba": NBA_TEAMS, "nhl": NHL_TEAMS, "mls": MLS_TEAMS}
SPORT_PATHS = {"nfl": "football/nfl", "nba": "basketball/nba", "nhl": "hockey/nhl", "mls": "soccer/usa.1"}
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def list_value(value):
    return value if type(value) == "list" else []

def signed_stat_number(value):
    if type(value) == "int":
        return value
    if type(value) == "float":
        return int(value) if value == int(value) else None
    if type(value) != "string":
        return None
    text = value.strip().replace("−", "-")
    if text == "":
        return None
    digits = text[1:] if text[0] in ["+", "-"] else text
    if digits == "":
        return None
    for ch in digits.elems():
        if ch < "0" or ch > "9":
            return None
    return int(text)

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + 1 if m <= 2 else y, m, d]

def parse_iso(value, offset_minutes):
    text = str(value).strip()

    if len(text) < 16:
        return None

    digits = text[0:4] + text[5:7] + text[8:10] + text[11:13] + text[14:16]
    for ch in digits.elems():
        if ch < "0" or ch > "9":
            return None
    y = int(text[0:4])
    mo = int(text[5:7])
    d = int(text[8:10])
    hh = int(text[11:13])
    mm = int(text[14:16])

    if y < 1970 or mo < 1 or mo > 12 or d < 1 or hh > 23 or mm > 59:
        return None
    leap = y % 400 == 0 or (y % 4 == 0 and y % 100 != 0)
    month_days = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if d > month_days[mo - 1]:
        return None

    mins = days_from_civil(y, mo, d) * 1440
    mins += hh * 60 + mm

    if not (text.endswith("Z") or text.endswith("+00:00")):
        return None
    return mins + offset_minutes

def draw_crest(c, name, x, y, width, height):
    if name != "":
        c.image(name, x, y, width, height)


def local_offset(minutes, zone):
    fixed = {"UTC": 0, "Pacific/Honolulu": -600, "America/Phoenix": -420}
    if zone in fixed:
        return fixed[zone]
    year = civil_from_days(minutes // 1440)[0]
    if zone == "Europe/London":
        march = days_from_civil(year, 3, 31)
        october = days_from_civil(year, 10, 31)
        start = (march - (march + 4) % 7) * 1440 + 60
        end = (october - (october + 4) % 7) * 1440 + 60
        return 60 if start <= minutes and minutes < end else 0
    standard = {"America/Anchorage": -540, "America/Los_Angeles": -480,
                "America/Denver": -420, "America/Chicago": -360, "America/New_York": -300}.get(zone, -480)
    march = days_from_civil(year, 3, 1)
    november = days_from_civil(year, 11, 1)
    start = (march + (7 - (march + 4) % 7) % 7 + 7) * 1440 + 120 - standard
    end = (november + (7 - (november + 4) % 7) % 7) * 1440 + 120 - standard - 60
    return standard + 60 if start <= minutes and minutes < end else standard


def team_code(league, info):
    identity = str(get(info, "id", ""))
    table = SPORT_TEAMS[league]
    for key in TEAM_IDS[league]:
        if TEAM_IDS[league][key] == identity:
            return table[key]["api"]
    return str(get(info, "abbreviation", "?")).upper()


def score_string(raw):
    if type(raw) == "dict":
        raw = get(raw, "displayValue", get(raw, "value", None))
    value = signed_stat_number(raw)
    return str(value) if value != None and value >= 0 else "-"


def select_match(events, api_team, state):
    best = None
    for event in list_value(events):
        if event["state"] != state:
            continue
        if event["home"]["abbr"] != api_team and event["away"]["abbr"] != api_team:
            continue
        if best == None or event["start"] < best["start"]:
            best = event
    return best


def parse_sport_events(data, league, ctx, fixtures=False):
    raw_events = get(data, "events", None)
    if type(raw_events) != "list":
        return None
    events = []
    for raw in raw_events:
        comps = list_value(get(raw, "competitions", []))
        for comp in comps:
            home = None
            away = None
            for competitor in list_value(get(comp, "competitors", [])):
                side = {"abbr": team_code(league, get(competitor, "team", {})),
                        "score": score_string(get(competitor, "score", None))}
                if get(competitor, "homeAway", "") == "home":
                    home = side
                elif get(competitor, "homeAway", "") == "away":
                    away = side
            if home == None or away == None:
                continue
            date = str(get(raw, "date", get(comp, "date", "")))
            start = parse_iso(date, 0)
            status = get(comp, "status", get(raw, "status", {}))
            stype = get(status, "type", {})
            state = str(get(stype, "state", "")).lower()
            status_name = str(get(stype, "name", "")).upper()
            if status_name in ["STATUS_POSTPONED", "STATUS_CANCELED", "STATUS_CANCELLED", "STATUS_SUSPENDED", "STATUS_ABANDONED"]:
                continue
            if state == "" and status_name == "" and fixtures and start != None and start > ctx.now.unix // 60:
                state = "pre"
            if state == "pre" and (start == None or start <= ctx.now.unix // 60):
                continue
            if state not in ["pre", "in"]:
                continue
            detail = str(get(stype, "shortDetail", get(stype, "detail", "LIVE"))).upper()
            events.append({"home": home, "away": away, "date": date,
                           "start": start if start != None else 0,
                           "state": state, "detail": detail[:19]})
    return events


def get_espn_events(url, league, ctx, fixtures=False):
    response = http.get(url, ttl_seconds=60)
    if get(response, "status_code", 0) != 200:
        return None
    return parse_sport_events(get(response, "json", {}), league, ctx, fixtures)


def read_sport_events(ctx, league, team):
    identity = TEAM_IDS[league].get(team, "")
    if identity == "":
        return None
    if league == "mlb":
        return read_mlb_schedule(ctx, identity)
    url = BASE + "site/v2/sports/" + SPORT_PATHS[league] + "/teams/" + identity + "/schedule"
    events = get_espn_events(url, league, ctx)
    if league == "mls":
        fixtures = get_espn_events(url + "?fixture=true", league, ctx, True)
        if events == None and fixtures == None:
            return None
        return list_value(events) + list_value(fixtures)
    return events


def iso_day(day):
    parts = civil_from_days(day)
    return str(parts[0]) + "-" + pad2(parts[1]) + "-" + pad2(parts[2])


def read_mlb_schedule(ctx, identity):
    today = ctx.now.unix // 86400
    url = ("https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=" + identity
           + "&startDate=" + iso_day(today - 1) + "&endDate=" + iso_day(today + 370)
           + "&hydrate=linescore&fields=dates,date,games,gamePk,gameDate,status,abstractGameState,detailedState,statusCode,teams,home,away,team,id,name,score,linescore,currentInning,inningState")
    response = http.get(url, ttl_seconds=60)
    data = get(response, "json", {})
    if get(response, "status_code", 0) != 200 or type(get(data, "dates", None)) != "list":
        return None
    events = []
    for day in data["dates"]:
        for game in list_value(get(day, "games", [])):
            teams = get(game, "teams", {})
            home = get(teams, "home", {})
            away = get(teams, "away", {})
            if get(home, "team", None) == None or get(away, "team", None) == None:
                continue
            status = get(game, "status", {})
            description = str(get(status, "detailedState", "")).upper()
            if "POSTPON" in description or "CANCEL" in description or "SUSPEND" in description:
                continue
            state = {"Live": "in", "Preview": "pre"}.get(get(status, "abstractGameState", ""), "post")
            date = str(get(game, "gameDate", ""))
            start = parse_iso(date, 0)
            if state == "post" or (state == "pre" and (start == None or start <= ctx.now.unix // 60)):
                continue
            line = get(game, "linescore", {})
            inning = get(line, "currentInning", None)
            detail = description
            if inning != None:
                detail = str(get(line, "inningState", "")).upper() + " " + str(inning)
            events.append({
                "home": {"abbr": team_code("mlb", get(home, "team", {})), "score": score_string(get(home, "score", None))},
                "away": {"abbr": team_code("mlb", get(away, "team", {})), "score": score_string(get(away, "score", None))},
                "state": state, "date": date, "start": start if start != None else 0, "detail": detail[:19],
            })
    return events
