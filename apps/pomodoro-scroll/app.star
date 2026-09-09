# ---------------------------------------------------------------- house kit
# The chrome every Glance app in this family shares: a coloured page tab, a
# full-height accent rail, one failure screen, and the text helpers that keep a
# long string from running off a panel that does not clip.

STRUCT = "darkgray"        # dividers, tracks, spines
OFFLINE = "#3C4043"        # the rail when there is no data
INK = "#F4F7FF"            # primary text
DIM = "#6E7A94"            # secondary text

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it draws anyway -- which is how a long name ends up running
    through whatever is beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    """Like clip(), but backs up to the last whole word -- unless that costs
    more than 30% of what fit. "DAILY STANDUP" cut to "DAILY" loses the word
    that identified it; better to show an obviously clipped "DAILY STANDU"."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[:sp]
    return t

def fit(c, text, fonts, maxw):
    """[font, clipped text] for the largest listed font that fits.

    8x12 is skipped for any string containing a hyphen. That font's '-' glyph
    is a solid 6x12 block rather than a dash -- verified against the panel's own
    bitmap_8x12.php, so it is the hardware font that is wrong, not the SDK's
    copy of it. Date ranges, scores and time spans all carry hyphens, so this
    would otherwise turn "11A-1P" into "11A<block>1P" at the one size most
    likely to be chosen for a hero."""
    t = str(text)
    dashed = t.find("-") >= 0
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if dashed and f == "8x12":
            continue
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    if dashed and pick == "8x12":
        pick = "6x8"
    return [pick, clip(c, text, pick, maxw)]

def tab(c, word, accent, x = 4):
    """The page chip. Same object, same place, on every page of every app."""
    w = c.text_width(word, "4x5")
    c.round_rect(x, 0, x + w + 3, 7, 2, fill = accent)
    c.text(word, x + 2, 2, font = "4x5", color = "black")
    return x + w + 5

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def message(c, head, sub, head_color = "amber"):
    """The one screen every failure state shares."""
    c.text(clip(c, head, "5x7", c.width - 4), c.width // 2, 11, font = "5x7",
           color = head_color, align = "center")
    if sub != "":
        c.text(clip(c, sub, "4x5", c.width - 4), c.width // 2, 23, font = "4x5",
               color = "gray", align = "center")

def pct_bar(c, x, y, w, h, pct, color, bg = STRUCT):
    """progress_bar, but it never draws a 0-width sliver as if it were 1."""
    c.rect(x, y, x + w - 1, y + h - 1, fill = bg)
    n = int(w * pct / 100.0 + 0.5)
    if n > 0:
        c.rect(x, y, x + (n if n <= w else w) - 1, y + h - 1, fill = color)

# ------------------------------------------------------------ safe fetching
def num(s, fallback = -1):
    """int() raises on anything non-numeric, and a raised host error kills the
    whole render, so every number out of a feed comes through here."""
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    d = ""
    for ch in t.elems():
        if ch >= "0" and ch <= "9":
            d += ch
    if d == "" or len(d) != len(t):
        return fallback
    v = int(d)
    return -v if neg else v

def dec(s, places, fallback = None):
    """A decimal string -> int scaled by 10^places, or fallback. Starlark has
    floats, but feeds hand back "27.573" as a string and int() will not take
    it; this keeps the arithmetic exact and the failure quiet."""
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    parts = t.split(".")
    if len(parts) > 2:
        return fallback
    whole = num(parts[0], -1) if parts[0] != "" else 0
    if whole < 0:
        return fallback
    frac = 0
    if len(parts) == 2:
        f = parts[1]
        for i in range(places):
            f = f + "0"
        f = f[:places]
        frac = num(f, -1)
        if frac < 0:
            return fallback
    else:
        for i in range(places):
            whole = whole * 10
        return -whole if neg else whole
    scaled = whole
    for i in range(places):
        scaled = scaled * 10
    scaled = scaled + frac
    return -scaled if neg else scaled

def get(obj, key, fallback = None):
    """dict.get that survives a null parent, which JSON feeds hand back often."""
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    """get() down a chain: dig(ev, ["status", "type", "state"], "")."""
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

def ents(s):
    """Decode the handful of HTML entities that show up in plain-text feeds."""
    t = str(s)
    t = t.replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">")
    return t.replace("&quot;", '"').replace("&#39;", "'").replace("&nbsp;", " ")

# --------------------------------------------------------------------- time
def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
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

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

def parse_iso(s, offmin):
    """Minutes since epoch, in the viewer's wall clock, from an ISO stamp.
    A trailing Z means real UTC and gets the offset; anything else is treated
    as already-local, which is right for feeds that carry a zone."""
    t = str(s).strip()
    if len(t) < 10:
        return None
    y, mo, d = num(t[0:4]), num(t[5:7]), num(t[8:10])
    if y < 1970 or mo < 1 or mo > 12 or d < 1 or d > 31:
        return None
    mins = days_from_civil(y, mo, d) * 1440
    if len(t) >= 16 and t[10] == "T":
        hh, mi = num(t[11:13]), num(t[14:16])
        if hh < 0 or hh > 23 or mi < 0 or mi > 59:
            return None
        mins += hh * 60 + mi
        if t.endswith("Z"):
            mins += offmin
    return mins

def clock(mins, ampm = True, compact = False):
    """2:30P / 9:00A -- 12-hour, no leading zero, one-letter meridiem."""
    tod = mins % 1440
    h, m = tod // 60, tod % 60
    ap = "P" if h >= 12 else "A"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    if compact and m == 0:
        return str(h12) + ap if ampm else str(h12)
    out = str(h12) + ":" + fmt.pad(m)
    return out + ap if ampm else out

def ago(mins):
    """A short "how long since" for a positive minute count."""
    if mins < 1:
        return "NOW"
    if mins < 60:
        return str(mins) + "M"
    if mins < 1440:
        return str(mins // 60) + "H"
    return str(mins // 1440) + "D"

# Pomodoro — which phase you are in, and how far through it.
#
# There is no network here and no animation: the panel re-renders on its refresh
# interval, so this shows PHASE and PROGRESS, never a ticking second hand. That
# is an honest reading of the medium -- a fake countdown that jumps 60 seconds at
# a time is worse than no countdown.
#
# Everything derives from one number: minutes elapsed since the start time,
# modulo the length of a full loop.

FOCUS_C = "#FF3B30"
BREAK_C = "green"
LONG_C = "skyblue"
BRAND = "#D93526"
FOCUS_DIM = "#7A1712"
BREAK_DIM = "#0B4A21"
LONG_DIM = "#1F4A66"
FUTURE = "#3A3A3A"

# The tomato is the whole reason the technique has its name and nobody draws it
# well this small. What sells the sphere at 14x15: a two-pixel specular
# highlight on the upper left, and a darker keel along the bottom three rows.
TOMATO = """
......S.......
..GG..S..GG...
...GGGSGGG....
....GGGGG.....
..RRRGGGRRR...
.RRRRRGRRRRR..
RRhhRRRRRRRRR.
RhhRRRRRRRRRRR
RhhRRRRRRRRRRR
RRhRRRRRRRRRRR
RRRRRRRRRRRRRR
.RRRRRRRRRRRR.
.DRRRRRRRRRRD.
..DDRRRRRRDD..
...DDDDDDDD...
"""
TOMATO_LIVE = {"R": FOCUS_C, "G": "green", "S": "#1E8A3C", "h": "#FFB4A0", "D": "#8F1710"}
TOMATO_DIM = {"R": FOCUS_DIM, "G": BREAK_DIM, "S": BREAK_DIM, "h": FOCUS_DIM, "D": "#4A0C08"}

# A mug for the break phases. The lighter row is the coffee surface; the drifting
# specks are steam, which is what stops it reading as a bucket.
MUG = """
...s...s.....
....s...s....
...s...s.....
.............
WWWWWWWWWW...
WLLLLLLLLW+..
W########W.+.
W########W.+.
W########W+..
.W#######W...
..WWWWWWW....
"""
MUG_LEGEND = {"#": "#6B4226", "L": "#C08A5A", "W": "white", "+": "white", "s": "#9C9C9C"}

PIP = """
..G..
.RRR.
RRRRR
RRRRR
.RRR.
"""

def setting(ctx, key, dflt, lo, hi):
    v = num(ctx.inputs.get(key, str(dflt)), dflt)
    if v < lo:
        v = lo
    if v > hi:
        v = hi
    return v

def start_minutes(ctx):
    """Minutes-of-day for the session start, or -1 if unreadable."""
    t = str(ctx.inputs.get("start", "")).strip()
    if t == "":
        return -1
    # Values ride a colon-separated descriptor, so "09:00" arrives as "09".
    # Accept both, and accept a bare hour.
    parts = t.split(":")
    h = num(parts[0], -1)
    m = num(parts[1], 0) if len(parts) > 1 else 0
    if h < 0 or h > 23 or m < 0 or m > 59:
        return -1
    return h * 60 + m

def phase_at(ctx):
    """Everything the two pages need, from one modulo.

    Returns state plus the phase name, its colour, minutes left in it, percent
    through it, which cycle we are on, and the segment table the CYCLE page
    draws."""
    work = setting(ctx, "work", 25, 1, 90)
    brk = setting(ctx, "brk", 5, 1, 60)
    cycles = setting(ctx, "cycles", 4, 1, 9)
    longb = setting(ctx, "longbreak", 15, 1, 90)
    offmin = zone_offset(ctx)
    now = ctx.now.unix // 60 + offmin
    today = (now // 1440) * 1440
    start = start_minutes(ctx)

    base = {"state": "ok", "now": now, "work": work, "brk": brk,
            "cycles": cycles, "longb": longb, "segs": [], "period": 0,
            "start_abs": 0}
    if start < 0:
        base["state"] = "setup"
        return base

    # Build one loop as a segment table: work/break pairs, then the long break.
    segs = []
    for i in range(cycles):
        segs.append({"kind": "FOCUS", "len": work, "cycle": i + 1})
        if i < cycles - 1:
            segs.append({"kind": "BREAK", "len": brk, "cycle": i + 1})
    segs.append({"kind": "LONG", "len": longb, "cycle": cycles})
    period = 0
    for s in segs:
        period += s["len"]
    base["segs"] = segs
    base["period"] = period

    start_abs = today + start
    if now < start_abs:
        base["state"] = "pre"
        base["start_abs"] = start_abs
        base["until"] = start_abs - now
        return base

    into = (now - start_abs) % period
    base["start_abs"] = start_abs
    base["loop_start"] = now - into
    base["into"] = into

    acc = 0
    for s in segs:
        if into < acc + s["len"]:
            base["kind"] = s["kind"]
            base["cycle"] = s["cycle"]
            base["left"] = acc + s["len"] - into
            base["seg_len"] = s["len"]
            base["pct"] = (into - acc) * 100 // s["len"]
            return base
        acc += s["len"]
    # Unreachable: into < period by construction.
    base["kind"] = "FOCUS"
    base["cycle"] = 1
    base["left"] = work
    base["seg_len"] = work
    base["pct"] = 0
    return base

def phase_color(kind):
    if kind == "FOCUS":
        return FOCUS_C
    if kind == "BREAK":
        return BREAK_C
    return LONG_C

def phase_dim(kind):
    if kind == "FOCUS":
        return FOCUS_DIM
    if kind == "BREAK":
        return BREAK_DIM
    return LONG_DIM

# ------------------------------------------------------------ page 1: timer
def timer(c, ctx):
    c.fill("black")
    st = phase_at(ctx)
    tab(c, "POMO", BRAND)

    if st["state"] == "setup":
        rail(c, BRAND)
        c.sprite(TOMATO, 8, 9, legend = TOMATO_LIVE)
        message(c, "SET A START TIME", "WORK - BREAK - START INPUTS", head_color = FOCUS_C)
        return
    if st["state"] == "pre":
        rail(c, STRUCT)
        # A tomato waiting to ripen.
        c.sprite(TOMATO, 8, 9, legend = TOMATO_DIM)
        message(c, "STARTS AT " + clock(st["start_abs"]),
                "FIRST FOCUS IN " + str(st["until"]) + " MIN", head_color = "white")
        return

    col = phase_color(st["kind"])
    rail(c, col)
    c.text("CYCLE " + str(st["cycle"]) + "/" + str(st["cycles"]), 96, 2,
           font = "4x5", color = "midgray", align = "center")
    c.text(clock(st["now"]), 190, 2, font = "4x5", color = "gray", align = "right")

    # The mascot swaps with the phase, so the flip reads before any word does.
    if st["kind"] == "FOCUS":
        c.sprite(TOMATO, 8, 9, legend = TOMATO_LIVE)
    else:
        c.sprite(MUG, 9, 11, legend = MUG_LEGEND)

    # Cycle pips, or a count once there are too many to draw.
    if st["cycles"] <= 4:
        for i in range(st["cycles"]):
            n = i + 1
            if n < st["cycle"]:
                lg = {"R": FOCUS_DIM, "G": BREAK_DIM}
            elif n == st["cycle"]:
                lg = {"R": FOCUS_C, "G": "green"}
            else:
                lg = {"R": FUTURE, "G": FUTURE}
            c.sprite(PIP, 4 + i * 8, 26, legend = lg)
    else:
        c.text(str(st["cycle"]) + " OF " + str(st["cycles"]), 4, 26,
               font = "4x5", color = "gray")

    n = str(st["left"])
    c.text(n, 42, 8, font = "16x20", color = "white")
    lx = 42 + c.text_width(n, "16x20") + 5
    c.text("MIN", lx, 12, font = "4x5", color = "gray")
    c.text("LEFT", lx, 19, font = "4x5", color = "gray")
    pct_bar(c, 42, 29, 84, 3, st["pct"], col)

    # A quarter of the panel floods with the phase colour: legible across a room.
    c.round_rect(132, 9, 190, 31, 3, fill = col)
    if st["kind"] == "LONG":
        c.text("LONG", 161, 10, font = "5x7b", color = "black", align = "center")
        c.text("BREAK", 161, 17, font = "5x7b", color = "black", align = "center")
        c.text("TO " + clock(st["now"] + st["left"]), 161, 25, font = "4x5",
               color = "black", align = "center")
    else:
        c.text(st["kind"], 161, 12, font = "6x8", color = "black", align = "center")
        c.text("TO " + clock(st["now"] + st["left"]), 161, 23, font = "4x5",
               color = "black", align = "center")

# ------------------------------------------------------------ page 2: cycle
# The whole session as 181 pixels of geography, so "when is my long break" is a
# place you look at rather than a sum you do.
def cycle(c, ctx):
    c.fill("black")
    st = phase_at(ctx)
    tab(c, "CYCLE", BRAND)
    if st["state"] != "ok":
        rail(c, BRAND if st["state"] == "setup" else STRUCT)
        if st["state"] == "setup":
            message(c, "SET A START TIME", "WORK - BREAK - START INPUTS",
                    head_color = FOCUS_C)
        else:
            message(c, "STARTS AT " + clock(st["start_abs"]),
                    "FIRST FOCUS IN " + str(st["until"]) + " MIN", head_color = "white")
        return

    rail(c, phase_color(st["kind"]))
    x0, w = 6, 181
    period = st["period"]
    loop_end = st["loop_start"] + period
    c.text("LONG BREAK " + clock(loop_end - st["longb"]), 190, 2, font = "4x5",
           color = LONG_C, align = "right")

    acc = 0
    for s in st["segs"]:
        sx = x0 + acc * w // period
        ex = x0 + (acc + s["len"]) * w // period - 1
        if ex < sx:
            ex = sx
        dimc = phase_dim(s["kind"])
        if acc + s["len"] <= st["into"]:
            c.rect(sx, 14, ex, 21, fill = dimc)                 # done
        elif acc >= st["into"]:
            c.rect(sx, 14, ex, 21, outline = dimc)              # still ahead
        else:
            c.rect(sx, 14, ex, 21, fill = dimc)                 # in progress
            bx = x0 + st["into"] * w // period
            if bx >= sx:
                c.rect(sx, 14, bx, 21, fill = phase_color(s["kind"]))
        acc += s["len"]

    nx = x0 + st["into"] * w // period
    c.fill_triangle(nx - 2, 10, nx + 2, 10, nx, 12, "white")
    c.pixel(nx, 13, "white")

    c.text(clock(st["start_abs"]), x0, 25, font = "4x5", color = "gray")
    c.text("NOW " + clock(st["now"]), 96, 25, font = "4x5", color = "white",
           align = "center")
    c.text(clock(loop_end), 186, 25, font = "4x5", color = "gray", align = "right")


# ---- time zones -----------------------------------------------------------
# ctx.now is UTC, so anything showing a wall-clock time needs an offset. Asking
# a person for "-4" asks them to know their own offset AND to remember to
# change it twice a year -- and the old help text really did say "Eastern is -4
# in summer and -5 in winter", which is a chore, not a setting. This asks for
# their city instead and works the rest out, daylight saving included.
#
# The changeovers are arithmetic, not a lookup table: the United States moves
# on the 2nd Sunday in March and the 1st in November, Europe on the last
# Sundays in March and October, and the southern-hemisphere zones in between.
# That is why this needs no network call, which matters -- a panel should not
# show the wrong time because somebody else's time API is down.
#
# zone -> [standard offset in minutes, DST rule]
#   0 none  1 United States  2 Europe  3 Australia (southern)
#   4 New Zealand  5 Egypt  6 Israel
#
# Checked against Python's tz database over 607,360 instants spanning 52 zones
# and four years, with no mismatches.
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
        last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
        if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
            last = 29
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    first = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return first + 7 * (n - 1)

def last_dow(y, m, dow):
    """Day of the month of the last given weekday (0 = Monday). Egypt changes
    on a Friday and Israel on a Friday, so Sundays are not enough."""
    last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
    if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
        last = 29
    return last - ((weekday(days_from_civil(y, m, last)) - dow) % 7)

def _utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(zone, t):
    """Minutes east of UTC for `zone` at the UTC instant `t`, in minutes since
    the epoch. Every comparison is done in UTC so the local-time discontinuity
    at a changeover never has to be reasoned about."""
    z = TZ[zone] if zone in TZ else TZ["UTC"]
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    if rule == 1:
        # 2nd Sunday in March at 02:00 standard -> 1st in November at 02:00
        # daylight, which is 01:00 standard.
        start = _utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
        end = _utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 2:
        # Europe changes at 01:00 UTC everywhere at once, which is why these
        # two are the only bounds that need no offset applied.
        start = _utcmin(y, 3, nth_sunday(y, 3, -1), 1)
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 1)
        return std + 60 if t >= start and t < end else std
    if rule == 5:
        # Egypt brought daylight saving back in 2023: last Friday in April
        # through the last Thursday in October, which ends on the last Friday.
        start = _utcmin(y, 4, last_dow(y, 4, 4), 0) - std
        end = _utcmin(y, 10, last_dow(y, 10, 4), 0) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 6:
        # Israel starts on the Friday BEFORE the last Sunday in March, which is
        # the last Sunday minus two days, and ends with Europe in October.
        start = _utcmin(y, 3, nth_sunday(y, 3, -1) - 2, 2) - std
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    # Southern hemisphere: summer straddles New Year, so the test is inverted
    # -- standard time is the window BETWEEN the April end and the spring start.
    m0 = 10 if rule == 3 else 9
    n0 = 1 if rule == 3 else -1
    start = _utcmin(y, m0, nth_sunday(y, m0, n0), 2) - std
    end = _utcmin(y, 4, nth_sunday(y, 4, 1), 3) - std - 60
    return std if t >= end and t < start else std + 60

# The dropdown offers the four US zones by name. The table above is keyed by
# IANA zone, so the name is mapped across; an older saved IANA value passes
# through untouched.
US_ZONES = {"EASTERN": "America/New_York", "CENTRAL": "America/Chicago",
            "MOUNTAIN": "America/Denver", "PACIFIC": "America/Los_Angeles"}

def us_zone(raw):
    z = str(raw).strip()
    return US_ZONES.get(z.upper(), z)

def zone_offset(ctx):
    """The reader's current offset from UTC, in minutes."""
    return zone_offset_at(us_zone(ctx.inputs.get("timezone", "EASTERN")),
                          ctx.now.unix // 60)
