# My Teams Board — only Joel's five teams, one page each.
#
# Steelers, Cardinals, Suns, Dodgers, Arizona State. Each page answers one
# question: are they playing right now, did they just play, or when is the
# next one? Live score beats a fresh final (18h), a fresh final beats a game
# today or tomorrow, and after that the page looks ahead. A team with no
# next game (the Dodgers in late October) keeps its last final up with a
# SEASON DONE tag instead of going blank.
#
# DATA. ESPN's public team-schedule endpoint — the same one the catalog's
# athlete-tracker apps use, no key:
#   site.api.espn.com/apis/site/v2/sports/<path>/teams/<id>/schedule
# One fetch per page per render, cached 300s so a live score can move
# between the panel's 900s refreshes. Kickoff times are converted from
# ESPN's UTC stamps to US Eastern by hand (fixed DST rules — the same
# approach as the athlete trackers; there is no tz database here).

GOLD = "#E8B33A"
WHITE = "#FFFFFF"
GRAY = "#8A8AA8"
DIM = "#6A7090"
RED = "#FF5347"
BG = "#08090D"

TEAMS = {
    "steelers": {"path": "football/nfl", "key": "steelersid", "id": "23",
                 "name": "STEELERS"},
    "cardinals": {"path": "football/nfl", "key": "cardinalsid", "id": "22",
                  "name": "CARDINALS"},
    "suns": {"path": "basketball/nba", "key": "sunsid", "id": "21",
             "name": "SUNS"},
    "dodgers": {"path": "baseball/mlb", "key": "dodgersid", "id": "19",
                "name": "DODGERS"},
    "asu": {"path": "football/college-football", "key": "asuid", "id": "9",
            "name": "ARIZONA ST", "short": "ASU"},
}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
WEEKDAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]


# ---- date and time plumbing ----------------------------------------------

def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil_from_days(z):
    """[y, m, d] for a day count since the epoch (Hinnant, inverted)."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + (1 if m <= 2 else 0), m, d]


def dst_start_unix(y):
    """Second Sunday of March, 07:00 UTC (US daylight time begins)."""
    d1 = days_from_civil(y, 3, 1)
    first_sun = 1 + (7 - (d1 + 4) % 7) % 7
    return days_from_civil(y, 3, first_sun + 7) * 86400 + 7 * 3600


def dst_end_unix(y):
    """First Sunday of November, 06:00 UTC (US daylight time ends)."""
    d1 = days_from_civil(y, 11, 1)
    first_sun = 1 + (7 - (d1 + 4) % 7) % 7
    return days_from_civil(y, 11, first_sun) * 86400 + 6 * 3600


def et_offset(unix):
    y = civil_from_days(unix // 86400)[0]
    if dst_start_unix(y) <= unix and unix < dst_end_unix(y):
        return -4
    return -5


def et_day(unix):
    """The Eastern-Time calendar day containing unix, as a day count."""
    return (unix + et_offset(unix) * 3600) // 86400


def parse_iso(s):
    """'2026-10-18T17:00Z' (UTC, seconds optional) -> unix, or None."""
    if s == None or len(s) < 16:
        return None
    ss = 0
    if len(s) >= 19 and s[16] == ":":
        ss = int(s[17:19])
    return (days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10])) * 86400
            + int(s[11:13]) * 3600 + int(s[14:16]) * 60 + ss)


def date_label(unix):
    """'SUN OCT 18' for the Eastern day containing unix."""
    day = et_day(unix)
    cd = civil_from_days(day)
    return "%s %s %d" % (WEEKDAYS[(day + 4) % 7], MONTHS[cd[1] - 1], cd[2])


def time_label(unix):
    """'1 PM' / '1:05 PM' in Eastern time."""
    secs = (unix + et_offset(unix) * 3600) % 86400
    hh = secs // 3600
    mm = (secs % 3600) // 60
    ap = "AM" if hh < 12 else "PM"
    h12 = hh % 12
    if h12 == 0:
        h12 = 12
    if mm == 0:
        return "%d %s" % (h12, ap)
    ms = str(mm) if mm >= 10 else "0" + str(mm)
    return "%d:%s %s" % (h12, ms, ap)


# ---- the feed --------------------------------------------------------------

def score_of(t):
    sc = t.get("score")
    if type(sc) == "dict":
        return sc.get("displayValue")
    if sc == None:
        return None
    return str(sc)


def shape(e, my_id):
    """One schedule event -> the bits the page draws, or None if unusable."""
    comp = (e.get("competitions") or [{}])[0]
    st = (comp.get("status") or {}).get("type") or {}
    mine = None
    opp = None
    for t in comp.get("competitors") or []:
        team = t.get("team") or {}
        ent = {"abbr": str(team.get("abbreviation") or "?").upper(),
               "home": t.get("homeAway") == "home",
               "score": score_of(t)}
        if str(team.get("id")) == str(my_id):
            mine = ent
        else:
            opp = ent
    if mine == None or opp == None:
        return None
    return {"unix": parse_iso(e.get("date")),
            "state": st.get("state"),
            "detail": str(st.get("detail") or "").upper(),
            "timeValid": e.get("timeValid", True),
            "mine": mine, "opp": opp}


def pick(events, my_id, now):
    """[kind, event, has_next] — kind is LIVE, FINAL, NEXT, DONE or NONE.

    Mirrors the athlete trackers' game_to_show priorities, simplified:
    live first; a final less than 18h old; a game today or tomorrow; a
    final less than 3 days old; the next game; the last final standing."""
    last = None
    nxt = None
    live = None
    for e in events:
        ev = shape(e, my_id)
        if ev == None or ev["unix"] == None:
            continue
        if ev["state"] == "in":
            live = ev
        elif ev["state"] == "post":
            if last == None or ev["unix"] > last["unix"]:
                last = ev
        elif ev["state"] == "pre":
            if nxt == None or ev["unix"] < nxt["unix"]:
                nxt = ev
    if live != None:
        return ["LIVE", live, nxt != None]
    if last != None and now - last["unix"] < 18 * 3600:
        return ["FINAL", last, nxt != None]
    if nxt != None and et_day(nxt["unix"]) - et_day(now) <= 1:
        return ["NEXT", nxt, True]
    if last != None and now - last["unix"] < 3 * 86400:
        return ["FINAL", last, nxt != None]
    if nxt != None:
        return ["NEXT", nxt, True]
    if last != None:
        return ["DONE", last, False]
    return ["NONE", None, False]


# ---- drawing -----------------------------------------------------------------

def clip(c, text, font, maxw):
    """Longest prefix of text that fits maxw — the header safety net."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def header(c, t, tag, tag_color):
    name = t["short"] if "short" in t else t["name"]
    if tag != "":
        room = c.width - c.text_width(tag, "4x5") - 3
        name = clip(c, name, "4x5", room)
    c.text(name, 0, 0, font = "4x5", color = GOLD)
    if tag != "":
        c.text(tag, c.width - 1, 0, font = "4x5", color = tag_color,
               align = "right")


def score_line(c, ent, y, color):
    s = ent["abbr"]
    if ent["score"] != None:
        s = s + " " + ent["score"]
    c.text(s, 0, y, font = "6x8", color = color)


def draw_scores(c, t, ev, tag, tag_color, footer):
    header(c, t, tag, tag_color)
    mine = ev["mine"]
    opp = ev["opp"]
    my_color = WHITE
    if tag == "FINAL" or tag == "DONE":
        if mine["score"] != None and opp["score"] != None:
            if int(mine["score"]) > int(opp["score"]):
                my_color = GOLD
            elif int(mine["score"]) < int(opp["score"]):
                my_color = GRAY
    score_line(c, mine, 8, my_color)
    score_line(c, opp, 18, WHITE)
    if footer != "":
        c.text_fit(footer, c.width // 2, 27, ["4x5", "3x4"], color = DIM,
                   align = "center", maxw = c.width - 2)


def draw_next(c, t, ev, now):
    header(c, t, "NEXT", GOLD)
    mine = ev["mine"]
    opp = ev["opp"]
    hero = ("VS " if mine["home"] else "AT ") + opp["abbr"]
    c.text_fit(hero, c.width // 2, 8, ["10x16", "7x12", "6x8"],
               color = WHITE, align = "center", maxw = c.width - 2)
    diff = et_day(ev["unix"]) - et_day(now)
    if not ev["timeValid"]:
        sub = date_label(ev["unix"])
    elif diff <= 0:
        sub = "TODAY " + time_label(ev["unix"])
    elif diff == 1:
        sub = "TMRW " + time_label(ev["unix"])
    else:
        day = et_day(ev["unix"])
        sub = "%s %s" % (WEEKDAYS[(day + 4) % 7], time_label(ev["unix"]))
    c.text_fit(sub, c.width // 2, 25, ["5x7", "4x5"], color = GOLD,
               align = "center", maxw = c.width - 2)


def board(c, ctx, page):
    t = TEAMS[page]
    tid = str(ctx.inputs.get(t["key"], t["id"])).strip()
    if tid == "":
        tid = t["id"]
    c.fill(BG)
    url = ("https://site.api.espn.com/apis/site/v2/sports/%s/teams/%s/schedule"
           % (t["path"], tid))
    r = http.get(url, ttl_seconds = 300)
    if r["status_code"] != 200 or not r["json"]:
        header(c, t, "", GRAY)
        c.text_fit("FEED DOWN", c.width // 2, 11, ["6x8", "5x7"],
                   color = GOLD, align = "center", maxw = c.width - 2)
        c.text_fit("WILL RETRY", c.width // 2, 23, ["4x5"],
                   color = DIM, align = "center", maxw = c.width - 2)
        return
    got = pick(r["json"].get("events") or [], tid, ctx.now.unix)
    kind = got[0]
    ev = got[1]
    if kind == "NONE" or ev == None:
        header(c, t, "", GRAY)
        c.text_fit("NO GAMES", c.width // 2, 11, ["6x8", "5x7"],
                   color = GOLD, align = "center", maxw = c.width - 2)
        c.text_fit("NONE POSTED", c.width // 2, 23, ["4x5"],
                   color = DIM, align = "center", maxw = c.width - 2)
        return
    if kind == "LIVE":
        foot = ev["detail"] if ev["detail"] != "" else "IN PROGRESS"
        draw_scores(c, t, ev, "LIVE", RED, foot)
    elif kind == "NEXT":
        draw_next(c, t, ev, ctx.now.unix)
    elif kind == "DONE":
        draw_scores(c, t, ev, "DONE", GRAY, "SEASON DONE")
    else:
        draw_scores(c, t, ev, "FINAL", GRAY,
                    date_label(ev["unix"]) if got[2] else "SEASON DONE")


def steelers(c, ctx):
    board(c, ctx, "steelers")


def cardinals(c, ctx):
    board(c, ctx, "cardinals")


def suns(c, ctx):
    board(c, ctx, "suns")


def dodgers(c, ctx):
    board(c, ctx, "dodgers")


def asu(c, ctx):
    board(c, ctx, "asu")
