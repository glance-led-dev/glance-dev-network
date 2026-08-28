# MLB Offensive Leaders (128x32)
#
# Top 4 batting leaders for a chosen category (AVG/HR/RBI/SB/Hits/Runs/SLG/OPS),
# filtered to MLB overall, AL, or NL. Data from MLB's own public Stats API
# (statsapi.mlb.com) - no key required.

TEAM_COLORS = {
    108: ["#BA0021", "#C4C9CC"],  # LAA (red, silver - navy dropped, too dark to read as a stripe)
    109: ["#A71930", "#000000"],  # AZ
    110: ["#DF4601", "#000000"],  # BAL
    111: ["#BD3039", "#0C2340"],  # BOS
    112: ["#0E3386", "#CC3433"],  # CHC
    113: ["#C6011F", "#000000"],  # CIN
    114: ["#E31937", "#0C2340"],  # CLE
    115: ["#333366", "#C4CED4"],  # COL (purple, silver - black dropped, too dark to read as a stripe)
    116: ["#0C2340", "#FA4616"],  # DET
    117: ["#002D62", "#EB6E1F"],  # HOU
    118: ["#004687", "#BD9B60"],  # KC
    119: ["#005A9C", "#FFFFFF"],  # LAD
    120: ["#AB0003", "#FFFFFF"],  # WSH (red, white - navy dropped, too dark to read as a stripe)
    121: ["#002D72", "#FF5910"],  # NYM
    133: ["#003831", "#EFB21E"],  # ATH
    134: ["#FDB827", "#000000"],  # PIT
    135: ["#2F241D", "#FFC425"],  # SD
    136: ["#0C2C56", "#005C5C"],  # SEA
    137: ["#FD5A1E", "#27251F"],  # SF
    138: ["#C41E3A", "#0C2340"],  # STL
    139: ["#092C5C", "#8FBCE6"],  # TB
    140: ["#003278", "#C0111F"],  # TEX
    141: ["#134A8E", "#E8291C"],  # TOR
    142: ["#002B5C", "#D31145"],  # MIN
    143: ["#E81828", "#000000"],  # PHI
    144: ["#13274F", "#CE1141"],  # ATL
    145: ["#27251F", "#C4CED4"],  # CWS
    146: ["#00A3E0", "#000000"],  # MIA
    147: ["#0C2340", "#B1B3B3"],  # NYY (navy, pinstripe silver - white dropped for accent purposes)
    158: ["#12284B", "#FFC52F"],  # MIL
}

# ---------- small input helper ----------
# An unset/cleared input can come back as None even with a fallback given to
# ctx.inputs.get(), so coerce before using it (see apps/local-aqi, apps/stocks, etc).

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return v

# ---------- color helpers ----------

def _hash(n):
    n = (n * 2654435761) % 2147483647
    n = (n ^ (n // 65536)) % 2147483647
    return n

MIN_STRIPE_BRIGHTNESS = 60  # below this, a color reads as invisible against the black row background

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def pick_color(colors, team_id, day_seed):
    h = _hash(day_seed * 92821 + team_id * 7919)
    idx = h % len(colors)
    chosen = colors[idx]
    if brightness(chosen) >= MIN_STRIPE_BRIGHTNESS:
        return chosen

    # too dark to read as a stripe - fall back to the brightest option this team has
    best = chosen
    best_brightness = brightness(chosen)
    for color in colors:
        b = brightness(color)
        if b > best_brightness:
            best = color
            best_brightness = b
    return best

# The category leader's text gets a stronger accent color than the plain stripe:
# never near-black (illegible/looks disabled) and never near-white (reads as "no
# color", defeating the point of a team accent).
ACCENT_MIN_BRIGHTNESS = 40
ACCENT_MAX_BRIGHTNESS = 235

def pick_accent_color(colors, team_id, day_seed):
    h = _hash(day_seed * 92821 + team_id * 7919 + 101)
    in_band = []
    for color in colors:
        b = brightness(color)
        if b >= ACCENT_MIN_BRIGHTNESS and b <= ACCENT_MAX_BRIGHTNESS:
            in_band.append(color)
    if len(in_band) > 0:
        return in_band[h % len(in_band)]

    # nothing in the ideal band - pick whichever color lands closest to it
    mid = (ACCENT_MIN_BRIGHTNESS + ACCENT_MAX_BRIGHTNESS) // 2
    best = colors[0]
    best_dist = abs(brightness(colors[0]) - mid)
    for color in colors:
        dist = abs(brightness(color) - mid)
        if dist < best_dist:
            best = color
            best_dist = dist
    return best

# ---------- network (keyless) ----------

def fetch_leaders(stat_key, league_id, season):
    if league_id == None:
        return http.get(
            "https://statsapi.mlb.com/api/v1/stats/leaders",
            params = {
                "leaderCategories": stat_key,
                "statGroup": "hitting",
                "season": str(season),
                "sportId": "1",
                "limit": "4",
            },
            ttl_seconds = 14400,
        )
    return http.get(
        "https://statsapi.mlb.com/api/v1/stats/leaders",
        params = {
            "leaderCategories": stat_key,
            "statGroup": "hitting",
            "season": str(season),
            "sportId": "1",
            "leagueId": str(league_id),
            "limit": "4",
        },
        ttl_seconds = 14400,
    )

def fetch_teams():
    return http.get(
        "https://statsapi.mlb.com/api/v1/teams",
        params = {"sportId": "1"},
        ttl_seconds = 2592000,
    )

def team_abbrev_map():
    resp = fetch_teams()
    m = {}
    if resp["status_code"] != 200:
        return m
    for t in resp["json"].get("teams", []):
        m[t["id"]] = t.get("abbreviation", "")
    return m

def league_id_for(league_choice):
    if league_choice == "AL":
        return 103
    if league_choice == "NL":
        return 104
    return None

# ---------- drawing ----------

def draw_leaderboard(c, ctx, stat_key, label):
    c.fill("black")

    league_choice = _s(ctx, "league", "MLB")
    league_id = league_id_for(league_choice)

    resp = fetch_leaders(stat_key, league_id, ctx.now.year)
    if resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        return

    blocks = resp["json"].get("leagueLeaders", [])
    if len(blocks) == 0 or len(blocks[0].get("leaders", [])) == 0:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        return

    leaders = blocks[0]["leaders"][:4]
    abbrev = team_abbrev_map()
    day_seed = ctx.now.year * 1000 + ctx.now.yday

    header = (league_choice + " - " + label).upper()
    c.rect(0, 0, 127, 6, fill = "white")
    c.text(header, 64, 1, font = "4x5", color = "black", align = "center")

    y = 8
    for entry in leaders:
        rank = entry.get("rank", 0)
        name = entry.get("person", {}).get("lastName", "?")
        value = entry.get("value", "")
        team_id = entry.get("team", {}).get("id", -1)
        team_abbr = abbrev.get(team_id, "")
        colors = TEAM_COLORS.get(team_id, ["#444444"])
        stripe = pick_color(colors, team_id, day_seed)

        row_text = (str(rank) + " " + name + " - " + team_abbr).upper()
        text_col = pick_accent_color(colors, team_id, day_seed) if rank == 1 else "gray"

        c.rect(0, y - 1, 3, y + 5, fill = stripe)
        c.text(row_text, 6, y, font = "4x5", color = text_col, align = "left")
        c.text(str(value).upper(), 126, y, font = "4x5", color = text_col, align = "right")
        y += 6

# ---------- pages ----------

def avg(c, ctx):
    draw_leaderboard(c, ctx, "battingAverage", "BATTING AVG")

def hr(c, ctx):
    draw_leaderboard(c, ctx, "homeRuns", "HOME RUNS")

def rbi(c, ctx):
    draw_leaderboard(c, ctx, "rbi", "RBI")

def sb(c, ctx):
    draw_leaderboard(c, ctx, "stolenBases", "STOLEN BASES")

def hits(c, ctx):
    draw_leaderboard(c, ctx, "hits", "HITS")

def runs(c, ctx):
    draw_leaderboard(c, ctx, "runs", "RUNS")

def slg(c, ctx):
    draw_leaderboard(c, ctx, "sluggingPercentage", "SLUGGING PCT")

def ops(c, ctx):
    draw_leaderboard(c, ctx, "onBasePlusSlugging", "OPS")
