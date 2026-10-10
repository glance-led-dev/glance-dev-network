# Scholar Citations for a Glance SCROLL panel (192x32).
#
# DESIGN. Two levels, top and bottom. The top level says who: the
# researcher's name in white, and today's date in a pill of the chosen
# highlight colour at the right. The bottom level says how much they are cited:
# a bar chart of citations per year with no year or axis labels, the current
# year's bar in the highlight colour against light gray past years. To the right
# of the chart sit four numbers - total citations, h-index and i10-index in
# white, and this year's citations in the same colour as its bar - and under
# them this year compared
# with last year, green when ahead and red when behind. With no API key the
# panel shows a sample profile. Every failure gets a two-line card:
# what, and what to do.
#
# Data: SerpApi's google_scholar_author engine, one search per day.

TTL = 86400               # one search a day; refresh: is hourly only so the date turns over

INK = "#F4F7FF"
DIM = "#6E7A94"
PAST = "#B4B8C0"          # light gray: history stays quiet so this year's color leads
TOTALS = "#FFFFFF"        # total citations, h-index and i10: white, the resting color for numbers
GREEN = "#42FF78"
RED = "#FF4D5E"
AMBER = "#F0B44D"
AXIS = "#3C4658"

# The highlight dropdown's choices, lowercased. One colour marks everything that
# is "now": this year's bar, this year's count and the date pill behind today's
# date. Nine chosen by the app's owner, in dropdown order.
COLORS = {
    "red": "#FF2121",
    "orange": "#F2BE45",
    "yellow": "#FFF143",
    "green": "#AFDD22",
    "cyan": "#25F8CB",
    "blue": "#44CEF6",
    "purple": "#CCA4E3",
    "pink": "#FF0097",
    "white": "#F2FDFF",
}
DEFAULT_COLOR = "blue"

# The date inside the pill is black, except on the two darkest highlights
# (luminance 93-99 against the others' 169-249), where black text on the pill
# is too close to the pill itself and white reads instead.
PILL_WHITE_TEXT = ["red", "pink"]

# ---- geometry ----------------------------------------------------------------
# 6 px clear at both outer edges (x 6..185). Top level y 0..6; bottom level
# y 9..31. The stats are laid out from the right edge first; the chart takes
# whatever is left of them.
EDGEL = 6
EDGER = 185
TOPY = 0
CHART_TOP = 9
CHART_BOT = 30            # bars stand on this row; the axis line is y 31
COLGAP = 5                # between stat columns
STATMAX = 134             # widest the stats may get before values step down a
                          # font, leaving the chart 39 px: ten 3 px bars.
                          # Worst planned case - "12,345" / "123" / "456" /
                          # "1,234" at 6x9 - is exactly 134.
VALUE_FONTS = ["6x9", "6x8", "5x7"]
CARD_DIVX = 67

DEMO = {
    "name": "Ada Lovelace",
    "cites": 1840, "h": 21, "i10": 38,
    "graph": [[2017, 40], [2018, 62], [2019, 95], [2020, 130], [2021, 168],
              [2022, 214], [2023, 260], [2024, 318], [2025, 355], [2026, 198]],
}

# The planned worst case, drawn with the hidden _debugstate input set to "big".
BIG = {
    "name": "Worst Case Researcher",
    "cites": 12345, "h": 123, "i10": 456,
    "graph": [[2017, 610], [2018, 780], [2019, 905], [2020, 1020], [2021, 1180],
              [2022, 1310], [2023, 1450], [2024, 1620], [2025, 1890], [2026, 1234]],
}

ARROW_UP = """
..#..
.###.
#####
"""
ARROW_DN = """
#####
.###.
..#..
"""

# ---- text kit ------------------------------------------------------------------
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k].rstrip(), font) <= maxw:
            return t[:k].rstrip()
    return ""

def fit(c, text, fonts, maxw):
    """[font, text]: the largest font that fits, hard-clipped in the smallest."""
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    last = fonts[len(fonts) - 1]
    return [last, clip(c, text, last, maxw)]

FONTH = {"8x10": 10, "6x9": 9, "6x8": 8, "5x7": 7, "4x5": 5}

def get(obj, key, fallback = None):
    if type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def num(v):
    if type(v) == "int":
        return v
    if type(v) == "float":
        return int(v)
    digits = ""
    for ch in str(v).elems():
        if ch in "0123456789":
            digits += ch
    return int(digits) if digits != "" else 0

def commas(n):
    s = str(abs(n))
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return ("-" if n < 0 else "") + out

# ---- local date ----------------------------------------------------------------
# US Eastern, resolved here: no time API to fail (ctx.now is UTC).
# Standard offset in minutes east of UTC; US daylight saving runs from the
# 2nd Sunday in March 02:00 to the 1st Sunday in November 02:00.
EASTERN = -300
MONTH = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT",
         "NOV", "DEC"]

def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    """[year, month, day] for days since the Unix epoch (the inverse)."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [yoe + era * 400 + (1 if m <= 2 else 0), m, d]

def nth_sunday(y, m, n):
    wd = (days_from_civil(y, m, 1) + 4) % 7      # 0 = Sunday; 1970-01-01 was a Thursday
    return 1 + (7 - wd) % 7 + 7 * (n - 1)

def local_date(ctx):
    """[year, month, day] on a US Eastern wall clock."""
    std = EASTERN
    t = ctx.now.unix // 60
    y = ctx.now.year
    start = days_from_civil(y, 3, nth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = days_from_civil(y, 11, nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    off = std + 60 if (t >= start and t < end) else std
    return civil_from_days((ctx.now.unix + off * 60) // 86400)

# ---- profile id ----------------------------------------------------------------
# A Scholar ID is 12 characters of letters, digits, '-' and '_', and either of
# the last two can come first. On the panel, settings ride a render descriptor
# (GDN:W:H:app:pages:ttl:key-value_key-value). '_' separates one setting from
# the next, so an ID containing '_' is split apart before the app runs and the
# panel shows E500 -- while the IDE, which hands the value over whole, works.
# '-' is safe: a setting is split from its value at the FIRST '-' only, which
# is how a date like 2026-08-13 arrives intact. So '_' alone is typed as a
# stand-in, '.', which survives the descriptor (hostnames rely on it) and,
# unlike a space, still counts as the first character. It is turned back here;
# a real '_' is still accepted, for the IDE and anywhere the value arrives whole.
IDCHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
STANDIN = {".": "_"}

def scholar_id(raw):
    """The ID from what was entered: the bare ID with or without the stand-in,
    or, where the value arrives whole, a profile link (…?user=ID&hl=en)."""
    s = str(raw).strip()
    at = s.find("user=")
    if at >= 0:
        s = s[at + 5:]
    out = ""
    for ch in s.elems():
        ch = STANDIN.get(ch, ch)
        if ch not in IDCHARS:
            break
        out += ch
    return out

def cut_link(raw):
    """True when a pasted profile link reached the app cut at its first ':' --
    all that is left of "https://scholar.google.com/..." on the panel."""
    return str(raw).strip().lower() in ["http", "https"]

# ---- data ----------------------------------------------------------------------
def lookup(apikey, sid):
    """[status, profile]; status is "ok" or a CARDS key."""
    r = http.get("https://serpapi.com/search.json", params = {
        "engine": "google_scholar_author",
        "author_id": sid,
        "hl": "en",
        "num": "1",           # only the header stats are drawn; skip the article list
        "api_key": apikey,
    }, ttl_seconds = TTL)
    status = r["status_code"]
    if status == 401 or status == 403:
        return ["badkey", None]
    if status == 429:
        return ["limit", None]
    if status != 200 or r["json"] == None:
        return ["offline", None]
    data = r["json"]
    if str(get(data, "error", "")) != "":
        err = str(get(data, "error", "")).lower()
        if "run out" in err or "limit" in err:
            return ["limit", None]
        if "api key" in err:
            return ["badkey", None]
        return ["notfound", None]
    author = get(data, "author", None)
    if author == None:
        return ["notfound", None]
    cited = get(data, "cited_by", {})
    stats = {}
    for row in get(cited, "table", []):
        if type(row) != "dict":
            continue
        for k in row.keys():
            stats[k] = num(get(row[k], "all", 0))
    graph = []
    for g in get(cited, "graph", []):
        y = num(get(g, "year", 0))
        if y > 0:
            graph.append([y, num(get(g, "citations", 0))])
    return ["ok", {
        "name": str(get(author, "name", "")),
        "cites": stats.get("citations", 0),
        "h": stats.get("h_index", 0),
        "i10": stats.get("i10_index", 0),
        "graph": graph,
    }]

def series(graph, year):
    """Continuous [year, count] from the first cited year through this year;
    Scholar leaves out years with no citations."""
    counts = {}
    first = year
    for g in graph:
        counts[g[0]] = g[1]
        if g[0] < first:
            first = g[0]
    return [[y, counts.get(y, 0)] for y in range(first, year + 1)]

# ---- drawing -------------------------------------------------------------------
def highlight(ctx):
    """[pill colour, pill text colour] from the highlight dropdown."""
    name = str(ctx.inputs.get("color", "Blue")).strip().lower()
    if name not in COLORS:
        name = DEFAULT_COLOR
    return [COLORS[name], "white" if name in PILL_WHITE_TEXT else "black"]

def top_level(c, name, datestr, hl):
    """Name on the left; today's date in a pill of the highlight colour at the
    right edge."""
    w = c.text_width(datestr, "4x5") + 4
    c.badge(datestr, EDGER - w + 1, 0, color = hl[1], bg = hl[0], font = "4x5")
    right = EDGER - w - 3
    room = right - EDGEL + 1
    ft = fit(c, name.upper(), ["5x7", "4x5"], room)
    c.text(ft[1], EDGEL, TOPY, font = ft[0], color = INK)

def chart(c, rows, year, right, now):
    """Bars for each year from x 6 to `right`, no labels; this year in `now`.
    The tallest year fills the full height."""
    peak = 0
    for r in rows:
        if r[1] > peak:
            peak = r[1]
    c.hline(EDGEL, right, CHART_BOT + 1, AXIS)

    x0 = EDGEL
    avail = right - x0 + 1
    bw = 3
    step = 4
    if len(rows) * step - 1 > avail:
        bw = 2
        step = 3
    if len(rows) * step - 1 > avail:
        bw = 1
        step = 2
    keep = (avail + 1) // step
    if len(rows) > keep:
        rows = rows[len(rows) - keep:]
    hmax = CHART_BOT - CHART_TOP + 1
    x = x0
    for r in rows:
        h = (r[1] * hmax + peak - 1) // peak if r[1] > 0 else 0
        if h > 0:
            c.rect(x, CHART_BOT - h + 1, x + bw - 1, CHART_BOT,
                   fill = now if r[0] == year else PAST)
        x += step

def stats(c, p, rows, year, now):
    """Four labelled numbers, laid out from the right edge. Returns the x
    where the stats begin so the chart can take the rest."""
    this = rows[len(rows) - 1][1] if len(rows) > 0 else 0
    last = rows[len(rows) - 2][1] if len(rows) > 1 else 0
    cols = [["CITATIONS", commas(p["cites"]), TOTALS],
            ["H-IDX", commas(p["h"]), TOTALS],
            ["I10", commas(p["i10"]), TOTALS],
            [str(year), commas(this), now]]

    # One value font for every profile (6x9), so the panel doesn't change size
    # as the numbers grow; only past the planned worst case does it step down.
    vf = VALUE_FONTS[0]
    widths = []
    for f in VALUE_FONTS:
        widths = [max(c.text_width(col[0], "4x5"), c.text_width(col[1], f)) for col in cols]
        total = COLGAP * 3
        for w in widths:
            total += w
        vf = f
        if total <= STATMAX:
            break
    xs = [0, 0, 0, 0]
    xr = EDGER + 1
    for i in [3, 2, 1, 0]:
        xs[i] = xr - widths[i]
        xr = xs[i] - COLGAP
    # Label and value centered in each column: left-aligned, "2,269" ended
    # 6 px before "24" and the two read as one number.
    for i in range(4):
        lw = c.text_width(cols[i][0], "4x5")
        vw = c.text_width(cols[i][1], vf)
        c.text(cols[i][0], xs[i] + (widths[i] - lw) // 2, CHART_TOP, font = "4x5", color = DIM)
        c.text(cols[i][1], xs[i] + (widths[i] - vw) // 2, 17 + (9 - FONTH[vf]), font = vf,
               color = cols[i][2])

    statx = xs[0]
    diff = this - last
    col = GREEN if diff >= 0 else RED
    # Right-aligned at the edge, under this year's column; the arrow sits
    # 2 px left of the measured text.
    line = clip(c, commas(abs(diff)) + " VS " + str(year - 1), "4x5", EDGER - statx - 6)
    tx = EDGER + 1 - c.text_width(line, "4x5")
    c.text(line, tx, 27, font = "4x5", color = col)
    c.sprite(ARROW_UP if diff >= 0 else ARROW_DN, tx - 7, 27, color = col)
    return statx

def draw(c, p, year, datestr, hl):
    rows = series(p["graph"], year)
    top_level(c, p["name"], datestr, hl)
    statx = stats(c, p, rows, year, hl[0])
    chart(c, rows, year, statx - 7, hl[0])

GHOST = [3, 5, 8, 7, 11, 14, 18, 22, 16]

def card(c, head, sub, head_color):
    """What went wrong and what to do, beside a gray ghost of the chart so the
    app still says what it is."""
    c.text("SCHOLAR CITATIONS", EDGEL, TOPY, font = "5x7", color = DIM)
    c.hline(EDGEL + 1, CARD_DIVX - 3, 31, AXIS)
    x = EDGEL + 2
    for h in GHOST:
        c.rect(x, 31 - h, x + 3, 30, fill = AXIS)
        x += 6
    mid = (CARD_DIVX + 4 + EDGER) // 2
    ht = fit(c, head, ["6x8", "5x7", "4x5"], EDGER - CARD_DIVX - 4)
    c.text(ht[1], mid, 12, font = ht[0], color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", EDGER - CARD_DIVX - 4), mid, 24, font = "4x5",
           color = DIM, align = "center")

CARDS = {
    "offline": ["SERPAPI UNREACHABLE", "RETRIES NEXT REFRESH", AMBER],
    "badkey": ["KEY REJECTED", "CHECK YOUR SERPAPI KEY", RED],
    "limit": ["SEARCH LIMIT HIT", "SERPAPI QUOTA USED UP", RED],
    "noid": ["NO PROFILE ID", "ADD YOUR SCHOLAR ID", AMBER],
    "link": ["ID, NOT THE LINK", "ENTER THE PROFILE ID ONLY", AMBER],
    "notfound": ["PROFILE NOT FOUND", "CHECK THE SCHOLAR ID", AMBER],
}

def profile(c, ctx):
    c.fill("black")
    today = local_date(ctx)
    year = today[0]           # local, so New Year's Eve in Eastern is still last year
    datestr = MONTH[today[1] - 1] + " " + str(today[2]) + " " + str(today[0])
    apikey = str(ctx.inputs.get("apikey", "")).strip()
    rawid = ctx.inputs.get("scholarid", "")
    sid = scholar_id(rawid)
    dbg = str(ctx.inputs.get("_debugstate", "")).strip().lower()
    hl = highlight(ctx)

    if dbg in CARDS:
        card(c, CARDS[dbg][0], CARDS[dbg][1], CARDS[dbg][2])
        return
    if dbg == "big":
        draw(c, BIG, year, datestr, hl)
        return
    if apikey == "" or dbg == "demo":
        draw(c, DEMO, year, datestr, hl)
        return
    if cut_link(rawid):
        card(c, CARDS["link"][0], CARDS["link"][1], CARDS["link"][2])
        return
    if sid == "":
        card(c, CARDS["noid"][0], CARDS["noid"][1], CARDS["noid"][2])
        return
    res = lookup(apikey, sid)
    if res[0] != "ok":
        cd = CARDS[res[0]]
        card(c, cd[0], cd[1], cd[2])
        return
    draw(c, res[1], year, datestr, hl)
