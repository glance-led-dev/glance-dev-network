# Ported from the tidbyt/community "Binary Clock" app (apps/binaryclock/binary_clock.star).
#
# ORIGINAL Pixlet: six columns (Year, Month, Day, Hour, Minute, Second), each a
# render.Column of render.Box "dots" showing that value in binary (up to 11 bits
# via log2(MAX_VALUE=2048)), with a letter label beneath. It builds 30 frames one
# second apart and plays them as a render.Animation.
#
# `gdn translate` flagged the Location schema + time.*/math.*/json/load() and the
# Row/Column/Box/Animation/Text widgets. Hand-finished for GDN (static 64x32):
# GDN v1 is a single frame, so this is the snapshot at the frozen ctx.now (UTC);
# the render.Box dot grid became c.rect calls. Year is shown as 2 digits so all
# six columns fit 32px tall. Active bit = red, inactive = dark, per the app's
# default colors.

NBITS = 7
POW = [64, 32, 16, 8, 4, 2, 1]

def main(c, ctx):
    n = ctx.now
    cols = [
        (n.year % 100, "Y"),
        (n.month, "M"),
        (n.day, "D"),
        (n.hour, "H"),
        (n.minute, "M"),
        (n.second, "S"),
    ]

    c.fill("black")
    colw = c.width // 6      # 10 px per column
    sqw = 6
    sqh = 2
    gap = 1
    top = 3

    for i in range(6):
        val, label = cols[i]
        cx = i * colw + (colw - sqw) // 2
        for r in range(NBITS):
            bit = (val // POW[r]) % 2
            y = top + r * (sqh + gap)
            fill = "red" if bit == 1 else "#222222"
            c.rect(cx, y, cx + sqw - 1, y + sqh - 1, fill = fill)
        ly = top + NBITS * (sqh + gap) + 1
        c.text(label, i * colw + colw // 2, ly, font = "4x5", color = "white", align = "center")
