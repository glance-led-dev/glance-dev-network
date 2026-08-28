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
    "light": [4.6, 6.6, 1.3, 7.0, 2.2, 2.6, 2.1, 0.2, 3.2, -5.8, 2.1, 1.5, 0.2, 0],
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
    for py in range(-r, r + 1):
        y = iy + py
        if y < 0 or y >= c.height:
            continue
        for px in range(-r, r + 1):
            x = ix + px
            if x < 0 or x >= c.width:
                continue
            u = fx * px + fy * py
            v = fx * py - fy * px
            if _in_body(u, v, nose, tail, bw):
                c.pixel(x, y, col)
            elif _in_wing(u, v, span, wst, croot, ctip, sweep):
                c.pixel(x, y, col)
            elif _in_wing(u, v, tspan, tst, tcroot, tctip, tsweep):
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
# Two feeds, in this order on purpose.
#
# adsbdb is asked first because it accepts the number printed on a boarding
# pass ("UA415") as well as the callsign an aircraft actually broadcasts
# ("UAL415"), and hands back both plus the airport coordinates. Resolving
# through it is what lets a person type what is on their ticket.
#
# adsb.lol is then asked for the live aircraft, by the ICAO callsign.

ADSB_CS = "https://api.adsb.lol/v2/callsign/"
ADSBDB = "https://api.adsbdb.com/v0/callsign/"

EARTH_NM = 3440.065

def hav_nm(lat1, lon1, lat2, lon2):
    """Great-circle distance in nautical miles.

    The flat-earth shortcut is within a percent over a short hop and out by
    hundreds of miles across an ocean, and an ocean is exactly where somebody
    watching a flight number cares most about the answer."""
    p1, p2 = lat1 * DEG, lat2 * DEG
    s1 = math.sin((lat2 - lat1) * DEG / 2.0)
    s2 = math.sin((lon2 - lon1) * DEG / 2.0)
    a = s1 * s1 + math.cos(p1) * math.cos(p2) * s2 * s2
    if a < 0.0:
        a = 0.0
    if a > 1.0:
        a = 1.0
    return 2.0 * EARTH_NM * math.asin(math.sqrt(a))

def nm_to_mi(nm):
    return int(nm * 1.15078 + 0.5)

def kt_to_mph(kt):
    return kt * 1151 // 1000

def fnum(x, fallback = None):
    """A float straight off a feed. num() rejects anything with a dot and dec()
    wants a fixed scale, and a latitude needs neither."""
    if x == None:
        return fallback
    t = str(x).strip()
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    bits = t.split(".")
    if len(bits) > 2:
        return fallback
    whole = num(bits[0], -1) if bits[0] != "" else 0
    if whole < 0:
        return fallback
    v = whole * 1.0
    if len(bits) == 2 and bits[1] != "":
        frac = num(bits[1], -1)
        if frac < 0:
            return fallback
        scale = 1.0
        for _ in range(len(bits[1])):
            scale *= 10.0
        v += frac / scale
    return -v if neg else v

def read_flight(ctx):
    raw = str(ctx.inputs.get("flight", "")).strip().upper().replace(" ", "")
    st = {"state": "setup", "q": raw, "call": raw, "route": None, "p": None,
          "gone": 0.0, "left": 0.0, "total": 0.0, "pct": 0}
    if raw == "":
        return st

    fr = None
    r = http.get(ADSBDB + raw, ttl_seconds = 3600)
    if r["status_code"] == 200 and r["json"] != None:
        fr = dig(r["json"], ["response", "flightroute"], None)
    if fr != None:
        ic = str(dig(fr, ["callsign_icao"], "")).strip().upper()
        if ic != "":
            st["call"] = ic
        st["route"] = {
            "airline": str(dig(fr, ["airline", "name"], "")).upper(),
            "o": str(dig(fr, ["origin", "iata_code"], "")).upper(),
            "d": str(dig(fr, ["destination", "iata_code"], "")).upper(),
            "ocity": str(dig(fr, ["origin", "municipality"], "")).upper(),
            "dcity": str(dig(fr, ["destination", "municipality"], "")).upper(),
            "olat": fnum(dig(fr, ["origin", "latitude"], None)),
            "olon": fnum(dig(fr, ["origin", "longitude"], None)),
            "dlat": fnum(dig(fr, ["destination", "latitude"], None)),
            "dlon": fnum(dig(fr, ["destination", "longitude"], None)),
        }
        # Route length is known the moment the route is, with or without an
        # aircraft. It is what turns "not airborne" from a dead end into
        # "LHR to JFK, 3,000 miles" -- which is the other thing you wanted.
        rr = st["route"]
        if rr["olat"] != None and rr["dlat"] != None:
            st["total"] = hav_nm(rr["olat"], rr["olon"], rr["dlat"], rr["dlon"])

    a = http.get(ADSB_CS + st["call"], ttl_seconds = 300)
    if a["status_code"] != 200 or a["json"] == None:
        st["state"] = "offline"
        return st
    ac = get(a["json"], "ac", [])
    if type(ac) != "list" or len(ac) == 0:
        # Nothing is transmitting this callsign. If adsbdb knew the route we
        # can still say which flight it is; otherwise we know nothing at all.
        st["state"] = "notair" if st["route"] != None else "unknown"
        return st

    d = ac[0]
    alt_raw = d.get("alt_baro", None)
    on_ground = str(alt_raw).lower() == "ground"
    st["p"] = {
        "hex": str(get(d, "hex", "")).strip().upper(),
        "reg": str(get(d, "r", "")).strip().upper(),
        "type": str(get(d, "t", "")).strip().upper(),
        "cat": str(get(d, "category", "")).strip().upper(),
        "alt": 0 if on_ground else num(alt_raw, 0),
        "ground": on_ground,
        "gs": intpart(get(d, "gs", 0), 0),
        "track": d.get("track", None),
        "rate": intpart(d.get("baro_rate", d.get("geom_rate", 0)), 0),
        "sel": num(d.get("nav_altitude_mcp", None), 0),
        "squawk": str(get(d, "squawk", "")).strip(),
        "lat": fnum(d.get("lat", None)),
        "lon": fnum(d.get("lon", None)),
    }
    st["state"] = "ground" if on_ground else "air"
    progress(st)
    return st

def progress(st):
    """How far along the route the aircraft is.

    adsbdb returns the route a callsign is KNOWN to fly, not the one it is
    flying today -- callsigns get reused, and the database goes stale. Seen in
    testing: UAL415 came back as Denver to LaGuardia while the aircraft was
    over Oxfordshire at 36,000ft. So the route is checked against the aircraft
    before any of it is believed: if the legs to each end sum to much more than
    the direct distance, the aircraft is not on that route and the app says so
    rather than drawing a confident, wrong progress bar."""
    rt, p = st["route"], st["p"]
    if rt == None or p == None or p["lat"] == None:
        return
    if rt["olat"] == None or rt["dlat"] == None:
        return
    total = st["total"]
    if total < 20.0:
        return
    gone = hav_nm(rt["olat"], rt["olon"], p["lat"], p["lon"])
    left = hav_nm(p["lat"], p["lon"], rt["dlat"], rt["dlon"])
    if gone + left > total * 1.25 + 60.0:
        st["route"] = None
        st["stale"] = True
        st["total"] = 0.0
        return
    st["gone"], st["left"] = gone, left
    pct = int(gone / total * 100.0 + 0.5)
    st["pct"] = 0 if pct < 0 else (100 if pct > 100 else pct)

def phase(st):
    """Colour and word for what the flight is doing."""
    p = st["p"]
    if p == None:
        return ["WAITING", "#6E7A94"]
    if p["ground"]:
        return ["ON GROUND", "#9AA6B8"]
    if p["rate"] > 400:
        return ["CLIMBING", "#00E36B"]
    if p["rate"] < -400:
        return ["DESCENDING", "#FFB300"]
    return ["CRUISING", "#78DCFF"]

def eta_words(st):
    """Time to run, from distance left and current ground speed. It ignores
    wind, holding and the approach, so it is an estimate and the label says
    LANDS IN rather than ARRIVES AT -- a wrong clock time reads as a promise."""
    p = st["p"]
    if p == None or st["left"] <= 0.0 or p["gs"] < 60:
        return ""
    mins = int(st["left"] / p["gs"] * 60.0 + 0.5)
    if mins < 1:
        return "<1M"
    if mins < 60:
        return str(mins) + "M"
    return str(mins // 60) + "H" + fmt.pad(mins % 60, 2)

def alt_words(p):
    if p == None:
        return ""
    if p["ground"]:
        return "GROUND"
    if p["alt"] >= 18000:
        # Above the transition altitude everybody, including the crew, calls it
        # a flight level.
        return "FL" + fmt.pad(p["alt"] // 100, 3)
    return fmt.commas((p["alt"] // 100) * 100) + "FT"

# ---- pages ----------------------------------------------------------------
# The question this app answers is "where is that flight right now", and the
# honest shape of that answer is a line between two airports with something on
# it. So the route bar is the hero and everything else is subordinate to it.
#
# The aircraft on the bar is drawn pointing RIGHT rather than at its true
# compass bearing. The bar is a schematic of a journey, not a map, and a
# westbound flight nosing left along a left-to-right progress bar reads as
# going backwards. The true heading gets a compass of its own on page two,
# where it means something.

BAR_L = 26
BAR_R = 160
BAR_Y = 13

def bar_x(pct):
    return BAR_L + (BAR_R - BAR_L) * pct // 100

def fam_of(p):
    return family_for(p["cat"], p["type"]) if p != None else "jet"

def fail(c, st, word):
    tab(c, word, "#78DCFF")
    if st["state"] == "setup":
        rail(c, STRUCT)
        message(c, "ADD A FLIGHT NUMBER", "LIKE UA415 OR BA117")
        return True
    if st["state"] == "offline":
        rail(c, OFFLINE)
        message(c, "ADS-B OFFLINE", "CANT REACH THE RECEIVER NETWORK")
        return True
    if st["state"] == "unknown":
        rail(c, OFFLINE)
        message(c, "NOT TRACKING " + clip(c, st["q"], "5x7", 60),
                "NOTHING IS BROADCASTING THAT CALLSIGN")
        return True
    return False

# ------------------------------------------------------------ page 1: flight
def flight(c, ctx):
    c.fill("black")
    st = read_flight(ctx)
    if fail(c, st, "FLIGHT"):
        return
    ph = phase(st)
    p, rt = st["p"], st["route"]
    col = ph[1]
    rail(c, col)
    tab(c, "FLIGHT", col)

    label = st["call"] if st["call"] != "" else st["q"]
    c.text(clip(c, label, "6x8", 48), 42, 0, font = "6x8", color = INK)
    if rt != None and rt["airline"] != "":
        c.text(clip(c, rt["airline"], "4x5", 96), 188, 2, font = "4x5",
               color = DIM, align = "right")
    elif p != None and p["reg"] != "":
        c.text(p["reg"], 188, 2, font = "4x5", color = DIM, align = "right")

    # --- the route band
    if rt != None:
        c.text(clip(c, rt["o"], "5x7", 20), 4, 10, font = "5x7", color = INK)
        c.text(clip(c, rt["d"], "5x7", 20), 188, 10, font = "5x7", color = INK,
               align = "right")
        c.vline(BAR_L, BAR_Y - 2, 5, STRUCT)
        c.vline(BAR_R, BAR_Y - 2, 5, STRUCT)
        c.line(BAR_L, BAR_Y, BAR_R, BAR_Y, "#2E313B")
        if st["state"] == "notair":
            c.text("NOT AIRBORNE", 96, 11, font = "4x5", color = "gray",
                   align = "center")
        else:
            px = bar_x(st["pct"])
            c.line(BAR_L, BAR_Y, px, BAR_Y, color.dim(col, 70))
            draw_aircraft(c, px, BAR_Y, 90.0, fam_of(p), col, 0.45)
    elif p != None:
        # No route we are willing to stand behind. Say that, rather than
        # drawing an empty bar that looks like a flight that has not started.
        draw_aircraft(c, 96, BAR_Y, p["track"] if p["track"] != None else 90.0,
                      fam_of(p), col, 0.55)
        c.text(ph[0], 4, 10, font = "5x7", color = col)
        if st.get("stale", False):
            c.text("ROUTE UNVERIFIED", 188, 11, font = "4x5", color = "gray",
                   align = "right")

    # --- three readouts
    c.vline(66, 19, 13, STRUCT)
    c.vline(130, 19, 13, STRUCT)
    c.text("ALTITUDE", 4, 19, font = "4x5", color = DIM)
    c.text(alt_words(p) if p != None else "--", 4, 25, font = "4x7",
           color = INK)
    c.text("SPEED", 70, 19, font = "4x5", color = DIM)
    spd = str(kt_to_mph(p["gs"])) + "MPH" if p != None and p["gs"] > 0 else "--"
    c.text(spd, 70, 25, font = "4x7", color = INK)

    if st["left"] > 0.0:
        c.text("LANDS IN", 134, 19, font = "4x5", color = DIM)
        e = eta_words(st)
        c.text(e if e != "" else "--", 134, 25, font = "4x7", color = col)
    elif p != None and p["track"] != None:
        c.text("HEADING", 134, 19, font = "4x5", color = DIM)
        c.text(str(int(p["track"])), 134, 25, font = "4x7", color = INK)
    elif st["total"] > 0.0:
        c.text("DISTANCE", 134, 19, font = "4x5", color = DIM)
        c.text(fmt.commas(nm_to_mi(st["total"])) + "MI", 134, 25, font = "4x7",
               color = INK)
    else:
        c.text("STATUS", 134, 19, font = "4x5", color = DIM)
        c.text(clip(c, ph[0], "4x7", 54), 134, 25, font = "4x7", color = col)

# ---------------------------------------------------------- page 2: aircraft
# The metal, and a compass. This is where the true heading belongs -- on a
# rose, where north is up and 298 degrees means something, rather than on a
# progress bar where it would fight the direction of travel.
ROSE_X = 150
ROSE_Y = 19
ROSE_R = 12

def aircraft(c, ctx):
    c.fill("black")
    st = read_flight(ctx)
    if fail(c, st, "AIRCRAFT"):
        return
    ph = phase(st)
    p = st["p"]
    col = ph[1]
    rail(c, col)
    tab(c, "AIRCRAFT", col)

    if st["state"] == "notair":
        rt = st["route"]
        c.text("NOT AIRBORNE", 4, 12, font = "8x12", color = "gray")
        sub = st["call"]
        if rt != None and rt["o"] != "" and rt["d"] != "":
            sub = st["call"] + "   " + rt["o"] + " TO " + rt["d"]
            if st["total"] > 0.0:
                sub = sub + "   " + fmt.commas(nm_to_mi(st["total"])) + " MILES"
        c.text(clip(c, sub, "4x5", 180), 4, 26, font = "4x5", color = "midgray")
        return

    if p["hex"] != "":
        c.text(p["hex"], 188, 2, font = "4x5", color = DIM, align = "right")
    # The phase word rides the top row next to the tab, which keeps the two
    # lines under the registration from stacking into one grey block.
    word = ph[0]
    if not p["ground"]:
        r = p["rate"] if p["rate"] >= 0 else -p["rate"]
        if r >= 300:
            word = word + " " + str(r) + "FPM"
    c.text(clip(c, word, "4x5", 100), 52, 2, font = "4x5", color = col)
    head = p["reg"] if p["reg"] != "" else st["call"]
    hf = fit(c, head, ["8x12", "6x8"], 100)
    c.text(hf[1], 4, 10 if hf[0] == "8x12" else 12, font = hf[0], color = INK)

    line = p["type"] if p["type"] != "" else "UNKNOWN TYPE"
    if p["squawk"] != "":
        line = line + "   SQ " + p["squawk"]
    if p["sel"] > 0 and not p["ground"]:
        # The altitude dialled into the autopilot: where the flight is going,
        # not just where it is. Nothing else on either page says that.
        line = line + "   SEL FL" + fmt.pad(p["sel"] // 100, 3)
    c.text(clip(c, line, "4x5", 130), 4, 24, font = "4x5", color = DIM)

    # --- compass rose
    c.circle(ROSE_X, ROSE_Y, ROSE_R, "#33363F")
    for k in range(0, 360, 90):
        a = k * DEG
        for r in [ROSE_R - 1, ROSE_R - 2]:
            c.pixel(int(ROSE_X + math.sin(a) * r), int(ROSE_Y - math.cos(a) * r),
                    "#5A5E6C")
    c.text("N", ROSE_X, 1, font = "4x5", color = "gray", align = "center")
    if p["track"] != None:
        draw_aircraft(c, ROSE_X, ROSE_Y, p["track"], fam_of(p), col, 0.7)
        c.text(fmt.pad(int(p["track"]), 3), 188, 25, font = "4x5",
               color = INK, align = "right")
    else:
        draw_aircraft(c, ROSE_X, ROSE_Y, 0.0, fam_of(p), color.dim(col, 55), 0.7)

