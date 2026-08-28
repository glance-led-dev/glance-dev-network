# Star of the Day - a different real star every day.
#
# No settings: it rotates automatically using today's date (ctx.now.yday), so each
# day shows the next star in the list. Draws a big shining star, a faint starfield,
# and a few quick facts.
#
# Distances are rounded light-years -- published parallax figures differ slightly
# between catalogs, so these are the commonly cited values rather than any one
# survey's exact number.

# name, constellation, "DISTANCE - DESCRIPTION", star color.
# The fact is split on the dash at draw time so it can sit on two lines.
STARS = [
    ("SIRIUS", "CANIS MAJOR", "8.6 LY - BRIGHTEST", "#CFE8FF"),
    ("CANOPUS", "CARINA", "310 LY - NAV STAR", "#F2F6FF"),
    ("RIGIL KENT", "CENTAURUS", "4.4 LY - SUNS NEIGHBOR", "#FFF0D0"),
    ("ARCTURUS", "BOOTES", "37 LY - ORANGE GIANT", "#FFB060"),
    ("VEGA", "LYRA", "25 LY - SUMMER STAR", "#BCD4FF"),
    ("CAPELLA", "AURIGA", "43 LY - GOLDEN", "#FFD36B"),
    ("RIGEL", "ORION", "860 LY - BLUE GIANT", "#9DB8FF"),
    ("PROCYON", "CANIS MINOR", "11 LY - NEARBY", "#F0F4FF"),
    ("ACHERNAR", "ERIDANUS", "139 LY - FLATTENED", "#B9CCFF"),
    ("BETELGEUSE", "ORION", "640 LY - RED GIANT", "#FF6B4A"),
    ("HADAR", "CENTAURUS", "390 LY - BLUE GIANT", "#A9C0FF"),
    ("ALTAIR", "AQUILA", "17 LY - FAST SPIN", "#E8F0FF"),
    ("ACRUX", "CRUX", "320 LY - THE CROSS", "#B7CCFF"),
    ("ALDEBARAN", "TAURUS", "65 LY - BULLS EYE", "#FF9A4A"),
    ("ANTARES", "SCORPIUS", "550 LY - RED HEART", "#FF5533"),
    ("SPICA", "VIRGO", "250 LY - BLUE-WHITE", "#CFE0FF"),
    ("POLLUX", "GEMINI", "34 LY - ORANGE", "#FFC070"),
    ("FOMALHAUT", "PISCIS AUS", "25 LY - LONELY STAR", "#DFEAFF"),
    ("DENEB", "CYGNUS", "2600 LY - SUPERGIANT", "#EAF2FF"),
    ("MIMOSA", "CRUX", "280 LY - CROSS JEWEL", "#B0C6FF"),
    ("REGULUS", "LEO", "79 LY - LITTLE KING", "#DCE8FF"),
    ("ADHARA", "CANIS MAJOR", "430 LY - UV BEACON", "#A8C2FF"),
    ("CASTOR", "GEMINI", "51 LY - SIX STARS", "#E6EEFF"),
    ("GACRUX", "CRUX", "89 LY - RED GIANT", "#FF7A50"),
    ("SHAULA", "SCORPIUS", "570 LY - THE STINGER", "#B4C8FF"),
    ("BELLATRIX", "ORION", "250 LY - THE WARRIOR", "#C7D8FF"),
    ("ELNATH", "TAURUS", "130 LY - BULLS HORN", "#DCE6FF"),
    ("MIAPLACIDUS", "CARINA", "113 LY - BLUE-WHITE", "#DDE8FF"),
    ("ALNILAM", "ORION", "2000 LY - BELT CENTER", "#C0D4FF"),
    ("ALNAIR", "GRUS", "101 LY - THE BRIGHT", "#C6D8FF"),
    ("ALNITAK", "ORION", "1260 LY - BELT EAST", "#B8CCFF"),
    ("MINTAKA", "ORION", "1200 LY - BELT WEST", "#BFD2FF"),
    ("ALIOTH", "URSA MAJOR", "81 LY - DIPPER BRIGHT", "#E2EAFF"),
    ("DUBHE", "URSA MAJOR", "123 LY - POINTER STAR", "#FFCB8A"),
    ("MERAK", "URSA MAJOR", "79 LY - POINTER STAR", "#E4ECFF"),
    ("ALKAID", "URSA MAJOR", "104 LY - HANDLE END", "#C8DAFF"),
    ("MIRFAK", "PERSEUS", "510 LY - SUPERGIANT", "#F0EFD8"),
    ("WEZEN", "CANIS MAJOR", "1600 LY - SUPERGIANT", "#F6F2E0"),
    ("KAUS AUSTRALIS", "SAGITTARIUS", "143 LY - THE BOW", "#D6E2FF"),
    ("AVIOR", "CARINA", "630 LY - ORANGE PAIR", "#FFB878"),
    ("MENKALINAN", "AURIGA", "81 LY - ECLIPSING", "#E4ECFF"),
    ("ATRIA", "TRI AUSTRALE", "390 LY - ORANGE GIANT", "#FFB466"),
    ("ALHENA", "GEMINI", "109 LY - THE BRAND", "#E0E9FF"),
    ("PEACOCK", "PAVO", "180 LY - BLUE GIANT", "#BFD2FF"),
    ("MIRZAM", "CANIS MAJOR", "500 LY - THE HERALD", "#B6CAFF"),
    ("ALPHARD", "HYDRA", "177 LY - THE LONELY", "#FFA860"),
    ("POLARIS", "URSA MINOR", "433 LY - NORTH STAR", "#FFFFFF"),
    ("HAMAL", "ARIES", "66 LY - THE RAM", "#FFC078"),
    ("ALGIEBA", "LEO", "130 LY - GOLD DOUBLE", "#FFCB80"),
    ("DIPHDA", "CETUS", "96 LY - ORANGE GIANT", "#FFC98C"),
    ("MIZAR", "URSA MAJOR", "83 LY - DOUBLE STAR", "#E0EAFF"),
    ("ALCOR", "URSA MAJOR", "82 LY - EYESIGHT TEST", "#E4ECFF"),
    ("NUNKI", "SAGITTARIUS", "228 LY - BLUE GIANT", "#C0D2FF"),
    ("MENKENT", "CENTAURUS", "61 LY - ORANGE GIANT", "#FFB870"),
    ("ALPHERATZ", "ANDROMEDA", "97 LY - SHARED STAR", "#DDE8FF"),
    ("MIRACH", "ANDROMEDA", "197 LY - RED GIANT", "#FF9E5A"),
    ("KOCHAB", "URSA MINOR", "131 LY - OLD POLE", "#FFBE7A"),
    ("RASALHAGUE", "OPHIUCHUS", "48 LY - FAST SPIN", "#E8EEFF"),
    ("ALGOL", "PERSEUS", "90 LY - DEMON STAR", "#DCE6FF"),
    ("DENEBOLA", "LEO", "36 LY - LIONS TAIL", "#E6EEFF"),
    ("ALBIREO", "CYGNUS", "430 LY - GOLD & BLUE", "#FFD080"),
    ("SADR", "CYGNUS", "1800 LY - SWANS HEART", "#F2EEDC"),
    ("ETAMIN", "DRACO", "154 LY - DRAGONS EYE", "#FFA860"),
    ("SCHEDAR", "CASSIOPEIA", "228 LY - ORANGE GIANT", "#FFC078"),
    ("CAPH", "CASSIOPEIA", "54 LY - THE HAND", "#FFF4D8"),
    ("ENIF", "PEGASUS", "690 LY - THE NOSE", "#FFB070"),
    ("MARKAB", "PEGASUS", "133 LY - THE SADDLE", "#DCE6FF"),
    ("SCHEAT", "PEGASUS", "196 LY - RED GIANT", "#FF9A55"),
    ("ALDERAMIN", "CEPHEUS", "49 LY - FUTURE POLE", "#E8EEFF"),
    ("THUBAN", "DRACO", "300 LY - ANCIENT POLE", "#E2EAFF"),
    ("PROXIMA", "CENTAURUS", "4.2 LY - CLOSEST", "#FF6B4A"),
    ("BARNARDS STAR", "OPHIUCHUS", "6 LY - FAST MOVER", "#FF7A4A"),
    ("SAIPH", "ORION", "650 LY - ORIONS KNEE", "#B4C8FF"),
    ("ZOSMA", "LEO", "58 LY - THE GIRDLE", "#E0E9FF"),
    ("PORRIMA", "VIRGO", "38 LY - CLOSE DOUBLE", "#F0F4FF"),
    ("RASALGETHI", "HERCULES", "360 LY - GIANTS HEAD", "#FF8A50"),
    ("MIRA", "CETUS", "300 LY - THE WONDERFUL", "#FF7040"),
    ("MENKAR", "CETUS", "250 LY - RED GIANT", "#FF9155"),
    ("ALCYONE", "TAURUS", "440 LY - PLEIADES", "#C8DAFF"),
    ("ANKAA", "PHOENIX", "85 LY - ORANGE GIANT", "#FFBE80"),
    ("SADALSUUD", "AQUARIUS", "540 LY - LUCKIEST", "#F4F0DC"),
    ("IZAR", "BOOTES", "236 LY - PRETTY PAIR", "#FFB878"),
    ("GIENAH", "CORVUS", "154 LY - RAVENS WING", "#C4D6FF"),
    ("ALPHECCA", "CORONA BOR", "75 LY - CROWN JEWEL", "#E4ECFF"),
]

# Faint background stars, kept out of the text area and out of the title so
# everything stays readable.
FIELD = [
    (2, 5), (3, 15), (36, 4), (37, 20),
    (118, 3), (124, 10), (121, 18), (126, 25), (114, 30),
    (100, 31), (84, 31), (66, 31),
]

# Cell height of each bundled font, so the stack can space itself evenly.
FONT_H = {"7x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# The starburst is drawn from the top of the panel (y=0) down to Y_BOTTOM, the
# row the old art already finished on, so it fills the whole space above the
# title instead of floating in the middle of it.
STAR_CX = 20
STAR_TOP = 0
STAR_BOTTOM = 18

HEXD = "0123456789abcdef"

def _hex2(v):
    if v < 0:
        v = 0
    if v > 255:
        v = 255
    return HEXD[v // 16] + HEXD[v % 16]

def _dim(col, num, den):
    # Knock a colour back without alpha, so the short diagonal rays read as a
    # softer glow behind the four main ones. Works for any "#rrggbb" entry.
    r = int(col[1:3], 16) * num // den
    g = int(col[3:5], 16) * num // den
    b = int(col[5:7], 16) * num // den
    return "#" + _hex2(r) + _hex2(g) + _hex2(b)

def fit_line(c, text, options, maxw):
    # Pick the biggest font the string fits in. If even the smallest one is too
    # wide -- a very long star or constellation name -- clip characters off the
    # end so it can never run into the panel edge.
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f, text

    f = options[len(options) - 1]
    out = text
    for _ in range(len(text)):
        if c.text_width(out, f) <= maxw:
            break
        out = out[:len(out) - 1]
    return f, out

def _twinkle(c, x, y, col):
    c.pixel(x, y, col)
    c.pixel(x - 1, y, col)
    c.pixel(x + 1, y, col)
    c.pixel(x, y - 1, col)
    c.pixel(x, y + 1, col)

def _ray_v(c, cx, cy, reach, sign, step, col):
    # A vertical ray that tapers from a few pixels wide at the core to a single
    # pixel at the tip. step controls how quickly it narrows.
    for d in range(reach + 1):
        half = (reach - d) // step
        c.hline(cx - half, cy + sign * d, half + half + 1, col)

def _ray_h(c, cx, cy, reach, sign, step, col):
    for d in range(reach + 1):
        half = (reach - d) // step
        c.vline(cx + sign * d, cy - half, half + half + 1, col)

def _big_star(c, cx, col):
    # A tapered four-point burst plus four dimmer diagonals and a glowing core.
    # It is anchored so the top tip lands on row STAR_TOP and the bottom tip on
    # STAR_BOTTOM, whatever those are set to.
    up = (STAR_BOTTOM - STAR_TOP) // 2
    cy = STAR_TOP + up
    down = STAR_BOTTOM - cy
    side = 13

    faint = _dim(col, 2, 5)
    for d in range(1, 7):
        c.pixel(cx - d, cy - d, faint)
        c.pixel(cx + d, cy - d, faint)
        c.pixel(cx - d, cy + d, faint)
        c.pixel(cx + d, cy + d, faint)

    _ray_h(c, cx, cy, side, 1, 5, col)
    _ray_h(c, cx, cy, side, -1, 5, col)
    _ray_v(c, cx, cy, up, -1, 4, col)
    _ray_v(c, cx, cy, down, 1, 4, col)

    c.fill_circle(cx, cy, 3, col)
    c.fill_circle(cx, cy, 1, "white")

def _stack(c, x, lines):
    # lines: [[text, font, color], ...]
    # Work out the leftover space, split it evenly between the lines, and
    # centre the whole block. Because the gap is computed rather than typed in,
    # it stays equal even when fit_font shrinks a long name.
    total = 0
    for ln in lines:
        total = total + FONT_H[ln[1]]

    n = len(lines)
    slack = c.height - total
    gap = 0
    if n > 1 and slack > 0:
        gap = slack // (n - 1)

    block = total + gap * (n - 1)
    y = (c.height - block) // 2
    if y < 0:
        y = 0

    for ln in lines:
        c.text(ln[0], x, y, font = ln[1], color = ln[2])
        y = y + FONT_H[ln[1]] + gap

def main(c, ctx):
    # One star per day, and the year shifts where the sequence starts so the
    # same date does not land on the same star every year.
    idx = (ctx.now.yday - 1 + ctx.now.year * 3) % len(STARS)
    name, constel, fact, col = STARS[idx]

    # "154 LY - DRAGONS EYE" is too wide for one line at this size, so split it
    # back into the distance and the description.
    dist = fact
    note = ""
    if " - " in fact:
        parts = fact.split(" - ")
        dist = parts[0]
        note = parts[1]

    c.fill("black")

    # faint starfield + a couple of brighter twinkles
    for p in FIELD:
        c.pixel(p[0], p[1], "#454c66")
    _twinkle(c, 124, 10, "#6a7291")
    _twinkle(c, 3, 15, "#6a7291")

    # the star of the day, on the left, with the app's title captioned under it
    _big_star(c, STAR_CX, col)

    # Title of the panel. Two lines so "STAR OF THE DAY" fits the 38px art
    # column at a readable size; fit_line drops to the smaller font if a build
    # ever changes the metrics.
    lw = 36
    title_col = "#ffd24a"
    tf, t1 = fit_line(c, "STAR OF", ["4x5", "3x4"], lw)
    c.text(t1, STAR_CX, 21, font = tf, color = title_col, align = "center")
    tf, t2 = fit_line(c, "THE DAY", ["4x5", "3x4"], lw)
    c.text(t2, STAR_CX, 27, font = tf, color = title_col, align = "center")

    # four evenly spaced lines on the right
    tx = 40
    tw = c.width - tx - 2

    nf, nt = fit_line(c, name, ["6x8", "5x7", "4x5"], tw)
    cf, ct = fit_line(c, constel, ["5x7", "4x5"], tw)
    df, dt = fit_line(c, dist, ["4x5"], tw)
    ff, ft = fit_line(c, note, ["4x5"], tw)

    _stack(c, tx, [
        [nt, nf, col],
        [ct, cf, "#8fa0c0"],
        [dt, df, "#9fb0cc"],
        [ft, ff, "#c2cad8"],
    ])