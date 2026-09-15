# DESIGN. A TV-style Test match scorebug for the nations you follow. Every
# screen opens with both sides' pixel flags, so a glance tells you who is
# playing before you read a digit.
#
# When one of your teams has a Test today, page 1 (score) is the scorebug: the
# batting side's score is the one hero, overs sit beside it, and the state of
# the game (lead, trail, chase, result) runs underneath. Page 2 (innings) is
# the card: one row per side with every innings. Several Tests today rotate
# one per refresh, with pips in the corner.
#
# On every other day the app looks your team up in ESPN's season list: page 1
# counts down to its next scheduled Test, page 2 shows how its last Test
# ended. With several teams picked, both pages rotate team by team. A team
# with no Test fixed yet falls back to its next ODI or T20I (or the one it is
# playing right now); with nothing at all fixed, it says so instead of going
# blank.
#
# Data: ESPN's public cricket scorepanel (no key). No params = every match
# today; team=<id>&dates=<year> = one team's whole season, 3-330 KB.
# site.api.espn.com serves the same path but 403s browser-like user agents,
# so this uses site.web.api.espn.com.

FEED = "https://site.web.api.espn.com/apis/site/v2/sports/cricket/scorepanel"

# refresh in manifest.yaml is 60: today's feed is cached for the same 60 s,
# and each refresh advances the rotation by one match (or one team).
LIVE_TTL = 60
# A season list only changes when a fixture is added or a Test finishes, and
# a Test finishing today already shows up through today's feed.
SEASON_TTL = 3600
ROTATE_SECONDS = 60
# Worst case per render: today + this season + next season + last season,
# 4 of the 8 uncached calls allowed.

LEFT = 6        # scroll safe-zone padding, both edges
RIGHT_PAD = 6

FLAG_W = 13
FLAG_H = 9

FONTH = {"10x16": 16, "9x12": 12, "8x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# ESPN's internationalClassId for men's internationals.
FORMAT = {"1": "TEST", "2": "ODI", "3": "T20I"}
WHITE_BALL = ["ODI", "T20I"]

# Short header chips for when a long one would crowd the right-hand flag
# ("ENG v PAK [flag]" ends at x 80; "LAST TEST" would start at x 87).
SHORT_CHIP = {
    "LAST TEST": "LAST",
    "NEXT TEST": "NEXT",
    "NEXT ODI": "NEXT",
    "NEXT T20I": "NEXT",
    "UPCOMING": "NEXT",
    "RESULT": "FINAL",
}

NODATA_BG = "#0B0C12"
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"

# The 12 men's Test nations: ESPN displayName (also the manifest's `teams`
# choices), abbreviation, and ESPN team id for the season lookup.
TEAMS = [
    ["Afghanistan", "AFG", "40"],
    ["Australia", "AUS", "2"],
    ["Bangladesh", "BAN", "25"],
    ["England", "ENG", "1"],
    ["India", "IND", "6"],
    ["Ireland", "IRE", "29"],
    ["New Zealand", "NZ", "5"],
    ["Pakistan", "PAK", "7"],
    ["South Africa", "SA", "3"],
    ["Sri Lanka", "SL", "8"],
    ["West Indies", "WI", "4"],
    ["Zimbabwe", "ZIM", "9"],
]
TEAM_ABBR = {t[0].lower(): t[1] for t in TEAMS}
TEAM_ID = {t[0].lower(): t[2] for t in TEAMS}
TEAM_NAME = {t[0].lower(): t[0].upper() for t in TEAMS}

# One legend for every flag. Colors are pushed a little brighter than the
# printed flags so dark greens and blues still read on an LED.
LEGEND = {
    "W": "#FFFFFF",
    "R": "#E8112D",
    "B": "#1646C8",
    "U": "#1E5AD2",
    "G": "#1E9E3A",
    "P": "#0B7A34",
    "E": "#169B62",
    "D": "#0A8A55",
    "Y": "#FFC81E",
    "K": "#303030",
    "O": "#FF9933",
    "N": "#1C3FAA",
    "M": "#A0183F",
    "T": "#0A8A6A",
    "F": "#FF7F00",
}

# 13x9 flags. West Indies has no national flag, so it wears the WI cricket
# palm and island on maroon. Ireland plays as all-Ireland, so its flag is the
# shamrock rather than a national tricolour.
FLAGS = {
    "ENG": [
        "WWWWWRRRWWWWW",
        "WWWWWRRRWWWWW",
        "WWWWWRRRWWWWW",
        "RRRRRRRRRRRRR",
        "RRRRRRRRRRRRR",
        "RRRRRRRRRRRRR",
        "WWWWWRRRWWWWW",
        "WWWWWRRRWWWWW",
        "WWWWWRRRWWWWW",
    ],
    "AUS": [
        "WBWRWBWBBBBBB",
        "BWWRWWBBBBWBB",
        "RRRRRRRBBBBBB",
        "BWWRWWBBWBBBB",
        "WBWRWBWBBBBWB",
        "BBBBBBBBBWBBB",
        "BBBWBBBBBBBBB",
        "BBWWWBBBBBWBB",
        "BBBWBBBBBBBBB",
    ],
    "NZ": [
        "WBWRWBWBBBBBB",
        "BWWRWWBBBBRBB",
        "RRRRRRRBBBBBB",
        "BWWRWWBBBBBRB",
        "WBWRWBWBRBBBB",
        "BBBBBBBBBBBBB",
        "BBBBBBBBBBBBB",
        "BBBBBBBBBBRBB",
        "BBBBBBBBBBBBB",
    ],
    "IND": [
        "OOOOOOOOOOOOO",
        "OOOOOOOOOOOOO",
        "OOOOOOOOOOOOO",
        "WWWWWWNWWWWWW",
        "WWWWWNWNWWWWW",
        "WWWWWWNWWWWWW",
        "GGGGGGGGGGGGG",
        "GGGGGGGGGGGGG",
        "GGGGGGGGGGGGG",
    ],
    "PAK": [
        "WWWPPPPPPPPPP",
        "WWWPPPPWWPPPP",
        "WWWPPPWWPPWPP",
        "WWWPPWWPPWWWP",
        "WWWPPWWPPPWPP",
        "WWWPPWWPPPPPP",
        "WWWPPPWWPPPPP",
        "WWWPPPPWWWPPP",
        "WWWPPPPPPPPPP",
    ],
    "SA": [
        "GGWRRRRRRRRRR",
        "YGGWRRRRRRRRR",
        "KYGGWWWWWWWWW",
        "KKYGGGGGGGGGG",
        "KKKYGGGGGGGGG",
        "KKYGGGGGGGGGG",
        "KYGGWWWWWWWWW",
        "YGGWUUUUUUUUU",
        "GGWUUUUUUUUUU",
    ],
    "SL": [
        "YYYYYYYYYYYYY",
        "YTFYMMMMMMMMY",
        "YTFYMMMMMMMMY",
        "YTFYMMYYYMMMY",
        "YTFYMYYYYYMMY",
        "YTFYMMYYYYYMY",
        "YTFYMMYMMYMMY",
        "YTFYMMMMMMMMY",
        "YYYYYYYYYYYYY",
    ],
    "WI": [
        "MMMMMMMMMMMMM",
        "MMMMYYMYYMMMM",
        "MMMYMMYMMYMMM",
        "MMMMMMYMMMMMM",
        "MMMMMMYMMMMMM",
        "MMMMMMYMMMMMM",
        "MMMMMYMMMMMMM",
        "MMMGGGGGGGMMM",
        "MMMMMMMMMMMMM",
    ],
    "BAN": [
        "DDDDDDDDDDDDD",
        "DDDDRRRDDDDDD",
        "DDDRRRRRDDDDD",
        "DDRRRRRRRDDDD",
        "DDRRRRRRRDDDD",
        "DDRRRRRRRDDDD",
        "DDDRRRRRDDDDD",
        "DDDDRRRDDDDDD",
        "DDDDDDDDDDDDD",
    ],
    "AFG": [
        "KKKKRRRRRGGGG",
        "KKKKRRRRRGGGG",
        "KKKKRRRRRGGGG",
        "KKKKRRWRRGGGG",
        "KKKKRWRWRGGGG",
        "KKKKRRWRRGGGG",
        "KKKKRRRRRGGGG",
        "KKKKRRRRRGGGG",
        "KKKKRRRRRGGGG",
    ],
    "ZIM": [
        "WGGGGGGGGGGGG",
        "WWYYYYYYYYYYY",
        "WWWRRRRRRRRRR",
        "WWWWKKKKKKKKK",
        "WRYWWKKKKKKKK",
        "WWWWKKKKKKKKK",
        "WWWRRRRRRRRRR",
        "WWYYYYYYYYYYY",
        "WGGGGGGGGGGGG",
    ],
    "IRE": [
        "EEEEEEEEEEEEE",
        "EEEEEWWWEEEEE",
        "EEEEEWWWEEEEE",
        "EEEWWWWWWWEEE",
        "EEEWWWEWWWEEE",
        "EEEEEEWEEEEEE",
        "EEEEEEWEEEEEE",
        "EEEEEEEWEEEEE",
        "EEEEEEEEEEEEE",
    ],
}


# ---------------------------------------------------------------- pages

def score(c, ctx):
    st = load_state(ctx)
    if st["kind"] == "error":
        draw_nodata(c, "SCORES OFFLINE", "RETRY NEXT REFRESH")
        return
    c.fill("black")
    idx = st["idx"]
    n = st["n"]

    if st["kind"] == "today":
        draw_match_score(c, ctx, st["matches"][idx], idx, n)
    elif st["live"] != None:
        draw_match_score(c, ctx, st["live"], idx, n)
    elif st["next"] != None:
        draw_header(c, st["next"], "NEXT " + st["next"]["fmt"], "amber", False)
        draw_next_hero(c, ctx, st["next"], idx, n)
    elif st["last"] != None:
        draw_header(c, st["last"], "LAST TEST", "gray", False)
        draw_result_hero(c, st["last"], idx, n)
    else:
        draw_unscheduled(c, st["team"], idx, n)


def innings(c, ctx):
    st = load_state(ctx)
    if st["kind"] == "error":
        draw_nodata(c, "SCORES OFFLINE", "RETRY NEXT REFRESH")
        return
    c.fill("black")
    idx = st["idx"]
    n = st["n"]

    if st["kind"] == "today":
        draw_match_card(c, st["matches"][idx], idx, n)
    elif st["live"] != None:
        draw_match_card(c, st["live"], idx, n)
    elif st["last"] != None:
        draw_card(c, st["last"], -1)
        # Page 1 already showed what's next when anything is fixed; when
        # nothing is, say so here rather than leave the viewer guessing.
        if st["next"] != None:
            foot = result_line(st["last"])
        else:
            foot = ["NEXT MATCH NOT SCHEDULED", "NOTHING SCHEDULED"]
        draw_footer(c, foot, "gray", idx, n, 26)
    elif st["next"] != None:
        draw_card(c, st["next"], -1)
        draw_footer(c, venue_lines(st["next"]), "gray", idx, n, 26)
    else:
        draw_unscheduled(c, st["team"], idx, n)


# The scorebug for one match in whatever state it is in.
def draw_match_score(c, ctx, m, idx, n):
    if m["state"] == "in":
        chip = m["fmt"]
        if m["fmt"] == "TEST":
            d = match_day(ctx, m)
            chip = ("DAY " + str(d)) if d > 0 else "LIVE"
        draw_header(c, m, chip, "green", True)
        draw_live_hero(c, ctx, m, idx, n)
    elif m["state"] == "pre":
        draw_header(c, m, "UPCOMING", "amber", False)
        draw_pre_hero(c, m, idx, n)
    else:
        draw_header(c, m, "RESULT", "gray", False)
        draw_result_hero(c, m, idx, n)


# The innings card for one match, with the side batting now marked.
def draw_match_card(c, m, idx, n):
    bi = batting(m)[0] if m["state"] == "in" else -1
    draw_card(c, m, bi)
    t = start_time(m) if m["state"] == "pre" else ""
    # "3RD TEST AT SOUTHAMPTON 11:00" clips at 4x5; the time matters more.
    foot = (m["desc"] + " STARTS " + t) if t != "" else venue_lines(m)
    draw_footer(c, foot, "gray", idx, n, 26)


# ---------------------------------------------------------------- data

def load_state(ctx):
    picks = teams_picked(ctx)
    dbg = str(ctx.inputs.get("_debugstate", "")).strip().lower()
    if dbg != "":
        return mock_state(ctx, dbg, picks)

    body = fetch({}, LIVE_TTL)
    if body == None:
        return {"kind": "error"}

    today = order_matches(matches_for(body, picks, ["TEST"]))
    if len(today) > 0:
        return today_state(ctx, today)

    # No Test today: one team per refresh, looked up in its season list.
    n = len(picks)
    idx = (ctx.now.unix // ROTATE_SECONDS) % n
    key = picks[idx]
    now = ctx.now.unix
    this_year = team_season(key, ctx.now.year)
    if this_year == None:
        return {"kind": "error"}
    nxt, last, live = split_season(only(this_year, ["TEST"]), now)
    if live != None:
        return today_state(ctx, [live])
    next_year = []
    if nxt == None:
        # Fixtures for early next year are often out by the autumn.
        next_year = team_season(key, ctx.now.year + 1) or []
        nxt = split_season(only(next_year, ["TEST"]), now)[0]
    if last == None:
        last = split_season(only(team_season(key, ctx.now.year - 1) or [], ["TEST"]), now)[1]

    st = {"kind": "team", "team": key, "next": nxt, "last": last, "live": None, "idx": idx, "n": n}
    if nxt == None:
        # No Test fixed: fall back to the team's ODIs and T20Is. One being
        # played now comes from today's 60 s feed, not the hour-old season.
        playing = order_matches(matches_for(body, [key], WHITE_BALL))
        if len(playing) > 0 and playing[0]["state"] == "in":
            st["live"] = playing[0]
        else:
            st["next"] = split_season(only(this_year + next_year, WHITE_BALL), now)[0]
    return st


def today_state(ctx, ms):
    return {
        "kind": "today",
        "matches": ms,
        "idx": (ctx.now.unix // ROTATE_SECONDS) % len(ms),
        "n": len(ms),
    }


def fetch(params, ttl):
    resp = http.get(FEED, params = params, ttl_seconds = ttl)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    if type(resp["json"]) != "dict":
        return None
    return resp["json"]


# One team's internationals (Test, ODI, T20I) for a calendar year, oldest
# first; None if ESPN is down.
def team_season(key, year):
    body = fetch({"team": TEAM_ID[key], "dates": str(year)}, SEASON_TTL)
    if body == None:
        return None
    return sorted(matches_for(body, [key], ["TEST", "ODI", "T20I"]), key = lambda m: m["start"])


def only(ms, fmts):
    return [m for m in ms if m["fmt"] in fmts]


# (next scheduled, last finished, live now) from a date-sorted season.
def split_season(ms, now):
    nxt = None
    last = None
    live = None
    for m in ms:
        if m["state"] == "in":
            live = live or m
        elif m["state"] == "pre":
            # A fixture ESPN never moved off "pre" after its date is stale.
            if nxt == None and m["start"] + 86400 >= now:
                nxt = m
        elif m["state"] == "post" and "CANCEL" not in m["summary"]:
            last = m
    return nxt, last, live


# The `teams` selection arrives as "England, Australia"; unknown names drop out.
def teams_picked(ctx):
    raw = ctx.inputs.get("teams", "England")
    parts = raw if type(raw) == "list" else str(raw).split(",")
    out = []
    for p in parts:
        key = str(p).strip().lower()
        if key in TEAM_ABBR and key not in out:
            out.append(key)
    if len(out) == 0:
        out.append("england")
    return out


def matches_for(body, picks, fmts):
    out = []
    seen = {}
    for block in as_list(body.get("scores")):
        for e in as_list(as_dict(block).get("events")):
            m = normalize(e)
            if m == None or m["fmt"] not in fmts or m["id"] in seen:
                continue
            a = m["teams"][0]["name"].lower()
            b = m["teams"][1]["name"].lower()
            if a in picks or b in picks:
                seen[m["id"]] = True
                out.append(m)
    return out


def normalize(e):
    e = as_dict(e)
    comps = as_list(e.get("competitions"))
    if len(comps) == 0:
        return None
    comp = as_dict(comps[0])
    klass = as_dict(comp.get("class"))
    stype = as_dict(as_dict(comp.get("status")).get("type"))
    addr = as_dict(as_dict(comp.get("venue")).get("address"))

    teams = []
    for cp in as_list(comp.get("competitors")):
        cp = as_dict(cp)
        t = as_dict(cp.get("team"))
        inns = []
        for ls in as_list(cp.get("linescores")):
            ls = as_dict(ls)
            if ls.get("isBatting") != True:
                continue
            inns.append({
                "r": to_int(ls.get("runs")),
                "w": to_int(ls.get("wickets")),
                "ov": ls.get("overs"),
                "desc": str(ls.get("description") or "").lower(),
                "cur": ls.get("isCurrent") in [1, True, "1"],
            })
        teams.append({
            "abbr": str(t.get("abbreviation") or "").upper()[:4],
            "name": str(t.get("displayName") or ""),
            "winner": str(cp.get("winner")).lower() == "true",
            "score": str(cp.get("score") or ""),
            "inns": inns,
        })
    if len(teams) != 2:
        return None

    return {
        "id": str(e.get("id") or ""),
        "fmt": FORMAT.get(str(klass.get("internationalClassId") or ""), ""),
        "state": str(stype.get("state") or ""),
        "desc": unescape(str(comp.get("description") or "TEST")).upper(),
        "city": unescape(str(addr.get("city") or "")).upper(),
        "start": iso_unix(str(comp.get("date") or e.get("date") or "")),
        "summary": unescape(str(as_dict(comp.get("status")).get("summary") or "")).upper(),
        "teams": teams,
    }


def order_matches(ms):
    out = []
    for st in ["in", "pre", "post"]:
        for m in ms:
            if m["state"] == st:
                out.append(m)
    for m in ms:
        if m["state"] not in ["in", "pre", "post"]:
            out.append(m)
    return out


# (team index, innings) for the side batting right now, or (-1, None).
def batting(m):
    for i in range(2):
        for inn in m["teams"][i]["inns"]:
            if inn["cur"]:
                return i, inn
    return -1, None


def total(t):
    n = 0
    for inn in t["inns"]:
        n += inn["r"]
    return n


# 453 all out -> "453", 587 for 8 declared -> "587/8D", 130 for 2 -> "130/2".
def inn_text(inn):
    if inn["desc"] == "declared":
        return str(inn["r"]) + "/" + str(inn["w"]) + "D"
    if inn["desc"] == "all out" or inn["w"] >= 10:
        return str(inn["r"])
    return str(inn["r"]) + "/" + str(inn["w"])


def innings_line(t):
    if len(t["inns"]) == 0:
        return "YET TO BAT"
    return " & ".join([inn_text(i) for i in t["inns"]])


def overs_text(ov):
    if type(ov) == "float":
        s = str(ov)
        return s[:-2] if s.endswith(".0") else s
    if type(ov) == "int":
        return str(ov)
    return ""


# ESPN puts the chase in the batting side's score: "130/2 (24.2 ov, target 130)".
def target_of(score):
    s = score.lower()
    k = s.find("target ")
    if k < 0:
        return 0
    digits = ""
    for ch in s[k + 7:].elems():
        if not ch.isdigit():
            break
        digits += ch
    return int(digits) if digits != "" else 0


def situation(m, bi, inn):
    bat = m["teams"][bi]
    other = m["teams"][1 - bi]
    target = target_of(bat["score"])
    if target > 0:
        return bat["abbr"] + " NEED " + str(max(0, target - inn["r"])) + " TO WIN"
    if len(other["inns"]) == 0:
        return bat["abbr"] + " FIRST INNINGS"
    diff = total(bat) - total(other)
    if diff > 0:
        return bat["abbr"] + " LEAD BY " + str(diff)
    if diff < 0:
        return bat["abbr"] + " TRAIL BY " + str(-diff)
    return "SCORES LEVEL"


# ("ENG WON", "BY 8 WKTS"), ("DRAWN", ""), ...
def result_parts(m):
    s = m["summary"]
    for t in m["teams"]:
        if t["winner"]:
            k = s.find(" WON BY ")
            margin = ""
            if k >= 0:
                margin = "BY " + s[k + 8:].replace("AN INNS", "INNS").replace("AN INNINGS", "INNS").replace("WICKETS", "WKTS")
            return t["abbr"] + " WON", margin
    if "DRAW" in s:
        return "DRAWN", ""
    if "TIED" in s:
        return "TIED", ""
    if "ABANDON" in s:
        return "ABANDONED", ""
    if "NO RESULT" in s:
        return "NO RESULT", ""
    return "RESULT", s


# One footer line for a finished Test: "ENG WON BY 8 WKTS", "3RD TEST DRAWN".
def result_line(m):
    head, margin = result_parts(m)
    if head == "RESULT":
        return margin if margin != "" else venue_line(m)
    if margin != "":
        return head + " " + margin
    return m["desc"] + " " + head


def venue_line(m):
    return m["desc"] + (" AT " + m["city"] if m["city"] != "" else "")


# With rotation pips beside it, "1ST TEST AT JOHANNESBURG" (105 px) loses the
# end of the city; "AT JOHANNESBURG" keeps it whole.
def venue_lines(m):
    if m["city"] == "":
        return [m["desc"]]
    return [venue_line(m), "AT " + m["city"]]


# "STARTS AT 10:30 LOCAL TIME" -> "10:30"
def start_time(m):
    s = m["summary"]
    k = s.find("STARTS AT ")
    if k < 0:
        return ""
    t = s[k + 10:].split(" ")[0]
    return t if ":" in t else ""


# Day of the Test, counted in 24 h steps from the scheduled first ball, so a
# Perth morning start (the previous day in UTC) still reads DAY 1.
def match_day(ctx, m):
    if m["start"] <= 0 or ctx.now.unix < m["start"]:
        return 0
    d = (ctx.now.unix - m["start"]) // 86400 + 1
    return d if d <= 6 else 0


# The calendar day a Test starts where it's played. ESPN gives first ball in
# UTC; no Test starts at 18:00 UTC or later on its own local date (the West
# Indies' 10am is 14:00 UTC), so a late-UTC start is the next morning in New
# Zealand or Australia: Melbourne's Boxing Day Test is "2026-12-25T23:30Z".
def local_day(start):
    day = start // 86400
    return day + 1 if start % 86400 >= 18 * 3600 else day


# ---------------------------------------------------------------- drawing

def draw_flag(c, abbr, x, y):
    art = FLAGS.get(abbr)
    if art == None:
        c.rect(x, y, x + FLAG_W - 1, y + FLAG_H - 1, outline = "midgray")
        return
    c.sprite(art, x, y, legend = LEGEND)


# [flag] ENG v PAK [flag] ................ state chip
def draw_header(c, m, chip, col, live):
    a = m["teams"][0]
    b = m["teams"][1]
    x = LEFT
    draw_flag(c, a["abbr"], x, 0)
    x += FLAG_W + 3
    c.text(a["abbr"], x, 1, font = "5x7", color = "white")
    x += c.text_width(a["abbr"], font = "5x7") + 3
    c.text("V", x, 2, font = "4x5", color = "gray")
    x += c.text_width("V", font = "4x5") + 3
    c.text(b["abbr"], x, 1, font = "5x7", color = "white")
    x += c.text_width(b["abbr"], font = "5x7") + 3
    draw_flag(c, b["abbr"], x, 0)
    left_end = x + FLAG_W

    dot = 5 if live else 0
    w = c.text_width(chip, font = "4x5")
    if c.width - RIGHT_PAD - w - dot < left_end + 5:
        chip = SHORT_CHIP.get(chip, chip)
        w = c.text_width(chip, font = "4x5")
    cx = c.width - RIGHT_PAD - w
    c.text(chip, cx, 2, font = "4x5", color = col)
    if live:
        c.rect(cx - 5, 3, cx - 3, 5, fill = "green")


# Two rows, one per side (flags y 1-9 and 12-20), every innings right-aligned.
def draw_card(c, m, bi):
    for i in range(2):
        t = m["teams"][i]
        y = 1 + i * 11
        draw_flag(c, t["abbr"], LEFT, y)
        ax = LEFT + FLAG_W + 3
        c.text(t["abbr"], ax, y + 1, font = "5x7", color = "white")
        x_min = ax + c.text_width(t["abbr"], font = "5x7") + 6
        if bi == i:
            # 2x2 green bullet: this side is batting now.
            c.rect(x_min - 4, y + 3, x_min - 3, y + 4, fill = "green")

        right = c.width - RIGHT_PAD
        text, font = fit_clip(c, innings_line(t), ["5x7", "4x5"], right - x_min)
        w = c.text_width(text, font = font)
        ty = y + 1 if font == "5x7" else y + 2
        col = "white" if len(t["inns"]) > 0 else "gray"
        c.text(text, right - w, ty, font = font, color = col)

    c.hline(LEFT, 23, c.width - LEFT - RIGHT_PAD, "darkgray")


# ENG [453/9] 112.4
#              OVERS
def draw_live_hero(c, ctx, m, idx, n):
    bi, inn = batting(m)
    if bi < 0:
        # Toss done, first ball not bowled yet.
        d = match_day(ctx, m)
        draw_center_hero(c, ("DAY " + str(d)) if d > 0 else "LIVE", "white")
        draw_footer(c, m["summary"], "white", idx, n, 27)
        return

    label = m["teams"][bi]["abbr"]
    runs = inn_text(inn)
    ov = overs_text(inn["ov"])
    lw = c.text_width(label, font = "6x8")
    ow = max(c.text_width(ov, font = "5x7"), c.text_width("OVERS", font = "4x5")) if ov != "" else 0
    room = c.width - LEFT - RIGHT_PAD

    font = "8x12"
    for f in ["10x16", "9x12", "8x12"]:
        if lw + 4 + c.text_width(runs, font = f) + (5 + ow if ow > 0 else 0) <= room:
            font = f
            break
    sw = c.text_width(runs, font = font)
    group = lw + 4 + sw + (5 + ow if ow > 0 else 0)
    x = max(LEFT, (c.width - group) // 2)

    c.text(label, x, 14, font = "6x8", color = "gray")
    x += lw + 4
    c.text(runs, x, 10 + (16 - FONTH[font]) // 2, font = font, color = "white")
    x += sw + 5
    if ow > 0:
        c.text(ov, x, 11, font = "5x7", color = "white")
        c.text("OVERS", x, 20, font = "4x5", color = "gray")

    draw_footer(c, situation(m, bi, inn), "white", idx, n, 27)


# 10:30  START
#        LOCAL
def draw_pre_hero(c, m, idx, n):
    t = start_time(m)
    if t == "":
        draw_center_hero(c, "TODAY", "white")
        draw_footer(c, venue_lines(m), "gray", idx, n, 27)
        return
    tw = c.text_width(t, font = "10x16")
    lw = c.text_width("START", font = "4x5")
    x = (c.width - (tw + 5 + lw)) // 2
    c.text(t, x, 10, font = "10x16", color = "white")
    c.text("START", x + tw + 5, 12, font = "4x5", color = "gray")
    c.text("LOCAL", x + tw + 5, 19, font = "4x5", color = "gray")
    draw_footer(c, venue_lines(m), "gray", idx, n, 27)


# 17 DEC  IN 93
#         DAYS
def draw_next_hero(c, ctx, m, idx, n):
    day = local_day(m["start"])
    ymd = civil_from_days(day)
    date = str(ymd[2]) + " " + MONTHS[ymd[1] - 1]
    days = day - ctx.now.unix // 86400
    if days <= 0:
        top, bottom = "", "TODAY"
    elif days == 1:
        top, bottom = "IN 1", "DAY"
    else:
        top, bottom = "IN " + str(days), "DAYS"

    dw = c.text_width(date, font = "10x16")
    cw = max(c.text_width(top, font = "4x5") if top != "" else 0, c.text_width(bottom, font = "4x5"))
    x = (c.width - (dw + 5 + cw)) // 2
    c.text(date, x, 10, font = "10x16", color = "white")
    if top != "":
        c.text(top, x + dw + 5, 12, font = "4x5", color = "white")
    c.text(bottom, x + dw + 5, 19, font = "4x5", color = "gray")
    draw_footer(c, venue_lines(m), "gray", idx, n, 27)


def draw_result_hero(c, m, idx, n):
    head, margin = result_parts(m)
    draw_center_hero(c, head, "white")
    draw_footer(c, margin if margin != "" else venue_lines(m), "gray", idx, n, 27)


def draw_center_hero(c, s, color):
    text, font = fit_clip(c, s, ["10x16", "9x12", "6x8"], c.width - LEFT - RIGHT_PAD)
    y = 10 + (16 - FONTH[font]) // 2
    c.text(text, c.width // 2, y, font = font, color = color, align = "center")


# A team with no Test last year or this year and nothing of any format fixed
# ahead: its flag at 2x, its name, and a plain statement - never a blank panel.
def draw_unscheduled(c, key, idx, n):
    abbr = TEAM_ABBR[key]
    fy = (c.height - FLAG_H * 2) // 2
    art = FLAGS.get(abbr)
    if art != None:
        c.sprite(art, LEFT, fy, legend = LEGEND, scale = 2)
    x = LEFT + FLAG_W * 2 + 6
    maxw = c.width - RIGHT_PAD - x
    name, nf = fit_clip(c, TEAM_NAME[key], ["6x8", "5x7"], maxw)
    c.text(name, x, 8, font = nf, color = "white")
    line, lf = fit_clip(c, "NO FIXTURES YET", ["4x5"], maxw)
    c.text(line, x, 19, font = lf, color = "gray")
    draw_rotation(c, idx, n, 27)


# One 4x5 line, centered on the canvas unless the rotation pips need the room.
# `s` may be a list of wordings, longest first: the first that fits is drawn,
# and only the last one is ever clipped.
def draw_footer(c, s, color, idx, n, y):
    pw = draw_rotation(c, idx, n, y)
    right = c.width - RIGHT_PAD
    if pw > 0:
        right = right - pw - 4
    options = s if type(s) == "list" else [s]
    pick = options[len(options) - 1]
    for o in options:
        if c.text_width(o.upper(), font = "4x5") <= right - LEFT:
            pick = o
            break
    text, font = fit_clip(c, pick, ["4x5"], right - LEFT)
    w = c.text_width(text, font = font)
    x = (c.width - w) // 2
    if x + w > right:
        x = right - w
    c.text(text, max(LEFT, x), y, font = font, color = color)


# Pips for up to 6 matches or teams (current one white), "2/9" beyond that.
def draw_rotation(c, idx, n, y):
    if n <= 1:
        return 0
    if n > 6:
        s = str(idx + 1) + "/" + str(n)
        w = c.text_width(s, font = "4x5")
        c.text(s, c.width - RIGHT_PAD - w, y, font = "4x5", color = "gray")
        return w
    w = n * 3 - 1
    x0 = c.width - RIGHT_PAD - w
    for i in range(n):
        col = "white" if i == idx else "midgray"
        c.rect(x0 + i * 3, y + 2, x0 + i * 3 + 1, y + 3, fill = col)
    return w


def draw_nodata(c, title, sub):
    c.fill(NODATA_BG)
    text, font = fit_clip(c, title, ["10x16", "6x8", "5x7", "4x5"], c.width - LEFT - RIGHT_PAD)
    c.text(text, c.width // 2, 8, font = font, color = NODATA_TITLE, align = "center")
    c.text(sub, c.width // 2, 21, font = "4x5", color = NODATA_SUB, align = "center")


# ---------------------------------------------------------------- helpers

# Largest font that fits maxw, else the smallest font hard-clipped with "..".
def fit_clip(c, s, fonts, maxw):
    s = s.upper()
    for f in fonts:
        if c.text_width(s, font = f) <= maxw:
            return s, f
    f = fonts[len(fonts) - 1]
    n = len(s)
    for i in range(1, n):
        t = s[:n - i].rstrip() + ".."
        if c.text_width(t, font = f) <= maxw:
            return t, f
    return "", f


def as_list(x):
    return x if type(x) == "list" else []


def as_dict(x):
    return x if type(x) == "dict" else {}


def to_int(x):
    if type(x) == "int":
        return x
    if type(x) == "float":
        return int(x)
    if type(x) == "string" and x.isdigit():
        return int(x)
    return 0


def unescape(s):
    return s.replace("&amp;", "&").replace("&#39;", "'").replace("&quot;", "\"")


# "2026-09-09T10:00Z" -> unix seconds, 0 if unparseable.
def iso_unix(s):
    if len(s) < 16:
        return 0
    digits = s[0:4] + s[5:7] + s[8:10] + s[11:13] + s[14:16]
    if not digits.isdigit():
        return 0
    days = days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10]))
    return days * 86400 + int(s[11:13]) * 3600 + int(s[14:16]) * 60


def days_from_civil(y, m, d):
    """Days since 1970-01-01 for a civil date (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil_from_days(z):
    """The inverse: days since the epoch back to [year, month, day]."""
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]


# ---------------------------------------------------------------- preview

# Hidden `_debugstate` input (not in the manifest) for previewing every screen
# whatever ESPN has on: live, chase, upcoming, result, drawn, multi (Tests
# today), next, nextodi, liveodi, last, none (days off), error.
def mock_state(ctx, dbg, picks):
    if dbg == "error":
        return {"kind": "error"}

    now = ctx.now.unix
    live = mock("in", "ENG", "PAK", [[245, 4, 61.3, "", True]],
                [[133, 10, 33.5, "all out", False]], "", now - 2 * 86400 - 10800)
    chase = mock("in", "AUS", "IND", [[387, 10, 101.2, "all out", False], [210, 6, 58.0, "declared", False]],
                 [[301, 10, 92.4, "all out", False], [212, 5, 54.2, "", True]], "",
                 now - 4 * 86400 - 7200, b_score = "301 & 212/5 (54.2 ov, target 297)")
    pre = mock("pre", "NZ", "SA", [], [], "STARTS AT 11:00 LOCAL TIME", now + 3600)
    won = mock("post", "ENG", "PAK", [[453, 10, 89.0, "all out", False], [130, 2, 24.2, "", False]],
               [[133, 10, 33.5, "all out", False], [449, 10, 96.4, "all out", False]],
               "ENGLAND WON BY 8 WKTS", now - 3 * 86400, winner = "ENG")
    drawn = mock("post", "WI", "SL", [[499, 10, 165.5, "all out", False], [109, 0, 40.0, "", False]],
                 [[549, 9, 139.3, "declared", False], [251, 9, 49.0, "declared", False]],
                 "MATCH DRAWN", now - 5 * 86400)
    nxt = mock("pre", "SA", "ENG", [], [], "", now + 93 * 86400,
               desc = "1ST TEST", city = "JOHANNESBURG")
    ire = mock("post", "IRE", "NZ", [[180, 10, 60.1, "all out", False], [164, 10, 55.0, "all out", False]],
               [[345, 10, 98.4, "all out", False]], "NEW ZEALAND WON BY AN INNS & 1 RUN",
               now - 110 * 86400, winner = "NZ", desc = "ONLY TEST", city = "BELFAST")

    odi = mock("pre", "ZIM", "AUS", [], [], "", now + 2 * 86400,
               desc = "2ND ODI", city = "HARARE", fmt = "ODI")
    t20 = mock("in", "IND", "AFG", [[182, 6, 20.0, "", False]], [[141, 4, 15.2, "", True]], "",
               now - 5400, b_score = "141/4 (15.2/20 ov, target 183)", desc = "2ND T20I",
               city = "DELHI", fmt = "T20I")

    n = len(picks)
    idx = (now // ROTATE_SECONDS) % n
    team = {"kind": "team", "team": picks[idx], "idx": idx, "n": n, "live": None}
    if dbg == "next":
        return dict(team, next = nxt, last = won)
    if dbg == "last":
        return dict(team, next = None, last = ire)
    if dbg == "nextodi":
        return dict(team, next = odi, last = ire)
    if dbg == "liveodi":
        return dict(team, next = None, last = None, live = t20)
    if dbg == "none":
        return dict(team, next = None, last = None)

    if dbg == "live":
        return today_state(ctx, [live])
    if dbg == "chase":
        return today_state(ctx, [chase])
    if dbg == "upcoming":
        return today_state(ctx, [pre])
    if dbg == "result":
        return today_state(ctx, [won])
    if dbg == "drawn":
        return today_state(ctx, [drawn])
    return today_state(ctx, [live, chase, pre])


def mock(state, a, b, a_inns, b_inns, summary, start, a_score = "", b_score = "",
         winner = "", desc = "3RD TEST", city = "SOUTHAMPTON", fmt = "TEST"):
    names = {t[1]: t[0] for t in TEAMS}

    def side(abbr, rows, score):
        return {
            "abbr": abbr,
            "name": names.get(abbr, abbr),
            "winner": abbr == winner,
            "score": score,
            "inns": [{"r": r[0], "w": r[1], "ov": r[2], "desc": r[3], "cur": r[4]} for r in rows],
        }

    return {
        "id": a + b + state,
        "fmt": fmt,
        "state": state,
        "desc": desc,
        "city": city,
        "start": start,
        "summary": summary,
        "teams": [side(a, a_inns, a_score), side(b, b_inns, b_score)],
    }
