# Red Tail Land Co. - logo for Glance SCROLL (192x32).
# REDTAIL.png is the RED TAIL wordmark with the red feather, made from the
# company logo at panel size. LAND CO. is set in red below it, letter-spaced
# like the printed logo.

RED = "#E65028"
LOGO_W = 95
LOGO_H = 23

def spaced(c, s, y, font, color, gap):
    # draw text with extra tracking, centered
    w = 0
    for ch in s.elems():
        w += c.text_width(ch, font=font) + gap
    w -= gap
    x = (c.width - w) // 2
    for ch in s.elems():
        c.text(ch, x, y, font=font, color=color)
        x += c.text_width(ch, font=font) + gap

def logo(c, ctx):
    c.clear()
    c.image("REDTAIL.png", (c.width - LOGO_W) // 2, 0)
    spaced(c, "LAND CO.", LOGO_H + 2, "5x7", RED, 3)
