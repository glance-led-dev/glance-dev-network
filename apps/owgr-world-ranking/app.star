# OWGR - World Ranking (192x32).
#
# DESIGN. A broadcast rankings graphic on a black ground: gold for the number
# one, silver and bronze tiles for two and three, slate tiles below that, and
# a green / red / grey movement chip on every row. Every page keeps EDGE (4 px)
# clear on both sides so it reads as its own unit in the scroll stream.
#
#   1 leader   gold No.1 medallion, flag, name, average points, lead over No.2
#   2 board1   positions 2-7, two columns of three
#   3 board2   positions 8-13
#   4 movers   biggest climbers and fallers inside the top 50 this week
#
# Data: the Official World Golf Ranking's own site API (apiweb.owgr.com) --
# free, no key, no User-Agent needed. One 50-row page (~29 KB) drives all four
# pages. Rankings publish on Mondays, so the app refreshes hourly and caches
# for an hour.
#
# Region filter: regionId narrows the list to players from one OWGR region.
# Ranks shown are always WORLD ranks (a European list reads 2, 4, 9 ...);
# the hero names the region ("EUROPE NO.1") and adds the world rank when the
# regional leader isn't world No.1.

RANK_URL = "https://apiweb.owgr.com/api/owgr/rankings/getRankings"
TTL = 3600
DEPTH = 50

# label -> (regionId, hero label)
REGIONS = {
    "World": (0, "WORLD"),
    "Europe": (4, "EUROPE"),
    "North America": (6, "N.AMERICA"),
    "Asia": (3, "ASIA"),
    "Australasia": (2, "AUSTRALASIA"),
    "Japan": (5, "JAPAN"),
    "Africa": (1, "AFRICA"),
    "South America": (7, "S.AMERICA"),
}

EDGE = 4

BG = "#000000"
GOLD = "#FFC72C"
GOLD_HI = "#FFE58A"
GOLD_DK = "#9A6A00"
SILVER = "#C9D3DE"
BRONZE = "#E0894A"
SLATE = "#1B2A40"
LINE = "#23324A"
TEXT = "#F4F7FB"
MUTED = "#8494AB"
DIM = "#4A5A72"
UP = "#2BE36B"
DOWN = "#FF4B4B"
FLAT = "#5C6B82"
NEW = "#FFB020"

# Lit glyph height per font (for vertical centring).
FONTH = {"4x5": 5, "5x7": 7, "4x7": 7, "3x4": 4, "8x12": 12, "9x12_bold": 12,
         "10x16": 16, "10x16_bold": 16, "7x12": 12, "16x20": 20}

# Bitmap fonts have no accented glyphs and skip them silently. Fold to ASCII.
ASCII_FOLD = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A", "Æ": "AE",
    "á": "a", "à": "a", "â": "a", "ä": "a", "ã": "a", "å": "a", "æ": "ae",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E", "é": "e", "è": "e", "ê": "e", "ë": "e",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I", "í": "i", "ì": "i", "î": "i", "ï": "i",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O", "Ø": "O",
    "ó": "o", "ò": "o", "ô": "o", "ö": "o", "õ": "o", "ø": "o",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U", "ú": "u", "ù": "u", "û": "u", "ü": "u",
    "Ç": "C", "ç": "c", "Ñ": "N", "ñ": "n", "ß": "SS", "Š": "S", "š": "s",
    "Ž": "Z", "ž": "z", "Č": "C", "č": "c", "Ł": "L", "ł": "l", "'": "", "’": "",
}

# ---------------------------------------------------------------------------
# Pixel flags, 10x7, keyed by OWGR iocCode. Black stripes are drawn in a dim
# grey (K) so they still read on an unlit panel.
FLAG_W = 10
FLAG_H = 7
FLAG_LEGEND = {
    "R": "#FF2A2A", "W": "#FFFFFF", "B": "#2B5BFF", "N": "#2440B8",
    "G": "#10B84A", "Y": "#FFD21A", "K": "#3A3A3A", "O": "#FF8A1F",
    "L": "#7CC8FF", "S": "#FF9A2E", "D": "#B07A2A", "T": "#1C2E9E",
}

FLAGS = {
    "USA": ["NNNNRRRRRR", "NWNNWWWWWW", "NNWNRRRRRR", "NNNNWWWWWW",
            "RRRRRRRRRR", "WWWWWWWWWW", "RRRRRRRRRR"],
    "ENG": ["WWWWRRWWWW", "WWWWRRWWWW", "WWWWRRWWWW", "RRRRRRRRRR",
            "WWWWRRWWWW", "WWWWRRWWWW", "WWWWRRWWWW"],
    "NIR": ["WWWWRRWWWW", "WWWWYYWWWW", "WWWWWWWWWW", "RRRWRRWRRR",
            "WWWWWWWWWW", "WWWWRRWWWW", "WWWWRRWWWW"],
    "SCO": ["WWBBBBBBWW", "BBWBBBBWBB", "BBBWBBWBBB", "BBBBWWBBBB",
            "BBBWBBWBBB", "BBWBBBBWBB", "WWBBBBBBWW"],
    "WAL": ["WWWWWWWWWW", "WWWWWWRRWW", "WWRRRRRWWW", "WRRRRRRWWW",
            "GGRGGRGGGG", "GGGGGGGGGG", "GGGGGGGGGG"],
    "IRL": ["GGGWWWWOOO"] * 7,
    "ITA": ["GGGWWWWRRR"] * 7,
    "FRA": ["BBBWWWWRRR"] * 7,
    "BEL": ["KKKYYYYRRR"] * 7,
    "PER": ["RRRWWWWRRR"] * 7,
    "MEX": ["GGGWWWWRRR", "GGGWWWWRRR", "GGGWDDWRRR", "GGGWDDWRRR",
            "GGGWGGWRRR", "GGGWWWWRRR", "GGGWWWWRRR"],
    "CAN": ["RRWWWWWWRR", "RRWWRRWWRR", "RRWRRRRWRR", "RRWWRRWWRR",
            "RRWWWRWWRR", "RRWWWWWWRR", "RRWWWWWWRR"],
    "ESP": ["RRRRRRRRRR", "RRRRRRRRRR", "YYYYYYYYYY", "YYYYYYYYYY",
            "YYYYYYYYYY", "RRRRRRRRRR", "RRRRRRRRRR"],
    "GER": ["KKKKKKKKKK", "KKKKKKKKKK", "RRRRRRRRRR", "RRRRRRRRRR",
            "RRRRRRRRRR", "YYYYYYYYYY", "YYYYYYYYYY"],
    "AUT": ["RRRRRRRRRR", "RRRRRRRRRR", "WWWWWWWWWW", "WWWWWWWWWW",
            "WWWWWWWWWW", "RRRRRRRRRR", "RRRRRRRRRR"],
    "NED": ["RRRRRRRRRR", "RRRRRRRRRR", "WWWWWWWWWW", "WWWWWWWWWW",
            "WWWWWWWWWW", "BBBBBBBBBB", "BBBBBBBBBB"],
    "PAR": ["RRRRRRRRRR", "RRRRRRRRRR", "WWWWWWWWWW", "WWWWGGWWWW",
            "WWWWWWWWWW", "BBBBBBBBBB", "BBBBBBBBBB"],
    "ARG": ["LLLLLLLLLL", "LLLLLLLLLL", "WWWWWWWWWW", "WWWWYYWWWW",
            "WWWWWWWWWW", "LLLLLLLLLL", "LLLLLLLLLL"],
    "IND": ["SSSSSSSSSS", "SSSSSSSSSS", "WWWWWWWWWW", "WWWWTTWWWW",
            "WWWWWWWWWW", "GGGGGGGGGG", "GGGGGGGGGG"],
    "THA": ["RRRRRRRRRR", "WWWWWWWWWW", "TTTTTTTTTT", "TTTTTTTTTT",
            "TTTTTTTTTT", "WWWWWWWWWW", "RRRRRRRRRR"],
    "COL": ["YYYYYYYYYY", "YYYYYYYYYY", "YYYYYYYYYY", "YYYYYYYYYY",
            "BBBBBBBBBB", "BBBBBBBBBB", "RRRRRRRRRR"],
    "VEN": ["YYYYYYYYYY", "YYYYYYYYYY", "BBBWBBWBBB", "BBWBBBBWBB",
            "BBBBBBBBBB", "RRRRRRRRRR", "RRRRRRRRRR"],
    "SWE": ["BBBYBBBBBB", "BBBYBBBBBB", "BBBYBBBBBB", "YYYYYYYYYY",
            "BBBYBBBBBB", "BBBYBBBBBB", "BBBYBBBBBB"],
    "DEN": ["RRRWRRRRRR", "RRRWRRRRRR", "RRRWRRRRRR", "WWWWWWWWWW",
            "RRRWRRRRRR", "RRRWRRRRRR", "RRRWRRRRRR"],
    "FIN": ["WWWBWWWWWW", "WWWBWWWWWW", "WWWBWWWWWW", "BBBBBBBBBB",
            "WWWBWWWWWW", "WWWBWWWWWW", "WWWBWWWWWW"],
    "NOR": ["RRWBWRRRRR", "RRWBWRRRRR", "WWWBWWWWWW", "BBBBBBBBBB",
            "WWWBWWWWWW", "RRWBWRRRRR", "RRWBWRRRRR"],
    "KOR": ["WWWWWWWWWW", "KWWWRRWWWK", "WKWRRRRWKW", "WWWBBBBWWW",
            "WKWWBBWWKW", "KWWWWWWWWK", "WWWWWWWWWW"],
    "JPN": ["WWWWWWWWWW", "WWWWRRWWWW", "WWWRRRRWWW", "WWWRRRRWWW",
            "WWWRRRRWWW", "WWWWRRWWWW", "WWWWWWWWWW"],
    "AUS": ["WNRNWNNNNN", "RRRRRNNWNN", "WNRNWNNNNW", "NNNNNNWNNN",
            "NNNNNNNNNN", "NNWNNNNWNN", "NNNNNNNNNN"],
    "NZL": ["WNRNWNNNNN", "RRRRRNNRNN", "WNRNWNNNNR", "NNNNNNRNNN",
            "NNNNNNNNNN", "NNNNNNNRNN", "NNNNNNNNNN"],
    "RSA": ["GWRRRRRRRR", "YGWRRRRRRR", "KYGWWWWWWW", "KKYGGGGGGG",
            "KYGWWWWWWW", "YGWBBBBBBB", "GWBBBBBBBB"],
    "ZIM": ["WGGGGGGGGG", "WWYYYYYYYY", "WWWRRRRRRR", "WRWWKKKKKK",
            "WWWRRRRRRR", "WWYYYYYYYY", "WGGGGGGGGG"],
    "CHI": ["BBBBWWWWWW", "BWWBWWWWWW", "BWWBWWWWWW", "BBBBWWWWWW",
            "RRRRRRRRRR", "RRRRRRRRRR", "RRRRRRRRRR"],
    "TPE": ["BBBBBRRRRR", "BBWBBRRRRR", "BWWWBRRRRR", "BBWBBRRRRR",
            "RRRRRRRRRR", "RRRRRRRRRR", "RRRRRRRRRR"],
    "PHI": ["WBBBBBBBBB", "WWBBBBBBBB", "WWWBBBBBBB", "WYWWBBBBBB",
            "WWWRRRRRRR", "WWRRRRRRRR", "WRRRRRRRRR"],
    "CHN": ["RRRRYRRRRR", "RYYRRYRRRR", "RYYRRRRRRR", "RRRRRYRRRR",
            "RRRRYRRRRR", "RRRRRRRRRR", "RRRRRRRRRR"],
    "HKG": ["RRRRRRRRRR", "RRRRRRRRRR", "RRRRWWRRRR", "RRRWWWWRRR",
            "RRRRWWRRRR", "RRRRRRRRRR", "RRRRRRRRRR"],
    "UAE": ["RRRGGGGGGG", "RRRGGGGGGG", "RRRWWWWWWW", "RRRWWWWWWW",
            "RRRWWWWWWW", "RRRKKKKKKK", "RRRKKKKKKK"],
}

def draw_flag(c, code, x, y, scale = 1):
    """10x7 pixel flag (scaled), or the 3-letter code when we have no art."""
    rows = FLAGS.get(code)
    if rows:
        c.sprite(rows, x, y, legend = FLAG_LEGEND, scale = scale)
        return
    if scale > 1:
        c.rect(x, y, x + FLAG_W * scale - 1, y + FLAG_H * scale - 1, outline = DIM)
        c.text(code, x + FLAG_W * scale // 2, y + (FLAG_H * scale - 5) // 2,
               font = "4x5", color = MUTED, align = "center")
    else:
        c.text(code, x, y + 2, font = "3x4", color = MUTED)

# ---------------------------------------------------------------------------
# Data

def fold(s):
    for k, v in ASCII_FOLD.items():
        if k in s:
            s = s.replace(k, v)
    return s

def clean_name(s):
    s = str(s or "")
    if "(" in s:
        s = s[:s.index("(")]
    return fold(s).upper().strip()

def region_of(ctx):
    key = ctx.inputs.get("region", "World")
    return REGIONS.get(key, REGIONS["World"])

def fetch(ctx):
    rid = region_of(ctx)[0]
    resp = http.get(RANK_URL, params = {
        "pageSize": str(DEPTH),
        "pageNumber": "1",
        "regionId": str(rid),
        "countryCode": "all",
    }, ttl_seconds = TTL)
    if resp["status_code"] != 200 or resp["json"] == None:
        return None
    body = resp["json"]
    if type(body) != "dict":
        return None
    raw = body.get("rankingsList") or []
    out = []
    for r in raw:
        p = r.get("player") or {}
        ctry = p.get("country") or {}
        rank = r.get("rank") or 0
        if rank <= 0:
            continue
        lw = r.get("lastWeekRank") or 0
        out.append({
            "rank": rank,
            "tied": r.get("isTied") == True,
            "lw": lw,
            "avg": r.get("pointsAverage") or 0.0,
            "first": clean_name(p.get("firstName")),
            "last": clean_name(p.get("lastName")),
            "ioc": clean_name(ctry.get("iocCode") or ctry.get("code3") or ""),
        })
    if len(out) == 0:
        return None

    # Namesakes (three KIMs in Asia's top 10) get initials on the boards.
    seen = {}
    for e in out:
        seen[e["last"]] = seen.get(e["last"], 0) + 1
    for e in out:
        if seen[e["last"]] > 1 and e["first"]:
            ini = ""
            for w in e["first"].replace("-", " ").split(" "):
                if w:
                    ini += w[0] + "."
            e["short"] = ini + e["last"]
    return out

# ---------------------------------------------------------------------------
# Helpers

def rank_label(e):
    return ("T" if e["tied"] else "") + str(e["rank"])

def move_of(e):
    if e["lw"] <= 0:
        return None
    return e["lw"] - e["rank"]

def fmt2(x):
    """Two-decimal string without fmt helpers: 17.7369 -> 17.74."""
    n = int(x * 100 + 0.5)
    whole = n // 100
    frac = n % 100
    return "%d.%s" % (whole, ("0" + str(frac)) if frac < 10 else str(frac))

def arrow(c, x, y, up, col):
    """5x3 solid triangle; (x, y) is the top-left of its box."""
    if up:
        c.pixel(x + 2, y, col)
        c.rect(x + 1, y + 1, x + 3, y + 1, fill = col)
        c.rect(x, y + 2, x + 4, y + 2, fill = col)
    else:
        c.rect(x, y, x + 4, y, fill = col)
        c.rect(x + 1, y + 1, x + 3, y + 1, fill = col)
        c.pixel(x + 2, y + 2, col)

def move_width(c, e):
    m = move_of(e)
    if m == None:
        return c.text_width("NEW", font = "4x5")
    if m == 0:
        return 5
    return 6 + c.text_width(str(abs(m)), font = "4x5")

def draw_move(c, e, xr, y):
    """Right-aligned movement chip ending at xr; y is the 7 px row top."""
    m = move_of(e)
    w = move_width(c, e)
    x = xr - w + 1
    if m == None:
        c.text("NEW", x, y + 1, font = "4x5", color = NEW)
    elif m == 0:
        c.rect(x, y + 3, x + 4, y + 3, fill = FLAT)
    else:
        col = UP if m > 0 else DOWN
        arrow(c, x, y + 2, m > 0, col)
        c.text(str(abs(m)), x + 6, y + 1, font = "4x5", color = col)
    return x

def fit_name(c, e, maxw, fonts):
    return fit_text(c, e.get("short") or e["last"], maxw, fonts)

def fit_text(c, name, maxw, fonts):
    """Largest font that fits; then the first word of a compound; then clip."""
    for f in fonts:
        if c.text_width(name, font = f) <= maxw:
            return (name, f)
    small = fonts[-1]
    for sep in ["-", " "]:
        if sep in name:
            parts = name.split(sep)
            head = parts[0]
            if len(head) > 3:
                for f in fonts:
                    if c.text_width(head, font = f) <= maxw:
                        return (head, f)
    # Hard clip, marked with a trailing dot so the cut reads as deliberate.
    for n in range(len(name) - 1, 0, -1):
        s = name[:n] + "."
        if c.text_width(s, font = small) <= maxw:
            return (s, small)
    return (name[:1], small)

def tile_color(rank):
    if rank == 1:
        return (GOLD, "#000000")
    if rank == 2:
        return (SILVER, "#000000")
    if rank == 3:
        return (BRONZE, "#000000")
    return (SLATE, TEXT)

# ---------------------------------------------------------------------------
# Screens

# 25x25 coin: d rim, G face, H glint, S shade (generated, round at r 10/12).
COIN = [
    "..........ddddd..........",
    ".......ddddddddddd.......",
    ".....dddddGGGGGddddd.....",
    "....dddHHHGGGGGGGGddd....",
    "...dddHHHGGGGGGGGGGddd...",
    "..dddHHHGGGGGGGGGGGGddd..",
    "..ddHHGGGGGGGGGGGGGGGdd..",
    ".ddHHHGGGGGGGGGGGGGGGGdd.",
    ".ddHHGGGGGGGGGGGGGGGGGdd.",
    ".ddHGGGGGGGGGGGGGGGGGGdd.",
    "ddGGGGGGGGGGGGGGGGGGGGGdd",
    "ddGGGGGGGGGGGGGGGGGGGGGdd",
    "ddGGGGGGGGGGGGGGGGGGGGGdd",
    "ddGGGGGGGGGGGGGGGGGGGGGdd",
    "ddGGGGGGGGGGGGGGGGGGGGGdd",
    ".ddGGGGGGGGGGGGGGGGGGSdd.",
    ".ddGGGGGGGGGGGGGGGGGSSdd.",
    ".ddGGGGGGGGGGGGGGGGSSSdd.",
    "..ddGGGGGGGGGGGGGGGSSdd..",
    "..dddGGGGGGGGGGGGSSSddd..",
    "...dddGGGGGGGGGGSSSddd...",
    "....dddGGGGGGGGSSSddd....",
    ".....dddddGGGGGddddd.....",
    ".......ddddddddddd.......",
    "..........ddddd..........",
]

def medallion(c, cx, cy, label, lit):
    """Gold No.1 coin centred on (cx, cy), numeral in black."""
    if lit:
        legend = {"d": GOLD_DK, "G": GOLD, "H": GOLD_HI, "S": "#E0A000"}
    else:
        legend = {"d": "#232833", "G": "#3A414D", "H": "#4A5260", "S": "#323843"}
    c.sprite(COIN, cx - 12, cy - 12, legend = legend)
    f = "10x16_bold"
    w = c.text_width(label, font = f)
    c.text(label, cx - w // 2 + 1, cy - 7, font = f, color = "#000000" if lit else "#6B7482")

def unavailable(c, ctx):
    c.fill(BG)
    medallion(c, EDGE + 12, 16, "?", False)
    x = EDGE + 30
    c.text("WORLD GOLF RANKING", x, 7, font = "5x7", color = TEXT)
    c.text("RANKINGS UNAVAILABLE - BACK SOON", x, 19, font = "4x5", color = MUTED)

def leader(c, ctx):
    data = fetch(ctx)
    if data == None:
        unavailable(c, ctx)
        return
    region = region_of(ctx)
    e = data[0]
    c.fill(BG)

    # Medallion: region position (always 1) in the coin.
    medallion(c, EDGE + 12, 16, "1", True)

    # Right block: average points and the lead over the next man.
    rx = c.width - EDGE - 1
    avg = fmt2(e["avg"])
    vfont = "9x12_bold"
    vw = c.text_width(avg, font = vfont)
    lead_txt = ""
    if len(data) > 1:
        lead_txt = "+" + fmt2(e["avg"] - data[1]["avg"])
    block_w = max(vw, c.text_width("AVG PTS", font = "4x5"))
    if lead_txt:
        block_w = max(block_w, c.text_width(lead_txt + " LEAD", font = "4x5"))
    bx = rx - block_w + 1
    c.text("AVG PTS", rx, 4, font = "4x5", color = MUTED, align = "right")
    c.text(avg, rx + 1, 10, font = vfont, color = TEXT, align = "right")
    if region[0] != 0 and e["rank"] != 1:
        c.text("WORLD NO." + rank_label(e), rx, 24, font = "4x5", color = GOLD, align = "right")
    elif lead_txt:
        lw = c.text_width(" LEAD", font = "4x5")
        c.text(" LEAD", rx, 24, font = "4x5", color = MUTED, align = "right")
        c.text(lead_txt, rx - lw, 24, font = "4x5", color = UP, align = "right")
    divx = bx - 4
    c.vline(divx, 4, 25, LINE)

    # Name lockup.
    x = EDGE + 30
    maxw = divx - 3 - x
    draw_flag(c, e["ioc"], x, 4)
    fx = x + FLAG_W + 3
    # Gold chip, right-aligned to the divider: "WORLD NO.1" / "EUROPE NO.1".
    # The chip wins over the first name, which steps down 5x7 -> 4x7 -> "S.".
    first = e["first"]
    plan = []
    for tag in [region[1] + " NO.1", region[1], "NO.1"]:
        plan.append((tag, first, "5x7"))
        plan.append((tag, first, "4x7"))
    plan.append(("NO.1", first[:1] + ".", "5x7"))
    fit = None
    for step in plan:
        tag = step[0]
        tw = c.text_width(tag, font = "4x5")
        tx = divx - 3 - tw
        if c.text_width(step[1], font = step[2]) <= tx - 4 - fx:
            fit = (step[1], step[2])
            break
    c.rect(tx - 1, 4, tx + tw - 1, 10, fill = GOLD)
    c.text(tag, tx, 5, font = "4x5", color = "#000000")
    if fit != None:
        c.text(fit[0], fx, 4, font = fit[1], color = MUTED)
    name, f = fit_name(c, e, maxw, ["10x16_bold", "10x16", "9x12_bold", "8x12", "7x12"])
    fh = FONTH.get(f, 12)
    c.text(name, x, 29 - fh, font = f, color = TEXT)

def board(c, ctx, start):
    data = fetch(ctx)
    if data == None:
        unavailable(c, ctx)
        return
    c.fill(BG)
    rows = data[start:start + 6]
    if len(rows) == 0:
        unavailable(c, ctx)
        return
    colw = (c.width - 2 * EDGE - 6) // 2
    tw = 0
    for e in rows:
        tw = max(tw, c.text_width(rank_label(e), font = "4x5"))
    tw = tw + 4
    for i in range(len(rows)):
        e = rows[i]
        col = i // 3
        r = i % 3
        x0 = EDGE + col * (colw + 6)
        xr = x0 + colw - 1
        y = 4 + r * 9
        bg, fg = tile_color(e["rank"])
        c.rect(x0, y, x0 + tw - 1, y + 6, fill = bg)
        c.text(rank_label(e), x0 + tw // 2 + 1, y + 1, font = "4x5", color = fg, align = "center")
        fx = x0 + tw + 2
        draw_flag(c, e["ioc"], fx, y)
        nx = fx + FLAG_W + 3
        mx = draw_move(c, e, xr, y)
        name, f = fit_name(c, e, mx - 3 - nx, ["5x7", "4x7"])
        c.text(name, nx, y, font = f, color = TEXT)
    c.vline(EDGE + colw + 2, 4, 25, LINE)

def board1(c, ctx):
    board(c, ctx, 1)

def board2(c, ctx):
    board(c, ctx, 7)

def movers(c, ctx):
    data = fetch(ctx)
    if data == None:
        unavailable(c, ctx)
        return
    c.fill(BG)
    ups = [e for e in data if move_of(e) != None and move_of(e) > 0]
    downs = [e for e in data if move_of(e) != None and move_of(e) < 0]
    ups = sorted(ups, key = lambda e: (-move_of(e), e["rank"]))[:2]
    downs = sorted(downs, key = lambda e: (move_of(e), e["rank"]))[:2]
    colw = (c.width - 2 * EDGE - 6) // 2

    # One chip width and one rank-tile width for the whole page.
    cw = 0
    tw = 0
    for e in ups + downs:
        cw = max(cw, c.text_width(str(abs(move_of(e))), font = "4x5"))
        tw = max(tw, c.text_width(rank_label(e), font = "4x5"))
    cw = cw + 10
    tw = tw + 4

    heads = [("CLIMBERS", UP, ups), ("FALLERS", DOWN, downs)]
    for col in range(2):
        title, hc, lst = heads[col]
        x0 = EDGE + col * (colw + 6)
        xr = x0 + colw - 1
        hw = c.text_width(title, font = "4x5")
        c.text(title, x0, 4, font = "4x5", color = hc)
        c.hline(x0 + hw + 2, 6, xr - (x0 + hw + 2) + 1, color.dim(hc, 35))
        if len(lst) == 0:
            c.text("NO MOVES", x0, 16, font = "5x7", color = FLAT)
            continue
        for i in range(len(lst)):
            e = lst[i]
            y = 12 + i * 9
            m = move_of(e)
            c.rect(x0, y, x0 + cw - 1, y + 6, fill = hc)
            arrow(c, x0 + 2, y + 2, m > 0, "#000000")
            c.text(str(abs(m)), x0 + 9, y + 1, font = "4x5", color = "#000000")
            fx = x0 + cw + 2
            draw_flag(c, e["ioc"], fx, y)
            nx = fx + FLAG_W + 3
            bg, fg = tile_color(e["rank"])
            c.rect(xr - tw + 1, y, xr, y + 6, fill = bg)
            c.text(rank_label(e), xr - tw + 1 + tw // 2 + 1, y + 1, font = "4x5", color = fg, align = "center")
            name, f = fit_name(c, e, xr - tw - 3 - nx, ["5x7", "4x7"])
            c.text(name, nx, y, font = f, color = TEXT)
    c.vline(EDGE + colw + 2, 4, 25, LINE)
