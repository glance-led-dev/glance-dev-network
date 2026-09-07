# Last Z Full Preparedness
# Clock only. No network.
# Calendar hours are Apocalypse Time (UTC minus 2).
# Day 1 is Monday. Day 7 is Sunday.

GRID = [
    ["SHELTER", "SCIENCE", "VEHICLE", "HERO", "ARMY", "VEHICLE"],
    ["SCIENCE", "HERO", "SHELTER", "ARMY", "VEHICLE", "SHELTER"],
    ["HERO", "ARMY", "SCIENCE", "VEHICLE", "SHELTER", "SCIENCE"],
    ["ARMY", "VEHICLE", "HERO", "SHELTER", "SCIENCE", "HERO"],
    ["VEHICLE", "SHELTER", "ARMY", "SCIENCE", "HERO", "ARMY"],
    ["SCIENCE", "VEHICLE", "HERO", "SHELTER", "ARMY", "HERO"],
    ["VEHICLE", "SHELTER", "ARMY", "SCIENCE", "HERO", "ARMY"],
]

LABEL = {
    "SHELTER": "SHELTER",
    "SCIENCE": "SCIENCE",
    "VEHICLE": "VEHICLE",
    "HERO": "HERO",
    "ARMY": "ARMY",
}

SPEND = {
    "SHELTER": "BUILD",
    "SCIENCE": "RESEARCH",
    "VEHICLE": "WRENCHES",
    "HERO": "EXP",
    "ARMY": "TRAIN",
}

COLOR = {
    "SHELTER": "#4FAE3F",
    "SCIENCE": "#63B3FF",
    "VEHICLE": "#F2C14E",
    "HERO": "#C9B6FF",
    "ARMY": "#FF8C00",
}

ART = {
    "SHELTER": "shelter.png",
    "SCIENCE": "research.png",
    "VEHICLE": "vehicle.png",
    "HERO": "hero.png",
    "ARMY": "army.png",
}

def _draw_art(c, theme):
    c.image(ART[theme], 44, 8, w = 22, h = 22)

def _is_leap_year(year):
    if year % 400 == 0:
        return True
    if year % 100 == 0:
        return False
    return year % 4 == 0

def _days_in_month(year, month):
    if month == 2:
        return 29 if _is_leap_year(year) else 28
    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30
    return 31

def _previous_day(year, month, day):
    day = day - 1
    if day < 1:
        month = month - 1
        if month < 1:
            month = 12
            year = year - 1
        day = _days_in_month(year, month)
    return [year, month, day]

def _day_of_week(year, month, day):
    offsets = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
    y = year
    if month < 3:
        y = y - 1
    return (y + y // 4 - y // 100 + y // 400 + offsets[month - 1] + day) % 7

def _apocalypse(now):
    year = now.year
    month = now.month
    day = now.day
    hour = now.hour
    minute = now.minute
    second = now.second
    hour = hour - 2
    if hour < 0:
        hour = hour + 24
        prev = _previous_day(year, month, day)
        year = prev[0]
        month = prev[1]
        day = prev[2]
    return [year, month, day, hour, minute, second]

def _dow_index(year, month, day):
    sun0 = _day_of_week(year, month, day)
    if sun0 == 0:
        return 6
    return sun0 - 1

def _block(hour):
    return hour // 4

def _theme(day_index, block):
    return GRID[day_index][block]

def _pad2(n):
    if n < 10:
        return "0" + str(n)
    return str(n)

def _remain(hour, minute, second):
    next_hour = (hour // 4 + 1) * 4
    if next_hour >= 24:
        next_hour = 24
    total = (next_hour - hour) * 3600 - minute * 60 - second
    if total < 0:
        total = 0
    h = total // 3600
    m = (total % 3600) // 60
    return [h, m, total]

def main(c, ctx):
    at = _apocalypse(ctx.now)
    year = at[0]
    month = at[1]
    day = at[2]
    hour = at[3]
    minute = at[4]
    second = at[5]

    day_i = _dow_index(year, month, day)
    block = _block(hour)
    theme = _theme(day_i, block)

    next_block = block + 1
    next_day_i = day_i
    if next_block > 5:
        next_block = 0
        next_day_i = (day_i + 1) % 7
    nxt = _theme(next_day_i, next_block)

    left = _remain(hour, minute, second)
    left_h = left[0]
    left_m = left[1]

    accent = COLOR[theme]
    c.fill("black")
    c.rect(0, 0, 1, 31, fill = accent)
    _draw_art(c, theme)
    c.vline(67, 2, 28, "darkgray")

    c.text("LAST Z FP", 4, 1, font = "4x5", color = "#6E7A94")
    c.text(LABEL[theme], 4, 10, font = "5x7", color = accent)
    c.text(SPEND[theme], 4, 22, font = "4x5", color = "#6E7A94")

    c.text("ENDS IN", 72, 1, font = "4x5", color = "#6E7A94")
    remain = str(left_h) + "H " + _pad2(left_m) + "M"
    c.text(remain, 72, 10, font = "6x8", color = "#F4F7FF")
    c.text("NEXT " + LABEL[nxt], 72, 22, font = "4x5", color = COLOR[nxt])