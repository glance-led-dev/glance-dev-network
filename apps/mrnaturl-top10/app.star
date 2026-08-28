# MrNaturl Top 10 - the week's top 10 singles and top 10 albums.
#
# Data comes from mrnaturl.com's own static feed at /api/panel.json, rebuilt
# every Saturday morning Eastern by the site's update pipeline and served as a
# static asset from Cloudflare Pages. The feed is about 2 KB, so it is well
# inside the panel's response cap, and it is first-party: no third-party
# scraper sits between the panel and the site.
#
# All chart data compiled from official Billboard charts.
#
# Layout adapts to the panel width, so the same app reads correctly on a
# single 64 px module and on a full 384 px chain.

FEED_URL = "https://www.mrnaturl.com/api/panel.json"

GOLD = "#e8b020"
GREEN = "#4caf50"
RED = "#d04a3a"
CYAN = "#4fb8d8"
DIM = "#8a8a8a"
FLAT = "#5a5a5a"

ROW_YS = [1, 7, 13, 19, 25]
ROW_FONT = "4x5"

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def fetch_feed():
    # The feed only changes once a week, so an hour of caching costs nothing
    # and keeps the panel from refetching on every page turn.
    return http.get(FEED_URL, ttl_seconds = 86400)

def get_data():
    resp = fetch_feed()
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def fit(c, text, font, maxw):
    # Truncate on measured pixel width rather than a guessed character count,
    # so it stays correct if the font changes.
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        stem = text[:i]
        if stem.endswith(" "):
            continue
        candidate = stem + "."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return "."

def pick_font(c, text, choices, maxw):
    # Walk from the largest font down and take the first one the string fits
    # in whole. Returns [font, height]; the caller centers on the height.
    for choice in choices:
        if c.text_width(text, choice[0]) <= maxw:
            return choice
    return choices[len(choices) - 1]

def pretty_week(week):
    # "2026-08-15" -> "AUG 15"
    if len(week) != 10:
        return ""
    month = int(week[5:7])
    day = week[8:10]
    if day[0] == "0":
        day = day[1:]
    return MONTHS[month - 1] + " " + day

def draw_unavailable(c, what):
    c.clear()
    c.text("BILLBOARD", c.width // 2, 6, font = "5x7", color = GOLD,
           align = "center")
    c.text(what.upper(), c.width // 2, 17, font = "4x5", color = DIM,
           align = "center")
    c.text("NO DATA", c.width // 2, 24, font = "4x5", color = DIM,
           align = "center")

# --- list pages -------------------------------------------------------------

def draw_rows(c, entries, first, last):
    # Five ranks per screen. Rank is right-aligned in a fixed gutter so the
    # titles line up whether the rank is one digit or two.
    width = c.width
    show_artist = width >= 112

    if show_artist:
        artist_w = (width - 16) * 38 // 100
        if artist_w > 76:
            artist_w = 76
        title_x = 16
        title_w = width - title_x - artist_w - 4
    else:
        artist_w = 0
        title_x = 16
        title_w = width - title_x - 1

    slot = 0
    for entry in entries:
        rank = entry["r"]
        if rank < first or rank > last:
            continue
        if slot >= len(ROW_YS):
            continue

        y = ROW_YS[slot]
        slot = slot + 1

        # Movement bar at the left edge. Named last_week, NOT last: `last` is
        # this function's rank-range parameter and shadowing it silently stops
        # the loop after the first row.
        last_week = entry.get("lw", 0)
        if last_week == 0:
            move_color = GOLD
        elif last_week > rank:
            move_color = GREEN
        elif last_week < rank:
            move_color = RED
        else:
            move_color = FLAT
        c.rect(0, y, 1, y + 4, fill = move_color)

        c.text(str(rank), 13, y, font = ROW_FONT, color = GOLD,
               align = "right")

        title = entry["t"].upper()
        c.text(fit(c, title, ROW_FONT, title_w), title_x, y,
               font = ROW_FONT, color = "white")

        if show_artist:
            artist = entry["a"].upper()
            c.text(fit(c, artist, ROW_FONT, artist_w), width - 1, y,
                   font = ROW_FONT, color = CYAN, align = "right")

def draw_list_page(c, chart_key, label, first, last):
    c.clear()
    data = get_data()
    if data == None:
        draw_unavailable(c, label)
        return

    entries = data.get(chart_key, [])
    if len(entries) == 0:
        draw_unavailable(c, label)
        return

    draw_rows(c, entries, first, last)

# --- number one pages -------------------------------------------------------

def draw_number_one(c, chart_key, label):
    c.clear()
    data = get_data()
    if data == None:
        draw_unavailable(c, label)
        return

    entries = data.get(chart_key, [])
    if len(entries) == 0:
        draw_unavailable(c, label)
        return

    top = entries[0]
    width = c.width
    week = pretty_week(data.get("week", ""))

    header_font = "4x5"
    meta_font = "4x5"

    # Gold bar: what this is on the left, the chart week on the right. On a
    # narrow panel the two would collide, so the week is dropped there - the
    # cover page still carries it.
    bar_h = 8
    c.rect(0, 0, width - 1, bar_h - 1, fill = GOLD)
    label_text = label.upper()
    c.text(label_text, 2, 1, font = header_font, color = "black")

    label_w = c.text_width(label_text, header_font)
    if week != "" and width - 4 - label_w - c.text_width(week, header_font) >= 6:
        c.text(week, width - 2, 1, font = header_font, color = "black",
               align = "right")

    # The title band runs from y 10 to y 22. Long album titles get a smaller
    # font rather than being cut in half, and the chosen font is centered in
    # the band so the page stays balanced either way.
    title = top["t"].upper()
    band_top = 10
    band_h = 13
    choices = [["8x12", 12], ["6x8", 8], ["4x5", 6]]
    if width < 112:
        choices = [["6x8", 8], ["4x5", 6]]

    chosen = pick_font(c, title, choices, width - 4)
    title_font = chosen[0]
    title_y = band_top + (band_h - chosen[1]) // 2
    c.text(fit(c, title, title_font, width - 4), 2, title_y,
           font = title_font, color = "white")

    # Bottom row: artist on the left, weeks-at-number-one on the right. The
    # note is only drawn when what is left over still fits a readable slice of
    # the artist name, otherwise the artist wins the whole row.
    meta_y = 24
    weeks_at_one = top.get("n1", 0)
    artist_w = width - 4

    if weeks_at_one > 0:
        note = str(weeks_at_one) + " WK"
        if weeks_at_one > 1:
            note = note + "S"
        note = note + " AT #1"
        note_w = c.text_width(note, meta_font)
        if width - 6 - note_w >= 30:
            c.text(note, width - 2, meta_y, font = meta_font, color = GOLD,
                   align = "right")
            artist_w = width - 6 - note_w

    artist = top["a"].upper()
    c.text(fit(c, artist, meta_font, artist_w), 2, meta_y,
           font = meta_font, color = CYAN)

# --- pages ------------------------------------------------------------------

def cover(c, ctx):
    c.clear()
    data = get_data()
    width = c.width

    if width >= 176:
        brand_font = "10x16_bold"
        brand_y = 1
        tag_y = 19
    elif width >= 96:
        brand_font = "6x8"
        brand_y = 3
        tag_y = 14
    else:
        brand_font = "5x7"
        brand_y = 3
        tag_y = 13

    c.text("BILLBOARD", width // 2, brand_y, font = brand_font, color = GOLD,
           align = "center")

    tagline = "TOP 10 SINGLES AND ALBUMS"
    if c.text_width(tagline, "4x5") > width - 2:
        tagline = "TOP 10"
    c.text(tagline, width // 2, tag_y, font = "4x5", color = CYAN,
           align = "center")

    if data != None:
        week = pretty_week(data.get("week", ""))
        if week != "":
            stamp = "WEEK OF " + week
            if c.text_width(stamp, "4x5") > width - 2:
                stamp = week
            c.text(stamp, width // 2, 26, font = "4x5", color = "white",
                   align = "center")

def singles_one(c, ctx):
    draw_number_one(c, "singles", "#1 SINGLE")

def singles_top(c, ctx):
    draw_list_page(c, "singles", "SINGLES", 1, 5)

def singles_rest(c, ctx):
    draw_list_page(c, "singles", "SINGLES", 6, 10)

def albums_one(c, ctx):
    draw_number_one(c, "albums", "#1 ALBUM")

def albums_top(c, ctx):
    draw_list_page(c, "albums", "ALBUMS", 1, 5)

def albums_rest(c, ctx):
    draw_list_page(c, "albums", "ALBUMS", 6, 10)
