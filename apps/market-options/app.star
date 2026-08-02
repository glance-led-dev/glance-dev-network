# Market Options - nearest-expiry ATM call/put board + ATM±1 wings. (128x32)
#
# Pages:
#   board  — spot, expected move, chain call/put volume, ATM mids + bid-ask
#   wings  — three neighboring strikes (ATM-1 / ATM / ATM+1) call & put mids
#
# Requires a Tradier live brokerage API token. With no key, the panel shows NO DATA.
# Always hits api.tradier.com (live) — sandbox is not supported.

TRADIER_LIVE = "https://api.tradier.com/v1"

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# 5x5 arrows for the day-change (same glyphs as the stock ticker app).
UP = [[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1]]
DOWN = [[1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0], [0, 0, 1, 0, 0]]

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def resolve_symbol(ctx):
    # Dropdown presets, or free-text when Ticker == OTHER.
    sym = _s(ctx, "symbol", "SPY").upper()
    if sym == "OTHER":
        custom = _s(ctx, "custom", "").upper()
        if custom:
            return custom
        return "SPY"
    if not sym:
        return "SPY"
    return sym

def _f(v):
    # JSON null / missing -> 0.0 so math never sees None.
    if v == None:
        return 0.0
    return float(v)

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def money(v):
    # Options premiums: always show cents under $100; whole dollars above.
    if v >= 100.0:
        return str(int(v + 0.5))
    cents = int(v * 100 + 0.5)
    return str(cents // 100) + "." + pad2(cents % 100)

def spot_money(v):
    cents = int(v * 100 + 0.5)
    return str(cents // 100) + "." + pad2(cents % 100)

def pct(p):
    sign = "+" if p >= 0 else "-"
    a = p if p >= 0 else -p
    t = int(a * 10 + 0.5)
    return sign + str(t // 10) + "." + str(t % 10) + "%"

def mid_price(opt):
    bid = _f(opt.get("bid", 0))
    ask = _f(opt.get("ask", 0))
    last = _f(opt.get("last", 0))
    if bid > 0 and ask > 0:
        return (bid + ask) / 2.0
    if last > 0:
        return last
    if bid > 0:
        return bid
    if ask > 0:
        return ask
    return 0.0

def abs_f(x):
    return x if x >= 0 else -x

def auth_headers(token):
    return {
        "Authorization": "Bearer " + token,
        "Accept": "application/json",
    }

def as_list(maybe):
    # Tradier returns a bare object for one item and a list for many.
    if maybe == None:
        return []
    if type(maybe) == "list":
        return maybe
    return [maybe]

def fmt_exp(iso):
    # "2026-07-24" -> "JUL 24"
    parts = iso.split("-")
    if len(parts) != 3:
        return iso
    m = int(parts[1])
    d = int(parts[2])
    if m < 1 or m > 12:
        return iso
    return MONTHS[m - 1] + " " + str(d)

def strike_label(k):
    # 515.0 -> "515", 512.5 -> "512.5"
    if k == float(int(k)):
        return str(int(k))
    return str(k)

def fmt_ba(bid, ask):
    # Dash reads cleaner than slash on a 4x5 font.
    return money(bid) + "-" + money(ask)

def em_label(straddle):
    # Near-dated ATM straddle ≈ expected move of the underlying.
    return "+/-" + money(straddle)

def volume_tag(call_vol, put_vol):
    # Nearest-expiry chain volume. Keep the label descriptive, not directional.
    cv = call_vol
    pv = put_vol
    if cv + pv <= 0:
        return "BAL", "white"
    if cv > pv * 1.25:
        return "C VOL", "green"
    if pv > cv * 1.25:
        return "P VOL", "red"
    return "BAL", "white"

def et_session(ctx):
    # ctx.now is UTC. Tag US equity session in Eastern time.
    # Returns "" during regular hours, else PRE / AH / ON / CLOSED.
    # DST: 2nd Sunday Mar → 1st Sunday Nov (US rule), approximated by month/day.
    mo = ctx.now.month
    d = ctx.now.day
    dst = False
    if mo > 3 and mo < 11:
        dst = True
    elif mo == 3 and d >= 8:
        dst = True
    elif mo == 11 and d <= 7:
        dst = True
    off = -4 if dst else -5

    local = ctx.now.unix + off * 3600
    day = local // 86400
    # 1970-01-01 was Thursday; convert so Mon=0 ... Sun=6
    wd = int((day + 3) % 7)
    sec = local % 86400
    if sec < 0:
        sec = sec + 86400
    mins = int(sec // 60)

    if wd >= 5:
        return "CLOSED"
    if mins < 4 * 60:
        return "ON"
    if mins < 9 * 60 + 30:
        return "PRE"
    if mins < 16 * 60:
        return ""
    if mins < 20 * 60:
        return "AH"
    return "ON"

def opt_iv(opt):
    g = opt.get("greeks", None)
    if g == None:
        return 0.0
    return _f(g.get("mid_iv", 0))

def side_from_opt(opt):
    bid = _f(opt.get("bid", 0))
    ask = _f(opt.get("ask", 0))
    return {
        "k": _f(opt.get("strike", 0)),
        "mid": mid_price(opt),
        "bid": bid,
        "ask": ask,
        "vol": _f(opt.get("volume", 0)),
        "oi": _f(opt.get("open_interest", 0)),
        "iv": opt_iv(opt),
    }

def kkey(k):
    return strike_label(k)

def sort_strikes(strikes):
    # Starlark has no sorted(); bubble-sort ascending.
    n = len(strikes)
    for i in range(n):
        for j in range(n - 1 - i):
            if strikes[j] > strikes[j + 1]:
                tmp = strikes[j]
                strikes[j] = strikes[j + 1]
                strikes[j + 1] = tmp
    return strikes

def index_of_strike(strikes, k):
    for i in range(len(strikes)):
        if strikes[i] == k:
            return i
    return -1

def atm_index(strikes, spot):
    best_i = 0
    best_d = 999999999.0
    for i in range(len(strikes)):
        dist = abs_f(strikes[i] - spot)
        if dist < best_d:
            best_d = dist
            best_i = i
    return best_i

def pack_wings(strikes, call_by_k, put_by_k, spot):
    # Up to 3 neighboring strikes centered on ATM: ATM-1, ATM, ATM+1.
    if len(strikes) == 0:
        return []
    ai = atm_index(strikes, spot)
    start = ai - 1
    if start < 0:
        start = 0
    end = start + 3
    if end > len(strikes):
        end = len(strikes)
        start = end - 3
        if start < 0:
            start = 0
    wings = []
    for i in range(start, end):
        k = strikes[i]
        key = kkey(k)
        call_mid = 0.0
        put_mid = 0.0
        if key in call_by_k:
            call_mid = mid_price(call_by_k[key])
        if key in put_by_k:
            put_mid = mid_price(put_by_k[key])
        wings.append({
            "k": k,
            "call_mid": call_mid,
            "put_mid": put_mid,
            "is_atm": i == ai,
        })
    return wings

def chain_maps(opts):
    strikes = []
    call_by_k = {}
    put_by_k = {}
    for opt in opts:
        k = _f(opt.get("strike", 0))
        if k <= 0:
            continue
        key = kkey(k)
        otype = str(opt.get("option_type", "")).lower()
        if otype == "call":
            call_by_k[key] = opt
        elif otype == "put":
            put_by_k[key] = opt
        if index_of_strike(strikes, k) < 0:
            strikes.append(k)
    return sort_strikes(strikes), call_by_k, put_by_k

def chain_volume(opts):
    call_total = 0.0
    put_total = 0.0
    for opt in opts:
        vol = _f(opt.get("volume", 0))
        otype = str(opt.get("option_type", "")).lower()
        if otype == "call":
            call_total = call_total + vol
        elif otype == "put":
            put_total = put_total + vol
    return call_total, put_total

def result_from_chain(sym, spot, chg, expiry, opts):
    strikes, call_by_k, put_by_k = chain_maps(opts)
    if len(strikes) == 0:
        return {"ok": False, "title": "NO CHAIN", "sub": "NO STRIKES"}

    ai = atm_index(strikes, spot)
    atm_k = strikes[ai]
    atm_key = kkey(atm_k)
    if atm_key not in call_by_k or atm_key not in put_by_k:
        return {"ok": False, "title": "NO ATM", "sub": "NO CALL/PUT PAIR"}

    call = side_from_opt(call_by_k[atm_key])
    put = side_from_opt(put_by_k[atm_key])
    call_vol_total, put_vol_total = chain_volume(opts)
    wings = pack_wings(strikes, call_by_k, put_by_k, spot)

    return {
        "ok": True,
        "sym": sym,
        "spot": spot,
        "chg": chg,
        "expiry": expiry,
        "call_k": call["k"],
        "call_mid": call["mid"],
        "call_bid": call["bid"],
        "call_ask": call["ask"],
        "call_vol": call["vol"],
        "call_vol_total": call_vol_total,
        "call_oi": call["oi"],
        "call_iv": call["iv"],
        "put_k": put["k"],
        "put_mid": put["mid"],
        "put_bid": put["bid"],
        "put_ask": put["ask"],
        "put_vol": put["vol"],
        "put_vol_total": put_vol_total,
        "put_oi": put["oi"],
        "put_iv": put["iv"],
        "wings": wings,
    }

# ---------- tradier ----------

def fetch(ctx):
    token = _s(ctx, "apikey", "")
    sym = resolve_symbol(ctx)

    if not token:
        return {"ok": False, "title": "NO DATA", "sub": "ADD TRADIER API KEY"}
    if not sym:
        return {"ok": False, "title": "NO SYMBOL", "sub": "SET TICKER"}

    base = TRADIER_LIVE
    hdrs = auth_headers(token)

    # 1) underlying quote
    rq = http.get(
        base + "/markets/quotes",
        headers = hdrs,
        params = {"symbols": sym},
        ttl_seconds = 300,
    )
    st = rq["status_code"]
    if st == 401 or st == 403:
        return {"ok": False, "title": "BAD TOKEN", "sub": "CHECK TRADIER KEY"}
    if st == 429:
        return {"ok": False, "title": "RATE LIMITED", "sub": "TRY AGAIN LATER"}
    if st != 200:
        return {"ok": False, "title": "QUOTE FAIL", "sub": "HTTP " + str(st)}

    qj = rq["json"]
    if not qj:
        return {"ok": False, "title": "NO QUOTE", "sub": "EMPTY RESPONSE"}
    quotes = qj.get("quotes", {})
    if quotes == None:
        return {"ok": False, "title": "NO QUOTE", "sub": sym + " MISSING"}
    # Tradier uses "unmatched_symbols" when the ticker is bad.
    if quotes.get("unmatched_symbols", None) != None and quotes.get("quote", None) == None:
        return {"ok": False, "title": "BAD SYMBOL", "sub": sym + " NOT FOUND"}

    qlist = as_list(quotes.get("quote", None))
    if len(qlist) == 0:
        return {"ok": False, "title": "NO QUOTE", "sub": sym + " EMPTY"}
    q = qlist[0]
    spot = _f(q.get("last", 0))
    if spot <= 0:
        spot = _f(q.get("close", 0))
    if spot <= 0:
        return {"ok": False, "title": "NO PRICE", "sub": "NO LAST FOR " + sym}
    chg = _f(q.get("change_percentage", 0))

    # 2) expirations
    re = http.get(
        base + "/markets/options/expirations",
        headers = hdrs,
        params = {"symbol": sym},
        ttl_seconds = 3600,
    )
    st = re["status_code"]
    if st == 401 or st == 403:
        return {"ok": False, "title": "BAD TOKEN", "sub": "CHECK TRADIER KEY"}
    if st != 200:
        return {"ok": False, "title": "EXPIRY FAIL", "sub": "HTTP " + str(st)}

    ej = re["json"]
    if not ej:
        return {"ok": False, "title": "NO EXPIRIES", "sub": "EMPTY RESPONSE"}
    ex = ej.get("expirations", {})
    if ex == None:
        return {"ok": False, "title": "NO EXPIRIES", "sub": "NONE LISTED"}
    dates = as_list(ex.get("date", None))
    if len(dates) == 0:
        return {"ok": False, "title": "NO EXPIRIES", "sub": "NONE LISTED"}
    expiry = str(dates[0])

    # 3) chain for nearest expiry (greeks=true so we can show IV)
    rc = http.get(
        base + "/markets/options/chains",
        headers = hdrs,
        params = {"symbol": sym, "expiration": expiry, "greeks": "true"},
        ttl_seconds = 300,
    )
    st = rc["status_code"]
    if st == 401 or st == 403:
        return {"ok": False, "title": "BAD TOKEN", "sub": "CHECK TRADIER KEY"}
    if st != 200:
        return {"ok": False, "title": "CHAIN FAIL", "sub": "HTTP " + str(st)}

    cj = rc["json"]
    if not cj:
        return {"ok": False, "title": "NO CHAIN", "sub": "EMPTY RESPONSE"}
    opts_wrap = cj.get("options", {})
    if opts_wrap == None:
        return {"ok": False, "title": "NO CHAIN", "sub": "NULL OPTIONS"}
    opts = as_list(opts_wrap.get("option", None))
    if len(opts) == 0:
        return {"ok": False, "title": "NO CHAIN", "sub": "NO CONTRACTS"}

    return result_from_chain(sym, spot, chg, expiry, opts)

def _err(c, d):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "darkgray")
    c.text("OPTIONS", c.width // 2, 1, font = "5x7", color = "white", align = "center")
    c.text(d["title"], 4, 12, font = "6x8", color = "orange")
    c.text(d["sub"], 4, 23, font = "4x5", color = "gray")

def _top(c, d, ctx):
    up = d["chg"] >= 0
    col = "green" if up else "red"
    c.rect(0, 0, c.width - 1, 8, fill = "darkgray")

    left = d["sym"] + " " + spot_money(d["spot"])
    c.text(left, 2, 1, font = "5x7", color = "white")

    # Session tag (Eastern): blank in RTH, else PRE / AH / CLOSED
    session = et_session(ctx)
    if session:
        sx = 2 + c.text_width(left, "5x7") + 3
        # Keep the tag from colliding with the % on the right.
        max_right = c.width - 2 - c.text_width(pct(d["chg"]), "5x7") - 12
        if sx + c.text_width(session, "4x5") <= max_right:
            session_color = "#6f8cff" if session == "ON" else "orange"
            c.text(session, sx, 2, font = "4x5", color = session_color)

    # Day % with up/down arrow just to its left
    ps = pct(d["chg"])
    c.text(ps, c.width - 2, 1, font = "5x7", color = col, align = "right")
    arrow_x = c.width - 2 - c.text_width(ps, "5x7") - 7
    c.bitmap(UP if up else DOWN, arrow_x, 2, col)

def draw_option_row(c, y, side, strike, mid, bid, ask, color):
    # Three hard-bounded columns: strike 2..34, mid 38..69, B/A 74..126.
    # text_fit shrinks long strike/mid values before they can cross a boundary.
    strike_text = side + strike_label(strike)
    c.text_fit(strike_text, 2, y, ["5x7", "4x5"], color = color, maxw = 33)
    c.text_fit(money(mid), 38, y, ["5x7", "4x5"], color = color, maxw = 32)
    c.text_fit(fmt_ba(bid, ask), c.width - 2, y + 1, ["4x5"],
               color = "white", align = "right", maxw = 53)

# ---------- pages ----------

def board(c, ctx):
    d = fetch(ctx)

    c.fill("black")
    if not d["ok"]:
        _err(c, d)
        return

    _top(c, d, ctx)

    # Meta: expiry | expected move (ATM straddle) | total chain call/put volume
    straddle = d["call_mid"] + d["put_mid"]
    left_meta = fmt_exp(d["expiry"])
    skew, skew_col = volume_tag(d["call_vol_total"], d["put_vol_total"])

    c.text(left_meta, 2, 10, font = "4x5", color = "gray")
    c.text("EM" + em_label(straddle), c.width // 2, 10, font = "4x5", color = "yellow",
           align = "center")
    c.text(skew, c.width - 2, 10, font = "4x5", color = skew_col, align = "right")

    # Call / put rows with strict column boundaries.
    c.line(72, 16, 72, 31, "#242833")
    draw_option_row(c, 16, "C", d["call_k"], d["call_mid"],
                    d["call_bid"], d["call_ask"], "green")
    draw_option_row(c, 24, "P", d["put_k"], d["put_mid"],
                    d["put_bid"], d["put_ask"], "red")

def wings(c, ctx):
    # Page 2: ATM ± 1 strike mids (call row / put row).
    d = fetch(ctx)

    c.fill("black")
    if not d["ok"]:
        _err(c, d)
        return

    _top(c, d, ctx)

    ws = d.get("wings", [])
    if ws == None or len(ws) == 0:
        c.text("NO WINGS", c.width // 2, 18, font = "5x7", color = "orange", align = "center")
        return

    # C/P legends on the left so columns stay clear of labels.
    c.text("C", 1, 18, font = "4x5", color = "green")
    c.text("P", 1, 26, font = "4x5", color = "red")

    # Three columns: strike / call mid / put mid — clear of the top bar.
    n = len(ws)
    col_w = (c.width - 8) // n
    for i in range(n):
        w = ws[i]
        x = 8 + i * col_w + col_w // 2
        kcol = "yellow" if w.get("is_atm", False) else "white"
        c.text(strike_label(w["k"]), x, 10, font = "4x5", color = kcol, align = "center")
        c.text(money(w["call_mid"]), x, 16, font = "5x7", color = "green", align = "center")
        c.text(money(w["put_mid"]), x, 24, font = "5x7", color = "red", align = "center")
