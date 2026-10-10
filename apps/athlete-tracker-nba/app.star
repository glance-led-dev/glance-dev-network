# Athlete Tracker (NBA): a basketball jersey in team colours with the player's
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
}

# logo sizes that are not 19x19 (w, h)
LOGO_SIZE = {
    "nba_atl": (19, 19),
    "nba_bkn": (19, 19),
    "nba_bos": (19, 19),
    "nba_cha": (25, 19),
    "nba_chi": (22, 19),
    "nba_cle": (22, 19),
    "nba_dal": (19, 19),
    "nba_den": (19, 19),
    "nba_det": (19, 19),
    "nba_gs": (19, 19),
    "nba_hou": (14, 19),
    "nba_ind": (23, 19),
    "nba_lac": (14, 19),
    "nba_lal": (19, 16),
    "nba_mem": (20, 19),
    "nba_mia": (18, 19),
    "nba_mil": (25, 19),
    "nba_min": (19, 19),
    "nba_no": (26, 10),
    "nba_ny": (25, 19),
    "nba_okc": (17, 19),
    "nba_orl": (26, 18),
    "nba_phi": (24, 19),
    "nba_phx": (26, 19),
    "nba_por": (19, 19),
    "nba_sa": (18, 18),
    "nba_sac": (26, 19),
    "nba_tor": (19, 19),
    "nba_utah": (26, 18),
    "nba_wsh": (19, 19),
}

# ---------------------------------------------------------------- players
# The dropdown label the user picked -> (league, ESPN athlete id).

# BEGIN PLAYERS (generated by tools/athlete_tracker_players.py; do not edit by hand)
PLAYERS = {
    "Aaron Gordon": 3064290,
    "Aaron Holiday": 3922230,
    "Aaron Nesmith": 4396909,
    "Aaron White": 2595175,
    "Aaron Wiggins": 4397183,
    "Ace Bailey": 4873138,
    "Aday Mara": 5174983,
    "Adem Bona": 5105637,
    "Adou Thiero": 5060631,
    "AJ Dybantsa": 5142718,
    "AJ Green": 4397475,
    "AJ Hammons": 2991178,
    "AJ Johnson": 5170947,
    "Ajay Mitchell": 4900671,
    "Al Horford": 3213,
    "Alan Williams": 2579326,
    "Alec Burks": 6429,
    "Alex Antetokounmpo": 4432452,
    "Alex Caruso": 2991350,
    "Alex Karaban": 4917149,
    "Alex Kirk": 2528355,
    "Alex Sarr": 5160992,
    "Alijah Martin": 4702656,
    "Allen Graves": 5149115,
    "Alondes Williams": 4592216,
    "Alperen Sengun": 4871144,
    "Amari Williams": 4702745,
    "Amen Thompson": 4684740,
    "Amida Brimah": 3074748,
    "Andre Drummond": 6585,
    "Andre Jackson Jr.": 4432190,
    "Andrew Nembhard": 4395712,
    "Andrew White III": 2990972,
    "Andrew Wiggins": 3059319,
    "Anfernee Simons": 4351851,
    "Angel Delgado": 3136479,
    "Anthony Black": 4712849,
    "Anthony Brown": 2531362,
    "Anthony Davis": 6583,
    "Anthony Edwards": 4594268,
    "Anthony Gill": 2581184,
    "Anthony Lamb": 4066790,
    "Anthony Tolliver": 3276,
    "Anton Watson": 4431705,
    "Antonius Cleveland": 3064237,
    "Ariel Hukporti": 4871141,
    "Aron Baynes": 2968439,
    "Asa Newell": 4873201,
    "Ausar Thompson": 4684742,
    "Austin Reaves": 4066457,
    "Ayo Dosunmu": 4397002,
    "Baba Miller": 5075626,
    "Bam Adebayo": 4066261,
    "Baylor Scheierman": 4593841,
    "Ben Saraf": 5242502,
    "Ben Sheppard": 4433076,
    "Ben Simmons": 3907387,
    "Bennedict Mathurin": 4683634,
    "Bennett Stirtz": 5241364,
    "Bilal Coulibaly": 5104155,
    "Billy Garrett Jr.": 3059356,
    "Bismack Biyombo": 6427,
    "BJ Johnson": 3059280,
    "Blake Hinson": 4396963,
    "Blake Wesley": 4683935,
    "Boban Marjanovic": 4376,
    "Bobby Portis": 3064482,
    "Bogdan Bogdanovic": 3037789,
    "Bogoljub Markovic": 5214989,
    "Bol Bol": 4397102,
    "Bones Hyland": 4592492,
    "Boo Buie": 4592712,
    "Brad Wanamaker": 6507,
    "Braden Smith": 5105854,
    "Bradley Beal": 6580,
    "Brandin Podziemski": 4709138,
    "Brandon Goodwin": 3057198,
    "Brandon Ingram": 3913176,
    "Brandon Miller": 4433287,
    "Brandon Williams": 4397040,
    "Brayden Burries": 5082206,
    "Brian Bowen II": 4277882,
    "Briante Weber": 2595229,
    "Brice Johnson": 2982330,
    "Brice Sensabaugh": 5105839,
    "Bronny James": 4683774,
    "Brook Lopez": 3448,
    "Brooks Barnhizer": 4684208,
    "Bruce Brown": 4065670,
    "Bruce Thornton": 5105837,
    "Bryce Cotton": 2531054,
    "Bryce Hopkins": 4565698,
    "Bryce McGowens": 4576086,
    "Bub Carrington": 4845374,
    "Buddy Hield": 2990984,
    "C.J. Williams": 2325499,
    "Cade Cunningham": 4432166,
    "Cady Lalanne": 2608716,
    "Caleb Houstan": 4433623,
    "Caleb Love": 4433144,
    "Caleb Martin": 3138160,
    "Caleb Wilson": 5095151,
    "Cam Christie": 4845363,
    "Cam Reddish": 4395627,
    "Cam Spencer": 4433083,
    "Cam Thomas": 4432174,
    "Cam Whitmore": 5105592,
    "Cameron Boozer": 5041935,
    "Cameron Carr": 5113969,
    "Cameron Johnson": 3138196,
    "Cameron Oliver": 3928275,
    "Cameron Payne": 3064230,
    "Caris LeVert": 2991043,
    "Carter Bryant": 5061568,
    "Cason Wallace": 4683692,
    "Cat Barber": 3059266,
    "Cedric Coward": 4903027,
    "Charles Bassey": 4397886,
    "Charles Cooke": 2988387,
    "Chaz Lanier": 4700852,
    "Chet Holmgren": 4433255,
    "Chris Boucher": 3948153,
    "Chris Cenac Jr.": 5142621,
    "Chris Johnson": 2325975,
    "Chris Manon": 4702972,
    "Chris Paul": 2779,
    "Chris Youngblood": 4706557,
    "Christian Anderson": 5060701,
    "Christian Braun": 4431767,
    "Christian Wood": 3058254,
    "CJ McCollum": 2490149,
    "Cliff Alexander": 3133600,
    "Clint Capela": 3102529,
    "Coby White": 4395651,
    "Cody Williams": 4895758,
    "Cole Anthony": 4432809,
    "Cole Swider": 4397134,
    "Colin Castleton": 4397204,
    "Collin Gillespie": 4278585,
    "Collin Murray-Boyles": 5093267,
    "Collin Sexton": 4277811,
    "Cooper Flagg": 5041939,
    "Corey Kispert": 4280151,
    "Craig Porter Jr.": 4701233,
    "Cristiano Felicio": 3113587,
    "D'Angelo Russell": 3136776,
    "Daeqwon Plowden": 4279318,
    "Dailyn Swain": 4848625,
    "Dalano Banton": 4397885,
    "Dalen Terry": 4433159,
    "Dalton Knecht": 4897943,
    "Damian Lillard": 6606,
    "Damien Inglis": 3102534,
    "Daniel Gafford": 4278049,
    "Daniel Theis": 2451037,
    "Daniss Jenkins": 5107199,
    "Danny Wolf": 5107173,
    "Dante Exum": 3102528,
    "DaQuan Jeffries": 3913220,
    "Dario Saric": 3032978,
    "Dariq Whitehead": 4432735,
    "Darius Acuff Jr.": 5142620,
    "Darius Garland": 4396907,
    "DaRon Holmes II": 4433607,
    "Darrun Hilliard": 2578259,
    "Darryn Peterson": 5041955,
    "David Jones Garcia": 4713010,
    "David Roddy": 4593041,
    "Davion Mitchell": 4278053,
    "Day'Ron Sharpe": 4432194,
    "De'Aaron Fox": 4066259,
    "De'Andre Hunter": 4065732,
    "De'Anthony Melton": 4066436,
    "Dean Wade": 3912848,
    "Deandre Ayton": 4278129,
    "DeAndre Jordan": 3442,
    "Dejounte Murray": 3907497,
    "Delon Wright": 3064447,
    "DeMar DeRozan": 3978,
    "Deni Avdija": 4683021,
    "Dennis Schroder": 3032979,
    "Dereck Lively II": 4683688,
    "Derik Queen": 4869780,
    "Derrick Jones Jr.": 3936099,
    "Derrick Walton Jr.": 3056273,
    "Derrick White": 3078576,
    "Desmond Bane": 4066320,
    "DeVaughn Akoon-Purcell": 3138256,
    "Devin Booker": 3136193,
    "Devin Carter": 4433188,
    "Devin Vassell": 4395630,
    "Dewayne Dedmon": 2580913,
    "Dillon Brooks": 3155526,
    "Dillon Jones": 4702159,
    "Dillon Mitchell": 5106283,
    "DJ Stephens": 2489563,
    "Domantas Sabonis": 3155942,
    "Dominick Barlow": 4870562,
    "Donovan Clingan": 5105565,
    "Donovan Mitchell": 3908809,
    "Donte DiVincenzo": 3934673,
    "Donte Grantham": 3129674,
    "Dorian Finney-Smith": 2578185,
    "Drake Powell": 5037873,
    "Draymond Green": 6589,
    "Drew Eubanks": 3914285,
    "Drew Gordon": 2327465,
    "Drew Peterson": 4397689,
    "Drew Timme": 4431695,
    "Dru Smith": 4066993,
    "Duncan Robinson": 3157465,
    "Duop Reath": 4066268,
    "Dwight Buycks": 6503,
    "Dwight Powell": 2531367,
    "Dylan Cardwell": 4433174,
    "Dylan Harper": 5037871,
    "Dyson Daniels": 4869342,
    "Ebuka Okorie": 5258459,
    "Edy Tavares": 3033031,
    "Egor Demin": 5175643,
    "Elijah Harkless": 4397449,
    "Emanuel Sharp": 5106058,
    "Emoni Bates": 4433620,
    "Enrique Freeman": 4592699,
    "Eric Atkins": 2531045,
    "Eric Gordon": 3431,
    "Eric Griffin": 2528646,
    "Eric Mika": 3065284,
    "Evan Mobley": 4432158,
    "Facundo Campazzo": 2968334,
    "Felix Okpara": 5105841,
    "Franz Wagner": 4566434,
    "Fred VanVleet": 2991230,
    "Gabe Vincent": 3137259,
    "Garrett Temple": 4023,
    "Garrison Mathews": 3913180,
    "Gary Harris": 2999547,
    "Gary Payton II": 3134903,
    "Gary Trent Jr.": 4277843,
    "Georges Niang": 2990969,
    "Georgios Papagiannis": 4017846,
    "GG Jackson": 5105550,
    "Gian Clavell": 3137694,
    "Giannis Antetokounmpo": 3032977,
    "Goga Bitadze": 4348700,
    "Gradey Dick": 5106258,
    "Grant Williams": 4066218,
    "Grayson Allen": 3135045,
    "Greg Whittington": 2594920,
    "Guerschon Yabusele": 4017844,
    "Gui Santos": 4997536,
    "Hannes Steinbach": 5281370,
    "Harrison Barnes": 6578,
    "Harrison Ingram": 4433618,
    "Henri Veesaar": 5105571,
    "Herbert Jones": 4277813,
    "Hollis Thompson": 6634,
    "Hugo Gonzalez": 5175647,
    "Hunter Dickinson": 4432180,
    "Hunter Tyson": 4395620,
    "Ian Clark": 2489785,
    "Immanuel Quickley": 4395724,
    "Isaac Humphries": 3926491,
    "Isaac Jones": 5107818,
    "Isaac Okoro": 4432822,
    "Isaiah Collier": 4683766,
    "Isaiah Evans": 5061585,
    "Isaiah Hartenstein": 4222252,
    "Isaiah Hicks": 3074765,
    "Isaiah Jackson": 4432170,
    "Isaiah Joe": 4395702,
    "Isaiah Livers": 4277957,
    "Isaiah Mobley": 4432815,
    "Isaiah Stewart": 4432810,
    "Isaiah Taylor": 3059336,
    "Isaiah Wong": 4431727,
    "Ish Smith": 4305,
    "Ish Wainright": 3059307,
    "Ivica Zubac": 4017837,
    "Izaiyah Nelson": 5107251,
    "J.J. Barea": 3055,
    "J.P. Tokoto": 2982331,
    "Ja Morant": 4279888,
    "Ja'Kobe Walter": 4684272,
    "Ja'Kobi Gillespie": 5107968,
    "Jabari Smith Jr.": 4432639,
    "Jabari Walker": 4432446,
    "Jack McVeigh": 3911893,
    "Jack White": 4065653,
    "Jacob Wiley": 2995079,
    "Jaden Bradley": 4432737,
    "Jaden Hardy": 4868423,
    "Jaden Ivey": 4433218,
    "Jaden McDaniels": 4431671,
    "Jae Crowder": 6581,
    "Jae'Sean Tate": 3136777,
    "Jahlil Okafor": 3135048,
    "Jahmai Mashack": 4683934,
    "Jahmir Young": 4433133,
    "Jaime Jaquez Jr.": 4432848,
    "JaKarr Sampson": 2608891,
    "Jake LaRavia": 4592691,
    "Jakob Poeltl": 3134908,
    "Jalen Bridges": 4432946,
    "Jalen Brunson": 3934672,
    "Jalen Duren": 4433621,
    "Jalen Green": 4437244,
    "Jalen Johnson": 4701230,
    "Jalen Lecque": 4423887,
    "Jalen McDaniels": 4066731,
    "Jalen Pickett": 4398390,
    "Jalen Slawson": 4398207,
    "Jalen Smith": 4397189,
    "Jalen Suggs": 4432165,
    "Jalen Williams": 4593803,
    "Jalen Wilson": 4431714,
    "Jamal Cain": 4278572,
    "Jamal Murray": 3936299,
    "Jamal Shead": 4432241,
    "Jamaree Bouyea": 4280245,
    "Jameel Warney": 2982185,
    "Jamel Artis": 3059276,
    "James Harden": 3992,
    "James Johnson": 3999,
    "James Michael McAdoo": 2594818,
    "James Nnaji": 5144059,
    "James Nunnally": 2326411,
    "James Webb III": 3079021,
    "James Wiseman": 4432808,
    "Jamil Wilson": 2488977,
    "Jamir Watkins": 4606840,
    "Jamison Battle": 4431893,
    "JaMychal Green": 2327577,
    "Jarace Walker": 5106060,
    "Jared McCain": 4683778,
    "Jared Terrell": 3133843,
    "Jaren Jackson Jr.": 4277961,
    "Jarred Vanderbilt": 4278077,
    "Jarrett Allen": 4066328,
    "Jase Richardson": 5239561,
    "Javin DeLaurier": 4065650,
    "Javon Freeman-Liberty": 4397511,
    "Javon Small": 4781746,
    "Javonte Green": 2596112,
    "Jaxson Hayes": 4397077,
    "Jay Huff": 4065731,
    "Jayden Quaintance": 5101845,
    "Jaylen Adams": 3133874,
    "Jaylen Brown": 3917376,
    "Jaylen Clark": 4432247,
    "Jaylen Hoard": 4395688,
    "Jaylen Nowell": 4278541,
    "Jaylen Wells": 5112087,
    "Jaylin Williams": 4432823,
    "Jaylon Tyson": 4683747,
    "Jayson Tatum": 4065648,
    "JD Davison": 4576085,
    "Jeff Dowtin Jr.": 4066786,
    "Jeff Green": 3209,
    "Jerami Grant": 2991070,
    "Jeremiah Fears": 5144091,
    "Jeremiah Robinson-Earl": 4432813,
    "Jeremy Sochan": 4610139,
    "Jericho Sims": 4277922,
    "Jett Howard": 5105806,
    "Jevon Carter": 3133635,
    "Jimmy Butler III": 6430,
    "Joan Beringer": 5279133,
    "Jock Landale": 3146557,
    "Joe Chealey": 3058269,
    "Joe Ingles": 2968436,
    "Joe Young": 2528386,
    "Joel Berry II": 3138155,
    "Joel Bolomboy": 2983551,
    "Joel Embiid": 3059318,
    "John Collins": 3908845,
    "John Konchar": 3134932,
    "John Tonje": 4593043,
    "Johnathan Williams": 3064528,
    "Johni Broome": 4433569,
    "Johnny Furphy": 5157066,
    "Jonas Valanciunas": 6477,
    "Jonathan Isaac": 4065654,
    "Jonathan Kuminga": 4433247,
    "Jonathan Mogbo": 5107897,
    "Jordan Clarkson": 2528426,
    "Jordan Goodwin": 4278402,
    "Jordan Hawkins": 4683750,
    "Jordan McLaughlin": 3134916,
    "Jordan Miller": 4396818,
    "Jordan Poole": 4277956,
    "Jordan Walsh": 4683689,
    "Jose Alvarado": 4277869,
    "Josh Giddey": 4871145,
    "Josh Green": 4432811,
    "Josh Hart": 3062679,
    "Josh Minott": 4687718,
    "Josh Okogie": 4065663,
    "Joshua Jefferson": 4870564,
    "Jrue Holiday": 3995,
    "JT Thor": 4702233,
    "Juan Toscano-Anderson": 4401416,
    "Julian Champagnie": 4592479,
    "Julian Phillips": 5105553,
    "Julian Reese": 4683742,
    "Julian Strawther": 4432181,
    "Julian Washburn": 2579492,
    "Julius Randle": 3064514,
    "Justin Champagnie": 4432907,
    "Justin Edwards": 4711297,
    "Justin Holiday": 2284101,
    "Jusuf Nurkic": 3102530,
    "Kam Jones": 4697268,
    "Karim Lopez": 5231919,
    "Karl-Anthony Towns": 3136195,
    "Karlo Matkovic": 4997538,
    "Kasparas Jakucionis": 5214640,
    "Kawhi Leonard": 6450,
    "Keaton Wagler": 5254165,
    "Keegan Murray": 4594327,
    "Kel'el Ware": 5105623,
    "Keldon Johnson": 4395723,
    "Kelly Olynyk": 2489663,
    "Kelly Oubre Jr.": 3133603,
    "Kennedy Chandler": 4432646,
    "Kenneth Lofton Jr.": 4585610,
    "Kenrich Williams": 3133626,
    "Kent Bazemore": 6637,
    "Kentavious Caldwell-Pope": 2581018,
    "Keon Ellis": 4702177,
    "Keshad Johnson": 4431786,
    "Kevin Durant": 3202,
    "Kevin Huerter": 4066372,
    "Kevin Love": 3449,
    "Kevin McCullar Jr.": 4411057,
    "Kevin Pangos": 2583962,
    "Kevin Porter Jr.": 4397140,
    "Kevon Looney": 3155535,
    "Keyonte George": 4433627,
    "Khalifa Diop": 4997530,
    "Khaman Maluach": 5203685,
    "Khem Birch": 2578240,
    "Khris Middleton": 6609,
    "Killian Hayes": 4683024,
    "Kingston Flemings": 5149077,
    "KJ Martin": 4431828,
    "Klay Thompson": 6475,
    "Koa Peat": 5041953,
    "Kobe Brown": 4431752,
    "Kobe Bufkin": 4683736,
    "Kobe Sanders": 4702352,
    "Koby Brea": 4591259,
    "Kon Knueppel": 5061575,
    "Kris Dunn": 2991139,
    "Kris Murray": 4594326,
    "Kristaps Porzingis": 3102531,
    "Kyle Anderson": 2993874,
    "Kyle Filipowski": 4684793,
    "Kyle Kuzma": 3134907,
    "Kyle Lowry": 3012,
    "Kyrie Irving": 6442,
    "Kyshawn George": 5174563,
    "Labaron Philon Jr.": 4873090,
    "Lajae Jones": 5108969,
    "Lamar Patterson": 2488721,
    "LaMelo Ball": 4432816,
    "Lance Thomas": 6485,
    "Landry Shamet": 3914044,
    "Larry Nance Jr.": 2580365,
    "Lauri Markkanen": 4066336,
    "Leaky Black": 4395650,
    "LeBron James": 1966,
    "Leonard Miller": 5044385,
    "Liam McNeeley": 5239590,
    "Liam Robbins": 4397347,
    "London Perrantes": 3059286,
    "Lonnie Walker IV": 4277890,
    "Lonzo Ball": 4066421,
    "Lorenzo Brown": 2528787,
    "Lucas Nogueira": 3032980,
    "Luguentz Dort": 4397020,
    "Luka Doncic": 3945274,
    "Luka Garza": 4277951,
    "Luka Mitrovic": 3899662,
    "Luke Kennard": 3913174,
    "Luke Kornet": 3064560,
    "Luke Travers": 4997539,
    "Mac McClung": 4397071,
    "Malachi Flynn": 4066668,
    "Malaki Branham": 4565201,
    "Malcolm Brogdon": 2566769,
    "Malcolm Delaney": 2282205,
    "Malik Beasley": 3907822,
    "Malik Monk": 4066262,
    "Malik Williams": 4277880,
    "Maliq Brown": 5105337,
    "Malique Lewis": 5184016,
    "Mamadi Diakite": 3947156,
    "Marcus Sasser": 4432107,
    "Marcus Smart": 2990992,
    "MarJon Beauchamp": 4432179,
    "Mark Williams": 4701232,
    "Markelle Fultz": 4066636,
    "Markus Howard": 4065805,
    "MarShon Brooks": 6428,
    "Marvin Bagley III": 4277848,
    "Mason Plumlee": 2488653,
    "Matas Buzelis": 4711294,
    "Matisse Thybulle": 3907498,
    "Matt Thomas": 3059311,
    "Matt Williams Jr.": 2991295,
    "Matthew Dellavedova": 2489716,
    "Max Christie": 4432582,
    "Max Shulga": 4701992,
    "Max Strus": 4065778,
    "Maxi Kleber": 2960236,
    "Maxime Raynaud": 4898371,
    "McKinley Wright IV": 4278507,
    "Meleek Thomas": 5041951,
    "Micah Peavy": 4432185,
    "Micah Potter": 4066399,
    "Michael Cobbins": 2530751,
    "Michael Porter Jr.": 4278104,
    "Mikal Bridges": 3147657,
    "Mike Conley": 3195,
    "Mike James": 2528096,
    "Mike Tobey": 2982337,
    "Mikel Brown Jr.": 5101761,
    "Miles Bridges": 4066383,
    "Miles McBride": 4431823,
    "Mindaugas Kuzminskas": 3138120,
    "Mitchell Robinson": 4351852,
    "Mitchell Watt": 2328615,
    "MJ Walker": 4277854,
    "Mo Bamba": 4277919,
    "Mohamed Diawara": 5289900,
    "Monta Ellis": 2751,
    "Monte Morris": 3059310,
    "Morez Johnson Jr.": 4873153,
    "Moritz Wagner": 3150844,
    "Moses Moody": 4432171,
    "Moses Wright": 4277871,
    "Mouhamed Gueye": 4712863,
    "Moussa Cisse": 4701208,
    "Moussa Diabate": 4433249,
    "Myles Turner": 3133628,
    "Myron Gardner": 4431772,
    "Nae'Qwan Tomlin": 5106268,
    "Naji Marshall": 4278594,
    "Nate Ament": 5164559,
    "Nate Williams": 4397821,
    "Nate Wolters": 2491079,
    "Naz Mitrou-Long": 2990968,
    "Naz Reid": 4396971,
    "Neemias Queta": 4397424,
    "Nic Claxton": 4278067,
    "Nick Martinelli": 5105832,
    "Nick Richards": 4278076,
    "Nick Smith Jr.": 4683686,
    "Nickeil Alexander-Walker": 4278039,
    "Nicolas Batum": 3416,
    "Nicolo Melli": 4341,
    "Nigel Hayes-Davis": 3059409,
    "Nikola Durisic": 5144067,
    "Nikola Jokic": 3112335,
    "Nikola Jovic": 4997528,
    "Nikola Milutinov": 3892893,
    "Nikola Radicevic": 3902065,
    "Nikola Topic": 5159925,
    "Nikola Vucevic": 6478,
    "Nique Clifford": 4702384,
    "Noa Essengue": 5242496,
    "Noah Clowney": 4712896,
    "Noah Penda": 5214637,
    "Nolan Traore": 5279130,
    "Norchad Omier": 4702134,
    "Norman Powell": 2595516,
    "Obi Toppin": 4278355,
    "Ochai Agbaji": 4397018,
    "OG Anunoby": 3934719,
    "Ognjen Jaramaz": 4017857,
    "Okaro White": 2528473,
    "Olivier Sarr": 4278046,
    "Olivier-Maxence Prosper": 4595400,
    "Omer Yurtseven": 3074213,
    "Onyeka Okongwu": 4431680,
    "Oscar Tshiebwe": 4432827,
    "Oso Ighodaro": 4601023,
    "Otega Oweh": 5106270,
    "Ousmane Dieng": 4997526,
    "P.J. Tucker": 3033,
    "P.J. Washington": 4278078,
    "Pacome Dadiet": 5211983,
    "Paolo Banchero": 4432573,
    "Pascal Siakam": 3149673,
    "Pat Connaughton": 2578239,
    "Pat Spencer": 4592714,
    "Patric Young": 2527926,
    "Patrick Williams": 4431687,
    "Patty Mills": 4004,
    "Paul George": 4251,
    "Paul Reed": 4278562,
    "Paul Watson": 3058030,
    "Paul Zipser": 3893023,
    "Payton Pritchard": 4066354,
    "Pelle Larsson": 4601025,
    "Pete Nance": 4397233,
    "Peyton Watson": 4576087,
    "Precious Achiuwa": 4431679,
    "Quentin Grimes": 4397014,
    "Quenton Jackson": 4592829,
    "Quinn Cook": 2566745,
    "Quinten Post": 4593016,
    "Rade Zagorac": 3893060,
    "Rakeem Christmas": 2596110,
    "Rashad Vaughn": 3137733,
    "Rasheer Fleming": 5105977,
    "Rayan Rupert": 5099752,
    "Reed Sheppard": 4711272,
    "Reggie Jackson": 6443,
    "Richaun Holmes": 2993370,
    "Richie Saunders": 5105462,
    "Riley Minix": 5177362,
    "RJ Barrett": 4395625,
    "Rob Dillingham": 4684275,
    "Robert Covington": 2490620,
    "Robert Williams III": 4066211,
    "Rocco Zikarsky": 5157587,
    "Ron Baker": 2580349,
    "Ron Harper Jr.": 4397251,
    "Ronald Holland II": 4683771,
    "Royce O'Neale": 2583632,
    "Rudy Gobert": 3032976,
    "Rui Hachimura": 4066648,
    "Russell Westbrook": 3468,
    "Ryan Broekhoff": 2489693,
    "Ryan Conwell": 5107157,
    "Ryan Dunn": 4888725,
    "Ryan Kalkbrenner": 4576060,
    "Ryan Nembhard": 4433629,
    "Ryan Rollins": 4591725,
    "Saddiq Bey": 4397136,
    "Sam Hauser": 4065804,
    "Sam Merrill": 4066757,
    "Sandro Mamukelashvili": 4278580,
    "Santi Aldama": 4593125,
    "Satnam Singh Bhamara": 3902067,
    "Scoot Henderson": 4683678,
    "Scottie Barnes": 4433134,
    "Scotty Hopson": 2328418,
    "Scotty Pippen Jr.": 4431785,
    "Sean Kilpatrick": 2488689,
    "Semaj Christon": 2983526,
    "Sergio de Larrea": 5279129,
    "Seth Curry": 2326307,
    "Shabazz Muhammad": 2993875,
    "Shaedon Sharpe": 4914336,
    "Shai Gilgeous-Alexander": 4278073,
    "Shake Milton": 3915195,
    "Sharife Cooper": 4432173,
    "Shawn Long": 2581180,
    "Shayne Whittington": 2491063,
    "Sidy Cissoko": 5081727,
    "Sim Bhullar": 2596402,
    "Simone Fontecchio": 3899664,
    "Sion James": 4602025,
    "Spencer Dinwiddie": 2580782,
    "Spencer Jones": 4592427,
    "Stephen Curry": 3975,
    "Stephon Castle": 4845367,
    "Steven Adams": 2991235,
    "Svi Mykhailiuk": 3133602,
    "T.J. McConnell": 2530530,
    "Tacko Fall": 3904625,
    "Taj Gibson": 3986,
    "Tamar Bates": 4683933,
    "Tari Eason": 4433192,
    "Tarik Biberovic": 5148538,
    "Tarris Reed Jr.": 5105809,
    "Taurean Prince": 2990962,
    "Taylor Hendricks": 4684806,
    "Terance Mann": 3907823,
    "Terrence Shannon Jr.": 4432847,
    "Terry Rozier": 3074752,
    "Terry Taylor": 4279815,
    "Thanasis Antetokounmpo": 3102533,
    "Thomas Bryant": 3934723,
    "Thomas Sorber": 5061603,
    "Tidjane Salaun": 5211176,
    "Tim Frazier": 2488945,
    "Tim Hardaway Jr.": 2528210,
    "Tim Quarterman": 4064730,
    "Tobi Lawal": 5106040,
    "Tobias Harris": 6440,
    "Torrey Craig": 2528693,
    "Toumani Camara": 4431736,
    "Trae Young": 4277905,
    "Trayce Jackson-Davis": 4431684,
    "Tre Johnson": 5238230,
    "Tre Jones": 4395626,
    "Tre Mann": 4432819,
    "Trendon Watford": 4431675,
    "Trevon Brazile": 4698719,
    "Trey Jemison III": 4395623,
    "Trey Kaufman-Renn": 4897438,
    "Trey Lyles": 3136196,
    "Trey Murphy III": 4397688,
    "Tristan da Silva": 4702382,
    "Tristan Enaruna": 4431734,
    "Tristan Thompson": 6474,
    "Tristan Vukcevic": 4997537,
    "Troy Williams": 3078286,
    "Ty Jerome": 4065733,
    "Ty-Shon Alexander": 4278555,
    "Tyler Bilodeau": 5105626,
    "Tyler Cavanaugh": 2982349,
    "Tyler Davis": 3947078,
    "Tyler Ennis": 3059281,
    "Tyler Herro": 4395725,
    "Tyler Kolek": 4433225,
    "Tyler Nickel": 4838721,
    "Tyrese Haliburton": 4396993,
    "Tyrese Martin": 4397179,
    "Tyrese Maxey": 4431678,
    "Tyrese Proctor": 5023693,
    "TyTy Washington Jr.": 4683749,
    "Tyus Jones": 3135046,
    "Udonis Haslem": 2184,
    "Ugonna Onyenso": 5037878,
    "Vander Blue": 2531039,
    "Vasilije Micic": 3102532,
    "Victor Wembanyama": 5104157,
    "Vince Shamar Hunter": 3057304,
    "Vince Williams Jr.": 4397227,
    "Vincent Poirier": 4237215,
    "Vit Krejci": 4578893,
    "VJ Edgecombe": 5124612,
    "Vladislav Goldin": 4700818,
    "Walker Kessler": 4433136,
    "Walt Lemon Jr.": 2528586,
    "Walter Clayton Jr.": 4896372,
    "Wang Zhelin": 4017850,
    "Wayne Selden": 3059316,
    "Wendell Carter Jr.": 4277847,
    "Wesley Matthews": 4032,
    "Will Cherry": 2489897,
    "Will Richard": 4897262,
    "Will Riley": 5144126,
    "Willie Reed": 2326015,
    "Xavier Munford": 2983512,
    "Xavier Rathan-Mayes": 3059247,
    "Xavier Tillman": 4277964,
    "Yang Hansen": 5217746,
    "Yanic Konan Niederhauser": 5108024,
    "Yaxel Lendeborg": 5175737,
    "Yongxi Cui": 5159486,
    "Yuki Kawamura": 5159895,
    "Yves Missi": 5061589,
    "Zaccharie Risacher": 5211175,
    "Zach Collins": 4066650,
    "Zach Edey": 4600663,
    "Zach LaVine": 3064440,
    "Zeke Nnaji": 4431690,
    "Zhou Qi": 3892894,
    "Ziaire Williams": 4433137,
    "Zion Williamson": 4395628,
    "Zoran Dragic": 2560823,
    "Zuby Ejiofor": 5106262,
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

def status_block(c, x, y, p, tag):
    """Stat slot for a player with no numbers: the injury if he has one, else INACTIVE / NO STATS."""
    inj = p["inj"]
    if inj:
        word, color = inj["tag"], inj["color"]
        lines = [(inj["part"], "white"), (("BACK " + inj["back"]) if inj["back"] else "", "gray")]
    elif p.get("inactive"):
        word, color, lines = "INACTIVE", "gray", [("", "gray"), ("", "gray")]
    else:
        word, color, lines = "NO STATS", "gray", [(tag, "gray"), ("", "gray")]
    hf = "9x12"
    sw = max([c.text_width(t, "4x5") for (t, _) in lines])
    if x + c.text_width(word, hf) + 3 + sw > 127:
        hf = "7x12"
    c.text(word, x, y, font = hf, color = color)
    sx = x + c.text_width(word, hf) + 3
    for i in range(len(lines)):
        t, col = lines[i]
        if t and sx + c.text_width(t, "4x5") <= 127:
            c.text(t, sx, y + 1 + i * 6, font = "4x5", color = col)

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

LEAGUE = "nba"
DEFAULT_PLAYER = "Nikola Jokic"
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
        "inactive": (a.get("status") or {}).get("type") == "inactive",
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
    stats = season_stats(ov, p)
    c.clear()
    draw_gear(c, p["lg"], p["num"], p["color"], p["alt"], p["logo"])
    name_and_logo(c, 35, p["last"], p["logo"], "")
    ac = accent(p["color"], p["alt"])
    # the logo names the team, so the bio line starts at the position
    meta_line(c, 35, 12, "" if p["logo"] else p["team"], p["pos"], p["ft"], p["in"], p["lbs"], ac, p["inj"])
    tag = szn_tag(p, next_event(ov, ctx.now.unix))
    if stats:
        stat_block(c, 35, 19, stats, tag, "gray", ac)
    else:
        status_block(c, 35, 19, p, tag)

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
        szn = season_stats(ov, p)
        if szn:
            stat_block(c, 35, 19, szn, szn_tag(p, None), "gray", ac)
        else:
            status_block(c, 35, 19, p, szn_tag(p, None))
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
    szn = season_stats(ov, p)
    inj = p["inj"]
    if not szn and (inj or p.get("inactive")):
        # nothing to show but his status: injured with no games yet, or inactive
        status_block(c, 35, 19, p, szn_tag(p, ev))
        return
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
        if szn:
            stat_block(c, 35, 19, szn, szn_tag(p, ev), "gray", ac)
        else:
            status_block(c, 35, 19, p, szn_tag(p, ev))
