# RotoWire Fantasy Matchup - 128x32 (scroll), two pages.
#
# DESIGN. Your fantasy football matchup, read like a broadcast scoreboard.
# You are always on the left in cyan, the opponent on the right in orange, and
# those two colors carry through both pages so they double as the legend.
#   matchup    team names on top, the two scores as the hero (the leader in
#              white, the trailer dimmed) with the week between them, and a
#              tug-of-war win-odds bar underneath with a pixel football parked
#              on the split.
#   positions  starter points summed by position, one column each. The side
#              that won the position is lit, the other dimmed, and a small tug
#              bar under every column repeats page one's bar in miniature.
# Black ground, no fills behind text, everything inside x 6-121 so the app
# reads as its own unit between its neighbours in a scroll rotation.
#
# DATA. Two public RotoWire My Leagues endpoints, no key. NFL only: the matchup
# endpoint 404s for every other sport.
#   ajax/get-team-chooser.php      every team's id and name in a league
#   api/nfl/get-matchup-analysis   the matchup for leagueID + teamID; leaving
#                                  out `week` returns the week in progress
# So the viewer types a league ID and their team's name, and the app finds the
# team id and the week on its own.

CHOOSER = "https://www.rotowire.com/myleagues/ajax/get-team-chooser.php"
MATCHUP = "https://www.rotowire.com/myleagues/api/nfl/get-matchup-analysis.php"

# Scores move play by play on game days. manifest refresh is 120 s and the
# matchup fetch uses the same ttl, so each refresh sees fresh numbers. Team
# names barely change, so the chooser is held for an hour.
LIVE_TTL = 120
TEAMS_TTL = 3600

ME = "#3CC8FF"
OPP = "#FF8C1A"
LABEL = "#6E7A94"
TRAIL = "#7C849A"
TRACK = "#1C2230"
CARD_BG = "#0B0C12"
CARD_TITLE = "#E8B04A"
CARD_SUB = "#6A7090"

L = 6      # safe zone, left edge
R = 121    # safe zone, right edge (inclusive)
MID = 64

# "188.8" is 52 px in 11x14_bold, so the score lanes are x 6-58 and 70-121 and
# the 11 px between them holds the week.
HERO = "11x14_bold"

FOOTBALL = """
...BBBBB...
.BBBWBWBBB.
BBBWWWWWBBB
.BBBWBWBBB.
...BBBBB...
"""
BALL = {"B": "#C8743A", "W": "white"}

POS_ORDER = ["QB", "RB", "WR", "TE", "K", "DEF"]
POS_ALIAS = {"DST": "DEF", "D/ST": "DEF", "D": "DEF", "PK": "K"}
MAX_COLS = 7

# Page two picks one value style for the whole page, so "25" never sits next
# to "7.1": decimals when they fit, else whole numbers, bigger font first.
# The third value is the gap kept between neighbouring columns' numbers:
# decimals need 5 px or "20.2" "29.9" run together, whole numbers read at 3.
VALUE_STYLES = [["5x7", True, 5], ["4x5", True, 5], ["5x7", False, 3], ["4x5", False, 3]]

NAME_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 &.!?#-"
ALNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

DEMO_ME = [["QB", 24.6], ["RB", 18.2], ["RB", 11.4], ["WR", 21.3], ["WR", 9.8],
           ["TE", 7.1], ["K", 8.0], ["DEF", 6.0]]
DEMO_OPP = [["QB", 17.9], ["RB", 22.5], ["RB", 6.3], ["WR", 14.2], ["WR", 12.7],
            ["TE", 11.4], ["K", 5.0], ["DEF", 3.0]]

# ---------- text ----------

def fits(c, s, font, maxw):
    return c.text_width(s, font) <= maxw

def clip(c, s, font, maxw):
    """Hard-clip to maxw. Nothing in the API clips, so every API string goes through here."""
    if fits(c, s, font, maxw):
        return s
    for k in range(len(s) - 1, 0, -1):
        t = s[:k].rstrip()
        if fits(c, t, font, maxw):
            return t
    return ""

def clip_words(c, s, font, maxw):
    """Cut at a word when that keeps at least half of what a hard clip would:
    "BLITZ BROTHERS" -> "BLITZ", not "BLITZ BROT"."""
    if fits(c, s, font, maxw):
        return s
    hard = clip(c, s, font, maxw)
    words = s.split(" ")
    for n in range(len(words) - 1, 0, -1):
        t = " ".join(words[:n])
        if fits(c, t, font, maxw):
            return t if len(t) * 2 >= len(hard) else hard
    return hard

def fit_font(c, s, fonts, maxw):
    for f in fonts:
        if fits(c, s, f, maxw):
            return f
    return fonts[len(fonts) - 1]

# ---------- data ----------

def clean(s):
    """Team names arrive mixed-case, sometimes HTML-escaped, sometimes with
    emoji. The fonts are uppercase ASCII, so keep only what can draw. 4x5 has
    no apostrophe glyph, so "Mo's" becomes "MOS" rather than "MO S"."""
    if type(s) != "string":
        return ""
    s = s.replace("&amp;", "&").replace("&#039;", "").replace("&#39;", "")
    s = s.replace("&apos;", "").replace("&quot;", "").replace("'", "").upper()
    out = ""
    for i in range(len(s)):
        ch = s[i]
        out += ch if ch in NAME_CHARS else " "
    return " ".join(out.split())

def squash(s):
    out = ""
    for i in range(len(s)):
        if s[i] in ALNUM:
            out += s[i]
    return out

def num(v):
    t = type(v)
    if t == "float" or t == "int":
        return float(v)
    if t == "string":
        s = v.strip()
        body = s[1:] if s.startswith("-") else s
        if body != "" and body.replace(".", "", 1).isdigit():
            return float(s)
    return 0.0

def tenths(x):
    """91.40000000000001 -> "91.4"."""
    neg = x < 0
    t = int((0 - x if neg else x) * 10 + 0.5)
    s = str(t // 10) + "." + str(t % 10)
    return "-" + s if neg else s

def whole(x):
    return "-" + str(int(0 - x + 0.5)) if x < 0 else str(int(x + 0.5))

def fail(title, sub):
    return {"err": [title, sub]}

def side(name, pts, win, players):
    return {"name": name, "pts": pts, "win": win, "players": players}

def roster(raw):
    out = []
    if type(raw) != "list":
        return out
    for p in raw:
        if type(p) != "dict":
            continue
        pos = p.get("position")
        pos = pos.strip().upper() if type(pos) == "string" else ""
        pos = clean(POS_ALIAS.get(pos, pos))
        if pos == "":
            continue
        out.append({"pos": pos, "pts": num(p.get("fpts")), "starter": p.get("isStarter") == True})
    return out

def demo_roster(rows):
    return [{"pos": r[0], "pts": r[1], "starter": True} for r in rows]

def demo():
    return {
        "err": None,
        "demo": True,
        "week": 1,
        "me": side("TD KINGS", 106.4, 71.2, demo_roster(DEMO_ME)),
        "opp": side("BLITZ BROS", 93.0, 28.8, demo_roster(DEMO_OPP)),
    }

def parse_teams(html):
    """The chooser is an HTML list: <li ... data-teamid="10">La Onda</li>."""
    teams = []
    if type(html) != "string":
        return teams
    chunks = html.split("data-teamid=\"")
    for i in range(1, len(chunks)):
        ch = chunks[i]
        q = ch.find("\"")
        gt = ch.find(">")
        lt = ch.find("<", gt + 1)
        if q <= 0 or gt < 0 or lt < 0:
            continue
        teams.append({"id": ch[:q], "name": clean(ch[gt + 1:lt])})
    return teams

def match_team(teams, want):
    """Exact name first (ignoring spaces and punctuation), then a team number,
    then a unique partial name."""
    key = squash(want)
    if key == "":
        return ""
    for t in teams:
        if squash(t["name"]) == key:
            return t["id"]
    if want.isdigit():
        for t in teams:
            if t["id"] == want:
                return t["id"]
    hits = [t["id"] for t in teams if key in squash(t["name"])]
    if len(hits) == 1:
        return hits[0]
    if len(hits) > 1:
        return "many"
    return ""

def read_matchup(ctx):
    league = ctx.inputs.get("league", "")
    league = league.strip() if type(league) == "string" else ""
    want = clean(ctx.inputs.get("team", ""))
    if league == "":
        return demo()
    if not league.isdigit():
        return fail("CHECK LEAGUE ID", "USE NUMBERS ONLY")
    if want == "":
        return fail("PICK YOUR TEAM", "ADD YOUR TEAM NAME")

    # The chooser turns a name (or a team number) into the team id, and doubles
    # as the check that the league exists, so a typo gets a specific message.
    resp = http.get(CHOOSER, params = {"leagueID": league, "sport": "nfl"}, ttl_seconds = TEAMS_TTL)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return fail("ROTOWIRE OFFLINE", "TRYING AGAIN SOON")
    teams = []
    if resp["json"].get("success") == True:
        teams = parse_teams(resp["json"].get("modalHTML"))
    if len(teams) == 0:
        return fail("LEAGUE NOT FOUND", "CHECK THE LEAGUE ID")
    tid = match_team(teams, want)
    if tid == "many":
        return fail("NAME FITS 2+ TEAMS", "TYPE MORE OF IT")
    if tid == "":
        return fail("TEAM NOT FOUND", "CHECK THE TEAM NAME")

    resp = http.get(MATCHUP, params = {"leagueID": league, "teamID": tid}, ttl_seconds = LIVE_TTL)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return fail("ROTOWIRE OFFLINE", "TRYING AGAIN SOON")
    data = resp["json"]
    info = data.get("matchupInfo")
    if type(info) != "dict":
        return fail("NO MATCHUP FOUND", "CHECK LEAGUE + TEAM")

    me = side(clean(info.get("teamName")) or "YOU", num(info.get("teamFpts")),
              num(info.get("teamWinPercentage")), roster(data.get("teamPlayers")))
    opp = None
    oname = clean(info.get("oppTeamName"))
    if oname != "" or num(info.get("oppTeamID")) > 0:
        opp = side(oname or "OPPONENT", num(info.get("oppTeamFpts")),
                   num(info.get("oppTeamWinPercentage")), roster(data.get("oppTeamPlayers")))
    return {"err": None, "demo": False, "week": int(num(info.get("currentWeek"))), "me": me, "opp": opp}

# ---------- shared pieces ----------

def card(c, title, sub, title_color):
    """No-data card: the football for identity, then a what and a what-to-do.
    The sub column is x 33-121 (89 px); "CHECK THE TEAM NAME" is 88 px."""
    c.fill(CARD_BG)
    c.sprite(FOOTBALL, L, 11, legend = BALL, scale = 2)
    x = L + 22 + 5
    maxw = R - x + 1
    tf = fit_font(c, title, ["6x8", "5x7", "4x5"], maxw)
    c.text(clip(c, title, tf, maxw), x, 8, font = tf, color = title_color)
    c.text(clip(c, sub, "4x5", maxw), x, 20, font = "4x5", color = CARD_SUB)

def not_live(c, m):
    """Draws the card and returns True when there's no matchup to show."""
    if m["err"] != None:
        card(c, m["err"][0], m["err"][1], CARD_TITLE)
        return True
    if m["opp"] == None:
        card(c, "BYE WEEK", "NO GAME THIS WEEK", ME)
        return True
    return False

def tug(c, x0, x1, y0, y1, a, b):
    """A bar split by share: a from the left in ME, b from the right in OPP."""
    a = max(a, 0.0)
    b = max(b, 0.0)
    if a + b <= 0:
        c.rect(x0, y0, x1, y1, fill = TRACK)
        return x0 + (x1 - x0 + 1) // 2
    split = x0 + int((x1 - x0 + 1) * a / (a + b) + 0.5)
    c.rect(x0, y0, x1, y1, fill = OPP)
    if split > x0:
        c.rect(x0, y0, split - 1, y1, fill = ME)
    return split

# ---------- page 1: the matchup ----------

def matchup(c, ctx):
    m = read_matchup(ctx)
    if not_live(c, m):
        return
    me = m["me"]
    op = m["opp"]
    c.clear()

    # Row 1 (y 1-5): team names, each in its half with a 6 px gap in the middle
    # (55 px, so "DIMASSTYLE" fits whole). A DEMO tag takes the center and the
    # names shrink around it.
    nw = (R - L + 1 - 6) // 2
    if m["demo"]:
        tw = c.text_width("DEMO", "4x5")
        tx = MID - tw // 2
        c.text("DEMO", tx, 1, font = "4x5", color = CARD_TITLE)
        nw = min(tx - 3 - L, R - (tx + tw + 3) + 1)
    a = clip_words(c, me["name"], "4x5", nw)
    b = clip_words(c, op["name"], "4x5", nw)
    c.text(a, L, 1, font = "4x5", color = ME)
    c.text(b, R + 1 - c.text_width(b, "4x5"), 1, font = "4x5", color = OPP)

    # Row 2 (y 8-21): the scores, each clipped to its lane. Leader white,
    # trailer dimmed, a tie lights both. The week stacks in the 11 px between.
    sa = clip(c, tenths(me["pts"]), HERO, 58 - L + 1)
    sb = clip(c, tenths(op["pts"]), HERO, R - 70 + 1)
    c.text(sa, L, 8, font = HERO, color = "white" if me["pts"] >= op["pts"] else TRAIL)
    c.text(sb, R + 1 - c.text_width(sb, HERO), 8, font = HERO,
           color = "white" if op["pts"] >= me["pts"] else TRAIL)
    if m["week"] > 0:
        c.text("WK", MID, 9, font = "4x5", color = LABEL, align = "center")
        c.text(clip(c, str(m["week"]), "4x5", 11), MID, 16, font = "4x5", color = "white", align = "center")
    else:
        c.text("VS", MID - 3, 13, font = "vs", color = LABEL)

    # Row 3 (y 25-29): win odds as a tug of war with the football on the split,
    # labelled WIN so the percentages aren't loose numbers. Bar ends are fixed
    # by the widest labels ("WIN 100%" 35 px, "100%" 17 px) so the bar never
    # changes length as the odds move.
    pa = max(0, min(100, int(me["win"] + 0.5)))
    lb = str(100 - pa) + "%"
    c.text("WIN", L, 25, font = "4x5", color = LABEL)
    c.text(str(pa) + "%", L + c.text_width("WIN ", "4x5"), 25, font = "4x5", color = ME)
    c.text(lb, R + 1 - c.text_width(lb, "4x5"), 25, font = "4x5", color = OPP)
    x0 = L + c.text_width("WIN 100%", "4x5") + 3
    x1 = R - c.text_width("100%", "4x5") - 3
    split = tug(c, x0, x1, 26, 28, float(pa), float(100 - pa))
    bx = max(x0, min(x1 - 10, split - 5))
    c.rect(bx - 1, 25, bx + 11, 29, fill = "black")
    c.sprite(FOOTBALL, bx, 25, legend = BALL)

# ---------- page 2: the position battle ----------

def totals(players):
    out = {}
    for p in players:
        if p["starter"]:
            out[p["pos"]] = out.get(p["pos"], 0.0) + p["pts"]
    return out

def sum_of(t, keys):
    s = 0.0
    for k in keys:
        s += t.get(k, 0.0)
    return s

def positions(c, ctx):
    m = read_matchup(ctx)
    if not_live(c, m):
        return
    ta = totals(m["me"]["players"])
    tb = totals(m["opp"]["players"])

    groups = [g for g in POS_ORDER if g in ta or g in tb]
    for g in sorted(ta.keys() + tb.keys()):
        if g not in groups:
            groups.append(g)
    if len(groups) == 0:
        card(c, "NO LINEUPS YET", "BACK AT KICKOFF", ME)
        return
    if len(groups) > MAX_COLS:
        tail = groups[MAX_COLS - 1:]
        groups = groups[:MAX_COLS - 1] + ["OTH"]
        ta["OTH"] = sum_of(ta, tail)
        tb["OTH"] = sum_of(tb, tail)

    c.clear()

    # Gutter: a YOU / OPP legend for the two value rows under a corner mark,
    # the football (or DEMO on sample data). Kept as narrow as its words: a
    # "WK1" tag here pushed four columns to 24 px and "20.2" "29.9" in 5x7 ran
    # together, so the week lives on page one only.
    gw = max(11, c.text_width("YOU", "4x5"), c.text_width("OPP", "4x5"))
    if m["demo"]:
        gw = max(gw, c.text_width("DEMO", "4x5"))
        c.text("DEMO", L, 1, font = "4x5", color = CARD_TITLE)
    else:
        c.sprite(FOOTBALL, L, 1, legend = BALL)
    c.text("YOU", L, 9, font = "4x5", color = ME)
    c.text("OPP", L, 18, font = "4x5", color = OPP)

    # Columns share what's right of the gutter, starting 2 px after it. Each
    # value gets its column width minus the style's gap (see VALUE_STYLES).
    left = L + gw + 2
    n = len(groups)
    cw = (R - left + 1) // n
    left = left + (R - left + 1 - cw * n) // 2
    style = VALUE_STYLES[len(VALUE_STYLES) - 1]
    for st in VALUE_STYLES:
        ok = True
        for g in groups:
            for v in [ta.get(g, 0.0), tb.get(g, 0.0)]:
                s = tenths(v) if st[1] else whole(v)
                if not fits(c, s, st[0], cw - st[2]):
                    ok = False
        if ok:
            style = st
            break
    vf = style[0]
    vy = [8, 17] if vf == "5x7" else [9, 18]

    for i in range(n):
        g = groups[i]
        a = ta.get(g, 0.0)
        b = tb.get(g, 0.0)
        cx = left + i * cw + cw // 2
        sa = tenths(a) if style[1] else whole(a)
        sb = tenths(b) if style[1] else whole(b)
        c.text(clip(c, g, "4x5", cw - 1), cx, 1, font = "4x5", color = "white", align = "center")
        c.text(clip(c, sa, vf, cw - style[2]), cx, vy[0], font = vf, align = "center",
               color = ME if a >= b else color.dim(ME, 40))
        c.text(clip(c, sb, vf, cw - style[2]), cx, vy[1], font = vf, align = "center",
               color = OPP if b >= a else color.dim(OPP, 40))
        tug(c, left + i * cw + 2, left + (i + 1) * cw - 3, 27, 28, a, b)
