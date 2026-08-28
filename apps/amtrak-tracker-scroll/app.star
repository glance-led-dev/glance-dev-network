# Amtrak Tracker
#
# Amtraker v3, a community mirror of Amtrak's live map. No key.
#
# It is fetched one train at a time on purpose: the all-trains
# endpoint is over a megabyte and would blow the response cap.
#
# The wide panel is a railroad — the track runs its full width and
# the locomotive sits at the train's real position along the route,
# which is the best use of this aspect ratio in the catalog.



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


def nodata(c, title, sub, narrow_title = "", narrow_sub = ""):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands — a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail

    narrow_title/narrow_sub are shorter wordings for a 64 panel, where 58px
    is all there is: "NO TRAIN DATA" measures 60px even in 4x5, the smallest
    font offered, so _fit_clip could only ever chop it to "NO TRAIN DAT".
    Passing a phrase that fits beats clipping one that does not.
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
        nt = narrow_title if narrow_title != "" else title
        ns = narrow_sub if narrow_sub != "" else sub
        t = _fit_clip(c, nt, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, ns, ["4x5"], maxw)
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


TRAINS = {
    "ADIRONDACK 68": "68",
    "ADIRONDACK 69": "69",
    "AUTO TRAIN 52": "52",
    "AUTO TRAIN 53": "53",
    "CALIFORNIA ZEPHYR 5": "5",
    "CALIFORNIA ZEPHYR 6": "6",
    "CARDINAL 50": "50",
    "CARDINAL 51": "51",
    "CAROLINIAN 79": "79",
    "CAROLINIAN 80": "80",
    "CITY OF NEW ORLEANS 58": "58",
    "CITY OF NEW ORLEANS 59": "59",
    "COAST STARLIGHT 11": "11",
    "COAST STARLIGHT 14": "14",
    "CRESCENT 19": "19",
    "CRESCENT 20": "20",
    "EMPIRE BUILDER 7": "7",
    "EMPIRE BUILDER 8": "8",
    "FLORIDIAN 40": "40",
    "FLORIDIAN 41": "41",
    "HEARTLAND FLYER 821": "821",
    "HEARTLAND FLYER 822": "822",
    "LAKE SHORE LIMITED 48": "48",
    "LAKE SHORE LIMITED 49": "49",
    "MAPLE LEAF 63": "63",
    "MAPLE LEAF 64": "64",
    "NORTHEAST REGIONAL 173": "173",
    "NORTHEAST REGIONAL 66": "66",
    "NORTHEAST REGIONAL 67": "67",
    "NORTHEAST REGIONAL 85": "85",
    "NORTHEAST REGIONAL 93": "93",
    "NORTHEAST REGIONAL 94": "94",
    "PALMETTO 89": "89",
    "PALMETTO 90": "90",
    "PENNSYLVANIAN 42": "42",
    "PENNSYLVANIAN 43": "43",
    "SILVER METEOR 97": "97",
    "SILVER METEOR 98": "98",
    "SOUTHWEST CHIEF 3": "3",
    "SOUTHWEST CHIEF 4": "4",
    "SUNSET LIMITED 1": "1",
    "SUNSET LIMITED 2": "2",
    "TEXAS EAGLE 21": "21",
    "TEXAS EAGLE 22": "22",
    "VERMONTER 55": "55",
    "VERMONTER 56": "56",
}


def resolve_train(ctx):
    """Train number for the picked service.

    The setting used to be the bare number, which meant knowing that the
    California Zephyr is 5 westbound and 6 eastbound before you could watch
    it. The dropdown carries "ROUTE NUMBER" labels and this maps them back.

    The number is what the feed is keyed on, so resolving here means both the
    request path and the response lookup use it. Anything that is not a known
    label falls through unchanged, so a number saved under the old free-text
    field still works.
    """
    v = str(ctx.inputs.get("number", "")).strip().upper()
    if v in TRAINS:
        return TRAINS[v]
    return v


def _days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def iso_minutes(s):
    """"2026-08-12T18:46:00-04:00" -> minutes, for differencing two stamps.

    Both stamps in a comparison come from the same station in the same feed,
    so they share a timezone offset and it cancels out -- which is why the
    offset is ignored rather than parsed. The date is included because a
    delayed overnight train can push arr past midnight while schArr sits on
    the previous day, and a time-only diff would read that as 23 hours early.
    """
    if len(s) < 16:
        return None
    return (_days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10])) * 1440
            + int(s[11:13]) * 60 + int(s[14:16]))


def iso_clock(s):
    """"2026-08-12T18:46:00-04:00" -> "6:46P", in the station's own local time."""
    if len(s) < 16:
        return ""
    hh = int(s[11:13])
    ap = "A" if hh < 12 else "P"
    h = hh % 12
    if h == 0:
        h = 12
    return str(h) + ":" + fmt.pad(int(s[14:16])) + ap


def timing(st):
    """[text, colour] for how late the train is into its next stop.

    trainTimely is the feed's own summary, but it is frequently an empty
    string -- it was blank on every train sampled while building this -- so
    the delay is computed from the stop's own arr vs schArr instead.
    """
    arr = str(st.get("arr", ""))
    sch = str(st.get("schArr", ""))
    a = iso_minutes(arr)
    s = iso_minutes(sch)
    if a == None or s == None:
        return ["", "#8FA8D8"]
    d = a - s
    if d >= 3:
        return ["+" + str(d) + " LATE", "#FF7A5B"]
    if d <= -3:
        return [str(-d) + " EARLY", "#7FB6E8"]
    return ["ON TIME", "#4EE38A"]


def train(c, ctx):
    num = resolve_train(ctx)
    if num == "":
        nodata(c, "NO TRAIN", "SET A NUMBER")
        return

    r = http.get("https://api-v3.amtraker.com/v3/trains/" + num,
                 ttl_seconds = 300)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO TRAIN DATA", "NO CONNECTION", "NO DATA", "NO NETWORK")
        return

    runs = r["json"].get(num, [])
    if len(runs) == 0:
        c.fill("#060A12")
        c.text("NOT RUNNING", c.width // 2, c.height // 2 - 4,
               font = "10x16" if c.width >= 128 else "5x7", color = "#5E6A88",
               align = "center")
        return

    t = runs[0]
    route = str(t.get("routeName", "")).upper()
    stations = t.get("stations", [])
    dest = str(t.get("destCode", "")).upper()
    orig = str(t.get("origCode", "")).upper()
    speed = int(float(t.get("velocity", 0) or 0))

    done = 0
    nxt = dest
    nxtst = None
    for s in stations:
        st = str(s.get("status", "")).upper()
        if st == "DEPARTED":
            done += 1
        elif nxtst == None:
            nxt = str(s.get("code", dest)).upper()
            nxtst = s
    frac = 0.0 if len(stations) <= 1 else done / float(len(stations) - 1)
    if frac > 1.0:
        frac = 1.0

    eta = iso_clock(str(nxtst.get("arr", ""))) if nxtst != None else ""
    tm = timing(nxtst) if nxtst != None else ["", "#8FA8D8"]
    timely = tm[0]
    col = tm[1]

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#05080F", "#131C2E",
                    horizontal = False)

    # The track owns the bottom band on its own. The locomotive used to be a
    # 20px sprite hung above the rail, spanning y=10..30, so it drove straight
    # through the text row at y=11 -- and because it is positioned by progress
    # along the route, which row it landed on changed as the train moved.
    # Rail at 30, sprite 10px sitting on it, nothing else below y=24.
    railw = 8
    c.rect(0, 30, c.width - 1, 30, fill = "#4A5470")
    for x in range(1, c.width, 4):
        c.rect(x, 31, x + 1, 31, fill = "#2E364A")
    lx = int(frac * (c.width - railw - 2))
    c.image("LOCO.png", lx, 24, w = railw, h = railw)

    if c.width >= 128:
        # Three bands of two columns, then the track: 0-7, 9-15, 17-23, 24-31.
        # The old layout had two rows and a big sprite, which left the middle
        # of a 192px panel empty; origin/destination, the arrival time and the
        # speed were all sitting unused in the same response.
        # 10px margins both sides (was 4 left / 6 right): the scroll safe
        # zone, and matching margins so the block reads centered.
        c.text(fitwords(c, route, "6x8", c.width - 78), 10, 0, font = "6x8",
               color = "#8FA8D8")
        c.text("#" + num, c.width - 10, 0, font = "6x8", color = "#C8D4EC",
               align = "right")

        if orig != "" and dest != "":
            # "-" not ">": the bitmap fonts have no '>' glyph, so it measured 0px
            # and drew nothing, leaving "CHI  EMY" with a hole in the middle.
            c.text(orig + "-" + dest, 10, 9, font = "5x7", color = "#C8D4EC")
        nx = "NEXT " + nxt
        if eta != "":
            nx = nx + " " + eta
        c.text(nx, c.width - 10, 9, font = "5x7", color = "#DCE4F4",
               align = "right")

        c.text(fitwords(c, timely, "5x7", 90), 10, 17, font = "5x7", color = col)
        if speed > 0:
            c.text(str(speed) + " MPH", c.width - 10, 17, font = "5x7",
                   color = "#7F8CA8", align = "right")
        else:
            c.text("STOPPED", c.width - 10, 17, font = "5x7", color = "#7F8CA8",
                   align = "right")
    else:
        c.text("#" + num, 2, 0, font = "5x7", color = "#C8D4EC")
        c.text(nxt, c.width - 2, 0, font = "5x7", color = "#8FA8D8",
               align = "right")
        # 64px cannot hold the arrival time and the endpoints side by side at
        # full size, so the time is placed first and the endpoints get only
        # what is left -- dropping out entirely rather than colliding.
        etaw = 0
        if eta != "":
            c.text(eta, c.width - 2, 9, font = "5x7", color = "#DCE4F4",
                   align = "right")
            etaw = c.text_width(eta, "5x7")
        if orig != "" and dest != "":
            ends = orig + "-" + dest
            # All of it or none: a clipped "CHI-S" reads as a rendering fault
            # rather than an abbreviation.
            if c.text_width(ends, "4x5") <= c.width - etaw - 8:
                c.text(ends, 2, 10, font = "4x5", color = "#7F8CA8")
        c.text(fitwords(c, timely, "4x5", c.width - 4), 2, 17, font = "4x5",
               color = col)
