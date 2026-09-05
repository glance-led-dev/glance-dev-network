# Del Norte JV Football -- a GDN Starlark app (128x32, 3 pages).
#
# There's no public API for high school sports schedules, and GDN's http
# module only understands JSON (no HTML parsing), so a live scrape of a
# schedule site isn't realistic here. Instead the season schedule below is a
# hardcoded snapshot pulled from MaxPreps for Del Norte HS (San Diego, CA)
# JV football, 2026-27 season:
#   https://www.maxpreps.com/ca/san-diego/del-norte-nighthawks/football/jv/
#
# Update RESULT (and DATE/TIME if the schedule changes) as the season goes --
# there's no way around editing this by hand week to week. Every entry with
# result = None is treated as "not played yet"; the first such entry is the
# "next" game and the last entry WITH a result is the "last" game. That means
# you don't have to touch ctx.now/dates at all to advance the app -- just
# fill in a score after each Friday's game.

YEAR = 2026  # season year -- bump this (and the schedule) each fall

GAMES = [
    # month, day, hour24, minute -- local (San Diego) kickoff time
    {"m": 8, "d": 21, "h": 16, "mi": 30, "opp": "MATER DEI CATHOLIC", "home": True, "result": {"us": 35, "them": 0}},
    {"m": 8, "d": 28, "h": 16, "mi": 0, "opp": "ST AUGUSTINE", "home": True, "result": {"us": 37, "them": 0}},
    {"m": 9, "d": 4, "h": 16, "mi": 30, "opp": "LA COSTA CANYON", "home": True, "result": None},
    {"m": 9, "d": 11, "h": 16, "mi": 30, "opp": "MT CARMEL", "home": True, "result": None},
    {"m": 9, "d": 18, "h": 16, "mi": 0, "opp": "POINT LOMA", "home": False, "result": None},
    {"m": 10, "d": 2, "h": 16, "mi": 15, "opp": "RANCHO BERNARDO", "home": False, "result": None},
    {"m": 10, "d": 9, "h": 16, "mi": 30, "opp": "OCEANSIDE", "home": True, "result": None},
    {"m": 10, "d": 16, "h": 16, "mi": 0, "opp": "POWAY", "home": True, "result": None},
    {"m": 10, "d": 23, "h": 16, "mi": 30, "opp": "EL CAMINO", "home": False, "result": None},
    {"m": 10, "d": 30, "h": 16, "mi": 30, "opp": "CARLSBAD", "home": False, "result": None},
]

TEAM = "DEL NORTE"
TEAM_SHORT = "DN"

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# ---------------------------------------------------------------- date math
# Howard Hinnant's civil_from_days / days_from_civil -- the standard
# allocation-free way to turn a calendar date into a day count (and back)
# using only +, -, *, // . This is what lets us compute a countdown without
# any datetime library, which GDN's Starlark sandbox doesn't have.

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def kickoff_unix(g, tz_offset_hours):
    """Unix seconds (UTC) for a game's local kickoff time."""
    days = days_from_civil(YEAR, g["m"], g["d"])
    local_unix = days * 86400 + g["h"] * 3600 + g["mi"] * 60
    return local_unix - tz_offset_hours * 3600

def date_str(g):
    return MONTHS[g["m"] - 1] + " " + str(g["d"])

def time_str(g):
    h12 = g["h"] % 12
    if h12 == 0:
        h12 = 12
    ap = "PM" if g["h"] >= 12 else "AM"
    mi = ("0" + str(g["mi"])) if g["mi"] < 10 else str(g["mi"])
    return str(h12) + ":" + mi + " " + ap

# ------------------------------------------------------------- schedule ops

def next_game():
    """First game with no result yet, or None if the season's done."""
    for g in GAMES:
        if g["result"] == None:
            return g
    return None

def last_game():
    """Most recently played game, or None if none have happened yet."""
    played = None
    for g in GAMES:
        if g["result"] != None:
            played = g
    return played

def season_record():
    """[wins, losses] across every game with a result so far."""
    w, l = 0, 0
    for g in GAMES:
        r = g["result"]
        if r != None:
            if r["us"] > r["them"]:
                w += 1
            else:
                l += 1
    return [w, l]

# -------------------------------------------------------------------- draw

def title(c, ctx):
    c.clear()

    logo_w, logo_h = 60, 26
    logo_x, logo_y = 2, (c.height - logo_h) // 2
    c.image("logo.png", logo_x, logo_y, w = logo_w, h = logo_h)

    text_x = logo_x + logo_w + 5
    maxw = c.width - text_x - 2
    c.text_fit("DEL NORTE", text_x, 6, ["6x8", "5x7", "4x5"], color = "white", maxw = maxw)
    c.text_fit("JV FOOTBALL", text_x, 18, ["6x8", "5x7", "4x5"], color = "#C9A961", maxw = maxw)

def _matchup(g):
    away = g["opp"] if g["home"] else TEAM
    home = TEAM if g["home"] else g["opp"]
    return away, home

def next(c, ctx):
    c.clear()
    g = next_game()
    if g == None:
        y = c.header("SEASON", bg = "gray", color = "black", font = "4x5")
        c.text_center("SEASON COMPLETE", y + 3, font = "5x7", color = "white")
        w, l = season_record()
        c.text_center("FINAL " + str(w) + "-" + str(l), y + 12, font = "5x7", color = "gray")
        return

    y = c.header("NEXT GAME", bg = "green", color = "black", font = "4x5")

    relation = "VS " if g["home"] else "@ "
    c.text_fit(relation + g["opp"], 3, y, ["6x8", "5x7", "4x5"], color = "white", maxw = c.width - 6)

    c.text(date_str(g) + "  " + time_str(g), 3, y + 9, font = "5x7", color = "yellow")

    tz = ctx.inputs.get("tz_offset", -7)
    secs = kickoff_unix(g, int(tz)) - ctx.now.unix
    if secs <= 0:
        countdown = "TODAY"
    else:
        days = secs // 86400
        if days >= 1:
            countdown = str(days) + " DAY" + ("" if days == 1 else "S") + " AWAY"
        else:
            countdown = str(secs // 3600) + " HRS AWAY"
    c.text(countdown, 3, y + 18, font = "4x5", color = "green")

def last(c, ctx):
    c.clear()
    g = last_game()
    if g == None:
        c.header("LAST GAME", bg = "cyan", color = "black", font = "4x5")
        c.text_center("NO GAMES YET", 18, font = "5x7", color = "white")
        return

    # Hand-built instead of c.scoreboard: that widget wants the full 32px of
    # canvas height to lay out team names + big score digits without
    # clipping, which leaves no room for a header bar above it. Drawing the
    # two sides ourselves keeps the header AND still fits a date at the
    # bottom -- same trick as the NEXT GAME page, just without a helper.
    y = c.header("LAST GAME", bg = "cyan", color = "black", font = "4x5")

    # "us"/"them" (from GAMES) map to the away/home slots (left/right on
    # screen) depending which side Del Norte played on that week.
    away_score = g["result"]["them"] if g["home"] else g["result"]["us"]
    home_score = g["result"]["us"] if g["home"] else g["result"]["them"]
    away_name = g["opp"][:6] if g["home"] else TEAM_SHORT
    home_name = TEAM_SHORT if g["home"] else g["opp"][:6]
    away_color = "cyan" if g["home"] else "green"
    home_color = "green" if g["home"] else "cyan"

    c.text(away_name, 4, y + 1, font = "5x7", color = away_color)
    c.text(str(away_score), 4, y + 9, font = "10x16_bold", color = "white")

    c.text_right(home_name, y + 1, font = "5x7", color = home_color, margin = 4)
    c.text_right(str(home_score), y + 9, font = "10x16_bold", color = "white", margin = 4)

    c.text_center(date_str(g), 27, font = "4x5", color = "gray")

def record(c, ctx):
    c.clear()
    # A corner tab instead of a full-width header bar -- c.stat's value font
    # ("6x8" only; "10x16_bold" and "8x12" both ran the value into the
    # "GAMES LEFT" line below, and 8x12's "-" glyph renders as a solid block
    # anyway) needs the room a full header would eat into.
    c.badge("RECORD", 2, 1, color = "black", bg = "yellow", font = "4x5")
    w, l = season_record()
    c.stat(str(w) + "W " + str(l) + "L", "OVERALL", 3, 10, fonts = ["6x8"], color = "white")

    played = 0
    for g in GAMES:
        if g["result"] != None:
            played += 1
    remaining = len(GAMES) - played
    c.text(str(remaining) + " GAMES LEFT", 3, 26, font = "4x5", color = "gray")
