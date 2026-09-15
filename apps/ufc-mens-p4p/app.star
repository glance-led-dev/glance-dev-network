# UFC Men's P4P -- the media panel's pound-for-pound list on a Pro scroll.
#
# DESIGN. A fight poster, not a spreadsheet. A red octagon is the mark on both
# pages, and it carries the app's state: red while the list is live, gray when
# the feed is down. Page one is the main event -- a gold crown and a big 1 over
# the best fighter in the world, with the next four beside him. Page two is the
# rest of the card, six through fifteen. Gold only ever means rank, white only
# ever means a name, and green/red only ever mean movement, so nothing on the
# panel competes with the names.

API_URL = "https://api.citoapi.com/api/v1/ufc/rankings/media"

MARK = "#D20A0A"       # octagon ring
MARK_IN = "#4A0606"    # the ring's inner shadow
GOLD = "#FFC72C"       # rank numerals and the crown
GOLD_DK = "#8C6410"    # crown band
INK = "#F4F7FF"        # names
DIM = "#6E7A94"        # labels and first names
STRUCT = "darkgray"    # dividers
OFF = "#505050"        # the ring when there is no data
UP = "green"
DOWN = "#FF3B30"       # brighter than MARK so a drop never reads as the logo

PAD = 8                # scroll safe zone, both outer edges
RIGHT = 375            # last column content may touch on a 384-wide app
MINGAP = 6             # narrowest gap between two ranking columns

FONTH = {"10x16": 16, "9x12": 12, "8x12": 12, "6x8": 8, "5x7": 7, "4x7": 7, "4x5": 5}
# 7x12 is left out on purpose: its A is taller than the other letters, so
# NURMAGOMEDOV drew with a lump in the middle.
HERO_FONTS = ["10x16", "9x12"]
HERO_LAST_WORD_FONTS = ["10x16", "9x12", "8x12", "6x8", "5x7"]
LIST_FONTS = ["5x7", "4x7"]

CROWN = """
G.....G.....G
GG...GGG...GG
GGG.GGRGG.GGG
GGGGGGGGGGGGG
DDDDDDDDDDDDD
"""
CROWN_LEGEND = {"G": GOLD, "R": MARK, "D": GOLD_DK}

UP_ART = """
..#..
.###.
#####
"""
DOWN_ART = """
#####
.###.
..#..
"""

# Shown when no key is set, labelled DEMO on the panel and promised in the
# input's help text. It goes through the same parser as the live feed.
DEMO = [
    {"rank": 1, "fighterName": "Islam Makhachev", "rankChange": 0},
    {"rank": 2, "fighterName": "Ilia Topuria", "rankChange": 0},
    {"rank": 3, "fighterName": "Merab Dvalishvili", "rankChange": 1},
    {"rank": 4, "fighterName": "Alexander Volkanovski", "rankChange": -1},
    {"rank": 5, "fighterName": "Khamzat Chimaev", "rankChange": 2},
    {"rank": 6, "fighterName": "Alexandre Pantoja", "rankChange": 0},
    {"rank": 7, "fighterName": "Jack Della Maddalena", "rankChange": 3},
    {"rank": 8, "fighterName": "Tom Aspinall", "rankChange": -1},
    {"rank": 9, "fighterName": "Magomed Ankalaev", "rankChange": 0},
    {"rank": 10, "fighterName": "Alex Pereira", "rankChange": -2},
    {"rank": 11, "fighterName": "Dricus Du Plessis", "rankChange": -3},
    {"rank": 12, "fighterName": "Belal Muhammad", "rankChange": 0},
    {"rank": 13, "fighterName": "Max Holloway", "rankChange": 0},
    {"rank": 14, "fighterName": "Charles Oliveira", "rankChange": 1},
    {"rank": 15, "fighterName": "Sean O'Malley", "rankChange": -1},
]

# The bitmap fonts are ASCII. Without this, "JOSÉ ALDO" draws as "JOS ALDO".
ACCENTS = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E", "Ě": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O", "Ø": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U", "Ů": "U",
    "Ç": "C", "Ć": "C", "Č": "C", "Ñ": "N", "Ń": "N",
    "Š": "S", "Ś": "S", "Ş": "S", "Ž": "Z", "Ż": "Z",
    "Ł": "L", "Ř": "R", "Ý": "Y", "Ğ": "G", "Đ": "D",
}

# ------------------------------------------------------------------ helpers
def get(obj, key, fallback = None):
    """dict.get that survives a null parent or a null value."""
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def num(s, fallback):
    """int() raises on anything non-numeric, and a raised error kills the whole
    render, so every number out of the feed ("+2", "NR", null) comes through here."""
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    if t == "":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return -int(t) if neg else int(t)

# None of the fonts carry an apostrophe -- "MEN'S" drew as "MENS" and
# "O'MALLEY" as "OMALLEY" -- so tw/txt measure and draw one by hand.
def tick(font):
    return [2, 4] if FONTH.get(font, 7) >= 12 else [1, 2]

def tw(c, s, font):
    parts = str(s).split("'")
    w = 0
    for p in parts:
        w += c.text_width(p, font)
    return w + (len(parts) - 1) * (tick(font)[0] + 2)

def txt(c, s, x, y, font, color):
    parts = str(s).split("'")
    tk = tick(font)
    cx = x
    for i in range(len(parts)):
        if i > 0:
            c.rect(cx + 1, y, cx + tk[0], y + tk[1] - 1, fill = color)
            cx += tk[0] + 2
        if parts[i] != "":
            c.text(parts[i], cx, y, font = font, color = color)
            cx += c.text_width(parts[i], font)

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw`. Nothing in the API clips."""
    t = str(text)
    for k in range(len(t), 0, -1):
        if tw(c, t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_mark(c, text, font, maxw):
    """clip(), but a cut name ends in a period (NURMAGOM.) so it reads as an
    abbreviation rather than a rendering fault."""
    t = str(text)
    if tw(c, t, font) <= maxw:
        return t
    for k in range(len(t) - 1, 0, -1):
        if tw(c, t[:k] + ".", font) <= maxw:
            return t[:k] + "."
    return ""

def fit(c, text, fonts, maxw):
    """[font, text] for the largest listed font that fits, hard-clipped in the
    smallest when none do. 8x12 draws '-' as a solid block, so a hyphenated
    name (SAINT-DENIS, KARA-FRANCE) never gets it."""
    dashed = str(text).find("-") >= 0
    ok = [f for f in fonts if not (dashed and f == "8x12")]
    for f in ok:
        if tw(c, text, f) <= maxw:
            return [f, text]
    f = ok[len(ok) - 1]
    return [f, clip(c, text, f, maxw)]

def squash(s):
    out = ""
    for ch in str(s).upper().elems():
        if (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9"):
            out += ch
    return out

def clean(s):
    t = str(s).upper()
    for k in ACCENTS:
        t = t.replace(k, ACCENTS[k])
    t = t.replace("’", "'")
    out = ""
    for ch in t.elems():
        if ch >= " " and ch <= "~":
            out += ch
    return " ".join(out.split())

def split_name(name):
    """[first, rest]. Surnames keep every word after the first, so DU PLESSIS
    and DELLA MADDALENA stay whole wherever they fit."""
    parts = clean(name).split()
    if len(parts) == 0:
        return ["", "TBA"]
    if len(parts) == 1:
        return ["", parts[0]]
    return [parts[0], " ".join(parts[1:])]

def last_word(s):
    words = s.split()
    return words[len(words) - 1] if len(words) > 1 else s

# ------------------------------------------------------------------ the feed
def is_mens_p4p(div):
    s = squash(div)
    if s.find("WOMEN") >= 0:
        return False
    return s.find("POUNDFORPOUND") >= 0 or s.find("P4P") >= 0

LIST_KEYS = ["fighters", "rankings", "rows", "entries", "data"]

def first_list(obj):
    for k in LIST_KEYS:
        v = get(obj, k, None)
        if type(v) == "list":
            return v
    return None

def p4p_rows(js):
    """The P4P rows, whether the feed is a flat list tagged by division (what
    the contributor's code read) or grouped by division."""
    data = js
    if type(js) == "dict":
        data = first_list(js)
        if data == None:
            data = get(js, "data", {})
    out = []
    if type(data) == "dict":
        for k in data:
            v = data[k]
            div = str(k)
            if type(v) == "dict":
                div = str(get(v, "division", k))
                v = first_list(v)
            if type(v) == "list" and is_mens_p4p(div):
                out.extend(v)
        return out
    if type(data) != "list":
        return out
    for row in data:
        if type(row) != "dict":
            continue
        div = get(row, "normalizedDivision", get(row, "division", ""))
        inner = first_list(row)
        if inner != None:
            if is_mens_p4p(get(row, "name", div)) or is_mens_p4p(div):
                out.extend(inner)
        elif is_mens_p4p(div):
            out.append(row)
    return out

def normalize(raw):
    rows = []
    for i in range(len(raw)):
        r = raw[i]
        if type(r) != "dict":
            continue
        name = str(get(r, "fighterName", ""))
        if name == "":
            name = str(get(r, "name", ""))
        if name == "":
            name = str(get(get(r, "fighter", None), "name", ""))
        parts = split_name(name)
        rows.append({
            "rank": num(get(r, "rank", ""), i + 1),
            "move": num(get(r, "rankChange", 0), 0),
            "first": parts[0],
            "last": parts[1],
        })

    def by_rank(row):
        return row["rank"]

    return sorted(rows, key = by_rank)[:15]

def fetch(ctx):
    v = ctx.inputs.get("citokey", "")
    key = "" if v == None else str(v).strip()
    if key == "":
        return {"state": "demo", "rows": normalize(DEMO)}

    # The media panel votes weekly, so a day-old copy is still this week's list
    # and the viewer's API quota lasts; refresh stays hourly to pick it up.
    resp = http.get(API_URL, headers = {"x-api-key": key}, ttl_seconds = 86400)
    code = resp["status_code"]
    if code == 401 or code == 403:
        return {"state": "badkey", "rows": []}
    if code == 429:
        return {"state": "rate", "rows": []}
    if code != 200 or resp["json"] == None:
        return {"state": "offline", "rows": []}
    rows = normalize(p4p_rows(resp["json"]))
    if len(rows) == 0:
        return {"state": "empty", "rows": []}
    return {"state": "ok", "rows": rows}

# ------------------------------------------------------------------ drawing
def in_oct(x, y, n, cut):
    if x < 0 or y < 0 or x >= n or y >= n:
        return False
    fx = n - 1 - x
    fy = n - 1 - y
    return x + y >= cut and fx + y >= cut and x + fy >= cut and fx + fy >= cut

def octagon_art(n, cut):
    """A two-ring octagon as sprite rows: A is the cage, B its inner shadow."""
    rows = []
    for y in range(n):
        row = ""
        for x in range(n):
            if not in_oct(x, y, n, cut):
                row += "."
            elif not in_oct(x - 1, y - 1, n - 2, cut):
                row += "A"
            elif not in_oct(x - 2, y - 2, n - 4, cut):
                row += "B"
            else:
                row += "."
        rows.append(row)
    return rows

OCT = 24
OCTAGON = octagon_art(OCT, 7)

def lockup(c, st, full):
    """The octagon mark, plus the UFC / MEN'S title on page one. Demo mode is
    labelled here on both pages, so it can never be mistaken for the real list."""
    live = st["state"] in ["ok", "demo", "empty"]
    c.sprite(OCTAGON, PAD, 4, legend = {"A": MARK if live else OFF,
                                         "B": MARK_IN if live else STRUCT})
    word = "P4P"
    wcol = INK if live else DIM
    if st["state"] == "demo" and not full:
        word = "DEMO"
        wcol = "amber"
    ww = c.text_width(word, "4x5")
    c.text(word, PAD + (OCT - ww) // 2, 14, font = "4x5", color = wcol)
    if not full:
        return
    tx = PAD + OCT + 5
    c.text("UFC", tx, 4, font = "6x8", color = INK)
    txt(c, "MEN'S", tx, 14, "4x5", DIM)
    if st["state"] == "demo":
        c.badge("DEMO", tx - 1, 21, color = "black", bg = "amber", font = "4x5", pad = 1)
    else:
        c.text("MEDIA", tx, 22, font = "4x5", color = DIM)

def arrow(c, move, x, y):
    c.sprite(UP_ART if move > 0 else DOWN_ART, x, y, color = UP if move > 0 else DOWN)

def message(c, x0, head, sub, color):
    """The one card every non-list state shares, centred in the content area."""
    cx = (x0 + RIGHT) // 2
    w = RIGHT - x0 - 8
    h = fit(c, head, ["6x8", "5x7", "4x5"], w)
    txt(c, h[1], cx - tw(c, h[1], h[0]) // 2, 16 - FONTH[h[0]], h[0], color)
    s = clip(c, sub, "4x5", w)
    txt(c, s, cx - tw(c, s, "4x5") // 2, 19, "4x5", DIM)

def card(c, st, x0):
    s = st["state"]
    if s == "badkey":
        message(c, x0, "CITO KEY NOT ACCEPTED", "CHECK THE API KEY IN SETTINGS", "amber")
    elif s == "rate":
        message(c, x0, "CITO RATE LIMIT HIT", "RANKINGS RETURN NEXT REFRESH", "amber")
    elif s == "offline":
        message(c, x0, "CAN'T REACH CITO", "TRYING AGAIN EVERY HOUR", "amber")
    elif s == "empty":
        message(c, x0, "NO P4P LIST POSTED YET", "CHECK BACK AFTER THE NEXT VOTE", INK)
    else:
        return False
    return True

def hero(c, f, x0, x1):
    """Crown, rank and name for No. 1. Returns the rightmost x it drew, so the
    divider can sit against the name instead of a worst-case gap."""
    c.sprite(CROWN, x0, 4, legend = CROWN_LEGEND)
    rank = str(f["rank"])
    rw = c.text_width(rank, "10x16")
    c.text(rank, x0 + 7 - rw // 2, 12, font = "10x16", color = GOLD)

    # Surname sits on the rank's baseline; the first name rides above it, so a
    # smaller surname font pulls the eyebrow down with it.
    nx = x0 + 19
    maxw = x1 - nx
    first = f["first"]
    name = f["last"]
    last = None
    for hf in HERO_FONTS:
        if last == None and tw(c, name, hf) <= maxw:
            last = [hf, name]
    if last == None:
        words = name.split()
        if len(words) > 1:
            # DELLA MADDALENA is 146px even in 9x12. Rather than shrink it to
            # body size, the leading words move up beside the first name and
            # MADDALENA keeps the hero font.
            first = (first + " " + " ".join(words[:-1])).strip()
            name = words[len(words) - 1]
        last = fit(c, name, HERO_LAST_WORD_FONTS, maxw)
    ly = 28 - FONTH[last[0]]
    txt(c, last[1], nx, ly, last[0], INK)
    end = nx + tw(c, last[1], last[0])

    ey = ly - 7
    move = f["move"]
    mtext = str(move if move > 0 else -move)
    mw = 7 + c.text_width(mtext, "4x5") if move != 0 else 0
    first = clip(c, first, "4x5", maxw - (mw + 4 if mw > 0 else 0))
    txt(c, first, nx, ey, "4x5", DIM)
    mx = nx + tw(c, first, "4x5") + (4 if first != "" else 0)
    if move != 0:
        arrow(c, move, mx, ey + 1)
        c.text(mtext, mx + 7, ey, font = "4x5", color = UP if move > 0 else DOWN)
        mx += mw
    return end if end > mx else mx

def columns(c, entries, names, font, ncols):
    """Per column: [arrow reserve, rank width, name width]."""
    spec = []
    for j in range(ncols):
        spec.append([0, 0, 0])
    for k in range(len(entries)):
        s = spec[k % ncols]
        if entries[k]["move"] != 0:
            s[0] = 6
        rw = c.text_width(str(entries[k]["rank"]), "5x7")
        s[1] = rw if rw > s[1] else s[1]
        nw = tw(c, names[k], font)
        s[2] = nw if nw > s[2] else s[2]
    return spec

def spec_width(spec):
    w = 0
    for s in spec:
        w += s[0] + s[1] + 3 + s[2]
    return w

def table(c, entries, x0, x1, ncols, ys):
    """Ranked fighters in aligned columns spread across x0..x1. One font for the
    whole table: 5x7 with full surnames, then last words only (DELLA MADDALENA
    -> MADDALENA), then 4x7 the same way; only when all four overflow does a
    name get hard-clipped, into an even share of the width."""
    n = len(entries)
    if n == 0:
        return
    avail = x1 - x0 + 1
    gaps = (ncols - 1) * MINGAP
    chosen = None
    for f in LIST_FONTS:
        for short in [False, True]:
            names = [last_word(e["last"]) if short else e["last"] for e in entries]
            spec = columns(c, entries, names, f, ncols)
            if chosen == None and spec_width(spec) + gaps <= avail:
                chosen = [f, names, spec]
    if chosen == None:
        # Still too long: lower one cap over every name column until the table
        # fits, so only the longest columns lose letters and short ones stay whole.
        f = LIST_FONTS[len(LIST_FONTS) - 1]
        names = [last_word(e["last"]) for e in entries]
        spec = columns(c, entries, names, f, ncols)
        budget = avail - gaps
        cap = 0
        for s in spec:
            budget -= s[0] + s[1] + 3
            cap = s[2] if s[2] > cap else cap
        for _ in range(cap):
            used = 0
            for s in spec:
                used += s[2] if s[2] < cap else cap
            if used <= budget:
                break
            cap -= 1
        for s in spec:
            s[2] = s[2] if s[2] < cap else cap
        chosen = [f, names, spec]

    font, names, spec = chosen[0], chosen[1], chosen[2]
    gap = (avail - spec_width(spec)) // (ncols - 1) if ncols > 1 else 0
    colx = []
    x = x0
    for s in spec:
        colx.append(x)
        x += s[0] + s[1] + 3 + s[2] + gap

    for k in range(n):
        row = k // ncols
        if row >= len(ys):
            break
        s = spec[k % ncols]
        e = entries[k]
        y = ys[row]
        rank = str(e["rank"])
        # Rank right-aligned so names line up; the arrow hugs its own numeral
        # ("^7 MADDALENA") rather than the column edge, where it read as
        # belonging to the next column's rank.
        rx = colx[k % ncols] + s[0] + s[1] - c.text_width(rank, "5x7")
        c.text(rank, rx, y, font = "5x7", color = GOLD)
        if e["move"] != 0:
            arrow(c, e["move"], rx - 6, y + 2)
        nx = colx[k % ncols] + s[0] + s[1] + 3
        txt(c, clip_mark(c, names[k], font, s[2]), nx, y, font, INK)

# ------------------------------------------------------------------ pages
def top(c, ctx):
    c.clear()
    st = fetch(ctx)
    lockup(c, st, True)
    c.vline(66, 4, 24, STRUCT)
    if card(c, st, 72):
        return
    rows = st["rows"]
    end = hero(c, rows[0], 72, 214)
    div = end + 8 if end + 8 > 180 else 180
    c.vline(div, 4, 24, STRUCT)
    table(c, rows[1:5], div + 7, RIGHT, 2, [6, 19])

def ranks(c, ctx):
    c.clear()
    st = fetch(ctx)
    lockup(c, st, False)
    c.vline(37, 4, 24, STRUCT)
    if card(c, st, 43):
        return
    rows = st["rows"]
    if len(rows) <= 5:
        message(c, 43, "TOP " + str(len(rows)) + " ONLY THIS WEEK",
                "NO FIGHTERS RANKED BELOW", INK)
        return
    table(c, rows[5:15], 43, RIGHT, 5, [6, 19])
