# Laundry Day
#
# Drying is a race between evaporation and rain. Open-Meteo's
# reference evapotranspiration is exactly the quantity agronomists
# use for it, so it does the work here — with rain as an outright
# veto, because one shower undoes a whole afternoon.



def geo(ctx):
    """[lat, lon, place] for the configured zip, or None when unavailable."""
    zip = str(ctx.inputs.get("zip", "")).strip()
    if zip == "":
        return None
    g = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if g["status_code"] != 200 or not g["json"]:
        return None
    places = g["json"].get("places", [])
    if not places:
        return None
    p = places[0]
    return [float(p["latitude"]), float(p["longitude"]),
            str(p.get("place name", "")).upper()]


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


def verdict(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP")
        return
    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "et0_fao_evapotranspiration,precipitation_probability_max,wind_speed_10m_max",
                           # Pinned, not left to the default. Open-Meteo
                           # answers in km/h unless asked otherwise, so the
                           # unlabelled wind on this panel was km/h being read
                           # as mph by an app whose only setting is a US zip
                           # -- 16 on the panel meant 10.
                           "wind_speed_unit": "mph",
                           "timezone": "auto", "forecast_days": "1"},
                 ttl_seconds = 7200)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO FORECAST", "NO CONNECTION")
        return
    d = r["json"].get("daily", {})

    def first(key):
        v = d.get(key, [])
        return float(v[0] or 0) if len(v) > 0 and v[0] != None else 0.0

    et = first("et0_fao_evapotranspiration")
    rain = first("precipitation_probability_max")
    wind = first("wind_speed_10m_max")

    if rain >= 50:
        line = "KEEP IT IN"
        col = "#FF5B5B"
        note = str(int(rain)) + "% RAIN"
    elif et >= 4.0 and rain < 20:
        line = "PERFECT"
        col = "#4EE38A"
        note = "DRY AND BREEZY"
    elif et >= 2.5:
        line = "WORTH IT"
        col = "#F5D64E"
        note = "SLOW BUT FINE"
    else:
        line = "USE THE DRYER"
        col = "#FF9A4A"
        note = "TOO DAMP"

    c.fill("black")
    n = 24 if c.width >= 128 else 16
    c.image("LAUNDRY.png", 4, 2, w = n, h = n)

    if c.width >= 128:
        # Three stacked rows to the right of the icon: 0-15 verdict, 17-23
        # note, 25-31 detail, with a blank row between each. 16+7+7 is 30 of
        # the 32 rows, so those two spare pixels are the whole gap budget --
        # butting the rows together leaves the 5x7 lines looking merged.
        #
        # The verdict used to be left-aligned with maxw = width-70 (reaching
        # x=152) while the note was right-aligned with no limit at all
        # (starting at x=95 for "SLOW BUT FINE"), so the two drew straight
        # through each other. Every row is left-aligned at x=30 now, which
        # also means no pair can collide as the strings change.
        # LAUNDRY pill rides 4px off the end of the verdict, wherever the
        # verdict happens to end.
        c.text(line, 32, 0, font = "10x16", color = col)
        c.badge("LAUNDRY", 32 + c.text_width(line, "10x16") + 4, 0,
                color = "black", bg = "#7FB6E8", font = "4x5")
        c.text(note, 32, 17, font = "5x7", color = "#B0BCD4")
        # Two spaces, and MPH tight against the number: at three spaces the
        # worst realistic reading ("DRYING 12.5MM   WIND 100 MPH") is 167px
        # against the 156px this row has, so it would have overflowed exactly
        # the way the bugs this batch has been fixing do.
        c.text("DRYING " + str(int(et * 10) / 10.0) + "MM  WIND "
               + str(int(wind)) + "MPH", 32, 25, font = "5x7",
               color = "#78849C")
    else:
        c.text_fit(line, c.width - 2, 8, ["10x16", "6x8", "5x7"], color = col,
                   align = "right", maxw = c.width - 20)
        # 4x5 only: 3x4 has no space glyph, so "DRY AND BREEZY" came out as
        # "DRYANDBREEZY". That one note is 65px at 4x5 against 60px of panel,
        # so it cannot simply widen -- the narrow layout takes a shorter
        # wording instead of a broken one. The verdict above it already
        # carries the meaning. Every other note fits as written.
        short = "BREEZY" if note == "DRY AND BREEZY" else note
        c.text_fit(short, c.width - 2, 25, ["4x5"], color = "#B0BCD4",
                   align = "right", maxw = c.width - 4)
