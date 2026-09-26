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
# WEEKLY STREAMERS
#
# DESIGN. GAME TICKET. Every pick is printed as a game ticket spanning the
# panel, and the ticket is the one memorable thing:
#
#   .-----------------------------------------------( )---------------.
#   | J. FERGUSON                             WEEK 3 :   ADMIT ONE     |
#   | [POS ] [ PROJ ]  [DAL]  [ AT ]  [NYG]          :    +2.7         |
#   |   TE     9.8      logo    MNF    logo          :    OVER         |
#   | OPP GIVES UP 26.4 PPG                          :   YOUR TE       |
#   '-----------------------------------------------( )---------------'
#     main ticket (x 6-137) in the streamer        tear-off stub (x 139-185)
#     club's card stock, club stripe on the        whose stock is the verdict
#     left edge
#
# The main ticket carries the event line (player, or the defense's club),
# seat-and-row style fields on foil plates - POS (position colour: DEF
# blue, K yellow, TE violet, QB pink), PROJ, and the VS / AT plate (OPP
# without the slate) printed between the streamer's and the opponent's
# club logos, the game day under it (TNF / SNF / MNF in white) - and the
# fine print: why the matchup is good (the opponent's points per game and
# projected sacks for DEF, the team's implied points for K, the total
# points per game the opponent gives up for TE / QB). A perforated tear
# line with half-moon notches splits off the stub. The stub is the
# verdict: green with how many points the pickup beats your starter by
# (+3.4 OVER YOUR K, or YOUR DEF ON BYE / IS OUT / IS EMPTY / PROJ 0.0),
# slate when your starter is still better (-0.8 VS YOUR K), dark with a
# padlock and his score when your starter at that slot already played
# (YOUR TE SCORED - the slot is locked, so it ranks last), the position
# colour (BEST ON THE WIRE) when no team is set, amber TEAM NOT FOUND.
# State screens are a grey ticket with the message printed on it and the
# stub stamped VOID (errors, red) or SOON / NONE / USED.
#
#   pick1, pick2   the two best streams in your league this week, ranked by
#                  points over your starter (or by position when your team
#                  isn't set). Only positions your league starts count. QB
#                  always counts in superflex / 2QB leagues; in a 1-QB
#                  league a QB shows only when he beats your starter. If no
#                  free agent beats any open slot, pick1 is your own team's
#                  ticket - YOUR STARTERS ARE BEST, your crest printed on
#                  it, a green KEEP stub with a check - or LINEUP LOCKED
#                  with a padlock stub when every slot has played.
#   board          every streaming slot side by side, one small ticket each
#                  in the club's stock with the position colour as its
#                  stub edge. 3-4 slots: logo, position, projection and the
#                  green ADD / slate chip. 1-2 slots get 92 px tickets:
#                  chip, gain, name with VS / @ opponent and a short reason
#                  (one slot shows its best two free agents).
#
# DATA. The shared fantasy-league adapter v2 (block above), matchups off:
# Sleeper 3 calls (5-6 for an old-season ID), ESPN 1. Then:
#   Sleeper  roster slots from the adapter (v2.1, no call), ONE projection feed for the
#            positions the league starts (TE+K+DEF 540 KB, +QB 760 KB), the
#            NFL slate (fl_nfl_games: opponent, home/away, kickoff, bye),
#            this week's matchup only once a game has kicked off (your
#            starters' actual points), NFL standings. Every value is priced
#            with fl_score in the league's own scoring (plus fgmiss summed
#            from the distance buckets when the league scores it).
#   ESPN     Sleeper DEF feed (implied points + sacks), the NFL slate, one
#            kona_player_info call per slot (DEF, K, TE, QB; free agents +
#            waivers, the league's own projection, limit 8, clubs still to
#            kick off only once games start), NFL standings. Your starters
#            come with the adapter's call: an actual stat line = played, a
#            0 projection = bye / out, a missing entry = empty slot.
# Locks: a player whose club has kicked off is off the wire; without the
# slate, the game date plus the Eastern hour (Sunday from 1 pm).
# Worst case 8 requests on both platforms; everything past the 8th is
# skipped and degrades (no slate -> no VS / @ or day, date-based locks; no
# standings -> the reason uses the projection).
# Refresh 300: league ID and team are free text.
# ======================================================================

INK = "#F4F7FF"
SLATE = "#8A93A8"
GOOD = "#2FE06F"
GOOD_DK = "#0E5A2A"
AMBER = "#FFBF00"
ALARM = "#FF3B30"

POS_COLOR = {"DEF": "#2DB8FF", "K": "#FFD23F", "TE": "#B18CFF", "QB": "#FF5C8A"}
POS_WORD = {"DEF": "DEF", "K": "K", "TE": "TE", "QB": "QB"}

STD_URL = "https://site.web.api.espn.com/apis/v2/sports/football/nfl/standings"
TTL_STD = 3600
TTL_FA = 900

# The lint needs every asset path as a literal, so the logos live in a dict.
SMALL = {
    "ARI": "ARI_S.png", "ATL": "ATL_S.png", "BAL": "BAL_S.png", "BUF": "BUF_S.png",
    "CAR": "CAR_S.png", "CHI": "CHI_S.png", "CIN": "CIN_S.png", "CLE": "CLE_S.png",
    "DAL": "DAL_S.png", "DEN": "DEN_S.png", "DET": "DET_S.png", "GB": "GB_S.png",
    "HOU": "HOU_S.png", "IND": "IND_S.png", "JAX": "JAX_S.png", "KC": "KC_S.png",
    "LV": "LV_S.png", "LAC": "LAC_S.png", "LAR": "LAR_S.png", "MIA": "MIA_S.png",
    "MIN": "MIN_S.png", "NE": "NE_S.png", "NO": "NO_S.png", "NYG": "NYG_S.png",
    "NYJ": "NYJ_S.png", "PHI": "PHI_S.png", "PIT": "PIT_S.png", "SF": "SF_S.png",
    "SEA": "SEA_S.png", "TB": "TB_S.png", "TEN": "TEN_S.png", "WSH": "WSH_S.png",
}
ALIAS = {"WAS": "WSH", "LA": "LAR", "JAC": "JAX", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# ESPN pro team id -> abbreviation (fantasy proTeamId = site API team id).
ESPN_PRO = {1: "ATL", 2: "BUF", 3: "CHI", 4: "CIN", 5: "CLE", 6: "DAL", 7: "DEN", 8: "DET",
            9: "GB", 10: "TEN", 11: "IND", 12: "KC", 13: "LV", 14: "LAR", 15: "MIA", 16: "MIN",
            17: "NE", 18: "NO", 19: "NYG", 20: "NYJ", 21: "PHI", 22: "ARI", 23: "PIT", 24: "LAC",
            25: "SF", 26: "SEA", 27: "TB", 28: "WSH", 29: "CAR", 30: "JAX", 33: "BAL", 34: "HOU"}

NICK = {
    "ARI": "CARDINALS", "ATL": "FALCONS", "BAL": "RAVENS", "BUF": "BILLS", "CAR": "PANTHERS",
    "CHI": "BEARS", "CIN": "BENGALS", "CLE": "BROWNS", "DAL": "COWBOYS", "DEN": "BRONCOS",
    "DET": "LIONS", "GB": "PACKERS", "HOU": "TEXANS", "IND": "COLTS", "JAX": "JAGUARS",
    "KC": "CHIEFS", "LV": "RAIDERS", "LAC": "CHARGERS", "LAR": "RAMS", "MIA": "DOLPHINS",
    "MIN": "VIKINGS", "NE": "PATRIOTS", "NO": "SAINTS", "NYG": "GIANTS", "NYJ": "JETS",
    "PHI": "EAGLES", "PIT": "STEELERS", "SF": "49ERS", "SEA": "SEAHAWKS", "TB": "BUCCANEERS",
    "TEN": "TITANS", "WSH": "COMMANDERS",
}

# Club colours lifted for black (navies raised to a blue that survives).
CLUB = {
    "BUF": "#2B63E6", "MIA": "#00B8C2", "NE": "#C8102E", "NYJ": "#1E9A5E",
    "BAL": "#6A45D8", "CIN": "#FB4F14", "CLE": "#9A5428", "PIT": "#FFB612",
    "HOU": "#D2203A", "IND": "#2D74DA", "JAX": "#00A3B4", "TEN": "#4B92DB",
    "DEN": "#FB6A14", "KC": "#E31837", "LV": "#A5ACAF", "LAC": "#2AA3F0",
    "DAL": "#3067DE", "NYG": "#2A4FD0", "PHI": "#0E9A86", "WSH": "#B8323A",
    "CHI": "#E0561A", "DET": "#1A92E2", "GB": "#FFB612", "MIN": "#8448DC",
    "ATL": "#E0263E", "CAR": "#1AA3EA", "NO": "#D3BC8D", "TB": "#E0201A",
    "ARI": "#CC2548", "LAR": "#FFC20E", "SF": "#D8211A", "SEA": "#69BE28",
}

# 9 x 9 fantasy-app ADD button: a round green chip with a white plus.
ADD = """
..GGGGG..
.GGGWGGG.
GGGGWGGGG
GGGGWGGGG
GWWWWWWWG
GGGGWGGGG
GGGGWGGGG
.GGGWGGG.
..GGGGG..
"""
# The same chip, slate, with a minus: your starter is still better.
HOLD = """
..SSSSS..
.SSSSSSS.
SSSSSSSSS
SSSSSSSSS
SWWWWWWWS
SSSSSSSSS
SSSSSSSSS
.SSSSSSS.
..SSSSS..
"""
CHIP_LEG = {"G": "#1FA84F", "S": "#4A5266", "W": "#FFFFFF"}

# 7 x 9 padlock: your starter at this slot already played - it's locked.
LOCK = """
..SSS..
.S...S.
.S...S.
SSSSSSS
SSSDSSS
SSDDDSS
SSSDSSS
SSSSSSS
"""
LOCK_LEG = {"S": "#8A93A8", "D": "#2A2F3A"}

# 16 x 12 check mark for YOUR STARTERS ARE BEST.
CHECK = """
..............GG
.............GGG
............GGG.
...........GGG..
..........GGG...
GG.......GGG....
GGG.....GGG.....
.GGG...GGG......
..GGG.GGG.......
...GGGGG........
....GGG.........
.....G..........
"""

# 9 x 5 football for the state cards.
BALL = """
..DDDDD..
.DBBWBBD.
DBWWWWWBD
.DBBWBBD.
..DDDDD..
"""
BALL_LEG = {"D": "#6B3410", "B": "#B5652B", "W": "#FFFFFF"}

# ------------------------------------------------------------ helpers
def ab(x):
    s = str(x if x != None else "").upper()
    return ALIAS.get(s, s)

def fit(c, text, fonts, maxw):
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

def sgn1(x):
    return ("+" if x >= 0 else "") + fl_fmt1(x)

def hero_w(c, s, font):
    w = 0
    for part in s.split("."):
        w += c.text_width(part, font)
    return w + (4 if "." in s else 0)

def draw_hero(c, s, x, y, font, col):
    """A number in a hero face with a hand-set 2 px point (the face's own
    '.' is a full-width cell)."""
    parts = s.split(".")
    c.text(parts[0], x, y, font = font, color = col)
    x += c.text_width(parts[0], font)
    if len(parts) > 1:
        h = {"10x16": 16, "9x12": 12, "6x8": 8, "5x7": 7}.get(font, 12)
        c.rect(x + 1, y + h - 2, x + 2, y + h - 1, fill = col)
        x += 4
        c.text(parts[1], x, y, font = font, color = col)
        x += c.text_width(parts[1], font)
    return x

def short_name(first, last):
    f = fl_clean(first)
    l = fl_clean(last)
    if l == "":
        return f
    if f == "":
        return l
    return f[:1] + ". " + l

# ------------------------------------------------------------ data
def st_std(b):
    """Team -> [points for per game, points against per game], from the ESPN
    NFL standings. Empty when the call fails, the budget is spent or no
    games are played yet (week 1)."""
    out = {}
    if b["n"] >= FL_MAX_CALLS:
        return out
    r = fl_get(b, STD_URL, ttl = TTL_STD)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return out
    stack = [r["json"]]
    for _ in range(12):
        nxt = []
        for n in stack:
            if type(n) != "dict":
                continue
            for e in fl_d(fl_d(n, "standings", {}), "entries", []):
                t = ab(fl_d(fl_d(e, "team", {}), "abbreviation", ""))
                v = {}
                for s in fl_d(e, "stats", []):
                    v[str(fl_d(s, "name", ""))] = fl_num(fl_d(s, "value", 0), 0)
                g = v.get("wins", 0) + v.get("losses", 0) + v.get("ties", 0)
                if t != "" and g > 0:
                    out[t] = [v.get("pointsFor", 0) / (g * 1.0), v.get("pointsAgainst", 0) / (g * 1.0)]
            nxt.extend([ch for ch in fl_d(n, "children", [])])
        stack = nxt
        if len(stack) == 0:
            break
    return out

def st_rows(b, season, week, positions):
    """One Sleeper projection feed for the given positions."""
    if b["n"] >= FL_MAX_CALLS:
        return None
    q = "?season_type=regular&order_by=pts_ppr" + "".join(["&position[]=" + p for p in positions])
    r = fl_get(b, FL_SLEEPER_API + "projections/nfl/" + str(season) + "/" + str(week) + q, ttl = FL_TTL_PROJ)
    if r["status_code"] != 200 or type(r["json"]) != "list":
        return None
    return r["json"]

def st_sched(rows):
    """From the DEF rows: team -> {opp, date, allow (projected points the
    defence gives up = the opponent's implied points), sack}."""
    out = {}
    for row in rows:
        if str(fl_d(fl_d(row, "player", {}), "position", "")) != "DEF":
            continue
        t = ab(fl_d(row, "team", fl_d(row, "player_id", "")))
        o = ab(fl_d(row, "opponent", ""))
        if t == "" or o == "":
            continue
        st = fl_d(row, "stats", {})
        out[t] = {"opp": o, "date": str(fl_d(row, "date", "")),
                  "allow": fl_num(fl_d(st, "pts_allow", -1), -1), "sack": fl_num(fl_d(st, "sack", -1), -1)}
    return out

def st_games(ctx, lg, week = None):
    """The adapter's NFL slate (fl_nfl_games), keyed by the logo codes this
    app uses: club -> {opp, home, kickoff_unix, day, done, bye}."""
    if lg["budget"]["n"] >= FL_MAX_CALLS:
        return {}
    g = fl_nfl_games(ctx, lg, week)
    out = {}
    for k, v in g.items():
        v2 = dict(v)
        v2["opp"] = ab(v.get("opp", ""))
        out[ab(k)] = v2
    return out

def st_new(lg):
    return {"slots": {"DEF": 1, "K": 1, "TE": 1, "QB": 1}, "sf": False, "cands": {}, "mine": {},
            "mine_all": {}, "sched": {}, "games": {}, "std": {}, "compare": False, "state": "ok"}

def st_load(ctx):
    # No fantasy scores needed up front: the app fetches this week's
    # matchup itself, and only once a game has kicked off.
    lg = fl_load(ctx, projections = False, matchups = False)
    if not lg["ok"]:
        return [lg, None]
    if lg["state"] == "demo":
        return [lg, st_demo(lg)]
    if lg["state"] == "predraft":
        return [lg, None]
    d = st_new(lg)
    if lg["platform"] == "SLEEPER":
        st_sleeper(ctx, lg, d)
    else:
        st_espn(ctx, lg, d)
    st_resolve(d)
    return [lg, d]

def st_et_weekday(ctx):
    return ((ctx.now.unix - 4 * 3600) // 86400 + 3) % 7      # Mon = 0

def st_lock(ctx, d, team, date):
    """'' still to play, 'live' kicked off, 'done' over. The slate's kickoff
    decides; without it, the game date plus the Eastern hour (Sunday from
    1 pm, Thursday and Monday nights from 8 pm)."""
    g = d["games"].get(team, None)
    if g != None and not g["bye"] and g["kickoff_unix"] > 0:
        if ctx.now.unix < g["kickoff_unix"]:
            return ""
        return "done" if g["done"] else "live"
    if date == "":
        return ""
    et = fl_et_date(ctx)
    if date < et[0]:
        return "done"
    if date == et[0]:
        wd = st_et_weekday(ctx)
        if (wd == 6 and et[1] >= 13) or (wd in [0, 3] and et[1] >= 20):
            return "live"
    return ""

def st_score(lg, stats):
    """fl_score, plus the aggregate kicker miss the feed lacks: Sleeper
    projects fgmiss_30_39 / 40_49 / 50p but 137 test leagues score plain
    `fgmiss` - sum the buckets into it when the league prices it."""
    st = stats if type(stats) == "dict" else {}
    ss = fl_d(fl_d(lg, "raw", {}), "scoring", {})
    if type(ss) == "dict" and fl_num(ss.get("fgmiss", 0), 0) != 0 and "fgmiss" not in st:
        miss = 0.0
        for k in ["fgmiss_0_19", "fgmiss_20_29", "fgmiss_30_39", "fgmiss_40_49", "fgmiss_50p"]:
            miss += fl_num(st.get(k, 0), 0)
        if miss > 0:
            st = dict(st)
            st["fgmiss"] = miss
    return fl_score(lg, st)

# ------------------------------------------------------------ Sleeper
def st_slot_counts(rp):
    n = {"QB": 0, "TE": 0, "K": 0, "DEF": 0, "SUPER_FLEX": 0}
    for p in rp:
        p = str(p)
        if p in n:
            n[p] += 1
    return n

def st_sleeper(ctx, lg, d):
    """Budget: adapter 3 (followed ID 5-6), projection feed 1, NFL slate
    1, this week's matchup 1 (only once a game has kicked off), standings
    1 = 7. Anything past the 8th is skipped and degrades."""
    b = lg["budget"]
    raw = lg["raw"]
    season = lg["season"]
    week = lg["week"]
    # Roster slots: adapter v2.1 carries roster_positions (no request).
    rp = raw.get("roster_positions", None)
    slotpos = []
    if type(rp) == "list" and len(rp) > 0:
        n = st_slot_counts(rp)
        d["slots"] = {"DEF": n["DEF"], "K": n["K"], "TE": n["TE"], "QB": n["QB"] + n["SUPER_FLEX"]}
        d["sf"] = n["SUPER_FLEX"] > 0 or n["QB"] >= 2
        slotpos = [str(p) for p in rp if str(p) not in ["BN", "IR", "TAXI"]]
    want = [p for p in ["QB", "TE", "K"] if d["slots"][p] > 0] + ["DEF"]
    rows = st_rows(b, season, week, want)
    if rows == None:
        d["state"] = "noproj"
        return
    d["sched"] = st_sched(rows)
    d["games"] = st_games(ctx, lg)
    taken = {}
    mine = None
    for ro in raw["rosters"]:
        for k in ["players", "reserve", "taxi"]:
            ps = fl_d(ro, k, [])
            if type(ps) == "list":
                for p in ps:
                    taken[str(p)] = True
        if fl_d(ro, "roster_id", None) == lg["me"]:
            mine = ro
    byid = {}
    for row in rows:
        byid[str(fl_d(row, "player_id", ""))] = row
    # Free agents: not kicked off yet, not out, projected above 0.
    cands = {}
    for row in rows:
        pid = str(fl_d(row, "player_id", ""))
        pl = fl_d(row, "player", {})
        pos = str(fl_d(pl, "position", ""))
        if pos not in ["QB", "TE", "K", "DEF"] or pid == "" or pid in taken:
            continue
        if d["slots"].get(pos, 0) == 0:
            continue
        team = ab(fl_d(row, "team", ""))
        g = d["games"].get(team, None)
        opp = ab(fl_d(row, "opponent", ""))
        if opp == "" or (g != None and g["bye"]):
            continue
        if st_lock(ctx, d, team, str(fl_d(row, "date", ""))) != "":
            continue
        inj = str(fl_d(pl, "injury_status", "")).upper()
        if inj in ["OUT", "IR", "PUP", "SUS", "DOUBTFUL", "DNR", "NA"]:
            continue
        pts = st_score(lg, fl_d(row, "stats", {}))
        if pts <= 0:
            continue
        name = NICK.get(team, team) if pos == "DEF" else short_name(fl_d(pl, "first_name", ""), fl_d(pl, "last_name", ""))
        cands.setdefault(pos, []).append(st_cand(pos, team, g["opp"] if g != None else opp, pts, name,
                                                 fl_num(fl_d(fl_d(row, "stats", {}), "sack", -1), -1), g))
    for pos in list(cands.keys()):
        cands[pos] = sorted(cands[pos], key = lambda x: -x["proj"])[:2]
    d["cands"] = cands
    # This week's lineup + points, once anything has kicked off (a slot
    # whose player already played is locked - compare on what he scored).
    kicked = False
    for g in d["games"].values():
        if not g["bye"] and g["kickoff_unix"] > 0 and g["kickoff_unix"] <= ctx.now.unix:
            kicked = True
    if len(d["games"]) == 0:
        for s in d["sched"].values():
            if st_lock(ctx, d, "", s["date"]) != "":
                kicked = True
    mrow = None
    if kicked and mine != None and lg["me_matched"] and b["n"] < FL_MAX_CALLS:
        rm = fl_get(b, FL_SLEEPER + "league/" + str(raw["league_id"]) + "/matchups/" + str(week), ttl = FL_TTL_LIVE)
        if rm["status_code"] == 200 and type(rm["json"]) == "list":
            for m in rm["json"]:
                if fl_d(m, "roster_id", None) == lg["me"]:
                    mrow = m
    d["std"] = st_std(b)
    # Your starters, slot by slot (starters line up with roster_positions).
    if mine == None or not lg["me_matched"] or len(slotpos) == 0:
        return
    starters = fl_d(mrow, "starters", None) if mrow != None else None
    if type(starters) != "list":
        starters = fl_d(mine, "starters", [])
    spts = fl_d(mrow, "starters_points", []) if mrow != None else []
    if type(spts) != "list":
        spts = []
    if type(starters) != "list" or len([s for s in starters if str(s) not in ["0", ""]]) == 0:
        return                      # guillotine team already cut, or no lineup
    d["compare"] = True
    for i in range(len(starters)):
        if i >= len(slotpos):
            break
        slot = slotpos[i]
        pos = "QB" if slot == "SUPER_FLEX" else slot
        if pos not in ["QB", "TE", "K", "DEF"]:
            continue
        pid = str(starters[i])
        if pid in ["0", ""]:
            if slot != "SUPER_FLEX" or d["sf"]:
                st_mine(d, pos, 0.0, "EMPTY")
            continue
        row = byid.get(pid, None)
        if row == None:
            if slot == "SUPER_FLEX":
                continue            # an RB / WR in the superflex: not a QB swap
            note = "OUT"
            if pos == "DEF":
                # A DEF's pid is its club code, and a DEF on bye has no row.
                t = ab(pid)
                g = d["games"].get(t, None)
                if (g != None and g["bye"]) or (g == None and len(d["sched"]) > 0 and t not in d["sched"]):
                    note = "BYE"
            st_mine(d, pos, 0.0, note)
            continue
        pl = fl_d(row, "player", {})
        if slot == "SUPER_FLEX" and str(fl_d(pl, "position", "")) != "QB":
            continue
        team = ab(fl_d(row, "team", ""))
        g = d["games"].get(team, None)
        if (g != None and g["bye"]) or (g == None and fl_d(row, "opponent", None) == None and team != "" and
                                        len(d["sched"]) > 0 and team not in d["sched"]):
            st_mine(d, pos, 0.0, "BYE")
            continue
        if fl_d(row, "opponent", None) == None or str(fl_d(pl, "injury_status", "")).upper() in FL_OUT:
            st_mine(d, pos, 0.0, "OUT")
            continue
        lk = st_lock(ctx, d, team, str(fl_d(row, "date", "")))
        if lk != "":
            act = fl_num(spts[i], -1) if i < len(spts) else -1
            st_mine(d, pos, act, "SCORED" if lk == "done" else "LIVE", True)
            continue
        st_mine(d, pos, st_score(lg, fl_d(row, "stats", {})), "")

def st_cand(pos, team, opp, pts, name, sack, g):
    return {"pos": pos, "team": team, "opp": opp, "proj": pts, "name": name, "sack": sack,
            "home": g["home"] if g != None else None, "day": g["day"] if g != None else ""}

def st_mine(d, pos, pts, note, locked = False):
    d["mine_all"].setdefault(pos, []).append({"proj": pts, "note": note, "locked": locked})

def st_resolve(d):
    """The starter a stream replaces: the weakest one whose slot is still
    open. A position whose every starter already played is locked."""
    for pos, xs in d["mine_all"].items():
        open_ = [x for x in xs if not x["locked"]]
        if len(open_) > 0:
            d["mine"][pos] = sorted(open_, key = lambda x: x["proj"])[0]
        else:
            d["mine"][pos] = xs[0]

# ------------------------------------------------------------ ESPN
ESPN_SLOT = {"QB": 0, "TE": 6, "K": 17, "DEF": 16}
ESPN_ID = {"ATL": 1, "BUF": 2, "CHI": 3, "CIN": 4, "CLE": 5, "DAL": 6, "DEN": 7, "DET": 8,
           "GB": 9, "TEN": 10, "IND": 11, "KC": 12, "LV": 13, "LAR": 14, "MIA": 15, "MIN": 16,
           "NE": 17, "NO": 18, "NYG": 19, "NYJ": 20, "PHI": 21, "ARI": 22, "PIT": 23, "LAC": 24,
           "SF": 25, "SEA": 26, "TB": 27, "WSH": 28, "CAR": 29, "JAX": 30, "BAL": 33, "HOU": 34}

def st_espn(ctx, lg, d):
    """Budget: adapter 1, Sleeper DEF feed 1 (implied points + sacks), NFL
    slate 1, one free-agent call per slot (DEF, K, TE, QB) 4, standings 1
    = 8."""
    b = lg["budget"]
    raw = lg["raw"]
    j = raw["json"]
    counts = fl_d(fl_d(fl_d(j, "settings", {}), "rosterSettings", {}), "lineupSlotCounts", {})
    def cnt(k):
        return int(fl_num(fl_d(counts, k, 0), 0))
    if len(counts) > 0:
        d["slots"] = {"DEF": cnt("16"), "K": cnt("17"), "TE": cnt("6"), "QB": cnt("0") + cnt("7")}
        d["sf"] = cnt("7") > 0 or cnt("0") >= 2
    week = int(fl_num(fl_d(j, "scoringPeriodId", lg["week"]), lg["week"]))
    rows = st_rows(b, lg["season"], week, ["DEF"])
    if rows != None:
        d["sched"] = st_sched(rows)
    d["games"] = st_games(ctx, lg, week)
    cands = {}
    for pos in ["DEF", "K", "TE", "QB"]:
        if d["slots"][pos] == 0:
            continue
        got = st_espn_fa(ctx, b, raw, lg["season"], week, pos, d)
        if got == None:
            break                   # private / budget: stop asking
        if len(got) > 0:
            cands[pos] = got
    d["cands"] = cands
    d["std"] = st_std(b)
    if len(cands) == 0 and b["n"] >= FL_MAX_CALLS:
        d["state"] = "noproj"
    # Your starters come with the adapter's call (no names or clubs: a
    # starter projected 0 is on bye or out, an actual stat line = played).
    if not lg["me_matched"]:
        return
    for m in fl_d(j, "schedule", []):
        if int(fl_num(fl_d(m, "matchupPeriodId", 0))) != lg["week"]:
            continue
        for side in ["home", "away"]:
            s = fl_d(m, side, None)
            if s == None or fl_d(s, "teamId", None) != lg["me"]:
                continue
            ro = fl_d(s, "rosterForCurrentScoringPeriod", None)
            if ro == None:
                continue
            d["compare"] = True
            seen = {}
            for e in fl_d(ro, "entries", []):
                slot = int(fl_num(fl_d(e, "lineupSlotId", 20), 20))
                seen[slot] = seen.get(slot, 0) + 1
                pos = {0: "QB", 7: "QB", 6: "TE", 17: "K", 16: "DEF"}.get(slot, "")
                if pos == "":
                    continue
                pl = fl_d(fl_d(e, "playerPoolEntry", {}), "player", {})
                if slot == 7 and not st_espn_is_qb(pl, week):
                    continue        # a RB / WR in the superflex
                act = st_espn_stat(pl, week, 0)
                pj = st_espn_stat(pl, week, 1)
                if act != None:
                    st_mine(d, pos, act, "SCORED", True)
                elif pj == None or pj <= 0:
                    st_mine(d, pos, 0.0, "PROJ0")
                else:
                    st_mine(d, pos, pj, "")
            # An empty slot has no entry at all: count against the settings.
            for sl, pos in [[0, "QB"], [6, "TE"], [17, "K"], [16, "DEF"], [7, "QB"]]:
                if sl == 7 and not d["sf"]:
                    continue
                for _ in range(cnt(str(sl)) - seen.get(sl, 0)):
                    st_mine(d, pos, 0.0, "EMPTY")

def st_espn_stat(pl, week, src):
    for s in fl_d(pl, "stats", []):
        if int(fl_num(fl_d(s, "statSourceId", -1), -1)) == src and int(fl_num(fl_d(s, "scoringPeriodId", 0))) == week:
            return fl_num(fl_d(s, "appliedTotal", 0))
    return None

def st_espn_is_qb(pl, week):
    """The matchup roster has no position: a superflex starter is a QB when
    he is projected 10+ pass attempts (ESPN stat 0)."""
    for s in fl_d(pl, "stats", []):
        if int(fl_num(fl_d(s, "statSourceId", -1), -1)) == 1 and int(fl_num(fl_d(s, "scoringPeriodId", 0))) == week:
            return fl_num(fl_d(fl_d(s, "stats", {}), "0", 0), 0) >= 10
    return False

def st_espn_fa(ctx, b, raw, season, week, pos, d):
    """Top free agents / waiver players at one slot, by the league's own
    projection, from clubs still to kick off. None = the call failed
    (stop), [] = nobody playable."""
    if b["n"] >= FL_MAX_CALLS:
        return None
    # Once games are under way, ask only for the clubs still to play (on a
    # Monday that's the MNF teams - they'd sit below the page otherwise).
    teams = ""
    if len(d["games"]) > 0:
        ids = []
        started = False
        for t, g in d["games"].items():
            if t not in ESPN_ID or g["bye"]:
                continue
            if g["kickoff_unix"] > 0 and g["kickoff_unix"] <= ctx.now.unix:
                started = True
            else:
                ids.append(str(ESPN_ID[t]))
        if started and len(ids) > 0:
            teams = ',"filterProTeamIds":{"value":[' + ",".join(sorted(ids)) + ']}'
    flt = ('{"players":{"filterStatus":{"value":["FREEAGENT","WAIVERS"]},"filterSlotIds":{"value":[' +
           str(ESPN_SLOT[pos]) + ']}' + teams + ',"sortAppliedStatTotal":{"sortAsc":false,"sortPriority":1,"value":"11' +
           str(season) + str(week) + '"},"filterStatsForTopScoringPeriodIds":{"value":1,"additionalValue":["11' +
           str(season) + str(week) + '"]},"limit":8}}')
    h = dict(raw["cookie"])
    h["x-fantasy-filter"] = flt
    r = fl_get(b, FL_ESPN + str(season) + "/segments/0/leagues/" + str(raw["league_id"]) +
               "?view=kona_player_info&scoringPeriodId=" + str(week), headers = h, ttl = TTL_FA)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    out = []
    for p in fl_d(r["json"], "players", []):
        pl = fl_d(p, "player", {})
        team = ESPN_PRO.get(int(fl_num(fl_d(pl, "proTeamId", 0), 0)), "")
        if team == "":
            continue
        inj = str(fl_d(pl, "injuryStatus", "")).upper()
        if inj in ["OUT", "INJURY_RESERVE", "SUSPENSION", "DOUBTFUL"]:
            continue
        g = d["games"].get(team, None)
        s = d["sched"].get(team, None)
        if g != None and g["bye"]:
            continue
        if g == None and len(d["sched"]) > 0 and s == None:
            continue                # bye (no slate: the DEF feed decides)
        if st_lock(ctx, d, team, s["date"] if s != None else "") != "":
            continue
        pts = st_espn_stat(pl, week, 1)
        if pts == None or pts <= 0:
            continue
        opp = g["opp"] if g != None else (s["opp"] if s != None else "")
        name = NICK.get(team, team) if pos == "DEF" else short_name(fl_d(pl, "firstName", ""), fl_d(pl, "lastName", ""))
        out.append(st_cand(pos, team, opp, pts, name, s["sack"] if (pos == "DEF" and s != None) else -1, g))
    return sorted(out, key = lambda x: -x["proj"])[:2]

# ------------------------------------------------------------ demo
def st_demo(lg):
    d = st_new(lg)
    d["compare"] = True
    def c(pos, team, opp, pts, name, sack, home, day):
        return {"pos": pos, "team": team, "opp": opp, "proj": pts, "name": name, "sack": sack,
                "home": home, "day": day}
    d["cands"] = {
        "DEF": [c("DEF", "SEA", "TEN", 9.4, "SEAHAWKS", 3.1, True, "SUN"),
                c("DEF", "CIN", "CLE", 7.9, "BENGALS", 2.6, False, "SUN")],
        "K": [c("K", "KC", "LV", 9.1, "H. BUTKER", -1, True, "SNF"),
              c("K", "DET", "CHI", 8.6, "J. BATES", -1, False, "SUN")],
        "TE": [c("TE", "DAL", "NYG", 9.8, "J. FERGUSON", -1, False, "MNF"),
               c("TE", "TB", "CAR", 8.2, "C. OTTON", -1, True, "SUN")],
    }
    d["mine"] = {"DEF": {"proj": 6.0, "note": "", "locked": False},
                 "K": {"proj": 8.4, "note": "", "locked": False},
                 "TE": {"proj": 7.1, "note": "", "locked": False},
                 "QB": {"proj": 21.4, "note": "", "locked": False}}
    d["sched"] = {"KC": {"opp": "LV", "date": "", "allow": 20.5, "sack": -1},
                  "LV": {"opp": "KC", "date": "", "allow": 27.4, "sack": -1},
                  "DET": {"opp": "CHI", "date": "", "allow": 22.0, "sack": -1},
                  "CHI": {"opp": "DET", "date": "", "allow": 26.1, "sack": -1}}
    d["std"] = {"TEN": [16.2, 25.0], "CLE": [17.5, 23.1], "NYG": [18.0, 26.4], "CAR": [19.5, 27.2],
                "KC": [27.0, 19.0], "DET": [28.5, 21.0]}
    return d

# ------------------------------------------------------------ picks
ORDER = ["QB", "DEF", "K", "TE"]

def st_picks(d):
    """[ranked picks, any beats your starter]. With your team set, ranked by
    points over the starter at that slot (a locked slot last); otherwise by
    position. Each position's best first, then the runners-up. A QB in a
    1-QB league only shows when he beats your starter."""
    firsts = []
    seconds = []
    for pos in ORDER:
        cs = d["cands"].get(pos, [])
        m = d["mine"].get(pos, None)
        for i in range(len(cs)):
            p = dict(cs[i])
            p["locked"] = d["compare"] and m != None and m["locked"]
            p["gain"] = p["proj"] - m["proj"] if (d["compare"] and m != None and not p["locked"]) else None
            p["mine"] = m
            if pos == "QB" and not d["sf"] and (p["gain"] == None or p["gain"] <= 0.05):
                continue
            if i == 0:
                firsts.append(p)
            else:
                seconds.append(p)
    if d["compare"]:
        def gk(p):
            if p["locked"]:
                return 999.0
            return -(p["gain"] if p["gain"] != None else -99.0)
        firsts = sorted(firsts, key = gk)
        seconds = sorted(seconds, key = gk)
    picks = firsts + seconds
    beats = len([p for p in firsts if p["gain"] != None and p["gain"] > 0.05]) > 0
    return [picks, beats]

def reason(p, d, short = False):
    """The matchup line (short: the board's narrow columns)."""
    pos = p["pos"]
    opp = p["opp"]
    sd = d["std"]
    sc = d["sched"]
    if pos == "DEF":
        if opp in sd:
            t = ("OPP " if short else "OPP SCORES ") + fl_fmt1(sd[opp][0]) + " PPG"
        elif p["team"] in sc and sc[p["team"]]["allow"] >= 0:
            t = "ALLOWS " + fl_fmt1(sc[p["team"]]["allow"]) + ("" if short else " PROJ")
        else:
            t = "VS " + (opp if short else NICK.get(opp, opp))
        if p["sack"] >= 0 and not short:
            t += "  " + fl_fmt1(p["sack"]) + " SACKS"
        return t
    if pos == "K":
        if opp in sc and sc[opp]["allow"] >= 0:
            return ("IMPLIED " if short else "TEAM IMPLIED ") + fl_fmt1(sc[opp]["allow"]) + ("" if short else " PTS")
        if p["team"] in sd:
            return ("SCORES " if short else "TEAM SCORES ") + fl_fmt1(sd[p["team"]][0]) + " PPG"
        return "VS " + (opp if short else NICK.get(opp, opp))
    if opp in sd:
        # Total points the opponent concedes, not points to the position.
        return "GIVES UP " + fl_fmt1(sd[opp][1]) if short else "OPP GIVES UP " + fl_fmt1(sd[opp][1]) + " PPG"
    if opp in sc and sc[opp]["allow"] >= 0:
        return ("IMPLIED " if short else "TEAM IMPLIED ") + fl_fmt1(sc[opp]["allow"]) + ("" if short else " PTS")
    return "VS " + (opp if short else NICK.get(opp, opp))

def mine_line(p):
    """What the stub says about your starter, two short lines."""
    pos = p["pos"]
    m = p["mine"]
    note = m["note"] if m != None else ""
    up = p["gain"] != None and p["gain"] > 0.05
    if note == "BYE":
        return ["YOUR " + pos, "ON BYE"]
    if note == "OUT":
        return ["YOUR " + pos, "IS OUT"]
    if note == "EMPTY":
        return ["YOUR " + pos, "IS EMPTY"]
    if note == "PROJ0":
        return ["YOUR " + pos, "PROJ 0.0"]
    if up:
        return ["OVER", "YOUR " + pos]
    return ["VS", "YOUR " + pos]

# ------------------------------------------------------------ the ticket
# The panel is one printed game ticket: a main ticket (x 6-137) in the
# streamer club's card stock and a tear-off stub (x 139-185) whose colour
# is the verdict, split by a perforated tear line with half-moon notches.
TL = 6              # ticket left edge: every lit pixel stays in x 6-185
TR = 185            # ticket right edge
PERF = 138          # the tear line
MX = 10             # main ticket print area (club stripe at x 6-7)
MR = 134
SX = PERF + 3       # stub print area, 2 px inside the stub edges
SR = TR - 2
SC = (SX + SR) // 2 # 162: stub centre
MC = (MX + MR) // 2 # 72: main ticket centre

FOIL = "#E8C15A"    # the printed field plates (POS / PROJ / VS)
PRINT = "#C9D1E0"   # fine print on the stock
STUB_ADD = GOOD
STUB_HOLD = "#4A5266"
STUB_LOCK = "#2E3440"
STUB_VOID = "#3C4043"
CARD_STOCK = "#262B36"
STOCK_PCT = 18      # club colour at 18 %: tinted card stock the logos still pop on

# The pick's fields: POS, PROJ and the VS plate between the two club logos.
F_POS = [MX, MX + 19]           # 10-29
F_PROJ = [MX + 23, MX + 53]     # 33-63
LOGO_A = 67                     # streamer club 24 x 18
F_VS = [92, 108]
LOGO_B = 110                    # opponent 24 x 18
PLATE_Y = 7                     # plates y 7-12, 3x4 text at 8
LOGO_Y = 7                      # logos y 7-24

def ticket(c, stock, stub, band = None):
    """Card stock, stub, perforated tear line, notched corners; band = the
    club-colour stripe printed down the left edge."""
    c.fill("black")
    c.rect(TL, 0, PERF - 1, 31, fill = stock)
    if band != None:
        c.rect(TL, 0, TL + 1, 31, fill = band)
    c.rect(PERF + 1, 0, TR, 31, fill = stub)
    for y in range(3, 29, 2):
        c.pixel(PERF, y, stub)          # dashes of stub between black holes
    # Half-moon notches where the tear line meets the edges.
    for i in range(3):
        c.rect(PERF - 3 + i, i, PERF + 3 - i, i, fill = "black")
        c.rect(PERF - 3 + i, 31 - i, PERF + 3 - i, 31 - i, fill = "black")
    # Clipped corners.
    for x in [TL, TR]:
        d = 1 if x == TL else -1
        for y in [0, 31]:
            e = 1 if y == 0 else -1
            c.pixel(x, y, "black")
            c.pixel(x + d, y, "black")
            c.pixel(x, y + e, "black")

def plate(c, word, x0, x1):
    """A printed foil field label, black 3x4 text centred in it."""
    c.rect(x0, PLATE_Y, x1, PLATE_Y + 5, fill = FOIL)
    c.text(word, (x0 + x1 + 1) // 2, PLATE_Y + 1, font = "3x4", color = "black", align = "center")

def top_tag(c, lg):
    """WEEK n (or DEMO) printed top right of the main ticket; returns its width."""
    demo = lg["state"] == "demo"
    tag = "DEMO" if demo else "WEEK " + str(lg["week"])
    f = "3x4" if demo else "4x5"
    c.text(tag, MR, 1, font = f, color = AMBER if demo else PRINT, align = "right")
    return c.text_width(tag, f)

def line_fit(c, name, maxw):
    """'J. FERGUSON' in 4x5; too long -> the last name, then clipped."""
    if c.text_width(name, "4x5") <= maxw:
        return name
    if ". " in name:
        last = name[name.find(". ") + 2:]
        if c.text_width(last, "4x5") <= maxw:
            return last
        name = last
    return fit(c, name, ["4x5"], maxw)[0]

def centre_hero(c, s, x0, x1, fonts, y_for):
    """The first face in which s fits between x0 and x1, centred."""
    for f in fonts:
        w = hero_w(c, s, f)
        if w <= x1 - x0 + 1 or f == fonts[len(fonts) - 1]:
            draw_hero(c, s, (x0 + x1 + 1) // 2 - w // 2, y_for[f], f, INK if y_for.get("ink") == None else y_for["ink"])
            return

def club_logo(c, team, x):
    if team in SMALL:
        c.image(SMALL[team], x, LOGO_Y)
    elif team != "":
        c.text(team, x + 12, LOGO_Y + 6, font = "5x7", color = INK, align = "center")

def stub_state(lg, p):
    """[stock, ink, big text, line 1, line 2, lock?] - the stub is the verdict."""
    pos = p["pos"]
    if p["locked"]:
        # Your starter at this slot already played: the slot is locked.
        m = p["mine"]
        a = m["proj"]
        big = fl_fmt1(a) if a >= 0 else ""
        verb = "PLAYING" if m["note"] == "LIVE" else ("SCORED" if big != "" else "PLAYED")
        return [STUB_LOCK, INK, big, "YOUR " + pos, verb, True]
    if p["gain"] != None:
        up = p["gain"] > 0.05
        ml = mine_line(p)
        return [STUB_ADD if up else STUB_HOLD, "black" if up else INK, sgn1(p["gain"]), ml[0], ml[1], False]
    if lg["state"] != "demo" and not lg["me_matched"] and lg["team_set"]:
        return [AMBER, "black", "TEAM", "NOT", "FOUND", False]
    return [POS_COLOR[pos], "black", POS_WORD[pos], "BEST ON", "THE WIRE", False]

def admit_one(c, ink):
    """ADMIT ONE along the top of the stub (3x4 has no space: two words)."""
    w1 = c.text_width("ADMIT", "3x4")
    x = SC - (w1 + 3 + c.text_width("ONE", "3x4")) // 2
    c.text("ADMIT", x, 1, font = "3x4", color = ink)
    c.text("ONE", x + w1 + 3, 1, font = "3x4", color = ink)

def draw_stub(c, st):
    ink = st[1]
    big = st[2]
    admit_one(c, ink)
    room = SR - SX + 1
    if st[5]:
        f = "9x12" if 9 + hero_w(c, big, "9x12") <= room else "6x8"
        w = 7 + (2 + hero_w(c, big, f) if big != "" else 0)
        x = SC - w // 2
        c.sprite(LOCK, x, 8, legend = LOCK_LEG)
        if big != "":
            draw_hero(c, big, x + 9, 6 if f == "9x12" else 8, f, ink)
    elif big != "":
        centre_hero(c, big, SX, SR, ["9x12", "6x8", "5x7"], {"9x12": 6, "6x8": 8, "5x7": 9, "ink": ink})
    for i in range(2):
        t = fit(c, st[3 + i], ["4x5"], room)[0]
        c.text(t, SC, 19 + 6 * i, font = "4x5", color = ink, align = "center")

# ------------------------------------------------------------ screens
def card(c, head, sub, stub, word, word_color):
    """A state screen: a blank grey ticket with the message printed on it
    and the stub stamped (VOID for errors, SOON / USED / NONE otherwise)."""
    ticket(c, CARD_STOCK, stub)
    h = fit(c, head, ["6x8", "5x7", "4x5"], MR - MX + 1)
    c.text(h[0], MC, 4, font = h[1], color = AMBER if stub == STUB_VOID else INK, align = "center")
    # The sub line, wrapped onto two lines at a space when it's too long.
    room = MR - MX + 1
    lines = [sub]
    if c.text_width(sub, "4x5") > room:
        words = sub.split(" ")
        for k in range(len(words) - 1, 0, -1):
            a = " ".join(words[:k])
            b = " ".join(words[k:])
            if c.text_width(a, "4x5") <= room and c.text_width(b, "4x5") <= room:
                lines = [a, b]
                break
    if len(lines) == 1:
        c.text(fit(c, sub, ["4x5"], room)[0], MC, 15, font = "4x5", color = PRINT, align = "center")
        c.sprite(BALL, MC - 4, 23, legend = BALL_LEG)
    else:
        c.text(lines[0], MC, 14, font = "4x5", color = PRINT, align = "center")
        c.text(lines[1], MC, 20, font = "4x5", color = PRINT, align = "center")
        c.sprite(BALL, MC - 4, 26, legend = BALL_LEG)
    admit_one(c, PRINT)
    w = fit(c, word, ["9x12", "6x8"], SR - SX + 1)
    c.text(w[0], SC, 12 if w[1] == "9x12" else 14, font = w[1], color = word_color, align = "center")

def state_screen(c, lg, d):
    if not lg["ok"]:
        card(c, lg["err"][0], lg["err"][1], STUB_VOID, "VOID", ALARM)
        return True
    if lg["state"] == "predraft":
        card(c, "DRAFT DAY AHEAD", "STREAMERS START AFTER YOUR DRAFT", GOOD_DK, "SOON", INK)
        return True
    if d == None or d["state"] == "noproj":
        card(c, "NO PROJECTIONS YET", "STREAMERS RETURN WHEN THEY POST", GOOD_DK, "SOON", INK)
        return True
    if len([p for p in ORDER if d["slots"].get(p, 0) > 0]) == 0:
        card(c, "NOTHING TO STREAM", "YOUR LEAGUE STARTS NO QB, DEF, K OR TE", GOOD_DK, "NONE", INK)
        return True
    if len(d["cands"]) == 0 and lg["month"] >= 2 and lg["month"] <= 8:
        card(c, "NFL OFFSEASON", "STREAMERS RETURN FOR WEEK 1", GOOD_DK, "SOON", INK)
        return True
    if len(d["cands"]) == 0:
        card(c, "WEEK " + str(lg["week"]) + " IS PLAYED", "NEW STREAMERS WHEN NEXT WEEK POSTS", GOOD_DK, "USED", INK)
        return True
    return False

def pick_frame(c, lg, d, p):
    pos = p["pos"]
    st = stub_state(lg, p)
    club = CLUB.get(p["team"], SLATE)
    ticket(c, color.dim(club, STOCK_PCT), st[0], club)
    # The event line: the player (or the defense's club), WEEK n / DEMO.
    tw = top_tag(c, lg)
    c.text(line_fit(c, p["name"], MR - MX - tw - 4), MX, 1, font = "4x5", color = INK)
    # POS and PROJ, seat-and-row style.
    plate(c, "POS", F_POS[0], F_POS[1])
    c.text(POS_WORD[pos], (F_POS[0] + F_POS[1] + 1) // 2, 15, font = "5x7", color = POS_COLOR[pos], align = "center")
    plate(c, "PROJ", F_PROJ[0], F_PROJ[1])
    centre_hero(c, fl_fmt1(p["proj"]), F_PROJ[0], F_PROJ[1], ["6x8", "5x7"], {"6x8": 14, "5x7": 15})
    # The game: streamer club VS / AT opponent, the day under the plate.
    club_logo(c, p["team"], LOGO_A)
    plate(c, "OPP" if p["home"] == None else ("VS" if p["home"] else "AT"), F_VS[0], F_VS[1])
    if p["day"] != "":
        dy = fit(c, p["day"], ["4x5", "3x4"], F_VS[1] - F_VS[0] + 1)
        c.text(dy[0], (F_VS[0] + F_VS[1] + 1) // 2, 15, font = dy[1],
               color = INK if p["day"] in ["TNF", "SNF", "MNF"] else PRINT, align = "center")
    club_logo(c, p["opp"], LOGO_B)
    # The fine print: why it's a good matchup.
    why = reason(p, d)
    if c.text_width(why, "4x5") > MR - MX + 1:
        why = why.replace("OPP SCORES ", "OPP ")        # keeps the sacks
    if c.text_width(why, "4x5") > MR - MX + 1:
        why = why.split("  ")[0]
    c.text(fit(c, why, ["4x5"], MR - MX + 1)[0], MX, 26, font = "4x5", color = PRINT)
    draw_stub(c, st)

def best_frame(c, lg, d):
    """No free agent beats any of your starters (or every slot is locked):
    your own team's ticket, crest printed on it, the stub says KEEP."""
    me = fl_team(lg, lg["me"])
    poss = [p for p in ORDER if p in d["mine"] and d["slots"].get(p, 0) > 0]
    locked = len(poss) > 0 and len([p for p in poss if not d["mine"][p]["locked"]]) == 0
    stock = color.dim(fl_badge_color(me), STOCK_PCT) if me != None else CARD_STOCK
    ticket(c, stock, STUB_LOCK if locked else STUB_ADD)
    right = MR
    if me != None:
        fl_badge(c, me, MR - 21, 6, 24)
        right = MR - 25
    if lg["state"] == "demo":
        c.text("DEMO", MR, 0, font = "3x4", color = AMBER, align = "right")
    ink = SLATE if locked else GOOD
    c.text("LINEUP LOCKED" if locked else "YOUR STARTERS", MX, 3, font = "6x8", color = ink)
    c.text("FOR THE WEEK" if locked else "ARE BEST", MX, 13, font = "6x8", color = ink)
    # One plate per slot checked, in the position colours, then the verdict.
    px = MX
    for p in poss:
        w = c.text_width(p, "4x5") + 4
        c.rect(px, 23, px + w - 1, 29, fill = POS_COLOR[p] if not d["mine"][p]["locked"] else SLATE)
        c.text(p, px + 2, 24, font = "4x5", color = "black")
        px += w + 2
    verdict = "NOTHING BETTER ON THE WIRE" if not locked else "ALL YOUR SLOTS HAVE PLAYED"
    if c.text_width(verdict, "4x5") > right - px - 2:
        verdict = "WIRE CHECKED" if not locked else "ALL PLAYED"
    if c.text_width(verdict, "4x5") <= right - px - 2:
        c.text(verdict, px + 2, 24, font = "4x5", color = PRINT)
    # The stub: a check (keep your lineup) or a padlock.
    ink2 = INK if locked else "black"
    admit_one(c, ink2)
    if locked:
        c.sprite(LOCK, SC - 7, 7, legend = LOCK_LEG, scale = 2)
        c.text("LOCKED", SC, 25, font = "4x5", color = ink2, align = "center")
    else:
        c.sprite(CHECK, SC - 8, 7, legend = {"G": "black"})
        c.text("KEEP", SC, 22, font = "4x5", color = ink2, align = "center")

def gain_chip(c, p, x, y):
    """Sprite + gain for the board; returns nothing."""
    if p["locked"]:
        c.sprite(LOCK, x + 1, y, legend = LOCK_LEG)
        return
    if p["gain"] == None:
        return
    up = p["gain"] > 0.05
    c.sprite(ADD if up else HOLD, x, y, legend = CHIP_LEG)

def mini_ticket(c, p, x0, x1):
    """A board column as a small ticket in the club's stock: the position
    colour as the stub edge on the left, notched corners."""
    c.rect(x0, 0, x1, 31, fill = color.dim(CLUB.get(p["team"], SLATE), STOCK_PCT))
    c.rect(x0, 0, x0 + 1, 31, fill = POS_COLOR[p["pos"]])
    for y in range(3, 29, 2):
        c.pixel(x0 + 2, y, "black")     # perforation beside the stub edge
    for y in [0, 31]:
        e = 1 if y == 0 else -1
        c.pixel(x1, y, "black")
        c.pixel(x1 - 1, y, "black")
        c.pixel(x1, y + e, "black")

def board_frame(c, lg, d, picks):
    """Every streaming slot side by side, one small ticket each: best free
    agent per position. One slot only -> its best two free agents."""
    c.fill("black")
    firsts = []
    seen = {}
    for p in picks:
        if p["pos"] not in seen:
            seen[p["pos"]] = True
            firsts.append(p)
    firsts = sorted(firsts, key = lambda p: ORDER.index(p["pos"]))
    if len(firsts) == 1:
        firsts = [p for p in picks if p["pos"] == firsts[0]["pos"]][:2]
    n = len(firsts)
    if n == 0:
        return
    pitch = (TR - TL + 2) // n
    for i in range(n):
        x = TL + i * pitch
        mini_ticket(c, firsts[i], x, x + pitch - 2)
    if n >= 3:
        compact = n >= 4
        for i in range(n):
            board_col(c, firsts[i], TL + i * pitch, pitch, compact, lg["state"] == "demo" and i == n - 1)
        # (The demo league streams three slots, so a demo board is never compact.)
        if lg["state"] == "demo" and not compact:
            c.text("DEMO", TL + n * pitch - 5, 26, font = "3x4", color = AMBER, align = "right")
        return
    for i in range(n):
        board_wide(c, d, firsts[i], TL + i * pitch, pitch, lg["state"] == "demo" and i == n - 1)
    if lg["state"] == "demo":
        c.text("DEMO", TL + n * pitch - 5, 27, font = "3x4", color = AMBER, align = "right")

def board_col(c, p, x, pitch, compact, demo = False):
    pc = POS_COLOR[p["pos"]]
    right = x + pitch - 5            # 2 px inside the ticket's right edge
    up = p["gain"] != None and p["gain"] > 0.05
    if compact:
        # 44 px tickets: logo, the position and gain right-aligned beside
        # it, the projection under it.
        cr = x + pitch - 3               # text ends 1 px inside the edge
        if p["team"] in SMALL:
            c.image(SMALL[p["team"]], x + 3, 1)
        c.text(POS_WORD[p["pos"]], cr, 2, font = "4x5", color = pc, align = "right")
        draw_hero(c, fl_fmt1(p["proj"]), x + 5, 22, "6x8", INK)
        if p["locked"]:
            c.sprite(LOCK, cr - 6, 9, legend = LOCK_LEG)
        elif p["gain"] != None:
            g = sgn1(p["gain"])
            if c.text_width(g, "3x4") > cr - (x + 28):
                g = ("+" if p["gain"] >= 0 else "") + str(int(p["gain"] + (0.5 if p["gain"] >= 0 else -0.5)))
            c.text(g, cr, 10, font = "3x4", color = GOOD if up else PRINT, align = "right")
        return
    if p["team"] in SMALL:
        c.image(SMALL[p["team"]], x + 5, 1)
    tx = x + 32
    c.text(POS_WORD[p["pos"]], tx, 1, font = "5x7", color = pc)
    ps = fl_fmt1(p["proj"])
    if hero_w(c, ps, "9x12") <= right - tx + 1:
        draw_hero(c, ps, tx, 10, "9x12", INK)
    else:
        draw_hero(c, ps, tx, 12, "6x8", INK)
    if p["locked"]:
        c.sprite(LOCK, x + 6, 22, legend = LOCK_LEG)
        a = p["mine"]["proj"]
        if a >= 0:
            t = fl_fmt1(a)
            f = "5x7" if c.text_width(t, "5x7") <= right - (x + 17) + 1 - (18 if demo else 0) else "4x5"
            c.text(t, x + 17, 23 if f == "5x7" else 24, font = f, color = PRINT)
    elif p["gain"] != None:
        gain_chip(c, p, x + 5, 22)
        g = sgn1(p["gain"])
        f = "5x7" if c.text_width(g, "5x7") <= right - (x + 17) + 1 - (18 if demo else 0) else "4x5"
        c.text(g, x + 17, 23 if f == "5x7" else 24, font = f, color = GOOD if up else PRINT)
    else:
        mw = right - (x + 5) + 1 - (18 if demo else 0)
        s = p["name"]
        if c.text_width(s, "4x5") > mw and ". " in s:
            s = s[s.find(". ") + 2:]
        nm = fit(c, s, ["4x5"], mw)
        c.text(nm[0], x + 5, 24, font = "4x5", color = PRINT)

def board_wide(c, d, p, x, pitch, demo):
    """A 92 px ticket (one or two streaming slots): logo, position, the
    projection and the chip on top; the name with VS / @ opponent, then the
    reason, underneath."""
    pc = POS_COLOR[p["pos"]]
    right = x + pitch - 6
    if p["team"] in SMALL:
        c.image(SMALL[p["team"]], x + 5, 0)
    tx = x + 32
    c.text(POS_WORD[p["pos"]], tx, 1, font = "4x5", color = pc)
    hx = draw_hero(c, fl_fmt1(p["proj"]), tx, 7, "9x12", INK)
    # Chip beside the position, the gain (or your starter's score) under it.
    up = p["gain"] != None and p["gain"] > 0.05
    g = ""
    if p["locked"]:
        a = p["mine"]["proj"]
        g = fl_fmt1(a) if a >= 0 else ""
    elif p["gain"] != None:
        g = sgn1(p["gain"])
    f = "5x7"
    if c.text_width(g, f) > right - hx - 6:
        f = "4x5"
    if c.text_width(g, f) > right - hx - 6 and p["gain"] != None:
        g = ("+" if p["gain"] >= 0 else "") + str(int(p["gain"] + (0.5 if p["gain"] >= 0 else -0.5)))
    if p["locked"]:
        c.sprite(LOCK, right - 7, 0, legend = LOCK_LEG)
    elif p["gain"] != None:
        c.sprite(ADD if up else HOLD, right - 8, 0, legend = CHIP_LEG)
    if g != "":
        c.text(g, right, 11, font = f, color = GOOD if up else PRINT, align = "right")
    # Name + VS / @ opponent.
    om = p["opp"]
    if om != "" and p["home"] != None:
        om = ("VS " if p["home"] else "@ ") + om
    ow = c.text_width(om, "4x5") if om != "" else 0
    nm = line_fit(c, p["name"], right - (x + 5) - ow - 4)
    c.text(nm, x + 5, 20, font = "4x5", color = INK)
    if om != "":
        c.text(om, right, 20, font = "4x5", color = PRINT, align = "right")
    rs = fit(c, reason(p, d, True), ["4x5"], right - (x + 5) - (18 if demo else 0))
    c.text(rs[0], x + 5, 26, font = "4x5", color = FOIL)

# ------------------------------------------------------------ pages
def page(c, ctx, k):
    got = st_load(ctx)
    lg = got[0]
    d = got[1]
    if lg["ok"]:
        lg["month"] = ctx.now.month
        lg["team_set"] = str(ctx.inputs.get("team", "")).strip() != ""
    if state_screen(c, lg, d):
        return
    pb = st_picks(d)
    picks = pb[0]
    beats = pb[1]
    if len(picks) == 0:
        # Only a 1-QB league's QB was on the wire and he isn't better.
        best_frame(c, lg, d)
        return
    if k == 2:
        board_frame(c, lg, d, picks)
        return
    if d["compare"] and not beats:
        # Nothing on the wire beats your lineup: pick1 says so, pick2 shows
        # the closest free agent anyway.
        if k == 0:
            best_frame(c, lg, d)
            return
        k = 0
    pick_frame(c, lg, d, picks[k % len(picks)])

def pick1(c, ctx):
    page(c, ctx, 0)

def pick2(c, ctx):
    page(c, ctx, 1)

def board(c, ctx):
    page(c, ctx, 2)
