# Ported from the tidbyt/community "Advice" app (apps/advice/advice.star).
#
# ORIGINAL Pixlet render: a vertical render.Marquee scrolling a padded
# render.WrappedText of a random tip from api.adviceslip.com.
#
# `gdn translate` converted the "Scroll speed" schema.Dropdown to a choice input
# and flagged http.* + cache + load() and the Marquee/Column/Padding/WrappedText
# widgets. Hand-finished for GDN (static 64x32): no network, so the advice is a
# bundled sample; the vertical marquee became statically wrapped text.

# Offline sample (the live app calls api.adviceslip.com).
ADVICE = "DON'T GIVE UP. GREAT THINGS TAKE TIME."

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
    c.rect(0, 0, c.width - 1, 6, fill = "blue")
    c.text("ADVICE", c.width // 2, 1, font = "4x5", color = "white", align = "center")
    # Pick the biggest font whose wrapped lines fit the space under the header.
    budget = c.height - 8
    font, lh = "4x5", 6
    for f, h in [("5x7", 8), ("4x5", 6)]:
        if len(wrap(c, ADVICE.upper(), c.width - 4, f)) * h <= budget:
            font, lh = f, h
            break
    lines = wrap(c, ADVICE.upper(), c.width - 4, font)
    total = len(lines) * lh
    y = 8 + max(0, (budget - total) // 2)
    for i in range(len(lines)):
        c.text(lines[i], c.width // 2, y, font = font, color = "white", align = "center")
        y += lh
