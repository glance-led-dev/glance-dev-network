# NFL Defensive Leaders (192x32)
#
# The top 3 defensive leaders in one stat per page (Total Tackles, Solo
# Tackles, Sacks, Interceptions, Passes Defended, TFL, Forced Fumbles,
# Defensive TDs), for NFL overall, the AFC, or the NFC - regular season or
# playoffs (the Stats setting; nothing switches on its own, since NFL playoff
# stats come from one to four games). Every page is a count, so none needs a
# minimum. Assisted Tackles was
# dropped (2026-09-16, Chris's call) - Total already equals Solo + Assisted,
# so all three was redundant, and Assisted alone is the least-looked-up of
# the three; Solo stayed as the one meaningful individual cut beside Total.
# Passes Defended took the freed slot (same session) - unlike the "general"
# category's fumblesForced/fumblesRecovered/fumblesTouchdowns fields, ESPN's
# sort actually works correctly for defensive.passesDefended (confirmed live
# against a 15-deep sorted sample), so this one didn't need the pooled/
# computed workaround Forced Fumbles does. Defensive TDs later replaced
# the standalone Pick Six page (same session) - Pick Six (interception
# return TDs only) was already a strict subset of Defensive TDs
# (interception + fumble return TDs combined), so once the combined stat
# existed there was no reason to keep the narrower one too. Forced Fumbles
# then replaced the original Fumble Recoveries page (same session, Chris's
# call) - forcing a fumble is a real, attributable defensive skill, while
# recovering one is largely positional luck (whichever body happens to be
# closest when it bounces), so Forced is the more meaningful individual
# stat of the two. Same pooled/computed workaround either way, just reading
# general idx 1 (fumblesForced) instead of idx 2 (fumblesRecovered). Data
# from ESPN's public stats-by-athlete API (site.web.api.espn.com) - no key
# required. Sibling app to nfl-offensive-leaders and
# nfl-special-teams-leaders, ported from
# mlb-offensive-leaders's own redesign (2026-09-15 review, PR #542) - same
# scorebook layout, a league/conference badge and football colors instead of
# baseball/league.
#
# Pages in this SDK are a fixed list declared in the manifest, so all 8
# category pages always exist.
#
# DESIGN. Same scorebook as mlb-offensive-leaders and nfl-offensive-leaders,
# on a black ground. The top row opens directly on the league badge - AFC
# red or NFC blue solid when a conference is picked, and the NFL shield
# (white rim, navy star band over red) for plain "NFL" with no conference
# filter, which reads as the league at a glance where a red/blue split pill
# didn't - then the stat in white and the season in gray. Under it, three
# rows: the rank in gray, a team badge, the player's name in white (initial
# and last name if the full name won't fit), and the number in white against the
# right edge. The badge is how a fan spots
# their team across a room: the team's code in its own two colors, like a
# helmet decal. Everything stays 6px inside both edges so the app reads as
# its own unit in the stream.

# id: [code, fill, ink]. Fill is the color the team wears most, ink its
# accent. A few inks are brightened from the team's literal secondary shade
# where it read as unreadable-dark text at 4x5 against this fill - Falcons
# (was black on dark red), Ravens (was black on purple), Panthers (was black
# on medium blue), Eagles (was black on dark green), Buccaneers (was dark
# pewter on dark red), and Bills/Patriots (both reds pushed brighter off
# navy) - the same category of fix mlb-offensive-leaders made for its own
# reds.
TEAMS = {
    22: ["ARI", "#A40227", "#FFFFFF"],  # Cardinals: red, white
    1: ["ATL", "#A71930", "#C4CED4"],   # Falcons: red, silver
    33: ["BAL", "#29126F", "#FFC72C"],  # Ravens: purple, gold
    2: ["BUF", "#00338D", "#FF4C4C"],   # Bills: navy, red
    29: ["CAR", "#0085CA", "#FFFFFF"],  # Panthers: blue, white
    3: ["CHI", "#0B1C3A", "#E64100"],   # Bears: navy, orange
    4: ["CIN", "#FB4F14", "#000000"],   # Bengals: orange, black
    5: ["CLE", "#472A08", "#FF3C00"],   # Browns: brown, orange
    6: ["DAL", "#002A5C", "#B0B7BC"],   # Cowboys: navy, silver
    7: ["DEN", "#0A2343", "#FC4C02"],   # Broncos: navy, orange
    8: ["DET", "#0076B6", "#BBBBBB"],   # Lions: blue, silver
    9: ["GB", "#204E32", "#FFB612"],    # Packers: green, gold
    34: ["HOU", "#C8102E", "#FFFFFF"],  # Texans: battle red, white (their navy is near-black on the panel)
    11: ["IND", "#003B75", "#FFFFFF"],  # Colts: navy, white
    30: ["JAX", "#007487", "#D7A22A"],  # Jaguars: teal, gold
    12: ["KC", "#E31837", "#FFB612"],   # Chiefs: red, gold
    13: ["LV", "#A5ACAF", "#000000"],   # Raiders: silver, black (flipped - a black badge vanishes on the panel)
    24: ["LAC", "#0080C6", "#FFC20E"],  # Chargers: powder blue, gold
    14: ["LAR", "#003594", "#FFD100"],  # Rams: royal blue, gold
    15: ["MIA", "#008E97", "#FC4C02"],  # Dolphins: aqua, orange
    16: ["MIN", "#4F2683", "#FFC62F"],  # Vikings: purple, gold
    17: ["NE", "#002A5C", "#FF4C57"],   # Patriots: navy, red
    18: ["NO", "#D3BC8D", "#000000"],   # Saints: gold, black
    19: ["NYG", "#003C7F", "#C9243F"],  # Giants: navy, red
    20: ["NYJ", "#115740", "#FFFFFF"],  # Jets: green, white
    21: ["PHI", "#06424D", "#A5ACAF"],  # Eagles: midnight green, silver
    23: ["PIT", "#FFB612", "#000000"],  # Steelers: gold, black (flipped, same reason)
    25: ["SF", "#AA0000", "#B3995D"],   # 49ers: red, gold
    26: ["SEA", "#002A5C", "#69BE28"],  # Seahawks: navy, action green
    27: ["TB", "#BD1C36", "#FFFFFF"],   # Buccaneers: red, white
    10: ["TEN", "#4495D2", "#001532"],  # Titans: light blue, navy
    28: ["WSH", "#5A1414", "#FFB612"],  # Commanders: burgundy, gold
}

TEAM_CONFERENCE = {
    33: "AFC", 2: "AFC", 4: "AFC", 5: "AFC", 7: "AFC", 34: "AFC", 11: "AFC",
    30: "AFC", 12: "AFC", 13: "AFC", 24: "AFC", 15: "AFC", 17: "AFC",
    20: "AFC", 23: "AFC", 10: "AFC",
    22: "NFC", 1: "NFC", 29: "NFC", 3: "NFC", 6: "NFC", 8: "NFC", 9: "NFC",
    14: "NFC", 16: "NFC", 18: "NFC", 19: "NFC", 21: "NFC", 25: "NFC",
    26: "NFC", 27: "NFC", 28: "NFC",
}

# ---------- palette & grid ----------

INK = "#F4F7FF"      # names, live numbers, the stat title
DIM = "#6E7A94"       # ranks, season, sub-lines
AMBER = "#E8B04A"     # the one attention state (feed offline)
GOLD = "#F2C14E"      # PLAYOFFS in the header
AFC_RED = "#D22D3A"
NFC_BLUE = "#2A66D9"

# The NFL shield, 9x8, filling the header row when no conference is picked:
# W the rim, S the stars, B the star band, R the lower field. The navy is
# lifted from the league's literal #013369, which vanished into the ground.
NFL_SHIELD = """
WWWWWWWWW
WBSBSBSBW
WBBBBBBBW
WRRRRRRRW
WRRRRRRRW
.WRRRRRW.
..WRRRW..
...WWW...
"""
NFL_SHIELD_W = 9
NFL_SHIELD_COLORS = {"W": "#FFFFFF", "S": "#FFFFFF", "B": "#2352B0", "R": "#D50A0A"}

PAD = 6              # scroll safe zone, both edges
RANK_W = 5           # one 5x7 digit
BADGE_X = PAD + RANK_W + 2  # 13
BADGE_H = 7
NAME_GAP = 2
GAP = 3              # blank px between a name and its value
ROW_Y = [9, 17, 25]  # three 7px rows, 1px apart, under the 8px header row
HEAD_Y = 2           # 4x5 header text, centered on the badge

# Names get one font per page, not per row: a long last name in 4x7 beside a
# short one in 5x7 reads as a mistake. 5x7 when every name on the page fits,
# else 4x7, then a hard clip.
NAME_FONTS = ["5x7", "4x7"]
VALUE_FONT = "5x7"

# ---------- name normalization ----------
# The bitmap fonts only cover plain ASCII - an accented letter renders as a
# stray symbol otherwise, so strip to the closest ASCII letter first.
ACCENT_MAP = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
    "Ñ": "N", "Ç": "C", "Ý": "Y",
    "á": "a", "à": "a", "â": "a", "ä": "a", "ã": "a", "å": "a",
    "é": "e", "è": "e", "ê": "e", "ë": "e",
    "í": "i", "ì": "i", "î": "i", "ï": "i",
    "ó": "o", "ò": "o", "ô": "o", "ö": "o", "õ": "o",
    "ú": "u", "ù": "u", "û": "u", "ü": "u",
    "ñ": "n", "ç": "c", "ý": "y",
}

def strip_accents(s):
    out = ""
    for i in range(len(s)):
        ch = s[i]
        out += ACCENT_MAP.get(ch, ch)
    return out

# ---------- color helpers ----------

HEX = "0123456789ABCDEF"

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def blend(a, b, pct):
    # pct% of a over b
    out = "#"
    for i in [1, 3, 5]:
        v = (int(a[i:i + 2], 16) * pct + int(b[i:i + 2], 16) * (100 - pct)) // 100
        out += HEX[v // 16] + HEX[v % 16]
    return out

# ---------- network (keyless) ----------
# ESPN's category names come back lowercase (e.g. "defensiveinterceptions")
# but the sort param needs camelCase for multi-word categories - a quirk of
# their API, confirmed by hand, not a typo.
#
# ESPN's byathlete endpoint also silently refuses to sort by anything in the
# "general" category (fumblesForced/fumblesRecovered/fumblesTouchdowns) - it
# returns 200 with an unsorted list no matter what casing is tried. There's
# no working sort key for those fields. Fumble Recoveries instead fetches a
# wide candidate pool from fields that DO sort correctly (tackles/sacks -
# virtually every player who recovers a fumble shows up near the top of one
# of those) and ranks that pool client-side using the recoveries number ESPN
# still hands back for every athlete regardless of sort field.

def fetch_leaders(ctx, sort_key, limit = 32):
    # One request per sort, sorted server-side. Each athlete is ~15 KB of
    # JSON, so about 60 fit under the 1 MB body cap.
    params = {
        "region": "us",
        "lang": "en",
        "contentorigin": "espn",
        "isqualified": "false",
        "seasontype": "2",
        "sort": sort_key + ":desc",
        "limit": str(limit),
    }
    sp = season_params(ctx)
    params["seasontype"] = sp[0]
    if sp[1] != "":
        params["season"] = sp[1]
    return http.get(
        "https://site.web.api.espn.com/apis/common/v3/sports/football/nfl/statistics/byathlete",
        params = params,
        # matches manifest.yaml's refresh - keep in sync
        ttl_seconds = 14400,
    )

def fetch_pool(ctx, specs):
    # specs: list of (sort_key, limit) tuples. Merges by athlete id so the
    # same player pulled in by two different sorts is only counted once.
    # Returns (ok, season, athletes) - ok is False only if every fetch
    # failed; season comes from whichever fetch succeeded first.
    seen = {}
    ok = False
    season = ""
    for spec in specs:
        resp = fetch_leaders(ctx, spec[0], limit = spec[1])
        if resp["status_code"] != 200 or resp["json"] == None:
            continue
        ok = True
        if season == "":
            season = season_of(resp)
        for a in resp["json"].get("athletes", []):
            aid = a.get("athlete", {}).get("id")
            if aid != None and aid not in seen:
                seen[aid] = a
    return ok, season, seen.values()

def season_of(resp):
    j = resp.get("json") or {}
    return str((j.get("requestedSeason") or j.get("currentSeason") or {}).get("displayName") or "")

def stat_total_str(a, category_name, idx):
    # Raw formatted value as ESPN sends it (e.g. "16.5" for a half-sack) -
    # used where the field is already sorted server-side, so this is only
    # for display and same-string tie detection, never arithmetic.
    for cat in a.get("categories", []):
        if cat.get("name") == category_name:
            totals = cat.get("totals", [])
            if idx < len(totals):
                return totals[idx]
    return ""

def stat_total_int(a, category_name, idx):
    # Only safe for fields that are always whole numbers (fumbles, TDs) -
    # used for the pooled/computed page, which needs to sort numerically
    # since ESPN can't sort this field itself. ESPN uses "-" (not "") as its
    # zero/no-stat placeholder here, so both must map to 0.
    v = stat_total_str(a, category_name, idx)
    return int(v) if v != "" and v != "-" else 0

def value_forced_fumbles(a):
    return stat_total_int(a, "general", 1)

# Total defensive touchdowns - a pick six plus a defensive fumble-return TD,
# added together. interceptionTouchdowns sorts fine on its own (Pick Six
# used it directly), but fumblesTouchdowns lives in the same "general"
# category ESPN won't sort by, so this needs the same pooled/computed path
# as Fumble Recoveries. Replaces the old standalone Pick Six page
# (2026-09-16, Chris's call) - Pick Six was already a strict subset of this
# total, so once the combined stat exists there's no reason to keep the
# narrower one around too.
def value_defensive_td(a):
    return stat_total_int(a, "defensiveinterceptions", 2) + stat_total_int(a, "general", 3)

def neg_value(entry):
    return -entry["value"]

def league_choice(ctx):
    v = ctx.inputs.get("league", "NFL")
    return v if v in ("NFL", "AFC", "NFC") else "NFL"

def conference_for(lg):
    return lg if lg in ("AFC", "NFC") else None

# ---------- stats setting & minimums ----------
# Regular season (the default) or Playoffs. NFL playoff stats come from a
# handful of games, so nothing switches on its own: a fan who wants them
# picks Playoffs (or adds the app twice). Playoffs shows the latest
# postseason - the January after a season - so in October it's last
# January's.

MODES = ["Regular season", "Playoffs"]

def mode_choice(ctx):
    v = ctx.inputs.get("stats", "Regular season")
    return v if v in MODES else "Regular season"

def playoff_season(ctx):
    # The 2026 season's playoffs are played in January 2027, so the latest
    # finished-or-running postseason always belongs to last calendar year's
    # season.
    return ctx.now.year - 1

def is_post(ctx):
    return mode_choice(ctx) == "Playoffs"

def season_params(ctx):
    # [ESPN seasontype, season ("" = the current one)].
    if is_post(ctx):
        return ["3", str(playoff_season(ctx))]
    return ["2", ""]

def total_of(a, category_name, idx):
    # One of an athlete's ESPN totals as a number (commas dropped); 0 when
    # missing or "-".
    for cat in a.get("categories", []):
        if cat.get("name") == category_name:
            totals = cat.get("totals", [])
            if idx < len(totals):
                s = str(totals[idx]).replace(",", "")
                ok = s != "" and s != "-"
                for i in range(len(s)):
                    if s[i] not in "0123456789.-":
                        ok = False
                if ok:
                    return float(s)
    return 0.0

def most_games(athletes):
    # Games behind the minimum: the most any player in this list has played
    # - in practice the clubs that haven't had their bye yet (or, in the
    # playoffs, have gone deepest). A club that just had its bye is counted
    # one game high, which a regular clears easily (starting quarterbacks
    # average twice the 14 attempts a game the bar asks for).
    g = 0
    for a in athletes:
        g = max(g, int(total_of(a, "general", 0)))
    return g

def bar_label(need, unit):
    # The minimum, rounded up, for the header: "42+ ATT".
    n = int(need) + (1 if need > int(need) else 0)
    return str(n) + "+ " + unit

# ---------- text helpers ----------

def clip(c, text, font, maxw):
    # Longest prefix that fits - nothing in the API clips on its own.
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for n in range(len(t), 0, -1):
        if c.text_width(t[:n], font) <= maxw:
            return t[:n]
    return ""

def page_font(c, strings, maxw):
    for f in NAME_FONTS:
        fits = True
        for s in strings:
            if c.text_width(s, f) > maxw:
                fits = False
                break
        if fits:
            return f
    return NAME_FONTS[-1]

def short_name(c, name, maxw):
    # A double-barrelled name that won't fit even in the smallest name font
    # keeps its last half whole rather than clipping mid-word.
    if "-" not in name or c.text_width(name, NAME_FONTS[-1]) <= maxw:
        return name
    parts = name.split("-")
    return parts[0][:1] + "-" + "-".join(parts[1:])

# ---------- chrome ----------

def league_chip(c, lg, x):
    # Opens the header. NFL (no conference picked) is the league's shield
    # across the full 8px header row; AFC/NFC are a 7px pill in their own
    # color: 4x5 text with 1px of fill above and below, 2px either side.
    if lg == "NFL":
        c.sprite(NFL_SHIELD, x, 0, legend = NFL_SHIELD_COLORS)
        return x + NFL_SHIELD_W
    w = c.text_width(lg, "4x5") + 4
    c.round_rect(x, 1, x + w - 1, 7, 1, fill = AFC_RED if lg == "AFC" else NFC_BLUE)
    c.text(lg, x + 2, HEAD_Y, font = "4x5", color = "white")
    return x + w

def header(c, lg, titles, season, post = False):
    # titles runs longest first; the header takes the first that fits beside
    # the badge and season. A playoff board adds PLAYOFFS in gold after it.
    right = c.width - PAD - 1
    x = league_chip(c, lg, PAD) + 3
    sw = 0
    if post:
        pw = c.text_width("PLAYOFFS", "4x5")
        c.text("PLAYOFFS", right, HEAD_Y, font = "4x5", color = GOLD, align = "right")
        sw = pw
        if season != "":
            sw += 4 + c.text_width(season, "4x5")
            c.text(season, right - pw - 4, HEAD_Y, font = "4x5", color = DIM, align = "right")
    elif season != "":
        sw = c.text_width(season, "4x5")
        c.text(season, right, HEAD_Y, font = "4x5", color = DIM, align = "right")
    room = right - sw - 3 - x
    title = clip(c, titles[-1], "4x5", room)
    for t in titles:
        if c.text_width(t, "4x5") <= room:
            title = t
            break
    c.text(title, x, HEAD_Y, font = "4x5", color = INK)

def message(c, head, sub, head_color):
    # Sits in the band under the header row, so a failed page still says
    # which stat and league/conference it is.
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

# ---------- team badges ----------

def team_style(team_id, team_abbr):
    t = TEAMS.get(team_id)
    if t:
        return t
    # A club this table doesn't know (a bad/missing id): a neutral badge with
    # whatever code ESPN handed us beats a blank.
    return [team_abbr.upper() or "?", "#444444", "#FFFFFF"]

def badge_width(c):
    # One width for every badge so the names start on one column: the widest
    # code (LAC/LAR/NYG/NYJ, 3 chars at 4x5) plus 2px of fill either side.
    w = 0
    for t in TEAMS.values():
        w = max(w, c.text_width(t[0], "4x5"))
    return w + 4

def badge(c, x, y, w, style):
    code, fill, ink = style[0], style[1], style[2]
    # Navy/black/brown fills vanish into the ground, so the dark ones get a
    # rim - a half-tone of their own ink, not gray, so e.g. a Raiders badge
    # stays black and silver out to its edge.
    edge = blend(ink, fill, 50) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + w - 1, y + BADGE_H - 1, 1, fill = fill, outline = edge)
    c.text(clip(c, code, "4x5", w - 2), x + w // 2, y + 1, font = "4x5", color = ink, align = "center")

# ---------- the leaderboard ----------

def display_name(c, full, last, room):
    # The longest form that fits in the main font: the full name, then
    # initial and last name, then the last name alone.
    full = strip_accents(full).upper()
    last = strip_accents(last).upper()
    forms = [full, full[:1] + ". " + last] if full != "" else []
    for f in forms:
        if c.text_width(f, NAME_FONTS[0]) <= room:
            return f
    return short_name(c, last, room)

def render_leaders(c, lg, titles, season, leaders, post = False):
    header(c, lg, titles, season, post)
    if len(leaders) == 0:
        # The stat just hasn't happened yet (no return TD in these playoffs,
        # nobody past a rate page's bar in Week 1) - not a missing feed.
        return message(c, "NONE SO FAR", "THESE PLAYOFFS" if post else "THIS SEASON", INK)

    rows = []
    for i in range(len(leaders)):
        e = leaders[i]
        rows.append({
            "rank": str(e["rank"]),
            "style": team_style(e["team_id"], e["team_abbr"]),
            "full": e.get("full", ""),
            "name": strip_accents(e["name"]).upper(),
            "value": str(e["value"]).upper(),
        })

    # Values right-aligned on the edge and measured first; the names get
    # what's left.
    right = c.width - PAD - 1
    bw = badge_width(c)
    name_x = BADGE_X + bw + NAME_GAP
    valw = 0
    for r in rows:
        valw = max(valw, c.text_width(r["value"], VALUE_FONT))
    room = right - valw - GAP - name_x + 1
    for r in rows:
        r["name"] = display_name(c, r["full"], r["name"], room)
    font = page_font(c, [r["name"] for r in rows], room)

    for i in range(len(rows)):
        r = rows[i]
        y = ROW_Y[i]
        c.text(clip(c, r["rank"], "5x7", RANK_W), PAD + RANK_W // 2, y, font = "5x7", color = DIM, align = "center")
        badge(c, BADGE_X, y, bw, r["style"])
        c.text(clip(c, r["name"], font, room), name_x, y, font = font, color = INK)
        c.text(clip(c, r["value"], VALUE_FONT, valw), right, y, font = VALUE_FONT, color = INK, align = "right")

def is_positive(v):
    # A zero-value entry means the stat hasn't actually happened for that
    # player yet, not a real ranked performance - early in a season (or for
    # a rare category) the real qualifiers can run out before len(ROW_Y)
    # does, and the rest of the row(s) should stay blank rather than fill
    # with padding (2026-09-16, Chris's call). v is either an int (a
    # computed page's value_fn) or ESPN's raw string total ("-"/"" for no
    # stat at all, otherwise a plain number, possibly decimal).
    if type(v) == "int":
        return v > 0
    s = str(v)
    if s == "" or s == "-":
        return False
    return float(s) > 0.0

def rank_candidates(candidates):
    # Competition-style ranking (1,2,3 or 1,2,2 on a tie), same as
    # mlb-offensive-leaders' use of MLB statsapi's own rank field - computed
    # here since neither the single-field sort nor the pooled/computed path
    # gets a ready-made rank from ESPN.
    leaders = []
    prev_value = None
    prev_rank = 0
    for entry in candidates:
        if not is_positive(entry["value"]):
            continue
        position = len(leaders) + 1
        rank = prev_rank if prev_value != None and entry["value"] == prev_value else position
        prev_value = entry["value"]
        prev_rank = rank
        entry["rank"] = rank
        leaders.append(entry)
        if len(leaders) >= len(ROW_Y):
            break
    return leaders

def draw_leaderboard(c, ctx, sort_key, category_name, idx, titles, limit = 32):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)
    post = mode_choice(ctx) == "Playoffs"

    resp = fetch_leaders(ctx, sort_key, limit = limit)
    if resp["status_code"] != 200 or resp["json"] == None:
        header(c, lg, titles, "", post)
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    athletes = resp["json"].get("athletes", [])
    candidates = []
    for a in athletes:
        athlete = a.get("athlete", {})
        team_id = athlete.get("teamId", -1)
        team_id = int(team_id) if team_id != None else -1
        if conf != None and TEAM_CONFERENCE.get(team_id) != conf:
            continue
        value = stat_total_str(a, category_name, idx)
        candidates.append({
            "full": athlete.get("displayName", ""),
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": team_id,
            "team_abbr": athlete.get("teamShortName", ""),
            "value": value,
        })
        if len(candidates) >= len(ROW_Y):
            break

    render_leaders(c, lg, titles, season_of(resp), rank_candidates(candidates), post)

def draw_leaderboard_computed(c, ctx, pool_specs, value_fn, titles):
    c.clear()
    lg = league_choice(ctx)
    conf = conference_for(lg)
    post = mode_choice(ctx) == "Playoffs"

    ok, season, pool = fetch_pool(ctx, pool_specs)
    if not ok:
        header(c, lg, titles, "", post)
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)

    candidates = []
    for a in pool:
        athlete = a.get("athlete", {})
        team_id = athlete.get("teamId", -1)
        team_id = int(team_id) if team_id != None else -1
        if conf != None and TEAM_CONFERENCE.get(team_id) != conf:
            continue
        candidates.append({
            "full": athlete.get("displayName", ""),
            "name": strip_accents(athlete.get("lastName", "?")),
            "team_id": team_id,
            "team_abbr": athlete.get("teamShortName", ""),
            "value": value_fn(a),
        })

    candidates = sorted(candidates, key = neg_value)[:len(ROW_Y)]
    render_leaders(c, lg, titles, season, rank_candidates(candidates), post)

# Wide pool for the one field ESPN won't let us sort by directly. Any player
# who forces a fumble is, in practice, already near the top of tackles or
# sacks - these two sorts together catch essentially the whole relevant pool.
# (60 by tackles is ~870 KB; each athlete is ~15 KB, and 150 ran past the
# 1 MB body cap, so that list never arrived.)
FORCED_FUMBLE_POOL = [("defensive.totalTackles", 60), ("defensive.sacks", 50)]

# Wide pool for Defensive TDs: interceptionTouchdowns sorts correctly on its
# own, so that sort alone already surfaces every pick-six scorer; unioned
# with the same tackles/sacks proxy pool FORCED_FUMBLE_POOL uses to also
# catch anyone whose only defensive TD came from a fumble return.
DEF_TD_POOL = [("defensiveInterceptions.interceptionTouchdowns", 32), ("defensive.totalTackles", 60), ("defensive.sacks", 50)]

# ---------- pages ----------

def tackles(c, ctx):
    # Same request as the Forced Fumbles / Defensive TDs pools.
    draw_leaderboard(c, ctx, "defensive.totalTackles", "defensive", 2, ["TOTAL TACKLES"], limit = 60)

def solo(c, ctx):
    draw_leaderboard(c, ctx, "defensive.soloTackles", "defensive", 0, ["SOLO TACKLES"])

def sacks(c, ctx):
    draw_leaderboard(c, ctx, "defensive.sacks", "defensive", 3, ["SACKS"], limit = 50)

def ints(c, ctx):
    draw_leaderboard(c, ctx, "defensiveInterceptions.interceptions", "defensiveinterceptions", 0, ["INTERCEPTIONS"])

def pd(c, ctx):
    draw_leaderboard(c, ctx, "defensive.passesDefended", "defensive", 6, ["PASSES DEFENDED", "PASS DEFENDED", "PASS DEF"])

def tfl(c, ctx):
    draw_leaderboard(c, ctx, "defensive.tacklesForLoss", "defensive", 5, ["TFL"])

def ff(c, ctx):
    draw_leaderboard_computed(c, ctx, FORCED_FUMBLE_POOL, value_forced_fumbles, ["FORCED FUMBLES", "FORCED FUM"])

def deftd(c, ctx):
    draw_leaderboard_computed(c, ctx, DEF_TD_POOL, value_defensive_td, ["DEFENSIVE TDS", "DEF TDS"])
