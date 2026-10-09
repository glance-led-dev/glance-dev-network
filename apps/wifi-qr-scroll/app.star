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
    w = c.badge(word, x, 1, color = "black", bg = accent, font = "4x5")
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

# Wi-Fi QR - QR encoder verified bit-for-bit against a reference
# implementation and round-tripped through a real scanner.

# ---- the one place the two languages differ -------------------------------
def _chars(s):
    return s.elems()


# ---- GF(256) for Reed-Solomon, primitive polynomial 0x11D -----------------
def _gf_tables():
    exp = [0] * 512
    log = [0] * 256
    x = 1
    for i in range(255):
        exp[i] = x
        log[x] = i
        x = x << 1
        if x & 0x100:
            x = x ^ 0x11D
    for i in range(255, 512):
        exp[i] = exp[i - 255]
    return exp, log

GF_EXP, GF_LOG = _gf_tables()


def _gf_mul(a, b):
    if a == 0 or b == 0:
        return 0
    return GF_EXP[GF_LOG[a] + GF_LOG[b]]


def _rs_generator(n):
    """Generator polynomial for n error-correction codewords."""
    # Coefficients are stored HIGHEST DEGREE FIRST, which is what _rs_encode
    # assumes when it reads gen[i+1]. Building them the other way round yields
    # a reversed polynomial that still looks plausible and silently produces
    # wrong error-correction codewords.
    g = [1]
    for i in range(n):
        # g = g * (x + alpha^i)
        out = [0] * (len(g) + 1)
        for j in range(len(g)):
            out[j] = out[j] ^ g[j]                                # the x term
            out[j + 1] = out[j + 1] ^ _gf_mul(g[j], GF_EXP[i])    # the alpha^i term
        g = out
    return g


def _rs_encode(data, n):
    """The n error-correction codewords for `data`."""
    gen = _rs_generator(n)
    rem = [0] * n
    for b in data:
        factor = b ^ rem[0]
        rem = rem[1:] + [0]
        if factor != 0:
            for i in range(len(gen) - 1):
                rem[i] = rem[i] ^ _gf_mul(gen[i + 1], factor)
    return rem


# ---- version tables (ECC L only; v1-3 are all single-block) ---------------
# version: [modules, total codewords, data codewords, ecc codewords]
VERSIONS = {
    1: [21, 26, 19, 7],
    2: [25, 44, 34, 10],
    3: [29, 70, 55, 15],
}
# Alignment-pattern centre for v2/v3 (v1 has none).
ALIGN_CENTRE = {1: 0, 2: 18, 3: 22}


def _utf8(s):
    """String -> list of byte values. Starlark has no .encode()."""
    out = []
    for ch in _chars(s):
        cp = ord(ch)
        if cp < 0x80:
            out.append(cp)
        elif cp < 0x800:
            out.append(0xC0 | (cp >> 6))
            out.append(0x80 | (cp & 0x3F))
        else:
            out.append(0xE0 | (cp >> 12))
            out.append(0x80 | ((cp >> 6) & 0x3F))
            out.append(0x80 | (cp & 0x3F))
    return out


def _pick_version(nbytes):
    """Smallest version that holds nbytes in byte mode at ECC L, or 0."""
    for v in [1, 2, 3]:
        # 4 bits mode + 8 bits length + 8 bits per byte, rounded up to codewords
        if 2 + nbytes <= VERSIONS[v][2]:
            return v
    return 0


def _bitstream(payload, version):
    """Mode + length + data + terminator + pad, as a list of data codewords."""
    cap = VERSIONS[version][2]
    bits = []
    # byte mode = 0100
    for b in [0, 1, 0, 0]:
        bits.append(b)
    # length: 8 bits for versions 1-9
    for i in range(8):
        bits.append((len(payload) >> (7 - i)) & 1)
    for byte in payload:
        for i in range(8):
            bits.append((byte >> (7 - i)) & 1)
    # terminator, up to 4 zero bits
    for i in range(4):
        if len(bits) >= cap * 8:
            break
        bits.append(0)
    # pad to a byte boundary
    for i in range(8):
        if len(bits) % 8 == 0:
            break
        bits.append(0)
    words = []
    for i in range(0, len(bits), 8):
        v = 0
        for j in range(8):
            v = (v << 1) | bits[i + j]
        words.append(v)
    # alternating pad codewords
    pads = [0xEC, 0x11]
    for i in range(cap):
        if len(words) >= cap:
            break
        words.append(pads[i % 2])
    return words


# ---- module placement -----------------------------------------------------
def _blank(n):
    m, reserved = [], []
    for i in range(n):
        m.append([0] * n)
        reserved.append([0] * n)
    return m, reserved


def _place_finder(m, res, n, r, c):
    for dr in range(-1, 8):
        for dc in range(-1, 8):
            rr, cc = r + dr, c + dc
            if rr < 0 or rr >= n or cc < 0 or cc >= n:
                continue
            on = 0
            if 0 <= dr and dr <= 6 and 0 <= dc and dc <= 6:
                edge = dr == 0 or dr == 6 or dc == 0 or dc == 6
                core = 2 <= dr and dr <= 4 and 2 <= dc and dc <= 4
                on = 1 if (edge or core) else 0
            m[rr][cc] = on
            res[rr][cc] = 1


def _place_alignment(m, res, n, centre):
    if centre == 0:
        return
    for dr in range(-2, 3):
        for dc in range(-2, 3):
            rr, cc = centre + dr, centre + dc
            adr = dr if dr >= 0 else -dr
            adc = dc if dc >= 0 else -dc
            ring = adr == 2 or adc == 2
            m[rr][cc] = 1 if (ring or (dr == 0 and dc == 0)) else 0
            res[rr][cc] = 1


def _place_static(version):
    n = VERSIONS[version][0]
    m, res = _blank(n)
    _place_finder(m, res, n, 0, 0)
    _place_finder(m, res, n, 0, n - 7)
    _place_finder(m, res, n, n - 7, 0)
    _place_alignment(m, res, n, ALIGN_CENTRE[version])
    # timing patterns
    for i in range(8, n - 8):
        bit = 1 if i % 2 == 0 else 0
        m[6][i] = bit
        res[6][i] = 1
        m[i][6] = bit
        res[i][6] = 1
    # the always-dark module
    m[n - 8][8] = 1
    res[n - 8][8] = 1
    # reserve the format-information areas
    for i in range(9):
        if not res[8][i]:
            res[8][i] = 1
        if not res[i][8]:
            res[i][8] = 1
    for i in range(8):
        res[8][n - 1 - i] = 1
        res[n - 1 - i][8] = 1
    return m, res, n


def _mask_bit(mask, r, c):
    if mask == 0:
        return (r + c) % 2 == 0
    if mask == 1:
        return r % 2 == 0
    if mask == 2:
        return c % 3 == 0
    if mask == 3:
        return (r + c) % 3 == 0
    if mask == 4:
        return (r // 2 + c // 3) % 2 == 0
    if mask == 5:
        return (r * c) % 2 + (r * c) % 3 == 0
    if mask == 6:
        return ((r * c) % 2 + (r * c) % 3) % 2 == 0
    return ((r + c) % 2 + (r * c) % 3) % 2 == 0


def _place_data(m, res, n, words, mask):
    bits = []
    for w in words:
        for i in range(8):
            bits.append((w >> (7 - i)) & 1)
    idx = 0
    col = n - 1
    upward = True
    for _ in range(n * 2):
        if col < 1:
            break
        if col == 6:            # the vertical timing column is skipped entirely
            col = col - 1
        for k in range(n):
            row = (n - 1 - k) if upward else k
            for dc in [0, 1]:
                cc = col - dc
                if res[row][cc]:
                    continue
                bit = bits[idx] if idx < len(bits) else 0
                idx = idx + 1
                if _mask_bit(mask, row, cc):
                    bit = bit ^ 1
                m[row][cc] = bit
        col = col - 2
        upward = not upward
    return m


FORMAT_XOR = 0x5412
ECC_L_BITS = 1          # 01


def _format_bits(mask):
    v = (ECC_L_BITS << 3) | mask
    code = v << 10
    for _ in range(5):
        hi = 0
        for b in range(14, 9, -1):
            if code >> b:
                hi = b
                break
        if hi < 10:
            break
        code = code ^ (0x537 << (hi - 10))
    return ((v << 10) | code) ^ FORMAT_XOR


def _place_format(m, n, mask):
    bits = _format_bits(mask)
    for i in range(15):
        # Placement index 0 takes the MOST significant format bit, so the
        # string reads f14..f0 from (8,0) rightwards.
        bit = (bits >> (14 - i)) & 1
        # copy 1, around the top-left finder
        if i < 6:
            m[8][i] = bit
        elif i == 6:
            m[8][7] = bit
        elif i == 7:
            m[8][8] = bit
        elif i == 8:
            m[7][8] = bit
        else:
            m[14 - i][8] = bit
        # copy 2, split between the other two finders. Seven bits go up the
        # left column -- not eight: (n-8, 8) is the permanently dark module and
        # writing format data over it corrupts both.
        if i < 7:
            m[n - 1 - i][8] = bit
        else:
            m[8][n - 15 + i] = bit
    return m


def _penalty(m, n):
    score = 0
    # rule 1: runs of 5+ same-colour modules in a row or column
    for a in range(n):
        for which in [0, 1]:
            run, prev = 0, -1
            for b in range(n):
                v = m[a][b] if which == 0 else m[b][a]
                if v == prev:
                    run = run + 1
                    if run == 5:
                        score = score + 3
                    elif run > 5:
                        score = score + 1
                else:
                    prev, run = v, 1
    # rule 2: 2x2 blocks of one colour
    for r in range(n - 1):
        for c in range(n - 1):
            v = m[r][c]
            if m[r][c + 1] == v and m[r + 1][c] == v and m[r + 1][c + 1] == v:
                score = score + 3
    # rule 3: the 1011101 finder-lookalike, with 4 light modules either side
    pat_a = [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0]
    pat_b = [0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1]
    for a in range(n):
        for b in range(n - 10):
            for which in [0, 1]:
                seg = []
                for k in range(11):
                    seg.append(m[a][b + k] if which == 0 else m[b + k][a])
                if seg == pat_a or seg == pat_b:
                    score = score + 40
    # rule 4: overall dark/light balance
    dark = 0
    for r in range(n):
        for c in range(n):
            dark = dark + m[r][c]
    pct = dark * 100 // (n * n)
    lo = pct if pct % 5 == 0 else pct - (pct % 5)
    k1 = lo - 50
    k2 = lo + 5 - 50
    k1 = k1 if k1 >= 0 else -k1
    k2 = k2 if k2 >= 0 else -k2
    score = score + (k1 if k1 < k2 else k2) // 5 * 10
    return score


def qr_matrix(text):
    """The QR matrix for `text` as a list of rows of 0/1, or None if too long."""
    payload = _utf8(text)
    version = _pick_version(len(payload))
    if version == 0:
        return None
    words = _bitstream(payload, version)
    ecc = _rs_encode(words, VERSIONS[version][3])
    full = words + ecc

    best, best_score = None, -1
    for mask in range(8):
        m, res, n = _place_static(version)
        m = _place_data(m, res, n, full, mask)
        m = _place_format(m, n, mask)
        s = _penalty(m, n)
        if best_score < 0 or s < best_score:
            best, best_score = m, s
    return best


def wifi_payload(ssid, password, security):
    """The standard WIFI: URI a phone camera understands."""
    sec = security.strip().upper()
    if sec == "" or sec == "OPEN" or sec == "NONE":
        sec = "nopass"
    elif sec == "WEP":
        sec = "WEP"
    else:
        sec = "WPA"
    out = "WIFI:T:" + sec + ";S:" + _esc(ssid) + ";"
    if sec != "nopass":
        out = out + "P:" + _esc(password) + ";"
    return out + ";"


def _esc(s):
    """Backslash-escape the characters that terminate a WIFI: field."""
    out = ""
    for ch in _chars(s):
        if ch == "\\" or ch == ";" or ch == "," or ch == ":" or ch == '"':
            out = out + "\\"
        out = out + ch
    return out

# Wi-Fi QR — a sign a guest can scan, or read and type.
#
# The QR encoder above is the real thing: byte mode, ECC L, Reed-Solomon over
# GF(256), all eight mask patterns scored by the spec's penalty rules. It was
# verified bit-for-bit against a reference implementation and every output was
# round-tripped through an actual scanner.
#
# Two geometry facts drive the layout:
#   * The shortest legal payload ("WIFI:T:nopass;S:X;;") is 19 bytes, which is
#     already past version 1's 17-byte capacity. So v1 NEVER occurs and the
#     field is one of exactly two widths: 25 or 29 modules.
#   * A QR needs DARK modules on a LIGHT field, so this is a white block on an
#     otherwise black panel. That inversion is physics, not taste.

SKY = "#78DCFF"

# The standard 3-arc fan aliases into mush at 1px. Two 2px-thick arcs with a
# 1px void between them read as "signal" at arm's length; the diamond is the
# source dot.
WIFI_FAN = """
...#######...
..#########..
.##.......##.
##..#####..##
#..#######..#
...##...##...
..##.....##..
.....###.....
....#####....
.....###.....
"""

# A phone showing a finder pattern, with ticks radiating toward the real code:
# it tells a guest what to DO, which an icon of a network never does.
PHONE = """
.#######.....
#.......#....
#.##.##.#..s.
#.#...#.#.s..
#...#...#..s.
#.#...#.#....
#.##.##.#..s.
#.......#.s..
#.......#..s.
#..ooo..#....
#.......#....
.#######.....
"""
PHONE_LEGEND = {"#": "white", "o": "gray", "s": SKY}

# Font 5x5 is the ONLY bundled font with a complete lowercase alphabet; every
# other one is caps-only. That is what lets a password print in its real case.
# Its whole set is: space $ % + - . 0-9 : A-Z a-z
P5 = " $%+-.0123456789:ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

def typeable(s):
    """True when every character can be drawn in 5x5. A password shown with
    missing or substituted glyphs is worse than no password at all, because a
    guest will type what they see and it will not work."""
    for ch in s.elems():
        if P5.find(ch) < 0:
            return False
    return True

def wifi_state(ctx):
    ssid = str(ctx.inputs.get("ssid", "")).strip()
    pw = str(ctx.inputs.get("password", "")).strip()
    sec = str(ctx.inputs.get("security", "WPA")).strip().upper()
    hidden = str(ctx.inputs.get("hidden", "No")).strip().lower() == "yes"
    st = {"state": "ok", "ssid": ssid, "pw": pw, "sec": sec, "hidden": hidden,
          "label": str(ctx.inputs.get("label", "GUEST WIFI")).strip().upper(),
          "show": str(ctx.inputs.get("showpw", "Yes")).strip().lower() == "yes"}
    if ssid == "":
        st["state"] = "setup"
        return st
    if sec != "OPEN" and sec != "NONE" and pw == "":
        st["state"] = "nopw"
        return st
    payload = wifi_payload(ssid, pw, sec)
    if hidden:
        payload = payload[:len(payload) - 1] + "H:true;;"
    st["payload"] = payload
    st["bytes"] = len(_utf8(payload))
    if st["bytes"] > 53:
        st["state"] = "toolong"
        st["over"] = st["bytes"] - 53
        return st
    st["matrix"] = qr_matrix(payload)
    if st["matrix"] == None:
        st["state"] = "toolong"
        st["over"] = st["bytes"] - 53
    return st

def wifi(c, ctx):
    c.fill("black")
    st = wifi_state(ctx)
    tab(c, "WIFI", SKY)

    if st["state"] != "ok":
        rail(c, OFFLINE if st["state"] == "toolong" else STRUCT)
        if st["state"] == "setup":
            message(c, "ADD YOUR WIFI", "SETTINGS - SSID AND PASSWORD")
        elif st["state"] == "nopw":
            message(c, "ADD YOUR WIFI", "ADD THE PASSWORD")
        else:
            # Actionable, not just "too long": say exactly how much to cut.
            message(c, "WIFI INFO TOO LONG",
                    "SHORTEN NAME AND PASSWORD BY " + str(st["over"]))
        return

    rail(c, SKY)
    m = st["matrix"]
    n = len(m)
    # The field hugs the right edge; only its left boundary moves with version,
    # so an open network hands a couple of pixels back to the name and nothing
    # else in the layout shifts.
    if n == 29:
        fx, ox, oy = 157, 158, 1
    else:
        fx, ox, oy = 159, 161, 3
    c.rect(fx, 0, 187, 31, fill = "white")
    for r in range(n):
        for cc in range(n):
            if m[r][cc]:
                c.pixel(ox + cc, oy + r, "black")

    # The phone + SCAN group keeps a 4px gap off the code; text on the
    # left keeps a 4px buffer before the group and truncates to fit it.
    gl = fx - 4 - 19
    c.text(clip(c, st["label"], "4x5", gl - 4 - 31), 31, 2, font = "4x5", color = "gray")
    c.sprite(WIFI_FAN, 4, 11, color = SKY)
    c.sprite(PHONE, fx - 4 - 13, 6, legend = PHONE_LEGEND)
    c.text("SCAN", fx - 4 - 9, 21, font = "4x5", color = SKY, align = "center")

    f = fit(c, st["ssid"].upper(), ["8x12", "6x8", "4x7"], gl - 4 - 21)
    c.text(f[1], 21, 10, font = f[0], color = "white")

    # A password is shown whole and exact, or not at all.
    if st["sec"] == "OPEN" or st["sec"] == "NONE":
        c.text("OPEN NETWORK - NO PASSWORD", 4, 25, font = "4x5", color = "gray")
    elif not st["show"] or not typeable(st["pw"]):
        c.text("SCAN THE CODE TO JOIN", 4, 25, font = "4x5", color = "gray")
    elif c.text_width(st["pw"], "5x5") <= gl - 4 - 47:
        c.text("PASSWORD", 4, 25, font = "4x5", color = "gray")
        c.text(st["pw"], 47, 25, font = "5x5", color = "white")
    elif c.text_width(st["pw"], "5x5") <= gl - 4 - 27:
        c.text("PASS", 4, 25, font = "4x5", color = "gray")
        c.text(st["pw"], 27, 25, font = "5x5", color = "white")
    else:
        c.text("SCAN THE CODE TO JOIN", 4, 25, font = "4x5", color = "gray")
