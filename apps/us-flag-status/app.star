# Half-Staff Watch - the official position of the US flag, 192x32.
#
# Sources, in priority order:
#   1. Presidential proclamations, live from the Federal Register REST API.
#   2. The permanent half-staff days fixed by 4 U.S.C. 7, computed locally so
#      the panel stays correct with no network at all.

FEED = "https://www.federalregister.gov/api/v1/documents.json" + \
       "?conditions%5Bterm%5D=%22half-staff%22" + \
       "&conditions%5Bpresidential_document_type%5D%5B%5D=proclamation" + \
       "&order=newest&per_page=5" + \
       "&fields%5B%5D=title&fields%5B%5D=publication_date" + \
       "&fields%5B%5D=signing_date&fields%5B%5D=raw_text_url"

# ---------------------------------------------------------------- palette ---

BG = "#000000"
STRIPE = "#D81F26"
WHITE = "#FFFFFF"
CANTON = "#1F3FC0"
POLE_C = "#8A8A8A"
BASE_C = "#5A5A5A"
FINIAL = "#FFD24A"
LABEL = "#6E6E6E"
DIVIDE = "#232323"
TRACK = "#242424"
OK = "#22C55E"
ALARM = "#E02020"
GHOST = "#3E3E3E"
HALF_C = "#FFAA00"

# ----------------------------------------------------------------- layout ---
# x 10..181 is the safe area; other apps play right before and after this one.

POLE_X = 13
FLAG_X = 14
FLAG_W = 24
FLAG_H = 13
PEAK_Y = 2
HALF_Y = 16

HERO_X = 48
HERO_W = 46
COL_X = 100
COL_R = 181
COL_W = 82

STARS = [
    [1, 1], [3, 1], [5, 1], [7, 1], [9, 1],
    [2, 3], [4, 3], [6, 3], [8, 3],
    [1, 5], [3, 5], [5, 5], [7, 5], [9, 5],
]

HERO_FACES = [["10x16", 16], ["7x12", 12], ["6x8", 8]]

# US Eastern (Washington, DC), where federal flag orders are issued.
STD_OFFSET = -5

MONTHS = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY",
          "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
MON3 = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL",
        "AUG", "SEP", "OCT", "NOV", "DEC"]

TRIM = [
    "HONORING THE VICTIMS OF THE TRAGEDY IN ",
    "HONORING THE VICTIMS OF THE TRAGEDY AT ",
    "HONORING THE VICTIMS OF THE ",
    "HONORING THE VICTIMS OF ",
    "HONORING THE MEMORY OF ",
    "ANNOUNCING THE DEATH OF ",
    "HONORING ",
    "IN MEMORY OF ",
    "DEATH OF ",
]

SHORTEN = {
    "SENATOR": "SEN",
    "REPRESENTATIVE": "REP",
    "CONGRESSMAN": "REP",
    "CONGRESSWOMAN": "REP",
    "PRESIDENT": "PRES",
    "GOVERNOR": "GOV",
    "SECRETARY": "SEC",
    "DEPARTMENT": "DEPT",
    "NATIONAL": "NATL",
    "MEMORIAL": "MEML",
    "UNITED": "US",
    "STATES": "",
    "FORMER": "",
    "THE": "",
    "OF": "",
    "AND": "&",
}

# -------------------------------------------------------------- calendar ---

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
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
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]

def weekday(z):
    # 0 = Sunday. 1970-01-01 was a Thursday.
    return (z + 4) % 7

def nth_dow(y, m, dow, n):
    first = days_from_civil(y, m, 1)
    return first + (dow - weekday(first)) % 7 + 7 * (n - 1)

def last_dow(y, m, lastday, dow):
    z = days_from_civil(y, m, lastday)
    return z - (weekday(z) - dow) % 7

def in_dst(y, d):
    return d >= nth_dow(y, 3, 0, 2) and d < nth_dow(y, 11, 0, 1)

def statutory(y):
    # 4 U.S.C. 7(d) and 7(m): the days the flag flies at half-staff by law.
    return [
        {"day": days_from_civil(y, 5, 15), "name": "PEACE OFFICERS DAY", "noon": False},
        {"day": last_dow(y, 5, 31, 1), "name": "MEMORIAL DAY", "noon": True},
        {"day": days_from_civil(y, 9, 11), "name": "PATRIOT DAY", "noon": False},
        {"day": nth_dow(y, 10, 0, 1), "name": "FALLEN FIREFIGHTERS", "noon": False},
        {"day": days_from_civil(y, 12, 7), "name": "PEARL HARBOR", "noon": False},
    ]

# ----------------------------------------------------------------- string ---

def is_num(s):
    if s == "":
        return False
    for i in range(len(s)):
        if not (s[i] in "0123456789"):
            return False
    return True

def parse_iso(s):
    if s == None or len(s) < 10:
        return -1
    y = s[0:4]
    m = s[5:7]
    d = s[8:10]
    if not (is_num(y) and is_num(m) and is_num(d)):
        return -1
    return days_from_civil(int(y), int(m), int(d))

def parse_until(body, start):
    # "...at half-staff ... until sunset, September 1, 2026."
    t = body.upper()
    i = t.find("UNTIL SUNSET")
    if i < 0:
        # Deaths of former Presidents run thirty days from the day of death.
        if t.find("THIRTY DAYS") >= 0:
            return start + 30
        return -1
    seg = t[i:i + 90]
    for mi in range(12):
        j = seg.find(MONTHS[mi])
        if j < 0:
            continue
        rest = seg[j + len(MONTHS[mi]):].replace(",", " ").replace(".", " ")
        nums = []
        for p in rest.split(" "):
            if is_num(p):
                nums.append(int(p))
            if len(nums) >= 2:
                break
        if len(nums) >= 2 and nums[0] >= 1 and nums[0] <= 31 and nums[1] > 2000:
            return days_from_civil(nums[1], mi + 1, nums[0])
    return -1

def clean_reason(title):
    t = title.upper().strip()
    if len(t) > 6 and t[-6:-4] == ", " and is_num(t[-4:]):
        t = t[:-6]
    for p in TRIM:
        if t.startswith(p):
            t = t[len(p):]
            break
    out = []
    for w in t.split(" "):
        w = w.strip()
        if w == "":
            continue
        w = SHORTEN.get(w, w)
        if w != "":
            out.append(w)
    t = " ".join(out).strip()
    return t if t != "" else "FEDERAL ORDER"

def clip(c, s, maxw, font):
    if c.text_width(s, font) <= maxw:
        return s
    for i in range(len(s)):
        cand = s[:len(s) - 1 - i]
        if c.text_width(cand, font) <= maxw:
            return cand
    return ""

def wrap2(c, s, maxw, font):
    words = s.split(" ")
    l1 = ""
    used = 0
    for i in range(len(words)):
        cand = words[i] if l1 == "" else l1 + " " + words[i]
        if c.text_width(cand, font) <= maxw:
            l1 = cand
            used = i + 1
        else:
            break
    if used == 0:
        return [clip(c, words[0], maxw, font), clip(c, " ".join(words[1:]), maxw, font)]
    return [l1, clip(c, " ".join(words[used:]), maxw, font)]

def fmt_md(day):
    ymd = civil_from_days(day)
    return MON3[ymd[1] - 1] + " " + str(ymd[2])

def fmt_age(n):
    if n <= 0:
        return "TODAY"
    if n == 1:
        return "1D AGO"
    return str(n) + "D AGO"

# ---------------------------------------------------------------- drawing ---

def draw_flag(c, x, y, ghost):
    if ghost:
        c.rect(x, y, x + FLAG_W - 1, y + FLAG_H - 1, outline=GHOST)
        for r in range(2, FLAG_H - 1, 3):
            for k in range(2, FLAG_W - 1, 3):
                c.pixel(x + k, y + r, GHOST)
        return
    for r in range(FLAG_H):
        c.rect(x, y + r, x + FLAG_W - 1, y + r,
               fill=STRIPE if r % 2 == 0 else WHITE)
    c.rect(x, y, x + 10, y + 6, fill=CANTON)
    for s in STARS:
        c.pixel(x + s[0], y + s[1], WHITE)

def draw_pole(c, half, ghost):
    c.rect(POLE_X, 1, POLE_X, 30, fill=GHOST if ghost else POLE_C)
    c.pixel(POLE_X, 0, GHOST if ghost else FINIAL)
    c.rect(POLE_X - 3, 31, POLE_X + 3, 31, fill=GHOST if ghost else BASE_C)
    draw_flag(c, FLAG_X, 9 if ghost else (HALF_Y if half else PEAK_Y), ghost)

def draw_rules(c):
    c.rect(44, 3, 44, 28, fill=DIVIDE)
    c.rect(96, 3, 96, 28, fill=DIVIDE)

def draw_hero(c, word, sub, color):
    c.text("US FLAG", HERO_X, 1, font="4x5", color=LABEL)
    face = HERO_FACES[len(HERO_FACES) - 1]
    for f in HERO_FACES:
        if c.text_width(word, f[0]) <= HERO_W:
            face = f
            break
    c.text(word, HERO_X, 8 + (16 - face[1]) // 2, font=face[0], color=color)
    c.text(sub, HERO_X, 24, font="5x7", color=WHITE)

def draw_detail(c, label, tag, tagcolor, l1, l2, l1color, foot, footcolor, pct):
    c.text(label, COL_X, 1, font="4x5", color=LABEL)
    if tag != "":
        c.text(tag, COL_R, 1, font="4x5", color=tagcolor, align="right")
    c.text(l1, COL_X, 8 if l2 != "" else 12, font="5x7", color=l1color)
    if l2 != "":
        c.text(l2, COL_X, 16, font="5x7", color=WHITE)
    c.text(foot, COL_X, 24, font="4x5", color=footcolor)
    if pct >= 0:
        c.rect(COL_X, 30, COL_R, 31, fill=TRACK)
        end = COL_X + (COL_R - COL_X) * (pct if pct <= 100 else 100) // 100
        c.rect(COL_X, 30, end, 31, fill=footcolor)

# ------------------------------------------------------------------- data ---

def live_order(today):
    # Returns [found, order] so a dead feed is never mistaken for all clear.
    r = http.get(FEED, ttl_seconds = 1800)
    if r["status_code"] != 200:
        return [False, None]
    body = r["json"]
    if body == None:
        return [False, None]
    best = None
    for doc in body.get("results", [])[:3]:
        start = parse_iso(doc.get("signing_date", None))
        pub = parse_iso(doc.get("publication_date", None))
        if start < 0:
            start = pub
        if start < 0 or today - start > 60:
            continue
        url = doc.get("raw_text_url", "")
        if url == "":
            continue
        t = http.get(url, ttl_seconds = 21600)
        if t["status_code"] != 200:
            continue
        end = parse_until(t["body"], start)
        if end < start or end - start > 60:
            continue
        if today < start or today > end:
            continue
        if best == None or end > best["end"]:
            best = {
                "reason": clean_reason(doc.get("title", "")),
                "start": start,
                "end": end,
                "pub": pub if pub >= 0 else start,
            }
    return [True, best]

def next_observance(today, year):
    best = -1
    for y in [year, year + 1]:
        for ev in statutory(y):
            if ev["day"] > today and (best < 0 or ev["day"] < best):
                best = ev["day"]
    return best

# ------------------------------------------------------------------- page ---

def status(c, ctx):
    c.fill(BG)

    # ctx.now is UTC; shift it into US Eastern before any date math.
    base = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day) * 1440 + \
           ctx.now.hour * 60 + ctx.now.minute + STD_OFFSET * 60
    guess = civil_from_days(base // 1440)
    if in_dst(guess[0], base // 1440):
        base = base + 60
    today = base // 1440
    minute = base % 1440
    year = civil_from_days(today)[0]

    draw_rules(c)

    reached, order = live_order(today)

    # ---- half-staff by proclamation --------------------------------------
    if order != None:
        span = order["end"] - order["start"]
        pct = (today - order["start"]) * 100 // span if span > 0 else 50
        lines = wrap2(c, order["reason"], COL_W, "5x7")
        draw_pole(c, True, False)
        draw_hero(c, "HALF", "STAFF", HALF_C)
        draw_detail(c, "REASON", fmt_age(today - order["pub"]), LABEL,
                    lines[0], lines[1], WHITE,
                    "THRU " + fmt_md(order["end"]), HALF_C, pct)
        return

    # ---- half-staff by statute -------------------------------------------
    for ev in statutory(year):
        if ev["day"] != today:
            continue
        if ev["noon"] and minute >= 720:
            break
        limit = 720 if ev["noon"] else 1440
        lines = wrap2(c, ev["name"], COL_W, "5x7")
        draw_pole(c, True, False)
        draw_hero(c, "HALF", "STAFF", HALF_C)
        draw_detail(c, "REASON", "BY LAW", LABEL, lines[0], lines[1], WHITE,
                    "THRU NOON" if ev["noon"] else "THRU SUNSET", HALF_C,
                    minute * 100 // limit)
        return

    # ---- feed unreachable, and no statutory day to fall back on ----------
    if not reached:
        draw_pole(c, False, True)
        draw_hero(c, "DATA", "DOWN", ALARM)
        draw_detail(c, "STATUS", "", LABEL, "FEED OFFLINE", "RETRY 15 MIN",
                    ALARM, "FEDERAL REGISTER", LABEL, -1)
        return

    # ---- all clear --------------------------------------------------------
    nxt = next_observance(today, year)
    draw_pole(c, False, False)
    draw_hero(c, "FULL", "STAFF", OK)
    draw_detail(c, "STATUS", "BY LAW", LABEL, "ALL CLEAR", "NO ORDERS", WHITE,
                "NEXT " + fmt_md(nxt) if nxt > 0 else "NONE SCHEDULED", OK, -1)