# New Year's Eve -- midnight around the world, on a 192x32 SCROLL panel.
#
# DESIGN. On December 31 midnight sweeps the planet through 38 time zones in
# 26 hours: Kiritimati first, Auckland the first big city, Sydney's harbour,
# Tokyo's temple bells, Dubai, Paris, London, Rio's Copacabana (the world's
# biggest party), the Times Square ball drop, and finally American Samoa.
#   midnight   the countdown to midnight in your time zone (days, then
#              hours and minutes), then HAPPY NEW YEAR with fireworks
#   world      the sweep: where it's already the new year, the share of
#              the world's people in it, the next city, and a dot for each
#              of the 38 time zones lighting up gold
#   party      the great celebrations, each with its landmark: the next one
#              counted down in your own time, HAPPENING NOW with fireworks;
#              the rest of the year, a different one each hour with when to
#              watch it live
#
# No data feed: every midnight is worked out from the time zones, so the
# app can refresh every minute and never goes offline. Fireworks change
# with every refresh.

LEFT = 10
RIGHT = 181

COLORS = {
    "bg": "#000000",
    "text": "#F4F7FB",
    "label": "#8A93A6",
    "dim": "#4B5563",
    "gold": "#FFC233",
    "red": "#FF4A4A",
    "green": "#34D058",
    "dot_off": "#2A3142",
}

# Your time zone (December offsets, minutes from UTC) and its short name.
ZONES = {
    "EASTERN": [-300, "ET"],
    "CENTRAL": [-360, "CT"],
    "MOUNTAIN": [-420, "MT"],
    "PACIFIC": [-480, "PT"],
    "ALASKA": [-540, "AKT"],
    "HAWAII": [-600, "HT"],
    "ATLANTIC": [-240, "AT"],
    "NEWFOUNDLAND": [-210, "NT"],
    "UK AND IRELAND": [0, "GMT"],
}

# The world's 38 New Year's Eve time zones, first to last, with December
# offsets (daylight saving where it's summer), a city for each and roughly
# how many people (millions) see in the year there.
WORLD = [
    [840, "KIRITIMATI", 0.01], [780, "AUCKLAND", 5.5], [765, "CHATHAM ISLANDS", 0.001],
    [720, "FIJI", 1.4], [660, "SYDNEY", 18.5], [630, "ADELAIDE", 1.9],
    [600, "BRISBANE", 19], [570, "DARWIN", 0.25], [540, "TOKYO", 214],
    [525, "EUCLA", 0.0001], [480, "BEIJING", 1647], [420, "BANGKOK", 438],
    [390, "YANGON", 54], [360, "DHAKA", 182], [345, "KATHMANDU", 30],
    [330, "NEW DELHI", 1452], [300, "KARACHI", 325], [270, "KABUL", 42],
    [240, "DUBAI", 38], [210, "TEHRAN", 89], [180, "MOSCOW", 715],
    [120, "CAIRO", 535], [60, "PARIS", 960], [0, "LONDON", 260],
    [-60, "CAPE VERDE", 0.85], [-120, "NUUK", 0.06], [-180, "RIO DE JANEIRO", 277],
    [-210, "ST. JOHN'S", 0.5], [-240, "HALIFAX", 77], [-300, "NEW YORK", 316],
    [-360, "CHICAGO", 295], [-420, "DENVER", 38], [-480, "LOS ANGELES", 61],
    [-540, "ANCHORAGE", 0.7], [-570, "MARQUESAS", 0.01], [-600, "HONOLULU", 1.7],
    [-660, "AMERICAN SAMOA", 0.05], [-720, "BAKER ISLAND", 0],
]

# The great celebrations, in the order midnight reaches them.
PARTIES = [
    ["AUCKLAND", 780, "sky", "FIRST BIG CITY TO CELEBRATE"],
    ["SYDNEY", 660, "opera", "HARBOUR BRIDGE FIREWORKS"],
    ["TOKYO", 540, "tokyo", "TEMPLE BELLS RING 108 TIMES"],
    ["DUBAI", 240, "burj", "BURJ KHALIFA LIGHT SHOW"],
    ["PARIS", 60, "eiffel", "THE EIFFEL TOWER SPARKLES"],
    ["LONDON", 0, "bigben", "BIG BEN STRIKES MIDNIGHT"],
    ["RIO DE JANEIRO", -180, "rio", "THE WORLD'S BIGGEST PARTY"],
    ["NEW YORK", -300, "ball", "THE TIMES SQUARE BALL DROP"],
    ["SEATTLE", -480, "needle", "SPACE NEEDLE FIREWORKS"],
]

SKY_STARS = [[2, 3], [9, 1], [15, 6], [4, 10], [12, 12], [18, 2], [7, 7]]

MONTHS = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]



# ---- art ----------------------------------------------------------------------

# Auckland: the Sky Tower
SKY = """
....w....
....w....
....w....
....s....
...sSs...
..sLLLs..
..SSSSS..
..sLLLs..
...sSs...
....S....
....S....
....S....
....S....
....S....
....S....
...sSs...
...sSs...
..ssSss..
.sssSsss.
"""
SKY_LEGEND = {"w": "#FF3B30", "s": "#8A93A6", "S": "#DCE3EC", "L": "#FFD54A"}

# Sydney: the Opera House on the harbour
OPERA = """
.......W.............
......WW......W......
.....WWw.....WW......
....WWWw....WWw...W..
...WWWWw...WWWw..WW..
..WWWWWw..WWWWw.WWw..
.WWWWWWwwWWWWWwWWWw..
bbbbbbbbbbbbbbbbbbbbb
.~~.~~~.~~.~~~.~~.~~.
"""
OPERA_LEGEND = {"W": "#F4F7FB", "w": "#B9C4D2", "b": "#C9A27A", "~": "#2F6FD8"}

# Tokyo: Tokyo Tower
TOKYO = """
.....w.....
.....w.....
.....R.....
.....R.....
....WRW....
....RRR....
....R.R....
....WWW....
...RR.RR...
...R...R...
...WWWWW...
..RR...RR..
..R.....R..
.RR.....RR.
.R..WWW..R.
RR.......RR
"""
TOKYO_LEGEND = {"w": "#FFD54A", "R": "#FF4A2A", "W": "#F4F7FB"}

# Dubai: the Burj Khalifa
BURJ = """
....w....
....s....
....S....
....S....
...sS....
...sSl...
...sSS...
...sSSl..
..lsSSS..
..sSSSS..
..sSlSSl.
..sSSSSS.
.lsSSSlSS
.sSSSSSSS
.sSSlSSSS
.sSSSSSSS
.sSSSSSlS
sSSSSSSSS
"""
BURJ_LEGEND = {"w": "#FFFFFF", "s": "#6E86A6", "S": "#B9CBE2", "l": "#5AB4FF"}

# Paris: the Eiffel Tower
EIFFEL = """
.....Y.....
.....B.....
.....B.....
....BBB....
....B.B....
....BBB....
....B.B....
...BB.BB...
...BBBBB...
...B...B...
..BB...BB..
..BBBBBBB..
.BB.....BB.
.B..BBB..B.
BB.B...B.BB
B..B...B..B
"""
EIFFEL_LEGEND = {"Y": "#FFFFFF", "B": "#C9A04E"}

# London: Big Ben
BIGBEN = """
....Y....
....s....
...sSs...
...SSS...
..sSSSs..
..SSSSS..
..SCCCS..
..CcKcC..
..CKKcC..
..SCCCS..
..SSSSS..
..SsSsS..
..SSSSS..
..SsSsS..
..SSSSS..
..SsSsS..
..SSSSS..
.sSSSSSs.
"""
BIGBEN_LEGEND = {"Y": "#FFD54A", "s": "#A07A3E", "S": "#D9B36A", "C": "#FFF3C4", "c": "#FFE08A", "K": "#3A2A12"}

# Rio: Christ the Redeemer on Corcovado
RIO = """
.......w.......
......www......
.wwwwwwwwwwwww.
.......w.......
.......w.......
......www......
......www......
......www......
......sss......
.....gsssg.....
....gggggggg...
...gggggggggg..
..ggggggggggggg
.gggggggggggggg
"""
RIO_LEGEND = {"w": "#F4F7FB", "s": "#B9C4D2", "g": "#2E7D46"}

# New York: the Times Square ball on its pole
BALL = """
.....y.....
.....P.....
...rbYgr...
..bYwYbYg..
.rYgYwYrYb.
.YbYrYgYwY.
.gYwYbYrYg.
.bYrYgYbYr.
..rYbYwYg..
...gYrYb...
.....P.....
.....P.....
.....P.....
....PPP....
..TTTTTTT..
..TtTtTtT..
..TTTTTTT..
..TtTtTtT..
"""
BALL_LEGEND = {"y": "#FFFFFF", "P": "#8A93A6", "Y": "#FFF3C4", "w": "#FFFFFF", "r": "#FF3B30", "b": "#3B82F6", "g": "#34D058", "T": "#4B5563", "t": "#FFD54A"}

# Seattle: the Space Needle
NEEDLE = """
......w......
......s......
......s......
.....sSs.....
..SSSSSSSSS..
.sLLLLLLLLLs.
..SSSSSSSSS..
....sSSSs....
.....s.s.....
.....s.s.....
.....s.s.....
.....s.s.....
....s...s....
....s...s....
...s.....s...
..ss.....ss..
"""
NEEDLE_LEGEND = {"w": "#FF3B30", "s": "#C9D3DF", "S": "#F4F7FB", "L": "#FFD54A"}

LANDMARKS = {
    "sky": [SKY, SKY_LEGEND],
    "opera": [OPERA, OPERA_LEGEND],
    "tokyo": [TOKYO, TOKYO_LEGEND],
    "burj": [BURJ, BURJ_LEGEND],
    "eiffel": [EIFFEL, EIFFEL_LEGEND],
    "bigben": [BIGBEN, BIGBEN_LEGEND],
    "rio": [RIO, RIO_LEGEND],
    "ball": [BALL, BALL_LEGEND],
    "needle": [NEEDLE, NEEDLE_LEGEND],
}

# Firework bursts by radius: [dx, dy, shade] with shade indexing a colour's
# [core, faint, mid, body, tip, glint, tail].
BURSTS = {
    5: [[-5, -1, 5], [-5, 2, 4], [-5, 4, 6], [-4, -3, 4], [-4, -1, 3], [-4, 1, 3], [-3, -3, 3], [-3, -1, 2], [-3, 1, 2], [-3, 3, 3], [-3, 4, 4], [-3, 6, 6], [-2, -5, 4], [-2, -2, 2], [-2, 0, 1], [-2, 1, 1], [-2, 2, 2], [-1, -4, 3], [-1, -3, 2], [-1, -2, 1], [-1, -1, 1], [-1, 1, 1], [-1, 3, 2], [-1, 4, 3], [-1, 5, 5], [-1, 7, 6], [0, -2, 1], [0, 0, 0], [0, 2, 1], [1, -5, 5], [1, -4, 3], [1, -3, 2], [1, -1, 1], [1, 1, 1], [1, 2, 1], [1, 3, 2], [1, 4, 3], [2, -2, 2], [2, -1, 1], [2, 0, 1], [2, 2, 2], [2, 5, 4], [2, 7, 6], [3, -4, 4], [3, -3, 3], [3, -1, 2], [3, 1, 2], [3, 3, 3], [4, -1, 3], [4, 1, 3], [4, 3, 4], [4, 5, 6], [5, -2, 4], [5, 1, 5]],
    6: [[-6, -1, 4], [-6, 1, 5], [-6, 3, 6], [-5, -4, 4], [-5, -1, 3], [-5, 1, 3], [-5, 4, 4], [-5, 6, 6], [-4, -3, 3], [-4, -1, 2], [-4, 1, 2], [-4, 3, 3], [-3, -5, 5], [-3, -2, 2], [-3, -1, 1], [-3, 1, 1], [-3, 3, 2], [-2, -4, 3], [-2, -2, 1], [-2, 2, 1], [-2, 4, 2], [-2, 5, 4], [-2, 7, 6], [-1, -3, 1], [-1, 3, 1], [0, -6, 4], [0, -5, 3], [0, -4, 2], [0, -3, 1], [0, 0, 0], [0, 3, 1], [0, 4, 2], [0, 5, 3], [0, 6, 5], [0, 8, 6], [1, -3, 1], [1, 3, 1], [2, -5, 4], [2, -4, 2], [2, -2, 1], [2, 2, 1], [2, 4, 3], [3, -3, 2], [3, -1, 1], [3, 1, 1], [3, 2, 2], [3, 5, 4], [3, 7, 6], [4, -3, 3], [4, -1, 2], [4, 1, 2], [4, 3, 3], [5, -4, 5], [5, -1, 3], [5, 1, 3], [5, 4, 4], [5, 6, 6], [6, -1, 4], [6, 1, 5]],
    7: [[-7, -1, 4], [-7, 1, 4], [-6, -4, 5], [-6, -1, 3], [-6, 1, 3], [-6, 4, 5], [-6, 6, 6], [-5, -3, 3], [-5, -1, 2], [-5, 1, 2], [-5, 3, 3], [-4, -6, 4], [-4, -3, 2], [-4, -1, 1], [-4, 1, 1], [-4, 3, 2], [-4, 6, 4], [-4, 8, 6], [-3, -5, 3], [-3, -4, 2], [-3, -2, 1], [-3, 2, 1], [-3, 4, 2], [-3, 5, 3], [-2, -3, 1], [-2, 3, 1], [-1, -7, 4], [-1, -6, 3], [-1, -5, 2], [-1, -4, 1], [-1, 4, 1], [-1, 5, 2], [-1, 6, 3], [-1, 7, 4], [-1, 9, 6], [0, 0, 0], [1, -7, 5], [1, -6, 3], [1, -5, 2], [1, -4, 1], [1, 4, 1], [1, 5, 2], [1, 6, 3], [1, 7, 5], [1, 9, 6], [2, -3, 1], [2, 3, 1], [3, -5, 3], [3, -4, 2], [3, -2, 1], [3, 2, 1], [3, 4, 2], [3, 5, 3], [4, -6, 4], [4, -3, 2], [4, -1, 1], [4, 1, 1], [4, 3, 2], [4, 6, 4], [4, 8, 6], [5, -3, 3], [5, -1, 2], [5, 1, 2], [5, 3, 3], [6, -4, 4], [6, -1, 3], [6, 1, 3], [6, 4, 4], [6, 6, 6], [7, -1, 5], [7, 1, 5]],
    8: [[-8, -2, 5], [-8, 1, 4], [-7, -4, 4], [-7, -1, 3], [-7, 1, 3], [-7, 4, 4], [-7, 6, 6], [-6, -4, 3], [-6, -1, 2], [-6, 1, 2], [-6, 3, 3], [-5, -6, 4], [-5, -3, 2], [-5, -1, 1], [-5, 1, 1], [-5, 3, 2], [-5, 5, 3], [-5, 6, 5], [-5, 8, 6], [-4, -5, 3], [-4, -3, 1], [-4, 2, 1], [-4, 4, 2], [-3, -8, 5], [-3, -4, 1], [-3, 4, 1], [-3, 7, 4], [-3, 9, 6], [-2, -7, 3], [-2, -6, 2], [-2, -5, 1], [-2, 5, 1], [-2, 6, 2], [0, -8, 4], [0, -7, 3], [0, -6, 2], [0, -5, 1], [0, 0, 0], [0, 5, 1], [0, 6, 2], [0, 7, 3], [0, 8, 4], [0, 10, 6], [2, -6, 2], [2, -5, 1], [2, 5, 1], [2, 6, 2], [2, 7, 3], [3, -7, 4], [3, -4, 1], [3, 4, 1], [3, 8, 5], [3, 10, 6], [4, -4, 2], [4, -2, 1], [4, 3, 1], [4, 5, 3], [5, -6, 5], [5, -5, 3], [5, -3, 2], [5, -1, 1], [5, 1, 1], [5, 3, 2], [5, 6, 4], [5, 8, 6], [6, -3, 3], [6, -1, 2], [6, 1, 2], [6, 4, 3], [7, -4, 4], [7, -1, 3], [7, 1, 3], [7, 4, 4], [7, 6, 6], [8, -1, 4], [8, 2, 5]],
}
# Each colour: [core, faint, mid, body, tip, glint, tail]
FIREWORK_COLORS = [
    ["#992F61", "#591B39", "#992F61", "#D8438A", "#FF4FA3", "#FFFFFF", "#661F41"],
    ["#997F2C", "#594A19", "#997F2C", "#D8B53E", "#FFD54A", "#FFFFFF", "#66551D"],
    ["#366C99", "#1F3E59", "#366C99", "#4C99D8", "#5AB4FF", "#FFFFFF", "#244866"],
    ["#1F7C34", "#12481E", "#1F7C34", "#2CB04A", "#34D058", "#FFFFFF", "#145323"],
    ["#774B99", "#452B59", "#774B99", "#A96AD8", "#C77DFF", "#FFFFFF", "#4F3266"],
    ["#993F24", "#592515", "#993F24", "#D85A33", "#FF6A3D", "#FFFFFF", "#662A18"],
]


# ---- time ------------------------------------------------------------------------

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil_from_days(z):
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return [y, m, d]


def jan1(year):
    return days_from_civil(year, 1, 1) * 86400


def strike(year, offset_min):
    # When the clocks strike 12 for `year` in a zone (unix seconds).
    return jan1(year) - offset_min * 60


def world_year(now):
    # The New Year the world is heading into (or in the middle of): it
    # stays the same until midnight has reached the very last time zone.
    return civil_from_days((now - 12 * 3600) // 86400)[0] + 1


def pad2(n):
    return ("0" if n < 10 else "") + str(n)


def countdown(secs):
    secs = max(0, secs)
    mins = (secs + 59) // 60
    if mins < 60:
        return str(mins) + " MIN"
    return str(mins // 60) + "H " + pad2(mins % 60) + "M"


def clock(unix, offset_min, abbr):
    # "DEC 31 6:00 AM ET"
    t = unix + offset_min * 60
    ymd = civil_from_days(t // 86400)
    s = t % 86400
    h = s // 3600
    m = (s % 3600) // 60
    h12 = h % 12
    return MONTHS[ymd[1]] + " " + str(ymd[2]) + " " + str(12 if h12 == 0 else h12) + ":" + pad2(m) + (" AM " if h < 12 else " PM ") + abbr


def zone_input(ctx):
    z = str(ctx.inputs.get("zone", "EASTERN")).upper()
    return z if z in ZONES else "EASTERN"


# ---- drawing helpers -------------------------------------------------------------------

def clip_words(c, text, font, max_w):
    words = [w for w in str(text).split(" ") if w != ""]
    for n in range(len(words), 0, -1):
        trial = " ".join(words[:n])
        if c.text_width(trial, font) <= max_w:
            return trial
    return words[0] if len(words) > 0 else ""


def text_fit(c, text, x, y, max_w, fonts, color):
    # The biggest font in the list that fits; 6x8 has no apostrophe.
    for f in fonts:
        if f == "6x8" and "'" in text:
            continue
        if c.text_width(text, f) <= max_w:
            c.text(text, x, y, font = f, color = color)
            return f
    f = fonts[len(fonts) - 1]
    c.text(clip_words(c, text, f, max_w), x, y, font = f, color = color)
    return f


def firework(c, cx, cy, r, palette):
    for p in BURSTS[r]:
        c.pixel(cx + p[0], cy + p[1], palette[p[2]])


def fireworks(c, spots, seed):
    # A different show each refresh: colours rotate with the minute.
    for i in range(len(spots)):
        s = spots[i]
        firework(c, s[0], s[1], s[2], FIREWORK_COLORS[(seed + i * 2) % len(FIREWORK_COLORS)])


def sparkle(c, x, y, w, h, seed):
    # A few glints around a word.
    pts = [[-2, 1], [w + 1, 2], [w // 2, -2], [-1, h - 2], [w + 2, h - 3], [w // 3, h + 1]]
    for i in range(len(pts)):
        if (i + seed) % 2 == 0:
            c.pixel(x + pts[i][0], y + pts[i][1], "#FFFFFF")
        else:
            c.pixel(x + pts[i][0], y + pts[i][1], "#FFE08A")


# ---- page 1: your midnight -----------------------------------------------------------------

def midnight(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    zone = zone_input(ctx)
    off = ZONES[zone][0]
    seed = now // 60
    x = LEFT + 50
    room = RIGHT - x

    local = now + off * 60
    ymd = civil_from_days(local // 86400)

    if ymd[1] == 1 and ymd[2] == 1:
        # It's New Year's Day where you are.
        fireworks(c, [[LEFT + 9, 9, 8], [LEFT + 29, 18, 7], [LEFT + 40, 7, 5]], seed)
        year = str(ymd[0])
        c.text(year, x, 8, font = "10x16", color = COLORS["gold"])
        yw = c.text_width(year, "10x16")
        sparkle(c, x, 8, yw, 16, seed)
        tx = x + yw + 8
        c.text("HAPPY", tx, 8, font = "6x8", color = COLORS["text"])
        c.text("NEW YEAR!", tx, 17, font = "6x8", color = COLORS["text"])
        c.text(clip_words(c, "CHEERS TO A GREAT YEAR", "4x5", room), x, 1, font = "4x5", color = COLORS["red"])
        return

    year = ymd[0] + 1
    left = strike(year, off) - now
    fireworks(c, [[LEFT + 10, 10, 7], [LEFT + 30, 20, 7], [LEFT + 41, 7, 5]], seed)
    if left > 86400:
        days = (left + 86399) // 86400
        c.text("COUNTDOWN TO " + str(year), x, 1, font = "4x5", color = COLORS["gold"])
        n = str(days)
        c.text(n, x, 8, font = "10x16", color = COLORS["text"])
        c.text("DAY" if days == 1 else "DAYS", x + c.text_width(n, "10x16") + 4, 16, font = "6x8", color = COLORS["text"])
        c.text(clip_words(c, "UNTIL MIDNIGHT, DEC 31", "4x5", room), x, 26, font = "4x5", color = COLORS["label"])
        return

    c.text(clip_words(c, "MIDNIGHT " + ZONES[zone][1] + " IN", "4x5", room), x, 1, font = "4x5", color = COLORS["gold"])
    if left < 60:
        c.text("ANY SECOND", x, 9, font = "6x8", color = COLORS["text"])
        c.text("10... 9... 8...", x, 19, font = "5x7", color = COLORS["red"])
        return
    c.text(countdown(left), x, 8, font = "10x16", color = COLORS["text"])
    tag = str(year) + " IS ALMOST HERE!" if left > 600 else "GET READY TO COUNT DOWN!"
    c.text(clip_words(c, tag, "4x5", room), x, 26, font = "4x5", color = COLORS["green"])


# ---- page 2: around the world ---------------------------------------------------------------

def zone_dots(c, year, now):
    # One dot per time zone, first (left) to last (right): gold once it's
    # midnight there, the newest one white.
    gap = 4
    x0 = (LEFT + RIGHT - (len(WORLD) - 1) * gap) // 2
    newest = -1
    for i in range(len(WORLD)):
        if strike(year, WORLD[i][0]) <= now:
            newest = i
    for i in range(len(WORLD)):
        x = x0 + i * gap
        col = COLORS["dot_off"]
        if i <= newest:
            col = "#FFFFFF" if i == newest else COLORS["gold"]
        c.rect(x, 29, x + 1, 30, fill = col)


def world(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    year = world_year(now)
    first = strike(year, WORLD[0][0])
    prev_last = strike(year - 1, WORLD[len(WORLD) - 1][0])
    c.text("AROUND THE WORLD", LEFT, 1, font = "4x5", color = COLORS["gold"])

    if now - prev_last < 12 * 3600:
        # Midnight has reached every time zone.
        zone_dots(c, year - 1, now)
        c.text("38 OF 38", RIGHT, 1, font = "4x5", color = COLORS["label"], align = "right")
        text_fit(c, "THE WHOLE WORLD", LEFT, 8, RIGHT - LEFT, ["6x8", "5x7"], COLORS["text"])
        text_fit(c, "IS IN " + str(year - 1) + "!", LEFT, 17, RIGHT - LEFT, ["6x8", "5x7"], COLORS["gold"])
        return

    if now < first:
        # Before the first midnight: who's first and last.
        zone_dots(c, year, now)
        c.text("38 MIDNIGHTS", RIGHT, 1, font = "4x5", color = COLORS["label"], align = "right")
        mid = (LEFT + RIGHT) // 2
        c.text("FIRST TO " + str(year), LEFT, 7, font = "4x5", color = COLORS["label"])
        text_fit(c, "KIRITIMATI", LEFT, 13, mid - LEFT - 4, ["6x8", "5x7"], COLORS["text"])
        c.text("LAST", mid + 4, 7, font = "4x5", color = COLORS["label"])
        text_fit(c, "AMERICAN SAMOA", mid + 4, 13, RIGHT - mid - 4, ["6x8", "5x7"], COLORS["text"])
        if first - now < 86400:
            c.text("FIRST MIDNIGHT IN " + countdown(first - now), LEFT, 22, font = "4x5", color = COLORS["green"])
        return

    # The sweep is on.
    zone_dots(c, year, now)
    done = 0
    total = 0
    newest = WORLD[0]
    nxt = None
    for z in WORLD:
        total += z[2]
        if strike(year, z[0]) <= now:
            done += z[2]
            newest = z
        elif nxt == None:
            nxt = z
    pct = int(done * 100 // total)
    if nxt != None:
        # The next city, as much of it as fits beside the title.
        cd = countdown(strike(year, nxt[0]) - now)
        room = RIGHT - (LEFT + c.text_width("AROUND THE WORLD", "4x5") + 6)
        for line in ["NEXT " + nxt[1] + " " + cd, nxt[1] + " " + cd, "NEXT " + cd]:
            if c.text_width(line, "4x5") <= room:
                c.text(line, RIGHT, 1, font = "4x5", color = COLORS["label"], align = "right")
                break

    # Right: how much of the world is already in the new year.
    p = str(pct) + "%" if pct > 0 else "<1%"
    c.text(p, RIGHT, 6, font = "10x16", color = COLORS["gold"], align = "right")
    pw = c.text_width(p, "10x16")
    c.text("OF EVERYONE", RIGHT, 23, font = "4x5", color = COLORS["label"], align = "right")
    room = RIGHT - max(pw, c.text_width("OF EVERYONE", "4x5")) - 6 - LEFT
    c.text("IT'S " + str(year) + " IN", LEFT, 9, font = "4x5", color = COLORS["label"])
    text_fit(c, newest[1], LEFT, 16, room, ["6x8", "5x7", "4x5"], COLORS["text"])


# ---- page 3: the great celebrations -----------------------------------------------------------

def party(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    zone = zone_input(ctx)
    off = ZONES[zone][0]
    abbr = ZONES[zone][1]
    year = world_year(now)
    first = strike(year, PARTIES[0][1])
    end = strike(year, PARTIES[len(PARTIES) - 1][1]) + 900
    live = now >= first - 86400 and now < end

    if live:
        # The next celebration (or the one happening right now).
        pick = PARTIES[len(PARTIES) - 1]
        for p in PARTIES:
            if now < strike(year, p[1]) + 900:
                pick = p
                break
    else:
        # The rest of the year: a different celebration each hour.
        pick = PARTIES[(now // 3600) % len(PARTIES)]
        if now >= end:
            year = year + 1
    t = strike(year, pick[1])
    happening = live and now >= t

    art = LANDMARKS[pick[2]]
    rows = art[0].strip("\n").split("\n")
    w = len(rows[0])
    h = len(rows)
    if happening:
        # Kept inside the safe zone, even over a narrow landmark.
        fireworks(c, [[max(LEFT + 6, LEFT + w // 2 - 2), 8, 6], [max(LEFT + 14, LEFT + w // 2 + 8), 14, 5]], now // 60)
    else:
        # A night sky over the landmark until its midnight comes.
        for i in range(len(SKY_STARS)):
            s = SKY_STARS[i]
            if s[1] < 32 - h - 2:
                c.pixel(LEFT + s[0], s[1], "#FFFFFF" if (i + now // 60) % 3 == 0 else "#5A6B8C")
    c.sprite(art[0], LEFT, 32 - h, legend = art[1])
    x = LEFT + max(w, 20) + 6
    room = RIGHT - x

    if happening:
        c.text("HAPPENING NOW!", x, 1, font = "4x5", color = COLORS["red"])
    elif live:
        c.text("NEXT BIG PARTY", x, 1, font = "4x5", color = COLORS["gold"])
    else:
        c.text("GREAT CELEBRATIONS", x, 1, font = "4x5", color = COLORS["gold"])
    text_fit(c, pick[0], x, 8, room, ["6x8", "5x7"], COLORS["text"])
    c.text(clip_words(c, pick[3], "4x5", room), x, 17, font = "4x5", color = COLORS["green"])

    when = clock(t, off, abbr)
    if happening:
        c.text(clip_words(c, "HAPPY " + str(year) + "!", "4x5", room), x, 25, font = "4x5", color = COLORS["gold"])
    elif live:
        cd = "IN " + countdown(t - now)
        c.text(cd, x, 25, font = "4x5", color = COLORS["gold"])
        rest = clip_words(c, when, "4x5", room - c.text_width(cd, "4x5") - 6)
        c.text(rest, RIGHT, 25, font = "4x5", color = COLORS["label"], align = "right")
    else:
        c.text("WATCH", x, 25, font = "4x5", color = COLORS["dim"])
        c.text(clip_words(c, when, "4x5", room - 28), x + 28, 25, font = "4x5", color = COLORS["label"])
