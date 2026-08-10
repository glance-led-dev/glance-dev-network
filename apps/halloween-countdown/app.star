# Halloween Countdown for a Glance LED V2 panel (64x32).
#
# The same night scene as the 192-wide Scroll version, compressed into two
# columns: your character under the moon on the left, the nights until
# October 31 stacked on the right. Everything comes from ctx.now — no network,
# so the panel always has something to show.

GROUNDY = 30          # top row of the ground silhouette
ZONEL = 25            # the text column, right of the character
ZONER = 63

BAT = [
    "#.......#",
    "##.###.##",
    "####.####",
    ".#######.",
    "..#...#..",
]
STARS = [(20, 3), (23, 14), (2, 20), (61, 8)]


def days_from_civil(y, m, d):
    """Days since a fixed epoch (Howard Hinnant's algorithm). Only the
    difference between two of these matters, so the epoch is irrelevant."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def days_left(ctx):
    """Nights until October 31. Rolls to next year once Halloween has passed."""
    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    night = days_from_civil(ctx.now.year, 10, 31)
    if today > night:
        night = days_from_civil(ctx.now.year + 1, 10, 31)
    return night - today


def scene(c):
    """Night sky, moon, a bat, and the ground the character stands on."""
    c.gradient_rect(0, 0, c.width - 1, 21, "#120425", "#2a0937", horizontal = False)
    c.gradient_rect(0, 22, c.width - 1, GROUNDY - 1, "#2a0937", "#5c1a2e",
                    horizontal = False)
    for s in STARS:
        c.pixel(s[0], s[1], "#6b5aa0")

    c.image("MOON.png", 1, 1, w = 13, h = 13)
    c.sprite(BAT, 8, 3, color = "#4a2a6b")

    c.rect(0, GROUNDY, c.width - 1, c.height - 1, fill = "#0a0316")
    c.hline(0, GROUNDY, c.width, "#40205e")


def character(c, who):
    """The hero art, bottom-aligned on the ground (the flyers hover)."""
    if who == "GHOST":
        c.image("GHOST.png", 4, 10, w = 15, h = 19)
    elif who == "WITCH":
        c.image("WITCH.png", 0, 13, w = 23, h = 15)
    else:
        c.image("JACKO.png", 1, 10, w = 22, h = 20)


def main(c, ctx):
    accent = ctx.inputs.get("accent", "#FF7A18")
    who = ctx.inputs.get("character", "PUMPKIN")

    scene(c)

    n = days_left(ctx)
    cx = (ZONEL + ZONER) // 2

    # On the night itself the character steps aside so the greeting can run
    # the full width of the panel.
    if n == 0:
        c.text("HAPPY", c.width // 2, 2, font = "10x16", color = accent,
               align = "center")
        c.text("HALLOWEEN", c.width // 2, 20, font = "5x7", color = "white",
               align = "center")
        return

    character(c, who)
    c.text("HALLOWEEN", cx, 0, font = "3x4", color = accent, align = "center")

    numstr = str(n)
    numfont = "16x20"
    numh = 20
    if c.text_width(numstr, numfont) > ZONER - ZONEL:
        numfont = "10x16"
        numh = 16
    c.text(numstr, cx, 4 + (20 - numh) // 2, font = numfont, color = "white",
           align = "center")
    c.text("DAY" if n == 1 else "DAYS", cx, 24, font = "4x5", color = accent,
           align = "center")
