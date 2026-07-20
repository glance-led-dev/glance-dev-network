# Ported from the official tidbyt/pixlet Location schema example (docs/schema/location/example.star).
#
# ORIGINAL Pixlet render code:
#   return render.Root(child = render.Marquee(width = 64,
#       child = render.Text("tz: %s" % timezone)))
# with a schema.Location picker whose JSON carries a "timezone" field.
#
# `gdn translate` converted the schema field to a manifest input and flagged the
# Marquee/Root/Text widgets + the load() imports. Hand-finished for GDN (static
# 64x32): the marquee became a two-line static label, and the Location picker
# became a plain timezone string input. See docs/PIXLET_COMPATIBILITY.md.
#
# The upstream example only ECHOED the timezone string back, since its job was
# demonstrating the schema. Here it actually uses it: timeapi.io resolves an
# IANA name to the real local time, which means daylight saving is handled by
# the tz database instead of a hand-maintained offset table. No API key needed.

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def _err(c, title, sub):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "orange")
    c.text("TIMEZONE", c.width // 2, 1, font = "4x5", color = "black", align = "center")
    c.text(title, c.width // 2, 12, font = "5x7", color = "orange", align = "center")
    c.text(sub, c.width // 2, 22, font = "4x5", color = "gray", align = "center")

def main(c, ctx):
    tz = _s(ctx, "tz", "America/New_York")
    fmt = _s(ctx, "hour_format", "12")

    if not tz:
        _err(c, "NO TIMEZONE", "SET ONE IN SETTINGS")
        return

    # http.get returns a DICT: {"status_code":..., "body":..., "json":...}
    r = http.get(
        "https://timeapi.io/api/Time/current/zone",
        params = {"timeZone": tz},
        # A minute of cache lines up with the refresh, so one call per render.
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

    c.fill("black")

    # ----- city across the top -----
    c.text(city, c.width // 2, 0, font = fit_font(c, city, ["5x7", "4x5"], c.width - 2), color = "cyan", align = "center")

    # ----- the time, as big as it fits -----
    tfont = fit_font(c, time_s, ["10x16", "7x12", "6x8"], c.width - 14)
    tw = c.text_width(time_s, tfont)
    tx = (c.width - tw) // 2
    if ampm:
        tx = (c.width - tw - 10) // 2      # leave room for the AM/PM tag

    c.text(time_s, tx, 9, font = tfont, color = "white")

    if ampm:
        c.text(ampm, tx + tw + 2, 11, font = "4x5", color = "gray")
        # DST tag sits under AM/PM, so you can see the zone is on summer time.
        if dst:
            c.text("DST", tx + tw + 2, 19, font = "4x5", color = "green")

    # ----- date along the bottom -----
    date_s = dow + " " + MONTHS[month - 1] + " " + str(day)
    c.text(date_s, c.width // 2, 26, font = "4x5", color = "gray", align = "center")