# Arcade Basketball High Score
#
# DESIGN. One number matters on an arcade basketball machine: the record. So
# the panel makes the record the hero and everything else chrome -- the title
# strip names the machine, the name underneath says who to beat, and the score
# is as large as 32 pixels of height will allow.
#
# The name and the score are typed straight into the app's settings. A house
# record falls a few times a year, which is rarer than most people edit their
# panel settings anyway, so a live data source would have been machinery in
# service of nothing.

# Basketball orange for the app's own chrome, so the strip and the ball read as
# one object. The rim is a redder orange than the ball and the seams a browner
# one: three shades of the same hue keep the sprite reading as a single object
# while still separating ball from rim. White is the resting color of a live
# number, which leaves amber free to mean "something needs attention".
ORANGE = "#E2570F"
BALL = "#FF7A1A"
RIM = "#D93C0B"
SEAM = "#8A2F06"
NET = "#AEBBD4"
INK = "#F4F7FF"
DIM = "#7C8AA5"
WARN = "#FFAA3C"

# 13x14: the ball on its way down, an open rim, the net below. The rim tapers
# over two rows rather than sitting flat -- a flat bar under a round ball reads
# as a cocktail glass, and the taper is what turns it back into a hoop seen
# from slightly above. Proportions are the real ones: a 9.5" ball through an
# 18" rim is almost exactly 7 px of 13, which is most of why it reads at all.
HOOP_ART = """
.....OSO.....
....OOSOO....
...OOOSOOO...
...SSOSOSS...
...OOOSOOO...
....OOSOO....
.....OSO.....
.............
.RRRRRRRRRRR.
..RRRRRRRRR..
..N.N.N.N.N..
...NNNNNNN...
....N.N.N....
.....NNN.....
"""
HOOP_W = 13
HOOP_H = 14
HOOP_LEGEND = {"O": BALL, "S": SEAM, "R": RIM, "N": NET}

# Vertical bands. The strip owns y 0-6, the hero band y 8-23, the name row
# y 25-31 -- every row of the panel is spoken for, with a 1 px gutter between.
STRIP_H = 7
HERO_Y = 8
HERO_H = 16
NAME_Y = 25

FONT_H = {"10x16": 16, "8x12": 12, "6x9": 9, "5x7": 7, "4x5": 5, "picopixel": 5}

DIGITS = "0123456789"

# Both settings ship blank, so this is what the catalog card renders -- the
# layout doing its job rather than an empty panel telling a stranger to fill in
# a form they cannot see yet.
DEMO_NAME = "ALEX"
DEMO_SCORE = 118


# ---- text ------------------------------------------------------------------

def _pick_font(c, s, w, fonts):
    """Biggest font in the ladder whose rendering of `s` fits `w`."""
    for f in fonts:
        if c.text_width(s, font = f) <= w:
            return f
    return fonts[len(fonts) - 1]


def _fit(c, s, x, y, w, fonts, color, align = "left"):
    """Biggest font that fits, then hard-clipped. Nothing in the drawing API
    clips, so a string that overflows even the smallest face would silently run
    off the canvas; this trims it instead."""
    pick = _pick_font(c, s, w, fonts)
    t = s
    for _ in range(len(s)):
        if c.text_width(t, font = pick) <= w:
            break
        t = t[:len(t) - 1]
    c.text(t, x, y, font = pick, color = color, align = align)
    return pick


def _int(s):
    """A whole number, or None. Starlark has no exceptions, so int() cannot be
    used speculatively -- every character is checked first. A number-typed
    setting can arrive as 84.0, so a decimal tail is truncated, not rejected."""
    t = str(s).strip().replace(",", "")
    if "." in t:
        t = t.split(".")[0]
    neg = t.startswith("-")
    if neg:
        t = t[1:]
    if t == "":
        return None
    for i in range(len(t)):
        if t[i] not in DIGITS:
            return None
    v = int(t)
    if neg:
        return -v
    return v


# ---- drawing ---------------------------------------------------------------

def _strip(c, label, bg, tag = None):
    """The title bar. Black text on a filled strip, so no stroke is needed. A
    tag is right-aligned and the title takes what is left, measured -- centering
    the title would run it straight through the tag."""
    c.rect(0, 0, c.width - 1, STRIP_H - 1, fill = bg)
    if tag == None:
        _fit(c, label, c.width // 2, 1, c.width - 2,
             ["4x5", "picopixel"], "black", align = "center")
    else:
        tw = c.text_width(tag, font = "picopixel")
        c.text(tag, c.width - 1, 1, font = "picopixel", color = "black",
               align = "right")
        _fit(c, label, 1, 1, c.width - 4 - tw,
             ["4x5", "picopixel"], "black", align = "left")


def _board(c, label, name, score, demo = False):
    c.fill("black")
    # A demo is dressed as a demo -- gray chrome and a tag -- so nobody reads
    # ALEX's 118 off the catalog card as somebody's real record. The tag sits
    # on the name row, not in the strip: "ARCADE HOOPS" beside a strip tag
    # measured 59px into 45px of room and lost its S, and a title clipped to
    # ARCADE HOOP is worse than no tag at all. Down here it is safe because the
    # demo name is ours -- "ALEX" is 23px centered, ending at x 43, and the tag
    # starts at 48.
    _strip(c, label, DIM if demo else ORANGE)

    # Hoop and score are one centered group, so a two-digit night and a
    # four-digit night are both balanced instead of drifting left.
    s = str(score)
    avail = c.width - 4 - HOOP_W - 3
    font = _pick_font(c, s, avail, ["10x16", "8x12", "6x9"])
    sw = c.text_width(s, font = font)
    x0 = (c.width - (HOOP_W + 3 + sw)) // 2
    if x0 < 1:
        x0 = 1

    c.sprite(HOOP_ART, x0, HERO_Y + (HERO_H - HOOP_H) // 2,
             legend = HOOP_LEGEND)
    c.text(s, x0 + HOOP_W + 3, HERO_Y + (HERO_H - FONT_H[font]) // 2,
           font = font, color = INK)

    _fit(c, name, c.width // 2, NAME_Y, c.width - 2,
         ["5x7", "4x5", "picopixel"], ORANGE if demo else INK, align = "center")
    if demo:
        c.text("DEMO", c.width - 1, NAME_Y + 1, font = "picopixel",
               color = DIM, align = "right")


def _message(c, label, bg, head, sub):
    """Two short lines: what is missing, and what to do about it. A panel on a
    wall never shows a stack trace -- or a blank."""
    c.fill("black")
    _strip(c, label, bg)
    _fit(c, head, c.width // 2, 10, c.width - 2, ["5x7", "4x5"], INK,
         align = "center")
    c.text_wrapped(sub, c.width // 2, 19, c.width - 2, font = "4x5",
                   color = DIM, line_gap = 2, align = "center",
                   max_lines = 2)


# ---- page ------------------------------------------------------------------

def champ(c, ctx):
    label = str(ctx.inputs.get("label", "ARCADE HOOPS")).strip().upper()
    if label == "":
        label = "ARCADE HOOPS"

    name = str(ctx.inputs.get("name", "")).strip().upper()
    score = _int(ctx.inputs.get("score", ""))

    # Nothing filled in yet: show the app working, clearly labelled, rather
    # than a form. Half filled in is a different thing -- somebody is mid-setup
    # and needs telling which half is missing.
    if score == None and name == "":
        _board(c, label, DEMO_NAME, DEMO_SCORE, demo = True)
    elif score == None:
        _message(c, label, WARN, "NO SCORE", "ADD THE HIGH SCORE")
    elif name == "":
        _message(c, label, WARN, "NO NAME", "ADD THE CHAMP")
    else:
        _board(c, label, name, score)
