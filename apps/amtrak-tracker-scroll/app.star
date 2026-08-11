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


def train(c, ctx):
    num = str(ctx.inputs.get("number", "")).strip()
    if num == "":
        nodata(c, "NO TRAIN", "SET A NUMBER")
        return

    r = http.get("https://api-v3.amtraker.com/v3/trains/" + num,
                 ttl_seconds = 300)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO TRAIN DATA", "NO CONNECTION")
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
    timely = str(t.get("trainTimely", "")).upper()
    stations = t.get("stations", [])
    dest = str(t.get("destCode", "")).upper()

    done = 0
    nxt = dest
    for s in stations:
        st = str(s.get("status", "")).upper()
        if st == "DEPARTED":
            done += 1
        elif nxt == dest:
            nxt = str(s.get("code", dest)).upper()
    frac = 0.0 if len(stations) <= 1 else done / float(len(stations) - 1)
    if frac > 1.0:
        frac = 1.0

    late = timely.find("LATE") >= 0
    col = "#FF7A5B" if late else "#4EE38A"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#05080F", "#131C2E",
                    horizontal = False)

    ty = c.height - 8
    c.rect(0, ty + 4, c.width - 1, ty + 5, fill = "#4A5470")
    for x in range(1, c.width, 4):
        c.rect(x, ty + 6, x + 1, ty + 6, fill = "#2E364A")

    ls = 20 if c.width >= 128 else 14
    lx = int(frac * (c.width - ls - 2))
    c.image("LOCO.png", lx, ty - ls + 6, w = ls, h = ls)

    if c.width >= 128:
        c.text(fitwords(c, route, "6x8", c.width - 92), 4, 1, font = "6x8",
               color = "#8FA8D8")
        c.text("#" + num, c.width - 6, 1, font = "6x8", color = "#C8D4EC",
               align = "right")
        c.text(fitwords(c, timely, "5x7", 110), 4, 11, font = "5x7", color = col)
        c.text("NEXT " + nxt, c.width - 6, 11, font = "5x7", color = "#8FA8D8",
               align = "right")
    else:
        c.text("#" + num, 2, 1, font = "5x7", color = "#C8D4EC")
        c.text(nxt, c.width - 2, 1, font = "5x7", color = "#8FA8D8",
               align = "right")
        c.text(fitwords(c, timely, "4x5", c.width - 4), 2, 10, font = "4x5",
               color = col)
