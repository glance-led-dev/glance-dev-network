# DESIGN. SportBoards is a thin renderer for a school's SportBoards /board
# feed. The access code picks the school on the server; this app never names
# a school, never scrapes, and never matches opponent names.
#
# One programmed feed, delivered in blocks. Every render builds the same
# logical feed of up to 16 pages from all the content pools (announcements,
# Today, the featured event, sponsors, results, upcoming), then shows
# one 8-page block of it: Block A = logical pages 1-8, Block B = 9-16.
# Athletics pages hold two compact event cards (sport icon, event text,
# opponent logo, a bright FINAL / TODAY / UPCOMING chip); sponsor, featured
# and announcement pages are full width. See build_feed() and select_block().
#
# Page lifecycle (the Harrison lesson): the render server renders every page
# in its own process, and a page that errors shows black on the board. So
# every page makes the SAME single http.get (identical url + headers, so
# pages 2..8 are cache hits and agree on the block), every API value goes
# through a safe accessor before it reaches a c.* call, and every page always
# draws something.

API_URL = "https://sportboards-backend.onrender.com/board"

# Shorter than the manifest refresh (300s) on purpose. One render of the 8
# pages finishes in seconds, well inside 45s, so pages 2-8 reuse page 1's
# cached response and agree on the block; the next render, five minutes
# later, finds the entry expired and fetches once. About one /board request
# per school per refresh per render host, however many boards show it.
TTL_SECONDS = 45

# ---- programmed feed ----------------------------------------------------------
# PAGE_COUNT must equal the number of names under `pages:` in manifest.yaml.
PAGE_COUNT = 8
CARDS_PER_PAGE = 2
# Beats within each 8-page block, kept only when that content exists.
# Announcements open a block (pages 1-2): alerts and schedule updates open
# every block, celebrations and general announcements Block A only.
ANNOUNCEMENT_SLOTS = [1, 2]
SPONSOR_SLOTS = [3, 6]
FEATURED_SLOTS = [8]
# The most recent varsity results promoted into the early feed.
LEAD_RESULTS = 4
MAX_ANNOUNCEMENTS = len(ANNOUNCEMENT_SLOTS)

# Outer padding so the app reads as its own unit in the scroll sequence.
EDGE = 6

# Two cards per page: 6 + 182 + 8 + 182 + 6 = 384.
CARD_W = 182

# The school stripe between cards: 1px primary, 2px white, 1px primary (the
# helmet stripe), with DIVIDER_PAD of black on each side.
DIVIDER_W = 4
DIVIDER_PAD = 2
DIVIDER_GAP = DIVIDER_W + 2 * DIVIDER_PAD

# ---- logos --------------------------------------------------------------------
# Backend canonical opponent slug -> bundled asset: the SportBoards opponent
# directory's verified logos, one file per school (Sheridan and Sheridan MS
# share one). The backend resolves every name and alias to a slug; this is an
# exact-key lookup, never name matching. Only names listed here are ever
# drawn, so an unknown slug can't reference a missing asset (which would
# blank the page); a matched slug with no entry, or an unmatched name, shows
# FALLBACK_LOGO.
LOGOS = {
    "avon": "logo-avon.png",
    "battle-ground-middle": "logo-battle-ground-middle.png",
    "benton-central": "logo-benton-central.png",
    "bishop-chatard": "logo-bishop-chatard.png",
    "carmel": "logo-carmel.png",
    "carroll-flora": "logo-carroll-flora.png",
    "clinton-central": "logo-clinton-central.png",
    "clinton-prairie": "logo-clinton-prairie.png",
    "covington": "logo-covington.png",
    "crawfordsville": "logo-crawfordsville.png",
    "danville": "logo-danville.png",
    "delphi": "logo-delphi.png",
    "faith-christian-lafayette": "logo-faith-christian-lafayette.png",
    "fountain-central": "logo-fountain-central.png",
    "frankfort": "logo-frankfort.png",
    "frontier": "logo-frontier.png",
    "guerin-catholic": "logo-guerin-catholic.png",
    "hamilton-heights": "logo-hamilton-heights.png",
    "harrison-west-lafayette": "logo-harrison-west-lafayette.png",
    "indianapolis-cathedral": "logo-indianapolis-cathedral.png",
    "kokomo": "logo-kokomo.png",
    "lafayette-central-catholic": "logo-lafayette-central-catholic.png",
    "lafayette-jefferson": "logo-lafayette-jefferson.png",
    "lebanon": "logo-lebanon.png",
    "lewis-cass": "logo-lewis-cass.png",
    "logansport": "logo-logansport.png",
    "logansport-intermediate": "logo-logansport-intermediate.png",
    "mccutcheon": "logo-mccutcheon.png",
    "north-miami": "logo-north-miami.png",
    "north-montgomery": "logo-north-montgomery.png",
    "north-newton": "logo-north-newton.png",
    "north-white": "logo-north-white.png",
    "northwestern-kokomo": "logo-northwestern-kokomo.png",
    "pioneer-royal-center": "logo-pioneer-royal-center.png",
    "rensselaer-central": "logo-rensselaer-central.png",
    "roncalli-indianapolis": "logo-roncalli-indianapolis.png",
    "rossville": "logo-rossville.png",
    "seeger": "logo-seeger.png",
    "sheridan": "logo-sheridan.png",
    "sheridan-middle-school": "logo-sheridan.png",
    "southmont": "logo-southmont.png",
    "southwestern-middle-lafayette": "logo-southwestern-middle-lafayette.png",
    "taylor": "logo-taylor.png",
    "tecumseh-lafayette": "logo-tecumseh-lafayette.png",
    "terre-haute-north": "logo-terre-haute-north.png",
    "terre-haute-south": "logo-terre-haute-south.png",
    "tipton": "logo-tipton.png",
    "tri-county": "logo-tri-county.png",
    "twin-lakes": "logo-twin-lakes.png",
    "wainwright-middle": "logo-wainwright-middle.png",
    "west-lafayette": "logo-west-lafayette.png",
    "western": "logo-western.png",
    "western-boone": "logo-western-boone.png",
}
FALLBACK_LOGO = "sportboards-28.png"
LOGO = 28

# ---- sponsor logos ---------------------------------------------------------------
# Backend canonical sponsor slug -> [bundled asset, width in px]. Every logo
# is 28px tall on its own background plate. Exact-key lookup only; a sponsor
# whose slug isn't listed (or has none) gets the text billboard instead.
SPONSOR_LOGOS = {
    "banker-investment-group": ["sponsor-banker-investment-group.png", 36],
    "christos": ["sponsor-christos.png", 63],
    "coca-cola": ["sponsor-coca-cola.png", 71],
    "coors-remodeling": ["sponsor-coors-remodeling.png", 35],
    "foley-foundations": ["sponsor-foley-foundations.png", 49],
    "huston-electric": ["sponsor-huston-electric.png", 103],
    "indiana-national-guard": ["sponsor-indiana-national-guard.png", 25],
    "iu-health": ["sponsor-iu-health.png", 162],
    "midwest-driving-school": ["sponsor-midwest-driving-school.png", 84],
    "mr-fence-it": ["sponsor-mr-fence-it.png", 92],
    "timberstone-homes": ["sponsor-timberstone-homes.png", 59],
}
SPONSOR_LOGO_H = 28
# The "<MASCOT> / SPONSOR" label column on sponsor pages: ten 4x5 characters.
SPONSOR_LABEL_W = 50

# ---- sport icons --------------------------------------------------------------
# A word in the sport name -> an ICON_ART key (the art is at the bottom of this
# file). Checked in order, so "FLAG FOOTBALL" is matched before "FOOTBALL".
# Boys and girls share an icon; gender stays in the text.
SPORT_ICONS = [
    ["FLAG FOOTBALL", "flag_football"],
    ["FOOTBALL", "football"],
    ["VOLLEYBALL", "volleyball"],
    ["SOCCER", "soccer"],
    ["BASKETBALL", "basketball"],
    ["SOFTBALL", "softball"],
    ["BASEBALL", "baseball"],
    ["TENNIS", "tennis"],
    ["GOLF", "golf"],
    ["CROSS COUNTRY", "cross_country"],
    ["TRACK", "track"],
    ["SWIM", "swimming"],
    ["DIVING", "swimming"],
    ["WRESTLING", "wrestling"],
    ["CHEER", "cheer"],
]
FALLBACK_ICON = "athletics"
ICON = 24

# Icons are c.sprite() art: each character is a pixel, colored through a
# legend. These letters are the sport's own colors and never change (a
# football stays brown, a tennis ball optic yellow). The school's colors fill
# three role letters, resolved per school in icon_legend():
#   A  accent: the school color that reads on black
#   C  contrast: the other school color; may be dark, so the art only puts it
#      on light pixels (a volleyball panel, a band on a megaphone)
#   E  a second accent that must read on black (C, or light gray if C is dark)
ICON_COLORS = {
    "W": "#FFFFFF",  # white
    "w": "#B4B4B4",  # light gray
    "d": "#5A5A5A",  # dark gray (seams on white)
    "k": "#000000",  # black (seams on color)
    "B": "#B8642A",  # football brown
    "b": "#7A3E14",  # football shadow
    "O": "#FF7A1A",  # basketball orange
    "o": "#C04A00",  # basketball shadow
    "Y": "#D4FF2A",  # tennis-ball yellow
    "y": "#FFE41A",  # softball yellow
    "R": "#E8202A",  # stitching red
    "T": "#C8402A",  # running-track red
    "G": "#2EB84A",  # grass green
    "g": "#16803A",  # grass shadow
    "U": "#1E6EFF",  # water blue
    "u": "#78C4FF",  # water highlight
    "N": "#FFC21A",  # gold
    "n": "#B07A00",  # gold shadow
}
# Below this brightness a school color disappears against the black panel.
ICON_ACCENT_MIN = 60
ICON_ACCENT_DARK_FALLBACK = "#B4B4B4"

# ---- type ---------------------------------------------------------------------
# Every character the 5x7 and 4x5 fonts can draw. Anything else is dropped
# (apostrophes) or becomes a space, so API text can't hit a missing glyph.
GLYPHS = " !#$%&()*+,-./0123456789:?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
FONTS = ["5x7", "4x5"]

WIN = "green"
LOSS = "red"
TIE = "amber"
LABEL = "gray"
TEXT = "white"
# Section chips: black 4x5 text on a filled pill. Kept clear of the W/L/T
# green, red and amber so a chip can't be misread as an outcome.
CHIP_RESULT = "#A0A0A0"
CHIP_TODAY = "skyblue"
CHIP_UPCOMING = "#C8A0FF"
CHIP_FEATURED = "#FFC21A"
URGENT_RED = "#E01818"
URGENT_AMBER = "#FFB000"
CELEBRATION_GOLD = "#FFC21A"
ERROR_HEAD = "#E8B04A"
BRAND_FALLBACK = "amber"

# =============================================================================
# Safe accessors: nothing from the API reaches a c.* call unchecked.
# =============================================================================

def is_dict(v):
    return type(v) == "dict"

def get_dict(d, key):
    if is_dict(d) and is_dict(d.get(key)):
        return d.get(key)
    return {}

def get_list(d, key):
    if is_dict(d) and type(d.get(key)) == "list":
        return d.get(key)
    return []

def get_str(d, key):
    """A trimmed string, or "" for missing / null / non-string values."""
    if is_dict(d) and type(d.get(key)) == "string":
        return d.get(key).strip()
    return ""

def get_score(d, key):
    """Scores arrive as strings ("24", "112.5"); accept plain numbers too."""
    if not is_dict(d):
        return ""
    v = d.get(key)
    t = type(v)
    if t == "string":
        return v.strip()
    if t == "int":
        return str(v)
    if t == "float":
        s = str(v)
        if s.endswith(".0"):
            s = s[:-2]
        return s
    return ""

def get_bool(d, key, fallback):
    if is_dict(d) and type(d.get(key)) == "bool":
        return d.get(key)
    return fallback

def panel_text(s):
    """Uppercase and reduce to glyphs the panel fonts can draw."""
    out = ""
    for ch in s.upper().elems():
        if ch in GLYPHS:
            out += ch
        elif ch == "'" or ch == "’":
            continue
        else:
            out += " "
    return " ".join(out.split())

HEX = "0123456789ABCDEF"

def safe_color(value):
    """Return "#RRGGBB" if value is a valid hex color, else ""."""
    if type(value) != "string":
        return ""
    v = value.strip().upper()
    if len(v) != 7 or not v.startswith("#"):
        return ""
    for ch in v[1:].elems():
        if ch not in HEX:
            return ""
    return v

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def readable_brand(school):
    """The school's color if it reads on black; navy and maroon don't."""
    for key in ["primary_color", "secondary_color"]:
        col = safe_color(school.get(key))
        if col != "" and brightness(col) >= 80:
            return col
    return BRAND_FALLBACK

def stripe_color(school):
    """The school's color for the borders, the divider stripe and the frame
    rules. The primary leads, dark or not (navy still frames the white
    center), unless it is near-black and would vanish on the black panel;
    then the secondary (Delphi: black -> its gold). Display only: the
    official colors are untouched."""
    for key in ["primary_color", "secondary_color"]:
        col = safe_color(school.get(key))
        if col != "" and not is_near_black(col):
            return col
    return BRAND_FALLBACK

def is_near_black(col):
    """Every channel at or below 0x28: indistinguishable from the panel."""
    return max(int(col[1:3], 16), int(col[3:5], 16), int(col[5:7], 16)) <= 40

def to_hex(r, g, b):
    out = "#"
    for v in [r, g, b]:
        v = max(0, min(255, v))
        out += HEX[v // 16] + HEX[v % 16]
    return out

def shade(hex_color, num, den):
    """hex_color scaled toward black by num/den."""
    r = int(hex_color[1:3], 16) * num // den
    g = int(hex_color[3:5], 16) * num // den
    b = int(hex_color[5:7], 16) * num // den
    return to_hex(r, g, b)

def icon_legend(school):
    """ICON_COLORS plus the school's A / C / E roles. Primary leads; when it
    can't be seen on black (navy, maroon, black) the secondary takes the A
    role and the primary moves to C, where it only ever sits on light pixels."""
    p = safe_color(school.get("primary_color"))
    s = safe_color(school.get("secondary_color"))
    if p == "":
        p = s
        s = ""
    if p == "":
        p = "#FFB000"
    if s == "":
        s = shade(p, 1, 2)
    a = p
    c = s
    if brightness(a) < ICON_ACCENT_MIN and brightness(c) > brightness(a):
        a = s
        c = p
    if brightness(a) < ICON_ACCENT_MIN:
        a = "#FFFFFF"
    e = c if brightness(c) >= ICON_ACCENT_MIN else ICON_ACCENT_DARK_FALLBACK
    legend = dict(ICON_COLORS)
    legend["A"] = a
    legend["C"] = c
    legend["E"] = e
    return legend

def logo_for(slug):
    if slug in LOGOS:
        return LOGOS[slug]
    return FALLBACK_LOGO

def sport_icon(event):
    sport = panel_text(get_str(event, "sport"))
    for pair in SPORT_ICONS:
        if pair[0] in sport:
            return pair[1]
    return FALLBACK_ICON

# =============================================================================
# Fetch: one GET, mapped onto a small set of named states.
# =============================================================================

def fetch_board(ctx):
    code = ctx.inputs.get("accesscode", "")
    if type(code) != "string" or code.strip() == "":
        return {"state": "NOKEY"}

    resp = http.get(
        API_URL,
        headers = {
            "Authorization": "Bearer " + code.strip(),
            "Accept": "application/json",
        },
        ttl_seconds = TTL_SECONDS,
    )
    status = resp["status_code"]

    if status == 401:
        return {"state": "AUTH"}
    if status == 403:
        return {"state": "INACTIVE"}
    if status != 200:
        # 0 (timeout, DNS, cold start), 5xx, unexpected 3xx/4xx.
        return {"state": "DOWN"}

    data = resp["json"]
    if not is_dict(data):
        return {"state": "BAD"}

    # The three stream collections. If one is present but not a list, showing
    # the board without it would quietly claim that section is empty.
    for key in ["results", "today", "upcoming"]:
        if key in data and type(data[key]) != "list":
            return {"state": "BAD"}

    return {"state": "OK", "data": data}

# =============================================================================
# Model: API events -> display-ready cards (plain strings only).
# =============================================================================

def level_forms(level):
    """Full -> shortest forms of a competition level. Never dropped."""
    l = panel_text(level)
    short = {
        "VARSITY": ["VARSITY", "VAR", "V"],
        "VARSITY/JV": ["VARSITY/JV", "V/JV"],
        "FRESHMAN": ["FRESHMAN", "FRESH", "FR"],
        "MIDDLE SCHOOL": ["MIDDLE SCHOOL", "MS"],
        "JUNIOR HIGH": ["JUNIOR HIGH", "JH"],
        "6TH GRADE": ["6TH GRADE", "6TH"],
        "7TH GRADE": ["7TH GRADE", "7TH"],
        "8TH GRADE": ["8TH GRADE", "8TH"],
        "UNIFIED": ["UNIFIED", "UNIF"],
    }
    if l in short:
        return short[l]
    return [l]

def sport_forms(sport):
    s = panel_text(sport)
    short = {
        "CROSS COUNTRY": ["CROSS COUNTRY", "XC"],
        "SWIMMING & DIVING": ["SWIMMING & DIVING", "SWIM & DIVE", "SWIM"],
        "TRACK & FIELD": ["TRACK & FIELD", "TRACK"],
        "VOLLEYBALL": ["VOLLEYBALL", "VOLLEY"],
        "BASKETBALL": ["BASKETBALL", "BBALL"],
        "FLAG FOOTBALL": ["FLAG FOOTBALL", "FLAG FB"],
        "GYMNASTICS": ["GYMNASTICS", "GYM"],
    }
    if s in short:
        return short[s]
    return [s]

def gender_forms(gender):
    g = panel_text(gender)
    short = {"GIRLS": ["GIRLS", "G"], "BOYS": ["BOYS", "B"]}
    if g in short:
        return short[g]
    return [g]

def join_words(parts):
    return " ".join([p for p in parts if p != ""])

def team_label_ladder(event):
    """Label candidates, e.g. BOYS VARSITY CROSS COUNTRY ->
    BOYS VAR CROSS COUNTRY -> BOYS VARSITY XC -> BOYS V CROSS COUNTRY -> ...
    Each keeps all three facts (gender, level, sport); only the spelling
    shrinks."""
    genders = gender_forms(get_str(event, "gender"))
    levels = level_forms(get_str(event, "level"))
    sports = sport_forms(get_str(event, "sport"))

    # Fewest abbreviations first; on a tie, level shortens before sport and
    # gender shortens last.
    ladder = []
    for rank in range(len(genders) + len(sports) + len(levels)):
        for gi in range(len(genders)):
            for si in range(len(sports)):
                for li in range(len(levels)):
                    if gi + si + li != rank:
                        continue
                    label = join_words([genders[gi], levels[li], sports[si]])
                    if label != "" and label not in ladder:
                        ladder.append(label)
    if len(ladder) == 0:
        title = panel_text(get_str(event, "title"))
        ladder.append(title if title != "" else "ATHLETICS")
    return ladder

def opponent_name(event):
    raw = get_str(event, "opponent")
    if raw == "" or raw.upper() == "TBD":
        return ""
    details = get_dict(event, "opponent_details")
    if get_bool(details, "matched", False):
        name = get_str(details, "name")
        if name != "":
            return panel_text(name)
    return panel_text(raw)

# Title words that mark the IHSAA tournament series. "STATE" alone counts
# only as the whole title or before one of STATE_FOLLOWERS.
TOURNAMENT_WORDS = ["SECTIONAL", "SECTIONALS", "REGIONAL", "REGIONALS",
                    "SEMISTATE", "IHSAA"]
STATE_FOLLOWERS = ["FINAL", "FINALS", "CHAMPIONSHIP", "CHAMPIONSHIPS",
                   "TOURNAMENT", "MEET"]

def is_tournament(event):
    """True for an IHSAA tournament-series event (Sectional, Regional,
    Semi-State, State). Uses the backend's tournament_stage or event_type
    when it sends them, otherwise the title. Invitationals, conference meets
    and ordinary games are not tournaments here."""
    if get_str(event, "tournament_stage").strip() != "":
        return True
    if get_str(event, "event_type").strip().lower() == "state tournament":
        return True
    words = panel_text(get_str(event, "title")).replace("-", " ").replace(".", " ").split(" ")
    words = [w for w in words if w != ""]
    for i in range(len(words)):
        w = words[i]
        if w in TOURNAMENT_WORDS:
            return True
        if w == "STATE":
            if len(words) == 1:
                return True
            if i > 0 and words[i - 1] == "SEMI":
                return True
            if i + 1 < len(words) and words[i + 1] in STATE_FOLLOWERS:
                return True
    return False

def draw_trophy(c, x, y):
    """A gold trophy in a 28px logo slot, for a tournament with no named
    opponent: the same on every school's board."""
    c.sprite(ICON_ART["trophy"], x + (LOGO - ICON) // 2, y + (LOGO - ICON) // 2, legend = TROPHY_LEGEND)

def opponent_logo(event):
    """None when there is no opponent: never draw a fake logo for TBD."""
    if opponent_name(event) == "":
        return None
    details = get_dict(event, "opponent_details")
    if get_bool(details, "matched", False):
        return logo_for(get_str(details, "slug"))
    return FALLBACK_LOGO

# Generic school-type suffixes, longest first. Dropping one is display
# shortening of the name the backend sent, not opponent matching.
NAME_SUFFIXES = [
    " JUNIOR-SENIOR HIGH SCHOOL", " JR-SR HIGH SCHOOL", " JR SR HIGH SCHOOL",
    " COMMUNITY HIGH SCHOOL", " HIGH SCHOOL", " JR-SR HS", " HS",
]

def name_forms(name):
    forms = [name]
    for suffix in NAME_SUFFIXES:
        if name.endswith(suffix) and len(name) > len(suffix):
            forms.append(name[:len(name) - len(suffix)])
            break
    return forms

def opponent_ladder(event):
    """Candidates for the middle line, longest first; [] when empty."""
    name = opponent_name(event)
    if name == "":
        title = panel_text(get_str(event, "title"))
        return [title] if title != "" else []
    prefix = ""
    ha = get_str(event, "home_away").upper()
    if ha.startswith("H"):
        prefix = "VS "
    elif ha.startswith("A"):
        prefix = "AT "
    return [prefix + n for n in name_forms(name)]

def short_date(event_date):
    """YYYY-MM-DD -> M/D, or "" if it isn't that shape."""
    parts = event_date.split("-")
    if len(parts) != 3 or len(parts[1]) != 2 or len(parts[2]) != 2:
        return ""
    if not (parts[1].isdigit() and parts[2].isdigit()):
        return ""
    return str(int(parts[1])) + "/" + str(int(parts[2]))

# ---- dates and times -----------------------------------------------------------
# starts_at arrives as UTC ISO-8601 ("2026-10-06T21:00:00+00:00"). Starlark has
# no time zone database, so the school's IANA zone (school.timezone) is looked
# up here: [standard offset in minutes, observes US daylight saving]. A zone
# not listed shows no start time rather than a wrong one.
ZONES = {
    "America/New_York": [-300, True],
    "America/Detroit": [-300, True],
    "America/Indiana/Indianapolis": [-300, True],
    "America/Indianapolis": [-300, True],
    "America/Indiana/Marengo": [-300, True],
    "America/Indiana/Petersburg": [-300, True],
    "America/Indiana/Vevay": [-300, True],
    "America/Indiana/Vincennes": [-300, True],
    "America/Indiana/Winamac": [-300, True],
    "America/Indiana/Knox": [-360, True],
    "America/Indiana/Tell_City": [-360, True],
    "America/Kentucky/Louisville": [-300, True],
    "America/Kentucky/Monticello": [-300, True],
    "America/Chicago": [-360, True],
    "America/Menominee": [-360, True],
    "America/North_Dakota/Center": [-360, True],
    "America/Denver": [-420, True],
    "America/Boise": [-420, True],
    "America/Phoenix": [-420, False],
    "America/Los_Angeles": [-480, True],
    "America/Anchorage": [-540, True],
    "Pacific/Honolulu": [-600, False],
}
WEEKDAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

def digits(s):
    """int value of an all-digit string, or -1."""
    if s == "" or not s.isdigit():
        return -1
    return int(s)

def days_from_civil(y, m, d):
    """Days since 1970-01-01 for a proleptic Gregorian date."""
    if m <= 2:
        y = y - 1
    era = y // 400
    yoe = y - era * 400
    doy = (153 * ((m + 9) % 12) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def parse_ymd(text):
    """YYYY-MM-DD (or the date part of an ISO stamp) -> [y, m, d], or []."""
    if len(text) < 10 or text[4:5] != "-" or text[7:8] != "-":
        return []
    y = digits(text[0:4])
    m = digits(text[5:7])
    d = digits(text[8:10])
    if y < 1970 or m < 1 or m > 12 or d < 1 or d > 31:
        return []
    return [y, m, d]

def weekday(days):
    return (days + 4) % 7  # 1970-01-01 was a Thursday; 0 = Sunday

def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    return first + (7 - weekday(first)) % 7 + 7 * (n - 1)

def utc_minutes(stamp):
    """ISO-8601 with Z or +HH:MM -> minutes since the epoch (UTC), or -1."""
    ymd = parse_ymd(stamp)
    if len(ymd) == 0 or len(stamp) < 16 or stamp[10:11] not in ["T", " "]:
        return -1
    hh = digits(stamp[11:13])
    mm = digits(stamp[14:16])
    if hh < 0 or hh > 23 or mm < 0 or mm > 59:
        return -1
    total = days_from_civil(ymd[0], ymd[1], ymd[2]) * 1440 + hh * 60 + mm
    tail = stamp[16:]
    if tail.endswith("Z"):
        return total
    sign = 0
    pos = -1
    for i in range(len(tail)):
        if tail[i] == "+" or tail[i] == "-":
            sign = 1 if tail[i] == "+" else -1
            pos = i
    if pos < 0:
        return -1  # no offset: can't tell what zone the clock time is in
    oh = digits(tail[pos + 1:pos + 3])
    om = digits(tail[pos + 4:pos + 6])
    if oh < 0 or om < 0:
        return -1
    return total - sign * (oh * 60 + om)

def local_minutes(utc, zone):
    """Minutes since the epoch on the school's wall clock, or -1."""
    if utc < 0 or zone not in ZONES:
        return -1
    std = ZONES[zone][0]
    if not ZONES[zone][1]:
        return utc + std
    # US rule: 2:00 local on the second Sunday of March to 2:00 local on
    # the first Sunday of November. Year from the UTC instant is safe; the
    # transitions are nowhere near New Year.
    days = utc // 1440
    year = 1970 + days // 366
    for i in range(3):
        if days_from_civil(year + 1, 1, 1) <= days:
            year += 1
    start = nth_sunday(year, 3, 2) * 1440 + 120 - std
    end = nth_sunday(year, 11, 1) * 1440 + 120 - (std + 60)
    if utc >= start and utc < end:
        return utc + std + 60
    return utc + std

def clock_forms(event, zone):
    """["6:30 PM", "6:30PM"] on the school's clock, or [] when starts_at is
    missing or can't be placed in the school's zone."""
    local = local_minutes(utc_minutes(get_str(event, "starts_at")), zone)
    if local < 0:
        return []
    mins = local % 1440
    h = mins // 60
    m = mins % 60
    ampm = "PM" if h >= 12 else "AM"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    t = str(h12) + ":" + ("0" if m < 10 else "") + str(m)
    return [t + " " + ampm, t + ampm]

def date_forms(event):
    """["WED 10/7", "10/7"] from event_date (already the school's local
    date), or [] if it isn't a date."""
    ymd = parse_ymd(get_str(event, "event_date"))
    if len(ymd) == 0:
        return []
    md = str(ymd[1]) + "/" + str(ymd[2])
    return [WEEKDAYS[weekday(days_from_civil(ymd[0], ymd[1], ymd[2]))] + " " + md, md]

def outcome_mark(outcome):
    o = outcome.lower()
    if o == "win":
        return ["W", WIN]
    if o == "loss":
        return ["L", LOSS]
    if o == "tie" or o == "draw":
        return ["T", TIE]
    return ["", TEXT]

def score_text(event, mark):
    """Winner's score first on a W or L; school first otherwise. Both
    scores must be present, or nothing is shown."""
    ours = panel_text(get_score(event, "school_score"))
    theirs = panel_text(get_score(event, "opponent_score"))
    if ours == "" or theirs == "":
        return ""
    if mark == "L":
        return theirs + "-" + ours
    return ours + "-" + theirs

# Bottom-row parts. A card offers its bottom row as a list of variants,
# widest first; the drawer uses the first that fits. A part marked clip may
# be shortened if even the last variant is too wide.
def chip(text, color):
    return {"t": text, "f": "4x5", "col": color, "chip": True, "clip": False}

def part(text, font, color, clip = False):
    return {"t": text, "f": font, "col": color, "chip": False, "clip": clip}

def result_bottom(event):
    """FINAL  W 24-10  10/3"""
    tag = chip("FINAL", CHIP_RESULT)
    mark = outcome_mark(get_str(event, "outcome"))
    score = score_text(event, mark[0])
    date = short_date(get_str(event, "event_date"))
    tail = [part(date, "4x5", LABEL)] if date != "" else []

    if mark[0] == "" and score == "":
        # e.g. a meet placing; shown as the backend wrote it.
        detail = panel_text(get_str(event, "result_text"))
        if detail == "":
            return [[tag] + tail]
        return [
            [tag, part(detail, "5x7", TEXT)] + tail,
            [tag, part(detail, "4x5", TEXT, clip = True)] + tail,
        ]

    mid = []
    if mark[0] != "":
        mid.append(part(mark[0], "5x7", mark[1]))
    if score != "":
        mid.append(part(score, "5x7", TEXT))
    if len(tail) > 0:
        # The score matters more than the date: drop the date first.
        return [[tag] + mid + tail, [tag] + mid]
    return [[tag] + mid]

def scheduled_bottom(tag, dates, clocks):
    """Variants for TODAY 6:00 PM or UPCOMING WED 10/7 6:00 PM. A missing
    date or time is simply absent; nothing is filled in."""
    out = []
    date_opts = [part(d, "5x7", TEXT) for d in dates] or [None]
    clock_opts = [part(t, "5x7", TEXT) for t in clocks] or [None]
    for d in date_opts:
        for t in clock_opts:
            out.append([p for p in [tag, d, t] if p != None])
    # Only then shrink the time to 4x5.
    if len(clocks) > 0:
        small = part(clocks[len(clocks) - 1], "4x5", TEXT)
        for d in date_opts:
            out.append([p for p in [tag, d, small] if p != None])
    return out

def event_card(event, kind, zone):
    if kind == "result":
        bottom = result_bottom(event)
    elif kind == "today":
        bottom = scheduled_bottom(chip("TODAY", CHIP_TODAY), [],
                                  clock_forms(event, zone))
    else:
        bottom = scheduled_bottom(chip("UPCOMING", CHIP_UPCOMING),
                                  date_forms(event), clock_forms(event, zone))
    return {
        "kind": kind,
        "icon": sport_icon(event),
        "labels": team_label_ladder(event),
        "opponent": opponent_ladder(event),
        "opp_logo": opponent_logo(event),
        "opp_trophy": opponent_name(event) == "" and is_tournament(event),
        "bottom": bottom,
    }

def has_content(event):
    """False only for rows a viewer couldn't identify: not a dict, or no
    sport, title or opponent (a bare "3-1" means nothing on the wall).
    Level never decides this."""
    if not is_dict(event):
        return False
    for key in ["sport", "title", "opponent"]:
        if panel_text(get_str(event, key)) != "":
            return True
    return False

# Stream order. Each collection is used whole and in API order; the API
# already applies the results/upcoming windows. max_results is ignored.
SECTIONS = [
    ["results", "show_results", "result"],
    ["today", "show_today", "today"],
    ["upcoming", "show_upcoming", "upcoming"],
]

def sections_on(data):
    settings = get_dict(data, "settings")
    return [sec for sec in SECTIONS if get_bool(settings, sec[1], True)]

def display_colors(school):
    """The school's colors as the panel shows them. A backend-supplied
    display_primary_color (an LED-calibrated stand-in for a primary color
    that reads too dark on the panel) replaces primary_color for display
    only; the official colors are never changed."""
    out = dict(school)
    led = safe_color(school.get("display_primary_color"))
    if led != "":
        out["primary_color"] = led
    return out

def school_info(data):
    school = display_colors(get_dict(data, "school"))
    name = panel_text(get_str(school, "name"))
    return {
        "name": name if name != "" else "ATHLETICS",
        "short": school_short(name if name != "" else "ATHLETICS"),
        "mascot": panel_text(get_str(school, "mascot")),
        "logo": logo_for(get_str(school, "slug")),
        "brand": readable_brand(school),
        "stripe": stripe_color(school),
        "legend": icon_legend(school),
    }

# =============================================================================
# Programmed feed. One logical feed of up to 16 pages is built from every
# content pool, then delivered by Glance in 8-page blocks (A = pages 1-8,
# B = pages 9-16). Importance decides what gets in; the slot plan below
# decides where it sits, so sponsors and the featured event land at fixed
# beats instead of in a pile at either end.
# =============================================================================

def is_varsity(event):
    return panel_text(get_str(event, "level")) == "VARSITY"

def event_key(event):
    return get_score(event, "id")

def school_short(name):
    forms = name_forms(name)
    return forms[len(forms) - 1]

def is_canceled(event):
    """Canceled by the backend's status, which comes from Eventlink's own
    canceled marker. Only when an event carries no status at all does a
    "CANCELED:" title prefix count. Postponed and rescheduled events stay
    eligible: they have no status of their own."""
    status = get_str(event, "status").strip().lower()
    if status != "":
        return status in ["canceled", "cancelled"]
    title = panel_text(get_str(event, "title"))
    return title.startswith("CANCELED:") or title.startswith("CANCELLED:")

def pick_featured(data, zone):
    """The first featured event that hasn't happened yet (today counts) and
    isn't canceled. The backend's `featured` list is ordered by date, then
    start time; a canceled event is skipped for the next one in that order."""
    today = get_str(data, "local_date")
    for event in get_list(data, "featured"):
        if not has_content(event) or is_canceled(event):
            continue
        day = get_str(event, "event_date")
        if today != "" and day != "" and day < today:
            continue
        kind = "today" if day == today else "upcoming"
        card = event_card(event, kind, zone)
        card["event"] = event
        card["qr"] = ticket_qr(event)
        card["dates"] = date_forms(event)
        card["clocks"] = clock_forms(event, zone)
        return card
    return None

def ticket_qr(event):
    """A ticket QR as rows of "0"/"1" strings, or None.

    The backend sends no per-event ticket URL or QR today, and GDN has no QR
    encoder, so this reads a precomputed module matrix from the event's
    `ticket_qr.modules` (a field the backend will need to add). Anything
    that isn't a square 21-29 module grid of 0/1 is ignored."""
    qr = get_dict(event, "ticket_qr")
    rows = get_list(qr, "modules")
    n = len(rows)
    if n < 21 or n > 29:
        return None
    for row in rows:
        if type(row) != "string" or len(row) != n:
            return None
        for ch in row.elems():
            if ch != "0" and ch != "1":
                return None
    return {"rows": rows, "label": panel_text(get_str(qr, "label"))}

# announcement_type -> display category. The backend's current values
# (general, cancellation, postponement, schedule_change) and the four
# category names both map, so the app works before and after the backend
# adopts the categories. Anything else shows as an ALERT: an announcement
# the app can't classify is never quieter than one it can.
ANNOUNCEMENT_CATEGORIES = {
    "urgent_alert": "alert",
    "urgent": "alert",
    "alert": "alert",
    "schedule_change": "schedule",
    "schedule_update": "schedule",
    "cancellation": "schedule",
    "cancelled": "schedule",
    "canceled": "schedule",
    "postponement": "schedule",
    "postponed": "schedule",
    "time_change": "schedule",
    "venue_change": "schedule",
    "location_change": "schedule",
    "celebration": "celebration",
    "achievement": "celebration",
    "general": "general",
    "general_announcement": "general",
    "announcement": "general",
}
# Priority order: which two show when more are active, and their order on
# the page slots.
CATEGORY_ORDER = ["alert", "schedule", "celebration", "general"]
# Categories that open every block; the rest open Block A only.
EVERY_BLOCK = ["alert", "schedule"]
# Legacy schedule types keep their specific heading; every other type in a
# category uses the category's heading.
TYPE_HEADERS = {
    "cancellation": "CANCELLED",
    "cancelled": "CANCELLED",
    "canceled": "CANCELLED",
    "postponement": "POSTPONED",
    "postponed": "POSTPONED",
}
CATEGORY_HEADERS = {
    "alert": "ALERT",
    "schedule": "SCHEDULE UPDATE",
    "celebration": "CELEBRATION",
    "general": "ANNOUNCEMENT",
}

def announcement_category(item):
    kind = get_str(item, "announcement_type").strip().lower()
    return ANNOUNCEMENT_CATEGORIES.get(kind, "alert")

def announcement_pages(data):
    """Display announcements as full-width pages, highest category first,
    at most MAX_ANNOUNCEMENTS. Only the backend's is_priority announcements
    are display announcements; the category comes from announcement_type."""
    out = []
    for item in get_list(data, "announcements"):
        if not get_bool(item, "is_priority", False):
            continue
        headline = panel_text(get_str(item, "headline"))
        message = panel_text(get_str(item, "message"))
        if headline == "" and message == "":
            continue
        category = announcement_category(item)
        kind = get_str(item, "announcement_type").strip().lower()
        out.append({
            "type": "announcement",
            "category": category,
            "header": TYPE_HEADERS.get(kind, CATEGORY_HEADERS[category]),
            "headline": headline,
            "message": message,
        })
    ranked = []
    for category in CATEGORY_ORDER:
        ranked.extend([p for p in out if p["category"] == category])
    return ranked[:MAX_ANNOUNCEMENTS]

def sponsor_pages(data):
    out = []
    for item in get_list(data, "sponsors"):
        name = panel_text(get_str(item, "name"))
        if name == "":
            continue
        slug = get_str(item, "slug")
        out.append({
            "type": "sponsor",
            "name": name,
            "slug": slug,
            "logo": SPONSOR_LOGOS.get(slug),
            "site": site_text(get_str(item, "website_url")),
        })
    return out

def site_text(url):
    """https://www.example.com/path -> EXAMPLE.COM"""
    u = url.strip().lower()
    for p in ["https://", "http://"]:
        if u.startswith(p):
            u = u[len(p):]
    if u.startswith("www."):
        u = u[4:]
    u = u.split("/")[0]
    return panel_text(u)

def sponsor_offset(data):
    """Where this render's sponsor window starts. Taken from the cached
    response's generated_at (the minute it was fetched), so every page of
    one render agrees, and each fresh fetch moves the window on by one full
    feed of sponsor beats; with any sponsor count, every sponsor comes round."""
    minute = utc_minutes(get_str(data, "generated_at"))
    if minute < 0:
        return 0
    return minute * len(SPONSOR_SLOTS) * 2

def sponsor_plan(sponsors, block_count, offset = 0):
    """Logical slot -> sponsor page. Each sponsor appears at most once per
    block: one sponsor takes the first sponsor beat of each block, two or
    more fill both beats, cycling through the list from `offset`."""
    plan = {}
    n = len(sponsors)
    if n == 0:
        return plan
    k = offset % n
    for b in range(block_count):
        for i in range(len(SPONSOR_SLOTS)):
            if n == 1 and i > 0:
                continue
            plan[b * PAGE_COUNT + SPONSOR_SLOTS[i]] = sponsors[k % n]
            k += 1
    return plan

def featured_plan(featured, block_count):
    plan = {}
    if featured == None:
        return plan
    for b in range(block_count):
        for s in FEATURED_SLOTS:
            plan[b * PAGE_COUNT + s] = {"type": "featured", "card": featured}
    return plan

def interleave_pairs(first, second):
    """F F S S F F S S ... then whatever is left of either."""
    out = []
    i = 0
    j = 0
    for _ in range(len(first) + len(second)):
        if i >= len(first) and j >= len(second):
            break
        for _ in range(CARDS_PER_PAGE):
            if i < len(first):
                out.append(first[i])
                i += 1
        for _ in range(CARDS_PER_PAGE):
            if j < len(second):
                out.append(second[j])
                j += 1
    return out

def card_pages(cards):
    pages = []
    for i in range(0, len(cards), CARDS_PER_PAGE):
        pages.append({"type": "cards", "cards": cards[i:i + CARDS_PER_PAGE]})
    return pages

def build_feed(data, zone):
    """The logical feed: {"pages": [...], "blocks": 1 or 2}.

    Allocation (what gets in), by importance: announcements, every Today
    event, the four most recent varsity results, upcoming in date order,
    then the remaining results. Placement: announcements open a block
    (pages 1-2; see announcement_plan), sponsors take pages 3 and 6 and the
    featured event page 8 of every block; the rest is Today and the lead
    results interleaved in pairs, then upcoming, then deeper results. When
    the cards don't fit, the cut comes from the bottom of that order."""
    featured = pick_featured(data, zone)
    fkey = event_key(featured["event"]) if featured != None else ""
    announcements = announcement_pages(data)
    sponsors = sponsor_pages(data)

    def cards_for(key, kind):
        out = []
        for event in get_list(data, key):
            if has_content(event) and (fkey == "" or event_key(event) != fkey):
                out.append(event_card(event, kind, zone))
        return out

    on = [sec[0] for sec in sections_on(data)]
    today = cards_for("today", "today") if "today" in on else []
    upcoming = cards_for("upcoming", "upcoming") if "upcoming" in on else []
    results = []
    lead = []
    if "results" in on:
        for event in get_list(data, "results"):
            if not has_content(event):
                continue
            card = event_card(event, "result", zone)
            if is_varsity(event) and len(lead) < LEAD_RESULTS:
                lead.append(card)
            else:
                results.append(card)

    # One block if everything fits in 8 pages, else two.
    blocks = 1
    for attempt in [1, 2]:
        blocks = attempt
        reserved = dict(sponsor_plan(sponsors, blocks, sponsor_offset(data)))
        reserved.update(featured_plan(featured, blocks))
        reserved.update(announcement_plan(announcements, blocks))
        free = blocks * PAGE_COUNT - len(reserved)
        cap = free * CARDS_PER_PAGE

        # Allocation by importance. Announcement, sponsor and featured pages
        # are already reserved, so the cards share what is left.
        t = today[:cap]
        room = cap - len(t)
        l = lead[:room]
        room -= len(l)
        u = upcoming[:room]
        room -= len(u)
        r = results[:room]
        units = card_pages(interleave_pairs(t, l) + u + r)
        needed = len(today) + len(lead) + len(upcoming) + len(results)
        if attempt == 1 and len(t) + len(l) + len(u) + len(r) == needed:
            break

    return {"pages": place(units, reserved, blocks), "blocks": blocks}

def announcement_plan(announcements, block_count):
    """Logical slot -> announcement page. Block A opens with every
    announcement; later blocks open with the alerts and schedule updates
    only. The list is already in category order, so each block keeps that
    order and no announcement appears twice in one block."""
    plan = {}
    for b in range(block_count):
        shown = [a for a in announcements if b == 0 or a["category"] in EVERY_BLOCK]
        for i in range(len(shown)):
            plan[b * PAGE_COUNT + ANNOUNCEMENT_SLOTS[i]] = shown[i]
    return plan

def place(units, reserved, blocks):
    """Lay pages into blocks * 8 slots. Reserved beats keep their slots;
    athletics fill the rest in order. A slot left over shows the school's
    identity page once per block, then reruns the athletics from the top,
    so no page is ever blank and nothing repeats while new content waits.
    Announcements are never rerun, so none appears twice in a block."""
    pages = []
    u = 0
    rerun = 0
    # Reruns cycle through the athletics with the identity page in the mix,
    # so a thin day alternates instead of repeating one page back to back.
    pool = units + [{"type": "identity"}]
    for b in range(blocks):
        identity_used = False
        for s in range(1, PAGE_COUNT + 1):
            slot = b * PAGE_COUNT + s
            if slot in reserved:
                pages.append(reserved[slot])
            elif u < len(units):
                pages.append(units[u])
                u += 1
            elif not identity_used:
                pages.append({"type": "identity"})
                identity_used = True
            else:
                pages.append(pool[rerun % len(pool)])
                rerun += 1
    return pages

def select_block(data, blocks, ctx):
    """Which 8-page block this render shows (0 = A, 1 = B).

    TEMPORARY V1 MECHANISM. GDN has no appearance counter, every page renders
    in its own process, and wall-clock buckets can split a block or lock onto
    a board's queue period. So the block comes from the cached /board
    response itself: every page of one render reads the same cached body
    (TTL_SECONDS < manifest refresh), so all 8 pages agree, and each fresh
    fetch's generated_at microseconds give an effectively random block, which
    can never lock Block B out (on average B is two appearances away).
    Replace with a backend-provided block index for strict A/B alternation;
    nothing else in the app needs to change."""
    if blocks <= 1:
        return 0
    stamp = get_str(data, "generated_at")
    dot = stamp.find(".")
    if dot >= 0:
        frac = ""
        for ch in stamp[dot + 1:].elems():
            if not ch.isdigit():
                break
            frac += ch
        if frac != "":
            return int(frac) % blocks
    if len(stamp) >= 19 and stamp[17:19].isdigit():
        return int(stamp[17:19]) % blocks
    # No usable stamp: last resort, and the only path with a block-split risk.
    return (ctx.now.unix // 60) % blocks

# =============================================================================
# Drawing
# =============================================================================

def drawable(c, text, font):
    """True when every character has a glyph in this font (the big fonts
    are missing some punctuation)."""
    for ch in text.elems():
        if ch != " " and c.text_width(ch, font) == 0:
            return False
    return True

def fit(c, ladder, maxw, fonts = FONTS):
    """First candidate that fits in the largest font; then the next font;
    then the last candidate hard-clipped with ".." in the smallest font.
    Returns [text, font]."""
    for font in fonts:
        for text in ladder:
            if drawable(c, text, font) and c.text_width(text, font) <= maxw:
                return [text, font]
    text = ladder[len(ladder) - 1]
    font = fonts[len(fonts) - 1]
    for i in range(len(text)):
        cut = text[:len(text) - i - 1].rstrip() + ".."
        if c.text_width(cut, font) <= maxw:
            return [cut, font]
    return ["", font]

def text_row(c, ladder, cx, y, maxw, color, fonts = FONTS, box = 7):
    """Centered fitted text in a `box`-pixel row. On the 7px card rows a
    smaller font sits on the same baseline; taller rows center it."""
    pick = fit(c, ladder, maxw, fonts)
    if pick[0] == "":
        return
    h = font_px(pick[1])
    dy = box - h if box == 7 else (box - h) // 2
    c.text(pick[0], cx, y + dy, font = pick[1], color = color, align = "center")

def font_px(font):
    return {"4x5": 5, "5x7": 7, "8x10": 10, "7x12": 12, "9x12": 12, "10x14": 14, "11x14": 14}.get(font, 7)

def part_width(c, p):
    w = c.text_width(p["t"], p["f"])
    return w + 4 if p["chip"] else w

BOTTOM_GAP = 4

def row_width(c, parts):
    total = BOTTOM_GAP * max(0, len(parts) - 1)
    for p in parts:
        total += part_width(c, p)
    return total

def pick_bottom(c, variants, maxw):
    """First variant that fits; else the last one with its clip part cut."""
    for v in variants:
        if row_width(c, v) <= maxw:
            return v
    last = variants[len(variants) - 1]
    out = []
    for p in last:
        if p["clip"]:
            room = maxw - (row_width(c, last) - part_width(c, p))
            q = dict(p)
            q["t"] = fit(c, [p["t"]], room)[0]
            out.append(q)
        else:
            out.append(p)
    return out

def draw_parts(c, parts, x, y):
    """A row of chips and text parts starting at x, on a 7px row at y."""
    for p in parts:
        if p["t"] == "":
            continue
        if p["chip"]:
            w = part_width(c, p)
            c.rect(x, y, x + w - 1, y + 6, fill = p["col"])
            c.text(p["t"], x + 2, y + 1, font = "4x5", color = "black")
        else:
            dy = 2 if p["f"] == "4x5" else 0
            c.text(p["t"], x, y + dy, font = p["f"], color = p["col"])
        x += part_width(c, p) + BOTTOM_GAP

def draw_bottom(c, variants, cx, maxw):
    """Bottom text row (y 22-28), centered as a group."""
    if len(variants) == 0:
        return
    parts = [p for p in pick_bottom(c, variants, maxw) if p["t"] != ""]
    draw_parts(c, parts, cx - row_width(c, parts) // 2, 22)

def draw_card(c, card, school, x0, w):
    # Sport icon in its own 24px slot at the left, the opponent logo at the
    # right, 1px in from the card edge; text between with 2px gaps. The
    # school is carried by the label color, the icon accents and the stripe
    # between cards, not by a logo on every card.
    c.sprite(ICON_ART[card["icon"]], x0 + 1, 2 + (LOGO - ICON) // 2, legend = school["legend"])
    if card["opp_logo"] != None:
        c.image(card["opp_logo"], x0 + w - LOGO - 1, 2, w = LOGO, h = LOGO)
    elif card["opp_trophy"]:
        draw_trophy(c, x0 + w - LOGO - 1, 2)
    tx0 = x0 + 1 + ICON + 2
    tw = w - (1 + ICON + 2) - (2 + LOGO + 1)
    cx = tx0 + tw // 2

    text_row(c, card["labels"], cx, 2, tw, school["brand"])
    if len(card["opponent"]) > 0:
        text_row(c, card["opponent"], cx, 12, tw, TEXT)
    draw_bottom(c, card["bottom"], cx, tw)

def draw_filler(c, school, x0, w, line):
    """An empty card slot: school identity, never a repeated or invented event."""
    c.image(school["logo"], x0 + 2, 2, w = LOGO, h = LOGO)
    tx0 = x0 + LOGO + 4
    tw = w - LOGO - 6
    cx = tx0 + tw // 2
    text_row(c, [school["name"], school["short"]], cx, 7, tw, school["brand"])
    if line != "":
        text_row(c, [line], cx, 17, tw, TEXT)

def draw_divider(c, x, color):
    """The helmet stripe: primary | white | white | primary, x..x+3."""
    c.vline(x, 1, 30, color = color)
    c.rect(x + 1, 1, x + 2, 30, fill = "white")
    c.vline(x + 3, 1, 30, color = color)

def draw_cards_page(c, page, school):
    w = CARD_W
    for s in range(CARDS_PER_PAGE):
        x0 = EDGE + s * (w + DIVIDER_GAP)
        if s < len(page["cards"]):
            draw_card(c, page["cards"][s], school, x0, w)
        else:
            draw_filler(c, school, x0, w, school["mascot"])
        if s > 0:
            draw_divider(c, x0 - DIVIDER_PAD - DIVIDER_W, school["stripe"])

def frame_lines(c, color):
    """Full-width pages: a rule along the top and bottom, running out to the
    color line of each side border (draw_edges) so the corners join."""
    x0 = EDGE - 3
    w = c.width - 2 * x0
    c.hline(x0, 0, w, color)
    c.hline(x0, 31, w, color)

def draw_featured(c, page, school):
    """Full width, three lines in priority order: the occasion (HOMECOMING)
    with FEATURED secondary, the matchup as the hero, then day and time.
    School logo left, opponent logo right of the matchup, ticket QR at the
    far right when the backend supplies one. The sport is left off: the
    occasion and the matchup already say what this is."""
    card = page["card"]
    event = card["event"]
    frame_lines(c, school["stripe"])

    right = c.width - EDGE
    qr = card["qr"]
    if qr != None:
        n = len(qr["rows"])
        qx = right - n - 2
        c.rect(qx - 2, 1, right - 1, 30, fill = "white")
        bits = [[1 if ch == "1" else 0 for ch in row.elems()] for row in qr["rows"]]
        c.bitmap(bits, qx, 2 + (28 - n) // 2, "black")
        label = qr["label"] if qr["label"] != "" else "TICKETS"
        lw = 36
        lx = qx - 4 - lw
        words = label.split(" ")
        if len(words) > 3:
            words = [label]
        top = 16 - (len(words) * 7 - 2) // 2
        for i in range(len(words)):
            text_row(c, [words[i]], lx + lw // 2, top + i * 7 - 1, lw, "white", ["4x5"])
        right = lx - 2

    c.image(school["logo"], EDGE + 1, 2, w = LOGO, h = LOGO)
    logo_x = right - LOGO - 1
    if card["opp_logo"] != None:
        c.image(card["opp_logo"], logo_x, 2, w = LOGO, h = LOGO)
    elif card["opp_trophy"]:
        draw_trophy(c, logo_x, 2)
    tx0 = EDGE + 1 + LOGO + 4
    tw = logo_x - 4 - tx0
    cx = tx0 + tw // 2

    # Line 1: a real occasion leads in the school color with a small gold
    # FEATURED after it; without one, FEATURED itself leads.
    occasion = featured_occasion(event)
    if occasion != "":
        opts = [
            [[occasion, "5x7", school["brand"]], ["FEATURED", "4x5", CHIP_FEATURED]],
            [[occasion, "5x7", school["brand"]]],
            [[occasion, "4x5", school["brand"]]],
        ]
    else:
        opts = [[["FEATURED", "5x7", CHIP_FEATURED]]]
    draw_dot_row(c, pick_dot_row(c, opts, tw), cx, 2)

    # Line 2: the matchup. Both names large with a small VS between them;
    # if that can't fit, the whole matchup as one line in the best font.
    opp = opponent_name(event)
    us = school["short"]
    ha = get_str(event, "home_away").upper()
    joint = "AT" if ha.startswith("A") else "VS"
    if not draw_matchup(c, us, joint, opp, cx, 10, tw):
        # Skip the one-letter "B V FOOTBALL" forms; the next font down is
        # better than a cryptic label in the hero font.
        labels = [l for l in card["labels"] if not has_initial(l)] or card["labels"]
        if opp == "":
            matchup = [us + " " + l for l in labels] + labels
        else:
            matchup = [us + " " + joint + " " + n for n in name_forms(opp)] + \
                      [joint + " " + n for n in name_forms(opp)]
        text_row(c, matchup, cx, 10, tw, TEXT, ["9x12", "5x7", "4x5"], 12)

    # Line 3: day and time only (TODAY in its chip color when it's today).
    dates = card["dates"] if card["kind"] != "today" else []
    clocks = card["clocks"]
    opts = []
    for d in (dates or [""]):
        for t in (clocks or [""]):
            row = []
            if card["kind"] == "today":
                row.append(["TODAY", "5x7", CHIP_TODAY])
            if d != "":
                row.append([d, "5x7", TEXT])
            if t != "":
                row.append([t, "5x7", TEXT])
            if len(row) > 0:
                opts.append(row)
    if len(opts) > 0:
        draw_dot_row(c, pick_dot_row(c, opts, tw), cx, 23)

def has_initial(label):
    for w in label.split(" "):
        if len(w) == 1:
            return True
    return False

DOT_GAP = 4

def dot_row_width(c, items):
    w = (len(items) - 1) * (2 * DOT_GAP + 2)
    for item in items:
        w += c.text_width(item[0], item[1])
    return w

def pick_dot_row(c, options, maxw):
    """First option that fits; else the last one."""
    for opt in options:
        if dot_row_width(c, opt) <= maxw:
            return opt
    return options[len(options) - 1]

def draw_dot_row(c, items, cx, y):
    """[text, font, color] items centered on a 7px row, split by small dots.
    Anything still too wide is clipped by fit() when drawn."""
    x = cx - dot_row_width(c, items) // 2
    for i in range(len(items)):
        t = items[i][0]
        f = items[i][1]
        c.text(t, x, y + (2 if f == "4x5" else 0), font = f, color = items[i][2])
        x += c.text_width(t, f)
        if i < len(items) - 1:
            c.rect(x + DOT_GAP, y + 3, x + DOT_GAP + 1, y + 4, fill = LABEL)
            x += 2 * DOT_GAP + 2

# Matchup fonts, largest first, all fitting the 12px hero row. Both schools
# step down through these before either name is dropped.
MATCHUP_FONTS = ["9x12", "7x12", "8x10", "5x7", "4x5"]

def draw_matchup(c, us, joint, opp, cx, y, maxw):
    """HARRISON vs RONCALLI: names in the largest font that fits both, a
    smaller VS between them, the opponent's shortest form first. Both
    schools are kept whenever they fit in any matchup font, so
    MCCUTCHEON AT TERRE HAUTE SOUTH VIGO steps down a font rather than
    losing MCCUTCHEON. Only if no font fits both does the school name go
    (its logo is on the left). Returns False, drawing nothing, when no form
    fits."""
    if opp == "":
        return False
    forms = name_forms(opp)
    shortest_first = [forms[len(forms) - 1 - i] for i in range(len(forms))]
    leads = [us, ""] if us != "" else [""]
    for u in leads:
        for font in MATCHUP_FONTS:
            if u != "" and not drawable(c, u, font):
                continue
            h = font_px(font)
            jfont = "5x7" if h >= 10 else "4x5"
            jw = c.text_width(joint, jfont)
            gap = 5 if h >= 10 else 3
            uw = c.text_width(u, font) + gap if u != "" else 0
            for n in shortest_first:
                if not drawable(c, n, font):
                    continue
                nw = c.text_width(n, font)
                total = uw + jw + gap + nw
                if total > maxw:
                    continue
                x = cx - total // 2
                ny = y + (12 - h) // 2
                if u != "":
                    c.text(u, x, ny, font = font, color = TEXT)
                c.text(joint, x + uw, ny + max(0, h - font_px(jfont) - 1), font = jfont, color = LABEL)
                c.text(n, x + uw + jw + gap, ny, font = font, color = TEXT)
                return True
    return False

def featured_occasion(event):
    """The event title when it names an occasion (HOMECOMING, SENIOR NIGHT),
    not just the opponent again ("ROSSVILLE", "KOKOMO HIGH SCHOOL")."""
    title = panel_text(get_str(event, "title"))
    if title == "":
        return ""
    opp = opponent_name(event)
    if opp != "":
        opp_forms = name_forms(opp)
        for t in name_forms(title):
            if t in opp_forms or t == "VS " + opp or t == "AT " + opp:
                return ""
    return title

def sponsor_labels(school):
    """The identifier over SPONSOR: the singular mascot (RAIDERS -> RAIDER),
    then the school's short name when there is no mascot or it won't fit."""
    mascot = school["mascot"]
    if mascot.endswith("S") and not mascot.endswith("SS"):
        mascot = mascot[:len(mascot) - 1]
    return [l for l in [mascot, school["short"]] if l != ""] or ["SCHOOL"]

def draw_sponsor(c, page, school):
    """School logo and "<MASCOT> SPONSOR" at the far left, the school
    stripe, the sponsor's logo when the app bundles one, then the business
    name centered in the space left with the web address beneath it. With no
    web address the name gets the full height."""
    frame_lines(c, school["stripe"])
    x = EDGE + 2
    c.image(school["logo"], x, 2, w = LOGO, h = LOGO)
    label_x = x + LOGO + 3
    lcx = label_x + SPONSOR_LABEL_W // 2
    labels = page.get("label") or sponsor_labels(school)
    text_row(c, labels, lcx, 9, SPONSOR_LABEL_W, school["brand"], ["4x5"], 5)
    text_row(c, ["SPONSOR"], lcx, 17, SPONSOR_LABEL_W, LABEL, ["4x5"], 5)
    dx = label_x + SPONSOR_LABEL_W + 3
    draw_divider(c, dx, school["stripe"])

    ax0 = dx + DIVIDER_W + 6
    logo = page.get("logo")
    if logo != None:
        c.image(logo[0], ax0, 2 + (28 - SPONSOR_LOGO_H) // 2)
        ax0 += logo[1] + 8
    aw = c.width - EDGE - 6 - ax0
    cx = ax0 + aw // 2
    for line in sponsor_name_layout(c, page["name"], aw, page["site"] != ""):
        c.text(line[0], cx, line[2], font = line[1], color = TEXT, align = "center")
    if page["site"] != "":
        text_row(c, [page["site"]], cx, 21, aw, school["brand"], ["5x7", "4x5"])

def balanced_split(c, name, font, room):
    """The name as two lines in `font`, as even as possible, or None."""
    if not drawable(c, name, font):
        return None
    words = name.split(" ")
    best = None
    for i in range(1, len(words)):
        a = " ".join(words[:i])
        b = " ".join(words[i:])
        if max(c.text_width(a, font), c.text_width(b, font)) <= room:
            score = abs(len(a) - len(b))
            if best == None or score < best[0]:
                best = [score, a, b]
    return None if best == None else [best[1], best[2]]

def sponsor_name_layout(c, name, room, has_site):
    """The business name as large as it reads, as [text, font, y] lines.
    Above a web address (rows 2-17): one 9x12 line, two 5x7 lines, then one
    fitted line. On its own (rows 2-29): one 10x14 line, one 9x12 line, two
    9x12 lines, then one fitted line. A last-resort line is clipped with
    ".." rather than run off the page."""
    def fits(font):
        return drawable(c, name, font) and c.text_width(name, font) <= room
    if has_site:
        if fits("9x12"):
            return [[name, "9x12", 4]]
        two = balanced_split(c, name, "5x7", room)
        if two != None:
            return [[two[0], "5x7", 2], [two[1], "5x7", 11]]
        pick = fit(c, [name], room)
        return [[pick[0], pick[1], 7]]
    for font in ["10x14", "9x12"]:
        if fits(font):
            return [[name, font, 2 + (28 - font_px(font)) // 2]]
    two = balanced_split(c, name, "9x12", room)
    if two != None:
        return [[two[0], "9x12", 3], [two[1], "9x12", 17]]
    two = balanced_split(c, name, "5x7", room)
    if two != None:
        return [[two[0], "5x7", 7], [two[1], "5x7", 18]]
    pick = fit(c, [name], room)
    return [[pick[0], pick[1], 2 + (28 - font_px(pick[1])) // 2]]

def announcement_style(category, school):
    """Accent, icon and colors per category. ALERT keeps the original urgent
    page exactly (red rules and chip, white headline, amber message)."""
    if category == "alert":
        return {"accent": URGENT_RED, "chip_text": "white", "hero": URGENT_AMBER,
                "art": ALERT_ART, "legend": {"R": URGENT_RED, "W": "white"}}
    if category == "schedule":
        return {"accent": URGENT_AMBER, "chip_text": "black", "hero": URGENT_AMBER,
                "art": CALENDAR_ART, "legend": dict(ICON_COLORS, a = URGENT_AMBER)}
    if category == "celebration":
        return {"accent": CELEBRATION_GOLD, "chip_text": "black", "hero": CELEBRATION_GOLD,
                "art": ICON_ART["trophy"], "legend": TROPHY_LEGEND}
    brand = school["brand"]
    return {"accent": brand, "chip_text": "black" if brightness(brand) >= 140 else "white",
            "hero": brand, "art": MEGAPHONE_ART, "legend": school["legend"]}

def draw_announcement(c, page, school):
    """Full width: the category's icon at both ends, its header chip, then
    the headline (white) and the message as the hero in the accent color."""
    style = announcement_style(page["category"], school)
    accent = style["accent"]
    frame_lines(c, accent)
    art = style["art"]
    y = (32 - len(art)) // 2
    for x in [EDGE + 2, c.width - EDGE - 2 - ICON]:
        c.sprite(art, x, y, legend = style["legend"])
    cx = c.width // 2
    tw = c.width - 2 * (EDGE + 2 + ICON + 6)
    head = page["header"]
    hw = c.text_width(head, "4x5") + 6
    c.rect(cx - hw // 2, 2, cx - hw // 2 + hw - 1, 8, fill = accent)
    c.text(head, cx - hw // 2 + 3, 3, font = "4x5", color = style["chip_text"])
    lines = [l for l in [page["headline"], page["message"]] if l != ""]
    if len(lines) == 1:
        text_row(c, [lines[0]], cx, 13, tw, style["hero"], ["9x12", "5x7", "4x5"], 12)
        return
    text_row(c, [lines[0]], cx, 10, tw, TEXT, ["5x7", "4x5"])
    text_row(c, [lines[1]], cx, 18, tw, style["hero"], ["9x12", "5x7", "4x5"], 12)

def draw_identity(c, school, line):
    """School identity: shown once in a block that runs out of new content,
    and as the empty state."""
    frame_lines(c, school["stripe"])
    c.image(school["logo"], EDGE + 1, 2, w = LOGO, h = LOGO)
    c.image(school["logo"], c.width - EDGE - 1 - LOGO, 2, w = LOGO, h = LOGO)
    cx = c.width // 2
    tw = c.width - 2 * (EDGE + LOGO + 8)
    text_row(c, [school["name"], school["short"]], cx, 3, tw, school["brand"], ["9x12", "5x7"], 12)
    text_row(c, [line] if line != "" else ["ATHLETICS"], cx, 19, tw, TEXT, ["5x7", "4x5"], 9)

def draw_message(c, head, sub):
    """Full-width state card: SportBoards mark, a what, and a what-to-do."""
    c.image(FALLBACK_LOGO, EDGE, 2, w = LOGO, h = LOGO)
    tx0 = EDGE + LOGO + 4
    tw = c.width - EDGE - tx0
    cx = tx0 + tw // 2
    text_row(c, [head], cx, 6, tw, ERROR_HEAD)
    text_row(c, [sub], cx, 18, tw, LABEL)

STATE_COPY = {
    "NOKEY": ["SPORTBOARDS", "ADD YOUR ACCESS CODE IN THE APP SETTINGS"],
    "AUTH": ["ACCESS CODE NOT RECOGNIZED", "CHECK THE CODE OR CONTACT SPORTBOARDS"],
    "INACTIVE": ["SUBSCRIPTION INACTIVE", "CONTACT SPORTBOARDS"],
    "DOWN": ["SCHEDULE UNAVAILABLE", "TRYING AGAIN SHORTLY"],
    "BAD": ["SCHEDULE DATA ERROR", "TRYING AGAIN SHORTLY"],
}

def render_page(c, ctx, page_index):
    c.fill("black")

    board = fetch_board(ctx)
    if board["state"] == "NOKEY":
        draw_demo(c, ctx, page_index)
        return
    if board["state"] != "OK":
        copy = STATE_COPY[board["state"]]
        draw_message(c, copy[0], copy[1])
        return

    data = board["data"]
    school = school_info(data)
    zone = get_str(get_dict(data, "school"), "timezone")
    feed = build_feed(data, zone)
    block = select_block(data, feed["blocks"], ctx)
    draw_feed_page(c, feed["pages"][block * PAGE_COUNT + page_index], school, data, feed)

def draw_feed_page(c, page, school, data, feed):
    kind = page["type"]
    if kind == "cards":
        draw_cards_page(c, page, school)
    elif kind == "sponsor":
        draw_sponsor(c, page, school)
    elif kind == "featured":
        draw_featured(c, page, school)
    elif kind == "announcement":
        draw_announcement(c, page, school)
    else:
        any_on = len(sections_on(data)) > 0
        empty = feed_is_empty(feed)
        draw_identity(c, school, "NO EVENTS TO SHOW" if empty and any_on else school["mascot"])
    draw_edges(c, school["stripe"])

def draw_edges(c, color):
    """The page's outer borders, matching the stripe between cards: white |
    school color at the left, school color | white at the right, each 2px
    outside the content, on every page type."""
    c.vline(EDGE - 4, 1, 30, color = "white")
    c.vline(EDGE - 3, 1, 30, color = color)
    c.vline(c.width - EDGE + 2, 1, 30, color = color)
    c.vline(c.width - EDGE + 3, 1, 30, color = "white")

def feed_is_empty(feed):
    for p in feed["pages"]:
        if p["type"] != "identity":
            return False
    return True

# =============================================================================
# Demo mode: no access code yet. Sample data for a fictional school, labelled
# DEMO on every page, built here (no request is made), shown through the same
# feed and page renderers as a real board.
# =============================================================================

DEMO_ZONE = "America/Indiana/Indianapolis"

def civil_from_days(z):
    """Days since 1970-01-01 -> "YYYY-MM-DD" (inverse of days_from_civil)."""
    z += 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y += 1
    return str(y) + "-" + ("0" if m < 10 else "") + str(m) + "-" + ("0" if d < 10 else "") + str(d)

def demo_stamp(utc_min):
    day = utc_min // 1440
    mins = utc_min % 1440
    hh = mins // 60
    mm = mins % 60
    return civil_from_days(day) + "T" + ("0" if hh < 10 else "") + str(hh) + ":" + ("0" if mm < 10 else "") + str(mm) + ":00+00:00"

def demo_event(i, day_offset, hour, sport, gender, level, opp, slug, ha, today_day, shift, result = None, title = ""):
    local = (today_day + day_offset) * 1440 + hour * 60
    e = {
        "id": 9000 + i, "sport": sport, "gender": gender, "level": level,
        "opponent": opp, "title": title if title != "" else opp,
        "event_date": civil_from_days(today_day + day_offset),
        "starts_at": demo_stamp(local - shift), "home_away": ha,
        "status": "scheduled", "is_featured": False,
        "opponent_details": {"matched": True, "slug": slug, "name": opp},
    }
    if result != None:
        e["status"] = "completed"
        e["outcome"] = result[0]
        e["school_score"] = result[1]
        e["opponent_score"] = result[2]
    return e

def demo_board(ctx):
    now_min = ctx.now.unix // 60
    local = local_minutes(now_min, DEMO_ZONE)
    shift = local - now_min
    today = local // 1440
    def ev(i, day_offset, hour, sport, gender, level, opp, slug, ha, result = None, title = ""):
        return demo_event(i, day_offset, hour, sport, gender, level, opp, slug, ha,
                          today, shift, result = result, title = title)

    homecoming = ev(1, 3, 19, "Football", "Boys", "Varsity", "Logansport", "logansport", "home", title = "Homecoming")
    homecoming["is_featured"] = True
    return {
        "generated_at": demo_stamp(now_min),
        "local_date": civil_from_days(today),
        "school": {"slug": "sportboards-demo", "name": "Demo High School", "mascot": "Demo",
                   "timezone": DEMO_ZONE, "primary_color": "#2E7DFF", "secondary_color": "#F5B700"},
        "settings": {},
        "results": [
            ev(2, -1, 19, "Football", "Boys", "Varsity", "Lafayette Jefferson", "lafayette-jefferson", "home", result = ["win", "35", "14"]),
            ev(3, -2, 18, "Volleyball", "Girls", "Varsity", "Kokomo", "kokomo", "away", result = ["win", "3", "1"]),
            ev(4, -2, 17, "Soccer", "Girls", "Varsity", "West Lafayette", "west-lafayette", "away", result = ["win", "2", "0"]),
            ev(5, -3, 17, "Soccer", "Boys", "Varsity", "Carmel", "carmel", "home", result = ["loss", "1", "2"]),
        ],
        "today": [
            ev(6, 0, 18, "Volleyball", "Girls", "Varsity", "McCutcheon", "mccutcheon", "home"),
            ev(7, 0, 17, "Cross Country", "Boys", "", "Frankfort", "frankfort", "away"),
        ],
        "upcoming": [
            ev(8, 1, 17, "Tennis", "Boys", "Varsity", "Lebanon", "lebanon", "home"),
            ev(9, 2, 18, "Soccer", "Girls", "Varsity", "Crawfordsville", "crawfordsville", "away"),
            ev(10, 4, 18, "Volleyball", "Girls", "JV", "Frontier", "frontier", "home"),
            ev(11, 5, 10, "Cross Country", "Girls", "", "Benton Central", "benton-central", "away"),
            homecoming,
        ],
        "featured": [homecoming],
        "announcements": [],
        "sponsors": [{"id": 1, "name": "Huston Electric", "slug": "huston-electric"}],
    }

DEMO_LETTERS = ["D", "E", "M", "O"]

def draw_demo(c, ctx, page_index):
    if page_index == 0:
        c.image(FALLBACK_LOGO, EDGE + 2, 2, w = LOGO, h = LOGO)
        cx = (EDGE + 2 + LOGO + c.width - EDGE) // 2
        tw = c.width - 2 * EDGE - LOGO - 8
        text_row(c, ["SPORTBOARDS DEMO"], cx, 2, tw, CHIP_FEATURED, ["9x12", "5x7"], 12)
        text_row(c, ["SAMPLE SCHOOL AND SAMPLE GAMES, NOT LIVE"], cx, 15, tw, TEXT, ["5x7", "4x5"])
        text_row(c, ["ADD YOUR ACCESS CODE IN THE APP SETTINGS"], cx, 24, tw, LABEL, ["4x5"], 5)
    else:
        data = demo_board(ctx)
        school = school_info(data)
        feed = build_feed(data, DEMO_ZONE)
        # After the splash, the feed's own pages in order (its filler
        # identity page skipped), cycling if the sample ever runs short.
        pages = [pg for pg in feed["pages"] if pg["type"] != "identity"] or feed["pages"]
        page = pages[(page_index - 1) % len(pages)]
        if page["type"] == "sponsor":
            page = dict(page)
            page["label"] = ["SAMPLE"]
        draw_feed_page(c, page, school, data, feed)
        # The DEMO letters take the left margin, so the left border gives way.
        c.rect(0, 0, EDGE - 1, 31, fill = "black")
    # DEMO, stacked in the left margin of every page.
    for i in range(len(DEMO_LETTERS)):
        c.text(DEMO_LETTERS[i], 1, 4 + i * 6, font = "4x5", color = CHIP_FEATURED)

def page1(c, ctx):
    render_page(c, ctx, 0)

def page2(c, ctx):
    render_page(c, ctx, 1)

def page3(c, ctx):
    render_page(c, ctx, 2)

def page4(c, ctx):
    render_page(c, ctx, 3)

def page5(c, ctx):
    render_page(c, ctx, 4)

def page6(c, ctx):
    render_page(c, ctx, 5)

def page7(c, ctx):
    render_page(c, ctx, 6)

def page8(c, ctx):
    render_page(c, ctx, 7)

# Small pixel art for the full-width pages (same legend scheme as ICON_ART).
# Announcement icons (24x24, same legend scheme as the sport icons).
# Megaphone: school colors (A, C) through the school's icon legend.
MEGAPHONE_ART = [
    "........................",
    "........................",
    "........................",
    ".................W......",
    "................AW......",
    "..............AAAW......",
    "............AAAAAW......",
    "...........AAAAAAW...W..",
    ".........AAAAAAAAW....W.",
    ".......AAAAAAAAAAW.W..WW",
    "..WWWWAAAAAAAAAAAW..W..W",
    "..WWWWAAAAAAAAAAAW..W..W",
    "..WWWWAAAAAAAAAAAW..W..W",
    "..WWWWAAAAAAAAAAAW..W..W",
    ".......CwwAAAAAAAW.W..WW",
    "........wwCAAAAAAW....W.",
    "........ww.CAAAAAW...W..",
    "........ww..CCAAAW......",
    "........ww....CCAW......",
    "................AW......",
    ".................W......",
    "........................",
    "........................",
    "........................",
]

# Calendar page with a clock badge: "a" is the schedule amber.
CALENDAR_ART = [
    "........................",
    ".....w........w.........",
    ".....w........w.........",
    ".aaaawaaaaaaaawaaaa.....",
    ".aaaawaaaaaaaawaaaa.....",
    ".aaaaaaaaaaaaaaaaaa.....",
    ".aaaaaaaaaaaaaaaaaa.....",
    ".WWWWWWWWWWWWWWWWWW.....",
    ".WWWWWWWWWWWWWWWWWW.....",
    ".WWWWWWWWWWWWWWWWWW.....",
    ".WWddWddWddWddWddWW.....",
    ".WWWWWWWWWWWWWWWWWW.....",
    ".WWWWWWWWWWWWWWaaaaaa...",
    ".WWddWddWddWdaaaaWWaaaa.",
    ".WWWWWWWWWWWWaaWWkWWWaa.",
    ".WWWWWWWWWWWaaWWWkWWWWaa",
    ".WWddWddWddWaaWWWkWWWWaa",
    ".WWWWWWWWWWWaWWWWkWWWWWa",
    ".WWWWWWWWWWWaWWWWkkkkWWa",
    ".WWWWWWWWWWWaaWWWWWWWWaa",
    ".WWWWWWWWWWWaaWWWWWWWWaa",
    ".............aaWWWWWWaa.",
    ".............aaaaWWaaaa.",
    "...............aaaaaa...",
]

# The trophy (ICON_ART["trophy"]) in fixed gold with a white band: the
# CELEBRATION icon and the tournament fallback, the same on every board.
TROPHY_LEGEND = dict(ICON_COLORS, A = "#FFFFFF", C = "#FFE08A")

ALERT_ART = [
    "...........RR...........",
    "..........RRRR..........",
    "..........RRRR..........",
    ".........RRRRRR.........",
    ".........RRRRRR.........",
    "........RRRWWRRR........",
    "........RRRWWRRR........",
    ".......RRRRWWRRRR.......",
    ".......RRRRWWRRRR.......",
    "......RRRRRWWRRRRR......",
    "......RRRRRWWRRRRR......",
    ".....RRRRRRWWRRRRRR.....",
    ".....RRRRRRWWRRRRRR.....",
    "....RRRRRRRWWRRRRRRR....",
    "....RRRRRRRRRRRRRRRR....",
    "...RRRRRRRRRRRRRRRRRR...",
    "...RRRRRRRRWWRRRRRRRR...",
    "..RRRRRRRRRWWRRRRRRRRR..",
    "..RRRRRRRRRRRRRRRRRRRR..",
    ".RRRRRRRRRRRRRRRRRRRRRR.",
]

# =============================================================================
# Sport icon art: 24x24, one character per pixel. "." is empty; every other
# character is a key in icon_legend(). Original SportBoards artwork.
# =============================================================================

ICON_ART = {
    "football": [
        "........................",
        "........................",
        "........................",
        "........................",
        "........................",
        ".......BBBBBBBBBB.......",
        ".....ABBBBBBBBBBBBA.....",
        "...BWABBBWBWBWBBBBAWB...",
        "..BBWABBWWWWWWWWBBAWBB..",
        ".BBBWABBBWBWBWBBBBAWBBB.",
        ".BBBWABBBBBBBBBBBBAWBBB.",
        "bBBBWABBBBBBBBBBBBAWBBBb",
        "bBBBWABBBBBBBBBBBBAWBBBb",
        "bBBBWABBBBBBBBBBBBAWBBBb",
        ".bBBWABBBBBBBBBBBBAWBBb.",
        ".bbBWABBBBBBBBBBBBAWBbb.",
        "..bbWABBBBBBBBBBBBAWbb..",
        "...bWAbBBBBBBBBBBbAWb...",
        ".....AbbbbbbbbbbbbA.....",
        ".......bbbbbbbbbb.......",
        "........................",
        "........................",
        "........................",
        "........................",
    ],
    "flag_football": [
        "........................",
        ".........BBBBBBBB.......",
        "......WABBWBWBWBBBAW....",
        "....BBWABWWWWWWWWBAWBB..",
        "...BBBWABBWBWBWBBBAWBBB.",
        "...BBBWABBBBBBBBBBAWBBB.",
        "...BBBWABBBBBBBBBBAWBBB.",
        "...bBBWABBBBBBBBBBAWBBb.",
        "...bbBWABBBBBBBBBBAWBbb.",
        "...bbbWABBBBBBBBBBAWbbb.",
        "....bbWAbBBBBBBBBbAWbb..",
        "......WAbbbbbbbbbbAW....",
        ".........bbbbbbbb.......",
        "........................",
        "....WWWWWWWWWWWWWWWW....",
        "....WWWWWWWWWWWWWWWW....",
        ".....AAAA......AAAA.....",
        "....AAAA......AAAA......",
        "...AAAA......AAAA.......",
        "...AAAA......AAAA.......",
        "..AAAA......AAAA........",
        ".AAAA......AAAA.........",
        ".AAAA......AAAA.........",
        "AAAA......AAAA..........",
    ],
    "volleyball": [
        "........................",
        "........wwwwwwww........",
        "......wwkkkWWkkWww......",
        "....wwkWWkkWWWkkWWww....",
        "...wwWWWWWkWWWWkWWWww...",
        "...wWWWWkkkkWWWWkWWWw...",
        "..wWWWkkAAAkWWWWkWWWWw..",
        "..wWkkAAAAAkWWWWWkWWWw..",
        ".wWkAAAAAAAAkWWWWkWWWWw.",
        ".wkAAAAAAAAAkWWWWkWWWWw.",
        ".wAAAAAAAAAkkkWWWkWWWWw.",
        ".wAAAAAAAkkWWkWWWWWWWWw.",
        ".wAAAAAAkkWWWkWWWWkWWWw.",
        ".wAAAAAkkWWWWWkWWWkWWWw.",
        ".wAAAkkWWWWWWkkkkkkkkkw.",
        ".wAAkkWWWWWWkkWWWWWWWWw.",
        "..wkkWWWWWWkkWWWWWWWWw..",
        "..wkWWWWWWkkkWWWWWWWWw..",
        "...wWWWWWkCCCkkkWWWWw...",
        "...wwWWkkCCCCCCCkkkww...",
        "....wwkkkCCCCCCCCCww....",
        "......wwWkkCCCCCww......",
        "........wwwwwwww........",
        "........................",
    ],
    "soccer": [
        "..........AAAA..........",
        ".......AAAAkkAAAA.......",
        ".....AAWWkkkkkkWWAA.....",
        "....AAWWWWkkkkWWWWAA....",
        "...AAWWWWWWWWWWWWWWAA...",
        "..AAWWWWWWWWWWWWWWWWAA..",
        "..AkWWWWWWWWWWWWWWWWkA..",
        ".AkkWWWWWWWWWWWWWWWWkkA.",
        ".AkkkWWWWWWkkWWWWWWkkkA.",
        ".AkkkWWWWWkkkkWWWWWkkkA.",
        "AAkkWWWWkkkkkkkkWWWWkkAA",
        "AkkWWWWWkkkkkkkkWWWWWkkA",
        "AWWWWWWWWkkkkkkWWWWWWwwA",
        "AAWWWWWWWkkkkkkWWWWWWwAA",
        ".AWWWWWWWkkkkkkWWWWWWwA.",
        ".AWWWWWWWWWWWWWWWWWWWwA.",
        ".AWWWWWWWWWWWWWWWWWWwwA.",
        "..AWWWWWWWWWWWWWWWWWwA..",
        "..AAkkkkWWWWWWWWkkkkAA..",
        "...AAkkkWWWWWWWWkkkAA...",
        "....AAkkkWWWWWWkkkAA....",
        ".....AAkkwwwwwwkkAA.....",
        ".......AAAAwwAAAA.......",
        "..........AAAA..........",
    ],
    "tennis": [
        "........................",
        ".........AAA.......YY...",
        ".......AAAAAAAA..YYYYWY.",
        ".....AAAAkwkwAAA.YYYWWY.",
        "....AAAwwwwwwwAAYYYYWYYY",
        "...AAAwkwkwkwkwAYYYYWYYY",
        "...AAwwwwwwwwwwwAYYYWWY.",
        "..AAwkwkwkwkwkwkAYYYYWY.",
        "..AAwwwwwwwwwwwwAA.YY...",
        ".AAkwkwkwkwkwkwkAA......",
        ".AAwwwwwwwwwwwwAA.......",
        ".AAkwkwkwkwkwkwAA.......",
        "..AwwwwwwwwwwwAA........",
        "..AAwkwkwkwkwAAA........",
        "..AAAwwwwwwwAAA.A.......",
        "...AAAwkwkAAAA.AA.......",
        "....AAAAAAAA..AAAA......",
        ".......AAA......AWW.....",
        ".................WCW....",
        "..................WCW...",
        "...................WCW..",
        "....................WCW.",
        ".....................WW.",
        "........................",
    ],
    "cross_country": [
        "........................",
        "........................",
        "........................",
        ".......AAAA.............",
        "......AAAAAA............",
        "......AWAWAAA...........",
        ".....AAAWAWAAA..........",
        ".....AAAAWAWAAAA........",
        "...WAAAAAAAAAAAAAA......",
        "..WWAAAAAAAAAAAAAAAA....",
        "..WWAACCCCCCCAAAAAAAAA..",
        "..WAACCCCCCCCCCAAAAAAAA.",
        "..AAAAAAAAAAAAAAAAAAAAAA",
        ".wwwwwwwwwwwwwwwwwwwwwww",
        "..d.dd.dd.dd.dd.dd.dd.d.",
        "........................",
        "........................",
        "........................",
        "........................",
        "........................",
        "............GGGGGGG.....",
        "GG.......GGGGGGGGGGGGG..",
        "GGGGGGGGGGGGGGGGGGGGGGGG",
        "gggggggggggggggggggggggg",
    ],
    "basketball": [
        "........................",
        "........................",
        ".........OOOOkOOOO......",
        "........OOOOOkOOOOO.....",
        "......kkOOOOOkOOOOOkk...",
        ".....OOkkOOOOkOOOOkkOo..",
        "AAA..OOOkkOOOkOOOkkOOo..",
        "....OOOOOkOOOkOOOkOOOOo.",
        "....OOOOOkOOOkOOOkOOOOo.",
        "...OOOOOOOkOOkOOkOOOOOoo",
        "...OOOOOOOkOOkOOkOOOOOoo",
        "AA.kkkkkkkkkkkkkkkkkkkkk",
        "...OOOOOOOkOOkOOkOOOOOoo",
        "...OOOOOOOkOOkOOkOOOOOoo",
        "...OOOOOOOkOOkOOkOOOOooo",
        "....OOOOOkOOOkOOOkOOOoo.",
        "AAA.OOOOOkOOOkOOOkOOooo.",
        ".....OOOkkOOOkOOOkkooo..",
        ".....oOkkOOOOkOOOOkkoo..",
        "......kkOOOOOkOOOookk...",
        "........oooOOkooooo.....",
        ".........ooookoooo......",
        "........................",
        "........................",
    ],
    "baseball": [
        "........................",
        "........AAAAAAAA........",
        "......AAWWWWWWWWAA......",
        ".....AWWWWWWWWWWWWA.....",
        "...AAWRWWWWWWWWWWRWAA...",
        "...AWRWWWWWWWWWWWWRWA...",
        "..AWWRRWWWWWWWWWWRRWWA..",
        "..AWWRRWRWWWWWWRWRRWWA..",
        ".AWWWWRWWWWWWWWWWRWWWWA.",
        ".AWWWWRRWWWWWWWWRRWWWWA.",
        ".AWWWWWRWWWWWWWWRWWWWWA.",
        ".AWWWRWRRWWWWWWRRWRWWWA.",
        ".AWWWWWRWWWWWWWWRWWWWWA.",
        ".AWWWWWRWWWWWWWWRWWWWWA.",
        ".AWWWWRRWWWWWWWWRRWWWwA.",
        ".AWWWRRWRWWWWWWRWRRWWwA.",
        "..AWWWRWWWWWWWWWWRWWwA..",
        "..ARWRRWWWWWWWWWWRRWRA..",
        "...AWRWWWWWWWWWWWWRwA...",
        "....AWWWWWWWWWWWWWwA....",
        ".....AWWWWWWWWWWwwA.....",
        "......AAWWWWWWwwAA......",
        "........AAAAAAAA........",
        "........................",
    ],
    "softball": [
        "........................",
        "........AAAAAAAA........",
        "......AAyyyyyyyyAA......",
        ".....AyyyyyyyyyyyyA.....",
        "...AAyRyyyyyyyyyyRyAA...",
        "...AyRyyyyyyyyyyyyRyA...",
        "..AyyRRyyyyyyyyyyRRyyA..",
        "..AyyRRyRyyyyyyRyRRyyA..",
        ".AyyyyRyyyyyyyyyyRyyyyA.",
        ".AyyyyRRyyyyyyyyRRyyyyA.",
        ".AyyyyyRyyyyyyyyRyyyyyA.",
        ".AyyyRyRRyyyyyyRRyRyyyA.",
        ".AyyyyyRyyyyyyyyRyyyyyA.",
        ".AyyyyyRyyyyyyyyRyyyyyA.",
        ".AyyyyRRyyyyyyyyRRyyyNA.",
        ".AyyyRRyRyyyyyyRyRRyyNA.",
        "..AyyyRyyyyyyyyyyRyyNA..",
        "..ARyRRyyyyyyyyyyRRyRA..",
        "...AyRyyyyyyyyyyyyRNA...",
        "....AyyyyyyyyyyyyyNA....",
        ".....AyyyyyyyyyyNNA.....",
        "......AAyyyyyyNNAA......",
        "........AAAAAAAA........",
        "........................",
    ],
    "golf": [
        "........................",
        "...........AAAA.........",
        ".........WWAAAAAAA......",
        ".........WWACCCAAAAA....",
        ".........WWACCCAAAAAAA..",
        ".........WWAAAAAAAAA....",
        ".........WWAAAAAAA......",
        ".........WWAAAA.........",
        ".........WW.............",
        ".........WW.............",
        ".........WW.............",
        ".........WW.............",
        ".........WW.............",
        ".........WW.............",
        ".........WW.............",
        ".........WW.....WWW.....",
        ".........WW....WWWWW....",
        ".........WW....WWWwW....",
        "....GGGGGWWGGGGGWwWG....",
        "..GGGGGGGWWGGGGGGGGGGG..",
        ".GGGGGGGkkkkGGGGGGGGGGG.",
        ".GGGGGGGGGGGGGGGGGGGGGG.",
        "..gggggggggggggggggggg..",
        "....gggggggggggggggg....",
    ],
    "swimming": [
        "........................",
        "........................",
        "........................",
        ".................WWW....",
        "..............WWWWWW....",
        "............WWWWWW......",
        "............WWW.........",
        "...........WWW..........",
        "......AAA..WW...........",
        ".....AAAAA.WW...........",
        ".....AAACW.WW...........",
        ".....AAAAAWWW.....WWWWW.",
        "......AAA.WWWWWWWWWWWWW.",
        "...uuu...WWWuuuWWWWWuuu.",
        "..uuuuuu.WWuuuuu...uuuuu",
        "uUUU..uuuUUU...uuUUU...u",
        "UUUUU...UUUUU...UUUUUU..",
        "UUUUUUUUUUUUUUUUUUUUUUUU",
        "UUUUUUUUUUUUUUUUUUUUUUUU",
        "UUUUUUUUUUUUUUUUUUUUUUUU",
        "uUUUUuUUUUuUUUUuUUUUuUUU",
        "UUUUuUUUUuUUUUuUUUUuUUUU",
        "UUUuUUUUuUUUUuUUUUuUUUUu",
        "UUuUUUUuUUUUuUUUUuUUUUuU",
    ],
    "wrestling": [
        "........................",
        "........................",
        ".......WWW.....WWW......",
        "......WWWWW...WWWWW.....",
        "......WWWWW...WWWWW.....",
        ".......WWW.....WWW......",
        "........................",
        ".....AAAAA....EEEEE.....",
        ".....WWAAWWWWWWWEEWW....",
        "....WWWAAWWWWWWWEEWWW...",
        "....WWWAAA....EEEEWWW...",
        "...WWWAAAA....EEEEEWWW..",
        "...WWWAAAA....EEEEEWWW..",
        "...WWAAAAA....EEEEE.WW..",
        "......WWWW.....WWWW.....",
        ".....WWWWW.....WWWWW....",
        ".....WWWWWW...WWWWWW....",
        "....WWW..WW...WW..WWW...",
        "....WWW..WW...WW..WWW...",
        "...WWW...WWW.WWW...WWW..",
        "...WWW....WW.WW....WWW..",
        "..AAAAAAkkkkkkkkAAAAAA..",
        ".AAkkkkkkkkkkkkkkkkkkAA.",
        "........................",
    ],
    "track": [
        "........................",
        "..............WWWW......",
        "..............WWWW......",
        "..............WWWW......",
        "..............WWWW......",
        ".............AAAA....WW.",
        "...........WAAAAA...WWW.",
        "........WWWWAAAAAWWWWW..",
        ".......WWWWAAAAAAWWWWW..",
        ".......WW..AAAAA..WWW...",
        "......WWW.AAAAAA........",
        "......WW.EEEEEA.........",
        ".........EEEEEA.........",
        "..........AAAA..........",
        ".........WWWWWWWW.......",
        "........WWW.WWWWWW......",
        "...WWWWWWW.....WWW......",
        "...WWWWWW......WWW......",
        "...............WW.......",
        "...............WW.......",
        "TTTTTTTTTTTTTTTTTTTTTTTT",
        "WWWWWWWWWWWWWWWWWWWWWWWW",
        "TTTTTTTTTTTTTTTTTTTTTTTT",
        "WTTTWTTTWTTTWTTTWTTTWTTT",
    ],
    "cheer": [
        "........................",
        "........................",
        "...............AWW......",
        "..............AAWW......",
        "............AAAAWW......",
        "..........AAAAAAWW......",
        ".........AAAAAAAWW......",
        ".......CCAAAAAAAWW....W.",
        ".....AACCAAAAAAAWW....W.",
        "wwwAAAACCAAAAAAAWW.W....",
        "wwwAAAACCAAAAAAAWW..W...",
        "wwwAAAACCAAAAAAAWW..W.W.",
        "wwwAAAACCAAAAAAAWW..W.W.",
        "wwwAAAACCAAAAAAAWW.W....",
        "wwwAAAACCAAAAAAAWW....W.",
        ".....AACCAAAAAAAWW......",
        ".......CCAAAAAAAWW....W.",
        ".........wwAAAAAWW......",
        ".........wwAAAAAWW......",
        ".........ww.AAAAWW......",
        ".........ww...AAWW......",
        ".........ww....AWW......",
        ".........ww.............",
        "........................",
    ],
    # Unrecognized sports: a coach's whistle on a school-color lanyard. The
    # trophy is kept for tournaments and CELEBRATION announcements.
    "athletics": [
        "......................A.",
        "......................A.",
        ".....................A..",
        ".....................A..",
        ".....................A..",
        "...................AA...",
        "..................A..A..",
        "..............dd.....A..",
        "..dddddddddddddddddAA...",
        "..dwwwwwwwwwwwwwwwdd....",
        "..dwwwwwwwwkkwWWwwwdd...",
        "..dwwwwwwwwwwWwwwwwwd...",
        "..ddddddddddWwwwwwwwwd..",
        "........dwwWwwwwwwwwwd..",
        "........dwwwwwwwwwwwwd..",
        "........dwwwwwwwwwwwwd..",
        "........dwwwwwwwwwwwwd..",
        ".........dwwwwwwwwwwd...",
        ".........ddwwwwwwwwdd...",
        "..........ddwwwwwwdd....",
        "...........dddddddd.....",
        "..............dd........",
        "........................",
        "........................",
    ],
    "trophy": [
        "........................",
        "........................",
        "...NNNNNNNNNNNNNNNNNN...",
        ".NNNNNNNNNNNNNNNNNNNNNN.",
        ".N.NNNNNNNNNNNNNNNNNN.N.",
        ".N.AAWAAAAAAAAAAAAAAA.N.",
        ".N.CCWCCCCCCCCCCCCCCC.N.",
        ".N.NNNNNNNNNNNNNNNNNN.N.",
        "..N.NWNNNNNNNNNNNNNN.N..",
        "...N.NNNNNNNNNNNNNN.N...",
        ".....NNNNNNNNNNNNNN.....",
        "......nNNNNNNNNNNn......",
        ".......nNNNNNNNNn.......",
        ".........nNNNNn.........",
        "..........NNNN..........",
        "..........NNNN..........",
        ".........nNNNNn.........",
        ".......wwwwwwwwww.......",
        ".......wWWWWWWWWw.......",
        "......wwwwwwwwwwww......",
        "......wwwwwwwwwwww......",
        "........................",
        "........................",
        "........................",
    ],
}
