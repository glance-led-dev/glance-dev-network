# National Day — 192x32 SCROLL
#
# The repo you pointed at (sattelbergerp/national-day-list) is a 2017 Ruby gem
# that scrapes nationaldaycalendar.com month pages. It is not a JSON API, and
# that site now sits behind a Cloudflare challenge, so GDN http.get usually
# cannot read it. This app still tries that source first (same URLs the gem
# used). If the body is a challenge page or empty, it falls back to Checkiday's
# public RSS — the same kind of "what day is it" list (Blueberry Popsicle Day,
# V-J Day, World Coconut Day, …) in a fetchable feed.

MONTHS = [
    "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
    "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER",
]
MON3 = [
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC",
]
SKIP = [
    "CHECKIDAY.COM", "CHECKIDAY", "BIRTHDAYS AND EVENTS",
    "WHAT DAY IS IT", "THE NATIONAL DAY NIGHTLY",
    "FIND WHAT YOU", "EXPLORE MORE", "CONTACT", "BUSINESS",
    "COMMUNITY", "PRESS", "CELEBRATION NATION", "NATIONAL DAY SPOTLIGHT",
    "ONGOING NATIONAL", "GLOBAL OBSERVANCES",
]
STD_OFF = {
    "US EASTERN": -5, "US CENTRAL": -6, "US MOUNTAIN": -7,
    "US PACIFIC": -8, "US ALASKA": -9, "US HAWAII": -10, "UTC": 0,
}
HAS_DST = {
    "US EASTERN": True, "US CENTRAL": True, "US MOUNTAIN": True,
    "US PACIFIC": True, "US ALASKA": True, "US HAWAII": False, "UTC": False,
}
UA = {"User-Agent": "glance-dev-network (glance-led.com)"}
TTL = 21600

BG = "#08060E"
MUTED = "#8A86A8"
HERO = "#FFFFFF"
CAL_RED = "#D42A2A"
CAL_WHITE = "#FFFFFF"

ENTITIES = [
    ["&amp;", "&"], ["&apos;", "'"], ["&#39;", "'"], ["&#039;", "'"],
    ["&#x27;", "'"], ["&quot;", '"'], ["&lt;", "<"], ["&gt;", ">"],
    ["&nbsp;", " "],
]


def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil_from_days(z):
    z = z + 719468
    era = (z // 146097) if z >= 0 else ((z - 146096) // 146097)
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = (mp + 3) if mp < 10 else (mp - 9)
    if m <= 2:
        y = y + 1
    return (y, m, d)


def first_sunday(y, m):
    first = days_from_civil(y, m, 1)
    wd = (first + 3) % 7
    until = (6 - wd) % 7
    return 1 + until


def us_dst(y, m, d):
    start = first_sunday(y, 3) + 7
    end = first_sunday(y, 11)
    n = m * 32 + d
    return n >= 3 * 32 + start and n < 11 * 32 + end


def local_when(ctx, zone):
    z = str(zone).upper().strip()
    if z == "":
        z = "US CENTRAL"
    std = STD_OFF.get(z, -6)
    unix = int(ctx.now.unix) + std * 3600
    days = unix // 86400
    y, m, d = civil_from_days(days)
    if HAS_DST.get(z, False) and us_dst(y, m, d):
        unix = unix + 3600
        days = unix // 86400
        y, m, d = civil_from_days(days)
    rem = unix % 86400
    if rem < 0:
        rem = rem + 86400
    hour = rem // 3600
    minute = (rem % 3600) // 60
    return {"y": y, "m": m, "d": d, "hour": hour, "minute": minute}


def decode(s):
    out = str(s)
    for e in ENTITIES:
        out = out.replace(e[0], e[1])
    return out


def tidy(s):
    t = decode(s).upper().strip()
    t = t.replace("\n", " ").replace("\t", " ")
    for i in range(6):
        t = t.replace("  ", " ")
    if t.startswith("TODAY IS "):
        t = t[9:]
    if t.endswith("!"):
        t = t[:len(t) - 1].strip()
    return t


def keep(name):
    if name == "" or len(name) < 4:
        return False
    for skip in SKIP:
        if name == skip or name.find(skip) >= 0:
            return False
    if name.find("ENABLE JAVASCRIPT") >= 0:
        return False
    if name.startswith("WORLD ") or name.startswith("INTERNATIONAL "):
        return False
    if name.find("DAY") < 0 and name.find("WEEK") < 0 and name.find("MONTH") < 0:
        return False
    return True


def uniq(names):
    out = []
    seen = {}
    for n in names:
        if keep(n) and seen.get(n) != True:
            seen[n] = True
            out.append(n)
    return out


def find_ci(s, needle):
    return s.upper().find(needle.upper())


def today_chunk(html):
    # The live page puts today's observances under an h2, then birthdays / weeks.
    a = find_ci(html, "NATIONAL DAYS")
    if a < 0:
        return ""
    rest = html[a:]
    end_at = len(rest)
    for mark in ["BIRTHDAYS AND EVENTS", "ONGOING NATIONAL", "GLOBAL OBSERVANCES"]:
        b = find_ci(rest, mark)
        if b >= 0 and b < end_at:
            end_at = b
    return rest[:end_at]


def h3_titles(html):
    out = []
    rest = html
    for n in range(40):
        start = rest.find("<h3")
        if start < 0:
            break
        rest = rest[start:]
        gt = rest.find(">")
        close = rest.find("</h3")
        if gt < 0 or close < 0 or close < gt:
            rest = rest[3:]
            continue
        raw = rest[gt + 1:close]
        raw = raw.replace("<![CDATA[", "").replace("]]>", "")
        name = tidy(strip_tags(raw))
        if keep(name):
            out.append(name)
        rest = rest[close + 4:]
    return out


def ndc_is_today(html, when):
    # The what-day-is-it page has been known to serve a stale date. Only
    # trust it when the <title> matches the viewer's local calendar day.
    a = find_ci(html, "<title>")
    b = find_ci(html, "</title>")
    if a < 0 or b < 0 or b <= a:
        return False
    title = tidy(strip_tags(html[a + 7:b]))
    mon = MONTHS[when["m"] - 1]
    day = str(when["d"])
    year = str(when["y"])
    return title.find(mon) >= 0 and title.find(day) >= 0 and title.find(year) >= 0


def strip_tags(s):
    out = ""
    skip = False
    text = str(s)
    for i in range(len(text)):
        ch = text[i]
        if ch == "<":
            skip = True
        elif ch == ">":
            skip = False
        elif skip == False:
            out = out + ch
    return out


def rss_titles(body):
    out = []
    rest = body
    for i in range(40):
        a = rest.find("<item")
        if a < 0:
            break
        rest = rest[a + 5:]
        t = rest.find("<title")
        if t < 0:
            break
        seg = rest[t:]
        gt = seg.find(">")
        end = seg.find("</title>")
        if gt < 0 or end < 0:
            break
        raw = seg[gt + 1:end]
        raw = raw.replace("<![CDATA[", "").replace("]]>", "")
        name = tidy(raw)
        if keep(name):
            out.append(name)
    return out


def blocked(body):
    b = str(body)
    return b.find("Just a moment") >= 0 or b.find("cf-browser-verification") >= 0


def fetch_days(when):
    # Same site the 2017 gem scraped. GDN cannot follow redirects, so no www.
    r = http.get("https://nationaldaycalendar.com/what-day-is-it/",
                 headers = UA, ttl_seconds = TTL)
    if r["status_code"] == 200 and blocked(r["body"]) == False:
        body = str(r["body"])
        if ndc_is_today(body, when):
            names = uniq(h3_titles(today_chunk(body)))
            if len(names) > 0:
                return names

    # Same kind of list, actually dated "today". Direct API URL avoids a 301.
    r2 = http.get("https://api.checkiday.com/rss", headers = UA, ttl_seconds = TTL)
    if r2["status_code"] == 200:
        names = uniq(rss_titles(str(r2["body"])))
        if len(names) > 0:
            return names
    return []


def fit_clip(c, text, fonts, maxw):
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


def wrap(c, text, font, maxw):
    words = str(text).split(" ")
    lines = []
    cur = ""
    for w in words:
        if w == "":
            continue
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    return lines


def nodata(c, title, sub):
    c.fill(BG)
    c.rect(10, 2, 11, 29, fill = CAL_RED)
    t = fit_clip(c, title, ["7x12", "6x8", "5x7", "4x5"], 160)
    c.text(t[1], 101, 6, font = t[0], color = CAL_RED, align = "center")
    d = fit_clip(c, sub, ["5x7", "4x5"], 160)
    c.text(d[1], 101, 20, font = d[0], color = MUTED, align = "center")


def draw_calendar(c, when):
    # Tear-off calendar stamp: red header, white page.
    c.round_rect(10, 2, 41, 29, 2, fill = CAL_WHITE)
    c.rect(10, 2, 41, 10, fill = CAL_RED)
    c.pixel(16, 2, BG)
    c.pixel(34, 2, BG)
    c.rect(15, 1, 17, 4, fill = CAL_WHITE)
    c.rect(33, 1, 35, 4, fill = CAL_WHITE)
    mon = MON3[when["m"] - 1]
    c.text(mon, 26, 3, font = "4x5", color = CAL_WHITE, align = "center")
    ds = str(when["d"])
    df = "10x16"
    if c.text_width(ds, df) > 26:
        df = "7x12"
    c.text(ds, 26, 12, font = df, color = "#000000", align = "center")


def featured_index(when, n):
    if n <= 0:
        return 0
    slot = when["hour"] * 4 + when["minute"] // 15
    return slot % n


def load_state(ctx):
    zone = ctx.inputs.get("timezone", "US CENTRAL")
    when = local_when(ctx, zone)
    days = fetch_days(when)
    return {"when": when, "days": days}


def today(c, ctx):
    st = load_state(ctx)
    c.fill(BG)
    if len(st["days"]) == 0:
        nodata(c, "DAYS UNAVAILABLE", "TRY AGAIN LATER")
        return

    days = st["days"]
    i = featured_index(st["when"], len(days))
    name = days[i]
    draw_calendar(c, st["when"])

    left = 48
    right = 181
    maxw = right - left
    cx = left

    kicker = "TODAY IS"
    c.text(kicker, cx, 3, font = "4x5", color = MUTED, align = "left")
    count = str(i + 1) + "/" + str(len(days))
    c.text(count, right, 3, font = "4x5", color = CAL_RED, align = "right")

    lines6 = wrap(c, name, "6x8", maxw)
    if len(lines6) <= 2:
        y = 11
        for ln in lines6:
            c.text(ln, cx, y, font = "6x8", color = HERO, align = "left")
            y = y + 9
        return

    lines5 = wrap(c, name, "5x7", maxw)
    if len(lines5) > 3:
        lines5 = lines5[:3]
        last = lines5[2]
        for k in range(len(last), 0, -1):
            if c.text_width(last[:k], "5x7") <= maxw:
                last = last[:k]
                break
        lines5[2] = last
    y = 11
    for ln in lines5:
        c.text(ln, cx, y, font = "5x7", color = HERO, align = "left")
        y = y + 7
