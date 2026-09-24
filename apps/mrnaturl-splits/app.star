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

MINT = "#2fd07a"     # brand, header bar, forward splits
RED = "#e0533d"      # reverse splits
SKY = "#6fb4ff"      # dates
AMBER = "#f0b429"    # countdown
DIM = "#8a8a8a"
WHITE = "white"

ROW_YS = [1, 7, 13, 19, 25]
ROW_FONT = "4x5"

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

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

def kind_color(entry):
    if entry.get("k", "f") == "r":
        return RED
    return MINT

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

def draw_brand(c, y, font):
    c.text("STOCK SPLITS CALENDAR", c.width // 2, y, font = font, color = MINT,
           align = "center")

def draw_no_data(c):
    c.clear()
    if wide(c):
        draw_brand(c, 4, "6x8")
        c.text("FEED UNAVAILABLE", c.width // 2, 16, font = "4x5",
               color = DIM, align = "center")
        c.text("CHECK BACK SOON", c.width // 2, 23, font = "4x5",
               color = DIM, align = "center")
    else:
        c.text("SPLITS", 32, 4, font = "5x7", color = MINT, align = "center")
        c.text("NO DATA", 32, 16, font = "4x5", color = DIM, align = "center")
        c.text("TRY LATER", 32, 23, font = "4x5", color = DIM,
               align = "center")

def draw_all_clear(c):
    c.clear()
    if wide(c):
        draw_brand(c, 4, "6x8")
        c.text("ALL CLEAR", c.width // 2, 15, font = "6x8", color = WHITE,
               align = "center")
        c.text("NO SPLITS SCHEDULED", c.width // 2, 25, font = "4x5",
               color = DIM, align = "center")
    else:
        c.text("SPLITS", 32, 3, font = "5x7", color = MINT, align = "center")
        c.text("ALL CLEAR", 32, 14, font = "5x7", color = WHITE,
               align = "center")
        c.text("NONE DUE", 32, 25, font = "4x5", color = DIM,
               align = "center")

# --- cover ------------------------------------------------------------------

def cover(c, ctx):
    c.clear()
    data = get_data()
    width = c.width

    if width >= 176:
        c.text("STOCK SPLITS CALENDAR", width // 2, 2, font = "7x12",
               color = MINT, align = "center")
        sub_y = 17
    elif wide(c):
        draw_brand(c, 3, "6x8")
        sub_y = 14
    else:
        c.text("SPLITS", 32, 1, font = "6x8", color = MINT, align = "center")
        c.text("CALENDAR", 32, 10, font = "6x8", color = MINT,
               align = "center")
        sub_y = 20

    if data == None:
        c.text("NO DATA", width // 2, sub_y + 2, font = "4x5", color = DIM,
               align = "center")
        return

    n = len(upcoming(data))
    if n == 0:
        line = "NONE SCHEDULED"
        if not wide(c):
            line = "NONE DUE"
    elif n == 1:
        line = "1 SCHEDULED"
    else:
        line = str(n) + " SCHEDULED"

    if wide(c):
        c.text(line, width // 2, sub_y, font = "4x5", color = WHITE,
               align = "center")
        stamp = "AS OF " + pretty_date(data.get("asof", ""))
        c.text(stamp, width // 2, 26, font = "4x5", color = SKY,
               align = "center")
    else:
        c.text(line, 32, sub_y, font = "4x5", color = WHITE, align = "center")
        c.text(pretty_date(data.get("asof", "")), 32, 26, font = "4x5",
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
    inner = right - left + 1

    # Header bar in the split's own color: FORWARD or REVERSE on the left,
    # the effective date on the right when there is room.
    c.rect(left, 0, right, 6, fill = color)
    if top.get("k", "f") == "r":
        label = "REVERSE SPLIT"
        if not wide(c):
            label = "REVERSE"
    else:
        label = "NEXT SPLIT"
        if not wide(c):
            label = "SPLIT"
    c.text(label, left + 2, 1, font = "4x5", color = "black")
    date_text = pretty_date(top["d"])
    if not wide(c):
        date_text = short_date(top["d"])
    label_w = c.text_width(label, "4x5")
    if inner - 6 - label_w - c.text_width(date_text, "4x5") >= 4:
        c.text(date_text, right - 1, 1, font = "4x5", color = "black",
               align = "right")

    # Middle band y 9 to 21: ticker on the left in white, ratio on the right
    # in the split's color. Ratio is measured first so the ticker never
    # collides with it.
    if wide(c):
        ratio_choices = [["8x12", 12], ["6x8", 8], ["4x5", 6]]
        tick_choices = [["8x12", 12], ["6x8", 8], ["4x5", 6]]
    else:
        ratio_choices = [["6x8", 8], ["4x5", 6]]
        tick_choices = [["6x8", 8], ["4x5", 6]]

    ratio = top["r"]
    rchoice = pick_font(c, ratio, ratio_choices, inner // 2)
    ratio_w = c.text_width(ratio, rchoice[0])
    band_top = 8
    band_h = 15
    c.text(ratio, right - 1, band_top + (band_h - rchoice[1]) // 2,
           font = rchoice[0], color = color, align = "right")

    tick = top["s"].upper()
    tick_room = inner - ratio_w - 8
    tchoice = pick_font(c, tick, tick_choices, tick_room)
    c.text(fit(c, tick, tchoice[0], tick_room), left + 2,
           band_top + (band_h - tchoice[1]) // 2, font = tchoice[0],
           color = WHITE)

    # Bottom row: company on the left, countdown on the right.
    meta_y = 25
    when = countdown(data, top["d"])
    name_w = inner - 4
    if when != "":
        when_w = c.text_width(when, "4x5")
        if inner - 6 - when_w >= 20:
            c.text(when, right - 1, meta_y, font = "4x5", color = AMBER,
                   align = "right")
            name_w = inner - 8 - when_w
    c.text(fit(c, top["n"].upper(), "4x5", name_w), left + 2, meta_y,
           font = "4x5", color = DIM)

# --- list pages -------------------------------------------------------------

def draw_rows(c, rows, first, last):
    # Five splits per screen. Each row: a colour bar (mint forward, red
    # reverse), the date, the ticker, the company when wide, and the ratio
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

    date_x = left + 3
    if wide(c):
        date_x = left + 4
    tick_x = date_x + date_w + 3

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

        c.rect(left, y, left + 1, y + 4, fill = color)
        c.text(row_date(c, entry), date_x, y, font = ROW_FONT, color = SKY)

        ratio = entry["r"]
        if not wide(c):
            ratio = entry.get("rs", ratio)
        ratio_w = c.text_width(ratio, ROW_FONT)
        c.text(ratio, right, y, font = ROW_FONT, color = color,
               align = "right")
        ratio_left = right - ratio_w

        tick = entry["s"].upper()
        tick_room = ratio_left - 3 - tick_x
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
        c.text("END OF LIST", c.width // 2, 8, font = "5x7", color = MINT,
               align = "center")
        c.text(text + " DUE", c.width // 2, 20, font = "4x5", color = DIM,
               align = "center")
        return
    draw_rows(c, rows, first, last)

def splits_top(c, ctx):
    draw_list_page(c, 1, 5)

def splits_rest(c, ctx):
    draw_list_page(c, 6, 10)
