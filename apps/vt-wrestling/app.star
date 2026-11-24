# Hokies Wrestling, 64x32.
#
# Data: MatSavant's public rankings file (one JSON, ~600 KB, refreshed weekly
# by MatSavant). It has every ranked D1 wrestler with FloWrestling AND InterMat
# ranks, record, DPG, All-American odds and title odds. This app keeps only the
# Hokies.
#
# Pages:
#   next    the next dual or tournament (or FINAL for a day after a dual)
#   team    projected NCAA finish, trophy odds, title odds, ranked Hokies
#   card1-3 one ranked Hokie each; the set rotates every refresh (every minute)
#           so all ten weights come around in a few minutes
#
# Coming next: a live dual page that takes over the whole app while VT wrestles.

RANKINGS_URL = "https://www.matsavant.com/data/p4p/2027.json"
SCHEDULE_URL = "https://www.matsavant.com/data/schedule/duals_2026-27.json"
ODDS_URL = "https://www.matsavant.com/data/xtp/2027/xtp_team_odds_history_2027.json"
RANKINGS_TTL = 3600    # an hour; MatSavant updates rankings about weekly
SCHEDULE_TTL = 900     # 15 minutes, so a final score shows up soon after a dual
ODDS_TTL = 3600        # MatSavant re-runs its forecast about daily
VT_SLUG = "virginia_tech"

# Without a User-Agent the request goes out as "python-requests", which
# MatSavant's host refuses (403). Say who we are instead.
HEADERS = {
    "User-Agent": "HokiesWrestling-GlanceLED/0.1 (personal LED display)",
    "Accept": "application/json",
    "Referer": "https://www.matsavant.com/",
}

# MatSavant's dual schedule has dates but no start times or tournaments, so
# these come from hokiesports.com's 2026-27 schedule. Update them each season.
DUAL_TIMES = {
    "2026-11-19": "7 PM", "2026-12-04": "7 PM", "2026-12-18": "7 PM",
    "2027-01-10": "5 PM", "2027-01-15": "7 PM", "2027-01-22": "7 PM",
    "2027-01-29": "7 PM", "2027-02-05": "7 PM", "2027-02-19": "7 PM",
}
TOURNAMENTS = [
    {"start": "2026-11-22", "end": "2026-11-22", "name": "KEYSTONE CLASSIC", "place": "PHILADELPHIA"},
    {"start": "2026-12-12", "end": "2026-12-13", "name": "NATL DUALS INV", "place": "TULSA"},
    {"start": "2027-01-02", "end": "2027-01-03", "name": "SOUTHERN SCUFFLE", "place": ""},
    {"start": "2027-03-06", "end": "2027-03-07", "name": "ACC CHAMPS", "place": "PITTSBURGH"},
    {"start": "2027-03-18", "end": "2027-03-20", "name": "NCAA CHAMPS", "place": "ST. LOUIS"},
]

W = 64
VT = "VT"
WEIGHTS = ["125", "133", "141", "149", "157", "165", "174", "184", "197", "285"]

MAROON = "#E0507A"     # VT maroon, lifted so it reads on black LEDs
ORANGE = "#FF8A1F"     # VT orange
GRAY = "#8A93A8"
DIM = "#6A7090"
AMBER = "#E8B04A"
TEAL = "#3FD0B0"

# Opponent colors and abbreviations, keyed by MatSavant team slug.
OPP = {
    "duke": {"abbr": "DUKE", "color": "#00539B", "alt": "#FFFFFF", "name": "Duke"},
    "nc_state": {"abbr": "NCSU", "color": "#CC0000", "alt": "#FFFFFF", "name": "NC State"},
    "north_carolina_state": {"abbr": "NCSU", "color": "#CC0000", "alt": "#FFFFFF", "name": "NC State"},
    "north_carolina": {"abbr": "UNC", "color": "#7BAFD4", "alt": "#13294B", "name": "North Carolina"},
    "pitt": {"abbr": "PITT", "color": "#003594", "alt": "#FFB81C", "name": "Pitt"},
    "pittsburgh": {"abbr": "PITT", "color": "#003594", "alt": "#FFB81C", "name": "Pitt"},
    "stanford": {"abbr": "STAN", "color": "#8C1515", "alt": "#FFFFFF", "name": "Stanford"},
    "virginia": {"abbr": "UVA", "color": "#232D4B", "alt": "#F84C1E", "name": "Virginia"},
    "virginia_tech": {"abbr": "VT", "color": "#6A2C3E", "alt": "#CF4520", "name": "Virginia Tech"},
    "illinois": {"abbr": "ILL", "color": "#FF5F05", "alt": "#13294B", "name": "Illinois"},
    "indiana": {"abbr": "IU", "color": "#970310", "alt": "#FFFFFF", "name": "Indiana"},
    "iowa": {"abbr": "IOWA", "color": "#231F20", "alt": "#FCD116", "name": "Iowa"},
    "maryland": {"abbr": "MD", "color": "#CE1126", "alt": "#FFFFFF", "name": "Maryland"},
    "michigan": {"abbr": "MICH", "color": "#00274C", "alt": "#FFCB05", "name": "Michigan"},
    "michigan_state": {"abbr": "MSU", "color": "#173F35", "alt": "#FFFFFF", "name": "Michigan State"},
    "minnesota": {"abbr": "MINN", "color": "#5E0A2F", "alt": "#FAB41C", "name": "Minnesota"},
    "nebraska": {"abbr": "NEB", "color": "#E31937", "alt": "#FFFFFF", "name": "Nebraska"},
    "northwestern": {"abbr": "NU", "color": "#492F92", "alt": "#FFFFFF", "name": "Northwestern"},
    "ohio_state": {"abbr": "OSU", "color": "#BA0C2F", "alt": "#A8ADB4", "name": "Ohio State"},
    "penn_state": {"abbr": "PSU", "color": "#061440", "alt": "#FFFFFF", "name": "Penn State"},
    "purdue": {"abbr": "PUR", "color": "#CEB888", "alt": "#000000", "name": "Purdue"},
    "rutgers": {"abbr": "RUTG", "color": "#CE0E2D", "alt": "#FFFFFF", "name": "Rutgers"},
    "wisconsin": {"abbr": "WIS", "color": "#A00000", "alt": "#FFFFFF", "name": "Wisconsin"},
    "arizona_state": {"abbr": "ASU", "color": "#FFC627", "alt": "#8C1D40", "name": "Arizona State"},
    "iowa_state": {"abbr": "ISU", "color": "#AE192D", "alt": "#FFC72A", "name": "Iowa State"},
    "missouri": {"abbr": "MIZ", "color": "#F1B82D", "alt": "#000000", "name": "Missouri"},
    "northern_iowa": {"abbr": "UNI", "color": "#473282", "alt": "#FFFFFF", "name": "Northern Iowa"},
    "oklahoma": {"abbr": "OU", "color": "#990000", "alt": "#FFFFFF", "name": "Oklahoma"},
    "oklahoma_state": {"abbr": "OKST", "color": "#FE5C00", "alt": "#000000", "name": "Oklahoma State"},
    "utah_valley": {"abbr": "UVU", "color": "#004812", "alt": "#E1C736", "name": "Utah Valley"},
    "west_virginia": {"abbr": "WVU", "color": "#EAAA00", "alt": "#002855", "name": "West Virginia"},
    "wyoming": {"abbr": "WYO", "color": "#492F24", "alt": "#FFC425", "name": "Wyoming"},
    "american": {"abbr": "AMER", "color": "#C41130", "alt": "#C8102E", "name": "American"},
    "american_university": {"abbr": "AMER", "color": "#C41130", "alt": "#C8102E", "name": "American"},
    "army": {"abbr": "ARMY", "color": "#000000", "alt": "#D3BC8D", "name": "Army"},
    "army_west_point": {"abbr": "ARMY", "color": "#000000", "alt": "#D3BC8D", "name": "Army"},
    "binghamton": {"abbr": "BING", "color": "#00614A", "alt": "#F0F0F0", "name": "Binghamton"},
    "bucknell": {"abbr": "BUCK", "color": "#000060", "alt": "#00316E", "name": "Bucknell"},
    "drexel": {"abbr": "DREX", "color": "#020260", "alt": "#FFD65A", "name": "Drexel"},
    "franklin_and_marshall": {"abbr": "F&M", "color": "#003C7F", "alt": "#FFFFFF", "name": "Franklin & Marshall"},
    "franklin_marshall": {"abbr": "F&M", "color": "#003C7F", "alt": "#FFFFFF", "name": "Franklin & Marshall"},
    "hofstra": {"abbr": "HOF", "color": "#003594", "alt": "#FFC72C", "name": "Hofstra"},
    "lehigh": {"abbr": "LEH", "color": "#6C2B2A", "alt": "#B69E70", "name": "Lehigh"},
    "liu": {"abbr": "LIU", "color": "#50C9F7", "alt": "#FFBF00", "name": "LIU"},
    "long_island": {"abbr": "LIU", "color": "#50C9F7", "alt": "#FFBF00", "name": "LIU"},
    "long_island_university": {"abbr": "LIU", "color": "#50C9F7", "alt": "#FFBF00", "name": "LIU"},
    "morgan_state": {"abbr": "MORG", "color": "#014786", "alt": "#F47937", "name": "Morgan State"},
    "navy": {"abbr": "NAVY", "color": "#00225B", "alt": "#B5A67C", "name": "Navy"},
    "sacred_heart": {"abbr": "SHU", "color": "#A40012", "alt": "#C29472", "name": "Sacred Heart"},
    "brown": {"abbr": "BRWN", "color": "#411E09", "alt": "#949300", "name": "Brown"},
    "columbia": {"abbr": "COLU", "color": "#7BA4DB", "alt": "#183863", "name": "Columbia"},
    "cornell": {"abbr": "COR", "color": "#B31B1B", "alt": "#FFFFFF", "name": "Cornell"},
    "harvard": {"abbr": "HARV", "color": "#990000", "alt": "#DBDBDB", "name": "Harvard"},
    "penn": {"abbr": "PENN", "color": "#082A74", "alt": "#A6163D", "name": "Penn"},
    "pennsylvania": {"abbr": "PENN", "color": "#082A74", "alt": "#A6163D", "name": "Penn"},
    "princeton": {"abbr": "PRIN", "color": "#000000", "alt": "#FF6000", "name": "Princeton"},
    "bloomsburg": {"abbr": "BLOOM", "color": "#8A1538", "alt": "#F2C75C", "name": "Bloomsburg"},
    "buffalo": {"abbr": "BUF", "color": "#005BBB", "alt": "#FFFFFF", "name": "Buffalo"},
    "central_michigan": {"abbr": "CMU", "color": "#4C0027", "alt": "#FBAB18", "name": "Central Michigan"},
    "clarion": {"abbr": "CLAR", "color": "#0B3D91", "alt": "#F9B612", "name": "Clarion"},
    "edinboro": {"abbr": "EDIN", "color": "#C8102E", "alt": "#FFFFFF", "name": "Edinboro"},
    "george_mason": {"abbr": "GMU", "color": "#016600", "alt": "#ECB010", "name": "George Mason"},
    "kent_state": {"abbr": "KENT", "color": "#002664", "alt": "#EAAB00", "name": "Kent State"},
    "lock_haven": {"abbr": "LHU", "color": "#A6192E", "alt": "#FFFFFF", "name": "Lock Haven"},
    "ohio": {"abbr": "OHIO", "color": "#154734", "alt": "#FFFFFF", "name": "Ohio"},
    "rider": {"abbr": "RID", "color": "#A80532", "alt": "#EBEBEB", "name": "Rider"},
    "siu_edwardsville": {"abbr": "SIUE", "color": "#EB1C23", "alt": "#080808", "name": "SIU Edwardsville"},
    "siue": {"abbr": "SIUE", "color": "#EB1C23", "alt": "#080808", "name": "SIU Edwardsville"},
    "air_force": {"abbr": "AF", "color": "#003594", "alt": "#FFFFFF", "name": "Air Force"},
    "cal_poly": {"abbr": "CP", "color": "#1E4D2B", "alt": "#EED897", "name": "Cal Poly"},
    "cal_state_bakersfield": {"abbr": "CSUB", "color": "#003BAB", "alt": "#FFFFFF", "name": "CSU Bakersfield"},
    "csu_bakersfield": {"abbr": "CSUB", "color": "#003BAB", "alt": "#FFFFFF", "name": "CSU Bakersfield"},
    "arkansas_little_rock": {"abbr": "LR", "color": "#AD0000", "alt": "#898D8F", "name": "Little Rock"},
    "little_rock": {"abbr": "LR", "color": "#AD0000", "alt": "#898D8F", "name": "Little Rock"},
    "north_dakota_state": {"abbr": "NDSU", "color": "#01402A", "alt": "#FFFFFF", "name": "North Dakota State"},
    "northern_colorado": {"abbr": "UNCO", "color": "#13558D", "alt": "#FFC533", "name": "Northern Colorado"},
    "northern_illinois": {"abbr": "NIU", "color": "#C8102E", "alt": "#000000", "name": "Northern Illinois"},
    "oregon_state": {"abbr": "ORST", "color": "#DC4405", "alt": "#000000", "name": "Oregon State"},
    "south_dakota_state": {"abbr": "SDST", "color": "#0033A0", "alt": "#FFD100", "name": "South Dakota State"},
    "app_state": {"abbr": "APP", "color": "#000000", "alt": "#FFCD00", "name": "App State"},
    "appalachian_state": {"abbr": "APP", "color": "#000000", "alt": "#FFCD00", "name": "App State"},
    "bellarmine": {"abbr": "BELL", "color": "#000000", "alt": "#FFFFFF", "name": "Bellarmine"},
    "campbell": {"abbr": "CAM", "color": "#000000", "alt": "#FFFFFF", "name": "Campbell"},
    "chattanooga": {"abbr": "UTC", "color": "#00386B", "alt": "#DCA71D", "name": "Chattanooga"},
    "davidson": {"abbr": "DAV", "color": "#000000", "alt": "#E51837", "name": "Davidson"},
    "gardner_webb": {"abbr": "GWEB", "color": "#C12535", "alt": "#909090", "name": "Gardner-Webb"},
    "presbyterian": {"abbr": "PRES", "color": "#194896", "alt": "#990134", "name": "Presbyterian"},
    "citadel": {"abbr": "CIT", "color": "#7BADD3", "alt": "#002856", "name": "The Citadel"},
    "the_citadel": {"abbr": "CIT", "color": "#7BADD3", "alt": "#002856", "name": "The Citadel"},
    "vmi": {"abbr": "VMI", "color": "#AE122A", "alt": "#000000", "name": "VMI"},
}

# ---- Safe accessors ---------------------------------------------------------

def as_dict(x):
    return x if type(x) == "dict" else {}

def as_list(x):
    return x if type(x) == "list" else []

def as_str(x):
    if x == None:
        return ""
    return str(x)

def as_num(x):
    """Number or None."""
    if type(x) == "int" or type(x) == "float":
        return x
    return None

def pct(p):
    """0.582 -> "58%". picopixel has no "<", so tiny odds read "0%"."""
    p = as_num(p)
    if p == None:
        return "-"
    n = int(p * 100 + 0.5)
    if n < 1:
        return "0%"
    return str(n) + "%"

def clip(c, s, font, maxw):
    s = as_str(s).upper()
    for _ in range(len(s) + 1):
        if s == "" or c.text_width(s, font) <= maxw:
            return s
        s = s[:len(s) - 1]
    return s

def fit(c, s, fonts, maxw):
    s = as_str(s).upper()
    for f in fonts:
        if c.text_width(s, f) <= maxw:
            return s, f
    last = fonts[len(fonts) - 1]
    return clip(c, s, last, maxw), last

def last_name(full):
    parts = as_str(full).strip().split(" ")
    if len(parts) == 0:
        return ""
    return parts[len(parts) - 1]

# ---- Data ---------------------------------------------------------------------

def hokies(data):
    """One entry per weight: the best-ranked Hokie, merged across Flo and
    InterMat lists, in weight order."""
    flo = as_dict(data.get("weights"))
    im = as_dict(data.get("intermat_weights"))
    out = []
    for wt in WEIGHTS:
        best = None
        for src in [as_list(flo.get(wt)), as_list(im.get(wt))]:
            for e in src:
                e = as_dict(e)
                if as_str(e.get("team_abbr")) != VT:
                    continue
                if best == None:
                    best = dict(e)
                elif as_str(e.get("name")) == as_str(best.get("name")):
                    # Same wrestler from the other list: fill missing ranks.
                    for k in ["rank", "flo_rank", "intermat_rank"]:
                        if best.get(k) == None and e.get(k) != None:
                            best[k] = e.get(k)
                break
        if best != None:
            best["wt"] = wt
            out.append(best)
    return out

def flo_rank(e):
    # In the Flo lists `rank` is Flo's; entries that came from the InterMat
    # lists carry Flo's as `flo_rank`.
    r = as_num(e.get("flo_rank"))
    if r == None:
        r = as_num(e.get("rank"))
    return r

# ---- Dates (Eastern time) -------------------------------------------------------

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

def days_from_civil(y, m, d):
    """Days since 1970-01-01 for a calendar date (Howard Hinnant's algorithm)."""
    y = y - 1 if m <= 2 else y
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def parse_date(s):
    """"2026-12-04" -> (2026, 12, 4) or None."""
    p = as_str(s).split("-")
    if len(p) != 3 or not (p[0].isdigit() and p[1].isdigit() and p[2].isdigit()):
        return None
    return (int(p[0]), int(p[1]), int(p[2]))

def day_num(s):
    d = parse_date(s)
    if d == None:
        return None
    return days_from_civil(d[0], d[1], d[2])

def today_et(ctx):
    """Today's day number in Eastern time. DST runs 2nd Sunday of March to 1st
    Sunday of November; close enough to the hour for a wrestling schedule."""
    unix = ctx.now.unix
    utc_day = unix // 86400
    y = ctx.now.year
    mar1 = days_from_civil(y, 3, 1)
    dst_start = mar1 + ((7 - (mar1 + 4) % 7) % 7) + 7      # 2nd Sunday of March
    nov1 = days_from_civil(y, 11, 1)
    dst_end = nov1 + ((7 - (nov1 + 4) % 7) % 7)            # 1st Sunday of November
    offset = 4 if (utc_day >= dst_start and utc_day < dst_end) else 5
    return (unix - offset * 3600) // 86400

def nice_date(s):
    """"2026-12-04" -> "FRI DEC 4"."""
    d = parse_date(s)
    if d == None:
        return ""
    n = days_from_civil(d[0], d[1], d[2])
    return DAYS[(n + 4) % 7] + " " + MONTHS[d[1] - 1] + " " + str(d[2])

# ---- Schedule ------------------------------------------------------------------------

def vt_duals(sched):
    """VT duals as {date, opp, home, result}, in date order."""
    out = []
    for d in as_list(sched):
        d = as_dict(d)
        a = as_dict(d.get("team_a"))
        b = as_dict(d.get("team_b"))
        if as_str(a.get("slug")) == VT_SLUG:
            vt_side, opp = 0, b
        elif as_str(b.get("slug")) == VT_SLUG:
            vt_side, opp = 1, a
        else:
            continue
        home = as_str(d.get("home"))
        where = "HOME" if home == VT_SLUG else ("NEUTRAL" if home == "" or d.get("neutral") == True else "AWAY")
        res = as_dict(d.get("result"))
        score = as_list(res.get("score"))
        final = None
        if len(score) == 2:
            final = {"vt": score[vt_side], "opp": score[1 - vt_side]}
        out.append({"date": as_str(d.get("date")), "opp_slug": as_str(opp.get("slug")),
                    "opp_name": as_str(opp.get("name")), "where": where, "final": final})
    return sorted(out, key = lambda x: x["date"])

def next_item(ctx, duals):
    """What the `next` page shows: a dual from the last day with its final,
    else today's or the next dual or tournament, whichever comes first."""
    today = today_et(ctx)
    for d in duals:
        n = day_num(d["date"])
        if n != None and d["final"] != None and today - 1 <= n and n <= today:
            return {"kind": "final", "d": d}
    best = None
    best_n = None
    for d in duals:
        n = day_num(d["date"])
        if n != None and n >= today and d["final"] == None:
            best, best_n = {"kind": "dual", "d": d}, n
            break
    for t in TOURNAMENTS:
        s = day_num(t["start"])
        e = day_num(t["end"])
        if s == None or e == None or e < today:
            continue
        if best_n == None or s < best_n:
            best, best_n = {"kind": "tourn", "t": t}, s
        break
    return best

# ---- Opponent badge --------------------------------------------------------------------

def opp_info(slug, name):
    o = OPP.get(slug)
    if o != None:
        return o["abbr"], o["color"], o["alt"]
    # Not a D1 wrestling school we know: initials on gray.
    words = as_str(name).upper().replace("THE ", "").split(" ")
    ab = "".join([w[0] for w in words if w != ""])[:4]
    return (ab if ab != "" else "OPP"), "#5F5E5A", "#FFFFFF"

def draw_badge(c, slug, name, x_right, y, h):
    """Team-color box with the abbreviation, right edge at x_right. Returns x0."""
    ab, col, alt = opp_info(slug, name)
    fill = col if brightness(col) >= 40 else alt
    txt = "black" if brightness(fill) > 150 else "white"
    w = c.text_width(ab, "4x5") + 4
    x0 = x_right - w
    c.rect(x0, y, x_right - 1, y + h - 1, fill = fill)
    c.text(ab, x0 + 2, y + (h - 5) // 2, font = "4x5", color = txt)
    return x0

def brightness(hexcolor):
    h = as_str(hexcolor).lstrip("#")
    if len(h) != 6:
        return 0
    return (int(h[0:2], 16) * 299 + int(h[2:4], 16) * 587 + int(h[4:6], 16) * 114) // 1000

# ---- Next page -------------------------------------------------------------------------

def draw_matchup(c, d, mid, mid_color):
    """VT logo left, opponent badge right, a word or score between."""
    c.image("vt22.png", 0, 7)
    x0 = draw_badge(c, d["opp_slug"], d["opp_name"], W, 7, 11)
    # Free space between the logo (x 0-21) and the badge, with 1px either side.
    lo = 23
    hi = x0 - 2
    t, f = fit(c, mid, ["5x7", "4x5"], hi - lo + 1)
    c.text(t, lo + (hi - lo + 1) // 2, 9, font = f, color = mid_color, align = "center")

def draw_next(c, ctx, item):
    today = today_et(ctx)
    if item == None:
        message(c, "SEASON OVER", "SEE YOU IN NOVEMBER", ORANGE)
        return
    if item["kind"] == "tourn":
        t = item["t"]
        s = day_num(t["start"])
        when = "TODAY" if s <= today else nice_date(t["start"])
        c.text(clip(c, when, "4x5", W), W // 2, 0, font = "4x5", color = AMBER, align = "center")
        c.image("vt22.png", 0, 7)
        c.text("NEXT", W, 9, font = "5x7", color = GRAY, align = "right")
        name, f = fit(c, t["name"], ["4x5", "picopixel"], W)
        c.text(name, W // 2, 20, font = f, color = "white", align = "center")
        place, f2 = fit(c, t["place"], ["4x5", "picopixel"], W)
        c.text(place, W // 2, 27, font = f2, color = DIM, align = "center")
        return

    d = item["d"]
    if item["kind"] == "final":
        vt = d["final"]["vt"]
        op = d["final"]["opp"]
        wl, col = ("W", "green") if vt > op else (("L", "red") if vt < op else ("T", AMBER))
        c.text("FINAL", W // 2, 0, font = "4x5", color = GRAY, align = "center")
        draw_matchup(c, d, str(vt) + "-" + str(op), "white")
        c.text(wl, W // 2, 20, font = "5x7", color = col, align = "center")
        name, f = fit(c, d["opp_name"], ["4x5", "picopixel"], W)
        c.text(name, W // 2, 27, font = f, color = DIM, align = "center")
        return

    n = day_num(d["date"])
    when = "TONIGHT" if n == today else ("TOMORROW" if n == today + 1 else nice_date(d["date"]))
    c.text(clip(c, when, "4x5", W), W // 2, 0, font = "4x5", color = AMBER, align = "center")
    draw_matchup(c, d, "AT" if d["where"] == "AWAY" else "VS", GRAY)
    t = DUAL_TIMES.get(d["date"], "")
    line = (t + " " if t != "" else "") + d["where"]
    c.text(clip(c, line, "4x5", W), W // 2, 20, font = "4x5", color = "white", align = "center")
    name, f = fit(c, d["opp_name"], ["4x5", "picopixel"], W)
    c.text(name, W // 2, 27, font = f, color = DIM, align = "center")

# ---- Team page -------------------------------------------------------------------------

def vt_odds(odds):
    """(projected NCAA finish, [xtp, p10, p90, title%, trophy%]) from the latest day."""
    days = as_list(as_dict(odds).get("days"))
    if len(days) == 0:
        return None, None
    teams = as_dict(as_dict(days[len(days) - 1]).get("teams"))
    mine = as_list(teams.get("Virginia Tech"))
    if len(mine) < 5:
        return None, None
    place = 1
    for name, v in teams.items():
        v = as_list(v)
        if name != "Virginia Tech" and len(v) > 0 and as_num(v[0]) != None and v[0] > mine[0]:
            place += 1
    return place, mine

def ordinal(n):
    if n % 100 in (11, 12, 13):
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

def odds_pct(v):
    v = as_num(v)
    if v == None:
        return "-"
    if v > 0 and v < 9.95:
        t = int(v * 10 + 0.5)                 # one decimal, e.g. 0.6%
        return str(t // 10) + "." + str(t % 10) + "%"
    return str(int(v + 0.5)) + "%"

def draw_team(c, odds, roster):
    c.image("vt22.png", 0, 0)
    c.text("HOKIES", W, 2, font = "5x7", color = ORANGE, align = "right")

    def row(label, value, y, color = "white"):
        c.text(label, 0, y, font = "4x5", color = GRAY)
        c.text(value, W, y, font = "4x5", color = color, align = "right")

    place, v = vt_odds(odds)
    if v != None:
        row("NCAA PROJ", ordinal(place), 13, AMBER)
        row("TROPHY", odds_pct(v[4]), 20)
        row("TITLE", odds_pct(v[3]), 27)
    else:
        row("RANKED", str(len(roster)) + "/10", 13)
        row("NCAA PROJ", "-", 20)

# ---- Screens --------------------------------------------------------------------

def message(c, title, sub, color):
    t, f = fit(c, title, ["6x8", "5x7", "4x5"], W - 2)
    c.text(t, W // 2, 8, font = f, color = color, align = "center")
    s, f2 = fit(c, sub, ["4x5", "picopixel"], W - 2)
    c.text(s, W // 2, 20, font = f2, color = DIM, align = "center")

def rank_color(now, before):
    now = as_num(now)
    before = as_num(before)
    if now == None or before == None or now == before:
        return "white"
    return "green" if now < before else "red"

def draw_card(c, e):
    c.image("vt22.png", 0, 0)
    c.text(as_str(e.get("wt")), 24, 2, font = "5x7", color = AMBER)
    rec = as_str(e.get("record"))
    if rec != "":
        c.text(rec, W, 3, font = "4x5", color = GRAY, align = "right")

    name, f = fit(c, last_name(e.get("name")), ["6x8", "5x7", "4x5"], W)
    c.text(name, W // 2, 12, font = f, color = "white", align = "center")

    fr = flo_rank(e)
    ir = as_num(e.get("intermat_rank"))
    flo = "FLO #" + (str(int(fr)) if fr != None else "-")
    im = "IM #" + (str(int(ir)) if ir != None else "-")
    c.text(flo, 0, 21, font = "4x5", color = rank_color(fr, e.get("prev_rank")))
    c.text(im, W, 21, font = "4x5", color = "white", align = "right")

    c.text("AA " + pct(e.get("aa_prob")), 0, 27, font = "picopixel", color = TEAL)
    c.text("TITLE " + pct(e.get("champ_prob")), W, 27, font = "picopixel", color = ORANGE, align = "right")

# ---- Pages --------------------------------------------------------------------------

def get_json(url, ttl):
    """(json, error tuple or None)."""
    resp = http.get(url, headers = HEADERS, ttl_seconds = ttl)
    if resp["status_code"] == 0:
        return None, ("NO SIGNAL", "CHECK WIFI")
    if resp["status_code"] != 200 or resp["json"] == None:
        return None, ("NO DATA", "MATSAVANT " + str(resp["status_code"]))
    return resp["json"], None

def next(c, ctx):
    c.fill("black")
    sched, err = get_json(SCHEDULE_URL, SCHEDULE_TTL)
    if err != None:
        message(c, err[0], err[1], AMBER)
        return
    draw_next(c, ctx, next_item(ctx, vt_duals(sched)))

def team(c, ctx):
    c.fill("black")
    odds, err = get_json(ODDS_URL, ODDS_TTL)
    if err != None:
        message(c, err[0], err[1], AMBER)
        return
    draw_team(c, odds, [])

def card(c, ctx, slot):
    c.fill("black")
    data, err = get_json(RANKINGS_URL, RANKINGS_TTL)
    if err != None:
        message(c, err[0], err[1], AMBER)
        return
    roster = hokies(as_dict(data))
    if len(roster) == 0:
        message(c, "NO HOKIES", "IN THIS WEEK'S RANKS", "green")
        return
    n = len(roster)
    frame = ctx.now.unix // 60
    draw_card(c, roster[(slot + 3 * frame) % n])

def card1(c, ctx):
    card(c, ctx, 0)

def card2(c, ctx):
    card(c, ctx, 1)

def card3(c, ctx):
    card(c, ctx, 2)
