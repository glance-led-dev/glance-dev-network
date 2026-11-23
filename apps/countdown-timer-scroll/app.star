# Countdown Timer
#
# DESIGN. The event name sits in a header strip; under it, the time
# left until a date and time -- "6 DAYS, 10 HOURS, 23 MINUTES" -- in a
# colour that says how close it is: far off, soon, imminent (each one a
# dropdown, green / dark yellow / red by default, with the two
# thresholds also dropdowns). Once the moment passes the same count
# reads "... AGO" in the past colour. A hairline under the header wears
# the state colour too.
#
#   64x32                    128+ (SCROLL)
#   +------------------+     +--------------------------------+
#   |    GOING HOME    |     |           GOING HOME           |
#   |------------------|     |--------------------------------|
#   |     16 DAYS      |     |   16 DAYS, 4 HOURS, 12 MIN     |
#   |     4 HOURS      |     |                                |
#   |   12 MINUTES     |     +--------------------------------+
#   +------------------+
#
# The count is laid out by trying arrangements largest font first:
# one line, then two, then one unit per line, each with full, short
# ("HRS") and letter ("H") unit words, and the first that fits wins.
# So no width needs its own copy, and nothing is ever clipped.
#
# ctx.now is UTC. The target is a wall-clock time in the chosen zone,
# converted with the shared 52-zone table (daylight saving included).

MINUTE = 60
HOUR = 60 * MINUTE
DAY = 24 * HOUR
WEEK = 7 * DAY

# Dropdown value -> seconds, for the two thresholds.
SPANS = {
    "1 HOUR": HOUR,
    "3 HOURS": 3 * HOUR,
    "6 HOURS": 6 * HOUR,
    "12 HOURS": 12 * HOUR,
    "1 DAY": DAY,
    "2 DAYS": 2 * DAY,
    "3 DAYS": 3 * DAY,
    "1 WEEK": WEEK,
    "2 WEEKS": 2 * WEEK,
    "4 WEEKS": 4 * WEEK,
}

# Dropdown value -> panel colour. Dark yellow is the "soon" default:
# named yellow is (255, 220, 80), too close to white across a room.
PALETTE = {
    "GREEN": "green",
    "YELLOW": "yellow",
    "DARK YELLOW": "#B49600",
    "AMBER": "amber",
    "ORANGE": "orange",
    "RED": "red",
    "PINK": "pink",
    "PURPLE": "purple",
    "SKYBLUE": "skyblue",
    "WHITE": "white",
    "GRAY": "gray",
}

DEFAULT_WARN = "1 WEEK"
DEFAULT_ALARM = "1 DAY"
DEFAULT_FAR = "GREEN"
DEFAULT_SOON = "DARK YELLOW"
DEFAULT_IMMINENT = "RED"
DEFAULT_PAST = "GRAY"
DEFAULT_NAME = "WHITE"

# [seconds, full singular, full plural, short singular, short plural, letter]
UNITS = [
    [WEEK, "WEEK", "WEEKS", "WK", "WKS", "W"],
    [DAY, "DAY", "DAYS", "DAY", "DAYS", "D"],
    [HOUR, "HOUR", "HOURS", "HR", "HRS", "H"],
    [MINUTE, "MINUTE", "MINUTES", "MIN", "MIN", "M"],
]
STYLE_FULL = 0
STYLE_SHORT = 1
STYLE_LETTER = 2

# Body ladder, largest first. 7x12 is left out: it has no comma glyph.
BODY_FONTS = ["16x20", "10x16", "9x12", "6x8", "5x7", "4x5"]
HEAD_FONTS = ["6x8", "5x7", "4x5"]
FONTH = {"16x20": 20, "10x16": 16, "9x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}
LINE_GAP = 1

NARROW_PAD = 1   # 64: use every pixel
WIDE_PAD = 8     # SCROLL: safe zone, so the app never merges with a neighbour

NODATA_BG = "#0B0C12"
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"


# ---- dates ----------------------------------------------------------------

def days_from_civil(y, m, d):
    """Days since 1970-01-01 for a civil date (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    """The inverse: days since the epoch back to [year, month, day]."""
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

def weekday(z):
    """0 = Monday .. 6 = Sunday. Day 0 (1970-01-01) was a Thursday."""
    return (z + 3) % 7

def month_days(y, m):
    last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
    if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
        return 29
    return last


# ---- time zones (shared with trash-day; see the notes there) ---------------
#
# zone -> [standard offset in minutes, DST rule]
#   0 none  1 United States  2 Europe  3 Australia (southern)
#   4 New Zealand  5 Egypt  6 Israel
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

def nth_sunday(y, m, n):
    """Day of the month of the nth Sunday, or the last one when n is -1."""
    if n == -1:
        last = month_days(y, m)
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    first = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return first + 7 * (n - 1)

def last_dow(y, m, dow):
    """Day of the month of the last given weekday (0 = Monday)."""
    last = month_days(y, m)
    return last - ((weekday(days_from_civil(y, m, last)) - dow) % 7)

def _utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(z, t):
    """Minutes east of UTC for zone row `z` at the UTC instant `t`, in
    minutes since the epoch."""
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    if rule == 1:
        start = _utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
        end = _utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 2:
        start = _utcmin(y, 3, nth_sunday(y, 3, -1), 1)
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 1)
        return std + 60 if t >= start and t < end else std
    if rule == 5:
        start = _utcmin(y, 4, last_dow(y, 4, 4), 0) - std
        # Ends at 24:00 on the last Thursday of October. That is NOT
        # midnight before the last Friday when Oct 31 is a Thursday
        # (2030): the change then lands on Nov 1.
        end = _utcmin(y, 10, last_dow(y, 10, 3), 24) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 6:
        start = _utcmin(y, 3, nth_sunday(y, 3, -1) - 2, 2) - std
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    m0 = 10 if rule == 3 else 9
    n0 = 1 if rule == 3 else -1
    start = _utcmin(y, m0, nth_sunday(y, m0, n0), 2) - std
    end = _utcmin(y, 4, nth_sunday(y, 4, 1), 3) - std - 60
    return std if t >= end and t < start else std + 60

def zone_row(name):
    """The TZ row for a zone name. Settings are joined with '_' on their
    way to the app, so "America/Los_Angeles" may arrive as "America/Los":
    a unique prefix match recovers it. Unknown names fall back to UTC."""
    if name in TZ:
        return TZ[name]
    if len(name) == 0:
        return TZ["UTC"]
    hits = [k for k in TZ if k.startswith(name)]
    if len(hits) == 1:
        return TZ[hits[0]]
    return TZ["UTC"]


# ---- inputs -----------------------------------------------------------------

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    v = str(v).strip()
    if v == "":
        return fallback
    return v

def _digits(s):
    out = ""
    for i in range(len(s)):
        if s[i] >= "0" and s[i] <= "9":
            out += s[i]
    return out

def _int_in(s, lo, hi, fallback):
    ds = _digits(s)
    if ds == "":
        return fallback
    n = int(ds)
    if n < lo or n > hi:
        return fallback
    return n

def target_unix(ctx):
    """The target as a UTC unix time, or None when the date is unusable.

    The date picker's value reaches the app cut at the first ':' of its
    time ("2026-08-14T01"), so the day is read as the first eight digits
    rather than split on '-'."""
    ds = _digits(_s(ctx, "date", ""))
    if len(ds) < 8:
        return None
    y = int(ds[0:4])
    m = int(ds[4:6])
    d = int(ds[6:8])
    if m < 1 or m > 12 or d < 1 or d > month_days(y, m):
        return None

    hh = _int_in(_s(ctx, "hour", "0"), 0, 23, 0)
    mm = _int_in(_s(ctx, "minute", "0"), 0, 59, 0)
    local = _utcmin(y, m, d, hh) + mm

    # Two passes: the offset depends on the instant, which depends on
    # the offset. The first guess uses standard time; the second
    # corrects it when the target falls in daylight saving.
    z = zone_row(_s(ctx, "timezone", "UTC"))
    off = zone_offset_at(z, local - z[0])
    off = zone_offset_at(z, local - off)
    return (local - off) * MINUTE

def color_for(ctx, key, fallback):
    name = _s(ctx, key, fallback).upper()
    return PALETTE[name] if name in PALETTE else PALETTE[fallback]

def span_for(ctx, key, fallback):
    name = _s(ctx, key, fallback).upper()
    return SPANS[name] if name in SPANS else SPANS[fallback]


# ---- the count --------------------------------------------------------------

def parts_of(secs, largest, detail):
    """[[count, unit row], ...] for a non-negative span: `detail` units
    from the largest non-zero one, zero units dropped.

    6d 0h 23m at 3 units -> 6 DAYS, 23 MINUTES; at 2 units -> 6 DAYS."""
    units = UNITS if largest == "WEEKS" else UNITS[1:]
    out = []
    left = secs
    taken = 0
    for u in units:
        if taken >= detail:
            break
        n = left // u[0]
        left = left - n * u[0]
        if n == 0 and taken == 0:
            continue
        taken += 1
        if n > 0:
            out.append([n, u])
    return out

def word(part, style):
    n = part[0]
    u = part[1]
    if style == STYLE_LETTER:
        return str(n) + u[5]
    if style == STYLE_SHORT:
        return str(n) + " " + (u[3] if n == 1 else u[4])
    return str(n) + " " + (u[1] if n == 1 else u[2])

def arrangements(parts, style, suffix):
    """Candidate line splits, fewest lines first. The AGO suffix rides
    the last line; a line of its own is tried only after every split
    that keeps it attached, so it is never orphaned needlessly."""
    words = [word(p, style) for p in parts]
    sep = " " if style == STYLE_LETTER else ", "
    n = len(words)
    out = [[sep.join(words)]]
    if n == 3:
        out.append([sep.join(words[0:2]), words[2]])
    if n >= 2:
        out.append(words)
    if suffix == "":
        return out
    attached = [ln[0:len(ln) - 1] + [ln[len(ln) - 1] + suffix] for ln in out]
    alone = [ln + [suffix.strip()] for ln in out]
    return attached + alone

def fits(c, lines, font, maxw, maxh):
    h = len(lines) * FONTH[font] + (len(lines) - 1) * LINE_GAP
    if h > maxh:
        return False
    for ln in lines:
        if c.text_width(ln, font) > maxw:
            return False
    return True

def layout(c, parts, suffix, maxw, maxh):
    """[lines, font] for the biggest font that fits. Full and short unit
    words beat a bigger font in letters; letters are the last resort."""
    for font in BODY_FONTS:
        for style in [STYLE_FULL, STYLE_SHORT]:
            for lines in arrangements(parts, style, suffix):
                if fits(c, lines, font, maxw, maxh):
                    return [lines, font]
    for font in BODY_FONTS:
        for lines in arrangements(parts, STYLE_LETTER, suffix):
            if fits(c, lines, font, maxw, maxh):
                return [lines, font]
    small = BODY_FONTS[len(BODY_FONTS) - 1]
    return [arrangements(parts, STYLE_LETTER, suffix)[0], small]

def layout_now(c, maxw, maxh):
    """Font for "NOW", under a minute either side of the target."""
    for font in BODY_FONTS:
        if fits(c, ["NOW"], font, maxw, maxh):
            return font
    return BODY_FONTS[len(BODY_FONTS) - 1]


# ---- drawing ----------------------------------------------------------------

def _fit_clip(c, text, fonts, maxw):
    """Largest font that fits, then hard-clipped: nothing in the API clips."""
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [text, f]
    f = fonts[len(fonts) - 1]
    for _ in range(len(text)):
        if len(text) <= 1 or c.text_width(text + "..", f) <= maxw:
            break
        text = text[0:len(text) - 1]
    return [text.rstrip() + "..", f]

def nodata(c, title, sub):
    c.fill(NODATA_BG)
    cx = c.width // 2
    t = _fit_clip(c, title, ["10x16", "6x8", "5x7", "4x5"], c.width - 4)
    th = FONTH[t[1]] if t[1] in FONTH else 8
    c.text(t[0], cx, (21 - th) // 2, font = t[1], color = NODATA_TITLE, align = "center")
    s = _fit_clip(c, sub, ["4x5"], c.width - 4)
    c.text(s[0], cx, 24, font = s[1], color = NODATA_SUB, align = "center")

def state_color(ctx, delta):
    """Colour for a signed span (target minus now)."""
    if delta < 0:
        return color_for(ctx, "pastcolor", DEFAULT_PAST)
    if delta < span_for(ctx, "alarmat", DEFAULT_ALARM):
        return color_for(ctx, "alarmcolor", DEFAULT_IMMINENT)
    if delta < span_for(ctx, "warnat", DEFAULT_WARN):
        return color_for(ctx, "sooncolor", DEFAULT_SOON)
    return color_for(ctx, "farcolor", DEFAULT_FAR)

def countdown(c, ctx):
    target = target_unix(ctx)
    if target == None:
        nodata(c, "SET DATE", "PICK A DAY")
        return

    c.fill("black")
    delta = target - ctx.now.unix
    col = state_color(ctx, delta)
    pad = WIDE_PAD if c.width >= 128 else NARROW_PAD
    maxw = c.width - 2 * pad
    cx = c.width // 2

    # Header: event name, then a hairline in the state colour.
    top = 0
    event = _s(ctx, "event", "").upper()
    if event != "":
        h = _fit_clip(c, event, HEAD_FONTS, maxw)
        c.text(h[0], cx, 0, font = h[1], color = color_for(ctx, "namecolor", DEFAULT_NAME), align = "center")
        top = FONTH[h[1]] + 1
        c.line(pad, top, c.width - 1 - pad, top, col)
        top += 2

    # Body: the count, centred in what is left.
    secs = delta if delta >= 0 else -delta
    largest = _s(ctx, "largest", "DAYS").upper()
    detail = _int_in(_s(ctx, "detail", "3"), 1, 3, 3)
    parts = parts_of(secs, largest, detail)
    suffix = " AGO" if delta < 0 else ""
    if len(parts) == 0:
        lines = ["NOW"]
        font = layout_now(c, maxw, c.height - top)
    else:
        lf = layout(c, parts, suffix, maxw, c.height - top)
        lines = lf[0]
        font = lf[1]

    fh = FONTH[font]
    bh = len(lines) * fh + (len(lines) - 1) * LINE_GAP
    y = top + (c.height - top - bh) // 2
    for ln in lines:
        c.text(ln, cx, y, font = font, color = col, align = "center")
        y += fh + LINE_GAP
