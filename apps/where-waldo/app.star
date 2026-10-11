# Where Waldo - find the striped hero doing something in a living scene.
# 384x32 (six 64 px modules). Pages: hunt (find him), found (boxed reveal).
# Both pages share a seed (current minute), so they show the same scene.
#
# Layout: x 10-24 hero mug shot | x 30-77 "WHERE / WALDO?" | x 80-373 scene.
#
# Every thing in the scene belongs to a ZONE of the backdrop (sky, sea, sand,
# sidewalk, road, ground...). It is placed so its feet/bottom rest inside that
# zone's band, so nothing stands on a building wall or floats in the water.
# EXTREME difficulty lets things overlap (painter's order: lower = in front);
# the hero is always drawn last so it is never covered.

# ---- Characters ------------------------------------------------------------
# Only WALDO is exposed to users (the manifest has no character input).
# STRIPEY is kept as a ready-to-use fallback: to switch, change
# ACTIVE_CHARACTER below to "STRIPEY" (or re-add a `character` dropdown).
THEMES = {
    "WALDO": {"name": "WALDO", "a": "#E01E1E", "b": "white"},
    "STRIPEY": {"name": "STRIPEY", "a": "#00D060", "b": "white"},
}

ACTIVE_CHARACTER = "WALDO"

# Things per scene (hero included) and scene brightness (percent).
COUNTS = {"EASY": 22, "MEDIUM": 44, "HARD": 70, "EXTREME": 120}
BRIGHT = {"EASY": 30, "MEDIUM": 60, "HARD": 100, "EXTREME": 100}

SKINS = ["#F1C27D", "#E0AC69", "#C68642", "#8D5524", "#FFDBAC"]
BABY_SHIRTS = ["#FFC8DD", "#BDE0FE", "#CDB4DB", "#FFF3B0", "#B8F2C9"]
BABY_HATS = ["#FFFFFF", "#BDE0FE", "#FFC8DD"]

STYLES = {
    "BEACH": {
        "shirts": ["#2A9D8F", "#E9C46A", "#F4A261", "#48CAE4", "#90BE6D"],
        "pants": ["#264653", "#E9C46A", "#7F5539"],
        "hats": ["#48CAE4", "#E9C46A", "#F4A261"],
    },
    "CITY": {
        "shirts": ["#6C757D", "#495057", "#3A5A8C", "#5C4B7D", "#2F6F5E"],
        "pants": ["#212529", "#343A40", "#1D3557"],
        "hats": ["#6C757D", "#3A5A8C", "#5C4B7D"],
    },
    "FAIR": {
        "shirts": ["#B5179E", "#7209B7", "#F72585", "#4895EF", "#4CC9F0"],
        "pants": ["#3A0CA3", "#560BAD", "#212529"],
        "hats": ["#4895EF", "#7209B7", "#4CC9F0"],
    },
}

FH = {"16x24": 24, "10x16": 16, "7x12": 12, "5x7": 7, "4x5": 5}
HEXD = "0123456789abcdef"
BG_X0 = 80    # scene zone: x 80-373 (10 px padding at the panel's right edge)
BG_X1 = 373
PX0 = 83      # leftmost sprite column
SW = 290      # BG_X1 - PX0


# ---- sprite library --------------------------------------------------------
# Rows are strings; '.' is empty.
# Person tokens: k skin | S shirt (stripes if striped) | P pants |
#                H hat (striped for the hero, skin if bare) | g glasses.
# 'A' and 'B' always draw in the hero's two stripe colors (near-miss decoys).
# Any other letter comes from the sprite's own "pal".
def mk(kind, rows, pal=None, stripe="row", hero=False):
    if pal == None:
        pal = {}
    return {"kind": kind, "rows": rows, "pal": pal, "stripe": stripe, "hero": hero}


SPR = {
    # --- people doing things ---
    "stand": mk("adult", [".HHH.", ".gkg.", ".kkk.", "SSSSS", "SSSSS", "SSSSS", ".P.P.", ".P.P."], hero=True),
    "walk": mk("adult", [".HHH.", ".gkg.", ".kkk.", "SSSSS", "SSSSS", "SSSSS", ".P.P.", "P...P"], hero=True),
    "run": mk("adult", ["..HHH.", "..gkg.", "..kkk.", "kSSSS.", ".SSSSk", ".SSS..", ".PP.P.", "P...P."], hero=True),
    "jump": mk("adult", ["kHHHk", "SgkgS", "SkkkS", ".SSS.", ".SSS.", ".P.P.", ".P.P.", ".....", "....."], hero=True),
    "wave": mk("adult", ["kHHH.", "Sgkg.", "Skkk.", "SSSSS", ".SSS.", ".SSS.", ".P.P.", ".P.P."], hero=True),
    "kneel": mk("adult", [".HHH.....", ".gkg.Z.Z.", ".kkk.ZZZ.", "SSSSkZZZZ", "SSSS.ZZDZ", "PPPP.....", "P..P....."],
                pal={"Z": "#C79A4E", "D": "#7A5A2A"}, hero=True),   # building a sandcastle
    "lie": mk("adult", ["HH......", "gkSSSPPP", "gkSSSPPP"], stripe="col", hero=True),   # lying down
    "sit": mk("adult", [".HHH...", ".gkg...", ".kkk...", ".SSSk..", ".SSSPPP", "NNNNNNN", ".N...N.", ".N...N."],
              pal={"N": "#7A5230"}, hero=True),                      # sitting on a bench
    "surf": mk("adult", ["..HHH..", "..gkg..", "..kkk..", "kSSSSSk", "..SSS..", "..P.P..", "QQQQQQQ"],
               pal={"Q": "#FFD23F"}, hero=True),                    # surfing
    "swim": mk("adult", [".HHH.", "kgkgk", "wwwww"], pal={"w": "#7FD0F5"}),   # swimming
    "crawl": mk("baby", ["...HH", "SSSkk", "k.k.."], stripe="col"),          # crawling baby
    "baby": mk("baby", ["HHH", "kkk", "SSS", "SSS"]),
    # --- beach animals and objects ---
    "crab": mk("obj", ["R.....R", "RRRRRRR", ".RRRRR.", ".R.R.R."], pal={"R": "#E2572B"}),
    "ball": mk("obj", [".RW.", "YRWU", "YRWU", ".RW."],
               pal={"Y": "#F2C230", "R": "#E03A3A", "W": "#F4F4F4", "U": "#2A7FD4"}),
    "umbrella": mk("obj", [".ABABA.", "ABABABA", "...K...", "...K...", "...K...", "...K..."], pal={"K": "#6B4A2B"}),
    "castle": mk("obj", ["S.S.S.S", "SSSSSSS", "SSSSSSS", "SSSDSSS", "SSSDSSS"], pal={"S": "#C79A4E", "D": "#7A5A2A"}),
    "starfish": mk("obj", ["..O..", ".OOO.", "OOOOO", ".O.O.", "O...O"], pal={"O": "#F08A3C"}),
    "towel": mk("obj", ["ABABAB", "ABABAB", "ABABAB"]),
    "gull_fly": mk("obj", ["W...W", "WW.WW", ".WWW."], pal={"W": "#F2F2F2"}),
    "gull_stand": mk("obj", [".WW.", "WWWY", ".WW.", ".O.O"], pal={"W": "#F2F2F2", "Y": "#F2C230", "O": "#F08A3C"}),
    "dog_run": mk("obj", ["N...NN.", "NNNNNNK", ".NNNNN.", "N.....N"], pal={"N": "#9C6A3A", "K": "#2B2B2B"}),
    "kite": mk("obj", [".R.", "RYR", ".R.", ".K.", "K..", ".K."], pal={"R": "#E03A3A", "Y": "#F2C230", "K": "#DDDDDD"}),
    "sailboat": mk("obj", ["...A...", "..ABA..", ".ABABA.", "ABABABA", "...K...", "NNNNNNN", ".NNNNN."],
                   pal={"K": "#2B2B2B", "N": "#7A4A2B"}),
    # --- city animals and objects ---
    "pigeon": mk("obj", ["..GG.", ".GGGY", "GGGG.", ".P.P."], pal={"G": "#8A94A3", "Y": "#F2C230", "P": "#C07A8A"}),
    "pigeon_fly": mk("obj", ["G...G", "GG.GG", ".GGG."], pal={"G": "#8A94A3"}),
    "dog": mk("obj", ["N..NN.", "NNNNNK", ".NNNN.", ".N..N."], pal={"N": "#9C6A3A", "K": "#2B2B2B"}),
    "cat": mk("obj", ["O..O", "OOOO", "OOOO", ".OO."], pal={"O": "#E0883A"}),
    "hydrant": mk("obj", [".R.", "RRR", ".R.", ".R.", "RRR"], pal={"R": "#C0392B"}),
    "cone": mk("obj", [".O.", "OWO", "OOO", "KKK"], pal={"O": "#F2761E", "W": "#F4F4F4", "K": "#333333"}),
    "lamp": mk("obj", ["YYY", ".K.", ".K.", ".K.", ".K.", ".K.", ".K.", "KKK"], pal={"Y": "#FFE27A", "K": "#2B2B2B"}),
    "mailbox": mk("obj", ["UUUU", "UUUU", "UUUU", ".K..", ".K.."], pal={"U": "#2A5CAA", "K": "#2B2B2B"}),
    "bin": mk("obj", ["KKK", "GGG", "GGG", "GGG"], pal={"K": "#444444", "G": "#5A6B5A"}),
    "taxi": mk("obj", ["..YYY..", ".YCCCY.", "YYYYYYY", ".K...K."], pal={"Y": "#F2C230", "C": "#9FD8F0", "K": "#222222"}),
    "bus": mk("obj", ["OOOOOOOOOOOO", "OCCOCCOCCOCO", "OOOOOOOOOOOO", "OOOOOOOOOOOO", ".KK......KK."],
              pal={"O": "#F2761E", "C": "#9FD8F0", "K": "#222222"}),
    # --- fairground animals and objects ---
    "balloon_p": mk("obj", [".P.", "PPP", "PPP", ".P.", ".K."], pal={"P": "#FF5A8A", "K": "#DDDDDD"}),
    "balloon_u": mk("obj", [".U.", "UUU", "UUU", ".U.", ".K."], pal={"U": "#4FA8FF", "K": "#DDDDDD"}),
    "bear": mk("obj", ["N...N", ".NNN.", "NNNNN", ".NNN.", ".N.N."], pal={"N": "#A0693A"}),
    "duck": mk("obj", [".YY.", "YYYO", "YYYY", ".YY."], pal={"Y": "#FFE45A", "O": "#F2761E"}),
    "pony": mk("obj", ["....WW", "WWWWWW", "WWWWW.", "W.W.W."], pal={"W": "#F2EAD8"}),
    "booth": mk("obj", ["ABABA", "NNNNN", "NCCCN", "NCCCN", "NNNNN", "NNNNN", "NNNNN"], pal={"N": "#8A5A3A", "C": "#FFE27A"}),
    "cart": mk("obj", ["ABABABA", ".N...N.", ".NYWYN.", ".NNNNN.", ".NNNNN.", ".K...K."],
               pal={"N": "#8A5A3A", "Y": "#FFE27A", "W": "#F4F4F4", "K": "#222222"}),
}

# Zones: z = name; w = share of the crowd (percent); lo..hi = the row range
# where a sprite's BOTTOM edge may sit; names = what can appear there.
THEME = {
    "BEACH": [
        {"z": "sky", "w": 10, "lo": 3, "hi": 9, "names": ["gull_fly", "kite"]},
        {"z": "sea", "w": 14, "lo": 14, "hi": 17, "names": ["sailboat", "surf", "swim"]},
        {"z": "sand", "w": 76, "lo": 21, "hi": 30,
         "names": ["stand", "walk", "run", "jump", "wave", "kneel", "lie", "crawl", "baby",
                   "crab", "starfish", "gull_stand", "dog_run", "ball", "umbrella", "towel", "castle"]},
    ],
    "CITY": [
        {"z": "sky", "w": 8, "lo": 3, "hi": 5, "names": ["pigeon_fly"]},
        {"z": "walk", "w": 67, "lo": 19, "hi": 24,
         "names": ["stand", "walk", "run", "wave", "jump", "sit", "baby", "dog", "cat", "pigeon",
                   "hydrant", "cone", "lamp", "mailbox", "bin"]},
        {"z": "road", "w": 25, "lo": 27, "hi": 30, "names": ["taxi", "bus"]},
    ],
    "FAIR": [
        {"z": "air", "w": 10, "lo": 5, "hi": 14, "names": ["balloon_p", "balloon_u"]},
        {"z": "ground", "w": 90, "lo": 21, "hi": 30,
         "names": ["stand", "walk", "run", "jump", "wave", "lie", "crawl", "baby",
                   "bear", "duck", "pony", "booth", "cart"]},
    ],
}


# ---- helpers ---------------------------------------------------------------
def read_cfg(ctx):
    mode = str(ctx.inputs.get("character", ACTIVE_CHARACTER)).upper()
    diff = str(ctx.inputs.get("difficulty", "MEDIUM")).upper()
    crowd = str(ctx.inputs.get("scenes", "CITY")).upper()
    if mode not in THEMES or diff not in COUNTS or crowd not in STYLES:
        return None
    return (THEMES[mode], COUNTS[diff], STYLES[crowd], crowd, diff)


def get_seed(ctx):
    n = ctx.now
    u = getattr(n, "unix", None)
    if type(u) == "int":
        return u // 60
    t = 0
    for f, m in [("month", 44640), ("day", 1440), ("hour", 60), ("minute", 1)]:
        v = getattr(n, f, 0)
        if type(v) == "int":
            t += v * m
    return t


def nxt(st):
    st[0] = (st[0] * 1103515245 + 12345) % 2147483648
    return st[0] // 65536


def pick(st, lst):
    return lst[nxt(st) % len(lst)]


def shade(col, f):
    out = "#"
    for i in range(3):
        v = int(col[1 + i * 2:3 + i * 2], 16) * f // 100
        if v > 255:
            v = 255
        out = out + HEXD[v // 16] + HEXD[v % 16]
    return out


def fit_font(c, s, maxw, fonts):
    for f in fonts:
        if c.text_width(s, f) <= maxw:
            return f
    return fonts[len(fonts) - 1]


def ctr(c, s, y, font, col):
    s = s.upper()
    w = c.text_width(s, font)
    c.text(s, 10 + (364 - w) // 2, y, font=font, color=col)


def put(c, x, y, s, dx, dy, col):
    for j in range(s):
        for i in range(s):
            c.pixel(x + dx * s + i, y + dy * s + j, col)


def first_pos(rows, ch):
    fr = -1
    fc = 999
    for j in range(len(rows)):
        for i in range(len(rows[j])):
            if rows[j][i] == ch:
                if fr < 0:
                    fr = j
                if i < fc:
                    fc = i
    return (fr, fc)


# Draw any sprite at (x, y), each sprite pixel s x s. p = person look (or None).
def draw(c, x, y, s, spr, p, th):
    rows = spr["rows"]
    pal = spr["pal"]
    byrow = spr["stripe"] == "row"
    fs = first_pos(rows, "S")
    fh = first_pos(rows, "H")
    for j in range(len(rows)):
        row = rows[j]
        for i in range(len(row)):
            ch = row[i]
            if ch == ".":
                continue
            if p != None and ch == "S":
                if p["stripes"]:
                    idx = (j - fs[0]) if byrow else (i - fs[1])
                    col = th["a"] if idx % 2 == 0 else th["b"]
                else:
                    col = p["shirt"]
            elif p != None and ch == "P":
                col = p["pants"]
            elif p != None and ch == "k":
                col = p["skin"]
            elif p != None and ch == "H":
                h = p["hat"]
                if h == "stripe":
                    col = th["a"] if (i - fh[1]) % 2 == 0 else th["b"]
                elif h == None:
                    col = p["skin"]
                else:
                    col = h
            elif p != None and ch == "g":
                col = "#101010" if p["glasses"] else p["skin"]
            elif ch == "A":
                col = th["a"]
            elif ch == "B":
                col = th["b"]
            else:
                col = pal[ch]
            if s == 1:
                c.pixel(x + i, y + j, col)
            else:
                put(c, x, y, s, i, j, col)


def hero(th):
    return {
        "a": th["a"], "b": th["b"], "shirt": th["a"], "pants": "#2B5BA8",
        "skin": "#F1C27D", "hat": "stripe", "glasses": True, "stripes": True,
    }


def decoy(st, style, th):
    stripes = nxt(st) % 100 < 18
    hat_on = nxt(st) % 100 < 30
    glasses = nxt(st) % 100 < 25
    shirt = pick(st, style["shirts"])
    pants = pick(st, style["pants"])
    skin = pick(st, SKINS)
    hatc = pick(st, style["hats"])
    if stripes and hat_on and glasses:
        glasses = False  # never a lookalike: near-misses only
    return {
        "a": th["a"], "b": th["b"], "shirt": shirt, "pants": pants,
        "skin": skin, "hat": hatc if hat_on else None,
        "glasses": glasses, "stripes": stripes,
    }


def decoy_baby(st, th):
    stripes = nxt(st) % 100 < 30
    hat_on = nxt(st) % 100 < 35
    shirt = pick(st, BABY_SHIRTS)
    skin = pick(st, SKINS)
    hatc = pick(st, BABY_HATS)
    return {
        "a": th["a"], "b": th["b"], "shirt": shirt, "skin": skin,
        "hat": hatc if hat_on else None, "stripes": stripes,
    }


BK = 24  # collision bucket width (sprites are at most 12 px wide)


def clash(buckets, x0, y0, x1, y1):
    # True if the rectangle is closer than 1 empty pixel to any placed one.
    for bk in range((x0 - 1) // BK, (x1 + 1) // BK + 1):
        lst = buckets.get(bk)
        if lst == None:
            continue
        for r in lst:
            if x0 <= r[2] + 1 and r[0] <= x1 + 1 and y0 <= r[3] + 1 and r[1] <= y1 + 1:
                return True
    return False


def reserve(buckets, r):
    for bk in range(r[0] // BK, r[2] // BK + 1):
        if bk in buckets:
            buckets[bk].append(r)
        else:
            buckets[bk] = [r]


def build(seed, count, style, th, crowd, overlap):
    st = [(seed * 2654435761 + 12345) % 2147483648]
    nxt(st)
    nxt(st)
    zones = THEME[crowd]
    # Hero first: any pose a striped person can do in this scene.
    cands = []
    for z in zones:
        for n in z["names"]:
            if SPR[n]["hero"]:
                cands.append((z, n))
    hc = cands[nxt(st) % len(cands)]
    hz = hc[0]
    hs = SPR[hc[1]]
    hw = len(hs["rows"][0])
    hh = len(hs["rows"])
    hx = PX0 + nxt(st) % (SW - hw)
    hb = hz["lo"] + nxt(st) % (hz["hi"] - hz["lo"] + 1)
    hy = hb - hh + 1
    if hy < 1:
        hy = 1
    people = [{"x": hx, "y": hy, "w": hw, "h": hh, "spr": hs, "p": hero(th), "t": True}]
    buckets = {}
    # reserved rectangle = the reveal box around the hero
    reserve(buckets, (hx - 1, hy - 1, hx + hw, hy + hh))
    for i in range(count * 12):
        if len(people) >= count:
            break
        roll = nxt(st) % 100
        z = zones[len(zones) - 1]
        acc = 0
        for zz in zones:
            acc += zz["w"]
            if roll < acc:
                z = zz
                break
        spr = SPR[z["names"][nxt(st) % len(z["names"])]]
        w = len(spr["rows"][0])
        h = len(spr["rows"])
        x = PX0 + nxt(st) % (SW - w)
        b = z["lo"] + nxt(st) % (z["hi"] - z["lo"] + 1)
        y = b - h + 1
        if y < 1:
            continue
        if not overlap:
            if clash(buckets, x, y, x + w - 1, y + h - 1):
                continue
            reserve(buckets, (x, y, x + w - 1, y + h - 1))
        p = None
        if spr["kind"] == "adult":
            p = decoy(st, style, th)
        elif spr["kind"] == "baby":
            p = decoy_baby(st, th)
        people.append({"x": x, "y": y, "w": w, "h": h, "spr": spr, "p": p, "t": False})
    return people


def frame(c, x0, y0, x1, y1, col):
    for x in range(x0, x1 + 1):
        c.pixel(x, y0, col)
        c.pixel(x, y1, col)
    for y in range(y0, y1 + 1):
        c.pixel(x0, y, col)
        c.pixel(x1, y, col)


# ---- scene backdrops (zone x 80-373) ---------------------------------------
# Full-brightness (HARD) palette; EASY and MEDIUM scale it down so the scene
# pops less. Bands overlap back-to-front so no seams.


def backdrop(c, crowd, f):
    x0 = BG_X0
    x1 = BG_X1
    if crowd == "BEACH":
        # sky 0-11, sea 12-17, sand 18-31
        c.rect(x0, 0, x1, 31, fill=shade("#4DA6E0", f))
        c.rect(x0, 12, x1, 31, fill=shade("#1B6FA8", f))
        c.rect(x0, 18, x1, 31, fill=shade("#D9B96E", f))
        cloud = shade("#EAF6FF", f)
        glint = shade("#7FD0F5", f)
        grain = shade("#BF9F55", f)
        for y in range(0, 12):
            for x in range(x0, x1 + 1):
                if (x * 5 + y * 9) % 29 == 0:
                    c.pixel(x, y, cloud)
        for y in range(12, 18):
            for x in range(x0, x1 + 1):
                if (x * 7 + y * 5) % 13 == 0:
                    c.pixel(x, y, glint)
        for y in range(19, 32):
            for x in range(x0, x1 + 1):
                if (x * 3 + y * 11) % 17 == 0:
                    c.pixel(x, y, grain)
    elif crowd == "CITY":
        # sky 0-6, buildings end at 17, sidewalk 18-24, curb 25, road 26-31
        c.rect(x0, 0, x1, 31, fill=shade("#6F9FCC", f))
        c.rect(x0, 3, x1, 31, fill=shade("#9CC0E0", f))
        bcol = shade("#3F4B5F", f)
        wcol = shade("#F2D06B", f)
        ws = [9, 7, 11, 8, 10, 9, 7, 12, 8, 10, 9, 8, 11, 9, 6]
        hs = [9, 6, 11, 8, 5, 10, 7, 9, 6, 11, 8, 10, 6, 11, 8]
        x = x0
        for k in range(80):
            if x > x1:
                break
            w = ws[k % 15]
            h = hs[(k * 7 + (k // 15) * 4) % 15]
            bx1 = min(x + w - 1, x1)
            c.rect(x, 18 - h, bx1, 17, fill=bcol)
            for wy in range(18 - h + 1, 16, 3):
                for wx in range(x + 1, bx1, 3):
                    if (wx * 5 + wy * 3) % 7 < 2:
                        c.pixel(wx, wy, wcol)
            x = x + w
        c.rect(x0, 18, x1, 24, fill=shade("#8D96A3", f))   # sidewalk
        c.rect(x0, 25, x1, 25, fill=shade("#B7BEC8", f))   # curb
        c.rect(x0, 26, x1, 31, fill=shade("#3A3F4A", f))   # road
        tile = shade("#7A8390", f)
        for x in range(x0 + 6, x1 + 1, 12):
            for y in range(18, 25):
                c.pixel(x, y, tile)
        lane = shade("#D9C24A", f)
        for x in range(x0, x1 + 1):
            if x % 10 < 5:
                c.pixel(x, 29, lane)
    else:  # FAIR: striped tent wall 0-17, grass ground 18-31
        c.rect(x0, 0, x1, 31, fill=shade("#5A2380", f))
        scol = shade("#7E3DAA", f)
        for sx in range(x0, x1 + 1, 16):
            c.rect(sx, 0, sx + 7, 17, fill=scol)
        conf = [shade("#FF5A8A", f), shade("#5AD1FF", f), shade("#FFE45A", f)]
        for y in range(1, 17):
            for x in range(x0, x1 + 1):
                if (x * 11 + y * 7) % 31 == 0:
                    c.pixel(x, y, conf[(x + y) % 3])
        wire = shade("#B89B2E", f)
        for x in range(x0, x1 + 1):
            c.pixel(x, 0, wire)
        i = 0
        for x in range(x0 + 3, x1, 6):
            c.pixel(x, 0, conf[i % 3])
            i += 1
        c.rect(x0, 18, x1, 31, fill=shade("#4C8C3A", f))   # grass
        c.rect(x0, 18, x1, 19, fill=shade("#3E7530", f))   # grass shadow line
        blade = shade("#6BAA4A", f)
        for y in range(20, 32):
            for x in range(x0, x1 + 1):
                if (x * 5 + y * 13) % 11 == 0:
                    c.pixel(x, y, blade)


# ---- screens ---------------------------------------------------------------
def error(c):
    c.fill("black")
    ctr(c, "BAD SETTING", 7, "5x7", "red")
    ctr(c, "RE-SAVE APP", 18, "5x7", "gray")


def left_label(c, line1, line2, col):
    longest = line1 if len(line1) >= len(line2) else line2
    f = fit_font(c, longest, 48, ["7x12", "5x7", "4x5"])
    h = FH[f]
    y0 = (32 - (2 * h + 2)) // 2
    w1 = c.text_width(line1, f)
    c.text(line1, 30 + (48 - w1) // 2, y0, font=f, color=col)
    w2 = c.text_width(line2, f)
    c.text(line2, 30 + (48 - w2) // 2, y0 + h + 2, font=f, color=col)


def scene(c, ctx, reveal):
    cfg = read_cfg(ctx)
    if cfg == None:
        error(c)
        return
    th = cfg[0]
    count = cfg[1]
    style = cfg[2]
    c.fill("black")
    backdrop(c, cfg[3], BRIGHT[cfg[4]])

    # Left zone: hero mug shot (x 10-24) + title text (x 30-77)
    name = th["name"].upper()
    if reveal:
        left_label(c, "FOUND", name + "!", "green")
    else:
        left_label(c, "WHERE", name + "?", "white")
    draw(c, 10, 4, 3, SPR["stand"], hero(th), th)

    # The scene. Lower things are drawn later (in front); hero is always last.
    people = build(get_seed(ctx), count, style, th, cfg[3], cfg[4] == "EXTREME")
    order = [[] for _ in range(32)]
    for e in people:
        if not e["t"]:
            order[e["y"] + e["h"] - 1].append(e)
    for lst in order:
        for e in lst:
            draw(c, e["x"], e["y"], 1, e["spr"], e["p"], th)
    hero_e = people[0]
    draw(c, hero_e["x"], hero_e["y"], 1, hero_e["spr"], hero_e["p"], th)
    if reveal:
        frame(c, hero_e["x"] - 1, hero_e["y"] - 1, hero_e["x"] + hero_e["w"], hero_e["y"] + hero_e["h"], "green")


def hunt(c, ctx):
    scene(c, ctx, False)


def found(c, ctx):
    scene(c, ctx, True)
