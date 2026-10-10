# Events Near Me - what is on around a ZIP code, from Ticketmaster.
#
# DATA. Two requests per render. The ZIP code goes to zippopotam.us once a
# day for a latitude and longitude and a place name; that point, as a
# geohash, goes to Ticketmaster Discovery v2 /events.json with the radius.
# It needs the viewer's own free Discovery key. There is no shared demo
# key, so the no-key state here is a setup screen rather than a fault.
#
# Things the API does that would otherwise have shipped as bugs, all found
# by probing it rather than by reading the docs:
#
#   1. postalCode is an exact match on the venue's postcode, in any country,
#      and radius does nothing beside it. A Tampa 33602 search returned an
#      event in Bielefeld, Germany, whose postcode is also 33602; 90210 at
#      100 miles returned one event where a geoPoint search returns
#      thousands. So the ZIP is geocoded and the search is by geoPoint,
#      which the radius does bound. countryCode is still pinned.
#   2. An empty result carries no _embedded key at all, rather than an empty
#      list, so the events have to be reached defensively.
#   3. priceRanges and distance come back absent on ordinary listings, so
#      neither is shown. A price present on one event in ten would read as
#      though the other nine were free.
#
# CACHE. startDateTime is rounded down to midnight so the request URL, and
# with it the cache key, stays stable across renders within a day. Rounding
# that far down also lets through events that already started today, so
# those are dropped here instead, against the panel clock, which is exact.
#
# TEXT. No font in the set carries an apostrophe, and names arrive full of
# them, so clean() filters every name to the glyphs that exist and folds the
# common accented letters rather than dropping them: LOS TIGRES DEL NORTE
# should not come out as LOS TIGRES DEL NORTE with a hole in it.
#
# A cancelled show must never look like a normal one, so the status rides
# both pages: as a chip on the first and in place of the time on the list.

API = "https://app.ticketmaster.com/discovery/v2/events.json"
GEO = "https://api.zippopotam.us/us/"
UA = {"User-Agent": "glance-events-near-me (glance-led.dev)"}

INK = "#FFFFFF"
DIM = "#7C8BA1"
OK = "#3DDC5B"
WARN = "#FFC219"
BAD = "#FF3B21"
SLATE = "#8FA3BF"

# Segment colours. The rail, the chip and the date column on the list all
# wear the same one, so the colour means the same thing on both pages.
SEG = {
    "MUSIC": "#FF4FD8",
    "SPORTS": "#3DDC5B",
    "ARTS & THEATRE": "#FFC219",
    "FILM": "#00C2C7",
    "MISCELLANEOUS": "#8FA3BF",
}

# What the chip says. The API names are too wide for a 7 px chip.
SEG_LABEL = {
    "ARTS & THEATRE": "THEATRE",
    "MISCELLANEOUS": "OTHER",
    "UNDEFINED": "OTHER",
}

# The dropdown value the viewer picks, and what the API calls it.
CATS = {
    "ALL": "",
    "MUSIC": "Music",
    "SPORTS": "Sports",
    "ARTS AND THEATRE": "Arts & Theatre",
    "FILM": "Film",
    "OTHER": "Miscellaneous",
}

WINDOWS = {
    "NEXT 7 DAYS": 7,
    "NEXT 30 DAYS": 30,
    "NEXT 90 DAYS": 90,
    "ANYTIME": 0,
}

WIN_SHORT = {
    "NEXT 7 DAYS": "7 DAYS",
    "NEXT 30 DAYS": "30 DAYS",
    "NEXT 90 DAYS": "90 DAYS",
    "ANYTIME": "ANYTIME",
}

# The dropdown value, as the empty screen names it.
CAT_SHORT = {
    "ALL": "EVENTS",
    "MUSIC": "MUSIC",
    "SPORTS": "SPORTS",
    "ARTS AND THEATRE": "THEATRE",
    "FILM": "FILM",
    "OTHER": "OTHER EVENTS",
}

# Chip text and colour for the first page.
STATUS = {
    "onsale": ["", OK],
    "offsale": ["OFF SALE", SLATE],
    "cancelled": ["CANCELLED", BAD],
    "postponed": ["POSTPONED", WARN],
    "rescheduled": ["RESCHEDULED", WARN],
}

# The same thing shortened, for where the time would go on the list.
STATUS_SHORT = {
    "offsale": "OFF SALE",
    "cancelled": "CANCELLED",
    "postponed": "POSTPONED",
    "rescheduled": "RESCHED",
}

DOW = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# Every glyph the fonts actually carry. 7x12 is poorer than this and is not
# used for anything that can hold punctuation.
ALLOWED = " !#$%&()*+,-./0123456789:?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"

ACCENTS = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A",
    "Ã": "A", "Å": "A", "Æ": "AE",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O",
    "Õ": "O", "Ø": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
    "Ñ": "N", "Ç": "C", "Ý": "Y", "ß": "SS",
}

# Words a clipped title must not be left ending on. TAMPA BAY LIGHTNING VS
# reads as though the opponent were still coming.
TAIL = {
    "VS": True, "VS.": True, "V": True, "V.": True, "-": True, "&": True,
    "AND": True, "AT": True, "WITH": True, "THE": True, "A": True,
    "OF": True, "IN": True, "ON": True, "FOR": True, "TO": True, "FT": True,
    "FEAT": True, "FEAT.": True, "PRESENTS": True, "@": True, "+": True,
}

# ------------------------------------------------------------- the icons
# Bold two-colour silhouettes, 16 wide, drawn lit on the black stub: "#" is
# the segment colour, "o" is white. The 16-tall ones leave their last row
# blank so the month under them keeps its 1 px gap.
TICKET = """
.##############.
##########.oooo#
##########.oooo#
##########.oooo#
.#########.ooo#.
..########.oo#..
..########.oo#..
.#########.ooo#.
##########.oooo#
##########.oooo#
##########.oooo#
.##############.
"""

NOTE = """
................
......##########
......##########
......##########
......##......##
......##......##
......##......##
......##......##
......##......##
......##......##
....####....####
..######..######
.#######.#######
.#######.#######
..#####...#####.
................
"""

TROPHY = """
..############..
.#.##########.#.
#..##########..#
#..##########..#
#..##########..#
.#.##########.#.
..#.########.#..
....########....
.....######.....
......####......
.......##.......
.......##.......
......####......
....########....
...##########...
................
"""

MASKS = """
.#######........
#########.......
##.###.##.......
##.###.##.......
########ooooooo.
#.#####ooooooooo
##.....oo.ooo.oo
#######oo.ooo.oo
.######ooooooooo
..#####oo.....oo
...###.o.ooooo.o
.......ooooooooo
........ooooooo.
.........ooooo..
..........ooo...
................
"""

STRIP = """
################
#..##..##..##..#
#..##..##..##..#
################
##oooooooooooo##
##oooooooooooo##
##oooooooooooo##
##oooooooooooo##
##oooooooooooo##
##oooooooooooo##
##oooooooooooo##
################
#..##..##..##..#
#..##..##..##..#
################
................
"""

# [art, y on the first page]. The ticket is 12 tall, so it sits lower.
ICON = {
    "MUSIC": [NOTE, 0],
    "SPORTS": [TROPHY, 0],
    "ARTS & THEATRE": [MASKS, 0],
    "FILM": [STRIP, 0],
}

# ------------------------------------------------------------- text tools
def clean(s):
    """Uppercase, then keep only glyphs that exist, folding the accented
    letters rather than dropping them."""
    t = str(s).upper()
    out = ""
    for ch in t.elems():
        if ch in ALLOWED:
            out += ch
        elif ch in ACCENTS:
            out += ACCENTS[ch]
    for _ in range(4):
        out = out.replace("  ", " ")
    return out.strip()

def headline(s):
    """Ticketmaster writes ACT: TOUR NAME. The act is what a viewer scans
    for, so the tour subtitle goes when there is one worth losing."""
    n = clean(s)
    if ":" in n:
        head = n.split(":")[0].strip()
        if len(head) >= 4:
            return head
    return n

def trim_tail(s):
    """Drop a dangling connective left at the end of a clipped title."""
    parts = s.strip().split(" ")
    for _ in range(3):
        if len(parts) > 1 and parts[len(parts) - 1] in TAIL:
            parts = parts[:len(parts) - 1]
    return " ".join(parts).strip()

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for i in range(len(t), 0, -1):
        cut = t[:i]
        if c.text_width(cut, font) <= maxw:
            return cut
    return ""

def clip_words(c, text, font, maxw):
    """A title gives up whole words before it gives up letters."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    parts = t.split(" ")
    for n in range(len(parts) - 1, 0, -1):
        cut = " ".join(parts[:n])
        if c.text_width(cut, font) <= maxw:
            return cut
    return clip(c, t, font, maxw)

def fit_text(c, text, font, maxw):
    """Clip only if it has to, and never leave a dangling connective."""
    if c.text_width(text, font) <= maxw:
        return text
    return trim_tail(clip_words(c, text, font, maxw))

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    last = fonts[len(fonts) - 1]
    return [last, fit_text(c, text, last, maxw)]

def pick(c, options, font, maxw):
    """The first whole phrase that fits, so a heading never loses its last
    letters to a wider neighbour."""
    for t in options:
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def pad2(n):
    return ("0" + str(n)) if n < 10 else str(n)

def pad4(n):
    s = str(n)
    for _ in range(4 - len(s)):
        s = "0" + s
    return s

# ------------------------------------------------------------- the chrome
# The panel is a ticket. A black stub in the left of the safe zone (x
# 10..33) carries the picture, lit in the segment colour, and the date; a
# perforated tear line runs down x 36; the body, x 39..181, carries the
# words. Nothing is filled: on an LED panel a lit stroke on black reads
# across a room where a hole punched out of a bright block does not.
STUB_X = 10
STUB_W = 24
TEAR_X = 36
CX = 39
RX = 181
CW = RX - CX + 1
TEAR = "#3B4758"

def ink_on(col):
    """Black on a bright fill, white on a dark one."""
    h = col.lstrip("#")
    if len(h) != 6:
        return "black"
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return "black" if (r * 299 + g * 587 + b * 114) // 1000 > 130 else "white"

def frame(c):
    c.fill("black")
    for y in range(1, 31, 2):
        c.rect(TEAR_X, y, TEAR_X, y, fill = TEAR)

def centred(c, text, font, y, col):
    """Text centred across the stub."""
    x = STUB_X + (STUB_W - c.text_width(text, font)) // 2
    c.text(text, x, y, font = font, color = col)

def stub_art(c, art, col, y):
    c.sprite(art, STUB_X + (STUB_W - 16) // 2, y, legend = {"#": col, "o": INK})

def pill(c, text, col, x, y):
    w = c.text_width(text, "4x5") + 4
    c.rect(x, y, x + w - 1, y + 6, fill = col)
    c.text(text, x + 2, y + 1, font = "4x5", color = ink_on(col))
    return w

def notice(c, art, col, head, subs):
    """subs is longest first: the line steps down to a shorter whole phrase
    rather than being cut off in the middle of one."""
    frame(c)
    stub_art(c, art, col, 10)
    hf = fit(c, head, ["9x12", "8x10", "6x8", "5x7"], CW)
    c.text(hf[1], CX, 7, font = hf[0], color = col)
    for f in ["5x7", "4x5"]:
        s = pick(c, subs, f, CW)
        if s != "":
            c.text(s, CX, 23, font = f, color = DIM)
            return
    c.text(fit_text(c, subs[len(subs) - 1], "4x5", CW), CX, 23,
           font = "4x5", color = DIM)

# ---------------------------------------------------------------- dates
def days_from_civil(y, m, d):
    """Day number from 1970-01-01, in integers only."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
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
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]

def iso_midnight(y, m, d):
    """The % operator here carries no width or zero-pad flags, so %04d is
    not available and the padding is done by hand."""
    return pad4(y) + "-" + pad2(m) + "-" + pad2(d) + "T00:00:00Z"

def date_parts(s):
    """2026-09-18 into three integers, or None if it is not a date."""
    t = str(s)
    if len(t) < 10 or t[4] != "-" or t[7] != "-":
        return None
    p = t.split("-")
    if len(p) < 3:
        return None
    for x in [p[0], p[1], p[2][:2]]:
        if not x.isdigit():
            return None
    return [int(p[0]), int(p[1]), int(p[2][:2])]

def minutes_of(s):
    """19:00:00 into 1140, or -1 when there is no usable time."""
    t = str(s)
    if len(t) < 4 or ":" not in t:
        return -1
    p = t.split(":")
    if len(p) < 2 or not p[0].isdigit() or not p[1].isdigit():
        return -1
    h, mi = int(p[0]), int(p[1])
    if h < 0 or h > 23 or mi < 0 or mi > 59:
        return -1
    return h * 60 + mi

def fmt_time(mins):
    if mins < 0:
        return "TIME TBA"
    h, mi = mins // 60, mins % 60
    tag = "AM" if h < 12 else "PM"
    hh = h % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + pad2(mi) + " " + tag

def fmt_date(dnum, m, d):
    return DOW[(dnum + 4) % 7] + " " + MON[m - 1] + " " + str(d)

def relative(delta, mins, dnum):
    """How far off, the way a person says it. Inside the week the weekday
    is the useful word; the stub carries the date itself."""
    if delta <= 0:
        return "TONIGHT" if mins >= 1020 else "TODAY"
    if delta == 1:
        return "TOMORROW"
    if delta <= 6:
        return "THIS " + DOW[(dnum + 4) % 7]
    if delta <= 13:
        return "IN " + str(delta) + " DAYS"
    if delta <= 20:
        return "IN 2 WEEKS"
    if delta <= 27:
        return "IN 3 WEEKS"
    return "IN " + str(delta // 30) + " MONTHS" if delta >= 60 else "IN A MONTH"

# ------------------------------------------------------------------ feed
B32 = "0123456789bcdefghjkmnpqrstuvwxyz"

def geohash(lat, lon, n):
    """The point as an n-character geohash, which is what Ticketmaster's
    geoPoint filter takes. 7 characters is about 150 m, plenty for a ZIP."""
    lat0, lat1 = -90.0, 90.0
    lon0, lon1 = -180.0, 180.0
    out, ch, bits, even = "", 0, 0, True
    for _ in range(n * 5):
        if even:
            mid = (lon0 + lon1) / 2
            if lon >= mid:
                ch, lon0 = ch * 2 + 1, mid
            else:
                ch, lon1 = ch * 2, mid
        else:
            mid = (lat0 + lat1) / 2
            if lat >= mid:
                ch, lat0 = ch * 2 + 1, mid
            else:
                ch, lat1 = ch * 2, mid
        even = not even
        bits += 1
        if bits == 5:
            out += B32[ch]
            ch, bits = 0, 0
    return out

def geocode(zipc):
    """[lat, lon, PLACE ST] for a US ZIP, or the status code that stopped
    it. ZIPs do not move, so a day in cache is conservative."""
    g = http.get(GEO + zipc, ttl_seconds = 86400)
    st = g["status_code"]
    if st != 200:
        return [None, st]
    p = dig(g["json"], ["places", 0], {})
    lat, lon = dig(p, ["latitude"], ""), dig(p, ["longitude"], "")
    if type(p) != "dict" or lat == "" or lon == "":
        return [None, 404]
    place = clean(dig(p, ["place name"], ""))
    st2 = clean(dig(p, ["state abbreviation"], ""))
    if st2 != "":
        place = (place + " " + st2).strip()
    return [[float(lat), float(lon), place], 200]

def dig(o, path, dflt):
    cur = o
    for k in path:
        if type(cur) == "dict":
            if k not in cur:
                return dflt
            cur = cur[k]
        elif type(cur) == "list":
            if type(k) != "int" or k < 0 or k >= len(cur):
                return dflt
            cur = cur[k]
        else:
            return dflt
    return dflt if cur == None else cur

def fetch(ctx):
    key = str(ctx.inputs.get("apikey", "")).strip()
    zipc = clean(ctx.inputs.get("zip", "33602")).replace(" ", "")
    catin = str(ctx.inputs.get("category", "ALL")).strip().upper()
    if catin not in CATS:
        catin = "ALL"
    radin = str(ctx.inputs.get("radius", "25 MILES")).strip().upper()
    rad = radin.split(" ")[0]
    if not rad.isdigit():
        rad, radin = "25", "25 MILES"
    winin = str(ctx.inputs.get("window", "NEXT 30 DAYS")).strip().upper()
    if winin not in WINDOWS:
        winin = "NEXT 30 DAYS"
    days = WINDOWS[winin]

    today = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    now_min = ctx.now.hour * 60 + ctx.now.minute
    base = {"zip": zipc, "cat": catin, "rad": rad, "radlabel": radin,
            "win": winin, "today": today, "now_min": now_min}

    if key == "":
        return dict(base, ok = False, setup = True,
                    head = "ADD YOUR FREE KEY",
                    subs = ["DEVELOPER.TICKETMASTER.COM - FREE, ONE MINUTE",
                            "DEVELOPER.TICKETMASTER.COM - FREE",
                            "DEVELOPER.TICKETMASTER.COM"])
    if zipc == "":
        return dict(base, ok = False, setup = True, head = "SET A ZIP CODE",
                    subs = ["THE PANEL LOOKS FOR EVENTS AROUND IT",
                            "EVENTS ARE FOUND AROUND IT"])

    geo = geocode(zipc)
    if geo[0] == None:
        if geo[1] == 0:
            return dict(base, ok = False, offline = True,
                        head = "ZIP LOOKUP OFFLINE", subs = ["RETRY IN 30 MIN"])
        return dict(base, ok = False, setup = True, head = "ZIP NOT FOUND",
                    subs = [zipc + " IS NOT A US ZIP CODE - CHECK THE SETTING",
                            zipc + " IS NOT A US ZIP CODE",
                            "CHECK THE ZIP CODE"])
    base["place"] = geo[0][2]

    params = {"apikey": key, "geoPoint": geohash(geo[0][0], geo[0][1], 7),
              "radius": rad, "unit": "miles", "countryCode": "US", "size": "20",
              "sort": "date,asc",
              "startDateTime": iso_midnight(ctx.now.year, ctx.now.month, ctx.now.day)}
    if CATS[catin] != "":
        params["classificationName"] = CATS[catin]
    if days > 0:
        e = civil_from_days(today + days)
        params["endDateTime"] = iso_midnight(e[0], e[1], e[2])

    r = http.get(API, params = params, headers = UA, ttl_seconds = 1800)
    st = r["status_code"]
    if st == 0:
        return dict(base, ok = False, offline = True,
                    head = "TICKETMASTER OFFLINE", subs = ["RETRY IN 30 MIN"])
    if st == 401 or st == 403:
        return dict(base, ok = False, setup = True, head = "KEY REJECTED",
                    subs = ["TICKETMASTER DID NOT ACCEPT THAT API KEY",
                            "THAT API KEY WAS NOT ACCEPTED"])
    if st == 429:
        return dict(base, ok = False, head = "RATE LIMITED",
                    subs = ["TOO MANY REQUESTS - THIS CLEARS ITSELF",
                            "TOO MANY REQUESTS"])
    if st != 200:
        return dict(base, ok = False, head = "EVENTS FEED ERROR",
                    subs = ["HTTP " + str(st) + " - RETRY LATER"])

    js = r["json"]
    if type(js) != "dict":
        return dict(base, ok = False, head = "EVENTS FEED ERROR",
                    subs = ["UNEXPECTED ANSWER"])

    total = dig(js, ["page", "totalElements"], 0)
    if type(total) != "int":
        total = 0
    raw = dig(js, ["_embedded", "events"], [])
    if type(raw) != "list":
        raw = []

    evs = []
    seen = {}
    for row in raw:
        if type(row) != "dict":
            continue
        start = dig(row, ["dates", "start"], {})
        parts = date_parts(dig(start, ["localDate"], ""))
        if parts == None:
            continue
        dnum = days_from_civil(parts[0], parts[1], parts[2])
        mins = -1
        if not dig(start, ["timeTBA"], False) and not dig(start, ["noSpecificTime"], False):
            mins = minutes_of(dig(start, ["localTime"], ""))
        # already over today: the day-rounded query cannot exclude these
        if dnum < today:
            continue
        if dnum == today and mins >= 0 and mins < now_min:
            continue
        name = headline(dig(row, ["name"], ""))
        # The same show at three venues on one night is three rows of noise.
        tag = name + "|" + str(dnum)
        if tag in seen:
            continue
        seen[tag] = True
        seg = clean(dig(row, ["classifications", 0, "segment", "name"], ""))
        # College fixtures and the like arrive as segment UNDEFINED even
        # inside a Sports search. When the viewer chose the kind, that is
        # the kind it is.
        if seg not in SEG and CATS[catin] != "":
            seg = clean(CATS[catin])
        ven = dig(row, ["_embedded", "venues", 0], {})
        evs.append({
            "name": name,
            "seg": seg,
            "col": SEG.get(seg, SLATE),
            "status": str(dig(row, ["dates", "status", "code"], "")).lower(),
            "dnum": dnum,
            "mon": parts[1],
            "day": parts[2],
            "mins": mins,
            "venue": clean(dig(ven, ["name"], "")),
            "city": clean(dig(ven, ["city", "name"], "")),
            "state": clean(dig(ven, ["state", "stateCode"], "")),
        })

    if len(evs) == 0:
        near = base["place"] if base["place"] != "" else zipc
        what = "NO " + CAT_SHORT[catin] + " WITHIN " + radin + " OF " + near
        return dict(base, ok = False, empty = True, total = total,
                    head = "NOTHING LISTED",
                    subs = [what + " IN THE " + winin,
                            what + " IN " + WIN_SHORT[winin],
                            what,
                            "NO " + CAT_SHORT[catin] + " NEAR " + near,
                            "NOTHING NEAR " + zipc])
    return dict(base, ok = True, evs = evs, total = total)

def fail(c, d):
    if d.get("setup", False):
        notice(c, TICKET, WARN, d["head"], d["subs"])
    elif d.get("empty", False):
        notice(c, TICKET, SLATE, d["head"], d["subs"])
    elif d.get("offline", False):
        notice(c, TICKET, SLATE, d["head"], d["subs"])
    else:
        notice(c, TICKET, BAD, d["head"], d["subs"])

def split_two(c, name, font):
    """The most even two-line break where both halves fit, or -1."""
    parts = name.split(" ")
    best, score = -1, -999999
    for n in range(1, len(parts)):
        wa = c.text_width(" ".join(parts[:n]), font)
        wb = c.text_width(" ".join(parts[n:]), font)
        if wa <= CW and wb <= CW:
            s = -(wa - wb) if wa > wb else -(wb - wa)
            if s > score:
                best, score = n, s
    return best

def draw_name(c, name):
    """The hero. The name band is y8..22. A name that fits goes on one line
    in the biggest face that holds it; one that does not wraps to two rows
    rather than losing its second half, which is where the opponent in a
    fixture lives."""
    for opt in [["9x12", 9], ["8x10", 10], ["6x8", 11]]:
        if c.text_width(name, opt[0]) <= CW:
            c.text(name, CX, opt[1], font = opt[0], color = INK)
            return
    parts = name.split(" ")
    for opt in [["5x7", 8, 16], ["4x7", 8, 16], ["4x5", 9, 15]]:
        n = split_two(c, name, opt[0])
        if n > 0:
            c.text(" ".join(parts[:n]), CX, opt[1], font = opt[0], color = INK)
            c.text(" ".join(parts[n:]), CX, opt[2], font = opt[0], color = INK)
            return
    c.text(fit_text(c, name, "5x7", CW), CX, 12, font = "5x7", color = INK)

# ------------------------------------------------------------ page: next
def next(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail(c, d)
        return
    e = d["evs"][0]
    col = e["col"]
    frame(c)

    # The stub: the picture of what kind of thing it is, lit in its colour,
    # then the date as a calendar leaf: month small, day big and white.
    art = ICON.get(e["seg"], [TICKET, 2])
    stub_art(c, art[0], col, art[1])
    centred(c, MON[e["mon"] - 1], "4x5", 16, DIM)
    centred(c, str(e["day"]), "8x10", 22, INK)

    # Chip row y0..6: segment chip, a status chip only when the event is
    # not simply on sale, and the place right-aligned.
    x = CX
    x += pill(c, SEG_LABEL.get(e["seg"], e["seg"] if e["seg"] != "" else "EVENT"),
              col, x, 0) + 2
    stat = STATUS.get(e["status"], ["", OK])
    if stat[0] != "":
        x += pill(c, stat[0], stat[1], x, 0) + 2
    where = e["city"] + (" " + e["state"] if e["state"] != "" else "")
    if where == "":
        where = d.get("place", "") if d.get("place", "") != "" else d["zip"]
    where = fit_text(c, where, "4x5", RX - x - 2)
    if where != "":
        c.text(where, RX, 1, font = "4x5", color = INK, align = "right")

    draw_name(c, e["name"])

    # Bottom row y24..30: the time in the segment colour, how far off it is
    # on the right, and the venue in whatever room is left between them.
    when = fmt_time(e["mins"])
    c.text(when, CX, 24, font = "5x7", color = col)
    rel = relative(e["dnum"] - d["today"], e["mins"], e["dnum"])
    rw = c.text_width(rel, "4x5")
    c.text(rel, RX, 25, font = "4x5", color = DIM, align = "right")
    vx = CX + c.text_width(when, "5x7") + 4
    if e["venue"] != "":
        c.text(fit_text(c, e["venue"], "4x7", RX - rw - 4 - vx), vx, 24,
               font = "4x7", color = DIM)

# -------------------------------------------------------- page: upcoming
def upcoming(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        fail(c, d)
        return
    evs = d["evs"]
    col = evs[0]["col"]
    frame(c)

    # The stub: a ticket, how many are on, and the place they are near.
    stub_art(c, TICKET, col, 1)
    total = d["total"] if d["total"] > len(evs) else len(evs)
    n = str(total) if total < 10000 else "9999"
    for opt in [["8x10", 15], ["6x8", 16], ["5x7", 17], ["4x5", 18]]:
        if c.text_width(n, opt[0]) <= STUB_W:
            centred(c, n, opt[0], opt[1], INK)
            break
    centred(c, d["zip"], "4x5", 27, DIM)

    # Header y0..6: the page name, and the search on the right.
    c.text("UPCOMING", CX, 1, font = "4x5", color = INK)
    hx = CX + c.text_width("UPCOMING", "4x5") + 4
    c.text(pick(c, ["WITHIN " + d["radlabel"] + " - " + d["win"],
                    d["rad"] + " MI - " + d["win"],
                    d["rad"] + " MI - " + WIN_SHORT[d["win"]],
                    d["radlabel"], ""],
                "4x5", RX - hx + 1),
           RX, 1, font = "4x5", color = DIM, align = "right")

    # Three rows on an 8 px pitch, the ones after the event on the first
    # page. The date wears the segment colour, the same colour the chip on
    # the first page carries. Where the time would go, a troubled event says
    # so instead: cancelled must not look ordinary.
    shown = evs[1:4] if len(evs) > 1 else evs[:1]
    nx = CX + c.text_width("SEP 30", "4x5") + 3
    for i in range(len(shown)):
        e = shown[i]
        y = 8 + i * 8
        c.text(MON[e["mon"] - 1] + " " + str(e["day"]), CX, y + 1,
               font = "4x5", color = e["col"])
        note = STATUS_SHORT.get(e["status"], "")
        if note != "":
            tcol = STATUS.get(e["status"], ["", WARN])[1]
        else:
            note = fmt_time(e["mins"]) if e["mins"] >= 0 else "TBA"
            tcol = DIM
        tw = c.text_width(note, "4x5")
        c.text(note, RX, y + 1, font = "4x5", color = tcol, align = "right")
        c.text(fit_text(c, e["name"], "4x7", RX - tw - 3 - nx), nx, y,
               font = "4x7", color = INK)
