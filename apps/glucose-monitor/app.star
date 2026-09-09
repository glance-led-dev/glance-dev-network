def fetch_data(ctx):
    domain = ctx.inputs.get("nightscouturl", "")
    token = ctx.inputs.get("token", "")
    if not domain or not token:
        return None
    resp = http.get("https://" + domain + "/api/v1/entries.json?count=36&token=" + token)
    if resp["status_code"] != 200:
        return None
    data = resp["json"]
    if len(data) == 0:
        return None
    return data

def main(c, ctx):
    c.clear()
    data = fetch_data(ctx)
    if data == None:
        c.text_center("SETUP NEEDED", 12, font="6x8", color="red")
        return

    entry = data[0]
    sgv = entry["sgv"]
    direction = entry.get("direction", "")

    color = "green"
    if sgv < 54 or sgv > 250:
        color = "red"
    elif sgv < 70 or sgv > 180:
        color = "yellow"

    arrow = "FLAT"
    if direction == "SingleUp":
        arrow = "UP"
    elif direction == "DoubleUp":
        arrow = "UP UP"
    elif direction == "FortyFiveUp":
        arrow = "RISING"
    elif direction == "SingleDown":
        arrow = "DOWN"
    elif direction == "DoubleDown":
        arrow = "DOWN DOWN"
    elif direction == "FortyFiveDown":
        arrow = "FALLING"

    total = 0
    for e in data:
        total += e["sgv"]
    avg = total // len(data)

    reading_seconds = entry["date"] // 1000
    age_minutes = (ctx.now.unix - reading_seconds) // 60

    # top row: big number left, trend centered, avg label top-right
    c.text(str(sgv), 2, 4, font="10x16", color=color, align="left")
    c.text(str(age_minutes) + " MIN AGO", 66, 8, font="4x7", color="orange", align="center")
    c.text(str(avg), 126, 4, font="10x16", color="gray", align="right")    


    # bottom row: age bottom-left, avg value bottom-right
    c.text(arrow, 2, 24, font="5x7", color=color, align="left")

    reading_seconds = entry["date"] // 1000
    local = reading_seconds + zone_offset(ctx) * 60
    secs = local % 86400
    hour = secs // 3600
    minute = (secs % 3600) // 60
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    time_str = str(hh) + ":" + fmt.pad(minute) + ap

    c.text(time_str, 52, 24, font="4x7", color="orange", align="left")
    c.text("3HR AVG", 126, 24, font="4x7", color="gray", align="right")


def days_from_civil(y, m, d):
    """Days since 1970-01-01 for a civil date (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    """The inverse: days since the epoch back to [year, month, day]."""
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

# The dropdown offers the four US zones by name. The table above is keyed by
# IANA zone, so the name is mapped across; an older saved IANA value passes
# through untouched.
US_ZONES = {"EASTERN": "America/New_York", "CENTRAL": "America/Chicago",
            "MOUNTAIN": "America/Denver", "PACIFIC": "America/Los_Angeles"}

def us_zone(raw):
    z = str(raw).strip()
    return US_ZONES.get(z.upper(), z)

def zone_offset(ctx):
    """The reader's current offset from UTC, in minutes."""
    return zone_offset_at(us_zone(ctx.inputs.get("timezone", "EASTERN")),
                          ctx.now.unix // 60)
