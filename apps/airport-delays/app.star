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
    """The page chip. Same object, same place, on every page of every app.

    c.badge() sizes the pill around the text's INK -- exactly 1px of pill
    above and below the lit rows -- instead of around the font's row count,
    which left the glyphs riding high inside a hand-drawn round_rect."""
    w = c.badge(word, x, 0, color = "black", bg = accent, font = "4x5")
    return x + w + 1

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

# ---- FAA airport delays ---------------------------------------------------
# Which US airports are actually holding aircraft on the ground right now.
# Free, no key, and the only feed in this batch that is XML rather than JSON --
# so there is a small tag scraper below instead of r["json"].
#
# The scraper is deliberately dumb: find a tag, take what is between it and its
# closing tag. That is enough for a document this shape and it cannot be
# tricked into anything worse than an empty string.

FAA = "https://nasstatus.faa.gov/api/airport-status-information"

# Worst first. A closed airport outranks a ground stop, which outranks a ground
# delay programme, which outranks the general arrival/departure creep.
KINDS = [
    ["CLOSED", "#FF2D2D"],
    ["GROUND STOP", "#FF4FCB"],
    ["GROUND DELAY", "#FF6A00"],
    ["DELAYS", "#FFB300"],
]

def blocks(xml, name):
    """Every inner text of <name>...</name>, tolerating attributes on the open
    tag. The boundary check matters: searching for "<Ground_Delay" would
    otherwise match "<Ground_Delay_List" and swallow the whole list."""
    out, rest = [], str(xml)
    close = "</" + name + ">"
    for _ in range(80):
        i = rest.find("<" + name)
        if i < 0:
            return out
        nx = i + 1 + len(name)
        if nx >= len(rest):
            return out
        if rest[nx] != ">" and rest[nx] != " ":
            rest = rest[nx:]
            continue
        j = rest.find(">", i)
        k = rest.find(close, j)
        if j < 0 or k < 0:
            return out
        out.append(rest[j + 1:k])
        rest = rest[k + len(close):]
    return out

def one(xml, name):
    b = blocks(xml, name)
    return b[0].strip() if len(b) > 0 else ""

def compact(s):
    """"2 hours and 4 minutes" -> "2H04M". The FAA writes durations out in
    words, and words do not fit on a panel next to an airport code."""
    t = str(s).lower()
    h, m = 0, 0
    for part in t.split(" and "):
        n = num(part.strip().split(" ")[0], -1)
        if n < 0:
            n = 1 if part.strip().startswith("an ") or part.strip().startswith("a ") else -1
        if n < 0:
            continue
        if part.find("hour") >= 0:
            h = n
        elif part.find("minute") >= 0:
            m = n
    if h > 0:
        return str(h) + "H" + fmt.pad(m, 2)
    if m > 0:
        return str(m) + "M"
    return ""

# The general delay reasons arrive as colon-joined operations shorthand --
# "TM Initiatives:SWAP:WX" -- which means nothing to anyone outside a control
# tower. The commonest codes get expanded and the rest is passed through.
CODES = [
    ["TM INITIATIVES", "TRAFFIC MGMT"],
    ["SWAP", "SEVERE WEATHER"],
    ["WX", "WEATHER"],
    ["VOL", "VOLUME"],
    ["RWY", "RUNWAY"],
    ["EQUIP", "EQUIPMENT"],
]

def reason_words(s):
    t = str(s).upper().strip()
    if t == "":
        return ""
    parts = []
    for p in t.split(":"):
        p = p.strip()
        if p == "":
            continue
        for cd in CODES:
            if p == cd[0]:
                p = cd[1]
        if p not in parts:
            parts.append(p)
    out = ""
    for p in parts:
        out = p if out == "" else out + " / " + p
    return out

def trim_tail(t):
    """Drop a dangling connective left behind by clipping.

    "Disabled aircraft on the runway" cut to width lands on "DISABLED AIRCRAFT
    ON THE", which reads like the panel gave up mid-sentence. Ending on
    "DISABLED AIRCRAFT" says the same thing and looks deliberate."""
    out = str(t).strip()
    for _ in range(3):
        cut = False
        for w in ["THE", "ON", "A", "AN", "OF", "AND", "TO", "AT", "DUE", "FOR", "/"]:
            tail = " " + w
            if out.endswith(tail):
                out = out[:len(out) - len(tail)].strip()
                cut = True
        if not cut:
            return out
    return out

def read_faa(ctx):
    st = {"state": "ok", "rows": [], "updated": ""}
    r = http.get(FAA, ttl_seconds = 300)
    if r["status_code"] != 200:
        st["state"] = "offline"
        return st
    x = str(r["body"])
    if x.find("AIRPORT_STATUS_INFORMATION") < 0:
        st["state"] = "offline"
        return st
    st["updated"] = one(x, "Update_Time")

    for b in blocks(one(x, "Airport_Closure_List"), "Airport"):
        st["rows"].append([0, one(b, "ARPT"), "",
                           reason_words(one(b, "Reason")),
                           "REOPENS " + one(b, "Reopen")])
    for b in blocks(one(x, "Ground_Stop_List"), "Program"):
        st["rows"].append([1, one(b, "ARPT"), "",
                           reason_words(one(b, "Reason")),
                           "UNTIL " + one(b, "End_Time").upper()])
    for b in blocks(one(x, "Ground_Delay_List"), "Ground_Delay"):
        st["rows"].append([2, one(b, "ARPT"), compact(one(b, "Avg")),
                           reason_words(one(b, "Reason")),
                           "MAX " + compact(one(b, "Max"))])
    for b in blocks(one(x, "Arrival_Departure_Delay_List"), "Delay"):
        ad = one(b, "Arrival_Departure")
        st["rows"].append([3, one(b, "ARPT"), compact(one(ad, "Max")),
                           reason_words(one(b, "Reason")),
                           one(ad, "Trend").upper()])

    st["rows"] = sorted(st["rows"], key = lambda r: r[0])
    if len(st["rows"]) == 0:
        st["state"] = "clear"
    return st

def kind_of(r):
    return KINDS[r[0]] if r[0] < len(KINDS) else KINDS[3]

# ---- pages ----------------------------------------------------------------

# Right-aligned anchor for the whole right-hand column: the page-status word,
# the airport count, and the stacked qualifier lines all end here. Back at the
# original 188, four pixels in from the panel edge.
RIGHT = 188

# Bottom lit row of each font's uppercase/digit glyphs, for bottom-aligning
# text whose font rung is chosen at runtime.
INK_BOT = {"16x20": 19, "10x16": 14, "8x12": 11, "4x5": 4}

def bottom_y(font, base):
    """y that lands `font`'s last lit row on `base`."""
    return base - INK_BOT.get(font, 0)

def two_lines(c, text, font, maxw):
    """[line1, line2] -- label and value on top, the trailing qualifiers
    ("AM EDT", "UTC") stacked underneath. Line one takes at most two words and
    only what actually fits; whatever is left drops to line two and is clipped
    there, so a long tail wraps instead of running past the panel edge."""
    words = []
    for w in str(text).split(" "):
        if w != "":
            words.append(w)
    if maxw < 4 or len(words) == 0:
        return ["", ""]
    l1, used = "", 0
    for i in range(len(words)):
        if i >= 2:
            break
        cand = words[i] if l1 == "" else l1 + " " + words[i]
        if c.text_width(cand, font) > maxw and l1 != "":
            break
        l1 = cand
        used = i + 1
    if used == 0:
        return [clip(c, words[0], font, maxw), ""]
    l2 = ""
    for w in words[used:]:
        l2 = w if l2 == "" else l2 + " " + w
    return [clip(c, l1, font, maxw), clip(c, l2, font, maxw)]

def fail(c, st, word):
    if st["state"] == "offline":
        rail(c, OFFLINE)
        tab(c, word, "#FF6A00")
        message(c, "NO FAA DATA", "CANT REACH NASSTATUS.FAA.GOV")
        return True
    if st["state"] == "clear":
        rail(c, "#00E36B")
        tab(c, word, "#00E36B")
        c.text("NO DELAYS", 96, 10, font = "8x12", color = "#00E36B",
               align = "center")
        c.text("EVERY US AIRPORT RUNNING NORMALLY", 96, 25, font = "4x5",
               color = DIM, align = "center")
        return True
    return False

# --------------------------------------------------------------- page 1: faa
def faa(c, ctx):
    c.fill("black")
    st = read_faa(ctx)
    if fail(c, st, "FAA"):
        return
    top = kind_of(st["rows"][0])
    rail(c, top[1])
    tab(c, "FAA", top[1])
    n = len(st["rows"])
    c.text(str(n) + (" AIRPORT" if n == 1 else " AIRPORTS"), RIGHT, 2,
           font = "4x5", color = top[1], align = "right")

    # Four rows on a six-pixel pitch from y=9. Everything is packed to the
    # LEFT of the row rather than the reason being flung to the right margin:
    # a code, a duration and a cause sitting apart with 90px of black between
    # them read as three unrelated columns instead of one airport's story.
    for i in range(n):
        if i > 3:
            break
        r = st["rows"][i]
        k = kind_of(r)
        y = 9 + i * 6
        c.rect(4, y, 6, y + 4, fill = k[1])

        # Four letters of code clear the duration column; with no duration the
        # code may run on to where the reason starts. Codes are not promised to
        # be three characters, and an uncut one walked into the "12H45".
        c.text(clip(c, r[1], "4x5", 19 if r[2] != "" else 44), 10, y,
               font = "4x5", color = INK)
        if r[2] != "":
            c.text(r[2], 54, y, font = "4x5", color = k[1], align = "right")
        c.text(trim_tail(clip_words(c, r[3], "4x5", 128)), 60, y, font = "4x5",
               color = DIM)

# ------------------------------------------------------------- page 2: worst
# The single worst airport, big enough to read from the other side of a
# departure lounge, with the detail the list row had no room for.
def worst(c, ctx):
    c.fill("black")
    st = read_faa(ctx)
    if fail(c, st, "WORST"):
        return
    r = st["rows"][0]
    k = kind_of(r)
    rail(c, k[1])
    tab(c, "WORST", k[1])
    c.text(k[0], RIGHT, 2, font = "4x5", color = k[1], align = "right")

    # The code and the cause both sit ON the bottom line -- last lit row at
    # y=29, two clear pixels under it -- so the top half of the right column is
    # free for the time to wrap onto two rows. Codes are usually three letters
    # but nothing in the feed promises that, so the hero drops a font rung
    # rather than growing into the column beside it.
    idf, idt = fit(c, r[1], ["16x20", "10x16", "8x12"], 68)
    c.text(idt, 4, bottom_y(idf, 29), font = idf, color = INK)
    bx = 4 + c.text_width(idt, idf) + 5

    extra = r[4].strip()
    if extra in ["MAX", "UNTIL", "REOPENS"]:
        extra = ""
    dw = 0
    if r[2] != "":
        c.text(r[2], bx, 9, font = "8x12", color = k[1])
        dw = c.text_width(r[2], "8x12") + 3
    if extra != "":
        # Measured off whatever the duration actually took, so the two lines
        # can never reach back into it however long the code or the wait is.
        lines = two_lines(c, extra, "4x5", RIGHT - (bx + dw) - 3)
        c.text(lines[0], RIGHT, 11, font = "4x5", color = DIM, align = "right")
        if lines[1] != "":
            c.text(lines[1], RIGHT, 17, font = "4x5", color = DIM,
                   align = "right")
    if r[3] != "":
        c.text(trim_tail(clip_words(c, r[3], "4x5", 188 - bx)), bx,
               bottom_y("4x5", 29), font = "4x5", color = INK)
