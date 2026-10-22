FONT_HEIGHT = {"10x16": 16, "7x12": 12, "6x8": 8, "5x7": 7}

def fit_font(c, text, options, maxw):
    for font in options:
        if c.text_width(text, font) <= maxw:
            return font
    return options[len(options) - 1]

def sign(c, ctx):
    msg = "GO BEARS!"

    c.fill("#0B162A")

    c.image("bears_primary.png", 3, 1, w=30, h=30)
    c.image("bears_vintage_football.png",
            c.width - 33, 1, w=30, h=30)

    tx = 36
    tw = c.width - 2 * tx
    cx = tx + tw // 2

    fonts = ["10x16", "7x12", "6x8", "5x7"]
    font = fit_font(c, msg, fonts, tw - 1)
    ty = (c.height - FONT_HEIGHT[font]) // 2

    c.text(msg, cx + 1, ty + 1,
           font=font, color="black", align="center")
    c.text(msg, cx, ty,
           font=font, color="#C83803", align="center")