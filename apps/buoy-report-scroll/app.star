# Buoy Report
#
# NDBC's latest_obs file is plain text, not JSON, and about 400
# bytes — far kinder than the 600KB full history file. It is parsed
# by finding a line by its prefix and pulling the first number out,
# which is robust to the column drift between buoy types.
#
# The same directory also serves a ~2KB per-station .rss whose item title is
# "Station 41013 - Frying Pan Shoals, NC", so the buoy's location does come
# off the feed. It is fetched separately and never fatal: if it 404s or the
# panel is offline the headline falls back to "BUOY <id>".
#
# The art is one generic scene — a lattice-mast discus buoy floating in an
# ocean band that runs the full panel width — so it is identical for every
# station id. Art is inset 4px from the left edge (a deliberate exception to
# the 10px text safe zone); every string is drawn with a stroke so it stays
# readable where it crosses the water.
#
# Layout runs left to right: the buoy hard against the left edge, then the
# headline block (location over the hero stat), then the stats column.


BG = "#050D18"
STROKE = "#020913"

# ocean
FOAM = "#CFEEFF"
MID = "#3E92C8"
DEEP = "#1A5B8C"
BED = "#0E3A5C"

SEA_TOP = 28  # topmost row a wave crest can reach
WAVE = [0, 0, 1, 1, 2, 2, 2, 2, 1, 1, 0, 0]

BUOY_LEGEND = {
    "K": "#08131F",  # outline
    "L": "#FFDF6B",  # beacon
    "M": "#C3D2E0",  # lattice mast
    "S": "#3E63A8",  # solar panel
    "Y": "#F5B92B",  # hull
    "W": "#FFEFAF",  # hull highlight
    "R": "#E24B3A",  # freeboard band
    "O": "#B0771A",  # hull in shadow
}

# 24 wide x 26 tall, drawn at (4, 3) so the keel lands in the wave crest.
BUOY_ART = [
    "..........KLLK..........",
    ".........KLLLLK.........",
    "..........KLLK..........",
    "...........MM...........",
    "..........MMMM..........",
    "..........M..M..........",
    "..........MMMM..........",
    "........SSM..MSS........",
    "........SSM..MSS........",
    "........SSMMMMSS........",
    "..........M..M..........",
    "..........MMMM..........",
    "..........M..M..........",
    "..........MMMM..........",
    ".........MMMMMM.........",
    "......KKKKMMMMKKKK......",
    "...KKYYYYYYYYYYYYYYKK...",
    ".KKYYYYYYYYYYYYYYYYYYKK.",
    "KYWWYYYYYYYYYYYYYYYYYYYK",
    "KYYYYYYYYYYYYYYYYYYYYYYK",
    "KRRRRRRRRRRRRRRRRRRRRRRK",
    "KRRRRRRRRRRRRRRRRRRRRRRK",
    "KOOOOOOOOOOOOOOOOOOOOOOK",
    ".KKOOOOOOOOOOOOOOOOOOKK.",
    "...KKOOOOOOOOOOOOOOKK...",
    ".....KKKKKKKKKKKKKK.....",
]

ART_INSET = 4    # 4px inset — deliberate override of the 10px text zone
BUOY_W = 24
STATS_X = 10     # stats run down the right column, on the safe-zone edge

NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def art_x(c):
    """Left column of the buoy: hard against the left edge of the panel."""
    return ART_INSET


def head_left(c):
    """Left edge of the headline block, 3px clear of the buoy's hull."""
    return art_x(c) + BUOY_W + 5


def stats_right(c):
    """Right edge of the stats column, on the safe-zone edge."""
    return c.width - STATS_X


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
    c.fill(BG)
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text_stroke(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
                      stroke = STROKE, align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 22, font = d[0], color = "#8A93B4",
                      stroke = STROKE, align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text_stroke(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
                      stroke = STROKE, align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 18, font = d[0], color = "#8A93B4",
                      stroke = STROKE, align = "center")


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


DIGITS = "0123456789"


def firstnum(line):
    """First number in a line, or None. Handles 15.5, -3, 30.07."""
    n = ""
    started = False
    for i in range(len(line)):
        ch = line[i]
        if DIGITS.find(ch) >= 0 or (ch == "." and started) or \
           (ch == "-" and not started and i + 1 < len(line) and DIGITS.find(line[i + 1]) >= 0):
            n += ch
            started = True
        elif started:
            break
    if n == "" or n == "-":
        return None
    return float(n)


OK_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ,.-/()&'"


def only_drawable(s):
    """Drop anything the bitmap fonts have no glyph for.

    Names arrive with degree signs and the odd accent; an unknown glyph is
    silently skipped by the renderer, which would jam two words together."""
    out = ""
    prev_space = False
    for i in range(len(s)):
        ch = s[i]
        if OK_CHARS.find(ch) < 0:
            ch = " "
        if ch == " ":
            if prev_space:
                continue
            prev_space = True
        else:
            prev_space = False
        out += ch
    return out.strip()


TRIM = " ,-.:/("


def trim(s):
    """Strip spaces and dangling punctuation off both ends."""
    a = 0
    b = len(s)
    for _ in range(len(s)):
        if a < b and TRIM.find(s[a]) >= 0:
            a += 1
    for _ in range(len(s)):
        if b > a and TRIM.find(s[b - 1]) >= 0:
            b -= 1
    return s[a:b]


LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


def has_letter(s):
    for i in range(len(s)):
        if LETTERS.find(s[i]) >= 0:
            return True
    return False


def place_forms(name):
    """Progressively shorter renderings of one station name, longest first.

    NDBC names run from "Frying Pan Shoals, NC" to 70-odd characters of
    bearing ("Neah Bay - 6 NM North of Cape Flattery, WA (Traffic Separation
    Lighted Buoy)"). Rather than clip mid-word, the drawer walks this ladder:
    whole name, then the head before any dash or bracket, then the head before
    the first comma. Generic — no per-station special cases."""
    # Some names lead with a gauge number ("8764044 - Tesoro Marine
    # Terminal, LA"). A segment with no letters in it is not a place.
    k = name.find(" - ")
    if k >= 0 and not has_letter(name[:k]):
        rest = trim(name[k + 3:])
        if rest != "":
            name = rest

    forms = [name]
    h = name
    for cut in [" - ", "- ", " ("]:
        k = h.find(cut)
        if k >= 0:
            h = h[:k]
    h = trim(h)
    if h != "" and h != name:
        forms.append(h)
    k = h.find(",")
    if k > 0:
        short = trim(h[:k])
        if short != "":
            forms.append(short)
    return forms


def station_place(station):
    """Station name off the feed, e.g. "FRYING PAN SHOALS, NC", or "".

    The per-station .rss beside latest_obs carries an item title of
    "Station 41013 - Frying Pan Shoals, NC" in about 2KB — the location does
    come off the API. Never fatal: a miss just leaves the station id showing."""
    r = http.get("https://www.ndbc.noaa.gov/data/latest_obs/" + station + ".rss",
                 ttl_seconds = 86400)
    if r["status_code"] != 200:
        return ""
    body = r["body"]
    i = body.find("<title>Station ")
    if i < 0:
        return ""
    j = body.find("</title>", i)
    if j < 0:
        return ""
    t = body[i + 7:j]
    k = t.find(" - ")
    if k < 0:
        return ""
    return only_drawable(t[k + 3:].upper())


def findline(lines, prefix):
    for ln in lines:
        if ln.startswith(prefix):
            return ln
    return None


def draw_scene(c):
    """Flat ground, the buoy, then the sea drawn over its keel.

    One scene for every station — nothing here varies with the id."""
    c.fill(BG)

    right = c.width - 1 - ART_INSET      # last art column, 4px in from the edge
    if right < ART_INSET:
        return

    c.sprite(BUOY_ART, art_x(c), 3, legend = BUOY_LEGEND)

    # Ocean: runs from the far inset out to the buoy, full width.
    c.rect(ART_INSET, SEA_TOP + 2, right, c.height - 2, fill = DEEP)
    c.rect(ART_INSET, c.height - 1, right, c.height - 1, fill = BED)
    for x in range(ART_INSET, right + 1):
        top = SEA_TOP + WAVE[(x - ART_INSET) % len(WAVE)]
        c.pixel(x, top, FOAM)
        if top + 1 < c.height:
            c.pixel(x, top + 1, MID)


def readouts(c, wt, at, kt, gkt):
    """[text, color] rows for the right-hand stack, widest label first.

    'G17' beside the wind read as a station code; every value now carries its
    own word so nothing on the panel is a bare code."""
    rows = []
    if wt != None:
        rows.append(["WATER " + str(int(wt)) + "F", "#8FD4FF"])
    if at != None:
        rows.append(["AIR " + str(int(at)) + "F", "#B4D8F0"])
    if kt != None:
        rows.append(["WIND " + str(int(kt)) + "KT", "#9FD0F0"])
    if gkt != None:
        rows.append(["GUST " + str(int(gkt)) + "KT", "#FFD27A"])
    return rows


# Four readouts only fit at 5x7; with three or fewer they get the taller rung.
# Rows are spaced one clear pixel wider than the glyph so the stroke of the row
# below never eats the tail of the row above.
STACK_Y = {
    1: [12],
    2: [4, 16],
    3: [0, 9, 18],
    4: [0, 8, 16, 24],
}
BIG_H = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7}


def fit_place(c, forms, fonts, maxw):
    """[font, text] for the biggest font that holds a whole form of the name.

    Font size wins over completeness — a readable "WINYAH BAY SURFACE" beats a
    4x5 mouthful — and if nothing fits, the shortest form is clipped."""
    for f in fonts:
        for t in forms:
            if c.text_width(t, f) <= maxw:
                return [f, t]
    last = fonts[len(fonts) - 1]
    short = forms[len(forms) - 1]
    t = clip(c, short, last, maxw)

    # Back off to a word boundary so the tail is never a stray half-word
    # ("CENTRAL ALEUTIANS 2"); a single unbreakable word still hard-clips.
    if len(t) < len(short) and short[len(t)] != " ":
        for k in range(len(t), 0, -1):
            if t[k - 1] == " ":
                head = trim(t[:k])
                if head != "":
                    t = head
                break
    return [last, t]


def buoy(c, ctx):
    station = str(ctx.inputs.get("station", "")).strip()
    if station == "":
        nodata(c, "NO STATION", "SET A BUOY ID")
        return

    r = http.get("https://www.ndbc.noaa.gov/data/latest_obs/" + station + ".txt",
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or r["body"] == "":
        nodata(c, "NO BUOY DATA", "CHECK STATION ID")
        return

    lines = r["body"].split("\n")
    wind = findline(lines, "Wind:")
    gust = findline(lines, "Gust:")
    wtmp = findline(lines, "Water Temp:")
    atmp = findline(lines, "Air Temp:")
    wave = findline(lines, "Significant Wave Height:")

    kt = firstnum(wind[wind.find(",") + 1:]) if wind != None and wind.find(",") >= 0 else None
    gkt = firstnum(gust) if gust != None else None
    wt = firstnum(wtmp) if wtmp != None else None
    at = firstnum(atmp) if atmp != None else None
    wv = firstnum(wave) if wave != None else None

    draw_scene(c)

    big = (str(int(wv * 10) / 10.0) + "FT") if wv != None else \
          ((str(int(kt)) + "KT") if kt != None else "--")

    # Location off the feed when it has one, the station id when it does not.
    place = station_place(station)
    forms = place_forms(place) if place != "" else ["BUOY " + station]

    hl = head_left(c)
    sr = stats_right(c)

    if c.width < 128:
        # Narrow panels: one headline plus the water temperature.
        maxw = sr - hl
        if maxw < 12:
            maxw = 12
        p = fit_place(c, forms, ["4x5"], maxw)
        c.text_stroke(p[1], hl, 0, font = p[0], color = "#7FB4DC",
                      stroke = STROKE)
        b = _fit_clip(c, big, ["10x16", "6x8", "5x7", "4x5"], maxw)
        c.text_stroke(b[1], hl, 7, font = b[0], color = "#EAF6FF",
                      stroke = STROKE)
        if wt != None:
            c.text_stroke(clip(c, "WATER " + str(int(wt)) + "F", "4x5", maxw),
                          sr, 23, font = "4x5", color = "#8FD4FF",
                          stroke = STROKE, align = "right")
        return

    rows = readouts(c, wt, at, kt, gkt)
    n = len(rows)
    rfont = "5x7" if n >= 4 else "6x8"
    ys = STACK_Y.get(n, [])

    # The stack claims only the width it needs, and the headline takes the rest.
    cap = 84
    w = 0
    for i in range(n):
        rows[i][0] = clip(c, rows[i][0], rfont, cap)
        tw = c.text_width(rows[i][0], rfont)
        if tw > w:
            w = tw
    maxw = (sr - w - 4) - hl
    if maxw < 24:
        maxw = 24

    # A long place name sheds its bearing tail, then a font rung, then clips.
    p = fit_place(c, forms, ["5x7", "4x5"], maxw)
    c.text_stroke(p[1], hl, 0, font = p[0], color = "#7FB4DC",
                  stroke = STROKE)

    b = _fit_clip(c, big, ["16x20", "10x16", "6x8", "5x7"], maxw)
    by = 8 + (20 - BIG_H[b[0]]) // 2
    c.text_stroke(b[1], hl, by, font = b[0], color = "#EAF6FF",
                  stroke = STROKE)

    for i in range(n):
        c.text_stroke(rows[i][0], sr, ys[i], font = rfont,
                      color = rows[i][1], stroke = STROKE, align = "right")
