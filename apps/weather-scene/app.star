# Weather
#
# Open-Meteo, keyed by zip. WMO weather codes collapse into eight
# drawn conditions, and the sky behind them is tinted by the code so
# a storm panel reads as a storm from the doorway before you have
# read a single character.



MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


def is_leap(y):
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def geo(ctx):
    """[lat, lon, place] for the configured zip, or None when unavailable."""
    zip = str(ctx.inputs.get("zip", "")).strip()
    if zip == "":
        return None
    g = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if g["status_code"] != 200 or not g["json"]:
        return None
    places = g["json"].get("places", [])
    if not places:
        return None
    p = places[0]
    return [float(p["latitude"]), float(p["longitude"]),
            str(p.get("place name", "")).upper()]


NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do.

    text_fit alone was not enough here: when even its smallest option
    overflows it still draws, which ran these messages off a 64 panel."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands — a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws — which is how a station name ended up running
    straight through the readout beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


# WMO code -> [sprite, label, sky top, sky bottom]
# Short labels exist because "PARTLY CLOUDY" cannot fit a 64 panel beside a
# sprite and a temperature, and clipping it produced "PARTLY CLOUD".
def wmo(code):
    if code == 0:
        return ["SUN", "CLEAR", "#1B4A86", "#7FB6E8", "CLEAR"]
    if code <= 2:
        return ["PARTLY", "PARTLY CLOUDY", "#22456E", "#8FB4D4", "PT CLOUDY"]
    if code == 3:
        return ["CLOUD", "OVERCAST", "#2A3242", "#6E7A8E", "OVERCAST"]
    if code <= 48:
        return ["FOG", "FOG", "#2E3238", "#7C8288", "FOG"]
    if code <= 57:
        return ["RAIN", "DRIZZLE", "#243244", "#5A7288", "DRIZZLE"]
    if code <= 67:
        return ["RAIN", "RAIN", "#1C2836", "#4A6076", "RAIN"]
    if code <= 77:
        return ["SNOW", "SNOW", "#333B4E", "#8E9AB4", "SNOW"]
    if code <= 82:
        return ["RAIN", "SHOWERS", "#1C2836", "#4A6076", "SHOWERS"]
    if code <= 86:
        return ["SNOW", "SNOW SHOWERS", "#333B4E", "#8E9AB4", "SNOW"]
    return ["STORM", "THUNDERSTORM", "#171B2A", "#3E4560", "STORMS"]


def sprite_at(c, name, x, y, n):
    """Draw one weather sprite, dispatched by name.

    The publish-time linter matches image literals against the manifest asset
    list, so the filenames have to be spelled out here rather than assembled
    from a variable."""
    if name == "SUN":
        c.image("SUN.png", x, y, w = n, h = n)
    elif name == "PARTLY":
        c.image("PARTLY.png", x, y, w = n, h = n)
    elif name == "CLOUD":
        c.image("CLOUD.png", x, y, w = n, h = n)
    elif name == "RAIN":
        c.image("RAIN.png", x, y, w = n, h = n)
    elif name == "SNOW":
        c.image("SNOW.png", x, y, w = n, h = n)
    elif name == "STORM":
        c.image("STORM.png", x, y, w = n, h = n)
    else:
        c.image("FOG.png", x, y, w = n, h = n)


def fetch(ctx, g):
    return http.get("https://api.open-meteo.com/v1/forecast",
                    params = {"latitude": str(g[0]), "longitude": str(g[1]),
                              "current": "temperature_2m,weather_code",
                              "daily": "weather_code,temperature_2m_max,temperature_2m_min",
                              "temperature_unit": str(ctx.inputs.get("units", "F")).lower() == "c" and "celsius" or "fahrenheit",
                              "timezone": "auto", "forecast_days": "4"},
                    ttl_seconds = 1800)


def now(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP CODE")
        return
    r = fetch(ctx, g)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO WEATHER", "FEED UNREACHABLE")
        return

    j = r["json"]
    cur = j.get("current", {})
    temp = int(float(cur.get("temperature_2m", 0) or 0))
    w = wmo(int(cur.get("weather_code", 0) or 0))
    daily = j.get("daily", {})
    hi = daily.get("temperature_2m_max", [0])
    lo = daily.get("temperature_2m_min", [0])

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, w[2], w[3],
                    horizontal = False)
    n = 24 if c.width >= 128 else 16

    if c.width >= 128:
        sprite_at(c, w[0], 6, 4, n)
        c.text(str(temp) + "\u00B0", 38, 4, font = "16x20", color = "#FFFFFF")
        c.text_fit(w[1], 38, 23, ["6x8", "5x7", "4x5"], color = "#DCE6F4",
                   maxw = c.width - 108)
        c.text(g[2], c.width - 6, 3, font = "5x7", color = "#DCE6F4",
               align = "right")
        c.text("H " + str(int(float(hi[0] or 0))), c.width - 6, 13,
               font = "6x8", color = "#FFD86A", align = "right")
        c.text("L " + str(int(float(lo[0] or 0))), c.width - 6, 22,
               font = "6x8", color = "#9FD0FF", align = "right")
    else:
        sprite_at(c, w[0], 2, 8, n)
        c.text(str(temp) + "\u00B0", c.width - 3, 6, font = "16x20",
               color = "#FFFFFF", align = "right")
        c.text_fit(w[4], c.width // 2, 26, ["4x5", "3x4"], color = "#DCE6F4",
                   align = "center", maxw = c.width - 4)


def forecast(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP CODE")
        return
    r = fetch(ctx, g)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "FEED UNREACHABLE")
        return

    daily = r["json"].get("daily", {})
    codes = daily.get("weather_code", [])
    hi = daily.get("temperature_2m_max", [])
    lo = daily.get("temperature_2m_min", [])
    days = len(codes) if len(codes) < 4 else 4
    if days < 2:
        nodata(c, "NO FORECAST", "EMPTY FEED")
        return

    c.fill("#0B1220")
    show = days - 1 if days > 1 else 1
    if c.width < 128:
        show = show if show < 3 else 3
    col = c.width // show
    n = 16 if c.width >= 128 else 12
    names = ["TOMORROW", "DAY 2", "DAY 3"]

    for i in range(show):
        k = i + 1
        w = wmo(int(codes[k] or 0))
        x = i * col
        c.vline(x, 2, c.height - 4, "#1B2436") if i > 0 else None
        sprite_at(c, w[0], x + (col - n) // 2, 2, n)
        if c.width >= 128:
            # 5x7 at y=26 would end on row 32, one past the panel.
            c.text(names[i], x + col // 2, 19, font = "4x5", color = "#6E7E96",
                   align = "center")
            c.text(str(int(float(hi[k] or 0))) + "/" + str(int(float(lo[k] or 0))),
                   x + col // 2, 25, font = "5x7", color = "#DCE6F4",
                   align = "center")
        else:
            c.text(str(int(float(hi[k] or 0))), x + col // 2, 17, font = "5x7",
                   color = "#FFD86A", align = "center")
            c.text(str(int(float(lo[k] or 0))), x + col // 2, 26, font = "4x5",
                   color = "#9FD0FF", align = "center")
