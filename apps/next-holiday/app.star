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
    """The page chip - drawn with c.badge so the text sits ink-centered in
    the pill (1px above and below, >=2px sides) per the design guidelines."""
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

# ---- next holiday ---------------------------------------------------------
# Nager.Date, free, no key, 100-odd countries. It returns the next dozen or so
# public holidays already sorted, which is exactly the shape this app wants.

NAGER = "https://date.nager.at/api/v3/NextPublicHolidays/"

MONTHS = ["", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY",
          "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
MON3 = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP",
        "OCT", "NOV", "DEC"]
DAYS = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY",
        "SUNDAY"]

# What the panel fonts can actually draw. drawText skips a missing glyph at
# zero width and says nothing, so an unrenderable string does not look wrong --
# it looks EMPTY, which is far worse. Japan's localName is a row of kanji and
# rendered as a completely blank panel until this existed.
DRAWABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,'-&/()!:"

def renderable(s):
    t = str(s).upper()
    if t.strip() == "":
        return False
    for ch in t.elems():
        if DRAWABLE.find(ch) < 0:
            return False
    return True

def best_name(local, english):
    """The local name is what people in the country actually call it, so it
    wins whenever the panel can draw it. Accents lose too -- Spain's "Dia de la
    Hispanidad" would come out as "DA DE LA HISPANIDAD" -- so anything outside
    the drawable set falls back to Nager's English gloss."""
    if renderable(local):
        return str(local).upper()
    if renderable(english):
        return str(english).upper()
    return "PUBLIC HOLIDAY"

def read_holidays(ctx):
    cc = str(ctx.inputs.get("country", "")).strip().upper()
    st = {"state": "ok", "cc": cc, "list": []}
    if len(cc) != 2:
        st["state"] = "setup"
        return st
    r = http.get(NAGER + cc, ttl_seconds = 21600)
    if r["status_code"] == 404 or r["status_code"] == 400:
        st["state"] = "badcountry"
        return st
    if r["status_code"] != 200 or r["json"] == None:
        st["state"] = "offline"
        return st
    j = r["json"]
    if type(j) != "list":
        st["state"] = "offline"
        return st

    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    for h in j:
        if type(h) != "dict":
            continue
        d = str(get(h, "date", ""))
        if len(d) < 10:
            continue
        y, m, dd = num(d[0:4], -1), num(d[5:7], -1), num(d[8:10], -1)
        if y < 0 or m < 1 or m > 12 or dd < 1:
            continue
        z = days_from_civil(y, m, dd)
        st["list"].append({
            "name": best_name(get(h, "localName", ""), get(h, "name", "")),
            "en": str(get(h, "name", "")).upper(),
            "y": y, "m": m, "d": dd, "z": z,
            "in": z - today,
            "global": get(h, "global", True) == True,
        })
    if len(st["list"]) == 0:
        st["state"] = "empty"
    return st

def when_words(n):
    if n <= 0:
        return "TODAY"
    if n == 1:
        return "TOMORROW"
    if n < 21:
        return "IN " + str(n) + " DAYS"
    if n < 60:
        w = n // 7
        return "IN " + str(w) + " WEEKS"
    return "IN " + str(n) + " DAYS"

def long_date(h):
    return (DAYS[weekday(h["z"])] + " " + str(h["d"]) + " " +
            MONTHS[h["m"]] + " " + str(h["y"]))

def short_date(h):
    return str(h["d"]) + " " + MON3[h["m"]]

def heat(n):
    """Closer is hotter. A holiday four months out should not shout in the same
    colour as one tomorrow."""
    if n <= 0:
        return "#FF4FCB"
    if n <= 3:
        return "#FF6A00"
    if n <= 14:
        return "#FFB300"
    if n <= 45:
        return "#7FE9FF"
    return "#78DCFF"

# ---- pages ----------------------------------------------------------------

def fail(c, st, word):
    tab(c, word, "#78DCFF")
    if st["state"] == "setup":
        rail(c, STRUCT)
        message(c, "ADD A COUNTRY", "TWO-LETTER CODE LIKE US GB DE JP")
        return True
    if st["state"] == "badcountry":
        rail(c, STRUCT)
        message(c, "COUNTRY NOT FOUND", "CHECK THE TWO-LETTER CODE")
        return True
    if st["state"] == "empty":
        rail(c, STRUCT)
        message(c, "NO HOLIDAYS LISTED", "NOTHING SCHEDULED FOR THIS COUNTRY")
        return True
    if st["state"] == "offline":
        rail(c, OFFLINE)
        message(c, "NO HOLIDAY DATA", "CANT REACH DATE.NAGER.AT")
        return True
    return False

# ----------------------------------------------------------- page 1: holiday
def holiday(c, ctx):
    c.fill("black")
    st = read_holidays(ctx)
    if fail(c, st, "HOLIDAY"):
        return
    h = st["list"][0]
    col = heat(h["in"])
    rail(c, col)
    x = tab(c, "HOLIDAY", col)
    c.text(when_words(h["in"]), 182, 2, font = "4x5", color = col,
           align = "right")

    hf = fit(c, h["name"], ["8x12", "6x8", "5x7"], 184)
    c.text(hf[1], 4, 10 if hf[0] == "8x12" else 12, font = hf[0], color = INK)

    sub = long_date(h)
    if not h["global"]:
        # Nager flags holidays that only apply in some regions. Saying so is
        # the difference between a day off and a day off somewhere else.
        sub = sub + "   REGIONAL"
    c.text(clip(c, sub, "4x5", 184), 4, 25, font = "4x5", color = DIM)

# ------------------------------------------------------------- page 2: ahead
def ahead(c, ctx):
    c.fill("black")
    st = read_holidays(ctx)
    if fail(c, st, "AHEAD"):
        return
    col = heat(st["list"][0]["in"])
    rail(c, col)
    tab(c, "AHEAD", col)
    c.text(st["cc"], 182, 2, font = "4x5", color = DIM, align = "right")

    # Four rows fill the panel exactly: 4x5 is five tall on a six-row pitch
    # from y=9, which lands the last one on 27..31 with nothing to spare.
    for i in range(len(st["list"])):
        if i > 3:
            break
        h = st["list"][i]
        y = 9 + i * 6
        hc = heat(h["in"])
        c.text(short_date(h), 4, y, font = "4x5", color = hc)
        c.text(clip(c, h["name"], "4x5", 108), 40, y, font = "4x5",
               color = INK if i == 0 else DIM)
        c.text(str(h["in"]) + "D", 182, y, font = "4x5", color = hc,
               align = "right")
