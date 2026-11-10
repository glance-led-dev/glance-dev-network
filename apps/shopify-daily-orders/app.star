# Shopify Orders Today (SCROLL) - order COUNTS only, no money anywhere.
#
# DESIGN. Hero: today's order count (running total since local midnight) under
# a pink ORDERS label. Beside it, the orders placed so far in the current
# local clock hour (+N THIS HR, resets at :00). On the right, 7 daily bars for
# the rolling last 7 days (today included). Past days are pink, today's
# partial bar is white, and the 7-day high gets an amber cap with
# "7D HIGH N" above. Bottom right: the clock time of the next refresh
# ("NEXT 3:45P").
#
# WHY NOT A TICKING COUNTDOWN. GDN frames are still images. The panel shows
# each frame until the next refresh, and an app with free-text/api-key inputs
# may refresh no faster than every 300 s, so an MM:SS readout would freeze.
# The next-update clock time stays true for the whole time the frame is up.
#
# DATA. GET-only Shopify Admin REST:
#   /admin/api/2026-10/orders.json?status=any&fields=id,created_at,cancelled_at,test
# No prices and no customer fields are requested. Paging walks since_id
# (250/page, at most 8 GETs = 2000 orders per 7 days). created_at_min is pinned
# to the window's first local midnight so full pages stay cached. ttl 240 s is
# under the 300 s refresh, so every render sees new orders without extra calls.
# Needs only read_orders. Never logs or draws the token.

API_VERSION = "2026-10"
PAGE_SIZE = 250
MAX_PAGES = 8
TTL = 240
REFRESH = 300            # keep in sync with manifest.yaml refresh
NDAYS = 7

PINK = "#FF4FA3"         # brand pink: counts/bars only, never negatives
LABEL = "#8A8F99"
TRACK = "#2A2D33"
UP = "#39E36B"
HIGH = "amber"
ERR = "red"

ZONES = {
    "America/New_York": (-5, True),
    "America/Chicago": (-6, True),
    "America/Denver": (-7, True),
    "America/Phoenix": (-7, False),
    "America/Los_Angeles": (-8, True),
    "UTC": (0, False),
}

# ---------------------------------------------------------------- dates

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return (y + 1 if m <= 2 else y, m, d)

def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    dow = (first + 4) % 7
    return first + (7 - dow) % 7 + 7 * (n - 1)

def utc_offset(zone, unix):
    std, dst = ZONES.get(zone, ZONES["America/Chicago"])
    if not dst:
        return std * 3600
    y = civil_from_days((unix + std * 3600) // 86400)[0]
    start = nth_sunday(y, 3, 2) * 86400 + 2 * 3600 - std * 3600
    end = nth_sunday(y, 11, 1) * 86400 + 2 * 3600 - (std + 1) * 3600
    if unix >= start and unix < end:
        return (std + 1) * 3600
    return std * 3600

def local_secs(zone, unix):
    return unix + utc_offset(zone, unix)

def iso_utc(unix):
    y, m, d = civil_from_days(unix // 86400)
    s = unix % 86400
    return (fmt.pad(y, 4) + "-" + fmt.pad(m) + "-" + fmt.pad(d) + "T" +
            fmt.pad(s // 3600) + ":" + fmt.pad((s % 3600) // 60) + ":" + fmt.pad(s % 60) + "Z")

def parse_ts(s):
    if len(s) < 19:
        return None
    day = days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10]))
    secs = int(s[11:13]) * 3600 + int(s[14:16]) * 60 + int(s[17:19])
    rest = s[19:]
    if rest.startswith("."):
        k = 1
        for i in range(1, len(rest)):
            if rest[i] in "0123456789":
                k = i + 1
            else:
                break
        rest = rest[k:]
    off = 0
    if len(rest) >= 6 and rest[0] in "+-":
        off = int(rest[1:3]) * 3600 + int(rest[4:6]) * 60
        if rest[0] == "-":
            off = -off
    return day * 86400 + secs - off

def clock12(local):
    s = local % 86400
    h = s // 3600
    m = (s % 3600) // 60
    ap = "A" if h < 12 else "P"
    h = h % 12
    if h == 0:
        h = 12
    return str(h) + ":" + fmt.pad(m) + ap

# ---------------------------------------------------------------- inputs

def clean_shop(raw):
    s = raw.strip().lower()
    for p in ["https//", "http//", "https", "http", "//", "/"]:
        if s.startswith(p):
            s = s[len(p):]
    s = s.split("/")[0]
    if s.endswith(".myshopify.com"):
        s = s[:-len(".myshopify.com")]
    ok = len(s) > 0
    for ch in s.elems():
        if ch not in "abcdefghijklmnopqrstuvwxyz0123456789-":
            ok = False
    return s if ok else ""

# ---------------------------------------------------------------- fetch

def error_lines(code):
    if code == 0:
        return ("SHOPIFY OFFLINE", "RETRYING SOON")
    if code == 401:
        return ("TOKEN REJECTED", "UPDATE IN GLANCE APP")
    if code == 403:
        return ("NO ORDER ACCESS", "NEEDS READ ORDERS")
    if code == 404 or (code >= 300 and code < 400):
        return ("STORE NOT FOUND", "CHECK STORE HANDLE")
    if code == 429:
        return ("SHOPIFY BUSY", "RETRYING SOON")
    return ("SHOPIFY ERROR " + str(code), "TRY AGAIN LATER")

def fetch_counts(shop, key, zone, now, skip_cancelled):
    lnow = local_secs(zone, now)
    today = lnow // 86400
    hour_start = lnow - lnow % 3600          # local seconds
    first = today - (NDAYS - 1)
    guess = first * 86400
    start = guess - utc_offset(zone, guess)
    counts = [0] * NDAYS
    this_hour = 0
    url = "https://" + shop + ".myshopify.com/admin/api/" + API_VERSION + "/orders.json"
    headers = {"X-Shopify-Access-Token": key, "Accept": "application/json"}
    since = "1"
    partial = True
    for page in range(MAX_PAGES):
        resp = http.get(url, headers = headers, params = {
            "status": "any",
            "limit": str(PAGE_SIZE),
            "since_id": since,
            "created_at_min": iso_utc(start),
            "fields": "id,created_at,cancelled_at,test",
        }, ttl_seconds = TTL)
        code = resp["status_code"]
        if code != 200 or resp["json"] == None:
            return {"ok": False, "err": error_lines(code)}
        orders = resp["json"].get("orders", None)
        if orders == None:
            return {"ok": False, "err": ("SHOPIFY SENT", "NO ORDER LIST")}
        for o in orders:
            since = str(o.get("id", since))
            if o.get("test", False):
                continue
            if skip_cancelled and o.get("cancelled_at", None) != None:
                continue
            ts = parse_ts(str(o.get("created_at", "")))
            if ts == None:
                continue
            lt = local_secs(zone, ts)
            i = lt // 86400 - first
            if i >= 0 and i < NDAYS:
                counts[i] += 1
                if lt >= hour_start and lt < hour_start + 3600:
                    this_hour += 1
        if len(orders) < PAGE_SIZE:
            partial = False
            break
    return {"ok": True, "counts": counts, "hour": this_hour, "partial": partial}

def demo_counts():
    return {"ok": True, "counts": [21, 34, 29, 40, 26, 37, 18], "hour": 2, "partial": False}

# ---------------------------------------------------------------- draw

def draw_error(c, lines):
    c.text("ORDERS", 10, 4, font = "5x7", color = PINK)
    c.text(lines[0], 10, 14, font = "6x8", color = ERR)
    c.text(lines[1], 10, 24, font = "4x5", color = LABEL)

def draw_orders(c, data, next_txt, demo):
    w = c.width
    counts = data["counts"]
    today_n = counts[-1]
    hour_n = data["hour"]

    # ---- hero: today's running total
    x0 = 10
    c.text("ORDERS", x0, 1, font = "5x7", color = PINK)
    c.text("TODAY", x0 + c.text_width("ORDERS", "5x7") + 3, 3, font = "4x5", color = LABEL)
    hero = str(today_n)
    hero_font = "16x20" if c.text_width(hero, "16x20") <= 52 else "10x16"
    c.text(hero, x0, 10, font = hero_font, color = "white")
    hero_w = max(c.text_width(hero, hero_font), c.text_width("ORDERS", "5x7") + 3 + c.text_width("TODAY", "4x5"))

    # ---- this hour
    hx = x0 + hero_w + 7
    inc = "+" + str(hour_n)
    c.text(inc, hx, 12, font = "9x12_bold", color = (UP if hour_n > 0 else LABEL))
    c.text("THIS HR", hx, 26, font = "4x5", color = LABEL)
    mid_w = max(c.text_width(inc, "9x12_bold"), c.text_width("THIS HR", "4x5"))

    # ---- 7-day bars + high
    bx1 = w - 10
    bx0 = hx + mid_w + 8
    hi = 0
    hi_i = 0
    for i in range(NDAYS):
        if counts[i] >= hi:      # ties: latest day wins
            hi = counts[i]
            hi_i = i
    top_txt = "7D HIGH "
    c.text(top_txt, bx1 - c.text_width(top_txt + str(hi), "4x5") + 1, 1, font = "4x5", color = LABEL)
    c.text(str(hi), bx1 - c.text_width(str(hi), "4x5") + 1, 1, font = "4x5", color = HIGH)

    top = 8
    base = 24
    h = base - top + 1
    gap = 1
    bw = (bx1 - bx0 + 1 - gap * (NDAYS - 1)) // NDAYS
    if bw > 9:
        bw = 9
    if bw < 1:
        bw = 1
    used = bw * NDAYS + gap * (NDAYS - 1)
    bx = bx1 - used + 1
    c.hline(bx, base + 1, used, TRACK)
    for i in range(NDAYS):
        v = counts[i]
        if hi > 0 and v > 0:
            bh = int(v * (h - 2) / hi + 0.5)
            if bh < 1:
                bh = 1
            color = "white" if i == NDAYS - 1 else PINK
            c.rect(bx, base - bh + 1, bx + bw - 1, base, fill = color)
            if i == hi_i:
                c.rect(bx, base - bh - 1, bx + bw - 1, base - bh, fill = HIGH)
        bx += bw + gap

    # ---- next update
    nt = ("DEMO " if demo else "NEXT ") + next_txt
    c.text(nt, bx1 - c.text_width(nt, "4x5") + 1, 27, font = "4x5", color = ("amber" if demo else LABEL))

def orders(c, ctx):
    c.clear()
    shop = clean_shop(str(ctx.inputs.get("shop", "")))
    key = str(ctx.inputs.get("apikey", "")).strip()
    zone = str(ctx.inputs.get("tz", "America/Chicago"))
    if zone not in ZONES:
        zone = "America/Chicago"
    skip = str(ctx.inputs.get("cancelled", "skip")) != "count"
    now = ctx.now.unix
    next_txt = clock12(local_secs(zone, now + REFRESH))

    if str(ctx.inputs.get("shop", "")).strip() == "" or key == "":
        draw_orders(c, demo_counts(), next_txt, True)
        return
    if shop == "":
        draw_error(c, ("STORE NOT FOUND", "USE HANDLE BEFORE .MYSHOPIFY.COM"))
        return
    data = fetch_counts(shop, key, zone, now, skip)
    if not data["ok"]:
        draw_error(c, data["err"])
        return
    draw_orders(c, data, next_txt, False)
