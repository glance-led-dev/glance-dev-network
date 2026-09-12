# Elections - National, Congressional, Senate, and gubernatorial races and
# results for your ZIP. No state legislature or local races.
#
# civicAPI (civicapi.org/api-documentation) is the data source, but it has no
# zip/postal/address lookup at all - races are only queryable by country and
# province (US state, e.g. "CA"), plus an optional district (e.g. "TX-HD-54"
# for TX State House district 54). So a zip code is resolved to a US state
# first, via the free api.zippopotam.us lookup (no key, cached ~forever since
# zip -> state never changes).
#
# Once we have the state, every race civicAPI returns with district == null
# is genuinely statewide (Governor, Secretary of State, US Senate, President,
# etc.) - those are safe to show for anyone in that state. Of those, only
# National (President), Senate, and Gubernatorial races are actually shown
# (see ALLOWED_TYPES) - every other statewide office (Lt. Governor, AG,
# Secretary of State, Treasurer, ...) is filtered out by choice, not a data
# gap. Congressional (US House) races are handled separately below, since
# they're district-scoped rather than statewide.
#
# US House races are district-scoped (civicAPI codes them like "WA-01", or
# "WY-AL" for an at-large seat), and a 5-digit zip can't be mapped to the
# right one without a real geocoder - zips routinely straddle district
# lines. The free, keyless Census Bureau geocoder
# (geocoding.geo.census.gov) resolves the zip's centroid coordinates
# (from zippopotam, below) to a Congressional District, which is built
# back into the same "XX-NN" / "XX-AL" shape civicAPI uses. This is
# centroid-based, not your exact address, so it's usually right but can
# be wrong for a zip that straddles a district boundary - there's no way
# to do better without the viewer entering a full street address, which
# these panels have no input for. Every other district-scoped race (State
# House, State Senate, county seats, ...) is still excluded, since there's
# no equivalent free lookup wired up for those.
#
# Same endpoint doubles as "upcoming" and "results": before election night
# percent_reporting is 0 and candidates show 0 votes; once results start
# coming in, percent_reporting and each candidate's votes/percent/winner
# update - refetched at most every 30 minutes (ttl_seconds below).
#
# Only two pages are declared: "intro" and "race". A manifest's pages: list
# is fixed at declare time and can't track how many real races a given ZIP
# has, so "race" time-multiplexes through them instead of using one
# manifest page per race - see current_index() for the mechanism (the same
# one yesterdays-extremes-scroll uses).

FEDERAL_TYPES = ["President", "U.S. Senate", "US Senate", "House of Representatives", "U.S. House", "US House"]

# National, Congressional, Senate, and Gubernatorial races only - every
# other statewide or district-scoped office civicAPI returns is filtered
# out in relevant_races.
ALLOWED_TYPES = FEDERAL_TYPES + ["Governor"]

PRIORITY = {
    "President": 0,
    "U.S. Senate": 1,
    "US Senate": 1,
    "House of Representatives": 2,
    "U.S. House": 2,
    "US House": 2,
    "Governor": 3,
}

def pad(n, width):
    s = str(n)
    for i in range(width):
        if len(s) >= width:
            break
        s = "0" + s
    return s

def today_str(ctx):
    return str(ctx.now.year) + "-" + pad(ctx.now.month, 2) + "-" + pad(ctx.now.day, 2)

def fetch_zip_geo(zip_code):
    return http.get(
        "http://api.zippopotam.us/us/" + zip_code,
        ttl_seconds = 2592000,
    )

def resolve_zip(zip_code):
    resp = fetch_zip_geo(zip_code)
    if resp["status_code"] != 200:
        return None
    places = (resp["json"] or {}).get("places", [])
    if len(places) == 0:
        return None
    p = places[0]
    state = p.get("state abbreviation", None)
    lat = p.get("latitude", None)
    lon = p.get("longitude", None)
    if state == None or lat == None or lon == None:
        return None
    return {"state": state, "lat": lat, "lon": lon}

def fetch_congress_geo(lat, lon):
    return http.get(
        "https://geocoding.geo.census.gov/geocoder/geographies/coordinates",
        params = {
            "x": lon,
            "y": lat,
            "benchmark": "Public_AR_Current",
            "vintage": "Current_Current",
            "layers": "Congressional Districts",
            "format": "json",
        },
        ttl_seconds = 2592000,
    )

def congress_district_code(state, lat, lon):
    # The layer key is named after the current Congress (e.g. "119th
    # Congressional Districts") and rolls over every two years, so match on
    # the stable substring instead of a hardcoded ordinal.
    resp = fetch_congress_geo(lat, lon)
    if resp["status_code"] != 200:
        return None
    geos = ((resp["json"] or {}).get("result", {}) or {}).get("geographies", {})
    for key in geos:
        if "Congressional District" not in key:
            continue
        entries = geos[key]
        if len(entries) == 0:
            continue
        basename = str(entries[0].get("BASENAME", "")).strip()
        if "arge" in basename:
            return state + "-AL"
        if basename.isdigit():
            return state + "-" + pad(int(basename), 2)
        return None
    return None

def fetch_races(state, start_date):
    # civicAPI's own ordering is NOT priority-sorted - a busy state like TX
    # returns 300+ races (mostly county judges/clerks), and its one federal
    # US Senate race can sit past index 250. A small limit silently drops
    # marquee races before this app's own sort ever sees them. 2000 stays
    # safely under the host's 2MB response cap (TX's full ~300-race payload
    # is ~150KB) while covering every state's real race count.
    return http.get(
        "https://civicapi.org/api/v2/race/search",
        params = {
            "country": "US",
            "province": state,
            "startDate": start_date,
            "limit": 2000,
        },
        ttl_seconds = 1800,
    )

def relevant_races(races, district_code):
    out = []
    for r in races:
        if r.get("type", "") not in ALLOWED_TYPES:
            continue
        d = r.get("district", None)
        if d == None or (district_code != None and d == district_code):
            out.append(r)
    return out

def sort_races(races):
    keyed = []
    for r in races:
        p = PRIORITY.get(r.get("type", ""), 50)
        date10 = str(r.get("election_date", "9999-99-99"))[:10]
        rid = r.get("id", 0)
        key = date10 + "_" + pad(p, 3) + "_" + pad(rid, 10)
        keyed.append([key, r])

    n = len(keyed)
    for i in range(n):
        min_idx = i
        for j in range(i + 1, n):
            if keyed[j][0] < keyed[min_idx][0]:
                min_idx = j
        if min_idx != i:
            tmp = keyed[i]
            keyed[i] = keyed[min_idx]
            keyed[min_idx] = tmp

    out = []
    for k in keyed:
        out.append(k[1])
    return out

def get_upcoming_races(ctx):
    zip_code = str(ctx.inputs.get("zip", 20500))
    geo = resolve_zip(zip_code)
    if geo == None:
        return (None, None, "zip")

    district_code = congress_district_code(geo["state"], geo["lat"], geo["lon"])

    resp = fetch_races(geo["state"], today_str(ctx))
    if resp["status_code"] != 200:
        return (geo["state"], None, "races")

    races = (resp["json"] or {}).get("races", [])
    races = sort_races(relevant_races(races, district_code))
    return (geo["state"], races, None)

def fit_text(c, text, font, maxw):
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i] + "..."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return "..."

def race_color(race_type):
    if race_type in FEDERAL_TYPES:
        return "#E8B04A"
    return "#40E0D0"

def nodata(c, title, sub):
    c.fill("#0B0C12")
    mid = c.width // 2
    c.text(title, mid, 8, font = "6x8", color = "#E8B04A", align = "center")
    c.text(sub, mid, 20, font = "4x5", color = "#6A7090", align = "center")

def draw_all_clear(c, state):
    c.fill("black")
    mid = c.width // 2
    c.rect(0, 0, c.width - 1, 4, fill = "#00FF7F")
    c.text("ALL CLEAR", mid, 10, font = "6x8", color = "#00FF7F", align = "center")
    msg = fit_text(c, "NO UPCOMING RACES IN " + state, "4x5", c.width - 16)
    c.text(msg, mid, 22, font = "4x5", color = "gray", align = "center")

ROWS_IN_RACE_CARD = 2

def draw_race(c, race, state):
    # Safe-zone edge padding for SCROLL (6-10px min per design guidelines) -
    # using 8px so content never touches the app's own outer edge, since on
    # Pro/Premier this app plays on-glass at the same time as neighbor apps.
    pad_x = 8
    content_w = c.width - (pad_x * 2)

    race_type = race.get("type", "Race")
    # The header carries the specific election name (e.g. "WASHINGTON US
    # HOUSE 1") instead of a generic "STATE TYPE" label - that was
    # redundant with the body, and dropping it frees a full row for
    # candidate names at a larger, more readable font.
    label = str(race.get("election_name", state + " " + race_type)).upper()
    content_y = c.header(label, bg = race_color(race_type))

    candidates = race.get("candidates", [])
    percent_reporting = race.get("percent_reporting", 0) or 0

    y = content_y
    if percent_reporting > 0:
        reporting_tag = str(int(percent_reporting)) + "% IN"
        c.text(reporting_tag, c.width - pad_x, y, font = "4x5", color = "gray", align = "right")
        y += 7

    # Wide-panel list rows use 5x7 per the design guidelines' typography
    # table (4x5 is the narrow/64px size) - candidate names read clearly at
    # this size with room to spare now that the header covers the name.
    row_h = 8
    shown = 0
    for cand in candidates:
        if shown >= ROWS_IN_RACE_CARD:
            break
        cname = cand.get("name", "").upper()
        party_initial = str(cand.get("party", "")).upper()[:1]
        color = cand.get("color", "white")
        left = cname + " (" + party_initial + ")"
        if percent_reporting > 0:
            right = str(int(cand.get("percent", 0))) + "%"
            right_w = c.text_width(right, "5x7")
            c.text(fit_text(c, left, "5x7", content_w - right_w - 4), pad_x, y, font = "5x7", color = color)
            c.text(right, c.width - pad_x, y, font = "5x7", color = color, align = "right")
        else:
            c.text(fit_text(c, left, "5x7", content_w), pad_x, y, font = "5x7", color = color)
        y += row_h
        shown += 1

    remaining = len(candidates) - shown
    if remaining > 0:
        c.text("+" + str(remaining) + " MORE", pad_x, y, font = "4x5", color = "gray")

def draw_candidate(c, race, candidate, state):
    pad_x = 8
    content_w = c.width - (pad_x * 2)

    race_type = race.get("type", "Race")
    label = str(race.get("election_name", state + " " + race_type)).upper()
    content_y = c.header(label, bg = race_color(race_type))

    percent_reporting = race.get("percent_reporting", 0) or 0

    name = candidate.get("name", "").upper()
    if percent_reporting > 0:
        reporting_tag = str(int(percent_reporting)) + "% IN"
        tag_w = c.text_width(reporting_tag, "4x5")
        c.text(fit_text(c, name, "6x8", content_w - tag_w - 4), pad_x, content_y, font = "6x8", color = "white")
        c.text(reporting_tag, c.width - pad_x, content_y + 2, font = "4x5", color = "gray", align = "right")
    else:
        c.text(fit_text(c, name, "6x8", content_w), pad_x, content_y, font = "6x8", color = "white")

    party = str(candidate.get("party", "")).upper()
    swatch_color = candidate.get("color", "white")
    if percent_reporting > 0:
        left = party
        if candidate.get("winner", False):
            left = left + "  WINNER"
        right = str(int(candidate.get("percent", 0))) + "%"
        right_w = c.text_width(right, "4x5")
        c.text(fit_text(c, left, "4x5", content_w - right_w - 4), pad_x, 26, font = "4x5", color = swatch_color)
        c.text(right, c.width - pad_x, 26, font = "4x5", color = swatch_color, align = "right")
    else:
        c.text(fit_text(c, party, "4x5", content_w), pad_x, 26, font = "4x5", color = swatch_color)

# One card per race - every race card already embeds its first
# ROWS_IN_RACE_CARD candidates by name. A race with more candidates than
# that gets one extra card per overflow candidate, capped at MAX_CARDS
# (a sanity ceiling, not a page-count constraint - see race() below for
# why page count no longer needs to track this at all).
MAX_CARDS = 6

def build_cards(races, max_cards):
    cards = []
    for r in races:
        if len(cards) >= max_cards:
            break
        cards.append({"kind": "race", "race": r})

    for r in races:
        if len(cards) >= max_cards:
            break
        candidates = r.get("candidates", [])
        for i in range(ROWS_IN_RACE_CARD, len(candidates)):
            if len(cards) >= max_cards:
                break
            cards.append({"kind": "candidate", "race": r, "candidate": candidates[i]})

    return cards

def current_index(ctx, count):
    # The catalog's standard way to show more items than fit as separate
    # manifest pages (see yesterdays-extremes-scroll/app.star): manifest
    # `pages:` is fixed at declare time and can't track how many real
    # races a given ZIP has, so instead of one page per race (with dead
    # "check back later" pages for ZIPs with fewer races than the ceiling),
    # a single "race" page time-multiplexes through `count` items, one per
    # minute, wrapping at whatever count actually is this render - a
    # 1-race ZIP shows that race every time; a 6-race ZIP cycles all 6.
    # `debugframe` is an undeclared, manifest-invisible input for
    # `gdn render --input debugframe=N` to preview a specific slide.
    dbg = str(ctx.inputs.get("debugframe", "")).strip()
    if dbg != "":
        return int(dbg) % count
    return (ctx.now.unix // 60) % count

def race(c, ctx):
    c.clear()

    state, races, err = get_upcoming_races(ctx)
    if err == "zip":
        nodata(c, "ZIP LOOKUP FAILED", "CHECK ZIP CODE SETTING")
        return
    if err == "races":
        nodata(c, "ELECTION DATA", "UNAVAILABLE")
        return
    if len(races) == 0:
        draw_all_clear(c, state)
        return

    cards = build_cards(races, MAX_CARDS)
    index = current_index(ctx, len(cards))

    card = cards[index]
    if card["kind"] == "race":
        draw_race(c, card["race"], state)
    else:
        draw_candidate(c, card["race"], card["candidate"], state)

MONTH_ABBR = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def short_date(date10):
    if len(date10) < 10:
        return date10
    m = int(date10[5:7])
    d = int(date10[8:10])
    if m < 1 or m > 12:
        return date10
    return MONTH_ABBR[m - 1] + " " + str(d)

def intro(c, ctx):
    c.clear()
    mid = c.width // 2
    c.text("ELECTIONS", mid, 2, font = "10x16_bold", color = "amber", align = "center")
    c.line(16, 20, c.width - 16, 20, "#555555")

    zip_code = str(ctx.inputs.get("zip", 20500))
    geo = resolve_zip(zip_code)
    if geo == None:
        c.text("SET YOUR ZIP CODE", mid, 23, font = "4x7", color = "gray", align = "center")
        return

    sub = "NEAR " + geo["state"]

    # races is sorted soonest-first, so races[0]'s date is the next
    # election - folded in here instead of its own cycling slide, so the
    # race page's cycle time is spent entirely on real races.
    _, races, err = get_upcoming_races(ctx)
    if err == None and len(races) > 0:
        date10 = str(races[0].get("election_date", ""))[:10]
        sub = sub + " - " + short_date(date10)

    c.text(sub.upper(), mid, 23, font = "4x7", color = "gray", align = "center")

