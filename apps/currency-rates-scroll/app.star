# Currency Rates
#
# open.er-api.com, keyless. The dropdowns list exactly the codes it serves,
# so nothing offered can fail to resolve.
#
# DESIGN (2026-08-25 redesign, per the design guidelines). Gold on near-black
# stays - it was the identity. The coins are DRAWN (circles + a $ glyph),
# pixel-perfect at each size, no scaled PNG. The panel says what the numbers
# mean: "1 <BASE> / BUYS" in the 10x15 outline face, so the base currency is
# always on the glass. Wide: one consolidated, centered block - coins, the
# lockup, a rule, then a ledger with the decimals in a column, all inside the
# scroll safe zone. Narrow (64): from the owner's sketch - coin top-left,
# stacked lockup, the rate as large as the panel allows, the currency code
# reading DOWN the right edge; the chosen currencies take the hero spot in
# turns by the minute, with a 1/3 counter so the rotation reads as deliberate
# (no counter when only one currency is chosen). Precision drops before font
# size, and a digit is never clipped - a cut number lies about the data.

GOLD = "#C8A860"      # codes and labels
BRIGHT = "#FFE8A8"    # values
FAINT = "#9A8850"     # the BUYS line
RULE = "#3A3010"      # separator, in the gold family

NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def coins(c, x, cy, big):
    """Two coins, drawn: a dark one behind, a $ coin in front. Integer
    circles - crisp at any size, nothing interpolated. Width: 22 / 17."""
    if big:
        c.fill_circle(x + 5, cy + 3, 5, "#C87820")
        c.circle(x + 5, cy + 3, 5, "#7A4410")
        c.fill_circle(x + 13, cy, 8, "#F5C842")
        c.circle(x + 13, cy, 8, "#8A5A10")
        c.circle(x + 13, cy, 6, "#D9A428")
        c.text("$", x + 13, cy - 3, font = "5x7", color = "#6A4A08",
               align = "center")
    else:
        c.fill_circle(x + 4, cy + 3, 4, "#C87820")
        c.circle(x + 4, cy + 3, 4, "#7A4410")
        c.fill_circle(x + 10, cy, 6, "#F5C842")
        c.circle(x + 10, cy, 6, "#8A5A10")
        c.text("$", x + 10, cy - 3, font = "5x7", color = "#6A4A08",
               align = "center")


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
    """Shown whenever a feed is unreachable or nothing is configured.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail"""
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


def rate_fit(c, v, fonts, maxw):
    """[font, text] for a rate: drop precision before dropping font size,
    and never clip a digit - a cut number lies about the data."""
    if v >= 1000.0:
        cands = [fmt.commas(int(v + 0.5)), str(int(v + 0.5))]
    elif v >= 100.0:
        cands = [str(int(v * 100) / 100.0), str(int(v * 10) / 10.0),
                 str(int(v + 0.5))]
    else:
        cands = [str(int(v * 10000) / 10000.0), str(int(v * 100) / 100.0)]
    for t in cands:
        for f in fonts:
            if c.text_width(t, f) <= maxw:
                return [f, t]
    return [fonts[len(fonts) - 1], cands[len(cands) - 1]]


def wide(c, base, rows):
    # Measure every part, then center the whole block on the panel.
    lock = "1 " + base
    lock_w = c.text_width(lock, "10x15_outline")
    vals = [rate_fit(c, r[1], ["5x7"], 44) for r in rows]
    code_w = 0
    val_w = 0
    for i in range(len(rows)):
        code_w = max(code_w, c.text_width(rows[i][0], "5x7"))
        val_w = max(val_w, c.text_width(vals[i][1], vals[i][0]))
    table_w = code_w + 5 + val_w
    art_w = 22
    total = art_w + 6 + lock_w + 8 + 1 + 8 + table_w
    x0 = (c.width - total) // 2
    if x0 < 10:
        x0 = 10  # never leave the safe zone

    coins(c, x0, 13, True)
    cx = x0 + art_w + 6 + lock_w // 2
    c.text(lock, cx, 0, font = "10x15_outline", color = BRIGHT,
           align = "center")
    c.text("BUYS", cx, 16, font = "10x15_outline", color = FAINT,
           align = "center")
    sx = x0 + art_w + 6 + lock_w + 8
    c.vline(sx, 4, 25, RULE)
    tx = sx + 9
    n = len(rows)
    ys = [13] if n == 1 else ([7, 19] if n == 2 else [3, 13, 23])
    for i in range(n):
        c.text(rows[i][0], tx, ys[i], font = "5x7", color = GOLD)
        c.text(vals[i][1], tx + table_w, ys[i], font = vals[i][0],
               color = BRIGHT, align = "right")


def narrow(c, ctx, base, rows):
    # 64x32, laid out from the owner's sketch: coin top-left, "1 USD / BUYS"
    # stacked beside it, the rate as large as it gets, and the currency code
    # reading DOWN the right edge, one letter per row. The currencies take
    # the hero spot in turns by the minute.
    idx = ctx.now.minute % len(rows)
    code = rows[idx][0]
    coins(c, 4, 7, False)
    cx = 34  # lockup center: clear of the coin and of the turn counter
    c.text("1 " + base, cx, 1, font = "4x5", color = GOLD, align = "center")
    c.text("BUYS", cx, 8, font = "4x5", color = FAINT, align = "center")
    if len(rows) > 1:
        # which turn is showing, so the rotation reads as deliberate
        c.text(str(idx + 1) + "/" + str(len(rows)), 63, 1, font = "4x5",
               color = "#6A5A38", align = "right")
    ly = 15
    for k in range(len(code)):
        c.text(code[k], 63, ly + k * 6, font = "4x5", color = GOLD,
               align = "right")
    v = rate_fit(c, rows[idx][1], ["10x15", "8x12"], 63 - 1 - 8)
    c.text(v[1], 1, 16, font = v[0], color = BRIGHT)


def rates(c, ctx):
    base = str(ctx.inputs.get("base", "USD")).strip().upper()
    want = []
    # Three slots rather than one comma-separated box: every combination of
    # three from 166 currencies is millions of dropdown entries.
    for k in ["curone", "curtwo", "curthree"]:
        v = str(ctx.inputs.get(k, "")).strip().upper()
        if v != "" and v != "NONE" and v != base and v not in want:
            want.append(v)
    if base == "" or len(want) == 0:
        nodata(c, "NOT CONFIGURED", "PICK CURRENCIES")
        return

    r = http.get("https://open.er-api.com/v6/latest/" + base,
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO RATES", "NO CONNECTION")
        return
    got = r["json"].get("rates", {})
    if len(got) == 0:
        nodata(c, "NO RATES", "CHECK THE CODES")
        return
    rows = []
    for w in want:
        v = got.get(w, None)
        if v != None:
            rows.append([w, float(v)])
    if len(rows) == 0:
        nodata(c, "NO RATES", "CHECK THE CODES")
        return

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#100C04", "#2A2008",
                    horizontal = False)
    if c.width >= 128:
        wide(c, base, rows)
    else:
        narrow(c, ctx, base, rows)
