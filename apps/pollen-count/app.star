# Pollen Count
#
# pollen.com's forecast, keyed by US zip, on the standard 0-12
# index. Open-Meteo's pollen layer was the obvious choice until
# you check it: it comes from CAMS, which models Europe only,
# and answers 200 with nulls everywhere in America.
#
# The endpoint requires a Referer header and returns 405
# without one, so this sends it explicitly.
#
# Naming the triggering plants is the point: MED-HIGH tells you
# little, GRASSES NETTLE tells you whether it is your problem.



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


# The published 0-12 scale.
BANDS = [
    [0.0, "LOW", "#4EE38A"],
    [2.5, "LOW-MED", "#A8E34E"],
    [4.9, "MEDIUM", "#F5D64E"],
    [7.3, "MED-HIGH", "#FF9A4A"],
    [9.7, "HIGH", "#FF5B5B"],
]


def band(v):
    out = BANDS[0]
    for b in BANDS:
        if v >= b[0]:
            out = b
    return out


def period(loc, name):
    for p in loc.get("periods", []):
        if str(p.get("Type", "")).upper() == name:
            return p
    return None


def today(c, ctx):
    zip = str(ctx.inputs.get("zip", "")).strip()
    if zip == "":
        nodata(c, "NO ZIP", "SET A ZIP CODE")
        return

    r = http.get("https://www.pollen.com/api/forecast/current/pollen/" + zip,
                 headers = {"User-Agent": "Mozilla/5.0",
                            "Referer": "https://www.pollen.com/forecast/current/pollen/" + zip,
                            "Accept": "application/json"},
                 ttl_seconds = 3600)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO POLLEN DATA", "CHECK THE ZIP")
        return

    loc = r["json"].get("Location", {})
    tod = period(loc, "TODAY")
    tom = period(loc, "TOMORROW")
    if tod == None or tod.get("Index", None) == None:
        nodata(c, "NO READING", "NOT COVERED HERE")
        return

    idx = float(tod.get("Index", 0) or 0)
    b = band(idx)

    names = []
    for t in tod.get("Triggers", []):
        nm = str(t.get("Name", "")).upper()
        if nm != "":
            names.append(nm)
    triggers = ", ".join(names) if len(names) > 0 else "NOTHING LISTED"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0C1408", "#22341A",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    c.image("POLLEN.png", 1, (c.height - sz) // 2, w = sz, h = sz)

    if c.width >= 128:
        c.text(str(int(idx * 10) / 10.0), 30, 4, font = "16x20", color = b[2])
        c.text_fit(b[1], c.width - 6, 3, ["10x16", "6x8"], color = b[2],
                   align = "right", maxw = c.width - 112)
        # Tomorrow's figure owns the lower right, so the trigger list is
        # clipped to the width genuinely free beside it.
        c.text(clip(c, triggers, "5x7", c.width - 92), 30, 25, font = "5x7",
               color = "#A8C098")
        if tom != None and tom.get("Index", None) != None:
            tv = float(tom.get("Index", 0) or 0)
            c.text("TMRW " + str(int(tv * 10) / 10.0), c.width - 6, 21,
                   font = "5x7", color = "#7E9870", align = "right")
    else:
        c.text_fit(str(int(idx * 10) / 10.0), c.width - 2, 2,
                   ["16x20", "10x16"], color = b[2], align = "right",
                   maxw = c.width - 20)
        c.text_fit(b[1], c.width - 2, 25, ["4x5", "3x4"], color = b[2],
                   align = "right", maxw = c.width - 4)
