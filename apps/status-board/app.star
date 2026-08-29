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

# ---- status board ---------------------------------------------------------
# Is it me, or is it them. Every one of these runs on Atlassian Statuspage,
# which exposes /api/v2/status.json publicly on every instance -- no key, no
# account, no scraping. That endpoint is a few hundred bytes and returns the
# whole answer already reduced to one word.
#
# Services that DON'T run Statuspage were tried and dropped rather than
# special-cased: Anthropic, Slack, GitLab, Notion, Docker, Zoom and Linear all
# answered with something that is not that JSON. One shape, or it is not in the
# table.

SERVICES = {
    "github": ["GITHUB", "https://www.githubstatus.com"],
    "cloudflare": ["CLOUDFLARE", "https://www.cloudflarestatus.com"],
    "openai": ["OPENAI", "https://status.openai.com"],
    "npm": ["NPM", "https://status.npmjs.org"],
    "discord": ["DISCORD", "https://discordstatus.com"],
    "dropbox": ["DROPBOX", "https://status.dropbox.com"],
    "twilio": ["TWILIO", "https://status.twilio.com"],
    "atlassian": ["ATLASSIAN", "https://status.atlassian.com"],
    "digitalocean": ["DIGITALOCEAN", "https://status.digitalocean.com"],
    "vercel": ["VERCEL", "https://www.vercel-status.com"],
    "netlify": ["NETLIFY", "https://www.netlifystatus.com"],
    "datadog": ["DATADOG", "https://status.datadoghq.com"],
    "figma": ["FIGMA", "https://status.figma.com"],
    "hubspot": ["HUBSPOT", "https://status.hubspot.com"],
}

# Statuspage's own five indicators, worst last. `rank` is what sorts the board
# and picks the accent, so a maintenance window never outranks an outage.
LEVELS = {
    "none": [0, "#00E36B", "OK"],
    "maintenance": [1, "#B49BF0", "MAINTENANCE"],
    "minor": [2, "#FFB300", "DEGRADED"],
    "major": [3, "#FF6A00", "OUTAGE"],
    "critical": [4, "#FF2D2D", "CRITICAL"],
}

def level_of(ind):
    i = str(ind).lower()
    return LEVELS[i] if i in LEVELS else [2, "#9AA6B8", "UNKNOWN"]

def read_board(ctx):
    raw = str(ctx.inputs.get("services", "")).strip().lower()
    st = {"state": "ok", "rows": [], "worst": 0, "bad": 0}
    picks = []
    for s in raw.split(","):
        k = s.strip()
        if k in SERVICES and k not in picks:
            picks.append(k)
        if len(picks) >= 6:
            break
    if len(picks) == 0:
        st["state"] = "setup"
        return st

    reached = 0
    for k in picks:
        sv = SERVICES[k]
        r = http.get(sv[1] + "/api/v2/status.json", ttl_seconds = 900)
        if r["status_code"] != 200 or r["json"] == None:
            # One unreachable service is not a broken app. It gets a grey row
            # and the others still report.
            st["rows"].append([sv[0], [-1, "#4A5060", "NO DATA"], ""])
            continue
        reached += 1
        ind = dig(r["json"], ["status", "indicator"], "")
        desc = str(dig(r["json"], ["status", "description"], "")).upper()
        lv = level_of(ind)
        st["rows"].append([sv[0], lv, desc])
        if lv[0] > st["worst"]:
            st["worst"] = lv[0]
        if lv[0] > 0:
            st["bad"] += 1
    if reached == 0:
        st["state"] = "offline"
    return st

def board_color(st):
    for k in LEVELS:
        if LEVELS[k][0] == st["worst"]:
            return LEVELS[k][1]
    return "#00E36B"

# ---- pages ----------------------------------------------------------------
# The board is a roll call: six services, two columns, always in the order the
# reader listed them so their eye learns the positions. Green is the boring
# case and the boring case is the one this panel spends its life in, so it has
# to look deliberate rather than empty.

def fail(c, st, word):
    tab(c, word, "#78DCFF")
    if st["state"] == "setup":
        rail(c, STRUCT)
        message(c, "PICK SOME SERVICES", "LIKE GITHUB,CLOUDFLARE,OPENAI")
        return True
    if st["state"] == "offline":
        rail(c, OFFLINE)
        message(c, "NO STATUS DATA", "COULDNT REACH ANY STATUS PAGE")
        return True
    return False

# ------------------------------------------------------------ page 1: status
def status(c, ctx):
    c.fill("black")
    st = read_board(ctx)
    if fail(c, st, "STATUS"):
        return
    col = board_color(st)
    rail(c, col)
    tab(c, "STATUS", col)
    if st["bad"] == 0:
        c.text("ALL GOOD", 188, 2, font = "4x5", color = "#00E36B",
               align = "right")
    else:
        word = "ISSUE" if st["bad"] == 1 else "ISSUES"
        c.text(str(st["bad"]) + " " + word, 188, 2, font = "4x5", color = col,
               align = "right")

    # Two columns of three. Six is the most that fits with a dot, a name and
    # room for the name to be DIGITALOCEAN.
    for i in range(len(st["rows"])):
        if i > 5:
            break
        r = st["rows"][i]
        x = 4 if i < 3 else 100
        y = 11 + (i % 3) * 7
        c.rect(x, y, x + 2, y + 2, fill = r[1][1])
        nc = INK if r[1][0] == 0 else r[1][1]
        c.text(clip(c, r[0], "4x5", 82), x + 6, y - 1, font = "4x5", color = nc)

# ------------------------------------------------------------ page 2: issues
def issues(c, ctx):
    c.fill("black")
    st = read_board(ctx)
    if fail(c, st, "ISSUES"):
        return
    col = board_color(st)
    rail(c, col)
    tab(c, "ISSUES", col)

    bad = []
    for r in st["rows"]:
        if r[1][0] > 0:
            bad.append(r)
    bad = sorted(bad, key = lambda r: -r[1][0])

    if len(bad) == 0:
        c.text("ALL SYSTEMS", 96, 10, font = "6x8", color = "#00E36B",
               align = "center")
        c.text("OPERATIONAL", 96, 20, font = "6x8", color = "#00E36B",
               align = "center")
        return

    # Worst first, with the provider's own words for what is wrong. Three rows
    # is the honest limit; anything more and the description gets clipped to
    # the point of being useless.
    if len(bad) > 3:
        # The overflow count rides the top row. Putting it under the third
        # service landed it on top of that service's own row.
        c.text("+" + str(len(bad) - 3) + " MORE", 188, 2, font = "4x5",
               color = "midgray", align = "right")
    for i in range(len(bad)):
        if i > 2:
            break
        r = bad[i]
        y = 11 + i * 7
        c.rect(4, y, 6, y + 2, fill = r[1][1])
        c.text(clip(c, r[0], "4x5", 62), 10, y - 1, font = "4x5",
               color = r[1][1])
        # clip_words, not clip: "PARTIALLY DEGRADED SERVICE" cut to the pixel
        # reads "PARTIALLY DEGRADED SERV", which looks like a rendering bug.
        # Backing up to the word break says the same thing and looks intended.
        txt = r[2] if r[2] != "" else r[1][2]
        c.text(clip_words(c, txt, "4x5", 108), 188, y - 1, font = "4x5",
               color = DIM, align = "right")
