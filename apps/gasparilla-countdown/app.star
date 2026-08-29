# Gasparilla countdown for a Glance Scroll panel (192x32).
# Draws PIRATE_FLAG.png beside the days-until-Gasparilla block, and centres the
# flag + text group as a single unit on the canvas.

EVENT_DATE = (2027, 1, 30)   # hardcoded festival date (Y, M, D)
LABEL      = "GASPARILLA"    # hardcoded header text

FLAG_W   = 48                # drawn width of PIRATE_FLAG.png
FLAG_GAP = 4                 # space between the flag and the text block
SAFE_L   = 10
SAFE_R   = 182

# Days since an epoch for a civil date (Hinnant's algorithm). We only ever
# subtract two of these, so the epoch it counts from doesn't matter.
def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def font_h(name):
    return int(name.split("x")[1])

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

def countdown(c, ctx):
    accent = ctx.inputs.get("accent", "#FFC300")

    c.fill("black")

    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    event = days_from_civil(EVENT_DATE[0], EVENT_DATE[1], EVENT_DATE[2])
    n = event - today

    # Header is fixed: GASPARILLA at y=0 in 6x8.
    hdr = LABEL
    hdrfont = "6x8"
    hw = c.text_width(hdr, hdrfont)

    # Big line: the days number in the tallest font that fits the band under
    # the header (rows 9..31, 23 rows -> 16x20 is the tallest rung that fits),
    # plus a small DAYS tag, or the festival-day message. The widest it may get
    # is the safe zone, so the number ladder degrades on absurd day counts.
    maxbig = (SAFE_R - SAFE_L + 1) - FLAG_W - FLAG_GAP

    if n <= 0:
        numstr = "TODAY!" if n == 0 else "AHOY!"
        daystr = ""
        dw = 0
        gap = 0
    else:
        numstr = str(n)
        daystr = "DAY" if n == 1 else "DAYS"
        dw = c.text_width(daystr, "5x7")
        gap = 3

    numfont = fit_font(c, numstr, ["16x20", "10x16", "7x12", "5x7"], maxbig - gap - dw)
    nw = c.text_width(numstr, numfont)
    bigw = nw + gap + dw

    # Text block is as wide as its widest line; the group is flag + block.
    bw = hw if hw > bigw else bigw
    groupw = FLAG_W + FLAG_GAP + bw
    gx = (c.width - groupw) // 2
    if gx < SAFE_L:
        gx = SAFE_L

    bx = gx + FLAG_W + FLAG_GAP

    c.image("PIRATE_FLAG.png", gx, 0, w = FLAG_W, h = 32)
    c.text(hdr, bx + (bw - hw) // 2, 0, font = hdrfont, color = accent, align = "left")

    # Lower band starts 1px under the header ink (row 9) and ends at the bottom
    # of the panel; sit the big line on the bottom edge.
    nh = font_h(numfont)
    numy = 32 - nh
    bigx = bx + (bw - bigw) // 2
    c.text(numstr, bigx, numy, font = numfont, color = "white", align = "left")
    if daystr:
        c.text(daystr, bigx + nw + gap, numy + nh - 7, font = "5x7", color = accent, align = "left")
