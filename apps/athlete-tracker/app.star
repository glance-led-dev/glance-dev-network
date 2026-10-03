# Athlete Tracker: a team-colour jersey / helmet sprite with the player's
# number, plus their bio line and live or season stats.

# ---------------------------------------------------------------- sprites
# P primary, D primary shade, L primary light, S secondary trim, W white,
# M facemask, E dark padding. The number is stamped on at runtime.

NBA_JERSEY = [
    "....SSSS............SSSS....",
    "....SPPS............SPPS....",
    "...SPPPS............SPPPS...",
    "...SPPPPS..........SPPPPS...",
    "..SPPPPPS..........SPPPPPS..",
    "..SPPPPPPS........SPPPPPPS..",
    ".SPPPPPPPPS......SPPPPPPPPS.",
    ".SPPPPPPPPPSS..SSPPPPPPPPPS.",
    ".SPPPPPPPPPPPSSPPPPPPPPPPPS.",
    ".SDLPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDLPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDLPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SDPPPPPPPPPPPPPPPPPPPPPPDS.",
    ".SSSSSSSSSSSSSSSSSSSSSSSSSS.",
    "..DDDDDDDDDDDDDDDDDDDDDDDD..",
]

NFL_HELMET = [
    "........SSSSSSSS..............",
    "......SSSSSSSSSSSS............",
    ".....SSPPPPPPPPPPSS...........",
    "....SPPPPPPPPPPPPLLS..........",
    "...SPPPPPPPPPPPPPPPLS.........",
    "..SPPPPPPPPPPPPPPPPPLS........",
    "..PPPPPPPPPPPPPPPPPPPPP.......",
    ".PPPPPPPPPPPPPPPPPPPPPP.......",
    ".PPPPPPPPPPPPPPPPPPPPPPP......",
    "PPPPPPPPPPPPPPPPPPPPPPPP......",
    "PPPPPPPPPPPPPPPPPPPPPPPP......",
    "PPPPPPPPPPPPPPPPPPPPPPPP......",
    "PPPPPPPPPPPPPPPPPPPPMMMMMMMMM.",
    "PPPPPPPPPPPPPPPPPPPE....M...M.",
    "PPPPPPPPPPPPPPPPPPPE....M...M.",
    "PPPPPPPPPPPEEPPPPPPE....M...M.",
    "PPPPPPPPPPPEEPPPPPPMMMMMMMMMM.",
    "DPPPPPPPPPPEEPPPPPPE....M...M.",
    "DDPPPPPPPPPPPPPPPPPE....M...M.",
    ".DDPPPPPPPPPPPPPPPPE....M...M.",
    ".DDDPPPPPPPPPPPPPPPMMMMMMMMMM.",
    "..DDDPPPPPPPPPPPPPPP.....MM...",
    "...DDDDPPPPPPPPPPPP...........",
    ".....DDD...DDDDDDD............",
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
    "nfl": {"art": NFL_HELMET, "digits": SMALL_DIGITS, "cx": 10, "top": 5, "x": 1, "y": 4},
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

# logo sizes that are not 19x19 (w, h)
LOGO_SIZE = {
    "mlb_ari": (19, 16),
    "mlb_ath": (19, 16),
    "mlb_atl": (19, 18),
    "mlb_bal": (19, 18),
    "mlb_bos": (13, 19),
    "mlb_chw": (13, 19),
    "mlb_cin": (19, 13),
    "mlb_cle": (12, 19),
    "mlb_col": (16, 19),
    "mlb_det": (13, 19),
    "mlb_laa": (13, 19),
    "mlb_lad": (13, 19),
    "mlb_mia": (19, 18),
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
    "mlb_tb": (19, 17),
    "mlb_tex": (17, 19),
    "mlb_tor": (19, 16),
    "nba_cha": (19, 18),
    "nba_chi": (19, 17),
    "nba_cle": (19, 16),
    "nba_hou": (14, 19),
    "nba_ind": (19, 18),
    "nba_lal": (19, 16),
    "nba_mem": (19, 18),
    "nba_mia": (18, 19),
    "nba_mil": (14, 19),
    "nba_no": (19, 7),
    "nba_ny": (19, 16),
    "nba_okc": (19, 11),
    "nba_orl": (19, 14),
    "nba_phi": (16, 19),
    "nba_phx": (19, 16),
    "nba_por": (17, 19),
    "nba_sa": (16, 19),
    "nba_sac": (17, 19),
    "nba_utah": (19, 13),
    "nfl_ari": (19, 18),
    "nfl_atl": (19, 18),
    "nfl_bal": (19, 9),
    "nfl_buf": (19, 13),
    "nfl_car": (19, 10),
    "nfl_cin": (19, 13),
    "nfl_cle": (19, 15),
    "nfl_dal": (19, 18),
    "nfl_den": (19, 10),
    "nfl_det": (19, 14),
    "nfl_gb": (19, 12),
    "nfl_hou": (19, 17),
    "nfl_ind": (18, 19),
    "nfl_jax": (19, 14),
    "nfl_kc": (19, 12),
    "nfl_lac": (19, 8),
    "nfl_lar": (19, 14),
    "nfl_lv": (18, 19),
    "nfl_mia": (19, 15),
    "nfl_min": (15, 19),
    "nfl_ne": (19, 9),
    "nfl_no": (16, 19),
    "nfl_nyg": (19, 15),
    "nfl_nyj": (19, 11),
    "nfl_phi": (19, 13),
    "nfl_sea": (19, 8),
    "nfl_sf": (19, 11),
    "nfl_tb": (19, 17),
    "nfl_wsh": (19, 11),
    "nhl_ana": (19, 17),
    "nhl_car": (19, 12),
    "nhl_cbj": (19, 17),
    "nhl_cgy": (19, 16),
    "nhl_chi": (19, 17),
    "nhl_col": (19, 16),
    "nhl_dal": (19, 16),
    "nhl_det": (19, 14),
    "nhl_fla": (17, 19),
    "nhl_la": (19, 12),
    "nhl_min": (19, 12),
    "nhl_mtl": (19, 13),
    "nhl_nsh": (19, 11),
    "nhl_nyi": (19, 18),
    "nhl_nyr": (19, 18),
    "nhl_ott": (19, 15),
    "nhl_phi": (19, 13),
    "nhl_pit": (19, 18),
    "nhl_sea": (15, 19),
    "nhl_sj": (19, 16),
    "nhl_stl": (19, 15),
    "nhl_tb": (19, 18),
    "nhl_tor": (17, 19),
    "nhl_utah": (19, 14),
    "nhl_van": (19, 18),
    "nhl_vgk": (14, 19),
    "nhl_wsh": (19, 15),
}

# ---------------------------------------------------------------- players
# The dropdown label the user picked -> (league, ESPN athlete id).

# BEGIN PLAYERS (generated by tools/athlete_tracker_players.py; do not edit by hand)
PLAYERS = {
    "A.J. Brown (NFL)": ("nfl", 4047646),
    "AJ Barner (NFL)": ("nfl", 4576297),
    "AJ Dybantsa (NBA)": ("nba", 5142718),
    "Aaron Gordon (NBA)": ("nba", 3064290),
    "Aaron Jones Sr. (NFL)": ("nfl", 3042519),
    "Aaron Judge (MLB)": ("mlb", 33192),
    "Aaron Nesmith (NBA)": ("nba", 4396909),
    "Aaron Nola (MLB)": ("mlb", 33709),
    "Aaron Rodgers (NFL)": ("nfl", 8439),
    "Aaron Wiggins (NBA)": ("nba", 4397183),
    "Abner Uribe (MLB)": ("mlb", 4917865),
    "Ace Bailey (NBA)": ("nba", 4873138),
    "Adam Fantilli (NHL)": ("nhl", 5136617),
    "Adam Fox (NHL)": ("nhl", 4197146),
    "Adam Larsson (NHL)": ("nhl", 2562610),
    "Aday Mara (NBA)": ("nba", 5174983),
    "Adley Rutschman (MLB)": ("mlb", 42178),
    "Adonai Mitchell (NFL)": ("nfl", 4597500),
    "Adrian Kempe (NHL)": ("nhl", 3114802),
    "Agustin Ramirez (MLB)": ("mlb", 5132014),
    "Ajay Mitchell (NBA)": ("nba", 4900671),
    "Al Horford (NBA)": ("nba", 3213),
    "Alec Burleson (MLB)": ("mlb", 4345070),
    "Alec Pierce (NFL)": ("nfl", 4360078),
    "Alejandro Kirk (MLB)": ("mlb", 42081),
    "Aleksander Barkov (NHL)": ("nhl", 3041970),
    "Alex Bregman (MLB)": ("mlb", 34886),
    "Alex Caruso (NBA)": ("nba", 2991350),
    "Alex DeBrincat (NHL)": ("nhl", 4063433),
    "Alex Laferriere (NHL)": ("nhl", 4697725),
    "Alex Lyon (NHL)": ("nhl", 3654006),
    "Alex Ovechkin (NHL)": ("nhl", 3101),
    "Alex Sarr (NBA)": ("nba", 5160992),
    "Alex Tuch (NHL)": ("nhl", 3114766),
    "Alexander Nikishin (NHL)": ("nhl", 5188393),
    "Alexander Wennberg (NHL)": ("nhl", 3042017),
    "Alexis Lafreniere (NHL)": ("nhl", 4697382),
    "Aliaksei Protas (NHL)": ("nhl", 4587943),
    "Alperen Sengun (NBA)": ("nba", 4871144),
    "Alvin Kamara (NFL)": ("nfl", 3054850),
    "Amen Thompson (NBA)": ("nba", 4684740),
    "Amon-Ra St. Brown (NFL)": ("nfl", 4374302),
    "Anders Lee (NHL)": ("nhl", 5793),
    "Andre Drummond (NBA)": ("nba", 6585),
    "Andrei Svechnikov (NHL)": ("nhl", 4352683),
    "Andrei Vasilevskiy (NHL)": ("nhl", 2976847),
    "Andres Munoz (MLB)": ("mlb", 40939),
    "Andrew Abbott (MLB)": ("mlb", 4414528),
    "Andrew Nembhard (NBA)": ("nba", 4395712),
    "Andrew Wiggins (NBA)": ("nba", 3059319),
    "Andy Pages (MLB)": ("mlb", 42468),
    "Anfernee Simons (NBA)": ("nba", 4351851),
    "Anthony Black (NBA)": ("nba", 4712849),
    "Anthony Cirelli (NHL)": ("nhl", 3941973),
    "Anthony Davis (NBA)": ("nba", 6583),
    "Anthony Edwards (NBA)": ("nba", 4594268),
    "Anthony Mantha (NHL)": ("nhl", 3042037),
    "Anton Forsberg (NHL)": ("nhl", 3036851),
    "Antonio Williams (NFL)": ("nfl", 5081432),
    "Aroldis Chapman (MLB)": ("mlb", 30442),
    "Artemi Panarin (NHL)": ("nhl", 3891952),
    "Artturi Lehkonen (NHL)": ("nhl", 3042050),
    "Ashton Jeanty (NFL)": ("nfl", 4890973),
    "Ausar Thompson (NBA)": ("nba", 4684742),
    "Austin Reaves (NBA)": ("nba", 4066457),
    "Austin Riley (MLB)": ("mlb", 34982),
    "Auston Matthews (NHL)": ("nhl", 4024123),
    "Ayo Dosunmu (NBA)": ("nba", 4397002),
    "Baker Mayfield (NFL)": ("nfl", 3052587),
    "Bam Adebayo (NBA)": ("nba", 4066261),
    "Beckett Sennecke (NHL)": ("nhl", 5216858),
    "Ben Rice (MLB)": ("mlb", 5016968),
    "Ben Simmons (NBA)": ("nba", 3907387),
    "Bennedict Mathurin (NBA)": ("nba", 4683634),
    "Bhayshul Tuten (NFL)": ("nfl", 4882093),
    "Bijan Robinson (NFL)": ("nfl", 4430807),
    "Bilal Coulibaly (NBA)": ("nba", 5104155),
    "Blake Coleman (NHL)": ("nhl", 2563026),
    "Blake Corum (NFL)": ("nfl", 4429096),
    "Blake Snell (MLB)": ("mlb", 33748),
    "Bo Bichette (MLB)": ("mlb", 38904),
    "Bo Horvat (NHL)": ("nhl", 3042002),
    "Bo Nix (NFL)": ("nfl", 4426338),
    "Bobby McMann (NHL)": ("nhl", 5048894),
    "Bobby Portis (NBA)": ("nba", 3064482),
    "Bobby Witt Jr. (MLB)": ("mlb", 42403),
    "Bowen Byram (NHL)": ("nhl", 4565225),
    "Brad Marchand (NHL)": ("nhl", 3852),
    "Bradley Beal (NBA)": ("nba", 6580),
    "Brady Skjei (NHL)": ("nhl", 2976856),
    "Brady Tkachuk (NHL)": ("nhl", 4319858),
    "Braelon Allen (NFL)": ("nfl", 4685247),
    "Brandin Podziemski (NBA)": ("nba", 4709138),
    "Brandon Aubrey (NFL)": ("nfl", 3953687),
    "Brandon Bussi (NHL)": ("nhl", 4996097),
    "Brandon Hagel (NHL)": ("nhl", 4065019),
    "Brandon Ingram (NBA)": ("nba", 3913176),
    "Brandon Lowe (MLB)": ("mlb", 39961),
    "Brandon Miller (NBA)": ("nba", 4433287),
    "Brandon Montour (NHL)": ("nhl", 3115032),
    "Brandon Nimmo (MLB)": ("mlb", 32159),
    "Brandon Woodruff (MLB)": ("mlb", 37515),
    "Brandt Clarke (NHL)": ("nhl", 4874722),
    "Braxton Ashcraft (MLB)": ("mlb", 41282),
    "Brayden Burries (NBA)": ("nba", 5082206),
    "Brayden Point (NHL)": ("nhl", 3151187),
    "Brayden Schenn (NHL)": ("nhl", 5219),
    "Breece Hall (NFL)": ("nfl", 4427366),
    "Brendan Donovan (MLB)": ("mlb", 41773),
    "Brent Burns (NHL)": ("nhl", 2300),
    "Brent Rooker (MLB)": ("mlb", 40926),
    "Brenton Strange (NFL)": ("nfl", 4430539),
    "Brian Robinson Jr. (NFL)": ("nfl", 4241474),
    "Brian Thomas Jr. (NFL)": ("nfl", 4432773),
    "Brice Sensabaugh (NBA)": ("nba", 5105839),
    "Brice Turang (MLB)": ("mlb", 41179),
    "Brock Boeser (NHL)": ("nhl", 3899979),
    "Brock Bowers (NFL)": ("nfl", 4432665),
    "Brock Faber (NHL)": ("nhl", 4697449),
    "Brock Nelson (NHL)": ("nhl", 5798),
    "Brock Purdy (NFL)": ("nfl", 4361741),
    "Bronny James (NBA)": ("nba", 4683774),
    "Brook Lopez (NBA)": ("nba", 3448),
    "Brooks Lee (MLB)": ("mlb", 4629081),
    "Bryan Abreu (MLB)": ("mlb", 41208),
    "Bryan Baker (MLB)": ("mlb", 40884),
    "Bryan Reynolds (MLB)": ("mlb", 38980),
    "Bryan Rust (NHL)": ("nhl", 2591155),
    "Bryan Woo (MLB)": ("mlb", 4629089),
    "Bryce Harper (MLB)": ("mlb", 30951),
    "Bryce Miller (MLB)": ("mlb", 4654313),
    "Bryce Young (NFL)": ("nfl", 4685720),
    "Bryson Stott (MLB)": ("mlb", 42417),
    "Bub Carrington (NBA)": ("nba", 4845374),
    "Bucky Irving (NFL)": ("nfl", 4596448),
    "Buddy Hield (NBA)": ("nba", 2990984),
    "Byron Buxton (MLB)": ("mlb", 32655),
    "C.J. Stroud (NFL)": ("nfl", 4432577),
    "CJ Abrams (MLB)": ("mlb", 42402),
    "CJ McCollum (NBA)": ("nba", 2490149),
    "Cade Cavalli (MLB)": ("mlb", 4308037),
    "Cade Cunningham (NBA)": ("nba", 4432166),
    "Cade Otton (NFL)": ("nfl", 4243331),
    "Cade Smith (MLB)": ("mlb", 4987924),
    "Cairo Santos (NFL)": ("nfl", 17427),
    "Cal Raleigh (MLB)": ("mlb", 41292),
    "Cale Makar (NHL)": ("nhl", 4233563),
    "Caleb Douglas (NFL)": ("nfl", 4869645),
    "Caleb Durbin (MLB)": ("mlb", 5007615),
    "Caleb Williams (NFL)": ("nfl", 4431611),
    "Caleb Wilson (NBA)": ("nba", 5095151),
    "Calvin Ridley (NFL)": ("nfl", 3925357),
    "Cam Little (NFL)": ("nfl", 4686361),
    "Cam Schlittler (MLB)": ("mlb", 5134581),
    "Cam Skattebo (NFL)": ("nfl", 4696981),
    "Cam Spencer (NBA)": ("nba", 4433083),
    "Cam Thomas (NBA)": ("nba", 4432174),
    "Cam Ward (NFL)": ("nfl", 4688380),
    "Cam Whitmore (NBA)": ("nba", 5105592),
    "Cameron Boozer (NBA)": ("nba", 5041935),
    "Cameron Carr (NBA)": ("nba", 5113969),
    "Cameron Dicker (NFL)": ("nfl", 4362081),
    "Cameron Johnson (NBA)": ("nba", 3138196),
    "Carlos Rodon (MLB)": ("mlb", 33696),
    "Carnell Tate (NFL)": ("nfl", 4871023),
    "Carson Benge (MLB)": ("mlb", 4925604),
    "Carter Bryant (NBA)": ("nba", 5061568),
    "Carter Hart (NHL)": ("nhl", 4064582),
    "Carter Jensen (MLB)": ("mlb", 4917812),
    "Carter Verhaeghe (NHL)": ("nhl", 3042088),
    "Case Keenum (NFL)": ("nfl", 15168),
    "Cason Wallace (NBA)": ("nba", 4683692),
    "Ceddanne Rafaela (MLB)": ("mlb", 4987382),
    "Cedric Coward (NBA)": ("nba", 4903027),
    "CeeDee Lamb (NFL)": ("nfl", 4241389),
    "Chandler Simpson (MLB)": ("mlb", 4679983),
    "Charlie Coyle (NHL)": ("nhl", 2555315),
    "Charlie McAvoy (NHL)": ("nhl", 3988803),
    "Chase Brown (NFL)": ("nfl", 4362238),
    "Chase Burns (MLB)": ("mlb", 4927516),
    "Chase DeLauter (MLB)": ("mlb", 4619649),
    "Chase McLaughlin (NFL)": ("nfl", 3150744),
    "Chet Holmgren (NBA)": ("nba", 4433255),
    "Chig Okonkwo (NFL)": ("nfl", 4360635),
    "Chris Bell (NFL)": ("nfl", 4869961),
    "Chris Boswell (NFL)": ("nfl", 17372),
    "Chris Brooks (NFL)": ("nfl", 3149687),
    "Chris Godwin Jr. (NFL)": ("nfl", 3116165),
    "Chris Kreider (NHL)": ("nhl", 5833),
    "Chris Olave (NFL)": ("nfl", 4361370),
    "Chris Paul (NBA)": ("nba", 2779),
    "Chris Rodriguez Jr. (NFL)": ("nfl", 4362619),
    "Chris Sale (MLB)": ("mlb", 30948),
    "Christian Braun (NBA)": ("nba", 4431767),
    "Christian McCaffrey (NFL)": ("nfl", 3117251),
    "Christian Walker (MLB)": ("mlb", 32758),
    "Christian Watson (NFL)": ("nfl", 4248528),
    "Christian Yelich (MLB)": ("mlb", 31283),
    "Chuba Hubbard (NFL)": ("nfl", 4241416),
    "Clayton Keller (NHL)": ("nhl", 4024857),
    "Coby White (NBA)": ("nba", 4395651),
    "Cody Bellinger (MLB)": ("mlb", 33912),
    "Cole Caufield (NHL)": ("nhl", 4565236),
    "Cole Hutson (NHL)": ("nhl", 5216918),
    "Cole Ragans (MLB)": ("mlb", 41054),
    "Collin Gillespie (NBA)": ("nba", 4278585),
    "Collin Murray-Boyles (NBA)": ("nba", 5093267),
    "Collin Sexton (NBA)": ("nba", 4277811),
    "Colston Loveland (NFL)": ("nfl", 4723086),
    "Colton Parayko (NHL)": ("nhl", 3069341),
    "Connor Bedard (NHL)": ("nhl", 5149125),
    "Connor Hellebuyck (NHL)": ("nhl", 3020225),
    "Connor McDavid (NHL)": ("nhl", 3895074),
    "Cooper Flagg (NBA)": ("nba", 5041939),
    "Cooper Kupp (NFL)": ("nfl", 2977187),
    "Corbin Carroll (MLB)": ("mlb", 42404),
    "Corey Seager (MLB)": ("mlb", 32691),
    "Courtland Sutton (NFL)": ("nfl", 3128429),
    "Cristopher Sanchez (MLB)": ("mlb", 42359),
    "Cutter Gauthier (NHL)": ("nhl", 5080145),
    "D'Andre Swift (NFL)": ("nfl", 4259545),
    "D'Angelo Russell (NBA)": ("nba", 3136776),
    "DJ Moore (NFL)": ("nfl", 3915416),
    "DK Metcalf (NFL)": ("nfl", 4047650),
    "Dak Prescott (NFL)": ("nfl", 2577417),
    "Dallas Goedert (NFL)": ("nfl", 3121023),
    "Dalton Kincaid (NFL)": ("nfl", 4385690),
    "Dalton Schultz (NFL)": ("nfl", 3117256),
    "Damian Lillard (NBA)": ("nba", 6606),
    "Dan Vladar (NHL)": ("nhl", 3942459),
    "Daniel Carlson (NFL)": ("nfl", 3051909),
    "Daniel Gafford (NBA)": ("nba", 4278049),
    "Daniel Jones (NFL)": ("nfl", 3917792),
    "Danny Wolf (NBA)": ("nba", 5107173),
    "Darcy Kuemper (NHL)": ("nhl", 2610321),
    "Darius Acuff Jr. (NBA)": ("nba", 5142620),
    "Darius Garland (NBA)": ("nba", 4396907),
    "Darnell Nurse (NHL)": ("nhl", 3041997),
    "Darren Raddysh (NHL)": ("nhl", 3149843),
    "Darren Waller (NFL)": ("nfl", 2576925),
    "Darryn Peterson (NBA)": ("nba", 5041955),
    "Davante Adams (NFL)": ("nfl", 16800),
    "David Bednar (MLB)": ("mlb", 38303),
    "David Montgomery (NFL)": ("nfl", 4035538),
    "David Pastrnak (NHL)": ("nhl", 3114778),
    "Davion Mitchell (NBA)": ("nba", 4278053),
    "Davis Martin (MLB)": ("mlb", 42823),
    "Day'Ron Sharpe (NBA)": ("nba", 4432194),
    "Daylen Lile (MLB)": ("mlb", 4917889),
    "De'Aaron Fox (NBA)": ("nba", 4066259),
    "De'Andre Hunter (NBA)": ("nba", 4065732),
    "De'Anthony Melton (NBA)": ("nba", 4066436),
    "De'Von Achane (NFL)": ("nfl", 4429160),
    "De'Zhaun Stribling (NFL)": ("nfl", 4710714),
    "DeMar DeRozan (NBA)": ("nba", 3978),
    "DeVonta Smith (NFL)": ("nfl", 4241478),
    "Dean Kremer (MLB)": ("mlb", 38295),
    "Deandre Ayton (NBA)": ("nba", 4278129),
    "Deebo Samuel Sr. (NFL)": ("nfl", 3126486),
    "Dejounte Murray (NBA)": ("nba", 3907497),
    "Deni Avdija (NBA)": ("nba", 4683021),
    "Dennis Schroder (NBA)": ("nba", 3032979),
    "Denzel Boston (NFL)": ("nfl", 4832800),
    "Dereck Lively II (NBA)": ("nba", 4683688),
    "Derik Queen (NBA)": ("nba", 4869780),
    "Derrick Henry (NFL)": ("nfl", 3043078),
    "Derrick White (NBA)": ("nba", 3078576),
    "Deshaun Watson (NFL)": ("nfl", 3122840),
    "Desmond Bane (NBA)": ("nba", 4066320),
    "Devaughn Vele (NFL)": ("nfl", 4569559),
    "Devin Booker (NBA)": ("nba", 3136193),
    "Devin Singletary (NFL)": ("nfl", 4040761),
    "Devin Vassell (NBA)": ("nba", 4395630),
    "Devin Williams (MLB)": ("mlb", 33224),
    "Devon Toews (NHL)": ("nhl", 3096249),
    "Dillon Brooks (NBA)": ("nba", 3155526),
    "Dillon Dingler (MLB)": ("mlb", 4345620),
    "Domantas Sabonis (NBA)": ("nba", 3155942),
    "Donovan Clingan (NBA)": ("nba", 5105565),
    "Donovan Mitchell (NBA)": ("nba", 3908809),
    "Dontayvion Wicks (NFL)": ("nfl", 4428850),
    "Donte DiVincenzo (NBA)": ("nba", 3934673),
    "Dougie Hamilton (NHL)": ("nhl", 2562605),
    "Drake Baldwin (MLB)": ("mlb", 4810190),
    "Drake Batherson (NHL)": ("nhl", 4271734),
    "Drake London (NFL)": ("nfl", 4426502),
    "Drake Maye (NFL)": ("nfl", 4431452),
    "Draymond Green (NBA)": ("nba", 6589),
    "Drew Rasmussen (MLB)": ("mlb", 42584),
    "Duncan Robinson (NBA)": ("nba", 3157465),
    "Dustin Wolf (NHL)": ("nhl", 4587952),
    "Dylan Cease (MLB)": ("mlb", 34943),
    "Dylan Cozens (NHL)": ("nhl", 4565228),
    "Dylan Guenther (NHL)": ("nhl", 4874723),
    "Dylan Harper (NBA)": ("nba", 5037871),
    "Dylan Holloway (NHL)": ("nhl", 4697397),
    "Dylan Larkin (NHL)": ("nhl", 3114755),
    "Dylan Sampson (NFL)": ("nfl", 5081397),
    "Dylan Strome (NHL)": ("nhl", 3899933),
    "Dyson Daniels (NBA)": ("nba", 4869342),
    "Easton Cowan (NHL)": ("nhl", 5149211),
    "Eddy Pineiro (NFL)": ("nfl", 4034949),
    "Eduardo Rodriguez (MLB)": ("mlb", 32675),
    "Edwin Diaz (MLB)": ("mlb", 35394),
    "Eeli Tolvanen (NHL)": ("nhl", 4233720),
    "Egor Demin (NBA)": ("nba", 5175643),
    "Elias Lindholm (NHL)": ("nhl", 3041994),
    "Elias Pettersson (NHL)": ("nhl", 4233566),
    "Elly De La Cruz (MLB)": ("mlb", 4917694),
    "Emanuel Wilson (NFL)": ("nfl", 4887558),
    "Emeka Egbuka (NFL)": ("nfl", 4567750),
    "Emerson Hancock (MLB)": ("mlb", 4297897),
    "Emilio Pagan (MLB)": ("mlb", 33403),
    "Emmet Sheehan (MLB)": ("mlb", 4417806),
    "Emmett Johnson (NFL)": ("nfl", 4832955),
    "Erik Karlsson (NHL)": ("nhl", 5164),
    "Ernie Clement (MLB)": ("mlb", 41287),
    "Esa Lindell (NHL)": ("nhl", 3069352),
    "Eugenio Suarez (MLB)": ("mlb", 32367),
    "Eury Perez (MLB)": ("mlb", 4917854),
    "Evan Bouchard (NHL)": ("nhl", 4352722),
    "Evan Engram (NFL)": ("nfl", 3051876),
    "Evan McPherson (NFL)": ("nfl", 4360234),
    "Evan Mobley (NBA)": ("nba", 4432158),
    "Evgeni Malkin (NHL)": ("nhl", 3124),
    "Ezequiel Duran (MLB)": ("mlb", 42457),
    "Fernando Mendoza (NFL)": ("nfl", 4837248),
    "Fernando Tatis Jr. (MLB)": ("mlb", 35983),
    "Filip Forsberg (NHL)": ("nhl", 2968772),
    "Filip Gustavsson (NHL)": ("nhl", 4272674),
    "Filip Hronek (NHL)": ("nhl", 4063607),
    "Foster Griffin (MLB)": ("mlb", 33773),
    "Framber Valdez (MLB)": ("mlb", 36581),
    "Francisco Lindor (MLB)": ("mlb", 32129),
    "Franz Wagner (NBA)": ("nba", 4566434),
    "Fred VanVleet (NBA)": ("nba", 2991230),
    "Freddie Freeman (MLB)": ("mlb", 30193),
    "Freddy Peralta (MLB)": ("mlb", 39825),
    "GG Jackson (NBA)": ("nba", 5105550),
    "Gabriel Landeskog (NHL)": ("nhl", 2562609),
    "Gabriel Moreno (MLB)": ("mlb", 42464),
    "Gabriel Vilardi (NHL)": ("nhl", 4233583),
    "Garrett Crochet (MLB)": ("mlb", 4297835),
    "Garrett Wilson (NFL)": ("nfl", 4569618),
    "Gavin McKenna (NHL)": ("nhl", 5342529),
    "Gavin Williams (MLB)": ("mlb", 4345076),
    "Geno Smith (NFL)": ("nfl", 15864),
    "George Holani (NFL)": ("nfl", 4429835),
    "George Kirby (MLB)": ("mlb", 42406),
    "George Kittle (NFL)": ("nfl", 3040151),
    "George Pickens (NFL)": ("nfl", 4426354),
    "George Springer (MLB)": ("mlb", 32078),
    "Geraldo Perdomo (MLB)": ("mlb", 41355),
    "Germie Bernard (NFL)": ("nfl", 4685261),
    "Gerrit Cole (MLB)": ("mlb", 32081),
    "Giannis Antetokounmpo (NBA)": ("nba", 3032977),
    "Gleyber Torres (MLB)": ("mlb", 33804),
    "Gradey Dick (NBA)": ("nba", 5106258),
    "Grayson Allen (NBA)": ("nba", 3135045),
    "Griffin Jax (MLB)": ("mlb", 42604),
    "Gunnar Helm (NFL)": ("nfl", 4686728),
    "Gunnar Henderson (MLB)": ("mlb", 42507),
    "Gustav Forsling (NHL)": ("nhl", 3151784),
    "Hannes Steinbach (NBA)": ("nba", 5281370),
    "Harold Fannin Jr. (NFL)": ("nfl", 5083076),
    "Harrison Butker (NFL)": ("nfl", 3055899),
    "Harrison Mevis (NFL)": ("nfl", 4574716),
    "Herbert Jones (NBA)": ("nba", 4277813),
    "Hunter Brown (MLB)": ("mlb", 4717803),
    "Hunter Goodman (MLB)": ("mlb", 4416591),
    "Hunter Henry (NFL)": ("nfl", 3046439),
    "Ian Happ (MLB)": ("mlb", 34945),
    "Ian Seymour (MLB)": ("mlb", 4669425),
    "Igor Shesterkin (NHL)": ("nhl", 3151297),
    "Ilya Sorokin (NHL)": ("nhl", 3151981),
    "Immanuel Quickley (NBA)": ("nba", 4395724),
    "Isaac Paredes (MLB)": ("mlb", 39706),
    "Isaiah Collier (NBA)": ("nba", 4683766),
    "Isaiah Davis (NFL)": ("nfl", 4695404),
    "Isaiah Hartenstein (NBA)": ("nba", 4222252),
    "Isaiah Joe (NBA)": ("nba", 4395702),
    "Isaiah Likely (NFL)": ("nfl", 4361050),
    "Isaiah Stewart (NBA)": ("nba", 4432810),
    "Isiah Pacheco (NFL)": ("nfl", 4361529),
    "Ivan Barbashev (NHL)": ("nhl", 3114985),
    "Ivan Demidov (NHL)": ("nhl", 5216860),
    "Ivan Herrera (MLB)": ("mlb", 41889),
    "Ivan Provorov (NHL)": ("nhl", 3899939),
    "Ivar Stenberg (NHL)": ("nhl", 5361709),
    "Ivica Zubac (NBA)": ("nba", 4017837),
    "J.K. Dobbins (NFL)": ("nfl", 4241985),
    "J.T. Miller (NHL)": ("nhl", 2590852),
    "JJ Peterka (NHL)": ("nhl", 4697438),
    "JJ Wetherholt (MLB)": ("mlb", 4941056),
    "Ja Morant (NBA)": ("nba", 4279888),
    "Ja'Kobi Lane (NFL)": ("nfl", 4870847),
    "Ja'Marr Chase (NFL)": ("nfl", 4362628),
    "Jabari Smith Jr. (NBA)": ("nba", 4432639),
    "Jac Caglianone (MLB)": ("mlb", 4926296),
    "Jack Eichel (NHL)": ("nhl", 3648002),
    "Jack Hughes (NHL)": ("nhl", 4565222),
    "Jackson Blake (NHL)": ("nhl", 5103645),
    "Jackson Chourio (MLB)": ("mlb", 4917869),
    "Jackson LaCombe (NHL)": ("nhl", 4565262),
    "Jackson Merrill (MLB)": ("mlb", 4872691),
    "Jacob Latz (MLB)": ("mlb", 3210625),
    "Jacob Markstrom (NHL)": ("nhl", 5452),
    "Jacob Misiorowski (MLB)": ("mlb", 5080761),
    "Jacob Trouba (NHL)": ("nhl", 2976839),
    "Jacob Wilson (MLB)": ("mlb", 4719300),
    "Jacob deGrom (MLB)": ("mlb", 32796),
    "Jacoby Brissett (NFL)": ("nfl", 2578570),
    "Jacory Croskey-Merritt (NFL)": ("nfl", 4575131),
    "Jadarian Price (NFL)": ("nfl", 4685512),
    "Jaden McDaniels (NBA)": ("nba", 4431671),
    "Jahmyr Gibbs (NFL)": ("nfl", 4429795),
    "Jaime Jaquez Jr. (NBA)": ("nba", 4432848),
    "Jake Allen (NHL)": ("nhl", 5111),
    "Jake Bates (NFL)": ("nfl", 4689936),
    "Jake Bauers (MLB)": ("mlb", 35013),
    "Jake DeBrusk (NHL)": ("nhl", 3900240),
    "Jake Elliott (NFL)": ("nfl", 3050478),
    "Jake Ferguson (NFL)": ("nfl", 4242355),
    "Jake Guentzel (NHL)": ("nhl", 3042083),
    "Jake LaRavia (NBA)": ("nba", 4592691),
    "Jake McCabe (NHL)": ("nhl", 3020803),
    "Jake McCarthy (MLB)": ("mlb", 41197),
    "Jake Oettinger (NHL)": ("nhl", 4196914),
    "Jake Sanderson (NHL)": ("nhl", 4697386),
    "Jakob Chychrun (NHL)": ("nhl", 4024950),
    "Jakob Poeltl (NBA)": ("nba", 3134908),
    "Jakobi Meyers (NFL)": ("nfl", 3916433),
    "Jakub Dobes (NHL)": ("nhl", 4697686),
    "Jalen Brunson (NBA)": ("nba", 3934672),
    "Jalen Coker (NFL)": ("nfl", 4695883),
    "Jalen Duren (NBA)": ("nba", 4433621),
    "Jalen Green (NBA)": ("nba", 4437244),
    "Jalen Hurts (NFL)": ("nfl", 4040715),
    "Jalen Johnson (NBA)": ("nba", 4701230),
    "Jalen McMillan (NFL)": ("nfl", 4430834),
    "Jalen Nailor (NFL)": ("nfl", 4382466),
    "Jalen Suggs (NBA)": ("nba", 4432165),
    "Jalen Williams (NBA)": ("nba", 4593803),
    "Jamal Murray (NBA)": ("nba", 3936299),
    "Jamal Shead (NBA)": ("nba", 4432241),
    "James Cook III (NFL)": ("nfl", 4379399),
    "James Harden (NBA)": ("nba", 3992),
    "James Wood (MLB)": ("mlb", 4918256),
    "Jameson Williams (NFL)": ("nfl", 4426388),
    "Jared Goff (NFL)": ("nfl", 3046779),
    "Jared Jones (MLB)": ("mlb", 4918156),
    "Jared McCain (NBA)": ("nba", 4683778),
    "Jared McCann (NHL)": ("nhl", 3114777),
    "Jaren Jackson Jr. (NBA)": ("nba", 4277961),
    "Jarren Duran (MLB)": ("mlb", 41610),
    "Jarrett Allen (NBA)": ("nba", 4066328),
    "Jason Myers (NFL)": ("nfl", 2473037),
    "Jason Robertson (NHL)": ("nhl", 4233875),
    "Jauan Jennings (NFL)": ("nfl", 3886598),
    "Javier Sanoja (MLB)": ("mlb", 5073992),
    "Javonte Williams (NFL)": ("nfl", 4361579),
    "Jaxon Smith-Njigba (NFL)": ("nfl", 4430878),
    "Jaxson Dart (NFL)": ("nfl", 4689114),
    "Jayden Daniels (NFL)": ("nfl", 4426348),
    "Jayden Reed (NFL)": ("nfl", 4362249),
    "Jaylen Brown (NBA)": ("nba", 3917376),
    "Jaylen Waddle (NFL)": ("nfl", 4372016),
    "Jaylen Warren (NFL)": ("nfl", 4569987),
    "Jaylen Wright (NFL)": ("nfl", 4682745),
    "Jaylin Noel (NFL)": ("nfl", 4586312),
    "Jaylin Williams (NBA)": ("nba", 4432823),
    "Jaylon Tyson (NBA)": ("nba", 4683747),
    "Jayson Tatum (NBA)": ("nba", 4065648),
    "Jazz Chisholm Jr. (MLB)": ("mlb", 41433),
    "Jeff Hoffman (MLB)": ("mlb", 33841),
    "Jerami Grant (NBA)": ("nba", 2991070),
    "Jeremiah Fears (NBA)": ("nba", 5144091),
    "Jeremiyah Love (NFL)": ("nfl", 4870808),
    "Jeremy Pena (MLB)": ("mlb", 41273),
    "Jeremy Swayman (NHL)": ("nhl", 4712036),
    "Jerry Jeudy (NFL)": ("nfl", 4241463),
    "Jesper Bratt (NHL)": ("nhl", 4268771),
    "Jesper Wallstedt (NHL)": ("nhl", 4874737),
    "Jesus Luzardo (MLB)": ("mlb", 39667),
    "Jet Greaves (NHL)": ("nhl", 4894366),
    "Jhoan Duran (MLB)": ("mlb", 41109),
    "Jimmy Butler III (NBA)": ("nba", 6430),
    "Jimmy Snuggerud (NHL)": ("nhl", 5080171),
    "Jo Adell (MLB)": ("mlb", 40854),
    "Joe Burrow (NFL)": ("nfl", 3915511),
    "Joe Ryan (MLB)": ("mlb", 42450),
    "Joel Embiid (NBA)": ("nba", 3059318),
    "Joel Eriksson Ek (NHL)": ("nhl", 3904091),
    "Joel Hofer (NHL)": ("nhl", 4587909),
    "Joey Daccord (NHL)": ("nhl", 3942073),
    "John Carlson (NHL)": ("nhl", 5118),
    "John Collins (NBA)": ("nba", 3908845),
    "John Gibson (NHL)": ("nhl", 2590824),
    "John Tavares (NHL)": ("nhl", 5160),
    "Jonah Coleman (NFL)": ("nfl", 4702555),
    "Jonathan Aranda (MLB)": ("mlb", 40810),
    "Jonathan Kuminga (NBA)": ("nba", 4433247),
    "Jonathan Marchessault (NHL)": ("nhl", 2967072),
    "Jonathan Taylor (NFL)": ("nfl", 4242335),
    "Jonathon Brooks (NFL)": ("nfl", 4678008),
    "Jordan Addison (NFL)": ("nfl", 4429205),
    "Jordan Eberle (NHL)": ("nhl", 5032),
    "Jordan Kyrou (NHL)": ("nhl", 4062251),
    "Jordan Love (NFL)": ("nfl", 4036378),
    "Jordan Mason (NFL)": ("nfl", 4360569),
    "Jordan Poole (NBA)": ("nba", 4277956),
    "Jordan Walker (MLB)": ("mlb", 4684778),
    "Jordyn Tyson (NFL)": ("nfl", 4880281),
    "Jose Altuve (MLB)": ("mlb", 31662),
    "Jose Alvarado (NBA)": ("nba", 4277869),
    "Jose Ramirez (MLB)": ("mlb", 32801),
    "Jose Soriano (MLB)": ("mlb", 40973),
    "Josh Allen (NFL)": ("nfl", 3918298),
    "Josh Doan (NHL)": ("nhl", 4874870),
    "Josh Downs (NFL)": ("nfl", 4688813),
    "Josh Giddey (NBA)": ("nba", 4871145),
    "Josh Hader (MLB)": ("mlb", 32760),
    "Josh Hart (NBA)": ("nba", 3062679),
    "Josh Jacobs (NFL)": ("nfl", 4047365),
    "Josh Morrissey (NHL)": ("nhl", 3042016),
    "Josh Naylor (MLB)": ("mlb", 35066),
    "Jrue Holiday (NBA)": ("nba", 3995),
    "Juan Soto (MLB)": ("mlb", 36969),
    "Julian Champagnie (NBA)": ("nba", 4592479),
    "Julio Rodriguez (MLB)": ("mlb", 41044),
    "Julius Randle (NBA)": ("nba", 3064514),
    "Jung Hoo Lee (MLB)": ("mlb", 5134621),
    "Junior Caminero (MLB)": ("mlb", 4905921),
    "Juraj Slafkovsky (NHL)": ("nhl", 4915349),
    "Justice Hill (NFL)": ("nfl", 4038441),
    "Justin Faulk (NHL)": ("nhl", 5746),
    "Justin Herbert (NFL)": ("nfl", 4038941),
    "Justin Jefferson (NFL)": ("nfl", 4262921),
    "Justin Wrobleski (MLB)": ("mlb", 4417203),
    "Jusuf Nurkic (NBA)": ("nba", 3102530),
    "Juuse Saros (NHL)": ("nhl", 3042109),
    "Juwan Johnson (NFL)": ("nfl", 3929645),
    "K'Andre Miller (NHL)": ("nhl", 4352770),
    "KC Concepcion (NFL)": ("nfl", 4870653),
    "Ka'imi Fairbairn (NFL)": ("nfl", 2971573),
    "Kaelon Black (NFL)": ("nfl", 4696044),
    "Kaleb Johnson (NFL)": ("nfl", 4819231),
    "Kalif Raymond (NFL)": ("nfl", 2973405),
    "Karel Vejmelka (NHL)": ("nhl", 3942065),
    "Karl-Anthony Towns (NBA)": ("nba", 3136195),
    "Kawhi Leonard (NBA)": ("nba", 6450),
    "Kayshon Boutte (NFL)": ("nfl", 4429022),
    "Kazuma Okamoto (MLB)": ("mlb", 5134636),
    "Keaton Mitchell (NFL)": ("nfl", 4596334),
    "Keaton Wagler (NBA)": ("nba", 5254165),
    "Keegan Murray (NBA)": ("nba", 4594327),
    "Keenan Allen (NFL)": ("nfl", 15818),
    "Kel'el Ware (NBA)": ("nba", 5105623),
    "Keldon Johnson (NBA)": ("nba", 4395723),
    "Kelly Oubre Jr. (NBA)": ("nba", 3133603),
    "Kendre Miller (NFL)": ("nfl", 4599739),
    "Kenley Jansen (MLB)": ("mlb", 29630),
    "Kenneth Walker III (NFL)": ("nfl", 4567048),
    "Kenny Gainwell (NFL)": ("nfl", 4371733),
    "Kenyon Sadiq (NFL)": ("nfl", 5083315),
    "Keon Coleman (NFL)": ("nfl", 4635008),
    "Ketel Marte (MLB)": ("mlb", 32512),
    "Kevin Durant (NBA)": ("nba", 3202),
    "Kevin Fiala (NHL)": ("nhl", 3114743),
    "Kevin Gausman (MLB)": ("mlb", 32667),
    "Kevin Huerter (NBA)": ("nba", 4066372),
    "Kevin McGonigle (MLB)": ("mlb", 5149072),
    "Kevin Porter Jr. (NBA)": ("nba", 4397140),
    "Keyonte George (NBA)": ("nba", 4433627),
    "Khalil Shakir (NFL)": ("nfl", 4373678),
    "Khaman Maluach (NBA)": ("nba", 5203685),
    "Kiefer Sherwood (NHL)": ("nhl", 4391255),
    "Kingston Flemings (NBA)": ("nba", 5149077),
    "Kirill Kaprizov (NHL)": ("nhl", 3942335),
    "Kirill Marchenko (NHL)": ("nhl", 4587996),
    "Kirk Cousins (NFL)": ("nfl", 14880),
    "Klay Thompson (NBA)": ("nba", 6475),
    "Kody Clemens (MLB)": ("mlb", 41311),
    "Kon Knueppel (NBA)": ("nba", 5061575),
    "Konnor Griffin (MLB)": ("mlb", 5218285),
    "Kris Letang (NHL)": ("nhl", 3539),
    "Kristaps Porzingis (NBA)": ("nba", 3102531),
    "Kyle Bradish (MLB)": ("mlb", 4311625),
    "Kyle Connor (NHL)": ("nhl", 3899952),
    "Kyle Filipowski (NBA)": ("nba", 4684793),
    "Kyle Harrison (MLB)": ("mlb", 4683375),
    "Kyle Kuzma (NBA)": ("nba", 3134907),
    "Kyle Monangai (NFL)": ("nfl", 4608686),
    "Kyle Pitts Sr. (NFL)": ("nfl", 4360248),
    "Kyle Schwarber (MLB)": ("mlb", 33712),
    "Kyle Tucker (MLB)": ("mlb", 34967),
    "Kyler Murray (NFL)": ("nfl", 3917315),
    "Kyren Williams (NFL)": ("nfl", 4430737),
    "Kyrie Irving (NBA)": ("nba", 6442),
    "Kyshawn George (NBA)": ("nba", 5174563),
    "LaMelo Ball (NBA)": ("nba", 4432816),
    "Labaron Philon Jr. (NBA)": ("nba", 4873090),
    "Ladd McConkey (NFL)": ("nfl", 4612826),
    "Lamar Jackson (NFL)": ("nfl", 3916387),
    "Lane Hutson (NHL)": ("nhl", 5080230),
    "Lauri Markkanen (NBA)": ("nba", 4066336),
    "Lawson Crouse (NHL)": ("nhl", 3899951),
    "LeBron James (NBA)": ("nba", 1966),
    "Leo Carlsson (NHL)": ("nhl", 5149153),
    "Leon Draisaitl (NHL)": ("nhl", 3114727),
    "Liam Hicks (MLB)": ("mlb", 4725251),
    "Linus Ullmark (NHL)": ("nhl", 3069285),
    "Logan Cooley (NHL)": ("nhl", 5080143),
    "Logan Gilbert (MLB)": ("mlb", 41221),
    "Logan Henderson (MLB)": ("mlb", 4917878),
    "Logan Stankoven (NHL)": ("nhl", 4874899),
    "Logan Thompson (NHL)": ("nhl", 4272888),
    "Logan Webb (MLB)": ("mlb", 41216),
    "Louis Varland (MLB)": ("mlb", 4917888),
    "Lucas Raymond (NHL)": ("nhl", 4697385),
    "Luguentz Dort (NBA)": ("nba", 4397020),
    "Luis Arraez (MLB)": ("mlb", 39572),
    "Luis Castillo (MLB)": ("mlb", 35124),
    "Luis Garcia Jr. (MLB)": ("mlb", 40459),
    "Luka Doncic (NBA)": ("nba", 3945274),
    "Lukas Dostal (NHL)": ("nhl", 4588165),
    "Luke Evangelista (NHL)": ("nhl", 4697446),
    "Luke Hughes (NHL)": ("nhl", 4874719),
    "Luke Keaschall (MLB)": ("mlb", 4977664),
    "Luke Kornet (NBA)": ("nba", 3064560),
    "Luther Burden III (NFL)": ("nfl", 4685278),
    "MacKenzie Gore (MLB)": ("mlb", 39636),
    "MacKenzie Weegar (NHL)": ("nhl", 3042269),
    "Mack Hollins (NFL)": ("nfl", 2991662),
    "Mackenzie Blackwood (NHL)": ("nhl", 3904177),
    "Macklin Celebrini (NHL)": ("nhl", 5206628),
    "Maikel Garcia (MLB)": ("mlb", 4905884),
    "Makai Lemon (NFL)": ("nfl", 4870795),
    "Malachi Fields (NFL)": ("nfl", 4682648),
    "Malik Monk (NBA)": ("nba", 4066262),
    "Malik Nabers (NFL)": ("nfl", 4595348),
    "Malik Washington (NFL)": ("nfl", 4569603),
    "Malik Willis (NFL)": ("nfl", 4242512),
    "Manny Machado (MLB)": ("mlb", 31097),
    "MarShawn Lloyd (NFL)": ("nfl", 4429023),
    "Marco Rossi (NHL)": ("nhl", 4697391),
    "Marcus Mariota (NFL)": ("nfl", 2576980),
    "Marcus Semien (MLB)": ("mlb", 32146),
    "Marcus Smart (NBA)": ("nba", 2990992),
    "Mark Andrews (NFL)": ("nfl", 3116365),
    "Mark Scheifele (NHL)": ("nhl", 2562632),
    "Mark Stone (NHL)": ("nhl", 5545),
    "Mark Williams (NBA)": ("nba", 4701232),
    "Martin Fehervary (NHL)": ("nhl", 4378677),
    "Martin Necas (NHL)": ("nhl", 4233586),
    "Marvin Harrison Jr. (NFL)": ("nfl", 4432708),
    "Mason Miller (MLB)": ("mlb", 4730225),
    "Mason Montgomery (MLB)": ("mlb", 4424112),
    "Matas Buzelis (NBA)": ("nba", 4711294),
    "Mathew Barzal (NHL)": ("nhl", 3899946),
    "Mats Zuccarello (NHL)": ("nhl", 5560),
    "Matt Boldy (NHL)": ("nhl", 4565233),
    "Matt Chapman (MLB)": ("mlb", 33857),
    "Matt Coronato (NHL)": ("nhl", 4874730),
    "Matt Duchene (NHL)": ("nhl", 5161),
    "Matt Olson (MLB)": ("mlb", 32767),
    "Matthew Boyd (MLB)": ("mlb", 34401),
    "Matthew Golden (NFL)": ("nfl", 4701936),
    "Matthew Knies (NHL)": ("nhl", 4874919),
    "Matthew Schaefer (NHL)": ("nhl", 5291933),
    "Matthew Stafford (NFL)": ("nfl", 12483),
    "Matthew Tkachuk (NHL)": ("nhl", 4024854),
    "Mattias Ekholm (NHL)": ("nhl", 2558631),
    "Mattias Samuelsson (NHL)": ("nhl", 4378656),
    "Matty Beniers (NHL)": ("nhl", 4781552),
    "Matvei Michkov (NHL)": ("nhl", 5149170),
    "Mauricio Dubon (MLB)": ("mlb", 35304),
    "Max Christie (NBA)": ("nba", 4432582),
    "Max Fried (MLB)": ("mlb", 32685),
    "Max Meyer (MLB)": ("mlb", 4345164),
    "Max Muncy (MLB)": ("mlb", 33303),
    "Maxime Raynaud (NBA)": ("nba", 4898371),
    "Meleek Thomas (NBA)": ("nba", 5041951),
    "Michael Busch (MLB)": ("mlb", 42415),
    "Michael Harris II (MLB)": ("mlb", 42470),
    "Michael King (MLB)": ("mlb", 40429),
    "Michael Mayer (NFL)": ("nfl", 4429086),
    "Michael Penix Jr. (NFL)": ("nfl", 4360423),
    "Michael Pittman Jr. (NFL)": ("nfl", 4035687),
    "Michael Porter Jr. (NBA)": ("nba", 4278104),
    "Michael Soroka (MLB)": ("mlb", 34984),
    "Michael Wacha (MLB)": ("mlb", 32640),
    "Michael Wilson (NFL)": ("nfl", 4360761),
    "Miguel Vargas (MLB)": ("mlb", 42453),
    "Mika Zibanejad (NHL)": ("nhl", 2562637),
    "Mikael Granlund (NHL)": ("nhl", 5831),
    "Mikal Bridges (NBA)": ("nba", 3147657),
    "Mike Evans (NFL)": ("nfl", 16737),
    "Mike Gesicki (NFL)": ("nfl", 3116164),
    "Mike Matheson (NHL)": ("nhl", 2976851),
    "Mike Trout (MLB)": ("mlb", 30836),
    "Mike Washington Jr. (NFL)": ("nfl", 4686658),
    "Mikel Brown Jr. (NBA)": ("nba", 5101761),
    "Mikhail Sergachev (NHL)": ("nhl", 4024868),
    "Mikko Rantanen (NHL)": ("nhl", 3899938),
    "Miles Bridges (NBA)": ("nba", 4066383),
    "Miles McBride (NBA)": ("nba", 4431823),
    "Miro Heiskanen (NHL)": ("nhl", 4233536),
    "Mitch Marner (NHL)": ("nhl", 3899937),
    "Mitchell Robinson (NBA)": ("nba", 4351852),
    "Mookie Betts (MLB)": ("mlb", 33039),
    "Morez Johnson Jr. (NBA)": ("nba", 4873153),
    "Morgan Geekie (NHL)": ("nhl", 4268466),
    "Morgan Rielly (NHL)": ("nhl", 2976833),
    "Moritz Seider (NHL)": ("nhl", 4565227),
    "Moussa Diabate (NBA)": ("nba", 4433249),
    "Munetaka Murakami (MLB)": ("mlb", 4872595),
    "Myles Turner (NBA)": ("nba", 3133628),
    "Najee Harris (NFL)": ("nfl", 4241457),
    "Naji Marshall (NBA)": ("nba", 4278594),
    "Nate Ament (NBA)": ("nba", 5164559),
    "Nathan Eovaldi (MLB)": ("mlb", 31174),
    "Nathan MacKinnon (NHL)": ("nhl", 3041969),
    "Naz Reid (NBA)": ("nba", 4396971),
    "Nazem Kadri (NHL)": ("nhl", 5349),
    "Neemias Queta (NBA)": ("nba", 4397424),
    "Nic Claxton (NBA)": ("nba", 4278067),
    "Nick Folk (NFL)": ("nfl", 10621),
    "Nick Kurtz (MLB)": ("mlb", 4966637),
    "Nick Lodolo (MLB)": ("mlb", 42433),
    "Nick Martinez (MLB)": ("mlb", 33372),
    "Nick Pivetta (MLB)": ("mlb", 36071),
    "Nick Schmaltz (NHL)": ("nhl", 3114770),
    "Nick Suzuki (NHL)": ("nhl", 4233594),
    "Nickeil Alexander-Walker (NBA)": ("nba", 4278039),
    "Nico Collins (NFL)": ("nfl", 4258173),
    "Nico Hischier (NHL)": ("nhl", 4233555),
    "Nico Hoerner (MLB)": ("mlb", 41219),
    "Nikita Kucherov (NHL)": ("nhl", 2563060),
    "Nikita Zadorov (NHL)": ("nhl", 3042021),
    "Nikola Jokic (NBA)": ("nba", 3112335),
    "Nikola Jovic (NBA)": ("nba", 4997528),
    "Nikola Vucevic (NBA)": ("nba", 6478),
    "Nikolaj Ehlers (NHL)": ("nhl", 3114741),
    "Noah Cameron (MLB)": ("mlb", 4417208),
    "Noah Dobson (NHL)": ("nhl", 4352732),
    "Noah Hanifin (NHL)": ("nhl", 3652964),
    "Nolan Arenado (MLB)": ("mlb", 31261),
    "Nolan McLean (MLB)": ("mlb", 4433874),
    "Norman Powell (NBA)": ("nba", 2595516),
    "OG Anunoby (NBA)": ("nba", 3934719),
    "Obi Toppin (NBA)": ("nba", 4278355),
    "Ollie Gordon II (NFL)": ("nfl", 4711533),
    "Omar Cooper Jr. (NFL)": ("nfl", 4723820),
    "Omarion Hampton (NFL)": ("nfl", 4685382),
    "Oneil Cruz (MLB)": ("mlb", 39712),
    "Onyeka Okongwu (NBA)": ("nba", 4431680),
    "Oronde Gadsden (NFL)": ("nfl", 4595342),
    "Oso Ighodaro (NBA)": ("nba", 4601023),
    "Otto Lopez (MLB)": ("mlb", 41917),
    "Owen Power (NHL)": ("nhl", 4781556),
    "Owen Tippett (NHL)": ("nhl", 4392072),
    "Ozzie Albies (MLB)": ("mlb", 33783),
    "P.J. Washington (NBA)": ("nba", 4278078),
    "Paolo Banchero (NBA)": ("nba", 4432573),
    "Parker Messick (MLB)": ("mlb", 4619898),
    "Parker Washington (NFL)": ("nfl", 4432620),
    "Pascal Siakam (NBA)": ("nba", 3149673),
    "Pat Freiermuth (NFL)": ("nfl", 4361411),
    "Patrick Kane (NHL)": ("nhl", 3735),
    "Patrick Mahomes (NFL)": ("nfl", 3139477),
    "Paul George (NBA)": ("nba", 4251),
    "Paul Skenes (MLB)": ("mlb", 4719507),
    "Pavel Buchnevich (NHL)": ("nhl", 3042081),
    "Pavel Dorofeyev (NHL)": ("nhl", 4587588),
    "Pavel Zacha (NHL)": ("nhl", 3899949),
    "Payton Pritchard (NBA)": ("nba", 4066354),
    "Payton Tolle (MLB)": ("mlb", 4966140),
    "Pete Alonso (MLB)": ("mlb", 37498),
    "Pete Crow-Armstrong (MLB)": ("mlb", 4717833),
    "Pete Fairbanks (MLB)": ("mlb", 42180),
    "Peter Lambert (MLB)": ("mlb", 39898),
    "Peyton Watson (NBA)": ("nba", 4576087),
    "Philip Broberg (NHL)": ("nhl", 4565229),
    "Porter Martone (NHL)": ("nhl", 5291941),
    "Precious Achiuwa (NBA)": ("nba", 4431679),
    "Puka Nacua (NFL)": ("nfl", 4426515),
    "Quentin Grimes (NBA)": ("nba", 4397014),
    "Quentin Johnston (NFL)": ("nfl", 4429025),
    "Quinn Hughes (NHL)": ("nhl", 4320548),
    "Quinshon Judkins (NFL)": ("nfl", 4685702),
    "Quinton Byfield (NHL)": ("nhl", 4697383),
    "RJ Barrett (NBA)": ("nba", 4395625),
    "RJ Harvey (NFL)": ("nfl", 4568490),
    "Rachaad White (NFL)": ("nfl", 4697815),
    "Rafael Devers (MLB)": ("mlb", 33859),
    "Raisel Iglesias (MLB)": ("mlb", 33618),
    "Randy Arozarena (MLB)": ("mlb", 36488),
    "Ranger Suarez (MLB)": ("mlb", 39817),
    "Rashee Rice (NFL)": ("nfl", 4428331),
    "Rashid Shaheed (NFL)": ("nfl", 4032473),
    "Rashod Bateman (NFL)": ("nfl", 4360939),
    "Rasmus Andersson (NHL)": ("nhl", 3904186),
    "Rasmus Dahlin (NHL)": ("nhl", 4294163),
    "Ray Davis (NFL)": ("nfl", 4429501),
    "Reed Sheppard (NBA)": ("nba", 4711272),
    "Reid Detmers (MLB)": ("mlb", 4326697),
    "Rhamondre Stevenson (NFL)": ("nfl", 4569173),
    "Rickard Rakell (NHL)": ("nhl", 2562629),
    "Rico Dowdle (NFL)": ("nfl", 4038815),
    "Riley Greene (MLB)": ("mlb", 42179),
    "Riley O'Brien (MLB)": ("mlb", 41509),
    "Robbie Ray (MLB)": ("mlb", 32175),
    "Robert Suarez (MLB)": ("mlb", 4148749),
    "Robert Thomas (NHL)": ("nhl", 4233637),
    "Robert Williams III (NBA)": ("nba", 4066211),
    "Roman Anthony (MLB)": ("mlb", 5080767),
    "Roman Josi (NHL)": ("nhl", 5436),
    "Roman Wilson (NFL)": ("nfl", 4431492),
    "Rome Odunze (NFL)": ("nfl", 4431299),
    "Romeo Doubs (NFL)": ("nfl", 4361432),
    "Ronald Acuna Jr. (MLB)": ("mlb", 36185),
    "Roope Hintz (NHL)": ("nhl", 3904183),
    "Royce O'Neale (NBA)": ("nba", 2583632),
    "Rudy Gobert (NBA)": ("nba", 3032976),
    "Rui Hachimura (NBA)": ("nba", 4066648),
    "Russell Westbrook (NBA)": ("nba", 3468),
    "Ryan Flournoy (NFL)": ("nfl", 5083754),
    "Ryan Hartman (NHL)": ("nhl", 3042063),
    "Ryan Helsley (MLB)": ("mlb", 39909),
    "Ryan Jeffers (MLB)": ("mlb", 41587),
    "Ryan Kalkbrenner (NBA)": ("nba", 4576060),
    "Ryan Leonard (NHL)": ("nhl", 5149172),
    "Ryan Nugent-Hopkins (NHL)": ("nhl", 2562624),
    "Ryan O'Hearn (MLB)": ("mlb", 35183),
    "Ryan O'Reilly (NHL)": ("nhl", 5208),
    "Ryan Pepiot (MLB)": ("mlb", 4208281),
    "Ryan Rollins (NBA)": ("nba", 4591725),
    "Saddiq Bey (NBA)": ("nba", 4397136),
    "Sal Stewart (MLB)": ("mlb", 5080771),
    "Salvador Perez (MLB)": ("mlb", 31127),
    "Sam Bennett (NHL)": ("nhl", 3114732),
    "Sam Darnold (NFL)": ("nfl", 3912547),
    "Sam Hauser (NBA)": ("nba", 4065804),
    "Sam LaPorta (NFL)": ("nfl", 4430027),
    "Sam Malinski (NHL)": ("nhl", 5136735),
    "Sam Reinhart (NHL)": ("nhl", 3114722),
    "Samaje Perine (NFL)": ("nfl", 3116389),
    "Sandro Mamukelashvili (NBA)": ("nba", 4278580),
    "Sandy Alcantara (MLB)": ("mlb", 35241),
    "Santi Aldama (NBA)": ("nba", 4593125),
    "Saquon Barkley (NFL)": ("nfl", 3929630),
    "Scoot Henderson (NBA)": ("nba", 4683678),
    "Scott Wedgewood (NHL)": ("nhl", 5622),
    "Scottie Barnes (NBA)": ("nba", 4433134),
    "Scotty Pippen Jr. (NBA)": ("nba", 4431785),
    "Sean Burke (MLB)": ("mlb", 4867679),
    "Sean Manaea (MLB)": ("mlb", 33244),
    "Sean Walker (NHL)": ("nhl", 4272905),
    "Sebastian Aho (NHL)": ("nhl", 3904173),
    "Seiya Suzuki (MLB)": ("mlb", 4142424),
    "Sergei Bobrovsky (NHL)": ("nhl", 5571),
    "Sergei Murashov (NHL)": ("nhl", 5188366),
    "Seth Jarvis (NHL)": ("nhl", 4697396),
    "Seth Jones (NHL)": ("nhl", 3041992),
    "Shaedon Sharpe (NBA)": ("nba", 4914336),
    "Shai Gilgeous-Alexander (NBA)": ("nba", 4278073),
    "Shane Baz (MLB)": ("mlb", 39639),
    "Shane McClanahan (MLB)": ("mlb", 41199),
    "Shayne Gostisbehere (NHL)": ("nhl", 3025662),
    "Shea Langeliers (MLB)": ("mlb", 42598),
    "Shea Theodore (NHL)": ("nhl", 3042055),
    "Shohei Ohtani (MLB)": ("mlb", 39832),
    "Shota Imanaga (MLB)": ("mlb", 5134630),
    "Sidney Crosby (NHL)": ("nhl", 3114),
    "Sonny Gray (MLB)": ("mlb", 32082),
    "Spencer Knight (NHL)": ("nhl", 4565234),
    "Spencer Shrader (NFL)": ("nfl", 4571557),
    "Spencer Strider (MLB)": ("mlb", 4307825),
    "Stefon Diggs (NFL)": ("nfl", 2976212),
    "Stephen Curry (NBA)": ("nba", 3975),
    "Stephon Castle (NBA)": ("nba", 4845367),
    "Steven Kwan (MLB)": ("mlb", 41996),
    "Steven Stamkos (NHL)": ("nhl", 5037),
    "T.J. Hockenson (NFL)": ("nfl", 4036133),
    "T.J. McConnell (NBA)": ("nba", 2530530),
    "TJ Rumfield (MLB)": ("mlb", 5014349),
    "Tacko Fall (NBA)": ("nba", 3904625),
    "Tage Thompson (NHL)": ("nhl", 4024988),
    "Taj Bradley (MLB)": ("mlb", 42480),
    "Tank Bigsby (NFL)": ("nfl", 4429013),
    "Tank Dell (NFL)": ("nfl", 4366031),
    "Tanner Bibee (MLB)": ("mlb", 4345278),
    "Tanner Scott (MLB)": ("mlb", 35135),
    "Tari Eason (NBA)": ("nba", 4433192),
    "Tarik Skubal (MLB)": ("mlb", 42409),
    "Taylor Ward (MLB)": ("mlb", 34923),
    "Tee Higgins (NFL)": ("nfl", 4239993),
    "Teoscar Hernandez (MLB)": ("mlb", 33377),
    "Terrance Ferguson (NFL)": ("nfl", 4570037),
    "Terry McLaurin (NFL)": ("nfl", 3121422),
    "Tetairoa McMillan (NFL)": ("nfl", 4685472),
    "Thomas Chabot (NHL)": ("nhl", 3900219),
    "Thomas Harley (NHL)": ("nhl", 4565239),
    "Tim Hardaway Jr. (NBA)": ("nba", 2528210),
    "Tim Stutzle (NHL)": ("nhl", 4697384),
    "Timo Meier (NHL)": ("nhl", 3899978),
    "Tobias Harris (NBA)": ("nba", 6440),
    "Tom Wilson (NHL)": ("nhl", 2970615),
    "Tomas Hertl (NHL)": ("nhl", 2976844),
    "Tony Pollard (NFL)": ("nfl", 3916148),
    "Toumani Camara (NBA)": ("nba", 4431736),
    "Trae Young (NBA)": ("nba", 4277905),
    "Travis Etienne Jr. (NFL)": ("nfl", 4239996),
    "Travis Hunter (NFL)": ("nfl", 4685415),
    "Travis Kelce (NFL)": ("nfl", 15847),
    "Travis Konecny (NHL)": ("nhl", 3900169),
    "Travis Sanheim (NHL)": ("nhl", 3114757),
    "Tre Johnson (NBA)": ("nba", 5238230),
    "Tre Jones (NBA)": ("nba", 4395626),
    "Tre Tucker (NFL)": ("nfl", 4428718),
    "Tre' Harris (NFL)": ("nfl", 4686612),
    "TreVeyon Henderson (NFL)": ("nfl", 4432710),
    "Trea Turner (MLB)": ("mlb", 33710),
    "Trevor Lawrence (NFL)": ("nfl", 4360310),
    "Trevor Megill (MLB)": ("mlb", 40080),
    "Trevor Rogers (MLB)": ("mlb", 39640),
    "Trevor Zegras (NHL)": ("nhl", 4565230),
    "Trey McBride (NFL)": ("nfl", 4361307),
    "Trey Murphy III (NBA)": ("nba", 4397688),
    "Trey Smack (NFL)": ("nfl", 4869461),
    "Trey Yesavage (MLB)": ("mlb", 4949041),
    "Troy Melton (MLB)": ("mlb", 5294127),
    "Tucker Kraft (NFL)": ("nfl", 4572680),
    "Ty Jerome (NBA)": ("nba", 4065733),
    "Tyjae Spears (NFL)": ("nfl", 4428557),
    "Tyler Allgeier (NFL)": ("nfl", 4373626),
    "Tyler Bass (NFL)": ("nfl", 3917232),
    "Tyler Bertuzzi (NHL)": ("nhl", 3042056),
    "Tyler Glasnow (MLB)": ("mlb", 33190),
    "Tyler Herro (NBA)": ("nba", 4395725),
    "Tyler Loop (NFL)": ("nfl", 4697745),
    "Tyler Shough (NFL)": ("nfl", 4360689),
    "Tyler Soderstrom (MLB)": ("mlb", 4686066),
    "Tyler Toffoli (NHL)": ("nhl", 5550),
    "Tyler Warren (NFL)": ("nfl", 4431459),
    "Tyreek Hill (NFL)": ("nfl", 3116406),
    "Tyrese Haliburton (NBA)": ("nba", 4396993),
    "Tyrese Maxey (NBA)": ("nba", 4431678),
    "Ukko-Pekka Luukkonen (NHL)": ("nhl", 4233889),
    "VJ Edgecombe (NBA)": ("nba", 5124612),
    "Valeri Nichushkin (NHL)": ("nhl", 3042003),
    "Vasily Podkolzin (NHL)": ("nhl", 4565231),
    "Victor Hedman (NHL)": ("nhl", 5157),
    "Victor Wembanyama (NBA)": ("nba", 5104157),
    "Vince Dunn (NHL)": ("nhl", 3904189),
    "Vincent Trocheck (NHL)": ("nhl", 2563036),
    "Vinnie Pasquantino (MLB)": ("mlb", 4109109),
    "Vladimir Guerrero Jr. (MLB)": ("mlb", 35002),
    "Vladislav Gavrikov (NHL)": ("nhl", 3942292),
    "Walker Kessler (NBA)": ("nba", 4433136),
    "Wan'Dale Robinson (NFL)": ("nfl", 4569587),
    "Wendell Carter Jr. (NBA)": ("nba", 4277847),
    "Wil Lutz (NFL)": ("nfl", 2985659),
    "Will Cuylle (NHL)": ("nhl", 4697468),
    "Will Reichard (NFL)": ("nfl", 4567104),
    "Will Smith (MLB)": ("mlb", 38309),
    "Will Smith (NHL)": ("nhl", 5149155),
    "Will Warren (MLB)": ("mlb", 5132011),
    "William Contreras (MLB)": ("mlb", 39895),
    "William Eklund (NHL)": ("nhl", 4874721),
    "William Nylander (NHL)": ("nhl", 3114736),
    "Willson Contreras (MLB)": ("mlb", 32532),
    "Willy Adames (MLB)": ("mlb", 33675),
    "Wilyer Abreu (MLB)": ("mlb", 4990055),
    "Woody Marks (NFL)": ("nfl", 4429059),
    "Wyatt Johnston (NHL)": ("nhl", 4874740),
    "Wyatt Langford (MLB)": ("mlb", 4719324),
    "Xavier Edwards (MLB)": ("mlb", 41326),
    "Xavier Hutchinson (NFL)": ("nfl", 4686422),
    "Xavier Worthy (NFL)": ("nfl", 4683062),
    "Yainer Diaz (MLB)": ("mlb", 4781491),
    "Yandy Diaz (MLB)": ("mlb", 33481),
    "Yaxel Lendeborg (NBA)": ("nba", 5175737),
    "Yordan Alvarez (MLB)": ("mlb", 36018),
    "Yoshinobu Yamamoto (MLB)": ("mlb", 4872587),
    "Yves Missi (NBA)": ("nba", 5061589),
    "Zac Gallen (MLB)": ("mlb", 39910),
    "Zaccharie Risacher (NBA)": ("nba", 5211175),
    "Zach Charbonnet (NFL)": ("nfl", 4426385),
    "Zach Edey (NBA)": ("nba", 4600663),
    "Zach Hyman (NHL)": ("nhl", 5509),
    "Zach LaVine (NBA)": ("nba", 3064440),
    "Zach Neto (MLB)": ("mlb", 4666100),
    "Zach Werenski (NHL)": ("nhl", 3899972),
    "Zack Gelof (MLB)": ("mlb", 4414531),
    "Zack Wheeler (MLB)": ("mlb", 31267),
    "Zay Flowers (NFL)": ("nfl", 4429615),
    "Zeev Buium (NHL)": ("nhl", 5206642),
    "Zion Williamson (NBA)": ("nba", 4395628),
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

def draw_gear(c, sport, number, primary, secondary):
    spec = SPORTS[sport]
    art = stamp_number(spec["art"], spec["digits"], number, spec["cx"], spec["top"])
    c.sprite(art, spec["x"], spec["y"], legend = palette(primary, secondary))

# ---------------------------------------------------------------- layout

def meta_line(c, x, y, team, pos, feet, inches, lbs, color):
    """TEAM . POS . 6'11" . 284 LB, with the foot/inch marks drawn as pixels."""
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

def stat_block(c, x, y, stats, tag, tag_color, accent):
    """Hero stat big with a stacked tag/label beside it; two more stacked small."""
    hv, hl = stats[0]
    c.text(hv, x, y, font = "9x12", color = "white")
    hx = x + c.text_width(hv, "9x12") + 2
    c.text(tag, hx, y + 1, font = "4x5", color = tag_color)
    c.text(hl, hx, y + 7, font = "4x5", color = accent)
    side = stats[1:3]
    vw, lw = 0, 0
    for (v, l) in side:
        vw = max(vw, c.text_width(v, "4x5"))
        lw = max(lw, c.text_width(l, "4x5"))
    # side column sits right of the hero, pushed against the right edge if needed
    tag_end = hx + max(c.text_width(tag, "4x5"), c.text_width(hl, "4x5"))
    rx = max(tag_end + 7, 96)
    rx = min(rx, 127 - vw - 3 - lw)
    c.vline(rx - 4, y + 2, 9, "#3A3A3A")
    # values right-aligned in one column, labels lined up after them
    for i in range(len(side)):
        v, l = side[i]
        yy = y + i * 6
        c.text(v, rx + vw - c.text_width(v, "4x5"), yy, font = "4x5", color = "white")
        c.text(l, rx + vw + 3, yy, font = "4x5", color = "gray")

LOGO_BOX = 19

def name_and_logo(c, x, last, logo, prefix):
    """Name top-left; team logo centred in a 19px box top-right, optionally led by @ / VS.
    Returns the x where the logo column starts, so the line below can stop short of it."""
    col = 128 - LOGO_BOX
    if logo:
        lw, lh = LOGO_SIZE.get(logo, (LOGO_BOX, LOGO_BOX))
        c.image(LOGOS[logo], 128 - LOGO_BOX + (LOGO_BOX - lw) // 2, (LOGO_BOX - lh) // 2)
    right = col
    if prefix:
        pw = c.text_width(prefix, "4x5")
        right = col - pw - 2
        c.text(prefix, right, 4, font = "4x5", color = "gray")
    room = right - 3 - x
    font = "7x12"
    if c.text_width(last, font) > room:
        font = "6x8"
    if c.text_width(last, font) > room:
        font = "4x5"
    c.text(last, x, {"7x12": -1, "6x8": 2, "4x5": 4}[font], font = font, color = "white")
    return col

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

DEFAULT_PLAYER = "Patrick Mahomes (NFL)"
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
        "logo": lg + "_" + abbr if (lg + "_" + abbr) in LOGOS else "",
        "color": team.get("color") or "8A8A8A",
        "alt": team.get("alternateColor") or "F0F0F0",
        "summary": summary,
    }

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
        return [(w("rushingYards"), "YDS"), (w("rushingTouchdowns"), "TD"), (w("receptions"), "REC")]
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
        return [("DNP", "")] + [("-", lab) for lab in labs[1:]]
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
        return [(f("rushingYards"), "YDS"), (f("rushingTouchdowns"), "TD"), (f("receptions"), "REC")]
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
    "nba": ["PTS", "REB", "AST"], "qb": ["YDS", "TD", "INT"], "rb": ["YDS", "TD", "REC"],
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
                return [(short(x.get("24")), "YDS"), (short(x.get("25")), "TD"), (short(x.get("53")), "REC")]
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

def message(c, line1, line2, color):
    """Two short lines, what happened and what to do, beside a grey jersey."""
    c.clear()
    draw_gear(c, "nba", "", "4A4A4A", "8A8A8A")
    c.text(line1, 35, 7, font = "6x8", color = color)
    c.text(line2, 35, 19, font = "4x5", color = "gray")

def pick_player(ctx):
    label = ctx.inputs.get("player", DEFAULT_PLAYER) or DEFAULT_PLAYER
    hit = PLAYERS.get(label)
    if hit == None:
        return None, "unknown"
    p = athlete(hit[0], hit[1])
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
    stats = season_stats(overview(p["lg"], p["id"]), p) or NO_STATS
    c.clear()
    draw_gear(c, p["lg"], p["num"], p["color"], p["alt"])
    name_and_logo(c, 35, p["last"], p["logo"], "")
    ac = accent(p["color"], p["alt"])
    # the logo names the team, so the bio line starts at the position
    meta_line(c, 35, 12, "" if p["logo"] else p["team"], p["pos"], p["ft"], p["in"], p["lbs"], ac)
    stat_block(c, 35, 19, stats, "SZN", "gray", ac)

def game(c, ctx):
    p, why = pick_player(ctx)
    if p == None:
        failed(c, why)
        return
    ov = overview(p["lg"], p["id"])
    ev = next_event(ov, ctx.now.unix)
    ac = accent(p["color"], p["alt"])
    c.clear()
    draw_gear(c, p["lg"], p["num"], p["color"], p["alt"])
    if ev == None:
        # offseason, or nothing on the schedule yet: say so and keep the season line
        stop = name_and_logo(c, 35, p["last"], p["logo"], "") - 3
        game_line(c, 35, 12, [("NO NEXT GAME", "gray")], stop)
        stat_block(c, 35, 19, season_stats(ov, p) or NO_STATS, "SZN", "gray", ac)
        return
    me, opp = {}, {}
    for comp in ev.get("competitors") or []:
        if str(comp.get("id")) == str(p["team_id"]):
            me = comp
        else:
            opp = comp
    opp_key = p["lg"] + "_" + (opp.get("abbreviation") or "").lower()
    stop = name_and_logo(c, 35, p["last"], opp_key if opp_key in LOGOS else "",
                         "@" if me.get("homeAway") == "away" else "VS") - 3
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
    game_line(c, 35, 12, [(day, "white"), (time, "white")], stop)
    proj = projection(p, ev)
    if proj:
        stat_block(c, 35, 19, proj, "PROJ", "#4FA3FF", ac)
    else:
        # no projection for this player (goalies, kickers, defenders): show the season line
        stat_block(c, 35, 19, season_stats(ov, p) or NO_STATS, "SZN", "gray", ac)
