# Recall Radar — latest FDA recall on a 192x32 panel.
#
# Primary source (same table as FDA.gov Recalls, Market Withdrawals &
# Safety Alerts — no API key):
#   https://www.fda.gov/safety/recalls-market-withdrawals-safety-alerts
#
# Fallback when that page is down, the first page has no match for the
# selected category, or the user filters by Class I/II/III:
#   https://api.fda.gov/food/enforcement.json
#   https://api.fda.gov/drug/enforcement.json
#   https://api.fda.gov/device/enforcement.json
#
# Press-release rows are not yet classified. Do not invent Class I/II/III.
# Frames are still images; the panel advances on the manifest refresh timer.

NOTICE_HEADERS = {
    "User-Agent": "GlanceRecallRadar/1.0 (GDN; official FDA recalls display)",
    "Accept": "text/html,application/xhtml+xml",
}

ENFORCE_HEADERS = {
    "User-Agent": "GlanceRecallRadar/1.0 (GDN; official openFDA display)",
    "Accept": "application/json",
}

NOTICE_URL = "https://www.fda.gov/safety/recalls-market-withdrawals-safety-alerts"
FOOD_URL = "https://api.fda.gov/food/enforcement.json"
DRUG_URL = "https://api.fda.gov/drug/enforcement.json"
DEVICE_URL = "https://api.fda.gov/device/enforcement.json"

# Press-release list can update the same day. Cache half an hour.
TTL_NOTICE = 1800
TTL_ENFORCE = 3600
POOL = 5
NEW_DAYS = 14

MONTHS = [
    "", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC",
]
MONTH_LEN = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

# Category marks on the product page only. Alert is text-only.

# 9x13 fork — long tines, solid neck, thick handle.
ICON_FOOD = """
.#..#..#.
.#..#..#.
.#..#..#.
.#..#..#.
.#######.
...###...
...###...
...###...
...###...
...###...
...###...
..#####..
..#####..
"""

# 9x13 capsule, band across the middle.
ICON_DRUG = """
...###...
..#...#..
..#...#..
..#...#..
..#####..
..#####..
..#...#..
..#...#..
..#...#..
..#...#..
...###...
...###...
.........
"""

# 9x13 medical plus.
ICON_DEVICE = """
...###...
...###...
...###...
#########
#########
#########
...###...
...###...
...###...
.........
.........
.........
.........
"""

# ---------- inputs / strings ----------

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def decode_entities(s):
    t = str(s)
    t = t.replace("&amp;", "&")
    t = t.replace("&nbsp;", " ")
    t = t.replace("&lt;", "<")
    t = t.replace("&gt;", ">")
    t = t.replace("&quot;", "\"")
    t = t.replace("&#39;", "'")
    t = t.replace("&apos;", "'")
    return t

def collapse_ws(s):
    s = decode_entities(str(s))
    s = s.replace("\n", " ").replace("\r", " ").replace("\t", " ")
    s = s.replace("&", " AND ")
    for _ in range(40):
        if s.find("  ") < 0:
            break
        s = s.replace("  ", " ")
    return s.strip()

def strip_tags(s):
    out = ""
    i = 0
    n = len(s)
    for _ in range(n + 1):
        if i >= n:
            break
        lt = s.find("<", i)
        if lt < 0:
            out = out + s[i:]
            break
        out = out + s[i:lt]
        gt = s.find(">", lt)
        if gt < 0:
            break
        i = gt + 1
    return collapse_ws(out)

def safe_upper(s):
    return collapse_ws(s).upper()

def field(rec, key, fallback = ""):
    if rec == None:
        return fallback
    v = rec.get(key, fallback)
    if v == None:
        return fallback
    return collapse_ws(str(v))

def ends_with(s, suf):
    n = len(suf)
    if n == 0:
        return True
    if len(s) < n:
        return False
    return s[len(s) - n:] == suf

def starts_with(s, pre):
    n = len(pre)
    if n == 0:
        return True
    if len(s) < n:
        return False
    return s[:n] == pre

def digits_only(s):
    out = ""
    t = str(s)
    for i in range(len(t)):
        if t[i].isdigit():
            out = out + t[i]
    return out

def to_int(s):
    t = digits_only(s)
    if t == "":
        return 0
    return int(t)

def ymd_int(s):
    t = digits_only(s)
    if len(t) < 8:
        return 0
    return int(t[:8])

def split_ymd(n):
    y = n // 10000
    m = (n // 100) % 100
    d = n % 100
    return y, m, d

def ymd_ord(n):
    y, m, d = split_ymd(n)
    if y < 1 or m < 1 or m > 12 or d < 1:
        return 0
    leap = 0
    if y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
        leap = 1
    days = y * 365 + y // 4 - y // 100 + y // 400
    i = 1
    for _ in range(12):
        if i >= m:
            break
        extra = 0
        if i == 2:
            extra = leap
        days = days + MONTH_LEN[i] + extra
        i = i + 1
    return days + d

def fmt_date(n):
    if n <= 0:
        return ""
    y, m, d = split_ymd(n)
    if m < 1 or m > 12:
        return str(n)
    return MONTHS[m] + " " + str(d)

def now_ymd(ctx):
    return ctx.now.year * 10000 + ctx.now.month * 100 + ctx.now.day

def is_new(rec, ctx):
    rd = rec["report_n"]
    if rd <= 0:
        return False
    delta = ymd_ord(now_ymd(ctx)) - ymd_ord(rd)
    return delta >= 0 and delta <= NEW_DAYS

# ---------- classification / category ----------

def category_choice(ctx):
    v = _s(ctx, "category", "ALL").upper()
    if v == "FOOD":
        return "FOOD"
    if v == "DRUGS" or v == "DRUG":
        return "DRUGS"
    if v == "DEVICES" or v == "DEVICE":
        return "DEVICES"
    return "ALL"

def severity_choice(ctx):
    v = _s(ctx, "severity", "ALL").upper()
    if v == "CLASS I" or v == "CLASS 1" or v == "I":
        return "Class I"
    if v == "CLASS II" or v == "CLASS 2" or v == "II":
        return "Class II"
    if v == "CLASS III" or v == "CLASS 3" or v == "III":
        return "Class III"
    return ""

def class_key(raw):
    u = safe_upper(raw)
    # Check III, then II, then I — "CLASS I" is a prefix of the others.
    if u.find("CLASS III") >= 0 or u == "III":
        return "III"
    if u.find("CLASS II") >= 0 or u == "II":
        return "II"
    if u.find("CLASS I") >= 0 or u == "I":
        return "I"
    if u.find("NOT YET") >= 0 or u.find("UNCLASS") >= 0 or u.find("PENDING") >= 0:
        return "PENDING"
    return "PENDING"

def class_rank(key):
    if key == "I":
        return 4
    if key == "II":
        return 3
    if key == "III":
        return 2
    return 1

def class_color(key):
    if key == "I":
        return "red"
    if key == "II":
        return "orange"
    if key == "III":
        return "yellow"
    return "skyblue"

def class_dim(key):
    if key == "I":
        return "#5A0000"
    if key == "II":
        return "#3D2200"
    if key == "III":
        return "#3D3300"
    return "#102030"

def class_label(key):
    if key == "I":
        return "CLASS I"
    if key == "II":
        return "CLASS II"
    if key == "III":
        return "CLASS III"
    return "PENDING"

def cat_from_type(product_type, fallback):
    u = safe_upper(product_type)
    if u.find("FOOD") >= 0:
        return "FOOD"
    if u.find("DRUG") >= 0:
        return "DRUGS"
    if u.find("DEVICE") >= 0:
        return "DEVICES"
    return fallback

def cat_icon(cat):
    if cat == "FOOD":
        return ICON_FOOD
    if cat == "DRUGS":
        return ICON_DRUG
    return ICON_DEVICE

def cat_word(cat):
    if cat == "FOOD":
        return "FOOD"
    if cat == "DRUGS":
        return "DRUGS"
    if cat == "DEVICES":
        return "DEVICES"
    return "RECALL"

# ---------- fetch: FDA.gov press-release table ----------

def td_text(row, marker):
    p = row.find(marker)
    if p < 0:
        return ""
    gt = row.find(">", p)
    if gt < 0:
        return ""
    end = row.find("</td>", gt)
    if end < 0:
        return ""
    return strip_tags(row[gt + 1:end])

def row_date(row):
    p = row.find("datetime=\"")
    if p >= 0:
        start = p + 10
        end = row.find("\"", start)
        if end > start:
            n = ymd_int(row[start:end])
            if n > 0:
                return n
    return ymd_int(td_text(row, "views-field-field-change-date-2"))

def parse_notice_row(row):
    brand = td_text(row, "views-field-brand-name")
    desc = td_text(row, "views-field-field-product-description-1")
    ptype = td_text(row, "views-field-field-regulated-product-field")
    reason = td_text(row, "views-field-field-recall-reason-description-1")
    firm = td_text(row, "views-field-company-name")
    if brand == "" and desc == "" and firm == "":
        return None
    terminated = td_text(row, "view-field-terminated-recall-table-column")
    status = "Ongoing"
    if terminated != "":
        status = "Terminated"
    cat = cat_from_type(ptype, "FOOD")
    report_n = row_date(row)
    return {
        "ok": True,
        "cat": cat,
        "class": "PENDING",
        "raw_class": "",
        "desc": desc,
        "reason": reason,
        "firm": firm,
        "dist": "",
        "brand": brand,
        "status": status,
        "number": "",
        "city": "",
        "state": "",
        "qty": "",
        "report_n": report_n,
        "class_n": 0,
        "init_n": report_n,
        "source": "notice",
    }

def parse_notice_table(body):
    start = body.find("id=\"datatable\"")
    if start < 0:
        start = body.find("<tbody>")
    else:
        start = body.find("<tbody>", start)
    if start < 0:
        return []
    end = body.find("</tbody>", start)
    if end < 0:
        return []
    tbody = body[start:end]
    rows = []
    i = 0
    for _ in range(80):
        p = tbody.find("<tr", i)
        if p < 0:
            break
        q = tbody.find("</tr>", p)
        if q < 0:
            break
        parsed = parse_notice_row(tbody[p:q])
        if parsed != None:
            rows.append(parsed)
        i = q + 5
    return rows

def fetch_notices():
    r = http.get(NOTICE_URL, headers = NOTICE_HEADERS, ttl_seconds = TTL_NOTICE)
    code = r["status_code"]
    if code == 0:
        return None
    if code != 200:
        return None
    body = r["body"]
    if body == None or body == "":
        return None
    rows = parse_notice_table(str(body))
    return rows

def notice_matches(rec, cat):
    if cat == "ALL":
        return True
    return rec["cat"] == cat

# ---------- fetch: openFDA enforcement (fallback / class filter) ----------

def fetch_endpoint(url, cat, class_term):
    params = {
        "sort": "report_date:desc",
        "limit": str(POOL),
    }
    if class_term != "":
        params["search"] = "classification:\"" + class_term + "\""
    r = http.get(url, headers = ENFORCE_HEADERS, params = params, ttl_seconds = TTL_ENFORCE)
    code = r["status_code"]
    if code == 0:
        return None
    if code == 404:
        return []
    if code != 200:
        return None
    data = r["json"]
    if data == None:
        return None
    results = data.get("results", None)
    if results == None:
        return None
    if type(results) != "list":
        return None
    out = []
    for rec in results:
        parsed = parse_record(rec, cat)
        if parsed != None:
            out.append(parsed)
    return out

def parse_record(rec, cat):
    if rec == None:
        return None
    desc = field(rec, "product_description")
    reason = field(rec, "reason_for_recall")
    firm = field(rec, "recalling_firm")
    dist = field(rec, "distribution_pattern")
    status = field(rec, "status")
    number = field(rec, "recall_number")
    raw_class = field(rec, "classification")
    ptype = field(rec, "product_type")
    city = field(rec, "city")
    state = field(rec, "state")
    qty = field(rec, "product_quantity")
    report_n = ymd_int(field(rec, "report_date"))
    class_n = ymd_int(field(rec, "center_classification_date"))
    init_n = ymd_int(field(rec, "recall_initiation_date"))
    got_cat = cat_from_type(ptype, cat)
    key = class_key(raw_class)
    return {
        "ok": True,
        "cat": got_cat,
        "class": key,
        "raw_class": raw_class,
        "desc": desc,
        "reason": reason,
        "firm": firm,
        "dist": dist,
        "status": status,
        "number": number,
        "city": city,
        "state": state,
        "qty": qty,
        "report_n": report_n,
        "class_n": class_n,
        "init_n": init_n,
        "brand": "",
        "source": "enforcement",
    }

def is_ongoing(rec):
    return safe_upper(rec["status"]) == "ONGOING"

def rec_score(rec):
    # Newest weekly Enforcement Report first. Prefer an Ongoing record over a
    # terminated one, then the most recently initiated recall in that week.
    # Class is a later tie-break so an old Class I does not bury a newer filing.
    live = 0
    if is_ongoing(rec):
        live = 1
    return (
        rec["report_n"],
        live,
        rec["init_n"],
        class_rank(rec["class"]),
        rec["number"],
    )

def better(a, b):
    if a == None:
        return b
    if b == None:
        return a
    sa = rec_score(a)
    sb = rec_score(b)
    i = 0
    for _ in range(5):
        if sb[i] > sa[i]:
            return b
        if sb[i] < sa[i]:
            return a
        i = i + 1
    return a

def pick_newest(pool):
    best = None
    for rec in pool:
        best = better(best, rec)
    return best

def empty_fail(reason):
    return {"ok": False, "reason": reason}

def load_enforcement(ctx, cat, class_term):
    food = None
    drug = None
    device = None
    if cat == "ALL" or cat == "FOOD":
        food = fetch_endpoint(FOOD_URL, "FOOD", class_term)
    if cat == "ALL" or cat == "DRUGS":
        drug = fetch_endpoint(DRUG_URL, "DRUGS", class_term)
    if cat == "ALL" or cat == "DEVICES":
        device = fetch_endpoint(DEVICE_URL, "DEVICES", class_term)

    fetched = []
    failed = 0
    if cat == "ALL" or cat == "FOOD":
        if food == None:
            failed = failed + 1
        elif food != []:
            fetched.append(food)
    if cat == "ALL" or cat == "DRUGS":
        if drug == None:
            failed = failed + 1
        elif drug != []:
            fetched.append(drug)
    if cat == "ALL" or cat == "DEVICES":
        if device == None:
            failed = failed + 1
        elif device != []:
            fetched.append(device)

    pool = []
    for bunch in fetched:
        for rec in bunch:
            pool.append(rec)

    wanted = 1
    if cat == "ALL":
        wanted = 3
    if pool == []:
        if failed >= wanted:
            return empty_fail("FDA DATA UNAVAILABLE")
        if class_term != "":
            return empty_fail("NO MATCHING RECALLS")
        return empty_fail("NO RECALLS FOUND")

    return pick_newest(pool)

def finish_rec(rec, ctx):
    if rec["ok"]:
        rec["new"] = is_new(rec, ctx)
        extra = rec["brand"]
        if extra == "":
            extra = rec["class"]
        print(
            "RECALL", rec["source"], rec["cat"], extra,
            rec["report_n"], rec["desc"][:60],
        )
    return rec

def load_recall(ctx):
    cat = category_choice(ctx)
    # Always prefer the FDA.gov press-release table (same order as the
    # website). Class I/II/III is not on that list; using openFDA for a
    # class filter showed week-old enforcement rows instead of today's notice.
    notices = fetch_notices()
    if notices != None:
        for rec in notices:
            if notice_matches(rec, cat):
                return finish_rec(rec, ctx)

    rec = load_enforcement(ctx, cat, severity_choice(ctx))
    return finish_rec(rec, ctx)

# ---------- text extraction (from official fields only) ----------

def cut_at(s, markers):
    best = s
    for m in markers:
        p = s.find(m)
        if p >= 12:
            chunk = s[:p].strip()
            if len(chunk) < len(best):
                best = chunk
    return best

def product_headline(desc):
    if desc == "":
        return "PRODUCT NOT LISTED"
    s = collapse_ws(desc)
    such = safe_upper(s).find("SUCH AS ")
    if such >= 0:
        rest = s[such + 8:].strip()
        if rest != "":
            s = rest
    s = cut_at(s, [" labeled as:", " labelled as:", " labeled as "])
    # First sentence when it looks like a product name, not a paragraph.
    p = s.find(". ")
    if p >= 12 and p <= 90:
        s = s[:p]
    s = cut_at(s, [" 1)", " 1.", "\t1)"])
    if len(s) > 90:
        c = s.find(", ")
        if c >= 12:
            s = s[:c]
    s = safe_upper(s)
    if ends_with(s, "."):
        s = s[:len(s) - 1].strip()
    if s == "":
        return "PRODUCT NOT LISTED"
    return s

def strip_reason_prefix(s):
    u = s
    prefixes = [
        "THE PRODUCT WAS RECALLED BECAUSE ",
        "PRODUCT WAS RECALLED BECAUSE ",
        "RECALLED BECAUSE ",
        "RECALL INITIATED BECAUSE ",
        "THE FIRM RECALLED THE PRODUCT BECAUSE ",
        "FIRM RECALLED THE PRODUCT BECAUSE ",
        "PRODUCTS MAY BE ",
        "PRODUCT MAY BE ",
        "THE PRODUCTS MAY BE ",
        "THE PRODUCT MAY BE ",
        "MAY BE ",
        "DUE TO ",
        "BECAUSE ",
    ]
    for pre in prefixes:
        if starts_with(u, pre):
            u = u[len(pre):]
            break
    return u.strip()

def reason_headline(reason):
    if reason == "":
        return "REASON NOT LISTED"
    s = collapse_ws(reason)
    s = safe_upper(s)
    s = strip_reason_prefix(s)
    if ends_with(s, "."):
        s = s[:len(s) - 1].strip()
    if s == "":
        return "REASON NOT LISTED"
    return s

def reason_short(reason):
    s = reason_headline(reason)
    if s == "REASON NOT LISTED":
        return s
    prefixes = [
        "POTENTIAL FOR CONTAMINATION WITH ",
        "POTENTIAL TO BE CONTAMINATED WITH ",
        "POTENTIAL FOR CONTAMINATION ",
        "POTENTIAL TO BE ",
        "POTENTIAL FOR ",
        "CONTAMINATION WITH ",
    ]
    for pre in prefixes:
        if starts_with(s, pre):
            s = s[len(pre):].strip()
            break
    for mark in [": ", "; ", " - ", " -- "]:
        p = s.find(mark)
        if p >= 8 and p <= 36:
            s = s[:p].strip()
            break
    return s

def strip_paren_tail(s):
    p = s.find(" (")
    if p >= 8:
        return s[:p].strip()
    return s

def details_title(rec):
    brand = strip_paren_tail(safe_upper(rec["brand"]))
    if brand != "":
        cleaned = firm_headline(brand)
        if cleaned != "FIRM NOT LISTED":
            return cleaned
        return brand
    firm = strip_paren_tail(firm_headline(rec["firm"]))
    if firm != "FIRM NOT LISTED":
        return firm
    product = product_headline(rec["desc"])
    if product != "PRODUCT NOT LISTED":
        return product
    return "FDA RECALL"

def firm_headline(firm):
    if firm == "":
        return "FIRM NOT LISTED"
    s = safe_upper(firm)
    suffixes = [
        ", INC.", " INC.", ", LLC.", ", LLC", " LLC", ", INC", " INC",
        ", L.P.", " L.P.", ", LP", " LP", " CORPORATION", " CORP.",
        ", CORP", " CORP", ", CO.", " CO.", ", LTD.", " LTD.", " LTD",
        ", P.A.", " P.A.",
        ", GMBH", " GMBH", ", AG", " AG",
    ]
    for suf in suffixes:
        if ends_with(s, suf):
            s = s[:len(s) - len(suf)].strip()
            break
    if s == "":
        return "FIRM NOT LISTED"
    return s

def dist_headline(dist, state):
    if dist == "":
        if state != "":
            return safe_upper(state)
        return "AREA NOT LISTED"
    u = safe_upper(dist)
    if u.find("NATIONWIDE") >= 0:
        return "NATIONWIDE"
    if u.find("THROUGHOUT THE UNITED STATES") >= 0:
        return "NATIONWIDE"
    if u.find("UNITED STATES") >= 0 and u.find("STATE") < 0:
        return "NATIONWIDE"
    p = u.find("ONLY IN ")
    if p >= 0:
        rest = u[p + 8:].strip()
        for m in [".", ",", ";", "/"]:
            cut = rest.find(m)
            if cut > 0:
                rest = rest[:cut].strip()
                break
        if rest != "":
            return rest
    p = u.find("THE FOLLOWING STATES:")
    if p >= 0:
        rest = u[p + 21:].strip()
        rest = rest.replace(".", "")
        states = rest.split(",")
        if len(states) == 1:
            one = states[0].strip()
            if one != "":
                return one
        if len(states) >= 2:
            return "MULTI-STATE"
    if state != "":
        return safe_upper(state)
    return u

# ---------- layout helpers ----------

def join_words(words, a, b):
    out = words[a]
    for i in range(a + 1, b):
        out = out + " " + words[i]
    return out

def wrap2(c, text, font, maxw):
    w = c.text_width(text, font)
    words = text.split(" ")
    if w <= maxw and (w + 18 <= maxw or len(words) < 2):
        return [text]
    # Keep "(SOFT RICOTTA)" together by wrapping after a closing paren.
    p = text.find(") ")
    if p > 0:
        a = text[:p + 1]
        b = text[p + 2:]
        if b != "" and c.text_width(a, font) <= maxw and c.text_width(b, font) <= maxw:
            return [a, b]
    if len(words) < 2:
        return []
    best = []
    best_score = 100000
    for i in range(1, len(words)):
        a = join_words(words, 0, i)
        b = join_words(words, i, len(words))
        wa = c.text_width(a, font)
        wb = c.text_width(b, font)
        if wa <= maxw and wb <= maxw:
            score = wa - wb
            if score < 0:
                score = -score
            if ends_with(a, "(") or starts_with(b, "("):
                score = score + 50
            if ends_with(a, ")") or ends_with(a, ","):
                score = score - 80
            if best == [] or score < best_score:
                best = [a, b]
                best_score = score
    if best != []:
        return best
    if w <= maxw:
        return [text]
    return []

def wrap_n(c, text, font, maxw, max_lines):
    words = text.split(" ")
    if len(words) == 0:
        return []
    if c.text_width(words[0], font) > maxw:
        return []
    lines = []
    cur = words[0]
    for i in range(1, len(words)):
        cand = cur + " " + words[i]
        if c.text_width(cand, font) <= maxw:
            cur = cand
        else:
            lines.append(cur)
            cur = words[i]
            if c.text_width(cur, font) > maxw:
                lines.append(ellipsis(c, cur, font, maxw))
                return lines[:max_lines]
            if len(lines) >= max_lines:
                rest = cur
                j = i + 1
                for _ in range(len(words) - i):
                    if j >= len(words):
                        break
                    rest = rest + " " + words[j]
                    j = j + 1
                last_i = len(lines) - 1
                lines[last_i] = ellipsis(c, lines[last_i] + " " + rest, font, maxw)
                return lines
    lines.append(cur)
    if len(lines) > max_lines:
        extra = join_words(lines, max_lines - 1, len(lines))
        lines = lines[:max_lines - 1]
        lines.append(ellipsis(c, extra, font, maxw))
    return lines

def ellipsis(c, text, font, maxw):
    if c.text_width(text, font) <= maxw:
        return text
    n = len(text)
    for i in range(n, 2, -1):
        t = text[:i].strip() + ".."
        if c.text_width(t, font) <= maxw:
            return t
    return ".."

def fit_lines(c, text, maxw, fonts, max_lines):
    if text == "":
        return ["NOT LISTED"], fonts[len(fonts) - 1]
    for font in fonts:
        if max_lines >= 2:
            lines = wrap2(c, text, font, maxw)
            if lines != []:
                return lines, font
    for font in fonts:
        lines = wrap_n(c, text, font, maxw, max_lines)
        if lines != []:
            return lines, font
    font = fonts[len(fonts) - 1]
    return [ellipsis(c, text, font, maxw)], font

def fit_lines_dense(c, text, maxw, fonts, max_lines):
    # Smaller fonts, more lines — do not jump to a 2-line 6x8 wrap.
    if text == "":
        return ["NOT LISTED"], fonts[len(fonts) - 1]
    last_font = fonts[len(fonts) - 1]
    for font in fonts:
        lines = wrap_n(c, text, font, maxw, max_lines)
        if lines == []:
            continue
        last = lines[len(lines) - 1]
        if ends_with(last, "..") and font != last_font:
            continue
        return lines, font
    lines = wrap_n(c, text, last_font, maxw, max_lines)
    if lines != []:
        return lines, last_font
    return [ellipsis(c, text, last_font, maxw)], last_font

def font_h(font):
    if font == "6x8":
        return 8
    if font == "5x7":
        return 7
    return 6

def draw_body_lines(c, lines, font, x, y, maxw, color, area_h):
    n = len(lines)
    glyph = font_h(font)
    if n >= 3:
        if font == "5x7":
            lh = 7
        else:
            lh = 6
    elif font == "6x8":
        lh = 10
    elif font == "5x7":
        lh = 9
    else:
        lh = 7
    total = glyph + (n - 1) * lh
    yy = y
    if area_h > 0 and n <= 2 and font != "4x5":
        yy = y + (area_h - total) // 2
        if yy < y:
            yy = y
    for line in lines:
        if c.text_width(line, font) <= maxw:
            c.text(line, x, yy, font = font, color = color)
        else:
            c.text_fit(ellipsis(c, line, font, maxw), x, yy, [font, "4x5"], color = color, maxw = maxw)
        yy = yy + lh

# ---------- drawing ----------

def draw_cat_mark(c, rec, x, y):
    col = class_color(rec["class"])
    if rec["class"] == "I":
        col = "white"
    c.sprite(cat_icon(rec["cat"]), x, y, color = col)

def draw_fail(c, heading, detail):
    c.fill("black")
    c.rect(0, 0, 2, c.height - 1, fill = "midgray")
    c.text("RECALL RADAR", 6, 3, font = "5x7", color = "white")
    c.text(heading.upper(), 6, 13, font = "6x8", color = "amber")
    c.text_fit(detail.upper(), 6, 23, ["5x7", "4x5"], color = "gray", maxw = 182)

def draw_frame(c, rec, thick):
    col = class_color(rec["class"])
    c.rect(0, 0, 2, c.height - 1, fill = col)
    if rec["class"] == "I" or thick:
        c.rect(0, 0, c.width - 1, c.height - 1, outline = col)
        if rec["class"] == "I":
            c.rect(1, 1, c.width - 2, c.height - 2, outline = col)

def new_badge_bg(rec):
    if rec["class"] == "I":
        return "yellow"
    return class_color(rec["class"])

def header_right_w(c, rec):
    if rec["new"]:
        return 32
    # 5x7 "DEVICES" is 41px. Extra pad so a long title cannot touch it.
    return c.text_width(rec["cat"], "5x7") + 12

def draw_clipped(c, text, x, y, maxw, fonts, color):
    for font in fonts:
        if c.text_width(text, font) <= maxw:
            c.text(text, x, y, font = font, color = color)
            return
    font = fonts[len(fonts) - 1]
    c.text(ellipsis(c, text, font, maxw), x, y, font = font, color = color)

def draw_header_right(c, rec, col, y):
    if rec["new"]:
        c.badge("NEW", c.width - 26, y, color = "black", bg = new_badge_bg(rec), font = "4x5", pad = 1)
    else:
        c.text(rec["cat"], c.width - 4, y, font = "5x7", color = col, align = "right")

def draw_header_bar(c, rec, title, ctx):
    col = class_color(rec["class"])
    # 9px bar, text at y=2 so a Class I double outline does not clip glyphs.
    c.rect(3, 0, c.width - 1, 9, fill = class_dim(rec["class"]))
    c.hline(3, 9, c.width - 3, col)
    maxw = c.width - 8 - header_right_w(c, rec)
    draw_clipped(c, title, 8, 2, maxw, ["5x7", "4x5"], "white")
    draw_header_right(c, rec, col, 1)

# ---------- pages ----------

def alert(c, ctx):
    rec = load_recall(ctx)
    c.fill("black")
    if not rec["ok"]:
        draw_fail(c, rec["reason"], "TRY AGAIN LATER")
        return

    key = rec["class"]
    col = class_color(key)

    if key == "I":
        c.rect(0, 0, c.width - 1, c.height - 1, outline = "red")
        c.rect(1, 1, c.width - 2, c.height - 2, outline = "red")
        c.rect(0, 0, c.width - 1, 9, fill = "red")
        c.text("CLASS I RECALL", 4, 1, font = "6x8", color = "white")
        if rec["new"]:
            c.badge("NEW", c.width - 26, 0, color = "black", bg = "yellow", font = "4x5", pad = 1)
        c.text(cat_word(rec["cat"]), 6, 13, font = "7x12", color = "white")
        c.text("DATA: FDA", c.width - 5, 24, font = "4x5", color = "gray", align = "right")
        return

    draw_frame(c, rec, False)
    c.text("RECALL RADAR", 6, 2, font = "5x7", color = "white")
    if rec["new"]:
        c.badge("NEW", c.width - 24, 1, color = "black", bg = col, font = "4x5", pad = 1)
    if key == "PENDING":
        c.text("FDA ALERT", 6, 12, font = "6x8", color = col)
        c.text(cat_word(rec["cat"]) + " RECALL", 6, 22, font = "5x7", color = "white")
        return
    c.text(class_label(key), 6, 12, font = "7x12", color = col)
    c.text(cat_word(rec["cat"]) + " RECALL", 6, 23, font = "5x7", color = "white")
    c.text("DATA: FDA", c.width - 4, 23, font = "4x5", color = "gray", align = "right")

def product(c, ctx):
    rec = load_recall(ctx)
    c.fill("black")
    if not rec["ok"]:
        draw_fail(c, rec["reason"], "TRY AGAIN LATER")
        return
    draw_frame(c, rec, False)
    draw_header_bar(c, rec, "PRODUCT", ctx)
    draw_cat_mark(c, rec, 5, 12)
    text = product_headline(rec["desc"])
    lines, font = fit_lines(c, text, 164, ["6x8", "5x7", "4x5"], 2)
    draw_body_lines(c, lines, font, 18, 12, 164, "white", 19)

def reason(c, ctx):
    rec = load_recall(ctx)
    c.fill("black")
    if not rec["ok"]:
        draw_fail(c, rec["reason"], "TRY AGAIN LATER")
        return
    draw_frame(c, rec, False)
    draw_header_bar(c, rec, "REASON", ctx)
    text = reason_headline(rec["reason"])
    lines, font = fit_lines_dense(c, text, 180, ["4x5"], 3)
    draw_body_lines(c, lines, font, 6, 11, 180, "white", 20)

def details(c, ctx):
    rec = load_recall(ctx)
    c.fill("black")
    if not rec["ok"]:
        draw_fail(c, rec["reason"], "TRY AGAIN LATER")
        return
    draw_frame(c, rec, False)
    col = class_color(rec["class"])
    title = details_title(rec)
    firm = firm_headline(rec["firm"])
    product = product_headline(rec["desc"])
    why = reason_short(rec["reason"])
    when = fmt_date(rec["report_n"])
    if when == "":
        when = "DATE UNKNOWN"

    c.rect(3, 0, c.width - 1, 9, fill = class_dim(rec["class"]))
    c.hline(3, 9, c.width - 3, col)
    maxw = c.width - 8 - header_right_w(c, rec)
    draw_clipped(c, title, 8, 2, maxw, ["4x5"], "white")
    draw_header_right(c, rec, col, 1)

    # Mid line is the product — more useful than repeating the firm/brand.
    mid = product
    if mid == "PRODUCT NOT LISTED" and firm != "FIRM NOT LISTED" and firm != title:
        mid = firm
    c.text(ellipsis(c, mid, "4x5", 180), 6, 13, font = "4x5", color = "white")

    date_w = c.text_width(when, "5x7")
    date_x = c.width - 4 - date_w
    why_w = date_x - 10
    if why_w < 70:
        why_w = 70
    c.text(ellipsis(c, why, "4x5", why_w), 6, 24, font = "4x5", color = col)
    c.text(when, date_x, 23, font = "5x7", color = col)
