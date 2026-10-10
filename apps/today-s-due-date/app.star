# DESIGN. A stack of three library books on the left and the date a book
# checked out today comes back on the right, in big gold type with its weekday
# underneath. The loan period and the reader's time zone are settings, so any
# library (7 to 42 days) anywhere in the world gets the right date.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
# Short names: 'WEDNESDAY' is 45px at 4x5 and the date column is only 41px.
DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

# Loan period dropdown -> days. The key matches the manifest choices exactly.
LOANS = {
    "1 week": 7,
    "10 days": 10,
    "2 weeks": 14,
    "3 weeks": 21,
    "4 weeks": 28,
    "30 days": 30,
    "6 weeks": 42,
}

def days_from_civil(y, m, d):
    # Convert a Gregorian calendar date to days since 1970-01-01.
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    # Convert days since 1970-01-01 into a Gregorian year, month, and day.
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    day = doy - (153 * mp + 2) // 5 + 1
    month = mp + (3 if mp < 10 else -9)
    year = yoe + era * 400 + (1 if month <= 2 else 0)
    return year, month, day

def weekday(z):
    # 0 = Monday .. 6 = Sunday. Day 0 (1970-01-01) was a Thursday.
    return (z + 3) % 7

# The shared 52-zone time zone dropdown, worked out offline so the date never
# depends on a time API being up. Same table and rules as google-calendar.
#
# zone -> [standard offset in minutes, DST rule]
#   0 none  1 United States  2 Europe  3 Australia (southern)
#   4 New Zealand  5 Egypt  6 Israel
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
    # Day of the month of the nth Sunday, or the last one when n is -1.
    if n == -1:
        last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
        if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
            last = 29
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    first = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return first + 7 * (n - 1)

def last_dow(y, m, dow):
    # Day of the month of the last given weekday (0 = Monday). Egypt and
    # Israel change on a Friday, so Sundays are not enough.
    last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
    if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
        last = 29
    return last - ((weekday(days_from_civil(y, m, last)) - dow) % 7)

def utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(zone, t):
    # Minutes east of UTC for `zone` at the UTC instant `t` (minutes since the
    # epoch). Every comparison is in UTC so changeovers need no local reasoning.
    z = TZ[zone] if zone in TZ else TZ["UTC"]
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    if rule == 1:
        # 2nd Sunday in March at 02:00 standard -> 1st in November at 02:00
        # daylight, which is 01:00 standard.
        start = utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
        end = utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 2:
        # Europe changes at 01:00 UTC everywhere at once.
        start = utcmin(y, 3, nth_sunday(y, 3, -1), 1)
        end = utcmin(y, 10, nth_sunday(y, 10, -1), 1)
        return std + 60 if t >= start and t < end else std
    if rule == 5:
        # Egypt: last Friday in April through the last Thursday in October.
        start = utcmin(y, 4, last_dow(y, 4, 4), 0) - std
        end = utcmin(y, 10, last_dow(y, 10, 4), 0) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 6:
        # Israel starts the Friday before the last Sunday in March and ends
        # with Europe in October.
        start = utcmin(y, 3, nth_sunday(y, 3, -1) - 2, 2) - std
        end = utcmin(y, 10, nth_sunday(y, 10, -1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    # Southern hemisphere: summer straddles New Year, so standard time is the
    # window BETWEEN the April end and the spring start.
    m0 = 10 if rule == 3 else 9
    n0 = 1 if rule == 3 else -1
    start = utcmin(y, m0, nth_sunday(y, m0, n0), 2) - std
    end = utcmin(y, 4, nth_sunday(y, 4, 1), 3) - std - 60
    return std if t >= end and t < start else std + 60

def draw_book(c, x, y, width, cover):
    # Each book is a bright spine with matching edges, gold bands, and a label.
    c.rect(x, y, x + width - 1, y + 2, fill=cover)
    c.rect(x + 2, y, x + 2, y + 2, fill="#FFE048")
    c.rect(x + width - 3, y, x + width - 3, y + 2, fill="#FFE048")
    c.rect(x + 5, y + 1, x + width - 6, y + 1, fill="#FFF7D6")

def due_date(c, ctx):
    c.fill("#040710")
    # The full title wraps to two centered lines on the 64-pixel panel.
    c.text("TODAY'S DUE", c.width // 2, 2, font="4x5", color="#32E6FF", align="center")
    c.text("DATE:", c.width // 2, 9, font="4x5", color="#32E6FF", align="center")
    # Three offset books, spines out, echo the approved pixel-art mockup.
    draw_book(c, 4, 18, 16, "#00DC46")
    draw_book(c, 2, 21, 18, "#FF315F")
    draw_book(c, 1, 24, 16, "#B64DFF")

    # Today in the reader's own zone, daylight saving included, plus the loan.
    zone = str(ctx.inputs.get("timezone", "America/New_York")).strip()
    loan = LOANS.get(str(ctx.inputs.get("loan", "3 weeks")).strip(), 21)
    local_min = ctx.now.unix // 60 + zone_offset_at(zone, ctx.now.unix // 60)
    due_days = local_min // 1440 + loan
    year, month, day = civil_from_days(due_days)
    label = MONTHS[month - 1] + " " + str(day)

    # Use the largest font that fits in the open right-hand area.
    date_center = 43
    date_width = c.width - 23
    font = "6x8"
    if c.text_width(label, font) > date_width:
        font = "5x7"
    if c.text_width(label, font) > date_width:
        font = "4x5"
    c.text(label, date_center, 17, font=font, color="#FFE048", align="center")
    # The weekday under the date, so "is the library open that day" is obvious.
    c.text(DAYS[weekday(due_days)], date_center, 26, font="4x5", color="#8FA3C8", align="center")
