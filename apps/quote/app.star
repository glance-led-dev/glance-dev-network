# Daily Quote - a short quote chosen by the day of year. (192x32)
# No inputs: it just uses ctx.now.
#
# WHY THERE IS NO API CALL: the free quote APIs are a poor fit here. ZenQuotes
# caps the free tier at 5 requests per 30 seconds AND requires a visible link
# back to their site, which a 32px panel cannot show. Quotable is keyless but
# has a history of outages. More importantly, both are full of misattributed
# quotes -- Einstein, Twain and Churchill get credited with things they never
# said -- and this app puts an author's name on screen. A curated list is the
# only way to be sure the attribution is right.
#
# Entries with an empty author are proverbs or common sayings with no single
# origin, so nothing is claimed for them.

QUOTES = [
    ["SPEAK SOFTLY AND CARRY A BIG STICK", "THEODORE ROOSEVELT"],
    ["THE ONLY THING WE HAVE TO FEAR IS FEAR ITSELF", "FRANKLIN D ROOSEVELT"],
    ["A HOUSE DIVIDED AGAINST ITSELF CANNOT STAND", "ABRAHAM LINCOLN"],
    ["FOUR SCORE AND SEVEN YEARS AGO", "ABRAHAM LINCOLN"],
    ["GIVE ME LIBERTY OR GIVE ME DEATH", "PATRICK HENRY"],
    ["THESE ARE THE TIMES THAT TRY MENS SOULS", "THOMAS PAINE"],
    ["NEVER GIVE IN. NEVER, NEVER, NEVER", "WINSTON CHURCHILL"],
    ["IT ALWAYS SEEMS IMPOSSIBLE UNTIL IT IS DONE", "NELSON MANDELA"],
    ["THE UNEXAMINED LIFE IS NOT WORTH LIVING", "SOCRATES"],
    ["I KNOW THAT I KNOW NOTHING", "SOCRATES"],
    ["I THINK THEREFORE I AM", "RENE DESCARTES"],
    ["MAN IS THE MEASURE OF ALL THINGS", "PROTAGORAS"],
    ["NO MAN STEPS IN THE SAME RIVER TWICE", "HERACLITUS"],
    ["FORTUNE FAVORS THE BOLD", "VIRGIL"],
    ["I CAME, I SAW, I CONQUERED", "JULIUS CAESAR"],
    ["THAT WHICH DOES NOT KILL US MAKES US STRONGER", "FRIEDRICH NIETZSCHE"],
    ["HELL IS OTHER PEOPLE", "JEAN-PAUL SARTRE"],
    ["WHEREOF ONE CANNOT SPEAK, ONE MUST BE SILENT", "LUDWIG WITTGENSTEIN"],
    ["POWER TENDS TO CORRUPT", "LORD ACTON"],
    ["KNOWLEDGE IS POWER", "FRANCIS BACON"],
    ["SCIENCE IS ORGANIZED KNOWLEDGE", "HERBERT SPENCER"],
    ["IMAGINATION IS MORE IMPORTANT THAN KNOWLEDGE", "ALBERT EINSTEIN"],
    ["THE ONLY SOURCE OF KNOWLEDGE IS EXPERIENCE", "ALBERT EINSTEIN"],
    ["IF I HAVE SEEN FURTHER IT IS BY STANDING ON THE SHOULDERS OF GIANTS", "ISAAC NEWTON"],
    ["A JOURNEY OF A THOUSAND MILES BEGINS WITH A SINGLE STEP", "LAO TZU"],
    ["NATURE DOES NOT HURRY", "LAO TZU"],
    ["WELL DONE IS BETTER THAN WELL SAID", "BENJAMIN FRANKLIN"],
    ["AN INVESTMENT IN KNOWLEDGE PAYS THE BEST INTEREST", "BENJAMIN FRANKLIN"],
    ["THE MASS OF MEN LEAD LIVES OF QUIET DESPERATION", "HENRY DAVID THOREAU"],
    ["SIMPLIFY, SIMPLIFY", "HENRY DAVID THOREAU"],
    ["THE BEST WAY OUT IS ALWAYS THROUGH", "ROBERT FROST"],
    ["HOPE IS THE THING WITH FEATHERS", "EMILY DICKINSON"],
    ["NOT ALL THOSE WHO WANDER ARE LOST", "J R R TOLKIEN"],
    ["BREVITY IS THE SOUL OF WIT", "WILLIAM SHAKESPEARE"],
    ["ALL THE WORLDS A STAGE", "WILLIAM SHAKESPEARE"],
    ["THE PEN IS MIGHTIER THAN THE SWORD", "EDWARD BULWER-LYTTON"],
    ["THE MEDIUM IS THE MESSAGE", "MARSHALL MCLUHAN"],
    ["FORM FOLLOWS FUNCTION", "LOUIS SULLIVAN"],
    ["LESS BUT BETTER", "DIETER RAMS"],
    ["THE BEST WAY TO PREDICT THE FUTURE IS TO INVENT IT", "ALAN KAY"],
    ["PREMATURE OPTIMIZATION IS THE ROOT OF ALL EVIL", "DONALD KNUTH"],
    ["SIMPLICITY IS PREREQUISITE FOR RELIABILITY", "EDSGER DIJKSTRA"],
    ["TALK IS CHEAP. SHOW ME THE CODE", "LINUS TORVALDS"],
    ["MAKE IT WORK, MAKE IT RIGHT, MAKE IT FAST", "KENT BECK"],
    ["THE ONLY WAY TO DO GREAT WORK IS TO LOVE WHAT YOU DO", "STEVE JOBS"],
    ["WE ARE WHAT WE REPEATEDLY DO", "WILL DURANT"],
    ["STAY HUNGRY, STAY FOOLISH", "WHOLE EARTH CATALOG"],
    ["DONE IS BETTER THAN PERFECT", ""],
    ["SHIP EARLY, SHIP OFTEN", ""],
    ["KEEP IT SIMPLE", ""],
    ["MEASURE TWICE, CUT ONCE", ""],
    ["FALL SEVEN TIMES, STAND UP EIGHT", ""],
    ["ACTIONS SPEAK LOUDER THAN WORDS", ""],
    ["PROGRESS OVER PERFECTION", ""],
    ["SMALL STEPS EVERY DAY", ""],
    ["DREAM BIG, START SMALL", ""],
    ["A PICTURE IS WORTH A THOUSAND WORDS", ""],
]

# Line height per font, chosen so there is ALWAYS at least a 1px gap between
# lines. These fonts render taller than their names suggest, so the numbers are
# deliberately generous.
LINE_H = {
    "7x12": 14,
    "6x8": 10,
    "5x7": 9,
    "4x5": 6,
}

FONTS = ["7x12", "6x8", "5x7", "4x5"]

AUTHOR_Y = 23        # author line sits here when there is one

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

def quote(c, ctx):
    # One quote per day. The prime stride jumps around the list instead of
    # stepping through it in order, while still reaching every entry.
    idx = (ctx.now.yday * 7919 + ctx.now.year) % len(QUOTES)
    text = QUOTES[idx][0]
    author = QUOTES[idx][1]

    c.fill("black")

    maxw = c.width - 6

    # An unattributed saying gets the whole panel; an attributed one leaves
    # room for the author line along the bottom.
    budget = AUTHOR_Y - 1 if author else c.height

    # Biggest font whose wrapped lines fit the space available.
    font = FONTS[len(FONTS) - 1]
    lh = LINE_H[font]
    lines = wrap(c, text, maxw, font)

    for f in FONTS:
        cand = wrap(c, text, maxw, f)
        if len(cand) * LINE_H[f] <= budget:
            font = f
            lh = LINE_H[f]
            lines = cand
            break

    # Never draw past the area we allotted.
    maxlines = budget // lh
    if len(lines) > maxlines:
        lines = lines[0:maxlines]

    total = len(lines) * lh
    y = max(0, (budget - total) // 2)

    for i in range(len(lines)):
        col = "yellow" if i == 0 else "white"
        c.text(lines[i], c.width // 2, y, font = font, color = col, align = "center")
        y = y + lh

    if author:
        c.text("- " + author, c.width // 2, AUTHOR_Y, font = "5x7", color = "#7C8BA6", align = "center")