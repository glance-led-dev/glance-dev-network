# MLB Magic Numbers (128x32)
#
# Each division and wild-card race, if the season ended today: the leader's
# magic number to clinch, and every other team's elimination number (how
# many combined losses/leader-wins puts them out). Scoped to one league at
# a time (AL/NL dropdown input) rather than both - the 8-page platform
# limit doesn't stretch to 3 divisions + wild card for both leagues at
# once, and a single-league instance leaves headroom for whatever else
# gets added later. 7 pages: intro, a leaders summary (all 3 division
# leaders with their division AND playoff-clinch magic numbers side by
# side), 3 "chasers" pages (every non-division-leader in the league, pooled
# across all 3 divisions and sorted by record - not grouped by division),
# a home-field page (which division leader is on track for home field
# advantage through the whole league playoffs), and a bye page (which two
# of the three are on track for a first-round bye). Both of those last two
# are 3-team races among the leaders, not the simple 2-team cutoffs
# everything else here uses, and are each other's mirror image - see
# homefield_status and bye_status for the math. A dedicated wild-card
# standings page was here too but is dropped for now - easy to re-add
# later, same pattern as everything else.
#
# Data from MLB's own public Stats API (statsapi.mlb.com) - no key required.
# Sibling app to mlb-playoff-picture - same standings endpoint. Division
# magic/elimination numbers come precomputed (magicNumber/
# eliminationNumberDivision); the wild-card magic number doesn't (the API
# only ever precomputes a magic number for a division leader, never for a
# wild-card cutoff), so it's derived here with the same formula MLB itself
# uses - see SEASON_GAMES below for the verification against live data.

# Same source/format as mlb-playoff-picture (lists, not single hexes) - a
# couple of teams get a 2nd option so badge_color() has a genuinely dark
# choice to fall back to instead of a near-white or neon primary color.
TEAM_COLORS = {
    108: ["#BA0021"],  # LAA
    109: ["#A71930"],  # AZ
    110: ["#DF4601"],  # BAL
    111: ["#BD3039"],  # BOS
    112: ["#0E3386"],  # CHC
    113: ["#C6011F"],  # CIN
    114: ["#E31937"],  # CLE
    115: ["#333366", "#C4CED4"],  # COL
    116: ["#FA4616"],  # DET
    117: ["#F4911E"],  # HOU
    118: ["#004687"],  # KC
    119: ["#005A9C"],  # LAD
    120: ["#AB0003"],  # WSH
    121: ["#FF5910"],  # NYM
    133: ["#EFB21E"],  # ATH
    134: ["#FDB827"],  # PIT
    135: ["#FFC425"],  # SD
    136: ["#005C5C"],  # SEA
    137: ["#FD5A1E"],  # SF
    138: ["#C41E3A"],  # STL
    139: ["#8FBCE6"],  # TB
    140: ["#003278"],  # TEX
    141: ["#134A8E"],  # TOR
    142: ["#D31145"],  # MIN
    143: ["#E81828"],  # PHI
    144: ["#CE1141"],  # ATL
    145: ["#27251F"],  # CWS
    146: ["#00A3E0"],  # MIA
    147: ["#0C2340"],  # NYY
    158: ["#12284B"],  # MIL
}

# division.id per MLB Stats API, keyed by league then by page name.
DIVISION_IDS = {
    "AL": {"east": 201, "central": 202, "west": 200},
    "NL": {"east": 204, "central": 205, "west": 203},
}

LEAGUE_IDS = {"AL": 103, "NL": 104}

# Standard 162-game season - the magic/elimination number formula is
# (season games + 1) - leaderWins - rivalLosses, where "rival" is whoever
# the number is being computed against, not the team it belongs to.
# Verified against live data both directions: matches the API's own AL East
# magicNumber exactly (163 - Rays' 75 wins - 2nd-place Yankees' 55 losses =
# 33), and independently matches a live wildCardEliminationNumber (163 -
# WC3 Orioles' 61 wins - WC4 Rangers' 64 losses = 38, exactly what the API
# reports as Rangers' own wildCardEliminationNumber) - same arithmetic,
# just read from whichever side of the cutoff you're standing on.
SEASON_GAMES = 162

CLINCH_COLOR = "#2ECC71"
MAGIC_COLOR = "#2ECC71"
ELIM_COLOR = "#E74C3C"
PLAYOFF_COLOR = "#3498DB"
TRAGIC_COLOR = "#F39C12"

# A magic/tragic number this low means it's basically about to happen - it
# looked identical to a lazy mid-teens number before this. See draw_status.
URGENT_THRESHOLD = 5

# The intro page's sparkle color, reused for the tiny "IN"/"WON" glint in
# draw_status - the one purely decorative gold accent in the app, so it
# never gets mistaken for a status color like CLINCH/ELIM/TRAGIC.
SPARKLE_COLOR = "#FFD700"

# A darker red than ELIM_COLOR, used only for an urgent tragic number's own
# digits - ELIM_COLOR is tuned for white/black text on TOP of it as a badge
# background, not for reading as text against the gold urgent badge itself.
URGENT_TRAGIC_TEXT = "#B71C1C"

# ---------- color helpers (ported from mlb-playoff-picture) ----------

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def badge_color(team_id):
    # Darkest of the team's colors - full-row badges carry white text by
    # default, so a near-white option (e.g. LAD's white) would be
    # unreadable; the darkest color gives the best contrast while still
    # reading as the team's color.
    colors = TEAM_COLORS.get(team_id, ["#444444"])
    best = colors[0]
    best_brightness = brightness(best)
    for color in colors:
        b = brightness(color)
        if b < best_brightness:
            best = color
            best_brightness = b
    return best

def text_color_for(team_id):
    # badge_color already picks each team's darkest option, but a few teams
    # (TB's Columbia Blue, HOU/ATH/PIT/SD's gold/orange) have no dark option
    # at all - white text on those reads weak. Fall back to black above this
    # brightness instead of assuming white always works.
    if brightness(badge_color(team_id)) > 150:
        return "black"
    return "white"

# ---------- input ----------

def league_choice(ctx):
    v = ctx.inputs.get("league", "AL")
    if v == None or v not in LEAGUE_IDS:
        return "AL"
    return v

# ---------- network (keyless) ----------

def fetch_standings(standings_type, season):
    return http.get(
        "https://statsapi.mlb.com/api/v1/standings",
        params = {"leagueId": "103,104", "season": str(season), "standingsTypes": standings_type},
        ttl_seconds = 7200,
    )

def fetch_teams():
    return http.get(
        "https://statsapi.mlb.com/api/v1/teams",
        params = {"sportId": "1"},
        ttl_seconds = 2592000,
    )

def team_nickname_map():
    resp = fetch_teams()
    m = {}
    if resp["status_code"] != 200:
        return m
    for t in resp["json"].get("teams", []):
        m[t["id"]] = t.get("teamName", "")
    return m

# ---------- standings ----------

def sort_by_division_rank(teams):
    # Small manual sort (<=5 items) - Starlark has no sorted(..., key=...).
    # Don't trust teamRecords' own array order for this - it happened to
    # match divisionRank in earlier testing, but that's not a documented
    # guarantee from the API, just what one data pull looked like.
    items = list(teams)
    n = len(items)
    for i in range(n):
        for j in range(n - 1 - i):
            r1 = int(items[j].get("divisionRank", "999"))
            r2 = int(items[j + 1].get("divisionRank", "999"))
            if r1 > r2:
                items[j], items[j + 1] = items[j + 1], items[j]
    return items

def division_block(records, division_id):
    for block in records:
        if block.get("division", {}).get("id") == division_id:
            return sort_by_division_rank(block.get("teamRecords", []))
    return []

def wildcard_block(records, league_id):
    for block in records:
        if block.get("league", {}).get("id") == league_id:
            # Already excludes division winners and sorts by wildCardRank
            # ascending (see mlb-playoff-picture's wildcard_top3, same block).
            return block.get("teamRecords", [])
    return []

# The API only includes "magicNumber" at all for the division's current
# leader - everyone else gets an eliminationNumberDivision instead (the
# same stat sports pages print as "E#"). "ELIM" (no countdown left) renders
# as a red badge via draw_status, not text, once a team's actually out.
def magic_status(t):
    # Only ever called by the leaders page, so "WON" (division-specific,
    # since this is the DIV column) is safe to hardcode here rather than
    # needing a page-level override like playoff_magic's "IN" does below.
    if t.get("divisionChamp", False):
        return "WON", CLINCH_COLOR
    magic = t.get("magicNumber")
    if magic != None:
        return str(magic), MAGIC_COLOR
    elim = t.get("eliminationNumberDivision", "-")
    if elim == "E":
        return "ELIM", ELIM_COLOR
    if elim in ("-", "", None):
        return "-", "gray"
    return str(elim), "gray"

# The "tragic number" (the elimination number, read as bad news instead of
# good) is the same wildCardEliminationNumber field already used elsewhere
# for the "E" badge - this only fires before that, while it's still a
# countdown rather than "E". When it's the closer of the two outcomes, it's
# the more newsworthy number: showing a hopeful magic number for a team
# that's actually closer to being eliminated than to clinching is
# misleading. magic_color is whichever color the caller would otherwise
# have used for the plain magic number (division pages and the wild-card
# page use different ones), so this stays neutral about who's calling it.
def magic_or_tragic(t, magic, magic_color):
    tragic = t.get("wildCardEliminationNumber", "-")
    if tragic in ("-", "", None, "E"):
        return str(magic), magic_color
    tragic_val = int(tragic)
    if tragic_val < magic:
        return str(tragic_val), TRAGIC_COLOR
    return str(magic), magic_color

# A division leader's OWN magic number (from magic_status) only covers the
# division route. This is their fallback route: how close they are to
# clinching at least a wild-card spot instead, racing their wins against
# that league's current wild-card rank-4 (same rank-4-rival formula the
# now-removed dedicated wild-card page used). "clinched" (not divisionChamp)
# is checked here since a team can lock up a playoff spot via wild card
# without having clinched the division outright.
# Also used for the division pages' non-leader teams - which meant this
# needed its own elimination check (wildCardEliminationNumber == "E"), not
# just clinched-or-magic-number: a team genuinely out of the wild-card race
# would otherwise still get a plausible-looking countdown from the formula
# below, since that formula alone has no way to represent "already out."
# Deliberately NOT given the tragic-number treatment below - this is also
# what the leaders page calls directly, which should stay pure magic-number.
def playoff_magic(t, wc_teams):
    if t.get("clinched", False):
        return "IN", CLINCH_COLOR
    if t.get("wildCardEliminationNumber", "-") == "E":
        return "ELIM", ELIM_COLOR
    if len(wc_teams) < 4:
        return "-", "gray"
    wins = t.get("wins", 0)
    rival_losses = wc_teams[3].get("losses", 0)
    magic = SEASON_GAMES + 1 - wins - rival_losses
    if magic <= 0:
        return "IN", CLINCH_COLOR
    return str(magic), PLAYOFF_COLOR

# The division pages' wrapper around playoff_magic - same clinch/eliminated
# terminal states pass straight through, but a plain magic number gets
# checked against the tragic number too. Kept separate from playoff_magic
# itself so the leaders page (which calls that directly) is unaffected.
def playoff_or_tragic(t, wc_teams):
    text, color = playoff_magic(t, wc_teams)
    if text == "IN" or text == "ELIM" or text == "-":
        return text, color
    return magic_or_tragic(t, int(text), color)

def draw_status(c, x_right, y, text, color, font):
    # ELIM/IN/WON render as filled badges (red/green), not colored text -
    # much more visually distinct at a glance than plain-colored text would
    # be. "WON" is the leaders page's DIV-column and page-2-only relabel of
    # "IN" (see draw_leaders_page and magic_status). A plain number gets the
    # same gold badge as the "IN"/"WON" glint once it's down to
    # URGENT_THRESHOLD or less - the countdown isn't over yet, but it's
    # close enough to be the most newsworthy thing on the row - except the
    # digits themselves stay green/red (whichever terminal color it's headed
    # for), so the row previews its own outcome instead of just glowing gold
    # generically. "-" (no data / not applicable) is the only case that
    # stays plain text.
    urgent_text_color = None
    if text == "ELIM":
        bg = ELIM_COLOR
    elif text == "IN" or text == "WON":
        bg = CLINCH_COLOR
    elif text not in ("-", "", None) and int(text) <= URGENT_THRESHOLD:
        bg = SPARKLE_COLOR
        urgent_text_color = URGENT_TRAGIC_TEXT if color == TRAGIC_COLOR else CLINCH_COLOR
    else:
        c.text(text, x_right, y, font = font, color = color, align = "right")
        return
    w = c.text_width(text, font)
    tc = urgent_text_color if urgent_text_color != None else ("white" if brightness(bg) < 150 else "black")
    badge_bottom = y + 6 if font == "4x7" else y + 4
    c.rect(x_right - w - 1, y - 1, x_right, badge_bottom, fill = bg)
    c.text(text, x_right, y, font = font, color = tc, align = "right")

    # A tiny gold glint in the badge's own top-right corner (never outside
    # its own pixels, so it's safe under any row spacing) celebrates an
    # actual clinch - "IN"/"WON" only, not the merely-close preview above.
    if text == "IN" or text == "WON":
        c.pixel(x_right, y - 1, SPARKLE_COLOR)
        c.pixel(x_right - 1, y - 1, SPARKLE_COLOR)

def draw_page_edges(c, left = True):
    # A 1px light line marking a clean page break while the kiosk scrolls
    # horizontally between pages. Only page 1 (intro) draws a left edge too -
    # otherwise a page's right border and the next page's left border would
    # double up into a 2px-thick seam at every transition.
    if left:
        c.rect(0, 0, 0, c.height - 1, fill = "gray")
    c.rect(c.width - 1, 0, c.width - 1, c.height - 1, fill = "gray")

def fit_text(c, text, font, maxw):
    # Truncates on actual pixel width, not a guessed character count - long
    # nicknames like "Diamondbacks" would otherwise run into the numbers.
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i] + "..."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return "..."

# Same two-column x-positions as the leaders page's DIV/WC (90 and 125) -
# "like it is on page 2", per request. Team color stops at the same 80 too.
TWO_COL_START = 80

def draw_wc_row(c, y, team_id, nickname, wc_text, wc_color, font = "4x5"):
    # Same single value as before (playoff_or_tragic gives one result per
    # team), but now split across two columns instead of one combined
    # "WC/E#" - a magic number or IN lands in the WC column with a dash
    # in E#, and a tragic number or ELIM lands in E# with a dash in WC.
    # They're mutually exclusive, never both filled.
    # 4x5 and 4x7 share identical glyph widths (only height differs), so
    # callers with vertical room to spare (homefield/bye, 3 rows on an 8px
    # step) can pass font="4x7" for bigger text; the tightly-packed chasers
    # pages (4 rows on a 6px step) stay at the 4x5 default.
    row_bottom = y + 6 if font == "4x7" else y + 4
    tc = text_color_for(team_id)
    c.rect(0, y - 1, TWO_COL_START - 1, row_bottom, fill = badge_color(team_id))
    nick = fit_text(c, nickname.upper(), font, TWO_COL_START - 10)
    c.text(nick, 3, y, font = font, color = tc, align = "left")

    if wc_text == "ELIM" or wc_color == TRAGIC_COLOR:
        draw_status(c, 90, y, "-", "gray", font)
        draw_status(c, 125, y, wc_text, wc_color, font)
    else:
        draw_status(c, 90, y, wc_text, wc_color, font)
        draw_status(c, 125, y, "-", "gray", font)

def sort_by_pct(teams):
    # Small manual sort - Starlark has no sorted(..., key=...). Winning
    # percentage, not raw win count - teams don't all have the same number
    # of games played, so pct is the fair "record" comparison across
    # divisions (wins alone would bias toward whoever's played more games).
    items = list(teams)
    n = len(items)
    for i in range(n):
        for j in range(n - 1 - i):
            p1 = float(items[j].get("winningPercentage", "0"))
            p2 = float(items[j + 1].get("winningPercentage", "0"))
            if p1 < p2:
                items[j], items[j + 1] = items[j + 1], items[j]
    return items

def league_leaders(div_records, league):
    ids = DIVISION_IDS[league]
    leaders = []
    for key in ("east", "central", "west"):
        teams = division_block(div_records, ids[key])
        if teams:
            leaders.append(teams[0])  # teamRecords is already divisionRank-sorted
    return leaders

def league_chasers(div_records, league):
    # Every non-division-leader in the league, pooled across all 3
    # divisions and sorted by record - the leaders page already covers
    # each division's #1 team, so these pages are everyone else.
    ids = DIVISION_IDS[league]
    combined = []
    for key in ("east", "central", "west"):
        combined += division_block(div_records, ids[key])[1:]
    return sort_by_pct(combined)

# Home field advantage throughout the league's playoffs goes to whichever
# division leader ends up with the best overall record - a genuine 3-team
# race among the leaders, not a fixed 2-team cutoff like division or wild
# card, and not something the API precomputes at all. Still built from the
# same validated magic/elimination formula, just applied against BOTH other
# leaders: a team needs to out-finish each of them individually to lock up
# the #1 seed, so its magic number is the LARGER of the two pairwise magic
# numbers (the harder of the two to secure) - once that clears, the easier
# one has necessarily cleared too, since the team's own wins count toward
# both simultaneously while each rival's losses only help their own pairing.
# Symmetrically, it's eliminated as soon as EITHER single pairing goes to
# zero, so its elimination number is the SMALLER of the two. Verified
# against live AL data before wiring this in: the current leader (best
# record) gets a plain magic number, while the other two - both plausibly
# closer to being knocked out of the race than to winning it - correctly
# get tragic numbers instead.
def homefield_status(x, others):
    x_wins = x.get("wins", 0)
    x_losses = x.get("losses", 0)
    magics = [SEASON_GAMES + 1 - x_wins - o.get("losses", 0) for o in others]
    elims = [SEASON_GAMES + 1 - o.get("wins", 0) - x_losses for o in others]
    magic = max(magics)
    elim = min(elims)
    if magic <= 0:
        return "IN", CLINCH_COLOR
    if elim <= 0:
        return "ELIM", ELIM_COLOR
    if elim < magic:
        return str(elim), TRAGIC_COLOR
    return str(magic), MAGIC_COLOR

# First-round byes go to the TOP 2 of the 3 division leaders (2022+ format:
# #1/#2 seed get a bye, #3 hosts a Wild Card series) - the mirror image of
# homefield_status's math, not the same computation despite both being
# 3-team races among the leaders. Home field needs to out-finish BOTH other
# leaders (magic = MAX, elim = MIN of the pairwise numbers); a bye only
# needs to out-finish AT LEAST ONE of them (missing a bye means finishing
# last among the 3), so here it flips: magic = MIN (only the easier of the
# two pairwise races needs to be secured), elim = MAX (both pairwise races
# have to fail before a bye is truly out of reach). Verified against live
# AL data and 3 synthetic cases (two clear leaders both already "IN" with
# the straggler "ELIM", a 3-way dead heat, and a team mathematically unable
# to avoid finishing last) before wiring this in.
def bye_status(x, others):
    x_wins = x.get("wins", 0)
    x_losses = x.get("losses", 0)
    magics = [SEASON_GAMES + 1 - x_wins - o.get("losses", 0) for o in others]
    elims = [SEASON_GAMES + 1 - o.get("wins", 0) - x_losses for o in others]
    magic = min(magics)
    elim = max(elims)
    if magic <= 0:
        return "IN", CLINCH_COLOR
    if elim <= 0:
        return "ELIM", ELIM_COLOR
    if elim < magic:
        return str(elim), TRAGIC_COLOR
    return str(magic), MAGIC_COLOR

def draw_chasers_page(c, ctx, league, page_index, label):
    # 10 non-leader teams per league, 4 per page - pages 3/4/5 are just
    # sequential chunks of one combined, record-sorted list, not tied to
    # any particular division anymore.
    c.fill("black")

    div_resp = fetch_standings("regularSeason", ctx.now.year)
    wc_resp = fetch_standings("wildCard", ctx.now.year)
    if div_resp["status_code"] != 200 or wc_resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        draw_page_edges(c, left = False)
        return

    chasers = league_chasers(div_resp["json"].get("records", []), league)
    start = page_index * 4
    teams = chasers[start:start + 4]
    if not teams:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        draw_page_edges(c, left = False)
        return

    wc_teams = wildcard_block(wc_resp["json"].get("records", []), LEAGUE_IDS[league])[:5]
    nicknames = team_nickname_map()

    c.rect(0, 0, 127, 6, fill = "white")
    c.text(label, 2, 1, font = "4x5", color = "black", align = "left")
    c.text("WC", 90, 1, font = "picopixel", color = "black", align = "right")
    c.text("E#", 125, 1, font = "picopixel", color = "black", align = "right")

    y = 8
    for t in teams:
        team_id = t.get("team", {}).get("id", -1)
        wc_text, wc_color = playoff_or_tragic(t, wc_teams)
        draw_wc_row(c, y, team_id, nicknames.get(team_id, "???"), wc_text, wc_color)
        y += 6
    draw_page_edges(c, left = False)

def draw_leaders_page(c, ctx, league, label):
    # Only 3 rows here (one per division leader), instead of the 5-team
    # squeeze the other pages need - room for 4x5 instead of picopixel, and
    # for two number columns per row instead of one.
    c.fill("black")

    div_resp = fetch_standings("regularSeason", ctx.now.year)
    wc_resp = fetch_standings("wildCard", ctx.now.year)
    if div_resp["status_code"] != 200 or wc_resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        draw_page_edges(c, left = False)
        return

    div_records = div_resp["json"].get("records", [])
    wc_teams = wildcard_block(wc_resp["json"].get("records", []), LEAGUE_IDS[league])[:5]

    leaders = league_leaders(div_records, league)

    if len(leaders) < 3:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        draw_page_edges(c, left = False)
        return

    nicknames = team_nickname_map()

    c.rect(0, 0, 127, 6, fill = "white")
    c.text(label, 2, 1, font = "4x5", color = "black", align = "left")
    c.text("DIV", 90, 1, font = "picopixel", color = "black", align = "right")
    c.text("WC", 125, 1, font = "picopixel", color = "black", align = "right")

    # Rows go WC magic number low to high - whoever's closest to clinching a
    # playoff spot (not necessarily the division) leads the page. Already
    # clinched ("IN") sorts first (nothing left to chase); the "-"/"ELIM"
    # cases shouldn't come up for an actual division leader, but sort last
    # defensively rather than crashing on int(text) if they ever did.
    def wc_sort_key(text):
        if text == "IN":
            return -1
        if text in ("-", "ELIM"):
            return 999999
        return int(text)

    rows = []
    for t in leaders:
        team_id = t.get("team", {}).get("id", -1)
        div_text, div_color = magic_status(t)
        playoff_text, playoff_color = playoff_magic(t, wc_teams)
        rows.append((wc_sort_key(playoff_text), team_id, div_text, div_color, playoff_text, playoff_color))

    # Small manual sort (<=3 items) - Starlark has no sorted(..., key=...).
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            if rows[j][0] > rows[j + 1][0]:
                rows[j], rows[j + 1] = rows[j + 1], rows[j]

    y = 9
    for _key, team_id, div_text, div_color, playoff_text, playoff_color in rows:
        # Team color stops before the DIV column, not the whole row - so
        # both number columns sit on black instead of competing with the
        # team's own color. text_color_for keeps the nickname readable
        # against whichever color the colored portion turns out to be.
        c.rect(0, y - 1, TWO_COL_START - 1, y + 6, fill = badge_color(team_id))
        tc = text_color_for(team_id)

        nick = fit_text(c, nicknames.get(team_id, "???").upper(), "4x7", TWO_COL_START - 10)
        c.text(nick, 5, y, font = "4x7", color = tc, align = "left")

        draw_status(c, 90, y, div_text, div_color, "4x7")

        # playoff_magic is shared with the chasers pages (via
        # playoff_or_tragic), which should keep "IN" - only relabel it here.
        if playoff_text == "IN":
            playoff_text = "WON"
        draw_status(c, 125, y, playoff_text, playoff_color, "4x7")

        y += 8
    draw_page_edges(c, left = False)

# A magic-side (non-tragic) team isn't remotely in elimination danger, so it
# sorts above any real E# - "IN" (already clinched, no elimination number
# even applies) sorts above that, and "ELIM" sorts to the very bottom below
# every real number. Only used for the home-field page (sort_by_e_number) -
# the bye page keeps the simpler two-bucket order below.
def e_number_sort_key(text, color):
    if text == "IN":
        return 999999
    if text == "ELIM":
        return -1
    if color == TRAGIC_COLOR:
        return int(text)
    return 999998

# Shared by the home-field and bye pages - both are "3 division leaders,
# ranked by a pairwise magic/tragic computation" with the same visual
# layout (renders through draw_wc_row, same as the chasers pages), the only
# difference is which status_fn does the ranking (homefield_status vs
# bye_status) and what the left column header says.
def draw_leader_race_page(c, ctx, league, label, col_label, status_fn, sort_by_e_number = False):
    c.fill("black")

    div_resp = fetch_standings("regularSeason", ctx.now.year)
    if div_resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        draw_page_edges(c, left = False)
        return

    leaders = league_leaders(div_resp["json"].get("records", []), league)
    if len(leaders) < 3:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        draw_page_edges(c, left = False)
        return

    nicknames = team_nickname_map()

    c.rect(0, 0, 127, 6, fill = "white")
    c.text(label, 2, 1, font = "4x5", color = "black", align = "left")
    c.text(col_label, 90, 1, font = "picopixel", color = "black", align = "right")
    c.text("E#", 125, 1, font = "picopixel", color = "black", align = "right")

    if sort_by_e_number:
        # Home field: E# high to low - safest team (or already-clinched)
        # first, most endangered (or already eliminated) last.
        rows = []
        for i in range(len(leaders)):
            x = leaders[i]
            others = [leaders[j] for j in range(len(leaders)) if j != i]
            team_id = x.get("team", {}).get("id", -1)
            text, color = status_fn(x, others)
            rows.append((e_number_sort_key(text, color), team_id, nicknames.get(team_id, "???"), text, color))
        n = len(rows)  # small manual sort (<=3 items) - Starlark has no sorted(..., key=...)
        for i in range(n):
            for j in range(n - 1 - i):
                if rows[j][0] < rows[j + 1][0]:
                    rows[j], rows[j + 1] = rows[j + 1], rows[j]
        rows = [(team_id, nickname, text, color) for _key, team_id, nickname, text, color in rows]
    else:
        # Bye: whichever leader(s) sit on the magic-number side go on top,
        # not whichever division happened to be listed first.
        rows = []
        tragic_rows = []
        for i in range(len(leaders)):
            x = leaders[i]
            others = [leaders[j] for j in range(len(leaders)) if j != i]
            team_id = x.get("team", {}).get("id", -1)
            text, color = status_fn(x, others)
            row = (team_id, nicknames.get(team_id, "???"), text, color)
            if text == "ELIM" or color == TRAGIC_COLOR:
                tragic_rows.append(row)
            else:
                rows.append(row)
        rows += tragic_rows

    y = 9
    for team_id, nickname, text, color in rows:
        draw_wc_row(c, y, team_id, nickname, text, color, font = "4x7")
        y += 8
    draw_page_edges(c, left = False)

def draw_homefield_page(c, ctx, league, label):
    draw_leader_race_page(c, ctx, league, label, "HFA", homefield_status, sort_by_e_number = True)

def draw_bye_page(c, ctx, league, label):
    draw_leader_race_page(c, ctx, league, label, "BYE", bye_status)

# ---------- pages ----------

def intro(c, ctx):
    league = league_choice(ctx)
    c.clear()
    # "MAGIC #" used to render as just "MAGIC" - the 7x12 title font has no
    # "#" glyph at all, so it silently vanished. Spelling it out sidesteps
    # that instead of hunting for a font that happens to have the glyph.
    c.text("MAGIC NUMBERS".upper(), 64, 3, font = "7x12", color = "white", align = "center")

    # A little sparkle in the corners and flanking the divider - nods at the
    # "MAGIC" in the title without competing with it; same gold as the "IN"/
    # "WON" glint elsewhere, so it reads as pure decoration, not another
    # status color.
    c.rect(6, 1, 6, 1, fill = SPARKLE_COLOR)
    c.rect(121, 2, 121, 2, fill = SPARKLE_COLOR)
    c.rect(14, 16, 14, 16, fill = SPARKLE_COLOR)
    c.rect(113, 16, 113, 16, fill = SPARKLE_COLOR)

    c.line(20, 18, 108, 18, "#555555")
    c.text((league + " DIVISION & WILD CARD").upper(), 64, 21, font = "4x5", color = "gray", align = "center")
    c.text("UPDATES EVERY 2 HOURS".upper(), 64, 27, font = "picopixel", color = "#555555", align = "center")
    draw_page_edges(c, left = True)

def leaders(c, ctx):
    league = league_choice(ctx)
    draw_leaders_page(c, ctx, league, league + " LEADERS")

def chasers1(c, ctx):
    league = league_choice(ctx)
    draw_chasers_page(c, ctx, league, 0, league + " CHASERS")

def chasers2(c, ctx):
    league = league_choice(ctx)
    draw_chasers_page(c, ctx, league, 1, league + " CHASERS")

def chasers3(c, ctx):
    league = league_choice(ctx)
    draw_chasers_page(c, ctx, league, 2, league + " CHASERS")

def homefield(c, ctx):
    league = league_choice(ctx)
    draw_homefield_page(c, ctx, league, league + " HOME FIELD")

def bye(c, ctx):
    league = league_choice(ctx)
    draw_bye_page(c, ctx, league, league + " BYE")
