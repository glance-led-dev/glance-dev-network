# Ported from the tidbyt/community "Compact Stocks" app (apps/compactstocks/stocks.star).
#
# ORIGINAL Pixlet: fetches 5 tickers from apistocks (RapidAPI) and lays each out
# as a render.Row of three Columns — symbol (colored) | price | daily % (green
# up / red down) — inside a centered render.Column. Without an API key it renders
# built-in EXAMPLE rows.
#
# `gdn translate` flagged http.* + the schema (api_key + 5x symbol/color) and the
# Row/Column/Text widgets. Hand-finished for GDN (static 64x32). The tabular
# layout and the price/percent FORMATTERS port verbatim; three Columns in a
# space-between Row became three aligned c.text() calls (left / center / right).
# The RapidAPI feed was swapped for Twelve Data, whose /quote endpoint takes all
# five symbols in a single request.

MAX_ROWS = 5

# Symbol colors, cycled in order. The original app let you pick one per ticker;
# on a 64px panel the color is just there to separate the rows visually.
PALETTE = ["cyan", "cyan", "yellow", "magenta", "orange"]

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

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _symbols(raw):
    out = []
    for part in raw.split(","):
        s = part.strip().upper()
        if s and len(out) < MAX_ROWS:
            out.append(s)
    return out

# ---------- the fetch ----------
# Returns {"ok": True, "rows": [[sym, price, change], ...]}
# or        {"ok": False, "title": ..., "sub": ...}

def fetch(ctx):
    key = _s(ctx, "apikey", "")
    syms = _symbols(_s(ctx, "symbols", ""))

    if not key:
        return {"ok": False, "title": "NO API KEY", "sub": "ADD IN SETTINGS"}
    if not syms:
        return {"ok": False, "title": "NO SYMBOLS", "sub": "ADD IN SETTINGS"}

    # http.get returns a DICT: {"status_code":..., "body":..., "json":...}
    r = http.get(
        "https://api.twelvedata.com/quote",
        params = {"symbol": ",".join(syms), "apikey": key},
        # Free tier is 800 calls a day. One call every 15 min is ~96.
        ttl_seconds = 900,
    )

    # ALWAYS check status_code before touching the json
    status = r["status_code"]
    if status == 401 or status == 403:
        return {"ok": False, "title": "BAD API KEY", "sub": "CHECK SETTINGS"}
    if status == 429:
        return {"ok": False, "title": "RATE LIMITED", "sub": "TRY LATER"}
    if status != 200:
        return {"ok": False, "title": "API ERROR", "sub": "CODE " + str(status)}

    body = r["json"]
    if not body:
        return {"ok": False, "title": "NO DATA", "sub": "EMPTY RESPONSE"}

    # Twelve Data reports its own errors inside a 200 response, so check here too.
    if body.get("status", "") == "error":
        return {"ok": False, "title": "API ERROR", "sub": "CHECK KEY / PLAN"}

    # One symbol comes back as a bare object; several come back keyed by symbol.
    # Normalize both into a dict so the loop below only has one shape to handle.
    if "symbol" in body:
        quotes = {str(body["symbol"]).upper(): body}
    else:
        quotes = body

    rows = []
    for sym in syms:
        q = quotes.get(sym, None)
        if q == None:
            continue
        # A bad ticker fails individually while the others still succeed.
        if q.get("status", "") == "error":
            continue

        price = q.get("close", None)
        change = q.get("percent_change", None)
        if price == None or change == None:
            continue

        rows.append([sym, float(price), float(change)])

    if not rows:
        return {"ok": False, "title": "NO QUOTES", "sub": "CHECK SYMBOLS"}

    return {"ok": True, "rows": rows}

# ---------- page ----------

def main(c, ctx):
    # picopixel is the narrowest bundled font — three columns of digits fit 64px.
    F = "picopixel"

    c.fill("black")

    d = fetch(ctx)
    if not d["ok"]:
        c.text(d["title"], c.width // 2, 8, font = F, color = "orange", align = "center")
        c.text(d["sub"], c.width // 2, 18, font = F, color = "gray", align = "center")
        return

    y = 1
    for i in range(len(d["rows"])):
        row = d["rows"][i]
        sym = row[0]
        price = row[1]
        change = row[2]

        col = PALETTE[i % len(PALETTE)]
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