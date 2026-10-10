# Chicago Cubs Win Flag: the W flag flying, with or without Cubs C logos.
IMAGES = {
    "Flags only": "flags.png",
    "Flags and C logos": "flags_and_logos.png",
}

def main(c, ctx):
    style = ctx.inputs.get("style", "Flags and C logos")
    c.fill("black")
    c.image(IMAGES.get(style, "flags_and_logos.png"), 0, 0, w=384, h=32)
