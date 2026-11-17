# DESIGN. A matchday strip for national-team football on a 192x32 SCROLL.
# Every page wears the same header so a viewer knows what they are looking at
# before they read a number: a pixel football, a state chip (LIVE in red, FT in
# white, NEXT in green, the group name in the competition's colour) and the
# competition name in that competition's own colour - sky blue for the Nations
# League, gold for the World Cup, blue for the Euros.
# Below the header the band splits in two. The left zone is the hero: the score
# in 10x16 between the two country codes, each underlined in its kit colour.
# The right zone carries the detail - goalscorers with minutes on the live and
# result pages, date and kickoff on the fixture page. The table page reflows
# the group into two columns. Black ground throughout, content held inside
# x 8-183 so neighbouring apps in the scroll never merge with it, and red kept
# for LIVE so it is the only thing on the panel that shouts.
#
# Data: ESPN's public soccer feeds (no key). A team is followed through its
# all-competition schedule (two calls), a group through the competition's
# standings plus month-by-month scoreboards. Goalscorers only appear on
# scoreboards, so the one match being shown is looked up there by its US
# Eastern date - that is the day ESPN files a match under (a 01:00Z World Cup
# kickoff is listed on the previous day).

SITE = "https://site.api.espn.com/apis/site/v2/sports/soccer/"
WEB = "https://site.web.api.espn.com/apis/site/v2/sports/soccer/all/teams/"
STANDINGS = "https://site.api.espn.com/apis/v2/sports/soccer/"

X0 = 8       # safe zone, left edge (inclusive)
X1 = 183     # safe zone, right edge (inclusive)
SPLIT = 104  # divider between the hero zone and the detail zone
RZ = 108     # detail zone left edge

INK = "#F4F7FF"
SOFT = "#A9B1C4"
DIM = "#6E7A94"
STRUCT = "#2A3040"
LIVE = "#FF3B30"
NEXT = "#00DC46"
FT = "#D8DEE9"
WARN = "#E8B04A"

# slug -> [panel name, accent, short name for when the round will not fit]
COMPS = {
    "uefa.nations": ["NATIONS LEAGUE", "#78DCFF", "NATIONS LG"],
    "fifa.world": ["WORLD CUP", "#FFC83C", "WORLD CUP"],
    "fifa.worldq": ["WC QUALIFIER", "#FFC83C", "WC QUAL"],
    "uefa.euro": ["EURO", "#5A8CFF", "EURO"],
    "uefa.euroq": ["EURO QUALIFIER", "#5A8CFF", "EURO QUAL"],
    "fifa.friendly": ["FRIENDLY", "#A0A8B8", "FRIENDLY"],
}

# Group dropdown label prefix -> ESPN competition slug.
GROUP_PREFIX = [
    ["World Cup Qualifying (Europe) - ", "fifa.worldq.uefa"],
    ["Nations League - ", "uefa.nations"],
    ["Euro Qualifying - ", "uefa.euroq"],
    ["World Cup - ", "fifa.world"],
    ["Euro - ", "uefa.euro"],
]

# Dropdown name -> [ESPN team id, code, primary colour, alternate colour].
TEAMS = {
    "Albania": ["585", "ALB", "E70000", "FFFFFF"],
    "Algeria": ["624", "ALG", "4F9A44", "FFFFFF"],
    "Andorra": ["587", "AND", "E70000", "0000CD"],
    "Argentina": ["202", "ARG", "74ACDF", "173E69"],
    "Armenia": ["579", "ARM", "DE2400", "FFFFFF"],
    "Australia": ["628", "AUS", "FFCD00", "FFCD00"],
    "Austria": ["474", "AUT", "D72B2C", "000000"],
    "Azerbaijan": ["581", "AZE", "2D4AB0", "FFFFFF"],
    "Belarus": ["583", "BLR", "FFFFFF", "E70000"],
    "Belgium": ["459", "BEL", "E30613", "6ECFF6"],
    "Bosnia and Herzegovina": ["452", "BIH", "112855", "FFFFFF"],
    "Brazil": ["205", "BRA", "FEE000", "193375"],
    "Bulgaria": ["462", "BUL", "D62612", "FFFFFF"],
    "Canada": ["206", "CAN", "000000", "ED2224"],
    "Cape Verde": ["2597", "CPV", "000080", "EF3340"],
    "Colombia": ["208", "COL", "FBD632", "21418C"],
    "Croatia": ["477", "CRO", "FF0000", "0C2FFF"],
    "Curacao": ["11678", "CUW", "0537E4", "0537E4"],
    "Cyprus": ["445", "CYP", "195CCD", "FFFFFF"],
    "Czechia": ["450", "CZE", "D7141A", "FFFFFF"],
    "DR Congo": ["2850", "COD", "418FDE", "C60000"],
    "Denmark": ["479", "DEN", "D02A3E", "FFFFFF"],
    "Ecuador": ["209", "ECU", "FFDD00", "034EA2"],
    "Egypt": ["2620", "EGY", "D20300", "FFFFFF"],
    "England": ["448", "ENG", "FFFFFF", "EA1F29"],
    "Estonia": ["444", "EST", "195CCD", "FFFFFF"],
    "Faroe Islands": ["447", "FRO", "FFFFFF", "195CCD"],
    "Finland": ["458", "FIN", "003580", "FFFFFF"],
    "France": ["478", "FRA", "000080", "C8E6D8"],
    "Georgia": ["584", "GEO", "FFFFFF", "4A2942"],
    "Germany": ["481", "GER", "FFFFFF", "00CED1"],
    "Ghana": ["4469", "GHA", "FBD632", "000000"],
    "Gibraltar": ["16721", "GIB", "DE2918", "FFFFFF"],
    "Greece": ["455", "GRE", "295DA8", "FFFFFF"],
    "Haiti": ["2654", "HAI", "0033A0", "FFFFFF"],
    "Hungary": ["480", "HUN", "CE2029", "FFFFFF"],
    "Iceland": ["470", "ISL", "0C2FFF", "FFFFFF"],
    "Iran": ["469", "IRN", "FFFFFF", "DA0000"],
    "Iraq": ["4375", "IRQ", "FFFFFF", "0A4D2E"],
    "Israel": ["461", "ISR", "2F4FA2", "FFFFFF"],
    "Italy": ["162", "ITA", "103CD6", "FFFFFF"],
    "Ivory Coast": ["4789", "CIV", "FF8200", "FF8200"],
    "Japan": ["627", "JPN", "000555", "000555"],
    "Jordan": ["2917", "JOR", "E70000", "FFFFFF"],
    "Kazakhstan": ["2619", "KAZ", "00ABC2", "FFEC2D"],
    "Kosovo": ["18272", "KOS", "0000CD", "FFEC00"],
    "Latvia": ["456", "LVA", "992242", "FFFFFF"],
    "Liechtenstein": ["589", "LIE", "0000CD", "E70000"],
    "Lithuania": ["460", "LTU", "FFE400", "DE2918"],
    "Luxembourg": ["582", "LUX", "E70000", "FFFFFF"],
    "Malta": ["453", "MLT", "DE2400", "FFFFFF"],
    "Mexico": ["203", "MEX", "006847", "000000"],
    "Moldova": ["483", "MDA", "0046AE", "FFD200"],
    "Montenegro": ["6775", "MNE", "E70000", "FFFFFF"],
    "Morocco": ["2869", "MAR", "DF2027", "FFFFFF"],
    "Netherlands": ["449", "NED", "FB5D00", "FB5D00"],
    "New Zealand": ["2666", "NZL", "000000", "FFFFFF"],
    "North Macedonia": ["463", "MKD", "E70000", "DDDDEA"],
    "Northern Ireland": ["586", "NIR", "CC0000", "FFFFFF"],
    "Norway": ["464", "NOR", "C8102E", "C8102E"],
    "Panama": ["2659", "PAN", "D21034", "005293"],
    "Paraguay": ["210", "PAR", "EA2300", "21418C"],
    "Poland": ["471", "POL", "FFFFFF", "DC143C"],
    "Portugal": ["482", "POR", "DA291C", "0D6938"],
    "Qatar": ["4398", "QAT", "691A40", "FFFFFF"],
    "Republic of Ireland": ["476", "IRL", "049A64", "F58241"],
    "Romania": ["473", "ROU", "FCD116", "CE1126"],
    "San Marino": ["588", "SMR", "00BFFF", "FFFFFF"],
    "Saudi Arabia": ["655", "KSA", "FFFFFF", "125B34"],
    "Scotland": ["580", "SCO", "1A2D69", "DE4E44"],
    "Senegal": ["654", "SEN", "FFFFFF", "006436"],
    "Serbia": ["6757", "SRB", "E70000", "FFFFFF"],
    "Slovakia": ["468", "SVK", "0C2FFF", "FFFFFF"],
    "Slovenia": ["472", "SVN", "FFFFFF", "0C2FFF"],
    "South Africa": ["467", "RSA", "FFB81C", "0C562E"],
    "South Korea": ["451", "KOR", "CE2028", "9E82C8"],
    "Spain": ["164", "ESP", "C60B1E", "FFFFFF"],
    "Sweden": ["466", "SWE", "FECB00", "006AA7"],
    "Switzerland": ["475", "SUI", "FF0000", "BCECAC"],
    "Tunisia": ["659", "TUN", "D20300", "FFFFFF"],
    "Turkiye": ["465", "TUR", "FFFFFF", "EF3340"],
    "Ukraine": ["457", "UKR", "FEDE00", "0C2FFF"],
    "United States": ["660", "USA", "213065", "D42339"],
    "Uruguay": ["212", "URU", "55B5E5", "000080"],
    "Uzbekistan": ["2570", "UZB", "FFFFFF", "0072CE"],
    "Wales": ["578", "WAL", "E70000", "174A3F"],
}

TEAM_BY_ID = {v[0]: v for v in TEAMS.values()}

DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# 7x7 football: the app's identity mark, top-left on every page.
BALL = """
..www..
.wwkww.
wwkkkww
wwwkwww
wkwwwkw
.kwwwk.
..www..
"""
BALL_LEGEND = {"w": INK, "k": "#3A4256"}

ACCENTS = {
    "á": "a", "à": "a", "â": "a", "ä": "a", "ã": "a", "å": "a", "ă": "a", "ą": "a",
    "æ": "ae", "ç": "c", "ć": "c", "č": "c", "ď": "d", "đ": "d",
    "é": "e", "è": "e", "ê": "e", "ë": "e", "ě": "e", "ę": "e", "ė": "e",
    "ğ": "g", "í": "i", "ì": "i", "î": "i", "ï": "i", "ı": "i",
    "ł": "l", "ñ": "n", "ń": "n", "ň": "n",
    "ó": "o", "ò": "o", "ô": "o", "ö": "o", "õ": "o", "ø": "o", "ő": "o",
    "ř": "r", "ş": "s", "ș": "s", "ś": "s", "š": "s", "ß": "ss",
    "ţ": "t", "ț": "t", "ť": "t",
    "ú": "u", "ù": "u", "û": "u", "ü": "u", "ű": "u", "ů": "u",
    "ý": "y", "ź": "z", "ż": "z", "ž": "z",
    "Á": "A", "Å": "A", "Ä": "A", "Æ": "AE", "Ç": "C", "Č": "C", "É": "E",
    "Í": "I", "İ": "I", "Ł": "L", "Ñ": "N", "Ó": "O", "Ö": "O", "Ø": "O",
    "Ş": "S", "Š": "S", "Ú": "U", "Ü": "U", "Ž": "Z",
}

# ------------------------------------------------------------ small helpers

def get(obj, key, fallback = None):
    """dict.get that survives a null parent, which JSON feeds hand back often."""
    if type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    cur = obj
    for k in path:
        cur = get(cur, k, None)
        if cur == None:
            return fallback
    return cur

def first(v):
    return v[0] if type(v) == "list" and len(v) > 0 else {}

def as_int(v, fallback = -1):
    """Scores arrive as "2", 2.0, or {"displayValue": "2"}; anything else -> fallback.
    int() raises on junk and a raised error kills the whole render."""
    if type(v) == "dict":
        v = get(v, "displayValue", get(v, "value", None))
    if type(v) == "int":
        return v
    if type(v) == "float":
        return int(v)
    t = str(v).strip() if v != None else ""
    return int(t) if t != "" and t.isdigit() else fallback

def display(text):
    """Panel fonts are ASCII uppercase: fold accents ("Højlund" -> "HOJLUND")
    and drop anything else outside ASCII rather than draw nothing."""
    out = ""
    for ch in str(text).elems():
        if ch in ACCENTS:
            out += ACCENTS[ch]
        elif ord(ch) < 128:
            out += ch
    return out.upper().strip()

def pad2(n):
    return ("0" if n < 10 else "") + str(n)

def truthy(v):
    return v == True or str(v).lower() in ["true", "1", "yes", "on"]

def clip_words(c, text, font, maxw):
    """clip(), backed up to the last whole word unless that costs > 30%."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        t = t[:sp]
    return t.rstrip(" -")

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw` - nothing in the API clips."""
    t = str(text)
    if maxw <= 0:
        return ""
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k].rstrip()
    return ""

def hex_brightness(h):
    h = str(h).lstrip("#").lower()
    if len(h) != 6:
        return -1
    digits = "0123456789abcdef"
    vals = []
    for i in [0, 2, 4]:
        hi = digits.find(h[i])
        lo = digits.find(h[i + 1])
        if hi < 0 or lo < 0:
            return -1
        vals.append(hi * 16 + lo)
    return (vals[0] * 299 + vals[1] * 587 + vals[2] * 114) // 1000

def on_color(bg):
    """Chip text: black once the fill is bright enough, white below that."""
    return "black" if hex_brightness(bg) >= 150 else "white"

def kit(primary, alternate):
    """The team's colour, unless it is too dark to see on black LEDs
    (Scotland's navy #1A2D69 vanishes), then its alternate, then grey."""
    for v in [primary, alternate]:
        if hex_brightness(v) >= 60:
            return "#" + str(v).lstrip("#")
    return SOFT

# --------------------------------------------------------------------- time
# Shared 52-zone table (same as trash-day): zone -> [std offset minutes, rule]
#   0 none  1 United States  2 Europe  3 Australia  4 New Zealand  5 Egypt  6 Israel
TZ = {
    "Pacific/Honolulu": [-600, 0],
    "America/Anchorage": [-540, 1],
    "America/Los_Angeles": [-480, 1],
    "America/Phoenix": [-420, 0],
    "America/Denver": [-420, 1],
    "America/Chicago": [-360, 1],
    "America/Mexico_City": [-360, 0],
    "America/New_York": [-300, 1],
    "America/Bogota": [-300, 0],
    "America/Halifax": [-240, 1],
    "America/Sao_Paulo": [-180, 0],
    "America/Argentina/Buenos_Aires": [-180, 0],
    "UTC": [0, 0],
    "Europe/Lisbon": [0, 2],
    "Europe/Dublin": [0, 2],
    "Europe/London": [0, 2],
    "Europe/Madrid": [60, 2],
    "Europe/Paris": [60, 2],
    "Europe/Amsterdam": [60, 2],
    "Europe/Berlin": [60, 2],
    "Europe/Rome": [60, 2],
    "Europe/Stockholm": [60, 2],
    "Europe/Warsaw": [60, 2],
    "Africa/Lagos": [60, 0],
    "Europe/Athens": [120, 2],
    "Europe/Helsinki": [120, 2],
    "Africa/Johannesburg": [120, 0],
    "Europe/Moscow": [180, 0],
    "Africa/Nairobi": [180, 0],
    "Asia/Dubai": [240, 0],
    "Asia/Karachi": [300, 0],
    "Asia/Kolkata": [330, 0],
    "Asia/Dhaka": [360, 0],
    "Asia/Bangkok": [420, 0],
    "Asia/Jakarta": [420, 0],
    "Asia/Shanghai": [480, 0],
    "Asia/Singapore": [480, 0],
    "Asia/Hong_Kong": [480, 0],
    "Australia/Perth": [480, 0],
    "Asia/Tokyo": [540, 0],
    "Asia/Seoul": [540, 0],
    "Australia/Adelaide": [570, 3],
    "Australia/Brisbane": [600, 0],
    "Australia/Sydney": [600, 3],
    "Australia/Melbourne": [600, 3],
    "Pacific/Auckland": [720, 4],
    "Atlantic/Reykjavik": [0, 0],
    "Europe/Kyiv": [120, 2],
    "Europe/Istanbul": [180, 0],
    "Africa/Cairo": [120, 5],
    "Asia/Jerusalem": [120, 6],
    "Asia/Manila": [480, 0],
}

def days_from_civil(y, m, d):
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
    m = mp + (3 if mp < 10 else -9)
    return [y + (1 if m <= 2 else 0), m, d]

def weekday(z):
    """0 = Monday .. 6 = Sunday. Day 0 (1970-01-01) was a Thursday."""
    return (z + 3) % 7

def nth_sunday(y, m, n):
    if n == -1:
        last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
        if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
            last = 29
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    f = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return f + 7 * (n - 1)

def last_dow(y, m, dow):
    last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
    if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
        last = 29
    return last - ((weekday(days_from_civil(y, m, last)) - dow) % 7)

def _utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(zone, t):
    """Minutes east of UTC for `zone` at UTC instant `t` (minutes since epoch)."""
    z = TZ[zone] if zone in TZ else TZ["UTC"]
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    if rule == 1:
        start = _utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
        end = _utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 2:
        start = _utcmin(y, 3, nth_sunday(y, 3, -1), 1)
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 1)
        return std + 60 if t >= start and t < end else std
    if rule == 5:
        start = _utcmin(y, 4, last_dow(y, 4, 4), 0) - std
        end = _utcmin(y, 10, last_dow(y, 10, 4), 0) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 6:
        start = _utcmin(y, 3, nth_sunday(y, 3, -1) - 2, 2) - std
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    m0 = 10 if rule == 3 else 9
    n0 = 1 if rule == 3 else -1
    start = _utcmin(y, m0, nth_sunday(y, m0, n0), 2) - std
    end = _utcmin(y, 4, nth_sunday(y, 4, 1), 3) - std - 60
    return std if t >= end and t < start else std + 60

def utc_minutes(iso):
    """ESPN dates look like 2026-11-17T19:45Z -> minutes since the epoch."""
    s = str(iso)
    if len(s) < 16:
        return None
    digits = s[0:4] + s[5:7] + s[8:10] + s[11:13] + s[14:16]
    if not digits.isdigit():
        return None
    return days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10])) * 1440 + int(s[11:13]) * 60 + int(s[14:16])

def local(utc, zone):
    t = utc + zone_offset_at(zone, utc)
    days = t // 1440
    ymd = civil_from_days(days)
    mins = t % 1440
    return {"days": days, "y": ymd[0], "m": ymd[1], "d": ymd[2], "wd": weekday(days),
            "hh": mins // 60, "mm": mins % 60}

def ymd_et(utc):
    """The day ESPN files a match under (US Eastern), as YYYYMMDD."""
    p = local(utc, "America/New_York")
    return str(p["y"]) + pad2(p["m"]) + pad2(p["d"])

def clock(p, twelve):
    if not twelve:
        return pad2(p["hh"]) + ":" + pad2(p["mm"])
    h = p["hh"] % 12
    return str(12 if h == 0 else h) + ":" + pad2(p["mm"]) + ("PM" if p["hh"] >= 12 else "AM")

def day_text(p):
    return DAYS[p["wd"]] + " " + str(p["d"]) + " " + MONTHS[p["m"] - 1]

def settings(ctx):
    zone = str(ctx.inputs.get("timezone", "Europe/London")).strip()
    return {
        "zone": zone if zone in TZ else "UTC",
        "twelve": str(ctx.inputs.get("clock", "24-hour")).startswith("12"),
        "friendlies": truthy(ctx.inputs.get("friendlies", False)),
        "now": ctx.now.unix // 60,
    }

# ---------------------------------------------------------- competitions

def comp_key(slug):
    s = str(slug)
    if s.startswith("fifa.worldq"):
        return "fifa.worldq"
    return s if s in COMPS else None

def tracked(slug, friendlies):
    k = comp_key(slug)
    return k != None and (k != "fifa.friendly" or friendlies)

def comp_name(slug):
    k = comp_key(slug)
    return COMPS[k][0] if k != None else "INTERNATIONAL"

def comp_short(slug):
    k = comp_key(slug)
    return COMPS[k][2] if k != None else "INTL"

def comp_color(slug):
    k = comp_key(slug)
    return COMPS[k][1] if k != None else SOFT

# ------------------------------------------------------------------ fetching

def fetch(url, ttl, params = {}):
    r = http.get(url, params = params, ttl_seconds = ttl)
    if get(r, "status_code", 0) != 200:
        return None
    j = get(r, "json", None)
    return j if type(j) == "dict" else None

def team_side(t):
    tm = get(t, "team", {})
    tid = str(get(tm, "id", ""))
    known = TEAM_BY_ID.get(tid)
    abbr = display(get(tm, "abbreviation", ""))
    if known != None:
        abbr = known[1]
        color = kit(known[2], known[3])
    else:
        color = kit(get(tm, "color", ""), get(tm, "alternateColor", ""))
    name = display(get(tm, "shortDisplayName", get(tm, "displayName", abbr)))
    return {
        "id": tid,
        "abbr": abbr if abbr != "" else "TBD",
        "name": name,
        "score": as_int(get(t, "score", None)),
        "so": as_int(get(t, "shootoutScore", None)),
        "color": color,
    }

def normalize(e, slug):
    c = first(get(e, "competitions", []))
    home = {}
    away = {}
    for t in get(c, "competitors", []):
        if get(t, "homeAway", "") == "home":
            home = t
        else:
            away = t
    st = dig(c, ["status", "type"], {})
    alt = str(get(c, "altGameNote", ""))
    rnd = alt[alt.rfind(", ") + 2:] if alt.find(", ") >= 0 else str(dig(e, ["seasonType", "name"], ""))
    if comp_key(slug) == "fifa.friendly":
        rnd = ""
    details = get(c, "details", None)
    return {
        "id": str(get(e, "id", "")),
        "slug": slug,
        "utc": utc_minutes(get(e, "date", "")),
        "time_ok": get(e, "timeValid", True) != False and get(c, "timeValid", True) != False,
        "state": str(get(st, "state", "")),
        "status": str(get(st, "name", "")),
        "completed": get(st, "completed", False) == True,
        "detail": display(get(st, "shortDetail", "")),
        "round": display(rnd),
        "home": team_side(home),
        "away": team_side(away),
        "details": details if type(details) == "list" else None,
    }

def with_details(m):
    """Swap in the scoreboard copy of a match, which is the only one that
    lists goalscorers. Failure costs the scorers, not the panel."""
    if m["details"] != None or m["utc"] == None:
        return m
    live = m["state"] == "in"
    sb = fetch(SITE + m["slug"] + "/scoreboard", 60 if live else 3600, {"dates": ymd_et(m["utc"])})
    for e in get(sb, "events", []):
        if str(get(e, "id", "")) == m["id"]:
            n = normalize(e, m["slug"])
            if n["round"] == "":
                n["round"] = m["round"]
            return n
    return m

def by_time(ms):
    return sorted([m for m in ms if m["utc"] != None], key = lambda m: m["utc"])

def latest_round(results):
    """Every result within two days of the most recent one: one matchday."""
    if len(results) == 0:
        return []
    top = results[0]["utc"]
    return [m for m in results if top - m["utc"] <= 2 * 1440]

# Team mode: the all-competition schedule, in two calls (played / to come).
def team_data(ctx, s):
    name = str(ctx.inputs.get("team", "England"))
    t = TEAMS.get(name)
    if t == None:
        return {"error": "noteam"}
    up = fetch(WEB + t[0] + "/schedule", 120, {"fixture": "true"})  # ttl matches refresh
    past = fetch(WEB + t[0] + "/schedule", 600)
    if up == None and past == None:
        return {"error": "offline"}
    live = []
    upcoming = []
    results = []
    seen = {}
    for src in [up, past]:
        for e in get(src, "events", []):
            slug = str(dig(e, ["league", "slug"], ""))
            if not tracked(slug, s["friendlies"]):
                continue
            m = normalize(e, slug)
            if m["id"] in seen or m["utc"] == None:
                continue
            seen[m["id"]] = True
            if m["state"] == "in":
                live.append(m)
            elif m["state"] == "pre":
                upcoming.append(m)
            elif m["completed"]:
                results.append(m)
    results = sorted(results, key = lambda m: -m["utc"])
    return {"error": "", "mode": "team", "name": name, "id": t[0], "code": t[1],
            "live": by_time(live), "upcoming": by_time(upcoming), "results": results}

def group_target(ctx):
    label = str(ctx.inputs.get("group", "Nations League - Group A3"))
    for p in GROUP_PREFIX:
        if label.startswith(p[0]):
            return [p[1], label[len(p[0]):].strip()]
    return None

def standings_rows(block):
    rows = []
    for en in dig(block, ["standings", "entries"], []):
        stats = {}
        for x in get(en, "stats", []):
            stats[str(get(x, "name", ""))] = x
        tm = get(en, "team", {})
        tid = str(get(tm, "id", ""))
        known = TEAM_BY_ID.get(tid)
        note = str(dig(en, ["note", "color"], ""))
        rows.append({
            "id": tid,
            "abbr": known[1] if known != None else display(get(tm, "abbreviation", "???")),
            "rank": as_int(get(get(stats, "rank", {}), "value", None), 99),
            "pts": as_int(get(get(stats, "points", {}), "value", None), 0),
            "gd": as_int(str(get(get(stats, "pointDifferential", {}), "displayValue", "0")).replace("+", "").replace("-", ""), 0),
            "gdneg": str(get(get(stats, "pointDifferential", {}), "displayValue", "")).startswith("-"),
            "note": "#" + note.lstrip("#") if hex_brightness(note) >= 60 else STRUCT,
        })
    return sorted(rows, key = lambda r: r["rank"])

def find_group(slug, match_fn, year):
    """[label, rows] for the first group in `slug` that match_fn accepts,
    [None, None] if none does, or None when the feed is unreachable.

    Between editions ESPN keeps serving the last one: in November 2026 Euro
    qualifying still returns the 2023 groups. A table more than a year old
    is treated as "not drawn yet" rather than shown as if it were current."""
    st = fetch(STANDINGS + slug + "/standings", 900)
    if st == None:
        return None
    season = as_int(get(first(get(st, "seasons", [])), "year", None), year)
    if season < year - 1:
        return [None, None]
    blocks = get(st, "children", [])
    if len(blocks) == 0 and get(st, "standings", None) != None:
        blocks = [st]
    for b in blocks:
        if match_fn(b):
            label = display(get(b, "abbreviation", get(b, "name", "")))
            return [label, standings_rows(b)]
    return [None, None]

def group_data(ctx, s, need_results):
    tgt = group_target(ctx)
    if tgt == None:
        return {"error": "nogroup"}
    slug, gname = tgt[0], tgt[1]
    want = display(gname)
    g = find_group(slug, lambda b: display(get(b, "name", "")) == want or display(get(b, "abbreviation", "")) == want, ctx.now.year)
    if g == None:
        return {"error": "offline"}
    if g[0] == None:
        return {"error": "notdrawn", "slug": slug, "label": want}
    ids = {r["id"]: True for r in g[1]}
    p = local(s["now"], "America/New_York")
    y, mo = p["y"], p["m"]
    months = [[y, mo, 120]]  # current month carries live games; ttl matches refresh
    months.append([y + (1 if mo == 12 else 0), 1 if mo == 12 else mo + 1, 1800])
    if need_results:
        months.append([y - (1 if mo == 1 else 0), 12 if mo == 1 else mo - 1, 3600])
    live = []
    upcoming = []
    results = []
    seen = {}
    for spec in months:
        sb = fetch(SITE + slug + "/scoreboard", spec[2], {"dates": str(spec[0]) + pad2(spec[1]), "limit": "200"})
        for e in get(sb, "events", []):
            m = normalize(e, slug)
            if m["id"] in seen or m["utc"] == None:
                continue
            if not (m["home"]["id"] in ids and m["away"]["id"] in ids):
                continue
            seen[m["id"]] = True
            if m["state"] == "in":
                live.append(m)
            elif m["state"] == "pre":
                upcoming.append(m)
            elif m["completed"]:
                results.append(m)
    if need_results and len(results) == 0 and len(g[1]) > 0:
        # Nothing in the last two months (a finished World Cup group, say):
        # the group leader's own schedule still holds its latest group game.
        sch = fetch(WEB + g[1][0]["id"] + "/schedule", 3600)
        for e in get(sch, "events", []):
            if str(dig(e, ["league", "slug"], "")) != slug:
                continue
            m = normalize(e, slug)
            if m["completed"] and m["utc"] != None and m["home"]["id"] in ids and m["away"]["id"] in ids:
                results.append(m)
    results = sorted(results, key = lambda m: -m["utc"])
    return {"error": "", "mode": "group", "slug": slug, "label": g[0], "rows": g[1],
            "live": by_time(live), "upcoming": by_time(upcoming), "results": results}

def load_data(ctx, s, need_results = False):
    if str(ctx.inputs.get("follow", "A team")).endswith("group"):
        return group_data(ctx, s, need_results)
    return team_data(ctx, s)

# ------------------------------------------------------------------- drawing

def header(c, chip, chip_bg, slug, rnd, meta = ""):
    """Ball, state chip, competition (in its colour), round, right-hand meta.
    The meta is drawn first so the competition text is clipped to what is
    left - "EURO QUALIFIER GROUP L" plus a date would otherwise collide."""
    c.sprite(BALL, X0, 0, legend = BALL_LEGEND)
    x = X0 + 10
    x = x + c.badge(chip, x, 0, color = on_color(chip_bg), bg = chip_bg, font = "4x5") + 4
    limit = X1
    if meta != "":
        mw = c.text_width(meta, "4x5")
        c.text(meta, X1 - mw + 1, 1, font = "4x5", color = SOFT)
        limit = X1 - mw - 4
    if slug != "":
        nm = comp_name(slug)
        # "NATIONS LEAGUE GROUP B4" next to a "1/2" counter is 1 px too wide;
        # the short name keeps the group, which is the part that matters.
        if rnd != "" and c.text_width(nm + " " + rnd, "4x5") + 2 > limit - x:
            nm = comp_short(slug)
        nm = clip(c, nm, "4x5", limit - x)
        if nm != "":
            c.text(nm, x, 1, font = "4x5", color = comp_color(slug))
            x = x + c.text_width(nm, "4x5") + 4
    if rnd != "" and x < limit:
        r = clip(c, rnd, "4x5", limit - x)
        if r != "":
            c.text(r, x, 1, font = "4x5", color = DIM)

def message(c, head, sub, color = WARN):
    """The one screen every failure and empty state shares: the ball as the
    app's identity, a what, and a what-to-do."""
    c.sprite(BALL, X0, 12, legend = BALL_LEGEND)
    left = X0 + 12
    cx = (left + X1) // 2
    w = X1 - left - 2
    c.text(clip(c, head, "5x7", w), cx, 8, font = "5x7", color = color, align = "center")
    if sub != "":
        c.text(clip_words(c, sub, "4x5", w), cx, 20, font = "4x5", color = SOFT, align = "center")

def error_screen(c, d):
    e = d["error"]
    if e == "offline":
        message(c, "SCORES UNAVAILABLE", "CHECKING AGAIN SOON")
    elif e == "noteam":
        message(c, "TEAM NOT FOUND", "PICK A TEAM IN SETTINGS")
    elif e == "nogroup":
        message(c, "GROUP NOT FOUND", "PICK A GROUP IN SETTINGS")
    elif e == "notdrawn":
        message(c, comp_short(d["slug"]) + " " + d["label"], "NOT DRAWN YET - CHECK BACK SOON", SOFT)
    else:
        message(c, "SOMETHING WENT WRONG", "CHECKING AGAIN SOON")

def who(d):
    return display(d["name"]) if d["mode"] == "team" else comp_short(d["slug"]) + " " + d["label"]

# Flags, not federation crests: crests are each FA's trademark and turn to
# mush at 10 px. Two real sizes ship per nation (never scaled): <CODE>_s.png
# 15x10 for the score pages, <CODE>_l.png 18x12 for the fixture page.
FLAG = {"s": [15, 10], "l": [18, 12]}
FRAME = "#3A4256"  # 1 px frame so black-edged flags (BEL, GER, EST) hold their shape

def team_width(c, side, size):
    return max(c.text_width(side["abbr"], "teamabbrev"), FLAG[size][0] + 2)

def team_block(c, side, x, size, flag_y, code_y):
    """The team's flag (framed) centred over its country code. A team without
    a shipped flag gets its kit colour in the flag's place, so the column keeps
    its shape. Returns the width used."""
    w = team_width(c, side, size)
    fw, fh = FLAG[size][0], FLAG[size][1]
    fx = x + (w - fw) // 2
    c.rect(fx - 1, flag_y - 1, fx + fw, flag_y + fh, outline = FRAME)
    if side["id"] in TEAM_BY_ID:
        c.image(side["abbr"] + "_" + size + ".png", fx, flag_y)
    else:
        c.rect(fx, flag_y, fx + fw - 1, flag_y + fh - 1, fill = side["color"])
    cw = c.text_width(side["abbr"], "teamabbrev")
    c.text(side["abbr"], x + (w - cw) // 2, code_y, font = "teamabbrev", color = INK)
    return w

def hero_score(c, m):
    """HOME  2-1  AWAY, centred in the hero zone. The dash is drawn, not typed:
    in 10x16 the '-' glyph sits high and thin next to the digits."""
    hs = str(m["home"]["score"]) if m["home"]["score"] >= 0 else "-"
    aw = str(m["away"]["score"]) if m["away"]["score"] >= 0 else "-"
    # Each team is a stack: flag frame y 9-20, code y 22-30. The score sits
    # at y 10-25 so a "PENS 4-2" line still fits under it at y 27.
    hw = team_width(c, m["home"], "s")
    awd = team_width(c, m["away"], "s")
    sw = c.text_width(hs, "10x16") + 3 + 6 + 3 + c.text_width(aw, "10x16")
    total = hw + 7 + sw + 7 + awd
    x = X0 + (SPLIT - 2 - X0 - total) // 2
    team_block(c, m["home"], x, "s", 10, 22)
    x = x + hw + 7
    c.text(hs, x, 10, font = "10x16", color = INK)
    x = x + c.text_width(hs, "10x16") + 3
    c.rect(x, 17, x + 5, 18, fill = INK)
    x = x + 9
    c.text(aw, x, 10, font = "10x16", color = INK)
    x = x + c.text_width(aw, "10x16") + 7
    team_block(c, m["away"], x, "s", 10, 22)
    if m["home"]["so"] >= 0 and m["away"]["so"] >= 0:
        pens = "PENS " + str(m["home"]["so"]) + "-" + str(m["away"]["so"])
        cx = X0 + hw + 7 + (SPLIT - 2 - X0 - total) // 2 + sw // 2
        c.text(pens, cx, 27, font = "4x5", color = SOFT, align = "center")

def surname(n):
    t = display(n)
    i = t.find(". ")
    return t[i + 2:] if i >= 0 else t

def minute(v):
    return display(v).replace("'", "") + "'"

def scorers(m):
    """[[team id, name, "23' 67'(P)"], ...] in the order the goals went in,
    one row per player. Shootout kicks are not goals and are skipped."""
    rows = []
    index = {}
    for dt in m["details"] or []:
        if get(dt, "scoringPlay", False) != True or get(dt, "shootout", False) == True:
            continue
        tid = str(dig(dt, ["team", "id"], ""))
        ath = first(get(dt, "athletesInvolved", []))
        nm = surname(get(ath, "shortName", get(ath, "displayName", "")))
        if nm == "":
            nm = "GOAL"
        mn = minute(dig(dt, ["clock", "displayValue"], ""))
        if get(dt, "ownGoal", False) == True:
            mn = mn + "(OG)"
        elif get(dt, "penaltyKick", False) == True:
            mn = mn + "(P)"
        key = tid + "|" + nm
        if key in index:
            rows[index[key]][2] = rows[index[key]][2] + " " + mn
        else:
            index[key] = len(rows)
            rows.append([tid, nm, mn])
    return rows

def scorer_zone(c, m, tick):
    rows = scorers(m)
    colors = {m["home"]["id"]: m["home"]["color"], m["away"]["id"]: m["away"]["color"]}
    cx = (RZ + X1) // 2
    goals = max(m["home"]["score"], 0) + max(m["away"]["score"], 0)
    if len(rows) == 0:
        if goals == 0:
            c.text("NO GOALS YET" if m["state"] == "in" else "NO GOALS", cx, 17, font = "4x5", color = DIM, align = "center")
        else:
            c.text("SCORERS TO FOLLOW", cx, 17, font = "4x5", color = DIM, align = "center")
        return
    # Four rows fit (y 9-31 at a 6 px pitch). More than four scorers page
    # through in threes, one page per refresh, with a counter in the fourth row
    # - every scorer gets shown, none hidden behind a "+N MORE".
    pages = 1 if len(rows) <= 4 else (len(rows) + 2) // 3
    pg = tick % pages
    show = rows if pages == 1 else rows[pg * 3:pg * 3 + 3]
    y = 9 + (4 - (len(show) + (1 if pages > 1 else 0))) * 3
    for r in show:
        c.rect(RZ, y + 2, RZ + 1, y + 3, fill = colors.get(r[0], SOFT))
        # Minutes are measured first; the name gets what is left.
        mw = c.text_width(r[2], "4x5")
        room = X1 - (RZ + 4) + 1 - mw - 3
        if room < 16:
            # "SMITH 12' 34' 56'(P) 78'" - a hat-trick plus; shorten the minutes.
            r[2] = clip(c, r[2], "4x5", X1 - RZ - 4 - 19)
            mw = c.text_width(r[2], "4x5")
            room = X1 - (RZ + 4) + 1 - mw - 3
        nm = clip(c, r[1], "4x5", room)
        c.text(nm, RZ + 4, y, font = "4x5", color = INK)
        c.text(r[2], X1 - mw + 1, y, font = "4x5", color = SOFT)
        y = y + 6
    if pages > 1:
        more = "SCORERS " + str(pg + 1) + "/" + str(pages)
        c.text(more, X1 - c.text_width(more, "4x5") + 1, y, font = "4x5", color = DIM)

def live_chip(m):
    d = m["detail"]
    if m["status"] == "STATUS_HALFTIME" or d == "HT":
        return "LIVE HT"
    if d == "" or len(d) > 8:
        return "LIVE"
    return "LIVE " + d

def result_chip(m):
    if m["status"] == "STATUS_FINAL_PEN" or (m["home"]["so"] >= 0 and m["away"]["so"] >= 0):
        return "FT PENS"
    if m["status"] == "STATUS_FINAL_AET":
        return "AET"
    return "FT"

def score_page(c, ctx, m, chip, chip_bg, meta):
    header(c, chip, chip_bg, m["slug"], m["round"], meta)
    hero_score(c, m)
    c.vline(SPLIT, 9, 22, STRUCT)
    scorer_zone(c, m, ctx.now.unix // 120)

def fixture_page(c, m, s, meta):
    header(c, "NEXT", NEXT, m["slug"], m["round"], meta)
    # HOME v AWAY as flag-over-code stacks: frame y 8-21, code y 23-31.
    hw = team_width(c, m["home"], "l")
    aw = team_width(c, m["away"], "l")
    total = hw + 12 + 5 + 12 + aw
    x = X0 + (SPLIT - 2 - X0 - total) // 2
    team_block(c, m["home"], x, "l", 9, 23)
    c.text("V", x + hw + 12, 16, font = "5x7", color = DIM)
    team_block(c, m["away"], x + hw + 29, "l", 9, 23)
    c.vline(SPLIT, 9, 22, STRUCT)
    p = local(m["utc"], s["zone"])
    today = local(s["now"], s["zone"])
    cx = (RZ + X1) // 2
    c.text(day_text(p), cx, 9, font = "5x7", color = INK, align = "center")
    ko = clock(p, s["twelve"]) if m["time_ok"] else "TBC"
    kw = c.text_width("KO", "4x5") + 3 + c.text_width(ko, "6x8")
    kx = cx - kw // 2
    c.text("KO", kx, 19, font = "4x5", color = DIM)
    c.text(ko, kx + c.text_width("KO", "4x5") + 3, 17, font = "6x8", color = INK)
    n = p["days"] - today["days"]
    if n <= 0:
        when, col = "TODAY", WARN
    elif n == 1:
        when, col = "TOMORROW", WARN
    else:
        when, col = "IN " + str(n) + " DAYS", SOFT
    c.text(when, cx, 27, font = "4x5", color = col, align = "center")

def frame(ctx, n):
    """Rotate through n matches, one per refresh (120 s)."""
    return (ctx.now.unix // 120) % n if n > 1 else 0

def counter(i, n, word = ""):
    if n <= 1:
        return word
    return (word + " " if word != "" else "") + str(i + 1) + "/" + str(n)

# --------------------------------------------------------------------- pages

def now(c, ctx):
    """Live score if a followed match is on, otherwise the next fixture."""
    c.clear()
    s = settings(ctx)
    d = load_data(ctx, s)
    if d["error"] != "":
        error_screen(c, d)
        return
    if len(d["live"]) > 0:
        i = frame(ctx, len(d["live"]))
        m = with_details(d["live"][i])
        score_page(c, ctx, m, live_chip(m), LIVE, counter(i, len(d["live"])))
        return
    up = d["upcoming"]
    if len(up) == 0:
        message(c, "NO FIXTURES YET", who(d) + " - DATES TBC", NEXT)
        return
    # One matchday: everything within two days of the first fixture.
    day = [m for m in up if m["utc"] - up[0]["utc"] <= 2 * 1440]
    i = frame(ctx, len(day))
    fixture_page(c, day[i], s, counter(i, len(day)))

def result(c, ctx):
    """The latest result with its goalscorers."""
    c.clear()
    s = settings(ctx)
    d = load_data(ctx, s, True)
    if d["error"] != "":
        error_screen(c, d)
        return
    if len(d["results"]) == 0:
        message(c, "NO RESULTS YET", who(d), NEXT)
        return
    rnd = latest_round(d["results"]) if d["mode"] == "group" else [d["results"][0]]
    i = frame(ctx, len(rnd))
    m = with_details(rnd[i])
    p = local(m["utc"], s["zone"])
    meta = str(p["d"]) + " " + MONTHS[p["m"] - 1]
    if p["y"] != local(s["now"], s["zone"])["y"]:
        meta = meta + " " + str(p["y"])  # a finished qualifying group's last game
    if len(rnd) > 1:
        meta = counter(i, len(rnd))
    score_page(c, ctx, m, result_chip(m), FT, meta)

def table_slug(d):
    """The competition whose group table matters for a team right now: the one
    it is playing in, then the next it plays, then the last it played.
    Friendlies have no table."""
    for lst in [d["live"], d["upcoming"], d["results"]]:
        for m in lst:
            if comp_key(m["slug"]) != "fifa.friendly":
                return m["slug"]
    return ""

def table(c, ctx):
    """The group table, two columns, the followed team lit."""
    c.clear()
    s = settings(ctx)
    d = load_data(ctx, s)
    if d["error"] != "":
        error_screen(c, d)
        return
    me = ""
    if d["mode"] == "team":
        slug = table_slug(d)
        if slug == "":
            message(c, "NO GROUP TABLE", who(d) + " - NOT IN A GROUP", NEXT)
            return
        tid = d["id"]
        g = find_group(slug, lambda b: tid in [str(dig(en, ["team", "id"], "")) for en in dig(b, ["standings", "entries"], [])], ctx.now.year)
        if g == None:
            error_screen(c, {"error": "offline"})
            return
        if g[0] == None:
            message(c, "NO GROUP TABLE", who(d) + " - NOT IN A GROUP", NEXT)
            return
        label, rows, me = g[0], g[1], tid
    else:
        slug, label, rows = d["slug"], d["label"], d["rows"]
    if len(rows) == 0:
        message(c, "TABLE NOT READY", "CHECK BACK AFTER THE FIRST MATCHDAY", SOFT)
        return
    header(c, label if label != "" else "TABLE", comp_color(slug), slug, "TABLE")
    show = rows if len(rows) <= 6 else rows[:5]
    slots = len(show) + (1 if len(rows) > 6 else 0)
    per_col = (slots + 1) // 2
    pitch = 8 if per_col >= 3 else 10
    top = 9 if per_col >= 3 else (11 if per_col == 2 else 16)
    cols = [[X0, 92], [99, X1]]
    c.vline(95, 9, 22, STRUCT)
    for k in range(len(show)):
        r = show[k]
        col = cols[k // per_col] if per_col > 0 else cols[0]
        y = top + (k % per_col) * pitch
        lit = me == "" or r["id"] == me
        x = col[0]
        c.rect(x, y + 2, x + 1, y + 3, fill = r["note"])
        rk = str(r["rank"]) if r["rank"] < 99 else str(k + 1)
        c.text(rk, x + 4, y + 1, font = "4x5", color = DIM)
        c.text(r["abbr"], x + 11, y, font = "5x7", color = INK if lit else SOFT)
        # Right side first: "15 PTS", then "+13 GD" to its left.
        right = col[1]
        pw = c.text_width("PTS", "4x5")
        c.text("PTS", right - pw + 1, y + 1, font = "4x5", color = DIM)
        pts = str(r["pts"])
        ptw = c.text_width(pts, "5x7")
        c.text(pts, right - pw - 1 - ptw + 1, y, font = "5x7", color = INK if lit else SOFT)
        gd = ("-" if r["gdneg"] and r["gd"] != 0 else "+" if r["gd"] > 0 else "") + str(r["gd"])
        gx = right - pw - 1 - ptw - 4  # "SUI +14 GD 16 PTS" is 82 px of an 85 px column
        gdw = c.text_width("GD", "4x5")
        c.text("GD", gx - gdw + 1, y + 1, font = "4x5", color = DIM)
        gvw = c.text_width(gd, "4x5")
        c.text(gd, gx - gdw - 2 - gvw + 1, y + 1, font = "4x5", color = SOFT)
    if len(rows) > 6:
        k = 5
        col = cols[k // per_col]
        y = top + (k % per_col) * pitch
        c.text("+" + str(len(rows) - 5) + " MORE", col[0] + 4, y + 1, font = "4x5", color = DIM)
