# Star of the Day — a different real star every day.
#
# No settings: it rotates automatically using today's date (ctx.now.yday), so each
# day shows the next star in the list. Draws a big shining star, a faint starfield,
# and a few quick facts.

# name, constellation, one-line fact, star color
STARS = [
    ("SIRIUS", "CANIS MAJOR", "8.6 LY - BRIGHTEST", "#CFE8FF"),
    ("CANOPUS", "CARINA", "310 LY - NAV STAR", "#F2F6FF"),
    ("ARCTURUS", "BOOTES", "37 LY - ORANGE GIANT", "#FFB060"),
    ("VEGA", "LYRA", "25 LY - SUMMER STAR", "#BCD4FF"),
    ("CAPELLA", "AURIGA", "43 LY - GOLDEN", "#FFD36B"),
    ("RIGEL", "ORION", "860 LY - BLUE GIANT", "#9DB8FF"),
    ("PROCYON", "CANIS MINOR", "11 LY - NEARBY", "#F0F4FF"),
    ("BETELGEUSE", "ORION", "640 LY - RED GIANT", "#FF6B4A"),
    ("ALTAIR", "AQUILA", "17 LY - FAST SPIN", "#E8F0FF"),
    ("ALDEBARAN", "TAURUS", "65 LY - BULLS EYE", "#FF9A4A"),
    ("ANTARES", "SCORPIUS", "550 LY - RED HEART", "#FF5533"),
    ("SPICA", "VIRGO", "250 LY - BLUE-WHITE", "#CFE0FF"),
    ("POLLUX", "GEMINI", "34 LY - ORANGE", "#FFC070"),
    ("FOMALHAUT", "PISCIS AUS", "25 LY - LONELY STAR", "#DFEAFF"),
    ("DENEB", "CYGNUS", "2600 LY - SUPERGIANT", "#EAF2FF"),
    ("REGULUS", "LEO", "79 LY - LITTLE KING", "#DCE8FF"),
    ("POLARIS", "URSA MINOR", "433 LY - NORTH STAR", "#FFFFFF"),
    ("BELLATRIX", "ORION", "250 LY - THE WARRIOR", "#C7D8FF"),
    ("CASTOR", "GEMINI", "51 LY - SIX STARS", "#E6EEFF"),
    ("MIZAR", "URSA MAJOR", "83 LY - DOUBLE STAR", "#E0EAFF"),
]

# Faint background stars, kept out of the text area so it stays readable.
FIELD = [
    (2, 5), (4, 27), (36, 4), (37, 28),
    (118, 3), (124, 10), (121, 18), (126, 25), (114, 30),
    (100, 31), (84, 31), (66, 31),
]


def _twinkle(c, x, y, col):
    c.pixel(x, y, col)
    c.pixel(x - 1, y, col)
    c.pixel(x + 1, y, col)
    c.pixel(x, y - 1, col)
    c.pixel(x, y + 1, col)


def _big_star(c, cx, cy, col):
    # four long rays + four short diagonals + a glowing core
    c.line(cx, cy - 13, cx, cy + 13, col)
    c.line(cx - 14, cy, cx + 14, cy, col)
    c.line(cx - 7, cy - 7, cx + 7, cy + 7, col)
    c.line(cx + 7, cy - 7, cx - 7, cy + 7, col)
    c.fill_circle(cx, cy, 4, col)
    c.fill_circle(cx, cy, 2, "white")


def main(c, ctx):
    name, constel, fact, col = STARS[(ctx.now.yday - 1) % len(STARS)]

    c.fill("black")

    # faint starfield + a couple of brighter twinkles
    for p in FIELD:
        c.pixel(p[0], p[1], "#454c66")
    _twinkle(c, 124, 10, "#6a7291")
    _twinkle(c, 4, 27, "#6a7291")

    # the star of the day, on the left
    _big_star(c, 20, 16, col)

    # the facts, on the right
    c.text(name, 40, 1, font = "7x12", color = col)
    c.text(constel, 40, 15, font = "5x7", color = "#8fa0c0")
    c.text(fact, 40, 25, font = "4x5", color = "#c2cad8")
