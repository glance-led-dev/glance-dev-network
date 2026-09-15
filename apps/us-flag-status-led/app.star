# Half-Staff Watch Mini - the official position of the US flag, 64x32.
#
# Same data as the 192-wide version, but 64x32 has no room to say it all at
# once, so it is split across three pages:
#   flag  - the pixel art, the hero word, and where the reading came from
#   why   - the reason, up to three lines
#   when  - how long the position holds, as one big value
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
ACCENT = "#FFAA00"   # half-staff hero and end date

# ----------------------------------------------------------------- layout ---
# 64x32 has no neighbouring app to pad against, so every pixel is in play.

POLE_X = 2
FLAG_X = 3
FLAG_W = 24
FLAG_H = 13
PEAK_Y = 2
HALF_Y = 16
GHOST_Y = 9

DIV_X = 28
RC_X = 30          # right column of the flag page
RC_R = 63
RC_W = 34

PAD = 1            # full-width pages
FULL_X = 1
FULL_R = 62
FULL_W = 62

STARS = [
    [1, 1], [3, 1], [5, 1], [7, 1], [9, 1],
    [2, 3], [4, 3], [6, 3], [8, 3],
    [1, 5], [3, 5], [5, 5], [7, 5], [9, 5],
]

# Stepped down until the string fits. [name, cell height]
HERO_FACES = [["7x12", 12], ["6x8", 8], ["5x7", 7]]
BIG_FACES = [["10x16", 16], ["7x12", 12], ["6x8", 8], ["5x7", 7]]

# Orders run until sunset local time; the panel always keeps US Eastern.
UTC_OFFSET = -5    # EST, plus an hour during US daylight saving

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
        {"day": days_from_civil(y, 5, 15), "name": "PEACE OFFICERS", "noon": False},
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

def wrapn(c, s, maxw, font, n):
    # Greedy wrap into exactly n lines; anything past that is clipped away.
    out = []
    cur = ""
    for w in s.split(" "):
        if w == "":
            continue
        w = clip(c, w, maxw, font)
        cand = w if cur == "" else cur + " " + w
        if c.text_width(cand, font) <= maxw:
            cur = cand
        else:
            out.append(cur)
            cur = w
    if cur != "":
        out.append(cur)
    res = []
    for i in range(n):
        res.append(out[i] if i < len(out) else "")
    return res

def body_font(c, s, maxw):
    # A single long word (FIREFIGHTERS) would be clipped at 5x7 on a 64-wide
    # panel, so drop to 4x5 when any word in the string will not fit whole.
    for f in ["5x7", "4x5"]:
        fits = True
        for w in s.split(" "):
            if w != "" and c.text_width(w, f) > maxw:
                fits = False
                break
        if fits:
            return f
    return "4x5"

def fit_font(c, s, maxw, faces):
    for f in faces:
        if c.text_width(s, f[0]) <= maxw:
            return f
    return faces[len(faces) - 1]

def fmt_md(day):
    ymd = civil_from_days(day)
    return MON3[ymd[1] - 1] + " " + str(ymd[2])

def fmt_age(n):
    if n <= 0:
        return "TODAY"
    if n == 1:
        return "1D AGO"
    return str(n) + "D AGO"

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

def resolve(ctx):
    # One description of the world, shared by all three pages. The HTTP calls
    # are ttl-cached, so calling this once per page costs nothing extra.

    # ctx.now is UTC; shift it into US Eastern before any date math.
    base = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day) * 1440 + \
           ctx.now.hour * 60 + ctx.now.minute + UTC_OFFSET * 60
    if in_dst(civil_from_days(base // 1440)[0], base // 1440):
        base = base + 60
    today = base // 1440
    minute = base % 1440
    year = civil_from_days(today)[0]

    st = {
        "half": True, "hero": "HALF", "sub": "STAFF", "color": ACCENT,
        "tag": "", "ghost": False,
        "whylabel": "REASON", "why": "",
        "whenlabel": "IN EFFECT", "footlabel": "THRU", "foot": "",
        "pct": -1,
    }

    reached, order = live_order(today)

    if order != None:
        span = order["end"] - order["start"]
        st["tag"] = fmt_age(today - order["pub"])
        st["why"] = order["reason"]
        st["foot"] = fmt_md(order["end"])
        st["pct"] = (today - order["start"]) * 100 // span if span > 0 else 50
        return st

    for ev in statutory(year):
        if ev["day"] != today:
            continue
        if ev["noon"] and minute >= 720:
            break
        st["tag"] = "BY LAW"
        st["why"] = ev["name"]
        st["foot"] = "NOON" if ev["noon"] else "SUNSET"
        st["pct"] = minute * 100 // (720 if ev["noon"] else 1440)
        return st

    if not reached:
        st["half"] = False
        st["ghost"] = True
        st["hero"] = "DATA"
        st["sub"] = "DOWN"
        st["color"] = ALARM
        st["whylabel"] = "STATUS"
        st["why"] = "CANT REACH FED DATA"
        st["whenlabel"] = "NO DATA"
        st["footlabel"] = "NEXT TRY"
        st["foot"] = "15 MIN"
        return st

    nxt = next_observance(today, year)
    st["half"] = False
    st["hero"] = "FULL"
    st["sub"] = "STAFF"
    st["color"] = OK
    st["tag"] = "BY LAW"
    st["whylabel"] = "STATUS"
    st["why"] = "ALL CLEAR NO ORDERS"
    st["whenlabel"] = "UPCOMING"
    st["footlabel"] = "NEXT"
    st["foot"] = fmt_md(nxt) if nxt > 0 else "NONE SET"
    return st

# ------------------------------------------------------------------ page 1 ---

def draw_flag_art(c, x, y, ghost):
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

def flag(c, ctx):
    st = resolve(ctx)
    c.fill(BG)

    shade = GHOST if st["ghost"] else POLE_C
    c.rect(POLE_X, 1, POLE_X, 30, fill=shade)
    c.pixel(POLE_X, 0, GHOST if st["ghost"] else FINIAL)
    c.rect(POLE_X - 2, 31, POLE_X + 2, 31, fill=GHOST if st["ghost"] else BASE_C)
    if st["ghost"]:
        top = GHOST_Y
    elif st["half"]:
        top = HALF_Y
    else:
        top = PEAK_Y
    draw_flag_art(c, FLAG_X, top, st["ghost"])

    c.rect(DIV_X, 2, DIV_X, 29, fill=DIVIDE)

    c.text("US FLAG", RC_X, 0, font="4x5", color=LABEL)
    face = fit_font(c, st["hero"], RC_W, HERO_FACES)
    c.text(st["hero"], RC_X, 6 + (12 - face[1]) // 2, font=face[0], color=st["color"])
    c.text(clip(c, st["sub"], RC_W, "5x7"), RC_X, 19, font="5x7", color=WHITE)
    if st["tag"] != "":
        c.text(clip(c, st["tag"], RC_W, "4x5"), RC_X, 27,
               font="4x5", color=LABEL)

# ------------------------------------------------------------------ page 2 ---

def why(c, ctx):
    st = resolve(ctx)
    c.fill(BG)

    # The source tag lives on the flag page; this page gives the reason the
    # whole width rather than repeating it.
    c.text(st["whylabel"], FULL_X, 0, font="4x5", color=LABEL)

    font = body_font(c, st["why"], FULL_W)
    ys = [7, 15, 23] if font == "5x7" else [9, 16, 23]
    lines = wrapn(c, st["why"], FULL_W, font, 3)
    for i in range(3):
        if lines[i] != "":
            c.text(lines[i], FULL_X, ys[i], font=font,
                   color=ALARM if st["ghost"] and i == 0 else WHITE)

# ------------------------------------------------------------------ page 3 ---

def when(c, ctx):
    st = resolve(ctx)
    c.fill(BG)

    c.text(st["whenlabel"], FULL_X, 0, font="4x5", color=LABEL)
    c.text(st["footlabel"], FULL_X, 7, font="4x5", color=LABEL)

    face = fit_font(c, st["foot"], FULL_W, BIG_FACES)
    c.text(st["foot"], FULL_X, 13 + (16 - face[1]) // 2,
           font=face[0], color=st["color"])

    if st["pct"] >= 0:
        c.rect(FULL_X, 30, FULL_R, 31, fill=TRACK)
        pct = st["pct"] if st["pct"] <= 100 else 100
        c.rect(FULL_X, 30, FULL_X + (FULL_R - FULL_X) * pct // 100, 31,
               fill=st["color"])