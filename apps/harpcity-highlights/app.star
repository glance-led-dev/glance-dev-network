# DESIGN: Orange team banner, black background, paired matchup rows,
# and separate margin/record views. 8px outer margins separate neighboring apps.
# Read-only Sleeper data; no account credentials or fixed league identifiers.
BASE = "https://api.sleeper.app/v1/"
ORANGE = "#FF7A18"

def fetch(path, ttl = 60):
    r = http.get(BASE + path, ttl_seconds = ttl)
    if r["status_code"] != 200:
        return None
    return r["json"]

def score(row):
    custom = row.get("custom_points")
    return custom if custom != None else row.get("points")

def points(value):
    if value == None:
        return "--"
    n = int((value if value >= 0 else -value) * 100 + 0.5)
    return ("-" if value < 0 else "") + str(n // 100) + "." + ("0" + str(n % 100))[-2:]

def clean(value):
    s = str(value).upper()
    allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-'&/!"
    return "".join([s[i] if s[i] in allowed else " " for i in range(len(s))]).strip()

def fit(c, value, width):
    s = clean(value)
    if c.text_width(s, font = "5x7") <= width:
        return s
    for n in range(len(s), -1, -1):
        t = s[:n] + "."
        if c.text_width(t, font = "5x7") <= width:
            return t
    return ""

def header(c, label):
    c.fill("black")
    c.rect(8, 0, c.width - 9, 8, fill = ORANGE)
    c.text(fit(c, label, c.width - 20), 10, 1, font = "5x7", color = "black")

def message(c, title, body):
    header(c, title)
    c.text(fit(c, body, c.width - 16), 8, 16, font = "5x7", color = "white")

def demo():
    return {"demo": True, "week": 1, "mine": {"points": 104.72}, "opp": {"points": 98.36}, "opponent": "SAMPLE OPPONENT", "settings": {"wins": 2, "losses": 1, "ties": 0, "fpts": 365, "fpts_decimal": 42}, "rows": [["HARPCITY HIGHLIGHTS", 2, 1, 0], ["SAMPLE TEAM TWO", 1, 2, 0]], "rid": 1}

def get_data(ctx):
    if ctx.inputs.get("mode", "live") == "demo":
        return demo()
    lid = str(ctx.inputs.get("leagueid", "")).strip()
    if not lid:
        return demo()
    if not lid.isdigit():
        return {"error": "USE NUMERIC LEAGUE ID"}
    target = str(ctx.inputs.get("teamname", "")).strip().lower()
    rid = int(ctx.inputs.get("rosterid", 0))
    week = int(ctx.inputs.get("week", 0))
    if week < 0 or week > 18:
        return {"error": "WEEK MUST BE 0 TO 18"}
    league = fetch("league/" + lid, 300)
    users = fetch("league/" + lid + "/users", 300)
    rosters = fetch("league/" + lid + "/rosters")
    if league == None or users == None or rosters == None:
        return {"error": "SLEEPER UNAVAILABLE"}
    if league.get("sport") != "nfl":
        return {"error": "NFL LEAGUE REQUIRED"}
    if week == 0:
        state = fetch("state/nfl", 300)
        if state == None:
            return {"error": "NFL WEEK UNAVAILABLE"}
        if str(state.get("season")) != str(league.get("season")) or state.get("season_type") != "regular":
            return {"error": "SELECT A WEEK IN SETTINGS"}
        week = int(state.get("week") or 0)
        if week < 1 or week > 18:
            return {"error": "NO CURRENT NFL WEEK"}
    names = {}
    owners = []
    for u in users:
        name = (u.get("metadata") or {}).get("team_name") or u.get("display_name") or "UNNAMED TEAM"
        names[u["user_id"]] = name
        if name.strip().lower() == target:
            owners.append(u["user_id"])
    candidates = []
    for r in rosters:
        if (rid > 0 and r["roster_id"] == rid) or (rid == 0 and r.get("owner_id") in owners):
            candidates.append(r)
    if len(candidates) != 1:
        return {"error": "SET EXACT TEAM OR ROSTER ID"}
    mine_roster = candidates[0]
    rid = mine_roster["roster_id"]
    matches = fetch("league/" + lid + "/matchups/" + str(week))
    mine = None
    opponents = []
    if matches != None:
        for m in matches:
            if m["roster_id"] == rid:
                mine = m
        if mine != None and mine.get("matchup_id") != None:
            opponents = [m for m in matches if m["roster_id"] != rid and m.get("matchup_id") == mine["matchup_id"]]
    opp = opponents[0] if len(opponents) == 1 else None
    opponent_name = "OPPONENT"
    rows = []
    for r in rosters:
        name = names.get(r.get("owner_id"), "TEAM " + str(r["roster_id"]))
        s = r.get("settings") or {}
        rows.append([name, s.get("wins", 0), s.get("losses", 0), s.get("ties", 0)])
        if opp != None and r["roster_id"] == opp["roster_id"]:
            opponent_name = name
    return {"demo": False, "week": week, "mine": mine, "opp": opp, "opponent": opponent_name, "settings": mine_roster.get("settings") or {}, "rows": rows, "match_error": matches == None, "rid": rid}

def ready(c, d):
    if d.get("error"):
        message(c, "HARPCITY HIGHLIGHTS", d["error"])
        return False
    return True

def tag(d, title):
    return ("DEMO / " if d["demo"] else "") + title

def matchup(c, ctx):
    d = get_data(ctx)
    if not ready(c, d):
        return
    if d.get("match_error"):
        message(c, "HARPCITY HIGHLIGHTS", "MATCHUP DATA UNAVAILABLE")
        return
    if d["mine"] == None or d["opp"] == None:
        message(c, tag(d, "WEEK " + str(d["week"])), "NO HEAD-TO-HEAD MATCHUP")
        return
    header(c, tag(d, "HARPCITY / WK " + str(d["week"])))
    c.text("YOUR TEAM", 8, 12, font = "5x7", color = ORANGE)
    c.text(points(score(d["mine"])), c.width - 8, 12, font = "5x7", color = "white", align = "right")
    c.text(fit(c, d["opponent"], c.width - 22 - c.text_width(points(score(d["opp"])), font = "5x7")), 8, 23, font = "5x7", color = "gray")
    c.text(points(score(d["opp"])), c.width - 8, 23, font = "5x7", color = "white", align = "right")

def margin(c, ctx):
    d = get_data(ctx)
    if not ready(c, d):
        return
    if d["mine"] == None or d["opp"] == None:
        message(c, "SCORE MARGIN", "MATCHUP NOT AVAILABLE")
        return
    a = score(d["mine"])
    b = score(d["opp"])
    if a == None or b == None:
        message(c, "SCORE MARGIN", "SCORE NOT AVAILABLE")
        return
    delta = a - b
    label = "LEADING BY " if delta > 0 else "TRAILING BY "
    header(c, tag(d, "HIGHLIGHTS / WK " + str(d["week"])))
    text = "TIED AT " + points(a) if delta == 0 else label + points((delta if delta >= 0 else -delta))
    c.text(text, c.width // 2, 15, font = "5x7", color = "green" if delta > 0 else "amber", align = "center")

def record(c, ctx):
    d = get_data(ctx)
    if not ready(c, d):
        return
    s = d["settings"]
    header(c, tag(d, "HARPCITY RECORD"))
    c.text("W %s  L %s  T %s" % (s.get("wins", 0), s.get("losses", 0), s.get("ties", 0)), 8, 12, font = "5x7", color = "white")
    pf = s.get("fpts", 0) + s.get("fpts_decimal", 0) / 100.0
    c.text("POINTS FOR " + points(pf), 8, 23, font = "5x7", color = ORANGE)

def league_records(c, ctx):
    d = get_data(ctx)
    if not ready(c, d):
        return
    rows = d["rows"]
    if not rows:
        message(c, "LEAGUE RECORDS", "NO ROSTERS")
        return
    # Roster order, not playoff rank. Rotate through two teams per refresh.
    blocks = (len(rows) + 1) // 2
    block = (ctx.now.unix // 60) % blocks
    header(c, tag(d, "LEAGUE RECORDS %d/%d" % (block + 1, blocks)))
    for i in range(2):
        index = block * 2 + i
        if index < len(rows):
            row = rows[index]
            y = 12 + i * 11
            c.text(fit(c, row[0], c.width - 22 - c.text_width("%d-%d-%d" % (row[1], row[2], row[3]), font = "5x7")), 8, y, font = "5x7", color = "white")
            c.text("%d-%d-%d" % (row[1], row[2], row[3]), c.width - 8, y, font = "5x7", color = ORANGE, align = "right")
