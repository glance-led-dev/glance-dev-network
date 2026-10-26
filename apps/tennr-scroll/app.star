# Tennr — a GDN Starlark app (logo, 1 page).
#
# DESIGN. The Tennr mark (two offset blocks, from the official logo) in brand
# coral, with the TENNR name in off-white, on a black ground. The mark and name
# are measured as one group and centered, so nothing sits at an edge. On 64px
# the group fills the panel; on wider scroll panels it is larger and stays
# inside the safe zone (6-10 px of padding at the outer edges).

CORAL = "#DC8674"
OFFWHITE = "#FBFBF9"
NAME = "TENNR"

def logo(c, ctx):
    c.fill("black")

    if c.width >= 128:
        mark, mw, mh = "MARK_L.png", 20, 22
        font, gap = "16x20", 8
    else:
        mark, mw, mh = "MARK.png", 14, 16
        font, gap = "7x12", 4

    fh = {"16x20": 20, "7x12": 12}[font]
    tw = c.measure_text(NAME, font) if hasattr(c, "measure_text") else len(NAME) * (16 if font == "16x20" else 7)
    group_w = mw + gap + tw
    x0 = (c.width - group_w) // 2

    c.image(mark, x0, (c.height - mh) // 2)
    c.text(NAME, x0 + mw + gap, (c.height - fh) // 2, font = font, color = OFFWHITE)
