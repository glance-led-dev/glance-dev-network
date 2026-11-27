# Athlete Career Resume -- a whole career on one strip, not this week's box
# score. NFL, NBA, MLB and NHL in one dropdown.
#
# DESIGN. The existing athlete trackers answer "how is this player doing right
# now". This is the opposite app: it answers "what have they done", and it is
# built from the two ESPN payloads those trackers never open -- /bio (awards,
# team history) and /stats (career totals plus the per-season table). The
# thesis is a resume: who they are, what they have piled up, and what they won.
#
# Three pages, each with one hero. IDENTITY is their kit in team colours --
# helmet, jersey or sweater -- with their number stamped on it and their
# surname set as large as it will go. CAREER is the one number that defines
# their position: 38,648 passing yards, 43,697 points, 386 home runs, 1,279
# points. Beside it, one bar per season, so you see the shape of the career and
# not just its sum. HONORS is the trophy case, and when ESPN lists no awards
# (which is most players, Travis Kelce included) the page turns into the career
# path instead: every club, every span, as crests. Empty is never an error.
#
# Four leagues share one layout because the question is the same in all of
# them. Only three things vary: which sprite is the kit, which stat category
# defines a position, and which endpoint to call.
#
# The app is framed by a 2px rail of the player's team colour down both outer
# edges. On a SCROLL panel this app shares the glass with its neighbours, and
# the two rails close it into its own card so it cannot visually merge with
# whatever plays before and after it.

# ---------------------------------------------------------------- house kit

INK = "#F4F7FF"          # primary text
DIM = "#6E7A94"          # labels, axes, anything that must not compete
STRUCT = "#2A3042"       # dividers and hairlines
GOLD = "#FFC24A"         # trophies only -- nothing else on the panel is gold
BG = "#07080C"

X0 = 10                  # scroll safe zone: content lives in x 10..181
X1 = 181

# Haloed text has its own, tighter bounds. ink() draws through text_stroke,
# which paints a 1px ring around every glyph -- a string started at X0 would
# put stroke pixels at x=9, outside the safe zone the rest of the app obeys.
# Two pixels of inset is cheaper than a frayed edge on a scrolling panel.
TX0 = X0 + 1
TX1 = X1 - 1

# Backdrop luminance tiers. These are luminance targets, not channel values:
# scaling a channel treats navy and gold alike and one of them disappears.
TEX_LO = 0.030           # the quiet tier -- mow bands, planks, ice
TEX_HI = 0.075           # the line tier -- yard lines, arcs, chalk
TEX_CAP = 80             # and no channel may exceed this regardless

FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x7": 7, "4x5": 5}

def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits `maxw`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it draws anyway -- which is how "WASHINGTON COMMANDERS" ends up
    running through the season span right-aligned beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    """[font, clipped text] for the largest listed font that fits."""
    t = str(text)
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, t, pick, maxw)]

def get(obj, key, fallback = None):
    """dict.get that survives a null parent, which ESPN hands back often."""
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def dig(obj, path, fallback = None):
    cur = obj
    for k in path:
        if cur == None or type(cur) != "dict":
            return fallback
        cur = cur.get(k, None)
    return fallback if cur == None else cur

def meta_fit(c, parts, maxw):
    """Join `parts` with " . ", dropping whole trailing parts until it fits.

    clip() would cut mid-word, which is how the career page came out saying
    "MCCAFFREY . 122 GP . 12 SZ" and "CROSKEY-MERRITT . 23 GP ." with a
    dangling separator. A dropped field reads as a choice; half a word reads
    as a bug."""
    keep = []
    for p in parts:
        if p == "":
            continue
        trial = " . ".join(keep + [p])
        if c.text_width(trial, "4x5") > maxw:
            break
        keep.append(p)
    if len(keep) == 0 and len(parts) > 0:
        return clip(c, parts[0], "4x5", maxw)
    return " . ".join(keep)

def eyebrow(c, word, right = "", right_color = ""):
    """Row 0: what this page is, and one line of quiet context opposite it.

    There is no rule under it, and that is arithmetic rather than taste. The
    panel is 32 rows. An eyebrow (5) plus a hairline (1) plus a 16x20 hero plus
    a 4x5 label is 31 rows of content and only 1 row left for the three gaps
    the guidelines require between them -- so a hairline here forces the hero
    to touch either the rule above it or its own label below. Dropping the rule
    buys that row back: eyebrow 0-4, clear 5, hero 6-25, clear 26, label 27-31.
    The dim slate against white does the separating instead."""
    c.text(word, X0, 0, font = "4x5", color = DIM)
    if right != "":
        col = right_color if right_color != "" else DIM
        c.text(clip(c, right, "4x5", 110), X1 + 1, 0, font = "4x5",
               color = col, align = "right")

def nodata(c, head, sub):
    """The one screen every failure state shares. A what, and a what to do."""
    c.fill(BG)
    frame(c, "#3C4043", 0)
    f, t = fit(c, head, ["10x16", "6x8", "5x7", "4x5"], X1 - X0)
    c.text(t, c.width // 2, 7, font = f, color = "amber", align = "center")
    c.text(clip(c, sub, "4x5", X1 - X0), c.width // 2, 25, font = "4x5",
           color = DIM, align = "center")

# ------------------------------------------------------------------ colour

def _rgb(h):
    h = str(h).replace("#", "")
    if len(h) != 6:
        return (128, 128, 128)
    # The length check alone is not enough: int(x, 16) raises on a 6-character
    # string that is not hex, and team.color comes verbatim out of ESPN into
    # palette() and accent() on all three pages -- so one bad colour took the
    # whole app down, not one element of it.
    for ch in h.upper().elems():
        if "0123456789ABCDEF".find(ch) < 0:
            return (128, 128, 128)
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))

def _hex(rgb):
    out = "#"
    for v in rgb:
        v = max(0, min(255, int(v)))
        out += "0123456789ABCDEF"[v // 16] + "0123456789ABCDEF"[v % 16]
    return out

def _lum(rgb):
    return (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255.0

def _scale(rgb, f):
    return (rgb[0] * f, rgb[1] * f, rgb[2] * f)

def _lift(rgb, floor):
    # LEDs crush dark colours -- the Ravens' navy reads as black on a panel, so
    # brightness comes up while the hue stays put.
    m = max(rgb[0], rgb[1], rgb[2], 1)
    if m >= floor:
        return rgb
    if m < 40:
        return (96, 96, 96)             # all-black kit: charcoal still lights
    return _scale(rgb, floor * 1.0 / m)

def _dist(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])

def palette(primary, secondary):
    """The helmet legend: shell, shade, highlight, trim, facemask, numeral."""
    p = _lift(_rgb(primary), 150)
    s = _lift(_rgb(secondary), 150)
    if _dist(p, s) < 90:
        s = (235, 235, 235)
    if abs(_lum(s) - _lum(p)) > 0.25:
        n = s
    elif _lum(p) < 0.6:
        n = (255, 255, 255)
    else:
        n = (20, 20, 20)
    light = (p[0] + (255 - p[0]) * 0.35, p[1] + (255 - p[1]) * 0.35,
             p[2] + (255 - p[2]) * 0.35)
    return {
        "P": _hex(p), "D": _hex(_scale(p, 0.6)), "L": _hex(light),
        "S": _hex(s), "W": "#F0F0F0", "M": "#B8B8B8", "E": "#262626",
        "G": "#6E6E6E", "N": _hex(n), "K": "#000000",
    }

def _lift_lum(rgb, target):
    """Raise a colour until its LUMINANCE clears `target`, keeping the hue.

    The fallback used to lift the max channel to 200, which is a different
    thing: Buffalo's #0048C8 has a 200 channel already and still lands at
    luminance 0.26, dimmer than the 0.33 this function had just rejected. A
    4x5 line in it on near-black is unreadable across a room."""
    out = rgb
    for i in range(8):
        if _lum(out) >= target:
            return out
        out = (out[0] + (255 - out[0]) * 0.3,
               out[1] + (255 - out[1]) * 0.3,
               out[2] + (255 - out[2]) * 0.3)
    return out

def _chroma(rgb):
    return max(rgb[0], rgb[1], rgb[2]) - min(rgb[0], rgb[1], rgb[2])

def _sat(rgb):
    """Saturation, but a near-black colour is called unsaturated rather than
    whatever its ratio works out to. Navy at 2% brightness is not a hue."""
    m = max(rgb[0], rgb[1], rgb[2])
    if m < 40:
        return 0.0
    return _chroma(rgb) * 1.0 / m

def _punch(rgb):
    """Take a colour to full brightness keeping its hue exactly, and only
    wash toward white if it is still too dim to read on an LED."""
    m = max(rgb[0], rgb[1], rgb[2], 1)
    out = _scale(rgb, 255.0 / m)
    for i in range(8):
        if _lum(out) >= 0.36:
            return out
        out = (out[0] + (255 - out[0]) * 0.12, out[1] + (255 - out[1]) * 0.12,
               out[2] + (255 - out[2]) * 0.12)
    return out

def accent(primary, secondary):
    """The one team colour that text and chrome are allowed to wear.

    The old version took the first colour whose luminance cleared 0.33. That
    handed Kansas City its gold -- the same gold as the trophies, so page 3
    drew the cabinet and its captions and its rail in one colour and the
    trophies stopped being the thing you saw. It also handed the Yankees a
    neutral grey indistinguishable from the error frame, and rejected
    Philadelphia's red for being 0.003 too dark, leaving a slate close to DIM.

    So: require actual saturation rather than brightness, take the colour to
    full brightness instead of discarding it for being dark, and refuse any
    accent that lands near GOLD while a second option exists."""
    gold = _rgb(GOLD)
    picks = []
    for h in (secondary, primary):
        rgb = _rgb(h)
        if _sat(rgb) >= 0.35:
            picks.append(_punch(rgb))
    for a in picks:
        if _dist(a, gold) >= 110:
            return _hex(a)
    if len(picks) > 0:
        return _hex(picks[0])
    return "#AEB9CC"

def tint(primary, secondary, lum):
    """A team colour taken down to a target LUMINANCE, for the backdrop.

    Scaling toward a fixed channel value would make a bright team's surface
    glare and a dark team's vanish. Luminance is the thing the eye is
    actually judging, so that is what gets pinned."""
    rgb = _rgb(primary)
    if _sat(rgb) < 0.35:
        rgb = _rgb(secondary)
    if _sat(rgb) < 0.35:
        rgb = (110, 122, 148)
    f = lum / max(_lum(rgb), 0.01)
    m = max(rgb[0], rgb[1], rgb[2], 1)
    if m * f > TEX_CAP:
        f = TEX_CAP * 1.0 / m
    return _hex(_scale(rgb, f))

# --------------------------------------------------------------- backdrop
# Each league gets its playing surface, top down, in a very dark tint of the
# team's own colour. It is the biggest coloured area on the panel and the
# thing that says "hockey" before a word is read. Built once at module load,
# as a sprite, so a page costs one draw call rather than ten thousand.
#
# They differ by DIRECTION as much as by shape -- vertical yard lines,
# horizontal planks, 45-degree mow bands, bare ice with arcs -- because at
# 3% luminance a shape is a rumour and a direction is not.

TEXW = X1 - X0 + 1

def _blank():
    return [["." for x in range(TEXW)] for y in range(32)]

def _put(g, px, y, ch):
    if px >= X0 and px <= X1 and y >= 0 and y <= 31:
        g[y][px - X0] = ch

def _ring(g, cx2, cy2, r, ch, x_lo, x_hi):
    # centre given in half-pixels so a circle can sit between two rows
    for y in range(32):
        for px in range(max(X0, x_lo), min(X1, x_hi) + 1):
            dx = 2 * px - cx2
            dy = 2 * y - cy2
            d = dx * dx + dy * dy
            if d >= (2 * r - 1) * (2 * r - 1) and d <= (2 * r + 1) * (2 * r + 1):
                _put(g, px, y, ch)

def _disc(g, cx2, cy2, r, ch, x_lo, x_hi):
    for y in range(32):
        for px in range(max(X0, x_lo), min(X1, x_hi) + 1):
            dx = 2 * px - cx2
            dy = 2 * y - cy2
            if dx * dx + dy * dy <= 4 * r * r:
                _put(g, px, y, ch)

def _rows(g):
    return ["".join(r) for r in g]

def gridiron():
    g = _blank()
    for px in range(X0, X1 + 1):
        if (px // 16) % 2 == 1:
            for y in range(32):
                _put(g, px, y, "a")
        if px % 16 == 0 or px == 95:
            for y in range(32):
                _put(g, px, y, "b")
        elif px % 4 == 0:
            for y in (9, 10, 21, 22):
                _put(g, px, y, "b")
    return _rows(g)

def hardwood():
    g = _blank()
    for y in range(32):
        r = y // 4
        for px in range(X0, X1 + 1):
            if y % 4 == 3:
                _put(g, px, y, "a")
            elif (px + r * 17) % 43 == 0:
                _put(g, px, y, "a")
    for y in range(32):
        _put(g, 95, y, "b")
        _put(g, 96, y, "b")
    _ring(g, 191, 31, 10, "b", X0, X1)
    for side in (0, 1):
        # three-point arc, key, free-throw circle, rim
        cx = 24 if side == 0 else 167
        lo = cx if side == 0 else X0
        hi = X1 if side == 0 else cx
        _ring(g, 2 * cx, 31, 15, "b", lo, hi)
        for px in (range(X0, 25) if side == 0 else range(167, X1 + 1)):
            _put(g, px, 1, "b")
            _put(g, px, 30, "b")
        kx = 36 if side == 0 else 155
        for px in (range(X0, 37) if side == 0 else range(155, X1 + 1)):
            _put(g, px, 10, "b")
            _put(g, px, 21, "b")
        for y in range(10, 22):
            _put(g, kx, y, "b")
        _ring(g, 2 * kx, 31, 5, "b", kx if side == 0 else X0, X1 if side == 0 else kx)
        rx = 14 if side == 0 else 177
        _ring(g, 2 * rx, 31, 2, "b", X0, X1)
    return _rows(g)

def rink():
    g = _blank()
    # boards: rounded rectangle, corner radius 9
    for px in range(X0 + 9, X1 - 8):
        _put(g, px, 0, "b")
        _put(g, px, 31, "b")
    _ring(g, 2 * (X0 + 9), 18, 9, "b", X0, X0 + 9)
    _ring(g, 2 * (X1 - 9), 18, 9, "b", X1 - 9, X1)
    _ring(g, 2 * (X0 + 9), 44, 9, "b", X0, X0 + 9)
    _ring(g, 2 * (X1 - 9), 44, 9, "b", X1 - 9, X1)
    # the corner rings are full half circles; clear the halves that face inward
    for y in range(9, 23):
        for px in range(X0, X0 + 10):
            _put(g, px, y, ".")
        for px in range(X1 - 9, X1 + 1):
            _put(g, px, y, ".")
        _put(g, X0, y, "b")
        _put(g, X1, y, "b")
    for y in range(1, 31):
        for px in (66, 67, 68, 123, 124, 125):       # blue lines, 3px
            _put(g, px, y, "b")
        if y % 4 < 2:                                # centre line, dashed
            _put(g, 95, y, "b")
            _put(g, 96, y, "b")
        _put(g, 22, y, "a")                          # goal lines
        _put(g, 169, y, "a")
    _disc(g, 191, 31, 10, ".", X0, X1)
    _ring(g, 191, 31, 10, "b", X0, X1)
    _disc(g, 191, 31, 1, "b", X0, X1)
    for cx in (40, 151):
        for cy2 in (15, 47):
            _ring(g, 2 * cx, cy2, 6, "b", X0, X1)
            _disc(g, 2 * cx, cy2, 1, "b", X0, X1)
    for cx in (75, 116):                             # neutral-zone dots
        for cy2 in (15, 47):
            _disc(g, 2 * cx, cy2, 1, "b", X0, X1)
    _disc(g, 44, 31, 4, "a", 22, X1)                 # creases
    _disc(g, 338, 31, 4, "a", X0, 169)
    return _rows(g)

def _infield(g):
    for y in range(31):
        k = 30 - y
        l = 95 - 2 * k
        r = 96 + 2 * k
        for px in (l - 1, l, r, r + 1):          # foul lines
            _put(g, px, y, "b")
        if y >= 2 and y <= 16:
            kk = y - 2
            for px in (95 - 2 * kk - 1, 95 - 2 * kk, 96 + 2 * kk, 96 + 2 * kk + 1):
                _put(g, px, y, "b")
    for b in ((94, 0), (65, 15), (123, 15), (94, 29)):
        for dy in range(3):
            for dx in range(4):
                _put(g, b[0] + dx, b[1] + dy, "b")
    _disc(g, 191, 33, 2, "b", X0, X1)            # mound

def diamond():
    g = _blank()
    for y in range(32):
        for px in range(X0, X1 + 1):
            if ((px + y) // 8) % 2 == 0:
                _put(g, px, y, "a")
    # infield dirt is bare: clear the mow inside the diamond
    for y in range(2, 31):
        k = (y - 2) if y <= 16 else (30 - y)
        for px in range(95 - 2 * k, 96 + 2 * k + 1):
            _put(g, px, y, ".")
    _infield(g)
    return _rows(g)


BACKDROP = {"nfl": gridiron(), "nba": hardwood(), "nhl": rink(),
            "mlb": diamond()}

def backdrop(c, lg, primary, secondary):
    """Drawn as two half-height sprites, not one.

    A 172x32 bitmap is 5,504 cells and the host refuses anything over 4,096,
    so the surface is cut across the middle into two 172x16 sprites of 2,752
    each. The seam is invisible because the halves are slices of one grid."""
    art = BACKDROP[lg]
    leg = {"a": tint(primary, secondary, TEX_LO),
           "b": tint(primary, secondary, TEX_HI)}
    c.sprite(art[0:16], X0, 0, legend = leg)
    c.sprite(art[16:32], X0, 16, legend = leg)

def frame(c, ac, page):
    """Segmented bracket. page 0 = no pager (error card)."""
    off = _hex(_scale(_rgb(ac), 0.28))
    for i in range(3):
        y0 = i * 11
        col = ac if (page == 0 or page == i + 1) else off
        c.rect(0, y0, 1, y0 + 9, fill = col)
        c.rect(c.width - 2, y0, c.width - 1, y0 + 9, fill = col)
    top = ac if page <= 1 else off
    bot = ac if (page == 0 or page == 3) else off
    c.rect(2, 0, 4, 0, fill = top)
    c.rect(c.width - 5, 0, c.width - 3, 0, fill = top)
    c.rect(2, 31, 4, 31, fill = bot)
    c.rect(c.width - 5, 31, c.width - 3, 31, fill = bot)


def ink(c, s, x, y, font = "5x7", color = "white", align = "left"):
    """Every string on a backdrop goes through here.

    A 1px stroke in the background colour buys the glyph a moat, so text
    stays readable over a yard line without the backdrop having to be dimmed
    to the point of pointlessness. The moat lands in the buffer ring the
    spacing rules already demand, so it costs no layout."""
    c.text_stroke(s, x, y, font = font, color = color, stroke = BG,
                  align = align)

# ------------------------------------------------------------------ sprites

# P shell, D shade, L highlight, S trim, W white, M facemask, G mask shade,
# E dark padding, N numeral, K numeral outline. 31x24.
HELMET = [
    "..........PPPPP................",
    "........PPSSSSSPP..............",
    "......PPSSSSSSSSSPP............",
    ".....PSSSSWWWWWSSSSP...........",
    "....PSSSWWPPPPPWWSSSP..........",
    "...PSSWWPPPPPPPPPWWSSP.........",
    "..PSSWPPPPPPPPPPLLPWSSP........",
    "..PSSWPPPPPPPPPPLLPWSSP........",
    ".PSSWPPPPPPPPPPPPLLPWSSP.......",
    ".PPPPPPPPPPPPPPPPPPPWSSPMMMMM..",
    ".PPPPPPPPPPPPPPPPPPPPPPPM..G.M.",
    ".DPPPPPPPPPPPPPPPPPPPPE.M..G..M",
    ".DPPPPPPPPPPPPPPPPPPE...M..G..M",
    ".DPPPPPPPPPPPPPPPPPEMMMMMMMMMMM",
    ".DPPPPPPPPPPPPPPPPPE....M..G..M",
    ".DPPPPPPPPPPPPPPPPPE....M..G..M",
    ".DPPPPPPPPPPPPPPPPPE....M..G..M",
    ".DPPPPPPPPPPPPPPPPPPMMMMMMMMMMM",
    "PPPPPPPPPPPPPPPPPPPPPPE.M..G..M",
    "PPPPPPPPPPEEPPPPPPPPPPPPM..GMM.",
    "PPPPPPPPPEEEEPPPPPPPPPPPM.MM...",
    ".DDPPPPPPPEEPPPPPPPPPPPPPM.....",
    "..DDPPPPPPPPPPPPPPPPPPPPP......",
    "....DDDDDDDDDDDDDDDDDDDD.......",
]

# Helmet-side numerals, 5x7.
DIGITS = {
    "0": ["XXXXX", "XX.XX", "XX.XX", "XX.XX", "XX.XX", "XX.XX", "XXXXX"],
    "1": ["..XX.", ".XXX.", "..XX.", "..XX.", "..XX.", "..XX.", ".XXXX"],
    "2": ["XXXXX", "...XX", "...XX", "XXXXX", "XX...", "XX...", "XXXXX"],
    "3": ["XXXXX", "...XX", "...XX", ".XXXX", "...XX", "...XX", "XXXXX"],
    "4": ["XX.XX", "XX.XX", "XX.XX", "XXXXX", "...XX", "...XX", "...XX"],
    "5": ["XXXXX", "XX...", "XX...", "XXXXX", "...XX", "...XX", "XXXXX"],
    "6": ["XXXXX", "XX...", "XX...", "XXXXX", "XX.XX", "XX.XX", "XXXXX"],
    "7": ["XXXXX", "...XX", "...XX", "..XX.", "..XX.", ".XX..", ".XX.."],
    "8": ["XXXXX", "XX.XX", "XX.XX", "XXXXX", "XX.XX", "XX.XX", "XXXXX"],
    "9": ["XXXXX", "XX.XX", "XX.XX", "XXXXX", "...XX", "...XX", "XXXXX"],
}


# NBA jersey, NHL sweater and MLB jersey, lifted from athlete-tracker-nfl
# along with the large numeral set they stamp. Same legend as the helmet:
# P shell, D shade, L highlight, S trim, W white, E dark, N numeral, K outline.

NBA_JERSEY = [
    "...SSSSSS..........SSSSSS...",
    "...SPPPPS..........SPPPPS...",
    "..SPPPPPS..........SPPPPPS..",
    "..SPPPPPPS........SPPPPPPS..",
    "..SPPPPPPS........SPPPPPPS..",
    ".SPPPPPPPPS......SPPPPPPPPS.",
    ".SPPPPPPPPPS....SPPPPPPPPPS.",
    "SPPPPPPPPPPPSSSSPPPPPPPPPPPS",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DPPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "SSSSSSSSSSSSSSSSSSSSSSSSSSSS",
    "WWWWWWWWWWWWWWWWWWWWWWWWWWWW",
    "SSSSSSSSSSSSSSSSSSSSSSSSSSSS",
    ".DDDDDDDDDDDDDDDDDDDDDDDDDD.",
]

NHL_SWEATER = [
    "..........SSSSSSSSSS..........",
    ".......PPPSS......SSPPP.......",
    "......PPPPPSS....SSPPPPP......",
    ".....PPPPPPPSS..SSPPPPPPP.....",
    "....PPPPPPPPPSSSSPPPPPPPPP....",
    "...PPPPPPPPPPPSSPPPPPPPPPPP...",
    "..PPPPPPPPPPPPPPPPPPPPPPPPPP..",
    ".PPPPPPPPPPPPPPPPPPPPPPPPPPPP.",
    "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
    "PPPPP.DPPPPPPPPPPPPPPPPD.PPPPP",
    "PPPPP.DPPPPPPPPPPPPPPPPD.PPPPP",
    "PPPPP.DPPPPPPPPPPPPPPPPD.PPPPP",
    "SSSSS.DPPPPPPPPPPPPPPPPD.SSSSS",
    "WWWWW.DPPPPPPPPPPPPPPPPD.WWWWW",
    "SSSSS.DPPPPPPPPPPPPPPPPD.SSSSS",
    "PPPPP.DPPPPPPPPPPPPPPPPD.PPPPP",
    "DDDDD.DPPPPPPPPPPPPPPPPD.DDDDD",
    "......DPPPPPPPPPPPPPPPPD......",
    "......DPPPPPPPPPPPPPPPPD......",
    "......DPPPPPPPPPPPPPPPPD......",
    "......DPPPPPPPPPPPPPPPPD......",
    "......DPPPPPPPPPPPPPPPPD......",
    "......SSSSSSSSSSSSSSSSSS......",
    "......WWWWWWWWWWWWWWWWWW......",
    "......SSSSSSSSSSSSSSSSSS......",
    "......PPPPPPPPPPPPPPPPPP......",
    "......DDDDDDDDDDDDDDDDDD......",
]

MLB_JERSEY = [
    "........PPPS........SPPP......",
    "......PPPPPS......SPPPPP......",
    "....PPPPPPPPS....SPPPPPPPP....",
    "..PPPPPPPPPPPS..SPPPPPPPPPPP..",
    ".PPPPPPPPPPPPPSSPPPPPPPPPPPPP.",
    "PPPPPPPPPPPPPPSSPPPPPPPPPPPPPP",
    "PPPPPPPPPPPPPPSWPPPPPPPPPPPPPP",
    "PPPPPPPPPPPPPPSSPPPPPPPPPPPPPP",
    "SSSSSDPPPPPPPPSSPPPPPPPPDSSSSS",
    ".....DPPPPPPPPSWPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSWPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSWPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSWPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSWPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSSPPPPPPPPD.....",
    ".....DPPPPPPPPSWPPPPPPPPD.....",
    ".....DDDDDDDDDDDDDDDDDDDD.....",
]

# Chest numerals, 6x11 -- the jerseys carry the number across the front, so
# they get a bigger face than the helmet's 5x7 side decal.

BIG_DIGITS = {
    "0": [".XXXX.", "XXXXXX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX."],
    "1": ["..XX..", ".XXX..", "XXXX..", "..XX..", "..XX..", "..XX..", "..XX..", "..XX..", "..XX..", "XXXXXX", "XXXXXX"],
    "2": [".XXXX.", "XXXXXX", "XX..XX", "....XX", "...XXX", "..XXX.", ".XXX..", "XXX...", "XX....", "XXXXXX", "XXXXXX"],
    "3": [".XXXX.", "XXXXXX", "XX..XX", "....XX", "..XXX.", "..XXX.", "....XX", "....XX", "XX..XX", "XXXXXX", ".XXXX."],
    "4": ["...XX.", "..XXX.", ".XXXX.", "XX.XX.", "XX.XX.", "XXXXXX", "XXXXXX", "...XX.", "...XX.", "...XX.", "...XX."],
    "5": ["XXXXXX", "XXXXXX", "XX....", "XX....", "XXXXX.", "XXXXXX", "....XX", "....XX", "XX..XX", "XXXXXX", ".XXXX."],
    "6": [".XXXX.", "XXXXXX", "XX....", "XX....", "XXXXX.", "XXXXXX", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX."],
    "7": ["XXXXXX", "XXXXXX", "....XX", "....XX", "...XX.", "...XX.", "..XX..", "..XX..", "..XX..", "..XX..", "..XX.."],
    "8": [".XXXX.", "XXXXXX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX.", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX."],
    "9": [".XXXX.", "XXXXXX", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXXX", "....XX", "....XX", "XXXXXX", ".XXXX."],
}

# 3x5. The step from one club to the next on the career path.
ARROW = [
    "X..",
    ".X.",
    "..X",
    ".X.",
    "X..",
]

# league -> kit art, numeral set, numeral centre x, numeral top y, and where
# the sprite sits on the panel. Each kit is a different height, so the y is
# per sport rather than a shared constant.
KIT = {
    "nfl": {"art": HELMET, "digits": DIGITS, "cx": 10, "top": 10, "y": 4},
    "nba": {"art": NBA_JERSEY, "digits": BIG_DIGITS, "cx": 14, "top": 11, "y": 1},
    "nhl": {"art": NHL_SWEATER, "digits": BIG_DIGITS, "cx": 15, "top": 9, "y": 3},
    "mlb": {"art": MLB_JERSEY, "digits": BIG_DIGITS, "cx": 15, "top": 10, "y": 3},
}

def stamp_number(art, digits, number, cx, top):
    """Art rows with the number drawn in N and a 1px K outline, so a white 15
    still reads on a white helmet."""
    g = [[row[i] for i in range(len(row))] for row in art]
    h, w = len(g), len(g[0])
    nm = number[:2]
    if not nm:
        return art
    gw, gh = len(digits["0"][0]), len(digits["0"])
    x0 = cx - (len(nm) * gw + (len(nm) - 1)) // 2
    lit = {}
    for i in range(len(nm)):
        glyph = digits.get(nm[i])
        if glyph == None:
            continue
        for yy in range(gh):
            for xx in range(gw):
                if glyph[yy][xx] == "X":
                    lit[(x0 + i * (gw + 1) + xx, top + yy)] = True
    for (x, y) in lit:
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                ax, ay = x + dx, y + dy
                if 0 <= ax and ax < w and 0 <= ay and ay < h:
                    if not lit.get((ax, ay)) and g[ay][ax] != ".":
                        g[ay][ax] = "K"
    for (x, y) in lit:
        if 0 <= x and x < w and 0 <= y and y < h:
            g[y][x] = "N"
    return ["".join(r) for r in g]

# -------------------------------------------------------------------- text

FOLD = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A", "Ā": "A",
    "Ă": "A", "Ą": "A", "Ç": "C", "Č": "C", "Ć": "C", "Ď": "D", "Đ": "D",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E", "Ě": "E", "Ę": "E", "Ē": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I", "Ī": "I", "Ľ": "L", "Ł": "L",
    "Ĺ": "L", "Ñ": "N", "Ň": "N", "Ń": "N", "Ó": "O", "Ò": "O", "Ô": "O",
    "Ö": "O", "Õ": "O", "Ø": "O", "Ő": "O", "Ř": "R", "Ŕ": "R", "Š": "S",
    "Ś": "S", "Ş": "S", "Ș": "S", "Ť": "T", "Ţ": "T", "Ț": "T", "Ú": "U",
    "Ù": "U", "Û": "U", "Ü": "U", "Ů": "U", "Ű": "U", "Ū": "U", "Ý": "Y",
    "Ÿ": "Y", "Ž": "Z", "Ź": "Z", "Ż": "Z", "ß": "SS", "Æ": "AE", "Œ": "OE",
}

OK_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .'-/"

def plain(s):
    """Uppercase, accents folded, anything the panel fonts cannot draw dropped.
    Every string out of ESPN goes through here before it is measured."""
    out = ""
    # str() first: get() normalises null to the fallback but not the TYPE, and
    # a JSON number arriving where a string was expected (a teamHistory
    # "seasons": 2019, say) has no .upper() and takes the page down with it.
    for ch in str(s or "").upper().elems():
        out += FOLD.get(ch, ch)
    keep = ""
    for ch in out.elems():
        if ch in OK_CHARS:
            keep += ch
    return keep.strip()

def digits_only(s):
    out = ""
    for ch in str(s).elems():
        if ch >= "0" and ch <= "9":
            out += ch
    return out

def to_int(s, fallback = 0):
    """ESPN hands back "38,648" and "-10" as strings; int() raises on both, and
    a raised host error kills the whole render."""
    t = str(s).strip().replace(",", "")
    neg = t.startswith("-")
    if neg or t.startswith("+"):
        t = t[1:]
    d = digits_only(t)
    if d == "" or len(d) != len(t):
        return fallback
    v = int(d)
    return -v if neg else v

def fmt_stat(v):
    """A feed total ready to draw. "1121" becomes "1,121" so it cannot be
    misread as eleven-twenty-one, while a kicker's "417-468" is left exactly
    as ESPN sent it -- it is a made/attempted pair, not a number."""
    t = str(v).replace(",", "")
    if t != "" and digits_only(t) == t:
        return commas(int(t))
    return plain(v)

def commas(n):
    s = str(abs(int(n)))
    out = ""
    for i in range(len(s)):
        if i > 0 and (len(s) - i) % 3 == 0:
            out += ","
        out += s[i]
    return ("-" if n < 0 else "") + out

# -------------------------------------------------------------------- feed

ESPN = "https://site.web.api.espn.com/apis/common/v3/sports/"
SPORT_PATH = {"nfl": "football/nfl", "nba": "basketball/nba",
              "mlb": "baseball/mlb", "nhl": "hockey/nhl"}

def athlete_url(lg, pid, tail = ""):
    return ESPN + SPORT_PATH[lg] + "/athletes/" + str(pid) + tail

def get_json(url, ttl):
    resp = http.get(url, ttl_seconds = ttl)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def profile(lg, pid):
    """Identity: name, number, position, team colours, college, draft."""
    # A career moves on the scale of weeks, so everything here is cached for
    # 6 hours. That deliberately outruns the manifest refresh of 3600: the panel
    # re-renders hourly, but a career total only moves after a game, so most
    # renders are served from cache and ESPN sees one request per player per
    # six hours rather than one per hour.
    d = get_json(athlete_url(lg, pid), 21600)
    a = get(d, "athlete")
    if a == None:
        return None
    team = get(a, "team", {})
    # "2017: Rd 1, Pk 10 (KC)". plain() drops the colon, comma and brackets as
    # unprintable, so the round and pick have to be read off the raw string --
    # splitting the folded text on "," found one field and no draft at all.
    draft = get(a, "displayDraft", "").upper()
    toks = []
    word = ""
    for ch in draft.elems():
        if (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9"):
            word += ch
        elif word != "":
            toks.append(word)
            word = ""
    if word != "":
        toks.append(word)
    rd, pk = "", ""
    for i in range(len(toks) - 1):
        if toks[i] == "RD":
            rd = digits_only(toks[i + 1])
        if toks[i] == "PK":
            pk = digits_only(toks[i + 1])
    return {
        "lg": lg,
        "id": pid,
        "last": plain(get(a, "lastName", "") or get(a, "displayName", "")),
        "first": plain(get(a, "firstName", "")),
        "num": digits_only(get(a, "jersey", "")),
        "pos": plain(dig(a, ["position", "abbreviation"], "")),
        "team": plain(get(team, "abbreviation", "")),
        "logo": TEAM_LOGO.get(lg + ":" + str(get(team, "id", "")), ""),
        "color": get(team, "color", "8A8A8A"),
        "alt": get(team, "alternateColor", "F0F0F0"),
        "college": plain(dig(a, ["college", "name"], "")),
        # "10TH SEASON" -> "10TH SZN": 12px back on the tightest row in the app.
        "exp": plain(get(a, "displayExperience", "")).replace("SEASON", "SZN"),
        "rd": rd,
        "pk": pk,
        "undrafted": draft.find("UNDRAFTED") >= 0,
        "active": get(a, "active", True),
    }

def bio(lg, pid):
    return get_json(athlete_url(lg, pid, "/bio"), 21600)

def stats(lg, pid):
    return get_json(athlete_url(lg, pid, "/stats"), 21600)

# ------------------------------------------------------------------ career

# position -> the ESPN stat category that defines the player. In the NFL every
# player carries every category (a kicker has a `passing` block of zeros), so
# the category cannot be chosen by which one is present -- only by position,
# with a non-zero hero as the tie-break. The other three leagues only return
# the categories that apply, but the same machinery works for them.
#
# Keys are "<league>:<position>"; a league with one shape for everyone (the
# NBA) needs no entries at all and falls through to its ORDER chain.
POS_CAT = {
    "nfl:QB": "passing",
    "nfl:RB": "rushing", "nfl:FB": "rushing", "nfl:HB": "rushing",
    "nfl:WR": "receiving", "nfl:TE": "receiving",
    "nfl:K": "kicking", "nfl:PK": "kicking",
    "nfl:P": "punting",
    # Defenders were missing entirely, so they fell through to the chain below
    # and were described by whatever they happened to have -- which for most
    # of them is the passing line from a trick play.
    "nfl:CB": "defensive", "nfl:S": "defensive", "nfl:FS": "defensive",
    "nfl:SS": "defensive", "nfl:DB": "defensive", "nfl:LB": "defensive",
    "nfl:ILB": "defensive", "nfl:OLB": "defensive", "nfl:MLB": "defensive",
    "nfl:DE": "defensive", "nfl:DT": "defensive", "nfl:NT": "defensive",
    "nfl:EDGE": "defensive",
    # Baseball splits cleanly down the middle: anyone who takes the mound is
    # judged on pitching, everyone else on what they do with the bat.
    "mlb:SP": "pitching", "mlb:RP": "pitching", "mlb:P": "pitching",
    # Hockey names its skater categories after the position itself.
    "nhl:C": "center", "nhl:LW": "leftWing", "nhl:RW": "rightWing",
    "nhl:D": "defenseman", "nhl:G": "goaltender",
}

# category -> (hero stat, hero label, [(stat, label), (stat, label)])
HERO = {
    "passing": ["passingYards", "PASS YDS",
                [["passingTouchdowns", "TD"], ["interceptions", "INT"]]],
    # Touchdowns lead for the ball carriers. The label row fits two support
    # stats most of the time and one when the numbers run long ("2,860 CAR" is
    # 38px on its own), so the order decides what survives -- and a back's
    # touchdowns are the number people came for, not his carries.
    "rushing": ["rushingYards", "RUSH YDS",
                [["rushingTouchdowns", "TD"], ["rushingAttempts", "CAR"]]],
    "receiving": ["receivingYards", "REC YDS",
                  [["receivingTouchdowns", "TD"], ["receptions", "REC"]]],
    "defensive": ["totalTackles", "TACKLES",
                  [["sacks", "SACK"], ["interceptions", "INT"]]],
    "kicking": ["totalKickingPoints", "KICK PTS",
                [["fieldGoalsMade-fieldGoalAttempts", "FG"],
                 ["longFieldGoalMade", "LNG"]]],
    "punting": ["puntYards", "PUNT YDS",
                [["punts", "PUNTS"], ["grossAvgPuntYards", "AVG"]]],
    "scoring": ["totalPoints", "POINTS",
                [["totalTouchdowns", "TD"], ["fieldGoals", "FG"]]],

    # Baseball. ESPN labels the hitting block "career-batting" (hyphen and
    # all) and the pitching block "pitching".
    "career-batting": ["homeRuns", "HOME RUNS",
                       [["RBIs", "RBI"], ["avg", "AVG"]]],
    "pitching": ["strikeouts", "STRIKEOUTS",
                 [["wins", "W"], ["ERA", "ERA"]]],

    # Basketball. "totals" is the counting block; "averages" alongside it is
    # per-game and carries the games-played count that totals omits.
    "totals": ["points", "POINTS",
               [["totalRebounds", "REB"], ["assists", "AST"]]],

    # Hockey names a skater's category after their position, so there are four
    # of them saying the same thing, plus the goaltender's own block.
    "center": ["points", "POINTS", [["goals", "G"], ["assists", "A"]]],
    "leftWing": ["points", "POINTS", [["goals", "G"], ["assists", "A"]]],
    "rightWing": ["points", "POINTS", [["goals", "G"], ["assists", "A"]]],
    "defenseman": ["points", "POINTS", [["goals", "G"], ["assists", "A"]]],
    "goaltender": ["wins", "WINS",
                   [["shutouts", "SO"], ["savePct", "SV%"]]],
}

# The fallback chain per league, tried after the position's own pick. An NFL
# lineman scores in no category at all, so the chain runs out and the honest
# hero becomes the thing he did do: turn up.
#
# A fallback category also has to clear FLOOR before it is allowed to define
# a player. Travis Kelce's feed carries passingYards "4" from a trick play and
# a fullback carries three career tackles; without a floor the chain seizes on
# that noise, and a fullback's page announced "3 TACKLES" as his career. The
# floor applies ONLY to the fallback chain -- a player's own position always
# wins, however small the number.
FLOOR = {
    "passing": 100, "rushing": 50, "receiving": 50, "defensive": 10,
    "kicking": 10, "punting": 10, "scoring": 6,
    "career-batting": 1, "pitching": 1, "totals": 1,
    "center": 1, "leftWing": 1, "rightWing": 1, "defenseman": 1,
    "goaltender": 1,
}

ORDER = {
    "nfl": ["passing", "rushing", "receiving", "defensive", "kicking",
            "punting", "scoring"],
    "mlb": ["career-batting", "pitching"],
    "nba": ["totals"],
    "nhl": ["center", "leftWing", "rightWing", "defenseman", "goaltender"],
}

# Where each league keeps its games-played count. The NBA's "totals" block has
# no games column at all, so it is read off "averages" instead.
GP_NAME = {"nfl": "gamesPlayed", "mlb": "gamesPlayed", "nba": "gamesPlayed",
           "nhl": "games"}

def cat_value(cat, name):
    """One career total out of a category, by stat name."""
    names = get(cat, "names", [])
    totals = get(cat, "totals", [])
    for i in range(len(names)):
        if names[i] == name and i < len(totals):
            return str(totals[i])
    return ""

def season_series(cat, name):
    """[[year, value], ...] for one stat, oldest first. The bars.

    A player traded mid-season gets one row per club AND a combined row, so
    Christian McCaffrey's 2022 arrives three times: 393 for Carolina, 746 for
    San Francisco and 1,139 as "2022 Totals" with a null teamId. Drawing every
    row gave him three bars for one season and a "12 SZN" count that counted
    the same year twice. One bar per year, and the combined row wins."""
    names = get(cat, "names", [])
    idx = -1
    for i in range(len(names)):
        if names[i] == name:
            idx = i
    if idx < 0:
        return []
    order = []
    best = {}
    combined = {}
    for s in get(cat, "statistics", []):
        row = get(s, "stats", [])
        if idx >= len(row):
            continue
        yr = to_int(dig(s, ["season", "year"], 0))
        if yr <= 0:
            continue
        # The combined row is the one with no club attached to it.
        total = get(s, "teamId", "") == ""
        if yr not in best:
            order.append(yr)
            best[yr] = to_int(row[idx])
            combined[yr] = total
        elif total and not combined[yr]:
            best[yr] = to_int(row[idx])
            combined[yr] = True
        elif not combined[yr] and to_int(row[idx]) > best[yr]:
            best[yr] = to_int(row[idx])
    out = []
    for yr in order:
        out.append([yr, best[yr]])
    return out

def games_played(lg, cats, cat):
    """Games played for the chosen category, falling back across the league's
    other blocks. The NBA's "totals" has no games column, so a 24-season
    career would otherwise report 0 GP on page 2."""
    for nm in (GP_NAME.get(lg, "gamesPlayed"), "gamesPlayed", "games"):
        v = to_int(cat_value(cat, nm))
        if v > 0:
            return v
    for key in ORDER.get(lg, []):
        other = cats.get(key)
        if other != None:
            for nm in ("gamesPlayed", "games"):
                v = to_int(cat_value(other, nm))
                if v > 0:
                    return v
    # Last resort: any block at all. The NBA keeps it in "averages", which is
    # not in the ORDER chain because it is per-game, not career totals.
    for key in cats:
        for nm in ("gamesPlayed", "games"):
            v = to_int(cat_value(cats[key], nm))
            if v > 0:
                return v
    return 0

def career(lg, st, pos):
    """The one category this player is defined by, already resolved to a hero
    value, two support stats and the per-season series."""
    cats = {}
    for cat in get(st, "categories", []):
        cats[get(cat, "name", "")] = cat
    order = ORDER.get(lg, [])
    tries = []
    own = POS_CAT.get(lg + ":" + pos, "")
    if own != "":
        tries.append(own)
    for k in order:
        if k not in tries:
            tries.append(k)
    for key in tries:
        cat = cats.get(key)
        if cat == None or key not in HERO:
            continue
        spec = HERO[key]
        raw = cat_value(cat, spec[0])
        # A rate stat ("3.20" ERA, ".917" SV%) has no leading integer, so the
        # >0 test is on the digits rather than on int() of the whole string.
        v = to_int(digits_only(raw), 0)
        if v <= 0:
            continue
        # Own position: any number at all. Fallback: it has to be a number
        # that plausibly describes a career, not a trick-play artefact.
        if key != own and v < FLOOR.get(key, 1):
            continue
        sup = []
        for s in spec[2]:
            v = cat_value(cat, s[0])
            if v != "" and v != "-" and v != "--":
                sup.append([fmt_stat(v), s[1]])
        return {
            "hero": fmt_stat(raw),
            "label": spec[1],
            "sup": sup,
            "series": season_series(cat, spec[0]),
            "gp": games_played(lg, cats, cat),
        }
    # No category scored: an NFL lineman, or a rookie yet to play.
    gp, series = 0, []
    for key in order:
        cat = cats.get(key)
        if cat != None:
            gp = max(gp, games_played(lg, cats, cat))
            if not series:
                series = season_series(cat, GP_NAME.get(lg, "gamesPlayed"))
    if gp <= 0:
        return None
    return {"hero": commas(gp), "label": "GAMES", "sup": [], "series": series,
            "gp": gp}

# ------------------------------------------------------------------ awards

AWARD_SHORT = {
    "SUPER BOWL MVP": "SB MVP",
    "NFL MVP": "NFL MVP",
    "NFL OFFENSIVE PLAYER OF THE YEAR": "OPOY",
    "NFL DEFENSIVE PLAYER OF THE YEAR": "DPOY",
    "NFL OFFENSIVE ROOKIE OF THE YEAR": "OROY",
    "NFL DEFENSIVE ROOKIE OF THE YEAR": "DROY",
    "NFL COMEBACK PLAYER OF THE YEAR": "COMEBACK",
    # ESPN's string is "Walter Payton NFL Man of the Year", so the key that
    # used to be here ("NFL WALTER PAYTON...") never matched anything and the
    # award rendered as "WALTER" -- the longest-word tie-break keeps the
    # earlier of two 6-letter words.
    "WALTER PAYTON NFL MAN OF THE YEAR": "PAYTON",
    "WALTER PAYTON AWARD": "PAYTON",
    "JOHNNY UNITAS GOLDEN ARM AWARD": "UNITAS",
    "FRED BILETNIKOFF AWARD": "BILETNKF",
    "BURLSWORTH TROPHY": "BURLSWTH",
    "CHUCK BEDNARIK AWARD": "BEDNARIK",
    "BRONKO NAGURSKI TROPHY": "NAGURSKI",
    "DOAK WALKER AWARD": "WALKER",
    "DAVEY O'BRIEN AWARD": "OBRIEN",
    "OUTLAND TROPHY": "OUTLAND",
    "LOMBARDI AWARD": "LOMBARDI",
    "MAXWELL AWARD": "MAXWELL",
    "JIM THORPE AWARD": "THORPE",
    "RIMINGTON TROPHY": "RIMINGTN",
    "PAUL HORNUNG AWARD": "HORNUNG",
    "HEISMAN TROPHY": "HEISMAN",
    "PRO BOWL": "PRO BOWL",

    # Cross-sport honours whose longest word is not what anyone calls them.
    # "Most Valuable Player" reduces to VALUABLE, "Finals MVP" to FINALS,
    # "Maurice Richard Trophy" to MAURICE (the tie goes to the earlier word)
    # and "All-Defensive Team" clipped to the unreadable ALL-DEFE.
    "MOST VALUABLE PLAYER": "MVP",
    "FINALS MVP": "FINALS MVP",
    "NLCS MVP": "NLCS MVP",
    "ALCS MVP": "ALCS MVP",
    "ALL-STAR MVP": "ASG MVP",
    "DEFENSIVE PLAYER OF THE YEAR": "DPOY",
    "CLUTCH PLAYER OF THE YEAR": "CLUTCH",
    "SIXTH MAN OF THE YEAR": "6TH MAN",
    "MOST IMPROVED PLAYER": "MIP",
    "ALL-DEFENSIVE TEAM": "ALL-DEF",
    "ALL-ROOKIE TEAM": "ALL-ROOK",
    "GOLD GLOVE": "GOLD GLV",
    "SILVER SLUGGER": "SLUGGER",
    "HANK AARON AWARD": "AARON",
    "ROBERTO CLEMENTE AWARD": "CLEMENTE",
    "MAURICE RICHARD TROPHY": "RICHARD",
    "TED LINDSAY AWARD": "LINDSAY",
    "CONN SMYTHE TROPHY": "SMYTHE",
    "ART ROSS TROPHY": "ART ROSS",
    "JAMES NORRIS TROPHY": "NORRIS",
    "FRANK J. SELKE TROPHY": "SELKE",
    "LADY BYNG TROPHY": "LADY BYNG",
    "CALDER TROPHY": "CALDER",
    "HART TROPHY": "HART",
    "VEZINA TROPHY": "VEZINA",
    "WILLIAM M. JENNINGS TROPHY": "JENNINGS",
}

def award_short(name):
    """A trophy label that fits a ~48px column.

    Mapped awards win. Anything unmapped falls back to its longest
    distinctive word, which is usually what the award is called out loud
    ("Art Ross Trophy" -> ROSS), with the rank carried separately so the
    ranked team honours stay apart."""
    n = plain(name)
    if n in AWARD_SHORT:
        return AWARD_SHORT[n]
    if len(n) <= 8:
        return n
    # The longest distinctive word, not the initials. Initials turned "Doak
    # Walker Award" into "DW" and "Heisman Memorial Trophy" into "HMT", which
    # name nothing; "WALKER" and "HEISMAN" are what the award is called out
    # loud. Ties keep the earlier word, so "Walter Payton Man of the Year"
    # gives PAYTON rather than the equally long WALTER.
    skip = ["OF", "THE", "AWARD", "NFL", "YEAR", "A", "AND", "TROPHY",
            "MEMORIAL", "PLAYER", "MAN", "TEAM"]
    # The honours that come in ranked flavours -- "All-NBA 1st Team" and
    # "All-NBA 2nd Team", "First All-Star Team" and "Second All-Star Team" --
    # both reduce to the same word, so LeBron's trophy case showed ALL-NBA
    # twice with different counts and no way to tell them apart. Carry the
    # rank through as a digit.
    rank = {"FIRST": "1", "1ST": "1", "SECOND": "2", "2ND": "2",
            "THIRD": "3", "3RD": "3"}
    tier = ""
    best = ""
    for w in n.split(" "):
        if w in rank:
            tier = rank[w]
            continue
        if w != "" and w not in skip and len(w) > len(best):
            best = w
    if best == "":
        return n[:9]
    # 9 rather than 8: a trophy column is ~48px and 4x5 fits a dozen
    # characters in it, so the extra letter costs nothing and "ALL-DEFEN"
    # survives where "ALL-DEFE" did not. clip() still bounds it to the column.
    return best[:9] + (" " + tier if tier != "" else "")

def awards(lg, b):
    out = []
    for a in get(b, "awards", []):
        # ESPN tags each award with the league that gave it, and a player who
        # starred in college carries those too. Travis Hunter's page showed
        # BEDNARIK / BILETNIKOFF / HEISMAN -- three college awards -- as his
        # professional trophy case, and they crowded out the career path that
        # should have shown instead.
        al = str(get(a, "league", lg)).lower()
        if al != "" and al != lg:
            continue
        nm = award_short(get(a, "name", ""))
        if nm == "":
            continue
        cnt = to_int(digits_only(get(a, "displayCount", "1")), 1)
        yrs = get(a, "seasons", [])
        last = ""
        if len(yrs) > 0:
            last = "'" + plain(str(yrs[0]))[-2:]
        out.append({"name": nm, "count": max(1, cnt), "last": last})
    # Biggest haul first. ESPN returns them in its own order, which put
    # LeBron's 4x All-NBA 2nd Team in the case and his 13x All-NBA 1st Team
    # in the "+9" overflow -- the page showed the lesser honours and hid the
    # career-defining one. Selection sort: the list is never more than a
    # dozen long, and Starlark has no stable sorted(key=) worth relying on.
    ranked = []
    taken = {}
    for i in range(len(out)):
        best = -1
        for j in range(len(out)):
            if taken.get(j):
                continue
            if best < 0 or out[j]["count"] > out[best]["count"]:
                best = j
        if best < 0:
            break
        taken[best] = True
        ranked.append(out[best])
    return ranked

def short_span(s):
    """"2016-2017, 2024-2025" -> "16-17 24-25". A player with two separate
    spells at one club produced a 20-character span, which at 4x5 left 87px
    for the name and cut "BALTIMORE RAVENS" to "BALTIMORE R". Dropping the
    century costs nothing a viewer needs and buys 36px back."""
    out = ""
    run = ""
    for ch in (str(s) + " ").elems():
        if ch >= "0" and ch <= "9":
            run += ch
        else:
            out += run[2:] if len(run) == 4 else run
            run = ""
            out += ch
    return out.strip()

def span_tokens(s):
    """The year tokens of a span, in order. "16-17 24-25" -> [16,17,24,25]."""
    toks = []
    cur = ""
    for ch in (str(s) + " ").elems():
        if ch == "-" or ch == " ":
            if cur != "":
                toks.append(cur)
                cur = ""
        else:
            cur += ch
    return toks

def merge_span(older, newer):
    """One span covering both spells at the same club.

    Concatenating them gave Derek Carr "14-20 20-23", which is both wider than
    the crest it labels -- widening the column and pushing another club out of
    the row -- and wrong: a relocation is one continuous spell, not two."""
    a, b = span_tokens(older), span_tokens(newer)
    if len(a) == 0:
        return newer
    if len(b) == 0:
        return older
    return a[0] + "-" + b[len(b) - 1]

def teams(lg, b):
    """[{name, span, logo}, ...] newest first. The crest is looked up by team
    id, because teamHistory's own `abbreviation` comes back null."""
    out = []
    for t in get(b, "teamHistory", []):
        nm = plain(get(t, "displayName", ""))
        sp = short_span(plain(get(t, "seasons", "")).replace("CURRENT", "NOW"))
        if nm == "":
            continue
        out.append({
            "name": nm,
            "span": sp,
            # "now" is carried per club rather than inferred from position in
            # the list: ESPN does not return teamHistory in chronological
            # order, so "the last one" is not "the current one".
            "now": sp.find("NOW") >= 0,
            "logo": TEAM_LOGO.get(lg + ":" + str(get(t, "id", "")), ""),
        })
    return out

def logo_box(key):
    """[w, h] of a crest, or [0, 0] when the team has no art."""
    wh = LOGO_W.get(key)
    return wh if wh != None else [0, 0]

# --------------------------------------------------------------------- load

def who(ctx):
    """Everything all three pages need. Two or three cached GETs; the profile
    alone is enough to draw page 1, so a stats outage costs a page, not the
    panel."""
    pick = ctx.inputs.get("player", "Patrick Mahomes (NFL)")
    row = PLAYERS.get(pick)
    if row == None:
        return ["UNKNOWN", None]
    p = profile(row[0], row[1])
    if p == None:
        return ["OFFLINE", None]
    return ["OK", p]

def fail(c, state):
    if state == "UNKNOWN":
        nodata(c, "UNKNOWN PLAYER", "PICK ONE FROM THE LIST")
    else:
        nodata(c, "NO ESPN DATA", "RETRYING ON NEXT REFRESH")

# =====================================================================
# PAGE 1 -- "THE PLAYER CARD".  Splice-ready.
#
# Dependency order, top to bottom:
#   1. layout constants          (goes with the house kit, near line 36)
#   2. SMALL_DIGITS              (goes beside DIGITS / BIG_DIGITS)
#   3. SHIELD, league marks      (goes in the sprite block)
#   4. LEAGUE_MARK dict          (goes beside KIT, after the marks)
#   5. helpers                   (goes after palette()/accent()/tint())
#   6. def resume(c, ctx)        (replaces the existing one wholesale)
#
# Uses, unchanged, from the app: X0 X1 TX0 TX1 INK DIM STRUCT BG FONTH
# clip() fit() meta_fit() ink() frame() backdrop() accent() palette()
# _rgb() _hex() _lum() _scale() stamp_number() logo_box() who() fail()
# KIT LOGO_FILE.
#
# DESIGN NOTE -- the name is a FIXED FACE, CENTRED, not fitted to the band.
# See the long comment above name_block().
# =====================================================================


# ------------------------------------------------- 1. layout constants
# The card is four columns: kit | name+badges | badge column. Every edge
# below is inclusive, because c.rect() is.

P1_SPINE_A = 43          # unchanged: the widest kit (NHL sweater) ends at
                         # x=40, so the first spine keeps its 2px clear
P1_BAND_X = 47           # unchanged: 3px clear of the spine
P1_BAND_R = 150          # the name/badge band's right edge
P1_SPINE_B = 152         # second spine: 1px clear of the band on its left,
                         # 2px clear of the badge column on its right
P1_BADGE_X = 155         # badge column 155..181
P1_BADGE_W = 27          # the widest crest we own is mlb_cin at 26px, so 27
                         # is the narrowest box that can centre any of them
P1_NAME_W = P1_BAND_R - P1_BAND_X + 1        # 104px
P1_NAME_Y = 2            # the name owns rows 2..17 whatever face it lands on
P1_NAME_H = 16           # ...and that band is 16 rows, the height of 10x16

P1_ROW_Y = 19            # badge row, rows 19..30
P1_MARK_WH = 12          # every league mark is 12x12
P1_CHIP_X = P1_BAND_X + P1_MARK_WH + 3       # 62: 3px clear of the mark
P1_CHIP_Y = 20           # chip rows 20..29
P1_CHIP_H = 10
P1_CHIP_PAD = 3          # pixels of fill either side of the chip's text
P1_TEXT_GAP = 4          # clear pixels between the chip and the text block
P1_TEXT_R = P1_BAND_R - 1    # 149. ink()'s halo inks 1px past the glyph box,
                             # so right-aligning on 150 would put black on
                             # 151 and leave the spine at 152 touching it.
P1_LINE1_Y = 19          # college      rows 19..23 (halo 18..24)
P1_LINE2_Y = 26          # seasons/etc  rows 26..30 (halo 25..31)

P1_CREST_Y = 2           # crest box rows 2..20
P1_CREST_H = 19          # 93 of our 124 crests are exactly 19 tall
P1_SHIELD_W = 11
P1_SHIELD_Y = 22         # shield rows 22..31, with row 21 as the gap
P1_SHIELD_CX = 5         # numeral centre column inside SHIELD
P1_SHIELD_TOP = 1        # numeral top row inside SHIELD
P1_FLIP_LUM = 0.55       # above this luminance, text on an accent fill goes
                         # black. Green Bay's #68FFA3 is 0.85 and would be
                         # unreadable in white; Philadelphia's #FF143B is
                         # 0.30 and must stay white.


# ----------------------------------------------------- 2. SMALL_DIGITS
# DIGITS is 5x7 and BIG_DIGITS is wider still; neither fits an 11px shield
# with a pixel of face left around it. 3x5 does: two digits are
# 3 + 1 + 3 = 7px, centred on column 5 they occupy columns 2..8, inside the
# shield's 9px-wide face.
#
# stamp_number() takes this set unmodified. It reads len(digits["0"][0])
# for the glyph width and len(digits["0"]) for the height and calls
# digits.get(ch), so the only contract is "a dict of equal-sized X/. rows"
# -- which this is. The outline pass writes K wherever a lit pixel's
# 8-neighbour is non-"." , so the ring lands on the shield's S face and
# never off the art.

SMALL_DIGITS = {
    "0": ["XXX", "X.X", "X.X", "X.X", "XXX"],
    "1": [".X.", "XX.", ".X.", ".X.", "XXX"],
    "2": ["XXX", "..X", "XXX", "X..", "XXX"],
    "3": ["XXX", "..X", "XXX", "..X", "XXX"],
    "4": ["X.X", "X.X", "XXX", "..X", "..X"],
    "5": ["XXX", "X..", "XXX", "..X", "XXX"],
    "6": ["XXX", "X..", "XXX", "X.X", "XXX"],
    "7": ["XXX", "..X", "..X", ".X.", ".X."],
    "8": ["XXX", "X.X", "XXX", "X.X", "XXX"],
    "9": ["XXX", "X.X", "XXX", "..X", "XXX"],
}


# ------------------------------------------- 3. shield and league marks
#
# Legend across all of them, extending the kit legend rather than inventing
# a second one:
#   B ball body   = team accent
#   D seam/shade  = the accent at 55%
#   S trim/rim    = team accent (the puck's only visible edge)
#   W white       = #F0F0F0
#   R stitch red  = #C8302A
#   E dark        = #262626
#   K outline     = #000000
#   N numeral     = black or white, whichever reads on the accent
#
# Cell budget: the host refuses a bitmap over 4096 cells. SHIELD is 110 and
# each mark is 144, so there is no danger here -- the backdrop's 172x16
# halves are the only art in this app anywhere near the ceiling.

# 11x10. The numeral well is rows 1..5 centred on column 5.
SHIELD = [
    "KKKKKKKKKKK",
    "KSSSSSSSSSK",
    "KSSSSSSSSSK",
    "KSSSSSSSSSK",
    "KSSSSSSSSSK",
    "KSSSSSSSSSK",
    ".KSSSSSSSK.",
    "..KSSSSSK..",
    "...KSSSK...",
    "....KSK....",
]

# 12x12. Football, laces across the midline.
NFL_MARK = [
    "............",
    "....KKKK....",
    "..KKBBBBKK..",
    ".KBBBBBBBBK.",
    "KBBBBWWBBBBK",
    "KBBWWWWWWBBK",
    "KBBBBWWBBBBK",
    ".KBBBBBBBBK.",
    "..KKBBBBKK..",
    "....KKKK....",
    "............",
    "............",
]

# 12x12. Basketball: vertical seam on column 5, plus the equator.
NBA_MARK = [
    "....KKKK....",
    "..KKBBBBKK..",
    ".KBBBDBBBBK.",
    ".KBBBDBBBBK.",
    "KBBBBDBBBBBK",
    "KDDDDDDDDDDK",
    "KBBBBDBBBBBK",
    ".KBBBDBBBBK.",
    ".KBBBDBBBBK.",
    "..KKBBBBKK..",
    "....KKKK....",
    "............",
]

# 12x12. The one mark that refuses team colour: a team-coloured baseball
# stops being a baseball, and a white ball with red seams is what makes an
# MLB page readable as baseball from across a room.
MLB_MARK = [
    "....KKKK....",
    "..KKWWWWKK..",
    ".KWRWWWWRWK.",
    "KWWRWWWWRWWK",
    "KWWRWWWWRWWK",
    "KWWRWWWWRWWK",
    "KWWRWWWWRWWK",
    "KWWRWWWWRWWK",
    ".KWRWWWWRWK.",
    "..KKWWWWKK..",
    "....KKKK....",
    "............",
]

# 12x12. A black puck on a near-black panel is invisible, so the rim and the
# top face edge wear the accent and only the body stays E.
NHL_MARK = [
    "............",
    "............",
    "..SSSSSSSS..",
    ".SEEEEEEEES.",
    "SESSSSSSSSES",
    "SEEEEEEEEEES",
    "SEEEEEEEEEES",
    "SEEEEEEEEEES",
    ".SEEEEEEEES.",
    "..SSSSSSSS..",
    "............",
    "............",
]

# ------------------------------------------------- 4. the per-league dict
LEAGUE_MARK = {"nfl": NFL_MARK, "nba": NBA_MARK, "nhl": NHL_MARK,
               "mlb": MLB_MARK}


# -------------------------------------------------------- 5. helpers

def on_accent(ac):
    """Text colour for anything sitting on a solid fill of `ac`.

    accent() now punches every team colour to full brightness, so roughly
    half the league lands light enough that white-on-accent is a smear.
    Kansas City's #FF1A3D is 0.30 and keeps white; Green Bay's #68FFA3 is
    0.85 and has to flip."""
    return BG if _lum(_rgb(ac)) >= P1_FLIP_LUM else INK

def mark_legend(ac):
    """One legend for the shield and all four league marks."""
    return {
        "B": ac,
        "D": _hex(_scale(_rgb(ac), 0.55)),
        "S": ac,
        "W": "#F0F0F0",
        "R": "#C8302A",
        "E": "#262626",
        "K": "#000000",
        "N": on_accent(ac),
    }

def draft_pick(p):
    """The number the shield stamps, or "" for no shield.

    The pick is the famous number -- PK1, PK10, PK32 -- so it is what goes
    on the badge. stamp_number() truncates to two characters, which would
    turn a 262nd overall pick into "26", so a 3-digit pick falls back to the
    round instead of lying."""
    if p["undrafted"]:
        return ""
    pk = p["pk"]
    if pk != "" and len(pk) <= 2:
        return pk
    if p["rd"] != "":
        return p["rd"]
    return ""

def name_block(c, last):
    """The surname: one fixed face, centred in the band. Returns nothing.

    THE CALL. The band is 104px and the obvious move is fit() -- take the
    biggest face that fits and let the name fill the width. That is what the
    page used to do, and it is exactly what made MAHOMES a wall and JUDGE
    half a panel of nothing.

    The backdrop now fills the panel, so "fill the band" is no longer load
    bearing: nothing is black any more whatever the name does. What is left
    to decide is what the page should LOOK like, and a fitted name makes
    every player a different page -- JUDGE at 16x20 is 84px and sets in a
    face 4px taller than MAHOMES at 10x16, which is 76px, so the SHORTER
    name renders BIGGER. Seen in rotation that reads as the renderer
    guessing, not as a decision.

    Fixed and centred makes it a card: the nameplate is in the same place,
    in the same face, at the same weight, on every player in every league,
    and the only thing that varies is how many letters are in it. The
    padding either side is the backdrop showing through -- the surface the
    man plays on, which is the point of having drawn it.

    10x16 is the face, not 16x20, for a second reason: a 20-row name plus
    the 12-row badge row plus the gaps is 35 rows on a 32-row panel. 16 + 12
    + gaps is 32 exactly. The badge row is the sprites, and the brief is
    more sprites.

    The ladder below it exists only so a monster cannot clip, never to make
    a short name big: 10x16 holds any surname up to 9 characters (98px).
    "WESTBROOK-IKHINE" is 175px at 10x16 and 111px at 6x8, so it lands on
    5x7 at 95px with nothing cut."""
    f, t = fit(c, last, ["10x16", "6x8", "5x7", "4x5"], P1_NAME_W)
    nw = c.text_width(t, f)
    nx = P1_BAND_X + (P1_NAME_W - nw) // 2
    ny = P1_NAME_Y + (P1_NAME_H - FONTH[f]) // 2
    ink(c, t, nx, ny, font = f, color = INK)

def badge_column(c, p, ac):
    """x 155..181: the accent cap, the team crest, the draft shield.

    This column is the same width for every player, so the card has one
    silhouette regardless of the data. It is also the first use of the 124
    crest PNGs anywhere on page 1 -- the crest says Kansas City better than
    the three characters "KC" ever did, and it is what makes a Chiefs page
    and a Yankees page different at twenty feet."""
    # A 1px accent rule across the top of the column, closing the card's
    # right end. frame() inks rows 0 only at x 2..4 and 187..189, so this
    # cannot collide with the pager.
    c.rect(P1_BADGE_X, 0, X1, 0, fill = ac)

    crest = p["logo"]
    wh = logo_box(crest)
    if crest != "" and wh[0] > 0:
        cx = P1_BADGE_X + (P1_BADGE_W - wh[0]) // 2
        cy = P1_CREST_Y + (P1_CREST_H - wh[1]) // 2
        c.image(LOGO_FILE[crest], cx, cy)
    else:
        # No crest for this team id: the league mark at scale 2 fills the
        # box rather than leaving the column half empty. The shield is
        # dropped in this branch because 24 + 10 does not fit rows 2..31
        # with a gap, and the draft then falls to the text tail below.
        art = LEAGUE_MARK.get(p["lg"], NFL_MARK)
        big = P1_MARK_WH * 2
        c.sprite(art, P1_BADGE_X + (P1_BADGE_W - big) // 2, P1_CREST_Y,
                 legend = mark_legend(ac), scale = 2)
        return False

    pick = draft_pick(p)
    if pick == "":
        return False
    c.sprite(stamp_number(SHIELD, SMALL_DIGITS, pick, P1_SHIELD_CX,
                          P1_SHIELD_TOP),
             P1_BADGE_X + (P1_BADGE_W - P1_SHIELD_W) // 2, P1_SHIELD_Y,
             legend = mark_legend(ac))
    return True

def position_chip(c, pos, ac):
    """The position in 6x8 on a filled accent chip. Returns its right edge.

    The chip's own fill is the moat, so this is the one string on the page
    that does NOT go through ink(): a black halo inside a solid colour reads
    as an outline typeface, not as separation."""
    if pos == "":
        return P1_BAND_X + P1_MARK_WH - 1
    tw = c.text_width(pos, "6x8")
    x1 = P1_CHIP_X + tw + 2 * P1_CHIP_PAD - 1
    c.rect(P1_CHIP_X, P1_CHIP_Y, x1, P1_CHIP_Y + P1_CHIP_H - 1, fill = ac)
    c.text(pos, P1_CHIP_X + P1_CHIP_PAD,
           P1_CHIP_Y + (P1_CHIP_H - FONTH["6x8"]) // 2,
           font = "6x8", color = on_accent(ac))
    return x1


# ----------------------------------------------------------- 6. page 1

# ------------------------------------------------------------------- page 1

def resume(c, ctx):
    """Identity, as a player card.

    Four columns: the kit in team colours with the number stamped on it; the
    surname on a nameplate; a badge row that says league, position and
    resume; and a badge column carrying the club's own crest over the draft
    pick. All of it on the league's playing surface.

    The words NFL, QB and RD1 PK10 are no longer on this panel. A football,
    a chip and a shield with a 10 in it are, which is the guidelines' whole
    argument about pixel art replacing repetitive text."""
    state, p = who(ctx)
    if p == None:
        return fail(c, state)
    c.fill(BG)
    ac = accent(p["color"], p["alt"])
    frame(c, ac, 1)
    backdrop(c, p["lg"], p["color"], p["alt"])

    # --- column 1: the kit. Unchanged, and still the hero of the page.
    kit = KIT[p["lg"]]
    c.sprite(stamp_number(kit["art"], kit["digits"], p["num"], kit["cx"],
                          kit["top"]),
             X0, kit["y"], legend = palette(p["color"], p["alt"]))

    # Two spines, both in STRUCT. Colour is identity on this page and the
    # dividers are not identity -- if the spines wore the accent too, the
    # page would be a single hue and the crest would stop being the thing
    # the eye lands on.
    c.rect(P1_SPINE_A, 2, P1_SPINE_A, 29, fill = STRUCT)
    c.rect(P1_SPINE_B, 2, P1_SPINE_B, 29, fill = STRUCT)

    # --- column 2, top: the nameplate, rows 2..17.
    name_block(c, p["last"])

    # --- column 3: crest and shield, rows 0..31.
    shielded = badge_column(c, p, ac)

    # --- column 2, bottom: the badge row, rows 19..30.
    c.sprite(LEAGUE_MARK.get(p["lg"], NFL_MARK), P1_BAND_X, P1_ROW_Y,
             legend = mark_legend(ac))
    chip_r = position_chip(c, p["pos"], ac)

    # Two 4x5 lines, right-aligned on the band. Worst case the chip is a
    # 3-character position -- 20px of text plus 6px of fill, ending at
    # x=87 -- which leaves 59px here. "10TH SZN" is 8 characters, so the
    # tail always fits and only the college is ever squeezed.
    tx = chip_r + 1 + P1_TEXT_GAP
    avail = P1_TEXT_R - tx + 1

    if p["college"] != "":
        ink(c, clip(c, p["college"], "4x5", avail), P1_TEXT_R, P1_LINE1_Y,
            font = "4x5", color = DIM, align = "right")

    # The shield carries the draft when it was drawn, so the words are not
    # repeated under it. When there is no shield -- undrafted, a 3-digit
    # pick with no round, or a club we have no crest for -- the draft comes
    # back as text, because dropping it entirely would be the panel quietly
    # losing a fact rather than choosing to.
    tail = []
    if not shielded:
        if p["undrafted"]:
            tail.append("UNDRAFTED")
        elif p["rd"] != "" and p["pk"] != "":
            tail.append("RD" + p["rd"] + " PK" + p["pk"])
    if p["exp"] != "":
        tail.append(p["exp"])
    if len(tail) > 0:
        ink(c, meta_fit(c, tail, avail), P1_TEXT_R, P1_LINE2_Y,
            font = "4x5", color = DIM, align = "right")

# ------------------------------------------------------------------- page 2
#
# Crest, number, skyline. Three things and a footer:
#
#   rows 0..19   crest | spine | the career total at 16x20
#   rows 23..31  stat glyph, what the number is, and one row of support stats
#   right        one bar per season on a baseline, the best year in white
#                with its value, the current year in the team's trim
#
# There is no eyebrow. The crest says whose page it is, the pager rail says
# which page, and the row that used to say "CAREER" went to the hero instead.

# ---- page 2 sprites. Same legend as the kit art (P shell, D shade, L
# highlight, S trim, W white, M light grey, G grey) plus T: a trim that is
# never white, for marks that sit on a white body. X is single-colour art.

# 4x6. The 16x20 face gives its comma a full 17px cell, which is where the
# hole in "38 ,648" came from and 11px the crest column needed.
P2_COMMA = [
    ".XXX",
    ".XXX",
    ".XXX",
    "..XX",
    ".XX.",
    "XX..",
]

# 7x5. Sits on the best season. White, not gold: gold is trophies only.
P2_CROWN = [
    "X..X..X",
    "XX.X.XX",
    "XXXXXXX",
    "X.X.X.X",
    "XXXXXXX",
]

# 11x7.
P2_FOOTBALL = [
    "...PPPPP...",
    ".PPLLPPPPP.",
    "PSPPWPWPPSP",
    "PSPWWWWWPSD",
    "PSPPWPWPPSD",
    ".PPPPPPPDD.",
    "...DDDDD...",
]

# 9x9.
P2_BASKETBALL = [
    "..PPDPP..",
    ".DPLDPPD.",
    "PPDPDPDPP",
    "PPDPDPDPP",
    "DDDDDDDDD",
    "PPDPDPDPP",
    "PPDPDPDPP",
    ".DPPDPPD.",
    "..PPDPP..",
]

# 9x9. White ball, stitches in T so they survive a white-trimmed club.
P2_BASEBALL = [
    "..WWWWW..",
    ".TWWWWWT.",
    "WWTWWWTWW",
    "WWWTWTWWW",
    "WWWTWTWWW",
    "WWWTWTWWW",
    "WWTWWWTWW",
    ".TWWWWWT.",
    "..WMMMM..",
]

# 10x9. Bat and ball: home runs.
P2_BAT = [
    ".......PP.",
    "......PPPL",
    ".....PPPP.",
    "....PPPP..",
    "...PPP....",
    "..PP...WW.",
    ".PP...WWWW",
    "SP....WWWM",
    "SS.....MM.",
]

# 11x9. Stick and puck. The puck is grey because a black one is not there.
P2_PUCK = [
    "........PP.",
    ".......PP..",
    "......PP...",
    ".....PP....",
    "....PP.....",
    "...PP......",
    "..PP...MMM.",
    "SSSP..MMMMM",
    "SSS...GGGGG",
]

# 11x7. Goaltender wins.
P2_NET = [
    "TTTTTTTTTTT",
    "TM.M.M.M.MT",
    "T.M.M.M.M.T",
    "TM.M.M.M.MT",
    "T.M.M.M.M.T",
    "TM.M.M.M.MT",
    "T.M.M.M.M.T",
]

# 9x9. Uprights with the ball going through: kicking points.
P2_GOALPOST = [
    "T...P...T",
    "T..PPP..T",
    "T...P...T",
    "T.......T",
    "TTTTTTTTT",
    "....T....",
    "....T....",
    "....T....",
    "...TTT...",
]

# 9x9. Tackles.
P2_SHIELD = [
    "PPPPPPPPP",
    "PLPPSPPPD",
    "PLPPSPPPD",
    "PSSSSSSSD",
    "PPPPSPPPD",
    ".PPPSPPD.",
    ".PPPSPPD.",
    "..PPSPD..",
    "...PPD...",
]

# hero label -> glyph. Anything unlisted (POINTS, GAMES) takes the league's
# own ball, so a new HERO entry can never leave the footer without a picture.
P2_GLYPH = {
    "PASS YDS": P2_FOOTBALL, "RUSH YDS": P2_FOOTBALL, "REC YDS": P2_FOOTBALL,
    "PUNT YDS": P2_FOOTBALL, "KICK PTS": P2_GOALPOST, "TACKLES": P2_SHIELD,
    "HOME RUNS": P2_BAT, "STRIKEOUTS": P2_BASEBALL, "WINS": P2_NET,
}
P2_LG_GLYPH = {"nfl": P2_FOOTBALL, "nba": P2_BASKETBALL, "mlb": P2_BASEBALL,
               "nhl": P2_PUCK}

# Crests whose art IS numerals. Beside a white 16x20 total they read as part
# of it -- the 76ers page said 7643,697 -- and no gap the page can afford
# fixes that, because the cause is two white numerals on one baseline, not
# the distance between them. These get a plate instead of a spine, which
# turns the crest into a tile. Checked against all 124 crests: this is the
# only one. Word crests (KNICKS, JETS, TOR) are letters and do not join.
P2_NUMERAL_CREST = {"nba_phi": True}

# ---- page 2 layout. Rows first, then columns.

P2_HERO_H = 20           # the hero band is rows 0..19, as on page 1
P2_HERO_FONT = "16x20"
P2_HERO_SMALL = ["10x16", "6x8"]   # a total that is not plain digits, or 100,000+
P2_COMMA_Y = 14          # comma inks rows 14..19, flush with the digits' feet
P2_COMMA_CELL = 6        # 1 clear + 4 comma + 1 clear
P2_COMMA_PAD = 1

P2_SPINE_OFF = 2         # crest, 2 clear, spine, 2 clear, hero
P2_HERO_OFF = 5
P2_PLATE_PAD = 1         # the numeral-crest plate: 1px all round the art
P2_BIG = 2               # scale of the stat glyph when it stands in for a crest

# The left block (hero, label, support stats) may not pass this column. A
# 26px crest and a five-digit total end exactly here, and it leaves the chart
# 49px: enough for 24 seasons at two pixels each.
P2_LBMAX = 129
P2_ZONE_GAP = 4          # 3 clear columns between the left block and the chart

P2_GLYPH_Y = 23          # footer glyph box is rows 23..31
P2_GLYPH_BOX = 9
P2_GLYPH_GAP = 3
P2_LABEL_FONTS = ["5x7", "4x5"]
P2_FOOT_Y = 27           # every 4x5 string in the bottom band: rows 27..31
P2_SUP_LEAD = 5          # label -> first support stat
P2_SUP_GAP = 6           # support stat -> support stat
P2_UNIT_GAP = 3          # "289" -> "TD"

P2_PEAK_Y = 0            # crown and peak value, rows 0..4; row 5 stays clear
P2_BAR_TOP = 6           # bars are rows 6..22
P2_BAR_BOT = 22
P2_RULE_Y = 24           # baseline, with row 23 clear above it
P2_TICK_Y = 25           # ticks hang off the baseline
P2_TICK_EVERY = 5        # one under every season divisible by five
P2_PITCH_MAX = 7         # a bar wider than this stops reading as a series
P2_PITCH_GAPPED = 3      # from here up bars get a 1px gap; below, they touch
P2_PEAK_MIN = 3          # "the best of two" is not a peak worth crowning
P2_CROWN_GAP = 2
P2_YEAR_GAP = 3          # least clear space between the two year labels

P2_ZEBRA = 0.7           # the alternate shade when bars touch
P2_LOUD = 200            # a trim this far from white is a colour, not white
P2_GOLD_NEAR = 120       # ...and this close to GOLD is a trophy, not a trim

def p2_halo(c, art, x, y, color):
    """A single-colour sprite with the same 1px BG moat ink() gives text.

    The comma and the crown belong to haloed numbers. Without their own moat
    a yard line runs up to the comma and stops dead at the digits either side
    of it, which is exactly the fraying the moat exists to prevent."""
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dx != 0 or dy != 0:
                c.sprite(art, x + dx, y + dy, color = BG)
    c.sprite(art, x, y, color = color)

def p2_colors(primary, secondary):
    """[legend, bar, zebra bar, current-season colour].

    The bars are the team's primary because they are the biggest block of
    colour on the page and should be the colour the club is known by. The
    current season takes the trim -- unless the trim is white, which is the
    peak's colour, or gold, which is the trophies' colour on the next page.
    Then it takes the pale tint of the primary instead."""
    pal = palette(primary, secondary)
    trim = _rgb(pal["S"])
    loud = _dist(trim, (255, 255, 255)) >= P2_LOUD
    gold = _dist(trim, _rgb(GOLD)) < P2_GOLD_NEAR
    pal["T"] = pal["S"] if loud else pal["P"]
    now = pal["S"] if (loud and not gold) else pal["L"]
    return [pal, pal["P"], _hex(_scale(_rgb(pal["P"]), P2_ZEBRA)), now]

def p2_hero_groups(hero):
    """["43", "697"] for "43,697"; [] when the total is not plain digits and
    commas, which sends it down the ordinary text path instead."""
    groups = str(hero).split(",")
    for g in groups:
        if g == "" or digits_only(g) != g:
            return []
    return groups

def p2_hero(c, hero, hx):
    """Draw the total with its left edge at hx; return its right edge."""
    groups = p2_hero_groups(hero)
    hw = 0
    for g in groups:
        hw += c.text_width(g, P2_HERO_FONT)
    hw += P2_COMMA_CELL * (len(groups) - 1)
    if len(groups) > 0 and hx + hw - 1 <= P2_LBMAX:
        x = hx
        for i in range(len(groups)):
            if i > 0:
                p2_halo(c, P2_COMMA, x + P2_COMMA_PAD, P2_COMMA_Y, INK)
                x += P2_COMMA_CELL
            ink(c, groups[i], x, 0, font = P2_HERO_FONT, color = INK)
            x += c.text_width(groups[i], P2_HERO_FONT)
        return hx + hw - 1
    # Bottom-aligned on the hero band, so whatever face it lands on the gap
    # to the footer is the same.
    f, t = fit(c, hero, P2_HERO_SMALL, P2_LBMAX - hx + 1)
    ink(c, t, hx, P2_HERO_H - FONTH[f], font = f, color = INK)
    return hx + c.text_width(t, f) - 1

def p2_foot_need(c, lx, label, lf, sup):
    """Right edge of the footer row for this label face and these stats."""
    r = lx + c.text_width(label, lf) - 1
    for i in range(len(sup)):
        r += P2_SUP_LEAD if i == 0 else P2_SUP_GAP
        r += c.text_width(sup[i][0], "4x5") + P2_UNIT_GAP
        r += c.text_width(sup[i][1], "4x5")
    return r

def p2_footer(c, lx, label, sup, ac):
    """Label then support stats on one row; return the row's right edge.

    One row, not two stacked. Two 4x5 lines under a 20-row hero need thirteen
    rows for a 2px gap and the panel has twelve, so stacking them left the
    top line one pixel under the total and competing with it. On one row the
    stats sit seven rows clear, and the second one drops when it does not
    fit -- the order in HERO already says which matters more."""
    lf = P2_LABEL_FONTS[0]
    keep = sup[:2]
    if p2_foot_need(c, lx, label, lf, keep) > P2_LBMAX:
        keep = keep[:1]
    if p2_foot_need(c, lx, label, lf, keep) > P2_LBMAX:
        lf = P2_LABEL_FONTS[1]
    if p2_foot_need(c, lx, label, lf, keep) > P2_LBMAX:
        keep = []
    label = clip(c, label, lf, P2_LBMAX - lx + 1)
    # Every face in the footer ends on row 31, the same row as the years.
    ink(c, label, lx, P2_FOOT_Y + FONTH["4x5"] - FONTH[lf], font = lf,
        color = ac)
    x = lx + c.text_width(label, lf)
    for i in range(len(keep)):
        x += P2_SUP_LEAD if i == 0 else P2_SUP_GAP
        ink(c, keep[i][0], x, P2_FOOT_Y, font = "4x5", color = INK)
        x += c.text_width(keep[i][0], "4x5") + P2_UNIT_GAP
        ink(c, keep[i][1], x, P2_FOOT_Y, font = "4x5", color = DIM)
        x += c.text_width(keep[i][1], "4x5")
    return x - 1

def p2_bucket(series, w):
    """At most `w` [year, value] rows.

    More seasons than pixels cannot happen to a real career, but a feed can
    hand back anything. Neighbouring seasons merge, keeping the best value
    and the later year, so the peak and the final year both survive."""
    n = len(series)
    if n <= w or w <= 0:
        return series
    k = (n + w - 1) // w
    out = []
    for i in range(0, n, k):
        best = series[i][1]
        last = series[i][0]
        for j in range(i, min(i + k, n)):
            if series[j][1] > best:
                best = series[j][1]
            last = series[j][0]
        out.append([last, best])
    return out

def p2_yy(year):
    return "'" + str(year)[-2:]

def p2_chart(c, series, zl, active, bar, bar2, now):
    """The skyline, in whatever is left between column zl and the safe edge."""
    w = X1 - zl + 1
    series = p2_bucket(series, w)
    n = len(series)
    pitch = min(P2_PITCH_MAX, w // n)
    gapped = pitch >= P2_PITCH_GAPPED
    # Gapped while there is room. Below three pixels a gap leaves 1px bars and
    # 1px holes -- a picket fence -- so the bars touch instead, and at two
    # pixels alternate shades keep the seasons countable.
    bw = pitch - 1 if gapped else pitch
    drawn = n * pitch - (1 if gapped else 0)
    cx0 = zl + (w - drawn) // 2
    bar_h = P2_BAR_BOT - P2_BAR_TOP + 1

    top = 0
    pk = -1
    for i in range(n):
        if series[i][1] > top:
            top = series[i][1]
            pk = i
    if n < P2_PEAK_MIN:
        pk = -1
    last = n - 1 if active else -1

    c.rect(cx0, P2_RULE_Y, cx0 + drawn - 1, P2_RULE_Y, fill = STRUCT)
    for i in range(n):
        v = series[i][1]
        # From zero, so a career year reads as twice a half year. A season
        # with nothing in it still gets one row: it happened.
        h = 1
        if top > 0 and v > 0:
            h = max(1, (v * bar_h * 2 + top) // (2 * top))
        x = cx0 + i * pitch
        col = bar
        if pitch == 2 and i % 2 != (n - 1) % 2:
            col = bar2
        if i == last:
            col = now
        if i == pk:
            col = INK
        c.rect(x, P2_BAR_BOT - h + 1, x + bw - 1, P2_BAR_BOT, fill = col)
        if i == last:
            # The current season stands on a foot. Colour alone would not
            # carry it for a club whose trim is close to its primary.
            c.rect(x, P2_TICK_Y, x + bw - 1, P2_TICK_Y, fill = now)
        elif series[i][0] % P2_TICK_EVERY == 0:
            c.rect(x + bw // 2, P2_TICK_Y, x + bw // 2, P2_TICK_Y, fill = DIM)

    if pk >= 0:
        # The white number is the height of the white bar: that is the scale.
        s = commas(top)
        sw = c.text_width(s, "4x5")
        cw = len(P2_CROWN[0])
        bcx = cx0 + pk * pitch + bw // 2
        kx = max(zl, min(TX1 - cw + 1, bcx - cw // 2))
        lroom = kx - P2_CROWN_GAP - zl
        rroom = TX1 - (kx + cw - 1) - P2_CROWN_GAP
        if sw <= max(lroom, rroom):
            p2_halo(c, P2_CROWN, kx, P2_PEAK_Y, INK)
            if rroom >= lroom:
                ink(c, s, kx + cw + P2_CROWN_GAP, P2_PEAK_Y, font = "4x5",
                    color = INK)
            else:
                ink(c, s, kx - P2_CROWN_GAP, P2_PEAK_Y, font = "4x5",
                    color = INK, align = "right")
        else:
            # No room for both, so the crown gives way and the number stays
            # whole. "5250" is not how anyone writes a passing season, and a
            # crown with no number tells you which year but not how good.
            tx = max(zl, min(TX1 - sw + 1, bcx - sw // 2))
            ink(c, s, tx, P2_PEAK_Y, font = "4x5", color = INK)

    ly = p2_yy(series[0][0])
    ry = p2_yy(series[n - 1][0])
    rcol = now if last >= 0 else DIM
    lw = c.text_width(ly, "4x5")
    rw = c.text_width(ry, "4x5")
    # align="right" takes the column after the last glyph pixel.
    redge = min(cx0 + drawn, TX1 + 1)
    if n == 1 or ly == ry:
        rx = max(zl + rw, min(TX1 + 1, cx0 + drawn // 2 + (rw + 1) // 2))
        ink(c, ry, rx, P2_FOOT_Y, font = "4x5", color = rcol, align = "right")
    elif lw + rw + P2_YEAR_GAP <= redge - cx0:
        ink(c, ly, cx0, P2_FOOT_Y, font = "4x5", color = DIM)
        ink(c, ry, redge, P2_FOOT_Y, font = "4x5", color = rcol,
            align = "right")
    else:
        # Too narrow to label both ends, so label the range once, centred,
        # as two strings so the current year still wears its colour.
        head = ly + "-"
        fw = c.text_width(head + ry, "4x5")
        rx = max(zl + fw, min(TX1 + 1, cx0 + drawn // 2 + (fw + 1) // 2))
        ink(c, ry, rx, P2_FOOT_Y, font = "4x5", color = rcol, align = "right")
        ink(c, head, rx - rw - 1, P2_FOOT_Y, font = "4x5", color = DIM,
            align = "right")

def p2_draw(c, p, cr, ac):
    """Everything on a live page 2. Split from career_page so the layout can
    be driven with a hand-made `p` and `cr` when checking edge cases."""
    pal, bar, bar2, now = p2_colors(p["color"], p["alt"])
    glyph = P2_GLYPH.get(cr["label"], P2_LG_GLYPH.get(p["lg"], P2_FOOTBALL))
    gw, gh = len(glyph[0]), len(glyph)

    # Left column: the crest, or the stat glyph at double size when the club
    # has no art. Never an empty column, and never the glyph twice.
    crest = p["logo"]
    cw, ch = logo_box(crest)[0], logo_box(crest)[1]
    lx = X0 + gw + P2_GLYPH_GAP
    if crest != "" and cw > 0 and P2_NUMERAL_CREST.get(crest):
        c.rect(X0, 0, X0 + cw + 2 * P2_PLATE_PAD - 1, P2_HERO_H, fill = STRUCT)
        c.image(LOGO_FILE[crest], X0 + P2_PLATE_PAD,
                P2_PLATE_PAD + (P2_HERO_H - P2_PLATE_PAD - ch) // 2)
    elif crest != "" and cw > 0:
        c.image(LOGO_FILE[crest], X0, (P2_HERO_H - ch) // 2)
        c.rect(X0 + cw + P2_SPINE_OFF, 0, X0 + cw + P2_SPINE_OFF,
               P2_HERO_H - 1, fill = STRUCT)
    else:
        cw = gw * P2_BIG
        c.sprite(glyph, X0, (P2_HERO_H - gh * P2_BIG) // 2, legend = pal,
                 scale = P2_BIG)
        c.rect(X0 + cw + P2_SPINE_OFF, 0, X0 + cw + P2_SPINE_OFF,
               P2_HERO_H - 1, fill = STRUCT)
        lx = TX0
    hero_r = p2_hero(c, cr["hero"], X0 + cw + P2_HERO_OFF)

    if lx != TX0:
        c.sprite(glyph, X0, P2_GLYPH_Y + (P2_GLYPH_BOX - gh) // 2,
                 legend = pal)
    foot_r = p2_footer(c, lx, cr["label"], cr["sup"], ac)

    # The right side is whatever the left block did not use. A three-digit
    # total hands the chart 90px; a five-digit one, 49.
    zl = max(hero_r, foot_r) + P2_ZONE_GAP
    series = cr["series"]
    if len(series) == 0:
        msg = clip(c, "NO SPLIT", "4x5", TX1 - zl + 1)
        ink(c, msg, zl, (P2_BAR_TOP + P2_BAR_BOT) // 2 - 2, font = "4x5",
            color = DIM)
        return
    p2_chart(c, series, zl, p["active"], bar, bar2, now)

def career_page(c, ctx):
    """The hero number, and the shape of the career that produced it."""
    state, p = who(ctx)
    if p == None:
        return fail(c, state)
    st = stats(p["lg"], p["id"])
    cr = career(p["lg"], st, p["pos"]) if st != None else None
    c.fill(BG)
    ac = accent(p["color"], p["alt"])
    frame(c, ac, 2)
    backdrop(c, p["lg"], p["color"], p["alt"])

    if cr == None:
        eyebrow(c, "CAREER", p["last"], ac)
        if st == None:
            # An outage is not the same answer as "this player has no stats",
            # and saying the second when the first is true is simply a lie on
            # the wall. Mahomes' page claimed ESPN had no totals for him the
            # moment the stats endpoint failed.
            c.text("NO CAREER STATS", c.width // 2, 13, font = "6x8",
                   color = "amber", align = "center")
            c.text("ESPN UNREACHABLE . RETRYING", c.width // 2, 25,
                   font = "4x5", color = DIM, align = "center")
        else:
            c.text("NO CAREER STATS YET", c.width // 2, 13, font = "6x8",
                   color = INK, align = "center")
            c.text("FIRST SEASON NOT ON THE BOARD", c.width // 2, 25,
                   font = "4x5", color = DIM, align = "center")
        return

    p2_draw(c, p, cr, ac)

# =====================================================================
# PAGE 3 -- HONORS. Splice-ready. Dependency order, top to bottom:
#   1. colour constants      (next to the house kit)
#   2. AWARD_LEGEND
#   3. ART_* sprite constants
#   4. shelf layout constants
#   5. AWARD_ART + award_art() + award_base_rank()  (after award_short())
#   6. honors()                                     (replaces the existing one)
#
# DESIGN. The old page drew one gold cup three times and let the captions
# carry every bit of the meaning. This version keeps the old page's shape --
# three bold trophies, a big count, a caption under each -- and replaces the
# one generic cup with a family of sixteen, so the silhouette says what was
# won before the caption is read rather than instead of it.
#
# The four league championship trophies are the only SILVER objects on the
# page. Everything else is gold. That one colour split means "he won the
# whole thing" reads before any shape is parsed.
#
# SIZING, because it is the whole argument of this revision. The band between
# the eyebrow and the captions is rows 7..24, which is 18 rows. The family is
# therefore drawn at 20x18 native and at scale 1. Scale 2 is arithmetically
# out: doubling even the shortest sprite in the family puts it at 28 wide and
# 18-32 tall, and anything over 18 rows collides with the caption. Drawing
# small art large was never the option -- drawing the art at the size the band
# actually affords was.
# =====================================================================


# ------------------------------------------------- 1. colour constants
# These belong beside INK / DIM / STRUCT / GOLD / BG in the house kit.

SILVER = "#C9D4E6"   # championship hardware -- not gold, metal
SHADE = "#8A6A1E"    # gold shade / underside
HILITE = "#FFE9A8"   # gold highlight (gems, medal centre)
STEEL = "#56607A"    # silver shade, dark fills (puck body, trophy mouths)


# -------------------------------------------------- 2. the one legend

# One legend for the whole family. "." is empty, as everywhere else.
AWARD_LEGEND = {
    "X": GOLD,
    "D": SHADE,
    "L": HILITE,
    "S": SILVER,
    "E": STEEL,
    "W": INK,
}


# ------------------------------------------------ 3. the sprite family
#
# Every sprite is 20 px wide and 12-18 px tall, drawn at scale 1 and
# bottom-aligned on SHELF_BASE. A level baseline is what makes a row of
# mismatched silhouettes read as one shelf instead of a scatter.
#
# NAMING, and this is load-bearing rather than cosmetic: every sprite is
# prefixed ART_. "LOMBARDI" is a value in AWARD_SHORT (the *college* Lombardi
# Award, an offensive-lineman honour) and ART_LOMBARDI is the NFL championship
# trophy. They mean different things and must map to different art, so the
# prefix makes the collision unwriteable rather than merely commented. Same
# reason ART_DIAMOND is prefixed: diamond() is already the MLB backdrop.

# -- championships: silver, and the only silver on the page ------------

# Pointed ball, white lace, pillar, slab. 20x17.
ART_LOMBARDI = [
    ".......SSSSSS.......",
    ".....SSSSSSSSSS.....",
    "...SSSSSSWWSSSSSS...",
    "..SSSSSSSWWSSSSSSS..",
    "...SSSSSSWWSSSSSS...",
    ".....SSSSSSSSSS.....",
    ".......SSSSSS.......",
    "........SSSS........",
    "........SSSS........",
    "........SSSS........",
    ".......SSSSSS.......",
    "......SSSSSSSS......",
    ".....SSSSSSSSSS.....",
    "....SSSSSSSSSSSS....",
    "...SSSSSSSSSSSSSS...",
    "...SSSSSSSSSSSSSS...",
    "...EEEEEEEEEEEEEE...",
]

# Seamed ball on a narrow stand. Gold, because the Larry O'Brien is. 20x17.
ART_TROPHY_NBA = [
    "......XXXXXXXX......",
    "....XXXXDXXDXXXX....",
    "...XXXXXDXXDXXXXX...",
    "..XXXXXXDXXDXXXXXX..",
    "..XXDDDDDDDDDDDDXX..",
    "..XXXXXXDXXDXXXXXX..",
    "...XXXXXDXXDXXXXX...",
    "....XXXXDXXDXXXX....",
    "......XXXXXXXX......",
    ".........XX.........",
    ".........XX.........",
    "........XXXX........",
    ".......XXXXXX.......",
    "......XXXXXXXX......",
    ".....XXXXXXXXXX.....",
    "...XXXXXXXXXXXXXX...",
    "...DDDDDDDDDDDDDD...",
]

# Bowl over a tiered barrel. The one trophy in sport whose silhouette
# everybody already knows, so it is allowed to be the widest thing on the
# shelf. 20x18.
ART_STANLEY = [
    "...SSSSSSSSSSSSSS...",
    "...SEEEEEEEEEEEES...",
    "...SSSSSSSSSSSSSS...",
    "....SSSSSSSSSSSS....",
    "....SSSSSSSSSSSS....",
    ".....SSSSSSSSSS.....",
    "......SSSSSSSS......",
    "......SSSSSSSS......",
    ".......SSSSSS.......",
    "......SSSSSSSS......",
    ".....SSSSSSSSSS.....",
    "....SSSSSSSSSSSS....",
    "..SSSSSSSSSSSSSSSS..",
    "..SEEEEEEEEEEEEEES..",
    "..SSSSSSSSSSSSSSSS..",
    "SSSSSSSSSSSSSSSSSSSS",
    "SEEEEEEEEEEEEEEEEEES",
    "SSSSSSSSSSSSSSSSSSSS",
]

# Pennant poles standing around a HOLLOW ring, on a stem and a two-tier
# pedestal. The void is the whole point: the first version of this sprite was
# a solid splay on a stem, i.e. a second ART_CROWN, and a page arguing that
# the silhouette is the label cannot give MVP and the World Series the same
# silhouette. 20x18.
ART_COMMISH = [
    ".S...S...S...S...S..",
    ".SS..SS..SS..SS..SS.",
    "SSSSSSSSSSSSSSSSSSSS",
    "SSEEEEEEEEEEEEEEEESS",
    "SEEEEEEEEEEEEEEEEEES",
    "SSEEEEEEEEEEEEEEEESS",
    ".SSSSSSSSSSSSSSSSSS.",
    "....SSSSSSSSSSSS....",
    ".......SSSSSS.......",
    "........SSSS........",
    "........SSSS........",
    "........SSSS........",
    ".......SSSSSS.......",
    "......SSSSSSSS......",
    "....SSSSSSSSSSSS....",
    "..SSSSSSSSSSSSSSSS..",
    "..SEEEEEEEEEEEEEES..",
    "..SSSSSSSSSSSSSSSS..",
]

# -- individual honours: gold -------------------------------------------

# Crown over a star. The only crown in the family, so "most valuable" can
# never collide with "all-league". 20x18.
ART_CROWN = [
    "..X......X......X...",
    "..X..X...X...X..X...",
    "..XXXXXXXXXXXXXXXX..",
    "..XXXXXXXXXXXXXXXX..",
    "....................",
    ".........XX.........",
    "........XXXX........",
    "........XXXX........",
    "XXXXXXXXXXXXXXXXXXXX",
    "XXXXXXXXXXXXXXXXXXXX",
    ".XXXXXXXXXXXXXXXXXX.",
    "..XXXXXXXXXXXXXXXX..",
    "...XXXXXXXXXXXXXX...",
    "..XXXXXXXXXXXXXXXX..",
    "..XXXXXXX..XXXXXXX..",
    ".XXXXXX......XXXXXX.",
    ".XXXX..........XXXX.",
    "XXX..............XXX",
]

# A bare star: FIRST all-league team, and the unranked default.
#
# The rank is in the art, not only in the caption. Crosby's shelf read
# ALL-STAR / ALL-STAR 1 and Curry's read ALL-NBA 2 / ALL-NBA 1 -- two
# identical stars side by side in both, which is the one thing this whole
# family exists to prevent. The three variants below share one silhouette, so
# they obviously name the same kind of honour, and differ only in mass:
#
#   1st  solid bright gold          -- maximum ink
#   2nd  gold rim, SHADE interior   -- filled, but visibly dimmer
#   3rd  gold rim, empty interior   -- a true outline
#
# Mass and brightness are the two things that survive 25 feet, and the ladder
# is monotonic in both, so "more ink = higher team" needs no explaining.
# 20x16.
ART_STAR = [
    ".........XX.........",
    ".........XX.........",
    "........XXXX........",
    "........XXXX........",
    "XXXXXXXXXXXXXXXXXXXX",
    "XXXXXXXXXXXXXXXXXXXX",
    ".XXXXXXXXXXXXXXXXXX.",
    "..XXXXXXXXXXXXXXXX..",
    "...XXXXXXXXXXXXXX...",
    "...XXXXXXXXXXXXXX...",
    "..XXXXXXXXXXXXXXXX..",
    "..XXXXXXX..XXXXXXX..",
    ".XXXXXX......XXXXXX.",
    ".XXXXX........XXXXX.",
    "XXXX............XXXX",
    "XX................XX",
]

# SECOND all-league team. Same silhouette, SHADE interior. The top point, the
# arm edge and the legs stay solid because they are 1-3px wide and a rim
# inside them would be nothing at all. 20x16.
ART_STAR_2 = [
    ".........XX.........",
    ".........XX.........",
    "........XXXX........",
    "........XXXX........",
    "XXXXXXXXXXXXXXXXXXXX",
    "XXXDDDDDDDDDDDDDDXXX",
    ".XXDDDDDDDDDDDDDDXX.",
    "..XXDDDDDDDDDDDDXX..",
    "...XXDDDDDDDDDDXX...",
    "...XXDDDDDDDDDDXX...",
    "..XXDDDDDDDDDDDDXX..",
    "..XXXXXDD..DDXXXXX..",
    ".XXXXXX......XXXXXX.",
    ".XXXXX........XXXXX.",
    "XXXX............XXXX",
    "XX................XX",
]

# THIRD all-league team. ART_STAR_2 with the interior removed rather than
# dimmed -- pixel for pixel the same outline, so the three read as one ladder
# and not as three unrelated marks. 20x16.
ART_STAR_3 = [
    ".........XX.........",
    ".........XX.........",
    "........XXXX........",
    "........XXXX........",
    "XXXXXXXXXXXXXXXXXXXX",
    "XXX..............XXX",
    ".XX..............XX.",
    "..XX............XX..",
    "...XX..........XX...",
    "...XX..........XX...",
    "..XX............XX..",
    "..XXXXX......XXXXX..",
    ".XXXXXX......XXXXXX.",
    ".XXXXX........XXXXX.",
    "XXXX............XXXX",
    "XX................XX",
]

# Gold face, silver rim, pointed heater, chevron notch. The only
# flat-top/pointed-bottom form on the shelf. 20x17.
ART_SHIELD = [
    ".SSSSSSSSSSSSSSSSSS.",
    ".SXXXXXXXXXXXXXXXXS.",
    ".SXXXXXXXXXXXXXXXXS.",
    ".SXXXXXDDDDDDXXXXXS.",
    ".SXXXXXXDDDDXXXXXXS.",
    ".SXXXXXXXDDXXXXXXXS.",
    ".SXXXXXXXXXXXXXXXXS.",
    ".SXXXXXXXXXXXXXXXXS.",
    "..SXXXXXXXXXXXXXXS..",
    "..SXXXXXXXXXXXXXXS..",
    "...SXXXXXXXXXXXXS...",
    "....SXXXXXXXXXXS....",
    ".....SXXXXXXXXS.....",
    "......SXXXXXXS......",
    ".......SXXXXS.......",
    "........SXXS........",
    ".........SS.........",
]

# Small star launching off a big open chevron: arrived, first year. It is the
# inverse stack of ART_CROWN, and what keeps the two apart is fill -- the
# crown's lower element is a solid star spanning the full width, this one's is
# a hollow V. 20x18.
ART_ROOKIE = [
    ".........XX.........",
    "........XXXX........",
    "..XXXXXXXXXXXXXXXX..",
    "...XXXXXXXXXXXXXX...",
    "...XXXXXX..XXXXXX...",
    "..XXXX........XXXX..",
    "....................",
    "....................",
    ".........XX.........",
    "........XXXX........",
    ".......XXXXXX.......",
    "......XXXXXXXX......",
    ".....XXXX..XXXX.....",
    "....XXXX....XXXX....",
    "...XXXX......XXXX...",
    "..XXXX........XXXX..",
    ".XXXX..........XXXX.",
    "XXXX............XXXX",
]

# A star inside a ring: the game, not the season-long team.
#
# The first attempt painted the star in the same gold as the ring, so the only
# thing separating core from band was a black gap -- which forced the band to
# 4-6px and squeezed the star into an 8x6 hole. Nothing five-pointed survives
# 8x6, and it read as an upward chevron. Painting the star in the highlight
# tone gives it its own value, so it can touch the band without dissolving
# into it; the band drops to 3-4px and the interior opens to 12x8, which is
# enough for arms, a point and two splayed legs. The top point is allowed to
# break the ring's inner edge -- that one row is the difference between a
# stub and the top of a star. 20x16.
ART_BADGE = [
    ".......XXXXXX.......",
    "....XXXXXXXXXXXX....",
    "..XXXXXXXXXXXXXXXX..",
    ".XXXXXXX.LL.XXXXXXX.",
    ".XXXXX...LL...XXXXX.",
    "XXXXX...LLLL...XXXXX",
    "XXXXLLLLLLLLLLLLXXXX",
    "XXXX.LLLLLLLLLL.XXXX",
    "XXXX..LLLLLLLL..XXXX",
    "XXXX.LLL....LLL.XXXX",
    "XXXXXLL......LLXXXXX",
    ".XXXXX........XXXXX.",
    ".XXXXXXX....XXXXXXX.",
    "..XXXXXXXXXXXXXXXX..",
    "....XXDDDDDDDDXX....",
    ".......XXXXXX.......",
]

# Gem over a band. Reserved for the literal "champion" honours so a ring never
# competes with the trophy that was lifted for it. 20x18.
ART_RING = [
    "........XXXX........",
    ".......XXDDXX.......",
    "......XXDLLDXX......",
    ".....XXDLLLLDXX.....",
    "......XXDLLDXX......",
    ".......XXDDXX.......",
    "........XXXX........",
    ".......XX..XX.......",
    "......XX....XX......",
    ".....XX......XX.....",
    "....XX........XX....",
    "...XX..........XX...",
    "...XX..........XX...",
    "...XX..........XX...",
    "....XX........XX....",
    ".....XXX....XXX.....",
    "......XXXXXXXX......",
    "........XXXX........",
]

# -- production marks ----------------------------------------------------

# A bat, third attempt, and the first one that is a bat.
#
# v1 was a 3px shaft with a white ball at the end and read as a lollipop. v2
# tapered continuously from barrel to knob, and a continuous taper at this
# size is a CURVE -- it read as a banana. A real bat is almost all straight
# line: a long barrel of constant width, one short taper, a straight handle,
# a knob. So every edge here is straight, the taper happens in four rows
# (7..10) and nowhere else, and the barrel and handle are each dead parallel.
#
# It stays diagonal rather than going vertical because a vertical club with a
# knob reads as a chess pawn or a bowling pin; the diagonal is also what keeps
# it the only diagonal object on the shelf. 20x18.
ART_BAT = [
    ".............XXXXX..",
    "...........XXXXXXX..",
    "...........XXXXXXX..",
    "..........XXXXXXX...",
    ".........XXXXXXX....",
    ".........XXXXXXX....",
    "........XXXXXXX.....",
    "........XXXXXX......",
    "........XXXXX.......",
    ".......XXXXX........",
    ".......XXXX.........",
    ".......XXX..........",
    "......XXX...........",
    "......XXX...........",
    ".....XXX............",
    "....XXX.............",
    "...XXXXX............",
    "..XXXXX.............",
]

# The disc alone, seen slightly from above: silver rim, light top face, dark
# body. Nothing else in the family is squat, which is exactly why it works.
# Bottom-aligned it seats low in the cell -- a puck lies on the ice, and the
# low seat is a second read cue. 20x12.
ART_PUCK = [
    ".....SSSSSSSSSS.....",
    "..SSSSSSSSSSSSSSSS..",
    ".SSSSSSSSSSSSSSSSSS.",
    "SSWWWWWWWWWWWWWWWWSS",
    "SSWWWWWWWWWWWWWWWWSS",
    "SSEEEEEEEEEEEEEEEESS",
    "SEEEEEEEEEEEEEEEEEES",
    "SEEEEEEEEEEEEEEEEEES",
    "SSEEEEEEEEEEEEEEEESS",
    ".SSEEEEEEEEEEEEEESS.",
    "..SSSSSSSSSSSSSSSS..",
    ".....SSSSSSSSSS.....",
]

# Rim, four strands, and the cone of the net. 20x16.
ART_NET = [
    ".XXXXXXXXXXXXXXXXXX.",
    ".XXXXXXXXXXXXXXXXXX.",
    ".XX..............XX.",
    "...XX..XX..XX..XX...",
    "...XX..XX..XX..XX...",
    "....XX.XX..XX.XX....",
    "....XX.XX..XX.XX....",
    ".....XXXX..XXXX.....",
    ".....XXXX..XXXX.....",
    "......XXX..XXX......",
    "......XXXXXXXX......",
    ".......XXXXXX.......",
    ".......XXXXXX.......",
    "........XXXX........",
    "........XXXX........",
    ".........XX.........",
]

# The plain ball: offence, no crown, no champion. 20x12.
ART_FOOTBALL = [
    ".......XXXXXX.......",
    ".....XXXXXXXXXX.....",
    "...XXXXXXWWXXXXXX...",
    "..XXXXXXXWWXXXXXXX..",
    ".XXXXXXXXWWXXXXXXXX.",
    "XXXXXWWWWWWWWWWXXXXX",
    "XXXXXWWWWWWWWWWXXXXX",
    ".XXXXXXXXWWXXXXXXXX.",
    "..XXXXXXXWWXXXXXXX..",
    "...XXXXXXWWXXXXXX...",
    ".....XXXXXXXXXX.....",
    ".......XXXXXX.......",
]

# The infield from above: an open rhombus with a thickened base at each
# corner. This is Gold Glove, and it is NOT a mitt -- a glove's identity is
# web, laces, thumb and four fingers, which is five separated forms, and every
# version of it collapsed into a pumpkin. The only rhombus in the family.
# 20x18.
ART_DIAMOND = [
    ".........XX.........",
    "........XXXX........",
    ".......XX..XX.......",
    "......XX....XX......",
    ".....XX......XX.....",
    "....XX........XX....",
    "...XX..........XX...",
    "..XX............XX..",
    ".XXX............XXX.",
    ".XXX............XXX.",
    "..XX............XX..",
    "...XX..........XX...",
    "....XX........XX....",
    ".....XX......XX.....",
    "......XX....XX......",
    ".......XX..XX.......",
    "........XXXX........",
    ".........XX.........",
]

# The default, and therefore the sprite that appears more often than any
# other, so it has to be the most legible thing on the shelf rather than the
# least. It replaces a laurel wreath whose two fronds never separated and
# whose centre void read as a necklace -- and which sat right on top of
# ART_RING and ART_BADGE in silhouette. V-shaped ribbon tails, a pinched knot,
# a solid disc with a bright centre. 20x18.
ART_MEDAL = [
    "XXXX............XXXX",
    "XXXX............XXXX",
    ".XXXX..........XXXX.",
    ".XXXX..........XXXX.",
    "..XXXX........XXXX..",
    "..XXXX........XXXX..",
    "...XXXX......XXXX...",
    "....XXXXX..XXXXX....",
    ".....XXXXXXXXXX.....",
    "......XXXXXXXX......",
    ".....XXXXXXXXXX.....",
    "....XXXXXXXXXXXX....",
    "...XXXXXXDDXXXXXX...",
    "...XXXXXDLLDXXXXX...",
    "...XXXXXDLLDXXXXX...",
    "...XXXXXXDDXXXXXX...",
    "....XXXXXXXXXXXX....",
    ".....XXXXXXXXXX.....",
]


# ---------------------------------------------- 4. shelf layout constants

SHELF_MAX = 3        # trophies on the shelf; see honors() for why 3, not 5
SHELF_PITCH = 48     # cell pitch: 42 of content plus a 6px gutter
SLOT_W = 42          # 20 sprite + 2 gap + 20 for a two-digit 10x16 count
SHELF_BASE = 24      # every sprite's bottom row. One baseline, no scatter.
ART_W = 20           # every sprite in the family is this wide

CNT_X = 22           # count numeral, offset from the cell's left edge
CNT_Y = 8            # 10x16 centred in the sprite band (rows 8..23)
CNT_FONT = "10x16"
CAP_FONT = "4x5"
CAP_GAP = 3          # between a caption and its year
CAP_SLACK = 2        # clear pixels between one caption and the next. The
                     # slot is 42 wide inside a 48 pitch, so a caption may
                     # borrow 4 of the 6 spare columns before it crowds its
                     # neighbour.

EYE_Y = 1            # eyebrow baseline. Not 0: ink()'s halo reaches 1px above
                     # the glyph box, and at y=0 that lands on row -1.
CAP_Y = 26           # caption baseline. 4x5 occupies 26..30, halo 25..31 --
                     # one row inside the panel at the bottom.
CREST_TOP = 6        # crest band, rows 6..31
CREST_ROWS = 26
CREST_GAP = 3        # clear space left of the crest


# ------------------------------------------------------- 5. the mapping
#
# Keyed on award_short() output -- what awards() actually hands back -- with
# any " 1" / " 2" / " 3" rank suffix stripped first.

AWARD_ART = {
    # -- championships: the only silver objects on the page --------------
    "SB MVP": ART_LOMBARDI,
    "FINALS MVP": ART_TROPHY_NBA,
    "SMYTHE": ART_STANLEY,          # Conn Smythe == the Cup run
    "NLCS MVP": ART_COMMISH,
    "ALCS MVP": ART_COMMISH,

    # -- most valuable ----------------------------------------------------
    "NFL MVP": ART_CROWN,
    "MVP": ART_CROWN,
    "HART": ART_CROWN,
    "HEISMAN": ART_CROWN,
    "MAXWELL": ART_CROWN,
    # The Ted Lindsay is the players' MVP vote, so it belongs with the other
    # most-valuable marks. It used to be ART_PUCK, which put it beside the
    # Art Ross -- a near-lock to share a shelf, and the two drew as two
    # identical discs on McDavid's.
    "LINDSAY": ART_CROWN,

    # -- all-league team. award_art() swaps in the 2nd/3rd-team variant --
    "ALL-NBA": ART_STAR,
    "ALL-MLB": ART_STAR,
    "ALL-NHL": ART_STAR,
    "ALL-PRO": ART_STAR,
    "ALL-STAR": ART_STAR,

    # -- the game, not the season -----------------------------------------
    "PRO BOWL": ART_BADGE,
    "ASG MVP": ART_BADGE,

    # -- defence ------------------------------------------------------------
    "DPOY": ART_SHIELD,
    "ALL-DEF": ART_SHIELD,
    # ESPN's real string is "All-Defensive 1st Team" -- the ordinal sits
    # INSIDE the name, so it never matched AWARD_SHORT's "ALL-DEFENSIVE TEAM"
    # key, fell through to award_short()'s longest-word rule as ALL-DEFEN, and
    # was caught by the "starts with ALL-" catch-all as a star. LeBron's shelf
    # was star / star / star. Both spellings are mapped now.
    "ALL-DEFEN": ART_SHIELD,
    "NORRIS": ART_SHIELD,
    "SELKE": ART_SHIELD,
    "VEZINA": ART_SHIELD,
    "JENNINGS": ART_SHIELD,
    "THORPE": ART_SHIELD,
    "BEDNARIK": ART_SHIELD,
    "NAGURSKI": ART_SHIELD,
    "OUTLAND": ART_SHIELD,

    # -- rookies. Rookie beats offence/defence: it happens once ------------
    "OROY": ART_ROOKIE,
    "DROY": ART_ROOKIE,
    "ALL-ROOK": ART_ROOKIE,
    "CALDER": ART_ROOKIE,

    # -- scoring / production ------------------------------------------------
    "ART ROSS": ART_PUCK,
    "RICHARD": ART_PUCK,
    "SLUGGER": ART_BAT,
    "AARON": ART_BAT,
    "BURLSWTH": ART_BAT,
    "SCORING": ART_NET,
    "REBOUND": ART_NET,
    "ASSIST": ART_NET,
    "BLOCKS": ART_NET,
    "STEALS": ART_NET,

    # -- offence (NFL) --------------------------------------------------------
    "OPOY": ART_FOOTBALL,
    "WALKER": ART_FOOTBALL,
    "UNITAS": ART_FOOTBALL,
    "BILETNKF": ART_FOOTBALL,
    "HORNUNG": ART_FOOTBALL,
    "RIMINGTN": ART_FOOTBALL,
    "OBRIEN": ART_FOOTBALL,         # Davey O'Brien, not the Larry O'Brien
    "LOMBARDI": ART_FOOTBALL,       # the COLLEGE Lombardi Award, a lineman
                                    # honour -- not ART_LOMBARDI, which is the
                                    # Super Bowl. The ART_ prefix is what makes
                                    # this line impossible to write wrongly.

    # -- fielding ---------------------------------------------------------------
    "GOLD GLV": ART_DIAMOND,

    # -- character / comeback: a medal, not a trophy -----------------------------
    "CLEMENTE": ART_MEDAL,
    "PAYTON": ART_MEDAL,
    "LADY BYNG": ART_MEDAL,
    "COMEBACK": ART_MEDAL,
    "CLUTCH": ART_MEDAL,
    "6TH MAN": ART_MEDAL,
    "MIP": ART_MEDAL,
}

RANK_DIGITS = {"1": 1, "2": 2, "3": 3}

# Which star a ranked all-league honour gets. 1 and anything unlisted fall
# through to the solid ART_STAR.
STAR_RANK = {2: ART_STAR_2, 3: ART_STAR_3}

# The one all-league string that is a GAME rather than a team. "First
# All-Star Team" is a postseason honour and arrives ranked; a plain
# "NHL All-Star" is a selection to the game, exactly what a Pro Bowl is, and
# it is why Crosby's shelf drew two identical stars in adjacent slots.
ALLSTAR_GAME = "ALL-STAR"

def award_base_rank(short):
    """"ALL-NBA 1" -> ["ALL-NBA", 1]. Unranked awards come back rank 0.

    award_short() carries the team rank through as a trailing digit so that
    All-NBA 1st and 2nd Team do not reduce to the same string. The caption
    prints that digit, and now so does the art: the rank is passed to
    award_art() rather than thrown away once the name has been stripped."""
    s = str(short)
    if len(s) > 2 and s[len(s) - 2] == " ":
        d = RANK_DIGITS.get(s[len(s) - 1], 0)
        if d > 0:
            return [s[0:len(s) - 2], d]
    return [s, 0]

def award_art(base, rank):
    """Sprite for a rank-stripped short award name. Default ART_MEDAL."""
    if base == ALLSTAR_GAME and rank == 0:
        return ART_BADGE
    art = AWARD_ART.get(base)
    if art == None:
        # Two cheap catch-alls before giving up, so a string ESPN adds next
        # season lands somewhere meaningful instead of piling onto the
        # default. The ALL- one routes into the star ladder below rather than
        # returning, so an unmapped "ALL-ACC 2" still gets its 2nd-team art.
        if base.find("CHAMP") >= 0 or base.find("TITLE") >= 0:
            return ART_RING
        if base.find("ALL-") == 0:
            art = ART_STAR
        else:
            return ART_MEDAL
    # The rank ladder applies to the star and to nothing else: a 2nd-team
    # honour is a lesser version of the same thing, which is not true of any
    # other mark in the family.
    if art == ART_STAR:
        return STAR_RANK.get(rank, ART_STAR)
    return art


# -------------------------------------------------------- 6. the page

def honors(c, ctx):
    """The trophy case -- or, for the many players ESPN lists no awards for,
    the career path. An empty cabinet is not an error, so it is not drawn as
    one: the page relabels itself and shows where he has played instead."""
    state, p = who(ctx)
    if p == None:
        return fail(c, state)
    b = bio(p["lg"], p["id"])
    c.fill(BG)
    ac = accent(p["color"], p["alt"])
    frame(c, ac, 3)
    backdrop(c, p["lg"], p["color"], p["alt"])

    if b == None:
        ink(c, "HONORS", TX0, EYE_Y, font = "4x5", color = DIM)
        ink(c, clip(c, p["last"], "4x5", 110), TX1, EYE_Y, font = "4x5",
            color = ac, align = "right")
        ink(c, "NO BIO DATA", c.width // 2, 14, font = "6x8", color = "amber",
            align = "center")
        ink(c, "RETRYING ON NEXT REFRESH", c.width // 2, 24, font = "4x5",
            color = DIM, align = "center")
        return

    aw = awards(p["lg"], b)
    th = teams(p["lg"], b)

    if len(aw) > 0:
        # The crest says which team, so the eyebrow does not have to carry the
        # player's name as well -- the picture is the label.
        crest = p["logo"]
        cw, ch = logo_box(crest)[0], logo_box(crest)[1]
        right = X1
        if crest != "":
            # Centred on rows 6..31, not 7..31. A 26px crest at y=7 inks row
            # 32 and the renderer drops that row silently.
            c.image(LOGO_FILE[crest], X1 - cw + 1,
                    CREST_TOP + (CREST_ROWS - ch) // 2)
            right = X1 - cw - CREST_GAP

        ink(c, "HONORS", TX0, EYE_Y, font = "4x5", color = DIM)
        if len(aw) > SHELF_MAX:
            # Right-aligned on `right`, not on TX1: at TX1 it printed on top
            # of the team crest (Derrick Henry's "+2" sat in the Ravens'
            # beak). It lives in the eyebrow row because the shelf now spends
            # its whole width on three trophies.
            ink(c, "+" + str(len(aw) - SHELF_MAX), right, EYE_Y, font = "4x5",
                color = DIM, align = "right")
        elif crest == "":
            ink(c, clip(c, p["last"], "4x5", 110), TX1, EYE_Y, font = "4x5",
                color = ac, align = "right")

        # THREE slots, each 42px of content on a 48px pitch.
        #
        # Five 20px-narrower sprites were tried and the shelf came out thin --
        # small marks adrift in a wide black band, with less presence than the
        # single repeated cup they replaced. Presence is not negotiable on a
        # panel read from 25 feet, and it is bought with width. Three slots
        # buy 42px each, which is exactly enough for a 20px sprite, a 10x16
        # count and a 4x5 caption underneath -- the old page's weight, with
        # sixteen different silhouettes instead of one.
        #
        # The count is a numeral again, for every count. A column of 2x2 pips
        # read as a dotted line rather than a quantity, and because it only
        # held counts up to five, a shelf could show two numerals beside two
        # pip columns -- one row, two counting systems. A digit is instantly
        # legible and never ambiguous.
        show = aw[0:SHELF_MAX]
        total = (len(show) - 1) * SHELF_PITCH + SLOT_W
        sx = X0 + (right - X0 - total) // 2
        if sx < X0:
            sx = X0
        for i in range(len(show)):
            a = show[i]
            x = sx + i * SHELF_PITCH
            br = award_base_rank(a["name"])
            art = award_art(br[0], br[1])
            # One baseline for every sprite in the family, no exceptions.
            c.sprite(art, x, SHELF_BASE + 1 - len(art), legend = AWARD_LEGEND)
            ink(c, str(a["count"]), x + CNT_X, CNT_Y, font = CNT_FONT,
                color = INK)
            # Name in the team colour, most recent year in grey beside it, so
            # "SB MVP '23" cannot be misread as a single award named 23.
            # Clip the NAME, never the rank. "ALL-STAR 2" is 45px against a
            # 44px budget and "ALL-DEFEN 2" is 51, so a plain clip() ate the
            # trailing digit -- and did it to the 2nd team while the 1st team
            # survived, because the "1" glyph happens to be a pixel narrower
            # than the "2". The rank is the whole reason the star has three
            # variants; it is the last thing that may be dropped, not the
            # first. So the base gets clipped and the rank is re-attached.
            capw = SHELF_PITCH - CAP_SLACK
            nm = a["name"]
            if br[1] > 0:
                tail = " " + str(br[1])
                nm = clip(c, br[0], CAP_FONT,
                          capw - c.text_width(tail, CAP_FONT)) + tail
            else:
                nm = clip(c, nm, CAP_FONT, capw)
            ink(c, nm, x, CAP_Y, font = CAP_FONT, color = ac)
            yw = c.text_width(nm, CAP_FONT) + CAP_GAP
            if a["last"] != "":
                if yw + c.text_width(a["last"], CAP_FONT) <= capw:
                    ink(c, a["last"], x + yw, CAP_Y, font = CAP_FONT,
                        color = DIM)
        return

    # No awards: the path. Always present -- every player has at least one team.
    ink(c, "CAREER PATH", TX0, EYE_Y, font = "4x5", color = DIM)
    ink(c, clip(c, p["last"], "4x5", 110), TX1, EYE_Y, font = "4x5",
        color = ac, align = "right")
    if len(th) == 0:
        # ESPN returns an empty teamHistory for plenty of players whose
        # profile names a club perfectly well, so the page used to say "NO
        # TEAM HISTORY" directly contradicting page 1. Fall back to the club
        # the profile gives, and only say nothing when there is nothing.
        if p["logo"] != "" or p["team"] != "":
            th = [{"name": p["team"], "span": "NOW", "now": True,
                   "logo": p["logo"]}]
        else:
            ink(c, "NO TEAM HISTORY", c.width // 2, 12, font = "6x8",
                color = INK, align = "center")
            ink(c, "ESPN LISTS NO CLUBS FOR THIS PLAYER", c.width // 2, 24,
                font = "4x5", color = DIM, align = "center")
            return

    # Oldest on the left, so the row reads as a timeline in the direction the
    # eye already travels. teams() hands them back newest first.
    #
    # Adjacent duplicates are merged first: a franchise that moved or was
    # renamed appears twice under one crest (Derek Carr's path drew the Raiders
    # mark, an arrow, and the Raiders mark again), so the two spells become one
    # crest carrying the outer span.
    path = []
    for i in range(len(th)):
        t = th[len(th) - 1 - i]
        if len(path) > 0 and t["logo"] != "" and path[-1]["logo"] == t["logo"]:
            path[-1] = {
                "name": path[-1]["name"],
                "span": merge_span(path[-1]["span"], t["span"]),
                "logo": t["logo"],
                "now": path[-1]["now"] or t["now"],
            }
            continue
        path.append(t)

    # Crests, not team names. "WASHINGTON COMMANDERS" is 84px of 4x5 text that
    # says what 26px of crest says faster, and four of them stacked was the
    # densest, least Glance-like page in the app. A one-club career is one 26px
    # crest in the middle of a 192px panel, which on a scroll strip reads as
    # dead air, so a single club is named in full beside its crest. Two clubs
    # are NOT: crest + 5 + a name needs about 90px each, two never fit in 172,
    # and the overflow loop then dropped the club the player actually plays for
    # -- 141 of the 141 two-club players were showing only their old team.
    named = len(path) == 1
    cols = []
    for t in path:
        wh = logo_box(t["logo"])
        sw = c.text_width(t["span"], "4x5")
        nf, ns, tw = "", "", 0
        if named:
            nf, ns = fit(c, t["name"], ["6x8", "5x7", "4x5"], 110)
            tw = max(c.text_width(ns, nf), sw)
        w = max(wh[0], sw) if not named else wh[0] + 5 + tw
        cols.append([t, w, wh, ns, nf, tw])

    # Fit from the NEWEST end backwards. Filling left-to-right and truncating
    # kept the oldest clubs and pushed the current one into the "+N" -- the one
    # club a viewer is certain to want was the one guaranteed to be dropped.
    gap, arrow_w = 4, 3
    pitch_extra = gap * 2 + arrow_w
    plus_w = 18                     # "+N" at 6x8 plus its gap; 14 overflowed
    total, shown = 0, 0
    for i in range(len(cols)):
        j = len(cols) - 1 - i
        add = cols[j][1] + (pitch_extra if shown > 0 else 0)
        room = X1 - X0 + 1 - (plus_w if i < len(cols) - 1 else 0)
        if total + add > room:
            break
        total += add
        shown += 1
    if shown == 0:
        shown, total = 1, cols[len(cols) - 1][1]

    more = len(cols) - shown
    first = more                    # index of the oldest club still drawn
    block = total + (plus_w if more > 0 else 0)
    x = X0 + (X1 - X0 + 1 - block) // 2
    base = 25                                  # every crest sits on this line

    if more > 0:
        # The "+N" leads now, because what it stands for is the earlier part
        # of the career and the row still reads oldest-to-newest.
        ink(c, "+" + str(more), x, base - 9, font = "6x8", color = DIM)
        x += plus_w

    for i in range(first, len(cols)):
        t, w, wh = cols[i][0], cols[i][1], cols[i][2]
        ns, nf, tw = cols[i][3], cols[i][4], cols[i][5]
        if i > first:
            c.sprite(ARROW, x + gap, base - 11, color = STRUCT)
            x += gap * 2 + arrow_w
        # Highlight the club the player is at NOW, not whichever happens to be
        # last in ESPN's list -- its order is not chronological, so a dozen
        # players had a former club lit up and their current one greyed out.
        cur = t["now"]
        if named and wh[0] > 0:
            c.image(LOGO_FILE[t["logo"]], x, base - wh[1])
            tx2 = x + wh[0] + 5
            ink(c, ns, tx2, base - wh[1] + (wh[1] - FONTH[nf]) // 2, font = nf,
                color = INK if cur else DIM)
            ink(c, t["span"], tx2 + tw // 2, 26, font = "4x5",
                color = ac if cur else DIM, align = "center")
            x += w
            continue
        if wh[0] > 0:
            c.image(LOGO_FILE[t["logo"]], x + (w - wh[0]) // 2, base - wh[1])
        else:
            # No crest for this franchise: the name, fitted, rather than a hole.
            f, s = fit(c, t["name"], ["6x8", "5x7", "4x5"], w)
            ink(c, s, x, base - FONTH[f], font = f, color = DIM)
        ink(c, t["span"], x + w // 2, 26, font = "4x5",
            color = ac if cur else DIM, align = "center")
        x += w

# ------------------------------------------------------------- team art
# "<league>:<espn team id>" -> crest. teamHistory carries an id and a
# displayName but no abbreviation, so the id is the only stable join to
# the asset files. Ids repeat across leagues (13 is the Lakers and the
# Rangers), hence the league prefix.
TEAM_LOGO = {
    "mlb:1": "mlb_bal",
    "mlb:10": "mlb_nyy",
    "mlb:11": "mlb_ath",
    "mlb:12": "mlb_sea",
    "mlb:13": "mlb_tex",
    "mlb:14": "mlb_tor",
    "mlb:15": "mlb_atl",
    "mlb:16": "mlb_chc",
    "mlb:17": "mlb_cin",
    "mlb:18": "mlb_hou",
    "mlb:19": "mlb_lad",
    "mlb:2": "mlb_bos",
    "mlb:20": "mlb_wsh",
    "mlb:21": "mlb_nym",
    "mlb:22": "mlb_phi",
    "mlb:23": "mlb_pit",
    "mlb:24": "mlb_stl",
    "mlb:25": "mlb_sd",
    "mlb:26": "mlb_sf",
    "mlb:27": "mlb_col",
    "mlb:28": "mlb_mia",
    "mlb:29": "mlb_ari",
    "mlb:3": "mlb_laa",
    "mlb:30": "mlb_tb",
    "mlb:4": "mlb_chw",
    "mlb:5": "mlb_cle",
    "mlb:6": "mlb_det",
    "mlb:7": "mlb_kc",
    "mlb:8": "mlb_mil",
    "mlb:9": "mlb_min",
    "nba:1": "nba_atl",
    "nba:10": "nba_hou",
    "nba:11": "nba_ind",
    "nba:12": "nba_lac",
    "nba:13": "nba_lal",
    "nba:14": "nba_mia",
    "nba:15": "nba_mil",
    "nba:16": "nba_min",
    "nba:17": "nba_bkn",
    "nba:18": "nba_ny",
    "nba:19": "nba_orl",
    "nba:2": "nba_bos",
    "nba:20": "nba_phi",
    "nba:21": "nba_phx",
    "nba:22": "nba_por",
    "nba:23": "nba_sac",
    "nba:24": "nba_sa",
    "nba:25": "nba_okc",
    "nba:26": "nba_utah",
    "nba:27": "nba_wsh",
    "nba:28": "nba_tor",
    "nba:29": "nba_mem",
    "nba:3": "nba_no",
    "nba:30": "nba_cha",
    "nba:4": "nba_chi",
    "nba:5": "nba_cle",
    "nba:6": "nba_dal",
    "nba:7": "nba_den",
    "nba:8": "nba_det",
    "nba:9": "nba_gs",
    "nfl:1": "nfl_atl",
    "nfl:10": "nfl_ten",
    "nfl:11": "nfl_ind",
    "nfl:12": "nfl_kc",
    "nfl:13": "nfl_lv",
    "nfl:14": "nfl_lar",
    "nfl:15": "nfl_mia",
    "nfl:16": "nfl_min",
    "nfl:17": "nfl_ne",
    "nfl:18": "nfl_no",
    "nfl:19": "nfl_nyg",
    "nfl:2": "nfl_buf",
    "nfl:20": "nfl_nyj",
    "nfl:21": "nfl_phi",
    "nfl:22": "nfl_ari",
    "nfl:23": "nfl_pit",
    "nfl:24": "nfl_lac",
    "nfl:25": "nfl_sf",
    "nfl:26": "nfl_sea",
    "nfl:27": "nfl_tb",
    "nfl:28": "nfl_wsh",
    "nfl:29": "nfl_car",
    "nfl:3": "nfl_chi",
    "nfl:30": "nfl_jax",
    "nfl:33": "nfl_bal",
    "nfl:34": "nfl_hou",
    "nfl:4": "nfl_cin",
    "nfl:5": "nfl_cle",
    "nfl:6": "nfl_dal",
    "nfl:7": "nfl_den",
    "nfl:8": "nfl_det",
    "nfl:9": "nfl_gb",
    "nhl:1": "nhl_bos",
    "nhl:10": "nhl_mtl",
    "nhl:11": "nhl_nj",
    "nhl:12": "nhl_nyi",
    "nhl:124292": "nhl_sea",
    "nhl:129764": "nhl_utah",
    "nhl:13": "nhl_nyr",
    "nhl:14": "nhl_ott",
    "nhl:15": "nhl_phi",
    "nhl:16": "nhl_pit",
    "nhl:17": "nhl_col",
    "nhl:18": "nhl_sj",
    "nhl:19": "nhl_stl",
    "nhl:2": "nhl_buf",
    "nhl:20": "nhl_tb",
    "nhl:21": "nhl_tor",
    "nhl:22": "nhl_van",
    "nhl:23": "nhl_wsh",
    "nhl:25": "nhl_ana",
    "nhl:26": "nhl_fla",
    "nhl:27": "nhl_nsh",
    "nhl:28": "nhl_wpg",
    "nhl:29": "nhl_cbj",
    "nhl:3": "nhl_cgy",
    "nhl:30": "nhl_min",
    "nhl:37": "nhl_vgk",
    "nhl:4": "nhl_chi",
    "nhl:5": "nhl_det",
    "nhl:6": "nhl_edm",
    "nhl:7": "nhl_car",
    "nhl:8": "nhl_la",
    "nhl:9": "nhl_dal",
}

# Measured from the PNGs. The crests are hand-drawn at native size and
# drawn at it -- scaling pixel art this small turns a readable mark to mush.
LOGO_W = {
    "mlb_ari": [19, 16],
    "mlb_ath": [23, 19],
    "mlb_atl": [20, 19],
    "mlb_bal": [20, 19],
    "mlb_bos": [13, 19],
    "mlb_chc": [19, 19],
    "mlb_chw": [14, 19],
    "mlb_cin": [26, 18],
    "mlb_cle": [12, 19],
    "mlb_col": [16, 19],
    "mlb_det": [13, 19],
    "mlb_hou": [19, 19],
    "mlb_kc": [19, 19],
    "mlb_laa": [12, 19],
    "mlb_lad": [13, 19],
    "mlb_mia": [23, 18],
    "mlb_mil": [17, 19],
    "mlb_min": [18, 19],
    "mlb_nym": [13, 19],
    "mlb_nyy": [17, 19],
    "mlb_phi": [14, 19],
    "mlb_pit": [13, 19],
    "mlb_sd": [14, 19],
    "mlb_sea": [12, 19],
    "mlb_sf": [13, 19],
    "mlb_stl": [15, 19],
    "mlb_tb": [22, 19],
    "mlb_tex": [17, 19],
    "mlb_tor": [24, 19],
    "mlb_wsh": [24, 19],
    "nba_atl": [19, 19],
    "nba_bkn": [19, 19],
    "nba_bos": [19, 19],
    "nba_cha": [25, 19],
    "nba_chi": [22, 19],
    "nba_cle": [22, 19],
    "nba_dal": [19, 19],
    "nba_den": [19, 19],
    "nba_det": [19, 19],
    "nba_gs": [19, 19],
    "nba_hou": [14, 19],
    "nba_ind": [23, 19],
    "nba_lac": [14, 19],
    "nba_lal": [19, 16],
    "nba_mem": [20, 19],
    "nba_mia": [18, 19],
    "nba_mil": [25, 19],
    "nba_min": [19, 19],
    "nba_no": [26, 10],
    "nba_ny": [25, 19],
    "nba_okc": [17, 19],
    "nba_orl": [26, 18],
    "nba_phi": [24, 19],
    "nba_phx": [26, 19],
    "nba_por": [19, 19],
    "nba_sa": [18, 18],
    "nba_sac": [26, 19],
    "nba_tor": [19, 19],
    "nba_utah": [26, 18],
    "nba_wsh": [19, 19],
    "nfl_ari": [22, 19],
    "nfl_atl": [26, 19],
    "nfl_bal": [26, 12],
    "nfl_buf": [26, 17],
    "nfl_car": [26, 17],
    "nfl_chi": [19, 19],
    "nfl_cin": [26, 18],
    "nfl_cle": [26, 19],
    "nfl_dal": [20, 19],
    "nfl_den": [26, 13],
    "nfl_det": [25, 19],
    "nfl_gb": [26, 17],
    "nfl_hou": [21, 19],
    "nfl_ind": [18, 19],
    "nfl_jax": [25, 16],
    "nfl_kc": [26, 16],
    "nfl_lac": [26, 11],
    "nfl_lar": [26, 19],
    "nfl_lv": [20, 19],
    "nfl_mia": [26, 18],
    "nfl_min": [15, 19],
    "nfl_ne": [26, 12],
    "nfl_no": [19, 19],
    "nfl_nyg": [24, 19],
    "nfl_nyj": [26, 16],
    "nfl_phi": [26, 18],
    "nfl_pit": [19, 19],
    "nfl_sea": [26, 13],
    "nfl_sf": [26, 15],
    "nfl_tb": [26, 19],
    "nfl_ten": [19, 19],
    "nfl_wsh": [26, 14],
    "nhl_ana": [23, 19],
    "nhl_bos": [19, 19],
    "nhl_buf": [19, 19],
    "nhl_car": [26, 16],
    "nhl_cbj": [23, 18],
    "nhl_cgy": [22, 19],
    "nhl_chi": [26, 19],
    "nhl_col": [25, 19],
    "nhl_dal": [23, 19],
    "nhl_det": [26, 19],
    "nhl_edm": [19, 19],
    "nhl_fla": [22, 19],
    "nhl_la": [26, 19],
    "nhl_min": [26, 17],
    "nhl_mtl": [26, 18],
    "nhl_nj": [19, 19],
    "nhl_nsh": [26, 16],
    "nhl_nyi": [19, 19],
    "nhl_nyr": [20, 19],
    "nhl_ott": [24, 19],
    "nhl_phi": [19, 13],
    "nhl_pit": [20, 19],
    "nhl_sea": [15, 19],
    "nhl_sj": [26, 19],
    "nhl_stl": [24, 19],
    "nhl_tb": [21, 19],
    "nhl_tor": [25, 19],
    "nhl_utah": [26, 17],
    "nhl_van": [20, 19],
    "nhl_vgk": [14, 19],
    "nhl_wpg": [19, 19],
    "nhl_wsh": [26, 19],
}

LOGO_FILE = {
    "mlb_ari": "assets/logos/mlb_ari.png",
    "mlb_ath": "assets/logos/mlb_ath.png",
    "mlb_atl": "assets/logos/mlb_atl.png",
    "mlb_bal": "assets/logos/mlb_bal.png",
    "mlb_bos": "assets/logos/mlb_bos.png",
    "mlb_chc": "assets/logos/mlb_chc.png",
    "mlb_chw": "assets/logos/mlb_chw.png",
    "mlb_cin": "assets/logos/mlb_cin.png",
    "mlb_cle": "assets/logos/mlb_cle.png",
    "mlb_col": "assets/logos/mlb_col.png",
    "mlb_det": "assets/logos/mlb_det.png",
    "mlb_hou": "assets/logos/mlb_hou.png",
    "mlb_kc": "assets/logos/mlb_kc.png",
    "mlb_laa": "assets/logos/mlb_laa.png",
    "mlb_lad": "assets/logos/mlb_lad.png",
    "mlb_mia": "assets/logos/mlb_mia.png",
    "mlb_mil": "assets/logos/mlb_mil.png",
    "mlb_min": "assets/logos/mlb_min.png",
    "mlb_nym": "assets/logos/mlb_nym.png",
    "mlb_nyy": "assets/logos/mlb_nyy.png",
    "mlb_phi": "assets/logos/mlb_phi.png",
    "mlb_pit": "assets/logos/mlb_pit.png",
    "mlb_sd": "assets/logos/mlb_sd.png",
    "mlb_sea": "assets/logos/mlb_sea.png",
    "mlb_sf": "assets/logos/mlb_sf.png",
    "mlb_stl": "assets/logos/mlb_stl.png",
    "mlb_tb": "assets/logos/mlb_tb.png",
    "mlb_tex": "assets/logos/mlb_tex.png",
    "mlb_tor": "assets/logos/mlb_tor.png",
    "mlb_wsh": "assets/logos/mlb_wsh.png",
    "nba_atl": "assets/logos/nba_atl.png",
    "nba_bkn": "assets/logos/nba_bkn.png",
    "nba_bos": "assets/logos/nba_bos.png",
    "nba_cha": "assets/logos/nba_cha.png",
    "nba_chi": "assets/logos/nba_chi.png",
    "nba_cle": "assets/logos/nba_cle.png",
    "nba_dal": "assets/logos/nba_dal.png",
    "nba_den": "assets/logos/nba_den.png",
    "nba_det": "assets/logos/nba_det.png",
    "nba_gs": "assets/logos/nba_gs.png",
    "nba_hou": "assets/logos/nba_hou.png",
    "nba_ind": "assets/logos/nba_ind.png",
    "nba_lac": "assets/logos/nba_lac.png",
    "nba_lal": "assets/logos/nba_lal.png",
    "nba_mem": "assets/logos/nba_mem.png",
    "nba_mia": "assets/logos/nba_mia.png",
    "nba_mil": "assets/logos/nba_mil.png",
    "nba_min": "assets/logos/nba_min.png",
    "nba_no": "assets/logos/nba_no.png",
    "nba_ny": "assets/logos/nba_ny.png",
    "nba_okc": "assets/logos/nba_okc.png",
    "nba_orl": "assets/logos/nba_orl.png",
    "nba_phi": "assets/logos/nba_phi.png",
    "nba_phx": "assets/logos/nba_phx.png",
    "nba_por": "assets/logos/nba_por.png",
    "nba_sa": "assets/logos/nba_sa.png",
    "nba_sac": "assets/logos/nba_sac.png",
    "nba_tor": "assets/logos/nba_tor.png",
    "nba_utah": "assets/logos/nba_utah.png",
    "nba_wsh": "assets/logos/nba_wsh.png",
    "nfl_ari": "assets/logos/nfl_ari.png",
    "nfl_atl": "assets/logos/nfl_atl.png",
    "nfl_bal": "assets/logos/nfl_bal.png",
    "nfl_buf": "assets/logos/nfl_buf.png",
    "nfl_car": "assets/logos/nfl_car.png",
    "nfl_chi": "assets/logos/nfl_chi.png",
    "nfl_cin": "assets/logos/nfl_cin.png",
    "nfl_cle": "assets/logos/nfl_cle.png",
    "nfl_dal": "assets/logos/nfl_dal.png",
    "nfl_den": "assets/logos/nfl_den.png",
    "nfl_det": "assets/logos/nfl_det.png",
    "nfl_gb": "assets/logos/nfl_gb.png",
    "nfl_hou": "assets/logos/nfl_hou.png",
    "nfl_ind": "assets/logos/nfl_ind.png",
    "nfl_jax": "assets/logos/nfl_jax.png",
    "nfl_kc": "assets/logos/nfl_kc.png",
    "nfl_lac": "assets/logos/nfl_lac.png",
    "nfl_lar": "assets/logos/nfl_lar.png",
    "nfl_lv": "assets/logos/nfl_lv.png",
    "nfl_mia": "assets/logos/nfl_mia.png",
    "nfl_min": "assets/logos/nfl_min.png",
    "nfl_ne": "assets/logos/nfl_ne.png",
    "nfl_no": "assets/logos/nfl_no.png",
    "nfl_nyg": "assets/logos/nfl_nyg.png",
    "nfl_nyj": "assets/logos/nfl_nyj.png",
    "nfl_phi": "assets/logos/nfl_phi.png",
    "nfl_pit": "assets/logos/nfl_pit.png",
    "nfl_sea": "assets/logos/nfl_sea.png",
    "nfl_sf": "assets/logos/nfl_sf.png",
    "nfl_tb": "assets/logos/nfl_tb.png",
    "nfl_ten": "assets/logos/nfl_ten.png",
    "nfl_wsh": "assets/logos/nfl_wsh.png",
    "nhl_ana": "assets/logos/nhl_ana.png",
    "nhl_bos": "assets/logos/nhl_bos.png",
    "nhl_buf": "assets/logos/nhl_buf.png",
    "nhl_car": "assets/logos/nhl_car.png",
    "nhl_cbj": "assets/logos/nhl_cbj.png",
    "nhl_cgy": "assets/logos/nhl_cgy.png",
    "nhl_chi": "assets/logos/nhl_chi.png",
    "nhl_col": "assets/logos/nhl_col.png",
    "nhl_dal": "assets/logos/nhl_dal.png",
    "nhl_det": "assets/logos/nhl_det.png",
    "nhl_edm": "assets/logos/nhl_edm.png",
    "nhl_fla": "assets/logos/nhl_fla.png",
    "nhl_la": "assets/logos/nhl_la.png",
    "nhl_min": "assets/logos/nhl_min.png",
    "nhl_mtl": "assets/logos/nhl_mtl.png",
    "nhl_nj": "assets/logos/nhl_nj.png",
    "nhl_nsh": "assets/logos/nhl_nsh.png",
    "nhl_nyi": "assets/logos/nhl_nyi.png",
    "nhl_nyr": "assets/logos/nhl_nyr.png",
    "nhl_ott": "assets/logos/nhl_ott.png",
    "nhl_phi": "assets/logos/nhl_phi.png",
    "nhl_pit": "assets/logos/nhl_pit.png",
    "nhl_sea": "assets/logos/nhl_sea.png",
    "nhl_sj": "assets/logos/nhl_sj.png",
    "nhl_stl": "assets/logos/nhl_stl.png",
    "nhl_tb": "assets/logos/nhl_tb.png",
    "nhl_tor": "assets/logos/nhl_tor.png",
    "nhl_utah": "assets/logos/nhl_utah.png",
    "nhl_van": "assets/logos/nhl_van.png",
    "nhl_vgk": "assets/logos/nhl_vgk.png",
    "nhl_wpg": "assets/logos/nhl_wpg.png",
    "nhl_wsh": "assets/logos/nhl_wsh.png",
}

# ---------------------------------------------------------------- players
# Dropdown label -> [league, ESPN athlete id]. Merged from the four
# athlete-tracker apps, which regenerate their lists weekly from ESPN
# ownership. The league suffix is part of the label because names collide
# across sports and the panel has to know which endpoint to call.
PLAYERS = {
    "A.J. Brown (NFL)": ["nfl", 4047646],
    "A.J. Ewing (MLB)": ["mlb", 5208019],
    "A.J. Greer (NHL)": ["nhl", 3648015],
    "A.J. Lawson (NBA)": ["nba", 4067017],
    "A.J. Minter (MLB)": ["mlb", 36133],
    "Aaron Ashby (MLB)": ["mlb", 41325],
    "Aaron Civale (MLB)": ["mlb", 40934],
    "Aaron Ekblad (NHL)": ["nhl", 3114717],
    "Aaron Gordon (NBA)": ["nba", 3064290],
    "Aaron Holiday (NBA)": ["nba", 3922230],
    "Aaron Jones Sr. (NFL)": ["nfl", 3042519],
    "Aaron Judge (MLB)": ["mlb", 33192],
    "Aaron Nesmith (NBA)": ["nba", 4396909],
    "Aaron Nola (MLB)": ["mlb", 33709],
    "Aaron Rodgers (NFL)": ["nfl", 8439],
    "Aaron White (NBA)": ["nba", 2595175],
    "Aaron Wiggins (NBA)": ["nba", 4397183],
    "Aatu Raty (NHL)": ["nhl", 4874912],
    "Abimelec Ortiz (MLB)": ["mlb", 5194635],
    "Abner Uribe (MLB)": ["mlb", 4917865],
    "Ace Bailey (NBA)": ["nba", 4873138],
    "Adael Amador (MLB)": ["mlb", 4917787],
    "Adam Edstrom (NHL)": ["nhl", 4894222],
    "Adam Fantilli (NHL)": ["nhl", 5136617],
    "Adam Fox (NHL)": ["nhl", 4197146],
    "Adam Henrique (NHL)": ["nhl", 5074],
    "Adam Jiricek (NHL)": ["nhl", 5216884],
    "Adam Klapka (NHL)": ["nhl", 5073306],
    "Adam Larsson (NHL)": ["nhl", 2562610],
    "Adam Lowry (NHL)": ["nhl", 2563066],
    "Adam Pelech (NHL)": ["nhl", 3069621],
    "Adam Prentice (NFL)": ["nfl", 3929914],
    "Adam Randall (NFL)": ["nfl", 4685526],
    "Adam Thielen (NFL)": ["nfl", 16460],
    "Adam Trautman (NFL)": ["nfl", 3911853],
    "Adam Wilsby (NHL)": ["nhl", 4697765],
    "Adama Sanogo (NBA)": ["nba", 4702023],
    "Aday Mara (NBA)": ["nba", 5174983],
    "Addison Barger (MLB)": ["mlb", 4997589],
    "Adem Bona (NBA)": ["nba", 5105637],
    "Adin Hill (NHL)": ["nhl", 3939714],
    "Adley Rutschman (MLB)": ["mlb", 42178],
    "Adolis Garcia (MLB)": ["mlb", 35537],
    "Adonai Mitchell (NFL)": ["nfl", 4597500],
    "Adou Thiero (NBA)": ["nba", 5060631],
    "Adreian Payne (NBA)": ["nba", 2531100],
    "Adrian Houser (MLB)": ["mlb", 32157],
    "Adrian Kempe (NHL)": ["nhl", 3114802],
    "Adrian Martinez (NFL)": ["nfl", 4361182],
    "Adrian Morejon (MLB)": ["mlb", 40917],
    "Agustin Ramirez (MLB)": ["mlb", 5132014],
    "Aidan Miller (MLB)": ["mlb", 5148968],
    "Aidan O'Connell (NFL)": ["nfl", 4260394],
    "AJ Barner (NFL)": ["nfl", 4576297],
    "AJ Blubaugh (MLB)": ["mlb", 42556],
    "AJ Dillon (NFL)": ["nfl", 4239934],
    "AJ Dybantsa (NBA)": ["nba", 5142718],
    "AJ Green (NBA)": ["nba", 4397475],
    "AJ Hammons (NBA)": ["nba", 2991178],
    "AJ Henning (NFL)": ["nfl", 4429053],
    "AJ Johnson (NBA)": ["nba", 5170947],
    "AJ Smith-Shawver (MLB)": ["mlb", 4917640],
    "Ajay Mitchell (NBA)": ["nba", 4900671],
    "Akira Schmid (NHL)": ["nhl", 4587845],
    "Al Horford (NBA)": ["nba", 3213],
    "Alan Williams (NBA)": ["nba", 2579326],
    "Alberts Smits (NHL)": ["nhl", 5334662],
    "Alec Bohm (MLB)": ["mlb", 41169],
    "Alec Burks (NBA)": ["nba", 6429],
    "Alec Burleson (MLB)": ["mlb", 4345070],
    "Alec Ingold (NFL)": ["nfl", 3917668],
    "Alec Martinez (NHL)": ["nhl", 3927],
    "Alec Pierce (NFL)": ["nfl", 4360078],
    "Alejandro Kirk (MLB)": ["mlb", 42081],
    "Aleksander Barkov (NHL)": ["nhl", 3041970],
    "Alex Antetokounmpo (NBA)": ["nba", 4432452],
    "Alex Bachman (NFL)": ["nfl", 3919510],
    "Alex Bregman (MLB)": ["mlb", 34886],
    "Alex Bump (NHL)": ["nhl", 5188356],
    "Alex Burrows (NHL)": ["nhl", 3259],
    "Alex Caruso (NBA)": ["nba", 2991350],
    "Alex DeBrincat (NHL)": ["nhl", 4063433],
    "Alex Formenton (NHL)": ["nhl", 4233882],
    "Alex Iafallo (NHL)": ["nhl", 3652598],
    "Alex Karaban (NBA)": ["nba", 4917149],
    "Alex Killorn (NHL)": ["nhl", 4968],
    "Alex Kirk (NBA)": ["nba", 2528355],
    "Alex Laferriere (NHL)": ["nhl", 4697725],
    "Alex Lange (MLB)": ["mlb", 40976],
    "Alex Len (NBA)": ["nba", 2596107],
    "Alex Lyon (NHL)": ["nhl", 3654006],
    "Alex McFarlane (MLB)": ["mlb", 4621422],
    "Alex Nedeljkovic (NHL)": ["nhl", 3114994],
    "Alex Newhook (NHL)": ["nhl", 4565237],
    "Alex Ovechkin (NHL)": ["nhl", 3101],
    "Alex Pietrangelo (NHL)": ["nhl", 4013],
    "Alex Sarr (NBA)": ["nba", 5160992],
    "Alex Toohey (NBA)": ["nba", 5170949],
    "Alex Tuch (NHL)": ["nhl", 3114766],
    "Alex Turcotte (NHL)": ["nhl", 4565226],
    "Alex Vesia (MLB)": ["mlb", 42622],
    "Alex Vlasic (NHL)": ["nhl", 4565266],
    "Alexander Kerfoot (NHL)": ["nhl", 3069394],
    "Alexander Nikishin (NHL)": ["nhl", 4915850],
    "Alexander Nylander (NHL)": ["nhl", 4024861],
    "Alexander Romanov (NHL)": ["nhl", 4587854],
    "Alexander Wennberg (NHL)": ["nhl", 3042017],
    "Alexander Zharovsky (NHL)": ["nhl", 5291976],
    "Alexandre Carrier (NHL)": ["nhl", 3942064],
    "Alexandre Texier (NHL)": ["nhl", 4233880],
    "Alexis Lafreniere (NHL)": ["nhl", 4697382],
    "Alfonzo McKinnie (NBA)": ["nba", 2530923],
    "Aliaksei Protas (NHL)": ["nhl", 4587943],
    "Alijah Martin (NBA)": ["nba", 4702656],
    "Allen Graves (NBA)": ["nba", 5149115],
    "Allonzo Trier (NBA)": ["nba", 3907525],
    "Alondes Williams (NBA)": ["nba", 4592216],
    "Alperen Sengun (NBA)": ["nba", 4871144],
    "Alpha Diallo (NBA)": ["nba", 4065813],
    "Alpha Kaba (NBA)": ["nba", 3893020],
    "Alvin Kamara (NFL)": ["nfl", 3054850],
    "Amar Johnson (NFL)": ["nfl", 4878878],
    "Amari Bailey (NBA)": ["nba", 5105638],
    "Amari Cooper (NFL)": ["nfl", 2976499],
    "Amari Williams (NBA)": ["nba", 4702745],
    "Amed Rosario (MLB)": ["mlb", 33215],
    "Ameer Abdullah (NFL)": ["nfl", 2576336],
    "Amen Thompson (NBA)": ["nba", 4684740],
    "Amida Brimah (NBA)": ["nba", 3074748],
    "Amon-Ra St. Brown (NFL)": ["nfl", 4374302],
    "Anders Carlson (NFL)": ["nfl", 4242519],
    "Anders Lee (NHL)": ["nhl", 5793],
    "Andre Burakovsky (NHL)": ["nhl", 3042044],
    "Andre Drummond (NBA)": ["nba", 6585],
    "Andre Jackson Jr. (NBA)": ["nba", 4432190],
    "Andre Pallante (MLB)": ["mlb", 4109034],
    "Andre Szmyt (NFL)": ["nfl", 4258620],
    "Andrei Iosivas (NFL)": ["nfl", 4368003],
    "Andrei Kuzmenko (NHL)": ["nhl", 5077308],
    "Andrei Svechnikov (NHL)": ["nhl", 4352683],
    "Andrei Vasilevskiy (NHL)": ["nhl", 2976847],
    "Andres Gimenez (MLB)": ["mlb", 37729],
    "Andres Munoz (MLB)": ["mlb", 40939],
    "Andrew Abbott (MLB)": ["mlb", 4414528],
    "Andrew Alvarez (MLB)": ["mlb", 4300668],
    "Andrew Armstrong (NFL)": ["nfl", 5093923],
    "Andrew Beck (NFL)": ["nfl", 3125107],
    "Andrew Benintendi (MLB)": ["mlb", 34986],
    "Andrew Copp (NHL)": ["nhl", 3042114],
    "Andrew Cristall (NHL)": ["nhl", 5149227],
    "Andrew Fischer (MLB)": ["mlb", 5128616],
    "Andrew Kittredge (MLB)": ["mlb", 35872],
    "Andrew Morris (MLB)": ["mlb", 5007765],
    "Andrew Nembhard (NBA)": ["nba", 4395712],
    "Andrew Painter (MLB)": ["mlb", 4872683],
    "Andrew Peeke (NHL)": ["nhl", 4064936],
    "Andrew Vaughn (MLB)": ["mlb", 42394],
    "Andrew White III (NBA)": ["nba", 2990972],
    "Andrew Wiggins (NBA)": ["nba", 3059319],
    "Andruw Monasterio (MLB)": ["mlb", 36950],
    "Andy Borregales (NFL)": ["nfl", 4569923],
    "Andy Dalton (NFL)": ["nfl", 14012],
    "Andy Greene (NHL)": ["nhl", 3313],
    "Andy Pages (MLB)": ["mlb", 42468],
    "Anfernee Simons (NBA)": ["nba", 4351851],
    "Angel Delgado (NBA)": ["nba", 3136479],
    "Angel Genao (MLB)": ["mlb", 5204351],
    "Angel Martinez (MLB)": ["mlb", 42497],
    "Anthony Beauvillier (NHL)": ["nhl", 3904107],
    "Anthony Black (NBA)": ["nba", 4712849],
    "Anthony Brown (NBA)": ["nba", 2531362],
    "Anthony Cirelli (NHL)": ["nhl", 3941973],
    "Anthony Davis (NBA)": ["nba", 6583],
    "Anthony Duclair (NHL)": ["nhl", 3042086],
    "Anthony Edwards (NBA)": ["nba", 4594268],
    "Anthony Eyanson (MLB)": ["mlb", 5129725],
    "Anthony Gill (NBA)": ["nba", 2581184],
    "Anthony Gould (NFL)": ["nfl", 4429684],
    "Anthony Kay (MLB)": ["mlb", 40947],
    "Anthony Lamb (NBA)": ["nba", 4066790],
    "Anthony Mantha (NHL)": ["nhl", 3042037],
    "Anthony Molina (MLB)": ["mlb", 5016983],
    "Anthony Richardson Sr. (NFL)": ["nfl", 4429084],
    "Anthony Santander (MLB)": ["mlb", 36084],
    "Anthony Smith (NFL)": ["nfl", 4685110],
    "Anthony Stolarz (NHL)": ["nhl", 3067313],
    "Anthony Tolliver (NBA)": ["nba", 3276],
    "Anthony Tyus III (NFL)": ["nfl", 4709392],
    "Anthony Volpe (MLB)": ["mlb", 42547],
    "Anton Forsberg (NHL)": ["nhl", 3036851],
    "Anton Frondell (NHL)": ["nhl", 5291935],
    "Anton Johansson (NHL)": ["nhl", 5188582],
    "Anton Lundell (NHL)": ["nhl", 4697395],
    "Anton Watson (NBA)": ["nba", 4431705],
    "Antonio Blakeney (NBA)": ["nba", 3907386],
    "Antonio Gibson (NFL)": ["nfl", 4360294],
    "Antonio Reeves (NBA)": ["nba", 4592686],
    "Antonio Senzatela (MLB)": ["mlb", 33750],
    "Antonio Williams (NFL)": ["nfl", 5081432],
    "Antonius Cleveland (NBA)": ["nba", 3064237],
    "Antti Niemi (NHL)": ["nhl", 3937],
    "Antwone Kelly (MLB)": ["mlb", 5134366],
    "Anze Kopitar (NHL)": ["nhl", 3183],
    "Arber Xhekaj (NHL)": ["nhl", 4893969],
    "Arian Smith (NFL)": ["nfl", 4429105],
    "Ariel Hukporti (NBA)": ["nba", 4871141],
    "Aroldis Chapman (MLB)": ["mlb", 30442],
    "Aron Baynes (NBA)": ["nba", 2968439],
    "Arseny Gritsyuk (NHL)": ["nhl", 4915855],
    "Arshdeep Bains (NHL)": ["nhl", 5103536],
    "Artem Zub (NHL)": ["nhl", 4712021],
    "Artemi Panarin (NHL)": ["nhl", 3891952],
    "Arttu Hyry (NHL)": ["nhl", 5209793],
    "Artturi Lehkonen (NHL)": ["nhl", 3042050],
    "Artur Akhtyamov (NHL)": ["nhl", 4697577],
    "Arturas Gudaitis (NBA)": ["nba", 3893015],
    "Arturs Silovs (NHL)": ["nhl", 4576894],
    "Artyom Levshunov (NHL)": ["nhl", 5206648],
    "Arvid Soderblom (NHL)": ["nhl", 4894729],
    "Asa Newell (NBA)": ["nba", 4873201],
    "Ashton Dulin (NFL)": ["nfl", 4061956],
    "Ashton Jeanty (NFL)": ["nfl", 4890973],
    "Athan Kaliakmanis (NFL)": ["nfl", 4432722],
    "Audric Estime (NFL)": ["nfl", 4569682],
    "Ausar Thompson (NBA)": ["nba", 4684742],
    "Austin Ekeler (NFL)": ["nfl", 3068267],
    "Austin Hooper (NFL)": ["nfl", 3043275],
    "Austin Martin (MLB)": ["mlb", 4297998],
    "Austin Reaves (NBA)": ["nba", 4066457],
    "Austin Riley (MLB)": ["mlb", 34982],
    "Austin Seibert (NFL)": ["nfl", 3821683],
    "Austin Wells (MLB)": ["mlb", 4683349],
    "Auston Matthews (NHL)": ["nhl", 4024123],
    "Axel Sandin-Pellikka (NHL)": ["nhl", 5149192],
    "Aydar Suniev (NHL)": ["nhl", 5188613],
    "Ayo Dosunmu (NBA)": ["nba", 4397002],
    "Baba Miller (NBA)": ["nba", 5075626],
    "Bailey Ober (MLB)": ["mlb", 3107919],
    "Baker Mayfield (NFL)": ["nfl", 3052587],
    "Bam Adebayo (NBA)": ["nba", 4066261],
    "Bam Knight (NFL)": ["nfl", 4427728],
    "Barclay Goodrow (NHL)": ["nhl", 3069411],
    "Barion Brown (NFL)": ["nfl", 4698597],
    "Barrett Hayton (NHL)": ["nhl", 4352699],
    "Bauer Sharp (NFL)": ["nfl", 4890373],
    "Baylor Scheierman (NBA)": ["nba", 4593841],
    "Beaux Collins (NFL)": ["nfl", 4431210],
    "Beck Malenstyn (NHL)": ["nhl", 4063240],
    "Beckett Sennecke (NHL)": ["nhl", 5216858],
    "Behren Morton (NFL)": ["nfl", 4431465],
    "Ben Bentil (NBA)": ["nba", 3136469],
    "Ben Brown (MLB)": ["mlb", 41516],
    "Ben Chiarot (NHL)": ["nhl", 5246],
    "Ben Hutton (NHL)": ["nhl", 3571762],
    "Ben Joyce (MLB)": ["mlb", 4867388],
    "Ben Kindel (NHL)": ["nhl", 5291947],
    "Ben Lovejoy (NHL)": ["nhl", 3993],
    "Ben Meyers (NHL)": ["nhl", 4755729],
    "Ben Moore (NBA)": ["nba", 3057189],
    "Ben Rice (MLB)": ["mlb", 5016968],
    "Ben Saraf (NBA)": ["nba", 5242502],
    "Ben Sauls (NFL)": ["nfl", 4566158],
    "Ben Sheppard (NBA)": ["nba", 4433076],
    "Ben Simmons (NBA)": ["nba", 3907387],
    "Ben Sinnott (NFL)": ["nfl", 4690923],
    "Ben Skowronek (NFL)": ["nfl", 4035656],
    "Ben VanSumeren (NFL)": ["nfl", 4372070],
    "Ben Yurosek (NFL)": ["nfl", 4433959],
    "Bennedict Mathurin (NBA)": ["nba", 4683634],
    "Bennett Stirtz (NBA)": ["nba", 5241364],
    "Berkly Catton (NHL)": ["nhl", 5216877],
    "Bhayshul Tuten (NFL)": ["nfl", 4882093],
    "Bijan Robinson (NFL)": ["nfl", 4430807],
    "Bilal Coulibaly (NBA)": ["nba", 5104155],
    "Bill Zonnon (NHL)": ["nhl", 5291958],
    "Billy Garrett Jr. (NBA)": ["nba", 3059356],
    "Bismack Biyombo (NBA)": ["nba", 6427],
    "BJ Johnson (NBA)": ["nba", 3059280],
    "Blade Tidwell (MLB)": ["mlb", 4719088],
    "Blake Coleman (NHL)": ["nhl", 2563026],
    "Blake Corum (NFL)": ["nfl", 4429096],
    "Blake Grupe (NFL)": ["nfl", 4259619],
    "Blake Hinson (NBA)": ["nba", 4396963],
    "Blake Lizotte (NHL)": ["nhl", 4316983],
    "Blake Snell (MLB)": ["mlb", 33748],
    "Blake Wesley (NBA)": ["nba", 4683935],
    "Blake Whiteheart (NFL)": ["nfl", 4362018],
    "Blaze Alexander (MLB)": ["mlb", 41345],
    "Blaze Jordan (MLB)": ["mlb", 4722953],
    "Bo Bichette (MLB)": ["mlb", 38904],
    "Bo Horvat (NHL)": ["nhl", 3042002],
    "Bo Melton (NFL)": ["nfl", 4259305],
    "Bo Naylor (MLB)": ["mlb", 41183],
    "Bo Nix (NFL)": ["nfl", 4426338],
    "Boban Marjanovic (NBA)": ["nba", 4376],
    "Bobby Brink (NHL)": ["nhl", 4565257],
    "Bobby McMann (NHL)": ["nhl", 5048894],
    "Bobby Portis (NBA)": ["nba", 3064482],
    "Bobby Witt Jr. (MLB)": ["mlb", 42403],
    "Bobi Klintman (NBA)": ["nba", 4906923],
    "Bogdan Bogdanovic (NBA)": ["nba", 3037789],
    "Bogoljub Markovic (NBA)": ["nba", 5214989],
    "Bokondji Imama (NHL)": ["nhl", 3939856],
    "Bol Bol (NBA)": ["nba", 4397102],
    "Bones Hyland (NBA)": ["nba", 4592492],
    "Boo Buie (NBA)": ["nba", 4592712],
    "Boone Jenner (NHL)": ["nhl", 2563054],
    "Bowen Byram (NHL)": ["nhl", 4565225],
    "Brad Keller (MLB)": ["mlb", 35292],
    "Brad Lord (MLB)": ["mlb", 4866810],
    "Brad Marchand (NHL)": ["nhl", 3852],
    "Brad Wanamaker (NBA)": ["nba", 6507],
    "Braden Montgomery (MLB)": ["mlb", 4950345],
    "Braden Schneider (NHL)": ["nhl", 4697402],
    "Braden Smith (NBA)": ["nba", 5105854],
    "Bradgley Rodriguez (MLB)": ["mlb", 5266086],
    "Bradley Beal (NBA)": ["nba", 6580],
    "Bradly Nadeau (NHL)": ["nhl", 5149213],
    "Brady Cook (NFL)": ["nfl", 4429435],
    "Brady House (MLB)": ["mlb", 4872681],
    "Brady Martin (NHL)": ["nhl", 5291937],
    "Brady Russell (NFL)": ["nfl", 4243176],
    "Brady Singer (MLB)": ["mlb", 41172],
    "Brady Skjei (NHL)": ["nhl", 2976856],
    "Brady Tkachuk (NHL)": ["nhl", 4319858],
    "Braeden Bowman (NHL)": ["nhl", 5272307],
    "Braeden Cootes (NHL)": ["nhl", 5291951],
    "Braelon Allen (NFL)": ["nfl", 4685247],
    "Branden Carlson (NBA)": ["nba", 4592435],
    "Brandin Cooks (NFL)": ["nfl", 16731],
    "Brandin Podziemski (NBA)": ["nba", 4709138],
    "Brandon Aiyuk (NFL)": ["nfl", 4360438],
    "Brandon Allen (NFL)": ["nfl", 2574511],
    "Brandon Aubrey (NFL)": ["nfl", 3953687],
    "Brandon Bussi (NHL)": ["nhl", 4996097],
    "Brandon Carlo (NHL)": ["nhl", 3904175],
    "Brandon Duhaime (NHL)": ["nhl", 4197009],
    "Brandon Goodwin (NBA)": ["nba", 3057198],
    "Brandon Hagel (NHL)": ["nhl", 4065019],
    "Brandon Ingram (NBA)": ["nba", 3913176],
    "Brandon Lowe (MLB)": ["mlb", 39961],
    "Brandon Marsh (MLB)": ["mlb", 40803],
    "Brandon McManus (NFL)": ["nfl", 16339],
    "Brandon Miller (NBA)": ["nba", 4433287],
    "Brandon Montour (NHL)": ["nhl", 3115032],
    "Brandon Nimmo (MLB)": ["mlb", 32159],
    "Brandon Pfaadt (MLB)": ["mlb", 4721302],
    "Brandon Powell (NFL)": ["nfl", 3115255],
    "Brandon Sampson (NBA)": ["nba", 3907385],
    "Brandon Smith (NFL)": ["nfl", 4240577],
    "Brandon Sproat (MLB)": ["mlb", 4621041],
    "Brandon Valenzuela (MLB)": ["mlb", 4918248],
    "Brandon Williams (NBA)": ["nba", 4397040],
    "Brandon Williamson (MLB)": ["mlb", 42431],
    "Brandon Woodruff (MLB)": ["mlb", 37515],
    "Brandon Young (MLB)": ["mlb", 4414339],
    "Brandt Clarke (NHL)": ["nhl", 4874722],
    "Brandyn Garcia (MLB)": ["mlb", 5202600],
    "Brashard Smith (NFL)": ["nfl", 4596602],
    "Braxton Ashcraft (MLB)": ["mlb", 41282],
    "Braxton Berrios (NFL)": ["nfl", 3123075],
    "Brayan Bello (MLB)": ["mlb", 4720856],
    "Brayan Rocchio (MLB)": ["mlb", 41217],
    "Brayden Burries (NBA)": ["nba", 5082206],
    "Brayden McNabb (NHL)": ["nhl", 5202],
    "Brayden Narveson (NFL)": ["nfl", 4361765],
    "Brayden Point (NHL)": ["nhl", 3151187],
    "Brayden Schenn (NHL)": ["nhl", 5219],
    "Brayden Willis (NFL)": ["nfl", 4360290],
    "Brayden Yager (NHL)": ["nhl", 5149188],
    "Braydon Fisher (MLB)": ["mlb", 41318],
    "Breece Hall (NFL)": ["nfl", 4427366],
    "Brendan Donovan (MLB)": ["mlb", 41773],
    "Brendan Gallagher (NHL)": ["nhl", 5614],
    "Brendan Smith (NHL)": ["nhl", 4973],
    "Brenden Dillon (NHL)": ["nhl", 2554903],
    "Brenen Thompson (NFL)": ["nfl", 4685553],
    "Brennan Presley (NFL)": ["nfl", 4431342],
    "Brent Burns (NHL)": ["nhl", 2300],
    "Brent Headrick (MLB)": ["mlb", 5116839],
    "Brent Rooker (MLB)": ["mlb", 40926],
    "Brent Suter (MLB)": ["mlb", 36023],
    "Brenton Doyle (MLB)": ["mlb", 42462],
    "Brenton Strange (NFL)": ["nfl", 4430539],
    "Brett Bateman (MLB)": ["mlb", 5134494],
    "Brett Baty (MLB)": ["mlb", 42414],
    "Brett Howden (NHL)": ["nhl", 4024989],
    "Brett Kulak (NHL)": ["nhl", 3068665],
    "Brett Pesce (NHL)": ["nhl", 3025535],
    "Brevin Jordan (NFL)": ["nfl", 4362504],
    "Brevyn Spann-Ford (NFL)": ["nfl", 4360967],
    "Brian Bowen II (NBA)": ["nba", 4277882],
    "Brian Dumoulin (NHL)": ["nhl", 5738],
    "Brian Robinson Jr. (NFL)": ["nfl", 4241474],
    "Brian Thomas Jr. (NFL)": ["nfl", 4432773],
    "Briante Weber (NBA)": ["nba", 2595229],
    "Brice Johnson (NBA)": ["nba", 2982330],
    "Brice Sensabaugh (NBA)": ["nba", 5105839],
    "Brice Turang (MLB)": ["mlb", 41179],
    "Britain Covey (NFL)": ["nfl", 3926231],
    "British Brooks (NFL)": ["nfl", 4373273],
    "Brittain Brown (NFL)": ["nfl", 4036032],
    "Brock Boeser (NHL)": ["nhl", 3899979],
    "Brock Bowers (NFL)": ["nfl", 4432665],
    "Brock Burke (MLB)": ["mlb", 39945],
    "Brock Faber (NHL)": ["nhl", 4697449],
    "Brock Nelson (NHL)": ["nhl", 5798],
    "Brock Purdy (NFL)": ["nfl", 4361741],
    "Brock Wright (NFL)": ["nfl", 4242392],
    "Bronny James (NBA)": ["nba", 4683774],
    "Brook Lopez (NBA)": ["nba", 3448],
    "Brooks Barnhizer (NBA)": ["nba", 4684208],
    "Brooks Laich (NHL)": ["nhl", 2180],
    "Brooks Lee (MLB)": ["mlb", 4629081],
    "Brooks Raley (MLB)": ["mlb", 32005],
    "Bruce Brown (NBA)": ["nba", 4065670],
    "Bruce Thornton (NBA)": ["nba", 5105837],
    "Bruno Fernando (NBA)": ["nba", 4277952],
    "Bryan Abreu (MLB)": ["mlb", 41208],
    "Bryan Baker (MLB)": ["mlb", 40884],
    "Bryan Hudson (MLB)": ["mlb", 4991171],
    "Bryan King (MLB)": ["mlb", 5201821],
    "Bryan Reynolds (MLB)": ["mlb", 38980],
    "Bryan Rust (NHL)": ["nhl", 2591155],
    "Bryan Woo (MLB)": ["mlb", 4629089],
    "Bryce Cotton (NBA)": ["nba", 2531054],
    "Bryce Elder (MLB)": ["mlb", 4301067],
    "Bryce Eldridge (MLB)": ["mlb", 5149064],
    "Bryce Harper (MLB)": ["mlb", 30951],
    "Bryce Hopkins (NBA)": ["nba", 4565698],
    "Bryce Lance (NFL)": ["nfl", 4879276],
    "Bryce McGowens (NBA)": ["nba", 4576086],
    "Bryce Miller (MLB)": ["mlb", 4654313],
    "Bryce Young (NFL)": ["nfl", 4685720],
    "Brycen Tremayne (NFL)": ["nfl", 4360763],
    "Bryson Stott (MLB)": ["mlb", 42417],
    "Bub Carrington (NBA)": ["nba", 4845374],
    "Bub Means (NFL)": ["nfl", 4427985],
    "Bubba Chandler (MLB)": ["mlb", 4683325],
    "Bucky Irving (NFL)": ["nfl", 4596448],
    "Buddy Hield (NBA)": ["nba", 2990984],
    "Byron Buxton (MLB)": ["mlb", 32655],
    "C.J. Ham (NFL)": ["nfl", 4012556],
    "C.J. Stroud (NFL)": ["nfl", 4432577],
    "C.J. Williams (NBA)": ["nba", 2325499],
    "Cade Cavalli (MLB)": ["mlb", 4308037],
    "Cade Cunningham (NBA)": ["nba", 4432166],
    "Cade Horton (MLB)": ["mlb", 4692526],
    "Cade Klubnik (NFL)": ["nfl", 4685413],
    "Cade Otton (NFL)": ["nfl", 4243331],
    "Cade Smith (MLB)": ["mlb", 4987924],
    "Cade Stover (NFL)": ["nfl", 4426496],
    "Cade York (NFL)": ["nfl", 4428963],
    "Caden Davis (NFL)": ["nfl", 4570688],
    "Cady Lalanne (NBA)": ["nba", 2608716],
    "Cairo Santos (NFL)": ["nfl", 17427],
    "Cal Quantrill (MLB)": ["mlb", 39875],
    "Cal Raleigh (MLB)": ["mlb", 41292],
    "Cale Fleury (NHL)": ["nhl", 4393055],
    "Cale Makar (NHL)": ["nhl", 4233563],
    "Caleb Desnoyers (NHL)": ["nhl", 5291936],
    "Caleb Douglas (NFL)": ["nfl", 4869645],
    "Caleb Durbin (MLB)": ["mlb", 5007615],
    "Caleb Houstan (NBA)": ["nba", 4433623],
    "Caleb Love (NBA)": ["nba", 4433144],
    "Caleb Malhotra (NHL)": ["nhl", 5361656],
    "Caleb Martin (NBA)": ["nba", 3138160],
    "Caleb Williams (NFL)": ["nfl", 4431611],
    "Caleb Wilson (NBA)": ["nba", 5095151],
    "Calum Ritchie (NHL)": ["nhl", 5149210],
    "Calvin Austin III (NFL)": ["nfl", 4243389],
    "Calvin de Haan (NHL)": ["nhl", 5266],
    "Calvin Faucher (MLB)": ["mlb", 3978173],
    "Calvin Pickard (NHL)": ["nhl", 5524],
    "Calvin Ridley (NFL)": ["nfl", 3925357],
    "Cam Christie (NBA)": ["nba", 4845363],
    "Cam Fowler (NHL)": ["nhl", 5495],
    "Cam Little (NFL)": ["nfl", 4686361],
    "Cam Reddish (NBA)": ["nba", 4395627],
    "Cam Schlittler (MLB)": ["mlb", 5134581],
    "Cam Skattebo (NFL)": ["nfl", 4696981],
    "Cam Smith (MLB)": ["mlb", 5080766],
    "Cam Spencer (NBA)": ["nba", 4433083],
    "Cam Talbot (NHL)": ["nhl", 5734],
    "Cam Thomas (NBA)": ["nba", 4432174],
    "Cam Ward (NFL)": ["nfl", 4688380],
    "Cam Whitmore (NBA)": ["nba", 5105592],
    "Cam York (NHL)": ["nhl", 4565235],
    "Camden Brown (NFL)": ["nfl", 4808759],
    "Cameron Bairstow (NBA)": ["nba", 2528354],
    "Cameron Boozer (NBA)": ["nba", 5041935],
    "Cameron Carr (NBA)": ["nba", 5113969],
    "Cameron Dicker (NFL)": ["nfl", 4362081],
    "Cameron Hughes (NHL)": ["nhl", 3942461],
    "Cameron Johnson (NBA)": ["nba", 3138196],
    "Cameron Latu (NFL)": ["nfl", 4372026],
    "Cameron Oliver (NBA)": ["nba", 3928275],
    "Cameron Payne (NBA)": ["nba", 3064230],
    "Cameron Reynolds (NBA)": ["nba", 3057240],
    "Camilo Doval (MLB)": ["mlb", 41337],
    "Caris LeVert (NBA)": ["nba", 2991043],
    "Carlos Correa (MLB)": ["mlb", 32653],
    "Carlos Cortes (MLB)": ["mlb", 41595],
    "Carlos Estevez (MLB)": ["mlb", 34861],
    "Carlos Lagrange (MLB)": ["mlb", 5201825],
    "Carlos Narvaez (MLB)": ["mlb", 5012120],
    "Carlos Rodon (MLB)": ["mlb", 33696],
    "Carmen Mlodzinski (MLB)": ["mlb", 4298378],
    "Carnell Tate (NFL)": ["nfl", 4871023],
    "Carsen Ryan (NFL)": ["nfl", 4685540],
    "Carson Beck (NFL)": ["nfl", 4430841],
    "Carson Benge (MLB)": ["mlb", 4925604],
    "Carson Carels (NHL)": ["nhl", 5361654],
    "Carson Cooper (NBA)": ["nba", 5105817],
    "Carson Kelly (MLB)": ["mlb", 32797],
    "Carson Steele (NFL)": ["nfl", 4714365],
    "Carson Wentz (NFL)": ["nfl", 2573079],
    "Carter Bear (NHL)": ["nhl", 5291949],
    "Carter Bryant (NBA)": ["nba", 5061568],
    "Carter Hart (NHL)": ["nhl", 4064582],
    "Carter Jensen (MLB)": ["mlb", 4917812],
    "Carter Verhaeghe (NHL)": ["nhl", 3042088],
    "Carter Yakemchuk (NHL)": ["nhl", 5216868],
    "Case Keenum (NFL)": ["nfl", 15168],
    "Casey Cizikas (NHL)": ["nhl", 5262],
    "Casey DeSmith (NHL)": ["nhl", 3025540],
    "Casey Mittelstadt (NHL)": ["nhl", 4233575],
    "Casey Mize (MLB)": ["mlb", 41167],
    "Casey Schmitt (MLB)": ["mlb", 4301949],
    "Cason Wallace (NBA)": ["nba", 4683692],
    "Cat Barber (NBA)": ["nba", 3059266],
    "Cayden Lindstrom (NHL)": ["nhl", 5216859],
    "Ceddanne Rafaela (MLB)": ["mlb", 4987382],
    "Cedric Coward (NBA)": ["nba", 4903027],
    "Cedric Mullins (MLB)": ["mlb", 35578],
    "Cedric Tillman (NFL)": ["nfl", 4369863],
    "Cedrick Wilson Jr. (NFL)": ["nfl", 4036335],
    "CeeDee Lamb (NFL)": ["nfl", 4241389],
    "Cesar Perdomo (MLB)": ["mlb", 5271881],
    "Chad Patrick (MLB)": ["mlb", 5131708],
    "Chad Ryland (NFL)": ["nfl", 4363538],
    "Chance Comanche (NBA)": ["nba", 3907526],
    "Chandler Brayboy (NFL)": ["nfl", 4573243],
    "Chandler Simpson (MLB)": ["mlb", 4679983],
    "Chandler Stephenson (NHL)": ["nhl", 3067858],
    "Chaney Johnson (NBA)": ["nba", 5174655],
    "Charle-Edouard D'Astous (NHL)": ["nhl", 4588175],
    "Charles Bassey (NBA)": ["nba", 4397886],
    "Charles Cooke (NBA)": ["nba", 2988387],
    "Charlie Condon (MLB)": ["mlb", 5033089],
    "Charlie Coyle (NHL)": ["nhl", 2555315],
    "Charlie Jones (NFL)": ["nfl", 4257188],
    "Charlie Kolar (NFL)": ["nfl", 4241263],
    "Charlie Lindgren (NHL)": ["nhl", 3095975],
    "Charlie McAvoy (NHL)": ["nhl", 3988803],
    "Charlie Smyth (NFL)": ["nfl", 5208518],
    "Charlie Woerner (NFL)": ["nfl", 4035020],
    "Chase Brown (NFL)": ["nfl", 4362238],
    "Chase Burns (MLB)": ["mlb", 4927516],
    "Chase DeLauter (MLB)": ["mlb", 4619649],
    "Chase Dollander (MLB)": ["mlb", 4719068],
    "Chase Edmonds (NFL)": ["nfl", 3119195],
    "Chase McLaughlin (NFL)": ["nfl", 3150744],
    "Chase Meidroth (MLB)": ["mlb", 5136929],
    "Chase Reid (NHL)": ["nhl", 5361653],
    "Chaundee Brown Jr. (NBA)": ["nba", 4278045],
    "Chaz Lanier (NBA)": ["nba", 4700852],
    "Chet Holmgren (NBA)": ["nba", 4433255],
    "Chig Okonkwo (NFL)": ["nfl", 4360635],
    "Chimere Dike (NFL)": ["nfl", 4431268],
    "Chinanu Onuaku (NBA)": ["nba", 3147366],
    "Chris Bassitt (MLB)": ["mlb", 33148],
    "Chris Bell (NFL)": ["nfl", 4869961],
    "Chris Blair (NFL)": ["nfl", 4369886],
    "Chris Boswell (NFL)": ["nfl", 17372],
    "Chris Boucher (NBA)": ["nba", 3948153],
    "Chris Brazzell II (NFL)": ["nfl", 5091739],
    "Chris Brooks (NFL)": ["nfl", 3149687],
    "Chris Cenac Jr. (NBA)": ["nba", 5142621],
    "Chris Collier (NFL)": ["nfl", 4698191],
    "Chris Godwin Jr. (NFL)": ["nfl", 3116165],
    "Chris Johnson (NBA)": ["nba", 2325975],
    "Chris Kreider (NHL)": ["nhl", 5833],
    "Chris Kunitz (NHL)": ["nhl", 2179],
    "Chris Livingston (NBA)": ["nba", 4433622],
    "Chris Manhertz (NFL)": ["nfl", 2531358],
    "Chris Manon (NBA)": ["nba", 4702972],
    "Chris Moore (NFL)": ["nfl", 2576581],
    "Chris Olave (NFL)": ["nfl", 4361370],
    "Chris Paul (NBA)": ["nba", 2779],
    "Chris Rodriguez Jr. (NFL)": ["nfl", 4362619],
    "Chris Sale (MLB)": ["mlb", 30948],
    "Chris Tanev (NHL)": ["nhl", 5592],
    "Chris Youngblood (NBA)": ["nba", 4706557],
    "Christian Anderson (NBA)": ["nba", 5060701],
    "Christian Braun (NBA)": ["nba", 4431767],
    "Christian Dvorak (NHL)": ["nhl", 3115035],
    "Christian Encarnacion-Strand (MLB)": ["mlb", 5012106],
    "Christian Kirk (NFL)": ["nfl", 3895856],
    "Christian Koloko (NBA)": ["nba", 4431778],
    "Christian Koss (MLB)": ["mlb", 4109031],
    "Christian McCaffrey (NFL)": ["nfl", 3117251],
    "Christian Scott (MLB)": ["mlb", 4414215],
    "Christian Vazquez (MLB)": ["mlb", 31389],
    "Christian Walker (MLB)": ["mlb", 32758],
    "Christian Watson (NFL)": ["nfl", 4248528],
    "Christian Wood (NBA)": ["nba", 3058254],
    "Christian Yelich (MLB)": ["mlb", 31283],
    "Christopher Dunn (NFL)": ["nfl", 4361665],
    "Chuba Hubbard (NFL)": ["nfl", 4241416],
    "Chucky Hepburn (NBA)": ["nba", 4590360],
    "Chuma Okeke (NBA)": ["nba", 4278052],
    "CJ Abrams (MLB)": ["mlb", 42402],
    "CJ Daniels (NFL)": ["nfl", 4605951],
    "CJ Donaldson (NFL)": ["nfl", 5081999],
    "CJ McCollum (NBA)": ["nba", 2490149],
    "CJ Williams (NFL)": ["nfl", 5085024],
    "Clarke Schmidt (MLB)": ["mlb", 41085],
    "Claude Giroux (NHL)": ["nhl", 3775],
    "Clay Holmes (MLB)": ["mlb", 32827],
    "Clay Stevenson (NHL)": ["nhl", 5104602],
    "Clayton Beeter (MLB)": ["mlb", 4313143],
    "Clayton Keller (NHL)": ["nhl", 4024857],
    "Clayton Tune (NFL)": ["nfl", 4360175],
    "Cleanthony Early (NBA)": ["nba", 2991227],
    "Cliff Alexander (NBA)": ["nba", 3133600],
    "Clint Capela (NBA)": ["nba", 3102529],
    "Coby Mayo (MLB)": ["mlb", 4683371],
    "Coby White (NBA)": ["nba", 4395651],
    "Cody Bellinger (MLB)": ["mlb", 33912],
    "Cody Bradford (MLB)": ["mlb", 4142539],
    "Cody Ceci (NHL)": ["nhl", 2976843],
    "Cody Demps (NBA)": ["nba", 2994416],
    "Cody Franson (NHL)": ["nhl", 3422],
    "Cody Glass (NHL)": ["nhl", 4233568],
    "Cody McLeod (NHL)": ["nhl", 3530],
    "Cody Ponce (MLB)": ["mlb", 34999],
    "Cody Schrader (NFL)": ["nfl", 4391845],
    "Cody White (NFL)": ["nfl", 4241983],
    "Cody Williams (NBA)": ["nba", 4895758],
    "Colbie Young (NFL)": ["nfl", 5092508],
    "Colby Jones (NBA)": ["nba", 4433378],
    "Colby Parkinson (NFL)": ["nfl", 4242557],
    "Cole Anthony (NBA)": ["nba", 4432809],
    "Cole Carrigg (MLB)": ["mlb", 5149102],
    "Cole Caufield (NHL)": ["nhl", 4565236],
    "Cole Eiserman (NHL)": ["nhl", 5216888],
    "Cole Hutson (NHL)": ["nhl", 5216918],
    "Cole Kmet (NFL)": ["nfl", 4258595],
    "Cole Knuble (NHL)": ["nhl", 5188341],
    "Cole Payton (NFL)": ["nfl", 4879250],
    "Cole Perfetti (NHL)": ["nhl", 4697392],
    "Cole Ragans (MLB)": ["mlb", 41054],
    "Cole Reinhardt (NHL)": ["nhl", 4894702],
    "Cole Sillinger (NHL)": ["nhl", 4874725],
    "Cole Swider (NBA)": ["nba", 4397134],
    "Cole Young (MLB)": ["mlb", 5080641],
    "Coleman Owen (NFL)": ["nfl", 4578436],
    "Colin Castleton (NBA)": ["nba", 4397204],
    "Colin Rea (MLB)": ["mlb", 33950],
    "Collin Gillespie (NBA)": ["nba", 4278585],
    "Collin Graf (NHL)": ["nhl", 5136607],
    "Collin Murray-Boyles (NBA)": ["nba", 5093267],
    "Collin Sexton (NBA)": ["nba", 4277811],
    "Colson Montgomery (MLB)": ["mlb", 4872685],
    "Colson Yankoff (NFL)": ["nfl", 4361088],
    "Colston Loveland (NFL)": ["nfl", 4723086],
    "Colt Emerson (MLB)": ["mlb", 5149068],
    "Colt Keith (MLB)": ["mlb", 4683384],
    "Colten Ellis (NHL)": ["nhl", 4736758],
    "Colton Cowser (MLB)": ["mlb", 4416990],
    "Colton Dach (NHL)": ["nhl", 4874940],
    "Colton Parayko (NHL)": ["nhl", 3069341],
    "Colton Sissons (NHL)": ["nhl", 2993474],
    "Connelly Early (MLB)": ["mlb", 4863321],
    "Connor Bedard (NHL)": ["nhl", 5149125],
    "Connor Brown (NHL)": ["nhl", 3067951],
    "Connor Clifton (NHL)": ["nhl", 3042191],
    "Connor Dewar (NHL)": ["nhl", 4588004],
    "Connor Hellebuyck (NHL)": ["nhl", 3020225],
    "Connor Heyward (NFL)": ["nfl", 4241961],
    "Connor Ingram (NHL)": ["nhl", 4063522],
    "Connor Mackey (NHL)": ["nhl", 4319927],
    "Connor McDavid (NHL)": ["nhl", 3895074],
    "Connor McMichael (NHL)": ["nhl", 4565246],
    "Connor Murphy (NHL)": ["nhl", 2562618],
    "Connor Norby (MLB)": ["mlb", 4417606],
    "Connor Prielipp (MLB)": ["mlb", 4620001],
    "Connor Zary (NHL)": ["nhl", 4697407],
    "Conor Garland (NHL)": ["nhl", 3939718],
    "Conor Geekie (NHL)": ["nhl", 5080155],
    "Conor Timmins (NHL)": ["nhl", 4233868],
    "Cooper Flagg (NBA)": ["nba", 5041939],
    "Cooper Kupp (NFL)": ["nfl", 2977187],
    "Cooper Pratt (MLB)": ["mlb", 5149101],
    "Cooper Rush (NFL)": ["nfl", 2972515],
    "Corbin Burnes (MLB)": ["mlb", 39878],
    "Corbin Carroll (MLB)": ["mlb", 42404],
    "Cordarrelle Patterson (NFL)": ["nfl", 15807],
    "Corey Kiner (NFL)": ["nfl", 4431431],
    "Corey Kispert (NBA)": ["nba", 4280151],
    "Corey Perry (NHL)": ["nhl", 2273],
    "Corey Seager (MLB)": ["mlb", 32691],
    "Courtland Sutton (NFL)": ["nfl", 3128429],
    "Craig Porter Jr. (NBA)": ["nba", 4701233],
    "Craig Reynolds (NFL)": ["nfl", 4421446],
    "Cristian Javier (MLB)": ["mlb", 41261],
    "Cristiano Felicio (NBA)": ["nba", 3113587],
    "Cristopher Sanchez (MLB)": ["mlb", 42359],
    "Curtis Jones (NBA)": ["nba", 4898369],
    "Curtis Mead (MLB)": ["mlb", 42360],
    "Cutter Gauthier (NHL)": ["nhl", 5080145],
    "Cyrus Allen (NFL)": ["nfl", 4912218],
    "D'Andre Swift (NFL)": ["nfl", 4259545],
    "D'Angelo Russell (NBA)": ["nba", 3136776],
    "D'Ernest Johnson (NFL)": ["nfl", 3139602],
    "D'Onta Foreman (NFL)": ["nfl", 3125116],
    "D.J. Montgomery (NFL)": ["nfl", 4249030],
    "Daemon Hunt (NHL)": ["nhl", 4697711],
    "Daeqwon Plowden (NBA)": ["nba", 4279318],
    "Dailyn Swain (NBA)": ["nba", 4848625],
    "Dak Prescott (NFL)": ["nfl", 2577417],
    "Dakota Joshua (NHL)": ["nhl", 4588638],
    "Dalano Banton (NBA)": ["nba", 4397885],
    "Dalen Terry (NBA)": ["nba", 4433159],
    "Dalibor Dvorsky (NHL)": ["nhl", 5149178],
    "Dallas Goedert (NFL)": ["nfl", 3121023],
    "Dalton Kincaid (NFL)": ["nfl", 4385690],
    "Dalton Knecht (NBA)": ["nba", 4897943],
    "Dalton Rushing (MLB)": ["mlb", 4619839],
    "Dalton Schultz (NFL)": ["nfl", 3117256],
    "Dalvin Cook (NFL)": ["nfl", 3116593],
    "Dameon Pierce (NFL)": ["nfl", 4360238],
    "Damian Lillard (NBA)": ["nba", 6606],
    "Damien Inglis (NBA)": ["nba", 3102534],
    "Damien Martinez (NFL)": ["nfl", 4808830],
    "Damon Severson (NHL)": ["nhl", 3068087],
    "Dan Girardi (NHL)": ["nhl", 3423],
    "Dan Vladar (NHL)": ["nhl", 3942459],
    "Daniel Bellinger (NFL)": ["nfl", 4361516],
    "Daniel Carlson (NFL)": ["nfl", 3051909],
    "Daniel Diez (NBA)": ["nba", 3033042],
    "Daniel Duarte (MLB)": ["mlb", 41094],
    "Daniel Gafford (NBA)": ["nba", 4278049],
    "Daniel Jones (NFL)": ["nfl", 3917792],
    "Daniel Lynch IV (MLB)": ["mlb", 41227],
    "Daniel Palencia (MLB)": ["mlb", 4875225],
    "Daniel Schneemann (MLB)": ["mlb", 42001],
    "Daniel Theis (NBA)": ["nba", 2451037],
    "Daniil But (NHL)": ["nhl", 5149183],
    "Daniil Tarasov (NHL)": ["nhl", 4587994],
    "Danila Yurov (NHL)": ["nhl", 5080172],
    "Daniss Jenkins (NBA)": ["nba", 5107199],
    "Danny Taylor (NHL)": ["nhl", 3389],
    "Danny Wolf (NBA)": ["nba", 5107173],
    "Dansby Swanson (MLB)": ["mlb", 34895],
    "Dante Exum (NBA)": ["nba", 3102528],
    "Dante Pettis (NFL)": ["nfl", 3127306],
    "DaQuan Jeffries (NBA)": ["nba", 3913220],
    "Darcy Kuemper (NHL)": ["nhl", 2610321],
    "Dare Ogunbowale (NFL)": ["nfl", 2983509],
    "Dareke Young (NFL)": ["nfl", 4401805],
    "Dario Saric (NBA)": ["nba", 3032978],
    "Dariq Whitehead (NBA)": ["nba", 4432735],
    "Darius Acuff Jr. (NBA)": ["nba", 5142620],
    "Darius Cooper (NFL)": ["nfl", 4715355],
    "Darius Garland (NBA)": ["nba", 4396907],
    "Darius Slayton (NFL)": ["nfl", 3916945],
    "Darnell Mooney (NFL)": ["nfl", 4040655],
    "Darnell Nurse (NHL)": ["nhl", 3041997],
    "Darnell Washington (NFL)": ["nfl", 4430802],
    "DaRon Holmes II (NBA)": ["nba", 4433607],
    "Darren Raddysh (NHL)": ["nhl", 3149843],
    "Darren Waller (NFL)": ["nfl", 2576925],
    "Darrun Hilliard (NBA)": ["nba", 2578259],
    "Darryn Peterson (NBA)": ["nba", 5041955],
    "Daulton Varsho (MLB)": ["mlb", 40963],
    "Davante Adams (NFL)": ["nfl", 16800],
    "David Bednar (MLB)": ["mlb", 38303],
    "David Hamilton (MLB)": ["mlb", 42987],
    "David Jiricek (NHL)": ["nhl", 5080147],
    "David Jones Garcia (NBA)": ["nba", 4713010],
    "David Michineau (NBA)": ["nba", 4017875],
    "David Montgomery (NFL)": ["nfl", 4035538],
    "David Moore (NFL)": ["nfl", 4212909],
    "David Njoku (NFL)": ["nfl", 3123076],
    "David Pastrnak (NHL)": ["nhl", 3114778],
    "David Perron (NHL)": ["nhl", 3792],
    "David Peterson (MLB)": ["mlb", 40921],
    "David Reinbacher (NHL)": ["nhl", 5149157],
    "David Rittich (NHL)": ["nhl", 4063288],
    "David Roddy (NBA)": ["nba", 4593041],
    "David Sandlin (MLB)": ["mlb", 4960696],
    "David Schlemko (NHL)": ["nhl", 3774],
    "David Stockton (NBA)": ["nba", 2489664],
    "Davion Mitchell (NBA)": ["nba", 4278053],
    "Davis Allen (NFL)": ["nfl", 4426553],
    "Davis Martin (MLB)": ["mlb", 42823],
    "Davis Mills (NFL)": ["nfl", 4242546],
    "Dawson Knox (NFL)": ["nfl", 3930086],
    "Dawson Mercer (NHL)": ["nhl", 4697401],
    "Daxon Rudolph (NHL)": ["nhl", 5361655],
    "Day'Ron Sharpe (NBA)": ["nba", 4432194],
    "Daylen Lile (MLB)": ["mlb", 4917889],
    "De'Aaron Fox (NBA)": ["nba", 4066259],
    "De'Andre Hunter (NBA)": ["nba", 4065732],
    "De'Anthony Melton (NBA)": ["nba", 4066436],
    "De'Von Achane (NFL)": ["nfl", 4429160],
    "De'Zhaun Stribling (NFL)": ["nfl", 4710714],
    "Dean Kremer (MLB)": ["mlb", 38295],
    "Dean Wade (NBA)": ["nba", 3912848],
    "Deandre Ayton (NBA)": ["nba", 4278129],
    "DeAndre Carter (NFL)": ["nfl", 2580216],
    "DeAndre Daniels (NBA)": ["nba", 2578232],
    "DeAndre Hopkins (NFL)": ["nfl", 15795],
    "DeAndre Jordan (NBA)": ["nba", 3442],
    "Declan Carlile (NHL)": ["nhl", 5103825],
    "Dedniel Nunez (MLB)": ["mlb", 4717899],
    "Dee Bost (NBA)": ["nba", 2327630],
    "Deebo Samuel Sr. (NFL)": ["nfl", 3126486],
    "DeeJay Dallas (NFL)": ["nfl", 4240631],
    "Deion Burks (NFL)": ["nfl", 4683151],
    "DeJon Jarreau (NBA)": ["nba", 4066796],
    "Dejounte Murray (NBA)": ["nba", 3907497],
    "Delon Wright (NBA)": ["nba", 3064447],
    "DeMar DeRozan (NBA)": ["nba", 3978],
    "Demarcus Robinson (NFL)": ["nfl", 3043116],
    "DeMario Douglas (NFL)": ["nfl", 4427095],
    "Demond Claiborne (NFL)": ["nfl", 4832846],
    "Deneric Prince (NFL)": ["nfl", 4372526],
    "Deni Avdija (NBA)": ["nba", 4683021],
    "Dennis Hildeby (NHL)": ["nhl", 5174160],
    "Dennis Houston (NFL)": ["nfl", 4572786],
    "Dennis Santana (MLB)": ["mlb", 39801],
    "Dennis Schroder (NBA)": ["nba", 3032979],
    "Dennis Wideman (NHL)": ["nhl", 3017],
    "Denton Mateychuk (NHL)": ["nhl", 5080156],
    "Denver Barkey (NHL)": ["nhl", 5173105],
    "Denzel Boston (NFL)": ["nfl", 4832800],
    "Deonte Burton (NBA)": ["nba", 3059358],
    "Dereck Lively II (NBA)": ["nba", 4683688],
    "Derek Carr (NFL)": ["nfl", 16757],
    "Derek Dorsett (NHL)": ["nhl", 3641],
    "Derik Queen (NBA)": ["nba", 4869780],
    "Derius Davis (NFL)": ["nfl", 4362477],
    "Derrick Henry (NFL)": ["nfl", 3043078],
    "Derrick Jones Jr. (NBA)": ["nba", 3936099],
    "Derrick Walton Jr. (NBA)": ["nba", 3056273],
    "Derrick White (NBA)": ["nba", 3078576],
    "Deshaun Watson (NFL)": ["nfl", 3122840],
    "Desmond Bane (NBA)": ["nba", 4066320],
    "Desmond Ridder (NFL)": ["nfl", 4239086],
    "Deuce Vaughn (NFL)": ["nfl", 4431453],
    "DeVaughn Akoon-Purcell (NBA)": ["nba", 3138256],
    "Devaughn Vele (NFL)": ["nfl", 4569559],
    "Deven Thompkins (NFL)": ["nfl", 4374187],
    "Devin Booker (NBA)": ["nba", 3136193],
    "Devin Cannady (NBA)": ["nba", 3906977],
    "Devin Carter (NBA)": ["nba", 4433188],
    "Devin Cooley (NHL)": ["nhl", 4319911],
    "Devin Duvernay (NFL)": ["nfl", 4039050],
    "Devin Leary (NFL)": ["nfl", 4361653],
    "Devin Neal (NFL)": ["nfl", 4682652],
    "Devin Robinson (NBA)": ["nba", 3137798],
    "Devin Singletary (NFL)": ["nfl", 4040761],
    "Devin Vassell (NBA)": ["nba", 4395630],
    "Devin Williams (MLB)": ["mlb", 33224],
    "Devon Dotson (NBA)": ["nba", 4397016],
    "Devon Levi (NHL)": ["nhl", 4894487],
    "Devon Toews (NHL)": ["nhl", 3096249],
    "DeVonta Smith (NFL)": ["nfl", 4241478],
    "Devontez Walker (NFL)": ["nfl", 4696882],
    "Dewayne Dedmon (NBA)": ["nba", 2580913],
    "DeWayne McBride (NFL)": ["nfl", 4430388],
    "Diamond Stone (NBA)": ["nba", 3924880],
    "Didier Fuentes (MLB)": ["mlb", 5291189],
    "Dillon Bell (NFL)": ["nfl", 4712579],
    "Dillon Brooks (NBA)": ["nba", 3155526],
    "Dillon Dingler (MLB)": ["mlb", 4345620],
    "Dillon Gabriel (NFL)": ["nfl", 4427238],
    "Dillon Jones (NBA)": ["nba", 4702159],
    "Dillon Mitchell (NBA)": ["nba", 5106283],
    "DJ Giddens (NFL)": ["nfl", 4874509],
    "DJ Herman (NFL)": ["nfl", 4685116],
    "DJ Herz (MLB)": ["mlb", 4917686],
    "DJ Moore (NFL)": ["nfl", 3915416],
    "DJ Stephens (NBA)": ["nba", 2489563],
    "DK Metcalf (NFL)": ["nfl", 4047650],
    "DL Hall (MLB)": ["mlb", 41018],
    "Dmitri Simashev (NHL)": ["nhl", 5149158],
    "Dmitri Voronkov (NHL)": ["nhl", 4915856],
    "Dmitry Kulikov (NHL)": ["nhl", 5328],
    "Dmitry Orlov (NHL)": ["nhl", 5646],
    "Dohnte Meyers (NFL)": ["nfl", 4384852],
    "Domantas Sabonis (NBA)": ["nba", 3155942],
    "Dominic Canzone (MLB)": ["mlb", 4345621],
    "Dominic James (NHL)": ["nhl", 4997033],
    "Dominic Smith (MLB)": ["mlb", 33218],
    "Dominic Zvada (NFL)": ["nfl", 5082424],
    "Dominick Barlow (NBA)": ["nba", 4870562],
    "Donovan Clingan (NBA)": ["nba", 5105565],
    "Donovan Edwards (NFL)": ["nfl", 4431536],
    "Donovan Mitchell (NBA)": ["nba", 3908809],
    "Donovan Walton (MLB)": ["mlb", 37232],
    "Dont'e Thornton Jr. (NFL)": ["nfl", 4432775],
    "Donta Hall (NBA)": ["nba", 3907408],
    "Dontayvion Wicks (NFL)": ["nfl", 4428850],
    "Donte DiVincenzo (NBA)": ["nba", 3934673],
    "Donte Grantham (NBA)": ["nba", 3129674],
    "Dorian Finney-Smith (NBA)": ["nba", 2578185],
    "Doug McDermott (NBA)": ["nba", 2528588],
    "Dougie Hamilton (NHL)": ["nhl", 2562605],
    "Drake Baldwin (MLB)": ["mlb", 4810190],
    "Drake Batherson (NHL)": ["nhl", 4271734],
    "Drake Dabney (NFL)": ["nfl", 4429466],
    "Drake London (NFL)": ["nfl", 4426502],
    "Drake Maye (NFL)": ["nfl", 4431452],
    "Drake Powell (NBA)": ["nba", 5037873],
    "Draymond Green (NBA)": ["nba", 6589],
    "Drew Allar (NFL)": ["nfl", 4714771],
    "Drew Anderson (MLB)": ["mlb", 41125],
    "Drew Commesso (NHL)": ["nhl", 4697450],
    "Drew Doughty (NHL)": ["nhl", 3995],
    "Drew Eubanks (NBA)": ["nba", 3914285],
    "Drew Gordon (NBA)": ["nba", 2327465],
    "Drew Helleson (NHL)": ["nhl", 4565270],
    "Drew Lock (NFL)": ["nfl", 3924327],
    "Drew O'Connor (NHL)": ["nhl", 4712146],
    "Drew Ogletree (NFL)": ["nfl", 4722908],
    "Drew Peterson (NBA)": ["nba", 4397689],
    "Drew Rasmussen (MLB)": ["mlb", 42584],
    "Drew Sample (NFL)": ["nfl", 3127310],
    "Drew Stevens (NFL)": ["nfl", 5081335],
    "Drew Timme (NBA)": ["nba", 4431695],
    "Dru Smith (NBA)": ["nba", 4066993],
    "Duncan Robinson (NBA)": ["nba", 3157465],
    "Duop Reath (NBA)": ["nba", 4066268],
    "Durham Smythe (NFL)": ["nfl", 3052897],
    "Dustin Harris (MLB)": ["mlb", 4917924],
    "Dustin Hopkins (NFL)": ["nfl", 15965],
    "Dustin May (MLB)": ["mlb", 40937],
    "Dustin Wolf (NHL)": ["nhl", 4587952],
    "Dwight Buycks (NBA)": ["nba", 6503],
    "Dwight Powell (NBA)": ["nba", 2531367],
    "Dyami Brown (NFL)": ["nfl", 4361577],
    "Dylan Beavers (MLB)": ["mlb", 4959037],
    "Dylan Cardwell (NBA)": ["nba", 4433174],
    "Dylan Cease (MLB)": ["mlb", 34943],
    "Dylan Cozens (NHL)": ["nhl", 4565228],
    "Dylan Crews (MLB)": ["mlb", 4719511],
    "Dylan DeMelo (NHL)": ["nhl", 2590861],
    "Dylan Dodd (MLB)": ["mlb", 4416462],
    "Dylan Garand (NHL)": ["nhl", 4697705],
    "Dylan Guenther (NHL)": ["nhl", 4874723],
    "Dylan Harper (NBA)": ["nba", 5037871],
    "Dylan Holloway (NHL)": ["nhl", 4697397],
    "Dylan Larkin (NHL)": ["nhl", 3114755],
    "Dylan Laube (NFL)": ["nfl", 4366963],
    "Dylan Lee (MLB)": ["mlb", 41455],
    "Dylan Samberg (NHL)": ["nhl", 4233878],
    "Dylan Sampson (NFL)": ["nfl", 5081397],
    "Dylan Strome (NHL)": ["nhl", 3899933],
    "Dyson Daniels (NBA)": ["nba", 4869342],
    "Easton Cowan (NHL)": ["nhl", 5149211],
    "Easton Stick (NFL)": ["nfl", 3120590],
    "Ebuka Okorie (NBA)": ["nba", 5258459],
    "Eddy Pineiro (NFL)": ["nfl", 4034949],
    "Edmundo Sosa (MLB)": ["mlb", 33809],
    "Eduard Bazardo (MLB)": ["mlb", 41939],
    "Eduardo Rodriguez (MLB)": ["mlb", 32675],
    "Eduardo Valencia (MLB)": ["mlb", 5133392],
    "Edward Cabrera (MLB)": ["mlb", 40944],
    "Edwin Diaz (MLB)": ["mlb", 35394],
    "Edwin Uceta (MLB)": ["mlb", 41308],
    "Edy Tavares (NBA)": ["nba", 3033031],
    "Eeli Tolvanen (NHL)": ["nhl", 4233720],
    "Eetu Luostarinen (NHL)": ["nhl", 4233877],
    "Efton Chism III (NFL)": ["nfl", 4695193],
    "Egor Chinakhov (NHL)": ["nhl", 4697404],
    "Egor Demin (NBA)": ["nba", 5175643],
    "Egor Zamula (NHL)": ["nhl", 4392268],
    "Eli Heidenreich (NFL)": ["nfl", 5081508],
    "Eli John Ndiaye (NBA)": ["nba", 5144071],
    "Eli Raridon (NFL)": ["nfl", 4831959],
    "Eli Stowers (NFL)": ["nfl", 4431574],
    "Eli Willits (MLB)": ["mlb", 5293140],
    "Elias Lindholm (NHL)": ["nhl", 3041994],
    "Elias N. Pettersson (NHL)": ["nhl", 5238086],
    "Elias Pettersson (NHL)": ["nhl", 4233566],
    "Elic Ayomanor (NFL)": ["nfl", 4883647],
    "Elijah Arroyo (NFL)": ["nfl", 4678006],
    "Elijah Harkless (NBA)": ["nba", 4397449],
    "Elijah Higgins (NFL)": ["nfl", 4426844],
    "Elijah Mitchell (NFL)": ["nfl", 4241555],
    "Elijah Moore (NFL)": ["nfl", 4372414],
    "Elijah Sarratt (NFL)": ["nfl", 5088338],
    "Elly De La Cruz (MLB)": ["mlb", 4917694],
    "Elmer Rodriguez (MLB)": ["mlb", 5194637],
    "Elmer Soderblom (NHL)": ["nhl", 5075840],
    "Elvis Alvarado (MLB)": ["mlb", 42211],
    "Elvis Merzlikins (NHL)": ["nhl", 3151038],
    "Emanuel Sharp (NBA)": ["nba", 5106058],
    "Emanuel Wilson (NFL)": ["nfl", 4887558],
    "Emari Demercado (NFL)": ["nfl", 4362478],
    "Emeka Egbuka (NFL)": ["nfl", 4567750],
    "Emerson Hancock (MLB)": ["mlb", 4297897],
    "Emil Andrae (NHL)": ["nhl", 4697457],
    "Emil Heineman (NHL)": ["nhl", 4697447],
    "Emilio Pagan (MLB)": ["mlb", 33403],
    "Emmanuel Henderson Jr. (NFL)": ["nfl", 4685381],
    "Emmanuel Rodriguez (MLB)": ["mlb", 5017049],
    "Emmet Sheehan (MLB)": ["mlb", 4417806],
    "Emmett Johnson (NFL)": ["nfl", 4832955],
    "Emmitt Finnie (NHL)": ["nhl", 5188599],
    "Emoni Bates (NBA)": ["nba", 4433620],
    "Endy Rodriguez (MLB)": ["mlb", 4712767],
    "Enrique Freeman (NBA)": ["nba", 4592699],
    "Enrique Hernandez (MLB)": ["mlb", 31358],
    "Equanimeous St. Brown (NFL)": ["nfl", 3932442],
    "Eric Atkins (NBA)": ["nba", 2531045],
    "Eric Gordon (NBA)": ["nba", 3431],
    "Eric Gray (NFL)": ["nfl", 4570561],
    "Eric Griffin (NBA)": ["nba", 2528646],
    "Eric Lauer (MLB)": ["mlb", 39915],
    "Eric Mika (NBA)": ["nba", 3065284],
    "Eric Moreland (NBA)": ["nba", 2531352],
    "Eric Pohlkamp (NHL)": ["nhl", 5188651],
    "Eric Robinson (NHL)": ["nhl", 4319879],
    "Eric Saubert (NFL)": ["nfl", 2975863],
    "Erick All Jr. (NFL)": ["nfl", 4427834],
    "Erick Fedde (MLB)": ["mlb", 33793],
    "Erik Cernak (NHL)": ["nhl", 3904178],
    "Erik Gudbranson (NHL)": ["nhl", 5503],
    "Erik Gustafsson (NHL)": ["nhl", 3891922],
    "Erik Haula (NHL)": ["nhl", 2593311],
    "Erik Johnson (NHL)": ["nhl", 3649],
    "Erik Karlsson (NHL)": ["nhl", 5164],
    "Erik McCree (NBA)": ["nba", 2994165],
    "Erik Miller (MLB)": ["mlb", 4152950],
    "Erik Sabrowski (MLB)": ["mlb", 5194333],
    "Erik Tolman (MLB)": ["mlb", 5337128],
    "Ernie Clement (MLB)": ["mlb", 41287],
    "Esa Lindell (NHL)": ["nhl", 3069352],
    "Esmerlyn Valdez (MLB)": ["mlb", 5137200],
    "Esteury Ruiz (MLB)": ["mlb", 39680],
    "Ethan Holliday (MLB)": ["mlb", 5293136],
    "Ethan Pecko (MLB)": ["mlb", 4944276],
    "Ethan Salas (MLB)": ["mlb", 5124004],
    "Ethan Thompson (NBA)": ["nba", 4278516],
    "Ethen Frank (NHL)": ["nhl", 4996093],
    "Eugenio Suarez (MLB)": ["mlb", 32367],
    "Eury Perez (MLB)": ["mlb", 4917854],
    "Evan Bouchard (NHL)": ["nhl", 4352722],
    "Evan Carter (MLB)": ["mlb", 4917921],
    "Evan Engram (NFL)": ["nfl", 3051876],
    "Evan Hull (NFL)": ["nfl", 4569609],
    "Evan McPherson (NFL)": ["nfl", 4360234],
    "Evan Mobley (NBA)": ["nba", 4432158],
    "Evan Phillips (MLB)": ["mlb", 37911],
    "Evan Rodrigues (NHL)": ["nhl", 3648008],
    "Evander Kane (NHL)": ["nhl", 5251],
    "Evgeni Malkin (NHL)": ["nhl", 3124],
    "Ezekiel Elliott (NFL)": ["nfl", 3051392],
    "Ezequiel Duran (MLB)": ["mlb", 42457],
    "Ezequiel Tovar (MLB)": ["mlb", 4905919],
    "Fabian Zetterlund (NHL)": ["nhl", 4587837],
    "Facundo Campazzo (NBA)": ["nba", 2968334],
    "Fedor Svechkov (NHL)": ["nhl", 4874736],
    "Felix Bautista (MLB)": ["mlb", 4905859],
    "Felix Okpara (NBA)": ["nba", 5105841],
    "Fernando Cruz (MLB)": ["mlb", 34068],
    "Fernando Mendoza (NFL)": ["nfl", 4837248],
    "Fernando Tatis Jr. (MLB)": ["mlb", 35983],
    "Feron Hunt (NBA)": ["nba", 4396638],
    "Filip Chytil (NHL)": ["nhl", 4233643],
    "Filip Forsberg (NHL)": ["nhl", 2968772],
    "Filip Gustavsson (NHL)": ["nhl", 4272674],
    "Filip Hallander (NHL)": ["nhl", 4588331],
    "Filip Hronek (NHL)": ["nhl", 4063607],
    "Florian Xhekaj (NHL)": ["nhl", 5188457],
    "Foster Griffin (MLB)": ["mlb", 33773],
    "Foster Moreau (NFL)": ["nfl", 3843945],
    "Framber Valdez (MLB)": ["mlb", 36581],
    "Francisco Alvarez (MLB)": ["mlb", 41253],
    "Francisco Lindor (MLB)": ["mlb", 32129],
    "Frank Gore Jr. (NFL)": ["nfl", 4429805],
    "Frank Nazar (NHL)": ["nhl", 5080157],
    "Frank Vatrano (NHL)": ["nhl", 3527554],
    "Franklin Arias (MLB)": ["mlb", 5273064],
    "Franz Wagner (NBA)": ["nba", 4566434],
    "Fraser Minten (NHL)": ["nhl", 5080207],
    "Fred VanVleet (NBA)": ["nba", 2991230],
    "Freddie Freeman (MLB)": ["mlb", 30193],
    "Freddie Gillespie (NBA)": ["nba", 4277886],
    "Freddy Peralta (MLB)": ["mlb", 39825],
    "Frederic Brunet (NHL)": ["nhl", 5103647],
    "Frederick Gaudreau (NHL)": ["nhl", 3149649],
    "Frederik Andersen (NHL)": ["nhl", 2517899],
    "Gabe Davis (NFL)": ["nfl", 4243537],
    "Gabe Perreault (NHL)": ["nhl", 5149204],
    "Gabe Speier (MLB)": ["mlb", 40327],
    "Gabe Vincent (NBA)": ["nba", 3137259],
    "Gabriel Hughes (MLB)": ["mlb", 4634930],
    "Gabriel Landeskog (NHL)": ["nhl", 2562609],
    "Gabriel Moreno (MLB)": ["mlb", 42464],
    "Gabriel Vilardi (NHL)": ["nhl", 4233583],
    "Gage Goncalves (NHL)": ["nhl", 4697470],
    "Gage Jump (MLB)": ["mlb", 5023852],
    "Gardner Minshew II (NFL)": ["nfl", 4038524],
    "Garnet Hathaway (NHL)": ["nhl", 3149633],
    "Garrett Cleavinger (MLB)": ["mlb", 36429],
    "Garrett Crochet (MLB)": ["mlb", 4297835],
    "Garrett Mitchell (MLB)": ["mlb", 4313442],
    "Garrett Nussmeier (NFL)": ["nfl", 4567747],
    "Garrett Temple (NBA)": ["nba", 4023],
    "Garrett Whitlock (MLB)": ["mlb", 39674],
    "Garrett Wilson (NFL)": ["nfl", 4569618],
    "Garrison Mathews (NBA)": ["nba", 3913180],
    "Gary Brightwell (NFL)": ["nfl", 4245645],
    "Gary Harris (NBA)": ["nba", 2999547],
    "Gary Payton II (NBA)": ["nba", 3134903],
    "Gary Sanchez (MLB)": ["mlb", 31095],
    "Gary Trent Jr. (NBA)": ["nba", 4277843],
    "Gavin Bartholomew (NFL)": ["nfl", 4708049],
    "Gavin Brindley (NHL)": ["nhl", 5136614],
    "Gavin McKenna (NHL)": ["nhl", 5342529],
    "Gavin Sheets (MLB)": ["mlb", 40700],
    "Gavin Williams (MLB)": ["mlb", 4345076],
    "Geno Smith (NFL)": ["nfl", 15864],
    "George Holani (NFL)": ["nfl", 4429835],
    "George Kirby (MLB)": ["mlb", 42406],
    "George Kittle (NFL)": ["nfl", 3040151],
    "George Klassen (MLB)": ["mlb", 5134517],
    "George Lombard Jr. (MLB)": ["mlb", 5149070],
    "George Pickens (NFL)": ["nfl", 4426354],
    "George Soriano (MLB)": ["mlb", 4917836],
    "George Springer (MLB)": ["mlb", 32078],
    "Georges Niang (NBA)": ["nba", 2990969],
    "Georgios Papagiannis (NBA)": ["nba", 4017846],
    "Geraldo Perdomo (MLB)": ["mlb", 41355],
    "Germie Bernard (NFL)": ["nfl", 4685261],
    "Gerrit Cole (MLB)": ["mlb", 32081],
    "GG Jackson (NBA)": ["nba", 5105550],
    "Gian Clavell (NBA)": ["nba", 3137694],
    "Giancarlo Stanton (MLB)": ["mlb", 30583],
    "Giannis Antetokounmpo (NBA)": ["nba", 3032977],
    "Gleb Pugachyov (NHL)": ["nhl", 5361716],
    "Glenn Gawdin (NHL)": ["nhl", 3942352],
    "Gleyber Torres (MLB)": ["mlb", 33804],
    "Goga Bitadze (NBA)": ["nba", 4348700],
    "Gordon Graceffo (MLB)": ["mlb", 5123582],
    "Gradey Dick (NBA)": ["nba", 5106258],
    "Graham Ashcraft (MLB)": ["mlb", 4084179],
    "Graham Gano (NFL)": ["nfl", 12460],
    "Graham Ike (NBA)": ["nba", 4703396],
    "Grant Calcaterra (NFL)": ["nfl", 4241374],
    "Grant Holmes (MLB)": ["mlb", 33840],
    "Grant Taylor (MLB)": ["mlb", 4927630],
    "Grant Williams (NBA)": ["nba", 4066218],
    "Grayson Allen (NBA)": ["nba", 3135045],
    "Grayson Rodriguez (MLB)": ["mlb", 41196],
    "Greg Desrosiers Jr. (NFL)": ["nfl", 4691889],
    "Greg Dortch (NFL)": ["nfl", 4037235],
    "Greg Dulcich (NFL)": ["nfl", 4367209],
    "Greg Joseph (NFL)": ["nfl", 3975763],
    "Greg Whittington (NBA)": ["nba", 2594920],
    "Greg Zuerlein (NFL)": ["nfl", 14993],
    "Gregory Soto (MLB)": ["mlb", 39804],
    "Griffin Conine (MLB)": ["mlb", 41295],
    "Griffin Jax (MLB)": ["mlb", 42604],
    "Guerschon Yabusele (NBA)": ["nba", 4017844],
    "Gui Santos (NBA)": ["nba", 4997536],
    "Gunnar Helm (NFL)": ["nfl", 4686728],
    "Gunnar Henderson (MLB)": ["mlb", 42507],
    "Gunner Olszewski (NFL)": ["nfl", 4424106],
    "Gustav Forsling (NHL)": ["nhl", 3151784],
    "Hagen Smith (MLB)": ["mlb", 5023126],
    "Hampus Lindholm (NHL)": ["nhl", 2968818],
    "Hannes Steinbach (NBA)": ["nba", 5281370],
    "Hao-Yu Lee (MLB)": ["mlb", 5124113],
    "Harold Fannin Jr. (NFL)": ["nfl", 5083076],
    "Harrison Bader (MLB)": ["mlb", 35062],
    "Harrison Barnes (NBA)": ["nba", 6578],
    "Harrison Butker (NFL)": ["nfl", 3055899],
    "Harrison Ingram (NBA)": ["nba", 4433618],
    "Harrison Mevis (NFL)": ["nfl", 4574716],
    "Hassan Haskins (NFL)": ["nfl", 4372071],
    "Hayden Wesneski (MLB)": ["mlb", 42996],
    "Haynes King (NFL)": ["nfl", 4428993],
    "Haywood Highsmith (NBA)": ["nba", 4291678],
    "Hector Rodriguez (MLB)": ["mlb", 5122878],
    "Heliot Ramos (MLB)": ["mlb", 39642],
    "Hendon Hooker (NFL)": ["nfl", 4240858],
    "Hendrix Lapierre (NHL)": ["nhl", 4697405],
    "Henri Veesaar (NBA)": ["nba", 5105571],
    "Henry Bolte (MLB)": ["mlb", 5080756],
    "Herbert Jones (NBA)": ["nba", 4277813],
    "Heriberto Hernandez (MLB)": ["mlb", 42455],
    "Hogan Harris (MLB)": ["mlb", 41364],
    "Hollis Thompson (NBA)": ["nba", 6634],
    "Hollywood Brown (NFL)": ["nfl", 4241372],
    "Hugo Gonzalez (NBA)": ["nba", 5175647],
    "Hunter Brown (MLB)": ["mlb", 4717803],
    "Hunter Dickinson (NBA)": ["nba", 4432180],
    "Hunter Dobbins (MLB)": ["mlb", 4415836],
    "Hunter Gaddis (MLB)": ["mlb", 4187661],
    "Hunter Goodman (MLB)": ["mlb", 4416591],
    "Hunter Greene (MLB)": ["mlb", 39635],
    "Hunter Henry (NFL)": ["nfl", 3046439],
    "Hunter Long (NFL)": ["nfl", 4239944],
    "Hunter Luepke (NFL)": ["nfl", 4383396],
    "Hunter McDonald (NHL)": ["nhl", 5103725],
    "Hunter Renfrow (NFL)": ["nfl", 3135321],
    "Hunter Tyson (NBA)": ["nba", 4395620],
    "Hyeseong Kim (MLB)": ["mlb", 5134614],
    "Ian Clark (NBA)": ["nba", 2489785],
    "Ian Cole (NHL)": ["nhl", 4991],
    "Ian Happ (MLB)": ["mlb", 34945],
    "Ian Moore (NHL)": ["nhl", 5188523],
    "Ian Seymour (MLB)": ["mlb", 4669425],
    "Ian Thomas (NFL)": ["nfl", 4045305],
    "Igor Chernyshov (NHL)": ["nhl", 5216907],
    "Igor Shesterkin (NHL)": ["nhl", 3151297],
    "Ildemaro Vargas (MLB)": ["mlb", 32985],
    "Ilya Lyubushkin (NHL)": ["nhl", 4342107],
    "Ilya Mikheyev (NHL)": ["nhl", 4422415],
    "Ilya Protas (NHL)": ["nhl", 5229146],
    "Ilya Samsonov (NHL)": ["nhl", 3900505],
    "Ilya Solovyov (NHL)": ["nhl", 4697784],
    "Ilya Sorokin (NHL)": ["nhl", 3151981],
    "Immanuel Quickley (NBA)": ["nba", 4395724],
    "Irv Charles (NFL)": ["nfl", 3929636],
    "Isaac Guerendo (NFL)": ["nfl", 4372561],
    "Isaac Howard (NHL)": ["nhl", 5080179],
    "Isaac Humphries (NBA)": ["nba", 3926491],
    "Isaac Jones (NBA)": ["nba", 5107818],
    "Isaac Okoro (NBA)": ["nba", 4432822],
    "Isaac Paredes (MLB)": ["mlb", 39706],
    "Isaac TeSlaa (NFL)": ["nfl", 5123663],
    "Isaia Cordinier (NBA)": ["nba", 4017845],
    "Isaiah Bond (NFL)": ["nfl", 4808839],
    "Isaiah Briscoe (NBA)": ["nba", 3936294],
    "Isaiah Collier (NBA)": ["nba", 4683766],
    "Isaiah Crawford (NBA)": ["nba", 4592857],
    "Isaiah Davis (NFL)": ["nfl", 4695404],
    "Isaiah Evans (NBA)": ["nba", 5061585],
    "Isaiah Hartenstein (NBA)": ["nba", 4222252],
    "Isaiah Hicks (NBA)": ["nba", 3074765],
    "Isaiah Jackson (NBA)": ["nba", 4432170],
    "Isaiah Joe (NBA)": ["nba", 4395702],
    "Isaiah Likely (NFL)": ["nfl", 4361050],
    "Isaiah Livers (NBA)": ["nba", 4277957],
    "Isaiah Mobley (NBA)": ["nba", 4432815],
    "Isaiah Stevens (NBA)": ["nba", 4432117],
    "Isaiah Stewart (NBA)": ["nba", 4432810],
    "Isaiah Taylor (NBA)": ["nba", 3059336],
    "Isaiah Williams (NFL)": ["nfl", 4569371],
    "Isaiah Wong (NBA)": ["nba", 4431727],
    "Isak Rosen (NHL)": ["nhl", 4874731],
    "Ish Smith (NBA)": ["nba", 4305],
    "Ish Wainright (NBA)": ["nba", 3059307],
    "Isiah Pacheco (NFL)": ["nfl", 4361529],
    "Israel Abanikanda (NFL)": ["nfl", 4429202],
    "Ivan Barbashev (NHL)": ["nhl", 3114985],
    "Ivan Demidov (NHL)": ["nhl", 5216860],
    "Ivan Herrera (MLB)": ["mlb", 41889],
    "Ivan Ivan (NHL)": ["nhl", 5103714],
    "Ivan Miroshnichenko (NHL)": ["nhl", 5080168],
    "Ivan Provorov (NHL)": ["nhl", 3899939],
    "Ivar Stenberg (NHL)": ["nhl", 5361709],
    "Ivica Zubac (NBA)": ["nba", 4017837],
    "Izaiyah Nelson (NBA)": ["nba", 5107251],
    "J. Michael Sturdivant (NFL)": ["nfl", 4635009],
    "J.J. Barea (NBA)": ["nba", 3055],
    "J.J. McCarthy (NFL)": ["nfl", 4433970],
    "J.J. Moser (NHL)": ["nhl", 4874929],
    "J.J. Taylor (NFL)": ["nfl", 4039607],
    "J.K. Dobbins (NFL)": ["nfl", 4241985],
    "J.P. Crawford (MLB)": ["mlb", 33210],
    "J.P. Tokoto (NBA)": ["nba", 2982331],
    "J.T. Compher (NHL)": ["nhl", 3041995],
    "J.T. Ginn (MLB)": ["mlb", 4414002],
    "J.T. Miller (NHL)": ["nhl", 2590852],
    "J.T. Realmuto (MLB)": ["mlb", 32177],
    "Ja Morant (NBA)": ["nba", 4279888],
    "Ja'Corey Brooks (NFL)": ["nfl", 4431506],
    "Ja'Kobe Walter (NBA)": ["nba", 4684272],
    "Ja'Kobi Gillespie (NBA)": ["nba", 5107968],
    "Ja'Kobi Lane (NFL)": ["nfl", 4870847],
    "Ja'Marr Chase (NFL)": ["nfl", 4362628],
    "Ja'Tavion Sanders (NFL)": ["nfl", 4431588],
    "Jabari Smith Jr. (NBA)": ["nba", 4432639],
    "Jabari Walker (NBA)": ["nba", 4432446],
    "Jac Caglianone (MLB)": ["mlb", 4926296],
    "Jacardia Wright (NFL)": ["nfl", 4428943],
    "Jaccob Slavin (NHL)": ["nhl", 3069836],
    "Jack Bech (NFL)": ["nfl", 4603186],
    "Jack Dreyer (MLB)": ["mlb", 5136082],
    "Jack Drury (NHL)": ["nhl", 4378671],
    "Jack Eichel (NHL)": ["nhl", 3648002],
    "Jack Endries (NFL)": ["nfl", 5085189],
    "Jack Flaherty (MLB)": ["mlb", 33837],
    "Jack Hughes (NHL)": ["nhl", 4565222],
    "Jack Johnson (NHL)": ["nhl", 3583],
    "Jack Kochanowicz (MLB)": ["mlb", 4917819],
    "Jack Leiter (MLB)": ["mlb", 4622181],
    "Jack McBain (NHL)": ["nhl", 4755695],
    "Jack McVeigh (NBA)": ["nba", 3911893],
    "Jack Perkins (MLB)": ["mlb", 4418686],
    "Jack Quinn (NHL)": ["nhl", 4697389],
    "Jack Roslovic (NHL)": ["nhl", 3904098],
    "Jack St. Ivany (NHL)": ["nhl", 4755690],
    "Jack Strand (NFL)": ["nfl", 5344782],
    "Jack White (NBA)": ["nba", 4065653],
    "Jackson Blake (NHL)": ["nhl", 5103645],
    "Jackson Chourio (MLB)": ["mlb", 4917869],
    "Jackson Hawes (NFL)": ["nfl", 4573699],
    "Jackson Holliday (MLB)": ["mlb", 5080633],
    "Jackson Jobe (MLB)": ["mlb", 4872647],
    "Jackson LaCombe (NHL)": ["nhl", 4565262],
    "Jackson Meeks (NFL)": ["nfl", 4602788],
    "Jackson Merrill (MLB)": ["mlb", 4872691],
    "Jackson Rowe (NBA)": ["nba", 4066889],
    "Jackson Smith (NHL)": ["nhl", 5291950],
    "Jacob Cowing (NFL)": ["nfl", 4575665],
    "Jacob deGrom (MLB)": ["mlb", 32796],
    "Jacob Fowler (NHL)": ["nhl", 5188437],
    "Jacob Gonzalez (MLB)": ["mlb", 4720990],
    "Jacob Kibodi (NFL)": ["nfl", 4240911],
    "Jacob Latz (MLB)": ["mlb", 3210625],
    "Jacob Lopez (MLB)": ["mlb", 42239],
    "Jacob Markstrom (NHL)": ["nhl", 5452],
    "Jacob Melanson (NHL)": ["nhl", 4894747],
    "Jacob Misiorowski (MLB)": ["mlb", 5080761],
    "Jacob Saylors (NFL)": ["nfl", 4383429],
    "Jacob Trouba (NHL)": ["nhl", 2976839],
    "Jacob Webb (MLB)": ["mlb", 40384],
    "Jacob Wiley (NBA)": ["nba", 2995079],
    "Jacob Wilson (MLB)": ["mlb", 4719300],
    "Jacob Young (MLB)": ["mlb", 4414210],
    "Jacoby Brissett (NFL)": ["nfl", 2578570],
    "Jacory Croskey-Merritt (NFL)": ["nfl", 4575131],
    "Jadarian Price (NFL)": ["nfl", 4685512],
    "Jaden Bradley (NBA)": ["nba", 4432737],
    "Jaden Hardy (NBA)": ["nba", 4868423],
    "Jaden Ivey (NBA)": ["nba", 4433218],
    "Jaden McDaniels (NBA)": ["nba", 4431671],
    "Jaden Schwartz (NHL)": ["nhl", 5835],
    "Jae Crowder (NBA)": ["nba", 6581],
    "Jae'Sean Tate (NBA)": ["nba", 3136777],
    "Jahan Dotson (NFL)": ["nfl", 4361409],
    "Jahdae Walker (NFL)": ["nfl", 5160110],
    "Jaheim Bell (NFL)": ["nfl", 4429262],
    "Jahlil Okafor (NBA)": ["nba", 3135048],
    "Jahmai Mashack (NBA)": ["nba", 4683934],
    "Jahmir Young (NBA)": ["nba", 4433133],
    "Jahmyr Gibbs (NFL)": ["nfl", 4429795],
    "Jaime Echenique (NBA)": ["nba", 4396682],
    "Jaime Jaquez Jr. (NBA)": ["nba", 4432848],
    "JaKarr Sampson (NBA)": ["nba", 2608891],
    "Jake Allen (NHL)": ["nhl", 5111],
    "Jake Bates (NFL)": ["nfl", 4689936],
    "Jake Bauers (MLB)": ["mlb", 35013],
    "Jake Bennett (MLB)": ["mlb", 4654024],
    "Jake Bobo (NFL)": ["nfl", 4360405],
    "Jake Briningstool (NFL)": ["nfl", 4431196],
    "Jake Browning (NFL)": ["nfl", 3886812],
    "Jake Burger (MLB)": ["mlb", 39882],
    "Jake Cronenworth (MLB)": ["mlb", 36364],
    "Jake DeBrusk (NHL)": ["nhl", 3900240],
    "Jake Elliott (NFL)": ["nfl", 3050478],
    "Jake Evans (NHL)": ["nhl", 4393049],
    "Jake Ferguson (NFL)": ["nfl", 4242355],
    "Jake Guentzel (NHL)": ["nhl", 3042083],
    "Jake Haener (NFL)": ["nfl", 4243322],
    "Jake Irvin (MLB)": ["mlb", 41290],
    "Jake LaRavia (NBA)": ["nba", 4592691],
    "Jake Mangum (MLB)": ["mlb", 42664],
    "Jake McCabe (NHL)": ["nhl", 3020803],
    "Jake McCarthy (MLB)": ["mlb", 41197],
    "Jake Middleton (NHL)": ["nhl", 3149839],
    "Jake Moody (NFL)": ["nfl", 4372066],
    "Jake Neighbours (NHL)": ["nhl", 4697409],
    "Jake O'Brien (NHL)": ["nhl", 5291944],
    "Jake Oettinger (NHL)": ["nhl", 4196914],
    "Jake Sanderson (NHL)": ["nhl", 4697386],
    "Jake Tonges (NFL)": ["nfl", 4259147],
    "Jake Walman (NHL)": ["nhl", 3151136],
    "Jakob Chychrun (NHL)": ["nhl", 4024950],
    "Jakob Junis (MLB)": ["mlb", 36056],
    "Jakob Marsee (MLB)": ["mlb", 4866735],
    "Jakob Poeltl (NBA)": ["nba", 3134908],
    "Jakobi Meyers (NFL)": ["nfl", 3916433],
    "Jakobie Keeney-James (NFL)": ["nfl", 5178972],
    "Jakub Dobes (NHL)": ["nhl", 4697686],
    "Jaleel McLaughlin (NFL)": ["nfl", 4722893],
    "Jalen Bridges (NBA)": ["nba", 4432946],
    "Jalen Brooks (NFL)": ["nfl", 4692835],
    "Jalen Brunson (NBA)": ["nba", 3934672],
    "Jalen Chatfield (NHL)": ["nhl", 4063449],
    "Jalen Coker (NFL)": ["nfl", 4695883],
    "Jalen Duren (NBA)": ["nba", 4433621],
    "Jalen Green (NBA)": ["nba", 4437244],
    "Jalen Hood-Schifino (NBA)": ["nba", 5105797],
    "Jalen Hurts (NFL)": ["nfl", 4040715],
    "Jalen Johnson (NBA)": ["nba", 4701230],
    "Jalen Lecque (NBA)": ["nba", 4423887],
    "Jalen McDaniels (NBA)": ["nba", 4066731],
    "Jalen McMillan (NFL)": ["nfl", 4430834],
    "Jalen Milroe (NFL)": ["nfl", 4432734],
    "Jalen Nailor (NFL)": ["nfl", 4382466],
    "Jalen Pickett (NBA)": ["nba", 4398390],
    "Jalen Royals (NFL)": ["nfl", 5082630],
    "Jalen Slawson (NBA)": ["nba", 4398207],
    "Jalen Smith (NBA)": ["nba", 4397189],
    "Jalen Suggs (NBA)": ["nba", 4432165],
    "Jalen Tolbert (NFL)": ["nfl", 4249417],
    "Jalen Williams (NBA)": ["nba", 4593803],
    "Jalen Wilson (NBA)": ["nba", 4431714],
    "Jalon Daniels (NFL)": ["nfl", 4596472],
    "Jam Miller (NFL)": ["nfl", 4685477],
    "Jamaal Pritchett (NFL)": ["nfl", 4892576],
    "Jamaal Williams (NFL)": ["nfl", 2980453],
    "Jamal Agnew (NFL)": ["nfl", 3061612],
    "Jamal Cain (NBA)": ["nba", 4278572],
    "Jamal Murray (NBA)": ["nba", 3936299],
    "Jamal Shead (NBA)": ["nba", 4432241],
    "Jamaree Bouyea (NBA)": ["nba", 4280245],
    "Jameel Warney (NBA)": ["nba", 2982185],
    "Jameis Winston (NFL)": ["nfl", 2969939],
    "Jamel Artis (NBA)": ["nba", 3059276],
    "James Conner (NFL)": ["nfl", 3045147],
    "James Cook III (NFL)": ["nfl", 4379399],
    "James Hagens (NHL)": ["nhl", 5275337],
    "James Harden (NBA)": ["nba", 3992],
    "James Johnson (NBA)": ["nba", 3999],
    "James Michael McAdoo (NBA)": ["nba", 2594818],
    "James Mitchell (NFL)": ["nfl", 4361988],
    "James Nnaji (NBA)": ["nba", 5144059],
    "James Nunnally (NBA)": ["nba", 2326411],
    "James Reimer (NHL)": ["nhl", 3870],
    "James Tibbs III (MLB)": ["mlb", 4925860],
    "James van Riemsdyk (NHL)": ["nhl", 3822],
    "James Webb III (NBA)": ["nba", 3079021],
    "James Wiseman (NBA)": ["nba", 4432808],
    "James Wood (MLB)": ["mlb", 4918256],
    "Jameson Taillon (MLB)": ["mlb", 31258],
    "Jameson Williams (NFL)": ["nfl", 4426388],
    "Jamie Benn (NHL)": ["nhl", 3998],
    "Jamie Drysdale (NHL)": ["nhl", 4697387],
    "Jamie Oleksiak (NHL)": ["nhl", 2562625],
    "Jamil Wilson (NBA)": ["nba", 2488977],
    "Jamir Watkins (NBA)": ["nba", 4606840],
    "Jamison Battle (NBA)": ["nba", 4431893],
    "JaMychal Green (NBA)": ["nba", 2327577],
    "Janson Junk (MLB)": ["mlb", 4881980],
    "Jarace Walker (NBA)": ["nba", 5106060],
    "Jared Boll (NHL)": ["nhl", 3640],
    "Jared Goff (NFL)": ["nfl", 3046779],
    "Jared Jones (MLB)": ["mlb", 4918156],
    "Jared McCain (NBA)": ["nba", 4683778],
    "Jared McCann (NHL)": ["nhl", 3114777],
    "Jared Spurgeon (NHL)": ["nhl", 5079],
    "Jared Terrell (NBA)": ["nba", 3133843],
    "Jared Wayne (NFL)": ["nfl", 4430681],
    "Jared Wiley (NFL)": ["nfl", 4430723],
    "Jared Young (MLB)": ["mlb", 41575],
    "Jaren Jackson Jr. (NBA)": ["nba", 4277961],
    "Jaret Patterson (NFL)": ["nfl", 4362452],
    "Jarnell Stokes (NBA)": ["nba", 2614962],
    "Jaron Pierre Jr. (NBA)": ["nba", 4703115],
    "Jarquez Hunter (NFL)": ["nfl", 4710341],
    "Jarred Vanderbilt (NBA)": ["nba", 4278077],
    "Jarren Duran (MLB)": ["mlb", 41610],
    "Jarrett Allen (NBA)": ["nba", 4066328],
    "Jarrett Stidham (NFL)": ["nfl", 3892775],
    "Jarron Cumberland (NBA)": ["nba", 4066486],
    "Jase Richardson (NBA)": ["nba", 5239561],
    "Jason Adam (MLB)": ["mlb", 32145],
    "Jason Dickinson (NHL)": ["nhl", 3042062],
    "Jason Myers (NFL)": ["nfl", 2473037],
    "Jason Robertson (NHL)": ["nhl", 4233875],
    "Jason Sanders (NFL)": ["nfl", 3124679],
    "Jason Zucker (NHL)": ["nhl", 2593315],
    "Jasson Dominguez (MLB)": ["mlb", 42401],
    "Jauan Jennings (NFL)": ["nfl", 3886598],
    "Javier Assad (MLB)": ["mlb", 5002950],
    "Javier Baez (MLB)": ["mlb", 32127],
    "Javier Sanoja (MLB)": ["mlb", 5073992],
    "Javin DeLaurier (NBA)": ["nba", 4065650],
    "Javon Freeman-Liberty (NBA)": ["nba", 4397511],
    "Javon Small (NBA)": ["nba", 4781746],
    "Javonte Cooke (NBA)": ["nba", 4597259],
    "Javonte Green (NBA)": ["nba", 2596112],
    "Javonte Williams (NFL)": ["nfl", 4361579],
    "Jawhar Jordan (NFL)": ["nfl", 4429939],
    "Jaxon Cover (NHL)": ["nhl", 5361678],
    "Jaxon Smith-Njigba (NFL)": ["nfl", 4430878],
    "Jaxson Dart (NFL)": ["nfl", 4689114],
    "Jaxson Hayes (NBA)": ["nba", 4397077],
    "Jay Beagle (NHL)": ["nhl", 3879],
    "Jay Huff (NBA)": ["nba", 4065731],
    "Jayden Daniels (NFL)": ["nfl", 4426348],
    "Jayden Higgins (NFL)": ["nfl", 4877706],
    "Jayden Quaintance (NBA)": ["nba", 5101845],
    "Jayden Reed (NFL)": ["nfl", 4362249],
    "Jayden Struble (NHL)": ["nhl", 4565269],
    "Jaydn Ott (NFL)": ["nfl", 4685489],
    "Jaydon Blue (NFL)": ["nfl", 4685279],
    "Jaylen Adams (NBA)": ["nba", 3133874],
    "Jaylen Brown (NBA)": ["nba", 3917376],
    "Jaylen Clark (NBA)": ["nba", 4432247],
    "Jaylen Hoard (NBA)": ["nba", 4395688],
    "Jaylen Morris (NBA)": ["nba", 3952343],
    "Jaylen Nowell (NBA)": ["nba", 4278541],
    "Jaylen Waddle (NFL)": ["nfl", 4372016],
    "Jaylen Warren (NFL)": ["nfl", 4569987],
    "Jaylen Wells (NBA)": ["nba", 5112087],
    "Jaylen Wright (NFL)": ["nfl", 4682745],
    "Jaylin Lane (NFL)": ["nfl", 4602667],
    "Jaylin Noel (NFL)": ["nfl", 4586312],
    "Jaylin Williams (NBA)": ["nba", 4432823],
    "Jaylon Tyson (NBA)": ["nba", 4683747],
    "Jayson Tatum (NBA)": ["nba", 4065648],
    "Jazz Chisholm Jr. (MLB)": ["mlb", 41433],
    "JD Davison (NBA)": ["nba", 4576085],
    "Jean-Gabriel Pageau (NHL)": ["nhl", 2593131],
    "Jeff Dowtin Jr. (NBA)": ["nba", 4066786],
    "Jeff Glass (NHL)": ["nhl", 3197],
    "Jeff Green (NBA)": ["nba", 3209],
    "Jeff Hoffman (MLB)": ["mlb", 33841],
    "Jeff Malott (NHL)": ["nhl", 4895214],
    "Jeff McNeil (MLB)": ["mlb", 33900],
    "Jeffrey Springs (MLB)": ["mlb", 35397],
    "Jeffrey Viel (NHL)": ["nhl", 4588188],
    "Jelani Woods (NFL)": ["nfl", 4241410],
    "Jemerrio Jones (NBA)": ["nba", 4067469],
    "Jerami Grant (NBA)": ["nba", 2991070],
    "Jeremiah Estrada (MLB)": ["mlb", 41014],
    "Jeremiah Fears (NBA)": ["nba", 5144091],
    "Jeremiah Jackson (MLB)": ["mlb", 41264],
    "Jeremiah Robinson-Earl (NBA)": ["nba", 4432813],
    "Jeremiyah Love (NFL)": ["nfl", 4870808],
    "Jeremy Lauzon (NHL)": ["nhl", 3904185],
    "Jeremy McNichols (NFL)": ["nfl", 3127586],
    "Jeremy Pena (MLB)": ["mlb", 41273],
    "Jeremy Ruckert (NFL)": ["nfl", 4361372],
    "Jeremy Sochan (NBA)": ["nba", 4610139],
    "Jeremy Swayman (NHL)": ["nhl", 4712036],
    "Jericho Sims (NBA)": ["nba", 4277922],
    "Jermar Jefferson (NFL)": ["nfl", 4374033],
    "Jerome Ford (NFL)": ["nfl", 4372019],
    "Jerry Jeudy (NFL)": ["nfl", 4241463],
    "Jeshaun Jones (NFL)": ["nfl", 4360637],
    "Jesper Boqvist (NHL)": ["nhl", 4233872],
    "Jesper Bratt (NHL)": ["nhl", 4268771],
    "Jesper Wallstedt (NHL)": ["nhl", 4874737],
    "Jesperi Kotkaniemi (NHL)": ["nhl", 4352692],
    "Jesse Edwards (NBA)": ["nba", 4431816],
    "Jesus Luzardo (MLB)": ["mlb", 39667],
    "Jesus Made (MLB)": ["mlb", 5196211],
    "Jesus Sanchez (MLB)": ["mlb", 39957],
    "Jet Greaves (NHL)": ["nhl", 4894366],
    "Jett Howard (NBA)": ["nba", 5105806],
    "Jevon Carter (NBA)": ["nba", 3133635],
    "Jhoan Duran (MLB)": ["mlb", 41109],
    "Jimmy Butler III (NBA)": ["nba", 6430],
    "Jimmy Garoppolo (NFL)": ["nfl", 16760],
    "Jimmy Holiday (NFL)": ["nfl", 4431142],
    "Jimmy Horn Jr. (NFL)": ["nfl", 4708486],
    "Jimmy Snuggerud (NHL)": ["nhl", 5080171],
    "Jiri Kulich (NHL)": ["nhl", 5080176],
    "JJ Bleday (MLB)": ["mlb", 42410],
    "JJ Moser (NHL)": ["nhl", 4874929],
    "JJ Peterka (NHL)": ["nhl", 4697438],
    "JJ Wetherholt (MLB)": ["mlb", 4941056],
    "Jo Adell (MLB)": ["mlb", 40854],
    "Joan Beringer (NBA)": ["nba", 5279133],
    "Joc Pederson (MLB)": ["mlb", 31392],
    "Jock Landale (NBA)": ["nba", 3146557],
    "Joe Burrow (NFL)": ["nfl", 3915511],
    "Joe Chealey (NBA)": ["nba", 3058269],
    "Joe Fagnano (NFL)": ["nfl", 4429582],
    "Joe Flacco (NFL)": ["nfl", 11252],
    "Joe Ingles (NBA)": ["nba", 2968436],
    "Joe Mack (MLB)": ["mlb", 4872695],
    "Joe Milton (NFL)": ["nfl", 4360698],
    "Joe Milton III (NFL)": ["nfl", 4360698],
    "Joe Mixon (NFL)": ["nfl", 3116385],
    "Joe Musgrove (MLB)": ["mlb", 34848],
    "Joe Royer (NFL)": ["nfl", 4565859],
    "Joe Ryan (MLB)": ["mlb", 42450],
    "Joe Veleno (NHL)": ["nhl", 4352804],
    "Joe Young (NBA)": ["nba", 2528386],
    "Joel Armia (NHL)": ["nhl", 2562596],
    "Joel Ayayi (NBA)": ["nba", 4280150],
    "Joel Berry II (NBA)": ["nba", 3138155],
    "Joel Bolomboy (NBA)": ["nba", 2983551],
    "Joel Edmundson (NHL)": ["nhl", 2563034],
    "Joel Embiid (NBA)": ["nba", 3059318],
    "Joel Eriksson Ek (NHL)": ["nhl", 3904091],
    "Joel Farabee (NHL)": ["nhl", 4352750],
    "Joel Hofer (NHL)": ["nhl", 4587909],
    "Joel Kuhnel (MLB)": ["mlb", 40855],
    "Joel Ward (NHL)": ["nhl", 2704],
    "Joey Cantillo (MLB)": ["mlb", 42488],
    "Joey Daccord (NHL)": ["nhl", 3942073],
    "Joey Ortiz (MLB)": ["mlb", 42958],
    "Joey Slye (NFL)": ["nfl", 3124084],
    "Joey Wiemer (MLB)": ["mlb", 4417134],
    "John Bates (NFL)": ["nfl", 4048228],
    "John Carlson (NHL)": ["nhl", 5118],
    "John Collins (NBA)": ["nba", 3908845],
    "John Gibson (NHL)": ["nhl", 2590824],
    "John Klingberg (NHL)": ["nhl", 2590751],
    "John Konchar (NBA)": ["nba", 3134932],
    "John Marino (NHL)": ["nhl", 3941974],
    "John Metchie III (NFL)": ["nfl", 4567096],
    "John Tavares (NHL)": ["nhl", 5160],
    "John Tonje (NBA)": ["nba", 4593043],
    "Johnathan Motley (NBA)": ["nba", 3059306],
    "Johnathan Williams (NBA)": ["nba", 3064528],
    "Johni Broome (NBA)": ["nba", 4433569],
    "Johnny Davis (NBA)": ["nba", 4432356],
    "Johnny Furphy (NBA)": ["nba", 5157066],
    "Johnny Mundt (NFL)": ["nfl", 3052096],
    "JoJo Romero (MLB)": ["mlb", 40456],
    "Jonah Coleman (NFL)": ["nfl", 4702555],
    "Jonah Cox (MLB)": ["mlb", 5145886],
    "Jonah Heim (MLB)": ["mlb", 33842],
    "Jonah Tong (MLB)": ["mlb", 5214984],
    "Jonas Brodin (NHL)": ["nhl", 2562600],
    "Jonas Johansson (NHL)": ["nhl", 3115546],
    "Jonas Siegenthaler (NHL)": ["nhl", 3904190],
    "Jonas Valanciunas (NBA)": ["nba", 6477],
    "Jonatan Berggren (NHL)": ["nhl", 4378660],
    "Jonathan Aranda (MLB)": ["mlb", 40810],
    "Jonathan Aspirot (NHL)": ["nhl", 4392308],
    "Jonathan Castagna (NHL)": ["nhl", 5188608],
    "Jonathan Drouin (NHL)": ["nhl", 3041971],
    "Jonathan Huberdeau (NHL)": ["nhl", 2562606],
    "Jonathan India (MLB)": ["mlb", 41171],
    "Jonathan Isaac (NBA)": ["nba", 4065654],
    "Jonathan Kuminga (NBA)": ["nba", 4433247],
    "Jonathan Lekkerimaki (NHL)": ["nhl", 5080159],
    "Jonathan Marchessault (NHL)": ["nhl", 2967072],
    "Jonathan Mingo (NFL)": ["nfl", 4426485],
    "Jonathan Mogbo (NBA)": ["nba", 5107897],
    "Jonathan Quick (NHL)": ["nhl", 3634],
    "Jonathan Taylor (NFL)": ["nfl", 4242335],
    "Jonathan Toews (NHL)": ["nhl", 3669],
    "Jonathon Brooks (NFL)": ["nfl", 4678008],
    "Jonnu Smith (NFL)": ["nfl", 3054212],
    "Jonny DeLuca (MLB)": ["mlb", 5005912],
    "Joonas Korpisalo (NHL)": ["nhl", 3069266],
    "Jordan Adams (NBA)": ["nba", 2993873],
    "Jordan Addison (NFL)": ["nfl", 4429205],
    "Jordan Binnington (NHL)": ["nhl", 2590874],
    "Jordan Clarkson (NBA)": ["nba", 2528426],
    "Jordan Eberle (NHL)": ["nhl", 5032],
    "Jordan Goodwin (NBA)": ["nba", 4278402],
    "Jordan Greenway (NHL)": ["nhl", 3900260],
    "Jordan Hawkins (NBA)": ["nba", 4683750],
    "Jordan James (NFL)": ["nfl", 4685397],
    "Jordan Kyrou (NHL)": ["nhl", 4062251],
    "Jordan Lawlar (MLB)": ["mlb", 4872649],
    "Jordan Love (NFL)": ["nfl", 4036378],
    "Jordan Martinook (NHL)": ["nhl", 2989376],
    "Jordan Mason (NFL)": ["nfl", 4360569],
    "Jordan McLaughlin (NBA)": ["nba", 3134916],
    "Jordan Miller (NBA)": ["nba", 4396818],
    "Jordan Mims (NFL)": ["nfl", 4243004],
    "Jordan Poole (NBA)": ["nba", 4277956],
    "Jordan Romano (MLB)": ["mlb", 36380],
    "Jordan Spence (NHL)": ["nhl", 4588190],
    "Jordan Staal (NHL)": ["nhl", 3541],
    "Jordan Travis (NFL)": ["nfl", 4360799],
    "Jordan Walker (MLB)": ["mlb", 4684778],
    "Jordan Walsh (NBA)": ["nba", 4683689],
    "Jordan Watkins (NFL)": ["nfl", 4431466],
    "Jordan Westburg (MLB)": ["mlb", 4298641],
    "Jordan Whittington (NFL)": ["nfl", 4569382],
    "Jordyn Tyson (NFL)": ["nfl", 4880281],
    "Jorge Gutierrez (NBA)": ["nba", 2327449],
    "Jorge Mateo (MLB)": ["mlb", 33832],
    "Jorge Polanco (MLB)": ["mlb", 32525],
    "Jorge Soler (MLB)": ["mlb", 32558],
    "Jose Altuve (MLB)": ["mlb", 31662],
    "Jose Alvarado (MLB)": ["mlb", 36063],
    "Jose Alvarado (NBA)": ["nba", 4277869],
    "Jose Berrios (MLB)": ["mlb", 32811],
    "Jose Caballero (MLB)": ["mlb", 42135],
    "Jose Fernandez (MLB)": ["mlb", 5010500],
    "Jose Ferrer (MLB)": ["mlb", 5119607],
    "Jose Ramirez (MLB)": ["mlb", 32801],
    "Jose Soriano (MLB)": ["mlb", 40973],
    "Jose Urquidy (MLB)": ["mlb", 35759],
    "Joseph Woll (NHL)": ["nhl", 4271575],
    "Josh Allen (NFL)": ["nfl", 3918298],
    "Josh Anderson (NHL)": ["nhl", 3069687],
    "Josh Bell (MLB)": ["mlb", 32517],
    "Josh Cameron (NFL)": ["nfl", 4879194],
    "Josh Cuevas (NFL)": ["nfl", 4876132],
    "Josh Doan (NHL)": ["nhl", 4874870],
    "Josh Downs (NFL)": ["nfl", 4688813],
    "Josh Giddey (NBA)": ["nba", 4871145],
    "Josh Gorges (NHL)": ["nhl", 2265],
    "Josh Gray (NBA)": ["nba", 3001308],
    "Josh Green (NBA)": ["nba", 4432811],
    "Josh Hader (MLB)": ["mlb", 32760],
    "Josh Hart (NBA)": ["nba", 3062679],
    "Josh Huestis (NBA)": ["nba", 2531364],
    "Josh Jacobs (NFL)": ["nfl", 4047365],
    "Josh Johnson (ARI) (NFL)": ["nfl", 11394],
    "Josh Johnson (CIN) (NFL)": ["nfl", 11394],
    "Josh Johnson (FA) (NFL)": ["nfl", 4390717],
    "Josh Jung (MLB)": ["mlb", 42437],
    "Josh Lowe (MLB)": ["mlb", 40557],
    "Josh Magette (NBA)": ["nba", 4064727],
    "Josh Manson (NHL)": ["nhl", 2590829],
    "Josh Minott (NBA)": ["nba", 4687718],
    "Josh Morrissey (NHL)": ["nhl", 3042016],
    "Josh Naylor (MLB)": ["mlb", 35066],
    "Josh Norris (NHL)": ["nhl", 4233627],
    "Josh Okogie (NBA)": ["nba", 4065663],
    "Josh Oliver (NFL)": ["nfl", 3921690],
    "Josh Smith (MLB)": ["mlb", 42884],
    "Josh Whyle (NFL)": ["nfl", 4360086],
    "Josh Williams (NFL)": ["nfl", 4568024],
    "Joshua Baez (MLB)": ["mlb", 4920835],
    "Joshua Dobbs (NFL)": ["nfl", 3044720],
    "Joshua Jefferson (NBA)": ["nba", 4870564],
    "Joshua Karty (NFL)": ["nfl", 4566192],
    "Joshua Kuroda-Grauer (MLB)": ["mlb", 5023768],
    "Joshua Mahura (NHL)": ["nhl", 4063504],
    "Joshua Palmer (NFL)": ["nfl", 4242433],
    "Josue De Paula (MLB)": ["mlb", 5102682],
    "JR Ritchie (MLB)": ["mlb", 5080757],
    "Jrue Holiday (NBA)": ["nba", 3995],
    "JT Thor (NBA)": ["nba", 4702233],
    "Juan Morillo (MLB)": ["mlb", 4722925],
    "Juan Nunez (NBA)": ["nba", 5144070],
    "Juan Soto (MLB)": ["mlb", 36969],
    "Juan Toscano-Anderson (NBA)": ["nba", 4401416],
    "Judd Caulfield (NHL)": ["nhl", 4755684],
    "Jude McAtamney (NFL)": ["nfl", 5092436],
    "JuJu Smith-Schuster (NFL)": ["nfl", 3120348],
    "Julian Champagnie (NBA)": ["nba", 4592479],
    "Julian Phillips (NBA)": ["nba", 5105553],
    "Julian Reese (NBA)": ["nba", 4683742],
    "Julian Strawther (NBA)": ["nba", 4432181],
    "Julian Washburn (NBA)": ["nba", 2579492],
    "Julio Rodriguez (MLB)": ["mlb", 41044],
    "Julius Chestnut (NFL)": ["nfl", 4367567],
    "Julius Randle (NBA)": ["nba", 3064514],
    "Jung Hoo Lee (MLB)": ["mlb", 5134621],
    "Junior Caminero (MLB)": ["mlb", 4905921],
    "Juraj Slafkovsky (NHL)": ["nhl", 4915349],
    "Jurickson Profar (MLB)": ["mlb", 31117],
    "Justice Hill (NFL)": ["nfl", 4038441],
    "Justin Barron (NHL)": ["nhl", 4697408],
    "Justin Brazeau (NHL)": ["nhl", 4063605],
    "Justin Champagnie (NBA)": ["nba", 4432907],
    "Justin Crawford (MLB)": ["mlb", 5080642],
    "Justin Edwards (NBA)": ["nba", 4711297],
    "Justin Faulk (NHL)": ["nhl", 5746],
    "Justin Fields (NFL)": ["nfl", 4362887],
    "Justin Herbert (NFL)": ["nfl", 4038941],
    "Justin Holiday (NBA)": ["nba", 2284101],
    "Justin Holl (NHL)": ["nhl", 5763],
    "Justin Hryckowian (NHL)": ["nhl", 5229176],
    "Justin Jefferson (NFL)": ["nfl", 4262921],
    "Justin Joly (NFL)": ["nfl", 4912052],
    "Justin Martinez (MLB)": ["mlb", 5116851],
    "Justin Minaya (NBA)": ["nba", 4278111],
    "Justin Sourdif (NHL)": ["nhl", 4697783],
    "Justin Steele (MLB)": ["mlb", 41022],
    "Justin Tucker (NFL)": ["nfl", 15683],
    "Justin Verlander (MLB)": ["mlb", 6341],
    "Justin Watson (NFL)": ["nfl", 3118892],
    "Justin Wrobleski (MLB)": ["mlb", 4417203],
    "Justus Annunen (NHL)": ["nhl", 4393408],
    "Jusuf Nurkic (NBA)": ["nba", 3102530],
    "Juuse Saros (NHL)": ["nhl", 3042109],
    "Juuso Valimaki (NHL)": ["nhl", 4233611],
    "Juwan Johnson (NFL)": ["nfl", 3929645],
    "K'Andre Miller (NHL)": ["nhl", 4352770],
    "Ka'imi Fairbairn (NFL)": ["nfl", 2971573],
    "Kaapo Kakko (NHL)": ["nhl", 4565223],
    "Kadarius Toney (NFL)": ["nfl", 4240600],
    "Kade Anderson (MLB)": ["mlb", 5198748],
    "Kaden Wetjen (NFL)": ["nfl", 5081338],
    "Kaedan Korczak (NHL)": ["nhl", 4565264],
    "Kaelen Culpepper (MLB)": ["mlb", 4935268],
    "Kaelon Black (NFL)": ["nfl", 4696044],
    "Kai Jones (NBA)": ["nba", 4431699],
    "Kai-Wei Teng (MLB)": ["mlb", 42242],
    "Kaiden Guhle (NHL)": ["nhl", 4697399],
    "Kailer Yamamoto (NHL)": ["nhl", 4233648],
    "Kaleb Johnson (NFL)": ["nfl", 4819231],
    "Kalif Raymond (NFL)": ["nfl", 2973405],
    "Kam Jones (NBA)": ["nba", 4697268],
    "Kameron Johnson (NFL)": ["nfl", 5097554],
    "Kareem Hunt (NFL)": ["nfl", 3059915],
    "Karel Vejmelka (NHL)": ["nhl", 3942065],
    "Karim Lopez (NBA)": ["nba", 5231919],
    "Karl-Anthony Towns (NBA)": ["nba", 3136195],
    "Karlo Matkovic (NBA)": ["nba", 4997538],
    "Kashawn Aitcheson (NHL)": ["nhl", 5291953],
    "Kasparas Jakucionis (NBA)": ["nba", 5214640],
    "Kasperi Kapanen (NHL)": ["nhl", 3114775],
    "KaVontae Turpin (NFL)": ["nfl", 3676833],
    "Kawhi Leonard (NBA)": ["nba", 6450],
    "Kayshon Boutte (NFL)": ["nfl", 4429022],
    "Kaytron Allen (NFL)": ["nfl", 4685246],
    "Kazuma Okamoto (MLB)": ["mlb", 5134636],
    "KC Concepcion (NFL)": ["nfl", 4870653],
    "Ke'Shawn Vaughn (NFL)": ["nfl", 3917612],
    "Ke'Shawn Williams (NFL)": ["nfl", 4570738],
    "KeAndre Lambert-Smith (NFL)": ["nfl", 4430870],
    "Keaton Mitchell (NFL)": ["nfl", 4596334],
    "Keaton Verhoeff (NHL)": ["nhl", 5342440],
    "Keaton Wagler (NBA)": ["nba", 5254165],
    "Kedon Slovis (NFL)": ["nfl", 4428512],
    "Keegan Kolesar (NHL)": ["nhl", 3941546],
    "Keegan Murray (NBA)": ["nba", 4594327],
    "Keenan Allen (NFL)": ["nfl", 15818],
    "Keenan Evans (NBA)": ["nba", 3133629],
    "Keibert Ruiz (MLB)": ["mlb", 38827],
    "Keider Montero (MLB)": ["mlb", 5182933],
    "Keifer Sykes (NBA)": ["nba", 2596247],
    "Keilan Robinson (NFL)": ["nfl", 4567095],
    "Keion Brooks Jr. (NBA)": ["nba", 4431689],
    "Keith Appling (NBA)": ["nba", 2531097],
    "Kel'el Ware (NBA)": ["nba", 5105623],
    "Keldon Johnson (NBA)": ["nba", 4395723],
    "Keleki Latu (NFL)": ["nfl", 4688552],
    "Kelly Olynyk (NBA)": ["nba", 2489663],
    "Kelly Oubre Jr. (NBA)": ["nba", 3133603],
    "Kendre Miller (NFL)": ["nfl", 4599739],
    "Kendrick Bourne (NFL)": ["nfl", 3045523],
    "Kendrick Law (NFL)": ["nfl", 4685441],
    "Kene Nwangwu (NFL)": ["nfl", 4035537],
    "Kenley Jansen (MLB)": ["mlb", 29630],
    "Kennedy Chandler (NBA)": ["nba", 4432646],
    "Kenneth Lofton Jr. (NBA)": ["nba", 4585610],
    "Kenneth Walker III (NFL)": ["nfl", 4567048],
    "Kenny Gainwell (NFL)": ["nfl", 4371733],
    "Kenny McIntosh (NFL)": ["nfl", 4427391],
    "Kenny Pickett (NFL)": ["nfl", 4240703],
    "Kenrich Williams (NBA)": ["nba", 3133626],
    "Kent Bazemore (NBA)": ["nba", 6637],
    "Kent Johnson (NHL)": ["nhl", 4781553],
    "Kentavious Caldwell-Pope (NBA)": ["nba", 2581018],
    "Kenyon Sadiq (NFL)": ["nfl", 5083315],
    "Keon Coleman (NFL)": ["nfl", 4635008],
    "Keon Ellis (NBA)": ["nba", 4702177],
    "Kerry Carpenter (MLB)": ["mlb", 42714],
    "Keshad Johnson (NBA)": ["nba", 4431786],
    "Ketel Marte (MLB)": ["mlb", 32512],
    "Kevin Bahl (NHL)": ["nhl", 4378686],
    "Kevin Coleman Jr. (NFL)": ["nfl", 4685307],
    "Kevin Durant (NBA)": ["nba", 3202],
    "Kevin Fiala (NHL)": ["nhl", 3114743],
    "Kevin Gausman (MLB)": ["mlb", 32667],
    "Kevin Ginkel (MLB)": ["mlb", 41432],
    "Kevin Huerter (NBA)": ["nba", 4066372],
    "Kevin Kelly (MLB)": ["mlb", 5001153],
    "Kevin Knox II (NBA)": ["nba", 4278075],
    "Kevin Korchinski (NHL)": ["nhl", 5080148],
    "Kevin Lankinen (NHL)": ["nhl", 4341584],
    "Kevin Love (NBA)": ["nba", 3449],
    "Kevin McCullar Jr. (NBA)": ["nba", 4411057],
    "Kevin McGonigle (MLB)": ["mlb", 5149072],
    "Kevin Pangos (NBA)": ["nba", 2583962],
    "Kevin Porter Jr. (NBA)": ["nba", 4397140],
    "Kevin Stenlund (NHL)": ["nhl", 3904191],
    "Kevon Looney (NBA)": ["nba", 3155535],
    "Keyontae Johnson (NBA)": ["nba", 4395714],
    "Keyonte George (NBA)": ["nba", 4433627],
    "KhaDarel Hodge (NFL)": ["nfl", 3047876],
    "Khalifa Diop (NBA)": ["nba", 4997530],
    "Khalil Herbert (NFL)": ["nfl", 4035886],
    "Khalil Shakir (NFL)": ["nfl", 4373678],
    "Khaman Maluach (NBA)": ["nba", 5203685],
    "Khem Birch (NBA)": ["nba", 2578240],
    "Khris Middleton (NBA)": ["nba", 6609],
    "Kiefer Sherwood (NHL)": ["nhl", 4391255],
    "Killian Hayes (NBA)": ["nba", 4683024],
    "Kimani Vidal (NFL)": ["nfl", 4430968],
    "Kingston Flemings (NBA)": ["nba", 5149077],
    "Kirby Dach (NHL)": ["nhl", 4565224],
    "Kirby Yates (MLB)": ["mlb", 32623],
    "Kirill Kaprizov (NHL)": ["nhl", 3942335],
    "Kirill Kudryavtsev (NHL)": ["nhl", 5188544],
    "Kirill Marchenko (NHL)": ["nhl", 4587996],
    "Kirk Cousins (NFL)": ["nfl", 14880],
    "KJ Martin (NBA)": ["nba", 4431828],
    "Klay Thompson (NBA)": ["nba", 6475],
    "Ko Kieft (NFL)": ["nfl", 4034779],
    "Koa Peat (NBA)": ["nba", 5041953],
    "Kobe Brown (NBA)": ["nba", 4431752],
    "Kobe Bufkin (NBA)": ["nba", 4683736],
    "Kobe Sanders (NBA)": ["nba", 4702352],
    "Koby Brea (NBA)": ["nba", 4591259],
    "Kodai Senga (MLB)": ["mlb", 4142421],
    "Kody Clemens (MLB)": ["mlb", 41311],
    "Kon Knueppel (NBA)": ["nba", 5061575],
    "Konata Mumpfield (NFL)": ["nfl", 4710855],
    "Konnor Griffin (MLB)": ["mlb", 5218285],
    "Konsta Helenius (NHL)": ["nhl", 5216882],
    "Kris Bubic (MLB)": ["mlb", 41201],
    "Kris Dunn (NBA)": ["nba", 2991139],
    "Kris Letang (NHL)": ["nhl", 3539],
    "Kris Murray (NBA)": ["nba", 4594326],
    "Kristaps Porzingis (NBA)": ["nba", 3102531],
    "Kumar Rocker (MLB)": ["mlb", 4414525],
    "Kyle Allen (NFL)": ["nfl", 3115293],
    "Kyle Anderson (NBA)": ["nba", 2993874],
    "Kyle Bradish (MLB)": ["mlb", 4311625],
    "Kyle Connor (NHL)": ["nhl", 3899952],
    "Kyle Filipowski (NBA)": ["nba", 4684793],
    "Kyle Finnegan (MLB)": ["mlb", 36543],
    "Kyle Freeland (MLB)": ["mlb", 33839],
    "Kyle Harrison (MLB)": ["mlb", 4683375],
    "Kyle Isbel (MLB)": ["mlb", 41263],
    "Kyle Juszczyk (NFL)": ["nfl", 16002],
    "Kyle Karros (MLB)": ["mlb", 5203102],
    "Kyle Kuzma (NBA)": ["nba", 3134907],
    "Kyle Leahy (MLB)": ["mlb", 5006093],
    "Kyle Lowry (NBA)": ["nba", 3012],
    "Kyle Manzardo (MLB)": ["mlb", 4917927],
    "Kyle McCord (NFL)": ["nfl", 4433971],
    "Kyle Monangai (NFL)": ["nfl", 4608686],
    "Kyle Palmieri (NHL)": ["nhl", 5517],
    "Kyle Pitts Sr. (NFL)": ["nfl", 4360248],
    "Kyle Quincey (NHL)": ["nhl", 3082],
    "Kyle Schwarber (MLB)": ["mlb", 33712],
    "Kyle Stowers (MLB)": ["mlb", 42796],
    "Kyle Teel (MLB)": ["mlb", 4743772],
    "Kyle Tucker (MLB)": ["mlb", 34967],
    "Kyle Williams (NFL)": ["nfl", 4613202],
    "Kyler Murray (NFL)": ["nfl", 3917315],
    "Kylor Kelley (NBA)": ["nba", 3950760],
    "Kyren Williams (NFL)": ["nfl", 4430737],
    "Kyrie Irving (NBA)": ["nba", 6442],
    "Kyshawn George (NBA)": ["nba", 5174563],
    "Labaron Philon Jr. (NBA)": ["nba", 4873090],
    "Ladd McConkey (NFL)": ["nfl", 4612826],
    "Lajae Jones (NBA)": ["nba", 5108969],
    "LaJohntay Wester (NFL)": ["nfl", 4690143],
    "Lake Bachar (MLB)": ["mlb", 42592],
    "Lamar Jackson (NFL)": ["nfl", 3916387],
    "Lamar Patterson (NBA)": ["nba", 2488721],
    "LaMelo Ball (NBA)": ["nba", 4432816],
    "Lan Larison (NFL)": ["nfl", 4698253],
    "Lance McCullers Jr. (MLB)": ["mlb", 32764],
    "Lance Thomas (NBA)": ["nba", 6485],
    "Landen Roupp (MLB)": ["mlb", 4345404],
    "Landry Shamet (NBA)": ["nba", 3914044],
    "Lane Hutson (NHL)": ["nhl", 5080230],
    "Lane Thomas (MLB)": ["mlb", 36409],
    "Laquon Treadwell (NFL)": ["nfl", 3051889],
    "Larry Drew II (NBA)": ["nba", 2325495],
    "Larry Nance Jr. (NBA)": ["nba", 2580365],
    "Lars Eller (NHL)": ["nhl", 3946],
    "Lars Nootbaar (MLB)": ["mlb", 4448736],
    "Laurent Brossoit (NHL)": ["nhl", 3026526],
    "Lauri Markkanen (NBA)": ["nba", 4066336],
    "Laviska Shenault Jr. (NFL)": ["nfl", 4243160],
    "Lawrence Butler (MLB)": ["mlb", 4917919],
    "Lawson Crouse (NHL)": ["nhl", 3899951],
    "Lazaro Montes (MLB)": ["mlb", 5124103],
    "Leaky Black (NBA)": ["nba", 4395650],
    "LeBron James (NBA)": ["nba", 1966],
    "Leevi Merilainen (NHL)": ["nhl", 4894703],
    "Lenni Hameenaho (NHL)": ["nhl", 5149245],
    "Leo Bernal (MLB)": ["mlb", 5124076],
    "Leo Carlsson (NHL)": ["nhl", 5149153],
    "Leo De Vries (MLB)": ["mlb", 5196124],
    "Leody Taveras (MLB)": ["mlb", 34951],
    "Leon Draisaitl (NHL)": ["nhl", 3114727],
    "Leonard Miller (NBA)": ["nba", 5044385],
    "LeQuint Allen Jr. (NFL)": ["nfl", 4911851],
    "Lester Quinones (NBA)": ["nba", 4431720],
    "Lewis Bond (NFL)": ["nfl", 4683159],
    "Liam Doyle (MLB)": ["mlb", 5130533],
    "Liam Hicks (MLB)": ["mlb", 4725251],
    "Liam McNeeley (NBA)": ["nba", 5239590],
    "Liam O'Brien (NHL)": ["nhl", 3150468],
    "Liam Ohgren (NHL)": ["nhl", 5080163],
    "Liam Robbins (NBA)": ["nba", 4397347],
    "Liam Ruck (NHL)": ["nhl", 5361669],
    "Lian Bichsel (NHL)": ["nhl", 5080162],
    "Lil'Jordan Humphrey (NFL)": ["nfl", 4039057],
    "Lindy Waters III (NBA)": ["nba", 4066317],
    "Linus Karlsson (NHL)": ["nhl", 4587713],
    "Linus Ullmark (NHL)": ["nhl", 3069285],
    "LJ Cryer (NBA)": ["nba", 4433149],
    "Logan Cooley (NHL)": ["nhl", 5080143],
    "Logan Gilbert (MLB)": ["mlb", 41221],
    "Logan Henderson (MLB)": ["mlb", 4917878],
    "Logan Mailloux (NHL)": ["nhl", 4874748],
    "Logan O'Connor (NHL)": ["nhl", 3988782],
    "Logan O'Hoppe (MLB)": ["mlb", 42047],
    "Logan Stankoven (NHL)": ["nhl", 4874899],
    "Logan Stanley (NHL)": ["nhl", 4024968],
    "Logan Thompson (NHL)": ["nhl", 4272888],
    "Logan Webb (MLB)": ["mlb", 41216],
    "London Perrantes (NBA)": ["nba", 3059286],
    "Lonnie Walker IV (NBA)": ["nba", 4277890],
    "Lonzo Ball (NBA)": ["nba", 4066421],
    "Lorenzo Brown (NBA)": ["nba", 2528787],
    "Louis Crevier (NHL)": ["nhl", 4697681],
    "Louis King (NBA)": ["nba", 4397103],
    "Louis Varland (MLB)": ["mlb", 4917888],
    "Lourdes Gurriel Jr. (MLB)": ["mlb", 36040],
    "Luca Cagnoni (NHL)": ["nhl", 5188591],
    "Lucas Erceg (MLB)": ["mlb", 36618],
    "Lucas Giolito (MLB)": ["mlb", 32697],
    "Lucas Havrisik (NFL)": ["nfl", 4245661],
    "Lucas Krull (NFL)": ["nfl", 4360231],
    "Lucas Nogueira (NBA)": ["nba", 3032980],
    "Lucas Raymond (NHL)": ["nhl", 4697385],
    "Lucas Spence (MLB)": ["mlb", 5273759],
    "Luguentz Dort (NBA)": ["nba", 4397020],
    "Luis Arraez (MLB)": ["mlb", 39572],
    "Luis Campusano (MLB)": ["mlb", 40521],
    "Luis Castillo (MLB)": ["mlb", 35124],
    "Luis Garcia Jr. (MLB)": ["mlb", 40459],
    "Luis Gil (MLB)": ["mlb", 40626],
    "Luis Lara (MLB)": ["mlb", 5138536],
    "Luis Medina (MLB)": ["mlb", 40949],
    "Luis Rengifo (MLB)": ["mlb", 37237],
    "Luis Robert Jr. (MLB)": ["mlb", 39631],
    "Luis Severino (MLB)": ["mlb", 33263],
    "Luis Torrens (MLB)": ["mlb", 33805],
    "Luisangel Acuna (MLB)": ["mlb", 42411],
    "Luka Doncic (NBA)": ["nba", 3945274],
    "Luka Garza (NBA)": ["nba", 4277951],
    "Luka Mitrovic (NBA)": ["nba", 3899662],
    "Lukas Dostal (NHL)": ["nhl", 4588165],
    "Luke Evangelista (NHL)": ["nhl", 4697446],
    "Luke Farrell (NFL)": ["nfl", 4040612],
    "Luke Hughes (NHL)": ["nhl", 4874719],
    "Luke Keaschall (MLB)": ["mlb", 4977664],
    "Luke Kennard (NBA)": ["nba", 3913174],
    "Luke Kornet (NBA)": ["nba", 3064560],
    "Luke Lachey (NFL)": ["nfl", 4432338],
    "Luke McCaffrey (NFL)": ["nfl", 4426948],
    "Luke Musgrave (NFL)": ["nfl", 4428085],
    "Luke Raley (MLB)": ["mlb", 40422],
    "Luke Schenn (NHL)": ["nhl", 5092],
    "Luke Schoonmaker (NFL)": ["nfl", 4372096],
    "Luke Travers (NBA)": ["nba", 4997539],
    "Luke Weaver (MLB)": ["mlb", 33770],
    "Luther Burden III (NFL)": ["nfl", 4685278],
    "Mac Jones (NFL)": ["nfl", 4241464],
    "Mac McClung (NBA)": ["nba", 4397071],
    "Mack Hollins (NFL)": ["nfl", 2991662],
    "Mackenzie Blackwood (NHL)": ["nhl", 3904177],
    "MacKenzie Gore (MLB)": ["mlb", 39636],
    "MacKenzie Weegar (NHL)": ["nhl", 3042269],
    "Mackie Samoskevich (NHL)": ["nhl", 4874741],
    "Macklin Celebrini (NHL)": ["nhl", 5206628],
    "Maikel Garcia (MLB)": ["mlb", 4905884],
    "Makai Lemon (NFL)": ["nfl", 4870795],
    "Malachi Corley (NFL)": ["nfl", 4613104],
    "Malachi Fields (NFL)": ["nfl", 4682648],
    "Malachi Flynn (NBA)": ["nba", 4066668],
    "Malaki Branham (NBA)": ["nba", 4565201],
    "Malcolm Brogdon (NBA)": ["nba", 2566769],
    "Malcolm Delaney (NBA)": ["nba", 2282205],
    "Malik Beasley (NBA)": ["nba", 3907822],
    "Malik Benson (NFL)": ["nfl", 5150247],
    "Malik Davis (NFL)": ["nfl", 4240603],
    "Malik Monk (NBA)": ["nba", 4066262],
    "Malik Nabers (NFL)": ["nfl", 4595348],
    "Malik Newman (NBA)": ["nba", 3907359],
    "Malik Washington (NFL)": ["nfl", 4569603],
    "Malik Williams (NBA)": ["nba", 4277880],
    "Malik Willis (NFL)": ["nfl", 4242512],
    "Maliq Brown (NBA)": ["nba", 5105337],
    "Malique Lewis (NBA)": ["nba", 5184016],
    "Mamadi Diakite (NBA)": ["nba", 3947156],
    "Manny Machado (MLB)": ["mlb", 31097],
    "Marat Khusnutdinov (NHL)": ["nhl", 4697442],
    "Marc Gatcomb (NHL)": ["nhl", 5103547],
    "Marc-Andre Fleury (NHL)": ["nhl", 2346],
    "Marc-Edouard Vlasic (NHL)": ["nhl", 3371],
    "Marcedes Lewis (NFL)": ["nfl", 9614],
    "Marcell Ozuna (MLB)": ["mlb", 31668],
    "Marcelo Huertas (NBA)": ["nba", 2968363],
    "Marcelo Mayer (MLB)": ["mlb", 4872648],
    "Marco Kasper (NHL)": ["nhl", 5080152],
    "Marco Rossi (NHL)": ["nhl", 4697391],
    "Marcus Foligno (NHL)": ["nhl", 5172],
    "Marcus Garrett (NBA)": ["nba", 4277892],
    "Marcus Johansson (NHL)": ["nhl", 5714],
    "Marcus Mariota (NFL)": ["nfl", 2576980],
    "Marcus Pettersson (NHL)": ["nhl", 3114995],
    "Marcus Sasser (NBA)": ["nba", 4432107],
    "Marcus Semien (MLB)": ["mlb", 32146],
    "Marcus Smart (NBA)": ["nba", 2990992],
    "Mario Ferraro (NHL)": ["nhl", 4233884],
    "Mario Hezonja (NBA)": ["nba", 2995706],
    "MarJon Beauchamp (NBA)": ["nba", 4432179],
    "Mark  Letestu (NHL)": ["nhl", 3626],
    "Mark Andrews (NFL)": ["nfl", 3116365],
    "Mark Giordano (NHL)": ["nhl", 3006],
    "Mark Jankowski (NHL)": ["nhl", 2976849],
    "Mark Kastelic (NHL)": ["nhl", 4587985],
    "Mark Redman (NFL)": ["nfl", 4431346],
    "Mark Scheifele (NHL)": ["nhl", 2562632],
    "Mark Stone (NHL)": ["nhl", 5545],
    "Mark Streit (NHL)": ["nhl", 3256],
    "Mark Vientos (MLB)": ["mlb", 41034],
    "Mark Williams (NBA)": ["nba", 4701232],
    "Markelle Fultz (NBA)": ["nba", 4066636],
    "Marko Guduric (NBA)": ["nba", 4230554],
    "Markus Howard (NBA)": ["nba", 4065805],
    "Markus Ruck (NHL)": ["nhl", 5361672],
    "Marlin Klein (NFL)": ["nfl", 4695705],
    "Marquez Valdes-Scantling (NFL)": ["nfl", 3051738],
    "Marshall Rifai (NHL)": ["nhl", 4419778],
    "MarShawn Lloyd (NFL)": ["nfl", 4429023],
    "MarShon Brooks (NBA)": ["nba", 6428],
    "Martin Fehervary (NHL)": ["nhl", 4378677],
    "Martin Necas (NHL)": ["nhl", 4233586],
    "Martin Perez (MLB)": ["mlb", 31098],
    "Martin Pospisil (NHL)": ["nhl", 4392883],
    "Marvin Bagley III (NBA)": ["nba", 4277848],
    "Marvin Harrison Jr. (NFL)": ["nfl", 4432708],
    "Marvin Mims Jr. (NFL)": ["nfl", 4686472],
    "Masataka Yoshida (MLB)": ["mlb", 4872598],
    "Mason Fluharty (MLB)": ["mlb", 4622501],
    "Mason Kinsey (NFL)": ["nfl", 4057082],
    "Mason Lohrei (NHL)": ["nhl", 4697461],
    "Mason Marchment (NHL)": ["nhl", 4272192],
    "Mason McTavish (NHL)": ["nhl", 4874718],
    "Mason Miller (MLB)": ["mlb", 4730225],
    "Mason Montgomery (MLB)": ["mlb", 4424112],
    "Mason Plumlee (NBA)": ["nba", 2488653],
    "Mason Rudolph (NFL)": ["nfl", 3116407],
    "Mason Taylor (NFL)": ["nfl", 4808766],
    "Mason Tipton (NFL)": ["nfl", 4573697],
    "Masyn Winn (MLB)": ["mlb", 4683365],
    "Matas Buzelis (NBA)": ["nba", 4711294],
    "Mathew Barzal (NHL)": ["nhl", 3899946],
    "Mathieu Joseph (NHL)": ["nhl", 3941965],
    "Mathieu Olivier (NHL)": ["nhl", 4064781],
    "Matias Maccelli (NHL)": ["nhl", 4587580],
    "Matisse Thybulle (NBA)": ["nba", 3907498],
    "Mats Zuccarello (NHL)": ["nhl", 5560],
    "Matt Boldy (NHL)": ["nhl", 4565233],
    "Matt Brash (MLB)": ["mlb", 4894467],
    "Matt Chapman (MLB)": ["mlb", 33857],
    "Matt Coronato (NHL)": ["nhl", 4874730],
    "Matt Duchene (NHL)": ["nhl", 5161],
    "Matt Gay (NFL)": ["nfl", 4249087],
    "Matt Hibner (NFL)": ["nfl", 4432260],
    "Matt McLain (MLB)": ["mlb", 4422899],
    "Matt Olson (MLB)": ["mlb", 32767],
    "Matt Prater (NFL)": ["nfl", 11122],
    "Matt Rempe (NHL)": ["nhl", 4697820],
    "Matt Roy (NHL)": ["nhl", 3942924],
    "Matt Savoie (NHL)": ["nhl", 5080153],
    "Matt Shaw (MLB)": ["mlb", 4867667],
    "Matt Strahm (MLB)": ["mlb", 34862],
    "Matt Thomas (NBA)": ["nba", 3059311],
    "Matt Tomkins (NHL)": ["nhl", 3069614],
    "Matt Wilkinson (MLB)": ["mlb", 5339226],
    "Matt Williams Jr. (NBA)": ["nba", 2991295],
    "Matthew Boyd (MLB)": ["mlb", 34401],
    "Matthew Dellavedova (NBA)": ["nba", 2489716],
    "Matthew Golden (NFL)": ["nfl", 4701936],
    "Matthew Hibner (NFL)": ["nfl", 4432260],
    "Matthew Knies (NHL)": ["nhl", 4874919],
    "Matthew Liberatore (MLB)": ["mlb", 41173],
    "Matthew Poitras (NHL)": ["nhl", 5080221],
    "Matthew Robertson (NHL)": ["nhl", 4565272],
    "Matthew Schaefer (NHL)": ["nhl", 5291933],
    "Matthew Stafford (NFL)": ["nfl", 12483],
    "Matthew Tkachuk (NHL)": ["nhl", 4024854],
    "Matthew Wood (NHL)": ["nhl", 5149189],
    "Matthew Wright (NFL)": ["nfl", 3128444],
    "Mattias Ekholm (NHL)": ["nhl", 2558631],
    "Mattias Samuelsson (NHL)": ["nhl", 4378656],
    "Matty Beniers (NHL)": ["nhl", 4781552],
    "Matvei Gridin (NHL)": ["nhl", 5216897],
    "Matvei Michkov (NHL)": ["nhl", 5149170],
    "Maurice Ndour (NBA)": ["nba", 3063982],
    "Mauricio Dubon (MLB)": ["mlb", 35304],
    "Mavrik Bourque (NHL)": ["nhl", 4697413],
    "Max Bredeson (NFL)": ["nfl", 4878695],
    "Max Brosmer (NFL)": ["nfl", 4573398],
    "Max Christie (NBA)": ["nba", 4432582],
    "Max Clark (MLB)": ["mlb", 5148964],
    "Max Crozier (NHL)": ["nhl", 5104716],
    "Max Domi (NHL)": ["nhl", 3042014],
    "Max Duggan (NFL)": ["nfl", 4427105],
    "Max Fried (MLB)": ["mlb", 32685],
    "Max Klare (NFL)": ["nfl", 4833029],
    "Max Meyer (MLB)": ["mlb", 4345164],
    "Max Muncy (ATH) (MLB)": ["mlb", 4872686],
    "Max Muncy (LAD) (MLB)": ["mlb", 33303],
    "Max Pacioretty (NHL)": ["nhl", 4005],
    "Max Sasson (NHL)": ["nhl", 4996099],
    "Max Scherzer (MLB)": ["mlb", 28976],
    "Max Shulga (NBA)": ["nba", 4701992],
    "Max Strus (NBA)": ["nba", 4065778],
    "Maxi Kleber (NBA)": ["nba", 2960236],
    "Maxim Shabanov (NHL)": ["nhl", 5302535],
    "Maxim Tsyplakov (NHL)": ["nhl", 5212753],
    "Maxime Raynaud (NBA)": ["nba", 4898371],
    "Maxwell Crozier (NHL)": ["nhl", 5104716],
    "McKinley Wright IV (NBA)": ["nba", 4278507],
    "Mecole Hardman Jr. (NFL)": ["nfl", 4035004],
    "Meleek Thomas (NBA)": ["nba", 5041951],
    "Merrill Kelly (MLB)": ["mlb", 32968],
    "Micah Peavy (NBA)": ["nba", 4432185],
    "Micah Potter (NBA)": ["nba", 4066399],
    "Michael Amadio (NHL)": ["nhl", 3149829],
    "Michael Arroyo (MLB)": ["mlb", 5124097],
    "Michael Badgley (NFL)": ["nfl", 3123052],
    "Michael Bandy (NFL)": ["nfl", 4034704],
    "Michael Blunden (NHL)": ["nhl", 3345],
    "Michael Brandsegg-Nygard (NHL)": ["nhl", 5216883],
    "Michael Bunting (NHL)": ["nhl", 3149603],
    "Michael Burton (NFL)": ["nfl", 2515270],
    "Michael Busch (MLB)": ["mlb", 42415],
    "Michael Carcone (NHL)": ["nhl", 4031645],
    "Michael Carter (NFL)": ["nfl", 4240657],
    "Michael Cobbins (NBA)": ["nba", 2530751],
    "Michael Conforto (MLB)": ["mlb", 33711],
    "Michael DiPietro (NHL)": ["nhl", 4392765],
    "Michael Eyssimont (NHL)": ["nhl", 4270247],
    "Michael Hage (NHL)": ["nhl", 5216889],
    "Michael Harris II (MLB)": ["mlb", 42470],
    "Michael Kesselring (NHL)": ["nhl", 4331604],
    "Michael King (MLB)": ["mlb", 40429],
    "Michael Massey (MLB)": ["mlb", 4109223],
    "Michael Mayer (NFL)": ["nfl", 4429086],
    "Michael McCarron (NHL)": ["nhl", 3042048],
    "Michael McGreevy (MLB)": ["mlb", 4424141],
    "Michael Misa (NHL)": ["nhl", 5291934],
    "Michael Penix Jr. (NFL)": ["nfl", 4360423],
    "Michael Petersen (MLB)": ["mlb", 41824],
    "Michael Pittman Jr. (NFL)": ["nfl", 4035687],
    "Michael Porter Jr. (NBA)": ["nba", 4278104],
    "Michael Pratt (NFL)": ["nfl", 4685039],
    "Michael Rasmussen (NHL)": ["nhl", 4233576],
    "Michael Soroka (MLB)": ["mlb", 34984],
    "Michael Trigg (NFL)": ["nfl", 4594749],
    "Michael Wacha (MLB)": ["mlb", 32640],
    "Michael Wiley (NFL)": ["nfl", 4569156],
    "Michael Wilson (NFL)": ["nfl", 4360761],
    "Michal Postava (NHL)": ["nhl", 5302578],
    "Mick Abel (MLB)": ["mlb", 4718970],
    "Mickey Gasper (MLB)": ["mlb", 5132012],
    "Mickey Moniak (MLB)": ["mlb", 36181],
    "Miguel Amaya (MLB)": ["mlb", 38905],
    "Miguel Andujar (MLB)": ["mlb", 33743],
    "Miguel Rojas (MLB)": ["mlb", 30791],
    "Miguel Ullola (MLB)": ["mlb", 5124163],
    "Miguel Vargas (MLB)": ["mlb", 42453],
    "Mika Zibanejad (NHL)": ["nhl", 2562637],
    "Mikael Backlund (NHL)": ["nhl", 3797],
    "Mikael Granlund (NHL)": ["nhl", 5831],
    "Mikal Bridges (NBA)": ["nba", 3147657],
    "Mike Boone (NFL)": ["nfl", 3139033],
    "Mike Burrows (MLB)": ["mlb", 4918155],
    "Mike Conley (NBA)": ["nba", 3195],
    "Mike Evans (NFL)": ["nfl", 16737],
    "Mike Gesicki (NFL)": ["nfl", 3116164],
    "Mike James (NBA)": ["nba", 2528096],
    "Mike Matheson (NHL)": ["nhl", 2976851],
    "Mike Reilly (NHL)": ["nhl", 2563077],
    "Mike Sirota (MLB)": ["mlb", 4956819],
    "Mike Tobey (NBA)": ["nba", 2982337],
    "Mike Trout (MLB)": ["mlb", 30836],
    "Mike Washington Jr. (NFL)": ["nfl", 4686658],
    "Mike White (NFL)": ["nfl", 3051381],
    "Mike Williams (NFL)": ["nfl", 3045138],
    "Mike Yastrzemski (MLB)": ["mlb", 33341],
    "Mikel Brown Jr. (NBA)": ["nba", 5101761],
    "Mikey Anderson (NHL)": ["nhl", 4588178],
    "Mikhail Sergachev (NHL)": ["nhl", 4024868],
    "Mikko Rantanen (NHL)": ["nhl", 3899938],
    "Miles Bridges (NBA)": ["nba", 4066383],
    "Miles Kelly (NBA)": ["nba", 4696317],
    "Miles McBride (NBA)": ["nba", 4431823],
    "Mindaugas Kuzminskas (NBA)": ["nba", 3138120],
    "Miro Heiskanen (NHL)": ["nhl", 4233536],
    "Mitch Bratt (MLB)": ["mlb", 5123768],
    "Mitch Keller (MLB)": ["mlb", 33722],
    "Mitch Marner (NHL)": ["nhl", 3899937],
    "Mitchell Evans (NFL)": ["nfl", 4683243],
    "Mitchell Robinson (NBA)": ["nba", 4351852],
    "Mitchell Tinsley (NFL)": ["nfl", 4690070],
    "Mitchell Trubisky (NFL)": ["nfl", 3039707],
    "Mitchell Watt (NBA)": ["nba", 2328615],
    "Mitchell Wilcox (NFL)": ["nfl", 3923392],
    "MJ Walker (NBA)": ["nba", 4277854],
    "Mo Alie-Cox (NFL)": ["nfl", 2998565],
    "Mo Bamba (NBA)": ["nba", 4277919],
    "Mohamed Diawara (NBA)": ["nba", 5289900],
    "Moises Ballesteros (MLB)": ["mlb", 4987418],
    "Monta Ellis (NBA)": ["nba", 2751],
    "Monte Morris (NBA)": ["nba", 3059310],
    "Montorie Foster Jr. (NFL)": ["nfl", 4600597],
    "Mookie Betts (MLB)": ["mlb", 33039],
    "Morez Johnson Jr. (NBA)": ["nba", 4873153],
    "Morgan Barron (NHL)": ["nhl", 4316970],
    "Morgan Frost (NHL)": ["nhl", 4233685],
    "Morgan Geekie (NHL)": ["nhl", 4268466],
    "Morgan Rielly (NHL)": ["nhl", 2976833],
    "Moritz Seider (NHL)": ["nhl", 4565227],
    "Moritz Wagner (NBA)": ["nba", 3150844],
    "Moses Brown (NBA)": ["nba", 4397126],
    "Moses Moody (NBA)": ["nba", 4432171],
    "Moses Wright (NBA)": ["nba", 4277871],
    "Mouhamed Gueye (NBA)": ["nba", 4712863],
    "Moussa Cisse (NBA)": ["nba", 4701208],
    "Moussa Diabate (NBA)": ["nba", 4433249],
    "Munetaka Murakami (MLB)": ["mlb", 4872595],
    "Myles Gaskin (NFL)": ["nfl", 3886818],
    "Myles Price (NFL)": ["nfl", 4430656],
    "Myles Turner (NBA)": ["nba", 3133628],
    "Myron Gardner (NBA)": ["nba", 4431772],
    "Nae'Qwan Tomlin (NBA)": ["nba", 5106268],
    "Najee Harris (NFL)": ["nfl", 4241457],
    "Naji Marshall (NBA)": ["nba", 4278594],
    "Nasim Nunez (MLB)": ["mlb", 4728688],
    "Nate Adkins (NFL)": ["nfl", 4383440],
    "Nate Ament (NBA)": ["nba", 5164559],
    "Nate Boerkircher (NFL)": ["nfl", 4686248],
    "Nate Carter (NFL)": ["nfl", 4605841],
    "Nate Danielson (NHL)": ["nhl", 5149175],
    "Nate Darling (NBA)": ["nba", 4067069],
    "Nate Lavender (MLB)": ["mlb", 4424442],
    "Nate Pearson (MLB)": ["mlb", 39646],
    "Nate Schmidt (NHL)": ["nhl", 3024798],
    "Nate Williams (NBA)": ["nba", 4397821],
    "Nate Wolters (NBA)": ["nba", 2491079],
    "Nathan Carter (NFL)": ["nfl", 4605841],
    "Nathan Church (MLB)": ["mlb", 4843048],
    "Nathan Eovaldi (MLB)": ["mlb", 31174],
    "Nathan Knight (NBA)": ["nba", 4067325],
    "Nathan Lukes (MLB)": ["mlb", 35682],
    "Nathan MacKinnon (NHL)": ["nhl", 3041969],
    "Nathaniel Lowe (MLB)": ["mlb", 40538],
    "Naz Mitrou-Long (NBA)": ["nba", 2990968],
    "Naz Reid (NBA)": ["nba", 4396971],
    "Nazem Kadri (NHL)": ["nhl", 5349],
    "Neal Pionk (NHL)": ["nhl", 3988847],
    "Neemias Queta (NBA)": ["nba", 4397424],
    "Nelson Agholor (NFL)": ["nfl", 2971618],
    "Nic Claxton (NBA)": ["nba", 4278067],
    "Nic Dowd (NHL)": ["nhl", 3025616],
    "Nicholas Singleton (NFL)": ["nfl", 4685555],
    "Nick Blankenburg (NHL)": ["nhl", 4781550],
    "Nick Chubb (NFL)": ["nfl", 3128720],
    "Nick Cousins (NHL)": ["nhl", 2563027],
    "Nick Foligno (NHL)": ["nhl", 3535],
    "Nick Folk (NFL)": ["nfl", 10621],
    "Nick Fortes (MLB)": ["mlb", 41674],
    "Nick Gonzales (MLB)": ["mlb", 4311634],
    "Nick Holden (NHL)": ["nhl", 3884],
    "Nick Jensen (NHL)": ["nhl", 3025608],
    "Nick Kurtz (MLB)": ["mlb", 4966637],
    "Nick Lardis (NHL)": ["nhl", 5173765],
    "Nick Lodolo (MLB)": ["mlb", 42433],
    "Nick Loftin (MLB)": ["mlb", 4314013],
    "Nick Martinelli (NBA)": ["nba", 5105832],
    "Nick Martinez (MLB)": ["mlb", 33372],
    "Nick Mullens (NFL)": ["nfl", 3059989],
    "Nick Muse (NFL)": ["nfl", 4249624],
    "Nick Paul (NHL)": ["nhl", 3042111],
    "Nick Perbix (NHL)": ["nhl", 4419638],
    "Nick Pivetta (MLB)": ["mlb", 36071],
    "Nick Richards (NBA)": ["nba", 4278076],
    "Nick Robertson (NHL)": ["nhl", 4565275],
    "Nick Schmaltz (NHL)": ["nhl", 3114770],
    "Nick Seeler (NHL)": ["nhl", 2564164],
    "Nick Smith Jr. (NBA)": ["nba", 4683686],
    "Nick Sogard (MLB)": ["mlb", 42979],
    "Nick Suzuki (NHL)": ["nhl", 4233594],
    "Nick Vannett (NFL)": ["nfl", 2576399],
    "Nick Westbrook-Ikhine (NFL)": ["nfl", 3929785],
    "Nickeil Alexander-Walker (NBA)": ["nba", 4278039],
    "Nico Collins (NFL)": ["nfl", 4258173],
    "Nico Daws (NHL)": ["nhl", 4697683],
    "Nico Hischier (NHL)": ["nhl", 4233555],
    "Nico Hoerner (MLB)": ["mlb", 41219],
    "Nicolas Batum (NBA)": ["nba", 3416],
    "Nicolas Deslauriers (NHL)": ["nhl", 5193],
    "Nicolas Hague (NHL)": ["nhl", 4233870],
    "Nicolas Roy (NHL)": ["nhl", 3943996],
    "Nicolo Melli (NBA)": ["nba", 4341],
    "Nigel Hayes-Davis (NBA)": ["nba", 3059409],
    "Nikita Klepov (NHL)": ["nhl", 5361658],
    "Nikita Kucherov (NHL)": ["nhl", 2563060],
    "Nikita Nesterenko (NHL)": ["nhl", 4755696],
    "Nikita Tolopilo (NHL)": ["nhl", 5188534],
    "Nikita Zadorov (NHL)": ["nhl", 3042021],
    "Nikita Zaitsev (NHL)": ["nhl", 4010739],
    "Nikko Remigio (NFL)": ["nfl", 4372716],
    "Niko Mikkola (NHL)": ["nhl", 3942354],
    "Nikola Durisic (NBA)": ["nba", 5144067],
    "Nikola Jokic (NBA)": ["nba", 3112335],
    "Nikola Jovic (NBA)": ["nba", 4997528],
    "Nikola Milutinov (NBA)": ["nba", 3892893],
    "Nikola Radicevic (NBA)": ["nba", 3902065],
    "Nikola Topic (NBA)": ["nba", 5159925],
    "Nikola Vucevic (NBA)": ["nba", 6478],
    "Nikolaj Ehlers (NHL)": ["nhl", 3114741],
    "Nils Hoglander (NHL)": ["nhl", 4565263],
    "Nils Lundkvist (NHL)": ["nhl", 4352800],
    "Nino Niederreiter (NHL)": ["nhl", 5511],
    "Nique Clifford (NBA)": ["nba", 4702384],
    "Noa Essengue (NBA)": ["nba", 5242496],
    "Noah Brown (NFL)": ["nfl", 3121409],
    "Noah Cameron (MLB)": ["mlb", 4417208],
    "Noah Cates (NHL)": ["nhl", 4419682],
    "Noah Clowney (NBA)": ["nba", 4712896],
    "Noah Dobson (NHL)": ["nhl", 4352732],
    "Noah Fant (NFL)": ["nfl", 4036131],
    "Noah Gray (NFL)": ["nfl", 4240472],
    "Noah Hanifin (NHL)": ["nhl", 3652964],
    "Noah Laba (NHL)": ["nhl", 5188370],
    "Noah Ostlund (NHL)": ["nhl", 5080160],
    "Noah Penda (NBA)": ["nba", 5214637],
    "Noah Schultz (MLB)": ["mlb", 5080754],
    "Noah Warren (NHL)": ["nhl", 5080210],
    "Noel Acciari (NHL)": ["nhl", 3096237],
    "Noelvi Marte (MLB)": ["mlb", 41307],
    "Nolan Allan (NHL)": ["nhl", 4874749],
    "Nolan Arenado (MLB)": ["mlb", 31261],
    "Nolan Gorman (MLB)": ["mlb", 41174],
    "Nolan McLean (MLB)": ["mlb", 4433874],
    "Nolan Schanuel (MLB)": ["mlb", 4739755],
    "Nolan Traore (NBA)": ["nba", 5279130],
    "Norchad Omier (NBA)": ["nba", 4702134],
    "Norman Powell (NBA)": ["nba", 2595516],
    "Obi Toppin (NBA)": ["nba", 4278355],
    "Ochai Agbaji (NBA)": ["nba", 4397018],
    "Odell Beckham Jr. (NFL)": ["nfl", 16733],
    "OG Anunoby (NBA)": ["nba", 3934719],
    "Ognjen Jaramaz (NBA)": ["nba", 4017857],
    "Okaro White (NBA)": ["nba", 2528473],
    "Olamide Zaccheaus (NFL)": ["nfl", 3917914],
    "Olen Zellweger (NHL)": ["nhl", 4874863],
    "Oliver Bjorkstrand (NHL)": ["nhl", 3042095],
    "Oliver Bonk (NHL)": ["nhl", 5149199],
    "Oliver Ekman-Larsson (NHL)": ["nhl", 5488],
    "Oliver Kapanen (NHL)": ["nhl", 4874943],
    "Oliver Moore (NHL)": ["nhl", 5149194],
    "Olivier Sarr (NBA)": ["nba", 4278046],
    "Olivier-Maxence Prosper (NBA)": ["nba", 4595400],
    "Olli Maatta (NHL)": ["nhl", 2976850],
    "Ollie Gordon II (NFL)": ["nfl", 4711533],
    "Omar Cooper Jr. (NFL)": ["nfl", 4723820],
    "Omarion Hampton (NFL)": ["nfl", 4685382],
    "Omer Yurtseven (NBA)": ["nba", 3074213],
    "Ondrej Palat (NHL)": ["nhl", 2590389],
    "Oneil Cruz (MLB)": ["mlb", 39712],
    "Onyeka Okongwu (NBA)": ["nba", 4431680],
    "Orion Kerkering (MLB)": ["mlb", 4630789],
    "Orlando Robinson (NBA)": ["nba", 4593049],
    "Oronde Gadsden (NFL)": ["nfl", 4595342],
    "Oscar Delp (NFL)": ["nfl", 4702559],
    "Oscar Tshiebwe (NBA)": ["nba", 4432827],
    "Oshae Brissett (NBA)": ["nba", 4278031],
    "Oskar Back (NHL)": ["nhl", 4894398],
    "Osleivis Basabe (MLB)": ["mlb", 42474],
    "Oso Ighodaro (NBA)": ["nba", 4601023],
    "Oswald Peraza (MLB)": ["mlb", 42479],
    "Otega Oweh (NBA)": ["nba", 5106270],
    "Otto Lopez (MLB)": ["mlb", 41917],
    "Ousmane Dieng (NBA)": ["nba", 4997526],
    "Owen Caissie (MLB)": ["mlb", 4917685],
    "Owen Michaels (NHL)": ["nhl", 5206840],
    "Owen Power (NHL)": ["nhl", 4781556],
    "Owen Tippett (NHL)": ["nhl", 4392072],
    "Owen Wright (NFL)": ["nfl", 4249616],
    "Ozzie Albies (MLB)": ["mlb", 33783],
    "P.A. Parenteau (NHL)": ["nhl", 2101],
    "P.J. Hairston (NBA)": ["nba", 2594816],
    "P.J. Tucker (NBA)": ["nba", 3033],
    "P.J. Washington (NBA)": ["nba", 4278078],
    "Pablo Lopez (MLB)": ["mlb", 39671],
    "Pacome Dadiet (NBA)": ["nba", 5211983],
    "Paolo Banchero (NBA)": ["nba", 4432573],
    "Parker Kelly (NHL)": ["nhl", 4392309],
    "Parker Messick (MLB)": ["mlb", 4619898],
    "Parker Romo (NFL)": ["nfl", 4051167],
    "Parker Washington (NFL)": ["nfl", 4432620],
    "Parker Wotherspoon (NHL)": ["nhl", 3942638],
    "Parris Campbell (NFL)": ["nfl", 3121410],
    "Pascal Siakam (NBA)": ["nba", 3149673],
    "Pat Bryant (NFL)": ["nfl", 4600981],
    "Pat Connaughton (NBA)": ["nba", 2578239],
    "Pat Freiermuth (NFL)": ["nfl", 4361411],
    "Pat Maroon (NHL)": ["nhl", 3853],
    "Pat Spencer (NBA)": ["nba", 4592714],
    "Patric Young (NBA)": ["nba", 2527926],
    "Patrick Bailey (MLB)": ["mlb", 4345843],
    "Patrick Herbert (NFL)": ["nfl", 4429811],
    "Patrick Kane (NHL)": ["nhl", 3735],
    "Patrick Mahomes (NFL)": ["nfl", 3139477],
    "Patrick Ricard (NFL)": ["nfl", 2975417],
    "Patrick Sandoval (MLB)": ["mlb", 40975],
    "Patrick Williams (NBA)": ["nba", 4431687],
    "Patrik Laine (NHL)": ["nhl", 4024820],
    "Patty Mills (NBA)": ["nba", 4004],
    "Paul Blackburn (MLB)": ["mlb", 32776],
    "Paul Cotter (NHL)": ["nhl", 4331579],
    "Paul George (NBA)": ["nba", 4251],
    "Paul Goldschmidt (MLB)": ["mlb", 31027],
    "Paul Reed (NBA)": ["nba", 4278562],
    "Paul Sewald (MLB)": ["mlb", 35009],
    "Paul Skenes (MLB)": ["mlb", 4719507],
    "Paul Watson (NBA)": ["nba", 3058030],
    "Paul Zipser (NBA)": ["nba", 3893023],
    "Pavel Buchnevich (NHL)": ["nhl", 3042081],
    "Pavel Dorofeyev (NHL)": ["nhl", 4587588],
    "Pavel Mintyukov (NHL)": ["nhl", 5080154],
    "Pavel Zacha (NHL)": ["nhl", 3899949],
    "Payne Durham (NFL)": ["nfl", 4372505],
    "Payton Pritchard (NBA)": ["nba", 4066354],
    "Payton Tolle (MLB)": ["mlb", 4966140],
    "Pedro Ramirez (MLB)": ["mlb", 5012995],
    "Pelle Larsson (NBA)": ["nba", 4601025],
    "Pete Alonso (MLB)": ["mlb", 37498],
    "Pete Crow-Armstrong (MLB)": ["mlb", 4717833],
    "Pete Fairbanks (MLB)": ["mlb", 42180],
    "Pete Nance (NBA)": ["nba", 4397233],
    "Peter Lambert (MLB)": ["mlb", 39898],
    "Peyton Krebs (NHL)": ["nhl", 4565238],
    "Peyton Watson (NBA)": ["nba", 4576087],
    "Pharaoh Brown (NFL)": ["nfl", 2971281],
    "Phil Mafah (NFL)": ["nfl", 4431562],
    "Phil Pressey (NBA)": ["nba", 2530722],
    "Philip Broberg (NHL)": ["nhl", 4565229],
    "Philip Rivers (NFL)": ["nfl", 5529],
    "Philip Tomasino (NHL)": ["nhl", 4565245],
    "Philipp Grubauer (NHL)": ["nhl", 5657],
    "Phillip Danault (NHL)": ["nhl", 2562602],
    "Pierre Deshawn Jackson (NBA)": ["nba", 2578204],
    "Pierre Strong Jr. (NFL)": ["nfl", 4249836],
    "Pierre-Cedric Labrie (NHL)": ["nhl", 3809],
    "Pierre-Luc Dubois (NHL)": ["nhl", 4024833],
    "Pius Suter (NHL)": ["nhl", 4271732],
    "PJ Hall (NBA)": ["nba", 4701225],
    "Pontus Holmberg (NHL)": ["nhl", 4588205],
    "Porter Martone (NHL)": ["nhl", 5291941],
    "Precious Achiuwa (NBA)": ["nba", 4431679],
    "Puka Nacua (NFL)": ["nfl", 4426515],
    "Pyotr Kochetkov (NHL)": ["nhl", 4565259],
    "Quentin Grimes (NBA)": ["nba", 4397014],
    "Quentin Johnston (NFL)": ["nfl", 4429025],
    "Quenton Jackson (NBA)": ["nba", 4592829],
    "Quez Watkins (NFL)": ["nfl", 4050373],
    "Quinn Cook (NBA)": ["nba", 2566745],
    "Quinn Ewers (NFL)": ["nfl", 4889929],
    "Quinn Hughes (NHL)": ["nhl", 4320548],
    "Quinn Hutson (NHL)": ["nhl", 5136660],
    "Quinn Mathews (MLB)": ["mlb", 4837405],
    "Quinn Priester (MLB)": ["mlb", 42449],
    "Quinshon Judkins (NFL)": ["nfl", 4685702],
    "Quinten Post (NBA)": ["nba", 4593016],
    "Quinton Byfield (NHL)": ["nhl", 4697383],
    "Rachaad White (NFL)": ["nfl", 4697815],
    "Rade Zagorac (NBA)": ["nba", 3893060],
    "Radek Faksa (NHL)": ["nhl", 2976842],
    "Radko Gudas (NHL)": ["nhl", 5502],
    "Rafael Devers (MLB)": ["mlb", 33859],
    "Rafael Flores Jr. (MLB)": ["mlb", 5131743],
    "Raheem Blackshear (NFL)": ["nfl", 4259308],
    "Raheem Mostert (NFL)": ["nfl", 2576414],
    "Raheim Sanders (NFL)": ["nfl", 4601080],
    "Rainiel Rodriguez (MLB)": ["mlb", 5289250],
    "Raisel Iglesias (MLB)": ["mlb", 33618],
    "Rakeem Christmas (NBA)": ["nba", 2596110],
    "Ralphy Velazquez (MLB)": ["mlb", 5149073],
    "Ramon Laureano (MLB)": ["mlb", 35142],
    "Randal Grichuk (MLB)": ["mlb", 31399],
    "Randy Arozarena (MLB)": ["mlb", 36488],
    "Randy Dobnak (MLB)": ["mlb", 42214],
    "Randy Vasquez (MLB)": ["mlb", 4722847],
    "Ranger Suarez (MLB)": ["mlb", 39817],
    "Rashad Vaughn (NBA)": ["nba", 3137733],
    "Rashee Rice (NFL)": ["nfl", 4428331],
    "Rasheen Ali (NFL)": ["nfl", 4690013],
    "Rasheer Fleming (NBA)": ["nba", 5105977],
    "Rashid Shaheed (NFL)": ["nfl", 4032473],
    "Rashod Bateman (NFL)": ["nfl", 4360939],
    "Rasmus Andersson (NHL)": ["nhl", 3904186],
    "Rasmus Dahlin (NHL)": ["nhl", 4294163],
    "Rasmus Ristolainen (NHL)": ["nhl", 3041999],
    "Rasmus Sandin (NHL)": ["nhl", 4352803],
    "Ray Davis (NFL)": ["nfl", 4429501],
    "Ray-Ray McCloud III (NFL)": ["nfl", 3728262],
    "Rayan Rupert (NBA)": ["nba", 5099752],
    "RayJ Dennis (NBA)": ["nba", 4431941],
    "Reed Sheppard (NBA)": ["nba", 4711272],
    "Reggie Gilliam (NFL)": ["nfl", 4039505],
    "Reggie Jackson (NBA)": ["nba", 6443],
    "Reggie Virgil (NFL)": ["nfl", 4869132],
    "Reid Detmers (MLB)": ["mlb", 4326697],
    "Reynaldo Lopez (MLB)": ["mlb", 33860],
    "Rhamondre Stevenson (NFL)": ["nfl", 4569173],
    "Rhett Lowder (MLB)": ["mlb", 4758873],
    "Rhys Hoskins (MLB)": ["mlb", 35291],
    "Richard Solomon (NBA)": ["nba", 2531214],
    "Richaun Holmes (NBA)": ["nba", 2993370],
    "Richie Palacios (MLB)": ["mlb", 41359],
    "Richie Saunders (NBA)": ["nba", 5105462],
    "Rickard Rakell (NHL)": ["nhl", 2562629],
    "Ricky Pearsall (NFL)": ["nfl", 4428209],
    "Rico Dowdle (NFL)": ["nfl", 4038815],
    "Rico Garcia (MLB)": ["mlb", 41382],
    "Ridly Greig (NHL)": ["nhl", 4697411],
    "Riley Greene (MLB)": ["mlb", 42179],
    "Riley Leonard (NFL)": ["nfl", 4683423],
    "Riley Minix (NBA)": ["nba", 5177362],
    "Riley Nowakowski (NFL)": ["nfl", 4693370],
    "Riley O'Brien (MLB)": ["mlb", 41509],
    "Riley Patterson (NFL)": ["nfl", 4243371],
    "River Ryan (MLB)": ["mlb", 5007605],
    "RJ Barrett (NBA)": ["nba", 4395625],
    "RJ Harvey (NFL)": ["nfl", 4568490],
    "Rob Dillingham (NBA)": ["nba", 4684275],
    "Robbie Ouzts (NFL)": ["nfl", 4691688],
    "Robbie Ray (MLB)": ["mlb", 32175],
    "Robby Snelling (MLB)": ["mlb", 5080753],
    "Robert Bortuzzo (NHL)": ["nhl", 4916],
    "Robert Covington (NBA)": ["nba", 2490620],
    "Robert Garcia (MLB)": ["mlb", 5125167],
    "Robert Gasser (MLB)": ["mlb", 4918251],
    "Robert Henry Jr. (NFL)": ["nfl", 5151317],
    "Robert Suarez (MLB)": ["mlb", 4148749],
    "Robert Thomas (NHL)": ["nhl", 4233637],
    "Robert Tonyan (NFL)": ["nfl", 2975674],
    "Robert Williams III (NBA)": ["nba", 4066211],
    "Robert Woods (NFL)": ["nfl", 15880],
    "Rocco Zikarsky (NBA)": ["nba", 5157587],
    "Roger McQueen (NHL)": ["nhl", 5291946],
    "Roki Sasaki (MLB)": ["mlb", 5134638],
    "Roman Anthony (MLB)": ["mlb", 5080767],
    "Roman Josi (NHL)": ["nhl", 5436],
    "Roman Kantserov (NHL)": ["nhl", 5149231],
    "Roman Wilson (NFL)": ["nfl", 4431492],
    "Rome Odunze (NFL)": ["nfl", 4431299],
    "Romeo Doubs (NFL)": ["nfl", 4361432],
    "Ron Baker (NBA)": ["nba", 2580349],
    "Ron Harper Jr. (NBA)": ["nba", 4397251],
    "Ronald Acuna Jr. (MLB)": ["mlb", 36185],
    "Ronald Holland II (NBA)": ["nba", 4683771],
    "Ronnie Rivers (NFL)": ["nfl", 4243003],
    "Roope Hintz (NHL)": ["nhl", 3904183],
    "Roschon Johnson (NFL)": ["nfl", 4426386],
    "Ross Colton (NHL)": ["nhl", 4392471],
    "Ross Johnston (NHL)": ["nhl", 3067822],
    "Royce Lewis (MLB)": ["mlb", 40635],
    "Royce O'Neale (NBA)": ["nba", 2583632],
    "Rudy Gobert (NBA)": ["nba", 3032976],
    "Rui Hachimura (NBA)": ["nba", 4066648],
    "Russ Smith (NBA)": ["nba", 2531038],
    "Russell Westbrook (NBA)": ["nba", 3468],
    "Russell Wilson (NFL)": ["nfl", 14881],
    "Rutger McGroarty (NHL)": ["nhl", 5080158],
    "Ryan Broekhoff (NBA)": ["nba", 2489693],
    "Ryan Conwell (NBA)": ["nba", 5107157],
    "Ryan Donato (NHL)": ["nhl", 3115033],
    "Ryan Dunn (NBA)": ["nba", 4888725],
    "Ryan Fitzgerald (NFL)": ["nfl", 4568263],
    "Ryan Flournoy (NFL)": ["nfl", 5083754],
    "Ryan Graves (NHL)": ["nhl", 3042122],
    "Ryan Greene (NHL)": ["nhl", 5080227],
    "Ryan Griffin (NFL)": ["nfl", 16140],
    "Ryan Gusto (MLB)": ["mlb", 5131986],
    "Ryan Hartman (NHL)": ["nhl", 3042063],
    "Ryan Helsley (MLB)": ["mlb", 39909],
    "Ryan Jeffers (MLB)": ["mlb", 41587],
    "Ryan Johnson (MLB)": ["mlb", 5007859],
    "Ryan Kalkbrenner (NBA)": ["nba", 4576060],
    "Ryan Leonard (NHL)": ["nhl", 5149172],
    "Ryan Lindgren (NHL)": ["nhl", 4271998],
    "Ryan McDonagh (NHL)": ["nhl", 4954],
    "Ryan McLeod (NHL)": ["nhl", 4378669],
    "Ryan McMahon (MLB)": ["mlb", 33247],
    "Ryan Miller (NFL)": ["nfl", 4369466],
    "Ryan Nembhard (NBA)": ["nba", 4433629],
    "Ryan Nugent-Hopkins (NHL)": ["nhl", 2562624],
    "Ryan O'Hearn (MLB)": ["mlb", 35183],
    "Ryan O'Reilly (NHL)": ["nhl", 5208],
    "Ryan Pepiot (MLB)": ["mlb", 4208281],
    "Ryan Poehling (NHL)": ["nhl", 4233668],
    "Ryan Pulock (NHL)": ["nhl", 3042019],
    "Ryan Reaves (NHL)": ["nhl", 3683],
    "Ryan Rollins (NBA)": ["nba", 4591725],
    "Ryan Shea (NHL)": ["nhl", 3942033],
    "Ryan Sloan (MLB)": ["mlb", 5218293],
    "Ryan Strome (NHL)": ["nhl", 2562636],
    "Ryan Suter (NHL)": ["nhl", 3047],
    "Ryan Suzuki (NHL)": ["nhl", 4565249],
    "Ryan Ufko (NHL)": ["nhl", 5188493],
    "Ryan Waldschmidt (MLB)": ["mlb", 5129344],
    "Ryan Walker (MLB)": ["mlb", 5000950],
    "Ryan Watson (MLB)": ["mlb", 5125911],
    "Ryan Weathers (MLB)": ["mlb", 41178],
    "Ryan Winterton (NHL)": ["nhl", 4894928],
    "Ryan Zeferjahn (MLB)": ["mlb", 4722057],
    "Ryker Evans (NHL)": ["nhl", 4874864],
    "Ryne Nelson (MLB)": ["mlb", 4916269],
    "Ryne Stanek (MLB)": ["mlb", 33301],
    "Saddiq Bey (NBA)": ["nba", 4397136],
    "Sal Cannella (NFL)": ["nfl", 4242536],
    "Sal Frelick (MLB)": ["mlb", 4417795],
    "Sal Stewart (MLB)": ["mlb", 5080771],
    "Salvador Perez (MLB)": ["mlb", 31127],
    "Salvon Ahmed (NFL)": ["nfl", 4243315],
    "Sam Antonacci (MLB)": ["mlb", 5207167],
    "Sam Bennett (NHL)": ["nhl", 3114732],
    "Sam Carrick (NHL)": ["nhl", 5474],
    "Sam Darnold (NFL)": ["nfl", 3912547],
    "Sam Dickinson (NHL)": ["nhl", 5216880],
    "Sam Ehlinger (NFL)": ["nfl", 4241820],
    "Sam Hauser (NBA)": ["nba", 4065804],
    "Sam Howell (NFL)": ["nfl", 4426875],
    "Sam LaPorta (NFL)": ["nfl", 4430027],
    "Sam Malinski (NHL)": ["nhl", 5136735],
    "Sam Merrill (NBA)": ["nba", 4066757],
    "Sam Montembeault (NHL)": ["nhl", 3942714],
    "Sam O'Reilly (NHL)": ["nhl", 5216901],
    "Sam Reinhart (NHL)": ["nhl", 3114722],
    "Sam Rinzel (NHL)": ["nhl", 5080173],
    "Sam Roush (NFL)": ["nfl", 4685504],
    "Sam Steel (NHL)": ["nhl", 4024998],
    "Samad Taylor (MLB)": ["mlb", 39710],
    "Samaje Perine (NFL)": ["nfl", 3116389],
    "Samuel Basallo (MLB)": ["mlb", 4917646],
    "Samuel Ersson (NHL)": ["nhl", 4587815],
    "Samuel Girard (NHL)": ["nhl", 4063401],
    "Sandis Vilmanis (NHL)": ["nhl", 5103599],
    "Sandro Mamukelashvili (NBA)": ["nba", 4278580],
    "Sandy Alcantara (MLB)": ["mlb", 35241],
    "Santi Aldama (NBA)": ["nba", 4593125],
    "Saquon Barkley (NFL)": ["nfl", 3929630],
    "SaRodorick Thompson Jr. (NFL)": ["nfl", 4362162],
    "Satnam Singh Bhamara (NBA)": ["nba", 3902067],
    "Savion Williams (NFL)": ["nfl", 4431487],
    "Scoot Henderson (NBA)": ["nba", 4683678],
    "Scott Laughton (NHL)": ["nhl", 2976848],
    "Scott Matlock (NFL)": ["nfl", 4373684],
    "Scott Wedgewood (NHL)": ["nhl", 5622],
    "Scottie Barnes (NBA)": ["nba", 4433134],
    "Scotty Hopson (NBA)": ["nba", 2328418],
    "Scotty Pippen Jr. (NBA)": ["nba", 4431785],
    "Seamus Casey (NHL)": ["nhl", 5080212],
    "Sean Burke (MLB)": ["mlb", 4867679],
    "Sean Clifford (NFL)": ["nfl", 4259592],
    "Sean Couturier (NHL)": ["nhl", 2562601],
    "Sean Durzi (NHL)": ["nhl", 4378683],
    "Sean Kilpatrick (NBA)": ["nba", 2488689],
    "Sean Kuraly (NHL)": ["nhl", 2564154],
    "Sean Manaea (MLB)": ["mlb", 33244],
    "Sean Monahan (NHL)": ["nhl", 3041996],
    "Sean Murphy (MLB)": ["mlb", 33557],
    "Sean Newcomb (MLB)": ["mlb", 33856],
    "Sean Tucker (NFL)": ["nfl", 4430871],
    "Sean Walker (NHL)": ["nhl", 4272905],
    "Sebastian Aho (NHL)": ["nhl", 3904173],
    "Sebastian Cossa (NHL)": ["nhl", 4874732],
    "Sebastian Walcott (MLB)": ["mlb", 5150947],
    "Seiya Suzuki (MLB)": ["mlb", 4142424],
    "Semaj Christon (NBA)": ["nba", 2983526],
    "Semyon Varlamov (NHL)": ["nhl", 3759],
    "Seranthony Dominguez (MLB)": ["mlb", 37793],
    "Sergei Bobrovsky (NHL)": ["nhl", 5571],
    "Sergei Murashov (NHL)": ["nhl", 5188366],
    "Sergio de Larrea (NBA)": ["nba", 5279129],
    "Seth Curry (NBA)": ["nba", 2326307],
    "Seth Hernandez (MLB)": ["mlb", 5293137],
    "Seth Jarvis (NHL)": ["nhl", 4697396],
    "Seth Jones (NHL)": ["nhl", 3041992],
    "Seth Lugo (MLB)": ["mlb", 34873],
    "Seth Lundy (NBA)": ["nba", 4431775],
    "Seth McGowan (NFL)": ["nfl", 4686468],
    "Seydou Traore (NFL)": ["nfl", 4714379],
    "Shabazz Muhammad (NBA)": ["nba", 2993875],
    "Shaedon Sharpe (NBA)": ["nba", 4914336],
    "Shai Gilgeous-Alexander (NBA)": ["nba", 4278073],
    "Shake Milton (NBA)": ["nba", 3915195],
    "Shakir Mukhamadullin (NHL)": ["nhl", 4697403],
    "Shane Baz (MLB)": ["mlb", 39639],
    "Shane Bieber (MLB)": ["mlb", 40912],
    "Shane Drohan (MLB)": ["mlb", 4315203],
    "Shane Larkin (NBA)": ["nba", 2596158],
    "Shane McClanahan (MLB)": ["mlb", 41199],
    "Shane Pinto (NHL)": ["nhl", 4565255],
    "Shane Smith (MLB)": ["mlb", 5201814],
    "Shane Wright (NHL)": ["nhl", 5080144],
    "Shaquille Harrison (NBA)": ["nba", 2991274],
    "Sharife Cooper (NBA)": ["nba", 4432173],
    "Shawn Long (NBA)": ["nba", 2581180],
    "Shayne Gostisbehere (NHL)": ["nhl", 3025662],
    "Shayne Whittington (NBA)": ["nba", 2491063],
    "Shea Langeliers (MLB)": ["mlb", 42598],
    "Shea Theodore (NHL)": ["nhl", 3042055],
    "Shedeur Sanders (NFL)": ["nfl", 4432762],
    "Sheldon Mac (NBA)": ["nba", 2594885],
    "Shohei Ohtani (MLB)": ["mlb", 39832],
    "Shota Imanaga (MLB)": ["mlb", 5134630],
    "Sidney Crosby (NHL)": ["nhl", 3114],
    "Sidy Cissoko (NBA)": ["nba", 5081727],
    "Sim Bhullar (NBA)": ["nba", 2596402],
    "Simi Fehoko (NFL)": ["nfl", 4360739],
    "Simon Benoit (NHL)": ["nhl", 4392642],
    "Simon Edvinsson (NHL)": ["nhl", 4874720],
    "Simon Holmstrom (NHL)": ["nhl", 4565244],
    "Simon Nemec (NHL)": ["nhl", 4915344],
    "Simone Fontecchio (NBA)": ["nba", 3899664],
    "Sion James (NBA)": ["nba", 4602025],
    "Sione Vaki (NFL)": ["nfl", 4912274],
    "Skal Labissiere (NBA)": ["nba", 3936296],
    "Skylar Thompson (NFL)": ["nfl", 4036419],
    "Skyler Bell (NFL)": ["nfl", 4683153],
    "Skyy Moore (NFL)": ["nfl", 4430191],
    "Slade Cecconi (MLB)": ["mlb", 41462],
    "Sonny Gray (MLB)": ["mlb", 32082],
    "Spencer Arrighetti (MLB)": ["mlb", 4726080],
    "Spencer Dinwiddie (NBA)": ["nba", 2580782],
    "Spencer Horwitz (MLB)": ["mlb", 4228472],
    "Spencer Jones (MLB)": ["mlb", 4867424],
    "Spencer Jones (NBA)": ["nba", 4592427],
    "Spencer Knight (NHL)": ["nhl", 4565234],
    "Spencer Miles (MLB)": ["mlb", 4833671],
    "Spencer Rattler (NFL)": ["nfl", 4426339],
    "Spencer Schwellenbach (MLB)": ["mlb", 4424862],
    "Spencer Shrader (NFL)": ["nfl", 4571557],
    "Spencer Steer (MLB)": ["mlb", 4722857],
    "Spencer Strider (MLB)": ["mlb", 4307825],
    "Spencer Torkelson (MLB)": ["mlb", 4424286],
    "Stefon Diggs (NFL)": ["nfl", 2976212],
    "Stephen Carlson (NFL)": ["nfl", 3948283],
    "Stephen Curry (NBA)": ["nba", 3975],
    "Stephen Halliday (NHL)": ["nhl", 5136706],
    "Stephen Kolek (MLB)": ["mlb", 5190073],
    "Stephon Castle (NBA)": ["nba", 4845367],
    "Sterling Shepard (NFL)": ["nfl", 2976592],
    "Stetson Bennett IV (NFL)": ["nfl", 4259553],
    "Steven Adams (NBA)": ["nba", 2991235],
    "Steven Cruz (MLB)": ["mlb", 5002931],
    "Steven Kwan (MLB)": ["mlb", 41996],
    "Steven Matz (MLB)": ["mlb", 33106],
    "Steven Okert (MLB)": ["mlb", 33716],
    "Steven Stamkos (NHL)": ["nhl", 5037],
    "Stuart Skinner (NHL)": ["nhl", 4268767],
    "Svi Mykhailiuk (NBA)": ["nba", 3133602],
    "T.J. Hockenson (NFL)": ["nfl", 4036133],
    "T.J. Hughes (NHL)": ["nhl", 5136616],
    "T.J. McConnell (NBA)": ["nba", 2530530],
    "Tacko Fall (NBA)": ["nba", 3904625],
    "Tage Thompson (NHL)": ["nhl", 4024988],
    "Tahj Brooks (NFL)": ["nfl", 4429299],
    "Tai Felton (NFL)": ["nfl", 4565185],
    "Taj Bradley (MLB)": ["mlb", 42480],
    "Taj Gibson (NBA)": ["nba", 3986],
    "Talen Horton-Tucker (NBA)": ["nba", 4396991],
    "Tamar Bates (NBA)": ["nba", 4683933],
    "Tank Bigsby (NFL)": ["nfl", 4429013],
    "Tank Dell (NFL)": ["nfl", 4366031],
    "Tanner Arkin (NFL)": ["nfl", 4683308],
    "Tanner Bibee (MLB)": ["mlb", 4345278],
    "Tanner Brown (NFL)": ["nfl", 4696736],
    "Tanner Gordon (MLB)": ["mlb", 4415658],
    "Tanner Hudson (NFL)": ["nfl", 3050481],
    "Tanner Jeannot (NHL)": ["nhl", 4064780],
    "Tanner Koziol (NFL)": ["nfl", 4917427],
    "Tanner McKee (NFL)": ["nfl", 4685201],
    "Tanner Scott (MLB)": ["mlb", 35135],
    "Tari Eason (NBA)": ["nba", 4433192],
    "Tarik Biberovic (NBA)": ["nba", 5148538],
    "Tarik Skubal (MLB)": ["mlb", 42409],
    "Tarris Reed Jr. (NBA)": ["nba", 5105809],
    "Tatsuya Imai (MLB)": ["mlb", 5330833],
    "Taurean Prince (NBA)": ["nba", 2990962],
    "Tay Martin (NFL)": ["nfl", 4245144],
    "Taylen Green (NFL)": ["nfl", 4431325],
    "Tayler Saucedo (MLB)": ["mlb", 42683],
    "Taylor Clarke (MLB)": ["mlb", 35277],
    "Taylor Hall (NHL)": ["nhl", 5428],
    "Taylor Heinicke (NFL)": ["nfl", 2565969],
    "Taylor Hendricks (NBA)": ["nba", 4684806],
    "Taylor Makar (NHL)": ["nhl", 4997080],
    "Taylor Raddysh (NHL)": ["nhl", 4063502],
    "Taylor Ward (MLB)": ["mlb", 34923],
    "Taysom Hill (NFL)": ["nfl", 2468609],
    "Taze Moore (NBA)": ["nba", 4066808],
    "Teagan Quitoriano (NFL)": ["nfl", 4374045],
    "Ted Hurst III (NFL)": ["nfl", 5220680],
    "Teddy Blueger (NHL)": ["nhl", 3024916],
    "Teddy Bridgewater (NFL)": ["nfl", 16728],
    "Tee Higgins (NFL)": ["nfl", 4239993],
    "Teoscar Hernandez (MLB)": ["mlb", 33377],
    "Terance Mann (NBA)": ["nba", 3907823],
    "Terence Davis (NBA)": ["nba", 3919454],
    "Terrance Ferguson (NFL)": ["nfl", 4570037],
    "Terrell Jennings (NFL)": ["nfl", 4427600],
    "Terrence Shannon Jr. (NBA)": ["nba", 4432847],
    "Terry McLaurin (NFL)": ["nfl", 3121422],
    "Terry Rozier (NBA)": ["nba", 3074752],
    "Terry Taylor (NBA)": ["nba", 4279815],
    "Tetairoa McMillan (NFL)": ["nfl", 4685472],
    "Teuvo Teravainen (NHL)": ["nhl", 2592095],
    "Tez Johnson (NFL)": ["nfl", 4608810],
    "Thanasis Antetokounmpo (NBA)": ["nba", 3102533],
    "Thatcher Demko (NHL)": ["nhl", 3096217],
    "Theo Gillen (MLB)": ["mlb", 5218298],
    "Theo Johnson (NFL)": ["nfl", 4429148],
    "Thomas Bryant (NBA)": ["nba", 3934723],
    "Thomas Chabot (NHL)": ["nhl", 3900219],
    "Thomas Harley (NHL)": ["nhl", 4565239],
    "Thomas Saggese (MLB)": ["mlb", 4999876],
    "Thomas Sorber (NBA)": ["nba", 5061603],
    "Thomas White (MLB)": ["mlb", 5149065],
    "Tidjane Salaun (NBA)": ["nba", 5211176],
    "Tij Iginla (NHL)": ["nhl", 5229186],
    "Tim Boyle (NFL)": ["nfl", 3045169],
    "Tim Frazier (NBA)": ["nba", 2488945],
    "Tim Hardaway Jr. (NBA)": ["nba", 2528210],
    "Tim Patrick (NFL)": ["nfl", 3134353],
    "Tim Quarterman (NBA)": ["nba", 4064730],
    "Tim Stutzle (NHL)": ["nhl", 4697384],
    "Tim Tawa (MLB)": ["mlb", 4345192],
    "Tim Washe (NHL)": ["nhl", 4996085],
    "Timo Meier (NHL)": ["nhl", 3899978],
    "Timothy Liljegren (NHL)": ["nhl", 4233618],
    "TJ Friedl (MLB)": ["mlb", 36020],
    "TJ Rumfield (MLB)": ["mlb", 5014349],
    "Tobe Awaka (NBA)": ["nba", 5105555],
    "Tobi Lawal (NBA)": ["nba", 5106040],
    "Tobias Harris (NBA)": ["nba", 6440],
    "Tolu Smith (NBA)": ["nba", 4397882],
    "Tom Kennedy (NFL)": ["nfl", 3126997],
    "Tom Willander (NHL)": ["nhl", 5149180],
    "Tom Wilson (NHL)": ["nhl", 2970615],
    "Tomas Hertl (NHL)": ["nhl", 2976844],
    "Tommy DeVito (NFL)": ["nfl", 4240391],
    "Tommy Edman (MLB)": ["mlb", 39907],
    "Tommy Novak (NHL)": ["nhl", 3942061],
    "Tommy Tremble (NFL)": ["nfl", 4372780],
    "Tommy White (MLB)": ["mlb", 4923961],
    "Tomoyuki Sugano (MLB)": ["mlb", 4142423],
    "Tony Bradley (NBA)": ["nba", 4065673],
    "Tony DeAngelo (NHL)": ["nhl", 3114769],
    "Tony Jones Jr. (NFL)": ["nfl", 4046676],
    "Tony Pollard (NFL)": ["nfl", 3916148],
    "Tony Santillan (MLB)": ["mlb", 40950],
    "Torrey Craig (NBA)": ["nba", 2528693],
    "Tory Horton (NFL)": ["nfl", 4597703],
    "Tosan Evbuomwan (NBA)": ["nba", 4597865],
    "Toumani Camara (NBA)": ["nba", 4431736],
    "Trae Young (NBA)": ["nba", 4277905],
    "Travis Bazzana (MLB)": ["mlb", 5007707],
    "Travis Etienne Jr. (NFL)": ["nfl", 4239996],
    "Travis Homer (NFL)": ["nfl", 4037457],
    "Travis Hunter (NFL)": ["nfl", 4685415],
    "Travis Kelce (NFL)": ["nfl", 15847],
    "Travis Konecny (NHL)": ["nhl", 3900169],
    "Travis Sanheim (NHL)": ["nhl", 3114757],
    "Trayce Jackson-Davis (NBA)": ["nba", 4431684],
    "Trayveon Williams (NFL)": ["nfl", 4035222],
    "Tre Johnson (NBA)": ["nba", 5238230],
    "Tre Jones (NBA)": ["nba", 4395626],
    "Tre Mann (NBA)": ["nba", 4432819],
    "Tre Tucker (NFL)": ["nfl", 4428718],
    "Tre' Harris (NFL)": ["nfl", 4686612],
    "Trea Turner (MLB)": ["mlb", 33710],
    "Trendon Watford (NBA)": ["nba", 4431675],
    "Trent Frederic (NHL)": ["nhl", 4024997],
    "Trent Grisham (MLB)": ["mlb", 34995],
    "Trent Harris (MLB)": ["mlb", 5201836],
    "TreVeyon Henderson (NFL)": ["nfl", 4432710],
    "Trevon Brazile (NBA)": ["nba", 4698719],
    "Trevon Duval (NBA)": ["nba", 4277842],
    "Trevor Connelly (NHL)": ["nhl", 5216887],
    "Trevor Etienne (NFL)": ["nfl", 4685350],
    "Trevor Larnach (MLB)": ["mlb", 41205],
    "Trevor Lawrence (NFL)": ["nfl", 4360310],
    "Trevor Lewis (NHL)": ["nhl", 3454],
    "Trevor McDonald (MLB)": ["mlb", 5185136],
    "Trevor Megill (MLB)": ["mlb", 40080],
    "Trevor Moore (NHL)": ["nhl", 3096186],
    "Trevor Rogers (MLB)": ["mlb", 39640],
    "Trevor Story (MLB)": ["mlb", 32150],
    "Trevor van Riemsdyk (NHL)": ["nhl", 3025524],
    "Trevor Zegras (NHL)": ["nhl", 4565230],
    "Trey Augustine (NHL)": ["nhl", 5149228],
    "Trey Benson (NFL)": ["nfl", 4429275],
    "Trey Jemison III (NBA)": ["nba", 4395623],
    "Trey Kaufman-Renn (NBA)": ["nba", 4897438],
    "Trey Lance (NFL)": ["nfl", 4383351],
    "Trey Lyles (NBA)": ["nba", 3136196],
    "Trey McBride (NFL)": ["nfl", 4361307],
    "Trey Murphy III (NBA)": ["nba", 4397688],
    "Trey Sermon (NFL)": ["nfl", 4241401],
    "Trey Smack (NFL)": ["nfl", 4869461],
    "Trey Yesavage (MLB)": ["mlb", 4949041],
    "Treylon Burks (NFL)": ["nfl", 4567156],
    "Tristan da Silva (NBA)": ["nba", 4702382],
    "Tristan Enaruna (NBA)": ["nba", 4431734],
    "Tristan Jarry (NHL)": ["nhl", 3042020],
    "Tristan Luneau (NHL)": ["nhl", 5080220],
    "Tristan Peters (MLB)": ["mlb", 5085893],
    "Tristan Thompson (NBA)": ["nba", 6474],
    "Tristan Vukcevic (NBA)": ["nba", 4997537],
    "Triston Casas (MLB)": ["mlb", 41180],
    "Troy Daniels (NBA)": ["nba", 2489530],
    "Troy Franklin (NFL)": ["nfl", 4431280],
    "Troy Hairston (NFL)": ["nfl", 4274040],
    "Troy Johnston (MLB)": ["mlb", 4346111],
    "Troy Melton (MLB)": ["mlb", 5294127],
    "Troy Stecher (NHL)": ["nhl", 3096102],
    "Troy Terry (NHL)": ["nhl", 3942905],
    "Troy Williams (NBA)": ["nba", 3078286],
    "Tua Tagovailoa (NFL)": ["nfl", 4241479],
    "Tucker Kraft (NFL)": ["nfl", 4572680],
    "Tutu Atwell (NFL)": ["nfl", 4360797],
    "Ty Chandler (NFL)": ["nfl", 4242431],
    "Ty Dellandrea (NHL)": ["nhl", 4352747],
    "Ty France (MLB)": ["mlb", 35591],
    "Ty Jerome (NBA)": ["nba", 4065733],
    "Ty Johnson (NFL)": ["nfl", 3915411],
    "Ty Simpson (NFL)": ["nfl", 4685522],
    "Ty-Shon Alexander (NBA)": ["nba", 4278555],
    "Tye Kartye (NHL)": ["nhl", 4588750],
    "Tyjae Spears (NFL)": ["nfl", 4428557],
    "Tylan Wallace (NFL)": ["nfl", 4241424],
    "Tyler Alexander (MLB)": ["mlb", 40360],
    "Tyler Allgeier (NFL)": ["nfl", 4373626],
    "Tyler Badie (NFL)": ["nfl", 4362748],
    "Tyler Bass (NFL)": ["nfl", 3917232],
    "Tyler Bertuzzi (NHL)": ["nhl", 3042056],
    "Tyler Bilodeau (NBA)": ["nba", 5105626],
    "Tyler Boyd (NFL)": ["nfl", 3045144],
    "Tyler Cavanaugh (NBA)": ["nba", 2982349],
    "Tyler Conklin (NFL)": ["nfl", 3915486],
    "Tyler Davis (NBA)": ["nba", 3947078],
    "Tyler Ennis (NBA)": ["nba", 3059281],
    "Tyler Glasnow (MLB)": ["mlb", 33190],
    "Tyler Goodson (NFL)": ["nfl", 4429676],
    "Tyler Harvey (NBA)": ["nba", 2578269],
    "Tyler Herro (NBA)": ["nba", 4395725],
    "Tyler Higbee (NFL)": ["nfl", 2573401],
    "Tyler Holton (MLB)": ["mlb", 3983833],
    "Tyler Huntley (NFL)": ["nfl", 4035671],
    "Tyler Johnson (NBA)": ["nba", 2530276],
    "Tyler Johnson (NFL)": ["nfl", 2310331],
    "Tyler Kleven (NHL)": ["nhl", 4697448],
    "Tyler Kolek (NBA)": ["nba", 4433225],
    "Tyler Lockett (NFL)": ["nfl", 2577327],
    "Tyler Loop (NFL)": ["nfl", 4697745],
    "Tyler Mahle (MLB)": ["mlb", 34973],
    "Tyler Myers (NHL)": ["nhl", 5052],
    "Tyler Nickel (NBA)": ["nba", 4838721],
    "Tyler O'Neill (MLB)": ["mlb", 34168],
    "Tyler Phillips (MLB)": ["mlb", 41247],
    "Tyler Rogers (MLB)": ["mlb", 34026],
    "Tyler Seguin (NHL)": ["nhl", 5430],
    "Tyler Shough (NFL)": ["nfl", 4360689],
    "Tyler Soderstrom (MLB)": ["mlb", 4686066],
    "Tyler Stephenson (MLB)": ["mlb", 34975],
    "Tyler Toffoli (NHL)": ["nhl", 5550],
    "Tyler Tolbert (MLB)": ["mlb", 4151063],
    "Tyler Warren (NFL)": ["nfl", 4431459],
    "Tyler Wells (MLB)": ["mlb", 4717904],
    "Tyquan Thornton (NFL)": ["nfl", 4362921],
    "Tyreek Hill (NFL)": ["nfl", 3116406],
    "Tyrel Bauer (NHL)": ["nhl", 4697648],
    "Tyrell Shavers (NFL)": ["nfl", 4241476],
    "Tyrese Haliburton (NBA)": ["nba", 4396993],
    "Tyrese Martin (NBA)": ["nba", 4397179],
    "Tyrese Maxey (NBA)": ["nba", 4431678],
    "Tyrese Proctor (NBA)": ["nba", 5023693],
    "Tyrod Taylor (NFL)": ["nfl", 14163],
    "Tyron Guerrero (MLB)": ["mlb", 33654],
    "Tyrone Taylor (MLB)": ["mlb", 32783],
    "Tyrone Tracy Jr. (NFL)": ["nfl", 4360516],
    "Tyson Bagent (NFL)": ["nfl", 4434153],
    "Tyson Foerster (NHL)": ["nhl", 4697406],
    "TyTy Washington Jr. (NBA)": ["nba", 4683749],
    "Tyus Jones (NBA)": ["nba", 3135046],
    "Udonis Haslem (NBA)": ["nba", 2184],
    "Ugonna Onyenso (NBA)": ["nba", 5037878],
    "Ukko-Pekka Luukkonen (NHL)": ["nhl", 4233889],
    "Ulrich Chomche (NBA)": ["nba", 5211984],
    "Ulysses Bentley IV (NFL)": ["nfl", 4426689],
    "Uvis Balinskis (NHL)": ["nhl", 5142461],
    "Valeri Nichushkin (NHL)": ["nhl", 3042003],
    "Van Jefferson (NFL)": ["nfl", 3930066],
    "Vander Blue (NBA)": ["nba", 2531039],
    "Vasilije Micic (NBA)": ["nba", 3102532],
    "Vasily Podkolzin (NHL)": ["nhl", 4565231],
    "Vaughn Grissom (MLB)": ["mlb", 42503],
    "Velus Jones Jr. (NFL)": ["nfl", 4035693],
    "Victor Caratini (MLB)": ["mlb", 33229],
    "Victor Eklund (NHL)": ["nhl", 5291952],
    "Victor Hedman (NHL)": ["nhl", 5157],
    "Victor Mesa Jr. (MLB)": ["mlb", 4917849],
    "Victor Olofsson (NHL)": ["nhl", 3151096],
    "Victor Scott II (MLB)": ["mlb", 4807220],
    "Victor Wembanyama (NBA)": ["nba", 5104157],
    "Viggo Bjorck (NHL)": ["nhl", 5361711],
    "Viking Gustafsson Nyberg (NHL)": ["nhl", 5275403],
    "Viktor Arvidsson (NHL)": ["nhl", 3120307],
    "Ville Heinola (NHL)": ["nhl", 4565241],
    "Ville Husso (NHL)": ["nhl", 3151137],
    "Ville Koivunen (NHL)": ["nhl", 4874911],
    "Vince Dunn (NHL)": ["nhl", 3904189],
    "Vince Shamar Hunter (NBA)": ["nba", 3057304],
    "Vince Williams Jr. (NBA)": ["nba", 4397227],
    "Vincent Desharnais (NHL)": ["nhl", 4392260],
    "Vincent Poirier (NBA)": ["nba", 4237215],
    "Vincent Trocheck (NHL)": ["nhl", 2563036],
    "Vinnie Pasquantino (MLB)": ["mlb", 4109109],
    "Vit Krejci (NBA)": ["nba", 4578893],
    "Vitek Vanecek (NHL)": ["nhl", 3114996],
    "VJ Edgecombe (NBA)": ["nba", 5124612],
    "Vladimir Guerrero Jr. (MLB)": ["mlb", 35002],
    "Vladimir Tarasenko (NHL)": ["nhl", 5837],
    "Vladislav Gavrikov (NHL)": ["nhl", 3942292],
    "Vladislav Goldin (NBA)": ["nba", 4700818],
    "Vladislav Kolyachonok (NHL)": ["nhl", 4565274],
    "Vlatko Cancar (NBA)": ["nba", 4230557],
    "Vsevolod Ishchenko (NBA)": ["nba", 5358755],
    "Wade Meckler (MLB)": ["mlb", 4424090],
    "Walbert Urena (MLB)": ["mlb", 5197476],
    "Walker Buehler (MLB)": ["mlb", 39251],
    "Walker Jenkins (MLB)": ["mlb", 5148963],
    "Walker Kessler (NBA)": ["nba", 4433136],
    "Walt Lemon Jr. (NBA)": ["nba", 2528586],
    "Walter Clayton Jr. (NBA)": ["nba", 4896372],
    "Wan'Dale Robinson (NFL)": ["nfl", 4569587],
    "Wang Zhelin (NBA)": ["nba", 4017850],
    "Warren Foegele (NHL)": ["nhl", 3151036],
    "Wayne Selden (NBA)": ["nba", 3059316],
    "Wendell Carter Jr. (NBA)": ["nba", 4277847],
    "Wesley Matthews (NBA)": ["nba", 4032],
    "Wiggo Sorensson (NHL)": ["nhl", 5364138],
    "Wil Lutz (NFL)": ["nfl", 2985659],
    "Will Borgen (NHL)": ["nhl", 3941946],
    "Will Cherry (NBA)": ["nba", 2489897],
    "Will Cuylle (NHL)": ["nhl", 4697468],
    "Will Howard (NFL)": ["nfl", 4429955],
    "Will Kacmarek (NFL)": ["nfl", 4880236],
    "Will Levis (NFL)": ["nfl", 4361418],
    "Will Mallory (NFL)": ["nfl", 4362523],
    "Will Reichard (NFL)": ["nfl", 4567104],
    "Will Richard (NBA)": ["nba", 4897262],
    "Will Riley (NBA)": ["nba", 5144126],
    "Will Shipley (NFL)": ["nfl", 4431545],
    "Will Smith (MLB)": ["mlb", 38309],
    "Will Smith (NHL)": ["nhl", 5149155],
    "Will Vest (MLB)": ["mlb", 41606],
    "Will Warren (MLB)": ["mlb", 5132011],
    "Willi Castro (MLB)": ["mlb", 34230],
    "William Carrier (NHL)": ["nhl", 3042054],
    "William Contreras (MLB)": ["mlb", 39895],
    "William Eklund (NHL)": ["nhl", 4874721],
    "William Karlsson (NHL)": ["nhl", 2563057],
    "William Nylander (NHL)": ["nhl", 3114736],
    "William Stromgren (NHL)": ["nhl", 4874893],
    "William Wallinder (NHL)": ["nhl", 4697436],
    "Willie Reed (NBA)": ["nba", 2326015],
    "Willson Contreras (MLB)": ["mlb", 32532],
    "Willy Adames (MLB)": ["mlb", 33675],
    "Wilyer Abreu (MLB)": ["mlb", 4990055],
    "Woody Marks (NFL)": ["nfl", 4429059],
    "Wyatt Aamodt (NHL)": ["nhl", 4419668],
    "Wyatt Cullen (NHL)": ["nhl", 5361662],
    "Wyatt Johnston (NHL)": ["nhl", 4874740],
    "Wyatt Kaiser (NHL)": ["nhl", 4697717],
    "Wyatt Langford (MLB)": ["mlb", 4719324],
    "Xander Bogaerts (MLB)": ["mlb", 31606],
    "Xavier Edwards (MLB)": ["mlb", 41326],
    "Xavier Gipson (NFL)": ["nfl", 4427278],
    "Xavier Hutchinson (NFL)": ["nfl", 4686422],
    "Xavier Legette (NFL)": ["nfl", 4430034],
    "Xavier Munford (NBA)": ["nba", 2983512],
    "Xavier Rathan-Mayes (NBA)": ["nba", 3059247],
    "Xavier Restrepo (NFL)": ["nfl", 4431353],
    "Xavier Smith (NFL)": ["nfl", 4386544],
    "Xavier Tillman (NBA)": ["nba", 4277964],
    "Xavier Worthy (NFL)": ["nfl", 4683062],
    "Yainer Diaz (MLB)": ["mlb", 4781491],
    "Yakov Trenin (NHL)": ["nhl", 3904188],
    "Yandy Diaz (MLB)": ["mlb", 33481],
    "Yang Hansen (NBA)": ["nba", 5217746],
    "Yanic Konan Niederhauser (NBA)": ["nba", 5108024],
    "Yanni Gourde (NHL)": ["nhl", 3094261],
    "Yaroslav Askarov (NHL)": ["nhl", 4697394],
    "Yaxel Lendeborg (NBA)": ["nba", 5175737],
    "Yegor Sharangovich (NHL)": ["nhl", 4587843],
    "Yennier Cano (MLB)": ["mlb", 35536],
    "Yoendrys Gomez (MLB)": ["mlb", 42898],
    "Yohan Ramirez (MLB)": ["mlb", 41893],
    "Yohandy Morales (MLB)": ["mlb", 4683376],
    "Yongxi Cui (NBA)": ["nba", 5159486],
    "Yordan Alvarez (MLB)": ["mlb", 36018],
    "Yoshinobu Yamamoto (MLB)": ["mlb", 4872587],
    "Younghoe Koo (NFL)": ["nfl", 3049899],
    "Yuki Kawamura (NBA)": ["nba", 5159895],
    "Yuki Matsui (MLB)": ["mlb", 4142414],
    "Yusei Kikuchi (MLB)": ["mlb", 41415],
    "Yves Missi (NBA)": ["nba", 5061589],
    "Yves Pons (NBA)": ["nba", 4278116],
    "Zac Gallen (MLB)": ["mlb", 39910],
    "Zac Jones (NHL)": ["nhl", 4781635],
    "Zac Thornton (MLB)": ["mlb", 5129576],
    "Zac Veen (MLB)": ["mlb", 4717903],
    "Zaccharie Risacher (NBA)": ["nba", 5211175],
    "Zach Benson (NHL)": ["nhl", 5149186],
    "Zach Bogosian (NHL)": ["nhl", 4002],
    "Zach Charbonnet (NFL)": ["nfl", 4426385],
    "Zach Collins (NBA)": ["nba", 4066650],
    "Zach Edey (NBA)": ["nba", 4600663],
    "Zach Ertz (NFL)": ["nfl", 15835],
    "Zach Horton (NFL)": ["nfl", 4877824],
    "Zach Hyman (NHL)": ["nhl", 5509],
    "Zach LaVine (NBA)": ["nba", 3064440],
    "Zach Lofton (NBA)": ["nba", 3059430],
    "Zach McKinstry (MLB)": ["mlb", 38420],
    "Zach Metsa (NHL)": ["nhl", 4419696],
    "Zach Neto (MLB)": ["mlb", 4666100],
    "Zach Werenski (NHL)": ["nhl", 3899972],
    "Zach Whitecloud (NHL)": ["nhl", 4312877],
    "Zach Wilson (NFL)": ["nfl", 4361259],
    "Zachariah Branch (NFL)": ["nfl", 4870612],
    "Zachary L'Heureux (NHL)": ["nhl", 4874744],
    "Zack Bolduc (NHL)": ["nhl", 4874734],
    "Zack Gelof (MLB)": ["mlb", 4414531],
    "Zack Littell (MLB)": ["mlb", 36052],
    "Zack MacEwen (NHL)": ["nhl", 4063569],
    "Zack Ostapchuk (NHL)": ["nhl", 4874881],
    "Zack Wheeler (MLB)": ["mlb", 31267],
    "Zaire Mitchell-Paden (NFL)": ["nfl", 4876006],
    "Zamir White (NFL)": ["nfl", 4361777],
    "Zane Gonzalez (NFL)": ["nfl", 3043234],
    "Zavier Scott (NFL)": ["nfl", 4257364],
    "Zavion Thomas (NFL)": ["nfl", 4869748],
    "Zay Flowers (NFL)": ["nfl", 4429615],
    "Zay Jones (NFL)": ["nfl", 3059722],
    "Zayne Parekh (NHL)": ["nhl", 5216878],
    "Zebby Matthews (MLB)": ["mlb", 4791597],
    "Zeev Buium (NHL)": ["nhl", 5206642],
    "Zeke Nnaji (NBA)": ["nba", 4431690],
    "Zemgus Girgensons (NHL)": ["nhl", 2968829],
    "Zhou Qi (NBA)": ["nba", 3892894],
    "Ziaire Williams (NBA)": ["nba", 4433137],
    "Zion Williamson (NBA)": ["nba", 4395628],
    "Zoran Dragic (NBA)": ["nba", 2560823],
    "Zuby Ejiofor (NBA)": ["nba", 5106262],
    "Zyhir Hope (MLB)": ["mlb", 5204650],
    "Zylan Cheatham (NBA)": ["nba", 3137713],
}
