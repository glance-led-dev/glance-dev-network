# NFL Bye Week Tracker
#
# Which clubs are resting, the week they rest, and - for your club - how long
# until it does. The bye is the one week a fantasy lineup can be wrecked by a
# schedule rather than an injury, so the app answers three questions:
#
#   thisweek  Who is on bye right now - the clubs' logos in a row.
#   nextweek  Who is on bye next week, so the lineup can be planned ahead.
#   myteam    One club's bye week, a countdown to it and the game it comes
#             back for, over its whole season as an 18-cell results strip.
#
# DESIGN. The bye is sleep, and the crescent moon is the app's mark. On the
# week pages a small moon with a trail of Z's leads the chip row, and the
# logos ARE the content - 40 x 24 pixel art, never scaled, laid out as a
# centered row with a hairline between clubs; when a slot is wide enough (one
# or two clubs) the nickname sits beside the logo. Four logos fill the safe
# zone, so a five- or six-bye week splits into two frames (a 1/2 counter says
# so) and its team count turns red-orange: that is the lineup-wrecking week.
# The pill says how urgent the week is: amber for THIS week (bench those
# players), sky blue for NEXT week (plan).
#
# A week without byes is good news: the NFL shield, NO BYES in green, and the
# whole league as a 32-tile mosaic in club colours, eight division columns,
# AFC | NFC - every tile lit because every club plays. Out of season the same
# mosaic is dimmed: the league is resting.
#
# On the club page the moon grows into the hero: a big crescent beside the
# bye week's number, under a BYE WEEK pill in the countdown colour (amber
# this week, sky blue ahead, green once it is behind you). The countdown and
# the return game ("BACK @ SEA") stack on the right. The strip beneath is the
# club's season: won weeks green, lost red, a tie white, weeks ahead dark,
# and in the bye week's cell a tiny moon; a white tick under a cell marks
# the current week.
#
# Data: ESPN's scoreboard (site.web host). With no params it is the current
# week, and `week.teamsOnBye` lists the resting clubs; `?week=N` gives any
# other week. The club page reads the club's schedule: its bye is the one
# regular-season week missing from the 17 games (ESPN's top-level `byeWeek`
# was stale for 2026 and is only a fallback), and each finished game gives
# a strip cell its W / L / T. Byes are fixed for a season, so specific weeks
# and schedules cache for 12 hours; only the "which week is it" call (the
# default scoreboard) is kept for one hour. Refresh is 300 s so a six-bye
# week's two frames both get seen.

SCOREBOARD = "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"
SCHEDULE = "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/teams/"
HEADERS = {"User-Agent": "glance-nfl-bye-week-tracker (glance-led.dev)"}
NOW_TTL = 3600
FIXED_TTL = 43200
LAST_WEEK = 18
GAMES = 17
FRAME_SECONDS = 300
HEAVY = 5              # a week with this many byes is the lineup-wrecker

# ------------------------------------------------------------------ layout
# 192 wide, safe zone x 10..181. Chip row y 0..6, logos y 8..31.
SAFE_L = 10
SAFE_R = 181
SAFE_W = SAFE_R - SAFE_L + 1
LOGO_W = 40
LOGO_H = 24
LOGO_Y = 8
# Club page: logo x 10..49, text x 54..181, week strip y 26..30, tick y 31.
CLUB_TX = 54
STRIP_Y = 25
CELL = 6

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
C_NOW = "#FFB000"      # bye this week
C_NEXT = "#78DCFF"     # bye next week, or later
C_DONE = "#2FE06F"     # bye is behind you / no byes this week
C_HEAVY = "#FF5A1F"    # five or six clubs resting at once
C_PAST = "#3A4356"     # hairlines, played weeks without a result
C_AHEAD = "#161C2A"    # weeks still to come
C_WIN = "#1FC45C"
C_LOSS = "#E8352B"
MOON = "#FFE08A"
MOON_SHADE = "#B89A48"

# Full name -> ESPN id and abbreviation (the abbreviation is the logo file).
TEAMS = {
    "ARIZONA CARDINALS": ["22", "ARI"], "ATLANTA FALCONS": ["1", "ATL"],
    "BALTIMORE RAVENS": ["33", "BAL"], "BUFFALO BILLS": ["2", "BUF"],
    "CAROLINA PANTHERS": ["29", "CAR"], "CHICAGO BEARS": ["3", "CHI"],
    "CINCINNATI BENGALS": ["4", "CIN"], "CLEVELAND BROWNS": ["5", "CLE"],
    "DALLAS COWBOYS": ["6", "DAL"], "DENVER BRONCOS": ["7", "DEN"],
    "DETROIT LIONS": ["8", "DET"], "GREEN BAY PACKERS": ["9", "GB"],
    "HOUSTON TEXANS": ["34", "HOU"], "INDIANAPOLIS COLTS": ["11", "IND"],
    "JACKSONVILLE JAGUARS": ["30", "JAX"], "KANSAS CITY CHIEFS": ["12", "KC"],
    "LAS VEGAS RAIDERS": ["13", "LV"], "LOS ANGELES CHARGERS": ["24", "LAC"],
    "LOS ANGELES RAMS": ["14", "LAR"], "MIAMI DOLPHINS": ["15", "MIA"],
    "MINNESOTA VIKINGS": ["16", "MIN"], "NEW ENGLAND PATRIOTS": ["17", "NE"],
    "NEW ORLEANS SAINTS": ["18", "NO"], "NEW YORK GIANTS": ["19", "NYG"],
    "NEW YORK JETS": ["20", "NYJ"], "PHILADELPHIA EAGLES": ["21", "PHI"],
    "PITTSBURGH STEELERS": ["23", "PIT"], "SAN FRANCISCO 49ERS": ["25", "SF"],
    "SEATTLE SEAHAWKS": ["26", "SEA"], "TAMPA BAY BUCCANEERS": ["27", "TB"],
    "TENNESSEE TITANS": ["10", "TEN"], "WASHINGTON COMMANDERS": ["28", "WSH"],
}
NICK = {TEAMS[k][1]: k.split(" ")[len(k.split(" ")) - 1] for k in TEAMS}

# The lint needs every asset path as a literal, so the logos live in a dict.
LOGOS = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png",
    "BUF": "BUF.png", "CAR": "CAR.png", "CHI": "CHI.png",
    "CIN": "CIN.png", "CLE": "CLE.png", "DAL": "DAL.png",
    "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png",
    "KC": "KC.png", "LV": "LV.png", "LAC": "LAC.png",
    "LAR": "LAR.png", "MIA": "MIA.png", "MIN": "MIN.png",
    "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png",
    "SF": "SF.png", "SEA": "SEA.png", "TB": "TB.png",
    "TEN": "TEN.png", "WSH": "WSH.png", "NFL": "NFL.png",
}
# ESPN has written Washington both ways over the years.
ALIAS = {"WAS": "WSH", "LA": "LAR", "JAC": "JAX"}

# The league by division, AFC then NFC (East, North, South, West), each
# club in an LED-tuned version of its colours - navies are lifted to a blue
# that survives on black, and where a primary is too dark to read the
# brighter club colour is used (SEA green, PIT gold, CHI orange).
DIVISIONS = [
    ["BUF", "MIA", "NE", "NYJ"], ["BAL", "CIN", "CLE", "PIT"],
    ["HOU", "IND", "JAX", "TEN"], ["DEN", "KC", "LV", "LAC"],
    ["DAL", "NYG", "PHI", "WSH"], ["CHI", "DET", "GB", "MIN"],
    ["ATL", "CAR", "NO", "TB"], ["ARI", "LAR", "SF", "SEA"],
]
CLUB = {
    "BUF": "#2B63E6", "MIA": "#00B8C2", "NE": "#C8102E", "NYJ": "#1E9A5E",
    "BAL": "#6A45D8", "CIN": "#FB4F14", "CLE": "#9A5428", "PIT": "#FFB612",
    "HOU": "#D2203A", "IND": "#2D74DA", "JAX": "#00A3B4", "TEN": "#4B92DB",
    "DEN": "#FB6A14", "KC": "#E31837", "LV": "#A5ACAF", "LAC": "#2AA3F0",
    "DAL": "#3067DE", "NYG": "#2A4FD0", "PHI": "#0E9A86", "WSH": "#B8323A",
    "CHI": "#E0561A", "DET": "#1A92E2", "GB": "#FFB612", "MIN": "#8448DC",
    "ATL": "#E0263E", "CAR": "#1AA3EA", "NO": "#D3BC8D", "TB": "#E0201A",
    "ARI": "#CC2548", "LAR": "#FFC20E", "SF": "#D8211A", "SEA": "#69BE28",
}

# 15 x 7: a crescent moon, a big Z and a small one - the club is asleep.
SLEEP = """
.MMM........zzz
MMM..........z.
MM....ZZZZZ.zzz
MM.......Z.....
MM......Z......
MMM....Z.......
.MMM..ZZZZZ....
"""
SLEEP_W = 15

def sleep_icon(c, x, color = MOON):
    c.sprite(SLEEP, x, 0, legend = {"M": color, "Z": INK, "z": DIM})

# 11 x 16: the hero crescent on the club page, lit edge and shaded inner rim.
BIG_MOON = """
....MMMM...
..MMMMMs...
.MMMMMs....
.MMMMs.....
MMMMs......
MMMMs......
MMMMs......
MMMMs......
MMMMs......
MMMMs......
MMMMs......
MMMMMs.....
.MMMMMs....
.MMMMMMs...
..MMMMMMMs.
....MMMMM..
"""
BIG_MOON_W = 11

# 5 x 5: the bye week's cell on the season strip.
CELL_MOON = """
.MMM.
MM...
MM...
MM...
.MMM.
"""

# ------------------------------------------------------------- text tools
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}

HEXD = "0123456789abcdef"

def ink_for(fill):
    """Black type on a bright pill, white on a dark one (brightness 150)."""
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def pill(c, word, fill, x):
    return c.badge(word, x, 0, color = ink_for(fill), bg = fill, font = "4x5")

def pill_w(c, word):
    return c.text_width(word, "4x5") + 4

def rail(c, color):
    # x 6..7: nothing lights x 0..5 or 186..191, so the app never runs
    # into its neighbours on a scroll wall.
    c.rect(6, 0, 7, 31, fill = color)

# ------------------------------------------------------------------ feeds
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def as_list(v):
    return v if type(v) == "list" else []

def to_int(v, fallback = -1):
    if type(v) == "int":
        return v
    if type(v) == "float":
        return int(v)
    t = str(v).strip()
    if t == "" or not t.isdigit():
        return fallback
    return int(t)

def abbr(a):
    a = str(a).upper()
    return ALIAS.get(a, a)

def byes_of(j):
    out = []
    for t in as_list(get(get(j, "week", {}), "teamsOnBye", [])):
        a = abbr(get(t, "abbreviation", ""))
        if a in LOGOS and a != "NFL" and a not in out:
            out.append(a)
    return out

def failed(r):
    if r["status_code"] == 0:
        return {"ok": False, "head": "ESPN OFFLINE", "sub": "CHECKING AGAIN SOON"}
    return {"ok": False, "head": "ESPN FEED ERROR", "sub": "HTTP " + str(r["status_code"]) + " - RETRY SOON"}

def fetch_now():
    """The current week, season and season type (1 pre, 2 regular, 3 post,
    4 off), plus this week's byes - all from the default scoreboard."""
    r = http.get(SCOREBOARD, headers = HEADERS, ttl_seconds = NOW_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return failed(r)
    j = r["json"]
    season = get(j, "season", {})
    return {"ok": True, "week": to_int(get(get(j, "week", {}), "number", -1)),
            "type": to_int(get(season, "type", 0), 0), "year": to_int(get(season, "year", 0), 0),
            "byes": byes_of(j)}

def fetch_week(year, week):
    params = {"week": str(week), "seasontype": "2"}
    if year > 0:
        params["dates"] = str(year)
    r = http.get(SCOREBOARD, params = params, headers = HEADERS, ttl_seconds = FIXED_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return failed(r)
    return {"ok": True, "byes": byes_of(r["json"])}

def game_of(e, tid):
    """One schedule event -> [week, result W/L/T or "", opponent, "VS" or "@"],
    or None when it is not a regular-season game this club plays in."""
    if to_int(get(get(e, "seasonType", {}), "type", 0), 0) != 2:
        return None
    wk = to_int(get(get(e, "week", {}), "number", -1))
    comps = as_list(get(e, "competitions", []))
    if wk < 1 or wk > LAST_WEEK or len(comps) == 0:
        return None
    comp = comps[0]
    me = None
    opp = None
    for cp in as_list(get(comp, "competitors", [])):
        cid = str(get(cp, "id", get(get(cp, "team", {}), "id", "")))
        if cid == tid:
            me = cp
        else:
            opp = cp
    if me == None:
        return None
    res = ""
    if get(get(get(comp, "status", {}), "type", {}), "completed", False) == True:
        if get(me, "winner", False) == True:
            res = "W"
        elif get(opp, "winner", False) == True:
            res = "L"
        else:
            res = "T"
    at = "@" if get(me, "homeAway", "") == "away" and get(comp, "neutralSite", False) != True else "VS"
    return [wk, res, abbr(get(get(opp, "team", {}), "abbreviation", "")), at]

def fetch_club(tid, year):
    params = {"season": str(year)} if year > 0 else {}
    r = http.get(SCHEDULE + tid + "/schedule", params = params, headers = HEADERS, ttl_seconds = FIXED_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return failed(r)
    j = r["json"]
    games = {}
    for e in as_list(get(j, "events", [])):
        g = game_of(e, tid)
        if g != None:
            games[g[0]] = g
    # The bye is the one week with no game. ESPN's own `byeWeek` field was
    # stale for 2026 (ATL, BUF, CHI), so it is only the fallback for a
    # schedule that is not yet 17 games long.
    bye = -1
    missing = [w for w in range(1, LAST_WEEK + 1) if w not in games]
    if len(games) == GAMES and len(missing) == 1:
        bye = missing[0]
    else:
        bye = to_int(get(j, "byeWeek", -1))
    return {"ok": True, "bye": bye, "games": games,
            "record": str(get(get(j, "team", {}), "recordSummary", ""))}

# ------------------------------------------------------------ shared chrome
def fail_screen(c, d):
    c.fill("black")
    rail(c, OFFLINE)
    sleep_icon(c, SAFE_L, DIM)
    hf = fit(c, d["head"], ["6x8", "5x7", "4x5"], SAFE_W)
    c.text(hf[1], 96, 11, font = hf[0], color = "amber", align = "center")
    sf = fit(c, d["sub"], ["4x5"], SAFE_W)
    c.text(sf[1], 96, 23, font = sf[0], color = DIM, align = "center")

MOSAIC_CELL = 4
MOSAIC_W = 8 * (MOSAIC_CELL + 1) + 1    # 41: eight columns, 2 px at AFC | NFC

def mosaic(c, x, y, lit):
    """The 32 clubs as a 4-row, 8-column block of tiles, one column per
    division. Lit tiles wear the club colour; unlit ones a quarter of it."""
    for d in range(8):
        cx = x + d * (MOSAIC_CELL + 1) + (1 if d >= 4 else 0)
        for r in range(4):
            col = CLUB[DIVISIONS[d][r]]
            cy = y + r * (MOSAIC_CELL + 1)
            c.rect(cx, cy, cx + MOSAIC_CELL - 1, cy + MOSAIC_CELL - 1,
                   fill = col if lit else color.dim(col, 30))

def shield_screen(c, word, color_, head, sub, label = "", head_color = "", lit = False):
    """The NFL shield on the left, a word in the chip row, a two-line message,
    and the league mosaic on the right - lit when all 32 clubs play."""
    c.fill("black")
    sleep_icon(c, SAFE_L)
    pill(c, word, color_, SAFE_L + SLEEP_W + 3)
    if label != "":
        c.text(label, SAFE_L + SLEEP_W + 3 + pill_w(c, word) + 4, 1, font = "4x5", color = INK)
    c.image(LOGOS["NFL"], SAFE_L, LOGO_Y)
    mx = SAFE_R - MOSAIC_W + 1
    mosaic(c, mx, LOGO_Y + 3, lit)
    tx = SAFE_L + LOGO_W + 5
    tw = mx - 4 - tx
    hf = fit(c, head, ["10x16", "9x12", "6x8", "5x7"], tw)
    c.text(hf[1], tx, 9, font = hf[0], color = head_color if head_color != "" else color_)
    sf = fit(c, sub, ["5x7", "4x5"], tw)
    c.text(sf[1], tx, 32 - INKH[sf[0]], font = sf[0], color = DIM)

def season_word(t):
    return {1: "PRESEASON", 3: "PLAYOFFS", 4: "OFFSEASON"}.get(t, "OFFSEASON")

# -------------------------------------------------------------- week pages
def frames_of(teams):
    """At most four logos fit the safe zone. More than four split into even
    frames - six byes are 3 + 3, not 4 + 2."""
    n = len(teams)
    k = (n + 3) // 4
    per = (n + k - 1) // k
    return [teams[i * per:(i + 1) * per] for i in range(k)]

def week_chip(c, when, week, color_, metas, meta_color):
    """The moon, a pill saying which week this is relative to now (THIS WEEK
    / NEXT WEEK), the week number in white, and `metas` right-aligned. The
    right side is measured first; 'BYES' leaves the label before any meta
    is shed, so a six-bye week keeps '6 TEAMS  1/2'."""
    x = SAFE_L + SLEEP_W + 3
    word = when + " WEEK"
    lx = x + pill_w(c, word) + 4
    pill(c, word, color_, x)
    for keep in range(len(metas), -1, -1):
        parts = metas[:keep]
        rw = c.text_width("  ".join(parts[::-1]), "4x5") + 4 if keep > 0 else 0
        for label in ["WEEK " + str(week) + " BYES", "WEEK " + str(week)]:
            if lx + c.text_width(label, "4x5") <= SAFE_R - rw or (keep == 0 and label.find("BYES") < 0):
                c.text(label, lx, 1, font = "4x5", color = INK)
                # The team count (last meta) carries the heavy-week alarm;
                # the frame counter stays slate.
                rx = SAFE_R
                for i in range(keep):
                    p = parts[i]
                    c.text(p, rx, 1, font = "4x5", color = meta_color if i == len(metas) - 1 else DIM, align = "right")
                    rx = rx - c.text_width(p, "4x5") - c.text_width("  ", "4x5")
                return

def bye_row(c, ctx, week, teams, color_, when):
    c.fill("black")
    frames = frames_of(teams)
    fi = (ctx.now.unix // FRAME_SECONDS) % len(frames)
    shown = frames[fi]

    # Chip row: moon, the week pill, and on the right the count (and which
    # frame this is when the week needs two). The count turns red-orange on
    # a five- or six-bye week.
    sleep_icon(c, SAFE_L)
    metas = [str(fi + 1) + "/" + str(len(frames))] if len(frames) > 1 else []
    metas = metas + [str(len(teams)) + (" TEAM" if len(teams) == 1 else " TEAMS")]
    week_chip(c, when, week, color_, metas, C_HEAVY if len(teams) >= HEAVY else DIM)

    # Logo row: equal slots across the safe zone. A slot wide enough for a
    # name gets the nickname beside the logo, all in one shared font so the
    # row reads as a set ('BUCCANEERS' is 59 px at 5x7, 49 at 4x5).
    k = len(shown)
    slot = SAFE_W // k
    namew = slot - LOGO_W - 8
    font = ""
    if namew >= 20:
        for f in ["10x16", "9x12", "6x8", "5x7", "4x5"]:
            if max([c.text_width(NICK[t], f) for t in shown]) <= namew:
                font = f
                break
    if font == "" and k == 4:
        # Four logos need 160 of 172 px: justify them edge to edge so every
        # hairline keeps a 1 px gap to the art on both sides (43 px slots
        # put some logos' edge columns right against the line).
        gap = (SAFE_W - k * LOGO_W) // (k - 1)
        for i in range(k):
            lx = SAFE_L + i * (LOGO_W + gap)
            c.image(LOGOS[shown[i]], lx, LOGO_Y)
            if i > 0:
                c.vline(lx - 1 - (gap - 1) // 2, LOGO_Y + 3, LOGO_Y + LOGO_H - 4, color = C_PAST)
        return
    for i in range(k):
        t = shown[i]
        x0 = SAFE_L + i * slot
        if font != "":
            w = LOGO_W + 4 + max([c.text_width(NICK[s], font) for s in shown])
            lx = x0 + (slot - w) // 2
            c.image(LOGOS[t], lx, LOGO_Y)
            c.text(NICK[t], lx + LOGO_W + 4, LOGO_Y + (LOGO_H - INKH[font]) // 2, font = font, color = INK)
        else:
            c.image(LOGOS[t], x0 + (slot - LOGO_W) // 2, LOGO_Y)
        if i > 0:
            c.vline(x0, LOGO_Y + 3, LOGO_Y + LOGO_H - 4, color = C_PAST)

def week_page(c, ctx, ahead):
    now = fetch_now()
    if not now["ok"]:
        fail_screen(c, now)
        return
    if now["type"] != 2 or now["week"] < 1:
        # Out of the regular season the pill names the phase in slate, the
        # hero says what that means for byes, and the league mosaic is dim.
        word = season_word(now["type"])
        # Subs are at most 13 characters: 5x7 beside the mosaic.
        msg = {1: ["NO BYES YET", "FROM WEEK 5"],
               3: ["BYES DONE", "18 WEEKS DONE"]}.get(now["type"], ["ALL REST", "BACK IN SEPT"])
        shield_screen(c, word, DIM, msg[0], msg[1], "", INK)
        return
    week = now["week"] + ahead
    when = "NEXT" if ahead > 0 else "THIS"
    color_ = C_NEXT if ahead > 0 else C_NOW
    if week > LAST_WEEK:
        shield_screen(c, "NEXT WEEK", C_DONE, "PLAYOFFS", "NO MORE BYES", "AFTER WEEK " + str(LAST_WEEK), "", True)
        return
    if ahead == 0:
        teams = now["byes"]
    else:
        d = fetch_week(now["year"], week)
        if not d["ok"]:
            fail_screen(c, d)
            return
        teams = d["byes"]
    if len(teams) == 0:
        shield_screen(c, when + " WEEK", C_DONE, "NO BYES", "ALL 32 PLAY", "WEEK " + str(week), "", True)
        return
    bye_row(c, ctx, week, teams, color_, when)

def thisweek(c, ctx):
    week_page(c, ctx, 0)

def nextweek(c, ctx):
    week_page(c, ctx, 1)

# ------------------------------------------------------------ club page
def countdown(bye, week, stype):
    """[countdown line, colour] beside the hero."""
    if stype == 1:
        return ["PRESEASON", DIM]
    if stype == 3:
        return ["BYES DONE", C_DONE]
    if stype != 2 or week < 1:
        return ["SEASON OVER", DIM]
    if bye == week:
        return ["THIS WEEK", C_NOW]
    if bye == week + 1:
        return ["NEXT WEEK", C_NEXT]
    if bye > week:
        return ["IN " + str(bye - week) + " WEEKS", C_NEXT]
    return ["BYE DONE", C_DONE]

def second_line(d, bye, week, stype):
    """Under the countdown: the game the club comes back for while the bye
    is ahead (or this week), else how many games are left to play."""
    games = d["games"]
    if (stype == 1 or (stype == 2 and bye >= week)) and (bye + 1) in games:
        g = games[bye + 1]
        if g[2] != "":
            return "BACK " + g[3] + " " + g[2]
    if stype == 2 and week > 0 and len(games) == GAMES:
        left = len([w for w in games if games[w][1] == ""])
        if left > 0:
            return str(left) + (" GAME LEFT" if left == 1 else " GAMES LEFT")
    return ""

def myteam(c, ctx):
    name = str(ctx.inputs.get("team", "KANSAS CITY CHIEFS")).strip().upper()
    if name not in TEAMS:
        name = "KANSAS CITY CHIEFS"
    tid = TEAMS[name][0]
    ab = TEAMS[name][1]
    now = fetch_now()
    if not now["ok"]:
        fail_screen(c, now)
        return
    d = fetch_club(tid, now["year"])
    if not d["ok"]:
        fail_screen(c, d)
        return
    bye = d["bye"]
    if bye < 1 or bye > LAST_WEEK:
        fail_screen(c, {"head": "NO BYE LISTED", "sub": NICK[ab] + " SCHEDULE OUT IN MAY"})
        return
    week = now["week"] if now["type"] == 2 else -1
    cd = countdown(bye, week, now["type"])

    c.fill("black")
    c.image(LOGOS[ab], SAFE_L, 4)

    # Chip row: BYE WEEK pill in the countdown colour, the club, its record
    # (measured first, right-aligned).
    pill(c, "BYE WEEK", cd[1], CLUB_TX)
    nx = CLUB_TX + pill_w(c, "BYE WEEK") + 4
    rec = d["record"]
    rx = SAFE_R + 1
    if rec != "":
        c.text(rec, SAFE_R, 1, font = "4x5", color = INK, align = "right")
        rx = SAFE_R - c.text_width(rec, "4x5") - 4
    shown = name if c.text_width(name, "4x5") <= rx - nx else NICK[ab]
    c.text(clip(c, shown, "4x5", rx - nx), nx, 1, font = "4x5", color = DIM)

    # Hero: the big crescent and the bye week's number. The countdown and
    # the return game stack right-aligned beside it; the hero is at most
    # 11 + 3 + 21 px wide, so both lines have 90 px.
    c.sprite(BIG_MOON, CLUB_TX, 7, legend = {"M": MOON, "s": MOON_SHADE})
    c.text(str(bye), CLUB_TX + BIG_MOON_W + 3, 7, font = "10x16", color = INK)
    c.text(cd[0], SAFE_R, 7, font = "6x8", color = cd[1], align = "right")
    sl = second_line(d, bye, week, now["type"])
    if sl != "":
        c.text(sl, SAFE_R, 17, font = "5x7", color = INK if sl.startswith("BACK") else DIM, align = "right")

    # The season strip: 18 cells, 5 px wide with a 1 px gap (x 54..160).
    # Each finished game is its result (green W, red L, white T), weeks ahead
    # are dark with a slate edge, the bye cell holds a small moon, and a
    # white tick under a cell marks the current week.
    for w in range(1, LAST_WEEK + 1):
        x = CLUB_TX + (w - 1) * CELL
        y1 = STRIP_Y + 4
        res = d["games"][w][1] if w in d["games"] else ""
        if w == bye:
            c.sprite(CELL_MOON, x, STRIP_Y, legend = {"M": MOON})
        elif res == "W":
            c.rect(x, STRIP_Y, x + CELL - 2, y1, fill = C_WIN)
        elif res == "L":
            c.rect(x, STRIP_Y, x + CELL - 2, y1, fill = C_LOSS)
        elif res == "T":
            c.rect(x, STRIP_Y, x + CELL - 2, y1, fill = INK)
        elif now["type"] == 3 or now["type"] == 4 or (week > 0 and w < week):
            c.rect(x, STRIP_Y, x + CELL - 2, y1, fill = C_PAST)
        else:
            c.rect(x, STRIP_Y, x + CELL - 2, y1, fill = C_AHEAD, outline = C_PAST)
        if w == week:
            c.line(x, y1 + 2, x + CELL - 2, y1 + 2, color = INK)
