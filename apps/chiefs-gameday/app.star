# Chiefs Game Day — public NFL score, countdown, and next game for a 128x32
# Glance LED panel. Data comes from ESPN's free public scoreboard and team
# schedule (no API key, no account, no personal information).
#
# Times are shown in US Central Time (the Chiefs' market, and what the
# living-room panel should display). DST is applied with the standard US
# rule, the same pattern used by the catalog's soccer-club-tracker app.

TEAM_ID = "12"
TEAM_ABBR = "KC"
TEAM_NAME = "CHIEFS"

SCHED_URL = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/12/schedule"
SCOREBOARD_URL = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"

# Host cache: scoreboard is the live path (clock, score, down and distance);
# the schedule is the season path (next game, record, bye). Refresh is 180s.
SCHED_TTL = 180
SCOREBOARD_TTL = 60

# After kickoff, keep the final on the panel this long before flipping to
# the next-game countdown. 36 hours covers a Sunday afternoon into Monday
# night, and a Thursday night into Saturday morning.
POST_WINDOW_MIN = 2160

RED = "#E31837"
GOLD = "#FFB81C"
GREY = "#8A8A8A"
DIM = "#505050"
WIN = "#00DC46"
LOSS = "#FF4A4A"

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
DOWNS = ["", "1ST", "2ND", "3RD", "4TH"]

# A small right-pointing arrowhead, used as the app's identity mark.
# 11 wide x 11 tall.
ARROWHEAD = [
    [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
]


# ---------- small helpers ----------

def get(obj, key, fallback=None):
    if type(obj) != "dict":
        return fallback
    value = obj.get(key, fallback)
    return fallback if value == None else value

def first(value):
    return value[0] if type(value) == "list" and len(value) > 0 else {}

def display(text):
    return str(text).upper() if text != None else ""

def score_text(value):
    if type(value) == "dict":
        value = get(value, "displayValue", get(value, "value", ""))
    if type(value) == "float":
        if value < 0:
            return "-"
        return str(int(value))
    text = str(value).strip() if value != None else ""
    if text == "" or text == "None":
        return "-"
    # Scoreboard sometimes sends the score as a plain string.
    out = ""
    for i in range(len(text)):
        ch = text[i]
        if ch >= "0" and ch <= "9":
            out = out + ch
    return out if out != "" else "-"

def is_num(s):
    if type(s) == "int" or type(s) == "float":
        return True
    text = str(s)
    if len(text) == 0:
        return False
    for i in range(len(text)):
        if text[i] < "0" or text[i] > "9":
            return False
    return True

def as_int(value, fallback=0):
    if type(value) == "int":
        return value
    if type(value) == "float":
        return int(value)
    text = str(value).strip() if value != None else ""
    if is_num(text):
        return int(text)
    return fallback

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return f
    return fonts[len(fonts) - 1]


# ---------- Central Time (US DST) ----------
# Copied in spirit from the catalog soccer-club-tracker: days_from_civil /
# nth_sunday / 2nd-Sunday-in-March to 1st-Sunday-in-November. Standard
# offset is UTC-6; DST is UTC-5.

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    return era * 146097 + yoe * 365 + yoe // 4 - yoe // 100 + doy - 719468

def civil_from_days(z):
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return [y, m, d]

def weekday(days):
    return (days + 4) % 7  # 0 = Sunday

def nth_sunday(y, m, n):
    d1 = days_from_civil(y, m, 1)
    return d1 + (7 - weekday(d1)) % 7 + 7 * (n - 1)

def utc_minutes(iso):
    # ESPN dates look like 2026-12-04T01:15Z (sometimes with seconds).
    if type(iso) != "string" or len(iso) < 16:
        return None
    digits = iso[0:4] + iso[5:7] + iso[8:10] + iso[11:13] + iso[14:16]
    if not is_num(digits):
        return None
    days = days_from_civil(int(iso[0:4]), int(iso[5:7]), int(iso[8:10]))
    return days * 1440 + int(iso[11:13]) * 60 + int(iso[14:16])

def central_offset(utc):
    # std = -6 hours. DST starts 2nd Sunday of March at 2:00 AM local
    # standard time, ends 1st Sunday of November at 2:00 AM local DST.
    std = -6 * 60
    year = civil_from_days(utc // 1440)[0]
    start = nth_sunday(year, 3, 2) * 1440 + 120 - std
    end = nth_sunday(year, 11, 1) * 1440 + 120 - (std + 60)
    dst = utc >= start and utc < end
    return std + (60 if dst else 0)

def local_parts(utc):
    local = utc + central_offset(utc)
    days = local // 1440
    ymd = civil_from_days(days)
    mins = local % 1440
    return {
        "days": days,
        "year": ymd[0],
        "month": ymd[1],
        "day": ymd[2],
        "wd": weekday(days),
        "hour": mins // 60,
        "minute": mins % 60,
    }

def clock_text(p):
    h = p["hour"] % 12
    h = 12 if h == 0 else h
    m = p["minute"]
    ampm = "PM" if p["hour"] >= 12 else "AM"
    return str(h) + ":" + ("0" if m < 10 else "") + str(m) + " " + ampm + " CT"

def date_text(p):
    return MONTHS[p["month"] - 1] + " " + str(p["day"])

def day_text(p):
    return DAYS[p["wd"]]


# ---------- ESPN parsing ----------

def side_from(competitor):
    team = get(competitor, "team", {})
    return {
        "id": str(get(team, "id", "")),
        "abbr": display(get(team, "abbreviation", "???")),
        "score": score_text(get(competitor, "score", "")),
        "winner": get(competitor, "winner", False) == True,
        "home": get(competitor, "homeAway", "") == "home",
    }

def normalize(event):
    if type(event) != "dict" or event == {}:
        return None
    comp = first(get(event, "competitions", []))
    if comp == {}:
        return None
    sides = [side_from(x) for x in get(comp, "competitors", [])]
    if len(sides) != 2:
        return None
    us = None
    them = None
    for s in sides:
        if s["id"] == TEAM_ID:
            us = s
        else:
            them = s
    if us == None or them == None:
        return None
    status = get(comp, "status", get(event, "status", {}))
    stype = get(status, "type", {})
    week = get(event, "week", {})
    week_n = as_int(get(week, "number", week), 0)
    time_valid = get(comp, "timeValid", get(event, "timeValid", True))
    iso = get(comp, "date", get(event, "date", ""))
    return {
        "id": str(get(event, "id", get(comp, "id", ""))),
        "state": get(stype, "state", ""),
        "status_name": display(get(stype, "name", "")),
        "short": display(get(stype, "shortDetail", "")),
        "detail": display(get(stype, "detail", "")),
        "clock": display(get(status, "displayClock", "")),
        "period": as_int(get(status, "period", 0), 0),
        "completed": get(stype, "completed", False) == True,
        "time_valid": time_valid != False,
        "utc_min": utc_minutes(iso) if type(iso) == "string" else None,
        "week": week_n,
        "us": us,
        "them": them,
        "situation": get(comp, "situation", None),
    }

def involving_us(event):
    comp = first(get(event, "competitions", []))
    for c in get(comp, "competitors", []):
        if str(get(get(c, "team", {}), "id", "")) == TEAM_ID:
            return True
    return False

def fetch_json(url, ttl):
    resp = http.get(url, ttl_seconds=ttl)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    return resp["json"]

def load_auto():
    sched = fetch_json(SCHED_URL, SCHED_TTL)
    board = fetch_json(SCOREBOARD_URL, SCOREBOARD_TTL)
    games = []
    seen = {}
    # Prefer the scoreboard copy of a game (live clock, situation, fresher score).
    if board != None:
        for ev in get(board, "events", []):
            if involving_us(ev):
                g = normalize(ev)
                if g != None:
                    games.append(g)
                    seen[g["id"]] = True
    if sched != None:
        for ev in get(sched, "events", []):
            g = normalize(ev)
            if g != None and seen.get(g["id"], False) != True:
                games.append(g)
                seen[g["id"]] = True
    record = ""
    standing = ""
    bye_week = 0
    current_week = 0
    if sched != None:
        team = get(sched, "team", {})
        record = display(get(team, "recordSummary", ""))
        standing = display(get(team, "standingSummary", ""))
        bye_week = as_int(get(sched, "byeWeek", 0), 0)
    if board != None:
        current_week = as_int(get(get(board, "week", {}), "number", 0), 0)
        if record == "":
            # Scoreboard competitors sometimes carry a total record.
            pass
    if current_week == 0 and sched != None:
        current_week = as_int(get(get(sched, "week", {}), "number", 0), 0)
    offline = sched == None and board == None
    return {
        "games": games,
        "record": record,
        "standing": standing,
        "bye_week": bye_week,
        "current_week": current_week,
        "offline": offline,
    }


# ---------- fixtures (layout previews only) ----------

def fixture_sides(us_score, them_score, them_abbr, us_home, us_winner, them_winner):
    us = {
        "id": TEAM_ID,
        "abbr": TEAM_ABBR,
        "score": us_score,
        "winner": us_winner,
        "home": us_home,
    }
    them = {
        "id": "0",
        "abbr": them_abbr,
        "score": them_score,
        "winner": them_winner,
        "home": us_home != True,
    }
    return us, them

def fixture_pregame():
    us, them = fixture_sides("-", "-", "LAR", False, False, False)
    return {
        "id": "pre",
        "state": "pre",
        "status_name": "STATUS_SCHEDULED",
        "short": "12/3 - 8:15 PM EST",
        "detail": "THU, DECEMBER 3RD AT 8:15 PM EST",
        "clock": "0:00",
        "period": 0,
        "completed": False,
        "time_valid": True,
        "utc_min": utc_minutes("2026-12-04T01:15Z"),
        "week": 13,
        "us": us,
        "them": them,
        "situation": None,
    }

def fixture_live():
    us, them = fixture_sides("21", "14", "BUF", False, False, False)
    return {
        "id": "live",
        "state": "in",
        "status_name": "STATUS_IN_PROGRESS",
        "short": "8:42 - 3RD",
        "detail": "8:42 - 3RD QUARTER",
        "clock": "8:42",
        "period": 3,
        "completed": False,
        "time_valid": True,
        "utc_min": utc_minutes("2026-11-27T01:20Z"),
        "week": 12,
        "us": us,
        "them": them,
        "situation": {
            "down": 1,
            "distance": 10,
            "shortDownDistanceText": "1st & 10",
            "downDistanceText": "1st & 10 at BUF 18",
            "possessionText": "BUF 18",
            "isRedZone": True,
            "possession": TEAM_ID,
            "lastPlay": {
                "scoreValue": 6,
                "team": {"id": TEAM_ID},
                "type": {"text": "Passing Touchdown", "abbreviation": "TD"},
                "text": "P.Mahomes pass to R.Rice for 18 yards, TOUCHDOWN.",
            },
        },
    }

def fixture_final():
    us, them = fixture_sides("10", "13", "BUF", False, False, True)
    return {
        "id": "final",
        "state": "post",
        "status_name": "STATUS_FINAL",
        "short": "FINAL",
        "detail": "FINAL",
        "clock": "0:00",
        "period": 4,
        "completed": True,
        "time_valid": True,
        "utc_min": utc_minutes("2026-11-27T01:20Z"),
        "week": 12,
        "us": us,
        "them": them,
        "situation": None,
    }

def fixture_pack(scene):
    # Shared record/standing used by the preview scenes.
    base = {
        "games": [],
        "record": "8-3",
        "standing": "2ND IN AFC WEST",
        "bye_week": 5,
        "current_week": 12,
        "offline": False,
        "force": scene,
    }
    if scene == "PREGAME":
        base["games"] = [fixture_final(), fixture_pregame()]
        base["force_game"] = fixture_pregame()
        base["force_next"] = None
    elif scene == "LIVE":
        base["games"] = [fixture_live(), fixture_pregame()]
        base["force_game"] = fixture_live()
        base["force_next"] = None
    elif scene == "FINAL":
        base["games"] = [fixture_final(), fixture_pregame()]
        base["force_game"] = fixture_final()
        base["force_next"] = fixture_pregame()
    elif scene == "BYE":
        nxt_us, nxt_them = fixture_sides("-", "-", "DEN", True, False, False)
        nxt = fixture_pregame()
        nxt["them"] = nxt_them
        nxt["us"] = nxt_us
        nxt["utc_min"] = utc_minutes("2026-10-18T20:25Z")
        nxt["week"] = 6
        base["current_week"] = 5
        base["bye_week"] = 5
        base["record"] = "4-0"
        base["standing"] = "1ST IN AFC WEST"
        base["games"] = [nxt]
        base["force_game"] = None
        base["force_next"] = nxt
        base["force"] = "BYE"
    elif scene == "OFFSEASON":
        base["record"] = "8-3"
        base["standing"] = "2ND IN AFC WEST"
        base["games"] = [fixture_final()]
        base["current_week"] = 0
        base["force_game"] = None
        base["force_next"] = None
        base["force"] = "OFFSEASON"
    elif scene == "ERROR":
        base["offline"] = True
        base["force"] = "ERROR"
    return base


# ---------- view selection ----------

def soonest_pre(games, now_min):
    best = None
    tbd = None
    for g in games:
        if g["state"] != "pre":
            continue
        if g["utc_min"] == None or g["time_valid"] != True:
            if tbd == None:
                tbd = g
            continue
        if best == None or g["utc_min"] < best["utc_min"]:
            best = g
    return best if best != None else tbd

def latest_post(games):
    best = None
    for g in games:
        if g["state"] != "post":
            continue
        if best == None:
            best = g
        elif g["utc_min"] != None and (best["utc_min"] == None or g["utc_min"] > best["utc_min"]):
            best = g
    return best

def live_game(games):
    for g in games:
        if g["state"] == "in":
            return g
        name = g["status_name"]
        if "DELAYED" in name or "SUSPEND" in name or "HALFTIME" in name or "END_PERIOD" in name:
            return g
    return None

def pick_view(data, now_min):
    if data.get("force", "") == "ERROR" or data["offline"] == True:
        return {"mode": "ERROR", "game": None, "next": None}
    if data.get("force", "") != "" and data.get("force", "") != "AUTO":
        return {
            "mode": data["force"],
            "game": data.get("force_game", None),
            "next": data.get("force_next", None),
        }
    games = data["games"]
    live = live_game(games)
    if live != None:
        return {"mode": "LIVE", "game": live, "next": soonest_pre(games, now_min)}
    post = latest_post(games)
    nxt = soonest_pre(games, now_min)
    if post != None:
        age = None
        if post["utc_min"] != None:
            age = now_min - post["utc_min"]
        if age == None or (age >= 0 and age <= POST_WINDOW_MIN):
            return {"mode": "FINAL", "game": post, "next": nxt}
    if data["bye_week"] > 0 and data["current_week"] == data["bye_week"]:
        return {"mode": "BYE", "game": None, "next": nxt}
    if nxt != None:
        return {"mode": "PREGAME", "game": nxt, "next": None}
    if post != None:
        return {"mode": "OFFSEASON", "game": post, "next": None}
    return {"mode": "OFFSEASON", "game": None, "next": None}


# ---------- drawing ----------

def stripe(c):
    c.rect(0, 0, 1, c.height - 1, fill=RED)
    c.rect(2, 0, 2, c.height - 1, fill=GOLD)

def arrowhead(c, x, y, color=RED):
    c.bitmap(ARROWHEAD, x, y, color=color)

def message(c, top, bottom, top_color="white"):
    c.fill("black")
    stripe(c)
    arrowhead(c, 6, 10, RED)
    # Leave the arrowhead its own column; center the words in the rest.
    cx = 22 + (c.width - 22) // 2
    c.text(top, cx, 8, font=fit(c, top, ["6x8", "5x7", "4x5"], 100), color=top_color, align="center")
    c.text(bottom, cx, 20, font=fit(c, bottom, ["4x5", "picopixel"], 100), color=GREY, align="center")

def vs_line(game):
    opp = game["them"]["abbr"]
    # "AT" not "@" — several panel fonts draw @ poorly at this size.
    if game["us"]["home"] == True:
        return "VS " + opp
    return "AT " + opp

def period_label(game):
    blob = game["status_name"] + " " + game["short"] + " " + game["detail"]
    if "HALFTIME" in blob:
        return "HT"
    if "DELAYED" in blob:
        return "DELAYED"
    if "SUSPEND" in blob:
        return "SUSPENDED"
    if "END_PERIOD" in blob or "END OF" in blob:
        p = game["period"]
        if p >= 1 and p <= 4:
            return "END Q" + str(p)
        return "END"
    p = game["period"]
    if p >= 5:
        return "OT" if p == 5 else "OT" + str(p - 4)
    if p >= 1 and p <= 4:
        return "Q" + str(p)
    if game["short"] != "":
        return game["short"]
    return "LIVE"

def live_clock_line(game):
    label = period_label(game)
    clock = game["clock"]
    if label in ["HT", "DELAYED", "SUSPENDED", "END"]:
        return label
    if clock != "" and clock != "0:00":
        return label + " " + clock
    return label

def down_line(game):
    sit = game["situation"]
    if type(sit) != "dict":
        return ""
    text = display(get(sit, "shortDownDistanceText", ""))
    if text != "":
        return text
    down = as_int(get(sit, "down", 0), 0)
    dist = as_int(get(sit, "distance", 0), 0)
    if down >= 1 and down <= 4:
        label = DOWNS[down] + " & " + str(dist)
        return label
    return ""

def possession_abbr(game):
    sit = game["situation"]
    if type(sit) != "dict":
        return ""
    pid = str(get(sit, "possession", ""))
    if pid == "" or pid == "None":
        return ""
    if pid == game["us"]["id"]:
        return game["us"]["abbr"]
    if pid == game["them"]["id"]:
        return game["them"]["abbr"]
    return ""

def scoring_tag(game):
    # Still-frame highlight while ESPN's last play is a Chiefs score.
    sit = game["situation"]
    if type(sit) != "dict":
        return ""
    play = get(sit, "lastPlay", {})
    if type(play) != "dict":
        return ""
    team = get(play, "team", {})
    tid = str(get(team, "id", ""))
    if tid != TEAM_ID:
        return ""
    pts = as_int(get(play, "scoreValue", 0), 0)
    if pts >= 6:
        return "TD"
    if pts == 3:
        return "FG"
    if pts == 2:
        return "2PT"
    if pts == 1:
        return "XP"
    return ""

def kick_parts(game):
    if game == None or game["utc_min"] == None or game["time_valid"] != True:
        return None
    return local_parts(game["utc_min"])

def countdown_text(game, now_min):
    if game == None or game["utc_min"] == None or game["time_valid"] != True:
        return "TIME TBD"
    left = game["utc_min"] - now_min
    if left <= 0:
        return "SOON"
    days = left // 1440
    hours = (left % 1440) // 60
    mins = left % 60
    if days >= 1:
        return str(days) + "D " + str(hours) + "H"
    if hours >= 1:
        return str(hours) + "H " + str(mins) + "M"
    return str(mins) + " MIN"

def next_footer(game, now_min):
    if game == None:
        return ""
    vs = vs_line(game)
    p = kick_parts(game)
    if p == None:
        return "NEXT " + vs
    return "NEXT " + vs + "  " + day_text(p) + " " + clock_text(p)

def draw_scores(c, game, result_tag, result_color, right_lines, flash_tag):
    # Chiefs on top, opponent under, status stacked on the right.
    # Column split: mark | abbrs | scores | status. Scores right-align
    # at SCORE_R so two-digit totals never collide with the abbreviations.
    stripe(c)
    arrowhead(c, 5, 10, RED)

    us = game["us"]["abbr"]
    them = game["them"]["abbr"]
    us_sc = game["us"]["score"]
    them_sc = game["them"]["score"]
    if us_sc == "-":
        us_sc = "0"
    if them_sc == "-":
        them_sc = "0"

    ax = 19
    score_r = 64
    us_col = GOLD if flash_tag != "" else "white"
    c.text(us, ax, 4, font="6x8", color=GOLD)
    c.text(us_sc, score_r, 1, font="10x16", color=us_col, align="right")
    c.text(them, ax, 20, font="5x7", color=GREY)
    c.text(them_sc, score_r, 17, font="7x12", color="white", align="right")

    rx = 68
    rw = c.width - rx - 2
    y = 2
    if flash_tag != "":
        tag = flash_tag
        tw = c.text_width(tag, "5x7")
        pad = 3
        c.round_rect(rx, y, rx + tw + pad * 2, y + 8, 1, fill=RED)
        c.text(tag, rx + pad, y + 1, font="5x7", color="white")
        # Clock shares the TD row when it fits to the right of the badge.
        if len(right_lines) > 0:
            clock = right_lines[0]
            cx = rx + tw + pad * 2 + 3
            left = c.width - 2 - cx
            if c.text_width(clock, "4x5") <= left:
                c.text(clock, cx, y + 2, font="4x5", color="white")
                right_lines = right_lines[1:]
        y = 12
    if result_tag != "":
        f = fit(c, result_tag, ["7x12", "6x8", "5x7"], rw)
        c.text(result_tag, rx, y, font=f, color=result_color)
        y = y + 12
    for i, line in enumerate(right_lines):
        if line == "" or y > 26:
            continue
        f = fit(c, line, ["5x7", "4x5", "picopixel"], rw)
        if "BALL" in line or line == "RED ZONE":
            col = GOLD
        elif "RZ" in line:
            col = GOLD
        elif i == 0 and flash_tag == "" and result_tag == "":
            col = "white"
        elif result_tag != "" and i == 0:
            col = "white"
        else:
            col = GREY
        # Paint RZ in red after the possession text when present.
        if line.endswith(" RZ"):
            base = line[:len(line) - 3]
            c.text(base, rx, y, font=f, color=GOLD)
            bw = c.text_width(base + " ", f)
            c.text("RZ", rx + bw, y, font=f, color=RED)
        else:
            c.text(line, rx, y, font=f, color=col)
        h = 8 if f == "5x7" else 6
        y = y + h

def draw_pregame(c, game, data, now_min):
    stripe(c)
    arrowhead(c, 5, 3, RED)
    c.text(TEAM_NAME, 20, 3, font="5x7", color=GOLD)

    vs = vs_line(game)
    rec = data["record"]
    head = vs if rec == "" else vs + "  " + rec
    c.text(head, 20, 12, font=fit(c, head, ["5x7", "4x5"], 104), color="white")

    p = kick_parts(game)
    count = countdown_text(game, now_min)
    if p == None:
        when = "KICKOFF TBD"
    else:
        when = day_text(p) + " " + date_text(p) + "  " + clock_text(p)
    c.text(when, 20, 22, font=fit(c, when, ["4x5", "picopixel"], 72), color=GREY)
    c.text(count, c.width - 3, 20, font=fit(c, count, ["6x8", "5x7", "4x5"], 44), color=GOLD, align="right")

def draw_live(c, game):
    flash = scoring_tag(game)
    lines = [live_clock_line(game)]
    down = down_line(game)
    if down != "":
        lines.append(down)
    poss = possession_abbr(game)
    sit = game["situation"]
    rz = type(sit) == "dict" and get(sit, "isRedZone", False) == True
    if poss != "":
        ball = poss + " BALL"
        if rz:
            ball = ball + " RZ"
        lines.append(ball)
    elif rz:
        lines.append("RED ZONE")
    draw_scores(c, game, "", "white", lines, flash)

def draw_final(c, game, nxt, now_min):
    won = game["us"]["winner"]
    lost = game["them"]["winner"]
    if won:
        tag = "W"
        col = WIN
    elif lost:
        tag = "L"
        col = LOSS
    else:
        tag = "T"
        col = "amber"
    lines = ["FINAL"]
    foot = next_footer(nxt, now_min)
    # Footer is long; put it as the last right-side line only if it fits,
    # otherwise under the scores across the bottom.
    draw_scores(c, game, tag, col, lines, "")
    if foot != "":
        # Overwrite the bottom with a full-width next-game line if needed.
        # The W/L + FINAL sit on the right; the next game goes along the
        # bottom in 4x5, but that collides with the opponent score. Keep
        # NEXT on the right under FINAL when short enough, else skip time.
        short = "NEXT " + vs_line(nxt) if nxt != None else ""
        p = kick_parts(nxt) if nxt != None else None
        if p != None:
            with_day = short + " " + day_text(p)
            if c.text_width(with_day, "4x5") <= 70:
                short = with_day
        c.text(short, 68, 24, font=fit(c, short, ["4x5", "picopixel"], 58), color=GOLD)

def draw_bye(c, data, nxt, now_min):
    stripe(c)
    arrowhead(c, 5, 3, RED)
    c.text(TEAM_NAME, 20, 3, font="5x7", color=GOLD)
    rec = data["record"]
    title = "BYE WEEK"
    c.text(title, 20, 12, font="6x8", color="white")
    if rec != "":
        c.text(rec, c.width - 3, 3, font="5x7", color="white", align="right")
    foot = next_footer(nxt, now_min)
    if foot == "":
        foot = data["standing"] if data["standing"] != "" else "NO GAME THIS WEEK"
    c.text(foot, 20, 23, font=fit(c, foot, ["4x5", "picopixel"], 104), color=GREY)

def draw_offseason(c, data, last):
    stripe(c)
    arrowhead(c, 5, 3, RED)
    c.text(TEAM_NAME, 20, 3, font="5x7", color=GOLD)
    rec = data["record"]
    if rec == "" and last != None:
        rec = last["us"]["score"] + "-" + last["them"]["score"]
    if rec != "":
        c.text(rec, 20, 12, font=fit(c, rec, ["10x16", "7x12", "6x8"], 70), color="white")
    else:
        c.text("NFL", 20, 12, font="7x12", color="white")
    c.text("OFFSEASON", c.width - 3, 3, font="4x5", color=GREY, align="right")
    stand = data["standing"] if data["standing"] != "" else ""
    if stand != "":
        c.text(stand, 20, 24, font=fit(c, stand, ["4x5", "picopixel"], 104), color=GREY)


# ---------- page ----------

def gameday(c, ctx):
    c.fill("black")
    scene = display(ctx.inputs.get("scene", "AUTO")).strip()
    if scene == "":
        scene = "AUTO"
    now_min = ctx.now.unix // 60

    if scene == "AUTO":
        data = load_auto()
    else:
        data = fixture_pack(scene)

    view = pick_view(data, now_min)
    mode = view["mode"]
    game = view["game"]
    nxt = view["next"]

    if mode == "ERROR":
        message(c, "NO GAME DATA", "RETRYING SOON", "amber")
        return
    if mode == "LIVE" and game != None:
        draw_live(c, game)
        return
    if mode == "FINAL" and game != None:
        draw_final(c, game, nxt, now_min)
        return
    if mode == "PREGAME" and game != None:
        draw_pregame(c, game, data, now_min)
        return
    if mode == "BYE":
        draw_bye(c, data, nxt, now_min)
        return
    if mode == "OFFSEASON":
        draw_offseason(c, data, game)
        return
    message(c, TEAM_NAME, "NO GAME SCHEDULED", "white")
