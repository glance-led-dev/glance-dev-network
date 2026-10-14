# NHL Goalie Leaders (192x32)
#
# The top 3 goalie leaders in one stat per page (Goals Against Average,
# Save Percentage, Wins, Shutouts, Saves, Games Played, Points, Penalty
# Minutes), for the NHL overall, the Eastern Conference, or the Western
# Conference - regular season or playoffs. Data from ESPN's public stats-by-athlete API
# (site.web.api.espn.com) - no key required. Sibling app to
# nhl-offensive-leaders, same scorebook template.
#
# STATS. Auto (the default) shows the playoffs while they're on and the
# regular season the rest of the year (ESPN's postseason window, one tiny
# request); Regular season and Playoffs pin one, so a fan can add the app
# twice and see both in the spring. Playoffs before the spring shows last
# spring's.
#
# Points and Penalty Minutes are light closers: goalies do pick up the odd
# assist and take real penalties (delay of game over the glass).
#
# Losses, OTL, Shots Against and Goals Against are left off: they aren't
# achievements.
#
# Save Percentage and Goals Against Average use the NHL's qualification
# rule: a goalie must have played at least 31.25% of his team's games,
# rounded up (27 of 84 by season's end). In the playoffs a starter plays
# nearly every game, so 31.25% would let one hot first-round series top the
# board: there the bar is 50% of the fewest playoff games played by a club
# still alive in the current round (never lower than where an earlier round
# ended, frozen when the Final starts) - 7 GP at the end of 2026 - from the
# NHL's own bracket, shown in the header ("4+ GP"). Team games come from the ESPN
# standings feed. Neither stat has a usable qualified sort, so both rank a
# pool of every goalie who has faced a shot (sorted by shots against, which
# skaters never have), locally. Games Played, Points and PIM use the same
# pool, since sorting those fields directly surfaces skaters.
#
# Values print as ESPN formats them: GAA "2.02", Save Pct ".921".

# id: [code, fill, ink]. Same table as nhl-offensive-leaders.
TEAMS = {
    25: ["ANA", "#FC4C02", "#000000"],   # Ducks: orange, black
    1: ["BOS", "#FDB71A", "#000000"],    # Bruins: gold, black (flipped - a black badge vanishes on the panel)
    2: ["BUF", "#00468B", "#FDB71A"],    # Sabres: navy, gold
    3: ["CGY", "#DD1A32", "#FAAF19"],    # Flames: red, gold
    7: ["CAR", "#E30426", "#000000"],    # Hurricanes: red, black
    4: ["CHI", "#E31937", "#000000"],    # Blackhawks: red, black
    17: ["COL", "#860038", "#8FBCE6"],   # Avalanche: burgundy, light blue
    29: ["CBJ", "#002D62", "#FF4C4C"],   # Blue Jackets: navy, red
    9: ["DAL", "#20864C", "#000000"],    # Stars: green, black
    5: ["DET", "#E30526", "#FFFFFF"],    # Red Wings: red, white
    6: ["EDM", "#00205B", "#FF4C00"],    # Oilers: navy, orange
    26: ["FLA", "#E51937", "#FFFFFF"],   # Panthers: red, white
    8: ["LA", "#A2AAAD", "#000000"],     # Kings: silver, black (flipped)
    30: ["MIN", "#124734", "#DDCBA4"],   # Wild: forest green, wheat
    10: ["MTL", "#C41230", "#FFFFFF"],   # Canadiens: red, white
    27: ["NSH", "#FDBA31", "#002D62"],   # Predators: gold, navy
    11: ["NJ", "#E30B2B", "#000000"],    # Devils: red, black
    12: ["NYI", "#00529B", "#F47D31"],   # Islanders: blue, orange
    13: ["NYR", "#0056AE", "#FFFFFF"],   # Rangers: blue, white
    14: ["OTT", "#DD1A32", "#B79257"],   # Senators: red, gold
    15: ["PHI", "#FE5823", "#000000"],   # Flyers: orange, black
    16: ["PIT", "#FDB71A", "#000000"],   # Penguins: gold, black (flipped)
    18: ["SJ", "#00788A", "#070707"],    # Sharks: teal, black
    124292: ["SEA", "#A3DCE4", "#001628"],  # Kraken: ice blue, deep-sea navy (flipped)
    19: ["STL", "#0070B9", "#FDB71A"],   # Blues: blue, gold
    20: ["TB", "#003E7E", "#FFFFFF"],    # Lightning: blue, white
    21: ["TOR", "#003E7E", "#FFFFFF"],   # Maple Leafs: blue, white
    129764: ["UTAH", "#7AB2E1", "#000000"],  # Mammoth: ice blue, black (flipped)
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
GOLD = "#F2C14E"      # PLAYOFFS in the header
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

def fetch_leaders(ctx, sort_key, limit = 32):
    # One request per sort, sorted server-side. Each athlete is ~15 KB of
    # JSON, so about 60 fit under the 1 MB body cap.
    params = {
        "region": "us",
        "lang": "en",
        "contentorigin": "espn",
        "isqualified": "false",
        "seasontype": "2",
        "sort": sort_key + ":desc",
        "limit": str(limit),
    }
    sp = season_params(ctx)
    params["seasontype"] = sp[0]
    if sp[1] != "":
        params["season"] = sp[1]
    return http.get(
        "https://site.web.api.espn.com/apis/common/v3/sports/hockey/nhl/statistics/byathlete",
        params = params,
        # matches manifest.yaml's refresh - keep in sync
        ttl_seconds = 10800,
    )

def season_of(resp):
    j = resp.get("json") or {}
    return str((j.get("requestedSeason") or j.get("currentSeason") or {}).get("displayName") or "")

def league_choice(ctx):
    v = ctx.inputs.get("league", "NHL")
    return v if v in ("NHL", "EAST", "WEST") else "NHL"

def conference_for(lg):
    return lg if lg in ("EAST", "WEST") else None

# ---------- stats setting ----------
# Auto (the default) shows the playoffs while they're on and the regular
# season the rest of the year; Regular season and Playoffs pin one, so a fan
# can add the app twice and see both in the spring. "While they're on" is
# ESPN's own postseason window for the season (mid-April to July 1), one
# ~700-byte request.

MODES = ["Auto", "Regular season", "Playoffs"]

def mode_choice(ctx):
    v = ctx.inputs.get("stats", "Auto")
    return v if v in MODES else "Auto"

def season_year(ctx):
    # ESPN names an NHL season by the year it ends: 2026-27 is 2027.
    return ctx.now.year + 1 if ctx.now.month >= 9 else ctx.now.year

def today(ctx):
    m = ctx.now.month
    dd = ctx.now.day
    return str(ctx.now.year) + "-" + ("0" if m < 10 else "") + str(m) + "-" + ("0" if dd < 10 else "") + str(dd)

def playoff_window(year):
    # [first day, last day] of ESPN's postseason for a season, or None.
    resp = http.get("https://sports.core.api.espn.com/v2/sports/hockey/leagues/nhl/seasons/" + str(year) + "/types/3",
                    ttl_seconds = 86400)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    j = resp["json"]
    return [str(j.get("startDate") or "9999")[:10], str(j.get("endDate") or "0000")[:10]]

def season_params(ctx):
    # [ESPN seasontype, season ("" = the current one)]. Playoffs before this
    # spring's start shows last spring's.
    mode = mode_choice(ctx)
    if mode == "Regular season":
        return ["2", ""]
    y = season_year(ctx)
    w = playoff_window(y)
    t = today(ctx)
    started = w != None and w[0] <= t
    if mode == "Playoffs":
        return ["3", str(y if started else y - 1)]
    if started and t <= w[1]:
        return ["3", str(y)]
    return ["2", ""]

def is_post(ctx):
    return season_params(ctx)[0] == "3"

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

def header(c, lg, titles, season, post = False):
    # titles runs longest first; the header takes the first that fits beside
    # the badge and season. A playoff board adds PLAYOFFS in gold after it.
    right = c.width - PAD - 1
    x = league_chip(c, lg, PAD) + 3
    sw = 0
    if post:
        pw = c.text_width("PLAYOFFS", "4x5")
        c.text("PLAYOFFS", right, HEAD_Y, font = "4x5", color = GOLD, align = "right")
        sw = pw
        if season != "":
            sw += 4 + c.text_width(season, "4x5")
            c.text(season, right - pw - 4, HEAD_Y, font = "4x5", color = DIM, align = "right")
    elif season != "":
        sw = c.text_width(season, "4x5")
        c.text(season, right, HEAD_Y, font = "4x5", color = DIM, align = "right")
    room = right - sw - 3 - x
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

def display_name(c, full, last, room):
    # The longest form that fits in the main font: the full name, then
    # initial and last name, then the last name alone.
    full = strip_accents(full).upper()
    last = strip_accents(last).upper()
    forms = [full, full[:1] + ". " + last] if full != "" else []
    for f in forms:
        if c.text_width(f, NAME_FONTS[0]) <= room:
            return f
    return short_name(c, last, room)

def render_leaders(c, lg, titles, season, leaders, post = False):
    header(c, lg, titles, season, post)
    if len(leaders) == 0:
        # The stat just hasn't happened yet (no return TD in these playoffs,
        # nobody past a rate page's bar in Week 1) - not a missing feed.
        return message(c, "NONE SO FAR", "THESE PLAYOFFS" if post else "THIS SEASON", INK)

    rows = []
    for i in range(len(leaders)):
        e = leaders[i]
        rows.append({
            "rank": str(e["rank"]),
            "style": team_style(e["team_id"], e["team_abbr"]),
            "full": e.get("full", ""),
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
        r["name"] = display_name(c, r["full"], r["name"], room)
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
    post = is_post(ctx)

    resp = fetch_leaders(ctx, sort_key)
    if resp["status_code"] != 200 or resp["json"] == None:
        header(c, lg, titles, "", post)
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
            "full": athlete.get("displayName", ""),
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": team_id,
            "team_abbr": athlete.get("teamShortName", ""),
            "value": value,
        })
        if len(candidates) >= len(ROW_Y):
            break

    render_leaders(c, lg, titles, season_of(resp), rank_candidates(candidates), post)

# Every goalie who has faced a shot. Skaters have no shots against, so
# they sort to the bottom of this list.
GOALIE_POOL_SORT = "defensive.shotsAgainst"
GOALIE_POOL_LIMIT = 70   # ~0.5 MB regular season, ~0.9 MB playoffs (1 MB cap)


def stat_total_str(a, category_name, idx):
    # Raw formatted value as ESPN sends it - used for display and
    # same-string tie detection, never arithmetic.
    for cat in a.get("categories", []):
        if cat.get("name") == category_name:
            totals = cat.get("totals", [])
            if idx < len(totals):
                return totals[idx]
    return ""

def goalie_pool(ctx, conf):
    # Entries keep the whole response object `a`: the stat totals live in
    # its "categories", a sibling of "athlete".
    resp = fetch_leaders(ctx, GOALIE_POOL_SORT, limit = GOALIE_POOL_LIMIT)
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

def playoff_games(year):
    # The bar's game count from the NHL's bracket (series win counts): the
    # fewest playoff games played by a club still alive in the current round
    # (including the last round's winners whose series hasn't started yet),
    # never lower than where an earlier round ended, frozen when the Final
    # starts. No byes in the NHL. None when the feed is down.
    resp = http.get("https://api-web.nhle.com/v1/playoff-bracket/" + str(year), ttl_seconds = 10800)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    played = {}     # round -> {club: games in that round}
    out = {}        # club -> round it went out in
    in_round = {}   # round -> {club: True}
    current = 0
    for sr in resp["json"].get("series", []):
        r = sr.get("playoffRound", 0)
        top = (sr.get("topSeedTeam") or {}).get("abbrev", "")
        bot = (sr.get("bottomSeedTeam") or {}).get("abbrev", "")
        if r < 1 or top == "" or bot == "":
            continue
        tw = sr.get("topSeedWins", 0) or 0
        bw = sr.get("bottomSeedWins", 0) or 0
        for t in (top, bot):
            in_round.setdefault(r, {})[t] = True
            played.setdefault(r, {})[t] = tw + bw
        if tw + bw > 0:
            current = max(current, r)
        if tw == 4:
            out[bot] = r
        elif bw == 4:
            out[top] = r
    if current == 0:
        return 0

    def through(t, r):
        n = 0
        for x in range(1, r + 1):
            n += played.get(x, {}).get(t, 0)
        return n

    floor = 0
    for r in range(1, current):
        winners = [t for t in in_round.get(r, {}) if out.get(t, 99) > r]
        if len(winners) > 0:
            floor = max(floor, min([through(t, r) for t in winners]))
    if current == 4:
        return floor
    cand = dict(in_round.get(current, {}))
    for t in in_round.get(current - 1, {}):
        if out.get(t, 99) > current - 1:
            cand[t] = True
    alive = [t for t in cand if t not in out]
    if len(alive) == 0:
        alive = list(in_round.get(current, {}))
    return max(floor, min([through(t, current) for t in alive]))

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
    post = is_post(ctx)

    pool, season = goalie_pool(ctx, conf)
    if pool == None:
        header(c, lg, titles, "", post)
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    label = season
    if post:
        # Playoffs: 50% of the bracket's game count, rounded up, the same
        # for every goalie.
        g = playoff_games(season_params(ctx)[1])
        if g == None:
            return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
        team_gp = {}
        fallback = max(1, (g + 1) // 2)
        label = str(fallback) + "+ GP"
    else:
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
            "full": athlete.get("displayName", ""),
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": entry["team_id"],
            "team_abbr": athlete.get("teamShortName", ""),
            "value": value,
        })

    candidates = sorted(candidates, key = value_key if ascending else neg_value_key)
    candidates = candidates[:len(ROW_Y)]
    # In the playoffs the bar takes the year's place in the header.
    render_leaders(c, lg, titles, label, rank_candidates(candidates, allow_zero = True), post)

def neg_value(entry):
    return -entry["value"]

# Games Played: the goalie pool re-sorted by games (general.games can't be
# used as a sort key).
def draw_games_played(c, ctx, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)
    post = is_post(ctx)

    pool, season = goalie_pool(ctx, conf)
    if pool == None:
        header(c, lg, titles, "", post)
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    candidates = []
    for entry in pool:
        if entry["games"] <= 0:
            continue
        athlete = entry["athlete"]
        candidates.append({
            "full": athlete.get("displayName", ""),
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": entry["team_id"],
            "team_abbr": athlete.get("teamShortName", ""),
            "value": entry["games"],
        })

    candidates = sorted(candidates, key = neg_value)
    candidates = candidates[:len(ROW_Y)]
    render_leaders(c, lg, titles, season, rank_candidates(candidates), post)

# Points and PIM: the goalie pool sorted by the stat. No qualification -
# an assist or a penalty counts the moment it happens.
def draw_pool_counting_stat(c, ctx, category_name, idx, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)
    post = is_post(ctx)

    pool, season = goalie_pool(ctx, conf)
    if pool == None:
        header(c, lg, titles, "", post)
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    candidates = []
    for entry in pool:
        athlete = entry["athlete"]
        value_str = stat_total_str(entry["a"], category_name, idx)
        if value_str == "" or value_str == "-":
            continue
        candidates.append({
            "full": athlete.get("displayName", ""),
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": entry["team_id"],
            "team_abbr": athlete.get("teamShortName", ""),
            "value": int(value_str),
        })

    candidates = sorted(candidates, key = neg_value)
    candidates = candidates[:len(ROW_Y)]
    render_leaders(c, lg, titles, season, rank_candidates(candidates), post)

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
