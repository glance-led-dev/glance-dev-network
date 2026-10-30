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

# name -> {size: (file, w, h)}. 84 is used with 1-2 logos, 54 with 3.
# Widest three at 54 are 61+57+55 = 173 of 180, which still leaves 1 px gaps.
# Various Wines is 20 px of bottles with its name drawn below them, because the
# artwork's lettering turned to mush and picopixel read as "PARIOUS HINES".
LOGOS = {
    "Blanton's": {84: ("blantons84.png", 84, 24), 54: ("blantons54.png", 54, 15)},
    "Bud Light": {84: ("budlight46.png", 46, 26), 54: ("budlight46.png", 46, 26)},
    "Bulleit": {84: ("bulleit74.png", 74, 26), 54: ("bulleit54.png", 54, 19)},
    "Elijah Craig": {84: ("elijahcraig34.png", 34, 26), 54: ("elijahcraig34.png", 34, 26)},
    "Four Roses": {84: ("fourroses82.png", 82, 26), 54: ("fourroses54.png", 54, 26)},
    "Maker's Mark": {84: ("makersmark61.png", 61, 26), 54: ("makersmark54.png", 54, 23)},
    "Old Forester": {84: ("oldforester81.png", 81, 26), 54: ("oldforester54.png", 54, 17)},
    "Rhinegeist": {84: ("rhinegeist26.png", 26, 26), 54: ("rhinegeist26.png", 26, 26)},
    "Stagg Jr": {84: ("staggjr64.png", 64, 26), 54: ("staggjr55.png", 55, 21)},
    "Various Wines": {84: ("wines61.png", 61, 26), 54: ("wines61.png", 61, 26)},
    "Weller": {84: ("weller66.png", 66, 26), 54: ("weller54.png", 54, 21)},
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
        if logo[0] == "wines61.png":
            c.text("VARIOUS WINES", x + logo[1] // 2, y + 21, font = "4x5", color = "white", align = "center")
        x += logo[1] + gap
