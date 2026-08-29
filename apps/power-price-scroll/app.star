# Power Price
#
# ComEd publishes its five-minute real-time price openly, with no
# key. It is the US analogue of Octopus Agile: if you are on the
# hourly plan, running the dryer at the right moment is worth real
# money.
#
# The feed is newest-first and quoted in cents per kilowatt hour.
# An hour of samples gives the trend, which matters more than the
# instantaneous number.



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


# 1px silhouette outline of PLUG.png at its drawn 24x24 size, offset (-1,-1).
PLUG_EDGE = """
..........................
........###....###........
........#.#....#.#........
........#.#....#.#........
........#.#....#.#........
......###.######.###......
......#............#......
.....##............##.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....#..............#.....
.....##............##.....
......#............#......
......###........###......
........###....###........
..........#....#..........
..........#....#..........
..........######..........
..........................
"""

def price(c, ctx):
    r = http.get("https://hourlypricing.comed.com/api",
                 params = {"type": "5minutefeed", "format": "json"},
                 ttl_seconds = 300)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO PRICE DATA", "COMED UNREACHABLE")
        return
    rows = r["json"]
    if len(rows) == 0:
        nodata(c, "NO PRICE DATA", "EMPTY FEED")
        return

    now = float(rows[0].get("price", 0) or 0)
    # Twelve five-minute samples back is an hour ago.
    back_i = 12 if len(rows) > 12 else len(rows) - 1
    back = float(rows[back_i].get("price", 0) or 0)
    delta = now - back

    if now < 0:
        col = "#7FD4FF"
        verdict = "NEGATIVE"
    elif now < 3:
        col = "#4EE38A"
        verdict = "CHEAP"
    elif now < 6:
        col = "#A8E34E"
        verdict = "NORMAL"
    elif now < 12:
        col = "#FFB03A"
        verdict = "PRICEY"
    else:
        col = "#FF5B5B"
        verdict = "EXPENSIVE"

    arrow = "RISING" if delta > 0.3 else ("FALLING" if delta < -0.3 else "STEADY")

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0C0E06", "#242A10",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    px = 5 if c.width >= 128 else 1
    py = (c.height - sz) // 2
    if c.width >= 128:
        # 1px black outline traced from the plug's own silhouette, matching
        # the stroked text.
        c.sprite(PLUG_EDGE, px - 1, py - 1, color = "black")
    c.image("PLUG.png", px, py, w = sz, h = sz)

    if c.width >= 128:
        # Title row names the app; content sits 4px further toward the middle
        # on both sides so nothing rides the edges while scrolling.
        c.text_stroke("POWER PRICE - CENTS PER KWH", 32, 1, font = "4x5",
                      color = "#8A9060")
        num = str(int(now * 10) / 10.0)
        nfont = "16x20" if c.text_width(num, "16x20") <= c.width - 124 else "10x16"
        c.text_stroke(num, 32, 7, font = nfont, color = col)
        c.text_stroke(verdict, c.width - 10, 7, font = "10x16", color = col,
                      align = "right")
        c.text_stroke(arrow, c.width - 10, 24, font = "6x8", color = "#B0B890",
                      align = "right")
    else:
        # Number and verdict centred in the space between the plug art and
        # the right edge, instead of hugging the edge.
        cxm = (17 + c.width) // 2
        c.text_fit(str(int(now * 10) / 10.0), cxm, 3,
                   ["16x20", "10x16"], color = col, align = "center",
                   maxw = c.width - 20)
        c.text_fit(verdict, cxm, 25, ["4x5", "3x4"], color = col,
                   align = "center", maxw = c.width - 20)
