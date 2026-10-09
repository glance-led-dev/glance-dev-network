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
    name = fit_team_name(c, name, 82)

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
        148,
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
