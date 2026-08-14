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
# DESIGN. The panel is black and every label is a picture. A bike silhouette is
# recognised before any word is read, so the word "BIKES" is not on the panel --
# the bike is. Same for the bolt (e-bikes) and the slot glyph (docks). White is
# the resting colour for a live number, which leaves amber and red free to mean
# something the moment they appear.

STATUS_URL = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json"

# Citi blue, lifted from the brand's #0068A5: at LED gamma the darker blue
# muddies against black and the frame stops reading as a frame.
BLUE = "#0E86D6"
YELLOW = "#FFD500"
SLATE = "#55606C"      # tyres and rack -- a dark object, not a hole
CHROME = "#7A8894"     # station name and other inert chrome
GHOST = "#2A343E"      # an empty dock on the meter
WHITE = "#FFFFFF"

# Side-on Citi Bike. The thick swoop from the head tube down to the bottom
# bracket is the step-through frame, which is what makes this read as a Citi
# Bike rather than a generic bicycle. The white arcs are fenders and the white
# pixel on the front plate is the rack logo.
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

BIKE_SMALL = """
....WW.....W.....
.....B......B...B
.....B......B.TTB
.....BB....B.B...
..WWWBB...B.WWW..
.T..BT.B.B.T...T.
T...B.TB.BT.....T
T...BBBBB.T.....T
T.....T.T.T.....T
.T...T.....T...T.
..TTT.......TTT..
"""

BIKE_LEGEND = {"B": BLUE, "W": WHITE, "T": SLATE}

BOLT = """
..YY
.YY.
YYYY
..YY
.YY.
YY..
"""

# An open dock: two posts and a floor.
DOCK = """
SS...SS
SS...SS
SS...SS
SS...SS
SSSSSSS
"""

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


def meter(c, x0, x1, total, ebikes, docks):
    """The dock row: one segment per physical dock, filled ones full height and
    empty ones a single ghost line.

    A bare count cannot say whether five bikes is comfortable or nearly the
    last one -- five at a 15-dock station and five at a 55-dock station read
    identically. This shows the ratio, the e-bike share and the size of the
    station at a glance, before a digit is read.
    """
    slots_total = total + docks
    if slots_total <= 0:
        return
    pitch = 4
    room = (x1 - x0 + 1) // pitch
    if slots_total <= room:
        x = x0
        for i in range(slots_total):
            if i < ebikes:
                c.rect(x, 29, x + 2, 31, fill = YELLOW)
            elif i < total:
                c.rect(x, 29, x + 2, 31, fill = BLUE)
            else:
                c.rect(x, 31, x + 2, 31, fill = GHOST)
            x = x + pitch
    else:
        # More docks than segments fit: one proportional bar instead, so a very
        # large station still shows its fill ratio rather than being cut off.
        w = x1 - x0
        c.rect(x0, 31, x1, 31, fill = GHOST)
        fill = (w * total) // slots_total
        if fill > 0:
            c.rect(x0, 29, x0 + fill, 31, fill = BLUE)
            e = (w * ebikes) // slots_total
            if e > 0:
                c.rect(x0 + fill - e, 29, x0 + fill, 31, fill = YELLOW)


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
    tstr = str(total)
    dstr = str(docks)

    c.fill("black")

    if c.width >= 128:
        nf = _fit_clip(c, name, ["4x5"], c.width - 4)
        c.text(nf[1], 2, 0, font = nf[0], color = CHROME)
        # One hairline is the whole grid: it separates header from data for the
        # cost of a single row.
        c.hline(0, 7, c.width, "#0C2233")

        # The right cluster is measured first so the left one can be given what
        # is actually left. Every position below is derived, not guessed: a
        # three-digit count is 51px at 16x20 and a fixed bolt position sat
        # underneath it.
        dock_w = c.text_width(dstr, "10x16")
        dock_x = c.width - 4 - dock_w
        ghost_x = dock_x - 4 - 17

        # A dim bike is an empty space. Reusing the hero silhouette for the
        # docks means one visual idea does both jobs, and neither number needs
        # a word next to it.
        c.sprite(BIKE_SMALL, ghost_x, 13,
                 legend = {"B": "#33404A", "W": "#4A5A66", "T": GHOST})
        c.text(dstr, dock_x, 12, font = "10x16",
               color = SLATE if not returning else count_color(docks))

        c.sprite(BIKE, 3, 10, legend = BIKE_LEGEND)

        hero = "16x20"
        # 6px for the bolt and its gap, plus room for the e-bike count.
        if 34 + c.text_width(tstr, hero) + 12 + c.text_width(str(ebikes), "8x12") > ghost_x - 6:
            hero = "10x16"
        c.text(tstr, 34, 8 if hero == "16x20" else 10, font = hero,
               color = SLATE if not renting else count_color(total))

        bx = 34 + c.text_width(tstr, hero) + 7
        if ebikes > 0:
            c.sprite(BOLT, bx, 16, legend = {"Y": YELLOW})
            c.text(str(ebikes), bx + 6, 14, font = "8x12", color = WHITE)
        else:
            # A dim bolt says "no e-bikes here" faster than the digit 0 does.
            c.sprite(BOLT, bx, 16, legend = {"Y": "#33404A"})

        meter(c, 2, c.width - 3, total, ebikes, docks)

        # A station can report ordinary counts and still refuse the trip, so
        # the badge carries the alarm and the dimmed number says it is moot.
        if not renting:
            c.sprite(NO_ENTRY, 20, 13, legend = {"R": "#E01A1A", "W": WHITE})
        if not returning:
            c.sprite(NO_ENTRY, ghost_x + 4, 15,
                     legend = {"R": "#E01A1A", "W": WHITE})
    else:
        # 64px has room for one bike, so the blue one goes to the bikes count
        # and the docks are carried by the meter plus a small number. The
        # ghost bike needs 17 columns it cannot have here.
        nf = _fit_clip(c, name, ["4x5"], c.width - 2)
        c.text(nf[1], 1, 0, font = nf[0], color = CHROME)
        c.sprite(BIKE_SMALL, 1, 8, legend = BIKE_LEGEND)
        c.text(tstr, 21, 7, font = "10x16",
               color = SLATE if not renting else count_color(total))
        bx = 21 + c.text_width(tstr, "10x16") + 4
        if ebikes > 0 and bx + 4 + c.text_width(str(ebikes), "5x7") <= c.width - 2:
            c.sprite(BOLT, bx, 8, legend = {"Y": YELLOW})
            c.text(str(ebikes), bx + 6, 9, font = "5x7", color = WHITE)
        c.text(dstr + " FREE", c.width - 2, 23, font = "4x5",
               color = SLATE if not returning else count_color(docks),
               align = "right")
        meter(c, 1, c.width - 2, total, ebikes, docks)
        if not renting:
            c.sprite(NO_ENTRY, 12, 11, legend = {"R": "#E01A1A", "W": WHITE})
