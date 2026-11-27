# Ham Shack -- a ham radio shack panel on 64x32.
#
# The 192-wide Ham Shack answers "what is happening on the air" across three
# wide pages. 64x32 cannot hold those layouts, so this is not that app made
# small: each page here answers one question a shack operator actually asks,
# and the day/night band matrix is cut to the half that applies right now.
#
#   bands   the four HF band groups with GOOD / FAIR / POOR for the time of
#           day it is where you are, each with a bar so the page reads from
#           across the room
#   solar   the solar flux index as the hero, SSN / K / A beside it, and the
#           highest band that flux supports, from N0NBH's own table
#   pota    the newest Parks on the Air activator in your area, and how many
#           are on the air
#   dx      the most-spotted DX station on the cluster outside your continent
#
# Data, keyless:
#   hamqsl.com/solarxml.php        N0NBH solar-terrestrial data (XML)
#   api.pota.app/spot/activator    live POTA activator spots (JSON)
#   hamqth.com/dxc_csv.php         the last 200 DX cluster spots (CSV)
#
# Every string on this panel is measured before it is drawn. A 4x5 glyph
# advances 5px, not 4 (the font carries a 1px gap), so "HOT DX" next to
# "17 SPOTS" wants 71px of a 64px panel -- the kind of overflow that clips
# in silence.

SOLAR_URL = "https://www.hamqsl.com/solarxml.php"
POTA_URL = "https://api.pota.app/spot/activator"
DXC_URL = "https://www.hamqth.com/dxc_csv.php?limit=200"
HEADERS = {
    "Accept": "application/json, text/xml, text/plain",
    "User-Agent": "Glance-GDN ham-shack (github.com/glance-led-dev/glance-dev-network)",
}

BG = "#000000"
TEXT = "#F4F7FB"
LABEL = "#8A93A6"
DIM = "#4B5563"
DIVIDE = "#232A36"
GOLD = "#FFC233"
GOOD = "#34D058"
FAIR = "#FFB020"
POOR = "#FF4D4D"
POTA_GREEN = "#34D058"
ERROR = "#E8B04A"
ERROR_SUB = "#6A7090"

MODE_COLORS = {"CW": "#FFC233", "PHONE": "#5AB4FF", "DIGITAL": "#D07CFF"}

BAND_COLORS = {
    "160M": "#C2772E", "80M": "#A855F7", "60M": "#818CF8", "40M": "#3B82F6",
    "30M": "#22D3EE", "20M": "#34D058", "17M": "#A3E635", "15M": "#FACC15",
    "12M": "#FB923C", "10M": "#FF4D4D", "6M": "#F472B6", "2M": "#E5E7EB",
}

# Where you are -> which POTA spots count, your continent (DX from your own
# continent isn't DX), and the short form the header has room for.
AREAS = {
    "WORLDWIDE": [[], "", "WW"],
    "USA": [["US"], "NA", "USA"],
    "CANADA": [["CA"], "NA", "VE"],
    "W1 NEW ENGLAND": [["US-CT", "US-ME", "US-MA", "US-NH", "US-RI", "US-VT"], "NA", "W1"],
    "W2 NY NJ": [["US-NY", "US-NJ"], "NA", "W2"],
    "W3 MID ATLANTIC": [["US-DE", "US-DC", "US-MD", "US-PA"], "NA", "W3"],
    "W4 SOUTHEAST": [["US-AL", "US-FL", "US-GA", "US-KY", "US-NC", "US-SC", "US-TN", "US-VA"], "NA", "W4"],
    "W5 SOUTH CENTRAL": [["US-AR", "US-LA", "US-MS", "US-NM", "US-OK", "US-TX"], "NA", "W5"],
    "W6 CALIFORNIA": [["US-CA"], "NA", "W6"],
    "W7 NORTHWEST": [["US-AZ", "US-ID", "US-MT", "US-NV", "US-OR", "US-UT", "US-WA", "US-WY"], "NA", "W7"],
    "W8 MI OH WV": [["US-MI", "US-OH", "US-WV"], "NA", "W8"],
    "W9 IL IN WI": [["US-IL", "US-IN", "US-WI"], "NA", "W9"],
    "W0 PLAINS": [["US-CO", "US-IA", "US-KS", "US-MN", "US-MO", "US-NE", "US-ND", "US-SD"], "NA", "W0"],
}

# Roughly the middle of each area, for the day/night question only.
# WORLDWIDE has no local noon, so it falls back to UTC and says WW.
AREA_UTC = {
    "USA": -6, "CANADA": -5, "W1 NEW ENGLAND": -5, "W2 NY NJ": -5, "W3 MID ATLANTIC": -5,
    "W4 SOUTHEAST": -5, "W5 SOUTH CENTRAL": -6, "W6 CALIFORNIA": -8, "W7 NORTHWEST": -7,
    "W8 MI OH WV": -5, "W9 IL IN WI": -6, "W0 PLAINS": -6,
}

# POTA modes by family, and the two-letter form for the scope line.
MODE_FAMILY = {
    "CW": "CW",
    "SSB": "PHONE", "USB": "PHONE", "LSB": "PHONE", "FM": "PHONE", "AM": "PHONE", "PHONE": "PHONE",
    "FT8": "DIGITAL", "FT4": "DIGITAL", "RTTY": "DIGITAL", "PSK31": "DIGITAL", "PSK": "DIGITAL",
    "DATA": "DIGITAL", "JS8": "DIGITAL", "OLIVIA": "DIGITAL", "DIGI": "DIGITAL", "MFSK": "DIGITAL",
}
MODE_SHORT = {"CW": "CW", "PHONE": "PH", "DIGITAL": "DG"}

# FT8 / FT4 watering holes (kHz), and the CW ends of each band.
FT8 = [1840, 3573, 5357, 7074, 10136, 14074, 18100, 21074, 24915, 28074, 50313]
FT4 = [3575, 7047, 10140, 14080, 18104, 21140, 24919, 28180, 50318]
CW_SEGMENTS = [[1800, 1840], [3500, 3600], [7000, 7040], [10100, 10150], [14000, 14070],
               [18068, 18100], [21000, 21070], [24890, 24915], [28000, 28070], [50000, 50100]]

# N0NBH's band groups, with the short label this panel has room for.
BANDS = [["80m-40m", "80-40"], ["30m-20m", "30-20"], ["17m-15m", "17-15"], ["12m-10m", "12-10"]]

# How high the flux will carry you, straight from N0NBH's own
# "Band Openings Use Solar Flux" table (hamqsl.com/solar2.html):
# [floor, verdict, colour].
SFI_BANDS = [
    [0, "40M AND DOWN", POOR],
    [70, "UP TO 20M", FAIR],
    [90, "UP TO 15M", FAIR],
    [120, "UP TO 10M", GOOD],
    [150, "10M PLUS 6M", GOOD],
    [200, "ALL BANDS 6M", GOOD],
]

# Starlark has no font metrics call, so heights travel with the name.
HERO = [["16x20", 20], ["10x16", 16], ["6x8", 8]]
CALL_FACES = [["10x16", 16], ["9x12", 12], ["6x8", 8], ["5x7", 7]]
TITLE_FACES = [["6x8", 8], ["5x7", 7], ["4x5", 5]]

# 64x32 has no neighbouring app to pad against, so column 0 and column 63
# are both in play.
LEFT = 0
RIGHT = 63
WIDE = 64


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


def pick(c, text, faces, max_w):
    # [font, height, text] for the largest face that fits, hard-clipped if
    # none do -- text_fit draws anyway once its ladder runs out.
    use = faces[len(faces) - 1]
    for f in faces:
        if c.text_width(text, f[0]) <= max_w:
            use = f
            break
    return [use[0], use[1], clip(c, text, use[0], max_w)]


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
    return AREAS[area][2]


def scope_of(area, mode):
    # "W4", "USA DG" -- short enough to sit beside a page title.
    s = area_short(area)
    return s if mode == "ALL MODES" else s + " " + MODE_SHORT.get(mode, mode)


def fit_call(c, call, font, max_w):
    # A portable call too long for the room ("KC2QVD/VA2") loses its suffix
    # or prefix rather than being cut mid-way.
    if c.text_width(call, font) <= max_w or "/" not in call:
        return clip(c, call, font, max_w)
    parts = sorted(call.split("/"), key = lambda p: len(p), reverse = True)
    return clip(c, parts[0], font, max_w)


def hero_call(c, call, max_w):
    """[font, height, text] -- the biggest face a call sign fits in.

    At each size the whole call is tried first; a portable call that will
    not fit ("KC2QVD/VA2") gives up its suffix rather than drop a size,
    because the base call large beats the full call small on a panel."""
    base = call
    if "/" in call:
        base = sorted(call.split("/"), key = lambda p: len(p), reverse = True)[0]
    for f in CALL_FACES:
        if c.text_width(call, f[0]) <= max_w:
            return [f[0], f[1], call]
        if c.text_width(base, f[0]) <= max_w:
            return [f[0], f[1], base]
    use = CALL_FACES[len(CALL_FACES) - 1]
    return [use[0], use[1], clip(c, base, use[0], max_w)]


def header(c, left, left_color, right, right_color, rule):
    # y 0-4 eyebrow, optionally with a 1px rule at y6. The right side is
    # measured first, so a long count never grows into the title.
    room = RIGHT + 1
    if right != "":
        c.text(right, RIGHT, 0, font = "4x5", color = right_color, align = "right")
        room = RIGHT - c.text_width(right, "4x5") - 1
    c.text(clip(c, left, "4x5", room - LEFT), LEFT, 0, font = "4x5", color = left_color)
    if rule:
        c.line(0, 6, 63, 6, DIVIDE)


def nodata(c, title, sub):
    # Shown whenever a feed is unreachable: the publish-time validator renders
    # every page with the network off, and a panel on a wall must say
    # something rather than going blank.
    c.fill("#0B0C12")
    t = pick(c, title, TITLE_FACES, WIDE - 2)
    c.text(t[2], 32, 5, font = t[0], color = ERROR, align = "center")
    d = pick(c, sub, [["4x5", 5]], WIDE - 2)
    c.text(d[2], 32, 18, font = d[0], color = ERROR_SUB, align = "center")


def quiet(c, title, sub, color):
    # Nothing on the air is an answer, not a fault -- so it does not wear
    # the amber error card.
    t = pick(c, title, TITLE_FACES, WIDE - 2)
    c.text(t[2], 32, 11, font = t[0], color = color, align = "center")
    d = pick(c, sub, [["4x5", 5]], WIDE - 2)
    c.text(d[2], 32, 23, font = d[0], color = DIM, align = "center")


def mode_chip(c, x, y, label, family):
    # Dark text on the mode's colour; returns its width.
    w = c.text_width(label, "4x5") + 4
    c.rect(x, y, x + w - 1, y + 6, fill = MODE_COLORS.get(family, DIM))
    c.text(label, x + 2, y + 1, font = "4x5", color = "#000000")
    return w


# ---- the solar XML ----------------------------------------------------------

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
    return GOOD if word == "GOOD" else (FAIR if word == "FAIR" else (POOR if word == "POOR" else DIM))


def cond_bar(word):
    # The same reading as the word, in a length the eye catches first.
    return 15 if word == "GOOD" else (10 if word == "FAIR" else (5 if word == "POOR" else 0))


def k_color(k):
    return GOOD if k <= 2 else (FAIR if k <= 4 else POOR)


def a_color(a):
    return GOOD if a < 15 else (FAIR if a < 30 else POOR)


def num(s):
    s = str(s).strip()
    out = ""
    for ch in s.elems():
        if ch.isdigit():
            out += ch
        elif out != "":
            break
    return int(out) if out != "" else -1


def sfi_band(sfi):
    out = SFI_BANDS[0]
    for b in SFI_BANDS:
        if sfi >= b[0]:
            out = b
    return out


def day_now(ctx):
    # Daytime, roughly, in the middle of the chosen area.
    off = AREA_UTC.get(area_input(ctx), 0)
    h = ((ctx.now.unix % 86400) // 3600 + off + 24) % 24
    return h >= 6 and h < 18


def solar_xml():
    resp = fetch(SOLAR_URL, 1800)
    xml = resp["body"] if resp != None else ""
    return xml if xml.find("<solardata>") >= 0 else ""


# ---- page 1: the bands, right now -------------------------------------------

def bands(c, ctx):
    c.fill(BG)
    xml = solar_xml()
    if xml == "":
        nodata(c, "NO SOLAR", "HAMQSL DOWN")
        return

    day = day_now(ctx)
    col = "day" if day else "night"
    header(c, "HF", GOLD, area_short(area_input(ctx)) + (" DAY" if day else " NIGHT"),
           LABEL, True)

    # Label at x0 (24px), bar x26-42, word right-aligned (19px, from x45).
    for r in range(len(BANDS)):
        y = 8 + r * 6
        word = band_condition(xml, BANDS[r][0], col)
        shade = cond_color(word)
        c.text(word if word != "" else "-", RIGHT, y, font = "4x5", color = shade, align = "right")
        c.text(BANDS[r][1], LEFT, y, font = "4x5", color = LABEL)
        w = cond_bar(word)
        if w > 0:
            c.rect(26, y + 1, 26 + w - 1, y + 3, fill = shade)


# ---- page 2: the numbers behind them ----------------------------------------

def solar(c, ctx):
    c.fill(BG)
    xml = solar_xml()
    if xml == "":
        nodata(c, "NO SOLAR", "HAMQSL DOWN")
        return

    # No hairline on this page: 5 header + 20 hero + 5 verdict + gaps is
    # exactly 32 rows, and the flux is worth the hero face.
    header(c, "SOLAR", LABEL, zulu(ctx.now.unix), DIM, False)
    sfi = num(tag(xml, "solarflux"))
    verdict = sfi_band(sfi)

    h = pick(c, str(sfi) if sfi >= 0 else "-", HERO, 33)
    c.text(h[2], LEFT, 6 + (20 - h[1]) // 2, font = h[0], color = verdict[2])

    # SSN, K and A: label left, value right-aligned, so three digits never
    # push back into the hero.
    k = num(tag(xml, "kindex"))
    a = num(tag(xml, "aindex"))
    rows = [
        ["SSN", num(tag(xml, "sunspots")), TEXT],
        ["K", k, k_color(k)],
        ["A", a, a_color(a)],
    ]
    for i in range(len(rows)):
        y = 7 + i * 7
        c.text(rows[i][0], 35, y, font = "4x5", color = DIM)
        c.text(str(rows[i][1]) if rows[i][1] >= 0 else "-", RIGHT, y, font = "4x5",
               color = rows[i][2], align = "right")

    # What that flux is worth, in N0NBH's own words.
    c.text(clip(c, verdict[1], "4x5", WIDE), LEFT, 27, font = "4x5", color = verdict[2])


# ---- page 3: Parks on the Air -----------------------------------------------

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
    c.fill(BG)
    mode = mode_input(ctx)
    area = area_input(ctx)
    scope = scope_of(area, mode)

    resp = fetch(POTA_URL, 60)
    spots = resp["json"] if resp != None else None
    if type(spots) != "list":
        nodata(c, "POTA DOWN", "BACK SOON")
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

    # With nothing on the air the scope belongs in the sentence, not twice.
    header(c, "POTA", POTA_GREEN, (str(len(live)) + " ON AIR") if len(live) > 0 else "",
           DIM, True)
    if len(live) == 0:
        quiet(c, "NO PARKS", "IN " + scope, POTA_GREEN)
        return

    live = sorted(live, key = lambda r: r[0], reverse = True)
    s = live[0][1]
    f = str(s.get("frequency") or "")
    freq = mhz(f) if f.replace(".", "").isdigit() else ""
    md = str(s.get("mode") or "?").upper()
    fam = live[0][2]
    # A long mode name would eat the frequency; the family says enough.
    if c.text_width(md, "4x5") > 19 and fam != "":
        md = MODE_SHORT.get(fam, md)
    where = str(s.get("locationDesc") or "").split(",")[0].upper()
    # "US-AZ" is the state everywhere else on the panel: "AZ".
    if where.startswith("US-") or where.startswith("CA-"):
        where = where[3:]

    h = hero_call(c, str(s.get("activator") or "").upper(), WIDE - 1)
    c.text(h[2], LEFT, 8 + (16 - h[1]) // 2, font = h[0], color = TEXT)

    # Footer, measured from the right so the chip never lands on the state.
    wx = RIGHT + 1
    if where != "":
        c.text(where, RIGHT, 26, font = "4x5", color = LABEL, align = "right")
        wx = RIGHT - c.text_width(where, "4x5") - 2
    chip_x = wx - (c.text_width(md, "4x5") + 4) + 1
    mode_chip(c, chip_x, 25, md, fam)
    if freq != "":
        c.text(clip(c, freq, "4x5", chip_x - 2 - LEFT), LEFT, 26, font = "4x5", color = GOLD)


# ---- page 4: the hottest DX -------------------------------------------------

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
    c.fill(BG)
    mode = mode_input(ctx)
    home = AREAS[area_input(ctx)][1]

    resp = fetch(DXC_URL, 60)
    spots = parse_cluster(resp["body"]) if resp != None else []
    if len(spots) == 0:
        nodata(c, "NO CLUSTER", "BACK SOON")
        return

    # Rank DX stations by how many spots they drew; DX from your own
    # continent doesn't count, and a station spotting itself isn't a pileup.
    tally = {}
    for s in spots:
        if home != "" and s["cont"] == home:
            continue
        if s["spotter"] == s["call"]:
            continue
        m = dx_mode(s["khz"], s["comment"])
        if mode != "ALL MODES" and m[0] != mode:
            continue
        t = tally.get(s["call"])
        if t == None:
            tally[s["call"]] = {"n": 1, "last": s, "mode": m}
        else:
            t["n"] += 1
            if s["unix"] > t["last"]["unix"]:
                t["last"] = s
                t["mode"] = m

    if len(tally) == 0:
        header(c, "HOT DX", GOLD, "", DIM, True)
        quiet(c, "NO HOT DX", "ALL QUIET", LABEL)
        return

    calls = sorted(tally.keys(), key = lambda k: [tally[k]["n"], tally[k]["last"]["unix"]], reverse = True)
    last = tally[calls[0]]["last"]

    # The frequency rides in the header: "HOT DX" and a spot count together
    # want 71px, and where to turn the dial is worth more than the tally.
    header(c, "HOT DX", GOLD, mhz(last["khz"]), GOLD, True)

    h = hero_call(c, last["call"], WIDE - 1)
    c.text(h[2], LEFT, 8 + (16 - h[1]) // 2, font = h[0], color = TEXT)

    # Footer: the band on the right in its own colour, the country in what
    # that leaves -- clipped at a word, never mid-word.
    band = last["band"]
    room = RIGHT + 1
    if band != "":
        c.text(band, RIGHT, 26, font = "4x5", color = BAND_COLORS.get(band, LABEL), align = "right")
        room = RIGHT - c.text_width(band, "4x5") - 2
    c.text(clip_words(c, last["country"], "4x5", room - LEFT), LEFT, 26, font = "4x5", color = LABEL)
