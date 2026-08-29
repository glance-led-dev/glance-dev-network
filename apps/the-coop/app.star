# The Coop -- a static welcome card: logo on the left, greeting on the right.
# Glance panels only ever show still frames (refreshed on a timer), so this
# is deliberately not an animation -- see gifs/the-coop/ in the repo root for
# an animated version, which only works where GIF playback is supported.

LOGO_H = 20
LOGO_W = 36
LOGO_X = 4
LOGO_Y = 6

TEAL = "#2CBABE"

def main(c, ctx):
    c.fill("black")
    msg = "WELCOME TO THE COOP"
    tw = c.text_width(msg, "5x7b")
    # Logo and message measured as one group - a 10px gap between them -
    # and the whole thing centred on the panel.
    gx = max(0, (c.width - (LOGO_W + 10 + tw)) // 2)
    c.image("logo.png", gx, LOGO_Y, w = LOGO_W, h = LOGO_H)
    y = (c.height - 7) // 2
    c.text(msg, gx + LOGO_W + 10, y, font = "5x7b", color = TEAL)
