# CTA Train Times for Glance LED
#
# Shows the next arrivals for a whole CTA station (both directions) on the
# 128x32 panel. Data comes from the CTA Train Tracker "ttarrivals" endpoint.
#
# Layout (128 x 32):
#   row 0  (y=0):  station name, dim gray
#   rows 1-3:      up to 3 next arrivals -> [LINE] DESTINATION .... 3M / DUE
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

# rt code -> short label that fits the panel
LINE_LABELS = {
    "Red": "RED",
    "Blue": "BLU",
    "Brn": "BRN",
    "G": "GRN",
    "Org": "ORG",
    "P": "PUR",
    "Pink": "PNK",
    "Y": "YEL",
}

FONT = "5x7"       # header
ROW_FONT = "4x5"   # arrival rows (compact, so 4 fit under the header)
GRAY = "#888888"

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

# Trim text to the widest prefix that fits in max_w pixels.
def _fit(c, s, max_w):
    if c.text_width(s, font=ROW_FONT) <= max_w:
        return s
    for n in range(len(s), 0, -1):
        if c.text_width(s[:n], font=ROW_FONT) <= max_w:
            return s[:n]
    return ""

def main(c, ctx):
    c.fill("black")

    station = ctx.inputs.get("station", "Jarvis")
    mapid = STATIONS.get(station, "41190")

    resp = http.get(
        BASE_URL,
        params = {
            "mapid": mapid,
        },
        ttl_seconds = 60,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        c.text_center("CTA UNAVAILABLE", 12, font=FONT, color="red")
        return

    ctatt = resp["json"].get("ctatt", {})
    if ctatt.get("errCd", "0") != "0":
        print("CTA errCd=" + str(ctatt.get("errCd")) + " errNm=" + str(ctatt.get("errNm")))
        c.text_center("CTA ERR " + str(ctatt.get("errCd", "?")), 12, font=FONT, color="red")
        return

    etas = ctatt.get("eta", [])
    if type(etas) != "list":   # CTA returns a bare object when there's exactly 1
        etas = [etas]

    now = _to_epoch(ctatt.get("tmst", ""))

    # Build (minutes, index, eta) so sorted() orders by time without a lambda.
    rows = []
    for i in range(len(etas)):
        e = etas[i]
        mins = (_to_epoch(e.get("arrT", "")) - now + 30) // 60
        rows.append((mins, i, e))
    rows = sorted(rows)

    # Station header: centered, tinted with the soonest arrival's line color.
    # (Multi-line hubs follow whatever train is coming next.)
    if len(rows) > 0:
        sta = rows[0][2].get("staNm", station)
        head_color = LINE_COLORS.get(rows[0][2].get("rt", ""), "white")
    else:
        sta = station
        idx = sta.find(" (")        # strip the "(Brown)" tag from the dropdown label
        if idx > 0:
            sta = sta[:idx]
        head_color = GRAY
    c.text_center(sta.upper(), 0, font=FONT, color=head_color)

    if len(rows) == 0:
        c.text_center("NO TRAINS", 18, font=FONT, color=GRAY)
        return

    y = 8
    shown = 0
    for row in rows:
        if shown >= 4:
            break
        mins = row[0]
        e = row[2]

        rt = e.get("rt", "")
        label = LINE_LABELS.get(rt, rt.upper()[:3])
        color = LINE_COLORS.get(rt, "white")

        if e.get("isApp", "0") == "1" or mins <= 0:
            when = "DUE"
        elif e.get("isDly", "0") == "1":
            when = "DLY"
        else:
            when = str(int(mins)) + "M"

        # line badge (left)
        c.text(label, 1, y, font=ROW_FONT, color=color)

        # minutes (right-aligned)
        w = c.text_width(when, font=ROW_FONT)
        c.text(when, ctx.width - w, y, font=ROW_FONT, color=color)

        # destination (middle, trimmed to remaining space)
        dest = _fit(c, e.get("destNm", "").upper(), ctx.width - w - 21)
        c.text(dest, 18, y, font=ROW_FONT, color="white")

        y += 6
        shown += 1
