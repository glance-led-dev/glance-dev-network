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
# MY ROSTER REPORT
#
# DESIGN. LOCKER ROOM FIRST. Page 1 is your locker room; page 2 is the
# trainer's clipboard for one player at a time.
#
#   lineup   (page 1) a bank of steel locker stalls across the panel, one
#            per starting slot in the league's order. Each stall: a
#            nameplate on top with the league's slot name (QB, RB, FLEX,
#            SF, DL...) - brushed steel for a starter who is good to go,
#            the status colour for one who is hurt or on bye, so trouble
#            lights up along the top row -, a hanging bar, the jersey on its
#            hook in the status colour with a chest mark (X out, IR, D
#            doubtful, ? questionable, B bye, a tick when good to go; grey
#            with ? for a player the feeds don't cover; an empty stall is
#            just the hook), cleats on the floor. Your crest hangs on the far
#            end of the room (up to 10 stalls; bigger IDP lineups use the full width
#            and 7 px jerseys). The bench runs along the bottom with your
#            team name and a READY pill ("5 OF 9 READY": green all, amber
#            one short, red worse; unknown slots are left out of the count).
#            Errors / empty / pre-draft: the room with nobody in it - two
#            empty stalls on their benches either side, the message in the
#            aisle.
#            y 0..6 plates | 7 bar | 8 hook | 9..21 jersey | 23..24 cleats
#            | 25..31 bench.
#   report   (page 2) one player per refresh, most urgent first: starters
#            who are OUT / IR / DOUBTFUL / QUESTIONABLE, then IR-slot players
#            who are healthy again (ACTIVATE - the league locks your lineup
#            until you move them), then starters on bye, then hurt bench
#            players. IR-slot players still on IR never show. Left: the chip
#            row (status - dimmed with LAST WK when the tag predates this
#            week's reports -, position, the lineup slot as the league names
#            it: STARTER / FLEX / SF / W/R / BENCH / IR SLOT, PROJ at the
#            right), the player's name as the hero, a footer with the body
#            part in the status colour and the bench cover in green ("2 RB
#            READY ON BENCH"). Then the wooden clipboard (x 115..142) with a
#            filled body figure whose hurt part glows in the status colour
#            (a calendar page with the week number on a bye; brass pips on
#            its base count the frames), and his NFL club's logo with the
#            game and decision deadline under it ("@DEN 4:25", "VS KC MNF",
#            amber inside 24 hours). Nobody hurt: the figure turns green,
#            ROSTER HEALTHY, your crest on the right.
#
# DATA. The shared fantasy-league adapter v2 (block above) finds your
# league and team (a Sleeper ID followed from last season re-reads this
# season's managers, so renamed teams match); this app asks it for no
# matchups - the roster's own starters are the lineup. Sleeper: 3
# projection feeds carry every player's injury status, body part, news
# time, club, opponent, date and projection (fl_proj_pts, league scoring),
# plus a club -> game map so a player with no projection row still gets his
# game. + fl_nfl_games (ESPN's keyless schedule) for home/away, kickoff
# time and byes on both platforms. Then at most one players/nfl/<id> for an
# IDP starter the feeds miss. The league's roster_positions come with the
# adapter (v2.1 lg["raw"], no request).
# Budget: Sleeper 3 + 3 projections + schedule + 1 IDP = 8; a followed ID
# with your team matched: 2 follow calls + 3 + 3 + schedule = 8 (v2.1 puts
# the slate ahead of the fresh-managers refresh), so it gets VS / @ too. ESPN: 1 + mRoster +
# schedule + one athlete card for the player on screen (body part) = 4.
# ======================================================================

INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
AMBER = "#FFBF00"
C_OUT = "#FF2D2D"
C_DOUBT = "#FF7A1F"
C_QUES = "#FFBF00"
C_BYE = "#3DB6FF"
C_UNK = "#5A6478"
SLATE = "#3A4356"
WOOD = "#8A5A2B"
WOOD_DK = "#5C3A1A"
STEEL = "#AEB8C6"
STEEL_DK = "#5E6878"
PAPER = "#141B29"
FIGURE = "#6F7C96"
BRASS = "#FFD27A"

L = 6
R = 185
TX = 6            # text zone x 6..111 (page 2: text, then the clipboard, then the logo)
TR = 111
TW = TR - TX + 1
LOGO_X = 146      # 40 x 24 logo x 146..185
BOARD_X = 115     # clipboard x 115..142, beside the logo

ESPN_BASE = "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/"
ESPN_ATHLETE = "https://site.web.api.espn.com/apis/common/v3/sports/football/nfl/athletes/"
TTL_ROSTER = 900
TTL_CARD = 3600
TTL_PLAYER = 21600

# status key -> [long, middle, short, colour, severity (0 = worst), chest letter]
STATUS = {
    "OUT": ["OUT", "OUT", "OUT", C_OUT, 0, "X"],
    "IR": ["INJURED RESERVE", "INJ RESERVE", "IR", C_OUT, 0, "IR"],
    "PUP": ["PUP LIST", "PUP", "PUP", C_OUT, 0, "P"],
    "SUS": ["SUSPENDED", "SUSP", "SUS", C_OUT, 1, "S"],
    "NA": ["INACTIVE", "INACT", "NA", C_OUT, 1, "NA"],
    "DOUBTFUL": ["DOUBTFUL", "DOUBT", "D", C_DOUBT, 2, "D"],
    "QUESTIONABLE": ["QUESTIONABLE", "QUES", "Q", C_QUES, 3, "?"],
    "DTD": ["DAY TO DAY", "DAY-DAY", "DTD", C_QUES, 3, "?"],
    "ACT": ["ACTIVATE", "ACTIVATE", "ACT", GOOD, 4, "A"],
    "BYE": ["BYE WEEK", "BYE", "BYE", C_BYE, 5, "B"],
}
# Tags that keep a player in an IR slot legally: those players are not a
# decision. Anything else in an IR slot locks the lineup until he is moved.
STILL_IR = ["IR", "OUT", "PUP", "NA", "SUS"]
# Game-day tags: they drop off at kickoff, and one older than this week's
# Tuesday is last week's designation.
GAME_TAGS = ["QUESTIONABLE", "DOUBTFUL", "DTD", "OUT"]

# Sleeper / ESPN designations -> status key ("" = playing).
STATUS_IN = {
    "OUT": "OUT", "IR": "IR", "INJURY_RESERVE": "IR", "PUP": "PUP", "SUS": "SUS",
    "SUSPENSION": "SUS", "NA": "NA", "DNR": "NA", "DOUBTFUL": "DOUBTFUL",
    "QUESTIONABLE": "QUESTIONABLE", "DAY_TO_DAY": "DTD", "COV": "OUT",
}

LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png",
    "SEA": "SEA.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
    "NFL": "NFL.png",
}
ALIAS = {"WAS": "WSH", "JAC": "JAX", "LA": "LAR", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# ESPN proTeamId -> abbreviation (stable ids).
ESPN_PRO = {1: "ATL", 2: "BUF", 3: "CHI", 4: "CIN", 5: "CLE", 6: "DAL", 7: "DEN", 8: "DET",
            9: "GB", 10: "TEN", 11: "IND", 12: "KC", 13: "LV", 14: "LAR", 15: "MIA", 16: "MIN",
            17: "NE", 18: "NO", 19: "NYG", 20: "NYJ", 21: "PHI", 22: "ARI", 23: "PIT", 24: "LAC",
            25: "SF", 26: "SEA", 27: "TB", 28: "WSH", 29: "CAR", 30: "JAX", 33: "BAL", 34: "HOU"}
ESPN_POS = {1: "QB", 2: "RB", 3: "WR", 4: "TE", 5: "K", 7: "P", 8: "DL", 9: "DT", 10: "DE",
            11: "LB", 12: "CB", 13: "S", 14: "HC", 16: "DEF"}

# Lineup slots as each platform names them. Sleeper roster_positions ->
# the label Sleeper's own lineup shows; ESPN lineupSlotId -> ESPN's.
SL_SLOT = {"QB": "QB", "RB": "RB", "WR": "WR", "TE": "TE", "K": "K", "DEF": "DEF",
           "FLEX": "FLEX", "SUPER_FLEX": "SF", "WRRB_FLEX": "W/R", "REC_FLEX": "W/T",
           "IDP_FLEX": "IDP", "DL": "DL", "LB": "LB", "DB": "DB", "DE": "DE", "DT": "DT",
           "CB": "CB", "S": "S", "P": "P"}
ESPN_SLOT = {0: "QB", 1: "TQB", 2: "RB", 3: "R/W", 4: "WR", 5: "W/T", 6: "TE", 7: "OP",
             8: "DT", 9: "DE", 10: "LB", 11: "DL", 12: "CB", 13: "S", 14: "DB", 15: "DP",
             16: "D/ST", 17: "K", 18: "P", 19: "HC", 23: "FLEX"}

# ESPN lineupSlotId -> position in ESPN's lineup display (page 1 order).
ESPN_SLOT_ORDER = {0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 6, 6: 5, 23: 7, 7: 8, 11: 10, 8: 11, 9: 12,
                   10: 13, 14: 14, 12: 15, 13: 16, 15: 17, 16: 20, 17: 21, 18: 22, 19: 23}

POS_COLOR = {"QB": "#FF6F9C", "RB": "#2EE6C8", "WR": "#5CB8FF", "TE": "#FFB45C",
             "K": "#C9A0FF", "DEF": "#9AA3B2", "DL": "#D9B38C", "LB": "#D9B38C", "DB": "#D9B38C"}

# ------------------------------------------------------------ pixel art
# 15 x 25 body figure, front view, filled. One letter per region so any of
# them can light up: H head, N neck, S shoulders, C chest, B belly / back,
# A upper arm, E elbow, F forearm, W wrist, P hand, G hip and groin,
# T thigh, K knee, L shin / calf, X ankle, O foot.
BODY = """
......HHH......
.....HHHHH.....
.....HHHHH.....
.....HHHHH.....
......HHH......
.......N.......
...SSSSSSSSS...
.SSSCCCCCCCSSS.
.AA.CCCCCCC.AA.
.AA.CCCCCCC.AA.
.AA.CCCCCCC.AA.
.EE.BBBBBBB.EE.
.FF.BBBBBBB.FF.
.FF.BBBBBBB.FF.
.FF.GGGGGGG.FF.
.WW.GGGGGGG.WW.
.PP.TTT.TTT.PP.
....TTT.TTT....
....TTT.TTT....
....KKK.KKK....
....LLL.LLL....
....LLL.LLL....
....LLL.LLL....
....XXX.XXX....
...OOOO.OOOO...
"""
REGIONS = "HNSCBAEFWPGTKLXO"
ROWS = BODY.strip().split("\n")

# Body-part words -> regions; first match wins, so longer words that contain
# a shorter one come first ("forearm" before "arm").
PARTS = [
    ["concussion", "H"], ["head", "H"], ["face", "H"], ["eye", "H"], ["jaw", "H"],
    ["neck", "N"], ["stinger", "N"],
    ["shoulder", "S"], ["collarbone", "S"], ["clavicle", "S"], ["ac joint", "S"],
    ["upper body", "SCBA"], ["lower body", "GTKLXO"],
    ["pectoral", "C"], ["chest", "C"], ["rib", "C"], ["sternum", "C"],
    ["oblique", "B"], ["abdom", "B"], ["core", "B"], ["back", "B"], ["spine", "B"],
    ["kidney", "B"], ["illness", "CB"], ["covid", "CB"],
    ["forearm", "F"], ["elbow", "E"], ["wrist", "W"],
    ["bicep", "A"], ["tricep", "A"], ["arm", "A"],
    ["thumb", "P"], ["finger", "P"], ["hand", "P"],
    ["hamstring", "T"], ["quad", "T"], ["thigh", "T"],
    ["groin", "G"], ["hip", "G"], ["glute", "G"], ["pelvis", "G"], ["adductor", "G"],
    ["knee", "K"], ["acl", "K"], ["mcl", "K"], ["meniscus", "K"], ["patella", "K"],
    ["lower leg", "L"], ["calf", "L"], ["shin", "L"], ["fibula", "L"], ["tibia", "L"], ["leg", "L"],
    ["achilles", "X"], ["ankle", "X"],
    ["foot", "O"], ["toe", "O"], ["heel", "O"], ["plantar", "O"], ["lisfranc", "O"],
]

# Halo round a lit part: the status colour at about half.
HALO = {C_OUT: "#7A1616", C_DOUBT: "#7A3A0E", C_QUES: "#7A5C00", GOOD: "#16703A"}

# 7 x 7 mini jersey for lineups of 13+ stalls (the big one is JERSEY_L, page 1).
JERSEY_S = """
.XX.XX.
XXXXXXX
XXXXXXX
X.XXX.X
..XXX..
..XXX..
..XXX..
"""

def lit_regions(part):
    t = str(part).lower()
    for p in PARTS:
        if t.find(p[0]) >= 0:
            return p[1]
    return ""

def glow_sprite(lit):
    """The figure with every empty pixel beside a lit part turned into 'h'."""
    if lit == "":
        return BODY
    h = len(ROWS)
    out = []
    for y in range(h):
        row = ROWS[y]
        line = ""
        for x in range(len(row)):
            ch = row[x]
            if ch == ".":
                for dy in [-1, 0, 1]:
                    for dx in [-1, 0, 1]:
                        yy = y + dy
                        xx = x + dx
                        if ch == "." and yy >= 0 and yy < h and xx >= 0 and xx < len(ROWS[yy]):
                            n = ROWS[yy][xx]
                            if n != "." and lit.find(n) >= 0:
                                ch = "h"
            line += ch
        out.append(line)
    return "\n".join(out)

def board(c):
    """The clipboard, x 6..33: wooden board, dark chart paper held by a
    steel clip across the top edge."""
    x0 = BOARD_X
    x1 = BOARD_X + 27
    c.rect(x0, 2, x1, 31, fill = WOOD)
    c.rect(x0, 31, x1, 31, fill = WOOD_DK)
    c.rect(x0 + 2, 4, x1 - 2, 29, fill = PAPER)
    # the clip: a wide steel jaw over the paper's top edge, a lever above it
    c.rect(x0 + 7, 1, x1 - 7, 3, fill = STEEL)
    c.rect(x0 + 7, 4, x1 - 7, 4, fill = STEEL_DK)
    c.rect(x0 + 10, 0, x1 - 10, 0, fill = STEEL_DK)

def pips(c, idx, n):
    """Frame counter as brass studs along the board's bottom edge (y 30..31):
    3 px studs up to 7 frames, 2 px up to 9, 1 px up to 12; the lit one is
    this frame, the rest are dark knots in the wood."""
    if n <= 1:
        return
    k = n if n <= 12 else 12
    w = 3 if k <= 7 else (2 if k <= 9 else 1)
    pitch = w + 1
    span = k * pitch - 1
    x = BOARD_X + (28 - span) // 2
    cur = idx if idx < k else k - 1
    for i in range(k):
        c.rect(x, 30, x + w - 1, 31, fill = BRASS if i == cur else WOOD_DK)
        x += pitch

def clipboard(c, part, col, mode = "injury"):
    """Board + figure. mode "injury" lights `part` in `col`; "healthy" lights
    everything in `col`; "plain" draws the figure in `col` (grey states)."""
    board(c)
    fx = BOARD_X + 7
    fy = 5
    lit = REGIONS if mode == "healthy" else ("" if mode == "plain" else lit_regions(part))
    leg = {"h": HALO.get(col, SLATE)}
    for r in REGIONS.elems():
        if mode == "plain":
            leg[r] = col
        else:
            leg[r] = col if lit.find(r) >= 0 else FIGURE
    c.sprite(glow_sprite("" if mode != "injury" else lit), fx, fy, legend = leg)
    if lit == "" and mode == "injury":
        # undisclosed: a "?" over the chest, nothing to point at
        c.text_stroke("?", fx + 5, fy + 8, font = "5x7", color = col, stroke = "black")

def calendar(c, week):
    """Bye week: the clipboard holds a calendar page, sky-blue header with
    BYE, the week number big below."""
    board(c)
    x0 = BOARD_X + 4
    x1 = BOARD_X + 23
    c.rect(x0, 8, x1, 29, fill = "#DCE3EE")
    c.rect(x0, 8, x1, 14, fill = C_BYE)
    for k in [x0 + 4, x1 - 4]:
        c.rect(k, 7, k, 9, fill = STEEL_DK)
    c.text("BYE", (x0 + x1 + 1) // 2, 9, font = "4x5", color = "black", align = "center")
    w = str(week)
    f = "6x8" if len(w) <= 2 else "4x5"
    c.text(w, (x0 + x1 + 1) // 2, 18, font = f, color = "#1A2233", align = "center")

# ------------------------------------------------------------- text tools
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k].rstrip(" -.")
    return ""

def fit(c, text, fonts, maxw):
    t = str(text)
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            return [t, f]
    f = fonts[len(fonts) - 1]
    return [clip(c, t, f, maxw), f]

def wrap2(c, text, font, maxw):
    """One line, or two split at a word; the second hard-clipped."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return [t]
    words = t.split(" ")
    for k in range(len(words) - 1, 0, -1):
        a = " ".join(words[:k])
        if c.text_width(a, font) <= maxw:
            return [a, clip(c, " ".join(words[k:]), font, maxw)]
    return [clip(c, t, font, maxw)]

INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}
SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]
PARTICLE = ["ST.", "ST", "DE", "DI", "DA", "DU", "LA", "LE", "VAN", "VON", "DEL", "DOS"]

def name_forms(full):
    """[full, initial + last, last, last without suffix]."""
    parts = [p for p in full.split(" ") if p != ""]
    if len(parts) < 2:
        return [full, full, full, full, full.split("-")[0]]
    end = len(parts)
    suffix = ""
    if end >= 3 and parts[end - 1] in SUFFIX:
        suffix = parts[end - 1]
        end -= 1
    start = end - 1
    if start >= 2 and parts[start - 1] in PARTICLE:
        start -= 1
    bare = " ".join(parts[start:end])
    last = bare + (" " + suffix if suffix != "" else "")
    return [full, parts[0][:1] + ". " + last, last, bare, bare.split("-")[0]]

WORD_GAP = 4      # big faces: a space is a full 10 px cell; set words 5 px apart

def dot_w(font):
    return 2 if font in ["10x16", "9x12", "8x10"] else 1

def words_w(c, t, font):
    """Width with the big faces' full-cell space set to a 5 px gap."""
    if dot_w(font) == 1 or " " not in t:
        return c.text_width(t, font)
    ws = [p for p in t.split(" ") if p != ""]
    w = 0
    for i in range(len(ws)):
        w += c.text_width(ws[i], font) + (1 + WORD_GAP if i > 0 else 0)
    return w

def words_text(c, t, x, y, font, col):
    if dot_w(font) == 1 or " " not in t:
        c.text(t, x, y, font = font, color = col)
        return x + c.text_width(t, font)
    ws = [p for p in t.split(" ") if p != ""]
    for i in range(len(ws)):
        if i > 0:
            x += 1 + WORD_GAP
        c.text(ws[i], x, y, font = font, color = col)
        x += c.text_width(ws[i], font)
    return x

def tight_w(c, text, font):
    """Width with every '.' set tight (the big faces give '.' a full cell)."""
    pieces = str(text).split(".")
    dw = dot_w(font)
    w = 0
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            w += 1 + dw + (dw + 3 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        w += words_w(c, t, font) if t != "" else 0
    return w - (1 if str(text).endswith(".") else 0)

def tight_text(c, text, x, y, font, col):
    pieces = str(text).split(".")
    dw = dot_w(font)
    base = y + INKH[font] - 1
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            c.rect(x + 1, base - dw + 1, x + dw, base, fill = col)
            x += 1 + dw + (dw + 3 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        if t != "":
            x = words_text(c, t, x, y, font, col)

def pick_name(c, forms, maxw):
    order = [[0, "10x16"], [1, "10x16"], [2, "10x16"], [0, "9x12"], [1, "9x12"], [2, "9x12"],
             [3, "10x16"], [3, "9x12"], [1, "8x10"], [2, "8x10"], [3, "8x10"],
             [2, "6x8"], [3, "6x8"], [4, "10x16"], [4, "9x12"], [4, "8x10"], [4, "6x8"], [3, "5x7"]]
    for o in order:
        if tight_w(c, forms[o[0]], o[1]) <= maxw:
            return o
    return [-1, "5x7"]

HEXD = "0123456789abcdef"

def ink_for(fill):
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def dim_hex(h, pct):
    """'#RRGGBB' at pct percent brightness, as hex (color.dim returns a
    tuple, which can't key HALO or feed ink_for)."""
    t = str(h).lower()
    v = [(HEXD.find(t[i]) * 16 + HEXD.find(t[i + 1])) * pct // 100 for i in [1, 3, 5]]
    return "#" + "".join([HEXD[x // 16] + HEXD[x % 16] for x in v])

def pill(c, word, fill, x, y):
    c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")

def pill_w(c, word):
    return c.text_width(word, "4x5") + 4

# ------------------------------------------------------------ dates / news
def et_shift(u):
    """Seconds US Eastern runs behind UTC at unix time u (EDT 4 h, EST 5 h -
    the season crosses the November change), from the adapter's rule."""
    return -fl_et_offset(u) * 3600

def et_day(ctx):
    u = ctx.now.unix
    return (u - et_shift(u)) // 86400

def week_start(ctx):
    """Unix time of this NFL week's Tuesday 00:00 ET - injury tags older than
    that are last week's (the new week's first report is Wednesday's)."""
    u = ctx.now.unix
    d = (u - et_shift(u)) // 86400
    wd = (d + 3) % 7                     # Mon = 0
    tue = d - (wd - 1) % 7
    return tue * 86400 + et_shift(u)

def kick_tail(kick, now, done = False):
    """[text, colour] for the deadline after the opponent: Sunday games give
    the ET kickoff ('1:00', '4:25', '9:30A'), prime time and odd days a tag
    (SNF, MNF, TNF, SAT); a game on is LIVE, one over is FINAL. Amber inside
    the last 24 hours before kickoff."""
    if kick <= 0:
        return ["", INK]
    if now >= kick:
        return ["FINAL" if done or now >= kick + 4 * 3600 else "LIVE", DIM]
    et = kick - et_shift(kick)
    wd = (et // 86400 + 3) % 7
    hh = (et % 86400) // 3600
    mm = (et % 3600) // 60
    if wd == 6 and hh < 19:
        h12 = hh % 12
        t = str(h12 if h12 != 0 else 12) + ":" + ("0" if mm < 10 else "") + str(mm) + ("A" if hh < 12 else "")
    elif wd == 6:
        t = "SNF"
    elif wd == 0:
        t = "MNF"
    elif wd == 3:
        t = "TNF"
    else:
        t = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][wd]
    return [t, AMBER if kick - now <= 86400 else INK]

def kick_label(kick):
    """'SUN 1:00' / 'MON 8:15' / 'SUN 9:30A': the day and ET kickoff."""
    et = kick - et_shift(kick)
    wd = (et // 86400 + 3) % 7
    hh = (et % 86400) // 3600
    mm = (et % 3600) // 60
    h12 = hh % 12
    return ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][wd] + " " + str(h12 if h12 != 0 else 12) +         ":" + ("0" if mm < 10 else "") + str(mm) + ("A" if hh < 12 else "")

def day_tag_days(days):
    """Game day (days since 1970, ET) -> SUN / MNF / TNF / SAT, when the
    kickoff time is unknown."""
    if days < 0:
        return ""
    return ["SUN", "MNF", "TUE", "WED", "TNF", "FRI", "SAT"][(days + 4) % 7]

def ago(now_unix, ms):
    """News age from a ms timestamp: '40M' / '3H' / '2D', or ''."""
    if type(ms) not in ["int", "float"] or ms <= 0:
        return ""
    s = now_unix - int(ms) // 1000
    if s < 0:
        s = 0
    if s < 3600:
        return str(s // 60 if s >= 60 else 1) + "M"
    if s < 48 * 3600:
        return str(s // 3600) + "H"
    return str(s // 86400) + "D"

def ymd_days(s):
    p = str(s).split("-")
    if len(p) != 3 or not (p[0].isdigit() and p[1].isdigit() and p[2].isdigit()):
        return -1
    return fl_days(int(p[0]), int(p[1]), int(p[2]))

def base_item():
    return {"pid": "", "name": "PLAYER", "pos": "", "team": "", "status": "", "tag": "",
            "slot": "BENCH", "slotlab": "", "part": "", "note": "", "opp": "", "pre": "",
            "kick": -1, "gday": -1, "dayt": "", "played": False, "bye": False, "proj": 0.0,
            "news": 0, "stale": False, "cover": -1, "espn_id": "", "outlook": "", "tcol": "", "done": False}

def set_game(it, g, now, today):
    """Club schedule entry {bye, opp, home, kick} or a Sleeper feed game
    {opp, date} -> the item's game fields."""
    if g == None:
        return
    if g.get("bye", False):
        it["bye"] = True
        return
    opp = g.get("opp", "")
    if opp == "":
        return
    it["opp"] = opp
    home = g.get("home", None)
    it["pre"] = "" if home == None else ("VS " if home else "@")
    k = g.get("kick", -1)
    if k > 0:
        it["kick"] = k
        it["done"] = g.get("done", False)
        it["played"] = now >= k
        it["gday"] = (k - et_shift(k)) // 86400
    else:
        it["gday"] = ymd_days(g.get("date", ""))
        it["dayt"] = day_tag_days(it["gday"])
        it["played"] = it["gday"] >= 0 and it["gday"] < today

# ------------------------------------------------------------ schedule
def club_games(ctx, lg, week):
    """The adapter's NFL slate (fl_nfl_games: ESPN's keyless schedule, +1
    call) in this app's club codes: club -> {bye, opp, home, kick, done}.
    {} when it can't be had (no budget left, network) - callers fall back
    to their own feed."""
    out = {}
    for k, v in fl_nfl_games(ctx, lg, week).items():
        ko = int(fl_num(v.get("kickoff_unix", 0), 0))
        out[ALIAS.get(k, k)] = {"bye": v.get("bye", False), "opp": ALIAS.get(v.get("opp", ""), v.get("opp", "")),
                                "home": v.get("home", None), "kick": ko if ko > 0 else -1,
                                "done": v.get("done", False)}
    return out

# ------------------------------------------------------------------ demo
# The demo roster: made-up players on real clubs, week 6 (MIA's bye).
# Fields: name, pos, club, status, slot, slot label, part, prefix, opp,
# deadline, deadline colour, proj, bench cover, last-week tag.
DEMO_PLAYERS = [
    ["MARCUS HOLLOWAY", "WR", "CIN", "OUT", "START", "WR", "KNEE", "@", "BAL", "4:25", INK, 14.2, 1, False],
    ["TREVON BASKIN", "RB", "DET", "DOUBTFUL", "START", "FLEX", "ANKLE - HIGH SPRAIN", "VS ", "GB", "1:00", INK, 12.8, 2, False],
    ["COLE ANDERSEN", "TE", "KC", "QUESTIONABLE", "START", "TE", "SHOULDER", "@", "LV", "TNF", AMBER, 9.6, 0, False],
    ["DARIUS WEBB", "RB", "SF", "ACT", "IR", "IR", "", "VS ", "ARI", "4:05", INK, 11.4, -1, False],
    ["JALEN PRICE", "WR", "MIA", "BYE", "START", "WR", "", "", "", "", INK, 0.0, 1, False],
    ["NICO SANTANA", "WR", "SEA", "QUESTIONABLE", "BENCH", "BENCH", "KNEE", "@", "LAR", "MNF", INK, 7.1, -1, True],
]
DEMO_LINEUP = [["QB", ""], ["RB", ""], ["RB", ""], ["WR", "OUT"], ["WR", "BYE"],
               ["TE", "QUESTIONABLE"], ["FLEX", "DOUBTFUL"], ["K", ""], ["DEF", ""]]
DEMO_WEEK = 6

def demo_report(lg):
    items = []
    for d in DEMO_PLAYERS:
        it = base_item()
        it.update({"name": d[0], "pos": d[1], "team": d[2], "status": "" if d[3] in ["BYE", "ACT"] else d[3],
                   "tag": "", "slot": d[4], "slotlab": d[5], "part": d[6], "pre": d[7], "opp": d[8],
                   "dayt": d[9], "tcol": d[10], "proj": d[11], "cover": d[12], "stale": d[13],
                   "bye": d[3] == "BYE"})
        items.append(it)
    lineup = [{"lab": x[0], "status": x[1]} for x in DEMO_LINEUP]
    rep = finish_report(items, lineup, DEMO_WEEK, 0, False)
    return rep

# ------------------------------------------------------------ Sleeper roster
def sl_slots(ctx, lg, n):
    """The n starting slots' labels (FLEX, SF, DL...), or [] if unknown."""
    rp = lg["raw"].get("roster_positions", [])       # adapter v2.1, no request
    if type(rp) != "list":
        return []
    out = [SL_SLOT.get(str(p), fl_clean(str(p))[:4]) for p in rp if str(p) not in ["BN", "IR", "TAXI"]]
    return out if len(out) == n else []

def sl_item(ctx, pid, row, pl, slot, lab, lg, games, byes, today):
    """One Sleeper player -> report item (status '' = fine)."""
    it = base_item()
    team = str(fl_d(row, "team", fl_d(pl, "team", "")))
    team = ALIAS.get(team, team)
    pos = str(fl_d(pl, "position", ""))
    if pos == "" and pid.isalpha():
        pos = "DEF"
    name = fl_clean(str(fl_d(pl, "first_name", "")) + " " + str(fl_d(pl, "last_name", "")))
    if pos == "DEF" or name == "":
        name = (team + " DEFENSE") if team != "" else ("PLAYER " + pid)
    part = fl_clean(fl_d(pl, "injury_body_part", ""))
    if part.startswith("NOT INJURY") or part in ["PERSONAL", "REST", "COACHS DECISION", "COACH DECISION"]:
        part = ""
    pj = fl_proj_pts(lg, pid)
    it.update({"pid": pid, "name": name, "pos": pos, "team": team,
               "status": STATUS_IN.get(str(fl_d(pl, "injury_status", "")).upper().strip(), ""),
               "slot": slot, "slotlab": lab, "part": part, "note": fl_clean(fl_d(pl, "injury_notes", "")),
               "proj": pj if pj > 0 else 0.0, "news": fl_num(fl_d(pl, "news_updated", 0))})
    g = games.get(team, None)
    set_game(it, g, ctx.now.unix, today)
    if team in byes and it["opp"] == "":
        it["bye"] = True
    return it

def sleeper_report(ctx, lg):
    me = lg["me"]
    ro = None
    for r in lg["raw"]["rosters"]:
        if fl_d(r, "roster_id", None) == me:
            ro = r
    if ro == None:
        return {"ok": True, "items": [], "lineup": [], "week": lg["week"], "empty": True}
    starters = [str(p) for p in fl_d(ro, "starters", [])]
    reserve = [str(p) for p in fl_d(ro, "reserve", [])]
    taxi = [str(p) for p in fl_d(ro, "taxi", [])]
    players = [str(p) for p in fl_d(ro, "players", [])]
    real = [p for p in starters if p != "0" and p != ""]
    if len(players) == 0 and len(real) == 0:
        cut = int(fl_num(fl_d(fl_d(ro, "settings", {}), "eliminated", 0), 0))
        return {"ok": True, "items": [], "lineup": [], "week": lg["week"], "empty": True, "chopped": cut > 0}

    b = lg["budget"]
    proj = lg["raw"]["proj"]
    if len(proj) == 0:
        proj = fl_sleeper_proj(ctx, b, lg["season"], lg["week"])
        lg["raw"]["proj"] = proj
    # Club -> game from the feed itself: any player of a club with an
    # opponent gives the whole club its game (low-projection rows carry no
    # opponent / date). A club in the feed with no game at all is on bye.
    feed = {}
    seen = {}
    for pid in proj:
        row = proj[pid]
        if type(row) != "dict":
            continue
        t = ALIAS.get(str(fl_d(row, "team", "")), str(fl_d(row, "team", "")))
        if t == "":
            continue
        seen[t] = True
        o = str(fl_d(row, "opponent", ""))
        if o != "" and t not in feed:
            feed[t] = {"opp": ALIAS.get(o, o), "date": str(fl_d(row, "date", ""))}
    byes = {}
    # At most 6 clubs have a bye in any week; a feed with fewer than 20
    # clubs playing is an off-week or an unscheduled one, not 12 byes.
    if not proj.get("_partial", False) and len(feed) >= 20:
        for t in seen:
            if t not in feed:
                byes[t] = True
    # ESPN's schedule adds home/away and the kickoff time (the Sleeper feed
    # has neither); without it the feed's game and day still show.
    games = dict(feed)
    games.update(club_games(ctx, lg, lg["week"]))
    today = et_day(ctx)
    labs = sl_slots(ctx, lg, len(starters))

    items = []
    lineup = []
    done = {}
    order = [[starters[i], "START", i] for i in range(len(starters))] + [[p, "IR", -1] for p in reserve] + \
            [[p, "BENCH", -1] for p in players if p not in starters and p not in reserve and p not in taxi]
    for e in order:
        pid = e[0]
        lab = labs[e[2]] if e[2] >= 0 and e[2] < len(labs) else ""
        if e[1] == "START" and (pid == "0" or pid == ""):
            lineup.append({"lab": lab if lab != "" else "--", "status": "EMPTY"})
            continue
        if pid in done:
            continue
        done[pid] = True
        row = proj.get(pid, None)
        if type(row) != "dict" and e[1] == "START" and b["n"] < FL_MAX_CALLS:
            # a starter the projection feeds don't carry (IDP): one lookup
            r = fl_get(b, FL_SLEEPER_API + "players/nfl/" + pid, ttl = TTL_PLAYER)
            if r["status_code"] == 200 and type(r["json"]) == "dict":
                row = {"team": fl_d(r["json"], "team", ""), "player": r["json"]}
        if type(row) != "dict":
            if e[1] == "START":
                lineup.append({"lab": lab if lab != "" else "?", "status": "UNK"})
            continue
        it = sl_item(ctx, pid, row, fl_d(row, "player", {}), e[1], lab, lg, games, byes, today)
        items.append(it)
        if e[1] == "START":
            lineup.append({"lab": lab if lab != "" else (it["pos"] if it["pos"] != "" else "?"),
                           "status": lineup_status(it, week_start(ctx))})
    return finish_report(items, lineup, lg["week"], week_start(ctx), True)

def lineup_status(it, wk0):
    st = it["status"]
    if st in GAME_TAGS and st != "OUT" and it["played"]:
        st = ""
    if st != "":
        return st
    if it["bye"]:
        return "BYE"
    return ""

def finish_report(items, lineup, week, wk0, live):
    """Keep the players who need a decision, most urgent first: hurt
    starters (worst status first, then projection), IR-slot players who can
    come back (ACTIVATE), starters on bye, then hurt bench players. A game
    tag is old news once his game kicks off; one older than this week's
    Tuesday is flagged LAST WK. Bench cover = healthy bench players at the
    same position whose game is still to come."""
    for it in items:
        if live:
            it["tag"] = it["status"]
            if it["status"] in GAME_TAGS and it["news"] > 0 and it["news"] // 1000 < wk0:
                it["stale"] = True
    out = []
    for it in items:
        st = it["status"]
        if st in ["QUESTIONABLE", "DOUBTFUL", "DTD"] and it["played"]:
            st = ""
        if it["slot"] == "IR":
            if live:
                if st in STILL_IR:
                    continue
                # back from IR (or only questionable): the lineup is locked
                # until he leaves the IR slot
                it["tag"] = st
                st = "ACT"
            elif st == "":
                st = "ACT"
            grp = 1
        elif st != "":
            grp = 0 if it["slot"] == "START" else 3
        elif it["bye"] and it["slot"] == "START":
            grp = 2
            st = "BYE"
        else:
            continue
        it["status"] = st
        it["grp"] = grp
        if live and it["slot"] == "START" and it["pos"] != "":
            it["cover"] = len([x for x in items if x["slot"] == "BENCH" and x["pos"] == it["pos"] and
                               x["tag"] == "" and not x["bye"] and not x["played"] and x["opp"] != ""])
        out.append(it)
    out = sorted(out, key = lambda x: (x["grp"], STATUS[x["status"]][4], -x["proj"]))
    nxt = -1
    for it in items:
        if it["slot"] == "START" and it["kick"] > 0 and not it["played"] and (nxt < 0 or it["kick"] < nxt):
            nxt = it["kick"]
    return {"ok": True, "items": out, "lineup": lineup, "week": week, "next": nxt,
            "empty": len(items) == 0 and len([x for x in lineup if x["status"] != "EMPTY"]) == 0}

# --------------------------------------------------------------- ESPN roster
def espn_report(ctx, lg):
    b = lg["budget"]
    raw = lg["raw"]
    j = raw["json"]
    sp = int(fl_num(fl_d(j, "scoringPeriodId", lg["week"]), lg["week"]))
    base = ESPN_BASE + str(raw["season"]) + "/segments/0/leagues/" + str(raw["league_id"])
    r = fl_get(b, base + "?view=mRoster&forTeamId=" + str(lg["me"]), headers = raw["cookie"], ttl = TTL_ROSTER)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "err": fl_http_err(r, "ESPN")["err"]}
    entries = []
    for t in fl_d(r["json"], "teams", []):
        if fl_d(t, "id", None) == lg["me"]:
            entries = fl_d(fl_d(t, "roster", {}), "entries", [])
    sched = club_games(ctx, lg, sp)
    today = et_day(ctx)
    items = []
    lineup = []
    for e in entries:
        slot_id = int(fl_num(fl_d(e, "lineupSlotId", 20)))
        slot = "BENCH" if slot_id == 20 else ("IR" if slot_id == 21 else "START")
        pe = fl_d(e, "playerPoolEntry", {})
        p = fl_d(pe, "player", {})
        team = ESPN_PRO.get(int(fl_num(fl_d(p, "proTeamId", 0))), "")
        pos = ESPN_POS.get(int(fl_num(fl_d(p, "defaultPositionId", 0))), "")
        name = fl_clean(fl_d(p, "fullName", ""))
        if pos == "DEF":
            name = (team + " DEFENSE") if team != "" else name
        projv = 0.0
        for s in fl_d(p, "stats", []):
            if int(fl_num(fl_d(s, "statSourceId", 0))) == 1 and int(fl_num(fl_d(s, "scoringPeriodId", -1))) == sp:
                projv = fl_num(fl_d(s, "appliedTotal", 0))
        it = base_item()
        it.update({"pid": str(fl_d(p, "id", "")), "name": name if name != "" else "PLAYER", "pos": pos,
                   "team": team, "slot": slot,
                   "status": STATUS_IN.get(str(fl_d(p, "injuryStatus", fl_d(e, "injuryStatus", ""))).upper(), ""),
                   "slotlab": ESPN_SLOT.get(slot_id, pos) if slot == "START" else "",
                   "proj": projv, "news": fl_num(fl_d(p, "lastNewsDate", 0)),
                   "espn_id": str(fl_d(p, "id", "")),
                   "outlook": str(fl_d(fl_d(fl_d(p, "outlooks", {}), "outlooksByWeek", {}), str(sp), ""))})
        set_game(it, sched.get(team, None), ctx.now.unix, today)
        items.append(it)
        if slot == "START":
            lineup.append({"lab": it["slotlab"] if it["slotlab"] != "" else (pos if pos != "" else "?"),
                           "status": lineup_status(it, 0), "ord": ESPN_SLOT_ORDER.get(slot_id, 50 + slot_id)})
    # mRoster lists players in roster order; hang the lockers in ESPN's own
    # lineup order (QB, RB, WR, TE, FLEX, OP, IDP, D/ST, K, P, HC).
    lineup = sorted(lineup, key = lambda s: s["ord"])
    return finish_report(items, lineup, sp, week_start(ctx), True)

def outlook_part(it):
    """ESPN writes 'Nacua (hip) is uncertain...': the first short
    parenthetical in this week's outlook, else the first body word in it."""
    t = it.get("outlook", "")
    chunks = t.split("(")
    for ch in chunks[1:8]:
        e = ch.find(")")
        if e < 0:
            continue
        inner = ch[:e]
        if len(inner) <= 24 and lit_regions(inner) != "":
            return fl_clean(inner)
    low = t.lower()
    best = -1
    word = ""
    for p in PARTS:
        i = low.find(p[0])
        if i >= 0 and (best < 0 or i < best):
            best = i
            word = p[0]
    return fl_clean(word)

def espn_part(lg, it):
    """Body part for the ESPN player on screen: the athlete card's injury
    ('HIP - SORENESS'), else the outlook text."""
    if it["espn_id"] == "" or it["status"] == "BYE" or (it["status"] == "ACT" and it["tag"] == ""):
        return
    r = fl_get(lg["budget"], ESPN_ATHLETE + it["espn_id"], ttl = TTL_CARD)
    if r["status_code"] == 200 and type(r["json"]) == "dict":
        inj = fl_d(fl_d(r["json"], "athlete", {}), "injuries", [])
        if len(inj) > 0:
            d = fl_d(inj[0], "details", {})
            ty = fl_clean(fl_d(d, "type", ""))
            dt = fl_clean(fl_d(d, "detail", ""))
            if ty != "" and ty != "UNDISCLOSED" and ty != "OTHER":
                it["part"] = ty + (" - " + dt if dt != "" and dt != "NOT SPECIFIED" else "")
                return
    it["part"] = outlook_part(it)

# ------------------------------------------------------------------ load
def roster_load(ctx):
    """[league, report] where report is {ok, items, lineup, week, empty}
    or a screen to show instead: {ok False, err [head, sub], ...}."""
    # games = True: the adapter fetches the NFL slate itself, ahead of a
    # followed ID's optional managers refresh once your team has matched.
    lg = fl_load(ctx, projections = True, matchups = False, games = True)
    if not lg["ok"]:
        return [lg, {"ok": False, "err": lg["err"], "mode": "error"}]
    if lg["state"] == "demo":
        return [lg, demo_report(lg)]
    if lg["state"] == "predraft":
        return [lg, {"ok": False, "err": ["DRAFT DAY AHEAD", "YOUR ROSTER FILLS AT THE DRAFT"], "mode": "calm"}]
    if not lg["me_matched"]:
        if fl_inputs(ctx)["team"] == "":
            return [lg, {"ok": False, "err": ["WHICH TEAM IS YOURS?", "ADD YOUR TEAM NAME IN SETTINGS"], "mode": "error"}]
        sub = "OR TRY YOUR SLEEPER USERNAME" if lg["platform"] == "SLEEPER" else "OR TRY YOUR ESPN DISPLAY NAME"
        return [lg, {"ok": False, "err": ["TEAM NOT FOUND", sub], "mode": "error"}]
    rep = sleeper_report(ctx, lg) if lg["platform"] == "SLEEPER" else espn_report(ctx, lg)
    if not rep["ok"]:
        rep["mode"] = "error"
        return [lg, rep]
    if rep["empty"]:
        if rep.get("chopped", False):
            return [lg, {"ok": False, "err": ["YOUR TEAM WAS CHOPPED", "GUILLOTINE - NO ROSTER LEFT"], "mode": "calm"}]
        return [lg, {"ok": False, "err": ["NO PLAYERS YET", "YOUR ROSTER IS EMPTY"], "mode": "calm"}]
    return [lg, rep]

# ------------------------------------------------------------ screens
def card(c, head, sub, mode):
    """Error / empty / pre-draft: the clipboard stays (grey for errors),
    the head centred, the sub on up to two 4x5 lines under it, the NFL
    shield on the right. 'ADD YOUR TEAM NAME IN SETTINGS' is 138 px in 4x5
    against a 102 px zone, so subs wrap at a word instead of clipping."""
    c.fill("black")
    clipboard(c, "", GOOD if mode == "calm" else STEEL_DK, "plain")
    c.image(LOGO["NFL"], LOGO_X, 4)
    mid = (TX + TR + 1) // 2
    h = fit(c, head, ["6x8", "5x7", "4x5"], TW)
    lines = wrap2(c, sub, "4x5", TW)
    y = 5 if len(lines) == 2 else 8
    c.text(h[0], mid, y, font = h[1], color = GOOD if mode == "calm" else AMBER, align = "center")
    y += 12 if len(lines) == 2 else 13
    for ln in lines:
        c.text(ln, mid, y, font = "4x5", color = DIM, align = "center")
        y += 7

def healthy(c, lg, rep, now):
    c.fill("black")
    clipboard(c, "", GOOD, "healthy")
    me = fl_team(lg, lg["me"])
    if me != None:
        fl_badge(c, me, R - 21 - 8, 1, 24)
    n = len([x for x in rep["lineup"] if x["status"] not in ["EMPTY", "UNK"]])
    mid = (TX + TR + 1) // 2
    c.text("ROSTER", mid, 3, font = "6x8", color = GOOD, align = "center")
    c.text("HEALTHY", mid, 12, font = "6x8", color = GOOD, align = "center")
    subs = []
    if rep.get("next", -1) > now and n > 0:
        t = kick_label(rep["next"])
        subs += ["ALL " + str(n) + " READY - NEXT " + t, str(n) + " READY - NEXT " + t]
    if n > 0:
        subs += ["ALL " + str(n) + " STARTERS READY", str(n) + " STARTERS READY"]
    subs.append("ALL CLEAR")
    for s in subs:
        if c.text_width(s, "4x5") <= TW:
            c.text(s, mid, 24, font = "4x5", color = DIM, align = "center")
            break
    if lg["state"] == "demo":
        c.text("DEMO", R - 21 - 8 + 11, 27, font = "4x5", color = AMBER, align = "center")

def chips(c, it, col, proj, demo):
    """Status pill (dimmed + LAST WK when the tag predates this week), the
    position pill, the lineup slot; PROJ right. Room runs out -> the status
    word shortens, then the position, PROJ, the slot and LAST WK drop."""
    stv = STATUS[it["status"]]
    pos = it["pos"]
    if it["slot"] == "START":
        lab = it["slotlab"]
        role = "STARTER" if lab == "" or lab == pos or (lab == "D/ST" and pos == "DEF") else lab
    else:
        role = {"BENCH": "BENCH", "IR": "IR SLOT"}[it["slot"]]
    pj = "DEMO" if demo else (fl_fmt1(proj) if proj > 0 else "")
    pieces = {"pos": pos != "", "proj": pj != "", "role": True, "last": it["stale"]}
    drops = [[], ["pos"], ["pos", "proj"], ["pos", "proj", "role"], ["pos", "proj", "role", "last"]]
    if demo:
        drops = [[], ["pos"], ["pos", "role"], ["pos", "role", "last"]]
    pick = None
    for dr in drops:
        for w in [stv[0], stv[1], stv[2]]:
            tot = pill_w(c, w)
            if pieces["last"] and "last" not in dr:
                tot += 2 + c.text_width("LAST WK", "4x5")
            if pieces["pos"] and "pos" not in dr:
                tot += 2 + pill_w(c, pos)
            if "role" not in dr:
                tot += 2 + pill_w(c, role)
            if pieces["proj"] and "proj" not in dr:
                tot += 4 + c.text_width(pj if demo else "PROJ " + pj, "4x5")
            if tot <= TW:
                pick = [w, dr]
                break
        if pick != None:
            break
    if pick == None:
        pick = [stv[2], drops[4]]
    dr = pick[1]
    x = TX
    fill = dim_hex(col, 45) if it["stale"] else col
    pill(c, pick[0], fill, x, 0)
    x += pill_w(c, pick[0]) + 2
    if pieces["last"] and "last" not in dr:
        c.text("LAST WK", x, 1, font = "4x5", color = DIM)
        x += c.text_width("LAST WK", "4x5") + 2
    if pieces["pos"] and "pos" not in dr:
        pill(c, pos, POS_COLOR.get(pos, "#9AA3B2"), x, 0)
        x += pill_w(c, pos) + 2
    if "role" not in dr:
        if it["slot"] == "START":
            pill(c, role, INK, x, 0)
        else:
            c.rect(x, 0, x + pill_w(c, role) - 1, 6, fill = SLATE)
            c.text(role, x + 2, 1, font = "4x5", color = "#C8D0DC")
    if pieces["proj"] and "proj" not in dr:
        vw = c.text_width(pj, "4x5")
        c.text(pj, TR, 1, font = "4x5", color = AMBER if demo else INK, align = "right")
        if not demo:
            c.text("PROJ", TR - vw - 4, 1, font = "4x5", color = DIM, align = "right")

def game_line(c, it, week, now):
    """Under the logo, 40 px: opponent with venue and the deadline, e.g.
    '@DEN 4:25' (40 px in 4x5 - the widest Sunday form); 'VS DEN 4:25' is
    47 px, so it falls to picopixel (38 px), then to the game alone."""
    cx = LOGO_X + 20
    if it["status"] == "BYE" or (it["bye"] and it["opp"] == ""):
        for g in ["BYE WK " + str(week), "BYE"]:
            if c.text_width(g, "4x5") <= 40:
                c.text(g, cx, 26, font = "4x5", color = C_BYE, align = "center")
                return
    if it["opp"] == "":
        if it["team"] == "":
            c.text("FREE AGENT" if c.text_width("FREE AGENT", "4x5") <= 40 else "FA", cx, 26,
                   font = "4x5", color = DIM, align = "center")
        return
    head = it["pre"] + it["opp"]
    tail = [it["dayt"], it["tcol"] if it["tcol"] != "" else INK]
    if it["kick"] > 0:
        tail = kick_tail(it["kick"], now, it["done"])
    tries = [[tail[0], "4x5"], [tail[0], "picopixel"]]
    if tail[0] != "":
        tries.append(["", "4x5"])       # 'VS NYG FINAL' won't fit: the game alone
    for t in tries:
        full = head + (" " + t[0] if t[0] != "" else "")
        w = c.text_width(full, t[1])
        if w <= 40:
            x = cx - w // 2
            y = 26 if t[1] == "4x5" else 25
            c.text(head, x, y, font = t[1], color = INK)
            if t[0] != "":
                c.text(t[0], x + w - c.text_width(t[0], t[1]), y, font = t[1], color = tail[1])
            return
    c.text(clip(c, head, "4x5", 40), cx, 26, font = "4x5", color = INK, align = "center")

def footer(c, it, col):
    """y 25..31: the body part in the status colour left, the bench cover
    right in green (grey NO WR ON BENCH when there is none). The part keeps 5x7 as long as it can; the
    cover shortens first, then the part drops to 4x5."""
    if it["status"] == "BYE":
        body = ["NO GAME THIS WEEK", "NO GAME"]
        bcol = C_BYE
    elif it["status"] == "ACT":
        p = it["part"]
        body = ([p, p[:p.find(" - ")]] if p.find(" - ") > 0 else [p]) if p != "" and it["tag"] != "" else []
        body += ["CLEARED - MOVE OFF IR", "OFF IR - START HIM", "MOVE OFF IR"]
        bcol = col if it["tag"] == "" else STATUS.get(it["tag"], STATUS["QUESTIONABLE"])[3]
    else:
        p = it["part"]
        body = []
        if p == "" and it["status"] == "SUS":
            body = ["SUSPENSION", "SUSP"]
        elif p == "" and it["status"] == "NA":
            body = ["NOT ACTIVE", "INACTIVE"]
        elif p != "":
            body.append(p)
            if p.find(" - ") > 0:
                body.append(p[:p.find(" - ")])
        else:
            if it["note"] != "":
                body.append(it["note"])
            body += ["UNDISCLOSED", "UNDISC"]
        bcol = col
    covers = []
    ccol = GOOD
    if it["cover"] > 0:
        n = str(it["cover"])
        covers = [n + " " + it["pos"] + " READY ON BENCH", n + " " + it["pos"] + " ON BENCH",
                  n + " ON BENCH"]
    elif it["cover"] == 0:
        covers = ["NO " + it["pos"] + " ON BENCH", "NO BENCH " + it["pos"]]
        ccol = DIM
    tries = []
    for f in ["5x7", "4x5"]:
        for cv in covers:
            tries.append([f, cv])
    tries += [["5x7", ""], ["4x5", ""]]
    for t in tries:
        cw = c.text_width(t[1], "4x5") + 6 if t[1] != "" else 0
        for bt in body:
            if c.text_width(bt, t[0]) <= TW - cw:
                c.text(bt, TX, 25 if t[0] == "5x7" else 27, font = t[0], color = bcol)
                if t[1] != "":
                    c.text(t[1], TR, 27, font = "4x5", color = ccol, align = "right")
                return
    c.text(clip(c, body[len(body) - 1], "4x5", TW), TX, 27, font = "4x5", color = bcol)

def report(c, ctx):
    got = roster_load(ctx)
    lg = got[0]
    rep = got[1]
    if not rep["ok"]:
        card(c, rep["err"][0], rep["err"][1], rep.get("mode", "error"))
        return
    items = rep["items"]
    now = ctx.now.unix
    if len(items) == 0:
        healthy(c, lg, rep, now)
        return
    idx = (now // 300) % len(items)
    demo = lg["state"] == "demo"
    if demo:
        idx = 0 if now % 3600 < 300 else idx
    it = items[idx]
    if not demo and lg["platform"] == "ESPN":
        espn_part(lg, it)
    stv = STATUS[it["status"]]
    col = stv[3]
    c.fill("black")

    # Left: the clipboard (calendar on a bye), frame pips on its base.
    if it["status"] == "BYE":
        calendar(c, rep["week"])
    elif it["status"] == "ACT":
        if it["tag"] != "" and it["part"] != "":
            clipboard(c, it["part"], STATUS.get(it["tag"], STATUS["QUESTIONABLE"])[3])
        else:
            clipboard(c, "", GOOD, "healthy")
    elif it["status"] in ["SUS", "NA"] and it["part"] == "":
        clipboard(c, "", FIGURE, "plain")     # not an injury: nothing to light
    else:
        clipboard(c, it["part"], dim_hex(col, 60) if it["stale"] else col)
    pips(c, idx, len(items))

    # Right: club logo, the game and its deadline under it.
    team = it["team"] if it["team"] in LOGO else "NFL"
    c.image(LOGO[team], LOGO_X, 0)
    game_line(c, it, rep["week"], now)

    chips(c, it, col, it["proj"], demo)

    # Hero: the name, in the band y 8..22.
    forms = name_forms(it["name"])
    nm = pick_name(c, forms, TW)
    ny = 8 + (15 - INKH[nm[1]]) // 2
    if nm[0] < 0:
        c.text(clip(c, forms[3], "5x7", TW), TX, ny, font = "5x7", color = INK)
    else:
        tight_text(c, forms[nm[0]], TX, ny, nm[1], INK)

    footer(c, it, col)

# ------------------------------------------------------------ page 2
def team_name(c, full, maxw):
    """Full team name in 5x7 or 4x5, else its leading whole words, else a
    hard clip, never ending on THE / OF / AND ('FOURTH AND LONG' -> 'FOURTH')."""
    got = fit(c, full, ["5x7", "4x5"], maxw)
    if got[0] == full:
        return got
    words = full.split(" ")
    for k in range(len(words) - 1, 0, -1):
        if words[k - 1] in ["THE", "A", "AN", "OF", "AND", "&", "-"] and k > 1:
            continue                  # never end on a dangling word
        part = " ".join(words[:k])
        for f in ["5x7", "4x5"]:
            if c.text_width(part, f) <= maxw:
                return [part, f]
    return got

# Nameplates are 1 px narrower than a stall: 'FLEX' is 19 px in 4x5.
LAB_SHORT = {"FLEX": "FLX", "D/ST": "DST", "W/R": "WR", "W/T": "WT", "R/W": "RW", "TQB": "QB"}

# Locker-room palette.
LOCKER_IN = "#10151F"     # stall interior
LOCKER_RIM = "#5E6878"    # steel dividers
PLATE = "#AEB8C6"         # a ready starter's nameplate (brushed steel)
PLATE_OFF = "#3A4356"     # an empty / unknown stall's plate
BAR = "#8792A3"           # the hanging bar in each stall
CLEAT = "#6A7488"
BENCH = "#6B4424"
BENCH_HI = "#9A6636"
BENCH_DK = "#2E1C0E"

# 13 x 13 jersey (big stalls): the chest (x 3..9, rows 5..12) holds the mark.
JERSEY_L = """
..XXX...XXX..
.XXXXX.XXXXX.
XXXXXXXXXXXXX
XXXXXXXXXXXXX
XXX.XXXXX.XXX
...XXXXXXX...
...XXXXXXX...
...XXXXXXX...
...XXXXXXX...
...XXXXXXX...
...XXXXXXX...
...XXXXXXX...
...XXXXXXX...
"""
# A pair of cleats on the stall floor.
CLEATS = """
XX..XX.
XXX.XXX
"""

def jersey_color(st):
    if st == "":
        return GOOD
    if st == "EMPTY":
        return SLATE
    if st == "UNK":
        return C_UNK
    return STATUS[st][3]

def stall(c, x, pitch, plate):
    """One locker stall with its left divider at x: the steel divider,
    the nameplate across the top (y 0..6), a dim interior and the
    hanging bar at y 7. The bank's closing divider is the caller's."""
    c.rect(x, 0, x, 24, fill = LOCKER_RIM)
    c.rect(x + 1, 8, x + pitch - 1, 24, fill = LOCKER_IN)
    c.rect(x + 1, 0, x + pitch - 1, 6, fill = plate)
    c.rect(x + 1, 7, x + pitch - 1, 7, fill = BAR)

def plate_label(c, lab, cx, room, ink):
    """The slot name centred on its plate: the league's name, its short
    form, then picopixel, then a clean clip - never wider than the plate."""
    short = LAB_SHORT.get(lab, lab)
    got = None
    for t in [[lab, "4x5"], [short, "4x5"], [lab, "picopixel"], [short, "picopixel"]]:
        if got == None and c.text_width(t[0], t[1]) <= room:
            got = t
    if got == None:
        got = [clip(c, short, "picopixel", room), "picopixel"]
    if got[0] == "":
        return
    c.text(got[0], cx, 1, font = got[1], color = ink, align = "center")

def chest_mark(c, s, x, y, col):
    """Big jersey chest: the status letter (X out, IR, D, ?, B...) in the
    jersey's ink, or a tick for a starter who is good to go."""
    st = s["status"]
    letter = "?" if st == "UNK" else ("" if st in ["", "EMPTY"] else STATUS[st][5])
    if letter != "":
        c.text(letter, x + 6, y + 6, font = "4x5", color = ink_for(col), align = "center")
    elif st == "":
        for p in [[4, 8], [5, 9], [6, 8], [7, 7], [8, 6]]:
            c.pixel(x + p[0], y + p[1], "black")

def bench(c, x0, x1):
    """The locker-room bench along the bottom, y 25..31: a lit top edge,
    the plank, a dark underside with two legs."""
    c.rect(x0, 25, x1, 25, fill = BENCH_HI)
    c.rect(x0, 26, x1, 30, fill = BENCH)
    c.rect(x0, 31, x1, 31, fill = BENCH_DK)
    for lx in [x0 + 6, x1 - 7]:
        c.rect(lx, 31, lx + 1, 31, fill = BENCH_HI)

def locker_card(c, head, sub, mode):
    """Error / empty / pre-draft on page 1: the locker room with nobody
    in it - two empty stalls either side (plates grey for errors, green
    for calm states) on their benches, the head and the wrapped sub in the
    aisle between them."""
    c.fill("black")
    pl = GOOD if mode == "calm" else PLATE_OFF
    for x in [L, L + 14, R - 28, R - 14]:
        stall(c, x, 14, pl)
        c.pixel(x + 7, 8, STEEL)          # an empty hook
        c.sprite(CLEATS, x + 4, 23, legend = {"X": CLEAT})
    for x in [L + 28, R]:
        c.rect(x, 0, x, 24, fill = LOCKER_RIM)
    bench(c, L, L + 28)
    bench(c, R - 28, R)
    x0 = L + 31
    x1 = R - 31
    w = x1 - x0 + 1
    mid = (x0 + x1 + 1) // 2
    h = fit(c, head, ["6x8", "5x7", "4x5"], w)
    lines = wrap2(c, sub, "4x5", w)
    y = 5 if len(lines) == 2 else 8
    c.text(h[0], mid, y, font = h[1], color = GOOD if mode == "calm" else AMBER, align = "center")
    y += 12 if len(lines) == 2 else 13
    for ln in lines:
        c.text(ln, mid, y, font = "4x5", color = DIM, align = "center")
        y += 7

def lineup(c, ctx):
    """Page 1, the locker room: one stall per starting slot in the league's
    lineup order. Each stall has the slot's nameplate on top (steel for a
    starter who is good to go, the status colour for one who is hurt or on
    bye, so trouble lights up along the top row), the jersey on its hanger
    in the status colour with the chest mark, cleats on the floor. Your
    crest hangs at the far end (up to 10 stalls); the bench along the
    bottom carries your team name and the READY count."""
    got = roster_load(ctx)
    lg = got[0]
    rep = got[1]
    if not rep["ok"]:
        locker_card(c, rep["err"][0], rep["err"][1], rep.get("mode", "error"))
        return
    slots = rep["lineup"]
    if len(slots) == 0:
        locker_card(c, "NO LINEUP SET", "SET YOUR STARTERS IN THE LEAGUE", "calm")
        return
    c.fill("black")
    me = fl_team(lg, lg["me"])
    n = len(slots)
    crest = me != None and (R - 21 - 3 - L) // n >= 15
    right = (R - 21 - 3) if crest else R
    pitch = (right - L) // n
    if pitch > 19:
        pitch = 19                        # short lineups: stalls stay stalls
    big = pitch >= 14
    span = n * pitch
    gw = span + 1 + (24 if crest else 0)  # bank + closing divider (+ gap + crest)
    x0 = L + (R - L + 1 - gw) // 2
    for i in range(n):
        s = slots[i]
        x = x0 + i * pitch
        st = s["status"]
        col = jersey_color(st)
        hurt = st not in ["", "EMPTY", "UNK"]
        pl = col if hurt else (PLATE_OFF if st in ["EMPTY", "UNK"] else PLATE)
        stall(c, x, pitch, pl)
        plate_label(c, s["lab"], x + 1 + (pitch - 1) // 2, pitch - 3,
                    ink_for(pl) if pl != PLATE_OFF else "#C8D0DC")
        jw = 13 if big else 7
        jx = x + 1 + (pitch - 1 - jw) // 2
        c.pixel(jx + jw // 2, 8, STEEL)       # the hanger hook
        if st == "EMPTY":
            continue                          # an empty stall: just the hook
        if big:
            c.sprite(JERSEY_L, jx, 9, legend = {"X": col})
            chest_mark(c, s, jx, 9, col)
            if pitch >= 16:
                c.sprite(CLEATS, x + 1 + (pitch - 1 - 7) // 2, 23, legend = {"X": CLEAT})
        else:
            c.sprite(JERSEY_S, jx, 10, legend = {"X": col})
            if hurt:
                # narrow stalls: a status tag on the stall floor
                c.rect(jx + 1, 19, jx + jw - 2, 22, fill = col)
    c.rect(x0 + span, 0, x0 + span, 24, fill = LOCKER_RIM)
    if crest:
        fl_badge(c, me, x0 + span + 3, 0, 24)

    # The bench: team name left, READY count right. Readiness counts the
    # slots the feeds cover: a starter nobody could look up (deep IDP) is a
    # grey jersey, never a red "not ready".
    bench(c, L, R)
    known = [s for s in slots if s["status"] not in ["UNK", "EMPTY"]]
    k = len(known)
    ready = len([s for s in known if s["status"] == ""])
    rcol = GOOD if ready == k else (AMBER if ready >= k - 1 else C_OUT)
    rtxt = ("ALL " + str(k) + " READY") if ready == k else (str(ready) + " OF " + str(k) + " READY")
    if k == 0:
        rtxt = "NO STARTERS SET"
        rcol = SLATE
    rw = pill_w(c, rtxt)
    c.badge(rtxt, R - rw + 1, 25, color = ink_for(rcol), bg = rcol, font = "4x5")
    room = R - rw - 2 - (L + 2)
    if lg["state"] == "demo":
        c.text("DEMO", R - rw - 2, 26, font = "4x5", color = AMBER, align = "right")
        room -= c.text_width("DEMO", "4x5") + 4
    if me != None and room > 8:
        nm = team_name(c, me["name"], room)
        c.text(clip(c, nm[0], "4x5", room), L + 2, 26, font = "4x5", color = INK)
