# Gini Fund Ticker
#
# DESIGN. Een lopende band, links door, zoals de balk zelf schuift.
# Glance tekent per app een stilstaand beeld. Er is geen marquee en geen
# animatie in de app. De Scroll zet de pagina's van een app achter elkaar
# en schuift die beelden naar links. De docs van Glance beloven niet dat
# een letter die over de paginarand valt op de balk weer aan elkaar groeit:
# de renderer knipt stil af wat buiten het canvas valt. Daarom blijft elk
# fonds en elke melding heel binnen een pagina. Past een segment niet meer
# in de resterende breedte, dan gaat het in zijn geheel naar de volgende
# pagina. De ruimte die overblijft blijft leeg.
#
# Een fonds is een blok van twee regels dat samen verhuist. De regel
# eronder blijft binnen de breedte van de hoofdregel. Een lange melding
# wordt op spaties geknipt in stukken die elk op een pagina passen.
#
# Studio (192) gebruikt 5x7 voor de hoofdregel, met marge 6. Een ronde
# die dan langer is dan 8 pagina's, zoals een melding van 120 tekens,
# stapt naar 4x5 met marge 4. Pro (384) gebruikt 10x16 plus 6x8. Dat blok
# is 16 + 3 + 8 = 27 pixels en past in 32, met ruimte tussen de regels.
# Is de ronde langer dan 8 pagina's, dan 9x12 en daarna 6x8. Op 64 vallen
# DAG en MTD weg zodra ze het segment breder maken dan de pagina.
#
# Hoofdregel per fonds: "SCF  120.00  DAG -2.00%  MTD +2.00%".
# De code is huisoranje #F75A3E. DAG en MTD: groen bij plus, rood bij min,
# wit bij precies nul. Een melding krijgt de kleur uit het antwoord:
# wit, oranje #F75A3E, groen, rood. Glance-lettertypen kennen alleen
# hoofdletters, dus een melding verschijnt in kapitalen.
#
# Data: een verzoek per verversing, ttl 300 s, refresh 300 s.
# GET getGlanceTicker met header X-Glance-Token. Een gevulde schermcode
# gaat mee als ?screen= . Een leeg veld laat de parameter weg, want een
# lege screen= geeft 400. De code is hoofdlettergevoelig: letters,
# cijfers, koppelteken en underscore, hooguit 40 tekens.
# Antwoord 200 bepaalt de fondsen en de meldingen. Bij 401, 403, 429 of
# een dode verbinding komt het foutscherm. Bij een ander antwoord bouwt
# de app dezelfde strook uit getGlanceFundValue, een fonds per gekozen
# code, zonder meldingen. Zonder token: DEMO, geen verzoek.
#
# Meldingen komen binnen als schone ASCII, soms met kleine letters.
# De lettertypen tekenen alleen hoofdletters, dus de balk zet ze om.

TICKER_URL = "https://tasteful-fund-track-flow.base44.app/functions/getGlanceTicker"
VALUE_URL = "https://tasteful-fund-track-flow.base44.app/functions/getGlanceFundValue"

PAGES = 8
FUNDS = ["GCF", "DFF", "SCF", "IVF", "GSF"]
NAMES = {
    "GCF": "CORE FUND",
    "DFF": "DIGITAL FUTURE",
    "SCF": "SUPER COMMODITIES",
    "IVF": "INCOME VALUE",
    "GSF": "GLOBAL SOUTH",
}
MONTHS = ["JAN", "FEB", "MRT", "APR", "MEI", "JUN", "JUL", "AUG", "SEP", "OKT", "NOV", "DEC"]
SCREEN_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
HEIGHTS = {"16x20": 20, "10x16": 16, "9x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

ORANGE = "#F75A3E"
LABEL = "#8A8F9E"
WHITE = "#FFFFFF"
WARN = "#E8B04A"
SUB = "#6A7090"
TTL = 300

DEMO_FUNDS = [
    {"fund_code": "GCF", "name": "CORE FUND", "nav": "100.00", "nav_date": "2026-01-01", "daily_return": "+1.00%", "mtd_return": "-1.00%", "peildatum": "2026-01-15"},
    {"fund_code": "DFF", "name": "DIGITAL FUTURE", "nav": "110.00", "nav_date": "2026-01-01", "daily_return": "-1.00%", "mtd_return": "+1.00%", "peildatum": "2026-01-15"},
    {"fund_code": "SCF", "name": "SUPER COMMODITIES", "nav": "120.00", "nav_date": "2026-01-01", "daily_return": "-2.00%", "mtd_return": "+2.00%", "peildatum": "2026-01-15"},
    {"fund_code": "IVF", "name": "INCOME VALUE", "nav": "130.00", "nav_date": "2026-01-01", "daily_return": "+0.00%", "mtd_return": "+0.00%", "peildatum": "2026-01-15"},
    {"fund_code": "GSF", "name": "GLOBAL SOUTH", "nav": "140.00", "nav_date": "2026-01-01", "daily_return": "+0.50%", "mtd_return": "-0.50%", "peildatum": "2026-01-15"},
]
DEMO_MESSAGES = [
    {"text": "VOORBEELD MELDING", "kleur": "oranje"},
    {"text": "CIJFERS ZIJN EEN VOORBEELD", "kleur": "wit"},
]

def _s(d, key, limit):
    """Veilige string uit de JSON. Leeg of raar type wordt '--'."""
    if type(d) != "dict":
        return "--"
    v = d.get(key)
    if v == None:
        return "--"
    if type(v) == "float" or type(v) == "int":
        v = str(v)
    if type(v) != "string":
        return "--"
    v = v.strip().upper()
    if v == "" or v == "NULL" or v == "NAN":
        return "--"
    if len(v) > limit:
        v = v[:limit]
    return v


def _pct(v):
    if v == "--":
        return v
    if not v.endswith("%"):
        v = v + "%"
    if not (v.startswith("-") or v.startswith("+")):
        if _is_zero(v):
            return v
        v = "+" + v
    return v


def _is_zero(v):
    digits = v.replace("+", "").replace("-", "").replace("%", "").replace(".", "").replace(",", "").replace("0", "")
    return digits == ""


def _color(v):
    if v == "--":
        return LABEL
    if _is_zero(v):
        return WHITE
    if v.startswith("-"):
        return "red"
    return "green"


def _kleur(v):
    if v == "ORANJE":
        return ORANGE
    if v == "GROEN":
        return "green"
    if v == "ROOD":
        return "red"
    return WHITE


def _digits(s):
    if type(s) != "string" or s == "":
        return -1
    for i in range(len(s)):
        if "0123456789".find(s[i]) < 0:
            return -1
    return int(s)


def _datum(d, key):
    raw = _s(d, key, 16)
    parts = raw.split("-")
    if len(parts) != 3:
        return ""
    year = parts[0]
    month = _digits(parts[1])
    day = parts[2]
    if len(year) != 4 or _digits(year) < 0 or len(day) != 2 or _digits(day) < 0:
        return ""
    if month < 1 or month > 12:
        return ""
    return day + " " + MONTHS[month - 1]


def _clip(c, text, font, maxw):
    if text == "" or maxw < 1:
        return ""
    if c.text_width(text, font) <= maxw:
        return text
    for k in range(len(text), 0, -1):
        if c.text_width(text[:k], font) <= maxw:
            return text[:k]
    return ""


def _as_list(raw):
    if type(raw) == "list":
        return raw
    if type(raw) == "string":
        return raw.split(",")
    return []


def _known_funds(raw):
    want = []
    for item in _as_list(raw):
        for part in str(item).strip().upper().split(" "):
            p = part.strip()
            if p in FUNDS and p not in want:
                want.append(p)
    ordered = []
    for code in FUNDS:
        if code in want:
            ordered.append(code)
    return ordered


def _screen_code(raw):
    """Hoofdlettergevoelig. Leeg blijft leeg, dan gaat screen niet mee."""
    if type(raw) != "string":
        return ""
    s = raw.strip()
    out = ""
    for i in range(len(s)):
        ch = s[i]
        if SCREEN_CHARS.find(ch) >= 0:
            out = out + ch
    if len(out) > 40:
        out = out[:40]
    return out


def _specs(width):
    # gaps: tussen code, NAV, DAG, dagwaarde, MTD, mtdwaarde.
    if width >= 320:
        return [
            {"top": "10x16", "sub": "6x8", "gaps": [4, 6, 3, 6, 3]},
            {"top": "9x12", "sub": "5x7", "gaps": [4, 6, 3, 6, 3]},
            {"top": "6x8", "sub": "5x7", "gaps": [4, 6, 3, 6, 3]},
        ]
    if width >= 128:
        return [
            {"top": "5x7", "sub": "4x5", "gaps": [3, 4, 2, 4, 2]},
            {"top": "4x5", "sub": "4x5", "gaps": [2, 3, 2, 3, 2]},
        ]
    return [
        {"top": "4x5", "sub": "4x5", "gaps": [2, 2, 1, 2, 1]},
    ]


def _metrics(width, spec):
    """Marge links en rechts, en de ruimte tussen twee segmenten."""
    if width >= 320:
        return {"pad": 10, "sep": 16}
    if width >= 128:
        # 4x5 is de kleine trap voor een lange ronde. Die heeft 4 px marge
        # nodig zodat een stuk melding en het volgende fonds nog samen passen.
        if spec["top"] == "4x5":
            return {"pad": 4, "sep": 8}
        return {"pad": 6, "sep": 10}
    return {"pad": 2, "sep": 4}


def _ys(spec):
    """Twee regels in 32 px, met minstens 1 px tussen de blokken."""
    th = HEIGHTS[spec["top"]]
    sh = HEIGHTS[spec["sub"]]
    gap = 3
    if th + gap + sh > 32:
        gap = 1
    block = th + gap + sh
    y0 = (32 - block) // 2
    if y0 < 0:
        y0 = 0
    y1 = y0 + th + gap
    if y1 + sh > 32:
        y1 = 32 - sh
    if y1 < y0 + th:
        y1 = y0 + th
    return [y0, y1]


def _push(c, runs, x, y, text, font, color):
    if text == "":
        return x
    w = c.text_width(text, font)
    runs.append([x, y, text, font, w, color])
    return x + w


def _item(c, runs_local, width):
    return {"w": width, "runs": runs_local}


def _text_item(c, spec, y0, y1, headline, subline, color, subcolor, cap):
    """Twee regels als een segment. De onderregel blijft binnen het segment."""
    top = spec["top"]
    sub = spec["sub"]
    head = _clip(c, headline, top, cap)
    foot = _clip(c, subline, sub, cap)
    if head == "" and foot == "":
        return None
    runs = []
    x = _push(c, runs, 0, y0, head, top, color)
    x2 = _push(c, runs, 0, y1, foot, sub, subcolor)
    w = x
    if x2 > w:
        w = x2
    if w > cap:
        w = cap
    if w < 1:
        return None
    return _item(c, runs, w)


def _line_width(c, parts, gaps, font):
    x = 0
    n = len(parts)
    for i in range(n):
        if parts[i] != "":
            x = x + c.text_width(parts[i], font)
        if i < n - 1:
            x = x + gaps[i]
    return x


def _paint_line(c, runs, y, parts, colors, gaps, font):
    x = 0
    n = len(parts)
    for i in range(n):
        if parts[i] != "":
            x = _push(c, runs, x, y, parts[i], font, colors[i])
        if i < n - 1:
            x = x + gaps[i]
    return x


def _fund_plans(fund):
    code = fund["code"]
    nav = fund["nav"]
    daily = fund["daily"]
    mtd = fund["mtd"]
    return [
        {
            "parts": [code, nav, "DAG", daily, "MTD", mtd],
            "colors": [ORANGE, WHITE, LABEL, _color(daily), LABEL, _color(mtd)],
        },
        {
            "parts": [code, nav, "DAG", daily],
            "colors": [ORANGE, WHITE, LABEL, _color(daily)],
        },
        {
            "parts": [code, nav],
            "colors": [ORANGE, WHITE],
        },
        {
            "parts": [code],
            "colors": [ORANGE],
        },
    ]


def _choose_plan(c, plans, gaps, font, maxw):
    nplans = len(plans)
    for pi in range(nplans):
        parts = plans[pi]["parts"]
        if _line_width(c, parts, gaps, font) <= maxw:
            return plans[pi]
    last = plans[nplans - 1]
    clipped = _clip(c, last["parts"][0], font, maxw)
    return {"parts": [clipped], "colors": [ORANGE]}


def _sub_parts(c, fund, font, maxw):
    """Naam, peildatum, NAV-datum, zolang ze binnen de hoofdregel blijven."""
    candidates = []
    if fund["name"] != "" and fund["name"] != "--":
        candidates.append(fund["name"])
    if fund["peil"] != "":
        candidates.append("P " + fund["peil"])
    if fund["navd"] != "":
        candidates.append("NAV " + fund["navd"])
    chosen = []
    used = 0
    for i in range(len(candidates)):
        text = candidates[i]
        gap = 0
        if len(chosen) > 0:
            gap = 4
        room = maxw - used - gap
        if room <= 0:
            break
        if c.text_width(text, font) <= room:
            chosen.append(text)
            used = used + gap + c.text_width(text, font)
        elif len(chosen) == 0:
            clipped = _clip(c, text, font, room)
            if clipped != "":
                chosen.append(clipped)
            break
    return chosen


def _paint_sub(c, runs, y, parts, font, maxw):
    x = 0
    for i in range(len(parts)):
        text = parts[i]
        gap = 0
        if x > 0:
            gap = 4
        room = maxw - x - gap
        if room <= 0:
            break
        if c.text_width(text, font) > room:
            text = _clip(c, text, font, room)
        if text == "":
            break
        color = LABEL
        if i == 0 and text.find("P ") != 0 and text.find("NAV ") != 0:
            color = WHITE
        x = x + gap
        x = _push(c, runs, x, y, text, font, color)
    return x


def _fund_item(c, spec, y0, y1, fund, maxw):
    top = spec["top"]
    sub = spec["sub"]
    plan = _choose_plan(c, _fund_plans(fund), spec["gaps"], top, maxw)
    runs = []
    top_w = _paint_line(c, runs, y0, plan["parts"], plan["colors"], spec["gaps"], top)
    if top_w > maxw:
        top_w = maxw
    if top_w < 1:
        return None
    parts = _sub_parts(c, fund, sub, top_w)
    _paint_sub(c, runs, y1, parts, sub, top_w)
    return _item(c, runs, top_w)


def _parse_fund(d):
    code = _s(d, "fund_code", 8)
    if code == "--":
        return None
    name = _s(d, "name", 28)
    if name == "--":
        name = NAMES.get(code, "")
    return {
        "code": code,
        "name": name,
        "nav": _s(d, "nav", 12),
        "daily": _pct(_s(d, "daily_return", 12)),
        "mtd": _pct(_s(d, "mtd_return", 12)),
        "peil": _datum(d, "peildatum"),
        "navd": _datum(d, "nav_date"),
    }


def _parse_message(d):
    # _s zet om naar hoofdletters. Kleine letters tekenen anders niet.
    # 180 laat een melding van 120 tekens heel, daarna knipt de balk op woorden.
    text = _s(d, "text", 180)
    if text == "--":
        return None
    return {"text": text, "color": _kleur(_s(d, "kleur", 12))}


def _mix(funds, messages):
    """Na elke 2 fondsen de volgende melding. Wat overblijft sluit de ronde."""
    items = []
    mi = 0
    n = len(funds)
    m = len(messages)
    for i in range(n):
        items.append({"kind": "fund", "fund": funds[i]})
        if (i + 1) % 2 == 0 and mi < m:
            items.append({"kind": "msg", "msg": messages[mi]})
            mi = mi + 1
    for extra_i in range(m - mi):
        items.append({"kind": "msg", "msg": messages[mi]})
        mi = mi + 1
    return items


def _words(text):
    raw = text.split(" ")
    out = []
    for i in range(len(raw)):
        if raw[i] != "":
            out.append(raw[i])
    return out


def _fit_words(c, words, start, font, room, foot_w):
    """Zoveel hele woorden als in room passen, samen met de onderregel."""
    if foot_w > room or room < 1:
        return [0, ""]
    cur = ""
    n = 0
    remain = len(words) - start
    for k in range(remain):
        word = words[start + k]
        if cur == "":
            trial = word
        else:
            trial = cur + " " + word
        tw = c.text_width(trial, font)
        wide = tw
        if foot_w > wide:
            wide = foot_w
        if tw <= room and wide <= room:
            cur = trial
            n = k + 1
        else:
            break
    return [n, cur]


def _build_pieces(c, spec, maxw, demo, funds, messages):
    ys = _ys(spec)
    y0 = ys[0]
    y1 = ys[1]
    pieces = []
    if demo:
        demo_item = _text_item(c, spec, y0, y1, "DEMO", "VOORBEELD", ORANGE, ORANGE, maxw)
        if demo_item != None:
            pieces.append({"kind": "fixed", "item": demo_item})
    mixed = _mix(funds, messages)
    for piece in mixed:
        if piece["kind"] == "fund":
            fund_item = _fund_item(c, spec, y0, y1, piece["fund"], maxw)
            if fund_item != None:
                pieces.append({"kind": "fixed", "item": fund_item})
        else:
            words = _words(piece["msg"]["text"])
            if len(words) > 0:
                pieces.append({"kind": "msg", "words": words, "color": piece["msg"]["color"]})
    return [pieces, y0, y1]


def _stamp(pages, marks, pi, x, item):
    runs = item["runs"]
    for r in range(len(runs)):
        run = runs[r]
        pages[pi].append([x + run[0], run[1], run[2], run[3], run[4], run[5]])
    return x + item["w"]


def _put_fixed(pages, marks, pi, x, item, pad, sep, right, width):
    usable = right - pad
    if item["w"] > usable:
        return ["wide", pi, x]
    spot = x
    if x > pad:
        spot = x + sep
    if spot + item["w"] > right:
        pi = pi + 1
        if pi >= PAGES:
            return ["full", pi, x]
        x = pad
    if x > pad:
        mark = x + sep // 2
        if mark >= 0 and mark < width:
            marks[pi].append(mark)
        x = x + sep
    x = _stamp(pages, marks, pi, x, item)
    return ["ok", pi, x]


def _put_message(c, spec, pages, marks, pi, x, words, color, y0, y1, pad, sep, right, width):
    """Leg woorden in de ruimte die op de pagina over is. Een woord dat niet past gaat heel naar de volgende pagina."""
    font = spec["top"]
    foot_w = c.text_width("MELDING", spec["sub"])
    usable = right - pad
    idx = 0
    nwords = len(words)
    for guard in range(40):
        if idx >= nwords:
            break
        room = usable
        if x > pad:
            room = right - x - sep
        fitted = _fit_words(c, words, idx, font, room, foot_w)
        n = fitted[0]
        text = fitted[1]
        if n == 0 and x > pad:
            pi = pi + 1
            if pi >= PAGES:
                return ["full", pi, x]
            x = pad
        else:
            if n == 0:
                text = _clip(c, words[idx], font, usable)
                n = 1
                if text == "":
                    return ["full", pi, x]
            item = _text_item(c, spec, y0, y1, text, "MELDING", color, color, usable)
            if item == None:
                return ["full", pi, x]
            if x > pad:
                mark = x + sep // 2
                if mark >= 0 and mark < width:
                    marks[pi].append(mark)
                x = x + sep
            if x + item["w"] > right:
                return ["full", pi, x]
            x = _stamp(pages, marks, pi, x, item)
            idx = idx + n
    if idx < nwords:
        return ["full", pi, x]
    return ["ok", pi, x]


def _put_piece(c, spec, pages, marks, pi, x, piece, y0, y1, pad, sep, right, width):
    if piece["kind"] == "fixed":
        return _put_fixed(pages, marks, pi, x, piece["item"], pad, sep, right, width)
    return _put_message(c, spec, pages, marks, pi, x, piece["words"], piece["color"], y0, y1, pad, sep, right, width)


def _place(c, spec, pieces, y0, y1, metrics, partial):
    """Zet elk segment heel op een pagina. None als de ronde niet in 8 pagina's past."""
    width = c.width
    pad = metrics["pad"]
    sep = metrics["sep"]
    right = width - pad
    n = len(pieces)
    if n == 0:
        return None
    pages = []
    marks = []
    for i in range(PAGES):
        pages.append([])
        marks.append([])
    pi = 0
    x = pad
    stopped = False
    for i in range(n):
        result = _put_piece(c, spec, pages, marks, pi, x, pieces[i], y0, y1, pad, sep, right, width)
        if result[0] == "wide":
            return None
        if result[0] != "ok":
            if not partial:
                return None
            stopped = True
            break
        pi = result[1]
        x = result[2]
    if not stopped:
        idx = 0
        for guard in range(40):
            result = _put_piece(c, spec, pages, marks, pi, x, pieces[idx], y0, y1, pad, sep, right, width)
            if result[0] != "ok":
                break
            pi = result[1]
            x = result[2]
            idx = idx + 1
            if idx >= n:
                idx = 0
    bar_y = 7
    if width < 128:
        bar_y = 8
    return {"pages": pages, "marks": marks, "bar_y": bar_y}


def _try_place(c, spec, demo, funds, messages, partial):
    metrics = _metrics(c.width, spec)
    maxw = c.width - 2 * metrics["pad"]
    built = _build_pieces(c, spec, maxw, demo, funds, messages)
    return _place(c, spec, built[0], built[1], built[2], metrics, partial)


def _compose(c, demo, funds, messages):
    specs = _specs(c.width)
    for spec in specs:
        placed = _try_place(c, spec, demo, funds, messages, False)
        if placed != None:
            return placed
    if len(messages) > 0:
        for spec in specs:
            placed = _try_place(c, spec, demo, funds, [], False)
            if placed != None:
                return placed
        placed = _try_place(c, specs[len(specs) - 1], demo, funds, messages, True)
        if placed != None:
            return placed
    return _try_place(c, specs[len(specs) - 1], demo, funds, [], True)


def _inside(width, w):
    if w <= 0:
        return True
    left = (width // 2) - (w // 2)
    if left < 0:
        return False
    if left + w > width:
        return False
    return True


def _pick_line(c, text, fonts):
    n = len(fonts)
    for i in range(n):
        font = fonts[i]
        if _inside(c.width, c.text_width(text, font)):
            return [font, text]
    font = fonts[n - 1]
    shown = text
    for k in range(len(text), 0, -1):
        shown = text[:k]
        if _inside(c.width, c.text_width(shown, font)):
            return [font, shown]
    return [font, ""]


def nodata(c, title, sub, short, title_color):
    c.fill("#0B0C12")
    shown = title
    if c.width < 128 and short != "":
        shown = short
    if c.width >= 320:
        tfonts = ["16x20", "10x16", "6x8", "4x5"]
        sfonts = ["6x8", "5x7", "4x5"]
    elif c.width >= 128:
        tfonts = ["10x16", "6x8", "5x7", "4x5"]
        sfonts = ["5x7", "4x5"]
    else:
        tfonts = ["5x7", "4x5"]
        sfonts = ["4x5"]
    picked = _pick_line(c, shown, tfonts)
    spicked = _pick_line(c, sub, sfonts)
    tfont = picked[0]
    ttext = picked[1]
    sfont = spicked[0]
    stext = spicked[1]
    th = HEIGHTS[tfont]
    sh = HEIGHTS[sfont]
    gap = 3
    if th + gap + sh > c.height:
        gap = 1
    block = th + gap + sh
    y0 = (c.height - block) // 2
    if y0 < 0:
        y0 = 0
    y1 = y0 + th + gap
    if y1 + sh > c.height:
        y1 = c.height - sh
    if ttext != "":
        c.text(ttext, c.width // 2, y0, font = tfont, color = title_color, align = "center")
    if stext != "":
        c.text(stext, c.width // 2, y1, font = sfont, color = SUB, align = "center")


def _fail(status):
    if status == 401 or status == 403:
        return ["GEEN TOEGANG", "TOKEN CONTROLEREN", "GEEN TOEGANG", WARN]
    if status == 429:
        return ["TE VEEL VERZOEKEN", "EVEN WACHTEN", "TE VEEL", WARN]
    if status == 0:
        return ["GEEN VERBINDING", "PROBEER OPNIEUW", "GEEN NET", WARN]
    return None


def _blank_numbers(funds):
    if len(funds) == 0:
        return True
    for fund in funds:
        if fund["nav"] != "--" or fund["daily"] != "--" or fund["mtd"] != "--":
            return False
    return True


def _fetch_value(token, code):
    return http.get(
        VALUE_URL,
        headers = {"X-Glance-Token": token},
        params = {"fund": code},
        ttl_seconds = TTL,
    )


def _funds_from_values(token, codes):
    found = []
    status = 200
    for code in codes:
        resp = _fetch_value(token, code)
        status = resp["status_code"]
        failed = _fail(status)
        if failed != None:
            return [None, failed]
        if status == 200 and type(resp["json"]) == "dict":
            fund = _parse_fund(resp["json"])
            if fund != None:
                found.append(fund)
    if status != 200 and len(found) == 0:
        return [None, ["GEEN DATA", "FOUT " + str(status), "GEEN DATA", WARN]]
    return [found, None]


def _err(title, sub, short, color):
    return {"mode": "err", "title": title, "sub": sub, "short": short, "color": color}


def _load(c, ctx):
    # Elke pagina rendert apart. Hetzelfde verzoek deelt de cache van Glance
    # (ttl 300). Een module-variabele kan hier niet bijgewerkt worden.
    chosen = _known_funds(ctx.inputs.get("funds", "GCF"))
    if len(chosen) == 0:
        chosen = ["GCF"]
    screen = _screen_code(ctx.inputs.get("screen", ""))
    token = ctx.inputs.get("token", "")
    if type(token) != "string":
        token = ""
    token = token.strip()
    demo = token == ""
    funds = []
    messages = []
    if demo:
        for row in DEMO_FUNDS:
            fund = _parse_fund(row)
            if fund != None:
                funds.append(fund)
        for row in DEMO_MESSAGES:
            msg = _parse_message(row)
            if msg != None:
                messages.append(msg)
    else:
        params = {}
        if screen != "":
            params = {"screen": screen}
        resp = http.get(
            TICKER_URL,
            headers = {"X-Glance-Token": token},
            params = params,
            ttl_seconds = TTL,
        )
        status = resp["status_code"]
        failed = _fail(status)
        if failed != None:
            return _err(failed[0], failed[1], failed[2], failed[3])
        if status == 200 and type(resp["json"]) == "dict":
            body = resp["json"]
            raw_funds = body.get("funds")
            if type(raw_funds) == "list":
                for row in raw_funds:
                    fund = _parse_fund(row)
                    if fund != None:
                        funds.append(fund)
            raw_msgs = body.get("messages")
            if type(raw_msgs) == "list":
                for row in raw_msgs:
                    msg = _parse_message(row)
                    if msg != None:
                        messages.append(msg)
        else:
            loaded = _funds_from_values(token, chosen)
            if loaded[1] != None:
                failed = loaded[1]
                return _err(failed[0], failed[1], failed[2], failed[3])
            funds = loaded[0]
    if len(funds) == 0 and len(messages) == 0:
        return _err("NOG GEEN KOERS", "WACHT OP DATA", "GEEN KOERS", WHITE)
    if _blank_numbers(funds) and len(messages) == 0:
        return _err("NOG GEEN KOERS", "WACHT OP DATA", "GEEN KOERS", WHITE)
    placed = _compose(c, demo, funds, messages)
    if placed == None:
        return _err("NOG GEEN KOERS", "WACHT OP DATA", "GEEN KOERS", WHITE)
    return {"mode": "ok", "pages": placed["pages"], "marks": placed["marks"], "bar_y": placed["bar_y"]}


def _page(c, ctx, index):
    state = _load(c, ctx)
    if state["mode"] != "ok":
        nodata(c, state["title"], state["sub"], state["short"], state["color"])
        return
    c.fill("#000000")
    for run in state["pages"][index]:
        c.text(run[2], run[0], run[1], font = run[3], color = run[5])
    for mark in state["marks"][index]:
        c.vline(mark, state["bar_y"], 18, ORANGE)


def p0(c, ctx):
    _page(c, ctx, 0)


def p1(c, ctx):
    _page(c, ctx, 1)


def p2(c, ctx):
    _page(c, ctx, 2)


def p3(c, ctx):
    _page(c, ctx, 3)


def p4(c, ctx):
    _page(c, ctx, 4)


def p5(c, ctx):
    _page(c, ctx, 5)


def p6(c, ctx):
    _page(c, ctx, 6)


def p7(c, ctx):
    _page(c, ctx, 7)
