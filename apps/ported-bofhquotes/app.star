# Ported from the tidbyt/community "BOFH Quotes" app (apps/bofhquotes/bofh_quotes.star).
#
# ORIGINAL Pixlet: a large table of excuses, random.number() picks one, shown in
# a render.Marquee. This is the classic "Bastard Operator From Hell" excuse
# generator -- a running joke from Simon Travaglia's 1990s stories about a
# sysadmin who blames every outage on something absurd.
#
# `gdn translate` flagged random.* + load() and the Marquee/Text widgets. Hand-
# finished for GDN (static 64x32): the QUOTES DATA TABLE ports verbatim (a subset
# here); randomness is replaced with a deterministic pick from the frozen
# ctx.now; the marquee became statically wrapped text. UPPERCASE-only fonts.

# Real excuses from the original app's table, plus a few in the same spirit.
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
    "BOGON EMISSIONS",
    "STATIC BUILDUP",
    "EXCESS SURGE PROTECTION",
    "SATAN DID IT",
    "DAEMONS DID IT",
    "YOU ARE OUT OF MEMORY",
    "THERE ISNT ANY PROBLEM",
    "UNOPTIMIZED HARD DRIVE",
    "TYPO IN THE CODE",
    "IT IS A DESIGN LIMITATION",
    "BIT BUCKET OVERFLOW",
    "CPU NEEDS RECALIBRATION",
    "SYSTEM NEEDS REBOOTING",
    "NOT PROPERLY GROUNDED",
    "HIGH PRESSURE SYSTEM FAILURE",
    "THE CABLE IS TOO SHORT",
    "ROUTING TABLE CORRUPTION",
    "SUNSPOT ACTIVITY",
    "MAGNETIC INTERFERENCE",
    "COSMIC RAY HIT THE PLATTER",
    "PLENUM CABLE FAILURE",
    "BAD ELECTRONS",
    "QUANTUM FLUCTUATIONS",
    "OPERATOR ERROR",
    "IT WORKS ON MY MACHINE",
    "THE SERVER IS SULKING",
    "INSUFFICIENT COFFEE",
    "GROUNDSKEEPERS TOOK THE PASSWORD",
    "NESTING ROACHES IN THE CABLE",
    "EVIL DOGS HYPNOTISED NIGHT SHIFT",
    "WAITING ON THE PHONE COMPANY",
    "SOMEBODY WAS CALCULATING PI",
    "NETWORK PACKETS TRAVELLING UPHILL",
    "FIRST FULL MOON OF WINTER",
    "ELECTRICIANS MADE POPCORN IN THE PSU",
    "THE FILE SYSTEM IS FULL OF IT",
    "MERCURY IS IN RETROGRADE",
    "TOO MANY TABS OPEN",
    "RANDOM NUMBER GENERATOR SAID NO",
    "THE INTERN TOUCHED SOMETHING",
    "IT IS DNS. IT IS ALWAYS DNS",
]

# Each tier is [font, line height]. The first one whose wrapped text fits the
# body area wins, so long excuses shrink instead of running off the panel.
TIERS = [["5x7", 8], ["4x5", 6], ["4x5", 5]]

HEADER_H = 6          # header band, rows 0..5
BODY_Y = 7            # first row the excuse can use

def wrap(c, text, maxw, font):
    # Split into words, but first chop any single word that is too wide to ever
    # fit -- "DIVIDE-BY-ZERO" is 14 characters and overflows 64px on its own,
    # and a space-only split has no way to break it.
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

def main(c, ctx):
    # Deterministic "random" pick from the frozen render time. The prime stride
    # means consecutive renders jump around the list instead of stepping by one,
    # while still reaching every excuse eventually.
    n = ctx.now.unix // 300
    idx = (n * 7919) % len(QUOTES)
    quote = QUOTES[idx]

    c.fill("black")

    # ----- header band -----
    c.rect(0, 0, c.width - 1, HEADER_H - 1, fill = "red")
    c.text("EXCUSE #" + str(idx + 1), c.width // 2, 0, font = "4x5", color = "white", align = "center")

    # ----- the excuse -----
    budget = c.height - BODY_Y
    maxw = c.width - 2

    font = TIERS[len(TIERS) - 1][0]
    lh = TIERS[len(TIERS) - 1][1]
    lines = wrap(c, quote, maxw, font)

    for t in TIERS:
        cand = wrap(c, quote, maxw, t[0])
        if len(cand) * t[1] <= budget:
            font = t[0]
            lh = t[1]
            lines = cand
            break

    # Absolute last resort: if even the tightest tier overflows, drop the extra
    # lines rather than drawing off the bottom of the panel.
    maxlines = budget // lh
    if len(lines) > maxlines:
        lines = lines[0:maxlines]

    total = len(lines) * lh
    y = BODY_Y + (budget - total) // 2
    if y < BODY_Y:
        y = BODY_Y

    for i in range(len(lines)):
        c.text(lines[i], c.width // 2, y, font = font, color = "green", align = "center")
        y = y + lh