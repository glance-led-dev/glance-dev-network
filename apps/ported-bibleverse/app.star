# Ported from the tidbyt/community "Bible Verse" app (apps/bibleverse/bible_verse.star).
#
# ORIGINAL Pixlet render: a render.Column of the colored reference (Text) above a
# render.Marquee scrolling the verse Text, from bible-api.com.
#
# `gdn translate` converted the schema.Color + schema.Dropdown to inputs and
# flagged http.* + load() and the Marquee/Column/Text widgets. Hand-finished for
# GDN (static 64x32): no network, so the verse is a bundled sample; the marquee
# became statically wrapped text. The reference color input is honored.

# Offline sample (the live app fetches a random verse from bible-api.com).
REFERENCE = "PSALM 118:24"
VERSE = "THIS IS THE DAY THE LORD HAS MADE."

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
    ref_color = ctx.inputs.get("color", "#00FF00")
    c.fill("black")
    ref = REFERENCE.upper()
    ref_font = "5x7" if c.text_width(ref, "5x7") <= c.width - 2 else "4x5"
    c.text(ref, c.width // 2, 1, font = ref_font, color = ref_color, align = "center")
    # Pick the biggest font whose wrapped lines fit under the reference.
    budget = c.height - 9
    font, lh = "4x5", 6
    for f, h in [("5x7", 8), ("4x5", 6)]:
        if len(wrap(c, VERSE.upper(), c.width - 2, f)) * h <= budget:
            font, lh = f, h
            break
    lines = wrap(c, VERSE.upper(), c.width - 2, font)
    total = len(lines) * lh
    y = 9 + max(0, (budget - total) // 2)
    for i in range(len(lines)):
        c.text(lines[i], c.width // 2, y, font = font, color = "white", align = "center")
        y += lh
