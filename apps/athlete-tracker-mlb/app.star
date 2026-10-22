# Athlete Tracker (MLB): a baseball jersey in team colours with the player's
# number, plus their bio line and live or season stats.

# ---------------------------------------------------------------- sprites
# P primary, D primary shade, L primary light, S secondary trim, W white,
# M facemask, G facemask shade, E dark padding. The number is stamped on at runtime.

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

NFL_HELMET = [
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

# Block jersey numerals, 6x11, 2px strokes.
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

# Helmet-side numerals, 5x7.
SMALL_DIGITS = {
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

# sport -> art, numeral set, numeral centre x, numeral top y, sprite x/y on panel
SPORTS = {
    "nba": {"art": NBA_JERSEY, "digits": BIG_DIGITS, "cx": 14, "top": 11, "x": 1, "y": 1},
    "nfl": {"art": NFL_HELMET, "digits": SMALL_DIGITS, "cx": 10, "top": 10, "x": 0, "y": 4},
    "nhl": {"art": NHL_SWEATER, "digits": BIG_DIGITS, "cx": 15, "top": 9, "x": 1, "y": 3},
    "mlb": {"art": MLB_JERSEY, "digits": BIG_DIGITS, "cx": 15, "top": 10, "x": 1, "y": 3},
}

# team logos (19px box, ESPN scoreboard logos snapped to each team palette). Literal paths so the linter can check them.
LOGOS = {
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
}

# logo sizes that are not 19x19 (w, h)
LOGO_SIZE = {
    "mlb_ari": (19, 16),
    "mlb_ath": (23, 19),
    "mlb_atl": (20, 19),
    "mlb_bal": (20, 19),
    "mlb_bos": (13, 19),
    "mlb_chc": (19, 19),
    "mlb_chw": (14, 19),
    "mlb_cin": (26, 18),
    "mlb_cle": (12, 19),
    "mlb_col": (16, 19),
    "mlb_det": (13, 19),
    "mlb_hou": (19, 19),
    "mlb_kc": (19, 19),
    "mlb_laa": (12, 19),
    "mlb_lad": (13, 19),
    "mlb_mia": (23, 18),
    "mlb_mil": (17, 19),
    "mlb_min": (18, 19),
    "mlb_nym": (13, 19),
    "mlb_nyy": (17, 19),
    "mlb_phi": (14, 19),
    "mlb_pit": (13, 19),
    "mlb_sd": (14, 19),
    "mlb_sea": (12, 19),
    "mlb_sf": (13, 19),
    "mlb_stl": (15, 19),
    "mlb_tb": (22, 19),
    "mlb_tex": (17, 19),
    "mlb_tor": (24, 19),
    "mlb_wsh": (24, 19),
}

# ---------------------------------------------------------------- players
# The dropdown label the user picked -> (league, ESPN athlete id).

# BEGIN PLAYERS (generated by tools/athlete_tracker_players.py; do not edit by hand)
PLAYERS = {
    "A.J. Ewing": 5208019,
    "A.J. Minter": 36133,
    "Aaron Ashby": 41325,
    "Aaron Civale": 40934,
    "Aaron Judge": 33192,
    "Aaron Nola": 33709,
    "Abimelec Ortiz": 5194635,
    "Abner Uribe": 4917865,
    "Adael Amador": 4917787,
    "Addison Barger": 4997589,
    "Adley Rutschman": 42178,
    "Adolis Garcia": 35537,
    "Adrian Houser": 32157,
    "Adrian Morejon": 40917,
    "Agustin Ramirez": 5132014,
    "Aidan Miller": 5148968,
    "AJ Blubaugh": 42556,
    "AJ Smith-Shawver": 4917640,
    "Alec Bohm": 41169,
    "Alec Burleson": 4345070,
    "Alejandro Kirk": 42081,
    "Alex Bregman": 34886,
    "Alex Lange": 40976,
    "Alex McFarlane": 4621422,
    "Alex Vesia": 42622,
    "Amed Rosario": 33215,
    "Andre Pallante": 4109034,
    "Andres Gimenez": 37729,
    "Andres Munoz": 40939,
    "Andrew Abbott": 4414528,
    "Andrew Alvarez": 4300668,
    "Andrew Benintendi": 34986,
    "Andrew Fischer": 5128616,
    "Andrew Kittredge": 35872,
    "Andrew Morris": 5007765,
    "Andrew Painter": 4872683,
    "Andrew Vaughn": 42394,
    "Andruw Monasterio": 36950,
    "Andy Pages": 42468,
    "Angel Genao": 5204351,
    "Angel Martinez": 42497,
    "Anthony Eyanson": 5129725,
    "Anthony Kay": 40947,
    "Anthony Molina": 5016983,
    "Anthony Santander": 36084,
    "Anthony Volpe": 42547,
    "Antonio Senzatela": 33750,
    "Antwone Kelly": 5134366,
    "Aroldis Chapman": 30442,
    "Austin Martin": 4297998,
    "Austin Riley": 34982,
    "Austin Wells": 4683349,
    "Bailey Ober": 3107919,
    "Ben Brown": 41516,
    "Ben Joyce": 4867388,
    "Ben Rice": 5016968,
    "Blade Tidwell": 4719088,
    "Blake Snell": 33748,
    "Blaze Alexander": 41345,
    "Blaze Jordan": 4722953,
    "Bo Bichette": 38904,
    "Bo Naylor": 41183,
    "Bobby Witt Jr.": 42403,
    "Brad Keller": 35292,
    "Brad Lord": 4866810,
    "Braden Montgomery": 4950345,
    "Bradgley Rodriguez": 5266086,
    "Brady House": 4872681,
    "Brady Singer": 41172,
    "Brandon Lowe": 39961,
    "Brandon Marsh": 40803,
    "Brandon Nimmo": 32159,
    "Brandon Pfaadt": 4721302,
    "Brandon Sproat": 4621041,
    "Brandon Valenzuela": 4918248,
    "Brandon Williamson": 42431,
    "Brandon Woodruff": 37515,
    "Brandon Young": 4414339,
    "Brandyn Garcia": 5202600,
    "Braxton Ashcraft": 41282,
    "Brayan Bello": 4720856,
    "Brayan Rocchio": 41217,
    "Braydon Fisher": 41318,
    "Brendan Donovan": 41773,
    "Brent Headrick": 5116839,
    "Brent Rooker": 40926,
    "Brent Suter": 36023,
    "Brenton Doyle": 42462,
    "Brett Bateman": 5134494,
    "Brett Baty": 42414,
    "Brice Turang": 41179,
    "Brock Burke": 39945,
    "Brooks Lee": 4629081,
    "Brooks Raley": 32005,
    "Bryan Abreu": 41208,
    "Bryan Baker": 40884,
    "Bryan Hudson": 4991171,
    "Bryan King": 5201821,
    "Bryan Reynolds": 38980,
    "Bryan Woo": 4629089,
    "Bryce Elder": 4301067,
    "Bryce Eldridge": 5149064,
    "Bryce Harper": 30951,
    "Bryce Miller": 4654313,
    "Bryson Stott": 42417,
    "Bubba Chandler": 4683325,
    "Byron Buxton": 32655,
    "Cade Cavalli": 4308037,
    "Cade Horton": 4692526,
    "Cade Smith": 4987924,
    "Cal Quantrill": 39875,
    "Cal Raleigh": 41292,
    "Caleb Durbin": 5007615,
    "Calvin Faucher": 3978173,
    "Cam Schlittler": 5134581,
    "Cam Smith": 5080766,
    "Camilo Doval": 41337,
    "Carlos Correa": 32653,
    "Carlos Cortes": 41595,
    "Carlos Estevez": 34861,
    "Carlos Lagrange": 5201825,
    "Carlos Narvaez": 5012120,
    "Carlos Rodon": 33696,
    "Carmen Mlodzinski": 4298378,
    "Carson Benge": 4925604,
    "Carson Kelly": 32797,
    "Carter Jensen": 4917812,
    "Casey Mize": 41167,
    "Casey Schmitt": 4301949,
    "Ceddanne Rafaela": 4987382,
    "Cedric Mullins": 35578,
    "Cesar Perdomo": 5271881,
    "Chad Patrick": 5131708,
    "Chandler Simpson": 4679983,
    "Charlie Condon": 5033089,
    "Chase Burns": 4927516,
    "Chase DeLauter": 4619649,
    "Chase Dollander": 4719068,
    "Chase Meidroth": 5136929,
    "Chris Bassitt": 33148,
    "Chris Sale": 30948,
    "Christian Encarnacion-Strand": 5012106,
    "Christian Koss": 4109031,
    "Christian Scott": 4414215,
    "Christian Vazquez": 31389,
    "Christian Walker": 32758,
    "Christian Yelich": 31283,
    "CJ Abrams": 42402,
    "Clarke Schmidt": 41085,
    "Clay Holmes": 32827,
    "Clayton Beeter": 4313143,
    "Coby Mayo": 4683371,
    "Cody Bellinger": 33912,
    "Cody Bradford": 4142539,
    "Cody Ponce": 34999,
    "Cole Carrigg": 5149102,
    "Cole Ragans": 41054,
    "Cole Young": 5080641,
    "Colin Rea": 33950,
    "Colson Montgomery": 4872685,
    "Colt Emerson": 5149068,
    "Colt Keith": 4683384,
    "Colton Cowser": 4416990,
    "Connelly Early": 4863321,
    "Connor Norby": 4417606,
    "Connor Prielipp": 4620001,
    "Cooper Pratt": 5149101,
    "Corbin Burnes": 39878,
    "Corbin Carroll": 42404,
    "Corey Seager": 32691,
    "Cristian Javier": 41261,
    "Cristopher Sanchez": 42359,
    "Curtis Mead": 42360,
    "Dalton Rushing": 4619839,
    "Daniel Duarte": 41094,
    "Daniel Lynch IV": 41227,
    "Daniel Palencia": 4875225,
    "Daniel Schneemann": 42001,
    "Dansby Swanson": 34895,
    "Daulton Varsho": 40963,
    "David Bednar": 38303,
    "David Hamilton": 42987,
    "David Peterson": 40921,
    "David Sandlin": 4960696,
    "Davis Martin": 42823,
    "Daylen Lile": 4917889,
    "Dean Kremer": 38295,
    "Dedniel Nunez": 4717899,
    "Dennis Santana": 39801,
    "Devin Williams": 33224,
    "Didier Fuentes": 5291189,
    "Dillon Dingler": 4345620,
    "DJ Herz": 4917686,
    "DL Hall": 41018,
    "Dominic Canzone": 4345621,
    "Dominic Smith": 33218,
    "Donovan Walton": 37232,
    "Drake Baldwin": 4810190,
    "Drew Anderson": 41125,
    "Drew Rasmussen": 42584,
    "Dustin Harris": 4917924,
    "Dustin May": 40937,
    "Dylan Beavers": 4959037,
    "Dylan Cease": 34943,
    "Dylan Crews": 4719511,
    "Dylan Dodd": 4416462,
    "Dylan Lee": 41455,
    "Edmundo Sosa": 33809,
    "Eduard Bazardo": 41939,
    "Eduardo Rodriguez": 32675,
    "Eduardo Valencia": 5133392,
    "Edward Cabrera": 40944,
    "Edwin Diaz": 35394,
    "Edwin Uceta": 41308,
    "Eli Willits": 5293140,
    "Elly De La Cruz": 4917694,
    "Elmer Rodriguez": 5194637,
    "Elvis Alvarado": 42211,
    "Emerson Hancock": 4297897,
    "Emilio Pagan": 33403,
    "Emmanuel Rodriguez": 5017049,
    "Emmet Sheehan": 4417806,
    "Endy Rodriguez": 4712767,
    "Enrique Hernandez": 31358,
    "Eric Lauer": 39915,
    "Erick Fedde": 33793,
    "Erik Miller": 4152950,
    "Erik Sabrowski": 5194333,
    "Erik Tolman": 5337128,
    "Ernie Clement": 41287,
    "Esmerlyn Valdez": 5137200,
    "Esteury Ruiz": 39680,
    "Ethan Holliday": 5293136,
    "Ethan Pecko": 4944276,
    "Ethan Salas": 5124004,
    "Eugenio Suarez": 32367,
    "Eury Perez": 4917854,
    "Evan Carter": 4917921,
    "Evan Phillips": 37911,
    "Ezequiel Duran": 42457,
    "Ezequiel Tovar": 4905919,
    "Felix Bautista": 4905859,
    "Fernando Cruz": 34068,
    "Fernando Tatis Jr.": 35983,
    "Foster Griffin": 33773,
    "Framber Valdez": 36581,
    "Francisco Alvarez": 41253,
    "Francisco Lindor": 32129,
    "Franklin Arias": 5273064,
    "Freddie Freeman": 30193,
    "Freddy Peralta": 39825,
    "Gabe Speier": 40327,
    "Gabriel Hughes": 4634930,
    "Gabriel Moreno": 42464,
    "Gage Jump": 5023852,
    "Garrett Cleavinger": 36429,
    "Garrett Crochet": 4297835,
    "Garrett Mitchell": 4313442,
    "Garrett Whitlock": 39674,
    "Gary Sanchez": 31095,
    "Gavin Sheets": 40700,
    "Gavin Williams": 4345076,
    "George Kirby": 42406,
    "George Klassen": 5134517,
    "George Lombard Jr.": 5149070,
    "George Soriano": 4917836,
    "George Springer": 32078,
    "Geraldo Perdomo": 41355,
    "Gerrit Cole": 32081,
    "Giancarlo Stanton": 30583,
    "Gleyber Torres": 33804,
    "Gordon Graceffo": 5123582,
    "Graham Ashcraft": 4084179,
    "Grant Holmes": 33840,
    "Grant Taylor": 4927630,
    "Grayson Rodriguez": 41196,
    "Gregory Soto": 39804,
    "Griffin Conine": 41295,
    "Griffin Jax": 42604,
    "Gunnar Henderson": 42507,
    "Hagen Smith": 5023126,
    "Hao-Yu Lee": 5124113,
    "Harrison Bader": 35062,
    "Hayden Wesneski": 42996,
    "Hector Rodriguez": 5122878,
    "Heliot Ramos": 39642,
    "Henry Bolte": 5080756,
    "Heriberto Hernandez": 42455,
    "Hogan Harris": 41364,
    "Hunter Brown": 4717803,
    "Hunter Dobbins": 4415836,
    "Hunter Gaddis": 4187661,
    "Hunter Goodman": 4416591,
    "Hunter Greene": 39635,
    "Hyeseong Kim": 5134614,
    "Ian Happ": 34945,
    "Ian Seymour": 4669425,
    "Ildemaro Vargas": 32985,
    "Isaac Paredes": 39706,
    "Ivan Herrera": 41889,
    "J.P. Crawford": 33210,
    "J.T. Ginn": 4414002,
    "J.T. Realmuto": 32177,
    "Jac Caglianone": 4926296,
    "Jack Dreyer": 5136082,
    "Jack Flaherty": 33837,
    "Jack Kochanowicz": 4917819,
    "Jack Leiter": 4622181,
    "Jack Perkins": 4418686,
    "Jackson Chourio": 4917869,
    "Jackson Holliday": 5080633,
    "Jackson Jobe": 4872647,
    "Jackson Merrill": 4872691,
    "Jacob deGrom": 32796,
    "Jacob Gonzalez": 4720990,
    "Jacob Latz": 3210625,
    "Jacob Lopez": 42239,
    "Jacob Misiorowski": 5080761,
    "Jacob Webb": 40384,
    "Jacob Wilson": 4719300,
    "Jacob Young": 4414210,
    "Jake Bauers": 35013,
    "Jake Bennett": 4654024,
    "Jake Burger": 39882,
    "Jake Cronenworth": 36364,
    "Jake Irvin": 41290,
    "Jake Mangum": 42664,
    "Jake McCarthy": 41197,
    "Jakob Junis": 36056,
    "Jakob Marsee": 4866735,
    "James Tibbs III": 4925860,
    "James Wood": 4918256,
    "Jameson Taillon": 31258,
    "Janson Junk": 4881980,
    "Jared Jones": 4918156,
    "Jared Young": 41575,
    "Jarren Duran": 41610,
    "Jason Adam": 32145,
    "Jasson Dominguez": 42401,
    "Javier Assad": 5002950,
    "Javier Baez": 32127,
    "Javier Sanoja": 5073992,
    "Jazz Chisholm Jr.": 41433,
    "Jeff Hoffman": 33841,
    "Jeff McNeil": 33900,
    "Jeffrey Springs": 35397,
    "Jeremiah Estrada": 41014,
    "Jeremiah Jackson": 41264,
    "Jeremy Pena": 41273,
    "Jesus Luzardo": 39667,
    "Jesus Made": 5196211,
    "Jesus Sanchez": 39957,
    "Jhoan Duran": 41109,
    "JJ Bleday": 42410,
    "JJ Wetherholt": 4941056,
    "Jo Adell": 40854,
    "Joc Pederson": 31392,
    "Joe Mack": 4872695,
    "Joe Musgrove": 34848,
    "Joe Ryan": 42450,
    "Joel Kuhnel": 40855,
    "Joey Cantillo": 42488,
    "Joey Ortiz": 42958,
    "Joey Wiemer": 4417134,
    "JoJo Romero": 40456,
    "Jonah Cox": 5145886,
    "Jonah Heim": 33842,
    "Jonah Tong": 5214984,
    "Jonathan Aranda": 40810,
    "Jonathan India": 41171,
    "Jonny DeLuca": 5005912,
    "Jordan Lawlar": 4872649,
    "Jordan Romano": 36380,
    "Jordan Walker": 4684778,
    "Jordan Westburg": 4298641,
    "Jorge Mateo": 33832,
    "Jorge Polanco": 32525,
    "Jorge Soler": 32558,
    "Jose Altuve": 31662,
    "Jose Alvarado": 36063,
    "Jose Berrios": 32811,
    "Jose Caballero": 42135,
    "Jose Fernandez": 5010500,
    "Jose Ferrer": 5119607,
    "Jose Ramirez": 32801,
    "Jose Soriano": 40973,
    "Jose Urquidy": 35759,
    "Josh Bell": 32517,
    "Josh Hader": 32760,
    "Josh Jung": 42437,
    "Josh Lowe": 40557,
    "Josh Naylor": 35066,
    "Josh Smith": 42884,
    "Joshua Baez": 4920835,
    "Joshua Kuroda-Grauer": 5023768,
    "Josue De Paula": 5102682,
    "JR Ritchie": 5080757,
    "Juan Morillo": 4722925,
    "Juan Soto": 36969,
    "Julio Rodriguez": 41044,
    "Jung Hoo Lee": 5134621,
    "Junior Caminero": 4905921,
    "Jurickson Profar": 31117,
    "Justin Crawford": 5080642,
    "Justin Martinez": 5116851,
    "Justin Steele": 41022,
    "Justin Verlander": 6341,
    "Justin Wrobleski": 4417203,
    "Kade Anderson": 5198748,
    "Kaelen Culpepper": 4935268,
    "Kai-Wei Teng": 42242,
    "Kazuma Okamoto": 5134636,
    "Keibert Ruiz": 38827,
    "Keider Montero": 5182933,
    "Kenley Jansen": 29630,
    "Kerry Carpenter": 42714,
    "Ketel Marte": 32512,
    "Kevin Gausman": 32667,
    "Kevin Ginkel": 41432,
    "Kevin Kelly": 5001153,
    "Kevin McGonigle": 5149072,
    "Kirby Yates": 32623,
    "Kodai Senga": 4142421,
    "Kody Clemens": 41311,
    "Konnor Griffin": 5218285,
    "Kris Bubic": 41201,
    "Kumar Rocker": 4414525,
    "Kyle Bradish": 4311625,
    "Kyle Finnegan": 36543,
    "Kyle Freeland": 33839,
    "Kyle Harrison": 4683375,
    "Kyle Isbel": 41263,
    "Kyle Karros": 5203102,
    "Kyle Leahy": 5006093,
    "Kyle Manzardo": 4917927,
    "Kyle Schwarber": 33712,
    "Kyle Stowers": 42796,
    "Kyle Teel": 4743772,
    "Kyle Tucker": 34967,
    "Lake Bachar": 42592,
    "Lance McCullers Jr.": 32764,
    "Landen Roupp": 4345404,
    "Lane Thomas": 36409,
    "Lars Nootbaar": 4448736,
    "Lawrence Butler": 4917919,
    "Lazaro Montes": 5124103,
    "Leo Bernal": 5124076,
    "Leo De Vries": 5196124,
    "Leody Taveras": 34951,
    "Liam Doyle": 5130533,
    "Liam Hicks": 4725251,
    "Logan Gilbert": 41221,
    "Logan Henderson": 4917878,
    "Logan O'Hoppe": 42047,
    "Logan Webb": 41216,
    "Louis Varland": 4917888,
    "Lourdes Gurriel Jr.": 36040,
    "Lucas Erceg": 36618,
    "Lucas Giolito": 32697,
    "Lucas Spence": 5273759,
    "Luis Arraez": 39572,
    "Luis Campusano": 40521,
    "Luis Castillo": 35124,
    "Luis Garcia Jr.": 40459,
    "Luis Gil": 40626,
    "Luis Lara": 5138536,
    "Luis Medina": 40949,
    "Luis Rengifo": 37237,
    "Luis Robert Jr.": 39631,
    "Luis Severino": 33263,
    "Luis Torrens": 33805,
    "Luisangel Acuna": 42411,
    "Luke Keaschall": 4977664,
    "Luke Raley": 40422,
    "Luke Weaver": 33770,
    "MacKenzie Gore": 39636,
    "Maikel Garcia": 4905884,
    "Manny Machado": 31097,
    "Marcell Ozuna": 31668,
    "Marcelo Mayer": 4872648,
    "Marcus Semien": 32146,
    "Mark Vientos": 41034,
    "Martin Perez": 31098,
    "Masataka Yoshida": 4872598,
    "Mason Fluharty": 4622501,
    "Mason Miller": 4730225,
    "Mason Montgomery": 4424112,
    "Masyn Winn": 4683365,
    "Matt Brash": 4894467,
    "Matt Chapman": 33857,
    "Matt McLain": 4422899,
    "Matt Olson": 32767,
    "Matt Shaw": 4867667,
    "Matt Strahm": 34862,
    "Matt Wilkinson": 5339226,
    "Matthew Boyd": 34401,
    "Matthew Liberatore": 41173,
    "Mauricio Dubon": 35304,
    "Max Clark": 5148964,
    "Max Fried": 32685,
    "Max Meyer": 4345164,
    "Max Muncy (ATH)": 4872686,
    "Max Muncy (LAD)": 33303,
    "Max Scherzer": 28976,
    "Merrill Kelly": 32968,
    "Michael Arroyo": 5124097,
    "Michael Busch": 42415,
    "Michael Conforto": 33711,
    "Michael Harris II": 42470,
    "Michael King": 40429,
    "Michael Massey": 4109223,
    "Michael McGreevy": 4424141,
    "Michael Petersen": 41824,
    "Michael Soroka": 34984,
    "Michael Wacha": 32640,
    "Mick Abel": 4718970,
    "Mickey Gasper": 5132012,
    "Mickey Moniak": 36181,
    "Miguel Amaya": 38905,
    "Miguel Andujar": 33743,
    "Miguel Rojas": 30791,
    "Miguel Ullola": 5124163,
    "Miguel Vargas": 42453,
    "Mike Burrows": 4918155,
    "Mike Sirota": 4956819,
    "Mike Trout": 30836,
    "Mike Yastrzemski": 33341,
    "Mitch Bratt": 5123768,
    "Mitch Keller": 33722,
    "Moises Ballesteros": 4987418,
    "Mookie Betts": 33039,
    "Munetaka Murakami": 4872595,
    "Nasim Nunez": 4728688,
    "Nate Lavender": 4424442,
    "Nate Pearson": 39646,
    "Nathan Church": 4843048,
    "Nathan Eovaldi": 31174,
    "Nathan Lukes": 35682,
    "Nathaniel Lowe": 40538,
    "Nick Fortes": 41674,
    "Nick Gonzales": 4311634,
    "Nick Kurtz": 4966637,
    "Nick Lodolo": 42433,
    "Nick Loftin": 4314013,
    "Nick Martinez": 33372,
    "Nick Pivetta": 36071,
    "Nick Sogard": 42979,
    "Nico Hoerner": 41219,
    "Noah Cameron": 4417208,
    "Noah Schultz": 5080754,
    "Noelvi Marte": 41307,
    "Nolan Arenado": 31261,
    "Nolan Gorman": 41174,
    "Nolan McLean": 4433874,
    "Nolan Schanuel": 4739755,
    "Oneil Cruz": 39712,
    "Orion Kerkering": 4630789,
    "Osleivis Basabe": 42474,
    "Oswald Peraza": 42479,
    "Otto Lopez": 41917,
    "Owen Caissie": 4917685,
    "Ozzie Albies": 33783,
    "Pablo Lopez": 39671,
    "Parker Messick": 4619898,
    "Patrick Bailey": 4345843,
    "Patrick Sandoval": 40975,
    "Paul Blackburn": 32776,
    "Paul Goldschmidt": 31027,
    "Paul Sewald": 35009,
    "Paul Skenes": 4719507,
    "Payton Tolle": 4966140,
    "Pedro Ramirez": 5012995,
    "Pete Alonso": 37498,
    "Pete Crow-Armstrong": 4717833,
    "Pete Fairbanks": 42180,
    "Peter Lambert": 39898,
    "Quinn Mathews": 4837405,
    "Quinn Priester": 42449,
    "Rafael Devers": 33859,
    "Rafael Flores Jr.": 5131743,
    "Rainiel Rodriguez": 5289250,
    "Raisel Iglesias": 33618,
    "Ralphy Velazquez": 5149073,
    "Ramon Laureano": 35142,
    "Randal Grichuk": 31399,
    "Randy Arozarena": 36488,
    "Randy Dobnak": 42214,
    "Randy Vasquez": 4722847,
    "Ranger Suarez": 39817,
    "Reid Detmers": 4326697,
    "Reynaldo Lopez": 33860,
    "Rhett Lowder": 4758873,
    "Rhys Hoskins": 35291,
    "Richie Palacios": 41359,
    "Rico Garcia": 41382,
    "Riley Greene": 42179,
    "Riley O'Brien": 41509,
    "River Ryan": 5007605,
    "Robbie Ray": 32175,
    "Robby Snelling": 5080753,
    "Robert Garcia": 5125167,
    "Robert Gasser": 4918251,
    "Robert Suarez": 4148749,
    "Roki Sasaki": 5134638,
    "Roman Anthony": 5080767,
    "Ronald Acuna Jr.": 36185,
    "Royce Lewis": 40635,
    "Ryan Gusto": 5131986,
    "Ryan Helsley": 39909,
    "Ryan Jeffers": 41587,
    "Ryan Johnson": 5007859,
    "Ryan McMahon": 33247,
    "Ryan O'Hearn": 35183,
    "Ryan Pepiot": 4208281,
    "Ryan Sloan": 5218293,
    "Ryan Waldschmidt": 5129344,
    "Ryan Walker": 5000950,
    "Ryan Watson": 5125911,
    "Ryan Weathers": 41178,
    "Ryan Zeferjahn": 4722057,
    "Ryne Nelson": 4916269,
    "Ryne Stanek": 33301,
    "Sal Frelick": 4417795,
    "Sal Stewart": 5080771,
    "Salvador Perez": 31127,
    "Sam Antonacci": 5207167,
    "Samad Taylor": 39710,
    "Samuel Basallo": 4917646,
    "Sandy Alcantara": 35241,
    "Sean Burke": 4867679,
    "Sean Manaea": 33244,
    "Sean Murphy": 33557,
    "Sean Newcomb": 33856,
    "Sebastian Walcott": 5150947,
    "Seiya Suzuki": 4142424,
    "Seranthony Dominguez": 37793,
    "Seth Hernandez": 5293137,
    "Seth Lugo": 34873,
    "Shane Baz": 39639,
    "Shane Bieber": 40912,
    "Shane Drohan": 4315203,
    "Shane McClanahan": 41199,
    "Shane Smith": 5201814,
    "Shea Langeliers": 42598,
    "Shohei Ohtani": 39832,
    "Shota Imanaga": 5134630,
    "Slade Cecconi": 41462,
    "Sonny Gray": 32082,
    "Spencer Arrighetti": 4726080,
    "Spencer Horwitz": 4228472,
    "Spencer Jones": 4867424,
    "Spencer Miles": 4833671,
    "Spencer Schwellenbach": 4424862,
    "Spencer Steer": 4722857,
    "Spencer Strider": 4307825,
    "Spencer Torkelson": 4424286,
    "Stephen Kolek": 5190073,
    "Steven Cruz": 5002931,
    "Steven Kwan": 41996,
    "Steven Matz": 33106,
    "Steven Okert": 33716,
    "Taj Bradley": 42480,
    "Tanner Bibee": 4345278,
    "Tanner Gordon": 4415658,
    "Tanner Scott": 35135,
    "Tarik Skubal": 42409,
    "Tatsuya Imai": 5330833,
    "Tayler Saucedo": 42683,
    "Taylor Clarke": 35277,
    "Taylor Ward": 34923,
    "Teoscar Hernandez": 33377,
    "Theo Gillen": 5218298,
    "Thomas Saggese": 4999876,
    "Thomas White": 5149065,
    "Tim Tawa": 4345192,
    "TJ Friedl": 36020,
    "TJ Rumfield": 5014349,
    "Tommy Edman": 39907,
    "Tommy White": 4923961,
    "Tomoyuki Sugano": 4142423,
    "Tony Santillan": 40950,
    "Travis Bazzana": 5007707,
    "Trea Turner": 33710,
    "Trent Grisham": 34995,
    "Trent Harris": 5201836,
    "Trevor Larnach": 41205,
    "Trevor McDonald": 5185136,
    "Trevor Megill": 40080,
    "Trevor Rogers": 39640,
    "Trevor Story": 32150,
    "Trey Yesavage": 4949041,
    "Tristan Peters": 5085893,
    "Triston Casas": 41180,
    "Troy Johnston": 4346111,
    "Troy Melton": 5294127,
    "Ty France": 35591,
    "Tyler Alexander": 40360,
    "Tyler Glasnow": 33190,
    "Tyler Holton": 3983833,
    "Tyler Mahle": 34973,
    "Tyler O'Neill": 34168,
    "Tyler Phillips": 41247,
    "Tyler Rogers": 34026,
    "Tyler Soderstrom": 4686066,
    "Tyler Stephenson": 34975,
    "Tyler Tolbert": 4151063,
    "Tyler Wells": 4717904,
    "Tyron Guerrero": 33654,
    "Tyrone Taylor": 32783,
    "Vaughn Grissom": 42503,
    "Victor Caratini": 33229,
    "Victor Mesa Jr.": 4917849,
    "Victor Scott II": 4807220,
    "Vinnie Pasquantino": 4109109,
    "Vladimir Guerrero Jr.": 35002,
    "Wade Meckler": 4424090,
    "Walbert Urena": 5197476,
    "Walker Buehler": 39251,
    "Walker Jenkins": 5148963,
    "Will Smith": 38309,
    "Will Vest": 41606,
    "Will Warren": 5132011,
    "Willi Castro": 34230,
    "William Contreras": 39895,
    "Willson Contreras": 32532,
    "Willy Adames": 33675,
    "Wilyer Abreu": 4990055,
    "Wyatt Langford": 4719324,
    "Xander Bogaerts": 31606,
    "Xavier Edwards": 41326,
    "Yainer Diaz": 4781491,
    "Yandy Diaz": 33481,
    "Yennier Cano": 35536,
    "Yoendrys Gomez": 42898,
    "Yohan Ramirez": 41893,
    "Yohandy Morales": 4683376,
    "Yordan Alvarez": 36018,
    "Yoshinobu Yamamoto": 4872587,
    "Yuki Matsui": 4142414,
    "Yusei Kikuchi": 41415,
    "Zac Gallen": 39910,
    "Zac Thornton": 5129576,
    "Zac Veen": 4717903,
    "Zach McKinstry": 38420,
    "Zach Neto": 4666100,
    "Zack Gelof": 4414531,
    "Zack Littell": 36052,
    "Zack Wheeler": 31267,
    "Zebby Matthews": 4791597,
    "Zyhir Hope": 5204650,
}
# END PLAYERS

# ---------------------------------------------------------------- colour

def _rgb(h):
    h = h.replace("#", "")
    if len(h) != 6:
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
    # LEDs crush dark colours (navy reads as black): raise brightness, keep hue
    m = max(rgb[0], rgb[1], rgb[2], 1)
    if m >= floor:
        return rgb
    if m < 40:
        return (96, 96, 96)               # black kit: charcoal still lights up
    return _scale(rgb, floor * 1.0 / m)

def _dist(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])

def palette(primary, secondary):
    p = _lift(_rgb(primary), 150)
    s = _lift(_rgb(secondary), 150)
    if _dist(p, s) < 90:
        s = (235, 235, 235)
    # numeral: secondary if it stands out from the shirt, else white or black
    if abs(_lum(s) - _lum(p)) > 0.25:
        n = s
    elif _lum(p) < 0.6:
        n = (255, 255, 255)
    else:
        n = (20, 20, 20)
    light = (p[0] + (255 - p[0]) * 0.35, p[1] + (255 - p[1]) * 0.35, p[2] + (255 - p[2]) * 0.35)
    return {
        "P": _hex(p),
        "D": _hex(_scale(p, 0.6)),
        "L": _hex(light),
        "S": _hex(s),
        "W": "#F0F0F0",
        "M": "#B8B8B8",
        "E": "#262626",
        "G": "#6E6E6E",
        "N": _hex(n),
        "K": "#000000",
    }

def accent(primary, secondary):
    """Team colour for text on black: the trim if it reads on an LED, else the primary."""
    for h in (secondary, primary):
        rgb = _rgb(h)
        if _lum(rgb) >= 0.33 and _dist(rgb, (255, 255, 255)) > 40:
            return _hex(rgb)
    return _hex(_lift(_rgb(primary), 200))

# ---------------------------------------------------------------- compose

def stamp_number(art, digits, number, cx, top):
    """Return art rows with the number drawn in N and a 1px black outline (K)."""
    g = [[row[i] for i in range(len(row))] for row in art]
    h, w = len(g), len(g[0])
    num = number[:2]
    if not num:
        return art
    gw = len(digits["0"][0])
    gh = len(digits["0"])
    total = len(num) * gw + (len(num) - 1)
    x0 = cx - total // 2
    lit = {}
    for i in range(len(num)):
        glyph = digits.get(num[i])
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
                if 0 <= ax and ax < w and 0 <= ay and ay < h and not lit.get((ax, ay)) and g[ay][ax] != ".":
                    g[ay][ax] = "K"
    for (x, y) in lit:
        if 0 <= x and x < w and 0 <= y and y < h:
            g[y][x] = "N"
    return ["".join(r) for r in g]

def draw_gear(c, sport, number, primary, secondary, logo = ""):
    spec = SPORTS[sport]
    art = stamp_number(spec["art"], spec["digits"], number, spec["cx"], spec["top"])
    c.sprite(art, spec["x"], spec["y"], legend = palette(primary, secondary))
    if not number and logo and sport != "nfl":
        # no number yet (just signed / traded): the team crest on the chest instead
        lw, lh = LOGO_SIZE.get(logo, (LOGO_BOX, LOGO_BOX))
        lx, ly = spec["x"] + spec["cx"] - lw // 2, spec["y"] + spec["top"] - 1
        # shirt's own dark shade behind the crest so a red logo still shows on a red shirt
        c.rect(lx - 1, ly - 1, lx + lw, ly + lh, fill = palette(primary, secondary)["D"])
        c.image(LOGOS[logo], lx, ly)

# ---------------------------------------------------------------- layout

def meta_line(c, x, y, team, pos, feet, inches, lbs, color, inj = None):
    """TEAM . POS . 6'11" . 284 LB, with the foot/inch marks drawn as pixels.
    An injured player gets POS . IR . ANKLE instead of height and weight."""
    f = "4x5"
    gap = "#5A5A5A"
    def sep(x):
        c.pixel(x + 2, y + 3, gap)
        return x + 6
    if team:
        c.text(team, x, y, font = f, color = color)
        x = sep(x + c.text_width(team, f))
    c.text(pos, x, y, font = f, color = color)
    x = sep(x + c.text_width(pos, f))
    if inj:
        c.text(inj["tag"], x, y, font = f, color = inj["color"])
        if inj["part"]:
            x = sep(x + c.text_width(inj["tag"], f))
            c.text(inj["part"], x, y, font = f, color = "white")
        return
    if feet:
        c.text(feet, x, y, font = f, color = "white")
        x += c.text_width(feet, f) + 1
        c.vline(x, y + 1, 2, "white")
        x += 2
        c.text(inches, x, y, font = f, color = "white")
        x += c.text_width(inches, f) + 1
        c.vline(x, y + 1, 2, "white")
        c.vline(x + 2, y + 1, 2, "white")
        x = sep(x + 3)
    if lbs:
        c.text(lbs, x, y, font = f, color = "white")
        x += c.text_width(lbs, f) + 2
        c.text("LB", x, y, font = f, color = "gray")

def stat_block(c, x, y, stats, tag, tag_color, accent, hero_color = "white"):
    """Hero stat big with a stacked tag/label beside it; two more stacked small."""
    hv, hl = stats[0]
    side = stats[1:3]
    vw, lw = 0, 0
    for (v, l) in side:
        vw = max(vw, c.text_width(v, "4x5"))
        lw = max(lw, c.text_width(l, "4x5"))
    tw = max(c.text_width(tag, "4x5"), c.text_width(hl, "4x5"))
    # a wide hero (.907, 4,183) drops to the smaller big font so the side column still fits
    hf = "9x12"
    if x + c.text_width(hv, hf) + 2 + tw + 6 > 127 - vw - 3 - lw:
        hf = "7x12"
    c.text(hv, x, y, font = hf, color = hero_color)
    hx = x + c.text_width(hv, hf) + 2
    c.text(tag, hx, y + 1, font = "4x5", color = tag_color)
    c.text(hl, hx, y + 7, font = "4x5", color = accent)
    # side column sits right of the hero, pushed against the right edge if needed
    tag_end = hx + tw
    rx = max(tag_end + 7, 96)
    rx = min(rx, 127 - vw - 3 - lw)
    if rx < tag_end + 6:
        return                                  # still no room (long injury tag): the hero says enough
    c.vline(rx - 4, y + 2, 9, "#3A3A3A")
    # values right-aligned in one column, labels lined up after them
    for i in range(len(side)):
        v, l = side[i]
        yy = y + i * 6
        c.text(v, rx + vw - c.text_width(v, "4x5"), yy, font = "4x5", color = "white")
        c.text(l, rx + vw + 3, yy, font = "4x5", color = "gray")

LOGO_BOX = 19

# ESPN's game feeds sometimes use a different abbreviation from its team pages (UTA vs UTAH)
LOGO_ALIAS = {
    "nhl_uta": "nhl_utah", "nba_uta": "nba_utah", "nba_gsw": "nba_gs", "nba_nyk": "nba_ny",
    "nba_sas": "nba_sa", "nba_nop": "nba_no", "nba_was": "nba_wsh", "nba_pho": "nba_phx",
    "nfl_was": "nfl_wsh", "nfl_jac": "nfl_jax", "nfl_lvr": "nfl_lv", "nhl_tbl": "nhl_tb",
    "nhl_sjs": "nhl_sj", "nhl_njd": "nhl_nj", "nhl_lak": "nhl_la", "nhl_vgs": "nhl_vgk",
    "nhl_mon": "nhl_mtl", "nhl_wsh": "nhl_wsh", "mlb_cws": "mlb_chw", "mlb_oak": "mlb_ath",
    "mlb_was": "mlb_wsh", "mlb_az": "mlb_ari", "mlb_tbr": "mlb_tb", "mlb_kcr": "mlb_kc",
    "mlb_sdp": "mlb_sd", "mlb_sfg": "mlb_sf",
}

def logo_key(lg, abbr):
    k = lg + "_" + (abbr or "").lower()
    k = LOGO_ALIAS.get(k, k)
    return k if k in LOGOS else ""

def name_and_logo(c, x, last, logo, prefix, fallback = ""):
    """Name top-left; team logo centred in a 19px-tall box top-right, optionally led by @ / VS.
    Returns the x where the logo column starts, so the line below can stop short of it."""
    col = 128 - LOGO_BOX
    if logo:
        lw, lh = LOGO_SIZE.get(logo, (LOGO_BOX, LOGO_BOX))
        box = max(LOGO_BOX, lw)               # wide marks (SEA, LAC, NE) get up to 26px
        col = 128 - box
        c.image(LOGOS[logo], col + (box - lw) // 2, (LOGO_BOX - lh) // 2)
    elif fallback:
        # no logo for this team: its abbreviation, so the opponent is never blank
        fw = c.text_width(fallback, "6x8")
        c.text(fallback, 128 - LOGO_BOX + (LOGO_BOX - fw) // 2, 2, font = "6x8", color = "white")
        col = min(col, 128 - fw - 1)
    right = col
    if prefix:
        pw = c.text_width(prefix, "4x5")
        right = col - pw - 2
        c.text(prefix, right, 4, font = "4x5", color = "gray")
    room = right - 3 - x
    # GILGEOUS-ALEXANDER won't fit even small: fall back to the last part, then trim
    if c.text_width(last, "4x5") > room and "-" in last:
        last = last.split("-")[-1]
    for _ in range(len(last)):
        if c.text_width(last, "4x5") <= room:
            break
        last = last[:-1]
    font = "7x12"
    if c.text_width(last, font) > room:
        font = "6x8"
    if c.text_width(last, font) > room:
        font = "4x5"
    c.text(last, x, {"7x12": -1, "6x8": 2, "4x5": 4}[font], font = font, color = "white")
    return col

def game_width(c, parts):
    w = 6 * (len(parts) - 1)
    for (t, _) in parts:
        w += c.text_width(t, "4x5")
    return w

def game_line(c, x, y, parts, stop):
    """Short facts separated by dim dots, never running past `stop`."""
    for i in range(len(parts)):
        txt, col = parts[i]
        gap = 6 if i else 0
        if x + gap + c.text_width(txt, "4x5") > stop:
            return
        if i:
            c.pixel(x + 2, y + 3, "#5A5A5A")
        x += gap
        c.text(txt, x, y, font = "4x5", color = col)
        x += c.text_width(txt, "4x5")

def result(me, opp, ac):
    """W / L / T and the winner's score first, the way ESPN writes a result: L 24-20, never 20-24."""
    a, b = me.get("score") or "0", opp.get("score") or "0"
    if not (a.isdigit() and b.isdigit()):
        return [("%s-%s" % (a, b), ac)]
    x, y = int(a), int(b)
    if x == y:
        return [("T", "gray"), ("%d-%d" % (x, y), ac)]
    return [("W", "green") if x > y else ("L", "red"), ("%d-%d" % (max(x, y), min(x, y)), ac)]

# ---------------------------------------------------------------- ESPN data

LEAGUE = "mlb"
DEFAULT_PLAYER = "Shohei Ohtani"
SPORT_PATH = {"nfl": "football/nfl", "nba": "basketball/nba", "nhl": "hockey/nhl", "mlb": "baseball/mlb"}
CORE_SPORT = {"nfl": "football", "nba": "basketball", "nhl": "hockey", "mlb": "baseball"}
FANTASY_GAME = {"nfl": "ffl", "nba": "fba", "nhl": "fhl", "mlb": "flb"}

# Panel fonts are plain A-Z: fold accented letters (JOKIC, DONCIC, STUTZLE).
FOLD = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A", "Ā": "A", "Ă": "A", "Ą": "A",
    "Ç": "C", "Č": "C", "Ć": "C", "Ď": "D", "Đ": "D",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E", "Ě": "E", "Ę": "E", "Ē": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I", "Ī": "I", "Ľ": "L", "Ł": "L", "Ĺ": "L",
    "Ñ": "N", "Ň": "N", "Ń": "N", "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O", "Ø": "O", "Ő": "O",
    "Ř": "R", "Ŕ": "R", "Š": "S", "Ś": "S", "Ş": "S", "Ș": "S", "Ť": "T", "Ţ": "T", "Ț": "T",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U", "Ů": "U", "Ű": "U", "Ū": "U",
    "Ý": "Y", "Ÿ": "Y", "Ž": "Z", "Ź": "Z", "Ż": "Z", "ß": "SS", "Æ": "AE", "Œ": "OE",
}

def plain(s):
    out = ""
    for ch in (s or "").upper().elems():
        out += FOLD.get(ch, ch)
    return "".join([ch for ch in out.elems() if ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .'-%/:"]).strip()

def get_json(url, ttl, headers = None):
    resp = http.get(url, headers = headers or {}, ttl_seconds = ttl)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def athlete(lg, pid):
    """Name, number, team colours and bio for one player."""
    d = get_json("https://site.web.api.espn.com/apis/common/v3/sports/%s/athletes/%d" % (SPORT_PATH[lg], pid), 21600)
    if not d or not d.get("athlete"):
        return None
    a = d["athlete"]
    team = a.get("team") or {}
    ft, inch = "", ""
    h = a.get("displayHeight") or ""           # 6' 2"
    if "'" in h:
        ft = h.split("'")[0].strip()
        inch = h.split("'")[1].replace('"', "").strip()
    lbs = (a.get("displayWeight") or "").split(" ")[0]
    summary = {}
    for st in (a.get("statsSummary") or {}).get("statistics") or []:
        summary[st.get("name")] = st.get("displayValue")
    abbr = (team.get("abbreviation") or "").lower()
    # "2025-26 regular season stats" / "2026 regular season stats": which season the numbers are from
    szn = ((a.get("statsSummary") or {}).get("displayName") or "").split(" ")[0]
    return {
        "lg": lg,
        "id": pid,
        "last": plain(a.get("lastName") or a.get("displayName")),
        "num": "".join([ch for ch in (a.get("jersey") or "").elems() if ch.isdigit()]),
        "pos": plain((a.get("position") or {}).get("abbreviation") or ""),
        "ft": ft,
        "in": inch,
        "lbs": lbs,
        "team_id": team.get("id"),
        "team": plain(team.get("abbreviation") or ""),
        "logo": logo_key(lg, abbr),
        "color": team.get("color") or "8A8A8A",
        "alt": team.get("alternateColor") or "F0F0F0",
        "summary": summary,
        "szn": szn,
        "inj": injury(a.get("injuries")),
    }

# ESPN injury type -> (panel tag, keeps them out of the game)
INJ = {
    "INJURY_STATUS_IR": ("IR", True), "INJURY_STATUS_OUT": ("OUT", True),
    "INJURY_STATUS_60DAYIL": ("IL60", True), "INJURY_STATUS_15DAYIL": ("IL15", True),
    "INJURY_STATUS_10DAYIL": ("IL10", True), "INJURY_STATUS_7DAYIL": ("IL7", True),
    "INJURY_STATUS_SUSPENSION": ("SUSP", True), "INJURY_STATUS_PATERNITY": ("LEAVE", True),
    "INJURY_STATUS_DOUBTFUL": ("DOUBT", False), "INJURY_STATUS_QUESTIONABLE": ("QUES", False),
    "INJURY_STATUS_DAYTODAY": ("DTD", False),
}

def injury(injuries):
    """The player's current injury designation, or None when healthy."""
    for j in injuries or []:
        t = (j.get("type") or {}).get("name") or ""
        if t == "INJURY_STATUS_ACTIVE":
            continue
        tag, out = INJ.get(t, (plain((j.get("type") or {}).get("abbreviation") or ""), False))
        if not tag:
            continue
        d = j.get("details") or {}
        part = plain(d.get("type") or "")
        if len(part) > 7 or part in ("OTHER", "ILLNESS"):
            part = "" if part != "ILLNESS" else "ILL"
        back = ""
        rd = d.get("returnDate") or ""
        if len(rd) >= 10:
            back = "%d/%d" % (int(rd[5:7]), int(rd[8:10]))
        return {"tag": tag, "out": out, "part": part, "back": back, "color": "red" if out else "amber"}
    return None

def overview(lg, pid):
    return get_json("https://site.web.api.espn.com/apis/common/v3/sports/%s/athletes/%d/overview" % (SPORT_PATH[lg], pid), 240)

# ---------------------------------------------------------------- numbers

def num(v):
    if v == None:
        return None
    if type(v) == "string":
        v = v.replace(",", "")
        if v in ("", "-", "--"):
            return None
    return float(v)

def short(v):
    """244 / 29.6 / 1.8 style values for a 4-6 character slot."""
    if v == None:
        return "-"
    if v >= 1000:
        return fmt.commas(int(v + 0.5))
    if v >= 100:
        return str(int(v + 0.5))
    r = int(v * 10 + 0.5)
    return str(r // 10) + "." + str(r % 10)

def whole(v):
    return "-" if v == None else fmt.commas(int(v + 0.5))

def avg3(h, ab):
    """Batting average as .282"""
    if not ab:
        return "-"
    r = int(h * 1000.0 / ab + 0.5)
    if r >= 1000:
        return "1.000"
    return "." + fmt.pad(r, 3)

def ip_outs(ip):
    """127.1 innings -> outs (the .1 / .2 are thirds)."""
    if ip == None:
        return 0
    w = int(ip)
    return w * 3 + int((ip - w) * 10 + 0.5)

def era(er, outs):
    if not outs:
        return "-"
    r = int(er * 2700.0 / outs + 0.5)
    return str(r // 100) + "." + fmt.pad(r % 100)

def kind(lg, pos, names):
    """Which stat set fits this player."""
    if lg == "nfl":
        if pos == "QB":
            return "qb"
        if pos in ("RB", "FB"):
            return "rb"
        if pos in ("WR", "TE"):
            return "wr"
        if pos in ("K", "PK"):
            return "k"
        return "def"
    if lg == "nhl":
        return "g" if pos == "G" else "sk"
    if lg == "mlb":
        return "p" if pos in ("SP", "RP", "P") else "bat"
    return "nba"

def season_stats(ov, p):
    """Three (value, label) pairs from the overview's Regular Season split."""
    st = (ov or {}).get("statistics") or {}
    names = st.get("names") or []
    split = None
    for sp in st.get("splits") or []:
        if sp.get("displayName") == "Regular Season":
            split = sp
    v = {}
    vals = []
    if split != None and names:
        vals = split.get("stats") or []
        for i in range(min(len(names), len(vals))):
            if names[i] not in v:
                v[names[i]] = vals[i]
    elif p.get("summary"):
        v = p["summary"]                       # "2026 season stats" from the athlete call
        names = list(v.keys())
    else:
        return None
    k = kind(p["lg"], p["pos"], names)
    def f(name):
        return short(num(v.get(name)))
    def w(name):
        return whole(num(v.get(name)))
    if k == "nba":
        return [(f("avgPoints"), "PTS"), (f("avgRebounds"), "REB"), (f("avgAssists"), "AST")]
    if k == "qb":
        return [(w("passingYards"), "YDS"), (w("passingTouchdowns"), "TD"), (w("interceptions"), "INT")]
    if k == "rb":
        return [(w("rushingYards"), "YDS"), (w("rushingAttempts"), "CAR"), (w("rushingTouchdowns"), "TD")]
    if k == "wr":
        return [(w("receivingYards"), "YDS"), (w("receptions"), "REC"), (w("receivingTouchdowns"), "TD")]
    if k == "k":
        return [(w("totalKickingPoints"), "PTS"), (v.get("fieldGoalsMade-fieldGoalAttempts") or "-", "FG"), (w("longFieldGoalMade"), "LNG")]
    if k == "sk":
        return [(w("points"), "PTS"), (w("goals"), "G"), (w("assists"), "A")]
    if k == "g":
        return [(v.get("savePct") or "-", "SV%"), (v.get("avgGoalsAgainst") or "-", "GAA"), (w("wins"), "W")]
    if k == "bat":
        ba = v.get("avg") or avg3(num(v.get("hits")) or 0, num(v.get("atBats")) or 0)
        return [(w("homeRuns"), "HR"), (ba, "AVG"), (w("RBIs"), "RBI")]
    if k == "p":
        if v.get("innings") == None and v.get("ERA"):
            # athlete summary fallback (no Regular Season split): ERA, K, WHIP
            return [(v["ERA"], "ERA"), (w("strikeouts"), "K"), (v.get("WHIP") or "-", "WHIP")]
        outs = ip_outs(num(v.get("innings")))
        return [(era(num(v.get("earnedRuns")) or 0, outs), "ERA"), (w("strikeouts"), "K"), (v.get("innings") or "-", "IP")]
    # defenders and anyone else: the first three stats ESPN lists, with its own labels
    if not vals:
        return None
    labels = st.get("labels") or names
    return [(vals[i], plain(labels[i])[:4]) for i in range(min(3, len(vals)))]

def next_event(ov, now_unix):
    ng = (ov or {}).get("nextGame") or {}
    evs = (ng.get("league") or {}).get("events") or []
    if not evs:
        return None
    ev = evs[0]
    t = parse_iso(ev.get("date"))
    state = ((ev.get("fullStatus") or {}).get("type") or {}).get("state") or ev.get("status")
    if state == "post" and t != None and now_unix - t > 18 * 3600:
        return None
    return ev

def ev_state(ev):
    return ((ev.get("fullStatus") or {}).get("type") or {}).get("state") or ev.get("status")

def sched_event(e):
    """A team-schedule event reshaped like the overview's nextGame event, so the game page draws either."""
    comp = (e.get("competitions") or [{}])[0]
    teams = []
    for t in comp.get("competitors") or []:
        sc = t.get("score")
        teams.append({
            "id": t.get("id"),
            "abbreviation": (t.get("team") or {}).get("abbreviation"),
            "homeAway": t.get("homeAway"),
            "score": sc.get("displayValue") if type(sc) == "dict" else sc,
        })
    return {
        "id": e.get("id"),
        "date": e.get("date"),
        "timeValid": e.get("timeValid", True),
        "season": (e.get("season") or {}).get("year"),
        "seasonType": (e.get("seasonType") or {}).get("type"),
        "week": (e.get("week") or {}).get("number"),
        "competitors": teams,
        "fullStatus": {"type": (comp.get("status") or {}).get("type") or {}},
    }

def team_games(p):
    """(last finished game, next unplayed game) from the team schedule. The overview's nextGame
    keeps pointing at the last game for days after it ends (a whole bye week in the NFL), so this
    is where the real next game comes from."""
    d = get_json("https://site.api.espn.com/apis/site/v2/sports/%s/teams/%s/schedule" % (SPORT_PATH[p["lg"]], p["team_id"]), 3600)
    last, nxt, lt, nt = None, None, None, None
    for e in (d or {}).get("events") or []:
        ev = sched_event(e)
        t = parse_iso(ev["date"])
        st = ev["fullStatus"]["type"]
        if t == None:
            continue
        if st.get("state") == "post" and st.get("completed") and (lt == None or t > lt):
            last, lt = ev, t
        elif st.get("state") == "pre" and (nt == None or t < nt):
            nxt, nt = ev, t
    return last, nxt

def et_day(unix):
    return (unix + et_offset(unix) * 3600) // 86400

def game_to_show(p, ov, now_unix):
    """The game page's game: the live one; else the last result for 2 days after the final (18h if
    the next game is today or tomorrow), then the next game with its projection."""
    ev = None
    evs = (((ov or {}).get("nextGame") or {}).get("league") or {}).get("events") or []
    if evs:
        ev = evs[0]
    if ev and ev_state(ev) == "in":
        return ev
    if not p["team_id"]:
        return next_event(ov, now_unix)
    last, nxt = team_games(p)
    lt = parse_iso(last["date"]) if last else None
    et = parse_iso(ev.get("date")) if ev else None
    if ev and ev_state(ev) == "post" and et != None and (lt == None or et >= lt):
        last, lt = ev, et                       # the overview hears about a final before the cached schedule
    if ev and ev_state(ev) == "pre":
        nxt = ev
    nt = parse_iso(nxt.get("date")) if nxt else None
    if last and now_unix - lt < 18 * 3600:
        return last
    if nxt and nt != None and et_day(nt) - et_day(now_unix) <= 1:
        return nxt
    if last and now_unix - lt < 2 * 86400:
        return last                             # just played: the most recent result
    if nxt:
        return nxt                              # then on to the next game and its projection
    if last and now_unix - lt < 3 * 86400:
        return last
    return None

def live_stats(p, ev):
    """This player's line in the current game (ESPN core API, ~20 KB)."""
    eid = ev.get("id")
    url = ("https://sports.core.api.espn.com/v2/sports/%s/leagues/%s/events/%s/competitions/%s/competitors/%s/roster/%d/statistics/0"
           % (CORE_SPORT[p["lg"]], p["lg"], eid, eid, p["team_id"], p["id"]))
    d = get_json(url, 60)
    if d == None:
        # not on tonight's game roster (scratched, injured, backup goalie)
        labs = LIVE_LABELS.get(kind(p["lg"], p["pos"], []), ["", "", ""])
        why = p["inj"]["tag"] if p["inj"] and p["inj"]["out"] else "DNP"
        return [(why, "")] + [("-", lab) for lab in labs[1:]]
    v = {}
    for cat in ((d or {}).get("splits") or {}).get("categories") or []:
        for s in cat.get("stats") or []:
            if s.get("name") not in v:
                v[s["name"]] = s.get("value")
    k = kind(p["lg"], p["pos"], v)
    def f(name):
        x = v.get(name)
        return "0" if x == None else str(int(x))
    if k == "nba":
        return [(f("points"), "PTS"), (f("rebounds"), "REB"), (f("assists"), "AST")]
    if k == "qb":
        return [(f("passingYards"), "YDS"), (f("passingTouchdowns"), "TD"), (f("interceptions"), "INT")]
    if k == "rb":
        return [(f("rushingYards"), "YDS"), (f("rushingAttempts"), "CAR"), (f("rushingTouchdowns"), "TD")]
    if k == "wr":
        return [(f("receivingYards"), "YDS"), (f("receptions"), "REC"), (f("receivingTouchdowns"), "TD")]
    if k == "k":
        return [(f("totalKickingPoints"), "PTS"), (f("fieldGoalsMade") + "/" + f("fieldGoalAttempts"), "FG"), (f("extraPointsMade"), "XP")]
    if k == "sk":
        return [(f("points"), "PTS"), (f("goals"), "G"), (f("assists"), "A")]
    if k == "g":
        return [(f("saves"), "SV"), (f("goalsAgainst"), "GA"), (f("shotsAgainst"), "SA")]
    if k == "bat":
        return [(f("hits") + "-" + f("atBats"), "H-AB"), (f("homeRuns"), "HR"), (f("RBIs"), "RBI")]
    if k == "p":
        return [(f("strikeouts"), "K"), (short(num(v.get("innings"))), "IP"), (f("earnedRuns"), "ER")]
    return [(f("totalTackles"), "TKL"), (f("sacks"), "SACK"), (f("interceptions"), "INT")]

LIVE_LABELS = {
    "nba": ["PTS", "REB", "AST"], "qb": ["YDS", "TD", "INT"], "rb": ["YDS", "CAR", "TD"],
    "wr": ["YDS", "REC", "TD"], "k": ["PTS", "FG", "XP"], "sk": ["PTS", "G", "A"],
    "g": ["SV", "GA", "SA"], "bat": ["H-AB", "HR", "RBI"], "p": ["K", "IP", "ER"], "def": ["TKL", "SACK", "INT"],
}

def per_game(x, gp, i):
    return short((x.get(str(i)) or 0) / gp)

def projection(p, ev):
    """Next-game projection from ESPN fantasy: a real per-game projection for the NFL,
    season projection / projected games everywhere else."""
    season = ev.get("season")
    if not season:
        return None
    url = ("https://lm-api-reads.fantasy.espn.com/apis/v3/games/%s/seasons/%d/segments/0/leaguedefaults/3?view=kona_player_info"
           % (FANTASY_GAME[p["lg"]], season))
    filt = '{"players":{"filterIds":{"value":[%d]}}}' % p["id"]
    d = get_json(url, 21600, {"x-fantasy-filter": filt})
    players = (d or {}).get("players") or []
    if not players:
        return None
    stats = (players[0].get("player") or {}).get("stats") or []
    k = kind(p["lg"], p["pos"], [])
    for s in stats:
        if s.get("statSourceId") != 1 or s.get("seasonId") != season:
            continue
        x = s.get("stats") or {}
        if p["lg"] == "nfl":
            if s.get("statSplitTypeId") != 1 or s.get("scoringPeriodId") != ev.get("week"):
                continue
            if k == "qb":
                return [(short(x.get("3")), "YDS"), (short(x.get("4")), "TD"), (short(x.get("20")), "INT")]
            if k == "rb":
                return [(short(x.get("24")), "YDS"), (short(x.get("23")), "CAR"), (short(x.get("25")), "TD")]
            if k == "wr":
                return [(short(x.get("42")), "YDS"), (short(x.get("53")), "REC"), (short(x.get("43")), "TD")]
            return None
        if s.get("statSplitTypeId") != 0:
            continue
        if p["lg"] == "nba" and x.get("42"):
            return [(per_game(x, x["42"], 0), "PTS"), (per_game(x, x["42"], 6), "REB"), (per_game(x, x["42"], 3), "AST")]
        if p["lg"] == "nhl" and k == "sk" and x.get("30"):
            return [(per_game(x, x["30"], 16), "PTS"), (per_game(x, x["30"], 13), "G"), (per_game(x, x["30"], 14), "A")]
        if p["lg"] == "mlb" and k == "bat" and x.get("81"):
            return [(per_game(x, x["81"], 1), "H"), (per_game(x, x["81"], 5), "HR"), (per_game(x, x["81"], 21), "RBI")]
        if p["lg"] == "mlb" and k == "p" and (x.get("33") or x.get("32")):
            gs = x.get("33") or x.get("32")
            return [(short((x.get("48") or 0) / gs), "K"), (short(x.get("47")), "ERA"), (short((x.get("34") or 0) / 3.0 / gs), "IP")]
        return None
    return None

# ---------------------------------------------------------------- time (US Eastern)

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era_ = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era_ * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era_ * 146097 + doe - 719468

def civil_from_days(z):
    z += 719468
    era_ = (z if z >= 0 else z - 146096) // 146097
    doe = z - era_ * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return (yoe + era_ * 400 + (1 if m <= 2 else 0), m, d)

def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    dow = (first + 4) % 7                     # 0 = Sunday
    return first + (7 - dow) % 7 + 7 * (n - 1)

def et_offset(unix):
    """-4 hours in US daylight time (2nd Sun of March to 1st Sun of November), else -5."""
    y = civil_from_days(unix // 86400)[0]
    start = nth_sunday(y, 3, 2) * 86400 + 7 * 3600
    end = nth_sunday(y, 11, 1) * 86400 + 6 * 3600
    return -4 if start <= unix and unix < end else -5

def parse_iso(s):
    """'2026-10-04T20:25:00.000+00:00' or '2026-10-04T20:25Z' (UTC) -> unix seconds."""
    if not s or len(s) < 16:
        return None
    return (days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10])) * 86400
            + int(s[11:13]) * 3600 + int(s[14:16]) * 60)

def when_et(iso, now_unix, time_valid):
    """('TODAY' | 'TMRW' | '10/5', '8:15PM ET')"""
    t = parse_iso(iso)
    if t == None:
        return ("", "")
    local = t + et_offset(t) * 3600
    today = (now_unix + et_offset(now_unix) * 3600) // 86400
    day = local // 86400
    y, m, d = civil_from_days(day)
    label = "TODAY" if day == today else ("TMRW" if day == today + 1 else "%d/%d" % (m, d))
    if not time_valid:
        return (label, "TBD")
    mins = (local % 86400) // 60
    h, mi = mins // 60, mins % 60
    ap = "AM" if h < 12 else "PM"
    h = h % 12
    if h == 0:
        h = 12
    return (label, "%d:%s%s ET" % (h, fmt.pad(mi), ap))

# ---------------------------------------------------------------- pages

NO_STATS = [("-", ""), ("-", ""), ("-", "")]

def szn_tag(p, ev):
    """SZN while the stats are this season's; 25-26 / 2025 while ESPN still shows last season."""
    y = p.get("szn") or ""
    if not ev or not ev.get("season") or len(y) < 4 or not y[0:4].isdigit():
        return "SZN"
    end = int(y[0:4]) + (1 if len(y) == 7 else 0)   # 2025-26 ends in 2026
    if ev["season"] <= end:
        return "SZN"
    return y[2:] if len(y) == 7 else y

def out_block(p, szn):
    """Hero slot for a player who will not play: IR / OUT / IL15, the injury, and when he is due back."""
    inj = p["inj"]
    return [(inj["tag"], inj["part"] or "INJ")] + szn[1:3], ("BACK " + inj["back"]) if inj["back"] else "OUT"

def message(c, line1, line2, color):
    """Two short lines, what happened and what to do, beside a grey jersey."""
    c.clear()
    draw_gear(c, LEAGUE, "", "4A4A4A", "8A8A8A")
    c.text(line1, 35, 7, font = "6x8", color = color)
    c.text(line2, 35, 19, font = "4x5", color = "gray")

def pick_player(ctx):
    label = ctx.inputs.get("player", DEFAULT_PLAYER) or DEFAULT_PLAYER
    pid = PLAYERS.get(label)
    if pid == None:
        return None, "unknown"
    p = athlete(LEAGUE, pid)
    if p == None:
        return None, "offline"
    return p, ""

def failed(c, why):
    if why == "unknown":
        message(c, "NO PLAYER", "PICK ONE IN SETTINGS", "amber")
    else:
        message(c, "ESPN OFFLINE", "RETRYING SOON", "red")

def season(c, ctx):
    p, why = pick_player(ctx)
    if p == None:
        failed(c, why)
        return
    ov = overview(p["lg"], p["id"])
    stats = season_stats(ov, p) or NO_STATS
    c.clear()
    draw_gear(c, p["lg"], p["num"], p["color"], p["alt"], p["logo"])
    name_and_logo(c, 35, p["last"], p["logo"], "")
    ac = accent(p["color"], p["alt"])
    # the logo names the team, so the bio line starts at the position
    meta_line(c, 35, 12, "" if p["logo"] else p["team"], p["pos"], p["ft"], p["in"], p["lbs"], ac, p["inj"])
    stat_block(c, 35, 19, stats, szn_tag(p, next_event(ov, ctx.now.unix)), "gray", ac)

def game(c, ctx):
    p, why = pick_player(ctx)
    if p == None:
        failed(c, why)
        return
    ov = overview(p["lg"], p["id"])
    ev = game_to_show(p, ov, ctx.now.unix)
    ac = accent(p["color"], p["alt"])
    c.clear()
    draw_gear(c, p["lg"], p["num"], p["color"], p["alt"], p["logo"])
    if ev == None:
        # offseason, nothing on the schedule and no recent result: say so and keep the season line
        stop = name_and_logo(c, 35, p["last"], p["logo"], "") - 3
        game_line(c, 35, 12, [("NO NEXT GAME", "gray")], stop)
        stat_block(c, 35, 19, season_stats(ov, p) or NO_STATS, szn_tag(p, None), "gray", ac)
        return
    me, opp = {}, {}
    for comp in ev.get("competitors") or []:
        if str(comp.get("id")) == str(p["team_id"]):
            me = comp
        else:
            opp = comp
    stop = name_and_logo(c, 35, p["last"], logo_key(p["lg"], opp.get("abbreviation")),
                         "@" if me.get("homeAway") == "away" else "VS", plain(opp.get("abbreviation") or "")) - 3
    status = (ev.get("fullStatus") or {}).get("type") or {}
    state = status.get("state") or ev.get("status")
    score = "%s-%s" % (me.get("score") or "0", opp.get("score") or "0")
    if state == "in":
        game_line(c, 35, 12, [(plain(status.get("shortDetail") or "LIVE"), "red"), (score, ac)], stop)
        stat_block(c, 35, 19, live_stats(p, ev), "LIVE", "red", ac)
        return
    if state == "post":
        parts = [("FINAL", "gray")] + result(me, opp, ac)
        if game_width(c, parts) > stop - 35:
            parts = parts[1:]                   # the result matters more than the word
        game_line(c, 35, 12, parts, stop)
        stat_block(c, 35, 19, live_stats(p, ev), "FINAL", "gray", ac)
        return
    day, time = when_et(ev.get("date"), ctx.now.unix, ev.get("timeValid", True))
    parts = [(day, "white"), (time, "white")]
    if ev.get("seasonType") == 1:
        parts = [("PRE", "amber")] + parts
    if game_width(c, parts) > stop - 35:
        parts = [(t.replace(" ET", ""), col) for (t, col) in parts]
    if game_width(c, parts) > stop - 35 and parts[0][0] == "PRE":
        parts = parts[1:]                       # the date and time matter more than the tag
    game_line(c, 35, 12, parts, stop)
    szn = season_stats(ov, p) or NO_STATS
    inj = p["inj"]
    if inj and inj["out"]:
        # injured reserve / IL / out: no projection to show, say why and when he is back
        stats, tag = out_block(p, szn)
        stat_block(c, 35, 19, stats, tag, "gray", "white", inj["color"])
        return
    proj = projection(p, ev)
    if proj and [v for (v, _) in proj if v not in ("-", "0.0", "0")]:
        # questionable / doubtful / day-to-day takes the PROJ slot, in amber
        stat_block(c, 35, 19, proj, inj["tag"] if inj else "PROJ", inj["color"] if inj else "#4FA3FF", ac)
    else:
        # no projection for this player (goalies, kickers, defenders): show the season line
        stat_block(c, 35, 19, szn, szn_tag(p, ev), "gray", ac)
