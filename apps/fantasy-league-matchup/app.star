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
# MY FANTASY MATCHUP
#
# DESIGN. Your fantasy week as a football field. Fantasy teams have no
# logos, so each team is its own pixel crest (the adapter's fl_badge): you
# on the left, this week's opponent on the right, each crest standing over
# its own end zone painted in the team colour and lettered with the team's
# record. Between them the two scores are the hero in 10x16 with a
# hand-set 2 px decimal point (the font's '.' is a full 10 px cell) - the
# leader white, the trailer slate - and the names sit above in the team
# colours. The one memorable thing is the field: a laced pixel football
# that sits at your win probability.
#
#   matchup   the field. The ball sits at your win probability between
#             your end zone and theirs (ahead = driving toward theirs). The
#             middle column says it in words: WIN 68%, green when you're the
#             favourite, amber in a coin flip, red when you're behind. When
#             the week is over the ball is in the winner's end zone, the
#             column reads FINAL / WON or LOST, and the 50-yard line carries
#             your place in the league (3RD OF 12). Tuesday to Thursday,
#             before anyone has points, it shows LAST week's final instead
#             of a 0.0 - 0.0 game ("WK 2 / WON").
#   outlook   the race to Monday night. One lane per team: a crest, a bar
#             of points already scored (bright) with the projected rest of
#             the week behind it (dim), the projected final on the right,
#             then the streak chip (W3 / L1), a helmet per starter still to
#             play with the count (12 TO PLAY), and the team's top scorer
#             (Sleeper). Trailing on projection, your label reads NEED 18.4.
#
# Guillotine leagues (Sleeper, no head-to-head) swap the opponent for the
# CHOP LINE - the lowest-projected team that isn't you, shown by projected
# total - and the outlook page lines up the crests in projected order with
# the chop zone in red and the hidden middle of a big league counted (+6).
# Fantasy byes draw your own lane; playoff weeks without a game read
# PLAYOFF BYE (top seeds) or SEASON OVER with your final place.
#
# DATA. The shared fantasy-league adapter v2 (block above): ESPN is one call
# (live score, projection, ESPN's own win probability, last week); Sleeper
# is league + managers + rosters + matchups plus three projection feeds,
# priced in the league's exact scoring, from which the adapter builds the
# projection and a normal-model win probability calibrated to ESPN's.
# Refresh 300: the viewer types a league ID and team (free text), and the
# live-score cache matches it.
# ======================================================================

INK = "#F4F7FF"
DIM = "#6E7A94"
TRAIL = "#7C849A"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
AMBER = "#FFBF00"
ALARM = "#FF3B30"
GRASS = "#0B4A20"
YARD = "#2F7D45"
MIDLINE = "#7FCB92"
GOLD = "#FFC83D"
LANE_BG = "#161B26"

L = 6            # safe zone
R = 185
BADGE_W = 22     # fl_badge(size 24) is 22 x 24
TX0 = L + BADGE_W + 3      # 31: text zone between the crests
TX1 = R - BADGE_W - 3      # 160
MID = (TX0 + TX1) // 2     # 95
FIELD_Y = 25               # the field: y 25..31
EZ = BADGE_W               # end zones as wide as the crests

# 11 x 6 football with white laces.
BALL = """
...DDDDD...
.DBBBBBBBD.
DBBWBWBWBBD
DBWWWWWWWBD
.DBBBBBBBD.
...DDDDD...
"""
BALL_LEG = {"D": "#6B3410", "B": "#B5652B", "W": "#FFFFFF"}
BALL_W = 11

# 7 x 6 helmet facing right, for starters still to play: shell in the team
# colour, a grey facemask cage.
HELMET = """
.XXXX..
XXXXXX.
XXXXXXM
XX.XMMM
XXX.M.M
.XX.MMM
"""

# 5 x 5 star for the top scorer.
STAR = """
..Y..
YYYYY
.YYY.
.Y.Y.
Y...Y
"""

# 13 x 14 trophy for a playoff bye (drawn at 2x).
TROPHY = """
.GGGGGGGGGGG.
GGYYYYYYYYYGG
G.GYYYYYYYG.G
G.GYYYYYYYG.G
.GGYYYYYYYGG.
...GYYYYYG...
....GYYYG....
.....GYG.....
.....GYG.....
....GGYGG....
...GYYYYYG...
...GGGGGGG...
..GYYYYYYYG..
..GGGGGGGGG..
"""
TROPHY_LEG = {"G": "#B8860B", "Y": "#FFD23F"}

# 20 x 24 guillotine for the chop line: two wooden posts and a crossbeam,
# the slanted blade hanging near the top, the lunette at the bottom.
GUILLOTINE = """
WWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWW
PP................PP
PP.RRRRRRRRRRRRRR.PP
PP.SSSSSSSSSSSSSS.PP
PP.SSSSSSSSSSSSSS.PP
PP.SSSSSSSSSSSSSE.PP
PP.SSSSSSSSSSSEE..PP
PP.SSSSSSSSSEE....PP
PP.SSSSSSSEE......PP
PP.SSSSSEE........PP
PP.EEEEE..........PP
PP................PP
PP................PP
PP................PP
PP................PP
PP................PP
PPWWWWWWWWWWWWWWWWPP
PPW.....WWWW.....WPP
PPW......WW......WPP
PPWWWWWWWWWWWWWWWWPP
PP................PP
PPPP............PPPP
PPPP............PPPP
"""
GUILLOTINE_LEG = {"W": "#8A5A2B", "P": "#A86F38", "R": "#5E6878", "S": "#AEB8C6", "E": "#FFFFFF"}

def ordinal(n):
    tail = "TH"
    if n % 100 < 11 or n % 100 > 13:
        tail = {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")
    return str(n) + tail

def record(t):
    s = str(t["wins"]) + "-" + str(t["losses"])
    return s + ("-" + str(t["ties"]) if t["ties"] > 0 else "")

def streak(t):
    """'3W' (both platforms) -> ['W3', colour], or None."""
    s = t.get("streak", "")
    if len(s) < 2:
        return None
    kind = s[len(s) - 1:]
    n = s[:len(s) - 1]
    if kind not in ["W", "L", "T"] or n == "" or n == "0":
        return None
    return [kind + n, GOOD if kind == "W" else (ALARM if kind == "L" else AMBER)]

def fit(c, text, fonts, maxw):
    """Largest font that fits; hard-clip in the smallest if none does."""
    t = str(text)
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            return [t, f]
    f = fonts[len(fonts) - 1]
    for k in range(len(t), 0, -1):
        s = t[:k].rstrip(" .-&")
        if c.text_width(s, f) <= maxw:
            return [s, f]
    return ["", f]

def name_for(c, team, maxw):
    """Full team name, else its first words, in 5x7 then 4x5."""
    full = team["name"]
    got = fit(c, full, ["5x7", "4x5"], maxw)
    if got[0] == full:
        return got
    words = full.split(" ")
    for k in range(len(words) - 1, 0, -1):
        part = " ".join(words[:k])
        for f in ["5x7", "4x5"]:
            if c.text_width(part, f) <= maxw:
                return [part, f]
    return got

def shorten(c, text, font, maxw):
    """The longest run of whole leading words that fits, else a hard clip."""
    if c.text_width(text, font) <= maxw:
        return text
    words = text.split(" ")
    for k in range(len(words) - 1, 0, -1):
        part = " ".join(words[:k])
        if c.text_width(part, font) <= maxw:
            return part
    return fit(c, text, [font], maxw)[0]

def name_pair(c, left, right, total, gap):
    """Both names in ONE font, so the row reads as a pair. 5x7 if both fit
    whole, else 4x5; if even 4x5 is too wide, the longer name gives up whole
    words until the pair fits ('FOURTH AND LONG' -> 'FOURTH AND')."""
    for f in ["5x7", "4x5"]:
        if c.text_width(left, f) + c.text_width(right, f) + gap <= total:
            return [left, right, f]
    f = "4x5"
    wl = c.text_width(left, f)
    wr = c.text_width(right, f)
    half = (total - gap) // 2
    if wl <= half:
        return [left, shorten(c, right, f, total - gap - wl), f]
    if wr <= half:
        return [shorten(c, left, f, total - gap - wr), right, f]
    return [shorten(c, left, f, half), shorten(c, right, f, half), f]

def win_color(p):
    return GOOD if p >= 60 else (AMBER if p >= 40 else ALARM)

# ------------------------------------------------------------ hero digits
# The 10x16 font draws '.' as a full 10 px cell, so "104.6" would carry a
# hole in the middle. The whole part and the tenth are set separately with
# a 2 x 2 dot between them.
HERO_DOT_Y = 13     # last row of the 10x16 digits (9x12: 10)

def hero_w(c, s, font):
    k = s.find(".")
    if k < 0:
        return c.text_width(s, font)
    return c.text_width(s[:k], font) + 5 + c.text_width(s[k + 1:], font)

def hero_text(c, s, x, y, font, col, right):
    w = hero_w(c, s, font)
    x0 = x - w + 1 if right else x
    k = s.find(".")
    if k < 0:
        c.text(s, x0, y, font = font, color = col)
        return
    whole = s[:k]
    ww = c.text_width(whole, font)
    c.text(whole, x0, y, font = font, color = col)
    dy = HERO_DOT_Y if font == "10x16" else 10
    c.rect(x0 + ww + 1, y + dy - 1, x0 + ww + 2, y + dy, fill = col)
    c.text(s[k + 1:], x0 + ww + 5, y, font = font, color = col)

# ------------------------------------------------------------ screens
def card(c, head, sub, rail_color, head_color):
    c.fill("black")
    c.rect(L, 0, L + 1, 31, fill = rail_color)
    c.sprite(BALL, 12, 10, legend = BALL_LEG, scale = 2)
    h = fit(c, head, ["6x8", "5x7", "4x5"], R - 44)
    c.text(h[0], 114, 8, font = h[1], color = head_color, align = "center")
    s = fit(c, sub, ["4x5", "picopixel"], R - 44)
    c.text(s[0], 114, 21, font = s[1], color = DIM, align = "center")

def state_screen(c, lg):
    """Anything that isn't a matchup to draw: error, pre-draft, no game."""
    if not lg["ok"]:
        card(c, lg["err"][0], lg["err"][1], OFFLINE, AMBER)
        return True
    if lg["state"] == "predraft":
        card(c, "DRAFT DAY AHEAD", "MATCHUPS START AFTER YOUR DRAFT", GOOD, GOOD)
        return True
    if lg["state"] == "nomatch":
        card(c, "NO GAME THIS WEEK", "YOUR LEAGUE IS OFF - BACK NEXT WEEK", GOOD, GOOD)
        return True
    return False

def opponent(lg):
    """[me, them, my score row, their score row, final, my win %]. Head to
    head: this week's opponent. Guillotine: the lowest team that isn't you
    (by projection when there is one)."""
    me = fl_team(lg, lg["me"])
    mine = lg["scores"].get(lg["me"], None)
    if lg.get("format", "h2h") == "guillotine":
        rows = [r for r in guill_order(lg) if r[1]["id"] != lg["me"]]
        if len(rows) == 0 or mine == None:
            return None
        worst = rows[len(rows) - 1]
        return [me, worst[1], mine, lg["scores"][worst[1]["id"]], False, -1]
    return side_rows(lg, fl_mine(lg), me, mine)

def side_rows(lg, mm, me, mine):
    m = mm[0]
    if m == None:
        return [me, None, mine, None, False, -1]
    a = mm[1] == "a"
    them = fl_team(lg, m["b"] if a else m["a"])
    if them == None:
        return [me, None, mine, None, False, -1]
    ms = {"pts": m["a_pts"] if a else m["b_pts"], "proj": m["a_proj"] if a else m["b_proj"],
          "left": m["a_left"] if a else m["b_left"]}
    ts = {"pts": m["b_pts"] if a else m["a_pts"], "proj": m["b_proj"] if a else m["a_proj"],
          "left": m["b_left"] if a else m["a_left"]}
    win = m["a_win"]
    if win >= 0 and not a:
        win = 100 - win
    return [me, them, ms, ts, m["final"], win]

def playoff_state(lg, me):
    """'' in the regular season, else 'bye' (a top seed resting in the
    first playoff week) or 'over' (no game in a playoff week)."""
    reg = lg.get("reg_weeks", 99)
    if lg["week"] <= reg:
        return ""
    pt = lg.get("playoff_teams", 0)
    if lg["week"] == reg + 1 and pt > 0 and me["rank"] <= pt:
        return "bye"
    return "over"

def side_screen(c, lg, me, mine, head, head_color, sub, big, small, art):
    """Your crest and name, a headline and a line under it, a big figure
    on the right."""
    c.fill("black")
    fl_badge(c, me, L, 4, 24)
    right = R
    if art == "trophy":
        c.sprite(TROPHY, R - 25, 2, legend = TROPHY_LEG, scale = 2)
        right = R - 30
    bw = c.text_width(big, "9x12") if big != "" else 0
    nm = name_for(c, me, right - TX0 - bw - 6)
    c.text(nm[0], TX0, 2, font = nm[1], color = me["color"])
    h = fit(c, head, ["6x8", "5x7"], right - TX0 - bw - 6)
    c.text(h[0], TX0, 12, font = h[1], color = head_color)
    s = fit(c, sub, ["4x5", "picopixel"], right - TX0 - bw - 6)
    c.text(s[0], TX0, 24, font = s[1], color = DIM)
    if big != "":
        hero_text(c, big, right, 6, "9x12", INK, True)
        c.text(small, right, 21, font = "4x5", color = DIM, align = "right")

def no_opponent(c, lg, me, mine):
    """No head-to-head game for you this week."""
    ps = playoff_state(lg, me)
    n = len(lg["teams"])
    if ps == "bye":
        side_screen(c, lg, me, mine, "PLAYOFF BYE", GOOD, "SEED " + str(me["rank"]) + " - " + record(me) + " - BACK NEXT WEEK",
                    "", "", "trophy")
    elif ps == "over":
        side_screen(c, lg, me, mine, "SEASON OVER", AMBER, ordinal(me["rank"]) + " OF " + str(n) + " - " + record(me),
                    ordinal(me["rank"]), "FINAL", "")
    else:
        side_screen(c, lg, me, mine, "BYE WEEK", GOOD, "NO OPPONENT THIS WEEK",
                    fl_fmt1(mine["pts"]) if mine != None else "", "PTS", "")

# ------------------------------------------------------------ the field
def field(c, lg, me, them, win, final, guillotine, demo):
    y0 = FIELD_Y
    c.rect(L, y0, L + EZ - 1, 31, fill = color.dim(me["color"], 45))
    c.rect(R - EZ + 1, y0, R, 31, fill = color.dim(them["color"], 45) if not guillotine else color.dim(ALARM, 45))
    # End zones are lettered with each team's record, like a stadium's
    # painted end zone.
    ez = [[L, record(me)], [R - EZ + 1, "CUT" if guillotine else record(them)]]
    for e in ez:
        t = fit(c, e[1], ["4x5", "picopixel"], EZ - 2)
        c.text_stroke(t[0], e[0] + EZ // 2, y0 + 1, font = t[1], color = INK, stroke = "black", align = "center")
    g0 = L + EZ
    g1 = R - EZ
    c.rect(g0, y0, g1, 31, fill = GRASS)
    span = g1 - g0
    for k in range(1, 10):
        x = g0 + span * k // 10
        c.rect(x, y0, x, 31, fill = MIDLINE if k == 5 else YARD)
    if demo:
        c.text_stroke("DEMO", g0 + 3, y0 + 1, font = "4x5", color = AMBER, stroke = "black")
    if win < 0:
        return
    if final:
        # Touchdown: the ball breaks the loser's goal line (clear of the
        # record painted in the end zone), and the 50 carries your place
        # in the league.
        bx = (g1 - 5) if win >= 50 else (g0 - 4)
        st = ordinal(me["rank"]) + " OF " + str(len(lg["teams"]))
        c.text_stroke(st, g0 + span // 2 + 1, y0 + 1, font = "4x5", color = INK, stroke = "black", align = "center")
        c.sprite(BALL, bx, y0 + 1, legend = BALL_LEG)
        return
    bx = g0 + span * win // 100 - BALL_W // 2
    lo = g0 + (21 if demo else 1)
    bx = lo if bx < lo else (g1 - BALL_W if bx > g1 - BALL_W else bx)
    c.sprite(BALL, bx, y0 + 1, legend = BALL_LEG)

# ------------------------------------------------------------ page 1
def matchup(c, ctx):
    lg = fl_load(ctx, projections = True)
    if state_screen(c, lg):
        return
    me = fl_team(lg, lg["me"])
    guill = lg.get("format", "h2h") == "guillotine"
    # Tuesday to Thursday nobody has points yet: show last week's final
    # rather than a 0.0 - 0.0 game.
    if not guill and not lg.get("played", True):
        lm = fl_mine_last(lg)
        if lm[0] != None:
            o = side_rows(lg, lm, me, None)
            if o[1] != None:
                board(c, lg, o[0], o[1], o[2]["pts"], o[3]["pts"], True, o[5], "WK " + str(lg["last"]["week"]))
                return
    o = opponent(lg)
    if o == None:
        card(c, "NO SCORES YET", "CHECK BACK AT KICKOFF", GOOD, GOOD)
        return
    me, them, ms, ts, final, win = o[0], o[1], o[2], o[3], o[4], o[5]
    if them == None:
        no_opponent(c, lg, me, ms)
        return
    if guill:
        # The chop line a fan sweats is the projected total, not the live one.
        a = ms["proj"] if ms["proj"] >= 0 else ms["pts"]
        b = ts["proj"] if ts["proj"] >= 0 else ts["pts"]
        board(c, lg, me, them, a, b, False, -1, "PROJ" if ts["proj"] >= 0 else "LIVE")
        return
    board(c, lg, me, them, ms["pts"], ts["pts"], final, win, "FINAL")

def board(c, lg, me, them, a, b, final, win, tag):
    guill = lg.get("format", "h2h") == "guillotine"
    demo = lg["state"] == "demo"
    c.fill("black")
    fl_badge(c, me, L, 0, 24)
    if guill:
        c.sprite(GUILLOTINE, R - 19, 0, legend = GUILLOTINE_LEG)
    else:
        fl_badge(c, them, R - BADGE_W + 1, 0, 24)

    # Top row: the two names in team colours. An unmatched `team` input
    # shows where to fix it instead of a stranger's name.
    unmatched = not demo and not lg["me_matched"]
    left = "SET YOUR TEAM" if unmatched else me["name"]
    right = "CHOP LINE" if guill else them["name"]
    np = name_pair(c, left, right, TX1 - TX0 + 1, 5)
    c.text(np[0], TX0, 0, font = np[2], color = AMBER if unmatched else me["color"])
    c.text(np[1], TX1, 0, font = np[2], color = ALARM if guill else them["color"], align = "right")

    # Hero: the two scores. The leader is white, the trailer slate.
    sa = fl_fmt1(a)
    sb = fl_fmt1(b)
    hero = "10x16"
    if hero_w(c, sa, hero) + hero_w(c, sb, hero) > (TX1 - TX0) - 30:
        hero = "9x12"
    hy = 8 if hero == "10x16" else 10
    hero_text(c, sa, TX0, hy, hero, INK if a >= b else TRAIL, False)
    hero_text(c, sb, TX1, hy, hero, INK if b >= a else TRAIL, True)

    # Middle column: the verdict.
    if final:
        c.text(tag, MID, 9, font = "4x5", color = DIM, align = "center")
        word = "WON" if win > 50 else ("LOST" if win < 50 else "TIE")
        c.text(word, MID, 16, font = "5x7", color = GOOD if win > 50 else (ALARM if win < 50 else AMBER), align = "center")
    elif guill:
        place = guill_place(lg)
        # Lowest projected is cut, next-lowest is a bad Monday away from it.
        word = ["SAFE", GOOD]
        if place[0] == place[1]:
            word = ["CUT", ALARM]
        elif place[0] == place[1] - 1:
            word = ["RISK", AMBER]
        if place[0] == 0:
            word = ["OUT", ALARM]        # already chopped in an earlier week
        c.text(tag, MID, 9, font = "4x5", color = DIM, align = "center")
        c.text(word[0], MID, 16, font = "5x7", color = word[1], align = "center")
    elif win >= 0:
        c.text("WIN", MID, 9, font = "4x5", color = DIM, align = "center")
        c.text(str(win) + "%", MID, 16, font = "5x7", color = win_color(win), align = "center")
    else:
        c.text("LIVE", MID, 12, font = "4x5", color = DIM, align = "center")

    if guill:
        chop_strip(c, lg)
    else:
        field(c, lg, me, them, win, final, False, demo)

def guill_order(lg):
    """Teams still alive (the adapter marks a cut team with starters 0),
    best projected first."""
    rows = []
    for t in lg["teams"]:
        s = lg["scores"].get(t["id"], None)
        if s != None and s.get("starters", 1) != 0 and s.get("cut", 0) == 0:
            rows.append([s["proj"] if s["proj"] >= 0 else s["pts"], t])
    return sorted(rows, key = lambda r: -r[0])

def guill_place(lg):
    """[your place by projected score, teams still alive this week]."""
    rows = guill_order(lg)
    for i in range(len(rows)):
        if rows[i][1]["id"] == lg["me"]:
            return [i + 1, len(rows)]
    return [0, len(rows)]

def chop_strip(c, lg):
    """Guillotine: every team as a pip on the field row, best projected on
    the left; you are white, the one on the block red, the next amber, the
    rest dim grass."""
    rows = guill_order(lg)
    n = len(rows)
    if n == 0:
        return
    y0 = FIELD_Y
    c.rect(L, y0, R, 31, fill = GRASS)
    span = R - L + 1
    pitch = span // n
    w = pitch - 2 if pitch - 2 <= 8 else 8
    for i in range(n):
        x = L + i * pitch + (pitch - w) // 2
        t = rows[i][1]
        col = INK if t["id"] == lg["me"] else (ALARM if i == n - 1 else (AMBER if i == n - 2 else YARD))
        c.rect(x, y0 + 1, x + w - 1, 30, fill = col)

# ------------------------------------------------------------ page 2
def outlook(c, ctx):
    lg = fl_load(ctx, projections = True)
    if state_screen(c, lg):
        return
    o = opponent(lg)
    if o == None:
        card(c, "NO SCORES YET", "CHECK BACK AT KICKOFF", GOOD, GOOD)
        return
    me, them, ms, ts = o[0], o[1], o[2], o[3]
    demo = lg["state"] == "demo"
    if them == None:
        if playoff_state(lg, me) != "" or ms == None:
            no_opponent(c, lg, me, ms)
            return
        # Fantasy bye (odd team count): your own lane - you still score.
        c.fill("black")
        top = ms["proj"] if ms["proj"] > ms["pts"] else ms["pts"]
        x1 = lane_x1(c, [[ms, ""]])
        lane(c, lg, me, ms, 0, top * 1.04 if top > 0 else 1.0, x1, "")
        c.rect(L, 18, R, 29, fill = "#10141C")
        c.text("FANTASY BYE - NO OPPONENT THIS WEEK", (L + R) // 2, 21, font = "4x5", color = DIM, align = "center")
        return
    c.fill("black")
    if lg.get("format", "h2h") == "guillotine":
        chop_board(c, lg)
        return
    top = 0
    for s in [ms, ts]:
        top = s["pts"] if s["pts"] > top else top
        top = s["proj"] if s["proj"] > top else top
    top = top * 1.04 if top > 0 else 1.0
    # Trailing on projection: how far short you are.
    need = ""
    if ms["proj"] >= 0 and ts["proj"] >= 0 and ms["proj"] < ts["proj"] and not o[4]:
        need = "NEED " + fl_fmt1(ts["proj"] - ms["proj"])
    x1 = lane_x1(c, [[ms, need], [ts, ""]])
    lane(c, lg, me, ms, 0, top, x1, need)
    end = lane(c, lg, them, ts, 16, top, x1, "")
    dx = R - c.text_width(lane_label(ts), "4x5") - 5
    if demo and end + c.text_width("DEMO", "4x5") <= dx:
        c.text("DEMO", dx, 26, font = "4x5", color = AMBER, align = "right")

def lane_val(s):
    """Projected final, or the score itself once everyone has played."""
    return s["proj"] if s["proj"] >= 0 and s["left"] != 0 else s["pts"]

def lane_label(s):
    return "FINAL" if s["left"] == 0 else ("PROJ" if s["proj"] >= 0 else "LIVE")

def lane_x1(c, sides):
    """One right edge for every lane's bar, so the bars share a scale."""
    wide = 0
    for sd in sides:
        s = sd[0]
        val = lane_val(s)
        for w in [c.text_width(fl_fmt1(val), "6x8"), c.text_width(sd[1] if sd[1] != "" else lane_label(s), "4x5")]:
            wide = w if w > wide else wide
    return R - wide - 4

def lane(c, lg, team, s, y, top, x1, need):
    """One team's race: crest, scored-so-far bar (bright) with the projected
    rest (dim) behind it, the projected final on the right, then streak,
    helmets + count of starters still to play, and the top scorer."""
    fl_badge(c, team, L, y, 16)
    x0 = L + 16 + 3
    val = lane_val(s)
    span = x1 - x0
    c.rect(x0, y + 1, x1, y + 7, fill = LANE_BG)
    pw = int(span * s["pts"] / top + 0.5)
    jw = int(span * val / top + 0.5)
    pw = 0 if pw < 0 else (span if pw > span else pw)
    jw = 0 if jw < 0 else (span if jw > span else jw)
    if jw > pw:
        c.rect(x0, y + 1, x0 + jw - 1, y + 7, fill = color.dim(team["color"], 35))
    if pw > 0:
        c.rect(x0, y + 1, x0 + pw - 1, y + 7, fill = team["color"])
        live = fl_fmt1(s["pts"])
        if pw >= c.text_width(live, "4x5") + 4:
            c.text(live, x0 + pw - 2, y + 2, font = "4x5", color = "black", align = "right")
    c.text(fl_fmt1(val), R, y + 1, font = "6x8", color = INK, align = "right")
    if need != "":
        c.text(need, R, y + 10, font = "4x5", color = AMBER, align = "right")
    else:
        c.text(lane_label(s), R, y + 10, font = "4x5", color = DIM, align = "right")

    # Second row, left to right: streak chip, helmets, count, top scorer.
    x = x0
    stop = R - c.text_width(need if need != "" else lane_label(s), "4x5") - 5
    sk = streak(team)
    if sk != None:
        w = c.text_width(sk[0], "4x5")
        c.rect(x, y + 9, x + w + 1, y + 15, fill = sk[1])
        c.text(sk[0], x + 1, y + 10, font = "4x5", color = "black")
        x += w + 5
    left = s["left"]
    if left > 0:
        # Three helmets, two once a top scorer needs the room; the count
        # carries the number either way (13-starter lineups exist).
        cap = 2 if s["pts"] > 0 and fl_top(lg, team["id"]) != None else 3
        for i in range(left if left <= cap else cap):
            c.sprite(HELMET, x, y + 9, legend = {"X": team["color"], "M": "#9AA3B2"})
            x += 9
        t = str(left) + " TO PLAY"
        c.text(t, x, y + 10, font = "4x5", color = DIM)
        x += c.text_width(t, "4x5") + 5
    elif left == 0:
        return top_line(c, lg, team, x, y, stop, "ALL PLAYED")
    if s["pts"] > 0:
        return top_line(c, lg, team, x, y, stop, "")
    return x

def top_line(c, lg, team, x, y, stop, fallback):
    tp = fl_top(lg, team["id"])
    if tp != None:
        t = tp[0] + " " + fl_fmt1(tp[1])
        if x + 7 + c.text_width(t, "4x5") <= stop:
            c.sprite(STAR, x, y + 10, legend = {"Y": GOLD})
            c.text(t, x + 7, y + 10, font = "4x5", color = INK)
            return x + 7 + c.text_width(t, "4x5") + 4
        t = shorten(c, tp[0], "4x5", stop - x - 7)
        if t != "" and len(t) == len(tp[0]):
            c.sprite(STAR, x, y + 10, legend = {"Y": GOLD})
            c.text(t, x + 7, y + 10, font = "4x5", color = INK)
            return x + 7 + c.text_width(t, "4x5") + 4
    if fallback != "" and x + c.text_width(fallback, "4x5") <= stop:
        c.text(fallback, x, y + 10, font = "4x5", color = DIM)
        return x + c.text_width(fallback, "4x5") + 4
    return x

def chop_board(c, lg):
    """Guillotine outlook: crests in projected order, left to right, the last
    one over a red chop zone and yours underlined. Past 10 teams it shows
    the top four and the bottom five with the hidden middle counted (+6)."""
    rows = guill_order(lg)
    n = len(rows)
    show = rows if n <= 10 else rows[:4] + [None] + rows[n - 5:]
    pitch = (R - L + 1) // len(show)
    for i in range(len(show)):
        x = L + i * pitch + (pitch - 16) // 2
        if show[i] == None:
            c.text("+" + str(n - 9), x + 8, 5, font = "5x7", color = DIM, align = "center")
            for dx in [3, 8, 13]:
                c.pixel(x + dx, 21, DIM)
            continue
        t = show[i][1]
        last = i == len(show) - 1
        if last:
            c.rect(x - 1, 17, x + 16, 25, fill = color.dim(ALARM, 40))
        fl_badge(c, t, x, 0, 16)
        v = str(int(show[i][0] + 0.5))
        c.text(v, x + 8, 19, font = "4x5", color = INK if t["id"] == lg["me"] else (ALARM if last else DIM), align = "center")
        if t["id"] == lg["me"]:
            c.rect(x + 3, 27, x + 12, 28, fill = INK)
    c.text("PROJ", R, 27, font = "4x5", color = DIM, align = "right")
