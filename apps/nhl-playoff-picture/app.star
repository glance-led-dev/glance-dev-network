# NHL Playoff Picture (192x32)
#
# One conference per app instance (input: East or West) - add the app twice
# for both. Two modes, picked from the NHL's season calendar:
#
#   page      race (regular season)                postseason
#   intro     if season ended today                playoffs / champion
#   div1      Metro / Central first round          that side's first round
#   div2      Atlantic / Pacific first round       that side's first round
#   leaders   No. 1 seed + both division leaders   second round
#   race1     Metro / Central top 3                conference final
#   race2     Atlantic / Pacific top 3             Stanley Cup Final
#   wildcard  both wild cards + first team out     finished series
#   chasers   next three teams chasing a spot      finished series, page 2
#
# Standings come from the NHL, so seeding and the x/y/z/p/e marks follow the
# league's own tiebreakers. Magic numbers are in points: points this team
# earns plus points its rival fails to earn. They show from March 1; before
# that the race pages show streak and last 10, and Leaders the points leads.
#
# Data from the NHL's public API (api-web.nhle.com) - no key required.

TEAM_COLORS = {
    "ANA": "#F47A38", "BOS": "#FFB81C", "BUF": "#003087", "CGY": "#C8102E",
    "CAR": "#CE1126", "CHI": "#CF0A2C", "COL": "#6F263D", "CBJ": "#002654",
    "DAL": "#006847", "DET": "#CE1126", "EDM": "#041E42", "FLA": "#C8102E",
    "LAK": "#111111", "MIN": "#154734", "MTL": "#AF1E2D", "NSH": "#FFB81C",
    "NJD": "#CE1126", "NYI": "#00539B", "NYR": "#0038A8", "OTT": "#C52032",
    "PHI": "#F74902", "PIT": "#FCB514", "SJS": "#006D75", "SEA": "#001628",
    "STL": "#002F87", "TBL": "#002868", "TOR": "#00205B", "UTA": "#6CACE4",
    "VAN": "#00205B", "VGK": "#B4975A", "WSH": "#C8102E", "WPG": "#041E42",
}

# division abbrev -> [conference, name]
DIVISIONS = {
    "A": ["E", "ATLANTIC"],
    "M": ["E", "METROPOLITAN"],
    "C": ["W", "CENTRAL"],
    "P": ["W", "PACIFIC"],
}
CONF_DIVS = {"E": ["M", "A"], "W": ["C", "P"]}   # Metro first
CONF_CHIP = {"E": "EAST", "W": "WEST"}

# bracket series letters: first round by division side, then later rounds
R1_LETTERS = {"A": ["A", "B"], "M": ["C", "D"], "C": ["E", "F"], "P": ["G", "H"]}
R2_LETTERS = {"E": ["J", "I"], "W": ["K", "L"]}   # Metro side first
CF_LETTERS = ["M", "N"]
FINAL_LETTER = "O"

# ---------- palette & grid ----------

INK = "#F4F7FF"
DIM = "#6E7A94"
STRUCT = "#282828"
AMBER = "#E8B04A"
GREEN = "#3FCF6E"
RED = "#E5484D"
LIVE = GREEN
NETWORK = "#B79CFF"
LEADING = "#5FC8FF"
CHIP = {"E": "#C8102E", "W": "#1D4ED8"}

PAD = 6
TILE_W = 9
TILE_H = 9
NAME_GAP = 2
NAME_W = 44
ROW_Y = [10, 21]
SMALL_Y = [8, 16, 24]
NAME_FONTS = ["5x7", "4x7"]

# Original pixel-art puck for the intro card: rubber top face, rim, side.
PUCK = [
    "....rrrrrrrr....",
    "..rrffffffffrr..",
    ".rffffffffffffr.",
    "rffffffffffffffr",
    ".rffffffffffffr.",
    "rsrrffffffffrrsr",
    "rsssrrrrrrrrsssr",
    "rssssssssssssssr",
    ".rssssssssssssr.",
    "..rrrrrrrrrrrr..",
]
PUCK_LEGEND = {"r": "#9AA3B5", "f": "#3A404D", "s": "#1F232B"}
PUCK_W = 16

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

def team_color(abbr):
    return TEAM_COLORS.get(abbr, "#3A3F4B")

def ink_on(fill):
    return "black" if brightness(fill) > 150 else "white"

# ---------- dates (ET game day) ----------

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
    days = days_from_civil(int(iso[0:4]), int(iso[5:7]), int(iso[8:10]))
    return days * 86400 + int(iso[11:13]) * 3600 + int(iso[14:16]) * 60

def et_parts(iso):
    # [game-day date, weekday, "7:08P", "MAY 9"] in ET
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

API = "https://api-web.nhle.com/v1"

def get_json(path, ttl):
    resp = http.get(API + path, ttl_seconds = ttl)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    return resp["json"]

def load_mode(ctx):
    # {"mode": "race"|"post", "season_games": n, "year": playoff year, "today": ...}
    today = today_str(ctx)
    sched = get_json("/schedule/" + today, 300)
    if sched == None:
        return None
    start = sched.get("regularSeasonStartDate", "")
    end = sched.get("regularSeasonEndDate", "")
    # the schedule call covers today and the next six days; finals from the
    # past week come from a second call
    y, mo, d = int(today[0:4]), int(today[5:7]), int(today[8:10])
    prev = get_json("/schedule/" + date_str(*civil_from_days(days_from_civil(y, mo, d) - 6)), 300)
    games = {}
    for src in [prev, sched]:
        if src == None:
            continue
        for day in src.get("gameWeek", []):
            for g in day.get("games", []):
                games[g.get("id")] = g
    out = {"today": today, "start": start, "end": end, "games": games.values()}
    if start != "" and today < start:
        # offseason: last spring's bracket stays up until opening night
        out["mode"] = "post"
        out["year"] = int(start[0:4])
    elif end != "" and today > end:
        out["mode"] = "post"
        out["year"] = int(end[0:4])
    else:
        out["mode"] = "race"
        out["year"] = int(end[0:4]) if end != "" else ctx.now.year
    # 84-game seasons from 2026-27 on
    out["season_games"] = 84 if out["year"] >= 2027 else 82
    return out

def standings(today):
    data = get_json("/standings/" + today, 300)
    if data == None:
        return None
    return data.get("standings", [])

def bracket(year):
    data = get_json("/playoff-bracket/" + str(year), 60)
    if data == None:
        return None
    out = {}
    for s in data.get("series", []):
        out[s.get("seriesLetter", "")] = s
    return out

def scoreboard(today):
    data = get_json("/score/" + today, 60)
    if data == None:
        return {}
    out = {}
    for g in data.get("games", []):
        out[g.get("id")] = g
    return out

# ---------- standings shape ----------

def abbr(t):
    return t.get("teamAbbrev", {}).get("default", "")

def nick(t):
    return t.get("teamCommonName", {}).get("default", abbr(t)).upper()

def seq(t, key):
    v = t.get(key)
    return 999 if v == None or v == 0 else v

def sort_by(items, key):
    out = list(items)
    n = len(out)
    for i in range(n):
        for j in range(n - 1 - i):
            if seq(out[j], key) > seq(out[j + 1], key):
                out[j], out[j + 1] = out[j + 1], out[j]
    return out

def shape(rows):
    div = {}
    conf = {"E": [], "W": []}
    for t in rows:
        d = t.get("divisionAbbrev", "")
        div[d] = div.get(d, []) + [t]
        c = t.get("conferenceAbbrev", "")
        if c in conf:
            conf[c].append(t)
    for d in list(div.keys()):
        div[d] = sort_by(div[d], "divisionSequence")
    for c in list(conf.keys()):
        conf[c] = sort_by(conf[c], "conferenceSequence")
    return {"div": div, "conf": conf}

def wild_pool(sh, c):
    # conference teams outside the division top 3, in wild card order
    top = []
    for d in CONF_DIVS[c]:
        for t in sh["div"].get(d, [])[:3]:
            top.append(abbr(t))
    return sort_by([t for t in sh["conf"][c] if abbr(t) not in top], "wildcardSequence")

# ---------- magic numbers (points) ----------

def remaining(t, m):
    return max(0, m["season_games"] - t.get("gamesPlayed", 0))

def max_pts(t, m):
    return t.get("points", 0) + 2 * remaining(t, m)

def kth_largest(values, k):
    v = sorted(values, reverse = True)
    if k <= 0 or k > len(v):
        return None
    return v[k - 1]

def mark(t):
    return t.get("clinchIndicator", "") or ""

def division_status(t, div, m):
    # [text, color]: division title magic number, or elimination number
    mk = mark(t)
    if mk in ("y", "z", "p"):
        return ["WON", GREEN]
    rivals = [x for x in div if abbr(x) != abbr(t)]
    if len(rivals) == 0:
        return ["-", DIM]
    p = t.get("points", 0)
    if abbr(div[0]) == abbr(t):
        n = max([max_pts(x, m) for x in rivals]) - p + 1
        return [str(max(1, n)), GREEN] if n > 0 else ["WON", GREEN]
    n = max_pts(t, m) - max([x.get("points", 0) for x in rivals]) + 1
    return [str(n), RED] if n > 0 else ["E", RED]

def playoff_status(t, sh, m):
    # The playoff-berth magic number, swapped for the tragic number when
    # the team is closer to elimination. A team is in once fewer than 3
    # division rivals or fewer than 5 conference rivals can catch it.
    mk = mark(t)
    if mk == "e":
        return ["E", RED]
    if mk in ("x", "y", "z", "p"):
        return ["IN", GREEN]
    c = t.get("conferenceAbbrev", "")
    d = t.get("divisionAbbrev", "")
    me = abbr(t)
    div_r = [x for x in sh["div"].get(d, []) if abbr(x) != me]
    oth_r = [x for x in sh["conf"][c] if x.get("divisionAbbrev") != d]
    p = t.get("points", 0)
    top = max_pts(t, m)
    routes = []
    third = kth_largest([max_pts(x, m) for x in div_r], 3)
    if third != None:
        routes.append(third - p + 1)
    fifth = kth_largest([max_pts(x, m) for x in div_r + oth_r], 5)
    if fifth != None:
        routes.append(fifth - p + 1)
    magic = max(1, min(routes)) if len(routes) > 0 else None
    # out when (5, 0), (4, 4) or (3, 5) division / other-division rivals
    # are surely ahead
    tragic = None
    for pat in [[5, 0], [4, 4], [3, 5]]:
        a = kth_largest([x.get("points", 0) for x in div_r], pat[0])
        if a == None:
            continue
        need = top - a + 1
        if pat[1] > 0:
            b = kth_largest([x.get("points", 0) for x in oth_r], pat[1])
            if b == None:
                continue
            need = max(need, top - b + 1)
        tragic = need if tragic == None else min(tragic, need)
    if tragic != None:
        tragic = max(1, tragic)
    if magic != None and (tragic == None or magic <= tragic):
        return [str(magic), GREEN]
    if tragic != None:
        return [str(tragic), RED]
    return ["-", DIM]

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

# Familiar short forms for nicknames too long for a tight column.
SHORT_NAMES = {
    "GOLDEN KNIGHTS": "KNIGHTS", "BLUE JACKETS": "JACKETS",
    "MAPLE LEAFS": "LEAFS", "HURRICANES": "CANES",
}

def fit_name(c, name, maxw):
    if c.text_width(name, NAME_FONTS[-1]) > maxw and SHORT_NAMES.get(name) != None:
        return SHORT_NAMES[name]
    return name

# ---------- chrome ----------

def chip(c, word, bg, x, right = False):
    w = c.text_width(word, "4x5") + 4
    x0 = x - w + 1 if right else x
    c.round_rect(x0, 0, x0 + w - 1, 6, 1, fill = bg)
    c.text(word, x0 + 2, 1, font = "4x5", color = ink_on(bg))
    return x0 + w

def header(c, conf, title, meta = ""):
    x = chip(c, CONF_CHIP[conf], CHIP[conf], PAD)
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
    message(c, "NOT SET YET", "FILLS IN AS THE SEASON GOES", INK)

def tile(c, x, y, h, team, label):
    fill = team_color(team)
    edge = lighten(fill, 45) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + TILE_W - 1, y + h - 1, 1, fill = fill, outline = edge)
    if label != "":
        font = "5x7" if h >= 9 and len(label) == 1 else "4x5"
        ty = y + (h - 7) // 2 if font == "5x7" else y + (h - 5) // 2
        c.text(label, x + TILE_W // 2, ty, font = font, color = ink_on(fill), align = "center")

def team_cell(c, x, y, label, team, text, font, color = INK, maxw = NAME_W):
    tile(c, x, y, TILE_H, team, label)
    c.text(clip(c, text, font, maxw), x + TILE_W + NAME_GAP, y + 1, font = font, color = color)

# ---------- network badges ----------

BADGES = {
    "TNT": ["#1B1B1B", "white", "#6E6E6E"],
    "TBS": ["#1F5FD6", "white", ""],
    "TRUTV": ["#1B1B1B", "#9BE34B", "#4A4A4A"],
    "ABC": ["#F4F7FF", "black", ""],
    "NHLN": ["#0A2B5C", "white", "#9AA3B5"],
}

def network_of(g):
    # first US national TV listing, shortened to the lead network
    if g == None:
        return ""
    for b in g.get("tvBroadcasts", []):
        if b.get("market") == "N" and b.get("countryCode") == "US":
            name = b.get("network", "").upper()
            if name.startswith("ESPN"):
                return "ESPN"
            return name.split(" ")[0]
    return ""

def network_width(c, net):
    w = c.text_width(net, "4x5")
    return w if net == "ESPN" else w + 4

def draw_network(c, net, x, y):
    w = c.text_width(net, "4x5")
    if net == "ESPN":
        c.text(net, x, y + 1, font = "4x5", color = "#E8202A")
    elif BADGES.get(net) != None:
        b = BADGES[net]
        c.round_rect(x, y, x + w + 3, y + 6, 1, fill = b[0], outline = b[2] if b[2] != "" else b[0])
        c.text(net, x + 2, y + 1, font = "4x5", color = b[1])
    else:
        c.text(net, x, y + 1, font = "4x5", color = NETWORK)

# ---------- intro ----------

def intro_card(c, kicker, hero, sub, sub_color):
    hw = c.text_width(hero, "10x16")
    lockup = PUCK_W + 6 + hw
    x0 = max(PAD, (c.width - lockup) // 2)
    hx = x0 + PUCK_W + 6
    c.sprite(PUCK, x0, 10, legend = PUCK_LEGEND)
    c.text(kicker, hx, 1, font = "4x5", color = DIM)
    c.text(hero, hx, 8, font = "10x16", color = INK)
    c.text(sub, c.width // 2, 26, font = "4x5", color = sub_color, align = "center")

def season_label(m):
    return "NHL " + str(m["year"] - 1) + "-" + str(m["year"] % 100)

# The fonts have no "@", so the host marker is drawn: 5x5.
AT_SIGN = [
    ".ggg.",
    "g.g.g",
    "g.ggg",
    "g....",
    ".ggg.",
]

def draw_at(c, cx, y, color):
    c.sprite(AT_SIGN, cx - 2, y, legend = {"g": color})

# ---------- race pages ----------

def race_division(c, sh, conf, div):
    # The division's two first-round series if the season ended today,
    # lower seed @ higher seed: a wild card @ 1 (the better division winner
    # gets the second wild card), 3 @ 2.
    header(c, conf, "FIRST ROUND")
    rows = sh["div"].get(div, [])
    pool = wild_pool(sh, conf)
    if len(rows) < 3 or len(pool) < 2:
        return not_yet(c)
    leaders = [sh["div"][d][0] for d in CONF_DIVS[conf] if len(sh["div"].get(d, [])) > 0]
    leaders = sort_by(leaders, "conferenceSequence")
    wc = pool[1] if abbr(leaders[0]) == abbr(rows[0]) else pool[0]
    pairs = [[wc, "W", rows[0], "1"], [rows[2], "3", rows[1], "2"]]
    wide = 72
    names = []
    for p in pairs:
        names.append(fit_name(c, nick(p[0]), wide))
        names.append(fit_name(c, nick(p[2]), wide))
    font = page_font(c, names, wide)
    for i in range(2):
        y = ROW_Y[i]
        p = pairs[i]
        team_cell(c, PAD, y, p[1], abbr(p[0]), names[i * 2], font, INK, wide)
        draw_at(c, 98, y + 2, DIM)
        team_cell(c, 104, y, p[3], abbr(p[2]), names[i * 2 + 1], font, INK, wide)

def chase_list(sh, conf, m):
    # wild card pool teams outside the two spots that are still alive
    pool = wild_pool(sh, conf)
    out = []
    for k in range(2, len(pool)):
        st = playoff_status(pool[k], sh, m)
        if st[0] != "E":
            out.append([k, pool[k], st])
    return out

def wc_page(c, sh, conf, m, title, rows):
    header(c, conf, title)
    stat_header(c, m)
    names = [fit_name(c, nick(r[1]), 66) for r in rows]
    font = page_font(c, names, 66)
    for i in range(len(rows)):
        k, t, st = rows[i]
        stat_row(c, sh, m, SMALL_Y[i], str(k + 1) if k < 2 else "", t, names[i], font, st)

def race_wildcard(c, sh, conf, m):
    # Both wild card holders, always, then the first team out.
    pool = wild_pool(sh, conf)
    if len(pool) < 2:
        header(c, conf, "WILD CARD")
        return not_yet(c)
    rows = [[k, pool[k], playoff_status(pool[k], sh, m)] for k in range(2)] + chase_list(sh, conf, m)[:1]
    wc_page(c, sh, conf, m, "WILD CARD", rows)

def race_chasers(c, sh, conf, m):
    # The next three teams still chasing a wild card. Unused rows stay blank.
    wc_page(c, sh, conf, m, "CHASERS", chase_list(sh, conf, m)[1:4])

# ---------- postseason ----------

def series_state(s, m, ctx):
    # Wins as of ctx.now: from the week's schedule when a game of this
    # series has finished, else the bracket's own count.
    top = s.get("topSeedTeam") or {}
    bot = s.get("bottomSeedTeam") or {}
    ta = top.get("abbrev", "")
    ba = bot.get("abbrev", "")
    letter = s.get("seriesLetter", "")
    out = {
        "top": ta, "bottom": ba,
        "top_label": s.get("topSeedRankAbbrev", "") or "",
        "bottom_label": s.get("bottomSeedRankAbbrev", "") or "",
        "names": {
            ta: (top.get("commonName") or {}).get("default", ta).upper(),
            ba: (bot.get("commonName") or {}).get("default", ba).upper(),
        },
        "wins": {ta: s.get("topSeedWins", 0), ba: s.get("bottomSeedWins", 0)},
        "need": 4, "winner": "", "next": None, "live": None,
    }
    last_done = None
    seen = False
    games = sorted([g for g in m["games"] if (g.get("seriesStatus") or {}).get("seriesLetter") == letter],
                   key = lambda g: g.get("startTimeUTC", ""))
    for g in games:
        ss = g.get("seriesStatus") or {}
        seen = True
        started = iso_unix(g.get("startTimeUTC", "2000-01-01T00:00:00Z")) <= ctx.now.unix
        state = g.get("gameState", "FUT")
        if started and state in ("FINAL", "OFF"):
            last_done = ss
        elif started and state in ("LIVE", "CRIT"):
            out["live"] = g
        elif out["next"] == None and not started:
            out["next"] = g
    if seen and last_done == None:
        # games scheduled but none finished yet
        out["wins"] = {ta: 0, ba: 0}
    if last_done != None:
        out["wins"] = {ta: last_done.get("topSeedWins", 0), ba: last_done.get("bottomSeedWins", 0)}
        out["need"] = last_done.get("neededToWin", 4)
    for t in [ta, ba]:
        if t != "" and out["wins"].get(t, 0) >= out["need"]:
            out["winner"] = t
    return out

def wins_color(st, team, other):
    # series winner green, leader blue, trailing gray, tied white
    if st["winner"] != "":
        return GREEN if st["winner"] == team else DIM
    w = st["wins"].get(team, 0)
    o = st["wins"].get(other, 0)
    if w > o:
        return LEADING
    if w < o:
        return DIM
    return INK

def short_label(lab):
    # D1 -> 1, WC1 -> W; the tile holds one character
    if lab.startswith("WC"):
        return "W"
    if len(lab) == 2:
        return lab[1]
    return ""

def status_line(st, m, scores, with_clock = False):
    if st["winner"] != "":
        return [st["winner"] + " WINS", AMBER]
    g = st["live"]
    if g != None:
        live = scores.get(g.get("id")) or g
        pd = live.get("periodDescriptor") or {}
        clock = live.get("clock") or {}
        n = pd.get("number", 1)
        kind = pd.get("periodType", "REG")
        per = "OT" if kind == "OT" else ("SO" if kind == "SO" else "P" + str(n))
        if clock.get("inIntermission", False):
            return ["END " + per, LIVE]
        # score in the row's own order: lower seed first
        home = live.get("homeTeam", {})
        away = live.get("awayTeam", {})
        ts = home.get("score", 0) if home.get("abbrev") == st["top"] else away.get("score", 0)
        bs = away.get("score", 0) if home.get("abbrev") == st["top"] else home.get("score", 0)
        sc = str(bs) + "-" + str(ts)
        if with_clock:
            return [per + " " + clock.get("timeRemaining", "") + "  " + sc, LIVE]
        return [per + " " + sc, LIVE]
    g = st["next"]
    if g == None:
        return ["", DIM]
    p = et_parts(g.get("startTimeUTC", "2000-01-01T00:00:00Z"))
    if p[0] == m["today"]:
        return [p[2], INK]
    return [p[1] + " " + p[2], DIM]

def series_rows(c, ctx, m, sts):
    # [tile] LOWER  w-w  [tile] HIGHER      status / network
    names = []
    for st in sts:
        names.append(fit_name(c, st["names"].get(st["bottom"], "TBD"), NAME_W) if st["bottom"] != "" else "TBD")
        names.append(fit_name(c, st["names"].get(st["top"], "TBD"), NAME_W) if st["top"] != "" else "TBD")
    font = page_font(c, names, NAME_W)
    right = c.width - PAD
    scores = scoreboard(m["today"])
    for i in range(min(2, len(sts))):
        st = sts[i]
        y = ROW_Y[i]
        # lower seed on the left, like the regular-season pages
        sides = [[st["bottom"], st["bottom_label"]], [st["top"], st["top_label"]]]
        for j in range(2):
            team, lab = sides[j]
            x = PAD if j == 0 else 80
            lost = st["winner"] != "" and st["winner"] != team
            color = DIM if (lost or team == "") else INK
            team_cell(c, x, y, short_label(lab), team, names[i * 2 + j], font, color)
        if st["top"] != "" and st["bottom"] != "":
            a, b = st["bottom"], st["top"]
            c.text(str(st["wins"].get(a, 0)), 65, y + 1, font = "5x7", color = wins_color(st, a, b), align = "center")
            c.text("-", 70, y + 1, font = "5x7", color = DIM, align = "center")
            c.text(str(st["wins"].get(b, 0)), 75, y + 1, font = "5x7", color = wins_color(st, b, a), align = "center")
        else:
            c.text("VS", 70, y + 2, font = "4x5", color = DIM, align = "center")
        s = status_line(st, m, scores)
        game = st["live"] if st["live"] != None else st["next"]
        net = network_of(game) if st["winner"] == "" else ""
        if net != "":
            ty = 7 + 13 * i
            c.text(clip(c, s[0], "4x5", right - 138), right, ty, font = "4x5", color = s[1], align = "right")
            draw_network(c, net, right - network_width(c, net) + 1, ty + 5)
        else:
            c.text(clip(c, s[0], "4x5", right - 138), right, y + 2, font = "4x5", color = s[1], align = "right")

def series_board(c, ctx, m, st, title_done):
    # One series, scoreboard style, status stacked on the right.
    names = [st["names"].get(st["top"], "TBD"), st["names"].get(st["bottom"], "TBD")]
    font = page_font(c, names, 70)
    right = c.width - PAD
    sides = [[st["top"], st["top_label"]], [st["bottom"], st["bottom_label"]]]
    for j in range(2):
        team, lab = sides[j]
        y = ROW_Y[j]
        lost = st["winner"] != "" and st["winner"] != team
        color = DIM if (lost or team == "") else INK
        team_cell(c, PAD, y, short_label(lab), team, names[j] if team != "" else "TBD", font, color, 70)
        if st["top"] != "" and st["bottom"] != "":
            other = sides[1 - j][0]
            c.text(str(st["wins"].get(team, 0)), 104, y + 1, font = "5x7", color = wins_color(st, team, other), align = "right")
    c.vline(112, ROW_Y[0], 29, STRUCT)
    cx = (116 + right) // 2
    if st["winner"] != "":
        c.text(title_done, cx, ROW_Y[0] + 2, font = "4x5", color = AMBER, align = "center")
        played = st["wins"].get(st["top"], 0) + st["wins"].get(st["bottom"], 0)
        c.text(st["winner"] + " IN " + str(played), cx, ROW_Y[1] + 2, font = "4x5", color = INK, align = "center")
        return
    g = st["live"] if st["live"] != None else st["next"]
    if g == None:
        return
    gnum = "GAME " + str(st["wins"].get(st["top"], 0) + st["wins"].get(st["bottom"], 0) + 1)
    net = network_of(g)
    if net != "":
        gw = c.text_width(gnum, "4x5")
        x0 = cx - (gw + 4 + network_width(c, net)) // 2
        c.text(gnum, x0, ROW_Y[0] + 2, font = "4x5", color = INK)
        draw_network(c, net, x0 + gw + 4, ROW_Y[0] + 1)
    else:
        c.text(gnum, cx, ROW_Y[0] + 2, font = "4x5", color = INK, align = "center")
    s = status_line(st, m, scoreboard(m["today"]), True)
    when = s[0]
    if st["live"] == None:
        e = et_parts(g.get("startTimeUTC", "2000-01-01T00:00:00Z"))
        when = ("TODAY " + e[2]) if e[0] == m["today"] else (e[1] + " " + e[2])
    c.text(when, cx, ROW_Y[1] + 2, font = "4x5", color = s[1] if st["live"] != None else DIM, align = "center")

# ---------- conference pages ----------

def conference(ctx):
    v = str(ctx.inputs.get("conference", "East")).upper()
    return "W" if v.startswith("W") else "E"

def conf_name(conf):
    return "EASTERN" if conf == "E" else "WESTERN"

COL_GP = 104      # right edges of the stat columns
COL_PTS = 128
COL_DIV = 154

def numbers_on(m):
    # magic and elimination numbers start on March 1; before that they sit
    # far too high to mean anything
    return m["today"] >= str(m["year"]) + "-03-01"

def last10(t):
    return str(t.get("l10Wins", 0)) + "-" + str(t.get("l10Losses", 0)) + "-" + str(t.get("l10OtLosses", 0))

def streak(t):
    code = t.get("streakCode", "") or ""
    return code + str(t.get("streakCount", 0)) if code != "" else "-"

def signed(n):
    return "+" + str(n) if n > 0 else str(n)

def stat_header(c, m):
    right = c.width - PAD
    c.text("GP", COL_GP, 1, font = "4x5", color = DIM, align = "right")
    c.text("PTS", COL_PTS, 1, font = "4x5", color = DIM, align = "right")
    if numbers_on(m):
        c.text("DIV", COL_DIV, 1, font = "4x5", color = DIM, align = "right")
        c.text("M/E#", right, 1, font = "4x5", color = DIM, align = "right")
    else:
        c.text("STRK", COL_DIV, 1, font = "4x5", color = DIM, align = "right")
        c.text("L10", right, 1, font = "4x5", color = DIM, align = "right")

def stat_row(c, sh, m, y, label, t, name, font, st):
    # tile (with its place), name, GP, PTS, then from March 1 the division
    # E# and playoff M/E#; before that the streak and last 10.
    right = c.width - PAD
    tile(c, PAD, y, 7, abbr(t), "")
    if label != "":
        c.text(label, PAD + TILE_W // 2, y + 1, font = "4x5", color = ink_on(team_color(abbr(t))), align = "center")
    c.text(clip(c, name, font, 66), PAD + TILE_W + NAME_GAP, y, font = font, color = INK)
    c.text(str(t.get("gamesPlayed", 0)), COL_GP, y, font = "5x7", color = DIM, align = "right")
    c.text(str(t.get("points", 0)), COL_PTS, y, font = "5x7", color = INK, align = "right")
    if not numbers_on(m):
        sk = streak(t)
        c.text(sk, COL_DIV, y + 1, font = "4x5", color = GREEN if sk.startswith("W") else (RED if sk.startswith("L") else DIM), align = "right")
        c.text(last10(t), right, y + 1, font = "4x5", color = INK, align = "right")
        return
    div = sh["div"].get(t.get("divisionAbbrev", ""), [])
    if len(div) > 0:
        d = division_status(t, div, m)
        if abbr(div[0]) != abbr(t):
            # division-title elimination number, E once out
            c.text(d[0], COL_DIV, y, font = "5x7", color = d[1], align = "right")
        elif d[0] == "WON":
            # the leader's magic number lives on the Leaders page; here
            # only a clinched title shows
            c.text("WON", COL_DIV, y, font = "5x7", color = GREEN, align = "right")
    c.text(st[0], right, y, font = "5x7", color = st[1], align = "right")

def race_top3(c, sh, conf, div, m):
    # The division's current top 3 with their playoff-spot magic/tragic
    # numbers, plus the division-title number: E# below 1st, WON once the
    # leader clinches.
    header(c, conf, "METRO" if div == "M" else DIVISIONS[div][1])
    stat_header(c, m)
    div_rows = sh["div"].get(div, [])
    if len(div_rows) < 4:
        return not_yet(c)
    rows = [[k, div_rows[k], playoff_status(div_rows[k], sh, m)] for k in range(3)]
    names = [fit_name(c, nick(r[1]), 66) for r in rows]
    font = page_font(c, names, 66)
    for i in range(3):
        k, t, st = rows[i]
        stat_row(c, sh, m, SMALL_Y[i], str(k + 1), t, names[i], font, st)

def conference_first_status(t, sh, m):
    # [text, color] for finishing first in the conference
    if mark(t) in ("z", "p"):
        return ["WON", GREEN]
    rivals = [x for x in sh["conf"][t.get("conferenceAbbrev", "")] if abbr(x) != abbr(t)]
    n = max([max_pts(x, m) for x in rivals]) - t.get("points", 0) + 1
    return [str(n), GREEN] if n > 0 else ["WON", GREEN]

def lead_over(t, others):
    # points ahead of the next-best team in `others`
    best = 0
    for x in others:
        if abbr(x) != abbr(t):
            best = max(best, x.get("points", 0))
    return t.get("points", 0) - best

def race_leaders(c, sh, conf, m):
    # Line 1: the conference's No. 1 seed race. Lines 2-3: both division
    # leaders' title magic numbers, the one closer to clinching first.
    # Before March 1, each line shows its points lead instead.
    early = not numbers_on(m)
    header(c, conf, "LEADERS", "LEAD" if early else "MAGIC #")
    if len(sh["conf"][conf]) == 0:
        return not_yet(c)
    top = sh["conf"][conf][0]
    divs = []
    for d in CONF_DIVS[conf]:
        rows = sh["div"].get(d, [])
        if len(rows) == 0:
            return not_yet(c)
        divs.append([d, rows[0], DIVISIONS[d][1] if d != "M" else "METRO", division_status(rows[0], rows, m)])

    def closeness(line):
        txt = line[3][0]
        if txt == "WON":
            return 0
        if txt.isdigit():
            return int(txt)
        return 9999
    if not early:
        divs = sorted(divs, key = closeness)
    lines = [["#1", top, "NO. 1 SEED", conference_first_status(top, sh, m)]] + divs
    names = [fit_name(c, nick(l[1]), 64) for l in lines]
    font = page_font(c, names, 64)
    right = c.width - PAD
    for i in range(len(lines)):
        lab, t, what, st = lines[i]
        y = SMALL_Y[i]
        c.text(lab, PAD, y + 1, font = "4x5", color = DIM)
        tile(c, PAD + 14, y, 7, abbr(t), "")
        c.text(clip(c, names[i], font, 64), PAD + 14 + TILE_W + NAME_GAP, y, font = font, color = INK)
        c.text(what, 156, y + 1, font = "4x5", color = DIM, align = "right")
        if early:
            pool = sh["conf"][conf] if lab == "#1" else sh["div"].get(t.get("divisionAbbrev", ""), [])
            ld = lead_over(t, pool)
            c.text(signed(ld) if ld != 0 else "TIED", right, y, font = "5x7", color = INK if ld > 0 else AMBER, align = "right")
        else:
            c.text(st[0], right, y, font = "5x7", color = st[1], align = "right")

def series_results(c, ctx, m, conf, br, part):
    # The conference's finished series, latest round first, three a page.
    header(c, conf, "SERIES RESULTS", str(part + 1) + " OF 2")
    letters = [CF_LETTERS[0 if conf == "E" else 1]] + R2_LETTERS[conf]
    for d in CONF_DIVS[conf]:
        letters = letters + R1_LETTERS[d]
    done = []
    for x in letters:
        if br.get(x) == None:
            continue
        st = series_state(br[x], m, ctx)
        if st["winner"] != "":
            done.append(st)
    done = done[part * 3:part * 3 + 3]
    if len(done) == 0:
        return message(c, "NO SERIES FINISHED", "" if part == 0 else "MORE AS SERIES END", INK)
    right = c.width - PAD
    names = []
    for st in done[:3]:
        loser = st["bottom"] if st["winner"] == st["top"] else st["top"]
        names.append(fit_name(c, st["names"][st["winner"]], 50))
        names.append(fit_name(c, st["names"][loser], 50))
    font = page_font(c, names, 50)
    for i in range(min(3, len(done))):
        st = done[i]
        y = SMALL_Y[i]
        w = st["winner"]
        lo = st["bottom"] if w == st["top"] else st["top"]
        tile(c, PAD, y, 7, w, "")
        c.text(clip(c, names[i * 2], font, 50), PAD + 11, y, font = font, color = INK)
        c.text("OVER", 90, y + 1, font = "4x5", color = DIM, align = "center")
        tile(c, 102, y, 7, lo, "")
        c.text(clip(c, names[i * 2 + 1], font, 50), 113, y, font = font, color = DIM)
        c.text(str(st["wins"].get(w, 0)) + "-" + str(st["wins"].get(lo, 0)), right, y, font = "5x7", color = GREEN, align = "right")

def post_rows(c, ctx, m, conf, title, meta, letters, br):
    header(c, conf, title, meta)
    sts = [series_state(br[x], m, ctx) for x in letters if br.get(x) != None]
    sts = [s for s in sts if s["top"] != "" or s["bottom"] != ""]
    if len(sts) == 0:
        return message(c, "NOT SET YET", "BRACKET FILLS IN AS SERIES END", INK)
    series_rows(c, ctx, m, sts)

def post_board(c, ctx, m, chip_word, chip_color, title, letter, done_title, br):
    x = chip(c, chip_word, chip_color, PAD)
    c.text(title, x + 3, 1, font = "4x5", color = INK)
    c.text("BEST OF 7", c.width - PAD, 1, font = "4x5", color = DIM, align = "right")
    s = br.get(letter)
    if s == None or ((s.get("topSeedTeam") or {}).get("abbrev", "") == "" and (s.get("bottomSeedTeam") or {}).get("abbrev", "") == ""):
        return message(c, "NOT SET YET", "BRACKET FILLS IN AS SERIES END", INK)
    series_board(c, ctx, m, series_state(s, m, ctx), done_title)

# ---------- page dispatch ----------

def intro(c, ctx):
    c.clear()
    conf = conference(ctx)
    m = load_mode(ctx)
    if m == None:
        return intro_card(c, "NHL", "PLAYOFFS", conf_name(conf) + " CONFERENCE", DIM)
    if m["mode"] == "race":
        return intro_card(c, season_label(m), "PLAYOFF PICTURE", CONF_CHIP[conf] + " - IF THE SEASON ENDED TODAY", DIM)
    br = bracket(m["year"])
    if br != None and br.get(FINAL_LETTER) != None:
        st = series_state(br[FINAL_LETTER], m, ctx)
        if st["winner"] != "":
            return intro_card(c, "STANLEY CUP " + str(m["year"]), "CHAMPIONS",
                              st["names"][st["winner"]] + " WIN THE STANLEY CUP", AMBER)
    intro_card(c, "STANLEY CUP " + str(m["year"]), "PLAYOFFS", conf_name(conf) + " CONFERENCE", DIM)

def page(c, ctx, slot):
    c.clear()
    conf = conference(ctx)
    m = load_mode(ctx)
    if m == None:
        header(c, conf, "PLAYOFFS")
        return offline(c)
    divs = CONF_DIVS[conf]
    if m["mode"] == "post":
        br = bracket(m["year"])
        if br == None:
            header(c, conf, "PLAYOFFS")
            return offline(c)
        if slot < 2:
            return post_rows(c, ctx, m, conf, "FIRST ROUND", "BEST OF 7", R1_LETTERS[divs[slot]], br)
        if slot == 2:
            return post_rows(c, ctx, m, conf, "SECOND ROUND", "BEST OF 7", R2_LETTERS[conf], br)
        if slot == 3:
            return post_board(c, ctx, m, CONF_CHIP[conf], CHIP[conf], "CONFERENCE FINAL",
                              CF_LETTERS[0 if conf == "E" else 1], CONF_CHIP[conf] + " CHAMPS", br)
        if slot == 4:
            return post_board(c, ctx, m, "NHL", AMBER, "STANLEY CUP FINAL", FINAL_LETTER, "CUP CHAMPS", br)
        return series_results(c, ctx, m, conf, br, slot - 5)
    rows = standings(m["today"])
    if rows == None:
        header(c, conf, "PLAYOFFS")
        return offline(c)
    sh = shape(rows)
    if slot < 2:
        return race_division(c, sh, conf, divs[slot])
    if slot == 2:
        return race_leaders(c, sh, conf, m)
    if slot < 5:
        return race_top3(c, sh, conf, divs[slot - 3], m)
    if slot == 5:
        return race_wildcard(c, sh, conf, m)
    race_chasers(c, sh, conf, m)

def div1(c, ctx):
    page(c, ctx, 0)

def div2(c, ctx):
    page(c, ctx, 1)

def leaders(c, ctx):
    page(c, ctx, 2)

def race1(c, ctx):
    page(c, ctx, 3)

def race2(c, ctx):
    page(c, ctx, 4)

def wildcard(c, ctx):
    page(c, ctx, 5)

def chasers(c, ctx):
    page(c, ctx, 6)
