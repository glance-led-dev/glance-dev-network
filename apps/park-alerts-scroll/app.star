# Park Alerts
#
# The NPS API. Their published DEMO_KEY works for light use, so the
# app ships usable out of the box and you can drop in your own free
# key when you want the headroom.
#
# Parks are chosen by name from a dropdown of all 60 National Parks
# and mapped to their NPS code here. Nobody knows offhand that
# Yosemite is 'yose', so asking for the code was a bad setting.
# The list came from the NPS API itself, so the codes are right by
# construction.
#
# Closures outrank information notices, because a road closure is
# the thing that changes your plans.



NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do.

    text_fit alone was not enough here: when even its smallest option
    overflows it still draws, which ran these messages off a 64 panel."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands — a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}


def wrap(c, words, font, maxw):
    """Greedily pack words into lines no wider than maxw."""
    lines = []
    cur = ""
    for w in words:
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    return lines


def block(c, text, x, y, maxw, maxh, fonts, color, gap):
    """Draw text at the largest font whose wrapped lines fit maxh."""
    words = str(text).upper().split(" ")
    for f in fonts:
        lines = wrap(c, words, f, maxw)
        if len(lines) * (FONTH[f] + gap) - gap <= maxh:
            for i in range(len(lines)):
                c.text(lines[i], x, y + i * (FONTH[f] + gap), font = f,
                       color = color)
            return len(lines)
    # Nothing fits: use the smallest face, draw what we can, and mark the
    # cut so a dropped tail reads as deliberate rather than as a bug.
    f = fonts[len(fonts) - 1]
    lines = wrap(c, words, f, maxw)
    n = maxh // (FONTH[f] + gap)
    if n > len(lines):
        n = len(lines)
    for i in range(n):
        line = lines[i]
        if i == n - 1 and n < len(lines):
            # `while` is a reserved keyword in Starlark even though the
            # language has no while loop, so this walks back with a for.
            for k in range(len(line), 0, -1):
                if c.text_width(line[:k] + "..", f) <= maxw:
                    line = line[:k]
                    break
            line = line + ".."
        c.text(line, x, y + i * (FONTH[f] + gap), font = f, color = color)
    return n


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws — which is how a station name ended up running
    straight through the readout beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def fitwords(c, text, font, maxw):
    """Longest run of WHOLE words that fits maxw.

    clip() cuts at the pixel and leaves things like "SCHOOL PI" or
    "PAINTED B", which read as a rendering fault rather than an
    abbreviation. This stops at a word boundary instead, and only falls back
    to a hard cut when a single word cannot fit on its own."""
    t = str(text).strip()
    if c.text_width(t, font) <= maxw:
        return t
    parts = t.split(" ")
    out = ""
    for w in parts:
        trial = w if out == "" else out + " " + w
        if c.text_width(trial, font) > maxw:
            break
        out = trial
    if out != "":
        return out
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


RANK = {"PARK CLOSURE": 3, "DANGER": 3, "CAUTION": 2, "INFORMATION": 1}
COLORS = {"PARK CLOSURE": "#FF4B4B", "DANGER": "#FF4B4B",
          "CAUTION": "#FFB03A", "INFORMATION": "#7FD4FF"}


CODES = {
    "ACADIA": "acad",
    "ARCHES": "arch",
    "BADLANDS": "badl",
    "BIG BEND": "bibe",
    "BISCAYNE": "bisc",
    "BLACK CANYON OF THE GUNNISON": "blca",
    "BRYCE CANYON": "brca",
    "CANYONLANDS": "cany",
    "CAPITOL REEF": "care",
    "CARLSBAD CAVERNS": "cave",
    "CHANNEL ISLANDS": "chis",
    "CONGAREE": "cong",
    "CRATER LAKE": "crla",
    "CUYAHOGA VALLEY": "cuva",
    "DEATH VALLEY": "deva",
    "DENALI": "dena",
    "DRY TORTUGAS": "drto",
    "EVERGLADES": "ever",
    "GATES OF THE ARCTIC": "gaar",
    "GATEWAY ARCH": "jeff",
    "GLACIER": "glac",
    "GLACIER BAY": "glba",
    "GRAND CANYON": "grca",
    "GRAND TETON": "grte",
    "GREAT BASIN": "grba",
    "GREAT SAND DUNES": "grsa",
    "GREAT SMOKY MOUNTAINS": "grsm",
    "GUADALUPE MOUNTAINS": "gumo",
    "HALEAKALĀ": "hale",
    "HAWAIʻI VOLCANOES": "havo",
    "HOT SPRINGS": "hosp",
    "INDIANA DUNES": "indu",
    "ISLE ROYALE": "isro",
    "JOSHUA TREE": "jotr",
    "KATMAI": "katm",
    "KENAI FJORDS": "kefj",
    "KOBUK VALLEY": "kova",
    "LAKE CLARK": "lacl",
    "LASSEN VOLCANIC": "lavo",
    "MAMMOTH CAVE": "maca",
    "MESA VERDE": "meve",
    "MOUNT RAINIER": "mora",
    "NEW RIVER GORGE": "neri",
    "NORTH CASCADES": "noca",
    "OLYMPIC": "olym",
    "PETRIFIED FOREST": "pefo",
    "PINNACLES": "pinn",
    "ROCKY MOUNTAIN": "romo",
    "SAGUARO": "sagu",
    "SEQUOIA & KINGS CANYON": "seki",
    "SHENANDOAH": "shen",
    "THEODORE ROOSEVELT": "thro",
    "VIRGIN ISLANDS": "viis",
    "VOYAGEURS": "voya",
    "WHITE SANDS": "whsa",
    "WIND CAVE": "wica",
    "WRANGELL - ST ELIAS": "wrst",
    "YELLOWSTONE": "yell",
    "YOSEMITE": "yose",
    "ZION": "zion",
}


def alerts(c, ctx):
    chosen = str(ctx.inputs.get("park", "")).strip().upper()
    park = CODES.get(chosen, "")
    key = str(ctx.inputs.get("apikey", "")).strip()
    if park == "" or key == "":
        nodata(c, "NOT CONFIGURED", "PICK A PARK")
        return

    r = http.get("https://developer.nps.gov/api/v1/alerts",
                 params = {"parkCode": park, "api_key": key, "limit": "10"},
                 ttl_seconds = 3600)
    if r["status_code"] == 403:
        nodata(c, "BAD KEY", "CHECK THE KEY")
        return
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO PARK DATA", "NO CONNECTION")
        return

    rows = r["json"].get("data", [])
    if len(rows) == 0:
        c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#06120A", "#123020",
                        horizontal = False)
        sz = 24 if c.width >= 128 else 16
        c.image("PINES.png", 1, c.height - sz, w = sz, h = sz)
        c.text("NO ALERTS", c.width - 6, 6,
               font = "10x16" if c.width >= 128 else "6x8", color = "#4EE38A",
               align = "right")
        c.text(clip(c, chosen, "5x7", c.width - 12), c.width - 6, 24,
               font = "5x7", color = "#3E7A56", align = "right")
        return

    top = rows[0]
    best = -1
    for a in rows:
        cat = str(a.get("category", "INFORMATION")).upper()
        if RANK.get(cat, 1) > best:
            best = RANK.get(cat, 1)
            top = a

    cat = str(top.get("category", "INFORMATION")).upper()
    col = COLORS.get(cat, "#7FD4FF")
    title = str(top.get("title", "")).upper()

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#08120C", "#16301E",
                    horizontal = False)
    c.rect(0, 0, c.width - 1, 6, fill = col)
    if c.width >= 128:
        line = "NPS " + cat + " - " + chosen + " " + str(len(rows))
        c.text(clip(c, line, "4x5", c.width - 20), 10, 1, font = "4x5",
               color = "#0A1A10")
    else:
        # The banner colour already carries the category on the small panel.
        c.text(clip(c, chosen, "4x5", c.width - 8), 3, 1, font = "4x5",
               color = "#0A1A10")

    # A lone tree in the corner with a floating grass strip read as an
    # unfinished scene, so the ground now runs the full width and the trees
    # stand on it.
    c.rect(0, c.height - 2, c.width - 1, c.height - 1, fill = "#22804A")
    sz = 16 if c.width >= 128 else 12
    c.image("PINES.png", c.width - sz - 2, c.height - sz - 1, w = sz, h = sz)
    if c.width >= 128:
        c.image("PINES.png", 4, c.height - sz - 1, w = sz, h = sz)
        block(c, title, 24, 9, c.width - sz - 30, 20,
              ["10x16", "6x8", "5x7", "4x5"], "#DCF0E0", 1)
    else:
        block(c, title, 3, 9, c.width - sz - 6, 20,
              ["6x8", "5x7", "4x5"], "#DCF0E0", 1)
