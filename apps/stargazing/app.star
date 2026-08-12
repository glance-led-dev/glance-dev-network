# Stargazing
#
# Three things decide a night: cloud cover, how much moon is in the
# sky, and whether it is dark yet. Cloud comes from Open-Meteo; the
# moon's phase is computed from a known new moon, so it works even
# when the forecast does not.
#
# The verdict weights cloud most heavily, because a clear night with
# a full moon still shows you plenty and an overcast one shows you
# nothing at all.



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


SYNODIC = 29.530588853
NEW_MOON = 947182440          # 2000-01-06 18:14 UTC, a known new moon


def phase(unix):
    """0 = new, 0.5 = full."""
    return ((unix - NEW_MOON) / 86400.0 % SYNODIC) / SYNODIC


def phase_name(p):
    if p < 0.03 or p > 0.97:
        return "NEW MOON"
    if p < 0.22:
        return "WAXING CRESCENT"
    if p < 0.28:
        return "FIRST QUARTER"
    if p < 0.47:
        return "WAXING GIBBOUS"
    if p < 0.53:
        return "FULL MOON"
    if p < 0.72:
        return "WANING GIBBOUS"
    if p < 0.78:
        return "LAST QUARTER"
    return "WANING CRESCENT"


def illum(p):
    """Illuminated fraction, 0-1."""
    return (1.0 - math.cos(2.0 * math.pi * p)) / 2.0


def tonight(c, ctx):
    g = geo(ctx)
    if g == None:
        nodata(c, "NO LOCATION", "SET A ZIP CODE")
        return

    r = http.get("https://api.open-meteo.com/v1/forecast",
                 params = {"latitude": str(g[0]), "longitude": str(g[1]),
                           "daily": "cloud_cover_mean", "timezone": "auto",
                           "forecast_days": "1"},
                 ttl_seconds = 1800)
    cloud = None
    if r["status_code"] == 200 and r["json"]:
        vals = r["json"].get("daily", {}).get("cloud_cover_mean", [])
        if len(vals) > 0 and vals[0] != None:
            cloud = float(vals[0])

    p = phase(ctx.now.unix)
    lit = illum(p)

    # Cloud dominates: a clear night under a full moon still shows you plenty.
    if cloud == None:
        score = int(100 - lit * 40)
        note = "CLOUD UNKNOWN"
    else:
        score = int((100 - cloud) * 0.75 + (1.0 - lit) * 25)
        note = str(int(cloud)) + "% CLOUD"

    if score >= 70:
        verdict = "EXCELLENT"
        col = "#6FE38A"
    elif score >= 50:
        verdict = "DECENT"
        col = "#F5D64E"
    elif score >= 30:
        verdict = "POOR"
        col = "#FF9A4A"
    else:
        verdict = "STAY IN"
        col = "#FF5B5B"

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#04060F", "#111A34",
                    horizontal = False)
    for s in [[9, 5], [27, 12], [49, 4], [70, 17], [104, 7], [138, 14],
              [163, 5], [184, 19]]:
        if s[0] < c.width:
            c.pixel(s[0], s[1], "#48538A")

    n = 24 if c.width >= 128 else 16
    c.image("MOON.png", 4, (c.height - n) // 2, w = n, h = n)
    if cloud != None and cloud >= 55:
        c.image("CLOUD.png", 4 + n // 3, (c.height - n) // 2 + n // 4,
                w = n, h = n)

    if c.width >= 128:
        # Right column first, then the verdict fitted to what is left.
        c.text(phase_name(p), c.width - 6, 4, font = "5x7", color = "#A8B4DC",
               align = "right")
        c.text_fit(verdict, 36, 5, ["16x20", "10x16", "6x8"], color = col,
                   maxw = c.width - 130)
        c.text(str(int(lit * 100)) + "% LIT", c.width - 6, 14, font = "5x7",
               color = "#7C88B4", align = "right")
        c.text(note, c.width - 6, 23, font = "5x7", color = "#7C88B4",
               align = "right")
    else:
        c.text_fit(verdict, c.width - 2, 4, ["10x16", "6x8", "5x7"],
                   color = col, align = "right", maxw = c.width - n - 8)
        c.text(note, c.width - 2, 24, font = "4x5", color = "#7C88B4",
               align = "right")
