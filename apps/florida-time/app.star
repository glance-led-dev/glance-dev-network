# Florida Time - the current time in Florida, on a Glance panel.
#
# No network call. Florida's clock is fully determined by the calendar: the
# peninsula runs on Eastern (UTC-5), the panhandle west of the Apalachicola
# River runs on Central (UTC-6), and both follow the federal daylight-saving
# rule -- forward on the second Sunday in March, back on the first Sunday in
# November. That rule is a dozen lines of arithmetic, so this computes it from
# ctx.now (UTC) rather than asking a time API. Nothing to be down, nothing to
# rate-limit, and no error screen to design: the panel is always right.
#
# DESIGN. A sunset strip over a beach: the gradient header is the sky, the palm
# stands on sand at the far left as the app's identity art, and the clock is the
# hero it shades. The palm is drawn full-height between the two horizontal
# rules -- one clear pixel under the header bar, one clear pixel over the day
# bar -- so the panel reads as a single scene rather than an icon parked next to
# a number.
#
# LAYOUT (128x32). The palm's own size drives the clock's x, and the two labels
# are placed off the WIDEST clock the field can produce, so nothing moves when
# the string does.
#
#   header  y=0..7     sunset gradient bar: FLORIDA left, local date right
#   palm    y=9..29    x=1, 17x21 sprite -- 1px clear of the header and the bar
#   time    y=10..29   x=20, 16x20  ("12:22" is the 84px worst case)
#   AM/PM   y=11..18   x=108, 6x8   (12-hour mode only)
#   zone    y=21..27   x=108, 5x7   -- green while DST is in effect
#   bar     y=31       how far through the day it is

DOW = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# A coconut palm, 17x21, baked as a sprite string so the app needs no PNG and
# no `assets:` entry. Seven fronds arc out of the crown and droop, each one a
# lit rachis (G, brightening to L at the tip) over a darker pinnae shadow (D),
# with sky left between them so the crown reads as leaves and not a blob. The
# trunk leans left as it falls, widening 2px -> 5px into a root flare, lit on
# the left (H) and shaded on the right (K) with a ring notch every other row.
# N are the two coconuts under the crown; S/s are the sand mound it stands on.
PALM = """
........GGL......
...LGDD.GDDDDD...
..LLGGG.G.GGGLL..
..DDDDG.GGGDDDD..
.LGGGG.GGG.GGGGD.
LLDDD.GGGGG.DDDLL
...DDGGGGGGGD....
..DGGGN.TK.GGGD..
..LLD...TK.NDL...
.LD....HTK...DL..
.......HKK.......
......HTK........
......HKK........
.....HTTK........
.....HKTK........
....HTTK.........
....HKTK.........
...HTTTK.........
...HKTTK.........
SSSSSSSSSSSss....
SSsSSSsSSsSSSssss
"""
PALM_COLORS = {
    "D": "#0E5C2A",  # frond shadow / pinnae
    "G": "#1FA64A",  # frond body
    "L": "#5FE07F",  # sunlit frond tip
    "T": "#8A5A2B",  # trunk
    "H": "#B9843F",  # trunk, sunlit edge
    "K": "#55361A",  # trunk, shaded edge and ring notches
    "N": "#C87E2C",  # coconuts -- lighter than every trunk tone and held one
                     # black pixel off the trunk, or they merge into it and
                     # read as a lumpy collar; staggered a row apart so the
                     # pair doesn't sit either side of the trunk like eyes
    "S": "#B08B48",  # sand
    "s": "#6B5124",  # sand, in shadow
}
PALM_ROWS = PALM.strip("\n").split("\n")
PALM_W = len(PALM_ROWS[0])
PALM_H = len(PALM_ROWS)

HEADER_A = "#FF8A00"
HEADER_B = "#FF2E7E"
TIME_COLOR = "#FFF3D6"
AMPM_COLOR = "#FFB03A"
DST_COLOR = "#5FD0A0"
STD_COLOR = "#9AA6B2"

TIME_FONT = "16x20"
AMPM_FONT = "6x8"
ZONE_FONT = "5x7"
DATE_FONT = "4x5"
# Starlark has no font-metrics call, so the row counts travel with the app.
FONTH = {"16x20": 20, "6x8": 8, "5x7": 7, "4x5": 5}

HEADER_H = 8        # the gradient bar owns y=0..7; its bottom rule is y=7
PALM_X = 1
PALM_GAP = 2                         # air between the sand and the clock
TIME_X = PALM_X + PALM_W + PALM_GAP  # = 20
TIME_Y = 10

# The labels are anchored to the WIDEST clock this field can print, not to the
# one that happens to be live: every 16x20 digit and the colon are 16px, so
# "12:22" measures 84px and ends at x=103, while a live "1:22" is 17px shorter.
# Hanging the labels off the live string would let them slide left at 1 o'clock
# and jump back at 10; hanging them off the worst case keeps them still.
WORST_TIME = "12:22"
LABEL_GAP = 4       # air between the widest clock and the label column
LABEL_LEAD = 2      # blank rows between AM/PM and the zone

# Margin between the date's last pixel and the right edge. 5px: the date is the
# quietest thing on the panel and was reading as if it had fallen off the end.
DATE_MARGIN = 5

# The two zones Florida actually uses: (standard UTC offset, abbreviations).
ZONES = {
    "peninsula": (-5, "EST", "EDT"),
    "panhandle": (-6, "CST", "CDT"),
}

# ---------- input ----------

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip().lower()

# ---------- calendar ----------

def _days_from_civil(y, m, d):
    # (year, month, day) -> days since 1970-01-01.
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _civil_from_days(z):
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return y, m, d

def _nth_sunday(y, month, nth):
    # Days since epoch for the nth Sunday of a month. Day 0 was a Thursday, so
    # (days + 4) % 7 is the weekday with 0 = Sunday.
    first = _days_from_civil(y, month, 1)
    return first + ((7 - (first + 4) % 7) % 7) + (nth - 1) * 7

# ---------- the actual clock ----------

def florida_offset(ctx, region):
    """Hours from UTC right now, the zone abbreviation, and whether it's DST."""
    zone = ZONES.get(region, ZONES["peninsula"])
    std = zone[0]

    now = ctx.now.unix
    year, _, _ = _civil_from_days(now // 86400)

    # Both transitions land at 2:00 *local* -- standard time in spring, daylight
    # time in autumn -- which is (2 - that offset) o'clock UTC.
    starts = _nth_sunday(year, 3, 2) * 86400 + (2 - std) * 3600
    ends = _nth_sunday(year, 11, 1) * 86400 + (2 - (std + 1)) * 3600

    if now >= starts and now < ends:
        return std + 1, zone[2], True
    return std, zone[1], False

def local_parts(ctx, off_hours):
    # Clock and date both come off this one shifted timestamp, so they can
    # never disagree across midnight.
    local = ctx.now.unix + off_hours * 3600
    sod = local % 86400
    days = (local - sod) // 86400
    year, month, day = _civil_from_days(days)
    return {
        "h": sod // 3600,
        "mi": (sod % 3600) // 60,
        "mo": month,
        "d": day,
        "wd": (days + 4) % 7,  # 0 = Sunday, to match DOW
    }

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

# ---------- the page ----------

def main(c, ctx):
    region = _s(ctx, "region", "peninsula")
    fmt = _s(ctx, "hourformat", "12")

    off, abbr, is_dst = florida_offset(ctx, region)
    t = local_parts(ctx, off)

    ampm = ""
    h = t["h"]
    if fmt != "24":
        ampm = "AM" if h < 12 else "PM"
        h = h % 12
        if h == 0:
            h = 12
    time_s = str(h) + ":" + pad2(t["mi"])

    bar_y = c.height - 1

    c.fill("black")

    # ----- header: the state, and today's date in Florida -----
    c.gradient_rect(0, 0, c.width - 1, HEADER_H - 1, HEADER_A, HEADER_B)
    c.text("FLORIDA", 3, 1, font = "5x7b", color = "black")

    # "WED SEP 30" is the worst case at 45px in 4x5; right-aligned against
    # c.width - DATE_MARGIN it runs x=78..122, which clears FLORIDA (ends x=43).
    date_s = DOW[t["wd"]] + " " + MONTHS[t["mo"] - 1] + " " + str(t["d"])
    c.text(date_s, c.width - DATE_MARGIN, 2,
           font = DATE_FONT, color = "black", align = "right")

    # ----- the palm, then the clock -----
    # The palm is centered in the 23-row band between the header's bottom rule
    # (y=7) and the day bar (y=31). The art is 21 rows, so that lands its crown
    # on y=9 and its sand on y=29: exactly one clear black pixel off each rule,
    # top and bottom. Resize the art and the clearance stays even on both sides.
    band_h = bar_y - HEADER_H
    palm_y = HEADER_H + (band_h - PALM_H) // 2
    c.sprite(PALM, PALM_X, palm_y, legend = PALM_COLORS)
    c.text(time_s, TIME_X, TIME_Y, font = TIME_FONT, color = TIME_COLOR)

    # ----- AM/PM over the zone, both left-justified in one column -----
    # LABEL_X = 108. The column's widest string is a 3-letter zone at 17px in
    # 5x7 (EST/EDT/CST/CDT all measure 17), so it ends at x=124 with 3px to
    # spare; AM/PM is 13px in 6x8. The pair is centered against the clock's 20
    # rows, which leaves the lower label ending at y=27 -- 3 rows clear of the
    # day bar at y=31.
    label_x = TIME_X + c.text_width(WORST_TIME, TIME_FONT) + LABEL_GAP

    stack = []
    if ampm:
        stack.append([ampm, AMPM_FONT, AMPM_COLOR])
    stack.append([abbr, ZONE_FONT, DST_COLOR if is_dst else STD_COLOR])

    stack_h = LABEL_LEAD * (len(stack) - 1)
    for row in stack:
        stack_h += FONTH[row[1]]

    ly = TIME_Y + (FONTH[TIME_FONT] - stack_h) // 2
    for row in stack:
        c.text(row[0], label_x, ly, font = row[1], color = row[2])
        ly += FONTH[row[1]] + LABEL_LEAD

    # ----- how far through the day it is -----
    mins = t["h"] * 60 + t["mi"]
    c.rect(0, bar_y, c.width - 1, bar_y, fill = "#241018")
    filled = (mins * (c.width - 1)) // 1440
    if filled > 0:
        c.rect(0, bar_y, filled, bar_y, fill = HEADER_A)
