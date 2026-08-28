# Indego
#
# Bikes and docks at one Philadelphia Indego station, from the public GBFS
# feed. No key.
#
# Same drawing code as apps/citi-bike -- GBFS is a standard, so the only real
# differences are the feed URL and the station table. Indego reports its
# e-bike count under num_bikes_available_types.electric where Citi Bike uses
# num_ebikes_available; the reader below handles both.
#
# The station list is baked in rather than fetched, so only the status feed
# (71 KB) is pulled rather than that plus station_information (126 KB) to turn
# an id into a label that never changes.
#
# DESIGN. The panel is black and every label is a picture. A bike silhouette is
# recognised before any word is read, so the word "BIKES" is not on the panel --
# the bike is. Same for the bolt (e-bikes) and the slot glyph (docks). White is
# the resting colour for a live number, which leaves amber and red free to mean
# something the moment they appear.

STATUS_URL = "https://gbfs.bcycle.com/bcycle_indego/station_status.json"

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
    "10TH AT OXFORD": "bcycle_indego_3268",
    "10TH AT PACKER": "bcycle_indego_3357",
    "10TH AT PHILLIES": "bcycle_indego_3469",
    "17TH AT GREEN": "bcycle_indego_3204",
    "17TH AT JFK": "bcycle_indego_3205",
    "17TH AT LOCUST": "bcycle_indego_3359",
    "17TH AT PINE": "bcycle_indego_3063",
    "17TH AT SPRING GARDEN": "bcycle_indego_3040",
    "18TH AT JFK": "bcycle_indego_3021",
    "18TH AT JFK CURBSIDE": "bcycle_indego_3333",
    "18TH AT WASHINGTON CHEW PLAYGROUND": "bcycle_indego_3064",
    "19TH AT LOMBARD": "bcycle_indego_3066",
    "20TH AT MARKET": "bcycle_indego_3156",
    "20TH AT SANSOM": "bcycle_indego_3462",
    "21ST AT CATHARINE": "bcycle_indego_3012",
    "21ST AT WINTER FRANKLIN INSTITUTE": "bcycle_indego_3014",
    "23RD AT CHESTNUT": "bcycle_indego_3256",
    "23RD AT FAIRMOUNT": "bcycle_indego_3051",
    "23RD AT MARKET": "bcycle_indego_3473",
    "23RD AT SOUTH": "bcycle_indego_3032",
    "24TH AT CHRISTIAN": "bcycle_indego_3248",
    "24TH AT RACE SRT": "bcycle_indego_3165",
    "25TH AT LOCUST": "bcycle_indego_3163",
    "27TH AT SOUTH": "bcycle_indego_3162",
    "2ND AT MARKET": "bcycle_indego_3447",
    "30TH STREET STATION EAST": "bcycle_indego_3161",
    "34TH AT ARCH": "bcycle_indego_3249",
    "34TH AT SPRUCE": "bcycle_indego_3208",
    "38TH AT MARKET": "bcycle_indego_3160",
    "38TH AT SPRUCE": "bcycle_indego_3159",
    "3RD AT GIRARD": "bcycle_indego_3088",
    "4TH AT CHRISTIAN": "bcycle_indego_3069",
    "54TH AT CEDAR": "bcycle_indego_3338",
    "56TH AT CHESTNUT": "bcycle_indego_3344",
    "6TH AT BROWN": "bcycle_indego_3286",
    "8TH AT SPRUCE": "bcycle_indego_3264",
    "9TH AT LOCUST": "bcycle_indego_3052",
    "BARNES FOUNDATION": "bcycle_indego_3116",
    "BROAD AT CARPENTER": "bcycle_indego_3213",
    "BROAD AT CHRISTIAN": "bcycle_indego_3086",
    "BROAD AT ONTARIO TEMPLE HOSPITAL": "bcycle_indego_3353",
    "BROAD AT OREGON": "bcycle_indego_3237",
    "BROAD AT PATTISON BSL": "bcycle_indego_3188",
    "BROAD AT REED": "bcycle_indego_3360",
    "BROAD AT RITNER": "bcycle_indego_3197",
    "CORINTHIAN AT POPLAR": "bcycle_indego_3211",
    "CRESCENT PARK": "bcycle_indego_3181",
    "FOGLIETTA PLAZA": "bcycle_indego_3049",
    "FRONT AT CARPENTER": "bcycle_indego_3072",
    "GIRARD STATION MFL": "bcycle_indego_3041",
    "KELLY DRIVE GRANDSTAND": "bcycle_indego_3328",
    "MOYAMENSING AT TASKER": "bcycle_indego_3100",
    "MUNICIPAL SERVICES BUILDING PLAZA": "bcycle_indego_3004",
    "PHILADELPHIA MUSEUM OF ART": "bcycle_indego_3057",
    "RODIN MUSEUM": "bcycle_indego_3054",
    "SCHUYLKILL BANKS PERGOLA": "bcycle_indego_3212",
    "SPRING GARDEN STATION BSL": "bcycle_indego_3059",
    "UNIVERSITY CITY STATION": "bcycle_indego_3020",
    "WATER AT MIFFLIN": "bcycle_indego_3266",
    "YORK AT ARAMINGO": "bcycle_indego_3275",
}


NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]

# The count face on the 192px layout, biggest first. 10x16 is the face the
# counts are meant to wear; the smaller rungs only come out if a freak count
# (four digits, say) would otherwise push a badge past the safe zone.
NUM_FONTS = ["10x16", "7x14", "5x7"]
LABELF = "4x5"

# Layout of the three labelled figures. Each group is a label with its number
# centred underneath; where one group ends the next one starts GAP later.
GAP = 25
FIRST_X = 38
NUM_Y = 14
SAFE_R = 182


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


def cols_layout(c, labels, nums, numf):
    """[label_x, num_x, right] per group, with a constant gap between groups.

    The number is centred on its label. When a number is wider than its label
    the number sets the group's left edge and the label rides along, so the
    constant gap is measured between the outer edges of whole groups rather
    than between labels.
    """
    out = []
    x = FIRST_X
    for i in range(len(labels)):
        lw = c.text_width(labels[i], LABELF)
        nw = c.text_width(nums[i], numf)
        lx = x
        nx = x + (lw - nw) // 2
        if nx < lx:
            lx = lx + (lx - nx)
            nx = x
        r = lx + lw - 1
        if nx + nw - 1 > r:
            r = nx + nw - 1
        out.append([lx, nx, r])
        x = r + GAP
    return out


def cols_extent(c, cols, nums, numf, ebikes, renting, returning):
    """Rightmost pixel the row would touch, badges and bolt included."""
    r = cols[2][2]
    if ebikes > 0:
        b = cols[1][1] + c.text_width(nums[1], numf) + 3 + 3
        if b > r:
            r = b
    if not renting:
        b = cols[0][1] + c.text_width(nums[0], numf) + 3 + 8
        if b > r:
            r = b
    if not returning:
        b = cols[2][1] + c.text_width(nums[2], numf) + 3 + 8
        if b > r:
            r = b
    return r


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
                c.rect(x, 30, x + 2, 31, fill = YELLOW)
            elif i < total:
                c.rect(x, 30, x + 2, 31, fill = BLUE)
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
            c.rect(x0, 30, x0 + fill, 31, fill = BLUE)
            e = (w * ebikes) // slots_total
            if e > 0:
                c.rect(x0 + fill - e, 30, x0 + fill, 31, fill = YELLOW)


def bikes(c, ctx):
    sid = resolve_station(ctx)
    if sid == "":
        nodata(c, "NO STATION", "IN SETTINGS")
        return

    r = http.get(STATUS_URL, ttl_seconds = 120)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO INDEGO DATA", "FEED UNREACHABLE")
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
        c.hline(0, 6, c.width, "#0C2233")

        # Three labelled figures. The original layout leaned on the glyphs
        # alone -- a bike, a bolt, a dim bike -- on the theory that neither
        # number needed a word next to it. In front of somebody who has not
        # seen the app before, "4  2  103" is a puzzle, so each figure now says
        # what it is. The bike keeps its place on the left as the app's mark.
        c.sprite(BIKE, 5, 11, legend = BIKE_LEGEND)

        labels = ["BIKES", "E-BIKES", "DOCKS"]
        nums = [tstr, str(ebikes), dstr]
        colors = [
            SLATE if not renting else count_color(total),
            WHITE if ebikes > 0 else "#33404A",
            SLATE if not returning else count_color(docks),
        ]

        numf = NUM_FONTS[len(NUM_FONTS) - 1]
        cols = cols_layout(c, labels, nums, numf)
        for f in NUM_FONTS:
            cc = cols_layout(c, labels, nums, f)
            if cols_extent(c, cc, nums, f, ebikes, renting,
                           returning) <= SAFE_R:
                numf = f
                cols = cc
                break

        for i in range(3):
            c.text(labels[i], cols[i][0], 8, font = LABELF, color = "#5A6C7A")
            c.text(nums[i], cols[i][1], NUM_Y, font = numf, color = colors[i])
        if ebikes > 0:
            c.sprite(BOLT,
                     cols[1][1] + c.text_width(nums[1], numf) + 3, 18,
                     legend = {"Y": YELLOW})

        meter(c, 2, c.width - 9, total, ebikes, docks)

        # A station can report ordinary counts and still refuse the trip, so
        # the badge carries the alarm and the dimmed number says it is moot.
        if not renting:
            c.sprite(NO_ENTRY,
                     cols[0][1] + c.text_width(tstr, numf) + 3, 16,
                     legend = {"R": "#E01A1A", "W": WHITE})
        if not returning:
            # Sits over the DOCKS column, which is where the refusal applies.
            c.sprite(NO_ENTRY,
                     cols[2][1] + c.text_width(dstr, numf) + 3, 16,
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
