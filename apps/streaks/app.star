# Streaks (192x32)
#
# The longest active win and losing streaks in whichever of MLB, the NHL, the
# NBA and the NFL are in their regular season, plus NHL point streaks (games
# in a row without a regulation loss). The four middle pages go to the
# leagues in season, in that order; with fewer leagues, one splits by
# conference (AL/NL, East/West, AFC/NFC) so no page is empty or repeated.
# A league drops off the day after its regular season ends (no playoffs).
# Around them: a Spotlight page (hottest and coldest streak in big type) and
# two closing pages - all-league cold streaks and last 10 games, or home/road
# and best/worst records when only one league is in season.
#
# Win/loss streaks come from ESPN standings (one request per league in
# season, never more than 3 at once); point streaks from the NHL's weekly
# schedule, walked back a week at a time until every team's streak has ended
# (at most SCHED_WEEKS weeks). 8 requests at most, GDN's limit.
#
# Streaks carry over between seasons, the way the record books count them:
# while a team has won (or lost) every game since opening day, last season's
# final standings (one cached request per league) add on the run it ended
# the season with. The NHL schedule look-back gets whatever requests are left.

USER_AGENT = "GDN-Streaks (glance-led-panel)"
LEAGUES = [("MLB", "baseball/mlb"), ("NHL", "hockey/nhl"), ("NBA", "basketball/nba"), ("NFL", "football/nfl")]
CONFS = {"MLB": ["AL", "NL"], "NHL": ["East", "West"], "NBA": ["East", "West"], "NFL": ["AFC", "NFC"]}

# Regular seasons from ESPN: (first day, day after the last games). Past the
# last known season, FALLBACK month/day windows take over each year.
SEASONS = {
    "MLB": [((2026, 3, 25), (2026, 9, 29)), ((2027, 3, 24), (2027, 9, 29))],
    "NHL": [((2025, 10, 7), (2026, 4, 18)), ((2026, 9, 28), (2027, 4, 11))],
    "NBA": [((2025, 10, 21), (2026, 4, 13)), ((2026, 10, 20), (2027, 4, 12))],
    "NFL": [((2025, 9, 4), (2026, 1, 6)), ((2026, 9, 6), (2027, 1, 13))],
}
# All-time regular-season record streaks, shown in each page's header.
RECORDS = {
    ("MLB", "win"): "RECORD 26: NYG 1916",
    ("NHL", "win"): "RECORD 17: PIT 1992-93",
    ("NBA", "win"): "RECORD 33: LAL 1971-72",
    ("NFL", "win"): "RECORD 23: IND 2008-09",
    ("NHL", "points"): "RECORD 35: PHI 1979-80",
    ("MLB", "lose"): "RECORD 23: PHI 1961",
    ("NHL", "lose"): "RECORD 17: WSH 1974-75",
    ("NBA", "lose"): "RECORD 28: DET 2023-24",
    ("NFL", "lose"): "RECORD 26: TB 1976-77",
}

# AL and NL keep their own record books, so their split pages use them.
CONF_RECORDS = {
    ("MLB", "AL", "win"): ("RECORD 22: CLE 2017", 22),
    ("MLB", "NL", "win"): ("RECORD 26: NYG 1916", 26),
    ("MLB", "AL", "lose"): ("RECORD 21: BAL 1988, CWS 2024", 21),
    ("MLB", "NL", "lose"): ("RECORD 23: PHI 1961", 23),
}

# The record numbers themselves, for the "close to the record" flag.
RECORD_N = {("MLB", "win"): 26, ("NHL", "win"): 17, ("NBA", "win"): 33, ("NFL", "win"): 23,
            ("NHL", "points"): 35, ("MLB", "lose"): 23, ("NHL", "lose"): 17, ("NBA", "lose"): 28,
            ("NFL", "lose"): 26}
# When a streak gets flagged as close to the record: 75% of it, rounded up.
CLOSE_AT = {("MLB", "win"): 20, ("NHL", "win"): 13, ("NBA", "win"): 25, ("NFL", "win"): 18,
            ("NHL", "points"): 27, ("MLB", "lose"): 18, ("NHL", "lose"): 13, ("NBA", "lose"): 21,
            ("NFL", "lose"): 20}

FALLBACK = {"MLB": ((3, 25), (9, 30)), "NHL": ((10, 1), (4, 17)), "NBA": ((10, 20), (4, 14)), "NFL": ((9, 6), (1, 13))}
SCHED_WEEKS = 5
MAX_REQUESTS = 8

FIRE = "#FF8A1E"
GOLD = "#FFC83D"
HOT = "#FF5A3C"
ICE = "#5CC8FF"
GREEN = "#5CE27A"
GRAY = "#8A8A8A"
SOFT = "#C8C8C8"
LINE = "#333333"

# Team chip colors from ESPN (background, text). Text is always the bright team color
# or white (dark text is unlit on an LED); near-black backgrounds become a dim
# shade of the bright color; every pair is at least 3:1 contrast.
TEAM_COLORS = {
    "MLB": {"ARI": ("#3A3A3A", "#FFFFFF"), "ATH": ("#003831", "#EFB21E"), "ATL": ("#0C2340", "#FFFFFF"), "BAL": ("#DF4601", "#FFFFFF"), "BOS": ("#0D2B56", "#FFFFFF"), "CHC": ("#0E3386", "#FFFFFF"), "CHW": ("#3B3E40", "#C4CED4"), "CIN": ("#C6011F", "#FFFFFF"), "CLE": ("#002B5C", "#FFFFFF"), "COL": ("#3A3A3A", "#FFFFFF"), "DET": ("#0A2240", "#FF4713"), "HOU": ("#002D62", "#EB6E1F"), "KC": ("#004687", "#7AB2DD"), "LAA": ("#BA0021", "#C4CED4"), "LAD": ("#005A9C", "#FFFFFF"), "MIA": ("#003143", "#00A3E0"), "MIL": ("#13294B", "#FFC72C"), "MIN": ("#031F40", "#FFFFFF"), "NYM": ("#002D72", "#FF5910"), "NYY": ("#132448", "#C4CED4"), "PHI": ("#003278", "#FFFFFF"), "PIT": ("#4C370C", "#FDB827"), "SD": ("#2F241D", "#FFC425"), "SEA": ("#0C2C56", "#FFFFFF"), "SF": ("#4C1B09", "#FD5A1E"), "STL": ("#BE0A14", "#FFFFFF"), "TB": ("#092C5C", "#8FBCE6"), "TEX": ("#003278", "#FFFFFF"), "TOR": ("#134A8E", "#6CACE5"), "WSH": ("#11225B", "#FFFFFF")},
    "NFL": {"ARI": ("#A40227", "#FFFFFF"), "ATL": ("#3A3A3A", "#FFFFFF"), "BAL": ("#29126F", "#FFFFFF"), "BUF": ("#00338D", "#FFFFFF"), "CAR": ("#0085CA", "#FFFFFF"), "CHI": ("#0B1C3A", "#E64100"), "CIN": ("#4B1806", "#FB4F14"), "CLE": ("#472A08", "#FF3C00"), "DAL": ("#002A5C", "#B0B7BC"), "DEN": ("#0A2343", "#FC4C02"), "DET": ("#0076B6", "#FFFFFF"), "GB": ("#204E32", "#FFB612"), "HOU": ("#EB0028", "#FFFFFF"), "IND": ("#003B75", "#FFFFFF"), "JAX": ("#007487", "#FFFFFF"), "KC": ("#E31837", "#FFFFFF"), "LAC": ("#0080C6", "#FFFFFF"), "LAR": ("#003594", "#FFD100"), "LV": ("#323434", "#A5ACAF"), "MIA": ("#008E97", "#FFFFFF"), "MIN": ("#4F2683", "#FFC62F"), "NE": ("#002A5C", "#FFFFFF"), "NO": ("#3F382A", "#D3BC8D"), "NYG": ("#003C7F", "#FFFFFF"), "NYJ": ("#115740", "#FFFFFF"), "PHI": ("#3A3A3A", "#FFFFFF"), "PIT": ("#4C3705", "#FFB612"), "SEA": ("#002A5C", "#69BE28"), "SF": ("#AA0000", "#FFFFFF"), "TB": ("#3E3A35", "#FFFFFF"), "TEN": ("#0C2340", "#4B92DB"), "WSH": ("#5A1414", "#FFB612")},
    "NBA": {"ATL": ("#C8102E", "#FDB927"), "BKN": ("#3A3A3A", "#FFFFFF"), "BOS": ("#008348", "#FFFFFF"), "CHA": ("#00788C", "#FFFFFF"), "CHI": ("#CE1141", "#FFFFFF"), "CLE": ("#860038", "#BC945C"), "DAL": ("#0064B1", "#BBC4CA"), "DEN": ("#0E2240", "#FEC524"), "DET": ("#1D428A", "#FFFFFF"), "GS": ("#1D428A", "#FDB927"), "HOU": ("#CE0E2D", "#FFFFFF"), "IND": ("#0C2340", "#FFD520"), "LAC": ("#C8102E", "#FFFFFF"), "LAL": ("#552583", "#FDB927"), "MEM": ("#12173F", "#5D76A9"), "MIA": ("#3A3A3A", "#FFFFFF"), "MIL": ("#00471B", "#EEE1C6"), "MIN": ("#266092", "#FFFFFF"), "NO": ("#C8102E", "#FFFFFF"), "NY": ("#1D428A", "#F58426"), "OKC": ("#007AC1", "#FFFFFF"), "ORL": ("#0150B5", "#FFFFFF"), "PHI": ("#1D428A", "#FFFFFF"), "PHX": ("#29127A", "#E56020"), "POR": ("#E03A3E", "#FFFFFF"), "SA": ("#3B3E40", "#C4CED4"), "SAC": ("#5A2D81", "#FFFFFF"), "TOR": ("#D91244", "#FFFFFF"), "UTAH": ("#4E008E", "#79A3DC"), "WSH": ("#002B5C", "#FFFFFF")},
    "NHL": {"ANA": ("#4C1701", "#FC4C02"), "BOS": ("#231F20", "#FDB71A"), "BUF": ("#00468B", "#FDB71A"), "CAR": ("#E30426", "#FFFFFF"), "CBJ": ("#002D62", "#FFFFFF"), "CGY": ("#DD1A32", "#FFFFFF"), "CHI": ("#E31937", "#FFFFFF"), "COL": ("#860038", "#FFFFFF"), "DAL": ("#20864C", "#FFFFFF"), "DET": ("#E30526", "#FFFFFF"), "EDM": ("#00205B", "#FF4C00"), "FLA": ("#002D62", "#FFFFFF"), "LA": ("#313334", "#A2AAAD"), "MIN": ("#124734", "#FFFFFF"), "MTL": ("#013A81", "#FFFFFF"), "NJ": ("#E30B2B", "#FFFFFF"), "NSH": ("#002D62", "#FDBA31"), "NYI": ("#00529B", "#FFFFFF"), "NYR": ("#0056AE", "#FFFFFF"), "OTT": ("#DD1A32", "#FFFFFF"), "PHI": ("#4C1A0A", "#FE5823"), "PIT": ("#4C3708", "#FDB71A"), "SEA": ("#314244", "#A3DCE4"), "SJ": ("#006D75", "#FFFFFF"), "STL": ("#0070B9", "#FFFFFF"), "TB": ("#003E7E", "#FFFFFF"), "TOR": ("#003E7E", "#FFFFFF"), "UTAH": ("#253544", "#7AB2E1"), "VAN": ("#003E7E", "#FFFFFF"), "VGK": ("#2A2A2A", "#B4975A"), "WPG": ("#002D62", "#FFFFFF"), "WSH": ("#0B1F41", "#FFFFFF")},
}

# NHL feed abbreviations -> ESPN's.
NHL_ABBR = {"TBL": "TB", "NJD": "NJ", "SJS": "SJ", "LAK": "LA", "UTA": "UTAH"}

# ---------- data ----------

def civil(z):
    z += 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return (y + 1 if m <= 2 else y), m, d

def days_from_civil(y, m, d):
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def day_start(t):
    # 07:00 UTC = 2-3 AM Eastern, after the night's last games.
    return days_from_civil(t[0], t[1], t[2]) * 86400 + 7 * 3600

def in_season(lg, unix):
    known = SEASONS.get(lg, [])
    last_end = 0
    for w in known:
        if day_start(w[0]) <= unix and unix < day_start(w[1]):
            return True
        last_end = max(last_end, day_start(w[1]))
    if unix < last_end:
        return False
    y, _, _ = civil(unix // 86400)
    sm, sd = FALLBACK[lg][0]
    em, ed = FALLBACK[lg][1]
    for sy in [y - 1, y]:
        ey = sy + 1 if em < sm else sy
        if day_start((sy, sm, sd)) <= unix and unix < day_start((ey, em, ed)):
            return True
    return False

def stat(e, name):
    for s in e.get("stats", []):
        if s.get("name") == name:
            return s
    return {}

def fetch_teams(lg, path, season = None):
    # season = None: this season (refreshed every 30 min); a past season's
    # final standings never change, so they're cached for 30 days.
    resp = http.get(
        "https://site.api.espn.com/apis/v2/sports/" + path + "/standings",
        params = {"season": str(season)} if season else {},
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 2592000 if season else 1800,
    )
    if resp["status_code"] != 200 or resp["json"] == None:
        return []
    out = []
    for conf in resp["json"].get("children", []):
        for e in conf.get("standings", {}).get("entries", []):
            s = stat(e, "streak")
            v = s.get("value")
            if v == None:
                continue
            l10 = stat(e, "Last Ten Games").get("displayValue", "")
            out.append({
                "lg": lg,
                "conf": conf.get("abbreviation", conf.get("name", "")),
                "abbr": e["team"]["abbreviation"],
                "streak": int(v),
                "rec": stat(e, "overall").get("displayValue", "").split(",")[0],
                "l10": l10,
                "home": stat(e, "Home").get("displayValue", ""),
                "road": stat(e, "Road").get("displayValue", ""),
                "l10w": int(l10.split("-")[0]) if l10 and l10.split("-")[0].isdigit() else -1,
            })
    return out

def two(n):
    return ("0" + str(n)) if n < 10 else str(n)

def fetch_point_streaks(unix, weeks):
    # The schedule's "now" link redirects, so ask for the week ending today
    # (Eastern, near enough) and follow previousStartDate back.
    y, m, d = civil((unix - 5 * 3600) // 86400 - 6)
    start = "%d-%s-%s" % (y, two(m), two(d))
    games = {}    # team -> [(date, "W" / "OTL" / "L")]
    season_start = False    # walked back past opening night: every run starts there
    for i in range(weeks):
        resp = http.get(
            "https://api-web.nhle.com/v1/schedule/" + start,
            headers = {"User-Agent": USER_AGENT},
            ttl_seconds = 1800 if i == 0 else 43200,
        )
        if resp["status_code"] != 200 or resp["json"] == None:
            break
        finals = 0
        for day in resp["json"].get("gameWeek", []):
            for g in day.get("games", []):
                if g.get("gameType") != 2 or g.get("gameState") not in ["OFF", "FINAL"]:
                    continue
                finals += 1
                ot = g.get("gameOutcome", {}).get("lastPeriodType") in ["OT", "SO"]
                a, h = g["awayTeam"], g["homeTeam"]
                for me, them in [(a, h), (h, a)]:
                    r = "W" if me.get("score", 0) > them.get("score", 0) else ("OTL" if ot else "L")
                    games.setdefault(me["abbrev"], []).append((day["date"], r))
        if finals == 0 and i > 0:
            season_start = True
            break
        # Stop once every team has a regulation loss in the weeks fetched.
        open_runs = [t for t in games if "L" not in [r for _, r in games[t]]]
        start = resp["json"].get("previousStartDate")
        if not start or (len(games) >= 32 and len(open_runs) == 0):
            break
    out = []
    for t, xs in games.items():
        xs = sorted(xs, reverse = True)
        n, w, ended = 0, 0, False
        for _, r in xs:
            if r == "L":
                ended = True
                break
            n += 1
            if r == "W":
                w += 1
        if n == 0:
            continue
        out.append({
            "lg": "NHL",
            "abbr": NHL_ABBR.get(t, t),
            "streak": n,
            "badge": str(n) + ("" if (ended or season_start) else "+"),
            "rec": "%d-0-%d" % (w, n - w),
        })
    return sorted(out, key = lambda r: -r["streak"])

def last_season(lg, unix):
    # ESPN's season number for last season: MLB and NFL go by the year they
    # start, the NBA and NHL by the year they end.
    y, m, _ = civil(unix // 86400)
    if lg == "MLB":
        return y - 1
    if lg == "NFL":
        return (y if m >= 8 else y - 1) - 1
    return (y + 1 if m >= 8 else y) - 1

def games_played(rec):
    n = 0
    for part in rec.split("-"):
        if part.isdigit():
            n += int(part)
    return n

def carry_over(lg, path, rows, unix):
    # Teams that have won (or lost) every game this season pick up the streak
    # they ended last season with, if it ran the same way. Returns True if
    # last season's standings were requested.
    fresh = [r for r in rows if r["streak"] != 0 and abs(r["streak"]) == games_played(r["rec"])]
    if len(fresh) == 0:
        return False
    prev = {}
    for r in fetch_teams(lg, path, last_season(lg, unix)):
        prev[r["abbr"]] = r["streak"]
    for r in fresh:
        before = prev.get(r["abbr"], 0)
        if (before > 0 and r["streak"] > 0) or (before < 0 and r["streak"] < 0):
            r["streak"] += before
            r["prev"] = abs(before)
    return True

def get_data(ctx):
    now = ctx.now.unix
    teams, active = {}, []
    used = 0
    for lg, path in LEAGUES:
        if not in_season(lg, now):
            continue
        rows = fetch_teams(lg, path)
        used += 1
        if len([r for r in rows if r["streak"] != 0]) == 0:
            continue                    # season window open, no games yet
        if carry_over(lg, path, rows, now):
            used += 1
        teams[lg] = rows
        active.append(lg)
    weeks = min(SCHED_WEEKS, MAX_REQUESTS - used)
    return {
        "teams": teams,
        "active": active,
        "points": fetch_point_streaks(now, weeks) if "NHL" in active and weeks > 0 else [],
        "views": plan(active),
    }

def plan(active):
    # The four middle pages: (league, conference or None, "win" / "lose" / "points").
    views = []
    for lg in active:
        views.append((lg, None, "win"))
        if lg == "NHL":
            views.append(("NHL", None, "points"))
    # Too few: split the first one-page league into its two conferences.
    for _ in range(4):
        if len(views) >= 4:
            break
        split = -1
        for i, v in enumerate(views):
            if v[1] == None and v[2] == "win" and len([x for x in views if x[0] == v[0]]) == 1:
                split = i
                break
        if split < 0:
            break
        lg = views[split][0]
        views = views[:split] + [(lg, CONFS[lg][0], "win"), (lg, CONFS[lg][1], "win")] + views[split + 1:]
    # Still short (MLB alone in summer): the first league's losing streaks by conference.
    if len(views) < 4 and len(active) > 0:
        for cf in CONFS[active[0]]:
            views.append((active[0], cf, "lose"))
    return views[:4]

def hot(rows):
    return sorted([r for r in rows if r["streak"] > 0], key = lambda r: -r["streak"])

def losing(rows):
    return sorted([r for r in rows if r["streak"] < 0], key = lambda r: r["streak"])

# ---------- drawing ----------

ICE_DARK = "#2E6FD0"
ICE_MID = "#5CC8FF"
ICE_TIP = "#E8F8FF"

def draw_icon(c, x, y):
    # 22 x 24 flame, left half fire and right half ice: hot and cold streaks.
    outer = [
        (10, 11), (9, 12), (9, 13), (8, 13), (7, 14),
        (6, 15), (5, 15), (4, 16), (3, 17), (3, 18),
        (2, 18), (2, 19), (1, 19), (1, 20), (1, 20),
        (1, 20), (1, 20), (1, 20), (2, 19), (2, 19),
        (3, 18), (4, 17), (5, 16), (7, 14),
    ]
    core = [(10, 11), (9, 12), (9, 12), (8, 13), (7, 13), (7, 14), (6, 14), (6, 15),
            (6, 15), (6, 15), (6, 15), (7, 14), (8, 13)]
    tip = [(10, 11), (9, 12), (9, 12), (9, 12), (10, 11)]
    for layer, dy, hot_c, ice_c in [(outer, 0, HOT, ICE_DARK), (core, 9, FIRE, ICE_MID), (tip, 15, GOLD, ICE_TIP)]:
        for i, r in enumerate(layer):
            a, b = r[0], r[1]
            if a <= 10:
                c.rect(x + a, y + dy + i, x + min(b, 10), y + dy + i, fill = hot_c)
            if b >= 11:
                c.rect(x + max(a, 11), y + dy + i, x + b, y + dy + i, fill = ice_c)

def chip(c, x, y, lg, abbr, font = "5x7"):
    # Team abbreviation on its team-color background. Returns the width.
    bg, fg = TEAM_COLORS.get(lg, {}).get(abbr, ("#333333", "#FFFFFF"))
    w = c.text_width(abbr, font) + 4
    h = 6 if font == "5x7" else 4
    c.rect(x, y, x + w - 1, y + h, fill = bg)
    c.text(abbr, x + 2, y, font = font, color = fg)
    return w

def badge(c, x, y, n, txt = None):
    if txt == None:
        txt = ("W" if n > 0 else "L") + str(abs(n))
    w = c.text_width(txt, "5x7") + 3
    c.rect(x, y, x + w - 1, y + 6, fill = "#5A1A0A" if n > 0 else "#0A2A4A")
    c.text(txt, x + 2, y, font = "5x7", color = FIRE if n > 0 else ICE)
    return w

def abs(n):
    return -n if n < 0 else n

def header(c, left, color, right = "", rcolor = GRAY):
    c.fill("#000000")
    # Too long for one line: "RECORD" -> "REC", single spaces, "MLB AL ..." -> "AL ...",
    # then 2-digit years.
    for step in range(4):
        if c.text_width(left, "4x5") + 6 + c.text_width(right, "4x5") <= 191:
            break
        if step == 0:
            right = right.replace("RECORD ", "REC ")
        elif step == 1:
            left = left.replace("  ", " ")
        elif step == 2:
            if left.startswith("MLB AL ") or left.startswith("MLB NL "):
                left = left[4:]
        else:
            right = right.replace(" 19", " ").replace(" 20", " ")
    c.text(left, 1, 1, font = "4x5", color = color)
    if right:
        c.text(right, 191, 1, font = "4x5", color = rcolor, align = "right")
    c.line(0, 7, 191, 7, LINE)

def record_for(lg, cf, kind):
    # (header text, record, flag-at): the AL's or NL's own record on their split
    # pages; everywhere else (NFL/NBA conferences included) the league record.
    if (lg, cf, kind) in CONF_RECORDS:
        txt, rec = CONF_RECORDS[(lg, cf, kind)]
        return txt, rec, (rec * 3 + 3) // 4
    if (lg, kind) not in RECORD_N:
        return "", None, None
    return RECORDS[(lg, kind)], RECORD_N[(lg, kind)], CLOSE_AT[(lg, kind)]

def record_note(lg, kind, n, cf = None):
    # "" until a streak gets within reach of the record, then
    # "5 TO TIE" / "TIES RECORD" / "NEW RECORD".
    _, rec, at = record_for(lg, cf, kind)
    n = abs(n)
    if rec == None or n < at:
        return ""
    if n < rec:
        return "%d TO TIE" % (rec - n)
    return "TIES RECORD" if n == rec else "NEW RECORD"

def short_note(note):
    # Narrow version of a record note: "5 TO TIE" -> "5 SHY", "TIES RECORD" -> "TIES REC".
    if note.endswith(" TO TIE"):
        return note[:-len(" TO TIE")] + " SHY"
    return note.replace("RECORD", "REC")

def team_grid(c, rows, kind = "win", cf = None):
    # 2 columns x 3 rows: streak badge, team, then its record - or, near the
    # league's all-time streak, how close it is (in gold).
    for i, r in enumerate(rows[:6]):
        x = 1 if i < 3 else 97
        y = 9 + (i % 3) * 8
        w = badge(c, x, y, r["streak"], r.get("badge"))
        cw = chip(c, x + w + 2, y, r["lg"], r["abbr"])
        note = record_note(r["lg"], kind, r["streak"], cf)
        tx = x + w + cw + 5
        if note:
            c.text(note, tx, y + 1, font = "4x5", color = GOLD)
        elif r.get("prev"):
            # Part of the streak came at the end of last season: "3-0 +8 LAST YR",
            # shortened to fit the column.
            right = 94 if i < 3 else 190
            extra = "+%d LAST YR" % r["prev"]
            if tx + c.text_width(r["rec"] + " " + extra, "4x5") <= right:
                c.text(r["rec"], tx, y + 1, font = "4x5", color = GRAY)
                c.text(extra, tx + c.text_width(r["rec"] + " ", "4x5"), y + 1, font = "4x5", color = SOFT)
            elif tx + c.text_width(extra, "4x5") <= right:
                c.text(extra, tx, y + 1, font = "4x5", color = SOFT)
            else:
                c.text("+" + str(r["prev"]) + " PRIOR", tx, y + 1, font = "4x5", color = SOFT)
        else:
            c.text(r["rec"], tx, y + 1, font = "4x5", color = GRAY)
    c.line(95, 9, 95, 31, "#222222")

def no_data(c, title):
    c.fill("#000000")
    c.text(title, 96, 6, font = "7x10", color = FIRE, align = "center")
    c.text("STREAKS UNAVAILABLE", 96, 20, font = "5x7", color = GRAY, align = "center")

# ---------- pages ----------

def intro(c, ctx):
    data = get_data(ctx)
    c.fill("#000000")
    draw_icon(c, 4, 3)
    x0 = 32
    c.text("STREAKS", x0, 2, font = "7x10", color = FIRE)
    # Everything here - streaks, records, carry-over - is regular season only.
    c.text("REGULAR SEASON", 191, 5, font = "4x5", color = GRAY, align = "right")
    x = x0
    if len(data["active"]) == 0:
        c.text("BACK WHEN THE SEASONS START", x0, 15, font = "4x5", color = GRAY)
    tops = []
    for lg in data["active"]:
        h = hot(data["teams"][lg])
        if len(h) > 0:
            tops.append((lg, h[0]["abbr"], "W" + str(h[0]["streak"])))
    # Full width: league tag + chip + streak, 6 px apart; drop the tags if that won't fit.
    tags = True
    need = 0
    for lg, ab, w in tops:
        need += c.text_width(lg, "4x5") + 2 + c.text_width(ab, "5x7") + 4 + 2 + c.text_width(w, "5x7") + 6
    if x0 + need - 6 > 191:
        tags = False
    for lg, ab, w in tops:
        if tags:
            c.text(lg, x, 15, font = "4x5", color = GRAY)
            x += c.text_width(lg, "4x5") + 2
        x += chip(c, x, 14, lg, ab) + 2
        c.text(w, x, 14, font = "5x7", color = FIRE)
        x += c.text_width(w, "5x7") + 6
    c.line(x0, 23, 191, 23, "#2A2A2A")
    best = headline(data)
    if best != None:
        x = x0 + chip(c, x0, 25, best["lg"], best["abbr"]) + 3
        c.text(best["text"], x, 25, font = "5x7", color = GREEN)

def headline_text(lg, kind, n, plain):
    # Near the record the headline says so: "W25 - 8 FROM RECORD".
    rec = RECORD_N.get((lg, kind))
    if rec == None or n < CLOSE_AT[(lg, kind)]:
        return plain
    tag = ("W" if kind == "win" else "PT") + str(n)
    if n < rec:
        return "%s - %d FROM RECORD" % (tag, rec - n)
    return "%s - %s" % (tag, "TIES RECORD" if n == rec else "NEW RECORD")

def headline(data):
    # The single longest streak anywhere: each league's top win streak and the
    # top NHL point streak. Ties go to a win streak (a point streak can include
    # OT losses), then league order. Nothing under 3 games.
    cands = []
    for i, lg in enumerate(data["active"]):
        h = hot(data["teams"][lg])
        if len(h) > 0:
            cands.append((h[0]["streak"], 1, -i, lg, h[0]["abbr"], headline_text(lg, "win", h[0]["streak"], "%d-GAME WIN STREAK" % h[0]["streak"])))
    pts = data["points"]
    if len(pts) > 0:
        cands.append((pts[0]["streak"], 0, 0, "NHL", pts[0]["abbr"], headline_text("NHL", "points", pts[0]["streak"], "%s-GAME POINT STREAK" % pts[0]["badge"])))
    if len(cands) == 0:
        return None
    top = sorted(cands, reverse = True)[0]
    if top[0] < 3:
        return None
    return {"lg": top[3], "abbr": top[4], "text": top[5]}

def off_season(c):
    c.fill("#000000")
    c.text("STREAKS", 96, 6, font = "7x10", color = FIRE, align = "center")
    c.text("BACK WHEN THE SEASONS START", 96, 20, font = "5x7", color = GRAY, align = "center")

def view_page(c, ctx, i):
    data = get_data(ctx)
    if i >= len(data["views"]):
        off_season(c)
        return
    lg, cf, kind = data["views"][i]
    if kind == "points":
        rows = data["points"]
        if len(rows) == 0:
            no_data(c, "NHL")
            return
        header(c, "NHL POINT STREAKS", FIRE, RECORDS[("NHL", "points")], GOLD)
        team_grid(c, rows, "points")
        return
    rows = [r for r in data["teams"][lg] if cf == None or r["conf"] == cf]
    name = lg + "  " + ((cf.upper() + " ") if cf else "")
    if kind == "lose":
        header(c, name + "LOSING STREAKS", ICE, record_for(lg, cf, "lose")[0], GOLD)
        team_grid(c, losing(rows), "lose", cf)
        return
    header(c, name + "WIN STREAKS", FIRE, record_for(lg, cf, "win")[0], GOLD)
    team_grid(c, hot(rows), "win", cf)

def board_1(c, ctx):
    view_page(c, ctx, 0)

def board_2(c, ctx):
    view_page(c, ctx, 1)

def board_3(c, ctx):
    view_page(c, ctx, 2)

def board_4(c, ctx):
    view_page(c, ctx, 3)

def wins_pct(rec):
    # (win share, wins) from "6-0", "19-3-3" or "8-2-1".
    parts = [int(x) for x in rec.split("-") if x.isdigit()]
    total = 0
    for x in parts:
        total += x
    if total == 0:
        return (-1.0, 0)
    return (parts[0] * 1.0 / total, parts[0])

def extras(data):
    # The last two pages, in order of preference, never repeating a middle page:
    # all-league cold streaks (2+ leagues), last 10 games (no NFL data), then
    # home/road and best/worst records when fewer leagues are in season.
    out = []
    if len(data["active"]) >= 2:
        out.append("cold")
    if len([lg for lg in data["active"] if len([r for r in data["teams"][lg] if r["l10w"] >= 0]) > 0]) > 0:
        out.append("last10")
    out.append("homeroad")
    out.append("best")
    return out

def all_rows(data):
    rows = []
    for lg in data["active"]:
        rows += data["teams"][lg]
    return rows

def two_lists(c, title, color, right, left_rows, right_rows, left_txt, right_txt, show_lg, right_hot = False):
    # Two columns of three: left hot (orange badges), right cold (blue) unless both are "good" lists.
    header(c, title, color, right, GRAY)
    for col, lst, n, txt in [(0, left_rows, 1, left_txt), (1, right_rows, 1 if right_hot else -1, right_txt)]:
        for i, r in enumerate(lst[:3]):
            x = 1 if col == 0 else 97
            y = 9 + i * 8
            w = badge(c, x, y, n, txt(r))
            cw = chip(c, x + w + 2, y, r["lg"], r["abbr"])
            c.text((r["lg"] + " " + r["rec"]) if show_lg else r["rec"], x + w + cw + 5, y + 1, font = "4x5", color = GRAY)
    c.line(95, 9, 95, 31, "#222222")

def extra_page(c, ctx, i):
    data = get_data(ctx)
    if len(data["active"]) == 0:
        off_season(c)
        return
    kind = extras(data)[i]
    many = len(data["active"]) > 1
    tag = "" if many else data["active"][0] + "  "
    if kind == "cold":
        rows = sorted(losing(all_rows(data)), key = lambda r: r["streak"])
        header(c, "COLD STREAKS", ICE, "LONGEST LOSING STREAKS")
        for i, r in enumerate(rows[:6]):
            x = 1 if i < 3 else 97
            y = 9 + (i % 3) * 8
            w = badge(c, x, y, r["streak"])
            cw = chip(c, x + w + 2, y, r["lg"], r["abbr"])
            note = record_note(r["lg"], "lose", r["streak"])
            tx = x + w + cw + 5
            right = 94 if i < 3 else 190
            c.text(r["lg"], tx, y + 1, font = "4x5", color = GRAY)
            tx += c.text_width(r["lg"] + " ", "4x5")
            if note and tx + c.text_width(note, "4x5") > right:
                note = short_note(note)
            c.text(note if note else r["rec"], tx, y + 1, font = "4x5", color = GOLD if note else GRAY)
        c.line(95, 9, 95, 31, "#222222")
    elif kind == "last10":
        rows = [r for r in all_rows(data) if r["l10w"] >= 0]
        best = sorted(rows, key = lambda r: (-r["l10w"], -r["streak"]))
        worst = sorted(rows, key = lambda r: (r["l10w"], r["streak"]))
        two_lists(c, tag + "LAST 10 GAMES", FIRE, "HOTTEST  |  COLDEST", best, worst,
                  lambda r: r["l10"], lambda r: r["l10"], many)
    elif kind == "homeroad":
        rows = [r for r in all_rows(data) if r["home"] and r["road"]]
        home = sorted(rows, key = lambda r: (-wins_pct(r["home"])[0], -wins_pct(r["home"])[1]))
        road = sorted(rows, key = lambda r: (-wins_pct(r["road"])[0], -wins_pct(r["road"])[1]))
        two_lists(c, tag + "HOME AND ROAD", FIRE, "BEST HOME  |  BEST ROAD", home, road,
                  lambda r: r["home"].split(",")[0], lambda r: r["road"].split(",")[0], many, True)
    else:
        rows = [r for r in all_rows(data) if wins_pct(r["rec"])[0] >= 0]
        best = sorted(rows, key = lambda r: -wins_pct(r["rec"])[0])
        worst = sorted(rows, key = lambda r: wins_pct(r["rec"])[0])
        two_lists(c, tag + "RECORDS", FIRE, "BEST  |  WORST", best, worst,
                  lambda r: r["rec"], lambda r: r["rec"], many)

def extra_1(c, ctx):
    extra_page(c, ctx, 0)

def extra_2(c, ctx):
    extra_page(c, ctx, 1)

def spot_half(c, x, label, color, r, kind):
    # One half of the spotlight: label, big streak number, team chip, what kind, record or record watch.
    c.text(label, x + 2, 1, font = "4x5", color = color)
    big = r.get("badge") if kind == "points" else (("W" if r["streak"] > 0 else "L") + str(abs(r["streak"])))
    c.text(big, x + 2, 10, font = "10x16", color = FIRE if color == FIRE else ICE)
    bx = x + 2 + c.text_width(big, "10x16") + 5
    chip(c, bx, 9, r["lg"], r["abbr"])
    what = {"win": "WIN STREAK", "points": "POINT STREAK", "lose": "LOSING STREAK"}[kind]
    c.text(what, bx, 18, font = "4x5", color = SOFT)
    note = record_note(r["lg"], kind, r["streak"])
    c.text(r["lg"], bx, 25, font = "4x5", color = GRAY)
    nx = bx + c.text_width(r["lg"] + " ", "4x5")
    if note and nx + c.text_width(note, "4x5") > x + 93:
        note = short_note(note)
    c.text(note if note else r["rec"], nx, 25, font = "4x5", color = GOLD if note else GRAY)

def spotlight(c, ctx):
    # The hottest and the coldest streak anywhere, in big type.
    data = get_data(ctx)
    c.fill("#000000")
    if len(data["active"]) == 0:
        off_season(c)
        return
    hots = []
    for i, lg in enumerate(data["active"]):
        h = hot(data["teams"][lg])
        if len(h) > 0:
            hots.append((h[0]["streak"], 1, -i, h[0], "win"))
    if len(data["points"]) > 0:
        hots.append((data["points"][0]["streak"], 0, 0, data["points"][0], "points"))
    colds = []
    for i, lg in enumerate(data["active"]):
        k = losing(data["teams"][lg])
        if len(k) > 0:
            colds.append((-k[0]["streak"], -i, k[0]))
    if len(hots) > 0:
        top = sorted(hots, key = lambda t: (t[0], t[1], t[2]), reverse = True)[0]
        spot_half(c, 0, "HOTTEST", FIRE, top[3], top[4])
    if len(colds) > 0:
        top = sorted(colds, key = lambda t: (t[0], t[1]), reverse = True)[0]
        spot_half(c, 97, "COLDEST", ICE, top[2], "lose")
    c.line(95, 1, 95, 31, "#222222")
