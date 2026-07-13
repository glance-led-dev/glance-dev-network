# Stock Ticker — price + daily change for a symbol. (128x32)
# Mock data derived from the symbol; swap `quote_of` for a real feed later.

UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1]]
DOWN = [[1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]

def quote_of(sym):
    seed = 0
    for i in range(len(sym)):
        seed = seed + ord(sym[i])
    price = 20 + seed % 480          # $20-$500
    chg = (seed * 7) % 199 - 99      # -9.9% .. +9.9% (tenths)
    return price, chg

def price(c, ctx):
    sym = ctx.inputs.get("symbol", "AAPL").upper()
    pr, chg = quote_of(sym)
    up = chg >= 0
    col = "green" if up else "red"

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "darkgray")
    c.text(sym, c.width // 2, 1, font = "5x7", color = "white", align = "center")

    c.text("$" + str(pr), 4, 11, font = "16x20", color = "white")

    a = chg if up else -chg
    pct = ("+" if up else "-") + str(a // 10) + "." + str(a % 10) + "%"
    c.bitmap(UP if up else DOWN, c.width - 8, 12, col)
    c.text(pct, c.width - 12, 13, font = "6x8", color = col, align = "right")
