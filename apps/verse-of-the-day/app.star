# Verse of the Day — one anchor verse per day, chosen by the date.
#
# The shelf is small on purpose: these are the verses that carried one
# man out of the pit, not a random draw from the whole Bible. Each
# entry is a single short clause in public-domain (KJV) wording — all
# that honestly fits a 64x32 panel — with its reference above it.
#
# Rotation is deterministic: day-of-year modulo the shelf length. No
# network, no state: every render on the same date shows the same
# verse, and the verse changes at midnight, not at refresh.

GOLD = "#E8B33A"
WHITE = "#EDEFF6"
BG = "#08090D"

# [reference, clause] — KJV wording, kept to one clause so the words
# stay big enough to read across a room.
VERSES = [
    ["PSALM 88:13", "UNTO THEE HAVE I CRIED, O LORD"],
    ["PSALM 91:2", "HE IS MY REFUGE AND MY FORTRESS"],
    ["2 COR 5:17", "HE IS A NEW CREATURE"],
    ["PSALM 94:19", "THY COMFORTS DELIGHT MY SOUL"],
    ["MATT 11:28", "I WILL GIVE YOU REST"],
    ["LAM 3:23", "GREAT IS THY FAITHFULNESS"],
    ["ISAIAH 58:11", "THE LORD SHALL GUIDE THEE CONTINUALLY"],
    ["JAMES 1:5", "LET HIM ASK OF GOD"],
]

# Row pitch per face: glyph rows plus breathing room (as measured in
# rss-headlines). The block below picks the largest face whose wrap
# fits the rows available.
PITCH = {"5x7": 8, "4x5": 7, "3x4": 5}
FACES = ["5x7", "4x5", "3x4"]


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def split_long(c, word, font, maxw):
    """A word wider than the column, chopped into pieces that fit."""
    parts = []
    rest = word
    for _i in range(24):
        if c.text_width(rest, font) <= maxw:
            parts.append(rest)
            return parts
        cut = 1
        for k in range(len(rest), 0, -1):
            if c.text_width(rest[:k], font) <= maxw:
                cut = k
                break
        parts.append(rest[:cut])
        rest = rest[cut:]
        if rest == "":
            return parts
    parts.append(rest)
    return parts


def wrap(c, text, font, maxw):
    """Greedily pack words into lines no wider than maxw."""
    lines = []
    cur = ""
    for raw in text.split(" "):
        if raw == "":
            continue
        for w in split_long(c, raw, font, maxw):
            trial = w if cur == "" else cur + " " + w
            if c.text_width(trial, font) <= maxw:
                cur = trial
            else:
                if cur != "":
                    lines.append(cur)
                cur = w
    if cur != "":
        lines.append(cur)
    return lines


def verse(c, ctx):
    doy = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day) - \
        days_from_civil(ctx.now.year, 1, 1)
    pick = VERSES[doy % len(VERSES)]
    ref = pick[0]
    text = pick[1]

    c.fill(BG)
    c.text_fit(ref, c.width // 2, 1, ["5x7", "4x5"], color = GOLD,
               align = "center", maxw = c.width - 2)

    # Words get the rest of the panel: y 10..31, centred as a block.
    top = 10
    height = c.height - top - 1
    face = FACES[len(FACES) - 1]
    lines = []
    for f in FACES:
        rows = (height + 1) // PITCH[f]
        if rows < 1:
            continue
        cand = wrap(c, text, f, c.width - 4)
        if len(cand) <= rows:
            face = f
            lines = cand
            break
    if not lines:
        face = FACES[len(FACES) - 1]
        rows = (height + 1) // PITCH[face]
        lines = wrap(c, text, face, c.width - 4)[:rows]
    used = len(lines) * PITCH[face] - 1
    y = top + (height - used) // 2
    for i in range(len(lines)):
        c.text(lines[i], c.width // 2, y + i * PITCH[face], font = face,
               color = WHITE, align = "center")
