# Grid Carbon
#
# How clean the electricity coming out of the wall is right now: the share
# of the grid running on carbon-free sources, the carbon intensity of a
# kilowatt-hour, and what is actually generating it.
#
# Data, all keyless, one request per render:
#   GREAT BRITAIN  api.carbonintensity.org.uk - National Grid publishes the
#                  intensity directly in gCO2/kWh, measured, plus a named
#                  band. This is the only source here that does the carbon
#                  arithmetic for us.
#   CALIFORNIA     caiso.com/outlook/current/fuelsource.csv
#   TEXAS          ercot.com fuel-mix.json
#   NEW YORK       mis.nyiso.com rtfuelmix csv
#
# The three US grids publish a fuel mix in megawatts and no carbon figure,
# so the app computes one: megawatts per fuel times that fuel's lifecycle
# emissions factor, divided by total generation. The factors are National
# Grid's own published table (api.carbonintensity.org.uk/intensity/factors)
# so that a British number and a Texan number are built the same way. That
# makes the US figure an ESTIMATE, and the panel says EST next to it -
# it is a fuel-mix calculation, not a measurement.
#
# Imports and batteries are left out of the intensity sum rather than
# guessed at: CAISO reports both, and neither has a generation footprint
# of its own at the point it enters the grid. They still show in the mix.
#
# DESIGN. The number that matters is the clean share, so it is the hero -
# a big percentage with a ring of blocks around it that fills as the grid
# cleans up, green when most of the power is carbon-free, amber in the
# middle, red when it is mostly fossil. Beside it the intensity in
# gCO2/kWh with its band word. Page two is the mix itself: one bar per
# fuel, ordered biggest first, each in the colour that fuel has on every
# grid chart - wind teal, solar amber, nuclear violet, gas orange, coal
# dark red, hydro blue - so the shape of the grid reads without labels.
#
# Cadence: refresh 900. The British feed moves every half hour and the US
# grids every five minutes; fifteen minutes is honest for both and gentle
# on four different public servers.

UK_URL = "https://api.carbonintensity.org.uk/intensity"
UK_MIX = "https://api.carbonintensity.org.uk/generation"
CAISO_URL = "https://www.caiso.com/outlook/current/fuelsource.csv"
ERCOT_URL = "https://www.ercot.com/api/1/services/read/dashboards/fuel-mix.json"
NYISO_URL = "http://mis.nyiso.com/public/csv/rtfuelmix/"
HEADERS = {"User-Agent": "glance-grid-carbon (glance-led.dev)"}
TTL = 900

# ----------------------------------------------------------------- palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FAINT = "#333B4D"
OFFLINE = "#3C4043"
CLEAN = "#2FE06F"
MID = "#FFC219"
DIRTY = "#FF5A3C"

# Fuel -> [display name, colour, gCO2eq per kWh]. The factors are National
# Grid's published table, used for every region so the numbers compare.
FUELS = {
    "WIND": ["WIND", "#00C2C7", 0],
    "SOLAR": ["SOLAR", "#FFC219", 0],
    "NUCLEAR": ["NUCLEAR", "#B18CFF", 0],
    "HYDRO": ["HYDRO", "#2F8FFF", 0],
    "BIOMASS": ["BIOMASS", "#8FD130", 120],
    "GEOTHERMAL": ["GEOTHERM", "#E06BB0", 0],
    "GAS": ["GAS", "#FF8A1F", 394],
    "COAL": ["COAL", "#C0392B", 937],
    "OIL": ["OIL", "#8A5A2B", 935],
    "OTHER": ["OTHER", "#8A93A6", 300],
    "IMPORTS": ["IMPORTS", "#5C7A99", -1],
    "STORAGE": ["STORAGE", "#7FD4C1", -1],
}
# Anything with a zero factor and not imports or storage is carbon-free.
CLEAN_FUELS = ["WIND", "SOLAR", "NUCLEAR", "HYDRO", "GEOTHERMAL"]

REGIONS = {
    "GREAT BRITAIN": ["UK", "GB"],
    "CALIFORNIA": ["CAISO", "CAL"],
    "TEXAS": ["ERCOT", "TEX"],
    "NEW YORK": ["NYISO", "NY"],
}

# ------------------------------------------------------------- text tools
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

HEXD = "0123456789abcdef"

def ink_for(fill):
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def pill(c, word, fill, x, y):
    return c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

# ----------------------------------------------------------------- numbers
def to_num(s):
    """A CSV or JSON number as tenths, or None. Handles a leading minus,
    which CAISO uses for batteries charging and for net imports."""
    t = str(s).strip()
    if t == "" or t == "-":
        return None
    neg = t.startswith("-")
    if neg:
        t = t[1:]
    parts = t.split(".")
    whole = parts[0]
    if whole == "":
        whole = "0"
    for ch in whole.elems():
        if ch < "0" or ch > "9":
            return None
    tenths = int(whole) * 10
    if len(parts) > 1 and len(parts[1]) > 0 and parts[1][0] >= "0" and parts[1][0] <= "9":
        tenths += int(parts[1][0])
    return -tenths if neg else tenths

def pct_text(n):
    return str(n) + "%"

def band_for(pct):
    if pct >= 60:
        return CLEAN
    if pct >= 30:
        return MID
    return DIRTY

def intensity_word(g):
    """National Grid's own bands, so the word and the number agree."""
    if g < 0:
        return ""
    if g <= 34:
        return "VERY LOW"
    if g <= 109:
        return "LOW"
    if g <= 189:
        return "MODERATE"
    if g <= 270:
        return "HIGH"
    return "VERY HIGH"

# ------------------------------------------------------------------- feeds
def add(mix, fuel, mw_tenths):
    if mw_tenths == None:
        return
    mix[fuel] = get(mix, fuel, 0) + mw_tenths

def parse_csv_row(line):
    out, cur, q = [], "", False
    for ch in line.elems():
        if ch == "\"":
            q = not q
        elif ch == "," and not q:
            out.append(cur)
            cur = ""
        else:
            cur += ch
    out.append(cur)
    return out

CAISO_MAP = {"SOLAR": "SOLAR", "WIND": "WIND", "GEOTHERMAL": "GEOTHERMAL", "BIOMASS": "BIOMASS",
             "BIOGAS": "BIOMASS", "SMALL HYDRO": "HYDRO", "COAL": "COAL", "NUCLEAR": "NUCLEAR",
             "NATURAL GAS": "GAS", "LARGE HYDRO": "HYDRO", "BATTERIES": "STORAGE",
             "IMPORTS": "IMPORTS", "OTHER": "OTHER"}
ERCOT_MAP = {"COAL AND LIGNITE": "COAL", "HYDRO": "HYDRO", "NUCLEAR": "NUCLEAR", "POWER STORAGE": "STORAGE",
             "SOLAR": "SOLAR", "WIND": "WIND", "NATURAL GAS": "GAS", "OTHER": "OTHER"}
NYISO_MAP = {"DUAL FUEL": "GAS", "NATURAL GAS": "GAS", "NUCLEAR": "NUCLEAR", "HYDRO": "HYDRO",
             "WIND": "WIND", "OTHER RENEWABLES": "BIOMASS", "OTHER FOSSIL FUELS": "OIL"}
UK_MAP = {"BIOMASS": "BIOMASS", "COAL": "COAL", "IMPORTS": "IMPORTS", "GAS": "GAS",
          "NUCLEAR": "NUCLEAR", "OTHER": "OTHER", "HYDRO": "HYDRO", "SOLAR": "SOLAR",
          "WIND": "WIND"}

def fetch_caiso():
    r = http.get(CAISO_URL, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] != 200:
        return [None, r["status_code"]]
    lines = [l for l in r["body"].split("\n") if l.strip() != ""]
    if len(lines) < 2:
        return [None, -1]
    head = parse_csv_row(lines[0])
    # The file is the whole day so far; the last row is now.
    row = parse_csv_row(lines[len(lines) - 1])
    mix, stamp = {}, ""
    for i in range(len(head)):
        name = head[i].strip().upper()
        if i >= len(row):
            break
        if name == "TIME":
            stamp = row[i].strip()
            continue
        add(mix, get(CAISO_MAP, name, "OTHER"), to_num(row[i]))
    return [[mix, stamp], 200]

def fetch_ercot():
    r = http.get(ERCOT_URL, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return [None, r["status_code"]]
    data = get(r["json"], "data", {})
    if type(data) != "dict" or len(data) == 0:
        return [None, -1]
    day_key = ""
    for k in data:
        if day_key == "" or k > day_key:
            day_key = k
    day = get(data, day_key, {})
    ts_key = ""
    for k in day:
        if ts_key == "" or k > ts_key:
            ts_key = k
    slot = get(day, ts_key, {})
    mix = {}
    for name in slot:
        gen = dig(slot, [name, "gen"], None)
        if type(gen) == "int" or type(gen) == "float":
            add(mix, get(ERCOT_MAP, name.upper(), "OTHER"), int(gen * 10))
    return [[mix, ts_key[11:16] if len(ts_key) >= 16 else ""], 200]

def pad(n):
    return str(n) if n >= 10 else "0" + str(n)

def fetch_nyiso(ctx):
    n = ctx.now
    url = NYISO_URL + str(n.year) + pad(n.month) + pad(n.day) + "rtfuelmix.csv"
    r = http.get(url, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] != 200:
        return [None, r["status_code"]]
    lines = [l for l in r["body"].split("\n") if l.strip() != ""]
    if len(lines) < 2:
        return [None, -1]
    # Every five minutes the file appends one row per fuel; take the rows
    # sharing the newest timestamp.
    last_stamp = parse_csv_row(lines[len(lines) - 1])[0].strip()
    mix = {}
    for i in range(len(lines) - 1, 0, -1):
        row = parse_csv_row(lines[i])
        if len(row) < 4 or row[0].strip() != last_stamp:
            break
        add(mix, get(NYISO_MAP, row[2].strip().upper(), "OTHER"), to_num(row[3]))
    return [[mix, last_stamp[11:16] if len(last_stamp) >= 16 else ""], 200]

def fetch_uk():
    r = http.get(UK_MIX, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return [None, r["status_code"]]
    gen = dig(r["json"], ["data", "generationmix"], [])
    if type(gen) != "list" or len(gen) == 0:
        return [None, -1]
    # The British feed gives percentages, not megawatts. Percent is what
    # the panel draws anyway, so they go in as tenths of a percent.
    mix = {}
    for row in gen:
        add(mix, get(UK_MAP, str(get(row, "fuel", "")).upper(), "OTHER"), to_num(get(row, "perc", 0)))
    stamp = str(dig(r["json"], ["data", "to"], ""))
    return [[mix, stamp[11:16] if len(stamp) >= 16 else ""], 200]

def fetch(ctx):
    label = str(ctx.inputs.get("region", "GREAT BRITAIN")).strip().upper()
    if label not in REGIONS:
        label = "GREAT BRITAIN"
    reg = REGIONS[label]
    base = {"region": label, "grid": reg[0], "short": reg[1]}

    if reg[0] == "UK":
        res = fetch_uk()
    elif reg[0] == "CAISO":
        res = fetch_caiso()
    elif reg[0] == "ERCOT":
        res = fetch_ercot()
    else:
        res = fetch_nyiso(ctx)
    if res[0] == None:
        if res[1] == 0:
            return dict(base, ok = False, head = reg[1] + " GRID OFFLINE", sub = "RETRY IN 15 MIN")
        return dict(base, ok = False, head = "GRID FEED ERROR",
                    sub = ("HTTP " + str(res[1]) if res[1] > 0 else "NOTHING PUBLISHED YET"))
    mix, stamp = res[0][0], res[0][1]

    # Generation only: imports and storage are real power but carry no
    # generation footprint here, so they are shown and not scored.
    total, clean_mw, carbon = 0, 0, 0
    for fuel in mix:
        mw = mix[fuel]
        if mw <= 0:
            continue
        if fuel == "IMPORTS" or fuel == "STORAGE":
            continue
        total += mw
        if fuel in CLEAN_FUELS:
            clean_mw += mw
        carbon += mw * FUELS[fuel][2]
    if total <= 0:
        return dict(base, ok = False, head = "NO GENERATION DATA", sub = "THE FEED CAME BACK EMPTY")

    bars = []
    for fuel in mix:
        if mix[fuel] > 0:
            bars.append([fuel, mix[fuel]])
    for i in range(1, len(bars)):
        k = i
        for step in range(i):
            if k > 0 and bars[k][1] > bars[k - 1][1]:
                bars[k], bars[k - 1] = bars[k - 1], bars[k]
                k -= 1

    measured = None
    if reg[0] == "UK":
        n = http.get(UK_URL, headers = HEADERS, ttl_seconds = TTL)
        if n["status_code"] == 200 and type(n["json"]) == "dict":
            actual = dig(n["json"], ["data", 0, "intensity", "actual"], None)
            if actual == None:
                arr = dig(n["json"], ["data"], [])
                if type(arr) == "list" and len(arr) > 0:
                    actual = dig(arr[0], ["intensity", "actual"], dig(arr[0], ["intensity", "forecast"], None))
            if type(actual) == "int":
                measured = actual

    return dict(base, ok = True, mix = mix, bars = bars, stamp = stamp, gen_total = total,
                clean = (clean_mw * 100 + total // 2) // total,
                gco2 = measured if measured != None else (carbon // total + 5) // 10 * 10 // 1,
                estimated = measured == None,
                total_mw = total // 10)

# ---------------------------------------------------------------- chrome
def chip_row(c, d, right, left = 10):
    w = pill(c, d["short"], "#5C9BE8", left, 0)
    x = left + w + 3
    rw = c.text_width(right, "4x5")
    c.text(right, 181, 1, font = "4x5", color = DIM, align = "right")
    for label in [d["region"] + " GRID", d["region"], d["short"]]:
        if c.text_width(label, "4x5") <= 181 - rw - 5 - x + 1:
            c.text(label, x, 1, font = "4x5", color = INK)
            return

def fail_screen(c, d):
    c.fill("black")
    rail(c, OFFLINE)
    hf = fit(c, d["head"], ["6x8", "5x7", "4x5"], 172)
    c.text(hf[1], 96, 10, font = hf[0], color = "amber", align = "center")
    sf = fit(c, d["sub"], ["4x5", "picopixel"], 172)
    c.text(sf[1], 96, 22, font = sf[0], color = DIM, align = "center")

# ------------------------------------------------------------- page: now
def now(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    col = band_for(d["clean"])
    rail(c, col)
    chip_row(c, d, (d["stamp"] if d["stamp"] != "" else "LIVE"), 10 + c.text_width("CARBON FREE", "4x5") + 4)

    # The clean share is the hero, with a meter under it that fills the
    # same way, so the number and the picture cannot disagree.
    # The hero sits in y 8..22 and its label goes beside it, not under it:
    # a 16x20 face reaches y 22, and CARBON FREE at y 27 was being cut
    # through by the digits above it.
    # CARBON FREE goes above the number, not below it: a 16x20 face lights
    # rows 8..27 here, and the label underneath was being cut through by
    # the digits every render.
    c.text("CARBON FREE", 10, 1, font = "4x5", color = DIM)
    txt = pct_text(d["clean"])
    c.text(txt, 10, 9, font = "16x20", color = col)
    w = c.text_width(txt, "16x20")

    mx = 10 + w + 8
    if mx < 96:
        mx = 96
    c.rect(mx, 8, 181, 17, fill = "#11151F")
    fillw = (181 - mx + 1) * d["clean"] // 100
    if fillw > 0:
        c.rect(mx, 8, mx + fillw - 1, 17, fill = col)

    # The band word is placed first and the unit fitted into what is left,
    # so 388 G CO2/KWH and VERY HIGH can never run through each other.
    edge = 181
    tail = ("EST" if d["estimated"] else intensity_word(d["gco2"]))
    if tail != "":
        c.text(tail, 181, 25, font = "4x5", color = DIM if d["estimated"] else col, align = "right")
        edge = 181 - c.text_width(tail, "4x5") - 5
    g = str(d["gco2"])
    c.text(g, mx, 21, font = "6x8", color = INK)
    gx = mx + c.text_width(g, "6x8") + 3
    for unit in ["G CO2/KWH", "G CO2", "G"]:
        if gx + c.text_width(unit, "4x5") - 1 <= edge:
            c.text(unit, gx, 25, font = "4x5", color = DIM)
            break

# ------------------------------------------------------------- page: mix
def mix(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail_screen(c, d)
        return
    c.fill("black")
    rail(c, band_for(d["clean"]))
    chip_row(c, d, pct_text(d["clean"]) + " CLEAN")

    # Shares are taken over generation only - the same base the carbon
    # figure uses - so the two pages cannot disagree. Imports and storage
    # still get a bar; they are simply measured against generation.
    total = d["gen_total"]
    if total <= 0:
        fail_screen(c, dict(d, head = "NO GENERATION DATA", sub = "THE FEED CAME BACK EMPTY"))
        return

    # Four fuels, biggest first, on an 6 px pitch: name, bar, share.
    shown = d["bars"][:4]
    for i in range(len(shown)):
        fuel, mw = shown[i][0], shown[i][1]
        y = 8 + i * 6
        f = FUELS[fuel]
        share = (mw * 100 + total // 2) // total
        ps = pct_text(share)
        pw = c.text_width(ps, "4x5")
        c.text(f[0], 10, y, font = "4x5", color = INK)
        bx = 10 + 40
        room = 181 - pw - 4 - bx
        bw = room * (share if share <= 100 else 100) // 100
        if bw > 0:
            c.rect(bx, y, bx + bw - 1, y + 4, fill = f[1])
        c.text(ps, 181, y, font = "4x5", color = DIM, align = "right")
