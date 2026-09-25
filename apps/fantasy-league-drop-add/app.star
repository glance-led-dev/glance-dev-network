# ---- BEGIN fantasy_league.star v2 ----
# ======================================================================
# FANTASY LEAGUE ADAPTER v2 - paste this block into an app.star (GDN apps
# are one file; nothing is loaded at runtime). Read _shared/NOTES.md first.
# To upgrade an app, replace everything from the BEGIN marker line to the
# END marker line with this file - nothing else changes.
#
# One call turns the viewer's three inputs into a normalised league:
#
#   lg = fl_load(ctx, projections = True)
#   lg = fl_load(ctx, matchups = False)  # Sleeper: skip matchups/{week} (no
#                   scores, matchups, played, last) - saves a request
#
#   lg["ok"]        False -> draw lg["err"] = [head, sub] on the error card
#   lg["state"]     "live" | "demo" | "predraft" | "nomatch"
#   lg["platform"]  "SLEEPER" | "ESPN" | "DEMO"
#   lg["name"], lg["season"], lg["week"], lg["scoring"] ("PPR"/"HALF"/"STD")
#   lg["teams"]     [{id, name, abbrev, owner, wins, losses, ties, pf, pa,
#                     rank, streak}] sorted by rank (1 = first place)
#   lg["by_id"]     id -> team
#   lg["matchups"]  this week: [{a, b, a_pts, b_pts, a_proj, b_proj,
#                     a_win (0-100, or -1 unknown), a_left, b_left, final}]
#   lg["format"]    "h2h" | "guillotine" (Sleeper type 3: no pairs, lowest
#                   score is cut - use lg["scores"])
#   lg["scores"]    id -> {pts, proj (-1 unknown), left (-1 unknown),
#                   starters (Sleeper only: filled lineup slots - 0 means a
#                   guillotine team already cut), cut (Sleeper only: the
#                   week a guillotine team was cut, 0 = alive)}
#   lg["me"]        your team id (the `team` input, forgiving match), or the
#                   first team when it's blank / unmatched
#   lg["me_matched"] False when the `team` input was blank or matched nothing
#   lg["raw"]       platform extras for app-specific reads:
#                   Sleeper {league_id, rosters, matchups, proj (pid -> row),
#                            scoring (scoring_settings, numbers only)}
#                   ESPN    {league_id, season, json (the mTeam+mMatchupScore
#                            +mSettings response), cookie (headers dict)}
#   lg["budget"]    {"n": requests used} - fl_get() refuses past 8
#   v2 additions (all optional reads - v1 apps ignore them):
#   lg["version"]   FL_VERSION
#   lg["played"]    True once any team has points this week (False Tue-Thu
#                   before kickoff, when every side is 0.0)
#   lg["last"]      last week's result, or None: {"week", "matchups" (same
#                   keys as lg["matchups"], final True, a_win 100/0/50),
#                   "scores" (id -> {pts})}. ESPN: always (free). Sleeper:
#                   fetched only while lg["played"] is False (+1 call).
#   lg["reg_weeks"] last regular-season week (ESPN matchupPeriodCount,
#                   Sleeper playoff_week_start - 1); later weeks = playoffs
#   lg["playoff_teams"] playoff field size (0 unknown)
#   lg["followed"]  Sleeper: True when an old-season ID was followed to
#                   this season's league (budget is tighter - see NOTES)
#   v2.1 additions (optional reads, no extra requests):
#   fl_load(ctx, games = True) fetches fl_nfl_games itself, ahead of the
#                   optional users refresh of a followed ID whose team
#                   already matched (the slate is worth more than fresh
#                   names); later fl_nfl_games calls are free
#   Sleeper leagues whose sport isn't "nfl" -> err NOT AN NFL LEAGUE
#   Offseason: an ESPN ID not yet renewed (new season 404, last season
#                   there) -> LEAGUE NOT RENEWED (+1 call on a 404); an old
#                   Sleeper ID with no successor in Mar-Aug -> NO <yr>
#                   LEAGUE YET / NEW SEASON NOT CREATED YET
#   lg["raw"]       Sleeper also {roster_positions (list), waiver_budget,
#                   waiver_type (0 rolling, 1 reverse standings, 2 FAAB),
#                   daily_waivers (0/1), settings (league settings dict)}
#   team["waiver_budget_used"], team["waiver_position"] (0 unknown):
#                   Sleeper roster settings; ESPN acquisitionBudgetSpent and
#                   waiverRank
# fl_locked(ctx, lg, club, date) -> has this club's game kicked off: the
# kickoff from fl_nfl_games when it was fetched, else the game date (ET
# 'YYYY-MM-DD', a Sleeper projection row's "date") and the day's earliest
# usual kickoff (fl_lock_hour: Sunday 1 pm, Thursday 8 pm, ...).
#
# Helpers: fl_mine(lg) -> [my matchup or None, "a"/"b"]; fl_mine_last(lg)
# the same for lg["last"]; fl_team(lg, id); fl_top(lg, id) -> [name, pts]
# of a team's top-scoring starter this week (Sleeper + demo; None on ESPN);
# fl_proj_pts(lg, pid) -> a Sleeper player's projection in THIS league's
# scoring (-1 unknown); fl_score(lg, stats) -> any Sleeper stats dict
# (projection or actual row["stats"]) in this league's points;
# fl_nfl_games(ctx, lg) -> club -> {opp, home, kickoff_unix, day, done,
# bye} for the week (+1 call, cached on lg); fl_badge(c, team, x, y, size) draws the team's pixel
# shield (size 24 -> 22 x 24, size 16 -> 16 x 16); team["color"] is its
# colour everywhere.
#
# Inputs it reads (declare all of them in manifest.yaml, see NOTES.md):
#   league (free-text), team (free-text), platform (AUTO/SLEEPER/ESPN),
#   espns2 + swid (api-key, only for private ESPN leagues)
# ======================================================================

FL_VERSION = "2.1.0"

FL_SLEEPER = "https://api.sleeper.app/v1/"
FL_SLEEPER_API = "https://api.sleeper.com/"
FL_ESPN = "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/"
FL_HEADERS = {"User-Agent": "glance-fantasy-league (glance-led.dev)"}

FL_TTL_LEAGUE = 3600      # league settings, managers: they barely change
FL_TTL_ROSTERS = 900      # records move once a week, rosters on waivers
FL_TTL_LIVE = 300         # scores: matches the manifest refresh
FL_TTL_PROJ = 3600        # Sleeper projections update a few times a day
FL_TTL_FOLLOW = 86400     # old-season -> this-season league lookup
FL_MAX_CALLS = 8

# Win model (Sleeper; ESPN sends its own winProbability). Each starter still
# to play adds (A + B * projection)^2 of variance, one whose game is on adds
# FL_VAR_LIVE. Fitted to ESPN's winProbability on 1,050 live ESPN matchups
# (ESPN's own per-player projections as input): mean |model - ESPN| 0.007.
FL_SD_A = 3.2
FL_SD_B = 1.06
FL_VAR_LIVE = 78.0

# Sleeper injury_status values that will not play: never "still to play".
FL_OUT = ["OUT", "IR", "SUS", "PUP", "DNR", "NA"]

FL_DIGITS = "0123456789"
FL_ALNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

# ---------------------------------------------------------------- basics
def fl_get(b, url, params = {}, headers = None, ttl = 300):
    """http.get with a request budget. The host allows 8 uncached requests
    and gives no way to see a cache hit, so every call counts; an optional
    fetch that would be the 9th returns status -1 instead of killing the
    render."""
    if b["n"] >= FL_MAX_CALLS:
        return {"status_code": -1, "json": None, "body": ""}
    b["n"] += 1
    return http.get(url, params = params, headers = headers if headers != None else FL_HEADERS,
                    ttl_seconds = ttl)

def fl_d(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def fl_num(v, fallback = 0):
    t = type(v)
    if t == "int" or t == "float":
        return v
    s = str(v).strip()
    if s == "":
        return fallback
    neg = s.startswith("-")
    if neg:
        s = s[1:]
    whole = 0
    frac = 0.0
    scale = 1.0
    seen_dot = False
    for ch in s.elems():
        if ch == ".":
            if seen_dot:
                return fallback
            seen_dot = True
            continue
        k = FL_DIGITS.find(ch)
        if k < 0:
            return fallback
        if seen_dot:
            scale = scale / 10.0
            frac += k * scale
        else:
            whole = whole * 10 + k
    out = whole + frac if seen_dot else whole
    return -out if neg else out

def fl_norm(s):
    """Uppercase letters and digits only: 'The Big-Dawgs!' -> 'THEBIGDAWGS'."""
    out = ""
    for ch in str(s).upper().elems():
        if FL_ALNUM.find(ch) >= 0:
            out += ch
    return out

def fl_clean(s):
    """Panel-safe uppercase text: keeps letters, digits and a few marks the
    fonts carry; emoji and apostrophes are dropped (JA'MARR -> JAMARR)."""
    keep = FL_ALNUM + " .,-&+#!?/"
    out = ""
    sp = True
    for ch in str(s).upper().elems():
        if keep.find(ch) < 0:
            continue
        if ch == " ":
            if sp:
                continue
            sp = True
        else:
            sp = False
        out += ch
    return out.strip()

def fl_fmt1(x):
    """One decimal, no float formatting needed: 104.56 -> '104.6'."""
    t = int(x * 10 + (0.5 if x >= 0 else -0.5))
    neg = t < 0
    if neg:
        t = -t
    return ("-" if neg else "") + str(t // 10) + "." + str(t % 10)

def fl_season(ctx):
    return ctx.now.year if ctx.now.month >= 3 else ctx.now.year - 1

def fl_exp(x):
    return math.pow(2.718281828459045, x)

def fl_phi(z):
    """Standard normal CDF (Abramowitz & Stegun 26.2.17, |error| < 8e-8)."""
    s = 1.0 if z >= 0 else -1.0
    z = z if z >= 0 else -z
    t = 1.0 / (1.0 + 0.2316419 * z)
    poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    p = 1.0 - 0.3989422804014327 * fl_exp(-z * z / 2.0) * poly
    return p if s > 0 else 1.0 - p

# ---------------------------------------------------------------- inputs
def fl_inputs(ctx):
    lid = str(ctx.inputs.get("league", "")).strip()
    team = str(ctx.inputs.get("team", "")).strip()
    plat = str(ctx.inputs.get("platform", "AUTO")).strip().upper()
    s2 = str(ctx.inputs.get("espns2", "")).strip()
    swid = str(ctx.inputs.get("swid", "")).strip()
    # People paste the whole URL or "leagueId=123"; keep the digit run.
    digits = ""
    best = ""
    for ch in (lid + " ").elems():
        if FL_DIGITS.find(ch) >= 0:
            digits += ch
        else:
            if len(digits) > len(best):
                best = digits
            digits = ""
    if plat not in ["SLEEPER", "ESPN"]:
        plat = "SLEEPER" if len(best) >= 15 else "ESPN"
    return {"raw": lid, "league": best, "team": team, "platform": plat,
            "espns2": s2, "swid": swid}

# ------------------------------------------------------------ team match
def fl_match(teams, want):
    """Exact team name, exact manager, abbreviation, then the best partial:
    a prefix beats a substring, and the field the text covers most of wins
    ('BIG' -> 'BIG DAWGS' over 'THE BIG ONES'). Right for 99.7% of 12,000
    probes across 371 real leagues (misses: one manager with two teams,
    emoji-only names)."""
    w = fl_norm(want)
    if w == "":
        return None
    for key in ["name", "owner"]:
        for t in teams:
            if fl_norm(t[key]) == w:
                return t["id"]
    for t in teams:
        if fl_norm(t["abbrev"]) == w:
            return t["id"]
    best = None
    score = 0.0
    for t in teams:
        for key in ["name", "owner", "owner_full"]:
            f = fl_norm(t[key])
            if f != "" and f.find(w) >= 0:
                sc = (2.0 if f.startswith(w) else 1.0) + len(w) / (len(f) * 1.0)
                if sc > score:
                    best = t["id"]
                    score = sc
    return best

def fl_rank(teams):
    """Standings order: win share, then points for. ESPN's own seed wins
    when it has one."""
    def key(t):
        g = t["wins"] + t["losses"] + t["ties"]
        share = (t["wins"] + 0.5 * t["ties"]) / (g * 1.0) if g > 0 else 0.0
        return (-(t["seed"] if t["seed"] > 0 else 999), share, t["pf"])
    out = sorted(teams, key = key, reverse = True)
    for i in range(len(out)):
        out[i]["rank"] = i + 1
    return out

def fl_team_rec(id, name, abbrev, owner, owner_full):
    return {"id": id, "name": name, "abbrev": abbrev, "owner": owner, "owner_full": owner_full,
            "wins": 0, "losses": 0, "ties": 0, "pf": 0.0, "pa": 0.0, "rank": 0, "seed": 0,
            "streak": "", "waiver_budget_used": 0, "waiver_position": 0}

def fl_abbrev(name):
    """'FOURTH AND LONG' -> 'FAL'; one word -> its first 4 letters."""
    words = [w for w in fl_clean(name).split(" ") if fl_norm(w) != ""]
    if len(words) >= 2:
        return "".join([fl_norm(w)[:1] for w in words])[:4]
    return fl_norm(name)[:4]

# --------------------------------------------------------------- errors
def fl_err(head, sub):
    return {"ok": False, "err": [head, sub], "state": "error", "budget": {"n": 0},
            "version": FL_VERSION}

def fl_http_err(r, who):
    sc = r["status_code"]
    if sc == 0:
        return fl_err(who + " OFFLINE", "RETRY IN 5 MIN")
    if sc == -1:
        return fl_err(who + " BUSY", "RETRY IN 5 MIN")
    return fl_err(who + " ERROR", "HTTP " + str(sc) + " - RETRY SOON")

# ---------------------------------------------------------------- Sleeper
def fl_sleeper_teams(rosters, users):
    """Team records from Sleeper rosters + league users."""
    byuser = {}
    for u in users:
        byuser[str(fl_d(u, "user_id", ""))] = u
    teams = []
    for ro in rosters:
        u = byuser.get(str(fl_d(ro, "owner_id", "")), {})
        owner = fl_clean(fl_d(u, "display_name", ""))
        name = fl_clean(fl_d(fl_d(u, "metadata", {}), "team_name", ""))
        if name == "":
            name = owner if owner != "" else "TEAM " + str(fl_d(ro, "roster_id", ""))
        t = fl_team_rec(fl_d(ro, "roster_id", 0), name, fl_abbrev(name), owner, "")
        s = fl_d(ro, "settings", {})
        t["wins"] = int(fl_num(fl_d(s, "wins", 0)))
        t["losses"] = int(fl_num(fl_d(s, "losses", 0)))
        t["ties"] = int(fl_num(fl_d(s, "ties", 0)))
        t["pf"] = fl_num(fl_d(s, "fpts", 0)) + fl_num(fl_d(s, "fpts_decimal", 0)) / 100.0
        t["pa"] = fl_num(fl_d(s, "fpts_against", 0)) + fl_num(fl_d(s, "fpts_against_decimal", 0)) / 100.0
        t["streak"] = str(fl_d(fl_d(ro, "metadata", {}), "streak", "")).upper()
        t["waiver_budget_used"] = int(fl_num(fl_d(s, "waiver_budget_used", 0), 0))
        t["waiver_position"] = int(fl_num(fl_d(s, "waiver_position", 0), 0))
        teams.append(t)
    return teams

def fl_sleeper(ctx, inp, b, projections, want_matchups = True, games = False):
    lid = inp["league"]
    season = fl_season(ctx)
    r = fl_get(b, FL_SLEEPER + "league/" + lid, ttl = FL_TTL_LEAGUE)
    if r["status_code"] != 200 and r["status_code"] != 404:
        return fl_http_err(r, "SLEEPER")
    lg = r["json"]
    if r["status_code"] == 404 or type(lg) != "dict":
        # Sleeper answers an unknown ID with 404 (older: 200 + JSON null).
        return fl_err("LEAGUE NOT FOUND", "CHECK THE SLEEPER LEAGUE ID")
    if str(fl_d(lg, "sport", "nfl")).lower() != "nfl":
        # One ID space for every Sleeper sport: an EPL ("clubsoccer:epl")
        # league loads fine and would render as a nonsense NFL lineup.
        return fl_err("NOT AN NFL LEAGUE", "ONLY NFL LEAGUES ARE SUPPORTED")

    users = None
    followed = False
    if str(fl_d(lg, "season", "")) != str(season) and str(fl_d(lg, "status", "")) == "complete":
        # A Sleeper ID is one season's league. Follow last season's ID to
        # this season's: the commissioner's league list for this season holds
        # the league whose previous_league_id is the ID we were given.
        ru = fl_get(b, FL_SLEEPER + "league/" + lid + "/users", ttl = FL_TTL_LEAGUE)
        users = ru["json"] if ru["status_code"] == 200 and type(ru["json"]) == "list" else []
        owners = [u for u in users if fl_d(u, "is_owner", False)] or users
        nxt = None
        if len(owners) > 0:
            rl = fl_get(b, FL_SLEEPER + "user/" + str(fl_d(owners[0], "user_id", "")) +
                        "/leagues/nfl/" + str(season), ttl = FL_TTL_FOLLOW)
            if rl["status_code"] == 200 and type(rl["json"]) == "list":
                for x in rl["json"]:
                    if str(fl_d(x, "previous_league_id", "")) == lid:
                        nxt = x
        if nxt == None:
            if ctx.now.month >= 3 and ctx.now.month <= 8:
                # Offseason: the commissioner hasn't renewed the league for
                # the new season yet - don't claim a new-year ID exists.
                return fl_err("NO " + str(season) + " LEAGUE YET", "NEW SEASON NOT CREATED YET")
            return fl_err(str(fl_d(lg, "season", "OLD")) + " LEAGUE ID",
                          "ENTER THE " + str(season) + " LEAGUE ID")
        lg = nxt
        followed = True
    status = str(fl_d(lg, "status", ""))
    nid = str(fl_d(lg, "league_id", lid))
    st = fl_d(lg, "settings", {})
    # settings.leg is the NFL week for almost every league; one test league
    # carried leg 6 in week 3 (and 404'd on matchups/6), so a leg that runs
    # ahead of the calendar is replaced by the calendar's week.
    week = int(fl_num(fl_d(st, "leg", 1), 1))
    cal = fl_nfl_week(ctx)
    if week < 1 or week > cal + 1:
        week = cal
    ss = {}
    for k, v in fl_d(lg, "scoring_settings", {}).items():
        if type(v) == "int" or type(v) == "float":
            ss[k] = v
    rec = ss.get("rec", 0)
    scoring = "PPR" if rec >= 1 else ("HALF" if rec >= 0.5 else "STD")
    # type 3 = guillotine: every team plays the whole league, lowest score
    # is cut - there is no head-to-head matchup, only lg["scores"].
    fmt = "guillotine" if int(fl_num(fl_d(st, "type", 0))) == 3 else "h2h"
    pws = int(fl_num(fl_d(st, "playoff_week_start", 0), 0))
    out = {"ok": True, "state": "live", "platform": "SLEEPER", "name": fl_clean(fl_d(lg, "name", "")),
           "season": season, "week": week, "scoring": scoring, "budget": b, "format": fmt,
           "scores": {}, "version": FL_VERSION, "played": False, "last": None,
           "followed": followed, "users_fresh": not followed,
           "reg_weeks": pws - 1 if pws > 1 else 14,
           "playoff_teams": int(fl_num(fl_d(st, "playoff_teams", 0), 0)),
           "teams": [], "by_id": {}, "matchups": [], "me": None, "me_matched": False,
           "raw": {"league_id": nid, "rosters": [], "matchups": [], "proj": {}, "scoring": ss,
                   "roster_positions": [str(p) for p in (fl_d(lg, "roster_positions", []) or [])],
                   "waiver_budget": int(fl_num(fl_d(st, "waiver_budget", 0), 0)),
                   "waiver_type": int(fl_num(fl_d(st, "waiver_type", 0), 0)),
                   "daily_waivers": int(fl_num(fl_d(st, "daily_waivers", 0), 0)),
                   "settings": st if type(st) == "dict" else {}}}
    if status in ["pre_draft", "drafting"]:
        out["state"] = "predraft"

    if users == None:
        ru = fl_get(b, FL_SLEEPER + "league/" + nid + "/users", ttl = FL_TTL_LEAGUE)
        users = ru["json"] if ru["status_code"] == 200 and type(ru["json"]) == "list" else []
    rr = fl_get(b, FL_SLEEPER + "league/" + nid + "/rosters", ttl = FL_TTL_ROSTERS)
    if rr["status_code"] != 200 or type(rr["json"]) != "list":
        return fl_http_err(rr, "SLEEPER")
    rosters = rr["json"]
    out["raw"]["rosters"] = rosters
    fl_finish_teams(out, fl_sleeper_teams(rosters, users), inp["team"])
    if followed and not out["me_matched"] and inp["team"] != "":
        # The team was renamed (or its manager replaced) since last season:
        # this season's managers now, ahead of everything optional - a
        # wrong "me" is worse than a missing projection.
        fl_sleeper_users_refresh(out, b, nid, rosters, followed, inp["team"])
    if out["state"] == "predraft":
        fl_sleeper_tail(ctx, out, b, nid, rosters, followed, inp["team"], games)
        return out

    if not want_matchups:
        # Apps that only need teams / rosters / player values (waivers,
        # streamers, drop & add): no scores, one request saved.
        if projections:
            out["raw"]["proj"] = fl_sleeper_proj(ctx, b, season, week)
        fl_sleeper_tail(ctx, out, b, nid, rosters, followed, inp["team"], games)
        return out
    rm = fl_get(b, FL_SLEEPER + "league/" + nid + "/matchups/" + str(week), ttl = FL_TTL_LIVE)
    if rm["status_code"] == 404 or (rm["status_code"] == 200 and type(rm["json"]) != "list"):
        out["state"] = "nomatch"
        fl_sleeper_tail(ctx, out, b, nid, rosters, followed, inp["team"], games)
        return out
    if rm["status_code"] != 200:
        return fl_http_err(rm, "SLEEPER")
    rows = rm["json"]
    out["raw"]["matchups"] = rows
    for m in rows:
        if fl_num(fl_d(m, "points", 0)) != 0:
            out["played"] = True

    # Budget order: this week's projections (3) come first once games are
    # on; in the Tue-Thu gap before any points, last week's final (1) goes
    # first, then projections only if all three still fit.
    if not out["played"] and week > 1:
        fl_sleeper_last(out, b, nid, week - 1)
    proj = {}
    if projections:
        proj = fl_sleeper_proj(ctx, b, season, week)
    out["raw"]["proj"] = proj
    today = fl_et_date(ctx)
    sched = {}
    if len(proj) > 0 and not proj.get("_partial", False) and fl_sleeper_game_today(rows, proj, today):
        sched = fl_sleeper_sched(b, season)
    pts_key = {"PPR": "pts_ppr", "HALF": "pts_half_ppr", "STD": "pts_std"}[scoring]
    elim = {}
    for ro in rosters:
        elim[fl_d(ro, "roster_id", 0)] = int(fl_num(fl_d(fl_d(ro, "settings", {}), "eliminated", 0), 0))
    fl_sleeper_matchups(out, rows, proj, pts_key, ss, today, sched, elim)
    if len(out["matchups"]) == 0 and fmt != "guillotine":
        out["state"] = "nomatch"
    fl_sleeper_tail(ctx, out, b, nid, rosters, followed, inp["team"], games)
    return out

def fl_sleeper_users_refresh(out, b, nid, rosters, followed, want):
    """A followed league starts with last season's managers (the follow
    needs them to find the commissioner). This season's /users replaces
    them - at once when the `team` input matched nobody (renamed team),
    otherwise with whatever budget is left at the end. Once per render."""
    if not followed or out["users_fresh"] or b["n"] >= FL_MAX_CALLS:
        return
    ru = fl_get(b, FL_SLEEPER + "league/" + nid + "/users", ttl = FL_TTL_LEAGUE)
    if ru["status_code"] == 200 and type(ru["json"]) == "list":
        out["users_fresh"] = True
        out["by_id"] = {}
        fl_finish_teams(out, fl_sleeper_teams(rosters, ru["json"]), want)

def fl_sleeper_tail(ctx, out, b, nid, rosters, followed, want, games):
    """The optional end of a Sleeper load. games = True (the app will draw
    the NFL slate): when your team already matched, the slate beats a
    refresh of names we already have, so it takes the budget first - a
    followed ID with projections has exactly one request left. Otherwise
    fresh names first, then the slate with whatever is left."""
    if games and out["me_matched"]:
        fl_nfl_games(ctx, out)
    fl_sleeper_users_refresh(out, b, nid, rosters, followed, want)
    if games:
        fl_nfl_games(ctx, out)      # cached on out: free when already fetched

def fl_sleeper_last(out, b, nid, wk):
    """lg["last"] from matchups/{wk}: finals by points."""
    r = fl_get(b, FL_SLEEPER + "league/" + nid + "/matchups/" + str(wk), ttl = FL_TTL_LEAGUE)
    if r["status_code"] != 200 or type(r["json"]) != "list":
        return
    last = {"week": wk, "matchups": [], "scores": {}}
    pairs = {}
    any_pts = False
    for m in r["json"]:
        rid = fl_d(m, "roster_id", 0)
        p = fl_num(fl_d(m, "points", 0))
        if p != 0:
            any_pts = True
        last["scores"][rid] = {"pts": p}
        mid = fl_d(m, "matchup_id", None)
        if mid != None:
            pairs.setdefault(mid, []).append([rid, p])
    if not any_pts:
        return
    if out.get("format", "h2h") != "guillotine":
        for mid in sorted(pairs.keys()):
            pr = pairs[mid]
            if len(pr) != 2:
                continue
            last["matchups"].append(fl_final_row(pr[0][0], pr[1][0], pr[0][1], pr[1][1]))
    out["last"] = last

def fl_final_row(a, bb, ap, bp):
    return {"a": a, "b": bb, "a_pts": ap, "b_pts": bp, "a_proj": ap, "b_proj": bp,
            "a_win": 100 if ap > bp else (0 if ap < bp else 50), "a_left": 0, "b_left": 0,
            "final": True}

def fl_sleeper_proj(ctx, b, season, week):
    """pid -> projection row, from three position groups (each < 1 MB). All
    three or none: a partial set can't price a lineup, so if the three
    won't fit the request budget nothing is fetched (proj["_partial"])."""
    proj = {}
    if b["n"] + 3 > FL_MAX_CALLS:
        proj["_partial"] = True
        return proj
    groups = [["WR"], ["RB"], ["QB", "TE", "K", "DEF"]]
    for g in groups:
        # position[] repeats, so the query is written out rather than
        # passed as a params dict (a dict holds one value per key).
        q = "?season_type=regular&order_by=pts_ppr" + "".join(["&position[]=" + p for p in g])
        r = fl_get(b, FL_SLEEPER_API + "projections/nfl/" + str(season) + "/" + str(week) + q,
                   ttl = FL_TTL_PROJ)
        if r["status_code"] != 200 or type(r["json"]) != "list":
            proj["_partial"] = True
            continue
        for row in r["json"]:
            pid = str(fl_d(row, "player_id", ""))
            if pid != "":
                proj[pid] = row
    return proj

def fl_sleeper_game_today(rows, proj, today):
    for m in rows:
        for pid in fl_d(m, "starters", []):
            row = proj.get(str(pid), None)
            if row != None and str(fl_d(row, "date", "")) == today[0]:
                return True
    return False

def fl_sleeper_sched(b, season):
    """game_id -> 'pre_game' | 'in_game' | 'complete' (27 KB, whole season).
    Only fetched on a game day, when the budget has room."""
    if b["n"] >= FL_MAX_CALLS:
        return {}
    r = fl_get(b, FL_SLEEPER_API + "schedule/nfl/regular/" + str(season), ttl = FL_TTL_LIVE)
    out = {}
    if r["status_code"] == 200 and type(r["json"]) == "list":
        for g in r["json"]:
            out[str(fl_d(g, "game_id", ""))] = str(fl_d(g, "status", ""))
    return out

def fl_score(lg, stats):
    """Public: a Sleeper stat or projection line (row["stats"]) in THIS
    league's points - the league's scoring_settings when it has them, else
    Sleeper's pts_ppr / pts_half_ppr / pts_std for lg["scoring"]. Use it for
    every player value so all apps price players identically."""
    ss = fl_d(fl_d(lg, "raw", {}), "scoring", {})
    key = {"PPR": "pts_ppr", "HALF": "pts_half_ppr"}.get(lg.get("scoring", "PPR"), "pts_std")
    return fl_score_ss(ss, stats if type(stats) == "dict" else {}, key)

def fl_score_ss(ss, stats, pts_key = "pts_ppr"):
    """A stat line in this league's scoring: sum(scoring_settings[k] *
    stats[k]). Matches Sleeper's own starters_points exactly (15,341 week-2
    starter slots in 144 leagues: 6-pt pass TD, TE premium, first-down and
    yardage bonuses, DEF brackets, kicker distance all included)."""
    if len(ss) == 0:
        return fl_num(fl_d(stats, pts_key, 0))
    t = 0.0
    for k, v in stats.items():
        w = ss.get(k, None)
        if w != None and (type(v) == "int" or type(v) == "float"):
            t += w * v
    return t

def fl_row_pts(row, ss, pts_key):
    return fl_score_ss(ss, fl_d(row, "stats", {}), pts_key)

def fl_et_date(ctx):
    """Today's date in US Eastern (EDT, UTC-4 for the whole regular season
    bar its last weeks - an hour's slack either way doesn't move a game day)
    as 'YYYY-MM-DD', plus the Eastern hour."""
    u = ctx.now.unix - 4 * 3600
    days = u // 86400
    # civil_from_days (Howard Hinnant)
    z = days + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y += 1
    ds = str(y) + "-" + ("0" if m < 10 else "") + str(m) + "-" + ("0" if d < 10 else "") + str(d)
    return [ds, (u % 86400) // 3600]

def fl_nfl_week(ctx):
    """The NFL regular-season week from the calendar alone: week 1 opens the
    Wednesday after Labor Day (first Monday of September), and each week
    turns over on Wednesday. Clamped to 1..18."""
    y = fl_season(ctx)
    # weekday of Sep 1 (0 = Monday), Zeller-free: days since 1970-01-01 was a Thursday
    d0 = fl_days(y, 9, 1)
    wd = (d0 + 3) % 7
    labor = d0 + ((7 - wd) % 7)
    start = labor + 2
    today = (ctx.now.unix - 4 * 3600) // 86400
    wk = (today - start) // 7 + 1
    return 1 if wk < 1 else (18 if wk > 18 else wk)

# ESPN pro-team ids -> the Sleeper club codes the projection rows use
# (ESPN writes WSH; Sleeper WAS - the NFL logo sets are named WSH).
FL_ESPN_CLUB_FIX = {"WSH": "WAS"}
FL_TTL_GAMES = 21600
FL_DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

def fl_et_offset(unix):
    """-4 h (EDT) or -5 h (EST): EST from the first Sunday of November to
    the second Sunday of March, 2 am local."""
    d = (unix - 4 * 3600) // 86400
    y = fl_civil(d)[0]
    n1 = fl_days(y, 11, 1)
    nov = n1 + (6 - (n1 + 3) % 7) % 7          # first Sunday of November
    m1 = fl_days(y, 3, 1)
    mar = m1 + (6 - (m1 + 3) % 7) % 7 + 7      # second Sunday of March
    return -5 if (d >= nov or d < mar) else -4

def fl_civil(days):
    z = days + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]

def fl_nfl_games(ctx, lg, week = None):
    """This week's NFL slate by club (Sleeper codes, plus a WSH alias):
    club -> {opp, home (bool), kickoff_unix, day ("TNF", "SUN", "SNF",
    "MNF", "SAT", ...), done (stats official or 4 h past kickoff),
    bye False}; a club on bye -> {bye: True}. One keyless ESPN call
    (proTeamSchedules_wl, ~110 KB, ttl 6 h) counted in lg["budget"] and
    cached on lg, so asking twice is free. {} when it fails or no budget.
    Sleeper projection rows carry `opponent` but no venue - use this for
    VS / @ and the day."""
    wk = lg.get("week", 1) if week == None else week
    raw = lg.get("raw", None)
    if raw == None or type(raw) != "dict":
        raw = {}
        lg["raw"] = raw
    key = "games_" + str(wk)
    if key in raw:
        return raw[key]
    season = lg.get("season", 0)
    if season == 0:
        season = fl_season(ctx)
    b = lg.get("budget", None)
    if b == None:
        b = {"n": 0}
        lg["budget"] = b
    out = {}
    r = fl_get(b, FL_ESPN + str(season) + "?view=proTeamSchedules_wl", ttl = FL_TTL_GAMES)
    if r["status_code"] == 200 and type(r["json"]) == "dict":
        teams = fl_d(fl_d(r["json"], "settings", {}), "proTeams", [])
        code = {}
        for t in teams:
            ab = str(fl_d(t, "abbrev", ""))
            code[int(fl_num(fl_d(t, "id", -1), -1))] = FL_ESPN_CLUB_FIX.get(ab, ab)
        for t in teams:
            me = code.get(int(fl_num(fl_d(t, "id", -1), -1)), "")
            if me == "" or me == "FA":
                continue
            games = fl_d(fl_d(t, "proGamesByScoringPeriod", {}), str(wk), [])
            if len(games) == 0:
                out[me] = {"bye": True, "opp": "", "home": False, "kickoff_unix": 0, "day": "BYE", "done": False}
                continue
            g = games[0]
            home = code.get(int(fl_num(fl_d(g, "homeProTeamId", -1), -1)), "")
            away = code.get(int(fl_num(fl_d(g, "awayProTeamId", -1), -1)), "")
            ko = int(fl_num(fl_d(g, "date", 0), 0)) // 1000
            loc = ko + fl_et_offset(ko) * 3600
            wd = (loc // 86400 + 3) % 7
            day = FL_DAYS[wd]
            if day == "THU":
                day = "TNF"
            elif day == "MON":
                day = "MNF"
            elif day == "SUN" and (loc % 86400) // 3600 >= 19:
                day = "SNF"
            out[me] = {"bye": False, "opp": away if me == home else home, "home": me == home,
                       "kickoff_unix": ko, "day": day,
                       "done": fl_d(g, "statsOfficial", False) == True or ctx.now.unix > ko + 4 * 3600}
        if "WAS" in out:
            out["WSH"] = out["WAS"]
    raw[key] = out
    return out

def fl_days(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def fl_sleeper_side(m, proj, pts_key, ss, today, sched):
    """One roster's week: live points, expected final (actual for starters
    whose game is over, max(actual, projection) while it is on, the
    projection before it), the variance of what is still to come, and how
    many starters are still to play. A starter with no projection (IDP,
    bye, deep backup) or ruled out (FL_OUT) counts only what he has."""
    pts = fl_num(fl_d(m, "points", 0))
    starters = fl_d(m, "starters", [])
    spts = fl_d(m, "starters_points", [])
    exp = 0.0
    var = 0.0
    left = 0
    filled = 0
    for i in range(len(starters)):
        pid = str(starters[i])
        if pid == "0" or pid == "":
            continue                        # empty slot
        filled += 1
        act = fl_num(spts[i]) if i < len(spts) else 0.0
        row = proj.get(pid, None)
        if row == None:
            exp += act                      # no projection (IDP): take what is there
            continue
        pj = fl_row_pts(row, ss, pts_key)
        inj = str(fl_d(fl_d(row, "player", {}), "injury_status", "")).upper()
        if pj == 0 or inj in FL_OUT:
            exp += act                      # not expected to score
            continue
        gs = sched.get(str(fl_d(row, "game_id", "")), "")
        gd = str(fl_d(row, "date", ""))
        if gs == "complete" or (gs == "" and gd != "" and gd < today[0]):
            exp += act                      # game is over
        elif gs == "in_game" or (gs == "" and gd == today[0] and act != 0):
            exp += act if act > pj else pj  # in progress
            var += FL_VAR_LIVE
        else:
            exp += pj                       # still to play
            sd = FL_SD_A + FL_SD_B * pj
            var += sd * sd
            left += 1
    return {"id": fl_d(m, "roster_id", 0), "pts": pts, "exp": exp, "var": var, "left": left,
            "starters": filled}

def fl_sleeper_matchups(out, rows, proj, pts_key, ss, today, sched, elim):
    have_proj = len(proj) > 0 and not proj.get("_partial", False)
    pairs = {}
    for m in rows:
        sd = fl_sleeper_side(m, proj, pts_key, ss, today, sched)
        cut = elim.get(sd["id"], 0)
        out["scores"][sd["id"]] = {"pts": sd["pts"], "proj": sd["exp"] if have_proj else -1,
                                   "left": sd["left"] if have_proj else -1,
                                   "starters": 0 if cut > 0 else sd["starters"], "cut": cut}
        mid = fl_d(m, "matchup_id", None)
        if mid != None:
            pairs.setdefault(mid, []).append(sd)
    if out.get("format", "h2h") == "guillotine":
        return
    for mid in sorted(pairs.keys()):
        if len(pairs[mid]) != 2:
            continue
        a = pairs[mid][0]
        bb = pairs[mid][1]
        win = -1
        final = False
        if have_proj:
            sd = math.sqrt(a["var"] + bb["var"])
            if sd < 0.5:
                win = 100 if a["pts"] > bb["pts"] else (0 if a["pts"] < bb["pts"] else 50)
                final = a["left"] + bb["left"] == 0 and (a["pts"] > 0 or bb["pts"] > 0)
            else:
                win = int(fl_phi((a["exp"] - bb["exp"]) / sd) * 100 + 0.5)
        out["matchups"].append({"a": a["id"], "b": bb["id"], "a_pts": a["pts"], "b_pts": bb["pts"],
                                "a_proj": a["exp"] if have_proj else -1, "b_proj": bb["exp"] if have_proj else -1,
                                "a_win": win, "a_left": a["left"] if have_proj else -1,
                                "b_left": bb["left"] if have_proj else -1, "final": final})

# ------------------------------------------------------------------ ESPN
def fl_espn(ctx, inp, b):
    lid = inp["league"]
    season = fl_season(ctx)
    headers = dict(FL_HEADERS)
    if inp["espns2"] != "" and inp["swid"] != "":
        swid = inp["swid"]
        if not swid.startswith("{"):
            swid = "{" + swid + "}"
        headers["Cookie"] = "espn_s2=" + inp["espns2"] + "; SWID=" + swid
    r = fl_get(b, FL_ESPN + str(season) + "/segments/0/leagues/" + lid +
               "?view=mTeam&view=mMatchupScore&view=mSettings", headers = headers, ttl = FL_TTL_LIVE)
    sc = r["status_code"]
    if sc == 401 or sc == 403:
        if "Cookie" in headers:
            return fl_err("ESPN COOKIES REJECTED", "COPY ESPN S2 + SWID AGAIN")
        return fl_err("PRIVATE ESPN LEAGUE", "ADD ESPN COOKIES IN SETTINGS")
    if sc == 404:
        # ESPN IDs persist across seasons, but from March until the league
        # is renewed the new season answers 404. Last season's league
        # (any answer but 404) means the ID is right, just not renewed.
        rp = fl_get(b, FL_ESPN + str(season - 1) + "/segments/0/leagues/" + lid + "?view=mSettings",
                    headers = headers, ttl = FL_TTL_LEAGUE)
        if rp["status_code"] in [200, 401, 403]:
            if ctx.now.month >= 3 and ctx.now.month <= 8:
                return fl_err("LEAGUE NOT RENEWED", "CHECK BACK IN AUGUST")
            return fl_err("LEAGUE NOT RENEWED", "NO " + str(season) + " SEASON FOR THIS ID")
        return fl_err("LEAGUE NOT FOUND", "CHECK THE ESPN LEAGUE ID")
    if sc != 200 or type(r["json"]) != "dict":
        return fl_http_err(r, "ESPN")
    j = r["json"]
    stt = fl_d(j, "settings", {})
    sch = fl_d(stt, "scheduleSettings", {})
    week = int(fl_num(fl_d(fl_d(j, "status", {}), "currentMatchupPeriod", 1), 1))
    out = {"ok": True, "state": "live", "platform": "ESPN", "name": fl_clean(fl_d(stt, "name", "")),
           "season": season, "week": week, "scoring": fl_espn_scoring(stt), "budget": b,
           "format": "h2h", "scores": {}, "version": FL_VERSION, "played": False, "last": None,
           "reg_weeks": int(fl_num(fl_d(sch, "matchupPeriodCount", 14), 14)),
           "playoff_teams": int(fl_num(fl_d(sch, "playoffTeamCount", 0), 0)),
           "teams": [], "by_id": {}, "matchups": [], "me": None, "me_matched": False,
           "raw": {"league_id": lid, "season": season, "json": j, "cookie": headers}}
    if fl_d(fl_d(j, "draftDetail", {}), "drafted", True) == False:
        out["state"] = "predraft"
    members = {}
    for mb in fl_d(j, "members", []):
        members[str(fl_d(mb, "id", ""))] = mb
    teams = []
    for t in fl_d(j, "teams", []):
        name = fl_clean(fl_d(t, "name", ""))
        if name == "":
            name = fl_clean(str(fl_d(t, "location", "")) + " " + str(fl_d(t, "nickname", "")))
        owners = fl_d(t, "owners", [])
        mb = members.get(str(fl_d(t, "primaryOwner", owners[0] if len(owners) > 0 else "")), {})
        owner = fl_clean(fl_d(mb, "displayName", ""))
        full = fl_clean(str(fl_d(mb, "firstName", "")) + " " + str(fl_d(mb, "lastName", "")))
        if name == "":
            name = "TEAM " + str(fl_d(t, "id", ""))
        ab = fl_clean(fl_d(t, "abbrev", ""))
        tr = fl_team_rec(fl_d(t, "id", 0), name, ab if ab != "" else fl_abbrev(name), owner, full)
        o = fl_d(fl_d(t, "record", {}), "overall", {})
        tr["wins"] = int(fl_num(fl_d(o, "wins", 0)))
        tr["losses"] = int(fl_num(fl_d(o, "losses", 0)))
        tr["ties"] = int(fl_num(fl_d(o, "ties", 0)))
        tr["pf"] = fl_num(fl_d(o, "pointsFor", 0))
        tr["pa"] = fl_num(fl_d(o, "pointsAgainst", 0))
        tr["seed"] = int(fl_num(fl_d(t, "playoffSeed", 0)))
        n = int(fl_num(fl_d(o, "streakLength", 0)))
        typ = str(fl_d(o, "streakType", ""))
        tr["streak"] = (str(n) + ("W" if typ == "WIN" else ("L" if typ == "LOSS" else "T"))) if n > 0 else ""
        tr["waiver_budget_used"] = int(fl_num(fl_d(fl_d(t, "transactionCounter", {}), "acquisitionBudgetSpent", 0), 0))
        tr["waiver_position"] = int(fl_num(fl_d(t, "waiverRank", 0), 0))
        teams.append(tr)
    fl_finish_teams(out, teams, inp["team"])
    last = {"week": week - 1, "matchups": [], "scores": {}}
    for m in fl_d(j, "schedule", []):
        mp = int(fl_num(fl_d(m, "matchupPeriodId", 0)))
        h = fl_d(m, "home", {})
        a = fl_d(m, "away", None)
        if mp == week - 1:
            # Last week, free from the same response (lg["last"]).
            hp = fl_num(fl_d(h, "totalPoints", 0))
            last["scores"][fl_d(h, "teamId", 0)] = {"pts": hp}
            if a != None:
                ap = fl_num(fl_d(a, "totalPoints", 0))
                last["scores"][fl_d(a, "teamId", 0)] = {"pts": ap}
                row = fl_final_row(fl_d(h, "teamId", 0), fl_d(a, "teamId", 0), hp, ap)
                wn = str(fl_d(m, "winner", ""))
                row["a_win"] = 100 if wn == "HOME" else (0 if wn == "AWAY" else row["a_win"])
                last["matchups"].append(row)
            continue
        if mp != week:
            continue
        hp = fl_d(h, "totalPointsLive", fl_d(h, "totalPoints", 0))
        if fl_num(hp) != 0:
            out["played"] = True
        if a == None:
            # A bye in the fantasy schedule (odd team count): the team still
            # scores, it just has no opponent. fl_mine() returns None for it.
            out["scores"][fl_d(h, "teamId", 0)] = {"pts": fl_num(hp), "left": fl_espn_left(h),
                                                   "proj": fl_num(fl_d(h, "totalProjectedPointsLive", -1), -1)}
            continue
        ap = fl_d(a, "totalPointsLive", fl_d(a, "totalPoints", 0))
        if fl_num(ap) != 0:
            out["played"] = True
        hj = fl_d(h, "totalProjectedPointsLive", -1)
        aj = fl_d(a, "totalProjectedPointsLive", -1)
        wp = fl_d(h, "winProbability", None)
        final = str(fl_d(m, "winner", "UNDECIDED")) != "UNDECIDED"
        win = -1
        if final:
            win = 100 if str(fl_d(m, "winner", "")) == "HOME" else (0 if str(fl_d(m, "winner", "")) == "AWAY" else 50)
        elif wp != None:
            win = int(fl_num(wp) * 100 + 0.5)
        out["scores"][fl_d(h, "teamId", 0)] = {"pts": fl_num(hp), "proj": fl_num(hj, -1), "left": fl_espn_left(h)}
        out["scores"][fl_d(a, "teamId", 0)] = {"pts": fl_num(ap), "proj": fl_num(aj, -1), "left": fl_espn_left(a)}
        out["matchups"].append({"a": fl_d(h, "teamId", 0), "b": fl_d(a, "teamId", 0),
                                "a_pts": fl_num(hp), "b_pts": fl_num(ap),
                                "a_proj": fl_num(hj, -1), "b_proj": fl_num(aj, -1),
                                "a_win": win, "a_left": fl_espn_left(h), "b_left": fl_espn_left(a),
                                "final": final})
    if week > 1 and len(last["scores"]) > 0:
        out["last"] = last
    if out["state"] == "live" and len(out["matchups"]) == 0:
        out["state"] = "nomatch"
    return out

def fl_espn_scoring(stt):
    items = fl_d(fl_d(stt, "scoringSettings", {}), "scoringItems", [])
    for it in items:
        if int(fl_num(fl_d(it, "statId", -1))) == 53:      # 53 = reception
            p = fl_num(fl_d(it, "points", 0))
            return "PPR" if p >= 1 else ("HALF" if p >= 0.5 else "STD")
    return "STD"

def fl_espn_left(side):
    """Starters (lineup slot not bench 20 / IR 21) with no actual stat line
    for the period yet and a projection above zero = still to play (a
    starter on a bye or ruled out projects 0 and never plays)."""
    ro = fl_d(side, "rosterForCurrentScoringPeriod", None)
    if ro == None:
        return -1
    left = 0
    for e in fl_d(ro, "entries", []):
        if int(fl_num(fl_d(e, "lineupSlotId", 20))) in [20, 21]:
            continue
        played = False
        pj = 0.0
        for s in fl_d(fl_d(fl_d(e, "playerPoolEntry", {}), "player", {}), "stats", []):
            src = int(fl_num(fl_d(s, "statSourceId", 1)))
            if src == 0:
                played = True
            elif src == 1:
                pj = fl_num(fl_d(s, "appliedTotal", 0))
        if not played and pj != 0:
            left += 1
    return left

# ------------------------------------------------------------------ demo
# Blank league ID: a believable league so the panel (and the catalog
# thumbnail) shows what the app does. Always labelled DEMO on the panel.
FL_DEMO_TEAMS = [
    ["BLITZ BRIGADE", "COACH", 2, 0, 249.8, 214.6, "2W"],
    ["TD TSUNAMI", "RIVAL", 1, 1, 238.1, 205.9, "1W"],
    ["GRIDIRON GHOSTS", "MIA", 1, 1, 236.5, 231.0, "1L"],
    ["FOURTH AND LONG", "DEV", 1, 1, 221.4, 228.7, "1L"],
    ["THE WAIVER WIRE", "SAM", 1, 1, 229.0, 219.4, "1W"],
    ["PUNT GOD", "JO", 1, 1, 212.3, 220.8, "1W"],
    ["HAIL MARYS", "ALEX", 0, 2, 204.7, 233.5, "2L"],
    ["RED ZONE RAIDERS", "KAI", 0, 2, 198.2, 235.1, "2L"],
]
# Top-scoring starter so far, by team id (fl_top on the demo league).
FL_DEMO_TOP = {1: ["CHASE", 24.4], 2: ["MCCAFFREY", 21.7], 3: ["LAMB", 19.2], 4: ["ALLEN", 22.8],
               5: ["BIJAN", 26.1], 6: ["KELCE", 12.9], 7: ["HENRY", 17.5], 8: ["JEFFERSON", 18.3]}

def fl_demo(inp):
    teams = []
    for i in range(len(FL_DEMO_TEAMS)):
        d = FL_DEMO_TEAMS[i]
        t = fl_team_rec(i + 1, d[0], fl_abbrev(d[0]), d[1], "")
        t["wins"] = d[2]
        t["losses"] = d[3]
        t["pf"] = d[4]
        t["pa"] = d[5]
        t["streak"] = d[6]
        teams.append(t)
    out = {"ok": True, "state": "demo", "platform": "DEMO", "name": "DEMO LEAGUE", "season": 0,
           "week": 3, "scoring": "PPR", "budget": {"n": 0}, "teams": [], "by_id": {},
           "format": "h2h", "scores": {}, "version": FL_VERSION, "played": True,
           "reg_weeks": 14, "playoff_teams": 4,
           "matchups": [
               {"a": 1, "b": 2, "a_pts": 104.6, "b_pts": 97.2, "a_proj": 121.8, "b_proj": 113.5,
                "a_win": 68, "a_left": 3, "b_left": 4, "final": False},
               {"a": 3, "b": 4, "a_pts": 88.1, "b_pts": 91.4, "a_proj": 110.2, "b_proj": 104.9,
                "a_win": 61, "a_left": 4, "b_left": 2, "final": False},
               {"a": 5, "b": 6, "a_pts": 120.4, "b_pts": 76.0, "a_proj": 126.3, "b_proj": 99.8,
                "a_win": 94, "a_left": 1, "b_left": 4, "final": False},
               {"a": 7, "b": 8, "a_pts": 65.3, "b_pts": 71.9, "a_proj": 101.7, "b_proj": 108.4,
                "a_win": 35, "a_left": 5, "b_left": 4, "final": False},
           ],
           "last": {"week": 2, "scores": {}, "matchups": [
               fl_final_row(1, 3, 131.2, 118.7), fl_final_row(2, 4, 124.9, 109.3),
               fl_final_row(5, 7, 112.4, 98.6), fl_final_row(6, 8, 101.8, 96.2)]},
           "me": None, "me_matched": False, "raw": {}}
    for m in out["matchups"]:
        out["scores"][m["a"]] = {"pts": m["a_pts"], "proj": m["a_proj"], "left": m["a_left"]}
        out["scores"][m["b"]] = {"pts": m["b_pts"], "proj": m["b_proj"], "left": m["b_left"]}
    for m in out["last"]["matchups"]:
        out["last"]["scores"][m["a"]] = {"pts": m["a_pts"]}
        out["last"]["scores"][m["b"]] = {"pts": m["b_pts"]}
    fl_finish_teams(out, teams, inp["team"] if inp["team"] != "" else "BLITZ BRIGADE")
    return out

# --------------------------------------------------------------- finish
def fl_finish_teams(out, teams, want):
    fl_color_teams(teams)
    teams = fl_rank(teams)
    out["teams"] = teams
    for t in teams:
        out["by_id"][t["id"]] = t
    me = fl_match(teams, want)
    out["me_matched"] = me != None
    if me == None and len(teams) > 0:
        me = teams[0]["id"]
    out["me"] = me

def fl_load(ctx, projections = False, matchups = True, games = False):
    """games = True: the app draws the NFL slate (fl_nfl_games) - fetch it
    here, where it can go ahead of the optional users refresh (v2.1)."""
    inp = fl_inputs(ctx)
    if inp["raw"] == "":
        return fl_demo(inp)
    if inp["league"] == "":
        return fl_err("LEAGUE ID IS A NUMBER", "COPY IT FROM THE LEAGUE URL")
    b = {"n": 0}
    if inp["platform"] == "SLEEPER":
        return fl_sleeper(ctx, inp, b, projections, matchups, games)
    out = fl_espn(ctx, inp, b)
    if games and out["ok"]:
        fl_nfl_games(ctx, out)
    return out

def fl_et_now(ctx):
    """[ET date 'YYYY-MM-DD', ET hour] with the real EDT / EST offset."""
    loc = ctx.now.unix + fl_et_offset(ctx.now.unix) * 3600
    ymd = fl_civil(loc // 86400)
    ds = str(ymd[0]) + "-" + ("0" if ymd[1] < 10 else "") + str(ymd[1]) + "-" + ("0" if ymd[2] < 10 else "") + str(ymd[2])
    return [ds, (loc % 86400) // 3600]

def fl_lock_hour(date):
    """The ET hour a game on this date ('YYYY-MM-DD') is assumed to lock
    when no kickoff time is known: the day's earliest usual kickoff.
    Sunday / Saturday / Christmas 1 pm, Thanksgiving 12, Black Friday 3 pm,
    Monday 7 pm (doubleheaders), Thursday and the rest 8 pm."""
    parts = str(date).split("-")
    if len(parts) != 3:
        return 13
    y = int(fl_num(parts[0], 0))
    m = int(fl_num(parts[1], 0))
    d = int(fl_num(parts[2], 0))
    if y == 0 or m == 0 or d == 0:
        return 13
    day = FL_DAYS[(fl_days(y, m, d) + 3) % 7]
    if m == 12 and d == 25:
        return 13
    if day == "THU" and m == 11 and d >= 22 and d <= 28:
        return 12
    if day == "FRI" and m == 11 and d >= 23 and d <= 29:
        return 15
    return {"SUN": 13, "SAT": 13, "MON": 19}.get(day, 20)

def fl_locked(ctx, lg, club, date = ""):
    """True once this NFL club's game this week has kicked off (a Sleeper
    lineup locks player by player at kickoff). Uses the real kickoff when
    fl_nfl_games is already on lg (never fetches it); else the game date
    (the Sleeper projection row's "date", ET) against fl_lock_hour - so a
    Sunday 1 pm game locks at 1 pm, not at the end of the day. A bye or an
    unknown club with no date is never locked."""
    g = fl_d(fl_d(lg, "raw", {}), "games_" + str(lg.get("week", 1)), {})
    t = fl_d(g, str(club).upper(), None)
    if t != None:
        if fl_d(t, "bye", False):
            return False
        ko = int(fl_num(fl_d(t, "kickoff_unix", 0), 0))
        if ko > 0:
            return ctx.now.unix >= ko
    if str(date) == "":
        return False
    now = fl_et_now(ctx)
    if str(date) < now[0]:
        return True
    return str(date) == now[0] and now[1] >= fl_lock_hour(date)

def fl_team(lg, id):
    return lg["by_id"].get(id, None)

def fl_mine(lg):
    """[matchup, side] for your team this week; side "a" or "b"."""
    for m in lg["matchups"]:
        if m["a"] == lg["me"]:
            return [m, "a"]
        if m["b"] == lg["me"]:
            return [m, "b"]
    return [None, ""]

def fl_mine_last(lg):
    """[matchup, side] for your team last week (lg["last"]), or [None, ""]."""
    last = lg.get("last", None)
    if last == None:
        return [None, ""]
    for m in last["matchups"]:
        if m["a"] == lg["me"]:
            return [m, "a"]
        if m["b"] == lg["me"]:
            return [m, "b"]
    return [None, ""]

def fl_proj_pts(lg, pid):
    """A Sleeper player's projection this week in the league's own scoring,
    or -1 when there is no projection row (ESPN, IDP, not fetched)."""
    raw = lg.get("raw", {})
    row = fl_d(fl_d(raw, "proj", {}), str(pid), None)
    if row == None:
        return -1
    return fl_score(lg, fl_d(row, "stats", {}))

def fl_top(lg, id):
    """[LAST NAME, points] of a team's best starter so far this week, or
    None (ESPN: no player names in the one-call response; nobody scored)."""
    if lg["platform"] == "DEMO":
        return FL_DEMO_TOP.get(id, None)
    if lg["platform"] != "SLEEPER":
        return None
    proj = fl_d(lg["raw"], "proj", {})
    for m in fl_d(lg["raw"], "matchups", []):
        if fl_d(m, "roster_id", None) != id:
            continue
        starters = fl_d(m, "starters", [])
        spts = fl_d(m, "starters_points", [])
        best = None
        for i in range(len(starters)):
            p = fl_num(spts[i]) if i < len(spts) else 0.0
            if p <= 0 or (best != None and p <= best[1]):
                continue
            pl = fl_d(proj.get(str(starters[i]), {}), "player", {})
            nm = fl_clean(fl_d(pl, "last_name", ""))
            if fl_d(pl, "position", "") == "DEF":
                nm = fl_clean(fl_d(pl, "team", str(starters[i]))) + " D"
            if nm == "":
                continue
            best = [nm, p]
        return best
    return None

# ------------------------------------------------------------ team badge
# Fantasy teams have no logos, so every team gets a pixel shield: its own
# colour, a dark field tinted with it, and its two-letter monogram. Colours
# are dealt by team id with a stride of 5 through 12 LED-bright hues, so no
# two teams in a league of 12 or fewer share one, and a team keeps its
# colour in every league app (ids never change). v2: the 12th hue is a
# saturated gold instead of light grey (grey read as "disabled" on LED).
FL_BADGE_COLORS = ["#FF4D4D", "#FF9A1F", "#FFD23F", "#9BE34A", "#2FD67A", "#2DD4C8",
                   "#2DB8FF", "#5C7DFF", "#A77CFF", "#FF5CD6", "#FF8FB0", "#C8A24A"]

def fl_color_teams(teams):
    ids = sorted([t["id"] for t in teams])
    for t in teams:
        i = ids.index(t["id"])
        t["color"] = FL_BADGE_COLORS[(i * 5) % len(FL_BADGE_COLORS)]

def fl_badge_color(team):
    return team.get("color", "#C8A24A")

def fl_monogram(team):
    words = [fl_norm(w) for w in fl_clean(team["name"]).split(" ")]
    words = [w for w in words if w != "" and w not in ["THE", "A", "OF"]] or [fl_norm(team["name"]) or "FT"]
    if len(words) >= 2:
        return words[0][:1] + words[1][:1]
    return words[0][:2]

def fl_badge(c, team, x, y, size = 24):
    """A heater shield, size 24 (22 x 24) or 16 (16 x 16), top-left at x, y:
    a 1 px rim in the team colour with the top corners knocked off, a dark
    field tinted with the colour, a chief band across the top (24 only) and
    the monogram in white."""
    col = fl_badge_color(team)
    field = color.dim(col, 20)
    w = 22 if size >= 24 else 16
    h = size
    straight = h * 5 // 9          # rows before the sides start to taper
    for r in range(h):
        inset = 0
        if r >= straight:
            inset = ((r - straight + 1) * (w // 2)) // (h - straight + 1)
        x0 = x + inset
        x1 = x + w - 1 - inset
        if x1 < x0:
            continue
        if r == 0:
            c.rect(x0 + 1, y, x1 - 1, y, fill = col)   # rounded shoulders
            continue
        c.rect(x0, y + r, x1, y + r, fill = col)
        if r < h - 2 and x1 - x0 >= 2:
            c.rect(x0 + 1, y + r, x1 - 1, y + r, fill = field)
    mono = fl_monogram(team)
    if size >= 24:
        c.rect(x + 3, y + 2, x + w - 4, y + 3, fill = col)
        f = "5x7" if c.text_width(mono, "5x7") <= w - 6 else "4x5"
        c.text(mono, x + w // 2, y + 7, font = f, color = "white", align = "center")
    else:
        c.text(mono, x + w // 2, y + 4, font = "4x5", color = "white", align = "center")
# ---- END fantasy_league.star v2 ----

# ======================================================================
# DROP & ADD
#
# DESIGN. A waiver-wire transaction slip in two pages.
#
#   move   the hero: your single best move. The player to drop sits on the
#          left in red under his NFL club logo, the player to add on the
#          right in green. Between them the gain is the headline ("+6.3" in
#          10x16 green over PTS/WK), and under it the one memorable thing:
#          a fat pixel swap arrow, red tail and green head, with the
#          position (or FLEX) stamped into its shaft. Names run along the
#          bottom as initial + last name (M.WASHINGTON). Under the add: how
#          many leagues roster him (ESPN "88% OWN", amber from 50% up: a
#          player you have to move on) or, on Sleeper, WIRE / WAIVERS. The
#          ADD label turns into an amber CLAIM when ESPN has him on waivers.
#          With no move worth 2+ PTS/WK: a green padlock "ROSTER IS TIGHT"
#          card quoting the best gain on offer.
#   next   NEXT MOVES: moves 2 and 3 as two 16 px rows - a position pill in
#          fantasy position colours (QB pink, RB teal, WR blue, TE orange,
#          FLEX violet), a pixel jersey in each player's club colours, a
#          mini swap arrow, the gain in green. With one move left over the
#          second row is an "ALSO SET" strip of ticked position pills; with
#          none, the page is a QB / RB / WR / TE line-up card: each spot
#          ticked SET (or SWAP when page 1 moves it) with the best gain the
#          wire offers there. The two pages never show the same card.
#
# VALUE. Rest-of-season points per week, a weighted average of what we
# know:
#   ESPN     (PPG x GP + ESPN's per-game season projection x 4 + this
#            week's projection) / (GP + 5). The season projection (stat
#            line source 1, split 2 - ESPN's in-season re-projection - else
#            split 0, the preseason one) damps a 2-game streak.
#   Sleeper  (PPG x GP + this week's projection x 4) / (GP + 4). Sleeper
#            has no season projection under the 1 MB cap (2.8 MB).
# Missing parts drop out of the average (a bye = no week projection).
#
# ROSTER RULES.
# - Never dropped: IR / reserve / taxi slots; anyone OUT, DOUBTFUL, on IR,
#   PUP, suspended or NA; a healthy player with no projection this week
#   (a bye) unless he has 3+ games of PPG (2+ when there are no
#   projections at all).
# - Zero evidence: after week 1 a healthy player with no games and no
#   projection is worth 0.0 and is the first drop.
# - Never added: OUT / DOUBTFUL / IR / PUP / suspended free agents, and one
#   with a single game and no projection.
# - When the drop has a projection this week the add must out-project him
#   too (two quiet games never get a star cut).
# - Same-position swaps (QB for QB) plus one FLEX swap: your weakest BENCH
#   RB / WR / TE for the best RB / WR / TE on the wire. No player twice.
#
# DATA (8-request budget). QB / RB / WR / TE only: kickers and defences
# are weekly streams (see the streamers app).
#   ESPN    adapter (1) + mRoster&forTeamId (1, ~220 KB) + one
#           kona_player_info per rostered position (4) with an
#           X-Fantasy-Filter: free agents + waivers at the slot, top 20 by
#           % owned, stats cut to the season lines and this week (~170 KB
#           each) = 6. ESPN's own appliedTotal / appliedAverage = league
#           scoring.
#   Sleeper fl_load(matchups = False): 3 (5 when an old-season ID is
#           followed) + season stats in three position groups (WR 840 KB
#           in week 3 and 923 KB for the whole 2025 season - at the 1 MB
#           cap, so a broken WR body is an error card, never a silent gap;
#           RB+QB; TE) + the v1 week projection for everyone (~610 KB)
#           = 7; the waiver settings (WAIVERS / WIRE tag) come with the
#           adapter (v2.1 lg["raw"]["settings"], no call). A followed ID
#           has room for the stats only: SEASON PPG. Week 1 uses the
#           adapter's projection feeds. Points: fl_score (league scoring).
#
# Adapter (v2) reads: fl_load(matchups = False), lg ok/err/state/platform/
# format/week/season/scoring/me/me_matched/followed/budget, lg["raw"]
# (Sleeper league_id + rosters + scoring, ESPN json + cookie + league_id +
# season), fl_get, fl_sleeper_proj, fl_score, fl_d, fl_num, fl_clean,
# fl_fmt1, FL_* URLs / TTLs.
# ======================================================================

INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
AMBER = "#FFBF00"
ALARM = "#FF3B30"
DROP_DARK = "#4A0E0B"
ADD_DARK = "#0B4A20"

L = 6
R = 185
LOGO_W = 24
LOGO_H = 18
MIN_GAIN = 2.0
# Skill positions only: kickers and defences are weekly streams (see the
# streamers app) and their week-to-week noise would crowd out real moves.
POSITIONS = ["QB", "RB", "WR", "TE"]
POS_SET = {"QB": True, "RB": True, "WR": True, "TE": True}
FLEX_POS = {"RB": True, "WR": True, "TE": True}

# Fantasy position colours (the vernacular of every draft board).
POS_COLOR = {"QB": "#FF4F86", "RB": "#1FD6C0", "WR": "#58A7FF", "TE": "#FFAE58", "FLEX": "#B98CFF"}

# The 24 x 18 NFL list set (never scaled at draw time).
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LAC": "LAC.png", "LAR": "LAR.png", "LV": "LV.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SEA": "SEA.png",
    "SF": "SF.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
}

# Club [trim, jersey] for the pixel jerseys - navy and black lifted so
# they read on an LED.
CLUB = {
    "ARI": ["#F0F2F5", "#E0304F"], "ATL": ["#F0F2F5", "#E8243C"], "BAL": ["#D0A52E", "#7B5CE8"],
    "BUF": ["#E8203A", "#2A6BFF"], "CAR": ["#B8BEC4", "#19A6F0"], "CHI": ["#FF5A1F", "#3F63C0"],
    "CIN": ["#F0F2F5", "#FF6A1F"], "CLE": ["#FF4E10", "#9A6433"], "DAL": ["#B0B7BC", "#3D7BFF"],
    "DEN": ["#3A6AB0", "#FF5A14"], "DET": ["#B0B7BC", "#1C9BE8"], "GB": ["#FFB612", "#2E8B57"],
    "HOU": ["#E8233C", "#3A5A8C"], "IND": ["#F0F2F5", "#3D86E8"], "JAX": ["#D7A22A", "#00A5B8"],
    "KC": ["#FFB612", "#FF2447"], "LV": ["#C4CACD", "#8A9196"], "LAC": ["#FFC20E", "#2AA8F0"],
    "LAR": ["#FFD100", "#2F6BFF"], "MIA": ["#FC6A12", "#00C2CC"], "MIN": ["#FFC62F", "#8F5BE8"],
    "NE": ["#E8203F", "#3A5A9C"], "NO": ["#D3BC8D", "#8A8580"], "NYG": ["#E8203F", "#2A5FE0"],
    "NYJ": ["#F0F2F5", "#1FA36E"], "PHI": ["#B0B7BC", "#0FA0A8"], "PIT": ["#FFB612", "#8A8580"],
    "SF": ["#D4B46A", "#E8201F"], "SEA": ["#69BE28", "#3A5A9C"], "TB": ["#8A8580", "#F0263A"],
    "TEN": ["#F0F2F5", "#4B92DB"], "WSH": ["#FFB612", "#B8323A"],
}

# Sleeper spellings that differ from the logo set.
TEAM_FIX = {"WAS": "WSH", "JAC": "JAX", "LA": "LAR", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# ESPN proTeamId -> abbreviation (0 = no NFL team).
ESPN_TEAM = {1: "ATL", 2: "BUF", 3: "CHI", 4: "CIN", 5: "CLE", 6: "DAL", 7: "DEN", 8: "DET", 9: "GB",
             10: "TEN", 11: "IND", 12: "KC", 13: "LV", 14: "LAR", 15: "MIA", 16: "MIN", 17: "NE",
             18: "NO", 19: "NYG", 20: "NYJ", 21: "PHI", 22: "ARI", 23: "PIT", 24: "LAC", 25: "SF",
             26: "SEA", 27: "TB", 28: "WSH", 29: "CAR", 30: "JAX", 33: "BAL", 34: "HOU"}

# ESPN defaultPositionId -> position, and position -> lineup slot id.
ESPN_POS = {1: "QB", 2: "RB", 3: "WR", 4: "TE", 5: "K", 16: "DEF"}
ESPN_SLOT = {"QB": 0, "RB": 2, "WR": 4, "TE": 6, "K": 17, "DEF": 16}
ESPN_BENCH = 20
ESPN_IR = 21

# Injury tags (both platforms' spellings). NO_ADD: never suggested as an
# add. HURT: never suggested as a drop either - a hurt starter is a hold.
NO_ADD = ["OUT", "IR", "INJURY_RESERVE", "PUP", "SUS", "SUSPENSION", "NA", "DNR", "DOUBTFUL"]
HURT = NO_ADD

# Name suffixes dropped on the panel to save width.
SUFFIX = ["JR", "JR.", "SR", "SR.", "II", "III", "IV", "V"]

# 9 x 10 padlock with a check: the roster is locked in.
LOCK = """
..SSSSS..
.S.....S.
.S.....S.
GGGGGGGGG
GGGGGGGWG
GGGGGGWGG
GWGGGWGGG
GGWGWGGGG
GGGWGGGGG
GGGGGGGGG
"""
LOCK_LEG = {"S": "#AEB8C6", "G": "#1FA04F", "W": "#FFFFFF"}

BALL = """
..DDDDD..
.DBBWBBD.
DBWWWWWBD
.DBBWBBD.
..DDDDD..
"""
BALL_LEG = {"D": "#6B3410", "B": "#B5652B", "W": "#FFFFFF"}

# 11 x 11 football jersey: J body, T trim (shoulder stripes + hem), K the
# V-neck. Drawn in each player's club colours.
JERSEY = """
.JJJ...JJJ.
JJJJJ.JJJJJ
JJJJJJJJJJJ
TTJJJJJJJTT
JJJJJJJJJJJ
JJ.JJJJJ.JJ
...JJJJJ...
...JJJJJ...
...JJJJJ...
...TTTTT...
...JJJJJ...
"""

# 7 x 6 tick.
CHECK = """
......G
.....GG
G...GG.
GG.GG..
.GGG...
..G....
"""
CHECK_LEG = {"G": "#2FE06F"}

# Demo moves (blank league ID): believable mid-season moves on real 2026
# clubs, labelled DEMO. [pos, drop, add]; player = [first, last, club, value,
# % owned, on waivers].
DEMO_SWAPS = [
    ["WR", ["KEON", "COLEMAN", "BUF", 7.1, 58, False], ["MALIK", "WASHINGTON", "MIA", 13.4, 41, False]],
    ["RB", ["AMEER", "ABDULLAH", "JAX", 4.3, 9, False], ["RICO", "DOWDLE", "PIT", 9.1, 63, True]],
    ["TE", ["TOMMY", "TREMBLE", "CAR", 4.6, 4, False], ["ELI", "RARIDON", "NE", 7.3, 12, False]],
]

# ------------------------------------------------------------ helpers
def team_abbr(t):
    t = str(t if t != None else "").upper()
    return TEAM_FIX.get(t, t)

def last_name(first, last):
    """Last name without a Jr./III suffix."""
    words = [w for w in fl_clean(last).split(" ") if w != "" and w not in SUFFIX]
    out = " ".join(words)
    if out == "":
        out = fl_clean(first)
    return out

def value(ppg, gp, pj, anchor):
    """Rest-of-season points per week (see VALUE in the header). -1 = no
    way to value him."""
    num = 0.0
    den = 0.0
    if gp >= 1:
        num += ppg * gp
        den += gp
    if anchor > 0:
        num += anchor * 4.0
        den += 4.0
    if pj > 0:
        w = 1.0 if anchor > 0 else 4.0
        num += pj * w
        den += w
    if den > 0:
        return num / den
    return -1.0

def player(pid, first, last, pos, team, ppg, gp, pj, inj, waiver, anchor = 0.0, own = -1.0, bench = True):
    first = fl_clean(first)
    return {"id": pid, "first": first, "name": last_name(first, last), "pos": pos,
            "team": team, "ppg": ppg, "gp": gp, "pj": pj, "anchor": anchor,
            "inj": str(inj if inj != None else "").upper().replace(" ", "_"),
            "waiver": waiver, "own": own, "bench": bench, "val": value(ppg, gp, pj, anchor)}

def zero_evidence(pool, week):
    """After week 1 a healthy rostered player with no games and no
    projection is worth nothing to you: value 0.0, the first drop."""
    if week < 2:
        return
    for p in pool:
        if p["gp"] == 0 and p["pj"] <= 0 and p["inj"] not in HURT:
            p["val"] = 0.0
            p["zero"] = True

def addable(p):
    if p["val"] <= 0 or p["team"] == "" or p["inj"] in NO_ADD:
        return False
    # one game and no projection is a fluke waiting to happen
    return p["pj"] > 0 or p["gp"] >= 2

def droppable(p, min_gp):
    """Never a hurt player (a hurt starter is a hold). A healthy one with no
    projection this week (a bye) needs min_gp games of PPG, unless he has
    no evidence at all (zero_evidence)."""
    if p["inj"] in HURT or p["val"] < 0:
        return False
    if p.get("zero", False) or p["pj"] > 0:
        return True
    return p["gp"] >= min_gp

def beats(add, drop):
    """The add must be worth more over the season AND, when the player you
    drop has a projection this week, out-project him too - so two quiet
    games from a star who is projected to bounce back never get him cut."""
    if add["val"] <= drop["val"]:
        return False
    return drop["pj"] <= 0 or add["pj"] > drop["pj"]

def first_beater(d, fas):
    for a in fas:
        if beats(a, d):
            return a
    return None

def pick_swaps(mine, fas, min_gp):
    """For your three weakest at each position, the best free agent at the
    same position who beats him; plus FLEX: your three weakest bench RB /
    WR / TE against the best RB / WR / TE. Biggest gain first, no player
    used twice. Returns [swaps worth MIN_GAIN+ (max 3), best gain seen,
    best gain per position]."""
    cands = []
    slot_best = {}
    for pos in POSITIONS:
        slot_best[pos] = -1.0
        m = sorted([p for p in mine if p["pos"] == pos and droppable(p, min_gp)], key = lambda p: p["val"])
        f = sorted([p for p in fas if p["pos"] == pos and addable(p)], key = lambda p: -p["val"])
        for d in m[:3]:
            a = first_beater(d, f)
            if a != None:
                cands.append({"pos": pos, "drop": d, "add": a, "gain": a["val"] - d["val"]})
    bench = sorted([p for p in mine if FLEX_POS.get(p["pos"], False) and p["bench"] and droppable(p, min_gp)],
                   key = lambda p: p["val"])
    fflex = sorted([p for p in fas if FLEX_POS.get(p["pos"], False) and addable(p)], key = lambda p: -p["val"])
    for d in bench[:3]:
        a = first_beater(d, fflex)
        if a != None and a["pos"] != d["pos"]:
            cands.append({"pos": "FLEX", "drop": d, "add": a, "gain": a["val"] - d["val"]})
    cands = sorted(cands, key = lambda s: -s["gain"])
    out = []
    used = {}
    for s in cands:
        if s["drop"]["id"] in used or s["add"]["id"] in used:
            continue
        used[s["drop"]["id"]] = True
        used[s["add"]["id"]] = True
        out.append(s)
        # best gain per position among moves that survive (the line-up card)
        if s["pos"] in slot_best and s["gain"] > slot_best[s["pos"]]:
            slot_best[s["pos"]] = s["gain"]
    best = out[0]["gain"] if len(out) > 0 else -1.0
    return [[s for s in out if s["gain"] >= MIN_GAIN][:3], best, slot_best]

def metric_label(has_ppg, has_pj):
    if has_ppg and has_pj:
        return "PPG+PROJ"
    return "SEASON PPG" if has_ppg else "WEEK PROJ"

def pool_out(mine, fas, has_ppg, has_pj, tag):
    return {"mine": mine, "fa": fas, "metric": metric_label(has_ppg, has_pj), "has_pj": has_pj, "tag": tag}

# ------------------------------------------------------------ Sleeper
# Fantasy points for one Sleeper stat line (season stats or a projection)
# come from the adapter's fl_score: the league's exact scoring_settings
# (6-point passing TDs, TE premium, yardage bonuses), else Sleeper's PPR /
# half / standard total.
SLEEPER_GROUPS = [["WR"], ["RB", "QB"], ["TE"]]

def sleeper_tag(lg):
    """WAIVERS when the league has no daily waivers (every add is a claim),
    else WIRE (a player just dropped still sits on waivers for days). The
    league's settings come with the adapter (v2.1 lg["raw"]["settings"],
    no request - a followed old-season ID gets them too)."""
    st = lg["raw"].get("settings", {})
    if int(fl_num(fl_d(st, "daily_waivers", 1), 1)) == 0:
        return "WAIVERS"
    return "WIRE"

def sleeper_pool(ctx, lg):
    b = lg["budget"]
    raw = lg["raw"]
    mine_ro = None
    rostered = {}
    for ro in raw["rosters"]:
        for k in ["players", "reserve", "taxi"]:
            for pid in fl_d(ro, k, []) or []:
                rostered[str(pid)] = True
        if fl_d(ro, "roster_id", None) == lg["me"]:
            mine_ro = ro
    if mine_ro == None:
        return pool_out([], [], False, False, "")
    hold = {}
    for k in ["reserve", "taxi"]:
        for pid in fl_d(mine_ro, k, []) or []:
            hold[str(pid)] = True
    starters = {}
    for pid in fl_d(mine_ro, "starters", []) or []:
        starters[str(pid)] = True
    my_ids = {}
    for pid in fl_d(mine_ro, "players", []) or []:
        if str(pid) not in hold:
            my_ids[str(pid)] = True
    if len(my_ids) == 0:
        return pool_out([], [], False, False, "")

    rows = []
    projd = {}
    has_ppg = False
    has_pj = False
    week = lg["week"]
    tag = "WIRE"
    if week <= 1:
        tag = sleeper_tag(lg)
        pr = fl_sleeper_proj(ctx, b, lg["season"], week)
        if pr.get("_partial", False):
            return {"err": ["SLEEPER FEED BUSY", "NEXT TRY IN 15 MIN"]}
        for k in pr:
            rows.append(pr[k])
        has_pj = len(rows) > 0
    else:
        # Season stats (names, teams, PPG) come first, in three groups. The
        # WR group sits near the 1 MB cap (840 KB in week 3, 923 KB for all
        # of 2025): a truncated body parses to nothing, and a silently
        # missing position would make the whole slip wrong - so any group
        # that fails is an error card naming it.
        for g in SLEEPER_GROUPS:
            q = "?season_type=regular&order_by=pts_ppr" + "".join(["&position[]=" + p for p in g])
            r = fl_get(b, FL_SLEEPER_API + "stats/nfl/" + str(lg["season"]) + q, ttl = FL_TTL_PROJ)
            if r["status_code"] != 200 or type(r["json"]) != "list":
                return {"err": ["SLEEPER " + "/".join(g) + " FEED BUSY", "NEXT TRY IN 15 MIN"]}
            rows.extend(r["json"])
        has_ppg = len(rows) > 0
        tag = sleeper_tag(lg)
        rp = fl_get(b, FL_SLEEPER + "projections/nfl/regular/" + str(lg["season"]) + "/" + str(week), ttl = FL_TTL_PROJ)
        if rp["status_code"] == 200 and type(rp["json"]) == "dict":
            projd = rp["json"]
            has_pj = True
    if len(rows) == 0:
        return {"err": ["SLEEPER STATS BUSY", "NEXT TRY IN 15 MIN"]}

    mine = []
    fas = []
    for row in rows:
        pid = str(fl_d(row, "player_id", ""))
        pl = fl_d(row, "player", {})
        pos = str(fl_d(pl, "position", "")).upper()
        if pid == "" or pos not in POS_SET:
            continue
        is_mine = pid in my_ids
        if not is_mine and pid in rostered:
            continue
        st = fl_d(row, "stats", {})
        if week <= 1:
            ppg = 0.0
            gp = 0
            pj = fl_score(lg, st)
        else:
            gp = int(fl_num(fl_d(st, "gp", 0)))
            ppg = fl_score(lg, st) / (gp * 1.0) if gp > 0 else 0.0
            pr = projd.get(pid, None)
            pj = 0.0
            if type(pr) == "dict" and fl_num(fl_d(pr, "gp", 0)) > 0:
                pj = fl_score(lg, pr)
        p = player(pid, fl_d(pl, "first_name", ""), fl_d(pl, "last_name", ""), pos,
                   team_abbr(fl_d(row, "team", fl_d(pl, "team", ""))), ppg, gp, pj,
                   fl_d(pl, "injury_status", ""), False, 0.0, -1.0, pid not in starters)
        if is_mine:
            mine.append(p)
        else:
            fas.append(p)
    zero_evidence(mine, week)
    return pool_out(mine, fas, has_ppg, has_pj, tag)

# ------------------------------------------------------------ ESPN
def espn_stats(pl, season, period):
    """[ppg, games, this week's projection, season projection per game]."""
    ppg = 0.0
    gp = 0
    pj = 0.0
    a0 = 0.0
    a2 = 0.0
    for s in fl_d(pl, "stats", []):
        if int(fl_num(fl_d(s, "seasonId", 0))) != season:
            continue
        src = int(fl_num(fl_d(s, "statSourceId", -1)))
        split = int(fl_num(fl_d(s, "statSplitTypeId", -1)))
        if src == 0 and split == 0:
            tot = fl_num(fl_d(s, "appliedTotal", 0))
            avg = fl_num(fl_d(s, "appliedAverage", 0))
            if avg > 0:
                gp = int(tot / avg + 0.5)
                ppg = avg
        elif src == 1 and split == 1 and int(fl_num(fl_d(s, "scoringPeriodId", -1))) == period:
            pj = fl_num(fl_d(s, "appliedTotal", 0))
        elif src == 1 and split == 0:
            a0 = fl_num(fl_d(s, "appliedAverage", 0))
        elif src == 1 and split == 2:
            a2 = fl_num(fl_d(s, "appliedAverage", 0))
    return [ppg, gp, pj, a2 if a2 > 0 else a0]

def espn_player(pe, season, period, waiver, bench):
    pl = fl_d(pe, "player", {})
    pos = ESPN_POS.get(int(fl_num(fl_d(pl, "defaultPositionId", 0))), "")
    if pos == "":
        return None
    v = espn_stats(pl, season, period)
    own = fl_num(fl_d(fl_d(pl, "ownership", {}), "percentOwned", -1), -1)
    return player(str(fl_d(pl, "id", fl_d(pe, "id", ""))), fl_d(pl, "firstName", ""), fl_d(pl, "lastName", ""),
                  pos, ESPN_TEAM.get(int(fl_num(fl_d(pl, "proTeamId", 0))), ""), v[0], v[1], v[2],
                  fl_d(pl, "injuryStatus", ""), waiver, v[3], own, bench)

def espn_pool(ctx, lg):
    b = lg["budget"]
    raw = lg["raw"]
    j = raw["json"]
    season = raw["season"]
    period = int(fl_num(fl_d(j, "scoringPeriodId", lg["week"]), lg["week"]))
    base = FL_ESPN + str(season) + "/segments/0/leagues/" + str(raw["league_id"])
    r = fl_get(b, base + "?view=mRoster&forTeamId=" + str(lg["me"]) + "&scoringPeriodId=" + str(period),
               headers = raw["cookie"], ttl = FL_TTL_ROSTERS)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"err": ["ESPN ROSTER BUSY", "NEXT TRY IN 15 MIN"]}
    mine = []
    for t in fl_d(r["json"], "teams", []):
        if fl_d(t, "id", None) != lg["me"]:
            continue
        for e in fl_d(fl_d(t, "roster", {}), "entries", []):
            slot = int(fl_num(fl_d(e, "lineupSlotId", ESPN_BENCH)))
            if slot == ESPN_IR:
                continue                     # IR slot: never dropped
            p = espn_player(fl_d(e, "playerPoolEntry", {}), season, period, False, slot == ESPN_BENCH)
            if p != None:
                mine.append(p)
    if len(mine) == 0:
        return pool_out([], [], False, False, "")
    held = {}
    for p in mine:
        held[p["pos"]] = True
    fas = []
    for pos in POSITIONS:
        slot = ESPN_SLOT[pos]
        # only positions you roster (a league with no TE slot still lets
        # you hold one for FLEX; one without that position has none of yours)
        if not held.get(pos, False):
            continue
        h = dict(raw["cookie"])
        h["X-Fantasy-Filter"] = ('{"players":{"filterStatus":{"value":["FREEAGENT","WAIVERS"]},' +
                                 '"filterSlotIds":{"value":[' + str(slot) + ']},' +
                                 '"filterStatsForExternalIds":{"value":[' + str(season) + "," + str(season) + str(period) + ']},' +
                                 '"sortPercOwned":{"sortPriority":1,"sortAsc":false},"limit":20}}')
        rf = fl_get(b, base + "?view=kona_player_info&scoringPeriodId=" + str(period), headers = h,
                    ttl = FL_TTL_ROSTERS)
        if rf["status_code"] != 200 or type(rf["json"]) != "dict":
            continue
        for pe in fl_d(rf["json"], "players", []):
            stt = str(fl_d(pe, "status", ""))
            if stt not in ["FREEAGENT", "WAIVERS"]:
                continue
            p = espn_player(pe, season, period, stt == "WAIVERS", True)
            if p != None and p["pos"] == pos:
                fas.append(p)
    has_ppg = False
    has_pj = False
    for p in mine + fas:
        if p["gp"] > 0:
            has_ppg = True
        if p["pj"] > 0 or p["anchor"] > 0:
            has_pj = True
    zero_evidence(mine, lg["week"])
    return pool_out(mine, fas, has_ppg, has_pj, "")

# ------------------------------------------------------------ model
def demo_player(pos, d):
    return {"id": d[1], "first": d[0], "name": d[1], "pos": pos, "team": d[2], "val": d[3],
            "own": d[4], "waiver": d[5]}

def demo_pool():
    swaps = []
    for d in DEMO_SWAPS:
        dr = demo_player(d[0], d[1])
        ad = demo_player(d[0], d[2])
        swaps.append({"pos": d[0], "drop": dr, "add": ad, "gain": ad["val"] - dr["val"]})
    return swaps

def load_model(ctx):
    lg = fl_load(ctx, matchups = False)
    m = {"lg": lg, "swaps": [], "best": -1.0, "slot_best": {}, "metric": "", "tag": "", "err": None,
         "empty": False}
    if not lg["ok"]:
        m["err"] = lg["err"]
        return m
    if lg["state"] == "predraft":
        return m
    if lg["state"] == "demo":
        m["swaps"] = demo_pool()
        m["best"] = m["swaps"][0]["gain"]
        m["metric"] = "PPG+PROJ"
        return m
    pool = sleeper_pool(ctx, lg) if lg["platform"] == "SLEEPER" else espn_pool(ctx, lg)
    if pool.get("err", None) != None:
        m["err"] = pool["err"]
        return m
    if len(pool["mine"]) == 0:
        m["empty"] = True
        return m
    got = pick_swaps(pool["mine"], pool["fa"], 3 if pool["has_pj"] else 2)
    m["swaps"] = got[0]
    m["best"] = got[1]
    m["slot_best"] = got[2]
    m["metric"] = pool["metric"]
    m["tag"] = pool["tag"]
    return m

# ------------------------------------------------------------ drawing
def fit(c, text, fonts, maxw):
    """Largest font that fits; hard-clip in the smallest if none does."""
    t = str(text)
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            return [t, f]
    f = fonts[len(fonts) - 1]
    for k in range(len(t), 0, -1):
        s = t[:k].rstrip(" .-&'")
        if c.text_width(s, f) <= maxw:
            return [s, f]
    return ["", f]

def name_fit(c, p, maxw, fonts):
    """Initial + last name (M.WASHINGTON) in the biggest font that takes it;
    else the last name; else its first part (EDWARDS-HELAIRE -> EDWARDS,
    ST. BROWN -> ST.); else a hard clip."""
    last = p["name"]
    tries = []
    ini = p.get("first", "")[:1]
    if ini != "":
        tries.append(ini + "." + last)
    tries.append(last)
    part = last.replace("-", " ").split(" ")[0]
    if part != "" and part != last:
        tries.append(part)
    for t in tries:
        for f in fonts:
            if c.text_width(t, f) <= maxw:
                return [t, f]
    return fit(c, last, fonts, maxw)

def card(c, head, sub, rail, head_color):
    c.fill("black")
    c.rect(L, 0, L + 1, 31, fill = rail)
    c.sprite(BALL, 14, 11, legend = BALL_LEG, scale = 2)
    h = fit(c, head, ["6x8", "5x7", "4x5"], R - 40)
    c.text(h[0], 112, 8, font = h[1], color = head_color, align = "center")
    s = fit(c, sub, ["4x5", "picopixel"], R - 40)
    c.text(s[0], 112, 21, font = s[1], color = DIM, align = "center")

def logo(c, team, x, y, tint):
    """The club logo, or a dim plate with the abbreviation when the logo
    set has no file (a free agent between teams)."""
    f = LOGO.get(team, None)
    if f != None:
        c.image(f, x, y)
        return
    c.rect(x, y, x + LOGO_W - 1, y + LOGO_H - 1, fill = tint)
    c.text(fit(c, team if team != "" else "FA", ["5x7", "4x5"], LOGO_W - 2)[0], x + LOGO_W // 2, y + 6,
           font = "5x7", color = INK, align = "center")

def jersey(c, team, x, y):
    cl = CLUB.get(team, ["#AEB8C6", "#4A5468"])
    c.sprite(JERSEY, x, y, legend = {"J": cl[1], "T": cl[0]})

def arrow(c, x0, x1, y, pos):
    """The swap arrow: 9 px tall, shaft rows y+2..y+6, head the last 8
    columns. Red tail, green head, split at the middle with a 1 px notch;
    the position pill over the notch."""
    head = 8
    mid = (x0 + x1 - head) // 2
    c.rect(x0, y + 2, mid - 1, y + 6, fill = ALARM)
    c.rect(mid + 1, y + 2, x1 - head, y + 6, fill = GOOD)
    # tail fletching: two notched rows so the tail reads as the start
    c.rect(x0, y + 1, x0 + 3, y + 1, fill = ALARM)
    c.rect(x0, y + 7, x0 + 3, y + 7, fill = ALARM)
    for k in range(head):
        hx = x1 - head + 1 + k
        half = 4 - (k * 5) // head
        if half < 0:
            half = 0
        c.rect(hx, y + 4 - half, hx, y + 4 + half, fill = GOOD)
    # the position as a pill in its fantasy colour, over the notch
    tw = c.text_width(pos, "4x5")
    pw = tw + 5
    px = (x0 + x1 - head) // 2 - pw // 2
    c.rect(px - 1, y + 1, px + pw, y + 7, fill = "black")
    c.rect(px, y + 1, px + pw - 1, y + 7, fill = POS_COLOR.get(pos, INK))
    c.text(pos, px + 3, y + 2, font = "4x5", color = "black")

def mini_arrow(c, x, y):
    """12 x 7: red tail, green head."""
    c.rect(x, y + 2, x + 4, y + 4, fill = ALARM)
    c.rect(x + 5, y + 2, x + 7, y + 4, fill = GOOD)
    for k in range(4):
        c.rect(x + 8 + k, y + k, x + 8 + k, y + 6 - k, fill = GOOD)

def pill(c, pos, x, y, w, font):
    """A position pill: the fantasy colour, black letters, centred."""
    h = 9 if font == "4x5" else 11
    c.rect(x, y, x + w - 1, y + h - 1, fill = POS_COLOR.get(pos, INK))
    c.text(pos, x + w // 2, y + 2, font = font, color = "black", align = "center")

def own_line(p):
    """ESPN % owned: amber from 50% up - move before somebody else does."""
    o = p.get("own", -1)
    if o == None or o < 0:
        return None
    n = int(o + 0.5)
    return [str(n) + "% OWN", AMBER if n >= 50 else DIM]

def move_page(c, m, s):
    c.fill("black")
    demo = m["lg"]["state"] == "demo"
    dr = s["drop"]
    ad = s["add"]
    logo(c, dr["team"], L, 0, DROP_DARK)
    logo(c, ad["team"], R - LOGO_W + 1, 0, ADD_DARK)

    # labels + values beside the logos
    lx = L + LOGO_W + 3              # 33
    rx = R - LOGO_W - 3              # 158
    c.text("DROP", lx, 1, font = "5x7", color = ALARM)
    if ad.get("waiver", False):
        c.text("CLAIM", rx, 1, font = "5x7", color = AMBER, align = "right")
    else:
        c.text("ADD", rx, 1, font = "5x7", color = GOOD, align = "right")
    c.text(fl_fmt1(dr["val"]), lx, 10, font = "5x7", color = INK)
    c.text(fl_fmt1(ad["val"]), rx, 10, font = "5x7", color = INK, align = "right")

    # the hero: the gain
    g = "+" + fl_fmt1(s["gain"])
    cx = 96
    hf = "10x16" if c.text_width(g, "10x16") <= 50 else "9x12"
    c.text(g, cx, 1 if hf == "10x16" else 3, font = hf, color = GOOD, align = "center")
    c.text("PTS/WK", cx, 18, font = "4x5", color = DIM, align = "center")

    # left: the metric (DEMO in the demo); right: % owned (ESPN) or the
    # Sleeper waiver tag
    if demo:
        c.text("DEMO", lx, 18, font = "4x5", color = AMBER)
    else:
        ml = fit(c, m["metric"], ["4x5", "picopixel"], 38)
        c.text(ml[0], lx, 18, font = ml[1], color = DIM)
    ow = own_line(ad)
    if ow != None:
        c.text(ow[0], rx, 18, font = "4x5", color = ow[1], align = "right")
    elif m["tag"] != "":
        c.text(m["tag"], rx, 18, font = "4x5", color = AMBER if m["tag"] == "WAIVERS" else DIM, align = "right")

    # names along the bottom edge, each in its own half; the arrow takes
    # whatever room they leave (at least 74..118)
    nw = 66
    dn = name_fit(c, dr, nw, ["5x7", "4x7", "4x5"])
    an = name_fit(c, ad, nw, ["5x7", "4x7", "4x5"])
    ax0 = max(L + c.text_width(dn[0], dn[1]) + 4, 66)
    ax1 = min(R - c.text_width(an[0], an[1]) - 4, 126)
    arrow(c, min(ax0, 74), max(ax1, 118), 23, s["pos"])
    c.text(dn[0], L, 26 if dn[1] == "4x5" else 25, font = dn[1], color = INK)
    c.text(an[0], R, 26 if an[1] == "4x5" else 25, font = an[1], color = INK, align = "right")

def tight_page(c, m):
    c.fill("black")
    c.rect(L, 0, L + 1, 31, fill = GOOD)
    c.sprite(LOCK, 10, 5, legend = LOCK_LEG, scale = 2)
    h = fit(c, "ROSTER IS TIGHT", ["6x8", "5x7"], 150)
    c.text(h[0], 34, 3, font = h[1], color = GOOD)
    c.text("NO MOVE GAINS 2+ PTS/WK", 34, 14, font = "4x5", color = INK)
    if m["best"] > 0:
        tail = "BEST ON THE WIRE +" + fl_fmt1(m["best"]) + "  " + m["metric"]
    else:
        tail = "NOBODY ON THE WIRE BEATS YOURS"
    t = fit(c, tail, ["4x5", "picopixel"], 150)
    c.text(t[0], 34, 23, font = t[1], color = DIM)

def move_row(c, s, y):
    """One NEXT MOVES row, 16 px: pill, jersey, drop, arrow, jersey, add,
    gain."""
    pill(c, s["pos"], L, y + 4, 23, "4x5")
    jersey(c, s["drop"]["team"], 31, y + 2)
    fonts = ["5x7", "4x7", "3x7"]
    dn = name_fit(c, s["drop"], 41, fonts)
    c.text(dn[0], 44, y + 4, font = dn[1], color = INK)
    mini_arrow(c, 87, y + 4)
    jersey(c, s["add"]["team"], 101, y + 2)
    an = name_fit(c, s["add"], 41, fonts)
    c.text(an[0], 114, y + 4, font = an[1], color = INK)
    g = "+" + fl_fmt1(s["gain"])
    gf = "5x7" if c.text_width(g, "5x7") <= 27 else "4x5"
    c.text(g, R, y + 4 if gf == "5x7" else y + 5, font = gf, color = GOOD, align = "right")

def set_strip(c, m, y):
    """Row 2 when only one move is left for it: every position no move
    touches, ticked."""
    moved = {}
    for s in m["swaps"]:
        moved[s["drop"]["pos"]] = True
        moved[s["add"]["pos"]] = True
    rest = [p for p in POSITIONS if not moved.get(p, False)]
    if len(rest) == 0:
        c.text("EVERY OTHER SPOT IS SET", L, y + 5, font = "4x5", color = DIM)
        return
    c.text("ALSO SET", L, y + 6, font = "4x5", color = DIM)
    x = 46
    for p in rest:
        pill(c, p, x, y + 4, 15, "4x5")
        c.sprite(CHECK, x + 17, y + 5, legend = CHECK_LEG)
        x += 34

def lineup_card(c, m):
    """No second move: a QB / RB / WR / TE line-up card. SWAP where page 1
    moves somebody, else a tick and the best gain the wire has there."""
    c.fill("black")
    moved = {}
    if len(m["swaps"]) > 0:
        moved[m["swaps"][0]["drop"]["pos"]] = True
    for i in range(4):
        pos = POSITIONS[i]
        x0 = L + i * 45
        cx = x0 + 22
        pill(c, pos, cx - 12, 1, 25, "5x7")
        if moved.get(pos, False):
            c.text("SWAP", cx, 15, font = "5x7", color = AMBER, align = "center")
            sub = "SEE MOVE"
        else:
            tw = c.text_width("SET", "5x7")
            sx = cx - (tw + 9) // 2
            c.sprite(CHECK, sx, 15, legend = CHECK_LEG)
            c.text("SET", sx + 9, 15, font = "5x7", color = GOOD)
            g = m["slot_best"].get(pos, -1.0)
            sub = "BEST +" + fl_fmt1(g) if g > 0 else "NO MOVE"
        c.text(sub, cx, 26, font = "4x5", color = DIM, align = "center")

def next_page(c, m):
    rest = m["swaps"][1:3]
    if len(rest) == 0:
        lineup_card(c, m)
        return
    c.fill("black")
    move_row(c, rest[0], 0)
    c.rect(L, 16, R, 16, fill = "#1C2230")
    if len(rest) > 1:
        move_row(c, rest[1], 16)
    else:
        set_strip(c, m, 16)

def state_screen(c, m):
    lg = m["lg"]
    if m["err"] != None:
        card(c, m["err"][0], m["err"][1], OFFLINE, AMBER)
        return True
    if lg["state"] == "predraft":
        card(c, "DRAFT DAY AHEAD", "MOVES START AFTER YOUR DRAFT", GOOD, GOOD)
        return True
    if m["empty"] and lg.get("format", "h2h") == "guillotine":
        card(c, "CHOPPED", "YOUR TEAM WAS CUT - NO ROSTER LEFT", OFFLINE, ALARM)
        return True
    if m["empty"]:
        card(c, "NO PLAYERS YET", "YOUR ROSTER IS EMPTY", GOOD, GOOD)
        return True
    if lg["state"] != "demo" and not lg["me_matched"]:
        card(c, "SET YOUR TEAM", "TEAM NAME OR MANAGER IN SETTINGS", AMBER, AMBER)
        return True
    return False

def move(c, ctx):
    m = load_model(ctx)
    if state_screen(c, m):
        return
    if len(m["swaps"]) > 0:
        move_page(c, m, m["swaps"][0])
    else:
        tight_page(c, m)

def next_moves(c, ctx):
    m = load_model(ctx)
    if state_screen(c, m):
        return
    next_page(c, m)
