# Today in Grateful Dead History for Glance LED Panels (192x32).
#
# Every Grateful Dead show played on today's date, 1965 through the last
# one at Soldier Field on 7/9/95, with full setlists, segues and notes.
# One show at a time, a new one each hour from a daily shuffle of the
# date's shows, so every show comes around.
#
# Data comes from gdsets.com's event search (the same feed behind its own
# "Today in GD history" box): one request returns every event on a month
# and day as HTML, with each show's sets, a ">" or "," after every song,
# and notes. It also lists side projects and later bands, so only events
# billed exactly "Grateful Dead" are kept, and cancelled shows are dropped.
# There's no JSON, so it's parsed with plain string search (Starlark has no
# regex or HTML parser); if gdsets doesn't answer the app shows "DATA
# UNAVAILABLE" rather than crashing. Song milestones and play counts never
# change, so they're tables at the end of the file, worked out once from
# the same data.

USER_AGENT = "Mozilla/5.0 (compatible; glance-dev-network/1.0)"
LAST_SHOW = "1995-07-09"
NPAGES = 8

MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# Songs in one segue chain share a color; the next chain switches.
CHAIN_COLORS = ["white", "#9CC8FF"]
ARROW = "#FF9F1C"
TAG_COLOR = "#888888"
TABS = {"1": "#FF3B3B", "2": "#3BA7FF", "3": "#B36BFF", "4": "#FF9F1C", "E": "#3DDC84", "BOB": "#FFE14D", "NOTE": "#FFE14D"}

# Text sizes tried biggest first, until a show's sets fit in SET_PAGES_MAX
# pages: (font, line height, lines per page, one song per line?, shortened
# names?). 4x7 keeps 5x7's full height with narrower letters, so it reads
# almost as well and fits about 40% more per line.
LADDER = [
    ("5x7", 8, 4, True, False),
    ("5x7", 8, 4, False, False),
    ("4x7", 8, 4, False, False),
    ("4x7", 8, 4, False, True),
    ("4x5", 6, 5, False, False),
    ("4x5", 6, 5, False, True),
]
SET_PAGES_MAX = 4

# The green E badge that starts an encore folded onto the last set page.
BADGE_W = 6

# The names Deadheads already use, swapped in when a show is too long to
# fit at full length.
SHORT = {
    "ALL ALONG THE WATCHTOWER": "WATCHTOWER",
    "AND WE BID YOU GOODNIGHT": "BID YOU GOODNIGHT",
    "ATTICS OF MY LIFE": "ATTICS",
    "BALLAD OF A THIN MAN": "THIN MAN",
    "BEAT IT ON DOWN THE LINE": "BIODTL",
    "BROWN-EYED WOMEN": "BROWN-EYED",
    "CAUTION DO NOT STOP ON TRACKS": "CAUTION",
    "CHINA CAT SUNFLOWER": "CHINA CAT",
    "CRYPTICAL ENVELOPMENT": "CRYPTICAL",
    "CUMBERLAND BLUES": "CUMBERLAND",
    "DANCIN' IN THE STREETS": "DANCIN'",
    "DUPREE'S DIAMOND BLUES": "DUPREE'S",
    "ESTIMATED PROPHET": "ESTIMATED",
    "EYES OF THE WORLD": "EYES",
    "FEEL LIKE A STRANGER": "STRANGER",
    "FIRE ON THE MOUNTAIN": "FIRE",
    "FRANKLIN'S TOWER": "FRANKLIN'S",
    "FRIEND OF THE DEVIL": "FOTD",
    "GOIN' DOWN THE ROAD": "GDTRFB",
    "GREATEST STORY EVER TOLD": "GREATEST STORY",
    "HELL IN A BUCKET": "BUCKET",
    "HELP ON THE WAY": "HELP",
    "I KNOW YOU RIDER": "RIDER",
    "I NEED A MIRACLE": "MIRACLE",
    "IT MUST HAVE BEEN THE ROSES": "ROSES",
    "IT'S ALL OVER NOW BABY BLUE": "BABY BLUE",
    "KNOCKIN' ON HEAVEN'S DOOR": "HEAVEN'S DOOR",
    "LITTLE RED ROOSTER": "ROOSTER",
    "MEXICALI BLUES": "MEXICALI",
    "MINGLEWOOD BLUES": "MINGLEWOOD",
    "MISSISSIPPI HALF-STEP": "HALF-STEP",
    "NOT FADE AWAY": "NFA",
    "ONE MORE SATURDAY NIGHT": "SATURDAY NIGHT",
    "PLAYIN' IN THE BAND": "PLAYIN'",
    "QUEEN JANE APPROXIMATELY": "QUEEN JANE",
    "QUINN THE ESKIMO": "QUINN",
    "RAMBLE ON ROSE": "RAMBLE ON",
    "SAINT OF CIRCUMSTANCE": "SAINT",
    "SAMSON & DELILAH": "SAMSON",
    "SCARLET BEGONIAS": "SCARLET",
    "SHAKEDOWN STREET": "SHAKEDOWN",
    "SMOKESTACK LIGHTNING": "SMOKESTACK",
    "STANDING ON THE MOON": "STANDING",
    "STUCK INSIDE OF MOBILE": "MOBILE",
    "SUGAR MAGNOLIA": "SUGAR MAG",
    "TERRAPIN STATION": "TERRAPIN",
    "THE MUSIC NEVER STOPPED": "MUSIC NEVER STOPPED",
    "THE OTHER ONE": "OTHER ONE",
    "THE TIMES THEY ARE A-CHANGIN'": "TIMES A-CHANGIN'",
    "THEY LOVE EACH OTHER": "TLEO",
    "TOUCH OF GREY": "TOUCH",
    "TURN ON YOUR LOVELIGHT": "LOVELIGHT",
    "UNCLE JOHN'S BAND": "UJB",
    "VICTIM OR THE CRIME": "VICTIM",
    "VIOLA LEE BLUES": "VIOLA LEE",
    "VISIONS OF JOHANNA": "VISIONS",
    "WEST L.A. FADEAWAY": "WEST L.A.",
    "WHEN I PAINT MY MASTERPIECE": "MASTERPIECE",
    "WOMEN ARE SMARTER": "WOMEN SMARTER",
}

# What each guest played. gdsets names its guests but almost never their
# instruments, so this fills them in; anyone not listed shows by name only.
# Keys are lowercase to fold its two spellings of Hamza El-Din together.
GUEST_INSTRUMENT = {
    "airto moreira": "PERCUSSION",
    "art neville": "KEYS",
    "babatunde olatunji": "PERCUSSION",
    "batucaje": "PERCUSSION",
    "berry oakley": "BASS",
    "billy cobham": "DRUMS",
    "bo diddley": "VOCALS, GUITAR",
    "bob dylan": "VOCALS, GUITAR",
    "bonnie raitt": "GUITAR, VOCALS",
    "boz scaggs": "VOCALS",
    "branford marsalis": "SAX",
    "brian wilson": "VOCALS",
    "bruce hornsby": "PIANO, ACCORDION",
    "butch trucks": "DRUMS",
    "carl wilson": "VOCALS",
    "carlos santana": "GUITAR",
    "carter beauford": "DRUMS",
    "charles lloyd": "FLUTE, SAX",
    "clarence clemons": "SAX",
    "craig chaquico": "GUITAR",
    "danny kirwan": "GUITAR",
    "dave torbert": "BASS",
    "david crosby": "GUITAR, VOCALS",
    "david grisman": "MANDOLIN",
    "david hidalgo": "GUITAR",
    "david laflamme": "VIOLIN",
    "david murray": "SAX",
    "david nelson": "GUITAR",
    "dennis wilson": "VOCALS",
    "diana moreira": "VOCALS",
    "dickey betts": "GUITAR",
    "dino valenti": "VOCALS",
    "duane allman": "GUITAR",
    "edie brickell": "VOCALS",
    "elvin bishop": "GUITAR, VOCALS",
    "etta james": "VOCALS",
    "flora purim": "VOCALS",
    "gary duncan": "GUITAR",
    "glen velez": "FRAME DRUM",
    "grace slick": "VOCALS",
    "graham wiggins": "DIDGERIDOO",
    "greg errico": "DRUMS",
    "gregg allman": "ORGAN, VOCALS",
    "gregg rolie": "KEYS",
    "gyuto monks": "CHANT",
    "hall & oates": "VOCALS",
    "hamza el-din": "OUD, TAR",
    "huey lewis": "HARMONICA",
    "jack casady": "BASS",
    "jaimoe": "DRUMS",
    "james cotton": "HARMONICA",
    "janis joplin": "VOCALS",
    "joan baez": "VOCALS",
    "joe ellis": "TRUMPET",
    "john cipollina": "GUITAR",
    "john dawson": "GUITAR, VOCALS",
    "john fogerty": "GUITAR, VOCALS",
    "john kahn": "BASS",
    "john popper": "HARMONICA",
    "jorma kaukonen": "GUITAR",
    "jose chepito areas": "PERCUSSION",
    "ken babbs": "SPOKEN WORD",
    "ken kesey": "SPOKEN WORD",
    "ken nordine": "SPOKEN WORD",
    "kodo drummer": "TAIKO",
    "lee oskar": "HARMONICA",
    "maria muldaur": "VOCALS",
    "martin fierro": "SAX",
    "matthew kelly": "HARMONICA",
    "merl saunders": "KEYS",
    "michael doucet": "FIDDLE",
    "mick fleetwood": "DRUMS",
    "mick taylor": "GUITAR",
    "mickey thomas": "VOCALS",
    "mike carabello": "PERCUSSION",
    "neal cassady": "SPOKEN WORD",
    "ned lagin": "KEYS, ELECTRONICS",
    "neil young": "GUITAR, VOCALS",
    "norton buffalo": "HARMONICA",
    "ornette coleman": "SAX",
    "papa john creach": "VIOLIN",
    "pete townshend": "GUITAR",
    "peter green": "GUITAR",
    "rick danko": "VOCALS",
    "shankar ghosh": "TABLA",
    "sikiru adepoju": "TALKING DRUM",
    "spencer davis": "VOCALS, GUITAR",
    "stephen stills": "GUITAR, VOCALS",
    "steve miller": "GUITAR, VOCALS",
    "suzanne vega": "VOCALS",
    "tom constanten": "KEYS",
    "will scarlett": "HARMONICA",
    "willie green": "DRUMS",
    "zakir hussain": "TABLA",
}

# Who was in the band, by gdsets' lineup id (its 14 Grateful Dead lineups
# never change, so they live here rather than costing a request).
LINEUPS = {
    "1784": ["JERRY", "BOBBY", "PHIL", "PIGPEN", "BILLY"],
    "1785": ["JERRY", "BOBBY", "PHIL", "PIGPEN", "MICKEY", "BILLY"],
    "1786": ["JERRY", "BOBBY", "PHIL", "PIGPEN", "TC", "MICKEY", "BILLY"],
    "1787": ["JERRY", "BOBBY", "PHIL", "PIGPEN", "MICKEY", "BILLY"],
    "1788": ["JERRY", "BOBBY", "PHIL", "PIGPEN", "BILLY"],
    "1789": ["JERRY", "BOBBY", "PHIL", "PIGPEN", "KEITH", "BILLY"],
    "1790": ["JERRY", "BOBBY", "PHIL", "PIGPEN", "KEITH", "DONNA", "BILLY"],
    "1791": ["JERRY", "BOBBY", "PHIL", "KEITH", "DONNA", "BILLY"],
    "1792": ["JERRY", "BOBBY", "PHIL", "KEITH", "DONNA", "BILLY"],
    "1793": ["JERRY", "BOBBY", "PHIL", "KEITH", "DONNA", "MICKEY", "BILLY"],
    "1794": ["JERRY", "BOBBY", "PHIL", "BRENT", "MICKEY", "BILLY"],
    "1795": ["JERRY", "BOBBY", "PHIL", "VINCE", "MICKEY", "BILLY"],
    "1796": ["JERRY", "BOBBY", "PHIL", "VINCE", "BRUCE", "MICKEY", "BILLY"],
    "1797": ["JERRY", "BOBBY", "PHIL", "VINCE", "MICKEY", "BILLY"],
}

# How the notes name each member ("w/o Bruce Hornsby", "John Kahn
# substituted for Phil").
MEMBER_WORDS = {
    "JERRY": ["jerry", "garcia"],
    "BOBBY": ["weir", "bob", "bobby"],
    "PHIL": ["phil", "lesh"],
    "PIGPEN": ["pigpen", "mckernan"],
    "TC": ["constanten"],
    "KEITH": ["keith"],
    "DONNA": ["donna"],
    "BRENT": ["brent", "mydland"],
    "VINCE": ["vince", "welnick"],
    "BRUCE": ["bruce", "hornsby"],
    "MICKEY": ["mickey", "hart"],
    "BILLY": ["billy", "kreutzmann"],
}

# Each member's birthday, for their age at the show.
BIRTHDAYS = {
    "JERRY": "1942-08-01",
    "BOBBY": "1947-10-16",
    "PHIL": "1940-03-15",
    "PIGPEN": "1945-09-08",
    "TC": "1944-03-19",
    "KEITH": "1948-07-19",
    "DONNA": "1947-08-22",
    "BRENT": "1952-10-21",
    "VINCE": "1951-02-21",
    "BRUCE": "1954-11-23",
    "MICKEY": "1943-09-11",
    "BILLY": "1946-05-07",
}

def age_on(m, date):
    # The member's age on the date, or -1 for a fill-in.
    b = BIRTHDAYS.get(m, "")
    if not b:
        return -1
    return int(date[0:4]) - int(b[0:4]) - (1 if date[5:] < b[5:] else 0)

def birthday_note(show, members):
    # "BOBBY'S 40TH BIRTHDAY" when the show fell on one; None if not.
    for m, col in members:
        b = BIRTHDAYS.get(m, "")
        if b and b[5:] == show["date"][5:]:
            return m + "'S " + ordinal(age_on(m, show["date"])) + " BIRTHDAY"
    return None

# gdsets gives Ned Lagin's 1974 shows (he and Phil played "Seastones")
# a lineup of their own, but he was never a member, so he shows as a guest.
NED_LINEUP = "1792"

JOIN_COLOR = "#3DDC84"
LEAVE_COLOR = "#FF3B3B"
SUB_COLOR = "#FF9F1C"

# Gold dots after a song mark a guest on it: one, two or three dots for
# gdsets' "*", "**" and "***", which the notes match to names.
GUEST_COLOR = "#FFE14D"
DOT_W = 3

# Official titles gdsets writes differently.
TITLE_FIX = {
    "SLIPKNOT": "SLIPKNOT!",
}

def fix_titles(s):
    # Applied to upper-case song names and notes; skips one already fixed.
    for wrong, right in TITLE_FIX.items():
        s = s.replace(right, wrong).replace(wrong, right)
    return s

ROMAN = {"I": "1", "II": "2", "III": "3", "IV": "4"}
ORDINAL = {"1ST": "1", "2ND": "2", "3RD": "3", "4TH": "4", "FIRST": "1", "SECOND": "2", "THIRD": "3"}

MILESTONE_KINDS = {
    "D": ("DEBUT", "#3DDC84"),
    "K": ("1ST KNOWN", "#3DDC84"),
    "O": ("ONLY TIME", "#FFE14D"),
    "B": ("BUST-OUT", "#B36BFF"),
    "L": ("LAST TIME", "#FF3B3B"),
    "R": ("RAREST", "#FF9F1C"),
}

def milestones(show):
    # [(kind, song, date last played, count)] for the show, in the table's
    # order: count is shows since for a bust-out, times played for the
    # rarest song. Last comes the night's rarest song (RARE_PLAYS) not
    # already named.
    out = []
    raw = MILESTONES.get(show["date"], "")
    for item in (raw.split("|") if raw else []):
        k = item[0]
        if k == "B":
            d = item[1:9]
            out.append((k, item[13:], d[0:4] + "-" + d[4:6] + "-" + d[6:8], int(item[9:13])))
        else:
            out.append((k, item[1:], "", 0))
    named = [m[1] for m in out]
    rare = None
    for key, tags, songs in show["sets"]:
        for name, seg, stars in songs:
            nm = name.upper()
            n = RARE_PLAYS.get(nm, 0)
            if n and nm not in named and (rare == None or n < rare[1]):
                rare = (nm, n)
    if rare != None:
        out.append(("R", rare[0], "", rare[1]))
    return out

# ---------------------------------------------------------------- dates

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    z += 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return (y + 1 if m <= 2 else y, m, d)

def weekday(days):
    # 0 = Sunday; epoch day 0 (1970-01-01) was a Thursday.
    return (days + 4) % 7

def slash_date(d):
    # "1990-07-26" -> "7/26/90"
    return str(int(d[5:7])) + "/" + str(int(d[8:10])) + "/" + d[2:4]

def eastern_today(ctx):
    # US Eastern date: DST runs from the second Sunday in March (7:00 UTC)
    # to the first Sunday in November (6:00 UTC).
    unix = ctx.now.unix
    y = ctx.now.year
    mar8 = days_from_civil(y, 3, 8)
    start = (mar8 + (7 - weekday(mar8)) % 7) * 86400 + 7 * 3600
    nov1 = days_from_civil(y, 11, 1)
    end = (nov1 + (7 - weekday(nov1)) % 7) * 86400 + 6 * 3600
    offset = -4 if unix >= start and unix < end else -5
    return civil_from_days((unix + offset * 3600) // 86400)

# Each band era's color, by who was on keys: Pigpen, then Keith & Donna,
# Brent, and Vince (with Bruce). Keith's months alongside Pigpen stay
# Pigpen's, since he was still in the band.
ERA_COLORS = [
    ("PIGPEN", "#B36BFF"),
    ("KEITH", "#FF9F1C"),
    ("BRENT", "#3DDC84"),
    ("VINCE", "#3BA7FF"),
]

ERA_NAMES = {"PIGPEN": "PIGPEN ERA", "KEITH": "KEITH & DONNA ERA", "BRENT": "BRENT ERA", "VINCE": "VINCE ERA"}

def era_key(show):
    # Who was on keys, which names the era (see ERA_COLORS); by the date
    # the era changed when there's no lineup on record.
    members = LINEUPS.get(show["lineup"], [])
    for who, color in ERA_COLORS:
        if who in members:
            return who
    d = show["date"]
    if d <= "1972-06-17":
        return "PIGPEN"
    if d <= "1979-02-17":
        return "KEITH"
    if d <= "1990-07-23":
        return "BRENT"
    return "VINCE"

def era_color(show):
    return {who: color for who, color in ERA_COLORS}[era_key(show)]

def scramble(x):
    x = x & 0xFFFFFFFF
    x = ((x ^ 61) ^ (x >> 16)) & 0xFFFFFFFF
    x = (x + (x << 3)) & 0xFFFFFFFF
    x = (x ^ (x >> 4)) & 0xFFFFFFFF
    x = (x * 0x27d4eb2d) & 0xFFFFFFFF
    x = (x ^ (x >> 15)) & 0xFFFFFFFF
    return x

def rotation_index(ctx, n, day):
    # The date's shows in a fresh shuffled order each day, stepping to the
    # next one every hour: it looks random, but every show gets its turn
    # before any repeats and none comes up twice in a row. Hourly so it
    # holds whatever refresh the panel uses, up to an hour.
    order = sorted(range(n), key = lambda k: scramble(day * 64 + k))
    return order[(ctx.now.unix // 3600) % n]

# ---------------------------------------------------------------- parsing

def strip_tags(s):
    parts = s.split("<")
    out = parts[0]
    for p in parts[1:]:
        i = p.find(">")
        out += p[i + 1:] if i >= 0 else p
    return out

# Characters the panel fonts lack, as their UTF-8 bytes, and the ASCII to
# show instead (the fonts have no double quote either, so two apostrophes
# stand in for one). gdsets labels its pages Latin-1 but sends UTF-8, so each
# arrives as one character per byte.
FOLD = [
    ([0xE2, 0x81, 0xA0], ""),  # word joiner after a guest "*"
    ([0xE2, 0x80, 0x98], "'"),
    ([0xE2, 0x80, 0x99], "'"),
    ([0xE2, 0x80, 0x9C], "''"),
    ([0xE2, 0x80, 0x9D], "''"),
    ([0xE2, 0x80, 0x93], "-"),
    ([0xE2, 0x80, 0x94], "-"),
    ([0xC3, 0xA9], "e"),
    ([0xC3, 0x89], "E"),
    ([0xC3, 0xA2], "a"),
    ([0xC3, 0xBC], "u"),
    ([0xC3, 0xB1], "n"),
    ([0xC3, 0xB6], "o"),
]
FOLD_STR = [("".join([chr(b) for b in bs]), out) for bs, out in FOLD]

def unescape(s):
    s = s.replace("&amp;", "&").replace("&#39;", "'").replace("&#039;", "'")
    s = s.replace("&quot;", "''").replace("\"", "''").replace("&gt;", ">").replace("&lt;", "<").replace("&nbsp;", " ")
    s = s.replace("&ndash;", "-").replace("&mdash;", "-")
    for bad, good in FOLD_STR:
        s = s.replace(bad, good)

    # Nor do "?" and "#": gdsets' "(?)" marks a guess.
    s = s.replace("(?)", " (MAYBE)").replace("?)", ", MAYBE)").replace("?", " (MAYBE)")
    s = s.replace("#", "NO. ")

    # Anything else outside ASCII would be dropped by c.text anyway.
    if [ch for ch in s.elems() if ord(ch) > 126]:
        s = "".join([ch for ch in s.elems() if ord(ch) <= 126])
    return s

def clean(s):
    return " ".join(unescape(strip_tags(s)).split())

def parse_label(raw):
    # "I:", "E:", "II: (acoustic)", "(early)", "(late) I: (electric)" ->
    # (tab key, grey tags).
    t = clean(raw).upper().replace("(", " ").replace(")", " ").replace(":", " ")
    key = ""
    tags = []
    for w in t.split():
        if w in ROMAN:
            key = ROMAN[w]
        elif w == "E" or w == "E1" or w == "E2" or w == "ENCORE":
            key = "E"
        elif w == "EARLY" or w == "LATE":
            tags.append(w + " SHOW")
        elif w == "ACOUSTIC" or w == "ELECTRIC":
            tags.append(w)
    return key, tags

def parse_songs(body):
    # Each song is followed by <span class="nobr">SEP</span>, where SEP is
    # ">" (segues into the next song), "," or empty. A guest marker nests
    # a <span class="ref-post">*</span> inside it.
    # Songs come back as (name, segue?, guest stars).
    pieces = body.split("<span class=\"nobr\">")
    songs = []
    rest = pieces[0]
    for k in range(1, len(pieces)):
        p = pieces[k]
        close = p.find("</span>")
        if p.startswith("<span"):
            close = p.find("</span>", close + 7)
        if close < 0:
            close = len(p)
        name = clean(rest).replace("*", "").strip()
        sep = clean(p[:close])
        if name:
            songs.append((name, ">" in sep, min(sep.count("*"), 3)))
        rest = p[close + 7:]
    return songs

def parse_head(date, b):
    # Date, venue and city from one show's headline; None for a cancelled
    # show or any band other than the Grateful Dead.
    hd_end = b.find("</div>")
    if hd_end < 0:
        return None
    head = clean(b[:hd_end])
    if "(cancelled)" in head.lower():
        return None
    r = head.find("] ")
    dow = head[r - 3:r].upper() if r >= 3 else ""
    rest = head[r + 2:] if r >= 0 else head
    dash = rest.find(" - ")
    if dash < 0 or rest[:dash] != "Grateful Dead":
        return None
    place = rest[dash + 3:]
    # Club Front was the band's rehearsal hall, and a soundcheck "for the
    # next day's performance" (Watkins Glen 7/27/73, Cairo 9/13/78) is a
    # warm-up; neither counts as a show. A real show whose notes mention a
    # taped soundcheck too (Port Chester 11/6/70) stays.
    if "Club Front" in place:
        return None
    n0 = b.find("<!-- NOTES -->")
    if n0 >= 0 and "soundcheck for" in b[n0:b.find("</div>", n0)].lower():
        return None

    # gdsets' own name for the venue, for the per-venue lookup.
    venue_q = ""
    vt = b[:hd_end].find("data-tip-type=\"venue\">")
    if vt >= 0:
        ve = b[:hd_end].find("</span>", vt)
        venue_q = unescape(b[vt + 22:ve]).strip()
    if place.endswith(")") and place.rfind(" (") >= 0:
        place = place[:place.rfind(" (")]
    parts = place.split(", ")
    if len(parts) >= 3:
        venue = ", ".join(parts[:-2])
        city = parts[-2] + ", " + parts[-1]
    elif len(parts) == 2:
        venue = parts[0]
        city = parts[1]
    else:
        venue = place
        city = ""
    # gdsets' ids for the show's lineup and its guest list.
    lineup = attr(b[:hd_end], "data-lineup")
    guests_id = attr(b[:hd_end], "data-guests")
    y = int(date[0:4]) if is_digits(date[0:4]) else 0
    return {"date": date, "y": y, "dow": dow, "venue": venue, "venue_q": venue_q or venue, "city": city, "lineup": lineup, "guests_id": guests_id}

def attr(s, name):
    i = s.find(name + "=\"")
    if i < 0:
        return ""
    i += len(name) + 2
    return s[i:s.find("\"", i)]

def parse_show(date, b):
    show = parse_head(date, b)
    if show == None:
        return None

    notes = ""
    n0 = b.find("<!-- NOTES -->")
    if n0 >= 0:
        n1 = b.find("</div>", n0)
        # The "*" stay: the NOTE page draws them as the songs' gold dots.
        notes = clean(b[n0 + 14:n1 if n1 >= 0 else len(b)])
        if notes.startswith("(") and notes.endswith(")"):
            notes = notes[1:-1]
        # The fonts have no ";" glyph; "view the program" is link text.
        notes = notes.replace("; ", " / ").replace(";", " / ")
        notes = notes.replace(" / view the program", "").replace("view the program", "")
        notes = " ".join(notes.split())

    # Which numbered set Bob Dylan sat in on ("2nd set and encore
    # w/Bob Dylan"), so its tab can say BOB.
    dylan = ""
    nu = notes.upper()
    if "W/BOB DYLAN" in nu or "WITH BOB DYLAN" in nu:
        for w in nu.replace(",", " ").replace("(", " ").split():
            if w in ORDINAL and dylan == "":
                dylan = ORDINAL[w]
        if dylan == "":
            dylan = "?"

    sets = []
    s0 = b.find("setlists-div")
    if s0 >= 0:
        s1 = b.find("<!-- NOTES -->", s0)
        if s1 < 0:
            s1 = b.find("media-div", s0)
        if s1 < 0:
            s1 = len(b)
        last = "0"
        for line in b[s0:s1].split("setlist-line")[1:]:
            lb = line.find("<b>")
            le = line.find("</b>")
            if lb >= 0 and le > lb:
                key, tags = parse_label(line[lb + 3:le])
                body = line[le + 4:]
            else:
                key, tags = "", []
                body = line[line.find(">") + 1:]
            if key == "":
                key = str(int(last) + 1) if last != "E" else "1"
            if key == dylan:
                key = "BOB"
            songs = parse_songs(body)
            if songs:
                sets.append((key, tags, songs))
            if key in ROMAN.values():
                last = key
    show["notes"] = notes
    show["sets"] = sets
    show["dylan"] = dylan != ""
    return show

def is_digits(s):
    if s == "":
        return False
    for i in range(len(s)):
        if s[i] < "0" or s[i] > "9":
            return False
    return True

def url_quote(s):
    s = s.replace("%", "%25").replace(" ", "%20").replace("&", "%26").replace("/", "%2F")
    s = s.replace("'", "%27").replace("#", "%23").replace("+", "%2B").replace("?", "%3F")
    s = s.replace("=", "%3D").replace(",", "%2C").replace("\"", "%22")
    return s

def fetch_heads(query):
    # Every Grateful Dead show a gdsets search returns, in date order,
    # cancelled ones and anything after LAST_SHOW left out; None if the
    # lookup fails. Past shows never change, so it's cached for 30 days.
    resp = http.get(
        "https://gdsets.com/scripts/q-events-classic.pl?" + query + "&band=Grateful%20Dead",
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 2592000,
    )
    if resp["status_code"] != 200:
        return None
    chunks = resp["body"].split(" SHOW -->")
    out = []
    for i in range(1, len(chunks)):
        date = chunks[i - 1][-10:]
        if len(date) != 10 or date[4] != "-" or date > LAST_SHOW:
            continue
        h = parse_head(date, chunks[i])
        if h != None:
            out.append(h)
    return out

def around(heads, show):
    # (index of this show in heads, previous show, next show).
    k = -1
    for i in range(len(heads)):
        if heads[i]["date"] == show["date"] and k < 0:
            k = i
    if k < 0:
        return None
    prev = heads[k - 1] if k > 0 else None
    nxt = heads[k + 1] if k + 1 < len(heads) else None
    return (k, prev, nxt)

def guest_names(show):
    # The show's guests in gdsets' order, each "NAME - INSTRUMENT" where
    # known, plus Ned Lagin on his own lineup's shows; [] for none.
    ned = [("NED LAGIN", GUEST_INSTRUMENT["ned lagin"])] if show["lineup"] == NED_LINEUP else []
    out = fetch_guests(show)
    if ned and not [n for n, i in out if n == "NED LAGIN"]:
        out = out + ned
    return out

def fetch_guests(show):
    # gdsets' guest list for the show; [] for none or a failed lookup.
    # Cached for 30 days.
    if not show["guests_id"]:
        return []
    resp = http.get(
        "https://gdsets.com/scripts/tips.pl?guests=" + show["guests_id"],
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 2592000,
    )
    if resp["status_code"] != 200:
        return []
    out = []
    for li in resp["body"].split("<li>")[1:]:
        name = clean(li[:li.find("</li>")] if "</li>" in li else li)
        played = GUEST_INSTRUMENT.get(name.lower(), "")
        d = name.find(" - ")
        if d >= 0:
            # gdsets named the instrument itself ("John Kahn - bass").
            played = name[d + 3:].upper()
            name = name[:d]
            played = GUEST_INSTRUMENT.get(name.lower(), played)
        if name == "" or name == "Unknown":
            continue
        out.append((name.upper(), played))
    return out

def names_member(text, m):
    # A fill-in (not a member) never matches.
    for w in MEMBER_WORDS.get(m, []):
        if (" " + text + " ").find(" " + w + " ") >= 0:
            return True
    return False

def band(show):
    # [(name, color)] for who played: the lineup, less anyone the notes
    # say sat the whole show out ("w/o Bruce Hornsby"), with any fill-in
    # ("John Kahn substituted for Phil") in the missing player's place.
    # Notes tied to a song by "*" are only that song, so they're skipped.
    out = [(m, "white") for m in LINEUPS.get(show["lineup"], [])]
    for seg in show["notes"].split(" / "):
        s = " ".join(seg.lower().replace(",", " ").split())
        if s.startswith("also "):
            s = s[5:]
        if s.startswith("w/o ") or s.startswith("without "):
            out = [(m, col) for m, col in out if not names_member(s, m)]
        elif " substituted for " in s:
            who = s[:s.find(" substituted for ")].split(" ")[-1].upper()
            gone = s[s.find(" substituted for ") + 17:]
            out = [((who, SUB_COLOR) if names_member(gone, m) else (m, col)) for m, col in out]
    return out

def milestone(show, prev, nxt):
    # Members joining (absent from the previous show that year) or
    # leaving (absent from the next): ({member: color}, header text).
    this = LINEUPS.get(show["lineup"], [])
    joins = []
    leaves = []
    if prev != None and prev["lineup"] in LINEUPS:
        joins = [m for m in this if m not in LINEUPS[prev["lineup"]]]
    if nxt != None and nxt["lineup"] in LINEUPS:
        leaves = [m for m in this if m not in LINEUPS[nxt["lineup"]]]
    colors = {}
    for m in leaves:
        colors[m] = LEAVE_COLOR
    for m in joins:
        colors[m] = JOIN_COLOR
    if joins:
        return colors, ("JOINS: " + ", ".join(joins), JOIN_COLOR)
    if leaves:
        return colors, ("LAST SHOW: " + ", ".join(leaves), LEAVE_COLOR)
    return colors, None

def guest_line(c, guests, maxw):
    # "WITH BRANFORD MARSALIS - SAX", falling back to names only, then to
    # the first few names and a count of the rest.
    full = ", ".join([n + (" - " + i if i else "") for n, i in guests])
    if c.text_width("WITH " + full, "4x5") <= maxw:
        return "WITH " + full
    for k in range(len(guests), 0, -1):
        t = "WITH " + ", ".join([n for n, i in guests[:k]])
        if k < len(guests):
            t += " +" + str(len(guests) - k) + " MORE"
        if c.text_width(t, "4x5") <= maxw:
            return t
    return fit_text(c, "WITH " + guests[0][0], "4x5", maxw)

def venue_heads(show):
    return fetch_heads("venue=" + url_quote(show["venue_q"]))

def year_query(show):
    return "date=%25%2F%25%2F" + str(show["y"])[2:]

def year_heads(show):
    return fetch_heads(year_query(show))

def year_shows(show):
    # Every Grateful Dead show that year with its setlist, from the same
    # cached request as year_heads; [] if the lookup fails.
    resp = http.get(
        "https://gdsets.com/scripts/q-events-classic.pl?" + year_query(show) + "&band=Grateful%20Dead",
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 2592000,
    )
    if resp["status_code"] != 200:
        return []
    chunks = resp["body"].split(" SHOW -->")
    out = []
    for i in range(1, len(chunks)):
        date = chunks[i - 1][-10:]
        if len(date) != 10 or date[4] != "-" or date > LAST_SHOW:
            continue
        s = parse_show(date, chunks[i])
        if s != None:
            out.append(s)
    return out

def city_heads(show):
    # Every Dead show in the show's town: "New York, NY" searches city and
    # state; "London, England" the city alone.
    if not show["city"]:
        return None
    parts = show["city"].split(", ")
    st = parts[1] if len(parts) > 1 else ""
    q = "city=" + url_quote(parts[0])
    if len(st) == 2 and st.isupper():
        q += "&state=" + st
    return fetch_heads(q)

def city_rank(show):
    heads = city_heads(show)
    if heads == None:
        return None
    a = around(heads, show)
    if a == None:
        return None
    return (a[0] + 1, len(heads))

def venue_rank(show):
    heads = venue_heads(show)
    if heads == None:
        return None
    a = around(heads, show)
    if a == None:
        return None
    return (a[0] + 1, len(heads))

def ordinal(n):
    if n % 100 >= 11 and n % 100 <= 13:
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

def fetch_shows(m, d):
    resp = http.get(
        "https://gdsets.com/scripts/q-events-classic.pl?date=" + str(m) + "%2F" + str(d) + "%2F%25",
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 86400,
    )
    if resp["status_code"] != 200:
        return None
    chunks = resp["body"].split(" SHOW -->")
    shows = []
    for i in range(1, len(chunks)):
        date = chunks[i - 1][-10:]
        if len(date) != 10 or date[4] != "-" or date > LAST_SHOW:
            continue
        s = parse_show(date, chunks[i])
        if s != None:
            shows.append(s)
    return shows

# ---------------------------------------------------------------- layout

def text_h(font):
    return 7 if font == "5x7" or font == "4x7" else 5

def layout(c, tags, songs, font, one_per_line, short, badge = False):
    # Lines of tokens (kind, text, chain, segue?, guest stars). Wraps at
    # song boundaries; a song wider than a line breaks between words.
    # With badge, the first line opens on the encore's E badge.
    sp = c.text_width("A A", font) - c.text_width("AA", font)
    maxw = 176
    lines = []
    cur = []
    x = 0
    if badge:
        cur.append(("badge", "E", 0, False, 0))
        x = BADGE_W + 2 * sp
    if tags:
        t = " / ".join(tags)
        cur.append(("tag", t, 0, False, 0))
        x += c.text_width(t, "4x5") + 2 * sp
        if one_per_line:
            lines.append(cur)
            cur = []
            x = 0
    chain = 0
    for name, seg, stars in songs:
        name = fix_titles(name.upper())
        if short:
            name = SHORT.get(name, name)
        w = c.text_width(name, font) + stars * DOT_W + (4 + sp if seg else 0)
        if x > 0 and (one_per_line or x + w > maxw):
            lines.append(cur)
            cur = []
            x = 0
        if w <= maxw:
            cur.append(("song", name, chain, seg, stars))
            x += w + 2 * sp
        else:
            words = name.split(" ")
            for j in range(len(words)):
                last = j == len(words) - 1
                ww = c.text_width(words[j], font) + (stars * DOT_W + (4 + sp if seg else 0) if last else 0)
                if x > 0 and x + ww > maxw:
                    lines.append(cur)
                    cur = []
                    x = 0
                cur.append(("word", words[j], chain, seg and last, stars if last else 0))
                x += ww + sp
            x += sp
        if not seg:
            chain += 1
    if cur:
        lines.append(cur)
    return lines

def set_pages(c, show, rung):
    # An encore short enough to fit in the room left on the last set's
    # page goes there behind an E badge instead of taking a page of its own.
    font, lh, per, one, short = rung
    marks = {}
    for k, song, d, g in milestones(show):
        nm = fix_titles(song)
        if nm not in marks:
            marks[nm] = k
            marks[SHORT.get(nm, nm)] = k
    pages = []
    for key, tags, songs in show["sets"]:
        if key == "E" and pages and pages[-1][1]["key"] != "E":
            last = pages[-1][1]
            lines = layout(c, tags, songs, font, one, short, badge = True)
            if len(last["lines"]) + len(lines) <= per:
                last["lines"] = last["lines"] + lines
                continue
        lines = layout(c, tags, songs, font, one, short)
        n = (len(lines) + per - 1) // per
        # Spread lines evenly so no page holds a lone straggler.
        each = (len(lines) + n - 1) // n
        for p in range(n):
            pages.append(("set", {"key": key, "lines": lines[p * each:p * each + each], "p": p + 1, "n": n, "font": font, "lh": lh, "marks": marks}))
    return pages

def wrap_words(c, s, font, maxw, max_lines):
    lines = []
    cur = ""
    for w in s.split(" "):
        t = w if cur == "" else cur + " " + w
        if rich_width(c, t, font) <= maxw:
            cur = t
        else:
            if cur != "":
                lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    if len(lines) > max_lines:
        lines = lines[:max_lines]
        last = lines[-1]
        for n in range(len(last), 0, -1):
            t = last[:n].rstrip(" ,/-") + " ..."
            if rich_width(c, t, font) <= maxw:
                break
        lines[-1] = t
    return lines

def fit_text(c, s, font, maxw):
    if c.text_width(s, font) <= maxw:
        return s
    for n in range(len(s) - 1, 0, -1):
        t = s[:n].rstrip(" ,/-") + "."
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def show_pages(c, show, budget):
    # Card + sets at the biggest text that fits the sets in SET_PAGES_MAX
    # pages, then as many extras as fit, in this order of priority: the
    # final show, milestones, notes (they key the guest dots), band, tour.
    # A show too long for that gets the smallest text and fewer extras.
    # None if even that won't fit.
    extras = ([("final", show)] if show["date"] == LAST_SHOW else []) + ([("milestones", show)] if milestones(show) else []) + ([("notes", show)] if show["notes"] else []) + [("band", show), ("tour", show)]
    if not show["sets"]:
        return [("card", show)] + in_order(extras[:budget - 1])
    # One song per line only when it costs no more pages than flowing them.
    flowed = len(set_pages(c, show, LADDER[1]))
    sp = None
    for rung in LADDER:
        p = set_pages(c, show, rung)
        if rung[3] and len(p) > flowed:
            continue
        if sp == None and len(p) <= SET_PAGES_MAX and 1 + len(p) <= budget:
            sp = p
    if sp == None:
        sp = set_pages(c, show, LADDER[-1])
        if 1 + len(sp) > budget:
            return None
    return [("card", show)] + sp + in_order(extras[:budget - 1 - len(sp)])

def in_order(extras):
    # The order the extras are shown in, whichever made it in.
    rank = {"final": 0, "milestones": 1, "notes": 2, "tour": 3, "band": 4}
    return sorted(extras, key = lambda e: rank[e[0]])

# Pages for a show whose setlist is missing or short, in order: the shows
# either side of it, the nearest show with a setlist, the year's top songs.
FILLERS = ["around", "nearest", "topsongs"]

# Not songs, so left out of the year's top songs.
NOT_SONGS = ["DRUMS", "SPACE", "JAM", "TUNING"]

def plan(c, show):
    # One show per render, always opened by the title page, then its card,
    # sets and extras. Nothing about the date's other shows, so each hour's
    # show is a surprise. Pages a short or missing setlist leaves free go
    # to the fillers, then a splash.
    pages = show_pages(c, show, NPAGES - 1)
    if pages == None:
        pages = ([("card", show)] + set_pages(c, show, LADDER[-1]))[:NPAGES - 1]
    pages = [("intro", None)] + pages
    for kind in FILLERS:
        if len(pages) < NPAGES:
            pages.append((kind, show))
    for i in range(NPAGES - len(pages)):
        pages.append(("splash", show))
    return pages

# ---------------------------------------------------------------- drawing

def chevron(c, x, y, h, color):
    # A ">" drawn with two lines; the panel fonts have no ">" glyph.
    mid = y + h // 2
    c.line(x, y + 1, x + 2, mid, color)
    c.line(x + 2, mid, x, y + h - 2, color)

def guest_dots(c, x, y, n):
    # n gold 2x2 dots at cap height, like a footnote mark; returns the x
    # after them.
    for i in range(n):
        c.rect(x + i * DOT_W, y, x + i * DOT_W + 1, y + 1, fill = GUEST_COLOR)
    return x + n * DOT_W

# Width of the chevron a ">" in the notes is drawn as.
NOTE_ARROW_W = 4

def rich_width(c, s, font):
    # Width of note text with each "*" drawn as a guest dot and each ">"
    # as a segue chevron.
    plain = s.replace("*", "").replace(">", "")
    return c.text_width(plain, font) + s.count("*") * DOT_W + s.count(">") * NOTE_ARROW_W

def draw_rich(c, s, x, y, font, color):
    for i, part in enumerate(s.split(">")):
        if i > 0:
            chevron(c, x, y, text_h(font), ARROW)
            x += NOTE_ARROW_W
        bits = part.split("*")
        for j in range(len(bits)):
            if j > 0:
                x = guest_dots(c, x, y, 1)
            if bits[j]:
                c.text(bits[j], x, y, font = font, color = color)
                x += c.text_width(bits[j], font)

def draw_tab(c, key, p, n):
    c.rect(0, 0, 10, 31, fill = TABS.get(key, "#888888"))
    if key == "BOB":
        letters = ["B", "O", "B"]
    elif key == "NOTE":
        letters = ["N", "O", "T", "E"]
    elif key == "E":
        letters = ["E"]
    else:
        letters = ["S", key]
    for i in range(len(letters)):
        c.text(letters[i], 5, 1 + i * 8, font = "5x7", color = "black", align = "center")
    if n > 1:
        for i in range(n):
            x = 5 - (n * 3 - 1) // 2 + i * 3
            c.rect(x, 29, x + 1, 30, fill = "black" if i + 1 == p else "white")

def draw_set(c, a):
    draw_tab(c, a["key"], a["p"], a["n"])
    marks = a.get("marks", {})
    font = a["font"]
    sp = c.text_width("A A", font) - c.text_width("AA", font)
    h = text_h(font)
    y = 0 if h == 7 else 1
    for line in a["lines"]:
        x = 14
        for kind, txt, chain, seg, stars in line:
            if kind == "badge":
                c.rect(x, y, x + BADGE_W - 1, y + h - 1, fill = TABS["E"])
                c.text("E", x + 1, y + (h - 5) // 2, font = "4x5", color = "black")
                x += BADGE_W + 2 * sp
                continue
            if kind == "tag":
                c.text(txt, x, y + h - 5, font = "4x5", color = TAG_COLOR)
                x += c.text_width(txt, "4x5") + 2 * sp
                continue
            c.text(txt, x, y, font = font, color = CHAIN_COLORS[chain % 2])
            if txt in marks:
                c.line(x, y + h, x + c.text_width(txt, font) - 2, y + h, MILESTONE_KINDS[marks[txt]][1])
            x += c.text_width(txt, font)
            x = guest_dots(c, x, y, stars)
            x += sp
            if seg:
                chevron(c, x, y, h, ARROW)
                x += 4 + sp
            elif kind == "song":
                x += sp
        y += a["lh"]

RELEASE_COLOR = "#FFE14D"

def release(show):
    # "RELEASED" when gdsets' notes say the show came out officially
    # ("released as Dick's Picks v. 5"), "PART RELEASED" when only some of
    # it did ("portions released as", "included on"); "" otherwise. The
    # notes page names the release.
    n = show["notes"].lower()
    i = n.find("released as")
    if i >= 0 and not n[:i].rstrip().endswith("portions"):
        return "RELEASED"
    if i >= 0 or "included on" in n:
        return "PART RELEASED"
    return ""

def draw_card(c, show, years_ago):
    y = show["y"]
    mm = int(show["date"][5:7])
    dd = int(show["date"][8:10])
    c.rect(0, 0, 191, 8, fill = era_color(show))
    c.text((show["dow"] + " " if show["dow"] else "") + MON[mm - 1] + " " + str(dd) + ", " + str(y), 2, 1, font = "5x7", color = "black")
    c.text(str(years_ago) + " YEARS AGO", 189, 1, font = "5x7", color = "black", align = "right")

    # "Greek Theatre / University Of California" -> two lines.
    v = show["venue"].upper()
    sub = ""
    sl = v.find(" / ")
    if sl >= 0:
        sub = v[sl + 3:]
        v = v[:sl]
    city = show["city"].upper()

    # An official release is tagged in gold at the venue line's right end.
    rel = release(show)
    if rel:
        c.text(rel, 189, 12, font = "4x5", color = RELEASE_COLOR, align = "right")
    room = 188 - (c.text_width(rel, "4x5") + 6 if rel else 0)
    if c.text_width(v, "5x7") <= room:
        c.text(v, 2, 11, font = "5x7", color = "white")
    else:
        c.text(fit_text(c, v, "4x5", room), 2, 12, font = "4x5", color = "white")

    # Third line: the guests in gold (Dylan still shows if the lookup
    # fails), or else a sub-venue. Either pushes the city to the last line.
    guests = guest_names(show)
    if not guests and show["dylan"]:
        guests = [("BOB DYLAN", GUEST_INSTRUMENT["bob dylan"])]
    if guests:
        c.text(guest_line(c, guests, 187), 2, 19, font = "4x5", color = GUEST_COLOR)
    elif sub:
        c.text(fit_text(c, sub, "4x5", 187), 2, 19, font = "4x5", color = "white")
    low = guests or sub

    # Bottom right: which show this was at the venue, "8TH OF 64 HERE";
    # the city sits beside it, in 5x7 when there's room, bottoms lined up.
    rank = venue_rank(show)
    label = ""
    if rank != None:
        k, n = rank
        label = "ONLY SHOW HERE" if n == 1 else ordinal(k) + " OF " + str(n) + " HERE"
    room = 189 - 6 - 2 - (c.text_width(label, "4x5") if label else 0)
    base = 26 if low else 23
    if not low and c.text_width(city, "5x7") <= room:
        c.text(city, 2, 21, font = "5x7", color = "#9CC8FF")
    else:
        c.text(fit_text(c, city, "4x5", room), 2, base, font = "4x5", color = "#9CC8FF")
    if label:
        c.text(label, 189, base, font = "4x5", color = "#888888", align = "right")

def draw_notes(c, show):
    draw_tab(c, "NOTE", 1, 1)
    lines = wrap_words(c, fix_titles(show["notes"].upper()), "4x5", 176, 5)
    for i in range(len(lines)):
        draw_rich(c, lines[i], 14, 1 + i * 6, "4x5", "white")

TIE_DYE = ["#FF3B3B", "#FF9F1C", "#FFE14D", "#3DDC84", "#3BA7FF", "#B36BFF"]

def ring(x, y):
    # Which tie-dye color a pixel gets: rippled rings out from the centre,
    # squashed to the panel's shape.
    dx = (x - 96) / 3.0
    dy = float(y - 16)
    r = math.sqrt(dx * dx + dy * dy)
    return int(math.floor((r + 1.2 * math.sin(math.atan2(dy, dx) * 8)) / 3.0)) % 6

def tie_dye(c):
    # Drawn as runs of one color per row, a few hundred rects in all.
    for y in range(32):
        start = 0
        cur = ring(0, y)
        for x in range(1, 193):
            k = ring(x, y) if x < 192 else -1
            if k != cur:
                c.rect(start, y, x - 1, y, fill = TIE_DYE[cur])
                start = x
                cur = k

def draw_intro(c):
    # Black letters over a tie-dye background; an original title card, not
    # a band logo.
    tie_dye(c)
    c.text("TODAY IN", 96, 4, font = "5x7", color = "black", align = "center")
    c.text("GRATEFUL DEAD HISTORY", 96, 15, font = "8x12", color = "black", align = "center")

def tour_milestone(show):
    # Joining/leaving colors and header note, from the shows either side
    # of this one that year; ({}, None) if the tour lookup fails.
    heads = year_heads(show)
    a = around(heads, show) if heads != None else None
    if a == None:
        return {}, None
    return milestone(show, a[1], a[2])

def set_length(show):
    # "23 SONGS IN 2 SETS + ENCORE" from the setlist; "" if there's none.
    n = 0
    sets = 0
    encores = 0
    for key, tags, songs in show["sets"]:
        n += len(songs)
        if key == "E":
            encores += 1
        else:
            sets += 1
    if n == 0:
        return ""
    t = str(n) + (" SONG" if n == 1 else " SONGS")
    if sets > 1:
        t += " IN " + str(sets) + " SETS"
    if encores == 1:
        t += " + ENCORE"
    elif encores > 1:
        t += " + " + str(encores) + " ENCORES"
    return t

# Where the tour page's values start, past its widest label ("PLAYED").
TOUR_COL = 34

def draw_tour(c, show):
    # Where this show falls on the year's tour, then its venue (first and
    # last Dead shows there; the card says how many) and, when the town saw
    # more Dead shows than this one venue, where it falls among them.
    heads = year_heads(show)
    a = around(heads, show) if heads != None else None
    c.text("ON TOUR IN " + str(show["y"]), 2, 1, font = "4x5", color = "#FFE14D")
    if a != None:
        c.text("SHOW " + str(a[0] + 1) + " OF " + str(len(heads)), 189, 1, font = "4x5", color = "#888888", align = "right")

    vh = venue_heads(show)
    town = city_rank(show)
    if town != None and vh != None and town[1] == len(vh):
        town = None
    length = set_length(show)
    rows = (1 if vh else 0) + (1 if town != None else 0) + (1 if length else 0)
    y = {0: 18, 1: 18, 2: 12, 3: 9}[rows]
    step = 9 if rows < 3 else 8

    # PLAYED  23 SONGS IN 2 SETS + ENCORE
    if length:
        c.text("PLAYED", 2, y, font = "4x5", color = "#888888")
        c.text(length, TOUR_COL, y, font = "4x5", color = "white")
        y += step

    # HERE  FIRST 10/2/87   LAST 6/4/95
    if vh:
        c.text("HERE", 2, y, font = "4x5", color = "#888888")
        if len(vh) == 1:
            c.text("THE ONLY GRATEFUL DEAD SHOW HERE", TOUR_COL, y, font = "4x5", color = "#3DDC84")
        else:
            x = TOUR_COL
            for label, h in [("FIRST ", vh[0]), ("LAST ", vh[-1])]:
                c.text(label, x, y, font = "4x5", color = "#888888")
                x += c.text_width(label, "4x5")
                c.text(slash_date(h["date"]), x, y, font = "4x5", color = "white")
                x += c.text_width("12/31/77", "4x5") + 8
        y += step

    # TOWN  127TH OF 142 IN NEW YORK
    if town != None:
        k, n = town
        c.text("TOWN", 2, y, font = "4x5", color = "#888888")
        c.text(ordinal(k) + " OF " + str(n) + " IN " + show["city"].split(", ")[0].upper(), TOUR_COL, y, font = "4x5", color = "white")

def day_num(date):
    return days_from_civil(int(date[0:4]), int(date[5:7]), int(date[8:10]))

def draw_around(c, show):
    # The two shows before and after this one that year, this one marked
    # in its era color. False if the tour lookup fails.
    heads = year_heads(show)
    a = around(heads, show) if heads != None else None
    if a == None:
        return False
    k = a[0]
    col = era_color(show)
    # Five rows, sliding at the year's ends so none are left blank.
    lo = max(0, min(k - 2, len(heads) - 5))
    y = 1
    for i in range(lo, lo + 5):
        if i >= 0 and i < len(heads):
            h = heads[i]
            me = i == k
            color = col if me else "white"
            if me:
                chevron(c, 1, y, 5, col)
            c.text(slash_date(h["date"]), 45, y, font = "4x5", color = color, align = "right")
            c.text(h["dow"], 49, y, font = "4x5", color = color if me else "#888888")
            place = h["venue"].split(" / ")[0] + (", " + h["city"].split(", ")[0] if h["city"] else "")
            place = place.upper()
            c.text(fit_text(c, place, "4x5", 123), 66, y, font = "4x5", color = color)
        y += 6
    return True

def nearest_set(show):
    # The closest show that year with a setlist, within two weeks; one at
    # the same venue wins, then the nearer, then the earlier. None if none.
    me = day_num(show["date"])
    best = None
    for s in year_shows(show):
        if not s["sets"] or s["date"] == show["date"]:
            continue
        gap = abs(day_num(s["date"]) - me)
        if gap > 14:
            continue
        key = (0 if s["venue"] == show["venue"] else 1, gap, s["date"] > show["date"])
        if best == None or key < best[0]:
            best = (key, s)
    return best[1] if best != None else None

def draw_nearest(c, show):
    # A nearby show's setlist in small text, all its sets run together, as
    # a taste of what the band was playing then. False if there's none.
    s = nearest_set(show)
    if s == None:
        return False
    songs = []
    for key, tags, ss in s["sets"]:
        songs += ss
    lines = layout(c, [], songs, "4x5", False, False)
    if len(lines) > 4:
        lines = layout(c, [], songs, "4x5", False, True)

    # Songs past the fourth line are counted in the header ("+9 MORE").
    shown = 0
    for line in lines[:4]:
        for kind, txt, chain, seg, stars in line:
            if kind == "song":
                shown += 1
    more = "+" + str(len(songs) - shown) + " MORE" if len(songs) > shown else ""
    head = ("NEARBY: " if show["sets"] else "NO SETLIST - NEAREST: ") + slash_date(s["date"]) + " " + s["venue"].split(" / ")[0].upper()
    c.rect(0, 0, 191, 6, fill = "#333333")
    room = 188 - (c.text_width(more, "4x5") + 6 if more else 0)
    c.text(fit_text(c, head, "4x5", room), 2, 1, font = "4x5", color = "#FFE14D")
    if more:
        c.text(more, 189, 1, font = "4x5", color = "#888888", align = "right")
    sp = c.text_width("A A", "4x5") - c.text_width("AA", "4x5")
    y = 8
    for line in lines[:4]:
        x = 2
        for kind, txt, chain, seg, stars in line:
            c.text(txt, x, y, font = "4x5", color = CHAIN_COLORS[chain % 2])
            x += c.text_width(txt, "4x5")
            x = guest_dots(c, x, y, stars)
            x += sp
            if seg:
                chevron(c, x, y, 5, ARROW)
                x += 4 + sp
            elif kind == "song":
                x += sp
        y += 6
    return True

def draw_top_songs(c, show):
    # The year's eight most-played songs, each counted once a show, over
    # the shows with a known setlist. False if there are none.
    counts = {}
    n = 0
    for s in year_shows(show):
        if not s["sets"]:
            continue
        n += 1
        seen = {}
        for key, tags, ss in s["sets"]:
            for name, seg, stars in ss:
                nm = fix_titles(name.upper())
                if nm not in seen and nm not in NOT_SONGS:
                    seen[nm] = True
                    counts[nm] = counts.get(nm, 0) + 1
    if not counts:
        return False
    top = sorted(counts.items(), key = lambda kv: -kv[1])[:8]
    c.text("TOP SONGS OF " + str(show["y"]), 2, 1, font = "4x5", color = "#FFE14D")
    c.text("IN " + str(n) + " KNOWN SETLISTS", 189, 1, font = "4x5", color = "#888888", align = "right")
    for i in range(len(top)):
        nm, k = top[i]
        x = 2 if i < 4 else 98
        y = 8 + (i % 4) * 6
        c.text(str(k), x + 12, y, font = "4x5", color = "#9CC8FF", align = "right")
        c.text(fit_text(c, SHORT.get(nm, nm), "4x5", 78), x + 16, y, font = "4x5", color = "white")
    return True

def commas(n):
    t = str(n)
    return t if len(t) <= 3 else t[:-3] + "," + t[-3:]

# Milestone page text sizes, biggest first: (font, line height). The
# smallest also takes the overflow.
MILESTONE_FONTS = [("5x7", 9), ("4x7", 8), ("4x5", 6)]

def milestone_rows(c, ms, font):
    # [(label, color, text, small?)] for the page at this font: each kind's
    # songs wrapped beside its label, and under each bust-out a small grey
    # line saying when it was last played (or, for the rarest song, how
    # often it was played at all). Also the songs' left edge, and
    # whether every song fit whole on its line.
    kinds = [k for k in ["D", "K", "O", "B", "L", "R"] if [m for m in ms if m[0] == k]]
    x0 = max([c.text_width(MILESTONE_KINDS[k][0], font) for k in kinds]) + 6
    room = 189 - x0
    rows = []
    ok = True
    for k in kinds:
        label, color = MILESTONE_KINDS[k]
        songs = [m for m in ms if m[0] == k]
        if k == "B" or k == "R":
            for m in songs:
                t = fix_titles(m[1])
                ok = ok and c.text_width(t, font) <= room
                rows.append((label, color, t, False))
                if k == "B":
                    rows.append(("", color, "LAST " + slash_date(m[2]) + ", " + commas(m[3]) + " SHOWS AGO", True))
                else:
                    rows.append(("", color, "PLAYED " + str(m[3]) + " TIMES IN ALL", True))
            continue
        line = ""
        first = True
        for m in songs:
            t = fix_titles(m[1])
            ok = ok and c.text_width(t + ",", font) <= room
            if line and c.text_width(line + ", " + t + ",", font) > room:
                rows.append((label if first else "", color, line + ",", False))
                first = False
                line = t
            else:
                line = line + ", " + t if line else t
        if line:
            rows.append((label if first else "", color, line, False))
    return rows, x0, ok

def rows_height(rows, font, lh):
    # Pixels from the top of the first row's text to the bottom of the last.
    h = 0
    for r in rows:
        h += 6 if r[3] else lh
    return h - (1 if rows[-1][3] else lh - text_h(font))

def draw_milestones(c, show):
    # The biggest text that fits every row whole; the grey notes stay
    # small. When nothing fits, the grey notes go before any song,
    # and failing that, rows past the bottom are cut with "...".
    ms = milestones(show)
    fit = None
    for dates in [True, False]:
        for font, lh in MILESTONE_FONTS:
            rows, x0, ok = milestone_rows(c, ms, font)
            if not dates:
                rows = [r for r in rows if not r[3]]
            if fit == None and ok and rows_height(rows, font, lh) <= 31:
                fit = (rows, x0, font, lh)
    if fit == None:
        for i in range(len(rows) - 1):
            if rows_height(rows, font, lh) > 31:
                rows = rows[:-1]
        last = rows[-1]
        rows[-1] = (last[0], last[1], last[2] + " ...", last[3])
        fit = (rows, x0, font, lh)
    rows, x0, font, lh = fit
    height = rows_height(rows, font, lh)
    y = (32 - height) // 2
    for label, color, text, small in rows:
        if small:
            if c.text_width(text, "4x5") > 189 - x0:
                text = text.replace(" AGO", "")
            c.text(fit_text(c, text, "4x5", 189 - x0), x0, y, font = "4x5", color = "#888888")
            y += 6
            continue
        if label:
            c.text(label, 2, y, font = font, color = color)
        c.text(fit_text(c, text, font, 189 - x0), x0, y, font = font, color = "white")
        y += lh

def draw_band_page(c, show):
    # Who played, big: the night's lineup in 5x7 under the era's name, each
    # with their age in small grey type, centred, wrapped as needed.
    # Anyone joining (green) or leaving (red) is called out in the header,
    # or else a birthday; a fill-in shows in orange.
    colors, note = tour_milestone(show)
    members = band(show)
    if note == None:
        bday = birthday_note(show, members)
        if bday != None:
            note = (bday, "#FFE14D")
    # The era's name heads the page in its color, keying the card's bar.
    c.text(ERA_NAMES[era_key(show)], 2, 1, font = "4x5", color = era_color(show))
    if note != None:
        c.text(note[0], 189, 1, font = "4x5", color = note[1], align = "right")
    if not members:
        c.text("LINEUP UNKNOWN", 96, 14, font = "5x7", color = "#555555", align = "center")
        return
    gap = 8

    def member_w(m):
        a = age_on(m, show["date"])
        return c.text_width(m, "5x7") + (2 + c.text_width(str(a), "4x5") if a >= 0 else 0)

    lines = [[]]
    w = 0
    for m, col in members:
        mw = member_w(m)
        if lines[-1] and w + gap + mw > 188:
            lines.append([])
            w = 0
        w += (gap if lines[-1] else 0) + mw
        lines[-1].append((m, col))
    step = 10 if len(lines) <= 2 else 8
    y = (32 + 7 - len(lines) * step) // 2 + 1
    for line in lines:
        lw = gap * (len(line) - 1)
        for m, col in line:
            lw += member_w(m)
        x = (192 - lw) // 2
        for m, col in line:
            c.text(m, x, y, font = "5x7", color = colors.get(m, col))
            a = age_on(m, show["date"])
            if a >= 0:
                c.text(str(a), x + c.text_width(m, "5x7") + 2, y + 2, font = "4x5", color = "#888888")
            x += member_w(m) + gap
        y += step

def draw_final(c, show):
    # Soldier Field, 7/9/95: the last Grateful Dead show and its last song.
    c.text("THE FINAL SHOW", 96, 2, font = "10x14", color = era_color(show), align = "center")
    if show["sets"]:
        last = show["sets"][-1][2][-1][0].upper()
        c.text("LAST SONG: " + fix_titles(last), 96, 19, font = "4x5", color = "white", align = "center")
    c.text("JERRY GARCIA DIED A MONTH LATER, 8/9/95", 96, 26, font = "4x5", color = "#888888", align = "center")

def draw_splash(c, show, years_ago):
    t = str(years_ago) + " YEARS AGO"
    c.text(t, 96, 3, font = "10x14", color = era_color(show), align = "center")
    mm = int(show["date"][5:7])
    line = MON[mm - 1] + " " + str(int(show["date"][8:10])) + ", " + str(show["y"]) + "  " + show["city"].upper()
    c.text(fit_text(c, line, "5x7", 188), 96, 22, font = "5x7", color = "white", align = "center")

# Text page sizes, biggest first: (font, line height).
PAGE_FONTS = [("5x7", 8), ("4x7", 8), ("4x5", 6)]

def draw_text_page(c, head, body):
    # A gold heading over the text at the biggest size that fits.
    c.text(head, 2, 1, font = "4x5", color = "#FFE14D")
    for font, lh in PAGE_FONTS:
        lines = wrap_words(c, body, font, 188, 99)
        if 8 + (len(lines) - 1) * lh + text_h(font) <= 32 or font == "4x5":
            break
    lines = lines[:(32 - 8) // lh + 1]
    y = 8 + (32 - 8 - ((len(lines) - 1) * lh + text_h(font))) // 2
    for line in lines:
        c.text(line, 2, y, font = font, color = "white")
        y += lh

# For the four dates the band never played (1/9, 1/19, 2/29, 12/25): the
# band, the people around it, landmark shows and records, the scene, and
# the whole run by gdsets' numbers. Each hour shows a different seven.
DAY_OFF_PAGES = [
    ("BOB WEIR", "RHYTHM GUITAR AND VOCALS. HE JOINED AT 17, THE YOUNGEST IN THE BAND"),
    ("PHIL LESH", "BASS. A CLASSICALLY TRAINED TRUMPET PLAYER WHO LEARNED BASS TO JOIN THE BAND IN 1965"),
    ("PIGPEN", "RON MCKERNAN: ORGAN, HARMONICA AND THE BLUES. HE DIED IN 1973 AT 27"),
    ("BILL KREUTZMANN", "DRUMS, FROM THE FIRST SHOW TO THE LAST"),
    ("MICKEY HART", "THE SECOND DRUMMER FROM 1967, AWAY 1971-74. HIS PLANET DRUM WON THE FIRST GRAMMY FOR BEST WORLD MUSIC ALBUM"),
    ("TOM CONSTANTEN", "KEYS 1968-70. AN AVANT-GARDE COMPOSER WHO HAD STUDIED WITH STOCKHAUSEN"),
    ("KEITH & DONNA", "KEITH AND DONNA JEAN GODCHAUX, A MARRIED COUPLE ON KEYS AND VOCALS IN THE 1970S"),
    ("BRENT MYDLAND", "KEYS AND VOCALS 1979-90, THE LONGEST-SERVING KEYBOARD PLAYER IN THE BAND"),
    ("VINCE & BRUCE", "VINCE WELNICK, LATE OF THE TUBES, ON KEYS 1990-95. BRUCE HORNSBY ON PIANO AND ACCORDION 1990-92"),
    ("ROBERT HUNTER", "THE BAND'S LYRICIST: HE WROTE THE WORDS TO MOST OF JERRY'S SONGS, FROM DARK STAR TO TOUCH OF GREY"),
    ("JOHN PERRY BARLOW", "WROTE THE WORDS TO BOB WEIR'S CASSIDY, MEXICALI BLUES AND ESTIMATED PROPHET"),
    ("OWSLEY STANLEY", "BEAR: THE EARLY SOUNDMAN WHOSE TAPES ARE STILL BEING RELEASED. HE DESIGNED THE STEAL YOUR FACE SKULL WITH BOB THOMAS"),
    ("THE WALL OF SOUND", "THE 1974 SOUND SYSTEM: HUNDREDS OF SPEAKERS STACKED BEHIND THE BAND, NO MONITORS NEEDED"),
    ("THE TAPERS", "FROM LATE 1984 FANS COULD RECORD SHOWS FROM THEIR OWN SECTION BEHIND THE SOUNDBOARD"),
    ("BETTY CANTOR-JACKSON", "RECORDING ENGINEER. HER 1970S SOUNDBOARD TAPES, THE BETTY BOARDS, ARE PRIZED BY TAPERS"),
    ("DICK LATVALA", "THE BAND'S TAPE ARCHIVIST FROM 1985. THE DICK'S PICKS SERIES IS NAMED FOR HIM"),
    ("CANDACE BRIGHTMAN", "THE BAND'S LIGHTING DESIGNER FROM THE EARLY 1970S TO THE END"),
    ("BILL GRAHAM", "PROMOTER FROM THE FILLMORE DAYS ON. AT NEW YEAR'S HE OFTEN MADE HIS ENTRANCE AS FATHER TIME"),
    ("BY THE NUMBERS", "2,307 SHOWS FROM 1965 TO 1995, AT 583 VENUES IN 310 TOWNS. THE BUSIEST YEAR WAS 1970, WITH 134"),
    ("MOST PLAYED", "ME & MY UNCLE 636 TIMES, SUGAR MAGNOLIA 605, THE OTHER ONE 603, PLAYIN' IN THE BAND 592"),
    ("HOME TURF", "322 SHOWS IN SAN FRANCISCO. THE MOST AT ONE VENUE: OAKLAND COLISEUM ARENA, 66, THEN WINTERLAND, 62"),
    ("THE WARLOCKS", "THE BAND'S FIRST NAME, IN 1965. THEY BECAME THE GRATEFUL DEAD LATE THAT YEAR ON FINDING ANOTHER BAND ALREADY HAD IT"),
    ("THE NAME", "JERRY FOUND GRATEFUL DEAD IN A DICTIONARY: A FOLK TALE OF A DEAD MAN'S SPIRIT REPAYING WHOEVER PAID FOR HIS BURIAL"),
    ("THE ACID TESTS", "KEN KESEY AND THE MERRY PRANKSTERS' PARTIES OF 1965-66, WITH THE DEAD AS THE HOUSE BAND"),
    ("710 ASHBURY", "THE BAND'S HOUSE IN SAN FRANCISCO'S HAIGHT-ASHBURY FROM 1966, RAIDED BY POLICE IN OCTOBER 1967"),
    ("MONTEREY POP", "THE DEAD PLAYED THE MONTEREY INTERNATIONAL POP FESTIVAL IN JUNE 1967"),
    ("WOODSTOCK", "AUGUST 1969, IN THE RAIN. THE STAGE WAS SO WET THEIR GEAR GAVE THEM SHOCKS, AND THEY RATED THEIR OWN SET A FLOP"),
    ("ALTAMONT", "BOOKED FOR THE DECEMBER 1969 FREE CONCERT, THEY LEFT WITHOUT PLAYING AFTER THE VIOLENCE. NEW SPEEDWAY BOOGIE IS ABOUT THAT DAY"),
    ("LIVE/DEAD", "THE 1969 LIVE ALBUM THAT OPENS WITH A 23-MINUTE DARK STAR"),
    ("1970", "WORKINGMAN'S DEAD AND AMERICAN BEAUTY, BOTH OUT THAT YEAR, TRADED PSYCHEDELIA FOR HARMONIES AND COUNTRY SONGS"),
    ("SKULL & ROSES", "THE 1971 LIVE ALBUM. KELLEY AND MOUSE TOOK ITS COVER FROM AN OLD EDITION OF THE RUBAIYAT OF OMAR KHAYYAM"),
    ("DEAD FREAKS UNITE", "SKULL & ROSES ASKED FANS TO MAIL IN THEIR ADDRESSES - THE START OF THE BAND'S MAILING LIST"),
    ("EUROPE '72", "THE SPRING 1972 TOUR OF EUROPE, RELEASED AS A TRIPLE LIVE ALBUM"),
    ("DANCING BEARS", "DRAWN BY BOB THOMAS FOR THE BACK OF 1973'S BEAR'S CHOICE, AN ALBUM OF OWSLEY'S TAPES"),
    ("GRATEFUL DEAD RECORDS", "IN 1973 THE BAND STARTED ITS OWN LABEL. WAKE OF THE FLOOD WAS THE FIRST RELEASE"),
    ("TOUCH OF GREY", "THEIR ONLY TOP 10 HIT, IN 1987. THE VIDEO HAS LIFE-SIZE SKELETON PUPPETS PLAYING THE BAND"),
    ("DYLAN & THE DEAD", "THE BAND BACKED BOB DYLAN ON A SUMMER 1987 STADIUM TOUR"),
    ("WATKINS GLEN", "JULY 28, 1973: THE SUMMER JAM WITH THE ALLMAN BROTHERS AND THE BAND, FOR ABOUT 600,000 PEOPLE"),
    ("THE HIATUS", "AFTER OCTOBER 1974 THE BAND STOPPED TOURING UNTIL JUNE 1976, PLAYING JUST FOUR SHOWS IN 1975"),
    ("THE MOVIE", "THE GRATEFUL DEAD MOVIE WAS FILMED AT WINTERLAND IN OCTOBER 1974. JERRY CO-DIRECTED IT, AND IT CAME OUT IN 1977"),
    ("CORNELL", "5/8/77 AT BARTON HALL IN ITHACA, OFTEN CALLED THEIR BEST SHOW. IT'S IN THE LIBRARY OF CONGRESS NATIONAL RECORDING REGISTRY"),
    ("EGYPT", "SEPTEMBER 1978: THREE SHOWS BY THE GREAT PYRAMID, THE LAST DURING A TOTAL LUNAR ECLIPSE"),
    ("WINTERLAND", "THE DEAD CLOSED WINTERLAND ON NEW YEAR'S EVE 1978, WITH THE BLUES BROTHERS OPENING"),
    ("NEW YEAR'S EVE", "22 NEW YEAR'S EVE SHOWS, SIX EACH AT WINTERLAND AND THE OAKLAND COLISEUM ARENA"),
    ("THE WARFIELD", "15 NIGHTS AT SAN FRANCISCO'S WARFIELD THEATRE IN 1980, WITH ACOUSTIC SETS, BECAME RECKONING AND DEAD SET"),
    ("SUNSHINE DAYDREAM", "THE FILM OF 8/27/72 IN VENETA, OREGON, A BENEFIT FOR THE KESEY FAMILY'S SPRINGFIELD CREAMERY"),
    ("AROUND THE WORLD", "BEYOND THE US AND CANADA: ENGLAND, SCOTLAND, FRANCE, GERMANY, THE NETHERLANDS, DENMARK, SWEDEN, SPAIN, LUXEMBOURG, EGYPT AND JAMAICA"),
    ("PIGPEN'S LAST SHOW", "JUNE 17, 1972, AT THE HOLLYWOOD BOWL"),
    ("KEITH GODCHAUX", "LEFT THE BAND IN 1979 AND DIED IN A CAR ACCIDENT IN 1980"),
    ("BRENT", "BRENT MYDLAND DIED IN JULY 1990, AT 37, AFTER 11 YEARS IN THE BAND"),
    ("THE RHYTHM DEVILS", "BILLY AND MICKEY'S PERCUSSION DUO. THEY PLAYED ON THE APOCALYPSE NOW SOUNDTRACK"),
    ("THE BEAM", "MICKEY'S METAL BEAM STRUNG WITH PIANO STRINGS, A STAPLE OF SPACE"),
    ("''RAM ROD''", "LARRY SHURTLIFF, THE BAND'S HEAD ROADIE FROM 1967, AND PRESIDENT OF GRATEFUL DEAD PRODUCTIONS 1976-95"),
    ("SCULLY & RIFKIN", "ROCK SCULLY AND DANNY RIFKIN, THE BAND'S MANAGERS IN THE HAIGHT-ASHBURY DAYS"),
    ("DAN HEALY", "THE BAND'S LIVE SOUND ENGINEER FROM THE LATE 1960S UNTIL 1993"),
    ("CHERRY GARCIA", "BEN & JERRY'S NAMED AN ICE CREAM FOR JERRY IN 1987"),
    ("J. GARCIA TIES", "JERRY'S PAINTINGS BECAME A POPULAR LINE OF NECKTIES IN THE 1990S"),
    ("DEADHEADS", "THE FANS WHO FOLLOWED THE BAND, MANY OF THEM TOUR TO TOUR"),
    ("SHAKEDOWN STREET", "THE PARKING-LOT MARKET OUTSIDE SHOWS, NAMED FOR THE 1978 SONG AND ALBUM"),
    ("MIRACLE TICKETS", "A FREE TICKET FOR A FAN OUTSIDE HOLDING UP ONE FINGER, AFTER THE SONG I NEED A MIRACLE"),
    ("MAIL ORDER", "THE BAND SOLD MANY OF ITS OWN TICKETS BY MAIL, AND FANS DECORATED THE ENVELOPES"),
    ("HALL OF FAME", "INDUCTED INTO THE ROCK AND ROLL HALL OF FAME IN 1994, AND GIVEN A LIFETIME ACHIEVEMENT GRAMMY IN 2007"),
    ("FARE THEE WELL", "IN 2015 THE FOUR SURVIVING CORE MEMBERS PLAYED FIVE FAREWELL SHOWS FOR THE 50TH ANNIVERSARY"),
    ("DEAD & COMPANY", "BOBBY, MICKEY AND BILLY WITH JOHN MAYER, FROM 2015"),
    ("THE OPENERS", "MOST OFTEN FIRST: JACK STRAW 195 TIMES, BERTHA 159, PROMISED LAND 130, HELL IN A BUCKET 123"),
    ("DARK STAR", "PLAYED 234 TIMES, FROM 1967 TO 1994"),
    ("THE LONGEST WAIT", "LOUIE LOUIE WENT 1,586 SHOWS WITHOUT BEING PLAYED, FROM 1967 TO 1988"),
    ("THE SONGBOOK", "448 DIFFERENT SONGS IN THE KNOWN SETLISTS"),
    ("BIG ROOMS", "AFTER OAKLAND AND WINTERLAND: THE SPECTRUM IN PHILADELPHIA, 53 SHOWS, AND MADISON SQUARE GARDEN, 52"),
]

def draw_day_off(c, ctx, page, m, d, day):
    # Page 1 says so; the rest are seven DAY_OFF_PAGES, a fresh seven each
    # hour from a daily shuffle.
    if page == 1:
        draw_message(c, "NO SHOWS ON " + MON[m - 1] + " " + str(d), "THE BAND HAD THE DAY OFF")
        return
    n = len(DAY_OFF_PAGES)
    order = sorted(range(n), key = lambda k: scramble(day * 64 + k))
    head, body = DAY_OFF_PAGES[order[((ctx.now.unix // 3600) * 7 + page - 2) % n]]
    draw_text_page(c, head, body)

# The band and its family, by the date each died: (name, born, died, what
# they did). On that date each joins the hourly shuffle as one more entry:
# the title page, a memorial page, then the six TRIBUTES pages. Aug 9 has
# no shows, so it's all Jerry's. A name in quotes is a nickname.
MEMORIALS = {
    "08-09": [("JERRY GARCIA", "1942-08-01", "1995-08-09", "LEAD GUITAR AND VOCALS, 1965-95")],
    "03-08": [("PIGPEN", "1945-09-08", "1973-03-08", "RON MCKERNAN: ORGAN, HARMONICA, 1965-72")],
    "07-23": [("KEITH GODCHAUX", "1948-07-19", "1980-07-23", "KEYS, 1971-79")],
    "07-26": [("BRENT MYDLAND", "1952-10-21", "1990-07-26", "KEYS AND VOCALS, 1979-90")],
    "06-02": [("VINCE WELNICK", "1951-02-21", "2006-06-02", "KEYS AND VOCALS, 1990-95")],
    "10-25": [("PHIL LESH", "1940-03-15", "2024-10-25", "BASS, 1965-95"),
              ("BILL GRAHAM", "1931-01-08", "1991-10-25", "PROMOTER, FROM THE FILLMORE ON")],
    "11-02": [("DONNA JEAN GODCHAUX", "1947-08-22", "2025-11-02", "VOCALS, 1972-79")],
    "01-10": [("BOB WEIR", "1947-10-16", "2026-01-10", "RHYTHM GUITAR AND VOCALS, 1965-95")],
    "09-23": [("ROBERT HUNTER", "1941-06-23", "2019-09-23", "LYRICIST")],
    "02-07": [("JOHN PERRY BARLOW", "1947-10-03", "2018-02-07", "LYRICIST")],
    "03-12": [("OWSLEY STANLEY", "1935-01-19", "2011-03-12", "BEAR - SOUNDMAN AND TAPER")],
    "11-10": [("KEN KESEY", "1935-09-17", "2001-11-10", "AUTHOR, AND HOST OF THE ACID TESTS")],
    "05-27": [("BILL WALTON", "1952-11-05", "2024-05-27", "HALL OF FAMER WHO SAW OVER 850 SHOWS")],
    "12-16": [("ROCK SCULLY", "1941-08-01", "2014-12-16", "THE BAND'S MANAGER, 1965-85")],
    "09-05": [("REX JACKSON", "1945-10-27", "1976-09-05", "ROADIE AND ROAD MANAGER")],
    "05-30": [("JOHN KAHN", "1947-06-13", "1996-05-30", "BASS, JERRY GARCIA BAND")],
    "10-24": [("MERL SAUNDERS", "1934-02-14", "2008-10-24", "HAMMOND ORGAN, WITH JERRY FROM 1971")],
    "06-29": [("ROB WASSERMAN", "1952-04-01", "2016-06-29", "BASS, CO-FOUNDER OF RATDOG")],
    "05-17": [('"RAM ROD"', "1945-04-19", "2006-05-17", "LARRY SHURTLIFF, HEAD ROADIE")],
}

def draw_memorial(c, who, year):
    # The name big, what they did, and their dates.
    name, born, died, role = who

    # A nickname comes in quotes, drawn as ticks: the big fonts have none.
    quoted = name.startswith('"')
    name = name.strip('"')
    q = 9 if quoted else 0
    for font, y in [("10x14", 1), ("8x12", 3), ("5x7", 6)]:
        if c.text_width(name, font) + 2 * q <= 188:
            break
    w = c.text_width(name, font)
    x = (192 - w) // 2
    c.text(name, x, y, font = font, color = "white")
    if quoted:
        for qx in [x - q, x + w + 2]:
            c.rect(qx, y, qx + 1, y + 3, fill = "white")
            c.rect(qx + 4, y, qx + 5, y + 3, fill = "white")
    c.text(role, 96, 18, font = "4x5", color = "#9CC8FF", align = "center")
    ago = year - int(died[0:4])
    when = (slash_date(born) + " - " + slash_date(died)) if born else "DIED " + slash_date(died)
    if ago > 0:
        when += ", " + str(ago) + (" YEAR" if ago == 1 else " YEARS") + " AGO TODAY"
    c.text(when, 96, 26, font = "4x5", color = "#888888", align = "center")

def draw_tribute(c, who, page, year):
    if page == 1:
        draw_intro(c)
    elif page == 2:
        draw_memorial(c, who, year)
    else:
        head, body = TRIBUTES[who[0].strip('"')][page - 3]
        draw_text_page(c, head, body)

def draw_message(c, a, b):
    c.text(a, 96, 9, font = "5x7", color = "#888888", align = "center")
    c.text(b, 96, 20, font = "4x5", color = "#555555", align = "center")

# ---------------------------------------------------------------- pages

def render(c, ctx, page):
    c.clear()
    y, m, d = eastern_today(ctx)
    shows = fetch_shows(m, d)
    tributes = MEMORIALS.get(str(m + 100)[1:] + "-" + str(d + 100)[1:], [])
    if shows == None:
        # gdsets is down: the date's tributes need no data; otherwise say
        # so, then the day-off pages.
        if tributes:
            pick = rotation_index(ctx, len(tributes), days_from_civil(y, m, d))
            draw_tribute(c, tributes[pick], page, y)
        elif page == 1:
            draw_message(c, "DATA UNAVAILABLE", "GDSETS.COM DID NOT ANSWER")
        else:
            draw_day_off(c, ctx, page, m, d, days_from_civil(y, m, d))
        return
    if not shows and not tributes:
        draw_day_off(c, ctx, page, m, d, days_from_civil(y, m, d))
        return
    pick = rotation_index(ctx, len(shows) + len(tributes), days_from_civil(y, m, d))
    if pick >= len(shows):
        draw_tribute(c, tributes[pick - len(shows)], page, y)
        return
    pages = plan(c, shows[pick])
    kind, a = pages[page - 1]
    if kind == "card":
        draw_card(c, a, y - a["y"])
    elif kind == "set":
        draw_set(c, a)
    elif kind == "notes":
        draw_notes(c, a)
    elif kind == "tour":
        draw_tour(c, a)
    elif kind == "band":
        draw_band_page(c, a)
    elif kind == "milestones":
        draw_milestones(c, a)
    elif kind == "final":
        draw_final(c, a)
    elif kind in FILLERS:
        filled = {"around": draw_around, "nearest": draw_nearest, "topsongs": draw_top_songs}[kind](c, a)
        if not filled:
            c.clear()
            draw_splash(c, a, y - a["y"])
    elif kind == "intro":
        draw_intro(c)
    else:
        draw_splash(c, a, y - a["y"])

def page1(c, ctx):
    render(c, ctx, 1)

def page2(c, ctx):
    render(c, ctx, 2)

def page3(c, ctx):
    render(c, ctx, 3)

def page4(c, ctx):
    render(c, ctx, 4)

def page5(c, ctx):
    render(c, ctx, 5)

def page6(c, ctx):
    render(c, ctx, 6)

def page7(c, ctx):
    render(c, ctx, 7)

def page8(c, ctx):
    render(c, ctx, 8)

# Song milestones by show date, worked out once from gdsets' full
# history (it can't change). Items split on "|", each a kind letter and
# the song: D debut, K first known (a setlist is missing just before it),
# O only time played, L last time (retired with 25+ shows still to go), and
# B a bust-out: "B" + the date last played (YYYYMMDD) + shows since then
# (four digits) + the song, for a gap of 100 or more shows. It sits at
# the end of the file to keep it out of the way.
MILESTONES = {
    "1966-01-07": "OI'LL GO CRAZY|OCAN'T COME DOWN|OPARCHMAN FARM|OTHE ONLY TIME IS NOW|KIT'S A SIN|KSICK & TIRED|KMINDBENDER|KON THE ROAD AGAIN|KSHE BELONGS TO ME|KDEATH DON'T HAVE NO MERCY|KMIDNIGHT HOUR|KEARLY MORNING RAIN|KIT'S ALL OVER NOW BABY BLUE",
    "1966-01-08": "KI'M A KING BEE|KI'M A HOG FOR YOU|KCAUTION DO NOT STOP ON TRACKS",
    "1966-01-13": "OALL OF MY LOVE",
    "1966-01-28": "KYOU DON'T HAVE TO ASK|KVIOLA LEE BLUES|KI KNOW YOU RIDER",
    "1966-03-12": "OYOU SEE A BROKEN HEART|OHEADS UP|KONE KIND FAVOR|KBEAT IT ON DOWN THE LINE|KNEXT TIME YOU SEE ME",
    "1966-03-25": "KSTEALIN'|KHEY LITTLE ONE|KCOLD RAIN & SNOW",
    "1966-04-22": "KGOOD MORNING LITTLE SCHOOLGIRL|KYOU DON'T LOVE ME",
    "1966-05-19": "KSTANDING ON THE CORNER|KIT HURTS ME TOO|KCREAM PUFF WAR|KSITTIN' ON TOP OF THE WORLD|KMINGLEWOOD BLUES|KTASTEBUD|KSILVER THREADS & GOLDEN NEEDLES|KGOOD LOVIN'|LSICK & TIRED|LMINDBENDER",
    "1966-06-01": "KDON'T EASE ME IN|KCARDBOARD COWBOY",
    "1966-07-03": "ODON'T MESS UP A GOOD THING|OGANGSTER OF LOVE|KNOBODY'S FAULT BUT MINE|KDANCIN' IN THE STREETS|KHE WAS A FRIEND OF MINE|KBIG BOSS MAN|KKEEP ROLLING BY|LTASTEBUD",
    "1966-07-16": "OIN THE PINES|KPAIN IN MY HEART",
    "1966-07-17": "LKEEP ROLLING BY",
    "1966-07-29": "LSTANDING ON THE CORNER|LCARDBOARD COWBOY",
    "1966-07-30": "LYOU DON'T HAVE TO ASK|LHEY LITTLE ONE",
    "1966-10-06": "KALICE D. MILLIONAIRE",
    "1966-11-18": "KTHE SAME THING",
    "1966-11-19": "KHI-HEEL SNEAKERS|KSMOKESTACK LIGHTNING|LPAIN IN MY HEART",
    "1966-11-29": "KME & MY UNCLE|KBIG BOY PETE|KDOWN SO LONG|KSOMETHING ON YOUR MIND|KLINDY|KI JUST WANNA MAKE LOVE TO YOU|LEARLY MORNING RAIN|LSTEALIN'",
    "1966-12-01": "OBETTY & DUPREE|OLOOK ON YONDER WALL|OIT'S MY OWN FAULT|KDEEP ELEM BLUES|LONE KIND FAVOR|LYOU DON'T LOVE ME|LALICE D. MILLIONAIRE|LDOWN SO LONG|LSOMETHING ON YOUR MIND",
    "1967-03-18": "KMORNING DEW|KTHE GOLDEN ROAD|LCREAM PUFF WAR",
    "1967-04-09": "KGLORIA",
    "1967-05-18": "KLOUIE LOUIE",
    "1967-06-01": "KALLIGATOR|KTURN ON YOUR LOVELIGHT",
    "1967-08-04": "KNEW POTATO CABOOSE|LLINDY",
    "1967-08-05": "KCRYPTICAL ENVELOPMENT|KTHE OTHER ONE",
    "1967-09-29": "LTHE GOLDEN ROAD",
    "1967-11-14": "KBORN CROSS-EYED|KDARK STAR",
    "1968-01-17": "KCHINA CAT SUNFLOWER|KTHE ELEVEN",
    "1968-01-20": "KCLEMENTINE",
    "1968-03-16": "KAND WE BID YOU GOODNIGHT",
    "1968-06-01": "LBORN CROSS-EYED",
    "1968-06-07": "KST. STEPHEN",
    "1968-12-07": "OROSEMARY",
    "1968-12-20": "KMOUNTAINS OF THE MOON",
    "1969-01-17": "KCOSMIC CHARLIE",
    "1969-01-24": "KDUPREE'S DIAMOND BLUES|KDOIN' THAT RAG",
    "1969-01-26": "LCLEMENTINE",
    "1969-02-11": "KHEY JUDE",
    "1969-02-19": "KNOT FADE AWAY|KTHE MAIN TEN",
    "1969-03-15": "KHARD TO HANDLE",
    "1969-04-26": "OWHAT'S BECOME OF THE BABY",
    "1969-05-31": "OYELLOW DOG STORY|KGREEN GREEN GRASS OF HOME",
    "1969-06-06": "OCHECKIN' UP",
    "1969-06-07": "KDIRE WOLF",
    "1969-06-08": "OTHE THINGS I USED TO DO|OWHO'S LOVING YOU TONIGHT|LNEW POTATO CABOOSE",
    "1969-06-20": "OOLD OLD HOUSE|KCOLD JORDAN|KCASEY JONES|KMAMA TRIED|KHIGH TIME",
    "1969-06-21": "KSLEWFOOT",
    "1969-07-04": "DLET ME IN 83968",
    "1969-07-12": "LMOUNTAINS OF THE MOON",
    "1969-08-02": "KSEASONS OF MY HEART",
    "1969-08-03": "LHI-HEEL SNEAKERS",
    "1969-08-21": "KEASY WIND",
    "1969-08-29": "KNEW ORLEANS|KSEARCHIN'",
    "1969-09-06": "KIT'S ALL OVER NOW",
    "1969-09-29": "KTHE SEVEN|LDOIN' THAT RAG",
    "1969-11-08": "KCUMBERLAND BLUES",
    "1969-12-04": "DBLACK PETER|DUNCLE JOHN'S BAND",
    "1969-12-10": "KBLACK QUEEN",
    "1969-12-19": "KMONKEY & THE ENGINEER|KLITTLE SADIE|KLONG BLACK LIMOUSINE|KI'VE BEEN ALL AROUND THIS WORLD|KMASON'S CHILDREN",
    "1969-12-20": "KNEW SPEEDWAY BOOGIE",
    "1969-12-26": "OGATHERING FLOWERS FOR THE MASTER'S BOUQUET",
    "1969-12-31": "DTHE RACE IS ON|LSLEWFOOT",
    "1970-01-31": "OBOUND IN MEMORIES|DSAWMILL|DKATIE MAE",
    "1970-02-07": "LGREEN GREEN GRASS OF HOME",
    "1970-02-13": "KWAKE UP LITTLE SUSIE",
    "1970-02-14": "KDARK HOLLOW",
    "1970-02-23": "LSEASONS OF MY HEART",
    "1970-02-28": "LMASON'S CHILDREN",
    "1970-03-20": "KFRIEND OF THE DEVIL|B196904260114VIOLA LEE BLUES",
    "1970-03-21": "KWALKIN' THE DOG|LHE WAS A FRIEND OF MINE|LTHE SEVEN",
    "1970-04-03": "KCANDYMAN",
    "1970-04-09": "OCOWBOY SONG|KIT'S A MAN'S WORLD",
    "1970-04-17": "OCATHY'S CLOWN",
    "1970-04-18": "OTHE MIGHTY FLOOD|OBLACK SNAKE|KTHE RUB|KROBERTA|KBRING ME MY SHOTGUN",
    "1970-04-19": "OBIG BREASA|KSHE'S MINE|LSAWMILL|LROBERTA",
    "1970-04-26": "LTHE ELEVEN",
    "1970-05-01": "B196906200108COLD JORDAN",
    "1970-05-07": "KTHE FROZEN LOGGER",
    "1970-05-10": "OWILL THE CIRCLE BE UNBROKEN",
    "1970-05-14": "DATTICS OF MY LIFE",
    "1970-05-15": "DBALLAD OF CASEY JONES|DA VOICE FROM ON HIGH|LLONG BLACK LIMOUSINE",
    "1970-06-04": "DSWING LOW SWEET CHARIOT|B196906220118IT'S A SIN|LIT'S A SIN",
    "1970-06-07": "DSUGAR MAGNOLIA",
    "1970-06-24": "DBIG RAILROAD BLUES|B196907040122LET ME IN 83968|LLET ME IN 83968",
    "1970-07-11": "KHOW LONG BLUES|KROSA LEE MCFALL|KTELL IT TO ME|LKATIE MAE|LBRING ME MY SHOTGUN|LSHE'S MINE",
    "1970-07-12": "OSO SAD|KEL PASO",
    "1970-07-28": "KTO LAY ME DOWN",
    "1970-08-05": "OCOCAINE BLUES|ODRINK UP & GO HOME|LBALLAD OF CASEY JONES|LA VOICE FROM ON HIGH",
    "1970-08-17": "KTRUCKIN'",
    "1970-08-18": "KRIPPLE|KBROKEDOWN PALACE|KOPERATOR",
    "1970-08-19": "LTELL IT TO ME",
    "1970-09-17": "KBOX OF RAIN",
    "1970-09-18": "KTILL THE MORNING COMES|LIT'S A MAN'S WORLD",
    "1970-09-19": "LSILVER THREADS & GOLDEN NEEDLES|LCOLD JORDAN|LSWING LOW SWEET CHARIOT",
    "1970-09-25": "KMONA",
    "1970-10-10": "KGOIN' DOWN THE ROAD",
    "1970-10-31": "LVIOLA LEE BLUES",
    "1970-11-08": "OMYSTERY TRAIN|OMY BABE|DAROUND & AROUND|B196908290154SEARCHIN'|LTHE MAIN TEN|LWAKE UP LITTLE SUSIE|LOPERATOR",
    "1970-11-11": "OJOHN'S OTHER|OUNCLE SAM BLUES|OODE TO BILLIE DEAN|OCOME BACK BABY|KLA BAMBA|KWHO DO YOU LOVE",
    "1970-11-13": "OYOU DON'T LOVE ME. DON'T EASE ME IN|KME & BOBBY MCGEE",
    "1970-11-14": "B196909060157IT'S ALL OVER NOW",
    "1970-11-20": "ODARLING COREY",
    "1970-12-26": "LTILL THE MORNING COMES",
    "1971-01-22": "DJOHNNY B. GOODE",
    "1971-02-18": "DBERTHA|DLOSER|DGREATEST STORY EVER TOLD|DWHARF RAT|DPLAYIN' IN THE BAND",
    "1971-02-19": "DBIRD SONG|DDEAL",
    "1971-04-04": "LEASY WIND",
    "1971-04-05": "KSING ME BACK HOME",
    "1971-04-06": "KOH BOY|LI'M A HOG FOR YOU",
    "1971-04-08": "DSECOND THAT EMOTION",
    "1971-04-27": "ORIOT IN CELL BLOCK #9|OGOOD VIBRATIONS|OI GET AROUND|OHELP ME RHONDA|OOKIE FROM MUSKOGEE|LSEARCHIN'",
    "1971-04-29": "LALLIGATOR|LSECOND THAT EMOTION",
    "1971-05-29": "DPROMISED LAND",
    "1971-07-31": "DSUGAREE|DMR. CHARLIE",
    "1971-08-24": "DEMPTY PAGES|DBROWN-EYED WOMEN",
    "1971-08-26": "LEMPTY PAGES",
    "1971-10-19": "DTENNESSEE JED|DJACK STRAW|DMEXICALI BLUES|DCOMES A TIME|DONE MORE SATURDAY NIGHT|DRAMBLE ON ROSE",
    "1971-11-07": "DHIDEAWAY",
    "1971-11-14": "DYOU WIN AGAIN",
    "1971-12-01": "LTHE RUB",
    "1971-12-04": "DRUN RUDOLPH RUN",
    "1971-12-05": "OI WASHED MY HANDS IN MUDDY WATER",
    "1971-12-15": "KMANNISH BOY|LRUN RUDOLPH RUN",
    "1971-12-31": "KCHINATOWN SHUFFLE|KBIG RIVER",
    "1972-03-05": "KBLACK-THROATED WIND",
    "1972-03-21": "KLOOKS LIKE RAIN|KTWO SOULS IN COMMUNION",
    "1972-03-25": "OI'VE SEEN THEM ALL|OTAKE IT ALL OFF|OYOU KNOW I LOVE YOU|OYOU'VE BEEN RUNNIN' ROUND ROUND|OPOLLUTION|OSAY BOSS MAN|OHOW SWEET IT IS|OARE YOU LONELY FOR ME|KHEY BO DIDDLEY|LMANNISH BOY",
    "1972-03-28": "OSIDEWALKS OF NEW YORK",
    "1972-04-14": "B197011110112WHO DO YOU LOVE",
    "1972-04-17": "DHE'S GONE",
    "1972-05-11": "LCAUTION DO NOT STOP ON TRACKS|LWHO DO YOU LOVE",
    "1972-05-23": "DROCKIN' PNEUMONIA",
    "1972-05-24": "LIT HURTS ME TOO",
    "1972-05-25": "LSITTIN' ON TOP OF THE WORLD",
    "1972-05-26": "LNEXT TIME YOU SEE ME|LMR. CHARLIE|LCHINATOWN SHUFFLE|LTWO SOULS IN COMMUNION",
    "1972-06-17": "DSTELLA BLUE",
    "1972-07-16": "DMISSISSIPPI HALF-STEP",
    "1972-07-21": "DWEATHER REPORT SUITE PRELUDE",
    "1972-09-16": "B197011290139DON'T EASE ME IN",
    "1972-09-23": "B197011080156IT'S ALL OVER NOW BABY BLUE|B197104180106AROUND & AROUND",
    "1972-09-24": "DTOMORROW IS FOREVER",
    "1972-09-26": "LYOU WIN AGAIN",
    "1972-09-27": "B197012270141ATTICS OF MY LIFE",
    "1972-10-09": "B197009170183BOX OF RAIN",
    "1972-10-18": "DPLAYIN' REPRISE",
    "1972-10-23": "LROCKIN' PNEUMONIA",
    "1973-02-09": "DROW JIMMY|DLOOSE LUCY|DHERE COMES SUNSHINE|DTHEY LOVE EACH OTHER|DEYES OF THE WORLD|DCHINA DOLL|DWAVE THAT FLAG",
    "1973-02-15": "DYOU AIN'T WOMAN ENOUGH",
    "1973-02-28": "B197108150128AND WE BID YOU GOODNIGHT",
    "1973-03-19": "B197005010266THE RACE IS ON",
    "1973-06-10": "DIT TAKES A LOT TO LAUGH IT TAKES A TRAIN TO CRY|DTHAT'S ALL RIGHT MAMA|LWAVE THAT FLAG",
    "1973-09-07": "DLET IT GROW",
    "1973-09-08": "DWEATHER REPORT I|DLET ME SING YOUR BLUES AWAY",
    "1973-09-21": "LLET ME SING YOUR BLUES AWAY",
    "1973-09-26": "LSING ME BACK HOME",
    "1973-10-21": "LYOU AIN'T WOMAN ENOUGH",
    "1973-11-09": "B197009200258TO LAY ME DOWN",
    "1973-11-10": "DUNCLE JOHN'S REPRISE",
    "1973-12-10": "DPEGGY-O|DSUNSHINE DAYDREAM",
    "1974-02-22": "DU.S. BLUES|DIT MUST HAVE BEEN THE ROSES|DSHIP OF FOOLS",
    "1974-02-24": "B197209260104IT'S ALL OVER NOW BABY BLUE",
    "1974-03-23": "DSCARLET BEGONIAS|DCASSIDY",
    "1974-05-17": "DMONEY MONEY",
    "1974-05-21": "LMONEY MONEY",
    "1974-06-23": "OLET IT ROCK|DSEASTONES",
    "1974-09-18": "B197212110107FRIEND OF THE DEVIL",
    "1974-10-18": "LWEATHER REPORT SUITE PRELUDE|LWEATHER REPORT I",
    "1974-10-19": "B197108070231MAMA TRIED|B197212110113TOMORROW IS FOREVER|LTOMORROW IS FOREVER",
    "1974-10-20": "B197205250167GOOD LOVIN'|LSEASTONES",
    "1975-03-23": "DBLUES FOR ALLAH|DSTRONGER THAN DIRT",
    "1975-06-17": "DCRAZY FINGERS|DHELP ON THE WAY|DSLIPKNOT|DFRANKLIN'S TOWER",
    "1975-08-13": "DTHE MUSIC NEVER STOPPED|DSAGE & SPIRIT|LBLUES FOR ALLAH",
    "1976-06-03": "DMIGHT AS WELL|DLAZY LIGHTNIN'|DSUPPLICATION|DSAMSON & DELILAH|DTHE WHEEL|B197112310202DANCIN' IN THE STREETS",
    "1976-06-04": "DMISSION IN THE RAIN|B197101210284COSMIC CHARLIE",
    "1976-06-09": "B197110310224ST. STEPHEN|B197007120341HIGH TIME",
    "1976-06-12": "B197210190143COMES A TIME",
    "1976-06-28": "OHAPPINESS IS DRUMMING",
    "1976-06-29": "LMISSION IN THE RAIN",
    "1976-07-12": "B197104290265MINGLEWOOD BLUES",
    "1976-07-16": "LSTRONGER THAN DIRT",
    "1976-09-25": "B197011200326IT'S ALL OVER NOW|LCOSMIC CHARLIE",
    "1977-02-26": "DTERRAPIN STATION|DESTIMATED PROPHET",
    "1977-03-18": "OL'ALHAMBRA|DFIRE ON THE MOUNTAIN",
    "1977-04-22": "DGOT MY MOJO WORKIN'",
    "1977-05-01": "DSUNRISE",
    "1977-05-13": "DJACK-A-ROE",
    "1977-05-15": "DPASSENGER|DIKO IKO",
    "1977-10-02": "B196907110549DUPREE'S DIAMOND BLUES",
    "1977-10-12": "B197407290107NOBODY'S FAULT BUT MINE",
    "1977-12-29": "B197410200104I KNOW YOU RIDER|B197410200104CHINA CAT SUNFLOWER",
    "1978-04-19": "DWEREWOLVES OF LONDON",
    "1978-08-30": "DSTAGGER LEE|DI NEED A MIRACLE|DIF I HAD THE WORLD TO GIVE",
    "1978-08-31": "DFROM THE HEART OF ME|DSHAKEDOWN STREET|DOLLIN ARAGEED",
    "1978-09-16": "LSUNRISE",
    "1978-10-21": "B197704220112GOT MY MOJO WORKIN'|LGOT MY MOJO WORKIN'",
    "1978-11-20": "LIF I HAD THE WORLD TO GIVE",
    "1978-12-31": "B197410180189DARK STAR|B197612310141AND WE BID YOU GOODNIGHT|B197607130162SUNSHINE DAYDREAM",
    "1979-02-07": "B197408060215DON'T EASE ME IN",
    "1979-02-11": "B197711020107MIGHT AS WELL",
    "1979-02-17": "B197705260131HIGH TIME|B197410190208BIG RAILROAD BLUES|B197410180209GREATEST STORY EVER TOLD|LFROM THE HEART OF ME",
    "1979-05-08": "B197712290109CHINA DOLL",
    "1979-08-04": "DALTHEA|DLOST SAILOR",
    "1979-08-14": "DEASY TO LOVE YOU",
    "1979-08-31": "DSAINT OF CIRCUMSTANCE",
    "1979-11-04": "DALABAMA GETAWAY",
    "1979-11-08": "B197804150111MORNING DEW",
    "1979-12-01": "DC.C. RIDER",
    "1979-12-26": "B197710060171UNCLE JOHN'S BAND|B197710140166BROKEDOWN PALACE|B197403230294UNCLE JOHN'S REPRISE",
    "1980-01-13": "OBRIDGING THE GAP|OAMAZING GRACE",
    "1980-03-30": "DFAR FROM ME",
    "1980-03-31": "DFEEL LIKE A STRANGER",
    "1980-08-19": "DLITTLE RED ROOSTER",
    "1980-09-25": "DOH BABE IT AIN'T NO LIE|B197012310591MONKEY & THE ENGINEER|B197007120646I'VE BEEN ALL AROUND THIS WORLD|B197104290553DARK HOLLOW|B197011080611ROSA LEE MCFALL|B197104290553RIPPLE|B197309150384BIRD SONG|B197901120119IT MUST HAVE BEEN THE ROSES",
    "1980-09-26": "B197410190314TO LAY ME DOWN|B197905080100CHINA DOLL",
    "1980-09-27": "B197410190315THE RACE IS ON",
    "1980-09-29": "DHEAVEN HELP THE FOOL",
    "1980-10-04": "B197012280599DEEP ELEM BLUES",
    "1980-10-27": "LROSA LEE MCFALL",
    "1980-10-31": "B197002280722LITTLE SADIE|B197508130333SAGE & SPIRIT|LLITTLE SADIE|LSAGE & SPIRIT|LHEAVEN HELP THE FOOL",
    "1980-11-26": "DSATISFACTION",
    "1980-12-31": "LI'VE BEEN ALL AROUND THIS WORLD",
    "1981-04-25": "B197104060626OH BOY|LDARK HOLLOW",
    "1981-05-04": "B197901050184NOBODY'S FAULT BUT MINE",
    "1981-07-02": "DWOMEN ARE SMARTER",
    "1981-07-07": "B197912100132DANCIN' IN THE STREETS",
    "1981-08-12": "B197902170187MIGHT AS WELL",
    "1981-08-14": "B197402240432IT'S ALL OVER NOW BABY BLUE",
    "1981-08-27": "B197410180400CUMBERLAND BLUES",
    "1981-08-28": "DNEVER TRUST A WOMAN",
    "1981-10-15": "DSPOONFUL|B198009060106FAR FROM ME",
    "1981-10-16": "OHULLY GULLY|B196704091174GLORIA|B197205240586TURN ON YOUR LOVELIGHT",
    "1981-11-30": "OMACK THE KNIFE",
    "1981-12-12": "OWARRIORS OF THE SUN|OYOU WON'T FIND ME|OWHERE HAVE THE HEROES GONE|OTHE BOXER|DCHILDREN OF THE 80S|DLUCIFER'S EYES|DBYE BYE LOVE|DBARBARA ALLEN|DLADY DI & I|B197410160433ME & BOBBY MCGEE|LOH BOY",
    "1981-12-26": "B197205250597BIG BOSS MAN",
    "1981-12-27": "LPASSENGER",
    "1981-12-30": "LBARBARA ALLEN|LLADY DI & I",
    "1981-12-31": "OBANKS OF THE OHIO|B197901200236DARK STAR|LME & BOBBY MCGEE|LCHILDREN OF THE 80S|LLUCIFER'S EYES|LBYE BYE LOVE",
    "1982-04-18": "OPHIL'S EARTHQUAKE SPACE",
    "1982-04-19": "OTHE RAVEN SPACE",
    "1982-05-28": "OI GOT A MIND TO GIVE UP LIVIN'|DWALKIN' BLUES",
    "1982-07-18": "B197609300422CRAZY FINGERS",
    "1982-08-04": "B197912040216STAGGER LEE",
    "1982-08-28": "DDAY JOB|DWEST L.A. FADEAWAY|B197804140343DUPREE'S DIAMOND BLUES",
    "1982-09-15": "DTOUCH OF GREY",
    "1982-09-17": "DTHROWING STONES",
    "1982-12-30": "DTELL MAMA|B197108260721HARD TO HANDLE",
    "1982-12-31": "DBABY WHAT YOU WANT ME TO DO|B197104290736MIDNIGHT HOUR|LHARD TO HANDLE|LTELL MAMA",
    "1983-03-25": "DMY BROTHER ESAU|B197710110406HELP ON THE WAY|B197710110406SLIPKNOT",
    "1983-03-30": "B198107100110CHINA DOLL",
    "1983-04-12": "DNOT FADE AWAY REPRISE",
    "1983-04-13": "DMAYBE YOU KNOW",
    "1983-04-15": "DLITTLE STAR",
    "1983-04-16": "B196912100931BLACK QUEEN|LBLACK QUEEN",
    "1983-04-17": "OLOVE THE ONE YOU'RE WITH",
    "1983-05-13": "DHELL IN A BUCKET",
    "1983-06-20": "LLITTLE STAR",
    "1983-08-26": "DWANG DANG DOODLE",
    "1983-09-24": "LDEEP ELEM BLUES",
    "1983-10-11": "B197901100356ST. STEPHEN",
    "1983-10-12": "DREVOLUTION",
    "1983-10-31": "LST. STEPHEN",
    "1983-12-31": "OGOODNIGHT IRENE|B198112310127BIG BOSS MAN",
    "1984-03-28": "DDON'T NEED LOVE|B198110160144OH BABE IT AIN'T NO LIE|LOH BABE IT AIN'T NO LIE",
    "1984-03-29": "B197011130857WALKIN' THE DOG",
    "1984-04-23": "OONLY A FOOL",
    "1984-06-14": "DDEAR MR. FANTASY",
    "1984-06-21": "B197011140882NEW ORLEANS|LNEW ORLEANS",
    "1984-06-24": "B198107070203DANCIN' IN THE STREETS",
    "1984-06-26": "B198208030125CASEY JONES",
    "1984-06-27": "DWHY DON'T WE DO IT IN THE ROAD",
    "1984-07-07": "B198212310105TURN ON YOUR LOVELIGHT",
    "1984-07-13": "B198112310167DARK STAR",
    "1984-07-22": "B196611291414I JUST WANNA MAKE LOVE TO YOU",
    "1984-10-09": "B197203250800SMOKESTACK LIGHTNING",
    "1984-10-12": "B198304190102ON THE ROAD AGAIN|B198209090135UNCLE JOHN'S REPRISE|B198204170159JACK-A-ROE|LON THE ROAD AGAIN",
    "1984-10-31": "DI AIN'T SUPERSTITIOUS|LLAZY LIGHTNIN'",
    "1984-11-02": "DGIMME SOME LOVIN'",
    "1984-11-03": "DDOWN IN THE BOTTOM|B198110160204GLORIA",
    "1984-12-28": "DTONS OF STEEL|DDAY TRIPPER",
    "1984-12-29": "B198304120120NOT FADE AWAY REPRISE",
    "1985-02-18": "B198212310131BABY WHAT YOU WANT ME TO DO",
    "1985-03-13": "B197908050410OLLIN ARAGEED",
    "1985-03-27": "DJUST LIKE TOM THUMB'S BLUES|B198210170148MISSISSIPPI HALF-STEP",
    "1985-04-04": "B196601071542SHE BELONGS TO ME",
    "1985-06-14": "DKEEP ON GROWING|B198010020334COMES A TIME|B198208100179STAGGER LEE",
    "1985-06-16": "B197209230796CRYPTICAL ENVELOPMENT|B198205280195WALKIN' BLUES",
    "1985-06-28": "LI AIN'T SUPERSTITIOUS|LDOWN IN THE BOTTOM",
    "1985-08-24": "LDAY TRIPPER",
    "1985-09-03": "B198105040297NOBODY'S FAULT BUT MINE|LCRYPTICAL ENVELOPMENT",
    "1985-09-07": "DHEY JUDE CODA|B197208250825THE FROZEN LOGGER|LTHE FROZEN LOGGER",
    "1985-10-28": "DKANSAS CITY",
    "1985-10-31": "B197807080527WEREWOLVES OF LONDON",
    "1985-11-05": "LKANSAS CITY",
    "1985-11-08": "LBABY WHAT YOU WANT ME TO DO",
    "1985-11-21": "B197009201009BIG BOY PETE|LSHE BELONGS TO ME|LBIG BOY PETE|LWALKIN' THE DOG",
    "1985-12-30": "DQUINN THE ESKIMO",
    "1986-02-11": "B197208220854HEY BO DIDDLEY|LHEY BO DIDDLEY",
    "1986-02-12": "DWILLIE & THE HAND JIVE",
    "1986-02-14": "LKEEP ON GROWING",
    "1986-03-19": "DVISIONS OF JOHANNA",
    "1986-03-20": "B197307280782BOX OF RAIN",
    "1986-03-21": "DI'M A ROAD RUNNER",
    "1986-03-24": "LLOST SAILOR",
    "1986-03-25": "DDESOLATION ROW",
    "1986-03-27": "OREVOLUTIONARY HAMSTRUNG BLUES",
    "1986-03-30": "LWHY DON'T WE DO IT IN THE ROAD",
    "1986-03-31": "LI'M A ROAD RUNNER",
    "1986-04-04": "LDAY JOB",
    "1986-04-13": "LDON'T NEED LOVE",
    "1986-04-18": "OMY BABY LEFT ME|B197306100803THAT'S ALL RIGHT MAMA|LTHAT'S ALL RIGHT MAMA",
    "1986-04-21": "B198304260205MAYBE YOU KNOW|LMAYBE YOU KNOW",
    "1986-05-03": "B198110160303THE RACE IS ON",
    "1986-07-02": "ODON'T THINK TWICE IT'S ALL RIGHT",
    "1986-12-15": "DWHEN PUSH COMES TO SHOVE|DBLACK MUDDY RIVER",
    "1986-12-30": "B198503130109OLLIN ARAGEED|LOLLIN ARAGEED",
    "1987-01-28": "OGET BACK",
    "1987-03-22": "B198212310254SUNSHINE DAYDREAM",
    "1987-03-29": "B198410300135FAR FROM ME",
    "1987-04-04": "LWILLIE & THE HAND JIVE",
    "1987-04-06": "LDANCIN' IN THE STREETS",
    "1987-06-13": "DWHEN I PAINT MY MASTERPIECE",
    "1987-06-20": "DALL ALONG THE WATCHTOWER",
    "1987-07-04": "DTHE TIMES THEY ARE A-CHANGIN'|DMAN OF PEACE|DI'LL BE YOUR BABY TONIGHT|DJOHN BROWN|DI WANT YOU|DBALLAD OF A THIN MAN|DSTUCK INSIDE OF MOBILE|DQUEEN JANE APPROXIMATELY|DCHIMES OF FREEDOM|DSLOW TRAIN|DJOEY|DKNOCKIN' ON HEAVEN'S DOOR",
    "1987-07-06": "DDAY-O",
    "1987-07-10": "DTANGLED UP IN BLUE|DTHE BALLAD OF FRANKIE LEE & JUDAS PRIEST|DSIMPLE TWIST OF FATE|DGOTTA SERVE SOMEBODY",
    "1987-07-12": "OTOMORROW IS A LONG TIME|OTHE WICKED MESSENGER|DHIGHWAY 61 REVISITED|LJOHN BROWN|LJOEY",
    "1987-07-19": "OHEART OF MINE|DMAGGIE'S FARM|DDEAD MAN DEAD MAN|DWATCHING THE RIVER FLOW|DRAINY DAY WOMEN NO. 12 & 35|LTANGLED UP IN BLUE|LTHE BALLAD OF FRANKIE LEE & JUDAS PRIEST",
    "1987-07-24": "OSHELTER FROM THE STORM|LTHE TIMES THEY ARE A-CHANGIN'|LMAN OF PEACE|LI'LL BE YOUR BABY TONIGHT|LI WANT YOU|LSLOW TRAIN|LHIGHWAY 61 REVISITED",
    "1987-07-26": "OMR. TAMBOURINE MAN|LCHIMES OF FREEDOM|LSIMPLE TWIST OF FATE|LGOTTA SERVE SOMEBODY|LDEAD MAN DEAD MAN|LWATCHING THE RIVER FLOW",
    "1987-08-13": "B198504080148BIG BOSS MAN",
    "1987-08-22": "B197009191116GOOD MORNING LITTLE SCHOOLGIRL",
    "1987-09-07": "B197011111097LA BAMBA",
    "1987-09-09": "DHEY POCKY WAY|DDEVIL WITH A BLUE DRESS|DGOOD GOLLY MISS MOLLY",
    "1987-09-13": "OFEVER",
    "1987-09-23": "LLA BAMBA|LTONS OF STEEL",
    "1987-10-03": "LMY BROTHER ESAU",
    "1987-10-04": "LDEVIL WITH A BLUE DRESS|LGOOD GOLLY MISS MOLLY",
    "1987-12-31": "ODO YOU WANNA DANCE|LDAY-O",
    "1988-03-12": "OLONG TALL SALLY",
    "1988-03-17": "B198509070162HEY JUDE CODA",
    "1988-03-26": "OSTIR IT UP",
    "1988-03-27": "OSO WHAT|B198310170287TO LAY ME DOWN",
    "1988-03-30": "B198410120229UNCLE JOHN'S REPRISE|LUNCLE JOHN'S REPRISE",
    "1988-04-01": "LBALLAD OF A THIN MAN",
    "1988-04-05": "B196705181586LOUIE LOUIE",
    "1988-04-30": "DLET THE GOOD TIMES ROLL",
    "1988-06-17": "DVICTIM OR THE CRIME",
    "1988-06-19": "DFOOLISH HEART",
    "1988-06-20": "DBLOW AWAY",
    "1988-06-22": "DI WILL TAKE YOU HOME",
    "1988-06-23": "DBELIEVE IT OR NOT|DBLACKBIRD",
    "1988-06-26": "DGENTLEMEN START YOUR ENGINES",
    "1988-06-30": "OGREEN ONIONS",
    "1988-07-17": "LBLACKBIRD",
    "1988-07-31": "LGENTLEMEN START YOUR ENGINES",
    "1988-09-03": "B198110160460RIPPLE|LRIPPLE",
    "1988-09-06": "B198705020112BEAT IT ON DOWN THE LINE",
    "1988-09-24": "OCHINESE BONES|ONEIGHBORHOOD GIRLS|OEVERY TIME YOU GO AWAY|OWHAT'S GOING ON",
    "1988-10-20": "DBUILT TO LAST",
    "1988-10-21": "B198603270194WANG DANG DOODLE",
    "1988-12-09": "B198508310236JACK-A-ROE",
    "1989-02-05": "DWE CAN RUN|DSTANDING ON THE MOON",
    "1989-02-07": "DJUST A LITTLE LIGHT",
    "1989-02-12": "B198110160496MONKEY & THE ENGINEER|B197011071214HOW LONG BLUES|LMONKEY & THE ENGINEER|LHOW LONG BLUES",
    "1989-04-03": "B198704090158EL PASO",
    "1989-04-09": "LLOUIE LOUIE",
    "1989-04-12": "B198709070125SPOONFUL",
    "1989-04-28": "DPICASSO MOON",
    "1989-05-06": "B198605030213THE RACE IS ON",
    "1989-06-21": "B197111071154HIDEAWAY|LHIDEAWAY",
    "1989-07-17": "B197812310761AND WE BID YOU GOODNIGHT|LWHEN PUSH COMES TO SHOVE",
    "1989-09-29": "B197004261323DEATH DON'T HAVE NO MERCY",
    "1989-10-08": "B198509120285HELP ON THE WAY|B198509120285SLIPKNOT",
    "1989-10-09": "B198407130360DARK STAR|B197210281088ATTICS OF MY LIFE",
    "1989-10-20": "DCALIFORNIA EARTHQUAKE",
    "1989-10-23": "LCALIFORNIA EARTHQUAKE",
    "1989-12-10": "OI'M A MAN|B198704030219C.C. RIDER",
    "1989-12-31": "B198807310107MIDNIGHT HOUR|B198804090133BIG BOSS MAN",
    "1990-02-25": "DTHE LAST TIME",
    "1990-03-14": "B197410190986LOOSE LUCY",
    "1990-03-15": "B198009030677EASY TO LOVE YOU|B198511080299REVOLUTION",
    "1990-03-16": "B197410190988BLACK-THROATED WIND",
    "1990-03-22": "B196903011509HEY JUDE|LHEY JUDE|LBELIEVE IT OR NOT",
    "1990-03-26": "B198809180106BIG RAILROAD BLUES|LBUILT TO LAST",
    "1990-03-28": "DTHE WEIGHT|LREVOLUTION",
    "1990-04-02": "LDEATH DON'T HAVE NO MERCY",
    "1990-07-10": "LWE CAN RUN",
    "1990-07-12": "LHEY JUDE CODA",
    "1990-07-14": "LI WILL TAKE YOU HOME",
    "1990-07-16": "LBLOW AWAY",
    "1990-07-18": "LEASY TO LOVE YOU",
    "1990-07-21": "LDEAR MR. FANTASY|LJUST A LITTLE LIGHT",
    "1990-07-22": "LFAR FROM ME|LHEY POCKY WAY",
    "1990-07-23": "LNEVER TRUST A WOMAN",
    "1990-09-15": "LGIMME SOME LOVIN'",
    "1990-09-20": "B198904030113EL PASO",
    "1990-10-17": "B198711140213MAGGIE'S FARM",
    "1990-10-20": "LNOT FADE AWAY REPRISE",
    "1990-10-22": "DVALLEY ROAD",
    "1990-10-27": "B198906180103SAINT OF CIRCUMSTANCE",
    "1990-10-28": "DSTANDER ON THE MOUNTAIN",
    "1990-10-31": "B198510310362WEREWOLVES OF LONDON",
    "1990-12-03": "LSTANDER ON THE MOUNTAIN",
    "1990-12-27": "B198707080266COMES A TIME",
    "1990-12-30": "LVALLEY ROAD",
    "1991-02-19": "B197011221345NEW SPEEDWAY BOOGIE",
    "1991-03-17": "DRUBIN & CHERISE",
    "1991-03-20": "B198804050216MIGHT AS WELL",
    "1991-05-12": "B197306101170IT TAKES A LOT TO LAUGH IT TAKES A TRAIN TO CRY|B198912100107C.C. RIDER",
    "1991-06-09": "LRUBIN & CHERISE",
    "1991-09-08": "B199003300112ATTICS OF MY LIFE",
    "1991-09-18": "B198912310136MIDNIGHT HOUR",
    "1991-09-22": "B198509030451NOBODY'S FAULT BUT MINE",
    "1991-09-25": "DTHAT WOULD BE SOMETHING",
    "1991-09-26": "B199007140107AND WE BID YOU GOODNIGHT|LAND WE BID YOU GOODNIGHT",
    "1991-10-27": "B197203251315MONA|LMONA",
    "1991-10-31": "LWEREWOLVES OF LONDON",
    "1991-11-03": "OBORN ON THE BAYOU|OGREEN RIVER|OBAD MOON RISING|OPROUD MARY|OFOREVER YOUNG",
    "1991-12-28": "B197112311327THE SAME THING",
    "1992-02-22": "DSO MANY ROADS|DWAVE TO THE WIND",
    "1992-02-23": "DWAY TO GO HOME|DCORRINA",
    "1992-03-09": "B198607070407SATISFACTION",
    "1992-03-16": "LIT TAKES A LOT TO LAUGH IT TAKES A TRAIN TO CRY|LC.C. RIDER",
    "1992-03-23": "B198511010469GLORIA",
    "1992-05-19": "DBABA O'RILEY|DTOMORROW NEVER KNOWS",
    "1992-06-20": "B198411020550CASEY JONES",
    "1992-06-25": "B198803120342GOOD MORNING LITTLE SCHOOLGIRL",
    "1992-06-28": "B199012140125TO LAY ME DOWN|LTO LAY ME DOWN",
    "1992-12-02": "DRAIN",
    "1992-12-06": "B197402231220HERE COMES SUNSHINE",
    "1993-02-21": "DLAZY RIVER ROAD|DETERNITY|DLIBERTY",
    "1993-02-22": "DDAYS BETWEEN",
    "1993-02-23": "DBROKEN ARROW",
    "1993-03-14": "DI FOUGHT THE LAW",
    "1993-03-17": "DLUCY IN THE SKY WITH DIAMONDS",
    "1993-03-27": "LCASEY JONES",
    "1993-05-22": "B198410310598SUPPLICATION|LSUPPLICATION",
    "1993-06-05": "DEASY ANSWERS",
    "1993-06-08": "B199109250103THAT WOULD BE SOMETHING",
    "1993-09-20": "B199105040172THE RACE IS ON",
    "1993-09-29": "LPLAYIN' REPRISE",
    "1993-12-08": "B197112151459I'M A KING BEE",
    "1993-12-09": "LWAVE TO THE WIND",
    "1993-12-12": "B199109220144NOBODY'S FAULT BUT MINE",
    "1994-03-23": "B199106170187MIGHT AS WELL|LMIGHT AS WELL",
    "1994-03-30": "LDARK STAR",
    "1994-03-31": "LI'M A KING BEE",
    "1994-06-08": "DSAMBA IN THE RAIN|B199206230119BIG RAILROAD BLUES",
    "1994-06-09": "DIF THE SHOE FITS",
    "1994-06-10": "B199111030166SUNSHINE DAYDREAM|LSUNSHINE DAYDREAM",
    "1994-07-01": "DI WANT TO TELL YOU",
    "1994-07-20": "DCHILDHOOD'S END|DMATILDA",
    "1994-07-23": "LKNOCKIN' ON HEAVEN'S DOOR",
    "1994-07-29": "B199206110151QUINN THE ESKIMO",
    "1994-07-31": "B199304040105MIDNIGHT HOUR",
    "1994-08-01": "B199206180148SATISFACTION|LSATISFACTION",
    "1994-09-17": "B199303100127IT'S ALL OVER NOW BABY BLUE",
    "1994-09-27": "LTHEY LOVE EACH OTHER",
    "1994-10-03": "LBEAT IT ON DOWN THE LINE",
    "1994-10-09": "B199303270127COMES A TIME|LCOMES A TIME",
    "1994-10-11": "LCHINA DOLL",
    "1994-10-13": "B199003260342DUPREE'S DIAMOND BLUES|LDUPREE'S DIAMOND BLUES",
    "1994-10-17": "B198707260548RAINY DAY WOMEN NO. 12 & 35|LMIDNIGHT HOUR|LRAINY DAY WOMEN NO. 12 & 35",
    "1994-10-18": "LSMOKESTACK LIGHTNING",
    "1994-11-29": "LBABA O'RILEY|LTOMORROW NEVER KNOWS",
    "1994-12-08": "LSPOONFUL",
    "1994-12-19": "LNOBODY'S FAULT BUT MINE",
    "1995-02-19": "B198906180416ALABAMA GETAWAY|LIT'S ALL OVER NOW BABY BLUE",
    "1995-02-21": "OSALT LAKE CITY|B198410080747I JUST WANNA MAKE LOVE TO YOU|B198604220635VISIONS OF JOHANNA|LI JUST WANNA MAKE LOVE TO YOU",
    "1995-03-18": "DIT'S ALL TOO MUCH",
    "1995-03-19": "DUNBROKEN CHAIN",
    "1995-03-23": "LTHE WEIGHT",
    "1995-03-24": "LHIGH TIME|LIF THE SHOE FITS",
    "1995-03-30": "B199308210130GOOD MORNING LITTLE SCHOOLGIRL",
    "1995-04-01": "DTAKE ME TO THE RIVER",
    "1995-04-02": "LSTUCK INSIDE OF MOBILE",
    "1995-04-05": "LJOHNNY B. GOODE|LMAGGIE'S FARM",
    "1995-05-20": "B199309200123THE RACE IS ON",
    "1995-06-15": "DROLLIN' & TUMBLIN'",
    "1995-06-24": "B199108130289BLACK MUDDY RIVER",
    "1995-06-28": "B199406080101BIG RAILROAD BLUES",
    "1995-06-30": "B199309180143GLORIA",
    "1995-07-06": "B199006160390BIG BOSS MAN",
}

# Times each rarely played song (50 or fewer) was played, from the same
# history as MILESTONES, for the night's rarest song.
RARE_PLAYS = {
    "A VOICE FROM ON HIGH": 4,
    "ALICE D. MILLIONAIRE": 3,
    "ATTICS OF MY LIFE": 49,
    "BABA O'RILEY": 12,
    "BABY WHAT YOU WANT ME TO DO": 4,
    "BALLAD OF A THIN MAN": 8,
    "BALLAD OF CASEY JONES": 2,
    "BARBARA ALLEN": 2,
    "BELIEVE IT OR NOT": 7,
    "BIG BOY PETE": 8,
    "BLACK QUEEN": 2,
    "BLACKBIRD": 2,
    "BLOW AWAY": 23,
    "BLUES FOR ALLAH": 3,
    "BORN CROSS-EYED": 14,
    "BRING ME MY SHOTGUN": 2,
    "BROKEN ARROW": 35,
    "BUILT TO LAST": 18,
    "BYE BYE LOVE": 2,
    "CALIFORNIA EARTHQUAKE": 2,
    "CARDBOARD COWBOY": 4,
    "CHILDHOOD'S END": 11,
    "CHILDREN OF THE 80S": 2,
    "CHIMES OF FREEDOM": 4,
    "CHINATOWN SHUFFLE": 28,
    "CLEMENTINE": 4,
    "COLD JORDAN": 14,
    "COSMIC CHARLIE": 42,
    "CREAM PUFF WAR": 9,
    "DARK HOLLOW": 32,
    "DAY TRIPPER": 5,
    "DAY-O": 2,
    "DAYS BETWEEN": 41,
    "DEAD MAN DEAD MAN": 2,
    "DEATH DON'T HAVE NO MERCY": 46,
    "DEVIL WITH A BLUE DRESS": 3,
    "DOIN' THAT RAG": 40,
    "DON'T NEED LOVE": 16,
    "DOWN IN THE BOTTOM": 9,
    "DOWN SO LONG": 2,
    "EARLY MORNING RAIN": 2,
    "EASY ANSWERS": 44,
    "EASY TO LOVE YOU": 45,
    "EASY WIND": 50,
    "EMPTY PAGES": 2,
    "ETERNITY": 44,
    "FROM THE HEART OF ME": 26,
    "GENTLEMEN START YOUR ENGINES": 2,
    "GLORIA": 15,
    "GOOD GOLLY MISS MOLLY": 3,
    "GOT MY MOJO WORKIN'": 2,
    "GOTTA SERVE SOMEBODY": 2,
    "GREEN GREEN GRASS OF HOME": 7,
    "HE WAS A FRIEND OF MINE": 21,
    "HEAVEN HELP THE FOOL": 17,
    "HEY BO DIDDLEY": 5,
    "HEY JUDE": 3,
    "HEY JUDE CODA": 28,
    "HEY LITTLE ONE": 2,
    "HEY POCKY WAY": 25,
    "HI-HEEL SNEAKERS": 3,
    "HIDEAWAY": 2,
    "HIGHWAY 61 REVISITED": 3,
    "HOW LONG BLUES": 5,
    "I AIN'T SUPERSTITIOUS": 8,
    "I FOUGHT THE LAW": 36,
    "I JUST WANNA MAKE LOVE TO YOU": 4,
    "I WANT TO TELL YOU": 7,
    "I WANT YOU": 2,
    "I WILL TAKE YOU HOME": 34,
    "I'LL BE YOUR BABY TONIGHT": 3,
    "I'M A HOG FOR YOU": 4,
    "I'M A KING BEE": 37,
    "I'M A ROAD RUNNER": 2,
    "I'VE BEEN ALL AROUND THIS WORLD": 20,
    "IF I HAD THE WORLD TO GIVE": 3,
    "IF THE SHOE FITS": 17,
    "IT TAKES A LOT TO LAUGH IT TAKES A TRAIN TO CRY": 7,
    "IT'S A MAN'S WORLD": 14,
    "IT'S A SIN": 12,
    "IT'S ALL TOO MUCH": 6,
    "JOEY": 3,
    "JOHN BROWN": 3,
    "JUST A LITTLE LIGHT": 21,
    "KANSAS CITY": 2,
    "KATIE MAE": 12,
    "KEEP ON GROWING": 4,
    "KEEP ROLLING BY": 2,
    "LA BAMBA": 5,
    "LADY DI & I": 2,
    "LET ME IN 83968": 2,
    "LET ME SING YOUR BLUES AWAY": 6,
    "LET THE GOOD TIMES ROLL": 47,
    "LINDY": 4,
    "LITTLE SADIE": 7,
    "LITTLE STAR": 3,
    "LONG BLACK LIMOUSINE": 5,
    "LOUIE LOUIE": 7,
    "LUCIFER'S EYES": 2,
    "LUCY IN THE SKY WITH DIAMONDS": 19,
    "MAGGIE'S FARM": 43,
    "MAN OF PEACE": 3,
    "MANNISH BOY": 2,
    "MASON'S CHILDREN": 19,
    "MATILDA": 6,
    "MAYBE YOU KNOW": 6,
    "MINDBENDER": 2,
    "MISSION IN THE RAIN": 5,
    "MONA": 4,
    "MONEY MONEY": 3,
    "MONKEY & THE ENGINEER": 41,
    "MOUNTAINS OF THE MOON": 13,
    "NEVER TRUST A WOMAN": 42,
    "NEW ORLEANS": 7,
    "NEW POTATO CABOOSE": 32,
    "NOBODY'S FAULT BUT MINE": 18,
    "NOT FADE AWAY REPRISE": 26,
    "OH BABE IT AIN'T NO LIE": 15,
    "OH BOY": 4,
    "OLLIN ARAGEED": 14,
    "ON THE ROAD AGAIN": 40,
    "ONE KIND FAVOR": 5,
    "OPERATOR": 4,
    "PAIN IN MY HEART": 2,
    "RAIN": 20,
    "RAINY DAY WOMEN NO. 12 & 35": 3,
    "REVOLUTION": 11,
    "RIPPLE": 41,
    "ROBERTA": 2,
    "ROCKIN' PNEUMONIA": 4,
    "ROLLIN' & TUMBLIN'": 2,
    "ROSA LEE MCFALL": 18,
    "RUBIN & CHERISE": 4,
    "RUN RUDOLPH RUN": 7,
    "SAGE & SPIRIT": 2,
    "SAMBA IN THE RAIN": 38,
    "SATISFACTION": 31,
    "SAWMILL": 3,
    "SEARCHIN'": 3,
    "SEASONS OF MY HEART": 7,
    "SEASTONES": 23,
    "SECOND THAT EMOTION": 7,
    "SHE BELONGS TO ME": 10,
    "SHE'S MINE": 3,
    "SICK & TIRED": 2,
    "SILVER THREADS & GOLDEN NEEDLES": 18,
    "SIMPLE TWIST OF FATE": 3,
    "SING ME BACK HOME": 41,
    "SITTIN' ON TOP OF THE WORLD": 44,
    "SLEWFOOT": 8,
    "SLOW TRAIN": 3,
    "SOMETHING ON YOUR MIND": 2,
    "STANDER ON THE MOUNTAIN": 3,
    "STANDING ON THE CORNER": 3,
    "STEALIN'": 5,
    "STRONGER THAN DIRT": 5,
    "SUNRISE": 30,
    "SUNSHINE DAYDREAM": 31,
    "SWING LOW SWEET CHARIOT": 11,
    "TAKE ME TO THE RIVER": 4,
    "TANGLED UP IN BLUE": 2,
    "TASTEBUD": 3,
    "TELL IT TO ME": 2,
    "TELL MAMA": 2,
    "THAT WOULD BE SOMETHING": 17,
    "THAT'S ALL RIGHT MAMA": 2,
    "THE BALLAD OF FRANKIE LEE & JUDAS PRIEST": 2,
    "THE FROZEN LOGGER": 8,
    "THE GOLDEN ROAD": 4,
    "THE MAIN TEN": 8,
    "THE RUB": 14,
    "THE SAME THING": 45,
    "THE SEVEN": 2,
    "THE TIMES THEY ARE A-CHANGIN'": 3,
    "THE WEIGHT": 41,
    "TILL THE MORNING COMES": 6,
    "TOMORROW IS FOREVER": 10,
    "TOMORROW NEVER KNOWS": 12,
    "TONS OF STEEL": 29,
    "TWO SOULS IN COMMUNION": 13,
    "UNBROKEN CHAIN": 10,
    "UNCLE JOHN'S REPRISE": 11,
    "VALLEY ROAD": 6,
    "VIOLA LEE BLUES": 35,
    "VISIONS OF JOHANNA": 8,
    "WAKE UP LITTLE SUSIE": 14,
    "WALKIN' THE DOG": 6,
    "WATCHING THE RIVER FLOW": 2,
    "WAVE THAT FLAG": 15,
    "WAVE TO THE WIND": 21,
    "WE CAN RUN": 22,
    "WEATHER REPORT I": 47,
    "WEREWOLVES OF LONDON": 12,
    "WHO DO YOU LOVE": 3,
    "WHY DON'T WE DO IT IN THE ROAD": 7,
    "WILLIE & THE HAND JIVE": 6,
    "YOU AIN'T WOMAN ENOUGH": 17,
    "YOU DON'T HAVE TO ASK": 8,
    "YOU DON'T LOVE ME": 2,
    "YOU WIN AGAIN": 25,
}

# The six pages after each memorial, from each person's Wikipedia article
# (and gdsets' lineups for show counts).
TRIBUTES = {
    "JERRY GARCIA": [
        ("BORN", "JEROME JOHN GARCIA, AUGUST 1, 1942, IN SAN FRANCISCO - NAMED FOR THE COMPOSER JEROME KERN. HIS FIRST STRINGED INSTRUMENT WAS THE BANJO"),
        ("HIS PLAYING HAND", "AT FOUR HE LOST TWO-THIRDS OF HIS RIGHT MIDDLE FINGER IN A WOOD-SPLITTING ACCIDENT"),
        ("THE GUITARS", "DOUG IRWIN BUILT HIM WOLF, TIGER AND ROSEBUD. TIGER LATER SOLD AT AUCTION FOR $9.5 MILLION"),
        ("BEYOND THE DEAD", "THE JERRY GARCIA BAND, OLD & IN THE WAY, LEGION OF MARY, THE NEW RIDERS, WHICH HE CO-FOUNDED - AND PEDAL STEEL ON TEACH YOUR CHILDREN"),
        ("IN HIS WORDS", "''OUR AUDIENCE IS LIKE PEOPLE WHO LIKE LICORICE. NOT EVERYBODY LIKES LICORICE, BUT THE PEOPLE WHO LIKE LICORICE REALLY LIKE LICORICE.''"),
        ("THE LAST SHOW", "JULY 9, 1995, AT SOLDIER FIELD IN CHICAGO. HE PLAYED TIGER ON THE LAST SONG, BOX OF RAIN"),
    ],
    "PIGPEN": [
        ("BORN", "RONALD CHARLES MCKERNAN, SEPTEMBER 8, 1945, IN SAN BRUNO, CALIFORNIA"),
        ("THE BLUES", "SON OF AN R&B AND BLUES DJ, HE TAUGHT HIMSELF BLUES PIANO, GUITAR AND HARMONICA"),
        ("THE NAME", "FIRST CALLED BLUE RON, HE BECAME PIGPEN AFTER THE FOREVER-DIRTY CHARACTER IN PEANUTS"),
        ("THE FOUNDER", "HE URGED THE WARLOCKS TO GO ELECTRIC, AND WAS THE BAND'S ORIGINAL LEADER AND FRONTMAN"),
        ("HIS SHOWCASES", "TURN ON YOUR LOVE LIGHT AND GOOD LOVIN', BELTED OUT AT THE FRONT OF THE STAGE"),
        ("ON STAGE", "ABOUT 740 SHOWS, FROM THE FIRST IN 1965 TO JUNE 17, 1972, AT THE HOLLYWOOD BOWL"),
    ],
    "KEITH GODCHAUX": [
        ("BORN", "JULY 19, 1948, IN SEATTLE. RAISED IN CONCORD, CALIFORNIA, HE PLAYED DIXIELAND AND COCKTAIL JAZZ AS A TEENAGER"),
        ("MEETING THE BAND", "IN 1971 DONNA INTRODUCED HIM TO JERRY, AND THAT FALL HE WAS ASKED TO JOIN"),
        ("FIRST SHOW", "OCTOBER 19, 1971, AT NORTHROP AUDITORIUM, UNIVERSITY OF MINNESOTA"),
        ("THE GRAND PIANO", "FROM 1972 TO 1974 HE PLAYED A FULL ACOUSTIC GRAND ON STAGE, FITTED WITH A SPECIAL PICKUP"),
        ("FAMILY", "HE MARRIED DONNA JEAN IN 1970. THEIR SON ZION PLAYS IN THE BAND BOOMBOX"),
        ("ON STAGE", "ABOUT 440 SHOWS, 1971-79, THEN THE HEART OF GOLD BAND WITH DONNA IN 1980"),
    ],
    "BRENT MYDLAND": [
        ("BORN", "OCTOBER 21, 1952, IN MUNICH, GERMANY, SON OF A U.S. ARMY CHAPLAIN. HE GREW UP IN CONCORD, CALIFORNIA"),
        ("SCHOOL DAYS", "CLASSICAL PIANO FROM AGE SIX, AND TRUMPET IN THE MARCHING BAND - UNTIL HE WAS DISMISSED FOR LONG HAIR"),
        ("JOINING THE DEAD", "AFTER THE BAND SILVER AND BOB WEIR'S BOBBY AND THE MIDNITES, HE PLAYED HIS FIRST DEAD SHOW APRIL 22, 1979"),
        ("HIS SONGS", "FAR FROM ME, EASY TO LOVE YOU AND TONS OF STEEL, AND HE CO-WROTE HELL IN A BUCKET"),
        ("BUILT TO LAST", "FOUR OF HIS SONGS ARE ON THE 1989 ALBUM, INCLUDING I WILL TAKE YOU HOME, A LULLABY FOR HIS DAUGHTERS"),
        ("ON STAGE", "ABOUT 810 SHOWS, 1979-90, THE LONGEST RUN OF ANY DEAD KEYBOARD PLAYER"),
    ],
    "VINCE WELNICK": [
        ("BORN", "FEBRUARY 21, 1951, IN PHOENIX, ARIZONA"),
        ("THE TUBES", "THE SAN FRANCISCO THEATER-ROCK BAND, WITH MTV HITS TALK TO YA LATER AND SHE'S A BEAUTY. HE ALSO TOURED WITH TODD RUNDGREN"),
        ("FIRST SHOW", "SEPTEMBER 7, 1990, AT THE RICHFIELD COLISEUM IN OHIO, CHOSEN PARTLY FOR HIS HIGH HARMONY VOICE"),
        ("YO VINNIE", "FANS CHEERED HIS NERVOUS FIRST SHOWS WITH YO VINNIE BANNERS. HE NAMED HIS PUBLISHING COMPANY FOR THEM"),
        ("ON STAGE", "ABOUT 380 SHOWS, 1990-95, WITH BRUCE HORNSBY ALONGSIDE ON GRAND PIANO FOR OVER 100"),
        ("AFTER THE DEAD", "RATDOG WITH BOB WEIR, PHIL LESH AND FRIENDS, AND THE MICKEY HART BAND"),
    ],
    "PHIL LESH": [
        ("BORN", "MARCH 15, 1940, IN BERKELEY, CALIFORNIA. HE STARTED ON VIOLIN AT EIGHT, THEN TRUMPET"),
        ("THE COMPOSER", "HE WANTED TO COMPOSE, AND IN 1962 STUDIED WITH LUCIANO BERIO AT MILLS COLLEGE, ALONGSIDE STEVE REICH"),
        ("MEETING JERRY", "AS A VOLUNTEER ENGINEER AT KPFA RADIO, HE INVITED JERRY TO PLAY ON THE STATION"),
        ("THE BASS", "IN 1965 JERRY ASKED HIM TO PLAY BASS IN THE WARLOCKS. HE HAD NEVER PLAYED ONE"),
        ("HIS SOUND", "HE SAID HIS BASS LINES OWED MORE TO BACH'S COUNTERPOINT THAN TO ROCK AND SOUL BASSISTS"),
        ("AFTER THE DEAD", "PHIL LESH AND FRIENDS, HIS VENUE TERRAPIN CROSSROADS, AND FURTHUR WITH BOB WEIR"),
    ],
    "BILL GRAHAM": [
        ("BORN", "WULF WOLODIA GRAJONCA, JANUARY 8, 1931, IN BERLIN. HE ESCAPED NAZI GERMANY AS A CHILD"),
        ("THE NAME", "GROWING UP IN THE BRONX, HE FOUND GRAHAM IN THE PHONE BOOK - THE CLOSEST NAME TO GRAJONCA"),
        ("KOREA", "HE SERVED IN THE KOREAN WAR AND EARNED THE BRONZE STAR AND THE PURPLE HEART"),
        ("THE FILLMORE", "A BENEFIT FOR THE SAN FRANCISCO MIME TROUPE LED TO THE FILLMORE, THEN FILLMORE WEST AND EAST AND WINTERLAND. THE DEAD WERE A FAVORITE"),
        ("BIG SHOWS", "WATKINS GLEN IN 1973, DAYS ON THE GREEN IN OAKLAND, AND THE U.S. HALF OF LIVE AID IN 1985"),
        ("IN TRIBUTE", "SAN FRANCISCO'S CIVIC AUDITORIUM NOW BEARS HIS NAME, AND HE ENTERED THE ROCK HALL OF FAME IN 1992"),
    ],
    "DONNA JEAN GODCHAUX": [
        ("BORN", "DONNA JEAN THATCHER, AUGUST 22, 1947, IN FLORENCE, ALABAMA"),
        ("MUSCLE SHOALS", "A SESSION SINGER ON WHEN A MAN LOVES A WOMAN, ELVIS'S SUSPICIOUS MINDS, AND RECORDS BY BOZ SCAGGS, DUANE ALLMAN AND CHER"),
        ("KEITH", "SHE MARRIED KEITH GODCHAUX IN 1970, AND IN 1971 INTRODUCED HIM TO JERRY"),
        ("ON STAGE", "ABOUT 410 SHOWS FROM THE END OF 1971 TO FEBRUARY 1979, SINGING MEZZO-SOPRANO"),
        ("THE GARCIA BAND", "WITH KEITH SHE PLAYED 146 NIGHTS IN THE JERRY GARCIA BAND, 1976-78"),
        ("LATER", "THE DONNA JEAN GODCHAUX BAND FROM 2009, AND THE ALABAMA MUSIC HALL OF FAME IN 2016"),
    ],
    "BOB WEIR": [
        ("BORN", "OCTOBER 16, 1947, IN SAN FRANCISCO. HE GREW UP IN ATHERTON AND TOOK UP GUITAR AT 13"),
        ("NEW YEAR'S EVE 1963", "AT 16 HE FOLLOWED BANJO MUSIC TO A PALO ALTO MUSIC STORE, MET JERRY, AND THEY PLAYED ALL NIGHT"),
        ("THE BEATLES", "THE BEATLES WERE WHY WE TURNED FROM A JUG BAND INTO A ROCK 'N' ROLL BAND, HE SAID"),
        ("HIS GUITAR", "HE PLAYED CHORD VOICINGS YOU'D EXPECT FROM A PIANO, INSPIRED BY JAZZ PIANIST MCCOY TYNER"),
        ("ACE", "HIS 1972 SOLO ALBUM, WITH THE DEAD AS HIS BAND - THE HOME OF CASSIDY AND MEXICALI BLUES"),
        ("THE BANDS", "KINGFISH, BOBBY AND THE MIDNITES, RATDOG, FURTHUR AND DEAD & COMPANY - WITH A FAREWELL IN GOLDEN GATE PARK, AUGUST 2025"),
    ],
    "ROBERT HUNTER": [
        ("BORN", "ROBERT BURNS, JUNE 23, 1941, IN ARROYO GRANDE, CALIFORNIA. HE WROTE A 50-PAGE FAIRY TALE BEFORE HE WAS 11"),
        ("BOB AND JERRY", "HE AND JERRY MET IN PALO ALTO IN 1961, AND PLAYED THEIR FIRST GIG AS A DUO THAT MAY"),
        ("THE FIRST ALBUM", "HIS WORK WITH THE BAND TOOK OFF ON 1969'S AOXOMOXOA"),
        ("THE SONGS", "DARK STAR, RIPPLE, TRUCKIN', CHINA CAT SUNFLOWER, TERRAPIN STATION, AND MANY MORE"),
        ("THE HALL OF FAME", "IN 1994 HE BECAME THE ONLY NON-PERFORMER EVER INDUCTED AS A MEMBER OF A BAND"),
        ("IN TRIBUTE", "ROLLING STONE CALLED HIM ONE OF ROCK'S MOST AMBITIOUS AND DAZZLING LYRICISTS"),
    ],
    "JOHN PERRY BARLOW": [
        ("BORN", "OCTOBER 3, 1947, NEAR CORA, WYOMING, ON THE BAR CROSS RANCH - WHICH HE LATER RAN FOR ALMOST 20 YEARS"),
        ("BOBBY", "HE MET BOB WEIR AT 15, AT THE FOUNTAIN VALLEY SCHOOL IN COLORADO SPRINGS"),
        ("THE FIRST SONGS", "IN LATE 1971, FOR BOBBY'S SOLO ALBUM: CASSIDY, MEXICALI BLUES AND BLACK-THROATED WIND"),
        ("THE SONGS", "ESTIMATED PROPHET, THE MUSIC NEVER STOPPED, HELL IN A BUCKET AND THROWING STONES"),
        ("WITH BRENT", "FOUR SONGS WITH BRENT MYDLAND ON 1989'S BUILT TO LAST"),
        ("THE INTERNET", "HE CO-FOUNDED THE ELECTRONIC FRONTIER FOUNDATION IN 1990"),
    ],
    "OWSLEY STANLEY": [
        ("BORN", "AUGUSTUS OWSLEY STANLEY III, JANUARY 19, 1935, GRANDSON OF A GOVERNOR OF KENTUCKY"),
        ("THE ENGINEER", "HE WORKED AS A TEST ENGINEER AT ROCKETDYNE, THEN AS AN AIR FORCE ELECTRONICS SPECIALIST"),
        ("THE DANCER", "INSPIRED BY THE BOLSHOI BALLET IN 1958, HE STUDIED BALLET AND DANCED PROFESSIONALLY"),
        ("BEAR", "AS BEAR HE WAS THE DEAD'S SOUND ENGINEER, AND RECORDED MANY OF THEIR SHOWS"),
        ("THE WALL OF SOUND", "HE DEVELOPED IT - ONE OF THE BIGGEST TOURING SOUND SYSTEMS EVER BUILT"),
        ("THE SKULL", "HE HELPED BOB THOMAS DESIGN THE BAND'S LIGHTNING-BOLT SKULL"),
    ],
    "KEN KESEY": [
        ("BORN", "SEPTEMBER 17, 1935, IN LA JUNTA, COLORADO. HE GREW UP IN SPRINGFIELD, OREGON"),
        ("THE WRESTLER", "A CHAMPION WRESTLER WHO NEARLY MADE THE OLYMPIC TEAM"),
        ("CUCKOO'S NEST", "INSPIRED BY NIGHT SHIFTS AT A VETERANS' HOSPITAL. THE 1975 FILM WON ALL FIVE TOP ACADEMY AWARDS"),
        ("FURTHUR", "IN 1964 HE AND THE MERRY PRANKSTERS CROSSED THE COUNTRY IN A PAINTED SCHOOL BUS"),
        ("THE ACID TESTS", "HIS 1965-66 PARTIES, WITH THE DEAD AS HOUSE BAND. HE MENTORED THE BAND FROM THEN ON"),
        ("WINTERLAND", "HE WAS INTERVIEWED BETWEEN SETS AT THE CLOSING OF WINTERLAND, NEW YEAR'S EVE 1978"),
    ],
    "BILL WALTON": [
        ("BORN", "NOVEMBER 5, 1952, IN LA MESA, CALIFORNIA. HIS FATHER TAUGHT MUSIC, HIS MOTHER WAS A LIBRARIAN"),
        ("UCLA", "UNDER JOHN WOODEN: NATIONAL TITLES IN 1972 AND 1973, AND AN 88-GAME WINNING STREAK"),
        ("44 POINTS", "IN THE 1973 TITLE GAME HE HIT 21 OF 22 SHOTS - STILL THE RECORD FOR A CHAMPIONSHIP GAME"),
        ("THE NBA", "THE FIRST PICK IN 1974. HE LED PORTLAND TO THE 1977 TITLE, WAS MVP IN 1978, AND WON AGAIN WITH BOSTON IN 1986"),
        ("THE DEADHEAD", "HE SAW HIS FIRST SHOWS IN HIGH SCHOOL IN 1967, MORE THAN 850 IN ALL, AND WENT TO EGYPT IN 1978"),
        ("ON THE AIR", "HE OVERCAME A STUTTER TO WIN AN EMMY, AND HOSTED ONE MORE SATURDAY NIGHT ON THE DEAD CHANNEL"),
    ],
    "RAM ROD": [
        ("BORN", "LARRY SHURTLIFF, APRIL 19, 1945"),
        ("THE NICKNAME", "IN MEXICO WITH KEN KESEY HE BOASTED HE WAS RAMON RODRIGUEZ RODRIGUEZ, THE FAMOUS MEXICAN GUIDE"),
        ("THE BUG", "AFTER HE RAMRODDED SEVEN ADULTS INTO A VOLKSWAGEN BEETLE, NEAL CASSADY CALLED HIM RAM ROD"),
        ("THE TRUCK", "HE STARTED IN 1967 DRIVING THE TOUR TRUCK, AND BECAME HEAD ROADIE AND EQUIPMENT MANAGER"),
        ("THE PRESIDENT", "PRESIDENT OF GRATEFUL DEAD PRODUCTIONS FROM 1976, WHEN THE BAND INCORPORATED, TO 1995"),
        ("GARCIA", "HE CO-PRODUCED JERRY'S 1972 SOLO ALBUM, GARCIA"),
    ],
    "ROCK SCULLY": [
        ("BORN", "AUGUST 1, 1941, IN SEATTLE - JERRY'S BIRTHDAY, A YEAR EARLIER. HE GREW UP IN CARMEL AND EUROPE"),
        ("CIVIL RIGHTS", "IN 1965 HE SERVED A MONTH IN JAIL FOR A CIVIL RIGHTS DEMONSTRATION"),
        ("THE MANAGER", "AFTER SEEING THE DEAD AT AN ACID TEST, HE SIGNED ON AS THEIR MANAGER ALMOST AT ONCE"),
        ("THE DEAL", "HE BOOKED THE FILLMORE AND THE AVALON, AND HELPED SIGN THE BAND TO WARNER BROS."),
        ("BIG STAGES", "HE GOT THE BAND INTO THE MONTEREY POP FESTIVAL AND WOODSTOCK"),
        ("THE BOOK", "HIS 1995 MEMOIR, LIVING WITH THE DEAD, COVERS 20 YEARS ON THE BUS"),
    ],
    "REX JACKSON": [
        ("BORN", "DONALD REX JACKSON, OCTOBER 27, 1945, IN HERMISTON, OREGON"),
        ("THE ROADIE", "HE JOINED IN THE MID-1960S AS AN EQUIPMENT TECHNICIAN, AND BECAME ROAD MANAGER IN 1976"),
        ("SUNRISE", "DONNA'S SONG SUNRISE, ON TERRAPIN STATION, WAS WRITTEN AFTER A SUNRISE CEREMONY HONORING HIM"),
        ("THE REX FOUNDATION", "THE BAND AND FRIENDS NAMED THEIR CHARITY FOR HIM WHEN THEY FOUNDED IT IN 1983"),
        ("THE FIRST BENEFITS", "SPRING 1984 AT THE MARIN VETERANS MEMORIAL AUDITORIUM - MORE THAN 40 REX BENEFIT SHOWS FOLLOWED"),
        ("THE GRANTS", "$8.2 MILLION TO SOME 1,000 RECIPIENTS. JERRY AND BILL GRAHAM SERVED ON ITS BOARD"),
    ],
    "JOHN KAHN": [
        ("BORN", "JUNE 13, 1947, IN MEMPHIS. HE GREW UP IN BEVERLY HILLS, WHERE MARILYN MONROE ONCE BABYSAT HIM"),
        ("THE PRODIGY", "HIS SYMPHONIC PIECE WAS THE FIRST STUDENT WORK EVER PLAYED BY BEVERLY HILLS HIGH'S ORCHESTRA"),
        ("THE SESSIONS", "BASS FOR MIKE BLOOMFIELD, JOHN LEE HOOKER, AND BREWER & SHIPLEY'S ONE TOKE OVER THE LINE"),
        ("MEETING JERRY", "MAY 1970, AT MONDAY NIGHT JAMS AT THE MATRIX IN SAN FRANCISCO"),
        ("WITH JERRY", "OLD & IN THE WAY, THE SAUNDERS-GARCIA BAND, LEGION OF MARY AND RECONSTRUCTION"),
        ("THE GARCIA BAND", "THE ONLY FOUNDING MEMBER BESIDES JERRY TO STAY TO THE END - HIS PARTNER OUTSIDE THE DEAD, 1970-95"),
    ],
    "MERL SAUNDERS": [
        ("BORN", "FEBRUARY 14, 1934, IN SAN MATEO, CALIFORNIA. JOHNNY MATHIS SANG IN HIS FIRST HIGH SCHOOL BAND"),
        ("THE MATRIX", "IN 1971 HE BEGAN PLAYING WITH JERRY AT THE MATRIX, A SMALL SAN FRANCISCO CLUB"),
        ("LEGION OF MARY", "THEIR SAUNDERS-GARCIA BAND MADE THREE ALBUMS AND BECAME LEGION OF MARY IN 1974"),
        ("1986", "AFTER JERRY'S ILLNESS THAT SUMMER, MERL LED THE WAY IN HELPING HIM RELEARN THE GUITAR"),
        ("THE RAINFOREST", "HIS 1990 BLUES FROM THE RAINFOREST, WITH JERRY - ONE TRACK ENDED UP ON BAYWATCH"),
        ("TWILIGHT ZONE", "HE WORKED WITH THE DEAD ON THE THEME FOR THE 1985 SERIES, AND WAS ITS MUSICAL DIRECTOR"),
    ],
    "ROB WASSERMAN": [
        ("BORN", "APRIL 1, 1952. HE STARTED ON VIOLIN, MOVED TO BASS, AND STUDIED COMPOSING WITH JOHN ADAMS"),
        ("SOLO", "HIS 1983 ALBUM WON DOWN BEAT'S RECORD OF THE YEAR"),
        ("DUETS", "THE 1988 ALBUM DREW THREE GRAMMY NOMINATIONS. BOBBY MCFERRIN WON FOR BROTHERS, WITH ROB"),
        ("TRIOS", "ON DUETS AND TRIOS HE PLAYED WITH JERRY, BOB WEIR, NEIL YOUNG, LOU REED AND MORE"),
        ("RATDOG", "HE CO-FOUNDED RATDOG WITH BOB WEIR"),
        ("LOU REED", "HE TOURED WIDELY WITH LOU REED, AND PLAYED ON HIS ALBUM NEW YORK"),
    ],
}
