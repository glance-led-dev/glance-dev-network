# Sunset Game Day Board - a game day header for a bar or watch party.
# 192x32 app. Three pages slide by: venue name -> board -> kickoff.
# The venue name is a setting, and the week's dates are worked out from
# ctx.now in the viewer's US time zone, so nobody has to edit them weekly.
# Content stays inside the scroll safe zone (x 6..185) with black edges
# so the header reads as its own unit between neighboring apps.

RED = "#E4512F"
ORANGE = "#EF733A"
AMBER = "#F59A3D"
GOLD = "#FBC85A"
SUN = "#FCE29A"
TEAL = "#0E7177"
WAVE = "#4DB8C0"
BROWN = "#6B2312"
LEAF = "#2E9A45"
LEAF2 = "#1F6E2F"
TRUNK = "#8A5A2B"

PALM = [
    "..ll...ll..",
    ".lLLl.lLLl.",
    "l...LlL...l",
    "...lLcLl...",
    "..l..t..l..",
    ".....t.....",
    ".....t.....",
    "......t....",
    "......t....",
    "......t....",
    ".......t...",
    ".......t...",
    ".......t...",
    ".......t...",
]
PALM_LEGEND = {"l": LEAF, "L": LEAF2, "c": BROWN, "t": TRUNK}

PAD = 6

DEFAULT_VENUE = "THE LOUNGE"
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
# Standard-time UTC offsets in minutes; DST is added in offset_minutes().
US_ZONES = {"EASTERN": -300, "CENTRAL": -360, "MOUNTAIN": -420, "PACIFIC": -480}
# First day of the week, 0 = Sunday.
WEEK_START = {"SUN-SAT": 0, "MON-SUN": 1, "TUE-MON": 2}

def days_from_civil(y, m, d):
    # Days since the Unix epoch (Howard Hinnant's algorithm).
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    # [y, m, d] from days since the epoch (Howard Hinnant's algorithm).
    z += 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + (1 if m <= 2 else 0), m, d]

def nth_sunday(y, m, n):
    wd = (days_from_civil(y, m, 1) + 4) % 7   # 1970-01-01 was a Thursday
    return 1 + (7 - wd) % 7 + 7 * (n - 1)

def offset_minutes(ctx):
    # US daylight saving: 2nd Sunday of March to 1st Sunday of November, 2 AM local.
    std = US_ZONES.get(str(ctx.inputs.get("timezone", "EASTERN")).upper(), -300)
    t = ctx.now.unix // 60
    y = ctx.now.year
    start = days_from_civil(y, 3, nth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = days_from_civil(y, 11, nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    return std + 60 if (t >= start and t < end) else std

def week_label(ctx):
    # "NOV 24 - 30  2026", or "NOV 30 - DEC 6  2026" when the week crosses a month.
    today = (ctx.now.unix + offset_minutes(ctx) * 60) // 86400
    first = WEEK_START.get(str(ctx.inputs.get("weekstart", "TUE-MON")).upper(), 2)
    wd = (today + 4) % 7
    start = today - (wd - first) % 7
    a = civil_from_days(start)
    b = civil_from_days(start + 6)
    if a[1] == b[1]:
        return "%s %d - %d  %d" % (MONTHS[a[1] - 1], a[2], b[2], b[0])
    return "%s %d - %s %d  %d" % (MONTHS[a[1] - 1], a[2], MONTHS[b[1] - 1], b[2], b[0])

def band(c, y0, y1, color):
    c.rect(PAD, y0, c.width - 1 - PAD, y1, fill=color)

def scene(c, water_y):
    w = c.width
    mid = w // 2
    c.clear()
    # sunset stripes, like the printed sheet
    band(c, 0, 4, RED)
    band(c, 5, 9, ORANGE)
    band(c, 10, water_y - 9, AMBER)
    band(c, water_y - 8, water_y - 1, GOLD)
    # setting sun
    c.fill_circle(mid, water_y, 9, SUN)
    c.hline(mid - 8, water_y - 3, 17, GOLD)
    c.hline(mid - 9, water_y - 1, 19, GOLD)
    # ocean and waves
    band(c, water_y, 31, TEAL)
    for x in range(PAD + 1, w - PAD - 3, 6):
        c.pixel(x, water_y + 2, WAVE)
        c.pixel(x + 1, water_y + 1, WAVE)
        c.pixel(x + 2, water_y + 2, WAVE)
    # palms inside the safe zone, one on each end
    if w >= 128:
        c.sprite(PALM, PAD + 2, 18, legend=PALM_LEGEND)
        rev = ["".join([r[len(r) - 1 - i] for i in range(len(r))]) for r in PALM]
        c.sprite(rev, w - PAD - 13, 18, legend=PALM_LEGEND)

def font_h(f):
    return int(f.split("x")[1].split("_")[0])

def wide(c, s, f):
    # width including hand-drawn apostrophes (big fonts have none)
    parts = s.split("'")
    w = 0
    for p in parts:
        w += c.text_width(p, font=f)
    return w + 5 * (len(parts) - 1)

def pick_font(c, s, fonts, maxw):
    # largest font from the list that fits within maxw pixels
    for f in fonts:
        if wide(c, s, f) <= maxw:
            return f
    return fonts[-1]

def centered(c, s, y, fonts, color, stroke):
    maxw = c.width - 2 * PAD - 30
    f = pick_font(c, s, fonts, maxw)
    # Hard-clip anything still too wide at the smallest font (long venue names):
    # drop whole words first so "...PELICAN SPORTS BAR" ends at "PELICAN", not "SP".
    for _ in range(len(s)):
        if wide(c, s, f) <= maxw or " " not in s:
            break
        s = s[:s.rfind(" ")].rstrip()
    for _ in range(len(s)):
        if wide(c, s, f) <= maxw:
            break
        s = s[:-1].rstrip()
    x = (c.width - wide(c, s, f)) // 2
    h = font_h(f)
    parts = s.split("'")
    for i in range(len(parts)):
        p = parts[i]
        if p:
            c.text_stroke(p, x, y, font=f, color=color, stroke=stroke, thickness=1)
            x += c.text_width(p, font=f)
        if i < len(parts) - 1:
            mh = max(2, h // 4)
            c.rect(x + 1, y - 1, x + 4, y + mh, fill=stroke)
            c.rect(x + 2, y, x + 3, y + mh - 1, fill=color)
            x += 5

def title(c, ctx):
    scene(c, 23)
    venue = str(ctx.inputs.get("venue", DEFAULT_VENUE)).strip().upper()
    if not venue:
        venue = DEFAULT_VENUE
    centered(c, venue, 3, ["10x16_bold", "10x16", "10x15", "8x12", "7x12", "6x8"], "white", BROWN)

def board(c, ctx):
    week = week_label(ctx)
    scene(c, 18)
    centered(c, "GAME DAY BOARD", 3, ["7x12", "8x12", "7x10", "6x8", "5x7"], "white", BROWN)
    centered(c, week, 21, ["7x10", "6x8", "5x7", "4x7"], "white", "black")

def kickoff(c, ctx):
    scene(c, 18)
    centered(c, "IT'S KICKOFF", 3, ["7x12", "8x12", "7x10", "6x8"], "white", BROWN)
    centered(c, "SOMEWHERE", 21, ["7x10", "6x8", "5x7"], GOLD, "black")
