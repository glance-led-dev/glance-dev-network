def a(c, ctx):
    c.image("frame1.png", 48, 0, w=64, h=32)

def b(c, ctx):
    c.image("frame1.png", 32, 0, w=64, h=32)

def c1(c, ctx):
    c.image("frame1.png", 16, 0, w=64, h=32)

def d(c, ctx):
    c.image("frame1.png", 0, 0, w=64, h=32)

def e(c, ctx):
    c.image("frame1.png", -16, 0, w=64, h=32)

def f(c, ctx):
    c.image("frame1.png", -32, 0, w=64, h=32)

def g(c, ctx):
    c.image("frame1.png", -48, 0, w=64, h=32)
