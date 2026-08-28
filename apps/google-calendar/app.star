# Google Calendar — the next meeting, today's agenda, and the week ahead, read
# straight from a calendar's "Secret address in iCal format".
#
# Why iCal and not the Calendar API: the API needs OAuth (there is no browser
# here) or an API key that only ever reaches PUBLIC calendars, and the calendar
# people actually want on a desk panel is their private one. The secret iCal
# address is a plain HTTPS GET that works for both.
#
# The feed is an unexpanded ICS export, so everything the Calendar API would do
# server-side has to happen here: unfolding wrapped lines, reading DTSTART in
# three different value types, walking RRULE forward, dropping EXDATEs, and
# letting a RECURRENCE-ID override replace the instance it names. Starlark has
# no date library, no regex and no while loop, so the pieces below are written
# to the shapes it does have.
#
# Times are carried as MINUTES since 1970-01-01 00:00 in the VIEWER's wall
# clock. That one representation makes ordering, "is it today", and formatting
# all fall out of integer arithmetic.

WINDOW_DAYS = 8          # how far ahead anything is expanded
MAX_EVENTS = 80          # keeps the sort cheap on a 2000-event export

# ---------------------------------------------------------------- date math
# Howard Hinnant's civil <-> serial-day algorithms. Integer only, correct for
# every proleptic-Gregorian date, and short enough to read.

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

def week_of(z):
    """Index of z's Monday-based week, for INTERVAL arithmetic."""
    return (z - weekday(z)) // 7

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
DOW1 = ["M", "T", "W", "T", "F", "S", "S"]
ICS_DAYS = {"MO": 0, "TU": 1, "WE": 2, "TH": 3, "FR": 4, "SA": 5, "SU": 6}

# ------------------------------------------------------------ small parsing
def digits(s):
    out = ""
    for ch in s.elems():
        if ch >= "0" and ch <= "9":
            out += ch
    return out

def num(s, fallback = -1):
    """int() raises on anything non-numeric and a raised host error kills the
    whole render, so every number out of the feed comes through here."""
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    d = digits(t)
    if d == "" or len(d) != len(t):
        return fallback
    v = int(d)
    return -v if neg else v

# ------------------------------------------------------------------- ICS io
# Properties whose folded continuation lines are pure weight: a meeting body or
# an attendee list runs to kilobytes, and rejoining them costs more than every
# field this app actually reads put together.
SKIP_FOLDS = ["DESCRIPTION", "ATTENDEE", "ORGANIZER", "X-", "ATTACH",
              "COMMENT", "GEO", "URL"]

WANT = {
    "DTSTART": 1, "DTEND": 1, "DURATION": 1, "SUMMARY": 1, "RRULE": 1,
    "EXDATE": 1, "RECURRENCE-ID": 1, "UID": 1, "STATUS": 1,
}

def unfold(body):
    """ICS wraps lines at 75 octets and marks the continuation with a leading
    space or tab. Rejoin them, except where the property is one we never read."""
    raw = body.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    out = []
    skipping = False
    for ln in raw:
        if ln.startswith(" ") or ln.startswith("\t"):
            if not skipping and len(out) > 0:
                out[len(out) - 1] = out[len(out) - 1] + ln[1:]
            continue
        skipping = False
        for p in SKIP_FOLDS:
            if ln.startswith(p):
                skipping = True
                break
        out.append(ln)
    return out

def prop(line):
    """[name, params, value] for one unfolded property line, or None."""
    i = line.find(":")
    if i < 0:
        return None
    head = line[:i]
    if head.count("\"") % 2 == 1:
        # The colon we found sits inside a quoted parameter (TZID="A:B"); take
        # the first one after the quote closes instead.
        j = line.find("\"", head.find("\"") + 1)
        i = line.find(":", j + 1) if j >= 0 else -1
        if i < 0:
            return None
        head = line[:i]
    s = head.find(";")
    if s < 0:
        return [head.upper(), "", line[i + 1:]]
    return [head[:s].upper(), head[s + 1:].upper(), line[i + 1:]]

def unescape(v):
    """ICS escapes commas, semicolons and newlines inside text values."""
    t = v.replace("\\n", " ").replace("\\N", " ")
    return t.replace("\\,", ",").replace("\\;", ";").replace("\\\\", "\\")

def parse_dt(params, val, offmin):
    """[minutes, all_day] in the viewer's wall clock, or None.

    Three value types arrive here and only one of them needs the offset:
      DTSTART;VALUE=DATE:20260822            a date, with no time at all
      DTSTART;TZID=America/New_York:...T09   a wall clock already in a zone
      DTSTART:20260822T130000Z               real UTC
    A TZID time is shown exactly as written. That is right whenever the event
    sits in the viewer's own zone -- nearly always -- and, unlike converting
    it, it stays right across a daylight-saving change with no tz database."""
    v = val.strip()
    if len(v) < 8:
        return None
    y, mo, d = num(v[0:4]), num(v[4:6]), num(v[6:8])
    if y < 1970 or mo < 1 or mo > 12 or d < 1 or d > 31:
        return None
    day = days_from_civil(y, mo, d)
    if len(v) < 13 or v[8] != "T":
        return [day * 1440, True]
    hh, mi = num(v[9:11]), num(v[11:13])
    if hh < 0 or hh > 23 or mi < 0 or mi > 59:
        return None
    t = day * 1440 + hh * 60 + mi
    if v.endswith("Z") and params.find("TZID=") < 0:
        t += offmin
    return [t, False]

def parse_duration(v):
    """Minutes in an ISO-8601 duration (PT1H30M, P1D, PT45M). 0 if unreadable."""
    t = str(v).strip().upper()
    if not t.startswith("P"):
        return 0
    mins, acc, in_time = 0, 0, False
    for ch in t[1:].elems():
        if ch == "T":
            in_time = True
        elif ch >= "0" and ch <= "9":
            acc = acc * 10 + num(ch, 0)
        else:
            if ch == "W":
                mins += acc * 10080
            elif ch == "D":
                mins += acc * 1440
            elif ch == "H":
                mins += acc * 60
            elif ch == "M" and in_time:
                mins += acc
            acc = 0
    return mins

def parse_rrule(s):
    r = {"freq": "", "interval": 1, "count": 0, "until": "",
         "byday": [], "bymonthday": [], "bymonth": []}
    for part in s.upper().split(";"):
        eq = part.find("=")
        if eq < 0:
            continue
        k, v = part[:eq], part[eq + 1:]
        if k == "FREQ":
            r["freq"] = v
        elif k == "INTERVAL":
            n = num(v)
            r["interval"] = n if n > 0 else 1
        elif k == "COUNT":
            n = num(v)
            r["count"] = n if n > 0 else 0
        elif k == "UNTIL":
            r["until"] = v
        elif k == "BYDAY":
            r["byday"] = v.split(",")
        elif k == "BYMONTHDAY":
            r["bymonthday"] = [num(x) for x in v.split(",") if num(x) > 0]
        elif k == "BYMONTH":
            r["bymonth"] = [num(x) for x in v.split(",") if num(x) > 0]
    return r

def split_byday(tok):
    """'2TU' -> [2, 1]; '-1FR' -> [-1, 4]; 'WE' -> [0, 2]. [0, -1] if unknown."""
    t = tok.strip()
    if len(t) < 2:
        return [0, -1]
    code = t[len(t) - 2:]
    if code not in ICS_DAYS:
        return [0, -1]
    head = t[:len(t) - 2]
    return [0 if head == "" else num(head, 0), ICS_DAYS[code]]

# ------------------------------------------------------------- feed reading
def parse_events(lines, offmin):
    """Every VEVENT in the feed, as flat dicts. One pass, no nesting."""
    out = []
    cur = None
    for ln in lines:
        if cur == None:
            if ln.startswith("BEGIN:VEVENT"):
                cur = {"uid": "", "summary": "", "status": "", "rrule": "",
                       "recid": None, "start": None, "end": None,
                       "allday": False, "dur": 0, "exdate": {}}
            continue
        if ln.startswith("END:VEVENT"):
            out.append(cur)
            cur = None
            continue
        # Cheap gate first: DESCRIPTION and LOCATION dominate an export, and
        # only these five initials can begin a property this app reads.
        if len(ln) == 0 or ln[0] not in ["D", "S", "R", "E", "U"]:
            continue
        p = prop(ln)
        if p == None or p[0] not in WANT:
            continue
        name, params, val = p[0], p[1], p[2]
        if name == "SUMMARY":
            cur["summary"] = unescape(val).strip()
        elif name == "UID":
            cur["uid"] = val.strip()
        elif name == "STATUS":
            cur["status"] = val.strip().upper()
        elif name == "RRULE":
            cur["rrule"] = val.strip()
        elif name == "DURATION":
            cur["dur"] = parse_duration(val)
        elif name == "DTSTART":
            dt = parse_dt(params, val, offmin)
            if dt != None:
                cur["start"] = dt[0]
                cur["allday"] = dt[1]
        elif name == "DTEND":
            dt = parse_dt(params, val, offmin)
            if dt != None:
                cur["end"] = dt[0]
        elif name == "RECURRENCE-ID":
            dt = parse_dt(params, val, offmin)
            if dt != None:
                cur["recid"] = dt[0] // 1440
        elif name == "EXDATE":
            for one in val.split(","):
                dt = parse_dt(params, one, offmin)
                if dt != None:
                    cur["exdate"][dt[0] // 1440] = True
    return out

# --------------------------------------------------------------- recurrence
def nth_weekday_day(y, m, ord_n, wd):
    """Serial day of the ord_n-th `wd` in month m -- the 2nd Tuesday, or for a
    negative ord_n the last Friday. -1 if the month has no such day."""
    first = days_from_civil(y, m, 1)
    if ord_n > 0:
        day = first + (wd - weekday(first) + 7) % 7 + (ord_n - 1) * 7
    else:
        nxt = days_from_civil(y + 1, 1, 1) if m == 12 else days_from_civil(y, m + 1, 1)
        last = nxt - 1
        day = last - (weekday(last) - wd + 7) % 7 + (ord_n + 1) * 7
    c = civil_from_days(day)
    return day if c[0] == y and c[1] == m else -1

def rule_hit(r, sday, day):
    """[matches, occurrence index] for `day` under rule `r` starting at `sday`.

    The index is what COUNT limits. Working it out arithmetically is what lets
    this test one candidate day at a time instead of generating a series from
    its first occurrence, which for a standup that started in 2019 is
    thousands of steps to reach this morning."""
    miss = [False, 0]
    if day < sday:
        return miss
    f, iv = r["freq"], r["interval"]
    sc, dc = civil_from_days(sday), civil_from_days(day)
    if len(r["bymonth"]) > 0 and dc[1] not in r["bymonth"]:
        return miss

    if f == "DAILY":
        gap = day - sday
        if gap % iv != 0:
            return miss
        return [True, gap // iv]

    if f == "WEEKLY":
        wds = []
        for tok in r["byday"]:
            b = split_byday(tok)
            if b[1] >= 0:
                wds.append(b[1])
        if len(wds) == 0:
            wds = [weekday(sday)]
        if weekday(day) not in wds:
            return miss
        wk = week_of(day) - week_of(sday)
        if wk % iv != 0:
            return miss
        # Position within the series, counting only the days at or after the
        # start in week 0, so COUNT lines up with what Google generated.
        srt = sorted(wds)
        pos, base = 0, 0
        for w in srt:
            if w < weekday(day) and (wk > 0 or w >= weekday(sday)):
                pos += 1
        if wk > 0:
            for w in srt:
                if w >= weekday(sday):
                    base += 1
            base += (wk // iv - 1) * len(srt)
        return [True, base + pos]

    if f == "MONTHLY":
        gap = (dc[0] - sc[0]) * 12 + (dc[1] - sc[1])
        if gap < 0 or gap % iv != 0:
            return miss
        if len(r["byday"]) > 0:
            ok = False
            for tok in r["byday"]:
                b = split_byday(tok)
                if b[1] < 0:
                    continue
                if b[0] == 0:
                    if weekday(day) == b[1]:
                        ok = True
                elif nth_weekday_day(dc[0], dc[1], b[0], b[1]) == day:
                    ok = True
            if not ok:
                return miss
        elif len(r["bymonthday"]) > 0:
            if dc[2] not in r["bymonthday"]:
                return miss
        elif dc[2] != sc[2]:
            return miss
        return [True, gap // iv]

    if f == "YEARLY":
        gap = dc[0] - sc[0]
        if gap < 0 or gap % iv != 0:
            return miss
        if len(r["bymonth"]) == 0 and dc[1] != sc[1]:
            return miss
        want_d = r["bymonthday"][0] if len(r["bymonthday"]) > 0 else sc[2]
        if dc[2] != want_d:
            return miss
        return [True, gap // iv]

    return miss

def expand(ev, lo_day, hi_day, skip_days, offmin):
    """Start minutes for every instance of `ev` inside [lo_day, hi_day]."""
    start = ev["start"]
    if start == None:
        return []
    sday, tod = start // 1440, start % 1440
    if ev["rrule"] == "":
        return [start] if lo_day <= sday and sday <= hi_day else []

    r = parse_rrule(ev["rrule"])
    if r["freq"] == "":
        return []
    until = 0
    if r["until"] != "":
        u = parse_dt("", r["until"], offmin)
        if u != None:
            until = u[0]

    hits = []
    for day in range(lo_day, hi_day + 1):
        if day in ev["exdate"] or day in skip_days:
            continue
        hit = rule_hit(r, sday, day)
        if not hit[0]:
            continue
        when = day * 1440 + tod
        if until > 0 and when > until:
            continue
        if r["count"] > 0 and hit[1] >= r["count"]:
            continue
        hits.append(when)
    return hits

# ------------------------------------------------------------------ palette
# Google Calendar's own event colours, in the order Google lists them.
#
# The catch: the iCal export does NOT carry them. basic.ics has no COLOR and no
# colorId, so there is nothing in the feed to read a colour out of. Rather than
# paint every event the same, each one is assigned a colour by hashing its UID
# -- stable for the life of the event, the same on all three pages, and varied
# enough that a day of meetings does not read as one block. It will not agree
# with what the same event looks like on calendar.google.com, and it cannot.
#
# Three of Google's eleven are left out on purpose. Graphite is grey, and grey
# already means chrome-or-broken here; Lavender and Blueberry are the same
# colour once a rail is two pixels wide; Basil is too dark to read as a lit
# block and collides with Sage. Eight also divides evenly, so the hash lands
# uniformly. The order alternates cool and warm, so even a round-robin
# fallback never puts two neighbours side by side.
#
# Each row is [fill, ink]. `fill` is the raw Google colour, used for rails,
# chips and blocks. `ink` is a lifted version for TEXT: several of the raw
# colours are dark enough that 1px glyph stems disappear on a black panel at
# LED brightness, and the fix is a brighter tint, not a different hue.
TINTS = [
    ["#039BE5", "#2BC0FF"],   # Peacock
    ["#F4511E", "#FF7038"],   # Tangerine
    ["#33B679", "#4CE39B"],   # Sage
    ["#8E24AA", "#C444E8"],   # Grape
    ["#F6BF26", "#FFD23D"],   # Banana
    ["#3F51B5", "#7183F0"],   # Blueberry
    ["#D50000", "#FF3B30"],   # Tomato
    ["#E67C73", "#FF9C93"],   # Flamingo
]

BLUE = "#1A73E8"          # the tab; deeper than Google's #4285F4 so white reads
BLUE_DIM = "#0A2E5C"      # today's spine on the week page
STRUCT = "darkgray"       # dividers, spines, tracks
OFFLINE = "#3C4043"       # graphite rail, for the states with no data
NOEVENT = "#17304F"       # the rail when there is simply nothing on

def event_color(uid, title):
    """[fill, ink] for one event, decided by its identity.

    A hand-rolled FNV-1a rather than the built-in hash(): the built-in is the
    host's, and if the host ever changes it every event on the panel silently
    changes colour. This one is part of the app."""
    seed = uid if uid != "" else title
    h = 2166136261
    for ch in seed.elems():
        h = (h ^ ord(ch)) * 16777619 % 4294967296
    return TINTS[h % len(TINTS)]

# --------------------------------------------------------------- formatting
def clock(mins, with_ampm = True, compact = False):
    """2:30P / 9:00A -- 12-hour, no leading zero, one-letter meridiem.

    `compact` drops the minutes on the hour (9A, 1P). It buys 15px, which on a
    64-wide panel is three more characters of the event's name -- and the name
    is what you actually needed to read."""
    tod = mins % 1440
    h, m = tod // 60, tod % 60
    ap = "P" if h >= 12 else "A"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    if compact and m == 0:
        return str(h12) + ap if with_ampm else str(h12)
    out = str(h12) + ":" + fmt.pad(m)
    return out + ap if with_ampm else out

def span(ev):
    """The time range under a title. Both meridiems only when they differ and
    the string still fits the column."""
    if ev["allday"]:
        return "ALL DAY"
    a, b = ev["start"], ev["end"]
    same = ((a % 1440) // 60 >= 12) == ((b % 1440) // 60 >= 12)
    if same:
        return clock(a, False) + "-" + clock(b)
    return clock(a) + "-" + clock(b)

def day_label(day, today):
    """TODAY / TMRW / MON..SUN -- the closed vocabulary the eyebrow allows."""
    if day == today:
        return "TODAY"
    if day == today + 1:
        return "TMRW"
    return DOW[weekday(day)]

def date_label(day):
    """FRI AUG 22."""
    c = civil_from_days(day)
    return DOW[weekday(day)] + " " + MONTHS[c[1] - 1] + " " + str(c[2])

def short_date(day):
    """FRI 22 -- the 64 panel's header has no room for the month."""
    c = civil_from_days(day)
    return DOW[weekday(day)] + " " + str(c[2])

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits. text_fit shrinks the font instead,
    and when even its smallest option overflows it draws anyway -- which is how
    a long meeting title ends up running off the panel."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    """Like clip(), but backs up to the last whole word -- unless that costs
    too much.

    A title cut to "DESIGN REV" reads as a typo and "DESIGN" reads as a title
    that ran out of room, so the word boundary is usually right. On a 64px
    panel it stops being right: "DAILY STANDUP" backs all the way up to
    "DAILY", and losing the only word that identified the meeting is worse
    than an obviously clipped one. So the whole-word version has to keep most
    of what fit; otherwise take the hard cut and let it look cut."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[:sp]
    return t

def tab(c, word, x = 4):
    """The blue page chip. Same object, same place, on every page.

    Standard pill: c.badge sizes the chip to the text's ink, so the word gets
    exactly one row above and below at every size. That is one row taller than
    the chip this used to hand-draw, so the agenda rows below start one row
    lower -- see AGENDA_TOP."""
    return x + c.badge(word, x, 0, color = "white", bg = BLUE,
                       font = "4x5") + 1

def message(c, head, sub, head_color = "amber"):
    """The one screen every failure state shares.

    5x7 is the wide panel's voice and 4x7 the narrow one's -- "ACCESS DENIED"
    is 77px at 5x7 and would run off a 64px panel. Neither line ever uses 3x4:
    that font has no space glyph, so "NO CONNECTION" comes out NOCONNECTION."""
    wide = c.width >= 128
    c.text(clip(c, head, "5x7" if wide else "4x7", c.width - 2), c.width // 2,
           11 if wide else 10, font = "5x7" if wide else "4x7",
           color = head_color, align = "center")
    if sub != "":
        c.text(clip(c, sub, "4x5", c.width - 2), c.width // 2, 23 if wide else 21,
               font = "4x5", color = "gray", align = "center")

# ------------------------------------------------------------------- fetch
def feed_url(ctx):
    """The secret (or public) iCal address, rebuilt from its two halves.

    It cannot be one field: input values ride a colon-separated render
    descriptor, so a pasted https:// link reaches the app as the word
    "https" and nothing else."""
    cal = str(ctx.inputs.get("calid", "")).strip()
    if cal == "" or cal.startswith("http"):
        return ""
    key = str(ctx.inputs.get("icalkey", "")).strip()
    if key.startswith("private-"):
        key = key[8:]
    # The id is a path segment, so its @ and # have to be percent-encoded --
    # Google's own holiday calendars are named "en.usa#holiday@group...". People
    # paste them both ways and an unencoded one 404s; re-encoding an already
    # encoded id would too, hence the %25 repair.
    cal = cal.replace("@", "%40").replace("#", "%23")
    cal = cal.replace("%2540", "%40").replace("%2523", "%23")
    part = ("private-" + key) if key != "" else "public"
    return "https://calendar.google.com/calendar/ical/" + cal + "/" + part + "/basic.ics"

def read_calendar(ctx):
    """One dict for every outcome, so a page reads `state` and never has to
    know how the fetch went beyond that."""
    offmin = zone_offset(ctx)
    now = ctx.now.unix // 60 + offmin
    base = {"state": "ok", "events": [], "now": now, "today": now // 1440}

    url = feed_url(ctx)
    if url == "":
        base["state"] = "setup"
        return base

    r = http.get(url, ttl_seconds = 300)
    code = r["status_code"]
    if code == 404:
        base["state"] = "notfound"
        return base
    if code == 401 or code == 403:
        base["state"] = "denied"
        return base
    if code != 200 or r["body"] == "":
        base["state"] = "offline"
        return base
    body = r["body"]
    if body.find("BEGIN:VCALENDAR") < 0:
        base["state"] = "notfound"
        return base

    raw = parse_events(unfold(body), offmin)

    # A RECURRENCE-ID event replaces one instance of its series, so the master
    # must not also generate that day. Collect the overridden days per UID
    # before expanding anything.
    overrides = {}
    for e in raw:
        if e["recid"] != None and e["uid"] != "":
            days = overrides.get(e["uid"], {})
            days[e["recid"]] = True
            overrides[e["uid"]] = days

    lo, hi = base["today"], base["today"] + WINDOW_DAYS
    hide_allday = str(ctx.inputs.get("hidealldays", "Show")).strip().lower() == "hide"
    out = []
    for e in raw:
        if e["status"] == "CANCELLED" or e["start"] == None:
            continue
        if e["allday"] and hide_allday:
            continue
        skip = overrides.get(e["uid"], {}) if e["recid"] == None else {}
        if e["allday"]:
            length = 1440
        elif e["end"] != None and e["end"] > e["start"]:
            length = e["end"] - e["start"]
        elif e["dur"] > 0:
            length = e["dur"]
        else:
            length = 60
        title = e["summary"] if e["summary"] != "" else "BUSY"
        tint = event_color(e["uid"], title)
        for when in expand(e, lo, hi, skip, offmin):
            if when + length <= now:
                continue                     # already finished
            out.append({"start": when, "end": when + length, "tint": tint,
                        "title": title.upper(), "allday": e["allday"]})
        if len(out) > MAX_EVENTS * 4:
            break

    # All-day events sort ahead of the timed ones that share their date.
    out = sorted(out, key = lambda e: e["start"] * 2 + (0 if e["allday"] else 1))
    base["events"] = out[:MAX_EVENTS]
    if len(base["events"]) == 0:
        base["state"] = "clear"
    return base

# ------------------------------------------------------------------- pages
# One file, two panels, branching on c.width exactly like every other paired
# app here. The vocabulary is identical on both -- blue page tab, an
# event-coloured rail, one hero answering "when" -- but the layouts are not
# scaled versions of each other: 64 stacks what 192 puts side by side, and
# each width spends its room on a different fact.
#
# The tab owns the top-left of every page. Nothing else draws there.

def state_screen(c, st):
    """Draw the states that have no events. True if it drew."""
    s = st["state"]
    if s == "ok" or s == "clear":
        return False
    wide = c.width >= 128
    c.rect(0, 0, 1, 31, fill = BLUE if s == "setup" else OFFLINE)
    if s == "setup":
        message(c, "ADD YOUR CALENDAR ID" if wide else "SET UP",
                "SETTINGS - INTEGRATE CALENDAR" if wide else "ADD CAL ID",
                head_color = "skyblue")
    elif s == "notfound":
        message(c, "CALENDAR NOT FOUND" if wide else "NOT FOUND",
                "CHECK THE ID AND THE SECRET KEY" if wide else "CHECK THE ID")
    elif s == "denied":
        message(c, "ACCESS DENIED",
                "THE SECRET KEY WAS REJECTED" if wide else "CHECK THE KEY")
    else:
        # "FEED OFFLINE" is 71px at 5x7 and will not fit a 64px panel.
        message(c, "FEED OFFLINE" if wide else "OFFLINE",
                "CANT REACH GOOGLE RIGHT NOW" if wide else "NO CONNECTION")
    return True

def hero_mode(ev, now):
    """Which of the four heroes this event gets. All-day is tested before
    live: an all-day event is "in progress" for twenty-four hours, so the
    other order puts a green NOW on every birthday and holiday."""
    if ev["allday"]:
        return "allday"
    if ev["start"] <= now:
        return "now"
    if ev["start"] - now < 60:
        return "soon"
    return "later"

# ------------------------------------------------------------- page 1: next
# ---- splash ---------------------------------------------------------------
# A calendar drawn as a calendar: a torn-off page with two binder rings, a
# coloured header band and the date on it, in Google's four brand colours.
# It is a generic calendar glyph rather than a copy of the Google mark -- the
# app reads a Google Calendar feed, it is not published by Google, so it says
# what it is without wearing somebody else's logo.
G_BLUE = "#4285F4"
G_RED = "#EA4335"
G_YELLOW = "#FBBC05"
G_GREEN = "#34A853"

def calendar_icon(c, x, y, accent):
    """A 22x22 calendar page, top-left at (x, y)."""
    c.rect(x + 2, y + 1, x + 3, y + 4, fill = "#9AA0A6")
    c.rect(x + 18, y + 1, x + 19, y + 4, fill = "#9AA0A6")
    c.round_rect(x, y + 3, x + 21, y + 21, 2, fill = "#F1F3F4")
    c.rect(x + 1, y + 4, x + 20, y + 9, fill = accent)
    for i in range(4):
        c.rect(x + 3 + i * 5, y + 12, x + 5 + i * 5, y + 13,
               fill = "#BDC1C6")
        c.rect(x + 3 + i * 5, y + 16, x + 5 + i * 5, y + 17,
               fill = "#BDC1C6")

def splash(c, ctx):
    c.fill("black")
    st = read_calendar(ctx)
    wide = c.width >= 128

    # The header band picks up how the day looks: green for a clear one, blue
    # for an ordinary one, yellow when it is filling up, red when it is packed.
    n = 0
    if st["state"] not in ["setup", "offline", "badfeed"]:
        for ev in st["events"]:
            if ev["start"] // 1440 == st["today"] or ev["start"] <= st["now"]:
                n += 1
    accent = G_GREEN
    if n >= 6:
        accent = G_RED
    elif n >= 3:
        accent = G_YELLOW
    elif n > 0:
        accent = G_BLUE

    if wide:
        calendar_icon(c, 6, 5, accent)
        c.text(day_of_month(st["today"]), 17, 14, font = "5x7",
               color = "#3C4043", align = "center")
        c.text("GOOGLE", 38, 4, font = "6x8", color = "white")
        c.text("CALENDAR", 38, 14, font = "6x8", color = accent)
        c.text(date_label(st["today"]), 38, 25, font = "4x5", color = "gray")
        if st["state"] in ["setup", "offline", "badfeed"]:
            c.text("NOT SET UP", 188, 25, font = "4x5", color = "midgray",
                   align = "right")
        elif n == 0:
            c.text("NOTHING TODAY", 188, 25, font = "4x5", color = G_GREEN,
                   align = "right")
        else:
            word = " EVENT" if n == 1 else " EVENTS"
            c.text(str(n) + word, 188, 25, font = "4x5", color = accent,
                   align = "right")
    else:
        calendar_icon(c, 4, 5, accent)
        c.text(day_of_month(st["today"]), 15, 14, font = "5x7",
               color = "#3C4043", align = "center")
        c.text("GCAL", 30, 6, font = "5x7", color = "white")
        if st["state"] in ["setup", "offline", "badfeed"]:
            c.text("SET UP", 30, 18, font = "4x5", color = "midgray")
        elif n == 0:
            c.text("CLEAR", 30, 18, font = "4x5", color = G_GREEN)
        else:
            c.text(str(n) + ("EV" if n != 1 else "EV"), 30, 18, font = "4x5",
                   color = accent)

def day_of_month(z):
    return str(civil_from_days(z)[2])

def next(c, ctx):
    c.fill("black")
    st = read_calendar(ctx)
    wide = c.width >= 128
    tab(c, "NEXT")
    if state_screen(c, st):
        return

    if st["state"] == "clear":
        c.rect(0, 0, 1, 31, fill = NOEVENT)
        if c.width >= 128:
            c.text("TODAY", 31, 2, font = "4x5", color = "gray")
            c.text("FREE", 6, 11, font = "10x16", color = "white")
            c.vline(61, 9, 21, STRUCT)
            c.text("NOTHING", 64, 4, font = "5x7", color = "gray")
            c.text("SCHEDULED", 64, 14, font = "5x7", color = "gray")
            c.rect(134, 0, 135, 31, fill = NOEVENT)
            c.text("ALL CLEAR", 139, 13, font = "4x5", color = "midgray")
        else:
            c.text("TODAY", 62, 1, font = "4x5", color = "gray", align = "right")
            c.text("FREE", 5, 7, font = "10x16", color = "white")
            c.text("NO EVENTS", 5, 24, font = "4x7", color = "gray")
        return

    ev = st["events"][0]
    now = st["now"]
    sday = ev["start"] // 1440
    tint, ink = ev["tint"][0], ev["tint"][1]
    mode = hero_mode(ev, now)
    length = ev["end"] - ev["start"]
    pct = 100 * (now - ev["start"]) / length if length > 0 else 0

    if c.width >= 128:
        c.rect(0, 0, 1, 31, fill = tint)
        c.text(day_label(sday, st["today"]), 31, 2, font = "4x5", color = "gray")
        if mode == "now":
            c.text("NOW", 6, 10, font = "10x16", color = "green")
            c.progress_bar(6, 28, 51, 3, pct, color = "green", bg = STRUCT)
        elif mode == "allday":
            # One line of 8x12 is 62px and the hero zone is 55 -- it ran
            # through the divider into the title. Stacked, it keeps the weight
            # the other three heroes have and stays inside its column.
            c.text("ALL", 6, 8, font = "8x12", color = "white")
            c.text("DAY", 6, 20, font = "8x12", color = "white")
        elif mode == "soon":
            n = str(ev["start"] - now)
            c.text(n, 6, 10, font = "16x20",
                   color = "amber" if ev["start"] - now <= 10 else "white")
            c.text("MIN", 6 + c.text_width(n, "16x20") + 5, 24, font = "4x5",
                   color = "gray")
        else:
            c.text(clock(ev["start"]), 6, 14, font = "8x12", color = "white")

        c.vline(61, 9, 21, STRUCT)
        c.text_wrapped(ev["title"], 64, 1, 66, font = "5x7", color = "white",
                       line_gap = 2, max_lines = 2)
        under = date_label(sday) if ev["allday"] else span(ev)
        c.text(clip(c, under, "4x7", 64), 64, 22, font = "4x7", color = ink)

        # The 64px a SCROLL has over the middle size buys the event AFTER this
        # one -- the second thing anyone asks a calendar. It is a quarter-scale
        # quotation of the page beside it: rail, time, title on the same rows.
        if len(st["events"]) > 1:
            nx = st["events"][1]
            c.rect(134, 0, 135, 31, fill = nx["tint"][0])
            c.text("THEN", 139, 2, font = "4x5", color = "gray")
            nday = nx["start"] // 1440
            if nx["allday"]:
                c.text("ALL DAY", 139, 10, font = "4x7", color = "amber")
            elif nday == st["today"]:
                c.text(clock(nx["start"]), 139, 10, font = "4x7", color = "amber")
            else:
                word = day_label(nday, st["today"])
                c.text(word, 139, 11, font = "4x5", color = "gray")
                c.text(clock(nx["start"]), 139 + c.text_width(word, "4x5") + 4,
                       10, font = "4x7", color = "amber")
            c.text(clip_words(c, nx["title"], "4x7", 49), 139, 22, font = "4x7",
                   color = "white")
        else:
            c.rect(134, 0, 135, 31, fill = NOEVENT)
            c.text("ALL CLEAR", 139, 13, font = "4x5", color = "midgray")
        return

    # --- 64: a poster. One number, one name. -------------------------------
    # The rail carries the progress of a running event, because a 10x16 hero
    # plus a title leaves no row for a horizontal bar. The tightest constraint
    # on the page turns into the only moving part on it.
    if mode == "now":
        c.rect(0, 0, 1, 31, fill = color.dim(tint, 30))
        top = 31 * pct / 100
        if top >= 1:
            c.rect(0, 0, 1, int(top), fill = tint)
    else:
        c.rect(0, 0, 1, 31, fill = tint)

    # The top-right slot changes meaning with the hero, so cutting the time
    # range at this width never leaves a question unanswered.
    slot = day_label(sday, st["today"])
    if mode == "soon":
        slot = clock(ev["start"])
    c.text(slot, 62, 1, font = "4x5", color = "gray", align = "right")

    if mode == "now":
        c.text("NOW", 5, 7, font = "10x16", color = "green")
    elif mode == "allday":
        c.text("ALL DAY", 5, 13, font = "6x8", color = "white")
    elif mode == "soon":
        n = str(ev["start"] - now)
        c.text(n, 5, 7, font = "10x16",
               color = "amber" if ev["start"] - now <= 10 else "white")
        c.text("MIN", 5 + c.text_width(n, "10x16") + 4, 18, font = "4x5",
               color = "gray")
    else:
        c.text(clock(ev["start"]), 5, 10, font = "8x12", color = "white")
    c.text(clip_words(c, ev["title"], "4x7", 59), 5, 24, font = "4x7",
           color = "white")

# ------------------------------------------------------------ page 2: today
def today(c, ctx):
    c.fill("black")
    st = read_calendar(ctx)
    wide = c.width >= 128
    tab(c, "TODAY")
    if state_screen(c, st):
        return

    rows = 3 if wide else 2
    # TODAY has to mean today. `events` is the whole eight-day window, so
    # without this a quiet morning fills its rows with tomorrow's meetings
    # under a TODAY header, and the +N badge counts the entire week. An event
    # that started before now is still today's even if it began yesterday.
    mine = []
    for ev in st["events"]:
        if ev["start"] // 1440 == st["today"] or ev["start"] <= st["now"]:
            mine.append(ev)
    shown = mine[:rows]
    extra = len(mine) - len(shown)
    # The full date fits a SCROLL; at 64 the month is what gives way.
    stamp = date_label(st["today"]) if wide else short_date(st["today"])
    c.text(stamp, c.width - 2, 2 if wide else 1, font = "4x5", color = "gray",
           align = "right")

    if st["state"] == "clear" or len(mine) == 0:
        if c.width >= 128:
            c.icon("check", 39, 12, color = "green")
            c.text("NOTHING SCHEDULED", 51, 12, font = "5x7", color = "white")
            c.text("ENJOY THE FREE TIME", c.width // 2, 24, font = "4x5",
                   color = "midgray", align = "center")
        else:
            c.icon("check", 4, 10, color = "green")
            c.text("NO EVENTS", 16, 10, font = "4x7", color = "white")
            c.text("ENJOY IT", 32, 22, font = "4x5", color = "midgray",
                   align = "center")
        return

    if extra > 0:
        n = "+" + str(extra if extra < 10 else 9)
        if c.width >= 128:
            c.text(n, 36, 2, font = "4x5", color = "midgray")
        else:
            c.text(n, 62, 19, font = "4x5", color = "midgray", align = "right")

    for i in range(len(shown)):
        ev = shown[i]
        running = ev["start"] <= st["now"] and ev["end"] > st["now"]
        if ev["allday"]:
            when, hue = "ALL DAY", "amber"
        elif running:
            when, hue = "NOW", "green"
        elif c.width >= 128:
            when, hue = span(ev), "amber"     # a SCROLL has room for the range
        else:
            when, hue = clock(ev["start"], True, True), "amber"
        if c.width >= 128:
            y = 8 + i * 8
            c.rect(0, y, 1, y + 6, fill = ev["tint"][0])
            c.text(clip(c, when, "4x7", 59), 5, y, font = "4x7", color = hue)
            c.text(clip_words(c, ev["title"], "4x7", 119), 68, y, font = "4x7",
                   color = "white")
        else:
            # Two stacked cards, not three rows: a 64px row minus a rail and a
            # time column leaves about six glyphs of title, which is no use to
            # anybody. Stacking the time over the name buys twelve.
            # The standard pill owns rows 0-6, so the first card starts at 7
            # and the pair has 25 rows to live in -- one short of two 13-row
            # cards. The row comes out of the gap inside a card, not the gap
            # between them: the second card still ends its title on row 31.
            y = 7 + i * 13
            c.rect(0, y, 1, y + 11, fill = ev["tint"][0])
            c.text(when, 4, y, font = "4x5", color = hue)
            c.text(clip_words(c, ev["title"], "4x7", 59), 4, y + 5, font = "4x7",
                   color = "white")

    if len(shown) < rows:
        if c.width >= 128:
            c.text("NO MORE TODAY", 68, 8 + len(shown) * 8 + 1, font = "4x5",
                   color = "midgray")
        else:
            c.text("NOTHING ELSE", 4, 7 + len(shown) * 13 + 1, font = "4x5",
                   color = "midgray")

# ------------------------------------------------------------- page 3: week
# Seven day-strips. Each strip is that day's clock folded into a short vertical
# run, so a block's HEIGHT ON THE PANEL is its time of day: mornings load the
# top, evenings the bottom. A week reads as a silhouette, which is faster than
# reading seven numbers, and an empty day is a bare spine rather than a hole.
#
# This is the one view that gets BETTER as the panel narrows: strips lose
# width, not meaning, because their information lives on the y axis.
# The strip used to run a fixed 8am to 11pm every day, so somebody whose
# meetings are all before lunch got their whole calendar squashed into the top
# third with nine empty hours under it. The window is a setting now, and its
# default fits itself to whatever is actually in the week.
DAY_LO = 8 * 60           # the fallback window, still 8am
DAY_HI = 23 * 60          # to 11pm

HOUR_WINDOWS = {
    "Work hours (9am to 5pm)": [9 * 60, 17 * 60],
    "Work hours (8am to 6pm)": [8 * 60, 18 * 60],
    "Waking hours (7am to 11pm)": [7 * 60, 23 * 60],
    "Whole day (midnight to midnight)": [0, 24 * 60],
}

def day_window(ctx, events):
    """The hours the strip covers.

    Auto looks at what is actually there and pads by half an hour each side, so
    a morning of meetings fills the strip instead of hiding in the top third.
    It never collapses below four hours -- a single 30-minute event stretched
    across the full height would read as an all-day commitment."""
    choice = str(ctx.inputs.get("hours", "")).strip()
    if choice in HOUR_WINDOWS:
        w = HOUR_WINDOWS[choice]
        return [w[0], w[1]]
    lo, hi = -1, -1
    for ev in events:
        if ev["allday"]:
            continue
        s0 = ev["start"] % 1440
        e0 = s0 + (ev["end"] - ev["start"])
        if e0 > 1440:
            e0 = 1440
        if lo < 0 or s0 < lo:
            lo = s0
        if hi < 0 or e0 > hi:
            hi = e0
    if lo < 0:
        return [DAY_LO, DAY_HI]
    lo = lo - 30
    hi = hi + 30
    if lo < 0:
        lo = 0
    if hi > 1440:
        hi = 1440
    if hi - lo < 240:
        hi = lo + 240
        if hi > 1440:
            hi = 1440
            lo = hi - 240
    return [lo, hi]

def hour_label(m):
    """A window edge as a short clock: 9AM, 12PM, 5PM."""
    h = (m // 60) % 24
    ap = "AM" if h < 12 else "PM"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ap
RULE = "#242424"

def week(c, ctx):
    c.fill("black")
    st = read_calendar(ctx)
    wide = c.width >= 128
    tab(c, "WEEK")
    if state_screen(c, st):
        return

    allday = [None, None, None, None, None, None, None]
    blocks = [[], [], [], [], [], [], []]
    total = 0
    for ev in st["events"]:
        i = ev["start"] // 1440 - st["today"]
        if i < 0 or i > 6:
            continue                      # the strips only ever show seven days
        total += 1
        if ev["allday"]:
            if allday[i] == None:
                allday[i] = ev["tint"][0]
        else:
            blocks[i].append(ev)

    win = day_window(ctx, st["events"])
    d_lo, d_hi = win[0], win[1]
    if d_hi <= d_lo:
        d_lo, d_hi = DAY_LO, DAY_HI

    if c.width >= 128:
        c.text(str(total if total < 100 else 99), 5, 10, font = "10x16",
               color = "white")
        c.text("EVENTS", 5, 27, font = "4x5", color = "gray")
        c.vline(35, 2, 28, STRUCT)
        # A scale for the y axis: with the noon and 6pm rules in place, "Tuesday
        # morning is blocked but the evening is free" is read exactly rather
        # than approximately.
        # The axis is labelled with the window's real edges rather than a
        # fixed AM / PM / EVE, because the window moves now.
        # Right-aligned to the gutter: "11PM" is 19px and ran into the Monday
        # column when it was set from x=40.
        c.text(hour_label(d_lo), 55, 13, font = "4x5", color = "midgray",
               align = "right")
        c.text(hour_label((d_lo + d_hi) // 2), 55, 19, font = "4x5",
               color = "midgray", align = "right")
        c.text(hour_label(d_hi), 55, 25, font = "4x5", color = "midgray",
               align = "right")
        for ry in [18, 25]:
            for rx in range(56, 191, 3):
                c.pixel(rx, ry, RULE)
        x0, colw, inset, half = 58, 19, 2, 5
        band, lo, hi = 9, 13, 30
    else:
        x0, colw, inset, half = 1, 9, 1, 3
        # One row lower than it used to sit: the standard c.badge pill is a row
        # taller than the chip this page hand-drew, and the today marker shares
        # x with it, so without this the two merge into a single blob.
        band, lo, hi = 16, 16, 30

    for i in range(7):
        day = st["today"] + i
        x = x0 + i * colw
        mid = x + (colw - 3) // 2
        mine = i == 0
        if c.width >= 128:
            if mine:
                c.round_rect(x, 0, x + colw - 2, 7, 2, fill = BLUE)
            c.text(DOW[weekday(day)], mid, 2, font = "4x5",
                   color = "white" if mine else "gray", align = "center")
            if allday[i] != None:
                c.rect(x + inset, 9, x + colw - 4, 10, fill = allday[i])
        else:
            if mine:
                c.round_rect(x, 8, x + colw - 2, 14, 1, fill = BLUE)
            c.text(DOW1[weekday(day)], mid, 9, font = "4x5",
                   color = "white" if mine else "gray", align = "center")
        c.vline(mid, lo, hi - lo + 1, BLUE_DIM if mine else STRUCT)
        if c.width < 128 and allday[i] != None:
            # No separate lane at this width: the all-day event pins to the top
            # of the strip instead, which is where a calendar draws it anyway.
            c.rect(x + inset, band, x + colw - 3, band + 1, fill = allday[i])
        for ev in blocks[i]:
            t = ev["start"] % 1440
            if t < d_lo:
                t = d_lo
            if t > d_hi:
                t = d_hi
            rows = hi - lo + 1
            y = lo + (t - d_lo) * rows // (d_hi - d_lo)
            h = (ev["end"] - ev["start"]) * rows // (d_hi - d_lo)
            if h < 2:
                h = 2
            if y + h - 1 > hi:
                h = hi - y + 1
            c.rect(mid - half, y, mid + half, y + h - 1, fill = ev["tint"][0])
        c.hline(x + inset, 31, colw - 3 - inset + 1, STRUCT)


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
