# Athlete Tracker (NHL): a hockey sweater in team colours with the player's
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

# logo sizes that are not 19x19 (w, h)
LOGO_SIZE = {
    "nhl_ana": (23, 19),
    "nhl_bos": (19, 19),
    "nhl_buf": (19, 19),
    "nhl_car": (26, 16),
    "nhl_cbj": (23, 18),
    "nhl_cgy": (22, 19),
    "nhl_chi": (26, 19),
    "nhl_col": (25, 19),
    "nhl_dal": (23, 19),
    "nhl_det": (26, 19),
    "nhl_edm": (19, 19),
    "nhl_fla": (22, 19),
    "nhl_la": (26, 19),
    "nhl_min": (26, 17),
    "nhl_mtl": (26, 18),
    "nhl_nj": (19, 19),
    "nhl_nsh": (26, 16),
    "nhl_nyi": (19, 19),
    "nhl_nyr": (20, 19),
    "nhl_ott": (24, 19),
    "nhl_phi": (19, 13),
    "nhl_pit": (20, 19),
    "nhl_sea": (15, 19),
    "nhl_sj": (26, 19),
    "nhl_stl": (24, 19),
    "nhl_tb": (21, 19),
    "nhl_tor": (25, 19),
    "nhl_utah": (26, 17),
    "nhl_van": (20, 19),
    "nhl_vgk": (14, 19),
    "nhl_wpg": (19, 19),
    "nhl_wsh": (26, 19),
}

# ---------------------------------------------------------------- players
# The dropdown label the user picked -> (league, ESPN athlete id).

# BEGIN PLAYERS (generated by tools/athlete_tracker_players.py; do not edit by hand)
PLAYERS = {
    "A.J. Greer": 3648015,
    "Aaron Ekblad": 3114717,
    "Aatu Raty": 4874912,
    "Adam Fantilli": 5136617,
    "Adam Fox": 4197146,
    "Adam Henrique": 5074,
    "Adam Jiricek": 5216884,
    "Adam Klapka": 5073306,
    "Adam Larsson": 2562610,
    "Adam Lowry": 2563066,
    "Adam Pelech": 3069621,
    "Adin Hill": 3939714,
    "Adrian Kempe": 3114802,
    "Akira Schmid": 4587845,
    "Alberts Smits": 5334662,
    "Alec Martinez": 3927,
    "Aleksander Barkov": 3041970,
    "Alex Bump": 5188356,
    "Alex Burrows": 3259,
    "Alex DeBrincat": 4063433,
    "Alex Formenton": 4233882,
    "Alex Iafallo": 3652598,
    "Alex Killorn": 4968,
    "Alex Laferriere": 4697725,
    "Alex Lyon": 3654006,
    "Alex Nedeljkovic": 3114994,
    "Alex Newhook": 4565237,
    "Alex Ovechkin": 3101,
    "Alex Pietrangelo": 4013,
    "Alex Tuch": 3114766,
    "Alex Turcotte": 4565226,
    "Alex Vlasic": 4565266,
    "Alexander Nikishin": 5188393,
    "Alexander Nylander": 4024861,
    "Alexander Romanov": 4587854,
    "Alexander Wennberg": 3042017,
    "Alexander Zharovsky": 5291976,
    "Alexandre Carrier": 3942064,
    "Alexandre Texier": 4233880,
    "Alexis Lafreniere": 4697382,
    "Aliaksei Protas": 4587943,
    "Anders Lee": 5793,
    "Andre Burakovsky": 3042044,
    "Andrei Kuzmenko": 5077308,
    "Andrei Svechnikov": 4352683,
    "Andrei Vasilevskiy": 2976847,
    "Andrew Copp": 3042114,
    "Andrew Cristall": 5149227,
    "Andrew Peeke": 4064936,
    "Andy Greene": 3313,
    "Anthony Beauvillier": 3904107,
    "Anthony Cirelli": 3941973,
    "Anthony Duclair": 3042086,
    "Anthony Mantha": 3042037,
    "Anthony Stolarz": 3067313,
    "Anton Forsberg": 3036851,
    "Anton Frondell": 5291935,
    "Anton Lundell": 4697395,
    "Antti Niemi": 3937,
    "Anze Kopitar": 3183,
    "Arber Xhekaj": 4893969,
    "Arseny Gritsyuk": 4915855,
    "Arshdeep Bains": 5103536,
    "Artem Zub": 4712021,
    "Artemi Panarin": 3891952,
    "Artturi Lehkonen": 3042050,
    "Artur Akhtyamov": 4697577,
    "Arturs Silovs": 4576894,
    "Artyom Levshunov": 5206648,
    "Arvid Soderblom": 4894729,
    "Auston Matthews": 4024123,
    "Axel Sandin-Pellikka": 5149192,
    "Barclay Goodrow": 3069411,
    "Barrett Hayton": 4352699,
    "Beck Malenstyn": 4063240,
    "Beckett Sennecke": 5216858,
    "Ben Chiarot": 5246,
    "Ben Kindel": 5291947,
    "Ben Lovejoy": 3993,
    "Berkly Catton": 5216877,
    "Bill Zonnon": 5291958,
    "Blake Coleman": 2563026,
    "Blake Lizotte": 4316983,
    "Bo Horvat": 3042002,
    "Bobby Brink": 4565257,
    "Bobby McMann": 5048894,
    "Bokondji Imama": 3939856,
    "Boone Jenner": 2563054,
    "Bowen Byram": 4565225,
    "Brad Marchand": 3852,
    "Braden Schneider": 4697402,
    "Bradly Nadeau": 5149213,
    "Brady Martin": 5291937,
    "Brady Skjei": 2976856,
    "Brady Tkachuk": 4319858,
    "Braeden Bowman": 5272307,
    "Braeden Cootes": 5291951,
    "Brandon Bussi": 4996097,
    "Brandon Carlo": 3904175,
    "Brandon Duhaime": 4197009,
    "Brandon Hagel": 4065019,
    "Brandon Montour": 3115032,
    "Brandt Clarke": 4874722,
    "Brayden McNabb": 5202,
    "Brayden Point": 3151187,
    "Brayden Schenn": 5219,
    "Brayden Yager": 5149188,
    "Brendan Gallagher": 5614,
    "Brendan Smith": 4973,
    "Brenden Dillon": 2554903,
    "Brent Burns": 2300,
    "Brett Howden": 4024989,
    "Brett Kulak": 3068665,
    "Brett Pesce": 3025535,
    "Brian Dumoulin": 5738,
    "Brock Boeser": 3899979,
    "Brock Faber": 4697449,
    "Brock Nelson": 5798,
    "Brooks Laich": 2180,
    "Bryan Rust": 2591155,
    "Cale Fleury": 4393055,
    "Cale Makar": 4233563,
    "Caleb Desnoyers": 5291936,
    "Caleb Malhotra": 5361656,
    "Calum Ritchie": 5149210,
    "Calvin de Haan": 5266,
    "Calvin Pickard": 5524,
    "Cam Fowler": 5495,
    "Cam Talbot": 5734,
    "Cam York": 4565235,
    "Cameron Hughes": 3942461,
    "Carson Carels": 5361654,
    "Carter Bear": 5291949,
    "Carter Hart": 4064582,
    "Carter Verhaeghe": 3042088,
    "Carter Yakemchuk": 5216868,
    "Casey Cizikas": 5262,
    "Casey DeSmith": 3025540,
    "Casey Mittelstadt": 4233575,
    "Cayden Lindstrom": 5216859,
    "Chandler Stephenson": 3067858,
    "Charle-Edouard D'Astous": 4588175,
    "Charlie Coyle": 2555315,
    "Charlie Lindgren": 3095975,
    "Charlie McAvoy": 3988803,
    "Chase Reid": 5361653,
    "Chris Kreider": 5833,
    "Chris Kunitz": 2179,
    "Chris Tanev": 5592,
    "Christian Dvorak": 3115035,
    "Claude Giroux": 3775,
    "Clay Stevenson": 5104602,
    "Clayton Keller": 4024857,
    "Cody Ceci": 2976843,
    "Cody Franson": 3422,
    "Cody Glass": 4233568,
    "Cody McLeod": 3530,
    "Cole Caufield": 4565236,
    "Cole Eiserman": 5216888,
    "Cole Hutson": 5216918,
    "Cole Perfetti": 4697392,
    "Cole Reinhardt": 4894702,
    "Cole Sillinger": 4874725,
    "Collin Graf": 5136607,
    "Colten Ellis": 4736758,
    "Colton Dach": 4874940,
    "Colton Parayko": 3069341,
    "Colton Sissons": 2993474,
    "Connor Bedard": 5149125,
    "Connor Brown": 3067951,
    "Connor Clifton": 3042191,
    "Connor Dewar": 4588004,
    "Connor Hellebuyck": 3020225,
    "Connor Ingram": 4063522,
    "Connor Mackey": 4319927,
    "Connor McDavid": 3895074,
    "Connor McMichael": 4565246,
    "Connor Murphy": 2562618,
    "Connor Zary": 4697407,
    "Conor Garland": 3939718,
    "Conor Geekie": 5080155,
    "Corey Perry": 2273,
    "Cutter Gauthier": 5080145,
    "Daemon Hunt": 4697711,
    "Dakota Joshua": 4588638,
    "Dalibor Dvorsky": 5149178,
    "Damon Severson": 3068087,
    "Dan Girardi": 3423,
    "Dan Vladar": 3942459,
    "Daniil But": 5149183,
    "Daniil Tarasov": 4587994,
    "Danila Yurov": 5080172,
    "Danny Taylor": 3389,
    "Darcy Kuemper": 2610321,
    "Darnell Nurse": 3041997,
    "Darren Raddysh": 3149843,
    "David Jiricek": 5080147,
    "David Pastrnak": 3114778,
    "David Perron": 3792,
    "David Reinbacher": 5149157,
    "David Rittich": 4063288,
    "David Schlemko": 3774,
    "Dawson Mercer": 4697401,
    "Daxon Rudolph": 5361655,
    "Declan Carlile": 5103825,
    "Dennis Hildeby": 5174160,
    "Dennis Wideman": 3017,
    "Denton Mateychuk": 5080156,
    "Denver Barkey": 5173105,
    "Derek Dorsett": 3641,
    "Devin Cooley": 4319911,
    "Devon Levi": 4894487,
    "Devon Toews": 3096249,
    "Dmitri Simashev": 5149158,
    "Dmitri Voronkov": 4915856,
    "Dmitry Kulikov": 5328,
    "Dmitry Orlov": 5646,
    "Dominic James": 4997033,
    "Dougie Hamilton": 2562605,
    "Drake Batherson": 4271734,
    "Drew Doughty": 3995,
    "Drew O'Connor": 4712146,
    "Dustin Wolf": 4587952,
    "Dylan Cozens": 4565228,
    "Dylan DeMelo": 2590861,
    "Dylan Garand": 4697705,
    "Dylan Guenther": 4874723,
    "Dylan Holloway": 4697397,
    "Dylan Larkin": 3114755,
    "Dylan Samberg": 4233878,
    "Dylan Strome": 3899933,
    "Easton Cowan": 5149211,
    "Eeli Tolvanen": 4233720,
    "Eetu Luostarinen": 4233877,
    "Egor Chinakhov": 4697404,
    "Egor Zamula": 4392268,
    "Elias Lindholm": 3041994,
    "Elias N. Pettersson": 5238086,
    "Elias Pettersson": 4233566,
    "Elmer Soderblom": 5075840,
    "Elvis Merzlikins": 3151038,
    "Emil Andrae": 4697457,
    "Emil Heineman": 4697447,
    "Emmitt Finnie": 5188599,
    "Eric Robinson": 4319879,
    "Erik Cernak": 3904178,
    "Erik Gudbranson": 5503,
    "Erik Haula": 2593311,
    "Erik Johnson": 3649,
    "Erik Karlsson": 5164,
    "Esa Lindell": 3069352,
    "Ethen Frank": 4996093,
    "Evan Bouchard": 4352722,
    "Evan Rodrigues": 3648008,
    "Evander Kane": 5251,
    "Evgeni Malkin": 3124,
    "Fabian Zetterlund": 4587837,
    "Fedor Svechkov": 4874736,
    "Filip Chytil": 4233643,
    "Filip Forsberg": 2968772,
    "Filip Gustavsson": 4272674,
    "Filip Hallander": 4588331,
    "Filip Hronek": 4063607,
    "Florian Xhekaj": 5188457,
    "Frank Nazar": 5080157,
    "Frank Vatrano": 3527554,
    "Fraser Minten": 5080207,
    "Frederick Gaudreau": 3149649,
    "Frederik Andersen": 2517899,
    "Gabe Perreault": 5149204,
    "Gabriel Landeskog": 2562609,
    "Gabriel Vilardi": 4233583,
    "Gage Goncalves": 4697470,
    "Garnet Hathaway": 3149633,
    "Gavin Brindley": 5136614,
    "Gavin McKenna": 5342529,
    "Gleb Pugachyov": 5361716,
    "Gustav Forsling": 3151784,
    "Hampus Lindholm": 2968818,
    "Hendrix Lapierre": 4697405,
    "Ian Cole": 4991,
    "Igor Chernyshov": 5216907,
    "Igor Shesterkin": 3151297,
    "Ilya Lyubushkin": 4342107,
    "Ilya Mikheyev": 4422415,
    "Ilya Protas": 5229146,
    "Ilya Samsonov": 3900505,
    "Ilya Solovyov": 4697784,
    "Ilya Sorokin": 3151981,
    "Isaac Howard": 5080179,
    "Isak Rosen": 4874731,
    "Ivan Barbashev": 3114985,
    "Ivan Demidov": 5216860,
    "Ivan Ivan": 5103714,
    "Ivan Miroshnichenko": 5080168,
    "Ivan Provorov": 3899939,
    "Ivar Stenberg": 5361709,
    "J.J. Moser": 4874929,
    "J.T. Compher": 3041995,
    "J.T. Miller": 2590852,
    "Jaccob Slavin": 3069836,
    "Jack Drury": 4378671,
    "Jack Eichel": 3648002,
    "Jack Hughes": 4565222,
    "Jack Johnson": 3583,
    "Jack McBain": 4755695,
    "Jack Quinn": 4697389,
    "Jack Roslovic": 3904098,
    "Jackson Blake": 5103645,
    "Jackson LaCombe": 4565262,
    "Jackson Smith": 5291950,
    "Jacob Fowler": 5188437,
    "Jacob Markstrom": 5452,
    "Jacob Melanson": 4894747,
    "Jacob Trouba": 2976839,
    "Jaden Schwartz": 5835,
    "Jake Allen": 5111,
    "Jake DeBrusk": 3900240,
    "Jake Evans": 4393049,
    "Jake Guentzel": 3042083,
    "Jake McCabe": 3020803,
    "Jake Middleton": 3149839,
    "Jake Neighbours": 4697409,
    "Jake O'Brien": 5291944,
    "Jake Oettinger": 4196914,
    "Jake Sanderson": 4697386,
    "Jake Walman": 3151136,
    "Jakob Chychrun": 4024950,
    "Jakub Dobes": 4697686,
    "Jalen Chatfield": 4063449,
    "James Hagens": 5275337,
    "James Reimer": 3870,
    "James van Riemsdyk": 3822,
    "Jamie Benn": 3998,
    "Jamie Drysdale": 4697387,
    "Jamie Oleksiak": 2562625,
    "Jared Boll": 3640,
    "Jared McCann": 3114777,
    "Jared Spurgeon": 5079,
    "Jason Dickinson": 3042062,
    "Jason Robertson": 4233875,
    "Jason Zucker": 2593315,
    "Jaxon Cover": 5361678,
    "Jay Beagle": 3879,
    "Jayden Struble": 4565269,
    "Jean-Gabriel Pageau": 2593131,
    "Jeff Glass": 3197,
    "Jeff Malott": 4895214,
    "Jeffrey Viel": 4588188,
    "Jeremy Lauzon": 3904185,
    "Jeremy Swayman": 4712036,
    "Jesper Bratt": 4268771,
    "Jesper Wallstedt": 4874737,
    "Jet Greaves": 4894366,
    "Jimmy Snuggerud": 5080171,
    "Jiri Kulich": 5080176,
    "JJ Peterka": 4697438,
    "Joe Veleno": 4352804,
    "Joel Armia": 2562596,
    "Joel Eriksson Ek": 3904091,
    "Joel Farabee": 4352750,
    "Joel Hofer": 4587909,
    "Joel Ward": 2704,
    "Joey Daccord": 3942073,
    "John Carlson": 5118,
    "John Gibson": 2590824,
    "John Klingberg": 2590751,
    "John Marino": 3941974,
    "John Tavares": 5160,
    "Jonas Brodin": 2562600,
    "Jonas Siegenthaler": 3904190,
    "Jonathan Aspirot": 4392308,
    "Jonathan Drouin": 3041971,
    "Jonathan Huberdeau": 2562606,
    "Jonathan Lekkerimaki": 5080159,
    "Jonathan Marchessault": 2967072,
    "Jonathan Quick": 3634,
    "Jonathan Toews": 3669,
    "Joonas Korpisalo": 3069266,
    "Jordan Binnington": 2590874,
    "Jordan Eberle": 5032,
    "Jordan Greenway": 3900260,
    "Jordan Kyrou": 4062251,
    "Jordan Martinook": 2989376,
    "Jordan Spence": 4588190,
    "Jordan Staal": 3541,
    "Joseph Woll": 4271575,
    "Josh Anderson": 3069687,
    "Josh Doan": 4874870,
    "Josh Gorges": 2265,
    "Josh Manson": 2590829,
    "Josh Morrissey": 3042016,
    "Josh Norris": 4233627,
    "Joshua Mahura": 4063504,
    "Juraj Slafkovsky": 4915349,
    "Justin Brazeau": 4063605,
    "Justin Faulk": 5746,
    "Justin Hryckowian": 5229176,
    "Justin Sourdif": 4697783,
    "Justus Annunen": 4393408,
    "Juuse Saros": 3042109,
    "K'Andre Miller": 4352770,
    "Kaapo Kakko": 4565223,
    "Kaedan Korczak": 4565264,
    "Kaiden Guhle": 4697399,
    "Kailer Yamamoto": 4233648,
    "Karel Vejmelka": 3942065,
    "Kashawn Aitcheson": 5291953,
    "Kasperi Kapanen": 3114775,
    "Keaton Verhoeff": 5342440,
    "Keegan Kolesar": 3941546,
    "Kent Johnson": 4781553,
    "Kevin Bahl": 4378686,
    "Kevin Fiala": 3114743,
    "Kevin Korchinski": 5080148,
    "Kevin Lankinen": 4341584,
    "Kevin Stenlund": 3904191,
    "Kiefer Sherwood": 4391255,
    "Kirby Dach": 4565224,
    "Kirill Kaprizov": 3942335,
    "Kirill Kudryavtsev": 5188544,
    "Kirill Marchenko": 4587996,
    "Konsta Helenius": 5216882,
    "Kris Letang": 3539,
    "Kyle Connor": 3899952,
    "Kyle Palmieri": 5517,
    "Kyle Quincey": 3082,
    "Lane Hutson": 5080230,
    "Lars Eller": 3946,
    "Lawson Crouse": 3899951,
    "Leevi Merilainen": 4894703,
    "Leo Carlsson": 5149153,
    "Leon Draisaitl": 3114727,
    "Liam Ohgren": 5080163,
    "Liam Ruck": 5361669,
    "Lian Bichsel": 5080162,
    "Linus Karlsson": 4587713,
    "Linus Ullmark": 3069285,
    "Logan Cooley": 5080143,
    "Logan Mailloux": 4874748,
    "Logan O'Connor": 3988782,
    "Logan Stankoven": 4874899,
    "Logan Stanley": 4024968,
    "Logan Thompson": 4272888,
    "Louis Crevier": 4697681,
    "Luca Cagnoni": 5188591,
    "Lucas Raymond": 4697385,
    "Lukas Dostal": 4588165,
    "Luke Evangelista": 4697446,
    "Luke Hughes": 4874719,
    "Luke Schenn": 5092,
    "Mackenzie Blackwood": 3904177,
    "MacKenzie Weegar": 3042269,
    "Mackie Samoskevich": 4874741,
    "Macklin Celebrini": 5206628,
    "Marat Khusnutdinov": 4697442,
    "Marc Gatcomb": 5103547,
    "Marc-Andre Fleury": 2346,
    "Marc-Edouard Vlasic": 3371,
    "Marco Kasper": 5080152,
    "Marco Rossi": 4697391,
    "Marcus Foligno": 5172,
    "Marcus Johansson": 5714,
    "Marcus Pettersson": 3114995,
    "Mario Ferraro": 4233884,
    "Mark  Letestu": 3626,
    "Mark Giordano": 3006,
    "Mark Jankowski": 2976849,
    "Mark Kastelic": 4587985,
    "Mark Scheifele": 2562632,
    "Mark Stone": 5545,
    "Mark Streit": 3256,
    "Markus Ruck": 5361672,
    "Martin Fehervary": 4378677,
    "Martin Necas": 4233586,
    "Martin Pospisil": 4392883,
    "Mason Lohrei": 4697461,
    "Mason Marchment": 4272192,
    "Mason McTavish": 4874718,
    "Mathew Barzal": 3899946,
    "Mathieu Joseph": 3941965,
    "Mathieu Olivier": 4064781,
    "Matias Maccelli": 4587580,
    "Mats Zuccarello": 5560,
    "Matt Boldy": 4565233,
    "Matt Coronato": 4874730,
    "Matt Duchene": 5161,
    "Matt Rempe": 4697820,
    "Matt Roy": 3942924,
    "Matt Savoie": 5080153,
    "Matthew Knies": 4874919,
    "Matthew Robertson": 4565272,
    "Matthew Schaefer": 5291933,
    "Matthew Tkachuk": 4024854,
    "Matthew Wood": 5149189,
    "Mattias Ekholm": 2558631,
    "Mattias Samuelsson": 4378656,
    "Matty Beniers": 4781552,
    "Matvei Gridin": 5216897,
    "Matvei Michkov": 5149170,
    "Mavrik Bourque": 4697413,
    "Max Domi": 3042014,
    "Max Pacioretty": 4005,
    "Max Sasson": 4996099,
    "Maxim Shabanov": 5302535,
    "Maxim Tsyplakov": 5212753,
    "Michael Amadio": 3149829,
    "Michael Blunden": 3345,
    "Michael Brandsegg-Nygard": 5216883,
    "Michael Bunting": 3149603,
    "Michael Carcone": 4031645,
    "Michael DiPietro": 4392765,
    "Michael Hage": 5216889,
    "Michael Kesselring": 4331604,
    "Michael McCarron": 3042048,
    "Michael Misa": 5291934,
    "Mika Zibanejad": 2562637,
    "Mikael Backlund": 3797,
    "Mikael Granlund": 5831,
    "Mike Matheson": 2976851,
    "Mikey Anderson": 4588178,
    "Mikhail Sergachev": 4024868,
    "Mikko Rantanen": 3899938,
    "Miro Heiskanen": 4233536,
    "Mitch Marner": 3899937,
    "Morgan Barron": 4316970,
    "Morgan Frost": 4233685,
    "Morgan Geekie": 4268466,
    "Morgan Rielly": 2976833,
    "Moritz Seider": 4565227,
    "Nate Danielson": 5149175,
    "Nate Schmidt": 3024798,
    "Nathan MacKinnon": 3041969,
    "Nazem Kadri": 5349,
    "Neal Pionk": 3988847,
    "Nic Dowd": 3025616,
    "Nick Blankenburg": 4781550,
    "Nick Cousins": 2563027,
    "Nick Foligno": 3535,
    "Nick Holden": 3884,
    "Nick Lardis": 5173765,
    "Nick Paul": 3042111,
    "Nick Robertson": 4565275,
    "Nick Schmaltz": 3114770,
    "Nick Seeler": 2564164,
    "Nick Suzuki": 4233594,
    "Nico Daws": 4697683,
    "Nico Hischier": 4233555,
    "Nicolas Deslauriers": 5193,
    "Nicolas Roy": 3943996,
    "Nikita Klepov": 5361658,
    "Nikita Kucherov": 2563060,
    "Nikita Zadorov": 3042021,
    "Niko Mikkola": 3942354,
    "Nikolaj Ehlers": 3114741,
    "Nils Hoglander": 4565263,
    "Nils Lundkvist": 4352800,
    "Nino Niederreiter": 5511,
    "Noah Cates": 4419682,
    "Noah Dobson": 4352732,
    "Noah Hanifin": 3652964,
    "Noah Laba": 5188370,
    "Noah Ostlund": 5080160,
    "Noel Acciari": 3096237,
    "Nolan Allan": 4874749,
    "Olen Zellweger": 4874863,
    "Oliver Bjorkstrand": 3042095,
    "Oliver Bonk": 5149199,
    "Oliver Ekman-Larsson": 5488,
    "Oliver Kapanen": 4874943,
    "Oliver Moore": 5149194,
    "Olli Maatta": 2976850,
    "Ondrej Palat": 2590389,
    "Oskar Back": 4894398,
    "Owen Michaels": 5206840,
    "Owen Power": 4781556,
    "Owen Tippett": 4392072,
    "P.A. Parenteau": 2101,
    "Parker Kelly": 4392309,
    "Parker Wotherspoon": 3942638,
    "Pat Maroon": 3853,
    "Patrick Kane": 3735,
    "Patrik Laine": 4024820,
    "Paul Cotter": 4331579,
    "Pavel Buchnevich": 3042081,
    "Pavel Dorofeyev": 4587588,
    "Pavel Mintyukov": 5080154,
    "Pavel Zacha": 3899949,
    "Peyton Krebs": 4565238,
    "Philip Broberg": 4565229,
    "Philipp Grubauer": 5657,
    "Phillip Danault": 2562602,
    "Pierre-Cedric Labrie": 3809,
    "Pierre-Luc Dubois": 4024833,
    "Pius Suter": 4271732,
    "Porter Martone": 5291941,
    "Pyotr Kochetkov": 4565259,
    "Quinn Hughes": 4320548,
    "Quinn Hutson": 5136660,
    "Quinton Byfield": 4697383,
    "Radek Faksa": 2976842,
    "Radko Gudas": 5502,
    "Rasmus Andersson": 3904186,
    "Rasmus Dahlin": 4294163,
    "Rasmus Ristolainen": 3041999,
    "Rasmus Sandin": 4352803,
    "Rickard Rakell": 2562629,
    "Ridly Greig": 4697411,
    "Robert Bortuzzo": 4916,
    "Robert Thomas": 4233637,
    "Roger McQueen": 5291946,
    "Roman Josi": 5436,
    "Roman Kantserov": 5149231,
    "Roope Hintz": 3904183,
    "Ross Colton": 4392471,
    "Ross Johnston": 3067822,
    "Rutger McGroarty": 5080158,
    "Ryan Donato": 3115033,
    "Ryan Graves": 3042122,
    "Ryan Greene": 5080227,
    "Ryan Hartman": 3042063,
    "Ryan Leonard": 5149172,
    "Ryan Lindgren": 4271998,
    "Ryan McDonagh": 4954,
    "Ryan McLeod": 4378669,
    "Ryan Nugent-Hopkins": 2562624,
    "Ryan O'Reilly": 5208,
    "Ryan Poehling": 4233668,
    "Ryan Pulock": 3042019,
    "Ryan Reaves": 3683,
    "Ryan Shea": 3942033,
    "Ryan Strome": 2562636,
    "Ryan Suter": 3047,
    "Ryan Suzuki": 4565249,
    "Ryan Ufko": 5188493,
    "Ryker Evans": 4874864,
    "Sam Bennett": 3114732,
    "Sam Carrick": 5474,
    "Sam Dickinson": 5216880,
    "Sam Malinski": 5136735,
    "Sam Montembeault": 3942714,
    "Sam Reinhart": 3114722,
    "Sam Rinzel": 5080173,
    "Sam Steel": 4024998,
    "Samuel Ersson": 4587815,
    "Samuel Girard": 4063401,
    "Sandis Vilmanis": 5103599,
    "Scott Laughton": 2976848,
    "Scott Wedgewood": 5622,
    "Seamus Casey": 5080212,
    "Sean Couturier": 2562601,
    "Sean Durzi": 4378683,
    "Sean Kuraly": 2564154,
    "Sean Monahan": 3041996,
    "Sean Walker": 4272905,
    "Sebastian Aho": 3904173,
    "Sebastian Cossa": 4874732,
    "Semyon Varlamov": 3759,
    "Sergei Bobrovsky": 5571,
    "Sergei Murashov": 5188366,
    "Seth Jarvis": 4697396,
    "Seth Jones": 3041992,
    "Shakir Mukhamadullin": 4697403,
    "Shane Pinto": 4565255,
    "Shane Wright": 5080144,
    "Shayne Gostisbehere": 3025662,
    "Shea Theodore": 3042055,
    "Sidney Crosby": 3114,
    "Simon Benoit": 4392642,
    "Simon Edvinsson": 4874720,
    "Simon Holmstrom": 4565244,
    "Simon Nemec": 4915344,
    "Spencer Knight": 4565234,
    "Stephen Halliday": 5136706,
    "Steven Stamkos": 5037,
    "Stuart Skinner": 4268767,
    "T.J. Hughes": 5136616,
    "Tage Thompson": 4024988,
    "Tanner Jeannot": 4064780,
    "Taylor Hall": 5428,
    "Taylor Makar": 4997080,
    "Taylor Raddysh": 4063502,
    "Teddy Blueger": 3024916,
    "Teuvo Teravainen": 2592095,
    "Thatcher Demko": 3096217,
    "Thomas Chabot": 3900219,
    "Thomas Harley": 4565239,
    "Tij Iginla": 5229186,
    "Tim Stutzle": 4697384,
    "Timo Meier": 3899978,
    "Timothy Liljegren": 4233618,
    "Tom Willander": 5149180,
    "Tom Wilson": 2970615,
    "Tomas Hertl": 2976844,
    "Tommy Novak": 3942061,
    "Tony DeAngelo": 3114769,
    "Travis Konecny": 3900169,
    "Travis Sanheim": 3114757,
    "Trent Frederic": 4024997,
    "Trevor Connelly": 5216887,
    "Trevor Lewis": 3454,
    "Trevor Moore": 3096186,
    "Trevor van Riemsdyk": 3025524,
    "Trevor Zegras": 4565230,
    "Trey Augustine": 5149228,
    "Tristan Jarry": 3042020,
    "Tristan Luneau": 5080220,
    "Troy Stecher": 3096102,
    "Troy Terry": 3942905,
    "Tye Kartye": 4588750,
    "Tyler Bertuzzi": 3042056,
    "Tyler Kleven": 4697448,
    "Tyler Myers": 5052,
    "Tyler Seguin": 5430,
    "Tyler Toffoli": 5550,
    "Tyson Foerster": 4697406,
    "Ukko-Pekka Luukkonen": 4233889,
    "Uvis Balinskis": 5142461,
    "Valeri Nichushkin": 3042003,
    "Vasily Podkolzin": 4565231,
    "Victor Eklund": 5291952,
    "Victor Hedman": 5157,
    "Victor Olofsson": 3151096,
    "Viggo Bjorck": 5361711,
    "Viking Gustafsson Nyberg": 5275403,
    "Viktor Arvidsson": 3120307,
    "Ville Husso": 3151137,
    "Ville Koivunen": 4874911,
    "Vince Dunn": 3904189,
    "Vincent Desharnais": 4392260,
    "Vincent Trocheck": 2563036,
    "Vitek Vanecek": 3114996,
    "Vladimir Tarasenko": 5837,
    "Vladislav Gavrikov": 3942292,
    "Warren Foegele": 3151036,
    "Wiggo Sorensson": 5364138,
    "Will Borgen": 3941946,
    "Will Cuylle": 4697468,
    "Will Smith": 5149155,
    "William Carrier": 3042054,
    "William Eklund": 4874721,
    "William Karlsson": 2563057,
    "William Nylander": 3114736,
    "Wyatt Aamodt": 4419668,
    "Wyatt Cullen": 5361662,
    "Wyatt Johnston": 4874740,
    "Wyatt Kaiser": 4697717,
    "Yakov Trenin": 3904188,
    "Yanni Gourde": 3094261,
    "Yaroslav Askarov": 4697394,
    "Yegor Sharangovich": 4587843,
    "Zach Benson": 5149186,
    "Zach Bogosian": 4002,
    "Zach Hyman": 5509,
    "Zach Metsa": 4419696,
    "Zach Werenski": 3899972,
    "Zach Whitecloud": 4312877,
    "Zack Bolduc": 4874734,
    "Zack Ostapchuk": 4874881,
    "Zayne Parekh": 5216878,
    "Zeev Buium": 5206642,
    "Zemgus Girgensons": 2968829,
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

# ---------------------------------------------------------------- ESPN data

LEAGUE = "nhl"
DEFAULT_PLAYER = "Connor McDavid"
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
    ev = next_event(ov, ctx.now.unix)
    ac = accent(p["color"], p["alt"])
    c.clear()
    draw_gear(c, p["lg"], p["num"], p["color"], p["alt"], p["logo"])
    if ev == None:
        # offseason, or nothing on the schedule yet: say so and keep the season line
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
        game_line(c, 35, 12, [("FINAL", "gray"), (score, ac)], stop)
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
