# BART Departures
#
# DESIGN. Black ground, no wash: a left identity block — the word BART in
# 4x5 sitting one pixel above the train, the pair centred as one unit — and
# a three-row departure board to its right, destination left, minutes
# right-aligned against the safe edge. The identity block is the only thing
# that is always on the panel, so it anchors the app in the rotation; the
# board is the data. Nothing touches the outer ten columns on either side,
# because on a 384 or 640 strip a neighbour app is on the glass at the same
# time and content at pixel 0 merges into it.
#
# BART's ETD API, which is open and needs only the public demo key
# they publish in their own documentation.
#
# BART rather than a generic transit app because most US agencies
# expose GTFS-Realtime as protobuf, which cannot be decoded here,
# and because this repo already ships two MBTA trackers. BART is
# the gap with a clean JSON feed.
#
# Line colour comes straight off the feed, so the panel matches the
# map on the station wall.


# Starlark has no font metrics call, so heights are carried by hand.
FONTH = {"6x8": 8, "5x7": 7, "4x7": 8, "4x5": 5, "3x4": 4}

# Per-app edge buffer. The scroll display is a stream: an unknown app plays
# before this one and another after it, so ten empty columns on each side
# keep the panel reading as its own unit instead of merging at the seam.
# On 64 there is no neighbour problem and every pixel has to earn its place,
# so the buffer drops to 1.
EDGE_WIDE = 10
EDGE_NARROW = 1

# TRAIN.png is authored 24x18 with a one-pixel transparent margin on the top
# and bottom and three transparent columns on each side, so the drawn ink is
# 18x16 inside the 24x18 box. Every placement below is measured against the
# INK, not the box — a ten pixel buffer that is really seven because three
# columns of the PNG are empty is not a ten pixel buffer. The wide panel
# draws the file at its authored size (no resampling at all); the narrow one
# steps it down on its own aspect rather than squashing 18 rows into 16.
ART = {
    "wide": {"w": 24, "h": 18, "dx": 3, "dy": 1, "iw": 18, "ih": 16},
    "narrow": {"w": 16, "h": 12, "dx": 2, "dy": 1, "iw": 12, "ih": 10},
}

TITLE = "BART"
TITLE_FONT = "4x5"
TITLE_COLOR = "#56A8F6"   # the train's own body blue, so the pair reads as one mark
DEST_COLOR = "#C8D4EC"
GROUND = "#000000"        # flat black: cheapest high contrast there is

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
    maxw = c.width - 2 * edge(c) - 2
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


def edge(c):
    """Columns kept empty at both ends of the panel."""
    return EDGE_WIDE if c.width >= 128 else EDGE_NARROW


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


def pick_font(c, texts, fonts, maxw):
    """Largest font in which EVERY string fits maxw.

    One font for the whole board rather than per row: three destinations set
    in three different sizes reads as a fault, and the column has to be sized
    for the worst string on the panel anyway."""
    last = fonts[0]
    for f in fonts:
        allowed = True
        fits = True
        for t in texts:
            # 3x4 has no space glyph: "DALY CITY" would draw as DALYCITY,
            # so it is only on the ladder when every name is one word.
            if f == "3x4" and t.find(" ") >= 0:
                allowed = False
                break
            if c.text_width(t, f) > maxw:
                fits = False
        if not allowed:
            continue
        last = f
        if fits:
            return f
    return last


def mins_reserve(c, font):
    """Width the minutes column is allowed to occupy — the WORST case, not
    whatever happens to be on the feed right now.

    Sizing this per row from the live string is the bug it replaces: at
    Embarcadero the board is one-digit at 07:40 and two-digit at 07:41, and
    the destination column silently changed width with it. The reserve is
    the wider of "LEAVING" (41px at 5x7) and a two-digit readout with its
    unit ("88 MIN", 35px at 5x7), so a train 59 minutes out cannot push into
    the name beside it."""
    w = c.text_width("LEAVING", font)
    for d in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
        t = c.text_width(d + d + " MIN", font)
        if t > w:
            w = t
    return w


def mins_reserve_narrow(c, font):
    """Same idea on 64, where the copy is "NOW" / "88M" rather than words."""
    w = c.text_width("NOW", font)
    for d in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
        t = c.text_width(d + d + "M", font)
        if t > w:
            w = t
    return w


HEX = {"RED": "#FF4B4B", "ORANGE": "#FF9A3A", "YELLOW": "#F5D64E",
       "GREEN": "#4EE38A", "BLUE": "#4EA8FF", "WHITE": "#DCE4F4",
       "PURPLE": "#B46BE8", "BEIGE": "#D8C8A0"}


STATIONS = {
    "12TH ST OAKLAND CITY CENTER": "12TH",
    "16TH ST MISSION": "16TH",
    "19TH ST OAKLAND": "19TH",
    "24TH ST MISSION": "24TH",
    "ANTIOCH": "ANTC",
    "ASHBY": "ASHB",
    "BALBOA PARK": "BALB",
    "BAY FAIR": "BAYF",
    "BERRYESSA NORTH SAN JOSE": "BERY",
    "CASTRO VALLEY": "CAST",
    "CIVIC CENTER UN PLAZA": "CIVC",
    "COLISEUM": "COLS",
    "COLMA": "COLM",
    "CONCORD": "CONC",
    "DALY CITY": "DALY",
    "DOWNTOWN BERKELEY": "DBRK",
    "DUBLIN PLEASANTON": "DUBL",
    "EL CERRITO DEL NORTE": "DELN",
    "EL CERRITO PLAZA": "PLZA",
    "EMBARCADERO": "EMBR",
    "FREMONT": "FRMT",
    "FRUITVALE": "FTVL",
    "GLEN PARK": "GLEN",
    "HAYWARD": "HAYW",
    "LAFAYETTE": "LAFY",
    "LAKE MERRITT": "LAKE",
    "MACARTHUR": "MCAR",
    "MILLBRAE": "MLBR",
    "MILPITAS": "MLPT",
    "MONTGOMERY ST": "MONT",
    "NORTH BERKELEY": "NBRK",
    "NORTH CONCORD MARTINEZ": "NCON",
    "OAKLAND AIRPORT": "OAKL",
    "ORINDA": "ORIN",
    "PITTSBURG BAY POINT": "PITT",
    "PITTSBURG CENTER": "PCTR",
    "PLEASANT HILL": "PHIL",
    "POWELL ST": "POWL",
    "RICHMOND": "RICH",
    "ROCKRIDGE": "ROCK",
    "SAN BRUNO": "SBRN",
    "SAN LEANDRO": "SANL",
    "SFO AIRPORT": "SFIA",
    "SOUTH HAYWARD": "SHAY",
    "SOUTH SAN FRANCISCO": "SSAN",
    "UNION CITY": "UCTY",
    "WALNUT CREEK": "WCRK",
    "WARM SPRINGS SOUTH FREMONT": "WARM",
    "WEST DUBLIN PLEASANTON": "WDUB",
    "WEST OAKLAND": "WOAK",
}


def resolve_station(ctx):
    """BART station code for the picked stop.

    The setting used to be the four-letter code itself, typed from memory or
    looked up on bart.gov. The dropdown carries station names and this maps
    them to codes; the names and codes both come from BART's own stn.aspx
    station list.

    Anything that is not a known name falls through unchanged, so a code saved
    under the old free-text field still works.
    """
    v = str(ctx.inputs.get("station", "")).strip().upper()
    if v in STATIONS:
        return STATIONS[v]
    return v


def identity(c):
    """The BART wordmark stacked on the train, centred vertically as one unit.

    Returns the x of the first column to the RIGHT of the art's ink, so the
    board can be placed off a measured edge instead of a hand-picked one.

    Wide arithmetic: ink is 18x16, title is 5 rows in 4x5, one blank row
    between them, so the unit is 22 rows on a 32 row panel — rows 5..26, with
    a five row margin above and below. Horizontally the ink starts at the
    edge buffer (x=10) and the PNG box therefore starts at x=7, because the
    file carries three empty columns."""
    a = ART["wide"] if c.width >= 128 else ART["narrow"]
    th = FONTH[TITLE_FONT]
    grp = th + 1 + a["ih"]
    top = (c.height - grp) // 2

    ink_x = edge(c)
    ink_y = top + th + 1
    c.image("TRAIN.png", ink_x - a["dx"], ink_y - a["dy"], w = a["w"],
            h = a["h"])

    # BART is 19px in 4x5 and the ink is 18px, so centring the label on the
    # art would put it one column outside the buffer; it is clamped instead.
    tw = c.text_width(TITLE, TITLE_FONT)
    tx = ink_x + (a["iw"] - tw) // 2
    if tx < ink_x:
        tx = ink_x
    c.text(TITLE, tx, top, font = TITLE_FONT, color = TITLE_COLOR)

    right = ink_x + a["iw"] - 1
    if tx + tw - 1 > right:
        right = tx + tw - 1
    return right + 1


def departures(c, ctx):
    st = resolve_station(ctx)
    key = str(ctx.inputs.get("apikey", "")).strip()
    if st == "" or key == "":
        nodata(c, "NOT CONFIGURED", "SET A STATION")
        return

    r = http.get("https://api.bart.gov/api/etd.aspx",
                 params = {"cmd": "etd", "orig": st, "key": key, "json": "y"},
                 ttl_seconds = 60)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO BART DATA", "NO CONNECTION")
        return

    root = r["json"].get("root", {})
    stations = root.get("station", [])
    if len(stations) == 0:
        nodata(c, "NO SUCH STATION",
               clip(c, st, "4x5", c.width - 2 * edge(c) - 2))
        return

    station = stations[0]
    etds = station.get("etd", [])

    rows = []
    for e in etds:
        dest = str(e.get("destination", "")).upper()
        ests = e.get("estimate", [])
        if len(ests) == 0:
            continue
        first = ests[0]
        mins = str(first.get("minutes", "")).upper()
        col = HEX.get(str(first.get("hexcolor", "")).upper(), None)
        if col == None:
            col = HEX.get(str(first.get("color", "WHITE")).upper(), "#DCE4F4")
        rows.append([dest, mins, col])

    c.fill(GROUND)

    if len(rows) == 0:
        # Empty is not an error: no train is a real answer, so it gets the
        # normal panel with the identity block, not the amber card.
        x0 = identity(c) + (4 if c.width >= 128 else 3)
        f = "6x8" if c.width >= 128 else "5x7"
        c.text(clip(c, "NO TRAINS", f, c.width - 1 - edge(c) - x0 + 1),
               (x0 + c.width - 1 - edge(c)) // 2,
               (c.height - FONTH[f]) // 2, font = f, color = "#5E6A88",
               align = "center")
        return

    wide = c.width >= 128
    x0 = identity(c) + (4 if wide else 3)
    right = c.width - 1 - edge(c)          # last column content may use

    # The minutes column is a FIXED reserve sized for its worst string, and
    # the destination column is what is left after a 3px separator. Both
    # edges of the name are therefore known before a single glyph is drawn.
    mfont = "5x7" if wide else "4x5"
    mw = mins_reserve(c, mfont) if wide else mins_reserve_narrow(c, mfont)
    sep = 3 if wide else 2
    avail = right - mw - sep - x0 + 1

    show = 3
    if show > len(rows):
        show = len(rows)

    # Constrain the destinations: pick the one font in which all of them fit
    # the column, then still word-fit each so a name longer than anything
    # BART currently publishes cannot escape the column.
    # "PITTSBURG/BAY POINT" is 113px in 5x7 against a 106px column, which is
    # what drops the board to 4x7 (92px) when that train is on the list.
    names = []
    for i in range(show):
        names.append(rows[i][0])
    nfont = pick_font(c, names, ["5x7", "4x7"] if wide else ["4x5", "3x4"],
                      avail)
    nh = FONTH[nfont]
    mh = FONTH[mfont]
    bh = nh if nh > mh else mh

    lh = c.height // show
    ytop = (c.height - lh * show) // 2

    for i in range(show):
        # Bottom-align the two halves of the row on a shared baseline, then
        # centre that baseline in the row's band, so a 4x7 name and a 5x7
        # readout sit on the same line instead of one hanging a pixel low.
        base = ytop + i * lh + (lh - bh) // 2 + bh - 1

        mins = rows[i][1]
        if mins == "LEAVING":
            label = "LEAVING" if wide else "NOW"
        else:
            label = mins + (" MIN" if wide else "M")
        label = clip(c, label, mfont, mw)
        c.text(label, right + 1, base - mh + 1, font = mfont,
               color = rows[i][2], align = "right")

        c.text(fitwords(c, rows[i][0], nfont, avail), x0, base - nh + 1,
               font = nfont, color = DEST_COLOR)
    # The station caption is dropped: with three departures there is no
    # spare row for it, and you already know which station you set.
