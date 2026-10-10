# Arsenal FC — a GDN Starlark app (192x32 SCROLL, 3 pages).
#
# DESIGN. Arsenal colors only — red, white, black, and shades of them, on a
# black ground (no green, no amber/gold): a loss is bold red, a draw a
# lighter red tint, a win white. This is the scroll build's own layout, not
# the 64px classic build stretched wide. The red cannon mark (48x22) stands
# on the black ground at the left of the safe zone (x8), closed off by a dim
# red rule, and everything else sits in the content band x63-183 — nothing
# touches the neighbor apps playing at either edge. Every page is a 9px
# header row (a state chip or tag left, competition or context right) over
# a band (y10-31) split by a hairline into a hero zone and a detail zone.
# Three pages rotate: MATCH (the live score while Arsenal are playing,
# otherwise the next fixture), RESULT (last final score with a
# WIN/DRAW/LOSS chip), TABLE (league position, points, goal difference,
# last-5 form). No inputs but one: a kickoff time zone (see TZ_OFFSET) —
# this is otherwise Arsenal, always.
#
# LOGO. assets/cannon.png is Arsenal's own 1921-22 club crest — a real,
# public-domain historical mark (see README.md for provenance and why the
# modern shield crest doesn't work at this resolution), thresholded to a
# single Arsenal red at 48x22px — roughly the minimum width where the wheel
# spokes and barrel stay legible; the 64px classic build only has room for
# a rougher ~20px rendition of the same source.
#
# DATA. TheSportsDB (team id 133604, league id 4328), shared free "3" test
# key — no signup, no api-key input. Same three trade-offs as the classic
# build: the free table lookup only returns the top 5 rows; kickoff time
# is converted from the fixture's own local (UK) time using a fixed
# standard-time offset (no daylight-saving adjustment); and MATCH scans the
# whole cross-sport livescore feed for Arsenal's team id. Refresh 300s.

RED = "#EF0107"
RED_LIGHT = "#FF6B61"  # draw / live minute / kickoff — a lighter tint of brand red
WHITE = "white"
GRAY = "gray"
RULE = "#5A0004"     # dim brand red: closes off the cannon mark
DIVIDER = "#3A3A3A"  # hairline between hero and detail zones
NODATA_BG = "#0B0C12"
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"

TEAM_ID = "133604"
LEAGUE_ID = "4328"

# The grid every page shares (see DESIGN).
CANNON_X = 8  # the 48x22 mark spans x8-55, y5-26
CANNON_Y = 5
RULE_X = 59
X0 = 63       # content band, inside the safe zone
X1 = 183
HEAD_Y = 2    # 4x5 text on the 9px header row
BAND_Y = 10   # hero/detail band, y10-31
BAND_H = 22

HERO_FONTS = ["16x20_bold", "10x16_bold", "6x8"]

FONTH = {
    "16x20_bold": 20, "10x16": 16, "10x16_bold": 16, "7x12": 12,
    "6x8": 8, "5x7": 7, "5x7b": 7, "4x5": 5,
}

MONTHS = {
    "01": "JAN", "02": "FEB", "03": "MAR", "04": "APR",
    "05": "MAY", "06": "JUN", "07": "JUL", "08": "AUG",
    "09": "SEP", "10": "OCT", "11": "NOV", "12": "DEC",
}

WEEKDAYS = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]

COMP_SHORT = {
    "ENGLISH PREMIER LEAGUE": "PREMIER LEAGUE",
    "UEFA CHAMPIONS LEAGUE": "UCL",
    "UEFA EUROPA LEAGUE": "UEL",
    "UEFA EUROPA CONFERENCE LEAGUE": "UECL",
    "FA CUP": "FA CUP",
    "EFL CUP": "EFL CUP",
    "FA COMMUNITY SHIELD": "COMMUNITY SHIELD",
    "EMIRATES CUP": "FRIENDLY",
    "CLUB FRIENDLIES": "FRIENDLY",
}

# Kickoff times come from the API in the fixture's own (UK) local time.
# Fixed standard-time offsets from UK — not DST-adjusted: doing that
# correctly needs a real tz database, which isn't available here.
TZ_OFFSET = {
    "UK": 0, "US EASTERN": -5, "US CENTRAL": -6, "US MOUNTAIN": -7,
    "US PACIFIC": -8, "CENTRAL EUROPE": 1,
}

EUROPEAN_COMPS = {"UCL": True, "UEL": True, "UECL": True}

# 5x5 star — the "big European night" badge, drawn next to the
# competition tag instead of reaching for a new accent color.
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

# The zones are narrower than the full panel, so even here the longest club
# names need shortening — same map as the classic build. Unmapped names
# still fall through fit_clip's hard-clip, so nothing can overflow, but
# every current Premier League club is covered.
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

def short_comp(name):
    up = name.upper()
    return COMP_SHORT.get(up, up)

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
# timezone offset (and a countdown computed) with plain integer math — no
# date library is available in this sandbox, and there's no `while`, so
# this has to stay a couple of `if`s, not a loop (see apply_tz).
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
    """TODAY, TOMORROW, a weekday within the week, or the date further out."""
    if days == 0:
        return "TODAY"
    if days == 1:
        return "TOMORROW"
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
    """The red cannon and its rule, at the left of the safe zone on every page."""
    c.image("cannon.png", CANNON_X, CANNON_Y)
    c.vline(RULE_X, 4, 24, RULE)

def chip(c, text, x0, font, fg, bg):
    """A filled label on the 9px header row, its text centered. Returns its width."""
    # text_width counts the glyph spacing after the last letter, so +3
    # reads as an even 2px pad on both sides.
    w = c.text_width(text, font = font) + 3
    c.rect(x0, 0, x0 + w - 1, 8, fill = bg)
    c.text(text, x0 + 2, (9 - FONTH[font]) // 2, font = font, color = fg)
    return w

def head_meta(c, comp, european, maxw):
    """Competition, right-aligned on the header row; European nights get the star."""
    star_w = 7 if european else 0
    t, f = fit_clip(c, comp, ["4x5"], maxw - star_w)
    c.text(t, X1, HEAD_Y, font = f, color = GRAY, align = "right")
    if european:
        c.bitmap(STAR, X1 - c.text_width(t, font = f) - 6, HEAD_Y, color = WHITE)

def split(c, x):
    """Hairline between a page's hero zone and its detail zone."""
    c.vline(x, 12, 18, DIVIDER)

def hero(c, text, fonts, x0, x1, color):
    """The page's one big value: fit to its zone, centered in the band."""
    t, f = fit_clip(c, text, fonts, x1 - x0 + 1)
    c.text(t, (x0 + x1) // 2, BAND_Y + (BAND_H - FONTH[f] + 1) // 2,
           font = f, color = color, align = "center")

def state_card(c, page, title, sub, title_color, sub_color, bg):
    """Fallback card on the same grid: which page, what happened, what it means."""
    c.fill(bg)
    mark(c)
    c.text(page, X0, HEAD_Y, font = "4x5", color = GRAY)
    cx = (X0 + X1) // 2
    t, tf = fit_clip(c, title, ["6x8", "5x7", "4x5"], X1 - X0 + 1)
    c.text(t, cx, 13, font = tf, color = title_color, align = "center")
    s, sf = fit_clip(c, sub, ["4x5"], X1 - X0 + 1)
    c.text(s, cx, 24, font = sf, color = sub_color, align = "center")

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
    comp = short_comp(e.get("strLeague") or "")
    y, m, d = parse_iso_date(e.get("dateEvent") or "0000-01-01")
    hh, mm = parse_hms(e.get("strTimeLocal") or e.get("strTime") or "00:00:00")
    y, m, d, hh, mm = apply_tz(y, m, d, hh, mm, tz_offset)
    return {
        "opponent": short_club(opponent or "TBD"),
        "home": home,
        "comp": comp,
        "european": EUROPEAN_COMPS.get(comp, False),
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
    comp = short_comp(r.get("strLeague") or "")
    y, m, d = parse_iso_date(r.get("dateEvent") or "0000-01-01")
    return {
        "opponent": short_club(opponent or "TBD"),
        "home": home,
        "score_for": home_score if home else away_score,
        "score_against": away_score if home else home_score,
        "comp": comp,
        "european": EUROPEAN_COMPS.get(comp, False),
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
    comp = short_comp((best.get("competition") or {}).get("name") or "")
    y, m, d = parse_iso_date((best.get("utcDate") or "0000-01-01T00:00:00Z")[0:10])
    return {
        "opponent": short_club(opponent or "TBD"),
        "home": is_home,
        "score_for": home_score if is_home else away_score,
        "score_against": away_score if is_home else home_score,
        "comp": comp,
        "european": EUROPEAN_COMPS.get(comp, False),
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
                "played": int(row.get("intPlayed") or 0),
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
        comp = short_comp(row.get("strLeague") or "")
        return {
            "opponent": short_club(opponent or "TBD"),
            "home": home,
            "score_for": home_score if home else away_score,
            "score_against": away_score if home else home_score,
            "minute": minute,
            "comp": comp,
            "european": EUROPEAN_COMPS.get(comp, False),
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
        empty_state(c, "MATCH", "NO FIXTURE", "NOT SCHEDULED YET")
        return
    draw_next(c, fx)

def draw_live(c, m):
    c.fill("black")
    mark(c)

    # Header: LIVE chip and the minute left, competition right.
    w = chip(c, "LIVE", X0, "4x5", WHITE, RED)
    c.text(m["minute"], X0 + w + 3, HEAD_Y, font = "4x5", color = RED_LIGHT)
    used = w + 3 + c.text_width(m["minute"], font = "4x5")
    head_meta(c, m["comp"], m["european"], X1 - X0 + 1 - used - 6)

    # Score is the hero, in white — the match isn't decided yet.
    hero(c, "%d-%d" % (m["score_for"], m["score_against"]), HERO_FONTS, X0, 120, WHITE)
    split(c, 125)

    zx = (130 + X1) // 2
    name, nf = fit_clip(c, m["opponent"], ["5x7", "4x5"], X1 - 130 + 1)
    c.text(name, zx, 13, font = nf, color = WHITE, align = "center")
    ha = "HOME" if m["home"] else "AWAY"
    c.text(ha, zx, 24, font = "4x5", color = GRAY, align = "center")

def draw_next(c, fx):
    c.fill("black")
    mark(c)

    # Header: HOME/AWAY MATCH left, competition right.
    ha = "HOME" if fx["home"] else "AWAY"
    c.text(ha, X0, HEAD_Y, font = "4x5", color = WHITE)
    mx = X0 + c.text_width(ha, font = "4x5") + 4
    c.text("MATCH", mx, HEAD_Y, font = "4x5", color = GRAY)
    used = mx - X0 + c.text_width("MATCH", font = "4x5")
    head_meta(c, fx["comp"], fx["european"], X1 - X0 + 1 - used - 6)

    # Hero: the opponent, as big as the name allows.
    hero(c, fx["opponent"], ["10x16", "7x12", "5x7", "4x5"], X0, 127, WHITE)
    split(c, 132)

    # Detail: kickoff day over kickoff time.
    zx = (137 + X1) // 2
    day, df = fit_clip(c, fx["day"], ["5x7b", "5x7", "4x5"], X1 - 137 + 1)
    c.text(day, zx, 12, font = df, color = WHITE, align = "center")
    tm, tf = fit_clip(c, fx["time"], ["5x7", "4x5"], X1 - 137 + 1)
    c.text(tm, zx, 22, font = tf, color = RED_LIGHT, align = "center")

def result(c, ctx):
    r, state = fetch_last_result(ctx.now, ctx.inputs.get("apikey", ""))
    if state == "offline":
        nodata(c, "RESULT", "NO DATA", "TRY LATER")
        return
    if state == "empty":
        empty_state(c, "RESULT", "NO RESULT", "SEASON NOT STARTED")
        return

    c.fill("black")
    mark(c)

    # Header: WIN/DRAW/LOSS chip and FT left, competition right.
    label, bg, fg = OUTCOME[outcome_key(r["score_for"], r["score_against"])]
    w = chip(c, label, X0, "5x7b", fg, bg)
    c.text("FT", X0 + w + 3, HEAD_Y, font = "4x5", color = GRAY)
    used = w + 3 + c.text_width("FT", font = "4x5")
    head_meta(c, r["comp"], r["european"], X1 - X0 + 1 - used - 6)

    hero(c, "%d-%d" % (r["score_for"], r["score_against"]), HERO_FONTS, X0, 120, WHITE)
    split(c, 125)

    # Detail: the opponent over the date and venue.
    zx = (130 + X1) // 2
    name, nf = fit_clip(c, r["opponent"], ["5x7", "4x5"], X1 - 130 + 1)
    c.text(name, zx, 13, font = nf, color = WHITE, align = "center")
    ha = "HOME" if r["home"] else "AWAY"
    c.text(r["date"] + "  " + ha, zx, 24, font = "4x5", color = GRAY, align = "center")

def table(c, ctx):
    row, state = fetch_table_row(ctx.now)
    if state == "offline":
        nodata(c, "TABLE", "NO DATA", "TRY LATER")
        return
    if state == "empty" or state == "outside_top5":
        # Not "empty" (that's a happy zero) and not a network error either —
        # the free lookup only covers the top 5 rows.
        nodata(c, "TABLE", "NOT RANKED", "TOP 5 ONLY ON THE FREE FEED")
        return

    c.fill("black")
    mark(c)
    c.text("PREMIER LEAGUE", X0, HEAD_Y, font = "4x5", color = GRAY)
    c.text("%d PLAYED" % row["played"], X1, HEAD_Y, font = "4x5", color = GRAY, align = "right")

    # Hero zone (x63-112): league position as an ordinal, the suffix set
    # small against the top of the number.
    n = str(row["rank"])
    suffix = ordinal(row["rank"])
    nw = c.text_width(n, font = "16x20_bold")
    x = (X0 + 112) // 2 - (nw + 1 + c.text_width(suffix, font = "5x7")) // 2
    c.text(n, x, BAND_Y + 1, font = "16x20_bold", color = WHITE)
    c.text(suffix, x + nw + 1, BAND_Y + 1, font = "5x7", color = WHITE)
    split(c, 117)

    # Detail zone (x122-183): points and goal difference, then form.
    dx = 122
    pts = str(row["points"])
    pw = c.text_width(pts, font = "6x8")
    c.text(pts, dx, 11, font = "6x8", color = WHITE)
    c.text("PTS", dx + pw + 2, 14, font = "4x5", color = GRAY)
    gd = row["goal_diff"]
    gd_str = "+%d" % gd if gd > 0 else str(gd)
    c.text(gd_str, X1, 14, font = "4x5", color = WHITE, align = "right")
    c.text("GD", X1 - c.text_width(gd_str, font = "4x5") - 3, 14, font = "4x5",
           color = GRAY, align = "right")

    # Last five results as W/D/L letters, most recent on the right.
    form = row["form"]
    if len(form) > 5:
        form = form[len(form) - 5:]
    if form:
        c.text("FORM", dx, 24, font = "4x5", color = GRAY)
        for i in range(len(form)):
            c.text(form[i], X1 - (len(form) - 1 - i) * 8, 23, font = "5x7b",
                   color = FORM_COLOR.get(form[i], GRAY), align = "right")
