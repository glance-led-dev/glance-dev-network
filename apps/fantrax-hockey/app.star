API_URL = "https://fantrax-public.mdarpino.workers.dev/api/league/"


# ------------------------------------------------------------
# DATA
# ------------------------------------------------------------

def fetch_data(ctx):
    leagueid = str(ctx.inputs.get("leagueid", "") or "").strip()
    apikey = str(ctx.inputs.get("apikey", "") or "").strip()

    if not leagueid or not apikey:
        return None

    resp = http.get(
        API_URL + leagueid,
        headers = {
            "Authorization": "Bearer " + apikey,
            "Accept": "application/json",
        },
        ttl_seconds = 300,
    )

    if resp["status_code"] != 200:
        return None

    if resp["json"] == None:
        return None

    return resp["json"]


def get_matchups(data):
    if data == None:
        return []

    matchups = data.get("matchups", [])

    if not matchups:
        matchups = data.get("ticker_sample", [])

    return matchups or []


def league_supported(data):
    if data == None:
        return True

    # This app intentionally has 7 pages, so it supports up to
    # 7 matchups / 14 teams. The standings app can still support 16.
    matchups = get_matchups(data)

    if len(matchups) > 7:
        return False

    team_count = data.get("team_count", 0) or 0

    if team_count > 14:
        return False

    supported = data.get("supported", {}) or {}
    value = supported.get("league_supported")

    if value == False:
        return False

    return True


# ------------------------------------------------------------
# TEAM HELPERS
# ------------------------------------------------------------

def safe_str(value):
    if value == None:
        return ""

    return str(value)


def team_name(team):
    if team == None:
        return "TEAM"

    name = team.get("name", "")

    if not name:
        name = team.get("short_name", "")

    if not name:
        name = "TEAM"

    return safe_str(name).upper()


def team_score(team):
    if team == None:
        return ""

    score = team.get("score")

    if score == None:
        return "0"

    return safe_str(score)


def team_logo_asset(team):
    # Preserve the existing sample-league logo treatment. Other Fantrax
    # leagues still render normally; teams without a bundled asset simply
    # render without a logo.
    name = team_name(team)

    if name == "CROSSFIT PREEMS":
        return "crossfit-preems.png"

    if name == "DARPS":
        return "darps.png"

    if name == "EV":
        return "ev.png"

    if name == "FASH":
        return "fash.png"

    if name.startswith("GODSPLAN"):
        return "godsplan.png"

    if name == "GREEK":
        return "greek.png"

    if name == "HEBREW SCHOOL OF ECONOMICS":
        return "hebrew-school-of-economics.png"

    if name == "MIKEVERRELLI11":
        return "mikeverrelli11.png"

    if name.startswith("MILLS"):
        return "mills.png"

    if name == "MR. WRENCH":
        return "mr-wrench.png"

    if name == "PAGE 1":
        return "page-1.png"

    if name == "PETER":
        return "peter.png"

    if name == "PUT HIM IN THE BATHROOM":
        return "put-him-in-the-bathroom.png"

    if name == "SWATTY":
        return "swatty.png"

    if name == "WILL YOU BE MY NEIGHBOURS ?":
        return "will-you-be-my-neighbours.png"

    return ""


def team_logo_pixels(data, team):
    if data == None or team == None:
        return []

    team_id = safe_str(team.get("id", ""))
    if not team_id:
        return []

    logos = data.get("logos", {}) or {}
    logo = logos.get(team_id, {}) or {}
    return logo.get("pixels", []) or []


def draw_logo_pixels(c, pixels, x, y):
    # A 16x16 logo is at most 256 c.pixel() calls. With two team logos
    # this stays far below GDN's 4096-op page limit.
    for pixel in pixels:
        if len(pixel) < 3:
            continue

        px = pixel[0]
        py = pixel[1]
        value = pixel[2]

        if px < 0 or px >= 16 or py < 0 or py >= 16:
            continue

        c.pixel(x + px, y + py, value)


def fit_team_name(c, name, max_width):
    name = name.upper()

    if c.text_width(name, font = "6x8") <= max_width:
        return name

    short = name

    for maximum in range(22, 5, -1):
        candidate = name[:maximum]

        if c.text_width(candidate, font = "6x8") <= max_width:
            short = candidate
            break

    return short


# ------------------------------------------------------------
# MESSAGE SCREEN
# ------------------------------------------------------------

def draw_message(c, line1, line2 = ""):
    c.fill("black")

    c.text_center(
        line1.upper(),
        6,
        font = "6x8",
        color = "amber",
    )

    if line2:
        c.text_center(
            line2.upper(),
            19,
            font = "4x5",
            color = "white",
        )


# ------------------------------------------------------------
# TEAM ROW
# ------------------------------------------------------------

def draw_team_row(c, data, team, y, color):
    name = team_name(team)
    score = team_score(team)
    pixels = team_logo_pixels(data, team)

    if pixels:
        draw_logo_pixels(c, pixels, 0, y)
    else:
        # Bundled league assets remain a zero-cost fallback while a newly
        # seen remote logo is warming into the Worker cache.
        logo = team_logo_asset(team)

        if logo:
            c.image(
                logo,
                0,
                y,
                w = 16,
                h = 16,
            )

    name = fit_team_name(c, name, 126)

    c.text(
        name,
        19,
        y + 3,
        font = "6x8",
        color = color,
    )

    c.text(
        score,
        180,
        y + 3,
        font = "6x8",
        color = color,
        align = "right",
    )


# ------------------------------------------------------------
# MATCHUP SCREEN
# ------------------------------------------------------------

def draw_matchup(c, ctx, index):
    data = fetch_data(ctx)

    if data == None:
        draw_message(c, "FANTRAX", "NO DATA")
        return

    if not league_supported(data):
        draw_message(c, "LEAGUE TOO LARGE", "MAX 14 TEAMS")
        return

    matchups = get_matchups(data)

    if not matchups:
        draw_message(c, "FANTRAX", "NO MATCHUPS")
        return

    if index >= len(matchups):
        draw_message(c, "FANTRAX", safe_str(len(matchups)) + " MATCHUPS")
        return

    matchup = matchups[index]

    away = matchup.get("away", {}) or {}
    home = matchup.get("home", {}) or {}

    away_score = away.get("score", 0) or 0
    home_score = home.get("score", 0) or 0

    away_color = "white"
    home_color = "white"

    if away_score > home_score:
        away_color = "amber"
    elif home_score > away_score:
        home_color = "amber"

    c.fill("black")

    draw_team_row(
        c,
        data,
        away,
        0,
        away_color,
    )

    draw_team_row(
        c,
        data,
        home,
        16,
        home_color,
    )


# ------------------------------------------------------------
# PAGES
# ------------------------------------------------------------

def matchup1(c, ctx):
    draw_matchup(c, ctx, 0)


def matchup2(c, ctx):
    draw_matchup(c, ctx, 1)


def matchup3(c, ctx):
    draw_matchup(c, ctx, 2)


def matchup4(c, ctx):
    draw_matchup(c, ctx, 3)


def matchup5(c, ctx):
    draw_matchup(c, ctx, 4)


def matchup6(c, ctx):
    draw_matchup(c, ctx, 5)


def matchup7(c, ctx):
    draw_matchup(c, ctx, 6)

