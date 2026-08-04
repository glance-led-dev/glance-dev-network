# GO OILERS: a new Glance app. Edit me!

def main(c, ctx):
    setting2 = ctx.inputs.get("setting2", "")
    c.fill("black")
    c.text_center("GO OILERS", 2, font="6x8", color="amber")
    msg = ctx.inputs.get("setting1", "")
    if msg:
        c.text_center(str(msg).upper(), 16, font="5x7", color="amber")
    c.image("tulsa_oilers_ifl_logo.png", 6, 0)
    c.image("tulsa_oilers_ifl_logo-2.png", 134, 0)
