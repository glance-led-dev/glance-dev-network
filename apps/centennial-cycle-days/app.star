def live(c, ctx):
    dst_end = days_from_civil(2026, 11, 1) * 86400 + 21600
    offset_hours = -4 if ctx.now.unix < dst_end else -5
    utc_day = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    local_day = utc_day - 1 if ctx.now.hour < -offset_hours else utc_day
    start_day = days_from_civil(2026, 10, 27)
    end_day = days_from_civil(2027, 1, 14)

    if local_day < start_day:
        draw_empty(c, "STARTS OCT", "27 2026")
        return
    if local_day > end_day:
        draw_empty(c, "ENDS JAN", "14 2027")
        return

    weekday_index = (local_day + 3) % 7
    if weekday_index == 5:
        local_day = local_day - 1
    elif weekday_index == 6:
        local_day = local_day - 2
    weekday_index = (local_day + 3) % 7

    if local_day < days_from_civil(2026, 11, 1):
        month = "OCT"
        day = local_day - days_from_civil(2026, 10, 1) + 1
    elif local_day < days_from_civil(2026, 12, 1):
        month = "NOV"
        day = local_day - days_from_civil(2026, 11, 1) + 1
    elif local_day < days_from_civil(2027, 1, 1):
        month = "DEC"
        day = local_day - days_from_civil(2026, 12, 1) + 1
    else:
        month = "JAN"
        day = local_day - days_from_civil(2027, 1, 1) + 1

    cycle_day = [3, 4, 5, 1, 2][weekday_index]
    draw_live_day(c, weekday_index, month, day, cycle_day)


def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = yy // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def draw_frame(c):
    c.fill("#07104C")
    c.rect(0, 0, c.width - 1, 0, fill="#087AC0")
    c.rect(0, c.height - 1, c.width - 1, c.height - 1, fill="#087AC0")
    c.rect(1, 11, 22, 22, fill="#0083C3")
    c.rect(7, 11, 16, 11, fill="#32365A")
    c.rect(4, 12, 18, 12, fill="#32365A")
    c.rect(3, 13, 20, 13, fill="#32365A")
    c.rect(2, 14, 21, 14, fill="#32365A")
    c.rect(1, 15, 22, 15, fill="#32365A")
    c.rect(1, 16, 21, 16, fill="#32365A")
    c.rect(1, 17, 20, 17, fill="#32365A")
    c.rect(2, 18, 19, 18, fill="#32365A")
    c.rect(3, 19, 18, 19, fill="#32365A")
    c.rect(4, 20, 16, 20, fill="#32365A")
    c.rect(6, 21, 13, 21, fill="#32365A")
    c.rect(10, 13, 12, 13, fill="#F7F3ED")
    c.rect(9, 14, 13, 14, fill="#F7F3ED")
    c.rect(7, 15, 14, 15, fill="#F7F3ED")
    c.rect(4, 16, 13, 16, fill="#F7F3ED")
    c.rect(3, 17, 12, 17, fill="#F7F3ED")
    c.rect(4, 18, 11, 18, fill="#F7F3ED")
    c.rect(6, 19, 10, 19, fill="#F7F3ED")
    c.rect(7, 20, 9, 20, fill="#F7F3ED")
    c.pixel(11, 15, "#101737")
    c.pixel(4, 17, "#101737")
    c.pixel(7, 19, "#101737")
    c.rect(15, 14, 17, 14, fill="#00AAE1")
    c.rect(16, 17, 18, 17, fill="#00AAE1")
    c.pixel(13, 20, "#00AAE1")


def draw_live_day(c, weekday_index, month, day, cycle_day):
    draw_frame(c)
    weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    date_label = weekdays[weekday_index] + " " + month + " " + str(day)
    if c.text_width(date_label, font="4x5") > c.width - 6:
        date_label = weekdays[weekday_index] + " " + str(day)
    title_x = 3
    title = "TODAY IS"
    title_width = c.text_width(title, font="4x5")
    number = str(cycle_day)
    number_width = c.text_width(number, font="16x24")
    number_x = c.width - number_width - 4
    if title_x + title_width > number_x - 2:
        title = "TODAY"
    c.text(title, title_x, 3, font="4x5", color="#77C9F4")
    c.text("DAY", 25, 14, font="5x7", color="white")
    c.text(number, number_x, 2, font="16x24", color="white")
    c.text(date_label, 3, 26, font="4x5", color="#77C9F4")


def draw_empty(c, message, detail):
    draw_frame(c)
    c.text("ALL CLEAR", 24, 5, font="4x5", color="#77C9F4")
    c.text(message, 24, 14, font="4x5", color="white")
    c.text(detail, 24, 22, font="4x5", color="#77C9F4")


def error(c, ctx):
    draw_frame(c)
    c.text("BAD DATE", 24, 7, font="4x5", color="amber")
    c.text("CHECK TIME", 24, 17, font="4x5", color="white")


def empty(c, ctx):
    draw_empty(c, "WEEKEND", "NO SCHOOL")


def demo(c, ctx):
    draw_frame(c)
    c.text("TODAY IS", 3, 3, font="4x5", color="#77C9F4")
    c.text("DEMO", 25, 14, font="4x5", color="amber")
    c.text("4", 44, 2, font="16x24", color="white")
    c.text("TUE OCT 27", 3, 26, font="4x5", color="#77C9F4")
