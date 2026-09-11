# DESIGN. Two pages. "intro" announces which extreme is being ranked and how
# many cities follow (e.g. "HIGH U.S. TEMPS / TOP 5 YESTERDAY"), shown once
# each time this app comes up in the panel's rotation -- since "ranked" below
# serves all four metrics off the same layout, a viewer glancing at the panel
# mid-cycle would otherwise have only the small HIGH/LOW word or icon to
# place what they're looking at. "ranked" is a list, one entry at a time: an
# identity glyph for the chosen metric (the word HIGH or LOW for
# temperatures, a raindrop icon for rain, a snowflake sprite for snowfall),
# "#N CITY, ST" as the headline, the extreme value as the hero, and a short
# amber note underneath it (the departure from normal, or a measured/
# estimated flag for snow reports) -- every row on this app is by definition
# a standout, so amber (the catalog's "notable" color) is used uniformly
# rather than per-row. Black ground throughout. 64-wide (this app) and
# 192-wide (yesterdays-extremes-scroll) share this file -- only the identity
# size, edge inset and how much narrow copy gets trimmed change with c.width.
#
# "ranked" is one manifest page, not one page per rank: the "Number of
# cities" input picks how many items to cycle through, and a manifest's
# `pages:` list is fixed at declare time -- there's no way to make its length
# track an input. An earlier version declared rank1..rank10 pages and hit two
# real problems: the render schema hard-caps a bundle at 8 pages (10 broke
# the interactive preview outright), and even at 8 it meant a "top 3" pick
# still cycled through 5 dead "THAT'S ALL" screens on the real device every
# rotation. current_index() below is the catalog's actual answer:
# time-multiplex through `count` items within one page, the same way
# study-flashcards cycles its deck.
#
# Three of the four metrics (rain, high temp, low temp) come from one
# nationwide /api/v1/yesterday call and are ranked client-side. Snowfall
# comes from /api/v1/snow/reports, whose "reports" schema isn't documented
# and returns 0 reports outside snow season -- rows_for_snow() infers the
# per-report fields from hail/week's identical "NWS Local Storm Reports via
# IEM" attribution line (the same underlying source, verified structure),
# but hasn't been checked against a live snow report. Read defensively.

BG = "#070B14"
NODATA_BG = "#0B0C12"
EMPTY_BG = "#081208"

INK = "#EAF6FF"          # hero numbers
LABEL_COL = "#7FB4DC"    # rank + place headline
NOTE_COL = "#FFD27A"     # sub-line -- every row here is a notable extreme
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"
EMPTY_TITLE = "#4ADE80"
EMPTY_SUB = "#6A9080"
END_TITLE = "#8A93B4"
END_SUB = "#6A7090"

HOT_COL = "#FFB454"
COLD_COL = "#8FC7FF"
RAIN_COL = "#4FA8FF"
SNOW_COL = "#BFE3FF"  # matches SNOWFLAKE_LEGEND's main spoke color

# 15x15, symmetric 8-spoke snowflake -- identical to weather-totals-scroll's,
# reused here rather than reinvented since it's the same visual language.
SNOWFLAKE_ART = [
    "#......#......#",
    ".#.....#.....#.",
    "..#...o#o...#..",
    "...#...#...#...",
    "....#..#..#....",
    ".....#.#.#.....",
    "..o...###...o..",
    "###############",
    "..o...###...o..",
    ".....#.#.#.....",
    "....#..#..#....",
    "...#...#...#...",
    "..#...o#o...#..",
    ".#.....#.....#.",
    "#......#......#",
]
SNOWFLAKE_ART_SMALL = [
    "#...#...#",
    ".#.o#o.#.",
    "..#.#.#..",
    ".o.###.o.",
    "#########",
    ".o.###.o.",
    "..#.#.#..",
    ".#.o#o.#.",
    "#...#...#",
]
SNOWFLAKE_LEGEND = {"#": "#BFE3FF", "o": "#7FC8FF"}

ART_W_WIDE = 16
ART_W_NARROW = 9

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw` in `font`."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest listed font that fits, else hard-clipped
    at the smallest."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

def fit_forms(c, forms, fonts, maxw):
    """[font, text] for the largest font that holds some whole form
    (longest first). Last resort backs off to a word boundary rather than
    clipping mid-word -- place names off snow reports can run long and
    ragged ("3 SSW Mount Baker Lodge")."""
    for f in fonts:
        for t in forms:
            if c.text_width(t, f) <= maxw:
                return [f, t]
    last_font = fonts[len(fonts) - 1]
    last_form = forms[len(forms) - 1]
    t = clip(c, last_form, last_font, maxw)
    if len(t) < len(last_form) and last_form[len(t)] != " ":
        for k in range(len(t), 0, -1):
            if t[k - 1] == " ":
                head = t[:k].strip()
                if head != "":
                    t = head
                break
    return [last_font, t]

NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]

def message_card(c, bg, title, title_col, sub, sub_col, narrow_title = None, narrow_sub = None):
    """The shared two-line card (error / empty / end-of-list all use this,
    just with different colors) -- centered, never overlapping."""
    c.fill(bg)
    maxw = c.width - 6
    if c.width >= 128:
        t = fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = title_col, align = "center")
        d = fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = sub_col, align = "center")
    else:
        t = fit_clip(c, narrow_title if narrow_title != None else title,
                      ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = title_col, align = "center")
        d = fit_clip(c, narrow_sub if narrow_sub != None else sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = sub_col, align = "center")

def get(obj, key, fallback = None):
    """dict.get that survives a null parent."""
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def in1(x):
    """A float to one decimal place as a string. Truncates, not rounds."""
    if x == None:
        return None
    v = int(float(x) * 10) / 10.0
    return str(v)

OK_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ,.-/()&'"

def only_drawable(s):
    """Drop anything the bitmap fonts have no glyph for, collapsing runs of
    the resulting spaces -- snow-report place names carry the odd symbol."""
    out = ""
    prev_space = False
    for i in range(len(s)):
        ch = s[i]
        if OK_CHARS.find(ch) < 0:
            ch = " "
        if ch == " ":
            if prev_space:
                continue
            prev_space = True
        else:
            prev_space = False
        out += ch
    return out.strip()

def fetch_yesterday():
    """[cities, reason]. reason is "ok" or "error".

    ttl_seconds stays at 3600 even though `refresh` is 60 -- the two are
    deliberately out of sync here. `refresh` just needs to be short enough
    for current_index() to advance visibly through `count` items; the data
    underneath only actually changes a few times a day, so re-fetching it
    every 60s would be pure waste. Every render this hour reads the same
    cached response and just picks a different row out of it."""
    r = http.get("https://weathertotals.com/api/v1/yesterday", ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        return [[], "error"]
    return [get(get(r["json"], "data", {}), "cities", []), "ok"]

def fetch_snow_reports():
    """[reports, reason]. reason is "ok" or "error". Same ttl/refresh split
    as fetch_yesterday() -- see its docstring."""
    r = http.get("https://weathertotals.com/api/v1/snow/reports", ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        return [[], "error"]
    return [get(get(r["json"], "data", {}), "reports", []), "ok"]

def rows_for_temp(cities, hottest):
    """Rows ranked by yesterday's high (hottest=True) or low (False), most
    extreme first."""
    items = []
    for city in cities:
        rep = get(city, "report", {})
        val = get(rep, "high") if hottest else get(rep, "low")
        if val == None:
            continue
        depart = get(rep, "highDepart") if hottest else get(rep, "lowDepart")
        sub = ""
        if depart != None:
            sign = "+" if depart >= 0 else ""
            sub = sign + str(int(depart)) + " VS NORMAL"
        label = str(get(city, "city", "")).upper() + ", " + str(get(city, "abbr", "")).upper()
        items.append([val, {"label": label, "value": str(int(val)) + "F", "sub": sub}])
    items = sorted(items, key = lambda it: it[0], reverse = hottest)
    return [it[1] for it in items]

def rows_for_rain(cities):
    """Rows ranked by yesterday's precip, wettest first."""
    items = []
    for city in cities:
        rep = get(city, "report", {})
        val = get(rep, "precip")
        if val == None:
            continue
        trace = get(rep, "trace", False)
        sub = "TRACE" if (trace and val == 0) else ""
        label = str(get(city, "city", "")).upper() + ", " + str(get(city, "abbr", "")).upper()
        items.append([val, {"label": label, "value": in1(val) + " IN", "sub": sub}])
    items = sorted(items, key = lambda it: it[0], reverse = True)
    return [it[1] for it in items]

def rows_for_snow(reports):
    """Rows ranked by report inches, biggest first. See the DESIGN note at
    the top of the file: this report shape is inferred, not confirmed
    against live data."""
    items = []
    for rep in reports:
        inches = get(rep, "inches")
        if inches == None:
            continue
        place = only_drawable(str(get(rep, "place", "")).upper())
        state = str(get(rep, "state", "")).upper()
        label = place
        if state != "":
            label = (label + ", " + state) if label != "" else state
        if label == "":
            label = "UNKNOWN LOCATION"
        measured = get(rep, "measured", False)
        items.append([inches, {"label": label, "value": in1(inches) + " IN",
                                "sub": "MEASURED" if measured else "ESTIMATED"}])
    items = sorted(items, key = lambda it: it[0], reverse = True)
    return [it[1] for it in items]

def fetch_rows(metric):
    """[rows, reason]. reason is "ok", "empty" or "error". rows is a list of
    {label, value, sub} dicts, most extreme first."""
    if metric == "Extreme Snowfall":
        reports, reason = fetch_snow_reports()
        if reason != "ok":
            return [[], "error"]
        rows = rows_for_snow(reports)
        return [rows, "ok" if len(rows) > 0 else "empty"]

    cities, reason = fetch_yesterday()
    if reason != "ok":
        return [[], "error"]
    if metric == "Extreme Rain":
        rows = rows_for_rain(cities)
    elif metric == "Extreme Low Temp":
        rows = rows_for_temp(cities, False)
    else:
        rows = rows_for_temp(cities, True)
    return [rows, "ok" if len(rows) > 0 else "empty"]

def empty_copy(metric):
    """[title, sub, narrow_title, narrow_sub] for the positive "nothing to
    show" screen -- e.g. no snow reports outside snow season is the answer
    people want, not an error."""
    if metric == "Extreme Snowfall":
        return ["NO SNOW REPORTS", "NONE IN THE LAST 24H", "NO SNOW", "LAST 24H"]
    return ["NO DATA YET", "CHECK BACK SOON", "NO DATA", "CHECK BACK"]

def banner_copy(metric, count):
    """[title, sub, narrow_title, narrow_sub, color] for the intro screen --
    shown once each time this app comes up in the rotation, before ranked()
    cycles through the individual cities, so a viewer knows which extreme
    (and how many cities) they're about to see. "U.S." makes the data's
    coverage explicit (WeatherTotals is a U.S.-only source); narrow_title
    drops the periods ("US" not "U.S.") and a trailing S off TEMPS/TEMP to
    fit -- the full "HIGH U.S. TEMPS" is 63px at the smallest narrow font
    against a 58px budget. "YESTERDAY" is only accurate for the three
    metrics sourced from /api/v1/yesterday; snowfall's window is the rolling
    last-24h of /api/v1/snow/reports, so it gets its own wording."""
    n = str(count)
    if metric == "Extreme Low Temp":
        return ["LOW U.S. TEMPS", "TOP " + n + " YESTERDAY", "LOW US TEMP", "TOP " + n, COLD_COL]
    if metric == "Extreme Rain":
        return ["MOST U.S. RAIN", "TOP " + n + " YESTERDAY", "MOST US RAIN", "TOP " + n, RAIN_COL]
    if metric == "Extreme Snowfall":
        return ["MOST U.S. SNOW", "TOP " + n + " LAST 24H", "MOST US SNOW", "TOP " + n, SNOW_COL]
    return ["HIGH U.S. TEMPS", "TOP " + n + " YESTERDAY", "HIGH US TEMP", "TOP " + n, HOT_COL]

def art_metrics(c):
    wide = c.width >= 128
    art_w = ART_W_WIDE if wide else ART_W_NARROW
    art_inset = 8 if wide else 0
    gap = 6 if wide else 2
    right_x = 10 if wide else 1
    head_left = art_inset + art_w + gap
    right_edge = c.width - right_x
    return [wide, art_inset, head_left, right_edge]

def draw_word(c, word, x, art_w, color, font, char_h):
    """`word` spelled out one letter per row, centered in the art column --
    used for HIGH/LOW instead of an icon: there's no built-in glyph for
    "hot"/"cold" the way sun/moon usually stand in for them, and a sun icon
    for a hot reading reads fine but the built-in "moon" (a thin crescent)
    doesn't read as "cold" at a glance, so a plain word replaces both."""
    total_h = len(word) * char_h + (len(word) - 1)
    y = (c.height - total_h) // 2
    cx = x + art_w // 2
    for ch in word.elems():
        c.text(ch, cx, y, font = font, color = color, align = "center")
        y += char_h + 1

def draw_identity(c, metric, wide, x):
    if metric == "Extreme Snowfall":
        art = SNOWFLAKE_ART if wide else SNOWFLAKE_ART_SMALL
        y = 8 if wide else 12
        c.sprite(art, x, y, legend = SNOWFLAKE_LEGEND)
        return
    if metric == "Extreme Rain":
        scale = 2 if wide else 1
        y = 8 if wide else 12
        c.icon("drop", x, y, color = RAIN_COL, scale = scale)
        return
    word = "HIGH" if metric == "Extreme High Temp" else "LOW"
    col = HOT_COL if metric == "Extreme High Temp" else COLD_COL
    art_w = ART_W_WIDE if wide else ART_W_NARROW
    font, char_h = ("5x7", 7) if wide else ("4x5", 5)
    draw_word(c, word, x, art_w, col, font, char_h)

def current_index(ctx, count):
    """Which rank to show right now -- the catalog's standard way to cycle
    through more items than fit as separate manifest pages (60s per item,
    wrapping at `count`). `debugframe` is an undeclared, manifest-invisible
    input for `gdn render --input debugframe=N` to preview a specific one."""
    dbg = str(ctx.inputs.get("debugframe", "")).strip()
    if dbg != "":
        return int(dbg) % count
    return (ctx.now.unix // 60) % count

def draw_rank(c, ctx):
    metric = str(ctx.inputs.get("metric", "Extreme High Temp"))
    count = int(str(ctx.inputs.get("count", "5")))
    index = current_index(ctx, count)
    rows, reason = fetch_rows(metric)

    if reason == "error":
        message_card(c, NODATA_BG, "DATA UNAVAILABLE", NODATA_TITLE,
                      "TRY AGAIN LATER", NODATA_SUB, narrow_sub = "TRY LATER")
        return
    if reason == "empty":
        title, sub, nt, ns = empty_copy(metric)
        message_card(c, EMPTY_BG, title, EMPTY_TITLE, sub, EMPTY_SUB,
                      narrow_title = nt, narrow_sub = ns)
        return

    n = count if count < len(rows) else len(rows)
    if index >= n:
        message_card(c, BG, "THAT'S ALL", END_TITLE, "FOR NOW", END_SUB)
        return

    row = rows[index]
    wide, art_inset, head_left, right_edge = art_metrics(c)
    c.fill(BG)
    draw_identity(c, metric, wide, art_inset)

    # The rank number is drawn as its own token, separate from fit_forms'
    # word-boundary fitting on the label. Baking "#1 " onto the front of the
    # label and fitting that as one string used to backfire: fit_forms saw
    # the rank's own trailing space as a legitimate place to drop everything
    # after it, so a label with no internal space to back off to instead
    # ("#1 RIVERSIDE" clipped straight to "#1", losing the city entirely).
    rank_tag = "#" + str(index + 1)
    forms = [row["label"], row["label"].split(",")[0]]

    if not wide:
        rank_font = "4x5"
        rank_w = c.text_width(rank_tag, rank_font)
        label_left = head_left + rank_w + 2
        maxw = right_edge - label_left
        if maxw < 12:
            maxw = 12
        c.text(rank_tag, head_left, 0, font = rank_font, color = LABEL_COL)
        h = fit_forms(c, forms, ["4x5"], maxw)
        c.text(h[1], label_left, 0, font = h[0], color = LABEL_COL)
        maxw = right_edge - head_left
        b = fit_clip(c, row["value"], ["10x16", "6x8", "5x7", "4x5"], maxw)
        c.text(b[1], head_left, 7, font = b[0], color = INK)
        # Sub sits on its own row at the bottom, clear of the hero: even at
        # 10x16 (16 tall, rows 7-22) it leaves row 23 as a buffer before the
        # sub's row 24 -- narrow never picks a taller hero font than that.
        if row["sub"] != "":
            c.text(clip(c, row["sub"], "4x5", maxw), right_edge, 24,
                   font = "4x5", color = NOTE_COL, align = "right")
        return

    # Wide: a compact meta row up top (rank + city, sub-note opposite it),
    # then the hero gets the *entire* width beneath it on its own row. An
    # earlier version put the sub-note below the hero instead -- at 16x20
    # the hero spans rows 8-27, which ran straight through a row-24 sub-note
    # for 4 rows. Keeping them on separate bands instead of stacked closer
    # removes the overlap instead of shrinking the hero to dodge it.
    sub_w = 0
    sub_font = "4x5"
    sub_text = ""
    if row["sub"] != "":
        s = fit_clip(c, row["sub"], ["5x7", "4x5"], 74)
        sub_font, sub_text = s[0], s[1]
        sub_w = c.text_width(sub_text, sub_font)

    rank_font = "5x7"
    rank_w = c.text_width(rank_tag, rank_font)
    label_left = head_left + rank_w + 3
    head_maxw = (right_edge - (sub_w + 4 if sub_w > 0 else 0)) - label_left
    if head_maxw < 24:
        head_maxw = 24
    c.text(rank_tag, head_left, 0, font = rank_font, color = LABEL_COL)
    h = fit_forms(c, forms, ["5x7", "4x5"], head_maxw)
    c.text(h[1], label_left, 0, font = h[0], color = LABEL_COL)
    if sub_w > 0:
        c.text(sub_text, right_edge, 0, font = sub_font, color = NOTE_COL, align = "right")

    hero_maxw = right_edge - head_left
    b = fit_clip(c, row["value"], ["16x20", "10x16", "6x8"], hero_maxw)
    BIG_H = {"16x20": 20, "10x16": 16, "6x8": 8}
    by = 8 + (20 - BIG_H[b[0]]) // 2
    c.text(b[1], head_left, by, font = b[0], color = INK)

def intro(c, ctx):
    metric = str(ctx.inputs.get("metric", "Extreme High Temp"))
    count = int(str(ctx.inputs.get("count", "5")))
    title, sub, narrow_title, narrow_sub, color = banner_copy(metric, count)
    message_card(c, BG, title, color, sub, NODATA_SUB,
                 narrow_title = narrow_title, narrow_sub = narrow_sub)

def ranked(c, ctx):
    draw_rank(c, ctx)
