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
# LEAGUE TRANSACTION WIRE
#
# DESIGN. TELEGRAM / TICKER TAPE. Every move in your league, newest first,
# is printed on a strip of off-white ticker tape that runs across the
# panel (x 6..185, perforated edges all round), typed in black like a
# telegram - WHO did WHAT to WHOM, for HOW MUCH, STOP. Nothing else in the
# catalog is a lit paper strip with dark type, so it can't be mistaken for
# the "logo left, text middle" cards.
#   - The fantasy team's crest (the adapter's fl_badge) and the player's NFL
#     club logo are POSTAGE STAMPS stuck on the end of the tape: a black
#     picture inside a white perforated margin. Your own crest stamp has a
#     gold margin and YOU printed as its value; anyone else's shows the
#     time (or DEMO).
#   - A FAAB bid is a red RUBBER STAMP ($23 in a heavy, slightly worn rule)
#     slammed next to the player's name. That is the one loud colour.
#   - Verbs are in coloured ink (green claim / add, red drop / chop, blue
#     trade); times and notes in faded ink.
#
#   latest   YOU CLAIMED ................ DEMO  [crest][  club logo  ]
#            J. WARREN RB [$23]                 [stamp][   stamp     ]
#            DROPS T. SPEARS  $77 LEFT          [ YOU ][             ]
#            A plain add says which move of the week it is (3RD MOVE THIS
#            WEEK); a waiver without FAAB says ON WAIVERS; STOP ends the
#            line when there is room. Outbid: the winning claim's stamp,
#            then YOUR $98 BID LOST (your losing bid in grey). A trade reads
#            TRADE / [TT] GETS T. MCLAURIN / [GG] GETS J. COOK +1 with both
#            crests as stamps and the swap arrows between them (COMMISH
#            TRADE when the commissioner forced it). A guillotine chop is
#            CUT with the blade as the picture stamp.
#   wire     the tape runs on, torn into three by perforated tear marks:
#            crest stamp + club logo stamp + a big +/- (and the position),
#            then the player typed underneath with the bid (red $) or the
#            time. The last slot is the league desk: the week's WIRE KING
#            (crown, crest stamp, N MOVES) and your FAAB left with a red
#            gauge. Empty slots read END OF THE WIRE.
#
# Your own moves: a gold-edged crest stamp with YOU, and a gold bar under
# a wire tile. An empty fortnight is QUIET WIRE - two telegraph poles, a
# slack wire, one bird and a blank strip of tape. Errors are typed on a
# short strip of tape with the hint underneath.
#
# DATA. The shared fantasy-league adapter (block above) for teams, then:
#   Sleeper  /league/<id>/transactions/<week>, and <week-1> only while this
#            week has fewer than 4 moves (keeps budget for the name
#            fallback); failed waiver claims are read only to spot the ones
#            that lost YOUR bid. Names of the players on screen come from ONE
#            request to sleeper.com/graphql (aliased get_player queries -
#            undocumented, so a failure prints a log line and falls back to
#            SL_BACKUP, the 300 most-transacted players, then to one
#            api.sleeper.com player call per name while the budget lasts).
#            DEF ids are club codes already. FAAB left: the league's
#            waiver_budget minus your roster's waiver_budget_used, both
#            carried by adapter v2.1 (no request).
#            Budget: 3 adapter calls (matchups skipped; 5 for an
#            old-season ID, which refetches this season's managers) + 1-2
#            + 1 (+ per-player name fallbacks while the budget lasts).
#   ESPN     mTransactions2 for this scoring period and the last (claims
#            with bids, adds, drops, failed claims), the league activity
#            feed filtered to trades (messageTypeId 244 - trades never
#            appear in mTransactions2), and one players_wl lookup for names.
#            FAAB left comes free from the adapter's mTeam + mSettings.
#            1 + 2 + 1 + 1 = 5 calls.
# Refresh 600: the league ID and team are free text (>= 300), and the wire
# moves a few times a day, not a few times a minute.
# ======================================================================

ADD = "#2FE06F"       # pickups
DROP = "#FF4D4D"      # drops, chops
TRADE = "#2DB8FF"     # trades
GOLD = "#FFC21A"      # FAAB and YOU
AMBER = "#FFBF00"

L = 6
R = 185
TTL_TX = 600
TTL_TX_OLD = 3600
TTL_NAMES = 21600
MAX_SHOWN = 4         # hero + three tiles

LOGO = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png", "CAR": "CAR.png",
    "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png", "DAL": "DAL.png", "DEN": "DEN.png",
    "DET": "DET.png", "GB": "GB.png", "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png",
    "KC": "KC.png", "LV": "LV.png", "LAC": "LAC.png", "LAR": "LAR.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png", "NYJ": "NYJ.png",
    "PHI": "PHI.png", "PIT": "PIT.png", "SF": "SF.png", "SEA": "SEA.png", "TB": "TB.png",
    "TEN": "TEN.png", "WSH": "WSH.png", "NFL": "NFL.png",
}
SMALL = {
    "ARI": "ARI_S.png", "ATL": "ATL_S.png", "BAL": "BAL_S.png", "BUF": "BUF_S.png", "CAR": "CAR_S.png",
    "CHI": "CHI_S.png", "CIN": "CIN_S.png", "CLE": "CLE_S.png", "DAL": "DAL_S.png", "DEN": "DEN_S.png",
    "DET": "DET_S.png", "GB": "GB_S.png", "HOU": "HOU_S.png", "IND": "IND_S.png", "JAX": "JAX_S.png",
    "KC": "KC_S.png", "LV": "LV_S.png", "LAC": "LAC_S.png", "LAR": "LAR_S.png", "MIA": "MIA_S.png",
    "MIN": "MIN_S.png", "NE": "NE_S.png", "NO": "NO_S.png", "NYG": "NYG_S.png", "NYJ": "NYJ_S.png",
    "PHI": "PHI_S.png", "PIT": "PIT_S.png", "SF": "SF_S.png", "SEA": "SEA_S.png", "TB": "TB_S.png",
    "TEN": "TEN_S.png", "WSH": "WSH_S.png",
}

# ESPN proTeamId -> club code (0 = free agent).
ESPN_CLUB = {1: "ATL", 2: "BUF", 3: "CHI", 4: "CIN", 5: "CLE", 6: "DAL", 7: "DEN", 8: "DET",
             9: "GB", 10: "TEN", 11: "IND", 12: "KC", 13: "LV", 14: "LAR", 15: "MIA", 16: "MIN",
             17: "NE", 18: "NO", 19: "NYG", 20: "NYJ", 21: "PHI", 22: "ARI", 23: "PIT", 24: "LAC",
             25: "SF", 26: "SEA", 27: "TB", 28: "WSH", 29: "CAR", 30: "JAX", 33: "BAL", 34: "HOU"}
ESPN_POS = {1: "QB", 2: "RB", 3: "WR", 4: "TE", 5: "K", 16: "DEF"}
# ESPN activity feed: the six newest "traded" topics (messageTypeId 244).
COMM_FILTER = ('{"communication":{"topics":{"filterType":{"value":["ACTIVITY_TRANSACTIONS"]},' +
               '"filterIncludeMessageTypeIds":{"value":[244]},"limit":6,"limitPerMessageSet":{"value":25},' +
               '"sortMessageDate":{"sortPriority":1,"sortAsc":false}}}}')
DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

def club(abbr):
    a = str(abbr).strip().upper()
    return {"WAS": "WSH", "JAC": "JAX", "LVR": "LV", "OAK": "LV", "SD": "LAC", "STL": "LAR"}.get(a, a)

# ------------------------------------------------------------- pixel art
# Two-way trade arrows, 15 x 11: the top one runs left -> right in the
# first team's colour, the bottom one right -> left in the second's.
SWAP = """
.........A.....
.........AA....
AAAAAAAAAAAA...
.........AA....
.........A.....
...............
.....B.........
....BB.........
...BBBBBBBBBBBB
....BB.........
.....B.........
"""
SWAP_S = """
.....A..
AAAAAAA.
.....A..
..B.....
.BBBBBBB
..B.....
"""
# A 3 x 7 dollar sign (4x5's $ reads as an S).
DOLLAR = """
.X.
XXX
X..
XXX
..X
XXX
.X.
"""
# A blank helmet for a player with no club (free agent / unknown).
HELMET = """
....XXXXXX....
..XXXXXXXXXX..
.XXXXXXXXXXXX.
XXXXXXXXXXXXXX
XXXXXXXXXXXXXX
XXXXXXXXX..XXX
XXXXXXXX.MMMMM
XXXXXXXX.M..M.
.XXXXXX..MMMMM
..XXXX....M.M.
"""
# Guillotine for a chopped team (guillotine leagues), 12 x 22.
BLADE = """
WWWWWWWWWWWW
PP........PP
PP.SSSSSS.PP
PP.SSSSSE.PP
PP.SSSEE..PP
PP.SEE....PP
PP.E......PP
PP........PP
PP........PP
PP........PP
PP........PP
PP........PP
PP........PP
PP........PP
PPWWWWWWWWPP
PPW..WW..WPP
PPWWWWWWWWPP
PP........PP
PP........PP
PP........PP
PPP......PPP
PPP......PPP
"""
BLADE_LEG = {"W": "#8A5A2B", "P": "#A86F38", "S": "#AEB8C6", "E": "#FFFFFF"}
BIRD = """
.KK..
KKKKO
.KKK.
..K..
"""
BALL = """
..DDDDD..
.DBBWBBD.
DBWWWWWBD
.DBBWBBD.
..DDDDD..
"""
BALL_LEG = {"D": "#6B3410", "B": "#B5652B", "W": "#FFFFFF"}

# ------------------------------------------------------------- text fit
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

def player_fit(c, p, fonts, maxw):
    """'J. WARREN' in the biggest font that fits, then 'WARREN', then a
    clipped surname in the smallest font."""
    full = p["name"]
    for f in fonts:
        if c.text_width(full, f) <= maxw:
            return [full, f]
    last = p["last"]
    for f in fonts:
        if c.text_width(last, f) <= maxw:
            return [last, f]
    # Drop a suffix before clipping: 'ST. BROWN JR.' -> 'ST. BROWN'.
    words = last.split(" ")
    if len(words) > 1 and words[len(words) - 1] in ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]:
        return fit(c, " ".join(words[:len(words) - 1]), fonts, maxw)
    return fit(c, last, fonts, maxw)


# The wire king's crown, 11 x 5: gold with three jewels.
CROWN = """
G....G....G
GG..GGG..GG
GGGGGGGGGGG
GGRGGBGGRGG
GGGGGGGGGGG
"""
CROWN_LEG = {"G": "#FFC21A", "R": "#FF4D4D", "B": "#2DB8FF"}

def ordinal(n):
    if n % 100 in [11, 12, 13]:
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

def et_offset(ts):
    """Seconds US Eastern is behind UTC at ts: EDT from 07:00 UTC on the
    second Sunday of March to 06:00 UTC on the first Sunday of November."""
    days = ts // 86400
    y = 1970 + days * 400 // 146097
    if fl_days(y + 1, 1, 1) <= days:
        y += 1
    if fl_days(y, 1, 1) > days:
        y -= 1
    m1 = fl_days(y, 3, 1)
    start = (m1 + (6 - (m1 + 3) % 7) % 7 + 7) * 86400 + 7 * 3600
    n1 = fl_days(y, 11, 1)
    end = (n1 + (6 - (n1 + 3) % 7) % 7) * 86400 + 6 * 3600
    return 4 * 3600 if ts >= start and ts < end else 5 * 3600

# ------------------------------------------------------------- players
def player_rec(first, last, pos, team):
    first = fl_clean(first)
    last = fl_clean(last)
    if last == "":
        last = first
        first = ""
    name = (first[:1] + ". " + last) if first != "" else last
    return {"name": name if name != "" else "PLAYER", "last": last if last != "" else "PLAYER",
            "pos": fl_clean(pos), "team": club(team)}

def unknown_player():
    return {"name": "PLAYER", "last": "PLAYER", "pos": "", "team": ""}

def dst_player(abbr):
    a = club(abbr)
    return {"name": a + " D/ST", "last": a + " D/ST", "pos": "DEF", "team": a}

def is_digits(s):
    s = str(s)
    return s != "" and fl_norm(s) == s and len([ch for ch in s.elems() if FL_DIGITS.find(ch) < 0]) == 0

def sleeper_names(b, pids):
    """pid -> player for the ids on screen. Club defences are keyed by their
    code ('KC'); everyone else comes from ONE sleeper.com/graphql request
    (aliased get_player fields, ~80 bytes a player). That endpoint is
    undocumented, so a failure prints a log line; the ids it didn't answer
    come from SL_BACKUP, then one api.sleeper.com call each while the
    request budget lasts."""
    out = {}
    ask = []
    for p in pids:
        if not is_digits(p):
            out[p] = dst_player(p)
        elif p not in ask:
            ask.append(p)
    if len(ask) == 0:
        return out
    q = "{" + " ".join(["p" + str(i) + ":get_player(sport:\"nfl\",player_id:\"" + ask[i] +
                        "\"){first_name last_name position team}" for i in range(len(ask))]) + "}"
    r = fl_get(b, "https://sleeper.com/graphql", params = {"query": q}, ttl = TTL_NAMES)
    data = fl_d(r["json"], "data", None) if r["status_code"] == 200 else None
    got = 0
    if type(data) == "dict":
        for i in range(len(ask)):
            row = data.get("p" + str(i), None)
            if type(row) == "dict" and (fl_d(row, "last_name", "") != "" or fl_d(row, "first_name", "") != ""):
                out[ask[i]] = player_rec(fl_d(row, "first_name", ""), fl_d(row, "last_name", ""),
                                         fl_d(row, "position", ""), fl_d(row, "team", ""))
                got += 1
    if got == 0:
        print("WARN sleeper graphql names failed (HTTP " + str(r["status_code"]) +
              ") - falling back to SL_BACKUP / players/nfl/<id>")
    for p in ask:
        if p in out:
            continue
        row = SL_BACKUP.get(p, None)
        if row != None:
            f = row.split("|")
            out[p] = player_rec(f[0], f[1], f[2], f[3])
            continue
        if got > 0 or b["n"] >= FL_MAX_CALLS:
            continue        # graphql answered and doesn't know it: an unknown id
        r1 = fl_get(b, FL_SLEEPER_API + "players/nfl/" + p, ttl = TTL_NAMES)
        if r1["status_code"] == 200 and type(r1["json"]) == "dict":
            row = r1["json"]
            out[p] = player_rec(fl_d(row, "first_name", ""), fl_d(row, "last_name", ""),
                                fl_d(row, "position", ""), fl_d(row, "team", ""))
    return out

def espn_names(b, season, pids):
    """pid -> player from ESPN's player pool, one request for every id on
    screen (X-Fantasy-Filter filterIds). D/ST ids are -16000 - club id."""
    out = {}
    ask = []
    for p in pids:
        n = int(fl_num(p, 0))
        if n < 0:
            out[p] = dst_player(ESPN_CLUB.get(-16000 - n, ""))
        elif n > 0 and n not in ask:
            ask.append(n)
    if len(ask) == 0:
        return out
    h = dict(FL_HEADERS)
    h["X-Fantasy-Filter"] = '{"filterIds":{"value":[' + ",".join([str(n) for n in ask]) + ']}}'
    r = fl_get(b, FL_ESPN + str(season) + "/players?view=players_wl", headers = h, ttl = TTL_NAMES)
    if r["status_code"] == 200 and type(r["json"]) == "list":
        for row in r["json"]:
            pid = str(int(fl_num(fl_d(row, "id", 0))))
            first = fl_d(row, "firstName", "")
            last = fl_d(row, "lastName", "")
            if first == "" and last == "":
                last = fl_d(row, "fullName", "")
            out[pid] = player_rec(first, last, ESPN_POS.get(int(fl_num(fl_d(row, "defaultPositionId", 0))), ""),
                                  ESPN_CLUB.get(int(fl_num(fl_d(row, "proTeamId", 0))), ""))
    return out

# ------------------------------------------------------- transactions
# One move: {kind claim|add|drop|trade|chop|fail, ts (unix s), team, adds
# [pid], drops [pid], bid (-1 none), comm (commissioner), sides [[team,
# [pid], [extra]]] for trades - an extra is ["pick", season, round] or
# ["faab", amount] - n (players freed, chop), cur (this week), beat (the
# bid YOUR failed claim on the same player lost with; -1 no FAAB, None not
# you)}. "fail" rows are failed waiver claims, used only for `beat`.
def tx_rec(kind, ts, team):
    return {"kind": kind, "ts": ts, "team": team, "adds": [], "drops": [], "bid": -1,
            "comm": False, "sides": [], "n": 0, "key": "", "cur": True, "beat": None}

def order_sides(sides):
    """Sides that received something first, so a 3- or 4-way trade shows
    two teams that got something."""
    return [s for s in sides if len(s[1]) + len(s[2]) > 0] + [s for s in sides if len(s[1]) + len(s[2]) == 0]

def sleeper_rows(rows, cur, seen):
    out = []
    for t in rows:
        if type(t) != "dict":
            continue
        status = str(fl_d(t, "status", ""))
        typ = str(fl_d(t, "type", ""))
        if status != "complete" and not (status == "failed" and typ == "waiver"):
            continue
        tid = str(fl_d(t, "transaction_id", ""))
        if tid != "" and tid in seen:
            continue
        seen[tid] = True
        ts = int(fl_num(fl_d(t, "status_updated", fl_d(t, "created", 0)))) // 1000
        rids = fl_d(t, "roster_ids", [])
        rids = rids if type(rids) == "list" else []
        adds = fl_d(t, "adds", {})
        drops = fl_d(t, "drops", {})
        adds = adds if type(adds) == "dict" else {}
        drops = drops if type(drops) == "dict" else {}
        bid = fl_d(fl_d(t, "settings", {}), "waiver_bid", None)
        rid = rids[0] if len(rids) > 0 else 0
        if status == "failed":
            x = tx_rec("fail", ts, rid)
            x["adds"] = sorted([p for p in adds.keys() if adds[p] == rid] or list(adds.keys()))
            x["bid"] = int(fl_num(bid)) if bid != None else -1
            x["cur"] = cur
            out.append(x)
            continue
        # A commissioner row across two or more rosters (mirrored adds and
        # drops) is a forced trade, not one team's pickup.
        if typ == "trade" or (typ == "commissioner" and len(rids) >= 2):
            sides = []
            for r in rids:
                extra = []
                for pk in fl_d(t, "draft_picks", []):
                    if fl_d(pk, "owner_id", None) == r:
                        extra.append(["pick", str(fl_d(pk, "season", "")), str(fl_d(pk, "round", ""))])
                for wb in fl_d(t, "waiver_budget", []):
                    if fl_d(wb, "receiver", None) == r:
                        extra.append(["faab", int(fl_num(fl_d(wb, "amount", 0)))])
                sides.append([r, sorted([p for p in adds.keys() if adds[p] == r]), extra])
            if len(sides) >= 2:
                x = tx_rec("trade", ts, 0)
                x["sides"] = order_sides(sides)
                x["team"] = x["sides"][0][0]
                x["comm"] = typ == "commissioner"
                x["cur"] = cur
                out.append(x)
            continue
        if typ == "chopped":
            x = tx_rec("chop", ts, rid)
            x["n"] = len(drops)
            x["cur"] = cur
            out.append(x)
            continue
        ad = sorted([p for p in adds.keys() if adds[p] == rid] or list(adds.keys()))
        dr = sorted([p for p in drops.keys() if drops[p] == rid] or list(drops.keys()))
        if len(ad) == 0 and len(dr) == 0:
            continue
        kind = "claim" if (typ == "waiver" and len(ad) > 0) else ("add" if len(ad) > 0 else "drop")
        x = tx_rec(kind, ts, rid)
        x["adds"] = ad
        x["drops"] = dr
        x["comm"] = typ == "commissioner"
        x["cur"] = cur
        if typ == "waiver" and bid != None:
            x["bid"] = int(fl_num(bid))
        out.append(x)
    return out

def sleeper_tx(lg, ctx):
    b = lg["budget"]
    nid = lg["raw"]["league_id"]
    wk = lg["week"]
    out = []
    seen = {}
    for w in [wk, wk - 1]:
        if w < 1:
            continue
        # Last week only while this week is thin: 4+ moves already fill the
        # hero and the tiles, and the saved call is the name fallback's.
        if w != wk and len([x for x in out if x["kind"] != "fail"]) >= 4:
            break
        r = fl_get(b, FL_SLEEPER + "league/" + nid + "/transactions/" + str(w),
                   ttl = TTL_TX if w == wk else TTL_TX_OLD)
        if r["status_code"] == 200 and type(r["json"]) == "list":
            out += sleeper_rows(r["json"], w == wk, seen)
        elif w == wk:
            return None
    return out

def espn_tx(lg, ctx):
    b = lg["budget"]
    j = lg["raw"]["json"]
    base = FL_ESPN + str(lg["season"]) + "/segments/0/leagues/" + lg["raw"]["league_id"]
    head = lg["raw"]["cookie"]
    sp = int(fl_num(fl_d(j, "scoringPeriodId", lg["week"]), lg["week"]))
    faab = fl_d(fl_d(fl_d(j, "settings", {}), "acquisitionSettings", {}), "isUsingAcquisitionBudget", False) == True
    out = []
    for w in [sp, sp - 1]:
        if w < 1:
            continue
        r = fl_get(b, base + "?view=mTransactions2&scoringPeriodId=" + str(w), headers = head,
                   ttl = TTL_TX if w == sp else TTL_TX_OLD)
        if r["status_code"] != 200 or type(r["json"]) != "dict":
            if w == sp:
                return None
            continue
        for t in fl_d(r["json"], "transactions", []):
            status = str(fl_d(t, "status", ""))
            typ = str(fl_d(t, "type", ""))
            failed = typ == "WAIVER" and status.startswith("FAILED")
            if status != "EXECUTED" and not failed:
                continue
            if typ not in ["WAIVER", "FREEAGENT", "ROSTER"]:
                continue
            ad = []
            dr = []
            for it in fl_d(t, "items", []):
                k = str(fl_d(it, "type", ""))
                pid = str(int(fl_num(fl_d(it, "playerId", 0))))
                if k == "ADD":
                    ad.append(pid)
                elif k == "DROP":
                    dr.append(pid)
            if len(ad) == 0 and len(dr) == 0:
                continue
            ts = int(fl_num(fl_d(t, "processDate", fl_d(t, "proposedDate", 0)))) // 1000
            if failed:
                kind = "fail"
            else:
                kind = "claim" if (typ == "WAIVER" and len(ad) > 0) else ("add" if len(ad) > 0 else "drop")
            x = tx_rec(kind, ts, fl_d(t, "teamId", 0))
            x["adds"] = ad
            x["drops"] = dr
            x["key"] = str(fl_d(t, "id", ""))
            x["cur"] = w == sp
            if typ == "WAIVER" and faab:
                x["bid"] = int(fl_num(fl_d(t, "bidAmount", 0)))
            out.append(x)
    # Trades never show in mTransactions2 (the executed proposal is hidden),
    # so they come from the league activity feed, filtered to "traded"
    # messages: one topic per trade, one message per player that moved.
    h = dict(head)
    h["X-Fantasy-Filter"] = COMM_FILTER
    r = fl_get(b, base + "?view=kona_league_communication", headers = h, ttl = TTL_TX)
    if r["status_code"] == 200 and type(r["json"]) == "dict":
        since = ctx.now.unix - 14 * 86400
        week_ago = ctx.now.unix - 7 * 86400
        for tp in fl_d(fl_d(r["json"], "communication", {}), "topics", []):
            ts = int(fl_num(fl_d(tp, "date", 0))) // 1000
            if ts < since:
                continue
            order = []
            got = {}
            for m in fl_d(tp, "messages", []):
                if int(fl_num(fl_d(m, "messageTypeId", 0))) != 244:
                    continue
                to = fl_d(m, "to", 0)
                if to not in got:
                    got[to] = []
                    order.append(to)
                got[to].append(str(int(fl_num(fl_d(m, "targetId", 0)))))
            if len(order) < 2:
                continue
            x = tx_rec("trade", ts, order[0])
            x["cur"] = ts >= week_ago
            for tid in order:
                x["sides"].append([tid, got[tid], []])
            out.append(x)
    return out

def tx_players(x):
    """The player ids a move puts on screen, in drawing order."""
    if x["kind"] == "trade":
        ids = []
        for s in x["sides"][:2]:
            ids += s[1][:2]
        return ids
    return x["adds"][:1] + x["drops"][:1]

def is_me(lg, team_id):
    return (lg["state"] == "demo" or lg["me_matched"]) and team_id == lg["me"]

def mark_beaten(lg, txs, fails):
    """A claim that won a player YOUR failed claim wanted carries your bid."""
    mine = [f for f in fails if is_me(lg, f["team"])]
    if len(mine) == 0:
        return
    for x in txs:
        if x["kind"] != "claim" or is_me(lg, x["team"]):
            continue
        for f in mine:
            if len([p for p in f["adds"] if p in x["adds"]]) > 0:
                x["beat"] = f["bid"]

def faab_left(lg):
    """[left, budget] of YOUR FAAB, or None (no FAAB, no team matched, or
    no budget left for the read)."""
    if lg["state"] == "demo":
        return [77, 100]
    if not lg["me_matched"]:
        return None
    budget = 0
    used = 0
    if lg["platform"] == "SLEEPER":
        # Adapter v2.1 carries the league's waiver settings and each
        # team's waiver_budget_used (no request, followed IDs too).
        if lg["raw"].get("waiver_type", 0) != 2:
            return None
        budget = lg["raw"].get("waiver_budget", 0)
        me = fl_team(lg, lg["me"])
        used = me.get("waiver_budget_used", 0) if me != None else 0
    else:
        j = lg["raw"]["json"]
        acq = fl_d(fl_d(j, "settings", {}), "acquisitionSettings", {})
        if fl_d(acq, "isUsingAcquisitionBudget", False) != True:
            return None
        budget = int(fl_num(fl_d(acq, "acquisitionBudget", 0), 0))
        for t in fl_d(j, "teams", []):
            if fl_d(t, "id", None) == lg["me"]:
                used = int(fl_num(fl_d(fl_d(t, "transactionCounter", {}), "acquisitionBudgetSpent", 0), 0))
    if budget <= 0:
        return None
    left = budget - used
    left = 0 if left < 0 else (budget if left > budget else left)   # -100 'used' happens
    return [left, budget]

def wire_king(lg, txs):
    """[team id, moves] for the team with the most moves this week - only a
    clear leader with 2 or more."""
    n = {}
    for x in txs:
        if not x["cur"] or x["kind"] == "chop":
            continue
        ids = [s[0] for s in x["sides"]] if x["kind"] == "trade" else [x["team"]]
        for t in ids:
            n[t] = n.get(t, 0) + 1
    ranked = sorted(n.items(), key = lambda kv: -kv[1])
    if len(ranked) == 0 or ranked[0][1] < 2:
        return None
    if len(ranked) > 1 and ranked[1][1] == ranked[0][1]:
        return None
    if fl_team(lg, ranked[0][0]) == None:
        return None
    return [ranked[0][0], ranked[0][1]]

def load_wire(ctx):
    """Everything both pages draw: the league (adapter), the moves (newest
    first), the names of the players on screen, your FAAB and the king."""
    # The wire never reads scores: matchups = False saves Sleeper a call.
    lg = fl_load(ctx, projections = False, matchups = False)
    if not lg["ok"]:
        e = lg["err"]
        # The adapter's retry hint assumes a 5-minute refresh; this app's is 10.
        return {"lg": lg, "tx": [], "players": {}, "wallet": None, "king": None,
                "err": [e[0], "RETRY IN 10 MIN" if e[1] == "RETRY IN 5 MIN" else e[1]]}
    if lg["state"] == "demo":
        return demo_wire(ctx, lg)
    if lg["state"] == "predraft":
        return {"lg": lg, "tx": [], "players": {}, "wallet": None, "king": None, "err": None}
    allx = sleeper_tx(lg, ctx) if lg["platform"] == "SLEEPER" else espn_tx(lg, ctx)
    if allx == None:
        return {"lg": lg, "tx": [], "players": {}, "wallet": None, "king": None,
                "err": [lg["platform"] + " WIRE DOWN", "TRANSACTIONS DIDN'T LOAD - RETRY IN 10 MIN"]}
    fails = [x for x in allx if x["kind"] == "fail"]
    txs = sorted([x for x in allx if x["kind"] != "fail"], key = lambda x: (-x["ts"], -x["bid"]))
    mark_beaten(lg, txs, fails)
    # Within the newest waiver run (same minute), the claim that beat you
    # leads.
    for i in range(1, len(txs)):
        if txs[0]["ts"] - txs[i]["ts"] > 60 or txs[0]["beat"] != None:
            break
        if txs[i]["beat"] != None:
            txs = [txs[i]] + txs[:i] + txs[i + 1:]
            break
    pids = []
    for x in txs[:MAX_SHOWN]:
        for p in tx_players(x):
            if p not in pids:
                pids.append(p)
    pl = sleeper_names(lg["budget"], pids) if lg["platform"] == "SLEEPER" else espn_names(lg["budget"], lg["season"], pids)
    return {"lg": lg, "tx": txs, "players": pl, "err": None,
            "wallet": faab_left(lg) if len(txs) > 0 else None, "king": wire_king(lg, txs)}

# ------------------------------------------------------------------ demo
# Blank league ID: the adapter's DEMO league with a believable week of
# moves. BLITZ BRIGADE (id 1) is "you" with $77 of $100 FAAB left; TD
# TSUNAMI (id 2) is the week's wire king.
DEMO_PLAYERS = {
    "d1": ["JAYLEN", "WARREN", "RB", "PIT"],
    "d2": ["TYJAE", "SPEARS", "RB", "TEN"],
    "d3": ["TERRY", "MCLAURIN", "WR", "WSH"],
    "d4": ["JAMES", "COOK", "RB", "BUF"],
    "d5": ["", "", "DEF", "SEA"],
    "d6": ["KAREEM", "HUNT", "RB", "KC"],
    "d7": ["JAKE", "FERGUSON", "TE", "DAL"],
    "d8": ["RASHID", "SHAHEED", "WR", "NO"],
    "d9": ["TUCKER", "KRAFT", "TE", "GB"],
}

def demo_wire(ctx, lg):
    now = ctx.now.unix
    pl = {}
    for k in DEMO_PLAYERS:
        d = DEMO_PLAYERS[k]
        pl[k] = dst_player(d[3]) if d[2] == "DEF" else player_rec(d[0], d[1], d[2], d[3])
    a = tx_rec("claim", now - 3 * 3600, 1)
    a["adds"] = ["d1"]
    a["drops"] = ["d2"]
    a["bid"] = 23
    t = tx_rec("trade", now - 7 * 3600, 2)
    t["sides"] = [[2, ["d3"], []], [3, ["d4"], [["pick", "2027", "2"]]]]
    f = tx_rec("add", now - 26 * 3600, 6)
    f["adds"] = ["d5"]
    d = tx_rec("drop", now - 30 * 3600, 8)
    d["drops"] = ["d6"]
    e = tx_rec("claim", now - 50 * 3600, 4)
    e["adds"] = ["d7"]
    e["bid"] = 6
    g = tx_rec("claim", now - 51 * 3600, 2)
    g["adds"] = ["d8"]
    g["bid"] = 4
    h = tx_rec("add", now - 60 * 3600, 2)
    h["adds"] = ["d9"]
    txs = [a, t, f, d, e, g, h]
    return {"lg": lg, "tx": txs, "players": pl, "err": None, "wallet": [77, 100],
            "king": wire_king(lg, txs)}

# ------------------------------------------------------------- helpers
def is_mine(w, team_id):
    return is_me(w["lg"], team_id)

def tx_mine(w, x):
    if x["kind"] == "trade":
        return len([s for s in x["sides"] if is_mine(w, s[0])]) > 0
    return is_mine(w, x["team"])

def team_of(w, tid):
    t = fl_team(w["lg"], tid)
    if t == None:
        return {"id": tid, "name": "TEAM " + str(tid), "abbrev": "T" + str(tid), "color": "#D8DEE8"}
    return t

def player_of(w, pid):
    return w["players"].get(pid, unknown_player())

def ago(ctx, ts, short):
    d = ctx.now.unix - ts
    if ts <= 0:
        return ""
    if d < 3600:
        return "NOW" if short else "JUST NOW"
    if d < 86400:
        return str(d // 3600) + ("H" if short else "H AGO")
    if d < 6 * 86400:
        # weekday in US Eastern; 1970-01-01 was a Thursday
        return DAYS[((ts - et_offset(ts)) // 86400 + 3) % 7]
    return str(d // 86400) + ("D" if short else "D AGO")

def moves_this_week(w, tid):
    n = 0
    for x in w["tx"]:
        if not x["cur"] or x["kind"] == "chop":
            continue
        ids = [s[0] for s in x["sides"]] if x["kind"] == "trade" else [x["team"]]
        if tid in ids:
            n += 1
    return n

def verb(x):
    if x["kind"] == "claim":
        return ["CLAIMED", ADD]
    if x["kind"] == "add":
        return ["ADDED", ADD]
    if x["kind"] == "drop":
        return ["DROPPED", DROP]
    if x["kind"] == "chop":
        return ["WAS CHOPPED", DROP]
    return ["TRADED", TRADE]

# Last-resort Sleeper names when sleeper.com/graphql fails: the 300 players
# moved most often across the test leagues (93% of all adds/drops), as
# id -> 'first initial|last|pos|club'. Regenerate with each PR.
SL_BACKUP = {
    "11435": "E|WILSON|RB|SEA", "9228": "B|YOUNG|QB|CAR", "11625": "A|MITCHELL|WR|NYJ", "13345": "J|COLEMAN|RB|DEN",
    "13346": "D|BOSTON|WR|CLE", "7571": "R|BATEMAN|WR|BAL", "10213": "T|TUCKER|WR|LV", "12545": "T|SHOUGH|QB|NO",
    "6130": "D|SINGLETARY|RB|NYG", "5001": "D|SCHULTZ|TE|HOU", "5854": "D|LOCK|QB|SEA", "9482": "M|MAYER|TE|LV",
    "12508": "J|DART|QB|NYG", "9486": "D|WICKS|WR|PHI", "11637": "K|COLEMAN|WR|BUF", "12493": "O|GADSDEN|TE|LAC",
    "13296": "C|DOUGLAS|WR|MIA", "9225": "T|BIGSBY|RB|PHI", "5849": "K|MURRAY|QB|MIN", "4177": "M|HOLLINS|WR|NE",
    "3161": "C|WENTZ|QB|MIN", "4993": "M|GESICKI|TE|CIN", "2306": "J|WINSTON|QB|NYG", "2505": "D|WALLER|TE|CAR",
    "13285": "M|FIELDS|WR|NYG", "3634": "K|RAYMOND|WR|CHI", "2307": "M|MARIOTA|QB|WAS", "11370": "C|BROOKS|RB|GB",
    "11834": "D|VELE|WR|NO", "11628": "M|HARRISON|WR|ARI", "12472": "R|SANDERS|RB|CLE", "12504": "K|JOHNSON|RB|GB",
    "10219": "C|RODRIGUEZ|RB|JAX", "13347": "D|CLAIBORNE|RB|MIN", "12487": "T|FERGUSON|TE|LAR", "13301": "A|WILLIAMS|WR|WAS",
    "10218": "X|HUTCHINSON|WR|HOU", "11630": "R|WILSON|WR|PIT", "13417": "D|STRIBLING|WR|SF", "12048": "G|HOLANI|RB|SEA",
    "13337": "E|JOHNSON|RB|KC", "12185": "S|SHRADER|K|IND", "4035": "A|KAMARA|RB|NO", "3163": "J|GOFF|QB|DET",
    "1166": "K|COUSINS|QB|LV", "5947": "J|MEYERS|WR|JAX", "1339": "Z|ERTZ|TE|PHI", "9504": "K|BOUTTE|WR|HOU",
    "11583": "J|BROOKS|RB|CAR", "9501": "D|DOUGLAS|WR|NE", "11610": "M|WASHINGTON|WR|MIA", "13330": "K|SADIQ|TE|NYJ",
    "8142": "A|PIERCE|WR|IND", "6804": "J|LOVE|QB|GB", "8188": "T|THORNTON|WR|KC", "7553": "K|PITTS|TE|ATL",
    "6650": "C|MCLAUGHLIN|K|TB", "9500": "J|DOWNS|WR|IND", "13545": "T|SMACK|K|GB", "3286": "D|ROBINSON|WR|SF",
    "8137": "G|PICKENS|WR|DAL", "11256": "T|BAGENT|QB|CHI", "10222": "J|REED|WR|GB", "6931": "D|DALLAS|RB|MIN",
    "13305": "M|WASHINGTON|RB|LV", "9224": "C|BROWN|RB|CIN", "8126": "W|ROBINSON|WR|TEN", "12015": "H|MEVIS|K|LAR",
    "13294": "M|LEMON|WR|PHI", "8259": "C|DICKER|K|LAC", "12718": "K|MUMPFIELD|WR|LAR", "9754": "Q|JOHNSTON|WR|LAC",
    "11655": "T|TRACY|RB|NYG", "11624": "X|WORTHY|WR|KC", "11581": "M|LLOYD|RB|GB", "12518": "T|WARREN|TE|IND",
    "4866": "S|BARKLEY|RB|PHI", "7002": "J|JOHNSON|TE|NO", "9758": "C|STROUD|QB|HOU", "9511": "K|MITCHELL|RB|LAC",
    "6828": "A|DILLON|RB|CAR", "9508": "T|SPEARS|RB|TEN", "5870": "D|JONES|QB|IND", "9480": "B|STRANGE|TE|JAX",
    "13298": "K|CONCEPCION|WR|CLE", "12530": "T|HUNTER|DB|JAX", "11566": "J|DANIELS|QB|WAS", "11635": "L|MCCONKEY|WR|LAC",
    "12474": "W|MARKS|RB|HOU", "6819": "M|PITTMAN|WR|PIT", "8134": "K|SHAKIR|WR|BUF", "8183": "B|PURDY|QB|SF",
    "5045": "C|SUTTON|WR|DEN", "13414": "K|BLACK|RB|SF", "4199": "A|JONES|RB|MIN", "5022": "D|GOEDERT|TE|PHI",
    "4066": "E|ENGRAM|TE|DEN", "7090": "D|MOONEY|WR|NYG", "11563": "B|NIX|QB|DEN", "8136": "R|WHITE|RB|WAS",
    "9487": "P|WASHINGTON|WR|JAX", "8180": "J|NAILOR|WR|LV", "6797": "J|HERBERT|QB|LAC", "4892": "B|MAYFIELD|QB|TB",
    "2020": "C|SANTOS|K|CHI", "12501": "M|GOLDEN|WR|GB", "8210": "C|OKONKWO|TE|WAS", "7528": "N|HARRIS|RB|NYG",
    "11646": "J|COKER|WR|CAR", "5844": "T|HOCKENSON|TE|MIN", "7021": "R|DOWDLE|RB|PIT", "11576": "B|ALLEN|RB|NYJ",
    "5189": "E|PINEIRO|K|SF", "7670": "J|PALMER|WR|BUF", "8676": "R|SHAHEED|WR|SEA", "9756": "J|ADDISON|WR|MIN",
    "13413": "C|ALLEN|WR|KC", "7600": "P|FREIERMUTH|TE|PIT", "12481": "C|SKATTEBO|RB|NYG", "7523": "T|LAWRENCE|QB|JAX",
    "4454": "K|BOURNE|WR|ARI", "6083": "M|GAY|K|LV", "4227": "H|BUTKER|K|KC", "7567": "K|GAINWELL|RB|TB",
    "19": "J|FLACCO|QB|CIN", "6149": "D|SLAYTON|WR|IND", "10235": "R|JOHNSON|RB|CHI", "11237": "J|SAYLORS|RB|DET",
    "4017": "D|WATSON|QB|CLE", "11539": "J|BATES|K|DET", "9757": "K|MILLER|RB|NO", "7562": "T|ATWELL|WR|LAR",
    "11199": "E|DEMERCADO|RB|DAL", "12492": "P|BRYANT|WR|DEN", "13311": "C|BELL|WR|MIA", "11729": "S|VAKI|RB|DET",
    "12533": "J|CROSKEY-MERRITT|RB|WAS", "12711": "T|LOOP|K|BAL", "6794": "J|JEFFERSON|WR|MIN", "5967": "T|POLLARD|RB|TEN",
    "12527": "A|JEANTY|RB|LV", "7569": "N|COLLINS|WR|HOU", "4574": "C|RUSH|QB|ATL", "13293": "J|LANE|WR|BAL",
    "11608": "I|WILLIAMS|WR|NYJ", "3321": "T|HILL|WR|", "8408": "J|MASON|RB|MIN", "12536": "J|NOEL|WR|HOU",
    "12489": "R|HARVEY|RB|DEN", "11783": "R|FLOURNOY|WR|DAL", "4039": "C|KUPP|WR|SEA", "7049": "J|JENNINGS|WR|MIN",
    "1945": "C|BOSWELL|K|PIT", "8154": "B|ROBINSON|RB|ATL", "8110": "J|FERGUSON|TE|DAL", "8161": "M|WILLIS|QB|MIA",
    "12509": "T|HARRIS|WR|LAC", "12534": "K|MONANGAI|RB|CHI", "9502": "T|DELL|WR|HOU", "12517": "C|LOVELAND|TE|CHI",
    "7042": "T|BASS|K|BUF", "2747": "J|MYERS|K|SEA", "1373": "G|SMITH|QB|NYJ", "4147": "S|PERINE|RB|CIN",
    "10229": "R|RICE|WR|KC", "11629": "D|WALKER|WR|BAL", "12507": "O|HAMPTON|RB|LAC", "7839": "E|MCPHERSON|K|CIN",
    "3214": "H|HENRY|TE|NE", "8800": "M|DAVIS|RB|DAL", "8121": "R|DOUBS|WR|NE", "5850": "J|JACOBS|RB|GB",
    "4943": "S|DARNOLD|QB|SEA", "9753": "Z|CHARBONNET|RB|SEA", "12519": "L|BURDEN|WR|CHI", "11618": "J|MCMILLAN|WR|TB",
    "4034": "C|MCCAFFREY|RB|SF", "8205": "I|PACHECO|RB|DET", "11603": "A|BARNER|TE|SEA", "11575": "R|DAVIS|RB|BUF",
    "421": "M|STAFFORD|QB|LAR", "1479": "K|ALLEN|WR|IND", "9997": "Z|FLOWERS|WR|BAL", "9226": "D|ACHANE|RB|MIA",
    "6783": "J|JEUDY|WR|CLE", "13276": "O|COOPER|WR|NYJ", "4881": "L|JACKSON|QB|BAL", "6806": "J|DOBBINS|RB|DEN",
    "8131": "I|LIKELY|TE|NYG", "8111": "C|OTTON|TE|TB", "11559": "M|PENIX|QB|ATL", "5995": "J|HILL|RB|BAL",
    "4981": "C|RIDLEY|WR|TEN", "9484": "T|KRAFT|TE|GB", "5872": "D|SAMUEL|WR|SF", "6865": "C|PARKINSON|TE|LAR",
    "13279": "C|TATE|WR|TEN", "8132": "T|ALLGEIER|RB|ARI", "11632": "M|NABERS|WR|NYG", "11792": "W|REICHARD|K|MIN",
    "5846": "D|METCALF|WR|PIT", "4033": "D|NJOKU|TE|LAC", "8172": "G|DULCICH|TE|MIA", "7611": "R|STEVENSON|RB|NE",
    "6768": "T|TAGOVAILOA|QB|ATL", "1737": "C|KEENUM|QB|CHI", "13317": "T|HURST|WR|TB", "8127": "C|KOLAR|TE|LAC",
    "13281": "J|TYSON|WR|NO", "13269": "F|MENDOZA|QB|LV", "11577": "W|SHIPLEY|RB|PHI", "13274": "G|BERNARD|WR|PIT",
    "5927": "T|MCLAURIN|WR|WAS", "12540": "C|DIKE|WR|TEN", "12502": "G|HELM|TE|TEN", "13421": "E|RARIDON|TE|NE",
    "12469": "D|SAMPSON|RB|CLE", "5012": "M|ANDREWS|TE|BAL", "13288": "N|SINGLETON|RB|TEN", "96": "A|RODGERS|QB|PIT",
    "7594": "C|HUBBARD|RB|CAR", "12522": "C|WARD|QB|TEN", "3451": "K|FAIRBAIRN|K|HOU", "11643": "J|WRIGHT|RB|MIA",
    "12535": "I|TESLAA|WR|DET", "827": "T|TAYLOR|QB|GB", "11647": "K|VIDAL|RB|LAC", "9494": "M|MIMS|WR|DEN",
    "4663": "A|EKELER|RB|", "3678": "W|LUTZ|K|DEN", "13533": "B|BROWN|WR|NO", "11586": "B|CORUM|RB|LAR",
    "12483": "J|BECH|WR|LV", "2449": "S|DIGGS|WR|WAS", "13394": "J|CAMERON|WR|JAX", "3155": "L|TREADWELL|WR|IND",
    "11168": "X|SMITH|WR|LAR", "12476": "D|NEAL|RB|", "8329": "D|LLOYD|LB|CAR", "8167": "C|WATSON|WR|GB",
    "13411": "Z|THOMAS|WR|CHI", "4950": "C|KIRK|WR|SF", "13405": "K|ALLEN|RB|WAS", "11565": "J|MCCARTHY|QB|MIN",
    "7627": "G|ROUSSEAU|DE|BUF", "13320": "Z|BRANCH|WR|ATL", "12491": "C|KINER|RB|NE", "1466": "T|KELCE|TE|KC",
    "11560": "C|WILLIAMS|QB|CHI", "4983": "D|MOORE|WR|BUF", "12467": "J|JAMES|RB|SF", "11786": "C|LITTLE|K|JAX",
    "4046": "P|MAHOMES|QB|KC", "13150": "D|COOPER|WR|PHI", "2197": "B|COOKS|WR|SF", "12511": "W|HOWARD|QB|PIT",
    "12485": "T|JOHNSON|WR|TB", "5095": "D|CARLSON|K|NO", "7726": "D|BARNES|LB|DET", "12556": "D|EZEIRUAKU|DL|DAL",
    "13423": "E|HEIDENREICH|RB|PIT", "12499": "E|AYOMANOR|WR|TEN", "11760": "A|BOOKER|DL|CHI", "6039": "T|JOHNSON|RB|BUF",
    "11627": "T|FRANKLIN|WR|DEN", "8112": "D|LONDON|WR|ATL", "9506": "S|TUCKER|RB|TB", "13268": "E|SARRATT|WR|BAL",
    "13424": "S|MCGOWAN|RB|IND", "13602": "J|STRAND|QB|ATL", "13277": "C|DONALDSON|RB|NO", "11626": "X|LEGETTE|WR|CAR",
    "12521": "E|ARROYO|TE|SEA", "4137": "J|CONNER|RB|ARI", "10917": "B|YOUNG|LB|LAR", "6826": "C|KMET|TE|CHI",
    "11631": "B|THOMAS|WR|JAX", "7564": "J|CHASE|WR|CIN", "12506": "H|FANNIN|TE|CLE", "8146": "G|WILSON|WR|NYJ",
    "8208": "T|BADIE|RB|DEN", "11623": "J|WHITTINGTON|WR|LAR", "5848": "M|BROWN|WR|PHI", "7647": "P|WERNER|LB|NO",
    "11728": "J|HICKS|DB|KC", "12457": "J|BLUE|RB|PHI", "5862": "B|BURNS|DE|NYG", "7648": "N|BOLTON|LB|KC",
    "8119": "J|DOTSON|WR|ATL", "13264": "D|MEYERS|WR|CIN", "8138": "J|COOK|RB|BUF", "5843": "D|BUSH|LB|CHI",
    "5944": "B|OKEREKE|LB|CAR", "12547": "K|WILLIAMS|WR|NE", "5857": "N|FANT|TE|NO", "13286": "J|PRICE|RB|SEA",
    "4037": "C|GODWIN|WR|TB", "10236": "D|KINCAID|TE|BUF", "12529": "T|HENDERSON|RB|NE", "12713": "A|BORREGALES|K|NE",
}

# ------------------------------------------------------------ the tape
# Everything a move says is typed on a strip of ticker tape: off-white
# paper, black type, perforated edges. The crest and the player's club logo
# are postage stamps stuck on it (white perforated margin, black picture),
# and a FAAB bid is a red rubber stamp.
TAPE = "#ECE2BF"        # the paper
TAPE_SHADOW = "#3B3423"  # one row under the strip
T_INK = "#000000"       # typed ink (unlit LEDs: the sharpest contrast)
T_DIM = "#6E6147"       # faded ink: times, notes
T_ADD = "#0B7A2F"       # verbs, in ink dark enough for the paper
T_DROP = "#C0161A"
T_TRADE = "#1356B5"
T_COMM = "#8A5A00"
RUBBER = "#E0231B"      # the FAAB rubber stamp
RUBBER_DEAD = "#8A8478" # the bid that lost
PAPER = "#FFFFFF"       # a stamp's perforated margin

def teeth_row(n):
    return "\n" + "".join(["X" if i % 2 == 1 else "." for i in range(n)]) + "\n"

def tape(c, x0, x1, y0, y1):
    """A strip of tape from x0 to x1 (inside the 6..185 safe zone): the
    paper, perforated edges all round (every other pixel punched out) and
    a shadow row."""
    c.rect(x0, y0, x1, y1, fill = TAPE)
    row = teeth_row(x1 - x0 + 1)
    c.sprite(row, x0, y0, legend = {"X": "black"})
    c.sprite(row, x0, y1, legend = {"X": "black"})
    col = "\n" + "\n".join(["X" if r % 2 == 1 else "." for r in range(y1 - y0 + 1)]) + "\n"
    c.sprite(col, x0, y0, legend = {"X": "black"})
    c.sprite(col, x1, y0, legend = {"X": "black"})
    if y1 < 31:
        c.rect(x0, y1 + 1, x1, y1 + 1, fill = TAPE_SHADOW)

def tear(c, x, y0, y1):
    """A perforated tear line across the tape (between two moves)."""
    c.sprite("\n" + "\n".join(["X" if (y - y0) % 2 == 0 else "." for y in range(y0, y1 + 1)]) + "\n",
             x, y0, legend = {"X": T_DIM})

def stamp_frame(w, h):
    """Sprite art for a stamp's paper: a perforated outer ring (every other
    pixel) and a solid inner ring; the picture field is left clear."""
    rows = []
    for r in range(h):
        s = ""
        for k in range(w):
            edge_r = r == 0 or r == h - 1
            edge_k = k == 0 or k == w - 1
            if edge_r or edge_k:
                pos = k if edge_r else r
                s += "W" if pos % 2 == 0 else "."
            elif r == 1 or r == h - 2 or k == 1 or k == w - 2:
                s += "W"
            else:
                s += "."
        rows.append(s)
    return "\n" + "\n".join(rows) + "\n"

def stamp(c, x, y, w, h, frame = PAPER):
    """A postage stamp at x, y (w x h): black picture field inside a
    perforated margin. Returns the field's top-left (x + 2, y + 2)."""
    c.rect(x + 1, y + 1, x + w - 2, y + h - 2, fill = "black")
    c.sprite(stamp_frame(w, h), x, y, legend = {"W": frame})
    return [x + 2, y + 2]

def mini_stamp(c, x, y, w, h, frame = PAPER):
    """A small stamp for the wire page: black field, perforated 1 px edge."""
    c.rect(x, y, x + w - 1, y + h - 1, fill = "black")
    rows = []
    for r in range(h):
        if r == 0 or r == h - 1:
            rows.append("".join(["W" if k % 2 == 0 else "." for k in range(w)]))
        else:
            rows.append(("W" if r % 2 == 0 else ".") + "." * (w - 2) + ("W" if r % 2 == 0 else "."))
    c.sprite("\n" + "\n".join(rows) + "\n", x, y, legend = {"W": frame})

def rubber(c, x, y, bid, col = RUBBER):
    """The FAAB rubber stamp, 13 px tall: '$23' inside a heavy 2 px rule,
    with a few pixels of the rule left unprinted like worn rubber. Returns
    its width."""
    s = "$" + str(bid)
    w = c.text_width(s, "5x7") + 6
    c.rect(x, y, x + w - 1, y + 12, fill = col)
    c.rect(x + 2, y + 2, x + w - 3, y + 10, fill = TAPE)
    # worn rubber
    c.pixel(x + w // 3, y, TAPE)
    c.pixel(x + (2 * w) // 3, y + 12, TAPE)
    c.pixel(x, y + 7, TAPE)
    c.pixel(x + w - 1, y + 3, TAPE)
    c.text(s, x + 3, y + 3, font = "5x7", color = col)
    return w

def rubber_w(c, bid):
    return c.text_width("$" + str(bid), "5x7") + 6

def dollar_text(c, x, y, s, col, font = "4x5"):
    """'$77 LEFT' with a sprite dollar (4x5's $ reads as an S). Returns the
    width."""
    c.sprite(DOLLAR, x, y - 1, legend = {"X": col})
    c.text(s, x + 4, y, font = font, color = col)
    return 4 + c.text_width(s, font)

def logo_big(c, p, x, y):
    """The player's 40x24 club logo; the NFL shield for a free agent."""
    c.image(LOGO.get(p["team"], "NFL.png"), x, y)

def logo_small(c, p, x, y):
    """24x18 club logo, or a grey helmet for a player without a club."""
    f = SMALL.get(p["team"], None)
    if f != None:
        c.image(f, x, y)
    else:
        c.sprite(HELMET, x + 5, y + 4, legend = {"X": "#5E6878", "M": "#9AA3B2"})

def gauge(c, x0, x1, y, wal):
    """A 3 px FAAB gauge on the tape: red ink for what's left, a faded
    track for what's spent."""
    if x1 - x0 < 6:
        return
    c.rect(x0, y, x1, y + 2, fill = "#C9BD97")
    fw = ((x1 - x0 + 1) * wal[0]) // wal[1] if wal[1] > 0 else 0
    if fw > 0:
        c.rect(x0, y, x0 + fw - 1, y + 2, fill = RUBBER)

# ------------------------------------------------------------- screens
def card(c, head, sub, rail_color, head_color):
    """Error / setup card: the message typed on a strip of tape with a
    small stamp in the status colour at its end, the hint under it."""
    c.fill("black")
    tape(c, L, R, 3, 19)
    h = fit(c, head, ["6x8", "5x7", "4x5"], R - 23 - TX0)
    c.text(h[0], TX0, 8 if h[1] == "6x8" else 9, font = h[1], color = head_color)
    mini_stamp(c, R - 20, 5, 18, 13, rail_color)
    c.sprite(BALL, R - 15, 9, legend = BALL_LEG)
    s = fit(c, sub, ["4x5", "picopixel"], R - L)
    c.text(s[0], L, 24, font = s[1], color = "#AEB4C0")

def quiet_wire(c, sub, demo):
    """Nothing moved: two telegraph poles, a slack wire, one bird and a
    blank strip of tape."""
    c.fill("black")
    pole = "#7A5230"
    for px in [14, 176]:
        c.rect(px, 3, px + 1, 31, fill = pole)
        c.rect(px - 4, 5, px + 5, 5, fill = pole)
        c.pixel(px - 3, 4, "#9AA3B2")
        c.pixel(px + 4, 4, "#9AA3B2")
    # the wire sags in a shallow curve between the insulators
    x0 = 18
    x1 = 172
    for x in range(x0, x1 + 1):
        u = (x - x0) * 1.0 / (x1 - x0)
        y = 4 + int(8.0 * 4.0 * u * (1.0 - u) + 0.5)
        c.pixel(x, y, "#5E6878")
    bx = 128
    u = (bx + 2 - x0) * 1.0 / (x1 - x0)
    c.sprite(BIRD, bx, 4 + int(8.0 * 4.0 * u * (1.0 - u) + 0.5) - 4, legend = {"K": "#8FA3BF", "O": GOLD})
    tape(c, 22, 168, 13, 30)
    c.text("QUIET WIRE", 95, 15, font = "5x7", color = T_INK, align = "center")
    s = fit(c, sub, ["4x5", "picopixel"], 136)
    c.text(s[0], 95, 23, font = s[1], color = T_DIM, align = "center")
    if demo:
        c.text("DEMO", 164, 16, font = "4x5", color = T_COMM, align = "right")

def state_screen(c, w, ctx):
    lg = w["lg"]
    if w["err"] != None:
        card(c, w["err"][0], w["err"][1], PAPER, T_INK)
        return True
    if lg["state"] == "predraft":
        card(c, "DRAFT DAY AHEAD", "THE WIRE OPENS AFTER YOUR DRAFT", ADD, T_ADD)
        return True
    if len(w["tx"]) == 0:
        wk = lg["week"]
        quiet_wire(c, ("NO MOVES IN WEEK " + str(wk)) if wk <= 1 else ("NO MOVES IN WEEKS " + str(wk - 1) + "-" + str(wk)),
                   lg["state"] == "demo")
        return True
    return False

# ------------------------------------------------------------ page 1
# Hero geometry: text on the tape from L to ZX1, then the crest stamp
# (22 x 30) and the player's logo stamp (46 x 30, the 40x24 logo).
TX0 = L + 3             # text starts clear of the tape's perforated end
LOGO_X = R - 45         # 140
CREST_X = LOGO_X - 25   # 115
ZX1 = CREST_X - 4       # 111

def latest(c, ctx):
    w = load_wire(ctx)
    if state_screen(c, w, ctx):
        return
    c.fill("black")
    tape(c, L, R, 1, 30)
    x = w["tx"][0]
    if x["kind"] == "trade":
        hero_trade(c, ctx, w, x)
    else:
        hero_move(c, ctx, w, x)

def first_fit(c, options, font, maxw):
    for s in options:
        if c.text_width(s, font) <= maxw:
            return s
    return ""

def crest_stamp(c, team, x, denom, denom_col):
    """The team's crest as a 22 x 30 stamp; `denom` (YOU / the time) is
    printed under it like a stamp's value. A gold margin marks YOU."""
    f = stamp(c, x, 1, 22, 30, GOLD if denom == "YOU" else PAPER)
    if denom == "":
        fl_badge(c, team, f[0] + 1, f[1] + 5, 16)
        return
    fl_badge(c, team, f[0] + 1, f[1] + 1, 16)
    fnt = "4x5" if c.text_width(denom, "4x5") <= 16 else "3x4"
    c.text(denom, f[0] + 9, f[1] + 19, font = fnt, color = denom_col, align = "center")

def hero_move(c, ctx, w, x):
    """TEAM VERB / PLAYER POS [$BID] / what went the other way, typed on
    the tape; the crest stamp and the player's logo stamp at the end."""
    team = team_of(w, x["team"])
    mine = tx_mine(w, x)
    demo = w["lg"]["state"] == "demo"
    vb = verb(x)
    vcol = T_DROP if vb[1] == DROP else (T_ADD if vb[1] == ADD else T_TRADE)
    when = "DEMO" if demo else ago(ctx, x["ts"], True)
    wal = w["wallet"] if (mine and x["kind"] != "chop") else None
    # The crest stamp's value: YOU on your move (the time moves to line 1),
    # else the time.
    crest_stamp(c, team, CREST_X, "YOU" if mine else when, GOLD if mine else (AMBER if demo else "#AEB4C0"))
    tx0 = TX0
    tx1 = ZX1

    # line 1: TEAM NAME + verb (+ the time when YOU took the stamp)
    vw = c.text_width(vb[0], "4x5")
    room = tx1 - tx0 - vw - 4
    if mine:
        long = "DEMO" if demo else ago(ctx, x["ts"], False)
        if c.text_width(long, "4x5") + 4 > room - 20:
            long = when
        lw = c.text_width(long, "4x5")
        c.text(long, tx1, 3, font = "4x5", color = T_DIM, align = "right")
        room -= lw + 5
    nm = shorten(c, team["name"], "4x5", room)
    if mine and nm != team["name"]:
        # Your move and the name no longer fits: YOU beats a half-name.
        nm = "YOU"
    c.text(nm, tx0, 3, font = "4x5", color = T_INK)
    c.text(vb[0], tx0 + (c.text_width(nm, "4x5") + 4 if nm != "" else 0), 3, font = "4x5", color = vcol)

    if x["kind"] == "chop":
        f = stamp(c, LOGO_X, 1, 46, 30)
        c.sprite(BLADE, f[0] + 15, f[1] + 2, legend = BLADE_LEG)
        c.text("CUT", tx0, 9, font = "9x12", color = T_DROP)
        n = x["n"]
        pl = str(n) + (" PLAYER" if n == 1 else " PLAYERS")
        c.text(first_fit(c, [pl + " TO WAIVERS STOP", pl + " TO WAIVERS", str(n) + " TO WAIVERS"], "4x5", tx1 - tx0),
               tx0, 23, font = "4x5", color = T_DIM)
        return

    # the logo stamp: the player who arrived (or left, for a drop)
    pid = x["adds"][0] if len(x["adds"]) > 0 else x["drops"][0]
    p = player_of(w, pid)
    f = stamp(c, LOGO_X, 1, 46, 30)
    logo_big(c, p, f[0] + 1, f[1] + 1)

    # line 2: the player, big, then the FAAB stamp(s)
    stamps_w = 0
    if x["bid"] >= 0:
        stamps_w += rubber_w(c, x["bid"]) + 4
    pos = p["pos"] if p["pos"] != "DEF" else ""
    pw = c.text_width(pos, "4x5") + 3 if pos != "" else 0
    pf = player_fit(c, p, ["9x12", "8x12", "7x12", "6x8", "5x7"], tx1 - tx0 - pw - stamps_w)
    big = pf[1] in ["9x12", "8x12", "7x12"]
    hy = 9 if big else 11
    c.text(pf[0], tx0, hy, font = pf[1], color = T_INK if x["kind"] != "drop" else T_DROP)
    nx = tx0 + c.text_width(pf[0], pf[1])
    if pos != "":
        c.text(pos, nx + 3, hy + (12 if big else 8) - 5, font = "4x5", color = T_DIM)
        nx += pw
    sx = nx + 4
    if x["bid"] >= 0:
        sx += rubber(c, sx, 9, x["bid"]) + 3
    more = len(x["adds"]) - 1 if len(x["adds"]) > 0 else len(x["drops"]) - 1

    # line 3: what went the other way, then STOP; your FAAB left at the end
    lx = tx0
    rx = tx1
    if wal != None:
        s = str(wal[0]) + " LEFT"
        ww = 4 + c.text_width(s, "4x5")
        if ww > 44:
            s = str(wal[0])
            ww = 4 + c.text_width(s, "4x5")
        dollar_text(c, tx1 - ww + 1, 23, s, RUBBER)
        rx = tx1 - ww - 3
    if x["beat"] != None:
        # They won a player YOU bid on: YOUR $98 BID LOST, the losing
        # amount in faded ink.
        if x["beat"] >= 0:
            amt = str(x["beat"])
            aw = 4 + c.text_width(amt, "4x5")
            yw = c.text_width("YOUR", "4x5")
            tail = first_fit(c, ["BID LOST STOP", "BID LOST", "LOST"], "4x5", rx - lx - yw - aw - 8)
            c.text("YOUR", lx, 23, font = "4x5", color = T_DROP)
            dollar_text(c, lx + yw + 4, 23, amt, RUBBER_DEAD)
            if tail != "":
                c.text(tail, lx + yw + aw + 8, 23, font = "4x5", color = T_DROP)
        else:
            c.text(first_fit(c, ["BEAT YOUR CLAIM STOP", "BEAT YOUR CLAIM", "BEAT YOU"], "4x5", rx - lx), lx, 23,
                   font = "4x5", color = T_DROP)
        return
    has_drop = len(x["adds"]) > 0 and len(x["drops"]) > 0
    words = []
    if x["bid"] < 0 and x["kind"] == "claim":
        words.append(["ON WAIVERS", "WAIVERS"])
    elif x["comm"]:
        words.append(["BY COMMISH", "COMMISH"])
    elif x["kind"] == "add":
        k = moves_this_week(w, x["team"]) if x["cur"] else 0
        if k >= 2:
            o = ordinal(k)
            words.append([o + " MOVE THIS WEEK", o + " MOVE THIS WK", o + " MOVE"])
        elif not has_drop:
            words.append(["FREE AGENT"])
    elif x["kind"] == "drop":
        words.append(["TO WAIVERS"])
    keep = 50 if has_drop else 0          # room kept for "DROPS T. SPEARS"
    for opts in words:
        s = first_fit(c, opts, "4x5", rx - lx - keep)
        if s != "":
            c.text(s, lx, 23, font = "4x5", color = T_DIM)
            lx += c.text_width(s, "4x5") + 5
    if more > 0:
        m = "+" + str(more) + (" MORE" if not has_drop else "")
        if lx + c.text_width(m, "4x5") <= rx:
            c.text(m, lx, 23, font = "4x5", color = T_INK)
            lx += c.text_width(m, "4x5") + 5
    if has_drop:
        # DROPS + the whole name or surname, never a clipped one
        d = player_of(w, x["drops"][0])
        dx = lx + c.text_width("DROPS", "4x5") + 4
        dn = first_fit(c, [d["name"], d["last"]], "4x5", rx - dx)
        if dn != "":
            c.text("DROPS", lx, 23, font = "4x5", color = T_DROP)
        else:
            # no room for the word: a red minus bar instead
            dx = lx + 7
            dn = first_fit(c, [d["name"], d["last"]], "4x5", rx - dx)
            if dn != "":
                c.rect(lx, 25, lx + 4, 25, fill = T_DROP)
        if dn != "":
            c.text(dn, dx, 23, font = "4x5", color = T_INK)
            lx = dx + c.text_width(dn, "4x5") + 5
    if lx > tx0 and rx - lx >= c.text_width("STOP", "4x5"):
        c.text("STOP", lx, 23, font = "4x5", color = T_DIM)

def extra_text(ex, font = "5x7"):
    if ex[0] == "pick":
        return ex[1] + " R" + ex[2]
    return ("" if font == "4x5" else "$") + str(ex[1]) + " FAAB"   # 4x5's $ reads as S

def side_text(c, w, s, font, maxw):
    """What one side of a trade received: the first player (or pick /
    FAAB), then +N for the rest."""
    rest = len(s[1]) + len(s[2]) - 1
    tail = (" +" + str(rest)) if rest > 0 else ""
    tw = c.text_width(tail, font) if tail != "" else 0
    if len(s[1]) > 0:
        return player_fit(c, player_of(w, s[1][0]), [font], maxw - tw)[0] + tail
    if len(s[2]) == 0:
        return fit(c, "NOTHING", [font], maxw)[0]
    return fit(c, extra_text(s[2][0], font), [font], maxw - tw)[0] + tail

def hero_trade(c, ctx, w, x):
    """TRADE / [TT] GETS T. MCLAURIN / [GG] GETS J. COOK +1 typed on the
    tape; both crests as stamps at the end with the swap arrows between."""
    demo = w["lg"]["state"] == "demo"
    sa = x["sides"][0]
    sb = x["sides"][1]
    ta = team_of(w, sa[0])
    tb = team_of(w, sb[0])
    when = "DEMO" if demo else ago(ctx, x["ts"], True)
    xb = R - 21
    xa = xb - 40
    for i in [0, 1]:
        t = ta if i == 0 else tb
        me = is_mine(w, x["sides"][i][0])
        crest_stamp(c, t, xa if i == 0 else xb, "YOU" if me else "", GOLD)
    c.sprite(SWAP, xa + 24, 10, legend = {"A": ta["color"], "B": tb["color"]})
    tx0 = TX0
    tx1 = xa - 4
    word = "COMMISH TRADE" if x["comm"] else "TRADE"
    c.text(word, tx0, 3, font = "4x5", color = T_COMM if x["comm"] else T_TRADE)
    tail = when if len(x["sides"]) <= 2 else (str(len(x["sides"])) + "-WAY")
    c.text(tail, tx1, 3, font = "4x5", color = T_DIM, align = "right")
    for i in [0, 1]:
        s = x["sides"][i]
        t = ta if i == 0 else tb
        y = 12 if i == 0 else 21
        me = is_mine(w, s[0])
        mono = "YOU" if me else fl_monogram(t)
        mw = c.text_width(mono, "5x7")
        # the monogram as a chip in the crest's own colours
        c.rect(tx0, y - 1, tx0 + mw + 3, y + 7, fill = "black" if me else color.dim(t["color"], 20))
        c.text(mono, tx0 + 2, y, font = "5x7", color = GOLD if me else t["color"])
        gx = tx0 + mw + 7
        c.text("GETS", gx, y + 2, font = "4x5", color = T_DIM)
        px = gx + c.text_width("GETS", "4x5") + 4
        c.text(side_text(c, w, s, "5x7", tx1 - px), px, y, font = "5x7", color = T_INK)

# ------------------------------------------------------------ page 2
# The tape runs on: three moves side by side, torn apart by perforated
# tear marks. Each has the crest and club logo as small stamps, a verb
# mark and the time, and the player (+ the bid in red) typed underneath.
def wire(c, ctx):
    w = load_wire(ctx)
    if state_screen(c, w, ctx):
        return
    c.fill("black")
    tape(c, L, R, 2, 30)
    desk = w["king"] != None or w["wallet"] != None
    rest = w["tx"][1:(3 if desk else MAX_SHOWN)]
    tw = (R - L + 1) // 3      # 60
    demo = w["lg"]["state"] == "demo"
    for i in range(3):
        x0 = L + 2 + i * tw       # 8, 68, 128: clear of the tape's perforated end
        if i > 0:
            tear(c, x0 - 3, 3, 29)
        if desk and i == 2:
            desk_tile(c, w, x0, tw - 4, demo)
        elif i < len(rest):
            tile(c, ctx, w, rest[i], x0, tw - 4, demo and not desk and i == len(rest) - 1)
        else:
            end_tile(c, x0, tw - 4)

def end_tile(c, x0, width):
    """A slot with no move: the tape runs out."""
    c.text("END OF", x0 + width // 2, 10, font = "4x5", color = T_DIM, align = "center")
    c.text("THE WIRE", x0 + width // 2, 17, font = "4x5", color = T_DIM, align = "center")

def desk_tile(c, w, x0, width, demo):
    """The league desk: this week's WIRE KING (crown, crest stamp, moves)
    and your FAAB left with a red gauge."""
    right = x0 + width - 1
    king = w["king"]
    wal = w["wallet"]
    note = "DEMO" if demo else "WK" + str(w["lg"]["week"])
    if king != None:
        t = team_of(w, king[0])
        mini_stamp(c, x0, 3, 18, 20, GOLD if is_mine(w, king[0]) else PAPER)
        fl_badge(c, t, x0 + 1, 5, 16)
        c.sprite(CROWN, x0 + 21, 4, legend = CROWN_LEG)
        c.text(note, right, 4, font = "4x5" if c.text_width(note, "4x5") <= right - x0 - 33 else "3x4",
               color = T_COMM if demo else T_DIM, align = "right")
        n = str(king[1])
        c.text(n, x0 + 21, 12, font = "6x8", color = T_INK)
        mx = x0 + 21 + c.text_width(n, "6x8") + 2
        c.text(first_fit(c, ["MOVES", "MOVS"], "4x5", right - mx + 1), mx, 15, font = "4x5", color = T_DIM)
        if wal != None:
            ws = str(wal[0]) + " LEFT"
            if 4 + c.text_width(ws, "4x5") > width - 9:
                ws = str(wal[0])        # $1000: the gauge says the rest
            ww = dollar_text(c, x0, 24, ws, RUBBER)
            gauge(c, x0 + ww + 3, right, 25, wal)
        else:
            c.text("YOU" if is_mine(w, king[0]) else "WIRE KING", x0, 24, font = "4x5", color = T_INK)
        return
    # wallet only: FAAB, the big number, and what it's out of with the gauge
    c.text("FAAB", x0, 4, font = "4x5", color = T_DIM)
    if demo:
        c.text("DEMO", right, 4, font = "4x5", color = T_COMM, align = "right")
    n = str(wal[0])
    f = "9x12" if c.text_width(n, "9x12") <= width - 5 else "6x8"
    c.sprite(DOLLAR, x0, 12, legend = {"X": RUBBER})
    c.text(n, x0 + 5, 10 if f == "9x12" else 12, font = f, color = RUBBER)
    of = fit(c, "OF " + str(wal[1]), ["4x5"], width - 10)[0]
    c.text(of, x0, 24, font = "4x5", color = T_DIM)
    gauge(c, x0 + c.text_width(of, "4x5") + 3, right, 25, wal)

# A 7 x 7 plus / minus for the wire page's verb mark.
PLUS7 = """
..XXX..
..XXX..
XXXXXXX
XXXXXXX
XXXXXXX
..XXX..
..XXX..
"""
MINUS7 = """
.......
.......
XXXXXXX
XXXXXXX
XXXXXXX
.......
.......
"""

def tile_foot(c, left, lcol, tail, tcol, x0, right, dollar = False, whole = []):
    """The line typed under a tile: `left` (fitted) and `tail` at the right
    (the bid with a sprite dollar, or the time). The time gives way when it
    would clip the name (anything but the full text or one in `whole`)."""
    tw = 0
    if tail != "" and not dollar:
        narrow = left(right - x0 + 1 - c.text_width(tail, "4x5") - 4)
        if narrow not in whole and narrow != left(right - x0 + 1):
            tail = ""
    if tail != "":
        tw = c.text_width(tail, "4x5") + (4 if dollar else 0)
        if dollar:
            dollar_text(c, right - tw + 1, 24, tail, tcol)
        else:
            c.text(tail, right, 24, font = "4x5", color = tcol, align = "right")
        tw += 4
    c.text(left(right - x0 + 1 - tw), x0, 24, font = "4x5", color = lcol)

def tile(c, ctx, w, x, x0, width, demo):
    """Crest stamp + club logo stamp + a verb mark, then the player and
    the bid (or the time) typed underneath. Your move: the crest stamp's
    edge is gold and a gold bar runs under the tile."""
    mine = tx_mine(w, x)
    right = x0 + width - 1
    when = "DEMO" if demo else ago(ctx, x["ts"], True)
    wcol = T_COMM if demo else T_DIM
    if x["kind"] == "trade":
        sa = x["sides"][0]
        sb = x["sides"][1]
        ta = team_of(w, sa[0])
        tb = team_of(w, sb[0])
        mini_stamp(c, x0, 3, 18, 20, GOLD if is_mine(w, sa[0]) else PAPER)
        fl_badge(c, ta, x0 + 1, 5, 16)
        c.sprite(SWAP_S, x0 + 19, 10, legend = {"A": ta["color"], "B": tb["color"]})
        mini_stamp(c, x0 + 28, 3, 18, 20, GOLD if is_mine(w, sb[0]) else PAPER)
        fl_badge(c, tb, x0 + 29, 5, 16)
        whole = []
        if len(sa[1]) > 0:
            pa = player_of(w, sa[1][0])
            more = len(sa[1]) + len(sa[2]) - 1
            whole = [n + ((" +" + str(more)) if more > 0 else "") for n in [pa["name"], pa["last"]]]
        tile_foot(c, lambda mw: side_text(c, w, sa, "4x5", mw), T_INK, when, wcol, x0, right, False, whole)
    else:
        team = team_of(w, x["team"])
        mini_stamp(c, x0, 3, 18, 20, GOLD if mine else PAPER)
        fl_badge(c, team, x0 + 1, 5, 16)
        if x["kind"] == "chop":
            c.sprite(BLADE, x0 + 22, 2, legend = BLADE_LEG)
            c.text("CHOP", right, 4, font = "4x5", color = T_DROP, align = "right")
            tile_foot(c, lambda mw: fit(c, str(x["n"]) + " FREED", ["4x5"], mw)[0], T_INK, when, wcol, x0, right)
        else:
            pid = x["adds"][0] if len(x["adds"]) > 0 else x["drops"][0]
            p = player_of(w, pid)
            mini_stamp(c, x0 + 19, 3, 26, 20)
            logo_small(c, p, x0 + 20, 4)
            add = len(x["adds"]) > 0
            c.sprite(PLUS7 if add else MINUS7, right - 6, 4, legend = {"X": T_ADD if add else T_DROP})
            pos = p["pos"] if p["pos"] != "DEF" else ""
            if pos != "" and c.text_width(pos, "4x5") <= right - x0 - 45:
                c.text(pos, right, 14, font = "4x5", color = T_DIM, align = "right")
            if x["bid"] >= 0:
                tile_foot(c, lambda mw: player_fit(c, p, ["4x5"], mw)[0], T_INK if add else T_DROP,
                          str(x["bid"]), RUBBER, x0, right, True)
            else:
                tile_foot(c, lambda mw: player_fit(c, p, ["4x5"], mw)[0], T_INK if add else T_DROP,
                          when, wcol, x0, right, False, [p["name"], p["last"]])
    if mine:
        c.rect(x0, 31, right, 31, fill = GOLD)
