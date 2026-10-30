# NFL Playoff Race (192x32)
#
# One conference per app instance (input: AFC or NFC) - add the app twice
# for both. Two modes, picked from the calendar and ESPN's playoff games:
#
#   page         race (regular season)          postseason
#   intro        if the season ended today      playoffs / champion
#   leaders      seeds 1-4 (division leaders)   seeds 1-4
#   wildcards    seeds 5-7                      Wild Card Round
#   first_round  Wild Card Round matchups       Divisional Round
#   hunt         seeds 8-10, games back of 7    conference title game
#   top_seed     No. 1 seed race                Super Bowl
#   div1         East / North standings         East / North final
#   div2         South / West standings         South / West final
#
# Seeds and clinch marks come from ESPN's standings, so the order follows
# the NFL's tiebreakers. Marks: * No. 1 seed, Z division, Y wild card,
# X playoff berth, E eliminated.

STANDINGS_URL = "https://site.web.api.espn.com/apis/v2/sports/football/nfl/standings"
SCORES_URL = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"
POST_WEEKS = [1, 2, 3, 5]    # Wild Card, Divisional, Championship, Super Bowl

TEAM_COLORS = {
    "ARI": "#97233F", "ATL": "#A71930", "BAL": "#241773", "BUF": "#00338D", "CAR": "#0085CA", "CHI": "#0B162A",
    "CIN": "#FB4F14", "CLE": "#FF3C00", "DAL": "#003594", "DEN": "#FB4F14", "DET": "#0076B6", "GB": "#203731",
    "HOU": "#03202F", "IND": "#002C5F", "JAX": "#006778", "KC": "#E31837", "LAC": "#0080C6", "LAR": "#003594",
    "LV": "#A5ACAF", "MIA": "#008E97", "MIN": "#4F2683", "NE": "#002244", "NO": "#D3BC8D", "NYG": "#0B2265",
    "NYJ": "#125740", "PHI": "#004C54", "PIT": "#FFB612", "SEA": "#002244", "SF": "#AA0000", "TB": "#D50A0A",
    "TEN": "#4B92DB", "WSH": "#5A1414",
}

# Second team color, for banner stripes.
TEAM_ALT = {
    "ARI": "#FFB612", "ATL": "#000000", "BAL": "#9E7C0C", "BUF": "#C60C30", "CAR": "#101820", "CHI": "#C83803",
    "CIN": "#000000", "CLE": "#311D00", "DAL": "#869397", "DEN": "#002244", "DET": "#B0B7BC", "GB": "#FFB612",
    "HOU": "#A71930", "IND": "#A2AAAD", "JAX": "#D7A22A", "KC": "#FFB81C", "LAC": "#FFC20E", "LAR": "#FFA300",
    "LV": "#000000", "MIA": "#FC4C02", "MIN": "#FFC62F", "NE": "#C60C30", "NO": "#101820", "NYG": "#A71930",
    "NYJ": "#FFFFFF", "PHI": "#A5ACAF", "PIT": "#101820", "SEA": "#69BE28", "SF": "#B3995D", "TB": "#FF7900",
    "TEN": "#0C2340", "WSH": "#FFB612",
}

INK = "#F4F7FF"
DIM = "#6E7A94"
STRUCT = "#282828"
AMBER = "#E8B04A"
GOLD = "#F5C542"
GREEN = "#3FCF6E"
RED = "#E5484D"
CHIP = {"AFC": "#C8102E", "NFC": "#1D4ED8"}

PAD = 6
TILE_W = 9
NAME_GAP = 2
ROW_Y = [10, 21]
SMALL_Y = [8, 16, 24]
NAME_FONTS = ["5x7", "4x7"]

# Original pixel-art football for the intro card.
BALL = [
    "....bbbbbbbb....",
    "..bbbbbbbbbbbb..",
    ".bbbwbbbbbbwbbb.",
    "bbbbbwwwwwwbbbbb",
    "bbbbbwbwbwbbbbbb",
    "bbbbbwwwwwwbbbbb",
    ".bbbwbbbbbbwbbb.",
    "..bbbbbbbbbbbb..",
    "....bbbbbbbb....",
]
BALL_LEGEND = {"b": "#8B4A22", "w": "#F4F7FF"}
BALL_W = 16

# Original pixel-art Lombardi-style trophy for the champion banner.
TROPHY = [
    "....l....",
    "...lss...",
    "..lssss..",
    "..lssss..",
    "...sss...",
    "....s....",
    "....s....",
    "...lss...",
    "...lss...",
    "..lssss..",
    "..lssss..",
    ".lssssss.",
    ".ddddddd.",
    ".ddddddd.",
]
TROPHY_LEGEND = {"l": "#F4F7FF", "s": "#B8BEC9", "d": "#5E6470"}

# The fonts have no "@" or "*", so both are drawn: 5x5.
AT_SIGN = [".ggg.", "g.g.g", "g.ggg", "g....", ".ggg."]
STAR = ["..g..", "ggggg", ".ggg.", ".g.g.", "g...g"]

# Familiar short forms for nicknames too long for a tight column.
SHORT_NAMES = {"BUCCANEERS": "BUCS", "COMMANDERS": "WASH"}

# ---------- color helpers ----------

HEX = "0123456789ABCDEF"

def brightness(h):
    return (int(h[1:3], 16) * 299 + int(h[3:5], 16) * 587 + int(h[5:7], 16) * 114) // 1000

def lighten(h, pct):
    out = "#"
    for i in [1, 3, 5]:
        v = int(h[i:i + 2], 16)
        v = v + (255 - v) * pct // 100
        out += HEX[v // 16] + HEX[v % 16]
    return out

def team_color(a):
    return TEAM_COLORS.get(a, "#3A3F4B")

def ink_on(fill):
    return "black" if brightness(fill) > 150 else "white"

# ---------- dates (ET) ----------

DAY_NAMES = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

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

def iso_unix(iso):
    days = days_from_civil(int(iso[0:4]), int(iso[5:7]), int(iso[8:10]))
    return days * 86400 + int(iso[11:13]) * 3600 + int(iso[14:16]) * 60

def et_offset(unix):
    # Eastern daylight time from mid-March to early November, else standard.
    y, m, d = civil_from_days(unix // 86400)
    dst = (m > 3 and m < 11) or (m == 3 and d >= 8) or (m == 11 and d < 7)
    return (4 if dst else 5) * 3600

def et_day(unix):
    t = unix - et_offset(unix)
    return t // 86400

def et_clock(unix):
    t = unix - et_offset(unix)
    sod = t % 86400
    h = sod // 3600
    hh = h % 12
    if hh == 0:
        hh = 12
    mins = (sod % 3600) // 60
    return str(hh) + (":" + pad2(mins) if mins else "") + ("A" if h < 12 else "P")

def weekday(unix):
    return DAY_NAMES[(et_day(unix) + 3) % 7]

# ---------- data ----------

def season_of(ctx):
    # The NFL season named for the year it starts: Jan-Jul belong to the
    # previous year's season.
    t = ctx.now.unix - et_offset(ctx.now.unix)
    y, m, d = civil_from_days(t // 86400)
    return y if m >= 8 else y - 1, m

def load_standings(season, conf):
    resp = http.get(STANDINGS_URL, params = {"level": "3", "season": str(season)}, ttl_seconds = 1800)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    out = {"teams": [], "divs": [], "played": 0, "all_seeds": {}}
    for cf in resp["json"].get("children", []):
        if cf.get("abbreviation") != conf:
            for dv in cf.get("children", []):
                for e in (dv.get("standings") or {}).get("entries", []):
                    for s in e.get("stats", []):
                        if s.get("name") == "playoffSeed":
                            out["all_seeds"][str(e["team"]["abbreviation"])] = int(s["value"])
            continue
        for dv in cf.get("children", []):
            rows = []
            for e in (dv.get("standings") or {}).get("entries", []):
                st = {}
                for s in e.get("stats", []):
                    st[s.get("name")] = s
                t = {
                    "abbr": str(e["team"]["abbreviation"]),
                    "nick": str(e["team"]["shortDisplayName"]).upper(),
                    "seed": int(st["playoffSeed"]["value"]) if "playoffSeed" in st else 99,
                    "w": int(st["wins"]["value"]) if "wins" in st else 0,
                    "l": int(st["losses"]["value"]) if "losses" in st else 0,
                    "t": int(st["ties"]["value"]) if "ties" in st else 0,
                    "rec": st["overall"]["displayValue"] if "overall" in st else "",
                    "streak": st["streak"]["displayValue"] if "streak" in st else "",
                    "div": str(dv.get("abbreviation", "")),
                    "clinch": st["clincher"]["displayValue"] if "clincher" in st else "",
                }
                out["played"] += t["w"] + t["l"] + t["t"]
                rows.append(t)
                out["teams"].append(t)
            out["divs"].append((str(dv.get("abbreviation", "")), rows))
    out["teams"] = sorted(out["teams"], key = lambda t: t["seed"])
    return out if out["teams"] else None

def parse_game(e, now):
    comps = e.get("competitions") or []
    if not comps:
        return None
    c = comps[0]
    side = {}
    for k in c.get("competitors") or []:
        tm = k.get("team") or {}
        side[k.get("homeAway")] = {"abbr": str(tm.get("abbreviation", "")), "nick": str(tm.get("shortDisplayName", "")).upper(),
                                   "score": str(k.get("score", ""))}
    if "home" not in side or "away" not in side:
        return None
    st = c.get("status") or {}
    kind = st.get("type") or {}
    start = iso_unix(str(e.get("date", "1970-01-01T00:00Z")))
    state = str(kind.get("state", "pre"))
    if start > now:
        state = "pre"     # a rewound render never sees later results
    notes = c.get("notes") or [{}]
    return {
        "home": side["home"], "away": side["away"], "start": start, "state": state,
        "period": st.get("period", 0), "detail": str(kind.get("shortDetail", "")).upper(),
        "note": str((notes[0] or {}).get("headline", "")).upper(),
    }

def load_post(season, now):
    games = []
    for wk in POST_WEEKS:
        resp = http.get(SCORES_URL, params = {"seasontype": "3", "week": str(wk), "dates": str(season)}, ttl_seconds = 300)
        if resp["status_code"] != 200 or resp["json"] == None:
            continue
        for e in resp["json"].get("events", []):
            g = parse_game(e, now)
            if g != None and "PRO BOWL" not in g["note"]:
                games.append(g)
    return games

def load_opener(season):
    # next season's first regular-season game: kickoff time and matchup
    resp = http.get(SCORES_URL, params = {"seasontype": "2", "week": "1", "dates": str(season)}, ttl_seconds = 21600)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    first = None
    for e in resp["json"].get("events", []):
        if first == None or str(e.get("date", "")) < str(first.get("date", "")):
            first = e
    if first == None:
        return None
    return {"start": iso_unix(str(first.get("date"))), "matchup": str(first.get("shortName", "")).upper()}

def week_label(season):
    sb = http.get(SCORES_URL, ttl_seconds = 1800)
    if sb["status_code"] != 200 or sb["json"] == None:
        return ""
    j = sb["json"]
    if (j.get("season") or {}).get("year") != season or (j.get("season") or {}).get("type") != 2:
        return ""
    n = (j.get("week") or {}).get("number")
    return "" if n == None else "WEEK " + str(n)

def model(ctx):
    conf = ctx.inputs.get("conference", "AFC")
    if conf not in CHIP:
        conf = "AFC"
    season, month = season_of(ctx)
    d = load_standings(season, conf)
    if d != None and d["played"] == 0:
        # Before the new season kicks off, last season's playoffs.
        season -= 1
        month = 1
        d = load_standings(season, conf)
    if d == None:
        return None
    d["conf"] = conf
    d["season"] = season
    d["seed_of"] = dict(d["all_seeds"])
    for t in d["teams"]:
        d["seed_of"][t["abbr"]] = t["seed"]
    post = load_post(season, ctx.now.unix) if month < 8 else []
    d["post"] = post
    d["mode"] = "post" if any([g["state"] != "pre" for g in post]) else "race"
    d["week"] = week_label(season) if d["mode"] == "race" else ""
    d["offseason"] = winner(super_bowl(d)) != None
    d["opener"] = load_opener(season + 1) if d["offseason"] else None
    return d

ROUND_ORDER = ["WILD CARD", "DIVISIONAL", "CHAMPIONSHIP", "SUPER BOWL"]

def round_ready(d, word):
    # a round's matchups count only once every earlier round is final
    for w in ROUND_ORDER[:ROUND_ORDER.index(word)]:
        for g in d["post"]:
            if w in g["note"] and g["state"] != "post":
                return False
    return True

def round_games(d, word, conf_only):
    out = []
    for g in d["post"]:
        if word in g["note"] and (not conf_only or g["note"].startswith(d["conf"])):
            out.append(g)
    return sorted(out, key = lambda g: g["start"])

def super_bowl(d):
    for g in d["post"]:
        if g["note"].startswith("SUPER BOWL"):
            return g
    return None

def sb_title(sb):
    # "SUPER BOWL LXI" from ESPN's game note
    words = sb["note"].split(" ") if sb != None else []
    return " ".join(words[:3]) if len(words) >= 3 else "SUPER BOWL"

def winner(g):
    if g == None or g["state"] != "post":
        return None
    hs, a = int(g["home"]["score"] or "0"), int(g["away"]["score"] or "0")
    return g["home"] if hs > a else g["away"]

def gb(t, ref):
    # games back of ref; a tie counts as half a win and half a loss
    v = ((ref["w"] - t["w"]) + (t["l"] - ref["l"])) / 2.0
    if v <= 0:
        return "-"
    s = str(v)
    return s[:-2] if s.endswith(".0") else s

# ---------- chrome ----------

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
        ok = True
        for s in strings:
            if c.text_width(s, f) > maxw:
                ok = False
        if ok:
            return f
    return NAME_FONTS[-1]

def fit_name(c, team, maxw):
    # full nickname, else a familiar short form, else the abbreviation
    n = team["nick"]
    if c.text_width(n, NAME_FONTS[-1]) <= maxw:
        return n
    s = SHORT_NAMES.get(n)
    if s != None:
        return s
    return team["abbr"]

def chip(c, word, bg, x):
    w = c.text_width(word, "4x5") + 4
    c.round_rect(x, 0, x + w - 1, 6, 1, fill = bg)
    c.text(word, x + 2, 1, font = "4x5", color = ink_on(bg))
    return x + w

def header(c, d, title, meta = "", meta_color = DIM):
    x = chip(c, d["conf"], CHIP[d["conf"]], PAD)
    c.text(title, x + 3, 1, font = "4x5", color = INK)
    if meta != "":
        c.text(meta, c.width - PAD, 1, font = "4x5", color = meta_color, align = "right")

def message(c, head, sub, head_color):
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

def offline(c):
    message(c, "STANDINGS OFFLINE", "TRYING AGAIN SOON", AMBER)

def tile(c, x, y, h, team, label):
    fill = team_color(team)
    edge = lighten(fill, 45) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + TILE_W - 1, y + h - 1, 1, fill = fill, outline = edge)
    if label != "":
        font = "5x7" if h >= 9 and len(label) == 1 else "4x5"
        ty = y + (h - 7) // 2 if font == "5x7" else y + (h - 5) // 2
        c.text(label, x + TILE_W // 2, ty, font = font, color = ink_on(fill), align = "center")

def small_tile(c, x, y, team, label):
    tile(c, x, y, 7, team, "")
    if label != "":
        c.text(label, x + TILE_W // 2, y + 1, font = "4x5", color = ink_on(team_color(team)), align = "center")

def draw_at(c, cx, y, color):
    c.sprite(AT_SIGN, cx - 2, y, legend = {"g": color})

def draw_mark(c, t, x, y):
    # clinch mark after a name: drawn star for No. 1, else Z/Y/X, red E
    m = t["clinch"]
    if m == "":
        return
    if m == "*":
        c.sprite(STAR, x, y, legend = {"g": GOLD})
    else:
        c.text(m.upper()[:1], x, y, font = "4x5", color = RED if m == "e" else GREEN)

def mark_room(teams):
    # pixels to keep free after the names when any team carries a mark
    return 6 if any([t["clinch"] != "" for t in teams]) else 0

def seed_cell(c, x, y, t, label, maxw, font, color = INK):
    tile(c, x, y, 9, t["abbr"], label)
    nx = x + TILE_W + NAME_GAP
    name = clip(c, t["nick"], font, maxw)
    c.text(name, nx, y + 1, font = font, color = color)
    draw_mark(c, t, nx + c.text_width(name, font) + 1, y)

# ---------- intro ----------

def intro_card(c, kicker, hero, sub, sub_color):
    hw = c.text_width(hero, "10x16")
    x0 = max(PAD, (c.width - (BALL_W + 6 + hw)) // 2)
    hx = x0 + BALL_W + 6
    c.sprite(BALL, x0, 10, legend = BALL_LEGEND)
    c.text(kicker, hx, 1, font = "4x5", color = DIM)
    c.text(hero, hx, 8, font = "10x16", color = INK)
    c.text(sub, c.width // 2, 26, font = "4x5", color = sub_color, align = "center")

def post_stage(d):
    sb = super_bowl(d)
    if sb != None and sb["state"] != "pre":
        return sb_title(sb)
    for word, label in (("CHAMPIONSHIP", "CONFERENCE TITLE GAMES"), ("DIVISIONAL", "DIVISIONAL ROUND"), ("WILD CARD", "WILD CARD ROUND")):
        if any([g["state"] != "pre" for g in round_games(d, word, False)]):
            return label
    return "PLAYOFFS"

def intro(c, ctx):
    d = model(ctx)
    conf = ctx.inputs.get("conference", "AFC")
    if d == None:
        intro_card(c, "NFL " + conf, "PLAYOFF RACE", "STANDINGS OFFLINE", AMBER)
        return
    kicker = "NFL " + str(d["season"]) + " " + d["conf"]
    if d["mode"] == "race":
        intro_card(c, kicker + ("  " + d["week"] if d["week"] else ""), "PLAYOFF RACE", "IF THE SEASON ENDED TODAY", DIM)
        return
    sb = super_bowl(d)
    champ = winner(sb)
    if champ != None:
        intro_card(c, "NFL " + str(d["season"]), "CHAMPIONS", champ["nick"] + " WIN " + sb_title(sb), GOLD)
        return
    intro_card(c, kicker, "PLAYOFFS", post_stage(d), GOLD)

# ---------- race pages ----------

def leaders(c, ctx):
    # Seeds 1-4: the division leaders; No. 1 gets the only bye.
    # Offseason: the champion's banner.
    d = model(ctx)
    if not d:
        return offline(c)
    if d["offseason"]:
        return champion_banner(c, d)
    header(c, d, "DIVISION LEADERS", d["week"])
    lead = d["teams"][:4]
    room = 50 - mark_room(lead)
    font = page_font(c, [t["nick"] for t in lead], room)
    for i, t in enumerate(lead):
        x = PAD + (i % 2) * 94
        y = ROW_Y[i // 2]
        seed_cell(c, x, y, t, str(t["seed"]), room, font)
        c.text(t["div"], x + 86, y + 2, font = "4x5", color = DIM, align = "right")

def race_wildcards(c, d):
    # Seeds 5-7 across one row, record under each name.
    header(c, d, "WILD CARDS", d["week"])
    teams = d["teams"][4:7]
    room = 46 - mark_room(teams)
    font = page_font(c, [t["nick"] for t in teams], room)
    for i, t in enumerate(teams):
        x = PAD + i * 62
        seed_cell(c, x, 10, t, str(t["seed"]), room, font)
        c.text(t["rec"], x + TILE_W + NAME_GAP, 22, font = "4x5", color = DIM)

def race_first_round(c, d):
    # Wild Card Round if the season ended today: 7 @ 2, 6 @ 3, 5 @ 4.
    s = d["teams"]
    header(c, d, "WILD CARD ROUND", "BYE: " + s[0]["nick"], GOLD)
    font = page_font(c, [t["nick"] for t in s[1:7]], 66)
    for i, (lo, hi) in enumerate([(7, 2), (6, 3), (5, 4)]):
        y = SMALL_Y[i]
        a, b = s[lo - 1], s[hi - 1]
        small_tile(c, PAD, y, a["abbr"], str(lo))
        c.text(clip(c, a["nick"], font, 66), PAD + TILE_W + NAME_GAP, y, font = font, color = INK)
        draw_at(c, 92, y + 1, DIM)
        small_tile(c, 100, y, b["abbr"], str(hi))
        c.text(clip(c, b["nick"], font, 66), 100 + TILE_W + NAME_GAP, y, font = font, color = INK)

def stat_rows(c, d, title, teams, ref):
    header(c, d, title)
    right = c.width - PAD
    c.text("W-L", 112, 1, font = "4x5", color = DIM, align = "right")
    c.text("GB", 138, 1, font = "4x5", color = DIM, align = "right")
    c.text("STRK", right, 1, font = "4x5", color = DIM, align = "right")
    font = page_font(c, [t["nick"] for t in teams], 60)
    for i, t in enumerate(teams[:3]):
        y = SMALL_Y[i]
        small_tile(c, PAD, y, t["abbr"], str(t["seed"]))
        name = clip(c, t["nick"], font, 60)
        c.text(name, PAD + TILE_W + NAME_GAP, y, font = font, color = INK)
        draw_mark(c, t, PAD + TILE_W + NAME_GAP + c.text_width(name, font) + 1, y)
        c.text(t["rec"], 112, y + 1, font = "4x5", color = DIM, align = "right")
        c.text(gb(t, ref), 138, y, font = "5x7", color = INK, align = "right")
        sk = t["streak"]
        c.text(sk, right, y + 1, font = "4x5", color = GREEN if sk.startswith("W") else (RED if sk.startswith("L") else DIM), align = "right")

def division_pair(c, d, names):
    header(c, d, names[0] + " / " + names[1])
    for k, name in enumerate(names):
        rows = []
        for dv in d["divs"]:
            if dv[0] == name:
                rows = dv[1]
        x = PAD + k * 94
        for i, t in enumerate(rows[:4]):
            y = 8 + i * 6
            tile(c, x, y, 5, t["abbr"], "")
            col = INK if i == 0 else DIM
            # a short form only when name + mark would crowd the record
            room = 86 - c.text_width(t["rec"], "4x5") - 3 - TILE_W - 2 - (6 if t["clinch"] != "" else 0)
            name_txt = t["nick"]
            if c.text_width(name_txt, "4x5") > room and SHORT_NAMES.get(name_txt) != None:
                name_txt = SHORT_NAMES[name_txt]
            name_txt = clip(c, name_txt, "4x5", room)
            c.text(name_txt, x + TILE_W + 2, y, font = "4x5", color = col)
            draw_mark(c, t, x + TILE_W + 3 + c.text_width(name_txt, "4x5"), y)
            c.text(t["rec"], x + 86, y, font = "4x5", color = col, align = "right")
    c.line(97, 8, 97, 31, STRUCT)

# ---------- postseason pages ----------

def game_status(g, now):
    if g["state"] == "post":
        return "FINAL", DIM
    if g["state"] == "in":
        det = g["detail"]
        if "HALF" in det:
            return "HALF", GREEN
        p = g["period"]
        return ("OT" if p > 4 else "Q" + str(p)), GREEN
    if et_day(g["start"]) == et_day(now):
        return et_clock(g["start"]), INK
    return weekday(g["start"]), DIM

def game_row(c, d, g, y, font, now):
    # lower seed @ higher seed, scores, status: winner green, loser dimmed
    w = winner(g)
    seed = d["seed_of"]
    for side, x, score_x in ((g["away"], PAD, 78), (g["home"], 87, 159)):
        col = INK if w == None else (GREEN if w["abbr"] == side["abbr"] else DIM)
        s = seed.get(side["abbr"])
        small_tile(c, x, y, side["abbr"], str(s) if s != None and s < 10 else "")
        c.text(fit_name(c, side, 46), x + TILE_W + NAME_GAP, y, font = font, color = col)
        if g["state"] != "pre":
            c.text(side["score"], score_x, y, font = "5x7", color = col, align = "right")
    draw_at(c, 83, y + 1, DIM)
    if g["state"] != "post":
        st, sc = game_status(g, now)
        c.text(st, c.width - PAD, y + 1, font = "4x5", color = sc, align = "right")

def round_page(c, d, title, word, now, empty):
    games = round_games(d, word, True)
    done = len(games) > 0 and all([g["state"] == "post" for g in games])
    header(c, d, title, "FINAL" if done else "", GOLD)
    known = [g for g in games if g["home"]["abbr"] in TEAM_COLORS and g["away"]["abbr"] in TEAM_COLORS] if round_ready(d, word) else []
    if not known:
        return message(c, "NOT SET YET", empty, INK)
    names = []
    for g in known:
        names.append(fit_name(c, g["away"], 46))
        names.append(fit_name(c, g["home"], 46))
    font = page_font(c, names, 46)
    for i, g in enumerate(known[:3]):
        game_row(c, d, g, SMALL_Y[i], font, now)

def board(c, d, chip_word, chip_color, title, g, now, empty):
    # one big game: two rows, scores at the right, status in the header
    x = chip(c, chip_word, chip_color, PAD)
    c.text(title, x + 3, 1, font = "4x5", color = INK)
    if g == None or g["home"]["abbr"] not in TEAM_COLORS or g["away"]["abbr"] not in TEAM_COLORS or not round_ready(d, "SUPER BOWL" if g["note"].startswith("SUPER BOWL") else "CHAMPIONSHIP"):
        return message(c, "NOT SET YET", empty, INK)
    st, sc = game_status(g, now)
    if g["state"] == "pre" and st in DAY_NAMES:
        st = st + " " + et_clock(g["start"])
    c.text(st, c.width - PAD, 1, font = "4x5", color = GOLD if st == "FINAL" else sc, align = "right")
    w = winner(g)
    for i, side in enumerate((g["away"], g["home"])):
        y = ROW_Y[i]
        col = INK if w == None else (GREEN if w["abbr"] == side["abbr"] else DIM)
        s = d["seed_of"].get(side["abbr"])
        tile(c, PAD, y, 9, side["abbr"], str(s) if s != None else "")
        c.text(side["nick"], PAD + TILE_W + NAME_GAP, y + 1, font = "5x7", color = col)
        if g["state"] != "pre":
            c.text(side["score"], c.width - PAD, y + 1, font = "5x7", color = col, align = "right")


# ---------- offseason pages ----------

def champion_banner(c, d):
    # The whole screen in the Super Bowl winner's colors.
    sb = super_bowl(d)
    champ = winner(sb)
    other = sb["away"] if champ["abbr"] == sb["home"]["abbr"] else sb["home"]
    fill = team_color(champ["abbr"])
    alt = TEAM_ALT.get(champ["abbr"], "#FFFFFF")
    dark = "#" + "".join([HEX[(int(fill[i:i + 2], 16) * 45 // 100) // 16] + HEX[(int(fill[i:i + 2], 16) * 45 // 100) % 16] for i in (1, 3, 5)])
    c.gradient_rect(0, 0, c.width - 1, c.height - 1, fill, dark, horizontal = True)
    c.rect(0, 0, c.width - 1, 1, fill = alt)
    c.rect(0, c.height - 2, c.width - 1, c.height - 1, fill = alt)
    c.sprite(TROPHY, 6, 9, legend = TROPHY_LEGEND)
    c.text(sb_title(sb) + " CHAMPIONS", 22, 4, font = "4x5", color = GOLD)
    name = champ["nick"]
    font = "10x16_bold" if c.text_width(name, "10x16_bold") <= 116 else "5x7"
    c.text_stroke(name, 22, 11 if font == "10x16_bold" else 15, font = font, color = INK, stroke = dark)
    hs, aws = int(sb["home"]["score"] or "0"), int(sb["away"]["score"] or "0")
    c.text(str(max(hs, aws)) + "-" + str(min(hs, aws)), c.width - PAD, 12, font = "5x7", color = INK, align = "right")
    c.text("V " + other["nick"], c.width - PAD, 21, font = "4x5", color = ink_on(fill), align = "right")

def road_to_title(c, d):
    # The champion's playoff run, round by round.
    sb = super_bowl(d)
    champ = winner(sb)
    fill = team_color(champ["abbr"])
    c.gradient_rect(0, 0, c.width - 1, 6, fill, "#000000")
    c.text("ROAD TO THE TITLE", 2, 1, font = "4x5", color = GOLD)
    c.text(champ["nick"], c.width - PAD, 1, font = "4x5", color = INK, align = "right")
    rows = []
    seed = d["seed_of"].get(champ["abbr"], 99)
    for word, label in (("WILD CARD", "WILD CARD"), ("DIVISIONAL", "DIVISIONAL"), ("CHAMPIONSHIP", "CONFERENCE"), ("SUPER BOWL", "SUPER BOWL")):
        mine = [g for g in d["post"] if word in g["note"] and champ["abbr"] in (g["home"]["abbr"], g["away"]["abbr"])]
        if mine:
            rows.append((label, mine[0]))
        elif word == "WILD CARD" and seed == 1:
            rows.append((label, None))
    for i, (label, g) in enumerate(rows[:4]):
        y = 8 + i * 6
        c.text(label, 2, y, font = "4x5", color = GOLD if label == "SUPER BOWL" else DIM)
        if g == None:
            c.text("BYE AS THE NO. 1 SEED", 58, y, font = "4x5", color = DIM)
            continue
        opp = g["away"] if g["home"]["abbr"] == champ["abbr"] else g["home"]
        s = d["seed_of"].get(opp["abbr"])
        small_tile(c, 58, y - 1, opp["abbr"], str(s) if s != None else "")
        c.text(opp["nick"], 58 + TILE_W + NAME_GAP, y, font = "4x5", color = INK)
        hs, aws = int(g["home"]["score"] or "0"), int(g["away"]["score"] or "0")
        c.text(str(max(hs, aws)) + "-" + str(min(hs, aws)), c.width - PAD, y, font = "4x5", color = GREEN, align = "right")

def countdown(c, d, ctx):
    # Days until next season's opener.
    c.fill("#000000")
    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#030A1A", "#0B2A5A", horizontal = False)
    nxt = d["season"] + 1
    c.text("SEE YOU IN " + str(nxt), 4, 3, font = "4x5", color = GOLD)
    op = d["opener"]
    if op == None:
        c.text("SCHEDULE COMING", 4, 12, font = "5x7", color = INK)
        c.text("KICKOFF IN SEPTEMBER", 4, 22, font = "4x5", color = DIM)
        return
    left = et_day(op["start"]) - et_day(ctx.now.unix)
    if left > 0:
        c.text_stroke(str(left), 4, 11, font = "10x16_bold", color = INK, stroke = "#030A1A")
        x = 8 + c.text_width(str(left), "10x16_bold")
        c.text("DAY TO" if left == 1 else "DAYS TO", x, 13, font = "4x5", color = DIM)
        c.text("KICKOFF", x, 20, font = "4x5", color = DIM)
    else:
        c.text("SEASON IS", 4, 12, font = "5x7", color = INK)
        c.text("UNDERWAY", 4, 21, font = "5x7", color = GREEN)
    c.line(104, 3, 104, 28, "#2E4A7A")
    c.text("KICKOFF", 110, 3, font = "4x5", color = DIM)
    y, m, dd = civil_from_days(et_day(op["start"]))
    months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    c.text(weekday(op["start"]) + " " + months[m - 1] + " " + str(dd), 110, 10, font = "5x7", color = INK)
    c.text(op["matchup"].replace("@", "AT"), 110, 21, font = "4x5", color = "#6FA8DC")

# ---------- pages ----------

def wildcards(c, ctx):
    d = model(ctx)
    if not d:
        return offline(c)
    if d["mode"] == "post":
        return round_page(c, d, "WILD CARD ROUND", "WILD CARD", ctx.now.unix, "SEEDS SET AFTER WEEK 18")
    race_wildcards(c, d)

def first_round(c, ctx):
    d = model(ctx)
    if not d:
        return offline(c)
    if d["mode"] == "post":
        return round_page(c, d, "DIVISIONAL ROUND", "DIVISIONAL", ctx.now.unix, "AFTER THE WILD CARD ROUND")
    race_first_round(c, d)

def hunt(c, ctx):
    # Race: the next three teams behind the 7 seed. Postseason: the
    # conference title game.
    d = model(ctx)
    if not d:
        return offline(c)
    if d["mode"] == "post":
        games = round_games(d, "CHAMPIONSHIP", True)
        return board(c, d, d["conf"], CHIP[d["conf"]], "CHAMPIONSHIP", games[0] if games else None, ctx.now.unix, "AFTER THE DIVISIONAL ROUND")
    stat_rows(c, d, "IN THE HUNT", d["teams"][7:10], d["teams"][6])

def top_seed(c, ctx):
    # Race: the race for No. 1 and the only bye. Postseason: the Super Bowl.
    d = model(ctx)
    if not d:
        return offline(c)
    if d["mode"] == "post":
        sb = super_bowl(d)
        return board(c, d, "NFL", "#013369", sb_title(sb), sb, ctx.now.unix, "AFTER THE CONFERENCE TITLE GAMES")
    stat_rows(c, d, "NO. 1 SEED RACE", d["teams"][:3], d["teams"][0])

def div1(c, ctx):
    d = model(ctx)
    if not d:
        return offline(c)
    if d["offseason"]:
        return road_to_title(c, d)
    division_pair(c, d, ["EAST", "NORTH"])

def div2(c, ctx):
    d = model(ctx)
    if not d:
        return offline(c)
    if d["offseason"]:
        return countdown(c, d, ctx)
    division_pair(c, d, ["SOUTH", "WEST"])
