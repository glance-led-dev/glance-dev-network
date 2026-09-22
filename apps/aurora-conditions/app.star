# Aurora Conditions (64x32)
#
# DESIGN. One ZIP code, three cards, in the order an aurora chaser actually
# asks the questions -- and each card has exactly one hero, so there is never
# a moment where four numbers compete for the eye.
#
#   wind        Is the driver there right now?  BZ is the hero at 9x12 on the
#               left with its trend arrow; BT, V and N ride a quiet rail on
#               the right, colour banded but deliberately small.
#   kp          How strong is it forecast to be at the hours you would
#               actually be outside -- 8pm, 11pm, 2am, 5am local.  Real bars
#               over the full height, and a dotted line across them marking
#               the Kp YOUR latitude needs before any of it reaches you.
#               Bars under that line are dimmed: hue is storm strength,
#               brightness is "does it get to me".
#   visibility  If it does fire, will the sky let you see it?  An aurora
#               curtain is the hero -- its height is the score and its colour
#               is the verdict -- with the verdict word riding on it and the
#               moon and cloud that set it along the bottom.
#
# The curtain is the app's identity: nothing else in the catalogue draws one,
# and it means the card reads as "aurora" before a single number is parsed.
#
# Everything on the panel is anchored to a timestamp that came back in the
# data, never to the render clock, so the same fetch always draws the same
# pixels -- including the curtain, whose ray pattern is seeded from the score.

# ---------------------------------------------------------------- palette

BG = "#05070E"
GRID = "#151B2E"
LABEL = "#5D6B96"
DIM = "#8493C0"
ARROW = "#79A6E8"
NEEDC = "#78DCFF"      # the "Kp you need" line, deliberately unlike the bands

GREEN = "#3FD46A"      # normal / not active
YELLOW = "#F2D34B"     # marginal
ORANGE = "#FF9A3C"     # good
RED = "#FF4B4B"        # strong
WHITE = "#FFFFFF"      # reserved for Kp 9, standing in for NOAA's dark red

PI = 3.141592653589793
DEG = 0.017453292519943295

# ------------------------------------------------------------ tiny helpers

DIGITS = "0123456789"


def trim(s):
    """Unset inputs arrive as None, not "" -- everything reads through here."""
    if s == None:
        return ""
    return str(s).strip(" \t\r\n")


def to_int(s):
    """int() on a non-number is a hard error and Starlark has no try, so
    every character gets checked first."""
    if s == None:
        return None
    t = trim(s)
    neg = False
    if t[:1] == "-":
        neg = True
        t = t[1:]
    elif t[:1] == "+":
        t = t[1:]
    if t == "":
        return None
    v = 0
    for ch in t.elems():
        i = DIGITS.find(ch)
        if i < 0:
            return None
        v = v * 10 + i
    return -v if neg else v


def to_float(v):
    if v == None:
        return None
    if type(v) == "int" or type(v) == "float":
        return float(v)
    t = trim(v)
    neg = False
    if t[:1] == "-":
        neg = True
        t = t[1:]
    elif t[:1] == "+":
        t = t[1:]
    if t == "":
        return None
    parts = t.split(".")
    if len(parts) > 2:
        return None
    whole = 0
    if parts[0] != "":
        whole = to_int(parts[0])
        if whole == None:
            return None
    frac = 0.0
    if len(parts) == 2 and parts[1] != "":
        f = to_int(parts[1])
        if f == None:
            return None
        scale = 1.0
        for _ in range(len(parts[1])):
            scale = scale * 10.0
        frac = float(f) / scale
    out = float(whole) + frac
    return -out if neg else out


def fixed(v, places):
    """Starlark's % has no %f, so decimals are formatted by hand."""
    neg = v < 0
    if neg:
        v = -v
    scale = 1
    for _ in range(places):
        scale = scale * 10
    n = int(v * float(scale) + 0.5)
    whole = n // scale
    out = str(whole)
    if places > 0:
        frac = str(n % scale)
        for _ in range(places - len(frac)):
            frac = "0" + frac
        out = out + "." + frac
    return "-" + out if neg and n > 0 else out


def smart(v, small_places):
    """One decimal while the number is small, whole once it needs the width.
    This is what bounds the hero: the widest BZ this can ever produce is
    "-9.9", 34px at 9x12, which is exactly the left zone."""
    if v == None:
        return "--"
    a = v if v >= 0 else -v
    return fixed(v, 0) if a >= 10.0 else fixed(v, small_places)


def clip_to(c, s, font, maxw):
    """Nothing in the drawing API clips, so every string that came from an API
    -- place names especially -- goes through here before it is drawn."""
    if s == "":
        return ""
    if c.text_width(s, font) <= maxw:
        return s
    t = s
    for _ in range(len(s)):
        t = t[:len(t) - 1].strip(" ")       # no "FAIRBANKS .." with a gap
        if t == "":
            return ""
        if c.text_width(t + "..", font) <= maxw:
            return t + ".."
    return ""


def fit_place(c, label, font, maxw):
    """Drop the state abbreviation before clipping the town. "FAIRBANKS AK" is
    47px and the visibility card's header has 36, and clipping gave
    "FAIRBA..", which names nowhere -- "FAIRBANKS" fits and names somewhere."""
    if label == "":
        return ""
    if c.text_width(label, font) <= maxw:
        return label
    i = label.rfind(" ")
    if i > 0 and c.text_width(label[:i], font) <= maxw:
        return label[:i]
    return clip_to(c, label, font, maxw)


# ------------------------------------------------------------------- time
# Howard Hinnant's civil-date algorithms. Starlark has no datetime, and the
# feeds all speak UTC ISO strings, so the conversion has to live here.

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil_from_days(z):
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]


def parse_iso(s):
    """"2026-09-16T20:05:05", "2026-09-16 20:05" and "2026-09-16T20:00" all
    arrive from one feed or another. All of them are UTC."""
    if s == None:
        return None
    t = str(s)
    if len(t) < 16:
        return None
    y = to_int(t[0:4])
    mo = to_int(t[5:7])
    d = to_int(t[8:10])
    h = to_int(t[11:13])
    mi = to_int(t[14:16])
    if y == None or mo == None or d == None or h == None or mi == None:
        return None
    se = 0
    if len(t) >= 19 and t[16:17] == ":":
        se = to_int(t[17:19])
        if se == None:
            se = 0
    return days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60 + se


def parts_of(epoch):
    """[year, month, day, hour, minute, weekday] -- weekday 0 = Sunday."""
    days = epoch // 86400
    rem = epoch - days * 86400
    ymd = civil_from_days(days)
    return [ymd[0], ymd[1], ymd[2], rem // 3600, (rem % 3600) // 60,
            (days + 4) % 7]


def epoch_of(y, mo, d, h, mi):
    return days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60


def hhmm(epoch):
    p = parts_of(epoch)
    return ("0" + str(p[3]))[-2:] + ":" + ("0" + str(p[4]))[-2:]


def nth_weekday(y, m, weekday, n):
    """Day-of-month of the nth given weekday, e.g. the 2nd Sunday of March."""
    first = days_from_civil(y, m, 1)
    w = (first + 4) % 7
    return 1 + (weekday - w + 7) % 7 + (n - 1) * 7


def us_dst(epoch, std_hours):
    """US rule: 2am local on the second Sunday of March to 2am on the first
    Sunday of November."""
    p = parts_of(epoch + std_hours * 3600)
    y = p[0]
    start = epoch_of(y, 3, nth_weekday(y, 3, 0, 2), 2, 0) - std_hours * 3600
    end = epoch_of(y, 11, nth_weekday(y, 11, 0, 1), 2, 0) - (std_hours + 1) * 3600
    return epoch >= start and epoch < end


def lon_offset(loc, epoch):
    """Seconds to add to UTC when the sky forecast -- which carries the real,
    daylight-saving-aware offset -- is the thing that failed.

    Longitude alone is not enough. Fifteen degrees per hour puts Connecticut
    on UTC-5, which is right in January and an hour wrong from March to
    November, and an hour wrong is a whole forecast row. The app is US-only
    now, so the daylight-saving rule is knowable: apply it."""
    if loc == None:
        return 0
    h = loc[1] / 15.0
    std = int(h + 0.5) if h >= 0 else int(h - 0.5)
    if std < -10 or std > -4:
        return std * 3600          # outside the US zones, leave it alone
    if std == -7 and loc[0] < 37.0 and loc[1] > -115.0:
        return std * 3600          # Arizona keeps standard time all year
    return (std + 1) * 3600 if us_dst(epoch, std) else std * 3600


# ------------------------------------------------------------------ bands
# Four colour bands per reading. These are the thresholds aurora chasers
# work to: Bz is signed and only southward (negative) drives the aurora, so
# its bands run the other way from the rest.

def band_bz(v):
    if v == None:
        return LABEL
    if v > -2.0:
        return GREEN
    if v > -5.0:
        return YELLOW
    if v > -10.0:
        return ORANGE
    return RED


def band_bt(v):
    if v == None:
        return LABEL
    if v < 5.0:
        return GREEN
    if v < 10.0:
        return YELLOW
    if v < 20.0:
        return ORANGE
    return RED


def band_speed(v):
    if v == None:
        return LABEL
    if v < 350.0:
        return GREEN
    if v < 450.0:
        return YELLOW
    if v < 550.0:
        return ORANGE
    return RED


def band_density(v):
    if v == None:
        return LABEL
    if v < 5.0:
        return GREEN
    if v < 10.0:
        return YELLOW
    if v < 20.0:
        return ORANGE
    return RED


def band_kp(kp):
    """NOAA's G scale, with white standing in for the dark red of G5."""
    if kp == None:
        return LABEL
    if kp < 5.0:
        return GREEN
    if kp < 6.0:
        return YELLOW
    if kp < 7.0:
        return ORANGE
    if kp < 8.0:
        return "#FF6A1A"
    if kp < 9.0:
        return RED
    return WHITE


# ------------------------------------------------------------------- moon
# Low-precision lunar position, good to a degree or so -- far better than
# this panel can show, and it means no second API and no key.

J2000 = 946728000              # 2000-01-01 12:00 UTC


def moon_phase(epoch):
    """Sun-to-moon elongation as a fraction of the cycle: 0 = new, 0.25 =
    first quarter, 0.5 = full, 0.75 = last quarter. Taken from both bodies'
    ecliptic longitudes rather than from a mean synodic month -- checked
    against a full ephemeris over 400 days, that is the difference between
    a 10-point and a 2-point error in percent illuminated."""
    d = (float(epoch) - float(J2000)) / 86400.0
    lam_m = 218.316 + 13.176396 * d + 6.289 * math.sin((134.963 + 13.064993 * d) * DEG)
    gs = 357.528 + 0.9856003 * d
    lam_s = (280.460 + 0.9856474 * d + 1.915 * math.sin(gs * DEG) +
             0.020 * math.sin(2.0 * gs * DEG))
    el = math.fmod(lam_m - lam_s, 360.0)
    if el < 0.0:
        el = el + 360.0
    return el / 360.0


def moon_illum(epoch):
    """Illuminated fraction, 0 (new) to 1 (full)."""
    return (1.0 - math.cos(2.0 * PI * moon_phase(epoch))) / 2.0


def moon_altitude(epoch, lat, lon):
    """Altitude of the moon above the horizon, in degrees. Negative is down."""
    d = (float(epoch) - float(J2000)) / 86400.0
    lm = (218.316 + 13.176396 * d) * DEG          # mean longitude
    mm = (134.963 + 13.064993 * d) * DEG          # mean anomaly
    fm = (93.272 + 13.229350 * d) * DEG           # argument of latitude
    lam = lm + 6.289 * DEG * math.sin(mm)         # ecliptic longitude
    bet = 5.128 * DEG * math.sin(fm)              # ecliptic latitude
    eps = 23.4397 * DEG
    ra = math.atan2(math.sin(lam) * math.cos(eps) -
                    math.tan(bet) * math.sin(eps), math.cos(lam))
    dec = math.asin(math.sin(bet) * math.cos(eps) +
                    math.cos(bet) * math.sin(eps) * math.sin(lam))
    gmst = (280.16 + 360.9856235 * d) * DEG
    ha = gmst + lon * DEG - ra
    rl = lat * DEG
    sin_alt = (math.sin(rl) * math.sin(dec) +
               math.cos(rl) * math.cos(dec) * math.cos(ha))
    if sin_alt > 1.0:
        sin_alt = 1.0
    if sin_alt < -1.0:
        sin_alt = -1.0
    return math.degrees(math.asin(sin_alt))


def moon_washout(epoch, lat, lon):
    """0 = no interference, 1 = full moon riding high. Brightness times how
    high it sits, because a full moon on the horizon barely matters."""
    lit = moon_illum(epoch)
    alt = moon_altitude(epoch, lat, lon)
    if alt <= 0.0:
        return 0.0
    return lit * math.sin(alt * DEG)


# ------------------------------------------------------------------- feeds

MAG_URL = "https://services.swpc.noaa.gov/json/rtsw/rtsw_mag_1m.json"
WIND_URL = "https://services.swpc.noaa.gov/json/rtsw/rtsw_wind_1m.json"
WX_URL = "https://api.open-meteo.com/v1/forecast"
GEO_URL = "https://api.zippopotam.us/us/"


# The plasma file is 2.67 MB against the host's 2 MB body cap, so it arrives
# truncated and unparseable. Both files are newest first and NOAA honours byte
# ranges, so the app asks for the front of each one. A sliced array is no
# longer valid JSON, so the records are read out of the raw text instead --
# 420 KB covers three hours of plasma and seven of magnetometer, against a
# download six times smaller than the one that was failing.

def rows_of(resp):
    """For the small feeds that parse cleanly in one piece."""
    if resp["status_code"] != 200:
        return None
    j = resp["json"]
    if j == None or type(j) != "list" or len(j) == 0:
        return None
    return j


WINDOW_BYTES = 420000
SCAN_CAP = 1400                # records walked before giving up on the window
TREND_WINDOW = 10800           # three hours, the span the arrow reads


def fetch_window(url):
    # Accept-Encoding matters as much as the Range here. The host fetches with
    # a library that asks for gzip by default, and NOAA drops the range when
    # it compresses -- which quietly returns the whole 2.67 MB file and a body
    # truncated at the host's cap. Asking for identity gets a real 206.
    r = http.get(url, headers = {"Range": "bytes=0-" + str(WINDOW_BYTES),
                                 "Accept-Encoding": "identity"},
                 ttl_seconds = 540)
    if r["status_code"] != 200 and r["status_code"] != 206:
        return None
    if r["json"] != None:
        return r["json"]            # short enough to have parsed cleanly
    body = r["body"]
    if body == None:
        return None
    t = str(body)
    if len(t) > WINDOW_BYTES:
        t = t[:WINDOW_BYTES]
    parts = t.split("},")
    if len(parts) < 2:
        return None
    return parts


# Records arrive either as dicts (clean JSON) or as raw text chunks (sliced
# array). These three read both, so nothing downstream has to care which.

def rec_num(rec, key):
    if type(rec) == "dict":
        return to_float(rec.get(key, None))
    pat = "\"" + key + "\":"
    i = rec.find(pat)
    if i < 0:
        return None
    seg = rec[i + len(pat):i + len(pat) + 26]
    j = seg.find(",")
    if j >= 0:
        seg = seg[:j]
    return to_float(seg)


def rec_str(rec, key):
    if type(rec) == "dict":
        v = rec.get(key, None)
        return str(v) if v != None else None
    pat = "\"" + key + "\": \""
    i = rec.find(pat)
    if i < 0:
        return None
    j = i + len(pat)
    k = rec[j:].find("\"")
    if k < 0:
        return None
    return rec[j:j + k]


def rec_active(rec):
    """NOAA marks its operational spacecraft with active=true; the others are
    cross-checks. ACE has flown since 1997 and its density sensor now reads
    0.46 against SOLAR1's 4.95, so believing whichever reported most recently
    puts a dead number on the panel."""
    if type(rec) == "dict":
        return rec.get("active", False) == True
    return rec.find("\"active\": true") >= 0


def lead(rows, field, want_active):
    """[source, newest timestamp] of the first usable record."""
    for i in range(len(rows)):
        if i >= SCAN_CAP:
            break
        r = rows[i]
        if want_active and not rec_active(r):
            continue
        if rec_num(r, field) == None:
            continue
        return [rec_str(r, "source"), parse_iso(rec_str(r, "time_tag"))]
    return None


def collect(rows, field, src, newest_t):
    """Walk the file, newest first, until three hours back."""
    out = []
    for i in range(len(rows)):
        if i >= SCAN_CAP:
            break
        r = rows[i]
        t = parse_iso(rec_str(r, "time_tag"))
        if t == None:
            continue
        if newest_t != None and newest_t - t > TREND_WINDOW:
            break
        if src != None and rec_str(r, "source") != src:
            continue
        v = rec_num(r, field)
        if v == None:
            continue
        out.append([t, v])
    return out


def series(rows, field):
    """[[epoch, value], ...] over the last three hours, newest first, from the
    one spacecraft NOAA currently flags as operational.

    The files interleave three spacecraft, and mixing them puts a step change
    in the middle of the trend -- they disagree by a nanotesla or two because
    they sit at different points in the same wind. They are also far longer
    than they look, about twenty hours at a sample a minute, so the walk stops
    three hours back: the right timescale for a quantity that reverses every
    twenty minutes, and a fraction of the work."""
    if rows == None:
        return []
    head = lead(rows, field, True)
    if head == None:
        head = lead(rows, field, False)      # nothing flagged active
    if head == None:
        return []
    out = collect(rows, field, head[0], head[1])
    if len(out) < 6:
        out = collect(rows, field, None, head[1])
    return out


def newest(pairs):
    if len(pairs) == 0:
        return None
    best = pairs[0]
    for p in pairs:
        if p[0] > best[0]:
            best = p
    return best


def mean_between(pairs, lo, hi):
    total = 0.0
    n = 0
    for p in pairs:
        if p[0] >= lo and p[0] <= hi:
            total = total + p[1]
            n = n + 1
    if n == 0:
        return None
    return total / float(n)


def trend(pairs, deadband):
    """-1, 0 or +1 by comparing the newest third of the window with the
    oldest third. The feed carries roughly the last hour at one sample a
    minute, which is the timescale Bz actually turns over on."""
    if len(pairs) < 6:
        return 0
    lo = pairs[0][0]
    hi = pairs[0][0]
    for p in pairs:
        if p[0] < lo:
            lo = p[0]
        if p[0] > hi:
            hi = p[0]
    span = hi - lo
    if span < 300:
        return 0
    third = span // 3
    recent = mean_between(pairs, hi - third, hi)
    older = mean_between(pairs, lo, lo + third)
    if recent == None or older == None:
        return 0
    delta = recent - older
    if delta > deadband:
        return 1
    if delta < -deadband:
        return -1
    return 0


# ------------------------------------------------------------- the ZIP code
# Two-hop location, the catalogue's standard shape: zip -> zippopotam (a day's
# ttl, because a ZIP does not move) -> lat/lon -> the real feeds.

def zip_of(ctx):
    """The typed ZIP, or "" -- shape-checked before it is ever put in a URL."""
    z = trim(ctx.inputs.get("zip", ""))
    if len(z) != 5:
        return ""
    for ch in z.elems():
        if DIGITS.find(ch) < 0:
            return ""
    return z


def geocode(ctx):
    """{"ok", "err"} plus lat/lon/label when it worked. The error is named --
    a blank box, a typo and a dead network want three different screens."""
    raw = trim(ctx.inputs.get("zip", ""))
    if raw == "":
        return {"ok": False, "err": "NOZIP"}
    z = zip_of(ctx)
    if z == "":
        return {"ok": False, "err": "BADZIP"}

    r = http.get(GEO_URL + z, ttl_seconds = 86400)
    if r["status_code"] == 404:
        return {"ok": False, "err": "NOTFOUND"}
    if r["status_code"] != 200 or r["json"] == None:
        return {"ok": False, "err": "OFFLINE"}

    places = r["json"].get("places", [])
    if type(places) != "list" or len(places) == 0:
        return {"ok": False, "err": "NOTFOUND"}
    p = places[0]
    la = to_float(p.get("latitude", None))
    lo = to_float(p.get("longitude", None))
    if la == None or lo == None:
        return {"ok": False, "err": "NOTFOUND"}

    name = str(p.get("place name", "")).upper()
    st = str(p.get("state abbreviation", "")).upper()
    label = name if st == "" or name == "" else name + " " + st
    if label == "":
        label = z
    return {"ok": True, "err": "", "lat": la, "lon": lo, "label": label}


def weather(loc):
    if loc == None:
        return None
    r = http.get(WX_URL, params = {
        "latitude": fixed(loc[0], 4),
        "longitude": fixed(loc[1], 4),
        "hourly": "cloud_cover",
        "current": "cloud_cover",
        "timezone": "auto",
        "forecast_days": "3",
    }, ttl_seconds = 1800)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    return r["json"]


def wx_offset(j):
    if j == None:
        return None
    v = to_float(j.get("utc_offset_seconds", None))
    return int(v) if v != None else None


def cloud_at(j, target, off):
    if j == None:
        return None
    h = j.get("hourly", {})
    times = h.get("time", [])
    vals = h.get("cloud_cover", [])
    if len(times) == 0 or len(vals) == 0:
        return None
    first = parse_iso(times[0])
    if first == None:
        return None
    idx = (target - (first - off)) // 3600
    if idx < 0 or idx >= len(vals):
        return None
    return to_float(vals[idx])


# ------------------------------------------------- how far south it reaches

POLE_LAT = 80.65               # IGRF geomagnetic north pole, current epoch
POLE_LON = -72.68


def geomag_lat(lat, lon):
    """Geomagnetic latitude, which is what the Kp rule is measured in --
    not the geographic latitude on a map. New England sits about nine
    degrees further north magnetically than geographically, which is the
    whole reason Connecticut ever sees an aurora. This is the dipole
    approximation: within about a degree of published corrected geomagnetic
    latitudes across North America and western Europe, and out by four or so
    over Iceland and the South Atlantic, where the real field is least like
    a dipole."""
    a = lat * DEG
    b = POLE_LAT * DEG
    s = (math.sin(a) * math.sin(b) +
         math.cos(a) * math.cos(b) * math.cos((lon - POLE_LON) * DEG))
    if s > 1.0:
        s = 1.0
    if s < -1.0:
        s = -1.0
    return math.abs(math.degrees(math.asin(s)))


HORIZON = 8.0                  # degrees equatorward before the glow dies
OVERHEAD = 2.0                 # degrees inside the oval before it is overhead


def aurora_reach(kp, gm):
    """0 to 1: how much of the oval gets to you. NOAA puts its equatorward
    edge at 66 degrees magnetic at Kp 0, moving two degrees equatorward per
    Kp step, with the glow visible a few hundred kilometres further south
    again -- the eight degrees below.

    The scale does not stop at that edge. Backtested against three shots
    from one camera at one lake in Connecticut: Kp 6.7 a degree and a half
    short of the edge gave moments of naked-eye aurora and a much better
    photograph, while Kp 8.7 two and a half degrees inside it was plainly
    overhead and five times brighter by the exposure the camera chose.
    Stopping the count at the edge scored those two nights the same."""
    if kp == None:
        return None
    m = (gm - (66.0 - 2.0 * kp) + HORIZON) / (HORIZON + OVERHEAD)
    if m < 0.0:
        return 0.0
    if m > 1.0:
        return 1.0
    return m


def kp_needed(gm):
    """The Kp at which aurora_reach first leaves zero here -- the moment any
    of the glow clears your horizon. This is the line drawn across the Kp
    card, and solving it from aurora_reach rather than restating the numbers
    is what stops the line and the verdict ever disagreeing."""
    return (66.0 - HORIZON - gm) / 2.0


# --------------------------------------------------------- tonight's clock
# Both the Kp card and the visibility card have to mean the same four
# moments, or they quietly disagree on screen. They are worked out once,
# here, from timestamps in the data -- never from the render clock.

# Local hours, counting past 24 into the next morning. Kp is published in
# three-hour UTC blocks, so hours three apart are the closest the panel can
# get to four genuinely different numbers.
HOURS = [20, 23, 26, 29]
HOUR_LABELS = ["8P", "11P", "2A", "5A"]

KP_URL = "https://services.swpc.noaa.gov/products/noaa-planetary-k-index-forecast.json"


def kp_rows(resp):
    """The feed has shipped as both a list of objects and a list of rows
    behind a header, so both are read."""
    j = rows_of(resp)
    if j == None:
        return []
    out = []
    if type(j[0]) == "dict":
        for r in j:
            t = parse_iso(r.get("time_tag", None))
            v = to_float(r.get("kp", r.get("kp_index", None)))
            if t != None and v != None:
                out.append([t, v, str(r.get("observed", "predicted"))])
        return out
    for i in range(1, len(j)):
        r = j[i]
        if type(r) != "list" or len(r) < 2:
            continue
        t = parse_iso(r[0])
        v = to_float(r[1])
        if t != None and v != None:
            out.append([t, v, str(r[2]) if len(r) > 2 else "predicted"])
    return out


def kp_at(rows, target):
    """The 3-hour bin the target instant falls in."""
    best = None
    for r in rows:
        if r[0] <= target and target - r[0] < 10800:
            if best == None or r[0] > best[0]:
                best = r
    return best[1] if best != None else None


def tonight(ctx):
    """The four instants, the place, and the feeds both cards read. Always
    returns a dict -- "ok" says whether the four instants are known, and
    "geo" carries the ZIP's own outcome, so the visibility card can name what
    is actually wrong instead of blaming the forecast for a blank ZIP box."""
    rows = kp_rows(http.get(KP_URL, ttl_seconds = 1800))
    geo = geocode(ctx)
    loc = [geo["lat"], geo["lon"]] if geo["ok"] else None
    j = weather(loc)
    auto = wx_offset(j)

    # A ZIP that could not be looked up still names the place well enough to
    # print: the guide's rule is that a location app shows its location, and
    # the typed ZIP is the location when the geocoder is the thing that died.
    label = geo["label"] if geo["ok"] else zip_of(ctx)

    night = {"ok": False, "geo": geo, "label": label, "loc": loc, "wx": j,
             "rows": rows, "auto": auto if auto != None else 0,
             "need": kp_needed(geomag_lat(loc[0], loc[1])) if loc != None else None}

    # "Now" is the last bin the Kp feed still calls observed. If that feed is
    # down, the sky forecast's own clock stands in.
    anchor = 0
    for r in rows:
        if r[2] != "predicted" and r[0] > anchor:
            anchor = r[0]
    if anchor == 0 and j != None and auto != None:
        t = parse_iso(j.get("current", {}).get("time", None))
        if t != None:
            anchor = t - auto
    if anchor == 0:
        return night

    off = auto if auto != None else lon_offset(loc, anchor)
    base = parts_of(anchor + off - 21600)          # the night that is running
    targets = []
    for h in HOURS:
        day = base[2] + (1 if h >= 24 else 0)
        targets.append(epoch_of(base[0], base[1], day, h % 24, 0) - off)

    night["ok"] = True
    night["off"] = off
    night["targets"] = targets
    return night


# -------------------------------------------------------------- wind card

SAMPLE_WIND_TIME = 1789331100      # fixed, so the catalogue thumbnail never
                                   # changes between builds


def sample_wind():
    return {
        "ok": True,
        "demo": True,
        "time": SAMPLE_WIND_TIME,
        "bz": -8.4, "bt": 14.2, "v": 552.0, "n": 6.8,
        "tbz": -1, "tbt": 1, "tv": 1, "tn": 0,
    }


def get_wind():
    mag = fetch_window(MAG_URL)
    wind = fetch_window(WIND_URL)
    if mag == None and wind == None:
        return {"ok": False}

    bz = series(mag, "bz_gsm")
    bt = series(mag, "bt")
    sp = series(wind, "proton_speed")
    de = series(wind, "proton_density")

    # The feed answered, so the card stays live even if a reading is null --
    # a missing value is "--", never a sample number wearing a live face.
    nbz = newest(bz)
    nbt = newest(bt)
    nsp = newest(sp)
    nde = newest(de)

    stamp = 0
    for n in [nbz, nbt, nsp, nde]:
        if n != None and n[0] > stamp:
            stamp = n[0]

    return {
        "ok": True,
        "demo": False,
        "time": stamp,
        "bz": nbz[1] if nbz != None else None,
        "bt": nbt[1] if nbt != None else None,
        "v": nsp[1] if nsp != None else None,
        "n": nde[1] if nde != None else None,
        "tbz": trend(bz, 0.5),
        "tbt": trend(bt, 0.5),
        "tv": trend(sp, 10.0),
        "tn": trend(de, 0.4),
    }


# The hero's arrow, 5x3 -- five rows would land on the glyph below it.
ARROW_UP = "..#..\n.###.\n#####"
ARROW_DOWN = "#####\n.###.\n..#.."
ARROW_FLAT = ".....\n#####\n....."

# The rail's tick, 3x2. The rail has 24px for a label and a four-digit value,
# so the trend gets three pixels of width or it gets dropped.
TICK_UP = ".#.\n###"
TICK_DOWN = "###\n.#."

HERO_ZONE = 38                 # x 0..37 is the hero, a hairline at 38, rail after


def rail_row(c, x0, y, label, value, col, tr):
    """One quiet row of the right rail: label left, value hard against the
    right edge, a 3px trend tick between them only if both still clear.
    The value is placed from its measured width, so "1000" cannot grow
    leftward through the label the first night the wind actually blows."""
    vw = c.text_width(value, "4x5")
    vx = c.width - 1 - vw
    lw = c.text_width(label, "3x4")
    if x0 + lw + 1 > vx:
        c.text(value, x0, y, font = "4x5", color = col)      # no room to label
        return
    c.text(label, x0, y + 1, font = "3x4", color = LABEL)
    c.text(value, vx, y, font = "4x5", color = col)
    if tr != 0 and x0 + lw + 2 + 3 + 1 <= vx:
        c.sprite(TICK_UP if tr > 0 else TICK_DOWN, x0 + lw + 2, y + 2,
                 color = ARROW)


def paint_wind(c, d):
    c.fill(BG)
    # Two draws rather than one string with a space in it: the 3x4 face has
    # no space glyph the validator will vouch for, so the gap is explicit.
    # "SOLAR" is 19px and "WIND" 17px at 3x4; the clock is a fixed 21px
    # right-aligned at x42, so the word gap is 2 and the gap before the clock
    # is 3. At the original gap of 5 they met at x41 and read as "WIND01:41Z".
    c.text("SOLAR", 1, 0, font = "3x4", color = DIM)
    c.text("WIND", 3 + c.text_width("SOLAR", "3x4"), 0, font = "3x4",
           color = DIM)
    if d["demo"]:
        # The sample numbers are deliberately believable, which is exactly why
        # they cannot wear a clock: -8.4 nT under a fresh-looking timestamp is
        # a panel telling the room there is a storm running when the feed is
        # simply down.
        c.text_right("DEMO", 0, font = "3x4", color = "#E8B04A", margin = 1)
    elif d["time"] > 0:
        # The Z is not decoration. The wind card never looks up a location, so
        # this clock is UTC, and an unlabelled 01:21 on a wall reads as local.
        c.text_right(hhmm(d["time"]) + "Z", 0, font = "3x4", color = LABEL,
                     margin = 1)
    c.hline(0, 5, c.width, GRID)
    c.vline(HERO_ZONE, 7, 25, GRID)

    # Hero: BZ. It is the one reading that decides whether anything happens,
    # so it gets the only large face on the card and the only full arrow.
    # 9x12 rather than 10x16 because 7x16, 6x16 and 10x14 have no minus glyph
    # and drop the sign silently -- and an unsigned Bz is the wrong number.
    bz = d["bz"]
    c.text("BZ", 2, 7, font = "4x5", color = LABEL)
    tr = d["tbz"]
    art = ARROW_FLAT
    if tr > 0:
        art = ARROW_UP
    elif tr < 0:
        art = ARROW_DOWN
    c.sprite(art, 14, 8, color = ARROW if tr != 0 else "#3A4568")
    c.text(smart(bz, 1), 2, 14, font = "9x12", color = band_bz(bz))
    c.text("NT", 2, 27, font = "3x4", color = LABEL)

    # The rail: banded, but small and arrowless-by-default on purpose.
    rail_row(c, 41, 8, "BT", smart(d["bt"], 1), band_bt(d["bt"]), d["tbt"])
    rail_row(c, 41, 17, "V", smart(d["v"], 0), band_speed(d["v"]), d["tv"])
    rail_row(c, 41, 26, "N", smart(d["n"], 1), band_density(d["n"]), d["tn"])


def wind(c, ctx):
    d = get_wind()
    if not d["ok"]:
        d = sample_wind()
    paint_wind(c, d)


# ---------------------------------------------------------------- kp card

KP_BASE = 25                   # bar baseline
KP_SPAN = 11                   # rows from the baseline to Kp 9
KP_GUTTER = 7                  # x 0..6 belongs to the "you need" marker


def sample_kp(label):
    return {"ok": True, "demo": True, "vals": [4.33, 5.33, 5.67, 4.67],
            "label": label, "need": None}


def get_kp(night):
    # Sample numbers stand in only when nothing answered at all, which is
    # the no-network render the catalogue uses for a thumbnail. A feed that
    # is reachable but silent gets dashes, so this card and the visibility
    # card never disagree about whether Kp is known.
    if not night["ok"]:
        return {"ok": False}
    vals = []
    for t in night["targets"]:
        vals.append(kp_at(night["rows"], t))
    return {"ok": True, "demo": False, "vals": vals, "label": night["label"],
            "need": night["need"]}


def kp_bar_top(v):
    h = int(v / 9.0 * float(KP_SPAN) + 0.5)
    if h < 0:
        h = 0
    if h > KP_SPAN:
        h = KP_SPAN
    return KP_BASE - h


def paint_kp(c, d):
    c.fill(BG)
    c.text("KP", 1, 0, font = "3x4", color = DIM)
    used = 1 + c.text_width("KP", "3x4")
    if d["demo"]:
        # Same reasoning as the wind card: sample Kp must say so.
        c.text("DEMO", used + 3, 0, font = "3x4", color = "#E8B04A")
        used = used + 3 + c.text_width("DEMO", "3x4")
    # The place, not the UTC offset the old card showed: a location app shows
    # its location, and "AVON CT" says which clock 8P means far better than
    # "UTC-4" did. Measured and fitted, because place names run long
    # ("MECHANICSVILLE VA" is 78px at 4x5, well past the panel).
    lab = fit_place(c, d["label"], "4x5", c.width - 4 - used)
    if lab != "":
        c.text_right(lab, 0, font = "4x5", color = LABEL, margin = 1)
    c.hline(0, 6, c.width, GRID)

    need = d["need"]
    colw = (c.width - KP_GUTTER) // 4

    for i in range(4):
        mid = KP_GUTTER + i * colw + colw // 2
        v = d["vals"][i]
        col = band_kp(v)
        # Hue is how big the storm is; brightness is whether it gets here.
        # A bar under the line is a storm that happens to somebody else.
        if need != None and v != None and v < need:
            col = color.dim(col, 55)

        txt = fixed(v, 1) if v != None else "--"
        c.text(txt, mid - c.text_width(txt, "4x5") // 2, 8, font = "4x5",
               color = col)
        # The empty track is drawn first and left visible. Without it a Kp 2
        # is three lit pixels floating over black with nothing to be small
        # against, and the card reads as broken rather than as a quiet night.
        c.rect(mid - 5, KP_BASE - KP_SPAN, mid + 5, KP_BASE, fill = GRID)
        top = kp_bar_top(v) if v != None else KP_BASE
        c.rect(mid - 5, top, mid + 5, KP_BASE, fill = col)

        lab = HOUR_LABELS[i]
        c.text(lab, mid - c.text_width(lab, "4x5") // 2, 27, font = "4x5",
               color = LABEL)

    # Drawn last so it rides on top of the bars it is judging.
    #
    # need <= 0 means the oval already sits over this ZIP at Kp 0 -- true from
    # Fairbanks north. There is no threshold to draw, and drawing one anyway
    # put the dotted line at y28, under the baseline and through the hour
    # labels. No line, and nothing is dimmed: every bar counts up there.
    if need != None and need > 0.0:
        # A need above Kp 9 (Miami is 11) pins the line to the top of the
        # track rather than above it: at y13 it sat directly under the value
        # row with no buffer, and the row read as underlined.
        ly = kp_bar_top(need) if need <= 9.0 else KP_BASE - KP_SPAN
        if ly < KP_BASE - KP_SPAN:
            ly = KP_BASE - KP_SPAN
        for x in range(KP_GUTTER, c.width, 2):
            c.pixel(x, ly, NEEDC)
        if need <= 9.0:
            n = str(int(need + 0.5))
            c.text(n, 1, ly - 2, font = "3x4", color = NEEDC)


def kp(c, ctx):
    night = tonight(ctx)
    # Without a location there is no local clock, and 8P/11P/2A/5A printed
    # against UTC bins is four hours of silent lie -- the card used to show
    # the zone for exactly this case and the redesign gave that line to the
    # place name. So say what is missing instead.
    #
    # Only when the feed itself answered, though: the render with no inputs
    # and no network is the catalogue thumbnail, and that one wants sample
    # readings rather than a second copy of the same prompt.
    if not night["geo"]["ok"] and len(night["rows"]) > 0:
        nodata(c, night["geo"]["err"])
        return
    d = get_kp(night)
    if not d["ok"]:
        d = sample_kp(night["label"])
    paint_kp(c, d)


# -------------------------------------------------------- visibility card
# Three things decide whether you see anything, and they multiply rather
# than average: a storm too weak to reach your latitude cannot be rescued
# by a clear sky, and an overcast sky cannot be rescued by a Kp 8.

VERDICTS = [
    [70, "HIGH", GREEN],
    [50, "GOOD", "#8FD94F"],
    [30, "MED", YELLOW],
    [0, "LOW", ORANGE],
]


def verdict_of(score):
    v = VERDICTS[len(VERDICTS) - 1]
    for row in VERDICTS:
        if score >= row[0]:
            return row
    return v


def get_view(night):
    # A problem the viewer can fix outranks a transient one. With an empty ZIP
    # box on a dead network both are true, and "NO FORECAST / RETRYING" would
    # send them off to wait for a feed that was never the thing standing in
    # their way.
    err = night["geo"]["err"]
    if err == "NOZIP" or err == "BADZIP" or err == "NOTFOUND":
        return {"ok": False, "why": err}
    if not night["ok"]:
        return {"ok": False, "why": "NOFORECAST"}
    loc = night["loc"]
    if loc == None:
        return {"ok": False, "why": err}
    if night["wx"] == None:
        return {"ok": False, "why": "NOFORECAST"}

    gm = geomag_lat(loc[0], loc[1])

    # Score each hour on its own and keep the best one. A night with one
    # clear window between two banks of cloud is a night worth going out
    # for, and an average would bury it.
    best = -1.0
    at = 0
    graded = False
    for i in range(4):
        t = night["targets"][i]
        cv = cloud_at(night["wx"], t, night["auto"])
        if cv == None:
            continue
        reach = aurora_reach(kp_at(night["rows"], t), gm)
        gate = 1.0
        if reach != None:
            graded = True
            gate = reach
        clear = (100.0 - cv) / 100.0
        dark = 1.0 - 0.65 * moon_washout(t, loc[0], loc[1])
        s = gate * clear * dark
        if s > best:
            best = s
            at = i

    if best < 0.0:
        return {"ok": False, "why": "NOFORECAST"}

    t = night["targets"][at]
    return {
        "ok": True,
        "score": int(best * 100.0 + 0.5),
        "hour": HOUR_LABELS[at],
        "graded": graded,
        "label": night["label"],
        "cloud": cloud_at(night["wx"], t, night["auto"]),
        "lit": moon_illum(t),
        "waxing": moon_phase(t) < 0.5,
        "washed": moon_washout(t, loc[0], loc[1]) > 0.45,
    }


def moon_disc(c, cx, cy, r, lit, waxing):
    """The real terminator: an ellipse whose half-width is the disc's
    half-width scaled by (1 - 2 x illuminated). Waxing lights the right
    limb, waning the left, which is the difference between a moon that
    rises in the evening and one that does not."""
    for dy in range(-r, r + 1):
        half = math.sqrt(float(r * r - dy * dy))
        xt = half * (1.0 - 2.0 * lit)
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > r * r:
                continue
            on = float(dx) >= xt if waxing else float(dx) <= -xt
            c.pixel(cx + dx, cy + dy, "#F2E4C0" if on else "#232A3E")


def curtain(c, top, base, score, col):
    """The app's identity, and the card's hero: an aurora curtain standing on
    `base`. Height carries the score and hue carries the verdict, so a glance
    from across the room answers the question before any number is read.

    The ray pattern is seeded from the score and nothing else -- two sines
    beating against each other. That keeps it deterministic: the same forecast
    always draws the same curtain, which matters on a panel that re-renders
    every ten minutes and would otherwise seem to shimmer at random.

    Three passes per column rather than a pixel loop: 192 draws instead of
    1024, and it gives the ray a bright foot fading to a dim crown, which is
    what a real curtain does."""
    span = base - top
    i = float(score) / 100.0
    if i < 0.0:
        i = 0.0
    if i > 1.0:
        i = 1.0
    peak = 2.0 + i * float(span - 2)
    ph = float(score) * 0.11
    mid = color.dim(col, 55)
    crown = color.dim(col, 25)

    for x in range(c.width):
        fx = float(x)
        # A fast sine cuts the individual rays, about one every 7px, and a
        # slow one is the envelope that groups them into a curtain instead of
        # a comb. They multiply rather than average, which is what puts real
        # gaps between the rays -- averaged, the whole thing read as one
        # smooth green hill.
        w = ((0.40 + 0.60 * math.sin(fx * 0.85 + ph)) *
             (0.55 + 0.45 * math.sin(fx * 0.21 + ph * 0.5)))
        h = int(peak * w + 0.5)
        if h < 1:
            h = 1
        y_top = base - h + 1
        if y_top < top:
            y_top = top
        # vline's third argument is a LENGTH, not an end row.
        c.vline(x, y_top, base - y_top + 1, crown)
        y2 = base - int(float(h) * 0.70)
        if y2 < y_top:
            y2 = y_top
        c.vline(x, y2, base - y2 + 1, mid)
        y3 = base - int(float(h) * 0.35)
        if y3 < y_top:
            y3 = y_top
        c.vline(x, y3, base - y3 + 1, col)


def cloud_deck(c, top, rows, cf, box):
    """The other half of the sky. Stars alone meant a 100%-cloud night drew as
    an empty black rectangle, which looks like a broken panel rather than an
    overcast one; a dim deck across the top rows says "socked in". Horizontal
    runs, not scattered pixels, because runs read as stratus and pixels read
    as noise. Same fixed-LCG discipline as the stars."""
    n = int(18.0 * cf + 0.5)
    if n <= 0:
        return
    seed = 71828182
    for _ in range(n):
        seed = (seed * 1103515245 + 12345) % 2147483648
        y = top + seed % rows
        seed = (seed * 1103515245 + 12345) % 2147483648
        x = seed % c.width
        seed = (seed * 1103515245 + 12345) % 2147483648
        for k in range(4 + seed % 9):
            px = x + k
            if px >= c.width:
                break
            if px >= box[0] and px <= box[2] and y >= box[1] and y <= box[3]:
                continue
            c.pixel(px, y, "#2E3852")


def star_field(c, top, bot, clear, box):
    """The cloud number as pixel art: a clear night gets a full sky, an
    overcast one gets none, and the card reads as overcast from across the
    room before anybody parses a percentage.

    Positions come from a fixed LCG and never from the clock, so only the
    count changes between renders -- the sky must not reshuffle itself every
    ten minutes. Stars landing in `box` are skipped rather than drawn under
    the verdict, and the curtain is painted afterwards, so a bright aurora
    washes the sky out the way a real one does."""
    n = int(26.0 * clear + 0.5)
    if n <= 0:
        return
    seed = 20260916
    shown = 0
    for _ in range(90):
        if shown >= n:
            break
        seed = (seed * 1103515245 + 12345) % 2147483648
        x = seed % c.width
        seed = (seed * 1103515245 + 12345) % 2147483648
        y = top + seed % (bot - top + 1)
        if x >= box[0] and x <= box[2] and y >= box[1] and y <= box[3]:
            continue
        c.pixel(x, y, "#8FA0C8" if shown % 3 == 0 else "#495A80")
        shown = shown + 1


CURTAIN_TOP = 7
CURTAIN_BASE = 22


def paint_view(c, d):
    c.fill(BG)
    # No "AURORA" eyebrow on this card: the curtain below is the identity, and
    # the 23px the word cost left 36 for the place -- not enough for
    # "FAIRBANKS" at 43px, which drew as "FAIRBA..". The location gets the
    # whole header instead, which is the one thing the guide requires a
    # location app to show.
    #
    # "SKY" appears only when Kp never answered: the score is then cloud and
    # moon alone, and the card must not claim to have graded a storm it never
    # saw. 3x4 has no space glyph, so it stays one word.
    right = "" if d["graded"] else "SKY"
    maxw = c.width - 2
    if right != "":
        c.text_right(right, 0, font = "3x4", color = LABEL, margin = 1)
        maxw = maxw - c.text_width(right, "3x4") - 3
    lab = fit_place(c, d["label"], "4x5", maxw)
    if lab != "":
        c.text(lab, 1, 0, font = "4x5", color = DIM)
    c.hline(0, 6, c.width, GRID)

    v = verdict_of(d["score"])
    txt = v[1] + " " + d["hour"]
    cx = c.width // 2
    tw = c.text_width(txt, "6x8")
    # The word's own footprint plus its 1px stroke, kept clear of stars.
    box = [cx - tw // 2 - 1, 10, cx + tw // 2 + 1, 19]

    clear = 0.5 if d["cloud"] == None else (100.0 - d["cloud"]) / 100.0
    cloud_deck(c, CURTAIN_TOP, 5, 1.0 - clear, box)
    star_field(c, CURTAIN_TOP, CURTAIN_BASE - 1, clear, box)
    curtain(c, CURTAIN_TOP, CURTAIN_BASE, d["score"], v[2])

    # The word and the hour ride on the curtain, stroked black so the glyphs
    # keep their black-ground contrast over the rays. The hour is here and not
    # in the footer because the footer has 5px left after the moon and the
    # cloud, and "11P" is 14px.
    # The verdict colour, not white. White is perfectly legible, but it makes
    # HIGH, GOOD and LOW the same shape from across a room, and the curtain
    # carrying the only colour sits mostly below the word where it does not
    # catch the eye. Rendered side by side, the coloured word is the one you
    # can read without reading it. The black stroke keeps it off the rays.
    c.text_stroke(txt, cx, 11, font = "6x8", color = v[2],
                  stroke = "#000000", align = "center")
    c.hline(0, 23, c.width, GRID)

    # Footer: the two things that set the score. The moon is drawn, not
    # labelled -- a lit disc at its real phase says "moon" to anybody.
    moon_disc(c, 4, 28, 3, d["lit"], d["waxing"])
    c.text(str(int(d["lit"] * 100.0 + 0.5)) + "%", 9, 26, font = "4x5",
           color = "#D8C58F" if d["washed"] else LABEL)
    c.icon("cloud", 31, 25, color = DIM)
    cl = "--" if d["cloud"] == None else str(int(d["cloud"] + 0.5)) + "%"
    c.text(cl, 41, 26, font = "4x5", color = DIM)


# ------------------------------------------------------------ the sad path
# Two short uppercase lines, a what and a what-to-do, over a dim curtain --
# the curtain is there so an error screen still says which app it belongs to.

WHY = {
    "NOZIP": ["NO LOCATION", "SET A ZIP"],
    "BADZIP": ["BAD ZIP", "5 DIGITS"],
    "NOTFOUND": ["NO SUCH ZIP", "CHECK IT"],
    "OFFLINE": ["NO NETWORK", "RETRYING"],
    "NOFORECAST": ["NO FORECAST", "RETRYING"],
}


def nodata(c, why):
    lines = WHY.get(why, WHY["NOFORECAST"])
    c.fill(BG)
    curtain(c, 20, 31, 12, "#1B3A5C")
    c.text_fit(lines[0], c.width // 2, 4, ["10x16", "6x8", "5x7", "4x5"],
               color = "#E8B04A", align = "center", maxw = c.width - 4)
    c.text_fit(lines[1], c.width // 2, 15, ["6x8", "5x7", "4x5"],
               color = "#6A7090", align = "center", maxw = c.width - 4)


def visibility(c, ctx):
    d = get_view(tonight(ctx))
    if not d["ok"]:
        nodata(c, d["why"])
        return
    paint_view(c, d)
