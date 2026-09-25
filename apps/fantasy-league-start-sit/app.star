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
# START / SIT OPTIMIZER
#
# DESIGN. A sideline substitution board for your fantasy lineup.
#
#   swap     page 1, the one move worth the most. The player coming IN on
#            the left under a green up-arrow (START), the player going OUT
#            on the right under a red down-arrow (SIT / BENCH / FILL), each
#            over his NFL club's logo. Under each logo his opponent (@DAL,
#            VS SEA), beside it his kickoff (SUN 1:00); the game that kicks
#            off first carries a gold padlock - that's when the move locks.
#            Centre: the green/red swap arrows, the projected gain (+4.1)
#            and the slot the new man takes (AT FLX). When the move needs a
#            starter to slide over (the new man can't play the benched
#            man's slot) a last line says who: WILSON > WR.
#            No move -> "LINEUP IS OPTIMAL" (gold trophy in confetti); a
#            starter who won't play with nobody to cover -> the red medic
#            cross alert; every game under way -> the gold padlock.
#   lineup   page 2, the lineup card: your crest and name, a meter of your
#            projected total now against the best lineup (the gain in
#            green), the top move's two club logos, every move in a list,
#            and along the bottom one cell per starting slot - bright green
#            the top move, green-capped other changes, red a starter who
#            won't play, grey a locked game, slate IDP (no projections on
#            Sleeper), dark green all fine. More than 12 slots fold the
#            defensive (IDP) slots into one IDP cell.
#
# DATA. The shared fantasy-league adapter (block above, v2, loaded with
# matchups = False - a lineup needs no scores) gives the league, your team,
# and on Sleeper the three projection feeds, priced in the league's own
# scoring by fl_score. On top of it:
#   Sleeper  roster_positions (carried by adapter v2.1, which also turns
#            away a non-NFL league), your roster's
#            starters / bench / IR / taxi, projections by player (names,
#            positions, NFL team, opponent, game date, injury status), and
#            the NFL slate (fl_load games = True: the adapter's
#            fl_nfl_games, ahead of a followed ID's optional managers
#            refresh) for kickoff times, venue (@ / VS), locks and byes.
#            Without it: the opponent and game day come from the projection
#            row (no venue, no time), a player is locked once his game day
#            is over or its earliest kickoff has passed (fl_locked: Sunday
#            1 pm ET), byes are teams with no game in the feed.
#   ESPN     your roster (mRoster&forTeamId, ~245 KB: lineupSlotId,
#            eligibleSlots, lineupLocked, injuryStatus and the projected
#            stat line statSourceId 1 / statSplitTypeId 1 / this week's
#            scoringPeriodId, appliedTotal in league scoring), slot counts
#            from mSettings (in the adapter's call), the NFL slate from
#            fl_nfl_games (proTeamSchedules_wl, ~110 KB).
# Budget: ESPN 3 calls; Sleeper 6 (7 with the slate), an old-season
# Sleeper ID 8 - never more than 8.
#
# THE OPTIMIZER. Locked players and players with no projection stay put.
# Every other slot is refilled by an exact assignment (Hungarian method,
# slots x players): as many slots filled as possible, then the most
# projected points. A starter keeps his place unless someone beats him by
# at least 0.05 (the same 0.05 that decides what counts as a move), and
# keeps his own slot when he stays, so the lineup never reshuffles for
# nothing. Starters who are OUT / IR / suspended / on bye project 0.
# Moves follow the substitution chain: the new man takes slot S; if S's
# old occupant leaves the lineup he is the one to SIT, if he slid to slot
# S2 follow S2's occupant, until someone leaves (or S was empty: FILL).
# So every START fits the slot shown, and the moves' gains add up to the
# difference between the two totals.
# ======================================================================

INK = "#F4F7FF"
DIM = "#6E7A94"
SLATE = "#9AA3B2"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
AMBER = "#FFBF00"
ALARM = "#FF3B30"
GOLD = "#FFC83D"
DEMO_C = "#B88A00"     # the DEMO tag: amber, a step down so it never leads

L = 6
R = 185
LOGO_W = 24
LOGO_H = 18
TX0 = L + LOGO_W + 3       # 33
TX1 = R - LOGO_W - 3       # 158
MID = 96

# page 1 rows
Y_HEAD = 0
Y_NAME = 9
Y_LINE = 18
Y_GAME = 25
Y_LOGO = 3

# 24 x 18 NFL club logos, literal paths (the publish lint can't follow a
# built-up path).
LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png",
    "SEA": "SEA.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
}
ALIAS = {"WAS": "WSH", "JAC": "JAX", "LA": "LAR", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# ESPN proTeamId -> abbreviation (the logo set's names).
ESPN_TEAM = {1: "ATL", 2: "BUF", 3: "CHI", 4: "CIN", 5: "CLE", 6: "DAL", 7: "DEN", 8: "DET",
             9: "GB", 10: "TEN", 11: "IND", 12: "KC", 13: "LV", 14: "LAR", 15: "MIA", 16: "MIN",
             17: "NE", 18: "NO", 19: "NYG", 20: "NYJ", 21: "PHI", 22: "ARI", 23: "PIT", 24: "LAC",
             25: "SF", 26: "SEA", 27: "TB", 28: "WSH", 29: "CAR", 30: "JAX", 33: "BAL", 34: "HOU"}

# Sleeper slot -> [label, positions it takes]
SL_SLOT = {
    "QB": ["QB", ["QB"]], "RB": ["RB", ["RB"]], "WR": ["WR", ["WR"]], "TE": ["TE", ["TE"]],
    "K": ["K", ["K"]], "DEF": ["DEF", ["DEF"]], "DL": ["DL", ["DL"]], "LB": ["LB", ["LB"]],
    "DB": ["DB", ["DB"]], "P": ["P", ["P"]],
    "FLEX": ["FLX", ["RB", "WR", "TE"]], "WRRB_FLEX": ["W/R", ["WR", "RB"]],
    "REC_FLEX": ["W/T", ["WR", "TE"]], "SUPER_FLEX": ["SF", ["QB", "RB", "WR", "TE"]],
    "IDP_FLEX": ["IDP", ["DL", "LB", "DB"]],
}

# ESPN lineupSlotId -> label
ES_SLOT = {0: "QB", 1: "TQB", 2: "RB", 3: "R/W", 4: "WR", 5: "W/T", 6: "TE", 7: "OP", 8: "DT",
           9: "DE", 10: "LB", 11: "DL", 12: "CB", 13: "S", 14: "DB", 15: "DP", 16: "DEF", 17: "K",
           18: "P", 19: "HC", 23: "FLX", 24: "ER"}
ES_POS = {1: "QB", 2: "RB", 3: "WR", 4: "TE", 5: "K", 16: "DEF", 7: "P", 9: "DT", 10: "DE",
          11: "LB", 12: "CB", 13: "S", 14: "HC"}

# defensive-player slots: folded into one IDP cell on a long lineup card
IDP_SLOTS = ["DL", "LB", "DB", "IDP", "DT", "DE", "CB", "S", "DP", "ER"]
# two-letter names for a crowded lineup card (DEF must not read as DE)
STRIP_SHORT = {"FLX": "FX", "DEF": "DF", "TQB": "TQ", "R/W": "RW", "W/R": "WR", "W/T": "WT",
               "IDP": "ID"}

# Injury tags that mean "won't play": the player projects 0.
SL_OUT = {"OUT": "OUT", "IR": "IR", "PUP": "PUP", "SUS": "SUS", "NA": "OUT", "DNR": "OUT", "COV": "OUT"}
ES_OUT = {"OUT": "OUT", "INJURY_RESERVE": "IR", "SUSPENSION": "SUS", "INACTIVE": "OUT"}
SL_WARN = {"QUESTIONABLE": "Q", "DOUBTFUL": "D"}
ES_WARN = {"QUESTIONABLE": "Q", "DOUBTFUL": "D", "DAY_TO_DAY": "Q"}

# optimiser weights (see THE OPTIMIZER above)
W_FILL = 1000.0     # any eligible player beats an empty slot
W_STAY = 0.05       # a healthy starter keeps his place unless beaten by this
W_SAME = 0.001      # ... and keeps his own slot when he stays
W_NOPE = 1000000.0  # not eligible for the slot

# ------------------------------------------------------------ pixel art
UP = """
..X..
.XXX.
XXXXX
"""
DOWN = """
XXXXX
.XXX.
..X..
"""
# the small right-pointing arrow of a hop line (WILSON > WR)
HOP = """
X..
XX.
XXX
XX.
X..
"""
# swap arrows: green points left (into your lineup), red points right (out)
SWAP = """
..G........
.GG........
GGGGGGGGGGG
.GG........
..G.....R..
........RR.
RRRRRRRRRRR
........RR.
........R..
"""
SWAP_LEG = {"G": GOOD, "R": ALARM}

# 5 x 5 padlock: this game kicks off first, the move locks then
PAD = """
.XXX.
X...X
XXXXX
XX.XX
XXXXX
"""

TROPHY = """
..YYYYYYYYYYY..
YYYWYYYYYYYYYYY
Y.YWYYYYYYYYY.Y
Y.YWYYYYYYYYY.Y
Y.YWYYYYYYYYY.Y
.YYYYYYYYYYYYY.
...YYYYYYYYY...
....YYYYYYY....
.....YYYYY.....
......YYY......
......YYY......
.....OOOOO.....
....DDDDDDD....
....DGGGGGD....
....DDDDDDD....
...DDDDDDDDD...
"""
TROPHY_LEG = {"Y": GOLD, "W": "#FFF4C2", "O": "#C98A12", "D": "#7A5A2E", "G": GOOD}

CROSS = """
..RRRRR..
..RWWWR..
..RWWWR..
RRRWWWRRR
RWWWWWWWR
RWWWWWWWR
RRRWWWRRR
..RWWWR..
..RWWWR..
..RRRRR..
"""
CROSS_LEG = {"R": ALARM, "W": "#FFFFFF"}

LOCK = """
..XXXXX..
.XX...XX.
.X.....X.
.X.....X.
YYYYYYYYY
YYYYYYYYY
YYYYKYYYY
YYYKKKYYY
YYYYKYYYY
YYYYKYYYY
YYYYYYYYY
"""
LOCK_LEG = {"X": SLATE, "Y": GOLD, "K": "#5A3E0A"}

# 18 x 16 blank jersey for an empty slot / a player with no NFL team
JERSEY = """
...XXXX....XXXX...
.XXXXXX.XX.XXXXXX.
XXXXXXXX..XXXXXXXX
XXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXX
.XXXXXXXXXXXXXXXX.
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
....XXXXXXXXXX....
"""

PLUS = """
.X.
XXX
.X.
"""

# confetti around the trophy: [x, y, colour]
CONFETTI = [[8, 3, GOOD], [13, 24, GOLD], [30, 5, "#2DB8FF"], [36, 26, GOOD], [4, 15, "#FF5CD6"],
            [44, 9, GOLD], [25, 29, "#FF5CD6"], [40, 18, "#2DB8FF"], [10, 29, GOLD], [47, 2, GOOD],
            [2, 7, GOLD], [50, 23, "#FF5CD6"], [176, 4, GOOD], [170, 13, GOLD], [60, 14, "#2DB8FF"],
            [174, 25, "#FF5CD6"]]

# ------------------------------------------------------------ demo lineup
# [slot, name, pos, team, proj, opp, home, kickoff, order, warn]
DEMO_PLAYERS = [
    ["QB", "J. HURTS", "QB", "PHI", 21.4, "NYG", True, "SUN 1:00", 2, ""],
    ["RB", "B. ROBINSON", "RB", "ATL", 18.9, "CAR", False, "SUN 1:00", 2, ""],
    ["RB", "J. GIBBS", "RB", "DET", 17.6, "GB", True, "SUN 4:25", 3, ""],
    ["WR", "C. KUPP", "WR", "SEA", 10.1, "ARI", True, "SUN 4:05", 3, "Q"],
    ["WR", "G. PICKENS", "WR", "DAL", 13.2, "CHI", False, "SNF 8:20", 4, ""],
    ["TE", "T. KELCE", "TE", "KC", 9.8, "LV", True, "SUN 4:25", 3, ""],
    ["FLEX", "J. WARREN", "RB", "PIT", 11.0, "CIN", False, "SUN 1:00", 2, ""],
    ["K", "B. AUBREY", "K", "DAL", 9.1, "CHI", False, "SNF 8:20", 4, ""],
    ["DEF", "BRONCOS", "DEF", "DEN", 8.4, "LAC", True, "MNF 8:15", 5, ""],
    ["", "J. JEUDY", "WR", "CLE", 14.2, "BAL", False, "SUN 1:00", 2, ""],
    ["", "R. STEVENSON", "RB", "NE", 12.6, "MIA", True, "SUN 1:00", 2, ""],
    ["", "D. KINCAID", "TE", "BUF", 7.2, "NYJ", True, "SUN 1:00", 2, ""],
    ["", "T. HIGGINS", "WR", "CIN", 8.9, "PIT", True, "SUN 1:00", 2, ""],
]

# ------------------------------------------------------------ helpers
def logo_key(team):
    t = str(team).upper()
    t = ALIAS.get(t, t)
    return t if t in LOGO else ""

def short_name(first, last):
    f = fl_clean(first)
    l = fl_clean(last)
    if l == "":
        return f
    if f == "":
        return l
    return f[:1] + ". " + l

SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]

def fit(c, text, fonts, maxw):
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

def name_fit(c, name, maxw):
    """J. SMITH-NJIGBA: full in 5x7 / 4x7 / 3x7, then the surname alone,
    then a clip."""
    fonts = ["5x7", "4x7", "3x7"]
    for f in fonts:
        if c.text_width(name, f) <= maxw:
            return [name, f]
    k = name.find(". ")
    sur = name[k + 2:] if k >= 0 and k <= 2 else name
    for f in fonts:
        if c.text_width(sur, f) <= maxw:
            return [sur, f]
    # HARRISON JR. -> HARRISON before any clipping
    words = sur.split(" ")
    if len(words) > 1 and words[len(words) - 1] in SUFFIX:
        sur = " ".join(words[:len(words) - 1])
    return fit(c, sur, fonts, maxw)

def num_text(c, s, x, y, font, col, align = "left"):
    """A number with a hand-set 1 px dot (the big fonts give '.' a full
    cell). Returns the width drawn."""
    k = s.find(".")
    if k < 0:
        w = c.text_width(s, font)
        c.text(s, x if align == "left" else (x - w + 1 if align == "right" else x - w // 2), y, font = font, color = col)
        return w
    a = s[:k]
    b = s[k + 1:]
    wa = c.text_width(a, font)
    wb = c.text_width(b, font)
    h = {"4x5": 5, "5x7": 7, "6x8": 8, "9x12": 12, "10x16": 16}.get(font, 7)
    dw = 1 if h <= 8 else 2
    w = wa + 1 + dw + 1 + wb
    x0 = x if align == "left" else (x - w + 1 if align == "right" else x - w // 2)
    c.text(a, x0, y, font = font, color = col)
    c.rect(x0 + wa + 1, y + h - dw, x0 + wa + dw, y + h - 1, fill = col)
    c.text(b, x0 + wa + dw + 2, y, font = font, color = col)
    return w

def text_w(c, s, font):
    k = s.find(".")
    if k < 0:
        return c.text_width(s, font)
    h = {"4x5": 5, "5x7": 7, "6x8": 8, "9x12": 12, "10x16": 16}.get(font, 7)
    return c.text_width(s[:k], font) + c.text_width(s[k + 1:], font) + 2 + (1 if h <= 8 else 2)

def gain_text(g):
    return "+" + (str(int(g + 0.5)) if g >= 99.95 else fl_fmt1(g))

def last_name(n):
    k = n.find(". ")
    return n[k + 2:] if k >= 0 and k <= 2 else n

# ------------------------------------------------------------ loading
def nfl_schedule(ctx, lg, week):
    """This week's NFL slate by club from the adapter's fl_nfl_games (ESPN
    proTeamSchedules_wl, one call, cached on lg): opponent, venue, kickoff
    and byes. None when it failed or the budget had no room."""
    g = fl_nfl_games(ctx, lg, week)
    return g if len(g) > 0 else None

def player(pid, name, pos, team, proj, known):
    return {"id": pid, "name": name, "pos": pos, "team": team, "proj": proj, "known": known,
            "locked": False, "tag": "", "warn": "", "elig": [], "opp": "", "home": None,
            "kick": "", "ko": 0}

def sched_status(p, sched, now):
    """[bye, locked] for a player from the NFL slate."""
    t = sched.get(logo_key(p["team"]), sched.get(p["team"], None))
    if t == None:
        return [False, False]
    if t.get("bye", False):
        return [True, False]
    ko = int(fl_num(t.get("kickoff_unix", 0), 0))
    return [False, ko > 0 and now >= ko]

def kick_text(day, ko):
    """SUN 1:00 / SNF 8:20 / MNF 8:15, Eastern."""
    loc = ko + fl_et_offset(ko) * 3600
    h = (loc % 86400) // 3600
    mi = (loc % 3600) // 60
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return (str(day) + " " if str(day) != "" else "") + str(h12) + ":" + ("0" if mi < 10 else "") + str(mi)

def date_day(ds):
    """'2026-09-27' -> 'SUN' (the Sleeper row's ET game date)."""
    parts = str(ds).split("-")
    if len(parts) != 3:
        return ""
    y = int(fl_num(parts[0], 0))
    m = int(fl_num(parts[1], 0))
    d = int(fl_num(parts[2], 0))
    if y == 0 or m == 0 or d == 0:
        return ""
    return FL_DAYS[(fl_days(y, m, d) + 3) % 7]

def game_info(p, sched, row_opp, row_date):
    """Opponent, venue and kickoff for a player: the NFL slate when we have
    it, else the Sleeper projection row's opponent and game day (no venue,
    no time - never guessed)."""
    t = None
    if sched != None:
        t = sched.get(logo_key(p["team"]), sched.get(p["team"], None))
    if t != None and not t.get("bye", False):
        ko = int(fl_num(t.get("kickoff_unix", 0), 0))
        p["opp"] = str(t.get("opp", ""))
        p["home"] = t.get("home", None)
        p["ko"] = ko
        p["kick"] = kick_text(t.get("day", ""), ko) if ko > 0 else ""
    elif str(row_opp) != "":
        p["opp"] = str(row_opp).upper()
        p["kick"] = date_day(row_date)

def sleeper_proj_points(lg, row):
    """A Sleeper projection row's points in this league's own scoring
    (the adapter's fl_score: scoring_settings x the projected stat line).
    The one place projections are priced."""
    return fl_score(lg, fl_d(row, "stats", {}))

def load_sleeper(ctx, lg, obj):
    week = lg["week"]
    proj = {}
    got = lg["raw"].get("proj", {})
    if not got.get("_partial", False):
        for k in got:
            proj[k] = got[k]
    sched = nfl_schedule(ctx, lg, week)
    rpos = fl_d(obj, "roster_positions", []) if obj != None else []
    slots_t = [p for p in rpos if p not in ["BN", "IR", "TAXI"]]
    ro = None
    for r in lg["raw"]["rosters"]:
        if fl_d(r, "roster_id", None) == lg["me"]:
            ro = r
    if ro == None:
        return None
    starters = [str(x) for x in (fl_d(ro, "starters", []) or [])]
    reserve = {}
    for x in (fl_d(ro, "reserve", []) or []) + (fl_d(ro, "taxi", []) or []):
        reserve[str(x)] = True
    if int(fl_num(fl_d(fl_d(ro, "settings", {}), "eliminated", 0), 0)) > 0:
        return {"chopped": True}
    today = fl_et_date(ctx)
    # Each NFL team's game day this week, from any of its players' rows (a
    # player with no projection has no date of his own).
    team_date = {}
    team_opp = {}
    for pid in proj:
        row = proj[pid]
        if type(row) == "dict" and str(fl_d(row, "date", "")) != "":
            k = logo_key(fl_d(row, "team", ""))
            team_date[k] = str(row["date"])
            if str(fl_d(row, "opponent", "")) != "":
                team_opp[k] = str(row["opponent"])
    have_proj = len(proj) > 0

    def mk(pid):
        row = proj.get(pid, None)
        if type(row) != "dict":
            return player(pid, "", "", "", 0.0, False)
        pl = fl_d(row, "player", {})
        pos = str(fl_d(pl, "position", "")).upper()
        team = str(fl_d(row, "team", fl_d(pl, "team", ""))).upper()
        if pos == "DEF":
            nm = fl_clean(fl_d(pl, "last_name", pid))
        else:
            nm = short_name(fl_d(pl, "first_name", ""), fl_d(pl, "last_name", ""))
        p = player(pid, nm, pos, team, sleeper_proj_points(lg, row), True)
        p["elig"] = [str(x).upper() for x in (fl_d(pl, "fantasy_positions", [pos]) or [pos])]
        inj = fl_norm(fl_d(pl, "injury_status", ""))
        p["tag"] = SL_OUT.get(inj, "")
        p["warn"] = SL_WARN.get(inj, "")
        gd = str(fl_d(row, "date", ""))
        if gd == "":
            gd = team_date.get(logo_key(team), "")
        ropp = str(fl_d(row, "opponent", "")) or team_opp.get(logo_key(team), "")
        if sched != None:
            st = sched_status(p, sched, ctx.now.unix)
            if st[0]:
                p["tag"] = "BYE"
            p["locked"] = st[1]
        else:
            if gd == "" and logo_key(team) != "" and len(team_date) >= 20:
                p["tag"] = "BYE"
            # No slate: the game date and the day's earliest usual kickoff
            # (adapter fl_locked - a Sunday 1 pm game locks at 1 pm ET).
            if gd != "" and fl_locked(ctx, lg, "", gd):
                p["locked"] = True
        if p["tag"] != "BYE":
            game_info(p, sched, ropp, gd)
        if p["tag"] != "":
            p["proj"] = 0.0
        return p

    slots = []
    n = len(slots_t) if len(slots_t) > 0 else len(starters)
    for i in range(n):
        occ = starters[i] if i < len(starters) else "0"
        typ = str(slots_t[i]) if i < len(slots_t) else ""
        p = mk(occ) if occ != "0" and occ != "" else None
        if typ == "" and p != None:
            typ = p["pos"]          # no roster_positions: the slot is his position
        sd = SL_SLOT.get(typ, None)
        slots.append({"label": sd[0] if sd != None else typ[:4], "takes": sd[1] if sd != None else [],
                      "cur": p})
    bench = []
    seen = {}
    for s in starters:
        seen[s] = True
    for x in (fl_d(ro, "players", []) or []):
        pid = str(x)
        if seen.get(pid, False) or reserve.get(pid, False):
            continue
        seen[pid] = True
        bench.append(mk(pid))

    def ok_for(slot, p):
        for e in p["elig"]:
            if e in slot["takes"]:
                return True
        return False

    return {"slots": slots, "bench": bench, "ok_for": ok_for, "have_proj": have_proj,
            "sched": sched != None}

def load_espn(ctx, lg):
    b = lg["budget"]
    raw = lg["raw"]
    week = lg["week"]
    j = raw["json"]
    period = int(fl_num(fl_d(j, "scoringPeriodId", week), week))
    r = fl_get(b, FL_ESPN + str(raw["season"]) + "/segments/0/leagues/" + str(raw["league_id"]) +
               "?view=mRoster&forTeamId=" + str(lg["me"]), headers = raw["cookie"], ttl = FL_TTL_LIVE)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"err": r["status_code"]}
    period = int(fl_num(fl_d(r["json"], "scoringPeriodId", period), period))
    entries = []
    for t in fl_d(r["json"], "teams", []):
        if fl_d(t, "id", None) == lg["me"]:
            entries = fl_d(fl_d(t, "roster", {}), "entries", []) or []
    sched = nfl_schedule(ctx, lg, period)
    counts = fl_d(fl_d(fl_d(j, "settings", {}), "rosterSettings", {}), "lineupSlotCounts", {})
    have_proj = False

    def mk(e):
        pe = fl_d(e, "playerPoolEntry", {})
        pl = fl_d(pe, "player", {})
        pos = ES_POS.get(int(fl_num(fl_d(pl, "defaultPositionId", 0))), "")
        team = ESPN_TEAM.get(int(fl_num(fl_d(pl, "proTeamId", 0))), "")
        if pos == "DEF":
            nm = fl_clean(fl_d(pl, "firstName", "")) or fl_clean(fl_d(pl, "fullName", ""))
        else:
            nm = short_name(fl_d(pl, "firstName", ""), fl_d(pl, "lastName", fl_d(pl, "fullName", "")))
        pj = None
        for s in (fl_d(pl, "stats", []) or []):
            if (int(fl_num(fl_d(s, "statSourceId", -1))) == 1 and int(fl_num(fl_d(s, "statSplitTypeId", -1))) == 1 and
                int(fl_num(fl_d(s, "scoringPeriodId", -1))) == period):
                pj = fl_num(fl_d(s, "appliedTotal", 0))
        p = player(str(fl_d(pl, "id", fl_d(e, "playerId", ""))), nm, pos, team, pj if pj != None else 0.0, pj != None)
        p["elig"] = [int(fl_num(x)) for x in (fl_d(pl, "eligibleSlots", []) or [])]
        p["locked"] = fl_d(pe, "lineupLocked", False) == True
        inj = str(fl_d(pl, "injuryStatus", fl_d(e, "injuryStatus", ""))).upper()
        p["tag"] = ES_OUT.get(inj, "")
        p["warn"] = ES_WARN.get(inj, "")
        if sched != None and team != "":
            st = sched_status(p, sched, ctx.now.unix)
            if st[0]:
                p["tag"] = "BYE"
                p["known"] = True
            else:
                game_info(p, sched, "", "")
        if p["tag"] != "":
            p["proj"] = 0.0
        return p

    starters = []
    bench = []
    for e in entries:
        sid = int(fl_num(fl_d(e, "lineupSlotId", 20)))
        if sid == 21:
            continue
        p = mk(e)
        if p["known"]:
            have_proj = True
        if sid == 20:
            bench.append(p)
        else:
            starters.append([sid, p])
    # Slots from the league's counts, in ESPN's own order; starters dropped
    # into the matching slot, empties left None.
    slots = []
    ids = sorted([int(fl_num(k)) for k in counts.keys()])
    for sid in ids:
        if sid in [20, 21] or sid not in ES_SLOT:
            continue
        for _ in range(int(fl_num(counts.get(str(sid), 0)))):
            slots.append({"label": ES_SLOT[sid], "sid": sid, "cur": None})
    for sp in starters:
        placed = False
        for s in slots:
            if not placed and s["sid"] == sp[0] and s["cur"] == None:
                s["cur"] = sp[1]
                placed = True
        if not placed:
            slots.append({"label": ES_SLOT.get(sp[0], "?"), "sid": sp[0], "cur": sp[1]})

    def ok_for(slot, p):
        return slot["sid"] in p["elig"]

    return {"slots": slots, "bench": bench, "ok_for": ok_for, "have_proj": have_proj,
            "sched": sched != None}

def load_demo():
    slots = []
    bench = []
    for d in DEMO_PLAYERS:
        p = player(d[1], d[1], d[2], d[3], d[4], True)
        p["elig"] = [d[2]]
        p["opp"] = d[5]
        p["home"] = d[6]
        p["kick"] = d[7]
        p["ko"] = d[8]
        p["warn"] = d[9]
        if d[0] == "":
            bench.append(p)
        else:
            sd = SL_SLOT[d[0]]
            slots.append({"label": sd[0], "takes": sd[1], "cur": p})

    def ok_for(slot, p):
        return p["pos"] in slot["takes"]

    return {"slots": slots, "bench": bench, "ok_for": ok_for, "have_proj": True, "sched": True}

# ------------------------------------------------------------ optimizer
def hungarian(cost, n, m):
    """Min-cost assignment of n rows to m >= n columns (the e-maxx
    Hungarian method, O(n^2 m), 1-based internally). Returns the column
    picked for each row (0-based)."""
    INF = 1e18
    u = [0.0] * (n + 1)
    v = [0.0] * (m + 1)
    pp = [0] * (m + 1)
    way = [0] * (m + 1)
    for i in range(1, n + 1):
        pp[0] = i
        j0 = 0
        minv = [INF] * (m + 1)
        used = [False] * (m + 1)
        for _ in range(m + 2):
            used[j0] = True
            i0 = pp[j0]
            row = cost[i0 - 1]
            delta = INF
            j1 = 0
            for j in range(1, m + 1):
                if not used[j]:
                    cur = row[j - 1] - u[i0] - v[j]
                    if cur < minv[j]:
                        minv[j] = cur
                        way[j] = j0
                    if minv[j] < delta:
                        delta = minv[j]
                        j1 = j
            for j in range(m + 1):
                if used[j]:
                    u[pp[j]] += delta
                    v[j] -= delta
                else:
                    minv[j] -= delta
            j0 = j1
            if pp[j0] == 0:
                break
        for _ in range(m + 2):
            j1 = way[j0]
            pp[j0] = pp[j1]
            j0 = j1
            if j0 == 0:
                break
    res = [-1] * n
    for j in range(1, m + 1):
        if pp[j] > 0:
            res[pp[j] - 1] = j - 1
    return res

def optimize(ro):
    """The best lineup (exact assignment), then the moves as substitution
    chains. Returns the plan."""
    slots = ro["slots"]
    ok_for = ro["ok_for"]
    pool = []
    starter = {}
    for i in range(len(slots)):
        s = slots[i]
        p = s["cur"]
        s["fixed"] = p != None and (p["locked"] or not p["known"])
        s["i"] = i
        if p != None and not s["fixed"] and p["id"] not in starter:
            pool.append(p)
            starter[p["id"]] = True
    for p in ro["bench"]:
        # a benched player who won't play is never worth a slot
        if p["known"] and not p["locked"] and p["tag"] == "" and p["id"] not in starter:
            pool.append(p)
            starter[p["id"]] = False
    open_s = [s for s in slots if not s["fixed"]]
    n = len(open_s)
    cost = []
    for s in open_s:
        row = []
        for p in pool:
            if ok_for(s, p):
                w = W_FILL + p["proj"]
                if starter[p["id"]] and p["tag"] == "":
                    w += W_STAY
                if s["cur"] != None and s["cur"]["id"] == p["id"]:
                    w += W_SAME
                row.append(-w)
            else:
                row.append(W_NOPE)
        for _ in range(n):
            row.append(0.0)            # leave the slot empty
        cost.append(row)
    pick = hungarian(cost, n, len(pool) + n) if n > 0 else []
    for k in range(n):
        j = pick[k]
        open_s[k]["new"] = pool[j] if j >= 0 and j < len(pool) else None
    for s in slots:
        if s["fixed"]:
            s["new"] = s["cur"]

    # Substitution chains: the new man takes slot S; follow S's old
    # occupant along the slots he slid to until someone leaves.
    cur_at = {}
    new_at = {}
    for s in slots:
        if s["cur"] != None:
            cur_at[s["cur"]["id"]] = s
        if s["new"] != None:
            new_at[s["new"]["id"]] = s
    moves = []
    for s in slots:
        x = s["new"]
        if x == None or s["fixed"] or x["id"] in cur_at:
            continue
        hops = []
        t = s
        out = None
        for _ in range(len(slots) + 1):
            c = t["cur"]
            if c == None:
                break
            if c["id"] not in new_at:
                out = c
                break
            nxt = new_at[c["id"]]
            hops.append([c, nxt["label"]])
            t = nxt
        moves.append({"in": x, "out": out, "slot": s["label"], "si": s["i"], "hops": hops,
                      "gain": x["proj"] - (out["proj"] if out != None else 0.0)})
    moves = sorted(moves, key = lambda m: (-m["gain"], m["si"]))
    # Starters who won't play and can't be covered from the bench.
    alerts = []
    for s in slots:
        p = s["new"]
        if p != None and p["tag"] != "" and not p["locked"]:
            alerts.append([p, s["label"]])
        if p == None:
            alerts.append([None, s["label"]])
    cur_t = 0.0
    new_t = 0.0
    locked = 0
    for s in slots:
        if s["cur"] != None and s["cur"]["known"]:
            cur_t += s["cur"]["proj"]
        if s["new"] != None and s["new"]["known"]:
            new_t += s["new"]["proj"]
        if s["cur"] != None and s["cur"]["locked"]:
            locked += 1
    return {"moves": moves, "alerts": alerts, "cur": cur_t, "best": new_t, "locked": locked,
            "slots": slots}

def compute(ctx):
    # matchups = False: a lineup needs rosters + projections, not scores;
    # it keeps Sleeper at 6-7 requests (8 for an old-season ID), all three
    # projection feeds always fit, and a league with no game this week
    # still gets its lineup checked.
    lg = fl_load(ctx, projections = True, matchups = False, games = True)
    out = {"lg": lg, "plan": None, "why": ""}
    if not lg["ok"]:
        return out
    # Adapter v2.1: lg["raw"] carries roster_positions (and refuses a
    # league whose sport isn't NFL itself) - no league re-read.
    obj = lg["raw"] if lg["platform"] == "SLEEPER" else None
    if lg["state"] == "predraft":
        return out
    if lg["state"] != "demo" and not lg["me_matched"]:
        out["why"] = "team"
        return out
    ro = None
    if lg["platform"] == "DEMO":
        ro = load_demo()
    elif lg["platform"] == "SLEEPER":
        ro = load_sleeper(ctx, lg, obj)
    else:
        ro = load_espn(ctx, lg)
    if ro == None:
        out["why"] = "roster"
        return out
    if "chopped" in ro:
        out["why"] = "chopped"
        return out
    if "err" in ro:
        out["why"] = "espn" + str(ro["err"])
        return out
    filled = [s for s in ro["slots"] if s["cur"] != None]
    if len(ro["slots"]) == 0 or (len(filled) == 0 and len(ro["bench"]) == 0):
        out["why"] = "chopped" if lg.get("format", "h2h") == "guillotine" else "empty"
        return out
    if not ro["have_proj"]:
        out["why"] = "noproj"
        return out
    out["plan"] = optimize(ro)
    out["sched"] = ro["sched"]
    return out

# ------------------------------------------------------------ screens
def card(c, head, sub, rail_color, head_color):
    c.fill("black")
    c.rect(L, 0, L + 1, 31, fill = rail_color)
    c.sprite(JERSEY, 12, 8, legend = {"X": color.dim(head_color, 45)})
    h = fit(c, head, ["6x8", "5x7", "4x5"], R - 44)
    c.text(h[0], 112, 8, font = h[1], color = head_color, align = "center")
    s = fit(c, sub, ["4x5", "picopixel"], R - 44)
    c.text(s[0], 112, 21, font = s[1], color = DIM, align = "center")

def state_screen(c, r):
    lg = r["lg"]
    if not lg["ok"]:
        card(c, lg["err"][0], lg["err"][1], OFFLINE, AMBER)
        return True
    w = r["why"]
    if lg["state"] == "predraft":
        card(c, "DRAFT DAY AHEAD", "TIPS START AFTER YOUR DRAFT", GOOD, GOOD)
        return True
    if w == "team":
        card(c, "WHICH TEAM IS YOURS?", "SET YOUR TEAM NAME IN SETTINGS", AMBER, AMBER)
        return True
    if w == "chopped":
        card(c, "CHOPPED", "YOUR TEAM IS OUT OF THE GUILLOTINE", ALARM, ALARM)
        return True
    if w == "empty" or w == "roster":
        card(c, "NO PLAYERS YET", "YOUR ROSTER IS EMPTY", GOOD, GOOD)
        return True
    if w == "noproj":
        card(c, "NO PROJECTIONS YET", "CHECK BACK CLOSER TO KICKOFF", GOOD, GOOD)
        return True
    if w.startswith("espn"):
        code = w[4:]
        card(c, "ESPN ROSTER " + ("OFFLINE" if code == "0" else "ERROR"), "RETRY IN 5 MIN", OFFLINE, AMBER)
        return True
    return False

def draw_logo(c, team, x, y):
    k = logo_key(team)
    if k != "":
        c.image(LOGO[k], x, y)
    else:
        c.sprite(JERSEY, x + 3, y + 1, legend = {"X": "#3A4150"})

# ------------------------------------------------------------ page 1
def opp_mark(c, p, cx, y):
    """@DAL (away) / VS DAL (home) / DAL (venue unknown), centred on cx."""
    o = str(p["opp"]).upper()
    if o == "":
        return
    if p["home"] == True:
        w = c.text_width("VS", "3x4") + 2 + c.text_width(o, "4x5")
        x = cx - w // 2
        c.text("VS", x, y + 1, font = "3x4", color = DIM)
        c.text(o, x + c.text_width("VS", "3x4") + 2, y, font = "4x5", color = SLATE)
    elif p["home"] == False:
        w = c.text_width("@", "4x5") + 1 + c.text_width(o, "4x5")
        x = cx - w // 2
        c.text("@", x, y, font = "4x5", color = DIM)
        c.text(o, x + c.text_width("@", "4x5") + 1, y, font = "4x5", color = SLATE)
    else:
        c.text(o, cx, y, font = "4x5", color = SLATE, align = "center")

def value_line(c, p, x, y, right):
    """WR 14.2 Q (left) / Q 10.1 WR (right). A player who won't play shows
    his tag in red; a Q / D player projected 0 shows the 0.0 in amber."""
    pos = p["pos"] if p["pos"] != "" else "?"
    tag = p["tag"]
    val = []        # [text, colour, is_number], in reading order
    if tag != "":
        val = [[tag, ALARM, False]]
    elif p["warn"] != "" and p["proj"] < 0.05:
        val = [[p["warn"], AMBER, False], [fl_fmt1(p["proj"]), AMBER, True]]
    elif p["warn"] != "":
        val = [[fl_fmt1(p["proj"]), SLATE, True], [p["warn"], AMBER, False]]
        if right:
            val = val[::-1]
    else:
        val = [[fl_fmt1(p["proj"]), SLATE, True]]
    parts = (val + [[pos, DIM, False]]) if right else ([[pos, DIM, False]] + val)
    widths = [text_w(c, q[0], "4x5") if q[2] else c.text_width(q[0], "4x5") for q in parts]
    total = 0
    for w in widths:
        total += w
    total += 4 * (len(parts) - 1)
    xx = x - total + 1 if right else x
    for i in range(len(parts)):
        q = parts[i]
        if q[2]:
            num_text(c, q[0], xx, y, "4x5", q[1])
        else:
            c.text(q[0], xx, y, font = "4x5", color = q[1])
        xx += widths[i] + 4

def game_line(c, p, x, y, right, first):
    """Kickoff (SUN 1:00) beside the opponent; the game that starts first
    gets the gold padlock - the move locks then. Returns [x0, x1]."""
    k = p["kick"]
    if p["tag"] == "BYE":
        k = "NO GAME"
        first = False
    if k == "":
        return [x, x]
    w = c.text_width(k, "4x5")
    pw = 7 if first else 0
    col = AMBER if first else DIM
    x0 = x - (w + pw) + 1 if right else x
    if first:
        c.sprite(PAD, x0, y, legend = {"X": GOLD})
    c.text(k, x0 + pw, y, font = "4x5", color = col)
    return [x0, x0 + w + pw - 1]

def side(c, p, x_logo, x_text, right, head, head_col, arrow, first, name_w):
    """One player's half of the board. Returns the game line's extent."""
    if p != None:
        draw_logo(c, p["team"], x_logo, Y_LOGO)
    else:
        c.sprite(JERSEY, x_logo + 3, Y_LOGO + 1, legend = {"X": "#3A4150"})
    align = "right" if right else "left"
    # head: arrow + word
    aw = 5
    if right:
        c.text(head, x_text - aw - 2, Y_HEAD, font = "5x7", color = head_col, align = "right")
        c.sprite(arrow, x_text - aw + 1, Y_HEAD + 2, legend = {"X": head_col})
    else:
        c.sprite(arrow, x_text, Y_HEAD + 2, legend = {"X": head_col})
        c.text(head, x_text + aw + 2, Y_HEAD, font = "5x7", color = head_col)
    nm = p["name"] if p != None else "EMPTY SLOT"
    nf = name_fit(c, nm, name_w)
    c.text(nf[0], x_text, Y_NAME, font = nf[1], color = INK if p != None else DIM, align = align)
    if p == None:
        return [x_text, x_text]
    value_line(c, p, x_text, Y_LINE, right)
    opp_mark(c, p, x_logo + LOGO_W // 2, Y_GAME)
    return game_line(c, p, x_text, Y_GAME, right, first)

def first_lock(m):
    """'in' / 'out': whose game kicks off first (the move's deadline)."""
    a = m["in"]["ko"]
    b = m["out"]["ko"] if m["out"] != None else 0
    if a <= 0 and b <= 0:
        return ""
    if b <= 0 or (a > 0 and a <= b):
        return "in"
    return "out" if m["out"] != None else ""

def swap(c, ctx):
    r = compute(ctx)
    if state_screen(c, r):
        return
    lg = r["lg"]
    plan = r["plan"]
    demo = lg["state"] == "demo"
    c.fill("black")
    if len(plan["moves"]) > 0:
        m = plan["moves"][0]
        o = m["out"]
        fl = first_lock(m)
        hop = len(m["hops"]) > 0
        g = gain_text(m["gain"])
        f = "6x8" if text_w(c, g, "6x8") <= 29 else ("5x7" if text_w(c, g, "5x7") <= 29 else "4x5")
        gw = text_w(c, g, f)
        gx0 = MID + 1 - gw // 2
        nw_l = gx0 - 5 - TX0
        nw_r = TX1 - (gx0 + gw - 1) - 5
        ext_l = side(c, m["in"], L, TX0, False, "START", GOOD, UP, fl == "in", nw_l if nw_l < 50 else 50)
        head = "SIT"
        if o == None:
            head = "FILL"
        elif o["tag"] != "":
            head = "BENCH"
        ext_r = side(c, o, R - LOGO_W + 1, TX1, True, head, ALARM, DOWN, fl == "out", nw_r if nw_r < 50 else 50)
        # centre: swap arrows (or, when a starter has to slide over to
        # make room, that slide: WILSON > WR), the gain, AT <slot>
        if hop:
            hw = c.text_width(head, "5x7") + 7
            hop_line(c, m["hops"], TX0 + 38 + 4, TX1 - hw - 4, 1)
        else:
            c.sprite(SWAP, MID - 5, 0, legend = SWAP_LEG)
        num_text(c, g, MID + 1, 11, f, GOOD, "center")
        sl = m["slot"]
        aw = c.text_width("AT", "4x5") + 3 + c.text_width(sl, "4x5")
        ax = MID + 1 - aw // 2
        c.text("AT", ax, 21, font = "4x5", color = DIM)
        c.text(sl, ax + c.text_width("AT", "4x5") + 3, 21, font = "4x5", color = INK)
        if demo:
            c.text("DEMO", MID + 1, 27, font = "4x5", color = DEMO_C, align = "center")
    elif len(plan["alerts"]) > 0:
        alert(c, plan, plan["alerts"][0])
        if demo:
            c.text("DEMO", R, 27, font = "4x5", color = DEMO_C, align = "right")
    elif plan["locked"] == len(plan["slots"]):
        c.sprite(LOCK, L + 6, 5, legend = LOCK_LEG, scale = 2)
        c.text("LINEUP LOCKED", 112, 4, font = "6x8", color = GOLD, align = "center")
        num_text(c, fl_fmt1(plan["cur"]), 112, 14, "5x7", INK, "center")
        c.text("PROJ - EVERY GAME HAS KICKED OFF", 112, 24, font = "4x5", color = DIM, align = "center")
    else:
        optimal(c, plan, demo)

def hop_line(c, hops, lo, hi, y):
    """WILSON > WR (+1 when the chain slides more than one starter),
    centred on the board between lo and hi."""
    h = hops[0]
    more = "+" + str(len(hops) - 1) if len(hops) > 1 else ""
    sl = h[1]
    fixed = 2 + 3 + 2 + c.text_width(sl, "4x5") + (3 + c.text_width(more, "4x5") if more != "" else 0)
    maxw = hi - lo + 1
    nm = fit(c, last_name(h[0]["name"]), ["4x5"], maxw - fixed)
    if nm[0] == "":
        return
    w = c.text_width(nm[0], "4x5") + fixed
    x = MID + 1 - w // 2
    if x < lo:
        x = lo
    if x + w - 1 > hi:
        x = hi - w + 1
    c.text(nm[0], x, y, font = "4x5", color = SLATE)
    x += c.text_width(nm[0], "4x5") + 2
    c.sprite(HOP, x, y, legend = {"X": INK})
    x += 5
    c.text(sl, x, y, font = "4x5", color = INK)
    if more != "":
        c.text(more, x + c.text_width(sl, "4x5") + 3, y, font = "4x5", color = DIM)

TAG_WORD = {"OUT": "OUT", "IR": "ON IR", "PUP": "ON PUP", "SUS": "SUSPENDED", "BYE": "ON BYE"}

def alert(c, plan, a):
    """A starter who won't play and nobody on the bench can cover him."""
    p = a[0]
    c.sprite(CROSS, L + 3, 6, legend = CROSS_LEG, scale = 2)
    x = TX0
    if p != None:
        draw_logo(c, p["team"], R - LOGO_W + 1, 4)
        c.text("BENCH", x, 2, font = "5x7", color = ALARM)
        nm = name_fit(c, p["name"], TX1 - x - 32)
        c.text(nm[0], x + 32, 2, font = nm[1], color = INK)
        c.text(TAG_WORD.get(p["tag"], p["tag"]), x, 12, font = "6x8", color = ALARM)
        c.text("NO BACKUP ON YOUR BENCH", x, 24, font = "4x5", color = DIM)
    else:
        c.text("EMPTY " + a[1] + " SLOT", x, 2, font = "5x7", color = INK)
        c.text("NO ONE TO START", x, 12, font = "6x8", color = ALARM)
        c.text("CHECK THE WAIVER WIRE", x, 24, font = "4x5", color = DIM)

def optimal(c, plan, demo):
    for q in CONFETTI:
        c.rect(L + q[0], q[1], L + q[0] + 1, q[1], fill = q[2])
    c.sprite(TROPHY, L + 17, 8, legend = TROPHY_LEG)
    c.text("LINEUP IS OPTIMAL", 118, 3, font = "6x8", color = GOOD, align = "center")
    t = fl_fmt1(plan["cur"])
    w = text_w(c, t, "5x7") + 3 + c.text_width("PROJ", "4x5")
    x = 118 - w // 2
    num_text(c, t, x, 14, "5x7", INK)
    c.text("PROJ", x + text_w(c, t, "5x7") + 3, 16, font = "4x5", color = DIM)
    c.text("NO MOVES TO MAKE", 118, 25, font = "4x5", color = DIM, align = "center")
    if demo:
        c.text("DEMO", R, 25, font = "4x5", color = DEMO_C, align = "right")

# ------------------------------------------------------------ page 2
def strip_cells(plan, hero):
    """The lineup card's cells: [label, style]. More than 12 slots fold the
    defensive slots into one IDP cell (worst style wins)."""
    cells = []
    fold = len(plan["slots"]) > 12
    idp = None
    rank = {"bad": 5, "hero": 4, "changed": 3, "locked": 2, "idp": 1, "fine": 0}
    for s in plan["slots"]:
        changed = s["new"] != None and (s["cur"] == None or s["new"]["id"] != s["cur"]["id"])
        bad = (s["new"] == None) or (s["new"]["tag"] != "" and not s["new"]["locked"])
        is_idp = s["label"] in IDP_SLOTS
        if bad:
            st = "bad"
        elif s["fixed"] and s["cur"] != None and s["cur"]["locked"]:
            st = "locked"
        elif changed and hero == s["i"]:
            st = "hero"
        elif changed:
            st = "changed"
        elif s["fixed"]:
            st = "idp"           # no projection: nothing to judge
        else:
            st = "fine"
        if fold and is_idp:
            if idp == None:
                idp = ["IDP", st]
                cells.append(idp)
            elif rank[st] > rank[idp[1]]:
                idp[1] = st
            continue
        cells.append([s["label"], st])
    return cells

STRIP_STYLE = {
    "bad": [ALARM, "black"],
    "locked": ["#2A2F3A", SLATE],
    "hero": [GOOD, "black"],
    "changed": ["#062414", GOOD],
    "idp": ["#1E2533", SLATE],
    "fine": ["#0E4A26", "#8FE3AE"],
    "party": [GOOD, "black"],
}

def lineup_strip(c, plan, x0, x1, y0, hero, party = False):
    """One cell per starting slot."""
    cells = strip_cells(plan, hero)
    n = len(cells)
    if n == 0:
        return
    pitch = (x1 - x0 + 2) // n
    if pitch > 24:
        pitch = 24
    total = pitch * n - 1
    xs = x0 + (x1 - x0 + 1 - total) // 2
    for i in range(n):
        lab = cells[i][0]
        st = "party" if party else cells[i][1]
        sty = STRIP_STYLE[st]
        x = xs + i * pitch
        w = pitch - 1
        c.rect(x, y0, x + w - 1, 31, fill = sty[0])
        if st == "changed":
            c.rect(x, y0 - 1, x + w - 1, y0 - 1, fill = GOOD)
        # full name in 4x5, then 3x4, then the two-letter name, then 1 letter
        f = "4x5"
        if c.text_width(lab, f) > w - 2:
            f = "3x4"
        if c.text_width(lab, f) > w - 2:
            lab = STRIP_SHORT.get(lab, lab[:2])
            f = "4x5" if c.text_width(lab, "4x5") <= w - 2 else "3x4"
        if c.text_width(lab, f) > w - 1:
            lab = lab[:1]
        c.text(lab, x + w // 2, y0 + (1 if f == "4x5" else 2), font = f, color = sty[1], align = "center")

def lineup(c, ctx):
    r = compute(ctx)
    if state_screen(c, r):
        return
    lg = r["lg"]
    plan = r["plan"]
    me = fl_team(lg, lg["me"])
    demo = lg["state"] == "demo"
    c.fill("black")
    fl_badge(c, me, L, 0, 24)
    x0 = L + 22 + 3
    has = len(plan["moves"]) > 0
    # the top move's two clubs, top right: IN then OUT
    xr = R
    if has:
        m = plan["moves"][0]
        draw_logo(c, m["in"]["team"], R - 2 * LOGO_W - 1, 0)
        if m["out"] != None:
            draw_logo(c, m["out"]["team"], R - LOGO_W + 1, 0)
        else:
            c.sprite(JERSEY, R - LOGO_W + 4, 1, legend = {"X": "#3A4150"})
        xr = R - 2 * LOGO_W - 5
    wk = "WK " + str(lg["week"])
    c.text(wk, xr, 1, font = "4x5", color = DIM, align = "right")
    nm = fit(c, me["name"], ["5x7", "4x5"], xr - x0 - c.text_width(wk, "4x5") - 4)
    c.text(nm[0], x0, 0, font = nm[1], color = me["color"])
    # meter: now (grey) + gain (green) against the best lineup
    best = plan["best"]
    cur = plan["cur"]
    bs = fl_fmt1(best)
    bw = text_w(c, bs, "5x7")
    lw = c.text_width("BEST", "4x5")
    bx1 = xr - bw - 3 - lw - 3
    c.rect(x0, 9, bx1, 15, fill = "#161B26")
    top = best if best > cur else cur
    top = top if top > 0 else 1.0
    span = bx1 - x0 + 1
    cw = int(span * cur / top + 0.5)
    bwid = int(span * best / top + 0.5)
    if bwid > cw:
        c.rect(x0 + cw + 1, 9, x0 + bwid - 1, 15, fill = GOOD)
    if cw > 0:
        c.rect(x0, 9, x0 + cw - 1, 15, fill = "#56617A")
        cs = fl_fmt1(cur)
        if cw >= text_w(c, cs, "4x5") + 4:
            num_text(c, cs, x0 + 2, 10, "4x5", INK)
    num_text(c, bs, xr, 9, "5x7", GOOD if best > cur + 0.05 else INK, "right")
    c.text("BEST", xr - bw - 3 - lw + 1, 11, font = "4x5", color = DIM)
    if demo:
        c.text("DEMO", L + 11, 26, font = "4x5", color = DEMO_C, align = "center")
    # the lineup card along the bottom
    hero = plan["moves"][0]["si"] if has else None
    lineup_strip(c, plan, x0, R, 26, hero, not has and len(plan["alerts"]) == 0)
    # the to-do list: every move, then every starter nobody can cover
    items = []
    for m in plan["moves"]:
        o = m["out"]
        b = last_name(o["name"]) if o != None else "EMPTY " + m["slot"]
        hurt = o != None and o["tag"] != ""
        if hurt:
            b += " " + o["tag"]
        items.append([[UP, GOOD, last_name(m["in"]["name"]), INK], [DOWN, ALARM, b, ALARM if hurt else SLATE],
                      [None, GOOD, gain_text(m["gain"]), GOOD]])
    for al in plan["alerts"]:
        t = (last_name(al[0]["name"]) + " " + al[0]["tag"]) if al[0] != None else "EMPTY " + al[1]
        items.append([[PLUS, ALARM, t, ALARM]])
    y = 18
    if len(items) == 0:
        msg = "LINEUP IS OPTIMAL"
        if plan["locked"] > 0:
            msg += " - " + str(plan["locked"]) + " LOCKED"
        c.text(msg, x0, y, font = "4x5", color = GOOD)
        return
    x = x0
    shown = 0
    for it in items:
        w = 0
        for part in it:
            w += (6 if part[0] != None else 0) + text_w(c, part[2], "4x5") + 3
        more = len(items) - shown - 1
        room = R - (c.text_width("+" + str(more), "4x5") + 3 if more > 0 else 0)
        if x + w - 3 > room and shown == 0:
            # the first item always shows: clip its names to share the room
            names = [k for k in range(len(it)) if it[k][0] != None]
            avail = room - x + 3
            for part in it:
                avail -= (6 if part[0] != None else text_w(c, part[2], "4x5")) + 3
            share = avail // len(names)
            for k in names:
                it[k][2] = fit(c, it[k][2], ["4x5"], share)[0]
            w = 0
            for part in it:
                w += (6 if part[0] != None else 0) + text_w(c, part[2], "4x5") + 3
        if x + w - 3 > room:
            break
        for part in it:
            if part[0] != None:
                c.sprite(part[0], x, y + 1, legend = {"X": part[1]})
                x += 6
            if part[0] == None:
                num_text(c, part[2], x, y, "4x5", part[3])
            else:
                c.text(part[2], x, y, font = "4x5", color = part[3])
            x += text_w(c, part[2], "4x5") + 3
        x += 5
        shown += 1
    if shown < len(items):
        c.text("+" + str(len(items) - shown), R, y, font = "4x5", color = AMBER, align = "right")
