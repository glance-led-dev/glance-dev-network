# Now Serving — a GDN Starlark app (192x32, 1 page).
#
# DESIGN. The logos are the app. A tiny "NOW SERVING" header sits on top and up
# to three logos, picked from dropdowns, fill the band below it. One logo centers;
# more spread out with equal gaps, including the gaps at the safe-zone edges.
#
# The logos are blended down from the brands' artwork rather than cut to on/off
# pixels: at 26 px the in-between brightness is what keeps script and fine lines
# readable. They are opaque on black, so they hold no semi-transparent pixels.

SAFE_LEFT = 6
SAFE_WIDTH = 180    # x 6-185, so the app never merges with its scroll neighbors
LOGO_TOP = 6        # header is picopixel at y 0-4, leaving 1 px clear above the logos
LOGO_HEIGHT = 26    # y 6-31

# name -> {size: (file, w, h[, (caption, color, dy)])}. "84" is the 1-2 logo slot,
# "54" the 3-logo slot. Widest three in the 3-logo slot are 61+57+57 = 175 of 180,
# which still leaves 1 px gaps.
# Old Forester is hand-drawn pixel lettering. The rest are blended from the
# artwork with firmed edges; Bulleit keeps its arch. BOURBON lines, taglines and
# (R) marks are dropped: unreadable at this size. Bulleit runs 88 wide; with an 84
# partner that leaves 2 px gaps. Maker's Mark redraws its seal ring as a crisp 1 px
# circle. Black lettering is turned white on the black panel.
# A caption is text the app draws in 4x5 at dy below the logo's top, for lines the
# artwork can't carry: Various Wines' name (its lettering turned to mush and
# picopixel read as "PARIOUS HINES"), Baker's High Rye, and Taylor's "Colonel E.H.".
WINES_CAPTION = ("VARIOUS WINES", "white", 21)
LOGOS = {
    "Baker's": {84: ("bakers81.png", 81, 25, ("HIGH RYE", "#3CC47C", 20)), 54: ("bakers57.png", 57, 20, ("HIGH RYE", "#3CC47C", 15))},
    "Bardstown": {84: ("bardstown72.png", 72, 26), 54: ("bardstown57.png", 57, 26)},
    "Blanton's": {84: ("blantons84.png", 84, 23), 54: ("blantons56.png", 56, 15)},
    "Bud Light": {84: ("budlight46.png", 46, 26), 54: ("budlight46.png", 46, 26)},
    "Bulleit": {84: ("bulleit88.png", 88, 19), 54: ("bulleit57.png", 57, 13)},
    "E.H. Taylor": {84: ("ehtaylor84.png", 84, 25, ("COLONEL E.H.", "white", 0)), 54: ("ehtaylor57.png", 57, 19, ("COLONEL E.H.", "white", 0))},
    "Elijah Craig": {84: ("elijahcraig36.png", 36, 26), 54: ("elijahcraig36.png", 36, 26)},
    "Four Roses": {84: ("fourroses57.png", 57, 26), 54: ("fourroses57.png", 57, 26)},
    "Heaven Hill": {84: ("heavenhill44.png", 44, 26), 54: ("heavenhill44.png", 44, 26)},
    "Jose Cuervo": {84: ("josecuervo84.png", 84, 21), 54: ("josecuervo57.png", 57, 14)},
    "Knob Creek": {84: ("knobcreek46.png", 46, 26), 54: ("knobcreek46.png", 46, 26)},
    "Maker's Mark": {84: ("makersmark62.png", 62, 26), 54: ("makersmark54.png", 54, 23)},
    "Michter's": {84: ("michters29.png", 29, 26), 54: ("michters29.png", 29, 26)},
    "Old Forester": {84: ("oldforester83.png", 83, 26), 54: ("oldforester54.png", 54, 20)},
    "Red Bull": {84: ("redbull52.png", 52, 26), 54: ("redbull52.png", 52, 26)},
    "Rhinegeist": {84: ("rhinegeist26.png", 26, 26), 54: ("rhinegeist26.png", 26, 26)},
    "Smirnoff": {84: ("smirnoff84.png", 84, 25), 54: ("smirnoff57.png", 57, 17)},
    "Stagg Jr": {84: ("staggjr64.png", 64, 26), 54: ("staggjr55.png", 55, 21)},
    "Truly": {84: ("truly84.png", 84, 26), 54: ("truly57.png", 57, 17)},
    "Various Wines": {84: ("wines61.png", 61, 26, WINES_CAPTION), 54: ("wines61.png", 61, 26, WINES_CAPTION)},
    "Weller": {84: ("weller67.png", 67, 26), 54: ("weller54.png", 54, 21)},
    "White Claw": {84: ("whiteclaw57.png", 57, 26), 54: ("whiteclaw57.png", 57, 26)},
}

def picks(ctx):
    """Chosen logos in dropdown order, skipping None and repeats."""
    out = []
    for name in [
        ctx.inputs.get("logo1", "None"),
        ctx.inputs.get("logo2", "None"),
        ctx.inputs.get("logo3", "None"),
    ]:
        if name in LOGOS and name not in out:
            out.append(name)
    return out

def serving(c, ctx):
    c.fill("black")
    c.text("NOW SERVING", c.width // 2, 0, font = "picopixel", color = "white", align = "center")

    names = picks(ctx)
    if not names:
        c.text("PICK A BOTTLE", c.width // 2, 15, font = "5x7", color = "gray", align = "center")
        return

    size = 54 if len(names) == 3 else 84
    logos = [LOGOS[name][size] for name in names]
    total = 0
    for logo in logos:
        total += logo[1]
    gap = (SAFE_WIDTH - total) // (len(logos) + 1)
    x = SAFE_LEFT + (SAFE_WIDTH - total - gap * (len(logos) - 1)) // 2
    for logo in logos:
        y = LOGO_TOP + (LOGO_HEIGHT - logo[2]) // 2
        c.image(logo[0], x, y)
        if len(logo) > 3:
            cap = logo[3]
            c.text(cap[0], x + logo[1] // 2, y + cap[2], font = "4x5", color = cap[1], align = "center")
        x += logo[1] + gap
