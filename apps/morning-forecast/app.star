# Morning Forecast — the wake-up panel for one zip.
#
# One screen that answers the morning question: how cold is it now, how
# warm does today get, how cold tonight, and what does the sky do? Page
# two is tomorrow. Everything comes from the National Weather Service in
# its own words, over the same data path as the stock NWS Forecast app:
# zippopotam.us turns the zip into coordinates, api.weather.gov turns
# coordinates into a forecast grid, and the grid returns the periods.
# The periods are picked apart by their isDaytime flags rather than by
# clock arithmetic, so the page is right at 6 AM and at 11 PM alike:
# "today" is always the next daytime period, tonight is the night that
# follows it.
#
# The degree mark is drawn as a small square outline beside the number:
# the panel fonts carry no degree glyph, and a character the font lacks
# is silently skipped — "32" with a hole where the circle belongs.

UA = {"User-Agent": "glance-dev-network (glance-led.com)"}
BG_TOP = "#0A1220"
BG_BOT = "#1E3350"
GOLD = "#E8B33A"
WHITE = "#FFFFFF"
PALE = "#DCE6F8"
SKY = "#7C90B0"
DIM = "#6A7090"


def geo(ctx):
    """[lat, lon, place] for the configured zip, or None.

    Coordinates stay as the strings zippopotam returned: the points URL
    below is built from them verbatim, so the address the panel asks
    weather.gov about is exactly the one the zip means."""
    zip = str(ctx.inputs.get("zip", "15010")).strip()
    if zip == "":
        return None
    g = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if g["status_code"] != 200 or not g["json"]:
        return None
    places = g["json"].get("places", [])
    if not places:
        return None
    p = places[0]
    return [str(p["latitude"]), str(p["longitude"]),
            str(p.get("place name", "")).upper(), zip]


def fetch(ctx):
    """[place, zip, periods] or None when any hop fails."""
    g = geo(ctx)
    if g == None:
        return None
    p = http.get("https://api.weather.gov/points/" + g[0] + "," + g[1],
                 headers = UA, ttl_seconds = 86400)
    if p["status_code"] != 200 or not p["json"]:
        return None
    url = p["json"].get("properties", {}).get("forecast", None)
    if url == None:
        return None
    f = http.get(url, headers = UA, ttl_seconds = 3600)
    if f["status_code"] != 200 or not f["json"]:
        return None
    ps = f["json"].get("properties", {}).get("periods", [])
    if not ps:
        return None
    return [g[2], g[3], ps]


def pick_parts(ps):
    """Split the period list into now / today / tonight / tomorrow / its night."""
    parts = {"now": ps[0], "day1": None, "night1": None,
             "day2": None, "night2": None}
    stage = 0
    for p in ps:
        day = p.get("isDaytime")
        if stage == 0 and day:
            parts["day1"] = p
            stage = 1
        elif stage == 1 and not day:
            parts["night1"] = p
            stage = 2
        elif stage == 2 and day:
            parts["day2"] = p
            stage = 3
        elif stage == 3 and not day:
            parts["night2"] = p
            stage = 4
    return parts


def cond_label(short):
    """A one-word sky, short enough for the column beside the number."""
    t = str(short).upper()
    if t.find("THUNDER") >= 0:
        return "STORMS"
    if (t.find("SNOW") >= 0 or t.find("SLEET") >= 0 or t.find("ICE") >= 0
            or t.find("FLURR") >= 0):
        return "SNOW"
    if t.find("RAIN") >= 0 or t.find("SHOWER") >= 0 or t.find("DRIZZLE") >= 0:
        return "RAIN"
    if t.find("FOG") >= 0 or t.find("HAZE") >= 0 or t.find("SMOKE") >= 0:
        return "FOG"
    if t.find("PARTLY") >= 0 or t.find("MOSTLY SUNNY") >= 0:
        return "PT CLDY"
    if t.find("CLOUD") >= 0 or t.find("OVERCAST") >= 0:
        return "CLOUDY"
    if t.find("CLEAR") >= 0:
        return "CLEAR"
    if t.find("SUNNY") >= 0:
        return "SUNNY"
    return "FAIR"


def fitwords(c, text, font, maxw):
    """Longest run of whole words that fits (borrowed from NWS Forecast)."""
    t = str(text).strip()
    if c.text_width(t, font) <= maxw:
        return t
    out = ""
    for w in t.split(" "):
        trial = w if out == "" else out + " " + w
        if c.text_width(trial, font) > maxw:
            break
        out = trial
    return out


def nodata(c, sub):
    c.fill("#0B0C12")
    c.text_fit("NO FORECAST", c.width // 2, 6, ["6x8", "5x7", "4x5"],
               color = GOLD, align = "center", maxw = c.width - 2)
    c.text_fit(sub, c.width // 2, 19, ["4x5"], color = DIM,
               align = "center", maxw = c.width - 2)


def big_temp(c, temp, x, y):
    """The hero number at 10x16 with a hand-drawn degree mark.

    Not the biggest face on the panel: at 16x20 a two-digit temperature
    plus its degree mark eats 40 of the 64 columns and leaves the sky
    and the high/low no room to be legible. 10x16 is still half the
    panel's height — and it is the stock NWS app's narrow-panel hero."""
    s = "--" if temp == None else str(int(temp))
    c.text(s, x, y, font = "10x16", color = WHITE)
    w = c.text_width(s, "10x16")
    c.rect(x + w + 2, y + 1, x + w + 4, y + 3, outline = WHITE)


def today(c, ctx):
    got = fetch(ctx)
    if got == None:
        nodata(c, "FEED DOWN")
        return
    place = got[0]
    parts = pick_parts(got[2])
    day = parts["day1"]
    if day == None:
        nodata(c, "NOTHING RETURNED")
        return
    night = parts["night1"]
    nowp = parts["now"]

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, BG_TOP, BG_BOT,
                    horizontal = False)
    c.text_fit(place, c.width // 2, 0, ["4x5", "3x4"], color = SKY,
               align = "center", maxw = c.width - 2)

    big_temp(c, nowp.get("temperature"), 1, 8)

    # The day you are waking into: its sky, then its high and low.
    c.text_fit(cond_label(day.get("shortForecast", "")), 28, 7,
               ["5x7", "4x5", "3x4"], color = PALE, align = "left",
               maxw = c.width - 29)
    hl = "H" + str(int(day.get("temperature")))
    if night != None and night.get("temperature") != None:
        hl = hl + " L" + str(int(night.get("temperature")))
    c.text_fit(hl, 28, 16, ["5x7", "4x5", "3x4"], color = WHITE,
               align = "left", maxw = c.width - 29)

    now_name = fitwords(c, str(nowp.get("name", "")).upper(), "4x5", 30)
    if now_name != "":
        c.text(now_name, 0, 27, font = "4x5", color = DIM)
    c.text(str(day.get("name", "")).upper(), c.width - 1, 27, font = "4x5",
           color = GOLD, align = "right")


def tomorrow(c, ctx):
    got = fetch(ctx)
    if got == None:
        nodata(c, "FEED DOWN")
        return
    parts = pick_parts(got[2])
    day = parts["day2"]
    if day == None:
        nodata(c, "NOTHING RETURNED")
        return
    night = parts["night2"]

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, BG_TOP, BG_BOT,
                    horizontal = False)
    c.text_fit(str(day.get("name", "")).upper(), c.width // 2, 0,
               ["4x5", "3x4"], color = GOLD, align = "center",
               maxw = c.width - 2)

    big_temp(c, day.get("temperature"), 1, 8)

    c.text_fit(cond_label(day.get("shortForecast", "")), 28, 7,
               ["5x7", "4x5", "3x4"], color = PALE, align = "left",
               maxw = c.width - 29)
    if night != None and night.get("temperature") != None:
        c.text_fit("L" + str(int(night.get("temperature"))), 28, 16,
                   ["5x7", "4x5", "3x4"], color = WHITE, align = "left",
                   maxw = c.width - 29)

    c.text(got[1], 0, 27, font = "4x5", color = DIM)
