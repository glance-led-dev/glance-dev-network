# Zmanim
#
# Original fetches Chabad.org's zmanim RSS feed and shows it as a vertically
# scrolling list (render.Marquee). GDN has no animation — each page is one
# static frame — so the list is paginated instead: a fixed number of pages,
# each showing a few zmanim, cycling on the manifest's refresh interval.
#
# Layout (64x32), each page:
#   y 0-5    date header
#   y 6-31   up to 4 zman rows: label left, time right-aligned in yellow

FEED = "https://www.chabad.org/tools/rss/zmanim.xml?locationid=%s&locationtype=2"

FONT = "4x5"
LABEL_FONT = "picopixel"
TINY = "3x4"
TIME_COLOR = "#ffff00"

# Two-line blocks (label row, then a larger time row below it) need more
# room per item than the old single-line layout, so PER_PAGE drops to 2.
# At the 8-page ceiling that is still 16 slots — exactly the full ZMANIM
# list — so every entry fits in one pass with no rotation needed.
PER_PAGE = 2
PAGE_COUNT = 8

# Vertical offsets within a block, tuned against real rendered pixels.
TIME_Y_OFFSET = 8   # label bottom (row 4) + 3px gap (rows 5,6,7) = row 8
BLOCK_HEIGHT = 17   # time bottom (row 14) + 2px gap (rows 15,16) = next label at 17

# Order matters: this is display order, top to bottom, not filtering. Every
# entry that appears in the feed and matches one of these prefixes is shown,
# in this order, regardless of what order the feed lists them in.
#
# The values are checked with startswith against the title text *before* the
# first " - " (i.e. still including any parenthetical, e.g.
# "Dawn (Alot Hashachar)"). The original Pixlet app's clean_title() stripped
# the parenthetical with a second .split(" (")[0] before matching, which
# makes every match_text comparison fail (the map's own values are longer
# than what's left to compare). It still produced usable single-word labels
# by accident, via the fallback path, but would not have correctly shortened
# multi-word entries like "Latest Shema Reading" -> "Last Shema". This port
# matches on the same string the original's own filter loop uses (a single
# split), which is the version that actually works.
ZMANIM = [
    ("Dawn (Alot", "DAWN"),
    ("Earliest Tallit", "TALLIT"),
    ("Sunrise", "SUNRISE"),
    ("Latest Shema", "LAST SHEMA"),
    ("Latest Shacharit", "LAST SHACHARIT"),
    ("Midday", "MIDDAY"),
    ("Earliest Mincha", "MINCHA GEDOLAH"),
    ("Mincha Ketanah", "MINCHA KETANAH"),
    ("Plag Hamincha", "PLAG HAMINCHA"),
    ("Sunset", "SUNSET"),
    ("Nightfall", "NIGHTFALL"),
    ("Midnight", "MIDNIGHT"),
    ("Candle Lighting after", "CANDLES (AFTER)"),
    ("Candle Lighting", "CANDLE LIGHTING"),
    ("Shabbat Ends", "SHABBAT ENDS"),
    ("Holiday Ends", "HOLIDAY ENDS"),
]

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# ---------------------------------------------------------------- date
# Pixlet's time.now().format("Monday") has no GDN equivalent — ctx.now gives
# only unix/year/month/day, so weekday is derived the same way it was for
# every other sports app in this set (days-since-epoch, mod 7).

def _days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def date_str(ctx):
    """'27AUG' — day fused to month, no weekday, no space. 3x4 has no space
    glyph, so this only works because there is nothing that needs one."""
    mon = MONTHS[ctx.now.month - 1]
    return str(ctx.now.day) + mon

# ---------------------------------------------------------------- fetch

def fetch(zip_code):
    resp = http.get(
        FEED % zip_code,
        ttl_seconds = 3600,
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " +
                           "AppleWebKit/537.36 (KHTML, like Gecko) " +
                           "Chrome/118.0.0.0 Safari/537.36",
        },
    )
    if resp["status_code"] != 200:
        return None
    return resp["body"]

def clean_time(zman_time):
    """'5:12am --' -> '5:12AM'. Matches the original's split points, then
    uppercases am/pm rather than dropping it — the time is now on its own
    row at 5x7, which has room for the full AM/PM."""
    parts = zman_time.split(" - ")
    if len(parts) < 2:
        return ""
    t = parts[1].split(" --")[0].strip()
    return t.upper()

def parse_items(body):
    """Returns [(label, time), ...] in ZMANIM display order, not feed order."""
    found = {}
    items = body.split("<item>")[1:]
    for item in items:
        ts = item.find("<title>")
        te = item.find("</title>")
        if ts < 0 or te < 0:
            continue
        full_title = item[ts + 7:te].strip()

        # Same split the original's own filtering loop uses (one split on
        # " - "), so the parenthetical stays and the prefix match works.
        head = full_title.split(" - ")[0]

        for prefix, label in ZMANIM:
            if head.startswith(prefix) and label not in found:
                t = clean_time(full_title)
                if t != "":
                    found[label] = t
                break

    # Emit in ZMANIM's declared order, not dict/feed order.
    out = []
    for prefix, label in ZMANIM:
        if label in found:
            out.append((label, found[label]))
    return out

# ---------------------------------------------------------------- drawing

def fit_label(c, text, room):
    """Truncate to fit, always at LABEL_FONT (never 3x4 — no space glyph
    there, so a multi-word label would silently run together, e.g. "MINCHA
    GEDOLAH" -> "MINCHAGEDOLAH"). picopixel has full uppercase, digits,
    space and colon, and is narrow enough that the widest real label —
    "CANDLE LIGHTING:" at 63px — clears the 64px panel with 1px to spare.
    This mostly only fires when the date corner eats into row 0's budget."""
    if c.text_width(text, font = LABEL_FONT) <= room:
        return text
    for i in range(len(text), 0, -1):
        t = text[:i]
        if c.text_width(t, font = LABEL_FONT) <= room:
            return t
    return ""

def message(c, lines, color = "gray"):
    y = 10
    for line in lines:
        c.text(line, c.width // 2, y, font = FONT, color = color, align = "center")
        y += 7

def draw_slot(c, ctx, slot):
    c.fill("black")

    zip_code = ctx.inputs.get("zip", "11367").strip()
    if zip_code == "":
        zip_code = "11367"

    body = fetch(zip_code)
    if body == None:
        message(c, ["NO DATA"], "red")
        return

    items = parse_items(body)
    if len(items) == 0:
        message(c, ["NO ZMANIM", "FOUND"], "gray")
        return

    # Fewer items than pages*PER_PAGE just means later slots wrap rather
    # than showing an empty page — same approach as the tennis app's
    # low-volume days. At PER_PAGE=2 and the 8-page ceiling, capacity is
    # 16 — the full ZMANIM list — so a normal ~12-item day still leaves
    # slots that wrap rather than sit empty.
    # slot % slices can land back on page 1's content instead of a page
    # further along, when len(items) is not a clean multiple of PER_PAGE —
    # e.g. 13 items (12 daily zmanim + one Shabbos-specific entry) gives
    # 7 slices, and slot 7 (the 8th, last page) computes (7 % 7) * 2 = 0,
    # silently repeating DAWN/TALLIT instead of showing anything new. Since
    # Shabbos-specific entries sit at the end of ZMANIM, they are exactly
    # what this was dropping. Pages beyond the last real slice now repeat
    # the LAST slice instead of wrapping to the first.
    slices = (len(items) + PER_PAGE - 1) // PER_PAGE
    start = min(slot, slices - 1) * PER_PAGE

    # Offsets tuned against the actual rendered pixels, not just the
    # arithmetic: label-to-time gap is 3px, block-to-block gap is 2px.
    y = 0
    for i in range(start, min(start + PER_PAGE, len(items))):
        label, t = items[i]
        room = c.width - 2
        c.text(fit_label(c, label + ":", room), 1, y, font = LABEL_FONT, color = "white")
        c.text(t, 1, y + TIME_Y_OFFSET, font = "5x7", color = TIME_COLOR)
        y += BLOCK_HEIGHT

def p1(c, ctx):
    draw_slot(c, ctx, 0)

def p2(c, ctx):
    draw_slot(c, ctx, 1)

def p3(c, ctx):
    draw_slot(c, ctx, 2)

def p4(c, ctx):
    draw_slot(c, ctx, 3)

def p5(c, ctx):
    draw_slot(c, ctx, 4)

def p6(c, ctx):
    draw_slot(c, ctx, 5)

def p7(c, ctx):
    draw_slot(c, ctx, 6)

def p8(c, ctx):
    draw_slot(c, ctx, 7)