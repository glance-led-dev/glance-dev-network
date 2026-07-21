# Stock Ticker - price + daily change for a symbol. (128x32)
#
# Live quotes from Twelve Data. One symbol per render, so one credit per
# fetch: at refresh 300 that is ~288 of the free tier's 800 a day.

UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1]]
DOWN = [[1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def money(v):
    # Cents below $1000, whole dollars above it -- otherwise a four-digit
    # price plus cents is too wide for the panel.
    if v >= 1000.0:
        return "$" + str(int(v + 0.5))
    cents = int(v * 100 + 0.5)
    return "$" + str(cents // 100) + "." + pad2(cents % 100)

def signed_money(v):
    # The dollar move, always signed: +$3.21 / -$12.05
    sign = "+" if v >= 0 else "-"
    a = v if v >= 0 else -v
    cents = int(a * 100 + 0.5)
    return sign + "$" + str(cents // 100) + "." + pad2(cents % 100)

def pct(p):
    sign = "+" if p >= 0 else "-"
    a = p if p >= 0 else -p
    t = int(a * 10 + 0.5)
    return sign + str(t // 10) + "." + str(t % 10) + "%"

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

# ---------- the fetch ----------
# Returns {"ok": True, "sym":..., "price":..., "chg":..., "amt":...}
# or        {"ok": False, "title":..., "sub":...}

def fetch(ctx):
    key = _s(ctx, "apikey", "")
    sym = _s(ctx, "symbol", "").upper()

    if not key:
        return {"ok": False, "title": "NO API KEY", "sub": "ADD ONE IN SETTINGS"}
    if not sym:
        return {"ok": False, "title": "NO SYMBOL", "sub": "ADD ONE IN SETTINGS"}

    # http.get returns a DICT: {"status_code":..., "body":..., "json":...}
    r = http.get(
        "https://api.twelvedata.com/quote",
        params = {"symbol": sym, "apikey": key},
        ttl_seconds = 300,
    )

    # ALWAYS check status_code before touching the json
    status = r["status_code"]
    if status == 401 or status == 403:
        return {"ok": False, "title": "BAD API KEY", "sub": "CHECK YOUR SETTINGS"}
    if status == 429:
        return {"ok": False, "title": "RATE LIMITED", "sub": "TRY AGAIN LATER"}
    if status != 200:
        return {"ok": False, "title": "API ERROR", "sub": "CODE " + str(status)}

    q = r["json"]
    if not q:
        return {"ok": False, "title": "NO DATA", "sub": "EMPTY RESPONSE"}

    # Twelve Data reports its own errors inside a 200 response, so check here too.
    # An unknown ticker comes back this way rather than as a 404.
    if q.get("status", "") == "error":
        return {"ok": False, "title": "BAD SYMBOL", "sub": sym + " NOT FOUND"}

    price = q.get("close", None)
    change = q.get("percent_change", None)
    if price == None or change == None:
        return {"ok": False, "title": "NO QUOTE", "sub": "NO PRICE FOR " + sym}

    # The dollar move. If the feed omits it, derive it from the percent.
    amt = q.get("change", None)
    if amt == None:
        amt = float(price) * float(change) / 100.0
    else:
        amt = float(amt)

    return {
        "ok": True,
        "sym": str(q.get("symbol", sym)).upper(),
        "price": float(price),
        "chg": float(change),
        "amt": amt,
    }

# ---------- page ----------

def price(c, ctx):
    d = fetch(ctx)

    c.fill("black")

    if not d["ok"]:
        c.rect(0, 0, c.width - 1, 8, fill = "darkgray")
        c.text("STOCKS", c.width // 2, 1, font = "5x7", color = "white", align = "center")
        c.text(d["title"], 4, 12, font = "6x8", color = "orange")
        c.text(d["sub"], 4, 23, font = "4x5", color = "gray")
        return

    up = d["chg"] >= 0
    col = "green" if up else "red"

    c.rect(0, 0, c.width - 1, 8, fill = "darkgray")
    c.text(d["sym"], c.width // 2, 1, font = "5x7", color = "white", align = "center")

    # Percent on top, dollar change under it, both right-aligned.
    ps = pct(d["chg"])
    cs = signed_money(d["amt"])

    c.text(ps, c.width - 2, 11, font = "5x7", color = col, align = "right")
    c.text(cs, c.width - 2, 21, font = "5x7", color = col, align = "right")

    # The arrow belongs to the percent line, so it anchors off that string only.
    # It sits at rows 12-16, well above the dollar line at row 21, so a wider
    # dollar string can never reach it.
    arrow_x = c.width - 2 - c.text_width(ps, "5x7") - 8
    c.bitmap(UP if up else DOWN, arrow_x, 12, col)

    # The price gets everything left of the arrow, but must also clear the
    # dollar line below it -- whichever of the two is further left wins.
    dollar_left = c.width - 2 - c.text_width(cs, "5x7")
    avail = arrow_x - 6
    if dollar_left - 6 < avail:
        avail = dollar_left - 6

    ms = money(d["price"])
    c.text(ms, 4, 11, font = fit_font(c, ms, ["16x20", "10x16", "7x12"], avail), color = "white")