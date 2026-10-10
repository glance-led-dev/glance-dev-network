# PT Heat Category
#
# DESIGN. Army black and gold. A pixel-art flag on a pole at the left wears
# the heat category's own flag color (white, green, yellow, red, black), so
# the picture is the answer from across the room. Beside it the category in
# that same color, and on the right one number with its label: the WBGT
# when a flag is up, the feels-like temp when it isn't. The post name rides
# the top-left in gold; NOW or PT 0630 SAT top-right says which moment it is.
#
# Heat categories follow the Army's WBGT bands (TB MED 507): CAT 1 78-81.9 F,
# CAT 2 82-84.9, CAT 3 85-87.9, CAT 4 88-89.9, CAT 5 90+. No feed publishes
# WBGT, so it is ESTIMATED from Open-Meteo's wet-bulb, air temp, sun and wind
# and labelled EST -- the range flag at the post is always the real call.
#
# Data: Open-Meteo (free, no key). refresh is 1800 s and the forecast ttl
# matches it; the ZIP lookup is cached a day.

BG = "#000000"
GOLD = "#FFC72C"
DIMGOLD = "#6B5310"
LABEL = "#8C8C8C"
POLE = "#9A9A9A"
COLD = "#78DCFF"

DOW = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

# post -> [short name for the panel, lat, lon]. Short names are 4x5 and the
# widest, "FT L WOOD", is 40px -- they share the top row with "PT 0630 SAT".
POSTS = {
    "FORT BRAGG": ["FT BRAGG", 35.14, -79.00],
    "FORT HOOD": ["FT HOOD", 31.13, -97.78],
    "FORT CAMPBELL": ["FT CAMPBELL", 36.66, -87.47],
    "FORT STEWART": ["FT STEWART", 31.87, -81.61],
    "FORT BENNING": ["FT BENNING", 32.36, -84.95],
    "FORT BLISS": ["FT BLISS", 31.81, -106.42],
    "FORT CARSON": ["FT CARSON", 38.74, -104.79],
    "JBLM": ["JBLM", 47.11, -122.57],
    "FORT DRUM": ["FT DRUM", 44.05, -75.72],
    "FORT RILEY": ["FT RILEY", 39.06, -96.79],
    "FORT SILL": ["FT SILL", 34.65, -98.40],
    "FORT POLK": ["FT POLK", 31.05, -93.20],
    "FORT LEONARD WOOD": ["FT L WOOD", 37.74, -92.14],
    "FORT JACKSON": ["FT JACKSON", 34.02, -80.89],
    "FORT GORDON": ["FT GORDON", 33.42, -82.14],
    "FORT KNOX": ["FT KNOX", 37.89, -85.96],
    "FORT LEE": ["FT LEE", 37.24, -77.33],
    "FORT RUCKER": ["FT RUCKER", 31.34, -85.71],
    "FORT SAM HOUSTON": ["FT SAM", 29.46, -98.43],
    "FORT HUACHUCA": ["HUACHUCA", 31.55, -110.35],
    "FORT IRWIN": ["FT IRWIN", 35.26, -116.68],
    "FORT LEAVENWORTH": ["LEAVENWORTH", 39.35, -94.92],
    "FORT WAINWRIGHT": ["WAINWRIGHT", 64.83, -147.64],
    "SCHOFIELD BARRACKS": ["SCHOFIELD", 21.49, -158.06],
    "CAMP HUMPHREYS": ["HUMPHREYS", 36.96, 127.03],
    "GRAFENWOEHR": ["GRAF", 49.70, 11.94],
    "VICENZA": ["VICENZA", 45.55, 11.55],
}

FIELDS = "temperature_2m,wet_bulb_temperature_2m,apparent_temperature,wind_speed_10m,shortwave_radiation"

NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do."""
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
    """Two short lines, what and what to do, on the black ground."""
    c.fill(BG)
    ft = _fit_clip(c, title, NODATA_FONTS, c.width - 16)
    c.text(ft[1], c.width // 2, 5, font = ft[0], color = GOLD, align = "center")
    fs = _fit_clip(c, sub, ["5x7", "4x5"], c.width - 16)
    c.text(fs[1], c.width // 2, 24, font = fs[0], color = LABEL, align = "center")


def rnd(x):
    return int(x + 0.5) if x >= 0 else -int(-x + 0.5)


def num(v):
    """Feed values arrive as numbers or null; null is None here."""
    if v == None:
        return None
    return float(v)


def place(ctx):
    """[short name, lat, lon], or [error title, error sub] as a 2-list."""
    post = str(ctx.inputs.get("post", "FORT CAMPBELL")).strip().upper()
    if post != "CUSTOM ZIP":
        return POSTS.get(post, POSTS["FORT CAMPBELL"])
    zip = str(ctx.inputs.get("zip", "")).strip()
    if zip == "":
        return ["NO ZIP", "SET A ZIP IN SETTINGS"]
    g = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if g["status_code"] == 404:
        return ["ZIP NOT FOUND", "CHECK THE ZIP CODE"]
    if g["status_code"] != 200 or not g["json"]:
        return ["NO WEATHER", "WILL RETRY SOON"]
    places = g["json"].get("places", [])
    if not places:
        return ["ZIP NOT FOUND", "CHECK THE ZIP CODE"]
    # A custom location shows its ZIP: there's no reliable short city name.
    return ["ZIP " + zip[:5], float(places[0]["latitude"]),
            float(places[0]["longitude"])]


def forecast(lat, lon):
    resp = http.get("https://api.open-meteo.com/v1/forecast", params = {
        "latitude": str(lat), "longitude": str(lon),
        "current": FIELDS, "hourly": FIELDS, "forecast_days": "3",
        "temperature_unit": "fahrenheit", "wind_speed_unit": "mph",
        "timezone": "auto",
    }, ttl_seconds = 1800)   # matches refresh
    if resp["status_code"] != 200 or not resp["json"]:
        return None
    return resp["json"]


def wbgt(t, tw, wind, sun):
    """Estimated outdoor WBGT (F) = 0.7 Tw + 0.2 Tg + 0.1 Ta, all in C.

    The black-globe temperature isn't forecast, so it's approximated as air
    temp plus a solar load that wind carries away: about +11 C in full
    1000 W/m2 sun at a 2 m/s breeze, +0 at night."""
    ta = (t - 32) * 5 / 9
    tw_c = (tw - 32) * 5 / 9
    ws = wind * 0.447
    tg = ta + 0.0167 * sun / (1 + 0.25 * ws)
    w = 0.7 * tw_c + 0.2 * tg + 0.1 * ta
    return w * 9 / 5 + 32


# [lower WBGT bound F, label, flag color, text color]. One table so the flag
# and the word can never disagree. A black flag on black needs a white edge.
CATS = [
    [90, "CAT 5", "#000000", "white"],
    [88, "CAT 4", "#FF2020", "#FF2020"],
    [85, "CAT 3", "#FFE000", "#FFE000"],
    [82, "CAT 2", "#00DC46", "#00DC46"],
    [78, "CAT 1", "#FFFFFF", "white"],
]


def category(w):
    for cat in CATS:
        if w >= cat[0]:
            return cat
    return None


def degree(c, x, y, color):
    """A 3x3 degree ring; 10x16 has no degree glyph."""
    c.pixel(x + 1, y, color)
    c.pixel(x, y + 1, color)
    c.pixel(x + 2, y + 1, color)
    c.pixel(x + 1, y + 2, color)


def flag(c, cat):
    """Pole at x 6 with a gold finial; an 18x12 flag in the category color."""
    c.vline(6, 3, 29, POLE)
    c.rect(5, 1, 7, 2, fill = GOLD)
    if cat == None:
        # No flag flying: a dark, empty outline where the flag would be.
        c.rect(7, 4, 24, 15, fill = "#141414", outline = "#4A4A4A")
        return
    edge = "white" if cat[2] == "#000000" else cat[2]
    c.rect(7, 4, 24, 15, fill = cat[2], outline = edge)


def conditions(c, where, when, t, tw, feels, wind, sun):
    """The shared page: flag, category, one number, two labels."""
    w = wbgt(t, tw, wind, sun)
    cat = category(w)
    c.fill(BG)
    flag(c, cat)

    # Top row: post (left, gold) and moment (right). "PT 0630 SAT" is 47px,
    # so the post name gets 121 - 47 - 3 - 28 = 43px before it's clipped.
    right = c.width - 7
    c.text(when, right, 1, font = "4x5", color = LABEL, align = "right")
    room = right - c.text_width(when, "4x5") - 3 - 28
    pn = _fit_clip(c, where, ["4x5"], room)
    c.text(pn[1], 28, 1, font = "4x5", color = GOLD)

    # Right column: the one number, 10x16 white with a drawn degree ring.
    if cat != None:
        val = rnd(w)
        lab = "WBGT EST"
        vcol = "white"
    else:
        val = rnd(feels)
        lab = "FEELS"
        vcol = COLD if val <= 32 else "white"
    vs = str(val)
    vw = c.text_width(vs, "10x16")
    c.text(vs, right - 4 - vw, 9, font = "10x16", color = vcol)
    degree(c, right - 2, 9, vcol)
    c.text(lab, right, 27, font = "4x5", color = LABEL, align = "right")

    # Middle: the category word ("CAT 5" is 53px, x 28..80; the widest value
    # "-12" plus ring starts at x 86, so they never meet).
    if cat != None:
        c.text(cat[1], 28, 9, font = "10x16", color = cat[3])
        c.text("AIR %d F" % rnd(t), 28, 27, font = "4x5", color = LABEL)
    else:
        c.text("NO FLAG", 28, 13, font = "6x8", color = "white")
        c.text("AIR %d F" % rnd(t), 28, 27, font = "4x5", color = LABEL)


def fetch(ctx):
    """[where, feed] or [error title, error sub, None]."""
    p = place(ctx)
    if len(p) == 2:
        return [p[0], p[1], None]
    fc = forecast(p[1], p[2])
    if fc == None:
        return ["NO WEATHER", "WILL RETRY SOON", None]
    return [p[0], fc]


def now(c, ctx):
    d = fetch(ctx)
    if len(d) == 3:
        nodata(c, d[0], d[1])
        return
    cur = d[1].get("current", {})
    t = num(cur.get("temperature_2m"))
    tw = num(cur.get("wet_bulb_temperature_2m"))
    feels = num(cur.get("apparent_temperature"))
    wind = num(cur.get("wind_speed_10m"))
    sun = num(cur.get("shortwave_radiation"))
    if t == None or tw == None or feels == None:
        nodata(c, "NO WEATHER", "WILL RETRY SOON")
        return
    conditions(c, d[0], "NOW", t, tw, feels, wind or 0.0, sun or 0.0)


def hourly_at(h, key, i, half):
    """Hour i's value, or the mean of i and i+1 for a :30 formation."""
    arr = h.get(key, [])
    if i >= len(arr) or arr[i] == None:
        return None
    v = float(arr[i])
    if half and i + 1 < len(arr) and arr[i + 1] != None:
        v = (v + float(arr[i + 1])) / 2
    return v


def dfc(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def pt(c, ctx):
    d = fetch(ctx)
    if len(d) == 3:
        nodata(c, d[0], d[1])
        return
    fc = d[1]
    pttime = str(ctx.inputs.get("pttime", "0630")).strip()
    if pttime not in ["0530", "0600", "0630", "0700"]:
        pttime = "0630"
    hh = pttime[:2]
    half = pttime[2:] == "30"
    # Feed times are local ISO strings ("2026-10-10T06:00"), so the next
    # formation is the first matching hour whose HH:MM is still ahead.
    nowstr = str(fc.get("current", {}).get("time", ""))
    h = fc.get("hourly", {})
    times = h.get("time", [])
    idx = -1
    for i in range(len(times)):
        ts = str(times[i])
        if ts[11:13] == hh and ts[:11] + hh + ":" + pttime[2:] > nowstr:
            idx = i
            break
    if idx < 0:
        nodata(c, "NO FORECAST", "WILL RETRY SOON")
        return
    t = hourly_at(h, "temperature_2m", idx, half)
    tw = hourly_at(h, "wet_bulb_temperature_2m", idx, half)
    feels = hourly_at(h, "apparent_temperature", idx, half)
    wind = hourly_at(h, "wind_speed_10m", idx, half)
    sun = hourly_at(h, "shortwave_radiation", idx, half)
    if t == None or tw == None or feels == None:
        nodata(c, "NO FORECAST", "WILL RETRY SOON")
        return
    ts = str(times[idx])
    day = DOW[(dfc(int(ts[0:4]), int(ts[5:7]), int(ts[8:10])) + 4) % 7]
    conditions(c, d[0], "PT " + pttime + " " + day, t, tw, feels,
               wind or 0.0, sun or 0.0)
