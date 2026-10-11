# Event Reminder - how many days until the next time something happens.
# (192x32)
#
# Built on event-milestone. Same panel, same measured layout -- but the
# reminder is a SCHEDULE, not a date: a first occurrence plus a cadence (every
# day, every 2, 3 or 4 days, weekly, every 2 weeks, monthly, quarterly,
# semi-yearly, yearly), and the count is always to the NEXT one.
#
#   |+--------+ DAYS TO <TITLE>
#   ||  theme |                                    [month][week][day]
#   ||  32x32 | <count> DAYS                                [cadence]
#   |+--------+                                           [next date]
#
# An accent rail 2 px wide down the left edge, the theme icon filling the
# full height beside it, and everything else in the column between the icon
# and the right edge: the title across its top, the count under it on the
# left, and a right-hand column of lamps, cadence and next date.
#
# The cadence sits over the next date -- "EVERY 2 WEEKS" is the one thing
# about a reminder the count alone cannot tell you -- and the three lamps top
# the column, each answering its own question about the next one: is it this
# calendar month, this Monday-to-Sunday week, today? A week can straddle a
# month end, so the week lamp can be lit with the month lamp off -- on Mon 28
# Sep, a reminder due Thu 1 Oct is this week but not this month. See
# lamp_states().
#
# The lamps are free here: at 23px they are narrower than every cadence label,
# so the right column reserves the same width either way and the count keeps
# its size.
#
# The panel is drawn edge to edge -- the rail IS the left edge -- rather than
# inside the scroll kit's 8 px safe zone, so the icon can take all 32 rows.
#
# Day-based cadences step from the first occurrence in fixed strides, so the
# schedule never drifts. Monthly, quarterly, semi-yearly and yearly step whole
# months from the first occurrence and land on the same day-of-month (or
# the last day the month has -- a reminder set for the 31st still fires in
# February, on the 28th). See next_due().
#
# The first date is declared `date`, which the Glance app's picker limits to
# today and later. It still goes past as the schedule runs -- that is the
# point of a repeat -- so a past first date is not an error: next_due() steps
# on from it to the next occurrence.
#
# Pure date arithmetic from ctx.now. Nothing is fetched.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

DIGITS = "0123456789"
HEXCHARS = "0123456789ABCDEF"

INK = "#08090D"          # near-black ground, per the contrast rule
DIM = "#5E5E7A"          # the cadence
MID = "#9A9AB8"          # secondary rows
STRUCT = "#1E2030"       # the unlit lamps

# The two colour dropdowns, count and accent, share this list: nine chosen by
# the app's owner, the same set event-milestone uses, in dropdown order.
#
# They are used as given, with no brightening, so their luminance against INK
# is worth knowing when picking one. Pink (#FF0097) is the dimmest at 93, then
# red at 99; the rest sit between 169 and 249. All clear 70, below which text
# starts to disappear on the panel.
COLORS = {
    "red": "#FF2121",
    "orange": "#F2BE45",
    "yellow": "#FFF143",
    "green": "#AFDD22",
    "cyan": "#25F8CB",
    "blue": "#44CEF6",
    "purple": "#CCA4E3",
    "pink": "#FF0097",
    "white": "#F2FDFF",
}

RAIL_W = 2               # the accent rail down the left edge
ICON = 32                # the theme icon: a 32x32 tile beside the rail
LEFT = RAIL_W + ICON + 3             # content column: icon, 3 px gap ...
RIGHT_EDGE = 192 - 3                 # ... to 2 px short of the right edge
BAND = 8                 # lower level starts here, below the title row

# The count block. 16x24 is deliberately NOT in the ladder: it is exactly as
# tall as the band, so it lands one row under the title with nothing below.
# Capping at 16x20 leaves two rows of air either side once the ink is centred.
HERO_FONTS = ["16x20", "10x16", "8x12"]
UNIT_FONT = "8x12"
UNIT_GAP = 6             # number to unit
CLEAR = 4                # unit to the right-hand column

# The right-hand column, right-aligned at RIGHT_EDGE, three 5-row items with
# three clear rows between each: lamps, cadence, next date.
MARKS_Y = 9              # lamps: rows 9-13
CADENCE_Y = 17           # cadence: rows 17-21
DATE_Y = 25              # next date: rows 25-29

# The three lamps: 5 + 4 + 5 + 4 + 5 = 23. They cost the count nothing --
# every cadence label is already wider than 23 at 4x5, so the right column
# reserves that much either way.
LAMP_SPAN = 23
MONTH_ON = "#E87722"     # orange: the next one lands this calendar month
WEEK_ON = "#3FA34D"      # green:  ...and inside this Monday-to-Sunday week
DAY_ON = "#2160AF"       # navy:   ...and it is today

# Ink heights, since Starlark cannot measure a glyph. For every face here the
# ink fills the full box.
FONT_INK = {"16x20": 20, "10x16": 16, "8x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# Cadence: dropdown label (lowercased) -> [stride in days, label on the panel].
# A stride of 0 means "calendar": the stride is whole months, from MONTH_STRIDE.
CADENCE = {
    "every day": [1, "EVERY DAY"],
    "every 2 days": [2, "EVERY 2 DAYS"],
    "every 3 days": [3, "EVERY 3 DAYS"],
    "every 4 days": [4, "EVERY 4 DAYS"],
    "weekly": [7, "WEEKLY"],
    "every 2 weeks": [14, "EVERY 2 WEEKS"],
    "monthly": [0, "MONTHLY"],
    "quarterly": [0, "QUARTERLY"],
    "semi-yearly": [0, "SEMI-YEARLY"],
    "yearly": [0, "YEARLY"],
}
MONTH_STRIDE = {"monthly": 1, "quarterly": 3, "semi-yearly": 6, "yearly": 12}


def ink_height(font):
    return FONT_INK.get(font, 8)


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm).

    Subtracting two of these is an exact day count. A (year diff * 365)
    approximation drifts by a day for every Feb 29 in between, which for an
    event a few decades back is a visibly wrong number.
    """
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)


def month_days(y, m):
    if m == 2:
        return 29 if is_leap(y) else 28
    return [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]


def parse_date(s):
    """A date setting -> [y, m, d], or None when it is unusable.

    Starlark has no exceptions, so the value is checked by hand before it is
    used. The picker sends a full ISO stamp and it does not arrive intact: the
    render descriptor is colon-separated at the top level
    (GDN:W:H:app:pages:ttl:inputs), so the time's own colons end the value and
    it is cut at the first one -- "1969-07-20T01:12:57.000Z" is delivered as
    "1969-07-20T01".

    Reducing to digits and taking the first eight accepts the full stamp, that
    truncated form, and a plain YYYY-MM-DD alike. The day always survives the
    cut because it sits before the "T".
    """
    ds = ""
    t = str(s)
    for i in range(len(t)):
        if DIGITS.find(t[i]) >= 0:
            ds = ds + t[i]
    if len(ds) < 8:
        return None

    y = int(ds[0:4])
    m = int(ds[4:6])
    d = int(ds[6:8])
    if y < 1000 or m < 1 or m > 12 or d < 1 or d > month_days(y, m):
        return None
    return [y, m, d]


def _hexval(ch):
    return HEXCHARS.find(ch.upper())


def civil_from_days(z):
    """The inverse of days_from_civil: epoch day count -> [y, m, d]."""
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + 1 if m <= 2 else y, m, d]


# ---------------------------------------------------------------- theme art
# Every theme is a 32x32 PNG in assets/, named after the theme with spaces as
# hyphens, drawn 1:1 into the icon tile. See draw_theme().

# Every theme the dropdown offers, by name.
THEMES = [
    "walking", "dumbbell", "fishing", "soccer", "football", "basketball",
    "badminton", "hockey", "skiing", "billiards", "darts", "golf", "chess",
    "frisbee", "archery", "bicycle", "climbing", "trash", "hospital", "school",
    "restaurant", "church", "birthday", "ring",
]



def _hex2(v):
    return HEXCHARS[v // 16] + HEXCHARS[v % 16]


def lift(bg):
    """A colour, lightened until it reads on the near-black ground.

    Only the lamp rims use it (see lamp()); every COLORS entry is already
    bright enough. Anything below a luminance of 70 is scaled up to roughly
    110, which keeps the hue and spends only the brightness needed to see it.
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
        return "#8A8AA8"       # near-black accent has no hue worth keeping
    r = min(255, r * 110 // lum)
    g = min(255, g * 110 // lum)
    b = min(255, b * 110 // lum)
    return "#" + _hex2(r) + _hex2(g) + _hex2(b)


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw`. Nothing in the drawing API
    clips -- a glyph past the edge is silently dropped -- so an unbounded
    string is cut here, deliberately, before it is drawn."""
    s = str(text)
    if c.text_width(s, font) <= maxw:
        return s
    for n in range(len(s), 0, -1):
        if c.text_width(s[0:n], font) <= maxw:
            return s[0:n]
    return ""


def clip_words(c, text, font, maxw):
    """clip(), but backed up to the last whole word -- unless that costs more
    than 30% of what fit. An event called "THE DAY THE MUSIC DIED" cut to "THE
    DAY THE" has lost the words that identify it; an obviously-clipped "THE DAY
    THE MUSIC DIE" reads better than a tidy cut that says nothing."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[0:sp]
    return t


def fit(c, text, fonts, maxw):
    """[font, clipped text] for the largest listed font that fits.

    text_fit shrinks the font but still draws when even its smallest option
    overflows, so the clip is applied here rather than trusted to the helper.
    """
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]


# ----------------------------------------------------------------- schedule

def norm_cadence(value):
    t = str(value).strip().lower()
    if t in CADENCE:
        return t
    return "every 2 days"


def norm_theme(value):
    """A theme setting, lowercased, against the themes that actually exist."""
    t = str(value).strip().lower()
    if t in THEMES:
        return t
    return "football"


def draw_theme(c, theme):
    """Draw the theme's PNG in the icon tile beside the rail.

    Every theme is a 32x32 PNG in assets/, named after the theme with spaces
    as hyphens ("torii gate" -> torii-gate.png), drawn 1:1.
    """
    if theme not in THEMES:
        theme = "football"
    c.image(theme.replace(" ", "-") + ".png", RAIL_W, 0)


def color_of(value, fallback):
    """A colour dropdown pick -> its hex, or the `fallback` entry's hex."""
    return COLORS.get(str(value).strip().lower(), COLORS[fallback])


def accent_of(ctx):
    return color_of(ctx.inputs.get("accent", "Blue"), "blue")


def reminder_of(ctx):
    """The configured reminder, or None until its DATE parses.

    A blank title falls back to the theme name, so a date and a theme alone
    still read as a reminder.
    """
    ymd = parse_date(ctx.inputs.get("date1", ""))
    if ymd == None:
        return None
    theme = norm_theme(ctx.inputs.get("theme1", ""))
    name = str(ctx.inputs.get("title1", "")).strip().upper()
    if name == "":
        name = theme.upper()
    return {"ymd": ymd, "cadence": norm_cadence(ctx.inputs.get("repeat1", "")),
            "theme": theme, "name": name,
            "numcolor": color_of(ctx.inputs.get("numcolor1", "Green"), "green")}


def next_due(ctx, ymd, cadence):
    """[days until the next occurrence, its date as [y, m, d]].

    Day strides count from the first occurrence in fixed steps, so a "every 3
    days" reminder started on a Monday stays on the same footing forever
    rather than drifting with each render. Calendar cadences land on the same
    day-of-month; a day the month does not have clamps to its last day.

    Before the first occurrence the answer is simply the first occurrence --
    a reminder set to start next Tuesday has nothing to repeat yet.
    """
    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    start = days_from_civil(ymd[0], ymd[1], ymd[2])
    if today <= start:
        return [start - today, ymd]

    stride = CADENCE[cadence][0]
    if stride > 0:
        k = (today - start + stride - 1) // stride
        nxt = start + k * stride
        return [nxt - today, civil_from_days(nxt)]

    # Calendar cadences step whole months from the first occurrence's month:
    # 1 monthly, 3 quarterly, 6 semi-yearly, 12 yearly. Months are counted
    # from year 0 so the stride crosses year ends without special cases. The
    # step at or before this month may already have passed this month, so the
    # one after it is tried too; that one is always in a later month.
    stride = MONTH_STRIDE.get(cadence, 1)
    base = ymd[0] * 12 + ymd[1] - 1
    k = (ctx.now.year * 12 + ctx.now.month - 1 - base) // stride
    for i in range(2):
        t = base + (k + i) * stride
        y = t // 12
        m = t % 12 + 1
        d = min(ymd[2], month_days(y, m))
        cand = days_from_civil(y, m, d)
        if cand >= today:
            return [cand - today, [y, m, d]]
    return [0, ymd]


def short_date(ymd):
    """"SEP 14" -- the year is noise on something that repeats."""
    return "%s %d" % (MONTHS[ymd[1] - 1], ymd[2])


# ------------------------------------------------------------------- chrome

def rail(c, color):
    """The accent rail down the left edge."""
    c.rect(0, 0, RAIL_W - 1, c.height - 1, fill = color)


def title_row(c, event, head, event_color = "white"):
    """The upper level: "<HEAD><EVENT>" across the content column.

    `head` is "DAYS SINCE " or "DAYS TO " -- the caller decides, because only
    it knows which side of today the date falls on.

    `event_color` is the reminder's own colour, shared with its count, so the
    name and the number read as one reminder while the fixed head stays neutral.

    Drawn from y=0 so the row ends at 6 and the lower level can start at 8
    with a clear row between them.

    The head is the fixed part, so only the event name is allowed to shrink or
    clip -- cutting the phrase itself would leave "DAYS SIN".
    """
    c.text(head, LEFT, 1, font = "4x5", color = MID)
    x = LEFT + c.text_width(head, "4x5")
    avail = RIGHT_EDGE + 1 - x

    # The name gets a font ladder, not just a clip: dropping a size keeps every
    # letter, and clip_words is still there for names no size fits.
    nf = fit(c, event, ["5x7", "4x5"], avail)
    font = nf[0]
    c.text(clip_words(c, event, font, avail), x,
           0 if font == "5x7" else 1, font = font, color = event_color)


def message(c, head, sub, head_color = "#E8B04A"):
    """The one screen every non-counting state shares.

    A 16x24 head fills the band and leaves nowhere below it for the sub, which
    put the instruction ABOVE the thing it explains -- it read as a caption for
    the row above. 16x20 costs four pixels of head and buys the sub its proper
    place underneath.
    """
    w = c.width - 2 * (RAIL_W + 2)
    c.text(clip(c, head, "16x20", w), c.width // 2, 4,
           font = "16x20", color = head_color, align = "center")
    if sub != "":
        c.text(clip(c, sub, "4x5", w), c.width // 2, 26,
               font = "4x5", color = MID, align = "center")


def lamp(c, x, y, on, color):
    """One 5x5 lamp at (x, y).

    Lit, the square is filled with its colour and rimmed with lift() of that
    same colour. All three are bright enough that lift() is the identity, so
    they draw as plain solid blocks and the rim costs nothing -- it is a
    guard, not a style: swap in a colour too dark for the ground and the lamp
    keeps a visible edge instead of vanishing into it.
    """
    if on:
        c.rect(x, y, x + 4, y + 4, fill = color, outline = lift(color))
    else:
        c.rect(x, y, x + 4, y + 4, outline = STRUCT)


def lamp_states(ctx, due_ymd):
    """[month, week, day] for the three lamps, each checked on its own.

    month: the next occurrence falls in this calendar month.
    week:  it falls in this Monday-to-Sunday week.
    day:   it is today.

    They are independent rather than a cascade, because a week can straddle
    a month end: on Mon 28 Sep, a reminder due Thu 1 Oct is this week but not
    this month, and gating the week lamp on the month kept it dark. Day still
    implies both of the others -- today is in today's month and week.

    `due_ymd` is the NEXT occurrence, so it is never earlier than today and
    "this week" only has to check the Sunday end. The year is checked as well
    as the month: a yearly reminder whose next turn is next September must
    not light the month lamp all through this one.
    """
    month = due_ymd[0] == ctx.now.year and due_ymd[1] == ctx.now.month
    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    monday = today - ctx.now.weekday          # ctx.now.weekday: 0 = Monday
    d = days_from_civil(due_ymd[0], due_ymd[1], due_ymd[2])
    week = d <= monday + 6
    day = d == today
    return [month, week, day]


def marks(c, due_ymd, ctx):
    """The three lamps, at the top of the right-hand column."""
    st = lamp_states(ctx, due_ymd)
    mx = RIGHT_EDGE + 1 - LAMP_SPAN
    lamp(c, mx, MARKS_Y, st[0], MONTH_ON)
    lamp(c, mx + 9, MARKS_Y, st[1], WEEK_ON)
    lamp(c, mx + 18, MARKS_Y, st[2], DAY_ON)


# --------------------------------------------------------------------- page

def reminder(c, ctx):
    ink_accent = accent_of(ctx)

    c.fill(INK)
    ev = reminder_of(ctx)

    if ev == None:
        rail(c, "#E8B04A")
        message(c, "SET A DATE", "PICK WHEN IT FIRST HAPPENS")
        return

    due = next_due(ctx, ev["ymd"], ev["cadence"])
    n = due[0]

    num_ink = ev["numcolor"]

    rail(c, ink_accent)
    draw_theme(c, ev["theme"])
    title_row(c, ev["name"], "DAYS TO ", num_ink)

    # The right-hand column: lamps, then the cadence, then the next date.
    label = CADENCE[ev["cadence"]][1]
    date = short_date(due[1])
    marks(c, due[1], ctx)
    c.text(label, RIGHT_EDGE, CADENCE_Y, font = "4x5", color = DIM,
           align = "right")
    c.text(date, RIGHT_EDGE, DATE_Y, font = "4x5", color = MID,
           align = "right")

    # The count clears whichever of the three is widest. Measuring only the
    # cadence would let the number run under the lamps on a short label like
    # WEEKLY, which is 30px against the lamps' 23.
    col = max(LAMP_SPAN, c.text_width(label, "4x5"), c.text_width(date, "4x5"))
    limit = RIGHT_EDGE + 1 - col - CLEAR

    # Every state takes the reminder's own colour. Leaving TODAY on the accent
    # meant a reminder set to pink turned blue on the one day it mattered.
    if n == 0:
        word = "TODAY"
        wcol = num_ink
        unit = ""
    else:
        word = fmt.commas(n)
        wcol = num_ink
        unit = "DAY" if n == 1 else "DAYS"

    x = LEFT
    uw = c.text_width(unit, UNIT_FONT) if unit != "" else 0
    ugap = UNIT_GAP if unit != "" else 0

    hf = fit(c, word, HERO_FONTS, limit - x - ugap - uw)
    hw = c.text_width(hf[1], hf[0])

    hh = ink_height(hf[0])
    hy = BAND + (c.height - BAND - hh) // 2
    c.text(hf[1], x, hy, font = hf[0], color = wcol)

    if unit != "":
        uy = hy + hh - ink_height(UNIT_FONT)
        c.text(unit, x + hw + UNIT_GAP, uy, font = UNIT_FONT, color = MID)
