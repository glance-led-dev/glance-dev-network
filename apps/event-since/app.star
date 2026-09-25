# Event Since - how long since something happened. (192x32)
#
# A sibling of event-milestone with the same drawing, themes, colours and
# lamps; the difference is the picker. That app counts DOWN to a future date,
# this one counts UP from a past one.
#
# One event per install -- add the app again to track another.
#
#   |+--------+ DAYS SINCE <EVENT>
#   ||  theme |                                    [month][week][day]
#   ||  32x32 | <count> DAYS
#   |+--------+                                         [event date]
#
# An accent rail 2 px wide down the left edge, the theme icon filling the
# full height beside it, and everything else in the column between the icon
# and the right edge: the title across its top, the count under it on the
# left, the anniversary lamps and the date stacked on the right.
#
# Past dates and today only. On the day itself the panel shows TODAY.
#
# The date input is declared `date-past`, which caps the Glance app's picker
# at today. The Glance app gives each picker only one direction -- a `date`
# input refuses days before today -- which is why past and future dates live
# in two separate apps. A future date that arrives anyway (a value saved by
# hand, or through the API) gets the set-a-date screen rather than a count:
# see since().
#
# The count takes the largest face that still clears the lamp-and-date column,
# and the ladder drops it a size for a number long enough to need the room.
#
# Vertically the count is CENTRED in the band and the unit sits on its
# baseline -- not hung from BAND with the unit on its own centre, which put the
# number one row under the title with eight dead rows beneath it and left
# "DAYS" floating two rows low. See HERO_FONTS and ink_height().
#
# Fifty-four themes, each a PNG in assets/; see THEMES and draw_theme().
#
# The three lamps under the date are the anniversary at a glance, as a strict
# cascade: orange for the whole of the event's month, green once the
# anniversary is in this Monday-to-Sunday week, navy on the day itself. Each
# narrows the one before it, so the lit run always starts at the left and its
# LENGTH is the reading. Off is drawn as an outline, not left blank -- see
# marks() and lamp_states().
#
# Colour is the user's: `numcolor` tints the event's name and count, and
# `accent` dresses the rail. Both are dropdowns over the named
# LED palette (see COLORS), resolved by color_of(). A hex saved back when these
# were colour pickers still resolves, and still goes through lift().
#
# Pure date arithmetic from ctx.now. Nothing is fetched, so there is no stale
# or empty screen to design around -- only a date the user has not set yet.
#
# The panel is drawn edge to edge -- the rail IS the left edge -- rather than
# inside the scroll kit's 8 px safe zone, so the icon can take all 32 rows.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

DIGITS = "0123456789"
HEXCHARS = "0123456789ABCDEF"

INK = "#08090D"          # near-black ground, per the contrast rule
MID = "#9A9AB8"          # secondary rows
STRUCT = "#1E2030"       # the unlit lamps

RAIL_W = 2               # the accent rail down the left edge
ICON = 32                # the theme icon: a 32x32 tile beside the rail
LEFT = RAIL_W + ICON + 3             # content column: icon, 3 px gap ...
RIGHT_EDGE = 192 - 3                 # ... to 2 px short of the right edge
BAND = 8                 # lower level starts here, below the title row

# The anniversary lamps: three 5x5 blocks, 4px apart, right-aligned over the
# date. 5 + 4 + 5 + 4 + 5 = 23 wide, ending at RIGHT_EDGE (see marks_x).
# Left to right they narrow: the month, the week, then the day itself.
MONTH_ON = "#E87722"     # orange: today is in the event's month
WEEK_ON = "#3FA34D"      # green:  the anniversary falls in this week
DAY_ON = "#2160AF"       # navy:   today is the anniversary itself
#
# MONTH_ON is the brand orange exactly. DAY_ON is NOT the brand navy #0C2340,
# which cannot be used here: its luminance is 31 against a ground of 9 and an
# unlit outline of 33, so it renders darker than an unlit lamp and reads
# inverted. #2160AF is that same navy at a brightness the panel can show --
# the channel ratios are 0.19:0.55:1.00 either way, so it is the same hue,
# lifted, not a different colour.
MARKS_Y = 11             # lamps: rows 11-15, just under the title
DATE_Y = 25              # date: rows 25-29, the foot of the column
DATE_FONT = "4x5"

# The count block. 16x24 is deliberately NOT in the ladder: it is exactly as
# tall as the band, so it lands one row under the title with nothing below,
# which reads top-heavy. Capping at 16x20 leaves two rows of air either side
# once the ink is centred. The gaps are 6 rather than 8 to buy back the three
# pixels that were pushing a five-digit count down to 10x16.
HERO_FONTS = ["16x20", "10x16", "8x12"]
UNIT_FONT = "6x8"        # not 8x12: see the note on LAMP_SPAN
UNIT_GAP = 6             # number to unit
CLEAR = 4                # unit to the lamp-and-date column
LAMP_SPAN = 23           # three 5x5 lamps, 4px apart
#
# The third lamp costs the count 9px of width, which is exactly enough to push
# a five-digit figure off 16x20 and down to 10x16. The unit gives that back
# instead: "DAYS" is 35px at 8x12 and 27px at 6x8, and the number is the hero
# -- shrinking the label it is already sitting next to costs far less than
# shrinking the figure itself.

# Ink heights, since Starlark cannot measure a glyph. Verified against
# gdn/data/fonts.json: for every face here the ink fills the full box, so
# these are the box heights -- but the number is what the layout centres on,
# so it is named rather than assumed.
FONT_INK = {"16x20": 20, "10x16": 16, "8x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}


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

    The value is split into its runs of digits and the first three are read as
    year, month and day. That accepts the full stamp, that truncated form, and
    a plain YYYY-MM-DD alike -- the day always survives the cut because it sits
    before the "T" -- and it does not assume a four-digit year, so "999-06-15"
    reads as the year 999 rather than failing for want of an eighth digit.
    A single unbroken run is taken as compact YYYYMMDD.

    Any year from 1 is accepted. The arithmetic is proleptic Gregorian, so a
    date before 1582 counts days on today's calendar, not the one in use then.
    """
    groups = []
    run = ""
    t = str(s)
    for i in range(len(t)):
        if DIGITS.find(t[i]) >= 0:
            run = run + t[i]
        elif run != "":
            groups.append(run)
            run = ""
    if run != "":
        groups.append(run)

    if len(groups) >= 3:
        ys, ms, dss = groups[0], groups[1], groups[2]
    elif len(groups) == 1 and len(groups[0]) >= 8:
        ys, ms, dss = groups[0][0:4], groups[0][4:6], groups[0][6:8]
    else:
        return None
    if len(ys) > 4 or len(ms) > 2 or len(dss) > 2:
        return None

    y = int(ys)
    m = int(ms)
    d = int(dss)
    if y < 1 or m < 1 or m > 12 or d < 1 or d > month_days(y, m):
        return None
    return [y, m, d]


def _hexval(ch):
    return HEXCHARS.find(ch.upper())


# ---------------------------------------------------------------- theme art
# Every theme is a PNG in assets/, named after the theme with spaces as
# hyphens. The pictures are 32x32, drawn 1:1 into the icon tile. The flags are
# the world-countries set, 40 wide at each country's own proportions, so they
# are scaled to the tile's width and centred in its height. See draw_theme().

# Every theme the dropdown offers, in dropdown order.
THEMES = [
    "wedding", "birthday", "graduation", "house", "car", "bicycle", "yacht",
    "departure", "arrival", "tree", "flower", "beach", "mountains",
    "torii gate", "pagoda", "heart", "couple", "couple blue", "couple pink",
    "girl", "boy", "campfire", "helicopter", "paraglider", "fishing",
    "running", "gold medal", "silver medal", "bronze medal", "soccer",
    "football", "basketball", "badminton", "volleyball", "hockey", "skiing",
    "chess", "golf", "trophy", "podium",
    # Nations
    "usa", "uk", "uae", "south korea", "russia", "japan", "italy", "india",
    "germany", "france", "china", "canada", "brazil", "australia",
]

# Flags, as the [w, h] they are drawn at. Starlark cannot read a PNG's size,
# so it is written down here: 40 wide scaled to 32, keeping each flag's own
# proportions.
FLAG_SIZE = {
    "china": [32, 22],       # 40x27
    "usa": [32, 17],         # 40x21
    "russia": [32, 22],      # 40x27
    "uk": [32, 16],          # 40x20
    "france": [32, 22],      # 40x27
    "germany": [32, 19],     # 40x24
    "japan": [32, 22],       # 40x27
    "brazil": [32, 22],      # 40x28
    "india": [32, 22],       # 40x27
    "italy": [32, 22],       # 40x27
    "uae": [32, 16],         # 40x20
    "canada": [32, 16],      # 40x20
    "australia": [32, 16],   # 40x20
    "south korea": [32, 22], # 40x27
}



def norm_theme(value):
    """A theme setting, lowercased, against the themes that actually exist.

    The dropdown hands back the label as typed in the manifest ("Torii Gate"),
    but a value saved before a theme existed -- or before this input existed at
    all -- arrives as something not in THEMES, so the fallback has to be a real
    theme rather than an error state.
    """
    t = str(value).strip().lower()
    if t in THEMES:
        return t
    return "wedding"


def draw_theme(c, theme):
    """Draw the theme's PNG in the icon tile beside the rail, centred.

    The PNG is named after the theme with spaces as hyphens ("torii gate" ->
    torii-gate.png). A picture fills the tile; a flag is drawn at its
    FLAG_SIZE.
    """
    if theme not in THEMES:
        theme = "wedding"
    size = FLAG_SIZE.get(theme, [ICON, ICON])
    w = size[0]
    h = size[1]
    c.image(theme.replace(" ", "-") + ".png", RAIL_W + (ICON - w) // 2,
            (c.height - h) // 2, w = w, h = h)


def _hex2(v):
    return HEXCHARS[v // 16] + HEXCHARS[v % 16]


def lift(bg):
    """The accent, lightened until it reads as text on the near-black ground.

    The accent is the user's to choose and it is drawn on the near-black
    ground -- rail, eyebrow, progress bar -- so a dark pick disappears: a navy
    "#101044" rendered every one of those invisible. Anything below a
    luminance of 70 is scaled up to roughly 110, which keeps the hue the user
    chose and spends only the brightness needed to see it.
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


# The colour dropdowns' choices, lowercased, onto the panel's named palette.
# Nine chosen by the app's owner, in dropdown order: red, orange, yellow,
# green, cyan, blue, purple, pink, white.
#
# They are used as given, with no brightening, so their luminance against the
# near-black ground is worth knowing when picking one. Pink (#FF0097) is the
# dimmest at 93, then red at 99; the rest sit between 169 and 249. All clear
# 70, below which text starts to disappear on the panel.
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


def color_of(value, fallback):
    """A colour dropdown's value as hex. A "#RRGGBB" saved by the old colour
    picker passes through so existing setups keep their colour; anything else
    unknown falls back to the setting's default."""
    v = str(value).strip()
    if v.startswith("#"):
        return v
    return COLORS.get(v.lower(), COLORS[fallback])


def accent_of(ctx):
    return color_of(ctx.inputs.get("accent", "Purple"), "purple")


def configured(ctx):
    """The event as the user set it up, or None when its date is unusable.

    The date is the only field the app cannot invent. A name is optional and
    falls back to the theme, so filling in nothing but a date still gives
    "DAYS SINCE BIRTHDAY" rather than a blank title.

    One event per install: someone tracking several adds the app once for
    each, and every copy takes its own turn in the scroll.
    """
    ymd = parse_date(ctx.inputs.get("date", ""))
    if ymd == None:
        return None
    theme = norm_theme(ctx.inputs.get("theme", ""))
    name = str(ctx.inputs.get("event", "")).strip().upper()
    if name == "":
        name = theme.upper()
    return {"ymd": ymd, "theme": theme, "name": name,
            "numcolor": color_of(ctx.inputs.get("numcolor", ""), "pink")}


def days_since(ctx, ymd):
    """Days since `ymd`.

    Negative means the chosen day has not arrived, which this app does not
    count: since() turns it away rather than clamping it to 0, because a
    clamped 0 is indistinguishable from an event that happened today, so a
    mis-set date would look correct.
    """
    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    return today - days_from_civil(ymd[0], ymd[1], ymd[2])


def pretty_date(ymd):
    return "%s %d %d" % (MONTHS[ymd[1] - 1], ymd[2], ymd[0])


# ------------------------------------------------------------------- chrome

def rail(c, color):
    """The accent rail down the left edge."""
    c.rect(0, 0, RAIL_W - 1, c.height - 1, fill = color)


def title_row(c, event, head, event_color = "white"):
    """The upper level: "<HEAD><EVENT>" across the content column.

    `head` is "DAYS SINCE " or "DAYS TO " -- the caller decides, because only
    it knows which side of today the date falls on.

    `event_color` is the event's own colour, shared with its count, so the
    name and the number read as one event while the fixed head stays neutral.

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


def marks_x(c):
    return RIGHT_EDGE + 1 - LAMP_SPAN


def lamp(c, x, y, on, color):
    """One 5x5 anniversary lamp at (x, y).

    Lit, the square is filled with its colour and rimmed with lift() of that
    same colour. Both lamps are bright enough that lift() is the identity, so
    both draw as plain solid blocks and the rim costs nothing -- it is a guard,
    not a style: swap in a colour too dark for the ground and the lamp keeps a
    visible edge instead of disappearing into it.
    """
    if on:
        c.rect(x, y, x + 4, y + 4, fill = color, outline = lift(color))
    else:
        c.rect(x, y, x + 4, y + 4, outline = STRUCT)


def anniversary(ctx, ymd):
    """This year's occurrence of the event's date, as [y, m, d].

    Feb 29 clamps to the 28th in a common year, so a leap-day anniversary
    still has a day to land on.
    """
    y = ctx.now.year
    d = ymd[2]
    if d > month_days(y, ymd[1]):
        d = month_days(y, ymd[1])
    return [y, ymd[1], d]


def lamp_states(ctx, ymd):
    """[month, week, day] for the three lamps, as a strict cascade.

    Each lamp narrows the one to its left, so week can never light without
    month, nor day without week. That is not decoration -- it is what makes
    the row readable at a glance: the lit run always starts at the left, so
    how MANY are lit tells you how close the anniversary is without having to
    remember which colour means what.

    Getting there meant fixing two lamps, not adding one. The first versions
    asked different KINDS of question -- month and day compared today against
    the event's month/day, while week asked whether the anniversary landed in
    a window -- and predicates of different kinds cannot nest. So week lit
    without month whenever a week straddled a month end (Mon 31 Aug for a
    1 Sep event), and day lit on its own on the 1st of every month, months
    away from any anniversary.
    """
    ann = anniversary(ctx, ymd)
    month = ctx.now.month == ymd[1]

    week = False
    day = False
    if month:
        today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
        monday = today - ctx.now.weekday      # ctx.now.weekday: 0 = Monday
        a = days_from_civil(ann[0], ann[1], ann[2])
        week = a >= monday and a <= monday + 6
        day = ctx.now.day == ann[2]
    return [month, week, day]


def marks(c, ymd, ctx):
    """The three anniversary lamps, sitting over the date they qualify.

    They narrow left to right: orange for the whole of the event's month,
    green once the anniversary is in this Monday-to-Sunday week, navy on the
    day itself. See lamp_states() for why they are a cascade.

    Off is drawn as an outline rather than left blank. A lamp that vanishes
    when it is off leaves nothing to say a lamp was ever there.
    """
    st = lamp_states(ctx, ymd)
    mx = marks_x(c)
    lamp(c, mx, MARKS_Y, st[0], MONTH_ON)
    lamp(c, mx + 9, MARKS_Y, st[1], WEEK_ON)
    lamp(c, mx + 18, MARKS_Y, st[2], DAY_ON)


# --------------------------------------------------------------------- page

def since(c, ctx):
    # The accent is made safe to draw AS ink on the black ground once, here,
    # because every use of it on this page is ink -- the rail and the lamps.
    ink_accent = lift(accent_of(ctx))

    c.fill(INK)
    ev = configured(ctx)

    # No usable date: say what is wrong and what to do, and dress the rail in
    # the warning colour rather than the accent so the state is never
    # contradicted by its own chrome.
    if ev == None:
        rail(c, "#E8B04A")
        message(c, "SET A DATE", "PICK A DAY FOR THIS EVENT")
        return

    n = days_since(ctx, ev["ymd"])

    # A future date is outside what this app counts -- the picker only offers
    # today and earlier -- so it is sent back to be set, in the same warning
    # dress as a missing date.
    if n < 0:
        rail(c, "#E8B04A")
        message(c, "SET A DATE", "PICK TODAY OR AN EARLIER DAY")
        return

    # The count colour belongs to the event, not the rail, so it is resolved
    # separately. lift() still guards a pick too dark for the black ground.
    num_ink = lift(ev["numcolor"])

    # Today gets its own word rather than a drawn zero.
    # Every state takes the event's own colour. Leaving TODAY on the accent
    # meant an event set to pink turned blue on the one day it mattered.
    head = "DAYS SINCE "
    wcol = num_ink
    if n == 0:
        word = "TODAY"
        unit = ""
    else:
        word = fmt.commas(n)
        unit = "DAY" if n == 1 else "DAYS"

    rail(c, ink_accent)
    draw_theme(c, ev["theme"])
    title_row(c, ev["name"], head, num_ink)

    # The right-hand column: the anniversary lamps over the date they qualify.
    date = pretty_date(ev["ymd"])
    marks(c, ev["ymd"], ctx)
    c.text(date, RIGHT_EDGE, DATE_Y, font = DATE_FONT, color = MID,
           align = "right")
    col_x = RIGHT_EDGE + 1 - max(LAMP_SPAN, c.text_width(date, DATE_FONT))

    # ----- the count, from the left -----------------------------------------
    # The count starts at the content column and has to stop short of the
    # lamp-and-date column on the right.
    x = LEFT

    uw = c.text_width(unit, UNIT_FONT) if unit != "" else 0
    ugap = UNIT_GAP if unit != "" else 0

    hf = fit(c, word, HERO_FONTS, col_x - CLEAR - x - ugap - uw)
    hw = c.text_width(hf[1], hf[0])

    # Centre the number's ink in the band rather than hanging it from BAND.
    # Drawn at BAND a 16-row face left one row under the title and eight dead
    # rows below it -- top-heavy, and the panel looked half empty.
    hh = ink_height(hf[0])
    hy = BAND + (c.height - BAND - hh) // 2
    c.text(hf[1], x, hy, font = hf[0], color = wcol)

    # The unit sits on the number's baseline, not on its own centre. "2,643"
    # and "DAYS" are one phrase and read as one only when their bottoms line
    # up; centring the smaller face left it hanging two rows low.
    if unit != "":
        uy = hy + hh - ink_height(UNIT_FONT)
        c.text(unit, x + hw + UNIT_GAP, uy, font = UNIT_FONT, color = MID)
