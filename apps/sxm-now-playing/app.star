# SiriusXM Now Playing (192x32)
#
# What's on right now on four SiriusXM channels: the album cover (or the
# channel number on a genre-colored tile when there's no cover), the song
# title, the artist and how long ago it started. Data from xmplaylist.com (https://xmplaylist.com/docs), an
# unaffiliated third party that tracks SiriusXM's on-air rotation; no
# SiriusXM account needed. GET /api/station/{deeplink} returns the
# station's recent plays newest-first, so results[0] is "now playing".
#
# Stations come from two light inputs: a short genre dropdown, and a text
# box of channel numbers ("30, 23, 33, 18"). "My Channels" (the
# default) uses the text box; any genre instead shows four of that
# genre's stations, a different four each hour. Both inputs have
# defaults, so the app shows real stations even with no settings at all.
# The channel number -> deeplink table lives here rather than in a
# dropdown, regenerated from GET https://xmplaylist.com/api/station.

USER_AGENT = "GDN-SXM-NowPlaying (glance-led-panel)"
# Four channels, not five: each costs up to two uncached requests per
# refresh (now playing + cover), and GDN allows eight.
NSLOTS = 4
DEFAULT_CHANNELS = "30, 23, 33, 18"
DEFAULT_GENRE = "My Channels"

# Dropdown label -> the xmplaylist genre tag behind it.
GENRES = {
    "Rock": "rock",
    "Pop": "pop",
    "Hip-Hop & R&B": "hiphop",
    "Country": "country",
    "Jazz & Standards": "jazz",
    "Dance & Electronic": "dance",
    "Latin & World": "world",
    "Canadian": "canadian",
    "Comedy": "comedy",
    "Christian": "christian",
    "Kids": "kids",
}

# A loose palette per genre for the channel tile (not SiriusXM branding).
GENRE_COLORS = {
    "rock": "#D7263D",
    "pop": "#FF3FA4",
    "hiphop": "#FF8C1A",
    "country": "#C98B2E",
    "jazz": "#5B5BFF",
    "dance": "#00C2E0",
    "world": "#13B58C",
    "canadian": "#E8E8E8",
    "comedy": "#FFD31A",
    "christian": "#9C7BFF",
    "kids": "#4FCB2E",
    "holiday": "#1E9E46",
}
DEFAULT_COLOR = "#777777"

# Channel number -> (xmplaylist deeplink, genre).
CHANNELS = {
    "2": ("siriusxmhits1", "pop"),
    "3": ("unwellmusic", "pop"),
    "4": ("lifewithjohnmayer", "pop"),
    "5": ("thepulse", "pop"),
    "6": ("poprocks", "pop"),
    "7": ("70son7", "pop"),
    "8": ("80son8", "pop"),
    "9": ("90son9", "pop"),
    "10": ("pop2k", "pop"),
    "11": ("the10sspot", "pop"),
    "12": ("kellyclarksonconnection", "pop"),
    "13": ("pitbullsglobalization", "pop"),
    "14": ("thebridge", "rock"),
    "15": ("yachtrockradio", "pop"),
    "16": ("theblend", "pop"),
    "17": ("thecoffeehouse", "pop"),
    "18": ("thebeatleschannel", "rock"),
    "19": ("bobmarleystuffgong", "rock"),
    "20": ("estreetradio", "rock"),
    "21": ("undergroundgarage", "rock"),
    "22": ("pearljamradio", "rock"),
    "23": ("gratefuldead", "rock"),
    "24": ("radiomargaritaville", "rock"),
    "25": ("classicrewind", "rock"),
    "26": ("classicvinyl", "rock"),
    "27": ("alt2k", "rock"),
    "28": ("thespectrum", "rock"),
    "29": ("phishradio", "rock"),
    "30": ("davematthewsbandradio", "rock"),
    "31": ("tompettyradio", "rock"),
    "32": ("u2xradio", "rock"),
    "33": ("1stwave", "rock"),
    "34": ("lithium", "rock"),
    "35": ("siriusxmu", "rock"),
    "36": ("altnation", "rock"),
    "37": ("octane", "rock"),
    "38": ("ozzysboneyard", "rock"),
    "39": ("hairnation", "rock"),
    "40": ("liquidmetal", "rock"),
    "41": ("siriusxmturbo", "rock"),
    "42": ("maximummetallica", "rock"),
    "43": ("rockthebellsradio", "hiphop"),
    "44": ("hiphopnation", "hiphop"),
    "45": ("shade45", "hiphop"),
    "46": ("theheat", "hiphop"),
    "47": ("heartsoul", "hiphop"),
    "48": ("theflow", "hiphop"),
    "49": ("flex2k", "hiphop"),
    "50": ("siriusxmfly", "hiphop"),
    "51": ("thegroove", "hiphop"),
    "52": ("bpm", "dance"),
    "53": ("diplosrevolution", "dance"),
    "54": ("studio54radio", "dance"),
    "55": ("siriusxmchill", "dance"),
    "56": ("thehighway", "country"),
    "57": ("y2kountry", "country"),
    "58": ("primecountry", "country"),
    "59": ("noshoesradio", "country"),
    "60": ("carriescountry", "country"),
    "61": ("williesroadhouse", "country"),
    "62": ("outlawcountry", "country"),
    "63": ("chrisstapletonradio", "country"),
    "64": ("morganwallenradio", "country"),
    "65": ("bluegrassjunction", "country"),
    "66": ("symphonyhall", "jazz"),
    "67": ("realjazz", "jazz"),
    "68": ("watercolors", "jazz"),
    "69": ("onbroadway", "jazz"),
    "70": ("siriuslysinatra", "jazz"),
    "71": ("40sjunction", "jazz"),
    "72": ("50sgold", "pop"),
    "73": ("60sgold", "pop"),
    "74": ("smokeyssoultown", "hiphop"),
    "75": ("bbkingsbluesville", "jazz"),
    "76": ("elvisradio", "pop"),
    "77": ("kirkfranklinspraise", "christian"),
    "78": ("themessage", "christian"),
    "79": ("messageworship", "christian"),
    "102": ("sebastianmaniscalcocmdy", "comedy"),
    "103": ("kevinhartslolradio", "comedy"),
    "104": ("conanobrienradio", "comedy"),
    "105": ("netflixisajokeradio", "comedy"),
    "106": ("comedyroundup", "comedy"),
    "107": ("comedycentralradio", "comedy"),
    "108": ("comedygreats", "comedy"),
    "109": ("purecomedy", "comedy"),
    "133": ("disneyhits", "kids"),
    "134": ("kidsplace", "kids"),
    "135": ("kidzbopradio", "kids"),
    "136": ("cocomelonfriends", "kids"),
    "139": ("siriusxmcomedyclub", "comedy"),
    "144": ("siriusxm144", "pop"),
    "145": ("talkingheadsradio", "pop"),
    "146": ("escape", "jazz"),
    "147": ("billgaithersenlighten", "christian"),
    "149": ("caliente", "world"),
    "150": ("aguila", "world"),
    "152": ("latinvault", "world"),
    "153": ("mixtapenorth", "canadian"),
    "154": ("theverge", "canadian"),
    "155": ("topofthecountryradio", "canadian"),
    "156": ("influencefranco", "canadian"),
    "157": ("attitudefranco", "canadian"),
    "158": ("racinesmusicales", "canadian"),
    "159": ("theindigiverse", "canadian"),
    "168": ("holycultureradio", "christian"),
    "300": ("siriusxm300", "pop"),
    "301": ("roadtripradio", "pop"),
    "302": ("andycohenskikilounge", "pop"),
    "305": ("mosaic", "pop"),
    "308": ("deeptracks", "rock"),
    "309": ("jamon309", "rock"),
    "312": ("bonjoviradio", "rock"),
    "314": ("greendaysidiotnation", "rock"),
    "315": ("redhotchilipeppers", "rock"),
    "330": ("siriusxmsilk330", "hiphop"),
    "332": ("shaggyboombasticradio", "hiphop"),
    "341": ("utopia", "dance"),
    "349": ("bakersfieldbeat", "country"),
    "350": ("redwhitebooze", "country"),
    "359": ("northamericana", "canadian"),
    "362": ("grownfolkjamz", "hiphop"),
    "505": ("talkingheadsradio", "rock"),
    "550": ("poptop500", "pop"),
    "551": ("80son8top500", "pop"),
    "552": ("90son9top500", "pop"),
    "553": ("classicrocktop1000", "rock"),
    "556": ("hiphopchronicles", "hiphop"),
    "558": ("countrytop1000", "country"),
    "560": ("billboardtop500", "pop"),
    "602": ("holidaytraditions", "holiday"),
    "702": ("disneyjrradio", "kids"),
    "703": ("pandoranow", "pop"),
    "705": ("siriusxmkpop", "pop"),
    "708": ("siriusxmlove", "pop"),
    "709": ("siriusxo", "pop"),
    "710": ("theloft", "rock"),
    "711": ("pettysburiedtreasure", "rock"),
    "713": ("rockbar", "rock"),
    "715": ("classicrockparty", "rock"),
    "721": ("steviescoolestsongs", "rock"),
    "724": ("soundcloudradio", "hiphop"),
    "735": ("steveaokisremixradio", "dance"),
    "736": ("astateofarmin", "dance"),
    "737": ("expertsonlyradio", "dance"),
    "739": ("saviorsundaydaily", "country"),
    "740": ("outsidersradio", "country"),
    "741": ("thevillage", "country"),
    "744": ("metoperaradio", "jazz"),
    "745": ("siriusxmpops", "jazz"),
    "746": ("spa", "jazz"),
    "757": ("thetragicallyhipradio", "canadian"),
    "758": ("iceberg", "canadian"),
    "759": ("lestubesfranco", "canadian"),
    "760": ("chuchoscubabeyond", "world"),
    "761": ("celiacruzazucar", "world"),
    "762": ("caricia", "world"),
    "763": ("viva", "world"),
    "764": ("latidos", "world"),
    "765": ("flownacion", "world"),
    "766": ("luna", "pop"),
    "767": ("rumbonmusic", "world"),
    "768": ("lakueva", "world"),
    "769": ("siriusxmdhamaka", "hiphop"),
}

# ---------- inputs ----------

def _s(ctx, key, fallback):
    # An unset input can come back as None even with a fallback given.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    v = str(v).strip()
    return v if v != "" else fallback

def parse_numbers(text):
    # "30, 23,33 / ch 18" -> ["30", "23", "33", "18"]: any run of digits is
    # a channel, everything else is a separator.
    out = []
    cur = ""
    for ch in (text + ",").elems():
        if ch >= "0" and ch <= "9":
            cur += ch
        elif cur != "":
            out.append(str(int(cur)))
            cur = ""
    return out

def genre_numbers(tag):
    nums = [n for n in CHANNELS if CHANNELS[n][1] == tag]
    return sorted(nums, key = lambda n: int(n))

def slot_numbers(ctx):
    # The channel numbers shown this hour, in page order.
    tag = GENRES.get(_s(ctx, "genre", DEFAULT_GENRE))
    if tag != None:
        nums = genre_numbers(tag)
        if len(nums) <= NSLOTS:
            start = 0
        else:
            # A different run each hour, walking the whole genre.
            start = (ctx.now.unix // 3600 * NSLOTS) % len(nums)
        return [nums[(start + i) % len(nums)] for i in range(NSLOTS)]
    nums = parse_numbers(_s(ctx, "channels", DEFAULT_CHANNELS))[:NSLOTS]
    if len(nums) == 0:
        nums = parse_numbers(DEFAULT_CHANNELS)
    # The page count is fixed, so a shorter list repeats to fill it.
    return [nums[i % len(nums)] for i in range(NSLOTS)]

def genre_label(ctx):
    g = _s(ctx, "genre", DEFAULT_GENRE)
    return g if GENRES.get(g) != None else None

# ---------- network ----------

def fetch_now_playing(deeplink):
    return http.get(
        "https://xmplaylist.com/api/station/" + deeplink,
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 60,
    )

# ---------- text ----------

# The bitmap fonts are ASCII only, so accented letters fold to plain ones.
FOLD = {
    "á": "A", "à": "A", "â": "A", "ä": "A", "ã": "A", "å": "A", "Á": "A", "À": "A", "Ä": "A",
    "é": "E", "è": "E", "ê": "E", "ë": "E", "É": "E", "È": "E",
    "í": "I", "ì": "I", "î": "I", "ï": "I", "Í": "I",
    "ó": "O", "ò": "O", "ô": "O", "ö": "O", "õ": "O", "ø": "O", "Ó": "O", "Ö": "O",
    "ú": "U", "ù": "U", "û": "U", "ü": "U", "Ú": "U", "Ü": "U",
    "ñ": "N", "Ñ": "N", "ç": "C", "Ç": "C", "ß": "SS",
    "’": "'", "‘": "'", "“": "\"", "”": "\"", "–": "-", "—": "-", "…": "...",
}

# Plain characters no font here can draw, swapped for ones they can.
SWAP = {"[": "(", "]": ")", "{": "(", "}": ")", ";": ",", "\"": "''", "_": " ", "`": "'", "~": "-"}

def clean(text):
    out = ""
    for ch in text.elems():
        if FOLD.get(ch) != None:
            out += FOLD[ch]
        elif SWAP.get(ch) != None:
            out += SWAP[ch]
        elif ord(ch) < 128:
            out += ch
    return " ".join(out.upper().split())

# The big title font is missing many glyphs (even Q), so it's only used
# when it can draw every character.
NO_GLYPH_7X10 = "#%&'()*+,/<=>?@Q\^|"

def big_ok(text):
    for ch in text.elems():
        if ch in NO_GLYPH_7X10:
            return False
    return True

def fit_text(c, text, font, maxw):
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        cand = text[:i].rstrip() + ".."
        if c.text_width(cand, font) <= maxw:
            return cand
    return ""

NAME_SUFFIXES = [" RADIO", " CHANNEL"]

def fit_name(c, name, maxw):
    # Full name in 5x7, then without a trailing "RADIO"/"CHANNEL", then the
    # narrower 4x7, and only then truncated.
    short = name
    for suf in NAME_SUFFIXES:
        if short.endswith(suf) and len(short) > len(suf) + 3:
            short = short[:-len(suf)]
    for font in ["5x7", "4x7"]:
        for n in [name, short]:
            if c.text_width(n, font) <= maxw:
                return font, n
    return "4x7", fit_text(c, short, "4x7", maxw)

def wrap2(c, text, font, maxw):
    # Word-wraps into at most two lines; whatever doesn't fit ends in "..".
    words = text.split(" ")
    first = ""
    i = 0
    for _ in range(len(words)):
        cand = words[i] if first == "" else first + " " + words[i]
        if c.text_width(cand, font) > maxw:
            break
        first = cand
        i += 1
        if i >= len(words):
            break
    if first == "":
        return [fit_text(c, text, font, maxw)]
    rest = " ".join(words[i:])
    if rest == "":
        return [first]
    return [first, fit_text(c, rest, font, maxw)]

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def concert_date(artist):
    # Live-archive channels put the show in the artist slot: "7.22.72
    # SEATTLE, WA" -> ("JUL 22 - SEATTLE, WA", "1972"), else None.
    sp = artist.find(" ")
    if sp < 5:
        return None
    parts = artist[:sp].split(".")
    if len(parts) != 3:
        return None
    for x in parts:
        if not x.isdigit() or len(x) > 2:
            return None
    m = int(parts[0])
    d = int(parts[1])
    if m < 1 or m > 12 or d < 1 or d > 31 or len(parts[2]) != 2:
        return None
    year = ("19" if int(parts[2]) >= 30 else "20") + parts[2]
    return MONTHS[m - 1] + " " + str(d) + " - " + artist[sp + 1:].strip(), year

VERSION_WORDS = ["REMASTER", "MONO", "STEREO", "RADIO EDIT", "SINGLE VERSION", "ALBUM VERSION", " MIX"]

def _is_version(tag):
    for w in VERSION_WORDS:
        if w in tag:
            return True
    return False

def strip_versions(title):
    # Drops release tags like "- 2009 REMASTER" or "(MONO)"; live and
    # demo tags stay, since they say something about the performance.
    for _ in range(3):
        i = title.rfind(" - ")
        if i > 0 and _is_version(title[i:]):
            title = title[:i].rstrip()
            continue
        if title.endswith(")") or title.endswith("]"):
            o = title.rfind("(" if title.endswith(")") else "[")
            if o > 0 and _is_version(" " + title[o:]):
                title = title[:o].rstrip()
                continue
        break
    return title

def strip_feat(title):
    # "(FEAT. X)" / "[WITH X]" repeat the artist line, so they come off.
    for tag in ["(FEAT", "[FEAT", "(FT.", "(WITH ", "[WITH "]:
        i = title.find(tag)
        if i > 0:
            return title[:i].rstrip()
    return title

def split_year(title):
    # Decade channels tag titles with the year, e.g. "LIKE A PRAYER (89)".
    if len(title) > 5 and title.endswith(")") and title[-4] == "(":
        yy = title[-3:-1]
        if yy.isdigit():
            year = ("19" if int(yy) >= 30 else "20") + yy
            return title[:-4].rstrip(), year
    return title, None

# ---------- color ----------

def _hex2(n):
    s = "0123456789ABCDEF"
    return s[n // 16] + s[n % 16]

def _rgb(h):
    return int(h[1:3], 16), int(h[3:5], 16), int(h[5:7], 16)

def mix(a, b, t):
    ar, ag, ab = _rgb(a)
    br, bg, bb = _rgb(b)
    return "#" + _hex2(int(ar + (br - ar) * t)) + _hex2(int(ag + (bg - ag) * t)) + _hex2(int(ab + (bb - ab) * t))

def brightness(h):
    r, g, b = _rgb(h)
    return (r * 299 + g * 587 + b * 114) // 1000

def hue(t):
    # t in [0,1) around the color wheel at full saturation.
    h6 = t * 6.0
    i = int(h6) % 6
    f = h6 - int(h6)
    up = int(255 * f)
    dn = 255 - up
    rgb = [(255, up, 0), (dn, 255, 0), (0, 255, up), (0, dn, 255), (up, 0, 255), (255, 0, dn)][i]
    return "#" + _hex2(rgb[0]) + _hex2(rgb[1]) + _hex2(rgb[2])

def genre_color(tag):
    return GENRE_COLORS.get(tag, DEFAULT_COLOR)

# ---------- "N MIN AGO" ----------

def days_from_civil(y, m, d):
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def iso_to_epoch(iso):
    # xmplaylist timestamps are UTC ("...Z").
    return (days_from_civil(int(iso[0:4]), int(iso[5:7]), int(iso[8:10])) * 86400 +
            int(iso[11:13]) * 3600 + int(iso[14:16]) * 60 + int(iso[17:19]))

# Minutes since the last song started before the page calls it a talk or
# DJ segment; jam-band channels get longer, since one jam can run 30+.
TALK_AFTER = 20
JAM_TALK_AFTER = 90
JAM_CHANNELS = ["22", "23", "29", "30", "309"]
FULL_SHOW_MAX = 240

def age_minutes(iso, now_unix):
    if iso == None or len(iso) < 19:
        return None
    return (now_unix - iso_to_epoch(iso)) // 60

def ago_label(iso, now_unix):
    if iso == None or len(iso) < 19:
        return ""
    mins = (now_unix - iso_to_epoch(iso)) // 60
    if mins < 1:
        return "JUST NOW"
    if mins < 60:
        return str(mins) + " MIN AGO"
    return str(mins // 60) + " HR AGO"

# ---------- shared art ----------

EQ_PATTERN = [3, 5, 2, 6, 4, 7, 3, 5, 6, 2, 4, 7, 5, 3, 6, 4]

def draw_eq(c, x, base_y, bars, max_h, color, seed):
    # Little level-meter bars growing up from base_y; the seed shifts the
    # pattern so neighboring pages don't look identical.
    for i in range(bars):
        h = EQ_PATTERN[(i + seed) % len(EQ_PATTERN)] * max_h // 7
        if h < 1:
            h = 1
        c.rect(x + i * 2, base_y - h + 1, x + i * 2, base_y, fill = color)

# ---------- album art ----------
# xmplaylist gives each track's Spotify cover URL. images.weserv.nl shrinks
# it to ART x ART and returns an uncompressed PNG as base64 text, since
# http.get only carries text. Uncompressed means the PNG's zlib stream is
# "stored" blocks, so decoding is just base64 + unpacking rows.

ART = 32
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

def png_pixels(b):
    # Returns rows of "#RRGGBB" for an 8-bit RGB/RGBA PNG with stored
    # deflate blocks, or None for anything else.
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
                v = line[k] + (a + up) // 2
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

def fetch_art(url):
    if url == None or not url.startswith("https://"):
        return None
    resp = http.get(
        "https://images.weserv.nl/",
        headers = {"User-Agent": USER_AGENT},
        params = {"url": url[8:], "w": str(ART), "h": str(ART), "fit": "cover", "sharp": "1", "output": "png", "l": "0", "encoding": "base64"},
        ttl_seconds = 604800,
    )
    body = resp.get("body", "")
    if resp["status_code"] != 200 or not body.startswith("data:image/png;base64,"):
        return None
    return png_pixels(b64_bytes(body[22:]))

def draw_art(c, rows, x0, y0):
    # One rect per run of same-colored pixels keeps the op count down.
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
            c.rect(x0 + x, y0 + y, x0 + e, y0 + y, fill = row[x])
            x = e + 1

def abs(n):
    return -n if n < 0 else n

# ---------- channel tile ----------

TILE_W = 34
NUM_FONTS = ["10x16_bold", "8x12", "6x8", "4x5"]

def num_font(c, number):
    for f in NUM_FONTS:
        if c.text_width(number, f) <= TILE_W - 4:
            return f
    return NUM_FONTS[-1]

def draw_tile(c, number, tag, seed):
    col = genre_color(tag)
    c.gradient_rect(0, 0, TILE_W - 1, 31, mix(col, "#FFFFFF", 0.18), mix(col, "#000000", 0.55), horizontal = False)
    ink = "#000000" if brightness(col) > 140 else "#FFFFFF"
    c.text(number, TILE_W // 2, 4, font = num_font(c, number), color = ink, align = "center")
    draw_eq(c, 6, 28, 12, 6, mix(ink, col, 0.35), seed)

# ---------- pages ----------

def draw_channel(c, ctx, index):
    c.fill("#000000")
    slots = slot_numbers(ctx)
    number = slots[index]
    entry = CHANNELS.get(number)
    # A channel listed again steps back through its history: the second
    # "30" is the song before the one now playing, and so on. The repeat
    # reuses the cached lookup, so it only costs a cover.
    back = len([n for n in slots[:index] if n == number])
    if entry == None:
        # Real channels xmplaylist doesn't follow (talk, news, sports) land
        # here too, so this is a notice, not an error.
        c.gradient_rect(0, 0, TILE_W - 1, 31, "#4A4A4A", "#1C1C1C", horizontal = False)
        c.text(number, TILE_W // 2, 4, font = num_font(c, number), color = "#BBBBBB", align = "center")
        draw_eq(c, 6, 28, 12, 6, "#555555", index * 3)
        x0 = TILE_W + 3
        c.text("CHANNEL " + number, x0, 1, font = "5x7", color = "#AAAAAA")
        c.line(x0, 9, 191, 9, "#333333")
        c.text("NO SONG INFO", x0, 12, font = "7x10", color = "#8FD3FF")
        c.text("NOT AVAILABLE FOR THIS CHANNEL", x0, 25, font = "4x7", color = "#888888")
        return

    deeplink, tag = entry
    col = genre_color(tag)
    resp = fetch_now_playing(deeplink)
    data = resp["json"] if resp["status_code"] == 200 and resp["json"] != None else {}
    channel = data.get("channel", {})
    results = data.get("results", [])[back:]

    # A long gap since the last song means a talk or DJ segment; no cover
    # then, since the last song isn't what's on.
    age = age_minutes(results[0].get("timestamp"), ctx.now.unix) if results else None
    limit = JAM_TALK_AFTER if number in JAM_CHANNELS else TALK_AFTER
    # A whole concert airs as one entry titled with the show ("9.11.82 WEST
    # PALM BEACH, FL") and no songs are logged until it ends, so a long gap
    # after one is the show still playing, not a talk segment.
    if results and concert_date(clean(results[0].get("track", {}).get("title", ""))) != None:
        limit = FULL_SHOW_MAX
    talk = back == 0 and age != None and age >= limit

    art = None
    if results and not talk:
        sp = results[0].get("spotify") or {}
        # Shrinking the 300px cover and sharpening reads clearer at 32px
        # than starting from Spotify's 64px thumbnail.
        art = fetch_art(sp.get("albumImageMedium") or sp.get("albumImageSmall"))

    # Left edge: the cover with the channel number on a tag in its corner,
    # or the genre tile when the track has no cover (live recordings).
    right_edge = 191
    if art != None:
        draw_art(c, art, 0, 0)
        tw = c.text_width(number, "4x5") + 3
        c.rect(0, 25, tw, 31, fill = col)
        c.text(number, 2, 26, font = "4x5", color = "#000000" if brightness(col) > 140 else "#FFFFFF")
        x0 = ART + 3
    else:
        draw_tile(c, number, tag, index * 3)
        x0 = TILE_W + 3
    maxw = right_edge - x0

    if resp["status_code"] != 200:
        msg = "RATE LIMITED" if resp["status_code"] == 429 else "DATA UNAVAILABLE"
        c.text(msg, x0 + maxw // 2, 12, font = "5x7", color = "#FF4D4D", align = "center")
        return

    # Header: channel name in the genre color, time since the song started
    # at the right.
    name = clean(channel.get("name", deeplink))
    ago = ago_label(results[0].get("timestamp") if results else None, ctx.now.unix)
    if ago and back > 0:
        ago = "PLAYED " + ago
    agew = c.text_width(ago, "4x5") if ago else 0
    head_col = col if brightness(col) > 60 else mix(col, "#FFFFFF", 0.4)
    nfont, name = fit_name(c, name, maxw - agew - 4)
    c.text(name, x0, 1, font = nfont, color = head_col)
    if ago:
        c.text(ago, right_edge, 2, font = "4x5", color = "#777777", align = "right")
    c.line(x0, 9, right_edge, 9, mix(col, "#000000", 0.6))

    if len(results) == 0:
        c.text("NO EARLIER SONGS" if back > 0 else "NO SONG DATA YET", x0, 16, font = "5x7", color = "#888888")
        return

    track = results[0].get("track", {})
    title, year = split_year(clean(track.get("title", "?")))
    title = strip_versions(strip_feat(title))
    artist = clean(", ".join(track.get("artists", [])))
    show = concert_date(artist)
    if show != None:
        artist = show[0]
        if year == None:
            year = show[1]
    else:
        # A full concert airing is listed as the show itself ("9.11.82 WEST
        # PALM BEACH, FL") with a squashed band name, so the channel name
        # stands in for it.
        show = concert_date(title)
        if show != None:
            title = show[0]
            year = show[1]
            artist = "FULL SHOW - " + name

    if talk:
        c.text("SHOW IN PROGRESS", x0, 12, font = "7x10", color = "#8FD3FF")
        c.text(fit_text(c, "LAST SONG: " + title, "4x5", maxw), x0, 26, font = "4x5", color = "#888888")
        return

    # Title: one big line if it fits, stepping fonts down; a title that
    # still needs two lines gets the smaller artist line to make room.
    two_lines = False
    if big_ok(title) and c.text_width(title, "7x10") <= maxw:
        c.text(title, x0, 12, font = "7x10", color = "#FFC83D")
    elif c.text_width(title, "5x7") <= maxw:
        c.text(title, x0, 13, font = "5x7", color = "#FFC83D")
    elif c.text_width(title, "4x7") <= maxw:
        c.text(title, x0, 13, font = "4x7", color = "#FFC83D")
    else:
        two_lines = True
        lines = wrap2(c, title, "4x7", maxw)
        for i in range(len(lines)):
            c.text(lines[i], x0, 10 + i * 8, font = "4x7", color = "#FFC83D")

    # Artist along the bottom, with the year badge from decade channels
    # and live-archive shows.
    afont = "4x5" if two_lines else "5x7"
    if not two_lines and c.text_width(artist, "5x7") > maxw - (c.text_width(year, "4x5") + 7 if year else 3):
        afont = "4x7"
    ay = 26 if two_lines else 25
    yw = 0
    if year:
        yw = c.text_width(year, "4x5") + 4
        c.rect(right_edge - yw + 1, 25, right_edge, 31, fill = mix(col, "#000000", 0.35))
        c.text(year, right_edge - yw // 2 + 1, 26, font = "4x5", color = "#FFFFFF", align = "center")
    c.text(fit_text(c, artist, afont, maxw - yw - 3), x0, ay, font = afont, color = "#C8C8C8")

# ---------- intro ----------

def _rand(seed):
    return (seed * 1103515245 + 12345) % 2147483648

INTRO_STARS = []
def _make_stars():
    s = 7
    for i in range(46):
        s = _rand(s)
        x = s % 192
        s = _rand(s)
        y = s % 24
        s = _rand(s)
        b = 70 + s % 150
        INTRO_STARS.append((x, y, "#" + _hex2(b) + _hex2(b) + _hex2(min(255, b + 40))))
_make_stars()

def draw_sirius(c, cx, cy):
    # The Dog Star: a blue-white core with four diffraction spikes.
    for r, col in [(4, "#0C1B3A"), (3, "#1D3F7A"), (2, "#5A8CE0"), (1, "#CFE3FF")]:
        c.fill_circle(cx, cy, r, col)
    c.pixel(cx, cy, "#FFFFFF")
    for k in range(2, 9):
        t = float(k) / 9.0
        col = mix("#DDEBFF", "#0A0A28", t)
        c.pixel(cx + k, cy, col)
        c.pixel(cx - k, cy, col)
        if k < 7:
            c.pixel(cx, cy + k, col)
            c.pixel(cx, cy - k, col)
    for k in [2, 3]:
        col = mix("#9FC3FF", "#0A0A28", float(k) / 4.0)
        c.pixel(cx + k, cy + k, col)
        c.pixel(cx - k, cy - k, col)
        c.pixel(cx + k, cy - k, col)
        c.pixel(cx - k, cy + k, col)

SAT = [
    "BBBBBBBB.........BBBBBBBB",
    "BGBGBGBB....H....BBGBGBGB",
    "BBBBBBBBTTTFFFTTTBBBBBBBB",
    "BGBGBGBB...FFF...BBGBGBGB",
    "BBBBBBBB...FFF...BBBBBBBB",
    "............D............",
    "...........DDD...........",
]

def draw_satellite(c, x, y):
    c.sprite(SAT, x, y, legend = {"B": "#2F5FC4", "G": "#8DB8FF", "T": "#9A9A9A", "H": "#FFFFFF", "F": "#E0A92E", "D": "#D8D8D8"})

def draw_waves(c, cx, cy):
    # Broadcast arcs opening to the left of the dish, fading with distance.
    for i, r in enumerate([4, 7, 10, 13]):
        col = mix("#BFF0FF", "#1A0B3A", i * 0.15)
        for dx in range(-r - 1, 0):
            for dy in range(-r - 1, r + 2):
                d2 = dx * dx + dy * dy
                if d2 > r * r - r and d2 <= r * r + r and dy * dy * 3 <= dx * dx * 2:
                    c.pixel(cx + dx, cy + dy, col)

def draw_spectrum(c):
    # Rainbow analyzer along the floor: bars with a bright top, a dim body
    # and a floating peak dot.
    for i in range(48):
        h = 1 + (EQ_PATTERN[(i * 5) % len(EQ_PATTERN)] + (i * 7) % 3) * 5 // 9
        col = hue(float(i) / 48.0 * 0.83)
        x = i * 4
        top = 31 - h + 1
        c.gradient_rect(x, top, x + 2, 31, col, mix(col, "#000000", 0.7), horizontal = False)
        c.rect(x, top - 1, x + 2, top - 1, fill = mix(col, "#FFFFFF", 0.5))

def intro(c, ctx):
    c.fill("#000000")
    c.gradient_rect(0, 0, 191, 31, "#03020C", "#1C0C40", horizontal = False)
    for x, y, col in INTRO_STARS:
        c.pixel(x, y, col)
    draw_spectrum(c)
    draw_sirius(c, 13, 8)
    draw_satellite(c, 165, 1)
    draw_waves(c, 164, 11)

    # text_stroke has no centering, so the title is placed by its width.
    tx = 92 - c.text_width("SIRIUSXM", "10x16_bold") // 2
    c.text_stroke("SIRIUSXM", tx + 1, 1, font = "10x16_bold", color = "#5A2AA0", stroke = "#5A2AA0")
    c.text_stroke("SIRIUSXM", tx, 0, font = "10x16_bold", color = "#FFFFFF", stroke = "#120828")

    # Subtitle: what's being shown, then the channels as tags in
    # their genre colors.
    label = genre_label(ctx)
    lead = clean(label) if label != None else "NOW PLAYING"
    nums = slot_numbers(ctx)
    chips_w = 0
    for n in nums:
        chips_w += c.text_width(n, "4x5") + 4 + 2
    lw = c.text_width(lead, "5x7")
    if lw + 4 + chips_w > 186 and " & " in lead:
        # "DANCE & ELECTRONIC" and friends shorten to their first word.
        lead = lead.split(" & ")[0]
        lw = c.text_width(lead, "5x7")
    x = 92 - (lw + 4 + chips_w - 2) // 2
    c.text_stroke(lead, x, 18, font = "5x7", color = "#FFC83D", stroke = "#000000")
    x += lw + 4
    for n in nums:
        entry = CHANNELS.get(n)
        col = genre_color(entry[1]) if entry != None else "#444444"
        w = c.text_width(n, "4x5") + 4
        c.round_rect(x, 18, x + w - 1, 24, 1, fill = col)
        c.text(n, x + 2, 19, font = "4x5", color = "#000000" if brightness(col) > 140 else "#FFFFFF")
        x += w + 2

def channel_1(c, ctx):
    draw_channel(c, ctx, 0)

def channel_2(c, ctx):
    draw_channel(c, ctx, 1)

def channel_3(c, ctx):
    draw_channel(c, ctx, 2)

def channel_4(c, ctx):
    draw_channel(c, ctx, 3)
