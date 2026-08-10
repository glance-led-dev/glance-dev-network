# Halloween Countdown for a Glance SCROLL panel (192x32).
#
# A night scene read left to right: your chosen character stands on the left,
# a full moon with bats hangs on the right, and the days until October 31 are
# spelled out between them. Everything is computed from ctx.now — no network,
# so the panel always has something to show.

MOONX = 158           # full moon, top-right
MOONY = 1
MOONR = 23            # the moon asset is square
GROUNDY = 29          # top row of the ground silhouette
ZONEL = 36            # text sits between the character and the moon
ZONER = 154

# Bat silhouettes: a near one and a couple further off.
BAT = [
    "##.........##",
    "###...#...###",
    "####.###.####",
    ".###########.",
    "..#.#####.#..",
]
# Faint stars, kept clear of the header, the day count and the bats.
STARS = [(37, 6), (59, 3), (130, 6), (152, 2), (155, 8)]


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


def sky(c):
    """Deep purple night fading to a sickly orange glow at the horizon."""
    c.gradient_rect(0, 0, c.width - 1, 20, "#120425", "#2a0937", horizontal = False)
    c.gradient_rect(0, 21, c.width - 1, GROUNDY - 1, "#2a0937", "#5c1a2e",
                    horizontal = False)
    for s in STARS:
        c.pixel(s[0], s[1], "#6b5aa0")


def moon(c):
    c.image("MOON.png", MOONX, MOONY, w = MOONR, h = MOONR)
    # one bat clipping the bright disc, two more out in the open sky
    c.sprite(BAT, MOONX + 12, MOONY + 3, color = "#4a2a6b")
    c.sprite(BAT, 136, 0, color = "#6b4f9e")
    c.sprite(BAT, 44, 2, color = "#5b4187")


def ground(c):
    c.rect(0, GROUNDY, c.width - 1, c.height - 1, fill = "#0a0316")
    c.hline(0, GROUNDY, c.width, "#40205e")
    for x in range(4, c.width, 11):
        c.pixel(x, GROUNDY - 1, "#2a1442")
    graveyard(c)


def graveyard(c):
    """A picket fence under the moon, with a grave cross tall enough to break
    the disc — nothing else is competing for that corner."""
    for x in range(156, 192, 4):
        c.vline(x, 25, 4, "#1a0a2c")
    c.hline(156, 26, 36, "#1a0a2c")
    c.rect(172, 20, 173, GROUNDY - 1, fill = "#150822")
    c.rect(169, 22, 176, 23, fill = "#150822")


def character(c, who):
    """The hero art, bottom-aligned on the ground (the flyers hover)."""
    if who == "GHOST":
        c.image("GHOST.png", 6, 2, w = 22, h = 26)
    elif who == "WITCH":
        c.image("WITCH.png", 1, 5, w = 32, h = 21)
    else:
        c.image("JACKO.png", 2, 3, w = 31, h = 27)


def countdown(c, ctx):
    accent = ctx.inputs.get("accent", "#FF7A18")
    who = ctx.inputs.get("character", "PUMPKIN")

    sky(c)
    moon(c)
    ground(c)
    character(c, who)

    n = days_left(ctx)
    cx = (ZONEL + ZONER) // 2

    if n == 0:
        c.text("HAPPY", cx, 1, font = "6x8", color = accent, align = "center")
        c.text("HALLOWEEN", cx, 11, font = "10x16", color = "white",
               align = "center")
        return

    c.text("HALLOWEEN", cx, 0, font = "6x8", color = accent, align = "center")

    numstr = str(n)
    numfont = "16x20"
    if c.text_width(numstr, numfont) > ZONER - ZONEL - 30:
        numfont = "10x16"
    daystr = "DAY" if n == 1 else "DAYS"

    numw = c.text_width(numstr, numfont)
    labw = c.text_width(daystr, "5x7")
    datew = c.text_width("OCT 31", "4x5")
    if datew > labw:
        labw = datew

    x0 = cx - (numw + 4 + labw) // 2
    c.text(numstr, x0, 8, font = numfont, color = "white")
    c.text(daystr, x0 + numw + 4, 10, font = "5x7", color = accent)
    c.text("OCT 31", x0 + numw + 4, 19, font = "4x5", color = "#9a7fd0")
