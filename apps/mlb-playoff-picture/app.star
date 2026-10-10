# MLB Playoff Picture (192x32)
#
# Two modes, picked from MLB's own season calendar:
#
#   RACE (regular season) - the field if the season ended today, with clinch
#   marks, first-round matchups, the wild card race and division magic numbers.
#
#   POSTSEASON (until next opening day) - every series with its score, TV
#   network, and the next game, live inning, or winner.
#
# Every page works in both modes, so the manifest's page list never changes:
#
#   page    race                     postseason
#   intro   if season ended today    postseason / champion
#   al1     AL field (seeds 1-6)     AL Wild Card Series
#   al2     AL first round + byes    AL Division Series
#   al3     AL wild card race        AL Championship Series
#   nl1-3   same for the NL
#   final   division races           World Series
#
# Magic numbers come from raw wins/losses (the API's own fields lag) and are
# shifted by one when the head-to-head tiebreaker is already decided.
#
# Data from MLB's own public Stats API (statsapi.mlb.com) - no key required.
#
# Each team is a tile in its color carrying its seed, with the nickname in
# white beside it. Everything stays 6px inside both edges.

TEAM_COLORS = {
    108: ["#BA0021"],  # LAA (Red)
    109: ["#A71930"],  # AZ (Sedona Red)
    110: ["#DF4601"],  # BAL (Orange)
    111: ["#BD3039"],  # BOS (Red)
    112: ["#0E3386"],  # CHC (Cubs Blue)
    113: ["#C6011F"],  # CIN (Red)
    114: ["#E31937"],  # CLE (Red)
    115: ["#333366", "#C4CED4"],  # COL (purple, silver)
    116: ["#FA4616"],  # DET (Orange)
    117: ["#F4911E"],  # HOU (Orange)
    118: ["#004687"],  # KC (Royal Blue)
    119: ["#005A9C"],  # LAD (Dodger Blue)
    120: ["#AB0003"],  # WSH (Red)
    121: ["#FF5910"],  # NYM (Orange)
    133: ["#EFB21E"],  # ATH (Gold)
    134: ["#FDB827"],  # PIT (Gold)
    135: ["#FFC425"],  # SD (Gold)
    136: ["#005C5C"],  # SEA (Northwest Green)
    137: ["#FD5A1E"],  # SF (Orange)
    138: ["#C41E3A"],  # STL (Cardinal Red)
    139: ["#8FBCE6"],  # TB (Columbia Blue)
    140: ["#003278"],  # TEX (Blue)
    141: ["#134A8E"],  # TOR (Blue)
    142: ["#D31145"],  # MIN (Scarlet Red)
    143: ["#E81828"],  # PHI (Red)
    144: ["#CE1141"],  # ATL (Scarlet)
    145: ["#27251F"],  # CWS
    146: ["#00A3E0"],  # MIA (Miami Blue)
    147: ["#0C2340"],  # NYY (Navy)
    158: ["#12284B"],  # MIL (Navy Blue)
}

AL_ID = 103
NL_ID = 104

# division id -> [league, short label], in conventional East/Central/West order
DIVISIONS = [
    [201, "AL", "E"],
    [202, "AL", "C"],
    [200, "AL", "W"],
    [204, "NL", "E"],
    [205, "NL", "C"],
    [203, "NL", "W"],
]

SEASON_GAMES = 162
WC_SPOTS = 3

# ---------- palette & grid ----------

INK = "#F4F7FF"     # names, live numbers
DIM = "#6E7A94"     # labels, meta
STRUCT = "#282828"  # dividers
AMBER = "#E8B04A"   # attention: a tiebreaker, a series winner
GREEN = "#3FCF6E"   # magic numbers, clinched
RED = "#E5484D"     # tragic numbers, eliminated
LIVE = GREEN
NETWORK = "#B79CFF"  # TV network
LEADING = "#5FC8FF"  # series wins of the team ahead in a series still going
LEAGUE = {"AL": "#D22D3A", "NL": "#2A66D9"}

PAD = 6             # scroll safe zone, both edges
TILE_W = 9
TILE_H = 9
NAME_GAP = 2
NAME_W = 44         # GUARDIANS at 4x7
ROW_Y = [10, 21]    # two 9px rows under the 7px chip row
SMALL_Y = [8, 16, 24]  # three 7px rows, 1px apart

# One font per page for names: 5x7 when every name fits, else 4x7, then clip.
NAME_FONTS = ["5x7", "4x7"]

# Original pixel-art baseball for the intro card.
BALL = [
    ".....ssssss.....",
    "...sswwwwwwss...",
    "..srwwwwwwwwrs..",
    ".swrwwwwwwwwrws.",
    ".swwrwwwwwwrwws.",
    "swwwrwwwwwwrwwws",
    "swwwrwwwwwwrwwws",
    "swwwrwwwwwwrwwws",
    "swwwrwwwwwwrwwws",
    "swwwrwwwwwwrwwws",
    "swwwrwwwwwwrwwws",
    ".swwrwwwwwwrwws.",
    ".swrwwwwwwwwrws.",
    "..srwwwwwwwwrs..",
    "...sswwwwwwss...",
    ".....ssssss.....",
]
BALL_LEGEND = {"s": "#8C95A8", "w": INK, "r": "#E03A3E"}
BALL_W = 16

# ---------- color helpers ----------

HEX = "0123456789ABCDEF"

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def lighten(hex_color, pct):
    out = "#"
    for i in [1, 3, 5]:
        v = int(hex_color[i:i + 2], 16)
        v = v + (255 - v) * pct // 100
        out += HEX[v // 16] + HEX[v % 16]
    return out

def team_color(team_id):
    # Darkest of the team's colors - COL's silver would wash the tile out.
    colors = TEAM_COLORS.get(team_id, ["#3A3F4B"])
    best = colors[0]
    for col in colors:
        if brightness(col) < brightness(best):
            best = col
    return best

def ink_on(fill):
    return "black" if brightness(fill) > 150 else "white"

# ---------- dates (ET game day) ----------
# ctx.now is UTC. Night games run past midnight UTC, so the game day is taken
# at a fixed UTC-5; displayed clock times use UTC-4, since the regular season
# and postseason sit almost entirely inside Daylight Time.

ET_QUERY_OFFSET_SECONDS = 5 * 3600
ET_DISPLAY_OFFSET_SECONDS = 4 * 3600
DAY_NAMES = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def civil_from_days(z):
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return y, m, d

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def date_str(y, m, d):
    return str(y) + "-" + pad2(m) + "-" + pad2(d)

def today_str(ctx):
    shifted = ctx.now.unix - ET_QUERY_OFFSET_SECONDS
    return date_str(*civil_from_days(shifted // 86400))

def iso_unix(iso):
    # "2026-10-03T22:30:00Z" - fixed width, safe to slice.
    days = days_from_civil(int(iso[0:4]), int(iso[5:7]), int(iso[8:10]))
    return days * 86400 + int(iso[11:13]) * 3600 + int(iso[14:16]) * 60

def et_parts(iso):
    # [game-day date string, weekday name, "8:08P"] in ET
    t = iso_unix(iso) - ET_DISPLAY_OFFSET_SECONDS
    days = t // 86400
    sod = t % 86400
    y, m, d = civil_from_days(days)
    h = sod // 3600
    hh = h % 12
    if hh == 0:
        hh = 12
    clock = str(hh) + ":" + pad2((sod % 3600) // 60) + ("A" if h < 12 else "P")
    return [date_str(y, m, d), DAY_NAMES[(days + 3) % 7], clock, MONTHS[m - 1] + " " + str(d)]

# ---------- network (keyless) ----------

API = "https://statsapi.mlb.com/api/v1"

def get_json(path, params, ttl):
    resp = http.get(API + path, params = params, ttl_seconds = ttl)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    return resp["json"]

def season_dates(year):
    data = get_json("/seasons/" + str(year), {"sportId": "1"}, 86400)
    if data == None or len(data.get("seasons", [])) == 0:
        return None
    s = data["seasons"][0]
    return {
        "start": s.get("regularSeasonStartDate", ""),
        "end": s.get("regularSeasonEndDate", ""),
    }

def load_mode(ctx):
    # {"mode": "race"|"post", "season": year, "end": last regular-season day}
    today = today_str(ctx)
    year = ctx.now.year
    dates = season_dates(year)
    if dates == None:
        return None
    if dates["start"] != "" and today < dates["start"]:
        # spring: last October's bracket stays up until opening day
        prev = season_dates(year - 1)
        if prev == None:
            return None
        return {"mode": "post", "season": year - 1, "end": prev["end"], "today": today}
    if dates["end"] != "" and today > dates["end"]:
        return {"mode": "post", "season": year, "end": dates["end"], "today": today}
    return {"mode": "race", "season": year, "end": dates["end"], "today": today}

def team_info():
    data = get_json("/teams", {"sportId": "1"}, 2592000)
    out = {}
    if data == None:
        return out
    for t in data.get("teams", []):
        out[t.get("id")] = {
            "abbr": t.get("abbreviation", ""),
            "name": t.get("teamName", ""),
        }
    return out

def standings(season, date):
    data = get_json("/standings", {
        "leagueId": "103,104",
        "season": str(season),
        "standingsTypes": "regularSeason",
        "date": date,
    }, 300)
    if data == None:
        return None
    return data.get("records", [])

def season_schedule(season, end):
    # Every regular-season game, trimmed to what head-to-head needs (~400KB).
    data = get_json("/schedule", {
        "sportId": "1",
        "gameType": "R",
        "season": str(season),
        "startDate": str(season) + "-01-01",
        "endDate": end,
        "fields": "dates,games,gameDate,officialDate,status,abstractGameState,teams,away,home,team,id,isWinner",
    }, 1800)
    if data == None:
        return None
    games = []
    for d in data.get("dates", []):
        for g in d.get("games", []):
            games.append(g)
    return games

def postseason_series(season):
    data = get_json("/schedule/postseason/series", {
        "season": str(season),
        "sportId": "1",
        "hydrate": "linescore,broadcasts(all)",
    }, 60)
    if data == None:
        return None
    return data.get("series", [])

# ---------- head-to-head ----------

def h2h_key(a, b):
    return str(min(a, b)) + "-" + str(max(a, b))

def build_h2h(games, today, now_unix):
    # won[key][team] = season-series wins so far; left[key] = meetings still to play
    won = {}
    left = {}
    for g in games:
        a = g.get("teams", {}).get("away", {})
        h = g.get("teams", {}).get("home", {})
        aid = a.get("team", {}).get("id", 0)
        hid = h.get("team", {}).get("id", 0)
        key = h2h_key(aid, hid)
        final = g.get("status", {}).get("abstractGameState") == "Final"
        started = iso_unix(g.get("gameDate", "2000-01-01T00:00:00Z")) <= now_unix
        if final and started:
            winner = hid if h.get("isWinner") else (aid if a.get("isWinner") else 0)
            if winner == 0:
                continue
            tally = won.get(key, {})
            tally[winner] = tally.get(winner, 0) + 1
            won[key] = tally
        elif g.get("officialDate", "") >= today:
            left[key] = left.get(key, 0) + 1
    return {"won": won, "left": left}

def remaining_meetings(h2h, a, b):
    if h2h == None:
        return 0
    return h2h["left"].get(h2h_key(a, b), 0)

def tiebreak_favors(h2h, team, rival, team_extra, rival_extra):
    # True: team wins a final tie with rival; False: rival does; None: open.
    if h2h == None:
        return None
    tally = h2h["won"].get(h2h_key(team, rival), {})
    t = tally.get(team, 0) + team_extra
    r = tally.get(rival, 0) + rival_extra
    if t == r:
        return None
    return t > r

# ---------- standings shape ----------

def tid(t):
    return t.get("team", {}).get("id", -1)

def rank(t, field):
    v = t.get(field)
    if v == None or v == "" or v == "-":
        return 999
    return int(v)

def sort_by(items, field):
    out = list(items)
    n = len(out)
    for i in range(n):
        for j in range(n - 1 - i):
            if rank(out[j], field) > rank(out[j + 1], field):
                out[j], out[j + 1] = out[j + 1], out[j]
    return out

def shape(records):
    # {"div": {div_id: [teams by divisionRank]}, "league": {lg: [teams]}, "all": [...]}
    div = {}
    league = {"AL": [], "NL": []}
    all_teams = []
    for block in records:
        did = block.get("division", {}).get("id")
        lid = block.get("league", {}).get("id")
        lg = "AL" if lid == AL_ID else "NL"
        div[did] = sort_by(block.get("teamRecords", []), "divisionRank")
        for t in block.get("teamRecords", []):
            league[lg].append(t)
            all_teams.append(t)
    return {"div": div, "league": league, "all": all_teams}

def division_leaders(sh, lg):
    out = []
    for d in DIVISIONS:
        if d[1] == lg and len(sh["div"].get(d[0], [])) > 0:
            out.append(sh["div"][d[0]][0])
    return sort_by(out, "leagueRank")

def wc_teams(sh, lg):
    leader_ids = [tid(t) for t in division_leaders(sh, lg)]
    pool = [t for t in sh["league"][lg] if tid(t) not in leader_ids]
    return sort_by(pool, "wildCardRank")

def seeds_for(sh, lg):
    return division_leaders(sh, lg) + wc_teams(sh, lg)[:WC_SPOTS]

DIVISION_WORDS = {"E": "EAST", "C": "CENTRAL", "W": "WEST"}

def division_name(sh, team_id):
    for d in DIVISIONS:
        for t in sh["div"].get(d[0], []):
            if tid(t) == team_id:
                return d[1] + " " + DIVISION_WORDS[d[2]]
    return ""

def division_of(sh, team_id):
    for did in sh["div"]:
        for t in sh["div"][did]:
            if tid(t) == team_id:
                return sh["div"][did]
    return []

# ---------- magic numbers ----------
# Each returns [text, color]. Numbers are "games won by this team or lost by
# the rival" - the standard magic number - with the head-to-head shift.

def division_status(t, div_teams, h2h):
    if t.get("divisionChamp", False):
        return ["WON", GREEN, None]
    team = tid(t)
    leader = div_teams[0]
    if tid(leader) == team:
        rivals = div_teams[1:]
        if len(rivals) == 0:
            return ["-", DIM, None]
        best = rivals[0]
        for r in rivals:
            if r.get("losses", 0) < best.get("losses", 0):
                best = r
        magic = SEASON_GAMES + 1 - t.get("wins", 0) - best.get("losses", 0)
        if tiebreak_favors(h2h, team, tid(best), 0, remaining_meetings(h2h, team, tid(best))) == True:
            magic -= 1
        if magic <= 0:
            return ["WON", GREEN, None]
        return [str(magic), GREEN, magic]
    elim = SEASON_GAMES + 1 - leader.get("wins", 0) - t.get("losses", 0)
    if tiebreak_favors(h2h, team, tid(leader), remaining_meetings(h2h, team, tid(leader)), 0) == False:
        elim -= 1
    if elim <= 0:
        return ["E", RED, None]
    return [str(elim), RED, elim]

def wc_rival(t, wc):
    # The third-best other team in the pool: finishing ahead of it clinches
    # a spot, finishing behind it eliminates.
    others = [o for o in wc if tid(o) != tid(t)]
    if len(others) < WC_SPOTS:
        return None
    return others[WC_SPOTS - 1]

def wc_elim_number(t, wc, h2h):
    # Games until this team can no longer finish ahead of its rival.
    rival = wc_rival(t, wc)
    if rival == None:
        return None
    team = tid(t)
    elim = SEASON_GAMES + 1 - t.get("losses", 0) - rival.get("wins", 0)
    if tiebreak_favors(h2h, team, tid(rival), remaining_meetings(h2h, team, tid(rival)), 0) == False:
        elim -= 1
    return elim

def playoff_status(t, wc, div_teams, h2h):
    # The playoff-berth number, swapped for the tragic number when the team
    # is closer to elimination than to clinching.
    if t.get("clinched", False):
        return ["IN", GREEN]
    elim = wc_elim_number(t, wc, h2h)
    if elim != None and elim <= 0:
        # out of the wild card, but winning the division is its own route
        d = division_status(t, div_teams, h2h)
        if d[0] != "E" and d[0] != "-":
            return [d[0], d[1], "DIV"]
        return ["E", RED]
    rival = wc_rival(t, wc)
    if rival == None:
        return ["-", DIM]
    team = tid(t)
    magic = SEASON_GAMES + 1 - t.get("wins", 0) - rival.get("losses", 0)
    if tiebreak_favors(h2h, team, tid(rival), 0, remaining_meetings(h2h, team, tid(rival))) == True:
        magic -= 1
    if magic <= 0:
        return ["IN", GREEN]
    if elim != None and elim < magic:
        return [str(elim), RED]
    return [str(magic), GREEN]

def best_record_clinched(t, others, h2h):
    team = tid(t)
    for o in others:
        magic = SEASON_GAMES + 1 - t.get("wins", 0) - o.get("losses", 0)
        if magic <= 0:
            continue
        if magic == 1 and tiebreak_favors(h2h, team, tid(o), 0, remaining_meetings(h2h, team, tid(o))) == True:
            continue
        return False
    return True

# The small fonts have no "*", so best-in-MLB gets a drawn 5x5 asterisk.
STAR = [
    "..g..",
    "g.g.g",
    ".ggg.",
    "g.g.g",
    "..g..",
]

def draw_mark(c, mark, x, y):
    if mark == "*":
        c.sprite(STAR, x, y, legend = {"g": GREEN})
    else:
        c.text(mark, x, y, font = "4x5", color = GREEN)

def top_mark(t, sh, lg, h2h):
    # Most superior clinch mark only: * best in MLB > z best in league > y
    # division > x berth. Each implies the ones after it.
    team = tid(t)
    if t.get("sportRank") == "1":
        if best_record_clinched(t, [o for o in sh["all"] if tid(o) != team], h2h):
            return "*"
    if t.get("leagueRank") == "1":
        if best_record_clinched(t, [o for o in sh["league"][lg] if tid(o) != team], h2h):
            return "Z"
    if t.get("divisionChamp", False):
        return "Y"
    if t.get("clinched", False):
        return "X"
    return ""

def load_race(ctx, m):
    recs = standings(m["season"], m["today"])
    if recs == None:
        return None
    games = season_schedule(m["season"], m["end"])
    # head-to-head is a refinement; the page still works without it
    h2h = build_h2h(games, m["today"], ctx.now.unix) if games != None else None
    return {"sh": shape(recs), "h2h": h2h, "numbers": m["today"] >= str(m["season"]) + "-08-01"}

# ---------- text helpers ----------

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
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

def nick_of(team_id, fallback, teams):
    info = teams.get(team_id)
    if info and info["name"]:
        return info["name"].upper()
    return fallback.split(" ")[-1].upper() if fallback else "TBD"

def abbr_of(team_id, fallback, teams):
    info = teams.get(team_id)
    if info and info["abbr"]:
        return info["abbr"].upper()
    return nick_of(team_id, fallback, teams)[:3]

def nickname(t, teams):
    return nick_of(tid(t), t.get("team", {}).get("name", "???"), teams)

# ---------- chrome ----------

def chip(c, word, bg, x, right = False):
    w = c.text_width(word, "4x5") + 4
    x0 = x - w + 1 if right else x
    c.round_rect(x0, 0, x0 + w - 1, 6, 1, fill = bg)
    c.text(word, x0 + 2, 1, font = "4x5", color = ink_on(bg))
    return x0 + w

def header(c, lg, title, meta = ""):
    x = chip(c, lg, LEAGUE[lg], PAD)
    c.text(title, x + 3, 1, font = "4x5", color = INK)
    if meta != "":
        c.text(meta, c.width - PAD, 1, font = "4x5", color = DIM, align = "right")

def message(c, head, sub, head_color):
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

def offline(c):
    message(c, "STANDINGS OFFLINE", "TRYING AGAIN SOON", AMBER)

def not_yet(c):
    message(c, "NO STANDINGS YET", "BACK ON OPENING DAY", INK)

def tile(c, x, y, h, team_id, label):
    fill = team_color(team_id)
    # navy and near-black tiles get a rim in a lighter tint of themselves
    edge = lighten(fill, 45) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + TILE_W - 1, y + h - 1, 1, fill = fill, outline = edge)
    if label != "":
        font = "5x7" if h >= 9 else "4x5"
        ty = y + (h - 7) // 2 if h >= 9 else y + 1
        c.text(label, x + TILE_W // 2, ty, font = font, color = ink_on(fill), align = "center")

def team_cell(c, x, y, seed, team_id, text, font, color = INK, maxw = NAME_W):
    tile(c, x, y, TILE_H, team_id, str(seed) if seed > 0 else "")
    c.text(clip(c, text, font, maxw), x + TILE_W + NAME_GAP, y + 1, font = font, color = color)

# ---------- intro ----------

def intro_card(c, kicker, hero, sub, sub_color):
    hw = c.text_width(hero, "10x16")
    lockup = BALL_W + 6 + hw
    x0 = max(PAD, (c.width - lockup) // 2)
    hx = x0 + BALL_W + 6
    c.sprite(BALL, x0, 8, legend = BALL_LEGEND)
    c.text(kicker, hx, 1, font = "4x5", color = DIM)
    c.text(hero, hx, 8, font = "10x16", color = INK)
    c.text(sub, c.width // 2, 26, font = "4x5", color = sub_color, align = "center")

def intro(c, ctx):
    c.clear()
    m = load_mode(ctx)
    if m == None:
        return intro_card(c, "MLB " + str(ctx.now.year), "PLAYOFFS", "IF SEASON ENDED TODAY", DIM)
    if m["mode"] == "race":
        return intro_card(c, "MLB " + str(m["season"]), "PLAYOFF PICTURE", "IF THE SEASON ENDED TODAY", DIM)
    series = postseason_series(m["season"])
    teams = team_info()
    champ = None
    if series != None:
        for s in series:
            st = series_state(s, ctx)
            if st["round"] == "W" and st["winner"] != None:
                champ = st["winner"]
    if champ != None:
        name = nick_of(champ["id"], champ["name"], teams)
        return intro_card(c, "MLB " + str(m["season"]), "CHAMPIONS", name + " WIN THE WORLD SERIES", AMBER)
    intro_card(c, "MLB " + str(m["season"]), "POSTSEASON", "THE ROAD TO THE WORLD SERIES", DIM)

# The fonts have no "@", so the host marker is drawn: 4x5.
AT_SIGN = [
    ".gg.",
    "g.gg",
    "g.gg",
    "g...",
    ".gg.",
]

def draw_at(c, cx, y, color):
    c.sprite(AT_SIGN, cx - 1, y, legend = {"g": color})

# ---------- race pages ----------

def race_field(c, data, lg, teams):
    # Seeds 1-3 (division winners) on top, wild cards 4-6 below, three columns.
    header(c, lg, "PLAYOFF FIELD")
    sh = data["sh"]
    seeds = seeds_for(sh, lg)
    if len(seeds) < 6:
        return not_yet(c)
    col_x = [PAD, 68, 130]
    names = [nickname(t, teams) for t in seeds]
    font = page_font(c, names, NAME_W)
    for i in range(6):
        t = seeds[i]
        x = col_x[i % 3]
        y = ROW_Y[i // 3]
        team_cell(c, x, y, i + 1, tid(t), names[i], font)
        mark = top_mark(t, sh, lg, data["h2h"])
        if mark != "":
            mx = x + TILE_W + NAME_GAP + c.text_width(clip(c, names[i], font, NAME_W), font) + 2
            draw_mark(c, mark, mx, y + 1)

def race_matchups(c, data, lg, teams):
    # One bracket half per row: the wild card pair, then the bye team waiting.
    header(c, lg, "FIRST ROUND", "WINNER FACES")
    seeds = seeds_for(data["sh"], lg)
    if len(seeds) < 6:
        return not_yet(c)
    rows = [[6, 3, 2], [5, 4, 1]]   # visitor, host, bye seed
    names = []
    for r in rows:
        for s in r:
            names.append(nickname(seeds[s - 1], teams))
    font = page_font(c, names, NAME_W)
    for i in range(2):
        y = ROW_Y[i]
        r = rows[i]
        team_cell(c, PAD, y, r[0], tid(seeds[r[0] - 1]), names[i * 3], font)
        # 2px clear on both sides of the @ and the arrow
        draw_at(c, 64, y + 2, DIM)
        team_cell(c, 69, y, r[1], tid(seeds[r[1] - 1]), names[i * 3 + 1], font)
        # the fonts have no ">", so the arrow to the waiting bye team is drawn
        for k in range(3):
            c.pixel(126 + k, y + 2 + k, DIM)
            c.pixel(126 + k, y + 6 - k, DIM)
        team_cell(c, 131, y, r[2], tid(seeds[r[2] - 1]), names[i * 3 + 2], font)

def race_wildcard(c, data, lg, teams):
    # From the last team in down, up to three teams that are neither IN nor
    # E. Unused rows stay blank.
    sh = data["sh"]
    wc = wc_teams(sh, lg)
    header(c, lg, "WILD CARD RACE")
    if len(wc) < WC_SPOTS + 2:
        return not_yet(c)
    right = c.width - PAD
    early = not data["numbers"]
    col_rec = 104       # W-L, right edge
    col_gb = 130        # GB, right edge
    col_3 = 156         # STRK before August 1, DIV after
    c.text("GB", col_gb, 1, font = "4x5", color = DIM, align = "right")
    if early:
        c.text("STRK", col_3, 1, font = "4x5", color = DIM, align = "right")
        c.text("L10", right, 1, font = "4x5", color = DIM, align = "right")
    else:
        c.text("DIV", col_3, 1, font = "4x5", color = DIM, align = "right")
        c.text("M/E#", right, 1, font = "4x5", color = DIM, align = "right")
    rows = []           # [wild card rank index, team, status]
    for k in range(WC_SPOTS - 1, len(wc)):
        if len(rows) == 3:
            break
        st = playoff_status(wc[k], wc, division_of(sh, tid(wc[k])), data["h2h"])
        if st[0] != "E" and st[0] != "IN":
            rows.append([k, wc[k], st])
    names = [nickname(r[1], teams) for r in rows]
    font = page_font(c, names, 60)
    for i in range(len(rows)):
        k, t, st = rows[i]
        y = SMALL_Y[i]
        tile(c, PAD, y, 7, tid(t), "")
        holding = k < WC_SPOTS
        if holding:
            c.text(str(k + 4), PAD + TILE_W // 2, y + 1, font = "4x5", color = ink_on(team_color(tid(t))), align = "center")
        c.text(clip(c, names[i], font, 60), PAD + TILE_W + NAME_GAP, y, font = font, color = INK)
        c.text(str(t.get("wins", 0)) + "-" + str(t.get("losses", 0)), col_rec, y + 1, font = "4x5", color = DIM, align = "right")
        gb = t.get("wildCardGamesBack", "-")
        gb_text = "-" if holding else ("TIED" if gb in ("-", "", None) else str(gb))
        c.text(gb_text, col_gb, y, font = "5x7", color = AMBER if gb_text == "TIED" else INK, align = "right")
        if early:
            sk = (t.get("streak") or {}).get("streakCode", "-")
            c.text(sk, col_3, y + 1, font = "4x5", color = GREEN if sk.startswith("W") else (RED if sk.startswith("L") else DIM), align = "right")
            c.text(last_ten(t), right, y + 1, font = "4x5", color = INK, align = "right")
        else:
            # the division-title elimination number (E once it's gone)
            d = division_status(t, division_of(sh, tid(t)), data["h2h"])
            c.text(d[0], col_3, y, font = "5x7", color = RED, align = "right")
            c.text(st[0], right, y, font = "5x7", color = st[1], align = "right")

def last_ten(t):
    for r in (t.get("records") or {}).get("splitRecords", []):
        if r.get("type") == "lastTen":
            return str(r.get("wins", 0)) + "-" + str(r.get("losses", 0))
    return "-"

def division_lead(div):
    # the leader's lead in games over 2nd place
    if len(div) < 2:
        return ["-", DIM]
    gb = div[1].get("divisionGamesBack", div[1].get("gamesBack", "-"))
    if gb in ("-", "", None, "0", "0.0"):
        return ["TIED", AMBER]
    return ["+" + str(gb), INK]

def race_divisions(c, data, teams):
    # Every division leader with its magic number, AL left and NL right,
    # each column in seed order.
    sh = data["sh"]
    chip(c, "AL", LEAGUE["AL"], PAD)
    chip(c, "NL", LEAGUE["NL"], c.width - PAD, right = True)
    early = not data["numbers"]
    c.text("DIVISION LEADERS" if early else "DIVISION MAGIC NUMBERS", c.width // 2, 1, font = "4x5", color = INK, align = "center")
    leaders = []
    for lg in ["AL", "NL"]:
        group = []
        for d in DIVISIONS:
            if d[1] != lg:
                continue
            div = sh["div"].get(d[0], [])
            if len(div) == 0:
                return not_yet(c)
            group.append([d, div[0], div])
        # seed order: the same 1-2-3 as the playoff field page
        n = len(group)
        for a in range(n):
            for b in range(n - 1 - a):
                if rank(group[b][1], "leagueRank") > rank(group[b + 1][1], "leagueRank"):
                    group[b], group[b + 1] = group[b + 1], group[b]
        leaders += group
    names = [nickname(l[1], teams) for l in leaders]
    font = page_font(c, names, NAME_W)
    for i in range(6):
        d, t, div = leaders[i]
        x0 = PAD if i < 3 else 100
        x1 = 92 if i < 3 else c.width - PAD
        y = SMALL_Y[i % 3]
        c.text(d[2], x0, y + 1, font = "4x5", color = DIM)
        tile(c, x0 + 6, y, 7, tid(t), "")
        c.text(str(i % 3 + 1), x0 + 6 + TILE_W // 2, y + 1, font = "4x5", color = ink_on(team_color(tid(t))), align = "center")
        c.text(clip(c, names[i], font, NAME_W), x0 + 6 + TILE_W + NAME_GAP, y, font = font, color = INK)
        st = division_lead(div) if early else division_status(t, div, data["h2h"])
        c.text(st[0], x1, y, font = "5x7", color = st[1], align = "right")
    c.vline(96, SMALL_Y[0], 31, STRUCT)

# ---------- postseason ----------

ROUND_NAMES = {
    "F": "WILD CARD SERIES",
    "D": "DIVISION SERIES",
    "L": "CHAMPIONSHIP SERIES",
    "W": "WORLD SERIES",
}

def is_team(team_id):
    return TEAM_COLORS.get(team_id) != None

def game_done(g, ctx):
    # Final and started before ctx.now.
    if g.get("status", {}).get("abstractGameState") != "Final":
        return False
    return iso_unix(g.get("gameDate", "2000-01-01T00:00:00Z")) <= ctx.now.unix

def game_live(g, ctx):
    return g.get("status", {}).get("abstractGameState") == "Live"

def series_state(s, ctx):
    games = s.get("games", [])
    sid = s.get("series", {}).get("id", "")
    out = {
        "id": sid,
        "round": sid[:1],
        "league": "",
        "high": None,
        "low": None,
        "wins": {},
        "need": 0,
        "winner": None,
        "next": None,
        "live": None,
        "played": 0,
    }
    if len(games) == 0:
        return out
    g0 = games[0]
    desc = g0.get("seriesDescription", "")
    out["league"] = "AL" if desc.startswith("AL") else ("NL" if desc.startswith("NL") else "")
    out["need"] = g0.get("gamesInSeries", len(games)) // 2 + 1
    home = g0.get("teams", {}).get("home", {}).get("team", {})
    away = g0.get("teams", {}).get("away", {}).get("team", {})
    out["high"] = {"id": home.get("id", 0), "name": home.get("name", "")}
    out["low"] = {"id": away.get("id", 0), "name": away.get("name", "")}
    wins = {out["high"]["id"]: 0, out["low"]["id"]: 0}
    for g in games:
        if game_done(g, ctx):
            out["played"] += 1
            for side in ["home", "away"]:
                tm = g.get("teams", {}).get(side, {})
                if tm.get("isWinner"):
                    wid = tm.get("team", {}).get("id", 0)
                    wins[wid] = wins.get(wid, 0) + 1
    out["wins"] = wins
    for side in [out["high"], out["low"]]:
        if wins.get(side["id"], 0) >= out["need"] and out["need"] > 0:
            out["winner"] = side
    if out["winner"] == None:
        for g in games:
            if game_done(g, ctx):
                continue
            if game_live(g, ctx) and iso_unix(g.get("gameDate", "2000-01-01T00:00:00Z")) <= ctx.now.unix:
                out["live"] = g
            out["next"] = g
            break
    return out

def league_series(series, ctx, lg, rnd):
    out = []
    if series == None:
        return out
    for s in series:
        st = series_state(s, ctx)
        if st["round"] == rnd and (lg == "" or st["league"] == lg):
            out.append(st)
    return out

def post_seeds(m):
    # Final regular-season standings; the API's ranks already apply MLB's
    # tiebreakers once every game is played.
    recs = standings(m["season"], m["end"])
    if recs == None:
        return None
    sh = shape(recs)
    out = {}
    for lg in ["AL", "NL"]:
        seeds = seeds_for(sh, lg)
        out[lg] = {tid(seeds[i]): i + 1 for i in range(len(seeds))}
    return out

def order_series(st, seeds, lg):
    # [left, right] = [lower seed, higher seed]
    hi = st["high"]
    lo = st["low"]
    sh_ = seed_in(seeds, lg, hi["id"])
    sl = seed_in(seeds, lg, lo["id"])
    if sh_ > 0 and sl > 0 and lg != "" and sl < sh_:
        return [hi, lo]
    return [lo, hi]

def score_of(g, team_id):
    for side in ["home", "away"]:
        tm = g.get("teams", {}).get(side, {})
        if tm.get("team", {}).get("id") == team_id:
            return tm.get("score", 0)
    return 0

def network_of(g):
    # First national English-language TV listing, trimmed to the lead
    # network: "TBS/HBO MAX" -> "TBS", "FOX / FS1" -> "FOX".
    if g == None:
        return ""
    for b in g.get("broadcasts", []):
        if b.get("type") == "TV" and b.get("language") == "en" and b.get("isNational", False):
            return b.get("name", "").split("/")[0].strip().upper()
    return ""

# Network badges: 7px tall, drawn in each network's colors. A network not
# listed falls back to plain purple text.
PEACOCK_FAN = [
    "..o.p..",
    ".yo.pb.",
    "yyo.pbb",
    "ryo.pbg",
    "rr...gg",
    "r.....g",
]
PEACOCK_LEGEND = {"y": "#FCB711", "o": "#F37021", "r": "#CC004C", "p": "#6460AA", "b": "#0089D0", "g": "#0DB14B"}
PEACOCK_DOTS = ["#FCB711", "#F37021", "#CC004C", "#6460AA", "#0089D0", "#0DB14B"]

BADGES = {
    "TBS": ["#1F5FD6", "white", ""],
    "FOX": ["#F4F7FF", "black", ""],
    "FS1": ["#1B1B1B", "white", "#6E6E6E"],
    "ABC": ["#F4F7FF", "black", ""],
    "TRUTV": ["#1B1B1B", "#9BE34B", "#4A4A4A"],
    "MLBN": ["#0A2B5C", "white", "#D50032"],
}

def network_width(c, net):
    w = c.text_width(net, "4x5")
    if net == "NBC" or net == "NBCSN":
        return 9 + w
    if net == "PEACOCK":
        return w + 3
    if net == "ESPN":
        return w
    return w + 4

def draw_network(c, net, x, y):
    # x is the badge's left edge, y its top
    w = c.text_width(net, "4x5")
    if net == "NBC" or net == "NBCSN":
        c.sprite(PEACOCK_FAN, x, y, legend = PEACOCK_LEGEND)
        c.text(net, x + 9, y + 1, font = "4x5", color = INK)
    elif net == "PEACOCK":
        c.text(net, x, y + 1, font = "4x5", color = INK)
        for k in range(6):
            c.pixel(x + w + 2, y + k, PEACOCK_DOTS[k])
    elif net == "ESPN":
        c.text(net, x, y + 1, font = "4x5", color = "#E8202A")
    elif BADGES.get(net) != None:
        b = BADGES[net]
        c.round_rect(x, y, x + w + 3, y + 6, 1, fill = b[0], outline = b[2] if b[2] != "" else b[0])
        c.text(net, x + 2, y + 1, font = "4x5", color = b[1])
    else:
        c.text(net, x, y + 1, font = "4x5", color = NETWORK)

def status_line(st, ctx, left, right, teams, today):
    # [text, color] for the series' right-hand status column.
    if st["winner"] != None:
        w = st["winner"]
        return [abbr_of(w["id"], w["name"], teams) + " WINS", AMBER]
    g = st["live"]
    if g != None:
        ls = g.get("linescore", {})
        half = "T" if ls.get("isTopInning", True) else "B"
        inn = str(ls.get("currentInning", ""))
        return [half + inn + " " + str(score_of(g, left["id"])) + "-" + str(score_of(g, right["id"])), LIVE]
    g = st["next"]
    if g == None:
        return ["", DIM]
    # Today: time in white. Later: day and time in gray.
    p = et_parts(g.get("gameDate", "2000-01-01T00:00:00Z"))
    tbd = g.get("status", {}).get("startTimeTBD", False) or not is_team(left["id"]) or not is_team(right["id"])
    if p[0] == today:
        return ["TODAY" if tbd else p[2], INK]
    if tbd:
        return [p[3], DIM]
    return [p[1] + " " + p[2], DIM]

def seed_in(seeds, lg, team_id):
    # lg "" (the World Series) looks the team up in both leagues
    if seeds == None:
        return 0
    if lg == "":
        return seeds["AL"].get(team_id, 0) + seeds["NL"].get(team_id, 0)
    return seeds.get(lg, {}).get(team_id, 0)

def wins_color(st, team_id, opp_id):
    # series winner green, current leader blue, trailing gray, tied white
    if st["winner"] != None:
        return GREEN if st["winner"]["id"] == team_id else DIM
    w = st["wins"].get(team_id, 0)
    o = st["wins"].get(opp_id, 0)
    if w > o:
        return LEADING
    if w < o:
        return DIM
    return INK

def series_rows(c, ctx, m, lg, rnd, teams, seeds):
    # Two series on one page, one per row:
    # [tile] LOWER  w-w  [tile] HIGHER      status
    all_series = postseason_series(m["season"])
    if all_series == None:
        return offline(c)
    sts = league_series(all_series, ctx, lg, rnd)
    if len(sts) == 0:
        return message(c, "NOT SET YET", "BRACKET FILLS IN AS SERIES END", INK)
    # bracket order: the half headed for the 1 seed last, like the race pages
    if rnd == "D" and len(sts) == 2:
        if seed_in(seeds, lg, sts[0]["high"]["id"]) == 1:
            sts = [sts[1], sts[0]]
    if rnd == "F" and len(sts) == 2:
        if seed_in(seeds, lg, sts[0]["high"]["id"]) == 4:
            sts = [sts[1], sts[0]]
    pairs = [order_series(st, seeds, lg) for st in sts]
    names = []
    for p in pairs:
        for side in p:
            names.append(nick_of(side["id"], side["name"], teams) if is_team(side["id"]) else "TBD")
    font = page_font(c, names, NAME_W)
    right = c.width - PAD
    for i in range(min(2, len(sts))):
        st = sts[i]
        y = ROW_Y[i]
        p = pairs[i]
        for j in range(2):
            side = p[j]
            x = PAD if j == 0 else 80
            known = is_team(side["id"])
            lost = st["winner"] != None and st["winner"]["id"] != side["id"]
            color = DIM if (lost or not known) else INK
            team_cell(c, x, y, seed_in(seeds, lg, side["id"]), side["id"], names[i * 2 + j], font, color)
        if is_team(p[0]["id"]) and is_team(p[1]["id"]):
            wl = st["wins"].get(p[0]["id"], 0)
            wr = st["wins"].get(p[1]["id"], 0)
            c.text(str(wl), 65, y + 1, font = "5x7", color = wins_color(st, p[0]["id"], p[1]["id"]), align = "center")
            c.text("-", 70, y + 1, font = "5x7", color = DIM, align = "center")
            c.text(str(wr), 75, y + 1, font = "5x7", color = wins_color(st, p[1]["id"], p[0]["id"]), align = "center")
        else:
            c.text("VS", 70, y + 2, font = "4x5", color = DIM, align = "center")
        s = status_line(st, ctx, p[0], p[1], teams, m["today"])
        net = network_of(st["live"] if st["live"] != None else st["next"]) if st["winner"] == None else ""
        if net != "":
            # time over the network badge
            ty = 7 + 13 * i
            c.text(clip(c, s[0], "4x5", right - 138), right, ty, font = "4x5", color = s[1], align = "right")
            draw_network(c, net, right - network_width(c, net) + 1, ty + 5)
        else:
            c.text(clip(c, s[0], "4x5", right - 138), right, y + 2, font = "4x5", color = s[1], align = "right")

def series_board(c, ctx, m, st, lg, teams, seeds):
    # One series, scoreboard style: a team per row with series wins on the
    # right, and the status stacked in the right-hand column.
    p = order_series(st, seeds, lg)
    names = [nick_of(s["id"], s["name"], teams) if is_team(s["id"]) else "TBD" for s in p]
    font = page_font(c, names, 70)
    right = c.width - PAD
    for j in range(2):
        side = p[j]
        y = ROW_Y[j]
        known = is_team(side["id"])
        lost = st["winner"] != None and st["winner"]["id"] != side["id"]
        color = DIM if (lost or not known) else INK
        team_cell(c, PAD, y, seed_in(seeds, lg, side["id"]), side["id"], names[j], font, color, 70)
        if known and is_team(p[1 - j]["id"]):
            w = st["wins"].get(side["id"], 0)
            c.text(str(w), 104, y + 1, font = "5x7", color = wins_color(st, side["id"], p[1 - j]["id"]), align = "right")
    c.vline(112, ROW_Y[0], 29, STRUCT)
    cx = (116 + right) // 2
    if st["winner"] != None:
        w = st["winner"]
        top = "WORLD CHAMPS" if st["round"] == "W" else (lg + " PENNANT")
        c.text(top, cx, ROW_Y[0] + 2, font = "4x5", color = AMBER, align = "center")
        c.text(abbr_of(w["id"], w["name"], teams) + " IN " + str(st["played"]), cx, ROW_Y[1] + 2, font = "4x5", color = INK, align = "center")
        return
    g = st["live"] if st["live"] != None else st["next"]
    if g == None:
        return
    gnum = "GAME " + str(g.get("seriesGameNumber", st["played"] + 1))
    net = network_of(g)
    if net != "":
        gw = c.text_width(gnum, "4x5")
        x0 = cx - (gw + 4 + network_width(c, net)) // 2
        c.text(gnum, x0, ROW_Y[0] + 2, font = "4x5", color = INK)
        draw_network(c, net, x0 + gw + 4, ROW_Y[0] + 1)
    else:
        c.text(gnum, cx, ROW_Y[0] + 2, font = "4x5", color = INK, align = "center")
    if st["live"] != None:
        ls = g.get("linescore", {})
        half = "TOP " if ls.get("isTopInning", True) else "BOT "
        line = half + str(ls.get("currentInning", "")) + "  " + str(score_of(g, p[0]["id"])) + "-" + str(score_of(g, p[1]["id"]))
        c.text(line, cx, ROW_Y[1] + 2, font = "4x5", color = LIVE, align = "center")
        return
    e = et_parts(g.get("gameDate", "2000-01-01T00:00:00Z"))
    tbd = g.get("status", {}).get("startTimeTBD", False) or not is_team(p[0]["id"]) or not is_team(p[1]["id"])
    if e[0] == m["today"]:
        when = "TODAY" if tbd else "TODAY " + e[2]
    elif tbd:
        when = e[1] + " " + e[3]
    else:
        when = e[1] + " " + e[2]
    c.text(when, cx, ROW_Y[1] + 2, font = "4x5", color = DIM, align = "center")

def post_single(c, ctx, m, lg, rnd, teams, seeds):
    all_series = postseason_series(m["season"])
    if all_series == None:
        return offline(c)
    sts = league_series(all_series, ctx, lg, rnd)
    if len(sts) == 0:
        return message(c, "NOT SET YET", "BRACKET FILLS IN AS SERIES END", INK)
    series_board(c, ctx, m, sts[0], lg, teams, seeds)

def post_page(c, ctx, m, lg, rnd):
    teams = team_info()
    seeds = post_seeds(m)
    if rnd == "W":
        x = chip(c, "MLB", AMBER, PAD)
        c.text("WORLD SERIES", x + 3, 1, font = "4x5", color = INK)
        c.text("BEST OF 7", c.width - PAD, 1, font = "4x5", color = DIM, align = "right")
        return post_single(c, ctx, m, "", "W", teams, seeds)
    header(c, lg, ROUND_NAMES[rnd], "BEST OF " + {"F": "3", "D": "5", "L": "7"}[rnd])
    if rnd == "L":
        return post_single(c, ctx, m, lg, rnd, teams, seeds)
    series_rows(c, ctx, m, lg, rnd, teams, seeds)

# ---------- page dispatch ----------

def league_page(c, ctx, lg, slot):
    c.clear()
    m = load_mode(ctx)
    if m == None:
        header(c, lg, "PLAYOFFS")
        return offline(c)
    if m["mode"] == "post":
        return post_page(c, ctx, m, lg, ["F", "D", "L"][slot])
    data = load_race(ctx, m)
    if data == None:
        header(c, lg, "PLAYOFFS")
        return offline(c)
    teams = team_info()
    if slot == 0:
        return race_field(c, data, lg, teams)
    if slot == 1:
        return race_matchups(c, data, lg, teams)
    race_wildcard(c, data, lg, teams)

def al1(c, ctx):
    league_page(c, ctx, "AL", 0)

def al2(c, ctx):
    league_page(c, ctx, "AL", 1)

def al3(c, ctx):
    league_page(c, ctx, "AL", 2)

def nl1(c, ctx):
    league_page(c, ctx, "NL", 0)

def nl2(c, ctx):
    league_page(c, ctx, "NL", 1)

def nl3(c, ctx):
    league_page(c, ctx, "NL", 2)

def final(c, ctx):
    c.clear()
    m = load_mode(ctx)
    if m == None:
        return offline(c)
    if m["mode"] == "post":
        return post_page(c, ctx, m, "", "W")
    data = load_race(ctx, m)
    if data == None:
        return offline(c)
    race_divisions(c, data, team_info())
