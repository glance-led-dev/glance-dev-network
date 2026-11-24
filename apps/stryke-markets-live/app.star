BG = "#071017"
GRID = "#1C333F"
CYAN = "#32C9DE"
GOLD = "#E8BC83"
GREEN = "#4ADE9B"
RED = "#FF7887"
BLUE = "#53ACFF"
WHITE = "#EAF5F7"
MUTED = "#8DAAB9"

ROTATION_SECONDS = 300
SNAPSHOT_URL = "https://toms.strykemarkets.com/api/v1/display/ticker"

def _snapshot():
    response = http.get(SNAPSHOT_URL, ttl_seconds=60)
    data = response["json"]
    if response["status_code"] != 200 or type(data) != "dict" or data.get("schemaVersion") != 1:
        return {}, "FEED UNAVAILABLE"
    return data, ""

def _rows(snapshot, section, key):
    group = snapshot.get(section)
    if type(group) != "dict":
        return []
    rows = group.get(key)
    return [row for row in rows if type(row) == "dict"] if type(rows) == "list" else []

# Friendly names shown in the setup app, mapped to the exact TOMS symbols.
MARKETS = {
    "EUR/USD": "EURUSD.SMX",
    "GBP/USD": "GBPUSD.SMX",
    "USD/JPY": "USDJPY.SMX",
    "USD/CHF": "USDCHF.SMX",
    "AUD/USD": "AUDUSD.SMX",
    "GOLD": "XAUUSD.SMM",
    "SILVER": "XAGUSD.SMM",
    "S&P 500": "US500.SMI",
    "NASDAQ 100": "USTECH.SMI",
    "WTI OIL": "XTIUSD.SME",
    "APPLE": "AAPL.CFD",
    "NVIDIA": "NVDA.CFD",
}

def _selected(ctx, key, rows, fields):
    # A selection arrives as "GOLD, S&P 500" (or a list); unknown names drop out.
    raw = ctx.inputs.get(key, "")
    parts = raw if type(raw) == "list" else str(raw or "").split(",")
    requested = [str(value).strip().upper() for value in parts if str(value).strip()]
    requested = [MARKETS.get(name, name) for name in requested]
    if not requested:
        return rows
    by_name = {}
    for i, row in enumerate(rows):
        for field in fields:
            name = row.get(field)
            if name and name.upper() not in by_name:
                by_name[name.upper()] = i
    selected = []
    seen = {}
    for name in requested:
        index = by_name.get(name)
        if index != None and index not in seen:
            seen[index] = True
            selected.append(rows[index])
    return selected

def _slot(ctx):
    return ctx.now.unix // ROTATION_SECONDS

def _label(value):
    if not value:
        return ""
    text = str(value).upper().replace("’", "'").replace("–", "-").replace("—", "-")
    return " ".join(text.split())

def _number(value):
    return type(value) in ["int", "float"]

def _fixed(value, digits):
    if not _number(value):
        return "--"
    digits = max(0, min(10, digits))
    scale = int("1" + "0" * digits)
    units = int(abs(value) * scale + 0.5)
    whole = str(units // scale)
    if digits:
        fraction = str(units % scale)
        whole += "." + "0" * (digits - len(fraction)) + fraction
    return ("-" if value < 0 else "") + whole

def _percent(value, digits=2):
    if not _number(value):
        return "--"
    return ("+" if value > 0 else "") + _fixed(value, digits) + "%"

def _direction(value):
    if not _number(value) or value == 0:
        return MUTED
    return GREEN if value > 0 else RED

def _points(row, key, limit):
    return [point["value"] for point in (row.get(key) or [])[-limit:] if type(point) == "dict" and _number(point.get("value"))]

def _status(c, message):
    c.text(_fit(c, message, "5x7", 112), 7, 15, font="5x7", color=MUTED)

def _background(c, incoming=True, outgoing=True):
    c.fill(BG)
    # Adjacent pages reveal the full emblem where their edges meet.
    if incoming:
        c.image("transition-in.png", 0, 0)
    if outgoing:
        c.image("transition-out.png", 121, 0)


def _fit(c, label, font, width):
    if c.text_width(label, font) <= width:
        return label
    for end in range(min(len(label), width), 0, -1):
        if c.text_width(label[:end] + "...", font) <= width:
            return label[:end] + "..."
    return "..."

def _brand(c, transitions=True):
    _background(c, incoming=transitions, outgoing=transitions)
    c.image("stryke-logo.png", 22, 1)
    for x in [8, 111]:
        c.line(x, 8, x + 8, 8, color=GRID)
        c.line(x + 2, 10, x + 6, 10, color=CYAN)
    c.text_center("THE FUTURE OF TRADING", 19, font="4x5", color=GOLD)
    c.text_center("WWW.STRYKEMARKETS.COM", 26, font="4x5", color=WHITE)

def main(c, ctx):
    _brand(c, transitions=False)

def brand_interlude(c, ctx):
    _brand(c)

def _market_title(c):
    _background(c, incoming=False)
    c.line(7, 5, 9, 5, color=CYAN)
    c.line(9, 5, 11, 1, color=CYAN)
    c.line(11, 1, 14, 8, color=CYAN)
    c.line(14, 8, 16, 4, color=CYAN)
    c.line(16, 4, 19, 4, color=CYAN)
    c.text("MARKET PULSE", 24, 1, font="5x7", color=CYAN)

def _strategy_title(c):
    _background(c)
    c.line(15, 7, 18, 4, color=GOLD)
    c.line(18, 4, 20, 6, color=GOLD)
    c.line(20, 6, 24, 1, color=GOLD)
    c.line(21, 1, 24, 1, color=GOLD)
    c.line(24, 1, 24, 4, color=GOLD)
    c.text("STRATEGY SPOTLIGHT", 120, 1, font="4x5", color=GOLD, align="right")
    c.line(32, 8, 120, 8, color="#483824")

def _volume_title(c):
    _background(c)
    c.rect(7, 0, 120, 9, fill="#10273A")
    c.text("TICK VOLUME", 67, 2, font="4x5", color=BLUE, align="center")
    for i in range(4):
        x = 103 + 4 * i
        c.rect(x, 6 - i, x + 1, 7, fill=BLUE)

def _halo_title(c):
    _background(c)
    c.rect(7, 0, 41, 9, fill="#163440")
    c.circle(11, 4, 3, CYAN)
    c.pixel(11, 4, color=CYAN)
    c.text("HALO", 17, 2, font="4x5", color=WHITE)
    c.text("TRADE IDEAS", 46, 2, font="4x5", color=CYAN)

def _chart_grid(c, left):
    for y in [14, 21, 28]:
        c.line(left, y, 119, y, color=GRID)

def _curve(c, values, left, color, shade):
    _chart_grid(c, left)
    for i in range(len(values)):
        x = left + i * (118 - left) // (len(values) - 1)
        y = 28 - values[i]
        c.line(x, y, x, 28, color=shade)
        if i > 0:
            c.line(left + (i - 1) * (118 - left) // (len(values) - 1), 28 - values[i - 1], x, y, color=color)
    x = 118
    y = 28 - values[-1]
    c.rect(x - 1, y - 1, x + 1, y + 1, fill=color)

def markets(c, ctx):
    _market_title(c)
    snapshot, error = _snapshot()
    rows = _selected(ctx, "instruments", _rows(snapshot, "marketPrices", "symbols"), ["symbol"])
    if not rows:
        _status(c, error or "NO QUOTES")
        return
    index = _slot(ctx) % len(rows)
    row = rows[index]
    bid = row.get("bid")
    digits = row.get("priceDigits")
    change = row.get("dailyChangePercent")
    price = _fixed(bid, digits if type(digits) == "int" else 2)
    font = "6x8" if c.text_width(price, "6x8") <= 59 else "4x5"
    c.text(_fit(c, _label(row.get("symbol")), "4x5", 59), 7, 11, font="4x5", color=GOLD)
    c.text(_fit(c, price, font, 59), 7, 17, font=font, color=WHITE)
    current = row.get("live") == True and _number(bid) and _utc_second(row.get("quoteAt")) != None
    c.text(_fit(c, _percent(change) if current else ("LAST QUOTE" if _number(bid) else "NO QUOTE"), "4x5", 59),
           7, 27, font="4x5", color=_direction(change) if current else MUTED)
    history = _points(row, "priceHistory", 24)
    if len(history) > 1:
        low, high = min(history), max(history)
        normalized = [8] * len(history) if low == high else [2 + int(14 * (value - low) / (high - low)) for value in history]
        _curve(c, normalized, 66, _direction(change) if current else MUTED, "#27404A")
    if len(rows) > 1:
        c.line(96, 31, 119, 31, color=GRID)
        c.pixel(96 + index * 23 // (len(rows) - 1), 31, color=CYAN)

def strategies(c, ctx):
    _strategy_title(c)
    snapshot, error = _snapshot()
    rows = _selected(ctx, "strategies", _rows(snapshot, "strategyMarketplace", "strategies"), ["id", "name"])
    if not rows:
        _status(c, error or "NO STRATEGIES")
        return
    row = rows[_slot(ctx) % len(rows)]
    archived = row.get("trackRecordSource") == "MT5_DEMO_ARCHIVE_AND_LIVE_RECORDS"
    name_width = 81 if archived else 113
    c.text(_fit(c, _label(row.get("name") or row.get("id")), "5x7", name_width), 7, 10, font="5x7", color=WHITE)
    if archived:
        c.text("ARCHIVE", 120, 12, font="3x4", color=GOLD, align="right")
    performance = row.get("performance") if row.get("verified") == True else None
    if type(performance) != "dict":
        c.text("RETURNS UNAVAILABLE", 7, 23, font="4x5", color=MUTED)
        return
    periods = ["7D", "30D", "90D"]
    values = [performance.get("return" + period.lower() + "Percent") for period in periods]
    for i in range(3):
        x = 7 + i * 38
        value = values[i]
        c.text(periods[i], x, 18, font="3x4", color=MUTED)
        c.text(_fit(c, _percent(value, 1), "4x5", 37), x, 23, font="4x5", color=_direction(value))
        c.line(x, 30, x + 33, 30, color=GRID)
        if _number(value) and value:
            length = min(15, max(1, int(abs(value))))
            c.line(x + 16, 30, x + 16 + (length if value > 0 else -length), 30, color=_direction(value))

def volume(c, ctx):
    _volume_title(c)
    snapshot, error = _snapshot()
    rows = _selected(ctx, "instruments", _rows(snapshot, "marketVolume", "symbols"), ["symbol"])
    if not rows:
        _status(c, error or "NO TICK VOLUME")
        return
    row = rows[_slot(ctx) % len(rows)]
    c.text(_fit(c, _label(row.get("symbol")), "4x5", 60), 7, 12, font="4x5", color=WHITE)
    c.text("24H", 7, 20, font="3x4", color=MUTED)
    c.text(_fit(c, _fixed(row.get("tickVolume24h"), 0), "4x5", 43), 23, 19, font="4x5", color=GOLD)
    change = row.get("tickVolumeChangePercent")
    c.text(_fit(c, _percent(change, 1), "4x5", 58), 7, 26, font="4x5", color=_direction(change))
    history = _points(row, "tickVolumeHistory", 11)
    if history:
        _chart_grid(c, 67)
        peak = max(1, max(history))
        for i in range(len(history)):
            x = 117 - 5 * (len(history) - 1 - i)
            height = int(17 * history[i] / peak)
            if height > 0:
                c.rect(x, 29 - height, x + 2, 28, fill=CYAN if i == len(history) - 1 else BLUE)

def _utc_second(value):
    if type(value) != "string" or len(value) < 20:
        return None
    if not (value.endswith("Z") or value.endswith("+00:00")):
        return None
    parts = [value[:4], value[5:7], value[8:10], value[11:13], value[14:16], value[17:19]]
    if not all([part.isdigit() for part in parts]):
        return None
    year, month, day, hour, minute, second = [int(part) for part in parts]
    if month < 1 or month > 12 or day < 1 or day > 31 or hour > 23 or minute > 59 or second > 59:
        return None
    # Gregorian calendar converted to whole UTC seconds, including leap years.
    previous = year - 1
    leap = year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
    offsets = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
    days = 365 * previous + previous // 4 - previous // 100 + previous // 400
    days += offsets[month - 1] + day - 1 + (1 if leap and month > 2 else 0)
    return (days - 719162) * 86400 + hour * 3600 + minute * 60 + second

def halo(c, ctx):
    _halo_title(c)
    snapshot, error = _snapshot()
    # Suppress an idea if it could expire before the next still frame.
    cutoff = ctx.now.unix + ROTATION_SECONDS
    rows = [row for row in _rows(snapshot, "haloTradeIdeas", "ideas")
            if (_utc_second(row.get("expiresAt")) or 0) > cutoff]
    if not rows:
        _status(c, error or "NO ACTIVE IDEAS")
        return
    row = rows[_slot(ctx) % len(rows)]
    symbol = _label(row.get("symbol"))
    side = _label(row.get("direction"))
    ratio = row.get("rewardToRisk")
    c.text(_fit(c, symbol, "5x7", 74), 7, 12, font="5x7", color=WHITE)
    c.text(_fit(c, (side + " " + _label(row.get("timeframe"))).strip(), "5x7", 74),
           7, 23, font="5x7", color=GREEN if side == "BUY" else RED)
    if _number(ratio):
        c.text("REWARD/RISK", 120, 12, font="3x4", color=MUTED, align="right")
        c.text(_fit(c, _fixed(ratio, 1) + "X", "6x8", 45), 120, 21, font="6x8", color=GOLD, align="right")

def _headline(c, title, width, y=11, lines=2):
    remaining = _label(title)
    for i in range(lines):
        if not remaining:
            return
        if i == lines - 1 or c.text_width(remaining, "4x5") <= width:
            c.text(_fit(c, remaining, "4x5", width), 7, y + i * 6, font="4x5", color=WHITE)
            return
        words = remaining.split(" ")
        line = words[0]
        count = 1
        for word in words[1:]:
            if c.text_width(line + " " + word, "4x5") > width:
                break
            line += " " + word
            count += 1
        c.text(_fit(c, line, "4x5", width), 7, y + i * 6, font="4x5", color=WHITE)
        remaining = " ".join(words[count:])

def _news(c, row, error):
    c.text("MARKET NEWS", 7, 1, font="4x7", color=WHITE)
    c.rect(108, 0, 120, 8, outline=CYAN)
    c.rect(110, 2, 112, 5, fill=CYAN)
    c.line(114, 2, 118, 2, color=CYAN)
    c.line(114, 4, 118, 4, color=CYAN)
    c.line(110, 6, 118, 6, color=CYAN)
    if not row:
        _status(c, error or "NO HEADLINES")
        return
    _headline(c, row.get("title"), 112)
    c.text(_fit(c, _label(row.get("source")), "4x5", 72), 7, 26, font="4x5", color=MUTED)
    c.text(_fit(c, _label(row.get("market")), "4x5", 39), 120, 26, font="4x5", color=CYAN, align="right")

def _insight(c, row, error):
    c.text("MARKET INSIGHTS", 120, 1, font="4x7", color=GOLD, align="right")
    c.line(9, 4, 13, 0, color=GOLD)
    c.line(13, 0, 17, 4, color=GOLD)
    c.line(17, 4, 13, 8, color=GOLD)
    c.line(13, 8, 9, 4, color=GOLD)
    c.pixel(13, 4, color=GOLD)
    if not row:
        _status(c, error or "NO INSIGHTS")
        return
    _headline(c, row.get("title"), 112)
    sentiment = _label(row.get("sentiment"))
    color = {"POSITIVE": GREEN, "NEGATIVE": RED}.get(sentiment, MUTED)
    c.text(_fit(c, sentiment or _label(row.get("market")), "4x5", 47), 7, 26, font="4x5", color=color)
    impact = _label(row.get("impact"))
    if impact:
        c.text(_fit(c, impact + " IMPACT", "4x5", 66), 120, 26, font="4x5", color=GOLD, align="right")

def market_news_and_insights(c, ctx):
    _background(c, outgoing=False)
    snapshot, error = _snapshot()
    slot = _slot(ctx)
    if slot % 2 == 0:
        rows = _rows(snapshot, "marketNews", "headlines")
        _news(c, rows[(slot // 2) % len(rows)] if rows else {}, error)
    else:
        rows = _rows(snapshot, "marketNews", "newsIq360")
        _insight(c, rows[(slot // 2) % len(rows)] if rows else {}, error)
