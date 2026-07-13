# Go Gators, a message sign with a bundled logo. (192x32)
#
# This app does the two things almost every app does: draw a PICTURE (a PNG you
# bundle with the app) and draw TEXT. Read it top to bottom to see how each part
# works.

# fit_font picks the biggest font from `options` whose rendered text still fits
# inside `maxw` pixels, so a long message shrinks instead of running off the edge.
def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]   # nothing fit, use the smallest


def sign(c, ctx):
    # 1. Read the user's settings. These come from manifest.yaml, and the
    #    second argument is the fallback if it's blank. Bitmap fonts are
    #    UPPERCASE only, so .upper() everything or it won't draw.
    l1 = ctx.inputs.get("line1", "GO").upper()
    l2 = ctx.inputs.get("line2", "GATORS").upper()
    col1 = ctx.inputs.get("color1", "orange")   # Florida orange for line 1
    col2 = ctx.inputs.get("color2", "blue")     # Florida blue for line 2

    # 2. Start from a blank (black) panel.
    c.fill("black")

    # 3. Draw the logo on the left. gator.png sits in this app's assets/ folder
    #    and is listed under `assets:` in manifest.yaml. c.image pastes it and
    #    w/h scale it to 47x30. The (x, y) you pass is the image's TOP-LEFT
    #    corner, so this lands 2px in and 1px down.

    # 4. The message goes to the right of the logo. Work out the space that's
    #    left, and its horizontal center, so the text stays centered there.
    tx = 54                   # text starts just past the logo
    tw = c.width - tx - 4     # pixels of width left for the text
    cx = tx + tw // 2         # center of the text area

    if l2:
        # Two lines: pick a font that fits the width, then stack them.
        fonts = ["10x16", "7x12", "6x8", "5x7"]
        c.text(l1, cx, 1, font = fit_font(c, l1, fonts, tw), color = col1,  align = "center")
        c.text(l2, cx, 16, font = fit_font(c, l2, fonts, tw), color = col2,  align = "center")
    else:
        # One line: go as big as fits.
        big = ["16x20", "10x16", "7x12", "6x8"]
        c.text(l1, cx, 6, font = fit_font(c, l1, big, tw), color = col1, align = "center")
    c.image("gator.png", 8, -1, w = 40, h = 32)

