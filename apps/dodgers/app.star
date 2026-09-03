# Dodgers: a new Glance app. Edit me!

def main(c, ctx):
    c.fill("black")
    c.text_center("LETS GO", 6, font="6x8", color="WHITE")
    c.text_center("DODGERS", 16, font="6x8", color="WHITE")
    msg = ctx.inputs.get("setting1", "")
    if msg:
        c.text_center(str(msg).upper(), 16, font="5x7", color="white")
    c.image("1.png", 10
, 1)
    
    
    c.image("1.png", 96, 1)
