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

# Severe weather, nationwide — how much of the country is under a warning.
#
# The existing nws-alerts app answers "is MY zip under an alert". This is the
# other question: what is happening to the country right now. On a bad
# afternoon that is a genuinely gripping thing to have on a wall.
#
# api.weather.gov, public, no key -- but it REQUIRES a User-Agent header and
# answers 403 without one.

# Starlark has no implicit adjacent-string concatenation, so this is one join.
API = ("https://api.weather.gov/alerts/active" +
       "?status=actual&severity=Severe,Extreme")
UA = {"User-Agent": "GlanceSevereWx/1.0 (glance-led.com)",
      "Accept": "application/geo+json"}

# Hazard families, in the order a person cares about them when several are
# running at once. First match wins, so TORNADO beats the generic WARNING.
FAMILIES = [
    ["TORNADO", "#FF2D2D"],
    ["HURRICANE", "#FF2D2D"],
    ["TSUNAMI", "#FF2D2D"],
    ["FLASH FLOOD", "#00E36B"],
    ["THUNDERSTORM", "#FFB300"],
    ["FLOOD", "#2BA7FF"],
    ["FIRE", "#FF6A00"],
    ["RED FLAG", "#FF6A00"],
    ["HEAT", "#FF4FCB"],
    ["WINTER", "#7FE9FF"],
    ["SNOW", "#7FE9FF"],
    ["ICE", "#7FE9FF"],
    ["BLIZZARD", "#7FE9FF"],
    ["WIND", "#B49BF0"],
    ["DUST", "#C8A15A"],
    ["FREEZE", "#7FE9FF"],
    ["SURF", "#2BA7FF"],
    ["FOG", "#9AA6B8"],
]

def family_of(event):
    e = str(event).upper()
    for f in FAMILIES:
        if e.find(f[0]) >= 0:
            return f
    return ["OTHER", "gray"]

# Marine and offshore zones use two-letter codes that are not states; counting
# them as states puts "PK" (Alaska marine) at the top of a national board and
# makes the page look broken.
NOT_STATES = ["PK", "PZ", "PH", "PM", "PS", "AN", "AM", "GM", "LE", "LO",
              "LH", "LM", "LS", "SL"]

TORNADO = """
....#####
...######
..######.
..#####..
..####...
...###...
...###...
....#....
....#....
"""
BOLT = """
...##
..##.
.###.
###..
.##..
##...
"""

def read_alerts(ctx):
    st = {"state": "ok", "total": 0, "extreme": 0, "fams": [], "states": []}
    r = http.get(API, headers = UA, ttl_seconds = 900)
    if r["status_code"] != 200 or r["json"] == None:
        st["state"] = "offline"
        return st
    feats = get(r["json"], "features", [])
    if type(feats) != "list":
        st["state"] = "offline"
        return st

    fam_count, fam_color, state_count = {}, {}, {}
    for f in feats:
        p = get(f, "properties", {})
        ev = str(get(p, "event", "")).strip().upper()
        if ev == "":
            continue
        st["total"] += 1
        if str(get(p, "severity", "")).upper() == "EXTREME":
            st["extreme"] += 1
        fam = family_of(ev)
        fam_count[fam[0]] = fam_count.get(fam[0], 0) + 1
        fam_color[fam[0]] = fam[1]
        # One alert covers many counties; count each STATE once so the board
        # ranks by how widely a state is affected, not by how finely NWS
        # happened to slice it into zones.
        seen = {}
        for ugc in get(get(p, "geocode", {}), "UGC", []):
            code = str(ugc)[:2].upper()
            if code == "" or code in NOT_STATES or code in seen:
                continue
            seen[code] = True
            state_count[code] = state_count.get(code, 0) + 1

    for k in fam_count:
        st["fams"].append([k, fam_count[k], fam_color[k]])
    st["fams"] = sorted(st["fams"], key = lambda x: -x[1])
    for k in state_count:
        st["states"].append([k, state_count[k]])
    st["states"] = sorted(st["states"], key = lambda x: -x[1])
    if st["total"] == 0:
        st["state"] = "quiet"
    return st

def top_color(st):
    if len(st["fams"]) == 0:
        return "green"
    return st["fams"][0][2]

def usa(c, ctx):
    c.fill("black")
    st = read_alerts(ctx)
    tab(c, "USA", "#FF2D2D")
    if st["state"] == "offline":
        rail(c, OFFLINE)
        message(c, "NWS UNREACHABLE", "CANT REACH WEATHER.GOV")
        return
    if st["state"] == "quiet":
        rail(c, "green")
        c.text("ALL QUIET", 96, 11, font = "5x7", color = "green", align = "center")
        c.text("NO SEVERE ALERTS NATIONWIDE", 96, 23, font = "4x5",
               color = "gray", align = "center")
        return
    col = top_color(st)
    rail(c, col)
    c.text("SEVERE + EXTREME NOW", 186, 2, font = "4x5", color = "gray",
           align = "right")
    hf = fit(c, str(st["total"]), ["16x20", "10x16"], 60)
    c.text(hf[1], 6, 9, font = hf[0], color = col)
    hx = 6 + c.text_width(hf[1], hf[0]) + 6
    c.text("ALERTS", hx, 12, font = "4x5", color = "gray")
    if st["extreme"] > 0:
        # A three-digit total pushes this column right; clip against the
        # divider rather than letting the word run through it.
        # "EXTREME" needs 39px and a three-digit total leaves about 30, so the
        # word is abbreviated rather than clipped to a fragment.
        c.text(str(st["extreme"]) + " EXT", hx, 20, font = "4x5",
               color = "#FF2D2D")
    c.vline(96, 10, 20, STRUCT)
    # The three biggest hazards, which is what "what is going on" actually means.
    for i in range(len(st["fams"])):
        if i > 2:
            break
        f = st["fams"][i]
        y = 10 + i * 7
        c.rect(102, y, 104, y + 4, fill = f[2])
        c.text(str(f[1]), 186, y, font = "4x5", color = "white", align = "right")
        c.text(clip(c, f[0], "4x5", 60), 108, y, font = "4x5", color = f[2])

def hazards(c, ctx):
    c.fill("black")
    st = read_alerts(ctx)
    tab(c, "HAZARDS", "#FF2D2D")
    if st["state"] != "ok":
        rail(c, OFFLINE if st["state"] == "offline" else "green")
        if st["state"] == "offline":
            message(c, "NWS UNREACHABLE", "CANT REACH WEATHER.GOV")
        else:
            message(c, "ALL QUIET", "NO SEVERE ALERTS NATIONWIDE")
        return
    rail(c, top_color(st))
    c.text(str(len(st["fams"])) + " KINDS", 186, 2, font = "4x5", color = "gray",
           align = "right")
    top = st["fams"][0][1] if len(st["fams"]) > 0 else 1
    for i in range(len(st["fams"])):
        if i > 3:
            break
        f = st["fams"][i]
        y = 9 + i * 6
        c.text(clip(c, f[0], "4x5", 60), 4, y, font = "4x5", color = f[2])
        # Bars share one scale, so the shape of the outbreak is comparable
        # across rows rather than each row filling its own width.
        w = f[1] * 86 // top
        if w < 1:
            w = 1
        c.rect(68, y, 68 + w - 1, y + 4, fill = f[2])
        c.text(str(f[1]), 186, y, font = "4x5", color = "white", align = "right")

def states(c, ctx):
    c.fill("black")
    st = read_alerts(ctx)
    tab(c, "STATES", "#FF2D2D")
    if st["state"] != "ok":
        rail(c, OFFLINE if st["state"] == "offline" else "green")
        if st["state"] == "offline":
            message(c, "NWS UNREACHABLE", "CANT REACH WEATHER.GOV")
        else:
            message(c, "ALL QUIET", "NO SEVERE ALERTS NATIONWIDE")
        return
    rail(c, top_color(st))
    c.text(str(len(st["states"])) + " STATES", 186, 2, font = "4x5",
           color = "gray", align = "right")
    if len(st["states"]) == 0:
        message(c, "NO LAND ALERTS", "ONLY MARINE ZONES ARE ACTIVE")
        return
    top = st["states"][0][1]
    col = top_color(st)
    # Two columns of four, worst first.
    for i in range(len(st["states"])):
        if i > 7:
            break
        s = st["states"][i]
        cx = 5 if i < 4 else 100
        y = 9 + (i % 4) * 6
        c.text(s[0], cx, y, font = "4x5", color = "white")
        w = s[1] * 49 // top
        if w < 1:
            w = 1
        c.rect(cx + 14, y, cx + 14 + w - 1, y + 4, fill = col)
        c.text(str(s[1]), cx + 84, y, font = "4x5", color = "gray",
               align = "right")
