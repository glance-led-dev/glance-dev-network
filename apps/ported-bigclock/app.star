# Ported from the tidbyt/community "Big Clock" app (apps/bigclock/big_clock.star).
#
# ORIGINAL Pixlet: a large retro clock built from base64 PNG number images tinted
# by a render.Box, laid out in a render.Row (HH : MM) with a flashing separator,
# animated across a minute; the color fades between day/night using the sunrise
# module and the configured location. Supports 12/24h and a leading zero.
#
# `gdn translate` converted the schema (Location + toggles) and flagged
# sunrise/time/re/base64/json/load() and the Row/Box/Image/Animation widgets.
# Hand-finished for GDN (static 64x32): the base64 number images became a big
# bitmap FONT; ctx.now is UTC so time is computed from a UTC-offset input; the
# 12/24h + leading-zero LOGIC ports; the sunrise fade became a simple day/night
# color pick (no network); the flashing separator is a static colon.

def pad2(n):
    return str(n) if n >= 10 else "0" + str(n)

def main(c, ctx):
    off = int(ctx.inputs.get("tz_offset", -5))
    fmt = ctx.inputs.get("hour_format", "24")
    lz = ctx.inputs.get("leading_zero", "no")

    secs = (ctx.now.unix + off * 3600) % 86400
    hh = secs // 3600
    mm = (secs % 3600) // 60

    ampm = ""
    if fmt == "12":
        ampm = "AM" if hh < 12 else "PM"
        h = hh % 12
        if h == 0:
            h = 12
    else:
        h = hh

    hh_str = pad2(h) if lz == "yes" else str(h)
    time_str = hh_str + ":" + pad2(mm)

    # simple day/night color (a static stand-in for the sunrise-based fade)
    color = "yellow" if 6 <= hh and hh < 19 else "#7aa0ff"

    c.fill("black")
    c.text(time_str, c.width // 2, 8, font = "10x16_bold", color = color, align = "center")
    if ampm != "":
        c.text(ampm, c.width - 1, 1, font = "4x5", color = "gray", align = "right")
