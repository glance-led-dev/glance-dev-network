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
# 300 s zit in de Glance-band 300-899: free-text en api-key mogen,
# en het aantal pagina's is niet begrensd. Schermcode blijft free-text
# omdat het een vrije id is die als ?screen= meegaat, zoals een
# station-id, niet een vaste keuzelijst.
# GET getGlanceTicker met header X-Glance-Token. Een gevulde schermcode
# gaat mee als ?screen= . Een leeg veld laat de parameter weg, want een
# lege screen= geeft 400. De code is hoofdlettergevoelig: letters,
# cijfers, koppelteken en underscore, hooguit 40 tekens.
# Antwoord 200 bepaalt de fondsen, hun top 5 holdings en de meldingen.
# Direct na elk fonds volgen tot vijf holdings: ticker, dagrendement
# (slot of mark t.o.v. vorige slot) en weging. Een holding blijft heel
# op een pagina, net als een fonds. Bij 401, 403, 429 of een dode
# verbinding komt het foutscherm. Bij een ander antwoord bouwt de app
# dezelfde strook uit getGlanceFundValue, een fonds per gekozen code,
# zonder holdings en zonder meldingen.
#
# Vier schermen. Live: antwoord 200 met fondsen of meldingen.
# Het eerste blok is GINI / FONDS, zodat de band zichzelf noemt.
# Fout: 401, 403, 429 of geen verbinding, amber, twee regels.
# Leeg: antwoord 200 zonder fondsen en zonder meldingen. Dat is geen
# fout: groen ALL CLEAR, niet de amber kaart.
# Demo: geen token, geen verzoek. Het eerste blok is DEMO / GINI SAMPLE
# en de meldingen zeggen in het Engels dat de ronde cijfers een sample
# zijn. De publieke catalogus toont die demo, nooit een live antwoord.
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
    {"fund_code": "GCF", "name": "CORE FUND", "nav": "100.00", "nav_date": "2026-01-01", "daily_return": "+1.00%", "mtd_return": "-1.00%", "peildatum": "2026-01-15", "holdings": [
        {"ticker": "IVF", "daily_return": "+0.00%", "weight_pct": "27.3%"},
        {"ticker": "GSF", "daily_return": "+0.50%", "weight_pct": "25.3%"},
        {"ticker": "SCF", "daily_return": "-2.00%", "weight_pct": "24.0%"},
        {"ticker": "DFF", "daily_return": "-1.00%", "weight_pct": "23.4%"},
    ]},
    {"fund_code": "DFF", "name": "DIGITAL FUTURE", "nav": "110.00", "nav_date": "2026-01-01", "daily_return": "-1.00%", "mtd_return": "+1.00%", "peildatum": "2026-01-15", "holdings": [
        {"ticker": "MAGS", "daily_return": "-0.04%", "weight_pct": "16.9%"},
        {"ticker": "XLK", "daily_return": "-0.34%", "weight_pct": "16.0%"},
        {"ticker": "IGV", "daily_return": "-0.76%", "weight_pct": "11.3%"},
        {"ticker": "QQQ", "daily_return": "-0.32%", "weight_pct": "10.5%"},
        {"ticker": "ETH", "daily_return": "-3.08%", "weight_pct": "9.4%"},
    ]},
    {"fund_code": "SCF", "name": "SUPER COMMODITIES", "nav": "120.00", "nav_date": "2026-01-01", "daily_return": "-2.00%", "mtd_return": "+2.00%", "peildatum": "2026-01-15", "holdings": [
        {"ticker": "GLD", "daily_return": "-2.82%", "weight_pct": "12.3%"},
        {"ticker": "URA", "daily_return": "-3.80%", "weight_pct": "11.2%"},
        {"ticker": "LIT", "daily_return": "-2.69%", "weight_pct": "9.3%"},
        {"ticker": "COPX", "daily_return": "-3.28%", "weight_pct": "7.7%"},
        {"ticker": "GDX", "daily_return": "-3.91%", "weight_pct": "6.7%"},
    ]},
    {"fund_code": "IVF", "name": "INCOME VALUE", "nav": "130.00", "nav_date": "2026-01-01", "daily_return": "+0.00%", "mtd_return": "+0.00%", "peildatum": "2026-01-15", "holdings": [
        {"ticker": "MOO", "daily_return": "-1.09%", "weight_pct": "10.2%"},
        {"ticker": "XLV", "daily_return": "-0.59%", "weight_pct": "8.0%"},
        {"ticker": "XLE", "daily_return": "+1.51%", "weight_pct": "7.9%"},
        {"ticker": "KIE", "daily_return": "-0.64%", "weight_pct": "7.4%"},
        {"ticker": "IXG", "daily_return": "-0.85%", "weight_pct": "7.1%"},
    ]},
    {"fund_code": "GSF", "name": "GLOBAL SOUTH", "nav": "140.00", "nav_date": "2026-01-01", "daily_return": "+0.50%", "mtd_return": "-0.50%", "peildatum": "2026-01-15", "holdings": [
        {"ticker": "UAE", "daily_return": "+2.38%", "weight_pct": "9.5%"},
        {"ticker": "COLO", "daily_return": "-2.67%", "weight_pct": "9.2%"},
        {"ticker": "EWW", "daily_return": "-0.12%", "weight_pct": "8.7%"},
        {"ticker": "AFK", "daily_return": "-1.99%", "weight_pct": "8.6%"},
        {"ticker": "EWS", "daily_return": "-0.69%", "weight_pct": "8.5%"},
    ]},
]
DEMO_MESSAGES = [
    {"text": "SAMPLE NOTICE", "kleur": "oranje"},
    {"text": "FIGURES ARE A SAMPLE", "kleur": "wit"},
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
        # 4x5 is de kleine trap voor een lange ronde. Zelfde 6 px rand als
        # de gewone Studio-band, zodat de safe zone ook dan blijft. Past een
        # melding niet meer naast het volgende fonds, dan gaat dat fonds heel
        # naar de volgende pagina.
        if spec["top"] == "4x5":
            return {"pad": 6, "sep": 8}
        return {"pad": 6, "sep": 10}
    return {"pad": 2, "sep": 4}


def _ys_for(top_font, sub_font, lines=2):
    """2 of 3 regels in 32 px. Drie regels als er holdings onder de kern staan."""
    th = HEIGHTS[top_font]
    sh = HEIGHTS[sub_font]
    nsub = lines - 1
    if nsub < 1:
        nsub = 1
    gap = 3
    if th + nsub * (gap + sh) > 32:
        gap = 2
    if th + nsub * (gap + sh) > 32:
        gap = 1
    if th + nsub * (gap + sh) > 32:
        gap = 0
    block = th + nsub * (gap + sh)
    y0 = (32 - block) // 2
    if y0 < 0:
        y0 = 0
    ys = [y0]
    y = y0 + th + gap
    for i in range(nsub):
        if y + sh > 32:
            y = 32 - sh
        prev_h = th if i == 0 else sh
        min_y = ys[len(ys) - 1] + prev_h
        if y < min_y:
            y = min_y
        ys.append(y)
        y = y + sh + gap
    return ys


def _ys(spec, lines=2):
    return _ys_for(spec["top"], spec["sub"], lines)


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
    """Kernregel, daaronder de top 5 holdings als die er zijn, anders naam en datum."""
    top = spec["top"]
    sub = spec["sub"]
    holds = fund.get("holdings", [])
    has = type(holds) == "list" and len(holds) > 0
    hold_font = sub
    if has:
        hold_font = _pick_hold_font(top, sub)
    packed = _pack_holding_rows(c, fund, hold_font, maxw)
    lines = 2
    if type(packed) == "list" and len(packed) > 0:
        rows = packed[0]
        if len(rows) >= 2:
            lines = 3
        elif len(rows) == 1:
            lines = 2
    else:
        hold_font = sub
    ys = _ys_for(top, hold_font, lines)
    y0 = ys[0]
    y1 = ys[1]
    plan = _choose_plan(c, _fund_plans(fund), spec["gaps"], top, maxw)
    runs = []
    top_w = _paint_line(c, runs, y0, plan["parts"], plan["colors"], spec["gaps"], top)
    if top_w > maxw:
        top_w = maxw
    if top_w < 1:
        return None
    used = top_w
    if type(packed) == "list" and len(packed) > 0:
        rows = packed[0]
        inner = packed[1]
        outer = packed[2]
        for ri in range(len(rows)):
            yi = ys[ri + 1]
            rw = _paint_holding_row(c, runs, yi, rows[ri], hold_font, inner, outer)
            if rw > used:
                used = rw
    else:
        parts = _sub_parts(c, fund, sub, top_w)
        sw = _paint_sub(c, runs, y1, parts, sub, top_w)
        if sw > used:
            used = sw
    if used > maxw:
        used = maxw
    return _item(c, runs, used)


def _weight(v):
    """Weging als percentage, zonder plus-teken (dat is geen rendement)."""
    if v == "--":
        return v
    if not v.endswith("%"):
        v = v + "%"
    if v.startswith("+"):
        v = v[1:]
    return v


def _parse_holdings(d):
    raw = d.get("holdings")
    if type(raw) != "list":
        return []
    out = []
    for i in range(len(raw)):
        row = raw[i]
        if type(row) != "dict":
            continue
        ticker = _s(row, "ticker", 8)
        if ticker == "--":
            continue
        out.append({
            "ticker": ticker,
            "daily": _pct(_s(row, "daily_return", 12)),
            "weight": _weight(_s(row, "weight_pct", 12)),
        })
        if len(out) >= 5:
            break
    return out


def _short_pct(v):
    """Eén cijfer achter de komma, behalve als dat 0.0 zou worden."""
    if v == "--":
        return v
    out = ""
    seen_dot = False
    nonzero_before = False
    kept = []
    n = len(v)
    for i in range(n):
        ch = v[i]
        if seen_dot:
            if ch >= "0" and ch <= "9":
                kept.append(ch)
                continue
            take = 1
            if not nonzero_before and len(kept) >= 2 and kept[0] == "0" and kept[1] != "0":
                take = 2
            for j in range(len(kept)):
                if j < take:
                    out = out + kept[j]
            out = out + ch
            seen_dot = False
            kept = []
            continue
        if ch >= "1" and ch <= "9" and not seen_dot:
            nonzero_before = True
        if ch == ".":
            seen_dot = True
        out = out + ch
    if seen_dot and len(kept) > 0:
        take = 1
        if not nonzero_before and len(kept) >= 2 and kept[0] == "0" and kept[1] != "0":
            take = 2
        for j in range(len(kept)):
            if j < take:
                out = out + kept[j]
    return out


def _pick_hold_font(top_font, preferred):
    """Onderfont dat samen met de kernregel en twee holdingsregels in 32 px past."""
    th = HEIGHTS[top_font]
    if preferred == "6x8":
        fonts = ["6x8", "5x7", "4x5"]
    elif preferred == "5x7":
        fonts = ["5x7", "4x5"]
    else:
        fonts = ["4x5"]
    for i in range(len(fonts)):
        f = fonts[i]
        sh = HEIGHTS[f]
        if th + 2 * (1 + sh) <= 32:
            return f
    return "4x5"


def _holding_chunk(h, mode):
    """Eén holding als drie stukken: ticker, rendement, weging."""
    ticker = h["ticker"]
    daily = h["daily"]
    weight = h["weight"]
    if mode == "short":
        daily = _short_pct(daily)
        weight = _short_pct(weight)
    elif mode == "nowt" or mode == "nowt_short":
        if mode == "nowt_short":
            daily = _short_pct(daily)
        if weight.endswith("%"):
            weight = weight[:-1]
    elif mode == "slash":
        if daily.endswith("%"):
            daily = daily[:-1]
        if weight.endswith("%"):
            weight = weight[:-1]
        daily = daily + "/"
    return [ticker, daily, weight]


def _holding_chunk_width(c, font, parts, inner_gap, outer_gap):
    w = 0
    n = len(parts)
    for i in range(n):
        if parts[i] != "":
            w = w + c.text_width(parts[i], font)
        if i < n - 1:
            w = w + inner_gap
    return w


def _try_pack_holdings(c, holds, font, maxw, mode, inner, outer):
    rows = []
    row = []
    used = 0
    for i in range(len(holds)):
        parts = _holding_chunk(holds[i], mode)
        w = _holding_chunk_width(c, font, parts, inner, outer)
        gap = 0
        if len(row) > 0:
            gap = outer
        if w > maxw:
            return []
        if used + gap + w > maxw:
            if len(row) == 0:
                return []
            rows.append(row)
            row = []
            used = 0
            gap = 0
            if len(rows) >= 2:
                return []
        row.append({"parts": parts, "daily": holds[i]["daily"], "w": w})
        used = used + gap + w
    if len(row) > 0:
        rows.append(row)
    if len(rows) == 0 or len(rows) > 2:
        return []
    return [rows, inner, outer]


def _pack_holding_rows(c, fund, font, maxw):
    """Verdeel tot vijf holdings over hooguit twee onderregels."""
    holds = fund.get("holdings", [])
    if type(holds) != "list" or len(holds) == 0:
        return []
    # Inner nooit onder 3 px, anders plakken rendement en weging aan elkaar.
    attempts = [
        ["full", 3, 8],
        ["full", 3, 6],
        ["nowt", 3, 6],
        ["nowt", 3, 4],
        ["nowt_short", 3, 6],
        ["short", 3, 6],
        ["slash", 3, 6],
    ]
    for i in range(len(attempts)):
        a = attempts[i]
        packed = _try_pack_holdings(c, holds, font, maxw, a[0], a[1], a[2])
        if type(packed) == "list" and len(packed) > 0:
            return packed
    return []


def _paint_holding_row(c, runs, y, row, font, inner, outer):
    x = 0
    n = len(row)
    for i in range(n):
        if i > 0:
            x = x + outer
        h = row[i]
        parts = h["parts"]
        daily = h["daily"]
        colors = [ORANGE, _color(daily), LABEL]
        for pi in range(len(parts)):
            if parts[pi] != "":
                x = _push(c, runs, x, y, parts[pi], font, colors[pi])
            if pi < len(parts) - 1:
                x = x + inner
    return x


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
        "holdings": _parse_holdings(d),
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
        demo_item = _text_item(c, spec, y0, y1, "DEMO", "GINI SAMPLE", ORANGE, ORANGE, maxw)
        if demo_item != None:
            pieces.append({"kind": "fixed", "item": demo_item})
    else:
        # Live heeft geen DEMO-blok. Een kort merkblok zodat de band in de
        # scroll-reeks herkenbaar is tussen de apps ervoor en erna.
        brand = _text_item(c, spec, y0, y1, "GINI", "FONDS", ORANGE, ORANGE, maxw)
        if brand != None:
            pieces.append({"kind": "fixed", "item": brand})
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


def _empty(c):
    """200 zonder fondsen en zonder meldingen. Positief, niet de amber kaart."""
    c.fill("#000000")
    title = "ALL CLEAR"
    sub = "NIETS TE MELDEN"
    if c.width >= 320:
        tfonts = ["10x16", "6x8", "5x7", "4x5"]
        sfonts = ["6x8", "5x7", "4x5"]
    elif c.width >= 128:
        tfonts = ["6x8", "5x7", "4x5"]
        sfonts = ["5x7", "4x5"]
    else:
        tfonts = ["5x7", "4x5"]
        sfonts = ["4x5"]
    picked = _pick_line(c, title, tfonts)
    spicked = _pick_line(c, sub, sfonts)
    tfont = picked[0]
    ttext = picked[1]
    sfont = spicked[0]
    stext = spicked[1]
    th = HEIGHTS[tfont]
    sh = HEIGHTS[sfont]
    gap = 3
    if th + gap + sh > c.height - 2:
        gap = 1
    block = th + gap + sh
    y0 = (c.height - block) // 2
    if y0 < 1:
        y0 = 1
    y1 = y0 + th + gap
    if y1 + sh > c.height - 1:
        y1 = c.height - 1 - sh
    if y1 < y0 + th:
        y1 = y0 + th
    if ttext != "":
        c.text(ttext, c.width // 2, y0, font = tfont, color = "green", align = "center")
    if stext != "":
        c.text(stext, c.width // 2, y1, font = sfont, color = WHITE, align = "center")


def _edge_pad(width):
    """Zelfde rand als de ticker: 10 op Pro, 6 op Studio, 1 op 64."""
    if width >= 320:
        return 10
    if width >= 128:
        return 6
    return 1


def _pick_inset(c, text, fonts, pad):
    """Grootste font dat binnen de rand past, daarna hard afkappen."""
    maxw = c.width - 2 * pad
    if maxw < 1:
        maxw = 1
    n = len(fonts)
    for i in range(n):
        font = fonts[i]
        if c.text_width(text, font) <= maxw:
            return [font, text]
    font = fonts[n - 1]
    shown = text
    for k in range(len(text), 0, -1):
        shown = text[:k]
        if c.text_width(shown, font) <= maxw:
            return [font, shown]
    return [font, ""]


def nodata(c, title, sub, short, title_color):
    c.fill("#0B0C12")
    shown = title
    if c.width < 128 and short != "":
        shown = short
    # 16x20 plus een onderregel raakt y 0 op een band van 32. 10x16 blijft
    # de held en houdt 1 px boven en onder vrij.
    if c.width >= 320:
        tfonts = ["10x16", "6x8", "5x7", "4x5"]
        sfonts = ["6x8", "5x7", "4x5"]
    elif c.width >= 128:
        tfonts = ["10x16", "6x8", "5x7", "4x5"]
        sfonts = ["5x7", "4x5"]
    else:
        tfonts = ["5x7", "4x5"]
        sfonts = ["4x5"]
    pad = _edge_pad(c.width)
    picked = _pick_inset(c, shown, tfonts, pad)
    spicked = _pick_inset(c, sub, sfonts, pad)
    tfont = picked[0]
    ttext = picked[1]
    sfont = spicked[0]
    stext = spicked[1]
    th = HEIGHTS[tfont]
    sh = HEIGHTS[sfont]
    gap = 3
    if th + gap + sh > c.height - 2:
        gap = 1
    block = th + gap + sh
    y0 = (c.height - block) // 2
    if y0 < 1:
        y0 = 1
    y1 = y0 + th + gap
    if y1 + sh > c.height - 1:
        y1 = c.height - 1 - sh
    if y1 < y0 + th:
        y1 = y0 + th
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
        return {"mode": "empty"}
    if _blank_numbers(funds) and len(messages) == 0:
        return _err("NOG GEEN KOERS", "WACHT OP DATA", "GEEN KOERS", WARN)
    placed = _compose(c, demo, funds, messages)
    if placed == None:
        return _err("TEKST TE LANG", "KORTER HOUDEN", "TE LANG", WARN)
    return {"mode": "ok", "pages": placed["pages"], "marks": placed["marks"], "bar_y": placed["bar_y"]}


def _page(c, ctx, index):
    state = _load(c, ctx)
    if state["mode"] == "empty":
        _empty(c)
        return
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
