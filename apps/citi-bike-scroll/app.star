# Citi Bike
#
# Bikes and docks at one station, from the public GBFS feed. No key.
#
# The station list is baked in rather than fetched. GBFS splits the data in
# two: station_status carries the live counts, station_information carries the
# names -- and information is ~1.36 MB for 2,509 stations, which is a lot of
# bytes to move on every render just to turn an id into a label that never
# changes. Only the status feed is fetched.
#
# DESIGN. Three numbers, ranked: bikes you can ride now is the hero, e-bikes
# rides second, empty slots to dock into rides third -- so the panel answers
# "can I get a bike?" before "can I park?". Every number is labelled by a
# picture rather than a word: the bike is "BIKES", the bolt is "E-BIKES", and
# the dock rack is "SLOTS". Under all of it a bar draws the whole station --
# one segment per physical dock, blue for a bike, yellow for an e-bike, a
# ghost line for an empty slot -- and it is held a clear pixel below every
# glyph and digit on the panel so it reads as a rule, never as a collision.
# White is the resting colour for a live number, which leaves amber and red
# free to mean something the moment they appear.

STATUS_URL = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json"

# Citi blue, lifted from the brand's #0068A5: at LED gamma the darker blue
# muddies against black and the frame stops reading as a frame.
BLUE = "#0E86D6"
YELLOW = "#FFD500"
DIMYELLOW = "#6E5E00"  # the bolt when the station has no e-bike to offer
SLATE = "#55606C"      # tyres and rack -- a dark object, not a hole
CHROME = "#7A8894"     # station name and other inert chrome
GHOST = "#2A343E"      # an empty dock on the bar
RACKCOL = "#5C6E80"    # the dock-rack glyph: a hard object, brighter than GHOST
DIM = "#5A6773"        # a count that is true but has nothing to say (0 e-bikes):
                       # readable, but visibly quieter than a live white number
WHITE = "#FFFFFF"
RED = "#E01A1A"

# Side-on Citi Bike, 25x15. The thick swoop from the head tube down to the
# bottom bracket is the step-through frame, which is what makes this read as a
# Citi Bike rather than a generic bicycle. The white arcs are fenders and the
# white pixel on the front plate is the rack logo.
BIKE = """
................WB.......
......WWW.........B......
........B.........B.T...B
........B.........BTT...W
.......BB.........B.TTTTB
......B..B.......BB......
...WWWB..B......BB.WWW...
..W..BW...B....BB.WB..W..
.T...B.T..B...BB.T.B...T.
T....B..T..B.BB.T...B...T
T...TBBBBBBBBB..T...T...T
T.......T..T....T.......T
.T.....T.........T.....T.
..T...T...........T...T..
...TTT.............TTT...
"""
BIKE_W = 25
BIKE_H = 15

BOLT = """
..YY
.YY.
YYYY
..YY
.YY.
YY..
"""
BOLT_W = 4
BOLT_H = 6

# The dock rack, 9x5: five posts standing on a rail with four empty bays
# between them. This is the word "SLOTS" -- an empty bay you can push a wheel
# into is exactly what the number counts, and it is the same comb rhythm the
# bar below draws once per physical dock. Earlier passes used T-headed posts
# and a two-bay rack; at 9px wide both read as a table, the plain comb reads
# as a rack.
RACK = """
D.D.D.D.D
D.D.D.D.D
D.D.D.D.D
D.D.D.D.D
DDDDDDDDD
"""
RACK_W = 9
RACK_H = 5

NO_ENTRY = """
...RRR...
..RRRRR..
.RRRRRRR.
RRWWWWWRR
RRWWWWWRR
RRWWWWWRR
.RRRRRRR.
..RRRRR..
...RRR...
"""
NO_ENTRY_W = 9
NO_ENTRY_H = 9

# Starlark has no font-metrics call, so the lit-row count of every font this
# app draws with is carried here. Rows are bottom-aligned off these numbers,
# which is what keeps a laddered-down hero sitting on the same baseline.
FONT_INK = {
    "10x15_outline": 15,
    "10x15": 14,
    "8x12": 12,
    "6x8": 8,
    "5x7": 7,
    "4x5": 5,
    "picopixel": 5,
}

# ---------------------------------------------------------------------------
# Geometry. Every row is stacked off the row above it plus the lit height of
# the font that sits there, so there are no hand-picked y values and the
# clearances hold whatever is drawn.

PAD = 8                # scroll edge padding: content lives in x 8 .. w-9
GAP = 1                # the house minimum: one black row between any two things
LABEL_FONT = "4x5"
BAR_H = 2              # the availability bar: 2px of ink, 1px for an empty slot

# 192 (scroll). The panel is read edge to edge, so it is given a real margin --
# eight black columns each side -- and every horizontal thing on it, name,
# rule and bar alike, starts and stops on that window rather than on three
# different insets. Vertically the name takes the top row, a hairline rules
# off the header, and the 10x15_outline number sits in the block below it with
# the bar landing on the last two rows of the panel.
# Name ink 0..4, rule 6, labels 8..12, numbers 14..28, row 29 black, bar 30..31.
W_NAME_Y = 0
W_RULE_Y = W_NAME_Y + FONT_INK[LABEL_FONT] + GAP            # 6
W_LABEL_Y = W_RULE_Y + 1 + GAP                              # 8
W_NUM_Y = W_LABEL_Y + FONT_INK[LABEL_FONT] + GAP            # 14
W_NUM_FONT = "10x15_outline"
RULE = "#0C2233"       # the header rule: present, never competing with the data

# Column pitch. Round 1 spaced the three figures on band/3 = 51px centres and
# the owner asked for four pixels off each gap, so the pitch is fixed at 47 and
# the group is re-centred in the band instead of hanging off its left edge.
# Each label stays centred on its own column, so a figure keeps its word.
W_COL_PITCH = 47

# 64 (classic). Maximise the space: the name starts on row 0 and the bar sits
# on the last two rows, and everything between is stacked with the same one-row
# gap. Name ink 0..4, bike and hero ink 6..20, second row ink 22..28, bar
# 30..31 -- the bar's first row is 30 and the lowest lit text row is 28.
N_NAME_Y = 0
N_ART_Y = N_NAME_Y + FONT_INK[LABEL_FONT] + GAP             # 6, bike y 6..20
N_HERO_FONTS = ["10x15", "8x12", "6x8"]
# At full size the hero's top row is the bike's top row; a laddered-down hero
# keeps this baseline instead of floating up with its own box.
N_HERO_BOT = N_ART_Y + FONT_INK[N_HERO_FONTS[0]] - 1        # 19

STATIONS = {
    "1 AVE AT E 44 ST": "66dc2172-0aca-11e7-82f6-3863bb44ef7c",
    "1 AVE AT E 6 ST": "c37931bb-8571-4671-a9a8-f3cf23897680",
    "10 AVE AT W 14 ST": "116dbc02-a3c1-4b65-9f73-2a09a2aa1379",
    "2 AVE AT E 31 ST": "1893622839585237496",
    "3 ST AT 3 AVE": "66de25bd-0aca-11e7-82f6-3863bb44ef7c",
    "7 AVE AT CENTRAL PARK SOUTH": "b94cc90e-9ca2-4471-8371-23be051e0157",
    "7 AVE S AT BLEECKER ST": "c466f15e-715f-411e-904e-1a71fb574cdd",
    "8 AVE AT W 31 ST": "66ddbd20-0aca-11e7-82f6-3863bb44ef7c",
    "8 AVE AT W 33 ST": "66dc686c-0aca-11e7-82f6-3863bb44ef7c",
    "9 AVE AT W 18 ST": "66dc11a7-0aca-11e7-82f6-3863bb44ef7c",
    "9 AVE AT W 22 ST": "66dc7a7d-0aca-11e7-82f6-3863bb44ef7c",
    "9 AVE AT W 33 ST": "1869743938848725856",
    "ALLEN ST AT HESTER ST": "1960020817312746312",
    "BROADWAY AT E 14 ST": "66db6387-0aca-11e7-82f6-3863bb44ef7c",
    "BROADWAY AT E 19 ST": "1975518133370609774",
    "BROADWAY AT W 25 ST": "daefc84c-1b16-4220-8e1f-10ea4866fdc7",
    "BROADWAY AT W 29 ST": "66dc4bd9-0aca-11e7-82f6-3863bb44ef7c",
    "BROADWAY AT W 48 ST": "64f0f28c-bedc-42d5-b107-ecdd48fc30cd",
    "BROADWAY AT W 53 ST": "66dc2c78-0aca-11e7-82f6-3863bb44ef7c",
    "CENTRAL PARK S AT GRAND ARMY PLAZA": "1964061627836181486",
    "CENTRE ST AT WORTH ST": "66dbe848-0aca-11e7-82f6-3863bb44ef7c",
    "COOPER SQUARE AT ASTOR PL": "66ddd545-0aca-11e7-82f6-3863bb44ef7c",
    "E 10 ST AT AVE A": "66dc1beb-0aca-11e7-82f6-3863bb44ef7c",
    "E 11 ST AT 3 AVE": "a4368364-fa79-493c-8478-1d3471a6077f",
    "E 11 ST AT BROADWAY": "66dbc860-0aca-11e7-82f6-3863bb44ef7c",
    "E 13 ST AT AVE A": "d9160982-2d9b-4f08-9469-a559a7b62809",
    "E 2 ST AT AVE B": "66db6aae-0aca-11e7-82f6-3863bb44ef7c",
    "E 2 ST AT AVE C": "66db2f4c-0aca-11e7-82f6-3863bb44ef7c",
    "E 20 ST AT 2 AVE": "66dc259a-0aca-11e7-82f6-3863bb44ef7c",
    "E 24 ST AT PARK AVE S": "66dc6a86-0aca-11e7-82f6-3863bb44ef7c",
    "E 27 ST AT 1 AVE": "66dc9223-0aca-11e7-82f6-3863bb44ef7c",
    "E 33 ST AT 1 AVE": "61c82689-3f4c-495d-8f44-e71de8f04088",
    "E 40 ST AT 5 AVE": "66db30e0-0aca-11e7-82f6-3863bb44ef7c",
    "E 40 ST AT PARK AVE": "c638ec67-9ac0-416f-944f-619926144931",
    "E 47 ST AT 2 AVE": "66db32fb-0aca-11e7-82f6-3863bb44ef7c",
    "E 47 ST AT PARK AVE": "66dbc982-0aca-11e7-82f6-3863bb44ef7c",
    "E 6 ST AT AVE B": "66db76a1-0aca-11e7-82f6-3863bb44ef7c",
    "FDR DRIVE AT E 35 ST": "66dc7659-0aca-11e7-82f6-3863bb44ef7c",
    "GANSEVOORT ST AT HUDSON ST": "1827839088308194240",
    "GRAND ST AT SAMUEL DICKSTEIN PLAZA": "8cb0375d-bcb2-4c90-9773-41c3c8fdf8d8",
    "GREENWICH ST AT W HOUSTON ST": "66dbbeda-0aca-11e7-82f6-3863bb44ef7c",
    "LAFAYETTE ST AT ASTOR PL": "2245650716933709032",
    "LAIGHT ST AT HUDSON ST": "66db402c-0aca-11e7-82f6-3863bb44ef7c",
    "LEXINGTON AVE AT E 24 ST": "66dc8a3d-0aca-11e7-82f6-3863bb44ef7c",
    "LEXINGTON AVE AT E 26 ST": "454b4a83-d0b1-42a2-8163-261e2a9d6ab9",
    "OLD SLIP AT SOUTH ST": "ff2869f0-4381-4cf3-863e-a0d776ec53b4",
    "PARK AVE AT E 41 ST": "66dc7f02-0aca-11e7-82f6-3863bb44ef7c",
    "PARK AVE AT E 42 ST": "66dc8025-0aca-11e7-82f6-3863bb44ef7c",
    "RIVERSIDE BLVD AT W 67 ST": "66dd51e6-0aca-11e7-82f6-3863bb44ef7c",
    "RIVERSIDE DR AT W 78 ST": "66dd5407-0aca-11e7-82f6-3863bb44ef7c",
    "VESEY ST AT GREENWICH ST": "1989279523593928720",
    "W 20 ST AT 8 AVE": "66dc36c3-0aca-11e7-82f6-3863bb44ef7c",
    "W 31 ST AT 7 AVE": "66dbe4db-0aca-11e7-82f6-3863bb44ef7c",
    "W 34 ST AT 11 AVE": "66dc8382-0aca-11e7-82f6-3863bb44ef7c",
    "W 37 ST AT BROADWAY": "341730d7-a61d-499d-8c07-fa015f644e54",
    "W 41 ST AT 8 AVE": "66dc3f08-0aca-11e7-82f6-3863bb44ef7c",
    "W 43 ST AT 10 AVE": "66dc7de9-0aca-11e7-82f6-3863bb44ef7c",
    "W 51 ST AT 6 AVE": "66dc7b10-0aca-11e7-82f6-3863bb44ef7c",
    "W 59 ST AT 10 AVE": "66dc0dab-0aca-11e7-82f6-3863bb44ef7c",
    "W BROADWAY AT SPRING ST": "bde94a25-6089-4490-af3a-8cc5702230b8",
}


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


def fitwords(c, text, font, maxw):
    """The longest run of whole words that fits. A station name cut mid-word
    ("BROADWAY AT E 1") reads worse than a shorter complete one, so the cut
    lands on a space when there is one to land on."""
    if c.text_width(text, font) <= maxw:
        return text
    out = ""
    for w in text.split(" "):
        cand = w if out == "" else out + " " + w
        if c.text_width(cand, font) > maxw:
            break
        out = cand
    if out == "":
        return _fit_clip(c, text, [font], maxw)[1]
    return out


def fitnum(c, s, fonts, maxw):
    """Largest font in the ladder that renders s inside maxw. Counts are 1-3
    characters and the last rung always fits, so nothing is ever clipped --
    a three-digit dock count drops a size instead of losing a digit."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(s, f) <= maxw:
            pick = f
            break
    return pick


def nodata(c, title, sub):
    """Shown whenever the feed is unreachable. The publish-time validator
    renders every page with the network disabled, so this has to say
    something sensible rather than going blank."""
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


def resolve_station(ctx):
    """Station id for the picked stop, or "" when it is not one of ours."""
    v = ctx.inputs.get("station", "")
    if v == None:
        v = ""
    v = str(v).strip().upper()
    if v in STATIONS:
        return STATIONS[v]
    return ""


def count_color(n):
    """White while there is nothing to worry about, so amber and red keep their
    meaning. Colouring every state leaves no colour to raise an alarm with."""
    if n <= 0:
        return "#FF2D2D"
    if n <= 3:
        return "#FFB000"
    return WHITE


def location(c, name, x, y, maxw):
    """The station name -- a location app always shows its location. picopixel
    is only worth reaching for when it rescues the whole name: "BROADWAY AT E
    14 ST" is 86px at 4x5 and 77px at picopixel, so on 64 neither fits and the
    smaller font would buy no extra word, only a harder read. Both fonts are
    five lit rows tall, so y is safe either way."""
    if c.text_width(name, "4x5") <= maxw:
        c.text(name, x, y, font = "4x5", color = CHROME)
    elif c.text_width(name, "picopixel") <= maxw:
        c.text(name, x, y, font = "picopixel", color = CHROME)
    else:
        c.text(fitwords(c, name, "4x5", maxw), x, y, font = "4x5",
               color = CHROME)


def bar(c, x0, x1, y0, h, total, ebikes, docks):
    """The whole station drawn as one rule along the bottom: one segment per
    physical dock, a bike full height, an empty slot a single ghost line on
    the last row.

    A bare count cannot say whether five bikes is comfortable or nearly the
    last one -- five at a 15-dock station and five at a 55-dock station read
    identically. This shows the ratio, the e-bike share and the size of the
    station at a glance, before a digit is read.

    y0 is handed in by the caller rather than hard-coded, because the two
    widths stop their text on different rows and the bar has to stay exactly
    one black row below whichever it is.
    """
    slots_total = total + docks
    if slots_total <= 0:
        return
    y1 = y0 + h - 1
    avail = x1 - x0 + 1
    # The pitch stretches to spend the whole width rather than sitting at a
    # fixed 4px: a 12-dock station on 192 used to draw a 47px stub of dashes
    # under the middle column and leave two thirds of the rule black, which
    # read as a broken bar rather than a small station.
    pitch = avail // slots_total
    if pitch >= 4:
        seg = pitch - 1
        x = x0 + (avail - (slots_total * pitch - 1)) // 2
        for i in range(slots_total):
            if i < ebikes:
                c.rect(x, y0, x + seg - 1, y1, fill = YELLOW)
            elif i < total:
                c.rect(x, y0, x + seg - 1, y1, fill = BLUE)
            else:
                c.rect(x, y1, x + seg - 1, y1, fill = GHOST)
            x = x + pitch
    else:
        # Too many docks for a legible segment: one proportional bar instead,
        # so a very large station still shows its fill ratio rather than being
        # cut off.
        w = x1 - x0
        c.rect(x0, y1, x1, y1, fill = GHOST)
        fill = (w * total) // slots_total
        if fill > 0:
            c.rect(x0, y0, x0 + fill, y1, fill = BLUE)
            e = (w * ebikes) // slots_total
            if e > 0:
                c.rect(x0 + fill - e, y0, x0 + fill, y1, fill = YELLOW)


def wide(c, name, total, ebikes, docks, renting, returning):
    """192: name across the top, the bike on the left, three labelled figures
    ranked by size of number, the bar underneath."""
    left = PAD
    right = c.width - 1 - PAD
    bar_y = c.height - BAR_H

    location(c, name, left, W_NAME_Y, right - left + 1)

    # One hairline is the whole grid: it separates header from data for the
    # cost of a single row, and it runs the content window rather than the
    # full width so the margin reads as deliberate on all three rows.
    c.hline(left, W_RULE_Y, right - left + 1, RULE)

    bike_legend = {"B": RED if not renting else BLUE, "W": WHITE, "T": SLATE}
    c.sprite(BIKE, left, W_NUM_Y, legend = bike_legend)

    # Three columns filling everything to the right of the bike. Centring the
    # content of each column on its own centre line is what pulled the figures
    # closer together: the old layout hung them off fixed left edges 56 px
    # apart and the group drifted right as the counts got shorter. The pitch
    # falls back to an even third of the band on any width too narrow to seat
    # three columns at W_COL_PITCH.
    band0 = left + BIKE_W + 2
    band = right - band0 + 1
    cw = W_COL_PITCH
    if cw * 3 > band:
        cw = band // 3
    cx0 = band0 + (band - cw * 3) // 2 + cw // 2

    num_mid = W_NUM_Y + FONT_INK[W_NUM_FONT] // 2

    tstr = str(total)
    estr = str(ebikes)
    dstr = str(docks)

    cols = [
        [cx0, "BIKES", tstr, SLATE if not renting else count_color(total)],
        [cx0 + cw, "E-BIKES", estr, WHITE if ebikes > 0 else DIM],
        [cx0 + 2 * cw, "DOCKS", dstr,
         SLATE if not returning else count_color(docks)],
    ]
    for col in cols:
        c.text(col[1], col[0], W_LABEL_Y, font = "4x5", color = "#5A6C7A",
               align = "center")

    c.text(tstr, cols[0][0], W_NUM_Y, font = W_NUM_FONT, color = cols[0][3],
           align = "center")
    c.text(dstr, cols[2][0], W_NUM_Y, font = W_NUM_FONT, color = cols[2][3],
           align = "center")

    # The bolt travels with the e-bike count instead of sitting at a fixed x:
    # number and bolt are centred on the column as one block, so the pair stays
    # put at 1, 2 or 3 digits instead of the bolt walking off to the right.
    ew = c.text_width(estr, W_NUM_FONT)
    ex = cols[1][0] - (ew + 2 + BOLT_W) // 2
    c.text(estr, ex, W_NUM_Y, font = W_NUM_FONT, color = cols[1][3])
    c.sprite(BOLT, ex + ew + 2, num_mid - BOLT_H // 2,
             legend = {"Y": YELLOW if ebikes > 0 else DIMYELLOW})

    # A station can report ordinary counts and still refuse the trip, so the
    # badge carries the alarm and the dimmed number says it is moot. Clamped to
    # the right margin: at three digits the docks column would otherwise push
    # the badge past x=185 and lose columns off the canvas.
    ny = num_mid - NO_ENTRY_H // 2
    legend = {"R": RED, "W": WHITE}
    if not renting:
        bx = cols[0][0] + c.text_width(tstr, W_NUM_FONT) // 2 + 2
        c.sprite(NO_ENTRY, bx, ny, legend = legend)
    if not returning:
        bx = cols[2][0] + c.text_width(dstr, W_NUM_FONT) // 2 + 2
        if bx + NO_ENTRY_W - 1 > right:
            bx = right - NO_ENTRY_W + 1
        c.sprite(NO_ENTRY, bx, ny, legend = legend)

    bar(c, left, right, bar_y, BAR_H, total, ebikes, docks)


def narrow(c, name, total, ebikes, docks, renting, returning):
    """64: no room for three columns and no room for words, so the pictures do
    the labelling -- bike, bolt, dock rack -- and the three counts are ranked
    by font size instead of by position."""
    # 64 maximises the space, so the bar takes the last rows of the panel and
    # the second row of text is hung one clear pixel above it rather than the
    # other way round.
    bar_y = c.height - BAR_H
    row2_bot = bar_y - GAP - 1

    location(c, name, 1, N_NAME_Y, c.width - 2)

    bike_legend = {"B": RED if not renting else BLUE, "W": WHITE, "T": SLATE}
    c.sprite(BIKE, 0, N_ART_Y, legend = bike_legend)

    tstr = str(total)
    estr = str(ebikes)
    dstr = str(docks)

    # Hero: bikes, centred in whatever is left of the strip once the bike has
    # taken the left. Centred rather than hung off the bike, because a two-digit
    # count left-aligned at x=28 left a 15px hole in the top-right corner and
    # the panel looked cut off. The width is measured against the closed-station
    # badge when there is one, so "103" drops to 8x12 rather than running under
    # the badge or off the right edge.
    hx = BIKE_W + 3
    hrt = c.width - 1
    if not renting:
        hrt = hrt - NO_ENTRY_W - 2
    hf = fitnum(c, tstr, N_HERO_FONTS, hrt - hx + 1)
    c.text(tstr, (hx + hrt) // 2, N_HERO_BOT - FONT_INK[hf] + 1, font = hf,
           color = SLATE if not renting else count_color(total),
           align = "center")
    if not renting:
        c.sprite(NO_ENTRY, c.width - NO_ENTRY_W,
                 N_HERO_BOT - BIKE_H // 2 - NO_ENTRY_H // 2 + 1,
                 legend = {"R": RED, "W": WHITE})

    # Second row, both clusters sitting on one baseline. E-bikes to the
    # left under the bike, slots hard right so a three-digit count grows
    # leftward into empty black instead of off the edge.
    ef = "5x7"
    c.sprite(BOLT, 1, row2_bot - BOLT_H + 1,
             legend = {"Y": YELLOW if ebikes > 0 else DIMYELLOW})
    c.text(estr, 1 + BOLT_W + 2, row2_bot - FONT_INK[ef] + 1, font = ef,
           color = WHITE if ebikes > 0 else DIM)

    sf = "4x5"
    sw = c.text_width(dstr, sf)
    c.text(dstr, c.width - 1, row2_bot - FONT_INK[sf] + 1, font = sf,
           color = SLATE if not returning else count_color(docks),
           align = "right")
    c.sprite(RACK, c.width - sw - 2 - RACK_W, row2_bot - RACK_H + 1,
             legend = {"D": RED if not returning else RACKCOL})

    bar(c, 0, c.width - 1, bar_y, BAR_H, total, ebikes, docks)


def bikes(c, ctx):
    sid = resolve_station(ctx)
    if sid == "":
        nodata(c, "NO STATION", "IN SETTINGS")
        return

    r = http.get(STATUS_URL, ttl_seconds = 120)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO BIKE DATA", "FEED UNREACHABLE")
        return

    found = None
    for s in r["json"].get("data", {}).get("stations", []):
        if str(s.get("station_id", "")) == sid:
            found = s
            break
    if found == None:
        nodata(c, "STATION GONE", "PICK ANOTHER")
        return

    total = int(found.get("num_bikes_available", 0) or 0)
    docks = int(found.get("num_docks_available", 0) or 0)
    ebikes = int(found.get("num_ebikes_available", 0) or 0)
    # Citi Bike reports e-bikes in their own field; Indego and several other
    # GBFS systems report a breakdown by type instead.
    types = found.get("num_bikes_available_types", None)
    if ebikes == 0 and types != None:
        ebikes = int(types.get("electric", 0) or 0)
    if ebikes > total:
        ebikes = total

    renting = found.get("is_renting", True)
    returning = found.get("is_returning", True)

    name = str(ctx.inputs.get("station", "")).strip().upper()

    c.fill("black")
    if c.width >= 128:
        wide(c, name, total, ebikes, docks, renting, returning)
    else:
        narrow(c, name, total, ebikes, docks, renting, returning)
