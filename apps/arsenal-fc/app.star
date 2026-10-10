# Arsenal FC — a GDN Starlark app (64x32, 3 pages).
#
# DESIGN. Arsenal colors only — red, white, black, and shades of them, on a
# black ground (no green, no amber/gold): a loss is bold red, a draw a
# lighter red tint, a win white. Every page shares one grid so the rotation
# reads as one app: the red cannon mark top-left (x1-20, y0-8) with context
# right-aligned beside it, one hero below (y10-25), and a single 4x5 footer
# line (y27-31). 64px has no room for a side rail, so the mark lives in the
# header row and the hero gets the whole width. Three pages rotate: MATCH
# (the live score while Arsenal are playing, otherwise the next fixture),
# RESULT (last final score with a WIN/DRAW/LOSS chip), TABLE (league
# position, points, goal difference, last-5 form). No inputs but one: a
# kickoff time zone (see TZ_OFFSET) — this is otherwise Arsenal, always.
#
# LOGO. assets/cannon.png is Arsenal's own 1921-22 club crest — a real,
# public-domain historical mark (see README.md for provenance and why the
# modern shield crest doesn't work at this resolution), thresholded to a
# single Arsenal red at 20x9px so it stands on the black ground.
#
# DATA. TheSportsDB (team id 133604, league id 4328) using the shared free
# "3" test key — no signup, no api-key input. Three known trade-offs,
# called out where they bite below: the free key's table lookup only
# returns the top 5 rows, so TABLE has a dedicated "outside the top 5"
# state; kickoff time is converted from the fixture's own local (UK) time
# using a fixed standard-time offset (no daylight-saving adjustment); and
# the free key's livescore feed is shared across every sport and league,
# so MATCH scans the whole feed for Arsenal's team id — refresh is 300s to
# keep the minute reasonably fresh, while the slower lookups cache longer
# through their own ttl_seconds.

RED = "#EF0107"
RED_LIGHT = "#FF6B61"  # draw / live minute / kickoff — a lighter tint of brand red
WHITE = "white"
GRAY = "gray"
NODATA_BG = "#0B0C12"
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"

TEAM_ID = "133604"
LEAGUE_ID = "4328"

# The grid every page shares (see DESIGN).
CANNON_X = 1  # the 20x9 mark spans x1-20, y0-8
HEAD_X0 = 22  # first header column clear of the mark
RIGHT = 63    # right edge for right-aligned text
CX = 32
HEAD_Y = 2    # 4x5 text, centered on the 9px cannon row
HERO_Y = 10
HERO_H = 16
FOOT_Y = 27

FONTH = {"10x16": 16, "10x16_bold": 16, "7x12": 12, "6x8": 8, "5x7": 7, "5x7b": 7, "4x5": 5}

MONTHS = {
    "01": "JAN", "02": "FEB", "03": "MAR", "04": "APR",
    "05": "MAY", "06": "JUN", "07": "JUL", "08": "AUG",
    "09": "SEP", "10": "OCT", "11": "NOV", "12": "DEC",
}

WEEKDAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

# Kickoff times come from the API in the fixture's own (UK) local time.
# Fixed standard-time offsets from UK — not DST-adjusted: doing that
# correctly needs a real tz database, which isn't available here. Good
# enough to get viewers within an hour outside of the ~6 weeks a year the
# two regions' clocks change on different dates.
TZ_OFFSET = {
    "UK": 0, "US EASTERN": -5, "US CENTRAL": -6, "US MOUNTAIN": -7,
    "US PACIFIC": -8, "CENTRAL EUROPE": 1,
}

# Competitions that earn the "big European night" star on MATCH.
EUROPEAN_COMPS = {
    "UEFA CHAMPIONS LEAGUE": True,
    "UEFA EUROPA LEAGUE": True,
    "UEFA EUROPA CONFERENCE LEAGUE": True,
}

# 5x5 star — the European-night badge, drawn next to the kickoff day
# instead of reaching for a new accent color.
STAR = [
    [0, 0, 1, 0, 0],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
    [0, 1, 0, 1, 0],
    [1, 0, 0, 0, 1],
]

# Result -> [chip label, chip fill, chip text], from one table so the word
# and the color can never disagree. Text flips to black on the bright fills.
OUTCOME = {
    "W": ["WIN", WHITE, "black"],
    "D": ["DRAW", RED_LIGHT, "black"],
    "L": ["LOSS", RED, WHITE],
}

FORM_COLOR = {"W": WHITE, "D": RED_LIGHT, "L": RED}

# Common long club names, shortened to fit a 64px panel; anything unmapped
# still falls through fit_clip's hard-clip, so no name can overflow.
CLUB_SHORT = {
    "MANCHESTER UNITED": "MAN UTD",
    "MANCHESTER CITY": "MAN CITY",
    "TOTTENHAM HOTSPUR": "SPURS",
    "WEST HAM UNITED": "WEST HAM",
    "BRIGHTON AND HOVE ALBION": "BRIGHTON",
    "WOLVERHAMPTON WANDERERS": "WOLVES",
    "NOTTINGHAM FOREST": "FOREST",
    "CRYSTAL PALACE": "PALACE",
    "LEICESTER CITY": "LEICESTER",
    "SHEFFIELD UNITED": "SHEFF UTD",
    "WEST BROMWICH ALBION": "WEST BROM",
    "IPSWICH TOWN": "IPSWICH",
    "LEEDS UNITED": "LEEDS",
    "NEWCASTLE UNITED": "NEWCASTLE",
    "AFC BOURNEMOUTH": "BOURNEMOUTH",
}

def fit_clip(c, text, fonts, maxw):
    """Pick the largest font in `fonts` that fits maxw; hard-clip if none do."""
    for f in fonts:
        if c.text_width(text, font = f) <= maxw:
            return text, f
    f = fonts[-1]
    for i in range(len(text) - 1):
        if c.text_width(text, font = f) <= maxw:
            break
        text = text[:-1]
    return text, f

def short_club(name):
    up = name.upper()
    return CLUB_SHORT.get(up, up)

def fmt_ymd(y, m, d):
    key = str(m) if m >= 10 else "0" + str(m)
    month = MONTHS.get(key, "???")
    return month + " " + str(d)

def fmt_hm12(h, m):
    ap = "AM" if h < 12 else "PM"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    mm = str(m) if m >= 10 else "0" + str(m)
    return "%d:%s%s" % (h12, mm, ap)

def parse_iso_date(date_iso):
    return int(date_iso[0:4]), int(date_iso[5:7]), int(date_iso[8:10])

def iso_ymd(y, m, d):
    mm = str(m) if m >= 10 else "0" + str(m)
    dd = str(d) if d >= 10 else "0" + str(d)
    return "%d-%s-%s" % (y, mm, dd)

def parse_hms(hhmmss):
    return int(hhmmss[0:2]), int(hhmmss[3:5])

# Julian day number <-> Gregorian date, so a kickoff can be shifted by a
# timezone offset (and a countdown computed) with plain integer math —
# no date library is available in this sandbox, and there's no `while`
# (see apply_tz), so this has to stay a couple of `if`s, not a loop.
def ymd_to_jdn(y, m, d):
    a = (14 - m) // 12
    y2 = y + 4800 - a
    m2 = m + 12 * a - 3
    return d + (153 * m2 + 2) // 5 + 365 * y2 + y2 // 4 - y2 // 100 + y2 // 400 - 32045

def jdn_to_ymd(jdn):
    a = jdn + 32044
    b = (4 * a + 3) // 146097
    c = a - (146097 * b) // 4
    d2 = (4 * c + 3) // 1461
    e = c - (1461 * d2) // 4
    m2 = (5 * e + 2) // 153
    day = e - (153 * m2 + 2) // 5 + 1
    month = m2 + 3 - 12 * (m2 // 10)
    year = 100 * b + d2 - 4800 + m2 // 10
    return year, month, day

def apply_tz(y, m, d, h, mi, offset_hours):
    total_min = h * 60 + mi + offset_hours * 60
    day_shift = 0
    if total_min < 0:
        total_min += 24 * 60
        day_shift = -1
    elif total_min >= 24 * 60:
        total_min -= 24 * 60
        day_shift = 1
    if day_shift != 0:
        y, m, d = jdn_to_ymd(ymd_to_jdn(y, m, d) + day_shift)
    return y, m, d, total_min // 60, total_min % 60

def days_until(now, y, m, d):
    return ymd_to_jdn(y, m, d) - ymd_to_jdn(now.year, now.month, now.day)

def day_label(days, y, m, d):
    """TODAY, TMRW, a weekday within the week, or the date further out."""
    if days == 0:
        return "TODAY"
    if days == 1:
        return "TMRW"
    if days >= 2 and days <= 6:
        return WEEKDAYS[(ymd_to_jdn(y, m, d) + 1) % 7]  # JDN + 1 counts from Sunday
    return fmt_ymd(y, m, d)  # far out, or a past-due edge case — just show the date

def ordinal(n):
    if n % 100 >= 11 and n % 100 <= 13:
        return "TH"
    return {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

def outcome_key(score_for, score_against):
    if score_for > score_against:
        return "W"
    if score_for == score_against:
        return "D"
    return "L"

def season_str(now):
    # EPL season spans Aug-May; treat Jul+ as the start of the new season.
    y = now.year
    if now.month >= 7:
        return "%d-%d" % (y, y + 1)
    return "%d-%d" % (y - 1, y)

def mark(c):
    """The red cannon, top-left on every page: the app's identity."""
    c.image("cannon.png", CANNON_X, 0)

def chip_width(c, text, font):
    # text_width counts the glyph spacing after the last letter, so +3
    # reads as an even 2px pad on both sides.
    return c.text_width(text, font = font) + 3

def chip(c, text, x0, y0, h, font, fg, bg):
    """A filled label h px tall, its text centered, left edge at x0."""
    w = chip_width(c, text, font)
    c.rect(x0, y0, x0 + w - 1, y0 + h - 1, fill = bg)
    c.text(text, x0 + 2, y0 + (h - FONTH[font]) // 2, font = font, color = fg)

def versus(c, name):
    """Footer: "V" and the opponent, centered as one run."""
    name, nf = fit_clip(c, name, ["4x5"], 62 - 7)
    x = CX - (7 + c.text_width(name, font = nf)) // 2
    c.text("V", x, FOOT_Y, font = "4x5", color = GRAY)
    c.text(name, x + 7, FOOT_Y, font = nf, color = WHITE)

def state_card(c, page, title, sub, title_color, sub_color, bg):
    """Fallback card on the same grid: which page, what happened, what it means."""
    c.fill(bg)
    mark(c)
    c.text(page, RIGHT, HEAD_Y, font = "4x5", color = GRAY, align = "right")
    t, tf = fit_clip(c, title, ["6x8", "5x7", "4x5"], 62)
    c.text(t, CX, 13, font = tf, color = title_color, align = "center")
    s, sf = fit_clip(c, sub, ["4x5"], 62)
    c.text(s, CX, 24, font = sf, color = sub_color, align = "center")

def nodata(c, page, title, sub):
    state_card(c, page, title, sub, NODATA_TITLE, NODATA_SUB, NODATA_BG)

def empty_state(c, page, title, sub):
    state_card(c, page, title, sub, WHITE, GRAY, "black")

def fetch_next_fixture(now, tz_offset):
    resp = http.get(
        "https://www.thesportsdb.com/api/v1/json/3/eventsnext.php",
        params = {"id": TEAM_ID},
        ttl_seconds = 1800,
    )
    if resp["status_code"] != 200:
        return None, "offline"
    events = resp["json"].get("events")
    if not events:
        return None, "empty"
    e = events[0]
    home = e.get("idHomeTeam") == TEAM_ID
    opponent = e.get("strAwayTeam") if home else e.get("strHomeTeam")
    y, m, d = parse_iso_date(e.get("dateEvent") or "0000-01-01")
    hh, mm = parse_hms(e.get("strTimeLocal") or e.get("strTime") or "00:00:00")
    y, m, d, hh, mm = apply_tz(y, m, d, hh, mm, tz_offset)
    return {
        "opponent": short_club(opponent or "TBD"),
        "home": home,
        "european": EUROPEAN_COMPS.get((e.get("strLeague") or "").upper(), False),
        "day": day_label(days_until(now, y, m, d), y, m, d),
        "time": fmt_hm12(hh, mm),
    }, "ok"

def fetch_last_result_sportsdb():
    resp = http.get(
        "https://www.thesportsdb.com/api/v1/json/3/eventslast.php",
        params = {"id": TEAM_ID},
        ttl_seconds = 1800,
    )
    if resp["status_code"] != 200:
        return None, "offline"
    results = resp["json"].get("results")
    if not results:
        return None, "empty"
    r = results[0]
    home = r.get("idHomeTeam") == TEAM_ID
    opponent = r.get("strAwayTeam") if home else r.get("strHomeTeam")
    home_score = int(r.get("intHomeScore") or 0)
    away_score = int(r.get("intAwayScore") or 0)
    y, m, d = parse_iso_date(r.get("dateEvent") or "0000-01-01")
    return {
        "opponent": short_club(opponent or "TBD"),
        "score_for": home_score if home else away_score,
        "score_against": away_score if home else home_score,
        "date": fmt_ymd(y, m, d),
    }, "ok"

FD_BASE = "https://api.football-data.org/v4"

def fd_resolve_team_id(apikey):
    """Look up Arsenal's numeric id on football-data.org by name instead of
    hardcoding a guessed id — cached almost indefinitely since it never
    changes. (The free Premier League team list is one request either way.)"""
    resp = http.get(
        FD_BASE + "/competitions/PL/teams",
        headers = {"X-Auth-Token": apikey},
        ttl_seconds = 2592000,
    )
    if resp["status_code"] != 200:
        return None
    for t in resp["json"].get("teams") or []:
        if "ARSENAL" in (t.get("name") or "").upper():
            return t.get("id")
    return None

def fetch_last_result_fd(apikey, now):
    team_id = fd_resolve_team_id(apikey)
    if team_id == None:
        return None, "offline"
    from_y, from_m, from_d = jdn_to_ymd(ymd_to_jdn(now.year, now.month, now.day) - 10)
    resp = http.get(
        FD_BASE + "/teams/%d/matches" % team_id,
        params = {
            "status": "FINISHED",
            "dateFrom": iso_ymd(from_y, from_m, from_d),
            "dateTo": iso_ymd(now.year, now.month, now.day),
        },
        headers = {"X-Auth-Token": apikey},
        ttl_seconds = 1800,
    )
    if resp["status_code"] != 200:
        return None, "offline"
    matches = resp["json"].get("matches") or []
    if not matches:
        return None, "empty"
    # Endpoint order isn't documented, so pick the max date explicitly
    # rather than trust matches[0] or matches[-1].
    best = matches[0]
    for mt in matches:
        if (mt.get("utcDate") or "") > (best.get("utcDate") or ""):
            best = mt
    home = best.get("homeTeam") or {}
    away = best.get("awayTeam") or {}
    is_home = home.get("id") == team_id
    ft = (best.get("score") or {}).get("fullTime") or {}
    home_score = int(ft.get("home") or 0)
    away_score = int(ft.get("away") or 0)
    opponent = away.get("name") if is_home else home.get("name")
    y, m, d = parse_iso_date((best.get("utcDate") or "0000-01-01T00:00:00Z")[0:10])
    return {
        "opponent": short_club(opponent or "TBD"),
        "score_for": home_score if is_home else away_score,
        "score_against": away_score if is_home else home_score,
        "date": fmt_ymd(y, m, d),
    }, "ok"

def fetch_last_result(now, apikey):
    """TheSportsDB's free key can lag several days behind on this team's
    last result (confirmed: it kept serving a week-old match while a newer
    one had already finished). If a football-data.org key is supplied,
    prefer it and only fall back to the free source when THAT fails —
    "empty" from football-data.org (no finished match in the last 10 days)
    is trusted as-is, not treated as a failure to fall back from."""
    if apikey:
        r, state = fetch_last_result_fd(apikey, now)
        if state != "offline":
            return r, state
    return fetch_last_result_sportsdb()

def fetch_table_row(now):
    resp = http.get(
        "https://www.thesportsdb.com/api/v1/json/3/lookuptable.php",
        params = {"l": LEAGUE_ID, "s": season_str(now)},
        ttl_seconds = 3600,
    )
    if resp["status_code"] != 200:
        return None, "offline"
    rows = resp["json"].get("table")
    if not rows:
        return None, "empty"
    for row in rows:
        if row.get("idTeam") == TEAM_ID:
            return {
                "rank": int(row.get("intRank") or 0),
                "points": int(row.get("intPoints") or 0),
                "goal_diff": int(row.get("intGoalDifference") or 0),
                "form": (row.get("strForm") or "").upper(),
            }, "ok"
    # The shared free API key only returns the table's top 5 rows.
    return None, "outside_top5"

NOT_LIVE_STATUS = {"NS": True, "FT": True, "POSTPONED": True, "PPD": True,
                    "CANC": True, "ABD": True, "TBD": True, "": True}

def fetch_live_match():
    resp = http.get(
        "https://www.thesportsdb.com/api/v1/json/3/livescore.php",
        params = {"s": "Soccer"},
        ttl_seconds = 300,
    )
    if resp["status_code"] != 200:
        return None, "offline"
    rows = resp["json"].get("livescore")
    if not rows:
        return None, "not_live"
    for row in rows:
        if row.get("idHomeTeam") != TEAM_ID and row.get("idAwayTeam") != TEAM_ID:
            continue
        status = (row.get("strStatus") or "").upper()
        if NOT_LIVE_STATUS.get(status):
            continue
        home = row.get("idHomeTeam") == TEAM_ID
        opponent = row.get("strAwayTeam") if home else row.get("strHomeTeam")
        home_score = int(row.get("intHomeScore") or 0)
        away_score = int(row.get("intAwayScore") or 0)
        progress = row.get("strProgress") or status
        # 4x5/5x7 have no apostrophe glyph (it's silently skipped, not
        # drawn) — "M" for minutes avoids that trap.
        minute = progress if status == "HT" else progress + "M"
        return {
            "opponent": short_club(opponent or "TBD"),
            "score_for": home_score if home else away_score,
            "score_against": away_score if home else home_score,
            "minute": minute,
        }, "ok"
    return None, "not_live"

def match(c, ctx):
    # One page for Arsenal's match: live while it's on, the next one otherwise.
    # A livescore outage alone still falls through to the fixture.
    m, live_state = fetch_live_match()
    if live_state == "ok":
        draw_live(c, m)
        return

    tz_offset = TZ_OFFSET.get(ctx.inputs.get("timezone", "UK"), 0)
    fx, state = fetch_next_fixture(ctx.now, tz_offset)
    if state == "offline":
        nodata(c, "MATCH", "NO DATA", "TRY LATER")
        return
    if state == "empty":
        empty_state(c, "MATCH", "NO FIXTURE", "NOT YET SET")
        return
    draw_next(c, fx)

def draw_live(c, m):
    c.fill("black")
    mark(c)
    # Header: the LIVE chip against the right edge, the minute fit before
    # it — stoppage time ("90+4M") drops its M to squeeze in.
    chip_x = RIGHT - chip_width(c, "LIVE", "4x5") + 1
    chip(c, "LIVE", chip_x, 0, 9, "4x5", WHITE, RED)
    minute = m["minute"]
    if c.text_width(minute, font = "4x5") > chip_x - 2 - HEAD_X0 and minute.endswith("M"):
        minute = minute[:-1]
    c.text(minute, chip_x - 3, HEAD_Y, font = "4x5", color = RED_LIGHT, align = "right")

    # Score is the hero, in white — the match isn't decided yet.
    score = "%d-%d" % (m["score_for"], m["score_against"])
    s, sf = fit_clip(c, score, ["10x16_bold", "6x8"], 62)
    c.text(s, CX, HERO_Y + (HERO_H - FONTH[sf]) // 2, font = sf, color = WHITE, align = "center")

    versus(c, m["opponent"])

def draw_next(c, fx):
    c.fill("black")
    mark(c)

    # Header: the kickoff day, with the star before it on European nights.
    dw = c.text_width(fx["day"], font = "4x5")
    c.text(fx["day"], RIGHT, HEAD_Y, font = "4x5", color = WHITE, align = "right")
    if fx["european"]:
        c.bitmap(STAR, RIGHT - dw - 6, HEAD_Y, color = RED_LIGHT)

    # Hero: the opponent, as big as the name allows.
    name, nf = fit_clip(c, fx["opponent"], ["10x16", "7x12", "5x7", "4x5"], 62)
    c.text(name, CX, HERO_Y + (HERO_H - FONTH[nf]) // 2, font = nf, color = WHITE, align = "center")

    # Footer: HOME/AWAY left, kickoff time right.
    ha = "HOME" if fx["home"] else "AWAY"
    c.text(ha, CANNON_X, FOOT_Y, font = "4x5", color = WHITE if fx["home"] else GRAY)
    c.text(fx["time"], RIGHT, FOOT_Y, font = "4x5", color = RED_LIGHT, align = "right")

def result(c, ctx):
    r, state = fetch_last_result(ctx.now, ctx.inputs.get("apikey", ""))
    if state == "offline":
        nodata(c, "RESULT", "NO DATA", "TRY LATER")
        return
    if state == "empty":
        empty_state(c, "RESULT", "NO RESULT", "NOT YET")
        return

    c.fill("black")
    mark(c)
    c.text("FT " + r["date"], RIGHT, HEAD_Y, font = "4x5", color = GRAY, align = "right")

    # Hero row, scorebug style: the outcome chip is placed first against
    # the right edge, then the score is fit and centered in what's left.
    label, bg, fg = OUTCOME[outcome_key(r["score_for"], r["score_against"])]
    chip_x = RIGHT - chip_width(c, label, "5x7b") + 1
    chip(c, label, chip_x, HERO_Y + 2, 11, "5x7b", fg, bg)
    score = "%d-%d" % (r["score_for"], r["score_against"])
    s, sf = fit_clip(c, score, ["10x16_bold", "6x8"], chip_x - 3 - CANNON_X)
    c.text(s, (CANNON_X + chip_x - 3) // 2, HERO_Y + (HERO_H - FONTH[sf]) // 2,
           font = sf, color = WHITE, align = "center")

    versus(c, r["opponent"])

def table(c, ctx):
    row, state = fetch_table_row(ctx.now)
    if state == "offline":
        nodata(c, "TABLE", "NO DATA", "TRY LATER")
        return
    if state == "empty" or state == "outside_top5":
        # Not "empty" (that's a happy zero) and not a network error either —
        # the free lookup only covers the top 5 rows, so treat it like the
        # nodata card: amber, informational.
        nodata(c, "TABLE", "NOT RANKED", "TOP 5 ONLY")
        return

    c.fill("black")
    mark(c)
    c.text("PL TABLE", RIGHT, HEAD_Y, font = "4x5", color = GRAY, align = "right")

    # Hero, left zone (x1-31): league position as an ordinal, the suffix
    # set small against the top of the number.
    n = str(row["rank"])
    suffix = ordinal(row["rank"])
    nw = c.text_width(n, font = "10x16_bold")
    x = 16 - (nw + 1 + c.text_width(suffix, font = "4x5")) // 2
    c.text(n, x, HERO_Y, font = "10x16_bold", color = WHITE)
    c.text(suffix, x + nw + 1, HERO_Y, font = "4x5", color = WHITE)

    # Right zone (x35-63): points, then goal difference.
    pts = str(row["points"])
    pw = c.text_width(pts, font = "6x8")
    c.text(pts, 35, HERO_Y + 1, font = "6x8", color = WHITE)
    c.text("PTS", 35 + pw + 2, HERO_Y + 4, font = "4x5", color = GRAY)
    gd = row["goal_diff"]
    gd_str = "+%d" % gd if gd > 0 else str(gd)
    c.text("GD", 35, HERO_Y + 11, font = "4x5", color = GRAY)
    c.text(gd_str, 35 + c.text_width("GD", font = "4x5") + 3, HERO_Y + 11, font = "4x5", color = WHITE)

    # Footer: last five results as W/D/L letters, most recent on the right.
    form = row["form"]
    if len(form) > 5:
        form = form[len(form) - 5:]
    if form:
        c.text("FORM", CANNON_X, FOOT_Y, font = "4x5", color = GRAY)
        for i in range(len(form)):
            c.text(form[i], RIGHT - (len(form) - 1 - i) * 8, FOOT_Y, font = "4x5",
                   color = FORM_COLOR.get(form[i], GRAY), align = "right")
