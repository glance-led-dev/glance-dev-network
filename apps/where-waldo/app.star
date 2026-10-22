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

# Per-scene density in percent (non-EXTREME levels). Scenes with narrow ground bands
# get a little less so the full count always fits.
SCALE = {"GROCERY STORE": 90, "HOLLYWOOD": 90}

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
    "SKI SLOPES": {
        "shirts": ["#E63946", "#1D8FE1", "#F4A261", "#2A9D8F", "#8E44AD"],
        "pants": ["#1B263B", "#2B2D42", "#3A3A3A"],
        "hats": ["#1D8FE1", "#F4A261", "#2A9D8F"],
    },
    "GROCERY STORE": {
        "shirts": ["#2A9D8F", "#E9C46A", "#4895EF", "#9B5DE5", "#F4A261"],
        "pants": ["#264653", "#3A3A3A", "#7F5539"],
        "hats": ["#4895EF", "#2A9D8F", "#E9C46A"],
    },
    "MOVIE THEATER": {
        "shirts": ["#4895EF", "#F4A261", "#9B5DE5", "#2A9D8F", "#E9C46A"],
        "pants": ["#2B2D42", "#1D3557", "#3A3A3A"],
        "hats": ["#4895EF", "#2A9D8F", "#9B5DE5"],
    },
    "MUSIC CONCERT": {
        "shirts": ["#FF5AD1", "#4FD1FF", "#FFE45A", "#7CFF6B", "#FF8A3D"],
        "pants": ["#1B1442", "#2B2D42", "#3A1F6B"],
        "hats": ["#FF5AD1", "#4FD1FF", "#7CFF6B"],
    },
    "SPORTS STADIUM": {
        "shirts": ["#1D8FE1", "#F2C230", "#2A9D8F", "#8E44AD", "#F4A261"],
        "pants": ["#222222", "#F4F4F4", "#1B263B"],
        "hats": ["#1D8FE1", "#F2C230", "#2A9D8F"],
    },
    "CAMPSITE": {
        "shirts": ["#6B8E23", "#B8860B", "#4682B4", "#CD853F", "#556B2F"],
        "pants": ["#3B2F2F", "#2F4F4F", "#556B2F"],
        "hats": ["#B8860B", "#4682B4", "#6B8E23"],
    },
    "HOLLYWOOD": {
        "shirts": ["#F1C40F", "#9B59B6", "#1ABC9C", "#E91E63", "#3498DB"],
        "pants": ["#111111", "#2C3E50", "#6C3483"],
        "hats": ["#F1C40F", "#1ABC9C", "#3498DB"],
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

    # ===== SKI SLOPES =====
    "ski": mk("adult", ["..HHH..", "..gkg..", "..kkk..", ".SSSSS.", "KSSSSSK", "KSSSSSK", "K.P.P.K", "K.P.P.K", "QQQQQQQ"],
              pal={"K": "#2B2B2B", "Q": "#FFD23F"}, hero=True),
    "snowboard": mk("adult", ["..HHH..", "..gkg..", "..kkk..", "kSSSSSk", "..SSS..", "..P.P..", "QQQQQQQ"],
                    pal={"Q": "#1D8FE1"}, hero=True),
    "sled": mk("adult", [".HHH...", ".gkg...", ".kkk...", ".SSSk..", ".SSSPPP", "NNNNNNN", "KKKKKKK"],
               pal={"N": "#2A7FD4", "K": "#555555"}, hero=True),
    "lift_chair": mk("adult", ["..K..", "..K..", ".HHH.", ".gkg.", ".kkk.", "SSSSS", "SSSSS", "NNNNN", ".P.P."],
                     pal={"K": "#2B2B2B", "N": "#555555"}, hero=True),
    "chair_empty": mk("obj", ["..K..", "..K..", "..K..", "..K..", "..K..", "..K..", "..K..", "NNNNN", ".K.K."],
                      pal={"K": "#2B2B2B", "N": "#555555"}),
    "snowman": mk("obj", [".KKK.", ".WOW.", ".WWW.", "..W..", "WWWWW", "WWKWW", "WWWWW", ".WWW."],
                  pal={"K": "#222222", "W": "#FFFFFF", "O": "#F2761E"}),
    "pine": mk("obj", ["..G..", ".GGG.", "GGGGG", ".GGG.", "GGGGG", "GGGGG", "..T..", "..T.."],
               pal={"G": "#2F7D3A", "T": "#6B4A2B"}),
    "husky": mk("obj", ["N..NN.", "NNNNNK", ".NNNN.", ".N..N."], pal={"N": "#9AA5B1", "K": "#2B2B2B"}),
    "bird_fly": mk("obj", ["K...K", "KK.KK", ".KKK."], pal={"K": "#333333"}),
    "cabin": mk("obj", ["..WWWWW..", ".WWWWWWW.", "NNNNNNNNN", "NCCNNDDNN", "NCCNNDDNN", "NNNNNNNNN"],
                pal={"W": "#F4F4F4", "N": "#8A5A3A", "C": "#FFE27A", "D": "#4A2E1B"}),
    # ===== GROCERY STORE =====
    "cart_push": mk("adult", [".HHH......", ".gkg......", ".kkk......", "SSSSkKKKKK", "SSSS.KGGGK", "SSSS.KKKKK", ".P.P......", ".P.P..O.O."],
                    pal={"K": "#9AA5B1", "G": "#6BBF59", "O": "#222222"}, hero=True),
    "slip": mk("adult", ["kHHHk", "SgkgS", "SkkkS", ".SSS.", ".SSS.", ".P.P.", ".P.P.", ".....", ".YYY."],
               pal={"Y": "#F2C230"}, hero=True),
    "shop_cart": mk("obj", ["K.....", "KKKKKK", ".KGGK.", ".KKKK.", ".O..O."],
               pal={"K": "#9AA5B1", "G": "#E76F51", "O": "#222222"}),
    "produce": mk("obj", ["RROOYYGG", "RROOYYGG", "NNNNNNNN", "N......N", "N......N"],
                  pal={"R": "#E63946", "O": "#F4A261", "Y": "#F2C230", "G": "#6BBF59", "N": "#8A5A3A"}),
    "boxes": mk("obj", ["..NNN.", "NNNNNN", "NNKNNN", "NNNNNN", "NNNNNN"], pal={"N": "#B07A45", "K": "#8A5A3A"}),
    "bucket": mk("obj", [".K..", "KK..", "YYYY", "YYYY", ".YY."], pal={"K": "#555555", "Y": "#F2C230"}),
    "wetfloor": mk("obj", ["..Y..", ".YYY.", ".YKY.", "YYKYY", "YYYYY", "YYYYY"], pal={"Y": "#F2C230", "K": "#333333"}),
    "mouse": mk("obj", ["..G.", "GGGG", ".P.P"], pal={"G": "#9AA5B1", "P": "#E7A7B6"}),
    "sale_sign": mk("obj", ["K.....K"] * 5 + ["ABABABA", "ABABABA"], pal={"K": "#555555"}),
    "price_sign": mk("obj", ["K.....K"] * 5 + ["YYYYYYY", "YKYKYKY"], pal={"K": "#555555", "Y": "#F2C230"}),
    "exit_sign": mk("obj", ["K.....K"] * 5 + ["GGGGGGG", "GWGWGWG"], pal={"K": "#555555", "G": "#2E9E4F", "W": "#F4F4F4"}),
    # ===== MOVIE THEATER =====
    "popcorn": mk("adult", [".HHH....", ".gkg.YWY", ".kkk.ABA", "SSSSkBAB", "SSSS.ABA", "SSSS.BAB", ".P.P....", ".P.P...."],
                  pal={"Y": "#FFE27A", "W": "#F4F4F4"}, hero=True),
    "popcorn_machine": mk("obj", [".ABABA.", "KYWYWYK", "KWYWYWK", "KYWYWYK", "RRRRRRR", "RRRRRRR", "RKKKKKR", "RRRRRRR", ".K...K."],
                          pal={"K": "#2B2B2B", "Y": "#FFE27A", "W": "#F4F4F4", "R": "#C0392B"}),
    "arcade": mk("obj", ["KKKKK", "KCCCK", "KCCCK", "KKKKK", "KRKYK", "KKKKK", "K...K", "K...K"],
                 pal={"K": "#2B2B4B", "C": "#4FD1C5", "R": "#E63946", "Y": "#F2C230"}),
    "rope": mk("obj", ["K.....K", "KRRRRRK", "K.....K", "KK...KK"], pal={"K": "#C9A227", "R": "#C0392B"}),
    "spill": mk("obj", ["Y.W.Y", "WYWYW"], pal={"Y": "#FFE27A", "W": "#F4F4F4"}),
    "reel": mk("obj", [".KKK.", "KGKGK", "KKGKK", "KGKGK", ".KKK."], pal={"K": "#2B2B2B", "G": "#9AA5B1"}),
    "poster_star": mk("obj", ["KKKKKK", "KUUYUK", "KUYYYK", "KUUYUK", "KUYUYK", "KUUUUK", "KUUUUK", "KKKKKK"],
                      pal={"K": "#222222", "U": "#2A3A8C", "Y": "#FFD23F"}),
    "poster_rocket": mk("obj", ["KKKKKK", "KUUWUK", "KUWWWK", "KUWRWK", "KUWWWK", "KURYRK", "KUUYUK", "KKKKKK"],
                        pal={"K": "#222222", "U": "#1B2A5C", "W": "#F4F4F4", "R": "#E63946", "Y": "#FFD23F"}),
    "poster_heart": mk("obj", ["KKKKKK", "KPPPPK", "KPRPRK", "KPRRRK", "KPPRPK", "KPPPPK", "KPPPPK", "KKKKKK"],
                       pal={"K": "#222222", "P": "#7A2A5A", "R": "#FF5A8A"}),
    # ===== MUSIC CONCERT =====
    "singer": mk("adult", ["MHHH.", "Sgkg.", "Skkk.", "SSSSS", ".SSS.", ".SSS.", ".P.P.", ".P.P."],
                 pal={"M": "#CFCFCF"}, hero=True),
    "keys": mk("adult", ["..HHH..", "..gkg..", "..kkk..", ".SSSSS.", "kSSSSSk", "WKWKWKW", "K.....K"],
               pal={"W": "#F4F4F4", "K": "#2B2B2B"}, hero=True),
    "drummer": mk("adult", ["..HHH..", "..gkg..", "..kkk..", "kSSSSSk", ".SSSSS.", "YYDDDYY", "DDDYDDD", ".K...K."],
                  pal={"Y": "#F2C230", "D": "#C0392B", "K": "#2B2B2B"}, hero=True),
    "guitarist": mk("adult", [".HHH.....", ".gkg.....", ".kkk.....", "SSSSS....", "SNNNNNKKK", "SNNNNN...", ".P.P.....", ".P.P....."],
                    pal={"N": "#C0752B", "K": "#2B2B2B"}),
    "speaker": mk("obj", ["KKKK", "KGGK", "KGGK", "KKKK", "KGGK", "KKKK"], pal={"K": "#222222", "G": "#555555"}),
    "mic_stand": mk("obj", [".M.", ".K.", ".K.", ".K.", ".K.", ".K.", ".K.", "KKK"], pal={"M": "#CFCFCF", "K": "#222222"}),
    "phone": mk("adult", ["ZHHH.", "Sgkg.", "Skkk.", "SSSSS", ".SSS.", ".SSS.", ".P.P.", ".P.P."],
                pal={"Z": "#9FD8F0"}, hero=True),
    "cheer": mk("adult", ["kHHHk", "SgkgS", "SkkkS", ".SSS.", ".SSS.", ".SSS.", ".P.P.", ".P.P."], hero=True),
    "crowdsurf": mk("adult", ["HH......", "gkSSSPPP", "gkSSSPPP", "k.k.k.k."], stripe="col", hero=True),
    "glowstick": mk("obj", ["P", "P", "P"], pal={"P": "#FF5AD1"}),
    # ===== SPORTS STADIUM =====
    "kick": mk("adult", [".HHH....", ".gkg....", ".kkk....", "SSSSS...", "SSSSS...", ".SSS....", ".P.PPPOO", ".P....OO"],
               pal={"O": "#FFFFFF"}, hero=True),
    "throw": mk("adult", ["OHHH.", "Sgkg.", "Skkk.", "SSSSS", ".SSS.", ".SSS.", ".P.P.", ".P.P."],
                pal={"O": "#8A4B2A"}, hero=True),
    "flagfan": mk("adult", [".HHH.KAB", ".gkg.KBA", ".kkk.K..", "SSSSkK..", "SSSS.K..", "SSSS.K..", ".P.P....", ".P.P...."],
                  pal={"K": "#9AA5B1"}, hero=True),
    "ref": mk("obj", [".KKK.", ".sss.", ".sss.", "KWKWK", "WKWKW", "KWKWK", ".P.P.", ".P.P."],
              pal={"K": "#222222", "W": "#F4F4F4", "s": "#E0AC69", "P": "#222222"}),
    "mascot": mk("obj", ["K.....K", "OOOOOOO", "OKOOOKO", "OOOKOOO", ".OOOOO.", "OOKOKOO", "OOOOOOO", ".OO.OO.", ".KK.KK."],
                 pal={"O": "#F2761E", "K": "#222222"}),
    "goal": mk("obj", ["WWWWWWWW", "WKKKKKKW", "WKKKKKKW", "WKKKKKKW", "W......W"], pal={"W": "#F4F4F4", "K": "#6B7B8C"}),
    "soccerball": mk("obj", [".W.", "WKW", ".W."], pal={"W": "#F4F4F4", "K": "#222222"}),
    # ===== CAMPSITE =====
    "log_sit": mk("adult", [".HHH...", ".gkg...", ".kkk...", ".SSSk..", ".SSSPPP", "NNNNNNN", "NNNNNNN"],
                  pal={"N": "#6B4A2B"}, hero=True),
    "hike": mk("adult", ["..HHH..", "..gkg..", "..kkk..", "NSSSSS.", "NSSSSS.", ".SSSSS.", "..P.P..", "..P.P.."],
               pal={"N": "#B8860B"}, hero=True),
    "kneel_fire": mk("adult", [".HHH.....", ".gkg..Y..", ".kkk.RYR.", "SSSSkRYYR", "SSSS.NNNN", "PPPP.....", "P..P....."],
                     pal={"R": "#F2761E", "Y": "#FFE45A", "N": "#6B4A2B"}, hero=True),
    "campfire": mk("obj", ["..Y..", ".RYR.", "RRYRR", "NNNNN", ".NNN."], pal={"Y": "#FFE45A", "R": "#F2761E", "N": "#6B4A2B"}),
    "tent": mk("obj", ["....A....", "...ABA...", "..ABABA..", ".ABABABA.", "ABAKKKABA", "ABAKKKABA"], pal={"K": "#222222"}),
    "tent2": mk("obj", ["....G....", "...GGG...", "..GGGGG..", ".GGGGGGG.", "GGGKKKGGG", "GGGKKKGGG"],
                pal={"G": "#3E8E41", "K": "#222222"}),
    "bear_wild": mk("obj", ["....NN.", "NNNNNNN", "NNNNNNK", "NNNNNN.", ".N.N.N."], pal={"N": "#5C4033", "K": "#222222"}),
    "deer": mk("obj", ["....K.K", "....KKK", "....NNN", "..NNNN.", "NNNNNN.", "NNNNNN.", "N.N..N."],
               pal={"K": "#D2B48C", "N": "#A0522D"}),
    "squirrel": mk("obj", ["..N.", "NNN.", "NNNN", ".N.N"], pal={"N": "#B5651D"}),
    "bat": mk("obj", ["K...K", "KKKKK", ".K.K."], pal={"K": "#222222"}),
    "fireflies": mk("obj", ["Y.Y", ".Y."], pal={"Y": "#E8F05A"}),
    "log_pile": mk("obj", [".NNNNN.", "NNNNNNN", "NKNKNKN"], pal={"N": "#6B4A2B", "K": "#4A2E1B"}),
    "cooler": mk("obj", ["WWWWW", "UUUUU", "UUUUU", "UUUUU"], pal={"W": "#F4F4F4", "U": "#2A7FD4"}),
    "lantern": mk("obj", [".K.", "YYY", "YYY", "KKK"], pal={"K": "#2B2B2B", "Y": "#FFE27A"}),
    "canoe": mk("obj", ["N.......N", ".NNNNNNN.", "..NNNNN.."], pal={"N": "#B5651D"}),
    "mushroom": mk("obj", ["RWR", "RRR", ".N."], pal={"R": "#E63946", "W": "#F4F4F4", "N": "#E8D9B0"}),
    "rock": mk("obj", [".GG.", "GGGG"], pal={"G": "#7B8794"}),
    # ===== HOLLYWOOD =====
    "pose": mk("adult", [".HHH.", ".gkg.", ".kkk.", "SSSSS", "kSSSk", ".SSS.", ".P.P.", "P...P"], hero=True),
    "director": mk("adult", [".HHH...", ".gkg...", ".kkk...", ".SSSkMM", ".SSSPPP", "NNNNNNN", ".N...N.", ".N...N."],
                   pal={"N": "#6B4A2B", "M": "#F2C230"}, hero=True),
    "clapper": mk("obj", ["KWKWK", "WKWKW", "KKKKK", "KWWWK", "KKKKK"], pal={"K": "#222222", "W": "#F4F4F4"}),
    "camera": mk("obj", ["KK.KK", "KKKKK", "KKKKL", ".KKK.", "..K..", ".K.K.", "K...K"], pal={"K": "#2B2B2B", "L": "#9FD8F0"}),
    "limo": mk("obj", ["..KKKKKKKKKK..", "KKCCKCCKCCKKKK", "KKKKKKKKKKKKKY", ".WW........WW."],
               pal={"K": "#222222", "C": "#9FD8F0", "Y": "#FFE27A", "W": "#555555"}),
    "heli": mk("obj", ["KKKKKKK", "...K...", "KCCKKKK", "..K.K.."], pal={"K": "#2B2B2B", "C": "#9FD8F0"}),
    "palm": mk("obj", ["G.GGG.G", "GGGGGGG", ".G.N.G.", "...N...", "...N...", "...N...", "...N...", "...N...", "...N..."],
               pal={"G": "#2F9E44", "N": "#8A5A3A"}),
    "trophy": mk("obj", ["YYY", "YYY", ".Y.", ".Y.", "YYY"], pal={"Y": "#F2C230"}),
    "red_carpet": mk("obj", ["RRRRRRRRRRRR", "RRRRRRRRRRRR"], pal={"R": "#C0392B"}),
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
    "SKI SLOPES": [
        {"z": "sky", "w": 8, "lo": 3, "hi": 8, "names": ["bird_fly"]},
        {"z": "lift", "w": 14, "lo": 11, "hi": 11, "names": ["lift_chair", "lift_chair", "chair_empty"]},
        {"z": "slope", "w": 78, "lo": 20, "hi": 30,
         "names": ["stand", "walk", "run", "wave", "jump", "ski", "ski", "snowboard", "sled", "baby",
                   "snowman", "pine", "pine", "husky", "cabin"]},
    ],
    "GROCERY STORE": [
        {"z": "ceiling", "w": 8, "lo": 9, "hi": 9, "names": ["sale_sign", "price_sign", "exit_sign"]},
        {"z": "floor", "w": 92, "lo": 22, "hi": 30,
         "names": ["stand", "walk", "run", "wave", "jump", "cart_push", "cart_push", "slip", "baby", "crawl",
                   "cat", "dog", "mouse", "shop_cart", "produce", "boxes", "bucket", "wetfloor"]},
    ],
    "MOVIE THEATER": [
        {"z": "wall", "w": 14, "lo": 12, "hi": 12, "names": ["poster_star", "poster_rocket", "poster_heart"]},
        {"z": "lobby", "w": 86, "lo": 22, "hi": 30,
         "names": ["stand", "walk", "run", "wave", "jump", "popcorn", "popcorn", "sit", "baby", "crawl",
                   "cat", "mouse", "popcorn_machine", "arcade", "rope", "spill", "reel", "booth", "bin"]},
    ],
    "MUSIC CONCERT": [
        {"z": "stage", "w": 22, "lo": 15, "hi": 17,
         "names": ["singer", "keys", "drummer", "guitarist", "speaker", "mic_stand"]},
        {"z": "air", "w": 8, "lo": 16, "hi": 21, "names": ["ball", "balloon_p", "balloon_u"]},
        {"z": "surf", "w": 6, "lo": 20, "hi": 22, "names": ["crowdsurf"]},
        {"z": "crowd", "w": 64, "lo": 24, "hi": 30,
         "names": ["cheer", "cheer", "jump", "wave", "phone", "stand", "baby", "glowstick"]},
    ],
    "SPORTS STADIUM": [
        {"z": "stands", "w": 12, "lo": 12, "hi": 13, "names": ["cheer", "wave", "flagfan"]},
        {"z": "field", "w": 88, "lo": 21, "hi": 30,
         "names": ["stand", "run", "run", "jump", "kick", "throw", "wave", "ref", "mascot", "goal",
                   "soccerball", "cone", "dog_run"]},
    ],
    "CAMPSITE": [
        {"z": "sky", "w": 8, "lo": 3, "hi": 9, "names": ["bat", "fireflies"]},
        {"z": "ground", "w": 92, "lo": 21, "hi": 30,
         "names": ["stand", "walk", "hike", "wave", "jump", "log_sit", "kneel_fire", "lie", "baby", "crawl",
                   "campfire", "tent", "tent2", "bear_wild", "deer", "squirrel", "log_pile", "cooler",
                   "lantern", "canoe", "mushroom", "rock", "pine", "pine"]},
    ],
    "HOLLYWOOD": [
        {"z": "sky", "w": 6, "lo": 4, "hi": 6, "names": ["heli"]},
        {"z": "walk", "w": 74, "lo": 21, "hi": 26,
         "names": ["stand", "walk", "run", "wave", "jump", "pose", "pose", "director", "phone", "baby", "dog",
                   "clapper", "camera", "palm", "palm", "trophy", "red_carpet", "rope", "mic_stand"]},
        {"z": "road", "w": 20, "lo": 30, "hi": 30, "names": ["limo", "taxi", "bus"]},
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


def mix(a, b, pct):
    # blend colour a toward colour b by pct percent (used for soft light beams)
    out = "#"
    for i in range(3):
        va = int(a[1 + i * 2:3 + i * 2], 16)
        vb = int(b[1 + i * 2:3 + i * 2], 16)
        v = (va * (100 - pct) + vb * pct) // 100
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
# pops less. Bands overlap back-to-front so there are no seams.
# Each scene paints real ground bands that match its zones in THEME.


def disc(c, cx, cy, r, col):
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy <= r * r + 1:
                c.pixel(cx + dx, cy + dy, col)


def bg_beach(c, f):
    # sky 0-11, sea 12-17, sand 18-31
    x0 = BG_X0
    x1 = BG_X1
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


def bg_city(c, f):
    # sky 0-6, buildings end at 17, sidewalk 18-24, curb 25, road 26-31
    x0 = BG_X0
    x1 = BG_X1
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


def bg_fair(c, f):
    # striped tent wall 0-17, grass ground 18-31
    x0 = BG_X0
    x1 = BG_X1
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


def bg_ski(c, f):
    # sky + peaks 0-14, snow slope 14-31, chairlift cable at y=2 (chairs hang from it)
    x0 = BG_X0
    x1 = BG_X1
    c.rect(x0, 0, x1, 31, fill=shade("#7EC8F5", f))
    rock = shade("#7A8FA8", f)
    cap = shade("#FFFFFF", f)
    for k in range(11):
        cx = x0 + 12 + k * 29 + (k * 7) % 9
        hm = 7 + (k * 5) % 5
        for r in range(hm):
            yy = 14 - hm + r + 1
            c.rect(cx - r, yy, cx + r, yy, fill=cap if r < 3 else rock)
    c.rect(x0, 14, x1, 31, fill=shade("#E8F1F8", f))
    tree = shade("#2F7D3A", f)
    for x in range(x0, x1 + 1, 5):
        c.rect(x, 11 + (x * 7) % 3, x + 2, 14, fill=tree)
    c.rect(x0, 2, x1, 2, fill=shade("#2B2B2B", f))
    pole = shade("#444444", f)
    for x in range(x0 + 40, x1, 90):
        c.rect(x, 2, x + 1, 13, fill=pole)
    sh = shade("#C9DAE8", f)
    for y in range(16, 32):
        for x in range(x0, x1 + 1):
            if (x * 5 + y * 3) % 23 == 0:
                c.pixel(x, y, sh)


def bg_grocery(c, f):
    # ceiling 0-2, shelves 3-17, tiled floor 18-31
    x0 = BG_X0
    x1 = BG_X1
    c.rect(x0, 0, x1, 17, fill=shade("#CDBB9A", f))
    c.rect(x0, 0, x1, 2, fill=shade("#EDEDED", f))
    lamp = shade("#FFFBE0", f)
    for x in range(x0 + 10, x1, 44):
        c.rect(x, 1, x + 13, 1, fill=lamp)
    board = shade("#7A5230", f)
    c.rect(x0, 9, x1, 9, fill=board)
    c.rect(x0, 15, x1, 15, fill=board)
    c.rect(x0, 16, x1, 17, fill=shade("#5C3D22", f))
    prods = [shade(v, f) for v in ["#E63946", "#F4A261", "#E9C46A", "#2A9D8F", "#4895EF", "#9B5DE5", "#F15BB5", "#90BE6D"]]
    hs = [5, 4, 5, 3, 4, 5, 4, 3]
    for k in range(75):
        x = x0 + k * 4
        if x + 2 > x1:
            break
        c.rect(x, 9 - hs[k % 8], x + 2, 8, fill=prods[k % 8])
        c.rect(x, 15 - hs[(k * 3) % 8], x + 2, 14, fill=prods[(k * 3 + 2) % 8])
    c.rect(x0, 18, x1, 31, fill=shade("#D8D8D8", f))
    t2 = shade("#BFBFBF", f)
    for tile in range(37):
        x = x0 + tile * 8
        if x > x1:
            break
        if tile % 2 == 0:
            c.rect(x, 18, x + 7, 24, fill=t2)
        else:
            c.rect(x, 25, x + 7, 31, fill=t2)


def bg_theater(c, f):
    # lobby: marquee bulbs 0, wall 0-17 (posters hang at 5-12), carpet 18-31
    x0 = BG_X0
    x1 = BG_X1
    c.rect(x0, 0, x1, 31, fill=shade("#2B1B3D", f))
    gold = shade("#C9A227", f)
    c.rect(x0, 13, x1, 17, fill=shade("#3E2760", f))
    c.rect(x0, 13, x1, 13, fill=gold)
    bulb = shade("#FFE27A", f)
    for x in range(x0, x1 + 1, 6):
        c.pixel(x, 0, bulb)
    c.rect(x0, 18, x1, 31, fill=shade("#8E1B2D", f))
    for x in range(x0, x1 + 1, 12):
        for yy in (21, 27):
            c.pixel(x + 6, yy, gold)
            c.rect(x + 5, yy + 1, x + 7, yy + 1, fill=gold)
            c.pixel(x + 6, yy + 2, gold)


def bg_concert(c, f):
    # stage wall 0-13 with light beams, stage floor 14-17, crowd floor 18-31
    x0 = BG_X0
    x1 = BG_X1
    c.rect(x0, 0, x1, 31, fill=shade("#4B35B8", f))
    c.rect(x0, 0, x1, 1, fill=shade("#222233", f))
    spot = shade("#FFFFFF", f)
    for x in range(x0 + 4, x1, 10):
        c.pixel(x, 0, spot)
    wall = shade("#4B35B8", f)
    beams = [(30, "#FF5AD1"), (85, "#4FD1FF"), (140, "#FFE45A"), (195, "#7CFF6B"), (250, "#FF5AD1")]
    for b in beams:
        col = mix(wall, shade(b[1], f), 40)      # soft cone, not a solid shape
        for y in range(2, 14):
            half = 1 + y // 5
            c.rect(x0 + b[0] - half, y, x0 + b[0] + half, y, fill=col)
        c.rect(x0 + b[0] - 1, 1, x0 + b[0] + 1, 1, fill=shade(b[1], f))   # the lamp itself
    c.rect(x0, 14, x1, 17, fill=shade("#6B4A2B", f))
    c.rect(x0, 14, x1, 14, fill=shade("#8A6238", f))
    c.rect(x0, 18, x1, 31, fill=shade("#2A1A5E", f))
    c.rect(x0, 18, x1, 19, fill=shade("#6E4FE0", f))


def bg_stadium(c, f):
    # stands 0-12, ad boards 13-15, grass field 16-31
    x0 = BG_X0
    x1 = BG_X1
    c.rect(x0, 0, x1, 31, fill=shade("#3B4A6B", f))
    band = shade("#2B3A55", f)
    for y in range(1, 13, 2):
        c.rect(x0, y, x1, y, fill=band)
    fans = [shade(v, f) for v in ["#E63946", "#F2C230", "#4895EF", "#F4F4F4", "#7CFF6B"]]
    for y in range(1, 13):
        for x in range(x0, x1 + 1):
            if (x * 7 + y * 13) % 9 == 0:
                c.pixel(x, y, fans[(x + y) % 5])
    c.rect(x0 + 120, 1, x0 + 170, 8, fill=shade("#111111", f))
    amber = shade("#FFB000", f)
    for x in range(x0 + 124, x0 + 168, 6):
        c.rect(x, 3, x + 2, 5, fill=amber)
    ads = [shade(v, f) for v in ["#E63946", "#F2C230", "#1D8FE1", "#F4F4F4"]]
    for k in range(25):
        x = x0 + k * 12
        if x > x1:
            break
        c.rect(x, 13, x + 11, 15, fill=ads[k % 4])
    c.rect(x0, 16, x1, 31, fill=shade("#3E9B4F", f))
    mow = shade("#46A857", f)
    for x in range(x0, x1 + 1, 24):
        c.rect(x, 16, x + 11, 31, fill=mow)
    white = shade("#F4F4F4", f)
    c.rect(x0, 17, x1, 17, fill=white)
    cx = x0 + 147
    c.rect(cx, 17, cx, 31, fill=white)
    for dy in range(-7, 8):
        for dx in range(-7, 8):
            d2 = dx * dx + dy * dy
            if d2 >= 40 and d2 <= 56 and 26 + dy <= 31:
                c.pixel(cx + dx, 26 + dy, white)


def bg_camp(c, f):
    # dusk sky 0-10, pine treeline, forest floor 16-31
    x0 = BG_X0
    x1 = BG_X1
    c.rect(x0, 0, x1, 31, fill=shade("#1B1F4D", f))
    c.rect(x0, 5, x1, 31, fill=shade("#3B2F7A", f))
    c.rect(x0, 9, x1, 31, fill=shade("#B8507A", f))
    c.rect(x0, 12, x1, 31, fill=shade("#F2884B", f))
    star = shade("#FFFFFF", f)
    for y in range(0, 8):
        for x in range(x0, x1 + 1):
            if (x * 5 + y * 11) % 31 == 0:
                c.pixel(x, y, star)
    disc(c, x0 + 210, 5, 3, shade("#FFF3C4", f))
    c.rect(x0, 16, x1, 31, fill=shade("#2F5D34", f))
    tree = shade("#173B2A", f)
    for k in range(42):
        cx = x0 + 3 + k * 7
        if cx > x1 - 3:
            break
        sh = (k * 5) % 3
        c.pixel(cx, 9 + sh, tree)
        c.rect(cx - 1, 10 + sh, cx + 1, 11 + sh, fill=tree)
        c.rect(cx - 2, 12 + sh, cx + 2, 13 + sh, fill=tree)
        c.rect(cx - 3, 14 + sh, cx + 3, 16, fill=tree)
    blade = shade("#3E7A44", f)
    for y in range(17, 32):
        for x in range(x0, x1 + 1):
            if (x * 7 + y * 5) % 13 == 0:
                c.pixel(x, y, blade)


def bg_hollywood(c, f):
    # golden-hour sky 0-7, hills with the sign 7-19, walk of fame 19-26, curb 27, road 28-31
    x0 = BG_X0
    x1 = BG_X1
    c.rect(x0, 0, x1, 31, fill=shade("#F28AB2", f))
    c.rect(x0, 4, x1, 31, fill=shade("#FFC27A", f))
    beam = shade("#FFFFFF", f * 6 // 10)
    for bx in (60, 130, 215, 270):
        c.line(x0 + bx, 7, x0 + bx + 9, 0, beam)
    word = "HOLLYWOOD"
    tw = c.text_width(word, "5x7")
    sx = x0 + (BG_X1 - BG_X0 - tw) // 2
    hill = shade("#8A6B3A", f)
    for xx in range(x0, x1 + 1, 4):
        dist = 0
        if xx < sx - 6:
            dist = sx - 6 - xx
        elif xx > sx + tw + 2:
            dist = xx - (sx + tw + 2)
        top = 7 + dist // 5
        if top > 14:
            top = 14
        c.rect(xx, top, xx + 3, 19, fill=hill)
    scrub = shade("#5E7F3A", f)
    for y in range(9, 20):
        for x in range(x0, x1 + 1):
            if (x * 7 + y * 3) % 19 == 0:
                c.pixel(x, y, scrub)
    c.text(word, sx, 8, font="5x7", color=shade("#FFFFFF", f))
    c.rect(x0, 19, x1, 26, fill=shade("#B8B8C4", f))   # sidewalk
    gold = shade("#F2C230", f)
    star = ["..Y..", "YYYYY", ".YYY.", ".Y.Y.", "Y...Y"]
    for sxx in range(x0 + 6, x1 - 6, 22):
        for j in range(5):
            for i in range(5):
                if star[j][i] == "Y":
                    c.pixel(sxx + i, 20 + j, gold)
    c.rect(x0, 27, x1, 27, fill=shade("#8A8A96", f))   # curb
    c.rect(x0, 28, x1, 31, fill=shade("#3A3A44", f))   # road


def backdrop(c, crowd, f):
    if crowd == "BEACH":
        bg_beach(c, f)
    elif crowd == "CITY":
        bg_city(c, f)
    elif crowd == "FAIR":
        bg_fair(c, f)
    elif crowd == "SKI SLOPES":
        bg_ski(c, f)
    elif crowd == "GROCERY STORE":
        bg_grocery(c, f)
    elif crowd == "MOVIE THEATER":
        bg_theater(c, f)
    elif crowd == "MUSIC CONCERT":
        bg_concert(c, f)
    elif crowd == "SPORTS STADIUM":
        bg_stadium(c, f)
    elif crowd == "CAMPSITE":
        bg_camp(c, f)
    else:
        bg_hollywood(c, f)


# ---- screens ---------------------------------------------------------------
def error(c):
    c.fill("black")
    ctr(c, "BAD SETTING", 7, "5x7", "red")
    ctr(c, "SAVE AGAIN", 18, "5x7", "gray")


# The 7x12 face has no "?" or "!" glyphs (they draw as nothing, zero width),
# so for that face the punctuation is drawn by hand: 8 rows tall, 2 px strokes,
# to match the letters. Smaller faces use their own punctuation.
CAP = {"7x12": 8, "5x7": 7, "4x5": 5}
QMARK = ["011110", "111111", "110011", "000111", "001110", "000000", "001100", "001100"]
BANG = ["11", "11", "11", "11", "11", "00", "11", "11"]


def draw_punct(c, ch, x, y, col):
    rows = QMARK if ch == "?" else BANG
    for j in range(len(rows)):
        for i in range(len(rows[j])):
            if rows[j][i] == "1":
                c.pixel(x + i, y + j, col)


def left_label(c, word, name, punct, col):
    # Two stacked, left-aligned lines in x 30-77: WORD / NAME + punctuation.
    pw = 7 if punct == "?" else 3
    manual = False
    f = "7x12"
    if c.text_width(name, f) + pw <= 48 and c.text_width(word, f) <= 48:
        manual = True
        total = max(c.text_width(word, f), c.text_width(name, f) + pw)
    else:
        f = fit_font(c, name + punct, 48, ["5x7", "4x5"])
        total = max(c.text_width(word, f), c.text_width(name + punct, f))
    cap = CAP[f]
    y0 = (32 - (2 * cap + 4)) // 2
    y1 = y0 + cap + 4
    x = 30 + (48 - total) // 2
    c.text(word, x, y0, font=f, color=col)
    if manual:
        c.text(name, x, y1, font=f, color=col)
        draw_punct(c, punct, x + c.text_width(name, f) + 1, y1, col)
    else:
        c.text(name + punct, x, y1, font=f, color=col)


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
        left_label(c, "FOUND", name, "!", "green")
    else:
        left_label(c, "WHERE", name, "?", "white")
    draw(c, 10, 4, 3, SPR["stand"], hero(th), th)

    # The scene. Lower things are drawn later (in front); hero is always last.
    overlap = cfg[4] == "EXTREME"
    if not overlap:
        count = count * SCALE.get(cfg[3], 100) // 100
    people = build(get_seed(ctx), count, style, th, cfg[3], overlap)
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
