# NWS Forecast
#
# api.weather.gov in two hops: the point lookup returns the grid
# office and cell, the gridpoint returns the forecast. Both are
# cached hard because the grid assignment for a zip never changes.
#
# The value here over a raw model feed is the wording: NWS writes
# 'showers likely after 2pm', which is more useful on a wall than a
# WMO code and a probability.



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


FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}


def wrap(c, words, font, maxw):
    """Greedily pack words into lines no wider than maxw."""
    lines = []
    cur = ""
    for w in words:
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    return lines


def block(c, text, x, y, maxw, maxh, fonts, color, gap):
    """Draw text at the largest font whose wrapped lines fit maxh."""
    words = str(text).upper().split(" ")
    for f in fonts:
        lines = wrap(c, words, f, maxw)
        if len(lines) * (FONTH[f] + gap) - gap <= maxh:
            for i in range(len(lines)):
                c.text(lines[i], x, y + i * (FONTH[f] + gap), font = f,
                       color = color)
            return len(lines)
    # Nothing fits: use the smallest face, draw what we can, and mark the
    # cut so a dropped tail reads as deliberate rather than as a bug.
    f = fonts[len(fonts) - 1]
    lines = wrap(c, words, f, maxw)
    n = maxh // (FONTH[f] + gap)
    if n > len(lines):
        n = len(lines)
    for i in range(n):
        line = lines[i]
        if i == n - 1 and n < len(lines):
            # `while` is a reserved keyword in Starlark even though the
            # language has no while loop, so this walks back with a for.
            for k in range(len(line), 0, -1):
                if c.text_width(line[:k] + "..", f) <= maxw:
                    line = line[:k]
                    break
            line = line + ".."
        c.text(line, x, y + i * (FONTH[f] + gap), font = f, color = color)
    return n


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


def fitwords(c, text, font, maxw):
    """Longest run of WHOLE words that fits maxw.

    clip() cuts at the pixel and leaves things like "SCHOOL PI" or
    "PAINTED B", which read as a rendering fault rather than an
    abbreviation. This stops at a word boundary instead, and only falls back
    to a hard cut when a single word cannot fit on its own."""
    t = str(text).strip()
    if c.text_width(t, font) <= maxw:
        return t
    parts = t.split(" ")
    out = ""
    for w in parts:
        trial = w if out == "" else out + " " + w
        if c.text_width(trial, font) > maxw:
            break
        out = trial
    if out != "":
        return out
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def icon_for(text):
    """[sprite, short label].

    The label is returned alongside so the small panel can print exactly the
    condition the sprite is showing. Printing a truncated shortForecast
    instead produced a storm sprite captioned MOSTLY SUNNY, because the icon
    was chosen from the whole string and the text was cut."""
    t = text.upper()
    if t.find("THUNDER") >= 0:
        return ["STORM", "STORMS"]
    if t.find("SNOW") >= 0 or t.find("SLEET") >= 0 or t.find("ICE") >= 0:
        return ["SNOW", "SNOW"]
    if t.find("RAIN") >= 0 or t.find("SHOWER") >= 0 or t.find("DRIZZLE") >= 0:
        return ["RAIN", "RAIN"]
    if t.find("FOG") >= 0 or t.find("HAZE") >= 0 or t.find("SMOKE") >= 0:
        return ["FOG", "FOG"]
    if t.find("PARTLY") >= 0 or t.find("MOSTLY SUNNY") >= 0:
        return ["PARTLY", "PT CLOUDY"]
    if t.find("CLOUD") >= 0 or t.find("OVERCAST") >= 0:
        return ["CLOUD", "CLOUDY"]
    return ["SUN", "SUNNY"]


def sprite_at(c, name, x, y, n):
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


def periods(ctx):
    g = geo(ctx)
    if g == None:
        return None
    p = http.get("https://api.weather.gov/points/" + str(g[0]) + "," + str(g[1]),
                 headers = {"User-Agent": "glance-dev-network (glance-led.com)"},
                 ttl_seconds = 86400)
    if p["status_code"] != 200 or not p["json"]:
        return None
    url = p["json"].get("properties", {}).get("forecast", None)
    if url == None:
        return None
    f = http.get(url, headers = {"User-Agent": "glance-dev-network (glance-led.com)"},
                 ttl_seconds = 3600)
    if f["status_code"] != 200 or not f["json"]:
        return None
    return f["json"].get("properties", {}).get("periods", [])


def show(c, ctx, idx):
    ps = periods(ctx)
    if ps == None:
        nodata(c, "NO FORECAST", "NWS UNREACHABLE")
        return
    if len(ps) <= idx:
        nodata(c, "NO FORECAST", "NOTHING RETURNED")
        return

    p = ps[idx]
    name = str(p.get("name", "")).upper()
    short = str(p.get("shortForecast", "")).upper()
    temp = p.get("temperature", None)
    got = icon_for(short)
    icon = got[0]
    label = got[1]

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0A1220", "#1E3350",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    sprite_at(c, icon, 1, (c.height - sz) // 2, sz)

    if c.width >= 128:
        c.text(fitwords(c, name, "4x5", 70), 28, 1, font = "4x5", color = "#7C90B0")
        if temp != None:
            c.text(str(int(temp)) + "\u00B0", c.width - 5, 2, font = "16x20",
                   color = "#FFFFFF", align = "right")
        block(c, short, 28, 9, c.width - 84, 21,
              ["10x16", "6x8", "5x7", "4x5"], "#DCE6F8", 1)
        pop = p.get("probabilityOfPrecipitation", {})
        chance = pop.get("value", None) if pop != None else None
        if chance != None and int(chance) > 0:
            c.text(str(int(chance)) + "% RAIN", c.width - 5, 24, font = "5x7",
                   color = "#7FB6E8", align = "right")
    else:
        if temp != None:
            c.text(str(int(temp)) + "\u00B0", c.width - 2, 1, font = "10x16",
                   color = "#FFFFFF", align = "right")
        # The canonical label, so caption and sprite can never disagree.
        c.text_fit(label, c.width - 2, 20, ["6x8", "5x7", "4x5"],
                   color = "#DCE6F8", align = "right", maxw = c.width - 20)


def now(c, ctx):
    show(c, ctx, 0)


def later(c, ctx):
    show(c, ctx, 1)
