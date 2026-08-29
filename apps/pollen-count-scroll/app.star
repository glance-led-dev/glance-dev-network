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


FONT_H = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 6, "3x4": 4}


def fit_font(c, text, fonts, maxw):
    """Largest font in `fonts` that draws `text` inside maxw (smallest if none)."""
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return f
    return fonts[len(fonts) - 1]


def clip_tidy(c, text, font, maxw):
    """clip(), minus the dangling separator a mid-string cut leaves behind."""
    t = clip(c, text, font, maxw)
    for sep in [", ", ",", ".", " "]:
        if t.endswith(sep):
            t = t[:len(t) - len(sep)]
    return t


def clip_names(c, names, font, maxw):
    """As many whole comma-separated names as fit — never half a plant.

    The smaller trigger font fits more of the list, which made a mid-word
    cut ("RAGWEED, NETTLE, CHEN") the common case rather than the rare one.
    Falls back to a plain clip when even the first name overflows."""
    out = ""
    for n in names:
        t = out + ", " + n if out != "" else n
        if c.text_width(t, font) > maxw:
            break
        out = t
    if out == "":
        return clip_tidy(c, ", ".join(names), font, maxw)
    return out


def place(loc, zip):
    """The panel's location line: CITY, ST when the feed names one, else the zip.

    Never per-location art — one text line covers every city the feed can
    return, and the caller shrinks then clips it when the name runs long."""
    city = str(loc.get("City", "") or "").upper().strip()
    st = str(loc.get("State", "") or "").upper().strip()
    z = str(loc.get("ZIP", "") or zip).strip()
    if city == "":
        return ["ZIP " + z, "ZIP " + z]
    if st == "":
        return [city, city]
    return [city + ", " + st, city]


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
    if len(names) == 0:
        names = ["NOTHING LISTED"]

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#0C1408", "#22341A",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 12
    # Wide panels drop the art 4px to row 8, clearing the top rows for the
    # plain POLLEN line; 8 + 24 = 32 still lands the last row on the canvas.
    iy = 8 if c.width >= 128 else (c.height - sz) // 2
    c.image("POLLEN.png", 1, iy, w = sz, h = sz)

    num = str(int(idx * 10) / 10.0)
    long_place, short_place = place(loc, zip)

    if c.width >= 128:
        # Three occupied blocks instead of one number floating in a dead
        # middle: reading + its unit on the left, band pill over the place
        # name on the right, triggers and tomorrow along the bottom.
        x0 = 28
        right = c.width - 10

        # The unit sits in a fixed-width stack beside the figure, so the
        # figure drops a rung once a 3-4 digit reading would push the pair
        # past its lane rather than shoving the right column off-panel.
        uw = c.text_width("/12", "6x8")
        if c.text_width("INDEX", "4x5") > uw:
            uw = c.text_width("INDEX", "4x5")
        # Reading and unit sit on a common bottom at row 25, one clear pixel
        # above the trigger line's row 27 top, whatever rung the figure lands
        # on — a 3-4 digit reading drops a font and stays bottom-aligned.
        numf = fit_font(c, num, ["16x20", "10x16", "6x8"], 100 - 4 - uw)
        numt = clip_tidy(c, num, numf, 100 - 4 - uw)
        c.text(numt, x0, 26 - FONT_H[numf], font = numf, color = b[2])
        ux = x0 + c.text_width(numt, numf) + 4
        c.text("/12", ux, 12, font = "6x8", color = "#A8C098")
        c.text("INDEX", ux, 21, font = "4x5", color = "#7E9870")

        # What the number is, named once: plain word, no chip, its top ink row
        # on the panel's first pixel and its left edge on the same x the pill
        # used to start from. Five ink rows is the ceiling here — the reading
        # sits on a common bottom at row 25 and its tallest rung tops out at
        # row 6, so a 7-row face would have 5x5's 35px run into the first digit
        # at x=28. Rows 0-4 across x=7..41 are otherwise empty: the art now
        # starts at row 8 and the right column starts past x=100.
        c.text("POLLEN", 1 + sz // 4, 0, font = "5x5", color = "#E8B04A")

        colx = ux + uw + 5
        colw = right - colx + 1

        # Longest place string that fits, then the bare city, then a clip.
        pf = "5x7"
        ptxt = long_place
        if c.text_width(ptxt, pf) > colw:
            ptxt = short_place
        if c.text_width(ptxt, pf) > colw:
            pf = "4x5"
            ptxt = long_place
            if c.text_width(ptxt, pf) > colw:
                ptxt = clip_tidy(c, short_place, pf, colw)
        c.text(ptxt, right, 8 - FONT_H[pf], font = pf, color = "#D2E4C2",
               align = "right")

        # The pill is padded out to the column so the block reads as one
        # slab under the place name instead of a word adrift in a corner.
        bf = fit_font(c, b[1], ["6x8", "5x7", "4x5"], colw - 4)
        btxt = clip(c, b[1], bf, colw - 4)
        bpad = (colw - c.text_width(btxt, bf)) // 2
        if bpad < 2:
            bpad = 2
        bw = c.text_width(btxt, bf) + 2 * bpad
        c.badge(btxt, right - bw + 1, 11, color = "#0C1408", bg = b[2],
                font = bf, pad = bpad)

        tw = 0
        if tom != None and tom.get("Index", None) != None:
            tv = float(tom.get("Index", 0) or 0)
            tstr = "TMRW " + str(int(tv * 10) / 10.0)
            tw = c.text_width(tstr, "5x7") + 6
            c.text(tstr, right, 25, font = "5x7", color = "#7E9870",
                   align = "right")
        # Bottom line: 4x5, ink ending on row 31, and clipped to the gap left
        # by the tomorrow figure so the longest trigger list cannot reach it.
        c.text(clip_names(c, names, "4x5", right - tw - x0 + 1), x0, 27,
               font = "4x5", color = "#A8C098")
    else:
        # Narrow panels get the same three facts stacked: place, figure with
        # its unit, band. The icon drops to 12px so the figure and its unit
        # share a row without either one riding over the art.
        right = c.width - 2
        c.text(clip_tidy(c, long_place, "4x5", c.width - 2), 1, 0,
               font = "4x5", color = "#D2E4C2")
        uw = c.text_width("/12", "4x5")
        ncap = right - 15 - 1 - uw
        nf = fit_font(c, num, ["16x20", "10x16", "6x8", "4x5"], ncap)
        c.text(clip_tidy(c, num, nf, ncap), right - uw - 2, 24 - FONT_H[nf],
               font = nf, color = b[2], align = "right")
        c.text("/12", right, 19, font = "4x5", color = "#A8C098",
               align = "right")
        c.text_fit(b[1], right, 26, ["4x5", "3x4"], color = b[2],
                   align = "right", maxw = c.width - 4)
