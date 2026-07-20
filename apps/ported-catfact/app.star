# Ported from the tidbyt/community "Catfact" app (apps/catfact/catfact.star).
#
# ORIGINAL Pixlet render: an 8x8 cat Image + render.Text("Cat Fact:") in a Row,
# then a VERTICAL render.Marquee scrolling a render.WrappedText of the fact
# fetched from the catfact.ninja API.
#
# `gdn translate` flagged http.* + cache + load() and the Marquee/Row/Column/
# Image/Text/WrappedText widgets. Hand-finished for GDN (static 64x32): the
# vertical marquee became statically wrapped text and the base64 PNG cat icon
# became a c.bitmap. The live catfact.ninja call is restored -- it needs no API
# key. A 64px panel only holds three readable lines, so the request asks the API
# for a short fact rather than trimming a long one afterwards.
# Bitmap fonts are UPPERCASE-only, so display text is .upper()'d.

CAT = [
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 0, 0, 0, 0, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 1, 1, 1, 1, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 0, 0, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
]

# Shown if the API is unreachable, so the panel never goes blank.
FALLBACK = "A CAT HAS 32 MUSCLES IN EACH EAR"

BODY_Y = 12          # first row under the divider
LINE_H = 6           # 5px glyph + 1px gap, so lines never touch

# Tried in order. picopixel is narrower, so it only comes out when a fact is
# too long to fit three lines of 4x5.
FONTS = ["4x5", "picopixel"]

def wrap(c, text, maxw, font):
    # Split on spaces, but chop any single word too wide to ever fit -- a
    # space-only split has no way to break one.
    words = []
    for w in text.split(" "):
        for _ in range(8):
            if c.text_width(w, font) <= maxw:
                break
            n = 1
            for k in range(1, len(w)):
                if c.text_width(w[0:k], font) > maxw:
                    break
                n = k
            words.append(w[0:n])
            w = w[n:]
        if w:
            words.append(w)

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

def get_fact():
    # http.get returns a DICT: {"status_code":..., "body":..., "json":...}
    # max_length keeps the reply short enough to fit three lines.
    r = http.get(
        "https://catfact.ninja/fact",
        params = {"max_length": "45"},
        ttl_seconds = 300,
    )

    # ALWAYS check status_code before touching the json
    if r["status_code"] != 200:
        return FALLBACK

    j = r["json"]
    if not j:
        return FALLBACK

    fact = j.get("fact", "")
    if not fact:
        return FALLBACK

    return str(fact)

def main(c, ctx):
    fact = get_fact().upper()

    c.fill("black")
    c.bitmap(CAT, 2, 1, "gray")
    c.text("CAT FACT", 13, 2, font = "5x7", color = "yellow")
    c.line(0, 10, c.width - 1, 10, "midgray")

    maxw = c.width - 2
    maxlines = (c.height - BODY_Y) // LINE_H

    # Use the bigger font when it fits; step down to picopixel only if it does not.
    font = FONTS[len(FONTS) - 1]
    lines = wrap(c, fact, maxw, font)
    for f in FONTS:
        cand = wrap(c, fact, maxw, f)
        if len(cand) <= maxlines:
            font = f
            lines = cand
            break

    # Never draw past the bottom edge. If a fact still runs long, mark the cut
    # rather than silently losing the end of the sentence.
    if len(lines) > maxlines:
        lines = lines[0:maxlines]
        last = lines[len(lines) - 1]
        for _ in range(8):
            if c.text_width(last + "...", font) <= maxw:
                break
            last = last[0:len(last) - 1]
        lines[len(lines) - 1] = last + "..."

    y = BODY_Y
    for i in range(len(lines)):
        c.text(lines[i], 1, y, font = font, color = "white")
        y = y + LINE_H