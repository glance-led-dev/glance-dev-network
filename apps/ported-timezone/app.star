# Ported from the official tidbyt/pixlet Location schema example (docs/schema/location/example.star).
#
# ORIGINAL Pixlet render code:
#   return render.Root(child = render.Marquee(width = 64,
#       child = render.Text("tz: %s" % timezone)))
# with a schema.Location picker whose JSON carries a "timezone" field.
#
# `gdn translate` converted the schema field to a manifest input and flagged the
# Marquee/Root/Text widgets + the load() imports. Hand-finished for GDN (static
# 64x32). See docs/PIXLET_COMPATIBILITY.md.
#
# LAYOUT IS FIXED. Nothing is measured against the current time, so the render
# only ever takes one of two forms, decided by the digit count of the hour.
#
#   CITY   y=0   5x7    x=32  center
#   DATE   y=25  4x5    x=32  center
#
#   one-digit hour (1:21)      two-digit hour (11:30)
#   TIME   y=8  10x16  right 47    TIME   y=8  10x16  right 53
#   AM/PM  y=10 4x5    left 49     AM/PM  y=10 picopixel right 64
#   DST    y=18 4x5    left 49     DST    y=18 picopixel right 64

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# one-digit hour
TIME_RIGHT_1 = 47
LABEL_X_1 = 49
LABEL_FONT_1 = "4x5"
LABEL_ALIGN_1 = "left"

# two-digit hour
TIME_RIGHT_2 = 53
LABEL_X_2 = 64
LABEL_FONT_2 = "picopixel"
LABEL_ALIGN_2 = "right"

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def _err(c, title, sub):
    c.fill("black")
    c.text("TIMEZONE", 32, 0, font = "5x7", color = "cyan", align = "center")
    c.text(title, 32, 12, font = "5x7", color = "orange", align = "center")
    c.text(sub, 32, 25, font = "4x5", color = "gray", align = "center")

def main(c, ctx):
    tz = _s(ctx, "tz", "America/New_York")
    fmt = _s(ctx, "hour_format", "12")

    if not tz:
        _err(c, "NO ZONE", "SET ONE IN SETTINGS")
        return

    # http.get returns a DICT: {"status_code":..., "body":..., "json":...}
    r = http.get(
        "https://timeapi.io/api/Time/current/zone",
        params = {"timeZone": tz},
        ttl_seconds = 55,
    )

    # ALWAYS check status_code before touching the json
    status = r["status_code"]
    if status == 400 or status == 404:
        _err(c, "BAD ZONE", tz.split("/")[-1].replace("_", " ").upper())
        return
    if status != 200:
        _err(c, "API ERROR", "CODE " + str(status))
        return

    j = r["json"]
    if not j:
        _err(c, "NO DATA", "EMPTY RESPONSE")
        return

    hour = j.get("hour", None)
    minute = j.get("minute", None)
    if hour == None or minute == None:
        _err(c, "NO TIME", "UNEXPECTED REPLY")
        return

    hour = int(hour)
    minute = int(minute)
    month = int(j.get("month", 1))
    day = int(j.get("day", 1))
    dow = str(j.get("dayOfWeek", ""))[0:3].upper()
    dst = j.get("dstActive", False)

    # Bitmap fonts are UPPERCASE-only, so always .upper() display text.
    city = tz.split("/")[-1].replace("_", " ").upper()

    ampm = ""
    h = hour
    if fmt == "12":
        ampm = "AM" if hour < 12 else "PM"
        h = hour % 12
        if h == 0:
            h = 12

    time_s = str(h) + ":" + pad2(minute)

    # The only thing that switches the layout is whether the hour is two digits.
    if h >= 10:
        time_right = TIME_RIGHT_2
        label_x = LABEL_X_2
        label_font = LABEL_FONT_2
        label_align = LABEL_ALIGN_2
    else:
        time_right = TIME_RIGHT_1
        label_x = LABEL_X_1
        label_font = LABEL_FONT_1
        label_align = LABEL_ALIGN_1

    c.fill("black")

    c.text(city, 32, 0, font = "5x7", color = "cyan", align = "center")

    c.text(time_s, time_right, 8, font = "10x16", color = "white", align = "right")

    if ampm:
        c.text(ampm, label_x, 10, font = label_font, color = "gray", align = label_align)

    if dst:
        c.text("DST", label_x, 18, font = label_font, color = "green", align = label_align)

    c.text(dow + " " + MONTHS[month - 1] + " " + str(day), 32, 25, font = "4x5", color = "gray", align = "center")