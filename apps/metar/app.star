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

# ---- METAR ----------------------------------------------------------------
# An airport weather observation, as pilots read it. The one thing a pilot
# wants from across a room is the flight category -- VFR, MVFR, IFR, LIFR --
# which is a four-way answer to "can I fly today", so it is a coloured badge
# and everything else is subordinate to it.
#
# aviationweather.gov is the US National Weather Service's own service. It is
# free, needs no key, and hands back the category already computed, which
# spares this app from re-deriving a rule that has real edge cases in it.

AWC = "https://aviationweather.gov/api/data/metar?format=json&ids="

# The categories, in the order they get worse.
CATS = {
    "VFR": ["#00E36B", "CLEAR TO FLY"],
    "MVFR": ["#2BA7FF", "MARGINAL"],
    "IFR": ["#FF6A00", "INSTRUMENT ONLY"],
    "LIFR": ["#FF2D2D", "LOW INSTRUMENT"],
}

COVER = {
    "SKC": ["CLEAR", 0], "CLR": ["CLEAR", 0], "CAVOK": ["CLEAR", 0],
    "FEW": ["FEW", 2], "SCT": ["SCATTERED", 4], "BKN": ["BROKEN", 7],
    "OVC": ["OVERCAST", 12], "OVX": ["OBSCURED", 12],
}

def short_name(n):
    bits = n.split(",")
    if len(bits) >= 2:
        return bits[0].strip() + ", " + bits[1].strip()
    return n.strip()

def cat_of(m):
    c = str(m["cat"]).upper()
    return CATS[c] if c in CATS else ["#9AA6B8", ""]

def read_metar(ctx):
    ids = str(ctx.inputs.get("airport", "")).strip().upper().replace(" ", "")
    st = {"state": "ok", "id": ids}
    if ids == "":
        st["state"] = "setup"
        return st
    r = http.get(AWC + ids, ttl_seconds = 1800)
    if r["status_code"] != 200 or r["json"] == None:
        st["state"] = "offline"
        return st
    j = r["json"]
    if type(j) != "list" or len(j) == 0:
        st["state"] = "nostation"
        return st
    d = j[0]

    layers = []
    for cl in get(d, "clouds", []):
        if type(cl) != "dict":
            continue
        cv = str(get(cl, "cover", "")).upper()
        if cv == "":
            continue
        layers.append([cv, num(get(cl, "base", -1), -1)])

    # The ceiling is the lowest broken or overcast layer, not the lowest cloud.
    # Scattered cloud has holes in it and does not make a ceiling, which is the
    # distinction the whole category system turns on.
    ceil = -1
    for L in layers:
        if L[0] in ["BKN", "OVC", "OVX"] and L[1] >= 0:
            if ceil < 0 or L[1] < ceil:
                ceil = L[1]

    st["m"] = {
        "id": str(get(d, "icaoId", ids)).upper(),
        # "NEW YORK/JF KENNEDY INTL, NY, US" -- the country is the least
        # useful third of that on a panel already showing the ICAO code.
        "name": short_name(str(get(d, "name", "")).upper()),
        "cat": str(get(d, "fltCat", "")).upper(),
        "temp": intpart(get(d, "temp", None), -999),
        "dewp": intpart(get(d, "dewp", None), -999),
        "wdir": get(d, "wdir", None),
        "wspd": intpart(get(d, "wspd", 0), 0),
        "wgst": intpart(get(d, "wgst", 0), 0),
        "visib": str(get(d, "visib", "")),
        "altim": intpart(get(d, "altim", 0), 0),
        "layers": layers,
        "ceil": ceil,
        "obs": num(get(d, "obsTime", 0), 0),
        "raw": str(get(d, "rawOb", "")).upper(),
    }
    return st

def wind_words(m):
    """Wind as a person says it out loud. VRB is a real value the feed sends as
    a string, and calm is a wind of zero from no direction at all."""
    if m["wspd"] <= 0:
        return "CALM"
    d = m["wdir"]
    head = "VRB" if str(d).upper() == "VRB" or d == None else fmt.pad(int(d), 3)
    out = head + "/" + str(m["wspd"])
    if m["wgst"] > 0:
        out = out + "G" + str(m["wgst"])
    return out + "KT"

def vis_words(m):
    v = m["visib"].strip()
    if v == "":
        return "--"
    # "10+" means ten statute miles or better and is the commonest value there
    # is; rendering it as "10+SM" keeps the plus, which carries the meaning.
    return v + "SM"

def ceil_words(m):
    if m["ceil"] < 0:
        return "NONE"
    if m["ceil"] >= 1000:
        return str(m["ceil"] // 1000) + "," + fmt.pad(m["ceil"] % 1000, 3) + "FT"
    return str(m["ceil"]) + "FT"

def press_words(m):
    """Altimeter setting. The feed is always in hectopascals; the United States
    and a handful of others fly on inches of mercury, so a K or P station gets
    the number its pilots actually dial into the subscale."""
    if m["altim"] <= 0:
        return "--"
    if m["id"].startswith("K") or m["id"].startswith("P"):
        h = int(m["altim"] * 100.0 / 33.8639 + 0.5)
        return str(h // 100) + "." + fmt.pad(h % 100, 2) + "IN"
    return str(m["altim"]) + "HPA"

def spread(m):
    """Temperature minus dewpoint. A small spread is fog, and it is the one
    piece of arithmetic on the page worth doing for the reader."""
    if m["temp"] == -999 or m["dewp"] == -999:
        return -999
    return m["temp"] - m["dewp"]

# ---- pages ----------------------------------------------------------------
# The flight category is the whole app. VFR, MVFR, IFR, LIFR is a four-way
# answer to "can I fly today", and it is the one thing that has to be readable
# from the other side of a hangar -- so it is a filled badge in its own colour
# and everything else on the panel is subordinate to it.

DEG = 3.141592653589793 / 180.0

def arrow(c, cx, cy, bearing, col, r):
    """An arrow pointing where the air is GOING. Meteorology names a wind by
    where it comes from -- a 230 wind blows toward 050 -- so the number and the
    picture disagree on purpose, and the number is labelled with its bearing
    while the arrow shows the flow the way a weather map does."""
    a = bearing * DEG
    fx, fy = math.sin(a), -math.cos(a)
    hx, hy = cx + fx * r, cy + fy * r
    c.line(int(cx - fx * r), int(cy - fy * r), int(hx), int(hy), col)
    for s in [-1, 1]:
        bx = hx - fx * 3.8 - fy * s * 2.6
        by = hy - fy * 3.8 + fx * s * 2.6
        c.line(int(hx), int(hy), int(bx), int(by), col)

def fail(c, st, word):
    tab(c, word, "#78DCFF")
    if st["state"] == "setup":
        rail(c, STRUCT)
        message(c, "ADD AN AIRPORT", "AN ICAO CODE LIKE KJFK OR EGLL")
        return True
    if st["state"] == "nostation":
        rail(c, STRUCT)
        message(c, "NO REPORT FOR " + clip(c, st["id"], "5x7", 60),
                "CHECK THE ICAO CODE")
        return True
    if st["state"] == "offline":
        rail(c, OFFLINE)
        message(c, "NO WEATHER DATA", "CANT REACH AVIATIONWEATHER.GOV")
        return True
    return False

# ------------------------------------------------------------- page 1: metar
def metar(c, ctx):
    c.fill("black")
    st = read_metar(ctx)
    if fail(c, st, "METAR"):
        return
    m = st["m"]
    cat = cat_of(m)
    col = cat[0]
    rail(c, col)
    tab(c, "METAR", col)
    if m["name"] != "":
        c.text(clip(c, m["name"], "4x5", 146), 188, 2, font = "4x5",
               color = DIM, align = "right")

    c.text(clip(c, m["id"], "8x12", 40), 4, 10, font = "8x12", color = INK)

    # The badge. A filled chip in the category's own colour, black text, so the
    # answer survives being seen from an angle or through a workshop door.
    if m["cat"] != "":
        c.badge(m["cat"], 46, 11, color = "black", bg = col, font = "6x8", pad = 3)

    if m["wspd"] > 0 and str(m["wdir"]).upper() != "VRB" and m["wdir"] != None:
        arrow(c, 112, 16, (m["wdir"] + 180) % 360, "#7FE9FF", 8)
    c.text(wind_words(m), 188, 12, font = "4x7", color = INK, align = "right")

    c.text("VIS", 4, 25, font = "4x5", color = DIM)
    c.text(vis_words(m), 24, 25, font = "4x5", color = INK)
    c.text("CEILING", 78, 25, font = "4x5", color = DIM)
    cc = INK if m["ceil"] < 0 else col
    c.text(ceil_words(m), 118, 25, font = "4x5", color = cc)

# --------------------------------------------------------------- page 2: sky
# A side elevation of the sky above the field. Cloud is drawn at its real base
# on a square-root scale, densest layer densest on the panel, which is the one
# thing a text report cannot show you: how much sky is left.
GND = 25

def layer_y(base):
    b = base
    if b < 0:
        b = 0
    if b > 12000:
        b = 12000
    return GND - int(15.0 * math.sqrt(b / 12000.0) + 0.5)

def sky(c, ctx):
    c.fill("black")
    st = read_metar(ctx)
    if fail(c, st, "SKY"):
        return
    m = st["m"]
    col = cat_of(m)[0]
    rail(c, col)
    tab(c, "SKY", col)
    c.text(m["id"], 182, 2, font = "4x5", color = DIM, align = "right")

    c.line(4, GND, 100, GND, STRUCT)

    # Highest first, so the label stack can be pushed apart downward without
    # ever crossing a band it does not belong to.
    order = sorted(m["layers"], key = lambda L: -L[1])
    if len(order) == 0:
        c.text("CLEAR BELOW 12,000FT", 52, 14, font = "4x5", color = DIM,
               align = "center")
    # Bands are drawn at their true heights; the LABELS live in three fixed
    # rows. Letting labels track their band means four close layers shove each
    # other down the panel and the lowest one lands on the temperature strip --
    # which is exactly what happened over Kennedy with cloud at 1,200, 4,300,
    # 5,500 and 25,000 feet.
    shown = 0
    for L in order:
        cv, base = L[0], L[1]
        if base < 0:
            continue
        ly = layer_y(base)
        n = COVER[cv][1] if cv in COVER else 4
        lc = col if cv in ["BKN", "OVC", "OVX"] else "#5A6072"
        if n > 0:
            step = 96 // (n + 1)
            for k in range(n):
                x = 6 + step * k + step // 2
                c.line(x, ly, x + (step - 3 if step > 4 else 2), ly, lc)
        if shown < 3:
            ty = 9 + shown * 6
            c.text(cv, 106, ty, font = "4x5", color = lc)
            c.text(fmt.commas(base) + "FT", 182, ty, font = "4x5", color = DIM,
                   align = "right")
            shown += 1
    if len(order) > 3:
        c.text("+" + str(len(order) - 3) + " MORE", 182, 27, font = "4x5",
               color = "midgray", align = "right")

    line = ""
    if m["temp"] != -999:
        line = str(m["temp"]) + "C"
        if m["dewp"] != -999:
            line = line + "  DEW " + str(m["dewp"]) + "C"
            sp = spread(m)
            if sp >= 0 and sp <= 2:
                # Two degrees or less and the air is at saturation: this is the
                # number that turns into fog while you are looking at it.
                line = line + "  FOG RISK"
    p = press_words(m)
    if p != "--":
        line = line + "  " + p if line != "" else p
    c.text(clip(c, line, "4x5", 184), 4, 27, font = "4x5", color = DIM)
