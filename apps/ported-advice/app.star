# Ported from the tidbyt/community "Advice" app (apps/advice/advice.star).
#
# ORIGINAL Pixlet render: a vertical render.Marquee scrolling a padded
# render.WrappedText of a random tip from api.adviceslip.com.
#
# `gdn translate` converted the "Scroll speed" schema.Dropdown to a choice input
# and flagged http.* + cache + load() and the Marquee/Column/Padding/WrappedText
# widgets. Hand-finished for GDN (static 64x32): the vertical marquee became
# statically wrapped text, and the live api.adviceslip.com call is restored --
# it needs no API key. Scroll speed is gone with the marquee.

# Shown if the API is unreachable, so the panel never goes blank.
FALLBACK = "DON'T GIVE UP. GREAT THINGS TAKE TIME."

BODY_Y = 8

# [font, line height]. First tier whose wrapped text fits the body wins, so a
# long slip shrinks instead of running off the panel. picopixel is the narrowest
# bundled font and is the last resort before trimming.
TIERS = [["5x7", 8], ["4x5", 6], ["picopixel", 6]]

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

def get_advice():
    # http.get returns a DICT: {"status_code":..., "body":..., "json":...}
    # The API caches for 2 seconds on its side; the TTL here matches refresh.
    r = http.get("https://api.adviceslip.com/advice", ttl_seconds = 300)

    # ALWAYS check status_code before touching the json
    if r["status_code"] != 200:
        return FALLBACK

    j = r["json"]
    if not j:
        return FALLBACK

    # The text is nested: {"slip": {"id": 135, "advice": "..."}}
    slip = j.get("slip", {})
    advice = slip.get("advice", "")
    if not advice:
        return FALLBACK

    return str(advice)

def main(c, ctx):
    advice = get_advice().upper()

    c.fill("black")
    c.rect(0, 0, c.width - 1, 6, fill = "blue")
    c.text("ADVICE", c.width // 2, 1, font = "4x5", color = "white", align = "center")

    budget = c.height - BODY_Y
    maxw = c.width - 4

    # Biggest font whose wrapped lines fit the space under the header.
    font = TIERS[len(TIERS) - 1][0]
    lh = TIERS[len(TIERS) - 1][1]
    lines = wrap(c, advice, maxw, font)

    for t in TIERS:
        cand = wrap(c, advice, maxw, t[0])
        if len(cand) * t[1] <= budget:
            font = t[0]
            lh = t[1]
            lines = cand
            break

    # Never draw past the bottom edge. If a slip still runs long, mark the cut
    # rather than silently losing the end of the sentence.
    maxlines = budget // lh
    if len(lines) > maxlines:
        lines = lines[0:maxlines]
        last = lines[len(lines) - 1]
        for _ in range(8):
            if c.text_width(last + "...", font) <= maxw:
                break
            last = last[0:len(last) - 1]
        lines[len(lines) - 1] = last + "..."

    total = len(lines) * lh
    y = BODY_Y + (budget - total) // 2
    if y < BODY_Y:
        y = BODY_Y

    for i in range(len(lines)):
        c.text(lines[i], c.width // 2, y, font = font, color = "white", align = "center")
        y = y + lh