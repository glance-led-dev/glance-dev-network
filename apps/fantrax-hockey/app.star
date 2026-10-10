API_URL = "https://fantrax-public.mdarpino.workers.dev/api/league/"


# ------------------------------------------------------------
# DATA
# ------------------------------------------------------------

def make_demo_logo(primary, secondary, variant):
    pixels = []

    for y in range(16):
        for x in range(16):
            dx = x - 7
            dy = y - 7
            color = ""

            # Rounded team-badge background.
            if dx * dx + dy * dy <= 45:
                color = primary

            # Individual hockey-style marks.
            if variant == 0:
                # Star
                if (y == 3 and x >= 5 and x <= 9) or \
                   (x == 7 and y >= 2 and y <= 12) or \
                   (x + y == 10 and x >= 3 and x <= 7) or \
                   (x - y == 4 and x >= 7 and x <= 11):
                    color = secondary

            elif variant == 1:
                # Snowflake
                if x == 7 or y == 7 or x == y or x + y == 14:
                    if x >= 3 and x <= 11 and y >= 3 and y <= 11:
                        color = secondary

            elif variant == 2:
                # Hockey puck / speed stripe
                if y >= 6 and y <= 9 and x >= 3 and x <= 11:
                    color = secondary
                if y == 5 and x >= 5 and x <= 10:
                    color = secondary

            elif variant == 3:
                # Shield
                if ((x == 4 or x == 10) and y >= 4 and y <= 9) or \
                   (y == 4 and x >= 4 and x <= 10) or \
                   (x + y == 16 and x >= 6 and x <= 9) or \
                   (x - y == -2 and x >= 5 and x <= 7):
                    color = secondary

            elif variant == 4:
                # Crown
                if y == 9 and x >= 3 and x <= 11:
                    color = secondary
                if y >= 5 and y <= 8 and \
                   (x == 3 or x == 7 or x == 11):
                    color = secondary
                if y == 8 and x >= 3 and x <= 11:
                    color = secondary

            elif variant == 5:
                # Crossed sticks
                if (x == y and x >= 3 and x <= 11) or \
                   (x + y == 14 and x >= 3 and x <= 11):
                    color = secondary
                if y == 11 and (x == 2 or x == 12):
                    color = secondary

            elif variant == 6:
                # Lightning bolt
                if (y >= 3 and y <= 7 and x == 9 - (y - 3)) or \
                   (y >= 7 and y <= 12 and x == 7 - (y - 7) // 2):
                    color = secondary
                if y == 7 and x >= 5 and x <= 9:
                    color = secondary

            if color:
                pixels.append([x, y, color])

    return {"pixels": pixels}

def demo_data():
    return {
        "team_count": 14,
        "supported": {"league_supported": True},
        "logos": {
            "demo1": make_demo_logo("#123B7A", "#F6C945", 0),
            "demo2": make_demo_logo("#6CCFF6", "#FFFFFF", 1),
            "demo3": make_demo_logo("#C62828", "#FFFFFF", 2),
            "demo4": make_demo_logo("#1E5AA8", "#F5D547", 3),
            "demo5": make_demo_logo("#54278F", "#F5A623", 4),
            "demo6": make_demo_logo("#111111", "#D32F2F", 5),
            "demo7": make_demo_logo("#00695C", "#FFFFFF", 6),
            "demo8": make_demo_logo("#8E2430", "#F4C542", 3),
            "demo9": make_demo_logo("#E65100", "#FFFFFF", 6),
            "demo10": make_demo_logo("#3A3A3A", "#5BC0EB", 1),
            "demo11": make_demo_logo("#154734", "#F9D616", 2),
            "demo12": make_demo_logo("#A00032", "#FFFFFF", 5),
            "demo13": make_demo_logo("#1C2D5A", "#E31B23", 4),
            "demo14": make_demo_logo("#4A148C", "#00BCD4", 0),
        },
        "matchups": [
            {"away": {"id": "demo1", "name": "NORTH STARS", "score": 34.25}, "home": {"id": "demo2", "name": "ICE BREAKERS", "score": 29.70}},
            {"away": {"id": "demo3", "name": "HAT TRICK HEROES", "score": 41.10}, "home": {"id": "demo4", "name": "BLUE LINE", "score": 38.65}},
            {"away": {"id": "demo5", "name": "PUCK DYNASTY", "score": 27.90}, "home": {"id": "demo6", "name": "GOAL DIGGERS", "score": 31.45}},
            {"away": {"id": "demo7", "name": "TOP SHELF", "score": 45.20}, "home": {"id": "demo8", "name": "BENCH WARMERS", "score": 33.80}},
            {"away": {"id": "demo9", "name": "POWER PLAY", "score": 36.75}, "home": {"id": "demo10", "name": "FROZEN FOUR", "score": 35.95}},
            {"away": {"id": "demo11", "name": "FIVE HOLE", "score": 22.40}, "home": {"id": "demo12", "name": "SLAP SHOTS", "score": 28.15}},
            {"away": {"id": "demo13", "name": "RINK RATS", "score": 39.60}, "home": {"id": "demo14", "name": "BREAKAWAY", "score": 42.05}},
        ],
    }

def fetch_data(ctx):
    leagueid = str(ctx.inputs.get("leagueid", "") or "").strip()
    apikey = str(ctx.inputs.get("apikey", "") or "").strip()

    if not leagueid or not apikey:
        return demo_data()

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

