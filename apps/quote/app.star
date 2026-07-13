# Daily Quote — a short quote chosen by the day of year. (192x32)
# No inputs: it just uses ctx.now. Auto-wraps to two lines.

QUOTES = [
    "STAY HUNGRY STAY FOOLISH",
    "DONE IS BETTER THAN PERFECT",
    "MAKE IT WORK THEN MAKE IT FAST",
    "SHIP EARLY SHIP OFTEN",
    "LESS BUT BETTER",
    "KEEP IT SIMPLE",
    "DREAM BIG START SMALL",
    "FALL DOWN SEVEN STAND UP EIGHT",
    "PROGRESS OVER PERFECTION",
    "SMALL STEPS EVERY DAY",
]

def wrap2(c, text, font, maxw):
    words = text.split(" ")
    l1 = ""
    l2 = ""
    for w in words:
        cand = l1 + (" " if l1 else "") + w
        if l2 == "" and c.text_width(cand, font) <= maxw:
            l1 = cand
        else:
            l2 = l2 + (" " if l2 else "") + w
    return l1, l2

def quote(c, ctx):
    q = QUOTES[ctx.now.yday % len(QUOTES)]
    l1, l2 = wrap2(c, q, "6x8", c.width - 6)

    c.fill("black")
    if l2:
        c.text(l1, c.width // 2, 7, font = "6x8", color = "yellow", align = "center")
        c.text(l2, c.width // 2, 18, font = "6x8", color = "white", align = "center")
    else:
        c.text(l1, c.width // 2, 12, font = "6x8", color = "yellow", align = "center")
