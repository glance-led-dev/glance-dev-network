# 10-Year Treasury Yield
#
# The benchmark US 10-year Treasury yield from treasury.gov's daily par
# yield curve feed (keyless XML, one call per month). Page one is the 10Y
# itself with its 1-day, 1-week and 1-month moves in basis points; page two
# is the 2Y-10Y spread, the recession-watch number, named NORMAL / FLAT /
# INVERTED.
#
# DESIGN. Black ground, a small engraved bond certificate (ivory border,
# gold seal) as the identity on the wide build, and "10 YEAR TREASURY" as
# the eyebrow. The yield is the hero in 16x20 white with a smaller percent
# sign hung on its baseline. Green and red only ever mean "rose" and
# "fell"; the left rail wears the day's move so the page never argues with
# itself. Changes sit in a boxed right zone, value measured first and the
# label fitted into what is left. On 64 the certificate and the date are
# dropped rather than squeezed.
#
# Cadence: treasury.gov posts once per business day (mid-afternoon ET), so
# refresh 3600 and the fetch ttl 3600 are kept in sync.

FEED = "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml"

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"       # hero numbers
IVORY = "#E9DCB4"     # identity and labels that name things
PARCH = "#8C845F"     # dim secondary labels
MINT = "#5FCB8A"      # sparkline
MINT_WASH = "#0B2416" # area under sparkline
RULE = "#2A2A2A"      # hairlines
ZERO = "#5A1E1E"      # the 0 bp line on the spread chart
UP = "green"
DOWN = "red"
FLAT = "gray"
OFFLINE = "#3C4043"
DIM = "#6E7A94"

FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# Business days back for the week and month moves. Counting rows rather
# than calendar days keeps the arithmetic exact; a holiday in the window
# shifts the comparison by one session, which is how desks quote it anyway.
WEEK_BACK = 5
MONTH_BACK = 21

# --------------------------------------------------------------- pixel art
# A bond certificate, 22 x 13: A ivory border, C engraved text lines,
# D gold seal. Wide build only.
CERT = """
AAAAAAAAAAAAAAAAAAAAAA
A....................A
A.CCCCCCCCCCCCCCCCC..A
A....................A
A.CCCCCCCCCCCC.......A
A....................A
A.CCCCCCCCC.....DDD..A
A..............DDDDD.A
A.CCCCCCC......DDDDD.A
A..............DDDDD.A
A...............DDD..A
A....................A
AAAAAAAAAAAAAAAAAAAAAA
"""
CERT_LEGEND = {"A": IVORY, "C": PARCH, "D": "#FFD36A"}

# ------------------------------------------------------------- text tools
def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw` (nothing in the API clips)."""
    t = str(text)
    if maxw <= 0:
        return ""
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    """[font, clipped text] for the largest listed font that fits."""
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def message(c, head, sub):
    """Shared failure card. `head`/`sub` are [wide, narrow] copy pairs."""
    wide = c.width >= 128
    h = head[0] if wide else head[1]
    u = sub[0] if wide else sub[1]
    maxw = c.width - 24 if wide else c.width - 2
    hf = fit(c, h, ["5x7", "4x5"], maxw)
    c.text(hf[1], c.width // 2, 9, font = hf[0], color = "amber", align = "center")
    sf = fit(c, u, ["4x5", "picopixel"], maxw)
    c.text(sf[1], c.width // 2, 20, font = sf[0], color = DIM, align = "center")

# ------------------------------------------------------------- number tools
def num(s, fallback = -1):
    t = str(s).strip()
    if t == "":
        return fallback
    for ch in t.elems():
        if ch < "0" or ch > "9":
            return fallback
    return int(t)

def hundredths(s):
    """'4.79' -> 479 (basis points), exact integer maths. Blank/N/A -> None."""
    t = str(s).strip()
    if t == "" or t == "N/A":
        return None
    neg = t.startswith("-")
    if neg:
        t = t[1:]
    parts = t.split(".")
    if len(parts) > 2:
        return None
    whole = num(parts[0], -1)
    if whole < 0:
        return None
    frac = 0
    if len(parts) == 2:
        frac = num((parts[1] + "00")[:2], -1)
        if frac < 0:
            return None
    v = whole * 100 + frac
    return -v if neg else v

def pct_text(bp):
    """479 -> '4.79'."""
    return str(bp // 100) + "." + fmt.pad(bp % 100)

def signed(d):
    """52 -> '+52', -48 -> '-48', 0 -> '0'."""
    if d == 0:
        return "0"
    return ("+" if d > 0 else "-") + str(math.abs(d))

def bp_text(d):
    """Move with a spaced unit for the wide build; '--' when unknown."""
    if d == None:
        return "--"
    if d == 0:
        return "UNCH"
    return signed(d) + " BP"

def bp_short(d):
    if d == None:
        return "--"
    if d == 0:
        return "UNCH"
    return signed(d) + "BP"

def move_color(d):
    if d == None or d == 0:
        return FLAT
    return UP if d > 0 else DOWN

def curve_shape(spread):
    """[word, colour] from the 2s/10s spread, banded in one place."""
    if spread == None:
        return ["NO SPREAD", FLAT]
    if spread < 0:
        return ["INVERTED", DOWN]
    if spread < 10:
        return ["FLAT", "amber"]
    return ["NORMAL", UP]

# ------------------------------------------------------------------- feed
def between(s, open_tag, close_tag):
    """Text between an opening tag (attributes allowed) and its close."""
    i = s.find(open_tag)
    if i < 0:
        return None
    i = s.find(">", i)
    if i < 0:
        return None
    j = s.find(close_tag, i)
    if j < 0:
        return None
    return s[i + 1:j]

def parse_month(body):
    """Atom XML: one <entry> per business day with <d:NEW_DATE>,
    <d:BC_2YEAR> and <d:BC_10YEAR>. No XML parser in the sandbox, and the
    shape is fixed, so cut it up with find()."""
    rows = []
    pos = 0
    for _ in range(40):
        e = body.find("<entry>", pos)
        if e < 0:
            break
        end = body.find("</entry>", e)
        if end < 0:
            break
        chunk = body[e:end]
        pos = end + 8
        d = between(chunk, "<d:NEW_DATE", "</d:NEW_DATE>")
        if d == None:
            continue
        ten = between(chunk, "<d:BC_10YEAR", "</d:BC_10YEAR>")
        two = between(chunk, "<d:BC_2YEAR", "</d:BC_2YEAR>")
        rows.append({
            "date": d[:10],
            "ten": hundredths(ten) if ten != None else None,
            "two": hundredths(two) if two != None else None,
        })
    return rows

def fetch_rows(ctx):
    """Three months, oldest first, so the 1-month move and a 30-day
    sparkline both have history even on the 2nd of a month. Three calls
    of the 8-per-render budget, each cached an hour to match refresh."""
    y, m = ctx.now.year, ctx.now.month
    yms = []
    for back in [2, 1, 0]:
        mm = m - back
        yy = y
        if mm < 1:
            mm += 12
            yy -= 1
        yms.append([yy, mm])
    rows = []
    status = 0
    for ym in yms:
        r = http.get(FEED,
                     params = {"data": "daily_treasury_yield_curve",
                               "field_tdr_date_value_month": str(ym[0]) + fmt.pad(ym[1])},
                     headers = {"User-Agent": "glance-ten-year-treasury"},
                     ttl_seconds = 3600)
        code = r.get("status_code", 0)
        if code == 200:
            status = 200
            rows = rows + parse_month(r.get("body", ""))
        elif status == 0:
            status = code
    return [status, sorted(rows, key = lambda r: r["date"])]

def back(series, n):
    """Move from n sessions ago to the latest, or None without the history."""
    if len(series) <= n:
        return None
    return series[len(series) - 1] - series[len(series) - 1 - n]

def short_date(d):
    return MONTHS[num(d[5:7], 1) - 1] + " " + str(num(d[8:10], 1))

def load_data(ctx):
    res = fetch_rows(ctx)
    status, rows = res[0], res[1]
    if status != 200:
        if status == 0:
            return {"ok": False, "head": ["TREASURY OFFLINE", "OFFLINE"],
                    "sub": ["RETRYING NEXT HOUR", "RETRY IN 1H"]}
        return {"ok": False, "head": ["TREASURY FEED ERROR", "FEED ERROR"],
                "sub": ["HTTP " + str(status), "HTTP " + str(status)]}
    ten = []
    dates = []
    spread = []
    for r in rows:
        if r["ten"] != None:
            ten.append(r["ten"])
            dates.append(r["date"])
            if r["two"] != None:
                spread.append(r["ten"] - r["two"])
    if len(ten) == 0:
        return {"ok": False, "head": ["NO 10Y YIELD YET", "NO DATA"],
                "sub": ["CHECK BACK THIS AFTERNOON", "CHECK LATER"]}
    last = rows[len(rows) - 1]
    for r in rows:
        if r["ten"] != None:
            last = r
    return {
        "ok": True,
        "ten": ten[len(ten) - 1],
        "d1": back(ten, 1),
        "d1w": back(ten, WEEK_BACK),
        "d1m": back(ten, MONTH_BACK),
        "when": short_date(dates[len(dates) - 1]),
        "ten_series": ten[-30:],
        "two": last["two"],
        "spread": (last["ten"] - last["two"]) if last["two"] != None else None,
        "spread_series": spread[-30:],
    }

def fail(c, d):
    if c.width >= 128:
        rail(c, OFFLINE)
    message(c, d["head"], d["sub"])

# ------------------------------------------------------------ page: 10Y
def ten_page(c, ctx):
    c.fill("black")
    d = load_data(ctx)
    if not d["ok"]:
        fail(c, d)
        return
    if c.width >= 128:
        ten_wide(c, d)
    else:
        ten_narrow(c, d)

def ten_wide(c, d):
    rail(c, move_color(d["d1"]))
    # Certificate x 10..31, y 10..22, centred on the hero band.
    c.sprite(CERT, 10, 10, legend = CERT_LEGEND)

    # Eyebrow: "10 YEAR TREASURY" is 73 px in 4x5 -> x 37..109, clear of
    # the divider at 116.
    lx = 37
    c.text(clip(c, "10 YEAR TREASURY", "4x5", 76), lx, 2, font = "4x5", color = IVORY)

    # Hero y 9..28: "4.96" is 67 px in 16x20 (x 37..103); "%" 6 px at
    # x 105..110. A two-digit yield ("12.50", 84 px) steps down to 10x16.
    hf = fit(c, pct_text(d["ten"]), ["16x20", "10x16"], 66)
    c.text(hf[1], lx, 9, font = hf[0], color = INK)
    vw = c.text_width(hf[1], hf[0])
    c.text("%", lx + vw + 2, 9 + FONTH[hf[0]] - 8, font = "6x8", color = PARCH)

    # Boxed right zone x 120..181 (62 px). Row 0: the close date.
    c.vline(116, 2, 28, RULE)
    rx0, rx1 = 120, 181
    when = clip(c, d["when"], "4x5", 40)
    ww = c.text_width(when, "4x5")
    c.text(when, rx1, 2, font = "4x5", color = IVORY, align = "right")
    c.text(clip(c, "CLOSE", "4x5", rx1 - rx0 + 1 - ww - 3), rx0, 2, font = "4x5",
           color = PARCH)
    c.hline(rx0, 8, rx1 - rx0 + 1, RULE)

    # Rows 1-3: value measured first, label fitted into the rest.
    # Worst case "MONTH" 24 + 3 + "-123 BP" 30 = 57 of 62.
    rows = [["DAY", d["d1"], 10], ["WEEK", d["d1w"], 17], ["MONTH", d["d1m"], 24]]
    for r in rows:
        v = clip(c, bp_text(r[1]), "4x5", 40)
        vw2 = c.text_width(v, "4x5")
        c.text(v, rx1, r[2], font = "4x5", color = move_color(r[1]), align = "right")
        c.text(clip(c, r[0], "4x5", rx1 - rx0 + 1 - vw2 - 3), rx0, r[2],
               font = "4x5", color = PARCH)

def ten_narrow(c, d):
    # Header y 1..5: "10Y" (13 px) left; the day's move right with its
    # arrow. "-123BP" is 27 px, arrow at x 30..34 worst case.
    col = move_color(d["d1"])
    c.text("10Y", 1, 1, font = "4x5", color = IVORY)
    mv = bp_short(d["d1"])
    mw = c.text_width(mv, "4x5")
    c.text(mv, 63, 1, font = "4x5", color = col, align = "right")
    if d["d1"] != None:
        c.trend_arrow(63 - mw - 6, 1, d["d1"], col)
    c.hline(0, 7, 64, RULE)

    # Hero y 9..24: "4.96" is 43 px in 10x16, "%" 5x7 on its baseline.
    hf = fit(c, pct_text(d["ten"]), ["10x16", "6x8"], 54)
    c.text(hf[1], 1, 9, font = hf[0], color = INK)
    vw = c.text_width(hf[1], hf[0])
    c.text("%", 1 + vw + 2, 9 + FONTH[hf[0]] - 7, font = "5x7", color = PARCH)

    # Footer y 26..30: week left, month right. "1W -12" 25 + "1M +123" 30.
    m = "1M " + (signed(d["d1m"]) if d["d1m"] != None else "--")
    mw2 = c.text_width(m, "4x5")
    c.text(m, 63, 26, font = "4x5", color = move_color(d["d1m"]), align = "right")
    w = "1W " + (signed(d["d1w"]) if d["d1w"] != None else "--")
    c.text(clip(c, w, "4x5", 64 - mw2 - 4), 1, 26, font = "4x5",
           color = move_color(d["d1w"]))

# ---------------------------------------------------------- page: spread
def spread_page(c, ctx):
    c.fill("black")
    d = load_data(ctx)
    if not d["ok"]:
        fail(c, d)
        return
    if d["spread"] == None:
        fail(c, {"head": ["NO 2-YEAR YIELD TODAY", "NO 2Y DATA"],
                 "sub": ["SPREAD RETURNS NEXT CLOSE", "CHECK LATER"]})
        return
    shape = curve_shape(d["spread"])
    if c.width >= 128:
        spread_wide(c, d, shape)
    else:
        spread_narrow(c, d, shape)

def hero_bp(c, value, x, y, maxw, fonts, unit_font):
    """Signed spread as the hero with 'BP' hung on its baseline; steps
    down the ladder until number + unit fit `maxw`."""
    t = signed(value)
    uw = c.text_width("BP", unit_font)
    hf = fit(c, t, fonts, maxw - uw - 2)
    c.text(hf[1], x, y, font = hf[0], color = INK)
    vw = c.text_width(hf[1], hf[0])
    c.text("BP", x + vw + 2, y + FONTH[hf[0]] - FONTH[unit_font], font = unit_font,
           color = PARCH)

def spread_wide(c, d, shape):
    rail(c, shape[1])
    lx = 12
    # Eyebrow "2Y-10Y SPREAD" 60 px -> x 12..71.
    c.text(clip(c, "2Y-10Y SPREAD", "4x5", 80), lx, 2, font = "4x5", color = IVORY)
    # Hero y 9..28: "+123" 67 + 2 + "BP" 13 = 82 -> x 12..93, clear of 98.
    hero_bp(c, d["spread"], lx, 9, 84, ["16x20", "10x16"], "6x8")

    # Middle zone x 102..135: 30 sessions of the spread, a dim red line at
    # 0 bp when the history crosses it (the inversion line).
    c.vline(98, 2, 28, RULE)
    sx, sy, sw, sh = 102, 9, 34, 15
    ss = d["spread_series"]
    if len(ss) >= 2:
        lo, hi = min(ss), max(ss)
        if lo < 0 and hi > 0:
            zy = sy + sh - 1 - ((0 - lo) * (sh - 1) + (hi - lo) // 2) // (hi - lo)
            c.hline(sx, zy, sw, ZERO)
        c.sparkline(ss, sx, sy, sw, sh, color = MINT, fill = MINT_WASH)
    c.hline(sx, sy + sh, sw, RULE)
    c.text(clip(c, "30 DAY", "4x5", sw), sx, 2, font = "4x5", color = PARCH)
    c.text(clip(c, d["when"], "4x5", sw), sx, 26, font = "4x5", color = PARCH)

    # Right zone x 143..181 (39 px): shape word, then the two legs.
    c.vline(139, 2, 28, RULE)
    rx0, rx1 = 143, 181
    c.text(clip(c, shape[0], "4x5", rx1 - rx0 + 1), rx1, 2, font = "4x5",
           color = shape[1], align = "right")
    c.hline(rx0, 8, rx1 - rx0 + 1, RULE)
    legs = [["2Y", d["two"], 12], ["10Y", d["ten"], 21]]
    for leg in legs:
        v = pct_text(leg[1]) + "%" if leg[1] != None else "--"
        v = clip(c, v, "4x5", 26)
        vw = c.text_width(v, "4x5")
        c.text(v, rx1, leg[2], font = "4x5", color = INK, align = "right")
        c.text(clip(c, leg[0], "4x5", rx1 - rx0 + 1 - vw - 2), rx0, leg[2],
               font = "4x5", color = PARCH)

def spread_narrow(c, d, shape):
    # Header "2Y-10Y SPREAD" 60 px at x 1..60.
    c.text(clip(c, "2Y-10Y SPREAD", "4x5", 62), 1, 1, font = "4x5", color = IVORY)
    c.hline(0, 7, 64, RULE)
    # Hero y 9..24: "+123" 42 + 2 + "BP" 11 = 55 px.
    hero_bp(c, d["spread"], 1, 9, 62, ["10x16", "6x8"], "5x7")
    # Footer: the shape word in its colour ("INVERTED" 37 px), close date
    # right ("SEP 30" 27 px) only if both fit with a gap; else the word wins.
    w = c.text_width(shape[0], "4x5")
    c.text(clip(c, shape[0], "4x5", 62), 1, 26, font = "4x5", color = shape[1])
    dt = d["when"]
    if w + 4 + c.text_width(dt, "4x5") <= 62:
        c.text(dt, 63, 26, font = "4x5", color = PARCH, align = "right")
