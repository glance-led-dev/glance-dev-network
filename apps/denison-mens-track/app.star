# Denison Men's Track & Field
#
# Live sources:
#   Schedule/results: Denison Athletics' current men's track schedule page
#   News/Jack update: Denison Athletics' men's track RSS feed
#
# The schedule page is parsed defensively because Denison uses Sidearm Sports
# HTML rather than a public JSON schedule endpoint. Every live page has a useful
# bundled fallback so the panel never goes blank if Denison is unavailable.

SCHEDULE_URL = "https://denisonbigred.com/sports/mens-track-and-field/schedule"
RSS_URL = "https://denisonbigred.com/rss.aspx?path=mtrack"

RED = "#C8032B"
DARK_RED = "#710019"
GOLD = "#F0C75E"
WHITE = "#FFFFFF"
GRAY = "#9CA3AF"
BLACK = "#050509"

SAMPLE_MEETS = [
    {"date": "MAY 2, 2026", "name": "NCAC CHAMPIONSHIPS", "location": "GAMBIER, OH", "result": "7TH PLACE", "completed": True},
    {"date": "MAY 7, 2026", "name": "HARRISON DILLARD TWILIGHT", "location": "BEREA, OH", "result": "NOT TEAM SCORED", "completed": True},
]


def _between(s, start, end):
    a = s.find(start)
    if a < 0:
        return ""
    a += len(start)
    b = s.find(end, a)
    if b < 0:
        return ""
    return s[a:b]


def _strip_tags(s):
    out = ""
    inside = False
    for i in range(len(s)):
        ch = s[i]
        if ch == "<":
            inside = True
        elif ch == ">":
            inside = False
            out += " "
        elif not inside:
            out += ch
    return out


def _clean(s):
    out = _strip_tags(s)
    pairs = [
        ["<![CDATA[", ""], ["]]>", ""], ["&amp;", "&"],
        ["&#39;", "'"], ["&apos;", "'"], ["&quot;", '"'],
        ["&nbsp;", " "], ["&ndash;", "-"], ["&mdash;", "-"],
        ["&reg;", ""], ["\r", " "], ["\n", " "], ["\t", " "],
    ]
    for p in pairs:
        out = out.replace(p[0], p[1])
    # HTML often leaves long runs of whitespace after tags are removed.
    return " ".join(out.split())


def _clip(c, text, font, maxw):
    t = str(text).upper()
    if c.text_width(t, font) <= maxw:
        return t
    suffix = ".."
    for n in range(len(t), 0, -1):
        if c.text_width(t[:n] + suffix, font) <= maxw:
            return t[:n] + suffix
    return suffix


def _wrap(c, text, font, maxw, max_lines):
    words = str(text).upper().split()
    lines = []
    cur = ""
    for word in words:
        trial = word if cur == "" else cur + " " + word
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            cur = word
            if len(lines) >= max_lines:
                break
    if len(lines) < max_lines and cur != "":
        lines.append(cur)
    if len(lines) == max_lines:
        used = " ".join(lines)
        original = " ".join(words)
        if len(used) < len(original):
            lines[max_lines - 1] = _clip(c, lines[max_lines - 1] + "..", font, maxw)
    return lines


def _header(c, label, page = ""):
    c.fill(BLACK)
    c.rect(0, 0, c.width - 1, 6, fill = RED)
    c.text(label, 3, 1, font = "4x5", color = WHITE)
    if page != "":
        c.text(page, c.width - 3, 1, font = "4x5", color = WHITE, align = "right")


def _draw_d(c, x, y, size):
    # Compact Denison-inspired D/track mark drawn natively, no logo asset.
    c.rect(x, y, x + size - 1, y + size - 1, fill = WHITE)
    c.rect(x + 1, y + 1, x + size - 2, y + size - 2, fill = BLACK)
    c.rect(x + 3, y + 3, x + size - 4, y + size - 4, fill = RED)
    c.line(x + 1, y + size - 3, x + size - 3, y + 1, DARK_RED)
    c.text("D", x + size // 2, y + size // 2 - 5, font = "6x8", color = WHITE, align = "center")


def _fetch_schedule():
    r = http.get(SCHEDULE_URL, ttl_seconds = 3600,
                 headers = {"User-Agent": "Glance Denison Track app"})
    if r["status_code"] != 200 or not r["body"]:
        return []
    return _parse_schedule(r["body"])


def _parse_schedule(body):
    meets = []
    blocks = body.split('<li class="sidearm-schedule-game ')
    for i in range(1, len(blocks)):
        block = blocks[i]
        # Ignore template/utility list items without a real opponent name.
        name_html = _between(block, 'sidearm-schedule-game-opponent-name">', "</div>")
        name = _clean(name_html)
        if name == "":
            continue
        date_html = _between(block, 'sidearm-schedule-game-opponent-date flex-item-1">', "</div>")
        location_html = _between(block, 'sidearm-schedule-game-location">', "</div>")
        result_html = _between(block, 'sidearm-schedule-game-result text-italic">', "</div>")
        # The toggle label includes the year, unlike the visible short date.
        toggle = _between(block, "Hide/Show Additional Information For ", "</button>")
        full_date = ""
        marker = toggle.rfind(" - ")
        if marker >= 0:
            full_date = _clean(toggle[marker + 3:])
        if full_date == "":
            full_date = _clean(date_html)
        completed = "sidearm-schedule-game-completed" in block[:350]
        result = _clean(result_html)
        if completed and result == "":
            result = "NOT TEAM SCORED"
        meets.append({
            "date": full_date,
            "name": name,
            "location": _clean(location_html),
            "result": result,
            "completed": completed,
        })
    return meets


def _next_meets(meets):
    out = []
    for meet in meets:
        if not meet["completed"]:
            out.append(meet)
            if len(out) == 2:
                break
    return out


def _recent_meets(meets):
    done = []
    for meet in meets:
        if meet["completed"]:
            done.append(meet)
    out = []
    for i in range(2):
        j = len(done) - 1 - i
        if j >= 0:
            out.append(done[j])
    return out


def _draw_meet(c, meet, heading, page):
    _header(c, heading, page)
    _draw_d(c, 4, 9, 20)
    x = 29
    maxw = c.width - x - 3
    name = _clip(c, meet["name"], "5x7b", maxw)
    c.text(name, x, 9, font = "5x7b", color = WHITE)
    detail = meet["date"]
    if meet["location"] != "":
        detail += " | " + meet["location"]
    c.text(_clip(c, detail, "4x5", maxw), x, 18, font = "4x5", color = GRAY)
    if meet["result"] != "":
        c.text(_clip(c, meet["result"], "4x5", maxw), x, 25, font = "4x5", color = GOLD)
    else:
        c.text("UPCOMING", x, 25, font = "4x5", color = GOLD)


def _draw_offseason(c, page):
    _header(c, "NEXT MEET", page)
    _draw_d(c, 4, 9, 20)
    c.text("2026-27 SCHEDULE", 29, 10, font = "5x7b", color = WHITE)
    c.text("COMING SOON", 29, 21, font = "5x7", color = GOLD)


def _fetch_rss():
    r = http.get(RSS_URL, ttl_seconds = 1800,
                 headers = {"User-Agent": "Glance Denison Track app"})
    if r["status_code"] != 200 or not r["body"]:
        return []
    out = []
    blocks = r["body"].split("<item>")
    for i in range(1, len(blocks)):
        item = blocks[i]
        out.append({
            "title": _clean(_between(item, "<title>", "</title>")),
            "description": _clean(_between(item, "<description>", "</description>")),
            "date": _clean(_between(item, "<pubDate>", "</pubDate>")),
        })
    return out


def _draw_story(c, label, title, detail, page):
    _header(c, label, page)
    maxw = c.width - 6
    title_lines = _wrap(c, title, "5x7b", maxw, 2)
    for i in range(len(title_lines)):
        c.text(title_lines[i], 3, 9 + i * 8, font = "5x7b", color = WHITE)
    y = 25 if len(title_lines) > 1 else 18
    c.text(_clip(c, detail, "4x5", maxw), 3, y, font = "4x5", color = GOLD)


def home(c, ctx):
    c.fill(BLACK)
    _draw_d(c, 4, 4, 24)
    c.text("DENISON", 34, 3, font = "10x16_bold", color = WHITE)
    c.text("MEN'S TRACK & FIELD", 35, 21, font = "5x7b", color = RED)


def next_meet(c, ctx):
    upcoming = _next_meets(_fetch_schedule())
    if len(upcoming) > 0:
        _draw_meet(c, upcoming[0], "NEXT MEET", "1/2")
    else:
        _draw_offseason(c, "1/2")


def next_after(c, ctx):
    upcoming = _next_meets(_fetch_schedule())
    if len(upcoming) > 1:
        _draw_meet(c, upcoming[1], "ON DECK", "2/2")
    elif len(upcoming) == 1:
        _draw_meet(c, upcoming[0], "NEXT MEET", "2/2")
    else:
        _draw_offseason(c, "2/2")


def latest_result(c, ctx):
    recent = _recent_meets(_fetch_schedule())
    if len(recent) > 0:
        _draw_meet(c, recent[0], "RECENT RESULT", "1/2")
    else:
        _draw_meet(c, SAMPLE_MEETS[1], "RECENT RESULT", "1/2")


def prior_result(c, ctx):
    recent = _recent_meets(_fetch_schedule())
    if len(recent) > 1:
        _draw_meet(c, recent[1], "RECENT RESULT", "2/2")
    else:
        _draw_meet(c, SAMPLE_MEETS[0], "RECENT RESULT", "2/2")


def jack_latest(c, ctx):
    _header(c, "JACK - LATEST RESULT", "1/2")
    c.text("HARRISON DILLARD", 4, 10, font = "6x8", color = WHITE)
    c.text("4X100 RELAY", 4, 22, font = "5x7b", color = GRAY)
    c.text("2ND  41.64", c.width - 4, 21, font = "6x8", color = GOLD, align = "right")


def jack_bests(c, ctx):
    _header(c, "JACK - COLLEGE BESTS", "2/2")
    c.text("400", 5, 10, font = "5x7b", color = GRAY)
    c.text("49.30", 32, 9, font = "6x8", color = GOLD)
    c.text("200", 91, 10, font = "5x7b", color = GRAY)
    c.text("22.58", 118, 9, font = "6x8", color = GOLD)
    c.text("100  11.35", 5, 23, font = "5x7", color = WHITE)
    c.text("3X ALL-NCAC", c.width - 4, 23, font = "5x7b", color = RED, align = "right")


def latest_news(c, ctx):
    items = _fetch_rss()
    if len(items) == 0:
        _draw_story(c, "BIG RED NEWS", "DENISON MEN'S TRACK & FIELD", "OFFICIAL TEAM UPDATES", "")
        return
    date = items[0]["date"]
    # RSS dates are long; the first 16 characters contain weekday/date/month.
    _draw_story(c, "BIG RED NEWS", items[0]["title"], date[:16], "")
