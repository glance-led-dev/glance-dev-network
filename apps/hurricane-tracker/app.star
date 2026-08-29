# Hurricane Tracker
#
# The National Hurricane Center's live storm list. Most of the year
# it is empty, and that is the answer people want — so the quiet
# state is a deliberate all-clear rather than a blank panel.
#
# Category comes from the Saffir-Simpson thresholds applied to the
# intensity in knots, which is what the feed actually carries.



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


def category(kt):
    """Saffir-Simpson from sustained wind in knots."""
    if kt >= 137:
        return ["CAT 5", "#FF3B6B"]
    if kt >= 113:
        return ["CAT 4", "#FF5B3B"]
    if kt >= 96:
        return ["CAT 3", "#FF8A3A"]
    if kt >= 83:
        return ["CAT 2", "#FFB03A"]
    if kt >= 64:
        return ["CAT 1", "#F5D64E"]
    if kt >= 34:
        return ["TROP STORM", "#6FD4FF"]
    return ["TROP DEPR", "#8FA8C8"]


def storms(c, ctx):
    r = http.get("https://www.nhc.noaa.gov/CurrentStorms.json", ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        nodata(c, "NO NHC DATA", "NO CONNECTION")
        return

    active = r["json"].get("activeStorms", [])
    n = len(active)

    if n == 0:
        c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#04120E", "#0A2A20",
                        horizontal = False)
        # Both lines are written for the Scroll, so the 64 gets its own
        # shorter wording rather than a clipped version of this one.
        if c.width >= 128:
            c.text("NO ACTIVE STORMS", c.width // 2, 4, font = "10x16",
                   color = "#4EE38A", align = "center")
            c.text("ATLANTIC AND PACIFIC CLEAR", c.width // 2, 23,
                   font = "4x5", color = "#357A5E", align = "center")
        else:
            c.text("NO STORMS", c.width // 2, 8, font = "6x8",
                   color = "#4EE38A", align = "center")
            c.text("ALL CLEAR", c.width // 2, 20, font = "4x5",
                   color = "#357A5E", align = "center")
        return

    s = active[0]
    name = str(s.get("name", "")).upper()
    kt = int(float(s.get("intensity", 0) or 0))
    cat = category(kt)
    basin = str(s.get("basin", "")).upper()
    mph = int(kt * 1.15078)

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#140409", "#2E0A18",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    c.image("HURRICANE.png", 1, (c.height - sz) // 2, w = sz, h = sz)

    if c.width >= 128:
        # The category is drawn first so the name can be given whatever room is
        # actually left. Before, the name was allowed to reach x=120 (maxw =
        # width - 100) while the category was right-aligned with no limit at
        # all: "TROP STORM" is 107px at 10x16, so it started at x=79 and the
        # two drew through each other for 41px. "CAT 5" is only 53px, which is
        # why the overlap showed up on tropical storms and not on hurricanes.
        #
        # Capping the category at 72px keeps "CAT n" big and drops the two long
        # spelled-out labels to 6x8, which buys the name back ~38px.
        cf = _fit_clip(c, cat[0], ["10x16", "6x8"], 72)
        c.text(cf[1], c.width - 6, 3, font = cf[0], color = cat[1],
               align = "right")
        c.text_fit(name, 28, 2, ["10x16", "6x8", "5x7"], color = "#FFFFFF",
                   maxw = c.width - 42 - c.text_width(cf[1], cf[0]))
        c.text(str(mph) + " MPH   " + basin, c.width - 6, 22, font = "6x8",
               color = "#E8A8B8", align = "right")
        if n > 1:
            c.text("+" + str(n - 1) + " MORE", 28, 22, font = "5x7",
                   color = "#A8788C")
    else:
        c.text_fit(name, c.width - 2, 0, ["6x8", "5x7", "4x5"],
                   color = "#FFFFFF", align = "right", maxw = c.width - 20)
        # "CAT n" fits on one line at 10x16, but "TROP STORM" / "TROP DEPR"
        # do not fit the 44px beside the icon in any font, so the two-word
        # labels are stacked one word per line at 6x8 instead of clipping.
        words = cat[0].split(" ")
        maxw = c.width - 20
        mph_y = 26
        if len(words) == 2 and c.text_width(cat[0], "6x8") > maxw:
            c.text(words[0], c.width - 2, 9, font = "6x8", color = cat[1],
                   align = "right")
            c.text(words[1], c.width - 2, 18, font = "6x8", color = cat[1],
                   align = "right")
            mph_y = 27
        else:
            c.text_fit(cat[0], c.width - 2, 11, ["10x16", "6x8"], color = cat[1],
                       align = "right", maxw = maxw)
        c.text(str(mph) + "MPH", c.width - 2, mph_y, font = "4x5",
               color = "#E8A8B8", align = "right")
