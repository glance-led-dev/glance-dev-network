# Born Today (192x32)
#
# Famous people born on today's date: five headliners with photo, age and
# what they're known for, six more on one page, and three legends from
# history. Births come from Wikipedia's "On this day" feed; fame is ranked
# by how many Wikipedia languages cover each person (one Wikidata query
# for the whole list), boosted for Americans and Canadians and for
# entertainers and athletes (household names on a U.S. panel).
#
# GDN's ctx.now is UTC, so "today" is worked out on Eastern time.
# Otherwise the panel would flip to tomorrow's birthdays at 7 or 8 PM.

USER_AGENT = "GDN-BornToday (glance-led-panel)"
STARS = 5
ALSO = 6
ALSO_POOL = 36
LEGENDS = 3
LEGEND_POOL = 24     # history page rotates through these, LEGENDS at a time

MONTHS = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY",
          "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
DAYS = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]

# People nobody wants a birthday card for.
SKIP_WORDS = ["SS officer", "war criminal", "convicted", "general and politician", "dictator", "murderer",
              "serial killer", "porn"]
HOME_WORDS = ["American", "Canadian"]
# Household names get a boost: entertainers and athletes. Soccer "footballers"
# don't ("American football player" does, through "player").
POP_WORDS = ["actor", "actress", "singer", "rapper", "musician", "comedian", "basketball", "baseball", "hockey",
             "player", "boxer", "wrestler", "television", "host", "model", "director", "songwriter", "golfer",
             "tennis", "racing", "driver", "quarterback", "dancer"]

GOLD = "#FFC83D"
GREEN = "#5CE27A"
GRAY = "#8A8A8A"
SOFT = "#C8C8C8"

# ---------- Eastern date ----------

def days_from_civil(y, m, d):
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    z += 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return (y + 1 if m <= 2 else y), m, d

def weekday(days):
    return (days + 4) % 7

def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    return first + (7 - weekday(first)) % 7 + 7 * (n - 1)

def eastern_today(unix):
    # US rules since 2007: EDT from 2 AM the second Sunday of March (07:00
    # UTC) to 2 AM the first Sunday of November (06:00 UTC).
    y, _, _ = civil_from_days(unix // 86400)
    start = nth_sunday(y, 3, 2) * 86400 + 7 * 3600
    end = nth_sunday(y, 11, 1) * 86400 + 6 * 3600
    offset = 4 if (unix >= start and unix < end) else 5
    days = (unix - offset * 3600) // 86400
    ly, lm, ld = civil_from_days(days)
    return ly, lm, ld, weekday(days)

def eastern_hour(unix):
    y, _, _ = civil_from_days(unix // 86400)
    start = nth_sunday(y, 3, 2) * 86400 + 7 * 3600
    end = nth_sunday(y, 11, 1) * 86400 + 6 * 3600
    offset = 4 if (unix >= start and unix < end) else 5
    return (unix - offset * 3600) % 86400 // 3600

# ---------- text ----------

FOLD = {
    "á": "A", "à": "A", "â": "A", "ä": "A", "ã": "A", "å": "A", "Á": "A", "À": "A", "Ä": "A",
    "é": "E", "è": "E", "ê": "E", "ë": "E", "É": "E", "È": "E",
    "í": "I", "ì": "I", "î": "I", "ï": "I", "Í": "I",
    "ó": "O", "ò": "O", "ô": "O", "ö": "O", "õ": "O", "ø": "O", "Ó": "O", "Ö": "O",
    "ú": "U", "ù": "U", "û": "U", "ü": "U", "Ú": "U", "Ü": "U",
    "ñ": "N", "Ñ": "N", "ç": "C", "Ç": "C", "ß": "SS", "ş": "S", "ğ": "G", "ı": "I", "ō": "O",
    "’": "'", "‘": "'", "“": "\"", "”": "\"", "–": "-", "—": "-", "…": "...",
}

def clean(text):
    out = ""
    for ch in text.elems():
        if FOLD.get(ch) != None:
            out += FOLD[ch]
        elif ord(ch) < 128:
            out += ch
    return " ".join(out.upper().split())

def died_year(text):
    # "... (died 2023)" -> 2023, else None
    i = text.find("(died ")
    if i < 0:
        return None
    y = text[i + 6:].split(")")[0].strip()
    return int(y) if y.isdigit() else None

def strip_died(text):
    i = text.find(" (died")
    return text[:i] if i >= 0 else text

def fit_text(c, text, font, maxw):
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        cand = text[:i].rstrip(" ,") + ".."
        if c.text_width(cand, font) <= maxw:
            return cand
    return ""

def fit_name(c, name, font, maxw):
    # Full name, then first + last, then first initial + last, then cut.
    parts = name.split(" ")
    suffix = ""
    if len(parts) > 2 and parts[-1] in ["JR.", "SR.", "II", "III", "IV"]:
        suffix = " " + parts[-1]
        parts = parts[:-1]
    cands = [name]
    if len(parts) > 2:
        cands.append(parts[0] + " " + parts[-1] + suffix)
    if len(parts) > 1:
        cands.append(parts[0][:1] + ". " + parts[-1] + suffix)
    for n in cands:
        if c.text_width(n, font) <= maxw:
            return n
    return fit_text(c, cands[-1], font, maxw)

def short_role(c, role, font, maxw):
    # "ACTOR, PRODUCER, AND DIRECTOR" -> "ACTOR, PRODUCER" -> "ACTOR"
    # before truncating, so it never ends mid-word if a shorter form fits.
    cands = [role]
    for sep in [", AND ", " AND ", ", "]:
        if sep in role:
            cands.append(role.split(sep)[0])
    for r in cands:
        if c.text_width(r, font) <= maxw:
            return r
    return fit_text(c, role, font, maxw)

def drop_nationality(role):
    # "Spanish footballer" -> "footballer", "Scottish-American businessman"
    # -> "businessman"; the panel has no room for both.
    words = role.split(" ")
    if len(words) < 2:
        return role
    w = words[0]
    if w[:1].isupper() and ("-" in w or w.endswith("an") or w.endswith("ish") or w.endswith("ese") or w.endswith("ch") or w.endswith("i")):
        return " ".join(words[1:])
    return role

# ---------- data ----------

def fetch_births(m, d):
    resp = http.get(
        "https://en.wikipedia.org/api/rest_v1/feed/onthisday/births/%d/%d" % (m, d),
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 43200,
    )
    if resp["status_code"] != 200 or resp["json"] == None:
        return []
    return resp["json"].get("births", [])

def fetch_fame(qids, m, d):
    if len(qids) == 0:
        return {}
    q = "SELECT ?i ?s WHERE { VALUES ?i { " + " ".join(["wd:" + x for x in qids]) + " } ?i wikibase:sitelinks ?s }"
    resp = http.get(
        "https://query.wikidata.org/sparql",
        headers = {"User-Agent": USER_AGENT, "Accept": "application/sparql-results+json"},
        params = {"format": "json", "query": q, "day": "%d-%d" % (m, d)},
        ttl_seconds = 43200,
    )
    out = {}
    if resp["status_code"] != 200 or resp["json"] == None:
        return out
    for b in resp["json"].get("results", {}).get("bindings", []):
        out[b["i"]["value"].split("/")[-1]] = int(b["s"]["value"])
    return out

def get_data(ctx):
    y, m, d, wd = eastern_today(ctx.now.unix)
    births = fetch_births(m, d)
    rows = []
    for b in births:
        pages = b.get("pages", [])
        text = b.get("text", "")
        year = b.get("year")
        if len(pages) == 0 or year == None or year > y:
            continue
        skip = False
        for w in SKIP_WORDS:
            if w in text:
                skip = True
        if skip:
            continue
        p = pages[0]
        died = "(died" in text
        body = strip_died(text)
        name = body.split(", ")[0] if ", " in body else body
        role = body[len(name) + 2:] if ", " in body else ""
        low = role.lower()
        pop = False
        for w in POP_WORDS:
            if w in low:
                pop = True
        home = False
        for w in HOME_WORDS:
            if role.startswith(w + " "):
                home = True
                role = role[len(w) + 1:]
            elif w in role:
                home = True
        role = drop_nationality(role)
        thumb = p.get("thumbnail", {}).get("source")
        rows.append({
            "qid": p.get("wikibase_item"),
            "name": clean(name),
            "role": clean(role),
            "year": year,
            "age": y - year,
            "died": died,
            "dyear": died_year(text),
            "home": home,
            "pop": pop,
            "thumb": thumb,
        })
    fame = fetch_fame([r["qid"] for r in rows if r["qid"]], m, d)
    for r in rows:
        # Wikipedia languages x1.5 for American/Canadian x1.5 for entertainers and
        # athletes (kept in whole numbers: x3/x2 each).
        r["score"] = fame.get(r["qid"], 0) * (3 if r["home"] else 2) * (3 if r["pop"] else 2)
    rows = sorted(rows, key = lambda r: -r["score"])
    living = [r for r in rows if not r["died"] and r["age"] <= 105]
    legends = [r for r in rows if r["died"]]
    return {
        "y": y, "m": m, "d": d, "wd": wd,
        "living": living, "legends": legends, "total": len(births),
    }

# ---------- photo ----------
# images.weserv.nl crops the Wikipedia thumbnail to 32x32 and returns an
# uncompressed PNG as base64 text, since http.get only carries text.

ART = 32
B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
B64_VAL = {B64[i]: i for i in range(64)}

def _hex2(n):
    s = "0123456789ABCDEF"
    return s[n // 16] + s[n % 16]

def b64_bytes(text):
    out = []
    acc = 0
    bits = 0
    for ch in text.elems():
        v = B64_VAL.get(ch)
        if v == None:
            continue
        acc = (acc << 6 | v) & 0xFFFFFF
        bits += 6
        if bits >= 8:
            bits -= 8
            out.append((acc >> bits) & 0xFF)
    return out

def _u32(b, i):
    return (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3]

def abs(n):
    return -n if n < 0 else n

def png_pixels(b):
    if len(b) < 33 or b[1] != 80 or b[2] != 78 or b[3] != 71:
        return None
    w = _u32(b, 16)
    h = _u32(b, 20)
    if b[24] != 8 or (b[25] != 2 and b[25] != 6) or b[28] != 0:
        return None
    bpp = 3 if b[25] == 2 else 4
    z = []
    i = 8
    for _ in range(64):
        if i + 8 > len(b):
            break
        n = _u32(b, i)
        if b[i + 4] == 73 and b[i + 5] == 68 and b[i + 6] == 65 and b[i + 7] == 84:
            z += b[i + 8:i + 8 + n]
        i += 12 + n
    raw = []
    j = 2
    for _ in range(4096):
        if j + 5 > len(z):
            break
        hdr = z[j]
        if (hdr >> 1) & 3 != 0:
            return None
        ln = z[j + 1] | (z[j + 2] << 8)
        raw += z[j + 5:j + 5 + ln]
        j += 5 + ln
        if hdr & 1:
            break
    stride = w * bpp
    if len(raw) < h * (stride + 1):
        return None
    rows = []
    prev = [0] * stride
    for y in range(h):
        f = raw[y * (stride + 1)]
        line = raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)]
        cur = []
        for k in range(stride):
            a = cur[k - bpp] if k >= bpp else 0
            up = prev[k]
            if f == 0:
                v = line[k]
            elif f == 1:
                v = line[k] + a
            elif f == 2:
                v = line[k] + up
            elif f == 3:
                v = line[k] + (a + up) // 2
            else:
                ul = prev[k - bpp] if k >= bpp else 0
                pp = a + up - ul
                pa = abs(pp - a)
                pb = abs(pp - up)
                pc = abs(pp - ul)
                v = line[k] + (a if pa <= pb and pa <= pc else (up if pb <= pc else ul))
            cur.append(v & 0xFF)
        rows.append(["#" + _hex2(cur[x * bpp]) + _hex2(cur[x * bpp + 1]) + _hex2(cur[x * bpp + 2]) for x in range(w)])
        prev = cur
    return rows

def fetch_photo(url):
    if url == None or not url.startswith("https://"):
        return None
    resp = http.get(
        "https://images.weserv.nl/",
        headers = {"User-Agent": USER_AGENT},
        params = {"url": url[8:], "w": str(ART), "h": str(ART), "fit": "cover", "a": "attention", "sharp": "1", "output": "png", "l": "0", "encoding": "base64"},
        ttl_seconds = 604800,
    )
    body = resp.get("body", "")
    if resp["status_code"] != 200 or not body.startswith("data:image/png;base64,"):
        return None
    return png_pixels(b64_bytes(body[22:]))

def draw_photo(c, rows, x0, y0):
    for y in range(len(rows)):
        row = rows[y]
        x = 0
        for _ in range(len(row)):
            if x >= len(row):
                break
            e = x
            for _ in range(len(row)):
                if e + 1 < len(row) and row[e + 1] == row[x]:
                    e += 1
                else:
                    break
            c.rect(x0 + x, y0 + y, x0 + e, y0 + y, fill = row[x])
            x = e + 1

def initials(name):
    parts = name.split(" ")
    if len(parts) == 1:
        return parts[0][:2]
    return parts[0][:1] + parts[-1][:1]

# ---------- drawing ----------

def draw_cake(c, x, y):
    # 24x26 pixel cake: three candles, two tiers, frosting drips.
    for i in range(3):
        cx = x + 5 + i * 7
        c.rect(cx, y + 1, cx, y + 2, fill = "#FFB020")
        c.rect(cx, y, cx, y, fill = "#FFF080")
        c.rect(cx, y + 4, cx + 1, y + 9, fill = ["#5CC8FF", "#FF7AC8", "#5CE27A"][i])
    c.rect(x + 2, y + 10, x + 21, y + 16, fill = "#C77DFF")
    c.rect(x + 2, y + 10, x + 21, y + 11, fill = "#FFFFFF")
    for dx in [4, 9, 14, 19]:
        c.rect(x + dx, y + 12, x + dx, y + 13, fill = "#FFFFFF")
    c.rect(x, y + 17, x + 23, y + 24, fill = "#FF5C8A")
    c.rect(x, y + 17, x + 23, y + 18, fill = "#FFFFFF")
    for dx in [2, 7, 12, 17, 22]:
        c.rect(x + dx, y + 19, x + dx, y + 20, fill = "#FFFFFF")
    c.rect(x - 2, y + 25, x + 25, y + 25, fill = "#666666")

def no_data(c):
    c.fill("#000000")
    c.text("BORN TODAY", 96, 6, font = "7x10", color = GOLD, align = "center")
    c.text("BIRTHDAYS UNAVAILABLE", 96, 20, font = "5x7", color = GRAY, align = "center")

def intro(c, ctx):
    data = get_data(ctx)
    c.fill("#000000")
    draw_cake(c, 5, 3)
    x0 = 38
    c.text("BORN TODAY", x0, 2, font = "7x10", color = GOLD)
    date = DAYS[data["wd"]] + ", " + MONTHS[data["m"] - 1] + " " + str(data["d"])
    c.text(fit_text(c, date, "5x7", 191 - x0), x0, 14, font = "5x7", color = "#FFFFFF")
    if len(data["living"]) == 0:
        c.text("BIRTHDAYS UNAVAILABLE", x0, 25, font = "4x5", color = GRAY)
        return
    top = data["living"][0]
    tail = " TURNS " + str(top["age"])
    nm = fit_text(c, top["name"], "4x5", 191 - x0 - c.text_width(tail, "4x5"))
    c.text(nm, x0, 25, font = "4x5", color = SOFT)
    c.text(tail, x0 + c.text_width(nm, "4x5"), 25, font = "4x5", color = GREEN)

def draw_star(c, ctx, index):
    data = get_data(ctx)
    if index >= len(data["living"]):
        no_data(c)
        return
    p = data["living"][index]
    c.fill("#000000")
    rows = fetch_photo(p["thumb"])
    if rows != None:
        draw_photo(c, rows, 0, 0)
    else:
        c.gradient_rect(0, 0, 31, 31, "#3A3A5A", "#15152A", horizontal = False)
        c.text(initials(p["name"]), 16, 10, font = "7x10", color = "#BBBBDD", align = "center")
    x0 = 36
    maxw = 191 - x0
    if c.text_width(p["name"], "7x10") <= maxw:
        c.text(p["name"], x0, 1, font = "7x10", color = GOLD)
    else:
        c.text(fit_text(c, p["name"], "5x7", maxw), x0, 3, font = "5x7", color = GOLD)
    role = p["role"]
    if c.text_width(role, "5x7") <= maxw:
        c.text(role, x0, 13, font = "5x7", color = SOFT)
    else:
        c.text(short_role(c, role, "4x7", maxw), x0, 13, font = "4x7", color = SOFT)
    c.line(x0, 22, 191, 22, "#2A2A2A")
    c.text("TURNS " + str(p["age"]) + " TODAY", x0, 25, font = "5x7", color = GREEN)
    c.text("BORN " + str(p["year"]), 191, 26, font = "4x5", color = GRAY, align = "right")

def star_1(c, ctx):
    draw_star(c, ctx, 0)

def star_2(c, ctx):
    draw_star(c, ctx, 1)

def star_3(c, ctx):
    draw_star(c, ctx, 2)

def star_4(c, ctx):
    draw_star(c, ctx, 3)

def star_5(c, ctx):
    draw_star(c, ctx, 4)

def also(c, ctx):
    data = get_data(ctx)
    # The next ALSO_POOL names after the headliners, six at a time, a new
    # six each hour; the set cycles a few times a day.
    pool = data["living"][STARS:STARS + ALSO_POOL]
    if len(pool) == 0:
        no_data(c)
        return
    sets = (len(pool) + ALSO - 1) // ALSO
    k = eastern_hour(ctx.now.unix) % sets
    people = pool[k * ALSO:(k + 1) * ALSO]
    c.fill("#000000")
    c.text("ALSO BORN TODAY", 1, 1, font = "4x5", color = GOLD)
    tag = MONTHS[data["m"] - 1][:3] + " " + str(data["d"]) + "  " + str(k + 1) + " OF " + str(sets)
    c.text(tag, 191, 1, font = "4x5", color = GRAY, align = "right")
    c.line(0, 7, 191, 7, "#333333")
    for i in range(len(people)):
        p = people[i]
        col = i // 3
        row = i % 3
        x = 1 + col * 97
        right = x + 93
        y = 9 + row * 8
        age = str(p["age"])
        aw = c.text_width(age, "5x7")
        c.text(age, right, y, font = "5x7", color = GREEN, align = "right")
        c.text(fit_name(c, p["name"], "4x7", 93 - aw - 4), x, y, font = "4x7", color = "#FFFFFF")
    c.line(96, 9, 96, 31, "#222222")

def history(c, ctx):
    data = get_data(ctx)
    # The top LEGEND_POOL legends, three at a time, a new three each hour.
    pool = data["legends"][:LEGEND_POOL]
    if len(pool) == 0:
        no_data(c)
        return
    sets = (len(pool) + LEGENDS - 1) // LEGENDS
    k = eastern_hour(ctx.now.unix) % sets
    people = pool[k * LEGENDS:(k + 1) * LEGENDS]
    c.fill("#000000")
    c.text("BORN ON THIS DAY IN HISTORY", 1, 1, font = "4x5", color = GOLD)
    c.text(str(k + 1) + " OF " + str(sets), 191, 1, font = "4x5", color = GRAY, align = "right")
    c.line(0, 7, 191, 7, "#333333")
    for i in range(len(people)):
        p = people[i]
        y = 9 + i * 8
        yrs = str(p["year"]) + ("-" + str(p["dyear"]) if p["dyear"] != None else "")
        c.text(yrs, 1, y, font = "5x7", color = GOLD)
        nx = c.text_width(yrs, "5x7") + 5
        nm = fit_name(c, p["name"], "5x7", 191 - nx)
        c.text(nm, nx, y, font = "5x7", color = "#FFFFFF")
        rx = nx + c.text_width(nm, "5x7") + 5
        role = short_role(c, p["role"], "4x5", 191 - rx) if rx < 175 else ""
        if role and not role.endswith(".."):
            c.text(role, rx, y + 1, font = "4x5", color = GRAY)     # whole words only

