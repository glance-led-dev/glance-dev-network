# Aurora Watch
#
# NOAA's planetary K index, 0-9, from the Space Weather Prediction
# Center. Kp is what actually decides how far south the aurora
# reaches, so the panel translates it into the plain question you
# are really asking: is it worth going outside tonight?



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


# Kp threshold -> [verdict, colour, roughly how far south]
BANDS = [
    [0, "QUIET", "#3A5068", "POLAR ONLY"],
    [3, "UNSETTLED", "#4E9BD6", "HIGH LATITUDES"],
    [5, "STORM", "#4EE38A", "NORTHERN STATES"],
    [6, "STRONG", "#F5C242", "MID LATITUDES"],
    [7, "SEVERE", "#FF7A18", "FAR SOUTH"],
    [8, "EXTREME", "#FF3B3B", "RARE AND WIDE"],
]


def band(kp):
    out = BANDS[0]
    for b in BANDS:
        if kp >= b[0]:
            out = b
    return out


def kp(c, ctx):
    r = http.get("https://services.swpc.noaa.gov/json/planetary_k_index_1m.json",
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO SPACE WX", "SWPC UNREACHABLE")
        return
    rows = r["json"]
    if len(rows) == 0:
        nodata(c, "NO SPACE WX", "EMPTY FEED")
        return

    last = rows[len(rows) - 1]
    val = last.get("estimated_kp", last.get("kp_index", 0))
    kpv = float(val) if val != None else 0.0
    b = band(kpv)

    c.fill("#05070E")
    if c.width >= 128:
        c.text("PLANETARY K INDEX", 6, 2, font = "5x7", color = "#4E5A80")
        c.text(str(int(kpv * 10) / 10.0), 6, 10, font = "16x20", color = b[2])
        c.text(b[1], c.width - 6, 4, font = "10x16", color = b[2],
               align = "right")
        c.text(b[3], c.width - 6, 22, font = "5x7", color = "#6A7090",
               align = "right")
        # the 0-9 scale, so the number has somewhere to sit
        for i in range(10):
            x = 74 + i * 5
            on = i <= int(kpv)
            c.rect(x, 24, x + 3, 29, fill = b[2] if on else "#1A2030")
    else:
        c.text("KP INDEX", c.width // 2, 0, font = "4x5", color = "#4E5A80",
               align = "center")
        c.text(str(int(kpv)), c.width // 2, 5, font = "16x20", color = b[2],
               align = "center")
        c.text_fit(b[1], c.width // 2, 26, ["4x5", "3x4"], color = b[2],
                   align = "center", maxw = c.width - 2)
