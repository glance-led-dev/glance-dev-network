# Wifey: a new Glance app. Edit me!

def main(c, ctx):
    c.fill("black")
    c.text_center("HI CINDY", 2, font="6x8", color="Blue")
    c.icon("heart", 7, 16, color="red", scale=2)   # icon name, x, y, color, scale
    c.icon("heart", 25, 16, color="red", scale=2)   # icon name, x, y, color, scale
    c.icon("heart", 43, 16, color="red", scale=2)   # icon name, x, y, color, scale
    msg = ctx.inputs.get("setting1", "")
    if msg:
        c.text_center(str(msg).upper(), 12, font="5x7", color="white")
