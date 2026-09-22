# Wikipedia Most Read
#
# What the world looked up yesterday, in order, with the number of people
# who looked it up. Wikimedia publishes a daily feed of the most-read
# articles on any language Wikipedia; this app reads the English one by
# default and rotates through the top five, one to a frame.
#
# Data: api.wikimedia.org/feed/v1/wikipedia/<lang>/featured/<Y>/<M>/<D>.
# Keyless. The feed carries the day's featured article, the most-read
# list with view counts and one-line extracts, and an on-this-day list.
# The most-read block is always for the day BEFORE the date requested -
# a day has to finish before it can be counted - so the app asks for
# today and prints the date the feed itself reports, never an assumed one.
#
# The response is around 260 KB because it carries thumbnails and extracts
# for 40-odd articles, which is well inside the 2 MB an app may read, and
# it changes once a day, so it is cached for six hours.
#
# DESIGN. A reading room, not a dashboard. The rank is the hero: a big
# numeral on a podium tile at the left - gold, silver, bronze, then grey -
# the way a chart position reads, with the article title beside it as
# large as it will go. Under the title an eye glyph stands in for the word
# VIEWS, the count sits in the globe's own blue, and a trend arrow with the
# day-over-day change says whether the story is still climbing; five small
# bars at the right draw the last five days of views, so a story that
# exploded overnight looks different from one that has been simmering all
# week. The puzzle-globe glyph sits in the chip row so the panel says
# whose list this is without spending a word on it. A second page stacks
# the top four as a compact chart, each row a bar scaled to the day's
# leader with the same podium colors and trend arrows, so the shape of the
# day - one runaway story, or four even ones - reads from across the room.
#
# Cadence: refresh 3600. The list is a daily count that stops moving once
# published, so an hour is generous; the fetch is cached for six.

FEED = "https://api.wikimedia.org/feed/v1/wikipedia/"
HEADERS = {"User-Agent": "glance-wikipedia-most-read (glance-led.dev)"}
TTL = 21600

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FAINT = "#3E465A"
BLUE = "#5C9BE8"        # the blue of the globe and the view counts
OFFLINE = "#3C4043"
UP = "#3DDC6A"          # still climbing
DOWN = "#E8564A"        # fading

# The podium: rank 1 gold, 2 silver, 3 bronze, the rest a quiet grey.
# ink_for() picks black or white text for each, so no tile can wash out.
PODIUM = ["#F2C14E", "#DDE3EE", "#D08A4E"]
TILE_REST = "#9AA3B5"

def podium(rank):
    return PODIUM[rank - 1] if rank <= len(PODIUM) else TILE_REST

LANGS = {
    "ENGLISH": ["en", "EN"], "SPANISH": ["es", "ES"], "GERMAN": ["de", "DE"],
    "FRENCH": ["fr", "FR"], "JAPANESE": ["ja", "JA"], "RUSSIAN": ["ru", "RU"],
    "PORTUGUESE": ["pt", "PT"], "ITALIAN": ["it", "IT"], "DUTCH": ["nl", "NL"],
    "POLISH": ["pl", "PL"],
}

# --------------------------------------------------------------- pixel art
# The puzzle globe, 11 x 11: a sphere of tiles with a seam down it.
GLOBE = """
...WWWWW...
.WWGWWWGWW.
.WGGWWWGGW.
WWWWWWWWWWW
WGWWGWGWWGW
WWWWWWWWWWW
WGWWGWGWWGW
WWWWWWWWWWW
.WGGWWWGGW.
.WWGWWWGWW.
...WWWWW...
"""
GLOBE_LEGEND = {"W": "#D8DCE3", "G": "#8A93A6"}

# An eye, 9 x 5: the picture is the label, so the word VIEWS never has to
# be spent. Lids in ink, pupil in the count's blue.
EYE = """
..LLLLL..
.L.....L.
L..PPP..L
.L.....L.
..LLLLL..
"""
EYE_LEGEND = {"L": "#D8DCE3", "P": BLUE}
EYE_W = 9

# ------------------------------------------------------------- text tools
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    """clip(), backed up to a whole word unless that costs more than a
    third of what fit - a title cut mid-word reads as a fault."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 3 >= len(t) * 2:
        return t[:sp] + ".."
    return t + ".."

def fit(c, text, fonts, maxw):
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

HEXD = "0123456789abcdef"

def ink_for(fill):
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def pill(c, word, fill, x, y):
    return c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

# ----------------------------------------------------------------- text
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-:;/&+%#!?()$@"
# Starlark has no top-level loops, so the fold table is written out:
# an accent dropped silently turns BEYONCE into BEYONC.
FOLD = {"À": "A", "Á": "A", "Â": "A", "Ã": "A", "Ä": "A", "Å": "A", "Ç": "C", "È": "E",
        "É": "E", "Ê": "E", "Ë": "E", "Ì": "I", "Í": "I", "Î": "I", "Ï": "I", "Ñ": "N",
        "Ò": "O", "Ó": "O", "Ô": "O", "Õ": "O", "Ö": "O", "Ø": "O", "Ù": "U", "Ú": "U",
        "Û": "U", "Ü": "U", "Ý": "Y", "Š": "S", "Ž": "Z", "Æ": "AE", "ß": "SS", "Ð": "D",
        "–": "-", "—": "-", "’": "", "‘": ""}

def clean(s):
    """Panel-safe uppercase. Titles arrive with underscores for spaces and
    occasional accents; the fonts have neither, so both are folded away."""
    out = ""
    last_space = True
    for ch in str(s).replace("_", " ").upper().elems():
        ch = FOLD.get(ch, ch)
        if KEEP.find(ch) < 0:
            ch = " " if ch == "\n" or ch == "\t" else ""
            if ch == "":
                continue
        if ch == " ":
            if last_space:
                continue
            last_space = True
        else:
            last_space = False
        out += ch
    return out.strip()

def commas(n):
    s = str(n)
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return out

def compact(n):
    """526535 -> 527K, 1240000 -> 1.2M. The panel has room for a shape,
    not a ledger."""
    if n < 1000:
        return str(n)
    if n < 999500:
        return str((n + 500) // 1000) + "K"
    tenths = (n + 50000) // 100000
    return str(tenths // 10) + "." + str(tenths % 10) + "M"

def delta(hist):
    """Day-over-day change as [direction, label]: '+26%' while the move is
    under a doubling, '5X' once it is past one, so a story that came from
    nowhere reads as a multiple rather than a four-digit percentage."""
    if len(hist) < 2 or hist[-2] <= 0:
        return None
    now, prev = hist[-1], hist[-2]
    if now >= prev * 2:
        return [1, str((now + prev // 2) // prev) + "X"]
    pct = (now - prev) * 100 // prev if now >= prev else -((prev - now) * 100 // prev)
    if pct > 0:
        return [1, "+" + str(pct) + "%"]
    if pct < 0:
        return [-1, str(pct) + "%"]
    return [0, "FLAT"]

def trend_color(direction):
    return UP if direction > 0 else (DOWN if direction < 0 else DIM)

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def num(s, fallback = -1):
    t = str(s).strip()
    if t == "":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return int(t)

def pad(n):
    return str(n) if n >= 10 else "0" + str(n)

def day_label(iso):
    """'2026-09-15Z' -> 'SEP 15'. The feed states the day it counted, so
    the panel repeats that rather than assuming yesterday."""
    t = str(iso)
    if len(t) < 10:
        return ""
    mo, dy = num(t[5:7]), num(t[8:10])
    if mo < 1 or mo > 12 or dy < 1:
        return ""
    return MONTHS[mo - 1] + " " + str(dy)

# ------------------------------------------------------------------- feed
def fetch(ctx):
    label = str(ctx.inputs.get("language", "ENGLISH")).strip().upper()
    if label not in LANGS:
        label = "ENGLISH"
    lang = LANGS[label]
    n = ctx.now
    url = FEED + lang[0] + "/featured/" + str(n.year) + "/" + pad(n.month) + "/" + pad(n.day)
    r = http.get(url, headers = HEADERS, ttl_seconds = TTL)
    base = {"lang": lang[1]}
    if r["status_code"] == 0:
        return dict(base, ok = False, head = "WIKIPEDIA OFFLINE", sub = "RETRY IN AN HOUR")
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return dict(base, ok = False, head = "WIKIPEDIA ERROR",
                    sub = "HTTP " + str(r["status_code"]) + " - RETRY LATER")
    mr = get(r["json"], "mostread", {})
    arts = get(mr, "articles", [])
    if type(arts) != "list" or len(arts) == 0:
        return dict(base, ok = False, head = "NO LIST YET",
                    sub = "TODAYS COUNT IS NOT PUBLISHED")
    out = []
    for a in arts:
        title = clean(dig(a, ["titles", "normalized"], get(a, "title", "")))
        views = get(a, "views", 0)
        # A wholly non-Latin title - most of the Japanese list - cleans
        # down to nothing or to stray punctuation, and a blank row is
        # worse than a shorter list.
        if len(title) < 2 or type(views) != "int":
            continue
        # The feed puts the main page in the list; nobody reads it as an
        # article, and it would swamp every real story.
        if title.startswith("MAIN PAGE") or title.startswith("SPECIAL"):
            continue
        # The feed carries the last five days of counts for every article;
        # they draw the bars and the trend. Today's count is always the
        # last entry so the arrow compares the right two days.
        hist = []
        for h in get(a, "view_history", []):
            v = get(h, "views", None)
            if type(v) == "int" and v >= 0:
                hist.append(v)
        if len(hist) == 0 or hist[-1] != views:
            hist.append(views)
        out.append({"title": title, "views": views, "hist": hist[-5:]})
        if len(out) == 5:
            break
    if len(out) == 0:
        return dict(base, ok = False, head = "NO LIST YET", sub = "NOTHING RANKED FOR THIS DAY")
    return dict(base, ok = True, arts = out, day = day_label(get(mr, "date", "")))

# ---------------------------------------------------------------- chrome
def chip_row(c, d, right, globe = True):
    """The date is never clipped: SEP 1 is a different day from SEP 16, so
    the label drops whole pieces - the word WIKIPEDIA first, then the
    edition - rather than losing characters off the end."""
    x = 10
    if globe:
        c.sprite(GLOBE, 10, 0, legend = GLOBE_LEGEND)
        x = 10 + 11 + 3
    w = pill(c, "MOST READ", BLUE, x, 0)
    x += w + 3
    rw = c.text_width(right, "4x5")
    c.text(right, 181, 1, font = "4x5", color = DIM, align = "right")
    room = 181 - rw - 5 - x + 1
    day = ("  " + d["day"]) if d["day"] != "" else ""
    for label in [d["lang"] + " WIKIPEDIA" + day, d["lang"] + day, day.strip()]:
        if c.text_width(label, "4x5") <= room:
            c.text(label, x, 1, font = "4x5", color = INK)
            return

def fail_screen(c, d):
    c.fill("black")
    rail(c, OFFLINE)
    c.sprite(GLOBE, 10, 10, legend = GLOBE_LEGEND)
    hf = fit(c, d["head"], ["6x8", "5x7", "4x5"], 140)
    c.text(hf[1], 110, 10, font = hf[0], color = "amber", align = "center")
    sf = fit(c, d["sub"], ["4x5", "picopixel"], 140)
    c.text(sf[1], 110, 22, font = sf[0], color = DIM, align = "center")

# --------------------------------------------------------------- page: one
def article(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail_screen(c, d)
        return
    n = len(d["arts"])
    idx = (ctx.now.unix // 60) % n
    a = d["arts"][idx]
    c.fill("black")
    rail(c, BLUE)
    chip_row(c, d, str(idx + 1) + "/" + str(n))

    # The rank on its podium tile, x 10..27, y 12..30: a chart position,
    # not a bullet, so it gets the weight. The tile starts a row under the
    # globe (y 0..10) so the two never touch.
    rank = idx + 1
    tile = podium(rank)
    c.round_rect(10, 12, 27, 30, 3, fill = tile)
    c.text(str(rank), 19, 13, font = "10x16", color = ink_for(tile), align = "center")

    # Title as big as it goes in x 32..181. The title takes two lines at
    # 6x8 when one will not hold it, because a title is the whole point
    # of the page. Either way the footer row sits at y 27.
    tx, tw = 32, 150
    one = fit(c, a["title"], ["10x16", "8x10", "6x8"], tw)
    if c.text_width(a["title"], one[0]) <= tw:
        c.text(one[1], tx, 9, font = one[0], color = INK)
    else:
        # Two lines split on a space, never inside a word: a title broken
        # as ZOZ / 6 LEG reads as a fault rather than as a wrap.
        head = clip(c, a["title"], "6x8", tw)
        cut = head.rfind(" ")
        if cut <= 0:
            cut = len(head)
        c.text(head[:cut], tx, 9, font = "6x8", color = INK)
        c.text(clip_words(c, a["title"][cut:].strip(), "6x8", tw), tx, 18, font = "6x8", color = INK)

    # Footer row, y 27..31: eye, count, trend arrow with the day-over-day
    # change, and the five-day bars right-aligned in the safe zone.
    fy = 27
    c.sprite(EYE, tx, fy, legend = EYE_LEGEND)
    x = tx + EYE_W + 3
    count = commas(a["views"])
    c.text(count, x, fy, font = "4x5", color = BLUE)
    x += c.text_width(count, "4x5") + 4
    bars_w = 34     # five bars of 6 px, 1 px apart
    bars_x = 181 - bars_w + 1
    d = delta(a["hist"])
    if d != None and x + 5 + 2 + c.text_width(d[1], "4x5") < bars_x - 3:
        col = trend_color(d[0])
        c.trend_arrow(x, fy, d[0], color = col)
        c.text(d[1], x + 7, fy, font = "4x5", color = col)
    if len(a["hist"]) >= 2:
        c.bars(a["hist"], bars_x, fy, bars_w, 5, color = BLUE, gap = 1, min_val = 0)

# -------------------------------------------------------------- page: five
def toplist(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    rail(c, BLUE)

    # Four rows on a 6 px pitch (y 8, 14, 20, 26). Five would have to sit
    # 5 px apart, and a 5 px face on a 5 px pitch means every row touches
    # the one below it; the rest of the list is counted in the chip row.
    shown = d["arts"][:4]
    more = len(d["arts"]) - len(shown)
    chip_row(c, d, ("+" + str(more) + " MORE") if more > 0 else "TOP " + str(len(shown)), False)

    top = d["arts"][0]["views"]
    for i in range(len(shown)):
        a = shown[i]
        y = 8 + i * 6
        vs = compact(a["views"])
        vw = c.text_width(vs, "4x5")
        # The bar underlays its own row only, so it reads as a chart.
        bw = 171 * a["views"] // top if top > 0 else 0
        if bw > 0:
            c.rect(10, y, 10 + bw - 1, y + 4, fill = "#10294A")
        # Rank numeral in its podium color, the same gold / silver / bronze
        # as the tiles on the article page.
        c.text(str(i + 1), 11, y, font = "4x5", color = podium(i + 1))
        c.text(vs, 181, y, font = "4x5", color = DIM, align = "right")
        # A trend arrow just left of the count, right-aligned so the title
        # column ends in the same place whatever the count's width.
        right = 181 - vw - 2
        dl = delta(a["hist"])
        if dl != None:
            c.trend_arrow(right - 5, y, dl[0], color = trend_color(dl[0]))
            right -= 5 + 3
        c.text(clip_words(c, a["title"], "4x5", right - 17), 17, y, font = "4x5", color = INK)
