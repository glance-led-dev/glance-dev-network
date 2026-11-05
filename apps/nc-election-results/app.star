# NC Election Results (192x32)
#
# Live North Carolina results from the State Board of Elections' results
# site (er.ncsbe.gov), no key required. Pick All NC for the statewide races
# and every US House district, or one of the 100 counties for its own ballot
# down to the county commissioners, school board and local referendums.
#
# PAGES. A card (countdown, polls, then precincts, ballots and turnout), then
# 7 race pages. The top race always holds the first one; on a ballot with
# more than 7 races the other 6 move on at each refresh, and the header
# counts through them (3/20) when the title leaves room. Pages are a fixed
# list in the manifest, so a short ballot repeats its races. One-name races
# are left out: nothing to count.
#
# OVERVIEW. All NC on All races holds the next two pages for the NC
# Legislature scoreboard and Closest Races, and the other 4 rotate. County
# views and the other Show choices never get them. The scoreboard counts
# seats led, plus unopposed seats in a darker shade, and calls nothing.
#
# CANDIDATES. Up to 3 in the big font, 4 in the small font, and 5 to 8 in two
# columns of name and share. Past 8 the last spot says how many are hidden.
# Everyone hidden still counts in the percentages.
#
# COUNTY VIEW. A county file holds that county's votes only, even for a
# statewide race, so races that reach past the county get a dim third column
# from the statewide file: NC for a statewide race, DIST for a district.
#
# NO WINNERS. The feed has no winner field and election night totals leave
# out late absentee and provisional ballots, so nothing here is ever called.
# The leader is just brighter, and the card says UNOFFICIAL.
#
# NEXT ELECTION. Change ELECTION, OPEN_UNIX, CLOSE_UNIX, DAY_LABEL and
# INCUMBENTS.

ELECTION = "20261103"
BASE = "https://er.ncsbe.gov/enr/" + ELECTION + "/data/"
OPEN_UNIX = 1793705400      # 6:30 AM ET, Nov 3
CLOSE_UNIX = 1793752200     # 7:30 PM ET, Nov 3
DAY_LABEL = "TUE NOV 3"
TTL = 240

# Ballot names of sitting officeholders in the All NC view. No feed carries
# this, so it's a list by hand: US Senate, NC-11 and Appeals Seat 3 have none
# on the ballot. County views stay unmarked; a partial list would make an
# incumbent with no mark look like a challenger.
INCUMBENTS = {
    "Don Davis": True, "Deborah K. Ross": True, "Greg Murphy": True,
    "Valerie P. Foushee": True, "Virginia Foxx": True, "Addison McDowell": True,
    "David Rouzer": True, "Mark Harris": True, "Richard Hudson": True,
    "Pat Harrigan": True, "Alma S. Adams": True, "Brad Knott": True,
    "Tim Moore": True, "Anita Earls": True, "John S. Arrowood": True,
    "Tobias (Toby) Hampson": True,
}

ALL_NC = "All NC"
COUNTIES = ["All NC", "Alamance", "Alexander", "Alleghany", "Anson", "Ashe", "Avery", "Beaufort", "Bertie", "Bladen", "Brunswick", "Buncombe", "Burke", "Cabarrus", "Caldwell", "Camden", "Carteret", "Caswell", "Catawba", "Chatham", "Cherokee", "Chowan", "Clay", "Cleveland", "Columbus", "Craven", "Cumberland", "Currituck", "Dare", "Davidson", "Davie", "Duplin", "Durham", "Edgecombe", "Forsyth", "Franklin", "Gaston", "Gates", "Graham", "Granville", "Greene", "Guilford", "Halifax", "Harnett", "Haywood", "Henderson", "Hertford", "Hoke", "Hyde", "Iredell", "Jackson", "Johnston", "Jones", "Lee", "Lenoir", "Lincoln", "Macon", "Madison", "Martin", "McDowell", "Mecklenburg", "Mitchell", "Montgomery", "Moore", "Nash", "New Hanover", "Northampton", "Onslow", "Orange", "Pamlico", "Pasquotank", "Pender", "Perquimans", "Person", "Pitt", "Polk", "Randolph", "Richmond", "Robeson", "Rockingham", "Rowan", "Rutherford", "Sampson", "Scotland", "Stanly", "Stokes", "Surry", "Swain", "Transylvania", "Tyrrell", "Union", "Vance", "Wake", "Warren", "Washington", "Watauga", "Wayne", "Wilkes", "Wilson", "Yadkin", "Yancey"]
SLOTS = 7

INK = "#F4F7FF"
SOFT = "#AEB8CC"
DIM = "#6E7A94"
GOLD = "#F2C14E"
NIGHT = "#1B2233"
DEM = "#4C8DFF"
REP = "#FF4C4C"
DEM_SAFE = "#264A8C"
REP_SAFE = "#8C2A2A"
PARTY = {"DEM": [DEM, "D"], "REP": [REP, "R"], "LIB": [GOLD, "L"], "GRE": ["#2ECC71", "G"], "CST": [SOFT, "C"]}

PAD = 6
RIGHT = 186
ROW_Y = [9, 17, 25]
NAME_X = PAD + 8
SMALL_Y = [7, 13, 19, 25]
COL_X = [PAD, 100]
COL_R = [92, RIGHT]

TITLES = [
    ("US HOUSE OF REPRESENTATIVES DISTRICT ", "US HOUSE "),
    ("NC HOUSE OF REPRESENTATIVES DISTRICT ", "NC HOUSE "),
    ("NC STATE SENATE DISTRICT ", "NC SENATE "),
    ("NC SUPREME COURT ASSOCIATE JUSTICE SEAT ", "SUPREME CT "),
    ("NC COURT OF APPEALS JUDGE SEAT ", "APPEALS CT "),
    ("NC SUPERIOR COURT JUDGE DISTRICT ", "SUPERIOR CT "),
    ("NC DISTRICT COURT JUDGE DISTRICT ", "DISTRICT CT "),
    ("DISTRICT ATTORNEY DISTRICT ", "DA "),
    ("CONSTITUTIONAL AMENDMENT - ", "AMEND: "),
    ("CITY OF ", ""),
    ("TOWN OF ", ""),
    ("VILLAGE OF ", ""),
    ("PARKS AND RECREATION", "PARKS + REC"),
    ("COUNCIL MEMBER", "COUNCIL"),
    ("SANITARY DISTRICT", "SANITARY"),
    ("REQUIRE PHOTO ID FOR VOTING", "PHOTO ID"),
    ("MAXIMUM INCOME TAX RATE OF 3.5%", "3.5% TAX CAP"),
    ("PROPERTY TAX LEVY LIMIT", "PROP TAX LIMIT"),
    ("BOARD OF COMMISSIONERS", "COMMISSIONERS"),
    ("BOARD OF EDUCATION", "SCHOOL BD"),
    ("-SCHOOLS SCHOOL BD", " SCHOOL BD"),
    (" CITY SCHOOLS SCHOOL BD", " SCHOOL BD"),
    (" CITY COUNCIL", " COUNCIL"),
    (" TOWN COUNCIL", " COUNCIL"),
    ("COUNCIL DISTRICT", "COUNCIL DIST"),
    ("ELECTION METHOD", "VOTE METHOD"),
    ("STRUCTURE CHANGE", "CHANGE"),
    (" TWP", ""),
    ("SOIL AND WATER CONSERVATION DISTRICT", "SOIL + WATER"),
    ("LOCAL SALES AND USE TAX", "SALES TAX"),
    (" REFERENDUM", ""),
    (" (UNEXPIRED)", ""),
    (" SEAT ", "-"),
    (" 00", " "),
    (" 0", " "),
    ("-0", "-"),
]

CLOSE_RACES = ("US ", "NC HOUSE", "NC STATE SENATE", "NC SUPREME", "NC COURT OF")

SUFFIXES = ["JR", "JR.", "SR", "SR.", "II", "III", "IV"]

# ---------- text ----------

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for n in range(len(t), 0, -1):
        if c.text_width(t[:n], font) <= maxw:
            return t[:n]
    return ""

def to_int(s):
    t = str(s).replace(",", "").strip()
    return int(t) if t.isdigit() else 0

def commas(n):
    s = str(n)
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return out

def pct_text(s):
    # Feed shares are strings like "0.7331".
    t = str(s).strip()
    if t.replace(".", "", 1).isdigit():
        tenths = int(float(t) * 1000 + 0.5)
        return str(tenths // 10) + "." + str(tenths % 10) + "%"
    return "-"

def last_name(name):
    # "Tobias (Toby) Hampson" -> HAMPSON, "JeKeith Cowell, Sr." -> COWELL
    n = name.upper()
    if n.startswith("WRITE-IN"):
        return "WRITE-IN"
    words = [w.strip(",") for w in n.split(" ") if w != "" and not w.startswith("(")]
    if len(words) > 1 and words[-1] in SUFFIXES:
        words = words[:-1]
    return words[-1] if len(words) else n

def race_pick(cnm):
    cut = cnm.find(" (VOTE FOR ")
    if cut < 0:
        return ""
    n = cnm[cut + 11:].replace(")", "").strip()
    return "" if n == "1" else " PICK " + n

def race_title(cnm, county):
    t = cnm
    cut = t.find(" (VOTE FOR ")
    if cut >= 0:
        t = t[:cut]
    if county != "":
        t = t.replace(county.upper() + " COUNTY ", "").replace(county.upper() + " ", "")
    for pair in TITLES:
        t = t.replace(pair[0], pair[1])
    if t.startswith("- "):
        t = t[2:]
    return t

# ---------- data ----------

def get_rows(name):
    resp = http.get(BASE + name, ttl_seconds = TTL)
    if resp["status_code"] != 200:
        return None
    rows = resp["json"]
    return rows if type(rows) == "list" else None

def group(rows):
    races = {}
    names = []
    for r in rows:
        k = r.get("cnm", "")
        if k not in races:
            races[k] = []
            names.append(k)
        races[k].append(r)
    return [races, names]

def is_write_in(r):
    return r.get("bnm", "").upper().startswith("WRITE-IN")

def contested(rows):
    return len([r for r in rows if not is_write_in(r)]) > 1

def is_amendment(cnm):
    return cnm.startswith("CONSTITUTIONAL")

def is_question(rows):
    # Referendums, bonds, fire tax and liquor votes all list a side, not a person.
    return rows[0].get("bnm", "").upper() in ("FOR", "AGAINST", "YES", "NO")

def is_county_race(cnm, rows):
    if is_amendment(cnm):
        return False
    return is_question(rows) or rows[0].get("ogl", "") not in ("FED", "JUD", "NCS", "NCH", "")

def race_rank(cnm, rows):
    if cnm.startswith("US SENATE"):
        return 0
    if cnm.startswith("US HOUSE"):
        return 1
    if is_amendment(cnm):
        return 2
    if cnm.startswith("NC STATE SENATE"):
        return 3
    if cnm.startswith("NC HOUSE"):
        return 4
    if is_question(rows):
        return 6
    if "COMMISSIONER" in cnm or "SHERIFF" in cnm:
        return 5
    if "BOARD OF EDUCATION" in cnm:
        return 7
    if cnm.startswith("NC SUPREME"):
        return 8
    if cnm.startswith("NC COURT OF APPEALS"):
        return 9
    if "SOIL" in cnm:
        return 11
    return 10

def race_list(races, names, county, show):
    state_ptl = max([0] + [to_int(races[k][0].get("ptl")) for k in names])
    picked = []
    for k in names:
        rows = races[k]
        if not contested(rows):
            continue
        if county == "" and to_int(rows[0].get("ptl")) != state_ptl and not k.startswith("US HOUSE"):
            continue
        if show == "Ballot questions" and not is_question(rows):
            continue
        if show == "Judges" and rows[0].get("ogl", "") != "JUD":
            continue
        if show == "County races" and county != "" and not is_county_race(k, rows):
            continue
        picked.append(k)
    return sorted(picked, key = lambda k: race_rank(k, races[k]))

def model(ctx):
    county = ctx.inputs.get("county", ALL_NC)
    if county not in COUNTIES:
        county = ALL_NC
    cid = COUNTIES.index(county)
    state = get_rows("results_0.txt")
    head = None
    for s in (get_rows("county.txt") or []):
        if to_int(s.get("cid")) == cid:
            head = s
    return {
        "county": "" if cid == 0 else county,
        "show": ctx.inputs.get("show", "All races"),
        "summary": head,
        "state": state,
        "rows": state if cid == 0 else get_rows("results_" + str(cid) + ".txt"),
    }

def has_votes(rows):
    return len([r for r in rows if to_int(r.get("vct")) > 0]) > 0

def race_order(rows):
    # Most votes first; before any votes, the feed's order with D and R on top.
    if has_votes(rows):
        return sorted(rows, key = lambda r: -to_int(r.get("vct")))
    return sorted(rows, key = lambda r: 0 if r.get("pty") in ("DEM", "REP") else 1)

# ---------- pages ----------

def card(c, ctx):
    m = model(ctx)
    now = ctx.now.unix
    s = m["summary"]
    title = (m["county"].upper() + " COUNTY") if m["county"] != "" else "ALL NC COUNTIES"
    prt = to_int((s or {}).get("prt"))
    ptl = to_int((s or {}).get("ptl"))
    ballots = to_int((s or {}).get("bct"))
    l3 = ""
    l4 = ""
    if prt > 0 or ballots > 0:
        done = ptl > 0 and prt >= ptl
        top = "ALL IN" if done else "LIVE"
        low = "COUNT"
        fill = "#1F7A45" if done else "#B3261E"
        l2 = ("ALL " + commas(ptl) + " PRECINCTS IN") if done else (commas(prt) + " OF " + commas(ptl) + " PRECINCTS")
        l3 = "TURNOUT " + s.get("bpt", "") + " - " + commas(ballots)
        stamp = s.get("imp", "")
        at = stamp.find(", 20")
        l4 = "UNOFFICIAL" + (" - UPDATED " + stamp[at + 7:].upper() if at >= 0 else "")
    elif now >= CLOSE_UNIX:
        top = "POLLS"
        low = "CLOSED"
        fill = NIGHT
        l2 = "EARLY VOTES POST FIRST"
        l3 = "USUALLY 8 TO 8:30 PM"
    elif now >= OPEN_UNIX:
        top = "VOTE"
        low = "TODAY"
        fill = "#1F7A45"
        l2 = "POLLS CLOSE 7:30 PM"
    else:
        d = (OPEN_UNIX - now + 86399) // 86400
        top = str(d)
        low = "DAY" if d == 1 else "DAYS"
        fill = NIGHT
        l2 = "ELECTION DAY " + DAY_LABEL
        l3 = "POLLS 6:30 AM - 7:30 PM"
    c.rect(0, 0, 39, 31, fill = fill)
    c.text(top, 20, 7, font = "6x8" if len(top) < 6 else "5x7", color = INK, align = "center")
    c.text(low, 20, 18, font = "5x7", color = INK, align = "center")
    x = 44
    w = c.width - x - 3
    c.text(clip(c, title, "5x7", w), x, 1, font = "5x7", color = GOLD)
    c.text(clip(c, l2, "5x7", w), x, 10, font = "5x7", color = INK)
    c.text(clip(c, l3, "4x5", w), x, 19, font = "4x5", color = SOFT)
    c.text(clip(c, l4, "4x5", w), x, 26, font = "4x5", color = DIM)

def race_page(c, ctx, slot):
    m = model(ctx)
    if m["rows"] == None or m["state"] == None:
        c.text("RESULTS FEED OFFLINE", c.width // 2, 13, font = "5x7", color = GOLD, align = "center")
        return
    g = group(m["rows"])
    names = race_list(g[0], g[1], m["county"], m["show"])
    overview = m["county"] == "" and m["show"] == "All races"
    if overview and slot == 1:
        board_page(c, g)
        return
    if overview and slot == 2:
        closest_page(c, g)
        return
    n = len(names)
    if n == 0:
        c.text("NO CONTESTED RACES", c.width // 2, 8, font = "5x7", color = INK, align = "center")
        c.text("TRY ALL RACES", c.width // 2, 18, font = "4x5", color = DIM, align = "center")
        return
    first = 3 if overview else 1
    per = SLOTS - first
    if slot == 0:
        at = 0
    elif n - 1 <= per:
        at = (1 + slot - first) % n
    else:
        batch = (ctx.now.unix // 300) % ((n - 1 + per - 1) // per)
        at = 1 + (batch * per + slot - first) % (n - 1)
    draw_race(c, m, names[at], g[0][names[at]], at + 1, n)

def seat_counts(races, names, prefix):
    # [D leading, R leading, D unopposed, R unopposed]
    out = [0, 0, 0, 0]
    for k in names:
        if not k.startswith(prefix):
            continue
        rows = races[k]
        real = [r for r in rows if not is_write_in(r)]
        if len(real) == 1 or has_votes(rows):
            top = sorted(real, key = lambda r: -to_int(r.get("vct")))[0]
            side = {"DEM": 0, "REP": 1}.get(top.get("pty"))
            if side != None:
                out[side] += 1
                if len(real) == 1:
                    out[side + 2] += 1
    return out

def board_row(c, y, label, seats, line, n):
    c.text(label, PAD, y, font = "5x7", color = INK)
    c.text("D" + str(n[0]), 62, y, font = "5x7", color = DEM)
    c.text("R" + str(n[1]), 90, y, font = "5x7", color = REP)
    x0 = 118
    w = 68
    c.rect(x0, y, x0 + w - 1, y + 6, fill = NIGHT)
    # Unopposed seats fill first, darker: they're decided, not a lead.
    if n[0] > 0:
        c.rect(x0, y, x0 + n[0] * w // seats - 1, y + 6, fill = DEM)
    if n[2] > 0:
        c.rect(x0, y, x0 + n[2] * w // seats - 1, y + 6, fill = DEM_SAFE)
    if n[1] > 0:
        c.rect(x0 + w - n[1] * w // seats, y, x0 + w - 1, y + 6, fill = REP)
    if n[3] > 0:
        c.rect(x0 + w - n[3] * w // seats, y, x0 + w - 1, y + 6, fill = REP_SAFE)
    a = x0 + line * w // seats
    b = x0 + w - line * w // seats
    c.rect(a, y - 1, a, y + 7, fill = GOLD)
    c.rect(b, y - 1, b, y + 7, fill = GOLD)

def board_page(c, g):
    c.text("NC LEGISLATURE", PAD, 1, font = "4x5", color = GOLD)
    c.text("LEADING - GOLD LINE 3/5", RIGHT, 1, font = "4x5", color = DIM, align = "right")
    board_row(c, 10, "NC HOUSE", 120, 72, seat_counts(g[0], g[1], "NC HOUSE"))
    board_row(c, 21, "NC SENATE", 50, 30, seat_counts(g[0], g[1], "NC STATE SENATE"))

def closest_page(c, g):
    # Single-seat candidate races with a quarter of their precincts in, so a
    # handful of early votes can't fill the page.
    found = []
    for k in g[1]:
        rows = g[0][k]
        if not k.startswith(CLOSE_RACES) or not contested(rows) or to_int(rows[0].get("vfr")) != 1:
            continue
        if not has_votes(rows) or to_int(rows[0].get("prt")) * 4 < to_int(rows[0].get("ptl")):
            continue
        real = sorted([r for r in rows if not is_write_in(r)], key = lambda r: -to_int(r.get("vct")))
        found.append([to_int(real[0].get("vct")) - to_int(real[1].get("vct")), k, real[0]])
    c.text("CLOSEST RACES", PAD, 1, font = "4x5", color = GOLD)
    c.text("VOTES AHEAD", RIGHT, 1, font = "4x5", color = DIM, align = "right")
    if len(found) == 0:
        c.text("NO COUNTS YET", c.width // 2, 15, font = "5x7", color = DIM, align = "center")
        return
    picks = sorted(found, key = lambda f: f[0])[:3]
    for i in range(len(picks)):
        p = picks[i]
        y = ROW_Y[i]
        c.text(clip(c, race_title(p[1], ""), "5x7", 86), PAD, y, font = "5x7", color = SOFT)
        chip = PARTY.get(p[2].get("pty", ""))
        if chip != None:
            c.text(chip[1], 96, y, font = "5x7", color = chip[0])
        lead = "+" + commas(p[0])
        room = RIGHT - c.text_width(lead, "5x7") - 4 - 104
        c.text(clip(c, last_name(p[2].get("bnm", "")), "5x7", room), 104, y, font = "5x7", color = INK)
        c.text(lead, RIGHT, y, font = "5x7", color = GOLD, align = "right")

def draw_race(c, m, cnm, rows, index, total):
    prt = to_int(rows[0].get("prt"))
    ptl = to_int(rows[0].get("ptl"))
    wide = None
    wide_label = ""
    # A write-in line stays hidden until it has votes.
    ordered = [r for r in race_order(rows) if not is_write_in(r) or to_int(r.get("vct")) > 0]
    if m["county"] != "" and len(ordered) <= 4:
        sg = group(m["state"])
        srows = sg[0].get(cnm)
        if srows != None and to_int(srows[0].get("ptl")) > ptl:
            wide = {}
            for r in srows:
                wide[r.get("bnm")] = r
            top = max([to_int(sg[0][k][0].get("ptl")) for k in sg[1]])
            wide_label = "NC" if to_int(srows[0].get("ptl")) == top else "DIST"
    vote_r = 118 if wide != None else 148
    pct_r = 152 if wide != None else RIGHT
    # Header: race, count through the ballot, precincts, comparison label.
    prec = commas(prt) + "/" + commas(ptl) + " IN"
    tag = str(index) + "/" + str(total)
    if wide != None:
        c.text(wide_label, RIGHT, 1, font = "4x5", color = DIM, align = "right")
    c.text(prec, pct_r, 1, font = "4x5", color = SOFT, align = "right")
    room = pct_r - c.text_width(prec, "4x5") - 4 - PAD
    # PICK n stays on screen when a long title has to clip.
    pick = race_pick(cnm)
    title = race_title(cnm, m["county"])
    title_w = c.text_width(title + pick, "4x5")
    c.text(clip(c, title, "4x5", room - c.text_width(pick, "4x5")) + pick, PAD, 1, font = "4x5", color = GOLD)
    if title_w + c.text_width(tag, "4x5") + 4 <= room:
        c.text(tag, PAD + title_w + 4, 1, font = "4x5", color = DIM)
    votes_in = has_votes(rows)
    known = INCUMBENTS if m["county"] == "" else {}
    if len(ordered) > 4:
        draw_columns(c, ordered, votes_in)
    elif len(ordered) == 4:
        draw_four(c, ordered, votes_in, wide, vote_r, pct_r, known)
    else:
        draw_rows(c, ordered, votes_in, wide, vote_r, pct_r, known)

def mark_incumbent(c, r, known, name, font, x, y):
    # (i) by hand, 7x5: the small fonts have no lowercase or parentheses.
    if r.get("bnm") in known:
        l = x + c.text_width(name, font) + 3
        for p in ((1, 0, 1, 0), (0, 1, 0, 3), (1, 4, 1, 4), (3, 0, 3, 0), (3, 2, 3, 4), (5, 0, 5, 0), (6, 1, 6, 3), (5, 4, 5, 4)):
            c.rect(l + p[0], y + p[1], l + p[2], y + p[3], fill = GOLD)

def wide_share(wide, r):
    o = wide.get(r.get("bnm"))
    if o == None or to_int(o.get("vct")) == 0:
        return "-"
    return pct_text(o.get("pct")).replace("%", "")

def draw_four(c, ordered, votes_in, wide, vote_r, pct_r, known):
    # One small row each: the 4x5 font fits four under the header.
    for i in range(4):
        r = ordered[i]
        y = SMALL_Y[i]
        col = INK if i == 0 and votes_in else SOFT
        chip = PARTY.get(r.get("pty", ""))
        if chip != None:
            c.text(chip[1], PAD, y, font = "4x5", color = chip[0])
        votes = commas(to_int(r.get("vct")))
        name_x = PAD + 6 if chip != None else PAD
        room = vote_r - c.text_width(votes, "4x5") - 4 - name_x
        name = clip(c, last_name(r.get("bnm", "")), "4x5", room)
        c.text(name, name_x, y, font = "4x5", color = col)
        mark_incumbent(c, r, known, name, "4x5", name_x, y)
        c.text(votes, vote_r, y, font = "4x5", color = SOFT if votes_in else DIM, align = "right")
        c.text(pct_text(r.get("pct")) if votes_in else "-", pct_r, y, font = "4x5", color = col if votes_in else DIM, align = "right")
        if wide != None:
            c.text(wide_share(wide, r), RIGHT, y, font = "4x5", color = DIM, align = "right")

def draw_columns(c, ordered, votes_in):
    # Five or more: two columns of name and share, no vote counts.
    extra = len(ordered) - 8
    shown = ordered[:7] if extra > 0 else ordered[:8]
    for i in range(len(shown)):
        r = shown[i]
        y = SMALL_Y[i % 4]
        left = COL_X[i // 4]
        right = COL_R[i // 4]
        col = INK if i == 0 and votes_in else SOFT
        chip = PARTY.get(r.get("pty", ""))
        if chip != None:
            c.text(chip[1], left, y, font = "4x5", color = chip[0])
        share = pct_text(r.get("pct")) if votes_in else "-"
        name_x = left + 6 if chip != None else left
        room = right - c.text_width(share, "4x5") - 3 - name_x
        c.text(clip(c, last_name(r.get("bnm", "")), "4x5", room), name_x, y, font = "4x5", color = col)
        c.text(share, right, y, font = "4x5", color = col if votes_in else DIM, align = "right")
    if extra > 0:
        c.text("+" + str(extra + 1) + " MORE", COL_R[1], SMALL_Y[3], font = "4x5", color = DIM, align = "right")

def draw_rows(c, ordered, votes_in, wide, vote_r, pct_r, known):
    for i in range(len(ordered)):
        r = ordered[i]
        y = ROW_Y[i]
        col = INK if i == 0 and votes_in else SOFT
        chip = PARTY.get(r.get("pty", ""))
        if chip != None:
            c.text(chip[1], PAD, y, font = "5x7", color = chip[0])
        votes = commas(to_int(r.get("vct")))
        share = pct_text(r.get("pct")) if votes_in else "-"
        name_x = NAME_X if chip != None else PAD
        room = vote_r - c.text_width(votes, "5x7") - 4 - name_x
        name = clip(c, last_name(r.get("bnm", "")), "5x7", room)
        c.text(name, name_x, y, font = "5x7", color = col)
        mark_incumbent(c, r, known, name, "5x7", name_x, y + 2)
        c.text(votes, vote_r, y, font = "5x7", color = SOFT if votes_in else DIM, align = "right")
        c.text(share, pct_r, y, font = "5x7", color = col if votes_in else DIM, align = "right")
        if wide != None:
            c.text(wide_share(wide, r), RIGHT, y, font = "5x7", color = DIM, align = "right")

def race1(c, ctx):
    race_page(c, ctx, 0)

def race2(c, ctx):
    race_page(c, ctx, 1)

def race3(c, ctx):
    race_page(c, ctx, 2)

def race4(c, ctx):
    race_page(c, ctx, 3)

def race5(c, ctx):
    race_page(c, ctx, 4)

def race6(c, ctx):
    race_page(c, ctx, 5)

def race7(c, ctx):
    race_page(c, ctx, 6)
