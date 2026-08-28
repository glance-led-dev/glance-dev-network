# Weather
#
# DESIGN. Open-Meteo, keyed by zip. WMO weather codes collapse into eight
# drawn conditions, and the sky behind them is tinted by the code so a storm
# panel reads as a storm from the doorway before you have read a single
# character. NOW is one hero temperature against that sky, the drawn condition
# on the left, place and today's high/low stacked on the right. FORECAST gives
# each of the next three days its own column of the same sky, dimmed to a
# near-black wash so the numbers keep black-background contrast.
#
# Because both pages put content on a colored ground, everything drawn on
# them carries a 1px black outline - it restores the local contrast a gradient
# takes away. Strings go through c.text_stroke(); the degree marks are baked
# pixel art with the outline in the art itself; and the weather drawings get
# the same halo from sprite_at(), stamped from a black silhouette derived from
# each PNG's own alpha. One rule, so nothing on the sky is left unedged.


MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# 192 scroll safe zone. Content lives in x 10..182 (stroke included) so the
# app reads as its own unit when a neighbour app is on the glass beside it.
SAFE_L = 10
SAFE_R = 182


# --- the degree mark ------------------------------------------------------
# No bitmap font in gdn/data/fonts.json carries U+00B0. The shipped app drew
# str(temp) + "°", and since text_width counts a missing glyph as 0px and
# drawText skips it, the panel showed a bare "80" with no unit on it at all -
# a magic number by the guidelines' own definition.
#
# So the mark is pixel art, one ring per font size, each baked with a 1px
# outline ('o') so it survives the sky gradient the same way text_stroke does.
# The ring's top-left ink sits 1px in from the art's top-left, which is why
# dtext() draws the art at (x - 1, y - 1). A legend value of None drops the
# outline, for the rare flat-ground caller.

DEG_RING6 = """
.oooooo.
oo####oo
o######o
o##oo##o
o##oo##o
o######o
oo####oo
.oooooo.
"""

DEG_RING4 = """
.oooo.
oo##oo
o#oo#o
o#oo#o
oo##oo
.oooo.
"""

DEG_RING3 = """
ooooo
o###o
o#o#o
o###o
ooooo
"""

DEG_RING2 = """
oooo
o##o
o##o
oooo
"""

# font -> [gap before/after the ring, ring width, art]. The ring is sized to
# the font's stroke weight: a 1px ring beside a 16x20 digit reads as dirt.
DEG_ART = {
    "16x20": [2, 6, DEG_RING6],
    "10x16": [1, 4, DEG_RING4],
    "8x12": [1, 4, DEG_RING4],
    "6x8": [1, 3, DEG_RING3],
    "5x7": [1, 3, DEG_RING3],
    "4x7": [1, 3, DEG_RING3],
    "4x5": [1, 2, DEG_RING2],
}

# Top row of the hero so its ink always bottoms out on row 20, whichever font
# the ladder picks: digits fill their box, so this is boxheight - 20.
HERO_Y = {"16x20": 1, "10x16": 6}


def dtext(c, s, x, y, font = "5x7", color = "white", stroke = None,
          draw = True):
    """Draw `s` at (x, y) with every U+00B0 painted as the baked degree ring
    for `font`; returns the run's total ink width.

    Call it with draw = False to measure only. Measuring and drawing share
    this one code path on purpose - a centred or right-aligned run can then
    never disagree with what actually lands on the panel."""
    parts = s.split("°")
    a = DEG_ART.get(font)
    cx = x
    for i in range(len(parts)):
        p = parts[i]
        if p != "":
            if draw:
                if stroke != None:
                    c.text_stroke(p, cx, y, font = font, color = color,
                                  stroke = stroke)
                else:
                    c.text(p, cx, y, font = font, color = color)
            cx += c.text_width(p, font)
        if i < len(parts) - 1 and a != None:
            cx += a[0]
            if draw:
                c.sprite(a[2], cx - 1, y - 1,
                         legend = {"#": color, "o": stroke})
            cx += a[1]
            if parts[i + 1] != "":
                cx += a[0]
    return cx - x


def dtext_w(c, s, font):
    """Ink width of a degree run, ring included."""
    return dtext(c, s, 0, 0, font = font, draw = False)


def dfit(c, s, fonts, maxw):
    """Largest font whose degree run fits `maxw`; the smallest as a fallback."""
    for f in fonts:
        if dtext_w(c, s, f) <= maxw:
            return f
    return fonts[len(fonts) - 1]


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


def whole(v):
    """A feed number as a whole-degree string, blanks and nulls included."""
    return str(int(float(v or 0)))


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


def art_at(c, name, x, y, n):
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


def key_at(c, name, x, y, n):
    """The same art as a flat black silhouette - every opaque pixel of the
    drawing, painted black, transparent everywhere else.

    Each *_KEY.png is machine-derived from its art's own alpha channel, so the
    two shapes can never drift apart the way a hand-drawn outline would."""
    if name == "SUN":
        c.image("SUN_KEY.png", x, y, w = n, h = n)
    elif name == "PARTLY":
        c.image("PARTLY_KEY.png", x, y, w = n, h = n)
    elif name == "CLOUD":
        c.image("CLOUD_KEY.png", x, y, w = n, h = n)
    elif name == "RAIN":
        c.image("RAIN_KEY.png", x, y, w = n, h = n)
    elif name == "SNOW":
        c.image("SNOW_KEY.png", x, y, w = n, h = n)
    elif name == "STORM":
        c.image("STORM_KEY.png", x, y, w = n, h = n)
    else:
        c.image("FOG_KEY.png", x, y, w = n, h = n)


def sprite_at(c, name, x, y, n):
    """Weather art with a continuous 1px black keyline around its silhouette.

    This is c.text_stroke's rule applied to pixel art: stamp the black
    silhouette at all eight neighbours of the target cell, then lay the art
    on top. Every art pixel that borders empty sky - orthogonally or
    diagonally - ends up with a black pixel outside it, so the drawing keeps
    its own edge against a sky wash the way the stroked strings do.

    Doing it in canvas space rather than baking a border into the PNG means
    the keyline is exactly 1px at every size the art is drawn at (24 on NOW,
    16 and 12 on FORECAST); a baked border would be scaled along with the art
    and blur away on the small per-day icons.

    The keyline occupies the ring x-1..x+n, y-1..y+n, so callers place the art
    one pixel inside whatever bound they are respecting."""
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            if dx != 0 or dy != 0:
                key_at(c, name, x + dx, y + dy, n)
    art_at(c, name, x, y, n)


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
    ts = str(temp) + "°"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, w[2], w[3],
                    horizontal = False)

    if c.width >= 128:
        # Vertical bands, ink rows, all measured against a 20-row hero:
        #   art   4-27 | hero 1-20 | label 23-30
        #   place 2-8  | H 12-19   | L 22-29
        # The shipped version put the hero at y=4 (ink 4-23) and "CLEAR" at
        # y=23, so the two shared row 23 and the label lost its top row into
        # the temperature. Every gap below is at least 2 ink rows.
        # The art sits one pixel inside SAFE_L so its keyline, not its ink,
        # is what lands on column 10 - the outline is content too.
        n = 24
        ax = SAFE_L + 1
        sprite_at(c, w[0], ax, 4, n)              # ink 11-34, keyline 10-35
        hx = ax + n + 5                           # 40: 5px clear of the art

        # The right column is measured first, because its left edge is what
        # bounds the hero and the condition label. "H -100" is 41px at 6x8
        # plus a 3px ring and its gap, so the block is 45px on a bad day.
        hs = "H " + whole(hi[0]) + "°"
        ls = "L " + whole(lo[0]) + "°"
        hw = dtext_w(c, hs, "6x8")
        lw = dtext_w(c, ls, "6x8")
        rl = SAFE_R - max(hw, lw)
        dtext(c, hs, SAFE_R - hw, 12, font = "6x8", color = "#FFD86A",
              stroke = "black")
        dtext(c, ls, SAFE_R - lw, 22, font = "6x8", color = "#9FD0FF",
              stroke = "black")

        # 3px keeps the hero's black outline clear of the H/L outline.
        box = rl - hx - 3
        hf = dfit(c, ts, ["16x20", "10x16"], box)
        tw = dtext(c, ts, hx, HERO_Y[hf], font = hf, color = "#FFFFFF",
                   stroke = "black")

        # The place name is right-aligned into whatever the hero left over —
        # "TRUTH OR CONSEQUENCES" is 125px at 5x7 and would have run straight
        # through the temperature, so it drops to 4x5 and then hard-clips.
        # The 4 is the hero's outline, the name's outline, and 2 clear pixels.
        cf = _fit_clip(c, g[2], ["5x7", "4x5"], SAFE_R - hx - tw - 4)
        c.text_stroke(cf[1], SAFE_R, 2, font = cf[0], color = "#DCE6F4",
                      stroke = "black", align = "right")

        lf = _fit_clip(c, w[1], ["6x8", "5x7", "4x5"], box)
        c.text_stroke(lf[1], hx, 23, font = lf[0], color = "#DCE6F4",
                      stroke = "black")
    else:
        # 64: art 5-20 | hero 1-20 (right-aligned) | label 24-30.
        n = 16
        sprite_at(c, w[0], 1, 5, n)               # ink 1-16, keyline 0-17
        hx = 20                                   # 2px clear of the keyline
        hf = dfit(c, ts, ["16x20", "10x16"], c.width - 2 - hx)
        tw = dtext_w(c, ts, hf)
        dtext(c, ts, c.width - 2 - tw, HERO_Y[hf], font = hf,
              color = "#FFFFFF", stroke = "black")
        lf = _fit_clip(c, w[4], ["5x7", "4x5"], c.width - 4)
        c.text_stroke(lf[1], c.width // 2, 24, font = lf[0], color = "#DCE6F4",
                      stroke = "black", align = "center")


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

    c.fill("#05070C")
    show = days - 1 if days > 1 else 1
    if c.width < 128:
        show = show if show < 3 else 3

    # Columns are cut from the safe zone, not from the full canvas, so the
    # outer edges stay black and the app does not merge with its neighbours.
    bl = SAFE_L if c.width >= 128 else 0
    br = SAFE_R if c.width >= 128 else c.width - 1
    span = br - bl + 1
    n = 16 if c.width >= 128 else 12
    names = ["TOMORROW", "DAY 2", "DAY 3"]

    for i in range(show):
        k = i + 1
        w = wmo(int(codes[k] or 0))
        x0 = bl + (span * i) // show
        x1 = bl + (span * (i + 1)) // show - 1
        cw = x1 - x0 + 1
        cx = x0 + cw // 2

        # Each day wears its own sky, dimmed to a near-black wash: the column
        # reads as weather before a digit is read, and stays dark enough that
        # stroked white text keeps black-background contrast.
        c.gradient_rect(x0, 0, x1, c.height - 1, color.dim(w[2], 30),
                        color.dim(w[3], 45), horizontal = False)
        if i > 0:
            c.vline(x0 - 1, 0, c.height, "#05070C")

        # Row 1 is the highest the art can start: its keyline needs row 0.
        sprite_at(c, w[0], cx - n // 2, 1, n)
        his = whole(hi[k]) + "°"
        los = whole(lo[k]) + "°"
        if c.width >= 128:
            # Ink rows: art 1-16 (keyline 0-17) | name 18-22 | temps 24-30.
            # A 5x7 temp row at y=25 would put its stroke on row 32, one past
            # the panel.
            c.text_stroke(names[i], cx, 18, font = "4x5", color = "#B9C6DC",
                          stroke = "black", align = "center")
            # Amber high, blue low, drawn as two runs so the colors survive —
            # "-100/-100" is 61px at 5x7 with its rings and drops to 4x7.
            f = _hilo_font(c, his, los, cw - 4)
            _hilo(c, his, los, cx, 24, f)
        else:
            # 64 stacks the pair instead: ink rows art 1-12 | hi 15-21 |
            # lo 24-30. A 5x7 low at y=25 puts its stroke on row 32, and a
            # 20px column cannot hold "-45°" at 5x7 anyway, so both rows are
            # laddered on their measured width.
            f = dfit(c, his, ["5x7", "4x7", "4x5"], cw - 2)
            tw = dtext_w(c, his, f)
            dtext(c, his, cx - tw // 2, 15, font = f, color = "#FFD86A",
                  stroke = "black")
            f = dfit(c, los, ["5x7", "4x7", "4x5"], cw - 2)
            tw = dtext_w(c, los, f)
            dtext(c, los, cx - tw // 2, 24, font = f, color = "#9FD0FF",
                  stroke = "black")


def _hilo_w(c, his, los, font):
    """Width of "<hi>/<lo>" drawn as three runs: the two 1px seams between
    them are the inter-glyph spacing drawText would have added itself."""
    return (dtext_w(c, his, font) + 1 + c.text_width("/", font) + 1 +
            dtext_w(c, los, font))


def _hilo_font(c, his, los, maxw):
    fonts = ["5x7", "4x7", "4x5"]
    for f in fonts:
        if _hilo_w(c, his, los, f) <= maxw:
            return f
    return fonts[len(fonts) - 1]


def _hilo(c, his, los, cx, y, font):
    """High / low centred on cx, each half keeping its own color."""
    x = cx - _hilo_w(c, his, los, font) // 2
    x += dtext(c, his, x, y, font = font, color = "#FFD86A",
               stroke = "black") + 1
    c.text_stroke("/", x, y, font = font, color = "#5F6E88", stroke = "black")
    x += c.text_width("/", font) + 1
    dtext(c, los, x, y, font = font, color = "#9FD0FF", stroke = "black")
