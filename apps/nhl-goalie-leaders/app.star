# NHL Goalie Leaders (128x32)
#
# The top 3 goalie leaders in one stat per page (Goals Against Average,
# Save Percentage, Wins, Shutouts, Saves, Games Played, Points, Penalty
# Minutes), for the NHL overall, the Eastern Conference, or the Western
# Conference. Data from ESPN's public stats-by-athlete API
# (site.web.api.espn.com) - no key required. Sibling app to
# nhl-offensive-leaders, same scorebook template.
#
# Points and Penalty Minutes are light closers: goalies do pick up the odd
# assist and take real penalties (delay of game over the glass).
#
# Losses, OTL, Shots Against and Goals Against are left off: they aren't
# achievements.
#
# Save Percentage and Goals Against Average use the NHL's qualification
# rule: a goalie must have played at least 31.25% of his team's games,
# rounded up (27 of 84 by season's end). Team games come from the ESPN
# standings feed. Neither stat has a usable qualified sort, so both rank a
# pool of every goalie who has faced a shot (sorted by shots against, which
# skaters never have), locally. Games Played, Points and PIM use the same
# pool, since sorting those fields directly surfaces skaters.
#
# Values print as ESPN formats them: GAA "2.02", Save Pct ".921".

# id: [code, fill, ink]. Same table as nhl-offensive-leaders.
TEAMS = {
    25: ["ANA", "#FC4C02", "#000000"],   # Ducks: orange, black
    1: ["BOS", "#231F20", "#FDB71A"],    # Bruins: black, gold
    2: ["BUF", "#00468B", "#FDB71A"],    # Sabres: navy, gold
    3: ["CGY", "#DD1A32", "#000000"],    # Flames: red, black
    7: ["CAR", "#E30426", "#000000"],    # Hurricanes: red, black
    4: ["CHI", "#E31937", "#000000"],    # Blackhawks: red, black
    17: ["COL", "#860038", "#8FBCE6"],   # Avalanche: burgundy, light blue
    29: ["CBJ", "#002D62", "#FF4C4C"],   # Blue Jackets: navy, red
    9: ["DAL", "#20864C", "#000000"],    # Stars: green, black
    5: ["DET", "#E30526", "#FFFFFF"],    # Red Wings: red, white
    6: ["EDM", "#00205B", "#FF4C00"],    # Oilers: navy, orange
    26: ["FLA", "#E51937", "#FFFFFF"],   # Panthers: red, white
    8: ["LA", "#121212", "#A2AAAD"],     # Kings: black, silver
    30: ["MIN", "#124734", "#DDCBA4"],   # Wild: forest green, wheat
    10: ["MTL", "#C41230", "#FFFFFF"],   # Canadiens: red, white
    27: ["NSH", "#FDBA31", "#002D62"],   # Predators: gold, navy
    11: ["NJ", "#E30B2B", "#000000"],    # Devils: red, black
    12: ["NYI", "#00529B", "#F47D31"],   # Islanders: blue, orange
    13: ["NYR", "#0056AE", "#FFFFFF"],   # Rangers: blue, white
    14: ["OTT", "#DD1A32", "#B79257"],   # Senators: red, gold
    15: ["PHI", "#FE5823", "#000000"],   # Flyers: orange, black
    16: ["PIT", "#000000", "#FDB71A"],   # Penguins: black, gold
    18: ["SJ", "#00788A", "#070707"],    # Sharks: teal, black
    124292: ["SEA", "#000D33", "#A3DCE4"],  # Kraken: navy, ice blue
    19: ["STL", "#0070B9", "#FDB71A"],   # Blues: blue, gold
    20: ["TB", "#003E7E", "#FFFFFF"],    # Lightning: blue, white
    21: ["TOR", "#003E7E", "#FFFFFF"],   # Maple Leafs: blue, white
    129764: ["UTAH", "#000000", "#7AB2E1"],  # Mammoth: black, ice blue
    22: ["VAN", "#003E7E", "#FFFFFF"],   # Canucks: navy, white
    37: ["VGK", "#344043", "#B4975A"],   # Golden Knights: steel gray, gold
    23: ["WSH", "#D71830", "#FFFFFF"],   # Capitals: red, white
    28: ["WPG", "#002D62", "#FF4C57"],   # Jets: navy, red
}

TEAM_CONFERENCE = {
    # Eastern: Atlantic + Metropolitan
    1: "EAST", 2: "EAST", 5: "EAST", 26: "EAST", 10: "EAST", 14: "EAST", 20: "EAST", 21: "EAST",
    7: "EAST", 29: "EAST", 11: "EAST", 12: "EAST", 13: "EAST", 15: "EAST", 16: "EAST", 23: "EAST",
    # Western: Central + Pacific
    4: "WEST", 17: "WEST", 9: "WEST", 30: "WEST", 27: "WEST", 19: "WEST", 129764: "WEST", 28: "WEST",
    25: "WEST", 3: "WEST", 6: "WEST", 8: "WEST", 18: "WEST", 124292: "WEST", 22: "WEST", 37: "WEST",
}

# ---------- palette & grid ----------

INK = "#F4F7FF"      # names, live numbers, the stat title
DIM = "#6E7A94"       # ranks, season, sub-lines
AMBER = "#E8B04A"     # the one attention state (feed offline)
EAST_RED = "#D22D3A"
WEST_BLUE = "#2A66D9"

PAD = 6              # scroll safe zone, both edges
RANK_W = 5           # one 5x7 digit
BADGE_X = PAD + RANK_W + 2  # 13
BADGE_H = 7
NAME_GAP = 2
GAP = 3              # blank px between a name and its value
ROW_Y = [9, 17, 25]  # three 7px rows, 1px apart, under the 8px header row
HEAD_Y = 2           # 4x5 header text, centered on the badge

# Names get one font per page, not per row: a long last name in 4x7 beside a
# short one in 5x7 reads as a mistake. 5x7 when every name on the page fits,
# else 4x7, then a hard clip.
NAME_FONTS = ["5x7", "4x7"]
VALUE_FONT = "5x7"

# ---------- name normalization ----------
# The bitmap fonts only cover plain ASCII - an accented letter renders as a
# stray symbol otherwise, so strip to the closest ASCII letter first.
ACCENT_MAP = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
    "Ñ": "N", "Ç": "C", "Ý": "Y",
    "á": "a", "à": "a", "â": "a", "ä": "a", "ã": "a", "å": "a",
    "é": "e", "è": "e", "ê": "e", "ë": "e",
    "í": "i", "ì": "i", "î": "i", "ï": "i",
    "ó": "o", "ò": "o", "ô": "o", "ö": "o", "õ": "o",
    "ú": "u", "ù": "u", "û": "u", "ü": "u",
    "ñ": "n", "ç": "c", "ý": "y",
}

def strip_accents(s):
    out = ""
    for i in range(len(s)):
        ch = s[i]
        out += ACCENT_MAP.get(ch, ch)
    return out

# ---------- color helpers ----------

HEX = "0123456789ABCDEF"

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def blend(a, b, pct):
    # pct% of a over b
    out = "#"
    for i in [1, 3, 5]:
        v = (int(a[i:i + 2], 16) * pct + int(b[i:i + 2], 16) * (100 - pct)) // 100
        out += HEX[v // 16] + HEX[v % 16]
    return out

# ---------- network (keyless) ----------

def fetch_leaders(sort_key, limit = 32):
    return http.get(
        "https://site.web.api.espn.com/apis/common/v3/sports/hockey/nhl/statistics/byathlete",
        params = {
            "region": "us",
            "lang": "en",
            "contentorigin": "espn",
            "isqualified": "false",
            "seasontype": "2",
            "sort": sort_key + ":desc",
            "limit": str(limit),
        },
        # matches manifest.yaml's refresh - keep in sync
        ttl_seconds = 10800,
    )

def season_of(resp):
    return str((resp.get("json") or {}).get("currentSeason", {}).get("displayName") or "")

def league_choice(ctx):
    v = ctx.inputs.get("league", "NHL")
    return v if v in ("NHL", "EAST", "WEST") else "NHL"

def conference_for(lg):
    return lg if lg in ("EAST", "WEST") else None

# ---------- text helpers ----------

def clip(c, text, font, maxw):
    # Longest prefix that fits - nothing in the API clips on its own.
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for n in range(len(t), 0, -1):
        if c.text_width(t[:n], font) <= maxw:
            return t[:n]
    return ""

def page_font(c, strings, maxw):
    for f in NAME_FONTS:
        fits = True
        for s in strings:
            if c.text_width(s, f) > maxw:
                fits = False
                break
        if fits:
            return f
    return NAME_FONTS[-1]

def short_name(c, name, maxw):
    # A double-barrelled name that won't fit even in the smallest name font
    # keeps its last half whole rather than clipping mid-word.
    if "-" not in name or c.text_width(name, NAME_FONTS[-1]) <= maxw:
        return name
    parts = name.split("-")
    return parts[0][:1] + "-" + "-".join(parts[1:])

# ---------- chrome ----------

def league_chip(c, lg, x):
    # 7px pill opening the header: 4x5 text with 1px of fill above and
    # below, 2px either side. EAST/WEST get their own solid color; NHL (no
    # conference picked) has no real "third color" of its own, so it's a
    # red/blue split instead - the same two colors, half each.
    w = c.text_width(lg, "4x5") + 4
    if lg == "EAST":
        c.round_rect(x, 1, x + w - 1, 7, 1, fill = EAST_RED)
    elif lg == "WEST":
        c.round_rect(x, 1, x + w - 1, 7, 1, fill = WEST_BLUE)
    else:
        c.round_rect(x, 1, x + w - 1, 7, 1, fill = EAST_RED)
        c.rect(x + w // 2, 1, x + w - 1, 7, fill = WEST_BLUE)
    c.text(lg, x + 2, HEAD_Y, font = "4x5", color = "white")
    return x + w

def header(c, lg, titles, season):
    # titles runs longest first; the header takes the first that fits beside
    # the badge and season.
    right = c.width - PAD - 1
    x = league_chip(c, lg, PAD) + 3
    sw = 0
    if season != "":
        sw = c.text_width(season, "4x5")
        c.text(season, right, HEAD_Y, font = "4x5", color = DIM, align = "right")
    room = right - sw - 2 - x
    title = clip(c, titles[-1], "4x5", room)
    for t in titles:
        if c.text_width(t, "4x5") <= room:
            title = t
            break
    c.text(title, x, HEAD_Y, font = "4x5", color = INK)

def message(c, head, sub, head_color):
    # Sits in the band under the header row, so a failed page still says
    # which stat and league/conference it is.
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

# ---------- team badges ----------

def team_style(team_id, team_abbr):
    t = TEAMS.get(team_id)
    if t:
        return t
    # A club this table doesn't know (a bad/missing id): a neutral badge with
    # whatever code ESPN handed us beats a blank.
    return [team_abbr.upper() or "?", "#444444", "#FFFFFF"]

def badge_width(c):
    # One width for every badge so the names start on one column: the widest
    # code (UTAH, 4 chars at 4x5) plus 2px of fill either side.
    w = 0
    for t in TEAMS.values():
        w = max(w, c.text_width(t[0], "4x5"))
    return w + 4

def badge(c, x, y, w, style):
    code, fill, ink = style[0], style[1], style[2]
    # Navy/black fills vanish into the ground, so the dark ones get a rim -
    # a half-tone of their own ink, not gray.
    edge = blend(ink, fill, 50) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + w - 1, y + BADGE_H - 1, 1, fill = fill, outline = edge)
    c.text(clip(c, code, "4x5", w - 2), x + w // 2, y + 1, font = "4x5", color = ink, align = "center")

# ---------- the leaderboard ----------

def render_leaders(c, lg, titles, season, leaders):
    header(c, lg, titles, season)
    if len(leaders) == 0:
        return message(c, "NO STATS YET", "CHECK BACK IN SEASON", INK)

    rows = []
    for i in range(len(leaders)):
        e = leaders[i]
        rows.append({
            "rank": str(e["rank"]),
            "style": team_style(e["team_id"], e["team_abbr"]),
            "name": strip_accents(e["name"]).upper(),
            "value": str(e["value"]).upper(),
        })

    # Values right-aligned on the edge and measured first; the names get
    # what's left.
    right = c.width - PAD - 1
    bw = badge_width(c)
    name_x = BADGE_X + bw + NAME_GAP
    valw = 0
    for r in rows:
        valw = max(valw, c.text_width(r["value"], VALUE_FONT))
    room = right - valw - GAP - name_x + 1
    for r in rows:
        r["name"] = short_name(c, r["name"], room)
    font = page_font(c, [r["name"] for r in rows], room)

    for i in range(len(rows)):
        r = rows[i]
        y = ROW_Y[i]
        c.text(clip(c, r["rank"], "5x7", RANK_W), PAD + RANK_W // 2, y, font = "5x7", color = DIM, align = "center")
        badge(c, BADGE_X, y, bw, r["style"])
        c.text(clip(c, r["name"], font, room), name_x, y, font = font, color = INK)
        c.text(clip(c, r["value"], VALUE_FONT, valw), right, y, font = VALUE_FONT, color = INK, align = "right")

def is_positive(v):
    # A zero counting stat hasn't happened yet, so its row stays blank.
    # Not applied to GAA/Save Pct, where 0.00 is the best there is.
    s = str(v)
    if s == "" or s == "-":
        return False
    return float(s) > 0.0

def rank_candidates(candidates, allow_zero = False):
    # Competition ranking (1, 2, 2) over an already sorted, already
    # conference-filtered list.
    leaders = []
    prev_value = None
    prev_rank = 0
    for entry in candidates:
        if not allow_zero and not is_positive(entry["value"]):
            continue
        position = len(leaders) + 1
        rank = prev_rank if prev_value != None and entry["value"] == prev_value else position
        prev_value = entry["value"]
        prev_rank = rank
        entry["rank"] = rank
        leaders.append(entry)
        if len(leaders) >= len(ROW_Y):
            break
    return leaders

def draw_leaderboard(c, ctx, sort_key, category_name, idx, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)

    resp = fetch_leaders(sort_key)
    if resp["status_code"] != 200 or resp["json"] == None:
        header(c, lg, titles, "")
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    athletes = resp["json"].get("athletes", [])
    candidates = []
    for a in athletes:
        athlete = a.get("athlete", {})
        if athlete.get("position", {}).get("abbreviation") != "G":
            continue
        team_id = athlete.get("teamId", -1)
        team_id = int(team_id) if team_id != None else -1
        if conf != None and TEAM_CONFERENCE.get(team_id) != conf:
            continue
        value = ""
        for cat in a.get("categories", []):
            if cat.get("name") == category_name:
                totals = cat.get("totals", [])
                if idx < len(totals):
                    value = totals[idx]
        candidates.append({
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": team_id,
            "team_abbr": athlete.get("teamShortName", ""),
            "value": value,
        })
        if len(candidates) >= len(ROW_Y):
            break

    render_leaders(c, lg, titles, season_of(resp), rank_candidates(candidates))

# Every goalie who has faced a shot. Skaters have no shots against, so
# they sort to the bottom of this list.
GOALIE_POOL_SORT = "defensive.shotsAgainst"
GOALIE_POOL_LIMIT = 120


def stat_total_str(a, category_name, idx):
    # Raw formatted value as ESPN sends it - used for display and
    # same-string tie detection, never arithmetic.
    for cat in a.get("categories", []):
        if cat.get("name") == category_name:
            totals = cat.get("totals", [])
            if idx < len(totals):
                return totals[idx]
    return ""

def goalie_pool(conf):
    # Entries keep the whole response object `a`: the stat totals live in
    # its "categories", a sibling of "athlete".
    resp = fetch_leaders(GOALIE_POOL_SORT, limit = GOALIE_POOL_LIMIT)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None, ""
    pool = []
    for a in resp["json"].get("athletes", []):
        athlete = a.get("athlete", {})
        if athlete.get("position", {}).get("abbreviation") != "G":
            continue
        team_id = athlete.get("teamId", -1)
        team_id = int(team_id) if team_id != None else -1
        if conf != None and TEAM_CONFERENCE.get(team_id) != conf:
            continue
        games_str = stat_total_str(a, "general", 0)
        games = int(games_str) if games_str not in ("", "-") else 0
        pool.append({"a": a, "athlete": athlete, "team_id": team_id, "games": games})
    return pool, season_of(resp)

def team_games_played():
    # team id -> games played, from the standings; {} when the feed is down.
    resp = http.get("https://site.api.espn.com/apis/v2/sports/hockey/nhl/standings", ttl_seconds = 10800)
    if resp["status_code"] != 200 or resp["json"] == None:
        return {}
    out = {}
    groups = [resp["json"]]
    for _ in range(4):
        nxt = []
        for g in groups:
            for e in g.get("standings", {}).get("entries", []):
                tid = int(e.get("team", {}).get("id", "-1"))
                for st in e.get("stats", []):
                    if st.get("name") == "gamesPlayed":
                        out[tid] = int(st.get("value") or 0)
            nxt += g.get("children", [])
        groups = nxt
    return out

def games_needed(team_gp):
    # NHL qualification for Save Pct and GAA: 31.25% of the team's games,
    # rounded up, at least 1.
    return max(1, (team_gp * 3125 + 9999) // 10000)

def value_key(entry):
    return float(entry["value"])

def neg_value_key(entry):
    return -float(entry["value"])

def min_qualified_games(pool):
    # Fallback when the standings feed is down: the busiest goalie's games
    # stand in for team games played.
    max_games = 0
    for entry in pool:
        if entry["games"] > max_games:
            max_games = entry["games"]
    return games_needed(max_games)

def draw_qualified_rate_stat(c, ctx, category_name, idx, ascending, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)

    pool, season = goalie_pool(conf)
    if pool == None:
        header(c, lg, titles, "")
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    team_gp = team_games_played()
    fallback = min_qualified_games(pool)
    candidates = []
    for entry in pool:
        gp = team_gp.get(entry["team_id"])
        needed = games_needed(gp) if gp != None and gp > 0 else fallback
        if entry["games"] < needed:
            continue
        athlete = entry["athlete"]
        value = stat_total_str(entry["a"], category_name, idx)
        if value == "" or value == "-":
            continue
        candidates.append({
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": entry["team_id"],
            "team_abbr": athlete.get("teamShortName", ""),
            "value": value,
        })

    candidates = sorted(candidates, key = value_key if ascending else neg_value_key)
    candidates = candidates[:len(ROW_Y)]
    render_leaders(c, lg, titles, season, rank_candidates(candidates, allow_zero = True))

def neg_value(entry):
    return -entry["value"]

# Games Played: the goalie pool re-sorted by games (general.games can't be
# used as a sort key).
def draw_games_played(c, ctx, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)

    pool, season = goalie_pool(conf)
    if pool == None:
        header(c, lg, titles, "")
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    candidates = []
    for entry in pool:
        if entry["games"] <= 0:
            continue
        athlete = entry["athlete"]
        candidates.append({
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": entry["team_id"],
            "team_abbr": athlete.get("teamShortName", ""),
            "value": entry["games"],
        })

    candidates = sorted(candidates, key = neg_value)
    candidates = candidates[:len(ROW_Y)]
    render_leaders(c, lg, titles, season, rank_candidates(candidates))

# Points and PIM: the goalie pool sorted by the stat. No qualification -
# an assist or a penalty counts the moment it happens.
def draw_pool_counting_stat(c, ctx, category_name, idx, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)

    pool, season = goalie_pool(conf)
    if pool == None:
        header(c, lg, titles, "")
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    candidates = []
    for entry in pool:
        athlete = entry["athlete"]
        value_str = stat_total_str(entry["a"], category_name, idx)
        if value_str == "" or value_str == "-":
            continue
        candidates.append({
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": entry["team_id"],
            "team_abbr": athlete.get("teamShortName", ""),
            "value": int(value_str),
        })

    candidates = sorted(candidates, key = neg_value)
    candidates = candidates[:len(ROW_Y)]
    render_leaders(c, lg, titles, season, rank_candidates(candidates))

# ---------- pages ----------

def wins(c, ctx):
    draw_leaderboard(c, ctx, "general.wins", "general", 5, ["WINS"])

def savepct(c, ctx):
    draw_qualified_rate_stat(c, ctx, "defensive", 5, False, ["SAVE PERCENTAGE", "SAVE PCT"])

def gaa(c, ctx):
    draw_qualified_rate_stat(c, ctx, "defensive", 1, True, ["GOALS AGAINST AVERAGE", "GAA"])

def shutouts(c, ctx):
    draw_leaderboard(c, ctx, "defensive.shutouts", "defensive", 9, ["SHUTOUTS"])

def saves(c, ctx):
    draw_leaderboard(c, ctx, "defensive.saves", "defensive", 4, ["SAVES"])

def games(c, ctx):
    draw_games_played(c, ctx, ["GAMES PLAYED", "GAMES"])

def points(c, ctx):
    draw_pool_counting_stat(c, ctx, "offensive", 2, ["POINTS"])

def pim(c, ctx):
    draw_pool_counting_stat(c, ctx, "penalties", 0, ["PENALTY MINUTES", "PEN MINUTES", "PIM"])
