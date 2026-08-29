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

def intpart(s, fallback = 0):
    """Whole-number part of a value that may arrive as a decimal.

    ADS-B ground speed comes back as 275.5 and altitude as 4600, from the same
    feed. num() rejects anything with a dot, so reading gs with it turned every
    aircraft's speed into 0 -- a wrong number that looks like a real one."""
    t = str(s).strip()
    return num(t.split(".")[0], fallback)

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

def parse_offset(raw):
    """Hours from UTC, as minutes. Free text, so "EST" lands here too."""
    t = str(raw).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    t = t.split(":")[0].split(".")[0].strip()
    d = ""
    for ch in t.elems():
        if ch >= "0" and ch <= "9":
            d += ch
    if d == "":
        return 0
    h = int(d)
    if h > 14:
        h = 14
    return (-h if neg else h) * 60

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

# ---- london tube ----------------------------------------------------------
# Nineteen lines, five rows of text. You cannot list them, so the app does two
# things at once: a ROLL CALL in colour along the bottom edge, and a TRIAGE
# list in words above it.
#
# The one rule that makes it work: colour lives only in BLOCKS, never in
# glyphs. Every line is a solid rectangle and every word is set in ink. That
# single decision solves three problems at once -- Northern's official colour
# is pure black and would be invisible as text; the pale lines bloom to white
# at glyph stroke widths but hold their hue as an 8x3 block; and a name is
# always legible because it is never dark-navy-on-black.
#
# The most common state by far is that everything is running, so the boring
# case is the one that has to look deliberate: a calm full rainbow and one
# green sentence.
#
# TfL split the Overground into six named lines in late 2024, so this is 19
# lines and not the 14 everybody still pictures.

TFL = ("https://api.tfl.gov.uk/Line/Mode/" +
       "tube,dlr,elizabeth-line,overground/Status")

# id, 3-letter code, list name, block colour. Order is fixed and learnable:
# the eleven Underground lines alphabetically, then Elizabeth and the DLR, then
# the six Overground lines alphabetically.
LINES = [
    ["bakerloo", "BAK", "BAKERLOO", "#B36305"],
    ["central", "CEN", "CENTRAL", "#E32017"],
    ["circle", "CIR", "CIRCLE", "#E8C400"],
    ["district", "DIS", "DISTRICT", "#0E8C3A"],
    ["hammersmith-city", "H&C", "HAM & CITY", "#E26E8F"],
    ["jubilee", "JUB", "JUBILEE", "#8A9096"],
    ["metropolitan", "MET", "METROPOLITAN", "#9B0056"],
    ["northern", "NOR", "NORTHERN", ""],
    ["piccadilly", "PIC", "PICCADILLY", "#1E4FA8"],
    ["victoria", "VIC", "VICTORIA", "#0098D4"],
    ["waterloo-city", "W&C", "WAT & CITY", "#46C08A"],
    ["elizabeth", "LIZ", "ELIZABETH", "#6950A1"],
    ["dlr", "DLR", "DLR", "#00A4A7"],
    ["liberty", "LIB", "LIBERTY", "#55585A"],
    ["lioness", "LIO", "LIONESS", "#FAA61A"],
    ["mildmay", "MIL", "MILDMAY", "#0077AD"],
    ["suffragette", "SUF", "SUFFRAGETTE", "#5BBD72"],
    ["weaver", "WEA", "WEAVER", "#823A62"],
    ["windrush", "WIN", "WINDRUSH", "#ED1B00"],
]

# Northern is "" above, on purpose: its official colour is #000000, which is
# nothing at all on an unlit panel. It is drawn as the only HOLLOW block --
# a one-pixel ink outline around black -- which is exactly how the dark tube
# map draws it, so Londoners parse it instantly and it can never be confused
# with Jubilee's filled grey.
HOLLOW = "#F4F7FF"

GOOD = "#2ECC40"
AMBER = "#FFB300"
SEVERE = "#FF6A00"
STOPPED = "#FF2D2D"
PLANNED = "#B07CFF"

def sev_colour(s):
    """TfL's statusSeverity is a number and lower is worse. Using it beats
    matching on the description string, which comes in a dozen spellings."""
    if s >= 10:
        return GOOD
    if s == 6:
        return SEVERE
    if s == 4 or s == 5 or s == 11:
        return PLANNED
    if s <= 3 or s == 16 or s == 20:
        return STOPPED
    return AMBER

# TfL's own numbering is not a commuter's ranking. It scores Planned Closure
# as 4 and Severe Delays as 6, so a scheduled weekend engineering closure sorts
# ABOVE an unplanned meltdown -- and the panel led with the Waterloo & City
# line's normal opening hours while the Metropolitan was in severe delays.
# A closure you have known about for a fortnight is not the news.
def rank(s):
    if s <= 2 or s == 16 or s == 20:
        return 0        # suspended, closed, not running
    if s == 3:
        return 1        # part suspended
    if s == 6:
        return 2        # severe delays
    if s == 5 or s == 11:
        return 3        # part closure
    if s == 4:
        return 4        # planned closure
    if s >= 10:
        return 99
    return 5            # minor delays, reduced, bus, diverted

def stopped(s):
    return s <= 3 or s == 16 or s == 20

def read_tube(ctx):
    st = {"state": "ok", "lines": [], "bad": 0, "worst": 99, "wsev": 10}
    r = http.get(TFL, ttl_seconds = 120)
    if r["status_code"] != 200 or r["json"] == None:
        st["state"] = "offline"
        return st
    j = r["json"]
    if type(j) != "list" or len(j) == 0:
        st["state"] = "offline"
        return st

    got = {}
    for l in j:
        if type(l) != "dict":
            continue
        lid = str(get(l, "id", ""))
        best, desc, why = 99, "GOOD SERVICE", ""
        for s in get(l, "lineStatuses", []):
            if type(s) != "dict":
                continue
            n = num(get(s, "statusSeverity", 10), 10)
            if n < best:
                best = n
                desc = str(get(s, "statusSeverityDescription", "")).upper()
                why = str(get(s, "reason", ""))
        got[lid] = [best, desc, why]

    for L in LINES:
        g = got[L[0]] if L[0] in got else [10, "GOOD SERVICE", ""]
        sev = g[0] if g[0] < 99 else 10
        row = {"code": L[1], "name": L[2], "colour": L[3], "id": L[0],
               "sev": sev, "desc": g[1], "why": clean_reason(g[2], L[2]),
               "col": sev_colour(sev), "stop": stopped(sev)}
        row["rank"] = rank(sev)
        st["lines"].append(row)
        if sev < 10:
            st["bad"] += 1
            if row["rank"] < st["worst"]:
                st["worst"] = row["rank"]
                st["wsev"] = sev
    return st

def clean_reason(s, name):
    """TfL prefixes every reason with the line's own name, which the panel has
    already said in colour. "Central Line: Minor delays due to train
    cancellations" only needs the half after the colon."""
    t = str(s).strip()
    i = t.find(": ")
    if i > 0 and i < 40:
        t = t[i + 2:]
    return t.upper().strip()

def worst_colour(st):
    return sev_colour(st.get("wsev", 10)) if st["bad"] > 0 else GOOD

def trouble(st):
    out = []
    for l in st["lines"]:
        if l["sev"] < 10:
            out.append(l)
    return sorted(out, key = lambda l: l["rank"])

# ---- pages ----------------------------------------------------------------
# The strip runs along the bottom of BOTH pages, so you can always check your
# own line while reading about somebody else's. Drama is additive: markers
# appear above the strip, rows appear above that, and the layout itself never
# changes.

STRIP_X = 11        # 19 segments, 8 wide, 1px gaps -> 11..180, centred
SEG_W = 8
SEG_Y = 29          # the colour blocks
MARK_Y = 27         # the status bar above a line in trouble

def seg_x(i):
    return STRIP_X + i * (SEG_W + 1)

def draw_strip(c, st):
    for i in range(len(st["lines"])):
        l = st["lines"][i]
        x = seg_x(i)
        if l["colour"] == "":
            # Northern: hollow ring, black inside. The only unfilled block on
            # the strip, which is what makes it identifiable at all.
            c.rect(x, SEG_Y, x + SEG_W - 1, SEG_Y, fill = HOLLOW)
            c.rect(x, SEG_Y + 2, x + SEG_W - 1, SEG_Y + 2, fill = HOLLOW)
            c.pixel(x, SEG_Y + 1, HOLLOW)
            c.pixel(x + SEG_W - 1, SEG_Y + 1, HOLLOW)
        else:
            # A line that is not running has its own colour dimmed to a third.
            # The panel cannot blink, and a block going dark reads as "this one
            # is off" faster than any word does.
            col = color.dim(l["colour"], 32) if l["stop"] else l["colour"]
            c.rect(x, SEG_Y, x + SEG_W - 1, SEG_Y + 2, fill = col)
        if l["sev"] < 10:
            c.rect(x, MARK_Y, x + SEG_W - 1, MARK_Y + 1, fill = l["col"])

def swatch(c, x, y, l):
    if l["colour"] == "":
        c.rect(x, y, x + 5, y, fill = HOLLOW)
        c.rect(x, y + 4, x + 5, y + 4, fill = HOLLOW)
        c.pixel(x, y + 1, HOLLOW)
        c.pixel(x, y + 2, HOLLOW)
        c.pixel(x, y + 3, HOLLOW)
        c.pixel(x + 5, y + 1, HOLLOW)
        c.pixel(x + 5, y + 2, HOLLOW)
        c.pixel(x + 5, y + 3, HOLLOW)
    else:
        c.rect(x, y, x + 5, y + 4, fill = l["colour"])

# --------------------------------------------------------------- page 1: tube
def tube(c, ctx):
    c.fill("black")
    st = read_tube(ctx)
    if st["state"] != "ok":
        rail(c, OFFLINE)
        tab(c, "TUBE", "#DC241F")
        message(c, "NO DATA FROM TFL", "CANT REACH THE TFL API")
        return
    rail(c, "#DC241F")
    tab(c, "TUBE", "#DC241F")
    draw_strip(c, st)

    if st["bad"] == 0:
        c.text(fmt.pad(ctx.now.hour, 2) + ":" + fmt.pad(ctx.now.minute, 2),
               189, 1, font = "3x7", color = DIM, align = "right")
        # The calm state is the app's resting face and gets the whole middle.
        c.text("GOOD SERVICE", 10, 13, font = "6x8", color = GOOD)
        c.text("ON ALL LINES", 10 + c.text_width("GOOD SERVICE ", "6x8"), 13,
               font = "6x8", color = DIM)
        return

    word = "ALERT" if st["bad"] == 1 else "ALERTS"
    c.text(str(st["bad"]) + " " + word, 189, 1, font = "3x7",
           color = worst_colour(st), align = "right")

    # The worst three get words. Everything else still shows as a marker on the
    # strip, so nothing is hidden -- the count and the markers carry the rest.
    bad = trouble(st)
    for i in range(len(bad)):
        if i > 2:
            break
        l = bad[i]
        y = 9 + i * 6
        swatch(c, 4, y, l)
        c.text(clip(c, l["name"], "4x5", 70), 12, y, font = "4x5", color = INK)
        c.text(clip(c, l["desc"], "4x5", 100), 189, y, font = "4x5",
               color = l["col"], align = "right")

# ------------------------------------------------------------- page 2: detail
# The why. TfL's own words, with the line's name stripped off the front because
# the chip has already said it in the line's own colour.
def detail(c, ctx):
    c.fill("black")
    st = read_tube(ctx)
    if st["state"] != "ok":
        rail(c, OFFLINE)
        tab(c, "WHY", "#DC241F")
        message(c, "NO DATA FROM TFL", "CANT REACH THE TFL API")
        return
    bad = trouble(st)
    if len(bad) == 0:
        rail(c, GOOD)
        tab(c, "WHY", GOOD)
        draw_strip(c, st)
        c.text("NOTHING TO REPORT", 96, 13, font = "6x8", color = GOOD,
               align = "center")
        return

    l = bad[0]
    rail(c, l["col"])
    draw_strip(c, st)

    # The chip carries the line's colour rather than the app's, so the page
    # announces which line it is about before a word is read.
    chip = l["colour"] if l["colour"] != "" else HOLLOW
    w = c.text_width(l["code"], "4x5")
    c.round_rect(4, 0, 4 + w + 3, 7, 2, fill = chip)
    c.text(l["code"], 6, 2, font = "4x5", color = "black")
    c.text(clip(c, l["desc"], "4x7", 96), 4 + w + 8, 0, font = "4x7",
           color = l["col"])
    if len(bad) > 1:
        c.text("+" + str(len(bad) - 1), 189, 1, font = "3x7", color = DIM,
               align = "right")

    txt = l["why"] if l["why"] != "" else l["desc"]
    y = 9
    for line in wrap_lines(c, txt, "4x5", 184, 3):
        c.text(line, 4, y, font = "4x5", color = INK)
        y += 6

def wrap_lines(c, text, font, maxw, maxlines):
    """Greedy word wrap. If it runs out of lines the last one gets an ellipsis,
    because text that simply stops at the panel edge reads as a bug."""
    out, cur, dropped = [], "", False
    for w in str(text).split(" "):
        if w == "":
            continue
        if dropped:
            continue
        t = w if cur == "" else cur + " " + w
        if c.text_width(t, font) <= maxw:
            cur = t
        elif len(out) + 1 < maxlines:
            out.append(cur)
            cur = w
        else:
            dropped = True
    if cur != "":
        out.append(cur)
    if dropped and len(out) > 0:
        # Clip the line FIRST, then add the ellipsis. Clipping the combined
        # string just trims the ellipsis back off the end again, which is why
        # the last line was still running flush to the panel edge.
        i = len(out) - 1
        room = maxw - c.text_width("...", font)
        out[i] = clip(c, out[i], font, room) + "..."
    return out
