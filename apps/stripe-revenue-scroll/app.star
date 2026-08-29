# Stripe Revenue
#
# Stripe's balance endpoint with a restricted API key. Use a
# read-only restricted key, never a live secret key — a panel on a
# wall should not be able to move money.
#
# Amounts arrive in the currency's smallest unit, so they are divided
# by 100 for the currencies that have cents.



NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do.

    text_fit alone was not enough here: when even its smallest option
    overflows it still draws, which ran these messages off a 64 panel."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands — a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


DEMO = "DEMO"


def is_demo(ctx):
    """True when the key is the literal DEMO opt-in.

    Catalog previews are rendered with this so they show the real layout
    carrying representative values. A panel with no key configured still gets
    the plain error screen — this never fires by accident."""
    return str(ctx.inputs.get("apikey", "")).strip().upper() == DEMO


def demo_badge(c):
    """A single corner marker. A SAMPLE word across the top-right covered real
    content in half these apps, which defeats the point of the preview."""
    c.rect(c.width - 5, 0, c.width - 1, 4, fill = "#3A3F52")
    c.text("S", c.width - 2, 0, font = "3x4", color = "#D8DEF0",
           align = "right")


STRIPE_SAMPLE = {"status_code": 200, "json": {"available": [
    {"amount": 4821650, "currency": "usd"}]}}

ZERO_DECIMAL = ["JPY", "KRW", "VND", "CLP", "ISK"]
SYMBOL = {"USD": "$", "EUR": "E", "GBP": "L", "JPY": "Y", "AUD": "A$",
          "CAD": "C$"}


def money_abbrev(v, sym):
    """$4.8M-style truncation, only used when the full number cannot fit."""
    for div, tag in [(1000000000, "B"), (1000000, "M"), (1000, "K")]:
        if v >= div:
            whole = int(v // div)
            tenth = int((v % div) * 10 // div)
            if whole >= 100 or tenth == 0:
                return sym + str(whole) + tag
            return sym + str(whole) + "." + str(tenth) + tag
    return sym + str(int(v))


def money(amount, cur):
    up = cur.upper()
    div = 1.0
    if up not in ZERO_DECIMAL:
        div = 100.0
    v = amount / div
    sym = SYMBOL.get(up, "")
    if v >= 1000:
        return sym + fmt.commas(int(v))
    return sym + str(int(v * 100) / 100.0)


def balance(c, ctx):
    key = str(ctx.inputs.get("apikey", "")).strip()
    if key == "":
        nodata(c, "NO KEY", "ADD KEY")
        return

    r = STRIPE_SAMPLE if is_demo(ctx) else http.get(
        "https://api.stripe.com/v1/balance",
        headers = {"Authorization": "Bearer " + key}, ttl_seconds = 600)
    if r["status_code"] == 401:
        nodata(c, "BAD KEY", "BAD KEY")
        return
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO BALANCE", "NO CONNECTION")
        return

    avail = r["json"].get("available", [])
    if len(avail) == 0:
        nodata(c, "NO BALANCE", "NOTHING YET")
        return

    rows = len(avail) if len(avail) < 3 else 3

    c.fill("#080A12")
    if c.width >= 128 and rows == 1:
        a = avail[0]
        cur = str(a.get("currency", "")).upper()
        raw = float(a.get("amount", 0) or 0)
        c.text_stroke("STRIPE AVAILABLE", 6, 2, font = "5x7",
                      color = "#6A72A8", stroke = "black")
        # full number when it fits, K/M/B truncation when it cannot
        amt = money(raw, cur)
        maxw = c.width - 60
        font = "16x20"
        if c.text_width(amt, font) > maxw:
            font = "10x16"
        if c.text_width(amt, font) > maxw:
            div = 1.0 if cur in ZERO_DECIMAL else 100.0
            amt = money_abbrev(raw / div, SYMBOL.get(cur, ""))
            font = "16x20" if c.text_width(amt, "16x20") <= maxw else "10x16"
        c.text_stroke(amt, 6, 10, font = font, color = "#8FA8FF",
                      stroke = "black")
        # currency code rides 3px off the end of the number
        ux = 6 + c.text_width(amt, font) + 3
        c.text_stroke(cur, ux, 14, font = "10x16", color = "#4E5680",
                      stroke = "black")
        # stripe mark: 7px tall, right edge 10px off the panel edge
        c.round_rect(c.width - 16, 2, c.width - 10, 8, 2, fill = "#635BFF")
        c.text("S", c.width - 14, 3, font = "4x5", color = "white")
        if is_demo(ctx):
            demo_badge(c)
        return

    h = c.height // rows
    for i in range(rows):
        a = avail[i]
        cur = str(a.get("currency", "")).upper()
        y = i * h + (h - 7) // 2
        if c.width >= 128:
            c.text(cur, 2, y, font = "5x7", color = "#6A72A8")
            c.text(money(float(a.get("amount", 0) or 0), cur), c.width - 2, y,
                   font = "5x7", color = "#8FA8FF", align = "right")
        else:
            # 64px cannot hold a currency code and an amount side by side.
            c.text(cur, 2, y - 4, font = "4x5", color = "#6A72A8")
            c.text_fit(money(float(a.get("amount", 0) or 0), cur), c.width - 2,
                       y + 2, ["5x7", "4x5"], color = "#8FA8FF",
                       align = "right", maxw = c.width - 4)
