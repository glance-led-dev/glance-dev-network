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

# ---- prayer times ---------------------------------------------------------
# The five daily prayers for a place, and how long until the next one.
# aladhan.com is free and needs no key.
#
# Times are returned in the CITY's timezone while ctx.now is the panel's, so
# the countdown assumes the panel is in the city it is showing -- which is the
# only way anybody actually uses this. The help text says so.

ALADHAN = "https://api.aladhan.com/v1/timingsByCity"
NOW_URL = "https://api.aladhan.com/v1/currentTime"

# Name -> aladhan's method id. The convention is not cosmetic: Fajr and Isha
# angles differ by several degrees between them, which moves those two prayers
# by real minutes. Shipping one hardcoded method to the whole world was wrong.
METHODS = {
    "Muslim World League": 3,
    "Islamic Society of North America (ISNA)": 2,
    "Umm Al-Qura University, Makkah": 4,
    "Egyptian General Authority of Survey": 5,
    "University of Islamic Sciences, Karachi": 1,
    "Shia Ithna-Ashari, Leva Institute, Qum": 0,
    "Institute of Geophysics, University of Tehran": 7,
    "Gulf Region": 8,
    "Kuwait": 9,
    "Qatar": 10,
    "Majlis Ugama Islam Singapura, Singapore": 11,
    "Union Organization Islamic de France": 12,
    "Diyanet Isleri Baskanligi, Turkey": 13,
    "Spiritual Administration of Muslims of Russia": 14,
    "Moonsighting Committee Worldwide": 15,
    "Dubai": 16,
    "Jabatan Kemajuan Islam Malaysia (JAKIM)": 17,
    "Tunisia": 18,
    "Algeria": 19,
    "Kementerian Agama Republik Indonesia": 20,
    "Morocco": 21,
    "Comunidade Islamica de Lisboa": 22,
    "Ministry of Awqaf, Jordan": 23
}

# The five obligatory prayers, in the order they fall. Sunrise and the two
# thirds of the night come back in the same payload and are deliberately not
# shown: they are not prayers, and five things fit a 192px row cleanly.
PRAYERS = [
    ["FAJR", "Fajr", "#7FE9FF"],
    ["DHUHR", "Dhuhr", "#FFD166"],
    ["ASR", "Asr", "#FFB300"],
    ["MAGHRIB", "Maghrib", "#FF6A00"],
    ["ISHA", "Isha", "#B49BF0"],
]

# The API returns the month name with diacritics (Rabi with a macron and an
# ayn) which no panel font has, and drawText silently drops missing glyphs.
# So the month comes from its number and this table instead.
HIJRI = ["", "MUHARRAM", "SAFAR", "RABI AL-AWWAL", "RABI AL-THANI",
         "JUMADA AL-AWWAL", "JUMADA AL-THANI", "RAJAB", "SHABAN", "RAMADAN",
         "SHAWWAL", "DHU AL-QIDAH", "DHU AL-HIJJAH"]

def hhmm(s):
    """'04:12' or '04:12 (BST)' -> minutes past midnight, or -1."""
    t = str(s).strip().split(" ")[0]
    bits = t.split(":")
    if len(bits) < 2:
        return -1
    h, m = num(bits[0], -1), num(bits[1], -1)
    if h < 0 or m < 0:
        return -1
    return h * 60 + m

def clock_of(mins):
    if mins < 0:
        return "--:--"
    return fmt.pad(mins // 60, 2) + ":" + fmt.pad(mins % 60, 2)

def gap_words(mins):
    if mins < 1:
        return "NOW"
    if mins < 60:
        return str(mins) + "M"
    return str(mins // 60) + "H " + fmt.pad(mins % 60, 2) + "M"

def split_city(choice):
    """"Kuala Lumpur, Malaysia" -> ["Kuala Lumpur", "Malaysia"]. Split on the
    LAST comma, because a city name can contain one and a country rarely does."""
    t = str(choice).strip()
    i = t.rfind(", ")
    if i < 0:
        return [t, ""]
    return [t[:i].strip(), t[i + 2:].strip()]

def read_prayer(ctx):
    parts = split_city(ctx.inputs.get("city", ""))
    city, country = parts[0], parts[1]
    mname = str(ctx.inputs.get("method", "")).strip()
    method = METHODS[mname] if mname in METHODS else 3
    st = {"state": "ok", "city": city.upper(), "times": [], "next": -1,
          "hijri": "", "now": ctx.now.hour * 60 + ctx.now.minute, "local": False}
    if city == "" or country == "":
        st["state"] = "setup"
        return st

    # The bare endpoint answers 302 to the same path with today's date in it,
    # and the SDK's http.get does not follow redirects -- so the date goes in
    # up front. That is also just more honest: the app asks for the day it is
    # actually showing instead of whatever the server thinks today is.
    day = (fmt.pad(ctx.now.day, 2) + "-" + fmt.pad(ctx.now.month, 2) + "-" +
           str(ctx.now.year))
    url = (ALADHAN + "/" + day + "?method=" + str(method) + "&city=" +
           city.replace(" ", "%20") + "&country=" +
           country.replace(" ", "%20"))
    r = http.get(url, ttl_seconds = 3600)
    if r["status_code"] == 400 or r["status_code"] == 404:
        st["state"] = "badcity"
        return st
    if r["status_code"] != 200 or r["json"] == None:
        st["state"] = "offline"
        return st
    d = dig(r["json"], ["data"], None)
    if d == None:
        st["state"] = "offline"
        return st

    tim = get(d, "timings", {})
    for p in PRAYERS:
        st["times"].append([p[0], hhmm(get(tim, p[1], "")), p[2]])

    # The countdown used to assume the panel stood in the city it was showing.
    # Now that the city is picked from a list it is far more likely to be
    # somewhere else, so the city's own wall clock is asked for directly --
    # which also covers the zones no static rule can express, like Morocco
    # stepping back an hour for Ramadan.
    tz = str(dig(d, ["meta", "timezone"], "")).strip()
    if tz != "":
        nr = http.get(NOW_URL + "?zone=" + tz, ttl_seconds = 120)
        if nr["status_code"] == 200 and nr["json"] != None:
            hm = hhmm(dig(nr["json"], ["data"], ""))
            if hm >= 0:
                st["now"] = hm
                st["local"] = True

    hn = num(dig(d, ["date", "hijri", "month", "number"], 0), 0)
    hd = str(dig(d, ["date", "hijri", "day"], "")).strip()
    hy = str(dig(d, ["date", "hijri", "year"], "")).strip()
    if hn >= 1 and hn <= 12 and hd != "":
        st["hijri"] = hd + " " + HIJRI[hn] + " " + hy

    # The next prayer still to come today; after Isha it is tomorrow's Fajr,
    # which is the only wrap this app has to handle.
    for i in range(len(st["times"])):
        if st["times"][i][1] > st["now"]:
            st["next"] = i
            break
    if st["next"] < 0 and len(st["times"]) > 0:
        st["next"] = 0
    return st

def until(st):
    """Minutes to the next prayer, wrapping midnight after Isha."""
    if st["next"] < 0:
        return -1
    t = st["times"][st["next"]][1]
    if t < 0:
        return -1
    d = t - st["now"]
    return d if d >= 0 else d + 1440

def since(st):
    """Minutes since the prayer before the next one -- the other half of the
    progress bar. Before Fajr that is yesterday's Isha."""
    if st["next"] < 0:
        return -1
    p = st["next"] - 1
    if p < 0:
        p = len(st["times"]) - 1
    t = st["times"][p][1]
    if t < 0:
        return -1
    d = st["now"] - t
    return d if d >= 0 else d + 1440

# ---- pages ----------------------------------------------------------------
# Page one answers the only question anybody has between prayers: how long have
# I got. Page two is the whole day at a glance, with what has passed dimmed and
# what is next lit -- so the shape of the day is legible without reading a
# single number.

def big_time(c, right, y, mins, col):
    """HH:MM in 8x12, right-aligned, with the colon drawn by hand.

    8x12's own colon is a pair of fat 6x4 diamonds -- the same class of defect
    as its hyphen, which is a solid block. On a clock face that is the one
    glyph you cannot afford to have wrong, so the hours and minutes are set
    separately and two 2x2 squares go in the gap. The font is left alone: the
    panel firmware ships the same bitmaps, and changing them here would break
    preview/panel parity."""
    hh, mm = fmt.pad(mins // 60, 2), fmt.pad(mins % 60, 2)
    wh, wm = c.text_width(hh, "8x12"), c.text_width(mm, "8x12")
    sx = right - (wh + 7 + wm)
    c.text(hh, sx, y, font = "8x12", color = col)
    cx = sx + wh + 2
    c.rect(cx, y + 3, cx + 1, y + 4, fill = col)
    c.rect(cx, y + 7, cx + 1, y + 8, fill = col)
    c.text(mm, sx + wh + 7, y, font = "8x12", color = col)

def fail(c, st, word):
    tab(c, word, "#7FE9FF")
    if st["state"] == "setup":
        rail(c, STRUCT)
        message(c, "ADD A CITY", "CITY AND TWO-LETTER COUNTRY CODE")
        return True
    if st["state"] == "badcity":
        rail(c, STRUCT)
        message(c, "CITY NOT FOUND", "CHECK THE CITY AND COUNTRY")
        return True
    if st["state"] == "offline":
        rail(c, OFFLINE)
        message(c, "NO PRAYER TIMES", "CANT REACH ALADHAN.COM")
        return True
    return False

# -------------------------------------------------------------- page 1: next
def nextup(c, ctx):
    c.fill("black")
    st = read_prayer(ctx)
    if fail(c, st, "NEXT"):
        return
    n = st["next"]
    if n < 0 or st["times"][n][1] < 0:
        rail(c, OFFLINE)
        tab(c, "NEXT", "#7FE9FF")
        message(c, "NO TIMES TODAY", "THE FEED RETURNED NOTHING USABLE")
        return
    p = st["times"][n]
    col = p[2]
    rail(c, col)
    tab(c, "NEXT", col)
    if st["city"] != "":
        c.text(clip(c, st["city"], "4x5", 140), 184, 2, font = "4x5",
               color = DIM, align = "right")

    c.text(clip(c, p[0], "8x12", 80), 4, 10, font = "8x12", color = INK)
    big_time(c, 184, 10, p[1], col)

    # The bar runs from the previous prayer to this one, so the fill is how
    # much of this interval has gone rather than an abstract percentage.
    gone, left = since(st), until(st)
    if gone >= 0 and left >= 0 and gone + left > 0:
        pct = gone * 100 // (gone + left)
        pct_bar(c, 4, 25, 110, 4, pct, col)
    c.text("IN " + gap_words(left), 184, 25, font = "4x5", color = INK,
           align = "right")

# ------------------------------------------------------------- page 2: today
def today(c, ctx):
    c.fill("black")
    st = read_prayer(ctx)
    if fail(c, st, "TODAY"):
        return
    n = st["next"]
    col = st["times"][n][2] if n >= 0 else "#7FE9FF"
    rail(c, col)
    tab(c, "TODAY", col)
    if st["hijri"] != "":
        c.text(clip(c, st["hijri"], "4x5", 140), 188, 2, font = "4x5",
               color = DIM, align = "right")
    elif st["city"] != "":
        c.text(clip(c, st["city"], "4x5", 140), 188, 2, font = "4x5",
               color = DIM, align = "right")

    # Five even columns. A prayer that has passed goes to structure grey, the
    # next one keeps its colour and gets a rule under it; the rest sit in ink.
    for i in range(len(st["times"])):
        t = st["times"][i]
        x = 4 + i * 37
        mid = x + 18
        if i == n:
            nc, tc = t[2], t[2]
        elif t[1] <= st["now"]:
            nc, tc = "#4A5060", "#5A6072"
        else:
            nc, tc = DIM, INK
        c.text(t[0], mid, 11, font = "4x5", color = nc, align = "center")
        c.text(clock_of(t[1]), mid, 19, font = "4x7", color = tc,
               align = "center")
        if i == n:
            c.rect(x + 2, 28, x + 33, 28, fill = t[2])
