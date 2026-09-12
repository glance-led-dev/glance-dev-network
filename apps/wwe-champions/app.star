# DESIGN. User brief: one large recognizable championship belt beside its
# champion, rotating through titles. Live championship carousel with reference-based native pixel art.
# Native drawing only: hard pixel edges, no scaled photos or soft alpha.
# Belt occupies x10..81; type occupies x91..181, with a quiet black gutter.
# Future belts: match supplied references with distinct plate silhouettes,
# strap colors, prominent accurate logos, and crisp metal/red detailing.

GOLD = "#E7AD35"
EDGE = "#89531C"
LIGHT = "#FFE5A0"
SILVER = "#F1F5FA"
SHADOW = "#3B2A18"
BLACK = "#090A0C"

def span(c, x, y, widths, color):
    for row in range(len(widths)):
        half = widths[row]
        c.hline(x - half, y + row, half * 2 + 1, color)

def wmark(c, x, y, small = False):
    # Two stacked jagged Ws, with the red slash below the diamond logo.
    if small:
        c.sprite(["W...W...W", "W...W...W", ".W.W.W.W.", ".W.W.W.W.", "..W...W..", "...RRRR.."], x, y,
                 legend = {"W": SILVER, "R": "#EC263D"})
        return
    art = [
        "WW......WW......WW",
        ".WW.....WW.....WW.",
        ".WW....WWWW....WW.",
        "..WW...WWWW...WW..",
        "..WW..WW..WW..WW..",
        "...WW.WW..WW.WW...",
        "...WWWW....WWWW...",
        "....WWW....WWW....",
        "WW...W......W...WW",
        ".WW.....WW.....WW.",
        "..WW...WWWW...WW..",
        "...WW.WW..WW.WW...",
        "....WWW....WWW....",
        ".....W......W.....",
        "........RRRRRRRR..",
        "....RRRRRRRR......",
    ]
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            c.sprite(art, x + dx, y + dy, legend = {"W": BLACK, "R": BLACK})
    c.sprite(art, x, y, legend = {"W": SILVER, "R": "#ED2540"})

def undisputed_mark(c):
    # Reference: long diagonal arms, a sharp central apex, and two deep
    # lower points. The old two short Ws read like a zigzag face at 32px.
    # Both strokes share a 21px-wide silhouette, with gold negative space.
    strokes = [
        [[35, 4], [41, 16], [45, 5], [49, 16], [55, 4]],
        [[35, 8], [41, 23], [45, 13], [49, 23], [55, 8]],
    ]
    c.line(39, 22, 55, 19, "#851E23")
    c.line(40, 22, 55, 20, "#ED2540")
    for points in strokes:
        for i in range(len(points) - 1):
            a = points[i]
            b = points[i + 1]
            for dx in [-1, 0, 1]:
                for dy in [-1, 0, 1]:
                    c.line(a[0] + dx, a[1] + dy, b[0] + dx, b[1] + dy, BLACK)
    for points in strokes:
        for i in range(len(points) - 1):
            a = points[i]
            b = points[i + 1]
            c.line(a[0], a[1], b[0], b[1], SILVER)

def strap(c, white):
    base = "#D7DEE8" if white else "#24262B"
    rim = "#FFFFFF" if white else "#646871"
    c.rect(12, 10, 79, 22, fill = base)
    c.rect(10, 12, 81, 20, fill = base)
    c.hline(13, 9, 66, rim)
    c.hline(13, 23, 66, rim)
    for x in [13, 16, 75, 78]:
        for y in [13, 19]:
            c.pixel(x, y, "#66707E" if white else "#A4A6AC")

def sides(c, world):
    for x in [24, 67]:
        span(c, x, 8, [2, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 2], EDGE)
        span(c, x, 9, [2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3], LIGHT)
        span(c, x, 10, [2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2], GOLD)
        c.rect(x - 2, 12, x + 2, 19, fill = SHADOW)
        c.line(x - 2, 13, x, 17, SILVER)
        c.line(x, 17, x + 2, 13, SILVER)
        c.pixel(x, 20, "#E33234" if not world else LIGHT)

def belt(c, kind):
    strap(c, kind == "women")
    sides(c, kind == "world")
    if kind == "women":
        # White leather follows the full plate, not just the strap ends.
        span(c, 45, 0, [13, 15] + [16] * 20 + [15, 13, 11, 8, 6, 3, 1], "#E5E1DE")
        for sx in [24, 67]:
            c.fill_circle(sx, 15, 4, BLACK)
            c.circle(sx, 15, 4, LIGHT)
            c.fill_circle(sx, 15, 2, "#AF2630")
            c.line(sx - 2, 13, sx - 1, 17, LIGHT)
            c.line(sx - 1, 17, sx, 14, LIGHT)
            c.line(sx, 14, sx + 1, 17, LIGHT)
            c.line(sx + 1, 17, sx + 2, 13, LIGHT)
    if kind == "world":
        # User reference: scalloped gold shoulders, dark globe lattice,
        # large silver double-W, and curved top/bottom gold banners.
        span(c, 45, 0, [5, 9, 11, 13, 16, 18, 19, 20, 21, 22] + [23] * 12 + [22, 21, 20, 19, 17, 14, 11, 8, 4], BLACK)
        span(c, 45, 1, [5, 9, 11, 13, 16, 18, 19, 20, 21] + [22] * 12 + [21, 20, 19, 17, 14, 11, 8, 4], EDGE)
        span(c, 45, 2, [5, 9, 11, 13, 16, 18, 19, 20] + [21] * 12 + [20, 19, 17, 14, 11, 8, 4], LIGHT)
        span(c, 45, 3, [5, 9, 11, 13, 16, 18, 19] + [20] * 12 + [19, 17, 14, 11, 8, 4], GOLD)
        # Mirrored curls suggest the raised gold ornament without noise.
        for direction in [-1, 1]:
            for dy in [0, 8]:
                for a, b in [[14, 8], [17, 9], [18, 11], [16, 12], [14, 11], [15, 10], [17, 14], [15, 15]]:
                    c.pixel(45 + direction * a, b + dy, LIGHT)
                    c.pixel(45 + direction * a, b + dy + 1, EDGE)
            for yy in [10, 14, 18, 22]:
                c.pixel(45 + direction * 19, yy, SILVER)
        c.fill_circle(45, 15, 11, LIGHT)
        c.fill_circle(45, 15, 10, BLACK)
        # Only plot grid pixels inside the globe; the gold field stays clear.
        for gy in range(-9, 10):
            for gx in range(-9, 10):
                if gx * gx + gy * gy <= 90:
                    if (gx + gy) % 6 == 0 or (gx - gy) % 6 == 0:
                        c.pixel(45 + gx, 15 + gy, "#AA853E")
        strokes = [
            [[36, 8], [41, 18], [45, 8], [49, 18], [54, 8]],
            [[36, 12], [41, 24], [45, 16], [49, 24], [54, 12]],
        ]
        for points in strokes:
            for i in range(len(points) - 1):
                a = points[i]
                b = points[i + 1]
                for dx in [-1, 0, 1]:
                    for dy in [-1, 0, 1]:
                        c.line(a[0] + dx, a[1] + dy, b[0] + dx, b[1] + dy, BLACK)
        for points in strokes:
            for i in range(len(points) - 1):
                a = points[i]
                b = points[i + 1]
                c.line(a[0] + 1, a[1], b[0] + 1, b[1], "#9CA6B8")
                c.line(a[0], a[1], b[0], b[1], SILVER)
        c.line(39, 24, 55, 22, SILVER)
        # Tiny inscriptions are represented by spaced silver engraving.
        c.hline(40, 4, 11, LIGHT)
        c.hline(37, 5, 17, EDGE)
        c.hline(38, 26, 15, EDGE)
        c.hline(40, 27, 11, LIGHT)
        for xx in [39, 42, 45, 48, 51]:
            c.pixel(xx, 5, SILVER)
            c.pixel(xx, 26, SILVER)
    else:
        # Both reference belts have gold fields; the women's white leather
        # and red circular side emblems distinguish it from the men's belt.
        field = GOLD
        # Both plates use the user's pentagonal silhouette: long vertical
        # sides to y21, then two shallow diagonals to the low point.
        span(c, 45, 1, [12, 14] + [15] * 19 + [14, 12, 10, 7, 5, 2, 0], EDGE)
        span(c, 45, 2, [12, 13] + [14] * 17 + [13, 11, 9, 7, 4, 2, 0], LIGHT)
        span(c, 45, 3, [11, 12] + [13] * 15 + [12, 11, 9, 7, 4, 2, 0], field)
        if kind != "women":
            for x in [34, 56]:
                c.vline(x, 7, 9, LIGHT)
        # Outline the logo itself so the Undisputed gold field stays visible.
        if kind == "women":
            for gx in [35, 38, 41, 44, 47, 50, 53, 56]:
                c.pixel(gx, 2, SILVER)
            for gy in [6, 9, 12, 15, 18]:
                c.pixel(31, gy, SILVER)
                c.pixel(59, gy, SILVER)
            c.pixel(32, 21, "#D62D3A")
            c.pixel(58, 21, "#D62D3A")
        undisputed_mark(c)
        c.hline(41, 24, 9, LIGHT)
        c.hline(43, 25, 5, EDGE)

def champion_text(c, name, x, y, font):
    # Bundled 7x12 has a 12px A but 8px R/H/E/etc. Use a matching 6x8 A
    # locally so RHEA shares a baseline, without changing the shared SDK.
    for i in range(len(name)):
        ch = name[i]
        if font == "7x12" and ch == "A":
            c.sprite([".AAAA.", "AA..AA", "AA..AA", "AAAAAA",
                      "AAAAAA", "AA..AA", "AA..AA", "AA..AA"],
                     x, y, color = SILVER)
            x = x + 7
        else:
            c.text(ch, x, y, font = font, color = SILVER)
            x = x + c.text_width(ch, font) + 1


def medal(c, shape, silver = False):
    rim = "#8E99AE" if silver else EDGE
    high = SILVER if silver else LIGHT
    metal = "#B3BDCF" if silver else GOLD
    if shape == "round":
        widths = [5, 8, 10, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 15, 15, 14, 13, 12, 10, 8, 5]
    elif shape == "square":
        widths = [11, 14, 16, 17] + [17] * 16 + [16, 14, 11, 7]
    else:
        widths = [4, 7, 10, 12, 14, 16, 17, 18, 18, 17, 16, 15, 15, 16, 17, 18, 18, 17, 16, 14, 12, 10, 7, 4]
    span(c, 45, 3, widths, rim)
    span(c, 45, 4, [max(0, x - 1) for x in widths[1:-1]], high)
    span(c, 45, 5, [max(0, x - 2) for x in widths[2:-2]], metal)

def ornament(c, silver = False):
    hi = SILVER if silver else LIGHT
    for x in [31, 34, 56, 59]:
        for y in [9, 13, 17, 21]:
            c.pixel(x, y, hi)
    for x in range(37, 54, 3):
        c.pixel(x, 5, hi)
        c.pixel(x, 25, hi)

def globe(c, cx, cy, radius, blue = False):
    c.fill_circle(cx, cy, radius, "#183E78" if blue else BLACK)
    c.circle(cx, cy, radius, LIGHT)
    c.vline(cx, cy - radius + 1, 2 * radius - 1, GOLD)
    c.hline(cx - radius + 1, cy, 2 * radius - 1, GOLD)
    for dy in [-3, 3]:
        c.hline(cx - radius + 2, cy + dy, 2 * radius - 3, EDGE)
    c.sprite([".GG...", "GGGG..", ".GG...", "..GGG.", "...GG.", "...G.."], cx - 3, cy - 3, color = LIGHT)

def extra_belt(c, kind):
    white = kind.endswith("white") or kind == "womentag"
    strap(c, white)
    sides(c, False)
    if kind in ["evolve", "evolvewhite", "id", "idwhite"]:
        for sx in [24, 67]:
            c.fill_circle(sx, 15, 5, "#7B879B")
            c.circle(sx, 15, 5, SILVER)
            c.fill_circle(sx, 15, 3, BLACK)
            c.line(sx - 2, 13, sx, 17, SILVER)
            c.line(sx, 17, sx + 2, 13, SILVER)
            c.pixel(sx, 21, "#BE88F2" if kind.startswith("evolve") else "#EB3442")
    if kind == "icwhite":
        # User's reference: tall oval gold frame, three blue globes,
        # black stepped shoulders and cream leather, not the men's plate.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, True)
        c.rect(27, 5, 63, 25, fill = "#E7DFCA", outline = LIGHT)
        c.rect(25, 8, 65, 22, fill = GOLD)
        c.rect(26, 9, 64, 21, fill = BLACK)
        for yy in [8, 11, 20, 23]:
            c.line(25, yy, 35, yy - 3 if yy < 15 else yy + 3, GOLD)
            c.line(55, yy - 3 if yy < 15 else yy + 3, 65, yy, GOLD)
        for sx in [22, 68]:
            c.fill_circle(sx, 15, 9, "#EDE5D6")
            c.fill_circle(sx, 15, 8, EDGE)
            globe(c, sx, 15, 7, blue = True)
            c.circle(sx, 15, 8, LIGHT)
        profile = [3, 6, 8, 10, 11, 12, 13, 13, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 14, 14, 14, 13, 13, 12, 11, 10, 8, 6, 3]
        span(c, 45, 0, profile, "#EDE5D6")
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], EDGE)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], LIGHT)
        span(c, 45, 3, [max(0, v - 3) for v in profile[3:-3]], GOLD)
        # Gold inscription band surrounds the smaller black inner oval.
        span(c, 45, 6, [2, 5, 6, 7, 8, 8, 9, 9, 9, 9, 9, 8, 8, 7, 6, 5, 2], EDGE)
        span(c, 45, 7, [2, 4, 5, 6, 7, 7, 8, 8, 8, 8, 7, 7, 6, 5, 4], BLACK)
        for d in [-1, 1]:
            for i in range(4):
                c.line(45 + d * (2 + i), 8 + i, 45 + d * (4 + i), 8 + i, LIGHT)
            for yy in [10, 14, 18, 22]:
                c.pixel(45 + d * 11, yy, BLACK)
        # Diamond framing and blue center globe carry the IC identity.
        for a, b in [[[45, 8], [54, 15]], [[54, 15], [45, 22]], [[45, 22], [36, 15]], [[36, 15], [45, 8]]]:
            c.line(a[0], a[1], b[0], b[1], LIGHT)
        c.fill_circle(45, 15, 5, "#24588D")
        c.circle(45, 15, 5, GOLD)
        c.vline(45, 11, 9, "#9D803F")
        c.hline(41, 15, 9, "#9D803F")
        c.sprite(["W...W...W", "W..WWW..W", ".W.W.W.W.", ".WWW.WWW.", "..W...W..", "...WWW..."],
                 41, 12, legend = {"W": LIGHT})
        for xx in [39, 42, 45, 48, 51]:
            c.pixel(xx, 4, BLACK)
            c.pixel(xx, 26, BLACK)
        c.hline(42, 23, 7, LIGHT)
    elif kind == "ic":
        # Men's reference: oval gold center, blue shoulder globes and
        # separate square logo plates on a broad black leather strap.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, False)
        c.rect(10, 6, 81, 25, fill = "#161719", outline = "#505052")
        c.rect(27, 5, 63, 25, fill = "#292827", outline = LIGHT)
        c.rect(25, 8, 65, 22, fill = GOLD)
        c.rect(26, 9, 64, 21, fill = BLACK)
        for yy in [8, 11, 20, 23]:
            c.line(25, yy, 35, yy - 3 if yy < 15 else yy + 3, GOLD)
            c.line(55, yy - 3 if yy < 15 else yy + 3, 65, yy, GOLD)
        for sx in [30, 60]:
            c.fill_circle(sx, 15, 6, EDGE)
            c.fill_circle(sx, 15, 5, GOLD)
            globe(c, sx, 15, 5, blue = True)
            c.circle(sx, 15, 6, LIGHT)
        profile = [3, 6, 8, 10, 11, 12, 13, 13, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 14, 14, 14, 13, 13, 12, 11, 10, 8, 6, 3]
        span(c, 45, 0, profile, "#3D3B32")
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], EDGE)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], LIGHT)
        span(c, 45, 3, [max(0, v - 3) for v in profile[3:-3]], GOLD)
        # Gold inscription band surrounds the smaller black inner oval.
        span(c, 45, 6, [2, 5, 6, 7, 8, 8, 9, 9, 9, 9, 9, 8, 8, 7, 6, 5, 2], EDGE)
        span(c, 45, 7, [2, 4, 5, 6, 7, 7, 8, 8, 8, 8, 7, 7, 6, 5, 4], BLACK)
        for d in [-1, 1]:
            for i in range(4):
                c.line(45 + d * (2 + i), 8 + i, 45 + d * (4 + i), 8 + i, LIGHT)
            for yy in [10, 14, 18, 22]:
                c.pixel(45 + d * 11, yy, BLACK)
        # Diamond framing and blue center globe carry the IC identity.
        for a, b in [[[45, 8], [54, 15]], [[54, 15], [45, 22]], [[45, 22], [36, 15]], [[36, 15], [45, 8]]]:
            c.line(a[0], a[1], b[0], b[1], LIGHT)
        c.fill_circle(45, 15, 5, "#24588D")
        c.circle(45, 15, 5, GOLD)
        c.vline(45, 11, 9, "#9D803F")
        c.hline(41, 15, 9, "#9D803F")
        c.sprite(["W...W...W", "W..WWW..W", ".W.W.W.W.", ".WWW.WWW.", "..W...W..", "...WWW..."],
                 41, 12, legend = {"W": LIGHT})
        for xx in [39, 42, 45, 48, 51]:
            c.pixel(xx, 4, BLACK)
            c.pixel(xx, 26, BLACK)
        c.hline(42, 23, 7, LIGHT)
        # Square side plates with circular blue WWE medallions.
        for sx in [18, 73]:
            c.rect(sx - 7, 7, sx + 7, 24, fill = EDGE, outline = LIGHT)
            c.rect(sx - 6, 8, sx + 6, 23, fill = GOLD)
            c.fill_circle(sx, 15, 6, BLACK)
            c.circle(sx, 15, 6, LIGHT)
            c.fill_circle(sx, 15, 4, "#24588D")
            c.circle(sx, 15, 4, EDGE)
            c.sprite(["W..W..W", "W..W..W", ".WW.WW.", ".WW.WW.", "..W.W.."],
                     sx - 3, 13, color = LIGHT)
            for yy in [10, 20]:
                c.pixel(sx - 4, yy, SILVER)
                c.pixel(sx + 4, yy, SILVER)
    elif kind == "us":
        # Reference: angular six-sided plate, silver/navy CHAMPION band,
        # a wide gold eagle over horizontal red/white stripes, black strap.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, False)
        for sx in [16, 75]:
            c.rect(sx - 5, 9, sx + 5, 24, fill = EDGE, outline = LIGHT)
            c.fill_circle(sx, 16, 4, "#30323C")
            c.circle(sx, 16, 4, GOLD)
            c.sprite(["W.W.W", "W.W.W", ".WWW.", ".W.W."], sx - 2, 14, color = SILVER)
        profile = [5, 7, 9, 11, 13, 15, 17, 19, 21] + [22] * 15 + [20, 17, 14, 11, 8, 5, 2]
        span(c, 45, 0, profile, "#44382A")
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], LIGHT)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], GOLD)
        for xx, yy in [[35, 6], [39, 5], [51, 5], [55, 6], [31, 8], [59, 8]]:
            c.pixel(xx, yy, SILVER)
            c.pixel(xx - 1, yy + 1, SILVER)
            c.pixel(xx + 1, yy + 1, SILVER)
        wmark(c, 41, 2, small = True)
        # The actual belt's blue word sits on silver, not a black US badge.
        c.rect(25, 9, 65, 15, fill = "#BCC4D2", outline = LIGHT)
        c.text("CHAMPION", 45, 10, font = "4x5", color = "#102543", align = "center")
        for yy in [17, 19, 21, 23, 25, 27]:
            half = 18 if yy < 23 else 17 if yy == 23 else 12 if yy == 25 else 5
            c.hline(45 - half, yy, half * 2 + 1, "#E2E7EF")
            c.hline(45 - half, yy + 1, half * 2 + 1, "#A9293F")
        # Stepped feather rows spread nearly the full plate width.
        for d in [-1, 1]:
            for row in range(6):
                inner = 3 + row // 2
                outer = 18 - row * 2
                c.line(45 + d * inner, 18 + row, 45 + d * outer, 17 + row, EDGE)
                c.line(45 + d * inner, 17 + row, 45 + d * outer, 16 + row, LIGHT)
        span(c, 45, 18, [2, 3, 3, 3, 2, 2, 1, 1], GOLD)
        c.pixel(45, 19, LIGHT)
        c.pixel(45, 21, EDGE)
        c.line(44, 24, 41, 27, LIGHT)
        c.line(46, 24, 49, 27, LIGHT)
        c.sprite([".SS.", "SSSB", ".SS.", ".GG."], 43, 16,
                 legend = {"S": SILVER, "B": EDGE, "G": GOLD})
    elif kind == "uswhite":
        # Reference: angular six-sided plate, silver/navy CHAMPION band,
        # women's white leather, navy star field and gold eagle over stripes.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, True)
        for sx in [16, 75]:
            c.rect(sx - 6, 8, sx + 6, 25, fill = "#EFE7DD")
            c.rect(sx - 5, 9, sx + 5, 24, fill = EDGE, outline = LIGHT)
            c.fill_circle(sx, 16, 4, "#30323C")
            c.circle(sx, 16, 4, GOLD)
            c.sprite(["W.W.W", "W.W.W", ".WWW.", ".W.W."], sx - 2, 14, color = SILVER)
        profile = [5, 7, 9, 11, 13, 15, 17, 19, 21] + [22] * 15 + [20, 17, 14, 11, 8, 5, 2]
        span(c, 45, 0, profile, "#EFE7DD")
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], LIGHT)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], GOLD)
        span(c, 45, 3, [9, 11, 13, 15, 17, 19], "#19365D")
        for xx, yy in [[35, 6], [39, 5], [51, 5], [55, 6], [31, 8], [59, 8]]:
            c.pixel(xx, yy, SILVER)
            c.pixel(xx - 1, yy + 1, SILVER)
            c.pixel(xx + 1, yy + 1, SILVER)
        wmark(c, 41, 2, small = True)
        # The actual belt's blue word sits on silver, not a black US badge.
        c.rect(25, 9, 65, 15, fill = "#BCC4D2", outline = LIGHT)
        c.text("CHAMPION", 45, 10, font = "4x5", color = "#102543", align = "center")
        for yy in [17, 19, 21, 23, 25, 27]:
            half = 18 if yy < 23 else 17 if yy == 23 else 12 if yy == 25 else 5
            c.hline(45 - half, yy, half * 2 + 1, "#E2E7EF")
            c.hline(45 - half, yy + 1, half * 2 + 1, "#A9293F")
        # Stepped feather rows spread nearly the full plate width.
        for d in [-1, 1]:
            for row in range(6):
                inner = 3 + row // 2
                outer = 18 - row * 2
                c.line(45 + d * inner, 18 + row, 45 + d * outer, 17 + row, EDGE)
                c.line(45 + d * inner, 17 + row, 45 + d * outer, 16 + row, LIGHT)
        span(c, 45, 18, [2, 3, 3, 3, 2, 2, 1, 1], GOLD)
        c.pixel(45, 19, LIGHT)
        c.pixel(45, 21, EDGE)
        c.line(44, 24, 41, 27, LIGHT)
        c.line(46, 24, 49, 27, LIGHT)
        c.sprite([".SS.", "SSSB", ".SS.", ".GG."], 43, 16,
                 legend = {"S": SILVER, "B": EDGE, "G": GOLD})
    elif kind == "worldtag":
        # User reference: round ornate gold face, burgundy banners, black
        # center shield and silver W, with square gold side medallions.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, False)
        c.rect(10, 7, 81, 24, fill = "#17171A", outline = "#373335")
        for sx in [18, 73]:
            c.rect(sx - 7, 8, sx + 7, 23, fill = EDGE, outline = LIGHT)
            c.rect(sx - 6, 9, sx + 6, 22, fill = GOLD)
            c.circle(sx, 15, 5, EDGE)
            c.circle(sx, 15, 4, LIGHT)
            c.sprite(["W.W.W", "W.W.W", ".WWW.", ".W.W."], sx - 2, 13, color = BLACK)
            for yy in [10, 21]:
                for dx in [-5, 5]:
                    c.pixel(sx + dx, yy, SILVER)
        for sx in [28, 63]:
            c.vline(sx, 10, 11, GOLD)
            for yy in [11, 14, 17, 20]:
                c.pixel(sx, yy, LIGHT)
        c.fill_circle(45, 15, 15, "#36302A")
        c.fill_circle(45, 15, 14, EDGE)
        c.circle(45, 15, 14, LIGHT)
        c.fill_circle(45, 15, 13, GOLD)
        c.circle(45, 15, 12, "#EDC56E")
        # Rim jewels and mirrored gold curls suggest the lions/filigree.
        for step in range(20):
            a = step * math.pi / 10
            c.pixel(int(45 + 13 * math.cos(a)), int(15 + 13 * math.sin(a)), SILVER)
        for d in [-1, 1]:
            for xx, yy in [[9, 10], [10, 12], [9, 14], [11, 15], [9, 17], [10, 19], [8, 21]]:
                c.pixel(45 + d * xx, yy, LIGHT)
                c.pixel(45 + d * (xx - 1), yy + 1, EDGE)
        c.rect(37, 5, 53, 8, fill = "#842D29")
        c.hline(39, 4, 13, LIGHT)
        c.rect(37, 23, 53, 26, fill = "#842D29")
        c.hline(39, 27, 13, LIGHT)
        for sx in range(38, 54, 2):
            c.vline(sx, 6, 2, "#FFF1CC")
            c.vline(sx, 24, 2, "#FFF1CC")
        span(c, 45, 10, [7, 7, 7, 6, 6, 6, 5, 5, 4, 3, 2, 1], "#211A16")
        strokes = [
            [[38, 10], [42, 17], [45, 10], [48, 17], [52, 10]],
            [[39, 14], [42, 21], [45, 16], [48, 21], [51, 14]],
        ]
        for points in strokes:
            for i in range(len(points) - 1):
                a = points[i]
                b = points[i + 1]
                c.line(a[0], a[1], b[0], b[1], SILVER)
        c.line(42, 21, 51, 20, SILVER)
    elif kind == "wwetag":
        # User reference: broad gold heraldic plate, raised crown, oval
        # black globe and two dark banners. Distinct from Raw's round belt.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, False)
        for sx in [16, 75]:
            c.rect(sx - 5, 8, sx + 5, 25, fill = EDGE, outline = LIGHT)
            c.rect(sx - 4, 9, sx + 4, 24, fill = GOLD)
            c.fill_circle(sx, 16, 4, BLACK)
            c.circle(sx, 16, 4, LIGHT)
            c.sprite(["W.W.W", "W.W.W", ".WWW.", ".W.W."], sx - 2, 14, color = GOLD)
        profile = [3, 5, 6, 7, 7, 12, 17, 19, 20, 21] + [21] * 16 + [20, 19, 17, 13]
        span(c, 45, 0, profile, "#423B2B")
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], LIGHT)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], GOLD)
        # Crown rises above the main shoulder line.
        c.sprite(["G..G..G", "GG.G.GG", ".GGGGG.", ".G.G.G.", "..GGG.."],
                 42, 1, legend = {"G": BLACK})
        c.hline(43, 6, 5, LIGHT)
        # Oval globe with thin gold meridians and a central gold double W.
        span(c, 45, 8, [4, 7, 9, 10, 11, 11, 11, 11, 10, 9, 7, 4], EDGE)
        span(c, 45, 9, [4, 7, 9, 10, 10, 10, 10, 9, 7, 4], BLACK)
        for yy in [11, 14, 17]:
            c.hline(37, yy, 17, "#8A703C")
        for xx in [40, 45, 50]:
            c.line(xx - 1, 10, xx + 1, 17, "#8A703C")
        for d in [-1, 1]:
            # Feathered griffin silhouettes flank the globe.
            for i in range(5):
                c.line(45 + d * 14, 13 + i, 45 + d * (18 - i // 2), 9 + i, LIGHT)
            c.line(45 + d * 14, 13, 45 + d * 13, 21, EDGE)
            c.line(45 + d * 13, 21, 45 + d * 17, 23, LIGHT)
            c.pixel(45 + d * 12, 12, LIGHT)
        c.sprite(["W....W....W", "W...WWW...W", ".W..W.W..W.", ".W.W...W.W.", "..WW...WW..", "...W...W...", "..W.W.W.W..", "...WW.WW...", "....W.W...."],
                 40, 9, color = LIGHT)
        c.line(42, 18, 50, 17, LIGHT)
        c.rect(35, 21, 55, 25, fill = BLACK)
        c.text("TAG", 45, 21, font = "4x5", color = LIGHT, align = "center")
        c.hline(31, 27, 29, BLACK)
        for xx in range(33, 60, 3):
            c.pixel(xx, 27, LIGHT)
        for xx in [28, 31, 59, 62]:
            c.pixel(xx, 8, LIGHT)
            c.pixel(xx, 25, LIGHT)
    elif kind == "womentag":
        # User reference: white scalloped leather, silver four-point plate,
        # gold center disk and silver laurels, not two interlocking globes.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, True)
        for sx in [21, 70]:
            c.rect(sx - 7, 7, sx + 7, 24, fill = "#E6E5E2")
            c.rect(sx - 6, 8, sx + 6, 23, fill = GOLD, outline = LIGHT)
            c.fill_circle(sx, 15, 6, "#777F89")
            c.circle(sx, 15, 6, SILVER)
            c.circle(sx, 15, 4, "#C9CFD7")
            c.sprite(["W.W.W", "W.W.W", ".WWW.", ".W.W."], sx - 2, 13, color = SILVER)
            for xx in [-5, 5]:
                c.pixel(sx + xx, 8, SILVER)
                c.pixel(sx + xx, 23, SILVER)
        c.fill_circle(45, 15, 15, "#DADBD9")
        c.fill_circle(45, 15, 14, LIGHT)
        c.fill_circle(45, 15, 13, GOLD)
        profile = [12, 12, 11, 11, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 12, 12, 11, 11, 12, 12]
        span(c, 45, 4, profile, "#616B78")
        span(c, 45, 5, [max(0, v - 1) for v in profile[1:-1]], "#DADEE5")
        # Four diagonal corner points are the defining silver silhouette.
        for a, b in [[[33, 4], [43, 14]], [[57, 4], [47, 14]], [[33, 26], [43, 16]], [[57, 26], [47, 16]]]:
            c.line(a[0], a[1], b[0], b[1], "#8B94A1")
        c.fill_circle(45, 15, 9, EDGE)
        c.fill_circle(45, 15, 8, GOLD)
        c.circle(45, 15, 7, LIGHT)
        c.vline(45, 9, 13, "#B68130")
        c.hline(39, 15, 13, "#B68130")
        # Silver laurel leaves arc around the gold medallion.
        for d in [-1, 1]:
            for xx, yy in [[6, 7], [8, 9], [10, 11], [10, 18], [8, 21], [6, 23]]:
                c.line(45 + d * xx, yy, 45 + d * (xx - 2), yy + 1, "#707B89")
                c.pixel(45 + d * xx, yy - 1, SILVER)
        # The 3x4 font lacks a space glyph; place the two words explicitly.
        c.text_stroke("TAG", 31, 13, font = "3x4", color = LIGHT, stroke = BLACK)
        c.text_stroke("TEAM", 43, 13, font = "3x4", color = LIGHT, stroke = BLACK)
    elif kind == "nxt":
        # User reference: black leather, black globe, gold hex wings, silver
        # NXT. Side plates are square gold frames with an X; NXT overspills.
        c.rect(10, 0, 81, 31, fill = BLACK)
        c.rect(10, 10, 81, 21, fill = "#101113")
        c.hline(12, 11, 68, "#2A2C31")
        c.hline(12, 20, 68, "#2A2C31")
        for x in [13, 78]:
            c.pixel(x, 13, "#3A3C42")
            c.pixel(x, 18, "#3A3C42")
        profile = [5, 7, 9, 11, 13, 15, 17, 18, 19, 20] + [20] * 12 + [19, 18, 17, 15, 13, 11, 9, 7, 5]
        span(c, 45, 0, profile, EDGE)
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], LIGHT)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], GOLD)
        span(c, 45, 3, [max(0, v - 6) for v in profile[3:-3]], BLACK)
        c.fill_circle(45, 15, 12, BLACK)
        c.circle(45, 15, 12, SILVER)
        c.circle(45, 15, 11, "#4E5662")
        for yy in [7, 11, 15, 19, 23]:
            half = 11 if yy == 15 else 8 if yy in [11, 19] else 4
            c.hline(45 - half, yy, half * 2 + 1, "#6B7380")
        c.vline(45, 4, 23, "#6B7380")
        for d in [-1, 1]:
            c.line(45, 4, 45 + d * 9, 15, "#8A93A0")
            c.line(45 + d * 9, 15, 45, 26, "#8A93A0")
        letters = [
            ["NN....NN", "NNN...NN", "NNNN..NN", "NN.NN.NN", "NN..NNNN", "NN...NNN", "NN....NN", "NN....NN", "NN....NN"],
            ["XXX...XXX", ".XXX.XXX.", "..XXXXX..", "...XXX...", "..XXXXX..", ".XXX.XXX.", "XXX...XXX", "XXX...XXX", "XXX...XXX"],
            ["TTTTTTTTT", "TTTTTTTTT", "...TTT...", "...TTT...", "...TTT...", "...TTT...", "...TTT...", "...TTT...", "...TTT..."],
        ]
        for i in range(3):
            x = [30, 39, 49][i]
            for dx in [-1, 0, 1]:
                for dy in [-1, 0, 1]:
                    c.sprite(letters[i], x + dx, 11 + dy, color = GOLD)
        for i in range(3):
            x = [30, 39, 49][i]
            c.sprite(letters[i], x, 12, color = "#B8BFC8")
            c.sprite(letters[i], x, 11, color = SILVER)
        c.sprite(["W.W.W", "W.W.W", ".WWW.", "..W.."], 43, 2, color = LIGHT)
        c.hline(39, 26, 13, GOLD)
        for xx in [41, 43, 45, 47, 49]:
            c.pixel(xx, 27, LIGHT)
        for sx in [17, 74]:
            c.rect(sx - 6, 8, sx + 6, 23, fill = EDGE, outline = LIGHT)
            c.rect(sx - 5, 9, sx + 5, 22, fill = GOLD)
            c.rect(sx - 4, 10, sx + 4, 21, fill = "#D5DBE4")
            c.sprite(["XX...XX", ".XX.XX.", "..XXX..", "...X...", "..XXX..", ".XX.XX.", "XX...XX"],
                     sx - 3, 12, color = GOLD)
    elif kind == "nxtwhite":
        # User reference: white leather, silver hex, gold inner ring, black
        # globe with a star, silver NXT. Side plates are white with gold X;
        # NXT overspills those plates at this size.
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, True)
        span(c, 45, 1, [8, 11, 14, 16, 18, 19, 20, 21] + [22] * 14 + [21, 20, 19, 16, 13, 10, 7], "#E8E4DE")
        profile = [5, 7, 9, 11, 13, 15, 17, 18, 19, 20] + [20] * 12 + [19, 18, 17, 15, 13, 11, 9, 7, 5]
        span(c, 45, 0, profile, "#8E99AE")
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], LIGHT)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], SILVER)
        c.fill_circle(45, 15, 13, GOLD)
        c.fill_circle(45, 15, 11, BLACK)
        c.circle(45, 15, 13, LIGHT)
        c.circle(45, 15, 11, "#4E5662")
        for yy in [8, 12, 15, 18, 22]:
            half = 9 if yy == 15 else 7 if yy in [12, 18] else 4
            c.hline(45 - half, yy, half * 2 + 1, "#6B7380")
        c.vline(45, 5, 21, "#6B7380")
        for d in [-1, 1]:
            c.line(45, 5, 45 + d * 8, 15, "#8A93A0")
            c.line(45 + d * 8, 15, 45, 25, "#8A93A0")
        c.sprite(["..W..", ".WWW.", "WWWWW", ".W.W.", "W...W"], 43, 13, color = "#8A93A0")
        letters = [
            ["NN....NN", "NNN...NN", "NNNN..NN", "NN.NN.NN", "NN..NNNN", "NN...NNN", "NN....NN", "NN....NN", "NN....NN"],
            ["XXX...XXX", ".XXX.XXX.", "..XXXXX..", "...XXX...", "..XXXXX..", ".XXX.XXX.", "XXX...XXX", "XXX...XXX", "XXX...XXX"],
            ["TTTTTTTTT", "TTTTTTTTT", "...TTT...", "...TTT...", "...TTT...", "...TTT...", "...TTT...", "...TTT...", "...TTT..."],
        ]
        for i in range(3):
            x = [30, 39, 49][i]
            for dx in [-1, 0, 1]:
                for dy in [-1, 0, 1]:
                    c.sprite(letters[i], x + dx, 11 + dy, color = BLACK)
        for i in range(3):
            x = [30, 39, 49][i]
            c.sprite(letters[i], x, 12, color = "#C5CAD3")
            c.sprite(letters[i], x, 11, color = SILVER)
        c.sprite(["W.W.W", "W.W.W", ".WWW.", "..W.."], 43, 2, color = "#3A3E48")
        c.hline(39, 26, 13, GOLD)
        for xx in [41, 43, 45, 47, 49]:
            c.pixel(xx, 27, LIGHT)
        for sx in [17, 74]:
            c.rect(sx - 6, 8, sx + 6, 23, fill = "#E8E4DE")
            c.rect(sx - 5, 9, sx + 5, 22, fill = GOLD, outline = LIGHT)
            c.rect(sx - 4, 10, sx + 4, 21, fill = SILVER)
            c.sprite(["XX...XX", ".XX.XX.", "..XXX..", "...X...", "..XXX..", ".XX.XX.", "XX...XX"],
                     sx - 3, 12, color = GOLD)
    elif kind == "nxttag":
        # User reference: black leather, gold hex, stacked silver N / X / T.
        c.rect(10, 0, 81, 31, fill = BLACK)
        c.rect(10, 10, 81, 21, fill = "#101113")
        c.hline(12, 11, 68, "#2A2C31")
        c.hline(12, 20, 68, "#2A2C31")
        profile = [5, 7, 9, 11, 13, 15, 17, 18, 19, 20] + [20] * 12 + [19, 18, 17, 15, 13, 11, 9, 7, 5]
        span(c, 45, 0, profile, EDGE)
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], LIGHT)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], GOLD)
        span(c, 45, 3, [max(0, v - 4) for v in profile[3:-3]], BLACK)
        for d in [-1, 1]:
            for ey in [4, 24]:
                px = 45 + d * 12
                c.sprite([".G.", "GLG", ".G."], px - 1, ey, legend = {"G": GOLD, "L": LIGHT})
        letters = [
            [
                "NNN...NNN",
                "NNN...NNN",
                "NNNN..NNN",
                "NNN.N.NNN",
                "NNN..NNNN",
                "NNN...NNN",
                "NNN...NNN",
            ],
            [
                "XX.....XX",
                ".XX...XX.",
                "..XX.XX..",
                "...XXX...",
                "..XX.XX..",
                ".XX...XX.",
                "XX.....XX",
            ],
            [
                "TTTTTTTTT",
                "TTTTTTTTT",
                "TTTTTTTTT",
                "...TTT...",
                "...TTT...",
                "...TTT...",
                "...TTT...",
            ],
        ]
        ys = [5, 13, 21]
        for i in range(3):
            x = 41
            y = ys[i]
            c.sprite(letters[i], x, y + 1, color = "#B8BFC8")
            c.sprite(letters[i], x, y, color = SILVER)
        for sx in [19, 71]:
            c.rect(sx - 5, 8, sx + 5, 23, fill = EDGE, outline = LIGHT)
            c.rect(sx - 4, 9, sx + 4, 22, fill = GOLD)
            c.rect(sx - 3, 11, sx + 3, 20, fill = BLACK)
            c.sprite(["S.S", ".S.", "S.S"], sx - 1, 14, legend = {"S": LIGHT})
    elif kind in ["na", "nawhite"]:
        # User reference: brown leather, round gold globe, black grid,
        # silver North America, square gold compass side plates.
        c.rect(10, 0, 81, 31, fill = BLACK)
        if kind == "nawhite":
            strap(c, True)
        else:
            c.rect(10, 9, 81, 22, fill = "#6B3E24")
            c.rect(10, 11, 81, 20, fill = "#5A3420")
            c.hline(12, 10, 68, "#A97746")
            c.hline(12, 21, 68, "#3D2416")
            for x in [13, 78]:
                c.pixel(x, 13, "#C4A06A")
                c.pixel(x, 18, "#C4A06A")
        c.fill_circle(45, 15, 15, EDGE)
        c.fill_circle(45, 15, 14, GOLD)
        c.circle(45, 15, 14, LIGHT)
        c.fill_circle(45, 15, 12, BLACK)
        for step in range(12):
            a = step * math.pi / 6
            c.pixel(int(45 + 13 * math.cos(a) + 0.5), int(15 + 13 * math.sin(a) + 0.5), LIGHT)
        for yy in [7, 11, 15, 19, 23]:
            dy = yy - 15
            v = 144 - dy * dy
            if v > 0:
                half = int(math.sqrt(v))
                c.hline(45 - half, yy, half * 2 + 1, EDGE)
        for xx in [37, 41, 45, 49, 53]:
            dx = xx - 45
            v = 144 - dx * dx
            if v > 0:
                half = int(math.sqrt(v))
                c.vline(xx, 15 - half, half * 2 + 1, EDGE)
        # Per-row land so the US sits on the globe center, not a tiny
        # triangle above it. Hudson Bay is a bite; Florida sticks east.
        bands = [
            [6, 41, 50],
            [7, 38, 53],
            [8, 36, 54],
            [9, 35, 54],
            [10, 36, 53],
            [11, 37, 53],
            [12, 38, 52],
            [13, 39, 51],
            [14, 39, 51],
            [15, 40, 50],
            [16, 41, 49],
            [17, 42, 48],
            [18, 43, 47],
            [19, 44, 46],
            [20, 45, 46],
        ]
        for b in bands:
            yy = b[0]
            for x in range(b[1], b[2] + 1):
                hole = yy == 9 and x >= 42 and x <= 44
                if hole:
                    continue
                if (x - 45) * (x - 45) + (yy - 15) * (yy - 15) <= 144:
                    c.pixel(x, yy, SILVER)
        for x in [33, 34, 35]:
            if (x - 45) * (x - 45) + 64 <= 144:
                c.pixel(x, 7, SILVER)
                c.pixel(x, 8, SILVER)
        c.pixel(53, 13, SILVER)
        c.pixel(54, 13, SILVER)
        c.pixel(53, 14, SILVER)
        c.pixel(40, 12, LIGHT)
        c.pixel(45, 14, LIGHT)
        c.pixel(49, 13, LIGHT)
        for sx in [23, 67]:
            leather = "#E8E4DE" if kind == "nawhite" else "#6B3E24"
            c.rect(sx - 6, 8, sx + 6, 23, fill = leather)
            c.rect(sx - 5, 9, sx + 5, 22, fill = EDGE, outline = LIGHT)
            c.rect(sx - 4, 10, sx + 4, 21, fill = GOLD)
            c.rect(sx - 2, 12, sx + 2, 19, fill = EDGE)
            c.line(sx - 3, 15, sx + 3, 15, LIGHT)
            c.line(sx, 12, sx, 19, LIGHT)
            c.pixel(sx, 15, BLACK)
    elif kind in ["evolve", "evolvewhite"]:
        c.rect(10, 0, 81, 31, fill = BLACK)
        strap(c, white)
        # Sculpted silver star/atom plate from the user's Evolve reference.
        # Full-height lobes replace the old rectangular nameplate.
        profile = [3, 6, 8, 10, 12, 14, 16, 17, 18, 19, 20, 21, 22, 22, 23, 23, 23, 22, 22, 21, 20, 19, 18, 17, 16, 14, 12, 10, 8, 6, 3]
        span(c, 45, 0, profile, "#737A89")
        span(c, 45, 1, [max(0, v - 1) for v in profile[1:-1]], SILVER)
        span(c, 45, 2, [max(0, v - 2) for v in profile[2:-2]], "#A9ADB9")
        span(c, 45, 3, [max(0, v - 4) for v in profile[3:-3]], "#20192D")
        for sx in [18, 73]:
            c.fill_circle(sx, 15, 7, "#8B8D9A")
            c.circle(sx, 15, 7, SILVER)
            c.fill_circle(sx, 15, 5, BLACK)
            c.circle(sx, 15, 5, "#B5B8C4")
            c.sprite(["W.W.W", "W.W.W", ".WWW.", ".W.W."], sx - 2, 13, color = SILVER)
            for yy in [6, 24]:
                c.pixel(sx, yy, "#C295FF")
                c.pixel(sx + 1, yy, "#6C429C")
        # Three long orbital loops form the recognizable six-point emblem.
        for angle in [0, 60, -60]:
            points = []
            theta = math.radians(angle)
            for step in range(33):
                t = step * math.pi / 16
                u = 20 * math.cos(t)
                v = 5 * math.sin(t)
                px = int(45 + u * math.cos(theta) - v * math.sin(theta))
                py = int(15 + 0.72 * (u * math.sin(theta) + v * math.cos(theta)))
                points.append([px, py])
            for i in range(32):
                a = points[i]
                b = points[i + 1]
                for dy in [-1, 0, 1]:
                    c.line(a[0], a[1] + dy, b[0], b[1] + dy, BLACK)
            for i in range(32):
                a = points[i]
                b = points[i + 1]
                c.line(a[0], a[1], b[0], b[1], SILVER)
        for xx in [32, 58]:
            for yy in [7, 23]:
                c.fill_circle(xx, yy, 1, "#AE7AEF")
                c.pixel(xx, yy, "#E4CAFF")
        c.text_stroke("EVOLVE", 45, 11, font = "6x8", color = SILVER, align = "center")
        # Purple orbital accent crosses only the central O, as in the logo.
        c.line(41, 21, 48, 8, "#C6A0F4")
        c.line(40, 19, 49, 11, "#8D62BB")
        c.hline(39, 5, 13, SILVER)
        c.hline(37, 25, 17, SILVER)
        for xx in [39, 42, 45, 48, 51]:
            c.pixel(xx, 26, "#56505F")
    elif kind in ["id", "idwhite"]:
        medal(c, "square", silver = True)
        c.rect(33, 7, 57, 23, fill = BLACK)
        c.circle(45, 15, 9, "#747E91")
        c.vline(45, 7, 17, "#596374")
        c.hline(37, 15, 17, "#596374")
        c.text("ID", 45, 8, font = "10x16_bold", color = SILVER, align = "center")
        c.hline(34, 24, 23, "#DF353B")
        ornament(c, True)
        for x in [31, 59]:
            for y in [7, 22]:
                c.pixel(x, y, "#EB3442")
    else:
        medal(c, "round")
        c.text("WWE", 45, 11, font = "5x7", color = BLACK, align = "center")

def draw_title_belt(c, kind):
    if kind in ["wwe", "women", "world"]:
        belt(c, kind)
    elif kind == "worldwhite":
        belt(c, "world")
        # Preserve the approved World plate and expose white strap ends.
        for x in [10, 73]:
            c.rect(x, 12, x + 8, 20, fill = "#E5E1DE")
            c.hline(x + 2, 10, 7, SILVER)
            c.hline(x + 2, 22, 7, SILVER)
            for yy in [14, 18]:
                c.pixel(x + 3, yy, "#747A86")
    else:
        extra_belt(c, kind)

# One belt per render. Data refreshes every 30 minutes; the selected title
# advances each minute. A fixed title can also be chosen in Studio/the app.
WIKI = "https://en.wikipedia.org/w/api.php"
UA = "WWEChampions-GDN/1.0 (https://github.com/glance-dev-network; LED title board)"
WIKI_TTL = 1800
ORDER = ["RAW", "SMACKDOWN", "OPEN", "NXT", "EVOLVE", "ID"]
BRANDS = {
    "RAW": {"heads": ["==== Raw ===="], "color": "#FF5664", "label": "RAW"},
    "SMACKDOWN": {"heads": ["==== SmackDown ===="], "color": "#559EFF", "label": "SMACKDOWN"},
    "OPEN": {"heads": ["==== Open ===="], "color": "#EAA4FF", "label": "WWE"},
    "NXT": {"heads": ["==== NXT ===="], "color": "#FFE15A", "label": "NXT"},
    "EVOLVE": {"heads": ["==== Evolve ===="], "color": "#B58AFF", "label": "EVOLVE"},
    "ID": {"heads": ["====WWE ID===="], "color": "#64D8A1", "label": "ID"},
}
MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
SKIP_TITLES = {}
# title, display label, belt family, brand. Exact matches prevent confusing
# the women's, men's, interim, and tag championships.
TITLES = [
    ["World Heavyweight Championship", "WORLD HEAVYWEIGHT", "world", "RAW"],
    ["Women's World Championship", "WOMEN'S WORLD", "worldwhite", "RAW"],
    ["WWE Intercontinental Championship", "INTERCONTINENTAL", "ic", "RAW"],
    ["WWE Women's Intercontinental Championship", "WOMEN'S IC", "icwhite", "RAW"],
    ["World Tag Team Championship", "WORLD TAG TEAM", "worldtag", "RAW"],
    ["Undisputed WWE Championship", "UNDISPUTED WWE", "wwe", "SMACKDOWN"],
    ["WWE Women's Championship", "WWE WOMEN'S", "women", "SMACKDOWN"],
    ["Interim WWE Women's Championship", "INTERIM WOMEN'S", "women", "SMACKDOWN"],
    ["WWE United States Championship", "UNITED STATES", "us", "SMACKDOWN"],
    ["WWE Women's United States Championship", "WOMEN'S US", "uswhite", "SMACKDOWN"],
    ["WWE Tag Team Championship", "WWE TAG TEAM", "wwetag", "SMACKDOWN"],
    ["WWE Women's Tag Team Championship", "WOMEN'S TAG TEAM", "womentag", "OPEN"],
    ["NXT Championship", "NXT CHAMPION", "nxt", "NXT"],
    ["NXT Women's Championship", "NXT WOMEN'S", "nxtwhite", "NXT"],
    ["NXT North American Championship", "NXT NORTH AMERICAN", "na", "NXT"],
    ["NXT Women's North American Championship", "NXT WOMEN'S NA", "nawhite", "NXT"],
    ["NXT Tag Team Championship", "NXT TAG TEAM", "nxttag", "NXT"],
    ["WWE Evolve Men's Championship", "EVOLVE MEN'S", "evolve", "EVOLVE"],
    ["WWE Evolve Women's Championship", "EVOLVE WOMEN'S", "evolvewhite", "EVOLVE"],
    ["WWE ID Championship", "WWE ID MEN'S", "id", "ID"],
    ["WWE Women's ID Championship", "WWE ID WOMEN'S", "idwhite", "ID"],
]

def normal(s):
    return str(s).upper().replace("’", "'").strip()

def format_won_date(s):
    t = squeeze(str(s).replace(",", " ").replace(".", " "))
    for i in range(len(MONTHS)):
        prefix = MONTHS[i] + " "
        if not t.startswith(prefix):
            continue
        parts = t[len(prefix):].split(" ")
        if len(parts) < 2:
            return ""
        day = parts[0]
        year = parts[1]
        if len(year) == 4:
            year = year[2:]
        if day == "" or year == "":
            return ""
        return str(i + 1) + "/" + day + "/" + year
    return ""


def footer_right(c, brand_label, won, slot, count):
    if won == "":
        return str(slot + 1) + "/" + str(count)
    since = "SINCE " + won
    used = c.text_width(brand_label, "4x5") + 4 + c.text_width(since, "4x5")
    if used <= 90:
        return since
    return won


def title_meta(title):
    for spec in TITLES:
        if normal(spec[0]) == normal(title):
            return spec
    return [title, normal(title).replace(" CHAMPIONSHIP", ""), "unknown", "OPEN"]

def wiki_names(cell):
    rest = cell
    out = []
    for _ in range(12):
        a = rest.find("[[")
        b = rest.find("]]", a)
        if a < 0 or b < 0:
            break
        inner = rest[a + 2:b]
        rest = rest[b + 2:]
        if inner.lower().startswith("file:") or inner.lower().startswith("image:"):
            continue
        out.append(inner.split("|")[-1].strip())
    return out

def read_title_row(row):
    cs = cells(row)
    if len(cs) < 2:
        return None
    title = wiki_first(cs[0])
    if "CHAMPIONSHIP" not in normal(title):
        return None
    # The champion follows an optional image/empty image cell. Never scan
    # onward into location or notes and accidentally promote an opponent.
    cell = cs[1]
    if cell == "" or "file:" in cell.lower() or "image:" in cell.lower():
        cell = cs[2] if len(cs) > 2 else ""
    names = wiki_names(cell)
    members = []
    if "TAG TEAM" in normal(title):
        members = names[1:] if len(names) >= 3 else names
    champ = names[0] if len(names) > 0 else plain(cell)
    if normal(champ) in ["", "—", "-", "VACANT"]:
        champ = "VACANT" if normal(champ) == "VACANT" else "UNAVAILABLE"
    won = ""
    for cell in cs:
        won = format_won_date(plain(cell))
        if won != "":
            break
    return {"title": title, "champ": champ, "members": members, "won": won}

def selected_rows(brands, brand):
    rows = []
    for key in ORDER:
        if brand == "ALL" or brand == key or (brand == "DEV" and key in ["OPEN", "EVOLVE", "ID"]):
            rows = rows + brands.get(key, [])
    return rows

def bounded(c, s, font, width):
    s = normal(s)
    if c.text_width(s, font) <= width:
        return s
    for i in range(len(s), 0, -1):
        if c.text_width(s[:i] + "..", font) <= width:
            return s[:i] + ".."
    return ""

def draw_name(c, item):
    members = item.get("members", [])
    if len(members) >= 2:
        for i in range(2):
            name = bounded(c, members[i], "5x7", 91)
            c.text(name, 91, 9 + i * 9, font = "5x7", color = SILVER)
        return
    name = normal(item["champ"])
    for font in ["10x16_bold", "7x12", "6x8", "5x7"]:
        if c.text_width(name, font) <= 91:
            champion_text(c, name, 91, 10, font)
            return
    # Long real names get two full words/lines before any explicit clipping.
    words = name.split(" ")
    line1 = ""
    line2 = ""
    for word in words:
        candidate = (line1 + " " + word).strip()
        if line2 == "" and c.text_width(candidate, "5x7") <= 91:
            line1 = candidate
        else:
            line2 = (line2 + " " + word).strip()
    c.text(bounded(c, line1, "5x7", 91), 91, 9, font = "5x7", color = SILVER)
    c.text(bounded(c, line2, "5x7", 91), 91, 18, font = "5x7", color = SILVER)

def error_screen(c, head, sub):
    c.fill("black")
    belt(c, "wwe")
    c.text("WWE TITLES", 91, 2, font = "4x5", color = LIGHT)
    c.text(bounded(c, head, "5x7", 91), 91, 11, font = "5x7", color = "#FFCA71")
    c.text(bounded(c, sub, "4x5", 91), 91, 23, font = "4x5", color = "#A8B1C5")

def board(c, ctx):
    brand = normal(ctx.inputs.get("brand", "ALL"))
    if brand not in ORDER + ["ALL", "DEV"]:
        error_screen(c, "BAD BRAND", "CHOOSE A BRAND")
        return
    brands = fetch_brands()
    if brands == None:
        error_screen(c, "FEED OFFLINE", "TRY AGAIN LATER")
        return
    rows = selected_rows(brands, brand)
    choice = ctx.inputs.get("title", "ROTATE")
    if choice != "ROTATE":
        matched = []
        for spec in TITLES:
            if choice == spec[1]:
                for item in rows:
                    if normal(item["title"]) == normal(spec[0]):
                        matched.append(item)
        rows = matched
    if len(rows) == 0:
        error_screen(c, "NO TITLE FOUND", "SET ALL / ROTATE")
        return
    slot = (ctx.now.unix // 60) % len(rows)
    item = rows[slot]
    spec = title_meta(item["title"])
    c.fill("black")
    draw_title_belt(c, spec[2])
    c.text(bounded(c, spec[1], "4x5", 91), 91, 2, font = "4x5", color = LIGHT)
    draw_name(c, item)
    brandmeta = BRANDS[spec[3]]
    brand_label = brandmeta["label"]
    c.text(brand_label, 91, 27, font = "4x5", color = brandmeta["color"])
    footer = footer_right(c, brand_label, item.get("won", ""), slot, len(rows))
    c.text(footer, 181, 27, font = "4x5", color = "#9BA8BB", align = "right")

def strip_refs(s):
    out = ""
    rest = s
    for _ in range(80):
        a = rest.find("<ref")
        if a < 0:
            return out + rest
        out = out + rest[:a]
        rest = rest[a:]
        end = rest.find("</ref>")
        sl = rest.find("/>")
        gt = rest.find(">")
        if sl >= 0 and (end < 0 or sl < end) and sl < 120 and gt >= 0 and sl < gt + 40:
            rest = rest[sl + 2:]
            continue
        if end < 0:
            return out
        rest = rest[end + 6:]
    return out + rest


def wiki_first(cell):
    rest = cell
    for _ in range(12):
        a = rest.find("[[")
        if a < 0:
            return ""
        b = rest.find("]]", a)
        if b < 0:
            return ""
        inner = rest[a + 2:b]
        rest = rest[b + 2:]
        low = inner.lower()
        if low.startswith("file:") or low.startswith("image:") or low.startswith("category:"):
            continue
        pipe = inner.find("|")
        if pipe >= 0:
            inner = inner[pipe + 1:]
        return inner.strip()
    return ""


def drop_templates(s):
    out = ""
    rest = s
    for _ in range(24):
        a = rest.find("{{")
        if a < 0:
            return out + rest
        out = out + rest[:a]
        rest = rest[a + 2:]
        d = rest.find("}}")
        if d < 0:
            return out
        rest = rest[d + 2:]
    return out + rest


def drop_links_keep_text(s):
    out = ""
    rest = s
    for _ in range(24):
        a = rest.find("[[")
        if a < 0:
            return out + rest
        out = out + rest[:a]
        b = rest.find("]]", a)
        if b < 0:
            return out
        inner = rest[a + 2:b]
        pipe = inner.find("|")
        if pipe >= 0:
            inner = inner[pipe + 1:]
        low = inner.lower()
        if not low.startswith("file:") and not low.startswith("image:"):
            out = out + inner + " "
        rest = rest[b + 2:]
    return out


def squeeze(s):
    t = s.replace("\t", " ")
    out = ""
    prev = False
    for i in range(len(t)):
        ch = t[i]
        if ch == " ":
            if prev == False:
                out = out + ch
            prev = True
        else:
            out = out + ch
            prev = False
    return out.strip()


def plain(cell):
    t = cell.replace("<br>", " ").replace("<br/>", " ").replace("<br />", " ")
    t = t.replace("'''", "")
    t = drop_templates(t)
    t = drop_links_keep_text(t)
    return squeeze(t)


def is_skip(cell):
    c = cell.strip()
    if c == "" or c == "|" or c == "-" or c == "—":
        return True
    if c.find("File:") >= 0 or c.find("file:") >= 0:
        return True
    if c.find("age in days") >= 0:
        return True
    if c.startswith("align"):
        return True
    if c.find("Defeated") >= 0 or c.find("defeated") >= 0:
        return True
    if c[0].isdigit():
        return True
    for m in MONTHS:
        if c.startswith(m + " "):
            return True
    if c.startswith("{{"):
        return True
    return False


def cells(row):
    out = []
    for line in strip_refs(row).split("\n"):
        p = line.strip()
        if p.startswith("|"):
            out.append(p[1:].strip())
        elif len(out) > 0 and not p.startswith("!"):
            out[-1] = out[-1] + " " + p
    return out


def table_after(text, heading):
    wanted = heading.replace("=", "").strip().upper()
    section = ""
    found = False
    for line in text.split("\n"):
        if line.startswith("==="):
            if found:
                break
            found = line.replace("=", "").strip().upper() == wanted
        elif found:
            section = section + line + "\n"
    a = section.find("{|")
    b = section.find("|}", a)
    return section[a:b + 2] if a >= 0 and b >= 0 else ""


def parse_table(tab):
    out = []
    rows = tab.split("|-")
    for row in rows:
        item = read_title_row(row)
        if item != None:
            out.append(item)
    return out


def parse_wiki(wt):
    brands = {}
    start = wt.find("== Current champions ==")
    if start < 0:
        return brands
    chunk = wt[start:]
    for key in ORDER:
        meta = BRANDS[key]
        items = []
        heads = meta["heads"]
        for h in heads:
            items = items + parse_table(table_after(chunk, h))
        brands[key] = items
    return brands


def fetch_brands():
    r = http.get(
        WIKI,
        headers = {"User-Agent": UA, "Accept": "application/json"},
        params = {
            "action": "parse",
            "page": "List_of_current_champions_in_WWE",
            "prop": "wikitext",
            "format": "json",
            "formatversion": "2",
        },
        ttl_seconds = WIKI_TTL,
    )
    if r["status_code"] != 200:
        return None
    j = r["json"]
    if type(j) != "dict":
        return None
    p = j.get("parse")
    if type(p) != "dict":
        return None
    wt = p.get("wikitext")
    if type(wt) != "string" or wt == "":
        return None
    return parse_wiki(wt)


