# ---------------------------------------------------------------- house kit
# The chrome every Glance app in this family shares: a coloured page tab, a
# full-height accent rail, one failure screen, and the text helpers that keep a
# long string from running off a panel that does not clip.

STRUCT = "darkgray"        # dividers, tracks, spines
OFFLINE = "#3C4043"        # the rail when there is no data
INK = "#F4F7FF"            # primary text
DIM = "#6E7A94"            # secondary text

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it draws anyway -- which is how a long name ends up running
    through whatever is beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    """Like clip(), but backs up to the last whole word -- unless that costs
    more than 30% of what fit. "DAILY STANDUP" cut to "DAILY" loses the word
    that identified it; better to show an obviously clipped "DAILY STANDU"."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[:sp]
    return t

def fit(c, text, fonts, maxw):
    """[font, clipped text] for the largest listed font that fits.

    8x12 is skipped for any string containing a hyphen. That font's '-' glyph
    is a solid 6x12 block rather than a dash -- verified against the panel's own
    bitmap_8x12.php, so it is the hardware font that is wrong, not the SDK's
    copy of it. Date ranges, scores and time spans all carry hyphens, so this
    would otherwise turn "11A-1P" into "11A<block>1P" at the one size most
    likely to be chosen for a hero."""
    t = str(text)
    dashed = t.find("-") >= 0
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if dashed and f == "8x12":
            continue
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    if dashed and pick == "8x12":
        pick = "6x8"
    return [pick, clip(c, text, pick, maxw)]

def tab(c, word, accent, x = 4):
    """The page chip. Same object, same place, on every page of every app."""
    w = c.badge(word, x, 0, color = "black", bg = accent, font = "4x5")
    return x + w + 1

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def message(c, head, sub, head_color = "amber"):
    """The one screen every failure state shares."""
    c.text(clip(c, head, "5x7", c.width - 4), c.width // 2, 11, font = "5x7",
           color = head_color, align = "center")
    if sub != "":
        c.text(clip(c, sub, "4x5", c.width - 4), c.width // 2, 23, font = "4x5",
               color = "gray", align = "center")

def pct_bar(c, x, y, w, h, pct, color, bg = STRUCT):
    """progress_bar, but it never draws a 0-width sliver as if it were 1."""
    c.rect(x, y, x + w - 1, y + h - 1, fill = bg)
    n = int(w * pct / 100.0 + 0.5)
    if n > 0:
        c.rect(x, y, x + (n if n <= w else w) - 1, y + h - 1, fill = color)

# ------------------------------------------------------------ safe fetching
def num(s, fallback = -1):
    """int() raises on anything non-numeric, and a raised host error kills the
    whole render, so every number out of a feed comes through here."""
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    d = ""
    for ch in t.elems():
        if ch >= "0" and ch <= "9":
            d += ch
    if d == "" or len(d) != len(t):
        return fallback
    v = int(d)
    return -v if neg else v

def intpart(s, fallback = 0):
    """Whole-number part of a value that may arrive as a decimal.

    ADS-B ground speed comes back as 275.5 and altitude as 4600, from the same
    feed. num() rejects anything with a dot, so reading gs with it turned every
    aircraft's speed into 0 -- a wrong number that looks like a real one."""
    t = str(s).strip()
    return num(t.split(".")[0], fallback)

def dec(s, places, fallback = None):
    """A decimal string -> int scaled by 10^places, or fallback. Starlark has
    floats, but feeds hand back "27.573" as a string and int() will not take
    it; this keeps the arithmetic exact and the failure quiet."""
    t = str(s).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    parts = t.split(".")
    if len(parts) > 2:
        return fallback
    whole = num(parts[0], -1) if parts[0] != "" else 0
    if whole < 0:
        return fallback
    frac = 0
    if len(parts) == 2:
        f = parts[1]
        for i in range(places):
            f = f + "0"
        f = f[:places]
        frac = num(f, -1)
        if frac < 0:
            return fallback
    else:
        for i in range(places):
            whole = whole * 10
        return -whole if neg else whole
    scaled = whole
    for i in range(places):
        scaled = scaled * 10
    scaled = scaled + frac
    return -scaled if neg else scaled

def get(obj, key, fallback = None):
    """dict.get that survives a null parent, which JSON feeds hand back often."""
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    """get() down a chain: dig(ev, ["status", "type", "state"], "")."""
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

def ents(s):
    """Decode the handful of HTML entities that show up in plain-text feeds."""
    t = str(s)
    t = t.replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">")
    return t.replace("&quot;", '"').replace("&#39;", "'").replace("&nbsp;", " ")

# --------------------------------------------------------------------- time
def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + 1 if m <= 2 else y, m, d]

def weekday(z):
    """0 = Monday .. 6 = Sunday. Day 0 (1970-01-01) was a Thursday."""
    return (z + 3) % 7

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

def parse_iso(s, offmin):
    """Minutes since epoch, in the viewer's wall clock, from an ISO stamp.
    A trailing Z means real UTC and gets the offset; anything else is treated
    as already-local, which is right for feeds that carry a zone."""
    t = str(s).strip()
    if len(t) < 10:
        return None
    y, mo, d = num(t[0:4]), num(t[5:7]), num(t[8:10])
    if y < 1970 or mo < 1 or mo > 12 or d < 1 or d > 31:
        return None
    mins = days_from_civil(y, mo, d) * 1440
    if len(t) >= 16 and t[10] == "T":
        hh, mi = num(t[11:13]), num(t[14:16])
        if hh < 0 or hh > 23 or mi < 0 or mi > 59:
            return None
        mins += hh * 60 + mi
        if t.endswith("Z"):
            mins += offmin
    return mins

def parse_offset(raw):
    """Hours from UTC, as minutes. Free text, so "EST" lands here too."""
    t = str(raw).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    t = t.split(":")[0].split(".")[0].strip()
    d = ""
    for ch in t.elems():
        if ch >= "0" and ch <= "9":
            d += ch
    if d == "":
        return 0
    h = int(d)
    if h > 14:
        h = 14
    return (-h if neg else h) * 60

def clock(mins, ampm = True, compact = False):
    """2:30P / 9:00A -- 12-hour, no leading zero, one-letter meridiem."""
    tod = mins % 1440
    h, m = tod // 60, tod % 60
    ap = "P" if h >= 12 else "A"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    if compact and m == 0:
        return str(h12) + ap if ampm else str(h12)
    out = str(h12) + ":" + fmt.pad(m)
    return out + ap if ampm else out

def ago(mins):
    """A short "how long since" for a positive minute count."""
    if mins < 1:
        return "NOW"
    if mins < 60:
        return str(mins) + "M"
    if mins < 1440:
        return str(mins // 60) + "H"
    return str(mins // 1440) + "D"

# ---- the aircraft ---------------------------------------------------------
# `track` arrives as a real bearing in degrees (318.09, not "NW"), and the old
# app threw that away by bucketing to eight compass points and drawing a 5x5
# blob.
#
# Getting a 16px aircraft to point at 318.09 degrees took three attempts.
#
#   1. Rotate a sprite. Nearest-neighbour resampling breaks every 1px feature
#      into dashes; anything smoother turns a hard-edged silhouette to mush.
#   2. Sixteen bearings from three masters via the square's symmetries. Exact,
#      but 16 fixed angles and 48 sprites for three families.
#   3. Draw the outline from rotated lines. Clean at the cardinals, a scarecrow
#      at every diagonal -- a skeleton of 1px strokes has nothing holding it
#      together once the strokes stop being horizontal and vertical.
#
# What actually works is to stop drawing lines and describe the aircraft as an
# AREA. The silhouette is a set of inequalities in the aircraft's own frame --
# a tapered fuselage, two swept trapezoid wings, a tailplane -- and the panel
# is rasterised by walking the pixels the aircraft could cover and asking each
# one "in the aircraft's frame, am I inside it?". Solid shapes survive rotation
# the way outlines do not: there is nothing to disconnect, no feature thinner
# than the shape itself, and the angle is exact rather than snapped.
#
#   panel -> body:  u = fx*px + fy*py,  v = fx*py - fy*px
#   where f = (sin B, -cos B) is the nose direction, u runs toward the nose and
#   v to the starboard wing.

DEG = 3.141592653589793 / 180.0

# family -> [nose, tail, body half-width, half-span, wing station, root chord,
#            tip chord, sweep, tail half-span, tail station, tail root chord,
#            tail tip chord, tail sweep, engines per side]
#
# The proportions are real ones. A 737 is about as long as its span; a 777 is
# longer than it is wide and carries visible nacelles; a Cessna has a stubby
# nose, a long tail moment and a straight wing set high and forward. Those
# three silhouettes are distinguishable at 16 pixels, which is the whole point
# of having families at all.
SHAPES = {
    "jet":   [7.5, 6.5, 1.3, 7.5, 0.0, 4.6, 1.5, 2.8, 3.4, -5.0, 2.4, 1.0, 1.3, 0],
    "heavy": [9.0, 7.5, 1.4, 8.8, -0.4, 4.8, 1.6, 2.9, 4.0, -6.0, 2.6, 1.1, 1.4, 2],
    "light": [4.6, 6.6, 1.4, 6.8, 2.2, 3.2, 2.6, 0.2, 3.2, -5.6, 2.4, 1.8, 0.2, 0],
}

def family_for(cat, typ):
    """ADS-B emitter category first, type code as a fallback. A7 is the only
    unambiguous rotorcraft signal in the feed; A5 and A4 are the wide-bodies."""
    ca = str(cat).upper()
    if ca == "A7":
        return "rotor"
    if ca == "A5" or ca == "A4":
        return "heavy"
    if ca == "A1" or ca == "B1" or ca == "B4":
        return "light"
    t = str(typ).upper()
    if t.startswith("R") or t.startswith("EC") or t.startswith("B4") or t.startswith("S7"):
        return "rotor"
    if t.startswith("C1") or t.startswith("P2") or t.startswith("PA") or t.startswith("SR"):
        return "light"
    for h in ["B74", "B77", "B78", "B76", "A38", "A35", "A33", "A34", "MD1", "IL9"]:
        if t.startswith(h):
            return "heavy"
    return "jet"

def _in_body(u, v, nose, tail, bw):
    """Fuselage: full width through the middle, tapering to a point at the nose
    and to a stub at the tail."""
    if u > nose or u < -tail:
        return False
    w = bw
    nt = nose * 0.5
    if u > nose - nt:
        w = bw * (nose - u) / nt
    tt = tail * 0.45
    if u < -tail + tt:
        w2 = bw * 0.45 + bw * 0.55 * (u + tail) / tt
        if w2 < w:
            w = w2
    d = v if v >= 0 else -v
    return d <= w

def _in_wing(u, v, span, st, croot, ctip, sweep):
    """A swept, tapered trapezoid either side of the body. The chord shrinks
    and the whole panel slides aft as you go outboard, which is the one cue
    that says 'airliner' rather than 'plus sign'."""
    if span <= 0:
        return False
    t = v if v >= 0 else -v
    if t > span:
        return False
    f = t / span
    d = u - (st - sweep * f)
    if d < 0:
        d = -d
    return d <= (croot + (ctip - croot) * f) / 2.0

def draw_aircraft(c, cx, cy, bearing, fam, col, scale = 1.0):
    """Top-down aircraft centred on (cx, cy) pointing at `bearing` degrees,
    0 = north, clockwise. `bearing` may be None for something on the ground
    with no heading; the caller decides what to draw instead, because pointing
    north and inventing a heading would be a lie."""
    s = SHAPES[fam] if fam in SHAPES else SHAPES["jet"]
    a = bearing * DEG
    fx, fy = math.sin(a), -math.cos(a)

    nose, tail, bw = s[0] * scale, s[1] * scale, s[2] * scale
    span, wst = s[3] * scale, s[4] * scale
    croot, ctip, sweep = s[5] * scale, s[6] * scale, s[7] * scale
    tspan, tst = s[8] * scale, s[9] * scale
    tcroot, tctip, tsweep = s[10] * scale, s[11] * scale, s[12] * scale
    if bw < 0.5:
        bw = 0.5

    # Reach of the shape in its own frame, which bounds the pixels worth
    # testing. Nothing outside this square can possibly be inside the aircraft.
    r = nose
    for v in [tail, span, tspan]:
        if v > r:
            r = v
    r = int(r + 1.5)

    ix, iy = int(cx), int(cy)
    # Four sub-samples per pixel rather than one at the centre, lit when at
    # least two land inside the shape.
    #
    # Testing only the centre made the silhouette depend on exactly where the
    # pixel grid happened to fall across an edge, so the same aircraft came out
    # clean at one bearing and lumpy and asymmetric at another -- a wing would
    # gain a pixel on one side and lose one on the other. Sampling the corners
    # of each pixel instead averages that out: edges land in the same place
    # whichever way the aircraft is pointing, which is what makes a 16px
    # silhouette read as a shape instead of a smudge.
    offs = [[-0.25, -0.25], [0.25, -0.25], [-0.25, 0.25], [0.25, 0.25]]
    for py in range(-r, r + 1):
        y = iy + py
        if y < 0 or y >= c.height:
            continue
        for px in range(-r, r + 1):
            x = ix + px
            if x < 0 or x >= c.width:
                continue
            hits = 0
            for o in offs:
                sx, sy = px + o[0], py + o[1]
                u = fx * sx + fy * sy
                v = fx * sy - fy * sx
                if _in_body(u, v, nose, tail, bw):
                    hits += 1
                elif _in_wing(u, v, span, wst, croot, ctip, sweep):
                    hits += 1
                elif _in_wing(u, v, tspan, tst, tcroot, tctip, tsweep):
                    hits += 1
            if hits >= 2:
                c.pixel(x, y, col)

    # Nacelles, on the wide-bodies only. Two dots a side is the difference
    # between "a plane" and "a big plane" at this size.
    if s[13] > 0 and scale > 0.7:
        for sg in [-1, 1]:
            for off in [0.4, 0.68]:
                bu = wst - sweep * off + croot * 0.35
                bv = span * off * sg
                c.pixel(int(cx + fx * bu - fy * bv), int(cy + fy * bu + fx * bv), col)

def draw_rotor(c, cx, cy, bearing, col, blade_col, scale = 1.0):
    """A rotorcraft from above: a dotted disc, a cabin, a thin boom and a tail
    rotor. The disc is a ring of dots rather than two crossed lines -- crossed
    lines just read as an X, and a solid ring reads as a no-entry sign, but a
    broken ring reads as something spinning. It does not turn with the heading,
    because it is spinning and any angle would be honest; the cabin and the
    boom do, and that is what says where the thing is going."""
    b = (bearing if bearing != None else 0.0) * DEG
    fx, fy = math.sin(b), -math.cos(b)
    dr = 7.0 * scale
    for k in range(0, 360, 30):
        a = k * DEG
        c.pixel(int(cx + math.sin(a) * dr), int(cy - math.cos(a) * dr), blade_col)
    tx, ty = cx - fx * 7.5 * scale, cy - fy * 7.5 * scale
    c.line(int(cx - fx * 1.5 * scale), int(cy - fy * 1.5 * scale),
           int(tx), int(ty), col)
    t = 2.0 * scale
    c.line(int(tx - fy * t), int(ty + fx * t),
           int(tx + fy * t), int(ty - fx * t), col)
    c.fill_circle(int(cx + fx * scale), int(cy + fy * scale),
                  2 if scale > 0.7 else 1, col)
    c.pixel(int(cx + fx * 3.6 * scale), int(cy + fy * 3.6 * scale), col)

# ---- data -----------------------------------------------------------------
ADSB = "https://api.adsb.lol/v2/point/"
ADSBDB = "https://api.adsbdb.com/v0/callsign/"
ZIP = "https://api.zippopotam.us/us/"

# Altitude bands. The colour says how high without reading a number, and it is
# the same colour the aircraft is drawn in on both pages.
BANDS = [
    [1500, "#FF4FCB", "PATTERN"],
    [5000, "#FF6A00", "LOW"],
    [12000, "#FFB300", "CLIMB"],
    [24000, "#7FE9FF", "MID"],
    [99000, "#78DCFF", "HIGH"],
]

def band_of(alt):
    for b in BANDS:
        if alt <= b[0]:
            return b
    return BANDS[len(BANDS) - 1]

def kt_to_mph(kt):
    return kt * 1151 // 1000

def nm10_to_mi10(t):
    """Tenths of a nautical mile -> tenths of a statute mile. adsb.lol works in
    nautical miles throughout; nobody standing under an aircraft does."""
    return t * 1151 // 1000

def read_sky(ctx):
    zipc = str(ctx.inputs.get("zip", "")).strip()
    radius = num(ctx.inputs.get("radius", "20"), 20)
    if radius < 5:
        radius = 5
    if radius > 250:
        radius = 250
    # The endpoint's radius argument is nautical miles, so a user asking for
    # 20 miles was quietly getting 23. Convert on the way in, and back on the
    # way out, and the panel only ever says miles.
    rad_nm = radius * 1000 // 1151
    if rad_nm < 4:
        rad_nm = 4
    st = {"state": "ok", "planes": [], "zip": zipc, "radius": radius,
          "rad_nm": rad_nm, "place": "", "lat": 0.0, "lon": 0.0,
          "now": ctx.now.unix // 60}
    if zipc == "":
        st["state"] = "setup"
        return st

    z = http.get(ZIP + zipc, ttl_seconds = 86400)
    if z["status_code"] != 200 or z["json"] == None:
        st["state"] = "badzip"
        return st
    places = get(z["json"], "places", [])
    if type(places) != "list" or len(places) == 0:
        st["state"] = "badzip"
        return st
    p0 = places[0]
    lat = str(get(p0, "latitude", ""))
    lon = str(get(p0, "longitude", ""))
    st["place"] = str(get(p0, "place name", "")).upper()
    # The scope plots true relative bearing, so the observer's position has to
    # survive as a number rather than the string the ZIP service hands back.
    la, lo = dec(lat, 4), dec(lon, 4)
    st["lat"] = la / 10000.0 if la != None else 0.0
    st["lon"] = lo / 10000.0 if lo != None else 0.0

    r = http.get(ADSB + lat + "/" + lon + "/" + str(rad_nm), ttl_seconds = 60)
    if r["status_code"] != 200 or r["json"] == None:
        st["state"] = "offline"
        return st
    for a in get(r["json"], "ac", []):
        if type(a) != "dict":
            continue
        alt_raw = a.get("alt_baro", None)
        # alt_baro is feet OR the literal string "ground". Treating that string
        # as a number is how an app ends up drawing a taxiing jet at 0 feet in
        # the middle of the sky.
        on_ground = str(alt_raw).lower() == "ground"
        alt = 0 if on_ground else num(alt_raw, -1)
        if alt < 0 and not on_ground:
            continue
        track = a.get("track", None)
        rate = a.get("baro_rate", a.get("geom_rate", None))
        st["planes"].append({
            # Military and blocked aircraft come through with no callsign, no
            # registration and no type. The ICAO hex is always there, and
            # "A4C1B2" is a real thing a spotter can look up; "UNKNOWN" is not.
            "hex": str(get(a, "hex", "")).strip().upper(),
            "reg": str(get(a, "r", "")).strip().upper(),
            "call": str(get(a, "flight", "")).strip().upper(),
            "type": str(get(a, "t", "")).strip().upper(),
            "cat": str(get(a, "category", "")).strip().upper(),
            "alt": alt, "ground": on_ground,
            "track": track,
            "rate": intpart(rate, 0) if rate != None else 0,
            "gs": intpart(get(a, "gs", 0), 0),
            "dst": nm10_to_mi10(dec(str(get(a, "dst", "0")), 1) or 0),
            "lat": a.get("lat", None), "lon": a.get("lon", None),
            "squawk": str(get(a, "squawk", "")).strip(),
            "seen": num(get(a, "seen", 0), 0),
        })
    if len(st["planes"]) == 0:
        st["state"] = "empty"
        return st
    st["planes"] = sorted(st["planes"], key = interest)
    return st

def emergency(p):
    """7500 hijack, 7600 radio failure, 7700 general emergency. These are the
    only three squawks worth interrupting a panel for."""
    return p["squawk"] in ["7500", "7600", "7700"]

def interest(p):
    """Lower sorts first. An emergency squawk outranks everything; after that
    the interesting aircraft is the close, low one -- something at 38,000ft
    passing overhead is not what a person looks up at."""
    if emergency(p):
        return -1000000
    if p["ground"]:
        return 900000 + p["dst"]
    return p["alt"] // 100 + p["dst"] * 3

def route_for(call):
    """Origin and destination for a callsign, or None. adsbdb answers for
    airline flights and 404s for private ones, which is most of the sky."""
    if call == "":
        return None
    r = http.get(ADSBDB + call, ttl_seconds = 3600)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    fr = dig(r["json"], ["response", "flightroute"], None)
    if fr == None:
        return None
    o = dig(fr, ["origin", "iata_code"], "")
    d = dig(fr, ["destination", "iata_code"], "")
    if o == "" or d == "":
        return None
    return [str(o).upper(), str(d).upper(),
            str(dig(fr, ["airline", "name"], "")).upper()]

def miles(t):
    """Tenths of a mile -> a string with one decimal place. Starlark has no
    float formatting, so the tenths are split out by hand."""
    return str(t // 10) + "." + str(t % 10)

# ---- pages ----------------------------------------------------------------
# One idea holds the whole app together: the middle of the panel is a
# cross-section of your airspace, seen from the side. The aircraft's height on
# the panel, the tape down the right edge and the rooftops along the bottom all
# sit on ONE altitude axis. A red-eye slides along the top of the frame; an
# arrival sinks toward the roofs. You read the altitude the way you would read
# it out of a window, before any number reaches you.
#
# The axis is square-root scaled, which spends its fourteen usable rows below
# 10,000ft where the drama is: 1,200 and 4,600 are visibly different heights,
# while 30,000 and 40,000 both just mean "very high".

SKY_L = 69
SKY_R = 178
# The wake's own box, inset from the sky so it never crosses a readout: clear
# of the type code and speed on the top row, and of the floating altitude on
# the right.
TRAIL_L = 92
TRAIL_R = 146
TRAIL_TOP = 8

ALT_TOP = 9                # the row a 40,000ft aircraft sits on
ALT_GND = 22               # the row something on the ground sits on

NIGHT = "#2A2D36"          # the rooftops
LIT = "#6A6D7C"            # a window with someone still awake behind it
STAR_A = "#565968"
STAR_B = "#383B46"

CLIMB = "#00E36B"
SINK = "#FFB300"
ALARM = "#FF2D2D"

SKYLINE = """
........#................................................................................#
.......###....................................#.....####...............................#######
.......###...........####.....#..........##########.####.............#.....###.........#######.................###
######.###...........####..#######.......##########.####.........########..###.........#######.......#########.###
######.###..########.####..#######.###...##########.####..######.########..###.#####...#######.####..#########.###
"""

# Offsets into the skyline rather than panel columns, so a lit window stays in
# its building if the silhouette is ever redrawn.
WINDOWS = [[1, 31], [8, 30], [23, 31], [30, 31], [44, 30], [54, 30], [69, 31],
           [76, 30], [89, 29], [102, 31], [112, 31]]

# Panel coordinates, two brightnesses, kept clear of the readouts. Depth, not
# a scatter of identical dots.
STARS = [[73, 8, 0], [81, 15, 1], [88, 21, 0], [95, 11, 1], [101, 18, 0],
         [124, 12, 0], [131, 20, 1], [139, 9, 0], [146, 16, 1], [151, 22, 0],
         [77, 19, 1], [160, 12, 0], [168, 20, 1], [176, 15, 0]]

# 4x5 has no '>' glyph -- the route line rendered as "EWR  IST" with a hole in
# it until this replaced it. A filled triangle also reads better than a chevron
# at three pixels wide.
ARROW = """
#..
##.
###
##.
#..
"""
CHEV_UP = """
..#..
.#.#.
#...#
"""
CHEV_DN = """
#...#
.#.#.
..#..
"""

def alt_y(alt, ground):
    """Panel row for an altitude. The square-root curve means a thousand feet
    near the ground is worth several pixels and a thousand at cruise is worth
    almost none, which is the right emphasis for something you glance at."""
    if ground:
        return ALT_GND
    a = alt
    if a > 40000:
        a = 40000
    if a < 0:
        a = 0
    return ALT_GND - int((ALT_GND - ALT_TOP) * math.sqrt(a / 40000.0) + 0.5)

def draw_scene(c):
    for s in STARS:
        c.pixel(s[0], s[1], STAR_A if s[2] == 0 else STAR_B)
    c.sprite(SKYLINE, SKY_L, 27, color = NIGHT)
    for w in WINDOWS:
        c.pixel(SKY_L + w[0], w[1], LIT)

def plane_glyph(c, cx, cy, p, col, scale = 1.0):
    fam = family_for(p["cat"], p["type"])
    if fam == "rotor":
        draw_rotor(c, cx, cy, p["track"], col, color.dim(col, 60), scale)
    elif p["track"] == None:
        # No heading. Pointing it north would invent a fact, so it is drawn
        # dimmed and facing the reader instead.
        draw_aircraft(c, cx, cy, 0.0, fam, color.dim(col, 55), scale)
    else:
        draw_aircraft(c, cx, cy, p["track"], fam, col, scale)

def draw_trail(c, cx, cy, p, col):
    """A dashed wake along the reverse track. It is the only motion a panel
    that cannot animate is allowed, and it doubles the heading cue: you see
    where the aircraft came from as well as where its nose points."""
    if p["track"] == None or p["ground"]:
        return
    a = p["track"] * DEG
    fx, fy = math.sin(a), -math.cos(a)
    faint = color.dim(col, 52)
    d = 12.0
    for k in range(9):
        x, y = int(cx - fx * d), int(cy - fy * d)
        # The wake stops before it reaches anything written down. It used to be
        # allowed the whole sky, so a westbound aircraft trailed dots straight
        # through the type code in the top-left and an eastbound one through
        # the altitude on the right -- which reads as interference, not motion.
        if x < TRAIL_L or x > TRAIL_R or y < TRAIL_TOP or y > 26:
            return
        if k % 2 == 0:
            c.pixel(x, y, faint)
        d += 3.0

def rate_chevrons(c, x, my, rate):
    """One chevron at 300 fpm, two at 1,200, three at 2,400 -- a stack you can
    count from across a room, instead of a signed number you have to read."""
    r = rate if rate >= 0 else -rate
    n = 0
    if r >= 300:
        n = 1
    if r >= 1200:
        n = 2
    if r >= 2400:
        n = 3
    for i in range(n):
        if rate > 0:
            y = my - 6 - 4 * i
            if y < 1:
                return
            c.sprite(CHEV_UP, x, y, color = CLIMB)
        else:
            y = my + 4 + 4 * i
            if y > 28:
                return
            c.sprite(CHEV_DN, x, y, color = SINK)

def trend_color(p):
    if p["ground"]:
        return "gray"
    if p["rate"] > 300:
        return CLIMB
    if p["rate"] < -300:
        return SINK
    return "#78DCFF"

def alt_short(p):
    if p["ground"]:
        return "GND"
    if p["alt"] >= 10000:
        return str(p["alt"] // 1000) + "K"
    return str((p["alt"] // 100) * 100)

def hero_color(p):
    return ALARM if emergency(p) else band_of(p["alt"])[1]

def fail(c, st, word):
    tab(c, word, "#78DCFF")
    if st["state"] == "setup":
        rail(c, STRUCT)
        message(c, "ADD A ZIP CODE", "SETS THE PATCH OF SKY TO WATCH")
        return True
    if st["state"] == "badzip":
        rail(c, STRUCT)
        message(c, "ZIP NOT FOUND", "CHECK THE ZIP CODE")
        return True
    if st["state"] == "offline":
        rail(c, OFFLINE)
        message(c, "ADS-B OFFLINE", "CANT REACH THE RECEIVER NETWORK")
        return True
    return False

# ---------------------------------------------------------- page 1: overhead
def overhead(c, ctx):
    c.fill("black")
    st = read_sky(ctx)
    if fail(c, st, "OVERHEAD"):
        return
    draw_scene(c)
    if st["state"] == "empty":
        rail(c, STRUCT)
        tab(c, "OVERHEAD", "#78DCFF")
        c.text("QUIET", 4, 11, font = "8x12", color = "gray")
        c.text("NOTHING IN " + str(st["radius"]) + " MI", 4, 25, font = "4x5",
               color = "midgray")
        return

    p = st["planes"][0]
    col = hero_color(p)
    rail(c, col)
    tab(c, "OVERHEAD", col)

    # --- who it is, left column
    head = p["call"] if p["call"] != "" else p["reg"]
    if head == "":
        head = p["hex"] if p["hex"] != "" else "UNKNOWN"
    hf = fit(c, head, ["8x12", "6x8", "5x7"], 62)
    c.text(hf[1], 4, 9 if hf[0] == "8x12" else 11, font = hf[0], color = INK)
    if emergency(p):
        c.text("SQUAWK " + p["squawk"], 4, 24, font = "4x5", color = ALARM)
    else:
        r = route_for(p["call"])
        if r != None:
            # Origin, arrow and destination are packed tight on purpose: the
            # distance is right-aligned against the divider and a three-letter
            # IATA pair only just clears it.
            o = clip(c, r[0], "4x5", 16)
            c.text(o, 4, 24, font = "4x5", color = INK)
            ax = 4 + c.text_width(o, "4x5") + 2
            c.sprite(ARROW, ax, 24, color = col)
            c.text(clip(c, r[1], "4x5", 16), ax + 5, 24, font = "4x5",
                   color = INK)
        elif p["ground"]:
            c.text("ON GROUND", 4, 24, font = "4x5", color = "gray")
        elif p["reg"] != "" and p["reg"] != head:
            c.text(clip(c, p["reg"], "4x5", 36), 4, 24, font = "4x5",
                   color = "gray")
    if p["dst"] > 0:
        c.text(miles(p["dst"]) + "MI", 66, 24, font = "4x5", color = DIM,
               align = "right")

    # --- the sky itself
    if p["type"] != "":
        c.text(clip(c, p["type"], "4x5", 30), SKY_L, 1, font = "4x5",
               color = DIM)
    if p["gs"] > 0:
        c.text(str(kt_to_mph(p["gs"])) + "MPH", SKY_R, 1, font = "4x5",
               color = DIM, align = "right")

    my = alt_y(p["alt"], p["ground"])
    draw_trail(c, 118, my, p, col)
    plane_glyph(c, 118, my, p, col, 1.0)

    # --- the tape: the same axis, quantified. The column fills from the ground
    # up to the aircraft, so height is a quantity you can see the size of and
    # not only a position; the two faint rules are 10,000 and 30,000 feet.
    tc = ALARM if emergency(p) else trend_color(p)
    c.rect(c.width - 4, 0, c.width - 1, 31, fill = "#22242C")
    c.rect(c.width - 4, my, c.width - 1, 31, fill = color.dim(tc, 30))
    for ft in [10000, 30000]:
        ty = alt_y(ft, False)
        c.rect(c.width - 4, ty, c.width - 1, ty, fill = "#474B58")
    c.rect(c.width - 7, my - 1, c.width - 1, my + 1, fill = tc)
    if not p["ground"]:
        rate_chevrons(c, c.width - 12, my, p["rate"])
    ay = my - 3
    if ay < 9:
        ay = 9
    if ay > 19:
        ay = 19
    c.text(alt_short(p), SKY_R, ay, font = "4x7",
           color = "gray" if p["ground"] else INK, align = "right")

# ------------------------------------------------------------- page 2: radar
# A north-up scope. Every aircraft is plotted at its TRUE relative bearing and
# distance rather than spread evenly for looks: one degree of latitude is 60
# nautical miles and one of longitude is 60*cos(lat), so the offset vector
# plots directly and the only trigonometry needed is a single cosine.
def radar(c, ctx):
    c.fill("black")
    st = read_sky(ctx)
    if fail(c, st, "RADAR"):
        return
    hot = st["state"] == "ok" and emergency(st["planes"][0])
    accent = ALARM if hot else "#78DCFF"
    rail(c, accent)
    tab(c, "RADAR", accent)

    n = len(st["planes"])
    c.text(str(n), 4, 8, font = "8x12", color = INK if n > 0 else "gray")
    c.text("ACFT", 4, 21, font = "4x5", color = DIM)
    # "IN 20MI" is 34px and the scope starts at 34, so the range gets its own
    # short line rather than sliding under the ring.
    c.text(str(st["radius"]) + "MI", 4, 27, font = "4x5", color = "midgray")

    cx, cy, rr = 48, 17, 14
    c.circle(cx, cy, rr, "#383B46")
    for k in range(0, 360, 30):
        a = k * DEG
        c.pixel(int(cx + math.sin(a) * 7.5), int(cy - math.cos(a) * 7.5),
                "#2A2D36")
    c.pixel(cx, cy - rr - 1, "gray")
    c.line(cx - 1, cy, cx + 1, cy, accent)
    c.line(cx, cy - 1, cx, cy + 1, accent)
    c.vline(66, 3, 26, "#2A2D36")

    if st["state"] == "empty":
        c.text("QUIET SKIES", 72, 10, font = "5x7", color = "gray")
        c.text("NOTHING OVERHEAD RIGHT NOW", 72, 21, font = "4x5",
               color = "midgray")
        return

    # cos(lat) to two terms. At the latitudes this app sees, the error against
    # a real cosine is well under one pixel at scope scale.
    la = st["lat"] * DEG
    coslat = 1.0 - la * la / 2.0
    for i in range(len(st["planes"])):
        if i > 15:
            break
        q = st["planes"][i]
        if q["lat"] == None or q["lon"] == None:
            continue
        dy = (q["lat"] - st["lat"]) * 60.0
        dx = (q["lon"] - st["lon"]) * 60.0 * coslat
        bx = cx + int(dx / st["rad_nm"] * rr)
        by = cy - int(dy / st["rad_nm"] * rr)
        if bx < cx - rr or bx > cx + rr or by < cy - rr or by > cy + rr:
            continue
        bc = hero_color(q)
        c.rect(bx, by, bx + 1, by + 1, fill = bc)
        if i == 0:
            # The one the other page is about, ticked so the two pages agree.
            c.pixel(bx - 3, by, bc)
            c.pixel(bx + 4, by, bc)
            c.pixel(bx, by - 3, bc)
            c.pixel(bx, by + 4, bc)

    # The three most interesting after the hero get a row each. Anything
    # further out stays a blip on the scope, which is all it deserves.
    if n == 1:
        c.text("NO OTHER TRAFFIC", 72, 15, font = "4x5", color = "midgray")
        return
    for i in range(1, 4):
        if i >= n:
            break
        q = st["planes"][i]
        y = 2 + (i - 1) * 10
        qc = hero_color(q)
        plane_glyph(c, 74, y + 3, q, qc, 0.42)
        lab = q["call"] if q["call"] != "" else q["reg"]
        if lab == "":
            lab = q["hex"] if q["hex"] != "" else "UNKNOWN"
        c.text(clip(c, lab, "4x7", 46), 84, y, font = "4x7", color = INK)
        c.text(alt_short(q), 152, y, font = "4x7", color = qc, align = "right")
        c.text(miles(q["dst"]) + "MI", c.width - 3, y, font = "4x7",
               color = DIM, align = "right")
