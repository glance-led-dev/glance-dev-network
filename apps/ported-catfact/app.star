# Ported from the tidbyt/community "Catfact" app (apps/catfact/catfact.star).
#
# ORIGINAL Pixlet render: an 8x8 cat Image + render.Text("Cat Fact:") in a Row,
# then a VERTICAL render.Marquee scrolling a render.WrappedText of the fact
# fetched from the catfact.ninja API.
#
# `gdn translate` flagged http.* + cache + load() and the Marquee/Row/Column/
# Image/Text/WrappedText widgets. Hand-finished for GDN (static 64x32): no
# network, so the fact is a bundled sample; the vertical marquee became
# statically wrapped text; the base64 PNG cat icon became a c.bitmap.
# Bitmap fonts are UPPERCASE-only, so display text is .upper()'d.

CAT = [
    [0, 1, 0, 0, 0, 0, 1, 0],
    [0, 1, 1, 0, 0, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 0, 1, 1, 0, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 1, 1, 1, 1, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 0, 1, 1, 0, 1, 0],
]

# Offline sample (the live app calls catfact.ninja/fact every 4 minutes).
FACT = "A CAT HAS 32 MUSCLES IN EACH EAR"

def wrap(c, text, maxw, font):
    words = text.split(" ")
    lines = []
    cur = ""
    for w in words:
        trial = cur + " " + w if cur else w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines

def main(c, ctx):
    c.fill("black")
    c.bitmap(CAT, 2, 1, "gray")
    c.text("CAT FACT", 13, 2, font = "5x7", color = "yellow")
    c.line(0, 10, c.width - 1, 10, "midgray")
    lines = wrap(c, FACT.upper(), c.width - 2, "4x5")
    y = 13
    for i in range(len(lines)):
        if y > c.height - 5:
            break
        c.text(lines[i], 1, y, font = "4x5", color = "white")
        y += 6
