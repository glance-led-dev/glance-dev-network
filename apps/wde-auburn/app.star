# War Eagle - an Auburn spirit card. (192x32)
#
#   [AU.png]        WAR DAMN EAGLE        [TIGER.png]
#                    GO! GO! GO!
#
# Static: no inputs, nothing fetched, so `refresh` is hourly only because the
# panel has to ask for something.
#
# The two marks are PNG assets rather than inline sprites, so they can be
# replaced by dropping new files into assets/ without touching this code.
# Both are 30x30 and drawn at 30x30 -- the size they were authored, per the
# design guidelines, rather than scaled from one file.
#
# They are declared in the manifest under `assets:` and drawn by LITERAL
# filename. That matters: the validator only cross-checks assets it can see
# as string literals, so a computed name would silently forfeit both the
# "declared but never drawn" and "drawn but not declared" checks -- and a
# missing asset is a hard render failure, not a blank shape.
#
# Both lines use text_stroke with a WHITE stroke, which is load-bearing
# rather than decorative. Auburn navy is #0C2341 -- luminance 31 against a
# near-black ground of 9 -- so the lower line would be close to invisible
# painted flat. The stroke gives every glyph an edge the panel can resolve,
# and the same treatment on the orange line keeps the two matched.

INK = "#08090D"          # near-black ground, per the contrast rule
ORANGE = "#E86100"       # upper line
NAVY = "#0C2341"         # lower line
STROKE = "#FFFFFF"       # the outline that makes both legible

PAD = 3
ART = 30                 # both assets are 30x30
GAP = 2

TOP = "WAR DAMN EAGLE"
BOTTOM = "GO! GO! GO!"

# One font for both lines, the largest that fits the LONGER of the two. Sized
# per line instead, the two would land on different faces, and a chant whose
# second line has visibly chunkier letters reads as a mistake, not emphasis.
LINE_FONTS = ["9x12", "8x12", "8x10", "6x9", "6x8", "5x7"]
FONT_H = {"9x12": 12, "8x12": 12, "8x10": 10, "6x9": 9, "6x8": 8, "5x7": 7}


def pick_font(c, avail):
    """Largest listed font that fits both lines AND can draw every character.

    The glyph check is not paranoia. 7x12 fits both lines comfortably, but it
    carries only 44 glyphs and has no "!", and this renderer draws a missing
    glyph as NOTHING rather than as a box: the panel showed "GO GO GO" with
    no warning from check, validate or the render. A zero-width "!" is the
    tell, so the ladder skips any face that cannot measure one.
    """
    for f in LINE_FONTS:
        if c.text_width("!", f) <= 0:
            continue
        if c.text_width(TOP, f) <= avail and c.text_width(BOTTOM, f) <= avail:
            return f
    return LINE_FONTS[len(LINE_FONTS) - 1]


def wde(c, ctx):
    c.fill(INK)

    # Art first, at the outer edges; the text is centred in what is left.
    c.image("AU.png", PAD, 1, w = ART, h = ART)
    c.image("TIGER.png", c.width - PAD - ART, 1, w = ART, h = ART)

    left = PAD + ART + GAP
    right = c.width - PAD - ART - GAP
    mid = (left + right) // 2
    font = pick_font(c, right - left)

    # Centre the pair of lines in the panel rather than pinning them: the
    # chosen face is not known until runtime, so the stack has to measure.
    h = FONT_H.get(font, 10)
    lead = 6
    y = (c.height - (2 * h + lead)) // 2
    c.text_stroke(TOP, mid, y, font = font, color = ORANGE,
                  stroke = STROKE, align = "center")
    c.text_stroke(BOTTOM, mid, y + h + lead, font = font, color = NAVY,
                  stroke = STROKE, align = "center")
