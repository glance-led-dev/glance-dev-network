# Chinese Holidays for a Glance SCROLL panel (192x32).
#
# DESIGN. After Sleeps Till Christmas, in three columns. A 32 px icon slot at
# each side; between them a red key-fret border (hui wen), the traditional
# Chinese meander, along the top, and under it the days until the next holiday
# as the hero in gold, with DAYS TIL and the holiday's name in its own colour
# beside it. New Year's Day fills both slots, a red 福 at the left and
# fireworks at the right, and Chinese New Year hangs a lantern at the left and
# firecrackers at the right. The other holidays show their picture at the left.
# On the holiday itself the count gives way to a greeting. The reader can
# follow whichever holiday comes next, or pick one to count down to all year.
#
# Seven holidays:
#   New Year's Day   1 January
#   Chinese New Year 1st day of the 1st lunar month
#   Qingming         the Clear and Bright solar term (4 or 5 April)
#   Labour Day       1 May
#   Dragon Boat      5th day of the 5th lunar month
#   Mid-Autumn       15th day of the 8th lunar month
#   National Day     1 October
#
# The four moving dates are a table, 2026-2045, not a calculation: the Chinese
# calendar turns on the exact minute of each new moon and solar term in Beijing
# time, which Starlark cannot compute to that precision. Every date in LUNAR was
# computed astronomically and checked against published tables, and each year
# where a new moon or solar term fell close to midnight was checked against the
# Hong Kong Observatory's calendar. Past 2045 only the three fixed holidays count.
#
# Everything else is worked out from ctx.now in the reader's time zone, so the
# count rolls at their midnight. No network, no error screen.

# ---- geometry ---------------------------------------------------------------
SLOT = 32            # the icon slots: x 0..31 at the left, x 160..191 at the right
LEFTX = 0
RIGHTX = 160
MIDL = 32            # the centre column, x 32..159: the border across the top,
MIDR = 159           # the count and its labels below it
TOPY = 0             # the border takes rows 0-4
ZONEL = MIDL + 3     # the count block is centred in x 35..156, 3 px clear of
ZONER = MIDR - 3     # each icon slot: 122 px

GOLD = "#FFD23F"     # the greeting's big line
LABEL = "#C8B89A"    # warm parchment: DAYS TIL, HAPPY
FRET = "#E8231F"     # the border

# One unit of the key fret, rail on the top row, hooks hanging below it.
FRET_UNIT = [
    "######",
    "#...#.",
    "#.#.#.",
    "#.#...",
    "#.####",
]

# One unit of the wave (qing hai bo), simplified to a row of nested arches,
# hanging from the top edge.
WAVE_UNIT = [
    "#.#..#.#",
    "#.#..#.#",
    "#..##..#",
    ".#....#.",
    "..####..",
]
WAVE = "#D8E8C8"     # pale spring green

# One unit of the gear border: a 7 px gear, teeth top and bottom, a hole in
# the hub, and a clear column before the next.
GEAR_UNIT = [
    ".#.#.#..",
    "#######.",
    "##...##.",
    "#######.",
    ".#.#.#..",
]
GEAR = "#C0C4CC"     # silver

# One unit of the railed key fret: a rail top and bottom with a Z-shaped hook
# between them, each unit closed off by a post.
RAIL_UNIT = [
    "######",
    "#...#.",
    "#.###.",
    "#.#...",
    "######",
]
RAIL = "#1E7A34"     # dark green, like the zongzi leaves

# One legend for every sprite, so a colour means the same thing everywhere.
LEG = {
    "R": "#E8231F",    # red
    "r": "#9A1414",    # dark red: lantern ribs
    "Y": "#FFD23F",    # gold
    "O": "#FF8C00",    # orange: tassels
    "G": "#3FB950",    # green
    "g": "#1E7A34",    # dark green
    "N": "#8B5A2B",    # brown
    "S": "#B8BCC8",    # steel
    "s": "#6E7A94",    # dark steel
    "L": "#FFF4C2",    # moon highlands: light yellow
    "l": "#F8EDBC",    # the soft rims of the maria
    "m": "#EADDAA",    # the maria
    "T": "#C8872E",    # mooncake
    "t": "#8A5A1C",    # mooncake pattern
    "B": "#3A8DFF",    # blue
    "b": "#9FD4F5",    # light blue: rain, spray
    "C": "#25F8CB",    # cyan
    "M": "#FF3FD0",    # magenta
    "W": "white",
    "K": "#F2C79A",    # skin
    "k": "#B97A4A",    # skin creases
    "P": "#FFB6C1",    # pink: the rabbit's ears and nose
}

# ---- pixel art ----------------------------------------------------------------
FIREWORKS = """
................................
........................W.......
...........Y....................
....................W...M...W...
...........R.........M..M..M....
.....Y.....R.....Y....M.M.M.....
......R....R....R......M.M......
.......R...R...R..W.MMM.W.MMM.W.
........R..R..R........M.M......
.........R.R.R........M.M.M.....
..........R.R........M..M..M....
..Y.RRRRRR.Y.RRRRRR.W...M...W...
..........R.R...................
.........R.R.R..........W.......
........R..R..R.................
.......R...R...R................
......R....R....R.......W.......
.....Y.....R.....Y..............
...........R........W...C...W...
.....................C..C..C....
...........Y..........C.C.C.....
.......................C.C......
..................W.CCC.W.CCC.W.
...........Y...........C.C......
...........Y..........C.C.C.....
...........Y.........C..C..C....
....................W...C...W...
...........Y....................
...........Y............W.......
................................
...........Y....................
...........Y....................
"""

FIRECRACKERS = """
..O..........YYYYYY..........Y..
.OOO...Y.....YYYYYY.....O...YYY.
..O...........RRRR...........Y..
...............YO...............
............RRROY.RRR...........
W.........RRRRRYO.RRRRR.........
.......RRrRRR..OY...RRrRRR......
...YYRRRRR.....YO......RRRRYY...
...YYRRR.......OY........RRYY...
............RRRYO.RRR...........
.........RRRRRROY.RRRRRR.......W
.......RRrRRR..YO...RRrRRR......
...YYRRRRRR....OY.....RRRRRYY...
...YYRRR.......YO........RRYY...
............RRROY.RRR...........
Y.........RRRRRYO.RRRRR.........
.......RRrRRR..OY...RRrRRR......
...YYRRRRR.....YO......RRRRYY...
...YYRRR.......OY........RRYY...
............RRRYO.RRR..........O
.........RRRRRROY.RRRRRR........
.......RRrRRR..YO...RRrRRR......
O..YYRRRRRR....OY.....RRRRRYY...
...YYRRR.......YO........RRYY...
...............OY..............Y
...............YO...............
....Y.....O..Y..O.Y..Y.....O....
...YYY........O..O........OOO...
....Y.......Y.OWY.O.Y......O....
................................
........W.....O.OO.....W........
.O...........Y....Y...........Y.
"""

KITES = """
................................
................................
...................RR...........
........WWW.......RYYR.......WWW
........BBBWWWWW..RRRR..WWWWWBBB
.........BBBBBBBWWWRRWWWBBBBBBB.
.........BBBBBBBBBBRRBBBBBBBBBB.
..........BBBBBBBBBRRBBBBBBBBB..
..........BBBBBBBBRRRRBBBBBBBB..
...........BBBBBBBRRRRBBBBBBB...
...........BBBBBBBBRRBBBBBBBB...
...............BBBBRRBBB........
...................RR...........
..................R.R...........
..................R..R..........
.......R..........R...R.........
.......RY........R....R.........
......YRYY......R.....R.........
.....YYRYYY.....Y......Y........
....RRRRRRRR....................
....YYYRYYYY............s.......
.....YYRYYY.....................
......YRYY................s.....
.......RY.......................
.......R...................s....
.......s........................
.......MRM..................s...
.....s..........................
.....MRM.....................s..
...s............................
.......MRM....................s.
.s..............................
"""

HAND_WRENCH = """
................................
................................
................................
..............k..k..k...........
............KKkKKkKKkKK.........
...........KKKkKKkKKkKKK........
...SSS....KKKKkKKkKKkKK....SS...
.SSSSSSS...KKKkKKkKKkKKK.SSSSSS.
.SSSSSSS...KKKkKKkKKkKKKSSSSSSSS
....SSSSSSSKKKkKKkKKkKKKSSS..SSS
....SSSSSSSKKKkKKkKKkKKKSS....SS
....SSSSSSSKKKKKKKKKKKKKSSS..SSS
.SSSSssssssKKKKKKKKKKKKKsssSSSSS
.SSSSSSS.kKKKKKKKKKKKKKK.SSSSSS.
...SSS...KKKKKKKKkkkKKKK...SS...
.........KKKkkkkkKKKKKKK........
.........kkkKKKKKKKKKKKK........
...........KKKKKKKKKKKKK........
...........KKKKKKKKKKKKK........
............kkkkkkkkkkk.........
............KKKKKKKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
............KKKKKkKKKKK.........
"""

ZONGZI = """
................................
................................
................................
................................
...........T.T..................
............T...................
............G...................
...........GGg..................
...........GGg..................
..........GgGGg.................
..........GgGgG.................
.........GgGGgGg................
.........GggGGgGg...............
........GgGgGGgGg.......T.T.....
........TTTTTTTTTg.......T......
.......GgGgGGGGgGg.......G......
......GGgGgGGGgGgGg......G......
......GgGgGGGGgGgGgg....GGg.....
.....GGgGgGGGGggGgGg....gGG.....
.....GgGgGGGGGggGgGgg..GgGG.....
....GGgGgGGGGGGgGggGg..gGGGg....
....TTTTTTTTTTTTTTTTTgGggGGG....
...GGgGgGGGGGGGggGggGgGggGGGg...
...GgGGgGGGGGGGgggGgGGTTTTTTT...
..GGgGGgGGGGGGGgggGggGgGgGGGg...
..GgGGgGGGGGGGGggggGGGgGgGgGgg..
.GGgGGgGGGGGGGGggggGGGgGgGggGg..
...................GGgGGgGggGgg.
...................GGgGGgGggGgg.
................................
................................
................................
"""

RABBIT = """
................................
........WWW...WWW...............
........WWW...WWW...............
........PWW...PWW...............
........PWW..WPWW...............
........PWW..WPWW...............
........WPWW.PWW................
........WPWW.PWW................
.........PWWWPWW................
.........WWWWWWW................
.......WWWWWWWW.................
......WWWWWWWWW.................
......WWWWWWWWW.................
.....WWRWWWWWWWW................
.....WWWWWWWWWWW................
.....PWWWWWWWWWW................
......WWWWWWWWWWWWWWWWWW........
......WWWWWWWWWWWWWWWWWWW.......
.......WWWWWWWWWWWWWWWWWWW......
.........WWWWWWWWWWWWWWWWWWWW...
..........WWWSWWWWWWWWWWWWWWWW..
..........WWWSWWWWWWWWWWWWWWWW..
..........WWSWWWWWWWWWWWWWWWS...
..........WWSWWWWWWWWWWWWWWW....
..........WSWWWWWWWWWWWWWWWW....
...........SWWWWWWWWWWWWWWW.....
.........WWWWWWWWWWWWWWWWW......
.........WWWWWWWWWWWWWWWW.......
..........SWSSSSSSWWWWWWWSS.....
................WWWWWWWWWWW.....
..................WWWWWWW.......
................................
"""

LANTERN = """
...............YY...............
...............YY...............
.........YYYYYYYYYYYYYY.........
.........YYYYYYYYYYYYYY.........
.........YOOOOOOOOOOOOY.........
........RRRRRrRrrRrRRRRR........
......RRRrRRRRRrrRRRRRrRRR......
....RRRRrRRRrRRrrRRrRRRrRRRR....
...RRRRrRRRRrRRrrRRrRRRRrRRRR...
..RRRRRrRRRrrRRrrRRrrRRRrRRRRR..
..RRRRrRRRRrRRRrrRRRrRRRRrRRRR..
.RRRRRrRRRRrRRRrrRRRrRRRRrRRRRR.
.RRRRRrRRRRrRRRrrRRRrRRRRrRRRRR.
.RRRRRrRRRRrRRRrrRRRrRRRRrRRRRR.
.RRRRRrRRRRrRRRrrRRRrRRRRrRRRRR.
.RRRRRrRRRRrRRRrrRRRrRRRRrRRRRR.
..RRRRrRRRRrRRRrrRRRrRRRRrRRRR..
..RRRRRrRRRrrRRrrRRrrRRRrRRRRR..
...RRRRrRRRRrRRrrRRrRRRRrRRRR...
....RRRRrRRRrRRrrRRrRRRrRRRR....
......RRRrRRRRRrrRRRRRrRRR......
........RROOOOOOOOOOOORR........
.........YYYYYYYYYYYYYY.........
.........YYYYYYYYYYYYYY.........
..............YYYY..............
..............YYYY..............
............OYOYOYOY............
............OYOYOYOY............
............OYOYOYOY............
............OYOYOYOY............
............OYOYOYOY............
............OYOYOYOY............
"""

WILLOW = """
...b.........................b..
...b.......ggggggggggg.......b..
......ggggggggggggggggggggg.....
...ggggggggggggggggggggggggggg..
..ggggggggggggGgGgggGgggggggggg.
..ggggggGgggGgGgggGgGgggGgggggg.
..ggGgGgggGgGgggGgGgggGgGgggGgG.
..G.G.ggGgGgggGgGgggGgGgggG.G.g.
..G.g.G.G.ggGgGgggGgGgg.G.G.g.G.
..g.G.G.g.GNG.g.GNG.g.G.G.gbG.G.
..G.G.g.G.G.gNGNGNg.G.G.g.GbG.g.
..G.g.G.G.g.G.GNg.G.G.g.G.G.g.G.
.bg.G.G.g.G.G.gNG.G.g.G.G.g.G.G.
.bG.G.g.G.G.g.GNG.g.G.G.g.G.G.g.
..G.g.G.Gbg.G.GNg.G.G.g.G.G.g.G.
..g.G.G.gbG.G.gNG.G.gbG.G.g.G.Gb
....G.g.G.G.g.GNG.g.Gb..g.G.G.gb
....g.G...g.G.GNg.G.G...G.G...G.
....G.G...G.G.NNG.G.g...G.g...G.
....G.g...G.g.NNG.g.....gbG...g.
....gb....g.G.NNg.G.....Gb....G.
....Gb....G...NNG.G.....G.....G.
....G.....Gb..NNG.......g.....g.
..........gb..NNg.............G.
.............NNNG..b............
.............NN....b.........b..
b............NN..............b..
b......b.....NN.................
.......b.....NN........b........
.............NN..b.....b........
...........NNNNNNb..............
...G...G...NNNNNNN...G....G...G.
"""

TOOLS = """
................................
.....................sS.........
......SSSS..........sssS........
.......SSSS........sssssS.......
........SSSS......sssssssS......
........SSSSS....sssssssssS.....
..S....SSSSSS...sssssssssssS....
..SS..SSSSSSS..sssssssssssssS...
..SSSSSSSSSSS..ssssssssssssssS..
..SSSSSSSSSSS...ssssssssssssssS.
...SSSSSSSSSS....sssssssssssss..
....SSSSSSSSSS....sssssssssss...
.....SSSSSsSSSS...Nsssssssss....
...........sSSSS.NNNsssssss.....
............sSSSNNNNNsssss......
.............sSNNNNN..sss.......
..............NNNNN....s........
.............NNNNNSS............
............NNNNNSSSS...........
...........NNNNN.sSSSS..........
..........NNNNN...sSSSS.........
.........NNNNN.....sSSSS........
........NNNNN.......sSSSS.......
.......NNNNN.........sSSSSSS....
......NNNNN...........sSSSSSSS..
.....NNNNN.............sSSSSSS..
....NNNNN..............SsS..SSS.
...NNNNN...............SSS..SSS.
...NNNN.................SSSSSS..
...NNN..................SSSSSS..
..........................SS....
................................
"""

DRAGON_BOAT = """
................................
................................
...........................Y....
........................YY..Y...
................................
.......................GGGGGGGGG
.......................GGGYGGGGG
........................GGGGGGGG
........................GGGRRRRR
........................GGGRRRRR
..G......................GGGGGG.
.Y......................GG..GGG.
GG.....RR..RR..RR..RR..RRG..GGG.
GG.....KK..KK..KK..KK..KK..GGGG.
GGG....KK..KK..KK..KK..KK..GGGG.
.GG....YY..YY..YY..YY..YY..GGG..
.GG....YY..YY..YY..YY..YY.GGGG..
.GGG...YY..YY..YY..YY..YY.GGGG..
.RGGRRRRRRRRRRRRRRRRRRRRRRGGG...
..GGRrRRrRRrRRrRRrRRrRRrRRGGG...
..RRRRRRRRRRRRRRRRRRRRRRRRGGG...
...YYYYYYYYYYYYYYYYYYYYYYYYR....
...RRRRRRRRRRRRRRRRRRRRRRRRR....
...RRRrRRrRRrRRrRRrRRrRRrRR.....
....RRRRRRRRRRRRRRRRRRRRRRR.....
....RRRRRRRRRRRRRRRRRRRRRRR.....
.b..N..bN...Nb..N..bN....b.....b
bBbBNBbBNBBBNBbBNBbBNBBBbBbBBBbB
BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
BBBbbBBBBbbBBBBbbBBBBbbBBBBbbBBB
BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
"""

MOON = """
................................
...........LLLLLLLLLL...........
.........LLLLLLLLLLLLLL.........
.......LLLLLLllllLLLLLLLL.......
......LLLLllmmmmmmllLLLLLL......
.....LLLLlmmmmmmmmmmlLLLLLL.....
....LLLLLLllllllllllLLLLLLLL....
...LLLLLLllmmmmllLLlllLLLLLLL...
...LLLLLlmmmmmmmmllmmmlLLLLll...
..LLLLLLlmmmmmmmmlmmmmmlLLlmml..
..LLLlllmmmmmmmmmmmmmmmlLlmmml..
.LLLlmmmmmmmmmmmmlmmmmlLLlmmmlL.
.LLlmmmmmmmmmmmmmmlllllllLlmmlL.
.LLlmmmmmmlmmmmlmmllmmmmmllllLL.
.LLmmmmmmmmllllllllmmmmmmlLLLLL.
.LlmmmmmmmmlLLLLLLlmmmmmmlLLLLL.
.LlmmmmmmmmlLLLLLLLlmmmmmllLLLL.
.LlmmmmmmmmlLLLLLLLllmmlmmmlLLL.
.LLmmmmmmmmllLLLLLLLLlllmmmlLLL.
.LLlmmmmmmmmlllLLLLLLLLlmmmlLLL.
.LLlmmmmmmmmmmmlLLLLLLLlmmmlLLL.
..LLlmmmmmmmmmmmlLLLLLLlmmlLLL..
..LLLlllmmmmmmmlLLLLLLLLllLLLL..
...LLLLllllWlllWLLLLLLLLLLLLL...
...LLLLLLLLLLWLLLWLLLLLLLLLLL...
....LLLLLLLLLLLWLLLLLLLLLLLL....
.....LLLLLLLWLLLLLLLLLLLLLL.....
......LLLLLLLLLWLLWLLLLLLL......
.......LLLLLLLLLLLLLLLLLL.......
.........LLLLLLLLLLLLLL.........
...........LLLLLLLLLL...........
................................
"""

FLAG = """
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRYRRRRRYYRRRRRRRRRRRRRRRRRRR
RRRRRYRRRRRYYRRRRRRRRRRRRRRRRRRR
RRYYYYYYYRRRRYYRRRRRRRRRRRRRRRRR
RRRYYYYYRRRRRYYRRRRRRRRRRRRRRRRR
RRRRYYYRRRRRRRRRRRRRRRRRRRRRRRRR
RRRYYRYYRRRRRYYRRRRRRRRRRRRRRRRR
RRRYRRRYRRRRRYYRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRYYRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRYYRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
"""

# ---- the holidays -------------------------------------------------------------
# name: shown under DAYS TIL, in color. border / pattern: the top border's
# colour and repeating unit, when a holiday sets its own (FRET and FRET_UNIT
# otherwise). The count is drawn in the name's colour. count: the colour of the
# big greeting line, when a holiday sets its own (GOLD otherwise). left / right: what fills each icon slot,
# a sprite (centred in the slot) or the name of a 32x32 PNG in assets/, or None
# to leave the slot empty. hi: the greeting on the day, a small line over a big
# gold one.
HOLIDAYS = {
    "newyear": {"name": "NEW YEAR'S DAY", "color": "#FFD23F", "left": "fu.png",
                "right": FIREWORKS, "hi": ["HAPPY", "NEW YEAR"]},
    "cny": {"name": "CHINESE NEW YEAR", "color": "#B5121B", "border": "#B5121B",
            "left": LANTERN,
            "right": FIRECRACKERS, "hi": ["HAPPY CHINESE", "NEW YEAR"]},
    "qingming": {"name": "QINGMING", "color": "#7ED957", "border": WAVE,
                 "pattern": WAVE_UNIT, "left": WILLOW,
                 "right": KITES, "hi": ["TODAY IS", "QINGMING"]},
    "labour": {"name": "LABOUR DAY", "color": GEAR, "count": GEAR, "border": GEAR,
               "pattern": GEAR_UNIT, "left": TOOLS,
               "right": HAND_WRENCH, "hi": ["HAPPY", "LABOUR DAY"]},
    "dragon": {"name": "DRAGON BOAT", "color": RAIL, "count": RAIL, "border": RAIL,
               "pattern": WAVE_UNIT, "left": DRAGON_BOAT,
               "right": ZONGZI, "hi": ["HAPPY", "DRAGON BOAT"]},
    "midautumn": {"name": "MID-AUTUMN", "short": "MID-AUTUMN", "color": GOLD, "count": GOLD, "border": GOLD,
                  "pattern": RAIL_UNIT, "left": MOON,
                  "right": RABBIT, "hi": ["HAPPY", "MID-AUTUMN"]},
    "national": {"name": "NATIONAL DAY", "short": "NATIONAL", "color": "#FF3B30", "left": FLAG,
                 "right": "years", "hi": ["HAPPY", "NATIONAL DAY"]},
}

# The Holiday dropdown, lowercased. The labels avoid '-', '_', ':' and "'",
# which the render descriptor treats as delimiters, so they reach the app
# intact. "next holiday" (None) follows whichever holiday comes next.
CHOICES = {
    "next holiday": None,
    "new year (jan 1)": "newyear",
    "chinese new year": "cny",
    "qingming": "qingming",
    "labour day": "labour",
    "dragon boat": "dragon",
    "mid autumn": "midautumn",
    "national day": "national",
}

# Calendar order, which is also the order two holidays on one day are named in.
ORDER = ["newyear", "cny", "qingming", "labour", "dragon", "midautumn", "national"]
FIXED = {"newyear": [1, 1], "labour": [5, 1], "national": [10, 1]}

# year: [Chinese New Year, Qingming, Dragon Boat, Mid-Autumn] as [month, day].
LUNAR_KEYS = ["cny", "qingming", "dragon", "midautumn"]
LUNAR = {
    2026: [[2, 17], [4, 5], [6, 19], [9, 25]],
    2027: [[2, 6], [4, 5], [6, 9], [9, 15]],
    2028: [[1, 26], [4, 4], [5, 28], [10, 3]],
    2029: [[2, 13], [4, 4], [6, 16], [9, 22]],
    2030: [[2, 3], [4, 5], [6, 5], [9, 12]],
    2031: [[1, 23], [4, 5], [6, 24], [10, 1]],
    2032: [[2, 11], [4, 4], [6, 12], [9, 19]],
    2033: [[1, 31], [4, 4], [6, 1], [9, 8]],
    2034: [[2, 19], [4, 5], [6, 20], [9, 27]],
    2035: [[2, 8], [4, 5], [6, 10], [9, 16]],
    2036: [[1, 28], [4, 4], [5, 30], [10, 4]],
    2037: [[2, 15], [4, 4], [6, 18], [9, 24]],
    2038: [[2, 4], [4, 5], [6, 7], [9, 13]],
    2039: [[1, 24], [4, 5], [5, 27], [10, 2]],
    2040: [[2, 12], [4, 4], [6, 14], [9, 20]],
    2041: [[2, 1], [4, 4], [6, 3], [9, 10]],
    2042: [[1, 22], [4, 4], [6, 22], [9, 28]],
    2043: [[2, 10], [4, 5], [6, 11], [9, 17]],
    2044: [[1, 30], [4, 4], [5, 31], [10, 5]],
    2045: [[2, 17], [4, 4], [6, 19], [9, 25]],
}

# The name steps down this ladder until the count block fits the zone. The
# second number is the row that keeps each size centred in the 6x8 name row.
NAME_FONTS = [["6x8", 17], ["5x7", 18], ["4x5", 19]]

# ---- date arithmetic -------------------------------------------------------
def days_from_civil(y, m, d):
    """Days since 1970-01-01 (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + 1 if m <= 2 else y, m, d]

def weekday(z):
    """0 = Monday .. 6 = Sunday. Day 0 (1970-01-01) was a Thursday."""
    return (z + 3) % 7

# ---- time zones ------------------------------------------------------------
# ctx.now is UTC. The reader picks the city nearest them and the offset,
# daylight saving included, is worked out here with no network call. The
# dropdown lists the cities west to east, each with its standard offset; the
# minus sign is U+2212, because '-' is a delimiter in the render descriptor.
#
# city (lowercased) -> [standard offset in minutes, DST rule]
#   0 none  1 United States  2 Europe (UK and EU)  3 Australia (southern)
TZ = {
    "london": [0, 2],
    "paris": [60, 2],
    "moscow": [180, 0],
    "bangkok": [420, 0],
    "beijing": [480, 0],
    "tokyo": [540, 0],
    "sydney": [600, 3],
    "san francisco": [-480, 1],
    "denver": [-420, 1],
    "chicago": [-360, 1],
    "new york": [-300, 1],
    "rio de janeiro": [-180, 0],
}

def nth_sunday(y, m, n):
    """Day of the month of the nth Sunday, or the last one when n is -1."""
    if n == -1:
        last = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
        if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
            last = 29
        return last - ((weekday(days_from_civil(y, m, last)) + 1) % 7)
    first = 1 + ((6 - weekday(days_from_civil(y, m, 1))) % 7)
    return first + 7 * (n - 1)

def _utcmin(y, m, d, hh):
    return days_from_civil(y, m, d) * 1440 + hh * 60

def zone_offset_at(city, t):
    """Minutes east of UTC for `city` at the UTC instant `t` (minutes since
    the epoch). Every comparison is done in UTC so the local-time
    discontinuity at a changeover never has to be reasoned about."""
    z = TZ.get(city, TZ["new york"])
    std, rule = z[0], z[1]
    if rule == 0:
        return std
    y = civil_from_days(t // 1440)[0]
    if rule == 1:
        # United States: 2nd Sunday in March to 1st Sunday in November, 02:00
        start = _utcmin(y, 3, nth_sunday(y, 3, 2), 2) - std
        end = _utcmin(y, 11, nth_sunday(y, 11, 1), 2) - std - 60
        return std + 60 if t >= start and t < end else std
    if rule == 2:
        # UK and EU: last Sunday in March to last Sunday in October, 01:00 UTC
        start = _utcmin(y, 3, nth_sunday(y, 3, -1), 1)
        end = _utcmin(y, 10, nth_sunday(y, 10, -1), 1)
        return std + 60 if t >= start and t < end else std
    # Australia: summer straddles New Year, from the 1st Sunday in October to
    # the 1st Sunday in April, so the test is inverted.
    start = _utcmin(y, 10, nth_sunday(y, 10, 1), 2) - std
    end = _utcmin(y, 4, nth_sunday(y, 4, 1), 3) - std - 60
    return std if t >= end and t < start else std + 60

def local_today(ctx):
    """[y, m, d] on the reader's wall clock."""
    # The dropdown labels carry the standard offset, "Beijing (+8)"; only the
    # city name before the bracket is looked up, so the label can say anything
    # after it.
    city = str(ctx.inputs.get("timezone", "New York (−5)")).split("(")[0].strip().lower()
    mins = ctx.now.unix // 60 + zone_offset_at(city, ctx.now.unix // 60)
    return civil_from_days(mins // 1440)

# ---- which holiday -------------------------------------------------------------
def dates_in(y):
    """[[day number, holiday id], ...] for the holidays of year y that are known."""
    out = []
    for h in ORDER:
        md = None
        if h in FIXED:
            md = FIXED[h]
        elif y in LUNAR:
            md = LUNAR[y][LUNAR_KEYS.index(h)]
        if md != None:
            out.append([days_from_civil(y, md[0], md[1]), h])
    return out

def next_holiday(t):
    """[days to go, day number, [holiday ids]]. Zero on the day itself. Two
    holidays on one day (Mid-Autumn on National Day, as in 2031) come back
    together, in calendar order."""
    today = days_from_civil(t[0], t[1], t[2])
    best = None
    ids = []
    for y in [t[0], t[0] + 1]:
        for e in dates_in(y):
            if e[0] < today:
                continue
            if best == None or e[0] < best:
                best = e[0]
                ids = [e[1]]
            elif e[0] == best:
                ids.append(e[1])
    return [best - today, best, ids]

def next_of(t, h):
    """[days to go, day number, [h]] for the next date of holiday h, today
    included, or None when the table has no date for it (a lunar holiday
    after 2045)."""
    today = days_from_civil(t[0], t[1], t[2])
    for y in [t[0], t[0] + 1]:
        for e in dates_in(y):
            if e[1] == h and e[0] >= today:
                return [e[0] - today, e[0], [h]]
    return None

# ---- text --------------------------------------------------------------------
def width_of(c, text, font):
    """c.text_width, counting each apostrophe as the 2 px draw_text gives it."""
    return c.text_width(text.replace("'", ""), font) + 2 * text.count("'")

def draw_text(c, text, x, y, font, color):
    """c.text, except that apostrophes are drawn. None of the bundled fonts has
    one, and a missing glyph draws as nothing: NEW YEAR'S would read NEW YEARS
    with no gap. The tick is a 1x2 bar at cap height."""
    parts = text.split("'")
    for i in range(len(parts)):
        if i > 0:
            c.rect(x, y, x, y + 1, fill = color)
            x += 2
        c.text(parts[i], x, y, font = font, color = color)
        x += c.text_width(parts[i], font)
    return x

# ---- scene -------------------------------------------------------------------
def border(c, color, unit, right_color = None):
    """A repeating pattern (the key fret, or a holiday's own) along the top of
    the centre column. With right_color, the right half is drawn in it: red
    and gold for National Day and Mid-Autumn on one day."""
    w = len(unit[0])
    half = (MIDL + MIDR + 1) // 2
    for x in range(MIDL, MIDR + 1):
        col = (x - MIDL) % w
        ink = right_color if right_color != None and x >= half else color
        for r in range(len(unit)):
            if unit[r][col] == "#":
                c.pixel(x, TOPY + r, ink)

def ordinal(n):
    """77 -> 77TH, 81 -> 81ST, 111 -> 111TH."""
    if n % 100 in (11, 12, 13):
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

def icon(c, what, slotx, year):
    """Fill one icon slot: a 32x32 PNG from assets/ at the slot's corner, a
    sprite centred in it, or "years": the founding year 1949 over a dash over
    this year's anniversary, 77TH in 2026, for National Day."""
    if what == None:
        return
    if what == "years":
        mid = slotx + SLOT // 2
        # rows: 1949 at 6-13, a dividing line across the slot at 16, the
        # anniversary at 19-26
        c.text("1949", mid, 6, font = "6x8", color = GOLD, align = "center")
        c.rect(slotx + 2, 16, slotx + SLOT - 3, 16, fill = GOLD)
        # From the 100TH (2049) the ordinal is wider than the slot at 6x8.
        nth = ordinal(year - 1949)
        if c.text_width(nth, "6x8") <= SLOT:
            c.text(nth, mid, 19, font = "6x8", color = GOLD, align = "center")
        else:
            c.text(nth, mid, 20, font = "5x7", color = GOLD, align = "center")
        return
    if what.endswith(".png"):
        c.image(what, slotx, 0)
        return
    rows = what.strip().split("\n")
    c.sprite(what, slotx + (SLOT - len(rows[0])) // 2, (SLOT - len(rows)) // 2,
             legend = LEG)

COMBO_GAP = 3        # px between the pieces of NATIONAL & MID-AUTUMN

def combo_parts(ids):
    """[[text, colour], ...] naming two holidays that share a day, each in its
    own colour: NATIONAL & MID-AUTUMN in 2031, National Day named first."""
    a = HOLIDAYS[ids[1]]
    b = HOLIDAYS[ids[0]]
    return [[a.get("short", a["name"]), a["color"]], ["&", LABEL],
            [b.get("short", b["name"]), b["color"]]]

def parts_width(c, parts, font):
    """Width of the pieces drawn side by side with COMBO_GAP between them. A
    fixed 3 px gap rather than space glyphs is what lets the pair fit 5x7."""
    w = COMBO_GAP * (len(parts) - 1)
    for p in parts:
        w += width_of(c, p[0], font)
    return w

def draw_parts(c, parts, x, y, font):
    for i in range(len(parts)):
        if i > 0:
            x += COMBO_GAP
        x = draw_text(c, parts[i][0], x, y, font, parts[i][1])

def fit_rung(c, parts, room):
    """The first rung of NAME_FONTS at which the pieces fit `room`."""
    for f in NAME_FONTS:
        if parts_width(c, parts, f[0]) <= room:
            return f
    return NAME_FONTS[len(NAME_FONTS) - 1]

def greeting(c, ids, cx):
    """The day itself: a small line over a big gold one, centred in the zone.
    Two holidays on one day get HAPPY over both names in their own colours,
    at the largest size that fits."""
    h = HOLIDAYS[ids[0]]
    small = h["hi"][0]
    big = h["hi"][1]
    if len(ids) > 1:
        parts = combo_parts(ids)
        rung = fit_rung(c, parts, ZONER - ZONEL + 1)
        c.text("HAPPY", cx, 8, font = "5x7", color = LABEL, align = "center")
        draw_parts(c, parts, cx - parts_width(c, parts, rung[0]) // 2, rung[1] + 1, rung[0])
        return
    c.text(small, cx, 8, font = "5x7", color = LABEL, align = "center")
    font = "9x12" if width_of(c, big, "9x12") <= ZONER - ZONEL + 1 else "6x8"
    draw_text(c, big, cx - width_of(c, big, font) // 2, 16, font, h.get("count", GOLD))

# ---- the page ----------------------------------------------------------------
def countdown(c, ctx):
    c.fill("black")
    choice = CHOICES.get(str(ctx.inputs.get("holiday", "Next holiday")).strip().lower())
    today = local_today(ctx)
    nh = next_of(today, choice) if choice != None else None
    if nh == None:
        nh = next_holiday(today)
    n = nh[0]
    ids = nh[2]
    h = HOLIDAYS[ids[0]]

    if len(ids) > 1:
        # Two holidays on one day: the border splits down the middle, the
        # second holiday's colour over its flag at the left, the first's over
        # the moon at the right, in the first holiday's pattern.
        border(c, HOLIDAYS[ids[1]].get("border", FRET), h.get("pattern", FRET_UNIT),
               h.get("border", FRET))
    else:
        border(c, h.get("border", FRET), h.get("pattern", FRET_UNIT))
    # Two holidays on one day: each takes a slot with its own picture, National
    # Day's flag at the left and Mid-Autumn's moon at the right, in the same
    # order as NATIONAL & MID-AUTUMN.
    left = h["left"]
    right = h["right"]
    if len(ids) > 1:
        left = HOLIDAYS[ids[1]]["left"]
        right = h["left"]
    icon(c, left, LEFTX, today[0])
    icon(c, right, RIGHTX, today[0])
    cx = (ZONEL + ZONER) // 2
    zonew = ZONER - ZONEL + 1

    if n == 0:
        greeting(c, ids, cx)
        return

    # The number, then two lines to its right: DAYS TIL and the name.
    # Following the next holiday, the count is 92 at most (1 October to
    # 1 January); one chosen holiday can be up to 384 days away (Chinese New
    # Year from 22 January to 10 February a year later). The build checks that
    # every holiday's block fits the zone at three digits on some rung of
    # NAME_FONTS.
    word = "DAY TIL" if n == 1 else "DAYS TIL"
    # The name as pieces: one holiday's name, or for two on one day (Mid-Autumn
    # on National Day, 2031) both short names in their own colours.
    if len(ids) > 1:
        parts = combo_parts(ids)
    else:
        parts = [[h["name"], h["color"]]]

    numstr = str(n)
    numw = c.text_width(numstr, "10x16")
    small = c.text_width(word, "4x5")
    rung = NAME_FONTS[len(NAME_FONTS) - 1]
    for f in NAME_FONTS:
        if numw + 5 + max(parts_width(c, parts, f[0]), small) <= zonew:
            rung = f
            break
    labw = max(parts_width(c, parts, rung[0]), small)
    x0 = cx - (numw + 5 + labw) // 2
    lx = x0 + numw + 5

    # Below the border: the number 10-25, and beside it DAYS TIL 10-14 over the
    # name in 17-24, the pair centred on the number.
    c.text(numstr, x0, 10, font = "10x16", color = h["color"])
    c.text(word, lx, 10, font = "4x5", color = LABEL)
    draw_parts(c, parts, lx, rung[1], rung[0])
