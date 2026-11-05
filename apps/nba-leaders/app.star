# NBA Leaders (192x32)
#
# The top 3 per-game and shooting leaders in one stat per page (Points,
# Rebounds, Assists, Steals, Blocks, FG Pct, 3PT Pct, FT Pct), for the whole
# NBA, the East, or the West - regular season or playoffs. Data from ESPN's
# public stats-by-athlete API (site.web.api.espn.com) - no key required.
# Sibling app to wnba-leaders, with the mlb-offensive-leaders season logic.
#
# Pages in this SDK are a fixed list declared in the manifest, so all 8
# category pages always exist.
#
# STATS. Auto (the default) shows the playoffs from the first playoff game
# to the end of the Finals and the regular season otherwise; Regular season
# and Playoffs pin one, so a fan can add the app twice and see both in the
# spring. Before opening night the latest regular season is last year's;
# the Playoffs setting shows last spring's until this year's start. Season
# dates come from ESPN's own season calendar.
#
# Regular season boards use ESPN's qualified list (isqualified=true), which
# scales the NBA's minimums to games played so far. ESPN applies no minimum
# to playoff stats, so a starter on a team swept in four games can sit on
# top all spring. Here the playoff bar is one number for everyone: the
# fewest playoff games played by a team still alive in the current round,
# frozen when the Finals start. Per-game pages need that many games; the
# shooting pages need the NBA's regular-season makes rate (300 FG, 82 3PT,
# 125 FT over 82 games) times that many games. The header shows the bar
# where the season would be ("8+ GP", "30+ FGM").
#
# DESIGN. The mlb-offensive-leaders scorebook, on a black ground. The top
# row opens on a basketball in 9x9 pixel art, then an EAST blue / WEST red
# chip when a conference is picked, the stat in white and the season in
# gray (with PLAYOFFS in gold). Under it, three rows: the rank in gray, a
# team badge, the player's name in white (initial and last name if the full
# name won't fit), and the number in white against the right edge. The
# badge is the team's code in its own two colors, like a jersey.
# Everything stays 6px inside both edges so the app reads as its own unit
# in the stream.

# ESPN team id: [code, fill, ink]. Fill and ink start from ESPN's own
# color/alternateColor fields; inks are LED-tuned where the pair is too
# close in brightness to read at 4x5 (Pistons, Thunder, 76ers, Kings,
# Wizards, Clippers, Heat), using another of the team's own colors.
TEAMS = {
    1: ["ATL", "#C8102E", "#FDB927"],   # Hawks: red, volt gold
    2: ["BOS", "#008348", "#FFFFFF"],   # Celtics: green, white
    17: ["BKN", "#000000", "#FFFFFF"],  # Nets: black, white
    30: ["CHA", "#008CA8", "#1D1060"],  # Hornets: teal, purple
    4: ["CHI", "#CE1141", "#000000"],   # Bulls: red, black
    5: ["CLE", "#860038", "#FDBB30"],   # Cavaliers: wine, gold
    6: ["DAL", "#0064B1", "#FFFFFF"],   # Mavericks: blue, white
    7: ["DEN", "#0E2240", "#FEC524"],   # Nuggets: navy, gold
    8: ["DET", "#1D428A", "#FF4C57"],   # Pistons: blue, red
    9: ["GS", "#FDB927", "#1D428A"],    # Warriors: gold, blue
    10: ["HOU", "#CE0E2D", "#FFFFFF"],  # Rockets: red, white
    11: ["IND", "#0C2340", "#FFD520"],  # Pacers: navy, gold
    12: ["LAC", "#C8102E", "#FFFFFF"],  # Clippers: red, white
    13: ["LAL", "#552583", "#FDB927"],  # Lakers: purple, gold
    29: ["MEM", "#5D76A9", "#12173F"],  # Grizzlies: blue, navy
    14: ["MIA", "#98002E", "#F9A01B"],  # Heat: red, yellow
    15: ["MIL", "#00471B", "#EEE1C6"],  # Bucks: green, cream
    16: ["MIN", "#266092", "#79BC43"],  # Timberwolves: blue, green
    3: ["NO", "#0A2240", "#B4975A"],    # Pelicans: navy, gold
    18: ["NY", "#1D428A", "#F58426"],   # Knicks: blue, orange
    25: ["OKC", "#007AC1", "#FDBB30"],  # Thunder: blue, yellow
    19: ["ORL", "#0150B5", "#FFFFFF"],  # Magic: blue, white
    20: ["PHI", "#1D428A", "#FFFFFF"],  # 76ers: blue, white
    21: ["PHX", "#29127A", "#E56020"],  # Suns: purple, orange
    22: ["POR", "#E03A3E", "#000000"],  # Trail Blazers: red, black
    23: ["SAC", "#5A2D81", "#D0D7DC"],  # Kings: purple, silver
    24: ["SA", "#000000", "#C4CED4"],   # Spurs: black, silver
    28: ["TOR", "#D91244", "#FFFFFF"],  # Raptors: red, white
    26: ["UTA", "#4E008E", "#79A3DC"],  # Jazz: purple, blue
    27: ["WSH", "#E31837", "#FFFFFF"],  # Wizards: red, white
}

CONFERENCE_ID = {"East": "5", "West": "6"}

# ---------- palette & grid ----------

INK = "#F4F7FF"      # names, live numbers, the stat title
DIM = "#6E7A94"      # ranks, season, sub-lines
AMBER = "#E8B04A"    # the one attention state (feed offline)
GOLD = "#F2C14E"     # PLAYOFFS in the header
EAST_BLUE = "#2A66D9"
WEST_RED = "#D22D3A"
BALL = "#F26A1B"

PAD = 6              # scroll safe zone, both edges
RANK_W = 5           # one 5x7 digit
BADGE_X = PAD + RANK_W + 2  # 13
BADGE_H = 7
NAME_GAP = 2
GAP = 4              # blank px between a name and its value
ROW_Y = [9, 17, 25]  # three 7px rows, 1px apart, under the 8px header row
HEAD_Y = 2           # 4x5 header text, centered on the ball

# A basketball at 9x9: the center lines and two side seams in black, so on
# the LED they read as the ball's dark grooves. Its last row sits in the
# 1px gap above the first leader row.
LOGO = """
...OOO...
.OKOKOKO.
.KOOKOOK.
OKOOKOOKO
KKKKKKKKK
OKOOKOOKO
.KOOKOOK.
.OKOKOKO.
...OOO...
"""
LOGO_W = 9
LOGO_LEGEND = {"O": BALL, "K": "#000000"}

# Names get one font per page, not per row: "GILGEOUS-ALEXANDER" in 4x7
# beside "DONCIC" in 5x7 reads as a mistake. 5x7 when every name on the page
# fits, else 4x7, then a hard clip.
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
    "Č": "C", "č": "c", "Ć": "C", "ć": "c", "Š": "S", "š": "s",
    "Ž": "Z", "ž": "z", "Đ": "D", "đ": "d", "Ņ": "N", "ņ": "n",
    "Ģ": "G", "ģ": "g", "Ū": "U", "ū": "u", "Ā": "A", "ā": "a",
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

STATS_API = "https://site.web.api.espn.com/apis/common/v3/sports/basketball/nba/statistics/byathlete"
CORE_API = "https://sports.core.api.espn.com/v2/sports/basketball/leagues/nba/seasons/"
STANDINGS = "https://site.web.api.espn.com/apis/v2/sports/basketball/nba/standings"
TTL = 10800          # matches manifest.yaml's refresh - keep in sync
DAY = 86400
MODES = ["Auto", "Regular season", "Playoffs"]
PLAYOFF_PAGE = 50    # athletes per playoff request: ~650 KB of the 1 MB cap

def conference_choice(ctx):
    v = ctx.inputs.get("conference", "NBA")
    return v if v in CONFERENCE_ID else "NBA"

def mode_choice(ctx):
    v = ctx.inputs.get("stats", "Auto")
    return v if v in MODES else "Auto"

def get_json(url, params, ttl):
    resp = http.get(url, params = params, ttl_seconds = ttl)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    return resp["json"]

def today(ctx):
    m = ctx.now.month
    dd = ctx.now.day
    return str(ctx.now.year) + "-" + ("0" if m < 10 else "") + str(m) + "-" + ("0" if dd < 10 else "") + str(dd)

def season_type_dates(year, kind):
    # [start, end] as YYYY-MM-DD for one ESPN season type (2 regular, 3
    # postseason), or None offline.
    d = get_json(CORE_API + str(year) + "/types/" + kind, {"lang": "en", "region": "us"}, DAY)
    if d == None:
        return None
    return [str(d.get("startDate", "9999"))[:10], str(d.get("endDate", "0000"))[:10]]

def which_season(ctx):
    # [season year, "2" regular or "3" playoffs] for this panel, or None
    # offline. ESPN names a season by the year it ends: 2026-27 is 2027.
    t = today(ctx)
    year = ctx.now.year + (1 if ctx.now.month >= 10 else 0)
    post = season_type_dates(year, "3")
    if post == None:
        return None
    mode = mode_choice(ctx)
    if mode == "Playoffs":
        return [year if post[0] <= t else year - 1, "3"]
    if mode == "Auto" and post[0] <= t and t <= post[1]:
        return [year, "3"]
    reg = season_type_dates(year, "2")
    if reg == None:
        return None
    return [year if reg[0] <= t else year - 1, "2"]

def season_label(year):
    # 2027 -> "2026-27"
    return str(year - 1) + "-" + str(year)[2:]

def fetch_athletes(year, kind, conf, sort_key, qualified, limit, page = 1):
    # [athletes, {category: [stat names]}], or None offline.
    params = {
        "page": str(page),
        "region": "us",
        "lang": "en",
        "contentorigin": "espn",
        "season": str(year),
        "seasontype": kind,
        "isqualified": "true" if qualified else "false",
        "sort": sort_key + ":desc",
        "limit": str(limit),
    }
    if conf in CONFERENCE_ID:
        params["conference"] = CONFERENCE_ID[conf]
    d = get_json(STATS_API, params, TTL)
    if d == None:
        return None
    names = {}
    for cat in d.get("categories") or []:
        names[cat.get("name", "")] = cat.get("names") or []
    return [d.get("athletes") or [], names]

def stat_of(athlete, names, category, field):
    # One stat's display string ("33.5", "47.6"), or "".
    for cat in athlete.get("categories") or []:
        if cat.get("name") == category:
            fields = names.get(category, [])
            totals = cat.get("totals") or []
            for i in range(min(len(fields), len(totals))):
                if fields[i] == field:
                    return str(totals[i])
    return ""

def fewest_games_alive(ctx, year):
    # The bar's game count: the fewest playoff games played by a team still
    # in the current round, from ESPN's playoff standings. Every series win
    # is exactly 4 wins, so a team's wins // 4 is the round it's in (0 = 1st
    # round). The current round is the first one not yet fully decided:
    # 8, 4 and 2 teams reach rounds 1-3. A team knocked out this round still
    # counts until the round ends, so the bar can sit a game or two below
    # the strict "still alive" count. There are no byes, so the count never
    # drops when a round opens. It stops rising when the Finals start.
    d = get_json(STANDINGS, {"season": str(year), "seasontype": "3"}, TTL)
    if d == None:
        return None
    teams = []   # [round, games, wins]
    for conf in d.get("children") or []:
        for e in (conf.get("standings") or {}).get("entries") or []:
            st = {}
            for x in e.get("stats") or []:
                st[x.get("name", "")] = x.get("value", 0) or 0
            w, l = int(st.get("wins", 0)), int(st.get("losses", 0))
            if w + l > 0:
                teams.append([w // 4, w + l, w])
    if len(teams) < 16:
        # Day 1 of the 1st round: some teams haven't tipped off yet.
        return 0
    current = 0
    for r in range(3):
        if len([t for t in teams if t[0] >= r + 1]) < [8, 4, 2][r]:
            break
        current = r + 1
    if current == 3:
        # Frozen for the Finals: both finalists have played the same Finals
        # games (one series), so the bar is the fewest games either played
        # through the conference finals.
        finalists = [t for t in teams if t[0] >= 3]
        finals = 0
        for t in finalists:
            finals += t[2] - 12
        return min([t[1] for t in finalists]) - finals
    return min([t[1] for t in teams if t[0] >= current])

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
    # keeps its last half whole: "GILGEOUS-ALEXANDER" becomes "G-ALEXANDER"
    # rather than clipping mid-word.
    if "-" not in name or c.text_width(name, NAME_FONTS[-1]) <= maxw:
        return name
    parts = name.split("-")
    return parts[0][:1] + "-" + "-".join(parts[1:])

# ---------- chrome ----------

def conference_chip(c, conf, x):
    # 7px pill beside the ball: 4x5 text with 1px of fill above and below,
    # 2px either side.
    label = conf.upper()
    w = c.text_width(label, "4x5") + 4
    c.round_rect(x, 1, x + w - 1, 7, 1, fill = EAST_BLUE if conf == "East" else WEST_RED)
    c.text(label, x + 2, HEAD_Y, font = "4x5", color = "white")
    return x + w

def header(c, conf, titles, season, post):
    # titles runs longest first; the header takes the first that fits beside
    # the ball, chip and season. A playoff board says so in gold after the
    # season.
    right = c.width - PAD - 1
    c.sprite(LOGO, PAD, 0, legend = LOGO_LEGEND)
    x = PAD + LOGO_W + 3
    if conf in CONFERENCE_ID:
        x = conference_chip(c, conf, x) + 3
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
    # which stat and conference it is.
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

# ---------- team badges ----------

def team_style(team_id, team_abbr):
    t = TEAMS.get(team_id)
    if t:
        return t
    # A team this table doesn't know (a bad/missing id, or an expansion team
    # not yet added): a neutral badge with whatever code ESPN handed us
    # beats a blank.
    return [team_abbr.upper()[:3] or "?", "#444444", "#FFFFFF"]

def badge_width(c):
    # One width for every badge so the names start on one column: the
    # widest code (3 chars at 4x5) plus 2px of fill either side.
    w = 0
    for t in TEAMS.values():
        w = max(w, c.text_width(t[0], "4x5"))
    return w + 4

def badge(c, x, y, w, style):
    code, fill, ink = style[0], style[1], style[2]
    # Navy/black/purple fills vanish into the ground, so the dark ones get
    # a rim - a half-tone of their own ink, not gray.
    edge = blend(ink, fill, 50) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + w - 1, y + BADGE_H - 1, 1, fill = fill, outline = edge)
    c.text(clip(c, code, "4x5", w - 2), x + w // 2, y + 1, font = "4x5", color = ink, align = "center")

# ---------- the leaderboard ----------

def to_num(v):
    # "33.5", "12" -> a number; anything else ("-", "") -> None.
    t = str(v)
    if t == "" or t == "." or t == "-":
        return None
    for i in range(len(t)):
        if t[i] not in "0123456789.":
            return None
    return float(t)

def ranked(rows):
    # rows: [value, tiebreak, athlete], best first. Top 3 with zero values
    # dropped; ties share a rank (1, 2, 2).
    rows = [r for r in rows if r[0] > 0]
    rows = sorted(rows, key = lambda r: (-r[0], -r[1]))
    out = []
    for i in range(min(len(ROW_Y), len(rows))):
        better = len([r for r in rows if r[0] > rows[i][0]])
        out.append([better + 1, rows[i][0], rows[i][2]])
    return out

def display_name(c, athlete, room):
    # The longest form that fits in the main font: "LUKA DONCIC", then
    # "L. DONCIC", then "DONCIC"; a double-barrelled last name that still
    # won't fit keeps its last half ("G-ALEXANDER").
    last = strip_accents(str(athlete.get("lastName", "?"))).upper()
    full = strip_accents(str(athlete.get("displayName", ""))).upper()
    forms = [full, full[:1] + ". " + last] if full != "" else []
    for f in forms:
        if c.text_width(f, NAME_FONTS[0]) <= room:
            return f
    return short_name(c, last, room)

def ceil(x):
    return int(x) + (1 if x > int(x) else 0)

def leaderboard(c, ctx, category, field, makes, rate, titles):
    # makes/rate: for a shooting page, the made-shots field and the NBA's
    # makes-per-game minimum; "" and 0 for a per-game page.
    c.clear()
    conf = conference_choice(ctx)
    which = which_season(ctx)
    if which == None:
        # No feed, so no season to vouch for - the ball and stat still say
        # which page this is.
        header(c, conf, titles, "", False)
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
    year, kind = which[0], which[1]
    post = kind == "3"
    label = season_label(year)
    rows = []
    if post:
        games = fewest_games_alive(ctx, year)
        if games == None:
            header(c, conf, titles, "", True)
            return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
        need = ceil(games * rate) if makes != "" else games
        if games > 0:
            label = str(need) + "+ " + ("GP" if makes == "" else {"fieldGoalsMade": "FGM", "threePointFieldGoalsMade": "3PM", "freeThrowsMade": "FTM"}[makes])
        # The full playoff list is ~3 MB, over the 1 MB body cap, so read it
        # sorted on this stat 50 at a time: the first 3 that clear the bar
        # are the leaders. They sit in the top ~55 at any bar (2026 check),
        # so this is one or two requests.
        for page in range(1, 6):
            got = fetch_athletes(year, "3", conf, category + "." + field, False, PLAYOFF_PAGE, page)
            if got == None:
                header(c, conf, titles, "", True)
                return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
            athletes, names = got[0], got[1]
            for a in athletes:
                v = to_num(stat_of(a, names, category, field))
                volume = to_num(stat_of(a, names, "offensive" if makes != "" else "general", makes if makes != "" else "gamesPlayed")) or 0
                if v == None or volume < need:
                    continue
                rows.append([v, volume, a])
            if len(rows) >= len(ROW_Y) or len(athletes) < PLAYOFF_PAGE:
                break
    else:
        # ESPN's qualified list, already sorted on this stat.
        got = fetch_athletes(year, "2", conf, category + "." + field, True, 10)
        if got == None:
            header(c, conf, titles, "", False)
            return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
        athletes, names = got[0], got[1]
        for i in range(len(athletes)):
            v = to_num(stat_of(athletes[i], names, category, field))
            if v != None:
                rows.append([v, -i, athletes[i]])
    header(c, conf, titles, label, post)
    top = ranked(rows)
    if len(top) == 0:
        # Before opening night or the first playoff game there's simply no
        # leaderboard - not an error.
        if post:
            return message(c, "NO PLAYOFF STATS YET", "FIRST TIP SOON", INK)
        return message(c, "NO STATS YET", "BACK ON OPENING NIGHT", INK)

    draw = []
    for rank, v, a in top:
        athlete = a.get("athlete") or {}
        tid = athlete.get("teamId")
        draw.append({
            "rank": str(rank),
            "style": team_style(int(tid) if tid != None else -1, str(athlete.get("teamShortName", ""))),
            "athlete": athlete,
            "value": stat_of(a, names, category, field),
        })

    # Values right-aligned on the edge and measured first; the names get
    # what's left.
    right = c.width - PAD - 1
    bw = badge_width(c)
    name_x = BADGE_X + bw + NAME_GAP
    valw = 0
    for r in draw:
        valw = max(valw, c.text_width(r["value"], VALUE_FONT))
    room = right - valw - GAP - name_x + 1
    for r in draw:
        r["name"] = display_name(c, r["athlete"], room)
    font = page_font(c, [r["name"] for r in draw], room)

    for i in range(len(draw)):
        r = draw[i]
        y = ROW_Y[i]
        c.text(clip(c, r["rank"], "5x7", RANK_W), PAD + RANK_W // 2, y, font = "5x7", color = DIM, align = "center")
        badge(c, BADGE_X, y, bw, r["style"])
        c.text(clip(c, r["name"], font, room), name_x, y, font = font, color = INK)
        c.text(clip(c, r["value"], VALUE_FONT, valw), right, y, font = VALUE_FONT, color = INK, align = "right")

# ---------- pages ----------

def points(c, ctx):
    leaderboard(c, ctx, "offensive", "avgPoints", "", 0, ["POINTS PER GAME", "POINTS"])

def rebounds(c, ctx):
    leaderboard(c, ctx, "general", "avgRebounds", "", 0, ["REBOUNDS PER GAME", "REBOUNDS"])

def assists(c, ctx):
    leaderboard(c, ctx, "offensive", "avgAssists", "", 0, ["ASSISTS PER GAME", "ASSISTS"])

def steals(c, ctx):
    leaderboard(c, ctx, "defensive", "avgSteals", "", 0, ["STEALS PER GAME", "STEALS"])

def blocks(c, ctx):
    leaderboard(c, ctx, "defensive", "avgBlocks", "", 0, ["BLOCKS PER GAME", "BLOCKS"])

def fgpct(c, ctx):
    leaderboard(c, ctx, "offensive", "fieldGoalPct", "fieldGoalsMade", 300.0 / 82, ["FIELD GOAL PCT", "FG PCT"])

def tppct(c, ctx):
    leaderboard(c, ctx, "offensive", "threePointFieldGoalPct", "threePointFieldGoalsMade", 1.0, ["THREE POINT PCT", "3PT PCT"])

def ftpct(c, ctx):
    leaderboard(c, ctx, "offensive", "freeThrowPct", "freeThrowsMade", 125.0 / 82, ["FREE THROW PCT", "FT PCT"])
