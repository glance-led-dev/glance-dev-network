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
    if obj == None:
        return fallback
    if key in obj:
        return obj[key]
    return fallback


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
    current_resp = http.get(
        NFL_URL,
        ttl_seconds = 60,
    )

    if current_resp["status_code"] != 200:
        return None

    current_data = current_resp["json"]

    if current_data == None:
        return None

    season_year = dig(
        current_data,
        ["season", "year"],
        ctx.now.year,
    )

    season_type = dig(
        current_data,
        ["season", "type"],
        2,
    )

    current_week = dig(
        current_data,
        ["week", "number"],
        1,
    )

    next_week = current_week + 1

    next_url = (
        NFL_URL +
        "?dates=" + str(season_year) +
        "&seasontype=" + str(season_type) +
        "&week=" + str(next_week)
    )

    next_resp = http.get(
        next_url,
        ttl_seconds = 60,
    )

    current_events = get(
        current_data,
        "events",
        [],
    )

    next_events = []

    if (
        next_resp["status_code"] == 200 and
        next_resp["json"] != None
    ):
        next_events = get(
            next_resp["json"],
            "events",
            [],
        )

    events = []

    for raw_event in current_events:
        competitions = get(
            raw_event,
            "competitions",
            [],
        )

        if len(competitions) == 0:
            continue

        competition = competitions[0]

        competitors = get(
            competition,
            "competitors",
            [],
        )

        if len(competitors) < 2:
            continue

        home = None
        away = None

        for competitor in competitors:
            side = str(
                get(
                    competitor,
                    "homeAway",
                    "",
                )
            ).lower()

            team = {
                "abbr": str(
                    dig(
                        competitor,
                        ["team", "abbreviation"],
                        "?",
                    )
                ).upper(),

                "score": str(
                    get(
                        competitor,
                        "score",
                        "0",
                    )
                ),
            }

            if side == "home":
                home = team

            if side == "away":
                away = team

        if home == None or away == None:
            continue

        events.append({
            "home": home,
            "away": away,

            "state": str(
                dig(
                    raw_event,
                    ["status", "type", "state"],
                    "",
                )
            ).lower(),

            "detail": str(
                dig(
                    raw_event,
                    ["status", "type", "shortDetail"],
                    "",
                )
            ).upper(),

            "date": str(
                get(
                    raw_event,
                    "date",
                    "",
                )
            ),
        })

    for raw_event in next_events:
        competitions = get(
            raw_event,
            "competitions",
            [],
        )

        if len(competitions) == 0:
            continue

        competition = competitions[0]

        competitors = get(
            competition,
            "competitors",
            [],
        )

        if len(competitors) < 2:
            continue

        home = None
        away = None

        for competitor in competitors:
            side = str(
                get(
                    competitor,
                    "homeAway",
                    "",
                )
            ).lower()

            team = {
                "abbr": str(
                    dig(
                        competitor,
                        ["team", "abbreviation"],
                        "?",
                    )
                ).upper(),

                "score": str(
                    get(
                        competitor,
                        "score",
                        "0",
                    )
                ),
            }

            if side == "home":
                home = team

            if side == "away":
                away = team

        if home == None or away == None:
            continue

        events.append({
            "home": home,
            "away": away,

            "state": str(
                dig(
                    raw_event,
                    ["status", "type", "state"],
                    "",
                )
            ).lower(),

            "detail": str(
                dig(
                    raw_event,
                    ["status", "type", "shortDetail"],
                    "",
                )
            ).upper(),

            "date": str(
                get(
                    raw_event,
                    "date",
                    "",
                )
            ),
        })

    return events


def nfl_live_match(events, team):
    api_team = nfl_api_team(team)

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if involved and event["state"] == "in":
            return event

    return None


def nfl_next_match(events, team):
    api_team = nfl_api_team(team)
    best = None

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if not involved:
            continue

        if event["state"] != "pre":
            continue

        if best == None or event["date"] < best["date"]:
            best = event

    return best


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


def simple_date_text(iso):
    if len(iso) < 10:
        return ""

    month = iso[5:7]
    day = iso[8:10]

    months = {
        "01": "JAN",
        "02": "FEB",
        "03": "MAR",
        "04": "APR",
        "05": "MAY",
        "06": "JUN",
        "07": "JUL",
        "08": "AUG",
        "09": "SEP",
        "10": "OCT",
        "11": "NOV",
        "12": "DEC",
    }

    month_text = get(months, month, "")

    if len(day) == 2 and day[0] == "0":
        day = day[1:]

    return month_text + " " + day


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
    c.image(
        "NFL22.png",
        4,
        0,
        22,
        22,
    )

    # MLB
    c.image(
        "MLB22.png",
        29,
        0,
        22,
        22,
    )

    # NBA
    c.image(
        "Jerry-West-the-NBA-Logo-500x281.png",
        49,
        -4,
        30,
        30,
    )

    # NHL
    c.image(
        "nhl-1-logo-png-transparent.png",
        75,
        0,
        22,
        22,
    )

    # MLS
    c.image(
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
        api_team = nfl_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = nfl_display_team(
            opponent["abbr"]
        )

        # Selected team crest
        c.image(
            nfl_team_crest(team),
            17,
            4,
            22,
            22,
        )

        # Opponent crest
        c.image(
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
    c.image(
        nfl_team_crest(team),
        17,
        4,
        22,
        22,
    )

    # Opponent crest
    c.image(
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
            next_match["date"]
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
        api_team = mlb_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = mlb_display_team(
            opponent["abbr"]
        )

        c.image(
            mlb_team_crest(team),
            17,
            6,
            20,
            20,
        )

        c.image(
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

    c.image(
        mlb_team_crest(team),
        18,
        2,
        21,
        21,
    )

    c.image(
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
            next_match["date"]
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
    now = ctx.now

    future = add_days(
        now.year,
        now.month,
        now.day,
        3,
    )

    start_date = (
        str(now.year) +
        pad2(now.month) +
        pad2(now.day)
    )

    end_date = (
        str(future[0]) +
        pad2(future[1]) +
        pad2(future[2])
    )

    url = (
        MLB_URL +
        "?dates=" +
        start_date +
        "-" +
        end_date +
        "&limit=100"
    )

    resp = http.get(
        url,
        ttl_seconds = 60,
    )

    if resp["status_code"] != 200:
        return None

    data = resp["json"]

    if data == None:
        return None

    raw_events = get(
        data,
        "events",
        [],
    )

    events = []

    for raw_event in raw_events:
        competitions = get(
            raw_event,
            "competitions",
            [],
        )

        if len(competitions) == 0:
            continue

        competition = competitions[0]

        competitors = get(
            competition,
            "competitors",
            [],
        )

        if len(competitors) < 2:
            continue

        home = None
        away = None

        for competitor in competitors:
            side = str(
                get(
                    competitor,
                    "homeAway",
                    "",
                )
            ).lower()

            mlb_team = {
                "abbr": str(
                    dig(
                        competitor,
                        ["team", "abbreviation"],
                        "?",
                    )
                ).upper(),

                "score": str(
                    get(
                        competitor,
                        "score",
                        "0",
                    )
                ),
            }

            if side == "home":
                home = mlb_team

            if side == "away":
                away = mlb_team

        if home == None or away == None:
            continue

        events.append({
            "home": home,
            "away": away,

            "state": str(
                dig(
                    raw_event,
                    ["status", "type", "state"],
                    "",
                )
            ).lower(),

            "detail": str(
                dig(
                    raw_event,
                    ["status", "type", "shortDetail"],
                    "",
                )
            ).upper(),

            "date": str(
                get(
                    raw_event,
                    "date",
                    "",
                )
            ),
        })

    return events

def mlb_live_match(events, team):
    api_team = mlb_api_team(team)

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if involved and event["state"] == "in":
            return event

    return None


def mlb_next_match(events, team):
    api_team = mlb_api_team(team)
    best = None

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if not involved:
            continue

        if event["state"] != "pre":
            continue

        if best == None or event["date"] < best["date"]:
            best = event

    return best

def read_nba_events(ctx, team):
    now = ctx.now

    future = add_days(
        now.year,
        now.month,
        now.day,
        30,
    )

    start_date = (
        str(now.year) +
        pad2(now.month) +
        pad2(now.day)
    )

    end_date = (
        str(future[0]) +
        pad2(future[1]) +
        pad2(future[2])
    )

    url = (
        NBA_URL +
        "?dates=" +
        start_date +
        "-" +
        end_date +
        "&limit=100"
    )

    resp = http.get(
        url,
        ttl_seconds = 60,
    )

    if resp["status_code"] != 200:
        return None

    data = resp["json"]

    if data == None:
        return None

    raw_events = get(
        data,
        "events",
        [],
    )

    events = []

    for raw_event in raw_events:
        competitions = get(
            raw_event,
            "competitions",
            [],
        )

        if len(competitions) == 0:
            continue

        competition = competitions[0]

        competitors = get(
            competition,
            "competitors",
            [],
        )

        if len(competitors) < 2:
            continue

        home = None
        away = None

        for competitor in competitors:
            side = str(
                get(
                    competitor,
                    "homeAway",
                    "",
                )
            ).lower()

            nba_team = {
                "abbr": str(
                    dig(
                        competitor,
                        ["team", "abbreviation"],
                        "?",
                    )
                ).upper(),

                "score": str(
                    get(
                        competitor,
                        "score",
                        "0",
                    )
                ),
            }

            if side == "home":
                home = nba_team

            if side == "away":
                away = nba_team

        if home == None or away == None:
            continue

        events.append({
            "home": home,
            "away": away,

            "state": str(
                dig(
                    raw_event,
                    ["status", "type", "state"],
                    "",
                )
            ).lower(),

            "detail": str(
                dig(
                    raw_event,
                    ["status", "type", "shortDetail"],
                    "",
                )
            ).upper(),

            "date": str(
                get(
                    raw_event,
                    "date",
                    "",
                )
            ),
        })

    return events


def nba_live_match(events, team):
    api_team = nba_api_team(team)

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if involved and event["state"] == "in":
            return event

    return None


def nba_next_match(events, team):
    api_team = nba_api_team(team)
    best = None

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if not involved:
            continue

        if event["state"] != "pre":
            continue

        if best == None or event["date"] < best["date"]:
            best = event

    return best

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
        api_team = nba_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = nba_display_team(
            opponent["abbr"]
        )

        c.image(
            nba_team_crest(team),
            17,
            3,
            22,
            22,
        )

        c.image(
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

    c.image(
        nba_team_crest(team),
        17,
        3,
        22,
        22,
    )

    c.image(
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
            next_match["date"]
        ),
        22,
        font = "4x5",
        color = color,
    )

def read_nhl_events(ctx, team):
    now = ctx.now

    future = add_days(
        now.year,
        now.month,
        now.day,
        30,
    )

    start_date = (
        str(now.year) +
        pad2(now.month) +
        pad2(now.day)
    )

    end_date = (
        str(future[0]) +
        pad2(future[1]) +
        pad2(future[2])
    )

    url = (
        NHL_URL +
        "?dates=" +
        start_date +
        "-" +
        end_date +
        "&limit=100"
    )

    resp = http.get(
        url,
        ttl_seconds = 60,
    )

    if resp["status_code"] != 200:
        return None

    data = resp["json"]

    if data == None:
        return None

    raw_events = get(
        data,
        "events",
        [],
    )

    events = []

    for raw_event in raw_events:
        competitions = get(
            raw_event,
            "competitions",
            [],
        )

        if len(competitions) == 0:
            continue

        competition = competitions[0]

        competitors = get(
            competition,
            "competitors",
            [],
        )

        if len(competitors) < 2:
            continue

        home = None
        away = None

        for competitor in competitors:
            side = str(
                get(
                    competitor,
                    "homeAway",
                    "",
                )
            ).lower()

            nhl_team = {
                "abbr": str(
                    dig(
                        competitor,
                        ["team", "abbreviation"],
                        "?",
                    )
                ).upper(),

                "score": str(
                    get(
                        competitor,
                        "score",
                        "0",
                    )
                ),
            }

            if side == "home":
                home = nhl_team

            if side == "away":
                away = nhl_team

        if home == None or away == None:
            continue

        events.append({
            "home": home,
            "away": away,

            "state": str(
                dig(
                    raw_event,
                    ["status", "type", "state"],
                    "",
                )
            ).lower(),

            "detail": str(
                dig(
                    raw_event,
                    ["status", "type", "shortDetail"],
                    "",
                )
            ).upper(),

            "date": str(
                get(
                    raw_event,
                    "date",
                    "",
                )
            ),
        })

    return events


def nhl_live_match(events, team):
    api_team = nhl_api_team(team)

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if involved and event["state"] == "in":
            return event

    return None


def nhl_next_match(events, team):
    api_team = nhl_api_team(team)
    best = None

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if not involved:
            continue

        if event["state"] != "pre":
            continue

        if best == None or event["date"] < best["date"]:
            best = event

    return best


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
        api_team = nhl_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = nhl_display_team(
            opponent["abbr"]
        )

        c.image(
            nhl_team_crest(team),
            17,
            3,
            22,
            22,
        )

        c.image(
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

    c.image(
        nhl_team_crest(team),
        17,
        3,
        22,
        22,
    )

    c.image(
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
            next_match["date"]
        ),
        22,
        font = "4x5",
        color = color,
    )

def read_mls_events(ctx, team):
    now = ctx.now

    future = add_days(
        now.year,
        now.month,
        now.day,
        14,
    )

    start_date = (
        str(now.year) +
        pad2(now.month) +
        pad2(now.day)
    )

    end_date = (
        str(future[0]) +
        pad2(future[1]) +
        pad2(future[2])
    )

    url = (
        MLS_URL +
        "?dates=" +
        start_date +
        "-" +
        end_date +
        "&limit=100"
    )

    resp = http.get(
        url,
        ttl_seconds = 60,
    )

    if resp["status_code"] != 200:
        return None

    data = resp["json"]

    if data == None:
        return None

    raw_events = get(
        data,
        "events",
        [],
    )

    events = []

    for raw_event in raw_events:
        competitions = get(
            raw_event,
            "competitions",
            [],
        )

        if len(competitions) == 0:
            continue

        competition = competitions[0]

        competitors = get(
            competition,
            "competitors",
            [],
        )

        if len(competitors) < 2:
            continue

        home = None
        away = None

        for competitor in competitors:
            side = str(
                get(
                    competitor,
                    "homeAway",
                    "",
                )
            ).lower()

            mls_team = {
                "abbr": str(
                    dig(
                        competitor,
                        ["team", "abbreviation"],
                        "?",
                    )
                ).upper(),

                "score": str(
                    get(
                        competitor,
                        "score",
                        "0",
                    )
                ),
            }

            if side == "home":
                home = mls_team

            if side == "away":
                away = mls_team

        if home == None or away == None:
            continue

        events.append({
            "home": home,
            "away": away,

            "state": str(
                dig(
                    raw_event,
                    ["status", "type", "state"],
                    "",
                )
            ).lower(),

            "detail": str(
                dig(
                    raw_event,
                    ["status", "type", "shortDetail"],
                    "",
                )
            ).upper(),

            "date": str(
                get(
                    raw_event,
                    "date",
                    "",
                )
            ),
        })

    return events


def mls_live_match(events, team):
    api_team = mls_api_team(team)

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if involved and event["state"] == "in":
            return event

    return None


def mls_next_match(events, team):
    api_team = mls_api_team(team)
    best = None

    for event in events:
        involved = (
            event["home"]["abbr"] == api_team or
            event["away"]["abbr"] == api_team
        )

        if not involved:
            continue

        if event["state"] != "pre":
            continue

        if best == None or event["date"] < best["date"]:
            best = event

    return best

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
        api_team = mls_api_team(team)

        opponent = opponent_of(
            live,
            api_team,
        )

        opponent_team = mls_display_team(
            opponent["abbr"]
        )

        c.image(
            mls_team_crest(team),
            17,
            2,
            22,
            22,
        )

        c.image(
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

    c.image(
        mls_team_crest(team),
        18,
        3,
        20,
        20,
    )

    c.image(
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
            next_match["date"]
        ),
        22,
        font = "4x5",
        color = color,
    )