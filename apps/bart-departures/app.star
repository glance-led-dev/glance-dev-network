# BART Departures
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


HEX = {"RED": "#FF4B4B", "ORANGE": "#FF9A3A", "YELLOW": "#F5D64E",
       "GREEN": "#4EE38A", "BLUE": "#4EA8FF", "WHITE": "#DCE4F4",
       "PURPLE": "#B46BE8", "BEIGE": "#D8C8A0"}


def departures(c, ctx):
    st = str(ctx.inputs.get("station", "")).strip().upper()
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
        nodata(c, "NO SUCH STATION", clip(c, st, "4x5", c.width - 8))
        return

    station = stations[0]
    name = str(station.get("name", st)).upper()
    etds = station.get("etd", [])
    if len(etds) == 0:
        c.fill("#0A0C14")
        c.text("NO TRAINS", c.width // 2, c.height // 2 - 4,
               font = "10x16" if c.width >= 128 else "6x8", color = "#5E6A88",
               align = "center")
        return

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

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#05070E", "#141C2E",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    c.image("TRAIN.png", 1, (c.height - sz) // 2, w = sz, h = sz)

    # Three rows on both panels: two left a hollow band across the middle
    # of the 64. The small panel drops to 4x5 so full station names fit.
    show = 3
    if show > len(rows):
        show = len(rows)
    wide = c.width >= 128
    font = "5x7" if wide else "4x5"
    x0 = 28 if wide else 19
    lh = c.height // show if show > 0 else c.height

    for i in range(show):
        y = i * lh + (lh - 7) // 2
        mins = rows[i][1]
        if mins == "LEAVING":
            label = "LEAVING" if wide else "NOW"
        else:
            label = mins + (" MIN" if wide else "M")
        mw = c.text_width(label, font) + 4
        c.text(label, c.width - 3, y, font = font, color = rows[i][2],
               align = "right")
        avail = c.width - x0 - mw - 4
        nm = rows[i][0]
        # Station names are single words, so word-fitting cannot help them.
        # Stepping down to 3x4 fits ANTIOCH whole instead of cutting to ANTIO.
        nf = font
        if not wide and c.text_width(nm, font) > avail:
            nf = "3x4"
        c.text(fitwords(c, nm, nf, avail), x0, y + (1 if nf == "3x4" else 0),
               font = nf, color = "#C8D4EC")
    # The station caption is dropped: with three departures there is no
    # spare row for it, and you already know which station you set.
