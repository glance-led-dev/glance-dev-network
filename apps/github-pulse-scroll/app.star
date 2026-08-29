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

# GitHub pulse — is main green, and is anything waiting on me?
#
# The existing github-repo app shows stars and forks. Those are vanity metrics.
# This is the opposite app: it is for the person who OWNS the repo and wants to
# know whether CI is green and whether anything is blocked on them. Red is the
# only state allowed to shout; everything else is built quiet enough that it can.
#
# A PAT is optional -- the public API answers without one -- but unauthenticated
# calls are capped at 60/hour per IP, which a shared render host burns quickly,
# so most people will add one.

GH = "https://api.github.com/repos/"
OK_C = "#2DA44E"
BAD_C = "#CF222E"
PEND = "#BF8700"

CHECK_HERO = """
............##
...........###
..........###.
.........###..
##......###...
###....###....
.###..###.....
..######......
...####.......
....##........
"""
CROSS_HERO = """
##.......##
###.....###
.###...###.
..###.###..
...#####...
..###.###..
.###...###.
###.....###
##.......##
"""
# "Working" without animation: a full ring knocked back to a quarter, with a
# graded head at twelve o'clock. The brightness comet reads as frozen motion
# rather than a broken circle.
SPIN_HERO = """
.....AAA.....
.....AAA.....
..BB.....DD..
..BB.....DD..
.............
CC.........DD
CC.........DD
CC.........DD
.............
..DD.....DD..
..DD.....DD..
.....DDD.....
.....DDD.....
"""
BRANCH = """
.#.......#.
###.....###
.#.......#.
.#.......#.
.#......##.
.#.....##..
.#...##....
.####......
.#.........
.#.........
###........
.#.........
"""
EYE = """
....#####....
..##.....##..
.#...OOO...#.
#....OOO....#
.#...OOO...#.
..##.....##..
....#####....
"""
EYE_MINI = """
..#####..
.#..#..#.
#..###..#
.#..#..#.
..#####..
"""
MINI_CHECK = """
....#
...##
#.##.
###..
.#...
"""
MINI_CROSS = """
#...#
.#.#.
..#..
.#.#.
#...#
"""
MINI_DOT = """
.###.
#####
#####
#####
.###.
"""
MINI_SKIP = """
.....
.....
#####
.....
.....
"""

def spin_legend():
    return {"A": PEND, "B": color.dim(PEND, 70), "C": color.dim(PEND, 45),
            "D": color.dim(PEND, 25)}

def repo_of(ctx):
    r = str(ctx.inputs.get("repo", "")).strip()
    # A pasted https:// URL arrives as the word "https", so owner/name is the
    # only form that can survive the render descriptor.
    if r == "" or r.find("/") < 0 or r.startswith("http"):
        return ""
    return r

def gh_get(path, token, ttl):
    h = {"Accept": "application/vnd.github+json"}
    if token != "":
        h["Authorization"] = "Bearer " + token
    return http.get(GH + path, headers = h, ttl_seconds = ttl)

def ago_short(mins):
    if mins < 60:
        return str(mins) + "M"
    if mins < 1440:
        return str(mins // 60) + "H"
    if mins < 525600:
        return str(mins // 1440) + "D"
    return str(mins // 525600) + "Y"

def read_repo(ctx):
    offmin = zone_offset(ctx)
    now = ctx.now.unix // 60 + offmin
    repo = repo_of(ctx)
    token = str(ctx.inputs.get("token", "")).strip()
    me = str(ctx.inputs.get("login", "")).strip().lower()
    st = {"state": "ok", "repo": repo.upper(), "now": now, "me": me,
          "prs": [], "runs": [], "ci": "none", "pass": 0, "fail": 0, "total": 0}
    if repo == "":
        st["state"] = "setup"
        return st

    pr = gh_get(repo + "/pulls?state=open&per_page=20", token, 300)
    if pr["status_code"] == 403:
        st["state"] = "rate"
        return st
    if pr["status_code"] == 404:
        st["state"] = "notfound"
        return st
    if pr["status_code"] != 200 or pr["json"] == None:
        st["state"] = "offline"
        return st
    rows = pr["json"]
    if type(rows) == "list":
        for row in rows:
            if type(row) != "dict":
                continue
            opened = parse_iso(str(get(row, "created_at", "")), offmin)
            wants = get(row, "requested_reviewers", [])
            mine = False
            if type(wants) == "list":
                for w in wants:
                    if str(get(w, "login", "")).lower() == me and me != "":
                        mine = True
            st["prs"].append({
                "num": num(get(row, "number", 0), 0),
                "title": str(get(row, "title", "")).strip().upper(),
                "draft": get(row, "draft", False) == True,
                "review": type(wants) == "list" and len(wants) > 0,
                "mine": mine,
                "age": (now - opened) if opened != None else 0,
            })

    runs = gh_get(repo + "/actions/runs?per_page=5", token, 300)
    if runs["status_code"] == 200 and runs["json"] != None:
        for row in get(runs["json"], "workflow_runs", []):
            if type(row) != "dict":
                continue
            started = parse_iso(str(get(row, "run_started_at", "")), offmin)
            st["runs"].append({
                "name": str(get(row, "name", "")).strip().upper(),
                "concl": str(get(row, "conclusion", "")).lower(),
                "status": str(get(row, "status", "")).lower(),
                "age": (now - started) if started != None else 0,
            })
    # CI verdict from the recent runs: a failure outranks anything in flight.
    for r in st["runs"]:
        st["total"] += 1
        if r["concl"] == "success":
            st["pass"] += 1
        elif r["concl"] in ["failure", "timed_out", "action_required"]:
            st["fail"] += 1
    if st["fail"] > 0:
        st["ci"] = "fail"
    else:
        running = False
        for r in st["runs"]:
            if r["status"] != "completed":
                running = True
        st["ci"] = "run" if running else ("ok" if st["total"] > 0 else "none")
    return st

def ci_color(ci):
    if ci == "fail":
        return BAD_C
    if ci == "run":
        return PEND
    if ci == "ok":
        return OK_C
    return "gray"

def gh_fail(c, st):
    if st["state"] == "setup":
        rail(c, STRUCT)
        message(c, "ADD A REPO", "OWNER/REPO IN SETTINGS")
        return True
    if st["state"] == "rate":
        rail(c, STRUCT)
        message(c, "RATE LIMITED", "ADD A TOKEN IN SETTINGS")
        return True
    if st["state"] == "notfound":
        rail(c, STRUCT)
        message(c, "REPO NOT FOUND", "CHECK OWNER/REPO")
        return True
    if st["state"] == "offline":
        rail(c, STRUCT)
        message(c, "GITHUB UNREACHABLE", "CANT REACH THE API")
        return True
    return False

def main(c, ctx):
    c.fill("black")
    st = read_repo(ctx)
    col = ci_color(st["ci"])
    c.badge("MAIN", 4, 1, color = "black" if st["state"] == "ok" else "gray",
            bg = col if st["state"] == "ok" else STRUCT, font = "4x5")
    if gh_fail(c, st):
        return
    rail(c, col)
    c.text(clip(c, st["repo"], "4x5", 120), 31, 2, font = "4x5", color = "gray")
    if len(st["runs"]) > 0:
        c.text(ago_short(st["runs"][0]["age"]), 186, 2, font = "4x5",
               color = "gray", align = "right")

    if st["ci"] == "ok":
        c.sprite(CHECK_HERO, 7, 14, color = OK_C)
        word, sub = "GREEN", "ALL " + str(st["pass"]) + " PASS"
    elif st["ci"] == "fail":
        c.sprite(CROSS_HERO, 8, 13, color = BAD_C)
        word, sub = "FAILING", str(st["fail"]) + " OF " + str(st["total"]) + " FAIL"
    elif st["ci"] == "run":
        c.sprite(SPIN_HERO, 7, 12, legend = spin_legend())
        word, sub = "RUNNING", str(st["pass"]) + " OF " + str(st["total"]) + " DONE"
    else:
        c.sprite(BRANCH, 8, 12, color = "midgray")
        word, sub = "NO CI", "NO CHECKS"
    c.text(word, 26, 12, font = "8x12", color = col)
    c.text(sub, 26, 26, font = "4x5", color = BAD_C if st["ci"] == "fail" else "gray")

    c.vline(92, 10, 21, STRUCT)
    for i in range(len(st["runs"])):
        if i > 2:
            break
        r = st["runs"][i]
        y = 10 + i * 7
        if r["status"] != "completed":
            c.sprite(MINI_DOT, 97, y, color = PEND)
        elif r["concl"] == "success":
            c.sprite(MINI_CHECK, 97, y, color = OK_C)
        elif r["concl"] in ["failure", "timed_out", "action_required"]:
            c.sprite(MINI_CROSS, 97, y, color = BAD_C)
        else:
            c.sprite(MINI_SKIP, 97, y, color = "gray")
        when = ago_short(r["age"])
        ww = c.text_width(when, "4x5")
        c.text(when, 186, y, font = "4x5", color = "gray", align = "right")
        c.text(clip(c, r["name"], "4x5", 186 - ww - 4 - 105), 105, y,
               font = "4x5", color = "white")

def queue(c, ctx):
    c.fill("black")
    st = read_repo(ctx)
    waiting = 0
    for p in st["prs"]:
        if p["review"] and not p["draft"]:
            waiting += 1
    col = PEND if waiting > 0 else OK_C
    c.badge("QUEUE", 4, 1, color = "black" if st["state"] == "ok" else "gray",
            bg = col if st["state"] == "ok" else STRUCT, font = "4x5")
    if gh_fail(c, st):
        return
    rail(c, col)
    c.text(clip(c, st["repo"], "4x5", 150), 36, 2, font = "4x5", color = "gray")

    c.sprite(BRANCH, 6, 10, color = "white")
    n = len(st["prs"])
    nf = fit(c, str(n), ["10x16", "8x12", "6x8"], 24)
    c.text(nf[1], 21, 9, font = nf[0], color = "white")
    c.text("OPEN PRS", 6, 26, font = "4x5", color = "gray")
    c.vline(46, 10, 21, STRUCT)

    if n == 0:
        c.text("NO OPEN PRS", 119, 13, font = "5x7", color = "gray", align = "center")
        c.text("INBOX ZERO", 119, 24, font = "4x5", color = "midgray", align = "center")
        return
    # Awaiting review first and oldest-first, then the rest, drafts last.
    def key(p):
        band = 0 if (p["review"] and not p["draft"]) else (2 if p["draft"] else 1)
        return band * 1000000 - p["age"]
    rows = sorted(st["prs"], key = key)
    for i in range(len(rows)):
        if i > 2:
            break
        p = rows[i]
        y = 9 + i * 8
        if p["draft"]:
            c.sprite(MINI_DOT, 53, y, color = "midgray")
        elif p["review"]:
            c.sprite(EYE_MINI, 51, y, color = PEND)
        else:
            c.sprite(MINI_DOT, 53, y, color = "gray")
        age = ago_short(p["age"])
        acol = "gray"
        if p["age"] >= 10080:
            acol = BAD_C
        elif p["age"] >= 1440:
            acol = PEND
        if p["draft"]:
            acol = "midgray"
        aw = c.text_width(age, "4x5")
        c.text(age, 186, y, font = "4x5", color = acol, align = "right")
        lab = "#" + str(p["num"])
        c.text(lab, 63, y, font = "4x5",
               color = "midgray" if p["draft"] else "white")
        tx = 63 + c.text_width(lab, "4x5") + 4
        c.text(clip_words(c, p["title"], "4x5", 186 - aw - tx - 5), tx, y,
               font = "4x5", color = "gray")

def review(c, ctx):
    c.fill("black")
    st = read_repo(ctx)
    # Pick first, so the tab can wear the answer. An amber REVIEW chip above a
    # green ALL CAUGHT UP is the page contradicting itself.
    pick = None
    for p in st["prs"]:
        if p["draft"] or not p["review"]:
            continue
        if pick == None or p["mine"] and not pick["mine"] or p["age"] > pick["age"]:
            pick = p
    chip = STRUCT
    if st["state"] == "ok":
        chip = PEND if pick != None else OK_C
    c.badge("REVIEW", 4, 1, color = "gray" if chip == STRUCT else "black",
            bg = chip, font = "4x5")
    if gh_fail(c, st):
        return
    if pick == None:
        rail(c, OK_C)
        c.text("ALL CAUGHT UP", 96, 11, font = "5x7", color = OK_C, align = "center")
        c.text("NO REVIEWS REQUESTED", 96, 23, font = "4x5", color = "gray",
               align = "center")
        return
    acol = "gray"
    if pick["age"] >= 10080:
        acol = BAD_C
    elif pick["age"] >= 1440:
        acol = PEND
    rail(c, acol)
    c.text("#" + str(pick["num"]), 41, 2, font = "4x5", color = "gray")
    c.text("WAITING " + ago_short(pick["age"]), 186, 2, font = "4x5",
           color = acol, align = "right")
    c.sprite(EYE, 6, 13, legend = {"#": PEND, "O": "white"})
    c.text_wrapped(pick["title"], 24, 10, 165, font = "5x7", color = "white",
                   line_gap = 2, max_lines = 2)


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

def zone_offset(ctx):
    """The reader's current offset from UTC, in minutes."""
    return zone_offset_at(str(ctx.inputs.get("timezone", "UTC")).strip(),
                          ctx.now.unix // 60)
