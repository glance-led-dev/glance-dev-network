# Times Table - a multiplication drill. (128x32)
#
#              7 x 4 = 28
#
# Nine equations to a round, one on screen at a time.
#
#   Normal   one multiplier is drawn per round and held, while the
#            multiplicand walks 1, 2, 3 ... 9. That is a single times table,
#            in order, which is the thing worth learning.
#   Shuffle  both numbers are drawn afresh every step -- nine unrelated
#            equations, duplicates allowed, which is what random means.
#
# The equation is the whole screen. There is no mode label and no position
# counter: on a 128 panel they would cost about a third of the width, and a
# child reading "7 x 4 = 28" does not need to be told it is a times table.
# The mode still shows quietly in the colour of the edge rail.
#
# Nothing is fetched and nothing is stored: the screen is a pure function of
# the clock, so two panels side by side agree, and a panel that reboots
# mid-round picks up where the clock says it should be rather than at 1.

INK = "#08090D"          # near-black ground, per the contrast rule
SIGN = "#9A9AB8"         # the cross and the = bars
HEXCHARS = "0123456789ABCDEF"

NORMAL_RAIL = "#4EA8FF"
SHUFFLE_RAIL = "#E85AA8"

PAD = 8                  # scroll safe zone: neighbours slide past the edges
PER_ROUND = 9
HOLD = 60                # seconds one equation holds -- see the note below

# The cross is deliberately a size DOWN from the digits: at the same size it
# competes with the numbers, which are the content. 16x24 and 16x20 are the
# same WIDTH, so at 128 the taller one costs nothing horizontally and fills
# the panel better; 16x20 sits behind it if anything ever needs the rows.
DIGIT_FONTS = ["16x24", "16x20", "10x16"]
CROSS_FONT = {"16x24": "8x12", "16x20": "8x12", "10x16": "6x8"}
FONT_INK = {"16x24": 24, "16x20": 20, "10x16": 16, "8x12": 12, "6x8": 8}

GAP = 5                  # between the parts of the equation
EQ_W = 12                # equals sign: bar width,
EQ_H = 4                 # bar thickness,
EQ_GAP = 6               # and the space between the two bars

# Drawn when Colors is Random: 24 hues at 15-degree steps around the wheel.
#
# Generated rather than hand-picked, so one rule holds for every entry
# instead of for the ones someone remembered to check: each is that hue at
# 68% saturation and 86% value, backed off only where that would fall below
# a luminance of 78 against the near-black ground of 9.
#
# Not full saturation. At S1.0/V1.0 these are neon -- a wall of pure hue that
# is tiring to look at and makes the grey cross and equals bars, which are
# deliberately quiet, look like a mistake next to it. Backing both down keeps
# every hue distinct while lowering the contrast against the ground.
#
# The luminance floor is what stops the softening going too far: pure blue at
# these settings is far darker than pure yellow, so without a floor the blues
# would fade out of legibility long before the yellows looked calm.
PALETTE = ["#DB4646", "#DB6B46", "#DB9146", "#DBB646", "#DBDB46",
           "#B6DB46", "#91DB46", "#6BDB46", "#46DB46", "#46DB6B",
           "#46DB91", "#46DBB6", "#46DBDB", "#46B6DB", "#4691DB",
           "#466BDB", "#4646DB", "#6B46DB", "#9146DB", "#B646DB",
           "#DB46DB", "#DB46B6", "#DB4691", "#DB466B"]

# HOLD matches `refresh` deliberately. The app is stateless, so the equation
# advances with the wall clock rather than with a counter -- and if HOLD were
# shorter than the render interval the sequence would skip rather than walk,
# turning a 1..9 walk into 1, 4, 7, 1, 4, 7. Lower both together to speed the
# drill up; a full round takes PER_ROUND * HOLD seconds either way.


def _hexval(ch):
    return HEXCHARS.find(ch.upper())


def _hex2(v):
    return HEXCHARS[v // 16] + HEXCHARS[v % 16]


def lift(bg):
    """A colour lightened until it reads on the near-black ground.

    Only the Custom colours need this -- the palette is chosen bright -- but
    a custom pick is the user's to make, and a dark one would draw a digit
    that is simply not there. Anything below a luminance of 70 is scaled up
    to roughly 110, which keeps the hue and spends only the brightness needed
    to see it.
    """
    h = str(bg).replace("#", "")
    if len(h) != 6:
        return bg
    for i in range(6):
        if _hexval(h[i]) < 0:
            return bg
    r = _hexval(h[0]) * 16 + _hexval(h[1])
    g = _hexval(h[2]) * 16 + _hexval(h[3])
    b = _hexval(h[4]) * 16 + _hexval(h[5])
    lum = (299 * r + 587 * g + 114 * b) // 1000
    if lum >= 70:
        return bg
    if lum < 8:
        return "#8A8AA8"
    r = min(255, r * 110 // lum)
    g = min(255, g * 110 // lum)
    b = min(255, b * 110 // lum)
    return "#" + _hex2(r) + _hex2(g) + _hex2(b)


def mix(n):
    """A 32-bit avalanche hash (the Murmur3 finaliser).

    Starlark has no random module, and the drill has to be a pure function of
    the clock, so randomness comes from hashing the step number. A plain LCG
    is not good enough here: consecutive seeds are exactly the input this
    gets, and with an LCG 73% of steps advanced the first operand by exactly
    one while the second cycled with a period of three. Both were plainly
    visible on the panel. This one keeps consecutive seeds uncorrelated.
    """
    x = n % 4294967296
    x = ((x ^ (x >> 16)) * 2246822507) % 4294967296
    x = ((x ^ (x >> 13)) * 3266489909) % 4294967296
    return x ^ (x >> 16)


def pick(seed):
    """A digit 1-9 from `seed`."""
    return mix(seed) % 9 + 1


def three_colors(seed):
    """Three DIFFERENT palette entries, drawn from `seed`.

    A partial Fisher-Yates over the index list, which guarantees the three
    are distinct. Drawing each independently would collide roughly one time
    in eight across three picks from twenty-four, and two numbers in one
    equation sharing a colour reads as a hint that they are related -- the
    one thing the colours must not imply.
    """
    n = len(PALETTE)
    idx = []
    for i in range(n):
        idx.append(i)
    for s in range(3):
        r = s + mix(seed * 3 + s) % (n - s)
        tmp = idx[s]
        idx[s] = idx[r]
        idx[r] = tmp
    return [PALETTE[idx[0]], PALETTE[idx[1]], PALETTE[idx[2]]]


def is_shuffle(ctx):
    return str(ctx.inputs.get("mode", "Normal")).strip().lower() == "shuffle"


def equation(ctx):
    """[multiplier, multiplicand, step number]."""
    step = ctx.now.unix // HOLD
    idx = step % PER_ROUND

    if is_shuffle(ctx):
        # Two seeds off one step, both hashed, so neither tracks the other.
        return [pick(step * 2 + 1), pick(step * 2 + 2), step]

    # Normal: the multiplier is drawn from the ROUND, not the step, so it
    # holds for all nine while the multiplicand counts up.
    return [pick((step // PER_ROUND) * 7919 + 3), idx + 1, step]


def colors(ctx, step):
    """[multiplier, multiplicand, product] colours."""
    if str(ctx.inputs.get("colormode", "Random")).strip().lower() == "custom":
        return [lift(str(ctx.inputs.get("multcolor", "#FFFFFF")).strip()),
                lift(str(ctx.inputs.get("candcolor", "#6FB7E8")).strip()),
                lift(str(ctx.inputs.get("prodcolor", "#FFD24A")).strip())]
    # Seeded well away from the operand seeds, so the colour of an equation
    # carries no information about its numbers.
    return three_colors(step * 31337 + 11)


def equals(c, x, cy, color):
    """An equals sign, drawn rather than typed, centred on `cy`.

    Not one of the 52 bundled fonts has an "=" glyph, and a missing glyph is
    drawn as NOTHING rather than as a box -- "9 X 9 = 81" measures exactly as
    wide as "9 X 9  81", and the panel would show the gap with no complaint
    from check, validate or the render.
    """
    top = cy - (2 * EQ_H + EQ_GAP) // 2
    c.rect(x, top, x + EQ_W - 1, top + EQ_H - 1, fill = color)
    c.rect(x, top + EQ_H + EQ_GAP, x + EQ_W - 1,
           top + 2 * EQ_H + EQ_GAP - 1, fill = color)


def table(c, ctx):
    c.fill(INK)
    c.rect(0, 0, 1, c.height - 1,
           fill = SHUFFLE_RAIL if is_shuffle(ctx) else NORMAL_RAIL)

    eq = equation(ctx)
    a = str(eq[0])
    b = str(eq[1])
    p = str(eq[0] * eq[1])
    col = colors(ctx, eq[2])

    avail = c.width - 2 * PAD
    font = DIGIT_FONTS[len(DIGIT_FONTS) - 1]
    for f in DIGIT_FONTS:
        xf = CROSS_FONT.get(f, "8x12")
        w = (c.text_width(a, f) + GAP + c.text_width("X", xf) + GAP
             + c.text_width(b, f) + GAP + EQ_W + GAP + c.text_width(p, f))
        if w <= avail:
            font = f
            break

    xf = CROSS_FONT.get(font, "8x12")
    wa = c.text_width(a, font)
    wx = c.text_width("X", xf)
    wb = c.text_width(b, font)
    wp = c.text_width(p, font)
    total = wa + GAP + wx + GAP + wb + GAP + EQ_W + GAP + wp

    h = FONT_INK.get(font, 24)
    y = (c.height - h) // 2
    cy = y + h // 2                       # the line every part centres on
    x = PAD + (avail - total) // 2

    c.text(a, x, y, font = font, color = col[0])
    x += wa + GAP
    c.text("X", x, cy - FONT_INK.get(xf, 12) // 2, font = xf, color = SIGN)
    x += wx + GAP
    c.text(b, x, y, font = font, color = col[1])
    x += wb + GAP
    equals(c, x, cy, SIGN)
    x += EQ_W + GAP
    c.text(p, x, y, font = font, color = col[2])
