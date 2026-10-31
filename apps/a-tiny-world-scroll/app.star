# A Tiny World -- a solarpunk settlement inside an ancient machine.
#
# Hidden preview inputs:
#   _debugscene = DAWN | DAY | DUSK | NIGHT | STORM | FESTIVAL
#   _debugage   = EMPTY | BUILD | GROW | DIVIDE | RUIN | REGROW
# The civilization advances one stage every six hours (four times per day).

SKY = {
    "DAWN": ["#160D2D", "#6E294B", "#E56B55"],
    "DAY": ["#082D45", "#0D6580", "#36A8A0"],
    "DUSK": ["#1A1238", "#79304F", "#E17A45"],
    "NIGHT": ["#030511", "#08142A", "#102A3A"],
    "STORM": ["#080B12", "#182331", "#30404B"],
    "FESTIVAL": ["#09051B", "#281240", "#512653"],
}

AGES = {"EMPTY": 0, "BUILD": 1, "GROW": 2, "DIVIDE": 3, "RUIN": 4, "REGROW": 5}
AGE_NAMES = ["EMPTY", "BUILD", "GROW", "DIVIDE", "RUIN", "REGROW"]
AGE_LABELS = ["START", "BUILD", "GROW", "SPLIT", "RUINS", "RETURN"]
STAR_X = [3, 9, 16, 24, 31, 39, 47, 55, 61, 70, 79, 88, 98, 109, 121, 133, 146, 157, 169, 179]
STAR_Y = [3, 8, 5, 11, 2, 7, 4, 10, 6, 3, 9, 5, 2, 8, 4, 10, 6, 3, 9, 5]


def state(ctx):
    tick = ctx.now.unix // 300
    hour = (ctx.now.unix // 3600) % 24
    day = ctx.now.unix // 86400
    world_day = max(0, day - 20000)
    if hour < 5 or hour >= 21:
        scene = "NIGHT"
    elif hour < 8:
        scene = "DAWN"
    elif hour < 17:
        scene = "DAY"
    else:
        scene = "DUSK"
    if day % 17 == 4:
        scene = "STORM"
    elif day % 13 == 7 and scene in ["DUSK", "NIGHT"]:
        scene = "FESTIVAL"
    debug_scene = str(ctx.inputs.get("_debugscene", "")).upper()
    if debug_scene in SKY:
        scene = debug_scene
    world_step = max(0, (ctx.now.unix - 20000 * 86400) // 21600)
    age = world_step % len(AGE_NAMES)
    debug_age = str(ctx.inputs.get("_debugage", "")).upper()
    if debug_age in AGES:
        age = AGES[debug_age]
    return {"scene": scene, "age": age, "tick": tick, "day": world_day}


def label_for(s):
    if s["scene"] == "FESTIVAL":
        return "FEST"
    if s["scene"] == "STORM":
        return "STORM"
    return AGE_LABELS[s["age"]]


def header(c, s):
    c.rect(0, 0, c.width - 1, 6, fill = "#030609")
    label = label_for(s)
    if c.width >= 128:
        c.text("TINY WORLD", 12, 1, font = "4x5", color = "#8EE3C1")
        c.text(label, c.width // 2, 1, font = "4x5", color = "#FFD35A", align = "center")
        c.text("DAY %d" % s["day"], c.width - 12, 1, font = "4x5", color = "#86A2AD", align = "right")
    else:
        c.text(label, 2, 1, font = "4x5", color = "#FFD35A")
        c.text("D%d" % s["day"], c.width - 2, 1, font = "4x5", color = "#86A2AD", align = "right")


def draw_sky(c, s, x0, x1):
    colors = SKY[s["scene"]]
    c.rect(x0, 7, x1, 11, fill = colors[0])
    c.rect(x0, 12, x1, 16, fill = colors[1])
    c.rect(x0, 17, x1, 20, fill = colors[2])
    if s["scene"] in ["NIGHT", "FESTIVAL"]:
        span = x1 - x0
        for i in range(len(STAR_X)):
            x = x0 + STAR_X[i] % span
            if x <= x1:
                col = "#FFF1A8" if (i + s["tick"]) % 3 == 0 else "#7AA6B8"
                c.pixel(x, 7 + STAR_Y[i] % 12, col)
    body_x = x1 - 9
    if s["scene"] in ["DAY", "DAWN"]:
        c.fill_circle(body_x, 11, 3, "#FFD35A")
        c.pixel(body_x - 4, 11, "#FFD35A")
        c.pixel(body_x + 4, 11, "#FFD35A")
        c.pixel(body_x, 7, "#FFD35A")
        c.pixel(body_x, 15, "#FFD35A")
    elif s["scene"] in ["DUSK", "NIGHT", "FESTIVAL"]:
        c.fill_circle(body_x, 11, 3, "#DCE9D4")
        c.fill_circle(body_x + 2, 10, 3, colors[0])
    if s["scene"] == "STORM":
        for x in range(x0 + 4, x1, 9):
            c.line(x, 11 + x % 3, x - 2, 15 + x % 3, "#62A8B5")


def hills(c, x0, x1):
    c.line(x0, 20, x0 + 12, 15, "#174F50")
    c.line(x0 + 12, 15, x0 + 25, 20, "#174F50")
    c.line(x0 + 20, 20, x0 + 38, 13, "#174F50")
    c.line(x0 + 38, 13, min(x1, x0 + 57), 20, "#174F50")
    if x1 - x0 > 80:
        c.line(x0 + 52, 20, x0 + 77, 15, "#174F50")
        c.line(x0 + 77, 15, x0 + 103, 20, "#174F50")
        c.line(x0 + 98, 20, x0 + 125, 14, "#174F50")
        c.line(x0 + 125, 14, min(x1, x0 + 150), 20, "#174F50")


def ancient_ring(c, cx, cy, r, broken):
    col = "#536760" if broken else "#748D7F"
    c.circle(cx, cy, r, col)
    c.circle(cx, cy, r - 2, "#263D3B")
    c.line(cx, cy - r, cx, cy - r + 4, col)
    c.line(cx - r, cy, cx - r + 4, cy, col)
    c.line(cx + r - 4, cy, cx + r, cy, col)
    if not broken:
        c.line(cx - 4, cy + 1, cx + 4, cy - 3, "#A7C6A8")
        c.fill_circle(cx, cy, 1, "#E9C46A")


def cliff(c, x0, x1, top):
    c.rect(x0, top, x1, 31, fill = "#273B34")
    c.line(x0, top, x1, top, "#6FA45B")
    c.line(x0 + 2, top + 6, x1 - 3, top + 9, "#395348")
    for x in range(x0 + 4, x1, 11):
        c.pixel(x, top + 4 + x % 7, "#7C8B64")


def house(c, x, ground, w, h, roof, lit, damaged):
    y = ground - h
    wall = "#6B765E" if damaged else "#A08B67"
    c.rect(x, y, x + w - 1, ground - 1, fill = wall, outline = "#17201D")
    c.line(x - 1, y, x + w // 2, y - 3, roof)
    c.line(x + w // 2, y - 3, x + w, y, roof)
    c.line(x, y + 1, x + w - 1, y + 1, "#C1A777")
    window = "#FFC857" if lit else "#213C3B"
    c.rect(x + 2, ground - 4, x + 3, ground - 2, fill = window)
    if w >= 9:
        c.rect(x + w - 4, ground - 4, x + w - 3, ground - 2, fill = window)
    c.rect(x + w // 2 - 1, ground - 4, x + w // 2 + 1, ground - 1, fill = "#332921")
    if damaged:
        c.line(x + w - 3, y - 2, x + w, y - 4, "#17201D")
        c.pixel(x + 1, ground - 3, "#17201D")


def scaffold(c, x, ground, w, h):
    c.line(x, ground, x, ground - h, "#B78A52")
    c.line(x + w, ground, x + w, ground - h, "#B78A52")
    c.line(x, ground - h + 2, x + w, ground - h + 2, "#B78A52")
    c.line(x, ground - 2, x + w, ground - h, "#715D43")


def person(c, x, ground, color, step):
    c.rect(x, ground - 6, x + 1, ground - 5, fill = "#E5B980")
    c.rect(x - 1, ground - 4, x + 2, ground - 2, fill = color)
    if step % 2 == 0:
        c.pixel(x - 1, ground - 1, color)
        c.pixel(x + 2, ground, color)
    else:
        c.pixel(x - 1, ground, color)
        c.pixel(x + 2, ground - 1, color)


def big_person(c, x, ground, color, facing, tool):
    c.rect(x, ground - 9, x + 2, ground - 7, fill = "#E5B980", outline = "#382820")
    c.rect(x - 1, ground - 6, x + 3, ground - 3, fill = color, outline = "#17201D")
    c.line(x, ground - 2, x - 1, ground, "#243330")
    c.line(x + 2, ground - 2, x + 3, ground, "#243330")
    arm_x = x + 4 if facing > 0 else x - 2
    c.line(x + 1, ground - 5, arm_x, ground - 4, color)
    if tool:
        c.line(arm_x, ground - 7, arm_x, ground - 2, "#C99A58")
        c.line(arm_x - 2, ground - 7, arm_x + 2, ground - 7, "#87928A")


def tree(c, x, ground, alive):
    c.rect(x, ground - 10, x + 2, ground, fill = "#6D4C35")
    c.line(x + 1, ground - 8, x - 5, ground - 13, "#6D4C35")
    c.line(x + 1, ground - 7, x + 6, ground - 12, "#6D4C35")
    if alive:
        c.fill_circle(x - 4, ground - 14, 4, "#4F9B72")
        c.fill_circle(x + 2, ground - 15, 5, "#63B66F")
        c.fill_circle(x + 7, ground - 13, 4, "#3E885C")


def tent(c, x, ground):
    c.line(x, ground, x + 10, ground - 12, "#E9C46A")
    c.line(x + 10, ground - 12, x + 20, ground, "#E9C46A")
    c.line(x, ground, x + 20, ground, "#715D43")
    c.line(x + 10, ground - 11, x + 10, ground, "#715D43")


def lanterns(c, x0, x1, y, tick):
    c.line(x0, y, x1, y + 1, "#6E526F")
    colors = ["#FFCF56", "#FF6B6B", "#63E6BE"]
    for x in range(x0 + 3, x1, 7):
        c.pixel(x, y + 2, colors[(x + tick) % 3])


def waterfall(c, x, top, bottom, tick):
    c.line(x, top, x, bottom, "#69D2D0")
    c.line(x + 1, top + 1, x + 1, bottom, "#237E8A")
    c.pixel(x - 1 + tick % 3, bottom, "#B7F5E8")


def compact_world(c, s):
    draw_sky(c, s, 0, 63)
    c.rect(0, 25, 63, 31, fill = "#273B34")
    c.line(0, 25, 63, 25, "#6FA45B")
    lit = s["scene"] in ["NIGHT", "DUSK", "FESTIVAL", "STORM"]
    age = s["age"]
    if age == 0:
        tent(c, 38, 26)
        c.line(34, 26, 34, 11, "#C9B36A")
        c.line(34, 11, 42, 14, "#8EE3C1")
        big_person(c, 8, 29, "#B5487A", 1, False)
        big_person(c, 22, 29, "#3AB0A2", 1, True)
    elif age == 1:
        c.rect(34, 17, 60, 25, fill = "#8B795D", outline = "#17201D")
        scaffold(c, 31, 26, 31, 17)
        c.line(31, 17, 62, 17, "#B78A52")
        big_person(c, 7, 29, "#B5487A", 1, True)
        big_person(c, 21, 29, "#3AB0A2", 1, False)
    elif age == 2:
        house(c, 27, 26, 30, 13, "#4F9B72", lit, False)
        tree(c, 9, 27, True)
        big_person(c, 17, 30, "#B5487A", 1, False)
        big_person(c, 59, 30, "#3AB0A2", -1, False)
    elif age == 3:
        house(c, 0, 26, 20, 11, "#B5485D", lit, False)
        house(c, 44, 26, 20, 11, "#3AB0A2", lit, False)
        c.rect(30, 13, 33, 31, fill = "#655C4C")
        c.line(10, 15, 10, 8, "#C9B36A")
        c.line(10, 8, 20, 11, "#B5485D")
        c.line(53, 15, 53, 8, "#C9B36A")
        c.line(53, 8, 43, 11, "#3AB0A2")
        big_person(c, 23, 30, "#B5485D", -1, False)
        big_person(c, 38, 30, "#3AB0A2", 1, False)
    elif age == 4:
        tree(c, 8, 27, False)
        c.rect(28, 20, 59, 26, fill = "#586157", outline = "#17201D")
        c.line(25, 20, 38, 12, "#715D43")
        c.line(38, 12, 48, 18, "#715D43")
        c.line(48, 18, 61, 14, "#715D43")
        c.line(32, 20, 44, 26, "#17201D")
        c.rect(51, 22, 55, 26, fill = "#17201D")
    else:
        house(c, 34, 26, 27, 12, "#4F9B72", lit, False)
        tree(c, 9, 27, True)
        c.fill_circle(25, 24, 3, "#63B66F")
        c.line(25, 27, 25, 22, "#6D4C35")
        big_person(c, 18, 30, "#E9C46A", 1, True)
    if s["scene"] == "FESTIVAL":
        lanterns(c, 2, 61, 9, s["tick"])
    header(c, s)


def wide_world(c, s):
    c.fill("black")
    draw_sky(c, s, 10, 181)
    hills(c, 10, 181)
    cliff(c, 10, 63, 23)
    cliff(c, 64, 127, 20)
    cliff(c, 128, 181, 24)
    ancient_ring(c, 96, 19, 14, s["age"] == 4)
    waterfall(c, 135, 14, 31, s["tick"])
    c.line(57, 22, 71, 18, "#A77B49")
    c.line(57, 23, 71, 19, "#5E4934")
    c.line(121, 19, 133, 23, "#A77B49")
    lit = s["scene"] in ["NIGHT", "DUSK", "FESTIVAL", "STORM"]
    age = s["age"]
    if age == 0:
        scaffold(c, 22, 23, 14, 9)
        scaffold(c, 75, 20, 12, 8)
    elif age == 1:
        house(c, 18, 23, 14, 8, "#4F9B72", lit, False)
        scaffold(c, 42, 23, 12, 9)
        house(c, 111, 20, 12, 7, "#C27A45", lit, False)
    else:
        house(c, 15, 23, 14, 8, "#4F9B72", lit, age == 4)
        house(c, 37, 23, 16, 10, "#C27A45", lit, age == 4)
        house(c, 69, 20, 13, 7, "#4F9B72", lit, False)
        house(c, 111, 20, 12, 7, "#C27A45", lit, age == 4)
        if age in [2, 3, 5]:
            house(c, 145, 24, 15, 9, "#4F9B72", lit, False)
            house(c, 165, 24, 11, 6, "#C27A45", lit, False)
    if age == 3:
        c.line(59, 21, 59, 10, "#C9B36A")
        c.line(59, 10, 68, 13, "#B5485D")
        c.line(137, 22, 137, 11, "#C9B36A")
        c.line(137, 11, 146, 14, "#3AB0A2")
    if age >= 2 and age != 4:
        routes = [31, 61, 88, 125, 151, 171]
        colors = ["#B5487A", "#3AB0A2", "#E9C46A"]
        grounds = [23, 22, 20, 21, 24, 24]
        for i in range(len(routes)):
            drift = (s["tick"] + i * 3) % 5
            person(c, routes[i] + drift, grounds[i], colors[i % 3], s["tick"] + i)
    if s["scene"] == "FESTIVAL":
        lanterns(c, 13, 88, 9, s["tick"])
        lanterns(c, 104, 178, 10, s["tick"] + 1)
    header(c, s)


def intro(c, ctx):
    c.fill("#030609")
    if c.width >= 128:
        c.circle(34, 16, 11, "#4F9B72")
        c.circle(34, 16, 7, "#237E8A")
        c.line(24, 19, 44, 13, "#E9C46A")
        c.text("A TINY WORLD", 67, 8, font = "10x16", color = "#FFD35A")
        person(c, 157, 23, "#B5487A", 0)
        person(c, 168, 23, "#3AB0A2", 1)
    else:
        c.circle(14, 16, 10, "#4F9B72")
        c.circle(14, 16, 6, "#237E8A")
        c.line(5, 19, 23, 13, "#E9C46A")
        c.text("TINY", 30, 7, font = "6x8", color = "#8EE3C1")
        c.text("WORLD", 30, 18, font = "5x7", color = "#FFD35A")


def world(c, ctx):
    s = state(ctx)
    if c.width >= 128:
        wide_world(c, s)
    else:
        compact_world(c, s)
