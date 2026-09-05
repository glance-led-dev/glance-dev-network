# Weight Goals
#
# A scale reads water, not fat. Day to day it swings a few pounds on salt
# and sleep, which is enough to show a "gain" on a morning someone did
# everything right -- so the number this panel makes big is the
# exponentially-weighted trend, not the last weigh-in. That is the
# Hacker's Diet idea, and it is the whole reason this is worth a panel:
# the trend only moves when the weight really does.
#
# The log lives in the user's own Google Sheet. Sheets can be read with no
# key and no OAuth through the gviz endpoint -- but only that one:
#
#   /gviz/tq?tqx=out:csv   -> 200, CSV in the body
#   /export?format=csv     -> 307 to googleusercontent, and this sandbox
#                             runs with redirects disabled, so the app
#                             gets an empty body and no explanation.
#
# The chart is resampled onto its own pixel columns by DATE, not by row.
# Plotting one point per weigh-in silently lies: four readings in one week
# and one the next get equal width, so a plateau looks like a cliff. Every
# column here is the same number of days wide, and gaps are interpolated
# across.


GVIZ = "/gviz/tq?tqx=out:csv"

# Hacker's Diet smoothing, but weighted by the GAP between weigh-ins rather
# than a fixed step. The classic constant assumes someone stands on the scale
# every morning; against a weekly log it barely moves -- five weekly readings
# falling 252 -> 236 came out as a "trend" of 248.8, which is not a number
# anybody would recognise as their own weight.
#
# alpha = dt / (TAU + dt) is the standard irregular-sample form. At dt = 1 day
# it gives 0.09, near enough the classic 0.1; at dt = 7 it gives 0.41, so a
# weekly log tracks properly. Same rule, both cadences, no setting.
TAU = 10.0

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

UNIT_LABEL = {"POUNDS": "LB", "KILOGRAMS": "KG", "STONE": "ST"}

# Weight loss is a weeks-to-months project, so the windows are too. TOTAL
# is there for the person who has been logging for two years and wants to
# see the whole shape of it.
# A year is the ceiling, everywhere. Nobody needs 2019's weigh-ins on a
# panel, and an unbounded sheet is an unbounded download and an unbounded
# parse -- both of which run inside one render's budget.
MAX_DAYS = 365
MAX_ROWS = 400            # ~daily for a year, with room for doubles
WINDOWS = {"30 DAYS": 30, "90 DAYS": 90, "1 YEAR": MAX_DAYS,
           "TOTAL": MAX_DAYS}

# House-kit palette. White is the resting colour for a live number, which
# leaves green and amber free to mean something the moment they appear.
INK = "#F4F7FF"
DIM = "#6E7A94"
STRUCT = "darkgray"
GOOD = "#4EE38A"
WARN = "#FFAA3C"
GOLD = "#FFD23D"          # the goal is met
SKY = "#7FB6E8"           # the weekly rate -- a fourth hue, so a page whose
                          # state is amber is not amber from edge to edge
CHIP = GOOD               # every pill on every page wears the brand green
TARGETC = GOOD            # the target's label and value on the data pages

# The target rule on the chart, and the word riding it. A brick red, kept
# deliberately short of the alarm reds the catalog uses (#FF3B30 / #FF5B5B):
# this is a number to hit, not a fault to fix, and the two must never read
# as the same thing.
TARGETLINE = "#C94F42"

# White with a cast, for stats that are going well or badly. Full green and
# full red on a wall of numbers reads as an alarm; a tint reads as a hint.
TINT_GOOD = "#B9F5CE"
TINT_BAD = "#F7C9C9"

MARGIN = 4                # left/right buffer so the app does not touch its
                          # neighbours in the scroll sequence

# Pace against a chosen goal date. Only these three ever colour themselves;
# a projected ETA stays dim, because the app guessed it and the user didn't.
PACECOL = {"ON PACE": GOOD, "BEHIND": WARN, "OFF PACE": WARN,
           "PAST DUE": "#FF5B5B", "WRONG WAY": WARN, "GOAL MET": GOOD}

# Short forms for the TRENDONLY headline. "FALLING" is 75px at 10x16 against
# a 74px zone -- one pixel over, so it clipped to "FALLIN". These say the
# same thing and fit at 16x20, so the hero gets bigger rather than smaller.
SHORT_WORD = {"FALLING": "DOWN", "RISING": "UP", "HOLDING": "FLAT",
              "GOAL MET": "MET", "NEW": "NEW"}

# Starlark has no font metrics call, so the heights are carried.
FONTH = {"16x20": 20, "10x16": 16, "10x16_outline": 16, "9x12": 12,
         "8x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# Blank rows a font leaves UNDER its ink. 10x16 reserves one and 16x20
# reserves none, so aligning on the cell instead of the ink floated a unit
# label one row low at one size and not the other.
BLANK = {"16x20": 0, "10x16": 1, "10x16_outline": 1, "9x12": 0,
         "8x12": 0, "6x8": 0, "5x7": 0, "4x5": 0}

# A dim twin of each state colour, for the wash under the trend line.
WASH = {GOOD: "#123521", WARN: "#33260E", INK: "#1C2029", GOLD: "#332B0C"}

# 7x7. Small enough to sit beside a 6x8 number and still read as a target,
# which means the words TO GO never have to be spelled out.
BULLSEYE = """
..rrr..
.r...r.
r.www.r
r.www.r
r.www.r
.r...r.
..rrr..
"""


def eye_legend(col):
    """The bullseye wears the state colour, so the ring and the number
    beside it can never disagree."""
    return {"r": col, "w": "#F0F4FC"}

# Two arts, because the goal decides which way "good" points. A loss goal
# gets a line falling into the target; a gain goal gets the same line
# climbing into it. The axes stay put in both -- mirroring the whole sprite
# would have put the floor along the top.
ART_DOWN = """
............................
............................
............................
.add........................
.add........................
.a.ll.......................
.a..lll.....................
.a...lllllll................
.a.....llllll...............
.a..........ll..............
.a...........ll.............
.a............ll............
.a.............lll..........
.a..............lll..rrr....
.a................llr...r...
.a.................r.www.r..
.a.................r.www.r..
.a.................r.www.r..
.a..................r...r...
.a...................rrr....
.a..........................
.a..........................
.aaaaaaaaaaaaaaaaaaaaaaaaaa.
............................
"""

ART_UP = """
............................
............................
............................
.a..........................
.a..........................
.a...................rrr....
.a..................r...r...
.a.................r.www.r..
.a.................r.www.r..
.a................lr.www.r..
.a..............lll.r...r...
.a.............lll...rrr....
.a............ll............
.a...........ll.............
.a..........ll..............
.a.....llllll...............
.a...lllllll................
.a..lll.....................
.addl.......................
.add........................
.a..........................
.a..........................
.aaaaaaaaaaaaaaaaaaaaaaaaaa.
............................
"""

ART_LEGEND = {
    "a": "#262D3E",   # axes
    "l": GOOD,        # the trend
    "d": "#D6FFE7",   # newest reading
    "r": "#FF5B5B",   # target ring
    "w": "#F0F4FC",   # target centre
}


def _bool_input(value, fallback):
    """Checkbox inputs arrive as a bool from the Studio and as text from a
    saved config, so both have to be accepted."""
    if value == None:
        return fallback
    if value == True or value == False:
        return value
    t = str(value).strip().lower()
    if t in ["true", "1", "yes", "on"]:
        return True
    if t in ["false", "0", "no", "off"]:
        return False
    return fallback


def _fmt1(v):
    """One decimal, built by hand: str() on a Starlark float is free to
    return 184.20000000000002, and that is 8 characters this panel does
    not have."""
    neg = v < 0
    if neg:
        v = -v
    t = int(v * 10 + 0.5)
    out = str(t // 10) + "." + str(t % 10)
    if neg:
        out = "-" + out
    return out


def _num(s):
    """A float from a cell, or None. Tolerates 184, 184.2, "184.2 lb",
    1,842 and a stray + -- people type into their own spreadsheet."""
    t = str(s).strip().replace(",", "").replace("+", "")
    keep = ""
    for ch in t.elems():
        if ch in "0123456789.-":
            keep += ch
        elif keep != "":
            break
    if keep == "" or keep == "-" or keep == ".":
        return None
    dots = 0
    for ch in keep.elems():
        if ch == ".":
            dots += 1
    if dots > 1:
        return None
    return float(keep)


def _days_from_civil(y, m, d):
    """Days since 1970-01-01. Hinnant's algorithm -- exact, no table."""
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def _civil_from_days(z):
    """[y, m, d] from a day number -- the inverse of the above."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]


def _parse_date(s):
    """A day number from a cell, or None.

    gviz renders a date column the way the sheet DISPLAYS it, not as a
    serial, so the format is whatever the owner's locale picked. ISO and
    both slash orders all turn up. Guessing wrong silently reorders the
    whole chart, so anything ambiguous is dropped rather than assumed."""
    t = str(s).strip()
    if t == "":
        return None
    sep = "-" if t.count("-") == 2 else ("/" if t.count("/") == 2 else "")
    if sep == "":
        return None
    nums = []
    for p in t.split(sep):
        v = _num(p)
        if v == None:
            return None
        nums.append(int(v))
    if len(nums) != 3:
        return None
    if nums[0] > 31:
        y, m, d = nums[0], nums[1], nums[2]
    else:
        m, d, y = nums[0], nums[1], nums[2]
        if y < 100:
            y += 2000
    if m < 1 or m > 12 or d < 1 or d > 31 or y < 1900 or y > 2200:
        return None
    return _days_from_civil(y, m, d)


def _csv_rows(text):
    """Rows of cells from gviz CSV. Quoted fields may hold commas and
    doubled quotes; nothing else in the dialect matters here."""
    rows = []
    row = []
    cell = ""
    inq = False
    i = 0
    n = len(text)
    for _ in range(n):
        if i >= n:
            break
        ch = text[i]
        if inq:
            if ch == '"':
                if i + 1 < n and text[i + 1] == '"':
                    cell += '"'
                    i += 1
                else:
                    inq = False
            else:
                cell += ch
        elif ch == '"':
            inq = True
        elif ch == ",":
            row.append(cell)
            cell = ""
        elif ch == "\n":
            row.append(cell)
            rows.append(row)
            row = []
            cell = ""
        elif ch != "\r":
            cell += ch
        i += 1
    if cell != "" or len(row) > 0:
        row.append(cell)
        rows.append(row)
    return rows


def _col_index(header, want, fallback):
    """Which column the user meant. A single letter is a position; anything
    else is matched against the header text, so a sheet whose columns move
    keeps working."""
    w = str(want).strip().upper()
    if w == "":
        return fallback
    if len(w) == 1 and w >= "A" and w <= "Z":
        return ord(w) - ord("A")
    for i in range(len(header)):
        if str(header[i]).strip().upper() == w:
            return i
    for i in range(len(header)):
        if w in str(header[i]).strip().upper():
            return i
    return fallback


def sheet_id(url):
    """The document id out of whatever the user pasted -- the edit link,
    the share link, or a bare id."""
    u = str(url).strip()
    if u == "":
        return ""
    if "/d/" in u:
        rest = u.split("/d/")[1]
        for cut in ["/", "?", "#"]:
            if cut in rest:
                rest = rest.split(cut)[0]
        return rest
    if "/" not in u and len(u) > 20:
        return u
    return ""


def fetch_log(ctx):
    """[[day, weight], ...] oldest first, or a string naming what broke."""
    sid = sheet_id(ctx.inputs.get("sheeturl", ""))
    if sid == "":
        return "NO SHEET"
    gid = str(ctx.inputs.get("gid", "")).strip()
    params = {}
    if gid != "":
        params["gid"] = gid
    # Sort and cap server-side when the date column is a plain letter, so a
    # five-year sheet is never downloaded in full just to throw most of it
    # away. gviz answers a bad column reference with 200 and a JSON error
    # body rather than an HTTP error, so that has to be sniffed for.
    dc = str(ctx.inputs.get("datecol", "A")).strip().upper()
    r = None
    if len(dc) == 1 and dc >= "A" and dc <= "Z":
        q = dict(params)
        q["tq"] = "select * order by " + dc + " desc limit " + str(MAX_ROWS)
        probe = http.get("https://docs.google.com/spreadsheets/d/" + sid + GVIZ,
                         params = q, ttl_seconds = 14400)
        if probe["status_code"] == 200 and probe["body"] and \
           not probe["body"].startswith("{"):
            r = probe
    if r == None:
        r = http.get("https://docs.google.com/spreadsheets/d/" + sid + GVIZ,
                     params = params, ttl_seconds = 14400)
    if r["status_code"] == 404:
        # gviz answers 404 for both "no such document" and "not shared",
        # and the second is far likelier -- nobody pastes a URL for a
        # sheet that does not exist.
        return "NOT SHARED"
    if r["status_code"] != 200 or not r["body"]:
        return "NO SHEET"

    rows = _csv_rows(r["body"])
    if len(rows) < 2:
        return "SHEET EMPTY"
    header = rows[0]
    di = _col_index(header, ctx.inputs.get("datecol", ""), 0)
    wi = _col_index(header, ctx.inputs.get("weightcol", ""), 1)

    out = []
    for row in rows[1:]:
        if len(row) <= di or len(row) <= wi:
            continue
        day = _parse_date(row[di])
        val = _num(row[wi])
        if day == None or val == None or val <= 0:
            continue
        out.append([day, val])
    if len(out) == 0:
        # Rows exist but nothing parsed, which nearly always means the two
        # columns are pointed somewhere else.
        return "CHECK COLUMNS"

    # A sheet is not sorted just because it looks sorted; people backfill
    # a missed morning at the bottom.
    out = sorted(out)
    merged = []
    for e in out:
        if len(merged) > 0 and merged[-1][0] == e[0]:
            merged[-1] = e          # one weigh-in per day; the later wins
        else:
            merged.append(e)
    return merged


def trend_of(series):
    """The smoothed trend, one value per weigh-in.

    The first reading seeds the trend outright: smoothing it against itself
    would start the line above or below every real number in the log."""
    t = [series[0][1]]
    cur = series[0][1]
    for i in range(1, len(series)):
        dt = series[i][0] - series[i - 1][0]
        if dt < 1:
            dt = 1
        a = dt / (TAU + dt)
        cur = cur + a * (series[i][1] - cur)
        t.append(cur)
    return t


def resample(days, vals, n):
    """`n` samples spread evenly over the window's DATE range.

    This is what makes the chart honest. The sparkline helper spaces its
    input evenly across the box, so handing it one point per weigh-in
    draws a week with four readings as wide as a week with one. Here every
    column is the same number of days, and a gap between weigh-ins is
    interpolated straight across."""
    if n < 2 or len(days) < 2:
        return [vals[len(vals) - 1]] * (n if n > 0 else 1)
    span = days[len(days) - 1] - days[0]
    if span <= 0:
        return [vals[len(vals) - 1]] * n
    out = []
    j = 0
    for i in range(n):
        t = days[0] + span * i / (n - 1.0)
        # Walk forward to the pair of weigh-ins bracketing t. i only ever
        # increases, so j never has to go back.
        for _ in range(len(days)):
            if j + 1 < len(days) - 1 and days[j + 1] < t:
                j += 1
            else:
                break
        d0, d1 = days[j], days[j + 1]
        v0, v1 = vals[j], vals[j + 1]
        if d1 == d0:
            out.append(v1)
        else:
            f = (t - d0) / (d1 - d0)
            f = 0.0 if f < 0 else (1.0 if f > 1 else f)
            out.append(v0 + (v1 - v0) * f)
    return out


def rate_per_week(days, trend):
    """Trend change per week across the window, or None with too little to
    say. Two weigh-ins a day apart cannot support a weekly rate."""
    if len(days) < 2:
        return None
    span = days[len(days) - 1] - days[0]
    if span < 7:
        return None
    return (trend[len(trend) - 1] - trend[0]) * 7.0 / span


def read(ctx):
    """Everything the layouts draw, or a [title, detail] problem."""
    data = fetch_log(ctx)
    if type(data) == "string":
        DETAIL = {
            "NO SHEET": "ADD THE URL",
            "NOT SHARED": "SHARE THE LINK",
            "SHEET EMPTY": "ADD A WEIGH IN",
            "CHECK COLUMNS": "DATE AND WEIGHT",
        }
        return [data, DETAIL.get(data, "CHECK SETTINGS")]

    label = str(ctx.inputs.get("window", "90 DAYS")).strip().upper()
    span_days = WINDOWS.get(label, 90)
    today = ctx.now.unix // 86400

    # The year cap applies even to rows the server did not filter -- a sheet
    # whose date column is named rather than lettered comes back whole.
    if span_days > MAX_DAYS:
        span_days = MAX_DAYS
    data = [e for e in data if e[0] >= today - MAX_DAYS]
    if len(data) == 0:
        return ["NO WEIGH INS", "NONE THIS YEAR"]
    if len(data) > MAX_ROWS:
        data = data[len(data) - MAX_ROWS:]
    win = [e for e in data if e[0] >= today - span_days]
    if len(win) == 0:
        # The window is empty but the log is not: say how cold the trail
        # is rather than pretending there is no data at all.
        return ["NO WEIGH INS", str(today - data[-1][0]) + " DAYS STALE"]

    days = [e[0] for e in win]
    trend = trend_of(win)
    goal = _num(ctx.inputs.get("goal", ""))
    unit = UNIT_LABEL.get(str(ctx.inputs.get("units", "POUNDS")).strip().upper(), "LB")
    rate = rate_per_week(days, trend)

    # The headline numbers are the ones off the scale, not a smoothed
    # average of them: the latest reading is the one worth being proud of,
    # and the change since the window opened is the other. The smoothing
    # still drives the RATE and the chart line, where a raw series is just
    # noise -- but it is never the number on the panel.
    latest = win[len(win) - 1][1]
    start = win[0][1]

    togo = None
    eta = ""
    pct = 0
    need = None
    days_left = None
    pace = ""
    if goal != None and goal > 0:
        togo = latest - goal
        if rate != None and rate != 0.0:
            wanted = -1.0 if togo > 0 else 1.0
            moving = -1.0 if rate < 0 else 1.0
            # togo is positive when there is weight to LOSE and rate is
            # negative when it is coming off, so the two signs cancel:
            # dividing them straight gives a negative answer for a run
            # that is going exactly to plan.
            weeks_left = togo / -rate
            if wanted == moving and weeks_left > 0:
                if weeks_left > 52:
                    eta = "OVER A YEAR"
                else:
                    ymd = _civil_from_days(today + int(weeks_left * 7))
                    eta = MONTHS[ymd[1] - 1] + " " + str(ymd[2])
                    # 48 weeks out lands in next year, and a bare "AUG 7"
                    # then reads as a date that has already been and gone.
                    now_y = _civil_from_days(today)[0]
                    if ymd[0] != now_y:
                        eta = MONTHS[ymd[1] - 1] + " '" + str(ymd[0])[2:]
            else:
                eta = "WRONG WAY"

        travelled = start - latest
        total = start - goal
        if total < 0:
            travelled = -travelled
            total = -total
        if total > 0:
            p = travelled * 100.0 / total
            pct = int(0 if p < 0 else (100 if p > 100 else p))

        # A target DATE turns the question from "when will I get there" into
        # "am I on pace", which is the one the user can act on today.
        # Standing on the number is not "off pace" -- it is done. This has
        # to win before any date arithmetic runs.
        met = togo < 0.5 and togo > -0.5
        gd = _parse_date(ctx.inputs.get("goaldate", ""))
        if met:
            pace = "GOAL MET"
            if gd != None:
                days_left = gd - today
        elif gd != None:
            days_left = gd - today
            if days_left <= 0:
                pace = "PAST DUE"
            else:
                need = togo * 7.0 / days_left      # units per week required
                if rate == None:
                    pace = "NEED " + _fmt1(need if need > 0 else -need)
                else:
                    # Both are signed the same way: negative need with a
                    # negative rate means losing, and losing fast enough.
                    ok = (need > 0 and rate <= -0.0) or (need < 0 and rate >= 0.0)
                    if not ok:
                        pace = "OFF PACE"
                    elif (rate < 0 and rate <= -need) or (rate > 0 and rate >= -need):
                        pace = "ON PACE"
                    else:
                        pace = "BEHIND"

    return {
        "raw": [e[1] for e in win],
        "pct": pct,
        "need": need,
        "days_left": days_left,
        "pace": pace,
        "start": start,
        "days": days,
        "trend": trend,
        "now": latest,
        "trend_now": trend[len(trend) - 1],
        "goal": goal,
        "togo": togo,
        "rate": rate,
        "eta": eta,
        "unit": unit,
        "since": today - days[len(days) - 1],
        "label": label,
        "short": "ALL" if span_days == 0 else str(span_days) + "D",
    }


def verdict(d):
    """[word, colour]. The word is what the trend is doing; the colour is
    whether that is what the user asked for. One function, so the two can
    never contradict each other -- FALLING painted green unconditionally
    told someone bulking that losing weight was going well."""
    r = d["rate"]
    if d["togo"] != None and d["togo"] < 0.5 and d["togo"] > -0.5:
        return ["GOAL MET", GOOD]
    if r == None:
        return ["NEW", INK]
    word = "HOLDING"
    if r < -0.1:
        word = "FALLING"
    elif r > 0.1:
        word = "RISING"
    if d["togo"] == None:
        return [word, INK]
    if word == "HOLDING":
        return [word, WARN]
    toward = (d["togo"] > 0 and r < 0) or (d["togo"] < 0 and r > 0)
    return [word, GOOD if toward else WARN]


def rail(c, color):
    """The accent spine. Splash only -- it is an identity mark, and running
    it down every page just narrowed the data pages by two columns."""
    c.rect(0, 0, 1, 31, fill = color)


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do.
    text_fit draws its smallest option even when nothing fits."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]


def pick_var(c, options, font, maxw):
    """The first whole variant that fits. Clipping mid-word printed
    '31.8LB ON PA', which reads as a bug rather than a shortage of room."""
    for o in options:
        if c.text_width(o, font) <= maxw:
            return o
    return options[len(options) - 1]


def hero_fit(c, value, unit, fonts, maxw):
    """[font, total width]. Sized for three digits, because nobody weighs
    1000 of anything -- reserving a fourth digit cost the hero a whole
    font rung for a case that never arrives."""
    dot = value.find(".")
    whole = value[:dot] if dot > 0 else value
    frac = value[dot:] if dot > 0 else ""
    fw = c.text_width(frac, "4x5") + 1 if frac != "" else 0
    uw = c.text_width(unit, "4x5") + 2 if unit != "" else 0
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(whole, f) + fw + uw <= maxw:
            pick = f
            break
    return [pick, c.text_width(whole, pick) + fw + uw]


def hero(c, x, y, value, unit, fonts, maxw, col):
    """A big number with a small decimal and unit, aligned on the INK, not
    the cell. 10x16 digits leave a blank row under them and 16x20 do not,
    so a fixed offset floated the unit one row low at one size and not the
    other. Returns the width drawn."""
    pick, total = hero_fit(c, value, unit, fonts, maxw)
    dot = value.find(".")
    whole = value[:dot] if dot > 0 else value
    frac = value[dot:] if dot > 0 else ""
    base = y + FONTH[pick] - 5 - BLANK[pick]
    c.text(whole, x, y, font = pick, color = col)
    cx = x + c.text_width(whole, pick)
    if frac != "":
        c.text(frac, cx + 1, base, font = "4x5", color = col)
        cx += c.text_width(frac, "4x5") + 1
    if unit != "":
        c.text(unit, cx + 2, base, font = "4x5", color = DIM)
    return total


def num_unit(c, cx, y, value, unit, fonts, maxw, col, ucol = DIM):
    """A number with a small unit beside it, the pair centred on `cx`.

    Signed values must never land on 8x12 (its hyphen is a solid block) or
    7x10 (it has no plus glyph at all -- "+12" silently draws as "12"), so
    those two are kept out of every ladder that reaches this."""
    uw = c.text_width(unit, "4x5") + 2 if unit != "" else 0
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(value, f) + uw <= maxw:
            pick = f
            break
    vw = c.text_width(value, pick)
    x = cx - (vw + uw) // 2
    c.text(value, x, y, font = pick, color = col)
    if unit != "":
        c.text(unit, x + vw + 2, y + FONTH[pick] - 5 - BLANK[pick],
               font = "4x5", color = ucol)


def centred(c, cx, y, text, w, color = DIM):
    c.text(_fit_clip(c, text, ["4x5"], w)[1], cx, y, font = "4x5",
           color = color, align = "center")


def eyebrow(c, x, y, text, w, color = DIM):
    c.text(_fit_clip(c, text, ["4x5"], w)[1], x, y, font = "4x5", color = color)


def nodata(c, title, sub):
    """Every unreachable-sheet case, and what the publish-time validator
    sees. Two lines on bands that can never overlap."""
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, ["10x16", "6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        s = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(s[1], c.width // 2, 22, font = s[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        s = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(s[1], c.width // 2, 18, font = s[0], color = "#6A7090",
               align = "center")


def stale_note(d):
    s = d["since"]
    if s <= 1:
        return ""
    if s <= 9:
        return str(s) + "D AGO"
    return "STALE " + str(s) + "D"


def md(day):
    """M/D from a day number -- the date the weigh-in actually carries."""
    y, m, dd = _civil_from_days(day)
    return str(m) + "/" + str(dd)


def scale_of(d, w):
    """[samples, lo, hi]. The goal sits inside the range at its TRUE
    distance: clamping it to the frame told the viewer it was close."""
    vals = resample(d["days"], d["trend"], w)
    lo = vals[0]
    hi = vals[0]
    for v in vals:
        lo = v if v < lo else lo
        hi = v if v > hi else hi
    for r in d["raw"]:
        lo = r if r < lo else lo
        hi = r if r > hi else hi
    g = d["goal"]
    if g != None and g > 0:
        lo = g if g < lo else lo
        hi = g if g > hi else hi
    if hi - lo < 1.0:
        mid = (hi + lo) / 2.0
        lo = mid - 0.5
        hi = mid + 0.5
    pad = (hi - lo) * 0.12
    out_lo = lo - pad
    out_hi = hi + pad
    # The padding is headroom for the trend line, not for the target. When
    # the goal is the lowest thing on the chart it belongs on the bottom
    # row -- floating it 12% up read as "nearly there" when it was not, and
    # as "still short" when the goal had actually been met.
    if g != None and g > 0:
        if g <= lo:
            out_lo = g
        if g >= hi:
            out_hi = g
    return [vals, out_lo, out_hi]


def chart(c, d, x, y, w, h, col, labelled, hide_values = False,
          hide_names = False):
    """Trend line, the weigh-ins behind it, and the goal rule.

    The plot the smoothing comes from: a solid trend, the raw readings
    marked so the scatter stays visible, the goal as its own line. The wash
    under the trend is what makes the shape read across a room."""
    vals, lo, hi = scale_of(d, w)
    span = hi - lo
    bottom = y + h - 1

    def row(v):
        r = bottom - int((v - lo) / span * (h - 1) + 0.5)
        return y if r < y else (bottom if r > bottom else r)

    c.sparkline(vals, x, y, w, h, color = col, fill = WASH.get(col, "#123521"),
                min_val = lo, max_val = hi)

    g = d["goal"]
    goal_lab_y = -99
    if g != None and g > 0:
        gy = row(g)
        c.hline(x, gy, w, TARGETLINE)
        # The word goes ON the line. Parked in the chip row it named
        # something the eye then had to go hunting for.
        ly = gy - 6 if gy - 6 >= y else gy + 2
        if ly + 4 > y + h - 1:
            ly = gy - 6
        if ly >= y and ly + 4 <= y + h - 1:
            lab = "TARGET" if w >= 120 else "TGT"
            if not hide_names and w >= 120:
                lab = "TARGET " + str(int(g + 0.5))
            c.text_stroke(_fit_clip(c, lab, ["4x5"], w - 4)[1], x + 2, ly,
                          font = "4x5", color = TARGETLINE, stroke = "black")
            goal_lab_y = ly

    if labelled and len(d["days"]) > 1:
        d0 = d["days"][0]
        dspan = d["days"][len(d["days"]) - 1] - d0
        if dspan > 0:
            for i in range(len(d["days"])):
                px = x + int((d["days"][i] - d0) * (w - 1) / dspan + 0.5)
                c.pixel(px, row(d["raw"][i]), INK)

    c.rect(x + w - 2, row(vals[len(vals) - 1]) - 1,
           x + w - 1, row(vals[len(vals) - 1]), fill = INK)

    if labelled and not hide_values:
        # Where the line starts and where it stands now. A chart with no
        # numbers on it is a shape; these two make it a measurement --
        # except in TRENDONLY, where a weight on the panel is the one thing
        # the setting exists to prevent.
        # Whole numbers on the chart: the decimal is noise at this size and
        # the stats page carries the precise figures.
        a = str(int(d["start"] + 0.5))
        b = str(int(d["now"] + 0.5))
        ay = row(d["start"])
        by = row(d["now"])
        say = ay + 2 if ay < y + h - 7 else ay - 6
        # Both the start value and the target label live at the left edge.
        # When the goal line runs near the start of the trend they printed
        # through each other; the target is the more useful of the two, so
        # the start value stands down.
        gap = say - goal_lab_y
        if gap < 0:
            gap = -gap
        if gap >= 6:
            c.text_stroke(a, x + 1, say, font = "4x5", color = DIM,
                          stroke = "black")
        c.text_stroke(b, x + w - 3, by + 2 if by < y + h - 7 else by - 6,
                      font = "4x5", color = INK, stroke = "black",
                      align = "right")


def total_str(moved, dp):
    """The change, signed, because half of these are gains. Never drawn at
    8x12 (its hyphen is a solid block) or 7x10 (it has no plus glyph at all,
    so "+12" silently draws as "12")."""
    v = moved if moved > 0 else -moved
    body = _fmt1(v) if dp else str(int(v + 0.5))
    return ("+" if moved > 0 else "-") + body


def asof(d):
    """How fresh the headline number is. It rides with the weight, because a
    weight with no date attached is not a fact about today."""
    n = d["since"]
    if n <= 0:
        return "AS OF TODAY"
    return "AS OF " + str(n) + "D AGO"


def which_art(d):
    if type(d) == "list" or d["togo"] == None:
        return ART_DOWN
    return ART_UP if d["togo"] < 0 else ART_DOWN


def splash(c, ctx):
    """Identity on the left, and where you stand on the right.

    The wordmark's second line is outlined rather than solid, so the two
    words read as one lockup at a glance instead of as two equal-weight
    lines shouting at each other."""
    c.fill("black")
    d = read(ctx)
    tail = "GOALS"
    if type(d) != "list" and d["togo"] == None:
        tail = "TRACKER"
    if c.width < 128:
        c.sprite(which_art(d), (c.width - 28) // 2, 0, legend = ART_LEGEND)
        w = "WEIGHT " + tail
        if c.text_width(w, "4x5") > c.width - 4:
            w = tail
        c.text(w, c.width // 2, 26, font = "4x5", color = GOOD,
               align = "center")
        return

    # Everything shifts to 2px off the left edge. The 20px of opening black
    # and the 39px hole between the plot and the wordmark were together most
    # of a third of the panel; spending them on the number instead lets the
    # headline run at 16x20 here, the same size it gets anywhere else.
    c.rect(2, 0, 3, 31, fill = GOOD)
    c.sprite(which_art(d), 8, 4, legend = ART_LEGEND)
    WM = 38
    c.text("WEIGHT", WM, 0, font = "10x16", color = INK)
    c.text(tail, WM, 16, font = "10x16_outline", color = GOOD)
    end = WM + c.text_width("WEIGHT", "10x16")
    if WM + c.text_width(tail, "10x16_outline") > end:
        end = WM + c.text_width(tail, "10x16_outline")

    R = c.width - MARGIN - 1
    L = end + 6
    room = R - L + 1
    if type(d) == "list" or room < 30:
        return
    # The pill, the weight and the bar all start on the same left edge, and
    # the right side is left ragged. The bar is the one element allowed to
    # run to the last column: it is a rule, not text, so it reads as the
    # page's own baseline rather than as content touching a neighbour.
    BARW = c.width - L
    lab = pick_var(c, [asof(d), "AS OF " + str(d["since"]) + "D",
                       str(d["since"]) + "D AGO", "TODAY"], "4x5", BARW - 4)
    c.badge(lab, L, 0, color = "black", bg = CHIP, font = "4x5")

    trendonly = _bool_input(ctx.inputs.get("trendonly", False), False)
    word, col = verdict(d)
    if trendonly:
        h = _fit_clip(c, SHORT_WORD.get(word, word),
                      ["16x20", "10x16", "6x8"], BARW)
        c.text(h[1], L, 9, font = h[0], color = col)
    else:
        hero(c, L, 9, _fmt1(d["now"]), d["unit"],
             ["16x20", "10x16", "6x8"], BARW, col)
    if d["togo"] != None:
        c.progress_bar(L, 30, BARW - 4, 2, d["pct"], color = col,
                       bg = "#1E2430")


def now(c, ctx):
    """Two numbers, given half a panel each.

    The weight itself moved to the splash, which had a hole in it and is the
    page a viewer meets first. What is left here is the pair that actually
    answers "how is this going" -- how far it has come, and how far is left
    -- so both get a 16x20 hero instead of the 8x12 they were squeezed into
    when three numbers shared the width."""
    d = read(ctx)
    if type(d) == "list":
        nodata(c, d[0], d[1])
        return
    trendonly = _bool_input(ctx.inputs.get("trendonly", False), False)
    word, col = verdict(d)
    unit = d["unit"]
    moved = d["now"] - d["start"]
    tint = INK
    if d["togo"] != None and moved != 0:
        if d["pace"] == "GOAL MET":
            tint = TINT_GOOD
        else:
            good = (d["togo"] > 0 and moved < 0) or (d["togo"] < 0 and moved > 0)
            tint = TINT_GOOD if good else TINT_BAD
    c.fill("black")

    if c.width >= 128:
        # Bands: eyebrow 0-4, hero 6-25, footnote 27-31. One clear row
        # between each, and the halves split by a full-height post.
        R = c.width - MARGIN - 1
        HALF = c.width // 2
        c.vline(HALF, 0, 32, STRUCT)
        LCX = MARGIN + (HALF - 2 - MARGIN) // 2
        RCX = HALF + 2 + (R - HALF - 2) // 2
        LW = HALF - 2 - MARGIN
        RW = R - HALF - 2

        centred(c, LCX, 0, "TOTAL " + d["short"], LW)
        if trendonly:
            c.trend_arrow(LCX - 2, 12, 0 if d["rate"] == None else
                          (1 if d["rate"] > 0 else -1), col)
        else:
            num_unit(c, LCX, 6, total_str(moved, False), unit,
                     ["16x20", "10x16", "6x8"], LW, tint)
        if d["rate"] != None and not trendonly:
            centred(c, LCX, 27, _fmt1(d["rate"]) + " " + unit + "/WK", LW, SKY)
        else:
            centred(c, LCX, 27, str(d["days"][len(d["days"]) - 1] -
                                    d["days"][0]) + " DAYS", LW)

        if d["togo"] != None:
            lab = "TARGET"
            if d["days_left"] != None and d["days_left"] > 0:
                lab = "TARGET " + str(d["days_left"]) + "D"
            centred(c, RCX, 0, lab, RW, TARGETC)
            if trendonly:
                c.sprite(BULLSEYE, RCX - 26, 11, legend = eye_legend(TARGETC))
                c.text(str(d["pct"]) + "%", RCX + 26, 9, font = "10x16",
                       color = col, align = "right")
            else:
                num_unit(c, RCX, 6, str(int(d["goal"] + 0.5)), unit,
                         ["16x20", "10x16", "6x8"], RW, INK)
            tail = d["pace"] if d["pace"] != "" else d["eta"]
            if tail != "":
                centred(c, RCX, 27, tail, RW, PACECOL.get(tail, DIM))
        else:
            centred(c, RCX, 4, "NO TARGET", RW, DIM)
            centred(c, RCX, 13, "SET A GOAL", RW, DIM)
            centred(c, RCX, 22, "TO SEE PACE", RW, DIM)
    else:
        # 64 keeps all three, because it has no room for a split.
        c.badge("W", 1, 0, color = "black", bg = CHIP, font = "4x5")
        c.text(_fit_clip(c, _fmt1(d["rate"]) + unit + "/WK"
                         if d["rate"] != None else "NEW LOG", ["4x5"], 46)[1],
               62, 1, font = "4x5", color = SKY, align = "right")
        if trendonly:
            h = _fit_clip(c, SHORT_WORD.get(word, word), ["10x16", "6x8"], 62)
            c.text(h[1], c.width // 2, 8, font = h[0], color = col,
                   align = "center")
        else:
            hf = hero_fit(c, _fmt1(d["now"]), unit, ["10x16", "6x8"], 62)
            hero(c, (c.width - hf[1]) // 2, 8, _fmt1(d["now"]), unit,
                 ["10x16", "6x8"], 62, col)
        if d["togo"] != None:
            c.sprite(BULLSEYE, 1, 24, legend = eye_legend(TARGETC))
            if trendonly:
                c.text(str(d["pct"]) + "%", 10, 25, font = "4x5", color = col)
                tail = d["pace"] if d["pace"] != "" else d["eta"]
                if tail != "":
                    c.text(_fit_clip(c, tail, ["4x5"], 34)[1], 62, 25,
                           font = "4x5", color = PACECOL.get(tail, DIM),
                           align = "right")
            else:
                tot = total_str(moved, False) + ("TG" if moved > 0 else "TL")
                tw = c.text_width(tot, "4x5")
                c.text(tot, 62, 25, font = "4x5", color = tint,
                       align = "right")
                c.text(_fit_clip(c, str(int(d["goal"] + 0.5)), ["4x5"],
                                 62 - tw - 4 - 10)[1],
                       10, 25, font = "4x5", color = DIM)
        else:
            c.text(_fit_clip(c, total_str(moved, False) +
                             ("TG" if moved > 0 else "TL"), ["4x5"], 60)[1],
                   c.width // 2, 25, font = "4x5", color = tint,
                   align = "center")


def graph(c, ctx):
    """The chart with the whole panel to itself."""
    d = read(ctx)
    if type(d) == "list":
        nodata(c, d[0], d[1])
        return
    word, col = verdict(d)
    hide = _bool_input(ctx.inputs.get("trendonly", False), False)
    c.fill("black")
    if c.width >= 128:
        c.badge(d["label"], MARGIN, 0, color = "black", bg = CHIP, font = "4x5")
        c.text(word, 192 - MARGIN, 1, font = "4x5", color = col,
               align = "right")
        chart(c, d, MARGIN, 9, 192 - MARGIN * 2, 22, col, True, hide, hide)
    else:
        c.badge("W", 1, 0, color = "black", bg = CHIP, font = "4x5")
        c.text(d["short"], 62, 1, font = "4x5", color = DIM, align = "right")
        chart(c, d, 1, 8, 62, 23, col, True, hide, hide)


def stats(c, ctx):
    d = read(ctx)
    if type(d) == "list":
        nodata(c, d[0], d[1])
        return
    if _bool_input(ctx.inputs.get("trendonly", False), False):
        trend_card(c, d)
        return
    stats_page(c, ctx, d)


def trend_card(c, d):
    """What the stats page becomes under TRENDONLY. Every number on the real
    stats page is a weight or a weight delta, and the whole point of the
    setting is that none of those reach the wall -- so the page carries
    progress and cadence instead. A manifest page always renders, so this
    replaces it rather than removing it."""
    word, col = verdict(d)
    narrow = c.width < 128
    L = 1 if narrow else MARGIN
    R = c.width - L
    c.fill("black")
    c.badge("W" if narrow else "PROGRESS", L, 0, color = "black", bg = CHIP,
            font = "4x5")
    c.text(d["short"] if narrow else d["label"], R, 1, font = "4x5",
           color = DIM, align = "right")
    if d["togo"] == None:
        c.text(_fit_clip(c, SHORT_WORD.get(word, word),
                         ["16x20", "10x16", "6x8"], R - L)[1],
               c.width // 2, 10, font = "16x20" if not narrow else "10x16",
               color = col, align = "center")
        return
    big = str(d["pct"]) + "%"
    tail = d["pace"] if d["pace"] != "" else d["eta"]
    if narrow:
        # 64: bullseye and percentage on one band, the pace on its own.
        # A 16x20 "60%" is 20 rows and ran straight through both footers.
        c.sprite(BULLSEYE, L, 13, legend = eye_legend(TARGETC))
        f = _fit_clip(c, big, ["10x16", "6x8"], R - L - 11)
        c.text(f[1], R, 9, font = f[0], color = col, align = "right")
        if tail != "":
            c.text(_fit_clip(c, tail, ["4x5"], R - L)[1], (L + R) // 2, 26,
                   font = "4x5", color = PACECOL.get(tail, DIM),
                   align = "center")
        return
    # 192: the percentage keeps its 16x20 and the two supporting lines move
    # BESIDE it rather than under it -- a 20-row hero and a footer at row 26
    # cannot share 32 rows, and this page has width to spare.
    c.sprite(BULLSEYE, L, 15, legend = eye_legend(TARGETC))
    f = _fit_clip(c, big, ["16x20", "10x16", "6x8"], 90)
    c.text(f[1], L + 11, 9, font = f[0], color = col)
    c.text(_fit_clip(c, str(len(d["days"])) + " WEIGH INS", ["4x5"], 70)[1],
           R, 11, font = "4x5", color = DIM, align = "right")
    if tail != "":
        c.text(_fit_clip(c, tail, ["4x5"], 70)[1], R, 21, font = "4x5",
               color = PACECOL.get(tail, DIM), align = "right")


def stats_page(c, ctx, d):
    """The numbers the other pages have no room for. Each value carries a
    tint rather than a colour: full green and full red across six numbers
    reads as an alarm, a tint reads as a hint."""
    trendonly = False
    word, col = verdict(d)
    unit = d["unit"]
    narrow = c.width < 128
    c.fill("black")
    R = c.width - 1 - (0 if narrow else MARGIN)
    L = 1 if narrow else MARGIN
    c.badge("STATS" if not narrow else "W", L, 0, color = "black",
            bg = CHIP, font = "4x5")
    # The window label lines up with the right-hand column of values rather
    # than the panel edge, so the page has one right margin instead of two.
    cols = 1 if narrow else 2
    colw = (R - L + 1) // cols
    head_x = L + (cols - 1) * colw + (colw - 2 if cols == 1
                                      else (colw * 7) // 10)
    c.text(d["short"] if narrow else d["label"], head_x, 1, font = "4x5",
           color = DIM, align = "right")

    moved = d["now"] - d["start"]
    # +1 good, -1 bad, 0 no opinion -- decided against the GOAL, so a gain
    # counts as progress for someone bulking.
    toward = 0
    if d["togo"] != None and moved != 0:
        if d["pace"] == "GOAL MET":
            toward = 1
        else:
            toward = 1 if ((d["togo"] > 0 and moved < 0) or
                           (d["togo"] < 0 and moved > 0)) else -1
    ratew = 0
    if d["togo"] != None and d["rate"] != None and d["rate"] != 0:
        ratew = 1 if ((d["togo"] > 0 and d["rate"] < 0) or
                      (d["togo"] < 0 and d["rate"] > 0)) else -1
    needw = 0
    if d["need"] != None and d["rate"] != None:
        need_abs = d["need"] if d["need"] > 0 else -d["need"]
        rate_abs = d["rate"] if d["rate"] > 0 else -d["rate"]
        needw = 1 if rate_abs >= need_abs else -1

    rate_s = "--" if d["rate"] == None else _fmt1(d["rate"])
    need_s = "--"
    away = "--"
    if d["togo"] != None:
        away = "--" if trendonly else _fmt1(d["togo"] if d["togo"] > 0
                                            else -d["togo"])
        if d["need"] != None:
            need_s = _fmt1(d["need"] if d["need"] > 0 else -d["need"])

    if narrow:
        # 64 has three rows, and START and CHANGE already have homes: the
        # weight is on the splash and the change is the TOTAL hero on the
        # now page. These three are the ones with nowhere else to live.
        if d["togo"] != None:
            cells = [["NEED/WK", need_s, needw],
                     ["PER WK", rate_s, ratew],
                     ["TO GO", away, 0]]
        else:
            cells = [["PER WK", rate_s, ratew],
                     ["CHANGE", ("+" if moved > 0 else "") + _fmt1(moved), toward],
                     ["LOGGED", str(len(d["days"])), 0]]
    else:
        cells = [["START", "--" if trendonly else _fmt1(d["start"]), 0],
                 ["CHANGE", ("+" if moved > 0 else "") + _fmt1(moved), toward],
                 ["PER WK", rate_s, ratew],
                 ["LOGGED", str(len(d["days"])), 0]]
        if d["togo"] != None:
            cells.append(["TO GO", away, 0])
            cells.append(["NEED/WK", need_s, needw])
        else:
            cells.append(["UNITS", unit, 0])
            cells.append(["STATE", word, 0])

    TINT = {1: TINT_GOOD, -1: TINT_BAD, 0: INK}
    n = 3 * cols
    for i in range(len(cells)):
        if i > n - 1:
            break
        cx = L + (i % cols) * colw
        # 5x7 on an 8-row pitch leaves exactly one black row between stats.
        cy = 9 + (i // cols) * 8
        # Right side measured FIRST, then the label fitted into what is
        # left -- the ordering that makes a collision impossible. The value
        # is anchored at 70% of the column rather than its far edge, so the
        # number reads as attached to its own label.
        v = _fit_clip(c, cells[i][1], ["5x7", "4x7", "3x7", "4x5"],
                      colw - 22)
        vx = cx + colw - 2 if cols == 1 else cx + (colw * 7) // 10
        vw = c.text_width(v[1], v[0])
        if vx - vw < cx + 20:
            vx = cx + 20 + vw
        if vx > cx + colw - 2:
            vx = cx + colw - 2
        c.text(v[1], vx, cy, font = v[0], color = TINT[cells[i][2]],
               align = "right")
        eyebrow(c, cx, cy + 1, cells[i][0], vx - vw - cx - 3)
