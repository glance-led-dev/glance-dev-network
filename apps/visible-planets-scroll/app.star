# Visible Planets
#
# Positions come from mean orbital elements: each planet's heliocentric
# longitude is stepped from a J2000 epoch, then differenced against
# Earth's to get elongation from the Sun. That is accurate to a few
# degrees, which is far better than this panel can draw, and it needs
# no network at all.
#
# Elongation is what decides visibility: a planet within about 15
# degrees of the Sun is lost in the glare whatever else is true.



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


# name, orbital period (days), longitude at J2000 (degrees)
BODIES = [
    ["MERCURY", 87.969, 252.25],
    ["VENUS", 224.701, 181.98],
    ["EARTH", 365.256, 100.46],
    ["MARS", 686.980, 355.43],
    ["JUPITER", 4332.589, 34.35],
    ["SATURN", 10759.22, 50.08],
]


def longitudes(unix):
    """Heliocentric longitude of each body, degrees."""
    days = unix / 86400.0 - 10957.5          # days since J2000
    out = {}
    for b in BODIES:
        out[b[0]] = (b[2] + 360.0 * days / b[1]) % 360.0
    return out


def elongation(lon, earth):
    """Angle between a planet and the Sun as seen from Earth, 0-180."""
    d = (lon - earth) % 360.0
    if d > 180.0:
        d = 360.0 - d
    return d


def verdict(name, e):
    """Kept to six characters: each planet gets width/5 of the panel, which is
    38px on the Scroll, and anything longer collided with its neighbour."""
    if e < 15.0:
        return ["GLARE", "#4A4E60"]
    if name == "MERCURY" or name == "VENUS":
        return ["DUSK", "#FFD86A"]
    if e > 150.0:
        return ["ALL NT", "#8FE38A"]
    if e > 60.0:
        return ["EVE", "#FFD86A"]
    return ["LOW", "#B0784A"]


def draw_planet(c, name, x, y, n):
    if name == "MERCURY":
        c.image("MERCURY.png", x, y, w = n, h = n)
    elif name == "VENUS":
        c.image("VENUS.png", x, y, w = n, h = n)
    elif name == "MARS":
        c.image("MARS.png", x, y, w = n, h = n)
    elif name == "JUPITER":
        c.image("JUPITER.png", x, y, w = n, h = n)
    else:
        c.image("SATURN.png", x, y, w = n, h = n)


def tonight(c, ctx):
    lons = longitudes(ctx.now.unix)
    earth = lons["EARTH"]

    order = ["MERCURY", "VENUS", "MARS", "JUPITER", "SATURN"]
    vis = []
    for nm in order:
        e = elongation(lons[nm], earth)
        if e >= 15.0:
            vis.append([nm, e])

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#050818", "#141C38",
                    horizontal = False)
    for s in [[7, 4], [23, 9], [41, 3], [58, 14], [95, 5], [131, 11],
              [150, 3], [176, 8]]:
        if s[0] < c.width:
            c.pixel(s[0], s[1], "#3A4470")

    if len(vis) == 0:
        c.text("NO PLANETS", c.width // 2, c.height // 2 - 6,
               font = "6x8" if c.width >= 128 else "4x5", color = "#8892B8",
               align = "center")
        c.text("ALL NEAR THE SUN", c.width // 2, c.height // 2 + 4,
               font = "4x5", color = "#4A5478", align = "center")
        return

    # As big as the column allows: 18 on the Scroll leaves the two text rows
    # under it, 20 on the 64 fills the third of the panel each planet gets.
    n = 18 if c.width >= 128 else 20
    show = len(vis)
    cap = 5 if c.width >= 128 else 3
    if show > cap:
        show = cap
    col = c.width // show

    for i in range(show):
        nm = vis[i][0]
        v = verdict(nm, vis[i][1])
        x = i * col
        draw_planet(c, nm, x + (col - n) // 2, 1, n)
        if c.width >= 128:
            c.text_fit(nm, x + col // 2, n + 2, ["4x5", "3x4"],
                       color = "#C8D0EC", align = "center", maxw = col - 2)
            c.text_fit(v[0], x + col // 2, n + 8, ["4x5", "3x4"], color = v[1],
                       align = "center", maxw = col - 2)
        else:
            c.text(nm[:3], x + col // 2, n + 3, font = "4x5", color = "#C8D0EC",
                   align = "center")
