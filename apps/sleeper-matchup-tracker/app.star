# Sleeper Matchup Tracker — a GDN Starlark app (64x32, 10 pages).
#
# Your Sleeper fantasy matchups across two leagues, plus your NFL teams:
#
#   tpl_matchup / lhl_matchup  Your live score vs your opponent (or the
#                              upcoming matchup pre-kickoff), tagged TPL/LHL.
#   tpl_stars / lhl_stars      Top 3 scorers on your roster — anyone at 4+
#                              points glows orange — plus your biggest bust.
#   tpl_board / lhl_board      League standings: top 3 and your row.
#   patriots / vikings         Live score, game status, and rotating top
#                              stat leaders (pre-game: season leaders).
#   afce / nfcn                AFC East / NFC North standings, your team gold.
#
# Data: Sleeper (keyless) + ESPN (keyless). Each page stays inside the
# 8-uncached-requests-per-render ceiling; player names cache 24 h.

SLEEPER = "https://api.sleeper.app/v1/"
ESPN_SCORE = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"
ESPN_STAND = "https://site.web.api.espn.com/apis/v2/sports/football/nfl/standings"
HEADERS = {"User-Agent": "glance-sleeper-matchup-tracker (glance-led.dev)"}

TTL_STATE = 3600
TTL_MATCHUP = 120
TTL_ROSTER = 3600
TTL_USERS = 86400
TTL_PLAYER = 86400
TTL_SCORE = 90
TTL_STAND = 3600

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
GOLD = "#FFC62F"
GOOD = "#2FE06F"
BAD = "#FF4A3D"
HOT = "#FF9A1F"
OFFLINE = "#3C4043"

# ----------------------------------------------------------------- helpers
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def num(s, fallback = 0):
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    if t == "":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return -int(t) if neg else int(t)

def inum(v, fallback = 0):
    # num() rejects floats ("5.0"); ESPN serves most stats as floats.
    if type(v) == "float":
        return int(v)
    if type(v) == "int":
        return v
    return num(v, fallback)

def fnum(s, fallback = 0.0):
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    parts = t.split(".")
    if len(parts) > 2 or parts[0] == "":
        return fallback
    for ch in parts[0].elems():
        if ch < "0" or ch > "9":
            return fallback
    v = float(int(parts[0]))
    if len(parts) == 2:
        frac = parts[1]
        if frac == "":
            return fallback
        for ch in frac.elems():
            if ch < "0" or ch > "9":
                return fallback
        div = 1.0
        for _ in frac.elems():
            div = div * 10.0
        v = v + float(int(frac)) / div
    return -v if neg else v

def isnum(s):
    t = str(s)
    if t == "":
        return False
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return False
    return True

def fmt1(x):
    # One decimal, trimming a ".0" tail. Never emits "-0".
    neg = x < 0
    v = -x if neg else x
    whole = int(v)
    frac = int((v - whole) * 10 + 0.5)
    if frac >= 10:
        whole = whole + 1
        frac = 0
    if whole == 0 and frac == 0:
        return "0"
    s = str(whole) if frac == 0 else str(whole) + "." + str(frac)
    return ("-" if neg else "") + s

def clip(c, s, font, maxw):
    s = str(s)
    if c.text_width(s, font) <= maxw:
        return s
    for n in range(len(s), 0, -1):
        t = s[:n]
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def fit(c, s, fonts, maxw):
    for f in fonts:
        if c.text_width(s, f) <= maxw:
            return [f, s]
    return [fonts[len(fonts) - 1], clip(c, s, fonts[len(fonts) - 1], maxw)]

def short_name(full):
    # "Ollie Gordon II" -> "GORDON"; "Amon-Ra St. Brown" -> "BROWN".
    parts = str(full).strip().split(" ")
    last = parts[len(parts) - 1].upper()
    if last in ["II", "III", "IV", "V", "JR", "SR"] and len(parts) > 1:
        last = parts[len(parts) - 2].upper()
    return last.replace(".", "")

# ------------------------------------------------------------------ fetch
def sget(url, params, ttl):
    r = http.get(url, params = params, headers = HEADERS, ttl_seconds = ttl)
    code = r["status_code"]
    if code == 0:
        return [False, "OFFLINE", None]
    j = r["json"]
    if code != 200 or (type(j) != "dict" and type(j) != "list"):
        return [False, "HTTP " + str(code), None]
    return [True, "", j]

def nfl_state():
    r = sget(SLEEPER + "state/nfl", {}, TTL_STATE)
    if not r[0]:
        return {"ok": False, "err": r[1]}
    j = r[2]
    return {"ok": True, "week": num(get(j, "week", 0)),
            "season": str(get(j, "season", "")),
            "stype": str(get(j, "season_type", ""))}

def league_users(lid):
    r = sget(SLEEPER + "league/" + lid + "/users", {}, TTL_USERS)
    if not r[0]:
        return {"ok": False, "err": r[1]}
    users = {}
    for u in r[2]:
        uid = str(get(u, "user_id", ""))
        meta = get(u, "metadata", {})
        name = str(get(meta, "team_name", "")).strip()
        if name == "":
            name = str(get(u, "display_name", "")).strip()
        users[uid] = name
    return {"ok": True, "users": users, "raw": r[2]}

def ascii_only(s):
    # LED fonts are ASCII-only; emoji in team names would render as tofu.
    out = ""
    for ch in str(s).elems():
        if ch >= " " and ch <= "~":
            out = out + ch
    return " ".join(out.split())

def team_abbr(name):
    # "Emeka Da Pizza" -> "EME"; "Treyven The Hunter" -> "TRE".
    w = str(name).strip().upper().split(" ")
    a = w[0] if len(w) > 0 else "?"
    a = "".join([ch for ch in a.elems() if ch >= "A" and ch <= "Z"])
    if a == "":
        a = "?"
    return a[:3]

def rec_str(s):
    w = num(get(s, "wins", 0))
    l = num(get(s, "losses", 0))
    t = num(get(s, "ties", 0))
    r = str(w) + "-" + str(l)
    if t > 0:
        r = r + "-" + str(t)
    return r

def matchup_bundle(ctx, league_key, tag):
    """Everything a Sleeper page needs. ok=False carries err text."""
    lid = str(ctx.inputs.get(league_key, "")).strip()
    want = str(ctx.inputs.get("sleeperuser", "Probrum")).strip().upper()
    if lid == "":
        return {"ok": False, "err": "NO LEAGUE ID"}
    st = nfl_state()
    if not st["ok"]:
        return {"ok": False, "err": st["err"]}
    week = st["week"]
    if week <= 0:
        return {"ok": False, "err": "NO WEEK"}
    mu = sget(SLEEPER + "league/" + lid + "/matchups/" + str(week), {}, TTL_MATCHUP)
    if not mu[0]:
        return {"ok": False, "err": mu[1]}
    ro = sget(SLEEPER + "league/" + lid + "/rosters", {}, TTL_ROSTER)
    if not ro[0]:
        return {"ok": False, "err": ro[1]}
    us = league_users(lid)
    if not us["ok"]:
        return {"ok": False, "err": us["err"]}
    uid = ""
    for u in us["raw"]:
        if str(get(u, "display_name", "")).strip().upper() == want:
            uid = str(get(u, "user_id", ""))
    if uid == "":
        return {"ok": False, "err": "USER NOT FOUND"}
    my_roster = None
    for x in ro[2]:
        if str(get(x, "owner_id", "")) == uid:
            my_roster = x
    if my_roster == None:
        return {"ok": False, "err": "NO ROSTER"}
    mid = get(my_roster, "roster_id", 0)
    my_e = None
    for x in mu[2]:
        if get(x, "roster_id", -1) == mid:
            my_e = x
    if my_e == None:
        return {"ok": False, "err": "NO MATCHUP"}
    game = get(my_e, "matchup_id", -1)
    opp_e = None
    opp_roster = None
    for x in mu[2]:
        if get(x, "matchup_id", -2) == game and get(x, "roster_id", -1) != mid:
            opp_e = x
    if opp_e != None:
        for x in ro[2]:
            if get(x, "roster_id", -1) == get(opp_e, "roster_id", -2):
                opp_roster = x
    my_name = us["users"].get(uid, want)
    opp_name = "?"
    opp_rec = ""
    if opp_roster != None:
        opp_name = us["users"].get(str(get(opp_roster, "owner_id", "")), "?")
        opp_rec = rec_str(get(opp_roster, "settings", {}))
    return {"ok": True, "tag": tag, "week": week,
            "my": my_e, "opp": opp_e,
            "my_name": ascii_only(my_name), "opp_name": ascii_only(opp_name),
            "my_rec": rec_str(get(my_roster, "settings", {})), "opp_rec": opp_rec}

def starter_pairs(entry):
    """[[player_id, live_points], ...] for the entry's starters."""
    starters = get(entry, "starters", [])
    pts = get(entry, "starters_points", [])
    out = []
    for i in range(len(starters)):
        p = 0.0
        if i < len(pts):
            p = fnum(pts[i], 0.0)
        out.append([str(starters[i]), p])
    return out

def sort_desc(pairs):
    # Insertion sort, points descending.
    for i in range(1, len(pairs)):
        k = pairs[i]
        j = i - 1
        for _ in range(i):
            if j < 0 or pairs[j][1] >= k[1]:
                break
            pairs[j + 1] = pairs[j]
            j = j - 1
        pairs[j + 1] = k
    return pairs

def player_name(pid):
    if not isnum(pid):
        return pid.upper() + " D"
    r = sget(SLEEPER + "players/nfl/" + pid, {}, TTL_PLAYER)
    if not r[0]:
        return "ID" + pid
    j = r[2]
    # full_name is null on this endpoint; build from first/last.
    full = str(get(j, "full_name", "")).strip()
    if full == "":
        full = (str(get(j, "first_name", "")).strip() + " " +
                str(get(j, "last_name", "")).strip()).strip()
    if full == "":
        pos = str(get(j, "position", "")).strip().upper()
        tm = str(get(j, "team", "")).strip().upper()
        combo = (pos + " " + tm).strip()
        return combo if combo != "" else "ID" + pid
    return short_name(full)

def board_rows(lid, uid):
    """Standings rows sorted by wins then points-for. [rank, abbr, rec, mine]"""
    ro = sget(SLEEPER + "league/" + lid + "/rosters", {}, TTL_ROSTER)
    if not ro[0]:
        return {"ok": False, "err": ro[1]}
    us = league_users(lid)
    if not us["ok"]:
        return {"ok": False, "err": us["err"]}
    rows = []
    for x in ro[2]:
        s = get(x, "settings", {})
        w = num(get(s, "wins", 0))
        fpts = fnum(get(s, "fpts", 0), 0.0) + fnum(get(s, "fpts_decimal", 0), 0.0) / 100.0
        name = us["users"].get(str(get(x, "owner_id", "")), "?")
        rows.append({"w": w, "fpts": fpts, "abbr": team_abbr(name),
                     "rec": rec_str(s),
                     "mine": str(get(x, "owner_id", "")) == uid})
    # Sort: wins desc, then fpts desc.
    for i in range(1, len(rows)):
        k = rows[i]
        j = i - 1
        for _ in range(i):
            if j < 0:
                break
            kj = rows[j]
            if kj["w"] > k["w"] or (kj["w"] == k["w"] and kj["fpts"] >= k["fpts"]):
                break
            rows[j + 1] = kj
            j = j - 1
        rows[j + 1] = k
    out = []
    for i in range(len(rows)):
        r = rows[i]
        out.append([i + 1, r["abbr"], r["rec"], r["mine"]])
    return {"ok": True, "rows": out}

def find_uid(ctx, lid):
    want = str(ctx.inputs.get("sleeperuser", "Probrum")).strip().upper()
    us = league_users(lid)
    if not us["ok"]:
        return ""
    for u in us["raw"]:
        if str(get(u, "display_name", "")).strip().upper() == want:
            return str(get(u, "user_id", ""))
    return ""

# ------------------------------------------------------------------- ESPN
def scoreboard():
    r = sget(ESPN_SCORE, {}, TTL_SCORE)
    if not r[0]:
        return {"ok": False, "err": r[1]}
    return {"ok": True, "events": get(r[2], "events", [])}

def any_live(events):
    for e in events:
        comp = get(e, "competitions", [{}])[0]
        t = get(get(comp, "status", {}), "type", {})
        if str(get(t, "state", "")) == "in":
            return True
    return False

def all_final(events):
    seen = False
    for e in events:
        seen = True
        comp = get(e, "competitions", [{}])[0]
        t = get(get(comp, "status", {}), "type", {})
        if str(get(t, "state", "")) != "post":
            return False
    return seen

def team_game(abbr):
    """Score + leaders for one club's current-week game."""
    sb = scoreboard()
    if not sb["ok"]:
        return {"ok": False, "err": sb["err"]}
    for e in sb["events"]:
        comp = get(e, "competitions", [{}])[0]
        cmap = {}
        for c in get(comp, "competitors", []):
            team = get(c, "team", {})
            cmap[str(get(team, "abbreviation", "")).upper()] = c
        if abbr not in cmap:
            continue
        me = cmap[abbr]
        opp_abbr = ""
        opp = None
        for k in cmap:
            if k != abbr:
                opp_abbr = k
                opp = cmap[k]
        t = get(get(comp, "status", {}), "type", {})
        state = str(get(t, "state", ""))
        detail = str(get(t, "shortDetail", ""))
        return {"ok": True, "me": num(get(me, "score", 0)),
                "opp": num(get(opp, "score", 0)), "opp_abbr": opp_abbr,
                "state": state, "detail": detail,
                "leaders": get(me, "leaders", [])}
    return {"ok": False, "err": "NO GAME"}

def weekday_name(month, day, year):
    # Zeller's congruence; returns SUN..SAT.
    m = month
    y = year
    if m < 3:
        m = m + 12
        y = y - 1
    k = y % 100
    j = y // 100
    h = (day + (13 * (m + 1)) // 5 + k + k // 4 + j // 4 + 5 * j) % 7
    names = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    return names[(h + 6) % 7]  # h: 0=Sat..6=Fri -> 0=Sun

def status_line(state, detail, year):
    # Bottom-line game status: "SUN 4:25P", "3rd 4:12", "FINAL".
    if state == "in":
        return clip_detail(detail)
    if state == "post":
        return "FINAL"
    # pre: "11/1 - 4:25 PM EST" -> "SUN 4:25P"
    d = str(detail)
    date_part = ""
    time_part = d
    if " - " in d:
        bits = d.split(" - ")
        date_part = bits[0]
        time_part = bits[1]
    tp = time_part.replace(" EST", "").replace(" EDT", "").split(" ")
    t = tp[0] if len(tp) > 0 else ""
    ap = tp[1][:1] if len(tp) > 1 else ""
    hm = t.split(":")
    ts = (hm[0] + ":" + hm[1] + ap) if len(hm) > 1 else (hm[0] + ap)
    wd = ""
    dp = date_part.split("/")
    if len(dp) == 2 and isnum(dp[0]) and isnum(dp[1]):
        wd = weekday_name(num(dp[0]), num(dp[1]), year) + " "
    return wd + ts

def clip_detail(detail):
    # "3rd 4:12" fits; "End 3rd" fits; longer gets cut to 7 chars.
    d = str(detail)
    return d if len(d) <= 7 else d[:7]

def compact_stat(display_value):
    # "141/214, 1784 YDS, 13 TD, 8 INT" -> "1784Y 13TD"
    yds = ""
    tds = ""
    for part in str(display_value).split(","):
        toks = part.strip().upper().split(" ")
        if "YDS" in toks and yds == "":
            for t in toks:
                if t != "" and t[0] >= "0" and t[0] <= "9":
                    yds = t
                    break
        if "TD" in toks and tds == "":
            for t in toks:
                if t != "" and t[0] >= "0" and t[0] <= "9":
                    tds = t
                    break
    out = ""
    if yds != "":
        out = yds + "Y"
    if tds != "":
        out = out + (" " if out != "" else "") + tds + "TD"
    return out

LEADER_LABEL = {"passingLeader": "P", "rushingLeader": "R", "receivingLeader": "C"}

def athlete_last(shortnm):
    # "A. Jones Sr." -> "JONES"; "D. Maye" -> "MAYE".
    parts = str(shortnm).strip().split(" ")
    last = parts[len(parts) - 1].upper().replace(".", "")
    if last in ["II", "III", "IV", "V", "JR", "SR"] and len(parts) > 1:
        last = parts[len(parts) - 2].upper().replace(".", "")
    return last[:6]

def leader_lines(leaders):
    """[[label, name, stat], ...] for pass/rush/rec, in that order."""
    order = ["passingLeader", "rushingLeader", "receivingLeader"]
    by_name = {}
    for l in leaders:
        by_name[str(get(l, "name", ""))] = l
    out = []
    for name in order:
        l = by_name.get(name, None)
        if l == None:
            continue
        first = get(get(l, "leaders", [{}])[0], "athlete", {})
        nm = athlete_last(get(first, "shortName", "?"))
        dv = get(get(l, "leaders", [{}])[0], "displayValue", "")
        out.append([LEADER_LABEL.get(name, "?"), nm, compact_stat(dv)])
    return out

def division_rows(conf_abbr, div_word):
    r = sget(ESPN_STAND, {"level": "3", "seasontype": "2"}, TTL_STAND)
    if not r[0]:
        return {"ok": False, "err": r[1]}
    for conf in get(r[2], "children", []):
        if str(get(conf, "abbreviation", "")).upper() != conf_abbr:
            continue
        for dv in get(conf, "children", []):
            nm = str(get(dv, "name", "")).upper()
            if not nm.endswith(div_word):
                continue
            rows = []
            for e in get(get(dv, "standings", {}), "entries", []):
                team = get(e, "team", {})
                abbr = str(get(team, "abbreviation", "")).upper()
                sm = {}
                for s in get(e, "stats", []):
                    sm[str(get(s, "name", ""))] = get(s, "value", 0)
                w = inum(sm.get("wins", 0))
                l = inum(sm.get("losses", 0))
                t = inum(sm.get("ties", 0))
                rec = str(w) + "-" + str(l)
                if t > 0:
                    rec = rec + "-" + str(t)
                sk = fnum(sm.get("streak", 0), 0.0)
                sks = ""
                if sk > 0:
                    sks = "W" + str(int(sk))
                elif sk < 0:
                    sks = "L" + str(int(-sk))
                rows.append({"abbr": abbr, "rec": rec, "streak": sks,
                             "seed": inum(sm.get("playoffSeed", 99), 99)})
            # Sort by playoff seed (ESPN's tiebreaks already applied).
            for i in range(1, len(rows)):
                k = rows[i]
                j = i - 1
                for _ in range(i):
                    if j < 0 or rows[j]["seed"] <= k["seed"]:
                        break
                    rows[j + 1] = rows[j]
                    j = j - 1
                rows[j + 1] = k
            return {"ok": True, "rows": rows, "name": nm}
    return {"ok": False, "err": "NO DIVISION"}

# ------------------------------------------------------------------ draw
def err_page(c, tag, err):
    c.fill("black")
    c.text(tag, 1, 1, font = "5x7", color = GOLD)
    hf = fit(c, err, ["5x7", "4x5"], 62)
    c.text(hf[1], 32, 12, font = hf[0], color = OFFLINE, align = "center")
    c.text("RETRY SOON", 32, 22, font = "4x5", color = DIM, align = "center")

def league_head(c, tag, week, status, scolor):
    c.text(tag, 1, 1, font = "5x7", color = GOLD)
    c.text("WK" + str(week), 22, 2, font = "4x5", color = DIM)
    c.text(status, 63, 2, font = "4x5", color = scolor, align = "right")

def matchup_status():
    sb = scoreboard()
    if not sb["ok"]:
        return ["", DIM]
    if any_live(sb["events"]):
        return ["LIVE", BAD]
    if all_final(sb["events"]):
        return ["FINAL", DIM]
    return ["PRE", INK]

# ------------------------------------------------------- pages: matchups
def draw_matchup(c, ctx, league_key, tag):
    b = matchup_bundle(ctx, league_key, tag)
    if not b["ok"]:
        err_page(c, tag, b["err"])
        return
    c.fill("black")
    my_pts = fnum(get(b["my"], "points", 0), 0.0)
    opp_pts = fnum(get(b["opp"], "points", 0), 0.0) if b["opp"] != None else 0.0
    st, scolor = matchup_status()
    league_head(c, tag, b["week"], st, scolor)
    if my_pts == 0 and opp_pts == 0:
        # Pre-kickoff: records, who you're up against.
        rc = b["my_rec"] + "  v  " + b["opp_rec"]
        c.text(rc, 32, 8, font = "4x5", color = DIM, align = "center")
        c.text("VS", 32, 13, font = "6x8", color = INK, align = "center")
        c.text(clip(c, b["opp_name"].upper(), "5x7", 60), 32, 23,
               font = "5x7", color = DIM, align = "center")
        return
    # Live / final: your score left, theirs right.
    c.text("YOU", 1, 9, font = "4x5", color = DIM)
    c.text(fmt1(my_pts), 1, 14, font = "6x8", color = INK)
    c.text("OPP", 33, 9, font = "4x5", color = DIM)
    c.text(fmt1(opp_pts), 33, 14, font = "6x8",
           color = GOOD if opp_pts < my_pts else (BAD if opp_pts > my_pts else INK))
    c.text(clip(c, b["my_name"].upper(), "4x5", 30), 1, 25, font = "4x5", color = DIM)
    c.text(clip(c, b["opp_name"].upper(), "4x5", 30), 63, 25, font = "4x5",
           color = DIM, align = "right")

def tpl_matchup(c, ctx):
    draw_matchup(c, ctx, "tplleague", "TPL")

def lhl_matchup(c, ctx):
    draw_matchup(c, ctx, "lhlleague", "LHL")

# ---------------------------------------------------------- pages: stars
def draw_stars(c, ctx, league_key, tag):
    b = matchup_bundle(ctx, league_key, tag)
    if not b["ok"]:
        err_page(c, tag, b["err"])
        return
    c.fill("black")
    c.text(tag, 1, 1, font = "4x5", color = GOLD)
    c.text("TOP PLAYS", 16, 1, font = "4x5", color = DIM)
    pairs = sort_desc(starter_pairs(b["my"]))
    if len(pairs) == 0 or pairs[0][1] <= 0:
        c.text("KICKOFF SOON", 32, 13, font = "5x7", color = DIM, align = "center")
        return
    # Top 3 scorers; the lowest starter is the bust (unless everyone ate).
    top = pairs[:3]
    bust = pairs[len(pairs) - 1]
    if bust[1] >= top[len(top) - 1][1] or bust[1] >= 10:
        bust = None
    rows = []
    for p in top:
        rows.append([player_name(p[0]), p[1], False])
    if bust != None:
        rows.append([player_name(bust[0]), bust[1], True])
    y = 8
    for r in rows:
        name, pts, is_bust = r[0], r[1], r[2]
        x0 = 1
        if is_bust:
            # Red flag square + red row: the bust. No "BUST" text — 64 px
            # can't afford the word and the name together.
            col = BAD
            c.rect(1, y + 1, 3, y + 3, fill = BAD)
            x0 = 6
        elif pts >= 4:
            col = HOT
        else:
            col = INK
        c.text(clip(c, name, "4x5", 62 - x0 - 18), x0, y, font = "4x5", color = col)
        c.text(fmt1(pts), 63, y, font = "4x5", color = col, align = "right")
        y = y + 6

def tpl_stars(c, ctx):
    draw_stars(c, ctx, "tplleague", "TPL")

def lhl_stars(c, ctx):
    draw_stars(c, ctx, "lhlleague", "LHL")

# ---------------------------------------------------------- pages: board
def draw_boards(c, ctx):
    # Both leagues' standings side by side: top 3 + your row, gold.
    c.fill("black")
    lid1 = str(ctx.inputs.get("tplleague", "")).strip()
    lid2 = str(ctx.inputs.get("lhlleague", "")).strip()
    if lid1 == "" or lid2 == "":
        err_page(c, "BOARD", "NO LEAGUE ID")
        return
    d1 = board_rows(lid1, find_uid(ctx, lid1))
    d2 = board_rows(lid2, find_uid(ctx, lid2))
    if not d1["ok"] or not d2["ok"]:
        err_page(c, "BOARD", d1["err"] if not d1["ok"] else d2["err"])
        return
    c.text("TPL", 1, 1, font = "4x5", color = GOLD)
    c.text("LHL", 34, 1, font = "4x5", color = GOLD)
    for d, x in [(d1, 1), (d2, 34)]:
        rows = d["rows"]
        show = rows[:3]
        me = None
        for r in rows:
            if r[3]:
                me = r
        if me != None and me[0] > 3:
            show.append(me)
        elif len(rows) > 3:
            show.append(rows[3])
        y = 7
        for r in show:
            abbr, rec, mine = r[1], r[2], r[3]
            c.text(clip(c, abbr + rec, "4x5", 29), x, y, font = "4x5",
                   color = GOLD if mine else INK)
            y = y + 6

def boards(c, ctx):
    draw_boards(c, ctx)

# ----------------------------------------------------- pages: NFL teams
def draw_team(c, ctx, title, abbr):
    g = team_game(abbr)
    if not g["ok"]:
        err_page(c, abbr, g["err"])
        return
    c.fill("black")
    c.text(title, 1, 1, font = "5x7", color = INK)
    mine_wins = g["me"] >= g["opp"]
    c.text(abbr + str(g["me"]), 1, 10, font = "6x8",
           color = INK if mine_wins else DIM)
    c.text(g["opp_abbr"] + str(g["opp"]), 63, 10, font = "6x8",
           color = INK if not mine_wins else DIM, align = "right")
    # One rotating stat leader (20 s each).
    lines = leader_lines(g["leaders"])
    idx = -1
    if len(lines) > 0:
        idx = (ctx.now.unix // 20) % len(lines)
        lab, nm, stat = lines[idx][0], lines[idx][1], lines[idx][2]
        line = lab + " " + nm + (" " + stat if stat != "" else "")
        c.text(clip(c, line, "4x5", 64), 1, 21, font = "4x5", color = GOLD)
    else:
        c.text("NO STATS YET", 1, 21, font = "4x5", color = DIM)
    # Bottom line: game status left, rotation dots right.
    c.text(clip(c, status_line(g["state"], g["detail"], ctx.now.year), "4x5", 44), 1, 27,
           font = "4x5", color = BAD if g["state"] == "in" else DIM)
    for i in range(len(lines)):
        x = 63 - (len(lines) - 1 - i) * 5
        c.rect(x - 2, 29, x, 31, fill = GOLD if i == idx else OFFLINE)

def patriots(c, ctx):
    draw_team(c, ctx, "PATRIOTS", "NE")

def vikings(c, ctx):
    draw_team(c, ctx, "VIKINGS", "MIN")

# ----------------------------------------------------- pages: divisions
def draw_divisions(c, ctx):
    # AFC East left, NFC North right; your team gold in each.
    c.fill("black")
    a = division_rows("AFC", "EAST")
    n = division_rows("NFC", "NORTH")
    if not a["ok"] or not n["ok"]:
        err_page(c, "DIV", a["err"] if not a["ok"] else n["err"])
        return
    c.text("AFCE", 1, 1, font = "4x5", color = DIM)
    c.text("NFCN", 34, 1, font = "4x5", color = DIM)
    for d, x, hilite in [(a, 1, "NE"), (n, 34, "MIN")]:
        y = 7
        for r in d["rows"][:4]:
            c.text(clip(c, r["abbr"] + r["rec"], "4x5", 29), x, y, font = "4x5",
                   color = GOLD if r["abbr"] == hilite else INK)
            y = y + 6

def divisions(c, ctx):
    draw_divisions(c, ctx)
