# MLB Pitching Leaders (192x32)
#
# The top 3 pitchers in one stat per page (ERA/K/Wins/Saves/IP/Games/WHIP/K9),
# for MLB overall, the AL, or the NL - regular season or postseason. Data
# from MLB's own public Stats API (statsapi.mlb.com) - no key required.
# Sibling app to mlb-offensive-leaders and mlb-playoff-picture.
#
# Pages in this SDK are a fixed list declared in the manifest, so all 8
# category pages always exist.
#
# STATS. Auto (the default) shows the postseason while it's on and the
# regular season otherwise; Regular season and Postseason pin one, so a fan
# can add the app twice and see both in October. MLB's own postseason
# leaderboard qualifies pitchers at 1 inning per game *their own team*
# played, so a starter with one gem for a club out in the Wild Card round
# can sit on top all month. Here the bar is one number for everyone: 1
# inning times the fewest games played by a club still alive in the current
# round (never lower than where an earlier round ended), frozen when the
# World Series starts (10 IP in 2025). Relievers qualify
# early; as the bar climbs it becomes a starters' board, as in the regular
# season. Ties list the pitcher with more innings first.
#
# DESIGN. The mlb-playoff-picture scorebook, as a leaderboard, on a black
# ground. A chip row names the league (AL red, NL blue, MLB split blue|red
# like its logo), the stat in white and the season in gray (with POSTSEASON
# in gold). Under it, three rows: the rank in gray, a team badge, the
# pitcher's name in white (initial and last name if the full name won't
# fit), and the number in white against the right edge. The badge is how a
# fan spots their team across a room: the
# team's code in its own two colors - orange on navy for the Tigers, gold on
# brown for the Padres, black on gold for the Pirates - like a cap patch.
# Real logos were the other option; at 7px tall they're blobs, and they're
# trademarks, where colors and codes are just facts. Everything stays 6px
# inside both edges so the app reads as its own unit in the stream.

# id: [code, fill, ink]. Fill is the color the team wears most, ink its
# second color. Inks are LED-tuned where the official shade washed out at
# 4x5: the Red Sox/Guardians/Rangers/Twins/Braves reds on navy read as dim
# maroon, so they're pushed brighter, as are the Royals' gold and the
# Mariners' Northwest green.
TEAMS = {
    108: ["LAA", "#BA0021", "#FFFFFF"],  # Angels: red, white
    109: ["AZ", "#A71930", "#E3D4AD"],   # D-backs: Sedona red, sand
    110: ["BAL", "#DF4601", "#000000"],  # Orioles: orange, black
    111: ["BOS", "#0C2340", "#FF4C57"],  # Red Sox: navy, red
    112: ["CHC", "#0E3386", "#FFFFFF"],  # Cubs: blue, white
    113: ["CIN", "#C6011F", "#FFFFFF"],  # Reds: red, white
    114: ["CLE", "#0C2340", "#FF3B4F"],  # Guardians: navy, red
    115: ["COL", "#333366", "#C4CED4"],  # Rockies: purple, silver
    116: ["DET", "#0C2340", "#FA4616"],  # Tigers: navy, orange
    117: ["HOU", "#EB6E1F", "#002D62"],  # Astros: orange, navy
    118: ["KC", "#004687", "#E8C47E"],   # Royals: royal blue, gold
    119: ["LAD", "#005A9C", "#FFFFFF"],  # Dodgers: Dodger blue, white
    120: ["WSH", "#AB0003", "#FFFFFF"],  # Nationals: red, white
    121: ["NYM", "#002D72", "#FF5910"],  # Mets: blue, orange
    133: ["ATH", "#003831", "#EFB21E"],  # Athletics: green, gold
    134: ["PIT", "#FDB827", "#000000"],  # Pirates: gold, black
    135: ["SD", "#2F241D", "#FFC425"],   # Padres: brown, gold
    136: ["SEA", "#0C2C56", "#2FD1C5"],  # Mariners: navy, Northwest green
    137: ["SF", "#27251F", "#FD5A1E"],   # Giants: black, orange
    138: ["STL", "#C41E3A", "#FFFFFF"],  # Cardinals: red, white
    139: ["TB", "#092C5C", "#8FBCE6"],   # Rays: navy, Columbia blue
    140: ["TEX", "#003278", "#FF3B47"],  # Rangers: blue, red
    141: ["TOR", "#134A8E", "#FFFFFF"],  # Blue Jays: blue, white
    142: ["MIN", "#002B5C", "#FF3868"],  # Twins: navy, red
    143: ["PHI", "#E81828", "#FFFFFF"],  # Phillies: red, white
    144: ["ATL", "#13274F", "#FF3A5C"],  # Braves: navy, red
    145: ["CWS", "#27251F", "#C4CED4"],  # White Sox: black, silver
    146: ["MIA", "#00A3E0", "#000000"],  # Marlins: Miami blue, black
    147: ["NYY", "#0C2340", "#FFFFFF"],  # Yankees: navy, white
    158: ["MIL", "#12284B", "#FFC52F"],  # Brewers: navy, gold
}

LEAGUE_ID = {"AL": "103", "NL": "104"}

# ---------- palette & grid ----------

INK = "#F4F7FF"     # names, live numbers, the stat title
DIM = "#6E7A94"     # ranks, season, the postseason bar, sub-lines
AMBER = "#E8B04A"   # the one attention state (feed offline)
GOLD = "#F2C14E"    # POSTSEASON in the header
AL_RED = "#D22D3A"
NL_BLUE = "#2A66D9"

PAD = 6             # scroll safe zone, both edges
RANK_W = 5          # one 5x7 digit
BADGE_X = PAD + RANK_W + 2  # 13
BADGE_H = 7
NAME_GAP = 2
GAP = 3             # blank px between a name and its value
ROW_Y = [9, 17, 25] # three 7px rows, 1px apart, under the 7px chip row

# Names get one font per page, not per row: "MISIOROWSKI" (65px at 5x7) in
# 4x7 beside "SALE" in 5x7 reads as a mistake. 5x7 when every name on the
# page fits, else 4x7 (51px for MISIOROWSKI), then a hard clip.
NAME_FONTS = ["5x7", "4x7"]
VALUE_FONT = "5x7"

# ---------- name normalization ----------
# The bitmap fonts only cover plain ASCII - an accented letter renders as a
# stray symbol (or nothing: "SANCHEZ" came out "SNCHEZ"), so strip to the
# closest ASCII letter first.
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

API = "https://statsapi.mlb.com/api/v1"
TTL = 14400         # matches manifest.yaml's refresh - keep in sync
DEFAULT_OUTS_RATE = 3.0   # outs (1 inning) per team game to qualify (MLB's rule)
# Only the fields the boards read, a fraction of the full player list.
FIELDS = "stats,splits,player,fullName,lastName,team,id,stat,era,whip,strikeoutsPer9Inn,strikeOuts,wins,saves,inningsPitched,outs,gamesPitched"
SCHEDULE_FIELDS = "dates,games,gameType,status,abstractGameState,teams,home,away,team,id,isWinner,seriesStatus,isOver"
ROUNDS = ["F", "D", "L", "W"]   # Wild Card, Division Series, LCS, World Series
MODES = ["Auto", "Regular season", "Postseason"]

def league_choice(ctx):
    v = ctx.inputs.get("league", "MLB")
    return v if v in LEAGUE_ID else "MLB"

def mode_choice(ctx):
    v = ctx.inputs.get("stats", "Auto")
    return v if v in MODES else "Auto"

def get_json(path, params):
    resp = http.get(API + path, params = params, ttl_seconds = TTL)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    return resp["json"]

def season_dates(year):
    d = get_json("/seasons/" + str(year), {"sportId": "1"})
    if d == None:
        return None
    s = d.get("seasons") or []
    return s[0] if len(s) > 0 and type(s[0]) == "dict" else {}

def today(ctx):
    m = ctx.now.month
    dd = ctx.now.day
    return str(ctx.now.year) + "-" + ("0" if m < 10 else "") + str(m) + "-" + ("0" if dd < 10 else "") + str(dd)

def which_season(ctx):
    # [year, "R" or "P", season dates] for this panel, or None offline.
    # Auto: the postseason from its first day to its last, the regular
    # season otherwise. Before a season's opening day the latest one is last
    # year's; the Postseason setting shows last October's until this one
    # starts.
    t = today(ctx)
    year = ctx.now.year
    info = season_dates(year)
    if info == None:
        return None
    if info.get("regularSeasonStartDate", "9999") > t:
        year -= 1
        info = season_dates(year)
        if info == None:
            return None
    post_start = info.get("postSeasonStartDate", "9999")
    post_end = info.get("postSeasonEndDate", "0000")
    mode = mode_choice(ctx)
    if mode == "Regular season":
        return [year, "R", info]
    if mode == "Postseason":
        if post_start > t:
            prev = season_dates(year - 1)
            return [year - 1, "P", prev or {}]
        return [year, "P", info]
    return [year, "P" if post_start <= t and t <= post_end else "R", info]

def fetch_players(year, kind, lg, pool):
    params = {
        "stats": "season",
        "group": "pitching",
        "gameType": kind,
        "season": str(year),
        "sportId": "1",
        "limit": "2000",
        "playerPool": pool,
        "fields": FIELDS,
    }
    if lg in LEAGUE_ID:
        params["leagueId"] = LEAGUE_ID[lg]
    d = get_json("/stats", params)
    if d == None:
        return None
    st = d.get("stats") or []
    if len(st) == 0 or type(st[0]) != "dict":
        return []
    return st[0].get("splits") or []

def fewest_games_alive(year):
    # The bar's game count: the fewest postseason games played by a club
    # still alive in the current round. A club with a bye isn't in the Wild
    # Card round, so it only counts from the Division Series on. When a new
    # round opens, its bye clubs have played 0 games, so the count never
    # drops below where an earlier round ended: the fewest games any club
    # that won that round had played through it (2 after the Wild Card
    # round), which keeps a 3-for-3 Wild Card loser off the top on Division
    # Series day 1. The count stops rising when the World Series starts.
    d = get_json("/schedule", {"sportId": "1", "season": str(year), "gameType": "F,D,L,W",
                               "hydrate": "seriesStatus", "fields": SCHEDULE_FIELDS})
    if d == None:
        return None
    played = {}     # round -> {club: games played in that round}
    out = {}        # club -> round it went out in
    in_round = {}   # round -> {club: True}
    current = -1
    for dt in d.get("dates") or []:
        for g in dt.get("games") or []:
            r = ROUNDS.index(g.get("gameType")) if g.get("gameType") in ROUNDS else -1
            state = (g.get("status") or {}).get("abstractGameState", "")
            sides = g.get("teams") or {}
            ids = [((sides.get(k) or {}).get("team") or {}).get("id", 0) for k in ("home", "away")]
            if r < 0 or ids[0] not in TEAMS or ids[1] not in TEAMS:
                continue   # "AL Champion" placeholders before a round is set
            for tid in ids:
                in_round.setdefault(r, {})[tid] = True
            if state in ("Final", "Live"):
                current = max(current, r)
            if state != "Final":
                continue
            for k in ("home", "away"):
                side = sides.get(k) or {}
                tid = (side.get("team") or {}).get("id", 0)
                played.setdefault(r, {})[tid] = played.get(r, {}).get(tid, 0) + 1
                if (g.get("seriesStatus") or {}).get("isOver") and not side.get("isWinner"):
                    out[tid] = r
    if current < 0:
        return 0

    def through(tid, r):
        # Games a club has played in rounds 0..r.
        n = 0
        for x in range(r + 1):
            n += played.get(x, {}).get(tid, 0)
        return n

    floor = 0
    for r in range(current):
        winners = [t for t in in_round.get(r, {}) if out.get(t, 99) > r]
        if len(winners) > 0:
            floor = max(floor, min([through(t, r) for t in winners]))
    if current == len(ROUNDS) - 1:
        # Frozen for the World Series: the fewest games either pennant
        # winner played through the LCS (10 in 2025, so 31 PA / 10 IP).
        # Letting it keep rising would leave only the two Series rosters
        # (and too few pitchers to fill a board).
        return floor
    # Still alive in the current round: everyone who has played in it, plus
    # every winner of the round before whose series hasn't started yet (the
    # two series of a round can start on different days).
    cand = dict(in_round.get(current, {}))
    if current > 0:
        for t in in_round.get(current - 1, {}):
            if out.get(t, 99) > current - 1:
                cand[t] = True
    alive = [t for t in cand if t not in out]
    if len(alive) == 0:
        alive = list(in_round.get(current, {}))
    return max(floor, min([through(t, current) for t in alive]))

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
    # keeps its last half whole: beside a 5-digit OPS, "CROW-ARMSTRONG"
    # becomes "C-ARMSTRONG" rather than clipping to "CROW-ARMSTRO".
    if "-" not in name or c.text_width(name, NAME_FONTS[-1]) <= maxw:
        return name
    parts = name.split("-")
    return parts[0][:1] + "-" + "-".join(parts[1:])

# ---------- chrome ----------

def league_chip(c, lg, x):
    # 7px pill: 4x5 text with 1px of fill above and below, 2px either side.
    w = c.text_width(lg, "4x5") + 4
    if lg == "MLB":
        # blue left half, red right half, like the MLB logo; the white text
        # reads on both
        mid = x + w // 2
        c.round_rect(x, 0, x + w - 1, 6, 1, fill = NL_BLUE)
        c.round_rect(mid, 0, x + w - 1, 6, 1, fill = AL_RED)
        c.rect(mid, 0, mid + 1, 6, fill = AL_RED)
    else:
        c.round_rect(x, 0, x + w - 1, 6, 1, fill = AL_RED if lg == "AL" else NL_BLUE)
    c.text(lg, x + 2, 1, font = "4x5", color = "white")
    return x + w

def header(c, lg, title, season, post):
    # The chip, the stat in white, the season in gray at the right edge; a
    # postseason board adds POSTSEASON in gold after it (and on the ERA,
    # WHIP and K/9 pages the season gives way to the innings bar, "3+ IP").
    right = c.width - PAD - 1
    x = league_chip(c, lg, PAD) + 3
    sw = 0
    if post:
        pw = c.text_width("POSTSEASON", "4x5")
        c.text("POSTSEASON", right, 1, font = "4x5", color = GOLD, align = "right")
        sw = pw
        if season != "":
            sw += 4 + c.text_width(season, "4x5")
            c.text(season, right - pw - 4, 1, font = "4x5", color = DIM, align = "right")
    elif season != "":
        sw = c.text_width(season, "4x5")
        c.text(season, right, 1, font = "4x5", color = DIM, align = "right")
    room = right - sw - 3 - x
    c.text(clip(c, title, "4x5", room), x, 1, font = "4x5", color = INK)

def message(c, head, sub, head_color):
    # Sits in the band under the chip row, so a failed page still says
    # which stat and league it is.
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

# ---------- team badges ----------

def team_style(team_id, team_name):
    t = TEAMS.get(team_id)
    if t:
        return t
    # A club this table doesn't know (a new id, an expansion team): a
    # neutral badge with the start of its nickname beats a blank.
    code = strip_accents(team_name.split(" ")[-1])[:3].upper()
    return [code or "?", "#444444", "#FFFFFF"]

def badge_width(c):
    # One width for every badge so the names start on one column: the
    # widest code (WSH/NYM, 15px at 4x5) plus 2px of fill either side.
    w = 0
    for t in TEAMS.values():
        w = max(w, c.text_width(t[0], "4x5"))
    return w + 4

def badge(c, x, y, w, style):
    code, fill, ink = style[0], style[1], style[2]
    # Navy, brown and black fills vanish into the ground, so the dark ones
    # get a rim - a half-tone of their own ink, not gray, so a Tigers badge
    # stays navy and orange out to its edge. Gray rims made every navy club
    # look like the same box.
    edge = blend(ink, fill, 50) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + w - 1, y + BADGE_H - 1, 1, fill = fill, outline = edge)
    c.text(clip(c, code, "4x5", w - 2), x + w // 2, y + 1, font = "4x5", color = ink, align = "center")

# ---------- the leaderboard ----------

def to_num(v):
    # "2.45", "205.0", "12" -> a number; anything else ("-.--", "") -> None.
    t = str(v)
    if t == "" or t == "." or t == "-":
        return None
    for i in range(len(t)):
        if t[i] not in "0123456789.":
            return None
    return float(t) if "." in t else int(t)

def leaders(players, field, low, need_outs):
    # Top 3 by field among pitchers with at least need_outs outs; low =
    # lower is better (ERA, WHIP). Ties share a rank, more innings listed
    # first.
    rows = []
    for p in players:
        st = p.get("stat") or {}
        v = to_num(st.get(field))
        outs = st.get("outs", 0)
        if v == None or outs < need_outs:
            continue
        rows.append([v, outs, p])
    rows = sorted(rows, key = lambda r: ((r[0] if low else -r[0]), -r[1]))
    out = []
    for i in range(min(len(ROW_Y), len(rows))):
        better = len([r for r in rows if (r[0] < rows[i][0] if low else r[0] > rows[i][0])])
        out.append([better + 1, rows[i][2]])
    return out

def display_name(c, person, room):
    # The longest form that fits in the main font: "JACOB MISIOROWSKI",
    # then "J. MISIOROWSKI", then "MISIOROWSKI"; a double-barrelled last
    # name that still won't fit keeps its last half ("C-ARMSTRONG").
    last = strip_accents(str(person.get("lastName", "?"))).upper()
    full = strip_accents(str(person.get("fullName", ""))).upper()
    forms = [full, full[:1] + ". " + last] if full != "" else []
    for f in forms:
        if c.text_width(f, NAME_FONTS[0]) <= room:
            return f
    return short_name(c, last, room)

def leaderboard(c, ctx, field, rate, low, title):
    c.clear()
    lg = league_choice(ctx)
    which = which_season(ctx)
    if which == None:
        # No feed, so no season to vouch for - the chip and stat still say
        # which page this is.
        header(c, lg, title, "", False)
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
    year, kind, info = which[0], which[1], which[2]
    post = kind == "P"
    need_outs = 0
    label = str(year)
    if post:
        players = fetch_players(year, "P", lg, "ALL")
        if rate and players != None:
            games = fewest_games_alive(year)
            if games == None:
                players = None
            else:
                rate_outs = float(info.get("qualifierOutsPitched") or DEFAULT_OUTS_RATE)
                need_outs = games * rate_outs
                # The bar in innings, rounded up, where the year would be: "3+ IP".
                ip = need_outs / 3.0
                label = str(int(ip) + (1 if ip > int(ip) else 0)) + "+ IP"
    header(c, lg, title, label, post)
    if not post:
        # MLB's own qualified list (1 inning per team game) for the rate stats.
        players = fetch_players(year, "R", lg, "QUALIFIED" if rate else "ALL")
    if players == None:
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
    top = leaders(players, field, low, need_outs)
    if len(top) == 0:
        # Before a first-ever season, or the first postseason pitch, there's
        # simply no leaderboard - not an error.
        if post:
            return message(c, "NO POSTSEASON STATS YET", "FIRST PITCH SOON", INK)
        return message(c, "NO STATS YET", "BACK ON OPENING DAY", INK)

    rows = []
    for rank, p in top:
        st = p.get("stat") or {}
        team = p.get("team") or {}
        rows.append({
            "rank": str(rank),
            "style": team_style(team.get("id", -1), str(team.get("name", ""))),
            "person": p.get("player") or {},
            "value": str(st.get(field, "-")).upper(),
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
        r["name"] = display_name(c, r["person"], room)
    font = page_font(c, [r["name"] for r in rows], room)

    for i in range(len(rows)):
        r = rows[i]
        y = ROW_Y[i]
        c.text(clip(c, r["rank"], "5x7", RANK_W), PAD + RANK_W // 2, y, font = "5x7", color = DIM, align = "center")
        badge(c, BADGE_X, y, bw, r["style"])
        c.text(clip(c, r["name"], font, room), name_x, y, font = font, color = INK)
        c.text(clip(c, r["value"], VALUE_FONT, valw), right, y, font = VALUE_FONT, color = INK, align = "right")

# ---------- pages ----------

def era(c, ctx):
    leaderboard(c, ctx, "era", True, True, "ERA")

def k(c, ctx):
    leaderboard(c, ctx, "strikeOuts", False, False, "STRIKEOUTS")

def wins(c, ctx):
    leaderboard(c, ctx, "wins", False, False, "WINS")

def saves(c, ctx):
    leaderboard(c, ctx, "saves", False, False, "SAVES")

def ip(c, ctx):
    leaderboard(c, ctx, "inningsPitched", False, False, "INNINGS PITCHED")

def games(c, ctx):
    leaderboard(c, ctx, "gamesPitched", False, False, "GAMES PITCHED")

def whip(c, ctx):
    leaderboard(c, ctx, "whip", True, True, "WHIP")

def k9(c, ctx):
    leaderboard(c, ctx, "strikeoutsPer9Inn", True, False, "K PER 9 INNINGS")
