# Ported from the tidbyt/community "Analog Clock" app (apps/analogclock/analog_clock.star).
#
# ORIGINAL Pixlet: renders an analog clock by compositing PRE-RENDERED base64 PNG
# hand images (a separate image per minute/hour-hand position) in a render.Stack,
# with the month and day drawn beside it.
#
# `gdn translate` flagged base64/json/time/load() and the Stack/Image/Text
# widgets. Hand-finished for GDN (static 64x32): rather than ship dozens of hand
# PNGs, the render approach was REWRITTEN — the hands are computed with trig and
# drawn with c.line from ctx.now (+ a UTC-offset input), the face is drawn with
# hour ticks, and the month/day sit to the right.

PI2 = 6.283185307179586

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def main(c, ctx):
    off = int(ctx.inputs.get("tz_offset", -5))
    secs = (ctx.now.unix + off * 3600) % 86400
    hh = secs // 3600
    mm = (secs % 3600) // 60

    cx = 15
    cy = 15
    r = 14

    c.fill("black")

    # face: 12 hour ticks (brighter at 12/3/6/9)
    for i in range(12):
        a = PI2 * i / 12.0
        tx = cx + int(r * math.sin(a) + 0.5)
        ty = cy - int(r * math.cos(a) + 0.5)
        col = "white" if i % 3 == 0 else "midgray"
        c.pixel(tx, ty, col)

    # hands
    min_a = PI2 * mm / 60.0
    hour_a = PI2 * ((hh % 12) + mm / 60.0) / 12.0
    mlen = r - 2
    hlen = r - 6
    c.line(cx, cy, cx + int(mlen * math.sin(min_a) + 0.5), cy - int(mlen * math.cos(min_a) + 0.5), "white")
    c.line(cx, cy, cx + int(hlen * math.sin(hour_a) + 0.5), cy - int(hlen * math.cos(hour_a) + 0.5), "yellow")
    c.rect(cx - 1, cy - 1, cx + 1, cy + 1, fill = "red")

    # month + day to the right
    mon = MONTHS[ctx.now.month - 1]
    c.text(mon, 48, 4, font = "5x7", color = "cyan", align = "center")
    c.text(str(ctx.now.day), 48, 13, font = "10x16", color = "white", align = "center")
