# Norm's Lounge - Game Day Board header for Glance SCROLL.
# 192x32 app. Three pages slide by: title -> board -> kickoff.
# Content stays inside the scroll safe zone (x 6..185) with black edges
# so the header reads as its own unit between neighboring apps.

RED = "#E4512F"
ORANGE = "#EF733A"
AMBER = "#F59A3D"
GOLD = "#FBC85A"
SUN = "#FCE29A"
TEAL = "#0E7177"
WAVE = "#4DB8C0"
BROWN = "#6B2312"
LEAF = "#2E9A45"
LEAF2 = "#1F6E2F"
TRUNK = "#8A5A2B"

PALM = [
    "..ll...ll..",
    ".lLLl.lLLl.",
    "l...LlL...l",
    "...lLcLl...",
    "..l..t..l..",
    ".....t.....",
    ".....t.....",
    "......t....",
    "......t....",
    "......t....",
    ".......t...",
    ".......t...",
    ".......t...",
    ".......t...",
]
PALM_LEGEND = {"l": LEAF, "L": LEAF2, "c": BROWN, "t": TRUNK}

PAD = 6

def band(c, y0, y1, color):
    c.rect(PAD, y0, c.width - 1 - PAD, y1, fill=color)

def scene(c, water_y):
    w = c.width
    mid = w // 2
    c.clear()
    # sunset stripes, like the printed sheet
    band(c, 0, 4, RED)
    band(c, 5, 9, ORANGE)
    band(c, 10, water_y - 9, AMBER)
    band(c, water_y - 8, water_y - 1, GOLD)
    # setting sun
    c.fill_circle(mid, water_y, 9, SUN)
    c.hline(mid - 8, water_y - 3, 17, GOLD)
    c.hline(mid - 9, water_y - 1, 19, GOLD)
    # ocean and waves
    band(c, water_y, 31, TEAL)
    for x in range(PAD + 1, w - PAD - 3, 6):
        c.pixel(x, water_y + 2, WAVE)
        c.pixel(x + 1, water_y + 1, WAVE)
        c.pixel(x + 2, water_y + 2, WAVE)
    # palms inside the safe zone, one on each end
    if w >= 128:
        c.sprite(PALM, PAD + 2, 18, legend=PALM_LEGEND)
        rev = ["".join([r[len(r) - 1 - i] for i in range(len(r))]) for r in PALM]
        c.sprite(rev, w - PAD - 13, 18, legend=PALM_LEGEND)

def font_h(f):
    return int(f.split("x")[1].split("_")[0])

def wide(c, s, f):
    # width including hand-drawn apostrophes (big fonts have none)
    parts = s.split("'")
    w = 0
    for p in parts:
        w += c.text_width(p, font=f)
    return w + 5 * (len(parts) - 1)

def pick_font(c, s, fonts, maxw):
    # largest font from the list that fits within maxw pixels
    for f in fonts:
        if wide(c, s, f) <= maxw:
            return f
    return fonts[-1]

def centered(c, s, y, fonts, color, stroke):
    maxw = c.width - 2 * PAD - 30
    f = pick_font(c, s, fonts, maxw)
    x = (c.width - wide(c, s, f)) // 2
    h = font_h(f)
    parts = s.split("'")
    for i in range(len(parts)):
        p = parts[i]
        if p:
            c.text_stroke(p, x, y, font=f, color=color, stroke=stroke, thickness=1)
            x += c.text_width(p, font=f)
        if i < len(parts) - 1:
            mh = max(2, h // 4)
            c.rect(x + 1, y - 1, x + 4, y + mh, fill=stroke)
            c.rect(x + 2, y, x + 3, y + mh - 1, fill=color)
            x += 5

def title(c, ctx):
    scene(c, 23)
    centered(c, "NORM'S LOUNGE", 3, ["10x16_bold", "10x16", "10x15", "8x12", "7x12", "6x8"], "white", BROWN)

def board(c, ctx):
    week = str(ctx.inputs.get("week", "NOV 24 - 30  2026")).upper()
    scene(c, 18)
    centered(c, "GAME DAY BOARD", 3, ["7x12", "8x12", "7x10", "6x8", "5x7"], "white", BROWN)
    centered(c, week, 21, ["7x10", "6x8", "5x7", "4x7"], "white", "black")

def kickoff(c, ctx):
    scene(c, 18)
    centered(c, "IT'S KICKOFF", 3, ["7x12", "8x12", "7x10", "6x8"], "white", BROWN)
    centered(c, "SOMEWHERE", 21, ["7x10", "6x8", "5x7"], GOLD, "black")
