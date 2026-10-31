# Pixel Migration -- a shared, deterministic creature migration.
#
# Eight creatures advance through eight habitats every six hours. A habitat
# selected on one panel shares the same schedule as that habitat everywhere.
# Hidden preview input: _debugslot = any whole number.

HABITATS = [
    {"name": "MOSS GARDEN", "short": "MOSS", "sky": "#123B38", "ground": "#315B3D", "accent": "#70D06B", "kind": 0},
    {"name": "TIDE POOL", "short": "TIDE", "sky": "#12334E", "ground": "#145A72", "accent": "#55DDE0", "kind": 1},
    {"name": "DUNE CAMP", "short": "DUNE", "sky": "#44284A", "ground": "#A05D38", "accent": "#FFC857", "kind": 2},
    {"name": "CLOUD FARM", "short": "CLOUD", "sky": "#31566E", "ground": "#526D62", "accent": "#DDF4FF", "kind": 3},
    {"name": "EMBER FIELD", "short": "EMBER", "sky": "#291723", "ground": "#4A2826", "accent": "#FF7043", "kind": 4},
    {"name": "MOON GROVE", "short": "MOON", "sky": "#171633", "ground": "#303252", "accent": "#C5A3FF", "kind": 5},
    {"name": "GLASS CAVE", "short": "GLASS", "sky": "#10252C", "ground": "#173D45", "accent": "#7AF4E4", "kind": 6},
    {"name": "REED MARSH", "short": "REEDS", "sky": "#243B42", "ground": "#365B52", "accent": "#B6D66B", "kind": 7},
]

HABITAT_INDEX = {"MOSS GARDEN": 0, "TIDE POOL": 1, "DUNE CAMP": 2, "CLOUD FARM": 3,
                 "EMBER FIELD": 4, "MOON GROVE": 5, "GLASS CAVE": 6, "REED MARSH": 7}

CREATURES = [
    {"name": "LUMEN MOTH", "short": "MOTH", "main": "#FFE66D", "accent": "#FF7FD1", "effect": "GLOW BLOOMS"},
    {"name": "MOSSBACK", "short": "MOSSBACK", "main": "#6BCB77", "accent": "#B7E36D", "effect": "NEW MOSS"},
    {"name": "SKY JELLY", "short": "JELLY", "main": "#61D4FF", "accent": "#B7F3FF", "effect": "RAIN POOLS"},
    {"name": "EMBER FOX", "short": "FOX", "main": "#FF7043", "accent": "#FFD166", "effect": "WARM STONES"},
    {"name": "GLASS SNAIL", "short": "SNAIL", "main": "#75E6DA", "accent": "#D8FFFF", "effect": "GLASS TRAIL"},
    {"name": "ECHO BIRD", "short": "BIRD", "main": "#9B8CFF", "accent": "#F5B8FF", "effect": "SINGING REEDS"},
    {"name": "STAR HARE", "short": "HARE", "main": "#E8E8FF", "accent": "#8FB8FF", "effect": "STAR SEEDS"},
    {"name": "ORBIT FISH", "short": "FISH", "main": "#48CAE4", "accent": "#FFCA6A", "effect": "SILVER SCALES"},
]


def migration(ctx):
    habitat_name = str(ctx.inputs.get("habitat", "MOSS GARDEN")).upper()
    hi = HABITAT_INDEX.get(habitat_name, 0)
    slot = ctx.now.unix // 21600
    debug = str(ctx.inputs.get("_debugslot", "")).strip()
    if debug != "":
        slot = int(debug)
    creature = (hi - slot) % len(CREATURES)
    previous = (creature + 1) % len(CREATURES)
    left = (hi - 1) % len(HABITATS)
    right = (hi + 1) % len(HABITATS)
    seconds_left = 21600 - ctx.now.unix % 21600
    hours_left = max(1, (seconds_left + 3599) // 3600)
    return {"habitat": hi, "creature": creature, "previous": previous,
            "from": left, "next": right, "hours": hours_left, "slot": slot}


def scene_bounds(c):
    return [10, 181] if c.width >= 128 else [0, 63]


def habitat_scene(c, habitat):
    b = scene_bounds(c)
    x0 = b[0]
    x1 = b[1]
    h = HABITATS[habitat]
    c.fill("black")
    c.rect(x0, 7, x1, 18, fill = h["sky"])
    c.rect(x0, 19, x1, 31, fill = h["ground"])
    span = x1 - x0
    kind = h["kind"]
    if kind == 0:
        for x in range(x0 + 5, x1, 19):
            c.rect(x, 15, x + 2, 26, fill = "#6C4E35")
            c.fill_circle(x + 1, 13, 6, "#3F8A55")
        c.hline(x0, x1, 20, "#70D06B")
    elif kind == 1:
        c.rect(x0, 18, x1, 31, fill = "#126B83")
        for x in range(x0 + 2, x1, 15):
            c.hline(x, min(x1, x + 8), 22 + x % 5, "#55DDE0")
        c.fill_circle(x0 + span // 4, 26, 5, "#5D6570")
        c.fill_circle(x0 + span * 3 // 4, 28, 4, "#707A7E")
    elif kind == 2:
        c.line(x0, 24, x0 + span // 3, 17, "#D48A45")
        c.line(x0 + span // 3, 17, x0 + span * 2 // 3, 25, "#D48A45")
        c.line(x0 + span // 2, 25, x1, 19, "#C8763D")
        c.rect(x0 + 8, 16, x0 + 9, 25, fill = "#507A4D")
        c.line(x0 + 9, 20, x0 + 13, 17, "#507A4D")
    elif kind == 3:
        for x in range(x0 + 8, x1, 30):
            c.fill_circle(x, 13 + x % 3, 5, "#C9E8EF")
            c.fill_circle(x + 6, 14 + x % 3, 4, "#DDF4FF")
        c.line(x0 + span // 4, 15, x0 + span // 4, 30, "#A9C4C0")
        c.line(x0 + span // 4, 15, x0 + span // 4 - 6, 11, "#DDF4FF")
        c.line(x0 + span // 4, 15, x0 + span // 4 + 6, 11, "#DDF4FF")
    elif kind == 4:
        c.rect(x0, 22, x1, 31, fill = "#2D1A1C")
        for x in range(x0 + 4, x1, 17):
            c.line(x, 30, x + 7, 23, "#FF7043")
            c.pixel(x + 4, 25, "#FFD166")
    elif kind == 5:
        c.fill_circle(x1 - 10, 13, 6, "#DDD6FF")
        c.fill_circle(x1 - 7, 11, 6, h["sky"])
        for x in range(x0 + 6, x1, 18):
            c.line(x, 16, x, 29, "#61557F")
            c.line(x, 16, x - 4, 12, "#7B6797")
            c.line(x, 16, x + 5, 11, "#7B6797")
    elif kind == 6:
        c.rect(x0, 7, x1, 31, fill = "#0D252B")
        for x in range(x0 + 5, x1, 14):
            c.line(x, 7, x + 3, 14 + x % 5, "#35636A")
            c.line(x + 6, 31, x + 3, 23 - x % 4, h["accent"])
    else:
        c.rect(x0, 22, x1, 31, fill = "#285D61")
        for x in range(x0 + 4, x1, 9):
            c.line(x, 28, x, 14 + x % 6, "#9BBF63")
            c.line(x, 19, x + 3, 16, "#B6D66B")
        c.hline(x0, x1, 25, "#69A7A2")


def header(c, s, title):
    b = scene_bounds(c)
    h = HABITATS[s["habitat"]]
    c.rect(b[0], 0, b[1], 6, fill = "#020506")
    if c.width >= 128:
        c.text(title, 12, 1, font = "4x5", color = h["accent"])
        c.text(h["short"], c.width // 2, 1, font = "4x5", color = "white", align = "center")
        c.text(str(s["hours"]) + "H", 180, 1, font = "4x5", color = "#829496", align = "right")
    else:
        c.text(title, 2, 1, font = "4x5", color = h["accent"])
        c.text(str(s["hours"]) + "H", 62, 1, font = "4x5", color = "#829496", align = "right")


def creature(c, index, cx, ground):
    p = CREATURES[index]
    main = p["main"]
    accent = p["accent"]
    if index == 0:  # moth
        c.fill_circle(cx - 6, ground - 8, 5, main)
        c.fill_circle(cx + 6, ground - 8, 5, main)
        c.line(cx, ground - 13, cx, ground - 2, accent)
        c.pixel(cx - 2, ground - 13, accent)
        c.pixel(cx + 2, ground - 13, accent)
    elif index == 1:  # mossback
        c.fill_circle(cx, ground - 6, 7, main)
        c.rect(cx - 6, ground - 6, cx + 7, ground - 1, fill = main)
        c.fill_circle(cx + 9, ground - 5, 3, accent)
        c.pixel(cx + 10, ground - 6, "black")
        for x in [cx - 5, cx + 3]:
            c.rect(x, ground - 1, x + 2, ground + 1, fill = accent)
    elif index == 2:  # sky jelly
        c.fill_circle(cx, ground - 10, 7, main)
        c.rect(cx - 7, ground - 10, cx + 7, ground - 6, fill = main)
        for x in [cx - 5, cx, cx + 5]:
            c.line(x, ground - 5, x + (1 if x != cx else -1), ground, accent)
        c.pixel(cx - 3, ground - 10, "black")
        c.pixel(cx + 3, ground - 10, "black")
    elif index == 3:  # ember fox
        c.rect(cx - 8, ground - 9, cx + 5, ground - 2, fill = main, outline = "black")
        c.fill_circle(cx + 7, ground - 9, 4, main)
        c.line(cx + 5, ground - 13, cx + 7, ground - 17, accent)
        c.line(cx + 9, ground - 13, cx + 11, ground - 17, accent)
        c.line(cx - 8, ground - 6, cx - 14, ground - 11, accent)
        c.pixel(cx + 9, ground - 10, "black")
    elif index == 4:  # glass snail
        c.fill_circle(cx - 3, ground - 8, 7, accent)
        c.circle(cx - 3, ground - 8, 4, main)
        c.rect(cx - 9, ground - 4, cx + 11, ground, fill = main)
        c.line(cx + 8, ground - 4, cx + 10, ground - 9, accent)
        c.line(cx + 11, ground - 4, cx + 13, ground - 9, accent)
        c.pixel(cx + 10, ground - 9, "black")
    elif index == 5:  # echo bird
        c.fill_circle(cx, ground - 7, 6, main)
        c.fill_circle(cx + 5, ground - 12, 3, accent)
        c.line(cx - 2, ground - 7, cx - 10, ground - 13, accent)
        c.line(cx - 2, ground - 6, cx - 11, ground - 3, main)
        c.line(cx + 7, ground - 12, cx + 11, ground - 10, "#FFD166")
        c.pixel(cx + 6, ground - 13, "black")
    elif index == 6:  # star hare
        c.fill_circle(cx - 2, ground - 6, 6, main)
        c.fill_circle(cx + 5, ground - 11, 4, main)
        c.line(cx + 3, ground - 14, cx + 1, ground - 20, accent)
        c.line(cx + 7, ground - 14, cx + 9, ground - 20, accent)
        c.fill_circle(cx - 9, ground - 8, 3, accent)
        c.pixel(cx + 7, ground - 12, "black")
    else:  # orbit fish
        c.fill_circle(cx, ground - 8, 7, main)
        c.rect(cx - 7, ground - 12, cx + 7, ground - 4, fill = main)
        c.line(cx - 7, ground - 8, cx - 14, ground - 14, accent)
        c.line(cx - 7, ground - 8, cx - 14, ground - 2, accent)
        c.line(cx - 14, ground - 14, cx - 14, ground - 2, accent)
        c.pixel(cx + 5, ground - 10, "black")


def effect(c, index, x0, x1, ground):
    p = CREATURES[index]
    for i in range(7):
        x = x0 + 4 + (i * 17) % max(5, x1 - x0 - 6)
        if index == 0:
            c.line(x, ground, x, ground - 5, "#5E9B55")
            c.fill_circle(x, ground - 7, 2, p["main"])
        elif index == 1:
            c.rect(x, ground - 2, x + 6, ground, fill = p["main"])
        elif index == 2:
            c.fill_circle(x, ground, 3, p["accent"])
            c.hline(x - 4, x + 4, ground, p["main"])
        elif index == 3:
            c.fill_circle(x, ground - 1, 3, p["main"])
            c.pixel(x, ground - 2, p["accent"])
        elif index == 4:
            c.line(x - 3, ground, x + 5, ground - 4, p["accent"])
        elif index == 5:
            c.line(x, ground, x, ground - 8, "#8BA55E")
            c.pixel(x + 2, ground - 7, p["accent"])
        elif index == 6:
            c.pixel(x, ground - 5, p["main"])
            c.pixel(x - 1, ground - 6, p["accent"])
            c.pixel(x + 1, ground - 6, p["accent"])
        else:
            c.line(x - 3, ground - 2, x + 4, ground, p["accent"])


def visitor(c, ctx):
    s = migration(ctx)
    habitat_scene(c, s["habitat"])
    p = CREATURES[s["creature"]]
    if c.width >= 128:
        creature(c, s["creature"], 46, 27)
        c.rect(72, 8, 178, 30, fill = "#030708", outline = HABITATS[s["habitat"]]["accent"])
        c.text_fit(p["name"], 125, 10, ["10x16", "7x12", "6x8"], color = p["main"], align = "center", maxw = 100)
        c.text("VISITING / " + p["effect"], 125, 26, font = "4x5", color = "#91A5A4", align = "center")
    else:
        creature(c, s["creature"], 32, 24)
        c.rect(0, 25, 63, 31, fill = "#030708")
        c.text_fit(p["name"], 32, 25, ["5x7", "4x5"], color = p["main"], align = "center", maxw = 60)
    header(c, s, "VISITOR")


def journey(c, ctx):
    s = migration(ctx)
    h = HABITATS[s["habitat"]]
    p = CREATURES[s["creature"]]
    c.fill("#020506")
    if c.width >= 128:
        xs = [17, 74, 131]
        ids = [s["from"], s["habitat"], s["next"]]
        labels = ["FROM", "NOW", "NEXT"]
        for i in range(3):
            hh = HABITATS[ids[i]]
            c.rect(xs[i], 9, xs[i] + 43, 29, fill = hh["sky"], outline = hh["accent"])
            c.text(labels[i], xs[i] + 21, 11, font = "4x5", color = "#A2B2B1", align = "center")
            c.text_fit(hh["short"], xs[i] + 21, 20, ["6x8", "5x7", "4x5"], color = hh["accent"], align = "center", maxw = 39)
        c.text(">", 67, 16, font = "6x8", color = CREATURES[s["creature"]]["main"], align = "center")
        c.text(">", 124, 16, font = "6x8", color = CREATURES[s["creature"]]["main"], align = "center")
    else:
        rows = [["FROM", HABITATS[s["from"]]["short"]], ["NOW", h["short"]], ["NEXT", HABITATS[s["next"]]["short"]]]
        for i in range(3):
            y = 8 + i * 8
            col = h["accent"] if i == 1 else "#829493"
            c.text(rows[i][0], 3, y, font = "4x5", color = "#829493")
            c.text(rows[i][1], 61, y, font = "4x5", color = col, align = "right")
            if i < 2:
                c.hline(3, 61, y + 6, "#18302E")
    header(c, s, p["short"] + " ROUTE" if c.width >= 128 else "JOURNEY")


def changed(c, ctx):
    s = migration(ctx)
    habitat_scene(c, s["habitat"])
    previous = s["previous"]
    p = CREATURES[previous]
    left_name = "MOSS" if previous == 1 else p["short"]
    b = scene_bounds(c)
    effect(c, previous, b[0], b[1], 29)
    if c.width >= 128:
        c.rect(58, 8, 177, 30, fill = "#030708", outline = p["main"])
        c.text("IT LEFT BEHIND", 117, 10, font = "4x5", color = "#91A5A4", align = "center")
        c.text_fit(p["effect"], 117, 15, ["10x16", "7x12", "6x8"], color = p["accent"], align = "center", maxw = 112)
    else:
        c.rect(0, 24, 63, 31, fill = "#030708")
        c.text_fit(p["effect"], 32, 25, ["5x7", "4x5"], color = p["accent"], align = "center", maxw = 60)
    header(c, s, left_name + " LEFT")
