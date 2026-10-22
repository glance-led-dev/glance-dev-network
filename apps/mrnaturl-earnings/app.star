# MrNaturl Earnings Calendar - the biggest US companies reporting earnings:
# today's reports with the EPS estimate and whether results come before the
# open (AM) or after the close (PM), then actual EPS and the beat or miss once
# they report; and the latest day's results.
#
# Data comes from MrNaturl's own static feed at /api/earnings.json, rebuilt
# several times a day from Nasdaq's public earnings calendar and served from
# Cloudflare Pages. No API key, no inputs.
#
# Same app.star ships as mrnaturl-earnings (64 wide) and
# mrnaturl-earnings-scroll (192 wide). The Scroll shows four companies per
# page, the Glance LED two. The eight pages walk through TODAY, then RESULTS;
# when there is more than fits, the set shown moves along every 10 minutes.

FEED_URL = "https://mrnaturl-earnings.pages.dev/api/earnings.json"

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

def get_data():
    resp = http.get(FEED_URL, ttl_seconds = 900)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def wide(c):
    return c.width >= 128

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

def reported(r):
    return r.get("a", "") != ""

def result_color(r):
    if r.get("b", True):
        return GREEN
    return RED

# --- screens: one kind (today or results) and up to 4 or 2 rows -----------

def screens(c, data):
    per = 4 if wide(c) else 2
    out = []
    t = data.get("today", {})
    rows = t.get("rows", [])
    if len(rows) == 0:
        out.append({"kind": "today", "label": t.get("label", ""), "rows": []})
    for i in range(0, len(rows), per):
        out.append({"kind": "today", "label": t.get("label", ""),
                    "rows": rows[i:i + per]})
    r = data.get("results", {})
    rows = r.get("rows", [])
    for i in range(0, len(rows), per):
        out.append({"kind": "results", "label": r.get("label", ""),
                    "rows": rows[i:i + per]})
    return out

def pick(c, ctx, data, page):
    scr = screens(c, data)
    n = len(scr)
    blocks = (n + PAGES - 1) // PAGES
    block = (ctx.now.unix // ROTATE_SECONDS) % blocks
    return scr[(block * PAGES + page) % n]

# --- drawing ----------------------------------------------------------------

def header(c, label, cols):
    left = 6 if wide(c) else 0
    edge = c.width - 1 - left
    c.text(label, left + 1, 1, font = "4x5", color = GOLD)
    if wide(c):
        c.text(cols[0], 134, 1, font = "4x5", color = GOLD, align = "right")
        c.text(cols[1], edge, 1, font = "4x5", color = GOLD, align = "right")
    elif cols[0] != "":
        c.text(cols[0], edge, 1, font = "4x5", color = GOLD, align = "right")
    c.line(left, 7, edge, 7, color = GOLD)

def row_wide(c, r, y, lead):
    # Ticker, company, estimate; then either "DUE AM/PM" or the actual EPS
    # and surprise percent in green or red.
    edge = 185
    c.text(r.get("s", ""), 6, y, font = "4x5", color = TICK)
    c.text(fit(c, r.get("n", ""), 72), 34, y, font = "4x5", color = WHITE)
    c.text(r.get("e", "--"), 134, y, font = "4x5", color = DIM, align = "right")
    if reported(r):
        col = result_color(r)
        c.text(r["a"], 162, y, font = "4x5", color = col, align = "right")
        c.text(r.get("p", ""), edge, y, font = "4x5", color = col, align = "right")
    else:
        w = r.get("w", "TBA")
        ww = c.text_width(w, "4x5")
        c.text(w, edge, y, font = "4x5", color = when_color(w), align = "right")
        c.text(lead, edge - ww - 5, y, font = "4x5", color = DIM, align = "right")

def row_small(c, r, y, lead):
    c.text(r.get("s", ""), 1, y, font = "4x5", color = TICK)
    if reported(r):
        col = result_color(r)
        c.text("BEAT" if r.get("b", True) else "MISS", 63, y, font = "4x5",
               color = col, align = "right")
        c.text(r["a"], 1, y + 6, font = "4x5", color = col)
        c.text(r.get("p", ""), 63, y + 6, font = "4x5", color = col,
               align = "right")
    else:
        w = r.get("w", "TBA")
        ww = c.text_width(w, "4x5")
        c.text(w, 63, y, font = "4x5", color = when_color(w), align = "right")
        c.text(lead, 63 - ww - 5, y, font = "4x5", color = DIM, align = "right")
        c.text("EST " + r.get("e", "--"), 1, y + 6, font = "4x5", color = DIM)

def short_day(label):
    # "TUE OCT 6" -> "TUE"
    return label.split(" ")[0] if label != "" else ""

def draw_screen(c, s):
    kind = s["kind"]
    rows = s["rows"]
    if kind == "today":
        if wide(c):
            header(c, "EARNINGS  " + s["label"], ["EST", "RESULT"])
        else:
            header(c, "EARNINGS", [short_day(s["label"]), ""])
        if len(rows) == 0:
            c.text("NO MAJOR REPORTS", c.width // 2, 15, font = "4x5",
                   color = DIM, align = "center")
            c.text("TODAY", c.width // 2, 22, font = "4x5", color = DIM,
                   align = "center")
            return
    elif wide(c):
        header(c, "RESULTS  " + s["label"], ["EST", "ACTUAL"])
    else:
        header(c, "RESULTS", [short_day(s["label"]), ""])

    for i in range(len(rows)):
        r = rows[i]
        lead = "DUE"
        if wide(c):
            row_wide(c, r, 9 + 6 * i, lead)
        else:
            row_small(c, r, 9 + 12 * i, lead)

def draw_no_data(c):
    if wide(c):
        c.text("EARNINGS CALENDAR", c.width // 2, 2, font = "6x8",
               color = GOLD, align = "center")
        c.text("FEED UNAVAILABLE", c.width // 2, 16, font = "4x5", color = DIM,
               align = "center")
        c.text("CHECK BACK SOON", c.width // 2, 23, font = "4x5", color = DIM,
               align = "center")
    else:
        c.text("EARNINGS", 32, 2, font = "6x8", color = GOLD, align = "center")
        c.text("NO DATA", 32, 15, font = "4x5", color = DIM, align = "center")
        c.text("TRY LATER", 32, 22, font = "4x5", color = DIM, align = "center")

def draw_page(c, ctx, page):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    draw_screen(c, pick(c, ctx, data, page))

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
