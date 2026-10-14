# NWS Day Ahead
#
# One screen from the National Weather Service, switching at 5pm local time:
#
#   before 5pm   TODAY  hi/lo    8A  12P  6P  10P   (8A becomes NOW after 8am)
#   from 5pm     TOMORROW hi/lo  10P | 8A  12P  6P   (10P is tonight)
#
# Each slot is NWS's hourly forecast for that hour: a condition icon and the
# chance of precipitation under it, then the hour. The high is the day's
# daytime period from the `forecast` feed and the low is the night after it.
#
# ctx.now is UTC and ctx has no time zone. The local hour is ctx.now shifted
# by the UTC offset NWS stamps on each startTime ("...T17:00:00-04:00", DST
# included), and the local date is read off the hourly period at that hour,
# so there is no calendar math here. geo() and nodata() are nws-forecast's.

UA = {"User-Agent": "glance-dev-network (glance-led.com)"}
EVENING_HOUR = 17
TONIGHT_HOUR = 22
DAY_HOURS = [8, 12, 18]


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


def forecasts(ctx):
    """[daily periods, hourly periods], or None when NWS is unreachable."""
    g = geo(ctx)
    if g == None:
        return None
    p = http.get("https://api.weather.gov/points/" + str(g[0]) + "," + str(g[1]),
                 headers = UA, ttl_seconds = 86400)
    if p["status_code"] != 200 or not p["json"]:
        return None
    props = p["json"].get("properties", {})
    out = []
    for key in ["forecast", "forecastHourly"]:
        url = props.get(key, None)
        if url == None:
            return None
        f = http.get(url, headers = UA, ttl_seconds = 1800)
        if f["status_code"] != 200 or not f["json"]:
            return None
        ps = f["json"].get("properties", {}).get("periods", [])
        if not ps:
            return None
        out.append(ps)
    return out


def hour_of(p):
    return int(str(p.get("startTime", ""))[11:13])


def date_of(p):
    return str(p.get("startTime", ""))[:10]


def local_now(ctx, hourly):
    """[date, hour] in the forecast's own time zone.

    US offsets are whole hours, so only the hour digits of the offset count."""
    s = str(hourly[0].get("startTime", ""))
    off = int(s[20:22])
    if s[19] == "-":
        off = -off
    hour = (ctx.now.hour + off) % 24
    for p in hourly:
        if hour_of(p) == hour:
            return [date_of(p), hour]
    return [date_of(hourly[0]), hour_of(hourly[0])]


def day_page(daily, i):
    """A daily daytime period plus the low from the night period after it."""
    if i == None:
        return None
    lo = None
    if i + 1 < len(daily) and not daily[i + 1].get("isDaytime", False):
        lo = daily[i + 1]
    return {"period": daily[i], "low": lo}


def plan(ctx, fc):
    """[title, day, slots, divider] for the screen.

    day is {"period", "low"} for the high/low; slots are [label, hourly period
    or None] left to right; divider is the slot index a rule is drawn before,
    or None, to split tonight from tomorrow."""
    daily = fc[0]
    hourly = fc[1]
    now = local_now(ctx, hourly)
    today = now[0]

    day_today = None
    day_next = None
    for i in range(len(daily)):
        p = daily[i]
        if not p.get("isDaytime", False):
            continue
        if date_of(p) == today and day_today == None:
            day_today = i
        elif date_of(p) > today and day_next == None:
            day_next = i

    tonight = ["10P", hourly_at(hourly, today, TONIGHT_HOUR)]
    if now[1] < EVENING_HOUR and day_today != None:
        slots = [[hour_label(h), hourly_at(hourly, today, h)] for h in DAY_HOURS]
        # Once the first slot has gone by, it shows the current hour instead.
        if slots[0][1] == None:
            slots[0] = ["NOW", hourly[0]]
        return ["TODAY", day_page(daily, day_today), slots + [tonight], None]

    # Past 10pm the slot has gone by; the current hour stands in for it.
    if tonight[1] == None:
        tonight = ["NOW", hourly[0]]
    if day_next == None:
        return ["TOMORROW", None, [tonight], None]
    tdate = date_of(daily[day_next])
    slots = [[hour_label(h), hourly_at(hourly, tdate, h)] for h in DAY_HOURS]
    return ["TOMORROW", day_page(daily, day_next), [tonight] + slots, 1]


def hour_label(h):
    """8 -> "8A", 12 -> "12P", 22 -> "10P"."""
    h12 = h % 12
    return str(12 if h12 == 0 else h12) + ("A" if h < 12 else "P")


def hourly_at(hourly, date, hour):
    for p in hourly:
        if date_of(p) == date and hour_of(p) == hour:
            return p
    return None


# --- condition icons -------------------------------------------------------
#
# Each hourly period carries NWS's own condition code in its icon URL
# (".../icons/land/night/tsra_sct,40?size=small"); the code list and its
# meanings are published at api.weather.gov/icons. Each code family is drawn
# with an existing sprite from nws-forecast, or the runtime's built-in moon
# for a clear or partly cloudy night.
SPRITE_FOR = {
    "skc": "SUN", "few": "SUN", "hot": "SUN", "cold": "SUN",
    "sct": "PARTLY",
    "bkn": "CLOUD", "ovc": "CLOUD",
    "rain": "RAIN", "rain_showers": "RAIN", "rain_showers_hi": "RAIN",
    "fzra": "RAIN", "rain_fzra": "RAIN", "sleet": "RAIN", "rain_sleet": "RAIN",
    "snow": "SNOW", "rain_snow": "SNOW", "snow_sleet": "SNOW",
    "snow_fzra": "SNOW", "blizzard": "SNOW",
    "tsra": "STORM", "tsra_sct": "STORM", "tsra_hi": "STORM",
    "tornado": "STORM", "hurricane": "STORM", "tropical_storm": "STORM",
    "fog": "FOG", "haze": "FOG", "smoke": "FOG", "dust": "FOG",
}
MOON_AT_NIGHT = ["skc", "few", "sct"]


def condition(p):
    """[NWS code, is_night] from a period's icon URL, wind_ prefix dropped."""
    url = str(p.get("icon", ""))
    night = url.find("/night/") >= 0
    tail = url.split("/")[-1].split("?")[0].split(",")[0]
    if tail.startswith("wind_"):
        tail = tail[5:]
    return [tail, night]


def draw_condition(c, p, x, y):
    got = condition(p)
    if got[1] and got[0] in MOON_AT_NIGHT:
        c.icon("moon", x + 2, y, color = "#E8E3B0", scale = 2)
        return
    c.image(SPRITE_FOR.get(got[0], "CLOUD") + ".png", x, y, w = 16, h = 16)


# --- drawing --------------------------------------------------------------

TITLE_Y = 0     # 4x5 / 3x4, ink 0-4
ICON_Y = 4      # 16px sprites, 4-19 (their top row is transparent)
POP_Y = 20      # 4x5 rain chance, 20-24
HOUR_Y = 26     # 4x5 hour label, 26-30

TITLE_COLOR = "#7C90B0"
HIGH_COLOR = "#FFFFFF"
LOW_COLOR = "#8EC0FF"
RAIN_COLOR = "#4FA8FF"
DRY_COLOR = "#5A6478"
RULE_COLOR = "#3A4A66"


def temp_str(p, unit):
    s = str(p.get("temperature", ""))
    return s + str(p.get("temperatureUnit", "")) if unit else s


def rain_pct(p):
    pop = p.get("probabilityOfPrecipitation", None)
    v = pop.get("value", None) if pop != None else None
    return 0 if v == None else int(v)


def draw_header(c, title, day):
    """Title left, high/low right; the title shrinks before units are dropped."""
    right = c.width - 1
    hi_s = ""
    lo_s = ""
    for f in [["4x5", True], ["3x4", True], ["4x5", False], ["3x4", False]]:
        if day != None:
            hi_s = temp_str(day["period"], f[1])
            lo_s = "/" + temp_str(day["low"], f[1]) if day["low"] != None else ""
        tw = c.text_width(hi_s + lo_s, "4x5")
        if c.text_width(title, f[0]) <= right - tw - 3:
            break
    c.text_stroke(title, 1, TITLE_Y, font = f[0], color = TITLE_COLOR)
    if lo_s != "":
        c.text_stroke(lo_s, right, TITLE_Y, font = "4x5", color = LOW_COLOR,
                      align = "right")
    if hi_s != "":
        c.text_stroke(hi_s, right - c.text_width(lo_s, "4x5"), TITLE_Y,
                      font = "4x5", color = HIGH_COLOR, align = "right")


def draw_slot(c, label, p, x, w):
    cx = x + w // 2
    c.text(label, cx, HOUR_Y, font = "4x5", color = TITLE_COLOR, align = "center")
    if p == None:
        # Already past: the hourly feed starts at the current hour.
        c.icon("minus", cx - 4, ICON_Y + 4, color = DRY_COLOR)
        return
    draw_condition(c, p, x, ICON_Y)

    # "100%" is wider than a slot; the % sign goes before the font shrinks
    # past readable, leaving a clear column between neighbours.
    pct = rain_pct(p)
    for t in [[str(pct) + "%", "4x5"], [str(pct) + "%", "3x4"], [str(pct), "4x5"]]:
        if c.text_width(t[0], t[1]) <= w - 2:
            break
    # Stroked: the rain sprites' drops reach the row above it.
    c.text_stroke(t[0], cx, POP_Y, font = t[1],
                  color = RAIN_COLOR if pct > 0 else DRY_COLOR, align = "center")


def main(c, ctx):
    fc = forecasts(ctx)
    if fc == None:
        nodata(c, "NO FORECAST", "NWS OFFLINE")
        return
    got = plan(ctx, fc)

    c.clear()
    slots = got[2]
    w = c.width // len(DAY_HOURS + [TONIGHT_HOUR])
    for k in range(len(slots)):
        draw_slot(c, slots[k][0], slots[k][1], k * w, w)
    if got[3] != None:
        c.vline(got[3] * w, ICON_Y, c.height - ICON_Y, RULE_COLOR)
    # Last, so the title and high/low sit over the tops of the sprites.
    draw_header(c, got[0], got[1])
