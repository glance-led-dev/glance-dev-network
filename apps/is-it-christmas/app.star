# Is It Christmas?
#
# A pixel-for-pixel port of the Tidbyt community app "Is It Christmas"
# (tidbyt/community apps/isitchristmas, by Austin Fonacier).
#
#   Every day but December 25: "Is It / Christmas?" in green, a red "No",
#   and two unlit trees. A completely still picture.
#   December 25: a green "Yes!" and the trees' colored lights twinkle.
#
# Pixel-for-pixel notes
# - The original lettering is Tidbyt's mixed-case tb-8 font. GDN fonts are
#   uppercase only, so each phrase is drawn as a bitmap copied glyph for glyph
#   from tb-8, at the exact x/y the Tidbyt placed it.
# - The trees are the original 11x11 PNG sprites, stretched to 11x12 exactly
#   as Pixlet stretched them (nearest neighbour: source row 5 is doubled).
# - Pixlet cycled four light frames every 500 ms. A GDN frame is a still
#   image, so the panel shows the next of those same four frames on each
#   60-second refresh instead.
#
# Time zone: ctx.now is UTC. December's UTC offset never changes for any zone
# listed (northern zones are on standard time, southern ones on summer time),
# so a fixed December offset is exact for the one day this app cares about.

GREEN = "#1E792C"   # original CHRISTMAS_GREEN
RED = "#C30F16"     # original CHRISTMAS_RED

# Minutes east of UTC, as observed in late December.
DEC_OFFSETS = {
    "US Eastern (New York)": -300,
    "US Central (Chicago)": -360,
    "US Mountain (Denver)": -420,
    "US Arizona (Phoenix)": -420,
    "US Pacific (Los Angeles)": -480,
    "US Alaska (Anchorage)": -540,
    "US Hawaii (Honolulu)": -600,
    "Atlantic (Halifax, Puerto Rico)": -240,
    "Newfoundland (St. John's)": -210,
    "Mexico City": -360,
    "Brazil (Sao Paulo)": -180,
    "UTC": 0,
    "UK / Ireland / Portugal": 0,
    "Central Europe (Paris, Berlin)": 60,
    "Eastern Europe (Athens, Kyiv)": 120,
    "Moscow / Istanbul": 180,
    "Gulf (Dubai)": 240,
    "India (Kolkata)": 330,
    "China / Singapore / Perth": 480,
    "Japan / Korea": 540,
    "Australia (Brisbane)": 600,
    "Australia (Adelaide)": 630,
    "Australia (Sydney, Melbourne)": 660,
    "New Zealand (Auckland)": 780,
}
DEFAULT_ZONE = "US Central (Chicago)"

# ---------------------------------------------------------------------------
# Lettering: tb-8 glyphs, '#' = lit. Each entry is (rows, x, y).
# ---------------------------------------------------------------------------

IS_IT = ([
    "###........###..#..",
    ".#..........#...#..",
    ".#...##.....#..###.",
    ".#..##......#...#..",
    ".#....#.....#...#.#",
    "###.##.....###...#.",
], 22, 1)

CHRISTMAS = ([
    ".##..#..........#.......#...................#.",
    "#..#.#..................#..................#.#",
    "#....###..#.#..##...##.###..##.#...###..##...#",
    "#....#..#.##.#..#..##...#...#.#.#.#..#.##...#.",
    "#..#.#..#.#.....#....#..#.#.#.#.#.#..#...#....",
    ".##..#..#.#....###.##....#..#.#.#..###.##...#.",
], 9, 9)

YES = ([
    "#...#..........#",
    "#...#..........#",
    ".#.#...##...##.#",
    "..#...#.##.##..#",
    "..#...##.....#..",
    "..#....##..##..#",
], 24, 24)

NO = ([
    "#..#.....",
    "##.#.....",
    "####..##.",
    "#.##.#..#",
    "#.##.#..#",
    "#..#..##.",
], 27, 24)

# ---------------------------------------------------------------------------
# Trees: the original sprites, already stretched to 11x12.
# g = needle green, t = trunk, other letters = light colors.
# ---------------------------------------------------------------------------

TREE_COLORS = {
    "g": "#4CAF50",
    "t": "#795548",
    "p": "#E91E63",   # pink
    "o": "#FF9800",   # orange
    "v": "#9C27B0",   # violet
    "c": "#00BCD4",   # cyan
    "y": "#FFCA28",   # yellow
    "a": "#FFC107",   # amber
}

TREE_UNLIT = [
    ".....g.....",
    "....ggg....",
    "....ggg....",
    "...ggggg...",
    "...ggggg...",
    "..ggggggg..",
    "..ggggggg..",
    "..ggggggg..",
    ".ggggggggg.",
    ".ggggggggg.",
    ".....t.....",
    ".....t.....",
]

TREE_LIT = [
    [
        ".....g.....",
        "....ggg....",
        "....ggg....",
        "...gggpg...",
        "...ggggg...",
        "..ggggggg..",
        "..ggggggg..",
        "..ggpgogg..",
        ".ggggggggg.",
        ".ggoggggpg.",
        ".....t.....",
        ".....t.....",
    ],
    [
        ".....g.....",
        "....ggg....",
        "....vgg....",
        "...gggcg...",
        "...ggggg...",
        "..ggggggg..",
        "..ggggggg..",
        "..ggcgvgg..",
        ".gvggggggg.",
        ".ggggggcgg.",
        ".....t.....",
        ".....t.....",
    ],
    [
        ".....g.....",
        "....ggg....",
        "....vgg....",
        "...gggpg...",
        "...ggggg...",
        "..ggggggg..",
        "..ggggggg..",
        "..ggpgogg..",
        ".gvggggggg.",
        ".ggogggcpg.",
        ".....t.....",
        ".....t.....",
    ],
    [
        ".....g.....",
        "....ggg....",
        "....gcy....",
        "...ggggg...",
        "...gyggg...",
        "..gggcgyg..",
        "..gggcgyg..",
        "..gaggggg..",
        ".ggggggcgg.",
        ".ggcggaggg.",
        ".....t.....",
        ".....t.....",
    ],
]

TREE_Y = 20
LEFT_TREE_X = 0
RIGHT_TREE_X = 53   # 64 - 11, flush right like Pixlet's space_between row

# ---------------------------------------------------------------------------

def civil_from_days(z):
    """(year, month, day) for a count of days since 1970-01-01 (Hinnant)."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return (y, m, d)

def to_matrix(rows):
    return [[1 if r[i] == "#" else 0 for i in range(len(r))] for r in rows]

def draw_words(c, words, color):
    rows, x, y = words
    c.bitmap(to_matrix(rows), x, y, color = color)

def draw_tree(c, rows, x0):
    for y in range(len(rows)):
        row = rows[y]
        for x in range(len(row)):
            ch = row[x]
            if ch != ".":
                c.pixel(x0 + x, TREE_Y + y, TREE_COLORS[ch])

def main(c, ctx):
    c.fill("black")

    zone = ctx.inputs.get("timezone", DEFAULT_ZONE)
    offset_min = DEC_OFFSETS.get(zone, DEC_OFFSETS[DEFAULT_ZONE])
    local = ctx.now.unix + offset_min * 60
    _, month, day = civil_from_days(local // 86400)
    christmas = month == 12 and day == 25

    draw_words(c, IS_IT, GREEN)
    draw_words(c, CHRISTMAS, GREEN)

    if christmas:
        draw_words(c, YES, GREEN)
        tree = TREE_LIT[(ctx.now.unix // 60) % 4]   # next frame each refresh
    else:
        draw_words(c, NO, RED)
        tree = TREE_UNLIT

    draw_tree(c, tree, LEFT_TREE_X)
    draw_tree(c, tree, RIGHT_TREE_X)