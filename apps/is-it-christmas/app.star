# Is It Christmas?
#
# DESIGN. A one-question app with a one-word answer. The question is the
# title, stacked in two 5x7 lines across the top; the answer is the hero, in
# 9x12_bold, centered in the gap between two pixel-art Christmas trees that sit in
# the bottom corners. Every day but December 25 the answer is a red NO and the
# trees are dark. On December 25 it is a green YES! and every light from the
# original's four twinkle frames is lit at once, in one still picture.
#
# Ported from the Tidbyt community app "Is It Christmas" by Austin Fonacier
# (tidbyt/community, apps/isitchristmas). The trees are the original 11x11
# sprites at native size; the lettering is GDN's own uppercase fonts.
#
# Layout (64x32), measured with gdn.fonts.text_width:
#   y 0-6    "IS IT"       5x7, 27 px wide, centered
#   y 7      1 px gap between the stacked title rows
#   y 8-14   "CHRISTMAS?"  5x7, 59 px wide, centered (x 2-60)
#   y 15-17  gap between the title and the hero
#   y 18-29  hero          9x12_bold, 12 rows of ink. Its bottom row lines up
#                          with the trees' lowest needles (y 29). "YES!" is the
#                          worst case at 34 px of ink; the trees' widest rows
#                          (left tree ink ends at x 9, right starts at x 54)
#                          leave x 11-52 = 42 px with a 1 px buffer each side.
#   y 21-31  trees         11x11 each, flush to the left and right edges.
#
# Screens. This app reads only the clock and one dropdown; it fetches nothing
# and needs no key, so there is no offline, empty or demo state to reach. An
# unrecognized time zone degrades to New York time instead of failing.
#
# Time zone. ctx.now is UTC. The app only needs the offset in late December,
# when every northern zone in the shared list is on standard time and every
# southern zone with daylight saving is on summer time, so a December offset
# per zone is exact for the one day that matters.

TITLE = "#00DC46"   # GDN named "green" (0, 220, 70): LED-tuned, high contrast
YES_COLOR = "#00DC46"
NO_COLOR = "#FF0000"  # GDN named "red": the only state allowed to shout

TITLE_FONT = "5x7"
HERO_FONT = "9x12_bold"
HERO_Y = 18

# The shared GDN time-zone list: [standard offset in minutes, DST rule].
# Rules 3 and 4 are the southern-hemisphere zones on summer time in December.
TZ = {
    "Pacific/Honolulu": [-600, 0],
    "America/Anchorage": [-540, 1],
    "America/Los_Angeles": [-480, 1],
    "America/Phoenix": [-420, 0],
    "America/Denver": [-420, 1],
    "America/Chicago": [-360, 1],
    "America/Mexico_City": [-360, 0],
    "America/New_York": [-300, 1],
    "America/Bogota": [-300, 0],
    "America/Halifax": [-240, 1],
    "America/Sao_Paulo": [-180, 0],
    "America/Argentina/Buenos_Aires": [-180, 0],
    "UTC": [0, 0],
    "Europe/Lisbon": [0, 2],
    "Europe/Dublin": [0, 2],
    "Europe/London": [0, 2],
    "Europe/Madrid": [60, 2],
    "Europe/Paris": [60, 2],
    "Europe/Amsterdam": [60, 2],
    "Europe/Berlin": [60, 2],
    "Europe/Rome": [60, 2],
    "Europe/Stockholm": [60, 2],
    "Europe/Warsaw": [60, 2],
    "Africa/Lagos": [60, 0],
    "Europe/Athens": [120, 2],
    "Europe/Helsinki": [120, 2],
    "Africa/Johannesburg": [120, 0],
    "Europe/Moscow": [180, 0],
    "Africa/Nairobi": [180, 0],
    "Asia/Dubai": [240, 0],
    "Asia/Karachi": [300, 0],
    "Asia/Kolkata": [330, 0],
    "Asia/Dhaka": [360, 0],
    "Asia/Bangkok": [420, 0],
    "Asia/Jakarta": [420, 0],
    "Asia/Shanghai": [480, 0],
    "Asia/Singapore": [480, 0],
    "Asia/Hong_Kong": [480, 0],
    "Australia/Perth": [480, 0],
    "Asia/Tokyo": [540, 0],
    "Asia/Seoul": [540, 0],
    "Australia/Adelaide": [570, 3],
    "Australia/Brisbane": [600, 0],
    "Australia/Sydney": [600, 3],
    "Australia/Melbourne": [600, 3],
    "Pacific/Auckland": [720, 4],
    "Atlantic/Reykjavik": [0, 0],
    "Europe/Kyiv": [120, 2],
    "Europe/Istanbul": [180, 0],
    "Africa/Cairo": [120, 5],
    "Asia/Jerusalem": [120, 6],
    "Asia/Manila": [480, 0],
}
DEFAULT_ZONE = "America/New_York"

# ---------------------------------------------------------------------------
# Trees: the original 11x11 sprites, drawn at native size (no stretching).
# The lit tree carries every light position from the original's four
# twinkle frames. Where frames gave one spot different colors, one of that
# spot's own colors was kept.
# ---------------------------------------------------------------------------

TREE_LEGEND = {
    "g": "#4CAF50",   # needles
    "t": "#795548",   # trunk
    "p": "#E91E63",   # pink
    "o": "#FF9800",   # orange
    "v": "#9C27B0",   # violet
    "c": "#00BCD4",   # cyan
    "y": "#FFCA28",   # yellow
    "a": "#FFC107",   # amber
}

TREE_DARK = [
    ".....g.....",
    "....ggg....",
    "....ggg....",
    "...ggggg...",
    "...ggggg...",
    "..ggggggg..",
    "..ggggggg..",
    ".ggggggggg.",
    ".ggggggggg.",
    ".....t.....",
    ".....t.....",
]

TREE_LIT = [
    ".....g.....",
    "....ggg....",
    "....vcy....",
    "...gggpg...",
    "...gyggg...",
    "..gggcgyg..",
    "..gapgogg..",
    ".gvggggcgg.",
    ".ggoggacpg.",
    ".....t.....",
    ".....t.....",
]

TREE_W = 11
TREE_Y = 21   # 32 - 11: the trunk sits on the bottom row

# ---------------------------------------------------------------------------

def civil_from_days(z):
    """(year, month, day) for a count of days since 1970-01-01 (Hinnant)."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return (y, m, d)

def december_offset(zone):
    """Minutes east of UTC for `zone` in late December."""
    z = TZ[zone] if zone in TZ else TZ[DEFAULT_ZONE]
    return z[0] + (60 if z[1] in (3, 4) else 0)

def is_christmas(ctx):
    zone = str(ctx.inputs.get("timezone", DEFAULT_ZONE)).strip()
    local = ctx.now.unix + december_offset(zone) * 60
    _, month, day = civil_from_days(local // 86400)
    return month == 12 and day == 25

def main(c, ctx):
    c.fill("black")

    yes = is_christmas(ctx)

    c.text_center("IS IT", 0, font = TITLE_FONT, color = TITLE)
    c.text_center("CHRISTMAS?", 8, font = TITLE_FONT, color = TITLE)

    if yes:
        # "YES!" is 34 px of ink at 9x12_bold (35 px advance), so x = 15
        # puts the ink at x 15-48: 5 px clear of each tree's widest row.
        c.text("YES!", 15, HERO_Y, font = HERO_FONT, color = YES_COLOR)
        tree = TREE_LIT
    else:
        # "NO" is 19 px of ink; x = 22 centers it (ink x 22-40).
        c.text("NO", 22, HERO_Y, font = HERO_FONT, color = NO_COLOR)
        tree = TREE_DARK

    c.sprite(tree, 0, TREE_Y, legend = TREE_LEGEND)
    c.sprite(tree, c.width - TREE_W, TREE_Y, legend = TREE_LEGEND)