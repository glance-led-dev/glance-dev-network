# MrNaturl Stock Splits Calendar - every upcoming US stock split, forward and reverse.
#
# Data comes from MrNaturl's own static feed at /api/splits.json, rebuilt
# every morning from the Nasdaq stock split calendar and served as a static
# asset from its own Cloudflare Pages project (mrnaturl-splits). The feed is about 2 KB and first-party: no
# third-party scraper sits between the panel and the site, and no API key is
# needed.
#
# Same app.star ships as mrnaturl-splits (64 wide) and mrnaturl-splits-scroll
# (192 wide). Layout branches on c.width.

FEED_URL = "https://mrnaturl-splits.pages.dev/api/splits.json"

MINT = "#2fd07a"     # brand, forward splits
RED = "#e0533d"      # reverse splits
SKY = "#6fb4ff"      # dates
AMBER = "#f0b429"    # countdown
DIM = "#8a8a8a"
WHITE = "white"

ROW_YS = [1, 7, 13, 19, 25]
ROW_FONT = "4x5"

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# --- pixel art ----------------------------------------------------------------

COIN_LEGEND = {"O": "#9a6a12", "Y": "#f5c542", "H": "#fff1a8", "S": "#7a4e08"}

# An 11x11 gold share coin with a dollar sign.
COIN = [
    "...OOOOO...",
    "..OHHYYYO..",
    ".OHYYSYYYO.",
    "OHYYSSSSYYO",
    "OYYSYSYYYYO",
    "OYYYSSSYYYO",
    "OYYYYSYSYYO",
    "OYYSSSSYYYO",
    ".OYYYSYYYO.",
    "..OYYYYYO..",
    "...OOOOO...",
]

# A 5x5 small coin, for "many shares".
MINI_COIN = [
    ".OOO.",
    "OHYYO",
    "OYYYO",
    "OYYYO",
    ".OOO.",
]

# Row icons, read left to right: one line forking into two (forward split),
# two lines joining into one (reverse split).
FORK = [
    "...XX",
    "..X..",
    "XX...",
    "..X..",
    "...XX",
]

MERGE = [
    "XX...",
    "..X..",
    "...XX",
    "..X..",
    "XX...",
]

ARROW = [
    "..X..",
    "...X.",
    "XXXXX",
    "...X.",
    "..X..",
]

def get_data():
    # The feed changes once a day, so an hour of caching costs nothing.
    resp = http.get(FEED_URL, ttl_seconds = 3600)
    if resp["status_code"] != 200:
        return None
    data = resp["json"]
    if data == None:
        return None
    return data

def wide(c):
    return c.width >= 128

def margin(c):
    # Scroll apps keep 6 px off each outer edge so neighbours never touch.
    if wide(c):
        return 6
    return 0

def fit(c, text, font, maxw):
    if maxw <= 0:
        return ""
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        stem = text[:i].rstrip(" ")
        candidate = stem + "."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return ""

def pick_font(c, text, choices, maxw):
    for choice in choices:
        if c.text_width(text, choice[0]) <= maxw:
            return choice
    return choices[len(choices) - 1]

def is_reverse(entry):
    return entry.get("k", "f") == "r"

def kind_color(entry):
    if is_reverse(entry):
        return RED
    return MINT

def kind_icon(c, entry, x, y):
    art = FORK
    if is_reverse(entry):
        art = MERGE
    c.sprite(art, x, y, color = kind_color(entry))

# --- sprites drawn from the art above -----------------------------------------

def split_coin(c, x, y, scale):
    # The coin cut down the middle: left half nudged up, right half nudged
    # down and out. 13 * scale wide.
    left = []
    right = []
    for row in COIN:
        left.append(row[:6])
        right.append("......" + row[6:])
    c.sprite(left, x, y, legend = COIN_LEGEND, scale = scale)
    c.sprite(right, x + 2 * scale, y + scale, legend = COIN_LEGEND,
             scale = scale)

def coin_flow(c, entry, x, y):
    # Forward: one big coin becomes a pile of small ones. Reverse: the pile
    # merges into one big coin. 33 px wide, 11 px tall.
    color = kind_color(entry)
    if is_reverse(entry):
        mini_pile(c, x, y)
        c.sprite(ARROW, x + 14, y + 3, color = color)
        c.sprite(COIN, x + 22, y, legend = COIN_LEGEND)
    else:
        c.sprite(COIN, x, y, legend = COIN_LEGEND)
        c.sprite(ARROW, x + 14, y + 3, color = color)
        mini_pile(c, x + 22, y)

def mini_pile(c, x, y):
    for dx in [0, 6]:
        for dy in [0, 6]:
            c.sprite(MINI_COIN, x + dx, y + dy, legend = COIN_LEGEND)

def calendar(c, x, y, w, h, iso, color):
    # A tear-off calendar page: binder rings, a header in the split's color
    # with the month, and a big day number on the page.
    month = ""
    day = ""
    if len(iso) == 10:
        month = MONTHS[int(iso[5:7]) - 1]
        day = str(int(iso[8:10]))
    head_h = 7
    c.rect(x, y + 1, x + w - 1, y + head_h, fill = color)
    c.rect(x, y + head_h + 1, x + w - 1, y + h - 1, fill = "#d8d8d8")
    c.hline(x, y + h - 1, w, "#9a9a9a")
    ring_l = x + 3
    ring_r = x + w - 4
    c.vline(ring_l, y, 3, "#5a5a5a")
    c.vline(ring_r, y, 3, "#5a5a5a")
    c.text(month, x + w // 2, y + 2, font = "4x5", color = "black",
           align = "center")
    body_top = y + head_h + 1
    body_h = h - head_h - 2
    font = pick_font(c, day, [["7x12", 12], ["6x8", 8]], w - 2)
    c.text(day, x + w // 2, body_top + (body_h - font[1]) // 2 + 1,
           font = font[0], color = "black", align = "center")

# --- dates ------------------------------------------------------------------

def day_number(y, m, d):
    # Days since 1970-01-01 for a civil date (Howard Hinnant's algorithm).
    if m <= 2:
        y = y - 1
    era = y // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def iso_day(iso):
    if len(iso) != 10:
        return None
    return day_number(int(iso[0:4]), int(iso[5:7]), int(iso[8:10]))

def pretty_date(iso):
    # "2026-10-02" -> "OCT 2"
    if len(iso) != 10:
        return ""
    day = iso[8:10]
    if day[0] == "0":
        day = day[1:]
    return MONTHS[int(iso[5:7]) - 1] + " " + day

def short_date(iso):
    # "2026-10-02" -> "10/2"
    if len(iso) != 10:
        return ""
    m = iso[5:7]
    d = iso[8:10]
    if m[0] == "0":
        m = m[1:]
    if d[0] == "0":
        d = d[1:]
    return m + "/" + d

def countdown(data, iso):
    # Days from the feed's as-of date, so a panel with a slow clock and the
    # feed always agree. "TODAY", "TOMORROW", "IN 9 DAYS".
    start = iso_day(data.get("asof", ""))
    end = iso_day(iso)
    if start == None or end == None:
        return ""
    n = end - start
    if n <= 0:
        return "TODAY"
    if n == 1:
        return "TOMORROW"
    return "IN " + str(n) + " DAYS"

def upcoming(data):
    return data.get("splits", [])

# --- shared screens -----------------------------------------------------------

def message_screen(c, title, line1, line2, title_color):
    # A coin on the left and two or three short lines beside it.
    c.clear()
    if wide(c):
        x = margin(c) + 2
        split_coin(c, x, 3, 2)
        tx = x + 32
        c.text("STOCK SPLITS CALENDAR", tx, 3, font = "5x7", color = MINT)
        c.text(title, tx, 14, font = "6x8", color = title_color)
        c.text(line1, tx, 25, font = "4x5", color = DIM)
    else:
        c.sprite(COIN, 2, 10, legend = COIN_LEGEND)
        tfont = pick_font(c, title, [["5x7", 7], ["4x5", 5]], 48)
        c.text(title, 39, 4 + (7 - tfont[1]) // 2, font = tfont[0],
               color = title_color, align = "center")
        c.text(line1, 39, 15, font = "4x5", color = DIM, align = "center")
        c.text(line2, 39, 23, font = "4x5", color = DIM, align = "center")

def draw_no_data(c):
    if wide(c):
        message_screen(c, "FEED UNAVAILABLE", "CHECK BACK SOON", "", DIM)
    else:
        message_screen(c, "NO DATA", "CHECK", "LATER", WHITE)

def draw_all_clear(c):
    if wide(c):
        message_screen(c, "ALL CLEAR", "NO SPLITS SCHEDULED", "", WHITE)
    else:
        message_screen(c, "ALL CLEAR", "NO SPLITS", "DUE", WHITE)

# --- cover ------------------------------------------------------------------

def tally(c, x, art, label, n, color):
    # 20 px column: icon + label on top, the count big underneath.
    c.sprite(art, x, 3, color = color)
    c.text(label, x + 7, 3, font = "4x5", color = color)
    c.text(str(n), x + 10, 13, font = "8x12", color = color, align = "center")

def cover(c, ctx):
    c.clear()
    data = get_data()
    width = c.width

    if wide(c):
        x = margin(c) + 2
        split_coin(c, x, 3, 2)
        tx = x + 32
        c.text("STOCK SPLITS", tx, 2, font = "7x12", color = MINT)
        if data == None:
            c.text("NO DATA", tx, 18, font = "5x7", color = DIM)
            return
        rows = upcoming(data)
        n = len(rows)
        line = str(n) + " SCHEDULED"
        if n == 0:
            line = "NONE SCHEDULED"
        c.text(line, tx, 17, font = "5x7", color = WHITE)
        c.text("AS OF " + pretty_date(data.get("asof", "")), tx, 26,
               font = "4x5", color = SKY)

        # Forward / reverse tally on the right: icon and label over a big
        # count, each in its own color.
        fwd = 0
        rev = 0
        for entry in rows:
            if is_reverse(entry):
                rev = rev + 1
            else:
                fwd = fwd + 1
        right = width - 1 - margin(c)
        tally(c, right - 43, FORK, "FWD", fwd, MINT)
        tally(c, right - 19, MERGE, "REV", rev, RED)
        return

    split_coin(c, 1, 4, 2)
    c.text("SPLITS", 46, 2, font = "5x7", color = MINT, align = "center")
    if data == None:
        c.text("NO", 46, 13, font = "5x7", color = DIM, align = "center")
        c.text("DATA", 46, 21, font = "4x5", color = DIM, align = "center")
        return
    n = len(upcoming(data))
    c.text(str(n), 46, 11, font = "7x12" if n < 100 else "5x7",
           color = WHITE, align = "center")
    c.text(pretty_date(data.get("asof", "")), 46, 25, font = "4x5",
           color = SKY, align = "center")

# --- next split (the hero) --------------------------------------------------

def next_split(c, ctx):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    rows = upcoming(data)
    if len(rows) == 0:
        draw_all_clear(c)
        return

    top = rows[0]
    color = kind_color(top)
    width = c.width
    left = margin(c)
    right = width - 1 - margin(c)
    when = countdown(data, top["d"])
    tick = top["s"].upper()

    if not wide(c):
        calendar(c, 0, 3, 20, 27, top["d"], color)
        tx = 23
        room = right - tx + 1
        tchoice = pick_font(c, tick, [["6x8", 8], ["4x5", 6]], room)
        c.text(fit(c, tick, tchoice[0], room), tx, 1, font = tchoice[0],
               color = WHITE)
        ratio = top["r"]
        if c.text_width(ratio, "6x8") > room:
            ratio = top.get("rs", ratio)
        rchoice = pick_font(c, ratio, [["6x8", 8], ["4x5", 6]], room)
        c.text(fit(c, ratio, rchoice[0], room), tx, 10 + (8 - rchoice[1]) // 2,
               font = rchoice[0], color = color)
        label = "FORWARD"
        if is_reverse(top):
            label = "REVERSE"
        c.text(label, tx, 20, font = "4x5", color = color)
        c.text(fit(c, when, "4x5", room), tx, 26, font = "4x5", color = AMBER)
        return

    calendar(c, left, 3, 22, 27, top["d"], color)
    tx = left + 27

    # Right block: ratio on top, the kind underneath, both in the split's
    # color. Measured first so the rest fits into what's left.
    ratio = top["r"]
    rchoice = pick_font(c, ratio, [["8x12", 12], ["6x8", 8], ["4x5", 6]], 60)
    c.text(ratio, right, 3 + (12 - rchoice[1]) // 2, font = rchoice[0],
           color = color, align = "right")
    label = "FORWARD SPLIT"
    if is_reverse(top):
        label = "REVERSE SPLIT"
    c.text(label, right, 18, font = "4x5", color = color, align = "right")
    block_w = c.text_width(ratio, rchoice[0])
    label_w = c.text_width(label, "4x5")
    if label_w > block_w:
        block_w = label_w

    flow_x = right - block_w - 8 - 34
    coin_flow(c, top, flow_x, 10)

    room = flow_x - 8 - tx
    tchoice = pick_font(c, tick, [["8x12", 12], ["6x8", 8]], room)
    c.text(fit(c, tick, tchoice[0], room), tx, 2, font = tchoice[0],
           color = WHITE)
    c.text(fit(c, top["n"].upper(), "4x5", room), tx, 17, font = "4x5",
           color = DIM)
    c.text(when, tx, 25, font = "4x5", color = AMBER)

# --- list pages -------------------------------------------------------------

def draw_rows(c, rows, first, last):
    # Five splits per screen. Each row: a fork (forward) or merge (reverse)
    # icon, the date, the ticker, the company when wide, and the ratio
    # right-aligned. The ratio is measured first; everything else fits into
    # what is left.
    width = c.width
    left = margin(c)
    right = width - 1 - margin(c)

    page = []
    for i in range(first - 1, last):
        if i < len(rows):
            page.append(rows[i])

    # Date column is as wide as the widest date on this page, so the ticker
    # column starts right after it with no wasted pixels on the 64 panel.
    date_w = 0
    for entry in page:
        w = c.text_width(row_date(c, entry), ROW_FONT)
        if w > date_w:
            date_w = w

    date_x = left + 7
    tick_x = date_x + date_w + 3
    if wide(c):
        date_x = left + 8
        tick_x = date_x + date_w + 4

    tick_w = 0
    for entry in page:
        w = c.text_width(entry["s"].upper(), ROW_FONT)
        if w > tick_w:
            tick_w = w

    slot = 0
    for entry in page:
        y = ROW_YS[slot]
        slot = slot + 1
        color = kind_color(entry)

        kind_icon(c, entry, left, y)
        c.text(row_date(c, entry), date_x, y, font = ROW_FONT, color = SKY)

        ratio = entry["r"]
        if not wide(c):
            ratio = entry.get("rs", ratio)
        ratio_w = c.text_width(ratio, ROW_FONT)
        c.text(ratio, right, y, font = ROW_FONT, color = color,
               align = "right")
        ratio_left = right - ratio_w

        tick = entry["s"].upper()
        tick_room = ratio_left - 2 - tick_x
        c.text(fit(c, tick, ROW_FONT, tick_room), tick_x, y,
               font = ROW_FONT, color = WHITE)

        if wide(c):
            # Company column starts after the widest ticker on the page, so
            # the names line up.
            name_x = tick_x + tick_w + 4
            name_room = ratio_left - 5 - name_x
            c.text(fit(c, entry["n"].upper(), ROW_FONT, name_room), name_x,
                   y, font = ROW_FONT, color = DIM)

def row_date(c, entry):
    if wide(c):
        return pretty_date(entry["d"])
    return short_date(entry["d"])

def draw_list_page(c, first, last):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    rows = upcoming(data)
    if len(rows) == 0:
        draw_all_clear(c)
        return
    if len(rows) < first:
        # Nothing left for this page: say how many there were, positively.
        n = len(rows)
        text = str(n) + " SPLIT"
        if n != 1:
            text = text + "S"
        if wide(c):
            message_screen(c, "END OF LIST", text + " DUE", "", WHITE)
        else:
            message_screen(c, "END", text, "DUE", WHITE)
        return
    draw_rows(c, rows, first, last)

def splits_top(c, ctx):
    draw_list_page(c, 1, 5)

def splits_rest(c, ctx):
    draw_list_page(c, 6, 10)
