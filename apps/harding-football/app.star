# Harding Football — Harding Bisons NCAA Division II score on a 64x32 Glance panel.
#
# DESIGN. A two-row scoreboard, the way a stadium board reads: a 7px header
# (football icon + game status), then away team over home team, name on the
# left and score on the right. Harding is always gold, the opponent white.
# Before kickoff the body becomes the matchup and the kickoff time instead.
# No settings: the app is one team, one feed.
#
# Data comes straight from the NCAA scoreboard feed (via the free
# ncaa-api.henrygd.me proxy, which repackages the NCAA's own feed as JSON).
# No bridge needed: the feed is a plain public GET, which is all Glance
# apps can do. The feed URL below returns the CURRENT week's D-II games;
# the app finds the one with Harding in it.
#
# Feed game shape (one entry of data["games"]):
#   {"game": {"gameID": "6605451",
#             "away": {"score": "0", "names": {"char6": "S NAZ",
#                      "short": "Southern Nazarene", "seo": "southern-nazarene"}},
#             "home": {"score": "56", "names": {"char6": "HARDNG",
#                      "short": "Harding", "seo": "harding"}},
#             "gameState": "live", "currentPeriod": "3RD",
#             "contestClock": "01:47", "startTime": "4:00 PM ET",
#             "startDate": "11/07/2026", "finalMessage": ""}}
# gameState is "pre", "live", or "final". Scores are "" before kickoff.

DEFAULT_FEED = "https://ncaa-api.henrygd.me/scoreboard/football/d2/current/all-conf"
WEEK_FEED = "https://ncaa-api.henrygd.me/scoreboard/football/d2/%d/%d/all-conf"

GOLD = "amber"
DIM = "#6E7A94"
RULE = "#4A3800"  # dim gold hairline under the header

# 9x5 football for the header: the app's identity mark.
BALL = [
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 1, 0, 0],
]

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
WEEKDAYS = ["THU", "FRI", "SAT", "SUN", "MON", "TUE", "WED"]  # epoch day 0 was a Thursday

def _days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _civil_year(day):
    # Epoch day -> calendar year.
    z = day + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    return yoe + era * 400 + (1 if mp >= 10 else 0)

def season_week(ctx):
    # Returns (season_year, week). NCAA weeks run Sunday-Saturday and week 1
    # is Labor Day weekend, so week 1's Sunday is 8 days before Labor Day
    # (2026: Labor Day Sep 7 -> Sunday Aug 30). Only used for the bye-week
    # fallback fetch of the previous week's feed.
    day = ctx.now.unix // 86400
    year = _civil_year(day)
    sep1 = _days_from_civil(year, 9, 1)
    labor_day = sep1 + (4 - sep1) % 7  # first Monday; epoch day 0 was a Thursday
    w = (day - (labor_day - 8)) // 7 + 1
    if w < 1:
        w = 1
    if w > 16:
        w = 16
    return year, w

def fetch(url):
    resp = http.get(url, ttl_seconds = 300)
    if resp["status_code"] != 200:
        return None, resp["status_code"]
    data = resp["json"]
    if data == None:
        return None, resp["status_code"]
    return data, resp["status_code"]

def find_harding(data):
    if data == None:
        return None
    games = data.get("games", None)
    if games == None:
        return None
    for entry in games:
        game = entry.get("game", None)
        if game == None:
            continue
        for side in ["home", "away"]:
            team = game.get(side, None)
            if team == None:
                continue
            names = team.get("names", None)
            if names != None and names.get("seo", "") == "harding":
                return game
    return None

def team_names(game):
    # Returns (harding_is_home, opp_code, opp_short), both upper-cased.
    home = game["home"]
    away = game["away"]
    if home["names"].get("seo", "") == "harding":
        opp = away
        harding_home = True
    else:
        opp = home
        harding_home = False
    code = opp["names"].get("char6", "")
    if code == "":
        code = opp["names"].get("short", "OPP")[:6].upper()
    return harding_home, code.upper(), opp["names"].get("short", "").upper()

def scores(game, harding_home):
    # Returns (harding_score, opp_score) as strings, "" when not started.
    if harding_home:
        return game["home"].get("score", ""), game["away"].get("score", "")
    return game["away"].get("score", ""), game["home"].get("score", "")

def ct_kickoff(start_time):
    # "4:00 PM ET" -> "3:00PM" (Central is 1 hour behind Eastern).
    parts = start_time.split(" ")
    if len(parts) < 2:
        return start_time
    hm = parts[0].split(":")
    if len(hm) < 2 or not hm[0].isdigit():
        return ""  # "TBA" and friends: no time to show
    h = int(hm[0])
    minute = hm[1]
    mer = parts[1]
    h24 = h % 12
    if mer == "PM":
        h24 += 12
    h24 = (h24 - 1) % 24
    h12 = h24 % 12
    if h12 == 0:
        h12 = 12
    mer2 = "PM" if h24 >= 12 else "AM"
    return str(h12) + ":" + minute + mer2

def kickoff_day(start_date):
    # "11/07/2026" -> "SAT NOV 7".
    parts = start_date.split("/")
    if len(parts) < 3 or not (parts[0].isdigit() and parts[1].isdigit() and parts[2].isdigit()):
        return ""
    m = int(parts[0])
    if m < 1 or m > 12:
        return ""
    d = int(parts[1])
    y = int(parts[2])
    wd = WEEKDAYS[_days_from_civil(y, m, d) % 7]
    return wd + " " + MONTHS[m - 1] + " " + str(d)

def strip_leading_zero(clock):
    if clock.startswith("0") and len(clock) > 1:
        return clock[1:]
    return clock

def fit(c, text, fonts, maxw):
    # Largest font in the ladder that fits maxw; if none does, hard-clip the
    # text in the smallest one. Nothing in the drawing API clips for us.
    for f in fonts:
        if c.text_width(text, font = f) <= maxw:
            return text, f
    f = fonts[-1]
    for _ in range(len(text)):
        if len(text) <= 1 or c.text_width(text, font = f) <= maxw:
            break
        text = text[:-1].strip()
    return text, f

def header(c, label, color):
    # Football, then the title or game status, one hairline underneath.
    c.bitmap(BALL, 1, 1, "#B5651D")
    c.line(3, 3, 7, 3, "white")
    label, f = fit(c, label, ["4x5"], 51)  # 64 - 12 (ball + gap) - 1 margin
    c.text(label, 12, 1, font = f, color = color)
    c.line(0, 7, 63, 7, RULE)

def score_row(c, y, name, score, name_color, score_color):
    # Score is measured first (right-aligned at the edge); the name gets
    # whatever is left, minus a 3px gutter.
    sw = c.text_width(score, font = "8x10")
    c.text(score, 63, y, font = "8x10", color = score_color, align = "right")
    name, f = fit(c, name, ["5x7", "4x5"], 63 - sw - 3 - 1)
    c.text(name, 1, y + (2 if f == "5x7" else 3), font = f, color = name_color)

def message(c, title, sub):
    header(c, "HARDING", GOLD)
    title, f = fit(c, title, ["6x8", "5x7", "4x5"], 62)
    c.text(title, 32, 12, font = f, color = "white", align = "center")
    sub, f = fit(c, sub, ["4x5"], 62)
    c.text(sub, 32, 24, font = f, color = DIM, align = "center")

def as_int(s):
    return int(s) if s.isdigit() else 0

def main(c, ctx):
    c.clear()

    data, status = fetch(DEFAULT_FEED)
    game = find_harding(data)

    # No Harding game in the current week's feed (bye week, or the feed
    # rolled over): fall back to last week's feed so the panel still shows
    # the most recent final instead of going blank.
    if game == None and data != None:
        year, week = season_week(ctx)
        if week > 1:
            data2, _status2 = fetch(WEEK_FEED % (year, week - 1))
            game = find_harding(data2)

    if data == None:
        message(c, "NO SCORES", "FEED OFFLINE" if status == 0 else "FEED ERROR " + str(status))
        return

    if game == None:
        message(c, "NO GAME", "THIS WEEK")
        return

    harding_home, opp_code, opp_short = team_names(game)
    state = game.get("gameState", "")

    if state == "pre":
        # Before kickoff: matchup, then the kickoff time as the hero.
        header(c, "HARDING", GOLD)
        opp = opp_short if opp_short != "" else opp_code
        prefix = "VS " if harding_home else "AT "
        full = prefix + opp
        if c.text_width(full, font = "4x5") > 62:
            full = prefix + opp_code  # "ARKANSAS-MONTICELLO" -> "ARK MO"
        full, f = fit(c, full, ["5x7", "4x5"], 62)
        c.text(full, 32, 10 if f == "5x7" else 11, font = f, color = "white", align = "center")

        day = kickoff_day(game.get("startDate", ""))  # "SAT NOV 14"
        kick = ct_kickoff(game.get("startTime", ""))  # "2:00PM", Central
        if kick == "":
            hero, foot = (day if day != "" else "TBA"), "TIME TBA"
        else:
            weekday = day.split(" ")[0] if day != "" else ""
            hero = (weekday + " " + kick).strip()
            # "NOV 14 CENTRAL" is 69px at 4x5, 5px too wide, hence "CT".
            foot = (" ".join(day.split(" ")[1:]) + " CT").strip()
        hero, f = fit(c, hero, ["6x8", "5x7", "4x5"], 62)
        c.text(hero, 32, 18, font = f, color = GOLD, align = "center")
        foot, f = fit(c, foot, ["4x5"], 62)
        c.text(foot, 32, 27, font = f, color = DIM, align = "center")
        return

    h_score, o_score = scores(game, harding_home)
    h_score = str(as_int(h_score))
    o_score = str(as_int(o_score))
    h_col = GOLD
    o_col = "white"

    if state == "final":
        if as_int(h_score) > as_int(o_score):
            label, col, o_col = "FINAL", "green", DIM
        elif as_int(h_score) < as_int(o_score):
            label, col, h_col = "FINAL", "red", "#7A5A00"
        else:
            label, col = "FINAL", DIM
    else:
        # Live: period + clock, e.g. "3RD 1:47".
        period = game.get("currentPeriod", "").upper()
        clock = strip_leading_zero(game.get("contestClock", ""))
        if period in ["HALF", "HALFTIME", "END"] or clock in ["", "0:00"]:
            clock = ""
        label = (period + " " + clock).strip()
        if label == "":
            label = "LIVE"
        col = "green"
    header(c, label, col)

    # Away team on top, home team underneath, like a stadium board.
    rows = [("HARDING", h_score, h_col, h_col), (opp_code, o_score, "white" if o_col == "white" else DIM, o_col)]
    if harding_home:
        rows = [rows[1], rows[0]]
    score_row(c, 10, rows[0][0], rows[0][1], rows[0][2], rows[0][3])
    score_row(c, 21, rows[1][0], rows[1][1], rows[1][2], rows[1][3])
