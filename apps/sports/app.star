# Score — two-team game score. (128x32) Mock data derived from the matchup.

def game(home, away):
    both = home + away
    seed = 0
    for i in range(len(both)):
        seed = seed + ord(both[i])
    hs = 78 + seed % 45
    as_ = 78 + (seed * 3) % 45
    q = 1 + seed % 4
    return hs, as_, q

def score(c, ctx):
    home = ctx.inputs.get("home", "LAL").upper()
    away = ctx.inputs.get("away", "BOS").upper()
    hs, as_, q = game(home, away)

    c.fill("black")
    c.text(home, 3, 1, font = "6x8", color = "yellow")
    c.text(str(hs), 3, 12, font = "10x16", color = "white")

    c.text(away, c.width - 3, 1, font = "6x8", color = "cyan", align = "right")
    c.text(str(as_), c.width - 3, 12, font = "10x16", color = "white", align = "right")

    label = "FINAL" if q > 3 else "Q" + str(q)
    c.text(label, c.width // 2, 6, font = "5x7", color = "gray", align = "center")
    c.text("-", c.width // 2, 16, font = "6x8", color = "gray", align = "center")
