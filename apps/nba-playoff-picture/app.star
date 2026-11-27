# NBA Playoff Picture (192x32)
#
# One conference per app instance (input: East or West) - add the app twice
# for both. Three modes from the league calendar:
#
#   page      regular season               playoffs (through the summer)
#   intro     if the season ended today    playoffs / champions
#   round1a   first round: 8 @ 1, 7 @ 2    first round: 8 v 1, 7 v 2
#   round1b   first round: 6 @ 3, 5 @ 4    first round: 6 v 3, 5 v 4
#   leaders   1 seed, top-6, play-in lines second round
#   top1      seeds 1-3                    conference finals
#   top2      seeds 4-6                    NBA Finals
#   playin    play-in matchups             play-in games / survivors
#   chasers   the next three teams         latest results
#
# Play-in week keeps the regular-season pages, with the real play-in games
# on the play-in page.
# The first week of a new season, the intro still shows last season's
# champion.
#
# Seeds come from ESPN's standings, which apply the NBA tiebreakers. Magic
# numbers are in wins: wins this team gets plus losses its rival takes. They
# show from March 1; before that the race pages show streak and last 10, and
# The Lines shows the games leads.
#
# Playoff series come from the playoff schedules of the conference's top-4
# seeds (every first-round series has one) plus one first-round upset
# winner, with today's scoreboard for live scores. A series between two
# teams outside those schedules shows what today's scoreboard knows, and
# who advanced once a later round starts.
#
# Data from ESPN's public APIs - no key required.

TEAM_COLORS = {
    "ATL": "#C8102E", "BOS": "#007A33", "BKN": "#111111", "CHA": "#1D8CAB",
    "CHI": "#CE1141", "CLE": "#860038", "DAL": "#00538C", "DEN": "#0E2240",
    "DET": "#C8102E", "GS": "#1D428A", "HOU": "#CE1141", "IND": "#002D62",
    "LAC": "#C8102E", "LAL": "#552583", "MEM": "#5D76A9", "MIA": "#98002E",
    "MIL": "#00471B", "MIN": "#0C2340", "NO": "#0C2340", "NY": "#006BB6",
    "OKC": "#007AC1", "ORL": "#0077C0", "PHI": "#006BB6", "PHX": "#E56020",
    "POR": "#E03A3E", "SAC": "#5A2D81", "SA": "#8A8D8F", "TOR": "#CE1141",
    "UTAH": "#4E008E", "WSH": "#002B5C",
}

CONF_CHIP = {"E": "EAST", "W": "WEST"}
CONF_KEY = {"E": "East", "W": "West"}

# ---------- palette & grid ----------

INK = "#F4F7FF"
DIM = "#6E7A94"
STRUCT = "#282828"
AMBER = "#E8B04A"
GREEN = "#3FCF6E"
RED = "#E5484D"
CHIP = {"E": "#C8102E", "W": "#1D4ED8"}

PAD = 6
TILE_W = 9
TILE_H = 9
NAME_GAP = 2
ROW_Y = [10, 21]
SMALL_Y = [8, 16, 24]
NAME_FONTS = ["5x7", "4x7"]
SEASON_GAMES = 82

# Original pixel-art basketball for the intro card.
BALL = [
    "....oooooo....",
    "..oooosoooo...",
    ".oooooosoooo..",
    ".soooooosooos.",
    "osssooooosss.o",
    "ooooosssssoooo",
    "oooooooossssoo",
    "ooooooososoooo",
    "osooooosoossoo",
    ".osoooosoooos.",
    ".oosooosooooo.",
    "..oosoosoooo..",
    "....oooooo....",
]
BALL_LEGEND = {"o": "#E8742A", "s": "#2A1A10"}
BALL_W = 14

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

# ---------- dates (ET) ----------

ET_OFFSET_SECONDS = 5 * 3600

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

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def today_str(ctx):
    y, m, d = civil_from_days((ctx.now.unix - ET_OFFSET_SECONDS) // 86400)
    return str(y) + "-" + pad2(m) + "-" + pad2(d)

def season_end_year(today):
    # the season that starts in October ends the next spring
    y = int(today[0:4])
    return y + 1 if int(today[5:7]) >= 8 else y

def numbers_on(today):
    # magic and elimination numbers start on March 1; before that they sit
    # far too high to mean anything
    return today[5:7] in ("03", "04", "05", "06", "07")

# ---------- network (keyless) ----------

STANDINGS = "https://site.api.espn.com/apis/v2/sports/basketball/nba/standings?level=2&season="
SEASON = "https://sports.core.api.espn.com/v2/sports/basketball/leagues/nba/seasons/"
SCOREBOARD = "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard?dates="

def get_json(url, ttl):
    resp = http.get(url, ttl_seconds = ttl)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    return resp["json"]

def load_mode(ctx):
    # {"mode": "race" | "playin" | "post", "year": season end year, "today"}
    # from the league calendar: the regular season, the play-in week, then
    # the playoffs, which stay up through the summer until the next opener
    today = today_str(ctx)
    y = season_end_year(today)
    out = {"mode": "race", "year": y, "today": today}
    data = get_json(SEASON + str(y), 86400)
    if data == None:
        return out
    starts = {}
    for t in (data.get("types") or {}).get("items", []):
        starts[t.get("type", 0)] = (t.get("startDate", "") or "")[0:10]
    reg = starts.get(2, "")
    playin = starts.get(5, "")
    post = starts.get(3, "")
    out["playin_start"] = playin
    out["reg_start"] = reg
    if reg != "" and today < reg:
        out["mode"] = "post"
        out["year"] = y - 1
    elif post != "" and today >= post:
        out["mode"] = "post"
    elif playin != "" and today >= playin:
        out["mode"] = "playin"
    return out

def load_all(year, ttl):
    # {"E": rows, "W": rows}, each conference's teams in seed order
    data = get_json(STANDINGS + str(year), ttl)
    if data == None:
        return None
    out = {}
    for ch in data.get("children", []):
        key = "E" if ch.get("abbreviation", "") == "East" else ("W" if ch.get("abbreviation", "") == "West" else "")
        if key == "":
            continue
        rows = []
        for e in (ch.get("standings") or {}).get("entries", []):
            t = e.get("team") or {}
            s = {}
            for st in e.get("stats", []):
                s[st.get("name", "")] = st
            rows.append({
                "id": str(t.get("id", "")),
                "abbr": t.get("abbreviation", ""),
                "name": t.get("name", t.get("abbreviation", "")).upper(),
                "seed": int((s.get("playoffSeed") or {}).get("value", 99) or 99),
                "w": int((s.get("wins") or {}).get("value", 0) or 0),
                "l": int((s.get("losses") or {}).get("value", 0) or 0),
                "gb": (s.get("gamesBehind") or {}).get("displayValue", "-"),
                "strk": (s.get("streak") or {}).get("displayValue", "-"),
                "l10": (s.get("Last Ten Games") or {}).get("displayValue", ""),
                "mark": (s.get("clincher") or {}).get("displayValue", ""),
            })
        out[key] = sorted(rows, key = lambda r: r["seed"])
    if out.get("E") == None or out.get("W") == None:
        return None
    return out

# ---------- playoff games ----------

ROUND_OF = {"RD16": 1, "QTR": 2, "SEMI": 3, "FINAL": 4}
NETWORKS = {"PRIME VIDEO": "PRIME", "NBA TV": "NBATV"}

def iso_unix(iso):
    # "2026-05-01T23:30Z" -> unix seconds
    y, m, d = int(iso[0:4]), int(iso[5:7]), int(iso[8:10])
    days = days_from_civil(y, m, d)
    return days * 86400 + int(iso[11:13]) * 3600 + int(iso[14:16]) * 60

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def network_of(comp):
    # first national TV listing; scoreboards and team schedules shape it
    # differently
    for b in comp.get("broadcasts", []):
        market = b.get("market", "")
        if type(market) == "dict":
            if str(market.get("type", "")).lower() != "national" or (b.get("type") or {}).get("shortName", "TV") != "TV":
                continue
            n = str((b.get("media") or {}).get("shortName", "")).upper()
        elif market == "national" and len(b.get("names", [])) > 0:
            n = str(b["names"][0]).upper()
        else:
            continue
        if n != "":
            return NETWORKS.get(n, "ESPN" if n.startswith("ESPN") else n.split(" ")[0])
    return ""

def score_of(c):
    s = c.get("score", 0)
    if type(s) == "dict":
        s = s.get("value", 0)
    if s == None or s == "":
        return 0
    return int(float(s))

def parse_game(e, now):
    comp = (e.get("competitions") or [{}])[0]
    note = ""
    for n in comp.get("notes", []):
        note = n.get("headline", "") or note
    start = e.get("date", "2000-01-01T00:00Z")
    played = iso_unix(start) <= now
    status = e.get("status") or comp.get("status") or {}
    st = status.get("type") or {}
    state = st.get("state", "pre")
    if not played:
        state = "pre"
    elif state == "pre":
        state = "in"
    teams = {}
    ids = {}
    for c in comp.get("competitors", []):
        a = (c.get("team") or {}).get("abbreviation", "")
        ids[c.get("id", "")] = a
        teams[a] = {"score": score_of(c), "home": c.get("homeAway", "") == "home"}
    wins = None
    ser = comp.get("series")
    # a game's series line counts wins through that game, so a future game
    # only helps when it hasn't been played anywhere yet (real time)
    if ser != None and (state == "post" or st.get("state", "pre") == "pre"):
        wins = {}
        for c in ser.get("competitors", []):
            wins[ids.get(c.get("id", ""), "")] = c.get("wins", 0)
    return {
        "id": str(e.get("id", "")), "start": start, "state": state, "teams": teams,
        "round": ROUND_OF.get((comp.get("type") or {}).get("abbreviation", ""), 0),
        "playin": "Play-In" in note, "note": note, "wins": wins,
        "period": status.get("period", 0), "clock": status.get("displayClock", ""),
        "half": st.get("name", "") == "STATUS_HALFTIME", "net": network_of(comp),
    }

def scoreboard(day, ttl, now):
    data = get_json(SCOREBOARD + day.replace("-", ""), ttl)
    if data == None:
        return None
    games = [parse_game(e, now) for e in data.get("events", [])]
    cal = []
    for lg in data.get("leagues", []):
        cal = [str(d)[0:10] for d in lg.get("calendar", [])]
    return {"games": games, "calendar": cal}

TEAM_SCHEDULE = "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/teams/%s/schedule?seasontype=3&season=%d"

def team_games(team_id, year, ttl, now):
    data = get_json(TEAM_SCHEDULE % (team_id, year), ttl)
    if data == None:
        return []
    return [parse_game(e, now) for e in data.get("events", [])]

LOOKAHEAD_SECONDS = 5 * 86400

def add_games(pool, games, now):
    for g in games:
        # games far ahead aren't needed, and they would give away later rounds
        # when rendering a past date
        if iso_unix(g["start"]) > now + LOOKAHEAD_SECONDS:
            continue
        if g["round"] > 0 or g["playin"]:
            old = pool.get(g["id"])
            # keep the scoreboard copy: it has the live clock and series line
            if old == None or (g["wins"] != None and old["wins"] == None):
                pool[g["id"]] = g

def load_games(ctx, m, all_rows, conf):
    # Play-in week: the play-in days so far plus the next one (scoreboards).
    # Playoffs: the playoff schedules of the conference's top-4 seeds (every
    # first-round series has one), one more for a first-round upset winner,
    # and today's scoreboard for live scores. At most 8 calls with the
    # calendar and standings.
    now = ctx.now.unix
    today = m["today"]
    pool = {}
    live = m["year"] == season_end_year(today)
    if live:
        first = scoreboard(today, 60, now)
        if first == None:
            return None
        add_games(pool, first["games"], now)
        if m["mode"] == "playin":
            cal = first["calendar"]
            days = [d for d in cal if d < today and d >= m.get("playin_start", today)][-3:] + [d for d in cal if d > today][:1]
            for d in days:
                sb = scoreboard(d, 600 if d > today else 900, now)
                if sb != None:
                    add_games(pool, sb["games"], now)
            return pool.values()
    ttl = 300 if live else 86400
    rows = all_rows[conf]
    fetched = []
    for r in rows[:4]:
        add_games(pool, team_games(r["id"], m["year"], ttl, now), now)
        fetched.append(r["abbr"])
    spare = 1 if live else 2
    by_seed = {}
    for r in rows:
        by_seed[r["seed"]] = r
    for p in [[1, 8], [2, 7], [3, 6], [4, 5]]:
        if spare == 0:
            break
        lo = by_seed.get(p[1])
        hi = by_seed.get(p[0])
        if lo == None or hi == None:
            continue
        st = series(all_rows, pool.values(), 1, lo["abbr"], hi["abbr"])
        if st["winner"] == lo["abbr"] and lo["abbr"] not in fetched:
            add_games(pool, team_games(lo["id"], m["year"], ttl, now), now)
            fetched.append(lo["abbr"])
            spare = spare - 1
    return pool.values()

# ---------- magic numbers (wins) ----------

def max_wins(t):
    return SEASON_GAMES - t["l"]

def kth_largest(values, k):
    v = sorted(values, reverse = True)
    if k <= 0 or k > len(v):
        return None
    return v[k - 1]

def spot_status(t, rows, k):
    # [text, color] for finishing in the top k: the magic number, swapped
    # for the tragic number when the team is closer to falling out
    rivals = [x for x in rows if x["abbr"] != t["abbr"]]
    cap = kth_largest([max_wins(x) for x in rivals], k)
    if cap == None:
        return ["-", DIM]
    magic = cap - t["w"] + 1
    if magic <= 0:
        return ["IN", GREEN]
    ahead = kth_largest([x["w"] for x in rivals], k)
    tragic = max_wins(t) - ahead + 1
    if tragic <= 0:
        return ["E", RED]
    if magic <= tragic:
        return [str(magic), GREEN]
    return [str(tragic), RED]

def games_ahead(a, b):
    # a's lead over b in games, e.g. "+2", "+1.5", "TIED"
    d = (a["w"] - b["w"]) + (b["l"] - a["l"])
    if d == 0:
        return "TIED"
    s = str(d // 2) if d % 2 == 0 else str(d // 2) + ".5"
    if d < 0:
        s = "-" + (str(-d // 2) if d % 2 == 0 else str(-d // 2) + ".5")
        return s
    return "+" + s

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
    "TIMBERWOLVES": "WOLVES", "TRAIL BLAZERS": "BLAZERS", "CAVALIERS": "CAVS",
    "MAVERICKS": "MAVS", "GRIZZLIES": "GRIZZ", "PELICANS": "PELS",
}

def fit_name(c, name, maxw):
    if c.text_width(name, NAME_FONTS[-1]) > maxw and SHORT_NAMES.get(name) != None:
        return SHORT_NAMES[name]
    return name

# ---------- chrome ----------

def chip(c, word, bg, x):
    w = c.text_width(word, "4x5") + 4
    c.round_rect(x, 0, x + w - 1, 6, 1, fill = bg)
    c.text(word, x + 2, 1, font = "4x5", color = ink_on(bg))
    return x + w

def header(c, conf, title, meta = ""):
    x = chip(c, CONF_CHIP[conf], CHIP[conf], PAD)
    c.text(title, x + 3, 1, font = "4x5", color = INK)
    if meta != "":
        c.text(meta, c.width - PAD, 1, font = "4x5", color = DIM, align = "right")

def message(c, head, sub, head_color):
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

def tile(c, x, y, h, team, label):
    fill = team_color(team)
    edge = lighten(fill, 45) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + TILE_W - 1, y + h - 1, 1, fill = fill, outline = edge)
    if label != "":
        font = "5x7" if h >= 9 and len(label) == 1 else "4x5"
        ty = y + (h - 7) // 2 if font == "5x7" else y + (h - 5) // 2
        c.text(label, x + TILE_W // 2, ty, font = font, color = ink_on(fill), align = "center")

def team_cell(c, x, y, label, team, text, font, color, maxw):
    tile(c, x, y, TILE_H, team, label)
    c.text(clip(c, text, font, maxw), x + TILE_W + NAME_GAP, y + 1, font = font, color = color)

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

# ---------- intro ----------

def intro_card(c, kicker, hero, sub, sub_color = DIM):
    hw = c.text_width(hero, "10x16")
    lockup = BALL_W + 6 + hw
    x0 = max(PAD, (c.width - lockup) // 2)
    hx = x0 + BALL_W + 6
    c.sprite(BALL, x0, 9, legend = BALL_LEGEND)
    c.text(kicker, hx, 1, font = "4x5", color = DIM)
    c.text(hero, hx, 8, font = "10x16", color = INK)
    c.text(clip(c, sub, "4x5", c.width - 2 * PAD), c.width // 2, 26, font = "4x5", color = sub_color, align = "center")

# ---------- race pages ----------

def first_round(c, conf, rows, pairs):
    # lower seed @ higher seed; 7 and 8 come out of the play-in
    header(c, conf, "FIRST ROUND", "7 + 8 FROM PLAY-IN")
    if len(rows) < 8:
        return message(c, "NOT SET YET", "FILLS IN AS THE SEASON GOES", INK)
    wide = 72
    names = []
    for p in pairs:
        names.append(fit_name(c, rows[p[0] - 1]["name"], wide))
        names.append(fit_name(c, rows[p[1] - 1]["name"], wide))
    font = page_font(c, names, wide)
    for i in range(2):
        y = ROW_Y[i]
        lo = rows[pairs[i][0] - 1]
        hi = rows[pairs[i][1] - 1]
        play_in = pairs[i][0] >= 7
        team_cell(c, PAD, y, str(pairs[i][0]), lo["abbr"], names[i * 2], font, AMBER if play_in else INK, wide)
        draw_at(c, 98, y + 2, DIM)
        team_cell(c, 104, y, str(pairs[i][1]), hi["abbr"], names[i * 2 + 1], font, INK, wide)

COL_WL = 104      # right edges of the stat columns
COL_GB = 132
COL_3 = 158

def stat_header(c, today, third, fourth):
    right = c.width - PAD
    c.text("W-L", COL_WL, 1, font = "4x5", color = DIM, align = "right")
    c.text("GB", COL_GB, 1, font = "4x5", color = DIM, align = "right")
    if numbers_on(today):
        c.text(third, COL_3, 1, font = "4x5", color = DIM, align = "right")
        c.text(fourth, right, 1, font = "4x5", color = DIM, align = "right")
    else:
        c.text("STRK", COL_3, 1, font = "4x5", color = DIM, align = "right")
        c.text("L10", right, 1, font = "4x5", color = DIM, align = "right")

SEED_W = 11       # small-row seed tile: wide enough for 10-15
ROW_NAME_X = PAD + SEED_W + NAME_GAP
ROW_NAME_W = 54

def seed_tile(c, x, y, t):
    fill = team_color(t["abbr"])
    edge = lighten(fill, 45) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + SEED_W - 1, y + 6, 1, fill = fill, outline = edge)
    c.text(str(t["seed"]), x + SEED_W // 2 + 1, y + 1, font = "4x5", color = ink_on(fill), align = "center")

def stat_row(c, today, y, t, name, font, rows):
    # seed tile, name, W-L, GB, then from March 1 the top-6 and top-10
    # magic/tragic numbers; before that the streak and last 10
    right = c.width - PAD
    seed_tile(c, PAD, y, t)
    c.text(clip(c, name, font, ROW_NAME_W), ROW_NAME_X, y, font = font, color = INK)
    c.text(str(t["w"]) + "-" + str(t["l"]), COL_WL, y, font = "5x7", color = INK, align = "right")
    c.text(t["gb"], COL_GB, y, font = "5x7", color = DIM, align = "right")
    if not numbers_on(today):
        sk = t["strk"]
        c.text(sk, COL_3, y + 1, font = "4x5", color = GREEN if sk.startswith("W") else (RED if sk.startswith("L") else DIM), align = "right")
        c.text(t["l10"], right, y + 1, font = "4x5", color = INK, align = "right")
        return
    s6 = spot_status(t, rows, 6)
    s10 = spot_status(t, rows, 10)
    c.text(s6[0], COL_3, y, font = "5x7", color = s6[1], align = "right")
    c.text(s10[0], right, y, font = "5x7", color = s10[1], align = "right")

def table_page(c, conf, today, title, rows, seeds):
    header(c, conf, title)
    stat_header(c, today, "TOP6", "TOP10")
    picked = [r for r in rows if r["seed"] in seeds]
    if len(picked) == 0:
        return message(c, "NOT SET YET", "FILLS IN AS THE SEASON GOES", INK)
    names = [fit_name(c, r["name"], ROW_NAME_W) for r in picked]
    font = page_font(c, names, ROW_NAME_W)
    for i in range(min(3, len(picked))):
        stat_row(c, today, SMALL_Y[i], picked[i], names[i], font, rows)

def playin_matchups(c, conf, rows):
    # 8 @ 7: the winner is the 7 seed. 10 @ 9: the loser is out. The 7/8
    # loser hosts the 9/10 winner for the 8 seed.
    header(c, conf, "PLAY-IN")
    c.text("7/8 LOSER: 2ND SHOT", c.width - PAD, 1, font = "4x5", color = AMBER, align = "right")
    if len(rows) < 10:
        return message(c, "NOT SET YET", "FILLS IN AS THE SEASON GOES", INK)
    pairs = [[8, 7, "WIN: 7 SEED"], [10, 9, "LOSER OUT"]]
    w = 42
    names = []
    for p in pairs:
        names.append(fit_name(c, rows[p[0] - 1]["name"], w))
        names.append(fit_name(c, rows[p[1] - 1]["name"], w))
    font = page_font(c, names, w)
    right = c.width - PAD
    for i in range(2):
        y = ROW_Y[i]
        lo = rows[pairs[i][0] - 1]
        hi = rows[pairs[i][1] - 1]
        team_cell(c, PAD, y, str(pairs[i][0]), lo["abbr"], names[i * 2], font, INK, w)
        draw_at(c, 66, y + 2, DIM)
        team_cell(c, 72, y, str(pairs[i][1]), hi["abbr"], names[i * 2 + 1], font, INK, w)
        c.text(pairs[i][2], right, y + 2, font = "4x5", color = GREEN if i == 0 else RED, align = "right")

def race_leaders(c, conf, today, rows):
    # Line 1: the No. 1 seed race. Line 2: the 6 seed's hold on a top-6
    # spot over the 7 seed. Line 3: the 10 seed's hold on the play-in over
    # the 11 seed. Before March 1, games leads; after, magic numbers.
    early = not numbers_on(today)
    header(c, conf, "THE LINES", "LEAD" if early else "MAGIC #")
    if len(rows) < 11:
        return message(c, "NOT SET YET", "FILLS IN AS THE SEASON GOES", INK)
    lines = [[1, 2, "1 SEED", 1], [6, 7, "TOP 6", 6], [10, 11, "PLAY-IN", 10]]
    nw = 50
    names = [fit_name(c, rows[l[0] - 1]["name"], nw) for l in lines]
    font = page_font(c, names, nw)
    right = c.width - PAD
    for i in range(3):
        a = rows[lines[i][0] - 1]
        b = rows[lines[i][1] - 1]
        y = SMALL_Y[i]
        seed_tile(c, PAD, y, a)
        c.text(clip(c, names[i], font, nw), ROW_NAME_X, y, font = font, color = INK)
        c.text(lines[i][2], 110, y + 1, font = "4x5", color = DIM, align = "right")
        c.text("OVER " + b["abbr"], 115, y + 1, font = "4x5", color = DIM)
        if early:
            ld = games_ahead(a, b)
            c.text(ld, right, y, font = "5x7", color = INK if ld.startswith("+") else AMBER, align = "right")
        else:
            st = spot_status(a, rows, lines[i][3])
            c.text(st[0], right, y, font = "5x7", color = st[1], align = "right")

def chasers(c, conf, today, rows):
    # the three teams just outside the play-in, GB from the 10 seed
    table_page(c, conf, today, "CHASERS", rows, [11, 12, 13])

# ---------- playoffs: bracket ----------

R1_PAIRS = [[[8, 1], [7, 2]], [[6, 3], [5, 4]]]
HALF_A = [1, 8, 4, 5]     # the 1/8 and 4/5 winners meet in the second round

def team_row(all_rows, abbr):
    for k in ["E", "W"]:
        for r in all_rows[k]:
            if r["abbr"] == abbr:
                return r
    return None

def pct(r):
    g = r["w"] + r["l"]
    return r["w"] * 1000 // g if g > 0 else 0

def reached(games, abbr, rnd):
    # the team has a game in round rnd or later
    for g in games:
        if g["round"] >= rnd and abbr in g["teams"]:
            return True
    return False

def series(all_rows, games, rnd, a, b):
    # one series as of now; a and b may be "" (not set yet). lo is the
    # lower seed, shown on the left.
    if a != "" and b != "":
        ra = team_row(all_rows, a)
        rb = team_row(all_rows, b)
        if ra != None and rb != None:
            better_a = ra["seed"] < rb["seed"] if rnd < 4 else pct(ra) >= pct(rb)
            if better_a:
                a, b = b, a
    st = {"lo": a, "hi": b, "round": rnd, "wins": None, "winner": "", "adv": False, "live": None, "next": None}
    if a == "" or b == "":
        return st
    # wins: finished games counted, or the scoreboard's series line when
    # that is further along (a game outside the schedules we hold)
    count = {a: 0, b: 0}
    line = None
    seen = False
    for g in sorted([g for g in games if g["round"] == rnd and a in g["teams"] and b in g["teams"]], key = lambda g: g["start"]):
        seen = True
        if g["state"] == "in":
            st["live"] = g
        elif g["state"] == "pre" and st["next"] == None:
            st["next"] = g
        elif g["state"] == "post":
            w = game_winner(g)
            if w in count:
                count[w] = count[w] + 1
        if g["wins"] != None:
            line = g["wins"]
    if seen:
        st["wins"] = {}
        for t in [a, b]:
            st["wins"][t] = max(count[t], (line or {}).get(t, 0))
            if st["wins"][t] >= 4:
                st["winner"] = t
    if st["winner"] == "" and rnd < 4:
        # the series has left the window: a later-round game shows who won
        for t in [a, b]:
            if reached(games, t, rnd + 1):
                st["winner"] = t
                st["adv"] = st["wins"] == None
    return st

def pair_in(games, rnd, pool):
    # the two teams of a round-rnd game involving any team in pool
    for g in games:
        if g["round"] == rnd:
            ts = list(g["teams"].keys())
            if len(ts) == 2 and (ts[0] in pool or ts[1] in pool):
                return ts
    return None

def bracket(all_rows, games, conf):
    rows = all_rows[conf]
    by_seed = {}
    for r in rows:
        by_seed[r["seed"]] = r["abbr"]
    r1 = []
    for page_pairs in R1_PAIRS:
        for p in page_pairs:
            r1.append(series(all_rows, games, 1, by_seed.get(p[0], ""), by_seed.get(p[1], "")))
    # r1 order: 8/1, 7/2, 6/3, 5/4
    halves = [[r1[0], r1[3]], [r1[1], r1[2]]]
    r2 = []
    for h in range(2):
        pool = [by_seed.get(s, "") for s in (HALF_A if h == 0 else [2, 7, 3, 6])]
        ts = pair_in(games, 2, pool)
        if ts == None:
            ts = [halves[h][0]["winner"], halves[h][1]["winner"]]
        r2.append(series(all_rows, games, 2, ts[0], ts[1]))
    ts = pair_in(games, 3, [r["abbr"] for r in rows])
    if ts == None:
        ts = [r2[0]["winner"], r2[1]["winner"]]
    cf = series(all_rows, games, 3, ts[0], ts[1])
    return {"r1": r1, "r2": r2, "cf": cf}

def finals(all_rows, games):
    ts = pair_in(games, 4, [r["abbr"] for r in all_rows["E"]] + [r["abbr"] for r in all_rows["W"]])
    if ts == None:
        ts = [bracket(all_rows, games, "E")["cf"]["winner"], bracket(all_rows, games, "W")["cf"]["winner"]]
    return series(all_rows, games, 4, ts[0], ts[1])

# ---------- playoffs: drawing ----------

BADGES = {
    "ABC": ["#F4F7FF", "black", ""],
    "NBC": ["#1B1B1B", "white", "#6E6E6E"],
    "PRIME": ["#00A8E1", "black", ""],
    "NBATV": ["#1D428A", "white", "#9AA3B5"],
    "PEACOCK": ["#1B1B1B", "#F4F7FF", "#6E6E6E"],
}

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
        c.text(net, x, y + 1, font = "4x5", color = "#B79CFF")

DAY_NAMES = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
ET_DISPLAY_OFFSET_SECONDS = 4 * 3600

def et_when(iso):
    # [ET date, weekday, "8:30P"]
    t = iso_unix(iso) - ET_DISPLAY_OFFSET_SECONDS
    days = t // 86400
    sod = t % 86400
    y, m, d = civil_from_days(days)
    h = sod // 3600
    hh = h % 12
    if hh == 0:
        hh = 12
    return [str(y) + "-" + pad2(m) + "-" + pad2(d), DAY_NAMES[(days + 3) % 7], str(hh) + ":" + pad2((sod % 3600) // 60) + ("A" if h < 12 else "P")]

def period_text(g):
    if g["half"]:
        return "HALF"
    p = g["period"]
    if p > 5:
        return str(p - 4) + "OT"
    return "OT" if p == 5 else "Q" + str(max(1, p))

def status_line(st, today):
    if st["winner"] != "":
        return [st["winner"] + (" ADV" if st["adv"] else " WINS"), AMBER]
    g = st["live"]
    if g != None:
        return [period_text(g) + " " + str(g["teams"][st["lo"]]["score"]) + "-" + str(g["teams"][st["hi"]]["score"]), GREEN]
    g = st["next"]
    if g == None:
        return ["", DIM]
    w = et_when(g["start"])
    return [w[2], INK] if w[0] == today else [w[1] + " " + w[2], DIM]

def wins_color(st, team, other):
    if st["winner"] != "":
        return GREEN if st["winner"] == team else DIM
    w = st["wins"].get(team, 0)
    o = st["wins"].get(other, 0)
    if w > o:
        return "#5FC8FF"
    return DIM if w < o else INK

def seed_label(all_rows, abbr):
    r = team_row(all_rows, abbr)
    return str(r["seed"]) if r != None and r["seed"] < 10 else ""

def name_for(c, all_rows, abbr, maxw):
    r = team_row(all_rows, abbr)
    return fit_name(c, r["name"], maxw) if r != None else "TBD"

def series_rows(c, all_rows, sts, today):
    # [tile] LOWER  w-w  [tile] HIGHER      status / network
    nw = 40
    names = []
    for st in sts:
        names.append(name_for(c, all_rows, st["lo"], nw) if st["lo"] != "" else "TBD")
        names.append(name_for(c, all_rows, st["hi"], nw) if st["hi"] != "" else "TBD")
    font = page_font(c, names, nw)
    right = c.width - PAD
    for i in range(min(2, len(sts))):
        st = sts[i]
        y = ROW_Y[i]
        for j in range(2):
            team = st["lo"] if j == 0 else st["hi"]
            lost = st["winner"] != "" and st["winner"] != team
            team_cell(c, PAD if j == 0 else 80, y, seed_label(all_rows, team), team, names[i * 2 + j], font,
                      DIM if (lost or team == "") else INK, nw)
        if st["wins"] != None:
            a, b = st["lo"], st["hi"]
            c.text(str(st["wins"][a]), 65, y + 1, font = "5x7", color = wins_color(st, a, b), align = "center")
            c.text("-", 70, y + 1, font = "5x7", color = DIM, align = "center")
            c.text(str(st["wins"][b]), 75, y + 1, font = "5x7", color = wins_color(st, b, a), align = "center")
        elif st["winner"] == "":
            c.text("VS", 70, y + 2, font = "4x5", color = DIM, align = "center")
        s = status_line(st, today)
        game = st["live"] if st["live"] != None else st["next"]
        net = game["net"] if (game != None and st["winner"] == "") else ""
        if net != "":
            ty = 7 + 13 * i
            c.text(clip(c, s[0], "4x5", right - 138), right, ty, font = "4x5", color = s[1], align = "right")
            draw_network(c, net, right - network_width(c, net) + 1, ty + 5)
        else:
            c.text(clip(c, s[0], "4x5", right - 138), right, y + 2, font = "4x5", color = s[1], align = "right")

def series_board(c, all_rows, st, today, done_title):
    # one series, scoreboard style: higher seed on top, status on the right
    right = c.width - PAD
    sides = [st["hi"], st["lo"]]
    names = [name_for(c, all_rows, t, 70) if t != "" else "TBD" for t in sides]
    font = page_font(c, names, 70)
    for j in range(2):
        team = sides[j]
        y = ROW_Y[j]
        lost = st["winner"] != "" and st["winner"] != team
        team_cell(c, PAD, y, seed_label(all_rows, team), team, names[j], font, DIM if (lost or team == "") else INK, 70)
        if st["wins"] != None:
            c.text(str(st["wins"][team]), 104, y + 1, font = "5x7", color = wins_color(st, team, sides[1 - j]), align = "right")
    c.vline(112, ROW_Y[0], 29, STRUCT)
    cx = (116 + right) // 2
    if st["winner"] != "":
        c.text(done_title, cx, ROW_Y[0] + 2, font = "4x5", color = AMBER, align = "center")
        if st["wins"] != None:
            lo = sides[1] if st["winner"] == sides[0] else sides[0]
            c.text(st["winner"] + " " + str(st["wins"][st["winner"]]) + "-" + str(st["wins"][lo]), cx, ROW_Y[1] + 2, font = "4x5", color = INK, align = "center")
        return
    g = st["live"] if st["live"] != None else st["next"]
    if g == None:
        return
    played = (st["wins"][st["hi"]] + st["wins"][st["lo"]]) if st["wins"] != None else 0
    gnum = "GAME " + str(played + 1)
    if g["net"] != "":
        gw = c.text_width(gnum, "4x5")
        x0 = cx - (gw + 4 + network_width(c, g["net"])) // 2
        c.text(gnum, x0, ROW_Y[0] + 2, font = "4x5", color = INK)
        draw_network(c, g["net"], x0 + gw + 4, ROW_Y[0] + 1)
    else:
        c.text(gnum, cx, ROW_Y[0] + 2, font = "4x5", color = INK, align = "center")
    if st["live"] != None:
        s = status_line(st, today)
        c.text(s[0], cx, ROW_Y[1] + 2, font = "4x5", color = GREEN, align = "center")
    else:
        w = et_when(g["start"])
        c.text(("TODAY " + w[2]) if w[0] == today else (w[1] + " " + w[2]), cx, ROW_Y[1] + 2, font = "4x5", color = DIM, align = "center")

def not_set(c):
    message(c, "NOT SET YET", "BRACKET FILLS IN AS SERIES END", INK)

def post_round1(c, all_rows, br, conf, part, today):
    header(c, conf, "FIRST ROUND")
    series_rows(c, all_rows, br["r1"][part * 2:part * 2 + 2], today)

def post_round2(c, all_rows, br, conf, today):
    header(c, conf, "SECOND ROUND")
    if br["r2"][0]["lo"] == "" and br["r2"][0]["hi"] == "" and br["r2"][1]["lo"] == "" and br["r2"][1]["hi"] == "":
        return not_set(c)
    series_rows(c, all_rows, br["r2"], today)

def post_board(c, all_rows, st, chip_word, chip_color, title, done_title, today):
    x = chip(c, chip_word, chip_color, PAD)
    c.text(title, x + 3, 1, font = "4x5", color = INK)
    c.text("BEST OF 7", c.width - PAD, 1, font = "4x5", color = DIM, align = "right")
    if st["lo"] == "" and st["hi"] == "":
        return not_set(c)
    series_board(c, all_rows, st, today, done_title)

def game_row(c, all_rows, y, g, tag, right_text, right_color):
    # [tag] AWAY score @ HOME score            right text
    ts = list(g["teams"].keys())
    if len(ts) != 2:
        return
    away = ts[0] if not g["teams"][ts[0]]["home"] else ts[1]
    home = ts[1] if away == ts[0] else ts[0]
    x = PAD
    if tag != "":
        c.text(tag, x, y + 1, font = "4x5", color = DIM)
        x = x + 18
    shown = g["state"] != "pre"
    for k in range(2):
        t = away if k == 0 else home
        r = team_row(all_rows, t)
        if r != None:
            seed_tile(c, x, y, r)
        lose = g["state"] == "post" and g["teams"][t]["score"] < g["teams"][home if k == 0 else away]["score"]
        c.text(t, x + SEED_W + 2, y, font = "5x7", color = DIM if lose else INK)
        if shown:
            c.text(str(g["teams"][t]["score"]), x + 52, y, font = "5x7", color = DIM if lose else INK, align = "right")
        if k == 0:
            draw_at(c, x + 58, y + 1, DIM)
            x = x + 64
    c.text(right_text, c.width - PAD, y + 1, font = "4x5", color = right_color, align = "right")

def game_winner(g):
    ts = list(g["teams"].keys())
    if g["state"] != "post" or len(ts) != 2:
        return ""
    return ts[0] if g["teams"][ts[0]]["score"] > g["teams"][ts[1]]["score"] else ts[1]

def game_status(g, today):
    if g["state"] == "post":
        return [game_winner(g) + " WINS", AMBER]
    if g["state"] == "in":
        return [period_text(g), GREEN]
    w = et_when(g["start"])
    return [w[2], INK] if w[0] == today else [w[1] + " " + w[2], DIM]

PLAYIN_TAGS = [["7th Place vs 8th", "7/8"], ["9th Place vs 10th", "9/10"], ["8th Place", "FOR 8"]]

def post_playin(c, all_rows, games, conf, mode, today):
    header(c, conf, "PLAY-IN")
    key = " - " + CONF_KEY[conf] + " - "
    pg = sorted([g for g in games if g["playin"] and key in g["note"]], key = lambda g: g["start"])
    if len(pg) == 0:
        if mode == "playin":
            return playin_matchups(c, conf, all_rows[conf])
        # the play-in has left the window: its two survivors
        c.text("VIA PLAY-IN", c.width - PAD, 1, font = "4x5", color = DIM, align = "right")
        rows = all_rows[conf]
        if len(rows) < 8:
            return not_set(c)
        names = [fit_name(c, rows[k]["name"], 120) for k in [6, 7]]
        font = page_font(c, names, 120)
        for i in range(2):
            team_cell(c, PAD, ROW_Y[i], str(i + 7), rows[6 + i]["abbr"], names[i], font, INK, 120)
            c.text(str(i + 7) + " SEED", c.width - PAD, ROW_Y[i] + 2, font = "4x5", color = AMBER, align = "right")
        return
    c.text("7/8 LOSER: 2ND SHOT", c.width - PAD, 1, font = "4x5", color = AMBER, align = "right")
    for i in range(min(3, len(pg))):
        g = pg[i]
        tag = ""
        for t in PLAYIN_TAGS:
            if t[0] in g["note"]:
                tag = t[1]
                break
        s = game_status(g, today)
        game_row(c, all_rows, SMALL_Y[i], g, tag, s[0], s[1])

def series_after(games, g):
    # the series wins once game g was over: its own series line, or the
    # finished games of that series counted up to it
    if g["wins"] != None:
        return g["wins"]
    ts = list(g["teams"].keys())
    if len(ts) != 2:
        return None
    out = {ts[0]: 0, ts[1]: 0}
    for x in games:
        if x["round"] == g["round"] and x["state"] == "post" and x["start"] <= g["start"] and ts[0] in x["teams"] and ts[1] in x["teams"]:
            w = game_winner(x)
            if w in out:
                out[w] = out[w] + 1
    return out

def series_text(games, g):
    # the series after this game: "NY WINS 4-1", "NY LEADS 3-1", "TIED 2-2"
    wins = series_after(games, g)
    if wins == None:
        return ""
    ts = list(wins.keys())
    if len(ts) != 2:
        return ""
    a, b = ts[0], ts[1]
    if wins[b] > wins[a]:
        a, b = b, a
    wa, wb = wins[a], wins[b]
    if wa == wb:
        return "TIED " + str(wa) + "-" + str(wb)
    return a + (" WINS " if wa >= 4 else " LEADS ") + str(wa) + "-" + str(wb)

def post_results(c, all_rows, games, conf, today):
    # the conference's latest finished playoff games (the Finals count for both)
    header(c, conf, "RESULTS", "LATEST")
    mine = [r["abbr"] for r in all_rows[conf]]
    done = [g for g in games if g["round"] > 0 and g["state"] == "post" and
            (g["round"] == 4 or len([t for t in g["teams"] if t in mine]) > 0)]
    done = sorted(done, key = lambda g: g["start"], reverse = True)[:3]
    if len(done) == 0:
        return message(c, "NO GAMES YET", "RESULTS SHOW AFTER EACH FINAL", INK)
    for i in range(len(done)):
        g = done[i]
        txt = series_text(games, g)
        game_row(c, all_rows, SMALL_Y[i], g, "", txt, AMBER if " WINS " in txt else INK)

# ---------- page dispatch ----------

def conference(ctx):
    v = str(ctx.inputs.get("conference", "East")).upper()
    return "W" if v.startswith("W") else "E"

CHAMPS_DAYS = 7    # the champions card stays up this long into a new season

def plus_days(day, n):
    return date_of(days_from_civil(int(day[0:4]), int(day[5:7]), int(day[8:10])) + n)

def date_of(days):
    y, m, d = civil_from_days(days)
    return str(y) + "-" + pad2(m) + "-" + pad2(d)

def last_champion(year, now):
    # the champion's team name from the scoreboard of last season's final
    # game day, or None: two small calls instead of rebuilding the bracket
    first = get_json(SCOREBOARD + str(year) + "0731", 86400)
    if first == None:
        return None
    cal = []
    for lg in first.get("leagues", []):
        cal = [str(d)[0:10] for d in lg.get("calendar", [])]
    days = [d for d in cal if d <= str(year) + "-07-31"]
    if len(days) == 0:
        return None
    data = get_json(SCOREBOARD + days[-1].replace("-", ""), 86400)
    if data == None:
        return None
    for e in data.get("events", []):
        g = parse_game(e, now)
        if g["round"] != 4 or g["state"] != "post" or g["wins"] == None:
            continue
        for c in ((e.get("competitions") or [{}])[0]).get("competitors", []):
            t = c.get("team") or {}
            a = t.get("abbreviation", "")
            if g["wins"].get(a, 0) >= 4:
                return t.get("name", a).upper()
    return None

def intro(c, ctx):
    c.clear()
    conf = conference(ctx)
    m = load_mode(ctx)
    y = m["year"]
    if m["mode"] == "race" and m.get("reg_start", "") != "" and m["today"] < plus_days(m["reg_start"], CHAMPS_DAYS):
        # opening week: last season's champions before the new picture
        ch = last_champion(y - 1, ctx.now.unix)
        if ch != None:
            return intro_card(c, "NBA FINALS " + str(y - 1), "CHAMPIONS", ch + " WIN THE NBA TITLE", AMBER)
    if m["mode"] == "race":
        return intro_card(c, "NBA " + str(y - 1) + "-" + str(y % 100), "PLAYOFF PICTURE",
                          CONF_CHIP[conf] + " - IF THE SEASON ENDED TODAY")
    if m["mode"] == "playin":
        return intro_card(c, "NBA PLAY-IN " + str(y), "PLAY-IN",
                          CONF_CHIP[conf] + " - WHO GETS THE 7 AND 8 SEEDS")
    all_rows = load_all(y, 3600)
    games = load_games(ctx, m, all_rows, conf) if all_rows != None else None
    if games != None:
        st = finals(all_rows, games)
        if st["winner"] != "":
            r = team_row(all_rows, st["winner"])
            return intro_card(c, "NBA FINALS " + str(y), "CHAMPIONS",
                              (r["name"] if r != None else st["winner"]) + " WIN THE NBA TITLE", AMBER)
    intro_card(c, "NBA PLAYOFFS " + str(y), "PLAYOFFS", ("EASTERN" if conf == "E" else "WESTERN") + " CONFERENCE")

def offline(c, conf):
    header(c, conf, "PLAYOFFS")
    message(c, "STANDINGS OFFLINE", "TRYING AGAIN SOON", AMBER)

def post_page(c, ctx, conf, m, slot):
    all_rows = load_all(m["year"], 3600)
    if all_rows == None:
        return offline(c, conf)
    games = load_games(ctx, m, all_rows, conf)
    if games == None:
        return offline(c, conf)
    today = m["today"]
    if slot == 5:
        return post_playin(c, all_rows, games, conf, m["mode"], today)
    if slot == 6:
        return post_results(c, all_rows, games, conf, today)
    br = bracket(all_rows, games, conf)
    if slot < 2:
        return post_round1(c, all_rows, br, conf, slot, today)
    if slot == 2:
        return post_round2(c, all_rows, br, conf, today)
    if slot == 3:
        return post_board(c, all_rows, br["cf"], CONF_CHIP[conf], CHIP[conf], "CONFERENCE FINALS", CONF_CHIP[conf] + " CHAMPS", today)
    post_board(c, all_rows, finals(all_rows, games), "NBA", AMBER, "NBA FINALS", "CHAMPIONS", today)

def page(c, ctx, slot):
    c.clear()
    conf = conference(ctx)
    m = load_mode(ctx)
    today = m["today"]
    if m["mode"] == "post" or (m["mode"] == "playin" and slot == 5):
        return post_page(c, ctx, conf, m, slot)
    all_rows = load_all(m["year"], 600)
    if all_rows == None:
        return offline(c, conf)
    rows = all_rows[conf]
    if slot == 0:
        return first_round(c, conf, rows, [[8, 1], [7, 2]])
    if slot == 1:
        return first_round(c, conf, rows, [[6, 3], [5, 4]])
    if slot == 2:
        return race_leaders(c, conf, today, rows)
    if slot == 3:
        return table_page(c, conf, today, "TOP 6", rows, [1, 2, 3])
    if slot == 4:
        return table_page(c, conf, today, "TOP 6", rows, [4, 5, 6])
    if slot == 5:
        return playin_matchups(c, conf, rows)
    chasers(c, conf, today, rows)

def round1a(c, ctx):
    page(c, ctx, 0)

def round1b(c, ctx):
    page(c, ctx, 1)

def leaders(c, ctx):
    page(c, ctx, 2)

def top1(c, ctx):
    page(c, ctx, 3)

def top2(c, ctx):
    page(c, ctx, 4)

def playin(c, ctx):
    page(c, ctx, 5)

def chasers_page(c, ctx):
    page(c, ctx, 6)
