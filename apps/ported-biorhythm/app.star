# Ported from the tidbyt/community "Biorhythm" app (apps/biorhythm/biorhythm.star).
#
# ORIGINAL Pixlet: computes days since your birthdate, then draws three sine
# waves (Physical 23d, Emotional 28d, Intellectual 33d) with three render.Plot
# scatter charts stacked in a render.Stack, labelled -P- -E- -I-.
#
# `gdn translate` converted the schema.DateTime and flagged humanize/time/math/
# load() and the Stack/Column/Row/Box/Plot/Text widgets. Hand-finished for GDN
# (static 64x32): the DATE-DIFF + SINE MATH port verbatim; render.Plot became
# c.line sparklines (GDN has no Plot widget) across a +/-16 day window centered
# on today, with a "today" marker and a P/E/I legend.

PI2 = 6.283185307179586

# Serial-day date difference (ported from the original dateDiff()).
def date_diff(d1, m1, y1, d2, m2, y2):
    m1 = float((m1 + 9) % 12)
    y1 = y1 - m1 / 10.0
    x1 = 365 * y1 + y1 / 4 - y1 / 100 + y1 / 400 + (m1 * 306 + 5) / 10 + (d1 - 1)
    m2 = float((m2 + 9) % 12)
    y2 = y2 - m2 / 10.0
    x2 = 365 * y2 + y2 / 4 - y2 / 100 + y2 / 400 + (m2 * 306 + 5) / 10 + (d2 - 1)
    return x2 - x1

def main(c, ctx):
    dt = ctx.inputs.get("bday", "1990-06-15")
    by = int(dt[0:4])
    bm = int(dt[5:7])
    bd = int(dt[8:10])
    n = ctx.now
    dD = date_diff(bd, bm, by, n.day, n.month, n.year)

    c.fill("black")
    cy = 14
    amp = 11.0
    half = c.width / 2.0

    # zero line and "today" marker
    c.line(0, cy, c.width - 1, cy, "#333333")
    c.line(c.width // 2, 1, c.width // 2, c.height - 8, "midgray")

    # (period, color) for Physical / Emotional / Intellectual
    curves = [(23, "yellow"), (28, "red"), (33, "blue")]
    for j in range(len(curves)):
        period, color = curves[j]
        px = -1
        py = -1
        for x in range(c.width):
            day = dD + (x - half) / 2.0        # 2 px per day, centered on today
            y = int(cy - amp * math.sin(PI2 * day / period) + 0.5)
            if px >= 0:
                c.line(px, py, x, y, color)
            px = x
            py = y

    # legend along the bottom
    c.text("P", 6, c.height - 6, font = "4x5", color = "yellow", align = "center")
    c.text("E", c.width // 2, c.height - 6, font = "4x5", color = "red", align = "center")
    c.text("I", c.width - 6, c.height - 6, font = "4x5", color = "blue", align = "center")
