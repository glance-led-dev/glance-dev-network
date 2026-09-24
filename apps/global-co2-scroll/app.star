# Carbon in the Air - the global CO2 concentration, from NOAA GML.
#
# DATA. Two keyless plain-text files from gml.noaa.gov, the global average
# across NOAA's four baseline observatories: Barrow, Mauna Loa, American
# Samoa and the South Pole.
#
#   co2_trend_gl.txt    year month day smoothed trend   (daily, from 2016)
#   co2_annmean_gl.txt  year mean unc                   (annual, from 1979)
#
# SMOOTHED IS NOT TREND. NOAA publishes two columns and they mean different
# things: smoothed still carries the seasonal cycle, trend has it taken out.
# Today's smoothed value sits BELOW the trend because September is near the
# annual low, so labelling one as the other would put a plain factual error
# on the panel. The headline is the smoothed value, which is what is
# actually in the air today; the trend is shown beside it and named.
#
# Both files are .gov, which the render host reaches directly rather than
# through the proxy pool.
#
# MATHS. Every value is parsed to hundredths as an integer, so 424.48
# becomes 42448 and no float arithmetic is needed anywhere.
#
# The daily file is nearly four thousand rows and only the last year is
# ever wanted, so only the tail is parsed rather than all of it.

DAILY = "https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_trend_gl.txt"
ANNUAL = "https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_annmean_gl.txt"
UA = {"User-Agent": "glance-global-co2 (glance-led.dev)"}

# 280 ppm, the level the air held for thousands of years before coal.
PRE_INDUSTRIAL = 28000

INK = "#FFFFFF"
DIM = "#7C8BA1"
FAINT = "#2A3242"
ACCENT = "#FF6B35"
HOT = "#FF3B21"
COOL = "#00C2C7"
WARN = "#FFC219"

MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

SPANS = {"SINCE 1979": 0, "LAST 20 YEARS": 20, "LAST 10 YEARS": 10}

# 7x7, a chimney with the smoke coming off it.
STACK = """
...#.#.
..#.#..
...#...
.#####.
.#...#.
.#...#.
#######
"""

# ------------------------------------------------------------- text tools
def pad2(n):
    return ("0" + str(n)) if n < 10 else str(n)

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for i in range(len(t), 0, -1):
        if c.text_width(t[:i], font) <= maxw:
            return t[:i]
    return ""

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    last = fonts[len(fonts) - 1]
    return [last, clip(c, text, last, maxw)]

def pick(c, options, font, maxw):
    """The first whole phrase that fits, so a label never loses its last
    letters to a wider neighbour."""
    for t in options:
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def rail(c, col):
    c.rect(0, 0, 1, 31, fill = col)

def pill(c, text, col, x, y):
    w = c.text_width(text, "4x5") + 4
    c.rect(x, y, x + w - 1, y + 6, fill = col)
    c.text(text, x + 2, y + 1, font = "4x5", color = "black")
    return w

def notice(c, col, head, subs):
    c.fill("black")
    rail(c, col)
    c.sprite(STACK, 12, 9, legend = {"#": col}, scale = 2)
    hf = fit(c, head, ["9x12", "8x10", "6x8", "5x7"], 150)
    c.text(hf[1], 32, 7, font = hf[0], color = col)
    for f in ["5x7", "4x5"]:
        s = pick(c, subs, f, 150)
        if s != "":
            c.text(s, 32, 23, font = f, color = DIM)
            return
    c.text(clip(c, subs[len(subs) - 1], "4x5", 150), 32, 23,
           font = "4x5", color = DIM)

# ------------------------------------------------------------- numbers
def ppm100(s):
    """424.48 into 42448, so everything downstream is integer maths."""
    t = str(s).strip()
    neg = t.startswith("-")
    if neg:
        t = t[1:]
    whole, frac = t, "00"
    if "." in t:
        bits = t.split(".")
        whole, frac = bits[0], (bits[1] + "00")[:2]
    if whole == "" or not whole.isdigit() or not frac.isdigit():
        return None
    v = int(whole) * 100 + int(frac)
    return -v if neg else v

def fmt2(v):
    """42448 back into 424.48, sign carried."""
    sign = "-" if v < 0 else ""
    a = -v if v < 0 else v
    return sign + str(a // 100) + "." + pad2(a % 100)

def fmt1(v):
    """42448 into 424.5, rounded rather than cut."""
    sign = "-" if v < 0 else ""
    a = -v if v < 0 else v
    a = (a + 5) // 10
    return sign + str(a // 10) + "." + str(a % 10)

def signed1(v):
    return ("+" + fmt1(v)) if v >= 0 else fmt1(v)

def fields(line):
    out = []
    for t in str(line).replace("\r", "").replace("\t", " ").split(" "):
        if t != "":
            out.append(t)
    return out

# ---------------------------------------------------------------- charts
def chart(c, vals, x0, y0, x1, y1, col, base):
    """A filled column chart, one pixel per column, scaled to its own range.
    A flat series would divide by zero, so it is given a floor of one."""
    n = len(vals)
    w = x1 - x0 + 1
    h = y1 - y0 + 1
    if n < 2 or w < 2 or h < 2:
        return
    lo, hi = vals[0], vals[0]
    for v in vals:
        if v < lo:
            lo = v
        if v > hi:
            hi = v
    rng = hi - lo
    if rng < 1:
        rng = 1
    for i in range(w):
        idx = i * (n - 1) // (w - 1)
        t = (vals[idx] - lo) * (h - 1) // rng
        c.rect(x0 + i, y1 - t, x0 + i, y1, fill = base)
        c.rect(x0 + i, y1 - t, x0 + i, y1 - t, fill = col)

# ------------------------------------------------------------------ feed
def rows_of(body, tail):
    """Data rows, comments dropped. Only the tail of the daily file is ever
    wanted, and it is nearly four thousand lines, so it is cut first."""
    lines = str(body).split("\n")
    if tail > 0 and len(lines) > tail:
        lines = lines[len(lines) - tail:]
    out = []
    for ln in lines:
        s = ln.strip()
        if s == "" or s.startswith("#"):
            continue
        out.append(fields(s))
    return out

def fetch(ctx):
    cmp_in = str(ctx.inputs.get("compare", "A YEAR AGO")).strip().upper()
    if cmp_in not in ["A YEAR AGO", "PRE-INDUSTRIAL", "1979"]:
        cmp_in = "A YEAR AGO"
    span_in = str(ctx.inputs.get("span", "SINCE 1979")).strip().upper()
    if span_in not in SPANS:
        span_in = "SINCE 1979"
    base = {"cmp": cmp_in, "span": span_in}

    rd = http.get(DAILY, headers = UA, ttl_seconds = 3600)
    if rd["status_code"] == 0:
        return dict(base, ok = False, offline = True, head = "NOAA OFFLINE",
                    subs = ["RETRY IN 1 HOUR"])
    if rd["status_code"] != 200:
        return dict(base, ok = False, head = "CO2 FEED ERROR",
                    subs = ["HTTP " + str(rd["status_code"]) + " - RETRY LATER"])

    # year month day smoothed trend, one row a day
    daily = []
    for f in rows_of(rd["body"], 420):
        if len(f) < 5:
            continue
        sm, tr = ppm100(f[3]), ppm100(f[4])
        y, m, d = ppm100(f[0]), ppm100(f[1]), ppm100(f[2])
        if sm == None or tr == None or y == None or m == None or d == None:
            continue
        daily.append([y // 100, m // 100, d // 100, sm, tr])
    if len(daily) == 0:
        return dict(base, ok = False, head = "CO2 FEED ERROR",
                    subs = ["NO READINGS IN THE DAILY FILE"])

    last = daily[len(daily) - 1]
    year_ago = daily[0] if len(daily) < 366 else daily[len(daily) - 366]

    ra = http.get(ANNUAL, headers = UA, ttl_seconds = 3600)
    annual = []
    if ra["status_code"] == 200:
        for f in rows_of(ra["body"], 0):
            if len(f) < 2:
                continue
            y, v = ppm100(f[0]), ppm100(f[1])
            if y == None or v == None:
                continue
            annual.append([y // 100, v])

    return dict(base, ok = True, daily = daily, annual = annual,
                last = last, year_ago = year_ago)

def fail(c, d):
    notice(c, COOL if d.get("offline", False) else HOT, d["head"], d["subs"])

# ------------------------------------------------------------- page: now
def now(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail(c, d)
        return
    c.fill("black")
    rail(c, ACCENT)
    last = d["last"]

    c.sprite(STACK, 10, 0, legend = {"#": ACCENT})
    x = 19 + pill(c, "GLOBAL CO2", ACCENT, 19, 0) + 2
    when = str(last[2]) + " " + MON[last[1] - 1] + " " + str(last[0])
    if c.text_width(when, "4x5") <= 181 - x - 2:
        c.text(when, 181, 1, font = "4x5", color = DIM, align = "right")

    # The headline is the smoothed value: what is actually in the air today.
    head = fmt2(last[3])
    c.text(head, 10, 8, font = "10x16", color = INK)
    hx = 10 + c.text_width(head, "10x16") + 4
    c.text("PPM", hx, 18, font = "5x7", color = ACCENT)

    # Right column: how much more than the chosen comparison.
    if d["cmp"] == "PRE-INDUSTRIAL":
        delta, label = last[3] - PRE_INDUSTRIAL, ["OVER 280 PPM", "VS 1750"]
    elif d["cmp"] == "1979":
        first = d["annual"][0][1] if len(d["annual"]) > 0 else None
        delta = last[3] - first if first != None else None
        label = ["OVER 1979", "VS 1979"]
    else:
        delta, label = last[3] - d["year_ago"][3], ["IN ONE YEAR", "IN A YEAR"]

    if delta != None:
        big = signed1(delta) + " PPM"
        c.text(big, 181, 9, font = "5x7", color = HOT if delta >= 0 else COOL,
               align = "right")
        c.text(pick(c, label, "4x5", 80), 181, 18, font = "4x5", color = DIM,
               align = "right")

    c.text("TREND " + fmt2(last[4]) + " PPM", 10, 25, font = "4x5", color = DIM)
    c.text("NOAA GLOBAL", 181, 25, font = "4x5", color = DIM, align = "right")

# ------------------------------------------------------------ page: rise
def rise(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail(c, d)
        return
    ann = d["annual"]
    if len(ann) < 2:
        notice(c, WARN, "NO ANNUAL RECORD",
               ["THE YEARLY FILE CAME BACK EMPTY", "YEARLY FILE EMPTY"])
        return
    c.fill("black")
    rail(c, ACCENT)

    keep = SPANS[d["span"]]
    if keep > 0 and len(ann) > keep:
        ann = ann[len(ann) - keep:]
    vals = []
    for row in ann:
        vals.append(row[1])
    first, latest = ann[0], ann[len(ann) - 1]

    x = 10 + pill(c, "THE RISE", ACCENT, 10, 0) + 3
    right = signed1(latest[1] - first[1]) + " PPM"
    c.text(right, 181, 1, font = "4x5", color = HOT, align = "right")
    c.text(pick(c, ["ANNUAL MEAN " + str(first[0]) + " TO " + str(latest[0]),
                    str(first[0]) + " TO " + str(latest[0]), "ANNUAL MEAN"],
                "4x5", 181 - c.text_width(right, "4x5") - 5 - x + 1),
           x, 1, font = "4x5", color = INK)

    chart(c, vals, 10, 9, 181, 24, ACCENT, FAINT)

    c.text(str(first[0]) + "  " + fmt1(first[1]), 10, 26, font = "4x5", color = DIM)
    c.text(str(latest[0]) + "  " + fmt1(latest[1]), 181, 26, font = "4x5",
           color = INK, align = "right")

# ---------------------------------------------------------- page: season
def season(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail(c, d)
        return
    daily = d["daily"]
    if len(daily) < 30:
        notice(c, WARN, "NOT ENOUGH DAYS",
               ["THE DAILY FILE IS TOO SHORT TO DRAW", "DAILY FILE TOO SHORT"])
        return
    c.fill("black")
    rail(c, COOL)

    year = daily if len(daily) < 366 else daily[len(daily) - 366:]
    vals = []
    hi_i, lo_i = 0, 0
    for i in range(len(year)):
        vals.append(year[i][3])
        if year[i][3] > year[hi_i][3]:
            hi_i = i
        if year[i][3] < year[lo_i][3]:
            lo_i = i

    x = 10 + pill(c, "YEARLY CYCLE", COOL, 10, 0) + 3
    swing = fmt1(vals[hi_i] - vals[lo_i]) + " PPM SWING"
    c.text(swing, 181, 1, font = "4x5", color = INK, align = "right")
    c.text(pick(c, ["PLANTS BREATHE IN AND OUT", "THE PLANTS BREATHE",
                    "SEASONAL"], "4x5",
                181 - c.text_width(swing, "4x5") - 5 - x + 1),
           x, 1, font = "4x5", color = DIM)

    chart(c, vals, 10, 9, 181, 24, COOL, FAINT)

    hi, lo = year[hi_i], year[lo_i]
    c.text("PEAK " + MON[hi[1] - 1] + " " + fmt1(hi[3]), 10, 26,
           font = "4x5", color = DIM)
    c.text("LOW " + MON[lo[1] - 1] + " " + fmt1(lo[3]), 181, 26,
           font = "4x5", color = DIM, align = "right")
