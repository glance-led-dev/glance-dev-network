# Solar Flares
#
# DESIGN. One page, two halves, no splash page of its own. The left 64px is
# the identity block: a SPACE / WEATHER wordmark sitting inside a dark sun —
# a radiating disc with sunspots, baked as a sprite and drawn in near-black
# oranges so it reads as background art rather than a second subject. The
# right 111px is the readout: the GOES flare class as the one hero, a stacked
# X-RAY / FLUX label and an A-B-C-M-X scale pinned to the right edge, and the
# plain-language consequence along the bottom. Ground is flat near-black —
# the old vertical gradient washed the whole strip orange and fought the apps
# either side of it in the rotation.
#
# GOES X-ray flux from NOAA SWPC. Flare class is logarithmic —
# A, B, C, M, X each a factor of ten — so the class letter is far
# more readable than the raw watts per square metre, and M and X
# are the ones that black out HF radio on the daylit side.


# --- geometry ---------------------------------------------------------------
# The safe zone on a 192 is x 10..182 with 6-10px of edge padding. The sun's
# outermost (near-black) ray tips land on x=7 and x=57 and "WEATHER" is 48px
# wide, so every lit pixel of the identity block sits inside the left 64 the
# brief allows, with 7px of left padding; the readout keeps 9px on the right.
SPLASH_W = 64          # identity block: never wider than this
WORD_CX = SPLASH_W // 2    # wordmark and sun share one centre line
SUN_X = WORD_CX - 25   # sprite is 51x32 and its disc sits 25px from its left
SUN_Y = 0
SUN_NARROW_X = 6       # same sprite, centred on a 64 panel
DIV_X = SPLASH_W + 2   # 1px rule between identity and readout
DATA_X = DIV_X + 6     # readout starts 6px clear of the rule
RIGHT = 182            # right-hand limit = safe zone edge, 9px of padding

GROUND = "#04050A"
RULE = "#3A1D06"
LABEL = "#9A6A30"      # dim amber for the tiny labels
SCALE_OFF = "#4A3316"  # unlit rungs of the A-B-C-M-X scale
SCALE_GAP = 3          # blank columns between scale letters

# The sun. Baked here rather than shipped as a PNG so it can be recoloured
# per state and so nothing has to be scaled at render time. Legend runs from
# the photosphere (A) out through the limb (E) to the corona rays (F, G);
# S is a sunspot. Every colour is a dark variant: the renderer has no alpha,
# so "low opacity background art" has to be mixed by hand.
SUN = (
    "                     G                  G" +
    "\n                     G                 GG" +
    "\n                     GG              GGG" +
    "\n                     GG             GGG" +
    "\n                     GGG    G      GGGG" +
    "\n               G     FFF   GG     FGG" +
    "\n               GG    FFFF FFG    FFFG" +
    "\n                GGF  FFFF FFF  FFFFF" +
    "\n                GFFFF FFF FFF FFFFF" +
    "\nGGGGG            FFFF   EEE   FFFF" +
    "\n  GGGGGGG         FFF DDCCCDD FFFF" +
    "\n     GGGGGGFFF    FF DCCCCCCCD FF     GGGG" +
    "\n        GGFFFFFFFFF DCSBBBBBCCD FFFFFGGGG" +
    "\n           FFFFFFFFECSSSAAABBCCEFFFFFGG" +
    "\n              FFFF DCBSAAAAABBCD FFF" +
    "\n                FF DCBBAAAAABBCD F" +
    "\n                 F DCBBAAAAABBCD FF" +
    "\n               FFF DCBBAAAAABBCD FFFF" +
    "\n            GGFFFFFECCBBAAABSCCEFFFFFFFF" +
    "\n          GGGGFFFFF DCCBBBBBCCD FFFFFFFFFGG" +
    "\n         GGGG     FF DCCCCCCCD FF    FFFGGGGGG" +
    "\n                 FFFF DDCCCDD FFF         GGGGGGG" +
    "\n                 FFFF   EEE   FFFF            GGGGG" +
    "\n                FFFFF FFF FFF FFFFG" +
    "\n               FFFFF  FFF FFFF  FGG" +
    "\n              GFFF    GFF FFFF    GG" +
    "\n              GGF     GG   FFF     G" +
    "\n            GGGG      G    GGG" +
    "\n            GGG             GG" +
    "\n           GGG              GG" +
    "\n          GG                 G" +
    "\n          G                  G"
)

SUN_LEGEND = {
    "A": "#B2560B",   # photosphere
    "B": "#9A4809",
    "C": "#7E3907",
    "D": "#602B05",
    "E": "#481F04",   # limb
    "F": "#3E1904",   # inner corona
    "G": "#210D01",   # outer corona
    "S": "#2A1102",   # sunspot
}

CLASSES = ["A", "B", "C", "M", "X"]

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


def flare_class(flux):
    """GOES long-band flux (W/m2) -> [letter, magnitude, colour, wide copy,
    narrow copy].

    Banded pairs from one function, so the colour and the word can never
    disagree. The fifth field is written for 64 rather than clipped from the
    fourth: "RADIO BLACKOUT" is 67px at 4x5 against the 60px a 64 panel has,
    and the only smaller font left, 3x4, has no space glyph — it renders
    "RADIOBLACKOUT"."""
    if flux <= 0:
        return ["--", 0.0, "#5A6078", "NO DATA", "NO DATA"]
    if flux >= 1e-4:
        return ["X", flux / 1e-4, "#FF3B3B", "RADIO BLACKOUT", "BLACKOUT"]
    if flux >= 1e-5:
        return ["M", flux / 1e-5, "#FF9A4A", "BRIEF HF FADES", "HF FADES"]
    if flux >= 1e-6:
        return ["C", flux / 1e-6, "#F5D64E", "MINOR ACTIVITY", "MINOR"]
    if flux >= 1e-7:
        return ["B", flux / 1e-7, "#6FD4FF", "QUIET SUN", "QUIET SUN"]
    return ["A", flux / 1e-8, "#5A8098", "VERY QUIET", "VERY QUIET"]


def class_label(cl):
    """Hero string: B6.9, X28. The decimal is dropped once the magnitude
    reaches double figures. X-class is the only band that gets there, and
    X28.0 is 84px at 16x20 against X28's 50: the tenth of a decade nobody
    reads was costing the hero a third of its width on exactly the day it
    matters."""
    if cl[0] == "--":
        return "--"
    m = cl[1]
    if m >= 10:
        return cl[0] + str(int(m))
    return cl[0] + str(int(m * 10) / 10.0)


def splash(c):
    """The identity block: sun first, wordmark on top of it.

    Both words are stroked black — they sit on the disc, and the guideline
    for text over art is that the stroke, not luck, does the separating. The
    lines are parked at y=1 and y=23 so their stroke boxes (0-9 and 22-31)
    leave the sun's disc (rows 9-22) showing between them instead of burying
    it: a wordmark centred on the disc hid the whole graphic."""
    c.sprite(SUN, SUN_X, SUN_Y, legend = SUN_LEGEND)
    c.text_stroke("SPACE", WORD_CX, 1, font = "6x8", color = "#FFE7B8",
                  stroke = "black", align = "center")
    c.text_stroke("WEATHER", WORD_CX, 23, font = "6x8", color = "#FF9E2E",
                  stroke = "black", align = "center")


def scale_width(c):
    """Measured width of the A-B-C-M-X scale, so the hero can be given
    whatever is left rather than a hand-picked number."""
    lw = c.text_width("A", "5x7")
    return (lw + SCALE_GAP) * (len(CLASSES) - 1) + lw


def class_scale(c, right, y, letter, col):
    """A-B-C-M-X, right-aligned on `right`, live class lit, each letter over
    a rung of track.

    The hero is a letter and a number on a logarithmic scale, which is a
    magic number until something on the panel shows what the letters run
    between — and the lit rung is what makes "B" read as second-from-quiet
    rather than as a word. Letters are rows y..y+6, the track is row y+8."""
    lw = c.text_width("A", "5x7")
    x = right - scale_width(c) + 1
    for i in range(len(CLASSES)):
        col_i = col if CLASSES[i] == letter else SCALE_OFF
        c.text(CLASSES[i], x + i * (lw + SCALE_GAP), y, font = "5x7",
               color = col_i)
        c.hline(x + i * (lw + SCALE_GAP), y + 8, lw, col_i)


def flux(c, ctx):
    r = http.get("https://services.swpc.noaa.gov/json/goes/primary/xrays-6-hour.json",
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO SWPC DATA", "NO CONNECTION")
        return
    rows = r["json"]
    if len(rows) == 0:
        nodata(c, "NO SWPC DATA", "EMPTY FEED")
        return

    # The feed interleaves two energy bands; the long band is the one the
    # flare classification is defined on. Walk back to the newest long-band
    # sample that actually carries flux: SWPC publishes the odd 0.0 row when
    # a satellite drops a minute, and taking the last row blind turned a
    # perfectly healthy quiet sun into "NO DATA" (2026-08-26T17:23Z had two
    # such rows on the end while 17:21Z read 7.46e-7).
    f = 0.0
    for i in range(len(rows) - 1, -1, -1):
        e = str(rows[i].get("energy", ""))
        if e.find("0.1-0.8") >= 0:
            v = float(rows[i].get("flux", 0) or 0)
            if v > 0:
                f = v
                break
    if f <= 0:
        nodata(c, "NO XRAY FLUX", "SWPC FEED GAP")
        return

    cl = flare_class(f)
    label = class_label(cl)

    # Flat near-black ground. The gradient this replaces ran #140C02 -> #301A04
    # over the whole 192 and left no unlit pixels for the sun's dark corona to
    # read against.
    c.fill(GROUND)

    if c.width >= 128:
        splash(c)
        c.vline(DIV_X, 4, 24, RULE)

        # The right-hand column is drawn first and the hero gets whatever is
        # left, because the column is the fixed one: the scale measures 37px,
        # "X-RAY" 24px and "FLUX" 19px at 4x5, all right-aligned on RIGHT.
        # Rows: 1-5 X-RAY | 7-11 FLUX | 13-19 scale | 21 track.
        c.text("X-RAY", RIGHT, 1, font = "4x5", color = LABEL, align = "right")
        c.text("FLUX", RIGHT, 7, font = "4x5", color = LABEL, align = "right")
        class_scale(c, RIGHT, 13, cl[0], cl[2])

        # Hero. Worst case is a 4-character label ("A9.9"/"X9.9" = 67px at
        # 16x20) against the 70px this leaves, so 16x20 survives every value
        # the feed can produce; the ladder stays because nothing from an API
        # gets drawn unmeasured, and it drops to 10x16 rather than run into
        # the scale.
        h = _fit_clip(c, label, ["16x20", "10x16"],
                      RIGHT - scale_width(c) - 3 - DATA_X)
        c.text(h[1], DATA_X, 1, font = h[0], color = cl[2])

        # The consequence, in words, along the bottom. "RADIO BLACKOUT" is the
        # longest string this can produce: 97px at 6x8, so it clears RIGHT by
        # 13px and never needs the smaller rungs — but a longer future string
        # would take them rather than run off the panel.
        s = _fit_clip(c, cl[3], ["6x8", "5x7", "4x5"], RIGHT - DATA_X + 1)
        c.text(s[1], DATA_X, 23, font = s[0], color = cl[2])
    else:
        # 64 keeps the sun and drops the wordmark: two 6x8 words would leave
        # nowhere for the readout, and the sun alone is identity enough at
        # this size. The sprite is 51px wide, so x=6 puts its disc on the
        # panel's centre line.
        c.sprite(SUN, SUN_NARROW_X, SUN_Y, legend = SUN_LEGEND)
        h = _fit_clip(c, label, ["16x20", "10x16"], c.width - 4)
        c.text_stroke(h[1], c.width // 2, 5, font = h[0], color = cl[2],
                      stroke = "black", align = "center")
        s = _fit_clip(c, cl[4], ["4x5"], c.width - 4)
        c.text_stroke(s[1], c.width // 2, 24, font = s[0], color = cl[2],
                      stroke = "black", align = "center")
