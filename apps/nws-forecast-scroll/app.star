# NWS Forecast
#
# api.weather.gov in two hops: the point lookup returns the grid
# office and cell, the gridpoint returns the forecast. Both are
# cached hard because the grid assignment for a zip never changes.
#
# The value here over a raw model feed is the wording: NWS writes
# 'showers likely after 2pm', which is more useful on a wall than a
# WMO code and a probability.
#
# DESIGN. A weather sprite on the left, the NWS sentence in the middle at the
# biggest face that will hold it, and the reading itself parked top-right in
# 16x20 with a degree ring after it. Three things only, each in its own
# column, on a near-black vertical gradient rather than a black ground so the
# panel reads as sky. Two rules drive every number below:
#
#   1. Every glyph on the gradient is drawn with c.text_stroke. A gradient is
#      a colored background, and #7C90B0 label text on #1E3350 is a soft edge
#      at ten feet; the black halo restores the black-ground contrast around
#      each letter. The degree ring gets the same halo (art_stroke) so it
#      reads as part of the number rather than as a separate object.
#   2. The right column is measured before the middle one is drawn. The
#      temperature group is the widest thing on the panel that changes size --
#      "84" is 33px at 16x20 and "-40" is 50px -- so the sentence gets
#      whatever is left, never a hand-picked width.



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
    on the panel ran straight through the line beneath it. Both are stroked
    like every other string in this app, which on the #0B0C12 ground reads as
    a faint shadow and keeps one text routine for the whole file.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text_stroke(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
                      align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
                      align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text_stroke(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
                      align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
                      align = "center")


FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}

# Stacked stroked rows need one more row of air than bare ones: the halo adds
# a pixel under line N and above line N+1, so a gap of 1 put two halos in the
# same row. 2 leaves the ink two clear rows apart and the halos merely
# touching.
ROWGAP = 2


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
    """Draw stroked text at the largest font whose wrapped lines fit maxh."""
    words = str(text).upper().split(" ")
    for f in fonts:
        lines = wrap(c, words, f, maxw)
        if len(lines) * (FONTH[f] + gap) - gap <= maxh:
            for i in range(len(lines)):
                c.text_stroke(lines[i], x, y + i * (FONTH[f] + gap), font = f,
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
        c.text_stroke(line, x, y + i * (FONTH[f] + gap), font = f,
                      color = color)
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


# --- the degree glyph the fonts do not have --------------------------------
#
# fonts.json is uppercase, digits and a handful of punctuation: there is no
# U+00B0 in 16x20 or in 10x16, so `str(temp) + "°"` silently dropped the
# character and the panel showed a bare 84 — a magic number, by the
# guidelines, on an app whose whole job is a temperature. These two rings are
# the missing glyph as pixel art, cut to the face each one sits beside:
# 16x20's strokes are 4px and its counters round, so the hero ring is 8x8 with
# 2px walls and clipped corners; 10x16's are 3px, so the small ring is 6x6.
DEG_HERO = """
..####..
.######.
##....##
##....##
##....##
##....##
.######.
..####..
"""
DEG_HERO_W = 8

DEG_SMALL = """
..##..
.####.
##..##
##..##
.####.
..##..
"""
DEG_SMALL_W = 6

# Columns between the last digit and the ring. The faces advance 1px between
# glyphs; 2 sets the ring just off the number the way a real degree sign sits,
# and the two black halos meet in the column between.
DEG_GAP = 2


def art_stroke(c, art, x, y, color, stroke = "black"):
    """c.text_stroke, for pixel art: the same 1px halo in the same order.

    Without it the ring is the one mark on the gradient with no outline, and
    at 8px against #1E3350 it reads as dirt on the panel instead of as the
    tail of the number."""
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            if dx != 0 or dy != 0:
                c.sprite(art, x + dx, y + dy, color = stroke)
    c.sprite(art, x, y, color = color)


def temp_group_w(c, s, font, degw):
    """Width of the number plus its degree ring, halos excluded."""
    return c.text_width(s, font) + DEG_GAP + degw


def draw_temp(c, s, right, y, font, art, degw, color):
    """Draw `s` + the ring as one group ending at `right`; return its left x.

    Right-aligning the GROUP rather than the digits is what keeps the ring on
    the panel: hang a fixed-x ring off a right-aligned number and the first
    three-character reading of the year ("-40", or 100+ in the desert) pushes
    it into the border, where the renderer clips it without a word."""
    x = right - temp_group_w(c, s, font, degw)
    c.text_stroke(s, x, y, font = font, color = color)
    art_stroke(c, art, x + c.text_width(s, font) + DEG_GAP, y, color)
    return x


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


# The art is the one thing on the panel with no outline, and on a lit
# gradient a pale cloud against #1E3350 has the same soft edge the label text
# had before it was stroked. So every PNG now carries a 1px black keyline,
# baked from its own alpha: every transparent pixel 8-neighbour adjacent to an
# opaque one is black. Deriving the edge from the silhouette rather than
# hand-drawing it means a future art edit only has to be re-baked, and thin
# marks -- the raindrops, the bolt, the snowflakes -- get the same edge as the
# cloud body.
#
# The keyline is grown OUTWARD, not carved out of the art: the files are
# 26x26 with the 24x24 drawing still at 1:1 in the middle. KEYLINE below is
# what that padding costs, so sprite_at can take the same 24px art box every
# call site already passes and place the padded file one pixel back — the art
# lands on exactly the pixel it landed on before the keyline existed.
KEYLINE = 1


def sprite_at(c, name, x, y, n):
    x = x - KEYLINE
    y = y - KEYLINE
    n = n + 2 * KEYLINE
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


# 192 is a SCROLL panel: an unknown app plays on either side of this one, so
# the composition sits EDGE px in from both borders instead of running to the
# glass. 64 is a whole panel to itself and maximizes the space instead.
EDGE = 9
EDGE_N = 2

# Clear columns kept between one element's ink and the next one's. 3 leaves a
# clear column either side of the two 1px halos that meet in between.
GAPX = 3

NAME_Y = 1      # eyebrow ink 1-5, halo 0-6
BODY_Y = 10     # sentence band 10-30, halo to 31 — one clear row under the eyebrow
BODY_H = 21
TEMP_Y = 1      # 16x20 ink 1-20, halo 0-21
RAIN_Y = 24     # 5x7 ink 24-30, halo 23-31 — row 22 stays clear of the hero
LABEL_Y = 20    # 64 only: 6x8 ink 20-27 under a 10x16 hero ending at row 15


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
    wide = c.width >= 128
    sz = 24 if wide else 16
    icon_x = EDGE if wide else 1
    sprite_at(c, icon, icon_x, (c.height - sz) // 2, sz)
    # Where the middle column may start: past the art, past its own halo.
    tx = icon_x + sz + GAPX + 1

    if wide:
        right = c.width - EDGE          # 183: ink ends at 182, halo at 183

        # Right column first, both rows of it, because both can grow: "-40" is
        # 50px against 33 for "84", and "100% RAIN" is 53px against 34 for
        # "5% RAIN". The sentence then gets the gap that is actually left.
        limit = c.width
        if temp != None:
            limit = draw_temp(c, str(int(temp)), right, TEMP_Y, "16x20",
                              DEG_HERO, DEG_HERO_W, "#FFFFFF")

        pop = p.get("probabilityOfPrecipitation", {})
        chance = pop.get("value", None) if pop != None else None
        if chance != None and int(chance) > 0:
            rain = str(int(chance)) + "% RAIN"
            rain_x = right - c.text_width(rain, "5x7")
            if rain_x < limit:
                limit = rain_x
            c.text_stroke(rain, right, RAIN_Y, font = "5x7",
                          color = "#7FB6E8", align = "right")

        maxw = limit - GAPX - tx
        if maxw > 0:
            c.text_stroke(fitwords(c, name, "4x5", maxw), tx, NAME_Y,
                          font = "4x5", color = "#7C90B0")
            block(c, short, tx, BODY_Y, maxw, BODY_H,
                  ["10x16", "6x8", "5x7", "4x5"], "#DCE6F8", ROWGAP)
    else:
        right = c.width - EDGE_N
        if temp != None:
            draw_temp(c, str(int(temp)), right, TEMP_Y, "10x16",
                      DEG_SMALL, DEG_SMALL_W, "#FFFFFF")
        # The canonical label, so caption and sprite can never disagree. Its
        # width comes off the sprite beside it rather than a constant, because
        # the sprite is 16px here and 24 on the wide build.
        lab = _fit_clip(c, label, ["6x8", "5x7", "4x5"], right - tx)
        c.text_stroke(lab[1], right, LABEL_Y, font = lab[0],
                      color = "#DCE6F8", align = "right")


def now(c, ctx):
    show(c, ctx, 0)


def later(c, ctx):
    show(c, ctx, 1)
