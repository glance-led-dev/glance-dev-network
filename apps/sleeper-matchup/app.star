# Sleeper Matchup - your live Sleeper fantasy football matchup on a 64x32 panel.
#
# Layout (64 x 32):
#   y 1-7    your username (left)        | opponent's username (right)
#   y 11-22  your score (green/red/white) | opponent's score (white)
#   y 26-30  WK n        football         margin (+12.3 / -4.2 / TIED)
#
# Data: Sleeper's free, public, read-only API (no key). Per render:
#   state/nfl (week, season) -> user/<username> -> user's leagues this season
#   -> league rosters + league users -> this week's matchups.
# Everything but the matchups is cached for an hour or more, so a normal
# refresh makes one request; the matchups are cached just under the refresh
# so each refresh shows new points on game day.

API = "https://api.sleeper.app/v1/"
HEADERS = {"User-Agent": "glance-sleeper-matchup (glance-led.dev)"}

STATE_TTL = 1800
USER_TTL = 86400
LEAGUES_TTL = 21600
LEAGUE_TTL = 3600
MATCHUP_TTL = 240

COL_W = 31          # each half is 31 px: left x 0-30, right x 33-63
LEFT_X = 0
RIGHT_X = 33

INK = "#F4F7FF"
LABEL = "#8C96AA"
DIM = "#2A3140"
WIN = "#2EE86A"
LOSE = "#FF3B30"
WARN = "#FFB000"
BALL = "#B4602A"

FOOTBALL = [
    [0, 1, 1, 1, 1, 1, 0],
    [1, 1, 0, 0, 0, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 0],
]

NAME_FONTS = ["5x7", "4x5", "picopixel"]
SCORE_FONTS = ["scoretext", "scoretext_6x11", "5x7"]

# ------------------------------------------------------------------ helpers

def get(c, path, ttl):
    r = http.get(API + path, headers = HEADERS, ttl_seconds = ttl)
    return r

def fmt1(p):
    """One decimal place, rounded half away from zero."""
    t = int(p * 10 + (0.5 if p >= 0 else -0.5))
    sign = "-" if t < 0 else ""
    t = t if t >= 0 else -t
    return sign + str(t // 10) + "." + str(t % 10)

def fit_text(c, s, fonts, max_w):
    """Largest font that fits max_w; else the smallest font, clipped by characters."""
    for f in fonts:
        if c.text_width(s, f) <= max_w:
            return [s, f]
    f = fonts[len(fonts) - 1]
    out = s
    for _ in range(len(s)):
        if c.text_width(out, f) <= max_w:
            break
        out = out[:len(out) - 1]
    return [out, f]

def font_h(f):
    return {"5x7": 7, "4x5": 5, "picopixel": 5, "scoretext": 12, "scoretext_6x11": 11}.get(f, 7)

def centered(c, s, font, col_x, y, color):
    w = c.text_width(s, font)
    c.text(s, col_x + (COL_W - w) // 2, y, font = font, color = color)

def points_of(m):
    if m == None:
        return 0.0
    cp = m.get("custom_points")
    if cp != None:
        return float(cp)
    p = m.get("points")
    if p == None:
        return 0.0
    return float(p)

# ------------------------------------------------------------------ screens

def draw_message(c, title, color, line1, line2):
    """Error / empty screen: what happened (title), then what to do (two short lines)."""
    c.fill("black")
    c.bitmap(FOOTBALL, 0, 1, BALL)
    c.text("SLEEPER", 9, 1, font = "4x5", color = LABEL)
    t = fit_text(c, title, ["5x7", "4x5"], 64)
    c.text(t[0], (64 - c.text_width(t[0], t[1])) // 2, 10, font = t[1], color = color)
    for i, ln in enumerate([line1, line2]):
        s = fit_text(c, ln, ["4x5", "picopixel"], 64)
        c.text(s[0], (64 - c.text_width(s[0], s[1])) // 2, 20 + i * 6, font = s[1], color = INK)

def draw_matchup(c, me, opp, my_pts, opp_pts, footer):
    c.fill("black")

    # names
    for col in [[me, LEFT_X, INK], [opp, RIGHT_X, LABEL]]:
        s = fit_text(c, col[0].upper(), NAME_FONTS, COL_W)
        y = 1 + (7 - font_h(s[1])) // 2
        centered(c, s[0], s[1], col[1], y, col[2])

    # scores - the hero
    if my_pts > opp_pts:
        my_color = WIN
    elif my_pts < opp_pts:
        my_color = LOSE
    else:
        my_color = INK
    for col in [[fmt1(my_pts), LEFT_X, my_color], [fmt1(opp_pts), RIGHT_X, INK]]:
        s = fit_text(c, col[0], SCORE_FONTS, COL_W)
        y = 11 + (12 - font_h(s[1])) // 2
        centered(c, s[0], s[1], col[1], y, col[2])

    # divider between the two halves
    for y in range(2, 23, 2):
        c.pixel(32, y, DIM)

    # footer: week (or DEMO), football, margin
    c.text(footer, 0, 26, font = "4x5", color = WARN if footer == "DEMO" else LABEL)
    c.bitmap(FOOTBALL, 28, 26, BALL)
    diff = my_pts - opp_pts
    if fmt1(diff if diff >= 0 else -diff) == "0.0":
        m, mc = "TIED", LABEL
    elif diff > 0:
        m, mc = "+" + fmt1(diff), WIN
    else:
        m, mc = fmt1(diff), LOSE
    c.text(m, 64 - c.text_width(m, "4x5"), 26, font = "4x5", color = mc)

# ------------------------------------------------------------------ data

def fetch_matchup(ctx):
    """Returns a dict: kind = 'live' | 'msg', plus what to draw."""
    username = str(ctx.inputs.get("username", "")).strip().lstrip("@")
    league_q = str(ctx.inputs.get("league", "")).strip()

    if username == "":
        return {"kind": "live", "me": "YOU", "opp": "RIVAL", "mine": 112.4, "theirs": 98.7, "footer": "DEMO"}

    st = get(None, "state/nfl", STATE_TTL)
    if st["status_code"] != 200 or type(st["json"]) != "dict":
        return {"kind": "msg", "title": "OFFLINE", "color": WARN, "l1": "SLEEPER DOWN", "l2": "RETRY IN 5 MIN"}
    state = st["json"]
    stype = str(state.get("season_type", ""))
    season = str(state.get("season", ""))
    week = state.get("week")
    if type(week) != "int" or week < 1:
        week = state.get("display_week")
    if stype not in ["regular", "post"] or type(week) != "int" or week < 1:
        return {"kind": "msg", "title": "OFFSEASON", "color": WIN, "l1": "SCORES RETURN", "l2": "IN WEEK 1"}

    u = get(None, "user/" + username.lower(), USER_TTL)
    if u["status_code"] == 0:
        return {"kind": "msg", "title": "OFFLINE", "color": WARN, "l1": "SLEEPER DOWN", "l2": "RETRY IN 5 MIN"}
    if u["status_code"] != 200 or type(u["json"]) != "dict" or not u["json"].get("user_id"):
        return {"kind": "msg", "title": "NO SUCH USER", "color": LOSE, "l1": "CHECK YOUR", "l2": "SLEEPER USERNAME"}
    user_id = str(u["json"]["user_id"])
    me_name = str(u["json"].get("display_name") or u["json"].get("username") or username)

    lg = get(None, "user/" + user_id + "/leagues/nfl/" + season, LEAGUES_TTL)
    if lg["status_code"] != 200 or type(lg["json"]) != "list":
        return {"kind": "msg", "title": "OFFLINE", "color": WARN, "l1": "SLEEPER DOWN", "l2": "RETRY IN 5 MIN"}
    leagues = [l for l in lg["json"] if type(l) == "dict"]
    league = None
    q = league_q.upper()
    for l in leagues:
        if q == "" or str(l.get("league_id", "")) == league_q or q in str(l.get("name", "")).upper():
            league = l
            break
    if league == None:
        return {"kind": "msg", "title": "NO LEAGUE", "color": LOSE, "l1": "CHECK LEAGUE", "l2": "NAME OR ID"}
    league_id = str(league["league_id"])

    rs = get(None, "league/" + league_id + "/rosters", LEAGUE_TTL)
    us = get(None, "league/" + league_id + "/users", LEAGUE_TTL)
    mu = get(None, "league/" + league_id + "/matchups/" + str(week), MATCHUP_TTL)
    for r in [rs, us, mu]:
        if r["status_code"] != 200 or type(r["json"]) != "list":
            return {"kind": "msg", "title": "OFFLINE", "color": WARN, "l1": "SLEEPER DOWN", "l2": "RETRY IN 5 MIN"}

    # roster_id -> owner's name, and find my roster (owner or co-owner)
    names = {}
    for x in us["json"]:
        if type(x) == "dict":
            names[str(x.get("user_id", ""))] = str(x.get("display_name") or "")
    owner_of = {}
    my_roster = None
    for r in rs["json"]:
        if type(r) != "dict":
            continue
        rid = r.get("roster_id")
        oid = str(r.get("owner_id") or "")
        owner_of[rid] = names.get(oid, "") or "OPEN TEAM"
        co = r.get("co_owners") or []
        if oid == user_id or user_id in [str(c) for c in co]:
            my_roster = rid
    if my_roster == None:
        return {"kind": "msg", "title": "NO TEAM", "color": LOSE, "l1": "YOU ARE NOT IN", "l2": "THAT LEAGUE"}

    mine = None
    for m in mu["json"]:
        if type(m) == "dict" and m.get("roster_id") == my_roster:
            mine = m
    footer = "WK " + str(week)
    if mine == None or mine.get("matchup_id") == None:
        return {"kind": "msg", "title": "BYE WEEK", "color": WIN, "l1": "NO MATCHUP", "l2": "THIS " + footer}
    opp = None
    for m in mu["json"]:
        if type(m) == "dict" and m.get("matchup_id") == mine.get("matchup_id") and m.get("roster_id") != my_roster:
            opp = m
    if opp == None:
        return {"kind": "msg", "title": "BYE WEEK", "color": WIN, "l1": "NO MATCHUP", "l2": "THIS " + footer}

    return {
        "kind": "live",
        "me": me_name,
        "opp": owner_of.get(opp.get("roster_id"), "OPPONENT"),
        "mine": points_of(mine),
        "theirs": points_of(opp),
        "footer": footer,
    }

# ------------------------------------------------------------------ page

def matchup(c, ctx):
    d = fetch_matchup(ctx)
    if d["kind"] == "msg":
        draw_message(c, d["title"], d["color"], d["l1"], d["l2"])
    else:
        draw_matchup(c, d["me"], d["opp"], d["mine"], d["theirs"], d["footer"])
