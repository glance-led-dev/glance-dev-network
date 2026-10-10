# DESIGN. A podium. Each page is one hero card for yesterday's #1, #2 or #3
# most extreme U.S. reading in the chosen metric: a medal on the left (the
# ribbon wears the metric's color, the disc the rank's metal, the rank knocked
# out of it in black), the reading as the white hero, and the place under an
# eyebrow that names the extreme ("HOTTEST"). Medal + eyebrow is the app's
# identity on every page, so no separate splash page is spent on it.
#
# Color only where it means something: the metric accent on the ribbon, the
# eyebrow and the hero's degree / unit mark; red only for a reading that tied
# or broke the station's record. Black ground throughout.
#
# 64 wide: medal left, eyebrow over a 10x16 hero beside it, the place on its
# own full-width row along the bottom; the context line is dropped rather than
# squeezed. 192 wide: everything inside the x 10-181 safe zone -- medal, a
# text column (eyebrow + date, place in the largest font that fits, context
# line), a hairline, and the hero right-aligned against the safe edge. Both
# apps ship this file; the only branch is `c.width >= 128`.
#
# Why four fixed pages instead of cycling one city per minute: the source is
# the NWS once-a-day climate report, so `refresh` is 3600, in sync with the
# fetch ttl. At that cadence a per-minute cycle would park on a single city
# for an hour, and a ranked list doesn't fit 64 wide ("PHILADELPHIA" alone is
# 57px at 4x5, leaving no room for a rank and a value on the same row). Four
# pages give every city the full width and never rotate through a dead screen.
#
# Rain, high and low temps come from one nationwide /api/v1/yesterday call,
# ranked client-side. Snowfall comes from /api/v1/snow/reports, whose
# "reports" schema isn't documented and is empty outside snow season --
# rows_for_snow() infers the per-report fields from hail/week's identical
# "NWS Local Storm Reports via IEM" source line but hasn't been checked
# against a live snow report. Read defensively.
#
# A fifth Metric choice, "Extremes", isn't a rank within one metric -- it's
# the #1 reading from each of the other four, one per page (gold=hottest,
# silver=coldest, bronze=wettest, the 4th spot=snowiest). Every page draws a
# GOLD "1ST" medal in that mode regardless of its slot, because each city
# genuinely is the #1 for its own metric -- a silver medal on the coldest
# city would misread as "2nd coldest," which it isn't. podium()'s `slot`
# parameter (which page position this is) and the metric/rank it actually
# fetches are the same thing in normal mode and different things in Extremes
# mode; see the slot/rank split there. The same reuse also gave the normal
# mode a 4th page for free: it now runs the podium one place deeper (top 4,
# not top 3) instead of the 4th page having nothing to show outside Extremes.

BG = "#000000"
INK = "#FFFFFF"          # hero reading
PLACE_COL = "#DCE6F2"    # city
META_COL = "#6E7A94"     # date, "ABOVE NORMAL", report kind
RULE_COL = "#232A3A"     # hairline between the text column and the hero
RECORD_COL = "#FF3B30"   # the only color allowed to shout

NODATA_BG = "#0B0C12"
NODATA_TITLE = "#E8B04A"
NODATA_SUB = "#6A7090"
EMPTY_TITLE = "#4ADE80"
EMPTY_SUB = "#6A9080"
SHORT_TITLE = "#8A93B4"

# [fill, rim] per podium spot.
METALS = [
    ["#FFC72C", "#A8740A"],  # gold
    ["#DCE3EA", "#7F8B99"],  # silver
    ["#E3894A", "#8C4A1F"],  # bronze
    ["#8B93A0", "#4A515C"],  # steel -- the 4th spot, off the traditional podium
]
ORDINALS = ["1ST", "2ND", "3RD", "4TH"]

# Extremes mode: page slot -> the metric it always shows rank 0 of.
EXTREME_METRICS = ["Extreme High Temp", "Extreme Low Temp", "Extreme Rain", "Extreme Snowfall"]

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

FONTH = {"16x24": 24, "16x20": 20, "10x16": 16, "7x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# Degree rings, sized to the hero face they sit beside (top-aligned).
RING6 = [
    ".####.",
    "######",
    "##..##",
    "##..##",
    "######",
    ".####.",
]
RING4 = [
    ".##.",
    "#..#",
    "#..#",
    ".##.",
]
RING3 = [
    ".#.",
    "#.#",
    ".#.",
]

# hero face -> [degree ring, unit font]
MARKS = {
    "16x24": [RING6, "6x8"],
    "16x20": [RING6, "6x8"],
    "10x16": [RING4, "4x5"],
    "7x12": [RING3, "4x5"],
    "6x8": [RING3, "4x5"],
}

# The only three cities in the feed that overflow the 62px 64-wide place row
# at 4x5 even without their state: COLORADO SPRINGS 76px, SAULT STE MARIE 68,
# CORPUS CHRISTI 64. Each short form is the name locals already use.
SHORT = {
    "COLORADO SPRINGS": "COLO SPRINGS",
    "SAULT STE MARIE": "SAULT",
    "CORPUS CHRISTI": "CORPUS",
}

def theme(metric):
    """[eyebrow word, accent, accent shade] -- one place, so the ribbon, the
    eyebrow and the hero's mark can never disagree."""
    if metric == "Extreme Low Temp":
        return ["COLDEST", "#5CC8FF", "#2A7BB8"]
    if metric == "Extreme Rain":
        return ["WETTEST", "#3D7BFF", "#1F47B0"]
    if metric == "Extreme Snowfall":
        return ["SNOWIEST", "#D6E8FF", "#8AA6CC"]
    return ["HOTTEST", "#FF8A1F", "#B34D00"]

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw` in `font`."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest listed font that fits, else hard-clipped
    at the smallest."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

def fit_forms(c, forms, fonts, maxw):
    """[font, text] for the largest font that holds some whole form
    (longest first). Last resort backs off to a word boundary rather than
    clipping mid-word -- place names off snow reports can run long and
    ragged ("3 SSW Mount Baker Lodge")."""
    for f in fonts:
        for t in forms:
            if c.text_width(t, f) <= maxw:
                return [f, t]
    last_font = fonts[len(fonts) - 1]
    last_form = forms[len(forms) - 1]
    t = clip(c, last_form, last_font, maxw)
    if len(t) < len(last_form) and last_form[len(t)] != " ":
        for k in range(len(t), 0, -1):
            if t[k - 1] == " ":
                head = t[:k].strip()
                if head != "":
                    t = head
                break
    return [last_font, t]

NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]

def message_card(c, bg, title, title_col, sub, sub_col, narrow_title, narrow_sub):
    """The shared two-line card (error / empty / short list) -- centered, on
    bands that can never overlap, inside the safe zone when wide."""
    c.fill(bg)
    if c.width >= 128:
        maxw = c.width - 20
        t = fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = title_col, align = "center")
        d = fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = sub_col, align = "center")
    else:
        maxw = c.width - 4
        t = fit_clip(c, narrow_title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = title_col, align = "center")
        d = fit_clip(c, narrow_sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = sub_col, align = "center")

def get(obj, key, fallback = None):
    """dict.get that survives a null parent."""
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def decimals(x, places):
    """A non-negative reading to `places` (1 or 2) decimals, rounded."""
    scale = 100 if places == 2 else 10
    v = int(float(x) * scale + 0.5)
    frac = str(v % scale)
    if places == 2 and len(frac) < 2:
        frac = "0" + frac
    return str(v // scale) + "." + frac

OK_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ,.-/()&'"

def only_drawable(s):
    """Drop anything the bitmap fonts have no glyph for, collapsing runs of
    the resulting spaces -- snow-report place names carry the odd symbol."""
    out = ""
    prev_space = False
    for i in range(len(s)):
        ch = s[i]
        if OK_CHARS.find(ch) < 0:
            ch = " "
        if ch == " ":
            if prev_space:
                continue
            prev_space = True
        else:
            prev_space = False
        out += ch
    return out.strip()

def short_date(iso):
    """"2026-09-13" -> "SEP 13"; "" when it doesn't parse."""
    s = str(iso)
    if len(s) < 10 or s[4] != "-" or s[7] != "-":
        return ""
    mm = s[5:7].lstrip("0")
    dd = s[8:10].lstrip("0")
    if not mm.isdigit() or not dd.isdigit():
        return ""
    m = int(mm)
    if m < 1 or m > 12:
        return ""
    return MONTHS[m - 1] + " " + dd

def fetch_yesterday():
    """[cities, date, reason]. reason is "ok" or "error". ttl matches the
    manifest's hourly refresh: the climate report behind this changes once a
    day, so every render within the hour reads the same cached response."""
    r = http.get("https://weathertotals.com/api/v1/yesterday", ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        return [[], "", "error"]
    data = get(r["json"], "data", {})
    return [get(data, "cities", []), short_date(get(data, "date", "")), "ok"]

def fetch_snow_reports():
    """[reports, reason]. reason is "ok" or "error". Same hourly ttl."""
    r = http.get("https://weathertotals.com/api/v1/snow/reports", ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        return [[], "error"]
    return [get(get(r["json"], "data", {}), "reports", []), "ok"]

def row(place, state, value, unit, depart = None, note = "", alarm = False):
    return {"place": place, "state": state, "value": value, "unit": unit,
            "depart": depart, "note": note, "alarm": alarm}

def rows_for_temp(cities, hottest):
    """Rows ranked by yesterday's high (hottest=True) or low (False), most
    extreme first. The feed's record is the one standing before yesterday, so
    matching it ties and passing it breaks it."""
    items = []
    for city in cities:
        rep = get(city, "report", {})
        val = get(rep, "high") if hottest else get(rep, "low")
        if val == None:
            continue
        rec = get(rep, "highRecord") if hottest else get(rep, "lowRecord")
        note = ""
        if rec != None:
            if val == rec:
                note = "TIES RECORD"
            elif (val > rec) == hottest:
                note = "NEW RECORD " + ("HIGH" if hottest else "LOW")
        depart = get(rep, "highDepart") if hottest else get(rep, "lowDepart")
        items.append([val, row(
            str(get(city, "city", "")).upper(),
            str(get(city, "abbr", "")).upper(),
            str(int(val)),
            "deg",
            depart = int(depart) if depart != None else None,
            note = note,
            alarm = note != "",
        )])
    items = sorted(items, key = lambda it: it[0], reverse = hottest)
    return [it[1] for it in items]

def rows_for_rain(cities):
    """Rows ranked by yesterday's precip, wettest first. Dry cities are left
    out, so a dry nationwide day lands on the empty screen, not a 0.00 podium."""
    items = []
    for city in cities:
        rep = get(city, "report", {})
        val = get(rep, "precip")
        if val == None or val <= 0:
            continue
        items.append([val, row(
            str(get(city, "city", "")).upper(),
            str(get(city, "abbr", "")).upper(),
            decimals(val, 2),
            "IN",
            note = "DAILY RAINFALL",
        )])
    items = sorted(items, key = lambda it: it[0], reverse = True)
    return [it[1] for it in items]

def rows_for_snow(reports):
    """Rows ranked by report inches, biggest first. See the DESIGN note at
    the top of the file: this report shape is inferred, not confirmed
    against live data."""
    items = []
    for rep in reports:
        inches = get(rep, "inches")
        if inches == None or inches <= 0:
            continue
        place = only_drawable(str(get(rep, "place", "")).upper())
        if place == "":
            place = "UNKNOWN"
        measured = get(rep, "measured", False)
        items.append([inches, row(
            place,
            str(get(rep, "state", "")).upper(),
            decimals(inches, 1),
            "IN",
            note = "MEASURED" if measured else "ESTIMATED",
        )])
    items = sorted(items, key = lambda it: it[0], reverse = True)
    return [it[1] for it in items]

def fetch_rows(metric):
    """[rows, meta, reason]. reason is "ok", "empty" or "error"; meta is the
    window the rows cover ("SEP 13", or "LAST 24H" for snow)."""
    if metric == "Extreme Snowfall":
        reports, reason = fetch_snow_reports()
        if reason != "ok":
            return [[], "", "error"]
        rows = rows_for_snow(reports)
        return [rows, "LAST 24H", "ok" if len(rows) > 0 else "empty"]

    cities, date, reason = fetch_yesterday()
    if reason != "ok":
        return [[], "", "error"]
    if metric == "Extreme Rain":
        rows = rows_for_rain(cities)
    elif metric == "Extreme Low Temp":
        rows = rows_for_temp(cities, False)
    else:
        rows = rows_for_temp(cities, True)
    return [rows, date, "ok" if len(rows) > 0 else "empty"]

def empty_copy(metric):
    """[title, sub, narrow_title, narrow_sub] -- nothing to rank is the
    answer people want, so this is the positive green card, not an error."""
    if metric == "Extreme Snowfall":
        return ["NO SNOW REPORTS", "NONE IN THE LAST 24H", "NO SNOW", "LAST 24H"]
    if metric == "Extreme Rain":
        return ["NO RAIN ANYWHERE", "DRY ACROSS THE U.S.", "NO RAIN", "DRY US-WIDE"]
    return ["NO REPORTS YET", "CHECK BACK SOON", "NO DATA", "CHECK BACK"]

def half_width(r2, dy):
    """Largest hw with hw*hw + dy*dy <= r2, or -1 when row dy is off the disc."""
    rest = r2 - dy * dy
    if rest < 0:
        return -1
    hw = 0
    for k in range(1, 16):
        if k * k > rest:
            break
        hw = k
    return hw

def medal_height(d):
    return (d // 2 - d // 3 + 2) + d

def draw_medal(c, x, y, d, rank, th):
    """A ribbon over a d-wide disc (d odd). The straps are d//3 wide and step
    in a pixel a row until they meet over the disc's center column; the disc
    is drawn after, so the ribbon tucks behind it. The rank is knocked out in
    black -- every metal's fill is brighter than ~150."""
    sw = d // 3
    cx = d // 2
    rh = cx - sw + 2
    for r in range(rh):
        c.line(x + r, y + r, x + r + sw - 1, y + r, th[1])
        c.line(x + d - r - sw, y + r, x + d - 1 - r, y + r, th[2])

    top = y + rh
    fill, rim = METALS[rank]
    r2 = (d * d) // 4
    ri2 = ((d - 2) * (d - 2)) // 4
    for dy in range(-cx, cx + 1):
        hw = half_width(r2, dy)
        if hw < 0:
            continue
        yy = top + cx + dy
        c.line(x + cx - hw, yy, x + cx + hw, yy, rim)
        hi = half_width(ri2, dy)
        if hi >= 0:
            c.line(x + cx - hi, yy, x + cx + hi, yy, fill)

    font = "7x12" if d >= 17 else "5x7"
    label = str(rank + 1)
    lx = x + cx - c.text_width(label, font) // 2
    c.text(label, lx, top + cx - FONTH[font] // 2, font = font, color = "#000000")

def dot_size(font):
    return 3 if FONTH[font] >= 20 else 2

def value_width(c, value, font):
    """Width of a reading drawn with a hand-set minus and decimal point. The
    faces' own "." takes a full cell -- "4.18" is 67px at 16x24, which
    squeezed the wide text column under 64px and knocked the rain hero down
    to 10x16; "4" + a 3px dot + "18" is 56px. And the faces' "-" sits well
    above the digits' middle, so "-23" read like an overline."""
    ds = dot_size(font)
    w = 0
    if value.startswith("-"):
        w = 5 * ds - 2
        value = value[1:]
    parts = value.split(".")
    if len(parts) != 2:
        return w + c.text_width(value, font)
    return w + c.text_width(parts[0], font) + 3 * ds - 2 + c.text_width(parts[1], font)

def draw_bar(c, x, y, w, h, color):
    for i in range(h):
        c.line(x, y + i, x + w - 1, y + i, color)

def draw_value(c, value, font, x, y, color):
    ds = dot_size(font)
    if value.startswith("-"):
        mw = 4 * ds - 2
        draw_bar(c, x, y + (FONTH[font] - ds) // 2, mw, ds, color)
        x += mw + ds
        value = value[1:]
    parts = value.split(".")
    if len(parts) != 2:
        c.text(value, x, y, font = font, color = color)
        return
    c.text(parts[0], x, y, font = font, color = color)
    dx = x + c.text_width(parts[0], font) + ds - 1
    draw_bar(c, dx, y + FONTH[font] - ds, ds, ds, color)
    c.text(parts[1], dx + 2 * ds - 1, y, font = font, color = color)

def hero_width(c, r, font):
    w = value_width(c, r["value"], font)
    mark = MARKS[font]
    if r["unit"] == "deg":
        return w + 1 + len(mark[0][0])
    return w + 2 + c.text_width(r["unit"], mark[1])

def draw_hero(c, r, font, x, y, th):
    """The reading in white, its degree ring (top-aligned) or unit
    (baseline-aligned) in the metric accent."""
    draw_value(c, r["value"], font, x, y, INK)
    w = value_width(c, r["value"], font)
    mark = MARKS[font]
    if r["unit"] == "deg":
        c.sprite(mark[0], x + w + 1, y, legend = {"#": th[1]})
    else:
        c.text(r["unit"], x + w + 2, y + FONTH[font] - FONTH[mark[1]],
               font = mark[1], color = th[1])

def place_forms(r):
    """Longest first: "CITY, ST", "CITY", then the known short name with and
    without its state."""
    names = [r["place"]]
    if r["place"] in SHORT:
        names.append(SHORT[r["place"]])
    forms = []
    for n in names:
        if r["state"] != "":
            forms.append(n + ", " + r["state"])
        forms.append(n)
    return forms

def draw_context(c, r, x, y, maxw):
    """The wide card's third line: a record in red, a snow report's kind or
    "DAILY RAINFALL" in gray, or the departure from normal."""
    if r["note"] != "":
        col = RECORD_COL if r["alarm"] else META_COL
        c.text(clip(c, r["note"], "4x5", maxw), x, y, font = "4x5", color = col)
        return
    dep = r["depart"]
    if dep == None:
        return
    if dep == 0:
        c.text("RIGHT AT NORMAL", x, y, font = "4x5", color = META_COL)
        return

    # "16° ABOVE NORMAL" when it fits, else "+16° VS NORMAL", else just "+16°".
    num = str(dep if dep > 0 else -dep)
    words = "ABOVE NORMAL" if dep > 0 else "BELOW NORMAL"
    if c.text_width(num, "4x5") + 8 + c.text_width(words, "4x5") > maxw:
        num = ("+" if dep > 0 else "-") + num
        words = "VS NORMAL"
    c.text(num, x, y, font = "4x5", color = INK)
    rx = x + c.text_width(num, "4x5") + 1
    c.sprite(RING3, rx, y, legend = {"#": INK})
    wx = rx + 3 + 4
    if wx + c.text_width(words, "4x5") <= x + maxw:
        c.text(words, wx, y, font = "4x5", color = META_COL)

def card_narrow(c, r, rank, th):
    c.fill(BG)
    d = 11
    draw_medal(c, 1, 5, d, rank, th)

    # Zone right of the medal: x 14-63.
    zl = 1 + d + 2
    zw = c.width - zl
    c.text(th[0], zl + zw // 2, 0, font = "4x5", color = th[1], align = "center")

    hf = "6x8"
    for f in ["10x16", "7x12", "6x8"]:
        if hero_width(c, r, f) <= zw:
            hf = f
            break
    hw = hero_width(c, r, hf)
    draw_hero(c, r, hf, zl + (zw - hw) // 2, 7 + (16 - FONTH[hf]) // 2, th)

    p = fit_forms(c, place_forms(r), ["4x5"], c.width - 2)
    c.text(p[1], c.width // 2, 26, font = p[0], color = PLACE_COL, align = "center")

def card_wide(c, r, rank, th, meta):
    c.fill(BG)
    left = 10
    right = c.width - 11  # last lit column of the x 10-181 safe zone on 192
    d = 19
    draw_medal(c, left, (c.height - medal_height(d)) // 2, d, rank, th)
    tx = left + d + 7

    # Right side first: measure the hero, then the text column gets what's
    # left. "4.18 IN" is 82px at 16x24, which would leave the place 53px, so
    # the hero steps down a face whenever the column would drop under 64.
    hf = "10x16"
    for f in ["16x24", "10x16"]:
        if (right - hero_width(c, r, f) - 11) - tx >= 64:
            hf = f
            break
    hw = hero_width(c, r, hf)
    hx = right - hw + 1
    draw_hero(c, r, hf, hx, (c.height - FONTH[hf]) // 2, th)

    rule_x = hx - 6
    c.line(rule_x, 4, rule_x, 27, RULE_COL)
    tw = rule_x - 5 - tx

    c.text(th[0], tx, 3, font = "4x5", color = th[1])
    ew = c.text_width(th[0], "4x5")
    if meta != "" and ew + 5 + c.text_width(meta, "4x5") <= tw:
        c.text(meta, tx + ew + 5, 3, font = "4x5", color = META_COL)

    p = fit_forms(c, place_forms(r), ["6x8", "5x7", "4x5"], tw)
    c.text(p[1], tx, 11 + (8 - FONTH[p[0]]) // 2, font = p[0], color = PLACE_COL)

    draw_context(c, r, tx, 23, tw)

def podium(c, ctx, slot):
    """`slot` is which page this is (0-3, gold/silver/bronze/4th). In normal
    mode that's also the rank to fetch and the medal to draw -- gold really
    is 1st place. In Extremes mode the two split: every slot fetches rank 0
    of its own fixed metric (EXTREME_METRICS[slot]) and always draws a gold
    "1ST" medal, because each is the #1 for its metric, not a 2nd/3rd/4th
    place relative to the others."""
    metric = str(ctx.inputs.get("metric", "Extreme High Temp"))
    extremes = metric == "Extremes"
    eff_metric = EXTREME_METRICS[slot] if extremes else metric
    rank = 0 if extremes else slot
    medal = 0 if extremes else slot

    th = theme(eff_metric)
    rows, meta, reason = fetch_rows(eff_metric)

    if reason == "error":
        message_card(c, NODATA_BG, "NO WEATHER DATA", NODATA_TITLE,
                     "CHECK BACK SOON", NODATA_SUB, "NO DATA", "TRY LATER")
        return
    if reason == "empty":
        title, sub, nt, ns = empty_copy(eff_metric)
        message_card(c, NODATA_BG, title, EMPTY_TITLE, sub, EMPTY_SUB, nt, ns)
        return
    if rank >= len(rows):
        # Only reachable in normal mode -- Extremes always asks for rank 0,
        # and reason == "ok" already guarantees at least one row.
        n = len(rows)
        noun = " REPORT" if n == 1 else " REPORTS"
        message_card(c, BG, "NO " + ORDINALS[rank] + " PLACE", SHORT_TITLE,
                     "ONLY " + str(n) + noun, NODATA_SUB,
                     "NO " + ORDINALS[rank], str(n) + noun)
        return

    if c.width >= 128:
        card_wide(c, rows[rank], medal, th, meta)
    else:
        card_narrow(c, rows[rank], medal, th)

def gold(c, ctx):
    podium(c, ctx, 0)

def silver(c, ctx):
    podium(c, ctx, 1)

def bronze(c, ctx):
    podium(c, ctx, 2)

def fourth(c, ctx):
    podium(c, ctx, 3)
