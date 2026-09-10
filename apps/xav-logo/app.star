# Xav logo: a new Glance app. Edit me!

def main(c, ctx):
    c.fill("black")
    c.text_center("XAV LOGO", 2, font="6x8", color="green")
    msg = ctx.inputs.get("setting1", "")
    if msg:
        c.text_center(str(msg).upper(), 16, font="5x7", color="white")
    c.image("runnignman.png", 1, 0, w = 62, h = 32)
