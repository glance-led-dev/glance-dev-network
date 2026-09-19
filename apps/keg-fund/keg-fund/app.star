BEER = "#E29B1A"
BEER_DARK = "#B06E0C"
FOAM = "#FFF3C8"
GLASS = "#9AA8B8"
BUBBLE = "#FFD56A"

def _parse_money(s, fallback):
    raw = str(s or "")
    cleaned = ""
    dotted = False
    for i in range(len(raw)):
        ch = raw[i]
        if ch >= "0" and ch <= "9":
            cleaned += ch
        elif ch == "." and not dotted:
            cleaned += ch
            dotted = True
    if cleaned == "" or cleaned == ".":
        return fallback
    return int(float(cleaned))

def _clamp(n, lo, hi):
    if n < lo:
        return lo
    if n > hi:
        return hi
    return n

def _stats(ctx):
    donated = _parse_money(ctx.inputs.get("donated", "0"), 0)
    goal = _parse_money(ctx.inputs.get("goal", "120"), 120)
    if goal < 1:
        goal = 1
    left = goal - donated
    if left < 0:
        left = 0
    pct = _clamp(int(donated * 100 / goal), 0, 100)
    name = str(ctx.inputs.get("label", "NEXT KEG") or "NEXT KEG").upper()
    return donated, goal, left, pct, name

def _bubbles(c, y0, y1, seed):
    spots = [
        (8, 3), (22, 7), (37, 2), (51, 9), (66, 4),
        (80, 8), (94, 3), (109, 6), (18, 12), (73, 11),
        (44, 5), (101, 10), (12, 8), (88, 2),
    ]
    for i in range(len(spots)):
        x = spots[i][0]
        y = spots[i][1] + seed
        if y >= y0 and y <= y1 and y < 31:
            color = FOAM if i % 3 == 0 else BUBBLE
            c.pixel(x, y, color)
            if i % 2 == 0 and y + 1 <= y1:
                c.pixel(x + 1, y, color)

def _foam_line(c, y):
    if y < 0 or y > 30:
        return
    for x in range(0, c.width, 4):
        bump = 0
        if x % 7 == 0:
            bump = -1
        elif x % 5 == 0:
            bump = 1
        yy = y + bump
        if yy >= 0 and yy < 32:
            c.rect(x, yy, min(x + 3, c.width - 1), min(yy + 1, 31), fill=FOAM)

def _draw_pour(c, pct, seed):
    c.fill("black")
    fill_h = _clamp(int(32 * pct / 100), 0, 32)
    top = 32 - fill_h
    if fill_h > 0:
        c.rect(0, top, c.width - 1, 31, fill=BEER)
        if fill_h > 8:
            c.rect(0, 26, c.width - 1, 31, fill=BEER_DARK)
        _foam_line(c, top)
        if fill_h > 4:
            _foam_line(c, top + 2)
        _bubbles(c, top + 1, 30, seed)

def _draw_mug(c, x, y):
    c.rect(x, y, x + 10, y + 16, outline=GLASS)
    c.rect(x + 1, y + 5, x + 9, y + 15, fill=BEER)
    c.rect(x + 1, y + 3, x + 9, y + 5, fill=FOAM)
    c.rect(x + 10, y + 6, x + 13, y + 12, outline=GLASS)

def pour1(c, ctx):
    _draw_pour(c, 18, 0)

def pour2(c, ctx):
    _draw_pour(c, 42, 1)

def pour3(c, ctx):
    _draw_pour(c, 70, 2)

def pour4(c, ctx):
    _draw_pour(c, 100, 3)
    c.text_center("KEG FUND", 12, font="6x8", color="black")

def wash1(c, ctx):
    c.fill("black")
    c.rect(28, 0, c.width - 1, 31, fill=BEER)
    c.rect(28, 0, 36, 31, fill=FOAM)
    _bubbles(c, 2, 28, 4)
    c.text("DONATE NOW!f", 2, 12, font="5x7", color=FOAM)

def wash2(c, ctx):
    c.fill("black")
    c.rect(86, 0, c.width - 1, 31, fill=BEER)
    c.rect(86, 0, 92, 31, fill=FOAM)
    c.text_center("...", 12, font="6x8", color=GLASS)

def funds(c, ctx):
    donated, goal, left, pct, name = _stats(ctx)
    c.fill("black")
    _draw_mug(c, 4, 8)

    bar_color = "green"
    if pct < 34:
        bar_color = "red"
    elif pct < 67:
        bar_color = "amber"

    if left <= 0:
        c.text("KEG FUNDED", 22, 5, font="6x8", color="green")
        c.text("TAP IT", 22, 15, font="7x12", color="amber")
        c.progress_bar(22, 26, 100, 4, 100, color="green")
        return

    c.text(name, 22, 3, font="5x7", color=FOAM)
    c.text(str(pct) + "%", 22, 12, font="10x16", color=bar_color)
    c.progress_bar(22, 26, 100, 4, pct, color=bar_color)