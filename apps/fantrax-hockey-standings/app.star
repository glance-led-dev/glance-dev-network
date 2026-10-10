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
        "standings": [
            {"id": "demo1", "rank": 1, "name": "NORTH STARS", "wins": 8, "losses": 2, "points": 128.4},
            {"id": "demo2", "rank": 2, "name": "ICE BREAKERS", "wins": 7, "losses": 3, "points": 121.7},
            {"id": "demo3", "rank": 3, "name": "HAT TRICK HEROES", "wins": 7, "losses": 3, "points": 118.9},
            {"id": "demo4", "rank": 4, "name": "BLUE LINE", "wins": 6, "losses": 4, "points": 114.2},
            {"id": "demo5", "rank": 5, "name": "PUCK DYNASTY", "wins": 6, "losses": 4, "points": 109.8},
            {"id": "demo6", "rank": 6, "name": "GOAL DIGGERS", "wins": 5, "losses": 5, "points": 105.5},
            {"id": "demo7", "rank": 7, "name": "TOP SHELF", "wins": 5, "losses": 5, "points": 101.3},
            {"id": "demo8", "rank": 8, "name": "BENCH WARMERS", "wins": 5, "losses": 5, "points": 98.6},
            {"id": "demo9", "rank": 9, "name": "POWER PLAY", "wins": 4, "losses": 6, "points": 94.1},
            {"id": "demo10", "rank": 10, "name": "FROZEN FOUR", "wins": 4, "losses": 6, "points": 89.7},
            {"id": "demo11", "rank": 11, "name": "FIVE HOLE", "wins": 3, "losses": 7, "points": 85.2},
            {"id": "demo12", "rank": 12, "name": "SLAP SHOTS", "wins": 3, "losses": 7, "points": 81.4},
            {"id": "demo13", "rank": 13, "name": "RINK RATS", "wins": 2, "losses": 8, "points": 76.8},
            {"id": "demo14", "rank": 14, "name": "BREAKAWAY", "wins": 1, "losses": 9, "points": 71.6},
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


def get_standings(data):
    if data == None:
        return []

    return data.get("standings", []) or []


def league_supported(data):
    if data == None:
        return True

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
    # A 16x16 logo is at most 256 c.pixel() calls. Two rows remain
    # comfortably below GDN's 4096-op page limit.
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

    for maximum in range(22, 4, -1):
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
# STANDINGS ROW
# ------------------------------------------------------------

def draw_standing_row(c, data, team, y, color):
    rank = safe_str(team.get("rank", ""))
    name = team_name(team)
    wins = safe_str(team.get("wins", 0))
    losses = safe_str(team.get("losses", 0))
    points = safe_str(team.get("points", 0))
    pixels = team_logo_pixels(data, team)

    # Rank
    c.text(
        rank,
        4,
        y + 3,
        font = "6x8",
        color = color,
    )

    # Logo
    if pixels:
        draw_logo_pixels(c, pixels, 20, y)

    # Team name
    name = fit_team_name(c, name, 74)

    c.text(
        name,
        39,
        y + 3,
        font = "6x8",
        color = color,
    )

    # Wins - Losses
    record = wins + "-" + losses

    c.text(
        record,
        143,
        y + 3,
        font = "6x8",
        color = color,
        align = "right",
    )

    # Points. Keep this column tight to the right edge so the
    # record and fantasy-points columns never overlap.
    c.text(
        points,
        190,
        y + 3,
        font = "6x8",
        color = color,
        align = "right",
    )


# ------------------------------------------------------------
# STANDINGS SCREEN
# ------------------------------------------------------------

def draw_standings(c, ctx, start_index):
    data = fetch_data(ctx)

    if data == None:
        draw_message(c, "FANTRAX", "NO DATA")
        return

    if not league_supported(data):
        draw_message(c, "LEAGUE TOO LARGE", "MAX 14 TEAMS")
        return

    standings = get_standings(data)

    if not standings:
        draw_message(c, "FANTRAX", "NO STANDINGS")
        return

    if start_index >= len(standings):
        draw_message(c, "FANTRAX", safe_str(len(standings)) + " TEAMS")
        return

    c.fill("black")

    if start_index < len(standings):
        draw_standing_row(
            c,
            data,
            standings[start_index],
            0,
            "amber",
        )

    if start_index + 1 < len(standings):
        draw_standing_row(
            c,
            data,
            standings[start_index + 1],
            16,
            "white",
        )


# ------------------------------------------------------------
# PAGES
# ------------------------------------------------------------

def standings1(c, ctx):
    draw_standings(c, ctx, 0)


def standings2(c, ctx):
    draw_standings(c, ctx, 2)


def standings3(c, ctx):
    draw_standings(c, ctx, 4)


def standings4(c, ctx):
    draw_standings(c, ctx, 6)


def standings5(c, ctx):
    draw_standings(c, ctx, 8)


def standings6(c, ctx):
    draw_standings(c, ctx, 10)


def standings7(c, ctx):
    draw_standings(c, ctx, 12)
