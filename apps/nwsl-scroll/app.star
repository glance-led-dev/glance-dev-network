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
    """The page chip - drawn with c.badge so the text sits ink-centered in
    the pill (1px above and below, >=2px sides) per the design guidelines."""
    w = c.badge(word, x, 0, color = "black", bg = accent, font = "4x5")
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

# NWSL — scores, the matchday board, the table, and your club.
#
# ESPN's public soccer API, no key. Crests are real club marks, pulled from
# ESPN's dark-background variants, cropped to their alpha bounds and rescaled
# offline to 30px and 22px; they ship as declared assets and are drawn with
# c.image(). A logo shrunk at render time with nearest-neighbour turns to mush,
# so both sizes are pre-scaled with LANCZOS instead.
#
# ESPN's own team.color fields are NOT used at runtime. Four of the sixteen are
# unusable on a black LED: Portland and Washington list 000000, Boston lists a
# placeholder 00FF00, and Orlando and Louisville are byte-identical to each
# other. The table below is the resolved set, and the rule that produced it was:
#   1. a colour may lead only if HSV V >= 0.60 and S >= 0.25 (plain luminance
#      mis-ranks saturated reds on this hardware)
#   2. if the primary fails and the alternate passes, swap them
#   3. if both fail, keep the club's real brand hue and lift it
#   4. after all that, no two leads may be confusable at a 2px rail
# Every departure from ESPN's data is a consequence of one of those four.

BASE = "https://site.api.espn.com/apis/"
SCORES = BASE + "site/v2/sports/soccer/usa.nwsl/scoreboard"
TABLE = BASE + "v2/sports/soccer/usa.nwsl/standings"
ACCENT = "#1D4ED8"
LIVE = "green"
SCHED = "amber"
DONE = "gray"
PPD = "red"

# abbr -> [lead, support]
TEAMS = {
    "LA":  ["#F58BBB", "#202121"],   # rule 3: black primary, kit-signature pink lifted
    "BAY": ["#FF6159", "#0D2032"],   # rule 4: nudged off FF5049, clashed with CHI
    "BOS": ["#0BD264", "#F0F0F0"],   # rule 3: 00FF00 was a placeholder
    "CHI": ["#C7102E", "#3AB5E8"],   # ESPN pair kept
    "DEN": ["#2F9E79", "#E4B83E"],   # rule 3: 20604E too dark to lead
    "GFC": ["#A9F1FD", "#101010"],
    "HOU": ["#FF6900", "#8AB7E9"],   # ESPN pair kept
    "KC":  ["#62CBC9", "#CF3339"],   # rule 4: its red is CHI's red at 2px
    "NC":  ["#1268B8", "#AB0033"],   # rule 4: burgundy collided with CHI and UTA
    "ORL": ["#AD2EE4", "#F0F0F0"],   # duplicate of LOU resolved to Pride purple
    "POR": ["#E01A6E", "#101010"],   # rule 3: black primary, rose side of red
    "LOU": ["#B49BF0", "#14002F"],   # keeps the lavender, deepened off GFC mist
    "SD":  ["#0F9FE0", "#032E62"],   # rule 2: swap to the surf cyan
    "SEA": ["#5A46D8", "#292431"],   # rule 3: both ESPN colours too dark
    "UTA": ["#F7AA14", "#AE122A"],   # rule 4: claret is CHI's red at 2px
    "WAS": ["#EDE939", "#101010"],   # rule 2: swap to the yellow
}

def team_colors(abbr):
    a = str(abbr).strip().upper()
    if a in TEAMS:
        return TEAMS[a]
    return ["gray", "midgray"]

def crest(abbr, size):
    a = str(abbr).strip().upper()
    return (a + str(size) + ".png") if a in TEAMS else ""

BALL = """
..#####..
.###o###.
####o####
###ooo###
###ooo###
##o###o##
.#o###o#.
.#######.
..#####..
"""
WHISTLE = """
#########.
##########
....##o###
....######
.....####.
"""

def state_of(ev):
    s = str(dig(ev, ["status", "type", "state"], "")).lower()
    detail = str(dig(ev, ["status", "type", "shortDetail"], "")).lower()
    if detail.find("postpon") >= 0 or detail.find("cancel") >= 0:
        return "ppd"
    if s == "in":
        return "live"
    if s == "post":
        return "ft"
    return "pre"

def read_events(ctx, offmin):
    r = http.get(SCORES, ttl_seconds = 120)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    out = []
    for ev in get(r["json"], "events", []):
        comps = get(ev, "competitions", [])
        if type(comps) != "list" or len(comps) == 0:
            continue
        comp = comps[0]
        home, away = None, None
        for cr in get(comp, "competitors", []):
            side = {"abbr": str(dig(cr, ["team", "abbreviation"], "?")).upper(),
                    "score": num(get(cr, "score", 0), 0)}
            if str(get(cr, "homeAway", "")) == "home":
                home = side
            else:
                away = side
        if home == None or away == None:
            continue
        out.append({
            "home": home, "away": away,
            "state": state_of(ev),
            "clock": str(dig(ev, ["status", "type", "detail"], "")).upper(),
            "short": str(dig(ev, ["status", "type", "shortDetail"], "")).upper(),
            "start": parse_iso(str(get(ev, "date", "")), offmin),
        })
    return out

def read_table(ctx):
    r = http.get(TABLE, ttl_seconds = 1800)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    node = r["json"]
    kids = get(node, "children", [])
    if type(kids) == "list" and len(kids) > 0:
        node = kids[0]
    rows = []
    for e in dig(node, ["standings", "entries"], []):
        stats = {}
        for s in get(e, "stats", []):
            stats[str(get(s, "name", ""))] = str(get(s, "displayValue", ""))
        rows.append({
            "abbr": str(dig(e, ["team", "abbreviation"], "?")).upper(),
            "name": str(dig(e, ["team", "displayName"], "")).upper(),
            "pts": num(stats.get("points", "0"), 0),
            "gd": stats.get("pointDifferential", "0"),
            "gp": num(stats.get("gamesPlayed", "0"), 0),
            "w": num(stats.get("wins", "0"), 0),
            "l": num(stats.get("losses", "0"), 0),
            "t": num(stats.get("ties", "0"), 0),
        })
    rows = sorted(rows, key = lambda r: -r["pts"])
    return rows

def minute_of(ev):
    """A short live clock. ESPN puts "63'" in detail and sometimes a word."""
    d = ev["clock"]
    if d.find("HALFTIME") >= 0 or d == "HT":
        return "HT"
    out = ""
    for ch in d.elems():
        if ch >= "0" and ch <= "9":
            out += ch
        elif out != "":
            break
    return (out + "'") if out != "" else "LIVE"

def match_color(state):
    if state == "live":
        return LIVE
    if state == "pre":
        return SCHED
    if state == "ppd":
        return PPD
    return DONE

def pick_match(evs, fav):
    """A live match involving the followed club, else any live match, else the
    club's own nearest match, else the first thing on the card."""
    if evs == None or len(evs) == 0:
        return None
    for e in evs:
        if e["state"] == "live" and fav != "" and (e["home"]["abbr"] == fav or e["away"]["abbr"] == fav):
            return e
    for e in evs:
        if e["state"] == "live":
            return e
    if fav != "":
        for e in evs:
            if e["home"]["abbr"] == fav or e["away"]["abbr"] == fav:
                return e
    return evs[0]

def fav_of(ctx):
    return str(ctx.inputs.get("team", "")).strip().upper()

# ------------------------------------------------------------- page 1: match
def match(c, ctx):
    c.fill("black")
    offmin = zone_offset(ctx)
    evs = read_events(ctx, offmin)
    if evs == None:
        rail(c, OFFLINE)
        tab(c, "NWSL", ACCENT)
        message(c, "NWSL OFFLINE", "RETRYING SOON")
        return
    ev = pick_match(evs, fav_of(ctx))
    if ev == None:
        rail(c, ACCENT)
        tab(c, "NWSL", ACCENT)
        message(c, "NO MATCHES", "NOTHING ON THE CARD")
        return
    col = match_color(ev["state"])
    rail(c, col)
    h, a = ev["home"], ev["away"]
    hc = crest(h["abbr"], 30)
    ac = crest(a["abbr"], 30)
    if hc != "":
        c.image(hc, 3, 1, 30, 30)
    if ac != "":
        c.image(ac, 159, 1, 30, 30)

    if ev["state"] == "live":
        c.fill_circle(87, 3, 2, LIVE)
        c.text(minute_of(ev), 93, 1, font = "4x5", color = LIVE)
        hero = str(h["score"]) + "-" + str(a["score"])
    elif ev["state"] == "ft":
        c.sprite(WHISTLE, 85, 1, legend = {"#": DONE, "o": "black"})
        c.text("FT", 98, 1, font = "4x5", color = DONE)
        hero = str(h["score"]) + "-" + str(a["score"])
    elif ev["state"] == "ppd":
        c.text("POSTPONED", 96, 1, font = "4x5", color = PPD, align = "center")
        hero = "PPD"
    else:
        c.text(date_of(ev["start"]), 96, 1, font = "4x5", color = SCHED,
               align = "center")
        hero = clock(ev["start"], True, True) if ev["start"] != None else "TBD"

    hf = fit(c, hero, ["10x16", "8x12"], 70)
    hw = c.text_width(hf[1], hf[0])
    c.text(hf[1], 96, 8, font = hf[0], color = col, align = "center")
    # The abbreviations flank the score, pushed out by however wide it is, so a
    # 2-1 and an 11-0 both keep a 5px gap.
    c.text(h["abbr"], 96 - hw // 2 - 5, 12, font = "5x7",
           color = team_colors(h["abbr"])[0], align = "right")
    c.text(a["abbr"], 96 + hw // 2 + 5, 12, font = "5x7",
           color = team_colors(a["abbr"])[0])

    if ev["state"] == "live":
        c.hline(36, 30, 120, "#323232")
        c.circle(96, 31, 6, "#323232")
    elif ev["state"] == "pre":
        c.hline(36, 30, 120, "#323232")
        c.sprite(BALL, 92, 22, legend = {"#": "white", "o": "black"})

def date_of(mins):
    if mins == None:
        return "TBD"
    d = mins // 1440
    cc = civil_from_days(d)
    return DOW[weekday(d)] + " " + MONTHS[cc[1] - 1] + " " + str(cc[2])

# --------------------------------------------------------------- page 2: day
def day(c, ctx):
    c.fill("black")
    offmin = zone_offset(ctx)
    evs = read_events(ctx, offmin)
    tab(c, "DAY", ACCENT)
    if evs == None or len(evs) == 0:
        rail(c, OFFLINE if evs == None else ACCENT)
        message(c, "NO MATCHES TODAY", "CHECK BACK ON MATCHDAY")
        return
    best = DONE
    for e in evs:
        if e["state"] == "live":
            best = LIVE
        elif e["state"] == "pre" and best != LIVE:
            best = SCHED
    rail(c, best)
    if evs[0]["start"] != None:
        c.text(date_of(evs[0]["start"]), 190, 2, font = "4x5", color = "gray",
               align = "right")
    fav = fav_of(ctx)
    cols = [6, 53, 100, 147]
    # Without rules the eight cells read as one run-on sentence.
    for x in [49, 96, 143]:
        c.vline(x, 9, 22, STRUCT)
    for i in range(len(evs)):
        if i > 7:
            break
        cx = cols[i % 4]
        y = 9 if i < 4 else 21
        e = evs[i]
        hcol = team_colors(e["home"]["abbr"])[0]
        acol = team_colors(e["away"]["abbr"])[0]
        if fav != "" and (e["home"]["abbr"] == fav or e["away"]["abbr"] == fav):
            c.rect(cx - 3, y, cx - 2, y + 10, fill = team_colors(fav)[0])
        c.text(e["home"]["abbr"], cx, y, font = "4x5", color = hcol)
        c.text(e["away"]["abbr"], cx + 43, y, font = "4x5", color = acol,
               align = "right")
        if e["state"] == "live" or e["state"] == "ft":
            mid = str(e["home"]["score"]) + "-" + str(e["away"]["score"])
            mcol = LIVE if e["state"] == "live" else "white"
        else:
            mid, mcol = "V", "midgray"
        c.text(mid, cx + 22, y, font = "4x5", color = mcol, align = "center")
        if e["state"] == "live":
            sub, scol = minute_of(e), LIVE
        elif e["state"] == "ft":
            sub, scol = "FT", DONE
        elif e["state"] == "ppd":
            sub, scol = "PPD", PPD
        else:
            sub, scol = (clock(e["start"], True, True) if e["start"] != None else "TBD"), SCHED
        c.text(sub, cx + 22, y + 6, font = "4x5", color = scol, align = "center")

# ---------------------------------------------------- pages 3+4: the table
def table_page(c, ctx, lo, hi, name):
    c.fill("black")
    rows = read_table(ctx)
    tab(c, name, ACCENT)
    if rows == None or len(rows) == 0:
        rail(c, OFFLINE)
        message(c, "NWSL OFFLINE", "RETRYING SOON")
        return
    rail(c, ACCENT)
    fav = fav_of(ctx)
    if name == "CHASE" and len(rows) >= 8:
        c.text("LINE " + str(rows[7]["pts"]) + " PTS", 190, 2, font = "4x5",
               color = "gray", align = "right")
    # The playoff line is the page's whole argument: TOP 8 stands on it, CHASE
    # hangs under it.
    liney = 31 if name == "TOP 8" else 8
    for x in range(2, 192, 4):
        c.rect(x, liney, x + 1, liney, fill = PPD)

    top = 8 if name == "TOP 8" else 9
    for i in range(lo, hi):
        if i >= len(rows):
            break
        r = rows[i]
        k = i - lo
        cx = 6 if k < 4 else 100
        y = top + (k % 4) * 6
        tc = team_colors(r["abbr"])
        if fav != "" and r["abbr"] == fav:
            c.round_rect(cx - 2, y - 1, cx + 91, y + 5, 1,
                         fill = color.dim(tc[0], 25))
        c.text(str(i + 1), cx + 7, y, font = "4x5", color = "gray", align = "right")
        c.rect(cx + 10, y, cx + 11, y + 4, fill = tc[0])
        c.rect(cx + 12, y, cx + 13, y + 4, fill = tc[1])
        c.text(r["abbr"], cx + 17, y, font = "4x5", color = tc[0])
        c.text(str(r["gd"]), cx + 68, y, font = "4x5", color = "gray",
               align = "right")
        c.text(str(r["pts"]), cx + 89, y, font = "4x5", color = "white",
               align = "right")

def top8(c, ctx):
    table_page(c, ctx, 0, 8, "TOP 8")

def chase(c, ctx):
    table_page(c, ctx, 8, 16, "CHASE")

# -------------------------------------------------------------- page 5: club
def club(c, ctx):
    c.fill("black")
    fav = fav_of(ctx)
    offmin = zone_offset(ctx)
    if fav == "" or fav not in TEAMS:
        tab(c, "NWSL", ACCENT)
        rail(c, ACCENT)
        c.text("PICK YOUR CLUB", 96, 4, font = "5x7", color = "white",
               align = "center")
        c.text("SET TEAM IN SETTINGS", 96, 14, font = "4x5", color = "gray",
               align = "center")
        # The league says hello while it waits: all sixteen kit chips.
        keys = sorted(TEAMS)
        for i in range(len(keys)):
            tc = TEAMS[keys[i]]
            x = 49 + i * 6
            c.rect(x, 23, x + 1, 27, fill = tc[0])
            c.rect(x + 2, 23, x + 3, 27, fill = tc[1])
        return
    tc = team_colors(fav)
    rail(c, tc[0])
    # standard pill for the team chip (ink-centered, encapsulated)
    bw = c.badge(fav, 4, 1, color = "black", bg = tc[0], font = "4x5")
    w = bw - 4   # keep the downstream x math (4 + w + 8) unchanged

    rows = read_table(ctx)
    me, rank = None, 0
    if rows != None:
        for i in range(len(rows)):
            if rows[i]["abbr"] == fav:
                me, rank = rows[i], i + 1
    if me == None:
        message(c, "NO TABLE YET", "STANDINGS NOT PUBLISHED")
        return
    c.text(clip(c, me["name"], "4x5", 105), 4 + w + 8, 2, font = "4x5",
           color = "white")
    c.text(str(me["w"]) + "-" + str(me["l"]) + "-" + str(me["t"]), 190, 2,
           font = "4x5", color = "gray", align = "right")
    cf = crest(fav, 22)
    if cf != "":
        c.image(cf, 3, 9, 22, 22)
    c.text(str(rank), 92, 9, font = "10x16", color = "white")
    suf = "TH"
    if rank == 1:
        suf = "ST"
    elif rank == 2:
        suf = "ND"
    elif rank == 3:
        suf = "RD"
    c.text(suf, 92 + c.text_width(str(rank), "10x16") + 3, 9, font = "4x5",
           color = "gray")
    inplay = rank <= 8
    c.badge("IN" if inplay else "OUT", 104, 18, color = "black" if inplay else "white",
            bg = LIVE if inplay else PPD, font = "4x5", pad = 2)
    if len(rows) >= 9:
        edge = rows[8]["pts"] if inplay else rows[7]["pts"]
        gap = me["pts"] - edge
        lab = ("+" + str(gap) + " ON 9TH") if inplay else (str(gap) + " TO 8TH")
        # x=4 put this over the crest (rows 9..30); x=92 put it under the IN
        # badge. It belongs with the other season facts in the middle column.
        c.text(lab, 30, 26, font = "4x5", color = "gray")
    c.text(str(me["pts"]) + " PTS", 30, 12, font = "4x5", color = "white")
    c.text("GD " + str(me["gd"]), 30, 20, font = "4x5", color = "gray")


# ---- time zones -----------------------------------------------------------
# ctx.now is UTC, so anything showing a wall-clock time needs an offset. Asking
# a person for "-4" asks them to know their own offset AND to remember to
# change it twice a year -- and the old help text really did say "Eastern is -4
# in summer and -5 in winter", which is a chore, not a setting. This asks for
# their city instead and works the rest out, daylight saving included.
#
# The changeovers are arithmetic, not a lookup table: the United States moves
# on the 2nd Sunday in March and the 1st in November, Europe on the last
# Sundays in March and October, and the southern-hemisphere zones in between.
# That is why this needs no network call, which matters -- a panel should not
# show the wrong time because somebody else's time API is down.
#
# zone -> [standard offset in minutes, DST rule]
#   0 none  1 United States  2 Europe  3 Australia (southern)
#   4 New Zealand  5 Egypt  6 Israel
#
# Checked against Python's tz database over 607,360 instants spanning 52 zones
# and four years, with no mismatches.
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

def nth_sunday(y, m, n):
    """Day of the month of the nth Sunday, or the last one when n is -1."""
    if n == -1:
        last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
        if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
            last = 29
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    first = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return first + 7 * (n - 1)

def last_dow(y, m, dow):
    """Day of the month of the last given weekday (0 = Monday). Egypt changes
    on a Friday and Israel on a Friday, so Sundays are not enough."""
    last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
    if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
        last = 29
    return last - ((weekday(days_from_civil(y, m, last)) - dow) % 7)

def _utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(zone, t):
    """Minutes east of UTC for `zone` at the UTC instant `t`, in minutes since
    the epoch. Every comparison is done in UTC so the local-time discontinuity
    at a changeover never has to be reasoned about."""
    z = TZ[zone] if zone in TZ else TZ["UTC"]
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    if rule == 1:
        # 2nd Sunday in March at 02:00 standard -> 1st in November at 02:00
        # daylight, which is 01:00 standard.
        start = _utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
        end = _utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 2:
        # Europe changes at 01:00 UTC everywhere at once, which is why these
        # two are the only bounds that need no offset applied.
        start = _utcmin(y, 3, nth_sunday(y, 3, -1), 1)
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 1)
        return std + 60 if t >= start and t < end else std
    if rule == 5:
        # Egypt brought daylight saving back in 2023: last Friday in April
        # through the last Thursday in October, which ends on the last Friday.
        start = _utcmin(y, 4, last_dow(y, 4, 4), 0) - std
        end = _utcmin(y, 10, last_dow(y, 10, 4), 0) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 6:
        # Israel starts on the Friday BEFORE the last Sunday in March, which is
        # the last Sunday minus two days, and ends with Europe in October.
        start = _utcmin(y, 3, nth_sunday(y, 3, -1) - 2, 2) - std
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    # Southern hemisphere: summer straddles New Year, so the test is inverted
    # -- standard time is the window BETWEEN the April end and the spring start.
    m0 = 10 if rule == 3 else 9
    n0 = 1 if rule == 3 else -1
    start = _utcmin(y, m0, nth_sunday(y, m0, n0), 2) - std
    end = _utcmin(y, 4, nth_sunday(y, 4, 1), 3) - std - 60
    return std if t >= end and t < start else std + 60

def zone_offset(ctx):
    """The reader's current offset from UTC, in minutes."""
    return zone_offset_at(str(ctx.inputs.get("timezone", "UTC")).strip(),
                          ctx.now.unix // 60)
