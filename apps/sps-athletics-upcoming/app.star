# SPS Upcoming Games — St. Paul's School (Big Red), every team: Varsity,
# JV, and JV-B/Thirds.
#
# This week's games, full stop — schedule first, then the score once it's
# posted, in the SAME slot: a game doesn't move anywhere when it's played,
# it just updates in place (see render_upcoming_slot). Companion app to
# sps-athletics-results, which covers the same games but stays strictly
# score-only and keeps them up for the whole week (a dedicated "what
# happened" view, for anyone who only wants that); this app is the "what's
# happening this week, start to finish" one. Splitting into two apps this
# way, rather than one page per day per app, is what makes room for each to
# get a full week's worth of pages instead of fighting over one shared set
# of 8 (see the page-count note below).
#
# A page is a SLOT, not a fixed weekday: there's no way for a page to remove
# itself from the device's rotation (the manifest's `pages:` list is a fixed
# set the device always cycles through, and a "no game this day" placeholder
# on every empty weekday would defeat the point of the app). So instead,
# week_matches() gathers every one of this week's games — played or not —
# for every day that actually has one, skipping empty days entirely, and
# each of the 7 slots picks one modulo that count. A light week (say 3 real
# games) cycles those 3 across all 7 slots rather than padding with blanks;
# a heavy week just shows 7 different games. Only a genuinely empty week
# (zero games scheduled at all) falls back to an explicit empty state.
#
# Data comes from ONE combined calendar endpoint that covers every sport at
# every level in a single response — athletics.sps.edu/services/
# responsive-calendar.ashx?type=month&sport=0&location=all&date=<M/D/Y> —
# discovered by watching the site's own "Composite Schedule" page make this
# exact call. That's a much better source than scraping each team's
# individual plain-text feed (this app's history did that first): it's
# structured JSON (http.get decodes it for us via resp["json"], no hand-
# rolled column parser needed), it carries real ISO dates (no guessing which
# calendar year a "Nov 30" belongs to for a season that spans New Year's),
# and — critically — the whole app only ever needs to fetch TWO of these
# (this month + next month) no matter how many teams or pages it has,
# because every team's games are already in that one response.
#
# That last point isn't just an optimization, it's a real correctness fix:
# gdn/starhost/http_client.py caps a render at 8 *uncached* http.get calls
# (MAX_REQUESTS_PER_RUN), and while a real device render is one page per
# call with its own fresh budget (server.py's /render endpoint), Glance Dev
# Studio's live preview and `write_previews` (required before `gdn submit`)
# render every page of the app together, sharing ONE budget — see
# gdn/preview.py, which calls run_star_app_sandboxed with no `only_page`. An
# earlier version of this app fetched one schedule per sport (32+ separate
# URLs across its pages) and blew that shared limit the moment Studio tried
# to preview it, even though it worked fine as individual `gdn render
# --page N` calls. Fetching everything through two shared URLs instead means
# every page hits the same two URLs, the second page onward gets a
# same-process cache hit for free, and the whole app — Studio preview,
# catalog previews, and the real device — stays under the cap regardless of
# how many teams it covers.
#
# Page count is a separate, harder ceiling: gdn/data/scene.schema.json caps
# every app at 8 pages total ("pages": {"maxItems": 8}), platform-wide. 7 of
# them are the game slots above; the 8th is a "this week" cover page. On
# Monday, `ctx.now`'s week rolls over and every slot re-targets the new
# week's dates automatically — no explicit "reset" logic needed anywhere in
# this file.

BIG_RED = "#c72035"
INK = "white"
DIM = "gray"
OFFLINE = "#3C4043"
ICON = 24  # SPS logo size in px; panel is 32 tall, header bar takes 9
OPP_ICON = 22  # opponent logo — its name sits beside it, not underneath

CALENDAR_URL = "https://athletics.sps.edu/services/responsive-calendar.ashx"

FEED_HEADERS = {
    # athletics.sps.edu's WAF soft-blocks the default "python-requests" UA
    # with a 404 — confirmed by comparing curl (200) against a bare
    # requests.get() (404) against the identical URL. A browser-shaped UA
    # gets the real feed.
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
                  "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
}

# opponent name (exactly as this feed prints it, already .strip()-ed) ->
# logos/<name>.png slug. Built by pulling a full year of this combined feed
# and matching every opponent that shows up — across all levels, not just
# Varsity — against the actual opponent-logo art we were given. Anything not
# in here (a rare scrimmage opponent we have no art for, or a meet/
# invitational/regatta name that was never a single opponent to begin with)
# just renders as text instead of an image — same code path, no special-
# casing needed.
OPPONENT_LOGO = {
    "Andover": "andover",
    "Austin Prep": "austin-prep",
    "Austin Preparatory School": "austin-prep",
    "Avon Old Farms": "avon-old-farms",
    "BC High": "bc-high",
    "Belmont Hill": "belmont-hill",
    "Belmont Hill School": "belmont-hill",
    "Berkshire": "berkshire-school",
    "Berkshire School": "berkshire-school",
    "Berwick": "berwick-academy",
    "Berwick Academy": "berwick-academy",
    "Brewster": "brewster-academy",
    "Brewster Academy": "brewster-academy",
    "Brooks": "brooks",
    "Brooks School": "brooks",
    "Brunswick School": "brunswick",
    "Buckingham Browne & Nichols": "buckingham-browne-and-nicols",
    "Buckingham Browne & Nichols School": "buckingham-browne-and-nicols",
    "Buckingham, Browne, & Nichols": "buckingham-browne-and-nicols",
    "Canterbury School": "cantebury",
    "Cardigan": "cardigan",
    "Cardigan Mountain School": "cardigan",
    "Choate Rosemary Hall": "choate",
    "Concord Academy": "concord-hs",
    "Cushing": "cushing",
    "Cushing Academy": "cushing",
    "Dana Hall": "dana-hall",
    "Dana Hall School": "dana-hall",
    "Deerfield": "deerfield",
    "Deerfield Academy": "deerfield",
    "Dexter Southfield": "dexter-southfield",
    "Dexter Southfield School": "dexter-southfield",
    "Dublin School": "dublin-hs",
    "Eaglebrook School": "eaglebrook-school",
    "Fessenden School": "fessenden-school",
    "Governor's Academy": "governors-academy",
    "Governors Academy": "governors-academy",
    "Governor’s": "governors-academy",
    "Governor’s Academy": "governors-academy",
    "Groton": "groton",
    "Groton School": "groton",
    "Hanover HS": "hanover-hs",
    "Hanover High School": "hanover-hs",
    "Holderness": "holderness",
    "Holderness School": "holderness",
    "KUA": "kua",
    "Kent School": "kent-school",
    "Kimball Union Academy": "kua",
    "Kingswood Oxford": "kingswood-oxford",
    "Kingswood-Oxford School": "kingswood-oxford",
    "Lawrence": "lawrence-academy",
    "Lawrence Academy": "lawrence-academy",
    "Lawrenceville": "lawrenceville",
    "Loomis Chaffee": "loomis-chaffee",
    "Loomis Chaffee School": "loomis-chaffee",
    "Middlesex School": "middlesex",
    "Milton": "milton",
    "Milton Academy": "milton",
    "NMH": "northfield-mount-hermon",
    "New Hampton School": "new-hampton",
    "Noble & Greenough": "nobles",
    "Noble and Greenough": "nobles",
    "Noble and Greenough School": "nobles",
    "Nobles": "nobles",
    "Northfield Mount Hermon": "northfield-mount-hermon",
    "Northfield Mount Hermon School": "northfield-mount-hermon",
    "Phillips Academy Andover": "andover",
    "Phillips Exeter Academy": "exeter",
    "Pingree": "pingree",
    "Pingree School": "pingree",
    "Pomfret Academy": "pomfret",
    "Pomfret School": "pomfret",
    "Portsmouth Abbey School": "portsmouth-abbey",
    "Proctor Academy": "proctor",
    "Rivers": "rivers",
    "St. Mark's": "st-marks",
    "St. Mark’s School": "st-marks",
    "St. Sebastians School": "st-sebs",
    "St. Sebastian’s School": "st-sebs",
    "Tabor Academy": "tabor-academy",
    "Taft School": "taft",
    "Thayer": "thayer-academy",
    "Thayer Academy": "thayer-academy",
    "The Governor's Academy": "governors-academy",
    "The Governor’s Academy": "governors-academy",
    "The Hotchkiss School": "hotchkiss",
    "The Lawrenceville School": "lawrenceville",
    "The Winsor School": "winsor",
    "Tilton School": "tilton",
    "Vermont Academy": "vermont-academy",
    "Wilbraham & Monson Academy": "willbrham-and-monson",
    "Williston Northampton School": "williston",
    "Winsor School": "winsor",
    "Worcester": "worcester-academy",
    "Worcester Academy": "worcester-academy",
}

# logo slug -> short display abbreviation for the opponent-name caption
# (see side_box) — real prep-school shorthand ("KUA", "BB&N", "NMH", "Nobles")
# reads far better at 4x5 in a ~50px-wide caption than a hard character
# clip of the full name ever could. Anything not listed here just falls
# back to the full name, still clip_words()-safe.
SLUG_ABBR = {
    "andover": "PA",
    "austin-prep": "AUSTIN PREP",
    "avon-old-farms": "AVON",
    "bc-high": "BC HIGH",
    "belmont-hill": "BELMONT HILL",
    "berkshire-school": "BERKSHIRE",
    "berwick-academy": "BERWICK",
    "brewster-academy": "BREWSTER",
    "brooks": "BROOKS",
    "brunswick": "BRUNSWICK",
    "buckingham-browne-and-nicols": "BB&N",
    "cantebury": "CANTERBURY",
    "cardigan": "CARDIGAN",
    "choate": "CHOATE",
    "concord-hs": "CONCORD",
    "cushing": "CUSHING",
    "dana-hall": "DANA HALL",
    "deerfield": "DEERFIELD",
    "dexter-southfield": "DEXTER",
    "dublin-hs": "DUBLIN",
    "eaglebrook-school": "EAGLEBROOK",
    "exeter": "PEA",
    "fessenden-school": "FESSENDEN",
    "governors-academy": "GOVS",
    "groton": "GROTON",
    "hanover-hs": "HANOVER",
    "holderness": "HOLDERNESS",
    "hotchkiss": "HOTCHKISS",
    "kent-school": "KENT",
    "kingswood-oxford": "K-O",
    "kua": "KUA",
    "lawrence-academy": "LAWRENCE",
    "lawrenceville": "LVILLE",
    "loomis-chaffee": "LOOMIS",
    "middlesex": "MIDDLESEX",
    "milton": "MILTON",
    "new-hampton": "NHS",
    "nobles": "NOBLES",
    "northfield-mount-hermon": "NMH",
    "pingree": "PINGREE",
    "pomfret": "POMFRET",
    "portsmouth-abbey": "PORTSMOUTH",
    "proctor": "PROCTOR",
    "rivers": "RIVERS",
    "st-marks": "ST MARK",
    "st-sebs": "ST SEBS",
    "tabor-academy": "TABOR",
    "taft": "TAFT",
    "thayer-academy": "THAYER",
    "tilton": "TILTON",
    "vermont-academy": "VERMONT",
    "willbrham-and-monson": "W&M",
    "williston": "WILLISTON",
    "winsor": "WINSOR",
    "worcester-academy": "WORCESTER",
}

# ------------------------------------------------------------- feed fetch

MON_ABBR = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DOW_ABBR = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

def days_since_epoch(y, m, d):
    """Day count relative to 2000-01-01 — no calendar module is exposed to
    app.star, so this (and its inverse below) stand in for one."""
    days = 0
    if y >= 2000:
        for yy in range(2000, y):
            days += 366 if is_leap(yy) else 365
    else:
        for yy in range(y, 2000):
            days -= 366 if is_leap(yy) else 365
    for mm in range(1, m):
        days += DAYS_IN_MONTH[mm - 1]
        if mm == 2 and is_leap(y):
            days += 1
    return days + d - 1

def date_from_days(days):
    """Inverse of days_since_epoch: a day count -> (year, month, day). Only
    for loops here -- this Starlark dialect has no `while` -- bounded well
    past any realistic date range (this only ever handles dates within a
    year of "now")."""
    y = 2000
    if days >= 0:
        for _ in range(400):
            n = 366 if is_leap(y) else 365
            if days < n:
                break
            days -= n
            y += 1
    else:
        for _ in range(400):
            if days >= 0:
                break
            y -= 1
            n = 366 if is_leap(y) else 365
            days += n
    m = 1
    for _ in range(12):
        dim = DAYS_IN_MONTH[m - 1] + (1 if m == 2 and is_leap(y) else 0)
        if days < dim:
            break
        days -= dim
        m += 1
    return (y, m, days + 1)

def fetch_month(y, m):
    """One http.get for one calendar month (every sport, every level) ->
    a flat list of its events, or None if the fetch failed. The response is
    already-decoded JSON (resp["json"]) — no text parsing needed. ttl_seconds
    matches the manifest's own refresh (300s) so the data is never staler
    than the panel's own re-render cadence."""
    date_param = "%d/1/%d 12:00:00 AM" % (m, y)
    resp = http.get(
        CALENDAR_URL,
        headers = FEED_HEADERS,
        params = {"type": "month", "sport": "0", "location": "all", "date": date_param},
        ttl_seconds = 300,
    )
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    out = []
    for day in resp["json"]:
        evs = day.get("events")
        if evs == None:
            continue
        for e in evs:
            out.append(e)
    return out

def fetch_calendar(ctx):
    """This month + next month, merged. Two calendar grids always overlap
    by a few padding days at each end (Sidearm pads every month out to full
    weeks), so together they comfortably cover the whole current week
    regardless of where in the month it falls. Returns (events, any_ok) —
    any_ok tells a page "couldn't reach the feed" apart from "genuinely
    nothing scheduled" so it can say so instead of showing the same "no
    games" message for both."""
    y1, m1 = ctx.now.year, ctx.now.month
    y2, m2 = y1, m1 + 1
    if m2 > 12:
        m2 = 1
        y2 = y1 + 1
    events = []
    any_ok = False
    for y, m in [(y1, m1), (y2, m2)]:
        got = fetch_month(y, m)
        if got != None:
            any_ok = True
            events.extend(got)
    return events, any_ok

def level_rank(title):
    """Lower ranks win when a day has more than one game: Varsity (or a
    sport with only one level at all, e.g. Baseball/Golf/Softball) first,
    then JV, then JV-B/Thirds."""
    if "JV B" in title:
        return 2
    if "JV" in title:
        return 1
    return 0

def event_minutes(e):
    d = e["date"]
    return int(d[11:13]) * 60 + int(d[14:16])

def has_result(e):
    result = e.get("result")
    return result != None and result.get("status") != None

def result_note(result):
    """Sidearm's own annotation on a finished result — "Scrimmage", "OT",
    "9 Inn.", "FORFEIT", "Lakes Region Champions", a meet placement like
    "6 Place", all real examples pulled live from this feed. postscore_info
    is the primary field; prescore_info (mostly used for meet placements)
    is the fallback for results that only carry that one."""
    for key in ("postscore_info", "prescore_info"):
        v = result.get(key)
        if v != None and v.strip() != "":
            return v.strip().upper()
    return None

HOME_AWAY_TAG = {"H": "HOME", "A": "AWAY", "N": "NEUTRAL"}

def venue_line(e):
    """"HOME - PILLSBURY FIELD" for a home game (the specific field, when
    the site has one on file) — but just "AWAY" / "NEUTRAL" alone for
    everything else. An away game's town isn't worth the space it costs:
    the opponent's own name/logo already says where the game effectively
    is, and this row already has a hard 80px budget to share with the
    opponent's name caption on the right."""
    indicator = e.get("location_indicator")
    if indicator == "H":
        facility = e.get("facility")
        place = facility["title"] if facility != None else e.get("location")
        return "HOME - " + place.upper() if place != None else "HOME"
    return HOME_AWAY_TAG.get(indicator)

def event_sort_key(e):
    return level_rank(e["sport"]["title"]) * 10000 + event_minutes(e)

def sorted_events(day_list):
    """Selection sort by event_sort_key — no `while` and (per the platform's
    Starlark) no lambda either, so this can't just be sorted(key=...)."""
    n = len(day_list)
    for i in range(n):
        best_i = i
        for j in range(i + 1, n):
            if event_sort_key(day_list[j]) < event_sort_key(day_list[best_i]):
                best_i = j
        if best_i != i:
            tmp = day_list[i]
            day_list[i] = day_list[best_i]
            day_list[best_i] = tmp
    return day_list

def events_for_day(events, y, m, d, want_played):
    """EVERY event on this exact date whose played state matches
    `want_played` (True, False, or None for "either") — a day with a
    doubleheader, or several different sports all playing the same day,
    produces one entry per game, not just the single highest-priority one.
    Sorted lowest level_rank first, then earliest time."""
    target = fmt.pad(y, 4) + "-" + fmt.pad(m) + "-" + fmt.pad(d)
    day_list = []
    for e in events:
        if e["date"][0:10] != target:
            continue
        if want_played != None and has_result(e) != want_played:
            continue
        day_list.append(e)
    return sorted_events(day_list)

# ----------------------------------------------------------------- drawing

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    """Like clip(), but backs up to the last whole word — a long facility
    name ("HOME - BOGLE LECHNER TURF FIELD") should drop "FIELD" entirely
    rather than mangle it into "FIE". Only backs up when that costs at most
    30% of the string, so a single very long word still gets a hard cut
    instead of vanishing to nothing."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[:sp]
    return t

def side_box(c, x, y, name):
    """The opponent's logo (see OPP_ICON) with its name/abbreviation beside
    it — to its left, vertically centered on it, not underneath — since
    there are 90+ possible opponents and not everyone will recognize a
    crest at a glance. When we have no art for an opponent, the logo slot
    is just left blank and the name sits in the same spot beside it."""
    slug = OPPONENT_LOGO.get(name)
    if slug != None:
        path = "logos/" + slug + ".png"
        c.image(path, x, y, OPP_ICON, OPP_ICON)
    # Right-aligned just left of the logo's own left edge, not centered —
    # centering could let a wide name grow left into the center date/time
    # text with no error, just a silently lost column. label_y centers the
    # 5px-tall "4x5" glyphs on the logo's own height. 36px is a hard cap,
    # not a style choice: the date/time line above it (font 5x7) reaches a
    # worst-case width of 55px centered on the panel, i.e. as far right as
    # x=124 — a caption any wider than 36px, ending at x-3, would reach far
    # enough left to run into that same row (confirmed live: "NEW HAMPTON"
    # at a looser cap visibly collided with "WED OCT 28" above it).
    label = SLUG_ABBR.get(slug, name.upper()) if slug != None else name.upper()
    t = clip_words(c, label, "4x5", 36)
    label_y = y + (OPP_ICON - 5) // 2
    c.text(t, x - 3, label_y, font = "4x5", color = INK, align = "right")

def card(c, ctx, sport_label, opponent, center_lines, accent = BIG_RED, small_line = None):
    y0 = c.header(sport_label, bg = accent, color = "black", font = "5x7")
    c.image("logos/sps.png", 2, y0, ICON, ICON)
    side_box(c, c.width - 2 - OPP_ICON, y0, opponent)
    cx = c.width // 2
    ty = y0 + 1
    for line in center_lines:
        c.text(line, cx, ty, font = "5x7", color = INK, align = "center")
        ty += 8
    if small_line != None:
        # tucked in right after the 5x7 lines above (4x5 is only 5px tall);
        # with ty starting at y0+1, this lands with a proper 1px gap on both
        # sides and ends exactly on the panel's last row — one row lower and
        # it touches the line above; one more line and it overflows. Capped
        # at 80px so even its worst-case width can't reach into the
        # opponent name caption's own zone on the right (the two are on
        # different rows, but stay conservative regardless).
        t = clip_words(c, small_line, "4x5", 80)
        c.text(t, cx, y0 + 17, font = "4x5", color = DIM, align = "center")

def empty_card(c, sport_label, lines, accent = OFFLINE):
    y0 = c.header(sport_label, bg = accent, color = "white", font = "5x7")
    c.image("logos/sps.png", 2, y0, ICON, ICON)
    cx = c.width // 2 + ICON // 2
    ty = y0 + 3
    for line in lines:
        c.text(line, cx, ty, font = "5x7", color = DIM, align = "center")
        ty += 8

def week_monday_days(ctx):
    today_days = days_since_epoch(ctx.now.year, ctx.now.month, ctx.now.day)
    return today_days - ctx.now.weekday

# --------------------------------------------------------------------- pages

def week_matches(ctx, want_played):
    """Every one of this week's qualifying events (see events_for_day), in
    Monday..Sunday order — a day with a doubleheader or several sports
    playing the same day contributes one entry per game, not just the
    single highest-priority one; a day with nothing just contributes
    nothing, instead of a placeholder to skip later. Pages can't remove
    themselves from the device's rotation (there's no such thing as a
    variable number of pages — the manifest's `pages:` list is a fixed set
    of slots the device always cycles through), so the closest real
    equivalent to "don't show empty days" is this: compact the actual games
    to the front, and let a page pick modulo the match count so extra slots
    cycle back through real games instead of ever showing a blank — and so
    a busy week's extra games still get their turn across the rotation
    instead of being silently dropped."""
    monday = week_monday_days(ctx)
    events, any_ok = fetch_calendar(ctx)
    matches = []
    for i in range(7):
        y, m, d = date_from_days(monday + i)
        for e in events_for_day(events, y, m, d, want_played):
            matches.append((i, e))
    return matches, any_ok

def render_upcoming_slot(c, ctx, slot_index):
    # want_played=None: this week's games either way — not-yet-played AND
    # already-played both qualify for a slot here. A game keeps its slot
    # across the week regardless of which side of "played" it's on; once
    # its score posts, this same slot just draws the score card below
    # instead of the schedule card, in place — no separate "it moved to
    # another app" step.
    matches, any_ok = week_matches(ctx, want_played = None)
    if not any_ok:
        empty_card(c, "THIS WEEK", ["FEED", "UNAVAILABLE"])
        return
    if len(matches) == 0:
        empty_card(c, "THIS WEEK", ["NO GAMES", "SCHEDULED"])
        return
    weekday_index, e = matches[slot_index % len(matches)]
    m = int(e["date"][5:7])
    d = int(e["date"][8:10])
    when = "%s %s %d" % (DOW_ABBR[weekday_index], MON_ABBR[m], d)
    opponent = e["opponent"]["title"].strip()
    if has_result(e):
        result = e["result"]
        accent = {"W": BIG_RED, "L": OFFLINE, "T": "#555555"}.get(result["status"], BIG_RED)
        # A scrimmage (status "N") carries no real team_score/opponent_score
        # (both null) — Sidearm's own signal that there's no number to show.
        # There's no WIN/LOSS/TIE to put in the header either then, so the
        # header stays just the sport name and "FINAL" goes where the score
        # would — the note below (e.g. "SCRIMMAGE") still explains why.
        if result["team_score"] != None and result["opponent_score"] != None:
            outcome = {"W": "WIN", "L": "LOSS", "T": "TIE"}.get(result["status"], "FINAL")
            score = "%s %s-%s" % (result["status"], result["team_score"], result["opponent_score"])
            header = e["sport"]["title"].upper() + " " + outcome
            lines = [when, score]
        else:
            header = e["sport"]["title"].upper()
            lines = [when, "FINAL"]
        card(c, ctx, header, opponent, lines, accent = accent, small_line = result_note(result))
    else:
        card(c, ctx, e["sport"]["title"].upper(), opponent,
             [when, e["time"].upper()], small_line = venue_line(e))

def this_week(c, ctx):
    monday = week_monday_days(ctx)
    y1, m1, d1 = date_from_days(monday)
    y2, m2, d2 = date_from_days(monday + 6)
    y0 = c.header("UPCOMING GAMES", bg = BIG_RED, color = "black", font = "5x7")
    c.image("logos/sps.png", 2, y0, ICON, ICON)
    cx = c.width // 2 + ICON // 2
    if m1 == m2:
        line = "%s %d-%d" % (MON_ABBR[m1], d1, d2)
    else:
        line = "%s %d - %s %d" % (MON_ABBR[m1], d1, MON_ABBR[m2], d2)
    c.text("THIS WEEK", cx, y0 + 3, font = "5x7", color = INK, align = "center")
    c.text(line, cx, y0 + 12, font = "5x7", color = DIM, align = "center")

def slot1(c, ctx):
    render_upcoming_slot(c, ctx, 0)

def slot2(c, ctx):
    render_upcoming_slot(c, ctx, 1)

def slot3(c, ctx):
    render_upcoming_slot(c, ctx, 2)

def slot4(c, ctx):
    render_upcoming_slot(c, ctx, 3)

def slot5(c, ctx):
    render_upcoming_slot(c, ctx, 4)

def slot6(c, ctx):
    render_upcoming_slot(c, ctx, 5)

def slot7(c, ctx):
    render_upcoming_slot(c, ctx, 6)
