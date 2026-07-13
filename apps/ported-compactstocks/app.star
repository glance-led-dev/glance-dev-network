# Ported from the tidbyt/community "Compact Stocks" app (apps/compactstocks/stocks.star).
#
# ORIGINAL Pixlet: fetches 5 tickers from apistocks (RapidAPI) and lays each out
# as a render.Row of three Columns — symbol (colored) | price | daily % (green
# up / red down) — inside a centered render.Column. Without an API key it renders
# built-in EXAMPLE rows.
#
# `gdn translate` flagged http.* + the schema (api_key + 5x symbol/color) and the
# Row/Column/Text widgets. Hand-finished for GDN (static 64x32): no network, so
# these are offline sample rows (like the app's own example mode). The tabular
# layout and the price/percent FORMATTERS port verbatim; three Columns in a
# space-between Row became three aligned c.text() calls (left / center / right).

# Offline sample rows: (symbol, symbol_color, price, daily_percent).
ROWS = [
    ("AAPL", "cyan", 229.87, 1.4),
    ("MSFT", "cyan", 419.33, -0.6),
    ("NVDA", "yellow", 123.45, 3.2),
    ("TSLA", "magenta", 251.10, -2.1),
    ("AMZN", "orange", 186.40, 0.8),
]

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def money(v):
    cents = int(v * 100 + 0.5)
    return str(cents // 100) + "." + pad2(cents % 100)

def pct(p):
    sign = "+" if p >= 0 else "-"
    a = p if p >= 0 else -p
    t = int(a * 10 + 0.5)
    return sign + str(t // 10) + "." + str(t % 10) + "%"

def main(c, ctx):
    # picopixel is the narrowest bundled font — three columns of digits fit 64px.
    F = "picopixel"
    c.fill("black")
    y = 1
    for i in range(len(ROWS)):
        sym, col, price, change = ROWS[i]
        pc = "green" if change >= 0 else "red"
        ps = pct(change)
        ms = money(price)
        # right-anchor % at the far right, then right-anchor price just left of it,
        # so the three columns never collide regardless of string length.
        c.text(ps, c.width - 1, y, font = F, color = pc, align = "right")
        price_right = c.width - 2 - c.text_width(ps, F) - 2
        c.text(ms, price_right, y, font = F, color = "white", align = "right")
        c.text(sym, 0, y, font = F, color = col)
        y += 6
