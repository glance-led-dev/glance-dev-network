# Ham Shack -- HF band conditions, Parks on the Air and the hottest DX, on
# a 192x32 SCROLL panel.
#
# DESIGN. What hams keep on a shack display (HamClock, OpenHamClock and
# their successors): band conditions with the solar numbers behind them,
# the DX cluster, and POTA spots. So:
#   bands   N0NBH's HF band conditions (day and night, 80m to 10m) with
#           SFI, sunspots, K and A, the noise level and any VHF opening.
#           The sun beside it carries one sunspot per 25 of the real count.
#   pota    the three newest Parks on the Air activators in your area and
#           mode: call, frequency, mode and state, and how many are on air
#   dx      the most-spotted DX station on the cluster right now (outside
#           your own continent): call, country, frequency, mode and the
#           bands it has been heard on
#
# Data, keyless:
#   hamqsl.com/solarxml.php        N0NBH solar-terrestrial data (XML)
#   api.pota.app/spot/activator    live POTA activator spots (JSON)
#   hamqth.com/dxc_csv.php         the last 200 DX cluster spots (CSV)

SOLAR_URL = "https://www.hamqsl.com/solarxml.php"
POTA_URL = "https://api.pota.app/spot/activator"
DXC_URL = "https://www.hamqth.com/dxc_csv.php?limit=200"
HEADERS = {
    "Accept": "application/json, text/xml, text/plain",
    "User-Agent": "Glance-GDN ham-shack (github.com/glance-led-dev/glance-dev-network)",
}

COLORS = {
    "bg": "#000000",
    "text": "#F4F7FB",
    "label": "#8A93A6",
    "dim": "#4B5563",
    "gold": "#FFC233",
    "good": "#34D058",
    "fair": "#FFB020",
    "poor": "#FF4D4D",
    "pota": "#34D058",
    "error": "#E8B04A",
    "error_sub": "#6A7090",
}

MODE_COLORS = {"CW": "#FFC233", "PHONE": "#5AB4FF", "DIGITAL": "#D07CFF"}

BAND_COLORS = {
    "160M": "#C2772E", "80M": "#A855F7", "60M": "#818CF8", "40M": "#3B82F6",
    "30M": "#22D3EE", "20M": "#34D058", "17M": "#A3E635", "15M": "#FACC15",
    "12M": "#FB923C", "10M": "#FF4D4D", "6M": "#F472B6", "2M": "#E5E7EB",
}
BAND_ORDER = ["160M", "80M", "60M", "40M", "30M", "20M", "17M", "15M", "12M", "10M", "6M", "2M"]

# Where you are -> which POTA spots count, and your continent (DX from your
# own continent isn't DX). US call areas group the states as the FCC does.
AREAS = {
    "WORLDWIDE": [[], ""],
    "USA": [["US"], "NA"],
    "CANADA": [["CA"], "NA"],
    "W1 NEW ENGLAND": [["US-CT", "US-ME", "US-MA", "US-NH", "US-RI", "US-VT"], "NA"],
    "W2 NY NJ": [["US-NY", "US-NJ"], "NA"],
    "W3 MID ATLANTIC": [["US-DE", "US-DC", "US-MD", "US-PA"], "NA"],
    "W4 SOUTHEAST": [["US-AL", "US-FL", "US-GA", "US-KY", "US-NC", "US-SC", "US-TN", "US-VA"], "NA"],
    "W5 SOUTH CENTRAL": [["US-AR", "US-LA", "US-MS", "US-NM", "US-OK", "US-TX"], "NA"],
    "W6 CALIFORNIA": [["US-CA"], "NA"],
    "W7 NORTHWEST": [["US-AZ", "US-ID", "US-MT", "US-NV", "US-OR", "US-UT", "US-WA", "US-WY"], "NA"],
    "W8 MI OH WV": [["US-MI", "US-OH", "US-WV"], "NA"],
    "W9 IL IN WI": [["US-IL", "US-IN", "US-WI"], "NA"],
    "W0 PLAINS": [["US-CO", "US-IA", "US-KS", "US-MN", "US-MO", "US-NE", "US-ND", "US-SD"], "NA"],
}

# POTA modes by family.
MODE_FAMILY = {
    "CW": "CW",
    "SSB": "PHONE", "USB": "PHONE", "LSB": "PHONE", "FM": "PHONE", "AM": "PHONE", "PHONE": "PHONE",
    "FT8": "DIGITAL", "FT4": "DIGITAL", "RTTY": "DIGITAL", "PSK31": "DIGITAL", "PSK": "DIGITAL",
    "DATA": "DIGITAL", "JS8": "DIGITAL", "OLIVIA": "DIGITAL", "DIGI": "DIGITAL", "MFSK": "DIGITAL",
}

# FT8 / FT4 watering holes (kHz), and the CW ends of each band.
FT8 = [1840, 3573, 5357, 7074, 10136, 14074, 18100, 21074, 24915, 28074, 50313]
FT4 = [3575, 7047, 10140, 14080, 18104, 21140, 24919, 28180, 50318]
CW_SEGMENTS = [[1800, 1840], [3500, 3600], [7000, 7040], [10100, 10150], [14000, 14070],
               [18068, 18100], [21000, 21070], [24890, 24915], [28000, 28070], [50000, 50100]]

BANDS = [["80m-40m", "80-40"], ["30m-20m", "30-20"], ["17m-15m", "17-15"], ["12m-10m", "12-10"]]

# ---- sprites (three-tone shading) -------------------------------------------

# The sun: a round, glowing disc lit from the upper left, with eight rays.
# Sunspots are drawn on top from the real sunspot number, as small flecks.
SUN = """
..........r..........
..........R..........
.....................
...r.....ggg.....r...
....R..ggEEEgg..R....
.....ggEEYYYEEgg.....
.....gEYWWYYYYEg.....
....gEYWWWYYYYYEg....
....gEYWWYYYYYYEg....
...gEYYYYYYYYYYYEg...
rR.gEYYYYYYYYYYYEg.Rr
...gEYYYYYYYYYYOEg...
....gEYYYYYYYYOEg....
....gEYYYYYYYOOEg....
.....gEYYYYYOOEg.....
.....ggEEYYOEEgg.....
....R..ggEEEgg..R....
...r.....ggg.....r...
.....................
..........R..........
..........r..........
"""
SUN_LEGEND = {"W": "#FFF8C8", "Y": "#FFD23F", "O": "#FFA62B", "E": "#F07F12", "g": "#4A2A06",
              "R": "#FFC233", "r": "#E0861A"}
SUNSPOTS = [[11, 9], [13, 12], [8, 13], [12, 7], [10, 14], [14, 10]]
SUNSPOT_COLOR = "#D9771A"

# Parks on the Air: a pine, a portable vertical on the air, a tent.
CAMP = """
................Y.........
...........w..wYaYw..w....
..........w..w..a..w..w...
..........w..w..a..w..w...
...........w..w.a.w..w....
.....G..........a.........
....GGG.........a.........
...GGgGG........a.........
....GGG.........a.........
...GGGgG........a.........
..GGGGGgG.......a.........
...GGGGG........a.....T...
..GGGGGGgG......a....TTT..
.GGGGGGGGgG.....a...TTTTT.
GGGGGGGGGGgG....a..TTTCTTT
.....tt.........a..TTCCCTT
dddddddddddddddddddddddddd
"""
CAMP_LEGEND = {"G": "#1F9D4A", "g": "#147A38", "t": "#7A4F28", "a": "#C9D3DF", "w": "#FFC233",
               "T": "#F08A1C", "C": "#5A2A0A", "d": "#3A6B2A", "Y": "#FF3B30"}

# The globe, lit from the upper left, with a signal going out.
GLOBE = """
......bbbbbbb......
....bbBBBBBbbbb....
...bBBHHGGBBBbbb...
..bBHHGGGGBBBBbbb..
.bBHBGGGGGBBGGBbbb.
.bBBBBGGGBBGGGGbbb.
bBBBBBBGBBBGGGGBbbb
bBBBBBBGGBBBGGBBbbb
bBBBBBBBGGBBBBBBbbb
bBBGGBBBBBBBBGBBbbb
bBBGGGBBBBBBGGBbbbb
.bBBGGGBBBBBBBBbbb.
.bbBBGGBBBBBBBbbbb.
..bbBBGBBBBBBbbbb..
...bbbBBBBBbbbbb...
....bbbbbbbbbbb....
......bbbbbbb......
"""
GLOBE_LEGEND = {"B": "#2F6FD8", "b": "#1E4A9A", "H": "#7FB2FF", "G": "#3FBF5A"}

WAVES = """
.y.....
..y..y.
..y...y
..y...y
..y..y.
.y.....
"""

LEFT = 10
RIGHT = 181


# ---- helpers -------------------------------------------------------------------

def fetch(url, ttl):
    resp = http.get(url, headers = HEADERS, ttl_seconds = ttl)
    return resp if resp["status_code"] == 200 else None


def clip(c, text, font, max_w):
    text = str(text)
    for _i in range(64):
        if len(text) <= 1 or c.text_width(text, font) <= max_w:
            break
        text = text[:len(text) - 1]
    return text.strip()


def clip_words(c, text, font, max_w):
    words = [w for w in str(text).split(" ") if w != ""]
    for n in range(len(words), 0, -1):
        trial = " ".join(words[:n]).rstrip(":,-(")
        if c.text_width(trial, font) <= max_w:
            return trial
    return clip(c, text, font, max_w)


def pad2(n):
    return ("0" if n < 10 else "") + str(n)


def zulu(now):
    # Hams keep UTC: "0258Z".
    s = now % 86400
    return pad2(s // 3600) + pad2((s % 3600) // 60) + "Z"


def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def utc_unix(date, hhmm, sec):
    # "2026-11-13", "02:36" or "0236" -> unix seconds.
    p = str(date).split("-")
    t = str(hhmm).replace(":", "")
    if len(p) != 3 or len(t) < 4 or not t[:4].isdigit():
        return 0
    return days_from_civil(int(p[0]), int(p[1]), int(p[2])) * 86400 + int(t[0:2]) * 3600 + int(t[2:4]) * 60 + sec


def ago(secs):
    m = max(0, secs) // 60
    return "NOW" if m < 1 else str(m) + "M AGO" if m < 60 else str(m // 60) + "H AGO"


def mhz(khz):
    # 7074.0 -> "7.074"; 14062.5 -> "14.062"
    k = int(float(khz) * 10) // 10
    return str(k // 1000) + "." + ("00" + str(k % 1000))[-3:]


def band_of(khz):
    k = float(khz)
    for b in [[1800, 2000, "160M"], [3500, 4000, "80M"], [5330, 5410, "60M"], [7000, 7300, "40M"],
              [10100, 10150, "30M"], [14000, 14350, "20M"], [18068, 18168, "17M"], [21000, 21450, "15M"],
              [24890, 24990, "12M"], [28000, 29700, "10M"], [50000, 54000, "6M"], [144000, 148000, "2M"]]:
        if k >= b[0] and k <= b[1]:
            return b[2]
    return ""


def mode_input(ctx):
    m = str(ctx.inputs.get("mode", "ALL MODES")).upper()
    return m if m in ["ALL MODES", "CW", "PHONE", "DIGITAL"] else "ALL MODES"


def area_input(ctx):
    a = str(ctx.inputs.get("area", "USA")).upper()
    return a if a in AREAS else "USA"


def area_short(area):
    # "W4 SOUTHEAST" -> "W4"; "USA" stays.
    return area.split(" ")[0] if area.startswith("W") and area[1:2].isdigit() else area


def draw_error(c, title, sub, x):
    c.text(clip_words(c, title, "6x8", RIGHT - x), x, 9, font = "6x8", color = COLORS["error"])
    c.text(clip_words(c, sub, "4x5", RIGHT - x), x, 21, font = "4x5", color = COLORS["error_sub"])


def fit_call(c, call, font, max_w):
    # A portable call too long for the room ("KC2QVD/VA2") loses its
    # suffix or prefix rather than being cut mid-way.
    if c.text_width(call, font) <= max_w or "/" not in call:
        return clip(c, call, font, max_w)
    parts = sorted(call.split("/"), key = lambda p: len(p), reverse = True)
    return clip(c, parts[0], font, max_w)


def mode_badge(c, x, y, label, family):
    # A small filled badge, dark text on the mode's colour; returns its width.
    w = c.text_width(label, "4x5") + 4
    c.rect(x, y, x + w - 1, y + 6, fill = MODE_COLORS.get(family, COLORS["dim"]))
    c.text(label, x + 2, y + 1, font = "4x5", color = "#000000")
    return w


# ---- page 1: HF band conditions -------------------------------------------------------

def tag(xml, name):
    i = xml.find("<" + name + ">")
    if i < 0:
        return ""
    i += len(name) + 2
    j = xml.find("</" + name + ">", i)
    return xml[i:j].strip() if j > i else ""


def band_condition(xml, band, time):
    key = 'name="' + band + '" time="' + time + '">'
    i = xml.find(key)
    if i < 0:
        return ""
    i += len(key)
    return xml[i:xml.find("<", i)].strip().upper()


def cond_color(word):
    return COLORS["good"] if word == "GOOD" else (COLORS["fair"] if word == "FAIR" else (COLORS["poor"] if word == "POOR" else COLORS["dim"]))


def k_color(k):
    return COLORS["good"] if k <= 2 else (COLORS["fair"] if k <= 4 else COLORS["poor"])


def num(s):
    s = str(s).strip()
    out = ""
    for ch in s.elems():
        if ch.isdigit():
            out += ch
        elif out != "":
            break
    return int(out) if out != "" else -1


VHF_PLACES = {
    "north_america": ["NA", "NA"], "europe": ["EU", "EU"], "europe_6m": ["EU 6M", "EU"],
    "europe_4m": ["EU 4M", "EU"], "northern_hemi": ["", ""],
}


def vhf_open(xml, home):
    # The first VHF phenomenon that isn't "Band Closed" and is on your side
    # of the world: [name, place] or None.
    i = 0
    for _n in range(12):
        i = xml.find("<phenomenon ", i)
        if i < 0:
            return None
        j = xml.find(">", i)
        k = xml.find("</phenomenon>", j)
        state = xml[j + 1:k].strip().upper()
        head = xml[i:j]
        if state != "" and state != "BAND CLOSED":
            name = head[head.find('name="') + 6:]
            name = name[:name.find('"')].upper().replace("VHF-", "")
            where = head[head.find('location="') + 10:]
            place = VHF_PLACES.get(where[:where.find('"')].lower(), ["", ""])
            if home == "" or place[1] == "" or place[1] == home:
                return [name, place[0]]
        i = k
    return None


AREA_UTC = {
    "USA": -6, "CANADA": -5, "W1 NEW ENGLAND": -5, "W2 NY NJ": -5, "W3 MID ATLANTIC": -5,
    "W4 SOUTHEAST": -5, "W5 SOUTH CENTRAL": -6, "W6 CALIFORNIA": -8, "W7 NORTHWEST": -7,
    "W8 MI OH WV": -5, "W9 IL IN WI": -6, "W0 PLAINS": -6,
}


def is_day(now, area):
    # True / False for daytime (06-18 local, roughly) in the area; None worldwide.
    off = AREA_UTC.get(area)
    if off == None:
        return None
    h = ((now % 86400) // 3600 + off + 24) % 24
    return h >= 6 and h < 18


def bands(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    resp = fetch(SOLAR_URL, 1800)
    xml = resp["body"] if resp != None else ""
    c.sprite(SUN, LEFT, 5, legend = SUN_LEGEND)
    if xml.find("<solardata>") < 0:
        draw_error(c, "SOLAR DATA OFFLINE", "BAND CONDITIONS RETURN SOON", LEFT + 24)
        return

    ssn = num(tag(xml, "sunspots"))
    for i in range(min(len(SUNSPOTS), max(0, (ssn + 24) // 25))):
        c.pixel(LEFT + SUNSPOTS[i][0], 5 + SUNSPOTS[i][1], SUNSPOT_COLOR)

    # The band table: day and night.
    gx = LEFT + 24
    dx = gx + 28
    nx = dx + 25
    c.text("HF", gx, 1, font = "4x5", color = COLORS["gold"])
    # The column for the time of day it is in your area is lit.
    day = is_day(now, area_input(ctx))
    c.text("DAY", dx, 1, font = "4x5", color = COLORS["text"] if day == True else COLORS["dim"])
    c.text("NIGHT", nx, 1, font = "4x5", color = COLORS["text"] if day == False else COLORS["dim"])
    for r in range(len(BANDS)):
        y = 8 + r * 6
        c.text(BANDS[r][1], gx, y, font = "4x5", color = COLORS["label"])
        for col in [[dx, "day"], [nx, "night"]]:
            w = band_condition(xml, BANDS[r][0], col[1])
            c.text(w if w != "" else "-", col[0], y, font = "4x5", color = cond_color(w))

    # The numbers behind them.
    sx = nx + 30
    c.text(zulu(now), RIGHT, 1, font = "4x5", color = COLORS["label"], align = "right")
    k = num(tag(xml, "kindex"))
    a = num(tag(xml, "aindex"))
    stats = [
        ["SFI", str(num(tag(xml, "solarflux"))), COLORS["text"], sx, 8],
        ["SSN", str(ssn), COLORS["text"], sx + 36, 8],
        ["K", str(k), k_color(k), sx, 16],
        ["A", str(a), k_color(1 if a < 15 else (3 if a < 30 else 5)), sx + 36, 16],
    ]
    for s in stats:
        c.text(s[0], s[3], s[4] + 1, font = "4x5", color = COLORS["dim"])
        c.text(s[1] if s[1] != "-1" else "-", s[3] + c.text_width(s[0], "4x5") + 3, s[4], font = "5x7", color = s[2])

    # Bottom: a VHF opening when there is one, else the noise floor.
    v = vhf_open(xml, AREAS[area_input(ctx)][1])
    if v != None:
        words = " ".join([w for w in [v[0], v[1], "OPEN"] if w != ""])
        c.text(clip_words(c, words, "4x5", RIGHT - sx), sx, 25, font = "4x5", color = COLORS["good"])
    else:
        noise = tag(xml, "signalnoise").upper()
        c.text("NOISE", sx, 25, font = "4x5", color = COLORS["dim"])
        c.text(noise if noise != "" else "-", sx + 28, 25, font = "4x5", color = COLORS["label"])


# ---- page 2: Parks on the Air -------------------------------------------------------------

def spot_area_ok(desc, area):
    places = AREAS[area][0]
    if len(places) == 0:
        return True
    for d in str(desc).upper().split(","):
        d = d.strip()
        for p in places:
            if d == p or d.startswith(p + "-"):
                return True
    return False


def pota(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    mode = mode_input(ctx)
    area = area_input(ctx)
    c.sprite(CAMP, LEFT, 14, legend = CAMP_LEGEND)
    x = LEFT + 30

    resp = fetch(POTA_URL, 60)
    spots = resp["json"] if resp != None else None
    if type(spots) != "list":
        c.text("POTA", LEFT, 1, font = "4x5", color = COLORS["pota"])
        draw_error(c, "POTA OFFLINE", "PARK SPOTS RETURN SOON", x)
        return

    live = []
    seen = {}
    for s in spots:
        # "QRT" in the comments means the activator has signed off.
        if "QRT" in str(s.get("comments") or "").upper() or s.get("invalid"):
            continue
        who = str(s.get("activator") or "").upper()
        if who == "" or who in seen:
            continue
        seen[who] = True
        fam = MODE_FAMILY.get(str(s.get("mode") or "").upper(), "")
        if mode != "ALL MODES" and fam != mode:
            continue
        if not spot_area_ok(s.get("locationDesc") or "", area):
            continue
        t = str(s.get("spotTime") or "")
        live.append([utc_unix(t[:10], t[11:16], 0), s, fam])
    live = sorted(live, key = lambda r: r[0], reverse = True)

    word = "1 ON THE AIR" if len(live) == 1 else str(len(live)) + " ON THE AIR"
    c.text("POTA", LEFT, 1, font = "4x5", color = COLORS["pota"])
    c.text(word, LEFT + 22, 1, font = "4x5", color = COLORS["label"])
    scope = area_short(area) + ("" if mode == "ALL MODES" else " " + mode)
    c.text(scope, RIGHT, 1, font = "4x5", color = COLORS["dim"], align = "right")

    if len(live) == 0:
        draw_error(c, "NO PARKS ON AIR", "NONE IN " + scope + " RIGHT NOW", x)
        return

    # Columns, sized from the rows on screen: call | frequency | mode | place.
    rows = []
    for i in range(min(3, len(live))):
        s = live[i][1]
        f = str(s.get("frequency") or "")
        rows.append({
            "call": str(s.get("activator") or "").upper(),
            "freq": mhz(f) if f.replace(".", "").isdigit() else "",
            "mode": str(s.get("mode") or "?").upper(),
            "family": live[i][2],
            "loc": str(s.get("locationDesc") or "").split(",")[0].upper(),
        })
    loc_w = max([c.text_width(r["loc"], "4x5") for r in rows])
    badge_w = max([c.text_width(r["mode"], "4x5") + 4 for r in rows])
    freq_w = max([c.text_width(r["freq"], "5x7") for r in rows])
    badge_x = RIGHT - loc_w - 4 - badge_w
    freq_right = badge_x - 4
    call_room = freq_right - freq_w - 5 - x
    for i in range(len(rows)):
        r = rows[i]
        y = 8 + i * 8
        c.text(r["loc"], badge_x + badge_w + 4, y + 1, font = "4x5", color = COLORS["label"])
        mode_badge(c, badge_x, y, r["mode"], r["family"])
        c.text(r["freq"], freq_right, y, font = "5x7", color = COLORS["gold"], align = "right")
        c.text(fit_call(c, r["call"], "5x7", call_room), x, y, font = "5x7", color = COLORS["text"])


# ---- page 3: the hottest DX ----------------------------------------------------------------

def dx_mode(khz, comment):
    # [family, label] from the comment if it says, else the band plan.
    cm = " " + str(comment).upper() + " "
    for d in ["FT8", "FT4", "RTTY", "PSK", "JS8"]:
        if d in cm:
            return ["DIGITAL", d]
    if " CW " in cm or "WPM" in cm:
        return ["CW", "CW"]
    for p in [" SSB ", " USB ", " LSB ", " FM "]:
        if p in cm:
            return ["PHONE", "SSB" if p != " FM " else "FM"]
    k = int(float(khz))
    for f in FT8:
        if k >= f and k <= f + 3:
            return ["DIGITAL", "FT8"]
    for f in FT4:
        if k >= f and k <= f + 3:
            return ["DIGITAL", "FT4"]
    for seg in CW_SEGMENTS:
        if k >= seg[0] and k < seg[1]:
            return ["CW", "CW"]
    return ["PHONE", "SSB"]


def parse_cluster(text):
    # spotter^freq^dx^comment^"HHMM YYYY-MM-DD"^lotw^eqsl^continent^band^country^dxcc
    out = []
    for line in str(text).split("\n"):
        f = line.strip().split("^")
        if len(f) < 10 or f[2] == "" or not f[1].replace(".", "").isdigit():
            continue
        when = f[4].split(" ")
        out.append({
            "spotter": f[0].upper(),
            "khz": f[1],
            "call": f[2].upper(),
            "comment": f[3],
            "unix": utc_unix(when[1], when[0], 0) if len(when) == 2 else 0,
            "cont": f[7].upper(),
            "band": f[8].upper() if f[8] != "" else band_of(f[1]),
            "country": f[9].upper(),
        })
    return out


def dx(c, ctx):
    c.fill(COLORS["bg"])
    now = ctx.now.unix
    mode = mode_input(ctx)
    area = area_input(ctx)
    home = AREAS[area][1]
    c.sprite(GLOBE, LEFT, 9, legend = GLOBE_LEGEND)
    c.sprite(WAVES, LEFT + 20, 14, legend = {"y": COLORS["gold"]})
    x = LEFT + 31
    c.text("HOT DX", LEFT, 1, font = "4x5", color = COLORS["gold"])
    c.text(zulu(now), RIGHT, 1, font = "4x5", color = COLORS["label"], align = "right")

    resp = fetch(DXC_URL, 60)
    spots = parse_cluster(resp["body"]) if resp != None else []
    if len(spots) == 0:
        draw_error(c, "DX CLUSTER OFFLINE", "SPOTS RETURN SOON", x)
        return

    # Rank DX stations by how many spots they drew; DX from your own
    # continent doesn't count.
    tally = {}
    for s in spots:
        if home != "" and s["cont"] == home:
            continue
        # A station spotting itself isn't a pileup.
        if s["spotter"] == s["call"]:
            continue
        m = dx_mode(s["khz"], s["comment"])
        if mode != "ALL MODES" and m[0] != mode:
            continue
        t = tally.get(s["call"])
        if t == None:
            tally[s["call"]] = {"n": 1, "last": s, "mode": m, "bands": [s["band"]]}
        else:
            t["n"] += 1
            if s["unix"] > t["last"]["unix"]:
                t["last"] = s
                t["mode"] = m
            if s["band"] not in t["bands"]:
                t["bands"].append(s["band"])
    if len(tally) == 0:
        c.text("MOST SPOTTED", LEFT + 30, 1, font = "4x5", color = COLORS["dim"])
        draw_error(c, "NO DX SPOTTED", "THE CLUSTER IS QUIET", x)
        return
    calls = sorted(tally.keys(), key = lambda k: [tally[k]["n"], tally[k]["last"]["unix"]], reverse = True)
    top = tally[calls[0]]
    last = top["last"]
    c.text("MOST SPOTTED", LEFT + 30, 1, font = "4x5", color = COLORS["dim"])

    # Hero: the call sign.
    call = last["call"]
    # The biggest face that fits; all of these have "/" for portable calls
    # ("LX/PA1L"). [font, y] keeps each one centred on the hero line.
    font = ["5x7", 12]
    for f in [["10x16", 8], ["9x12", 10], ["8x12", 10], ["6x9", 11]]:
        if c.text_width(call, f[0]) <= 66:
            font = f
            break
    c.text(call, x, font[1], font = font[0], color = COLORS["text"])
    font = font[0]
    rx = x + c.text_width(call, font) + 6

    # Country, then where it was last heard.
    c.text(clip_words(c, last["country"], "5x7", RIGHT - rx), rx, 8, font = "5x7", color = COLORS["text"])
    freq = mhz(last["khz"])
    c.text(freq, rx, 17, font = "4x5", color = COLORS["gold"])
    bx = rx + c.text_width(freq, "4x5") + 4
    bx += mode_badge(c, bx, 16, top["mode"][1], top["mode"][0]) + 4
    c.text(ago(now - last["unix"]), bx, 17, font = "4x5", color = COLORS["dim"])

    # Bottom: the bands it's been heard on, and the spot count.
    n = str(top["n"]) + (" SPOT" if top["n"] == 1 else " SPOTS")
    c.text(n, RIGHT, 26, font = "4x5", color = COLORS["label"], align = "right")
    limit = RIGHT - c.text_width(n, "4x5") - 6
    bxx = x
    for b in BAND_ORDER:
        if b not in top["bands"]:
            continue
        w = c.text_width(b, "4x5")
        if bxx + w > limit:
            break
        c.text(b, bxx, 26, font = "4x5", color = BAND_COLORS.get(b, COLORS["label"]))
        bxx += w + 5
