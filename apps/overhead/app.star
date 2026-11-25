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
ZIP_URL = "https://api.zippopotam.us/us/"
UA = "GDN-Overhead (glance-led-panel)"

# [GeoColor layer, infrared layer, name, sub-satellite longitude]
#
# GeoColor is the photograph: cloud by day, and by night the city lights,
# which is the best thing on the panel. Band 13 is clean infrared, which
# measures how cold the cloud tops are -- grey where the sky is quiet, then
# green, yellow and red as the tops climb. It is the same sky through a
# different eye, it means something page one cannot say, and because it
# reads temperature rather than light it is just as good at 3am.
EAST = ["GOES-East_ABI_GeoColor", "GOES-East_ABI_Band13_Clean_Infrared",
        "GOES-EAST", "75.2W"]
WEST = ["GOES-West_ABI_GeoColor", "GOES-West_ABI_Band13_Clean_Infrared",
        "GOES-WEST", "137.0W"]

ZOOM = {"TIGHT": 3.0, "NORMAL": 5.0, "WIDE": 8.0}
STORM = 9.0                 # degrees of latitude on the storm-tops page
WMAX = 120.0                # the widest longitude span worth asking for
STALE = 3 * 3600            # past this, say how old the picture is

# weserv's unsharp mask, applied before the image is handed over. A 192x32
# panel throws away almost everything a 1920-pixel frame knows, and the
# averaging that does it leaves cloud looking like fog. Measured on real
# frames this lifts the standard deviation of brightness from 53 to 70
# without the haloing that shows up at 5.
SHARP = "3"

# GIBS lists a frame in its index a little before the pixels exist, and the
# placeholder is a 104-byte transparent PNG -- which weserv dutifully
# re-encodes into a full-size black one, so no size check can catch it.
# Start one frame behind the newest listing and walk back if a frame still
# comes back void.
BACKOFF = 600
TRIES = 3

# The state lines. Solid amber looked like a road atlas laid over the sky:
# at 192x32 a one-pixel line is proportionally six times the weight it has on
# a screen, and it won rather than helped. Copper, and dotted on alternate
# pixels, places the weather without swallowing it -- and the dotting keys
# off (x + y) rather than distance along a segment, so the pattern stays
# aligned where outlines meet instead of beating against itself.
LINE = "#B87333"

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

# How many of those eighty buckets a page is allowed to actually use.
#
# Every distinct colour costs one bitmap per chunk, and a bitmap is a row of
# 0/1 integers in the scene JSON, so a 192x32 page costs about 15 KB per
# colour -- and the whole app, all three pages together, gets 1 MiB. Rendering
# one page at a time never shows this; three pages of photograph came to
# 1.31 MiB and would not load at all. Two pages and a line budget fit.
#
# The ceiling is not a quality setting. A frame that lands in forty buckets
# does not look twice as good as one held to twenty; the tail is a handful of
# pixels each. Measured on real GOES frames, capping at 20 moves the RMS
# error against the original from 5.6 to 8.7, against 31.4 for a uniform
# 4x4x4 cube. Twenty is chosen from the worst case rather than from a frame
# that happened to look fine: the two pages can never exceed 0.72 MiB of art
# however the cloud falls, which leaves room for the state lines.
CAP = 20

# THE STATE LINES. Without them a 192x32 strip of cloud is a grey smear --
# beautiful, but you cannot tell whether the weather is over you or over the
# next state. NASA's own reference layers are no help: Reference_Features
# draws nothing at all through WMS, and the Coastlines layer put 19 pixels on
# a 6144-pixel panel. So the outlines are carried here and drawn directly, in
# a colour chosen to read over both grey cloud and the infrared palette.
#
# Source: the US Census cartographic boundary file, simplified with
# Douglas-Peucker at 0.15 degrees and quantised to sixteenths of a degree --
# about 7 km, well inside one pixel at any zoom this app offers. Each ring is
# "<lat>,<lon>|<dlat><dlon>..." in sixteenths, two characters per step.
#
# It costs one line op per visible segment: 138 of them at the close zoom,
# 432 at the storm zoom, against a 4096-op page limit.
BORDER_CH = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-./:;<=>?@[]^_{}~'
BORDER_BIAS = 45
BORDERS = (
    '560,-1398|i.0ubeVki2Zmfepccgje)g~npiiv;882,-2106|ljglfike;887,-2109|djnh;903,-2128|fnld;902,-2138|hp' +
    'ZtZqaioTfnferchfmnrchgpi;889,-2140|ipfgld;911,-2143|jgixdqeRoike;904,-2146|odgtWcofkl;901,-2154|qVre' +
    'lmgrQm;932,-2155|hqcnhecmcY(bfm;917,-2174|dmieni;931,-2180|g!ZnlWeiidqXmn;963,-2353|cVov;969,-2361|c' +
    'fjfno;1124,-2365|e~iqk!a_0i0i0iRij;dgV*dlmwpnluH[K&a-UkZXqckkhalcmkgaojhfobjpoiqPsgtLteSmlUpgkVZvfZv' +
    'KqIlmohcWo8hNpTgbmZdVmijtqUdOmgffcpfdemiLWJiSpwjWsrogm-nTYMSSdRdhfwcWdhW9beaGffinddgUeemfaLiemhZaibm' +
    'fdjjZgkgdgmeGlhmoi#y*kxejirmdmlr.mhrywmlolhfPmdZerWgdmcaLjfklsfkmrZfDtRklohjbpchflmkeionjqwrog&pvi!n' +
    'ouYjrndYHmVgMlModnlmJy~iyiscfglh;ntjVkjoWbzmdnlkBqbt4mpnjk?%>jzp#i*r)dzeanxcwj;ffe$k.e+;928,-2447|jc' +
    'qsesfigU;921,-2463|kmkehomniqgmeiioUEqWpqgn;906,-2473|felm;895,-2490|ekjdll;885,-2558|bcpo;886,-2568' +
    '|glgamiin;880,-2596|hfjl;1018,-2599|ifil;872,-2605|glkf;869,-2649|fhlj;866,-2652|icio;966,-2662|gtej' +
    'ebpMlz;864,-2662|hlecjpbHoykdkjjt;851,-2701|nrgpbUmg;846,-2716|ieim;916,-2722|gfkl;843,-2731|ggkk;10' +
    '19,-2748|i)c*cTqOhUni;838,-2759|gfkl;834,-2778|hqja;836,-2789|jneTls;830,-2824|glgalgjp;831,-2834|eg' +
    'mk;831,-2850|gnfgnf;848,-2994|eGmmi);592,-1745|0i0ifiiC#0iSnnseqlopra$ggsyji~i[;584,-1512|i~i-fjddis' +
    'fiHPZdglbgi0igrijb~ili;672,-1972|i~ir0iei0~O~XqUYXmf2ucpTngqBri#OthmawjfgjbxVwgpa#nrgix;656,-1727|i~' +
    'i~iq0iOii0i0iK~i%ii!;673,-1169|h$ZibFzkip;637,-1207|cgSqiY%gjo;624,-1233|fili;496,-1368|iqdkg~fipmgq' +
    '0(QiRgZchZtdidzcgftbongclgymySmcbNtSgPlkrei>;560,-1330|dfH/TsMZkabglgk1reripm~Wjii_;303,-2490|ketfql' +
    'WzZV;336,-2505|cqicog;339,-2512|hdjn;347,-2527|cjiemgkn;356,-2551|dkjbmn;784,-1857|SiZnV(RejuWoaro)e' +
    'n4ii0i0ib?klc$vuY}iiy;680,-1450|i~ikVn0ifiabWggbdhkbfdtfqUtmjZ!Vqkopqgowniob;668,-1376|i#0ifihYVYmec' +
    'Vlafcpjqp~imij);696,-1462|enaiWxbegXakZamdh0iO(ctavli~i];640,-1630|i~i~i#fpeecq9ii0i0iD~lni;620,-134' +
    '2|iyVocqSHk0iIfiiMtpgpvshvovemvsjsnicx;528,-1498|i^WlYaYgi:dgaoedhqccdtgdpZcelbeeuRebkK$nzZyiip;689,' +
    '-1131|me<gptxouueolsfngkMihodhaqaRlfeglYchdWkfVX;636,-1272|i~iyNkisbfhYmikcvipmecZfXlnVqmlarchTcWri;' +
    '686,-1135|flbebpisghfQqejAtmh;lo;668,-1335|i0iYxsxdzmpsckyrY+ViYYgmqufnOkidUY;732,-1368|fglk;722,-14' +
    '01|vZs7w@hmZakrcqgtn+ejiwbkhqjPfimVbPlgWW;768,-1421|fcosfe;747,-1472|idYidZdmXfW&ami0i4/inblnqh~Yi>o' +
    'iilXofukvZ(lue#cQTO;560,-1416|go0ceiKkfQqcnkiEsksq%e(xi/;650,-1469|eoYjasdjhrXeawbieoSYiYnnlhi0iG~io' +
    'ammkdsZj~i$;784,-1665|0iOii0i0iKaimdcKqZuchWzmvLrdyii~i~i~i~i$;688,-1653|i~i>d/XrOmWri0i0iOyiiC<iiu;' +
    '672,-1872|i~im0i0idifhkYQk~0%2~inii~in;725,-1137|CkemcYjQ*omqtljn;658,-1188|goachmXgWXsWrvobpjopep;5' +
    '92,-1719|i~i.0h8ii0iVfkiHaiiU~i~inii+;720,-1174|8kJeheeqnxflbFpjpSrai0iImirwpfj]lpthtyk;;585,-1296|i' +
    '~i^bkfTixejcVcmeehXWViZxQiQneg0iarrr-poit;784,-1556|0tdii0i0iC~ioii~i~i(;672,-1288|MiTdbUcfkfZenZgVq' +
    'Q{ij&cxs<;592,-1601|i~i~ij0kYinWeQmZfes4ld;ii0ieqii~im;739,-1971|gnckgqp~iri=eoMXfo9gi0i0iHvcyo>lnph' +
    'o;676,-1276|eii~i-YtXaapbRi0iD@imu;667,-1139|fjiflk;672,-1144|dmdehctjin;561,-1324|j-dmi!T!UVTKxY-Fo' +
    'r;735,-1665|i~i~i>dddp9ibffloWgWmZi0i0ih~imi;584,-1409|lig~i~iybcZHZZi0i0ia)ui);584,-1629|i/DifnY_lm' +
    'erm!c#JiRrOdgXmeTYeYjXenicPVOojSqSxd@DkUUTsOxc%Gk~iw~i/ii$;672,-1795|i!Sii<0iOii0i8~i[ii:;720,-1144|' +
    'bheaWdVhiV@gi:;608,-1206|ikUWpjpr;631,-1254|drlmcpYfbzViibgtckj0i0i7x-cnn&!tfnuxmi;784,-1873|0keid0i' +
    '0idogmPml+Vljd/fnZjtlyai~i~in;773,-1963|fjlh;777,-1968|kjekkf;650,-1288|UiiyZiq%cpfhnZeiWTldQXdMuVqg' +
    'inrmglolpwxn;745,-1447|U~dgenZatzMWMhi0ihmbqiucuMtlnenrsim)fhfp;720,-1745|i~i[0iOii0i0iK~i%ii<;288,-' +
    '1063|hWphkkg)cfiY' +
    '')

BORDER_VAL = {BORDER_CH[i]: i for i in range(len(BORDER_CH))}

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

def squeeze(rows, sums, cap):
    """Hold the page to `cap` colours, and return [rows, legend].

    The buckets are fixed, but how many of them a frame reaches is not, so
    the cost of a page would otherwise be whatever the cloud decides. This
    puts a ceiling on it: the most populous buckets survive, each thin one is
    folded into the survivor nearest it in colour, and that survivor's mean
    is recomputed over everything it now holds -- so the kept colours shift
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

    held = squeeze(rows, sums, cap)
    return [held[0], held[1], mx]

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

def coastlines(c, box, w, h, color):
    """Draw the state and coast outlines that fall inside this frame.

    One pass over the packed table, straight into panel coordinates. A
    segment is skipped when both ends land on the same pixel, which at this
    scale is most of them, and when both ends are off the same edge -- so
    the op count follows what is actually visible rather than the size of
    the table.
    """
    lat0 = box[0] + box[2]
    lon0 = box[1] - box[3]
    sx = w / (2.0 * box[3])
    sy = h / (2.0 * box[2])
    for ring in BORDERS.split(";"):
        bar = ring.find("|")
        if bar < 0:
            continue
        comma = ring.find(",")
        la = int(ring[:comma])
        lo = int(ring[comma + 1:bar])
        body = ring[bar + 1:]
        px = int((lo / 16.0 - lon0) * sx)
        py = int((lat0 - la / 16.0) * sy)
        for i in range(0, len(body) - 1, 2):
            la += BORDER_VAL[body[i]] - BORDER_BIAS
            lo += BORDER_VAL[body[i + 1]] - BORDER_BIAS
            x = int((lo / 16.0 - lon0) * sx)
            y = int((lat0 - la / 16.0) * sy)
            if x != px or y != py:
                if not ((x < 0 and px < 0) or (x >= w and px >= w) or
                        (y < 0 and py < 0) or (y >= h and py >= h)):
                    dotted(c, px, py, x, y, color, w, h)
            px = x
            py = y

def dotted(c, x0, y0, x1, y1, color, w, h):
    """One segment, drawn on alternate pixels of a checkerboard."""
    dx = x1 - x0
    dy = y1 - y0
    steps = dx if dx >= 0 else -dx
    ady = dy if dy >= 0 else -dy
    if ady > steps:
        steps = ady
    if steps == 0:
        if x0 >= 0 and x0 < w and y0 >= 0 and y0 < h and (x0 + y0) % 2 == 0:
            c.pixel(x0, y0, color)
        return
    for s in range(steps + 1):
        x = x0 + dx * s // steps
        y = y0 + dy * s // steps
        if x >= 0 and x < w and y >= 0 and y < h and (x + y) % 2 == 0:
            c.pixel(x, y, color)

def one_frame(layer, box, w, h, when):
    # WMS 1.3.0 with CRS=EPSG:4326 wants minlat,minlon,maxlat,maxlon.
    bbox = (f4(box[0] - box[2]) + "," + f4(box[1] - box[3]) + "," +
            f4(box[0] + box[2]) + "," + f4(box[1] + box[3]))
    src = (GIBS_WMS + "?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&LAYERS=" + layer +
           "&STYLES=&CRS=EPSG:4326&BBOX=" + bbox +
           "&WIDTH=" + str(w) + "&HEIGHT=" + str(h) +
           "&FORMAT=image/png&TIME=" + when)
    b = grab({"url": src, "output": "png", "l": "0", "encoding": "base64",
              "sharp": SHARP}, 300)
    if b == None:
        return None
    got = png_quant(b, w, CAP)
    if got == None or got[2] == 0:
        return None          # nothing in it at all: the frame is a placeholder
    return got

def region(layer, box, w, h, newest):
    at = when_unix(newest) - BACKOFF
    for _ in range(TRIES):
        when = iso_time(at)
        got = one_frame(layer, box, w, h, when)
        if got != None:
            return got, when
        at -= BACKOFF
    return None, ""

# ---------- reading the inputs ----------

def zoom_deg(ctx):
    return ZOOM.get(str(ctx.inputs.get("zoom", "NORMAL")).strip().upper(), 7.0)

def marker_on(ctx):
    return str(ctx.inputs.get("marker", "ON")).strip().upper() != "OFF"

def lines_on(ctx):
    return str(ctx.inputs.get("lines", "ON")).strip().upper() != "OFF"

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

def picture(c, ctx, which, hdeg, label):
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
    got, used = region(sat[which], box, 192, 32, when)
    if got == None:
        nodata(c, "NO PICTURE", "THE " + sat[2] + " FRAME DID NOT ARRIVE")
        return

    paint(c, got, 0, 0, 64)
    # Lines over the picture but under the marker and the caption, so the
    # place you live is never hidden by a state boundary running through it.
    if lines_on(ctx):
        coastlines(c, box, 192, 32, LINE)
    if marker_on(ctx):
        at = mark_xy(box, loc[2], loc[3], 192, 32)
        target(c, at[0], at[1])

    left = loc[0] + " " + loc[1] if label == "" else label
    age = age_secs(used, ctx)
    if age > STALE:
        stamp(c, left, str(age // 3600) + "H OLD", AMBER)
    else:
        stamp(c, left, used[11:16] + "Z", SOFT)

# ---------- pages ----------

def close(c, ctx):
    # GeoColor: cloud by day, city lights by night, your ZIP in the middle.
    picture(c, ctx, 0, zoom_deg(ctx), "")

def storm(c, ctx):
    # The same sky as cloud-top temperature, pulled back a little because
    # weather you care about is usually still a state away.
    picture(c, ctx, 1, STORM, "STORM TOPS")
