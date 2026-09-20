def main(c, ctx):
    c.fill("black")

    hour = ctx.now.hour
    minute = ctx.now.minute
    month = ctx.now.month
    day = ctx.now.day

    # Rogers, ND — Central Time
    # CST = UTC-6
    # CDT = UTC-5

    offset = -6

    if month > 3 and month < 11:
        offset = -5
    elif month == 3 and day >= 8:
        offset = -5
    elif month == 11 and day < 8:
        offset = -5

    hour = hour + offset

    if hour < 0:
        hour = hour + 24

    if hour >= 24:
        hour = hour - 24

    # 12-hour format
    if hour >= 12:
        ampm = "PM"
    else:
        ampm = "AM"

    hour = hour % 12

    if hour == 0:
        hour = 12

    if minute < 10:
        minute_text = "0" + str(minute)
    else:
        minute_text = str(minute)

    time = str(hour) + ":" + minute_text

    c.text_center(time, 8, font="10x16", color="white")