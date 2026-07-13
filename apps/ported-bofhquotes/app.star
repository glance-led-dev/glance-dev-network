# Ported from the tidbyt/community "BOFH Quotes" app (apps/bofhquotes/bofh_quotes.star).
#
# ORIGINAL Pixlet: a large table of excuses, random.number() picks one, shown in
# a render.Marquee. This is the classic "Bastard Operator From Hell" excuse
# generator.
#
# `gdn translate` flagged random.* + load() and the Marquee/Text widgets. Hand-
# finished for GDN (static 64x32): the QUOTES DATA TABLE ports verbatim (a subset
# here); randomness is replaced with a deterministic pick from the frozen
# ctx.now; the marquee became statically wrapped text. UPPERCASE-only fonts.

# Real excuses from the original app's table (a representative subset).
QUOTES = [
    "CLOCK SPEED",
    "SOLAR FLARES",
    "STATIC FROM NYLON UNDERWEAR",
    "GLOBAL WARMING",
    "POOR POWER CONDITIONING",
    "DOPPLER EFFECT",
    "HARDWARE STRESS FRACTURES",
    "DRY JOINTS ON CABLE PLUG",
    "TEMPORARY ROUTING ANOMALY",
    "FAT ELECTRONS IN THE LINES",
    "FLOATING POINT PROCESSOR OVERFLOW",
    "DIVIDE-BY-ZERO ERROR",
    "POSIX COMPLIANCE PROBLEM",
    "MONITOR RESOLUTION TOO HIGH",
    "IMPROPERLY ORIENTED KEYBOARD",
    "DECREASING ELECTRON FLUX",
    "RADIOSITY DEPLETION",
    "CPU RADIATOR BROKEN",
    "POSITRON ROUTER MALFUNCTION",
    "PIEZO-ELECTRIC INTERFERENCE",
    "(L)USER ERROR",
    "WORKING AS DESIGNED",
    "DYNAMIC SOFTWARE LINKING TABLE CORRUPTED",
    "TECHTONIC STRESS",
]

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
    # Deterministic "random" pick from the frozen render time.
    idx = ctx.now.unix // 60 % len(QUOTES)
    quote = QUOTES[idx]

    c.fill("black")
    c.rect(0, 0, c.width - 1, 6, fill = "red")
    c.text("EXCUSE #" + str(idx + 1), c.width // 2, 1, font = "4x5", color = "white", align = "center")

    # Pick the biggest font whose wrapped lines fit the area under the header.
    budget = c.height - 8
    font, lh = "4x5", 6
    for f, h in [("5x7", 8), ("4x5", 6)]:
        if len(wrap(c, quote, c.width - 2, f)) * h <= budget:
            font, lh = f, h
            break
    lines = wrap(c, quote, c.width - 2, font)
    total = len(lines) * lh
    y = 8 + max(0, (budget - total) // 2)
    for i in range(len(lines)):
        c.text(lines[i], c.width // 2, y, font = font, color = "green", align = "center")
        y += lh
