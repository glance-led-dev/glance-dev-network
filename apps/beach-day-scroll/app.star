# Beach Day
#
# DESIGN. The panel is a beach postcard, not a dashboard: a full-width
# sky/sea/sand scene carries the forecast as weather you can *see* -- blue
# gradient with a sun when the day is worth going, flat grey with a raining
# cloud when it is not -- and a row of striped umbrellas stands on the sand.
# Every glyph on top of that scene is drawn with drawTextWithStroke (black),
# which is what makes white/amber type survive a bright sky.
#
# Four things decide a beach day and no single one of them settles it, so
# they are scored together: warmth, low rain chance, gentle wind, and enough
# UV to be worth the sunscreen but not so much it is punishing.
#
# Reading order, left to right:
#   [ 53 ] BEACH/SCORE/<place>   [ 82 deg F ]   [ sun ]
#   [ PERFECT pill ]      ~ umbrellas ~     [ drop 10% / gusts 8 MPH ]
# The hero number is the 0-100 beach score -- it is NOT a temperature, so it
# carries the words BEACH SCORE and never a degree ring. The temperature is
# the second number and it is the one that wears the degree ring plus F/C, so
# the two large numbers can never be mistaken for each other (the previous
# build showed "53" and "102" with no label on either, and the degree sign it
# asked for was U+00B0 -- a codepoint no GDN bitmap font has, so it silently
# drew nothing. The ring here is pixel art for exactly that reason).


# ---------------------------------------------------------------- geometry
# Scroll safe zone: the scene is inset SCENE_PAD from both edges so the app
# reads as its own card between neighbours in the rotation, and all type sits
# inside x = TEXT_L .. (width - TEXT_R_PAD), i.e. 10..182 on a 192.
SCENE_PAD = 4
TEXT_L = 10
TEXT_R_PAD = 10          # last ink column = width - TEXT_R_PAD

SKY_BOT = 19             # sky   rows 0..19
SEA_BOT = 24             # sea   rows 20..24
                         # sand  rows 25..31

HERO_X = 10
HERO_Y = 1               # 16x20 digits ink rows 1..20 (stroke 0..21)
LBL_X = 64               # label column: BEACH / SCORE / place
LBL_Y1 = 3
LBL_Y2 = 10
LOC_Y = 17
LOC_MAX = 30             # "MALIBU" is 29px at 4x5; anything wider falls back
                         # to the zip, so the column can never reach the
                         # temperature block that starts at x=96.
TEMP_X = 96
TEMP_Y = 3               # 10x16 digits ink rows 3..17
# The degree ring and the F/C ride 2px off the MEASURED end of the digits, not
# a hand-picked x: "-99" is 32px at 10x16 and "8" is 10px, and a fixed ring
# left a 13px hole after every two-digit temperature. Worst case the cluster
# ends at x=140, clear of the rain row (worst-case stroke starts at x=151).
RING_GAP = 2
UNIT_GAP = 2
SUN_CY = 6               # sun/cloud art centre, right-hand sky
RAIN_Y = 15              # 5x7 ink rows 15..21
WIND_Y = 24              # 5x7 ink rows 24..30 (stroke 23..31, on canvas)
PILL_Y = 24              # verdict pill rows 24..30

# Umbrellas: [x, art key, top row]. Drawn unstroked (see draw_umbrellas), so
# the box is the art itself. Chosen so every canopy clears the label column
# (ends x=94, row 22), the temp block and the stat column (worst-case wind
# "199 MPH" puts the gust icon's stroke at x=141; the last umbrella ends 134).
UMBRELLAS = [
    [57, "S", 23], [67, "B", 24], [85, "M", 25],
    [99, "B", 24], [116, "S", 23], [126, "M", 25],
]
BALL_X = 136             # a ball bobbing in the surf, clear of the wind row
BALL_Y = 20


# ---------------------------------------------------------------- pixel art
# Canopy stripes alternate every two columns, so the same two-colour legend
# reads as a beach umbrella at all three sizes.
UMB_B = """
......P......
...2112211...
.12211221122.
1122112211221
......P......
......P......
......P......
......P......
"""

UMB_M = """
....P....
..22112..
.1221122.
112211221
....P....
....P....
....P....
"""

UMB_S = """
...P...
.12211.
1122112
...P...
...P...
...P...
"""

# Shade pools. Each one lies on the sand directly under its canopy, starting on
# the row below the fan and never reaching wider than the fan itself. A solid
# row followed by a stippled one gives the shadow an edge that falls off into
# the sand, which is what keeps it reading as shade rather than as a black box
# stamped on the beach (two solid rows read as a dark base under the canopy).
# Drawn BEFORE the umbrella, so the pole is painted back over its own shadow
# and passes straight through it.
SHD_B = """
.HHHHHHHHHHH.
..H.H.H.H.H..
"""

SHD_M = """
.HHHHHHH.
..H.H.H..
"""

SHD_S = """
.HHHHH.
..H.H..
"""

# 4x4 ring; the 8-way stroke pass fills the hole and the rim, so it lands as
# a 6x6 degree sign that matches the black stroke on the digits beside it.
RING = """
.CC.
C..C
C..C
.CC.
"""

RING_SM = """
.C.
C.C
.C.
"""

SUN = """
..CCC..
.CCCCC.
CCCCCCC
CCCCCCC
CCCCCCC
.CCCCC.
..CCC..
"""

# Detached sparks around the disc; drawn unstroked because yellow on sky is
# already high contrast and a stroked single pixel reads as a black blob.
SUN_RAYS = [
    [0, -6], [0, -5], [0, 5], [0, 6], [-6, 0], [-5, 0], [5, 0], [6, 0],
    [-5, -5], [5, -5], [-5, 5], [5, 5],
]

CLOUD = """
...WWW...WW..
..WWWWWWWWWW.
.WWWWWWWWWWWW
WWWWWWWWWWWWW
.DDDDDDDDDDD.
"""

CLOUD_RAIN = """
...WWW...WW..
..WWWWWWWWWW.
.WWWWWWWWWWWW
WWWWWWWWWWWWW
.DDDDDDDDDDD.
..R...R...R..
.R...R...R...
R...R...R....
"""

DROP = """
..C..
..C..
.CCC.
CCCCC
CCCCC
.CCC.
"""

# Three offset gust lines. A pennant was tried first and read as a capital
# letter next to the speed ("F13 MPH"); staggered lines can't be misread.
WINDY = """
CCCCC.
......
.CCCCC
......
CCCC..
"""

BALL = """
.12.
1221
2112
.21.
"""

STROKE_OFFSETS = [[-1, -1], [0, -1], [1, -1], [-1, 0],
                  [1, 0], [-1, 1], [0, 1], [1, 1]]


def art(c, s, x, y, legend, stroke = "black"):
    """Pixel art with an outline, the sprite twin of drawTextWithStroke.

    Eight offset silhouette passes in `stroke`, then the real legend on top:
    the art keeps a 1px outline against the sky/sea/sand behind it. Every
    placement below budgets for that extra pixel on each side."""
    for o in STROKE_OFFSETS:
        c.sprite(s, x + o[0], y + o[1], color = stroke)
    c.sprite(s, x, y, legend = legend)


# ---------------------------------------------------------------- palettes
def conditions(rain, uv, total):
    """One banded [state] decision, so the sky and the verdict can't disagree."""
    if rain >= 55:
        return "STORM"
    if rain >= 25 or uv < 2.5 or total < 45:
        return "HAZY"
    return "SUNNY"


def palette(cond):
    """Scene colors per condition: sunny blue gradient, hazy wash, grey storm."""
    if cond == "STORM":
        return {
            "sky1": "#232830", "sky2": "#68717C", "horizon": "#8C97A2",
            "sea1": "#2C3640", "sea2": "#465360", "crest": "#93A0AD",
            "foam": "#AEB8C2", "sand1": "#6E6656", "sand2": "#4C463B",
            "shade": "#221F19",
            "sun": "#C9D2DC", "rim": "#12161C", "pole": "#4E4A44",
            "umb": [["#8A6A68", "#C2C7CC"], ["#6F7A86", "#BFC6CD"],
                    ["#7E7466", "#C7C2B4"]],
        }
    if cond == "HAZY":
        return {
            "sky1": "#3F5E7C", "sky2": "#A8BECD", "horizon": "#C2D6E0",
            "sea1": "#2E5B72", "sea2": "#4C8296", "crest": "#D3E3EA",
            "foam": "#E6EEF2", "sand1": "#C7B48C", "sand2": "#9A8763",
            "shade": "#453922",
            "sun": "#FFD23F", "rim": "#B4600E", "pole": "#6B4A2B",
            "umb": [["#D2453C", "#F0EDE6"], ["#E0A81C", "#F4F1E8"],
                    ["#2E93AC", "#F0E7D2"]],
        }
    return {
        "sky1": "#0F5AA8", "sky2": "#8FD3F5", "horizon": "#B7E7FB",
        "sea1": "#0B4E78", "sea2": "#1B8FB4", "crest": "#CFF2FF",
        "foam": "#EAFBFF", "sand1": "#E3C489", "sand2": "#B8905A",
        "shade": "#3A2910",
        "sun": "#FFD23F", "rim": "#D2610C", "pole": "#7A5230",
        "umb": [["#E5372F", "#FFFFFF"], ["#FFC21A", "#FFFFFF"],
                ["#12A5C4", "#FFF3D6"]],
    }


def draw_scene(c, pal, cond):
    """Sky / sea / sand bands, whitecaps, and the sun-or-raincloud overhead."""
    c.fill("#04060A")                       # gutters outside the scene card
    x0 = SCENE_PAD if c.width >= 128 else 0   # 64 maximizes space: full bleed
    x1 = c.width - 1 - x0
    span = x1 - x0 + 1
    c.gradient_rect(x0, 0, x1, SKY_BOT, pal["sky1"], pal["sky2"],
                    horizontal = False)
    c.gradient_rect(x0, SKY_BOT + 1, x1, SEA_BOT, pal["sea1"], pal["sea2"],
                    horizontal = False)
    c.gradient_rect(x0, SEA_BOT + 1, x1, c.height - 1, pal["sand1"],
                    pal["sand2"], horizontal = False)
    c.hline(x0, SKY_BOT + 1, span, pal["horizon"])

    # Whitecaps: two staggered dash rows plus a foam line at the water's edge.
    for i in range(0, span):
        x = x0 + i
        if i % 13 < 3:
            c.pixel(x, SKY_BOT + 3, pal["crest"])
        if (i + 6) % 11 < 2:
            c.pixel(x, SKY_BOT + 5, pal["crest"])
        if (i + 3) % 7 < 4:
            c.pixel(x, SEA_BOT, pal["foam"])

    # Wide: the free right-hand sky above the stat column. Narrow: the left
    # sky beside the centred hero, because the verdict pill owns the top row.
    cx = c.width - 34
    cy = SUN_CY
    if c.width < 128:
        cx = 8
        cy = SUN_CY + 7
    if cond == "STORM":
        art(c, CLOUD_RAIN, cx - 6, cy - 4,
            {"W": pal["sun"], "D": "#8D98A5", "R": "#9FB6C9"}, pal["rim"])
        return
    art(c, SUN, cx - 3, cy - 3, {"C": pal["sun"]}, pal["rim"])
    for r in SUN_RAYS:
        c.pixel(cx + r[0], cy + r[1], pal["sun"])
    if cond == "HAZY":
        art(c, CLOUD, cx - 6, cy + 1,
            {"W": "#E4EAF0", "D": "#A9B4C0"}, pal["rim"])
    elif c.width >= 128:
        # glitter path: the sun's reflection on the water, sunny days only
        for g in [[-1, 2], [2, 2], [0, 3], [3, 3], [1, 4]]:
            c.pixel(cx + g[0], SKY_BOT + 1 + g[1], pal["foam"])


def draw_umbrellas(c, pal):
    """Six striped umbrellas and a beach ball on the sand.

    Sizes are mixed and the small ones stand a row higher, so the sand reads
    as depth rather than a row of identical stamps.

    The umbrellas are scenery, not type: they are drawn UNSTROKED (plain
    c.sprite, no black silhouette pass) so they sit in the background the way
    the sky and sea do. The black keyline is reserved for the foreground
    glyphs -- an outline on a 7px canopy read as a sticker pasted over the
    sand instead of part of it. The ball in the surf is scenery on the same
    terms, so it is unstroked too.

    Each umbrella lays a shade pool on the sand first, spanning only the fan
    above it and tapering as it recedes; the umbrella is then drawn over the
    top, which is what puts the pole back through the middle of its own shadow.

    kinds: [canopy art, shade art, shade top offset from the umbrella's top
    row]. The offset is the fan's last row + 1, so the shade always starts
    immediately under the canopy: B/M fan rows 1..3, S fan rows 1..2."""
    kinds = {"B": [UMB_B, SHD_B, 4], "M": [UMB_M, SHD_M, 4],
             "S": [UMB_S, SHD_S, 3]}
    n = 0
    for u in UMBRELLAS:
        pair = pal["umb"][n % len(pal["umb"])]
        k = kinds[u[1]]
        c.sprite(k[1], u[0], u[2] + k[2], legend = {"H": pal["shade"]})
        c.sprite(k[0], u[0], u[2],
                 legend = {"1": pair[0], "2": pair[1], "P": pal["pole"]})
        n = n + 1
    c.sprite(BALL, BALL_X, BALL_Y,
             legend = {"1": "#FFFFFF", "2": pal["umb"][0][0]})


# ---------------------------------------------------------------- data
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

    The two lines get explicit, non-overlapping bands - a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text_stroke(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
                      stroke = "black", align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
                      stroke = "black", align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text_stroke(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
                      stroke = "black", align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text_stroke(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
                      stroke = "black", align = "center")


def verdict_of(total):
    """[word, color] from one function, so the pill and the hero agree."""
    if total >= 75:
        return ["PERFECT", "#4EE38A"]
    if total >= 55:
        return ["GOOD", "#F5D64E"]
    if total >= 35:
        return ["SO-SO", "#FF9A4A"]
    return ["STAY HOME", "#FF5B5B"]


def clamp(v, lo, hi):
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v


# ---------------------------------------------------------------- page
def score(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    metric = str(ctx.inputs.get("units", "IMPERIAL")).upper() == "METRIC"
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "temperature_2m_max,precipitation_probability_max,wind_speed_10m_max,uv_index_max",
                           "temperature_unit": "celsius" if metric else "fahrenheit",
                           "wind_speed_unit": "kmh" if metric else "mph",
                           "timezone": "auto", "forecast_days": "1"},
                 ttl_seconds = 3600)   # matches refresh: 3600 in the manifest
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "NO CONNECTION")
        return
    d = r["json"].get("daily", {})

    def first(key):
        v = d.get(key, [])
        return float(v[0] or 0) if len(v) > 0 and v[0] != None else 0.0

    temp = first("temperature_2m_max")
    rain = first("precipitation_probability_max")
    wind = first("wind_speed_10m_max")
    uv = first("uv_index_max")

    tempf = temp if not metric else temp * 9 / 5 + 32
    windm = wind if not metric else wind * 0.621371

    # Warmth carries the most weight; rain is the strongest veto.
    warm = 100.0 - abs(tempf - 82.0) * 4.0
    if warm < 0:
        warm = 0.0
    dry = 100.0 - rain
    calm = 100.0 - windm * 4.0
    if calm < 0:
        calm = 0.0
    sun = 100.0 - abs(uv - 6.0) * 12.0
    if sun < 0:
        sun = 0.0
    total = int(clamp(warm * 0.40 + dry * 0.30 + calm * 0.20 + sun * 0.10,
                      0, 100))

    v = verdict_of(total)
    cond = conditions(rain, uv, total)
    pal = palette(cond)

    # Every displayed number is clamped to the digit count the layout was
    # measured for: a bad feed value must not widen a block into its neighbour.
    tval = str(int(clamp(temp, -99, 199)))
    rval = str(int(clamp(rain, 0, 100))) + "%"
    wval = str(int(clamp(wind, 0, 999)))
    unit = "C" if metric else "F"
    wunit = "KMH" if metric else "MPH"

    draw_scene(c, pal, cond)

    if c.width >= 128:
        draw_umbrellas(c, pal)
        right = c.width - TEXT_R_PAD          # last ink column for the stats

        # Hero: the beach score, 0-100. Worst case "100" is 50px at 16x20.
        c.text_stroke(str(total), HERO_X, HERO_Y, font = "16x20",
                      color = v[1], stroke = "black")
        # ...and the two words that say what that number is.
        c.text_stroke("BEACH", LBL_X, LBL_Y1, font = "4x5", color = "#DCEAF6",
                      stroke = "black")
        c.text_stroke("SCORE", LBL_X, LBL_Y2, font = "4x5", color = "#DCEAF6",
                      stroke = "black")
        # Location, because a weather app that won't say where it is reads as
        # a bug. "MALIBU" is 29px and fits; "SAN FRANCISCO" is 62px, so wide
        # (or blank) place names fall back to the zip, which is always 5
        # digits and can never reach the temperature block.
        loc = g[2]
        if loc == "" or c.text_width(loc, "4x5") > LOC_MAX:
            loc = str(ctx.inputs.get("zip", "")).strip()
        lc = _fit_clip(c, loc, ["4x5"], LOC_MAX)
        c.text_stroke(lc[1], LBL_X, LOC_Y, font = lc[0], color = "#FFE9A8",
                      stroke = "black")

        # Temperature: digits + degree ring + F/C, the only number here that
        # is allowed to wear a degree sign.
        c.text_stroke(tval, TEMP_X, TEMP_Y, font = "10x16", color = "white",
                      stroke = "black")
        rx = TEMP_X + c.text_width(tval, "10x16") + RING_GAP
        art(c, RING, rx, TEMP_Y, {"C": "white"}, "black")
        c.text_stroke(unit, rx + 4 + UNIT_GAP, TEMP_Y, font = "5x7",
                      color = "white", stroke = "black")

        # Rain: drop + percentage, right-aligned so the longest value ("100%",
        # 23px) still starts inside the safe zone.
        rw = c.text_width(rval, "5x7")
        c.text_stroke(rval, right + 1, RAIN_Y, font = "5x7", color = "white",
                      stroke = "black", align = "right")
        art(c, DROP, right - rw - 7, RAIN_Y + 1, {"C": "#8AD4FF"}, "black")

        # Wind: gust lines + speed + unit. Worst case ("199 MPH", 4x5 unit)
        # puts the icon's stroke at x=141, clear of the last umbrella (135).
        uw = c.text_width(wunit, "4x5")
        ww = c.text_width(wval, "5x7")
        c.text_stroke(wunit, right + 1, WIND_Y + 2, font = "4x5",
                      color = "#CFE4F2", stroke = "black", align = "right")
        c.text_stroke(wval, right - uw - 1, WIND_Y, font = "5x7",
                      color = "white", stroke = "black", align = "right")
        art(c, WINDY, right - uw - ww - 9, WIND_Y + 2, {"C": "#E8F4FF"},
            "black")

        # Verdict pill: black on the state color, so it reads at 30 feet even
        # against bright sand.
        c.badge(v[0], TEXT_L, PILL_Y, color = "black", bg = v[1],
                font = "4x5", pad = 2)
    else:
        # 64 wide: the umbrellas and the stat column are dropped rather than
        # squeezed - the sky art carries the conditions, the pill carries the
        # verdict, and the three surviving elements get whole bands:
        # 0-6 pill | 8-22 score | 26-30 label + temperature.
        pw = c.text_width(v[0], "4x5") + 4
        c.badge(v[0], (c.width - pw) // 2, 0, color = "black", bg = v[1],
                font = "4x5", pad = 2)
        c.text_stroke(str(total), c.width // 2, 8, font = "10x16",
                      color = v[1], stroke = "black", align = "center")
        c.text_stroke("SCORE", 2, 26, font = "4x5", color = "#DCEAF6",
                      stroke = "black")
        # Right-aligned temperature cluster, measured back from the edge:
        # [digits] gap [3px ring] gap [F/C]. "-99" + "C" is 26px, so it can
        # never reach "SCORE" (ink ends x=26).
        ux = c.width - 2 - c.text_width(unit, "4x5") + 1
        c.text_stroke(unit, ux, 26, font = "4x5", color = "white",
                      stroke = "black")
        art(c, RING_SM, ux - 5, 26, {"C": "white"}, "black")
        c.text_stroke(tval, ux - 7, 26, font = "4x5", color = "white",
                      stroke = "black", align = "right")
