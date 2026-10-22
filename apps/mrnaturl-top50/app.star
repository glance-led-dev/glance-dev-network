# MrNaturl Top 50 Earnings - when the 50 largest US companies report
# earnings next (date, before the open AM or after the close PM, and the EPS
# estimate), and their results from the last 5 business days: actual EPS and
# how far they beat or missed.
#
# The Top 50 is the 50 largest US companies by market cap (foreign companies
# left out, each company counted once), checked daily.
#
# Data comes from MrNaturl's own static feed at /api/top50.json, rebuilt
# several times a day from Nasdaq's public earnings calendar and stock
# screener and served from Cloudflare Pages. No API key, no inputs.
#
# Same app.star ships as mrnaturl-top50 (64 wide) and mrnaturl-top50-scroll
# (192 wide). The Scroll shows four companies per page, the Glance LED two.
# The eight pages walk through NEXT TO REPORT, then LATEST RESULTS (only as
# many pages as there are results); when there is more than fits, the set
# shown moves along every 10 minutes.

FEED_URL = "https://mrnaturl-earnings.pages.dev/api/top50.json"

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

def result_color(r):
    if r.get("b", True):
        return GREEN
    return RED

def screens(c, data):
    per = 4 if wide(c) else 2
    out = []
    rows = data.get("next", [])
    for i in range(0, len(rows), per):
        out.append({"kind": "next", "rows": rows[i:i + per]})
    rows = data.get("latest", [])
    for i in range(0, len(rows), per):
        out.append({"kind": "latest", "rows": rows[i:i + per]})
    return out

def pick(c, ctx, data, page):
    scr = screens(c, data)
    n = len(scr)
    if n == 0:
        return None
    blocks = (n + PAGES - 1) // PAGES
    block = (ctx.now.unix // ROTATE_SECONDS) % blocks
    return scr[(block * PAGES + page) % n]

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
        # Next report: estimate, then the date and AM or PM.
        c.text(fit(c, r.get("n", ""), 72), 34, y, font = "4x5", color = WHITE)
        c.text(r.get("e", "--"), 134, y, font = "4x5", color = DIM, align = "right")
        w = r.get("w", "TBA")
        ww = c.text_width(w, "4x5")
        c.text(w, edge, y, font = "4x5", color = when_color(w), align = "right")
        c.text(r.get("d", ""), edge - ww - 5, y, font = "4x5", color = DIM,
               align = "right")
    else:
        # Result: date, estimate, actual EPS and surprise in green or red.
        col = result_color(r)
        c.text(fit(c, r.get("n", ""), 46), 34, y, font = "4x5", color = WHITE)
        c.text(r.get("d", ""), 104, y, font = "4x5", color = DIM, align = "right")
        c.text(r.get("e", "--"), 134, y, font = "4x5", color = DIM, align = "right")
        c.text(r["a"], 162, y, font = "4x5", color = col, align = "right")
        c.text(r.get("p", ""), edge, y, font = "4x5", color = col, align = "right")

def row_small(c, r, y):
    c.text(r.get("s", ""), 1, y, font = "4x5", color = TICK)
    if r.get("a", "") == "":
        w = r.get("w", "TBA")
        ww = c.text_width(w, "4x5")
        c.text(w, 63, y, font = "4x5", color = when_color(w), align = "right")
        c.text(r.get("d", ""), 63 - ww - 5, y, font = "4x5", color = DIM,
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
        header(c, "TOP 50  NEXT TO REPORT" if wide(c) else "TOP 50 NEXT",
               ["EST", "WHEN"])
    else:
        header(c, "TOP 50  LATEST RESULTS" if wide(c) else "TOP 50 RESULTS",
               ["EST", "ACTUAL"])
    rows = s["rows"]
    for i in range(len(rows)):
        if wide(c):
            row_wide(c, rows[i], 9 + 6 * i)
        else:
            row_small(c, rows[i], 9 + 12 * i)

def draw_message(c, line1, line2):
    title = "TOP 50 EARNINGS" if wide(c) else "TOP 50"
    c.text(title, c.width // 2, 2, font = "6x8", color = GOLD, align = "center")
    c.text(line1, c.width // 2, 15, font = "4x5", color = DIM, align = "center")
    c.text(line2, c.width // 2, 22, font = "4x5", color = DIM, align = "center")

def draw_page(c, ctx, page):
    c.clear()
    data = get_data()
    if data == None:
        if wide(c):
            draw_message(c, "FEED UNAVAILABLE", "CHECK BACK SOON")
        else:
            draw_message(c, "NO DATA", "TRY LATER")
        return
    s = pick(c, ctx, data, page)
    if s == None:
        draw_message(c, "NO DATES POSTED", "CHECK BACK SOON")
        return
    draw_screen(c, s)

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
