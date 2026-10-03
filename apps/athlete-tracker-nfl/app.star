# Athlete Tracker (NFL): a football helmet in team colours with the player's
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
}

# logo sizes that are not 19x19 (w, h)
LOGO_SIZE = {
    "nfl_ari": (22, 19),
    "nfl_atl": (26, 19),
    "nfl_bal": (26, 12),
    "nfl_buf": (26, 17),
    "nfl_car": (26, 17),
    "nfl_chi": (19, 19),
    "nfl_cin": (26, 18),
    "nfl_cle": (26, 19),
    "nfl_dal": (20, 19),
    "nfl_den": (26, 13),
    "nfl_det": (25, 19),
    "nfl_gb": (26, 17),
    "nfl_hou": (21, 19),
    "nfl_ind": (18, 19),
    "nfl_jax": (25, 16),
    "nfl_kc": (26, 16),
    "nfl_lac": (26, 11),
    "nfl_lar": (26, 19),
    "nfl_lv": (20, 19),
    "nfl_mia": (26, 18),
    "nfl_min": (15, 19),
    "nfl_ne": (26, 12),
    "nfl_no": (19, 19),
    "nfl_nyg": (24, 19),
    "nfl_nyj": (26, 16),
    "nfl_phi": (26, 18),
    "nfl_pit": (19, 19),
    "nfl_sea": (26, 13),
    "nfl_sf": (26, 15),
    "nfl_tb": (26, 19),
    "nfl_ten": (19, 19),
    "nfl_wsh": (26, 14),
}

# ---------------------------------------------------------------- players
# The dropdown label the user picked -> (league, ESPN athlete id).

# BEGIN PLAYERS (generated by tools/athlete_tracker_players.py; do not edit by hand)
PLAYERS = {
    "A.J. Brown": 4047646,
    "Aaron Jones Sr.": 3042519,
    "Aaron Rodgers": 8439,
    "Adam Prentice": 3929914,
    "Adam Randall": 4685526,
    "Adam Thielen": 16460,
    "Adam Trautman": 3911853,
    "Adonai Mitchell": 4597500,
    "Adrian Martinez": 4361182,
    "Aidan O'Connell": 4260394,
    "AJ Barner": 4576297,
    "AJ Dillon": 4239934,
    "AJ Henning": 4429053,
    "Alec Ingold": 3917668,
    "Alec Pierce": 4360078,
    "Alvin Kamara": 3054850,
    "Amar Johnson": 4878878,
    "Amari Cooper": 2976499,
    "Ameer Abdullah": 2576336,
    "Amon-Ra St. Brown": 4374302,
    "Anders Carlson": 4242519,
    "Andre Szmyt": 4258620,
    "Andrei Iosivas": 4368003,
    "Andrew Beck": 3125107,
    "Andy Borregales": 4569923,
    "Andy Dalton": 14012,
    "Anthony Gould": 4429684,
    "Anthony Richardson Sr.": 4429084,
    "Anthony Smith": 4685110,
    "Antonio Gibson": 4360294,
    "Antonio Williams": 5081432,
    "Arian Smith": 4429105,
    "Ashton Dulin": 4061956,
    "Ashton Jeanty": 4890973,
    "Athan Kaliakmanis": 4432722,
    "Audric Estime": 4569682,
    "Austin Ekeler": 3068267,
    "Austin Hooper": 3043275,
    "Austin Seibert": 3821683,
    "Baker Mayfield": 3052587,
    "Bam Knight": 4427728,
    "Barion Brown": 4698597,
    "Bauer Sharp": 4890373,
    "Beaux Collins": 4431210,
    "Behren Morton": 4431465,
    "Ben Sauls": 4566158,
    "Ben Sinnott": 4690923,
    "Ben Skowronek": 4035656,
    "Ben VanSumeren": 4372070,
    "Ben Yurosek": 4433959,
    "Bhayshul Tuten": 4882093,
    "Bijan Robinson": 4430807,
    "Blake Corum": 4429096,
    "Blake Grupe": 4259619,
    "Blake Whiteheart": 4362018,
    "Bo Melton": 4259305,
    "Bo Nix": 4426338,
    "Brady Cook": 4429435,
    "Brady Russell": 4243176,
    "Braelon Allen": 4685247,
    "Brandin Cooks": 16731,
    "Brandon Aiyuk": 4360438,
    "Brandon Allen": 2574511,
    "Brandon Aubrey": 3953687,
    "Brandon McManus": 16339,
    "Brandon Powell": 3115255,
    "Brashard Smith": 4596602,
    "Braxton Berrios": 3123075,
    "Brayden Narveson": 4361765,
    "Brayden Willis": 4360290,
    "Breece Hall": 4427366,
    "Brenen Thompson": 4685553,
    "Brennan Presley": 4431342,
    "Brenton Strange": 4430539,
    "Brevin Jordan": 4362504,
    "Brevyn Spann-Ford": 4360967,
    "Brian Robinson Jr.": 4241474,
    "Brian Thomas Jr.": 4432773,
    "Britain Covey": 3926231,
    "British Brooks": 4373273,
    "Brittain Brown": 4036032,
    "Brock Bowers": 4432665,
    "Brock Purdy": 4361741,
    "Brock Wright": 4242392,
    "Bryce Lance": 4879276,
    "Bryce Young": 4685720,
    "Brycen Tremayne": 4360763,
    "Bub Means": 4427985,
    "Bucky Irving": 4596448,
    "C.J. Ham": 4012556,
    "C.J. Stroud": 4432577,
    "Cade Klubnik": 4685413,
    "Cade Otton": 4243331,
    "Cade Stover": 4426496,
    "Cade York": 4428963,
    "Caden Davis": 4570688,
    "Cairo Santos": 17427,
    "Caleb Douglas": 4869645,
    "Caleb Williams": 4431611,
    "Calvin Austin III": 4243389,
    "Calvin Ridley": 3925357,
    "Cam Little": 4686361,
    "Cam Skattebo": 4696981,
    "Cam Ward": 4688380,
    "Camden Brown": 4808759,
    "Cameron Dicker": 4362081,
    "Cameron Latu": 4372026,
    "Carnell Tate": 4871023,
    "Carsen Ryan": 4685540,
    "Carson Beck": 4430841,
    "Carson Steele": 4714365,
    "Carson Wentz": 2573079,
    "Case Keenum": 15168,
    "Cedric Tillman": 4369863,
    "Cedrick Wilson Jr.": 4036335,
    "CeeDee Lamb": 4241389,
    "Chad Ryland": 4363538,
    "Chandler Brayboy": 4573243,
    "Charlie Jones": 4257188,
    "Charlie Kolar": 4241263,
    "Charlie Smyth": 5208518,
    "Charlie Woerner": 4035020,
    "Chase Brown": 4362238,
    "Chase Edmonds": 3119195,
    "Chase McLaughlin": 3150744,
    "Chig Okonkwo": 4360635,
    "Chimere Dike": 4431268,
    "Chris Bell": 4869961,
    "Chris Blair": 4369886,
    "Chris Boswell": 17372,
    "Chris Brazzell II": 5091739,
    "Chris Brooks": 3149687,
    "Chris Collier": 4698191,
    "Chris Godwin Jr.": 3116165,
    "Chris Manhertz": 2531358,
    "Chris Moore": 2576581,
    "Chris Olave": 4361370,
    "Chris Rodriguez Jr.": 4362619,
    "Christian Kirk": 3895856,
    "Christian McCaffrey": 3117251,
    "Christian Watson": 4248528,
    "Christopher Dunn": 4361665,
    "Chuba Hubbard": 4241416,
    "CJ Daniels": 4605951,
    "CJ Donaldson": 5081999,
    "CJ Williams": 5085024,
    "Clayton Tune": 4360175,
    "Cody White": 4241983,
    "Colbie Young": 5092508,
    "Colby Parkinson": 4242557,
    "Cole Kmet": 4258595,
    "Cole Payton": 4879250,
    "Colson Yankoff": 4361088,
    "Colston Loveland": 4723086,
    "Connor Heyward": 4241961,
    "Cooper Kupp": 2977187,
    "Cooper Rush": 2972515,
    "Cordarrelle Patterson": 15807,
    "Corey Kiner": 4431431,
    "Courtland Sutton": 3128429,
    "Craig Reynolds": 4421446,
    "Cyrus Allen": 4912218,
    "D'Andre Swift": 4259545,
    "D'Ernest Johnson": 3139602,
    "D.J. Montgomery": 4249030,
    "Dak Prescott": 2577417,
    "Dallas Goedert": 3121023,
    "Dalton Kincaid": 4385690,
    "Dalton Schultz": 3117256,
    "Dalvin Cook": 3116593,
    "Dameon Pierce": 4360238,
    "Damien Martinez": 4808830,
    "Daniel Bellinger": 4361516,
    "Daniel Carlson": 3051909,
    "Daniel Jones": 3917792,
    "Dante Pettis": 3127306,
    "Dare Ogunbowale": 2983509,
    "Dareke Young": 4401805,
    "Darius Cooper": 4715355,
    "Darius Slayton": 3916945,
    "Darnell Mooney": 4040655,
    "Darnell Washington": 4430802,
    "Darren Waller": 2576925,
    "Davante Adams": 16800,
    "David Montgomery": 4035538,
    "David Moore": 4212909,
    "David Njoku": 3123076,
    "Davis Allen": 4426553,
    "Davis Mills": 4242546,
    "Dawson Knox": 3930086,
    "De'Von Achane": 4429160,
    "De'Zhaun Stribling": 4710714,
    "DeAndre Hopkins": 15795,
    "Deebo Samuel Sr.": 3126486,
    "DeeJay Dallas": 4240631,
    "Deion Burks": 4683151,
    "Demarcus Robinson": 3043116,
    "DeMario Douglas": 4427095,
    "Demond Claiborne": 4832846,
    "Deneric Prince": 4372526,
    "Dennis Houston": 4572786,
    "Denzel Boston": 4832800,
    "Derek Carr": 16757,
    "Derius Davis": 4362477,
    "Derrick Henry": 3043078,
    "Deshaun Watson": 3122840,
    "Desmond Ridder": 4239086,
    "Deuce Vaughn": 4431453,
    "Devaughn Vele": 4569559,
    "Devin Duvernay": 4039050,
    "Devin Leary": 4361653,
    "Devin Neal": 4682652,
    "Devin Singletary": 4040761,
    "DeVonta Smith": 4241478,
    "Devontez Walker": 4696882,
    "DeWayne McBride": 4430388,
    "Dillon Gabriel": 4427238,
    "DJ Giddens": 4874509,
    "DJ Moore": 3915416,
    "DK Metcalf": 4047650,
    "Dohnte Meyers": 4384852,
    "Dominic Zvada": 5082424,
    "Donovan Edwards": 4431536,
    "Dont'e Thornton Jr.": 4432775,
    "Dontayvion Wicks": 4428850,
    "Drake Dabney": 4429466,
    "Drake London": 4426502,
    "Drake Maye": 4431452,
    "Drew Allar": 4714771,
    "Drew Lock": 3924327,
    "Drew Ogletree": 4722908,
    "Drew Sample": 3127310,
    "Drew Stevens": 5081335,
    "Durham Smythe": 3052897,
    "Dustin Hopkins": 15965,
    "Dyami Brown": 4361577,
    "Dylan Laube": 4366963,
    "Dylan Sampson": 5081397,
    "Easton Stick": 3120590,
    "Eddy Pineiro": 4034949,
    "Efton Chism III": 4695193,
    "Eli Heidenreich": 5081508,
    "Eli Raridon": 4831959,
    "Eli Stowers": 4431574,
    "Elic Ayomanor": 4883647,
    "Elijah Arroyo": 4678006,
    "Elijah Higgins": 4426844,
    "Elijah Mitchell": 4241555,
    "Elijah Moore": 4372414,
    "Elijah Sarratt": 5088338,
    "Emanuel Wilson": 4887558,
    "Emari Demercado": 4362478,
    "Emeka Egbuka": 4567750,
    "Emmanuel Henderson Jr.": 4685381,
    "Emmett Johnson": 4832955,
    "Equanimeous St. Brown": 3932442,
    "Eric Gray": 4570561,
    "Eric Saubert": 2975863,
    "Erick All Jr.": 4427834,
    "Evan Engram": 3051876,
    "Evan McPherson": 4360234,
    "Ezekiel Elliott": 3051392,
    "Fernando Mendoza": 4837248,
    "Foster Moreau": 3843945,
    "Frank Gore Jr.": 4429805,
    "Gabe Davis": 4243537,
    "Gardner Minshew II": 4038524,
    "Garrett Nussmeier": 4567747,
    "Garrett Wilson": 4569618,
    "Gary Brightwell": 4245645,
    "Gavin Bartholomew": 4708049,
    "Geno Smith": 15864,
    "George Holani": 4429835,
    "George Kittle": 3040151,
    "George Pickens": 4426354,
    "Germie Bernard": 4685261,
    "Graham Gano": 12460,
    "Grant Calcaterra": 4241374,
    "Greg Dortch": 4037235,
    "Greg Dulcich": 4367209,
    "Greg Joseph": 3975763,
    "Greg Zuerlein": 14993,
    "Gunnar Helm": 4686728,
    "Gunner Olszewski": 4424106,
    "Harold Fannin Jr.": 5083076,
    "Harrison Butker": 3055899,
    "Harrison Mevis": 4574716,
    "Hassan Haskins": 4372071,
    "Haynes King": 4428993,
    "Hendon Hooker": 4240858,
    "Hollywood Brown": 4241372,
    "Hunter Henry": 3046439,
    "Hunter Long": 4239944,
    "Hunter Luepke": 4383396,
    "Hunter Renfrow": 3135321,
    "Ian Thomas": 4045305,
    "Irv Charles": 3929636,
    "Isaac Guerendo": 4372561,
    "Isaac TeSlaa": 5123663,
    "Isaiah Bond": 4808839,
    "Isaiah Davis": 4695404,
    "Isaiah Likely": 4361050,
    "Isaiah Williams": 4569371,
    "Isiah Pacheco": 4361529,
    "Israel Abanikanda": 4429202,
    "J. Michael Sturdivant": 4635009,
    "J.J. McCarthy": 4433970,
    "J.J. Taylor": 4039607,
    "J.K. Dobbins": 4241985,
    "Ja'Corey Brooks": 4431506,
    "Ja'Kobi Lane": 4870847,
    "Ja'Marr Chase": 4362628,
    "Ja'Tavion Sanders": 4431588,
    "Jacardia Wright": 4428943,
    "Jack Bech": 4603186,
    "Jack Endries": 5085189,
    "Jack Strand": 5344782,
    "Jackson Hawes": 4573699,
    "Jackson Meeks": 4602788,
    "Jacob Cowing": 4575665,
    "Jacob Kibodi": 4240911,
    "Jacob Saylors": 4383429,
    "Jacoby Brissett": 2578570,
    "Jacory Croskey-Merritt": 4575131,
    "Jadarian Price": 4685512,
    "Jahan Dotson": 4361409,
    "Jahdae Walker": 5160110,
    "Jahmyr Gibbs": 4429795,
    "Jake Bates": 4689936,
    "Jake Bobo": 4360405,
    "Jake Browning": 3886812,
    "Jake Elliott": 3050478,
    "Jake Ferguson": 4242355,
    "Jake Haener": 4243322,
    "Jake Moody": 4372066,
    "Jake Tonges": 4259147,
    "Jakobi Meyers": 3916433,
    "Jakobie Keeney-James": 5178972,
    "Jaleel McLaughlin": 4722893,
    "Jalen Brooks": 4692835,
    "Jalen Coker": 4695883,
    "Jalen Hurts": 4040715,
    "Jalen McMillan": 4430834,
    "Jalen Milroe": 4432734,
    "Jalen Nailor": 4382466,
    "Jalen Royals": 5082630,
    "Jalen Tolbert": 4249417,
    "Jalon Daniels": 4596472,
    "Jam Miller": 4685477,
    "Jamaal Williams": 2980453,
    "Jamal Agnew": 3061612,
    "Jameis Winston": 2969939,
    "James Conner": 3045147,
    "James Cook III": 4379399,
    "Jameson Williams": 4426388,
    "Jared Goff": 3046779,
    "Jared Wayne": 4430681,
    "Jared Wiley": 4430723,
    "Jaret Patterson": 4362452,
    "Jarquez Hunter": 4710341,
    "Jarrett Stidham": 3892775,
    "Jason Myers": 2473037,
    "Jason Sanders": 3124679,
    "Jauan Jennings": 3886598,
    "Javonte Williams": 4361579,
    "Jawhar Jordan": 4429939,
    "Jaxon Smith-Njigba": 4430878,
    "Jaxson Dart": 4689114,
    "Jayden Daniels": 4426348,
    "Jayden Higgins": 4877706,
    "Jayden Reed": 4362249,
    "Jaydon Blue": 4685279,
    "Jaylen Waddle": 4372016,
    "Jaylen Warren": 4569987,
    "Jaylen Wright": 4682745,
    "Jaylin Lane": 4602667,
    "Jaylin Noel": 4586312,
    "Jelani Woods": 4241410,
    "Jeremiyah Love": 4870808,
    "Jeremy McNichols": 3127586,
    "Jeremy Ruckert": 4361372,
    "Jermar Jefferson": 4374033,
    "Jerome Ford": 4372019,
    "Jerry Jeudy": 4241463,
    "Jeshaun Jones": 4360637,
    "Jimmy Garoppolo": 16760,
    "Jimmy Holiday": 4431142,
    "Jimmy Horn Jr.": 4708486,
    "Joe Burrow": 3915511,
    "Joe Fagnano": 4429582,
    "Joe Flacco": 11252,
    "Joe Milton III": 4360698,
    "Joe Mixon": 3116385,
    "Joe Royer": 4565859,
    "Joey Slye": 3124084,
    "John Bates": 4048228,
    "John Metchie III": 4567096,
    "Johnny Mundt": 3052096,
    "Jonah Coleman": 4702555,
    "Jonathan Mingo": 4426485,
    "Jonathan Taylor": 4242335,
    "Jonathon Brooks": 4678008,
    "Jonnu Smith": 3054212,
    "Jordan Addison": 4429205,
    "Jordan James": 4685397,
    "Jordan Love": 4036378,
    "Jordan Mason": 4360569,
    "Jordan Travis": 4360799,
    "Jordan Watkins": 4431466,
    "Jordan Whittington": 4569382,
    "Jordyn Tyson": 4880281,
    "Josh Allen": 3918298,
    "Josh Cameron": 4879194,
    "Josh Cuevas": 4876132,
    "Josh Downs": 4688813,
    "Josh Jacobs": 4047365,
    "Josh Johnson (CIN)": 11394,
    "Josh Johnson (FA)": 4390717,
    "Josh Oliver": 3921690,
    "Josh Whyle": 4360086,
    "Josh Williams": 4568024,
    "Joshua Dobbs": 3044720,
    "Joshua Karty": 4566192,
    "Joshua Palmer": 4242433,
    "Jude McAtamney": 5092436,
    "JuJu Smith-Schuster": 3120348,
    "Julius Chestnut": 4367567,
    "Justice Hill": 4038441,
    "Justin Fields": 4362887,
    "Justin Herbert": 4038941,
    "Justin Jefferson": 4262921,
    "Justin Joly": 4912052,
    "Justin Tucker": 15683,
    "Justin Watson": 3118892,
    "Juwan Johnson": 3929645,
    "Ka'imi Fairbairn": 2971573,
    "Kadarius Toney": 4240600,
    "Kaden Wetjen": 5081338,
    "Kaelon Black": 4696044,
    "Kaleb Johnson": 4819231,
    "Kalif Raymond": 2973405,
    "Kameron Johnson": 5097554,
    "Kareem Hunt": 3059915,
    "KaVontae Turpin": 3676833,
    "Kayshon Boutte": 4429022,
    "Kaytron Allen": 4685246,
    "KC Concepcion": 4870653,
    "Ke'Shawn Vaughn": 3917612,
    "Ke'Shawn Williams": 4570738,
    "KeAndre Lambert-Smith": 4430870,
    "Keaton Mitchell": 4596334,
    "Kedon Slovis": 4428512,
    "Keenan Allen": 15818,
    "Keilan Robinson": 4567095,
    "Kendre Miller": 4599739,
    "Kendrick Bourne": 3045523,
    "Kendrick Law": 4685441,
    "Kene Nwangwu": 4035537,
    "Kenneth Walker III": 4567048,
    "Kenny Gainwell": 4371733,
    "Kenny McIntosh": 4427391,
    "Kenny Pickett": 4240703,
    "Kenyon Sadiq": 5083315,
    "Keon Coleman": 4635008,
    "Kevin Coleman Jr.": 4685307,
    "KhaDarel Hodge": 3047876,
    "Khalil Shakir": 4373678,
    "Kimani Vidal": 4430968,
    "Kirk Cousins": 14880,
    "Ko Kieft": 4034779,
    "Konata Mumpfield": 4710855,
    "Kyle Allen": 3115293,
    "Kyle Juszczyk": 16002,
    "Kyle McCord": 4433971,
    "Kyle Monangai": 4608686,
    "Kyle Pitts Sr.": 4360248,
    "Kyle Williams": 4613202,
    "Kyler Murray": 3917315,
    "Kyren Williams": 4430737,
    "Ladd McConkey": 4612826,
    "LaJohntay Wester": 4690143,
    "Lamar Jackson": 3916387,
    "Lan Larison": 4698253,
    "Laquon Treadwell": 3051889,
    "LeQuint Allen Jr.": 4911851,
    "Lewis Bond": 4683159,
    "Lil'Jordan Humphrey": 4039057,
    "Lucas Havrisik": 4245661,
    "Lucas Krull": 4360231,
    "Luke Farrell": 4040612,
    "Luke Lachey": 4432338,
    "Luke McCaffrey": 4426948,
    "Luke Musgrave": 4428085,
    "Luke Schoonmaker": 4372096,
    "Luther Burden III": 4685278,
    "Mac Jones": 4241464,
    "Mack Hollins": 2991662,
    "Makai Lemon": 4870795,
    "Malachi Corley": 4613104,
    "Malachi Fields": 4682648,
    "Malik Benson": 5150247,
    "Malik Davis": 4240603,
    "Malik Nabers": 4595348,
    "Malik Washington": 4569603,
    "Malik Willis": 4242512,
    "Marcedes Lewis": 9614,
    "Marcus Mariota": 2576980,
    "Mark Andrews": 3116365,
    "Mark Redman": 4431346,
    "Marlin Klein": 4695705,
    "Marquez Valdes-Scantling": 3051738,
    "MarShawn Lloyd": 4429023,
    "Marvin Harrison Jr.": 4432708,
    "Marvin Mims Jr.": 4686472,
    "Mason Kinsey": 4057082,
    "Mason Rudolph": 3116407,
    "Mason Taylor": 4808766,
    "Mason Tipton": 4573697,
    "Matt Gay": 4249087,
    "Matt Prater": 11122,
    "Matthew Golden": 4701936,
    "Matthew Hibner": 4432260,
    "Matthew Stafford": 12483,
    "Matthew Wright": 3128444,
    "Max Bredeson": 4878695,
    "Max Brosmer": 4573398,
    "Max Klare": 4833029,
    "Michael Badgley": 3123052,
    "Michael Bandy": 4034704,
    "Michael Burton": 2515270,
    "Michael Carter": 4240657,
    "Michael Mayer": 4429086,
    "Michael Penix Jr.": 4360423,
    "Michael Pittman Jr.": 4035687,
    "Michael Pratt": 4685039,
    "Michael Trigg": 4594749,
    "Michael Wiley": 4569156,
    "Michael Wilson": 4360761,
    "Mike Boone": 3139033,
    "Mike Evans": 16737,
    "Mike Gesicki": 3116164,
    "Mike Washington Jr.": 4686658,
    "Mike White": 3051381,
    "Mike Williams": 3045138,
    "Mitchell Evans": 4683243,
    "Mitchell Tinsley": 4690070,
    "Mitchell Trubisky": 3039707,
    "Mo Alie-Cox": 2998565,
    "Montorie Foster Jr.": 4600597,
    "Myles Gaskin": 3886818,
    "Myles Price": 4430656,
    "Najee Harris": 4241457,
    "Nate Adkins": 4383440,
    "Nate Boerkircher": 4686248,
    "Nathan Carter": 4605841,
    "Nelson Agholor": 2971618,
    "Nicholas Singleton": 4685555,
    "Nick Chubb": 3128720,
    "Nick Folk": 10621,
    "Nick Mullens": 3059989,
    "Nick Vannett": 2576399,
    "Nick Westbrook-Ikhine": 3929785,
    "Nico Collins": 4258173,
    "Nikko Remigio": 4372716,
    "Noah Brown": 3121409,
    "Noah Fant": 4036131,
    "Noah Gray": 4240472,
    "Odell Beckham Jr.": 16733,
    "Olamide Zaccheaus": 3917914,
    "Ollie Gordon II": 4711533,
    "Omar Cooper Jr.": 4723820,
    "Omarion Hampton": 4685382,
    "Oronde Gadsden": 4595342,
    "Oscar Delp": 4702559,
    "Owen Wright": 4249616,
    "Parker Romo": 4051167,
    "Parker Washington": 4432620,
    "Parris Campbell": 3121410,
    "Pat Bryant": 4600981,
    "Pat Freiermuth": 4361411,
    "Patrick Mahomes": 3139477,
    "Patrick Ricard": 2975417,
    "Payne Durham": 4372505,
    "Pharaoh Brown": 2971281,
    "Phil Mafah": 4431562,
    "Philip Rivers": 5529,
    "Pierre Strong Jr.": 4249836,
    "Puka Nacua": 4426515,
    "Quentin Johnston": 4429025,
    "Quez Watkins": 4050373,
    "Quinn Ewers": 4889929,
    "Quinshon Judkins": 4685702,
    "Rachaad White": 4697815,
    "Raheem Blackshear": 4259308,
    "Raheem Mostert": 2576414,
    "Raheim Sanders": 4601080,
    "Rashee Rice": 4428331,
    "Rasheen Ali": 4690013,
    "Rashid Shaheed": 4032473,
    "Rashod Bateman": 4360939,
    "Ray Davis": 4429501,
    "Ray-Ray McCloud III": 3728262,
    "Reggie Gilliam": 4039505,
    "Reggie Virgil": 4869132,
    "Rhamondre Stevenson": 4569173,
    "Ricky Pearsall": 4428209,
    "Rico Dowdle": 4038815,
    "Riley Leonard": 4683423,
    "Riley Nowakowski": 4693370,
    "Riley Patterson": 4243371,
    "RJ Harvey": 4568490,
    "Robbie Ouzts": 4691688,
    "Robert Tonyan": 2975674,
    "Roman Wilson": 4431492,
    "Rome Odunze": 4431299,
    "Romeo Doubs": 4361432,
    "Ronnie Rivers": 4243003,
    "Roschon Johnson": 4426386,
    "Russell Wilson": 14881,
    "Ryan Fitzgerald": 4568263,
    "Ryan Flournoy": 5083754,
    "Ryan Griffin": 16140,
    "Ryan Miller": 4369466,
    "Sal Cannella": 4242536,
    "Salvon Ahmed": 4243315,
    "Sam Darnold": 3912547,
    "Sam Ehlinger": 4241820,
    "Sam Howell": 4426875,
    "Sam LaPorta": 4430027,
    "Sam Roush": 4685504,
    "Samaje Perine": 3116389,
    "Saquon Barkley": 3929630,
    "SaRodorick Thompson Jr.": 4362162,
    "Savion Williams": 4431487,
    "Scott Matlock": 4373684,
    "Sean Clifford": 4259592,
    "Sean Tucker": 4430871,
    "Seth McGowan": 4686468,
    "Seydou Traore": 4714379,
    "Shedeur Sanders": 4432762,
    "Sione Vaki": 4912274,
    "Skylar Thompson": 4036419,
    "Skyler Bell": 4683153,
    "Skyy Moore": 4430191,
    "Spencer Rattler": 4426339,
    "Spencer Shrader": 4571557,
    "Stefon Diggs": 2976212,
    "Sterling Shepard": 2976592,
    "Stetson Bennett IV": 4259553,
    "T.J. Hockenson": 4036133,
    "Tahj Brooks": 4429299,
    "Tai Felton": 4565185,
    "Tank Bigsby": 4429013,
    "Tank Dell": 4366031,
    "Tanner Arkin": 4683308,
    "Tanner Brown": 4696736,
    "Tanner Koziol": 4917427,
    "Tanner McKee": 4685201,
    "Tay Martin": 4245144,
    "Taylen Green": 4431325,
    "Taylor Heinicke": 2565969,
    "Taysom Hill": 2468609,
    "Teagan Quitoriano": 4374045,
    "Ted Hurst III": 5220680,
    "Teddy Bridgewater": 16728,
    "Tee Higgins": 4239993,
    "Terrance Ferguson": 4570037,
    "Terrell Jennings": 4427600,
    "Terry McLaurin": 3121422,
    "Tetairoa McMillan": 4685472,
    "Tez Johnson": 4608810,
    "Theo Johnson": 4429148,
    "Tim Boyle": 3045169,
    "Tim Patrick": 3134353,
    "Tom Kennedy": 3126997,
    "Tommy DeVito": 4240391,
    "Tommy Tremble": 4372780,
    "Tony Pollard": 3916148,
    "Tory Horton": 4597703,
    "Travis Etienne Jr.": 4239996,
    "Travis Homer": 4037457,
    "Travis Hunter": 4685415,
    "Travis Kelce": 15847,
    "Trayveon Williams": 4035222,
    "Tre Tucker": 4428718,
    "Tre' Harris": 4686612,
    "TreVeyon Henderson": 4432710,
    "Trevor Etienne": 4685350,
    "Trevor Lawrence": 4360310,
    "Trey Benson": 4429275,
    "Trey Lance": 4383351,
    "Trey McBride": 4361307,
    "Trey Sermon": 4241401,
    "Trey Smack": 4869461,
    "Treylon Burks": 4567156,
    "Troy Franklin": 4431280,
    "Tua Tagovailoa": 4241479,
    "Tucker Kraft": 4572680,
    "Tutu Atwell": 4360797,
    "Ty Chandler": 4242431,
    "Ty Johnson": 3915411,
    "Ty Simpson": 4685522,
    "Tyjae Spears": 4428557,
    "Tylan Wallace": 4241424,
    "Tyler Allgeier": 4373626,
    "Tyler Badie": 4362748,
    "Tyler Bass": 3917232,
    "Tyler Conklin": 3915486,
    "Tyler Goodson": 4429676,
    "Tyler Higbee": 2573401,
    "Tyler Huntley": 4035671,
    "Tyler Johnson": 2310331,
    "Tyler Lockett": 2577327,
    "Tyler Loop": 4697745,
    "Tyler Shough": 4360689,
    "Tyler Warren": 4431459,
    "Tyquan Thornton": 4362921,
    "Tyreek Hill": 3116406,
    "Tyrell Shavers": 4241476,
    "Tyrod Taylor": 14163,
    "Tyrone Tracy Jr.": 4360516,
    "Tyson Bagent": 4434153,
    "Ulysses Bentley IV": 4426689,
    "Van Jefferson": 3930066,
    "Wan'Dale Robinson": 4569587,
    "Wil Lutz": 2985659,
    "Will Howard": 4429955,
    "Will Kacmarek": 4880236,
    "Will Levis": 4361418,
    "Will Reichard": 4567104,
    "Will Shipley": 4431545,
    "Woody Marks": 4429059,
    "Xavier Hutchinson": 4686422,
    "Xavier Legette": 4430034,
    "Xavier Restrepo": 4431353,
    "Xavier Smith": 4386544,
    "Xavier Worthy": 4683062,
    "Younghoe Koo": 3049899,
    "Zach Charbonnet": 4426385,
    "Zach Ertz": 15835,
    "Zach Horton": 4877824,
    "Zach Wilson": 4361259,
    "Zachariah Branch": 4870612,
    "Zaire Mitchell-Paden": 4876006,
    "Zamir White": 4361777,
    "Zane Gonzalez": 3043234,
    "Zavier Scott": 4257364,
    "Zavion Thomas": 4869748,
    "Zay Flowers": 4429615,
    "Zay Jones": 3059722,
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

LEAGUE = "nfl"
DEFAULT_PLAYER = "Patrick Mahomes"
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
