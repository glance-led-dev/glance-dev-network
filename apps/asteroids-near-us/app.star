# Close Approach (192x32)
#
# One HTTP call to NASA's Near Earth Object service. With no dates in the
# request, the feed returns the next 7 days keyed by date, so the earliest
# key is today. No date math needed.
#
# Every field NASA sends back is a STRING, even the numbers, so anything we
# want to compare or format has to go through float() first.

MUTED   = "#7C8BA6"
DIM     = "#3A4050"
SAFE    = "#7CD4FF"      # blue: just another rock going by
CLOSE   = "#FFB000"      # amber: inside 10 lunar distances
HAZARD  = "#FF3B30"      # red: NASA flagged it potentially hazardous

# Four tones, lit from the upper left. H is the sunlit face, M the body,
# S the terminator falling into shadow, C the craters.
TONES = {
    "H": "#C4BAA8",
    "M": "#8C8478",
    "S": "#544E46",
    "C": "#3B362F",
}

# 22x20 rock. Not a circle: the silhouette is deliberately lopsided.
ASTEROID = [
    "........HHHHH.........",
    "......HHHHHHHHM.......",
    ".....HHHHHHHHHMMM.....",
    "...HHHCCHHHHHHMMMMS...",
    "..HHHCCCHHHHHMMMMMSS..",
    ".HHHHCCHHHHMMMMMSSSS..",
    ".HHHHHHHHMMMMMMMSSSS..",
    "HHHHHHHHMMMMMMCCSSSSS.",
    "HHHHHHHMMMMMMCCCSSSSS.",
    "HHHHHHMMMMMMMCCCSSSSS.",
    "HHHHHMMMMMMMMCCSSSSSSS",
    ".HHHHMMMMMMSSSSSSSSSS.",
    ".HHHMMMMMMSSSSSSSSSS..",
    "..HHMMMCCMSSSSSSSSS...",
    "..HMMMMCCSSSSSSSSS....",
    "...MMMMMMSSSSSSSS.....",
    "....MMMMMSSSSSSS......",
    ".....MMMMSSSSSS.......",
    "......MMSSSSS.........",
    ".......SSSSS..........",
]

def _draw_rock(c, rows, x, y, flat=""):
    # flat: draw the whole thing in one color (used for the error screens).
    for ry in range(len(rows)):
        row = rows[ry]
        for rx in range(len(row)):
            ch = row[rx]
            if ch == ".":
                continue
            if flat:
                c.pixel(x + rx, y + ry, flat)
            else:
                c.pixel(x + rx, y + ry, TONES[ch])

def _msg(c, title, sub, col):
    c.fill("black")
    _draw_rock(c, ASTEROID, 2, 6, flat=DIM)
    c.text(title, 30, 6, font="6x8", color=col)
    c.text(sub, 30, 18, font="5x7", color=MUTED)

# ---------- number formatting ----------

def _one_dec(v):
    whole = int(v)
    tenth = int((v - float(whole)) * 10.0 + 0.5)
    if tenth > 9:
        whole = whole + 1
        tenth = 0
    return str(whole) + "." + str(tenth)

def _ld_num(v):
    # Lunar distances. 1 LD = the Earth-Moon gap (~239,000 mi). Under 1 means
    # it passed inside the Moon's orbit.
    if v < 100.0:
        return _one_dec(v)
    return str(int(v + 0.5))

def _big(v):
    # 7204056 -> "7.2M", 812345 -> "812K"
    if v >= 1000000.0:
        return _one_dec(v / 1000000.0) + "M"
    if v >= 1000.0:
        return str(int(v / 1000.0 + 0.5)) + "K"
    return str(int(v + 0.5))

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

def clip_text(c, text, font, maxw):
    # Last resort once the smallest font still overruns: chop characters off
    # the end until it fits. Keeps a long name inside its column.
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text)):
        cut = text[:len(text) - 1 - i]
        if c.text_width(cut, font) <= maxw:
            return cut
    return ""

# ---------- page ----------

def neo(c, ctx):
    key = ctx.inputs.get("apikey", "").strip() or "DEMO_KEY"

    # http.get returns a DICT: {"status_code": ..., "body": ..., "json": ...}
    r = http.get(
        "https://api.nasa.gov/neo/rest/v1/feed",
        params = {"detailed": "false", "api_key": key},
        ttl_seconds = 3600,
    )

    # ALWAYS check status_code before touching the json
    status = r["status_code"]

    if status == 403:
        _msg(c, "BAD API KEY", "CHECK YOUR SETTINGS", CLOSE)
        return
    if status == 429:
        _msg(c, "RATE LIMITED", "TRY AGAIN LATER", CLOSE)
        return
    if status != 200:
        _msg(c, "NASA ERROR", "CODE " + str(status), CLOSE)
        return

    days = r["json"].get("near_earth_objects", {})
    if not days:
        _msg(c, "NO DATA", "NOTHING RETURNED", MUTED)
        return

    # The feed gives 7 days keyed by date. Sorted, the first one is today.
    today = sorted(days.keys())[0]
    rocks = days[today]

    if not rocks:
        _msg(c, "ALL CLEAR", "NO APPROACHES TODAY", SAFE)
        return

    # Find the one that gets closest. NASA doesn't sort them for us.
    best = rocks[0]
    best_ld = float(best["close_approach_data"][0]["miss_distance"]["lunar"])

    for rock in rocks:
        ld = float(rock["close_approach_data"][0]["miss_distance"]["lunar"])
        if ld < best_ld:
            best = rock
            best_ld = ld

    approach = best["close_approach_data"][0]
    hazard = best["is_potentially_hazardous_asteroid"]

    miles = float(approach["miss_distance"]["miles"])
    mph = float(approach["relative_velocity"]["miles_per_hour"])
    feet = float(best["estimated_diameter"]["feet"]["estimated_diameter_max"])

    name = best["name"].replace("(", "").replace(")", "").upper()

    if hazard:
        col = HAZARD
    elif best_ld < 10.0:
        col = CLOSE
    else:
        col = SAFE

    c.fill("black")

    # ----- the rock -----
    _draw_rock(c, ASTEROID, 2, 6)

    # A red frame when NASA has actually flagged it.
    if hazard:
        c.rect(0, 0, c.width - 1, 0, fill=HAZARD)
        c.rect(0, c.height - 1, c.width - 1, c.height - 1, fill=HAZARD)

    c.rect(26, 3, 26, 28, fill=DIM)          # divider

    # ----- headline: how close, in lunar distances -----
    if hazard:
        c.text("HAZARDOUS", 30, 1, font="4x5", color=HAZARD)
    else:
        c.text("CLOSEST TODAY", 30, 1, font="4x5", color=MUTED)

    # Number goes big; the unit is spelled out beside it so nobody has to
    # guess what "LD" means.
    dist = _ld_num(best_ld)
    dfont = fit_font(c, dist, ["10x16", "7x12", "6x8"], 50)
    c.text(dist, 30, 8, font=dfont, color=col)

    ux = 30 + c.text_width(dist, dfont) + 3
    c.text("LUNAR", ux, 10, font="4x5", color=col)
    c.text("DIST", ux, 17, font="4x5", color=col)

    # Name column stops short of the divider at 110.
    nfont = fit_font(c, name, ["5x7", "4x5"], 77)
    c.text(clip_text(c, name, nfont, 77), 30, 25, font=nfont, color=MUTED)

    # ----- right column: the details -----
    # Divider, labels and stats all sit 10px further left than they used to,
    # and each stat starts in a fixed column right beside its label instead
    # of being flung out to the right edge.
    c.rect(110, 3, 110, 28, fill=DIM)        # divider

    rows = [
        ["DIST", _big(miles) + " MI"],
        ["SIZE", str(int(feet + 0.5)) + " FT"],
        ["SPD", _big(mph) + " MPH"],
    ]

    y = 5
    for row in rows:
        c.text(row[0], 116, y, font="4x5", color=DIM)
        # 139..180 is all the stat gets; drop a rung, then clip, if a value
        # ever runs long.
        vfont = fit_font(c, row[1], ["4x5", "3x4"], 41)
        vy = y
        if vfont == "3x4":
            vy = y + 1
        c.text(clip_text(c, row[1], vfont, 41), 139, vy, font=vfont, color="white")
        y = y + 9