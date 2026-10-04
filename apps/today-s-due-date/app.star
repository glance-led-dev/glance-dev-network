MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
def days_from_civil(year, month, day):
    # Convert a Gregorian calendar date to days since 1970-01-01.
    y = year - 1 if month <= 2 else year
    era = y // 400
    yoe = y - era * 400
    mp = month + (-3 if month > 2 else 9)
    doy = (153 * mp + 2) // 5 + day - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468
def eastern_offset_seconds(unix_seconds, utc_year):
    # Eastern Time: DST starts on the second Sunday in March at 07:00 UTC
    # and ends on the first Sunday in November at 06:00 UTC.
    march_first = days_from_civil(utc_year, 3, 1)
    march_first_weekday = (march_first + 3) % 7  # Monday=0, Sunday=6
    first_sunday_march = 1 + ((6 - march_first_weekday) % 7)
    second_sunday_march = first_sunday_march + 7
    dst_start = days_from_civil(utc_year, 3, second_sunday_march) * 86400 + 7 * 3600
    november_first = days_from_civil(utc_year, 11, 1)
    november_first_weekday = (november_first + 3) % 7
    first_sunday_november = 1 + ((6 - november_first_weekday) % 7)
    dst_end = days_from_civil(utc_year, 11, first_sunday_november) * 86400 + 6 * 3600
    if unix_seconds >= dst_start and unix_seconds < dst_end:
        return -4 * 3600
    return -5 * 3600
def civil_from_days(days):
    # Convert days since 1970-01-01 into a Gregorian year, month, and day.
    z = days + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    year = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    day = doy - (153 * mp + 2) // 5 + 1
    month = mp + (3 if mp < 10 else -9)
    year += 1 if month <= 2 else 0
    return year, month, day
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
    # Convert the render time to Eastern Time, including its daylight-saving shift.
    eastern_unix = ctx.now.unix + eastern_offset_seconds(ctx.now.unix, ctx.now.year)
    today_days = eastern_unix // 86400
    year, month, day = civil_from_days(today_days + 21)
    label = MONTHS[month - 1] + " " + str(day)
    # Use the largest font that fits in the open right-hand area.
    date_center = 43
    date_width = c.width - 23
    font = "6x8"
    if c.text_width(label, font) > date_width:
        font = "5x7"
    if c.text_width(label, font) > date_width:
        font = "4x5"
    c.text(label, date_center, 20, font=font, color="#FFE048", align="center")
