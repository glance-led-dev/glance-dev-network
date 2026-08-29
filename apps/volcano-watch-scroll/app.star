# Volcano Watch
#
# USGS publishes the elevated-alert list openly. Colour codes are
# the aviation ones (GREEN through RED) and alert levels the ground
# ones (NORMAL through WARNING); the panel leads with whichever
# volcano is highest on the ground scale.



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


RANK = {"NORMAL": 0, "ADVISORY": 1, "WATCH": 2, "WARNING": 3}
COLORS = {"NORMAL": "#4EE38A", "ADVISORY": "#F5D64E",
          "WATCH": "#FF9A4A", "WARNING": "#FF3B3B"}


# 1px silhouette outline of VOLCANO.png at its drawn 24x24 size, offset (-1,-1).
VOLCANO_EDGE = """
..........................
............####..........
............#..#..........
..........###..###........
.........##......##.......
.........#........#.......
.........##......##.......
..........#......#........
..........##..####........
.........##....##.........
.........#......#.........
........##......##........
.......##........##.......
......##..........##......
......#............#......
.....##............##.....
....##..............##....
...##................##...
...#..................#...
..##..................##..
.##....................##.
##......................##
#........................#
#........................#
#........................#
"""

def alerts(c, ctx):
    r = http.get("https://volcanoes.usgs.gov/hans-public/api/volcano/getElevatedVolcanoes",
                 ttl_seconds = 7200)
    if r["status_code"] != 200 or r["json"] == None:
        nodata(c, "NO USGS DATA", "NO CONNECTION")
        return

    rows = r["json"]
    if len(rows) == 0:
        c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#04120E", "#0A2A20",
                        horizontal = False)
        c.text("ALL QUIET", c.width // 2, c.height // 2 - 8,
               font = "10x16" if c.width >= 128 else "6x8", color = "#4EE38A",
               align = "center")
        c.text("NO ELEVATED VOLCANOES", c.width // 2, c.height // 2 + 9,
               font = "4x5", color = "#357A5E", align = "center")
        return

    top = rows[0]
    best = -1
    for v in rows:
        lv = str(v.get("alert_level", "NORMAL")).upper()
        if RANK.get(lv, 0) > best:
            best = RANK.get(lv, 0)
            top = v

    name = str(top.get("volcano_name", "")).upper()
    lv = str(top.get("alert_level", "NORMAL")).upper()
    col = COLORS.get(lv, "#9AA4C0")

    c.gradient_rect(0, 0, c.width - 1, c.height - 1, "#140A06", "#301608",
                    horizontal = False)
    sz = 24 if c.width >= 128 else 16
    if c.width >= 128:
        c.sprite(VOLCANO_EDGE, 6, c.height - sz - 1, color = "black")
    c.image("VOLCANO.png", 7, c.height - sz, w = sz, h = sz)

    # The observatory tells you where the volcano is.
    region = {"avo": "ALASKA", "hvo": "HAWAII", "cvo": "CASCADES",
              "calvo": "CALIFORNIA", "yvo": "YELLOWSTONE"}.get(
        str(top.get("obs_abbr", "")).lower(),
        str(top.get("obs_fullname", "")).upper().replace(" VOLCANO OBSERVATORY", ""))

    if c.width >= 128:
        # Left column stacks name / region / count, each 2px apart; the
        # alert level rides vertically centred at the right.
        nfont = "10x16"
        for f in ["10x16", "6x8", "5x7"]:
            nfont = f
            if c.text_width(name, f) <= c.width - 116:
                break
        nh = {"10x16": 16, "6x8": 8, "5x7": 7}[nfont]
        c.text_stroke(clip(c, name, nfont, c.width - 116), 36, 3, font = nfont,
                      color = "#FFE8D8")
        ry = 3 + nh + 2
        c.text_stroke(clip(c, region, "4x5", c.width - 116), 36, ry,
                      font = "4x5", color = "#C09880")
        c.text_stroke(str(len(rows)) + " ELEVATED", 36, ry + 5 + 2,
                      font = "4x5", color = "#C09880")
        c.text_stroke(lv, c.width - 10, (c.height - 16) // 2, font = "10x16",
                      color = col, align = "right")
    else:
        c.text_fit(name, c.width - 2, 1, ["6x8", "5x7", "4x5"],
                   color = "#FFE8D8", align = "right", maxw = c.width - 20)
        c.text_fit(lv, c.width - 2, 11, ["10x16", "6x8"], color = col,
                   align = "right", maxw = c.width - 20)
        c.text(str(len(rows)) + " ACTIVE", c.width - 2, 25, font = "4x5",
               color = "#C09880", align = "right")
