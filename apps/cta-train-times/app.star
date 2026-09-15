# CTA Train Times (Chicago) for Glance
#
# DESIGN. A platform sign for one CTA 'L' station, readable from across the
# room. The station name sits top-left over a stripe painted in the colors of
# every line stopping there (all red at Jarvis, six colors at Clark/Lake).
# Under it, two big departure rows: a small train front in the line's color
# is the label, then the destination, then the minutes as the hero. Each row
# is the next train to a different destination, so a two-way station shows
# both directions at once; a terminal fills row two with its following train.
# Black ground, white numbers; green only for DUE, amber only for a delay.
#
# Layout (128x32; content stays inside x 6..121 so the app reads as its own
# unit between neighbors in the scroll sequence):
#   y 0-6    STATION NAME (5x7, white)                      CTA (4x5, gray)
#   y 8      line-color stripe
#   y 10-19  [train] DESTINATION ....................... 7 MIN
#   y 21-30  [train] DESTINATION ...................... 15 MIN
#
# Data comes from our own caching proxy (cta-proxy on Vercel), NOT directly
# from CTA. The proxy holds the single CTA API key server-side and edge-caches
# each station for 60s, so every panel runs off one key and CTA is hit at most
# once per minute per station. The proxy returns CTA's ttarrivals JSON verbatim.
#   - arrT / tmst are ISO "YYYY-MM-DDTHH:MM:SS" in Chicago LOCAL time. We compute
#     minutes as (arrT - tmst), so timezone/DST never enter the math.

BASE_URL = "https://cta-proxy-rob-1155s-projects.vercel.app/api/arrivals"

# Station name (dropdown label) -> CTA map ID. Generated from the City of
# Chicago 'List of L Stops' dataset; names shared across lines are tagged.
STATIONS = {
    "18th": "40830",
    "35th-Bronzeville-IIT": "41120",
    "35th/Archer": "40120",
    "43rd": "41270",
    "47th (Green)": "41080",
    "47th (Red)": "41230",
    "51st": "40130",
    "54th/Cermak": "40580",
    "63rd": "40910",
    "69th": "40990",
    "79th": "40240",
    "87th": "41430",
    "95th/Dan Ryan": "40450",
    "Adams/Wabash": "40680",
    "Addison (Blue)": "41240",
    "Addison (Brown)": "41440",
    "Addison (Red)": "41420",
    "Argyle": "41200",
    "Armitage": "40660",
    "Ashland (Green/Pink)": "40170",
    "Ashland (Orange)": "41060",
    "Ashland/63rd": "40290",
    "Austin (Blue)": "40010",
    "Austin (Green)": "41260",
    "Belmont (Blue)": "40060",
    "Belmont (Brown/Purple/Red)": "41320",
    "Berwyn": "40340",
    "Bryn Mawr": "41380",
    "California (Blue)": "40570",
    "California (Green)": "41360",
    "California (Pink)": "40440",
    "Central (Green)": "40280",
    "Central (Purple)": "41250",
    "Central Park": "40780",
    "Cermak-Chinatown": "41000",
    "Cermak-McCormick Place": "41690",
    "Chicago (Blue)": "41410",
    "Chicago (Brown/Purple)": "40710",
    "Chicago (Red)": "41450",
    "Cicero (Blue)": "40970",
    "Cicero (Green)": "40480",
    "Cicero (Pink)": "40420",
    "Clark/Division": "40630",
    "Clark/Lake": "40380",
    "Clinton (Blue)": "40430",
    "Clinton (Green/Pink)": "41160",
    "Conservatory": "41670",
    "Cottage Grove": "40720",
    "Cumberland": "40230",
    "Damen (Blue)": "40590",
    "Damen (Brown)": "40090",
    "Damen (Green)": "41710",
    "Damen (Pink)": "40210",
    "Davis": "40050",
    "Dempster": "40690",
    "Dempster-Skokie": "40140",
    "Diversey": "40530",
    "Division": "40320",
    "Forest Park": "40390",
    "Foster": "40520",
    "Francisco": "40870",
    "Fullerton": "41220",
    "Garfield (Green)": "40510",
    "Garfield (Red)": "41170",
    "Grand (Blue)": "40490",
    "Grand (Red)": "40330",
    "Granville": "40760",
    "Halsted (Green)": "40940",
    "Halsted (Orange)": "41130",
    "Harlem (Blue, Blue Line - Forest Park Branch)": "40980",
    "Harlem (Blue, Blue Line - O'Hare Branch)": "40750",
    "Harlem/Lake": "40020",
    "Harold Washington Library-State/Van Buren": "40850",
    "Harrison": "41490",
    "Howard": "40900",
    "Illinois Medical District": "40810",
    "Indiana": "40300",
    "Irving Park (Blue)": "40550",
    "Irving Park (Brown)": "41460",
    "Jackson (Blue)": "40070",
    "Jackson (Red)": "40560",
    "Jarvis": "41190",
    "Jefferson Park": "41280",
    "Kedzie (Brown)": "41180",
    "Kedzie (Green)": "41070",
    "Kedzie (Orange)": "41150",
    "Kedzie (Pink)": "41040",
    "Kedzie-Homan": "40250",
    "Kimball": "41290",
    "King Drive": "41140",
    "Kostner": "40600",
    "Lake": "41660",
    "Laramie": "40700",
    "LaSalle": "41340",
    "LaSalle/Van Buren": "40160",
    "Lawrence": "40770",
    "Linden": "41050",
    "Logan Square": "41020",
    "Loyola": "41300",
    "Main": "40270",
    "Merchandise Mart": "40460",
    "Midway": "40930",
    "Monroe (Blue)": "40790",
    "Monroe (Red)": "41090",
    "Montrose (Blue)": "41330",
    "Montrose (Brown)": "41500",
    "Morgan": "41510",
    "Morse": "40100",
    "North/Clybourn": "40650",
    "Noyes": "40400",
    "O'Hare": "40890",
    "Oak Park (Blue)": "40180",
    "Oak Park (Green)": "41350",
    "Oakton-Skokie": "41680",
    "Paulina": "41310",
    "Polk": "41030",
    "Pulaski (Blue)": "40920",
    "Pulaski (Green)": "40030",
    "Pulaski (Orange)": "40960",
    "Pulaski (Pink)": "40150",
    "Quincy/Wells": "40040",
    "Racine": "40470",
    "Ridgeland": "40610",
    "Rockwell": "41010",
    "Roosevelt": "41400",
    "Rosemont": "40820",
    "Sedgwick": "40800",
    "Sheridan": "40080",
    "South Boulevard": "40840",
    "Southport": "40360",
    "Sox-35th": "40190",
    "State/Lake": "40260",
    "Thorndale": "40880",
    "UIC-Halsted": "40350",
    "Washington": "40370",
    "Washington/Wabash": "41700",
    "Washington/Wells": "40730",
    "Wellington": "41210",
    "Western (Blue, Blue Line - Forest Park Branch)": "40220",
    "Western (Blue, Blue Line - O'Hare Branch)": "40670",
    "Western (Brown)": "41480",
    "Western (Orange)": "40310",
    "Western (Pink)": "40740",
    "Wilson": "40540",
}

# rt code -> panel color
LINE_COLORS = {
    "Red": "red",
    "Blue": "blue",
    "Brn": "#a05a2c",   # no named brown; warm brown hex
    "G": "green",
    "Org": "orange",
    "P": "purple",
    "Pink": "pink",
    "Y": "yellow",
}

# Stripe order: CTA's usual line order.
LINE_ORDER = ["Red", "Blue", "Brn", "G", "Org", "P", "Pink", "Y"]

# Short forms, used only when the full name doesn't fit its slot.
DEST_SHORT = {
    "95TH/DAN RYAN": "95TH",
    "DEMPSTER-SKOKIE": "SKOKIE",
    "JEFFERSON PARK": "JEFF PARK",
    "COTTAGE GROVE": "COTTAGE",
    "ASHLAND/63RD": "ASHLAND/63",
    "FOREST PARK": "FOREST PK",
    "HARLEM/LAKE": "HARLEM",
    "54TH/CERMAK": "54TH",
    "UIC-HALSTED": "UIC",
}
STATION_SHORT = {
    "HAROLD WASHINGTON LIBRARY-STATE/VAN BUREN": "HW LIBRARY",
    "ILLINOIS MEDICAL DISTRICT": "MEDICAL DISTRICT",
    "CERMAK-MCCORMICK PLACE": "MCCORMICK PLACE",
    "35TH-BRONZEVILLE-IIT": "35TH-BRONZEVILLE",
}

PAD = 6               # scroll safe zone on each side
NAME_FONT = "5x7"     # station name and destinations
NUM_FONT = "10x10"    # hero minutes (8x10's slashed zero read "10" as "1Ø")
SMALL_FONT = "4x5"    # CTA tag, MIN unit, message subline
ROW_Y = [10, 21]      # 10px departure rows; 1px clear above, between, below
DEST_X = PAD + 9 + 4  # after the 9px train and a 4px gap

WHITE = "white"
GRAY = "gray"
AMBER = "#E8B04A"
SLATE = "#6A7090"

# Front of an 'L' car on its rail, 9x8: X body, W windshield, L headlights,
# R rail (the rail is what keeps it from reading as a bus).
TRAIN = """
.XXXXXXX.
XWWWWWWWX
XWWWWWWWX
XXXXXXXXX
XLXXXXXLX
XXXXXXXXX
.X.....X.
RRRRRRRRR
"""

# Convert "YYYYMMDD HH:MM:SS" -> seconds since 1970-01-01 (no time module).
# Uses the days-from-civil algorithm so it is correct across month/year/DST
# boundaries. Only used for arrT - tmst differences, so the absolute epoch
# offset cancels out anyway.
def _digits(s):
    out = ""
    for i in range(len(s)):
        ch = s[i]
        if ch >= "0" and ch <= "9":
            out += ch
    return out

def _to_epoch(s):
    # Accepts "YYYYMMDD HH:MM:SS" or ISO "YYYY-MM-DDTHH:MM:SS": keep digits only.
    ds = _digits(s)
    if len(ds) < 14:
        return 0
    y = int(ds[0:4])
    mo = int(ds[4:6])
    d = int(ds[6:8])
    h = int(ds[8:10])
    mi = int(ds[10:12])
    se = int(ds[12:14])

    yy = y - (1 if mo <= 2 else 0)
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * ((mo - 3) if mo > 2 else (mo + 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    days = era * 146097 + doe - 719468
    return days * 86400 + h * 3600 + mi * 60 + se

# The bitmap fonts have no apostrophe ("O'HARE" drew as OHARE), so names are
# drawn in parts with each apostrophe as a 1x2 tick and a pixel of space on
# either side. _name_w measures the same way, 3px per apostrophe.
def _name_w(c, s):
    parts = s.split("'")
    w = 0
    for p in parts:
        w += c.text_width(p, font = NAME_FONT)
    return w + 3 * (len(parts) - 1)

def _draw_name(c, s, x, y, col):
    parts = s.split("'")
    for i in range(len(parts)):
        if i > 0:
            c.vline(x + 1, y, 2, col)
            x += 3
        c.text(parts[i], x, y, font = NAME_FONT, color = col)
        x += c.text_width(parts[i], font = NAME_FONT)

# Widest prefix of s that fits max_w, without a dangling space or slash.
def _clip(c, s, max_w):
    for n in range(len(s), 0, -1):
        t = s[:n].rstrip(" /-('")
        if _name_w(c, t) <= max_w:
            return t
    return ""

# Full name if it fits; else drop a "(...)" tag, then the short form, then clip.
def _fit_name(c, s, short, max_w):
    s = s.upper()
    if _name_w(c, s) <= max_w:
        return s
    i = s.find(" (")
    if i > 0:
        s = s[:i]
    s = short.get(s, s)
    return _clip(c, s, max_w)

def _text_right(c, s, right, y, font, col):
    c.text(s, right - c.text_width(s, font = font) + 1, y, font = font, color = col)

# Station name, CTA tag, and a stripe with one segment per line at the station.
def _header(c, name, lines):
    right = c.width - 1 - PAD
    tw = c.text_width("CTA", font = SMALL_FONT)
    _text_right(c, "CTA", right, 1, SMALL_FONT, GRAY)
    _draw_name(c, _fit_name(c, name, STATION_SHORT, right - tw - PAD - 4), PAD, 0, WHITE)

    total = right - PAD + 1
    if len(lines) == 0:
        c.hline(PAD, 8, total, "darkgray")
        return
    seg = (total - (len(lines) - 1)) // len(lines)
    x = PAD
    for i in range(len(lines)):
        w = seg if i < len(lines) - 1 else right - x + 1
        c.hline(x, 8, w, LINE_COLORS.get(lines[i], WHITE))
        x += w + 1

# Two-line card in the content band (y 10-31): what happened, what next.
def _message(c, head, sub, col):
    c.text_center(head, 13, font = NAME_FONT, color = col)
    c.text_center(sub, 23, font = SMALL_FONT, color = SLATE)

# One departure row with its top at y: train, destination, minutes.
def _row(c, e, mins, y, dest_w):
    right = c.width - 1 - PAD
    col = LINE_COLORS.get(e.get("rt", ""), WHITE)
    c.sprite(TRAIN, PAD, y + 2, legend = {"X": col, "W": color.dim(col, 30), "L": WHITE, "R": "midgray"})

    if e.get("isApp", "0") == "1" or mins <= 0:
        _text_right(c, "DUE", right, y, NUM_FONT, "green")
    elif e.get("isDly", "0") == "1":
        _text_right(c, "DLY", right, y, NUM_FONT, "amber")
    else:
        uw = c.text_width("MIN", font = SMALL_FONT)
        _text_right(c, "MIN", right, y + 5, SMALL_FONT, GRAY)
        _text_right(c, str(min(mins, 99)), right - uw - 2, y, NUM_FONT, WHITE)

    dest = _fit_name(c, e.get("destNm") or "", DEST_SHORT, dest_w)
    _draw_name(c, dest, DEST_X, y + 3, WHITE)

# The next train to each destination, soonest first, two rows max. Trains
# ending their run here are skipped (at O'Hare nobody boards for O'Hare);
# a single-destination station fills the second row with its next train.
def _pick(rows, sta):
    live = [r for r in rows if (r[2].get("destNm") or "").upper() != sta.upper()]
    if len(live) == 0:
        live = rows
    firsts = []
    rest = []
    seen = {}
    for r in live:
        key = (r[2].get("rt") or "") + "|" + (r[2].get("destNm") or "")
        if key in seen:
            rest.append(r)
        else:
            seen[key] = True
            firsts.append(r)
    out = firsts[:2]
    for r in rest:
        if len(out) >= 2:
            break
        out.append(r)
    return sorted(out)

def main(c, ctx):
    c.clear()

    station = ctx.inputs.get("station", "Jarvis")
    mapid = STATIONS.get(station, STATIONS["Jarvis"])
    i = station.find(" (")
    label = station[:i] if i > 0 else station

    # The proxy edge-caches 60s and the manifest refreshes every 180s, so
    # each render gets a fresh board.
    resp = http.get(BASE_URL, params = {"mapid": mapid}, ttl_seconds = 60)
    body = resp["json"] if resp["status_code"] == 200 else None
    ctatt = body.get("ctatt") if type(body) == "dict" else None
    if type(ctatt) != "dict":
        _header(c, label, [])
        _message(c, "NO TRAIN DATA", "RETRYING SOON", AMBER)
        return

    err = str(ctatt.get("errCd") or "0")
    if err != "0":
        print("CTA errCd=" + err + " errNm=" + str(ctatt.get("errNm")))
        _header(c, label, [])
        _message(c, "CTA ERROR " + err, "RETRYING SOON", AMBER)
        return

    etas = ctatt.get("eta")
    if type(etas) == "dict":   # CTA returns a bare object when there's exactly 1
        etas = [etas]
    elif type(etas) != "list":
        etas = []

    # (minutes, index, eta) so sorted() orders by time without a lambda.
    now = _to_epoch(ctatt.get("tmst") or "")
    rows = []
    seen_lines = {}
    for i in range(len(etas)):
        e = etas[i]
        if type(e) != "dict":
            continue
        arr = _to_epoch(e.get("arrT") or "")
        if arr == 0 or now == 0:
            continue
        rows.append(((arr - now + 30) // 60, i, e))
        seen_lines[e.get("rt") or ""] = True
    rows = sorted(rows)
    lines = [rt for rt in LINE_ORDER if rt in seen_lines]

    sta = label
    if len(rows) > 0:
        sta = rows[0][2].get("staNm") or label
    _header(c, sta, lines)

    picked = _pick(rows, sta)
    if len(picked) == 0:
        _message(c, "NO TRAINS DUE", "CHECK BACK SOON", WHITE)
        return

    # Destinations get a fixed width, sized to the widest time ("88 MIN" or
    # DUE) plus a 5px gap, so a name never flips between long and short forms
    # as it counts down. At 3px, "FOREST PARK" ran into the 10x10 "13" (its
    # "1" flags left) and read as PARK13.
    right = c.width - 1 - PAD
    when_w = c.text_width("MIN", font = SMALL_FONT) + 2 + c.text_width("88", font = NUM_FONT)
    when_w = max(when_w, c.text_width("DUE", font = NUM_FONT))
    dest_w = right - when_w - 5 - DEST_X + 1

    for n in range(len(picked)):
        r = picked[n]
        _row(c, r[2], r[0], ROW_Y[n], dest_w)
