# Standard-time UTC offsets. Daylight time adds one hour.
OFFSETS = {
    "Eastern": -5,
    "Central": -6,
    "Mountain": -7,
    "Pacific": -8,
}

def weekday(year, month, day):
    # Sakamoto's method: 0 = Sunday
    t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
    if month < 3:
        year = year - 1
    return (year + year // 4 - year // 100 + year // 400 + t[month - 1] + day) % 7

def nth_sunday(year, month, n):
    first = weekday(year, month, 1)
    return 1 + (7 - first) % 7 + 7 * (n - 1)

def is_dst(now, std):
    # US DST: 2 AM local, second Sunday of March to first Sunday of November.
    # Compare in UTC hours so the switch lands on the right hour.
    month = now.month
    if month > 3 and month < 11:
        return True
    if month < 3 or month > 11:
        return False
    if month == 3:
        start = nth_sunday(now.year, 3, 2)
        return (now.day, now.hour) >= (start, 2 - std)
    end = nth_sunday(now.year, 11, 1)
    return (now.day, now.hour) < (end, 2 - (std + 1))

def main(c, ctx):
    c.fill("black")

    zone = ctx.inputs.get("timezone", "Central")
    std = OFFSETS.get(zone, -6)

    offset = std
    if is_dst(ctx.now, std):
        offset = std + 1

    hour = (ctx.now.hour + offset) % 24
    minute = ctx.now.minute

    # 12-hour format
    hour = hour % 12
    if hour == 0:
        hour = 12

    if minute < 10:
        minute_text = "0" + str(minute)
    else:
        minute_text = str(minute)

    time = str(hour) + ":" + minute_text

    c.text_center(time, 8, font="10x16", color="white")
