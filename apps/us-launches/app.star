# US Launches (192x32)
#
# The next three rocket launches from any US pad - Cape Canaveral, Kennedy,
# Vandenberg, Wallops, Starbase and the rest, crewed or not. Each launch gets
# two pages: the launch itself (status, rocket, mission, your local time, the
# countdown) and "can I see it?" (a verdict from your zip, a compass needle
# pointing at the pad, and when to look: the moment a typical climb, on its
# likely heading, clears your horizon). An intro page leads the set,
# drawn under the real sky over your zip - sun, moon and phase included. The
# last page lists every US launch in the next seven days.
#
# A launch that has flown keeps its slot for eight hours with its result
# (SUCCESS / FAILURE / PARTIAL), then steps aside - sooner if the next launch
# is within two hours or already live.
#
# Sources, all keyless (8 uncached requests per render across every page,
# so each launch gets one detailed request and Open-Meteo one call):
#   Launch Library 2    ll.thespacedevs.com (15 requests/hour free, so the
#                       launch list is cached 15 minutes)
#   zippopotam.us       zip -> latitude/longitude
#   Open-Meteo          the zip's time zone and 16 days of sunrise/sunset
#
# The can-I-see-it page adds your own cloud forecast for the launch hour,
# and warns of sonic booms when a booster comes home near you.
#
# Launch weather odds ("WX 80% GO") come from Launch Library's probability
# field when a launch forecast exists - for Florida, the 45th Weather
# Squadron's, issued a few days out.
#
# The countdown moves in minutes, once per refresh. Launch Library has no
# "scrubbed" flag; a hold whose reason mentions a scrub shows SCRUB, any other
# hold shows HOLD, and a new date simply replaces the old one.

INK = "#F4F7FF"
DIM = "#6E7A94"
GREEN = "#2FBF5B"
YELLOW = "#F2D04E"
AMBER = "#E8B04A"
RED = "#E5484D"
BLUE = "#3B82F6"
MAGENTA = "#D946EF"
GRAY = "#5B6770"
BLACK = "#000000"
DARK_INK = [GREEN, YELLOW, AMBER]

PAD = 6
DEFAULT_ZIP = "32920"
LL2 = "https://ll.thespacedevs.com/2.3.0/launches/upcoming/"
SHOWN = 3

# ---------- small helpers ----------

def clip(c, t, f, w):
    t = str(t)
    if c.text_width(t, f) <= w:
        return t
    for n in range(len(t), 0, -1):
        if c.text_width(t[:n], f) <= w:
            return t[:n].rstrip()
    return ""

def ascii_upper(s):
    # The bitmap fonts are ASCII only; drop anything else.
    out = ""
    for ch in str(s).upper().elems():
        if ord(ch) < 128:
            out += ch
    return out

def pad2(n):
    return ("0" if n < 10 else "") + str(n)

def sqrt(x):
    if x <= 0.0:
        return 0.0
    g = x if x > 1.0 else 1.0
    for _ in range(30):
        g = 0.5 * (g + x / g)
    return g

def sin_cos(deg):
    d = deg % 360.0
    sx = 1.0
    cx = 1.0
    if d > 180.0:
        d = 360.0 - d
        sx = -1.0
    if d > 90.0:
        d = 180.0 - d
        cx = -1.0
    x = d * 3.14159265 / 180.0
    x2 = x * x
    s = x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0 * (1.0 - x2 / 42.0)))
    c = 1.0 - x2 / 2.0 * (1.0 - x2 / 12.0 * (1.0 - x2 / 30.0))
    return [sx * s, cx * c]

def atan_deg(z):
    # |z| <= 1, polynomial good to ~0.01 degree.
    z2 = z * z
    r = z * (0.9998660 + z2 * (-0.3302995 + z2 * (0.1801410 + z2 * (-0.0851330 + z2 * 0.0208351))))
    return r * 180.0 / 3.14159265

def bearing_deg(dx, dy):
    # Compass bearing of (east, north) offset.
    if dx == 0.0 and dy == 0.0:
        return 0.0
    if abs(dy) >= abs(dx):
        a = atan_deg(dx / dy)
        b = a if dy > 0 else a + 180.0
    else:
        a = atan_deg(dy / dx)
        b = 90.0 - a if dx > 0 else 270.0 - a
    return b % 360.0

C16 = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
WORD = {"N": "NORTH", "S": "SOUTH", "E": "EAST", "W": "WEST", "NE": "NORTHEAST", "NW": "NORTHWEST", "SE": "SOUTHEAST", "SW": "SOUTHWEST"}

# ---------- calendar (UTC epoch <-> civil date) ----------

DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
MONTHS_LONG = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]

def civil(days):
    # Days since 1970-01-01 -> [year, month, day] (Howard Hinnant's algorithm).
    z = days + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + (1 if m <= 2 else 0), m, d]

def days_from_civil(y, m, d):
    y = y - (1 if m <= 2 else 0)
    era = (y if y >= 0 else y - 399) // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def weekday(days):
    return (days + 3) % 7  # 1970-01-01 was a Thursday; 0 = Monday

def parse_iso(s):
    # "2026-10-30T04:02:00Z" -> unix seconds (UTC).
    t = str(s)
    if len(t) < 19:
        return None
    d = days_from_civil(int(t[0:4]), int(t[5:7]), int(t[8:10]))
    return d * 86400 + int(t[11:13]) * 3600 + int(t[14:16]) * 60 + int(t[17:19])

# ---------- the viewer's clock (US daylight time rule) ----------

NO_DST = ["America/Phoenix", "Pacific/Honolulu", "America/Puerto_Rico", "Pacific/Guam",
          "America/St_Thomas", "Pacific/Pago_Pago", "Pacific/Saipan"]

ZONE = {-4: "A", -5: "E", -6: "C", -7: "M", -8: "P", -9: "AK", -10: "H"}

def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    return first + (6 - weekday(first)) % 7 + 7 * (n - 1)

def in_dst(unix, std):
    # US rule: 2nd Sunday of March 2:00 local standard to 1st Sunday of
    # November 2:00 local daylight.
    y = civil((unix + std) // 86400)[0]
    start = nth_sunday(y, 3, 2) * 86400 + 2 * 3600 - std
    end = nth_sunday(y, 11, 1) * 86400 + 2 * 3600 - (std + 3600)
    return unix >= start and unix < end

def zone_info(om, now):
    # [standard offset, observes DST]. Open-Meteo's offset is the one in force
    # when it answered (its "current" time), not at render time - the cache
    # can straddle a clock change - so judge DST at that moment.
    off = int(om.get("utc_offset_seconds", -5 * 3600))
    tz = str(om.get("timezone", ""))
    if tz in NO_DST:
        return [off, False]
    at = (om.get("current") or {}).get("time")
    at = int(at) if type(at) == "int" else now
    if in_dst(at, off - 3600):
        return [off - 3600, True]
    return [off, True]

def local_offset(z, unix):
    return z[0] + (3600 if z[1] and in_dst(unix, z[0]) else 0)

def zone_abbr(z, unix):
    letter = ZONE.get(z[0] // 3600, "")
    if letter == "":
        return ""
    dst = z[1] and in_dst(unix, z[0])
    return letter + ("DT" if dst else "ST")

def clock(unix, z):
    lt = unix + local_offset(z, unix)
    m = (lt // 60) % 1440
    h = m // 60
    h12 = h % 12
    return str(12 if h12 == 0 else h12) + ":" + pad2(m % 60) + ("A" if h < 12 else "P")

def day_date(unix, off):
    days = (unix + off) // 86400
    cd = civil(days)
    return DAYS[weekday(days)] + " " + pad2(cd[1]) + "/" + pad2(cd[2])

# ---------- where the viewer is ----------

def viewer(ctx):
    z = str(ctx.inputs.get("zip", DEFAULT_ZIP)).strip()
    if z == "":
        z = DEFAULT_ZIP
    if len(z) != 5 or not z.isdigit():
        return None
    r = http.get("https://api.zippopotam.us/us/" + z, ttl_seconds = 86400)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    places = r["json"].get("places") or []
    if len(places) == 0:
        return None
    lat = float(places[0]["latitude"])
    lon = float(places[0]["longitude"])
    om = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {"latitude": str(lat), "longitude": str(lon), "daily": "sunrise,sunset",
                  "current": "is_day,cloud_cover,weather_code", "hourly": "cloud_cover",
                  "timezone": "auto", "timeformat": "unixtime", "forecast_days": "16"},
        ttl_seconds = 900,
    )
    j = om["json"] if om["status_code"] == 200 and type(om["json"]) == "dict" else {}
    daily = j.get("daily") or {}
    city = ascii_upper(places[0].get("place name") or "")
    state = ascii_upper(places[0].get("state abbreviation") or "")
    return {
        "zip": z,
        "city": city,
        "state": state,
        "lat": lat,
        "lon": lon,
        "zone": zone_info(j, ctx.now.unix),
        "rise": daily.get("sunrise") or [],
        "set": daily.get("sunset") or [],
        "current": j.get("current"),
        "hourly": j.get("hourly") or {},
    }

def sky_at(v, unix):
    # "DAY", "TWILIGHT" (rocket sunlit over a dark sky - the plume glows) or
    # "NIGHT". Past the 16-day table, reuse its last day; sunset barely moves.
    rs = v["rise"]
    ss = v["set"]
    if len(rs) == 0 or len(ss) == 0:
        return "NIGHT"
    # The day whose evening (plus six hours) the launch falls before: a
    # 3 AM launch belongs to that morning, an 11 PM one to that evening.
    i = len(rs) - 1
    for k in range(len(ss)):
        if unix <= int(ss[k]) + 6 * 3600:
            i = k
            break
    shift = 0
    if unix > int(ss[len(ss) - 1]) + 6 * 3600:
        shift = ((unix - int(ss[len(ss) - 1])) // 86400) * 86400
    rise = int(rs[i]) + shift
    sett = int(ss[i]) + shift
    if unix >= rise - 20 * 60 and unix <= sett + 20 * 60:
        return "DAY"
    if (unix > sett + 20 * 60 and unix <= sett + 100 * 60) or (unix >= rise - 100 * 60 and unix < rise - 20 * 60):
        return "TWILIGHT"
    return "NIGHT"

# ---------- booster and landing ----------
# The detailed launch record names the first-stage booster, its flight count
# and where it lands. A return-to-launch-site landing near you means sonic
# booms. One request per shown launch, cached 30 minutes and shared with
# the delay check below.

def launch_detail(l):
    # The detailed record (booster, landing and the update log), or None.
    if l.get("id") == None:
        return None
    r = http.get("https://ll.thespacedevs.com/2.3.0/launches/" + str(l["id"]) + "/",
                 params = {"mode": "detailed"}, ttl_seconds = 1800)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    return r["json"]

def booster_info(l):
    if l.get("id") == None:
        return l.get("_booster")
    j = launch_detail(l)
    if j == None:
        return None
    for st in ((j.get("rocket") or {}).get("launcher_stage") or []):
        ln = st.get("launcher") or {}
        ld = st.get("landing") or {}
        loc = ld.get("landing_location") or ld.get("location") or {}
        return {"serial": str(ln.get("serial_number") or ""), "flight": st.get("launcher_flight_number"),
                "type": str((ld.get("type") or {}).get("abbrev") or ""), "site": str(loc.get("abbrev") or ""),
                "attempt": ld.get("attempt") == True}
    return None

def ordinal(n):
    n = int(n)
    suf = "TH"
    if n % 100 < 11 or n % 100 > 13:
        suf = {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")
    return str(n) + suf

def booster_line(b):
    # "B1093 18TH FLIGHT", "B1093 FIRST FLIGHT"
    if b == None or b["serial"] == "":
        return ""
    f = b["flight"]
    if type(f) != "int":
        return b["serial"]
    return b["serial"] + " " + ("FIRST FLIGHT" if f == 1 else ordinal(f) + " FLIGHT")

# ---------- delays ----------
# Launch Library logs every schedule change as an update ("Now targeting Oct
# 31 at 03:48 UTC", "Delayed to NET November 10"). When the newest target is
# later than the one before, the launch slipped. For 24 hours after that
# announcement the status chip says DELAYED; the "DELAYED FROM ..." note on
# the launch page stays until it flies. Read from the same detailed record.

MONTH_IDX = {"Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6, "Jul": 7, "Aug": 8,
             "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12}
DELAY_FRESH = 24 * 3600

def target_of(comment, created):
    # "Now targeting Oct 31 at 03:48 UTC" -> unix, or None.
    t = str(comment)
    i = t.find("targeting ")
    k = 10
    if i < 0:
        i = t.lower().find("delayed to ")
        k = 11
    if i < 0:
        return None
    w = t[i + k:].replace(",", " ").replace(".", " ").replace("NET ", "").split(" ")
    w = [x for x in w if x != ""]
    if len(w) < 2 or w[0][:3] not in MONTH_IDX or not w[1].isdigit():
        return None
    mo = MONTH_IDX[w[0][:3]]
    day = int(w[1])
    if len(str(created)) < 7:
        return None
    y = int(str(created)[:4])
    cm = int(str(created)[5:7])
    if mo < cm - 6:
        y = y + 1
    hh = 0
    mm = 0
    if len(w) >= 4 and w[2] == "at" and ":" in w[3]:
        hm = w[3].split(":")
        if hm[0].isdigit() and hm[1][:2].isdigit():
            hh = int(hm[0])
            mm = int(hm[1][:2])
    return days_from_civil(y, mo, day) * 86400 + hh * 3600 + mm * 60

def delay_info(l, now):
    # {"from": old unix, "count": slips in a row, "at": when announced,
    # "fresh": announced within 24 hours} or None.
    j = launch_detail(l)
    if j == None:
        return None
    targets = []
    for u in (j.get("updates") or [])[:10]:
        t = target_of(u.get("comment"), u.get("created_on"))
        if t != None:
            targets.append([parse_iso(u.get("created_on")) or 0, t])
    if len(targets) < 2:
        return None
    targets = sorted(targets, key = lambda x: -x[0])
    if targets[0][1] <= targets[1][1] + 600:
        return None
    count = 1
    for k in range(1, len(targets) - 1):
        if targets[k][1] > targets[k + 1][1] + 600:
            count += 1
        else:
            break
    return {"from": targets[1][1], "count": count, "at": targets[0][0],
            "fresh": now - targets[0][0] < DELAY_FRESH}

def delay_text(c, d, v, room):
    # "DELAYED FROM 10/30 12:02A", shortened to fit.
    off = local_offset(v["zone"], d["from"])
    cd = civil((d["from"] + off) // 86400)
    date = pad2(cd[1]) + "/" + pad2(cd[2])
    head = "DELAYED " + (str(d["count"]) + "X " if d["count"] > 1 else "") + "FROM "
    for o in [head + date + " " + clock(d["from"], v["zone"]), head + date, "DELAYED FROM " + date, "DELAYED"]:
        if c.text_width(o, "4x5") <= room:
            return o
    return ""

# ---------- launches ----------

SITES = [["Vandenberg", "VANDENBERG"], ["Kennedy", "KENNEDY"], ["Cape Canaveral", "CAPE CANAVERAL"],
         ["Wallops", "WALLOPS"], ["Starbase", "STARBASE"], ["Boca Chica", "STARBASE"],
         ["Kodiak", "KODIAK"], ["Spaceport America", "SPACEPORT AMERICA"], ["Mojave", "MOJAVE"]]

PROVIDERS = {"UNITED LAUNCH ALLIANCE": "ULA", "NORTHROP GRUMMAN SPACE SYSTEMS": "NORTHROP GRUMMAN",
             "NATIONAL AERONAUTICS AND SPACE ADMINISTRATION": "NASA"}

DONE = ["Success", "Failure", "Partial Failure"]

WRAPUP = 8 * 3600  # a finished launch stays this long: a west-coast night launch is still there in the morning

CLEAR_FOR_NEXT = 2 * 3600  # a result yields slot 1 this long before the next liftoff

def fetch_launches(now):
    # The next US launches, plus the most recent one that flew in the last
    # eight hours (it shows its result before stepping aside). The result
    # gives way early rather than clash with what's next: once a newer launch
    # is in flight or live, or the next one is within two hours.
    r = http.get(LL2, params = {"limit": "30", "mode": "normal", "hide_recent_previous": "false"}, ttl_seconds = 900)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    flown = None
    ahead = []
    for l in (r["json"].get("results") or []):
        pad = l.get("pad") or {}
        country = (pad.get("country") or {}).get("alpha_3_code") or ""
        loc = str((pad.get("location") or {}).get("name") or "")
        if country != "USA" and not loc.endswith(", USA"):
            continue
        t = parse_iso(l.get("net"))
        ab = (l.get("status") or {}).get("abbrev")
        if ab in DONE:
            if t == None or now - t > WRAPUP:
                continue
            if flown == None or t > (parse_iso(flown.get("net")) or 0):
                flown = l
            continue
        ahead.append(l)
    if flown != None and len(ahead) > 0:
        n = ahead[0]
        nt = parse_iso(n.get("net"))
        nab = (n.get("status") or {}).get("abbrev")
        busy = nab == "In Flight" or n.get("webcast_live") == True
        if busy or (nt != None and exact_time(n) and nt - now <= CLEAR_FOR_NEXT):
            flown = None
    out = ([flown] if flown != None else []) + ahead
    return out[:SHOWN]

def site_name(l):
    loc = str(((l.get("pad") or {}).get("location") or {}).get("name") or "")
    for s in SITES:
        if s[0] in loc:
            return s[1]
    return ascii_upper(loc.split(",")[0])

def status_of(l, now):
    # [label, color]
    st = l.get("status") or {}
    ab = str(st.get("abbrev") or "")
    hold = str(l.get("holdreason") or "").lower()
    if ab == "In Flight":
        return ["LIFTOFF", MAGENTA]
    if ab == "Success":
        return ["SUCCESS", GREEN]
    if ab == "Failure":
        return ["FAILURE", RED]
    if ab == "Partial Failure":
        return ["PARTIAL", AMBER]
    if "scrub" in hold:
        return ["SCRUB", RED]
    if ab == "Hold":
        return ["HOLD", AMBER]
    if ab == "Go" and l.get("webcast_live") == True:
        return ["LIVE", MAGENTA]
    if ab == "Go":
        return ["GO", GREEN]
    if ab == "TBC":
        return ["TBC", BLUE]
    return ["TBD", GRAY]

FINISHED = ["SUCCESS", "FAILURE", "PARTIAL"]

def shown_status(l, now):
    # The chip: DELAYED (amber) for 24 hours after a slip is announced,
    # unless something louder (live, hold, scrub, liftoff) is going on.
    st = status_of(l, now)
    if st[0] in ("GO", "TBC", "TBD"):
        d = delay_info(l, now)
        if d != None and d["fresh"]:
            return ["DELAYED", AMBER]
    return st

def precision(l):
    return str((l.get("net_precision") or {}).get("abbrev") or "")

def exact_time(l):
    return precision(l) in ("SEC", "MIN", "HR", "")

def when_text(l, v):
    t = parse_iso(l.get("net"))
    if t == None:
        return "DATE TBD"
    p = precision(l)
    if p in ("M", "Q", "Y", "H1", "H2", "Q1", "Q2", "Q3", "Q4"):
        cd = civil(t // 86400)
        return "NET " + MONTHS_LONG[cd[1] - 1] + " " + str(cd[0])
    if p == "DAY":
        return day_date(t, 0) + " TIME TBD"
    off = local_offset(v["zone"], t)
    ab = zone_abbr(v["zone"], t)
    return day_date(t, off) + " " + clock(t, v["zone"]) + (" " + ab if ab != "" else "")

# The display redraws every five minutes and then cycles its pages, so a
# number can be up to ~5 minutes old when seen. Counts are kept to what that
# allows: days+hours, then hours+minutes rounded DOWN to ten, and inside the
# last hour the liftoff clock time does the work (it never goes stale).

def soon_text(s):
    # Under an hour out: "IN 40 MIN", rounded down to five; then ANY MINUTE.
    # (The panel fonts have no "~".)
    if s <= 5 * 60:
        return "ANY MINUTE"
    return "IN " + str((s // 60) // 5 * 5) + " MIN"

def ago_text(s):
    m = max(0, s) // 60
    if m < 60:
        return "JUST NOW" if m < 5 else str(m // 5 * 5) + " MIN AGO"
    h = m // 60
    return str(h) + (" HR AGO" if h == 1 else " HRS AGO")

def countdown(l, now, status):
    # The launch page's right-hand count.
    t = parse_iso(l.get("net"))
    if t == None:
        return "TBD"
    p = precision(l)
    if p in ("M", "Q", "Y", "H1", "H2", "Q1", "Q2", "Q3", "Q4"):
        return "NET " + MONTHS[civil(t // 86400)[1] - 1]
    s = t - now
    if status in FINISHED:
        return ago_text(-s)
    if status == "LIFTOFF":
        return "IN FLIGHT"
    if status == "SCRUB":
        return "NEW TIME TBD"
    if status == "HOLD":
        return "HOLDING"
    if p == "DAY":
        d = s // 86400
        return "T-" + str(max(d, 0)) + (" DAY" if d == 1 else " DAYS")
    if s < 3600:
        return soon_text(s)
    d = s // 86400
    h = (s % 86400) // 3600
    m = (s % 3600) // 60 // 10 * 10
    if d > 0:
        return "T-" + str(d) + "D " + str(h) + "H"
    return "T-" + str(h) + "H " + pad2(m) + "M"

def weather_odds(l):
    # ["WX 80% GO", color] from Launch Library's probability, or None.
    p = l.get("probability")
    if type(p) != "int" or p < 0 or p > 100:
        return None
    col = GREEN if p >= 70 else (YELLOW if p >= 40 else RED)
    return ["WX " + str(p) + "% GO", col]

def window_text(l):
    a = parse_iso(l.get("window_start"))
    b = parse_iso(l.get("window_end"))
    if a == None or b == None or not exact_time(l):
        return ""
    m = (b - a) // 60
    if m <= 0:
        return "EXACT WINDOW"  # instantaneous: that minute or not today
    if m >= 60:
        return str(m // 60) + " HR WINDOW"
    return str(m) + " MIN WINDOW"

def provider(l):
    p = ascii_upper((l.get("launch_service_provider") or {}).get("name") or "")
    return PROVIDERS.get(p, p)

def rocket(l):
    n = ascii_upper((((l.get("rocket") or {}).get("configuration") or {}).get("name")) or "")
    return n.replace(" BLOCK 5", "")

def mission(l):
    m = (l.get("mission") or {}).get("name")
    if m == None or m == "":
        m = str(l.get("name") or "").split("|")[-1]
    return ascii_upper(m).strip().replace("STARLINK GROUP", "STARLINK")

# ---------- sun and moon (for the intro's live sky) ----------
# Low-precision solar position and Meeus's abbreviated lunar theory, the
# same terms Where in the Sky uses: a few arcminutes, far finer than a pixel.

def norm360(x):
    x = math.fmod(x, 360.0)
    return x + 360.0 if x < 0.0 else x

def ecl_to_radec(lon, lat, t):
    eps = math.radians(23.439291 - 0.0130042 * t)
    lr = math.radians(lon)
    br = math.radians(lat)
    x = math.cos(br) * math.cos(lr)
    y = math.cos(br) * math.sin(lr) * math.cos(eps) - math.sin(br) * math.sin(eps)
    z = math.cos(br) * math.sin(lr) * math.sin(eps) + math.sin(br) * math.cos(eps)
    return [norm360(math.degrees(math.atan2(y, x))), math.degrees(math.asin(max(-1.0, min(1.0, z))))]

def sun_lon(t):
    l0 = 280.46646 + 36000.76983 * t
    m = math.radians(357.52911 + 35999.05029 * t)
    return norm360(l0 + 1.9146 * math.sin(m) + 0.0200 * math.sin(2.0 * m))

def moon_lonlat(t):
    lp = 218.3164477 + 481267.88123421 * t
    m = math.radians(134.9633964 + 477198.8675055 * t)
    ms = math.radians(357.5291092 + 35999.0502909 * t)
    d = math.radians(297.8501921 + 445267.1114034 * t)
    f = math.radians(93.2720950 + 483202.0175233 * t)
    lon = lp + 6.289 * math.sin(m) - 1.274 * math.sin(m - 2.0 * d) + 0.658 * math.sin(2.0 * d) - \
        0.186 * math.sin(ms) - 0.059 * math.sin(2.0 * m - 2.0 * d) - 0.057 * math.sin(m - 2.0 * d + ms) + \
        0.053 * math.sin(m + 2.0 * d) + 0.046 * math.sin(2.0 * d - ms) + 0.041 * math.sin(m - ms) - \
        0.035 * math.sin(d) - 0.031 * math.sin(m + ms) - 0.015 * math.sin(2.0 * f - 2.0 * d) + \
        0.011 * math.sin(m - 4.0 * d)
    lat = 5.128 * math.sin(f) + 0.281 * math.sin(m + f) + 0.278 * math.sin(m - f) + \
        0.173 * math.sin(2.0 * d - f) + 0.055 * math.sin(2.0 * d - m + f) + \
        0.046 * math.sin(2.0 * d - m - f) + 0.033 * math.sin(2.0 * d + f) + 0.017 * math.sin(2.0 * m + f)
    return [norm360(lon), lat]

def alt_az(radec, lat, lon, jd):
    gmst = norm360(280.46061837 + 360.98564736629 * (jd - 2451545.0))
    ha = math.radians(norm360(gmst + lon - radec[0]))
    dec = math.radians(radec[1])
    la = math.radians(lat)
    sa = math.sin(dec) * math.sin(la) + math.cos(dec) * math.cos(la) * math.cos(ha)
    alt = math.asin(max(-1.0, min(1.0, sa)))
    ca = (math.sin(dec) - math.sin(alt) * math.sin(la)) / max(1e-9, math.cos(alt) * math.cos(la))
    az = math.degrees(math.acos(max(-1.0, min(1.0, ca))))
    if math.sin(ha) > 0.0:
        az = 360.0 - az
    return [math.degrees(alt), az]

def sky_now(lat, lon, unix):
    # Sun and moon altitude/azimuth, moon illumination and waxing.
    jd = float(unix) / 86400.0 + 2440587.5
    t = (jd - 2451545.0) / 36525.0
    sl = sun_lon(t)
    ml = moon_lonlat(t)
    sun = alt_az(ecl_to_radec(sl, 0.0, t), lat, lon, jd)
    moon = alt_az(ecl_to_radec(ml[0], ml[1], t), lat, lon, jd)
    elong = norm360(ml[0] - sl)
    cos_e = math.cos(math.radians(ml[1])) * math.cos(math.radians(elong))
    return {"sun_alt": sun[0], "sun_az": sun[1], "moon_alt": moon[0], "moon_az": moon[1],
            "illum": (1.0 - cos_e) / 2.0, "waxing": elong < 180.0}

# ---------- likely heading ----------
# Launch Library gives the orbit type and a mission blurb, not the launch
# azimuth, so the direction is an educated guess from pad + orbit + mission:
# [compass degrees, words] or None when it could go either way.

STATION_WORDS = ["iss", "space station", "dragon", "cygnus", "crew-", "crs", "starliner", "axiom", "dream chaser"]

def likely_heading(l):
    site = site_name(l)
    orbit = str((((l.get("mission") or {}).get("orbit")) or {}).get("abbrev") or "")
    text = (str((l.get("mission") or {}).get("name") or "") + " " +
            str((l.get("mission") or {}).get("description") or "")).lower()
    station = False
    for w in STATION_WORDS:
        if w in text:
            station = True
    if site in ("CAPE CANAVERAL", "KENNEDY"):
        if station or orbit == "ISS":
            return [44.0, "NE"]
        if orbit in ("GTO", "GEO", "GSO", "TLI", "Lunar", "Helio-N", "HEO", "Heliocentric N/A"):
            return [90.0, "E"]
        if orbit in ("MEO",):
            return [45.0, "NE"]
        if orbit in ("SSO", "PO"):
            return [160.0, "SSE"]
        return None
    if site == "VANDENBERG":
        if orbit in ("SSO", "PO", "LEO"):
            return [190.0, "S"]
        return None
    if site == "WALLOPS":
        if station or orbit == "ISS":
            return [130.0, "SE"]
        return None
    if site == "STARBASE":
        return [95.0, "E"]
    return None

def angle_between(a, b):
    d = abs((a - b) % 360.0)
    return 360.0 - d if d > 180.0 else d

# ---------- can I see it? ----------

# ---------- when does it clear your horizon? ----------
# A typical orbital climb (Falcon 9 to low orbit, close enough for the
# others): [seconds after liftoff, altitude km, downrange km], through
# second-stage cutoff. The rocket is in view once it stands at least one
# degree above your horizon, with the Earth's curve (and normal refraction,
# a 4/3 Earth radius) between you and it.

ASCENT = [[0, 0.0, 0.0], [30, 2.0, 0.0], [60, 9.0, 2.0], [90, 20.0, 8.0], [120, 40.0, 25.0],
          [150, 65.0, 55.0], [180, 90.0, 100.0], [210, 110.0, 155.0], [240, 125.0, 215.0],
          [300, 150.0, 350.0], [360, 165.0, 500.0], [420, 175.0, 670.0], [480, 185.0, 860.0],
          [540, 195.0, 1080.0]]
EARTH_R43 = 6371.0 * 4.0 / 3.0
MIN_ELEV = 1.0

def ascent_at(t):
    for i in range(len(ASCENT) - 1):
        a = ASCENT[i]
        b = ASCENT[i + 1]
        if t >= a[0] and t <= b[0]:
            f = float(t - a[0]) / float(b[0] - a[0])
            return [a[1] + f * (b[1] - a[1]), a[2] + f * (b[2] - a[2])]
    last = ASCENT[len(ASCENT) - 1]
    return [last[1], last[2]]

def sky_track(l, v):
    # {first: seconds or None, peak: max elevation deg, dir: compass word at
    # first sight}. With no heading guess the climb is taken as straight up,
    # the cautious case.
    pad = l.get("pad") or {}
    plat = float(pad.get("latitude") or 0)
    plon = float(pad.get("longitude") or 0)
    k = math.cos(math.radians((plat + v["lat"]) / 2.0))
    vx = (v["lon"] - plon) * 111.32 * k
    vy = (v["lat"] - plat) * 111.32
    hd = likely_heading(l)
    sx = math.sin(math.radians(hd[0])) if hd != None else 0.0
    cy = math.cos(math.radians(hd[0])) if hd != None else 0.0
    first = None
    look = ""
    peak = -90.0
    for t in range(0, ASCENT[len(ASCENT) - 1][0] + 1, 10):
        ad = ascent_at(t)
        rx = ad[1] * sx
        ry = ad[1] * cy
        dx = rx - vx
        dy = ry - vy
        d = math.sqrt(dx * dx + dy * dy)
        if d < 0.5:
            d = 0.5
        el = math.degrees(math.atan2(ad[0] - d * d / (2.0 * EARTH_R43), d))
        if el > peak:
            peak = el
        if el >= MIN_ELEV and first == None:
            first = t
            look = C16[int((bearing_deg(dx, dy) + 11.25) % 360.0 / 22.5)]
    return {"first": first, "peak": peak, "dir": look}

def mmss(sec):
    return str(sec // 60) + ":" + pad2(sec % 60)

def visibility(l, v, now):
    # {verdict, color, detail, tip, bearing}. Daylight needs the rocket
    # close; after dark (or in twilight, when the plume glows) the climb
    # model decides whether and when it clears your horizon.
    pad = l.get("pad") or {}
    plat = float(pad.get("latitude") or 0)
    plon = float(pad.get("longitude") or 0)
    k = sin_cos(90.0 - (v["lat"] + plat) / 2.0)[0]  # cos(mid-latitude)
    dy = (plat - v["lat"]) * 69.0
    dx = (plon - v["lon"]) * 69.0 * k
    miles = sqrt(dx * dx + dy * dy)
    brg = bearing_deg(dx, dy)
    pt = C16[int((brg + 11.25) % 360.0 / 22.5)]
    dist = str(int(miles + 0.5)) if miles < 1000 else str(int(miles + 0.5) // 1000) + "," + pad2(int(miles + 0.5) % 1000 // 10) + str(int(miles + 0.5) % 10)
    where = dist + " MI " + pt
    out = {"bearing": brg, "detail": where}
    t = parse_iso(l.get("net"))

    if miles <= 60:
        out.update({"verdict": "YOU WILL SEE IT", "color": GREEN, "tip": "LOOK " + WORD.get(pt, pt) + " AT LIFTOFF"})
        if t != None and exact_time(l):
            out["detail"] = where + ", " + sky_at(v, t)
        return out
    if t == None or not exact_time(l):
        if miles <= 800:
            out.update({"verdict": "DEPENDS ON TIME", "color": DIM, "tip": "LAUNCH TIME NOT SET YET"})
        else:
            out.update({"verdict": "NOT VISIBLE", "color": DIM, "tip": "TOO FAR FROM " + v["zip"]})
        return out

    sky = sky_at(v, t)
    tr = sky_track(l, v)
    if tr["first"] == None:
        out.update({"verdict": "NOT VISIBLE", "color": DIM, "detail": where + (", DAYTIME" if sky == "DAY" else ""),
                    "tip": "STAYS BELOW YOUR HORIZON"})
        return out
    when = "LOOK " + tr["dir"] + " AT " + clock(t + tr["first"], v["zone"]) + "  T+" + mmss(tr["first"])
    if sky == "DAY":
        if miles <= 150:
            out.update({"verdict": "MAYBE - LOW IN " + tr["dir"], "color": YELLOW, "detail": where + ", DAYTIME", "tip": when})
        else:
            out.update({"verdict": "NOT VISIBLE", "color": DIM, "detail": where + ", DAYTIME", "tip": "TOO FAR FOR A DAY LAUNCH"})
        return out
    if tr["peak"] >= 5.0:
        out.update({"verdict": "LIKELY - LOOK " + tr["dir"], "color": GREEN, "detail": where + ", " + sky, "tip": when})
    else:
        out.update({"verdict": "MAYBE - LOW IN " + tr["dir"], "color": YELLOW, "detail": where + ", " + sky, "tip": when})
    return out

# 7x7 weather icons, one bitmap per color layer ("#" = lit).
SUN_C = "#F2C14E"
MOON_C = "#C9D3E6"
CLOUD_C = "#9AA4B8"
RAIN_C = "#4F9BFF"
SNOW_C = "#FFFFFF"
BOLT_C = "#F2D04E"

ICON_ART = {
    "sun": [[SUN_C, ["#..#..#", ".#####.", ".#####.", "#######", ".#####.", ".#####.", "#..#..#"]]],
    "moon": [[MOON_C, ["..###..", ".##....", "##.....", "##.....", "##.....", ".##....", "..###.."]]],
    "partly": [[SUN_C, ["..#....", ".###...", "####...", ".#.....", ".......", ".......", "......."]],
               [CLOUD_C, [".......", "....##.", "...####", "..#####", ".######", "#######", "......."]]],
    "partly_night": [[MOON_C, [".##....", "##.....", "#......", "#......", ".......", ".......", "......."]],
                     [CLOUD_C, [".......", "....##.", "...####", "..#####", ".######", "#######", "......."]]],
    "cloud": [[CLOUD_C, [".......", "..##...", ".####..", ".#####.", "#######", "#######", "......."]]],
    "rain": [[CLOUD_C, ["..##...", ".####..", "#######", "#######", ".......", ".......", "......."]],
             [RAIN_C, [".......", ".......", ".......", ".......", ".#..#..", "#..#..#", "..#..#."]]],
    "snow": [[CLOUD_C, ["..##...", ".####..", "#######", "#######", ".......", ".......", "......."]],
             [SNOW_C, [".......", ".......", ".......", ".......", "#.#.#..", ".......", ".#.#.#."]]],
    "storm": [[CLOUD_C, ["..##...", ".####..", "#######", "#######", ".......", ".......", "......."]],
              [BOLT_C, [".......", ".......", ".......", "...#...", "..##...", "...##..", "...#..."]]],
    "fog": [[CLOUD_C, [".......", "######.", ".......", ".######", ".......", "######.", "......."]]],
}

def draw_icon(c, name, x, y):
    for layer in ICON_ART.get(name, []):
        rows = []
        for line in layer[1]:
            rows.append([1 if ch == "#" else 0 for ch in line.elems()])
        c.bitmap(rows, x, y, layer[0])

# ---------- your sky at launch time ----------
# Open-Meteo's hourly cloud-cover forecast for the zip (16 days out), read at
# the launch hour. Heavy cloud knocks a LIKELY down to MAYBE.

def clouds_at(v, t):
    if t == None:
        return None
    h = v["hourly"]
    times = h.get("time") or []
    cover = h.get("cloud_cover") or []
    hour = (t // 3600) * 3600
    for i in range(len(times)):
        if int(times[i]) == hour and i < len(cover) and cover[i] != None:
            return int(cover[i])
    return None

def draw_cloud_tag(c, pct, right, y, day):
    # Icon + percent at the right end of a row: clear / partly / cloudy.
    name = "sun" if day else "moon"
    if pct >= 70:
        name = "cloud"
    elif pct >= 30:
        name = "partly" if day else "partly_night"
    txt = "CLEAR" if pct < 15 else str(pct) + "%"
    col = GREEN if pct < 30 else (YELLOW if pct < 70 else AMBER)
    tw = c.text_width(txt, "4x5")
    c.text(txt, right, y + 1, font = "4x5", color = col, align = "right")
    draw_icon(c, name, right - tw - 9, y)
    return tw + 10

# ---------- page chrome ----------

QMARK = ["##.", "..#", ".#.", "...", ".#."]

def qmark(c, x, y, color):
    # The 4x5 font has no "?": three columns by five rows at cap height.
    for row in range(5):
        for col in range(3):
            if QMARK[row][col] == "#":
                c.pixel(x + col, y + row, color)

def chip(c, label, color, x = PAD):
    # Status pill, 9px tall (rows 0-8): plain 5x7 on the status color, black
    # on the light ones, white on red/magenta/blue/gray.
    w = c.text_width(label, "5x7") + 4
    c.round_rect(x, 0, x + w - 1, 8, 1, fill = color)
    c.text(label, x + 2, 1, font = "5x7", color = BLACK if color in DARK_INK else "white")
    return x + w + 3

def message(c, l1, l2, color):
    w = c.width - 2 * PAD
    c.text(clip(c, l1, "5x7", w), c.width // 2, 11, font = "5x7", color = color, align = "center")
    c.text(clip(c, l2, "4x5", w), c.width // 2, 22, font = "4x5", color = DIM, align = "center")

def setup(c, ctx, i):
    # [viewer, launch] or None after drawing why not.
    c.clear()
    v = viewer(ctx)
    if v == None:
        message(c, "ZIP CODE NOT FOUND", "CHECK THE ZIP SETTING", AMBER)
        return None
    ls = fetch_launches(ctx.now.unix)
    if ls == None:
        message(c, "LAUNCH DATA OFFLINE", "TRYING AGAIN SOON", AMBER)
        return None
    if i >= len(ls):
        message(c, "NO LAUNCH #" + str(i + 1) + " YET", "NOTHING ELSE SCHEDULED FROM US PADS", DIM)
        return None
    return [v, ls[i], len(ls)]

# ---------- pages ----------

def launch_page(c, ctx, i):
    got = setup(c, ctx, i)
    if got == None:
        return
    v = got[0]
    l = got[1]
    now = ctx.now.unix
    st = shown_status(l, now)
    right = c.width - PAD - 1
    x = chip(c, st[0], st[1])
    tag = str(i + 1) + "/" + str(got[2])
    c.text(tag, right, 2, font = "4x5", color = DIM, align = "right")
    room = right - x - c.text_width(tag, "4x5") - 4
    top = rocket(l) + "  " + site_name(l)
    if c.text_width(top, "4x5") > room:
        top = rocket(l)
    c.text(clip(c, top, "4x5", room), x, 2, font = "4x5", color = INK)
    c.text(clip(c, mission(l), "5x7", right - PAD), PAD, 9, font = "5x7", color = INK)

    cd = countdown(l, now, st[0])
    cdc = INK if st[0] in ("TBD", "TBC") else st[1]
    cw = c.text_width(cd, "5x7")
    c.text(cd, right, 17, font = "5x7", color = cdc, align = "right")
    # The time takes what the countdown leaves, with a clear 8px gap.
    room = right - cw - 8 - PAD
    when = when_text(l, v)
    if c.text_width(when, "5x7") <= room:
        c.text(when, PAD, 17, font = "5x7", color = DIM)
    else:
        c.text(clip(c, when, "4x5", room), PAD, 18, font = "4x5", color = DIM)

    # Bottom row: provider, launch-weather odds when a forecast exists (the
    # 45th Weather Squadron's for Florida, a few days out), then the window.
    win = window_text(l)
    c.text(win, right, 26, font = "4x5", color = DIM, align = "right")
    room = right - PAD - (c.text_width(win, "4x5") + 8 if win != "" else 0)
    wx = weather_odds(l)
    x = PAD
    if wx != None:
        ww = c.text_width(wx[0], "4x5")
        if ww <= room:
            c.text(wx[0], PAD, 26, font = "4x5", color = wx[1])
            x = PAD + ww + 8
            room = room - ww - 8
    # A recent slip takes the provider's place: "DELAYED FROM 10/30 12:02A".
    dl = delay_info(l, now) if st[0] not in FINISHED else None
    if dl != None:
        txt = delay_text(c, dl, v, room)
        if win != "" and not txt.startswith("DELAYED FROM") and " FROM " not in txt:
            # The window gives way before the delay loses its "FROM" date.
            wide = delay_text(c, dl, v, right - x)
            if " FROM " in wide:
                c.rect(right - c.text_width(win, "4x5"), 26, right, 31, fill = "#000000")
                txt = wide
        if txt != "":
            c.text(txt, x, 26, font = "4x5", color = AMBER)
    elif room > 12:
        bl = booster_line(booster_info(l))
        if bl != "" and c.text_width(bl, "4x5") <= room:
            c.text(bl, x, 26, font = "4x5", color = "#7FC8E8")
        else:
            c.text(clip(c, provider(l), "4x5", room), x, 26, font = "4x5", color = DIM)

def see_page(c, ctx, i):
    got = setup(c, ctx, i)
    if got == None:
        return
    v = got[0]
    l = got[1]
    now = ctx.now.unix
    st = shown_status(l, now)
    right = c.width - PAD - 1
    x = chip(c, st[0], st[1])
    c.text("CAN I SEE IT", x, 2, font = "4x5", color = INK)
    qmark(c, x + c.text_width("CAN I SEE IT", "4x5") + 1, 2, INK)
    # Where you're looking from: "CITY, ST", then the city alone, then the zip.
    room = right - (x + c.text_width("CAN I SEE IT", "4x5") + 4) - 6
    here = v["zip"]
    for o in [v["city"] + ", " + v["state"], v["city"]]:
        if o.strip(", ") != "" and c.text_width(o, "4x5") <= room:
            here = o
            break
    c.text(here, right, 2, font = "4x5", color = DIM, align = "right")

    vis = visibility(l, v, now)
    if st[0] in FINISHED:
        # Nothing left to look for: say what happened and when.
        t = parse_iso(l.get("net"))
        vis["verdict"] = "ALREADY LAUNCHED"
        vis["color"] = st[1]
        vis["tip"] = "LIFTOFF " + clock(t, v["zone"]) + ", " + st[0]
    cx = PAD + 11
    cy = 20
    rad = 10
    c.circle(cx, cy, rad, "#3A4256")
    c.pixel(cx, cy - rad, INK)
    sc = sin_cos(vis["bearing"])
    tx = cx + int(sc[0] * (rad - 2) + (0.5 if sc[0] >= 0 else -0.5))
    ty = cy - int(sc[1] * (rad - 2) + (0.5 if sc[1] >= 0 else -0.5))
    c.line(cx, cy, tx, ty, vis["color"])
    c.fill_circle(tx, ty, 1, vis["color"])
    c.pixel(cx, cy, INK)

    x2 = cx + rad + 6
    t = parse_iso(l.get("net"))
    tag = 0
    if st[0] not in FINISHED and exact_time(l) and vis["color"] != DIM:
        pct = clouds_at(v, t)
        if pct != None:
            if pct >= 70 and vis["verdict"].startswith("LIKELY"):
                vis["verdict"] = vis["verdict"].replace("LIKELY", "MAYBE")
                vis["color"] = YELLOW
            tag = draw_cloud_tag(c, pct, right, 18, sky_at(v, t) == "DAY")
    # A booster coming home near you: sonic booms (they're loud).
    b = booster_info(l) if st[0] not in FINISHED else None
    if b != None and b["attempt"] and b["type"] == "RTLS":
        pad = l.get("pad") or {}
        k = math.cos(math.radians(v["lat"]))
        dy = (float(pad.get("latitude") or 0) - v["lat"]) * 69.0
        dx = (float(pad.get("longitude") or 0) - v["lon"]) * 69.0 * k
        dmi = math.sqrt(dx * dx + dy * dy)
        if dmi <= 75.0:
            vis["tip"] = "BOOSTER TO " + (b["site"] if b["site"] != "" else "THE CAPE") + ": SONIC BOOMS"
    c.text(clip(c, vis["verdict"], "5x7", right - x2), x2, 9, font = "5x7", color = vis["color"])
    c.text(clip(c, vis["detail"], "4x5", right - x2 - tag), x2, 19, font = "4x5", color = INK)
    c.text(clip(c, vis["tip"], "4x5", right - x2), x2, 26, font = "4x5", color = DIM if "BOOM" not in vis["tip"] else AMBER)

# ---------- page 8: this week ----------

SITE_CODES = {"CAPE CANAVERAL": "CCSFS", "KENNEDY": "KSC", "VANDENBERG": "VSFB", "WALLOPS": "WALLOPS",
              "STARBASE": "STARBASE", "KODIAK": "KODIAK"}
ROCKET_SHORT = [["Falcon Heavy", "FH"], ["Falcon 9", "F9"], ["Vulcan", "VULCAN"], ["Atlas V", "ATLAS"],
                ["Starship", "STARSHIP"], ["New Glenn", "NG"], ["Electron", "ELECTRON"]]

def rocket_short(l):
    n = str((((l.get("rocket") or {}).get("configuration") or {}).get("name")) or "")
    for r in ROCKET_SHORT:
        if r[0] in n:
            return r[1]
    return ascii_upper(n.split(" ")[0])

def week(c, ctx):
    # Every US launch in the next seven days, four to a page: day and your
    # time, rocket, mission, pad, with a status dot.
    c.clear()
    v = viewer(ctx)
    if v == None:
        return message(c, "ZIP CODE NOT FOUND", "CHECK THE ZIP SETTING", AMBER)
    now = ctx.now.unix
    ls = week_launches(now)
    if ls == None:
        return message(c, "LAUNCH DATA OFFLINE", "TRYING AGAIN SOON", AMBER)
    shown = [x.get("id") for x in (fetch_launches(now) or [])]
    right = c.width - PAD - 1
    c.text("THIS WEEK", PAD, 1, font = "5x7", color = INK)
    n = len(ls)
    head = (str(n) + " US LAUNCH" + ("" if n == 1 else "ES")) if n <= 4 else ("4 OF " + str(n) + " US LAUNCHES")
    c.text(head, right, 2, font = "4x5", color = DIM, align = "right")
    if n == 0:
        return message(c, "NO US LAUNCHES", "IN THE NEXT 7 DAYS", DIM)
    rows = ls[:4]
    # Columns sized to this week's rows: when, rocket, mission, pad.
    ww = 0
    rw = 0
    sw = 0
    for l in rows:
        rw = max(rw, c.text_width(rocket_short(l), "4x5"))
        sw = max(sw, c.text_width(SITE_CODES.get(site_name(l), site_name(l)), "4x5"))
    ww = c.text_width("WED 12:00P", "4x5")
    rx = PAD + 5 + ww + 4
    mx = rx + rw + 4
    mroom = right - sw - 4 - mx
    y = 9
    for l in rows:
        t = parse_iso(l.get("net"))
        st = shown_status(l, now) if l.get("id") in shown else status_of(l, now)
        c.fill_circle(PAD + 1, y + 2, 1, st[1])
        if exact_time(l):
            when = day_date(t, local_offset(v["zone"], t))[:3] + " " + clock(t, v["zone"])
        else:
            when = day_date(t, 0)[:3] + " TBD"
        c.text(when, PAD + 5, y, font = "4x5", color = DIM)
        c.text(rocket_short(l), rx, y, font = "4x5", color = INK)
        ms = mission(l).replace("STARLINK ", "SL ").replace("AMAZON LEO", "AMZN")
        c.text(clip(c, ms, "4x5", mroom), mx, y, font = "4x5", color = INK)
        c.text(SITE_CODES.get(site_name(l), site_name(l)), right, y, font = "4x5", color = DIM, align = "right")
        y += 6

def week_launches(now):
    r = http.get(LL2, params = {"limit": "30", "mode": "normal", "hide_recent_previous": "false"}, ttl_seconds = 900)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    out = []
    for l in (r["json"].get("results") or []):
        pad = l.get("pad") or {}
        if ((pad.get("country") or {}).get("alpha_3_code") or "") != "USA":
            continue
        if (l.get("status") or {}).get("abbrev") in DONE:
            continue
        t = parse_iso(l.get("net"))
        if t == None or t - now > 7 * 86400:
            continue
        out.append(l)
    return out

def launch1(c, ctx):
    launch_page(c, ctx, 0)

def see1(c, ctx):
    see_page(c, ctx, 0)

def launch2(c, ctx):
    launch_page(c, ctx, 1)

def see2(c, ctx):
    see_page(c, ctx, 1)

def launch3(c, ctx):
    launch_page(c, ctx, 2)

def see3(c, ctx):
    see_page(c, ctx, 2)

# ---------- intro: a launch under the real sky ----------
# The sky over your zip right now: its color follows the sun's altitude,
# and the sun and moon (in its real phase) sit where they are, east on the
# left of the scene, south in the middle, west on the right. The sunlit
# "jellyfish" plume only shows at twilight, when it really happens.

STARS = [[121, 2], [127, 8], [134, 3], [141, 12], [150, 5], [189, 9], [184, 15], [124, 17], [131, 21], [188, 22],
         [114, 4], [60, 3], [88, 1], [30, 2], [100, 9], [12, 1]]

PAD_X = 150
PAD_Y = 26
TIP_X = 172
TIP_Y = 9
SCENE_L = 128  # just past the end of the title
SCENE_R = 191
HORIZON = 27

def sky_palette(alt):
    # [top, mid, horizon band top, band bottom, water, stars?]
    if alt > 10:
        return ["#1C4F9C", "#4C8ED6", "#9CCBF0", "#BFE0F7", "#1A4A78", False]
    if alt > 0:
        return ["#22447E", "#6C7FB8", "#E7A55A", "#F6C46E", "#24395C", False]
    if alt > -6:
        return ["#170F45", "#6B2A50", "#A84A2E", "#E0782C", "#0A0E1C", True]
    if alt > -12:
        return ["#0A0B2E", "#2A1A52", "#4A2A4E", "#6A3A3E", "#060812", True]
    return ["#02030C", "#070A22", "#0B1030", "#0E1436", "#03050C", True]

def sky_x(az):
    # True compass layout: east at the scene's left edge, south in the
    # middle, west at the right. The sun and moon pass behind the tower and
    # the climbing rocket just as they would from the beach.
    if az < 75 or az > 285:
        return None
    return int(SCENE_L + (az - 90.0) / 180.0 * (SCENE_R - SCENE_L) + 0.5)

def sky_y(alt):
    if alt < -1:
        return None
    # The top of the scene is 40 degrees up, so a midday sun reads as
    # midday in every season (late-autumn noon is only ~40 deg in the
    # middle of the US); anything higher pins near the top edge.
    a = min(alt, 40.0)
    return int(HORIZON - a / 40.0 * (HORIZON - 4) + 0.5)

def draw_sun(c, x, y, alt):
    col = "#FFF2B0" if alt > 10 else "#FFC060"
    halo = "#FFE58A" if alt > 10 else "#F08A3A"
    c.fill_circle(x, y, 4, halo)
    c.fill_circle(x, y, 3, col)
    c.fill_circle(x, y, 2, "#FFFFFF" if alt > 10 else "#FFE0A0")

def draw_moon(c, x, y, illum, waxing, faded):
    # Row by row: the terminator sits at h * (1 - 2 * illum) from center,
    # lit side on the right while waxing (as seen from the US).
    r = 4
    for dy in range(-r, r + 1):
        h = 0
        for k in range(r + 1):
            if k * k + dy * dy <= r * r + 1:
                h = k
        xt = h * (1.0 - 2.0 * illum)
        for dx in range(-h, h + 1):
            lit = dx >= xt if waxing else dx <= -xt
            if lit:
                c.pixel(x + dx, y + dy, "#D8E2F2" if faded else "#EEF2FA")
            elif not faded:
                c.pixel(x + dx, y + dy, "#262C40")

def intro(c, ctx):
    # Normal days: the climbing rocket and "NEXT:" strip. Within 24 hours of
    # a US launch (or while one is live) the page becomes the launch-day
    # board: big countdown, the real rocket standing on the pad, and the
    # can-I-see-it verdict. Either way it sits under the live sky and the
    # zip's current weather.
    c.clear()
    w = c.width
    now = ctx.now.unix
    v = viewer(ctx)
    sk = sky_now(v["lat"], v["lon"], now) if v != None else \
        {"sun_alt": -4.0, "sun_az": 250.0, "moon_alt": -10.0, "moon_az": 0.0, "illum": 0.5, "waxing": True}
    kind = weather_kind(v) if v != None else "clear"
    ls = fetch_launches(now) or []
    flown = None
    upcoming = []
    for l in ls:
        if status_of(l, now)[0] in FINISHED:
            if flown == None:
                flown = l
        else:
            upcoming.append(l)
    nxt = upcoming[0] if len(upcoming) > 0 else None
    st = shown_status(nxt, now) if nxt != None else None
    launch_day = nxt != None and v != None and is_launch_day(nxt, now, st[0])
    # An upcoming launch day (or one that's live) outranks the wrap-up on the
    # intro; the result still holds its slot on the launch pages.
    wrapup = flown != None and v != None and not launch_day

    sun_alt = sk["sun_alt"]
    day = sun_alt > 0
    pal = wx_palette(kind, sun_alt, sky_palette(sun_alt))
    show = sky_bodies_visible(kind)
    moon_up = sk["moon_alt"] > 0 and sun_alt < 0
    day_moon = sk["moon_alt"] > 0 and sun_alt >= 0

    c.gradient_rect(0, 0, w - 1, 13, pal[0], pal[1], horizontal = False)
    c.gradient_rect(0, 14, w - 1, 25, pal[1], pal[2], horizontal = False)
    c.gradient_rect(0, 26, w - 1, 27, pal[2], pal[3], horizontal = False)
    if pal[5] and kind in ("clear", "partly"):
        n = len(STARS) if sun_alt < -12 else len(STARS) // 2
        for s in STARS[:n]:
            if not moon_up or s[0] % 3 != 0:
                c.pixel(s[0], s[1], "#AEB8D0" if sun_alt < -12 else "#7C86A8")

    # Sun and moon where they really are (behind the hardware, as in life).
    if show[0] and sun_alt > -1:
        x = sky_x(sk["sun_az"])
        y = sky_y(sun_alt)
        if x != None and y != None:
            draw_sun(c, x, y, sun_alt)
    if show[1] and (moon_up or day_moon):
        x = sky_x(sk["moon_az"])
        y = sky_y(sk["moon_alt"])
        if x != None and y != None:
            draw_moon(c, x, y, sk["illum"], sk["waxing"], day_moon)
    draw_clouds_back(c, kind, day)

    if wrapup:
        draw_spent_trail(c, day, now - (parse_iso(flown.get("net")) or now))
    elif not launch_day:
        draw_climb(c, sun_alt, day)

    # Water, with a light path under the sun or moon when the sky is clear.
    c.rect(0, 28, w - 1, 31, fill = pal[4])
    glint = None
    if kind in ("clear", "partly"):
        if sun_alt > -1:
            glint = [sky_x(sk["sun_az"]), "#FFE7A0" if sun_alt > 10 else "#F0A050"]
        elif moon_up:
            glint = [sky_x(sk["moon_az"]), "#B8C4DA"]
    if glint != None and glint[0] != None:
        for y in range(28, 32):
            spread = (y - 27) * 2
            for x in range(glint[0] - spread, glint[0] + spread + 1, 2):
                if (x + y) % 3 != 0:
                    c.pixel(x, y, glint[1])

    draw_pad(c, day)
    if launch_day:
        box = draw_rocket_on_pad(c, rocket_shape(nxt), day)
        if not day:
            floodlights(c, box[1])
        venting(c, box, day)

    draw_weather_front(c, kind, day, now // 300)

    stroke = "#0B1030" if day else "#05030F"
    if launch_day:
        return launch_day_text(c, nxt, v, now, st, stroke)
    if wrapup:
        fs = status_of(flown, now)
        t = parse_iso(flown.get("net"))
        c.text_stroke("US LAUNCHES", 5, 2, font = "10x16_bold", color = INK, stroke = stroke)
        c.hline(5, 19, 104, fs[1])
        lead = "LAUNCHED " + clock(t, v["zone"]) + "  "
        if c.text_width(lead + fs[0], "4x5") > 128:
            lead = clock(t, v["zone"]) + "  "
        c.text_stroke(lead, 5, 22, font = "4x5", color = "#F0F4FA" if day else "#D6DEEE", stroke = stroke)
        c.text_stroke(fs[0], 5 + c.text_width(lead, "4x5"), 22, font = "4x5", color = fs[1], stroke = stroke)
        return
    c.text_stroke("US LAUNCHES", 5, 2, font = "10x16_bold", color = INK, stroke = stroke)
    c.hline(5, 19, 104, "#E8862C")
    line = next_strip(c, nxt, v) if nxt != None and v != None else "EVERY US PAD  YOUR SKY"
    c.text_stroke(line, 5, 22, font = "4x5", color = "#F0F4FA" if day else "#D6DEEE", stroke = stroke)

def draw_spent_trail(c, day, age):
    # After launch: the trail hangs in the sky and drifts apart, fainter the
    # longer it's been (spent by the end of the wrap-up); no rocket - it's in
    # orbit.
    fade = min(1.0, max(0.0, float(age) / WRAPUP))
    cols = ["#C9CED8", "#A9B0BE", "#8A92A2", "#6A7282"] if day else ["#8A7A86", "#6E6070", "#564C5A", "#3E3846"]
    col = cols[min(3, int(fade * 4))]
    steps = 30
    for k in range(2, steps + 1):
        t = k * 1.0 / steps
        p = plume_point(t)
        drift = int(t * fade * 6)  # high-altitude winds shear the top
        x = int(p[0] + 0.5) + drift
        y = int(p[1] + 0.5)
        if (k + int(fade * 5)) % 3 != 0:
            c.fill_circle(x, y, 1 if t > 0.5 else 2, col)

def draw_climb(c, sun_alt, day):
    # The trail and the climbing rocket; the sunlit bell only at twilight.
    if sun_alt <= -2 and sun_alt > -16:
        bell = [["#13285A", 6, 0.30], ["#1B3F7A", 5, 0.25], ["#26599C", 4, 0.20], ["#3C78BA", 3, 0.14],
                ["#62A0D6", 2, 0.08], ["#A9D2F0", 1, 0.03]]
        for b in bell:
            p = plume_point(1.0 - b[2])
            c.fill_circle(int(p[0] + 0.5), int(p[1] + 0.5), b[1], b[0])
            q = plume_point(1.0 - b[2] / 2.0)
            c.fill_circle(int(q[0] + 0.5), int(q[1] + 0.5), max(1, b[1] - 1), b[0])
    steps = 40
    prev = plume_point(0.0)
    for k in range(1, steps + 1):
        t = k * 1.0 / steps
        p = plume_point(t)
        x0 = int(prev[0] + 0.5)
        y0 = int(prev[1] + 0.5)
        x1 = int(p[0] + 0.5)
        y1 = int(p[1] + 0.5)
        if day:
            c.fill_circle(x1, y1, 2 if t < 0.5 else 1, "#E8ECF2")
            c.line(x0, y0, x1, y1, "#FFFFFF")
        elif t < 0.3:
            c.fill_circle(x1, y1, 3 - int(t * 7), "#6E6070")
            c.line(x0, y0, x1, y1, "#C9A27A")
        elif t < 0.75:
            c.line(x0 - 1, y0, x1 - 1, y1, "#B5561E")
            c.line(x0, y0, x1, y1, "#FFC15A")
        else:
            c.line(x0, y0 + 1, x1, y1 + 1, "#E8862C")
            c.line(x0, y0, x1, y1, "#FFF4C8")
        prev = p
    draw_rocket(c)

# ---------- launch day ----------

LAUNCH_DAY_SECONDS = 24 * 3600

def is_launch_day(l, now, status):
    if status in ("LIVE", "LIFTOFF"):
        return True
    t = parse_iso(l.get("net"))
    if t == None or not exact_time(l):
        return False
    return t - now <= LAUNCH_DAY_SECONDS and t - now > -3600

def day_word(t, v, now):
    off_t = local_offset(v["zone"], t)
    off_n = local_offset(v["zone"], now)
    dt = (t + off_t) // 86400 - (now + off_n) // 86400
    if dt == 0:
        return "TODAY"
    if dt == 1:
        return "TOMORROW"
    return day_date(t, off_t)

def launch_day_text(c, l, v, now, st, stroke):
    live = st[0] in ("LIVE", "LIFTOFF")
    held = st[0] in ("HOLD", "SCRUB")
    col = MAGENTA if live else (st[1] if held else AMBER)
    label = st[0] if (live or held or st[0] == "DELAYED") else "LAUNCH DAY"
    lw = chip(c, label, col, 5) - 8

    t = parse_iso(l.get("net"))
    ab = zone_abbr(v["zone"], t)
    when = day_word(t, v, now) + " " + clock(t, v["zone"]) + (" " + ab if ab != "" else "")
    cd = countdown(l, now, st[0])
    # Inside the last hour (or live, or flying) the liftoff time is the big
    # number - it's right whenever you read it - and the count goes small.
    close = t != None and t - now < 3600 and not held
    if st[0] == "LIFTOFF":
        sub = "WE HAVE LIFTOFF"
        cd = clock(t, v["zone"])
    elif close:
        sub = "IN THE COUNT" if st[0] == "LIVE" and t - now <= 0 else soon_text(t - now)
        cd = clock(t, v["zone"])
    else:
        sub = when
    c.text_stroke(sub, 5 + lw + 3, 2, font = "4x5", color = "#F0F4FA", stroke = stroke)

    big = "10x16_bold" if c.text_width(cd, "10x16_bold") <= 78 else "7x12"
    c.text_stroke(cd, 5, 9, font = big, color = col if (live or held) else INK, stroke = stroke)

    # Rocket and mission beside the countdown, up to the lightning pole:
    # full size if the rocket fits, else both in the small font.
    rx = 5 + c.text_width(cd, big) + 6
    room = 137 - rx  # text may run over the thin lightning pole
    rk = rocket(l)
    ms = mission(l)
    if c.text_width(rk, "5x7") <= room:
        c.text_stroke(rk, rx, 10, font = "5x7", color = INK, stroke = stroke)
        # Narrow 3x7 before clipping: "STARLINK 15-18" should read whole.
        mf = "4x5" if c.text_width(ms, "4x5") <= room else "3x7"
        c.text_stroke(clip(c, ms, mf, room), rx, 18 if mf == "3x7" else 19, font = mf, color = "#D6DEEE", stroke = stroke)
    else:
        c.text_stroke(clip(c, rk, "4x5", room), rx, 10, font = "4x5", color = INK, stroke = stroke)
        c.text_stroke(clip(c, ms, "4x5", room), rx, 17, font = "4x5", color = "#D6DEEE", stroke = stroke)

    # The verdict on its own dark backing so it reads over water and steam;
    # a scrubbed launch has no time to look at yet.
    if st[0] == "SCRUB":
        return
    vis = visibility(l, v, now)
    vt = vis["verdict"]
    # "LIKELY - LOOK SSW AT 6:12P": the moment it clears your horizon.
    if " AT " in vis["tip"] and (vt.startswith("LIKELY") or vt.startswith("MAYBE")):
        at = vis["tip"].split(" AT ")[1].split("  ")[0]
        if c.text_width(vt + " AT " + at, "4x5") <= 132:
            vt = vt + " AT " + at
    vw = c.text_width(vt, "4x5")
    c.rect(4, 25, 5 + vw, 31, fill = "#05070F")
    c.text(vt, 5, 26, font = "4x5", color = vis["color"] if vis["color"] != DIM else "#9AA4B8")

def next_strip(c, l, v):
    # "NEXT: FALCON 9  FRI 12:02A" - the rocket and your local day/time.
    t = parse_iso(l.get("net"))
    when = ""
    if t != None:
        p = precision(l)
        if p in ("M", "Q", "Y", "H1", "H2", "Q1", "Q2", "Q3", "Q4"):
            when = "NET " + MONTHS[civil(t // 86400)[1] - 1]
        elif p == "DAY":
            cd = civil(t // 86400)
            when = MONTHS[cd[1] - 1] + " " + str(cd[2])
        else:
            off = local_offset(v["zone"], t)
            when = day_date(t, off)[:3] + " " + clock(t, v["zone"])
    for name in [rocket(l), rocket(l).split(" ")[0]]:
        line = "NEXT: " + name + ("  " + when if when != "" else "")
        if c.text_width(line, "4x5") <= 128:
            return line
    return clip(c, "NEXT: " + when, "4x5", 128)

# ---------- intro hardware ----------

def draw_rocket(c):
    # Two-pixel body on a 1-in-2 climb (the trail's final slope): engine
    # bloom, white first stage, dark interstage band, second stage, then a
    # shaded nose. Rows are the sunlit top edge and the shadowed underside.
    c.fill_circle(TIP_X, TIP_Y + 1, 2, "#FF9A2E")
    c.fill_circle(TIP_X, TIP_Y + 1, 1, "#FFF4C8")
    for k in range(1, 12):
        x = TIP_X + k
        y = TIP_Y - (k + 1) // 2 + 1
        if k == 7:
            top = "#2A2F3D"
            low = "#1C202B"
        elif k >= 10:
            top = "#DDE4F0"
            low = "#9AA4B8"
        else:
            top = "#FFFFFF"
            low = "#B8C2D6"
        c.pixel(x, y - 1, top)
        if k < 11:
            c.pixel(x, y, low)
    c.pixel(TIP_X + 12, TIP_Y - 5, "#C9D3E6")  # nose tip
    c.pixel(TIP_X + 1, TIP_Y + 1, "#7A8296")   # aft skirt / engine bell

def draw_pad(c, day):
    # Concrete pad and flame trench, a cross-braced lattice tower with its
    # crew-access arm and lightning mast, two lightning-protection poles,
    # and steam billowing out of the trench.
    steel = "#5A6070" if day else "#3A4050"
    dark = "#3A4256" if day else "#0A0C14"
    c.rect(139, 25, 162, 27, fill = dark)
    c.rect(148, 26, 153, 27, fill = "#05060A")  # trench mouth

    # Lightning-protection poles, wires to the tower's mast.
    pole = "#4A5060" if day else "#2A2F3D"
    c.vline(136, 13, 13, pole)
    c.vline(160, 14, 12, pole)
    c.line(136, 13, 145, 5, pole)
    c.line(160, 14, 145, 5, pole)

    # Tower: two rails, X bracing every three rows, platform decks.
    c.vline(143, 9, 17, steel)
    c.vline(147, 9, 17, steel)
    for y in range(10, 25, 3):
        c.line(144, y, 146, y + 2, steel)
        c.line(146, y, 144, y + 2, steel)
        c.hline(143, y, 5, steel)
    c.hline(143, 8, 5, steel)
    # Crew-access arm swung toward where the rocket stood, and the mast.
    c.hline(147, 13, 4, "#8A93A6" if day else "#4A5164")
    c.pixel(150, 14, "#8A93A6" if day else "#4A5164")
    c.vline(145, 4, 4, steel)
    c.pixel(145, 3, "#E5484D")

    # Steam out of the trench, lit orange from below at night.
    puff = "#E8ECF2" if day else "#6E6070"
    glow = "#FFD9A0" if day else "#D88A4A"
    for p in [[140, 24, 2], [137, 25, 2], [156, 24, 2], [159, 25, 2], [154, 23, 1], [142, 23, 1]]:
        c.fill_circle(p[0], p[1], p[2], puff)
    c.pixel(141, 25, glow)
    c.pixel(156, 25, glow)
    c.fill_circle(PAD_X, PAD_Y, 2, "#FFD27A")
    c.pixel(PAD_X, PAD_Y, "#FFFFFF")

# ---------- weather over the scene ----------
# The zip's current conditions from Open-Meteo (WMO weather codes plus
# cloud cover, from the viewer's forecast call), drawn over the live sky.

def weather_kind(v):
    cur = v["current"]
    if type(cur) != "dict":
        return "clear"
    code = int(cur.get("weather_code") or 0)
    cover = int(cur.get("cloud_cover") or 0)
    if code >= 95:
        return "storm"
    if (code >= 71 and code <= 77) or code in (85, 86):
        return "snow"
    if (code >= 51 and code <= 67) or (code >= 80 and code <= 82):
        return "rain"
    if code in (45, 48):
        return "fog"
    if cover < 25:
        return "clear"
    if cover < 60:
        return "partly"
    if cover < 88:
        return "cloudy"
    return "overcast"

ROCKET_SHAPES = [["Falcon Heavy", "FALCON HEAVY"], ["Falcon 9", "FALCON 9"], ["Vulcan", "VULCAN"],
                 ["Atlas V", "ATLAS V"], ["Starship", "STARSHIP"], ["Super Heavy", "STARSHIP"],
                 ["New Glenn", "NEW GLENN"], ["Electron", "ELECTRON"]]

def rocket_shape(l):
    n = str((((l.get("rocket") or {}).get("configuration") or {}).get("name")) or "")
    for r in ROCKET_SHAPES:
        if r[0] in n:
            return r[1]
    return "FALCON 9"

def cloud(c, x, y, size, body, shade):
    # A puff: three overlapping discs on a flat shaded base.
    c.fill_circle(x, y, size, body)
    c.fill_circle(x + size + 1, y - 1, size + 1, body)
    c.fill_circle(x + 2 * size + 2, y, size, body)
    c.hline(x - size, y + size, 3 * size + 4, shade)

def wx_palette(kind, sun_alt, pal):
    # Gray the sky down under heavy cloud; keep the live palette otherwise.
    if kind in ("overcast", "rain", "storm", "snow"):
        if sun_alt > 0:
            return ["#5E6878", "#7C8696", "#9AA2AE", "#A8B0BA", "#3A4656", False]
        if sun_alt > -6:
            return ["#2A2638", "#4A3A4A", "#6A4A44", "#7A5444", "#151822", False]
        return ["#0C0E14", "#14171F", "#1A1D26", "#1E2129", "#06070B", False]
    if kind == "fog":
        if sun_alt > 0:
            return ["#8A96A6", "#A8B2BE", "#C2CAD2", "#CCD2D8", "#6A7684", False]
        return ["#1A1E28", "#2A2F3A", "#3A404A", "#444A54", "#14171E", False]
    return pal

def sky_bodies_visible(kind):
    # [sun, moon]: hidden behind overcast, faded through fog.
    if kind in ("overcast", "rain", "storm", "snow"):
        return [False, False]
    return [True, True]

def draw_clouds_back(c, kind, day):
    body = "#E8ECF2" if day else "#2A2E3C"
    shade = "#B8C0CC" if day else "#1C1F2A"
    if kind == "partly":
        cloud(c, 118, 6, 2, body, shade)
        cloud(c, 176, 16, 2, body, shade)
    elif kind == "cloudy":
        cloud(c, 114, 5, 2, body, shade)
        cloud(c, 150, 3, 3, body, shade)
        cloud(c, 172, 14, 2, body, shade)
        cloud(c, 124, 17, 2, body, shade)
    elif kind in ("overcast", "rain", "storm", "snow"):
        dark = "#4A5262" if day else "#191C25"
        darker = "#3A4150" if day else "#111319"
        for x in range(0, c.width, 14):
            cloud(c, x, 3 + (x // 14) % 2 * 2, 3, dark, darker)

def draw_weather_front(c, kind, day, tick):
    # In front of everything but the title: rain, snow, lightning, fog.
    if kind == "rain" or kind == "storm":
        col = "#9FB4D0" if day else "#5A6C88"
        for x in range(-8, c.width, 5):
            if x < 120 and x % 10 != 2:
                continue  # sparser behind the title
            for y0 in range((x * 7) % 9, 30, 9):
                c.line(x + y0 // 3, y0, x + y0 // 3 + 1, y0 + 3, col)
    if kind == "storm":
        bolt = [[168, 6], [165, 11], [168, 11], [163, 18]]
        for i in range(len(bolt) - 1):
            c.line(bolt[i][0], bolt[i][1], bolt[i + 1][0], bolt[i + 1][1], "#FFF6B0")
        c.pixel(162, 19, "#FFFFFF")
    if kind == "snow":
        for i in range(70):
            x = (i * 37 + tick) % c.width
            y = (i * 13) % 28
            c.pixel(x, y, "#F2F6FC" if (i % 3) else "#C9D3E6")
    if kind == "fog":
        col = "#D8DEE6" if day else "#4A5060"
        for y in range(16, 30):
            for x in range(0, c.width, 2):
                if (x + y * 3) % (2 if y > 22 else 4) == 0:
                    c.pixel(x + (y % 2), y, col)

# ---------- on-pad rockets: [legend, rows top->bottom] ----------
ROCKET_COLORS = {"w": "#F2F4F8", "k": "#2A2F3D", "o": "#D9822B", "b": "#C9853A", "g": "#B8BEC8",
                 "h": "#E2E6EE", "d": "#5A606C", "u": "#2A5CB8", "e": "#3A3E46", "s": "#DDE2EA"}

SPRITES = {
    "FALCON 9": [".w.", "www", "www", "www", "www", "www", "www", "kkk", "kkk", "www", "www", "www", "www",
                 "www", "www", "www", "www", "www", "kwk"],
    "FALCON HEAVY": ["...w...", "..www..", "..www..", "..www..", "..www..", "..www..", "w.www.w", "wwkkkww",
                     "wwkkkww", "kwwwwwk", "wwwwwww", "wwwwwww", "wwwwwww", "wwwwwww", "wwwwwww", "wwwwwww",
                     "wwwwwww", "wwwwwww", "kwkwkwk"],
    "VULCAN": [".ww.", "wwww", "wwww", "wwww", "wwww", "wwww", "wwww", "oooo", "oooo", "oooo", "oooo",
               "oooo", "oooo", "oooo", "soooos", "soooos", "soooos", "soooos", "eooooe"],
    "ATLAS V": [".ww.", "wwww", "wwww", "wwww", "wwww", "wwww", "wwww", "wwww", "bbbb", "bbbb", "bbbb",
                "bbbb", "bbbb", "bbbb", "bbbb", "sbbbbs", "sbbbbs", "sbbbbs", "ebbbbe"],
    "STARSHIP": ["..h..", ".hgg.", "dhggd", "hgggg", "hgggg", "hgggg", "hgggg", "hgggg", "dhggd", "eeeee",
                 "dhggd", "hgggg", "hgggg", "hgggg", "hgggg", "hgggg", "hgggg", "hgggg", "hgggg", "hgggg",
                 "eeeee"],
    "NEW GLENN": [".ww.", "wwww", "wwww", "wwww", "wwww", "wwww", "wwww", "uuuu", "wwww", "wwww", "wwww",
                  "wwww", "wwww", "wwww", "wwww", "wwww", "wwww", "wwww", "wwww", "kwwk"],
    "ELECTRON": [".k", "kk", "kk", "kk", "kk", "kk", "kk", "kk", "kk", "kk", "kk", "kk"],
}

def draw_rocket_on_pad(c, name, day):
    rows = SPRITES.get(name, SPRITES["FALCON 9"])
    w = 0
    for r in rows:
        w = max(w, len(r))
    base_y = 25
    left = 154 - w // 2
    for i in range(len(rows)):
        r = rows[i]
        y = base_y - len(rows) + i
        off = (w - len(r)) // 2
        for j in range(len(r)):
            ch = r[j]
            if ch == ".":
                continue
            col = ROCKET_COLORS.get(ch, "#F2F4F8")
            # Shade the right-hand column for roundness.
            if j == len(r) - 1 and ch in ("w", "g", "o", "b", "s") and len(r) > 1:
                col = {"w": "#B8C2D6", "g": "#8E959F", "o": "#A8621E", "b": "#99642A", "s": "#AEB6C4"}[ch]
            if not day and ch in ("w", "s"):
                col = "#C9D0DC" if col == "#F2F4F8" else col
            if not day and ch == "k":
                col = "#6A7080"  # a black Electron would vanish at night
            c.pixel(left + off + j, y, col)
    return [left, base_y - len(rows), w]

def floodlights(c, top):
    # Night: pale beams from the pad corners up the vehicle.
    for k in range(8):
        y = 26 - k * 2
        if y < top:
            break
        c.pixel(150 - k // 2, y, "#6A6040")
        c.pixel(158 + k // 2, y, "#6A6040")
    c.pixel(149, 26, "#FFF0B0")
    c.pixel(159, 26, "#FFF0B0")

def venting(c, box, day):
    col = "#F2F4F8" if day else "#8A8FA0"
    x = box[0] + box[2]
    c.fill_circle(x + 2, box[1] + 6, 1, col)
    c.pixel(x + 4, box[1] + 5, col)
    c.fill_circle(box[0] - 2, 24, 2, col)
    c.fill_circle(x + 2, 24, 2, col)

def plume_point(t):
    # Cubic curve shaped like a gravity turn: straight up off the pad, then
    # leaning over steadily until it meets the engine on the rocket's own
    # ~30-degree climb line - never flatter low than high.
    x0, y0 = float(PAD_X), float(PAD_Y)
    x1, y1 = float(PAD_X), float(PAD_Y) - 10.0
    x3, y3 = float(TIP_X), float(TIP_Y) + 1.0
    x2, y2 = x3 - 7.0, y3 + 4.0
    u = 1.0 - t
    a = u * u * u
    b = 3.0 * u * u * t
    c = 3.0 * u * t * t
    d = t * t * t
    return [a * x0 + b * x1 + c * x2 + d * x3, a * y0 + b * y1 + c * y2 + d * y3]
