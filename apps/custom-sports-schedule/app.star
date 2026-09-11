# Custom Sports Schedule -- Prout's next 7 games on a 192x32 panel, LIVE off
# the schedule spreadsheet:
# https://docs.google.com/spreadsheets/d/1RAdODqjHvG5g7sagBCOCgtmuwggMEKTpZcYrktJw1NY
# (gid 0, the "prout schdeule" tab, polled every 60s -- see manifest.yaml's
# refresh: 60) plus the "standings" tab for final-score records.
#
# A "Sport" dropdown (All Sports / Mens Soccer / Womens Soccer / Volleyball)
# filters which games count toward the 7 slots, same as before. Each row's
# Status then drives which of 3 layouts a slot uses:
#   - Upcoming:    logos, "AT", codes, date/time (the original layout)
#   - In Progress: logos, "VS", codes, live score (yellow) from the "final
#     score (home-away)" column (the sheet doubles that column for the live
#     score while a game is in progress, not just the final one), and
#     period/clock on the right if those columns exist -- see
#     PERIOD_COL_CANDIDATES / CLOCK_COL_CANDIDATES below; until they're added
#     to the sheet this just shows "LIVE".
#   - Final:       logos, "vs", codes + records (from the standings tab, when
#     that team's sport section + name match), scores -- winner in its own
#     color, loser gray -- and "WINS" on the right in the winner's color.
#
# Slot 1 (right after the title page) is always "the current thing":
# whichever game (in the selected sport filter) is In Progress, or else the
# most recent Final -- then slots 2-7 fill with the next Upcoming games. Once
# a new game starts, it takes over slot 1 (bumping the old Final), and once
# *that* game finishes, its own Final result becomes slot 1 -- so at most one
# past result is ever shown at a time.
#
# Team logos are still a manual dict below (file:// paths in the sheet's logo
# columns only resolve on the laptop that has those files, not on a deployed
# panel) -- add an entry here when a new opponent shows up in the window.
# Anything not in the dict falls back to a plain colored circle with its
# code's first letter (_draw_badge) -- Barrington, Coventry, Cumberland, and
# South Kingstown already used that fallback even in the old hardcoded
# version, so this is the same behavior, just automatic now.

SHEET_ID = "1RAdODqjHvG5g7sagBCOCgtmuwggMEKTpZcYrktJw1NY"

# export?format=csv 307-redirects to a googleusercontent.com CDN host -- the
# host's http.get now follows that one specific redirect (see
# _is_trusted_export_redirect in gdn/starhost/http_client.py) since it's
# always live, unlike gviz (which can lag real edits by minutes -- too stale
# for a scoreboard that's supposed to update within 60s).
SCHEDULE_CSV_URL = "https://docs.google.com/spreadsheets/d/" + SHEET_ID + "/export?format=csv&gid=0"

# Records aren't as time-sensitive as a live score, so this one stays on
# gviz (by tab name -- no known gid for it, and the export endpoint needs one).
STANDINGS_CSV_URL = "https://docs.google.com/spreadsheets/d/" + SHEET_ID + "/gviz/tq?tqx=out:csv&sheet=standings"

TOTAL_GAME_SLOTS = 7

TEAM_LOGOS = {
    "PROUT": "prout.png",
    "EGHS": "eghs.png",
    "EAST GREENWICH": "eastgreenwich.png",
    "FOXBOROUGH": "foxborough.png",
    "PILGRIM": "pilgrim.png",
    "CHARIHO": "chariho.png",
    "DAVIES C&T": "daviesct.png",
    "CRANSTON WEST": "cranstonwest.png",
    "JUANITA": "juanita.png",
    "LINCOLN": "lincoln.png",
    "MIDDLETOWN": "middletown.png",
    "MPHS": "mphs.png",
    "PONAGANSET": "ponaganset.png",
    "BARRINGTON": "barrington.png",
    "SOUTH KINGSTOWN": "southkingstown.png",
    "COVENTRY": "coventry.png",
    "CUMBERLAND": "cumberland.png",
}

SPORT_ICON = {"mens soccer": "soccer_ball.png", "girls soccer": "soccer_ball.png", "volleyball": "volleyball.png"}

# dropdown label -> the sheet's own lowercase "Sport" column value
SPORT_FILTER = {"Mens Soccer": "mens soccer", "Womens Soccer": "girls soccer", "Volleyball": "volleyball"}

MONTHS = {
    "01": "JAN", "02": "FEB", "03": "MAR", "04": "APR", "05": "MAY", "06": "JUN",
    "07": "JUL", "08": "AUG", "09": "SEP", "10": "OCT", "11": "NOV", "12": "DEC",
}

# Named colors the sheet actually uses that aren't in gdn's small NAMED
# palette (gdn/colors.py) -- anything not found here or there falls back to
# white rather than crashing the app on a color gdn doesn't recognize.
COLOR_ALIASES = {
    "maroon": "#800000",
    "navy": "#000080",
    "navy blue": "#000080",
    "gold": "#CEB45A",
    "crimson": "#DC143C",
    "scarlet red": "#8C1515",
    "dark green": "#006400",
    "teal": "#008080",
    "tan": "#CEB45A",
}

GDN_NAMED = ["black", "white", "red", "green", "puregreen", "blue", "yellow", "orange",
             "cyan", "magenta", "gray", "grey", "darkgray", "darkgrey", "midgray",
             "midgrey", "amber", "pink", "purple", "skyblue"]

PERIOD_COL_CANDIDATES = ["period", "quarter", "qtr", "current period"]
CLOCK_COL_CANDIDATES = ["time", "clock", "time remaining", "game clock", "time left"]
PERIOD_ABBREV = {"PREGAME": "PRE", "HALFTIME": "HT", "SHOOTOUT": "SO", "FINAL": "FIN"}

def _color(raw):
    v = (raw or "").strip().lower()
    if v == "":
        return "white"
    if v in GDN_NAMED:
        return v
    if v.startswith("#"):
        return v
    return COLOR_ALIASES.get(v, "white")

def _all_digits(s):
    if s == "":
        return False
    for i in range(len(s)):
        ch = s[i]
        if ch < "0" or ch > "9":
            return False
    return True

def _valid_record(s):
    if not s:
        return False
    parts = s.split("-")
    if len(parts) < 2 or len(parts) > 3:
        return False
    for p in parts:
        if not _all_digits(p) or len(p) > 2:
            return False
    return True

def _collapse_spaces(s):
    out = s
    for _ in range(6):
        out = out.replace("  ", " ")
    return out

def _norm_name(s):
    return _collapse_spaces(s.replace("\n", " ").replace("\r", " ")).strip().upper()

def _fmt_date(d):
    parts = d.strip().split("-")
    if len(parts) != 3:
        return d
    mon = MONTHS.get(parts[1], parts[1])
    day = str(int(parts[2])) if _all_digits(parts[2]) else parts[2]
    return mon + " " + day

def _fmt_time(t):
    t = t.strip().upper().replace(" ", "")
    if t.endswith("PM"):
        return t[:-2] + "P"
    if t.endswith("AM"):
        return t[:-2] + "A"
    return t

def _find_col(headers, candidates):
    for cand in candidates:
        for i in range(len(headers)):
            if headers[i].strip().lower() == cand:
                return i
    return -1

def _cell(row, i):
    if i < 0 or i >= len(row):
        return ""
    return row[i].strip()

# ---- a small quoted-CSV parser (handles commas and embedded newlines inside
# quoted fields, and "" as an escaped quote) -- the sheet's real data has
# both, so a plain split(",")/split("\n") would silently corrupt rows. ----
def _parse_csv(text):
    rows = []
    row = []
    field = ""
    in_quotes = False
    skip_next = False
    n = len(text)
    for i in range(n):
        if skip_next:
            skip_next = False
            continue
        ch = text[i]
        if in_quotes:
            if ch == "\"":
                if i + 1 < n and text[i + 1] == "\"":
                    field += "\""
                    skip_next = True
                else:
                    in_quotes = False
            else:
                field += ch
        else:
            if ch == "\"":
                in_quotes = True
            elif ch == ",":
                row.append(field)
                field = ""
            elif ch == "\r":
                pass
            elif ch == "\n":
                row.append(field)
                rows.append(row)
                row = []
                field = ""
            else:
                field += ch
    if field != "" or len(row) > 0:
        row.append(field)
        rows.append(row)
    return rows

def _draw_badge(c, x, y, size, color, letter):
    r = size // 2
    c.fill_circle(x + r, y + r, r, color)
    c.circle(x + r, y + r, r, "white")
    c.text(letter, x + r, y + r - 3, font = "5x7b", color = "black", align = "center")

def _draw_logo(c, name, x, y, size, color):
    logo = TEAM_LOGOS.get((name or "").strip().upper())
    if logo == None:
        _draw_badge(c, x, y, size, color, (name or "?")[0:1])
    else:
        c.image(logo, x, y, w = size, h = size)

def _load_games(sport_value):
    """sport_value: '' for All Sports, or one of SPORT_FILTER's values."""
    resp = http.get(SCHEDULE_CSV_URL, ttl_seconds = 60)
    if resp["status_code"] != 200 or not resp["body"]:
        return []
    rows = _parse_csv(resp["body"])
    if len(rows) < 2:
        return []
    headers = rows[0]
    c_sport = _find_col(headers, ["sport"])
    c_status = _find_col(headers, ["status"])
    c_home_team = _find_col(headers, ["home team"])
    c_home_color = _find_col(headers, ["home color or hex"])
    c_away_team = _find_col(headers, ["away team"])
    c_away_color = _find_col(headers, ["away color or hex"])
    c_date = _find_col(headers, ["game date"])
    c_time = _find_col(headers, ["game time"])
    c_abbrev = _find_col(headers, ["2-4 letter abreviation"])
    c_score = _find_col(headers, ["final score (home-away)"])
    c_period = _find_col(headers, PERIOD_COL_CANDIDATES)
    c_clock = _find_col(headers, CLOCK_COL_CANDIDATES)

    games = []
    for row in rows[1:]:
        home_team = _cell(row, c_home_team)
        away_team = _cell(row, c_away_team)
        if home_team == "" and away_team == "":
            continue
        sport = _cell(row, c_sport).lower()
        if sport_value and sport != sport_value:
            continue

        status = _cell(row, c_status).lower()
        if status == "final":
            status = "final"
        elif status == "in progress":
            status = "in_progress"
        else:
            status = "upcoming"

        abbrev = _cell(row, c_abbrev)
        home_prout = home_team.upper() == "PROUT"
        away_prout = away_team.upper() == "PROUT"
        home_code = "PRT" if home_prout else (abbrev if abbrev else home_team[0:4].upper())
        away_code = "PRT" if away_prout else (abbrev if abbrev else away_team[0:4].upper())

        score_raw = _cell(row, c_score)
        home_score, away_score = None, None
        parts = score_raw.split("-")
        if len(parts) == 2 and _all_digits(parts[0].strip()) and _all_digits(parts[1].strip()):
            home_score = int(parts[0].strip())
            away_score = int(parts[1].strip())

        games.append({
            "sport": sport,
            "status": status,
            "home_team": home_team,
            "home_color": _color(_cell(row, c_home_color)),
            "home_code": home_code,
            "away_team": away_team,
            "away_color": _color(_cell(row, c_away_color)),
            "away_code": away_code,
            "date": _fmt_date(_cell(row, c_date)),
            "time": _fmt_time(_cell(row, c_time)),
            "home_score": home_score,
            "away_score": away_score,
            "period": _cell(row, c_period) if c_period >= 0 else "",
            "clock": _cell(row, c_clock) if c_clock >= 0 else "",
            "icon": SPORT_ICON.get(sport, "soccer_ball.png"),
        })

    recent = None
    for g in games:
        if g["status"] == "in_progress":
            recent = g
            break
    if recent == None:
        for g in games:
            if g["status"] == "final":
                recent = g  # keep overwriting -- last Final in sheet order wins
    slides = []
    if recent != None:
        slides.append(recent)
    remaining = TOTAL_GAME_SLOTS - len(slides)
    for g in games:
        if len(slides) >= TOTAL_GAME_SLOTS:
            break
        if g["status"] == "upcoming" and remaining > 0:
            slides.append(g)
            remaining -= 1
    return slides

def _load_standings():
    """sport (sheet's lowercase value) -> {team name upper: record 'W-L' or 'W-L-T'}."""
    resp = http.get(STANDINGS_CSV_URL, ttl_seconds = 60)
    result = {}
    if resp["status_code"] != 200 or not resp["body"]:
        return result
    rows = _parse_csv(resp["body"])
    current_sport = None
    for row in rows:
        c0 = _cell(row, 0)
        c1 = _cell(row, 1)
        if c1.upper().startswith("W-L"):
            title = c0
            if title.upper().endswith(" TEAM"):
                title = title[:-5]
            current_sport = title.strip().lower()
            if current_sport not in result:
                result[current_sport] = {}
            continue
        if current_sport == None or c1 == "":
            continue
        record = _cell(row, 6)
        if _valid_record(record):
            result[current_sport][_norm_name(c1)] = record
    return result

def _record_for(standings, sport, team_name):
    section = standings.get(sport)
    if section == None:
        return ""
    return section.get(_norm_name(team_name), "")

# ---- shared layout geometry (upcoming / in-progress / final all use it) ----
LOGO_SIZE = 26
LOGO_Y = 3
RIGHT_X = 190

# Sport-icon column, shown on upcoming/final slots when "All Sports" is
# selected (each game gets its own ball icon since the codes alone don't say
# which sport). In-progress never shows it -- that slot needs the room for
# the live score and period/clock instead.
ICON_SIZE = 20
ICON_X = 4
ICON_CX = ICON_X + ICON_SIZE // 2
AWAY_X_ICON = ICON_X + ICON_SIZE + 8
HOME_X_ICON = AWAY_X_ICON + LOGO_SIZE + 12

AWAY_X_PLAIN = 2
HOME_X_PLAIN = AWAY_X_PLAIN + LOGO_SIZE + 12

def _sport_letter(sport):
    if "mens" in sport:
        return "M"
    if "girls" in sport:
        return "W"
    return None

def _draw_sport_icon(c, g, show_icon):
    """Returns (away_x, home_x) for the logo columns, drawing the sport ball
    on the far left first when show_icon is True."""
    if not show_icon:
        return AWAY_X_PLAIN, HOME_X_PLAIN
    letter = _sport_letter(g["sport"])
    if letter != None:
        c.text(letter, ICON_CX, 1, font = "4x5", color = "white", align = "center")
        c.image(g["icon"], ICON_X, 9, w = ICON_SIZE, h = ICON_SIZE)
    else:
        c.image(g["icon"], ICON_X, (c.height - ICON_SIZE) // 2, w = ICON_SIZE, h = ICON_SIZE)
    return AWAY_X_ICON, HOME_X_ICON

def _draw_upcoming(c, g, show_icon):
    c.fill("black")
    away_x, home_x = _draw_sport_icon(c, g, show_icon)
    info_x = home_x + LOGO_SIZE + 10

    _draw_logo(c, g["away_team"], away_x, LOGO_Y, LOGO_SIZE, g["away_color"])
    _draw_logo(c, g["home_team"], home_x, LOGO_Y, LOGO_SIZE, g["home_color"])
    at_x = (away_x + LOGO_SIZE + home_x) // 2
    c.text("AT", at_x, LOGO_Y + LOGO_SIZE // 2 - 5, font = "4x5", color = "gray", align = "center")
    c.text(g["away_code"], info_x, 3, font = "5x7b", color = g["away_color"])
    c.text(g["home_code"], info_x, 17, font = "5x7b", color = g["home_color"])
    name_w = max(c.text_width(g["away_code"], "5x7b"), c.text_width(g["home_code"], "5x7b"))
    dt_x = info_x + name_w + 8
    c.text(g["date"], dt_x, 3, font = "4x5", color = "white")
    c.text(g["time"], dt_x, 17, font = "4x5", color = "gray")

def _draw_in_progress(c, g):
    c.fill("black")
    away_x, home_x = AWAY_X_PLAIN, HOME_X_PLAIN
    info_x = home_x + LOGO_SIZE + 10
    score_x = info_x + 34

    _draw_logo(c, g["away_team"], away_x, LOGO_Y, LOGO_SIZE, g["away_color"])
    _draw_logo(c, g["home_team"], home_x, LOGO_Y, LOGO_SIZE, g["home_color"])
    vs_x = (away_x + LOGO_SIZE + home_x) // 2
    c.text("VS", vs_x, LOGO_Y + LOGO_SIZE // 2 - 5, font = "4x5", color = "gray", align = "center")

    c.text(g["away_code"], info_x, 2, font = "5x7b", color = g["away_color"])
    c.text(g["home_code"], info_x, 18, font = "5x7b", color = g["home_color"])
    away_score = str(g["away_score"]) if g["away_score"] != None else "0"
    home_score = str(g["home_score"]) if g["home_score"] != None else "0"
    c.text(away_score, score_x, 1, font = "10x16_bold", color = "yellow")
    c.text(home_score, score_x, 17, font = "10x16_bold", color = "yellow")

    if g["period"] or g["clock"]:
        period_txt = PERIOD_ABBREV.get(g["period"].upper(), g["period"][:3].upper()) if g["period"] else ""
        c.text(period_txt, RIGHT_X, 4, font = "4x5", color = "white", align = "right")
        c.text(g["clock"], RIGHT_X, 17, font = "4x5", color = "white", align = "right")
    else:
        c.text("LIVE", RIGHT_X, 13, font = "4x5", color = "red", align = "right")

def _draw_final(c, g, standings, show_icon):
    c.fill("black")
    away_x, home_x = _draw_sport_icon(c, g, show_icon)
    info_x = home_x + LOGO_SIZE + 10
    score_x = info_x + 34

    _draw_logo(c, g["away_team"], away_x, LOGO_Y, LOGO_SIZE, g["away_color"])
    _draw_logo(c, g["home_team"], home_x, LOGO_Y, LOGO_SIZE, g["home_color"])
    vs_x = (away_x + LOGO_SIZE + home_x) // 2
    c.text("vs", vs_x, LOGO_Y + LOGO_SIZE // 2 - 5, font = "4x5", color = "gray", align = "center")

    have_scores = g["away_score"] != None and g["home_score"] != None
    away_win = have_scores and g["away_score"] > g["home_score"]
    home_win = have_scores and g["home_score"] > g["away_score"]
    away_code_color = g["away_color"] if (away_win or not have_scores) else "midgray"
    home_code_color = g["home_color"] if (home_win or not have_scores) else "midgray"
    away_score_color = g["away_color"] if (away_win or not have_scores) else "midgray"
    home_score_color = g["home_color"] if (home_win or not have_scores) else "midgray"

    c.text(g["away_code"], info_x, 2, font = "5x7b", color = away_code_color)
    c.text(g["home_code"], info_x, 18, font = "5x7b", color = home_code_color)

    away_record = _record_for(standings, g["sport"], g["away_team"])
    home_record = _record_for(standings, g["sport"], g["home_team"])
    if away_record:
        c.text("(" + away_record + ")", info_x, 10, font = "4x5", color = "gray")
    if home_record:
        c.text("(" + home_record + ")", info_x, 26, font = "4x5", color = "gray")

    away_score = str(g["away_score"]) if g["away_score"] != None else "0"
    home_score = str(g["home_score"]) if g["home_score"] != None else "0"
    c.text(away_score, score_x, 1, font = "10x16_bold", color = away_score_color)
    c.text(home_score, score_x, 17, font = "10x16_bold", color = home_score_color)

    if have_scores:
        winner_code = g["away_code"] if away_win else g["home_code"]
        winner_color = g["away_color"] if away_win else g["home_color"]
        c.text(winner_code, RIGHT_X, 4, font = "5x7b", color = winner_color, align = "right")
        c.text("WINS", RIGHT_X, 17, font = "5x7b", color = winner_color, align = "right")
    else:
        c.text("FINAL", RIGHT_X, 13, font = "4x5", color = "white", align = "right")

def _draw_empty(c):
    c.fill("black")
    c.text("NO GAME SCHEDULED", c.width // 2, 13, font = "5x7", color = "gray", align = "center")

def _draw_slide(c, g, show_icon):
    if g["status"] == "in_progress":
        _draw_in_progress(c, g)
    elif g["status"] == "final":
        _draw_final(c, g, _load_standings(), show_icon)
    else:
        _draw_upcoming(c, g, show_icon)

def _page(c, ctx, index):
    sport_label = ctx.inputs.get("sport", "All Sports")
    sport_value = SPORT_FILTER.get(sport_label, "")
    slides = _load_games(sport_value)
    if index < len(slides):
        _draw_slide(c, slides[index], sport_label == "All Sports")
    else:
        _draw_empty(c)

SPORT_LETTER_LABEL = {"Mens Soccer": "M", "Womens Soccer": "W"}
BALL_SIZE_WITH_LETTER = 22
BALL_SIZE_PLAIN = 24

def title(c, ctx):
    c.fill("black")
    sport = ctx.inputs.get("sport", "All Sports")
    text_w = max(c.text_width("UPCOMING", "10x16_bold"), c.text_width("GAMES", "10x16_bold"))

    icon = SPORT_ICON.get(SPORT_FILTER.get(sport, ""), None)
    letter = SPORT_LETTER_LABEL.get(sport, None)
    ball_size = BALL_SIZE_WITH_LETTER if letter != None else BALL_SIZE_PLAIN
    ball_w = ball_size + 6 if icon != None else 0
    block_w = 32 + 4 + text_w + ball_w
    x0 = (c.width - block_w) // 2

    c.image("prout.png", x0, 0, w = 32, h = 32)
    c.text("UPCOMING", x0 + 36, 0, font = "10x16_bold", color = "white")
    c.text("GAMES", x0 + 36, 16, font = "10x16_bold", color = "#800000")
    if icon != None:
        ball_x = x0 + 36 + text_w + 6
        if letter != None:
            c.text(letter, ball_x + ball_size // 2, 0, font = "4x5", color = "white", align = "center")
            c.image(icon, ball_x, 6, w = ball_size, h = ball_size)
        else:
            c.image(icon, ball_x, (c.height - ball_size) // 2, w = ball_size, h = ball_size)

def game1(c, ctx):
    _page(c, ctx, 0)

def game2(c, ctx):
    _page(c, ctx, 1)

def game3(c, ctx):
    _page(c, ctx, 2)

def game4(c, ctx):
    _page(c, ctx, 3)

def game5(c, ctx):
    _page(c, ctx, 4)

def game6(c, ctx):
    _page(c, ctx, 5)

def game7(c, ctx):
    _page(c, ctx, 6)
