# MrNaturl My Holdings Earnings - earnings for the stocks you pick. Each one
# shows its result (actual EPS and the beat or miss) for 5 business days after
# it reports, then its next report date, before the open (AM) or after the
# close (PM), and the EPS estimate.
#
# The pick list holds every US company that reported earnings in the past
# year; type a ticker or name in the Glance app to search it.
#
# Data comes from MrNaturl's own static feed at /api/holdings/<letter>.json,
# rebuilt several times a day from Nasdaq's public earnings calendar and
# served from Cloudflare Pages. No API key.
#
# Same app.star ships as mrnaturl-holdings (64 wide) and
# mrnaturl-holdings-scroll (192 wide). The Scroll shows four stocks per page,
# the Glance LED two. Recent results come first, then upcoming reports, soonest
# first; when there is more than fits, the set shown moves along every 10
# minutes.

FEED_BASE = "https://mrnaturl-earnings.pages.dev/api/holdings/"

GOLD = "#d9b55a"      # headers
TICK = "#ffd76a"      # ticker symbols
GREEN = "#3fb950"     # beat
RED = "#f0504a"       # miss
AMBER = "#e8b020"     # AM: before the open
BLUE = "#2f6bff"      # PM: after the close
DIM = "#a6dcff"       # dates and estimates (light blue)
WHITE = "white"

PAGES = 8
ROTATE_SECONDS = 600

# --- the picked stocks -------------------------------------------------------

def picked(ctx):
    # A selection arrives as a list or as a comma separated string. Each
    # choice reads "TICKER NAME"; the ticker is the first word.
    raw = ctx.inputs.get("stocks", "")
    items = raw if type(raw) == "list" else str(raw).split(",")
    out = []
    for item in items:
        words = str(item).strip().split(" ")
        if len(words) == 0 or words[0] == "":
            continue
        sym = words[0].upper()
        if sym not in [p[0] for p in out]:
            out.append((sym, " ".join(words[1:])))
    return out

def letter(sym):
    ch = sym[0]
    return ch if ch.isalpha() else "0"

def get_letter(ch):
    resp = http.get(FEED_BASE + ch + ".json", ttl_seconds = 900)
    if resp["status_code"] != 200:
        return None
    return resp["json"].get("stocks", {})

def load_rows(stocks):
    # Returns (results, upcoming, ok). ok is False only when no feed answered.
    files = {}
    answered = False
    results = []
    upcoming = []
    undated = []
    for sym, name in stocks:
        ch = letter(sym)
        if ch not in files:
            files[ch] = get_letter(ch)
            if files[ch] != None:
                answered = True
        rec = None
        if files[ch] != None:
            rec = files[ch].get(sym)
        if rec == None:
            undated.append({"s": sym, "n": name, "d": "NO DATE", "w": "", "e": "--"})
            continue
        n = rec.get("n", name)
        if "lr" in rec:
            lr = rec["lr"]
            results.append((-lr.get("k", 0), {"s": sym, "n": n, "d": lr.get("d", ""),
                                              "e": lr.get("e", "--"), "a": lr.get("a", ""),
                                              "p": lr.get("p", ""), "b": lr.get("b", True)}))
        elif "nx" in rec:
            nx = rec["nx"]
            upcoming.append((nx.get("k", 0), {"s": sym, "n": n, "d": nx.get("d", ""),
                                              "w": nx.get("w", "TBA"), "e": nx.get("e", "--")}))
        else:
            undated.append({"s": sym, "n": n, "d": "NO DATE", "w": "", "e": "--"})
    results = [x[1] for x in sorted(results, key = lambda x: x[0])]
    upcoming = [x[1] for x in sorted(upcoming, key = lambda x: x[0])] + undated
    return results, upcoming, answered

# --- screens -----------------------------------------------------------------

def wide(c):
    return c.width >= 128

def screens(c, results, upcoming):
    per = 4 if wide(c) else 2
    out = []
    for i in range(0, len(results), per):
        out.append({"kind": "latest", "rows": results[i:i + per]})
    for i in range(0, len(upcoming), per):
        out.append({"kind": "next", "rows": upcoming[i:i + per]})
    return out

def pick(ctx, scr, page):
    n = len(scr)
    blocks = (n + PAGES - 1) // PAGES
    block = (ctx.now.unix // ROTATE_SECONDS) % blocks
    return scr[(block * PAGES + page) % n]

# --- drawing -----------------------------------------------------------------

def fit(c, text, maxw):
    if maxw <= 0:
        return ""
    if c.text_width(text, "4x5") <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i].rstrip(" ") + "."
        if c.text_width(candidate, "4x5") <= maxw:
            return candidate
    return ""

def when_color(w):
    if w == "AM":
        return AMBER
    if w == "PM":
        return BLUE
    return DIM

def result_color(r):
    if r.get("b", True):
        return GREEN
    return RED

def header(c, label, cols):
    left = 6 if wide(c) else 0
    edge = c.width - 1 - left
    c.text(label, left + 1, 1, font = "4x5", color = GOLD)
    if wide(c):
        c.text(cols[0], 134, 1, font = "4x5", color = GOLD, align = "right")
        c.text(cols[1], edge, 1, font = "4x5", color = GOLD, align = "right")
    c.line(left, 7, edge, 7, color = GOLD)

def row_wide(c, r, y):
    edge = 185
    c.text(r.get("s", ""), 6, y, font = "4x5", color = TICK)
    if r.get("a", "") == "":
        c.text(fit(c, r.get("n", ""), 72), 34, y, font = "4x5", color = WHITE)
        c.text(r.get("e", "--"), 134, y, font = "4x5", color = DIM, align = "right")
        w = r.get("w", "")
        ww = c.text_width(w, "4x5") + 5 if w != "" else 0
        if w != "":
            c.text(w, edge, y, font = "4x5", color = when_color(w), align = "right")
        c.text(r.get("d", ""), edge - ww, y, font = "4x5", color = DIM,
               align = "right")
    else:
        col = result_color(r)
        c.text(fit(c, r.get("n", ""), 46), 34, y, font = "4x5", color = WHITE)
        c.text(r.get("d", ""), 104, y, font = "4x5", color = DIM, align = "right")
        c.text(r.get("e", "--"), 134, y, font = "4x5", color = DIM, align = "right")
        c.text(r["a"], 162, y, font = "4x5", color = col, align = "right")
        c.text(r.get("p", ""), edge, y, font = "4x5", color = col, align = "right")

def row_small(c, r, y):
    c.text(r.get("s", ""), 1, y, font = "4x5", color = TICK)
    if r.get("a", "") == "":
        w = r.get("w", "")
        ww = c.text_width(w, "4x5") + 5 if w != "" else 0
        if w != "":
            c.text(w, 63, y, font = "4x5", color = when_color(w), align = "right")
        c.text(r.get("d", ""), 63 - ww, y, font = "4x5", color = DIM,
               align = "right")
        c.text("EST " + r.get("e", "--"), 1, y + 6, font = "4x5", color = DIM)
    else:
        col = result_color(r)
        word = "BEAT" if r.get("b", True) else "MISS"
        c.text(word, 63, y, font = "4x5", color = col, align = "right")
        c.text(r.get("d", ""), 63 - c.text_width(word, "4x5") - 5, y,
               font = "4x5", color = DIM, align = "right")
        c.text(r["a"], 1, y + 6, font = "4x5", color = col)
        c.text(r.get("p", ""), 63, y + 6, font = "4x5", color = col,
               align = "right")

def draw_screen(c, s):
    if s["kind"] == "next":
        header(c, "MY HOLDINGS  NEXT" if wide(c) else "NEXT",
               ["EST", "WHEN"])
    else:
        header(c, "MY HOLDINGS  RESULTS" if wide(c) else "RESULTS",
               ["EST", "ACTUAL"])
    rows = s["rows"]
    for i in range(len(rows)):
        if wide(c):
            row_wide(c, rows[i], 9 + 6 * i)
        else:
            row_small(c, rows[i], 9 + 12 * i)

def draw_message(c, line1, line2):
    title = "MY HOLDINGS EARNINGS" if wide(c) else "HOLDINGS"
    c.text(title, c.width // 2, 2, font = "6x8", color = GOLD, align = "center")
    c.text(line1, c.width // 2, 15, font = "4x5", color = DIM, align = "center")
    c.text(line2, c.width // 2, 22, font = "4x5", color = DIM, align = "center")

def draw_page(c, ctx, page):
    c.clear()
    stocks = picked(ctx)
    if len(stocks) == 0:
        if wide(c):
            draw_message(c, "PICK YOUR STOCKS", "IN THE GLANCE APP SETTINGS")
        else:
            draw_message(c, "PICK STOCKS", "IN SETTINGS")
        return
    results, upcoming, ok = load_rows(stocks)
    if not ok:
        if wide(c):
            draw_message(c, "FEED UNAVAILABLE", "CHECK BACK SOON")
        else:
            draw_message(c, "NO DATA", "TRY LATER")
        return
    draw_screen(c, pick(ctx, screens(c, results, upcoming), page))

def page_1(c, ctx):
    draw_page(c, ctx, 0)

def page_2(c, ctx):
    draw_page(c, ctx, 1)

def page_3(c, ctx):
    draw_page(c, ctx, 2)

def page_4(c, ctx):
    draw_page(c, ctx, 3)

def page_5(c, ctx):
    draw_page(c, ctx, 4)

def page_6(c, ctx):
    draw_page(c, ctx, 5)

def page_7(c, ctx):
    draw_page(c, ctx, 6)

def page_8(c, ctx):
    draw_page(c, ctx, 7)
