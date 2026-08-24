# NFL Scores — built for the Glance Developer Network.
#
# Design follows the reference: a team logo beside the abbreviation and
# record.
#
# Layout (64x32), single page:
#   game day   two team bands right, kickoff time in the left column
#   in game    same bands, left column shows quarter / clock / down / spot
#   final      same bands, left column shows FINAL
#   idle       your logo left, abbreviation, record

SCOREBOARD = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"

# The scoreboard only lists the current week, so on a bye or in the offseason
# the team simply is not in it. The team endpoint carries the record and the
# next fixture, which is what the idle screen needs.
TEAM_API = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/"

BIG = "5x7"
FONT = "4x5"
TINY = "3x4"

# Glyph coverage, measured rather than assumed:
#   3x4    A-Z and 0-9 ONLY. No colon, hyphen, ampersand, period, slash or
#          space. Missing glyphs render as nothing and text_width reports
#          them as zero-width, so "8:42" silently becomes "842".
#   4x5    full punctuation. The safe default for anything non-alphanumeric.
#   5x5b   has : - . and space, but NO & or /.
#   5x7    full punctuation.
# Anything containing punctuation must use 4x5 or 5x7.

# Logo size. MUST match the pixel size of the files in assets/ — c.image()
# resizes with nearest-neighbour, so any mismatch duplicates or drops whole
# rows rather than scaling. One constant, used everywhere.
LOGO_S = 16

# Live layout: stats column on the left, teams stacked on the right.
LEFT_W = 24
LOGO_X = 28
DIVIDER_X = 26

# A scheduled game sits in the scoreboard payload for the whole week, so
# "has a game" is not the same as "is game day". Inside this window the
# matchup card shows; outside it, the idle record card does.
PREGAME_WINDOW_HOURS = 12
DIM = "#8a8a8a"
ACCENT = "#FFCC00"
RED_ZONE = "#FF3333"

# (background, abbreviation, score + ticks). All three are explicit — edit
# any team freely, nothing is computed. Backgrounds are team primaries;
# abbreviations use the secondary where it separates cleanly and white where
# it does not.
TEAM = {
    "ARI": ("#97233F", "#FFFFFF", "#FFFFFF"),
    "ATL": ("#A71930", "#FFFFFF", "#FFFFFF"),
    "BAL": ("#241773", "#FFFFFF", "#FFFFFF"),
    "BUF": ("#00338D", "#FFFFFF", "#FFFFFF"),
    "CAR": ("#0085CA", "#FFFFFF", "#FFFFFF"),
    "CHI": ("#0B162A", "#C83803", "#FFFFFF"),
    "CIN": ("#000000", "#FB4F14", "#FFFFFF"),
    "CLE": ("#311D00", "#FF3C00", "#FFFFFF"),
    "DAL": ("#003594", "#869397", "#FFFFFF"),
    "DEN": ("#002244", "#FB4F14", "#FFFFFF"),
    "DET": ("#0076B6", "#FFFFFF", "#FFFFFF"),
    "GB":  ("#203731", "#FFB612", "#FFFFFF"),
    "HOU": ("#03202F", "#FFFFFF", "#FFFFFF"),
    "IND": ("#003087", "#FFFFFF", "#FFFFFF"),
    "JAX": ("#006778", "#D7A22A", "#FFFFFF"),
    "KC":  ("#E31837", "#FFB81C", "#FFFFFF"),
    "LV":  ("#000000", "#A5ACAF", "#FFFFFF"),
    "LAC": ("#0080C6", "#FFC20E", "#FFFFFF"),
    "LAR": ("#003594", "#FFA300", "#FFFFFF"),
    "MIA": ("#005F61", "#FC4C02", "#FFFFFF"),
    "MIN": ("#4F2683", "#FFC62F", "#FFFFFF"),
    "NE":  ("#002244", "#FFFFFF", "#FFFFFF"),
    "NO":  ("#101820", "#D3BC8D", "#FFFFFF"),
    "NYG": ("#0B2265", "#FFFFFF", "#FFFFFF"),
    "NYJ": ("#125740", "#FFFFFF", "#FFFFFF"),
    "PHI": ("#004C54", "#A5ACAF", "#FFFFFF"),
    "PIT": ("#000000", "#FFB612", "#FFFFFF"),
    "SF":  ("#AA0000", "#FFFFFF", "#FFFFFF"),
    "SEA": ("#002244", "#69BE28", "#FFFFFF"),
    "TB":  ("#34302B", "#FFFFFF", "#FFFFFF"),
    "TEN": ("#0C2340", "#4B92DB", "#FFFFFF"),
    "WSH": ("#5A1414", "#FFB612", "#FFFFFF"),
}

def colors(abbr):
    """(background, abbreviation, score) — hardcoded, not derived."""
    return TEAM.get(abbr, ("#222222", "#cccccc", "#FFFFFF"))

def logo_file(abbr):
    return abbr + ".png"

# ---------------------------------------------------------------- data

def fetch(ttl):
    resp = http.get(SCOREBOARD, ttl_seconds = ttl)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    return resp["json"]

def digits_only(s):
    out = ""
    for ch in s.elems():
        if ch >= "0" and ch <= "9":
            out += ch
    return out

def local_start(raw, offset):
    """'2026-09-14T17:00Z' -> '1:00P' at the user's offset."""
    parts = raw.split("T")
    if len(parts) != 2:
        return ""
    hm = parts[1].replace("Z", "").split(":")
    if len(hm) < 2:
        return ""
    hh = digits_only(hm[0])
    if hh == "":
        return ""
    hour = int(hh) + offset
    if hour < 0:
        hour += 24
    if hour >= 24:
        hour -= 24
    ampm = "P" if hour >= 12 else "A"
    h12 = hour % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + hm[1] + ampm

def record_of(cr):
    """'9-1-0' from the overall record entry; '' when absent."""
    for rec in cr.get("records", []):
        if rec.get("type", "") == "total" or rec.get("name", "") == "overall":
            return str(rec.get("summary", ""))
    recs = cr.get("records", [])
    if len(recs) > 0:
        return str(recs[0].get("summary", ""))
    return ""

def timeouts_left(v):
    """ESPN omits the field outside live play; -1 means "no timeouts left"."""
    if v == None:
        return -1
    n = int(v)
    if n < 0:
        return 0
    if n > 3:
        return 3
    return n

def down_short(sit):
    """'2&6', or '1&G' goal-to-go. Empty unless the down is a real 1-4.

    ESPN reports down as -1 on kickoffs, extra points and other dead-ball
    states. The old guard only rejected 0, so a -1 rendered as "-1&G".
    """
    d = sit.get("down", None)
    if d == None:
        return ""
    d = int(d)
    if d < 1 or d > 4:
        return ""

    dist = sit.get("distance", None)
    if dist == None:
        return str(d)
    if int(dist) == 0:
        return str(d) + "&G"
    return str(d) + "&" + str(int(dist))

def field_spot(sit, poss_abbr):
    """'OWN 45' / 'OPP 23' from ESPN's possessionText ('PIT 45').

    Whether it is own or opposition territory is decided by comparing the
    abbreviation in possessionText against whoever actually has the ball.
    """
    txt = str(sit.get("possessionText", "")).strip()
    if txt != "":
        parts = txt.split(" ")
        if len(parts) >= 2:
            side = parts[0].upper()
            yard = "".join([ch for ch in parts[1].elems() if ch >= "0" and ch <= "9"])
            if yard != "":
                if side == "50":
                    return "MID50"
                return ("OWN" if side == poss_abbr else "OPP") + yard

    # Second source: the long down-distance text carries the spot, as in
    # "1st & Goal at PIT 4". possessionText goes missing between plays and
    # right after a score, which is exactly when the panel looked broken.
    long_txt = str(sit.get("downDistanceText", ""))
    if " at " in long_txt:
        tail = long_txt.split(" at ")
        bits = tail[len(tail) - 1].strip().split(" ")
        if len(bits) >= 2:
            side = bits[0].upper()
            yard = "".join([ch for ch in bits[1].elems() if ch >= "0" and ch <= "9"])
            if yard != "":
                return ("OWN" if side == poss_abbr else "OPP") + yard

    # Last resort: yardLine counts up from the possessing team's own goal line.
    y = sit.get("yardLine", None)
    if y == None:
        return ""
    y = int(y)
    if y == 50:
        return "MID50"
    if y < 50:
        return "OWN" + str(y)
    return "OPP" + str(100 - y)

def quarter_name(period, state):
    if state == "halftime":
        return "HALF"
    if period == 1:
        return "1ST"
    if period == 2:
        return "2ND"
    if period == 3:
        return "3RD"
    if period == 4:
        return "4TH"
    if period > 4:
        return "OT"
    return ""

DAYS = ["THU", "FRI", "SAT", "SUN", "MON", "TUE", "WED"]

def _atoi(s):
    n = 0
    for ch in s.elems():
        if ch < "0" or ch > "9":
            return 0
        n = n * 10 + (ord(ch) - 48)
    return n

def _days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def parse_iso(s):
    """'2026-09-14T17:00Z' -> epoch seconds, 0 if unreadable."""
    if type(s) != "string" or len(s) < 10:
        return 0
    y, mo, d = _atoi(s[0:4]), _atoi(s[5:7]), _atoi(s[8:10])
    if y == 0 or mo == 0 or d == 0:
        return 0
    hh, mm = 0, 0
    if len(s) >= 16 and s[10] == "T":
        hh, mm = _atoi(s[11:13]), _atoi(s[14:16])
    return _days_from_civil(y, mo, d) * 86400 + hh * 3600 + mm * 60

def hours_until(iso, now_unix):
    """Hours until kickoff. Unreadable dates return a big number, which keeps
    the app on the idle card rather than guessing that a game is imminent."""
    t = parse_iso(iso)
    return 999999.0 if t == 0 else (t - now_unix) / 3600.0

def weekday_of(iso):
    """'2026-09-14T17:00Z' -> 'SUN'. Empty string if unreadable."""
    if type(iso) != "string" or len(iso) < 10:
        return ""
    y, mo, d = _atoi(iso[0:4]), _atoi(iso[5:7]), _atoi(iso[8:10])
    if y == 0 or mo == 0 or d == 0:
        return ""
    return DAYS[_days_from_civil(y, mo, d) % 7]

def team_info(abbr):
    """Record and next fixture for a team with no game this week."""
    data = get_json(TEAM_API + abbr, 900)
    if data == None:
        return None
    t = data.get("team", {})

    record = ""
    items = t.get("record", {}).get("items", [])
    if len(items) > 0:
        record = str(items[0].get("summary", ""))

    opp, when, away = "", "", False
    nxt = t.get("nextEvent", [])
    if len(nxt) > 0:
        ev = nxt[0]
        when = str(ev.get("date", ""))
        comps = ev.get("competitions", [])
        if len(comps) > 0:
            for cr in comps[0].get("competitors", []):
                a = cr.get("team", {}).get("abbreviation", "")
                if a != abbr and a != "":
                    opp = a
                elif a == abbr:
                    away = cr.get("homeAway", "") == "away"

    return {"abbr": abbr, "record": record, "opp": opp, "when": when, "away": away}

def get_json(url, ttl):
    resp = http.get(url, ttl_seconds = ttl)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    return resp["json"]

def find_game(data, abbr):
    for event in data.get("events", []):
        comps = event.get("competitions", [])
        if len(comps) == 0:
            continue
        comp = comps[0]

        home, away, found = None, None, False
        for cr in comp.get("competitors", []):
            if cr.get("homeAway") == "home":
                home = cr
            else:
                away = cr
            if cr.get("team", {}).get("abbreviation", "") == abbr:
                found = True
        if not found or home == None or away == None:
            continue

        status = event.get("status", {})
        stype = status.get("type", {})
        state = stype.get("state", "")
        detail = str(stype.get("shortDetail", "")).lower()

        halftime = "half" in detail
        period = int(status.get("period", 0))

        sit = comp.get("situation", {})
        poss = sit.get("possession", "")
        home_ab = home.get("team", {}).get("abbreviation", "???")
        away_ab = away.get("team", {}).get("abbreviation", "???")
        poss_abbr = away_ab if poss == away.get("team", {}).get("id", "") else home_ab

        return {
            "state": state,
            "home": home.get("team", {}).get("abbreviation", "???"),
            "away": away.get("team", {}).get("abbreviation", "???"),
            "home_score": str(home.get("score", "0")),
            "away_score": str(away.get("score", "0")),
            "home_record": record_of(home),
            "away_record": record_of(away),
            "quarter": quarter_name(period, "halftime" if halftime else state),
            "clock": str(status.get("displayClock", "")),
            "possession": poss,
            "away_to": timeouts_left(sit.get("awayTimeouts", None)),
            "home_to": timeouts_left(sit.get("homeTimeouts", None)),
            "red_zone": sit.get("isRedZone", False) == True,
            "down": down_short(sit),
            "spot": field_spot(sit, poss_abbr) if poss != "" else "",
            "home_id": home.get("team", {}).get("id", ""),
            "away_id": away.get("team", {}).get("id", ""),
            "date": event.get("date", ""),
        }
    return None

def parse_offset(s, fallback):
    """Read a UTC offset out of free text without ever raising.

    This is a free-text field, so "EST", "-4:00", "UTC-5" and "four" are all
    things people type. int() raises on every one, and a raised host error
    is not caught anywhere — the panel goes blank instead of falling back.
    Take the sign and the leading digits; if there are none, use the default.
    """
    s = s.strip()
    neg = s.startswith("-")
    digits = ""
    for ch in s.elems():
        if ch >= "0" and ch <= "9":
            digits += ch
        elif digits != "":
            break
    if digits == "":
        return fallback
    v = int(digits)
    if v > 14:
        return fallback
    return -v if neg else v

# ---------------------------------------------------------------- drawing

def fit(c, text, room, fonts):
    for f in fonts:
        if c.text_width(text, font = f) <= room:
            return f
    return fonts[len(fonts) - 1]

def timeout_bars(c, cx, y, n, color = "white"):
    """Three 3px ticks centred on cx. Only the remaining ones are drawn — a
    used timeout disappears rather than dimming. The full set is 11px wide
    (3 ticks, 1px gaps), so the slots stay put as they are used up."""
    if n < 0:
        return
    left = cx - 5
    for i in range(n):
        x = left + i * 4
        c.line(x, y, x + 2, y, color)

def poss_marker(c, x, y, color = "white"):
    """2x2 dot at the far right, level with the score."""
    c.rect(x, y, x + 1, y + 1, fill = color)

def idle_board(c, info):
    """No game this week: logo left, abbreviation and record right."""
    c.fill("black")
    c.image(logo_file(info["abbr"]), 2, 8, w = LOGO_S, h = LOGO_S)

    x = 24
    c.text(info["abbr"], x, 5, font = BIG, color = DIM)
    if info["record"] != "":
        rf = fit(c, info["record"], c.width - x - 1, [BIG, FONT])
        c.text(info["record"], x, 16, font = rf, color = "white")

def board(c, ctx):
    """Two logos with scores beneath, status down the middle."""
    c.fill("black")
    g = load_game(c, ctx)
    if g == None:
        return

    live_board(c, g)

def live_board(c, g):
    """Stats stacked down the left, teams stacked on the right.

    Dropping the space in the yard line ("OWN45") brings the widest left-hand
    line down to 24px, level with the clock. The 3px saved goes to the logos,
    which are 16px rather than 14.
    """
    # Divider between the stats column and the scores.
    c.line(DIVIDER_X, 0, DIVIDER_X, 31, "white")

    # Right: away on top, home beneath, each a logo and a score.
    rows = [
        (g["away"], g["away_score"], g["away_id"], g["away_to"], 0),
        (g["home"], g["home_score"], g["home_id"], g["home_to"], 16),
    ]
    # Each band is 16px: abbreviation, score, timeout ticks — all centred in
    # the strip between the logo and the possession lane, so the three lines
    # stack on a common axis.
    # Text block is 14px — a 3-letter abbreviation at 4x5 — with its right
    # edge 2px clear of the possession dot.
    room = 14
    right = c.width - 3
    cx = right - room // 2

    for abbr, score, tid, to, y in rows:
        bg, abbr_col, fg = colors(abbr)

        # Team colour fills this half of the band, right of the divider.
        c.rect(DIVIDER_X + 1, y, c.width - 1, y + 15, fill = bg)
        c.image(logo_file(abbr), LOGO_X, y, w = LOGO_S, h = LOGO_S)

        af = fit(c, abbr, room, [FONT, TINY])
        c.text(abbr, cx, y + 1, font = af, color = abbr_col, align = "center")

        # No score before kickoff — 0-0 is noise, not information.
        if g["state"] != "pre":
            sf = fit(c, score, room, [FONT, TINY])
            c.text(score, cx, y + 7, font = sf, color = fg, align = "center")

        timeout_bars(c, cx, y + 14, to, fg)

        if g["possession"] != "" and g["possession"] == tid:
            poss_marker(c, c.width - 2, y + 8, fg)

    # Left column is centred on the strip left of the divider.
    lcx = DIVIDER_X // 2

    if g["state"] == "pre":
        # Game day but not started: same two-band layout, with the left
        # column carrying only the kickoff time.
        #
        # "10:00P" is 29px at 4x5 and the column is 24, so it used to run
        # over the divider. Split the meridiem onto its own row instead of
        # shrinking: 3x4 has no colon, so a smaller font would silently drop
        # it and leave "1000P".
        t = local_start(g["date"], g["offset"])
        if t == "":
            c.text("TODAY", lcx, 13, font = FONT, color = ACCENT,
                   align = "center")
            return

        hm = t[:len(t) - 1]
        mer = t[len(t) - 1:] + "M"
        c.text(hm, lcx, 9, font = FONT, color = ACCENT, align = "center")
        c.text(mer, lcx, 17, font = FONT, color = ACCENT, align = "center")
        return

    if g["state"] == "post":
        c.text("FINAL", lcx, 13, font = FONT, color = "white", align = "center")
        return

    if g["quarter"] == "HALF":
        c.text("HALF", lcx, 13, font = FONT, color = ACCENT, align = "center")
        return

    # Quarter, clock, then a blank row, then down and distance and the yard
    # line. The gap separates the game clock from the drive state.
    col = RED_ZONE if g["red_zone"] else DIM
    lines = [
        (g["quarter"], ACCENT, 1),
        (g["clock"], "white", 8),
        (g["down"], col, 18),
        (g["spot"], col, 25),
    ]
    for text, color, y in lines:
        if text != "":
            f = fit(c, text, LEFT_W, [FONT, TINY])
            c.text(text, lcx, y, font = f, color = color, align = "center")

def message(c, lines, color = "white"):
    y = 10
    for line in lines:
        c.text(line, c.width // 2, y, font = FONT, color = color, align = "center")
        y += 7

def load_game(c, ctx):
    abbr = ctx.inputs.get("team", "PHI").strip().upper()
    offset = parse_offset(ctx.inputs.get("utcoffset", "-4"), -4)

    data = fetch(60)
    if data == None:
        c.fill("black")
        message(c, ["NO DATA"], "red")
        return None

    g = find_game(data, abbr)

    # Scheduled, but not for a while: show the idle card instead of a matchup
    # card with a kickoff time three days out.
    if g != None and g["state"] == "pre":
        if hours_until(g["date"], ctx.now.unix) > PREGAME_WINDOW_HOURS:
            away_side = abbr == g["away"]
            info = {
                "abbr": abbr,
                "record": g["away_record"] if away_side else g["home_record"],
                "opp": g["home"] if away_side else g["away"],
                "when": g["date"],
                "away": away_side,
            }
            idle_board(c, info)
            return None

    if g == None:
        info = team_info(abbr)
        if info == None:
            c.fill("black")
            message(c, [abbr, "NO GAME"], "gray")
        else:
            idle_board(c, info)
        return None

    g["offset"] = offset
    g["pick"] = abbr
    return g