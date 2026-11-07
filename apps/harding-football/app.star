# Harding Football — Harding Bisons NCAA Division II score on a 64x32 Glance panel.
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
WEEK_FEED = "https://ncaa-api.henrygd.me/scoreboard/football/d2/2026/%d/all-conf"

# Sunday Aug 30, 2026, as a UTC epoch day: NCAA weeks run Sunday-Saturday,
# and week 1 of the 2026 D-II season started that Sunday. Only used for the
# fallback fetch (previous week) when the current feed has no Harding game.
EPOCH_DAY_WEEK1_SUNDAY = 20695

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

def current_week(ctx):
    day = ctx.now.unix // 86400
    w = (day - EPOCH_DAY_WEEK1_SUNDAY) // 7 + 1
    if w < 1:
        return 1
    if w > 15:
        return 15
    return w

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
    # Returns (harding_is_home, opp_code, opp_short).
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
    return harding_home, code, opp["names"].get("short", "")

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
    if len(parts) < 3:
        return ""
    m = int(parts[0])
    d = int(parts[1])
    y = int(parts[2])
    wd = WEEKDAYS[_days_from_civil(y, m, d) % 7]
    return wd + " " + MONTHS[m - 1] + " " + str(d)

def strip_leading_zero(clock):
    if clock.startswith("0") and len(clock) > 1:
        return clock[1:]
    return clock

def main(c, ctx):
    c.clear()

    feed = ctx.inputs.get("feedurl", "") or ""
    custom_feed = feed != ""
    if not custom_feed:
        feed = DEFAULT_FEED

    data, status = fetch(feed)
    game = find_harding(data)

    # No Harding game in the current week's feed (bye week, or the feed
    # rolled over): fall back to last week's feed so the panel still shows
    # the most recent final instead of going blank. Skipped when a custom
    # feed URL was given, so test renders stay on the URL asked for.
    if game == None and not custom_feed and data != None:
        prev_week = current_week(ctx) - 1
        if prev_week >= 1:
            data2, _status2 = fetch(WEEK_FEED % prev_week)
            game = find_harding(data2)

    if data == None:
        reason = "FEED DOWN"
        if status != 0 and status != 200:
            reason = "HTTP " + str(status)
        c.text("NO DATA", 32, 8, font = "5x7", color = "red", align = "center")
        c.text(reason, 32, 19, font = "4x5", color = "gray", align = "center")
        return

    if game == None:
        c.text("HARDING", 32, 3, font = "5x7", color = "amber", align = "center")
        c.text("NO GAME", 32, 13, font = "5x7", color = "white", align = "center")
        c.text("THIS WEEK", 32, 23, font = "4x5", color = "gray", align = "center")
        return

    harding_home, opp_code, _opp_short = team_names(game)
    state = game.get("gameState", "")

    # Top row: HARDING in gold on the left, opponent's NCAA code on the right.
    c.text("HARDING", 1, 1, font = "5x7", color = "amber")
    c.text(opp_code, 63, 1, font = "5x7", color = "white", align = "right")

    if state == "pre":
        # No score yet: show the kickoff day/time in the middle. The full
        # "SAT NOV 14 3:00PM" line is wider than the 64px panel at 5x7, so
        # only the weekday + time go on the bottom line.
        day = kickoff_day(game.get("startDate", ""))
        kick = ct_kickoff(game.get("startTime", ""))
        c.text("VS", 32, 9, font = "10x16", color = "white", align = "center")
        weekday = day.split(" ")[0] if day != "" else ""
        line = (weekday + " " + kick).strip()
        c.text(line, 32, 25, font = "5x7", color = "gray", align = "center")
        return

    h_score, o_score = scores(game, harding_home)
    if h_score == "":
        h_score = "0"
    if o_score == "":
        o_score = "0"

    # Big scores: Harding's on the left in gold, opponent's on the right.
    c.text(h_score, 1, 10, font = "10x16", color = "amber")
    c.text(o_score, 63, 10, font = "10x16", color = "white", align = "right")
    c.text("-", 32, 12, font = "6x8", color = "midgray", align = "center")

    if state == "final":
        won = int(h_score) > int(o_score)
        col = "green" if won else "red"
        c.text("FINAL", 32, 25, font = "5x7", color = col, align = "center")
    else:
        # Live: period + clock, e.g. "3RD 1:47".
        period = game.get("currentPeriod", "")
        clock = strip_leading_zero(game.get("contestClock", ""))
        status_line = (period + " " + clock).strip()
        if status_line == "":
            status_line = "LIVE"
        c.text(status_line, 32, 25, font = "5x7", color = "green", align = "center")
