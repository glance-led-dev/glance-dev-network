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

# Minecraft server — is it up, and are my friends on?
#
# Public API (mcsrvstat.us), no key. The status is played by a character rather
# than stated by a label: a grass block when the world is running, and the same
# creeper face asleep with drifting Z's when it is not. "The server is
# sleeping" is something a seven-year-old reads instantly, and nobody reads it
# as broken.

GRASS = "#7CBD56"
API = "https://api.mcsrvstat.us/3/"

# A 3/4-view grass block. The lit top face, the shaded left, the warm right --
# three tones is the minimum that reads as a cube rather than a green square,
# and the 1px black seam down the middle is what separates the two side faces.
GRASS_BLOCK = """
......ggg......
....gGgggGg....
..gGgggegggGg..
ggGgggGgggegggg
eegGgeggGggggee
llllgGgggGgdddd
llllllgggddddbd
lllllll.ddddddd
lllllll.ddbdddd
.llllll.dddddd.
...llll.dddd...
.....ll.dd.....
"""
BLOCK_LEGEND = {"g": GRASS, "G": "#8FD463", "e": "#5E9A40",
                "l": "#5C4229", "L": "#6E4F33", "d": "#8B6845", "b": "#9C7850"}

# The canonical 8x8 creeper grid, drawn as holes punched out of mottled green so
# the panel's own black does the face. Anything else at this size reads as a
# frog.
CREEPER = """
gGggeggG
gBBggBBg
gBBggBBg
gGgBBgeg
ggBBBBgg
geBBBBgG
ggBggBgg
gGBegBgg
"""
CREEPER_SLEEP = """
gGggeggG
gggeggGg
gBBggBBg
gGgBBgeg
ggBBBBgg
geBBBBgG
ggBggBgg
gGBegBgg
"""
AWAKE = {"g": "#4EA33C", "G": "#66C24F", "e": "#3B8930", "B": None}
ASLEEP = {"g": "#2E5F28", "G": "#38702F", "e": "#254D20", "B": None}

def kilo(n):
    """36501 -> 36.5K. A public server can hold six figures and the raw number
    runs off the panel at any font big enough to be the page's hero."""
    if n < 1000:
        return str(n)
    if n < 10000:
        return str(n // 1000) + "." + str((n % 1000) // 100) + "K"
    if n < 1000000:
        return str(n // 1000) + "K"
    return str(n // 1000000) + "M"

def read_server(ctx):
    host = str(ctx.inputs.get("host", "")).strip()
    st = {"state": "ok", "host": host.upper(), "online": False,
          "now": 0, "players": [], "count": 0, "max": 0, "motd": "", "version": ""}
    if host == "":
        st["state"] = "setup"
        return st
    r = http.get(API + host, ttl_seconds = 600)
    if r["status_code"] != 200 or r["json"] == None:
        # mcsrvstat itself being unreachable is NOT the same as the server being
        # down, and saying "OFFLINE" for it would be a lie about someone's world.
        st["state"] = "nocheck"
        return st
    d = r["json"]
    st["online"] = get(d, "online", False) == True
    pl = get(d, "players", {})
    st["count"] = num(get(pl, "online", 0), 0)
    st["max"] = num(get(pl, "max", 0), 0)
    names = get(pl, "list", [])
    if type(names) == "list":
        for n in names:
            if type(n) == "dict":
                st["players"].append(str(get(n, "name", "")).upper())
            else:
                st["players"].append(str(n).upper())
    motd = get(d, "motd", {})
    lines = get(motd, "clean", [])
    if type(lines) == "list" and len(lines) > 0:
        st["motd"] = ents(str(lines[0])).strip().upper()
    st["version"] = str(get(d, "version", "")).upper()
    if not st["online"]:
        st["state"] = "down"
    return st

def mc(c, ctx):
    c.fill("black")
    st = read_server(ctx)
    if st["state"] == "setup":
        tab(c, "MC", GRASS)
        rail(c, GRASS)
        message(c, "MINECRAFT SERVER", "ADD A SERVER ADDRESS IN SETTINGS")
        return
    if st["state"] == "nocheck":
        tab(c, "MC", "amber")
        rail(c, "amber")
        message(c, "CANT CHECK", "MCSRVSTAT.US NOT ANSWERING")
        return
    if st["state"] == "down":
        tab(c, "MC", "red")
        rail(c, "red")
        c.sprite(CREEPER_SLEEP, 14, 12, legend = ASLEEP, scale = 2)
        c.text("Z", 32, 12, font = "4x5", color = "gray")
        c.text("Z", 38, 7, font = "4x5", color = "gray")
        c.text("Z", 44, 2, font = "4x5", color = "midgray")
        c.text("OFFLINE", 62, 8, font = "10x16", color = "red")
        c.text(clip(c, st["host"], "4x5", 100), 62, 26, font = "4x5", color = "gray")
        return

    tab(c, "MC", GRASS)
    rail(c, "green")
    c.text(clip(c, st["host"], "4x5", 130), 21, 1, font = "4x5", color = "gray")
    if st["version"] != "":
        c.text(clip(c, st["version"], "4x5", 40), 182, 1, font = "4x5",
               color = "midgray", align = "right")
    c.sprite(GRASS_BLOCK, 6, 13, legend = BLOCK_LEGEND)
    c.text("ONLINE", 28, 10, font = "8x12", color = "green")
    if st["motd"] != "":
        c.text(clip(c, st["motd"], "4x5", 68), 28, 25, font = "4x5", color = "gray")

    c.vline(100, 10, 20, STRUCT)
    c.text("PLAYERS", 106, 10, font = "4x5", color = "gray")
    tally = kilo(st["count"]) + "/" + kilo(st["max"]) if st["max"] > 0 else kilo(st["count"]) + " ON"
    tf = fit(c, tally, ["10x16", "8x12", "6x8"], 82)
    c.text(tf[1], 106, 16, font = tf[0], color = "white")
    # The right-hand column only exists if the tally actually leaves room for
    # it. A six-figure server ("36K/200K") is the more useful fact anyway, and
    # a teaser drawn on top of it is worse than no teaser.
    room = 106 + c.text_width(tf[1], tf[0]) + 6 <= 154
    if room and len(st["players"]) > 0:
        for i in range(len(st["players"])):
            if i > 1:
                break
            c.text(clip(c, st["players"][i], "4x5", 36), 154, 15 + i * 6,
                   font = "4x5", color = "white")
        if len(st["players"]) > 2:
            c.text("+" + str(len(st["players"]) - 2), 154, 27, font = "4x5",
                   color = "gray")
    elif room and st["count"] == 0:
        c.text("NOBODY ON", 154, 21, font = "4x5", color = "gray")
    elif room:
        # A populated server that does not publish its roster is not empty, and
        # saying NOBODY ON there would be plainly wrong.
        c.text("LIST HIDDEN", 154, 21, font = "4x5", color = "midgray")

def players(c, ctx):
    c.fill("black")
    st = read_server(ctx)
    tab(c, "PLAYERS", GRASS)
    if st["state"] != "ok":
        rail(c, "red" if st["state"] == "down" else
             ("amber" if st["state"] == "nocheck" else GRASS))
        if st["state"] == "down":
            c.sprite(CREEPER_SLEEP, 14, 12, legend = ASLEEP, scale = 2)
            c.text("OFFLINE", 62, 8, font = "10x16", color = "red")
        elif st["state"] == "nocheck":
            # Not the same as the server being down, and this page said "add a
            # server address" for it -- which is wrong when one is already set.
            message(c, "CANT CHECK", "MCSRVSTAT.US NOT ANSWERING")
        else:
            message(c, "MINECRAFT SERVER", "ADD A SERVER ADDRESS IN SETTINGS")
        return
    rail(c, "green")
    c.text(str(st["count"]) + " OF " + str(st["max"]), 182, 1, font = "4x5",
           color = "gray", align = "right")
    c.sprite(CREEPER, 8, 12, legend = AWAKE, scale = 2)
    if len(st["players"]) == 0:
        if st["count"] > 0:
            c.text("LIST HIDDEN", 40, 12, font = "6x8", color = "gray")
            c.text(kilo(st["count"]) + " PLAYING", 40, 22, font = "4x5",
                   color = "midgray")
        else:
            c.text("NOBODY ON", 40, 14, font = "6x8", color = "gray")
        return
    # 6x6 is the only small font carrying an underscore, which half of all
    # Minecraft usernames contain.
    for i in range(len(st["players"])):
        if i > 5:
            break
        col = 32 if i < 3 else 112
        y = 10 + (i % 3) * 8
        if i == 5 and len(st["players"]) > 6:
            c.text("+" + str(len(st["players"]) - 5) + " MORE", col, y + 1,
                   font = "4x5", color = "gray")
        else:
            c.text(clip(c, st["players"][i], "6x6", 70), col, y, font = "6x6",
                   color = "white")
