# NHL Offensive Leaders (128x32)
#
# The top 3 offensive leaders in one stat per page (Points, Goals, Assists,
# Power Play Points, Game-Winning Goals, Shots, Faceoffs Won, Penalty
# Minutes), for the NHL overall, the Eastern Conference, or the Western
# Conference. Data from ESPN's public stats-by-athlete API
# (site.web.api.espn.com) - no key required. Same scorebook layout and
# team-badge system as the MLB/NFL sibling apps, with hockey colors and
# stats.
#
# Left off: Shooting Pct and Faceoff Pct (flukey 100% leaders even with
# isqualified=true), Plus/Minus (mostly team-driven), and Short-Handed
# Points and Hits (not in this feed). Power Play Points is computed as
# powerPlayGoals + powerPlayAssists.
#
# With no games played yet in a season, the feed returns the last
# completed season's totals; the header shows whatever season it reports.
#
# Layout: league/conference pill (red EAST, blue WEST, split for NHL),
# stat and season, then three rows of rank, team badge, last name, value.
# Everything stays 6px inside both edges.

# id: [code, fill, ink] from ESPN's team colors; a few inks are swapped
# for a brighter accent where the ESPN pair was too low-contrast at 4x5.
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
# stray symbol otherwise, so strip to the closest ASCII letter first. NHL
# rosters have plenty of these (Scandinavian, Czech/Slovak, French).
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

def fetch_pool(specs):
    # specs: list of (sort_key, limit). Merged by athlete id. Returns
    # (ok, season, athletes); ok is False only if every fetch failed.
    seen = {}
    ok = False
    season = ""
    for spec in specs:
        resp = fetch_leaders(spec[0], limit = spec[1])
        if resp["status_code"] != 200 or resp["json"] == None:
            continue
        ok = True
        if season == "":
            season = season_of(resp)
        for a in resp["json"].get("athletes", []):
            aid = a.get("athlete", {}).get("id")
            if aid != None and aid not in seen:
                seen[aid] = a
    return ok, season, seen.values()

def stat_total_str(a, category_name, idx):
    # Raw formatted value as ESPN sends it - used for display and
    # same-string tie detection, never arithmetic.
    for cat in a.get("categories", []):
        if cat.get("name") == category_name:
            totals = cat.get("totals", [])
            if idx < len(totals):
                return totals[idx]
    return ""

def stat_total_int(a, category_name, idx):
    # Whole-number fields only. ESPN's "-" and "" both mean 0.
    v = stat_total_str(a, category_name, idx)
    return int(v) if v != "" and v != "-" else 0

def value_pp_points(a):
    return stat_total_int(a, "offensive", 3) + stat_total_int(a, "offensive", 4)

def neg_value(entry):
    return -entry["value"]

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
    # 7px pill: solid red EAST, solid blue WEST, red/blue split for NHL.
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
    # Dark fills get a rim in a half-tone of their own ink.
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
    # A zero stat hasn't happened yet, so its row stays blank. ESPN sends
    # "-" or "" for no stat.
    s = str(v)
    if s == "" or s == "-":
        return False
    return float(s) > 0.0

def rank_candidates(candidates):
    # Competition ranking (1, 2, 2) over the already conference-filtered
    # order.
    leaders = []
    prev_value = None
    prev_rank = 0
    for entry in candidates:
        if not is_positive(entry["value"]):
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

def draw_leaderboard_computed(c, ctx, pool_specs, value_fn, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)

    ok, season, pool = fetch_pool(pool_specs)
    if not ok:
        header(c, lg, titles, "")
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    candidates = []
    for a in pool:
        athlete = a.get("athlete", {})
        team_id = athlete.get("teamId", -1)
        team_id = int(team_id) if team_id != None else -1
        if conf != None and TEAM_CONFERENCE.get(team_id) != conf:
            continue
        candidates.append({
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": team_id,
            "team_abbr": athlete.get("teamShortName", ""),
            "value": value_fn(a),
        })

    candidates = sorted(candidates, key = neg_value)[:len(ROW_Y)]
    render_leaders(c, lg, titles, season, rank_candidates(candidates))

# One fetch, not two: with one request per page the app is already at the
# 8-uncached-requests-per-render cap. The top 100 by points catch every real
# PP points leader, and stay ~700 KB, under the 1 MB response cap.
PP_POOL = [("offensive.points", 100)]

# ---------- pages ----------

def goals(c, ctx):
    draw_leaderboard(c, ctx, "offensive.goals", "offensive", 0, ["GOALS"])

def assists(c, ctx):
    draw_leaderboard(c, ctx, "offensive.assists", "offensive", 1, ["ASSISTS"])

def points(c, ctx):
    draw_leaderboard(c, ctx, "offensive.points", "offensive", 2, ["POINTS"])

def pppoints(c, ctx):
    draw_leaderboard_computed(c, ctx, PP_POOL, value_pp_points, ["POWER PLAY POINTS", "PP POINTS"])

def gwg(c, ctx):
    draw_leaderboard(c, ctx, "offensive.gameWinningGoals", "offensive", 7, ["GAME-WINNING GOALS", "GW GOALS"])

def shots(c, ctx):
    draw_leaderboard(c, ctx, "offensive.shotsTotal", "offensive", 5, ["SHOTS ON GOAL", "SHOTS"])

def faceoffs(c, ctx):
    draw_leaderboard(c, ctx, "offensive.faceoffsWon", "offensive", 8, ["FACEOFFS WON", "FACEOFFS"])

def pim(c, ctx):
    draw_leaderboard(c, ctx, "penalties.penaltyMinutes", "penalties", 0, ["PENALTY MINUTES", "PEN MINUTES", "PIM"])
