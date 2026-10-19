# Sleep Panel — last night's sleep, drawn elsewhere, shown here.
#
# The numbers live on a phone (HealthKit has no wall API), so a helper
# draws a fresh 64x32 PNG each morning — "SLEEP 86" and "8H 50M" baked
# into the picture — and hosts it at a stable URL. This app's whole job
# is to fetch that picture and put it on the panel:
#
#   feed URL -> images.weserv.nl (resize to exactly 64x32, base64 PNG)
#            -> the platform's stored-block PNG decoder (same one as
#               rain-watch and sxm-now-playing)
#            -> one rect per run of same-coloured pixels.
#
# Anything goes wrong — no URL set, feed down, picture undecodable —
# and the panel falls back to a calm placeholder rather than going
# blank: the label in gold and one small word about why.

UA = {"User-Agent": "glance-dev-network (glance-led.com)"}
BG = "#08090D"
GOLD = "#E8B33A"
DIM = "#8A8AA8"

# ---------- PNG decoding (base64 text -> rows of #RRGGBB) ----------
# Same decoder as rain-watch / sxm-now-playing: the proxy returns an
# uncompressed PNG, so its zlib stream is stored blocks and decoding is
# base64 + unfiltering rows.

B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
B64_VAL = {B64[i]: i for i in range(64)}


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


def _hex2(n):
    s = "0123456789ABCDEF"
    return s[n // 16] + s[n % 16]


def png_pixels(b):
    # Rows of "#RRGGBB" for an 8-bit RGB/RGBA PNG with stored deflate
    # blocks, or None for anything else.
    if len(b) < 33 or b[1] != 80 or b[2] != 78 or b[3] != 71:
        return None
    w = _u32(b, 16)
    h = _u32(b, 20)
    if b[24] != 8 or (b[25] != 2 and b[25] != 6) or b[28] != 0:
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
    rows = []
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
                v = (line[k] + (a + up) // 2)
            else:
                ul = prev[k - bpp] if k >= bpp else 0
                pp = a + up - ul
                pa = abs(pp - a)
                pb = abs(pp - up)
                pc = abs(pp - ul)
                v = line[k] + (a if pa <= pb and pa <= pc else (up if pb <= pc else ul))
            cur.append(v & 0xFF)
        rows.append(["#" + _hex2(cur[x * bpp]) + _hex2(cur[x * bpp + 1]) + _hex2(cur[x * bpp + 2]) for x in range(w)])
        prev = cur
    return rows


def draw_rows(c, rows):
    # One rect per run of same-coloured pixels keeps the op count down.
    for y in range(len(rows)):
        row = rows[y]
        x = 0
        for _ in range(len(row)):
            if x >= len(row):
                break
            e = x
            for _ in range(len(row)):
                if e + 1 < len(row) and row[e + 1] == row[x]:
                    e += 1
                else:
                    break
            c.rect(x, y, e, y, fill = row[x])
            x = e + 1


def placeholder(c, label, sub):
    c.fill(BG)
    c.text_fit(label, c.width // 2, 4, ["10x16", "7x12", "6x8"],
               color = GOLD, align = "center", maxw = c.width - 2)
    c.text_fit(sub, c.width // 2, 24, ["4x5", "3x4"], color = DIM,
               align = "center", maxw = c.width - 2)


def panel(c, ctx):
    label = str(ctx.inputs.get("label", "SLEEP")).strip().upper()
    if label == "":
        label = "SLEEP"
    url = str(ctx.inputs.get("feedurl", "")).strip()
    if url == "":
        placeholder(c, label, "SET FEED URL")
        return
    if url.startswith("https://"):
        src = url[8:]
    elif url.startswith("http://"):
        src = url[7:]
    else:
        placeholder(c, label, "BAD FEED URL")
        return
    resp = http.get(
        "https://images.weserv.nl/",
        headers = UA,
        params = {"url": src, "w": "64", "h": "32", "fit": "cover",
                  "output": "png", "l": "0", "encoding": "base64"},
        ttl_seconds = 1800,
    )
    body = resp.get("body", "")
    if resp["status_code"] != 200 or not body.startswith("data:image/png;base64,"):
        placeholder(c, label, "FEED DOWN")
        return
    rows = png_pixels(b64_bytes(body[22:]))
    if rows == None or len(rows) < 32:
        placeholder(c, label, "FEED DOWN")
        return
    draw_rows(c, rows)
