# Upcoming Birthdays — first name, MM/DD, and the age they are turning.
# Data comes from the entries input only. Nothing is hardcoded about a
# real household, and this app does not fetch a calendar.

# Fake names used only when the list is left blank (the DEMO screens).
DEMO_TEXT = "Alex,12/03,1996; Sam,01/15,2018; Jordan,03/22,1981; Riley,04/01,2005; Casey,11/27,1990"

# Minutes east of UTC, plus a DST rule id (0 = none, 1 = US).
TZ = {
    "UTC": [0, 0],
    "Pacific/Honolulu": [-600, 0],
    "America/Anchorage": [-540, 1],
    "America/Los_Angeles": [-480, 1],
    "America/Phoenix": [-420, 0],
    "America/Denver": [-420, 1],
    "America/Chicago": [-360, 1],
    "America/New_York": [-300, 1],
}

# Cake body and candle flames, drawn in two colors.
CAKE = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
]

FLAMES = [
    [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

FONTH = {
    "16x20": 20,
    "10x16": 16,
    "10x15": 15,
    "6x8": 8,
    "5x7": 7,
    "4x7": 7,
    "4x5": 5,
    "picopixel": 5,
}

# ------------------------------------------------------------ date math
# Same civil-date helpers the official GDN Google Calendar app uses.

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
    return (z + 3) % 7

def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

def nth_sunday(y, m, n):
    if n == -1:
        last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
        if m == 2 and is_leap(y):
            last = 29
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    first = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return first + 7 * (n - 1)

def _utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(zone, t):
    # Minutes east of UTC for `zone` at UTC minute `t`. US DST (rule 1)
    # follows the official GDN Google Calendar app: 2nd Sunday in March
    # to the 1st Sunday in November.
    z = TZ[zone] if zone in TZ else TZ["UTC"]
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    start = _utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
    end = _utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
    return std + 60 if t >= start and t < end else std

def zone_offset(ctx):
    return zone_offset_at(str(ctx.inputs.get("timezone", "America/New_York")).strip(),
                          ctx.now.unix // 60)

def local_ymd(ctx):
    off = zone_offset(ctx)
    return civil_from_days((ctx.now.unix + off * 60) // 86400)

# ------------------------------------------------------------ parsing

def digits(s):
    out = ""
    for ch in s.elems():
        if ch >= "0" and ch <= "9":
            out += ch
    return out

def num(s, fallback = -1):
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    d = digits(t)
    if d == "" or len(d) != len(t):
        return fallback
    v = int(d)
    return -v if neg else v

def pad2(n):
    s = str(n)
    if len(s) < 2:
        return "0" + s
    return s

def mmdd(m, d):
    return pad2(m) + "/" + pad2(d)

def split_lines(raw):
    text = str(raw)
    text = text.replace("\r", "\n")
    text = text.replace(";", "\n")
    text = text.replace("|", "\n")
    out = []
    for part in text.split("\n"):
        p = part.strip()
        if p != "":
            out.append(p)
    return out

def parse_md(s):
    t = str(s).strip()
    if t == "":
        return None
    # YYYY-MM-DD (no colons, safe in a text input).
    if len(t) >= 10 and t[4] == "-" and t[7] == "-":
        y = num(t[0:4])
        m = num(t[5:7])
        d = num(t[8:10])
        if y >= 1900 and m >= 1 and m <= 12 and d >= 1 and d <= 31:
            return [m, d, y]
        return None
    sep = "/"
    if t.find("/") < 0:
        sep = "-"
    bits = t.split(sep)
    if len(bits) != 2:
        return None
    m = num(bits[0])
    d = num(bits[1])
    if m >= 1 and m <= 12 and d >= 1 and d <= 31:
        return [m, d, -1]
    return None

def parse_line(line):
    raw = line.strip()
    if raw == "":
        return None
    parts = raw.split(",")
    if len(parts) < 2:
        parts = []
        for bit in raw.split(" "):
            b = bit.strip()
            if b != "":
                parts.append(b)
    cleaned = []
    for p in parts:
        t = p.strip()
        if t != "":
            cleaned.append(t)
    if len(cleaned) < 2:
        return None
    name = cleaned[0]
    date_s = cleaned[1]
    year_s = cleaned[2] if len(cleaned) >= 3 else ""
    md = parse_md(date_s)
    if md == None:
        return None
    m, d, embedded = md[0], md[1], md[2]
    year = embedded if embedded >= 1900 else num(year_s)
    if year < 1900 or year > 2100:
        return None
    if name == "":
        return None
    return {"name": name, "month": m, "day": d, "year": year}

def clamp_day(y, m, d):
    if m == 2 and d >= 29:
        return 29 if is_leap(y) else 28
    return d

def upcoming(person, ty, tm, td):
    m = person["month"]
    d0 = person["day"]
    d_this = clamp_day(ty, m, d0)
    if m > tm or (m == tm and d_this >= td):
        ny, nd = ty, d_this
    else:
        ny = ty + 1
        nd = clamp_day(ny, m, d0)
    age = ny - person["year"]
    days = days_from_civil(ny, m, nd) - days_from_civil(ty, tm, td)
    return {
        "name": person["name"],
        "month": m,
        "day": d0,
        "year": person["year"],
        "age": age,
        "days": days,
        "next_year": ny,
        "next_day": nd,
    }

def load_people(ctx):
    raw = str(ctx.inputs.get("entries", "")).strip()
    demo = raw == ""
    text = DEMO_TEXT if demo else raw
    people = []
    bad = 0
    for line in split_lines(text):
        p = parse_line(line)
        if p == None:
            bad += 1
        else:
            people.append(p)
    typo = local_ymd(ctx)
    ty, tm, td = typo[0], typo[1], typo[2]
    upcoming_list = []
    for p in people:
        upcoming_list.append(upcoming(p, ty, tm, td))
    keyed = []
    for u in upcoming_list:
        keyed.append([u["days"], u["month"], u["day"], u["name"], u])
    keyed = sorted(keyed)
    ordered = []
    for row in keyed:
        ordered.append(row[4])
    row_n = num(ctx.inputs.get("rows", "4"), 4)
    if row_n < 3:
        row_n = 3
    if row_n > 5:
        row_n = 5
    return {
        "demo": demo,
        "bad": bad,
        "people": ordered,
        "rows": row_n,
        "today": typo,
    }

# ------------------------------------------------------------ drawing helpers

def clip(c, text, font, maxw):
    s = str(text)
    if maxw <= 0:
        return ""
    if c.text_width(s, font = font) <= maxw:
        return s
    dots = ".."
    dw = c.text_width(dots, font = font)
    if dw > maxw:
        return ""
    out = ""
    for ch in s.elems():
        trial = out + ch
        if c.text_width(trial, font = font) + dw > maxw:
            break
        out = trial
    return out + dots

def pick_font(c, text, fonts, maxw):
    chosen = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(str(text), font = f) <= maxw:
            return f
    return chosen

def pad_x(c):
    return 8 if c.width >= 128 else 2

def draw_cake(c, x, y, cake_color = "pink", flame_color = "amber"):
    c.bitmap(FLAMES, x, y, color = flame_color)
    c.bitmap(CAKE, x, y, color = cake_color)

def countdown_long(days):
    if days <= 0:
        return "TODAY!"
    if days == 1:
        return "IN 1 DAY"
    return "IN %d DAYS" % days

def countdown_short(days):
    if days <= 0:
        return "TODAY!"
    return "%dD" % days

def age_label(age):
    if age < 0 or age > 130:
        return ""
    return "TURNS %d" % age

def when_color(days):
    if days <= 0:
        return "green"
    if days <= 7:
        return "amber"
    return "white"

def state_screen(c, title, sub, color = "amber"):
    c.fill("black")
    x = pad_x(c)
    draw_cake(c, x, 10)
    tx = x + 14
    maxw = c.width - tx - pad_x(c)
    hf = pick_font(c, title, ["6x8", "5x7", "4x5"], maxw)
    c.text(title, tx, 6, font = hf, color = color)
    sf = pick_font(c, sub, ["4x5", "picopixel"], maxw)
    c.text(sub, tx, 18, font = sf, color = "gray")

def empty_or_error(c, st):
    if st["demo"] == False and len(st["people"]) == 0:
        state_screen(c, "CHECK LIST", "NAME, MM/DD, YEAR")
        return True
    return False

# ------------------------------------------------------------ pages

def badge_width(c, text, font="4x5", pad=2):
    if pad < 2:
        pad = 2
    return c.text_width(str(text), font=font) + 2 * pad

def next(c, ctx):
    st = load_people(ctx)
    if empty_or_error(c, st):
        return
    c.fill("black")
    wide = c.width >= 128
    x = pad_x(c)
    right = c.width - pad_x(c)
    p = st["people"][0]
    name = p["name"].upper()
    when = countdown_long(p["days"])
    accent = when_color(p["days"])
    date_s = mmdd(p["month"], p["day"])
    turns = age_label(p["age"])
    is_today = p["days"] <= 0

    c.rect(0, 0, 1, c.height - 1, fill="pink")
    cake_x = x
    draw_cake(c, cake_x, 11 if wide else 12)
    col = cake_x + 14

    # DEMO sits above the cake so it never steals room from the hero name.
    if st["demo"]:
        c.badge("DEMO", col, 1, color="black", bg="amber", font="4x5", pad=2)

    name_y = 8 if st["demo"] else (3 if wide else 2)
    name_max = right - col

    if is_today:
        bw = badge_width(c, "TODAY!", "4x5", 2)
        bx = right - bw
        if bx < col:
            bx = col
        c.badge("TODAY!", bx, 1 if st["demo"] else 2, color="black", bg="green", font="4x5", pad=2)
        name_max = bx - 3 - col
    else:
        wf = "5x7" if wide else "4x5"
        ww = c.text_width(when, font=wf)
        c.text(when, right, 3 if wide else 2, font=wf, color=accent, align="right")
        name_max = right - ww - 4 - col
    if name_max < 12:
        name_max = 12

    if wide:
        nf = pick_font(c, name, ["16x20", "10x16", "6x8", "5x7"], name_max)
    else:
        nf = pick_font(c, name, ["10x16", "6x8", "5x7", "4x5"], name_max)
    c.text(clip(c, name, nf, name_max), col, name_y, font=nf, color="white")

    meta = date_s
    if turns != "":
        meta = date_s + "  " + turns if wide else date_s + " " + turns
    mf = "5x7" if wide else "4x5"
    meta_y = name_y + FONTH[nf] + 1
    if meta_y + FONTH[mf] > c.height:
        meta_y = c.height - FONTH[mf]
    c.text(clip(c, meta, mf, right - col), col, meta_y, font=mf, color="pink")

def soon(c, ctx):
    st = load_people(ctx)
    if empty_or_error(c, st):
        return
    c.fill("black")
    wide = c.width >= 128
    x = pad_x(c)
    right = c.width - pad_x(c)
    people = st["people"]

    # 4 rows is the most that keeps a 1 px gap under a header on a 32 px panel.
    n = st["rows"]
    if wide == False and n > 3:
        n = 3
    if n > 4:
        n = 4
    if n > len(people):
        n = len(people)

    c.rect(0, 0, 1, c.height - 1, fill="pink")
    title = "BIRTHDAYS"
    title_x = x
    if st["demo"]:
        dw = c.badge("DEMO", x, 0, color="black", bg="amber", font="4x5", pad=2)
        title_x = x + dw + 3
    c.text(title, title_x, 1, font="4x5", color="pink")

    nxt = people[0]
    if nxt["days"] <= 0:
        bw = badge_width(c, "TODAY!", "4x5", 2)
        c.badge("TODAY!", right - bw, 0, color="black", bg="green", font="4x5", pad=2)
    else:
        head_r = countdown_long(nxt["days"]) if wide else countdown_short(nxt["days"])
        c.text(head_r, right, 1, font="4x5", color=when_color(nxt["days"]), align="right")
    c.hline(x, 7, right - x, "darkgray")

    show = people[0:n]
    lh = 24 // n
    font = "5x7" if wide and n <= 3 else "4x5"
    if FONTH[font] + 1 > lh:
        font = "4x5"
    gap = 3 if wide else 2
    when_w = c.text_width("TODAY!", font=font)
    age_w = c.text_width("999", font=font)
    date_w = c.text_width("00/00", font=font)
    when_x = right
    age_x = right - when_w - gap
    date_x = age_x - age_w - gap
    name_right = date_x - date_w - gap
    name_max = name_right - x
    if name_max < 8:
        name_max = 8

    y0 = 8
    for i in range(len(show)):
        p = show[i]
        y = y0 + i * lh
        ty = y + max(0, (lh - FONTH[font]) // 2)
        if ty + FONTH[font] > c.height:
            ty = c.height - FONTH[font]
        name = p["name"].upper()
        date_s = mmdd(p["month"], p["day"])
        is_today = p["days"] <= 0
        name_color = "green" if is_today else "white"
        meta_color = "green" if is_today else "gray"
        when_s = "TODAY!" if is_today else countdown_short(p["days"])
        age_s = str(p["age"]) if p["age"] >= 0 and p["age"] <= 130 else ""

        c.text(when_s, when_x, ty, font=font, color="green" if is_today else when_color(p["days"]), align="right")
        if age_s != "" and age_x > x:
            c.text(age_s, age_x, ty, font=font, color=meta_color, align="right")
        if date_x > x:
            c.text(date_s, date_x, ty, font=font, color=meta_color, align="right")
        c.text(clip(c, name, font, name_max), x, ty, font=font, color=name_color)

    extra = len(people) - n
    if extra > 0:
        more = "+%d" % extra
        # Park the overflow count on the header, after the title, so it
        # never lands on a row.
        mw = c.text_width(more, font="4x5")
        mx = title_x + c.text_width(title, font="4x5") + 3
        header_right_limit = right - c.text_width("IN 000 DAYS", font="4x5") - 2
        if mx + mw <= header_right_limit:
            c.text(more, mx, 1, font="4x5", color="gray")
