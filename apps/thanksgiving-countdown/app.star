# Thanksgiving Countdown — a GDN Starlark app (192x32, 1 page).
#
# DESIGN. Five complete designs, picked from one dropdown. Each is a full scene
# with the words placed to suit it, so they read as different signs rather than
# one layout with different art. On the day, the count gives way to HAPPY
# THANKSGIVING in the same spot.
#
# ctx.now is UTC and apps aren't told the viewer's time zone, so a dropdown sets
# it. The greeting then runs midnight to midnight on the viewer's own clock,
# rather than ending at 7 PM in New York when Friday starts in UTC.

AMBER = "#F5A623"
DAY = 86400
HOUR = 3600

# zone -> (standard hours from UTC, observes daylight saving)
ZONES = {
    "Eastern": (-5, True),
    "Central": (-6, True),
    "Mountain": (-7, True),
    "Arizona": (-7, False),
    "Pacific": (-8, True),
    "Alaska": (-9, True),
    "Hawaii": (-10, False),
}

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def thanksgiving(y):
    """Fourth Thursday of November, as a day number. Day 0 was a Thursday."""
    nov1 = days_from_civil(y, 11, 1)
    return nov1 + (-nov1) % 7 + 21

def first_sunday(day):
    """First Sunday on or after a day number. Day 3 was a Sunday."""
    return day + (3 - day) % 7

def utc_offset(ctx):
    """Seconds from UTC for the chosen zone right now. US rule: DST runs from
    2 AM on the second Sunday of March to 2 AM on the first Sunday of November."""
    hours, observes_dst = ZONES.get(ctx.inputs.get("zone", "Eastern"), ZONES["Eastern"])
    standard = hours * HOUR
    if observes_dst:
        y = ctx.now.year
        start = (first_sunday(days_from_civil(y, 3, 1)) + 7) * DAY + 2 * HOUR - standard
        end = first_sunday(days_from_civil(y, 11, 1)) * DAY + HOUR - standard
        if start <= ctx.now.unix and ctx.now.unix < end:
            return standard + HOUR
    return standard

def days_left(ctx):
    """Whole days until Thanksgiving on the viewer's clock; 0 is the day itself."""
    today = (ctx.now.unix + utc_offset(ctx)) // DAY
    target = thanksgiving(ctx.now.year)
    if today > target:
        target = thanksgiving(ctx.now.year + 1)
    return target - today

def label(days):
    return "DAY" if days == 1 else "DAYS"

def put_center(c, text, y, font, color):
    c.text_stroke(text, (c.width - c.text_width(text, font = font)) // 2, y, font = font, color = color)

def count(c, days, y, number_color, label_color):
    """The number with its small label beside it, centered as one unit. 16x20
    ends at y + 19, so it stops above each scene's ground and table."""
    number = str(days)
    number_w = c.text_width(number, font = "16x20")
    label_w = c.text_width(label(days), font = "5x7")
    x = (c.width - number_w - 3 - label_w) // 2
    c.text_stroke(number, x, y, font = "16x20", color = number_color)
    c.text_stroke(label(days), x + number_w + 3, y + 13, font = "5x7", color = label_color)

# name -> (scene, title color, number color, label color). Each palette comes from
# its scene: roast gold, leaf colors, moonlight and pumpkin, and so on. All text is
# stroked, because every scene fills in behind the count.
DESIGNS = {
    "Thanksgiving table": ("scenetable.png", AMBER, "#EBB060", "#FFF6E0"),
    "Turkey and fall tree": ("sceneturkey.png", "#F5C542", "#F28C28", "#F5C542"),
    "Fall scene": ("scenefall.png", "#F5C542", "#FFF6E0", "#FFF6E0"),
    "Cornucopia": ("scenecornucopia.png", "#F5C542", "#F28C28", "#FFF6E0"),
    "Harvest moon": ("sceneharvest.png", "#F28C28", "#F7E7B0", "#F7E7B0"),
}

def countdown(c, ctx):
    name = ctx.inputs.get("design", "Thanksgiving table")
    if name not in DESIGNS:
        name = "Thanksgiving table"
    scene, title, number, small = DESIGNS[name]
    c.fill("black")
    c.image(scene, 0, 0)
    days = days_left(ctx)

    if name == "Thanksgiving table":
        # The title lies on the tablecloth, which starts at y 24.
        put_center(c, "THANKSGIVING", 25, "5x7", title)
        if days == 0:
            put_center(c, "HAPPY", 4, "10x16", number)
        else:
            count(c, days, 2, number, small)
    elif days == 0:
        put_center(c, "HAPPY", 3, "10x16", number)
        put_center(c, "THANKSGIVING", 21, "5x7", title)
    else:
        put_center(c, "THANKSGIVING", 0, "5x7", title)
        count(c, days, 8, number, small)
