# Overhead (192x32)
#
# A live satellite view of your own patch of the planet. GOES-19 is parked
# over 75.2W and GOES-18 over 137.0W, both 35,786 km up, and they photograph
# the Americas every ten minutes. This app puts your corner of that picture
# on the glass, full bleed, with as little chrome in the way as possible.
#
# GETTING A PHOTOGRAPH ONTO A PANEL. http.get carries text, not bytes, and
# c.image() only reads files shipped inside the app -- so a picture from the
# internet looks impossible. It is not. images.weserv.nl will fetch any
# public image, resize it to exactly 192x32 and re-encode it as a PNG whose
# deflate blocks are *stored*, handed back as base64 text. That last part is
# the whole trick: with l=0 there is nothing to inflate, so the decoder
# below is forty lines instead of a zlib implementation. The technique is
# cfdmb's, from rain-watch, which reads weather radar the same way.
#
# WHICH PICTURE. NASA's GIBS serves GOES imagery over WMS, which takes an
# arbitrary bounding box and output size. So the frame can be centred on the
# viewer's ZIP code at any scale, with no tile stitching and no projection
# maths beyond one cosine to stop the longitude span from stretching.
#
# WHICH FRAME. GIBS runs about an hour behind the satellite, and asking it
# for the default time fails roughly one render in five -- it answers 200
# with a 104-byte transparent PNG. Asking for an explicit timestamp did not
# fail once in testing, so the newest frame time is looked up first. The
# full time index is 582 KB, far too big to parse here; a two-day window is
# about 320 bytes and ends with exactly the timestamp wanted.
#
# An hour of lag sounds worse than it is. At the default scale one pixel is
# 17 km, so an hour of a weather system's travel is two or three pixels.
#
# HOW WIDE IS A 6:1 PANEL. Wider than feels right: 32 rows of 5 degrees is
# 555 km tall, which at the same scale makes the picture 3300 km across.
# Push the height much past that and the box runs off the end of the map
# near the poles, where a degree of longitude is short -- so the span is
# capped, and the view closes in rather than running off the edge.
#
# DRAWING IT. 192x32 is 6144 pixels, while a page may emit at most 4096 draw
# ops and no single bitmap may hold more than 4096 cells. c.sprite emits one
# bitmap per colour in its legend, so the frame is quantised to at most 80
# colours and drawn in three 64-wide chunks: a few dozen bitmaps of 2048
# cells each, well inside both limits.
#
# The quantiser has to run in Starlark, which rules out a nearest-colour
# search -- 6144 pixels against 80 colours is half a million comparisons.
# Instead the buckets are fixed and cheap: 32 steps of grey for anything
# near-neutral, which is most of a satellite picture, and 48 coarse chroma
# cells for land, city lights and the sunlit limb. The *colour* of each
# bucket is then the mean of the pixels that landed in it, which costs one
# running total and makes the palette adapt to the frame. Fixed buckets,
# adaptive palette, one pass. Measured against the original it lands three
# times closer than a uniform 4x4x4 colour cube.

WESERV = "https://images.weserv.nl/"
GIBS_WMS = "https://gibs.earthdata.nasa.gov/wms/epsg4326/best/wms.cgi"
GIBS_TIMES = "https://gibs.earthdata.nasa.gov/wmts/epsg4326/best/1.0.0/"
STAR = "https://cdn.star.nesdis.noaa.gov/"
ZIP_URL = "https://api.zippopotam.us/us/"
UA = "GDN-Overhead (glance-led-panel)"

# [GIBS layer, NOAA STAR folder, name, sub-satellite longitude]
EAST = ["GOES-East_ABI_GeoColor", "GOES19", "GOES-EAST", "75.2W"]
WEST = ["GOES-West_ABI_GeoColor", "GOES18", "GOES-WEST", "137.0W"]

ZOOM = {"TIGHT": 3.0, "NORMAL": 5.0, "WIDE": 8.0}
CONTINENT = 10.0            # degrees of latitude on the wide page
WMAX = 120.0                # the widest longitude span worth asking for
STALE = 3 * 3600            # past this, say how old the picture is

# GIBS lists a frame in its index a little before the pixels exist, and the
# placeholder is a 104-byte transparent PNG -- which weserv dutifully
# re-encodes into a full-size black one, so no size check can catch it.
# Start one frame behind the newest listing and walk back if a frame still
# comes back void.
BACKOFF = 600
TRIES = 3

# NOAA's full-disk JPEG carries a caption bar across its bottom 14 rows of
# 339, so the last two rows of the 32-pixel version are dropped.
FD_SRC = 339
FD_ROWS = 30

BG = "#05070C"
INK = "#F4F7FF"
SOFT = "#C3CEE4"
DIM = "#7C879E"
GOLD = "#FFC94A"
AMBER = "#FFB300"
SHADOW = "#000000"

# 80 legend characters. c.sprite treats " " and "." as holes, so neither
# appears here, and nothing here needs escaping inside the scene's JSON.
ALPHA = ("0123456789" +
         "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
         "abcdefghijklmnopqrstuvwxyz" +
         "!#$%&()*+-/:;<=>?@")
NB = 80

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

def f4(v):
    # Four decimal places without relying on a format spec. A ten-thousandth
    # of a degree is about 11 m, far finer than this ever needs.
    neg = v < 0
    if neg:
        v = -v
    n = int(v * 10000.0 + 0.5)
    s = str(n // 10000) + "." + pad(n % 10000, 4)
    return "-" + s if neg else s

def ymd(unix):
    # Civil date from a Unix second, by Howard Hinnant's days_from_civil in
    # reverse. Only used to bracket the frame-time query.
    z = unix // 86400 + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return [y, m, d]

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def iso_day(t):
    return str(t[0]) + "-" + pad(t[1], 2) + "-" + pad(t[2], 2) + "T00:00:00Z"

def when_unix(when):
    return (days_from_civil(int(when[0:4]), int(when[5:7]), int(when[8:10])) * 86400 +
            int(when[11:13]) * 3600 + int(when[14:16]) * 60)

def iso_time(unix):
    t = ymd(unix)
    s = unix % 86400
    return (str(t[0]) + "-" + pad(t[1], 2) + "-" + pad(t[2], 2) + "T" +
            pad(s // 3600, 2) + ":" + pad((s % 3600) // 60, 2) + ":00Z")

def clip(c, s, font, maxw):
    if c.text_width(s, font) <= maxw:
        return s
    out = s
    for _ in range(len(s)):
        if out == "" or c.text_width(out, font) <= maxw:
            break
        out = out[:len(out) - 1]
    return out

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
    """Palette index 0-79. One pass, pure arithmetic, no search."""
    mx = r if r > g else g
    if b > mx:
        mx = b
    mn = r if r < g else g
    if b < mn:
        mn = b
    lum = (r * 77 + g * 151 + b * 28) >> 8
    if mx - mn < 28:
        return lum >> 3                      # 0-31: cloud, snow, sea, night
    if mx == r:
        h6 = 0 if g >= b else 5
    elif mx == g:
        h6 = 1 if b >= r else 2
    else:
        h6 = 3 if r >= g else 4
    return 32 + h6 * 8 + (lum >> 6) * 2 + (1 if mx - mn >= 70 else 0)

def png_quant(b, want_w):
    """[rows of legend characters, legend, brightest channel] for a PNG."""
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
            return None                      # not a stored block; needs l=0
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
            if r > mx:
                mx = r
            if g > mx:
                mx = g
            if bl > mx:
                mx = bl
            chars.append(ALPHA[idx])
        rows.append("".join(chars))
        prev = cur

    legend = {}
    for idx in range(NB):
        s = sums[idx]
        if s[3] > 0:
            legend[ALPHA[idx]] = [s[0] // s[3], s[1] // s[3], s[2] // s[3]]
    return [rows, legend, mx]

def paint(c, got, x0, y0, chunk):
    """Lay the quantised frame down in chunks, under the 4096-cell cap."""
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

# ---------- the feeds ----------

def grab(params, ttl):
    resp = http.get(WESERV, headers = {"User-Agent": UA}, params = params, ttl_seconds = ttl)
    if resp["status_code"] != 200:
        return None
    body = resp.get("body", "")
    if not body.startswith("data:image/png;base64,"):
        return None
    if len(body) < 2000:
        return None          # a transparent frame relayed as a valid PNG
    return b64_bytes(body[22:])

def location(ctx):
    z = str(ctx.inputs.get("zip", "10101")).strip()
    if len(z) != 5 or not z.isdigit():
        return None, "CHECK THE ZIP CODE"
    resp = http.get(ZIP_URL + z, ttl_seconds = 2592000)
    if resp["status_code"] == 0:
        return None, "ZIP LOOKUP DID NOT ANSWER"
    j = resp["json"]
    if resp["status_code"] != 200 or j == None or len(j.get("places", [])) == 0:
        return None, "NO SUCH US ZIP CODE"
    p = j["places"][0]
    return [p["place name"].upper(), p["state abbreviation"].upper(),
            float(p["latitude"]), float(p["longitude"])], None

def bird(lon):
    # GOES-East sees the whole lower 48; west of here GOES-West has the
    # better angle, and it is the only one that sees Alaska and Hawaii.
    return WEST if lon < -112.0 else EAST

def frame_time(sat, ctx):
    a = ymd(ctx.now.unix - 86400)
    b = ymd(ctx.now.unix + 86400)
    url = (GIBS_TIMES + sat[0] + "/default/500m/all/" +
           iso_day(a) + "--" + iso_day(b) + ".xml")
    resp = http.get(url, headers = {"User-Agent": UA}, ttl_seconds = 300)
    if resp["status_code"] != 200:
        return ""
    body = resp.get("body", "")
    i = body.find("<Domain>")
    k = body.find("</Domain>")
    if i < 0 or k <= i:
        return ""
    spans = body[i + 8:k].split(",")
    bits = spans[len(spans) - 1].split("/")
    if len(bits) < 2 or len(bits[1]) < 20:
        return ""
    return bits[1]                      # the end of the newest span

def frame_box(lat, lon, hdeg, w, h):
    """[centre lat, centre lon, half height, half width] in degrees.

    The longitude span is divided by cos(latitude) so a degree across
    matches a degree down on the ground and the picture is not stretched.
    Near the end of the map -- Alaska and Hawaii -- the box is slid back
    onto it rather than narrowed, because narrowing it would collapse the
    wide page onto the close one. The viewer stops being dead centre when
    that happens, which is why the marker is positioned rather than fixed.
    """
    aspect = w * 1.0 / h
    cl = math.cos(lat * math.pi / 180.0)
    half = aspect * hdeg / cl / 2.0
    if half > WMAX / 2.0:
        half = WMAX / 2.0
    vhalf = half * cl / aspect
    lon0 = lon
    if lon0 - half < -180.0:
        lon0 = -180.0 + half
    if lon0 + half > 180.0:
        lon0 = 180.0 - half
    lat0 = lat
    if lat0 - vhalf < -90.0:
        lat0 = -90.0 + vhalf
    if lat0 + vhalf > 90.0:
        lat0 = 90.0 - vhalf
    return [lat0, lon0, vhalf, half]

def mark_xy(box, lat, lon, w, h):
    x = int((lon - (box[1] - box[3])) / (2.0 * box[3]) * w)
    y = int(((box[0] + box[2]) - lat) / (2.0 * box[2]) * h)
    return [min(w - 3, max(2, x)), min(h - 3, max(2, y))]

def one_frame(sat, box, w, h, when):
    # WMS 1.3.0 with CRS=EPSG:4326 wants minlat,minlon,maxlat,maxlon.
    bbox = (f4(box[0] - box[2]) + "," + f4(box[1] - box[3]) + "," +
            f4(box[0] + box[2]) + "," + f4(box[1] + box[3]))
    src = (GIBS_WMS + "?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&LAYERS=" + sat[0] +
           "&STYLES=&CRS=EPSG:4326&BBOX=" + bbox +
           "&WIDTH=" + str(w) + "&HEIGHT=" + str(h) +
           "&FORMAT=image/png&TIME=" + when)
    b = grab({"url": src, "output": "png", "l": "0", "encoding": "base64"}, 300)
    if b == None:
        return None
    got = png_quant(b, w)
    if got == None or got[2] == 0:
        return None          # nothing in it at all: the frame is a placeholder
    return got

def region(sat, box, w, h, newest):
    at = when_unix(newest) - BACKOFF
    for _ in range(TRIES):
        when = iso_time(at)
        got = one_frame(sat, box, w, h, when)
        if got != None:
            return got, when
        at -= BACKOFF
    return None, ""

def hemisphere(sat):
    # weserv applies a manual crop *after* resizing, which would clamp a
    # 32-pixel image rather than trim the source, so the banner is dropped
    # here instead: NOAA's caption occupies the last 14 of 339 rows, which
    # lands below row 30 once the disk is 32 across. The disk itself spans
    # rows 0 to 30, so nothing of the Earth is lost.
    src = STAR + sat[1] + "/ABI/FD/GEOCOLOR/" + str(FD_SRC) + "x" + str(FD_SRC) + ".jpg"
    b = grab({"url": src, "w": "32", "h": "32",
              "output": "png", "l": "0", "encoding": "base64"}, 300)
    if b == None:
        return None
    got = png_quant(b, 32)
    if got == None or got[2] == 0:
        return None
    return [got[0][:FD_ROWS], got[1], got[2]]

# ---------- reading the inputs ----------

def zoom_deg(ctx):
    return ZOOM.get(str(ctx.inputs.get("zoom", "NORMAL")).strip().upper(), 7.0)

def marker_on(ctx):
    return str(ctx.inputs.get("marker", "ON")).strip().upper() != "OFF"

def age_secs(when, ctx):
    return ctx.now.unix - when_unix(when)

# ---------- the screens ----------

def nodata(c, title, sub):
    c.fill(BG)
    c.rect(0, 0, 191, 31, outline = AMBER)
    c.text(title, 96, 8, font = "6x8", color = AMBER, align = "center")
    c.text(clip(c, sub, "4x5", 184), 96, 20, font = "4x5", color = DIM, align = "center")

def target(c, x, y):
    # Small enough not to spoil the picture, outlined so it survives both a
    # white cloud top and a black ocean at night. The centre stays open.
    c.rect(x - 2, y - 2, x + 2, y + 2, outline = SHADOW)
    c.rect(x - 1, y - 1, x + 1, y + 1, outline = INK)

def stamp(c, left, right, right_color):
    if left != "":
        c.text_stroke(clip(c, left, "4x5", 110), 1, 26, font = "4x5",
                      color = SOFT, stroke = SHADOW)
    if right != "":
        c.text_stroke(right, 190, 26, font = "4x5", color = right_color,
                      stroke = SHADOW, align = "right")

def picture(c, ctx, hdeg, label_place):
    c.fill(BG)
    loc, err = location(ctx)
    if loc == None:
        nodata(c, "NO LOCATION", err)
        return
    sat = bird(loc[3])
    when = frame_time(sat, ctx)
    if when == "":
        nodata(c, "NO FRAME INDEX", "GIBS DID NOT ANSWER")
        return
    box = frame_box(loc[2], loc[3], hdeg, 192, 32)
    got, used = region(sat, box, 192, 32, when)
    if got == None:
        nodata(c, "NO PICTURE", "THE " + sat[2] + " FRAME DID NOT ARRIVE")
        return

    paint(c, got, 0, 0, 64)
    if marker_on(ctx):
        at = mark_xy(box, loc[2], loc[3], 192, 32)
        target(c, at[0], at[1])

    left = loc[0] + " " + loc[1] if label_place else sat[2]
    age = age_secs(used, ctx)
    if age > STALE:
        stamp(c, left, str(age // 3600) + "H OLD", AMBER)
    else:
        stamp(c, left, used[11:16] + "Z", SOFT)

# ---------- pages ----------

def close(c, ctx):
    picture(c, ctx, zoom_deg(ctx), True)

def wide(c, ctx):
    picture(c, ctx, CONTINENT, False)

def disk(c, ctx):
    c.fill(BG)
    loc, err = location(ctx)
    sat = bird(loc[3] if loc != None else -75.0)
    got = hemisphere(sat)
    if got == None:
        nodata(c, "NO DISK", "NOAA STAR DID NOT ANSWER")
        return
    paint(c, got, 6, 1, 32)
    c.text("THE WHOLE HEMISPHERE", 48, 2, font = "5x7", color = GOLD)
    c.text(clip(c, sat[2] + ", 35,786 KM UP", "4x5", 143), 48, 12,
           font = "4x5", color = INK)
    c.text(clip(c, "PARKED OVER " + sat[3], "4x5", 143), 48, 19,
           font = "4x5", color = DIM)
    c.text(clip(c, "A NEW PICTURE EVERY 10 MIN", "4x5", 143), 48, 26,
           font = "4x5", color = DIM)
