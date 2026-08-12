# Solar Flares
#
# GOES X-ray flux from NOAA SWPC. Flare class is logarithmic —
# A, B, C, M, X each a factor of ten — so the class letter is far
# more readable than the raw watts per square metre, and M and X
# are the ones that black out HF radio on the daylit side.



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


def flare_class(flux):
    """GOES long-band flux (W/m2) -> class letter and magnitude."""
    if flux <= 0:
        return ["--", 0.0, "#5A6078", "NO DATA"]
    if flux >= 1e-4:
        return ["X", flux / 1e-4, "#FF3B3B", "RADIO BLACKOUT"]
    if flux >= 1e-5:
        return ["M", flux / 1e-5, "#FF9A4A", "BRIEF HF FADES"]
    if flux >= 1e-6:
        return ["C", flux / 1e-6, "#F5D64E", "MINOR ACTIVITY"]
    if flux >= 1e-7:
        return ["B", flux / 1e-7, "#6FD4FF", "QUIET SUN"]
    return ["A", flux / 1e-8, "#5A8098", "VERY QUIET"]


def flux(c, ctx):
    r = http.get("https://services.swpc.noaa.gov/json/goes/primary/xrays-6-hour.json",
                 ttl_seconds = 900)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO SWPC DATA", "NO CONNECTION")
        return
    rows = r["json"]
    if len(rows) == 0:
        nodata(c, "NO SWPC DATA", "EMPTY FEED")
        return

    # The feed interleaves two energy bands; the long band is the one the
    # flare classification is defined on.
    latest = None
    for i in range(len(rows) - 1, -1, -1):
        e = str(rows[i].get("energy", ""))
        if e.find("0.1-0.8") >= 0:
            latest = rows[i]
            break
    if latest == None:
        latest = rows[len(rows) - 1]

    f = float(latest.get("flux", 0) or 0)
    cl = flare_class(f)
    label = cl[0] + (str(int(cl[1] * 10) / 10.0) if cl[0] != "--" else "")

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#140C02", "#301A04",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    c.image("FLARE.png", 1, (c.height - sz) // 2, w = sz, h = sz)

    if c.width >= 128:
        c.text("X-RAY FLUX", 30, 2, font = "4x5", color = "#A07840")
        c.text_fit(label, 30, 8, ["16x20", "10x16"], color = cl[2],
                   maxw = c.width - 130)
        c.text_fit(cl[3], c.width - 6, 6, ["6x8", "5x7"], color = cl[2],
                   align = "right", maxw = c.width - 110)
        c.text("GOES PRIMARY", c.width - 6, 24, font = "4x5",
               color = "#8A6838", align = "right")
    else:
        c.text_fit(label, c.width - 2, 4, ["16x20", "10x16"], color = cl[2],
                   align = "right", maxw = c.width - 20)
        c.text_fit(cl[3], c.width - 2, 25, ["4x5", "3x4"], color = cl[2],
                   align = "right", maxw = c.width - 4)
