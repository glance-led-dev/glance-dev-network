# hello-jay: a new Glance app. Edit me!

def main(c, ctx):
    c.fill("black")
    c.text_center("HELLO-JAY", 2, font="6x8", color="green")
    msg = ctx.inputs.get("setting_1", "")
    if msg:
        c.text_center(str(msg).upper(), 16, font="5x7", color="white")
    
    c.image("glance_mktg_black.png", 2, 11, w = 26, h = 16)
   
