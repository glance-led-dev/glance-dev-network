# Prime Time Time Machine for the Glance Scroll (192x32).
#
# Shows what was on network television at this exact minute, on this weekday,
# in the 1980s year chosen in the settings: the show on the air right now,
# every network in the same time slot, what comes on next, and outside prime
# time, tonight's lineup.
#
# No internet requests. The schedules for the 1979-80 through 1989-90
# television seasons are built into this file (see SEASONS below). Network
# schedules, show titles, and Nielsen season rankings are historical facts,
# compiled once from the "United States network television schedule" season
# articles on Wikipedia and cross-checked. Network names appear as plain text,
# never as logos. The pixel TV set is original art.
#
# Seasons change through the year the way they did on the air: a fall lineup,
# mid-season replacements, spring changes, and summer reruns. Exact premiere
# and cancellation dates within a season are approximate.

INK = "#F4F7FF"
SOFT = "#B8C0D0"
DIM = "#6E7A94"
MAG = "#FF2BD6"
CYAN = "#29E3FF"
AMBER = "#FFB000"
NETC = {"ABC": "#FFD23F", "CBS": "#29E3FF", "NBC": "#FF4FA0", "FOX": "#7CFF5A"}
NET_ORDER = ["ABC", "CBS", "NBC", "FOX"]
DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
DAY_NAMES = {"SUN": "SUNDAY", "MON": "MONDAY", "TUE": "TUESDAY", "WED": "WEDNESDAY", "THU": "THURSDAY", "FRI": "FRIDAY", "SAT": "SATURDAY"}

LEFT = 10
RIGHT = 181
TEXT_X = 38

# ---------------------------------------------------------------- time ----

# (standard offset from UTC in minutes, observes daylight saving time,
#  minutes to shift the 1980s Eastern/Pacific schedule)
# Network prime time aired an hour earlier by the clock in the Central and
# Mountain time zones (8 p.m. Eastern = 7 p.m. Central).
ZONES = {
    "EASTERN": (-300, True, 0),
    "CENTRAL": (-360, True, 60),
    "MOUNTAIN": (-420, True, 60),
    "ARIZONA": (-420, False, 60),
    "PACIFIC": (-480, True, 0),
}
DEFAULT_ZONE = "EASTERN"

def days_from_civil(y, m, d):
    yy = (y - 1) if m <= 2 else y
    era = yy // 400
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = (mp + 3) if mp < 10 else (mp - 9)
    if m <= 2:
        y = y + 1
    return (y, m, d)

def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    wd = (first + 4) % 7
    return 1 + (7 - wd) % 7 + (n - 1) * 7

def zone_info(ctx):
    zone = str(ctx.inputs.get("timezone", DEFAULT_ZONE)).strip().upper()
    if zone not in ZONES:
        zone = DEFAULT_ZONE
    return ZONES[zone]

def local_clock(ctx):
    # Returns (days since 1970-01-01, minute of the day) on the viewer's clock.
    std, dst, _ = zone_info(ctx)
    t = ctx.now.unix // 60
    off = std
    if dst:
        y = civil_from_days((t + std) // 1440)[0]
        start = (days_from_civil(y, 3, nth_sunday(y, 3, 2)) * 1440 + 120) - std
        end = (days_from_civil(y, 11, nth_sunday(y, 11, 1)) * 1440 + 120) - std - 60
        if t >= start and t < end:
            off = std + 60
    lt = t + off
    return (lt // 1440, lt % 1440)

# ------------------------------------------------------------ schedule ----

def chosen_year(ctx, days):
    v = str(ctx.inputs.get("year", "1986")).strip().upper()
    if v.isdigit() and int(v) >= 1980 and int(v) <= 1989:
        return int(v)
    # "SURPRISE ME": a different 1980s year each day, the same all day long.
    return 1980 + (days * 7 + 3) % 10

def when(ctx):
    days, minute = local_clock(ctx)
    _, _, shift = zone_info(ctx)
    y, m, d = civil_from_days(days)
    year = chosen_year(ctx, days)
    return struct(days = days, minute = minute, sched_minute = minute + shift,
                  shift = shift, month = m, day = d, year = year)

def season_key(year, month):
    # September-December belong to the season that starts that fall;
    # January-August belong to the season that started the fall before.
    return year if month >= 9 else year - 1

def position(month, day):
    # Months counted from the start of a season (September = 9 ... August = 20),
    # in tenths, matching the period markers in SEASONS.
    mm = month if month >= 9 else month + 12
    return mm * 10 + (day - 1) * 10 // 31

def night(w, day_offset):
    # {network: [(start, end, title, rank, rerun), ...]} for the chosen year,
    # on today's weekday (or tomorrow's, with day_offset = 1).
    sk = season_key(w.year, w.month)
    season = SEASONS.get(sk, {})
    dname = DAYS[(w.days + day_offset + 4) % 7]
    nets = season.get(dname, {})
    pos = position(w.month, w.day)
    out = {}
    for net in NET_ORDER:
        periods = nets.get(net, None)
        if not periods:
            continue
        pick = None
        for p in periods:
            if p[0] <= pos and (pick == None or p[0] >= pick[0]):
                pick = p
        if pick == None:
            # Early September, before the new season's premieres: the
            # previous season's summer lineup was still on the air. Fox
            # before its April 1987 launch has no earlier season, so it
            # simply doesn't appear.
            prev = SEASONS.get(sk - 1, {}).get(dname, {}).get(net, None)
            if prev:
                pick = prev[len(prev) - 1]
            else:
                continue
        progs = []
        for q in pick[1]:
            progs.append(struct(start = q[0], end = q[1], title = TITLES[q[2]], rank = q[3], rerun = q[4] == 1, net = net))
        out[net] = progs
    return struct(nets = out, dname = dname)

def bounds(n):
    lo = 9999
    hi = 0
    for net in n.nets:
        for p in n.nets[net]:
            lo = min(lo, p.start)
            hi = max(hi, p.end)
    return (lo, hi)

def is_local(p):
    return p.title.startswith("LOCAL")

def airing(n, t):
    out = []
    for net in NET_ORDER:
        for p in n.nets.get(net, []):
            if p.start <= t and t < p.end:
                out.append(p)
    return out

def best(progs):
    # The highest-rated show in a list (a lower Nielsen rank is better),
    # skipping local programming. Unranked shows count after ranked ones.
    pick = None
    for p in progs:
        if is_local(p):
            continue
        if pick == None:
            pick = p
        elif p.rank > 0 and (pick.rank == 0 or p.rank < pick.rank):
            pick = p
        elif p.rank == 0 and pick.rank == 0 and "MOVIE" in pick.title and "MOVIE" not in p.title:
            # Between two unranked choices, a series beats a movie slot.
            pick = p
    return pick

def all_progs(n):
    out = []
    for net in NET_ORDER:
        out.extend(n.nets.get(net, []))
    return out

# ------------------------------------------------------------- drawing ----

def clock_text(minute):
    h = (minute // 60) % 24
    mm = minute % 60
    ap = "AM" if h < 12 else "PM"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + ("0" if mm < 10 else "") + str(mm) + " " + ap

def slot_text(sched_minute, w):
    # A schedule time (Eastern listing) shown on the viewer's clock.
    return clock_text(sched_minute - w.shift)

def short_time(sched_minute, w):
    s = clock_text(sched_minute - w.shift)
    return s[:-3]

def tv(c, x, y):
    # Original pixel art: a 1980s console TV with rabbit ears.
    c.line(x + 6, y, x + 10, y + 5, DIM)
    c.line(x + 16, y, x + 12, y + 5, DIM)
    c.round_rect(x, y + 5, x + 21, y + 21, 2, fill = "#1A1A2E", outline = MAG)
    c.rect(x + 3, y + 8, x + 15, y + 18, fill = CYAN)
    c.rect(x + 5, y + 10, x + 9, y + 12, fill = INK)
    c.fill_circle(x + 18, y + 10, 1, AMBER)
    c.fill_circle(x + 18, y + 15, 1, AMBER)

def hero_width(c, s, font):
    # 8x10 has no apostrophe glyph, so apostrophes are drawn by hand.
    if font != "8x10":
        return c.text_width(s, font)
    parts = s.split("'")
    w = 0
    for i, part in enumerate(parts):
        if part:
            w = w + c.text_width(part, font)
        if i < len(parts) - 1:
            w = w + 3
    return w

def draw_hero(c, s, x, y, font, color):
    if font != "8x10":
        c.text(s, x, y, font = font, color = color)
        return
    parts = s.split("'")
    for i, part in enumerate(parts):
        if part:
            c.text(part, x, y, font = font, color = color)
            x = x + c.text_width(part, font) + 1
        if i < len(parts) - 1:
            c.vline(x, y, 3, color)
            x = x + 3

def fit(c, s, font, maxw):
    if c.text_width(s, font) <= maxw:
        return s
    for i in range(len(s), 0, -1):
        t = s[:i].rstrip(" ,:-/") + "."
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def split_two(c, s, font, maxw):
    # Break a long title into two lines at the best space.
    words = s.split(" ")
    bestpair = None
    for i in range(1, len(words)):
        a = " ".join(words[:i])
        b = " ".join(words[i:])
        wa = c.text_width(a, font)
        wb = c.text_width(b, font)
        if wa <= maxw and wb <= maxw:
            score = max(wa, wb)
            if bestpair == None or score < bestpair[0]:
                bestpair = (score, a, b)
    if bestpair == None:
        return None
    return (bestpair[1], bestpair[2])

def short_title(s):
    # Only used when a title is too wide for its row.
    if s.startswith("THE ") and len(s) > 14:
        s = s[4:]
    s = s.replace(" NIGHT AT THE MOVIES", " MOVIE").replace(" NIGHT MOVIES", " MOVIE").replace(" NIGHT MOVIE", " MOVIE")
    return s

def detail_line(p, w):
    if p.rank > 0:
        return ("#" + str(p.rank) + " SHOW OF THE SEASON", AMBER)
    if p.rerun:
        return ("SUMMER RERUN", SOFT)
    if is_local(p):
        return ("LOCAL STATIONS", SOFT)
    return (short_time(p.start, w) + " TO " + slot_text(p.end, w), SOFT)

def hero_page(c, header, header_color, p, w, extra = None):
    # Header, the show title as large as it fits, then network and detail.
    c.clear()
    tv(c, LEFT, 5)
    maxw = RIGHT - TEXT_X
    title = p.title
    line2 = detail_line(p, w)
    if extra != None:
        line2 = extra
    netw = c.text_width(p.net, "4x5")
    if hero_width(c, title, "8x10") <= maxw:
        c.text(header, TEXT_X, 2, font = "4x5", color = header_color)
        draw_hero(c, title, TEXT_X, 10, "8x10", INK)
        by = 24
    elif c.text_width(title, "5x7") <= maxw:
        c.text(header, TEXT_X, 2, font = "4x5", color = header_color)
        c.text(title, TEXT_X, 12, font = "5x7", color = INK)
        by = 24
    else:
        two = split_two(c, title, "5x7", maxw)
        font = "5x7"
        if two == None:
            two = split_two(c, title, "4x5", maxw)
            font = "4x5"
        if two == None:
            two = (fit(c, title, "4x5", maxw), "")
            font = "4x5"
        c.text(header, TEXT_X, 1, font = "4x5", color = header_color)
        c.text(two[0], TEXT_X, 8, font = font, color = INK)
        c.text(two[1], TEXT_X, 16, font = font, color = INK)
        by = 25
    c.text(p.net, TEXT_X, by, font = "4x5", color = NETC[p.net])
    c.text(fit(c, line2[0], "4x5", maxw - netw - 6), TEXT_X + netw + 6, by, font = "4x5", color = line2[1])

def lineup_page(c, header, progs, highlight):
    c.clear()
    if len(progs) <= 3:
        c.text(header, LEFT, 1, font = "4x5", color = MAG)
        font = "5x7"
        y = 8
        step = 8
    else:
        c.text(header, LEFT, 0, font = "4x5", color = MAG)
        font = "4x5"
        y = 7
        step = 6
    labelw = c.text_width("ABC", font) + 6
    for p in progs:
        c.text(p.net, LEFT, y, font = font, color = NETC[p.net])
        col = INK if p == highlight else SOFT
        if is_local(p):
            col = DIM
        t = p.title
        maxw = RIGHT - LEFT - labelw
        if c.text_width(t, font) > maxw:
            t = short_title(t)
        rowfont = font
        if c.text_width(t, rowfont) > maxw:
            rowfont = "4x5"
        dy = 1 if rowfont != font else 0
        c.text(fit(c, t, rowfont, maxw), LEFT + labelw, y + dy, font = rowfont, color = col)
        y = y + step

def list_page(c, header, progs, w, page_index):
    # Up to three shows at a time, cycling through the night.
    c.clear()
    c.text(header, LEFT, 1, font = "4x5", color = MAG)
    groups = (len(progs) + 2) // 3
    start = (page_index % groups) * 3 if groups > 0 else 0
    y = 8
    timew = c.text_width("10:00", "5x7") + 6
    for p in progs[start:start + 3]:
        c.text(short_time(p.start, w), LEFT, y, font = "5x7", color = CYAN)
        t = p.title
        font = "5x7"
        maxw = RIGHT - LEFT - timew
        if c.text_width(t, font) > maxw:
            t = short_title(t)
        if c.text_width(t, font) > maxw:
            font = "4x5"
        c.text(fit(c, t, font, maxw), LEFT + timew, y + (1 if font == "4x5" else 0), font = font, color = SOFT if is_local(p) else INK)
        y = y + 8

def no_schedule(c, w):
    c.clear()
    tv(c, LEFT, 5)
    c.text("PRIME TIME " + str(w.year), TEXT_X, 6, font = "5x7", color = MAG)
    c.text("NO NETWORK SCHEDULE", TEXT_X, 16, font = "4x5", color = SOFT)
    c.text("FOR THIS NIGHT", TEXT_X, 23, font = "4x5", color = SOFT)

# ---------------------------------------------------------------- state ----

def state(ctx):
    w = when(ctx)
    n = night(w, 0)
    lo, hi = bounds(n)
    t = w.sched_minute
    if len(n.nets) > 0 and t >= lo and t < hi:
        return struct(w = w, n = n, live = True, label = "TONIGHT", lo = lo, hi = hi)
    if len(n.nets) > 0 and t < lo:
        return struct(w = w, n = n, live = False, label = "TONIGHT", lo = lo, hi = hi)
    n2 = night(w, 1)
    lo2, hi2 = bounds(n2)
    return struct(w = w, n = n2, live = False, label = "TOMORROW", lo = lo2, hi = hi2)

def stamp(s):
    return DAYS[(s.w.days + 4) % 7] + " " + clock_text(s.w.minute) + "  " + str(s.w.year)

def featured(s):
    if s.live:
        return best(airing(s.n, s.w.sched_minute))
    return best(all_progs(s.n))

# ---------------------------------------------------------------- pages ----

def now(c, ctx):
    s = state(ctx)
    if len(s.n.nets) == 0:
        no_schedule(c, s.w)
        return
    p = featured(s)
    if p == None:
        no_schedule(c, s.w)
        return
    if s.live:
        hero_page(c, stamp(s), MAG, p, s.w)
    else:
        head = s.label + "'S BIG SHOW IN " + str(s.w.year)
        extra = (slot_text(p.start, s.w), CYAN)
        if p.rank > 0:
            extra = (slot_text(p.start, s.w) + "  #" + str(p.rank) + " OF THE SEASON", AMBER)
        hero_page(c, head, MAG, p, s.w, extra)

def lineup(c, ctx):
    s = state(ctx)
    if len(s.n.nets) == 0:
        no_schedule(c, s.w)
        return
    if s.live:
        progs = airing(s.n, s.w.sched_minute)
        lineup_page(c, "ON RIGHT NOW  " + stamp(s), progs, featured(s))
    else:
        progs = airing(s.n, s.lo)
        lineup_page(c, s.label + " AT " + slot_text(s.lo, s.w) + " IN " + str(s.w.year), progs, best(progs))

def next(c, ctx):
    s = state(ctx)
    if len(s.n.nets) == 0:
        no_schedule(c, s.w)
        return
    w = s.w
    if s.live:
        cur = featured(s)
        t = w.sched_minute
        pick = None
        if cur != None:
            for p in s.n.nets.get(cur.net, []):
                if p.start >= cur.end and p.start < s.hi and not is_local(p):
                    pick = p
                    break
        if pick == None:
            for p in all_progs(s.n):
                if p.start > t and not is_local(p) and (pick == None or p.start < pick.start):
                    pick = p
        if pick != None:
            hero_page(c, "UP NEXT ON " + pick.net + "  " + slot_text(pick.start, w), CYAN, pick, w)
            return
        top = best(all_progs(s.n))
        if top != None:
            hero_page(c, "TONIGHT'S TOP SHOW IN " + str(w.year), CYAN, top, w)
            return
        no_schedule(c, w)
        return
    nets = [x for x in NET_ORDER if x in s.n.nets]
    net = nets[(w.minute // 60) % len(nets)]
    header = s.label + " ON " + net + "  " + DAY_NAMES[s.n.dname] + " " + str(w.year)
    list_page(c, header, s.n.nets[net], w, w.minute // 3)

# ---------------------------------------------------------------- data ----

TITLES = [
    "OUT OF THE BLUE",
    "A NEW KIND OF FAMILY",
    "MORK & MINDY",
    "THE ASSOCIATES",
    "THE ABC SUNDAY NIGHT MOVIE",
    "SALVAGE 1",
    "GALACTICA 1980",
    "TENSPEED AND BROWN SHOE",
    "WHEN THE WHISTLE BLOWS",
    "60 MINUTES",
    "ARCHIE BUNKER'S PLACE",
    "ONE DAY AT A TIME",
    "ALICE",
    "THE JEFFERSONS",
    "TRAPPER JOHN, M.D.",
    "THE WONDERFUL WORLD OF DISNEY",
    "THE BIG EVENT",
    "PRIME TIME SUNDAY",
    "CHIPS",
    "240-ROBERT",
    "MONDAY NIGHT FOOTBALL",
    "VARIOUS PROGRAMMING",
    "THE ABC MONDAY NIGHT MOVIE",
    "LAVERNE & SHIRLEY",
    "ANGIE",
    "STONE",
    "FAMILY",
    "THAT'S INCREDIBLE!",
    "ONE IN A MILLION",
    "MONDAY NIGHT BASEBALL",
    "THE WHITE SHADOW",
    "M*A*S*H",
    "WKRP IN CINCINNATI",
    "LOU GRANT",
    "HOUSE CALLS",
    "THE LAST RESORT",
    "THE STOCKARD CHANNING SHOW",
    "FLO",
    "PHYL & MIKHY",
    "LITTLE HOUSE ON THE PRAIRIE",
    "NBC MONDAY NIGHT AT THE MOVIES",
    "HAPPY DAYS",
    "THREE'S COMPANY",
    "TAXI",
    "THE LAZARUS SYNDROME",
    "HART TO HART",
    "GOODTIME GIRLS",
    "CALIFORNIA FEVER",
    "THE CBS TUESDAY NIGHT MOVIE",
    "HAWAII FIVE-O",
    "PARIS",
    "THE MISADVENTURES OF SHERIFF LOBO",
    "NBC TUESDAY NIGHT AT THE MOVIES",
    "THE BIG SHOW",
    "UNITED STATES",
    "EIGHT IS ENOUGH",
    "CHARLIE'S ANGELS",
    "VEGA$",
    "20/20",
    "STRUCK BY LIGHTNING",
    "THE CBS WEDNESDAY NIGHT MOVIE",
    "THE BAD NEWS BEARS",
    "YOUNG MAVERICK",
    "BEYOND WESTWORLD",
    "REAL PEOPLE",
    "DIFF'RENT STROKES",
    "HELLO, LARRY",
    "THE BEST OF SATURDAY NIGHT LIVE",
    "FROM HERE TO ETERNITY",
    "THE FACTS OF LIFE",
    "QUINCY, M.E.",
    "BENSON",
    "BARNEY MILLER",
    "SOAP",
    "THE ROPERS",
    "NOBODY'S PERFECT",
    "THE WALTONS",
    "BARNABY JONES",
    "KNOTS LANDING",
    "PALMERSTOWN, U.S.A.",
    "THE CONTENDER",
    "BUCK ROGERS IN THE 25TH CENTURY",
    "KATE LOVES A MYSTERY",
    "SKAG",
    "THE ROCKFORD FILES",
    "NBC THURSDAY NIGHT AT THE MOVIES",
    "GAMES PEOPLE PLAY",
    "FANTASY ISLAND",
    "THE ABC FRIDAY NIGHT MOVIE",
    "B.A.D. CATS",
    "THE INCREDIBLE HULK",
    "THE DUKES OF HAZZARD",
    "DALLAS",
    "SHIRLEY",
    "EISCHIED",
    "NBC FRIDAY NIGHT AT THE MOVIES",
    "SPECIAL PROGRAMMING",
    "HERE'S BOOMER",
    "PINK LADY",
    "ME AND MAXX",
    "SPEAK UP AMERICA",
    "DETECTIVE SCHOOL",
    "THE LOVE BOAT",
    "WORKING STIFFS",
    "BIG SHAMUS, LITTLE SHAMUS",
    "CBS SATURDAY MOVIE",
    "THE CHISHOLMS",
    "THE TIM CONWAY SHOW",
    "HAGEN",
    "UNIVERSE",
    "B. J. AND THE BEAR",
    "A MAN CALLED SLOANE",
    "PRIME TIME SATURDAY",
    "SANFORD",
    "JOE'S WORLD",
    "GOOD TIME HARRY",
    "THOSE AMAZING ANIMALS",
    "LOCAL AND PAID POLITICAL PROGRAMMING",
    "SPECIALS",
    "DISNEY'S WONDERFUL WORLD",
    "DYNASTY",
    "FOUL PLAY",
    "LADIES' MAN",
    "PRIVATE BENJAMIN",
    "THE TWO OF US",
    "FLAMINGO ROAD",
    "THE LAST CONVERTIBLE",
    "TOO CLOSE FOR COMFORT",
    "IT'S A LIVING",
    "THE CBS TUESDAY NIGHT MOVIES",
    "THAT'S MY LINE",
    "CHECKING IN",
    "THE STEVE ALLEN COMEDY HOUR",
    "LOBO",
    "NERO WOLFE",
    "THE GREATEST AMERICAN HERO",
    "ALOHA PARADISE",
    "AMERICAN DREAM",
    "THE ABC SUMMER MOVIE",
    "ENOS",
    "THE CBS WEDNESDAY NIGHT MOVIES",
    "MOVIE OF THE WEEK",
    "BOSOM BUDDIES",
    "CBS THURSDAY MOVIE SPECIAL",
    "MAGNUM, P.I.",
    "PARK PLACE",
    "NURSE",
    "I'M A BIG GIRL NOW",
    "THE KRYPTON FACTOR",
    "NBC MAGAZINE WITH DAVID BRINKLEY",
    "MARIE",
    "NUMBER 96",
    "HARPER VALLEY PTA",
    "THE BRADY BRIDES",
    "COMEDY THEATER",
    "BREAKING AWAY",
    "THE CBS SATURDAY NIGHT MOVIES",
    "FREEBIE AND THE BEAN",
    "SECRETS OF MIDLAND HEIGHTS",
    "CONCRETE COWBOYS",
    "RIKER",
    "BARBARA MANDRELL AND THE MANDRELL SISTERS",
    "NBC SATURDAY NIGHT AT THE MOVIES",
    "WALKING TALL",
    "HILL STREET BLUES",
    "THE GANGSTER CHRONICLES",
    "B.J. AND THE BEAR",
    "CODE RED",
    "TODAY'S FBI",
    "LOCAL",
    "NBC SUNDAY NIGHT MOVIE",
    "FATHER MURPHY",
    "ABC MONDAY NIGHT MOVIE",
    "BEST OF THE WEST",
    "MR. MERLIN",
    "REPORT TO MURPHY",
    "MAKING THE GRADE",
    "FILTHY RICH",
    "JOANIE LOVES CHACHI",
    "SIMON & SIMON",
    "Q.E.D.",
    "BRET MAVERICK",
    "THE SHAPE OF THINGS",
    "VARIOUS",
    "CASSIE & CO.",
    "MCCLAIN'S LAW",
    "THE FALL GUY",
    "SHANNON",
    "HERBIE, THE LOVE BUG",
    "BAKER'S DOZEN",
    "LOVE, SIDNEY",
    "TEACHERS ONLY",
    "POLICE SQUAD!",
    "9 TO 5",
    "NO SOAP, RADIO",
    "DARKROOM",
    "JESSICA NOVAK",
    "CAGNEY & LACEY",
    "HARPER VALLEY",
    "LEWIS & CLARK",
    "GIMME A BREAK!",
    "FAME",
    "STRIKE FORCE",
    "MAKING A LIVING",
    "THE PHOENIX",
    "MAGGIE",
    "FALCON CREST",
    "NBC MAGAZINE",
    "JOKEBOOK",
    "CHICAGO STORY",
    "OPEN ALL NIGHT",
    "KING'S CROSSING",
    "T.J. HOOKER",
    "WALT DISNEY",
    "NASHVILLE PALACE",
    "FITZ AND BONES",
    "BILLY CRYSTAL COMEDY HOUR",
    "ONE OF THE BOYS",
    "TELEVISION: INSIDE AND OUT",
    "RIPLEY'S BELIEVE IT OR NOT!",
    "MATT HOUSTON",
    "GLORIA",
    "GOODNIGHT, BEANTOWN",
    "NEWHART",
    "VOYAGERS!",
    "NBC SUNDAY NIGHT AT THE MOVIES",
    "CASABLANCA",
    "THE POWERS OF MATTHEW STAR",
    "KNIGHT RIDER",
    "SQUARE PEGS",
    "SMALL & FRYE",
    "FOOT IN THE DOOR",
    "TUCKER'S WITCH",
    "LITTLE HOUSE: A NEW BEGINNING",
    "FAMILY TIES",
    "THE 1/2 HOUR COMEDY HOUR",
    "BRING 'EM BACK ALIVE",
    "ACE CRAWFORD, PRIVATE EYE",
    "GUN SHY",
    "ON THE ROAD WITH CHARLES KURALT",
    "OUR TIMES WITH BILL MOYERS",
    "GAVILAN",
    "ST. ELSEWHERE",
    "THE A-TEAM",
    "BARE ESSENCE",
    "REMINGTON STEELE",
    "TALES OF THE GOLD MONKEY",
    "HIGH PERFORMANCE",
    "RYAN'S FOUR",
    "THE ABC WEDNESDAY NIGHT MOVIE",
    "THE HAMPTONS",
    "TWO MARRIAGES",
    "SEVEN BRIDES FOR SEVEN BROTHERS",
    "ZORRO AND SON",
    "BUFFALO BILL",
    "THE NEWS IS THE NEWS",
    "THE FAMILY TREE",
    "STAR OF THE FAMILY",
    "IT TAKES TWO",
    "CONDO",
    "AMANDA'S",
    "THE NEW ODD COUPLE",
    "THE ABC THURSDAY NIGHT MOVIE",
    "EYE ON HOLLYWOOD",
    "REGGIE",
    "CHEERS",
    "MAMA'S FAMILY",
    "THE QUEST",
    "ABC FRIDAY NIGHT MOVIE",
    "AT EASE",
    "RENEGADES",
    "BABY MAKES FIVE",
    "THE MISSISSIPPI",
    "T. J. HOOKER",
    "THE CBS SATURDAY NIGHT MOVIE",
    "WIZARDS AND WARRIORS",
    "SILVER SPOONS",
    "THE DEVLIN CONNECTION",
    "MONITOR",
    "HARDCASTLE AND MCCORMICK",
    "THE FOUR SEASONS",
    "MAGGIE BRIGGS",
    "DOMESTIC LIFE",
    "AFTERMASH",
    "FIRST CAMERA",
    "SUMMER SUNDAY U.S.A.",
    "AUTOMAN",
    "CALL TO GLORY",
    "SCARECROW AND MRS. KING",
    "EMERALD POINT N.A.S.",
    "KATE & ALLIE",
    "BOONE",
    "TV'S BLOOPERS & PRACTICAL JOKES",
    "JUST OUR LUCK",
    "OH MADELINE",
    "FOUL-UPS, BLEEPS & BLUNDERS",
    "A.K.A. PABLO",
    "SHAPING UP",
    "HOTEL",
    "THE ABC TUESDAY NIGHT MOVIE",
    "THE AMERICAN PARADE",
    "BAY CITY BLUES",
    "FOR LOVE AND HONOR",
    "RIPTIDE",
    "WHIZ KIDS",
    "EMPIRE",
    "MAMA MALONE",
    "NIGHT COURT",
    "DOUBLE TROUBLE",
    "THE DUCK FACTORY",
    "JENNIFER SLEPT HERE",
    "VARIOUS PILOTS",
    "TRAUMA CENTER",
    "IT'S NOT EASY",
    "MASQUERADE",
    "LOTTERY!",
    "WE GOT IT MADE",
    "WEBSTER",
    "BLUE THUNDER",
    "MR. SMITH",
    "MANIMAL",
    "LEGMEN",
    "THE MASTER",
    "THE NEW SHOW",
    "CUTTER TO HOUSTON",
    "AIRWOLF",
    "MICKEY SPILLANE'S MIKE HAMMER",
    "THE ROUSTERS",
    "THE YELLOW ROSE",
    "PEOPLE ARE FUNNY",
    "MURDER, SHE WROTE",
    "CRAZY LIKE A FOX",
    "PUNKY BREWSTER",
    "OCEANQUEST",
    "THREE'S A CROWD",
    "PAPER DOLLS",
    "JESSIE",
    "WHO'S THE BOSS?",
    "GLITTER",
    "MACGRUDER AND LOUD",
    "MOONLIGHTING",
    "HAIL TO THE CHIEF",
    "E/R",
    "THE LUCIE ARNAZ SHOW",
    "WEST 57TH",
    "ROCK 'N' ROLL SUMMER ACTION",
    "CHARLES IN CHARGE",
    "DREAMS",
    "DOUBLE DARE",
    "I HAD THREE WIVES",
    "HIGHWAY TO HEAVEN",
    "IT'S YOUR MOVE",
    "SARA",
    "PEOPLE DO THE CRAZIEST THINGS",
    "WILDSIDE",
    "EYE TO EYE",
    "STREET HAWK",
    "THE COSBY SHOW",
    "HAWAIIAN HEAT",
    "MR. BELVEDERE",
    "OFF THE RACK",
    "ME AND MOM",
    "THE COMEDY FACTORY",
    "DETECTIVE IN THE HOUSE",
    "V",
    "HUNTER",
    "MIAMI VICE",
    "HOT PURSUIT",
    "CODE NAME: FOXFIRE",
    "THE BEST TIMES",
    "HALF NELSON",
    "TELEVISION PARTS",
    "UNDER ONE ROOF",
    "MOTOWN REVUE",
    "FINDER OF LOST LOVES",
    "COVER UP",
    "OTHERWORLD",
    "PARTNERS IN CRIME",
    "SPENCER",
    "BERRENGER'S",
    "OUR TIME",
    "MACGYVER",
    "THE DISNEY SUNDAY MOVIE",
    "CBS SUNDAY MOVIE",
    "AMAZING STORIES",
    "ALFRED HITCHCOCK PRESENTS",
    "FATHERS AND SONS",
    "DALTON'S CODE OF VENGEANCE",
    "THE INSIDERS",
    "YOU AGAIN?",
    "VALERIE",
    "GROWING PAINS",
    "OUR FAMILY HONOR",
    "SPENSER: FOR HIRE",
    "PERFECT STRANGERS",
    "HOMETOWN",
    "CBS TUESDAY NIGHT MOVIE",
    "STIR CRAZY",
    "MORNINGSTAR/EVENINGSTAR",
    "MARY",
    "FOLEY SQUARE",
    "THE EQUALIZER",
    "STINGRAY",
    "1986",
    "MR. SUNSHINE",
    "CHARLIE & CO.",
    "GEORGE BURNS COMEDY WEEK",
    "FAST TIMES",
    "TOUGH COOKIES",
    "CBS WEDNESDAY NIGHT MOVIE",
    "HELL TOWN",
    "BLACKE'S MAGIC",
    "LADY BLUE",
    "ABC THURSDAY NIGHT MOVIE",
    "SHADOW CHASERS",
    "THE COLBYS",
    "BRIDGES TO CROSS",
    "CBS THURSDAY NIGHT MOVIE",
    "PRICE IS RIGHT SPECIAL",
    "ALL IS FORGIVEN",
    "HE'S THE MAYOR",
    "JOE BASH",
    "THE TWILIGHT ZONE",
    "LEO & LIZ IN BEVERLY HILLS",
    "CBS FRIDAY MOVIE",
    "MISFITS OF SCIENCE",
    "THE LAST PRECINCT",
    "HOLLYWOOD BEAT",
    "LIME STREET",
    "THE REDD FOXX SHOW",
    "FORTUNE DANE",
    "ABC SATURDAY NIGHT MOVIE",
    "CBS SATURDAY NIGHT MOVIE",
    "MELBA",
    "THE GOLDEN GIRLS",
    "227",
    "ME & MRS. C",
    "DESIGNING WOMEN",
    "NOTHING IS EASY",
    "HARD COPY",
    "21 JUMP STREET",
    "MARRIED... WITH CHILDREN",
    "THE TRACEY ULLMAN SHOW",
    "MR. PRESIDENT",
    "DUET",
    "LOCAL PROGRAMMING",
    "OUR HOUSE",
    "EASY STREET",
    "RAGS TO RICHES",
    "MY SISTER SAM",
    "THE CAVANAUGHS",
    "ALF",
    "JACK AND MIKE",
    "MAX HEADROOM",
    "THE WIZARD",
    "SPIES",
    "HOUSTON KNIGHTS",
    "NIGHT HEAT",
    "MATLOCK",
    "CRIME STORY",
    "THE TORTELLIS",
    "HEAD OF THE CLASS",
    "HARRY",
    "MARIAH",
    "TOGETHER WE STAND",
    "BETTER DAYS",
    "THE NEW MIKE HAMMER",
    "ROXIE",
    "TAKE FIVE",
    "THE BRONX ZOO",
    "OUR WORLD",
    "HEART OF THE CITY",
    "STARMAN",
    "SLEDGE HAMMER!",
    "THE CHARMINGS",
    "KAY O'BRIEN",
    "SHELL GAME",
    "L.A. LAW",
    "NOTHING IN COMMON",
    "THE DAYS AND NIGHTS OF MOLLY DODD",
    "SIDEKICKS",
    "DADS",
    "GUNG HO",
    "THE POPCORN KID",
    "CBS SUMMER PLAYHOUSE",
    "ADDERLY",
    "ROOMIES",
    "LIFE WITH LUCY",
    "THE ELLEN BURSTYN SHOW",
    "OHARA",
    "THE ABC SATURDAY NIGHT MOVIE",
    "ANIMAL CRACK-UPS",
    "DOWNTOWN",
    "OUTLAWS",
    "DOWN AND OUT IN BEVERLY HILLS",
    "THE NEW ADVENTURES OF BEANS BAXTER",
    "WEREWOLF",
    "KAREN'S SONG",
    "AMEN",
    "SWEET SURRENDER",
    "DOLLY",
    "BUCK JAMES",
    "SUPERCARRIER",
    "IT'S GARRY SHANDLING'S SHOW",
    "AMERICA'S MOST WANTED",
    "MY TWO DADS",
    "DAY BY DAY",
    "FRANK'S PLACE",
    "WISEGUY",
    "EISENHOWER AND LUTZ",
    "BLUE SKIES",
    "VALERIE'S FAMILY",
    "THIRTYSOMETHING",
    "THE WONDER YEARS",
    "JUST THE TEN OF US",
    "FULL HOUSE",
    "JAKE AND THE FATMAN",
    "THE LAW & HARRY MCGRAW",
    "48 HOURS",
    "TRIAL AND ERROR",
    "COMING OF AGE",
    "J.J. STARBUCK",
    "IN THE HEAT OF THE NIGHT",
    "NBC SUMMER SHOWCASE",
    "HOOPERMAN",
    "THE SLAP MAXWELL STORY",
    "JUST IN TIME",
    "HEARTBEAT",
    "CHINA BEACH",
    "THE OLDEST ROOKIE",
    "THE SMOTHERS BROTHERS SHOW",
    "A YEAR IN THE LIFE",
    "AARON'S WAY",
    "GEORGE SCHLATTER'S FUNNY PEOPLE",
    "THE NBC WEDNESDAY NIGHT MOVIE",
    "PROBE",
    "HOTHOUSE",
    "TOUR OF DUTY",
    "A DIFFERENT WORLD",
    "I MARRIED DORA",
    "PURSUIT OF HAPPINESS",
    "THE THORNS",
    "FAMILY MAN",
    "BEAUTY AND THE BEAST",
    "PRIVATE EYE",
    "SONNY SPOON",
    "THE HIGHWAYMAN",
    "BEVERLY HILLS BUNTZ",
    "ONCE A HERO",
    "SABLE",
    "EVERYTHING'S RELATIVE",
    "LEG WORK",
    "HIGH MOUNTAIN RANGERS",
    "FIRST IMPRESSIONS",
    "SECOND CHANCE",
    "WOMEN IN PRISON",
    "BOYS WILL BE BOYS",
    "FAMILY DOUBLE DARE",
    "DIRTY DOZEN: THE SERIES",
    "THE REPORTERS",
    "INCREDIBLE SUNDAY",
    "MISSION: IMPOSSIBLE",
    "GREAT CIRCUSES OF THE WORLD",
    "HAVE FAITH",
    "TOTALLY HIDDEN VIDEO",
    "THE MAGICAL WORLD OF DISNEY",
    "THE JIM HENSON HOUR",
    "THE ABC MONDAY MYSTERY MOVIE",
    "CBS MONDAY NIGHT MOVIE",
    "MURPHY BROWN",
    "ALMOST GROWN",
    "LIVE-IN",
    "HEARTLAND",
    "DOCTOR DOCTOR",
    "THE HOGAN FAMILY",
    "NEARLY DEPARTED",
    "ROSEANNE",
    "ANYTHING BUT LOVE",
    "COACH",
    "HIGH RISK",
    "CBS TUESDAY MOVIE",
    "TV 101",
    "MIDNIGHT CALLER",
    "THE ROBERT GUILLAUME SHOW",
    "LIVE! DICK CLARK PRESENTS",
    "THE VAN DYKE SHOW",
    "ANNIE MCGUIRE",
    "HARD TIME ON PLANET EARTH",
    "THE SMOTHERS BROTHERS COMEDY HOUR",
    "UNSOLVED MYSTERIES",
    "BABY BOOM",
    "TATTINGERS",
    "NIGHTINGALES",
    "QUANTUM LEAP",
    "KNIGHT & DAYE",
    "FM",
    "KNIGHTWATCH",
    "A FINE ROMANCE",
    "ABC NEWS SPECIALS",
    "THURSDAY NIGHT BASEBALL",
    "A MAN CALLED HAWK",
    "PRIMETIME LIVE",
    "PARADISE",
    "DEAR JOHN",
    "SOMETHING IS OUT THERE",
    "FATHER DOWLING MYSTERIES",
    "UNSUB",
    "DREAM STREET",
    "MURPHY'S LAW",
    "MEN",
    "DIRTY DANCING",
    "RAISING MIRANDA",
    "DOLPHIN COVE",
    "JESSE HAWKES",
    "BEYOND TOMORROW",
    "COPS",
    "EMPTY NEST",
    "13 EAST",
    "LIFE GOES ON",
    "FREE SPIRIT",
    "HOMEROOM",
    "AMERICA'S FUNNIEST HOME VIDEOS",
    "ELVIS",
    "TIM CONWAY'S FUNNY AMERICA",
    "BOOKER",
    "OPEN HOUSE",
    "THE SIMPSONS",
    "THE OUTSIDERS",
    "IN LIVING COLOR",
    "BRAND NEW LIFE",
    "SISTER KATE",
    "ANN JILLIAN",
    "A FAMILY FOR JOE",
    "CAPITAL NEWS",
    "THE YOUNG RIDERS",
    "MAJOR DAD",
    "THE PEOPLE NEXT DOOR",
    "THE FAMOUS TEDDY Z",
    "CITY",
    "HIS & HERS",
    "SYDNEY",
    "THE DAVE THOMAS COMEDY SHOW",
    "SATURDAY NIGHT WITH CONNIE CHUNG",
    "ALIEN NATION",
    "WORKING GIRL",
    "SHANNON'S DEAL",
    "CHICKEN SOUP",
    "RESCUE 911",
    "WOLF",
    "ISLAND SON",
    "REAL LIFE WITH JANE PAULEY",
    "DOOGIE HOWSER, M.D.",
    "THE MARSHALL CHRONICLES",
    "EQUAL JUSTICE",
    "BREWSTER PLACE",
    "PEACEABLE KINGDOM",
    "GRAND SLAM",
    "NORMAL LIFE",
    "THIS IS AMERICA, CHARLIE BROWN",
    "TOP COPS",
    "GLORY DAYS",
    "MOLLOY",
    "THE NUTT HOUSE",
    "SINGER & SONS",
    "TWIN PEAKS",
    "TOP OF THE HILL",
    "MAX MONROE: LOOSE CANNON",
    "NORTHERN EXPOSURE",
    "THE EDDIE CAPRA MYSTERIES",
    "GRAND",
    "WINGS",
    "SEINFELD",
    "FAMILY MATTERS",
    "NEW ATTITUDE",
    "SNOOPS",
    "THE BRADYS",
    "BAGDAD CAFE",
    "SUGAR AND SPICE",
    "SMALL TALK",
    "PRIME TIME PETS",
    "CANDID CAMERA",
    "WISH YOU WERE HERE",
    "ROOM FOR ROMANCE",
    "BAYWATCH",
    "HARDBALL",
    "MANCUSO, F.B.I.",
    "TRUE BLUE",
    "NASTY BOYS",
    "LIVING DOLLS",
    "THE ABC SATURDAY MYSTERY MOVIE",
    "H.E.L.P.",
    "SUNSET BEAT",
    "SUPER JEOPARDY!",
    "MONOPOLY",
    "CAROL AND COMPANY",
    "DOWN HOME",
]

SEASONS = {
    1979: {
        "SUN": {"ABC": [[96, [[1140,1170,0,0,0], [1170,1200,1,0,0], [1200,1230,2,27,0], [1230,1260,3,0,0], [1260,1380,4,29,0]]], [110, [[1140,1200,5,0,0], [1200,1230,2,27,0], [1230,1260,3,0,0], [1260,1380,4,29,0]]], [130, [[1140,1200,6,0,0], [1200,1260,7,29,0], [1260,1380,4,29,0]]], [150, [[1140,1200,6,0,0], [1200,1260,7,29,0], [1260,1380,4,29,0]]], [180, [[1140,1200,6,0,0], [1200,1260,8,0,1], [1260,1380,4,29,0]]]], "CBS": [[0, [[1140,1200,9,1,0], [1200,1230,10,11,0], [1230,1260,11,10,0], [1260,1290,12,4,0], [1290,1320,13,8,0], [1320,1380,14,19,0]]]], "NBC": [[96, [[1140,1200,15,0,0], [1200,1320,16,0,0], [1320,1380,17,0,0]]], [130, [[1140,1200,15,0,0], [1200,1320,16,0,0], [1320,1380,17,0,0]]], [150, [[1140,1200,15,0,0], [1200,1320,16,0,0], [1320,1380,17,0,0]]], [180, [[1140,1200,15,0,0], [1200,1260,18,0,1], [1260,1380,16,0,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,19,0,0], [1260,1380,20,0,0]]], [130, [[1200,1260,21,0,0], [1260,1380,22,0,0]]], [140, [[1200,1230,23,0,0], [1230,1260,24,0,0], [1260,1320,25,0,0], [1320,1380,26,0,0]]], [150, [[1200,1260,27,3,0], [1260,1320,26,0,0], [1320,1380,25,0,0]]], [180, [[1200,1230,28,0,1], [1230,1380,29,0,0]]]], "CBS": [[96, [[1200,1260,30,0,0], [1260,1290,31,4,0], [1290,1320,32,22,0], [1320,1380,33,0,0]]], [130, [[1200,1260,30,0,0], [1260,1290,31,4,0], [1290,1320,34,14,0], [1320,1380,33,0,0]]], [140, [[1200,1230,32,22,0], [1230,1260,35,0,0], [1260,1290,31,4,0], [1290,1320,34,14,0], [1320,1380,33,0,0]]], [150, [[1200,1230,32,22,0], [1230,1260,36,0,0], [1260,1290,31,4,0], [1290,1320,37,7,0], [1320,1380,33,0,0]]], [180, [[1200,1230,32,22,0], [1230,1260,38,0,0], [1260,1290,31,4,0], [1290,1320,34,14,0], [1320,1380,33,0,0]]]], "NBC": [[0, [[1200,1260,39,16,0], [1260,1380,40,0,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,41,17,0], [1230,1260,24,0,0], [1260,1290,42,2,0], [1290,1320,43,13,0], [1320,1380,44,0,0]]], [110, [[1200,1230,41,17,0], [1230,1260,24,0,0], [1260,1290,42,2,0], [1290,1320,43,13,0], [1320,1380,45,0,0]]], [130, [[1200,1230,41,17,0], [1230,1260,28,0,0], [1260,1290,42,2,0], [1290,1320,43,13,0], [1320,1380,45,0,0]]], [140, [[1200,1230,41,17,0], [1230,1260,46,0,0], [1260,1290,42,2,0], [1290,1320,43,13,0], [1320,1380,45,0,0]]], [150, [[1200,1230,41,17,0], [1230,1260,23,0,0], [1260,1290,42,2,0], [1290,1320,43,13,0], [1320,1380,45,0,0]]], [180, [[1200,1230,41,17,0], [1230,1260,23,0,0], [1260,1290,42,2,0], [1290,1320,43,13,0], [1320,1380,45,0,0]]]], "CBS": [[96, [[1200,1260,47,0,0], [1260,1380,48,0,0]]], [110, [[1200,1260,47,0,0], [1260,1320,49,0,0], [1320,1380,50,0,0]]], [130, [[1200,1260,30,0,0], [1260,1320,49,0,0], [1320,1380,50,0,0]]], [140, [[1200,1260,30,0,0], [1260,1380,48,0,0]]], [150, [[1200,1260,30,0,0], [1260,1380,48,0,0]]], [180, [[1200,1260,30,0,0], [1260,1380,48,0,0]]]], "NBC": [[96, [[1200,1260,51,0,0], [1260,1380,52,0,0]]], [130, [[1200,1260,51,0,0], [1260,1380,52,0,0]]], [150, [[1200,1260,51,0,0], [1260,1350,53,0,0], [1350,1380,54,0,0]]], [180, [[1200,1260,51,0,0], [1260,1350,53,0,0], [1350,1380,54,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1260,55,12,0], [1260,1320,56,20,0], [1320,1380,57,29,0]]], [130, [[1200,1260,55,12,0], [1260,1320,56,20,0], [1320,1380,57,29,0]]], [150, [[1200,1260,55,12,0], [1260,1320,56,20,0], [1320,1380,57,29,0]]], [180, [[1200,1260,26,0,0], [1260,1320,56,20,0], [1320,1380,57,29,0]]], [190, [[1200,1320,21,0,0], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1230,35,0,0], [1230,1260,59,0,0], [1260,1380,60,0,0]]], [110, [[1200,1230,35,0,0], [1230,1260,61,0,0], [1260,1380,60,0,0]]], [115, [[1200,1260,62,0,0], [1260,1380,60,0,0]]], [130, [[1200,1260,62,0,0], [1260,1380,60,0,0]]], [150, [[1200,1260,63,0,0], [1260,1380,60,0,0]]], [180, [[1200,1260,63,0,0], [1260,1380,60,0,0]]]], "NBC": [[96, [[1200,1260,64,14,0], [1260,1290,65,26,0], [1290,1320,66,0,0], [1320,1380,67,0,1]]], [130, [[1200,1260,64,14,0], [1260,1290,65,26,0], [1290,1320,66,0,0], [1320,1380,67,0,1]]], [150, [[1200,1260,64,14,0], [1260,1290,65,26,0], [1290,1320,66,0,0], [1320,1380,68,0,0]]], [180, [[1200,1260,64,14,0], [1260,1290,65,26,0], [1290,1320,69,0,0], [1320,1380,70,0,1]]]]},
        "THU": {"ABC": [[96, [[1200,1230,23,0,0], [1230,1260,71,23,0], [1260,1290,72,20,0], [1290,1320,73,25,0], [1320,1380,58,0,0]]], [130, [[1200,1230,2,27,0], [1230,1260,71,23,0], [1260,1290,72,20,0], [1290,1320,73,25,0], [1320,1380,58,0,0]]], [150, [[1200,1230,2,27,0], [1230,1260,71,23,0], [1260,1290,72,20,0], [1290,1320,3,0,0], [1320,1380,58,0,0]]], [160, [[1200,1230,2,27,0], [1230,1260,71,23,0], [1260,1290,72,20,0], [1290,1320,74,0,0], [1320,1380,58,0,0]]], [180, [[1200,1230,2,27,0], [1230,1260,24,0,0], [1260,1290,72,20,0], [1290,1320,75,0,0], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,76,0,0], [1260,1320,49,0,0], [1320,1380,77,0,0]]], [130, [[1200,1260,76,0,0], [1260,1320,77,0,0], [1320,1380,78,29,0]]], [150, [[1200,1260,79,0,0], [1260,1320,77,0,0], [1320,1380,80,0,0]]], [180, [[1200,1260,76,0,0], [1260,1320,77,0,0], [1320,1380,80,0,0]]]], "NBC": [[96, [[1200,1260,81,0,0], [1260,1320,70,0,0], [1320,1380,82,0,0]]], [130, [[1200,1260,81,0,0], [1260,1320,70,0,0], [1320,1380,83,0,0]]], [150, [[1200,1260,81,0,0], [1260,1320,70,0,0], [1320,1380,84,0,1]]], [180, [[1200,1260,81,0,0], [1260,1380,85,0,0]]], [190, [[1200,1260,86,0,0], [1260,1380,85,0,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1260,87,28,0], [1260,1380,88,0,0]]], [130, [[1200,1260,89,0,0], [1260,1380,88,0,0]]], [150, [[1200,1260,8,0,0], [1260,1380,88,0,0]]], [180, [[1200,1320,88,0,0], [1320,1380,7,0,1]]], [190, [[1200,1230,71,0,1], [1230,1260,46,0,0], [1260,1380,88,0,0]]]], "CBS": [[0, [[1200,1260,90,0,0], [1260,1320,91,9,0], [1320,1380,92,6,0]]]], "NBC": [[96, [[1200,1260,93,0,0], [1260,1320,84,0,0], [1320,1380,94,0,0]]], [130, [[1200,1260,93,0,0], [1260,1380,95,0,0]]], [140, [[1200,1260,96,0,0], [1260,1380,95,0,0]]], [150, [[1200,1230,97,0,0], [1230,1260,69,0,0], [1260,1320,21,0,0], [1320,1380,98,0,0]]], [180, [[1200,1230,97,0,0], [1230,1260,99,0,0], [1260,1320,84,0,0], [1320,1380,21,0,0]]], [200, [[1200,1320,21,0,0], [1320,1380,100,0,0]]]]},
        "SAT": {"ABC": [[96, [[1200,1230,74,0,0], [1230,1260,101,0,0], [1260,1320,102,23,0], [1320,1380,45,0,0]]], [110, [[1200,1230,74,0,0], [1230,1260,101,0,0], [1260,1320,102,23,0], [1320,1380,87,28,0]]], [115, [[1200,1230,74,0,0], [1230,1260,1,0,0], [1260,1320,102,23,0], [1320,1380,87,28,0]]], [130, [[1200,1230,28,0,0], [1230,1260,74,0,0], [1260,1320,102,23,0], [1320,1380,87,28,0]]], [150, [[1200,1230,24,0,0], [1230,1260,46,0,0], [1260,1320,102,23,0], [1320,1380,87,28,0]]], [180, [[1200,1260,21,0,0], [1260,1320,102,23,0], [1320,1380,8,0,0]]], [190, [[1200,1260,21,0,0], [1260,1320,102,23,0], [1320,1380,87,28,0]]]], "CBS": [[96, [[1200,1230,103,0,0], [1230,1260,61,0,0], [1260,1320,104,0,0], [1320,1380,50,0,0]]], [101, [[1200,1260,21,0,0], [1260,1380,105,0,0]]], [130, [[1200,1260,106,0,0], [1260,1380,105,0,0]]], [150, [[1200,1260,107,0,0], [1260,1320,49,0,0], [1320,1380,108,0,0]]], [160, [[1200,1260,107,0,0], [1260,1380,105,0,0]]], [180, [[1200,1230,61,0,0], [1230,1260,36,0,0], [1260,1380,105,0,0]]], [190, [[1200,1230,11,0,1], [1230,1260,61,0,0], [1260,1380,105,0,0]]], [200, [[1200,1260,109,0,0], [1260,1380,105,0,0]]]], "NBC": [[96, [[1200,1260,18,18,0], [1260,1320,110,0,0], [1320,1380,111,0,0]]], [130, [[1200,1260,18,18,0], [1260,1320,110,0,0], [1320,1380,112,0,0]]], [150, [[1200,1260,110,0,0], [1260,1290,113,0,0], [1290,1320,99,0,0], [1320,1380,112,0,0]]], [160, [[1200,1260,110,0,0], [1260,1290,113,0,0], [1290,1320,114,0,0], [1320,1380,112,0,0]]], [180, [[1200,1260,81,0,1], [1260,1320,21,0,0], [1320,1350,114,0,0], [1350,1380,115,0,0]]]]},
    },
    1980: {
        "SUN": {"ABC": [[96, [[1140,1200,116,0,0], [1200,1260,117,0,0], [1260,1380,4,24,0]]], [110, [[1140,1200,116,0,0], [1200,1260,56,0,0], [1260,1380,4,24,0]]], [130, [[1140,1200,116,0,0], [1200,1260,56,0,0], [1260,1380,4,24,0]]], [150, [[1140,1200,116,0,0], [1200,1260,118,0,0], [1260,1380,4,24,0]]], [180, [[1140,1200,116,0,0], [1200,1260,118,0,0], [1260,1380,4,24,0]]]], "CBS": [[0, [[1140,1200,9,3,0], [1200,1230,10,13,0], [1230,1260,11,11,0], [1260,1290,12,7,0], [1290,1320,13,6,0], [1320,1380,14,17,0]]]], "NBC": [[0, [[1140,1200,119,0,0], [1200,1260,18,24,0], [1260,1380,16,0,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,27,22,0], [1260,1380,20,20,0]]], [130, [[1200,1260,27,22,0], [1260,1320,120,0,0], [1320,1380,121,0,0]]], [150, [[1200,1260,27,22,0], [1260,1320,120,0,0], [1320,1380,73,0,0]]], [180, [[1200,1230,118,0,0], [1230,1380,29,0,0]]]], "CBS": [[96, [[1200,1230,37,0,0], [1230,1260,122,0,0], [1260,1290,31,4,0], [1290,1320,34,8,0], [1320,1380,33,27,0]]], [130, [[1200,1230,37,0,0], [1230,1260,122,0,0], [1260,1290,31,4,0], [1290,1320,34,8,0], [1320,1380,33,27,0]]], [150, [[1200,1230,123,0,0], [1230,1260,122,0,0], [1260,1290,31,4,0], [1290,1320,34,8,0], [1320,1380,33,27,0]]], [155, [[1200,1230,123,0,0], [1230,1260,124,0,0], [1260,1290,31,4,0], [1290,1320,34,8,0], [1320,1380,33,27,0]]], [180, [[1200,1230,123,0,0], [1230,1260,107,0,0], [1260,1290,31,4,0], [1290,1320,34,8,0], [1320,1380,33,27,0]]]], "NBC": [[96, [[1200,1260,39,10,0], [1260,1380,40,29,0]]], [130, [[1200,1260,39,10,0], [1260,1380,40,29,0]]], [150, [[1200,1260,39,10,0], [1260,1380,40,29,0]]], [180, [[1200,1260,39,10,0], [1260,1320,125,0,0], [1320,1380,126,0,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,41,15,0], [1230,1260,23,20,0], [1260,1290,42,8,0], [1290,1320,127,15,0], [1320,1380,45,23,0]]], [130, [[1200,1230,41,15,0], [1230,1260,23,20,0], [1260,1290,42,8,0], [1290,1320,127,15,0], [1320,1380,45,23,0]]], [150, [[1200,1230,41,15,0], [1230,1260,23,20,0], [1260,1290,42,8,0], [1290,1320,127,15,0], [1320,1380,45,23,0]]], [180, [[1200,1230,41,15,0], [1230,1260,23,20,0], [1260,1290,42,8,0], [1290,1320,128,0,0], [1320,1380,45,23,0]]]], "CBS": [[96, [[1200,1260,117,0,0], [1260,1380,129,0,0]]], [110, [[1200,1260,30,0,0], [1260,1380,129,0,0]]], [130, [[1200,1260,130,0,0], [1260,1380,129,0,0]]], [150, [[1200,1260,79,0,0], [1260,1380,129,0,0]]], [180, [[1200,1230,131,0,0], [1230,1260,37,0,0], [1260,1380,129,0,0]]]], "NBC": [[96, [[1200,1320,52,0,0], [1320,1380,132,0,0]]], [110, [[1200,1260,133,0,0], [1260,1320,110,0,0], [1320,1380,132,0,0]]], [130, [[1200,1260,133,0,0], [1260,1320,110,0,0], [1320,1380,125,0,0]]], [150, [[1200,1260,133,0,0], [1260,1320,134,0,0], [1320,1380,125,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1260,55,0,0], [1260,1290,43,0,0], [1290,1320,73,0,0], [1320,1380,57,0,0]]], [130, [[1200,1260,55,0,0], [1260,1290,43,0,0], [1290,1320,73,0,0], [1320,1380,57,0,0]]], [150, [[1200,1260,135,0,0], [1260,1320,136,0,0], [1320,1380,137,0,0]]], [180, [[1200,1260,56,0,0], [1260,1380,138,0,0]]], [185, [[1200,1260,56,0,0], [1260,1320,57,0,0], [1320,1380,120,0,0]]]], "CBS": [[0, [[1200,1260,139,0,0], [1260,1380,140,0,0]]]], "NBC": [[96, [[1200,1260,64,12,0], [1260,1380,141,0,0]]], [110, [[1200,1260,64,12,0], [1260,1290,65,17,0], [1290,1320,69,26,0], [1320,1380,70,0,0]]], [130, [[1200,1260,64,12,0], [1260,1290,65,17,0], [1290,1320,69,26,0], [1320,1380,70,0,0]]], [150, [[1200,1260,64,12,0], [1260,1290,65,17,0], [1290,1320,69,26,0], [1320,1380,70,0,0]]], [180, [[1200,1260,64,12,0], [1260,1290,65,17,0], [1290,1320,69,26,0], [1320,1380,70,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1230,2,0,0], [1230,1260,142,0,0], [1260,1290,72,0,0], [1290,1320,128,0,0], [1320,1380,58,0,0]]], [130, [[1200,1230,2,0,0], [1230,1260,142,0,0], [1260,1290,72,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]], [150, [[1200,1230,2,0,0], [1230,1260,142,0,0], [1260,1290,72,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]], [180, [[1200,1230,2,0,0], [1230,1260,142,0,0], [1260,1290,72,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,76,30,0], [1260,1380,143,0,0]]], [120, [[1200,1260,76,30,0], [1260,1320,144,14,0], [1320,1380,78,28,0]]], [130, [[1200,1260,76,30,0], [1260,1320,144,14,0], [1320,1380,78,28,0]]], [150, [[1200,1230,131,0,0], [1230,1260,145,0,0], [1260,1320,144,14,0], [1320,1380,78,28,0]]], [160, [[1200,1230,131,0,0], [1230,1260,145,0,0], [1260,1320,144,14,0], [1320,1380,146,0,0]]], [170, [[1200,1260,76,30,0], [1260,1320,144,14,0], [1320,1380,78,28,0]]], [180, [[1200,1260,76,30,0], [1260,1320,144,14,0], [1320,1380,78,28,0]]]], "NBC": [[96, [[1200,1260,86,0,0], [1260,1380,85,0,0]]], [130, [[1200,1260,81,0,0], [1260,1380,85,0,0]]], [150, [[1200,1260,81,0,0], [1260,1380,85,0,0]]], [180, [[1200,1260,81,0,0], [1260,1380,85,0,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,71,0,0], [1230,1260,147,0,0], [1260,1380,88,0,0]]], [130, [[1200,1230,71,0,0], [1230,1260,147,0,0], [1260,1380,88,0,0]]], [150, [[1200,1230,71,0,0], [1230,1260,147,0,0], [1260,1380,88,0,0]]], [180, [[1200,1230,71,0,0], [1230,1260,148,0,0], [1260,1380,88,0,0]]]], "CBS": [[0, [[1200,1260,90,0,0], [1260,1320,91,2,0], [1320,1380,92,1,0]]]], "NBC": [[96, [[1200,1320,95,0,0], [1320,1380,149,0,0]]], [120, [[1200,1260,150,0,0], [1260,1320,151,0,0], [1320,1380,149,0,0]]], [130, [[1200,1230,152,0,0], [1230,1260,113,0,0], [1260,1320,134,0,0], [1320,1380,149,0,0]]], [135, [[1200,1230,152,0,0], [1230,1260,153,0,0], [1260,1320,134,0,0], [1320,1380,149,0,0]]], [150, [[1200,1230,152,0,0], [1230,1260,113,0,0], [1260,1320,134,0,0], [1320,1380,149,0,0]]], [155, [[1200,1230,152,0,0], [1230,1260,113,0,0], [1260,1320,118,0,0], [1320,1380,149,0,0]]], [180, [[1200,1230,152,0,0], [1230,1260,154,0,0], [1260,1320,118,0,0], [1320,1380,149,0,0]]]]},
        "SAT": {"ABC": [[96, [[1200,1260,117,0,0], [1260,1320,102,5,0], [1320,1380,87,17,0]]], [110, [[1200,1260,155,0,0], [1260,1320,102,5,0], [1320,1380,87,17,0]]], [130, [[1200,1260,56,0,0], [1260,1320,102,5,0], [1320,1380,87,17,0]]], [135, [[1200,1260,19,0,0], [1260,1320,102,5,0], [1320,1380,87,17,0]]], [150, [[1200,1260,55,0,0], [1260,1320,102,5,0], [1320,1380,87,17,0]]]], "CBS": [[96, [[1200,1230,32,0,0], [1230,1260,107,0,0], [1260,1380,156,0,0]]], [120, [[1200,1230,32,0,0], [1230,1260,107,0,0], [1260,1320,157,0,0], [1320,1380,158,0,0]]], [125, [[1200,1230,32,0,0], [1230,1260,107,0,0], [1260,1290,37,0,0], [1290,1320,122,0,0], [1320,1380,159,0,0]]], [150, [[1200,1230,32,0,0], [1230,1260,37,0,0], [1260,1320,159,0,0], [1320,1380,160,0,0]]], [155, [[1200,1260,139,0,0], [1260,1380,156,0,0]]]], "NBC": [[96, [[1200,1260,161,0,0], [1260,1380,162,0,0]]], [130, [[1200,1260,161,0,0], [1260,1320,163,0,0], [1320,1380,164,0,0]]], [135, [[1200,1260,161,0,0], [1260,1320,165,0,0], [1320,1380,164,0,0]]], [150, [[1200,1260,161,0,0], [1260,1320,166,0,0], [1320,1380,163,0,0]]], [180, [[1200,1260,161,0,0], [1260,1320,166,0,0], [1320,1380,86,0,0]]]]},
    },
    1981: {
        "SUN": {"ABC": [[0, [[1140,1200,167,0,0], [1200,1260,168,0,0], [1260,1380,4,22,0]]]], "CBS": [[0, [[1140,1200,9,2,0], [1200,1230,10,12,0], [1230,1260,11,10,0], [1260,1290,12,5,0], [1290,1320,13,3,0], [1320,1380,14,15,0]]]], "NBC": [[96, [[1140,1200,169,0,0], [1200,1260,18,0,0], [1260,1380,170,0,0]]], [130, [[1140,1200,169,0,0], [1200,1260,18,0,0], [1260,1380,170,0,0]]], [150, [[1140,1200,171,0,0], [1200,1260,18,0,0], [1260,1380,170,0,0]]], [180, [[1140,1200,171,0,0], [1200,1260,18,0,0], [1260,1380,170,0,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,27,28,0], [1260,1380,20,11,0]]], [130, [[1200,1260,27,28,0], [1260,1380,172,8,0]]], [150, [[1200,1260,27,28,0], [1260,1380,172,8,0]]], [180, [[1200,1230,173,0,0], [1230,1380,29,0,0]]]], "CBS": [[96, [[1200,1230,123,0,0], [1230,1260,124,0,0], [1260,1290,31,9,0], [1290,1320,34,23,0], [1320,1380,33,0,0]]], [130, [[1200,1230,174,0,0], [1230,1260,123,0,0], [1260,1290,31,9,0], [1290,1320,34,23,0], [1320,1380,33,0,0]]], [150, [[1200,1230,123,0,0], [1230,1260,175,0,0], [1260,1290,31,9,0], [1290,1320,176,0,0], [1320,1380,33,0,0]]], [180, [[1200,1230,123,0,0], [1230,1260,32,0,0], [1260,1290,31,9,0], [1290,1320,34,0,0], [1320,1380,33,0,0]]], [185, [[1200,1230,123,0,0], [1230,1260,32,0,0], [1260,1290,31,9,0], [1290,1320,177,0,0], [1320,1380,33,0,0]]]], "NBC": [[0, [[1200,1260,39,24,0], [1260,1380,40,0,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,41,18,0], [1230,1260,23,20,0], [1260,1290,42,4,0], [1290,1320,127,6,0], [1320,1380,45,15,0]]], [130, [[1200,1230,41,18,0], [1230,1260,23,20,0], [1260,1290,42,4,0], [1290,1320,127,6,0], [1320,1380,45,15,0]]], [150, [[1200,1230,41,18,0], [1230,1260,178,0,0], [1260,1290,42,4,0], [1290,1320,127,6,0], [1320,1380,45,15,0]]], [180, [[1200,1230,41,18,0], [1230,1260,178,0,0], [1260,1290,42,4,0], [1290,1320,127,6,0], [1320,1380,45,15,0]]]], "CBS": [[90, [[1200,1260,169,0,0], [1260,1380,129,0,0]]], [96, [[1200,1260,179,0,0], [1260,1380,129,0,0]]], [130, [[1200,1260,179,0,0], [1260,1380,129,0,0]]], [150, [[1200,1260,180,0,0], [1260,1380,129,0,0]]], [180, [[1200,1260,180,0,0], [1260,1380,129,0,0]]]], "NBC": [[90, [[1200,1320,52,0,0], [1320,1380,169,0,0]]], [96, [[1200,1260,171,0,0], [1260,1320,181,0,0], [1320,1380,125,0,0]]], [130, [[1200,1260,171,0,0], [1260,1320,181,0,0], [1320,1380,125,0,0]]], [150, [[1200,1260,181,0,0], [1260,1320,125,0,0], [1320,1380,161,0,0]]], [150, [[1200,1260,181,0,0], [1260,1320,125,0,0], [1320,1380,182,0,0]]], [155, [[1200,1260,181,0,0], [1260,1320,125,0,0], [1320,1380,183,0,0]]], [180, [[1200,1260,181,0,0], [1260,1320,184,0,0], [1320,1380,125,0,0]]], [185, [[1200,1260,171,0,0], [1260,1320,181,0,0], [1320,1380,185,0,0]]]]},
        "WED": {"ABC": [[90, [[1200,1260,135,0,0], [1260,1320,118,0,0], [1320,1380,120,19,0]]], [96, [[1200,1260,135,0,0], [1260,1320,186,26,0], [1320,1380,120,19,0]]], [130, [[1200,1260,135,0,0], [1260,1320,186,26,0], [1320,1380,120,19,0]]], [150, [[1200,1260,135,0,0], [1260,1320,186,26,0], [1320,1380,120,19,0]]], [180, [[1200,1260,135,0,0], [1260,1320,186,26,0], [1320,1380,120,19,0]]]], "CBS": [[90, [[1200,1230,174,0,0], [1230,1260,32,0,0], [1260,1380,140,0,0]]], [96, [[1200,1230,174,0,0], [1230,1260,32,0,0], [1260,1320,146,0,0], [1320,1380,187,0,0]]], [130, [[1200,1230,32,0,0], [1230,1260,124,0,0], [1260,1380,140,0,0]]], [150, [[1200,1260,188,0,0], [1260,1290,32,0,0], [1290,1320,189,0,0], [1320,1380,187,0,0]]]], "NBC": [[96, [[1200,1260,64,21,0], [1260,1290,69,24,0], [1290,1320,190,0,0], [1320,1380,70,0,0]]], [130, [[1200,1260,64,21,0], [1260,1290,69,24,0], [1290,1320,190,0,0], [1320,1380,70,0,0]]], [150, [[1200,1260,64,21,0], [1260,1290,69,24,0], [1290,1320,191,0,0], [1320,1380,70,0,0]]], [180, [[1200,1260,64,21,0], [1260,1290,69,24,0], [1290,1320,191,0,0], [1320,1380,70,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1230,2,0,0], [1230,1260,173,0,0], [1260,1290,142,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]], [110, [[1200,1230,2,0,0], [1230,1260,173,0,0], [1260,1290,72,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]], [130, [[1200,1230,2,0,0], [1230,1260,173,0,0], [1260,1290,72,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]], [150, [[1200,1230,192,0,0], [1230,1260,142,0,0], [1260,1290,193,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]], [155, [[1200,1230,194,0,0], [1230,1260,2,0,0], [1260,1290,72,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]], [180, [[1200,1260,195,0,0], [1260,1290,72,0,0], [1290,1320,43,0,0], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,144,17,0], [1260,1320,146,0,0], [1320,1380,78,0,0]]], [110, [[1200,1260,144,17,0], [1260,1320,78,0,0], [1320,1380,196,0,0]]], [130, [[1200,1260,144,17,0], [1260,1320,78,0,0], [1320,1380,196,0,0]]], [150, [[1200,1260,144,17,0], [1260,1320,197,0,0], [1320,1380,78,0,0]]], [180, [[1200,1260,144,17,0], [1260,1320,197,0,0], [1320,1380,78,0,0]]]], "NBC": [[96, [[1200,1230,198,0,0], [1230,1260,199,0,0], [1260,1290,65,0,0], [1290,1320,200,0,0], [1320,1380,164,27,0]]], [130, [[1200,1260,201,0,0], [1260,1290,65,0,0], [1290,1320,200,0,0], [1320,1380,164,27,0]]], [150, [[1200,1260,201,0,0], [1260,1290,65,0,0], [1290,1320,200,0,0], [1320,1380,164,27,0]]], [180, [[1200,1260,201,0,0], [1260,1290,65,0,0], [1290,1320,200,0,0], [1320,1380,164,27,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,71,0,0], [1230,1260,142,0,0], [1260,1320,195,0,0], [1320,1380,202,0,0]]], [130, [[1200,1230,71,0,0], [1230,1260,72,0,0], [1260,1290,173,0,0], [1290,1320,203,0,0], [1320,1380,202,0,0]]], [150, [[1200,1230,71,0,0], [1230,1260,72,0,0], [1260,1320,204,0,0], [1320,1380,202,0,0]]], [155, [[1200,1230,71,0,0], [1230,1260,205,0,0], [1260,1380,88,0,0]]]], "CBS": [[96, [[1200,1260,90,0,0], [1260,1320,91,6,0], [1320,1380,92,1,0]]], [130, [[1200,1260,91,6,0], [1260,1320,92,1,0], [1320,1380,206,13,0]]], [150, [[1200,1260,91,6,0], [1260,1320,92,1,0], [1320,1380,206,13,0]]], [180, [[1200,1260,91,6,0], [1260,1320,92,1,0], [1320,1380,146,0,0]]]], "NBC": [[96, [[1200,1260,207,0,0], [1260,1320,185,0,0], [1320,1380,169,0,0]]], [130, [[1200,1260,207,0,0], [1260,1320,185,0,0], [1320,1380,184,0,0]]], [135, [[1200,1260,207,0,0], [1260,1380,95,0,0]]], [150, [[1200,1230,208,0,0], [1230,1320,209,0,0], [1320,1380,185,0,0]]], [180, [[1200,1230,199,0,0], [1230,1320,209,0,0], [1320,1380,184,0,0]]]]},
        "SAT": {"ABC": [[96, [[1200,1230,205,0,0], [1230,1260,203,0,0], [1260,1320,102,14,0], [1320,1380,87,30,0]]], [110, [[1200,1230,210,0,0], [1230,1260,203,0,0], [1260,1320,102,14,0], [1320,1380,87,30,0]]], [130, [[1200,1260,211,0,0], [1260,1320,102,14,0], [1320,1380,87,30,0]]], [150, [[1200,1260,212,28,0], [1260,1320,102,14,0], [1320,1380,87,30,0]]]], "CBS": [[0, [[1200,1260,213,0,0], [1260,1380,156,0,0]]]], "NBC": [[96, [[1200,1260,161,0,0], [1260,1320,214,0,0], [1320,1380,215,0,0]]], [101, [[1200,1260,161,0,0], [1260,1290,198,0,0], [1290,1320,199,0,0], [1320,1380,216,0,0]]], [130, [[1200,1230,217,0,0], [1230,1260,198,0,0], [1260,1320,161,0,0], [1320,1380,218,0,0]]], [135, [[1200,1230,217,0,0], [1230,1320,209,0,0], [1320,1380,185,0,0]]], [150, [[1200,1230,198,0,0], [1230,1260,217,0,0], [1260,1320,161,0,0], [1320,1380,207,0,0]]], [180, [[1200,1230,97,0,0], [1230,1260,198,0,0], [1260,1380,162,0,0]]]]},
    },
    1982: {
        "SUN": {"ABC": [[0, [[1140,1200,219,0,0], [1200,1260,220,0,0], [1260,1380,4,26,0]]]], "CBS": [[96, [[1140,1200,9,1,0], [1200,1230,10,22,0], [1230,1260,221,18,0], [1260,1290,13,12,0], [1290,1320,11,16,0], [1320,1380,14,18,0]]], [130, [[1140,1200,9,1,0], [1200,1230,10,22,0], [1230,1260,221,18,0], [1260,1290,13,12,0], [1290,1320,11,16,0], [1320,1380,14,18,0]]], [150, [[1140,1200,9,1,0], [1200,1230,222,0,0], [1230,1260,221,18,0], [1260,1290,13,12,0], [1290,1320,223,12,0], [1320,1380,14,18,0]]], [160, [[1140,1200,9,1,0], [1200,1230,222,0,0], [1230,1260,223,12,0], [1260,1290,13,12,0], [1290,1320,12,0,0], [1320,1380,14,18,0]]], [180, [[1140,1200,9,1,0], [1200,1230,12,0,1], [1230,1260,11,0,1], [1260,1290,13,12,0], [1290,1320,223,0,1], [1320,1380,14,18,0]]], [200, [[1140,1200,9,1,0], [1200,1230,12,0,1], [1230,1260,11,0,1], [1260,1290,13,12,0], [1290,1320,222,0,1], [1320,1380,14,18,0]]]], "NBC": [[96, [[1140,1200,224,0,0], [1200,1260,18,0,0], [1260,1380,225,0,0]]], [130, [[1140,1200,224,0,0], [1200,1260,18,0,0], [1260,1380,225,0,0]]], [150, [[1140,1200,226,0,0], [1200,1260,18,0,0], [1260,1380,225,0,0]]], [180, [[1140,1200,224,0,0], [1200,1260,18,0,0], [1260,1380,225,0,0]]], [200, [[1140,1200,227,0,1], [1200,1260,228,0,1], [1260,1380,225,0,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,27,22,0], [1260,1380,20,10,0]]], [130, [[1200,1260,27,22,0], [1260,1380,22,24,0]]], [150, [[1200,1260,27,22,0], [1260,1380,22,24,0]]], [180, [[1200,1380,29,0,0]]]], "CBS": [[96, [[1200,1230,229,0,0], [1230,1260,123,0,0], [1260,1290,31,3,0], [1290,1320,223,12,0], [1320,1380,197,0,0]]], [130, [[1200,1230,229,0,0], [1230,1260,177,0,0], [1260,1290,31,3,0], [1290,1320,223,12,0], [1320,1380,197,0,0]]], [145, [[1200,1230,229,0,0], [1230,1260,230,0,0], [1260,1290,12,0,0], [1290,1320,11,16,0], [1320,1380,197,0,0]]], [150, [[1200,1230,10,22,0], [1230,1260,231,0,0], [1260,1290,12,0,0], [1290,1320,11,16,0], [1320,1380,197,0,0]]], [160, [[1200,1230,10,22,0], [1230,1260,231,0,0], [1260,1290,31,0,1], [1290,1320,11,16,0], [1320,1380,197,0,0]]], [180, [[1200,1230,229,0,1], [1230,1260,123,0,1], [1260,1290,31,0,1], [1290,1320,10,0,1], [1320,1380,197,0,0]]], [190, [[1200,1230,229,0,1], [1230,1260,123,0,1], [1260,1320,232,0,1], [1320,1380,197,0,0]]], [200, [[1200,1230,229,0,1], [1230,1260,123,0,1], [1260,1290,31,0,1], [1290,1320,223,0,1], [1320,1380,197,0,0]]]], "NBC": [[96, [[1200,1260,233,28,0], [1260,1380,40,0,0]]], [130, [[1200,1260,233,28,0], [1260,1380,40,0,0]]], [150, [[1200,1230,190,0,0], [1230,1260,234,0,0], [1260,1380,40,0,0]]], [180, [[1200,1230,190,0,0], [1230,1260,234,0,0], [1260,1380,40,0,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,41,28,0], [1230,1260,23,25,0], [1260,1290,42,6,0], [1290,1320,193,15,0], [1320,1380,45,17,0]]], [130, [[1200,1230,41,28,0], [1230,1260,23,25,0], [1260,1290,42,6,0], [1290,1320,193,15,0], [1320,1380,45,17,0]]], [150, [[1200,1230,41,28,0], [1230,1260,23,25,0], [1260,1290,42,6,0], [1290,1320,193,15,0], [1320,1380,45,17,0]]], [160, [[1200,1230,41,28,0], [1230,1260,178,0,0], [1260,1290,42,6,0], [1290,1320,193,15,0], [1320,1380,45,17,0]]], [180, [[1200,1230,41,28,0], [1230,1260,178,0,0], [1260,1290,42,6,0], [1290,1320,193,15,0], [1320,1380,45,17,0]]], [190, [[1200,1230,235,0,0], [1230,1260,178,0,0], [1260,1290,42,6,0], [1290,1320,193,15,0], [1320,1380,45,17,0]]], [200, [[1200,1230,41,0,1], [1230,1260,178,0,0], [1260,1290,42,6,0], [1290,1320,193,15,0], [1320,1380,45,17,0]]]], "CBS": [[96, [[1200,1260,236,0,0], [1260,1380,129,27,0]]], [130, [[1200,1260,213,0,0], [1260,1380,129,27,0]]], [150, [[1200,1230,237,0,0], [1230,1260,238,0,0], [1260,1380,129,27,0]]], [160, [[1200,1260,96,0,0], [1260,1380,129,27,0]]], [170, [[1200,1260,236,0,0], [1260,1380,129,27,0]]], [180, [[1200,1230,239,0,0], [1230,1260,240,0,0], [1260,1380,129,27,0]]]], "NBC": [[96, [[1200,1260,171,0,0], [1260,1320,241,0,0], [1320,1380,242,0,0]]], [130, [[1200,1260,243,10,0], [1260,1320,244,0,0], [1320,1380,242,0,0]]], [150, [[1200,1260,243,10,0], [1260,1320,245,0,0], [1320,1380,242,0,0]]], [180, [[1200,1260,243,10,0], [1260,1320,245,0,0], [1320,1380,242,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1260,246,0,0], [1260,1320,186,14,0], [1320,1380,120,5,0]]], [130, [[1200,1260,246,0,0], [1260,1320,186,14,0], [1320,1380,120,5,0]]], [145, [[1200,1260,247,0,0], [1260,1320,186,14,0], [1320,1380,120,5,0]]], [150, [[1200,1260,186,14,0], [1260,1320,248,0,0], [1320,1380,120,5,0]]], [160, [[1200,1260,186,14,0], [1260,1380,249,0,0]]], [180, [[1200,1260,186,14,0], [1260,1320,246,0,0], [1320,1380,120,0,1]]], [190, [[1200,1260,186,14,0], [1260,1320,250,0,0], [1320,1380,120,0,1]]], [200, [[1200,1260,186,14,0], [1260,1320,251,0,0], [1320,1380,120,0,1]]]], "CBS": [[96, [[1200,1260,252,0,0], [1260,1290,12,0,0], [1290,1320,177,0,0], [1320,1380,232,0,0]]], [110, [[1200,1260,252,0,0], [1260,1380,60,0,0]]], [130, [[1200,1260,252,0,0], [1260,1380,60,0,0]]], [150, [[1200,1230,253,0,0], [1230,1260,229,0,1], [1260,1380,60,0,0]]], [180, [[1200,1230,230,0,0], [1230,1260,177,0,0], [1260,1380,60,0,0]]], [190, [[1200,1230,10,0,1], [1230,1260,221,0,1], [1260,1380,60,0,0]]]], "NBC": [[96, [[1200,1260,64,30,0], [1260,1290,69,0,0], [1290,1320,234,0,0], [1320,1380,70,0,0]]], [130, [[1200,1260,64,30,0], [1260,1290,69,0,0], [1290,1320,234,0,0], [1320,1380,70,0,0]]], [150, [[1200,1260,64,30,0], [1260,1290,69,0,0], [1290,1320,43,0,0], [1320,1380,70,0,0]]], [180, [[1200,1260,64,30,0], [1260,1290,69,0,0], [1290,1320,254,0,0], [1320,1380,70,0,0]]], [180, [[1200,1260,64,30,0], [1260,1290,69,0,0], [1290,1320,254,0,0], [1320,1350,255,0,0], [1350,1380,43,0,0]]], [190, [[1200,1260,64,30,0], [1260,1290,69,0,0], [1290,1320,254,0,0], [1320,1380,256,0,1]]], [200, [[1200,1260,64,30,0], [1260,1290,69,0,0], [1290,1320,234,0,1], [1320,1380,242,0,1]]]]},
        "THU": {"ABC": [[96, [[1200,1230,178,0,0], [1230,1260,257,0,0], [1260,1290,127,0,0], [1290,1320,258,0,0], [1320,1380,58,0,0]]], [130, [[1200,1260,135,0,0], [1260,1290,127,0,0], [1290,1320,258,0,0], [1320,1380,58,0,0]]], [140, [[1200,1230,259,0,0], [1230,1260,260,0,0], [1260,1290,127,0,0], [1290,1320,258,0,0], [1320,1380,58,0,0]]], [150, [[1200,1230,71,0,0], [1230,1260,259,0,0], [1260,1290,127,0,0], [1290,1320,258,0,0], [1320,1380,58,0,0]]], [160, [[1200,1260,96,0,0], [1260,1290,127,0,0], [1290,1320,260,0,0], [1320,1380,58,0,0]]], [180, [[1200,1230,259,0,0], [1230,1260,261,0,0], [1260,1290,127,0,0], [1290,1320,258,0,1], [1320,1380,58,0,0]]], [190, [[1200,1320,262,0,0], [1320,1380,58,0,0]]], [200, [[1200,1230,263,0,0], [1230,1260,127,0,1], [1260,1290,264,0,0], [1290,1320,258,0,1], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,144,3,0], [1260,1320,179,7,0], [1320,1380,78,20,0]]], [130, [[1200,1260,144,3,0], [1260,1320,179,7,0], [1320,1380,78,20,0]]], [150, [[1200,1260,144,3,0], [1260,1320,179,7,0], [1320,1380,232,0,0]]], [180, [[1200,1260,144,3,0], [1260,1320,179,7,0], [1320,1380,78,0,1]]]], "NBC": [[96, [[1200,1260,201,0,0], [1260,1290,265,0,0], [1290,1320,43,0,0], [1320,1380,164,21,0]]], [130, [[1200,1260,201,0,0], [1260,1290,200,0,0], [1290,1320,265,0,0], [1320,1380,164,21,0]]], [150, [[1200,1260,201,0,0], [1260,1290,200,0,0], [1290,1320,265,0,0], [1320,1380,164,21,0]]], [180, [[1200,1260,201,0,0], [1260,1290,200,0,0], [1290,1320,265,0,0], [1320,1380,164,21,0]]], [200, [[1200,1230,200,0,1], [1230,1260,266,0,1], [1260,1290,21,0,0], [1290,1320,265,0,0], [1320,1380,164,21,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,71,0,0], [1230,1260,261,0,0], [1260,1320,135,0,0], [1320,1380,267,0,0]]], [110, [[1200,1230,71,0,0], [1230,1260,261,0,0], [1260,1380,268,0,0]]], [130, [[1200,1230,71,0,0], [1230,1260,261,0,0], [1260,1380,268,0,0]]], [145, [[1200,1230,71,0,0], [1230,1260,269,0,0], [1260,1320,270,0,0], [1320,1380,246,0,0]]], [150, [[1200,1230,271,0,0], [1230,1260,269,0,0], [1260,1320,270,0,0], [1320,1380,246,0,0]]], [160, [[1200,1230,261,0,0], [1230,1260,269,0,0], [1260,1380,268,0,0]]], [180, [[1200,1230,71,0,1], [1230,1260,269,0,0], [1260,1380,268,0,0]]]], "CBS": [[96, [[1200,1260,91,30,0], [1260,1320,92,2,0], [1320,1380,206,8,0]]], [130, [[1200,1260,91,30,0], [1260,1320,92,2,0], [1320,1380,206,8,0]]], [150, [[1200,1260,91,30,0], [1260,1320,92,2,0], [1320,1380,272,0,0]]], [180, [[1200,1260,91,30,0], [1260,1320,92,2,0], [1320,1380,206,0,1]]]], "NBC": [[96, [[1200,1260,227,0,0], [1260,1320,228,0,0], [1320,1380,245,0,0]]], [130, [[1200,1260,227,0,0], [1260,1320,228,0,0], [1320,1380,245,0,0]]], [150, [[1200,1260,227,0,0], [1260,1320,228,0,0], [1320,1380,244,0,0]]], [180, [[1200,1260,227,0,0], [1260,1320,228,0,0], [1320,1380,94,0,1]]]]},
        "SAT": {"ABC": [[0, [[1200,1260,273,0,0], [1260,1320,102,9,0], [1320,1380,87,0,0]]]], "CBS": [[96, [[1200,1260,213,0,0], [1260,1380,274,0,0]]], [130, [[1200,1260,213,0,0], [1260,1380,274,0,0]]], [150, [[1200,1260,275,0,0], [1260,1380,274,0,0]]], [180, [[1200,1260,275,0,0], [1260,1380,274,0,0]]]], "NBC": [[96, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1290,200,0,0], [1290,1320,190,0,0], [1320,1380,277,0,0]]], [130, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1290,266,0,0], [1290,1320,43,0,0], [1320,1380,256,0,0]]], [150, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1290,266,0,0], [1290,1320,191,0,0], [1320,1380,278,0,0]]], [180, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1320,70,0,1], [1320,1380,278,0,0]]], [200, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1320,70,0,1], [1320,1380,226,0,0]]]]},
    },
    1983: {
        "SUN": {"ABC": [[0, [[1140,1200,219,0,0], [1200,1260,279,30,0], [1260,1380,4,12,0]]]], "CBS": [[96, [[1140,1200,9,2,0], [1200,1230,12,28,0], [1230,1260,11,0,0], [1260,1290,13,19,0], [1290,1320,222,0,0], [1320,1380,14,0,0]]], [130, [[1140,1200,9,2,0], [1200,1230,280,24,0], [1230,1260,11,0,0], [1260,1290,13,19,0], [1290,1320,12,28,0], [1320,1380,14,0,0]]], [145, [[1140,1200,9,2,0], [1200,1230,281,0,0], [1230,1260,280,24,0], [1260,1290,13,19,0], [1290,1320,12,28,0], [1320,1380,14,0,0]]], [150, [[1140,1200,9,2,0], [1200,1230,281,0,0], [1230,1260,282,0,0], [1260,1290,13,19,0], [1290,1320,12,28,0], [1320,1380,14,0,0]]], [160, [[1140,1200,9,2,0], [1200,1230,283,15,0], [1230,1260,280,24,0], [1260,1290,13,19,0], [1290,1320,12,28,0], [1320,1380,14,0,0]]], [180, [[1140,1200,9,2,0], [1200,1230,283,15,0], [1230,1260,280,24,0], [1260,1290,13,19,0], [1290,1320,12,28,0], [1320,1380,14,0,0]]], [190, [[1140,1200,9,2,0], [1200,1230,222,0,1], [1230,1260,280,24,0], [1260,1290,13,19,0], [1290,1320,12,28,0], [1320,1380,14,0,0]]], [200, [[1140,1200,9,2,0], [1200,1230,11,0,1], [1230,1260,222,0,1], [1260,1290,13,19,0], [1290,1320,12,28,0], [1320,1380,14,0,0]]]], "NBC": [[96, [[1140,1200,284,0,0], [1200,1260,228,29,0], [1260,1380,225,0,0]]], [130, [[1140,1200,284,0,0], [1200,1260,228,29,0], [1260,1380,225,0,0]]], [150, [[1140,1200,284,0,0], [1200,1260,228,29,0], [1260,1380,225,0,0]]], [160, [[1140,1200,171,0,1], [1200,1260,228,29,0], [1260,1380,225,0,0]]], [180, [[1140,1200,171,0,1], [1200,1260,228,29,0], [1260,1380,225,0,0]]], [190, [[1140,1200,285,0,0], [1200,1260,228,29,0], [1260,1380,225,0,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,27,0,0], [1260,1380,20,21,0]]], [130, [[1200,1260,27,0,0], [1260,1380,22,13,0]]], [150, [[1200,1260,286,0,0], [1260,1380,22,13,0]]], [160, [[1200,1260,96,0,0], [1260,1380,22,13,0]]], [180, [[1200,1260,96,0,0], [1260,1380,22,13,0]]], [200, [[1200,1260,287,0,0], [1260,1380,22,13,0]]]], "CBS": [[96, [[1200,1260,288,20,0], [1260,1290,283,15,0], [1290,1320,223,23,0], [1320,1380,289,0,0]]], [130, [[1200,1260,288,20,0], [1260,1290,283,15,0], [1290,1320,223,23,0], [1320,1380,289,0,0]]], [150, [[1200,1260,288,20,0], [1260,1290,290,8,0], [1290,1320,223,23,0], [1320,1380,197,10,0]]], [160, [[1200,1260,288,20,0], [1260,1290,11,0,0], [1290,1320,223,23,0], [1320,1380,197,10,0]]], [180, [[1200,1260,288,20,0], [1260,1290,11,0,0], [1290,1320,223,23,0], [1320,1380,197,10,0]]], [200, [[1200,1260,288,20,0], [1260,1290,290,0,1], [1290,1320,223,23,0], [1320,1380,197,10,0]]]], "NBC": [[96, [[1200,1260,291,0,0], [1260,1380,40,22,0]]], [130, [[1200,1260,292,14,0], [1260,1380,40,22,0]]], [150, [[1200,1260,292,14,0], [1260,1380,40,22,0]]], [180, [[1200,1260,292,14,0], [1260,1380,40,22,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,293,0,0], [1230,1260,41,0,0], [1260,1290,42,0,0], [1290,1320,294,0,0], [1320,1380,45,0,0]]], [130, [[1200,1230,295,0,0], [1230,1260,41,0,0], [1260,1290,42,0,0], [1290,1320,294,0,0], [1320,1380,45,0,0]]], [145, [[1200,1230,295,0,0], [1230,1260,296,0,0], [1260,1290,42,0,0], [1290,1320,294,0,0], [1320,1380,45,0,0]]], [150, [[1200,1230,295,0,0], [1230,1260,296,0,0], [1260,1290,42,0,0], [1290,1320,297,0,0], [1320,1380,45,0,0]]], [160, [[1200,1230,295,0,0], [1230,1260,41,0,0], [1260,1290,42,0,0], [1290,1320,294,0,1], [1320,1380,45,0,0]]], [180, [[1200,1230,295,0,0], [1230,1260,42,0,1], [1260,1320,298,0,1], [1320,1380,45,0,0]]], [200, [[1200,1230,295,0,0], [1230,1260,42,0,1], [1260,1380,299,0,0]]]], "CBS": [[96, [[1200,1260,272,0,0], [1260,1380,48,26,0]]], [130, [[1200,1260,272,0,0], [1260,1380,48,26,0]]], [150, [[1200,1260,300,0,0], [1260,1380,48,26,0]]], [180, [[1200,1230,283,0,1], [1230,1260,282,0,1], [1260,1380,48,26,0]]]], "NBC": [[96, [[1200,1260,243,4,0], [1260,1320,245,0,0], [1320,1380,301,0,0]]], [115, [[1200,1260,243,4,0], [1260,1320,245,0,0], [1320,1380,302,0,0]]], [130, [[1200,1260,243,4,0], [1260,1320,303,18,0], [1320,1380,245,0,0]]], [150, [[1200,1260,243,4,0], [1260,1320,303,18,0], [1320,1380,245,0,0]]], [180, [[1200,1260,243,4,0], [1260,1320,303,18,0], [1320,1380,245,0,0]]]]},
        "WED": {"ABC": [[90, [[1200,1260,186,16,0], [1260,1320,251,0,0], [1320,1380,298,9,0]]], [96, [[1200,1260,186,16,0], [1260,1320,120,3,0], [1320,1380,298,9,0]]], [130, [[1200,1260,186,16,0], [1260,1320,120,3,0], [1320,1380,298,9,0]]], [150, [[1200,1260,186,16,0], [1260,1320,120,3,0], [1320,1380,298,9,0]]], [180, [[1200,1260,186,16,0], [1260,1380,249,0,0]]], [200, [[1200,1260,186,16,0], [1260,1320,120,0,1], [1320,1380,298,0,1]]]], "CBS": [[96, [[1200,1260,304,0,0], [1260,1380,60,0,0]]], [130, [[1200,1230,282,0,0], [1230,1260,305,0,0], [1260,1380,60,0,0]]], [150, [[1200,1230,11,0,0], [1230,1260,306,0,0], [1260,1380,60,0,0]]], [180, [[1200,1260,300,0,0], [1260,1380,60,0,0]]]], "NBC": [[96, [[1200,1260,64,0,0], [1260,1290,69,25,0], [1290,1320,234,0,0], [1320,1380,242,0,0]]], [130, [[1200,1260,64,0,0], [1260,1290,69,25,0], [1290,1320,307,0,0], [1320,1380,242,0,0]]], [150, [[1200,1260,64,0,0], [1260,1290,69,25,0], [1290,1320,308,0,0], [1320,1380,242,0,0]]], [180, [[1200,1260,64,0,0], [1260,1290,69,25,0], [1290,1320,309,0,0], [1320,1380,242,0,0]]], [190, [[1200,1230,308,0,1], [1230,1260,310,0,1], [1260,1290,69,25,0], [1290,1320,309,0,0], [1320,1380,242,0,0]]], [200, [[1200,1230,308,0,1], [1230,1260,310,0,1], [1260,1290,69,25,0], [1290,1320,311,0,0], [1320,1380,242,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1260,312,0,0], [1260,1290,193,0,0], [1290,1320,313,0,0], [1320,1380,58,0,0]]], [130, [[1200,1260,286,0,0], [1260,1320,314,0,0], [1320,1380,58,0,0]]], [150, [[1200,1260,251,0,0], [1260,1320,315,0,0], [1320,1380,58,0,0]]], [160, [[1200,1260,27,0,0], [1260,1320,251,0,0], [1320,1380,58,0,0]]], [180, [[1200,1230,41,0,0], [1230,1260,311,0,0], [1260,1320,315,0,0], [1320,1380,58,0,0]]], [200, [[1200,1260,58,0,0], [1260,1380,21,0,0]]]], "CBS": [[0, [[1200,1260,144,6,0], [1260,1320,179,5,0], [1320,1380,78,11,0]]]], "NBC": [[96, [[1200,1230,200,0,0], [1230,1260,266,0,0], [1260,1290,316,0,0], [1290,1320,265,0,0], [1320,1380,164,0,0]]], [115, [[1200,1230,200,0,0], [1230,1260,266,0,0], [1260,1290,265,0,0], [1290,1320,254,0,0], [1320,1380,164,0,0]]], [130, [[1200,1230,200,0,0], [1230,1260,234,0,0], [1260,1290,265,0,0], [1290,1320,254,0,0], [1320,1380,164,0,0]]], [150, [[1200,1230,200,0,0], [1230,1260,234,0,0], [1260,1290,265,0,0], [1290,1320,309,0,0], [1320,1380,164,0,0]]], [180, [[1200,1230,200,0,0], [1230,1260,234,0,0], [1260,1290,265,0,0], [1290,1320,307,0,0], [1320,1380,164,0,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,71,0,0], [1230,1260,317,27,0], [1260,1320,315,0,0], [1320,1380,220,0,0]]], [130, [[1200,1230,71,0,0], [1230,1260,317,27,0], [1260,1320,318,0,0], [1320,1380,220,0,0]]], [150, [[1200,1230,71,0,0], [1230,1260,317,27,0], [1260,1320,314,0,0], [1320,1380,220,0,0]]], [160, [[1200,1230,71,0,0], [1230,1260,317,27,0], [1260,1320,318,0,0], [1320,1380,220,0,0]]], [180, [[1200,1230,71,0,0], [1230,1260,317,27,0], [1260,1320,318,0,0], [1320,1380,220,0,0]]]], "CBS": [[0, [[1200,1260,91,0,0], [1260,1320,92,1,0], [1320,1380,206,7,0]]]], "NBC": [[96, [[1200,1230,319,0,0], [1230,1260,310,0,0], [1260,1320,320,0,0], [1320,1380,302,0,0]]], [115, [[1200,1230,319,0,0], [1230,1260,310,0,0], [1260,1380,95,0,0]]], [130, [[1200,1260,321,0,0], [1260,1320,322,0,0], [1320,1380,323,0,0]]], [145, [[1200,1260,322,0,0], [1260,1320,321,0,0], [1320,1380,323,0,0]]], [150, [[1200,1260,322,0,0], [1260,1380,95,0,0]]], [180, [[1200,1260,322,0,0], [1260,1380,95,0,0]]]]},
        "SAT": {"ABC": [[0, [[1200,1260,273,0,0], [1260,1320,102,17,0], [1320,1380,87,0,0]]]], "CBS": [[96, [[1200,1260,324,0,0], [1260,1380,274,0,0]]], [130, [[1200,1260,304,0,0], [1260,1320,325,0,0], [1320,1380,326,0,0]]], [150, [[1200,1260,304,0,0], [1260,1320,325,0,0], [1320,1380,326,0,0]]], [180, [[1200,1230,306,0,0], [1230,1380,274,0,0]]], [200, [[1200,1260,325,0,1], [1260,1380,21,0,0]]]], "NBC": [[96, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1320,327,0,0], [1320,1380,328,0,0]]], [115, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1320,320,0,0], [1320,1380,328,0,0]]], [130, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1290,316,0,0], [1290,1320,266,0,0], [1320,1380,328,0,0]]], [150, [[1200,1230,65,0,0], [1230,1260,276,0,0], [1260,1290,329,0,0], [1290,1320,266,0,0], [1320,1380,328,0,0]]], [160, [[1200,1230,65,0,0], [1230,1260,310,0,0], [1260,1290,329,0,0], [1290,1320,266,0,0], [1320,1380,328,0,0]]], [180, [[1200,1230,65,0,0], [1230,1260,276,0,1], [1260,1290,266,0,1], [1290,1320,329,0,0], [1320,1380,327,0,0]]], [190, [[1200,1230,65,0,0], [1230,1260,276,0,1], [1260,1290,142,0,1], [1290,1320,266,0,1], [1320,1380,291,0,0]]], [200, [[1200,1230,65,0,0], [1230,1260,276,0,1], [1260,1290,142,0,1], [1290,1320,266,0,1], [1320,1380,321,0,0]]]]},
    },
    1984: {
        "SUN": {"ABC": [[96, [[1140,1200,219,0,0], [1200,1260,279,0,0], [1260,1380,4,21,0]]], [115, [[1140,1200,219,0,0], [1200,1380,4,21,0]]]], "CBS": [[96, [[1140,1200,9,4,0], [1200,1260,330,8,0], [1260,1290,13,0,0], [1290,1320,12,0,0], [1320,1380,14,29,0]]], [130, [[1140,1200,9,4,0], [1200,1260,330,8,0], [1260,1320,331,10,0], [1320,1380,14,29,0]]]], "NBC": [[96, [[1140,1170,276,0,0], [1170,1200,332,0,0], [1200,1260,228,0,0], [1260,1380,225,0,0]]], [130, [[1140,1170,332,0,0], [1170,1200,276,0,0], [1200,1260,228,0,0], [1260,1380,225,0,0]]], [180, [[1140,1170,332,0,0], [1170,1260,21,0,0], [1260,1380,225,0,0]]], [200, [[1140,1170,332,0,0], [1170,1200,21,0,0], [1200,1260,333,0,0], [1260,1380,225,0,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,287,0,0], [1260,1380,20,25,0]]], [115, [[1200,1260,279,0,0], [1260,1380,20,25,0]]], [130, [[1200,1260,279,0,0], [1260,1380,22,0,0]]], [180, [[1200,1380,29,0,0]]], [200, [[1200,1260,279,0,1], [1260,1380,22,0,0]]]], "CBS": [[0, [[1200,1260,288,22,0], [1260,1290,290,17,0], [1290,1320,223,16,0], [1320,1380,197,26,0]]]], "NBC": [[0, [[1200,1260,292,22,0], [1260,1380,40,18,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,295,0,0], [1230,1260,334,0,0], [1260,1320,335,0,0], [1320,1380,336,0,0]]], [110, [[1200,1230,334,0,0], [1230,1260,337,0,0], [1260,1320,335,0,0], [1320,1380,336,0,0]]], [115, [[1200,1230,334,0,0], [1230,1260,337,0,0], [1260,1320,338,0,0], [1320,1380,335,0,0]]], [130, [[1200,1230,334,0,0], [1230,1260,337,0,0], [1260,1320,339,0,0], [1320,1380,287,0,0]]], [145, [[1200,1230,334,0,0], [1230,1260,337,0,0], [1260,1320,339,0,0], [1320,1380,340,0,0]]], [150, [[1200,1230,334,0,0], [1230,1260,295,0,0], [1260,1290,337,0,0], [1290,1320,341,0,0], [1320,1380,339,0,0]]], [180, [[1200,1230,337,0,1], [1230,1260,334,0,1], [1260,1320,340,0,1], [1320,1380,339,0,0]]]], "CBS": [[96, [[1200,1230,283,0,0], [1230,1260,342,0,0], [1260,1380,48,0,0]]], [110, [[1200,1260,96,0,0], [1260,1380,48,0,0]]], [130, [[1200,1230,13,0,0], [1230,1260,12,0,0], [1260,1380,48,0,0]]], [150, [[1200,1230,343,0,0], [1230,1260,13,0,0], [1260,1380,48,0,0]]], [160, [[1200,1260,96,0,0], [1260,1380,48,0,0]]], [180, [[1200,1230,343,0,0], [1230,1260,13,0,0], [1260,1380,48,0,0]]], [190, [[1200,1230,13,0,1], [1230,1260,12,0,1], [1260,1380,48,0,0]]], [200, [[1200,1320,48,0,0], [1320,1380,344,0,0]]]], "NBC": [[0, [[1200,1260,243,6,0], [1260,1320,303,14,0], [1320,1380,245,25,0]]]]},
        "WED": {"ABC": [[96, [[1200,1260,186,22,0], [1260,1320,120,1,0], [1320,1380,298,12,0]]], [180, [[1200,1260,345,0,0], [1260,1320,120,1,0], [1320,1380,298,12,0]]]], "CBS": [[96, [[1200,1230,346,0,0], [1230,1260,347,0,0], [1260,1380,60,0,0]]], [110, [[1200,1230,346,0,0], [1230,1260,342,0,0], [1260,1380,60,0,0]]], [150, [[1200,1260,348,0,0], [1260,1380,60,0,0]]], [180, [[1200,1230,346,0,1], [1230,1260,342,0,1], [1260,1380,60,0,0]]], [190, [[1200,1260,349,0,0], [1260,1380,60,0,0]]]], "NBC": [[96, [[1200,1260,350,18,0], [1260,1290,69,0,0], [1290,1320,351,0,0], [1320,1380,242,0,0]]], [140, [[1200,1260,350,18,0], [1260,1290,69,0,0], [1290,1320,352,0,0], [1320,1380,242,0,0]]], [180, [[1200,1260,350,18,0], [1260,1290,69,0,0], [1290,1320,308,0,1], [1320,1380,242,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1230,353,0,0], [1230,1260,337,0,0], [1260,1320,338,0,0], [1320,1380,58,0,0]]], [110, [[1200,1320,262,0,0], [1320,1380,58,0,0]]], [150, [[1200,1260,354,0,0], [1260,1320,355,0,0], [1320,1380,58,0,0]]], [160, [[1200,1260,356,0,0], [1260,1320,21,0,0], [1320,1380,58,0,0]]], [180, [[1200,1320,262,0,0], [1320,1380,58,0,0]]]], "CBS": [[0, [[1200,1260,144,15,0], [1260,1320,179,7,0], [1320,1380,78,9,0]]]], "NBC": [[0, [[1200,1230,357,3,0], [1230,1260,234,5,0], [1260,1290,265,12,0], [1290,1320,307,20,0], [1320,1380,164,30,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,71,0,0], [1230,1260,317,25,0], [1260,1320,358,0,0], [1320,1380,220,0,0]]], [130, [[1200,1230,71,0,0], [1230,1260,317,25,0], [1260,1320,356,0,0], [1320,1380,220,0,0]]], [145, [[1200,1230,317,25,0], [1230,1260,359,0,0], [1260,1290,71,0,0], [1290,1320,360,0,0], [1320,1380,220,0,0]]], [150, [[1200,1230,317,25,0], [1230,1260,359,0,0], [1260,1290,71,0,0], [1290,1320,360,0,0], [1320,1380,361,0,0]]], [180, [[1200,1230,317,25,0], [1230,1260,362,0,0], [1260,1290,71,0,0], [1290,1320,353,0,0], [1320,1380,220,0,0]]], [190, [[1200,1230,317,25,0], [1230,1260,359,0,1], [1260,1290,71,0,0], [1290,1320,360,0,1], [1320,1380,21,0,0]]]], "CBS": [[96, [[1200,1260,91,0,0], [1260,1320,92,2,0], [1320,1380,206,10,0]]], [150, [[1200,1260,363,0,0], [1260,1320,92,2,0], [1320,1380,206,10,0]]], [170, [[1200,1260,91,0,1], [1260,1320,92,2,0], [1320,1380,206,10,0]]], [180, [[1200,1260,91,0,1], [1260,1320,92,2,0], [1320,1380,206,10,0]]]], "NBC": [[96, [[1200,1260,364,0,0], [1260,1320,365,0,0], [1320,1380,366,0,0]]], [115, [[1200,1260,364,0,0], [1260,1320,366,0,0], [1320,1380,367,0,0]]], [130, [[1200,1260,364,0,0], [1260,1320,365,0,0], [1320,1380,366,0,0]]], [140, [[1200,1260,368,0,0], [1260,1320,364,0,0], [1320,1380,366,0,0]]], [150, [[1200,1260,369,0,0], [1260,1320,370,0,0], [1320,1380,366,0,0]]], [180, [[1200,1230,371,0,0], [1230,1260,372,0,1], [1260,1320,364,0,1], [1320,1380,366,0,0]]], [190, [[1200,1320,95,0,0], [1320,1380,366,0,0]]], [200, [[1200,1260,228,0,1], [1260,1320,373,0,0], [1320,1380,366,0,0]]]]},
        "SAT": {"ABC": [[0, [[1200,1260,273,0,0], [1260,1320,102,0,0], [1320,1380,374,0,0]]]], "CBS": [[96, [[1200,1260,325,0,0], [1260,1320,326,0,0], [1320,1380,375,0,0]]], [130, [[1200,1260,376,0,0], [1260,1320,325,0,0], [1320,1380,375,0,0]]], [150, [[1200,1230,346,0,0], [1230,1260,342,0,1], [1260,1320,325,0,0], [1320,1380,375,0,0]]], [160, [[1200,1260,375,0,0], [1260,1320,325,0,0], [1320,1380,326,0,1]]], [190, [[1200,1260,325,0,1], [1260,1380,105,0,0]]]], "NBC": [[96, [[1200,1230,65,0,0], [1230,1260,200,0,0], [1260,1320,377,0,0], [1320,1380,367,0,0]]], [110, [[1200,1230,65,0,0], [1230,1260,308,0,0], [1260,1290,200,0,0], [1290,1320,378,0,0], [1320,1380,377,0,0]]], [130, [[1200,1230,65,0,0], [1230,1260,308,0,0], [1260,1290,200,0,0], [1290,1320,351,0,0], [1320,1380,379,0,0]]], [150, [[1200,1230,65,0,0], [1230,1260,308,0,0], [1260,1290,200,0,0], [1290,1320,372,0,0], [1320,1380,365,0,0]]], [180, [[1200,1230,65,0,0], [1230,1260,351,0,1], [1260,1290,200,0,0], [1290,1320,266,0,1], [1320,1380,21,0,0]]], [190, [[1200,1230,380,0,0], [1230,1260,351,0,1], [1260,1290,200,0,0], [1290,1320,266,0,1], [1320,1380,21,0,0]]], [200, [[1200,1230,65,0,1], [1230,1260,380,0,0], [1260,1290,200,0,0], [1290,1380,21,0,0]]]]},
    },
    1985: {
        "SUN": {"ABC": [[96, [[1140,1200,219,0,0], [1200,1260,381,0,0], [1260,1380,4,0,0]]], [130, [[1140,1260,382,0,0], [1260,1380,4,0,0]]]], "CBS": [[96, [[1140,1200,9,4,0], [1200,1260,330,3,0], [1260,1320,331,0,0], [1320,1380,14,0,0]]], [130, [[1140,1200,9,4,0], [1200,1260,330,3,0], [1260,1380,383,12,0]]]], "NBC": [[96, [[1140,1170,332,0,0], [1170,1200,276,0,0], [1200,1230,384,0,0], [1230,1260,385,0,0], [1260,1380,225,21,0]]], [150, [[1140,1170,276,0,0], [1170,1200,386,0,0], [1200,1230,384,0,0], [1230,1260,385,0,0], [1260,1380,225,21,0]]], [170, [[1140,1170,276,0,0], [1170,1200,332,0,0], [1200,1380,21,0,0]]], [200, [[1140,1170,276,0,0], [1170,1200,332,0,0], [1200,1260,387,0,0], [1260,1380,225,21,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,279,0,0], [1260,1380,20,15,0]]], [130, [[1200,1260,279,0,0], [1260,1380,172,0,0]]], [180, [[1200,1260,388,0,0], [1260,1380,172,0,0]]], [190, [[1200,1380,29,0,0]]]], "CBS": [[0, [[1200,1260,288,28,0], [1260,1290,290,14,0], [1290,1320,223,16,0], [1320,1380,197,0,0]]]], "NBC": [[96, [[1200,1260,292,0,0], [1260,1380,40,22,0]]], [130, [[1200,1230,389,19,0], [1230,1260,390,24,0], [1260,1380,40,22,0]]], [150, [[1200,1230,390,24,0], [1230,1260,389,19,0], [1260,1380,40,22,0]]], [170, [[1200,1230,390,24,0], [1230,1260,384,0,0], [1260,1380,40,22,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,337,10,0], [1230,1260,391,17,0], [1260,1320,340,24,0], [1320,1380,392,0,0]]], [110, [[1200,1230,337,10,0], [1230,1260,391,17,0], [1260,1320,340,24,0], [1320,1380,393,0,0]]], [150, [[1200,1230,337,10,0], [1230,1260,394,0,0], [1260,1320,340,24,0], [1320,1380,393,0,0]]], [160, [[1200,1230,337,10,0], [1230,1260,391,17,0], [1260,1320,340,24,0], [1320,1380,393,0,0]]], [180, [[1200,1230,337,10,0], [1230,1260,394,0,0], [1260,1320,340,24,0], [1320,1380,393,0,0]]], [190, [[1200,1230,337,10,0], [1230,1260,391,17,0], [1260,1320,340,24,0], [1320,1380,393,0,0]]]], "CBS": [[96, [[1200,1260,395,0,0], [1260,1380,396,0,0]]], [110, [[1200,1260,21,0,0], [1260,1380,396,0,0]]], [115, [[1200,1260,397,0,0], [1260,1380,396,0,0]]], [140, [[1200,1260,21,0,0], [1260,1320,14,0,0], [1320,1380,21,0,0]]], [145, [[1200,1260,14,0,0], [1260,1380,396,0,0]]], [150, [[1200,1260,398,0,0], [1260,1290,399,0,0], [1290,1320,400,0,0], [1320,1380,401,0,0]]], [160, [[1200,1260,398,0,0], [1260,1320,326,0,1], [1320,1380,401,0,0]]], [180, [[1200,1260,179,0,1], [1260,1320,144,0,1], [1320,1380,401,0,0]]]], "NBC": [[96, [[1200,1260,243,30,0], [1260,1320,303,0,0], [1320,1380,245,0,0]]], [130, [[1200,1260,243,30,0], [1260,1320,303,0,0], [1320,1380,245,0,0]]], [150, [[1200,1260,243,30,0], [1260,1320,365,0,0], [1320,1380,402,0,0]]], [180, [[1200,1260,243,30,0], [1260,1320,365,0,0], [1320,1380,403,0,0]]], [200, [[1200,1320,52,0,0], [1320,1380,403,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1260,388,0,0], [1260,1320,120,7,0], [1320,1380,298,22,0]]], [130, [[1200,1260,381,0,0], [1260,1320,120,7,0], [1320,1380,298,22,0]]], [180, [[1200,1260,381,0,0], [1260,1320,279,0,1], [1320,1380,298,22,0]]], [190, [[1200,1230,394,0,1], [1230,1260,404,0,1], [1260,1320,381,0,0], [1320,1380,298,22,0]]]], "CBS": [[96, [[1200,1260,397,0,0], [1260,1290,405,0,0], [1290,1320,406,0,0], [1320,1380,401,0,0]]], [110, [[1200,1260,96,0,0], [1260,1290,405,0,0], [1290,1320,406,0,0], [1320,1380,401,0,0]]], [115, [[1200,1230,399,0,0], [1230,1260,400,0,0], [1260,1290,405,0,0], [1290,1320,406,0,0], [1320,1380,401,0,0]]], [130, [[1200,1230,399,0,0], [1230,1260,400,0,0], [1260,1320,331,0,0], [1320,1380,401,0,0]]], [150, [[1200,1230,407,0,0], [1230,1260,408,0,0], [1260,1380,409,0,0]]], [160, [[1200,1260,344,0,0], [1260,1380,409,0,0]]], [180, [[1200,1230,400,0,0], [1230,1260,405,0,0], [1260,1320,325,0,1], [1320,1380,344,0,0]]]], "NBC": [[96, [[1200,1260,350,13,0], [1260,1320,410,0,0], [1320,1380,242,0,0]]], [130, [[1200,1260,350,13,0], [1260,1320,411,0,0], [1320,1380,242,0,0]]], [180, [[1200,1260,350,13,0], [1260,1290,200,0,1], [1290,1320,389,0,1], [1320,1380,242,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1260,186,0,0], [1260,1320,412,0,0], [1320,1380,58,0,0]]], [110, [[1200,1320,413,0,0], [1320,1380,58,0,0]]], [115, [[1200,1260,414,0,0], [1260,1320,415,0,0], [1320,1380,58,0,0]]], [130, [[1200,1260,219,0,0], [1260,1320,415,0,0], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,144,0,0], [1260,1320,179,29,0], [1320,1380,78,17,0]]], [130, [[1200,1260,144,0,0], [1260,1320,179,29,0], [1320,1380,78,17,0]]], [150, [[1200,1260,179,29,0], [1260,1320,416,0,0], [1320,1380,78,17,0]]], [180, [[1200,1260,331,0,1], [1260,1320,14,0,1], [1320,1380,78,17,0]]], [190, [[1200,1260,331,0,1], [1260,1380,417,0,0]]], [200, [[1200,1260,418,0,0], [1260,1320,331,0,1], [1320,1380,14,0,0]]]], "NBC": [[96, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,5,0], [1290,1320,307,11,0], [1320,1380,164,0,0]]], [145, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,5,0], [1290,1320,419,0,0], [1320,1380,164,0,0]]], [150, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,5,0], [1290,1320,307,11,0], [1320,1380,164,0,0]]], [180, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,5,0], [1290,1320,419,0,0], [1320,1380,164,0,0]]], [190, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,5,0], [1290,1320,307,11,0], [1320,1380,164,0,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,65,0,0], [1290,1320,71,0,0], [1320,1380,393,0,0]]], [110, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,65,0,0], [1290,1320,71,0,0], [1320,1380,392,0,0]]], [130, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,65,0,0], [1290,1320,420,0,0], [1320,1380,186,0,0]]], [150, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,404,0,0], [1290,1320,421,0,0], [1320,1380,186,0,0]]], [160, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1380,88,0,0]]], [180, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,404,0,0], [1290,1320,21,0,0], [1320,1380,102,0,1]]], [200, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1380,21,0,0]]]], "CBS": [[96, [[1200,1260,422,0,0], [1260,1320,92,6,0], [1320,1380,206,24,0]]], [130, [[1200,1260,422,0,0], [1260,1320,92,6,0], [1320,1380,206,24,0]]], [150, [[1200,1230,405,0,0], [1230,1260,423,0,0], [1260,1320,92,6,0], [1320,1380,206,24,0]]], [180, [[1200,1260,422,0,0], [1260,1380,424,0,0]]]], "NBC": [[96, [[1200,1260,228,0,0], [1260,1320,425,0,0], [1320,1380,366,9,0]]], [130, [[1200,1260,425,0,0], [1260,1320,228,0,0], [1320,1380,366,9,0]]], [145, [[1200,1260,303,0,0], [1260,1320,228,0,0], [1320,1380,366,9,0]]], [150, [[1200,1260,303,0,0], [1260,1320,426,0,0], [1320,1380,366,9,0]]], [160, [[1200,1260,228,0,0], [1260,1320,426,0,0], [1320,1380,366,9,0]]], [180, [[1200,1260,228,0,0], [1260,1320,366,9,0], [1320,1380,402,0,1]]], [200, [[1200,1260,243,0,1], [1260,1320,366,9,0], [1320,1380,303,0,0]]]]},
        "SAT": {"ABC": [[96, [[1200,1260,427,0,0], [1260,1320,428,0,0], [1320,1380,102,0,0]]], [110, [[1200,1260,186,0,0], [1260,1320,412,0,0], [1320,1380,102,0,0]]], [130, [[1200,1230,429,0,0], [1230,1260,71,0,0], [1260,1320,430,0,0], [1320,1380,102,0,0]]], [150, [[1200,1230,429,0,0], [1230,1260,71,0,0], [1260,1380,102,0,1]]], [160, [[1200,1230,404,0,0], [1230,1260,71,0,0], [1260,1380,102,0,1]]], [180, [[1200,1230,65,0,1], [1230,1260,71,0,0], [1260,1380,431,0,0]]]], "CBS": [[96, [[1200,1260,325,0,0], [1260,1380,432,0,0]]], [150, [[1200,1260,331,0,0], [1260,1380,432,0,0]]], [160, [[1200,1260,331,0,0], [1260,1320,325,0,0], [1320,1380,144,0,0]]], [180, [[1200,1380,21,0,0]]], [200, [[1200,1230,433,0,0], [1230,1380,432,0,0]]]], "NBC": [[96, [[1200,1230,200,0,0], [1230,1260,69,27,0], [1260,1290,434,7,0], [1290,1320,435,20,0], [1320,1380,365,0,0]]], [150, [[1200,1230,200,0,0], [1230,1260,69,27,0], [1260,1290,434,7,0], [1290,1320,419,0,0], [1320,1380,245,0,0]]], [160, [[1200,1230,200,0,0], [1230,1260,69,27,0], [1260,1290,434,7,0], [1290,1320,435,20,0], [1320,1380,245,0,0]]], [180, [[1200,1230,69,27,0], [1230,1260,435,20,0], [1260,1290,434,7,0], [1290,1320,436,0,0], [1320,1380,245,0,0]]], [200, [[1200,1230,69,27,0], [1230,1260,435,20,0], [1260,1290,434,7,0], [1290,1380,21,0,0]]]]},
    },
    1986: {
        "SUN": {"ABC": [[0, [[1140,1260,382,0,0], [1260,1380,4,0,0]]]], "CBS": [[96, [[1140,1200,9,6,0], [1200,1260,330,4,0], [1260,1380,383,16,0]]], [130, [[1140,1200,9,6,0], [1200,1260,330,4,0], [1260,1290,437,0,0], [1290,1320,438,0,0], [1320,1380,439,0,0]]], [150, [[1140,1200,9,6,0], [1200,1260,330,4,0], [1260,1380,383,16,0]]], [180, [[1140,1200,9,6,0], [1200,1260,330,4,0], [1260,1380,383,16,0]]]], "FOX": [[160, [[1140,1200,440,0,0], [1200,1230,441,0,0], [1230,1260,442,0,0], [1260,1290,443,0,0], [1290,1320,444,0,0], [1320,1380,445,0,0]]], [180, [[1140,1200,440,0,0], [1200,1230,441,0,0], [1230,1260,444,0,1], [1260,1290,443,0,0], [1290,1320,444,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1140,1200,446,0,0], [1200,1230,447,0,0], [1230,1260,390,0,0], [1260,1380,225,20,0]]], [130, [[1140,1200,446,0,0], [1200,1230,447,0,0], [1230,1260,390,0,0], [1260,1380,225,20,0]]], [150, [[1140,1200,446,0,0], [1200,1260,448,0,0], [1260,1380,225,20,0]]], [180, [[1140,1200,243,0,1], [1200,1260,446,0,1], [1260,1380,225,20,0]]], [190, [[1140,1200,446,0,1], [1200,1260,448,0,1], [1260,1380,225,20,0]]], [200, [[1140,1200,446,0,1], [1200,1260,234,0,1], [1260,1380,225,20,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,381,0,0], [1260,1380,20,18,0]]], [130, [[1200,1260,381,0,0], [1260,1380,22,0,0]]], [150, [[1200,1380,29,0,0]]], [180, [[1200,1380,29,0,0]]]], "CBS": [[96, [[1200,1230,290,19,0], [1230,1260,449,22,0], [1260,1290,223,12,0], [1290,1320,437,0,0], [1320,1380,197,0,0]]], [130, [[1200,1230,290,19,0], [1230,1260,449,22,0], [1260,1290,223,12,0], [1290,1320,450,0,0], [1320,1380,197,0,0]]], [150, [[1200,1230,290,19,0], [1230,1260,449,22,0], [1260,1290,223,12,0], [1290,1320,437,0,0], [1320,1380,197,0,0]]], [180, [[1200,1230,290,19,0], [1230,1260,449,22,0], [1260,1290,223,12,0], [1290,1320,437,0,0], [1320,1380,197,0,0]]]], "NBC": [[96, [[1200,1230,451,28,0], [1230,1260,384,0,0], [1260,1380,40,17,0]]], [130, [[1200,1230,451,28,0], [1230,1260,384,0,0], [1260,1380,40,17,0]]], [150, [[1200,1230,451,28,0], [1230,1260,390,0,0], [1260,1380,40,17,0]]], [180, [[1200,1230,451,28,0], [1230,1260,390,0,0], [1260,1380,40,17,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,337,10,0], [1230,1260,391,8,0], [1260,1320,340,9,0], [1320,1380,452,0,0]]], [130, [[1200,1230,337,10,0], [1230,1260,391,8,0], [1260,1320,340,9,0], [1320,1380,452,0,0]]], [150, [[1200,1230,337,10,0], [1230,1260,391,8,0], [1260,1320,340,9,0], [1320,1380,453,0,0]]], [180, [[1200,1230,337,10,0], [1230,1260,391,8,0], [1260,1320,340,9,0], [1320,1380,393,0,1]]]], "CBS": [[96, [[1200,1260,454,0,0], [1260,1380,396,0,0]]], [130, [[1200,1260,455,0,0], [1260,1380,396,0,0]]], [150, [[1200,1260,344,0,0], [1260,1380,396,0,0]]], [180, [[1200,1260,454,0,1], [1260,1380,396,0,0]]], [190, [[1200,1260,179,0,1], [1260,1320,456,0,1], [1320,1380,457,0,0]]]], "NBC": [[96, [[1200,1260,458,15,0], [1260,1320,459,0,0], [1320,1380,403,0,0]]], [110, [[1200,1260,458,15,0], [1260,1320,164,0,0], [1320,1380,403,0,0]]], [130, [[1200,1260,458,15,0], [1260,1320,164,0,0], [1320,1380,245,0,0]]], [150, [[1200,1260,458,15,0], [1260,1290,200,0,0], [1290,1320,447,0,0], [1320,1380,164,0,0]]], [160, [[1200,1260,458,15,0], [1260,1290,200,0,0], [1290,1320,460,0,0], [1320,1380,164,0,0]]], [180, [[1200,1260,458,15,0], [1260,1380,52,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1230,394,0,0], [1230,1260,461,30,0], [1260,1320,120,25,0], [1320,1380,298,0,0]]], [130, [[1200,1230,394,0,0], [1230,1260,461,30,0], [1260,1320,120,25,0], [1320,1380,298,0,0]]], [150, [[1200,1230,394,0,0], [1230,1260,462,0,0], [1260,1320,120,25,0], [1320,1380,298,0,0]]], [160, [[1200,1230,394,0,0], [1230,1260,461,30,0], [1260,1320,120,25,0], [1320,1380,463,0,0]]], [180, [[1200,1230,394,0,0], [1230,1260,461,30,0], [1260,1320,381,0,1], [1320,1380,298,0,1]]]], "CBS": [[96, [[1200,1230,464,0,0], [1230,1260,465,0,0], [1260,1320,144,0,0], [1320,1380,401,0,0]]], [115, [[1200,1260,466,0,0], [1260,1320,144,0,0], [1320,1380,401,0,0]]], [130, [[1200,1260,466,0,0], [1260,1320,144,0,0], [1320,1380,401,0,0]]], [150, [[1200,1260,466,0,0], [1260,1320,144,0,0], [1320,1380,456,0,0]]], [160, [[1200,1230,467,0,0], [1230,1260,468,0,0], [1260,1320,144,0,0], [1320,1380,456,0,0]]], [170, [[1200,1260,466,0,1], [1260,1320,144,0,0], [1320,1380,456,0,0]]], [190, [[1200,1260,466,0,1], [1260,1320,144,0,0], [1320,1380,401,0,1]]]], "NBC": [[96, [[1200,1260,350,24,0], [1260,1290,200,0,0], [1290,1320,389,0,0], [1320,1380,242,0,0]]], [130, [[1200,1260,350,24,0], [1260,1290,200,0,0], [1290,1320,460,0,0], [1320,1380,242,0,0]]], [145, [[1200,1260,350,24,0], [1260,1290,307,7,0], [1290,1320,460,0,0], [1320,1380,469,0,0]]], [150, [[1200,1260,350,24,0], [1260,1290,307,7,0], [1290,1320,447,0,0], [1320,1380,469,0,0]]], [160, [[1200,1260,350,24,0], [1260,1290,307,7,0], [1290,1320,447,0,0], [1320,1380,242,0,0]]], [180, [[1200,1260,350,24,0], [1260,1290,69,0,1], [1290,1320,307,0,1], [1320,1380,242,0,0]]], [190, [[1200,1260,350,24,0], [1260,1290,307,0,1], [1290,1320,21,0,0], [1320,1380,242,0,0]]], [200, [[1200,1260,350,24,0], [1260,1320,469,0,1], [1320,1380,242,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1260,470,0,0], [1260,1320,415,0,0], [1320,1380,58,0,0]]], [130, [[1200,1260,470,0,0], [1260,1320,415,0,0], [1320,1380,58,0,0]]], [150, [[1200,1260,470,0,0], [1260,1320,452,0,0], [1320,1380,58,0,0]]], [180, [[1200,1260,470,0,0], [1260,1320,471,0,1], [1320,1380,58,0,0]]], [190, [[1200,1260,472,0,1], [1260,1320,470,0,0], [1320,1380,58,0,0]]], [200, [[1200,1230,473,0,1], [1230,1260,474,0,1], [1260,1320,470,0,0], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,179,0,0], [1260,1320,78,26,0], [1320,1380,475,0,0]]], [110, [[1200,1230,422,0,0], [1230,1290,179,0,0], [1290,1320,437,0,0], [1320,1380,78,26,0]]], [130, [[1200,1260,476,0,0], [1260,1320,179,0,0], [1320,1380,78,26,0]]], [140, [[1200,1260,454,0,0], [1260,1320,179,0,0], [1320,1380,78,26,0]]], [150, [[1200,1260,454,0,0], [1260,1320,179,0,0], [1320,1380,78,26,0]]], [180, [[1200,1260,288,0,1], [1260,1320,179,0,0], [1320,1380,78,26,0]]], [190, [[1200,1260,288,0,1], [1260,1380,417,0,0]]]], "NBC": [[96, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,3,0], [1290,1320,307,7,0], [1320,1380,164,0,0]]], [110, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,3,0], [1290,1320,307,7,0], [1320,1380,477,21,0]]], [130, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,3,0], [1290,1320,307,7,0], [1320,1380,477,21,0]]], [150, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,3,0], [1290,1320,478,0,0], [1320,1380,477,21,0]]], [180, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,3,0], [1290,1320,479,0,0], [1320,1380,477,21,0]]], [200, [[1200,1230,357,1,0], [1230,1260,234,2,0], [1260,1290,265,3,0], [1290,1320,307,0,1], [1320,1380,477,21,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,480,0,0], [1290,1320,473,0,0], [1320,1380,472,0,0]]], [115, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,481,0,0], [1290,1320,482,0,0], [1320,1380,472,0,0]]], [130, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1290,482,0,0], [1290,1320,481,0,0], [1320,1380,472,0,0]]], [140, [[1200,1230,317,0,0], [1230,1260,359,0,0], [1260,1380,88,0,0]]], [145, [[1200,1230,474,0,0], [1230,1260,317,0,0], [1260,1380,88,0,0]]], [150, [[1200,1230,474,0,0], [1230,1260,317,0,0], [1260,1380,88,0,0]]], [180, [[1200,1230,473,0,1], [1230,1260,359,0,1], [1260,1380,88,0,0]]], [200, [[1200,1230,317,0,1], [1230,1260,359,0,1], [1260,1320,453,0,1], [1320,1380,472,0,1]]]], "CBS": [[96, [[1200,1260,288,0,0], [1260,1320,92,11,0], [1320,1380,206,23,0]]], [130, [[1200,1260,288,0,0], [1260,1320,92,11,0], [1320,1380,206,23,0]]], [150, [[1200,1230,438,0,0], [1230,1260,483,0,0], [1260,1320,92,11,0], [1320,1380,206,23,0]]], [180, [[1200,1260,484,0,0], [1260,1320,92,11,0], [1320,1380,439,0,0]]], [190, [[1200,1260,484,0,0], [1260,1320,92,11,0], [1320,1380,485,0,0]]]], "NBC": [[96, [[1200,1260,243,0,0], [1260,1320,366,27,0], [1320,1380,477,21,0]]], [110, [[1200,1260,243,0,0], [1260,1320,366,27,0], [1320,1380,459,0,0]]], [130, [[1200,1260,402,0,0], [1260,1320,366,27,0], [1320,1380,459,0,0]]], [150, [[1200,1230,486,0,0], [1230,1260,384,0,0], [1260,1320,366,27,0], [1320,1380,402,0,0]]], [180, [[1200,1260,402,0,1], [1260,1320,366,27,0], [1320,1380,459,0,1]]], [200, [[1200,1260,448,0,1], [1260,1320,366,27,0], [1320,1380,459,0,1]]]]},
        "SAT": {"ABC": [[96, [[1200,1230,487,0,0], [1230,1260,488,0,0], [1260,1320,471,0,0], [1320,1380,393,0,0]]], [115, [[1200,1230,480,0,0], [1230,1260,473,0,0], [1260,1320,471,0,0], [1320,1380,393,0,0]]], [130, [[1200,1230,480,0,0], [1230,1260,473,0,0], [1260,1320,489,0,0], [1320,1380,393,0,0]]], [150, [[1200,1260,472,0,0], [1260,1320,489,0,0], [1320,1380,393,0,0]]], [180, [[1200,1230,317,0,1], [1230,1260,480,0,0], [1260,1290,482,0,1], [1290,1320,481,0,1], [1320,1380,472,0,1]]], [190, [[1200,1230,317,0,1], [1230,1380,490,0,0]]], [200, [[1200,1230,491,0,0], [1230,1260,488,0,0], [1260,1380,490,0,0]]]], "CBS": [[96, [[1200,1260,492,0,0], [1260,1320,466,0,0], [1320,1380,422,0,0]]], [110, [[1200,1260,454,0,0], [1260,1320,466,0,0], [1320,1380,422,0,0]]], [115, [[1200,1260,492,0,0], [1260,1320,466,0,0], [1320,1380,422,0,0]]], [130, [[1200,1260,493,0,0], [1260,1380,274,0,0]]], [150, [[1200,1320,274,0,0], [1320,1380,344,0,0]]], [180, [[1200,1320,274,0,0], [1320,1380,344,0,0]]]], "FOX": [[190, [[1200,1230,494,0,0], [1230,1260,495,0,0], [1260,1290,496,0,0], [1290,1320,497,0,0], [1320,1380,445,0,0]]], [200, [[1200,1230,496,0,0], [1230,1260,495,0,0], [1260,1290,494,0,0], [1290,1320,497,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1200,1230,69,0,0], [1230,1260,435,14,0], [1260,1290,434,5,0], [1290,1320,498,13,0], [1320,1380,365,28,0]]], [130, [[1200,1230,69,0,0], [1230,1260,435,14,0], [1260,1290,434,5,0], [1290,1320,498,13,0], [1320,1380,365,28,0]]], [150, [[1200,1230,69,0,0], [1230,1260,435,14,0], [1260,1290,434,5,0], [1290,1320,498,13,0], [1320,1380,365,28,0]]], [160, [[1200,1230,69,0,0], [1230,1260,499,0,0], [1260,1290,434,5,0], [1290,1320,436,0,0], [1320,1380,365,28,0]]], [170, [[1200,1230,69,0,0], [1230,1260,435,14,0], [1260,1290,434,5,0], [1290,1320,436,0,0], [1320,1380,365,28,0]]], [180, [[1200,1230,435,0,1], [1230,1260,436,0,0], [1260,1290,434,5,0], [1290,1320,498,0,1], [1320,1380,365,28,0]]], [190, [[1200,1230,69,0,1], [1230,1260,435,0,1], [1260,1290,434,5,0], [1290,1320,498,0,1], [1320,1380,365,28,0]]]]},
    },
    1987: {
        "SUN": {"ABC": [[96, [[1140,1200,382,0,0], [1200,1260,393,0,0], [1260,1320,500,0,0], [1320,1380,501,0,0]]], [130, [[1140,1260,382,0,0], [1260,1380,4,0,0]]], [150, [[1140,1200,382,0,0], [1200,1260,502,0,0], [1260,1380,4,0,0]]], [160, [[1140,1200,382,0,0], [1200,1260,96,0,0], [1260,1380,4,0,0]]], [180, [[1140,1200,382,0,0], [1200,1260,381,0,1], [1260,1380,4,0,0]]]], "CBS": [[0, [[1140,1200,9,8,0], [1200,1260,330,9,0], [1260,1380,383,18,0]]]], "FOX": [[96, [[1140,1200,440,0,0], [1200,1230,441,0,0], [1230,1260,21,0,0], [1260,1290,442,0,0], [1290,1320,443,0,0], [1320,1380,445,0,0]]], [110, [[1140,1200,440,0,0], [1200,1230,496,0,0], [1230,1260,441,0,0], [1260,1290,442,0,0], [1290,1320,444,0,0], [1320,1380,445,0,0]]], [130, [[1140,1200,440,0,0], [1200,1230,496,0,0], [1230,1260,441,0,0], [1260,1290,503,0,1], [1290,1320,444,0,0], [1320,1350,442,0,0], [1350,1380,445,0,0]]], [150, [[1140,1200,440,0,0], [1200,1230,504,0,0], [1230,1260,441,0,0], [1260,1290,503,0,1], [1290,1320,444,0,0], [1320,1350,442,0,0], [1350,1380,496,0,0]]], [180, [[1140,1200,440,0,0], [1200,1230,504,0,0], [1230,1260,441,0,0], [1260,1290,503,0,1], [1290,1320,444,0,0], [1320,1350,442,0,0], [1350,1380,496,0,0]]]], "NBC": [[96, [[1140,1200,446,0,0], [1200,1230,234,17,0], [1230,1260,505,20,0], [1260,1380,225,23,0]]], [130, [[1140,1200,446,0,0], [1200,1230,234,17,0], [1230,1260,505,20,0], [1260,1380,225,23,0]]], [150, [[1140,1200,446,0,0], [1200,1230,234,17,0], [1230,1260,506,28,0], [1260,1380,225,23,0]]], [180, [[1140,1200,448,0,1], [1200,1230,234,17,0], [1230,1260,505,20,0], [1260,1380,225,23,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,381,0,0], [1260,1380,20,16,0]]], [130, [[1200,1260,381,0,0], [1260,1380,22,0,0]]], [150, [[1200,1260,381,0,0], [1260,1380,22,0,0]]], [180, [[1200,1380,29,0,0]]]], "CBS": [[96, [[1200,1230,507,0,0], [1230,1260,290,0,0], [1260,1290,223,25,0], [1290,1320,437,0,0], [1320,1380,197,0,0]]], [110, [[1200,1230,290,0,0], [1230,1260,507,0,0], [1260,1290,223,25,0], [1290,1320,437,0,0], [1320,1380,197,0,0]]], [130, [[1200,1230,290,0,0], [1230,1260,437,0,0], [1260,1290,223,25,0], [1290,1320,507,0,0], [1320,1380,508,0,0]]], [150, [[1200,1230,290,0,0], [1230,1260,437,0,0], [1260,1290,223,25,0], [1290,1320,509,0,0], [1320,1380,508,0,0]]], [160, [[1200,1230,290,0,0], [1230,1260,437,0,0], [1260,1290,223,25,0], [1290,1320,509,0,0], [1320,1380,197,0,0]]], [180, [[1200,1260,510,0,0], [1260,1290,223,25,0], [1290,1320,509,0,0], [1320,1380,197,0,0]]], [190, [[1200,1260,510,0,0], [1260,1290,223,25,0], [1290,1320,437,0,1], [1320,1380,144,0,1]]], [200, [[1200,1230,223,0,1], [1230,1260,450,0,0], [1260,1290,290,0,1], [1290,1320,437,0,1], [1320,1380,144,0,1]]]], "NBC": [[0, [[1200,1230,451,10,0], [1230,1260,511,20,0], [1260,1380,40,26,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,337,6,0], [1230,1260,391,5,0], [1260,1320,340,12,0], [1320,1380,512,0,0]]], [130, [[1200,1230,337,6,0], [1230,1260,513,10,0], [1260,1320,340,12,0], [1320,1380,512,0,0]]], [150, [[1200,1230,337,6,0], [1230,1260,514,0,0], [1260,1320,340,12,0], [1320,1380,512,0,0]]], [180, [[1200,1230,337,6,0], [1230,1260,394,0,1], [1260,1320,340,12,0], [1320,1380,512,0,0]]], [190, [[1200,1230,337,6,0], [1230,1260,515,0,1], [1260,1320,340,12,0], [1320,1380,512,0,0]]]], "CBS": [[96, [[1200,1260,456,0,0], [1260,1320,516,0,0], [1320,1380,517,0,0]]], [130, [[1200,1260,518,0,0], [1260,1320,516,0,0], [1320,1380,197,0,0]]], [150, [[1200,1230,519,0,0], [1230,1260,449,0,0], [1260,1290,520,0,0], [1290,1320,507,0,0], [1320,1380,197,0,0]]], [160, [[1200,1260,456,0,0], [1260,1380,48,0,0]]], [180, [[1200,1260,484,0,0], [1260,1380,48,0,0]]]], "NBC": [[96, [[1200,1260,458,14,0], [1260,1320,521,0,0], [1320,1380,459,0,0]]], [110, [[1200,1260,458,14,0], [1260,1320,365,28,0], [1320,1380,459,0,0]]], [130, [[1200,1260,458,14,0], [1260,1320,365,28,0], [1320,1380,459,0,0]]], [150, [[1200,1260,458,14,0], [1260,1320,522,19,0], [1320,1380,459,0,0]]], [160, [[1200,1260,458,14,0], [1260,1380,52,0,0]]], [180, [[1200,1260,458,14,0], [1260,1320,521,0,0], [1320,1380,523,0,0]]], [190, [[1200,1260,458,14,0], [1260,1320,522,0,1], [1320,1380,523,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1230,394,0,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,525,0,0], [1320,1380,120,0,0]]], [130, [[1200,1230,394,0,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,525,0,0], [1320,1380,120,0,0]]], [145, [[1200,1230,391,5,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,525,0,0], [1320,1380,120,0,0]]], [150, [[1200,1230,391,5,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,526,0,0], [1320,1380,527,0,0]]], [160, [[1200,1230,391,5,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,526,0,0], [1320,1380,528,0,0]]], [170, [[1200,1230,391,5,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,525,0,0], [1320,1380,528,0,0]]], [180, [[1200,1230,391,5,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,525,0,0], [1320,1380,393,0,1]]], [200, [[1200,1230,391,5,0], [1230,1260,461,23,0], [1260,1290,524,0,0], [1290,1320,525,0,0], [1320,1380,528,0,1]]]], "CBS": [[96, [[1200,1260,529,0,0], [1260,1320,144,0,0], [1320,1380,401,0,0]]], [130, [[1200,1260,517,0,0], [1260,1320,144,0,0], [1320,1380,401,0,0]]], [150, [[1200,1260,530,0,0], [1260,1320,516,0,0], [1320,1380,401,0,0]]], [180, [[1200,1260,516,0,1], [1260,1320,401,0,1], [1320,1380,508,0,1]]]], "NBC": [[96, [[1200,1260,350,0,0], [1260,1320,531,0,0], [1320,1380,242,0,0]]], [130, [[1200,1260,350,0,0], [1260,1320,531,0,0], [1320,1380,242,0,0]]], [140, [[1200,1260,532,30,0], [1260,1320,350,0,0], [1320,1380,531,0,0]]], [150, [[1200,1260,532,30,0], [1260,1320,531,0,0], [1320,1380,469,0,0]]], [160, [[1200,1260,532,30,0], [1260,1320,350,0,0], [1320,1380,242,0,0]]], [180, [[1200,1260,350,0,1], [1260,1290,479,0,0], [1290,1320,352,0,1], [1320,1380,469,0,0]]], [190, [[1200,1260,96,0,0], [1260,1320,533,0,0], [1320,1380,242,0,1]]], [200, [[1200,1260,533,0,0], [1260,1380,534,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1230,473,0,0], [1230,1260,474,0,0], [1260,1380,262,0,0]]], [130, [[1200,1230,474,0,0], [1230,1380,262,0,0]]], [150, [[1200,1260,535,0,0], [1260,1320,298,0,0], [1320,1380,501,0,0]]], [160, [[1200,1260,453,0,0], [1260,1320,298,0,0], [1320,1380,501,0,0]]], [180, [[1200,1320,262,0,0], [1320,1380,536,0,0]]]], "CBS": [[96, [[1200,1260,537,0,0], [1260,1320,508,0,0], [1320,1380,78,0,0]]], [130, [[1200,1260,537,0,0], [1260,1320,179,0,0], [1320,1380,78,0,0]]], [150, [[1200,1260,518,0,0], [1260,1320,179,0,0], [1320,1380,78,0,0]]], [180, [[1200,1260,518,0,0], [1260,1320,179,0,0], [1320,1380,197,0,1]]]], "NBC": [[96, [[1200,1230,357,1,0], [1230,1260,538,2,0], [1260,1290,265,3,0], [1290,1320,307,7,0], [1320,1380,477,12,0]]], [130, [[1200,1230,357,1,0], [1230,1260,538,2,0], [1260,1290,265,3,0], [1290,1320,307,7,0], [1320,1380,477,12,0]]], [150, [[1200,1230,357,1,0], [1230,1260,538,2,0], [1260,1290,265,3,0], [1290,1320,479,0,0], [1320,1380,477,12,0]]], [160, [[1200,1230,357,1,0], [1230,1260,538,2,0], [1260,1290,265,3,0], [1290,1320,307,7,0], [1320,1380,477,12,0]]], [180, [[1200,1230,357,1,0], [1230,1260,538,2,0], [1260,1290,265,3,0], [1290,1320,307,7,0], [1320,1380,477,12,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,515,0,0], [1230,1260,539,0,0], [1260,1320,453,0,0], [1320,1380,58,0,0]]], [110, [[1200,1230,515,0,0], [1230,1260,539,0,0], [1260,1290,359,0,0], [1290,1320,540,0,0], [1320,1380,58,0,0]]], [130, [[1200,1230,515,0,0], [1230,1260,359,0,0], [1260,1290,541,0,0], [1290,1320,473,0,0], [1320,1380,58,0,0]]], [145, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,541,0,0], [1320,1380,58,0,0]]], [150, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,542,0,0], [1320,1380,58,0,0]]], [180, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,539,0,1], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,543,0,0], [1260,1320,92,22,0], [1320,1380,206,0,0]]], [130, [[1200,1260,543,0,0], [1260,1320,92,22,0], [1320,1380,206,0,0]]], [150, [[1200,1260,543,0,0], [1260,1320,92,22,0], [1320,1380,206,0,0]]], [180, [[1200,1260,543,0,0], [1260,1380,424,0,0]]]], "NBC": [[96, [[1200,1260,448,0,0], [1260,1320,366,0,0], [1320,1380,544,0,0]]], [130, [[1200,1260,96,0,0], [1260,1320,366,0,0], [1320,1380,545,0,0]]], [145, [[1200,1260,546,0,0], [1260,1320,366,0,0], [1320,1380,545,0,0]]], [150, [[1200,1260,546,0,0], [1260,1290,307,7,0], [1290,1320,547,0,0], [1320,1380,366,0,0]]], [160, [[1200,1260,292,0,1], [1260,1320,546,0,0], [1320,1380,366,0,0]]], [180, [[1200,1260,292,0,1], [1260,1320,545,0,1], [1320,1380,366,0,0]]], [190, [[1200,1260,292,0,1], [1260,1320,411,0,1], [1320,1380,366,0,0]]]]},
        "SAT": {"ABC": [[96, [[1200,1260,548,0,0], [1260,1320,489,0,0], [1320,1380,298,0,0]]], [110, [[1200,1260,549,0,0], [1260,1320,489,0,0], [1320,1380,298,0,0]]], [115, [[1200,1260,489,0,0], [1260,1320,549,0,0], [1320,1380,298,0,0]]], [130, [[1200,1260,500,0,0], [1260,1320,489,0,0], [1320,1380,393,0,0]]], [150, [[1200,1260,500,0,0], [1260,1320,489,0,0], [1320,1380,393,0,0]]], [170, [[1200,1260,535,0,1], [1260,1320,489,0,0], [1320,1380,393,0,0]]], [180, [[1200,1260,535,0,1], [1260,1320,489,0,0], [1320,1380,298,0,1]]], [190, [[1200,1260,502,0,1], [1260,1320,489,0,0], [1320,1380,298,0,1]]], [200, [[1200,1260,502,0,1], [1260,1320,21,0,0], [1320,1380,393,0,1]]]], "CBS": [[96, [[1200,1230,449,0,0], [1230,1260,550,0,0], [1260,1320,551,0,0], [1320,1380,344,0,0]]], [110, [[1200,1320,274,0,0], [1320,1380,344,0,0]]], [130, [[1200,1260,552,0,0], [1260,1320,456,0,0], [1320,1380,344,0,0]]], [140, [[1200,1260,552,0,0], [1260,1320,537,0,0], [1320,1380,344,0,0]]], [150, [[1200,1260,552,0,0], [1260,1320,537,0,0], [1320,1380,344,0,0]]], [180, [[1200,1230,290,0,1], [1230,1260,507,0,1], [1260,1320,537,0,0], [1320,1380,344,0,0]]], [200, [[1200,1230,553,0,0], [1230,1260,507,0,1], [1260,1320,537,0,0], [1320,1380,344,0,0]]]], "FOX": [[96, [[1200,1230,496,0,0], [1230,1260,495,0,0], [1260,1290,554,0,0], [1290,1320,444,0,0], [1320,1380,445,0,0]]], [110, [[1200,1230,443,0,0], [1230,1260,555,0,0], [1260,1290,495,0,0], [1290,1320,554,0,0], [1320,1380,445,0,0]]], [130, [[1200,1230,556,0,0], [1230,1260,555,0,0], [1260,1290,495,0,0], [1290,1320,443,0,0], [1320,1380,445,0,0]]], [150, [[1200,1230,557,0,0], [1230,1260,556,0,0], [1260,1320,496,0,0], [1320,1380,445,0,0]]], [160, [[1200,1230,557,0,0], [1230,1260,556,0,0], [1260,1320,558,0,0], [1320,1380,445,0,0]]], [180, [[1200,1260,557,0,0], [1260,1320,558,0,0], [1320,1380,445,0,0]]], [200, [[1200,1260,559,0,0], [1260,1320,96,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1200,1230,69,0,0], [1230,1260,435,27,0], [1260,1290,434,4,0], [1290,1320,498,15,0], [1320,1380,365,29,0]]], [115, [[1200,1230,69,0,0], [1230,1260,435,27,0], [1260,1290,434,4,0], [1290,1320,498,15,0], [1320,1380,521,0,0]]], [130, [[1200,1230,69,0,0], [1230,1260,435,27,0], [1260,1290,434,4,0], [1290,1320,498,15,0], [1320,1380,521,0,0]]], [150, [[1200,1230,69,0,0], [1230,1260,435,27,0], [1260,1290,434,4,0], [1290,1320,498,15,0], [1320,1380,365,28,0]]], [180, [[1200,1230,69,0,0], [1230,1260,435,27,0], [1260,1290,434,4,0], [1290,1320,498,15,0], [1320,1380,365,28,0]]]]},
    },
    1988: {
        "SUN": {"ABC": [[96, [[1140,1200,560,0,0], [1200,1260,561,0,0], [1260,1380,4,0,0]]], [130, [[1140,1200,562,0,0], [1200,1260,96,0,0], [1260,1380,4,0,0]]], [150, [[1140,1200,560,0,0], [1200,1260,340,0,0], [1260,1380,4,0,0]]], [180, [[1140,1200,560,0,0], [1200,1230,563,0,1], [1230,1380,4,0,0]]], [200, [[1140,1200,560,0,0], [1200,1260,381,0,1], [1260,1380,4,0,0]]]], "CBS": [[0, [[1140,1200,9,5,0], [1200,1260,330,8,0], [1260,1380,383,27,0]]]], "FOX": [[96, [[1140,1200,440,0,0], [1200,1230,504,0,0], [1230,1260,441,0,0], [1260,1290,503,0,1], [1290,1320,442,0,0], [1320,1350,444,0,0], [1350,1380,445,0,0]]], [130, [[1140,1200,440,0,0], [1200,1230,504,0,0], [1230,1260,441,0,0], [1260,1290,503,0,1], [1290,1320,442,0,0], [1320,1350,444,0,0], [1350,1380,445,0,0]]], [150, [[1140,1200,440,0,0], [1200,1230,504,0,0], [1230,1260,441,0,0], [1260,1290,503,0,1], [1290,1320,442,0,0], [1320,1350,444,0,0], [1350,1380,445,0,0]]], [180, [[1140,1200,440,0,0], [1200,1230,504,0,0], [1230,1260,564,0,0], [1260,1290,441,0,1], [1290,1320,503,0,1], [1320,1350,442,0,1], [1350,1380,444,0,1]]]], "NBC": [[96, [[1140,1200,565,0,0], [1200,1230,234,0,0], [1230,1260,506,0,0], [1260,1380,170,22,0]]], [130, [[1140,1200,565,0,0], [1200,1230,234,0,0], [1230,1260,506,0,0], [1260,1380,170,22,0]]], [150, [[1140,1200,565,0,0], [1200,1230,234,0,0], [1230,1260,506,0,0], [1260,1380,170,22,0]]], [180, [[1140,1200,566,0,0], [1200,1260,565,0,0], [1260,1380,170,22,0]]], [200, [[1140,1200,565,0,0], [1200,1230,234,0,1], [1230,1260,505,0,1], [1260,1380,170,22,0]]]]},
        "MON": {"ABC": [[96, [[1200,1380,20,15,0]]], [110, [[1200,1260,381,0,0], [1260,1380,20,15,0]]], [130, [[1200,1260,381,0,0], [1260,1380,22,0,0]]], [140, [[1200,1260,381,0,0], [1260,1380,567,29,0]]], [150, [[1200,1260,381,0,0], [1260,1380,567,29,0]]], [180, [[1200,1260,381,0,0], [1260,1380,567,29,0]]]], "CBS": [[96, [[1200,1230,223,0,0], [1230,1260,450,0,0], [1260,1380,568,0,0]]], [110, [[1200,1230,223,0,0], [1230,1260,520,0,0], [1260,1290,569,0,0], [1290,1320,437,0,0], [1320,1380,96,0,0]]], [130, [[1200,1230,223,0,0], [1230,1260,290,0,0], [1260,1290,569,0,0], [1290,1320,437,0,0], [1320,1380,570,0,0]]], [150, [[1200,1230,571,0,0], [1230,1260,572,0,0], [1260,1290,569,0,0], [1290,1320,437,0,0], [1320,1350,223,0,0], [1350,1380,290,0,0]]], [180, [[1200,1230,290,0,1], [1230,1260,572,0,0], [1260,1290,569,0,0], [1290,1320,437,0,0], [1320,1350,223,0,0], [1350,1380,573,0,0]]], [190, [[1200,1230,290,0,1], [1230,1260,437,0,1], [1260,1290,569,0,0], [1290,1320,437,0,0], [1320,1350,569,0,1], [1350,1380,223,0,1]]]], "NBC": [[96, [[1200,1230,451,15,0], [1230,1260,574,22,0], [1260,1380,40,25,0]]], [130, [[1200,1230,451,15,0], [1230,1260,574,22,0], [1260,1380,40,25,0]]], [150, [[1200,1230,451,15,0], [1230,1260,575,0,0], [1260,1380,40,25,0]]], [160, [[1200,1230,451,15,0], [1230,1260,574,22,0], [1260,1380,40,25,0]]], [180, [[1200,1230,451,15,0], [1230,1260,574,22,0], [1260,1380,40,25,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,337,7,0], [1230,1260,576,2,0], [1260,1380,96,0,0]]], [115, [[1200,1230,337,7,0], [1230,1260,576,2,0], [1260,1320,340,0,0], [1320,1380,512,0,0]]], [130, [[1200,1230,337,7,0], [1230,1260,576,2,0], [1260,1320,340,0,0], [1320,1380,512,0,0]]], [145, [[1200,1230,337,7,0], [1230,1260,513,22,0], [1260,1290,576,2,0], [1290,1320,577,10,0], [1320,1380,512,0,0]]], [150, [[1200,1230,337,7,0], [1230,1260,513,22,0], [1260,1290,576,2,0], [1290,1320,563,0,0], [1320,1380,512,0,0]]], [180, [[1200,1230,337,7,0], [1230,1260,513,22,0], [1260,1290,576,2,0], [1290,1320,578,0,1], [1320,1380,512,0,0]]]], "CBS": [[96, [[1200,1260,579,0,0], [1260,1380,580,0,0]]], [115, [[1200,1260,581,0,0], [1260,1380,580,0,0]]], [130, [[1200,1260,537,0,0], [1260,1380,580,0,0]]], [150, [[1200,1260,537,0,0], [1260,1380,580,0,0]]], [180, [[1200,1260,484,0,0], [1260,1380,580,0,0]]]], "NBC": [[96, [[1200,1260,458,13,0], [1260,1380,52,0,0]]], [110, [[1200,1260,458,13,0], [1260,1320,522,18,0], [1320,1380,582,0,0]]], [130, [[1200,1260,458,13,0], [1260,1320,522,18,0], [1320,1380,582,0,0]]], [150, [[1200,1260,458,13,0], [1260,1320,522,18,0], [1320,1380,582,0,0]]], [180, [[1200,1260,458,13,0], [1260,1320,522,18,0], [1320,1380,582,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1230,391,13,0], [1230,1260,461,20,0], [1260,1380,249,0,0]]], [115, [[1200,1230,391,13,0], [1230,1260,461,20,0], [1260,1290,513,22,0], [1290,1320,524,0,0], [1320,1380,528,0,0]]], [145, [[1200,1230,391,13,0], [1230,1260,461,20,0], [1260,1290,578,0,0], [1290,1320,524,0,0], [1320,1380,528,0,0]]], [150, [[1200,1230,391,13,0], [1230,1260,461,20,0], [1260,1290,578,0,0], [1290,1320,583,0,0], [1320,1380,528,0,0]]], [180, [[1200,1230,391,13,0], [1230,1260,461,20,0], [1260,1290,524,0,0], [1290,1320,583,0,0], [1320,1380,528,0,0]]], [200, [[1200,1230,391,13,0], [1230,1260,461,20,0], [1260,1290,524,0,0], [1290,1320,578,0,0], [1320,1380,528,0,0]]]], "CBS": [[90, [[1200,1260,584,0,0], [1260,1320,401,0,0], [1320,1380,508,0,0]]], [96, [[1200,1230,585,0,0], [1230,1260,586,0,0], [1260,1320,401,0,0], [1320,1380,508,0,0]]], [130, [[1200,1260,581,0,0], [1260,1320,401,0,0], [1320,1380,508,0,0]]], [140, [[1200,1260,587,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]], [150, [[1200,1260,587,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]], [180, [[1200,1260,587,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]], [200, [[1200,1260,588,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]]], "NBC": [[96, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,590,0,0], [1320,1380,591,0,0]]], [110, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,505,0,0], [1320,1380,591,0,0]]], [130, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,505,0,0], [1320,1380,592,0,0]]], [150, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,505,0,0], [1320,1380,592,0,0]]], [160, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,505,0,0], [1320,1380,593,0,0]]], [180, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,505,0,0], [1320,1380,366,0,0]]], [190, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,594,0,0], [1320,1380,366,0,0]]], [200, [[1200,1260,589,17,0], [1260,1290,307,21,0], [1290,1320,595,0,0], [1320,1380,96,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1380,96,0,0]]], [110, [[1200,1260,596,0,0], [1260,1320,120,0,0], [1320,1380,96,0,0]]], [130, [[1200,1260,597,0,0], [1260,1320,120,0,0], [1320,1380,527,0,0]]], [150, [[1200,1260,96,0,0], [1260,1320,120,0,0], [1320,1380,598,0,0]]], [180, [[1200,1380,599,0,0]]], [200, [[1200,1260,600,0,1], [1260,1320,561,0,1], [1320,1380,601,0,0]]]], "CBS": [[96, [[1200,1260,518,0,0], [1260,1380,417,0,0]]], [110, [[1200,1260,518,0,0], [1260,1320,602,0,0], [1320,1380,78,27,0]]], [130, [[1200,1260,518,0,0], [1260,1320,602,0,0], [1320,1380,78,27,0]]], [150, [[1200,1260,518,0,0], [1260,1320,401,0,0], [1320,1380,78,27,0]]], [180, [[1200,1260,518,0,0], [1260,1290,450,0,0], [1290,1320,520,0,0], [1320,1380,401,0,0]]], [190, [[1200,1260,518,0,0], [1260,1320,401,0,0], [1320,1380,78,27,0]]]], "NBC": [[0, [[1200,1230,357,1,0], [1230,1260,538,3,0], [1260,1290,265,4,0], [1290,1320,603,11,0], [1320,1380,477,13,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,514,0,0], [1320,1380,58,0,0]]], [130, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,514,0,0], [1320,1380,58,0,0]]], [150, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,514,0,0], [1320,1380,58,0,0]]], [180, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,514,0,0], [1320,1380,58,0,0]]], [190, [[1200,1230,394,0,0], [1230,1260,515,0,0], [1260,1290,359,0,0], [1290,1320,21,0,0], [1320,1380,58,0,0]]], [200, [[1200,1230,515,0,1], [1230,1260,359,0,1], [1260,1290,394,0,1], [1290,1320,514,0,1], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,543,0,0], [1260,1320,92,29,0], [1320,1380,206,0,0]]], [130, [[1200,1260,543,0,0], [1260,1320,92,29,0], [1320,1380,206,0,0]]], [150, [[1200,1260,543,0,0], [1260,1320,92,29,0], [1320,1380,206,0,0]]], [180, [[1200,1260,543,0,0], [1260,1380,424,0,0]]]], "NBC": [[96, [[1200,1260,545,0,0], [1260,1320,604,0,0], [1320,1380,366,0,0]]], [130, [[1200,1260,605,0,0], [1260,1320,366,0,0], [1320,1380,606,0,0]]], [150, [[1200,1260,566,0,0], [1260,1320,593,0,0], [1320,1380,606,0,0]]], [160, [[1200,1260,566,0,0], [1260,1320,366,0,0], [1320,1380,607,0,0]]], [180, [[1200,1260,350,0,0], [1260,1380,95,0,0]]]]},
        "SAT": {"ABC": [[96, [[1200,1260,608,0,0], [1260,1380,431,0,0]]], [110, [[1200,1320,431,0,0], [1320,1380,608,0,0]]], [130, [[1200,1260,561,0,0], [1260,1320,600,0,0], [1320,1380,608,0,0]]], [150, [[1200,1260,561,0,0], [1260,1320,600,0,0], [1320,1380,609,0,0]]], [160, [[1200,1260,600,0,0], [1260,1380,431,0,0]]], [180, [[1200,1260,600,0,0], [1260,1380,431,0,0]]]], "CBS": [[90, [[1200,1230,553,0,0], [1230,1260,507,0,1], [1260,1320,96,0,0], [1320,1380,344,0,0]]], [96, [[1200,1230,610,0,0], [1230,1260,611,0,0], [1260,1320,179,0,0], [1320,1380,344,0,0]]], [110, [[1200,1260,584,0,0], [1260,1320,179,0,0], [1320,1380,344,0,0]]], [130, [[1200,1260,612,0,0], [1260,1290,610,0,0], [1290,1320,611,0,0], [1320,1380,344,0,0]]], [140, [[1200,1260,612,0,0], [1260,1320,588,0,0], [1320,1380,344,0,0]]], [145, [[1200,1260,581,0,0], [1260,1320,588,0,0], [1320,1380,344,0,0]]], [150, [[1200,1260,602,0,0], [1260,1320,613,0,0], [1320,1380,344,0,0]]], [180, [[1200,1260,602,0,0], [1260,1320,537,0,0], [1320,1380,344,0,0]]]], "FOX": [[96, [[1200,1260,559,0,0], [1260,1320,614,0,0], [1320,1380,445,0,0]]], [130, [[1200,1260,559,0,0], [1260,1290,615,0,0], [1290,1320,614,0,0], [1320,1380,445,0,0]]], [150, [[1200,1230,615,0,0], [1230,1290,559,0,0], [1290,1320,614,0,0], [1320,1380,445,0,0]]], [180, [[1200,1230,615,0,0], [1230,1290,559,0,0], [1290,1320,614,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1200,1230,435,0,0], [1230,1260,498,25,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,19,0]]], [130, [[1200,1230,435,0,0], [1230,1260,498,25,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,19,0]]], [150, [[1200,1230,217,0,0], [1230,1260,498,25,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,19,0]]], [160, [[1200,1230,435,0,0], [1230,1260,217,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,19,0]]], [180, [[1200,1230,435,0,0], [1230,1260,498,25,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,19,0]]], [190, [[1200,1230,505,0,1], [1230,1260,498,25,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,19,0]]], [200, [[1200,1230,498,25,0], [1230,1260,617,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,19,0]]]]},
    },
    1989: {
        "SUN": {"ABC": [[96, [[1140,1200,618,0,0], [1200,1230,619,0,0], [1230,1260,620,0,0], [1260,1380,4,0,0]]], [130, [[1140,1200,618,0,0], [1200,1230,621,5,0], [1230,1260,619,0,0], [1260,1380,4,0,0]]], [140, [[1140,1200,618,0,0], [1200,1230,621,5,0], [1230,1260,622,0,0], [1260,1380,4,0,0]]], [150, [[1140,1200,618,0,0], [1200,1260,621,5,0], [1260,1380,4,0,0]]], [180, [[1140,1200,618,0,0], [1200,1230,621,5,0], [1230,1380,4,0,0]]], [190, [[1140,1200,618,0,0], [1200,1230,621,5,0], [1230,1260,359,0,0], [1260,1380,4,0,0]]], [200, [[1140,1200,618,0,0], [1200,1230,621,5,0], [1230,1260,623,0,0], [1260,1380,4,0,0]]]], "CBS": [[0, [[1140,1200,9,7,0], [1200,1260,330,13,0], [1260,1380,383,24,0]]]], "FOX": [[96, [[1140,1200,624,0,0], [1200,1230,504,0,0], [1230,1260,564,0,0], [1260,1290,441,0,0], [1290,1320,625,0,0], [1320,1350,442,0,0], [1350,1380,503,0,1]]], [130, [[1140,1200,624,0,0], [1200,1230,504,0,0], [1230,1260,626,28,0], [1260,1290,441,0,0], [1290,1320,625,0,0], [1320,1350,442,0,0], [1350,1380,503,0,1]]], [150, [[1140,1200,627,0,0], [1200,1230,504,0,0], [1230,1260,626,28,0], [1260,1290,441,0,0], [1290,1320,625,0,0], [1320,1380,624,0,0]]], [180, [[1140,1200,627,0,0], [1200,1230,504,0,0], [1230,1260,626,28,0], [1260,1290,441,0,0], [1290,1320,628,0,0], [1320,1380,624,0,0]]]], "NBC": [[96, [[1140,1200,629,0,0], [1200,1230,630,0,0], [1230,1260,505,0,0], [1260,1380,170,0,0]]], [115, [[1140,1200,565,0,0], [1200,1230,630,0,0], [1230,1260,505,0,0], [1260,1380,170,0,0]]], [130, [[1140,1200,565,0,0], [1200,1230,631,0,0], [1230,1260,630,0,0], [1260,1380,170,0,0]]], [150, [[1140,1260,565,0,0], [1260,1380,170,0,0]]], [160, [[1140,1200,565,0,0], [1200,1230,451,0,1], [1230,1260,435,0,0], [1260,1380,170,0,0]]], [180, [[1140,1260,565,0,0], [1260,1380,170,0,0]]], [200, [[1140,1170,631,0,0], [1170,1200,632,0,0], [1200,1260,565,0,0], [1260,1380,170,0,0]]]]},
        "MON": {"ABC": [[96, [[1200,1260,381,0,0], [1260,1380,20,10,0]]], [130, [[1200,1260,381,0,0], [1260,1380,22,0,0]]], [150, [[1200,1260,381,0,0], [1260,1320,528,0,0], [1320,1380,633,0,0]]], [160, [[1200,1260,634,0,0], [1260,1380,22,0,0]]], [180, [[1200,1260,381,0,0], [1260,1380,22,0,0]]]], "CBS": [[96, [[1200,1230,635,0,0], [1230,1260,636,0,0], [1260,1290,569,27,0], [1290,1320,637,0,0], [1320,1350,437,22,0], [1350,1380,223,0,0]]], [110, [[1200,1230,635,0,0], [1230,1260,637,0,0], [1260,1290,569,27,0], [1290,1320,437,22,0], [1320,1350,223,0,0], [1350,1380,573,0,0]]], [130, [[1200,1230,635,0,0], [1230,1260,638,0,0], [1260,1290,569,27,0], [1290,1320,437,22,0], [1320,1350,223,0,0], [1350,1380,573,0,0]]], [150, [[1200,1230,635,0,0], [1230,1260,638,0,0], [1260,1290,569,27,0], [1290,1320,437,22,0], [1320,1350,223,0,0], [1350,1380,639,0,0]]], [160, [[1200,1230,635,0,0], [1230,1260,223,0,0], [1260,1290,569,27,0], [1290,1320,437,22,0], [1320,1380,96,0,0]]], [180, [[1200,1230,635,0,0], [1230,1260,640,0,0], [1260,1290,569,27,0], [1290,1320,437,22,0], [1320,1350,223,0,0], [1350,1380,641,0,0]]], [190, [[1200,1230,635,0,0], [1230,1290,573,0,0], [1290,1320,437,22,0], [1320,1380,642,0,0]]]], "FOX": [[0, [[1200,1260,440,0,0], [1260,1320,643,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1200,1230,451,0,0], [1230,1260,574,0,0], [1260,1380,40,0,0]]], [130, [[1200,1230,451,0,0], [1230,1260,574,0,0], [1260,1380,40,0,0]]], [150, [[1200,1230,505,0,0], [1230,1260,574,0,0], [1260,1380,40,0,0]]], [160, [[1200,1230,505,0,0], [1230,1260,644,0,0], [1260,1320,365,24,0], [1320,1380,645,0,0]]], [180, [[1200,1230,451,0,0], [1230,1260,574,0,0], [1260,1380,40,0,0]]], [190, [[1200,1230,630,0,0], [1230,1260,644,0,0], [1260,1380,40,0,0]]]]},
        "TUE": {"ABC": [[96, [[1200,1230,337,12,0], [1230,1260,513,8,0], [1260,1290,576,1,0], [1290,1320,646,13,0], [1320,1380,512,0,0]]], [110, [[1200,1230,337,12,0], [1230,1260,513,8,0], [1260,1290,576,1,0], [1290,1320,578,18,0], [1320,1380,512,0,0]]], [130, [[1200,1230,337,12,0], [1230,1260,513,8,0], [1260,1290,576,1,0], [1290,1320,578,18,0], [1320,1380,512,0,0]]], [150, [[1200,1230,337,12,0], [1230,1260,513,8,0], [1260,1290,576,1,0], [1290,1320,578,18,0], [1320,1380,512,0,0]]], [180, [[1200,1230,337,12,0], [1230,1260,513,8,0], [1260,1290,576,1,0], [1290,1320,578,18,0], [1320,1380,512,0,0]]]], "CBS": [[96, [[1200,1260,647,0,0], [1260,1320,648,0,0], [1320,1380,649,0,0]]], [130, [[1200,1260,647,0,0], [1260,1380,396,0,0]]], [150, [[1200,1260,647,0,0], [1260,1380,396,0,0]]], [180, [[1200,1260,647,0,0], [1260,1380,396,0,0]]]], "NBC": [[96, [[1200,1260,458,20,0], [1260,1320,522,19,0], [1320,1380,582,0,0]]], [130, [[1200,1260,458,20,0], [1260,1320,522,19,0], [1320,1380,582,0,0]]], [150, [[1200,1260,458,20,0], [1260,1320,522,19,0], [1320,1380,582,0,0]]], [180, [[1200,1260,458,20,0], [1260,1320,522,19,0], [1320,1380,650,0,0]]]]},
        "WED": {"ABC": [[96, [[1200,1230,391,21,0], [1230,1260,461,26,0], [1260,1290,651,28,0], [1290,1320,577,0,0], [1320,1380,528,0,0]]], [130, [[1200,1230,391,21,0], [1230,1260,461,26,0], [1260,1290,651,28,0], [1290,1320,577,0,0], [1320,1380,528,0,0]]], [150, [[1200,1230,391,21,0], [1230,1260,461,26,0], [1260,1290,651,28,0], [1290,1320,652,0,0], [1320,1380,653,0,0]]], [160, [[1200,1230,391,21,0], [1230,1260,461,26,0], [1260,1290,651,28,0], [1290,1320,654,0,0], [1320,1380,653,0,0]]], [180, [[1200,1230,391,21,0], [1230,1260,461,26,0], [1260,1290,651,28,0], [1290,1320,577,0,0], [1320,1380,528,0,0]]]], "CBS": [[96, [[1200,1260,655,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]], [110, [[1200,1260,543,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]], [130, [[1200,1260,656,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]], [150, [[1200,1230,657,0,0], [1230,1260,640,0,0], [1260,1320,516,0,0], [1320,1380,508,0,0]]], [160, [[1200,1230,640,0,0], [1230,1260,657,0,0], [1260,1320,516,0,0], [1320,1380,96,0,0]]], [180, [[1200,1230,658,0,1], [1230,1260,657,0,0], [1260,1320,516,0,0], [1320,1380,96,0,0]]], [190, [[1200,1230,223,0,1], [1230,1260,639,0,0], [1260,1320,516,0,0], [1320,1380,659,0,0]]]], "FOX": [[190, [[1200,1260,660,0,0], [1260,1290,661,0,0], [1290,1320,311,0,0], [1320,1380,445,0,0]]], [200, [[1200,1260,440,0,1], [1260,1290,661,0,0], [1290,1320,311,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1200,1260,589,11,0], [1260,1290,307,28,0], [1290,1320,662,0,0], [1320,1380,593,0,0]]], [110, [[1200,1260,589,11,0], [1260,1290,307,28,0], [1290,1320,505,0,0], [1320,1380,593,0,0]]], [130, [[1200,1260,589,11,0], [1260,1290,307,28,0], [1290,1320,603,17,0], [1320,1380,593,0,0]]], [150, [[1200,1260,589,11,0], [1260,1290,307,28,0], [1290,1320,595,0,0], [1320,1380,593,0,0]]], [170, [[1200,1260,589,11,0], [1260,1290,307,28,0], [1290,1320,603,17,0], [1320,1380,593,0,0]]], [180, [[1200,1260,589,11,0], [1260,1290,663,0,0], [1290,1320,603,17,0], [1320,1380,593,0,0]]], [190, [[1200,1260,589,11,0], [1260,1290,307,28,0], [1290,1320,603,17,0], [1320,1380,593,0,0]]]]},
        "THU": {"ABC": [[96, [[1200,1260,561,0,0], [1260,1320,634,0,0], [1320,1380,601,0,0]]], [130, [[1200,1260,605,0,0], [1260,1320,634,0,0], [1320,1380,601,0,0]]], [150, [[1200,1260,605,0,0], [1260,1320,664,0,0], [1320,1380,601,0,0]]], [180, [[1200,1260,605,0,0], [1260,1320,664,0,0], [1320,1380,601,0,0]]]], "CBS": [[96, [[1200,1260,518,0,0], [1260,1320,665,0,0], [1320,1380,78,0,0]]], [130, [[1200,1260,518,0,0], [1260,1320,649,0,0], [1320,1380,78,0,0]]], [150, [[1200,1260,518,0,0], [1260,1320,666,0,0], [1320,1380,78,0,0]]], [160, [[1200,1260,518,0,0], [1260,1320,206,0,0], [1320,1380,78,0,0]]], [180, [[1200,1260,518,0,0], [1260,1320,508,0,1], [1320,1380,648,0,0]]], [190, [[1200,1260,518,0,0], [1260,1320,667,0,0], [1320,1380,668,0,1]]]], "FOX": [[200, [[1200,1230,626,0,1], [1230,1260,21,0,0], [1260,1320,660,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1200,1230,357,1,0], [1230,1260,538,4,0], [1260,1290,265,3,0], [1290,1320,603,17,0], [1320,1380,477,16,0]]], [130, [[1200,1230,357,1,0], [1230,1260,538,4,0], [1260,1290,265,3,0], [1290,1320,669,15,0], [1320,1380,477,16,0]]], [150, [[1200,1230,357,1,0], [1230,1260,538,4,0], [1260,1290,265,3,0], [1290,1320,670,0,0], [1320,1380,477,16,0]]], [180, [[1200,1230,357,1,0], [1230,1260,538,4,0], [1260,1290,265,3,0], [1290,1320,671,0,0], [1320,1380,477,16,0]]], [190, [[1200,1230,357,1,0], [1230,1260,538,4,0], [1260,1290,265,3,0], [1290,1320,669,15,0], [1320,1380,477,16,0]]]]},
        "FRI": {"ABC": [[96, [[1200,1230,515,22,0], [1230,1260,672,0,0], [1260,1290,394,0,0], [1290,1320,514,0,0], [1320,1380,58,0,0]]], [130, [[1200,1230,515,22,0], [1230,1260,672,0,0], [1260,1290,394,0,0], [1290,1320,514,0,0], [1320,1380,58,0,0]]], [150, [[1200,1230,515,22,0], [1230,1260,672,0,0], [1260,1290,394,0,0], [1290,1320,514,0,0], [1320,1380,58,0,0]]], [180, [[1200,1230,515,22,0], [1230,1260,672,0,0], [1260,1290,394,0,0], [1290,1320,673,0,0], [1320,1380,58,0,0]]]], "CBS": [[96, [[1200,1260,674,0,0], [1260,1320,92,0,0], [1320,1380,206,0,0]]], [130, [[1200,1260,666,0,0], [1260,1320,92,0,0], [1320,1380,206,0,0]]], [140, [[1200,1260,675,0,0], [1260,1320,92,0,0], [1320,1380,206,0,0]]], [150, [[1200,1260,21,0,0], [1260,1290,676,0,0], [1290,1320,677,0,0], [1320,1380,92,0,0]]], [160, [[1200,1230,678,0,0], [1230,1260,21,0,0], [1260,1290,676,0,0], [1290,1320,677,0,0], [1320,1380,92,0,0]]], [180, [[1200,1230,96,0,0], [1230,1260,638,0,0], [1260,1380,424,0,0]]], [190, [[1200,1260,674,0,0], [1260,1380,424,0,0]]], [200, [[1200,1230,679,0,0], [1230,1260,680,0,0], [1260,1290,223,0,1], [1290,1320,681,0,0], [1320,1380,682,0,0]]]], "NBC": [[90, [[1200,1260,683,0,0], [1260,1380,95,0,0]]], [96, [[1200,1260,683,0,0], [1260,1320,684,0,0], [1320,1380,685,0,0]]], [130, [[1200,1260,683,0,0], [1260,1320,686,0,0], [1320,1380,685,0,0]]], [140, [[1200,1260,683,0,0], [1260,1320,687,0,0], [1320,1380,685,0,0]]], [150, [[1200,1260,683,0,0], [1260,1320,687,0,0], [1320,1380,684,0,0]]], [160, [[1200,1260,685,0,0], [1260,1320,687,0,0], [1320,1380,684,0,0]]], [170, [[1200,1260,683,0,0], [1260,1320,687,0,0], [1320,1380,684,0,0]]], [180, [[1200,1260,181,0,1], [1260,1320,328,0,1], [1320,1380,582,0,1]]], [190, [[1200,1260,593,0,1], [1260,1320,645,0,1], [1320,1380,582,0,1]]], [200, [[1200,1260,593,0,1], [1260,1290,307,0,1], [1290,1320,670,0,1], [1320,1380,582,0,1]]]]},
        "SAT": {"ABC": [[96, [[1200,1230,359,0,0], [1230,1260,688,0,0], [1260,1380,689,0,0]]], [130, [[1200,1260,561,0,0], [1260,1380,689,0,0]]], [150, [[1200,1260,690,0,0], [1260,1380,689,0,0]]], [170, [[1200,1260,691,0,0], [1260,1380,689,0,0]]], [180, [[1200,1230,622,0,0], [1230,1260,21,0,0], [1260,1380,689,0,0]]], [180, [[1200,1230,692,0,0], [1230,1260,693,0,0], [1260,1380,689,0,0]]], [200, [[1200,1230,692,0,0], [1230,1260,693,0,0], [1260,1320,528,0,1], [1320,1380,664,0,1]]]], "CBS": [[96, [[1200,1260,602,0,0], [1260,1320,537,0,0], [1320,1380,642,0,0]]], [130, [[1200,1260,602,0,0], [1260,1320,537,0,0], [1320,1380,642,0,0]]], [150, [[1200,1260,602,0,0], [1260,1320,537,0,0], [1320,1380,642,0,0]]], [180, [[1200,1260,602,0,0], [1260,1320,543,0,0], [1320,1380,537,0,0]]]], "FOX": [[96, [[1200,1230,615,0,0], [1230,1290,559,0,0], [1290,1320,614,0,0], [1320,1380,445,0,0]]], [130, [[1200,1230,615,0,0], [1230,1260,564,0,0], [1260,1320,559,0,0], [1320,1380,445,0,0]]], [150, [[1200,1230,615,0,0], [1230,1260,564,0,0], [1260,1290,628,0,0], [1290,1320,442,0,0], [1320,1380,445,0,0]]], [180, [[1200,1230,615,0,0], [1230,1260,564,0,0], [1260,1290,625,0,1], [1290,1320,442,0,0], [1320,1380,445,0,0]]], [190, [[1200,1230,615,0,0], [1230,1260,564,0,0], [1260,1290,441,0,1], [1290,1320,442,0,0], [1320,1380,445,0,0]]], [200, [[1200,1260,564,0,0], [1260,1290,615,0,0], [1290,1320,442,0,0], [1320,1380,445,0,0]]]], "NBC": [[96, [[1200,1230,435,0,0], [1230,1260,498,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,24,0]]], [130, [[1200,1230,435,0,0], [1230,1260,498,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,24,0]]], [150, [[1200,1230,451,0,0], [1230,1260,498,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,24,0]]], [160, [[1200,1230,632,0,0], [1230,1260,617,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1350,694,0,0], [1350,1380,695,0,0]]], [170, [[1200,1230,617,0,0], [1230,1260,498,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1350,694,0,0], [1350,1380,695,0,0]]], [180, [[1200,1230,435,0,0], [1230,1260,498,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,24,0]]], [190, [[1200,1230,498,0,0], [1230,1260,617,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1380,365,24,0]]], [200, [[1200,1230,498,0,0], [1230,1260,617,0,0], [1260,1290,434,6,0], [1290,1320,616,9,0], [1320,1350,694,0,0], [1350,1380,21,0,0]]]]},
    },
}
