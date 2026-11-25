# Window (192x32)
#
# A window onto a national park, live. Eight public webcams, and the panel
# shows whichever one the sun is highest over at this minute -- first light
# over the New River Gorge, mid-afternoon on the rim of the Grand Canyon,
# the last of the day on Kilauea.
#
# WHY IT FOLLOWS THE SUN. A webcam panel sounds simple until you look at one
# at two in the morning: every camera in the country is black, fogged, or
# showing infrared mush. Pointing at a single camera means a beautiful panel
# for half the day and a dark rectangle for the other half. Ranking the
# cameras by the sun's altitude and showing the brightest fixes it outright,
# and costs nothing -- solar position is arithmetic, not an API call.
#
# A US-only set still leaves a gap. Kilauea loses the sun around 04:00 UTC
# and the New River Gorge does not get it back until about 12:20, so for
# roughly eight hours there is genuinely nothing to show. Rather than serve
# a black rectangle, those hours get a card naming the next window to catch
# the light and how long until it does.
#
# NOT EVERY CAMERA TELLS THE TRUTH. Two of the cameras I tried -- Zion and
# Isle Royale -- serve a sunlit frame all night long: the feed has stopped
# and the last good picture is still sitting there. Both are left out, but
# the same thing can happen to any of these at any time, and http.get hands
# back no Last-Modified to check against. So every frame is weighed against
# where the sun actually is: bright at midnight, or black at noon, and the
# app moves to the next camera rather than pass it off as live.
#
# GETTING A PHOTOGRAPH ONTO A PANEL. http.get carries text, not bytes, and
# c.image() only reads files shipped inside the app. images.weserv.nl will
# fetch any public image, crop it about a focal point, resize it to exactly
# 192x32 and re-encode it as a PNG with *stored* deflate blocks, handed back
# as base64 -- so there is nothing to inflate and the decoder below is forty
# lines rather than a zlib implementation. The technique is cfdmb's, from
# rain-watch, which reads weather radar the same way.
#
# WHERE TO CUT THE BAND. A 16:9 camera cropped to 6:1 keeps under a third of
# the frame, so which third decides whether the panel is a photograph or a
# stripe of sky. weserv applies a manual crop *after* resizing, which would
# just clamp a 192-pixel image, but fit=cover with a=crop-50-NN crops about a
# focal point before the resize. Every camera carries its own NN, set by eye.

WESERV = "https://images.weserv.nl/"
UA = "GDN-Window (glance-led-panel)"
NPS = "https://www.nps.gov/webcams-"
HVO = "https://volcanoes.usgs.gov/cams/"

# The Air Resources Division network. These are visibility-monitoring
# cameras, which means every one of them is pointed at the best view in the
# park on purpose, and the whole network answers to one URL template. They
# are the reason this app has eighteen windows rather than eight: the first
# sweep only found the cameras that parks embed as plain <img> tags, and
# missed both these and everything behind nps.gov/media/webcam/view.htm.
ARD = "https://www.nps.gov/featurecontent/ard/webcams/images/"

# Grand Canyon Conservancy, by way of the park's own webcam pages.
PIX = "https://cdn.pixelcaster.com/public.pixelcaster.com/snapshots/"

# [name, state, url, lat, lon, vertical focal point %, UTC offset, US DST?]
#
# Ordered east to west, which is the order the sun reaches them. The spread
# is the point: from Acadia at 68W to Kilauea at 156W is 88 degrees, close
# to six hours, so the stretch when nowhere in the list is lit is as short
# as public American cameras allow.
CAMS = [
    ["ACADIA", "ME", ARD + "acad.jpg", 44.35, -68.21, 55, -5, True],
    ["SHENANDOAH", "VA", ARD + "shen.jpg", 38.53, -78.44, 52, -5, True],
    ["GREAT SMOKY MTNS", "TN", ARD + "grsm.jpg", 35.56, -83.50, 55, -5, True],
    ["MAMMOTH CAVE", "KY", ARD + "maca.jpg", 37.19, -86.10, 50, -6, True],
    ["THEODORE ROOSEVELT", "ND", ARD + "thro.jpg", 46.98, -103.54, 55, -6, True],
    ["BIG BEND", "TX", ARD + "bibe.jpg", 29.30, -103.25, 55, -6, True],
    ["GLACIER BASIN", "CO", NPS + "romo/glacier_basin.jpeg", 40.33, -105.60, 50, -7, True],
    ["YELLOWSTONE", "WY", NPS + "yell/west_into.jpg", 44.66, -111.10, 50, -7, True],
    ["GRAND CANYON", "AZ", ARD + "grca.jpg", 36.07, -112.12, 58, -7, False],
    ["KOLB STUDIO", "AZ", PIX + "grandcanyon-2/latest.jpg", 36.06, -112.14, 55, -7, False],
    ["GLACIER", "MT", NPS + "glac/StMaryPTZ.jpg", 48.75, -113.44, 50, -7, True],
    ["YOSEMITE", "CA", ARD + "yose.jpg", 37.75, -119.60, 55, -8, True],
    ["LASSEN VOLCANIC", "CA", NPS + "lavo/kyvc_webcam1.jpg", 40.54, -121.42, 50, -8, True],
    ["MOUNT RAINIER", "WA", ARD + "mora.jpg", 46.79, -121.74, 50, -8, True],
    ["NORTH CASCADES", "WA", ARD + "noca.jpg", 48.68, -121.30, 50, -8, True],
    ["OLYMPIC", "WA", ARD + "olym.jpg", 47.80, -123.40, 50, -8, True],
    ["DENALI", "AK", ARD + "dena.jpg", 63.33, -150.50, 50, -9, True],
    ["KILAUEA", "HI", HVO + "KPcam/images/M.jpg", 19.45, -155.60, 56, -10, False],
]

AUTO = "FOLLOW THE SUN"
NEXT = "THE NEXT BEST LIT"
TRIES = 3                   # how many cameras to try before giving up
DAY = 0.09                  # sin(altitude) above this is proper daylight
DUSK = -0.10                # below this the sun is past civil twilight
DARK_FLOOR = 14             # a daylit frame this dim is a dead camera
BRIGHT_CEIL = 95            # a night frame this bright is a stale one
LEAN = 8                    # fewer colours than this and there is no picture

# weserv's unsharp mask. Averaging a 1920-pixel frame down to 192 leaves a
# landscape looking like fog; at 3 this lifts the standard deviation of
# brightness from 55 to 67 without the haloing that appears at 5. It costs
# nothing, because more local contrast would otherwise mean more colour
# buckets and the cap already bounds those.
SHARP = "3"

BG = "#05070C"
INK = "#F4F7FF"
SOFT = "#C3CEE4"
DIM = "#7C879E"
GOLD = "#FFC94A"
AMBER = "#FFB300"
SHADOW = "#000000"

RAD = 3.141592653589793 / 180.0

ALPHA = ("0123456789" +
         "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
         "abcdefghijklmnopqrstuvwxyz" +
         "!#$%&()*+-/:;<=>?@")
NB = 80

# How many of those eighty buckets a page is allowed to actually use.
#
# Every distinct colour costs one bitmap per chunk, and a bitmap is a row of
# 0/1 integers in the scene JSON, so a 192x32 page costs about 15 KB per
# colour -- and the whole app, every page together, gets 1 MiB. Rendering one
# page at a time never shows this, which is how a two-page app ended up at
# 0.91 MiB with no margin left for a frame that happened to spread wider.
#
# The ceiling is not a quality setting. A photograph that lands in forty
# buckets does not look twice as good as one held to twenty; the tail is a
# handful of pixels each. Measured on real webcam frames, the RMS error
# against the original is 9.4 uncapped and 9.4 at twenty colours -- it does
# not move -- against 31.4 for a uniform 4x4x4 cube.
#
# Twenty is chosen from the worst case rather than from a frame that happened
# to look fine: a colour present in all three chunks of both pages costs
# 2 x 3 x 20 bitmaps of about 6,280 bytes, so the page art can never exceed
# 0.72 MiB however the light falls.
CAP = 20

B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
B64_VAL = {B64[i]: i for i in range(64)}

# ---------- small helpers ----------

def pad(n, width):
    s = str(n)
    for _ in range(width):
        if len(s) >= width:
            break
        s = "0" + s
    return s

def ymd(unix):
    z = unix // 86400 + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [yoe + era * 400 + (1 if m <= 2 else 0), m, d]

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def clip(c, s, font, maxw):
    if c.text_width(s, font) <= maxw:
        return s
    out = s
    for _ in range(len(s)):
        if out == "" or c.text_width(out, font) <= maxw:
            break
        out = out[:len(out) - 1]
    return out

# ---------- clocks ----------

def us_dst(t):
    # Second Sunday in March to the first Sunday in November. The changeover
    # hour itself is not split hairs over; nothing here turns on it.
    p = ymd(t)
    y = p[0]
    m = p[1]
    d = p[2]
    if m < 3 or m > 11:
        return False
    if m > 3 and m < 11:
        return True
    w = (days_from_civil(y, m, 1) + 4) % 7       # 0 = Sunday
    first_sun = 1 + (7 - w) % 7
    if m == 3:
        return d >= first_sun + 7
    return d < first_sun

def clock(unix, cam, h24):
    t = unix + cam[6] * 3600
    if cam[7] and us_dst(t):
        t += 3600
    s = t % 86400
    hh = s // 3600
    mm = (s % 3600) // 60
    if h24:
        return pad(hh, 2) + ":" + pad(mm, 2)
    h12 = hh % 12
    return (str(12 if h12 == 0 else h12) + ":" + pad(mm, 2) +
            (" AM" if hh < 12 else " PM"))

def spell(hours):
    if hours < 0:
        return ""
    h = int(hours)
    m = int((hours - h) * 60.0)
    if h <= 0:
        return str(m) + " MIN"
    return str(h) + "H " + pad(m, 2) + "M"

# ---------- where the sun is ----------

def sun(lat, lon, unix):
    """[sin(altitude), hour angle in degrees, sin(dec), cos(dec)].

    The low-precision solar position from the Astronomical Almanac: good to
    a hundredth of a degree, which is a great deal finer than deciding which
    of eight cameras has the best light."""
    d = (unix - 946728000) / 86400.0                  # days from J2000.0
    g = (357.529 + 0.98560028 * d) * RAD
    q = 280.459 + 0.98564736 * d
    lam = (q + 1.915 * math.sin(g) + 0.020 * math.sin(2.0 * g)) * RAD
    e = (23.439 - 0.00000036 * d) * RAD
    sin_dec = math.sin(e) * math.sin(lam)
    cos_dec = math.sqrt(1.0 - sin_dec * sin_dec)
    ra = math.atan2(math.cos(e) * math.sin(lam), math.cos(lam)) / RAD
    gmst = 18.697374558 + 24.06570982441908 * d
    lst = math.fmod(gmst + lon / 15.0, 24.0)
    if lst < 0.0:
        lst += 24.0
    h = math.fmod(lst * 15.0 - ra + 540.0, 360.0)
    if h < 0.0:
        h += 360.0
    h -= 180.0                                        # -180..180, 0 at noon
    la = lat * RAD
    alt = (math.sin(la) * sin_dec +
           math.cos(la) * cos_dec * math.cos(h * RAD))
    return [alt, h, sin_dec, cos_dec]

def to_sunrise(lat, s):
    """Hours until the sun next clears the horizon here, or -1."""
    la = lat * RAD
    den = math.cos(la) * s[3]
    if den == 0.0:
        return -1.0
    cs = (-0.01454 - math.sin(la) * s[2]) / den
    if cs > 1.0 or cs < -1.0:
        return -1.0                                   # polar day or night
    h0 = math.acos(cs) / RAD
    return math.fmod(-h0 - s[1] + 720.0, 360.0) / 15.0

def ranked(unix):
    """Every camera with its sun, brightest first."""
    out = []
    for cam in CAMS:
        out.append([cam, sun(cam[3], cam[4], unix)])
    return sorted(out, key = lambda r: -r[1][0])

def by_sunrise(unix):
    out = []
    for cam in CAMS:
        s = sun(cam[3], cam[4], unix)
        out.append([cam, s, to_sunrise(cam[3], s)])
    return sorted(out, key = lambda r: r[2] if r[2] >= 0.0 else 999.0)

# ---------- base64 and PNG ----------

def b64_bytes(text):
    out = []
    acc = 0
    bits = 0
    for ch in text.elems():
        v = B64_VAL.get(ch)
        if v == None:
            continue
        acc = (acc << 6 | v) & 0xFFFFFF
        bits += 6
        if bits >= 8:
            bits -= 8
            out.append((acc >> bits) & 0xFF)
    return out

def _u32(b, i):
    return (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3]

def bucket(r, g, b):
    mx = r if r > g else g
    if b > mx:
        mx = b
    mn = r if r < g else g
    if b < mn:
        mn = b
    lum = (r * 77 + g * 151 + b * 28) >> 8
    if mx - mn < 28:
        return lum >> 3
    if mx == r:
        h6 = 0 if g >= b else 5
    elif mx == g:
        h6 = 1 if b >= r else 2
    else:
        h6 = 3 if r >= g else 4
    return 32 + h6 * 8 + (lum >> 6) * 2 + (1 if mx - mn >= 70 else 0)

def squeeze(rows, sums, cap):
    """Hold the page to `cap` colours, and return [rows, legend].

    The buckets are fixed, but how many of them a photograph reaches is not,
    so the cost of a page is whatever the weather decides. This puts a
    ceiling on it: the most populous buckets survive, each thin one is folded
    into the survivor nearest it in colour, and that survivor's mean is
    recomputed over everything it now holds -- so the kept colours shift
    slightly to cover the pixels they inherited rather than staying put.

    Nothing is searched per pixel. The fold is decided once, over at most
    eighty buckets, and applied to the rows as a character substitution.
    """
    used = []
    for i in range(NB):
        if sums[i][3] > 0:
            used.append(i)

    if len(used) > cap:
        order = sorted(used, key = lambda i: -sums[i][3])
        keep = order[:cap]
        swap = {}
        for d in order[cap:]:
            s = sums[d]
            dr = s[0] // s[3]
            dg = s[1] // s[3]
            db = s[2] // s[3]
            best = keep[0]
            bd = -1
            for k in keep:
                t = sums[k]
                er = dr - t[0] // t[3]
                eg = dg - t[1] // t[3]
                eb = db - t[2] // t[3]
                e = er * er + eg * eg + eb * eb
                if bd < 0 or e < bd:
                    bd = e
                    best = k
            swap[ALPHA[d]] = ALPHA[best]
            t = sums[best]
            t[0] += s[0]
            t[1] += s[1]
            t[2] += s[2]
            t[3] += s[3]
        out = []
        for r in rows:
            out.append("".join([swap.get(ch, ch) for ch in r.elems()]))
        rows = out
        used = keep

    legend = {}
    for i in used:
        s = sums[i]
        legend[ALPHA[i]] = [s[0] // s[3], s[1] // s[3], s[2] // s[3]]
    return [rows, legend]

def png_quant(b, want_w, cap):
    """[rows of legend characters, legend, brightest channel, mean]."""
    if len(b) < 33 or b[1] != 80 or b[2] != 78 or b[3] != 71:
        return None
    w = _u32(b, 16)
    h = _u32(b, 20)
    if w != want_w or b[24] != 8 or (b[25] != 2 and b[25] != 6) or b[28] != 0:
        return None
    bpp = 3 if b[25] == 2 else 4

    z = []
    i = 8
    for _ in range(64):
        if i + 8 > len(b):
            break
        n = _u32(b, i)
        if b[i + 4] == 73 and b[i + 5] == 68 and b[i + 6] == 65 and b[i + 7] == 84:
            z += b[i + 8:i + 8 + n]
        i += 12 + n

    raw = []
    j = 2
    for _ in range(4096):
        if j + 5 > len(z):
            break
        hdr = z[j]
        if (hdr >> 1) & 3 != 0:
            return None
        ln = z[j + 1] | (z[j + 2] << 8)
        raw += z[j + 5:j + 5 + ln]
        j += 5 + ln
        if hdr & 1:
            break

    stride = w * bpp
    if len(raw) < h * (stride + 1):
        return None

    sums = []
    for _ in range(NB):
        sums.append([0, 0, 0, 0])

    rows = []
    mx = 0
    tot = 0
    prev = [0] * stride
    for y in range(h):
        f = raw[y * (stride + 1)]
        line = raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)]
        cur = []
        for k in range(stride):
            a = cur[k - bpp] if k >= bpp else 0
            up = prev[k]
            if f == 0:
                v = line[k]
            elif f == 1:
                v = line[k] + a
            elif f == 2:
                v = line[k] + up
            elif f == 3:
                v = line[k] + (a + up) // 2
            else:
                ul = prev[k - bpp] if k >= bpp else 0
                pp = a + up - ul
                pa = abs(pp - a)
                pb = abs(pp - up)
                pc = abs(pp - ul)
                v = line[k] + (a if pa <= pb and pa <= pc else (up if pb <= pc else ul))
            cur.append(v & 0xFF)

        chars = []
        for x in range(w):
            r = cur[x * bpp]
            g = cur[x * bpp + 1]
            bl = cur[x * bpp + 2]
            idx = bucket(r, g, bl)
            s = sums[idx]
            s[0] += r
            s[1] += g
            s[2] += bl
            s[3] += 1
            tot += r + g + bl
            if r > mx:
                mx = r
            if g > mx:
                mx = g
            if bl > mx:
                mx = bl
            chars.append(ALPHA[idx])
        rows.append("".join(chars))
        prev = cur

    held = squeeze(rows, sums, cap)
    return [held[0], held[1], mx, tot // (w * h * 3)]

def paint(c, got, x0, y0, chunk):
    rows = got[0]
    legend = got[1]
    w = len(rows[0])
    n = (w + chunk - 1) // chunk
    for ci in range(n):
        a = ci * chunk
        part = []
        for r in rows:
            part.append(r[a:a + chunk])
        c.sprite(part, x0 + a, y0, legend = legend)

# ---------- the cameras ----------

def shot(cam):
    resp = http.get(WESERV, headers = {"User-Agent": UA}, ttl_seconds = 240,
                    params = {"url": cam[2], "w": "192", "h": "32",
                              "fit": "cover", "a": "crop-50-" + str(cam[5]),
                              "sharp": SHARP,
                              "output": "png", "l": "0", "encoding": "base64"})
    if resp["status_code"] != 200:
        return None
    body = resp.get("body", "")
    if not body.startswith("data:image/png;base64,") or len(body) < 2000:
        return None
    return png_quant(b64_bytes(body[22:]), 192, CAP)

def honest(got, alt):
    """Is there a picture here, and does it match where the sun actually is?

    Three ways a camera lies, and none of them is an HTTP error. It can be
    dead and serve black. It can be frozen and serve yesterday's sunshine at
    midnight. And it can serve a flat card that says IMAGE UNAVAILABLE,
    which is bright, plausible and has no landscape in it whatever -- the
    Bryce Canyon camera was doing exactly that when this was written, and a
    whited-out lens at Crater Lake came through as three colours.

    The first two are caught by comparing the frame with the sun. The third
    is caught by counting colours: the quantiser is allowed twenty and a
    real landscape uses all of them, while a flat card or a white-out uses a
    handful. Nothing here needs a second request or a clock the camera owns.
    """
    if got[2] == 0:
        return False
    if len(got[1]) < LEAN:
        return False        # a flat card, a white-out, or a lens cap
    if alt > DAY and got[3] < DARK_FLOOR:
        return False        # broad daylight and the lens is black
    if alt < DUSK and got[3] > BRIGHT_CEIL:
        return False        # long past dusk and still sunlit: a stale frame
    return True

def best(order, start):
    """The first camera from `start` that answers with a believable frame."""
    for k in range(TRIES):
        i = start + k
        if i >= len(order):
            break
        got = shot(order[i][0])
        if got != None and honest(got, order[i][1][0]):
            return [order[i][0], order[i][1], got]
    return None

# ---------- the screens ----------

def nodata(c, title, sub):
    c.fill(BG)
    c.rect(0, 0, 191, 31, outline = AMBER)
    c.text(title, 96, 8, font = "6x8", color = AMBER, align = "center")
    c.text(clip(c, sub, "4x5", 184), 96, 20, font = "4x5", color = DIM, align = "center")

def caption(c, cam, unix, h24, lit):
    left = cam[0] + " " + cam[1]
    c.text_stroke(clip(c, left, "4x5", 120), 1, 26, font = "4x5",
                  color = SOFT, stroke = SHADOW)
    c.text_stroke(clock(unix, cam, h24), 190, 26, font = "4x5",
                  color = SOFT if lit else GOLD, stroke = SHADOW, align = "right")

def night_card(c, ctx, h24):
    # Nothing in the country is lit. Say so, and say what is next.
    c.fill(BG)
    q = by_sunrise(ctx.now.unix)
    c.text("EVERY WINDOW IS DARK", 96, 3, font = "5x7", color = GOLD, align = "center")
    row = q[0]
    if row[2] < 0.0:
        c.text("THE SUN IS A WHILE OFF", 96, 15, font = "4x5", color = DIM, align = "center")
        return
    c.text(clip(c, "FIRST LIGHT AT " + row[0][0] + " " + row[0][1], "4x5", 188),
           96, 14, font = "4x5", color = INK, align = "center")
    c.text(clip(c, "IN " + spell(row[2]) + "  -  " + clock(ctx.now.unix, row[0], h24) + " THERE",
                "4x5", 188),
           96, 23, font = "4x5", color = DIM, align = "center")

def sunrise_board(c, ctx, h24):
    c.fill(BG)
    c.text("NEXT LIGHT", 1, 1, font = "4x5", color = GOLD)
    c.line(0, 7, 191, 7, "#1B2436")
    q = by_sunrise(ctx.now.unix)
    for i in range(3):
        if i >= len(q):
            break
        row = q[i]
        y = 10 + i * 7
        c.text(clip(c, row[0][0] + " " + row[0][1], "4x5", 130), 1, y,
               font = "4x5", color = INK if i == 0 else DIM)
        c.text(spell(row[2]) if row[2] >= 0.0 else "-", 190, y,
               font = "4x5", color = GOLD if i == 0 else DIM, align = "right")

# ---------- pages ----------

def h24_on(ctx):
    return str(ctx.inputs.get("clock", "12 HOUR")).strip().upper().startswith("24")

def named(ctx, key, fallback):
    """The camera a setting names, or None for 'let the sun decide'."""
    want = str(ctx.inputs.get(key, fallback)).strip().upper()
    if want == "" or want == AUTO or want == NEXT:
        return None
    for cam in CAMS:
        if cam[0] == want:
            return cam
    return None

def pinned(c, ctx, cam, h24):
    """A camera the viewer asked for by name, shown whatever the light."""
    s = sun(cam[3], cam[4], ctx.now.unix)
    got = shot(cam)
    if got == None:
        nodata(c, "NO PICTURE", cam[0] + " DID NOT ANSWER")
        return
    if not honest(got, s[0]):
        nodata(c, "NOT LIVE", "THE " + cam[0] + " FEED HAS STOPPED")
        return
    paint(c, got, 0, 0, 64)
    caption(c, cam, ctx.now.unix, h24, s[0] > DUSK)

def show(c, ctx, slot):
    c.fill(BG)
    h24 = h24_on(ctx)
    pick = named(ctx, "place", AUTO) if slot == 0 else named(ctx, "second", NEXT)
    if pick != None:
        pinned(c, ctx, pick, h24)
        return

    order = ranked(ctx.now.unix)
    start = slot
    # Whatever the other page is showing is not a candidate here, or a
    # viewer who pinned one window would see it twice.
    other = named(ctx, "second", NEXT) if slot == 0 else named(ctx, "place", AUTO)
    if other != None:
        order = [r for r in order if r[0][0] != other[0]]
        start = 0

    if order[0][1][0] < DUSK:
        if slot == 0:
            night_card(c, ctx, h24)
        else:
            sunrise_board(c, ctx, h24)
        return

    found = best(order, start)
    if found == None:
        nodata(c, "NO PICTURE", "NO CAMERA ANSWERED WITH A LIVE FRAME")
        return
    paint(c, found[2], 0, 0, 64)
    caption(c, found[0], ctx.now.unix, h24, True)

def view(c, ctx):
    show(c, ctx, 0)

def elsewhere(c, ctx):
    show(c, ctx, 1)
