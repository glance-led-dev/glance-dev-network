# Tide Clock
#
# NOAA CO-OPS high/low predictions. Whether the tide is rising or
# falling is worked out from which extreme comes next, which is the
# thing you actually want to know standing on a beach.



MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


def is_leap(y):
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


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


def tides(c, ctx):
    station = str(ctx.inputs.get("station", "")).strip()
    if station == "":
        nodata(c, "NO STATION", "SET A STATION ID")
        return

    r = http.get("https://api.tidesandcurrents.noaa.gov/api/prod/datagetter",
                 params = {"product": "predictions", "application": "glance",
                           "datum": "MLLW", "station": station,
                           "time_zone": "lst_ldt", "units": "english",
                           "interval": "hilo", "format": "json",
                           "date": "today"},
                 ttl_seconds = 1800)
    if r["status_code"] != 200 or not r["json"]:
        nodata(c, "NO TIDE DATA", "NO CONNECTION")
        return
    rows = r["json"].get("predictions", [])
    if len(rows) == 0:
        nodata(c, "NO PREDICTIONS", "CHECK STATION")
        return

    # Station time is local; ctx.now is UTC, so compare on clock time only and
    # fall back to the first entry once the day's list is exhausted.
    nowhm = fmt.pad(ctx.now.hour) + ":" + fmt.pad(ctx.now.minute)
    nxt = None
    for row in rows:
        t = str(row.get("t", ""))
        if len(t) >= 16 and t[11:16] > nowhm:
            nxt = row
            break
    if nxt == None:
        nxt = rows[len(rows) - 1]

    rising = str(nxt.get("type", "H")).upper() == "H"
    label = "HIGH" if rising else "LOW"
    arrow = "RISING" if rising else "FALLING"
    col = "#4EA8FF" if rising else "#7A8FA8"
    when = str(nxt.get("t", ""))[11:16]
    ft = float(nxt.get("v", 0) or 0)

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#04101C", "#0B2A44",
                    horizontal = False)
    n = 24 if c.width >= 128 else 16
    c.image("TIDE.png", 2, c.height - n + 4, w = n, h = n)

    if c.width >= 128:
        c.text("NEXT " + label, 30, 2, font = "4x5", color = "#5E82A0")
        c.text(when, 30, 8, font = "16x20", color = col)
        c.text(arrow, c.width - 6, 4, font = "10x16", color = col,
               align = "right")
        c.text(str(int(ft * 10) / 10.0) + " FT", c.width - 6, 23, font = "6x8",
               color = "#8FC4E8", align = "right")
    else:
        c.text(label, 20, 1, font = "4x5", color = "#5E82A0")
        c.text_fit(when, c.width - 2, 7, ["16x20", "10x16"], color = col,
                   align = "right", maxw = c.width - 20)
        c.text(str(int(ft * 10) / 10.0) + "FT", c.width - 2, 25, font = "4x5",
               color = "#8FC4E8", align = "right")
