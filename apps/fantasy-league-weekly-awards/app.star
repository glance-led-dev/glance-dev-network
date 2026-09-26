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
# WEEKLY AWARDS
#
# DESIGN. The league's trophy case for the week just played, in three
# pages. Each page is a slot at the banquet and hands out one award per
# render; the award rotates every refresh (5 minutes), so a slot shows its
# other awards on the panel's next passes. If the viewer's team takes one
# of a slot's awards, that frame comes first (the rotation is anchored to
# Tuesday 06:00 ET, when the week's awards land).
#
#   podium   TOP SCORER (gold cup) <-> PLAYER OF THE WEEK (his NFL club
#            logo, 40 x 24 at native size, position chip, the fantasy team
#            that started him). Page 1, so the thumbnail is the gold cup.
#   games    CLOSEST GAME (stopwatch) <-> UNLUCKIEST (storm cloud: the
#            highest score that still lost) <-> BIGGEST BLOWOUT (starburst).
#            A game frame shows the winner's crest and name, the loser under
#            it in its colour, the margin as the hero and the final score.
#   shame    LOWEST SCORE (pixel toilet) <-> LEFT ON BENCH (sideline bench
#            with a helmet: best possible lineup minus the one started).
#
# Every frame: the award's pixel art in the art column, the winning team's
# crest (the adapter's fl_badge) and name in the team colour, the number
# that won it as the hero on the right. A white YOU pill in the title row
# when the viewer's team is in it. Under that, the YOUR WEEK strip - "YOU
# 4TH OF 10  123.0 [W]" - so every frame says how the viewer's own week
# went (shown when the team input matched a team). ESPN leagues add the
# season trophy shelf under the gold cup: one small cup per week the
# winner has been top scorer this season, and SEASON HIGH / SEASON LOW
# when this week beat every earlier week.
#
# Guillotine leagues (Sleeper) have no games: games = STILL STANDING
# (every team that played, best first, the cut crossed out; 11+ teams as
# two rows of small monogram crests with the cut score in red, the
# viewer's crest rimmed in white) <-> CLOSE SHAVE (grimace: who survived
# the blade by the least); shame = CHOPPED (guillotine) <-> BENCH.
#
# Names: the whole team name in 5x7, then 4x5, then the manager's name,
# then leading words that don't end on THE / OF / A ..., then the abbrev.
#
# WEEK. The most recent completed fantasy week: ESPN's current matchup
# period once every game in it is decided, else the one before; Sleeper's
# week before the calendar week (a week is done on Tuesday morning, after
# Monday night). In week 1, before any week is complete, the pages show
# week 1 so far, labelled SO FAR.
#
# DATA. The shared fantasy-league adapter v2 (block above) plus:
#   ESPN     the adapter's one call already holds every week's scores (the
#            awards, the season shelf); PLAYER and BENCH add one mBoxscore
#            call for the week's scoring period, schedule filtered to that
#            week by an x-fantasy-filter header (0.2-0.8 MB). The bench is
#            the best legal lineup from each player's eligibleSlots and the
#            league's lineupSlotCounts, narrowest slots first.
#   Sleeper  the week's scores come from the adapter (this week's matchups,
#            or lg["last"] in the Tue-Thu gap - no extra call); otherwise
#            one matchups/<week> call. PLAYER adds that call's lineups and
#            players/<id> (~1 KB); BENCH adds the league's roster_positions
#            (carried by the adapter, no call) and the week's stats for
#            player positions (two groups, 0.42 +
#            0.31 MB, or one 0.6-0.73 MB call when the budget is tight).
#            IDP slots keep their starters.
# At most 8 calls on any page. Refresh 300: the league and team inputs are
# free text.
# ======================================================================

INK = "#F4F7FF"
DIM = "#6E7A94"
SLATE = "#8B93A7"
AMBER = "#FFBF00"
ALARM = "#FF3B30"
GOOD = "#2FE06F"
OFFLINE = "#3C4043"

GOLD = "#FFC83D"
SILVER = "#C9D3E0"
BOOM = "#FF7A1A"
SKY = "#2DB8FF"
STORM = "#A77CFF"
MUD = "#D9975A"
TEAL = "#2DD4C8"

L = 6
R = 185
TX = 38             # text column starts here (the art column is x 6..33)

AWARD = {
    "top": ["TOP SCORER", GOLD, "TOP SCORE"],
    "blowout": ["BIGGEST BLOWOUT", BOOM, "BLOWOUT"],
    "closest": ["CLOSEST GAME", SKY, "CLOSEST"],
    "unlucky": ["UNLUCKIEST", STORM, "UNLUCKY"],
    "lowest": ["LOWEST SCORE", MUD, "LOW SCORE"],
    "bench": ["LEFT ON BENCH", TEAL, "BENCH"],
    "player": ["PLAYER OF THE WEEK", GOLD, "TOP PLAYER"],
    "standing": ["STILL STANDING", GOOD, "STANDING"],
    "shave": ["CLOSE SHAVE", SKY, "SHAVE"],
    "chopped": ["CHOPPED", ALARM, "CHOPPED"],
}

# The three slots. Guillotine leagues swap the game awards.
SLOTS = {
    "h2h": {"podium": ["top", "player"], "games": ["closest", "unlucky", "blowout"],
            "shame": ["lowest", "bench"]},
    "guillotine": {"podium": ["top", "player"], "games": ["standing", "shave"],
                   "shame": ["chopped", "bench"]},
}
FRAME_T0 = 1788256800      # Tue 2026-09-01 10:00 UTC (06:00 ET): awards land
FRAME_SECS = 300           # one award per refresh

# NFL club logos, 40 x 24, drawn at native size.
LOGOS = {
    "ARI": "ARI.png", "ATL": "ATL.png", "BAL": "BAL.png", "BUF": "BUF.png",
    "CAR": "CAR.png", "CHI": "CHI.png", "CIN": "CIN.png", "CLE": "CLE.png",
    "DAL": "DAL.png", "DEN": "DEN.png", "DET": "DET.png", "GB": "GB.png",
    "HOU": "HOU.png", "IND": "IND.png", "JAX": "JAX.png", "KC": "KC.png",
    "LAC": "LAC.png", "LAR": "LAR.png", "LV": "LV.png", "MIA": "MIA.png",
    "MIN": "MIN.png", "NE": "NE.png", "NO": "NO.png", "NYG": "NYG.png",
    "NYJ": "NYJ.png", "PHI": "PHI.png", "PIT": "PIT.png", "SEA": "SEA.png",
    "SF": "SF.png", "TB": "TB.png", "TEN": "TEN.png", "WSH": "WSH.png",
    "NFL": "NFL.png",
}

# Sleeper spells a few clubs differently from the logo set.
CLUB_FIX = {"WAS": "WSH", "JAC": "JAX", "LA": "LAR", "OAK": "LV", "SD": "LAC", "STL": "LAR"}

# ESPN proTeamId -> club (stable ids).
ESPN_PRO = {1: "ATL", 2: "BUF", 3: "CHI", 4: "CIN", 5: "CLE", 6: "DAL", 7: "DEN", 8: "DET",
            9: "GB", 10: "TEN", 11: "IND", 12: "KC", 13: "LV", 14: "LAR", 15: "MIA", 16: "MIN",
            17: "NE", 18: "NO", 19: "NYG", 20: "NYJ", 21: "PHI", 22: "ARI", 23: "PIT", 24: "LAC",
            25: "SF", 26: "SEA", 27: "TB", 28: "WSH", 29: "CAR", 30: "JAX", 33: "BAL", 34: "HOU"}
# ESPN player defaultPositionId (not the lineup-slot ids: slot 8 DT, 9 DE,
# 10 LB, 11 DL, 14 DB, 15 DP, 24 ER are slots).
ESPN_POS = {1: "QB", 2: "RB", 3: "WR", 4: "TE", 5: "K", 7: "P", 16: "DEF",
            9: "DT", 10: "DE", 11: "LB", 12: "CB", 13: "S", 14: "HC"}
ESPN_NOT_STARTING = [20, 21]       # bench, IR (slot 24 is ER, a real IDP starter)

# Words a shortened team name must not end on.
NAME_STOP = ["THE", "IN", "OF", "A", "AN", "AND", "&", "TO", "FOR", "ON", "AT", "MY", "YOUR",
             "DA", "LA", "EL", "LE", "DE", "DEL", "WITH", "IS", "-", "+"]

# ------------------------------------------------------------ pixel art
# Gold cup, 22 x 21: handles, a highlight down the bowl, a star, a
# two-step plinth with a plate.
CUP = """
..DGGGGGGGGGGGGGGGGD..
DDDGLLGGGGGGGGGGGGGDDD
D.DGLLGGGGGWGGGGGGGD.D
D.DGLLGGGGWWWGGGGGGD.D
D..DGLGGGWWWWWGGGGD..D
.D.DGLGGGGWWWGGGGGD.D.
..DDGGGGGWGGGWGGGGDD..
....DGGGGGGGGGGGGD....
.....DGGGGGGGGGGD.....
......DDGGGGGGDD......
........DGGGGD........
.........DGGD.........
.........DGGD.........
........DGGGGD........
.......DGGGGGGD.......
......DDDDDDDDDD......
.....BBBBBBBBBBBB.....
.....BPPPPPPPPPPB.....
.....BPPPPPPPPPPB.....
.....BBBBBBBBBBBB.....
....BBBBBBBBBBBBBB....
"""
CUP_GOLD = {"G": "#FFC83D", "L": "#FFF1A8", "D": "#A8740A", "W": "#FFFFFF", "B": "#5A3A1E", "P": "#C9A04A"}
CUP_SILVER = {"G": "#B8C2D0", "L": "#FFFFFF", "D": "#5E6878", "W": "#FFFFFF", "B": "#3A3F4A", "P": "#8C96A6"}

# Blowout starburst, 22 x 21.
BURST = """
..........R...........
...R......RR......R...
...RR....ROR.....RR...
....RRR.ROOR...RRR....
....ROORROOORRROOR....
.....ROOOOYOOOOOR.....
.RRRROOYYYYYYYOORRRR..
..RROOYYWWWWWYYOOR....
....ROYYWWWWWWYYOR....
RRRROOYWWWWWWWWYOORRRR
...ROOYWWWWWWWWYYOR...
....ROYYWWWWWWYYOR....
..RROOYYYWWWWYYYOORR..
.RRRROOYYYYYYYOORRRRR.
.....ROOOOYOOOOOR.....
....ROORRROOORROOR....
....RRR..ROOR..RRR....
...RR.....OR.....RR...
...R......RR......R...
..........R...........
"""
BURST_LEG = {"R": "#E0301E", "O": "#FF7A1A", "Y": "#FFD23F", "W": "#FFF6D0"}

# Stopwatch, 20 x 22: crown and button, sky-blue case, white face, the red
# hand a hair short of twelve.
WATCH = """
........KKKK........
........KBBK........
.........KK.......K.
.....KKKKKKKKKK..KBK
...KKSSSSSSSSSSKKKK.
..KSSWWWWWWWWWWSSK..
.KSWWWWWWDWWWWWWWSK.
.KSWDWWWWRWWWWWDWSK.
KSWWWWWWWRWWWWWWWWSK
KSWWWWWWWRWWWWWWWWSK
KSWDWWWWWRWWWWWWDWSK
KSWWWWWWWKWWWWWWWWSK
KSWWWWWWWWWWWWWWWWSK
KSWWWWWWWWWWWWWWWWSK
.KSWDWWWWWWWWWWDWSK.
.KSWWWWWWWWWWWWWWSK.
..KSSWWWWWDWWWWSSK..
...KKSSSSSSSSSSKK...
.....KKKKKKKKKK.....
"""
WATCH_LEG = {"K": "#1F6FA8", "B": "#9BD9FF", "S": "#2DB8FF", "W": "#FFFFFF", "D": "#5E6878", "R": "#FF3B30"}

# Storm cloud, 24 x 22: a grey cloud, purple rain and a yellow bolt.
STORMCLOUD = """
.........HHHHH..........
.......HHCCCCCHH........
......HCCCCCCCCCH.HHH...
...HHHCCCCCCCCCCHHCCCH..
..HCCCCCCCCCCCCCCCCCCCH.
.HCCCCCCCCCCCCCCCCCCCCCH
.HCCCCCCCCCCCCCCCCCCCCCH
HCCCCCCCCCCCCCCCCCCCCCCH
HDDDDDDDDDDDDDDDDDDDDDDH
.HHHHHHHHHYYYHHHHHHHHHH.
..........YYY...........
..P...P..YYY...P....P...
..P...P..YYYYYY.P...P...
.P...P.....YYY..P..P....
.P...P....YYY..P...P....
.........YY....P........
....P...YY...P.....P....
....P...Y....P....P.....
...P.........P....P.....
...P....................
"""
STORM_LEG = {"H": "#5E6878", "C": "#9AA3B2", "D": "#6E7A94", "Y": "#FFD23F", "P": "#A77CFF"}

# Toilet, 20 x 22: tank with a flush handle, lid, bowl, pedestal. Plain
# porcelain - the award is the joke, the art stays polite.
TOILET = """
.KKKKKKKKKKK........
.KWWWWWWWWWK........
.KWWWWWWWWWKHH......
.KWWWWWWWWWK........
.KWWWWWWWWWK........
.KWWWWWWWWWK........
.KSWWWWWWWSK........
.KKKKKKKKKKK........
..KWWWWWWWKKKKKKKKK.
..KWWWWWWWWWWWWWWWWK
..KSSSSSSSSSSSSSSSSK
..KKKKKKKKKKKKKKKKKK
...KWWWWWWWWWWWWWWK.
....KWWWWWWWWWWWWK..
.....KWWWWWWWWWWK...
......KWWWWWWWSK....
.......KWWWWWWK.....
.......KWWWWWWK.....
......KWWWWWWWWK....
......KKKKKKKKKK....
"""
TOILET_LEG = {"K": "#6E7A94", "W": "#F4F7FF", "S": "#C9D3E0", "H": "#D9975A"}


# Sideline bench with a helmet left on it, 24 x 18: a white stripe round
# the crown, ear hole, and a two-bar facemask on the front.
BENCHART = """
.....XXXXXX.............
...XXXXXXXXXX...........
..WWWWWWWWWWWW..........
.XXXXXXXXXXXXXX.........
.XXXKKXXXXXXXXX.........
.XXXKKXXXXXXXXDMMMMM....
.XXXXXXXXXXXXD.....M....
..XXXXXXXXXXXDMMMMMM....
...XXXXXXXXX...M........
BBBBBBBBBBBBBBBBBBBBBBBB
TTTTTTTTTTTTTTTTTTTTTTTT
BBBBBBBBBBBBBBBBBBBBBBBB
..LL................LL..
..LL................LL..
..LL................LL..
..LL................LL..
.LLLL..............LLLL.
"""
BENCH_LEG = {"K": "#0E4F4A", "X": "#2DD4C8", "D": "#178C84", "W": "#F4F7FF", "M": "#C9D3E0",
             "B": "#8A5A2B", "T": "#A86F38", "L": "#5E6878"}

# 7 x 6 cup for the season trophy shelf.
MINICUP = """
.GGGGG.
GGLGGGG
.GLGGG.
..GGG..
...G...
..DDD..
"""
MINICUP_LEG = {"G": "#FFC83D", "L": "#FFF1A8", "D": "#A8740A"}

# Guillotine, 20 x 24.
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

# Grimace with a bead of sweat for the close shave, 20 x 19.
GRIMACE = """
......YYYYYYYY......
....YYYYYYYYYYYY....
...YYYYYYYYYYYYYY...
..YYYYYYYYYYYYYYYY.B
.YYYYKKYYYYYKKYYYYBB
.YYYYKKYYYYYKKYYYBBB
YYYYYYYYYYYYYYYYYYBB
YYYYYYYYYYYYYYYYYYYY
YYYYYYYYYYYYYYYYYYYY
YYYKKKKKKKKKKKKKKYYY
YYYKWKWKWKWKWKWKKYYY
YYYKKKKKKKKKKKKKKYYY
YYYKWKWKWKWKWKWKKYYY
.YYKKKKKKKKKKKKKKYY.
.YYYYYYYYYYYYYYYYYY.
..YYYYYYYYYYYYYYYY..
...YYYYYYYYYYYYYY...
....YYYYYYYYYYYY....
......YYYYYYYY......
"""
GRIMACE_LEG = {"Y": "#FFD23F", "K": "#4A3500", "W": "#FFFFFF", "B": "#2DB8FF"}

# 7 x 7 crossed-out mark for the cut crest.
XMARK = """
X.....X
.X...X.
..X.X..
...X...
..X.X..
.X...X.
X.....X
"""


# ------------------------------------------------------------ helpers
def fmt1(x):
    """fl_fmt1 with a nudge: 54.15 is 54.1499999 in binary floating point."""
    return fl_fmt1(x + 0.000001 if x >= 0 else x - 0.000001)

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

def name_fit(c, lg, t, maxw, fonts = ["5x7", "4x5"]):
    """A team's name in maxw: the whole name in the biggest font that takes
    it; else the manager's name; else leading words that don't end on a
    small word (THE, OF ...) and aren't the start of another team's name;
    else the abbreviation."""
    own = fl_clean(t.get("owner", ""))
    name = tname(lg, t["id"])
    for f in fonts:
        if c.text_width(name, f) <= maxw:
            return [name, f]
    if own != "" and fl_norm(own) != fl_norm(name):
        for f in fonts:
            if c.text_width(own, f) <= maxw:
                return [own, f]
    others = [fl_norm(x["name"]) for x in lg["teams"] if x["id"] != t["id"]]
    words = name.split(" ")
    for k in range(len(words) - 1, 0, -1):
        part = " ".join(words[:k]).rstrip(" .-&,+/")
        tail = fl_norm(words[k - 1])
        pn = fl_norm(part)
        if tail == "" or tail in NAME_STOP or len(pn) < 4:
            continue
        if len([o for o in others if o.startswith(pn)]) > 0:
            continue
        for f in fonts:
            if c.text_width(part, f) <= maxw:
                return [part, f]
    return fit(c, t["abbrev"] if fl_norm(t["abbrev"]) != "" else name, fonts, maxw)

def tname(lg, tid):
    """A team's full display name (an emoji-only name falls back to the
    manager, then TEAM <id>)."""
    t = fl_team(lg, tid)
    if fl_norm(t["name"]) != "":
        return t["name"]
    own = fl_clean(t.get("owner", ""))
    return own if fl_norm(own) != "" else "TEAM " + str(tid)

def ordinal(n):
    tail = "TH"
    if n % 100 < 11 or n % 100 > 13:
        tail = {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")
    return str(n) + tail

def et_now(ctx):
    """[weekday (0 = Monday), hour] in US Eastern (EDT, UTC-4)."""
    u = ctx.now.unix - 4 * 3600
    return [((u // 86400) + 3) % 7, (u % 86400) // 3600]

def cut_of(lg, tid):
    """Guillotine: the week a team was cut (0 = alive)."""
    return int(fl_num(fl_d(lg["scores"].get(tid, None), "cut", 0)))

# ------------------------------------------------------------ the week
def week_data(ctx, lg):
    """The awards week, normalised across platforms:
    {week, sofar, fmt, rows: [[id, pts]] (teams that played), pairs:
    [[winner id, loser id, winner pts, loser pts]], cut (guillotine: ids
    cut this week), left (guillotine: teams still standing), tally (ESPN
    season shelf), err (card text or None)}. Lineups (`src` Sleeper, `box`
    ESPN) are fetched later, only by the frames that need them."""
    fmt = lg.get("format", "h2h")
    out = {"week": 0, "sofar": False, "fmt": fmt, "rows": [], "pairs": [], "err": None,
           "src": None, "src_tried": False, "box": None, "box_tried": False, "sp": [],
           "tally": None, "cut": [], "left": -1}
    if lg["platform"] == "SLEEPER":
        cal = fl_nfl_week(ctx)
        et = et_now(ctx)
        # The week is over on Tuesday morning (Monday night is done); the
        # calendar week itself turns over on Wednesday.
        done = cal if (et[0] == 1 and et[1] >= 6) else cal - 1
        w = done if done <= lg["week"] else lg["week"]
        if w < 1:
            w = lg["week"]
            out["sofar"] = True
        out["week"] = w
        last = lg.get("last", None)
        if w == lg["week"] and len(lg["raw"]["matchups"]) > 0:
            out["src"] = lg["raw"]["matchups"]
            out["src_tried"] = True
            sleeper_rows(lg, out, out["src"])
        elif last != None and last["week"] == w:
            last_rows(lg, out, last)          # the adapter's gap fetch: no call
        else:
            src = wk_src(lg, out)
            if src == None:
                out["err"] = out.get("src_err", None) or ["SLEEPER BUSY", "RETRY IN 5 MIN"]
                return out
            sleeper_rows(lg, out, src)
        guillotine_cut(lg, out)
        return out

    if lg["platform"] == "ESPN":
        j = lg["raw"]["json"]
        p = lg["week"]
        cur = [m for m in fl_d(j, "schedule", []) if int(fl_num(fl_d(m, "matchupPeriodId", 0))) == p]
        decided = len(cur) > 0
        for m in cur:
            if str(fl_d(m, "winner", "UNDECIDED")) == "UNDECIDED":
                decided = False
        w = p if decided else p - 1
        if w < 1:
            w = p
            out["sofar"] = True
        out["week"] = w
        live = out["sofar"]
        per = {}
        for m in fl_d(j, "schedule", []):
            mp = int(fl_num(fl_d(m, "matchupPeriodId", 0)))
            if mp < 1 or mp > w:
                continue
            sides = []
            for key in ["home", "away"]:
                s = fl_d(m, key, None)
                if s == None:
                    continue
                tid = fl_d(s, "teamId", 0)
                if lg["by_id"].get(tid, None) == None:
                    continue
                if mp < w:
                    per.setdefault(mp, []).append([tid, fl_num(fl_d(s, "totalPoints", 0))])
                    continue
                pts = fl_num(fl_d(s, "totalPointsLive", fl_d(s, "totalPoints", 0)) if live else fl_d(s, "totalPoints", 0))
                sides.append([tid, pts])
                out["rows"].append([tid, pts])
            if len(sides) == 2:
                out["pairs"].append(pair_rec(sides[0], sides[1]))
        mp = fl_d(fl_d(fl_d(j, "settings", {}), "scheduleSettings", {}), "matchupPeriods", {})
        out["sp"] = [int(fl_num(x)) for x in fl_d(mp, str(w), [w])]
        if not live and w > 1:
            out["tally"] = espn_tally(per, out["rows"])
        return out

    return demo_week(lg)

def sleeper_rows(lg, out, src):
    pairs = {}
    for m in src:
        rid = fl_d(m, "roster_id", 0)
        st = [s for s in fl_d(m, "starters", []) if str(s) not in ["0", ""]]
        if len(st) == 0:
            continue                 # a guillotine team already cut, or an empty roster
        cp = fl_d(m, "custom_points", None)
        pts = fl_num(cp) if cp != None else fl_num(fl_d(m, "points", 0))
        if lg["by_id"].get(rid, None) == None:
            continue
        out["rows"].append([rid, pts])
        mid = fl_d(m, "matchup_id", None)
        if mid != None and out["fmt"] != "guillotine":
            pairs.setdefault(mid, []).append([rid, pts])
    for mid in sorted(pairs.keys()):
        p = pairs[mid]
        if len(p) == 2:
            out["pairs"].append(pair_rec(p[0], p[1]))

def last_rows(lg, out, last):
    """Rows and games from the adapter's lg["last"] (finals by points). It
    has no lineups, so a team is out when it was cut before this week or
    scored nothing (an empty roster)."""
    w = out["week"]
    seen = {}
    for tid in last["scores"].keys():
        if lg["by_id"].get(tid, None) == None:
            continue
        c = cut_of(lg, tid)
        if c > 0 and c < w:
            continue
        pts = fl_num(fl_d(last["scores"][tid], "pts", 0))
        if pts == 0:
            continue
        out["rows"].append([tid, pts])
        seen[tid] = True
    if out["fmt"] != "guillotine":
        for m in last["matchups"]:
            if seen.get(m["a"], False) and seen.get(m["b"], False):
                out["pairs"].append(pair_rec([m["a"], m["a_pts"]], [m["b"], m["b_pts"]]))

def wk_src(lg, wk):
    """Sleeper: the week's matchups rows (lineups and players_points), once."""
    if wk["src_tried"]:
        return wk["src"]
    wk["src_tried"] = True
    r = fl_get(lg["budget"], FL_SLEEPER + "league/" + lg["raw"]["league_id"] + "/matchups/" + str(wk["week"]),
               ttl = 300 if wk["sofar"] else FL_TTL_LEAGUE)
    if r["status_code"] == 200 and type(r["json"]) == "list":
        wk["src"] = r["json"]
    elif r["status_code"] == 404 or r["status_code"] == 200:
        wk["src"] = []
    elif r["status_code"] == 0:
        wk["src_err"] = ["SLEEPER OFFLINE", "RETRY IN 5 MIN"]
    return wk["src"]

def guillotine_cut(lg, wk):
    """Who the blade took this week (Sleeper's roster `eliminated` week, via
    lg["scores"][id]["cut"]) and how many are left. Before Sleeper records
    the cut, the lowest score is the one going."""
    if wk["fmt"] != "guillotine":
        return
    rows = wk["rows"]
    if wk["sofar"] or len(rows) < 2:
        wk["left"] = len(rows)
        return
    cut = [r[0] for r in rows if cut_of(lg, r[0]) == wk["week"]]
    if len(cut) == 0:
        cut = [sorted(rows, key = lambda r: r[1])[0][0]]
    wk["cut"] = cut
    wk["left"] = len(rows) - len(cut)

def espn_tally(per, rows):
    """Season shelf from the weeks before this one plus this week: how often
    each team was the week's top / low score, and the best / worst score
    of the earlier weeks."""
    out = {"top": {}, "low": {}, "prior_max": -1.0, "prior_min": -1.0}
    weeks = [per[k] for k in per.keys()] + [rows]
    for i in range(len(weeks)):
        sc = [x for x in weeks[i] if x[1] > 0]
        if len(sc) < 2:
            continue
        s = sorted(sc, key = lambda x: -x[1])
        out["top"][s[0][0]] = out["top"].get(s[0][0], 0) + 1
        lo = s[len(s) - 1]
        out["low"][lo[0]] = out["low"].get(lo[0], 0) + 1
        if i < len(weeks) - 1:
            if s[0][1] > out["prior_max"]:
                out["prior_max"] = s[0][1]
            if out["prior_min"] < 0 or lo[1] < out["prior_min"]:
                out["prior_min"] = lo[1]
    return out

def pair_rec(x, y):
    """[winner id, loser id, winner pts, loser pts]; a tie keeps the order."""
    if y[1] > x[1]:
        return [y[0], x[0], y[1], x[1]]
    return [x[0], y[0], x[1], y[1]]

# ------------------------------------------------------------ demo week
# The demo league's week 2, results only (the adapter's DEMO league is
# week 3, so these are its last completed week).
DEMO_PAIRS = [[1, 8, 124.6, 79.3], [3, 2, 141.2, 127.9], [4, 5, 131.6, 83.5], [7, 6, 99.8, 98.6]]
DEMO_BENCH = [7, 31.4, 131.2]        # team, points left, best possible
DEMO_PLAYER = {"name": "JAMARR CHASE", "short": "J. CHASE", "pos": "WR", "club": "CIN", "pts": 38.6, "tid": 4}
DEMO_TALLY = {"top": {3: 2}, "low": {8: 2}, "prior_max": 136.0, "prior_min": 64.8}

def demo_week(lg):
    out = {"week": 2, "sofar": False, "fmt": "h2h", "rows": [], "pairs": DEMO_PAIRS, "err": None,
           "src": None, "src_tried": True, "box": None, "box_tried": True, "sp": [2],
           "tally": DEMO_TALLY, "cut": [], "left": -1}
    for p in DEMO_PAIRS:
        out["rows"].append([p[0], p[2]])
        out["rows"].append([p[1], p[3]])
    return out

# ------------------------------------------------------------ bench math
def best_lineup(slots, pool):
    """Best possible points: slots [[eligible set], ...], pool [[pts,
    [positions]]]. The narrowest slots are filled first, each with the
    best eligible player left - exact for the nested slot shapes fantasy
    leagues use (QB / RB / WR / TE, then FLEX, then SUPERFLEX)."""
    order = sorted(range(len(slots)), key = lambda i: len(slots[i]))
    used = {}
    total = 0.0
    ranked = sorted(range(len(pool)), key = lambda i: -pool[i][0])
    for si in order:
        for pi in ranked:
            if used.get(pi, False):
                continue
            ok = False
            for pos in pool[pi][1]:
                if pos in slots[si]:
                    ok = True
            if ok:
                used[pi] = True
                if pool[pi][0] > 0:
                    total += pool[pi][0]
                break
    return total

def sleeper_positions(lg, wk, groups):
    """pid -> [positions] for everyone with a stat line this week. None if
    the budget or the feed says no. Team defences need no stats (their id
    is the club)."""
    pos = {}
    for g in groups:
        q = "?season_type=regular&order_by=pts_ppr" + "".join(["&position[]=" + p for p in g])
        r = fl_get(lg["budget"], FL_SLEEPER_API + "stats/nfl/" + str(lg["season"]) + "/" + str(wk["week"]) + q,
                   ttl = 900 if wk["sofar"] else 3600)
        if r["status_code"] != 200 or type(r["json"]) != "list":
            return None
        for row in r["json"]:
            pid = str(fl_d(row, "player_id", ""))
            pl = fl_d(row, "player", {})
            fp = fl_d(pl, "fantasy_positions", [])
            p0 = str(fl_d(pl, "position", ""))
            ps = [str(x) for x in fp] if len(fp) > 0 else ([p0] if p0 != "" else [])
            if pid != "" and len(ps) > 0:
                pos[pid] = ps
    return pos

SLEEPER_SLOT = {"QB": ["QB"], "RB": ["RB"], "WR": ["WR"], "TE": ["TE"], "K": ["K"], "DEF": ["DEF"],
                "FLEX": ["RB", "WR", "TE"], "SUPER_FLEX": ["QB", "RB", "WR", "TE"],
                "REC_FLEX": ["WR", "TE"], "WRRB_FLEX": ["RB", "WR"]}

def sleeper_slots(lg, stats_calls):
    """slot index -> eligible positions from the league's roster_positions
    (IDP slots are left out: their starters stay as started). Adapter v2.1
    carries roster_positions in lg["raw"] - no request. None when the
    league has none. (stats_calls is kept for the callers; unused.)"""
    rp = [str(p) for p in lg["raw"].get("roster_positions", []) if str(p) not in ["BN", "IR", "TAXI"]]
    out = {}
    for i in range(len(rp)):
        if rp[i] in SLEEPER_SLOT:
            out[i] = SLEEPER_SLOT[rp[i]]
    return out if len(rp) > 0 else None

def sleeper_bench(lg, wk):
    """[[team id, points left, best possible]] for every team, or None."""
    rows = wk_src(lg, wk)
    if rows == None or len(rows) == 0:
        return None
    # Two stats groups (0.42 + 0.31 MB) when the budget has room for them,
    # else one call for all five offensive positions (0.60-0.73 MB, under
    # the 1 MB cap).
    groups = [["WR", "TE"], ["QB", "RB", "K"]]
    if lg["budget"]["n"] + 3 > FL_MAX_CALLS:
        groups = [["QB", "RB", "WR", "TE", "K"]]
    exact = sleeper_slots(lg, len(groups))
    pos = sleeper_positions(lg, wk, groups)
    if pos == None:
        return None
    # Team defences are keyed by club (LAR), not a number.
    def pos_of(pid):
        if pid in pos:
            return pos[pid]
        if len(pid) <= 3 and fl_norm(pid) == pid and FL_DIGITS.find(pid[:1]) < 0:
            return ["DEF"]
        return []
    # The league's lineup slots: from its roster_positions (adapter v2.1),
    # else read off the league's own lineups - slot i takes
    # whatever positions any team started there, which can only understate
    # a flex.
    seen = {}
    for m in rows:
        st = fl_d(m, "starters", [])
        for i in range(len(st)):
            pid = str(st[i])
            if pid in ["0", ""]:
                continue
            for p in pos_of(pid)[:1]:
                seen.setdefault(i, {})[p] = True
    slots = {}
    for i in seen.keys():
        s = list(seen[i].keys())
        if "QB" in s and len(s) > 1:
            s = ["QB", "RB", "WR", "TE"]           # superflex
        slots[i] = s
    if exact != None:
        slots = exact
    out = []
    for m in rows:
        st = [str(x) for x in fl_d(m, "starters", [])]
        if len([x for x in st if x not in ["0", ""]]) == 0:
            continue
        if lg["by_id"].get(fl_d(m, "roster_id", 0), None) == None:
            continue
        pp = fl_d(m, "players_points", {})
        actual = 0.0
        fixed = 0.0
        lineup = []
        started = {}
        movable = {}
        for i in range(len(st)):
            pid = st[i]
            if pid in ["0", ""]:
                if i in slots:
                    lineup.append(slots[i])   # an empty slot a bench player could fill
                continue
            started[pid] = True
            v = fl_num(pp.get(pid, 0))
            actual += v
            if i in slots and (len(pos_of(pid)) > 0 or v == 0):
                lineup.append(slots[i])       # a starter who didn't play frees the slot
                movable[pid] = True
            else:
                fixed += v                    # a player we can't place stays put
        pool = []
        for pid in [str(x) for x in fl_d(m, "players", [])]:
            ps = pos_of(pid)
            if len(ps) == 0:
                continue
            if pid in started and pid not in movable:
                continue
            pool.append([fl_num(pp.get(pid, 0)), ps])
        best = fixed + best_lineup(lineup, pool)
        left = best - actual
        out.append([fl_d(m, "roster_id", 0), left if left > 0.05 else 0.0, best])
    return out

def espn_box(lg, wk):
    """The week's mBoxscore (schedule filtered to the week), once, or None.
    A matchup that spans two scoring periods (some playoff rounds) reads the
    last one only."""
    if wk["box_tried"]:
        return wk["box"]
    wk["box_tried"] = True
    if len(wk["sp"]) == 0:
        return None
    sp = wk["sp"][len(wk["sp"]) - 1]
    h = dict(lg["raw"]["cookie"])
    h["x-fantasy-filter"] = '{"schedule":{"filterMatchupPeriodIds":{"value":[' + str(wk["week"]) + ']}}}'
    r = fl_get(lg["budget"], FL_ESPN + str(lg["raw"]["season"]) + "/segments/0/leagues/" + lg["raw"]["league_id"] +
               "?view=mBoxscore&scoringPeriodId=" + str(sp), headers = h, ttl = 300 if wk["sofar"] else 1800)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    wk["box"] = r["json"]
    return wk["box"]

def espn_entries(box, week):
    """teamId -> roster entries for the week."""
    out = {}
    for m in fl_d(box, "schedule", []):
        if int(fl_num(fl_d(m, "matchupPeriodId", 0))) != week:
            continue
        for key in ["home", "away"]:
            s = fl_d(m, key, None)
            if s == None:
                continue
            ro = fl_d(s, "rosterForCurrentScoringPeriod", None) or fl_d(s, "rosterForMatchupPeriod", {})
            out[fl_d(s, "teamId", 0)] = fl_d(ro, "entries", [])
    return out

def espn_bench(lg, wk, box):
    counts = fl_d(fl_d(fl_d(lg["raw"]["json"], "settings", {}), "rosterSettings", {}), "lineupSlotCounts", {})
    slot_list = []
    for k in counts.keys():
        sid = int(fl_num(k))
        n = int(fl_num(counts[k]))
        if sid in ESPN_NOT_STARTING or n <= 0:
            continue
        for i in range(n):
            slot_list.append(sid)
    if len(slot_list) == 0:
        return None
    # A slot's eligible set = the slot itself (players list the slots they
    # may fill), so a slot's breadth is how many positions reach it.
    reach = {}
    ents = espn_entries(box, wk["week"])
    for tid in ents.keys():
        for e in ents[tid]:
            pl = fl_d(fl_d(e, "playerPoolEntry", {}), "player", {})
            dp = int(fl_num(fl_d(pl, "defaultPositionId", 0)))
            for s in fl_d(pl, "eligibleSlots", []):
                reach.setdefault(int(fl_num(s)), {})[dp] = True
    out = []
    for tid in ents.keys():
        if lg["by_id"].get(tid, None) == None:
            continue
        actual = 0.0
        pool = []
        for e in ents[tid]:
            slot = int(fl_num(fl_d(e, "lineupSlotId", 20)))
            pe = fl_d(e, "playerPoolEntry", {})
            v = fl_num(fl_d(pe, "appliedStatTotal", 0))
            if slot not in ESPN_NOT_STARTING:
                actual += v
            if slot == 21:
                continue                    # injured reserve can't be started
            el = [int(fl_num(s)) for s in fl_d(fl_d(pe, "player", {}), "eligibleSlots", [])]
            pool.append([v, el])
        # Slots as single-element sets over slot ids; breadth decides order.
        slots = sorted(slot_list, key = lambda s: len(reach.get(s, {})))
        best = best_lineup([[s] for s in slots], pool)
        left = best - actual
        out.append([tid, left if left > 0.05 else 0.0, best])
    return out

def top_player(lg, wk):
    """{name, short, pos, club, pts, tid, pid} of the week's best starter, or
    None. Sleeper leaves name / club to player_info (one small call, made
    only when the frame is drawn)."""
    if lg["platform"] == "DEMO":
        return DEMO_PLAYER
    if lg["platform"] == "ESPN":
        box = espn_box(lg, wk)
        if box == None:
            return None
        best = None
        ents = espn_entries(box, wk["week"])
        for tid in ents.keys():
            if lg["by_id"].get(tid, None) == None:
                continue
            for e in ents[tid]:
                if int(fl_num(fl_d(e, "lineupSlotId", 20))) in ESPN_NOT_STARTING:
                    continue
                pe = fl_d(e, "playerPoolEntry", {})
                v = fl_num(fl_d(pe, "appliedStatTotal", 0))
                if best == None or v > best[0]:
                    best = [v, tid, fl_d(pe, "player", {})]
        if best == None:
            return None
        pl = best[2]
        pos = ESPN_POS.get(int(fl_num(fl_d(pl, "defaultPositionId", 0))), "")
        club = ESPN_PRO.get(int(fl_num(fl_d(pl, "proTeamId", 0))), "")
        name = fl_clean(fl_d(pl, "fullName", ""))
        if pos == "DEF":
            name = fl_clean(str(fl_d(pl, "fullName", "")).replace("D/ST", "")) + " DEFENSE"
        short = name
        if pos != "DEF":
            fn = fl_clean(fl_d(pl, "firstName", ""))
            ln = fl_clean(fl_d(pl, "lastName", ""))
            if fn != "" and ln != "":
                short = fn[:1] + ". " + ln
        return {"name": name, "short": short, "pos": pos, "club": club, "pts": best[0], "tid": best[1]}
    # Sleeper: starters_points lines up with starters.
    best = None
    for m in wk_src(lg, wk) or []:
        rid = fl_d(m, "roster_id", 0)
        if lg["by_id"].get(rid, None) == None:
            continue
        st = fl_d(m, "starters", [])
        sp = fl_d(m, "starters_points", [])
        for i in range(len(st)):
            pid = str(st[i])
            if pid in ["0", ""] or i >= len(sp):
                continue
            v = fl_num(sp[i])
            if best == None or v > best[0]:
                best = [v, rid, pid]
    if best == None:
        return None
    pid = best[2]
    if FL_DIGITS.find(pid[:1]) < 0:
        club = CLUB_FIX.get(pid, pid)
        return {"name": pid + " DEFENSE", "short": pid + " DEFENSE", "pos": "DEF", "club": club,
                "pts": best[0], "tid": best[1]}
    if lg["budget"]["n"] >= FL_MAX_CALLS:
        return None                      # no call left for his name
    return {"pid": pid, "pts": best[0], "tid": best[1]}

def player_info(lg, pl):
    """Fill a Sleeper player's name, position and club (players/<id>)."""
    if "name" in pl:
        return pl
    r = fl_get(lg["budget"], FL_SLEEPER_API + "players/nfl/" + pl["pid"], ttl = 21600)
    j = r["json"] if r["status_code"] == 200 and type(r["json"]) == "dict" else {}
    fn = fl_clean(fl_d(j, "first_name", ""))
    ln = fl_clean(fl_d(j, "last_name", ""))
    name = (fn + " " + ln).strip()
    club = str(fl_d(j, "team", "")).upper()
    return {"name": name if name != "" else "PLAYER " + pl["pid"],
            "short": (fn[:1] + ". " + ln) if fn != "" and ln != "" else name,
            "pos": str(fl_d(j, "position", "")).upper(), "club": CLUB_FIX.get(club, club),
            "pts": pl["pts"], "tid": pl["tid"]}

# ------------------------------------------------------------ the frames
def is_me(lg, tid):
    return tid == lg["me"] and (lg["me_matched"] or lg["state"] == "demo")

def calc(lg, wk, key):
    """One award's winner as a frame {key, ids, ...}, or None when there is
    nothing to give (no games, no lineup data)."""
    rows = wk["rows"]
    if key == "top":
        b = sorted(rows, key = lambda r: -r[1])[0]
        return {"key": key, "ids": [b[0]], "tid": b[0], "val": b[1]}
    if key == "player":
        pl = top_player(lg, wk)
        return None if pl == None else {"key": key, "ids": [pl["tid"]], "pl": pl}
    if key in ["closest", "blowout"]:
        if len(wk["pairs"]) == 0:
            return None
        sgn = 1 if key == "closest" else -1
        p = sorted(wk["pairs"], key = lambda q: sgn * (q[2] - q[3]))[0]
        return {"key": key, "ids": [p[0], p[1]], "p": p}
    if key == "unlucky":
        losers = [p for p in wk["pairs"] if p[2] > p[3]]
        if len(losers) == 0:
            return None
        p = sorted(losers, key = lambda q: -q[3])[0]
        return {"key": key, "ids": [p[1]], "p": p}
    if key == "lowest":
        lo = sorted(rows, key = lambda r: r[1])[0]
        return {"key": key, "ids": [lo[0]], "tid": lo[0], "val": lo[1]}
    if key == "bench":
        res = None
        if lg["platform"] == "DEMO":
            res = [DEMO_BENCH]
        elif lg["platform"] == "ESPN":
            box = espn_box(lg, wk)
            res = espn_bench(lg, wk, box) if box != None else None
        else:
            res = sleeper_bench(lg, wk)
        if res == None or len(res) == 0:
            return None
        b = sorted(res, key = lambda r: -r[1])[0]
        return {"key": key, "ids": [b[0]] if b[1] > 0 else [], "b": b}
    if key == "standing":
        return {"key": key, "ids": []} if len(rows) >= 2 else None
    if key == "shave":
        s = sorted(rows, key = lambda r: r[1])
        live = [r for r in s if r[0] not in wk["cut"]]
        gone = [r for r in s if r[0] in wk["cut"]]
        if len(s) < 2 or len(live) == 0:
            return None
        edge = gone[len(gone) - 1][1] if len(gone) > 0 else s[0][1]
        safe = live[0] if len(gone) > 0 else s[1]
        return {"key": key, "ids": [safe[0]], "tid": safe[0], "val": safe[1] - edge, "pts": safe[1]}
    if key == "chopped":
        s = sorted(rows, key = lambda r: r[1])
        gone = [r for r in s if r[0] in wk["cut"]]
        lo = gone[0] if len(gone) > 0 else s[0]
        return {"key": key, "ids": [r[0] for r in gone] or [lo[0]], "tid": lo[0], "val": lo[1],
                "with": [r[0] for r in gone if r[0] != lo[0]]}
    return None

def pick(ctx, lg, wk, slot):
    """The frame this render shows: the slot's awards that can be given,
    the viewer's own first, one per refresh from Tuesday 06:00 ET."""
    fr = []
    for k in SLOTS[wk["fmt"]][slot]:
        f = calc(lg, wk, k)
        if f != None:
            f["mine"] = len([i for i in f["ids"] if is_me(lg, i)]) > 0
            fr.append(f)
    if len(fr) == 0:
        return None
    order = [f for f in fr if f["mine"]] + [f for f in fr if not f["mine"]]
    return order[((ctx.now.unix - FRAME_T0) // FRAME_SECS) % len(order)]

# ------------------------------------------------------------ screens
def card(c, head, sub, rail, head_color):
    c.fill("black")
    c.rect(L, 0, L + 1, 31, fill = rail)
    c.sprite(CUP, L + 3, 5, legend = CUP_SILVER)
    h = fit(c, head, ["6x8", "5x7", "4x5"], R - 44)
    c.text(h[0], 112, 8, font = h[1], color = head_color, align = "center")
    s = fit(c, sub, ["4x5", "picopixel"], R - 44)
    c.text(s[0], 112, 21, font = s[1], color = DIM, align = "center")

def state_card(c, lg):
    if not lg["ok"]:
        card(c, lg["err"][0], lg["err"][1], OFFLINE, AMBER)
        return True
    if lg["state"] == "predraft":
        card(c, "AWARDS AFTER WEEK 1", "YOUR LEAGUE HASNT DRAFTED YET", GOOD, GOOD)
        return True
    return False

def get_week(c, ctx):
    """Load the league and the awards week; draws a card and returns None
    when there's nothing to award."""
    lg = fl_load(ctx, projections = False)
    if state_card(c, lg):
        return None
    wk = week_data(ctx, lg)
    if wk["err"] != None:
        card(c, wk["err"][0], wk["err"][1], OFFLINE, AMBER)
        return None
    scored = [r for r in wk["rows"] if r[1] != 0]
    if len(scored) == 0:
        card(c, "NO SCORES YET", "AWARDS AFTER THE FIRST KICKOFF", GOOD, GOOD)
        return None
    return [lg, wk]

def header(c, lg, wk, key, you, x0 = TX):
    """Week, DEMO and the YOU pill top right; the award title in its colour
    from x0, in whichever of its long / short forms fits what's left."""
    a = AWARD[key]
    wtxt = ("WK " + str(wk["week"])) + (" SO FAR" if wk["sofar"] else "")
    x = R
    c.text(wtxt, x, 2, font = "4x5", color = DIM, align = "right")
    x -= c.text_width(wtxt, "4x5") + 4
    if lg["state"] == "demo":
        c.text("DEMO", x, 2, font = "4x5", color = AMBER, align = "right")
        x -= c.text_width("DEMO", "4x5") + 4
    if you:
        w = c.text_width("YOU", "4x5")
        c.rect(x - w - 3, 1, x, 7, fill = INK)
        c.text("YOU", x - 1, 2, font = "4x5", color = "black", align = "right")
        x -= w + 7
    room = x - x0 - 2
    for t in [[a[0], "5x7"], [a[2], "5x7"], [a[2], "4x5"]]:
        if c.text_width(t[0], t[1]) <= room or t[1] == "4x5":
            f = fit(c, t[0], [t[1]], room)
            c.text(f[0], x0, 1 if t[1] == "5x7" else 2, font = t[1], color = a[1])
            return [x0 + c.text_width(f[0], t[1]), x]
    return [x0, x]

def art(c, key, y = -1):
    """The award's pixel art in the art column (y overrides the top)."""
    if key == "top":
        c.sprite(CUP, L + 3, 6 if y < 0 else y, legend = CUP_GOLD)
    elif key == "blowout":
        c.sprite(BURST, L + 3, 6, legend = BURST_LEG)
    elif key == "closest":
        c.sprite(WATCH, L + 4, 7, legend = WATCH_LEG)
    elif key == "unlucky":
        c.sprite(STORMCLOUD, L + 1, 6, legend = STORM_LEG)
    elif key == "lowest":
        c.sprite(TOILET, L + 4, 7, legend = TOILET_LEG)
    elif key == "bench":
        c.sprite(BENCHART, L + 1, 8, legend = BENCH_LEG)
    elif key == "chopped":
        c.sprite(GUILLOTINE, L + 4, 4, legend = GUILLOTINE_LEG)
    elif key == "shave":
        c.sprite(GRIMACE, L + 4, 8, legend = GRIMACE_LEG)

def shelf(c, n):
    """The season trophy shelf under the gold cup: one small cup per week
    this team has had the top score (four at most)."""
    k = n if n <= 3 else 3
    x = L + 14 - (8 * k - 1) // 2
    for i in range(k):
        c.sprite(MINICUP, x + i * 8, 26, legend = MINICUP_LEG)

def hero_at(c, value, label, col, compact):
    s = fmt1(value)
    f = "10x16" if c.text_width(s, "10x16") <= 52 else "9x12"
    w = c.text_width(s, f)
    y = (9 if compact else 10) if f == "10x16" else (11 if compact else 12)
    c.text(s, R - w, y, font = f, color = col)
    lw = c.text_width(label, "4x5")
    c.text(label, R, 26 if compact else 27, font = "4x5", color = DIM, align = "right")
    return [R - w, R - lw]

def my_week(lg, wk):
    """The viewer's own week for the strip, or None: {rank, n, pts, res,
    out (guillotine: week cut, when cut before this one)}."""
    if not (lg["me_matched"] or lg["state"] == "demo") or lg["me"] == None:
        return None
    me = lg["me"]
    rows = wk["rows"]
    mine = [r for r in rows if r[0] == me]
    if len(mine) == 0:
        cw = cut_of(lg, me) if wk["fmt"] == "guillotine" else 0
        if cw > 0 and cw < wk["week"]:
            return {"out": cw}
        return None
    pts = mine[0][1]
    res = ""
    if wk["fmt"] == "guillotine":
        if not wk["sofar"]:
            res = "CUT" if me in wk["cut"] else "SAFE"
    elif not wk["sofar"]:
        for p in wk["pairs"]:
            if p[0] == me or p[1] == me:
                res = "T" if p[2] == p[3] else ("W" if p[0] == me else "L")
    return {"rank": 1 + len([r for r in rows if r[1] > pts]), "n": len(rows), "pts": pts,
            "res": res, "out": 0}

RES_COL = {"W": GOOD, "L": ALARM, "T": AMBER, "SAFE": GOOD, "CUT": ALARM}

def strip(c, lg, wk, m, x0, maxx):
    """YOUR WEEK, bottom row: 'YOU 4TH OF 10  123.0 [W]' in whatever fits
    between x0 and maxx."""
    y = 26
    col = fl_team(lg, lg["me"])["color"]
    if m["out"] > 0:
        t = fit(c, "YOU  CUT IN WK " + str(m["out"]), ["4x5"], maxx - x0)
        c.text(t[0], x0, y, font = "4x5", color = DIM)
        return
    pts = fmt1(m["pts"])
    rk = ordinal(m["rank"])
    chip = m["res"]
    cw = c.text_width(chip, "4x5") + 4 if chip != "" else 0
    for r in [rk + " OF " + str(m["n"]), rk + "/" + str(m["n"]), rk]:
        need = c.text_width("YOU", "4x5") + 4 + c.text_width(r, "4x5") + 4 + c.text_width(pts, "4x5") + (3 + cw if cw > 0 else 0)
        if need <= maxx - x0 or r == rk:
            x = x0
            c.text("YOU", x, y, font = "4x5", color = INK)
            x += c.text_width("YOU", "4x5") + 4
            c.text(r, x, y, font = "4x5", color = DIM)
            x += c.text_width(r, "4x5") + 4
            c.text(pts, x, y, font = "4x5", color = col)
            x += c.text_width(pts, "4x5") + 3
            if cw > 0 and x + cw - 1 <= maxx:
                c.rect(x, y - 1, x + cw - 2, y + 5, fill = RES_COL[chip])
                c.text(chip, x + 2, y, font = "4x5", color = "black")
            return

def first_fit(c, subs, maxw):
    """The first sub line that fits whole in 4x5, else the last one clipped."""
    for s in subs:
        if c.text_width(s, "4x5") <= maxw:
            return [s, "4x5"]
    return fit(c, subs[len(subs) - 1], ["4x5", "picopixel"], maxw)

def team_award(c, lg, wk, f, value, label, subs, sub_color, cups = 0):
    """One team takes the award: crest, name in team colour, a sub line
    (the first of `subs` that fits), the number, and the viewer's strip."""
    key = f["key"]
    t = fl_team(lg, f["tid"])
    # The viewer's strip, unless the award is the viewer's own (the YOU
    # pill says it, and the numbers would repeat).
    m = my_week(lg, wk) if not is_me(lg, t["id"]) else None
    cp = m != None
    c.fill("black")
    art(c, key, 3 if cups > 0 else -1)
    if cups > 0:
        shelf(c, cups)
    header(c, lg, wk, key, f["mine"])
    hx = hero_at(c, value, label, INK, cp)
    by = 9 if cp else 11
    fl_badge(c, t, TX, by, 16)
    nx = TX + 16 + 4
    nm = name_fit(c, lg, t, hx[0] - nx - 5)
    c.text(nm[0], nx, by + (1 if nm[1] == "5x7" else 2), font = nm[1], color = t["color"])
    if len(subs) > 0:
        s = first_fit(c, subs, hx[0] - nx - 5)
        c.text(s[0], nx, 19 if cp else 22, font = s[1], color = sub_color)
    if cp:
        strip(c, lg, wk, m, TX, hx[1] - 5)

def pair_award(c, lg, wk, f):
    """A game takes the award: the winner's crest and name, the loser under
    it, the margin as the hero with the final score beneath it."""
    key = f["key"]
    p = f["p"]
    m = my_week(lg, wk)
    cp = m != None
    c.fill("black")
    art(c, key)
    header(c, lg, wk, key, f["mine"] or is_me(lg, p[0]) or is_me(lg, p[1]))
    final = fmt1(p[2]) + "-" + fmt1(p[3])
    hx = hero_at(c, p[2] - p[3], final, INK, cp)
    w = fl_team(lg, p[0])
    l = fl_team(lg, p[1])
    by = 9 if cp else 11
    fl_badge(c, w, TX, by, 16)
    nx = TX + 16 + 4
    room = hx[0] - nx - 5          # the final score sits below the name rows
    nm = name_fit(c, lg, w, room)
    c.text(nm[0], nx, by + (1 if nm[1] == "5x7" else 2), font = nm[1], color = w["color"])
    verb = "TIED" if p[2] == p[3] else ("EDGED" if p[2] - p[3] < 5 else "BEAT")
    # "BEAT THE WAIVER WIRE" when it fits; the loser's whole name beats the
    # verb when it doesn't.
    ly = 19 if cp else 22
    vw = c.text_width(verb, "4x5") + 4
    lw = c.text_width(tname(lg, p[1]), "4x5")
    if lw > room - vw and lw <= room:
        vw = 0
    if vw > 0:
        c.text(verb, nx, ly, font = "4x5", color = DIM)
    ln = name_fit(c, lg, l, room - vw, ["4x5"])
    c.text(ln[0], nx + vw, ly, font = ln[1], color = l["color"])
    if cp:
        strip(c, lg, wk, m, TX, hx[1] - 5)

# ------------------------------------------------------------ award frames
def draw_top(c, lg, wk, f):
    best = [f["tid"], f["val"]]
    t = wk["tally"]
    cups = 0
    subs = []
    col = DIM
    if t != None:
        cups = t["top"].get(best[0], 0)
        if t["prior_max"] > 0 and best[1] > t["prior_max"]:
            subs = ["SEASON HIGH SCORE", "SEASON HIGH"]
            col = GOLD
        elif cups >= 2:
            subs = [ordinal(cups) + " TOP SCORE THIS YEAR", ordinal(cups) + " TOP SCORE", ordinal(cups) + " TIME"]
    beat = []
    for p in wk["pairs"]:
        if p[0] == best[0] and p[2] > p[3]:
            on = tname(lg, p[1])
            by = fmt1(p[2] - p[3])
            beat = ["BEAT " + on + " BY " + by, "BEAT " + on, "WON BY " + by]
        elif (p[1] == best[0] or p[0] == best[0]) and p[2] == p[3]:
            beat = ["TIED " + tname(lg, p[1] if p[0] == best[0] else p[0]), "TIED"]
    if len(subs) > 0 and len(beat) > 0:
        subs = [subs[0] + ", " + beat[len(beat) - 1]] + subs
    subs = subs + beat
    if len(subs) == 0 and len(wk["rows"]) > 1:
        tot = 0.0
        for r in wk["rows"]:
            tot += r[1]
        avg = tot / (len(wk["rows"]) * 1.0)
        subs = ["+" + fmt1(best[1] - avg) + " OVER THE LEAGUE AVERAGE", "+" + fmt1(best[1] - avg) + " OVER AVERAGE"]
    team_award(c, lg, wk, f, best[1], "PTS", subs, col, cups)

def draw_unlucky(c, lg, wk, f):
    p = f["p"]
    who = tname(lg, p[0])
    place = len([r for r in wk["rows"] if r[1] > p[3]]) + 1
    subs = ["LOST TO " + who + " " + fmt1(p[2]), "LOST TO " + who,
            ordinal(place) + " BEST SCORE, LOST", ordinal(place) + " BEST, LOST", "LOST BY " + fmt1(p[2] - p[3])]
    f2 = dict(f)
    f2["tid"] = p[1]
    team_award(c, lg, wk, f2, p[3], "PTS", subs, DIM)

def draw_lowest(c, lg, wk, f):
    low = [f["tid"], f["val"]]
    rows = sorted(wk["rows"], key = lambda r: r[1])
    subs = []
    t = wk["tally"]
    if t != None:
        n = t["low"].get(low[0], 0)
        if t["prior_min"] > 0 and low[1] < t["prior_min"]:
            subs = ["SEASON LOW SCORE", "SEASON LOW"]
        elif n >= 2:
            subs = [ordinal(n) + " LOW SCORE THIS YEAR", ordinal(n) + " LOW SCORE", ordinal(n) + " TIME"]
    for p in wk["pairs"]:
        if p[1] == low[0] and p[2] > p[3]:
            subs = subs + ["LOST TO " + tname(lg, p[0]), "LOST BY " + fmt1(p[2] - p[3])]
        elif p[0] == low[0] and p[2] > p[3]:
            subs = ["AND STILL WON"] + subs
    if len(rows) > 1:
        subs.append(fmt1(rows[1][1] - low[1]) + " BEHIND THE NEXT WORST")
    team_award(c, lg, wk, f, low[1], "PTS", subs, DIM)

def draw_bench(c, lg, wk, f):
    b = f["b"]
    if b[1] <= 0:
        c.fill("black")
        art(c, "bench")
        header(c, lg, wk, "bench", False)
        c.text("PERFECT LINEUPS", TX, 13, font = "5x7", color = GOOD)
        c.text("EVERY TEAM STARTED ITS BEST", TX, 23, font = "4x5", color = DIM)
        return
    f2 = dict(f)
    f2["tid"] = b[0]
    team_award(c, lg, wk, f2, b[1], "PTS",
               ["BEST LINEUP " + fmt1(b[2]) + ", STARTED " + fmt1(b[2] - b[1]), "BEST " + fmt1(b[2]) + ", STARTED " + fmt1(b[2] - b[1]),
                "BEST LINEUP " + fmt1(b[2]), "BEST " + fmt1(b[2])], DIM)

def draw_player(c, lg, wk, f):
    pl = player_info(lg, f["pl"])
    t = fl_team(lg, pl["tid"])
    m = my_week(lg, wk)
    cp = m != None
    c.fill("black")
    logo = LOGOS.get(pl["club"], LOGOS["NFL"])
    c.image(logo, L, 5)
    x0 = L + 40 + 4
    header(c, lg, wk, "player", f["mine"], x0)   # title sits right of the logo here
    hx = hero_at(c, pl["pts"], "PTS", INK, cp)
    room = hx[0] - x0 - 5
    # Full name, then J. SURNAME, then the surname alone, before a clip.
    last = pl["short"].split(". ", 1)[1] if ". " in pl["short"] else pl["short"]
    nm = None
    for cand in [[pl["name"], "5x7"], [pl["short"], "5x7"], [pl["name"], "4x5"], [pl["short"], "4x5"], [last, "5x7"]]:
        if nm == None and c.text_width(cand[0], cand[1]) <= room:
            nm = cand
    if nm == None:
        nm = fit(c, last, ["4x5"], room)
    c.text(nm[0], x0, 10 if cp else 12, font = nm[1], color = INK)
    # Sub line: position chip, then his fantasy team's name.
    ly = 19 if cp else 23
    cx = x0
    if pl["pos"] != "":
        pw = c.text_width(pl["pos"], "4x5")
        c.rect(cx, ly - 1, cx + pw + 2, ly + 5, fill = GOLD)
        c.text(pl["pos"], cx + 2, ly, font = "4x5", color = "black")
        cx += pw + 7
    if t != None:
        tw = c.text_width(tname(lg, t["id"]), "4x5")
        fw = c.text_width("FOR", "4x5") + 4
        if tw > hx[0] - cx - 5 - fw and tw <= hx[0] - cx - 5:
            fw = 0                     # the whole team name beats "FOR"
        if fw > 0:
            c.text("FOR", cx, ly, font = "4x5", color = DIM)
        cx += fw
        tn = name_fit(c, lg, t, hx[0] - cx - 5, ["4x5"])
        c.text(tn[0], cx, ly, font = tn[1], color = t["color"])
    if cp:
        strip(c, lg, wk, m, x0, hx[1] - 5)

def no_games(c, lg, wk, key):
    c.fill("black")
    art(c, key)
    header(c, lg, wk, key, False)
    why = {"bench": ["NO LINEUP DATA", "BENCH SCORES UNAVAILABLE THIS WEEK"],
           "player": ["NO PLAYER DATA", "PLAYER SCORES UNAVAILABLE THIS WEEK"]}.get(key, ["NO GAMES", "NO HEAD-TO-HEAD GAMES THIS WEEK"])
    c.text(why[0], TX, 13, font = "5x7", color = INK)
    c.text(why[1], TX, 23, font = "4x5", color = DIM)

# ------------------------------------------------------------ guillotine
def still_standing(c, lg, wk):
    """Every team that played this week, best score first, the cut crossed
    out in red. Up to 10 teams: full crests with scores; more: two rows of
    small monogram crests and the cut score on the right."""
    c.fill("black")
    rows = sorted(wk["rows"], key = lambda r: -r[1])
    n = len(rows)
    a = AWARD["standing"]
    hd = header(c, lg, wk, "standing", False, L)
    lt = str(wk["left"]) + " LEFT"
    if hd[0] + 6 + c.text_width(lt, "4x5") <= hd[1] - 4:
        c.text(lt, hd[0] + 6, 2, font = "4x5", color = DIM)
    if n <= 10:
        pitch = (R - L + 1) // n
        for i in range(n):
            t = fl_team(lg, rows[i][0])
            cut = rows[i][0] in wk["cut"]
            x = L + i * pitch + (pitch - 16) // 2
            fl_badge(c, t, x, 10, 16)
            if cut:
                c.sprite(XMARK, x + 4, 14, legend = {"X": ALARM})
            v = str(int(rows[i][1] + 0.5))
            c.text(v, x + 8, 27, font = "4x5", color = ALARM if cut else (INK if is_me(lg, t["id"]) else DIM), align = "center")
        return
    per = (n + 1) // 2
    gone = [r for r in rows if r[0] in wk["cut"]]
    for i in range(n):
        t = fl_team(lg, rows[i][0])
        x = L + (i % per) * 16
        y = 10 if i < per else 21
        mini_crest(c, t, x + 1, y, rows[i][0] in wk["cut"], is_me(lg, t["id"]))
    # The blade's side of the shelf: the cut score in red.
    bx = L + per * 16 + 2
    cx = (bx + R) // 2
    if len(gone) > 0:
        c.text("CUT", cx, 11, font = "4x5", color = ALARM, align = "center")
        v = fmt1(gone[0][1])
        f = "5x7" if c.text_width(v, "5x7") <= R - bx else "4x5"
        c.text(v, cx, 18, font = f, color = ALARM, align = "center")
        c.text("PTS", cx, 26, font = "4x5", color = DIM, align = "center")
    else:
        # Week 1 so far: the lowest score is the one on the block.
        c.text("LOW", cx, 11, font = "4x5", color = AMBER, align = "center")
        v = fmt1(rows[n - 1][1])
        f = "5x7" if c.text_width(v, "5x7") <= R - bx else "4x5"
        c.text(v, cx, 18, font = f, color = AMBER, align = "center")
        c.text("PTS", cx, 26, font = "4x5", color = DIM, align = "center")

def mini_crest(c, t, x, y, cut, me):
    """A 13 x 10 shield with the team's monogram: rim in the team colour
    (white for the viewer), a dark tinted field; a cut team is dimmed with
    a red slash."""
    col = t["color"]
    rim = INK if me else col
    if cut:
        col = color.dim(col, 35)
        rim = color.dim(rim, 35)
    field = color.dim(col, 22)
    insets = [1, 0, 0, 0, 0, 0, 1, 2, 3, 5]
    for r in range(10):
        i = insets[r]
        c.rect(x + i, y + r, x + 12 - i, y + r, fill = rim)
        if r > 0 and r < 8 and 12 - 2 * i >= 2:
            c.rect(x + i + 1, y + r, x + 11 - i, y + r, fill = field)
    c.text(fl_monogram(t), x + 7, y + 2, font = "4x5", color = SLATE if cut else "white", align = "center")
    if cut:
        c.rect(x - 1, y + 4, x + 13, y + 5, fill = ALARM)

# ------------------------------------------------------------ pages
def slot_page(c, ctx, slot):
    got = get_week(c, ctx)
    if got == None:
        return
    lg, wk = got[0], got[1]
    f = pick(ctx, lg, wk, slot)
    if f == None:
        no_games(c, lg, wk, SLOTS[wk["fmt"]][slot][0] if SLOTS[wk["fmt"]][slot][0] != "standing" else "shave")
        return
    k = f["key"]
    if k == "top":
        draw_top(c, lg, wk, f)
    elif k == "player":
        draw_player(c, lg, wk, f)
    elif k in ["closest", "blowout"]:
        pair_award(c, lg, wk, f)
    elif k == "unlucky":
        draw_unlucky(c, lg, wk, f)
    elif k == "lowest":
        draw_lowest(c, lg, wk, f)
    elif k == "bench":
        draw_bench(c, lg, wk, f)
    elif k == "standing":
        still_standing(c, lg, wk)
    elif k == "shave":
        team_award(c, lg, wk, f, f["val"], "PTS CLEAR",
                   ["SCORED " + fmt1(f["pts"]) + ", JUST ABOVE THE BLADE", "SCORED " + fmt1(f["pts"])], DIM)
    elif k == "chopped":
        left = wk["left"]
        subs = ["CUT - " + str(left) + " TEAMS LEFT", "CUT, " + str(left) + " LEFT", "CUT"]
        if len(f["with"]) > 0:
            subs = ["CUT WITH " + tname(lg, f["with"][0]), "CUT, " + str(left) + " LEFT"]
        if wk["sofar"]:
            subs = ["ON THE BLOCK SO FAR", "ON THE BLOCK"]
        team_award(c, lg, wk, f, f["val"], "PTS", subs, ALARM)

def podium(c, ctx):
    slot_page(c, ctx, "podium")

def games(c, ctx):
    slot_page(c, ctx, "games")

def shame(c, ctx):
    slot_page(c, ctx, "shame")
