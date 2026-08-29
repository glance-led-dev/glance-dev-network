# Disaster Desk — latest official FEMA disaster declaration on a 192x32 panel.
#
# Source (no API key):
#   https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries
#
# Grain: each row is a designated area (county / reservation / municipio)
# of a Stafford Act declaration. Many rows share one disasterNumber.
# The panel shows the newest unique disasterNumber after server-side
# sort ($orderby=declarationDate desc,disasterNumber desc), not each row.
#
# Not an official FEMA application. A declaration in this dataset is
# historical; it does not mean the hazard is occurring right now.
# Frames are still images; the panel advances on the manifest refresh timer.

HEADERS = {
    "User-Agent": "GlanceDisasterDesk/1.0 (GDN; official OpenFEMA display)",
    "Accept": "application/json",
}

FEMA_URL = "https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries"
SELECT = "disasterNumber,state,declarationType,declarationDate,incidentType,declarationTitle,incidentBeginDate,designatedArea,ihProgramDeclared,iaProgramDeclared,paProgramDeclared,hmProgramDeclared,femaDeclarationString"
TTL = 1800
POOL = 20
NEW_DAYS = 2

MONTHS = [
    "", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC",
]
MONTH_LEN = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

AREA = {
    "ALABAMA": "AL", "ALASKA": "AK", "ARIZONA": "AZ", "ARKANSAS": "AR",
    "CALIFORNIA": "CA", "COLORADO": "CO", "CONNECTICUT": "CT",
    "DELAWARE": "DE", "DISTRICT OF COLUMBIA": "DC", "FLORIDA": "FL",
    "GEORGIA": "GA", "HAWAII": "HI", "IDAHO": "ID", "ILLINOIS": "IL",
    "INDIANA": "IN", "IOWA": "IA", "KANSAS": "KS", "KENTUCKY": "KY",
    "LOUISIANA": "LA", "MAINE": "ME", "MARYLAND": "MD",
    "MASSACHUSETTS": "MA", "MICHIGAN": "MI", "MINNESOTA": "MN",
    "MISSISSIPPI": "MS", "MISSOURI": "MO", "MONTANA": "MT",
    "NEBRASKA": "NE", "NEVADA": "NV", "NEW HAMPSHIRE": "NH",
    "NEW JERSEY": "NJ", "NEW MEXICO": "NM", "NEW YORK": "NY",
    "NORTH CAROLINA": "NC", "NORTH DAKOTA": "ND", "OHIO": "OH",
    "OKLAHOMA": "OK", "OREGON": "OR", "PENNSYLVANIA": "PA",
    "RHODE ISLAND": "RI", "SOUTH CAROLINA": "SC", "SOUTH DAKOTA": "SD",
    "TENNESSEE": "TN", "TEXAS": "TX", "UTAH": "UT", "VERMONT": "VT",
    "VIRGINIA": "VA", "WASHINGTON": "WA", "WEST VIRGINIA": "WV",
    "WISCONSIN": "WI", "WYOMING": "WY", "AMERICAN SAMOA": "AS",
    "GUAM": "GU", "NORTHERN MARIANA ISLANDS": "MP", "PUERTO RICO": "PR",
    "VIRGIN ISLANDS": "VI",
}

STATE_NAME = {
    "AL": "ALABAMA", "AK": "ALASKA", "AZ": "ARIZONA", "AR": "ARKANSAS",
    "CA": "CALIFORNIA", "CO": "COLORADO", "CT": "CONNECTICUT",
    "DE": "DELAWARE", "DC": "DISTRICT OF COLUMBIA", "FL": "FLORIDA",
    "GA": "GEORGIA", "HI": "HAWAII", "ID": "IDAHO", "IL": "ILLINOIS",
    "IN": "INDIANA", "IA": "IOWA", "KS": "KANSAS", "KY": "KENTUCKY",
    "LA": "LOUISIANA", "ME": "MAINE", "MD": "MARYLAND",
    "MA": "MASSACHUSETTS", "MI": "MICHIGAN", "MN": "MINNESOTA",
    "MS": "MISSISSIPPI", "MO": "MISSOURI", "MT": "MONTANA",
    "NE": "NEBRASKA", "NV": "NEVADA", "NH": "NEW HAMPSHIRE",
    "NJ": "NEW JERSEY", "NM": "NEW MEXICO", "NY": "NEW YORK",
    "NC": "NORTH CAROLINA", "ND": "NORTH DAKOTA", "OH": "OHIO",
    "OK": "OKLAHOMA", "OR": "OREGON", "PA": "PENNSYLVANIA",
    "RI": "RHODE ISLAND", "SC": "SOUTH CAROLINA", "SD": "SOUTH DAKOTA",
    "TN": "TENNESSEE", "TX": "TEXAS", "UT": "UTAH", "VT": "VERMONT",
    "VA": "VIRGINIA", "WA": "WASHINGTON", "WV": "WEST VIRGINIA",
    "WI": "WISCONSIN", "WY": "WYOMING", "AS": "AMERICAN SAMOA",
    "GU": "GUAM", "MP": "N MARIANA ISLANDS", "PR": "PUERTO RICO",
    "VI": "VIRGIN ISLANDS",
}

INCIDENT_FEMA = {
    "FIRE": "Fire",
    "FLOOD": "Flood",
    "HURRICANE": "Hurricane",
    "SEVERE STORM": "Severe Storm",
    "TORNADO": "Tornado",
    "TROPICAL STORM": "Tropical Storm",
    "TYPHOON": "Typhoon",
    "WINTER STORM": "Winter Storm",
}

ICON_WARN = """
...#...
..#.#..
..#.#..
.#...#.
.#.#.#.
#.....#
#######
"""

ICON_CANE = """
..##.#.
.#..##.
#......
.##.##.
......#
.##..#.
.#.##..
"""

ICON_TORN = """
.#####.
.#####.
..###..
...#...
...#...
..#.#..
.#...#.
"""

ICON_SNOW = """
...#...
.#.#.#.
..###..
#######
..###..
.#.#.#.
...#...
"""

ICON_QUAKE = """
.......
##..#.#
..##...
#...##.
.##..#.
#..##..
.......
"""

# ---------- strings / fields ----------

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def collapse_ws(s):
    t = str(s).replace("\n", " ").replace("\r", " ").replace("\t", " ")
    t = t.replace("&", " AND ")
    for _ in range(40):
        if t.find("  ") < 0:
            break
        t = t.replace("  ", " ")
    return t.strip()

def safe_upper(s):
    return collapse_ws(s).upper()

def field(rec, key, fallback = ""):
    if rec == None:
        return fallback
    v = rec.get(key, fallback)
    if v == None:
        return fallback
    return collapse_ws(str(v))

def is_true(v):
    if v == True:
        return True
    if v == 1:
        return True
    u = str(v).strip().upper()
    return u == "TRUE" or u == "YES" or u == "1"

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
    return MONTHS[m] + " " + str(d) + " " + str(y)

def fmt_date_short(n):
    if n <= 0:
        return ""
    y, m, d = split_ymd(n)
    if m < 1 or m > 12:
        return str(n)
    return MONTHS[m] + " " + str(d)

def now_ymd(ctx):
    return ctx.now.year * 10000 + ctx.now.month * 100 + ctx.now.day

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

# ---------- inputs ----------

def area_code(ctx):
    v = safe_upper(_s(ctx, "area", "ALL USA"))
    if v == "" or v == "ALL" or v == "ALL USA" or v == "USA" or v == "US":
        return ""
    mapped = AREA.get(v, "")
    if mapped != "":
        return mapped
    if len(v) == 2:
        return v
    return ""

def incident_type(ctx):
    v = safe_upper(_s(ctx, "incident", "ALL"))
    if v == "" or v == "ALL":
        return ""
    return INCIDENT_FEMA.get(v, "")

def state_label(code, fallback):
    if code == "":
        return fallback
    name = STATE_NAME.get(code, "")
    if name != "":
        return name
    return code

# ---------- FEMA type / incident display ----------

def decl_kind(code):
    u = safe_upper(code)
    if u == "DR":
        return "DR"
    if u == "EM":
        return "EM"
    if u == "FM":
        return "FM"
    return "XX"

def decl_label(kind):
    if kind == "DR":
        return "MAJOR DISASTER"
    if kind == "EM":
        return "EMERGENCY"
    if kind == "FM":
        return "FIRE MANAGEMENT"
    return "DECLARATION"

def decl_color(kind):
    if kind == "DR":
        return "red"
    if kind == "EM":
        return "amber"
    if kind == "FM":
        return "orange"
    return "skyblue"

def decl_dim(kind):
    if kind == "DR":
        return "#3A0000"
    if kind == "EM":
        return "#3A2A00"
    if kind == "FM":
        return "#3A1A00"
    return "#102030"

def incident_key(raw):
    u = safe_upper(raw)
    if u == "FIRE":
        return "FIRE"
    if u == "FLOOD":
        return "FLOOD"
    if u == "HURRICANE":
        return "HURRICANE"
    if u == "TYPHOON":
        return "TYPHOON"
    if u == "TROPICAL STORM":
        return "TROPICAL STORM"
    if u == "TORNADO":
        return "TORNADO"
    if u == "SEVERE STORM":
        return "STORM"
    if u == "WINTER STORM" or u == "SNOWSTORM" or u == "SEVERE ICE STORM":
        return "SNOW"
    if u == "EARTHQUAKE":
        return "QUAKE"
    return "OTHER"

def incident_color(key):
    if key == "FIRE":
        return "orange"
    if key == "FLOOD":
        return "cyan"
    if key == "HURRICANE" or key == "TYPHOON" or key == "TROPICAL STORM":
        return "purple"
    if key == "TORNADO":
        return "white"
    if key == "STORM":
        return "yellow"
    if key == "SNOW":
        return "skyblue"
    if key == "QUAKE":
        return "amber"
    return "amber"

def draw_incident_icon(c, key, x, y, color):
    if key == "FIRE":
        c.icon("flame", x, y, color)
        return
    if key == "FLOOD":
        c.icon("drop", x, y, color)
        return
    if key == "STORM":
        c.icon("bolt", x, y, color)
        return
    if key == "HURRICANE" or key == "TYPHOON" or key == "TROPICAL STORM":
        c.sprite(ICON_CANE, x, y, color = color)
        return
    if key == "TORNADO":
        c.sprite(ICON_TORN, x, y, color = color)
        return
    if key == "SNOW":
        c.sprite(ICON_SNOW, x, y, color = color)
        return
    if key == "QUAKE":
        c.sprite(ICON_QUAKE, x, y, color = color)
        return
    c.sprite(ICON_WARN, x, y, color = color)

def clean_area_name(raw):
    s = safe_upper(raw)
    if s == "":
        return ""
    s = s.replace(" (COUNTY)", " COUNTY")
    s = s.replace(" (PARISH)", " PARISH")
    s = s.replace(" (BOROUGH)", " BOROUGH")
    s = s.replace(" (CENSUS AREA)", "")
    s = s.replace(" (MUNICIPALITY)", "")
    s = s.replace(" (MUNICIPIO)", "")
    s = s.replace(" (CITY)", " CITY")
    return collapse_ws(s)

def shorten_title(s):
    t = s
    t = t.replace("STRAIGHT-LINE WINDS", "WINDS")
    t = t.replace("LANDSLIDES, AND MUDSLIDES", "LANDSLIDES")
    t = t.replace("LANDSLIDES AND MUDSLIDES", "LANDSLIDES")
    t = t.replace(", AND ", " AND ")
    t = t.replace(" ,", ",")
    return collapse_ws(t)

def decl_code(rec):
    s = safe_upper(rec["code"])
    if s != "":
        return s
    kind = rec["kind"]
    num = rec["number"]
    st = rec["state"]
    if num <= 0:
        return ""
    prefix = kind
    if prefix == "XX":
        prefix = "DR"
    out = prefix + "-" + str(num)
    if st != "":
        out = out + "-" + st
    return out

# ---------- fetch ----------

def fail_rec(reason):
    return {
        "ok": False,
        "reason": reason,
        "kind": "XX",
        "number": 0,
        "state": "",
        "title": "",
        "itype": "",
        "ikey": "OTHER",
        "decl_n": 0,
        "begin_n": 0,
        "code": "",
        "area": "",
        "n_areas": 0,
        "many": False,
        "ia": False,
        "pa": False,
        "hm": False,
        "usa": True,
        "today": False,
        "new": False,
    }

def parse_row(raw):
    if raw == None:
        return None
    num = to_int(field(raw, "disasterNumber"))
    if num <= 0:
        return None
    return {
        "number": num,
        "state": safe_upper(field(raw, "state")),
        "kind": decl_kind(field(raw, "declarationType")),
        "decl_n": ymd_int(field(raw, "declarationDate")),
        "itype": field(raw, "incidentType"),
        "title": field(raw, "declarationTitle"),
        "begin_n": ymd_int(field(raw, "incidentBeginDate")),
        "area": field(raw, "designatedArea"),
        "code": field(raw, "femaDeclarationString"),
        "ih": is_true(raw.get("ihProgramDeclared", False)),
        "ia": is_true(raw.get("iaProgramDeclared", False)),
        "pa": is_true(raw.get("paProgramDeclared", False)),
        "hm": is_true(raw.get("hmProgramDeclared", False)),
    }

def unique_areas(rows):
    out = []
    for rec in rows:
        a = rec["area"]
        seen = False
        for x in out:
            if x == a:
                seen = True
                break
        if not seen and a != "":
            out.append(a)
    return out

def pick_unique(rows, usa, ctx):
    if len(rows) == 0:
        return fail_rec("EMPTY")
    first = rows[0]
    num = first["number"]
    same = []
    for rec in rows:
        if rec["number"] == num:
            same.append(rec)
    areas = unique_areas(same)
    ia = False
    pa = False
    hm = False
    for rec in same:
        if rec["ih"] or rec["ia"]:
            ia = True
        if rec["pa"]:
            pa = True
        if rec["hm"]:
            hm = True
    title = first["title"]
    if title == "":
        title = first["itype"]
    if title == "":
        title = "FEMA DECLARATION"
    area = ""
    if len(areas) > 0:
        area = clean_area_name(areas[0])
    decl_n = first["decl_n"]
    today = False
    isnew = False
    if decl_n > 0:
        delta = ymd_ord(now_ymd(ctx)) - ymd_ord(decl_n)
        if delta == 0:
            today = True
        if delta >= 0 and delta <= NEW_DAYS:
            isnew = True
    many = len(same) >= POOL
    return {
        "ok": True,
        "reason": "",
        "kind": first["kind"],
        "number": num,
        "state": first["state"],
        "title": title,
        "itype": first["itype"],
        "ikey": incident_key(first["itype"]),
        "decl_n": decl_n,
        "begin_n": first["begin_n"],
        "code": first["code"],
        "area": area,
        "n_areas": len(areas),
        "many": many,
        "ia": ia,
        "pa": pa,
        "hm": hm,
        "usa": usa,
        "today": today,
        "new": isnew,
    }

def build_filter(state, itype):
    parts = []
    if state != "":
        parts.append("state eq '" + state + "'")
    if itype != "":
        parts.append("incidentType eq '" + itype + "'")
    if len(parts) == 0:
        return ""
    if len(parts) == 1:
        return parts[0]
    return parts[0] + " and " + parts[1]

def fetch_rows(state, itype):
    params = {
        "$select": SELECT,
        "$orderby": "declarationDate desc,disasterNumber desc",
        "$top": str(POOL),
        "$metadata": "false",
    }
    filt = build_filter(state, itype)
    if filt != "":
        params["$filter"] = filt
    r = http.get(FEMA_URL, headers = HEADERS, params = params, ttl_seconds = TTL)
    code = r["status_code"]
    if code == 0:
        return None
    if code != 200:
        return None
    data = r["json"]
    if data == None:
        return None
    rows = data.get("DisasterDeclarationsSummaries", None)
    if rows == None:
        return None
    if type(rows) != "list":
        return None
    out = []
    for raw in rows:
        parsed = parse_row(raw)
        if parsed != None:
            out.append(parsed)
    return out

def load_desk(ctx):
    state = area_code(ctx)
    itype = incident_type(ctx)
    rows = fetch_rows(state, itype)
    if rows == None:
        return fail_rec("DOWN")
    if len(rows) == 0:
        return fail_rec("EMPTY")
    return pick_unique(rows, state == "", ctx)

# ---------- text fitting ----------

def join_words(words, a, b):
    out = words[a]
    for i in range(a + 1, b):
        out = out + " " + words[i]
    return out

def ellipsis(c, text, font, maxw):
    if c.text_width(text, font) <= maxw:
        return text
    n = len(text)
    for i in range(n, 2, -1):
        t = text[:i].strip() + ".."
        if c.text_width(t, font) <= maxw:
            return t
    return ".."

def wrap2(c, text, font, maxw):
    w = c.text_width(text, font)
    words = text.split(" ")
    if w <= maxw and (w + 18 <= maxw or len(words) < 2):
        return [text]
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
            if ends_with(a, ",") or ends_with(a, "&"):
                score = score - 40
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

def fit_lines(c, text, maxw, fonts, max_lines):
    if text == "":
        return ["NOT LISTED"], fonts[len(fonts) - 1]
    variants = [text]
    short = shorten_title(text)
    if short != text:
        variants.append(short)
    big = []
    small = []
    for font in fonts:
        if font == "4x5":
            small.append(font)
        else:
            big.append(font)
    # Prefer a readable face, even if the title must be shortened.
    for src in variants:
        for font in big:
            if max_lines >= 2:
                lines = wrap2(c, src, font, maxw)
                if lines != []:
                    return lines, font
    for src in variants:
        for font in big:
            lines = wrap_n(c, src, font, maxw, max_lines)
            if lines != []:
                return lines, font
    for src in variants:
        for font in small:
            if max_lines >= 2:
                lines = wrap2(c, src, font, maxw)
                if lines != []:
                    return lines, font
            lines = wrap_n(c, src, font, maxw, max_lines)
            if lines != []:
                return lines, font
    font = fonts[len(fonts) - 1]
    return [ellipsis(c, shorten_title(text), font, maxw)], font

def fit_one(c, text, fonts, maxw):
    for font in fonts:
        if c.text_width(text, font) <= maxw:
            return font, text
    font = fonts[len(fonts) - 1]
    return font, ellipsis(c, text, font, maxw)

def font_h(font):
    if font == "10x16":
        return 16
    if font == "8x12":
        return 12
    if font == "7x12":
        return 8
    if font == "6x8":
        return 8
    if font == "5x7":
        return 7
    return 6

def draw_body_lines(c, lines, font, x, y, maxw, color, area_h):
    n = len(lines)
    glyph = font_h(font)
    if n >= 3:
        lh = glyph
    elif font == "6x8":
        lh = 10
    elif font == "5x7":
        lh = 9
    else:
        lh = glyph + 1
    total = glyph + (n - 1) * lh
    yy = y
    if area_h > 0 and n <= 2:
        yy = y + (area_h - total) // 2
        if yy < y:
            yy = y
    for line in lines:
        c.text(ellipsis(c, line, font, maxw), x, yy, font = font, color = color)
        yy = yy + lh

# ---------- chrome ----------

def draw_fail(c, heading, detail):
    c.fill("#08090C")
    c.rect(0, 0, 2, c.height - 1, fill = "midgray")
    c.sprite(ICON_WARN, 6, 2, color = "gray")
    c.text("DISASTER DESK", 16, 3, font = "5x7", color = "white")
    c.text(heading.upper(), 6, 14, font = "6x8", color = "amber")
    c.text_fit(detail.upper(), 6, 24, ["5x7", "4x5"], color = "gray", maxw = 182)

def draw_shell(c, rec, thick):
    col = decl_color(rec["kind"])
    c.fill("#08090C")
    rail = 2
    if rec["kind"] == "DR" or thick:
        rail = 3
    c.rect(0, 0, rail, c.height - 1, fill = col)

def draw_clipped(c, text, x, y, maxw, fonts, color):
    font, t = fit_one(c, text, fonts, maxw)
    c.text(t, x, y, font = font, color = color)

def yesno(flag):
    if flag:
        return "YES"
    return "NO"

def aid_color(flag):
    if flag:
        return "green"
    return "gray"

def areas_label(rec):
    n = rec["n_areas"]
    if n <= 0:
        return ""
    if n == 1:
        return rec["area"]
    label = str(n) + " AREAS"
    if rec["many"]:
        label = str(n) + "+ AREAS"
    return label

# ---------- pages ----------

def alert(c, ctx):
    rec = load_desk(ctx)
    c.fill("#08090C")
    if not rec["ok"]:
        if rec["reason"] == "EMPTY":
            draw_fail(c, "NO MATCHING", "DECLARATIONS")
        else:
            draw_fail(c, "FEMA DATA", "UNAVAILABLE")
        return

    kind = rec["kind"]
    col = decl_color(kind)
    draw_shell(c, rec, kind == "DR")
    c.sprite(ICON_WARN, 6, 2, color = col)
    c.text("DISASTER DESK", 16, 3, font = "5x7", color = "white")

    right = ""
    if rec["new"]:
        c.badge("NEW", c.width - 26, 1, color = "black", bg = col, font = "4x5", pad = 1)
    elif rec["usa"]:
        right = "USA"
        c.text(right, c.width - 8, 3, font = "5x7", color = "gray", align = "right")

    place = state_label(rec["state"], "UNITED STATES")
    if rec["usa"] and rec["state"] == "":
        place = "LATEST USA"
    maxw = 182
    font, place_t = fit_one(c, place, ["8x12", "6x8", "5x7", "4x5"], maxw)
    c.text(place_t, 6, 11, font = font, color = "white")

    sub = decl_label(kind)
    if rec["today"]:
        sub = "NEW DECLARATION"
    sfont, sub_t = fit_one(c, sub, ["6x8", "5x7", "4x5"], 182)
    c.text(sub_t, 6, 24, font = sfont, color = col)

def incident(c, ctx):
    rec = load_desk(ctx)
    c.fill("#08090C")
    if not rec["ok"]:
        if rec["reason"] == "EMPTY":
            draw_fail(c, "NO MATCHING", "DECLARATIONS")
        else:
            draw_fail(c, "FEMA DATA", "UNAVAILABLE")
        return

    kind = rec["kind"]
    col = decl_color(kind)
    icol = incident_color(rec["ikey"])
    draw_shell(c, rec, False)
    c.rect(3, 0, c.width - 1, 9, fill = decl_dim(kind))
    c.hline(3, 9, c.width - 3, col)
    head = safe_upper(rec["itype"])
    if head == "":
        head = "INCIDENT"
    code = decl_code(rec)
    right_w = 0
    if code != "":
        right_w = c.text_width(code, "4x5") + 10
        c.text(code, c.width - 8, 2, font = "4x5", color = col, align = "right")
    draw_clipped(c, head, 8, 1, c.width - 12 - right_w, ["5x7", "4x5"], "white")

    draw_incident_icon(c, rec["ikey"], 6, 13, icol)
    title = safe_upper(rec["title"])
    lines, font = fit_lines(c, title, 164, ["6x8", "5x7", "4x5"], 2)
    draw_body_lines(c, lines, font, 18, 11, 164, "white", 20)

def declared(c, ctx):
    rec = load_desk(ctx)
    c.fill("#08090C")
    if not rec["ok"]:
        if rec["reason"] == "EMPTY":
            draw_fail(c, "NO MATCHING", "DECLARATIONS")
        else:
            draw_fail(c, "FEMA DATA", "UNAVAILABLE")
        return

    kind = rec["kind"]
    col = decl_color(kind)
    draw_shell(c, rec, False)
    c.rect(3, 0, c.width - 1, 9, fill = decl_dim(kind))
    c.hline(3, 9, c.width - 3, col)

    head = "DECLARED"
    if rec["today"]:
        head = "DECLARED TODAY"
    c.text(head, 8, 1, font = "5x7", color = "white")
    if rec["new"] and not rec["today"]:
        c.badge("NEW", c.width - 26, 1, color = "black", bg = col, font = "4x5", pad = 1)

    when = fmt_date(rec["decl_n"])
    if when == "":
        when = "DATE UNKNOWN"
    font, when_t = fit_one(c, when, ["8x12", "6x8", "5x7"], 182)
    c.text(when_t, 6, 12, font = font, color = col)

    code = decl_code(rec)
    if code == "":
        code = "NUMBER UNKNOWN"
    began = ""
    if rec["begin_n"] > 0 and rec["begin_n"] != rec["decl_n"]:
        began = "BEGAN " + fmt_date_short(rec["begin_n"])
    if began != "":
        c.text(code, 6, 25, font = "5x7", color = "white")
        c.text(began, c.width - 4, 25, font = "4x5", color = "gray", align = "right")
    else:
        c.text(code, 6, 25, font = "5x7", color = "white")

def aid(c, ctx):
    rec = load_desk(ctx)
    c.fill("#08090C")
    if not rec["ok"]:
        if rec["reason"] == "EMPTY":
            draw_fail(c, "NO MATCHING", "DECLARATIONS")
        else:
            draw_fail(c, "FEMA DATA", "UNAVAILABLE")
        return

    kind = rec["kind"]
    col = decl_color(kind)
    draw_shell(c, rec, False)
    c.rect(3, 0, c.width - 1, 9, fill = decl_dim(kind))
    c.hline(3, 9, c.width - 3, col)

    has_flags = rec["ia"] or rec["pa"] or rec["hm"]
    if has_flags:
        c.text("FEMA AID", 8, 1, font = "5x7", color = "white")
        if rec["n_areas"] > 1:
            more = areas_label(rec)
            c.text(more, c.width - 8, 2, font = "4x5", color = col, align = "right")
        c.text("PUBLIC", 6, 12, font = "5x7", color = "gray")
        c.text(yesno(rec["pa"]), 58, 12, font = "5x7", color = aid_color(rec["pa"]))
        c.text("INDIVIDUAL", 90, 12, font = "5x7", color = "gray")
        c.text(yesno(rec["ia"]), 156, 12, font = "5x7", color = aid_color(rec["ia"]))
        extra = rec["area"]
        if extra == "":
            extra = state_label(rec["state"], "")
        if rec["hm"]:
            extra = extra + "  HM YES"
        if extra == "":
            extra = "AREA NOT LISTED"
        draw_clipped(c, extra, 6, 24, 182, ["5x7", "4x5"], "white")
        return

    c.text("AFFECTED AREA", 8, 1, font = "5x7", color = "white")
    area = rec["area"]
    if area == "":
        area = areas_label(rec)
    if area == "":
        area = "AREA NOT LISTED"
    font, area_t = fit_one(c, area, ["6x8", "5x7", "4x5"], 182)
    c.text(area_t, 6, 12, font = font, color = "white")
    place = state_label(rec["state"], "")
    if rec["n_areas"] > 1:
        place = areas_label(rec)
    draw_clipped(c, place, 6, 24, 182, ["5x7", "4x5"], col)
