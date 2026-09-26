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
# WAIVER TARGETS
#
# The best players nobody in your league has rostered, ranked by this
# week's projection, what they have scored this season, and how fast
# managers all over Sleeper are adding them.
#
# DESIGN. THE WAIVER WIRE, literally: a telephone wire sagging between two
# wooden poles (x 6-7 and 184-185, crossarms, glass insulators), and the
# unrostered players hang from it on clothespins like laundry. Nothing is
# lit outside x 6..185; logos are the authored 24 x 18 set, never scaled.
#
#   page 1 (target)
#   |T~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~T|
#   ||  +-pin--------pin-+  +=pin=================pin==+  +-pin--------pin-+|
#   ||  |[LOGO ] #2      |  |[LOGO ] WR VS NO         Q|  |[LOGO ] #3      ||
#   ||  |[24x18] 11.2    |  |[24x18] 13.1 (7x12) <WR2 ]|  |[24x18] 10.6    ||
#   ||  |[     ] Q (fl)  |  |        (big)       <+7.0]|  |[     ] (flame) ||
#   ||  |COKER           |  |SHAHEED (5x7)       (fl)62K|  |ALLEN           ||
#   ++  +----------------+  +==========================+  +----------------++
#
#   The #1 card is the big one in the middle (82 wide, gold frame, hangs
#   highest where the wire sags): club logo, position + this week's
#   opponent - or CUT <monogram in the cutting team's badge colour>,
#   WAIVERS, ON BYE - and an injury code at the right, the projection in
#   7x12, the surname in 5x7, a small flame + HOT ADD count. The claim tag
#   survives as a small manila tag with a punched hole beside the number:
#   YOUR need when the team matched (WR2 over a green +7.0 stamp, NEED over
#   an amber K, NO / GAIN), else season points (SZN / 38). #2 and #3 hang
#   either side (44 wide, slate frames): logo, #rank in the position colour,
#   projection, injury code + flame, surname. DEMO sits in the #1 card's
#   bottom-right corner (in place of the hot-add count).
#
#   page 2 (wire)   the wire goes on: #4, #5, #6 on the same poles; with your
#   team matched the third card is YOUR claim ticket in manila - your crest,
#   WAIV #7, $73 LEFT (else your team's name). The position (and ALL when
#   it rotates) and DEMO hang in the gaps.
#
#   State screens (error, offline, private, predraft, picked clean) are one
#   wide sign pinned to the same wire: amber frame for problems, green for
#   good news.
#
# Ranking: this week's projection pulled toward season points per game by
# min(gp, 6) / 18 (1/9 after two games, 1/3 from six), plus a hot-add
# bonus of min(3, 0.35 x proj) at 150K adds in a day. A player on bye
# projects 0 and falls down the list; one with no projection for a game
# week (a backup, an inactive) falls further.
#
# Scoring: ESPN's numbers are already in the league's scoring. Sleeper's
# are recomputed in YOUR league's scoring by the adapter's fl_score() -
# sum(scoring_settings[stat] x stat) - for projections, season points and
# your own roster (6-pt pass TDs, TE premium, bonuses all count).
#
# Position: the dropdown picks one; ALL steps through the positions one per
# refresh (RB, WR, TE, QB, RB, WR, DEF, K - the skill spots come round
# twice, a 40-minute lap). A league with no K or DEF slot is skipped on to
# the next skill position: ESPN reads its lineupSlotCounts, Sleeper its
# roster_positions (or, when a league has none, the fact that nobody
# rosters one). Picking K or DEF by hand in such a league says so.
#
# DATA (requests per render, 8 max):
#   Sleeper  adapter 3 (matchups = False; scoring_settings come with it)
#            + trending adds + the position's projections + its season
#            stats + this week's transactions for DROPPED = 7. The league's
#            roster_positions and FAAB settings come with the adapter
#            (v2.1 lg["raw"], 0 calls). Last season's ID: adapter 5 (the
#            follow and this season's managers) + 3 = 8, still in the
#            league's exact scoring, with FAAB, without DROPPED. Your need
#            and waiver order come from rosters the adapter already read
#            (0 calls).
#            Rostered = every rosters[].players / reserve / taxi id.
#   ESPN     adapter 1 + kona_player_info (FREEAGENT + WAIVERS at the
#            position, sorted by this week's projection, 20 players) +
#            trending adds + Sleeper's projections for the position (names
#            for trending ids, byes, opponents) = 4; + your roster
#            (mRoster&forTeamId, ~220 KB) when the team matched = 5; + one
#            or two mTransactions2 (~27 KB) when the #1 is ON WAIVERS = 7.
#   Mapping trending ids onto ESPN players: normalised full name + club,
#   then the name alone; a defense by its club.
# Refresh 300: free-text inputs (the under-5-minute rule allows only
# dropdown / checkbox / selection inputs).
# ======================================================================

INK = "#F4F7FF"
DIM = "#6E7A94"
FIRST = "#9AA3B2"
OFFLINE = "#3C4043"
DIV = "#232A3A"
GOOD = "#2FE06F"
AMBER = "#FFBF00"
ALARM = "#FF3B30"
HOT = "#FF8A1F"

# The claim tag: manila paper, a darker fold, black stamp.
PAPER = "#E8C06A"
PAPER_EDGE = "#9C7432"
STAMP = "#000000"
STRING = "#8A93A6"

L = 6
R = 185

POS_COLOR = {"QB": "#FF6F9C", "RB": "#2EE6C8", "WR": "#5CB8FF", "TE": "#FFB45C",
             "K": "#C792FF", "DEF": "#B0BCCB"}
POSITIONS = ["QB", "RB", "WR", "TE", "K", "DEF"]
ALL_ORDER = ["RB", "WR", "TE", "QB", "RB", "WR", "DEF", "K"]
FRAME_SECONDS = 300

# injury_status (Sleeper) / injuryStatus (ESPN) -> [tag, colour]
INJ = {
    "QUESTIONABLE": ["Q", AMBER], "DOUBTFUL": ["D", "#FF7A1F"], "OUT": ["OUT", ALARM],
    "IR": ["IR", ALARM], "INJURY_RESERVE": ["IR", ALARM], "PUP": ["PUP", ALARM],
    "SUS": ["SUS", "#FF7A1F"], "SUSPENSION": ["SUS", "#FF7A1F"], "DAY_TO_DAY": ["DTD", AMBER],
}

# ESPN proTeamId -> club
ESPN_TEAM = {1: "ATL", 2: "BUF", 3: "CHI", 4: "CIN", 5: "CLE", 6: "DAL", 7: "DEN", 8: "DET",
             9: "GB", 10: "TEN", 11: "IND", 12: "KC", 13: "LV", 14: "LAR", 15: "MIA", 16: "MIN",
             17: "NE", 18: "NO", 19: "NYG", 20: "NYJ", 21: "PHI", 22: "ARI", 23: "PIT", 24: "LAC",
             25: "SF", 26: "SEA", 27: "TB", 28: "WSH", 29: "CAR", 30: "JAX", 33: "BAL", 34: "HOU"}
# ESPN lineup slot to filter the player pool by
ESPN_SLOT = {"QB": 0, "RB": 2, "WR": 4, "TE": 6, "K": 17, "DEF": 16}
ESPN_POS = {1: "QB", 2: "RB", 3: "WR", 4: "TE", 5: "K", 16: "DEF"}

# A defense is shown as city over nickname.
CLUB = {
    "ARI": ["ARIZONA", "CARDINALS"], "ATL": ["ATLANTA", "FALCONS"], "BAL": ["BALTIMORE", "RAVENS"],
    "BUF": ["BUFFALO", "BILLS"], "CAR": ["CAROLINA", "PANTHERS"], "CHI": ["CHICAGO", "BEARS"],
    "CIN": ["CINCINNATI", "BENGALS"], "CLE": ["CLEVELAND", "BROWNS"], "DAL": ["DALLAS", "COWBOYS"],
    "DEN": ["DENVER", "BRONCOS"], "DET": ["DETROIT", "LIONS"], "GB": ["GREEN BAY", "PACKERS"],
    "HOU": ["HOUSTON", "TEXANS"], "IND": ["INDIANAPOLIS", "COLTS"], "JAX": ["JACKSONVILLE", "JAGUARS"],
    "KC": ["KANSAS CITY", "CHIEFS"], "LV": ["LAS VEGAS", "RAIDERS"], "LAC": ["LOS ANGELES", "CHARGERS"],
    "LAR": ["LOS ANGELES", "RAMS"], "MIA": ["MIAMI", "DOLPHINS"], "MIN": ["MINNESOTA", "VIKINGS"],
    "NE": ["NEW ENGLAND", "PATRIOTS"], "NO": ["NEW ORLEANS", "SAINTS"], "NYG": ["NEW YORK", "GIANTS"],
    "NYJ": ["NEW YORK", "JETS"], "PHI": ["PHILADELPHIA", "EAGLES"], "PIT": ["PITTSBURGH", "STEELERS"],
    "SF": ["SAN FRANCISCO", "49ERS"], "SEA": ["SEATTLE", "SEAHAWKS"], "TB": ["TAMPA BAY", "BUCCANEERS"],
    "TEN": ["TENNESSEE", "TITANS"], "WSH": ["WASHINGTON", "COMMANDERS"],
}
TEAM_FIX = {"WAS": "WSH", "JAC": "JAX", "LA": "LAR", "OAK": "LV", "SD": "LAC"}

# Logos, as literal paths so the asset lint sees every one: the 24 x 18
# list set. Never scaled.
SMALL = {
    "ARI": "ARI_S.png", "ATL": "ATL_S.png", "BAL": "BAL_S.png", "BUF": "BUF_S.png", "CAR": "CAR_S.png",
    "CHI": "CHI_S.png", "CIN": "CIN_S.png", "CLE": "CLE_S.png", "DAL": "DAL_S.png", "DEN": "DEN_S.png",
    "DET": "DET_S.png", "GB": "GB_S.png", "HOU": "HOU_S.png", "IND": "IND_S.png", "JAX": "JAX_S.png",
    "KC": "KC_S.png", "LV": "LV_S.png", "LAC": "LAC_S.png", "LAR": "LAR_S.png", "MIA": "MIA_S.png",
    "MIN": "MIN_S.png", "NE": "NE_S.png", "NO": "NO_S.png", "NYG": "NYG_S.png", "NYJ": "NYJ_S.png",
    "PHI": "PHI_S.png", "PIT": "PIT_S.png", "SF": "SF_S.png", "SEA": "SEA_S.png", "TB": "TB_S.png",
    "TEN": "TEN_S.png", "WSH": "WSH_S.png",
}

SUFFIX = ["JR.", "JR", "SR.", "SR", "II", "III", "IV", "V"]

FLAME = """
...R...
..RR...
..RYR.R
.RYYRRR
RRYYYRR
RYYWYYR
RYYWWYR
.RYYYR.
"""
FLAME_LEG = {"R": "#FF4A1C", "Y": "#FFB020", "W": "#FFF3B0"}

TTL_TREND = 1800
TTL_PROJ = 3600
TTL_SEASON = 21600
TTL_POOL = 900
MAX_BODY = 1000000   # the published response cap; bigger bodies are treated as missing

# ------------------------------------------------------------ helpers
def club(t):
    t = str(t if t != None else "").upper()
    return TEAM_FIX.get(t, t)

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

def surname(c, s, fonts, maxw):
    """The surname in the largest font that fits; a JR. / III is dropped
    before anything is clipped."""
    got = fit(c, s, fonts, maxw)
    if got[0] == s:
        return got
    words = s.split(" ")
    if len(words) > 1 and words[len(words) - 1] in SUFFIX:
        return fit(c, " ".join(words[:len(words) - 1]), fonts, maxw)
    return got

def kfmt(n):
    """Adds as the panel says them: 950, 6.2K, 62K, 411K."""
    n = int(n)
    if n < 1000:
        return str(n)
    if n < 10000:
        return fl_fmt1(n / 1000.0) + "K"
    return str((n + 500) // 1000) + "K"

def pos_for(ctx):
    want = str(ctx.inputs.get("position", "ALL")).strip().upper()
    if want in POSITIONS:
        return [want, False]
    return [ALL_ORDER[(ctx.now.unix // FRAME_SECONDS) % len(ALL_ORDER)], True]

def next_skill(ctx):
    """ALL landed on K or DEF in a league that doesn't play one: the next
    skill position in the rotation."""
    i = (ctx.now.unix // FRAME_SECONDS) % len(ALL_ORDER)
    for k in range(1, len(ALL_ORDER) + 1):
        p = ALL_ORDER[(i + k) % len(ALL_ORDER)]
        if p not in ["K", "DEF"]:
            return p
    return "RB"

NOT_PLAYED = {"K": "NO KICKERS IN THIS LEAGUE", "DEF": "NO DEFENSES IN THIS LEAGUE"}

def espn_plays(lg, pos):
    """K and DEF only count when the league has a lineup slot for them
    (no flex takes either). Unknown settings -> assume it does."""
    if pos not in ["K", "DEF"]:
        return True
    counts = fl_d(fl_d(fl_d(lg["raw"]["json"], "settings", {}), "rosterSettings", {}), "lineupSlotCounts", None)
    if type(counts) != "dict":
        return True
    return int(fl_num(fl_d(counts, str(ESPN_SLOT[pos]), 0))) > 0

def split_name(first, last, pos, team):
    """[first line, surname] - a defense is city over nickname."""
    if pos == "DEF":
        cn = CLUB.get(team, [team, "DEFENSE"])
        return [cn[0], cn[1]]
    return [fl_clean(first), fl_clean(last)]

def body_ok(r):
    return r["status_code"] == 200 and len(r.get("body", "")) <= MAX_BODY

# ------------------------------------------------------------ league scoring
# Every Sleeper stat line becomes points in YOUR league through the
# adapter's fl_score(lg, stats): sum(scoring_settings[stat] * stat), exactly
# Sleeper's own formula, so 6-pt pass TDs, -2 INTs, TE premium, 100-yard
# bonuses and changed yardage all land. The settings come with the league
# the adapter already read (lg["raw"]["scoring"], also for a followed
# last-season ID); a league without them falls back to Sleeper's preset
# pts_ppr / pts_half_ppr / pts_std. Used for this week's projection, season
# points and your own roster alike.

def league_object(lg, pos):
    """roster_positions (does the league play K / DEF?) and FAAB
    (waiver_type, waiver_budget), shaped like the Sleeper league object.
    Adapter v2.1 carries both in lg["raw"] from the league object it
    already read - no request, and a followed old-season ID gets them too."""
    raw = lg["raw"]
    return {"roster_positions": raw.get("roster_positions", []),
            "settings": {"waiver_type": raw.get("waiver_type", 0),
                         "waiver_budget": raw.get("waiver_budget", 0)}}

# Ranking (the review's formula): this week's projection pulled toward
# season points per game by min(gp, 6) / 18 - 1/9 of the way after two
# games, 1/3 from six on, so one big week can't outrank a strong
# projection - plus a hot-add bonus of min(3, 0.35 x proj) at 150K adds, so
# a buzzy backup projecting 4 can't top the list on adds alone.
def score_of(p):
    proj = p["proj"]
    gp = p["gp"] if p["gp"] < 6 else 6
    base = proj
    if p["gp"] > 0:
        base = proj + (p["ppg"] - proj) * gp / 18.0
    if p["bye"]:
        base = p["ppg"] / 3.0
    elif proj <= 0:
        base = p["ppg"] / 6.0        # not expected to play this week
    cap = 0.35 * proj
    cap = 3.0 if cap > 3.0 else (0.0 if cap < 0 else cap)
    hot = cap * (p["adds"] if p["adds"] < 150000 else 150000) / 150000.0
    return base + hot

def player(first, last, pos, team, proj, season, gp, adds, inj, bye, status, pid = "", opp = ""):
    nm = split_name(first, last, pos, team)
    p = {"first": nm[0], "last": nm[1], "pos": pos, "team": team, "proj": proj,
         "season": season, "gp": gp, "ppg": season / (gp * 1.0) if gp > 0 else 0.0,
         "adds": adds, "inj": inj, "bye": bye, "status": status, "id": str(pid),
         "opp": club(opp), "cut": None}
    p["score"] = score_of(p)
    return p

def rank(players):
    keep = [p for p in players if p["proj"] > 0 or p["season"] > 0 or p["adds"] > 0]
    return sorted(keep, key = lambda p: (-p["score"], -p["proj"], p["last"]))

# ------------------------------------------------------------ Sleeper feeds
def trending(b):
    """Sleeper id -> adds in the last 24 hours (top 100 across Sleeper)."""
    out = {}
    r = fl_get(b, FL_SLEEPER + "players/nfl/trending/add",
               params = {"lookback_hours": "24", "limit": "100"}, ttl = TTL_TREND)
    if r["status_code"] != 200 or type(r["json"]) != "list":
        return out
    for row in r["json"]:
        pid = str(fl_d(row, "player_id", ""))
        if pid != "":
            out[pid] = int(fl_num(fl_d(row, "count", 0)))
    return out

def sleeper_feed(b, kind, season, week, pos, ttl):
    """projections / stats rows for one position; None when unavailable."""
    path = FL_SLEEPER_API + kind + "/nfl/" + str(season)
    if week > 0:
        path += "/" + str(week)
    r = fl_get(b, path + "?season_type=regular&order_by=pts_ppr&position[]=" + pos, ttl = ttl)
    if not body_ok(r) or type(r["json"]) != "list":
        return None
    return r["json"]

def playing_teams(rows):
    """Clubs with a game this week, from the projections' opponents. None
    when the feed is too thin to tell (then nobody is marked on bye)."""
    teams = {}
    for row in rows:
        if fl_d(row, "opponent", "") != "":
            teams[club(fl_d(row, "team", ""))] = True
    return teams if len(teams) >= 20 else None

def on_bye(teams, team):
    return teams != None and team != "" and not teams.get(team, False)

def inj_of(s):
    s = str(s if s != None else "").upper()
    return s if s in INJ else ""

# ------------------------------------------------------------ Sleeper
def sleeper_mine(lg):
    """Your roster's active player ids (reserve / taxi left out) and your
    waiver standing, when the team input matched."""
    if not lg["me_matched"]:
        return None
    for ro in lg["raw"]["rosters"]:
        if fl_d(ro, "roster_id", None) != lg["me"]:
            continue
        out = {}
        for pid in fl_d(ro, "players", []) or []:
            out[str(pid)] = True
        for k in ["reserve", "taxi"]:
            for pid in fl_d(ro, k, []) or []:
                out.pop(str(pid), None)
        return {"ids": out, "settings": fl_d(ro, "settings", {})}
    return None

def sleeper_waiver(lg, mine, league):
    """{rank, left}: your waiver position, and FAAB left (-1 = not a FAAB
    league / unknown)."""
    s = mine["settings"]
    rk = int(fl_num(fl_d(s, "waiver_position", 0)))
    left = -1
    st = fl_d(league, "settings", {}) if league != None else {}
    if int(fl_num(fl_d(st, "waiver_type", -1), -1)) == 2:
        left = int(fl_num(fl_d(st, "waiver_budget", 0))) - int(fl_num(fl_d(s, "waiver_budget_used", 0)))
        if left < 0:
            left = 0
    return {"rank": rk, "left": left}

def sleeper_cut(lg, t):
    """DROPPED: this week's transactions (small, +1) - who let the #1 target
    go. The request adapter v2 frees (matchups = False) pays for it on a
    this-season ID; a followed old-season ID has no room and skips it
    silently."""
    if len(t["players"]) == 0:
        return
    top = t["players"][0]
    r = fl_get(lg["budget"], FL_SLEEPER + "league/" + str(lg["raw"]["league_id"]) + "/transactions/" +
               str(lg["week"]), ttl = 600)
    if r["status_code"] != 200 or type(r["json"]) != "list":
        return
    for x in r["json"]:
        if type(x) != "dict" or str(fl_d(x, "status", "")) != "complete":
            continue
        dr = fl_d(x, "drops", {})
        if type(dr) == "dict" and top["id"] in dr:
            top["cut"] = dr[top["id"]]
            return

def sleeper_targets(ctx, lg, pos, rotating):
    b = lg["budget"]
    season = lg["season"]
    week = lg["week"]
    taken = {}
    for ro in lg["raw"]["rosters"]:
        for k in ["players", "reserve", "taxi"]:
            for pid in fl_d(ro, k, []) or []:
                taken[str(pid)] = True
    league = league_object(lg, pos)
    rp = fl_d(league, "roster_positions", None) if league != None else None
    if pos in ["K", "DEF"] and type(rp) == "list" and len(rp) > 0 and pos not in [str(x) for x in rp]:
        # The league object says there is no K / DEF slot.
        if not rotating:
            return {"ok": False, "err": [NOT_PLAYED[pos], "PICK ANOTHER POSITION IN SETTINGS"], "pos": pos}
        pos = next_skill(ctx)
    adds = trending(b)
    rows = sleeper_feed(b, "projections", season, week, pos, TTL_PROJ)
    if rows == None:
        return {"ok": False, "err": ["PROJECTIONS BUSY", "SLEEPER - RETRY IN 5 MIN"]}
    if pos in ["K", "DEF"] and (type(rp) != "list" or len(rp) == 0) and len(taken) > 0 and len(rows) > 0:
        # No roster_positions: nobody rostering one means no K / DEF slot.
        held = len([r for r in rows if taken.get(str(fl_d(r, "player_id", "")), False)])
        if held == 0:
            if not rotating:
                return {"ok": False, "err": [NOT_PLAYED[pos], "PICK ANOTHER POSITION IN SETTINGS"], "pos": pos}
            pos = next_skill(ctx)
            rows = sleeper_feed(b, "projections", season, week, pos, TTL_PROJ)
            if rows == None:
                return {"ok": False, "err": ["PROJECTIONS BUSY", "SLEEPER - RETRY IN 5 MIN"]}
    seas = sleeper_feed(b, "stats", season, 0, pos, TTL_SEASON)
    tot = {}
    for row in seas or []:
        st = fl_d(row, "stats", {})
        tot[str(fl_d(row, "player_id", ""))] = [fl_score(lg, st), int(fl_num(fl_d(st, "gp", 0)))]
    playing = playing_teams(rows)
    me = sleeper_mine(lg)
    mine = []
    out = []
    for row in rows:
        pid = str(fl_d(row, "player_id", ""))
        pl = fl_d(row, "player", {})
        if pid == "" or str(fl_d(pl, "position", "")) != pos:
            continue
        team = club(fl_d(row, "team", fl_d(pl, "team", "")))
        pj = fl_score(lg, fl_d(row, "stats", {}))
        if me != None and me["ids"].get(pid, False):
            mine.append([pj, on_bye(playing, team)])
        if taken.get(pid, False) or team not in SMALL:
            continue                       # rostered, or not on an NFL roster
        sz = tot.get(pid, [0.0, 0])
        out.append(player(fl_d(pl, "first_name", ""), fl_d(pl, "last_name", ""), pos, team,
                          pj, sz[0], sz[1], adds.get(pid, 0),
                          inj_of(fl_d(pl, "injury_status", "")), on_bye(playing, team), "UNROSTERED",
                          pid, fl_d(row, "opponent", "")))
    t = {"ok": True, "players": rank(out), "season_known": seas != None, "pos": pos,
         "mine": mine if me != None else None, "exact": len(lg["raw"]["scoring"]) > 0,
         "wv": sleeper_waiver(lg, me, league) if me != None else None}
    sleeper_cut(lg, t)
    return t

# ------------------------------------------------------------ ESPN
def espn_targets(ctx, lg, pos):
    b = lg["budget"]
    raw = lg["raw"]
    season = raw["season"]
    period = int(fl_num(fl_d(raw["json"], "scoringPeriodId", lg["week"]), lg["week"]))
    if period < 1:
        period = lg["week"]
    wid = "11" + str(season) + str(period)
    filt = ('{"players":{"filterStatus":{"value":["FREEAGENT","WAIVERS"]},' +
            '"filterSlotIds":{"value":[' + str(ESPN_SLOT[pos]) + ']},"limit":20,' +
            '"sortAppliedStatTotal":{"sortAsc":false,"sortPriority":1,"value":"' + wid + '"},' +
            '"filterStatsForTopScoringPeriodIds":{"value":1,"additionalValue":["00' + str(season) + '","' + wid + '"]}}}')
    headers = dict(raw["cookie"])
    headers["X-Fantasy-Filter"] = filt
    r = fl_get(b, FL_ESPN + str(season) + "/segments/0/leagues/" + str(raw["league_id"]),
               params = {"view": "kona_player_info", "scoringPeriodId": str(period)},
               headers = headers, ttl = TTL_POOL)
    sc = r["status_code"]
    if sc == 401 or sc == 403:
        return {"ok": False, "err": ["PRIVATE ESPN LEAGUE", "ADD ESPN COOKIES IN SETTINGS"]}
    if not body_ok(r) or type(r["json"]) != "dict":
        return {"ok": False, "err": ["ESPN BUSY" if sc == 200 else ("ESPN OFFLINE" if sc == 0 else "ESPN ERROR"),
                                     "PLAYER POOL - RETRY IN 5 MIN"]}
    adds = trending(b)
    # Sleeper's projections for the position: trending ids -> name + club,
    # and which clubs have a game this week.
    srows = sleeper_feed(b, "projections", season, period, pos, TTL_PROJ) or []
    playing = playing_teams(srows)
    opp = {}
    for row in srows:
        if fl_d(row, "opponent", "") != "":
            opp[club(fl_d(row, "team", ""))] = fl_d(row, "opponent", "")
    by_key = {}
    by_name = {}
    for row in srows:
        pid = str(fl_d(row, "player_id", ""))
        n = adds.get(pid, 0)
        if n == 0:
            continue
        pl = fl_d(row, "player", {})
        team = club(fl_d(row, "team", fl_d(pl, "team", "")))
        if pos == "DEF":
            by_key["DEF" + team] = n
            continue
        nm = name_key(str(fl_d(pl, "first_name", "")) + " " + str(fl_d(pl, "last_name", "")))
        by_key[nm + team] = n
        by_name[nm] = n
    out = []
    for e in fl_d(r["json"], "players", []):
        pl = fl_d(e, "player", {})
        p2 = ESPN_POS.get(int(fl_num(fl_d(pl, "defaultPositionId", 0))), "")
        if p2 != pos:
            continue
        team = ESPN_TEAM.get(int(fl_num(fl_d(pl, "proTeamId", 0))), "")
        if team == "":
            continue
        proj = 0.0
        season_pts = 0.0
        gp = 0
        for s in fl_d(pl, "stats", []):
            src = int(fl_num(fl_d(s, "statSourceId", -1)))
            split = int(fl_num(fl_d(s, "statSplitTypeId", -1)))
            if src == 1 and split == 1 and int(fl_num(fl_d(s, "scoringPeriodId", -1))) == period:
                proj = fl_num(fl_d(s, "appliedTotal", 0))
            elif src == 0 and split == 0:
                season_pts = fl_num(fl_d(s, "appliedTotal", 0))
                gp = int(fl_num(fl_d(fl_d(s, "stats", {}), "210", 0)))
        full = str(fl_d(pl, "fullName", ""))
        if pos == "DEF":
            n = by_key.get("DEF" + team, 0)
        else:
            nk = name_key(full)
            n = by_key.get(nk + team, by_name.get(nk, 0))
        first = str(fl_d(pl, "firstName", ""))
        last = str(fl_d(pl, "lastName", ""))
        if first == "" and last == "":
            parts = full.split(" ")
            first = parts[0]
            last = " ".join(parts[1:])
        status = "ON WAIVERS" if str(fl_d(e, "status", "")) == "WAIVERS" else "FREE AGENT"
        bye = on_bye(playing, team) if len(srows) > 0 else False
        out.append(player(first, last, pos, team, proj, season_pts, gp, n,
                          inj_of(fl_d(pl, "injuryStatus", "")), bye, status,
                          str(int(fl_num(fl_d(pl, "id", 0)))), opp.get(team, "")))
    t = {"ok": True, "players": rank(out), "season_known": True, "pos": pos, "mine": None,
         "exact": True, "wv": None}
    if lg["me_matched"]:
        t["mine"] = espn_mine(lg, pos, period, playing)
        t["wv"] = espn_waiver(lg)
    if len(t["players"]) > 0 and t["players"][0]["status"] == "ON WAIVERS":
        espn_cut(lg, t["players"][0], period)
    return t

def espn_mine(lg, pos, period, playing):
    """Your players at the position with this week's projection (+1:
    mRoster for your team only, ~220 KB). None when it can't be read."""
    raw = lg["raw"]
    r = fl_get(lg["budget"], FL_ESPN + str(raw["season"]) + "/segments/0/leagues/" + str(raw["league_id"]) +
               "?view=mRoster&forTeamId=" + str(lg["me"]) + "&scoringPeriodId=" + str(period),
               headers = raw["cookie"], ttl = FL_TTL_ROSTERS)
    if not body_ok(r) or type(r["json"]) != "dict":
        return None
    mine = []
    for tm in fl_d(r["json"], "teams", []):
        if fl_d(tm, "id", None) != lg["me"]:
            continue
        for e in fl_d(fl_d(tm, "roster", {}), "entries", []):
            if int(fl_num(fl_d(e, "lineupSlotId", 20))) == 21:
                continue                     # IR slot
            pl = fl_d(fl_d(e, "playerPoolEntry", {}), "player", {})
            if ESPN_POS.get(int(fl_num(fl_d(pl, "defaultPositionId", 0))), "") != pos:
                continue
            pj = 0.0
            for s in fl_d(pl, "stats", []):
                if (int(fl_num(fl_d(s, "statSourceId", -1))) == 1 and int(fl_num(fl_d(s, "statSplitTypeId", -1))) == 1 and
                    int(fl_num(fl_d(s, "scoringPeriodId", -1))) == period):
                    pj = fl_num(fl_d(s, "appliedTotal", 0))
            team = ESPN_TEAM.get(int(fl_num(fl_d(pl, "proTeamId", 0))), "")
            mine.append([pj, on_bye(playing, team)])
    return mine

def espn_waiver(lg):
    j = lg["raw"]["json"]
    acq = fl_d(fl_d(j, "settings", {}), "acquisitionSettings", {})
    for tm in fl_d(j, "teams", []):
        if fl_d(tm, "id", None) != lg["me"]:
            continue
        left = -1
        if fl_d(acq, "isUsingAcquisitionBudget", False) == True:
            left = int(fl_num(fl_d(acq, "acquisitionBudget", 0))) - int(fl_num(fl_d(fl_d(tm, "transactionCounter", {}), "acquisitionBudgetSpent", 0)))
            if left < 0:
                left = 0
        return {"rank": int(fl_num(fl_d(tm, "waiverRank", 0))), "left": left}
    return None

def espn_cut(lg, top, period):
    """ON WAIVERS on ESPN = dropped in the last day or two: this scoring
    period's and the last one's transactions (~27 KB each) say by whom."""
    raw = lg["raw"]
    for w in [period, period - 1]:
        if w < 1:
            continue
        r = fl_get(lg["budget"], FL_ESPN + str(raw["season"]) + "/segments/0/leagues/" + str(raw["league_id"]) +
                   "?view=mTransactions2&scoringPeriodId=" + str(w), headers = raw["cookie"], ttl = 600)
        if r["status_code"] != 200 or type(r["json"]) != "dict":
            return
        best = -1
        for x in fl_d(r["json"], "transactions", []):
            if str(fl_d(x, "status", "")) != "EXECUTED":
                continue
            for it in fl_d(x, "items", []):
                if str(fl_d(it, "type", "")) == "DROP" and str(int(fl_num(fl_d(it, "playerId", 0)))) == top["id"]:
                    ts = int(fl_num(fl_d(x, "processDate", 0)))
                    if ts > best:
                        best = ts
                        top["cut"] = fl_d(it, "fromTeamId", fl_d(x, "teamId", None))
        if best >= 0:
            return

def name_key(s):
    """'Marvin Harrison Jr.' -> 'MARVINHARRISON' (suffixes dropped)."""
    words = [w for w in str(s).upper().replace(".", " ").split(" ") if w != ""]
    words = [w for w in words if w not in SUFFIX]
    return fl_norm(" ".join(words))

# ------------------------------------------------------------ demo
# Blank league ID: a believable wire for the DEMO league (tagged DEMO).
# [first, last, club, proj, season, gp, adds, injury, bye]
DEMO = {
    "RB": [["RICO", "DOWDLE", "PIT", 12.4, 31.6, 3, 41800, "", False],
           ["TYJAE", "SPEARS", "TEN", 10.9, 24.2, 3, 22600, "QUESTIONABLE", False],
           ["BLAKE", "CORUM", "LAR", 9.8, 21.5, 3, 12900, "", False],
           ["RAY", "DAVIS", "BUF", 8.1, 17.0, 3, 3100, "", False],
           ["ZACH", "CHARBONNET", "SEA", 7.6, 15.2, 3, 2400, "", False],
           ["KENDRE", "MILLER", "NO", 7.1, 12.6, 3, 5100, "", False],
           ["JAYLEN", "WRIGHT", "MIA", 6.4, 9.8, 3, 1800, "", False]],
    "WR": [["RASHID", "SHAHEED", "SEA", 13.1, 38.4, 3, 62400, "", False],
           ["JALEN", "COKER", "CAR", 11.2, 27.9, 3, 18300, "", False],
           ["KEENAN", "ALLEN", "IND", 10.6, 29.1, 3, 7400, "QUESTIONABLE", False],
           ["TRE", "TUCKER", "LV", 9.4, 22.8, 3, 2600, "", False],
           ["JAYDEN", "REED", "GB", 8.9, 19.1, 3, 3300, "", False],
           ["DARIUS", "SLAYTON", "NYG", 8.2, 16.4, 3, 1500, "", False],
           ["KAVONTAE", "TURPIN", "DAL", 7.4, 15.0, 3, 900, "", False]],
    "TE": [["AJ", "BARNER", "SEA", 9.2, 24.4, 3, 28700, "", False],
           ["CADE", "OTTON", "TB", 8.4, 19.8, 3, 9900, "", False],
           ["CHIG", "OKONKWO", "WSH", 7.7, 16.1, 3, 4200, "", False],
           ["GREG", "DULCICH", "MIA", 6.9, 12.3, 3, 1300, "DOUBTFUL", False],
           ["THEO", "JOHNSON", "NYG", 6.5, 13.4, 3, 2100, "", False],
           ["ELIJAH", "ARROYO", "SEA", 6.1, 9.9, 3, 6800, "", False],
           ["MIKE", "GESICKI", "CIN", 5.8, 12.0, 3, 700, "", False]],
    "QB": [["GENO", "SMITH", "NYJ", 18.6, 52.4, 3, 15800, "", False],
           ["AARON", "RODGERS", "PIT", 17.9, 49.7, 3, 9100, "", False],
           ["MARCUS", "MARIOTA", "WSH", 17.1, 41.0, 3, 21400, "", False],
           ["JAMEIS", "WINSTON", "NYG", 16.4, 20.2, 2, 5600, "", False],
           ["BRYCE", "YOUNG", "CAR", 15.9, 44.1, 3, 3800, "", False],
           ["JOE", "FLACCO", "CLE", 15.2, 40.3, 3, 1200, "", False],
           ["SPENCER", "RATTLER", "NO", 14.6, 38.8, 3, 4400, "", False]],
    "K": [["DANIEL", "CARLSON", "LV", 8.9, 24.0, 3, 6700, "", False],
          ["TYLER", "BASS", "BUF", 8.6, 21.0, 3, 4100, "", False],
          ["SPENCER", "SHRADER", "IND", 8.3, 22.0, 3, 2900, "", False],
          ["MATT", "GAY", "WSH", 7.9, 19.0, 3, 1200, "", False],
          ["JASON", "MYERS", "SEA", 7.6, 20.0, 3, 900, "", False],
          ["CHASE", "MCLAUGHLIN", "TB", 7.4, 23.0, 3, 1600, "", False],
          ["JAKE", "ELLIOTT", "PHI", 7.2, 17.0, 3, 500, "", False]],
    "DEF": [["", "", "SF", 8.8, 21.0, 3, 19500, "", False],
            ["", "", "NYG", 8.3, 17.0, 3, 8800, "", False],
            ["", "", "CIN", 7.9, 26.0, 3, 5200, "", False],
            ["", "", "NE", 7.6, 14.0, 3, 1900, "", False],
            ["", "", "CHI", 7.2, 15.0, 3, 1400, "", False],
            ["", "", "TB", 6.9, 12.0, 3, 800, "", False],
            ["", "", "ATL", 6.6, 11.0, 3, 600, "", False]],
}

# This week's opponents for the demo clubs.
DEMO_OPP = {"PIT": "NE", "TEN": "IND", "LAR": "PHI", "BUF": "MIA", "SEA": "NO", "CAR": "ATL",
            "IND": "TEN", "LV": "WSH", "TB": "NYJ", "WSH": "LV", "MIA": "BUF", "NYJ": "TB",
            "NYG": "KC", "SF": "ARI", "CIN": "MIN", "NE": "PIT", "NO": "SEA", "CHI": "DAL",
            "DAL": "CHI", "GB": "CLE", "CLE": "GB", "PHI": "LAR", "ATL": "CAR"}
# BLITZ BRIGADE (the demo "you"): this week's projection of your players
# at each position, and your waiver standing.
DEMO_MINE = {"RB": [16.2, 11.8, 7.4, 3.9], "WR": [17.5, 12.0, 10.2, 8.8, 6.1], "TE": [8.1],
             "QB": [22.4, 15.0], "K": [], "DEF": [9.6]}
DEMO_WAIVER = {"rank": 7, "left": 73}

def demo_targets(lg, pos):
    out = []
    for d in DEMO[pos]:
        out.append(player(d[0], d[1], pos, d[2], d[3], d[4], d[5], d[6], d[7], d[8], "UNROSTERED",
                          "", DEMO_OPP.get(d[2], "")))
    ps = rank(out)
    if pos == "RB":
        ps[0]["status"] = "ON WAIVERS"
        ps[0]["cut"] = 2                     # TD TSUNAMI let him go
    mine = None
    wv = None
    if lg["me_matched"]:
        mine = [[v, False] for v in DEMO_MINE[pos]]
        wv = DEMO_WAIVER
    return {"ok": True, "players": ps, "season_known": True, "pos": pos, "mine": mine,
            "exact": True, "wv": wv}

# ------------------------------------------------------------ load
def gather(ctx):
    """[league, targets, position, rotating]"""
    pp = pos_for(ctx)
    pos = pp[0]
    # Waivers never read scores: matchups = False saves Sleeper a call,
    # which the cut-by lookup spends.
    lg = fl_load(ctx, matchups = False)
    if not lg["ok"]:
        return [lg, None, pos, pp[1]]
    if lg["state"] == "predraft":
        return [lg, None, pos, pp[1]]
    if lg["state"] == "demo":
        return [lg, demo_targets(lg, pos), pos, pp[1]]
    if lg["platform"] == "SLEEPER":
        t = sleeper_targets(ctx, lg, pos, pp[1])
        return [lg, t, t.get("pos", pos), pp[1]]
    if not espn_plays(lg, pos):
        if not pp[1]:
            return [lg, {"ok": False, "err": [NOT_PLAYED[pos], "PICK ANOTHER POSITION IN SETTINGS"]}, pos, False]
        pos = next_skill(ctx)
    return [lg, espn_targets(ctx, lg, pos), pos, pp[1]]

# ------------------------------------------------------------ the wire
# Two wooden poles just inside the safe zone (x 6-7 and 184-185, crossarms
# reaching inward, glass insulators) carry a telephone wire that sags 2 px
# to the middle. Everything hangs from it on clothespins, between x 9 and
# 182; nothing is lit outside x 6..185.
POLE = "#8B5A2B"
POLE_HI = "#C28246"
INSUL = "#5FD3C4"
WIRE = "#7C8799"
CARD = "#141B29"       # a player card's face
EDGE = "#4A5673"       # a player card's frame
GOLD = "#FFC83D"       # the #1 card's frame
PIN_LEG = {"W": "#E6B873", "D": "#8A5A28", "S": "#C9D1DC"}
BROWN = "#6B4A16"      # quiet type on manila

PL = 6      # left pole (6..7)
PR = 184    # right pole (184..185)
SAG = 2

# A clothespin seen from the front: two prongs and the spring.
PIN = """
WDW
WDW
SSS
WDW
WDW
"""

# A small flame for the cards (5 x 5).
MINI_FLAME = """
..R..
.RYR.
RYYYR
RYWYR
.RYR.
"""

def wire_y(x):
    t = (x - 95.5) / 85.0
    return 1 + int(SAG * (1 - t * t) + 0.5)

def draw_wire(c):
    c.fill("black")
    for px in [PL, PR]:
        c.rect(px, 1, px + 1, 31, fill = POLE)
        c.rect(px, 1, px, 31, fill = POLE_HI)
    # crossarms reach inward; the wire runs insulator to insulator
    c.rect(PL, 3, PL + 4, 3, fill = POLE)
    c.rect(PR - 3, 3, PR + 1, 3, fill = POLE)
    c.pixel(PL + 4, 2, INSUL)
    c.pixel(PR - 3, 2, INSUL)
    for x in range(PL + 5, PR - 3):
        c.pixel(x, wire_y(x), WIRE)

def pin(c, x, bottom):
    """A clothespin whose lower end bites the card's top edge at `bottom`."""
    c.sprite(PIN, x, bottom - 4, legend = PIN_LEG)

def frame(c, x0, y0, x1, edge, face):
    """A card hanging from y0 down to the panel's bottom row."""
    c.rect(x0, y0, x1, 31, fill = edge)
    c.rect(x0 + 1, y0 + 1, x1 - 1, 30, fill = face)

# ------------------------------------------------------------ screens
def card(c, head, sub, edge, head_color):
    """State screens: one wide sign pinned to the wire."""
    draw_wire(c)
    x0 = 22
    x1 = 169
    frame(c, x0, 6, x1, edge, CARD)
    pin(c, x0 + 10, 6)
    pin(c, x1 - 12, 6)
    h = fit(c, head, ["6x8", "5x7", "4x5"], x1 - x0 - 8)
    c.text(h[0], 96, 11 if h[1] == "6x8" else 12, font = h[1], color = head_color, align = "center")
    s = fit(c, sub, ["4x5", "picopixel"], x1 - x0 - 8)
    c.text(s[0], 96, 23, font = s[1], color = DIM, align = "center")

def state_screen(c, got):
    lg = got[0]
    t = got[1]
    if not lg["ok"]:
        card(c, lg["err"][0], lg["err"][1], AMBER, AMBER)
        return True
    if lg["state"] == "predraft":
        card(c, "DRAFT DAY AHEAD", "EVERYONE'S AVAILABLE UNTIL YOUR DRAFT", GOOD, GOOD)
        return True
    if not t["ok"]:
        card(c, t["err"][0], t["err"][1], AMBER, AMBER)
        return True
    if len(t["players"]) == 0:
        card(c, "WIRE IS PICKED CLEAN", "NO " + got[2] + " WORTH ADDING IS UNROSTERED", GOOD, GOOD)
        return True
    return False

# ------------------------------------------------------------ your need
def gain_fmt(x):
    return fl_fmt1(x) if x < 9.95 else str(int(x + 0.5))

def need_of(t, p):
    """What the #1 target means for YOUR team (team input matched):
    [text, fill] - RB3 +2.9 (he'd be your RB3, 2.9 over your weakest RB
    with a game), NEED K (you have none), NO GAIN. None = unmatched."""
    mine = t.get("mine", None)
    if mine == None:
        return None
    pos = p["pos"]
    if len(mine) == 0:
        return ["NEED " + pos, AMBER]
    live = [m[0] for m in mine if not m[1]]
    weakest = min(live) if len(live) > 0 else 0.0
    gain = p["proj"] - weakest
    if p["bye"] or gain < 0.05:
        return ["NO GAIN", None]
    slot = 1 + len([v for v in live if v > p["proj"]])
    return [pos + str(slot) + " +" + gain_fmt(gain), GOOD]

# ------------------------------------------------------------ cards
def small_card(c, p, rank, x, w, y):
    """A player card on a clothespin pair: 24 x 18 club logo, #rank in the
    position colour, this week's projection, a small flame for a hot add,
    the surname along the bottom."""
    frame(c, x, y, x + w - 1, EDGE, CARD)
    pin(c, x + 4, y)
    pin(c, x + w - 7, y)
    c.image(SMALL[p["team"]], x + 2, y + 1)
    rc = x + 27
    rr = x + w - 3                   # last text column
    rk = "#" + str(rank)
    c.text(rk, rc, y + 2, font = "4x5", color = POS_COLOR[p["pos"]])
    v = "BYE" if p["bye"] else fl_fmt1(p["proj"])
    if c.text_width(v, "4x5") > rr - rc + 1:
        v = str(int(p["proj"] + 0.5))    # 20.4 -> 20 on a narrow card
    vf = fit(c, v, ["4x5", "3x4"], rr - rc + 1)
    c.text(vf[0], rc, y + 8, font = vf[1], color = DIM if p["bye"] else INK)
    # third line: an injury code, then the flame if there is room
    fx = rc
    if p["inj"] != "":
        tg = INJ[p["inj"]]
        c.text(tg[0], rc, y + 14, font = "4x5", color = tg[1])
        fx = rc + c.text_width(tg[0], "4x5") + 2
    if p["adds"] >= 500 and fx + 5 <= rr + 1:
        c.sprite(MINI_FLAME, fx, y + 14, legend = FLAME_LEG)
    nm = surname(c, p["last"], ["4x5", "3x4"], w - 4)
    c.text(nm[0], x + 2, y + 19, font = nm[1], color = INK)

def mini_tag(c, x0, x1, y0, y1):
    """The claim tag, small: manila, point to the left, a punched hole."""
    mid = (y0 + y1) // 2
    for r in range(y0, y1 + 1):
        d = r - y0 if r - y0 < y1 - r else y1 - r
        inset = 3 - d if d < 3 else 0
        c.rect(x0 + inset, r, x1, r, fill = PAPER)
    c.rect(x1, y0, x1, y1, fill = PAPER_EDGE)
    c.rect(x0 + 1, mid - 1, x0 + 3, mid + 1, fill = PAPER_EDGE)
    c.pixel(x0 + 2, mid, "black")

def tag_lines(c, need, p, t, lg, cx):
    """Two lines on the claim tag: your need (WR2 / +7.0 on a green stamp,
    NEED / K on amber, NO / GAIN), else season points (SZN / 38)."""
    l1 = ""
    l2 = ""
    fill = None
    if need != None:
        parts = need[0].split(" ")
        l1 = parts[0]
        l2 = " ".join(parts[1:])
        fill = need[1]
    elif t["season_known"] and p["season"] > 0:
        l1 = "SZN"
        l2 = str(int(p["season"] + 0.5))
    elif p["bye"]:
        l1 = "WK"
        l2 = str(lg["week"])
    else:
        l1 = "NEW"
    c.text(fit(c, l1, ["4x5", "3x4"], 19)[0], cx, 13, font = "4x5", color = STAMP if fill != None else BROWN, align = "center")
    if l2 == "":
        return
    s = fit(c, l2, ["4x5", "3x4"], 19)
    if fill != None:
        w = c.text_width(s[0], s[1]) + 4
        x0 = cx - w // 2
        c.rect(x0, 18, x0 + w - 1, 24, fill = fill)
        c.text(s[0], x0 + 2, 19, font = s[1], color = "black")
    else:
        c.text(s[0], cx, 19, font = s[1], color = STAMP, align = "center")

def top_row(c, lg, p, x, rx, y):
    """Position, then who cut him / ON WAIVERS / BYE / the opponent, and an
    injury code at the right - whatever fits between x and rx."""
    pc = POS_COLOR[p["pos"]]
    c.text(p["pos"], x, y, font = "4x5", color = pc)
    x += c.text_width(p["pos"], "4x5") + 4
    if p["inj"] != "":
        tg = INJ[p["inj"]]
        c.text(tg[0], rx, y, font = "4x5", color = tg[1], align = "right")
        rx -= c.text_width(tg[0], "4x5") + 3
    cut = fl_team(lg, p["cut"]) if p["cut"] != None else None
    if cut != None:
        mono = fl_monogram(cut)
        if x + c.text_width("CUT " + mono, "4x5") <= rx + 1:
            c.text("CUT", x, y, font = "4x5", color = AMBER)
            c.text(mono, x + c.text_width("CUT ", "4x5"), y, font = "4x5", color = fl_badge_color(cut))
            return
    choices = []
    if p["status"] == "ON WAIVERS":
        choices = [["WAIVERS", AMBER], ["WAIV", AMBER]]
    elif p["bye"]:
        choices = [["ON BYE", "#8A93A6"], ["BYE", "#8A93A6"]]
    elif p["opp"] != "":
        choices = [["VS " + p["opp"], FIRST], [p["opp"], FIRST]]
    for ch in choices:
        if x + c.text_width(ch[0], "4x5") <= rx + 1:
            c.text(ch[0], x, y, font = "4x5", color = ch[1])
            return

# ------------------------------------------------------------ page 1
HERO_X = 55     # the #1 card: 55..136, frame from y 4
HERO_W = 82
SIDE_W = 44     # #2 at 9..52, #3 at 139..182, frames from y 6

def target(c, ctx):
    got = gather(ctx)
    if state_screen(c, got):
        return
    lg = got[0]
    t = got[1]
    ps = t["players"]
    p = ps[0]
    demo = lg["state"] == "demo"
    need = need_of(t, p)
    draw_wire(c)

    # the runners-up hang either side, a little lower
    if len(ps) > 1:
        small_card(c, ps[1], 2, 9, SIDE_W, 6)
    if len(ps) > 2:
        small_card(c, ps[2], 3, 139, SIDE_W, 6)

    # the #1 card: bigger, gold, in the middle
    x = HERO_X
    x1 = HERO_X + HERO_W - 1
    frame(c, x, 4, x1, GOLD, CARD)
    pin(c, x + 10, 4)
    pin(c, x1 - 12, 4)
    c.image(SMALL[p["team"]], x + 2, 5)
    top_row(c, lg, p, x + 28, x1 - 2, 6)
    v = "BYE" if p["bye"] else fl_fmt1(p["proj"])
    vf = fit(c, v, ["7x12", "5x7", "4x5"], 26)
    c.text(vf[0], x + 28, {"7x12": 12, "5x7": 14, "4x5": 15}[vf[1]], font = vf[1],
           color = DIM if p["bye"] else INK)

    # the claim tag, small, beside the projection
    tx0 = x + 55
    mini_tag(c, tx0, x1 - 2, 12, 24)
    tag_lines(c, need, p, t, lg, (tx0 + 4 + x1 - 2) // 2)

    # surname along the bottom; a hot add's flame under the tag
    nm = surname(c, p["last"], ["5x7", "4x5"], 52)
    c.text(nm[0], x + 2, 24 if nm[1] == "5x7" else 25, font = nm[1], color = INK)
    if demo:
        c.text("DEMO", tx0 + 2, 26, font = "4x5", color = AMBER)
    elif p["adds"] >= 500:
        c.sprite(MINI_FLAME, tx0 + 1, 26, legend = FLAME_LEG)
        k = fit(c, kfmt(p["adds"]), ["4x5", "3x4"], x1 - 2 - (tx0 + 7) + 1)
        c.text(k[0], tx0 + 7, 26, font = k[1], color = HOT)

# ------------------------------------------------------------ page 2
SLOTS = [9, 73, 139]   # three cards on the wire, 44 wide, 20 and 22 px apart
CARD2_W = 44

def your_card(c, lg, t, x):
    """Your claim ticket in manila: your crest, your waiver order, FAAB
    left (else your team's name)."""
    me = fl_team(lg, lg["me"])
    if me == None:
        return
    w = CARD2_W
    frame(c, x, 6, x + w - 1, PAPER_EDGE, PAPER)
    pin(c, x + 4, 6)
    pin(c, x + w - 7, 6)
    fl_badge(c, me, x + 2, 8, 16)
    wv = t.get("wv", None)
    rk = wv["rank"] if wv != None else 0
    left = wv["left"] if wv != None else -1
    rc = x + 20
    if rk > 0:
        c.text("WAIV", rc, 8, font = "4x5", color = BROWN)
        r = fit(c, "#" + str(rk), ["6x8", "5x7", "4x5"], w - 22)
        c.text(r[0], rc, 15, font = r[1], color = STAMP)
    else:
        c.text("YOU", rc, 8, font = "4x5", color = BROWN)
    if left >= 0:
        s1 = "$" + str(left) + " LEFT"
        if c.text_width(s1, "4x5") > w - 4:
            s1 = "$" + str(left)
        c.text(fit(c, s1, ["4x5", "3x4"], w - 4)[0], x + 2, 25, font = "4x5", color = STAMP)
        return
    words = me["name"].split(" ")
    nm = ""
    for k in range(len(words), 0, -1):
        s1 = " ".join(words[:k]).rstrip(" .,-&")
        if k < len(words) and words[k - 1] in ["AND", "THE", "OF", "A", "&", "N"]:
            continue
        if c.text_width(s1, "4x5") <= w - 4:
            nm = s1
            break
    if nm == "":
        nm = fit(c, me["name"], ["4x5"], w - 4)[0]
    c.text(nm, x + 2, 25, font = "4x5", color = STAMP)

def wire(c, ctx):
    got = gather(ctx)
    if state_screen(c, got):
        return
    lg = got[0]
    t = got[1]
    ps = t["players"]
    demo = lg["state"] == "demo"
    mine = t.get("mine", None) != None and fl_team(lg, lg["me"]) != None
    base = 3
    show = ps[3:6]
    if len(show) == 0:
        base = 1 if len(ps) > 1 else 0
        show = ps[base:3]
    if mine:
        show = show[:2]
    draw_wire(c)
    for i in range(len(show)):
        small_card(c, show[i], base + i + 1, SLOTS[i], CARD2_W, 6)
    if mine:
        your_card(c, lg, t, SLOTS[2])
    # between the cards: the position (and ALL when it rotates), DEMO
    pos = got[2]
    g1 = (SLOTS[0] + CARD2_W + SLOTS[1]) // 2
    g2 = (SLOTS[1] + CARD2_W + SLOTS[2]) // 2
    c.text(pos, g1, 12, font = "5x7", color = POS_COLOR.get(pos, INK), align = "center")
    if got[3]:
        c.text("ALL", g1, 22, font = "4x5", color = DIM, align = "center")
    if demo:
        c.text("DEMO", g2, 22, font = "4x5", color = AMBER, align = "center")
