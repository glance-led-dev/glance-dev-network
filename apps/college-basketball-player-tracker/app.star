# College Basketball Player Tracker
# Seven compact live-stat pages: the five starters, then the top two bench scorers.

INK = "#F4F7FF"
DIM = "#738096"
LINE = "#263241"
LIVE = "#49D17D"
WARN = "#FFB347"
RED = "#FF4D5A"
DARK_LOSER = "#545B66"
ILLINOIS_PANEL = "#24344A"
ILLINOIS_BORDER = "#0B1424"

LEAGUES = {
    "MEN": "mens-college-basketball",
}

JERSEY = [
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

# Editable 20x20 jersey artwork used by the player pages.
# P = team primary color, D = dark team outline, W = white trim, . = transparent.
NATIVE_JERSEY_20 = [
    "....................",
    "....DDDDD..DDDDD....",
    "....DPPPD..DPPPD....",
    "....DPPPD..DPPPD....",
    "....DPPPD..DPPPD....",
    "....DPPPD..DPPPD....",
    "...DDPPPWDDWPPPDD...",
    "...DPPPPPWWPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DDDDDDDDDDDDDD...",
]

DIGITS = {
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

def clean(value, fallback = ""):
    text = str(value if value != None else "").strip()
    return text if text != "" else fallback

def upper(value, fallback = ""):
    return clean(value, fallback).upper()

def hex_color(value, fallback):
    text = clean(value).replace("#", "")
    return "#" + text if len(text) == 6 else fallback

HEX = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15}
HEX_CHARS = "0123456789ABCDEF"

def channel(text, offset):
    value = upper(text).replace("#", "")
    if len(value) != 6:
        return 0
    return HEX.get(value[offset], 0) * 16 + HEX.get(value[offset + 1], 0)

def rgb_hex(red, green, blue):
    return "#" + HEX_CHARS[red // 16] + HEX_CHARS[red % 16] + HEX_CHARS[green // 16] + HEX_CHARS[green % 16] + HEX_CHARS[blue // 16] + HEX_CHARS[blue % 16]

def darker_team_color(team):
    primary = hex_color(team.get("color"), "#263241")
    alternate = hex_color(team.get("alternateColor"), "#263241")
    candidates = []
    for color_value in [primary, alternate]:
        red = channel(color_value, 0)
        green = channel(color_value, 2)
        blue = channel(color_value, 4)
        brightness = red + green + blue
        orange_or_yellow = red > 150 and green > 65 and blue < 120
        white_or_bright = brightness > 480
        if not orange_or_yellow and not white_or_bright:
            candidates.append(color_value)
    if len(candidates) == 0:
        return ILLINOIS_PANEL
    chosen = candidates[0]
    chosen_sum = channel(chosen, 0) + channel(chosen, 2) + channel(chosen, 4)
    for candidate in candidates[1:]:
        candidate_sum = channel(candidate, 0) + channel(candidate, 2) + channel(candidate, 4)
        if candidate_sum < chosen_sum:
            chosen = candidate
            chosen_sum = candidate_sum
    return chosen

def team_tint(team_color, base_color):
    return rgb_hex(
        (channel(team_color, 0) + channel(base_color, 0) * 2) // 3,
        (channel(team_color, 2) + channel(base_color, 2) * 2) // 3,
        (channel(team_color, 4) + channel(base_color, 4) * 2) // 3,
    )

def dark_fill(color_value):
    return rgb_hex(channel(color_value, 0) // 5, channel(color_value, 2) // 5, channel(color_value, 4) // 5)

def color_brightness(color_value):
    return (channel(color_value, 0) * 299 + channel(color_value, 2) * 587 + channel(color_value, 4) * 114) // 1000

def readable_team_accent(team, background):
    # Keep the official primary hue whenever it reads clearly. Very dark team
    # colors are lifted toward white for tiny LED text without changing the
    # darker school-color background, dividers, border, or jersey treatment.
    if str(team.get("id")) == "57":
        return hex_color(team.get("alternateColor"), "#FA4616")
    primary = hex_color(team.get("color"), "#738096")
    difference = color_brightness(primary) - color_brightness(background)
    if difference < 0:
        difference = -difference
    if difference >= 120:
        return primary
    alternate = hex_color(team.get("alternateColor"), "#738096")
    alternate_difference = color_brightness(alternate) - color_brightness(background)
    if alternate_difference < 0:
        alternate_difference = -alternate_difference
    alternate_channels = [channel(alternate, 0), channel(alternate, 2), channel(alternate, 4)]
    alternate_max = max(alternate_channels)
    alternate_min = min(alternate_channels)
    # Use a real school secondary when it is both readable and visibly colored.
    # Neutral white/gray alternates are skipped so the page retains team identity.
    if alternate_difference >= 120 and alternate_max - alternate_min >= 40:
        return alternate
    return rgb_hex(
        (channel(primary, 0) + 255 * 3) // 4,
        (channel(primary, 2) + 255 * 3) // 4,
        (channel(primary, 4) + 255 * 3) // 4,
    )

def official_team_accent(team, background):
    # Team abbreviations must use an exact official color, never a generated
    # tint. Pick whichever of the primary or secondary reads best on the page.
    primary = hex_color(team.get("color"), INK)
    alternate = hex_color(team.get("alternateColor"), INK)
    background_brightness = color_brightness(background)
    primary_contrast = abs(color_brightness(primary) - background_brightness)
    alternate_contrast = abs(color_brightness(alternate) - background_brightness)
    return alternate if alternate_contrast > primary_contrast else primary

def get_json(url, ttl):
    response = http.get(url, ttl_seconds = ttl)
    if (response.get("status_code", 0) != 200 or response.get("json") == None) and "site.api.espn.com" in url:
        response = http.get(url.replace("site.api.espn.com", "site.web.api.espn.com"), ttl_seconds = ttl)
    if response.get("status_code", 0) != 200:
        return None
    return response.get("json")

# Verified ESPN IDs and school metadata, audited 2026-10-13. This directory
# keeps selection available when ESPN omits a school or its directory is down.
TEAM_DIRECTORY = {
    "ABILENE CHRISTIAN WILDCATS": {"id":"2000","displayName":"Abilene Christian Wildcats","location":"Abilene Christian","shortDisplayName":"Abilene Chrstn","abbreviation":"ACU","color":"592d82","alternateColor":"b1b3b3","slug":"abilene-christian-wildcats"},
    "AIR FORCE FALCONS": {"id":"2005","displayName":"Air Force Falcons","location":"Air Force","shortDisplayName":"Air Force","abbreviation":"AF","color":"003594","alternateColor":"ffffff","slug":"air-force-falcons"},
    "AKRON ZIPS": {"id":"2006","displayName":"Akron Zips","location":"Akron","shortDisplayName":"Akron","abbreviation":"AKR","color":"041e42","alternateColor":"c5b783","slug":"akron-zips"},
    "ALABAMA A&M BULLDOGS": {"id":"2010","displayName":"Alabama A&M Bulldogs","location":"Alabama A&M","shortDisplayName":"Alabama A&M","abbreviation":"AAMU","color":"790000","alternateColor":"ffffff","slug":"alabama-am-bulldogs"},
    "ALABAMA CRIMSON TIDE": {"id":"333","displayName":"Alabama Crimson Tide","location":"Alabama","shortDisplayName":"Alabama","abbreviation":"ALA","color":"9e1b32","alternateColor":"ffffff","slug":"alabama-crimson-tide"},
    "ALABAMA STATE HORNETS": {"id":"2011","displayName":"Alabama State Hornets","location":"Alabama State","shortDisplayName":"Alabama St","abbreviation":"ALST","color":"e9a900","alternateColor":"0a0a0a","slug":"alabama-state-hornets"},
    "ALCORN STATE BRAVES": {"id":"2016","displayName":"Alcorn State Braves","location":"Alcorn State","shortDisplayName":"Alcorn St","abbreviation":"ALCN","color":"4b0058","alternateColor":"46166a","slug":"alcorn-state-braves"},
    "AMERICAN UNIVERSITY EAGLES": {"id":"44","displayName":"American University Eagles","location":"American University","shortDisplayName":"American","abbreviation":"AMER","color":"c41130","alternateColor":"c8102e","slug":"american-university-eagles"},
    "APP STATE MOUNTAINEERS": {"id":"2026","displayName":"App State Mountaineers","location":"App State","shortDisplayName":"App State","abbreviation":"APP","color":"000000","alternateColor":"ffcd00","slug":"app-state-mountaineers"},
    "ARIZONA STATE SUN DEVILS": {"id":"9","displayName":"Arizona State Sun Devils","location":"Arizona State","shortDisplayName":"Arizona St","abbreviation":"ASU","color":"ffc627","alternateColor":"8c1d40","slug":"arizona-state-sun-devils"},
    "ARIZONA WILDCATS": {"id":"12","displayName":"Arizona Wildcats","location":"Arizona","shortDisplayName":"Arizona","abbreviation":"ARIZ","color":"cc0033","alternateColor":"003366","slug":"arizona-wildcats"},
    "ARKANSAS RAZORBACKS": {"id":"8","displayName":"Arkansas Razorbacks","location":"Arkansas","shortDisplayName":"Arkansas","abbreviation":"ARK","color":"a32136","alternateColor":"ffffff","slug":"arkansas-razorbacks"},
    "ARKANSAS STATE RED WOLVES": {"id":"2032","displayName":"Arkansas State Red Wolves","location":"Arkansas State","shortDisplayName":"Arkansas St","abbreviation":"ARST","color":"cc092f","alternateColor":"000000","slug":"arkansas-state-red-wolves"},
    "ARKANSAS-PINE BLUFF GOLDEN LIONS": {"id":"2029","displayName":"Arkansas-Pine Bluff Golden Lions","location":"Arkansas-Pine Bluff","shortDisplayName":"AR-Pine Bluff","abbreviation":"UAPB","color":"e0aa0f","alternateColor":"eaaa00","slug":"arkansas-pine-bluff-golden-lions"},
    "ARMY BLACK KNIGHTS": {"id":"349","displayName":"Army Black Knights","location":"Army","shortDisplayName":"Army","abbreviation":"ARMY","color":"000000","alternateColor":"d3bc8d","slug":"army-black-knights"},
    "AUBURN TIGERS": {"id":"2","displayName":"Auburn Tigers","location":"Auburn","shortDisplayName":"Auburn","abbreviation":"AUB","color":"002b5c","alternateColor":"f26522","slug":"auburn-tigers"},
    "AUSTIN PEAY GOVERNORS": {"id":"2046","displayName":"Austin Peay Governors","location":"Austin Peay","shortDisplayName":"Austin Peay","abbreviation":"APSU","color":"8e0b0b","alternateColor":"","slug":"austin-peay-governors"},
    "BYU COUGARS": {"id":"252","displayName":"BYU Cougars","location":"BYU","shortDisplayName":"BYU","abbreviation":"BYU","color":"0047ba","alternateColor":"002e5d","slug":"byu-cougars"},
    "BALL STATE CARDINALS": {"id":"2050","displayName":"Ball State Cardinals","location":"Ball State","shortDisplayName":"Ball State","abbreviation":"BALL","color":"ba0c2f","alternateColor":"ffffff","slug":"ball-state-cardinals"},
    "BAYLOR BEARS": {"id":"239","displayName":"Baylor Bears","location":"Baylor","shortDisplayName":"Baylor","abbreviation":"BAY","color":"154734","alternateColor":"ffb81c","slug":"baylor-bears"},
    "BELLARMINE KNIGHTS": {"id":"91","displayName":"Bellarmine Knights","location":"Bellarmine","shortDisplayName":"Bellarmine","abbreviation":"BELL","color":"000000","alternateColor":"","slug":"bellarmine-knights"},
    "BELMONT BRUINS": {"id":"2057","displayName":"Belmont Bruins","location":"Belmont","shortDisplayName":"Belmont","abbreviation":"BEL","color":"182142","alternateColor":"c9262d","slug":"belmont-bruins"},
    "BETHUNE-COOKMAN WILDCATS": {"id":"2065","displayName":"Bethune-Cookman Wildcats","location":"Bethune-Cookman","shortDisplayName":"Bethune","abbreviation":"BCU","color":"7b1831","alternateColor":"e9aa12","slug":"bethune-cookman-wildcats"},
    "BINGHAMTON BEARCATS": {"id":"2066","displayName":"Binghamton Bearcats","location":"Binghamton","shortDisplayName":"Binghamton","abbreviation":"BING","color":"00614A","alternateColor":"f0f0f0","slug":"binghamton-bearcats"},
    "BOISE STATE BRONCOS": {"id":"68","displayName":"Boise State Broncos","location":"Boise State","shortDisplayName":"Boise St","abbreviation":"BOIS","color":"0033a0","alternateColor":"d64309","slug":"boise-state-broncos"},
    "BOSTON COLLEGE EAGLES": {"id":"103","displayName":"Boston College Eagles","location":"Boston College","shortDisplayName":"Boston College","abbreviation":"BC","color":"8c2232","alternateColor":"dbcca6","slug":"boston-college-eagles"},
    "BOSTON UNIVERSITY TERRIERS": {"id":"104","displayName":"Boston University Terriers","location":"Boston University","shortDisplayName":"Boston U","abbreviation":"BU","color":"cc0000","alternateColor":"ffffff","slug":"boston-university-terriers"},
    "BOWLING GREEN FALCONS": {"id":"189","displayName":"Bowling Green Falcons","location":"Bowling Green","shortDisplayName":"Bowling Green","abbreviation":"BGSU","color":"fd5000","alternateColor":"4f2c1d","slug":"bowling-green-falcons"},
    "BRADLEY BRAVES": {"id":"71","displayName":"Bradley Braves","location":"Bradley","shortDisplayName":"Bradley","abbreviation":"BRAD","color":"b70002","alternateColor":"c0c0c0","slug":"bradley-braves"},
    "BROWN BEARS": {"id":"225","displayName":"Brown Bears","location":"Brown","shortDisplayName":"Brown","abbreviation":"BRWN","color":"411e09","alternateColor":"949300","slug":"brown-bears"},
    "BRYANT BULLDOGS": {"id":"2803","displayName":"Bryant Bulldogs","location":"Bryant","shortDisplayName":"Bryant","abbreviation":"BRY","color":"000000","alternateColor":"9f8343","slug":"bryant-bulldogs"},
    "BUCKNELL BISON": {"id":"2083","displayName":"Bucknell Bison","location":"Bucknell","shortDisplayName":"Bucknell","abbreviation":"BUCK","color":"000060","alternateColor":"00316e","slug":"bucknell-bison"},
    "BUFFALO BULLS": {"id":"2084","displayName":"Buffalo Bulls","location":"Buffalo","shortDisplayName":"Buffalo","abbreviation":"BUF","color":"005bbb","alternateColor":"ffffff","slug":"buffalo-bulls"},
    "BUTLER BULLDOGS": {"id":"2086","displayName":"Butler Bulldogs","location":"Butler","shortDisplayName":"Butler","abbreviation":"BTLR","color":"0d1361","alternateColor":"00a3e0","slug":"butler-bulldogs"},
    "CAL POLY MUSTANGS": {"id":"13","displayName":"Cal Poly Mustangs","location":"Cal Poly","shortDisplayName":"Cal Poly","abbreviation":"CP","color":"1E4D2B","alternateColor":"eed897","slug":"cal-poly-mustangs"},
    "CAL STATE BAKERSFIELD ROADRUNNERS": {"id":"2934","displayName":"Cal State Bakersfield Roadrunners","location":"Cal State Bakersfield","shortDisplayName":"Bakersfield","abbreviation":"CSUB","color":"003BAB","alternateColor":"","slug":"cal-state-bakersfield-roadrunners"},
    "CAL STATE FULLERTON TITANS": {"id":"2239","displayName":"Cal State Fullerton Titans","location":"Cal State Fullerton","shortDisplayName":"Fullerton","abbreviation":"CSUF","color":"003767","alternateColor":"ff8300","slug":"cal-state-fullerton-titans"},
    "CAL STATE NORTHRIDGE MATADORS": {"id":"2463","displayName":"Cal State Northridge Matadors","location":"Cal State Northridge","shortDisplayName":"CSU Northridge","abbreviation":"CSUN","color":"b50000","alternateColor":"","slug":"cal-state-northridge-matadors"},
    "CALIFORNIA BAPTIST LANCERS": {"id":"2856","displayName":"California Baptist Lancers","location":"California Baptist","shortDisplayName":"CA Baptist","abbreviation":"CBU","color":"000080","alternateColor":"","slug":"california-baptist-lancers"},
    "CALIFORNIA GOLDEN BEARS": {"id":"25","displayName":"California Golden Bears","location":"California","shortDisplayName":"California","abbreviation":"CAL","color":"041e42","alternateColor":"ffc72c","slug":"california-golden-bears"},
    "CAMPBELL FIGHTING CAMELS": {"id":"2097","displayName":"Campbell Fighting Camels","location":"Campbell","shortDisplayName":"Campbell","abbreviation":"CAM","color":"000000","alternateColor":"","slug":"campbell-fighting-camels"},
    "CANISIUS GOLDEN GRIFFINS": {"id":"2099","displayName":"Canisius Golden Griffins","location":"Canisius","shortDisplayName":"Canisius","abbreviation":"CAN","color":"004a81","alternateColor":"dda50f","slug":"canisius-golden-griffins"},
    "CENTRAL ARKANSAS BEARS": {"id":"2110","displayName":"Central Arkansas Bears","location":"Central Arkansas","shortDisplayName":"C Arkansas","abbreviation":"CARK","color":"a7a9ac","alternateColor":"8e959a","slug":"central-arkansas-bears"},
    "CENTRAL CONNECTICUT BLUE DEVILS": {"id":"2115","displayName":"Central Connecticut Blue Devils","location":"Central Connecticut","shortDisplayName":"C Connecticut","abbreviation":"CCSU","color":"1B49A2","alternateColor":"d1d5d8","slug":"central-connecticut-blue-devils"},
    "CENTRAL MICHIGAN CHIPPEWAS": {"id":"2117","displayName":"Central Michigan Chippewas","location":"Central Michigan","shortDisplayName":"C Michigan","abbreviation":"CMU","color":"4c0027","alternateColor":"fbab18","slug":"central-michigan-chippewas"},
    "CHARLESTON COUGARS": {"id":"232","displayName":"Charleston Cougars","location":"Charleston","shortDisplayName":"Charleston","abbreviation":"COFC","color":"7a2531","alternateColor":"9e8959","slug":"charleston-cougars"},
    "CHARLESTON SOUTHERN BUCCANEERS": {"id":"2127","displayName":"Charleston Southern Buccaneers","location":"Charleston Southern","shortDisplayName":"Charleston So","abbreviation":"CHSO","color":"2e3192","alternateColor":"ded090","slug":"charleston-southern-buccaneers"},
    "CHARLOTTE 49ERS": {"id":"2429","displayName":"Charlotte 49ers","location":"Charlotte","shortDisplayName":"Charlotte","abbreviation":"CLT","color":"005035","alternateColor":"a49665","slug":"charlotte-49ers"},
    "CHATTANOOGA MOCS": {"id":"236","displayName":"Chattanooga Mocs","location":"Chattanooga","shortDisplayName":"Chattanooga","abbreviation":"UTC","color":"00386b","alternateColor":"dca71d","slug":"chattanooga-mocs"},
    "CHICAGO STATE COUGARS": {"id":"2130","displayName":"Chicago State Cougars","location":"Chicago State","shortDisplayName":"Chicago St","abbreviation":"CHST","color":"006700","alternateColor":"","slug":"chicago-state-cougars"},
    "CINCINNATI BEARCATS": {"id":"2132","displayName":"Cincinnati Bearcats","location":"Cincinnati","shortDisplayName":"Cincinnati","abbreviation":"CIN","color":"000000","alternateColor":"e00122","slug":"cincinnati-bearcats"},
    "CLEMSON TIGERS": {"id":"228","displayName":"Clemson Tigers","location":"Clemson","shortDisplayName":"Clemson","abbreviation":"CLEM","color":"f56600","alternateColor":"ffffff","slug":"clemson-tigers"},
    "CLEVELAND STATE VIKINGS": {"id":"325","displayName":"Cleveland State Vikings","location":"Cleveland State","shortDisplayName":"Cleveland St","abbreviation":"CLE","color":"006633","alternateColor":"231f20","slug":"cleveland-state-vikings"},
    "COASTAL CAROLINA CHANTICLEERS": {"id":"324","displayName":"Coastal Carolina Chanticleers","location":"Coastal Carolina","shortDisplayName":"Coastal","abbreviation":"CCU","color":"006f71","alternateColor":"a27752","slug":"coastal-carolina-chanticleers"},
    "COLGATE RAIDERS": {"id":"2142","displayName":"Colgate Raiders","location":"Colgate","shortDisplayName":"Colgate","abbreviation":"COLG","color":"821019","alternateColor":"ffffff","slug":"colgate-raiders"},
    "COLORADO BUFFALOES": {"id":"38","displayName":"Colorado Buffaloes","location":"Colorado","shortDisplayName":"Colorado","abbreviation":"COLO","color":"cfb87c","alternateColor":"000000","slug":"colorado-buffaloes"},
    "COLORADO STATE RAMS": {"id":"36","displayName":"Colorado State Rams","location":"Colorado State","shortDisplayName":"Colorado St","abbreviation":"CSU","color":"004c23","alternateColor":"c8c372","slug":"colorado-state-rams"},
    "COLUMBIA LIONS": {"id":"171","displayName":"Columbia Lions","location":"Columbia","shortDisplayName":"Columbia","abbreviation":"COLU","color":"7ba4db","alternateColor":"183863","slug":"columbia-lions"},
    "COPPIN STATE EAGLES": {"id":"2154","displayName":"Coppin State Eagles","location":"Coppin State","shortDisplayName":"Coppin St","abbreviation":"COPP","color":"2e3192","alternateColor":"ffd204","slug":"coppin-state-eagles"},
    "CORNELL BIG RED": {"id":"172","displayName":"Cornell Big Red","location":"Cornell","shortDisplayName":"Cornell","abbreviation":"COR","color":"b31b1b","alternateColor":"ffffff","slug":"cornell-big-red"},
    "CREIGHTON BLUEJAYS": {"id":"156","displayName":"Creighton Bluejays","location":"Creighton","shortDisplayName":"Creighton","abbreviation":"CREI","color":"005ca9","alternateColor":"6cadde","slug":"creighton-bluejays"},
    "DARTMOUTH BIG GREEN": {"id":"159","displayName":"Dartmouth Big Green","location":"Dartmouth","shortDisplayName":"Dartmouth","abbreviation":"DART","color":"005730","alternateColor":"000000","slug":"dartmouth-big-green"},
    "DAVIDSON WILDCATS": {"id":"2166","displayName":"Davidson Wildcats","location":"Davidson","shortDisplayName":"Davidson","abbreviation":"DAV","color":"000000","alternateColor":"e51837","slug":"davidson-wildcats"},
    "DAYTON FLYERS": {"id":"2168","displayName":"Dayton Flyers","location":"Dayton","shortDisplayName":"Dayton","abbreviation":"DAY","color":"004B8D","alternateColor":"ffffff","slug":"dayton-flyers"},
    "DEPAUL BLUE DEMONS": {"id":"305","displayName":"DePaul Blue Demons","location":"DePaul","shortDisplayName":"DePaul","abbreviation":"DEP","color":"2d649c","alternateColor":"ce1125","slug":"depaul-blue-demons"},
    "DELAWARE BLUE HENS": {"id":"48","displayName":"Delaware Blue Hens","location":"Delaware","shortDisplayName":"Delaware","abbreviation":"DEL","color":"00539f","alternateColor":"ffd200","slug":"delaware-blue-hens"},
    "DELAWARE STATE HORNETS": {"id":"2169","displayName":"Delaware State Hornets","location":"Delaware State","shortDisplayName":"Delaware St","abbreviation":"DSU","color":"009cdb","alternateColor":"d51c28","slug":"delaware-state-hornets"},
    "DENVER PIONEERS": {"id":"2172","displayName":"Denver Pioneers","location":"Denver","shortDisplayName":"Denver","abbreviation":"DEN","color":"98002e","alternateColor":"a8996e","slug":"denver-pioneers"},
    "DETROIT MERCY TITANS": {"id":"2174","displayName":"Detroit Mercy Titans","location":"Detroit Mercy","shortDisplayName":"Detroit Mercy","abbreviation":"DETM","color":"165b9e","alternateColor":"d31733","slug":"detroit-mercy-titans"},
    "DRAKE BULLDOGS": {"id":"2181","displayName":"Drake Bulldogs","location":"Drake","shortDisplayName":"Drake","abbreviation":"DRKE","color":"005596","alternateColor":"bec0c2","slug":"drake-bulldogs"},
    "DREXEL DRAGONS": {"id":"2182","displayName":"Drexel Dragons","location":"Drexel","shortDisplayName":"Drexel","abbreviation":"DREX","color":"020260","alternateColor":"ffd65a","slug":"drexel-dragons"},
    "DUKE BLUE DEVILS": {"id":"150","displayName":"Duke Blue Devils","location":"Duke","shortDisplayName":"Duke","abbreviation":"DUKE","color":"00539b","alternateColor":"ffffff","slug":"duke-blue-devils"},
    "DUQUESNE DUKES": {"id":"2184","displayName":"Duquesne Dukes","location":"Duquesne","shortDisplayName":"Duquesne","abbreviation":"DUQ","color":"002D62","alternateColor":"b90b2e","slug":"duquesne-dukes"},
    "EAST CAROLINA PIRATES": {"id":"151","displayName":"East Carolina Pirates","location":"East Carolina","shortDisplayName":"East Carolina","abbreviation":"ECU","color":"582c83","alternateColor":"ffc72c","slug":"east-carolina-pirates"},
    "EAST TENNESSEE STATE BUCCANEERS": {"id":"2193","displayName":"East Tennessee State Buccaneers","location":"East Tennessee State","shortDisplayName":"ETSU","abbreviation":"ETSU","color":"002d61","alternateColor":"ffc423","slug":"east-tennessee-state-buccaneers"},
    "EAST TEXAS A&M LIONS": {"id":"2837","displayName":"East Texas A&M Lions","location":"East Texas A&M","shortDisplayName":"East Texas A&M","abbreviation":"ETAM","color":"000000","alternateColor":"","slug":"east-texas-am-lions"},
    "EASTERN ILLINOIS PANTHERS": {"id":"2197","displayName":"Eastern Illinois Panthers","location":"Eastern Illinois","shortDisplayName":"E Illinois","abbreviation":"EIU","color":"000000","alternateColor":"bebab9","slug":"eastern-illinois-panthers"},
    "EASTERN KENTUCKY COLONELS": {"id":"2198","displayName":"Eastern Kentucky Colonels","location":"Eastern Kentucky","shortDisplayName":"E Kentucky","abbreviation":"EKU","color":"660819","alternateColor":"f0f0f0","slug":"eastern-kentucky-colonels"},
    "EASTERN MICHIGAN EAGLES": {"id":"2199","displayName":"Eastern Michigan Eagles","location":"Eastern Michigan","shortDisplayName":"E Michigan","abbreviation":"EMU","color":"006938","alternateColor":"ffffff","slug":"eastern-michigan-eagles"},
    "EASTERN WASHINGTON EAGLES": {"id":"331","displayName":"Eastern Washington Eagles","location":"Eastern Washington","shortDisplayName":"E Washington","abbreviation":"EWU","color":"a10022","alternateColor":"abb4bc","slug":"eastern-washington-eagles"},
    "ELON PHOENIX": {"id":"2210","displayName":"Elon Phoenix","location":"Elon","shortDisplayName":"Elon","abbreviation":"ELON","color":"020303","alternateColor":"b59a57","slug":"elon-phoenix"},
    "EVANSVILLE PURPLE ACES": {"id":"339","displayName":"Evansville Purple Aces","location":"Evansville","shortDisplayName":"Evansville","abbreviation":"EVAN","color":"663399","alternateColor":"ef6f00","slug":"evansville-purple-aces"},
    "FAIRFIELD STAGS": {"id":"2217","displayName":"Fairfield Stags","location":"Fairfield","shortDisplayName":"Fairfield","abbreviation":"FAIR","color":"000000","alternateColor":"ebebeb","slug":"fairfield-stags"},
    "FAIRLEIGH DICKINSON KNIGHTS": {"id":"161","displayName":"Fairleigh Dickinson Knights","location":"Fairleigh Dickinson","shortDisplayName":"FDU","abbreviation":"FDU","color":"72293c","alternateColor":"28334a","slug":"fairleigh-dickinson-knights"},
    "FLORIDA A&M RATTLERS": {"id":"50","displayName":"Florida A&M Rattlers","location":"Florida A&M","shortDisplayName":"Florida A&M","abbreviation":"FAMU","color":"F89728","alternateColor":"00843d","slug":"florida-am-rattlers"},
    "FLORIDA ATLANTIC OWLS": {"id":"2226","displayName":"Florida Atlantic Owls","location":"Florida Atlantic","shortDisplayName":"FAU","abbreviation":"FAU","color":"003366","alternateColor":"cc0000","slug":"florida-atlantic-owls"},
    "FLORIDA GATORS": {"id":"57","displayName":"Florida Gators","location":"Florida","shortDisplayName":"Florida","abbreviation":"FLA","color":"0021a5","alternateColor":"fa4616","slug":"florida-gators"},
    "FLORIDA GULF COAST EAGLES": {"id":"526","displayName":"Florida Gulf Coast Eagles","location":"Florida Gulf Coast","shortDisplayName":"FGCU","abbreviation":"FGCU","color":"00885a","alternateColor":"076c3b","slug":"florida-gulf-coast-eagles"},
    "FLORIDA INTERNATIONAL PANTHERS": {"id":"2229","displayName":"Florida International Panthers","location":"Florida International","shortDisplayName":"FIU","abbreviation":"FIU","color":"091f3f","alternateColor":"c3993f","slug":"florida-international-panthers"},
    "FLORIDA STATE SEMINOLES": {"id":"52","displayName":"Florida State Seminoles","location":"Florida State","shortDisplayName":"Florida St","abbreviation":"FSU","color":"782f40","alternateColor":"ceb888","slug":"florida-state-seminoles"},
    "FORDHAM RAMS": {"id":"2230","displayName":"Fordham Rams","location":"Fordham","shortDisplayName":"Fordham","abbreviation":"FOR","color":"830032","alternateColor":"909090","slug":"fordham-rams"},
    "FRESNO STATE BULLDOGS": {"id":"278","displayName":"Fresno State Bulldogs","location":"Fresno State","shortDisplayName":"Fresno St","abbreviation":"FRES","color":"b1102b","alternateColor":"13284c","slug":"fresno-state-bulldogs"},
    "FURMAN PALADINS": {"id":"231","displayName":"Furman Paladins","location":"Furman","shortDisplayName":"Furman","abbreviation":"FUR","color":"582c83","alternateColor":"ffffff","slug":"furman-paladins"},
    "GARDNER-WEBB RUNNIN' BULLDOGS": {"id":"2241","displayName":"Gardner-Webb Runnin' Bulldogs","location":"Gardner-Webb","shortDisplayName":"Gardner-Webb","abbreviation":"GWEB","color":"c12535","alternateColor":"909090","slug":"gardner-webb-runnin-bulldogs"},
    "GEORGE MASON PATRIOTS": {"id":"2244","displayName":"George Mason Patriots","location":"George Mason","shortDisplayName":"George Mason","abbreviation":"GMU","color":"016600","alternateColor":"ecb010","slug":"george-mason-patriots"},
    "GEORGE WASHINGTON REVOLUTIONARIES": {"id":"45","displayName":"George Washington Revolutionaries","location":"George Washington","shortDisplayName":"G Washington","abbreviation":"GW","color":"002843","alternateColor":"e8d2a1","slug":"george-washington-revolutionaries"},
    "GEORGETOWN HOYAS": {"id":"46","displayName":"Georgetown Hoyas","location":"Georgetown","shortDisplayName":"Georgetown","abbreviation":"GTWN","color":"110E42","alternateColor":"001c58","slug":"georgetown-hoyas"},
    "GEORGIA BULLDOGS": {"id":"61","displayName":"Georgia Bulldogs","location":"Georgia","shortDisplayName":"Georgia","abbreviation":"UGA","color":"ba0c2f","alternateColor":"2c2a29","slug":"georgia-bulldogs"},
    "GEORGIA SOUTHERN EAGLES": {"id":"290","displayName":"Georgia Southern Eagles","location":"Georgia Southern","shortDisplayName":"GA Southern","abbreviation":"GASO","color":"041e42","alternateColor":"a3aaae","slug":"georgia-southern-eagles"},
    "GEORGIA STATE PANTHERS": {"id":"2247","displayName":"Georgia State Panthers","location":"Georgia State","shortDisplayName":"Georgia St","abbreviation":"GAST","color":"0039a6","alternateColor":"ffffff","slug":"georgia-state-panthers"},
    "GEORGIA TECH YELLOW JACKETS": {"id":"59","displayName":"Georgia Tech Yellow Jackets","location":"Georgia Tech","shortDisplayName":"Georgia Tech","abbreviation":"GT","color":"b3a369","alternateColor":"ffffff","slug":"georgia-tech-yellow-jackets"},
    "GONZAGA BULLDOGS": {"id":"2250","displayName":"Gonzaga Bulldogs","location":"Gonzaga","shortDisplayName":"Gonzaga","abbreviation":"GONZ","color":"041e42","alternateColor":"c8102e","slug":"gonzaga-bulldogs"},
    "GRAMBLING TIGERS": {"id":"2755","displayName":"Grambling Tigers","location":"Grambling","shortDisplayName":"Grambling","abbreviation":"GRAM","color":"ee8601","alternateColor":"ffd10a","slug":"grambling-tigers"},
    "GRAND CANYON LOPES": {"id":"2253","displayName":"Grand Canyon Lopes","location":"Grand Canyon","shortDisplayName":"Grand Canyon","abbreviation":"GCU","color":"522398","alternateColor":"ffffff","slug":"grand-canyon-lopes"},
    "GREEN BAY PHOENIX": {"id":"2739","displayName":"Green Bay Phoenix","location":"Green Bay","shortDisplayName":"Green Bay","abbreviation":"GB","color":"006633","alternateColor":"ffffff","slug":"green-bay-phoenix"},
    "HAMPTON PIRATES": {"id":"2261","displayName":"Hampton Pirates","location":"Hampton","shortDisplayName":"Hampton","abbreviation":"HAMP","color":"0067AC","alternateColor":"","slug":"hampton-pirates"},
    "HARVARD CRIMSON": {"id":"108","displayName":"Harvard Crimson","location":"Harvard","shortDisplayName":"Harvard","abbreviation":"HARV","color":"990000","alternateColor":"dbdbdb","slug":"harvard-crimson"},
    "HAWAI'I RAINBOW WARRIORS": {"id":"62","displayName":"Hawai'i Rainbow Warriors","location":"Hawai'i","shortDisplayName":"Hawai'i","abbreviation":"HAW","color":"005737","alternateColor":"000000","slug":"hawaii-rainbow-warriors"},
    "HIGH POINT PANTHERS": {"id":"2272","displayName":"High Point Panthers","location":"High Point","shortDisplayName":"High Point","abbreviation":"HPU","color":"330072","alternateColor":"ffffff","slug":"high-point-panthers"},
    "HOFSTRA PRIDE": {"id":"2275","displayName":"Hofstra Pride","location":"Hofstra","shortDisplayName":"Hofstra","abbreviation":"HOF","color":"003594","alternateColor":"ffc72c","slug":"hofstra-pride"},
    "HOLY CROSS CRUSADERS": {"id":"107","displayName":"Holy Cross Crusaders","location":"Holy Cross","shortDisplayName":"Holy Cross","abbreviation":"HC","color":"582c83","alternateColor":"ffffff","slug":"holy-cross-crusaders"},
    "HOUSTON CHRISTIAN HUSKIES": {"id":"2277","displayName":"Houston Christian Huskies","location":"Houston Christian","shortDisplayName":"Hou Christian","abbreviation":"HCU","color":"00539c","alternateColor":"","slug":"houston-christian-huskies"},
    "HOUSTON COUGARS": {"id":"248","displayName":"Houston Cougars","location":"Houston","shortDisplayName":"Houston","abbreviation":"HOU","color":"c8102e","alternateColor":"ffffff","slug":"houston-cougars"},
    "HOWARD BISON": {"id":"47","displayName":"Howard Bison","location":"Howard","shortDisplayName":"Howard","abbreviation":"HOW","color":"003a63","alternateColor":"e51937","slug":"howard-bison"},
    "IU INDIANAPOLIS JAGUARS": {"id":"85","displayName":"IU Indianapolis Jaguars","location":"IU Indianapolis","shortDisplayName":"IU Indy","abbreviation":"IUIN","color":"A81F30","alternateColor":"d59f0f","slug":"iu-indianapolis-jaguars"},
    "IDAHO STATE BENGALS": {"id":"304","displayName":"Idaho State Bengals","location":"Idaho State","shortDisplayName":"Idaho St","abbreviation":"IDST","color":"ef8c00","alternateColor":"e9a126","slug":"idaho-state-bengals"},
    "IDAHO VANDALS": {"id":"70","displayName":"Idaho Vandals","location":"Idaho","shortDisplayName":"Idaho","abbreviation":"IDHO","color":"000000","alternateColor":"8c6e4a","slug":"idaho-vandals"},
    "ILLINOIS FIGHTING ILLINI": {"id":"356","displayName":"Illinois Fighting Illini","location":"Illinois","shortDisplayName":"Illinois","abbreviation":"ILL","color":"ff5f05","alternateColor":"13294b","slug":"illinois-fighting-illini"},
    "ILLINOIS STATE REDBIRDS": {"id":"2287","displayName":"Illinois State Redbirds","location":"Illinois State","shortDisplayName":"Illinois St","abbreviation":"ILST","color":"CE1126","alternateColor":"ffe716","slug":"illinois-state-redbirds"},
    "INCARNATE WORD CARDINALS": {"id":"2916","displayName":"Incarnate Word Cardinals","location":"Incarnate Word","shortDisplayName":"Incarnate Word","abbreviation":"UIW","color":"000000","alternateColor":"080808","slug":"incarnate-word-cardinals"},
    "INDIANA HOOSIERS": {"id":"84","displayName":"Indiana Hoosiers","location":"Indiana","shortDisplayName":"Indiana","abbreviation":"IU","color":"970310","alternateColor":"ffffff","slug":"indiana-hoosiers"},
    "INDIANA STATE SYCAMORES": {"id":"282","displayName":"Indiana State Sycamores","location":"Indiana State","shortDisplayName":"Indiana St","abbreviation":"INST","color":"00669a","alternateColor":"f0f0f0","slug":"indiana-state-sycamores"},
    "IONA GAELS": {"id":"314","displayName":"Iona Gaels","location":"Iona","shortDisplayName":"Iona","abbreviation":"IONA","color":"6f2c3e","alternateColor":"f0ab00","slug":"iona-gaels"},
    "IOWA HAWKEYES": {"id":"2294","displayName":"Iowa Hawkeyes","location":"Iowa","shortDisplayName":"Iowa","abbreviation":"IOWA","color":"231f20","alternateColor":"fcd116","slug":"iowa-hawkeyes"},
    "IOWA STATE CYCLONES": {"id":"66","displayName":"Iowa State Cyclones","location":"Iowa State","shortDisplayName":"Iowa State","abbreviation":"ISU","color":"ae192d","alternateColor":"ffc72a","slug":"iowa-state-cyclones"},
    "JACKSON STATE TIGERS": {"id":"2296","displayName":"Jackson State Tigers","location":"Jackson State","shortDisplayName":"Jackson St","abbreviation":"JKST","color":"123297","alternateColor":"b5b7ba","slug":"jackson-state-tigers"},
    "JACKSONVILLE DOLPHINS": {"id":"294","displayName":"Jacksonville Dolphins","location":"Jacksonville","shortDisplayName":"Jacksonville","abbreviation":"JAX","color":"00523e","alternateColor":"","slug":"jacksonville-dolphins"},
    "JACKSONVILLE STATE GAMECOCKS": {"id":"55","displayName":"Jacksonville State Gamecocks","location":"Jacksonville State","shortDisplayName":"Jax State","abbreviation":"JXST","color":"cc0000","alternateColor":"000000","slug":"jacksonville-state-gamecocks"},
    "JAMES MADISON DUKES": {"id":"256","displayName":"James Madison Dukes","location":"James Madison","shortDisplayName":"James Madison","abbreviation":"JMU","color":"450084","alternateColor":"cbb677","slug":"james-madison-dukes"},
    "KANSAS CITY ROOS": {"id":"140","displayName":"Kansas City Roos","location":"Kansas City","shortDisplayName":"Kansas City","abbreviation":"KC","color":"004b87","alternateColor":"ffc72c","slug":"kansas-city-roos"},
    "KANSAS JAYHAWKS": {"id":"2305","displayName":"Kansas Jayhawks","location":"Kansas","shortDisplayName":"Kansas","abbreviation":"KU","color":"0051ba","alternateColor":"e8000d","slug":"kansas-jayhawks"},
    "KANSAS STATE WILDCATS": {"id":"2306","displayName":"Kansas State Wildcats","location":"Kansas State","shortDisplayName":"Kansas St","abbreviation":"KSU","color":"330a57","alternateColor":"e2e3e4","slug":"kansas-state-wildcats"},
    "KENNESAW STATE OWLS": {"id":"338","displayName":"Kennesaw State Owls","location":"Kennesaw State","shortDisplayName":"Kennesaw St","abbreviation":"KENN","color":"fdbb30","alternateColor":"0b1315","slug":"kennesaw-state-owls"},
    "KENT STATE GOLDEN FLASHES": {"id":"2309","displayName":"Kent State Golden Flashes","location":"Kent State","shortDisplayName":"Kent State","abbreviation":"KENT","color":"002664","alternateColor":"eaab00","slug":"kent-state-golden-flashes"},
    "KENTUCKY WILDCATS": {"id":"96","displayName":"Kentucky Wildcats","location":"Kentucky","shortDisplayName":"Kentucky","abbreviation":"UK","color":"0033a0","alternateColor":"ffffff","slug":"kentucky-wildcats"},
    "LSU NEW ORLEANS PRIVATEERS": {"id":"2443","displayName":"LSU New Orleans Privateers","location":"LSU New Orleans","shortDisplayName":"LSU N Orleans","abbreviation":"NOLA","color":"461d7c","alternateColor":"fdd023","slug":"lsu-new-orleans-privateers"},
    "LSU TIGERS": {"id":"99","displayName":"LSU Tigers","location":"LSU","shortDisplayName":"LSU","abbreviation":"LSU","color":"461d76","alternateColor":"fdd023","slug":"lsu-tigers"},
    "LA SALLE EXPLORERS": {"id":"2325","displayName":"La Salle Explorers","location":"La Salle","shortDisplayName":"La Salle","abbreviation":"LAS","color":"003356","alternateColor":"ffce00","slug":"la-salle-explorers"},
    "LAFAYETTE LEOPARDS": {"id":"322","displayName":"Lafayette Leopards","location":"Lafayette","shortDisplayName":"Lafayette","abbreviation":"LAF","color":"790000","alternateColor":"a59474","slug":"lafayette-leopards"},
    "LAMAR CARDINALS": {"id":"2320","displayName":"Lamar Cardinals","location":"Lamar","shortDisplayName":"Lamar","abbreviation":"LAM","color":"000000","alternateColor":"ebebeb","slug":"lamar-cardinals"},
    "LE MOYNE DOLPHINS": {"id":"2330","displayName":"Le Moyne Dolphins","location":"Le Moyne","shortDisplayName":"Le Moyne","abbreviation":"LEM","color":"","alternateColor":"","slug":"le-moyne-dolphins"},
    "LEHIGH MOUNTAIN HAWKS": {"id":"2329","displayName":"Lehigh Mountain Hawks","location":"Lehigh","shortDisplayName":"Lehigh","abbreviation":"LEH","color":"6c2b2a","alternateColor":"b69e70","slug":"lehigh-mountain-hawks"},
    "LIBERTY FLAMES": {"id":"2335","displayName":"Liberty Flames","location":"Liberty","shortDisplayName":"Liberty","abbreviation":"LIB","color":"0a254e","alternateColor":"b72025","slug":"liberty-flames"},
    "LINDENWOOD LIONS": {"id":"2815","displayName":"Lindenwood Lions","location":"Lindenwood","shortDisplayName":"Lindenwood","abbreviation":"LIN","color":"000000","alternateColor":"","slug":"lindenwood-lions"},
    "LIPSCOMB BISONS": {"id":"288","displayName":"Lipscomb Bisons","location":"Lipscomb","shortDisplayName":"Lipscomb","abbreviation":"LIP","color":"20366C","alternateColor":"f6b734","slug":"lipscomb-bisons"},
    "LITTLE ROCK TROJANS": {"id":"2031","displayName":"Little Rock Trojans","location":"Little Rock","shortDisplayName":"Little Rock","abbreviation":"LR","color":"AD0000","alternateColor":"898d8f","slug":"little-rock-trojans"},
    "LONG BEACH STATE BEACH": {"id":"299","displayName":"Long Beach State Beach","location":"Long Beach State","shortDisplayName":"Long Beach St","abbreviation":"LBSU","color":"000000","alternateColor":"f1f2f3","slug":"long-beach-state-beach"},
    "LONG ISLAND UNIVERSITY SHARKS": {"id":"112358","displayName":"Long Island University Sharks","location":"Long Island University","shortDisplayName":"Long Island","abbreviation":"LIU","color":"50c9f7","alternateColor":"ffbf00","slug":"long-island-university-sharks"},
    "LONGWOOD LANCERS": {"id":"2344","displayName":"Longwood Lancers","location":"Longwood","shortDisplayName":"Longwood","abbreviation":"LONG","color":"003273","alternateColor":"9ea2a3","slug":"longwood-lancers"},
    "LOUISIANA RAGIN' CAJUNS": {"id":"309","displayName":"Louisiana Ragin' Cajuns","location":"Louisiana","shortDisplayName":"Louisiana","abbreviation":"UL","color":"ce181e","alternateColor":"000000","slug":"louisiana-ragin-cajuns"},
    "LOUISIANA TECH BULLDOGS": {"id":"2348","displayName":"Louisiana Tech Bulldogs","location":"Louisiana Tech","shortDisplayName":"Louisiana Tech","abbreviation":"LT","color":"003087","alternateColor":"cb333b","slug":"louisiana-tech-bulldogs"},
    "LOUISVILLE CARDINALS": {"id":"97","displayName":"Louisville Cardinals","location":"Louisville","shortDisplayName":"Louisville","abbreviation":"LOU","color":"c9001f","alternateColor":"ffffff","slug":"louisville-cardinals"},
    "LOYOLA CHICAGO RAMBLERS": {"id":"2350","displayName":"Loyola Chicago Ramblers","location":"Loyola Chicago","shortDisplayName":"Loyola Chicago","abbreviation":"LUC","color":"9d1244","alternateColor":"","slug":"loyola-chicago-ramblers"},
    "LOYOLA MARYLAND GREYHOUNDS": {"id":"2352","displayName":"Loyola Maryland Greyhounds","location":"Loyola Maryland","shortDisplayName":"Loyola MD","abbreviation":"L-MD","color":"76a7a0","alternateColor":"c9cbca","slug":"loyola-maryland-greyhounds"},
    "LOYOLA MARYMOUNT LIONS": {"id":"2351","displayName":"Loyola Marymount Lions","location":"Loyola Marymount","shortDisplayName":"LMU","abbreviation":"LMU","color":"880029","alternateColor":"00345b","slug":"loyola-marymount-lions"},
    "MAINE BLACK BEARS": {"id":"311","displayName":"Maine Black Bears","location":"Maine","shortDisplayName":"Maine","abbreviation":"ME","color":"127dbe","alternateColor":"","slug":"maine-black-bears"},
    "MANHATTAN JASPERS": {"id":"2363","displayName":"Manhattan Jaspers","location":"Manhattan","shortDisplayName":"Manhattan","abbreviation":"MAN","color":"4f8537","alternateColor":"b5b7ba","slug":"manhattan-jaspers"},
    "MARIST RED FOXES": {"id":"2368","displayName":"Marist Red Foxes","location":"Marist","shortDisplayName":"Marist","abbreviation":"MRST","color":"e53730","alternateColor":"f0f0f0","slug":"marist-red-foxes"},
    "MARQUETTE GOLDEN EAGLES": {"id":"269","displayName":"Marquette Golden Eagles","location":"Marquette","shortDisplayName":"Marquette","abbreviation":"MARQ","color":"003366","alternateColor":"ffcc00","slug":"marquette-golden-eagles"},
    "MARSHALL THUNDERING HERD": {"id":"276","displayName":"Marshall Thundering Herd","location":"Marshall","shortDisplayName":"Marshall","abbreviation":"MRSH","color":"00b140","alternateColor":"000000","slug":"marshall-thundering-herd"},
    "MARYLAND EASTERN SHORE HAWKS": {"id":"2379","displayName":"Maryland Eastern Shore Hawks","location":"Maryland Eastern Shore","shortDisplayName":"MD Eastern","abbreviation":"UMES","color":"5c2301","alternateColor":"b5b7ba","slug":"maryland-eastern-shore-hawks"},
    "MARYLAND TERRAPINS": {"id":"120","displayName":"Maryland Terrapins","location":"Maryland","shortDisplayName":"Maryland","abbreviation":"MD","color":"ce1126","alternateColor":"ffffff","slug":"maryland-terrapins"},
    "MASSACHUSETTS MINUTEMEN": {"id":"113","displayName":"Massachusetts Minutemen","location":"Massachusetts","shortDisplayName":"UMass","abbreviation":"MASS","color":"881c1c","alternateColor":"ffffff","slug":"massachusetts-minutemen"},
    "MCNEESE COWBOYS": {"id":"2377","displayName":"McNeese Cowboys","location":"McNeese","shortDisplayName":"McNeese","abbreviation":"MCN","color":"00529C","alternateColor":"ffd204","slug":"mcneese-cowboys"},
    "MEMPHIS TIGERS": {"id":"235","displayName":"Memphis Tigers","location":"Memphis","shortDisplayName":"Memphis","abbreviation":"MEM","color":"004991","alternateColor":"8e908f","slug":"memphis-tigers"},
    "MERCER BEARS": {"id":"2382","displayName":"Mercer Bears","location":"Mercer","shortDisplayName":"Mercer","abbreviation":"MER","color":"ff7f29","alternateColor":"080808","slug":"mercer-bears"},
    "MERCYHURST LAKERS": {"id":"2385","displayName":"Mercyhurst Lakers","location":"Mercyhurst","shortDisplayName":"Mercyhurst","abbreviation":"MERC","color":"000000","alternateColor":"","slug":"mercyhurst-lakers"},
    "MERRIMACK WARRIORS": {"id":"2771","displayName":"Merrimack Warriors","location":"Merrimack","shortDisplayName":"Merrimack","abbreviation":"MRMK","color":"2f4f93","alternateColor":"e8c535","slug":"merrimack-warriors"},
    "MIAMI (OH) REDHAWKS": {"id":"193","displayName":"Miami (OH) RedHawks","location":"Miami (OH)","shortDisplayName":"Miami OH","abbreviation":"M-OH","color":"c41230","alternateColor":"ffffff","slug":"miami-oh-redhawks"},
    "MIAMI HURRICANES": {"id":"2390","displayName":"Miami Hurricanes","location":"Miami","shortDisplayName":"Miami","abbreviation":"MIA","color":"f47423","alternateColor":"035131","slug":"miami-hurricanes"},
    "MICHIGAN STATE SPARTANS": {"id":"127","displayName":"Michigan State Spartans","location":"Michigan State","shortDisplayName":"Michigan St","abbreviation":"MSU","color":"173f35","alternateColor":"ffffff","slug":"michigan-state-spartans"},
    "MICHIGAN WOLVERINES": {"id":"130","displayName":"Michigan Wolverines","location":"Michigan","shortDisplayName":"Michigan","abbreviation":"MICH","color":"00274c","alternateColor":"ffcb05","slug":"michigan-wolverines"},
    "MIDDLE TENNESSEE BLUE RAIDERS": {"id":"2393","displayName":"Middle Tennessee Blue Raiders","location":"Middle Tennessee","shortDisplayName":"MTSU","abbreviation":"MTSU","color":"036eb7","alternateColor":"ffffff","slug":"middle-tennessee-blue-raiders"},
    "MILWAUKEE PANTHERS": {"id":"270","displayName":"Milwaukee Panthers","location":"Milwaukee","shortDisplayName":"Milwaukee","abbreviation":"MILW","color":"000000","alternateColor":"ffc20e","slug":"milwaukee-panthers"},
    "MINNESOTA GOLDEN GOPHERS": {"id":"135","displayName":"Minnesota Golden Gophers","location":"Minnesota","shortDisplayName":"Minnesota","abbreviation":"MINN","color":"5e0a2f","alternateColor":"fab41c","slug":"minnesota-golden-gophers"},
    "MISSISSIPPI STATE BULLDOGS": {"id":"344","displayName":"Mississippi State Bulldogs","location":"Mississippi State","shortDisplayName":"Mississippi St","abbreviation":"MSST","color":"5d1725","alternateColor":"c1c6c8","slug":"mississippi-state-bulldogs"},
    "MISSISSIPPI VALLEY STATE DELTA DEVILS": {"id":"2400","displayName":"Mississippi Valley State Delta Devils","location":"Mississippi Valley State","shortDisplayName":"Miss Valley St","abbreviation":"MVSU","color":"005328","alternateColor":"cf2d34","slug":"mississippi-valley-state-delta-devils"},
    "MISSOURI STATE BEARS": {"id":"2623","displayName":"Missouri State Bears","location":"Missouri State","shortDisplayName":"Missouri St","abbreviation":"MOST","color":"5e0009","alternateColor":"ffffff","slug":"missouri-state-bears"},
    "MISSOURI TIGERS": {"id":"142","displayName":"Missouri Tigers","location":"Missouri","shortDisplayName":"Missouri","abbreviation":"MIZ","color":"f1b82d","alternateColor":"000000","slug":"missouri-tigers"},
    "MONMOUTH HAWKS": {"id":"2405","displayName":"Monmouth Hawks","location":"Monmouth","shortDisplayName":"Monmouth","abbreviation":"MONM","color":"051844","alternateColor":"","slug":"monmouth-hawks"},
    "MONTANA GRIZZLIES": {"id":"149","displayName":"Montana Grizzlies","location":"Montana","shortDisplayName":"Montana","abbreviation":"MONT","color":"751D4A","alternateColor":"666666","slug":"montana-grizzlies"},
    "MONTANA STATE BOBCATS": {"id":"147","displayName":"Montana State Bobcats","location":"Montana State","shortDisplayName":"Montana St","abbreviation":"MTST","color":"00205c","alternateColor":"bc955c","slug":"montana-state-bobcats"},
    "MOREHEAD STATE EAGLES": {"id":"2413","displayName":"Morehead State Eagles","location":"Morehead State","shortDisplayName":"Morehead St","abbreviation":"MORE","color":"094FA3","alternateColor":"fed91a","slug":"morehead-state-eagles"},
    "MORGAN STATE BEARS": {"id":"2415","displayName":"Morgan State Bears","location":"Morgan State","shortDisplayName":"Morgan St","abbreviation":"MORG","color":"014786","alternateColor":"f47937","slug":"morgan-state-bears"},
    "MOUNT ST. MARY'S MOUNTAINEERS": {"id":"116","displayName":"Mount St. Mary's Mountaineers","location":"Mount St. Mary's","shortDisplayName":"Mount St Marys","abbreviation":"MSM","color":"005596","alternateColor":"ebebeb","slug":"mount-st-marys-mountaineers"},
    "MURRAY STATE RACERS": {"id":"93","displayName":"Murray State Racers","location":"Murray State","shortDisplayName":"Murray St","abbreviation":"MUR","color":"002148","alternateColor":"000e00","slug":"murray-state-racers"},
    "NC STATE WOLFPACK": {"id":"152","displayName":"NC State Wolfpack","location":"NC State","shortDisplayName":"NC State","abbreviation":"NCSU","color":"cc0000","alternateColor":"ffffff","slug":"nc-state-wolfpack"},
    "NJIT HIGHLANDERS": {"id":"2885","displayName":"NJIT Highlanders","location":"NJIT","shortDisplayName":"NJIT","abbreviation":"NJIT","color":"EE3024","alternateColor":"df3e2e","slug":"njit-highlanders"},
    "NAVY MIDSHIPMEN": {"id":"2426","displayName":"Navy Midshipmen","location":"Navy","shortDisplayName":"Navy","abbreviation":"NAVY","color":"00225b","alternateColor":"b5a67c","slug":"navy-midshipmen"},
    "NEBRASKA CORNHUSKERS": {"id":"158","displayName":"Nebraska Cornhuskers","location":"Nebraska","shortDisplayName":"Nebraska","abbreviation":"NEB","color":"e31937","alternateColor":"ffffff","slug":"nebraska-cornhuskers"},
    "NEVADA WOLF PACK": {"id":"2440","displayName":"Nevada Wolf Pack","location":"Nevada","shortDisplayName":"Nevada","abbreviation":"NEV","color":"041e42","alternateColor":"8a8d8f","slug":"nevada-wolf-pack"},
    "NEW HAMPSHIRE WILDCATS": {"id":"160","displayName":"New Hampshire Wildcats","location":"New Hampshire","shortDisplayName":"New Hampshire","abbreviation":"UNH","color":"004990","alternateColor":"c3c4c6","slug":"new-hampshire-wildcats"},
    "NEW HAVEN CHARGERS": {"id":"2441","displayName":"New Haven Chargers","location":"New Haven","shortDisplayName":"New Haven","abbreviation":"NHVN","color":"041e42","alternateColor":"ffc425","slug":"new-haven-chargers"},
    "NEW MEXICO LOBOS": {"id":"167","displayName":"New Mexico Lobos","location":"New Mexico","shortDisplayName":"New Mexico","abbreviation":"UNM","color":"ba0c2f","alternateColor":"a7a8aa","slug":"new-mexico-lobos"},
    "NEW MEXICO STATE AGGIES": {"id":"166","displayName":"New Mexico State Aggies","location":"New Mexico State","shortDisplayName":"New Mexico St","abbreviation":"NMSU","color":"7e141b","alternateColor":"231f20","slug":"new-mexico-state-aggies"},
    "NIAGARA PURPLE EAGLES": {"id":"315","displayName":"Niagara Purple Eagles","location":"Niagara","shortDisplayName":"Niagara","abbreviation":"NIA","color":"69207E","alternateColor":"f0f0f0","slug":"niagara-purple-eagles"},
    "NICHOLLS COLONELS": {"id":"2447","displayName":"Nicholls Colonels","location":"Nicholls","shortDisplayName":"Nicholls","abbreviation":"NICH","color":"C41230","alternateColor":"f0f0f0","slug":"nicholls-colonels"},
    "NORFOLK STATE SPARTANS": {"id":"2450","displayName":"Norfolk State Spartans","location":"Norfolk State","shortDisplayName":"Norfolk St","abbreviation":"NORF","color":"0c8968","alternateColor":"fdb813","slug":"norfolk-state-spartans"},
    "NORTH ALABAMA LIONS": {"id":"2453","displayName":"North Alabama Lions","location":"North Alabama","shortDisplayName":"North Alabama","abbreviation":"UNA","color":"663399","alternateColor":"","slug":"north-alabama-lions"},
    "NORTH CAROLINA A&T AGGIES": {"id":"2448","displayName":"North Carolina A&T Aggies","location":"North Carolina A&T","shortDisplayName":"NC A&T","abbreviation":"NCAT","color":"0505aa","alternateColor":"004684","slug":"north-carolina-at-aggies"},
    "NORTH CAROLINA CENTRAL EAGLES": {"id":"2428","displayName":"North Carolina Central Eagles","location":"North Carolina Central","shortDisplayName":"NC Central","abbreviation":"NCCU","color":"880023","alternateColor":"c2c3c0","slug":"north-carolina-central-eagles"},
    "NORTH CAROLINA TAR HEELS": {"id":"153","displayName":"North Carolina Tar Heels","location":"North Carolina","shortDisplayName":"North Carolina","abbreviation":"UNC","color":"7bafd4","alternateColor":"13294b","slug":"north-carolina-tar-heels"},
    "NORTH DAKOTA FIGHTING HAWKS": {"id":"155","displayName":"North Dakota Fighting Hawks","location":"North Dakota","shortDisplayName":"North Dakota","abbreviation":"UND","color":"00A26B","alternateColor":"c2c3c0","slug":"north-dakota-fighting-hawks"},
    "NORTH DAKOTA STATE BISON": {"id":"2449","displayName":"North Dakota State Bison","location":"North Dakota State","shortDisplayName":"N Dakota St","abbreviation":"NDSU","color":"01402A","alternateColor":"ffffff","slug":"north-dakota-state-bison"},
    "NORTH FLORIDA OSPREYS": {"id":"2454","displayName":"North Florida Ospreys","location":"North Florida","shortDisplayName":"North Florida","abbreviation":"UNF","color":"004B8D","alternateColor":"babcbe","slug":"north-florida-ospreys"},
    "NORTH TEXAS MEAN GREEN": {"id":"249","displayName":"North Texas Mean Green","location":"North Texas","shortDisplayName":"North Texas","abbreviation":"UNT","color":"068f33","alternateColor":"ffffff","slug":"north-texas-mean-green"},
    "NORTHEASTERN HUSKIES": {"id":"111","displayName":"Northeastern Huskies","location":"Northeastern","shortDisplayName":"Northeastern","abbreviation":"NE","color":"CC0001","alternateColor":"c2c3c0","slug":"northeastern-huskies"},
    "NORTHERN ARIZONA LUMBERJACKS": {"id":"2464","displayName":"Northern Arizona Lumberjacks","location":"Northern Arizona","shortDisplayName":"N Arizona","abbreviation":"NAU","color":"003976","alternateColor":"1b3069","slug":"northern-arizona-lumberjacks"},
    "NORTHERN COLORADO BEARS": {"id":"2458","displayName":"Northern Colorado Bears","location":"Northern Colorado","shortDisplayName":"N Colorado","abbreviation":"UNCO","color":"13558D","alternateColor":"ffc533","slug":"northern-colorado-bears"},
    "NORTHERN ILLINOIS HUSKIES": {"id":"2459","displayName":"Northern Illinois Huskies","location":"Northern Illinois","shortDisplayName":"N Illinois","abbreviation":"NIU","color":"c8102e","alternateColor":"000000","slug":"northern-illinois-huskies"},
    "NORTHERN IOWA PANTHERS": {"id":"2460","displayName":"Northern Iowa Panthers","location":"Northern Iowa","shortDisplayName":"Northern Iowa","abbreviation":"UNI","color":"473282","alternateColor":"ffffff","slug":"northern-iowa-panthers"},
    "NORTHERN KENTUCKY NORSE": {"id":"94","displayName":"Northern Kentucky Norse","location":"Northern Kentucky","shortDisplayName":"N Kentucky","abbreviation":"NKU","color":"ffc82e","alternateColor":"000000","slug":"northern-kentucky-norse"},
    "NORTHWESTERN STATE DEMONS": {"id":"2466","displayName":"Northwestern State Demons","location":"Northwestern State","shortDisplayName":"N'Western St","abbreviation":"NWST","color":"492F91","alternateColor":"ed6118","slug":"northwestern-state-demons"},
    "NORTHWESTERN WILDCATS": {"id":"77","displayName":"Northwestern Wildcats","location":"Northwestern","shortDisplayName":"Northwestern","abbreviation":"NU","color":"492f92","alternateColor":"ffffff","slug":"northwestern-wildcats"},
    "NOTRE DAME FIGHTING IRISH": {"id":"87","displayName":"Notre Dame Fighting Irish","location":"Notre Dame","shortDisplayName":"Notre Dame","abbreviation":"ND","color":"062340","alternateColor":"c99700","slug":"notre-dame-fighting-irish"},
    "OAKLAND GOLDEN GRIZZLIES": {"id":"2473","displayName":"Oakland Golden Grizzlies","location":"Oakland","shortDisplayName":"Oakland","abbreviation":"OAK","color":"04091c","alternateColor":"bc955c","slug":"oakland-golden-grizzlies"},
    "OHIO BOBCATS": {"id":"195","displayName":"Ohio Bobcats","location":"Ohio","shortDisplayName":"Ohio","abbreviation":"OHIO","color":"154734","alternateColor":"ffffff","slug":"ohio-bobcats"},
    "OHIO STATE BUCKEYES": {"id":"194","displayName":"Ohio State Buckeyes","location":"Ohio State","shortDisplayName":"Ohio State","abbreviation":"OSU","color":"ba0c2f","alternateColor":"a8adb4","slug":"ohio-state-buckeyes"},
    "OKLAHOMA SOONERS": {"id":"201","displayName":"Oklahoma Sooners","location":"Oklahoma","shortDisplayName":"Oklahoma","abbreviation":"OU","color":"990000","alternateColor":"ffffff","slug":"oklahoma-sooners"},
    "OKLAHOMA STATE COWBOYS": {"id":"197","displayName":"Oklahoma State Cowboys","location":"Oklahoma State","shortDisplayName":"Oklahoma St","abbreviation":"OKST","color":"fe5c00","alternateColor":"000000","slug":"oklahoma-state-cowboys"},
    "OLD DOMINION MONARCHS": {"id":"295","displayName":"Old Dominion Monarchs","location":"Old Dominion","shortDisplayName":"Old Dominion","abbreviation":"ODU","color":"003768","alternateColor":"a1d2f1","slug":"old-dominion-monarchs"},
    "OLE MISS REBELS": {"id":"145","displayName":"Ole Miss Rebels","location":"Ole Miss","shortDisplayName":"Ole Miss","abbreviation":"MISS","color":"13294b","alternateColor":"cf142b","slug":"ole-miss-rebels"},
    "OMAHA MAVERICKS": {"id":"2437","displayName":"Omaha Mavericks","location":"Omaha","shortDisplayName":"Omaha","abbreviation":"OMA","color":"e3193e","alternateColor":"474648","slug":"omaha-mavericks"},
    "ORAL ROBERTS GOLDEN EAGLES": {"id":"198","displayName":"Oral Roberts Golden Eagles","location":"Oral Roberts","shortDisplayName":"Oral Roberts","abbreviation":"ORU","color":"002462","alternateColor":"dac792","slug":"oral-roberts-golden-eagles"},
    "OREGON DUCKS": {"id":"2483","displayName":"Oregon Ducks","location":"Oregon","shortDisplayName":"Oregon","abbreviation":"ORE","color":"00934b","alternateColor":"fff41b","slug":"oregon-ducks"},
    "OREGON STATE BEAVERS": {"id":"204","displayName":"Oregon State Beavers","location":"Oregon State","shortDisplayName":"Oregon St","abbreviation":"ORST","color":"dc4405","alternateColor":"000000","slug":"oregon-state-beavers"},
    "PACIFIC TIGERS": {"id":"279","displayName":"Pacific Tigers","location":"Pacific","shortDisplayName":"Pacific","abbreviation":"PAC","color":"F47820","alternateColor":"c2c3c0","slug":"pacific-tigers"},
    "PENN STATE NITTANY LIONS": {"id":"213","displayName":"Penn State Nittany Lions","location":"Penn State","shortDisplayName":"Penn State","abbreviation":"PSU","color":"061440","alternateColor":"ffffff","slug":"penn-state-nittany-lions"},
    "PENNSYLVANIA QUAKERS": {"id":"219","displayName":"Pennsylvania Quakers","location":"Pennsylvania","shortDisplayName":"Penn","abbreviation":"PENN","color":"082A74","alternateColor":"a6163d","slug":"pennsylvania-quakers"},
    "PEPPERDINE WAVES": {"id":"2492","displayName":"Pepperdine Waves","location":"Pepperdine","shortDisplayName":"Pepperdine","abbreviation":"PEPP","color":"003A72","alternateColor":"dc762f","slug":"pepperdine-waves"},
    "PITTSBURGH PANTHERS": {"id":"221","displayName":"Pittsburgh Panthers","location":"Pittsburgh","shortDisplayName":"Pitt","abbreviation":"PITT","color":"003594","alternateColor":"ffb81c","slug":"pittsburgh-panthers"},
    "PORTLAND PILOTS": {"id":"2501","displayName":"Portland Pilots","location":"Portland","shortDisplayName":"Portland","abbreviation":"PORT","color":"330072","alternateColor":"a8b3ba","slug":"portland-pilots"},
    "PORTLAND STATE VIKINGS": {"id":"2502","displayName":"Portland State Vikings","location":"Portland State","shortDisplayName":"Portland St","abbreviation":"PRST","color":"00311e","alternateColor":"ebebeb","slug":"portland-state-vikings"},
    "PRAIRIE VIEW A&M PANTHERS": {"id":"2504","displayName":"Prairie View A&M Panthers","location":"Prairie View A&M","shortDisplayName":"Prairie View","abbreviation":"PV","color":"582c83","alternateColor":"eaaa00","slug":"prairie-view-am-panthers"},
    "PRESBYTERIAN BLUE HOSE": {"id":"2506","displayName":"Presbyterian Blue Hose","location":"Presbyterian","shortDisplayName":"Presbyterian","abbreviation":"PRES","color":"194896","alternateColor":"990134","slug":"presbyterian-blue-hose"},
    "PRINCETON TIGERS": {"id":"163","displayName":"Princeton Tigers","location":"Princeton","shortDisplayName":"Princeton","abbreviation":"PRIN","color":"000000","alternateColor":"ff6000","slug":"princeton-tigers"},
    "PROVIDENCE FRIARS": {"id":"2507","displayName":"Providence Friars","location":"Providence","shortDisplayName":"Providence","abbreviation":"PROV","color":"000000","alternateColor":"a3a19e","slug":"providence-friars"},
    "PURDUE BOILERMAKERS": {"id":"2509","displayName":"Purdue Boilermakers","location":"Purdue","shortDisplayName":"Purdue","abbreviation":"PUR","color":"ceb888","alternateColor":"000000","slug":"purdue-boilermakers"},
    "PURDUE FORT WAYNE MASTODONS": {"id":"2870","displayName":"Purdue Fort Wayne Mastodons","location":"Purdue Fort Wayne","shortDisplayName":"Purdue FW","abbreviation":"PFW","color":"cfb991","alternateColor":"000000","slug":"purdue-fort-wayne-mastodons"},
    "QUEENS UNIVERSITY ROYALS": {"id":"2511","displayName":"Queens University Royals","location":"Queens University","shortDisplayName":"Queens","abbreviation":"QUC","color":"192C66","alternateColor":"857040","slug":"queens-university-royals"},
    "QUINNIPIAC BOBCATS": {"id":"2514","displayName":"Quinnipiac Bobcats","location":"Quinnipiac","shortDisplayName":"Quinnipiac","abbreviation":"QUIN","color":"041B43","alternateColor":"","slug":"quinnipiac-bobcats"},
    "RADFORD HIGHLANDERS": {"id":"2515","displayName":"Radford Highlanders","location":"Radford","shortDisplayName":"Radford","abbreviation":"RAD","color":"BC1515","alternateColor":"c2c3c0","slug":"radford-highlanders"},
    "RHODE ISLAND RAMS": {"id":"227","displayName":"Rhode Island Rams","location":"Rhode Island","shortDisplayName":"Rhode Island","abbreviation":"URI","color":"091f3f","alternateColor":"5ab3e8","slug":"rhode-island-rams"},
    "RICE OWLS": {"id":"242","displayName":"Rice Owls","location":"Rice","shortDisplayName":"Rice","abbreviation":"RICE","color":"00205b","alternateColor":"c1c6c8","slug":"rice-owls"},
    "RICHMOND SPIDERS": {"id":"257","displayName":"Richmond Spiders","location":"Richmond","shortDisplayName":"Richmond","abbreviation":"RICH","color":"9e0712","alternateColor":"b90b2e","slug":"richmond-spiders"},
    "RIDER BRONCS": {"id":"2520","displayName":"Rider Broncs","location":"Rider","shortDisplayName":"Rider","abbreviation":"RID","color":"a80532","alternateColor":"ebebeb","slug":"rider-broncs"},
    "ROBERT MORRIS COLONIALS": {"id":"2523","displayName":"Robert Morris Colonials","location":"Robert Morris","shortDisplayName":"Robert Morris","abbreviation":"RMU","color":"00214D","alternateColor":"a21d2b","slug":"robert-morris-colonials"},
    "RUTGERS SCARLET KNIGHTS": {"id":"164","displayName":"Rutgers Scarlet Knights","location":"Rutgers","shortDisplayName":"Rutgers","abbreviation":"RUTG","color":"ce0e2d","alternateColor":"ffffff","slug":"rutgers-scarlet-knights"},
    "SE LOUISIANA LIONS": {"id":"2545","displayName":"SE Louisiana Lions","location":"SE Louisiana","shortDisplayName":"SE Louisiana","abbreviation":"SELA","color":"215732","alternateColor":"ffc72c","slug":"se-louisiana-lions"},
    "SIU EDWARDSVILLE COUGARS": {"id":"2565","displayName":"SIU Edwardsville Cougars","location":"SIU Edwardsville","shortDisplayName":"SIUE","abbreviation":"SIUE","color":"eb1c23","alternateColor":"080808","slug":"siu-edwardsville-cougars"},
    "SMU MUSTANGS": {"id":"2567","displayName":"SMU Mustangs","location":"SMU","shortDisplayName":"SMU","abbreviation":"SMU","color":"a80000","alternateColor":"0033a1","slug":"smu-mustangs"},
    "SACRAMENTO STATE HORNETS": {"id":"16","displayName":"Sacramento State Hornets","location":"Sacramento State","shortDisplayName":"Sacramento St","abbreviation":"SAC","color":"00573C","alternateColor":"cdb97d","slug":"sacramento-state-hornets"},
    "SACRED HEART PIONEERS": {"id":"2529","displayName":"Sacred Heart Pioneers","location":"Sacred Heart","shortDisplayName":"Sacred Heart","abbreviation":"SHU","color":"a40012","alternateColor":"c29472","slug":"sacred-heart-pioneers"},
    "SAINT JOSEPH'S HAWKS": {"id":"2603","displayName":"Saint Joseph's Hawks","location":"Saint Joseph's","shortDisplayName":"Saint Joseph's","abbreviation":"JOES","color":"9e1b32","alternateColor":"6c6f70","slug":"saint-josephs-hawks"},
    "SAINT LOUIS BILLIKENS": {"id":"139","displayName":"Saint Louis Billikens","location":"Saint Louis","shortDisplayName":"Saint Louis","abbreviation":"SLU","color":"00539C","alternateColor":"ebebeb","slug":"saint-louis-billikens"},
    "SAINT MARY'S GAELS": {"id":"2608","displayName":"Saint Mary's Gaels","location":"Saint Mary's","shortDisplayName":"Saint Mary's","abbreviation":"SMC","color":"d80024","alternateColor":"003057","slug":"saint-marys-gaels"},
    "SAINT PETER'S PEACOCKS": {"id":"2612","displayName":"Saint Peter's Peacocks","location":"Saint Peter's","shortDisplayName":"Saint Peter's","abbreviation":"SPU","color":"004CC2","alternateColor":"","slug":"saint-peters-peacocks"},
    "SAM HOUSTON BEARKATS": {"id":"2534","displayName":"Sam Houston Bearkats","location":"Sam Houston","shortDisplayName":"Sam Houston","abbreviation":"SHSU","color":"f56423","alternateColor":"ffffff","slug":"sam-houston-bearkats"},
    "SAMFORD BULLDOGS": {"id":"2535","displayName":"Samford Bulldogs","location":"Samford","shortDisplayName":"Samford","abbreviation":"SAM","color":"005485","alternateColor":"bc0023","slug":"samford-bulldogs"},
    "SAN DIEGO STATE AZTECS": {"id":"21","displayName":"San Diego State Aztecs","location":"San Diego State","shortDisplayName":"San Diego St","abbreviation":"SDSU","color":"a6192e","alternateColor":"000000","slug":"san-diego-state-aztecs"},
    "SAN DIEGO TOREROS": {"id":"301","displayName":"San Diego Toreros","location":"San Diego","shortDisplayName":"San Diego","abbreviation":"USD","color":"2f99d4","alternateColor":"2f99d4","slug":"san-diego-toreros"},
    "SAN FRANCISCO DONS": {"id":"2539","displayName":"San Francisco Dons","location":"San Francisco","shortDisplayName":"San Francisco","abbreviation":"SF","color":"005a36","alternateColor":"ffffff","slug":"san-francisco-dons"},
    "SAN JOSÉ STATE SPARTANS": {"id":"23","displayName":"San José State Spartans","location":"San José State","shortDisplayName":"San José St","abbreviation":"SJSU","color":"0038a8","alternateColor":"ffb81a","slug":"san-jose-state-spartans"},
    "SANTA CLARA BRONCOS": {"id":"2541","displayName":"Santa Clara Broncos","location":"Santa Clara","shortDisplayName":"Santa Clara","abbreviation":"SCU","color":"690b0b","alternateColor":"101010","slug":"santa-clara-broncos"},
    "SEATTLE U REDHAWKS": {"id":"2547","displayName":"Seattle U Redhawks","location":"Seattle U","shortDisplayName":"Seattle U","abbreviation":"SEA","color":"BF2E1A","alternateColor":"c2c3c0","slug":"seattle-u-redhawks"},
    "SETON HALL PIRATES": {"id":"2550","displayName":"Seton Hall Pirates","location":"Seton Hall","shortDisplayName":"Seton Hall","abbreviation":"HALL","color":"0857B1","alternateColor":"8a8d8f","slug":"seton-hall-pirates"},
    "SIENA SAINTS": {"id":"2561","displayName":"Siena Saints","location":"Siena","shortDisplayName":"Siena","abbreviation":"SIE","color":"037961","alternateColor":"eea60f","slug":"siena-saints"},
    "SOUTH ALABAMA JAGUARS": {"id":"6","displayName":"South Alabama Jaguars","location":"South Alabama","shortDisplayName":"South Alabama","abbreviation":"USA","color":"00205b","alternateColor":"bf0d3e","slug":"south-alabama-jaguars"},
    "SOUTH CAROLINA GAMECOCKS": {"id":"2579","displayName":"South Carolina Gamecocks","location":"South Carolina","shortDisplayName":"South Carolina","abbreviation":"SC","color":"73000a","alternateColor":"000000","slug":"south-carolina-gamecocks"},
    "SOUTH CAROLINA STATE BULLDOGS": {"id":"2569","displayName":"South Carolina State Bulldogs","location":"South Carolina State","shortDisplayName":"SC State","abbreviation":"SCST","color":"7d1315","alternateColor":"104897","slug":"south-carolina-state-bulldogs"},
    "SOUTH CAROLINA UPSTATE SPARTANS": {"id":"2908","displayName":"South Carolina Upstate Spartans","location":"South Carolina Upstate","shortDisplayName":"SC Upstate","abbreviation":"UPST","color":"008545","alternateColor":"000000","slug":"south-carolina-upstate-spartans"},
    "SOUTH DAKOTA COYOTES": {"id":"233","displayName":"South Dakota Coyotes","location":"South Dakota","shortDisplayName":"South Dakota","abbreviation":"SDAK","color":"CD1241","alternateColor":"f0f0f0","slug":"south-dakota-coyotes"},
    "SOUTH DAKOTA STATE JACKRABBITS": {"id":"2571","displayName":"South Dakota State Jackrabbits","location":"South Dakota State","shortDisplayName":"S Dakota St","abbreviation":"SDST","color":"0033a0","alternateColor":"ffd100","slug":"south-dakota-state-jackrabbits"},
    "SOUTH FLORIDA BULLS": {"id":"58","displayName":"South Florida Bulls","location":"South Florida","shortDisplayName":"South Florida","abbreviation":"USF","color":"006747","alternateColor":"cfc493","slug":"south-florida-bulls"},
    "SOUTHEAST MISSOURI STATE REDHAWKS": {"id":"2546","displayName":"Southeast Missouri State Redhawks","location":"Southeast Missouri State","shortDisplayName":"SE Missouri","abbreviation":"SEMO","color":"c8102e","alternateColor":"000000","slug":"southeast-missouri-state-redhawks"},
    "SOUTHERN ILLINOIS SALUKIS": {"id":"79","displayName":"Southern Illinois Salukis","location":"Southern Illinois","shortDisplayName":"S Illinois","abbreviation":"SIU","color":"85283D","alternateColor":"c2c3c0","slug":"southern-illinois-salukis"},
    "SOUTHERN INDIANA SCREAMING EAGLES": {"id":"88","displayName":"Southern Indiana Screaming Eagles","location":"Southern Indiana","shortDisplayName":"S Indiana","abbreviation":"USI","color":"","alternateColor":"","slug":"southern-indiana-screaming-eagles"},
    "SOUTHERN JAGUARS": {"id":"2582","displayName":"Southern Jaguars","location":"Southern","shortDisplayName":"Southern","abbreviation":"SOU","color":"004B97","alternateColor":"ffc82d","slug":"southern-jaguars"},
    "SOUTHERN MISS GOLDEN EAGLES": {"id":"2572","displayName":"Southern Miss Golden Eagles","location":"Southern Miss","shortDisplayName":"Southern Miss","abbreviation":"USM","color":"ffc72c","alternateColor":"231f20","slug":"southern-miss-golden-eagles"},
    "SOUTHERN UTAH THUNDERBIRDS": {"id":"253","displayName":"Southern Utah Thunderbirds","location":"Southern Utah","shortDisplayName":"Southern Utah","abbreviation":"SUU","color":"c72026","alternateColor":"000000","slug":"southern-utah-thunderbirds"},
    "ST. BONAVENTURE BONNIES": {"id":"179","displayName":"St. Bonaventure Bonnies","location":"St. Bonaventure","shortDisplayName":"St Bonaventure","abbreviation":"SBU","color":"70261D","alternateColor":"","slug":"st-bonaventure-bonnies"},
    "ST. JOHN'S RED STORM": {"id":"2599","displayName":"St. John's Red Storm","location":"St. John's","shortDisplayName":"St John's","abbreviation":"SJU","color":"d10000","alternateColor":"101010","slug":"st-johns-red-storm"},
    "ST. THOMAS TOMMIES": {"id":"2900","displayName":"St. Thomas Tommies","location":"St. Thomas","shortDisplayName":"St Thomas","abbreviation":"STMN","color":"000000","alternateColor":"","slug":"st-thomas-tommies"},
    "STANFORD CARDINAL": {"id":"24","displayName":"Stanford Cardinal","location":"Stanford","shortDisplayName":"Stanford","abbreviation":"STAN","color":"8c1515","alternateColor":"ffffff","slug":"stanford-cardinal"},
    "STEPHEN F. AUSTIN LUMBERJACKS": {"id":"2617","displayName":"Stephen F. Austin Lumberjacks","location":"Stephen F. Austin","shortDisplayName":"SF Austin","abbreviation":"SFA","color":"393996","alternateColor":"bec0c2","slug":"stephen-f-austin-lumberjacks"},
    "STETSON HATTERS": {"id":"56","displayName":"Stetson Hatters","location":"Stetson","shortDisplayName":"Stetson","abbreviation":"STET","color":"0a5640","alternateColor":"56854e","slug":"stetson-hatters"},
    "STONEHILL SKYHAWKS": {"id":"284","displayName":"Stonehill Skyhawks","location":"Stonehill","shortDisplayName":"Stonehill","abbreviation":"STO","color":"000000","alternateColor":"","slug":"stonehill-skyhawks"},
    "STONY BROOK SEAWOLVES": {"id":"2619","displayName":"Stony Brook Seawolves","location":"Stony Brook","shortDisplayName":"Stony Brook","abbreviation":"STBK","color":"990000","alternateColor":"","slug":"stony-brook-seawolves"},
    "SYRACUSE ORANGE": {"id":"183","displayName":"Syracuse Orange","location":"Syracuse","shortDisplayName":"Syracuse","abbreviation":"SYR","color":"000e54","alternateColor":"ff431b","slug":"syracuse-orange"},
    "TCU HORNED FROGS": {"id":"2628","displayName":"TCU Horned Frogs","location":"TCU","shortDisplayName":"TCU","abbreviation":"TCU","color":"4d1979","alternateColor":"ffffff","slug":"tcu-horned-frogs"},
    "TARLETON STATE TEXANS": {"id":"2627","displayName":"Tarleton State Texans","location":"Tarleton State","shortDisplayName":"Tarleton St","abbreviation":"TAR","color":"000000","alternateColor":"","slug":"tarleton-state-texans"},
    "TEMPLE OWLS": {"id":"218","displayName":"Temple Owls","location":"Temple","shortDisplayName":"Temple","abbreviation":"TEM","color":"a41e35","alternateColor":"ffffff","slug":"temple-owls"},
    "TENNESSEE STATE TIGERS": {"id":"2634","displayName":"Tennessee State Tigers","location":"Tennessee State","shortDisplayName":"Tennessee St","abbreviation":"TNST","color":"171796","alternateColor":"f0f0f0","slug":"tennessee-state-tigers"},
    "TENNESSEE TECH GOLDEN EAGLES": {"id":"2635","displayName":"Tennessee Tech Golden Eagles","location":"Tennessee Tech","shortDisplayName":"Tennessee Tech","abbreviation":"TNTC","color":"5A4099","alternateColor":"ffde00","slug":"tennessee-tech-golden-eagles"},
    "TENNESSEE VOLUNTEERS": {"id":"2633","displayName":"Tennessee Volunteers","location":"Tennessee","shortDisplayName":"Tennessee","abbreviation":"TENN","color":"ff8200","alternateColor":"ffffff","slug":"tennessee-volunteers"},
    "TEXAS A&M AGGIES": {"id":"245","displayName":"Texas A&M Aggies","location":"Texas A&M","shortDisplayName":"Texas A&M","abbreviation":"TA&M","color":"500000","alternateColor":"ffffff","slug":"texas-am-aggies"},
    "TEXAS A&M-CORPUS CHRISTI ISLANDERS": {"id":"357","displayName":"Texas A&M-Corpus Christi Islanders","location":"Texas A&M-Corpus Christi","shortDisplayName":"Texas A&M-CC","abbreviation":"AMCC","color":"0067c5","alternateColor":"007f3e","slug":"texas-am-corpus-christi-islanders"},
    "TEXAS LONGHORNS": {"id":"251","displayName":"Texas Longhorns","location":"Texas","shortDisplayName":"Texas","abbreviation":"TEX","color":"af5c37","alternateColor":"ffffff","slug":"texas-longhorns"},
    "TEXAS SOUTHERN TIGERS": {"id":"2640","displayName":"Texas Southern Tigers","location":"Texas Southern","shortDisplayName":"Texas Southern","abbreviation":"TXSO","color":"860038","alternateColor":"ffffff","slug":"texas-southern-tigers"},
    "TEXAS STATE BOBCATS": {"id":"326","displayName":"Texas State Bobcats","location":"Texas State","shortDisplayName":"Texas St","abbreviation":"TXST","color":"501214","alternateColor":"6a5638","slug":"texas-state-bobcats"},
    "TEXAS TECH RED RAIDERS": {"id":"2641","displayName":"Texas Tech Red Raiders","location":"Texas Tech","shortDisplayName":"Texas Tech","abbreviation":"TTU","color":"da291c","alternateColor":"000000","slug":"texas-tech-red-raiders"},
    "THE CITADEL BULLDOGS": {"id":"2643","displayName":"The Citadel Bulldogs","location":"The Citadel","shortDisplayName":"The Citadel","abbreviation":"CIT","color":"7badd3","alternateColor":"002856","slug":"the-citadel-bulldogs"},
    "TOLEDO ROCKETS": {"id":"2649","displayName":"Toledo Rockets","location":"Toledo","shortDisplayName":"Toledo","abbreviation":"TOL","color":"0b2240","alternateColor":"ffcd00","slug":"toledo-rockets"},
    "TOWSON TIGERS": {"id":"119","displayName":"Towson Tigers","location":"Towson","shortDisplayName":"Towson","abbreviation":"TOW","color":"FFC229","alternateColor":"","slug":"towson-tigers"},
    "TROY TROJANS": {"id":"2653","displayName":"Troy Trojans","location":"Troy","shortDisplayName":"Troy","abbreviation":"TROY","color":"862633","alternateColor":"b1b1b1","slug":"troy-trojans"},
    "TULANE GREEN WAVE": {"id":"2655","displayName":"Tulane Green Wave","location":"Tulane","shortDisplayName":"Tulane","abbreviation":"TULN","color":"006747","alternateColor":"418fde","slug":"tulane-green-wave"},
    "TULSA GOLDEN HURRICANE": {"id":"202","displayName":"Tulsa Golden Hurricane","location":"Tulsa","shortDisplayName":"Tulsa","abbreviation":"TLSA","color":"003595","alternateColor":"d0b787","slug":"tulsa-golden-hurricane"},
    "UAB BLAZERS": {"id":"5","displayName":"UAB Blazers","location":"UAB","shortDisplayName":"UAB","abbreviation":"UAB","color":"1a5632","alternateColor":"fdb913","slug":"uab-blazers"},
    "UALBANY GREAT DANES": {"id":"399","displayName":"UAlbany Great Danes","location":"UAlbany","shortDisplayName":"UAlbany","abbreviation":"UALB","color":"3D2777","alternateColor":"ffffff","slug":"ualbany-great-danes"},
    "UC DAVIS AGGIES": {"id":"302","displayName":"UC Davis Aggies","location":"UC Davis","shortDisplayName":"UC Davis","abbreviation":"UCD","color":"002855","alternateColor":"c3c4c6","slug":"uc-davis-aggies"},
    "UC IRVINE ANTEATERS": {"id":"300","displayName":"UC Irvine Anteaters","location":"UC Irvine","shortDisplayName":"UC Irvine","abbreviation":"UCI","color":"002B5C","alternateColor":"fec52e","slug":"uc-irvine-anteaters"},
    "UC RIVERSIDE HIGHLANDERS": {"id":"27","displayName":"UC Riverside Highlanders","location":"UC Riverside","shortDisplayName":"UC Riverside","abbreviation":"UCR","color":"14234F","alternateColor":"","slug":"uc-riverside-highlanders"},
    "UC SAN DIEGO TRITONS": {"id":"28","displayName":"UC San Diego Tritons","location":"UC San Diego","shortDisplayName":"UC San Diego","abbreviation":"UCSD","color":"000000","alternateColor":"ffcd00","slug":"uc-san-diego-tritons"},
    "UC SANTA BARBARA GAUCHOS": {"id":"2540","displayName":"UC Santa Barbara Gauchos","location":"UC Santa Barbara","shortDisplayName":"Santa Barbara","abbreviation":"UCSB","color":"1e1840","alternateColor":"febc11","slug":"uc-santa-barbara-gauchos"},
    "UCF KNIGHTS": {"id":"2116","displayName":"UCF Knights","location":"UCF","shortDisplayName":"UCF","abbreviation":"UCF","color":"000000","alternateColor":"b4a169","slug":"ucf-knights"},
    "UCLA BRUINS": {"id":"26","displayName":"UCLA Bruins","location":"UCLA","shortDisplayName":"UCLA","abbreviation":"UCLA","color":"2774ae","alternateColor":"f2a900","slug":"ucla-bruins"},
    "UCONN HUSKIES": {"id":"41","displayName":"UConn Huskies","location":"UConn","shortDisplayName":"UConn","abbreviation":"CONN","color":"0c2340","alternateColor":"a2aaad","slug":"uconn-huskies"},
    "UIC FLAMES": {"id":"82","displayName":"UIC Flames","location":"UIC","shortDisplayName":"UIC","abbreviation":"UIC","color":"001e62","alternateColor":"d50032","slug":"uic-flames"},
    "UL MONROE WARHAWKS": {"id":"2433","displayName":"UL Monroe Warhawks","location":"UL Monroe","shortDisplayName":"UL Monroe","abbreviation":"ULM","color":"840029","alternateColor":"fdb913","slug":"ul-monroe-warhawks"},
    "UMBC RETRIEVERS": {"id":"2378","displayName":"UMBC Retrievers","location":"UMBC","shortDisplayName":"UMBC","abbreviation":"UMBC","color":"000000","alternateColor":"ad860a","slug":"umbc-retrievers"},
    "UMASS LOWELL RIVER HAWKS": {"id":"2349","displayName":"UMass Lowell River Hawks","location":"UMass Lowell","shortDisplayName":"UMass Lowell","abbreviation":"UML","color":"00529C","alternateColor":"cf1f2f","slug":"umass-lowell-river-hawks"},
    "UNC ASHEVILLE BULLDOGS": {"id":"2427","displayName":"UNC Asheville Bulldogs","location":"UNC Asheville","shortDisplayName":"UNC Asheville","abbreviation":"UNCA","color":"003da5","alternateColor":"ffffff","slug":"unc-asheville-bulldogs"},
    "UNC GREENSBORO SPARTANS": {"id":"2430","displayName":"UNC Greensboro Spartans","location":"UNC Greensboro","shortDisplayName":"UNC Greensboro","abbreviation":"UNCG","color":"003559","alternateColor":"ffd90a","slug":"unc-greensboro-spartans"},
    "UNC WILMINGTON SEAHAWKS": {"id":"350","displayName":"UNC Wilmington Seahawks","location":"UNC Wilmington","shortDisplayName":"UNC Wilmington","abbreviation":"UNCW","color":"00665e","alternateColor":"ffda00","slug":"unc-wilmington-seahawks"},
    "UNLV REBELS": {"id":"2439","displayName":"UNLV Rebels","location":"UNLV","shortDisplayName":"UNLV","abbreviation":"UNLV","color":"cf0a2c","alternateColor":"cac8c8","slug":"unlv-rebels"},
    "USC TROJANS": {"id":"30","displayName":"USC Trojans","location":"USC","shortDisplayName":"USC","abbreviation":"USC","color":"9d2235","alternateColor":"ffc72c","slug":"usc-trojans"},
    "UT ARLINGTON MAVERICKS": {"id":"250","displayName":"UT Arlington Mavericks","location":"UT Arlington","shortDisplayName":"UT Arlington","abbreviation":"UTA","color":"004b7c","alternateColor":"f58024","slug":"ut-arlington-mavericks"},
    "UT MARTIN SKYHAWKS": {"id":"2630","displayName":"UT Martin Skyhawks","location":"UT Martin","shortDisplayName":"UT Martin","abbreviation":"UTM","color":"FF6700","alternateColor":"102a5c","slug":"ut-martin-skyhawks"},
    "UT RIO GRANDE VALLEY VAQUEROS": {"id":"292","displayName":"UT Rio Grande Valley Vaqueros","location":"UT Rio Grande Valley","shortDisplayName":"UT Rio Grande","abbreviation":"RGV","color":"dc6000","alternateColor":"e1732d","slug":"ut-rio-grande-valley-vaqueros"},
    "UTEP MINERS": {"id":"2638","displayName":"UTEP Miners","location":"UTEP","shortDisplayName":"UTEP","abbreviation":"UTEP","color":"ff8200","alternateColor":"041e42","slug":"utep-miners"},
    "UTSA ROADRUNNERS": {"id":"2636","displayName":"UTSA Roadrunners","location":"UTSA","shortDisplayName":"UTSA","abbreviation":"UTSA","color":"0c2340","alternateColor":"f15a22","slug":"utsa-roadrunners"},
    "UTAH STATE AGGIES": {"id":"328","displayName":"Utah State Aggies","location":"Utah State","shortDisplayName":"Utah State","abbreviation":"USU","color":"0f2439","alternateColor":"ffffff","slug":"utah-state-aggies"},
    "UTAH TECH TRAILBLAZERS": {"id":"3101","displayName":"Utah Tech Trailblazers","location":"Utah Tech","shortDisplayName":"Utah Tech","abbreviation":"UTU","color":"000000","alternateColor":"","slug":"utah-tech-trailblazers"},
    "UTAH UTES": {"id":"254","displayName":"Utah Utes","location":"Utah","shortDisplayName":"Utah","abbreviation":"UTAH","color":"be0000","alternateColor":"ffffff","slug":"utah-utes"},
    "UTAH VALLEY WOLVERINES": {"id":"3084","displayName":"Utah Valley Wolverines","location":"Utah Valley","shortDisplayName":"Utah Valley","abbreviation":"UVU","color":"004812","alternateColor":"e1c736","slug":"utah-valley-wolverines"},
    "VCU RAMS": {"id":"2670","displayName":"VCU Rams","location":"VCU","shortDisplayName":"VCU","abbreviation":"VCU","color":"ffaf00","alternateColor":"000000","slug":"vcu-rams"},
    "VMI KEYDETS": {"id":"2678","displayName":"VMI Keydets","location":"VMI","shortDisplayName":"VMI","abbreviation":"VMI","color":"ae122a","alternateColor":"000000","slug":"vmi-keydets"},
    "VALPARAISO BEACONS": {"id":"2674","displayName":"Valparaiso Beacons","location":"Valparaiso","shortDisplayName":"Valparaiso","abbreviation":"VAL","color":"794500","alternateColor":"","slug":"valparaiso-beacons"},
    "VANDERBILT COMMODORES": {"id":"238","displayName":"Vanderbilt Commodores","location":"Vanderbilt","shortDisplayName":"Vanderbilt","abbreviation":"VAN","color":"000000","alternateColor":"cfae70","slug":"vanderbilt-commodores"},
    "VERMONT CATAMOUNTS": {"id":"261","displayName":"Vermont Catamounts","location":"Vermont","shortDisplayName":"Vermont","abbreviation":"UVM","color":"154734","alternateColor":"ffc72c","slug":"vermont-catamounts"},
    "VILLANOVA WILDCATS": {"id":"222","displayName":"Villanova Wildcats","location":"Villanova","shortDisplayName":"Villanova","abbreviation":"VILL","color":"00205b","alternateColor":"13b5ea","slug":"villanova-wildcats"},
    "VIRGINIA CAVALIERS": {"id":"258","displayName":"Virginia Cavaliers","location":"Virginia","shortDisplayName":"Virginia","abbreviation":"UVA","color":"232d4b","alternateColor":"f84c1e","slug":"virginia-cavaliers"},
    "VIRGINIA TECH HOKIES": {"id":"259","displayName":"Virginia Tech Hokies","location":"Virginia Tech","shortDisplayName":"Virginia Tech","abbreviation":"VT","color":"6a2c3e","alternateColor":"cf4520","slug":"virginia-tech-hokies"},
    "WAGNER SEAHAWKS": {"id":"2681","displayName":"Wagner Seahawks","location":"Wagner","shortDisplayName":"Wagner","abbreviation":"WAG","color":"00483A","alternateColor":"ffffff","slug":"wagner-seahawks"},
    "WAKE FOREST DEMON DEACONS": {"id":"154","displayName":"Wake Forest Demon Deacons","location":"Wake Forest","shortDisplayName":"Wake Forest","abbreviation":"WAKE","color":"ceb888","alternateColor":"2c2a29","slug":"wake-forest-demon-deacons"},
    "WASHINGTON HUSKIES": {"id":"264","displayName":"Washington Huskies","location":"Washington","shortDisplayName":"Washington","abbreviation":"WASH","color":"33006f","alternateColor":"e8d3a2","slug":"washington-huskies"},
    "WASHINGTON STATE COUGARS": {"id":"265","displayName":"Washington State Cougars","location":"Washington State","shortDisplayName":"Washington St","abbreviation":"WSU","color":"a60f2d","alternateColor":"4d4d4d","slug":"washington-state-cougars"},
    "WEBER STATE WILDCATS": {"id":"2692","displayName":"Weber State Wildcats","location":"Weber State","shortDisplayName":"Weber St","abbreviation":"WEB","color":"18005a","alternateColor":"ebebeb","slug":"weber-state-wildcats"},
    "WEST FLORIDA ARGONAUTS": {"id":"2697","displayName":"West Florida Argonauts","location":"West Florida","shortDisplayName":"West Florida","abbreviation":"UWF","color":"087dc2","alternateColor":"03b186","slug":"west-florida-argonauts"},
    "WEST GEORGIA WOLVES": {"id":"2698","displayName":"West Georgia Wolves","location":"West Georgia","shortDisplayName":"West Georgia","abbreviation":"WGA","color":"0033a1","alternateColor":"db1a21","slug":"west-georgia-wolves"},
    "WEST VIRGINIA MOUNTAINEERS": {"id":"277","displayName":"West Virginia Mountaineers","location":"West Virginia","shortDisplayName":"West Virginia","abbreviation":"WVU","color":"eaaa00","alternateColor":"002855","slug":"west-virginia-mountaineers"},
    "WESTERN CAROLINA CATAMOUNTS": {"id":"2717","displayName":"Western Carolina Catamounts","location":"Western Carolina","shortDisplayName":"W Carolina","abbreviation":"WCU","color":"492F91","alternateColor":"bf9e70","slug":"western-carolina-catamounts"},
    "WESTERN ILLINOIS LEATHERNECKS": {"id":"2710","displayName":"Western Illinois Leathernecks","location":"Western Illinois","shortDisplayName":"W Illinois","abbreviation":"WIU","color":"4e1e8a","alternateColor":"ffc90a","slug":"western-illinois-leathernecks"},
    "WESTERN KENTUCKY HILLTOPPERS": {"id":"98","displayName":"Western Kentucky Hilltoppers","location":"Western Kentucky","shortDisplayName":"Western KY","abbreviation":"WKU","color":"e13a3e","alternateColor":"ffffff","slug":"western-kentucky-hilltoppers"},
    "WESTERN MICHIGAN BRONCOS": {"id":"2711","displayName":"Western Michigan Broncos","location":"Western Michigan","shortDisplayName":"W Michigan","abbreviation":"WMU","color":"532e1f","alternateColor":"f1c500","slug":"western-michigan-broncos"},
    "WICHITA STATE SHOCKERS": {"id":"2724","displayName":"Wichita State Shockers","location":"Wichita State","shortDisplayName":"Wichita St","abbreviation":"WICH","color":"ffcd00","alternateColor":"27251f","slug":"wichita-state-shockers"},
    "WILLIAM & MARY TRIBE": {"id":"2729","displayName":"William & Mary Tribe","location":"William & Mary","shortDisplayName":"William & Mary","abbreviation":"W&M","color":"115740","alternateColor":"f0b323","slug":"william-mary-tribe"},
    "WINTHROP EAGLES": {"id":"2737","displayName":"Winthrop Eagles","location":"Winthrop","shortDisplayName":"Winthrop","abbreviation":"WIN","color":"9e0b0e","alternateColor":"fdb41e","slug":"winthrop-eagles"},
    "WISCONSIN BADGERS": {"id":"275","displayName":"Wisconsin Badgers","location":"Wisconsin","shortDisplayName":"Wisconsin","abbreviation":"WIS","color":"a00000","alternateColor":"ffffff","slug":"wisconsin-badgers"},
    "WOFFORD TERRIERS": {"id":"2747","displayName":"Wofford Terriers","location":"Wofford","shortDisplayName":"Wofford","abbreviation":"WOF","color":"533B22","alternateColor":"f0f0f0","slug":"wofford-terriers"},
    "WRIGHT STATE RAIDERS": {"id":"2750","displayName":"Wright State Raiders","location":"Wright State","shortDisplayName":"Wright St","abbreviation":"WRST","color":"cba052","alternateColor":"cba052","slug":"wright-state-raiders"},
    "WYOMING COWBOYS": {"id":"2751","displayName":"Wyoming Cowboys","location":"Wyoming","shortDisplayName":"Wyoming","abbreviation":"WYO","color":"492f24","alternateColor":"ffc425","slug":"wyoming-cowboys"},
    "XAVIER MUSKETEERS": {"id":"2752","displayName":"Xavier Musketeers","location":"Xavier","shortDisplayName":"Xavier","abbreviation":"XAV","color":"21304e","alternateColor":"a5a7a8","slug":"xavier-musketeers"},
    "YALE BULLDOGS": {"id":"43","displayName":"Yale Bulldogs","location":"Yale","shortDisplayName":"Yale","abbreviation":"YALE","color":"004a81","alternateColor":"286dc0","slug":"yale-bulldogs"},
    "YOUNGSTOWN STATE PENGUINS": {"id":"2754","displayName":"Youngstown State Penguins","location":"Youngstown State","shortDisplayName":"Youngstown St","abbreviation":"YSU","color":"E51935","alternateColor":"690717","slug":"youngstown-state-penguins"},
}

def resolve_team(league, query):
    wanted = upper(query, "ILLINOIS")
    if wanted in TEAM_DIRECTORY:
        return TEAM_DIRECTORY[wanted]
    # ESPN's team directory can lag the dropdown manifest for newly added
    # schools. Keep stable ESPN IDs for those labels and use the direct team
    # endpoint as a fallback if the directory response omits them.
    known_team_ids = {
        "QUEENS UNIVERSITY ROYALS": "2511",
        "LINDENWOOD LIONS": "2815",
        "SOUTHERN INDIANA SCREAMING EAGLES": "88",
    }
    known_team_id = known_team_ids.get(wanted)
    data = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/teams?limit=500" % league, 86400)
    teams = [] if data == None else (((data.get("sports") or [{}])[0].get("leagues") or [{}])[0].get("teams") or [])
    partial = None
    for wrapped in teams:
        team = wrapped.get("team") or {}
        if known_team_id != None and str(team.get("id")) == known_team_id:
            return team
        names = [upper(team.get("displayName")), upper(team.get("location")), upper(team.get("shortDisplayName")), upper(team.get("nickname")), upper(team.get("abbreviation"))]
        if wanted in names:
            return team
        if partial == None:
            for name in names:
                if wanted in name:
                    partial = team
    if partial != None:
        return partial
    if known_team_id != None:
        detail = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/teams/%s" % (league, known_team_id), 86400)
        if detail != None:
            return detail.get("team") or detail
    return None

def find_event(league, team_id):
    data = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/scoreboard?groups=50&limit=1000" % league, 45)
    if data == None:
        return None
    for event in data.get("events", []):
        competition = (event.get("competitions") or [{}])[0]
        for competitor in competition.get("competitors", []):
            if str((competitor.get("team") or {}).get("id")) == team_id:
                return str(event.get("id"))
    return None

def stat_map(table):
    result = {}
    labels = table.get("labels", [])
    for index in range(len(labels)):
        result[str(labels[index]).upper()] = index
    return result

def stat_value(row, indexes, key, fallback = "0"):
    index = indexes.get(key)
    values = row.get("stats", [])
    if index == None or index >= len(values):
        return fallback
    return clean(values[index], fallback)

def average_value(categories, key, fallback = "0.0"):
    for category in categories:
        for item in category.get("stats", []):
            if item.get("name") == key:
                return clean(item.get("displayValue"), fallback)
    return fallback

def tenths(value):
    text = clean(value, "0").split(".")
    whole = int(text[0]) if text[0].isdigit() else 0
    decimal = int(text[1][0]) if len(text) > 1 and len(text[1]) > 0 and text[1][0].isdigit() else 0
    return whole * 10 + decimal

def athlete_position(athlete):
    position = athlete.get("position") or {}
    return upper(position.get("abbreviation") or position.get("name"))

def athlete_height(athlete):
    # ESPN normally supplies displayHeight (for example 6' 6\"). Compact it
    # for the 128-pixel header so it reads cleanly beside the player name.
    height = upper(athlete.get("displayHeight") or athlete.get("height"))
    return height.replace("' ", "'").replace("\"", "").replace(" ", "")

def athlete_bio(athlete):
    position = athlete_position(athlete)
    height = athlete_height(athlete)
    if position != "" and height != "":
        return position + " " + height
    return position if position != "" else height

def athlete_weight(athlete):
    weight = upper(athlete.get("displayWeight") or athlete.get("weight"))
    return weight.replace("POUNDS", "").replace("LBS", "").replace("LB", "").strip()

def athlete_year(athlete):
    experience = athlete.get("experience") or {}
    value = upper(experience.get("abbreviation") or experience.get("displayValue") or athlete.get("class"))
    classes = {
        "FRESHMAN": "FR",
        "SOPHOMORE": "SO",
        "JUNIOR": "JR",
        "SENIOR": "SR",
        "GRADUATE": "GR",
        "GRADUATE STUDENT": "GR",
    }
    return classes.get(value, value)

def athlete_extra_bio(athlete):
    return athlete_year(athlete)

def season_data(league, team):
    team_id = str(team.get("id"))
    roster = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/teams/%s/roster" % (league, team_id), 21600)
    if roster == None:
        return {"error": "ROSTER OFFLINE"}
    roster_info = {}
    for athlete in (roster.get("athletes") or []):
        athlete_id = str(athlete.get("id"))
        roster_info[athlete_id] = {
            "name": upper(athlete.get("shortName") or athlete.get("displayName") or athlete.get("fullName"), "PLAYER"),
            "jersey": clean(athlete.get("jersey"), "0"),
            "bio": athlete_bio(athlete),
            "extra_bio": athlete_extra_bio(athlete),
        }
    slug = clean(team.get("slug"), team_id)
    page_url = "https://www.espn.com/%s/team/stats/_/id/%s/%s" % (league, team_id, slug)
    response = http.get(page_url, headers = {"User-Agent": "Mozilla/5.0 (compatible; Glance College Basketball Tracker)"}, ttl_seconds = 21600)
    if response.get("status_code", 0) != 200:
        return {"error": "AVERAGES OFFLINE"}
    body = clean(response.get("body"))
    marker = "window['__espnfitt__']="
    if marker not in body:
        return {"error": "AVERAGES NOT POSTED"}
    payload = body.split(marker, 1)[1].split(";</script>", 1)[0]
    document = json.decode(payload)
    rows = (((((document.get("page") or {}).get("content") or {}).get("stats") or {}).get("playerStats") or [[]])[0])
    players = []
    players_with_stats = []
    for row in rows:
        athlete = row.get("athlete") or {}
        athlete_id = clean(athlete.get("uid")).split("~a:")[-1]
        # The ESPN averages page can retain last season's departed players while
        # the roster endpoint has already rolled forward. Only join rows whose
        # athlete ID is still on the selected team's current roster.
        if athlete_id not in roster_info:
            continue
        players_with_stats.append(athlete_id)
        values = {}
        for item in ((row.get("statGroups") or {}).get("stats") or []):
            values[item.get("name")] = clean(item.get("displayValue"), "0.0")
        players.append({
            "id": athlete_id,
            "name": upper(athlete.get("shortName") or athlete.get("name"), "PLAYER"),
            "jersey": roster_info.get(athlete_id, {}).get("jersey", ""),
            "bio": roster_info.get(athlete_id, {}).get("bio", ""),
            "extra_bio": roster_info.get(athlete_id, {}).get("extra_bio", ""),
            "starter": False,
            "min": values.get("avgMinutes", "0.0"),
            "pts": values.get("avgPoints", "0.0"),
            "reb": values.get("avgRebounds", "0.0"),
            "ast": values.get("avgAssists", "0.0"),
            "stl": values.get("avgSteals", "0.0"),
            "blk": values.get("avgBlocks", "0.0"),
            "fg": values.get("fieldGoalPct", "-")
        })
    # Missing statistics are unknown, not zero. Retain current roster identity
    # without inventing averages for players whose stat rows are not posted.
    for athlete_id in roster_info:
        if athlete_id in players_with_stats:
            continue
        info = roster_info[athlete_id]
        players.append({
            "id": athlete_id,
            "name": info.get("name", "PLAYER"),
            "jersey": info.get("jersey", ""),
            "bio": info.get("bio", ""),
            "extra_bio": info.get("extra_bio", ""),
            "starter": False,
            "min": "--",
            "pts": "--",
            "reb": "--",
            "ast": "--",
            "stl": "--",
            "blk": "--",
            "fg": "-",
        })
    return {"players": players, "team": team, "opponent": {}, "team_score": "", "opponent_score": "", "state": "AVG", "detail": "SEASON AVERAGES", "mode": "AVERAGES"}

def game_data(ctx):
    league = LEAGUES.get(upper(ctx.inputs.get("league"), "MEN"), LEAGUES["MEN"])
    selected_team = resolve_team(league, ctx.inputs.get("team"))
    if selected_team == None:
        return {"error": "SCHOOL NOT FOUND"}
    team_id = str(selected_team.get("id"))
    event_id = upper(ctx.inputs.get("event"), "AUTO")
    if event_id == "AUTO":
        event_id = find_event(league, team_id)
    if event_id == None:
        return season_data(league, selected_team)
    data = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/summary?event=%s" % (league, event_id), 30)
    if data == None:
        return {"error": "GAME DATA OFFLINE"}

    competition = ((data.get("header") or {}).get("competitions") or [{}])[0]
    team = None
    opponent = None
    for competitor in competition.get("competitors", []):
        if str((competitor.get("team") or {}).get("id")) == team_id:
            team = competitor
        else:
            opponent = competitor
    if team == None:
        return {"error": "TEAM NOT IN GAME"}

    table = None
    for group in (data.get("boxscore") or {}).get("players", []):
        if str((group.get("team") or {}).get("id")) == team_id:
            tables = group.get("statistics") or []
            if len(tables) > 0:
                table = tables[0]
    if table == None:
        if upper(((competition.get("status") or {}).get("type") or {}).get("state")) == "PRE":
            return season_data(league, selected_team)
        return {"error": "STATS NOT POSTED"}

    indexes = stat_map(table)
    players = []
    for row in table.get("athletes", []):
        athlete = row.get("athlete") or {}
        minutes = stat_value(row, indexes, "MIN", "0")
        if row.get("didNotPlay", False) or minutes == "0" or minutes == "0:00" or minutes == "--":
            continue
        players.append({
            "id": str(athlete.get("id")),
            "name": upper(athlete.get("shortName") or athlete.get("displayName"), "PLAYER"),
            "jersey": clean(athlete.get("jersey"), ""),
            "bio": athlete_bio(athlete),
            "extra_bio": athlete_extra_bio(athlete),
            "starter": row.get("starter", False) == True,
            "min": minutes,
            "pts": stat_value(row, indexes, "PTS"),
            "reb": stat_value(row, indexes, "REB"),
            "ast": stat_value(row, indexes, "AST"),
            "stl": stat_value(row, indexes, "STL"),
            "blk": stat_value(row, indexes, "BLK"),
            "fg": stat_value(row, indexes, "FG", "-")
        })

    status = competition.get("status") or {}
    status_type = status.get("type") or {}
    state = upper(status_type.get("state"), "PRE")
    detail = upper(status_type.get("shortDetail") or status_type.get("detail"), "SCHEDULED")
    return {
        "players": players,
        "team": team.get("team") or {},
        "opponent": (opponent or {}).get("team") or {},
        "opponent_ap_rank": current_opponent_ap(league, opponent, (data.get("header") or {}).get("season", {}).get("year")),
        "team_score": clean(team.get("score"), "0"),
        "opponent_score": clean((opponent or {}).get("score"), "0"),
        "team_home_away": clean(team.get("homeAway"), "away"),
        "opponent_home_away": clean((opponent or {}).get("homeAway"), "home"),
        "state": state,
        "detail": detail,
        "period": int(status.get("period") or 0),
        "clock": clean(status.get("displayClock")),
        "mode": "GAME",
    }

def current_opponent_ap(league, competitor, season):
    # Use the named AP poll only, never an unspecified curated/Coaches rank.
    if competitor == None or season == None:
        return ""
    payload = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/rankings?season=%s" % (league, season), 1800)
    if payload == None:
        return ""
    wanted = str((competitor.get("team") or {}).get("id", ""))
    for poll in payload.get("rankings", []):
        if poll.get("name") != "AP Top 25" or str((poll.get("season") or {}).get("year")) != str(season):
            continue
        for row in poll.get("ranks", []):
            rank = str(row.get("current", ""))
            if str((row.get("team") or {}).get("id")) == wanted and rank.isdigit() and int(rank) >= 1 and int(rank) <= 25:
                return rank
    return ""

def points_value(item):
    text = clean(item.get("pts"), "0")
    return tenths(text)

def lineup(game):
    players = game.get("players", [])
    if game.get("mode") == "GAME":
        starters = []
        bench = []
        for item in players:
            if item.get("starter", False):
                starters.append(item)
            else:
                bench.append(item)
        if len(starters) >= 5:
            ordered = starters[:5]
            selected = []
            for slot in range(2):
                best = None
                for item in bench:
                    if item["id"] in selected:
                        continue
                    if best == None or points_value(item) > points_value(best):
                        best = item
                if best != None:
                    ordered.append(best)
                    selected.append(best["id"])
            # The seven selected players are displayed in scoring order, while
            # selection itself remains the five starters plus two bench leaders.
            ranked = []
            ranked_ids = []
            for slot in range(len(ordered)):
                best = None
                for item in ordered:
                    if item["id"] in ranked_ids:
                        continue
                    if best == None or points_value(item) > points_value(best):
                        best = item
                if best != None:
                    ranked.append(best)
                    ranked_ids.append(best["id"])
            return ranked
    ordered = []
    selected = []
    for slot in range(7):
        best = None
        for item in players:
            if item["id"] in selected:
                continue
            if best == None or points_value(item) > points_value(best):
                best = item
        if best != None:
            ordered.append(best)
            selected.append(best["id"])
    return ordered

def draw_jersey(c, x, y, primary, shade, trim, number):
    palette = {"P": primary, "D": shade, "L": primary, "S": trim, "W": INK}
    # Layer the compressed artwork so the 18px body cannot overwrite its own
    # dark edge or bright trim when multiple source pixels land on one pixel.
    for layer in [["P", "L"], ["D"], ["S", "W"]]:
        for row in range(len(JERSEY)):
            for column in range(len(JERSEY[row])):
                pixel = JERSEY[row][column]
                if pixel in layer:
                    c.pixel(x + (column * 3) // 5, y + (row * 3) // 5, palette.get(pixel, primary))
    digits = clean(number)[-2:]
    if digits != "":
        center_x = x + 8 if len(digits) > 1 else x + 9
        number_y = y + 7
        c.text(digits, center_x - 1, number_y, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x + 1, number_y, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x, number_y - 1, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x, number_y + 1, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x, number_y, font = "4x5", color = INK, align = "center")

def draw_small_number(c, number, center_x, y, shade):
    digits = clean(number)[-2:]
    if digits == "":
        return
    # Use the native eight-direction stroke so diagonal corners are complete
    # and the small jersey number reads as one clean outlined glyph.
    c.text_stroke(digits, center_x, y, font = "4x5", color = INK, stroke = shade, thickness = 1, align = "center")

def draw_native_jersey(c, x, y, primary, shade, background, number):
    palette = {"P": primary, "D": shade, "W": INK}
    for row in range(len(NATIVE_JERSEY_20)):
        for column in range(22):
            if column <= 3:
                source_column = column
            elif column <= 18:
                source_column = 3 + ((column - 3) * 13 + 7) // 15
            else:
                source_column = column - 2
            pixel = NATIVE_JERSEY_20[row][source_column]
            if pixel != ".":
                c.pixel(x + column, y + row, palette[pixel])
    digits = clean(number)[-2:]
    if digits != "":
        number_width = c.text_width(digits, "4x5")
        number_left = x + (22 - number_width) // 2
        c.text_stroke(digits, number_left, y + 10, font = "4x5", color = INK, stroke = shade, thickness = 1, align = "left")

def draw_minimal_jersey(c, x, y, primary, shade, background, number):
    # Same basketball-tank silhouette without bright trim details.
    c.rect(x + 3, y + 6, x + 14, y + 17, fill = shade)
    c.rect(x + 4, y + 1, x + 7, y + 8, fill = shade)
    c.rect(x + 10, y + 1, x + 13, y + 8, fill = shade)
    c.rect(x + 4, y + 7, x + 13, y + 16, fill = primary)
    c.rect(x + 5, y + 2, x + 6, y + 7, fill = primary)
    c.rect(x + 11, y + 2, x + 12, y + 7, fill = primary)
    c.pixel(x + 7, y + 2, background)
    c.pixel(x + 10, y + 2, background)
    c.pixel(x + 8, y + 3, background)
    c.pixel(x + 9, y + 3, background)
    draw_small_number(c, number, x + 9, y + 9, shade)

def draw_number_badge(c, x, y, primary, shade, number):
    c.round_rect(x + 2, y + 1, x + 16, y + 17, 3, fill = primary, outline = shade)
    draw_small_number(c, number, x + 9, y + 7, shade)

def fit(c, text, x, y, width, font, color_value):
    value = upper(text)
    fitted = value
    for size in range(len(value), 0, -1):
        candidate = value[:size]
        if c.text_width(candidate, font) <= width:
            fitted = candidate
            break
    c.text(fitted, x, y, font = font, color = color_value)
    return c.text_width(fitted, font)

def compact_bio_width(c, bio):
    if "'" not in bio:
        return c.text_width(bio, "picopixel")
    parts = bio.split("'", 1)
    return c.text_width(parts[0], "picopixel") + 3 + c.text_width(parts[1], "picopixel")

def draw_compact_bio(c, bio, x, y, color_value):
    if "'" not in bio:
        c.text_stroke(bio, x, y, font = "picopixel", color = color_value, stroke = LINE, thickness = 1, align = "left")
        return
    # picopixel has no visible apostrophe glyph, so reserve two pixels and
    # draw the height mark directly between the feet and inches digits.
    parts = bio.split("'", 1)
    left_width = c.text_width(parts[0], "picopixel")
    c.text_stroke(parts[0], x, y, font = "picopixel", color = color_value, stroke = LINE, thickness = 1, align = "left")
    mark_x = x + left_width + 1
    c.pixel(mark_x, y, color_value)
    c.pixel(mark_x, y + 1, color_value)
    c.pixel(mark_x - 1, y, LINE)
    c.pixel(mark_x + 1, y, LINE)
    c.pixel(mark_x - 1, y + 1, LINE)
    c.pixel(mark_x + 1, y + 1, LINE)
    c.text_stroke(parts[1], mark_x + 2, y, font = "picopixel", color = color_value, stroke = LINE, thickness = 1, align = "left")

def error_page(c, message):
    c.fill("#152338")
    c.rect(0, 0, c.width - 1, 31, outline = "#0B1424")
    c.text("COLLEGE HOOPS", c.width // 2, 3, font = "5x7", color = WARN, align = "center")
    c.text(message, c.width // 2, 15, font = "4x5", color = INK, align = "center")
    c.text("CHECK SCHOOL" if message == "SCHOOL NOT FOUND" else "TRY AGAIN LATER", c.width // 2, 24, font = "picopixel", color = DIM, align = "center")

def score_number(value):
    text = clean(value, "0")
    return int(text) if text.isdigit() else 0

def draw_team_logo(c, team, x, y, line_color):
    team_id = str(team.get("id"))
    if team_id in [str(t.get("id")) for t in TEAM_DIRECTORY.values()]:
        c.image(team_id + ".png", x, y, w = 11, h = 9)
        return
    abbreviation = upper(team.get("abbreviation"), "T")[:2]
    c.rect(x, y, x + 10, y + 8, fill = dark_fill(line_color), outline = line_color)
    c.text(abbreviation, x + 5, y + 2, font = "3x4", color = INK, align = "center")

def draw_stat(c, label, value, x, label_y, value_y, value_font, value_color):
    c.text(label, x, label_y, font = "3x4", color = DIM)
    if clean(value) != "":
        c.text(clean(value), x, value_y, font = value_font, color = value_color)

def original_player_page(c, ctx, page_index, force_average = False, preview_game = False, mark_style = "native"):
    if force_average:
        selected_team = resolve_team(LEAGUES["MEN"], ctx.inputs.get("team"))
        game = season_data(LEAGUES["MEN"], selected_team) if selected_team != None else {"error": "SCHOOL NOT FOUND"}
    else:
        game = game_data(ctx)
    if game.get("error") != None:
        error_page(c, game["error"])
        return
    players = lineup(game)
    if page_index >= len(players):
        error_page(c, "LINEUP NOT POSTED")
        return
    athlete = players[page_index]

    team = game["team"]
    primary = hex_color(team.get("color"), "#1F5AA6")
    if str(team.get("id")) == "183":
        # Syracuse's jersey is its signature orange, even when ESPN returns a
        # stale or alternate team color for the selected team record.
        primary = "#F76900"
    safe_team_color = darker_team_color(team)
    line_color = team_tint(safe_team_color, ILLINOIS_BORDER)
    background = team_tint(safe_team_color, ILLINOIS_PANEL)
    if str(team.get("id")) == "356":
        line_color = ILLINOIS_BORDER
        background = ILLINOIS_PANEL
    if str(team.get("id")) == "2305":
        # Kansas needs a visibly blue panel rather than a nearly neutral navy.
        line_color = team_tint(primary, ILLINOIS_BORDER)
        background = rgb_hex(
            (channel(primary, 0) + channel(ILLINOIS_PANEL, 0)) // 2,
            (channel(primary, 2) + channel(ILLINOIS_PANEL, 2)) // 2,
            (channel(primary, 4) + channel(ILLINOIS_PANEL, 4)) // 2,
        )
    accent = readable_team_accent(team, background)
    if str(team.get("id")) == "356":
        accent = primary
    # vline's third argument is its pixel length, not its ending y coordinate.
    divider_height = 20 if game.get("mode") == "AVERAGES" else 15
    c.fill(background)
    c.rect(0, 0, 127, 31, outline = line_color)
    # The featured PTS box keeps its full-height borders on both sides.

    c.vline(47, 11, 20, line_color)
    # Keep points in the wide feature box and divide the remaining stat area evenly.
    c.vline(67, 11, divider_height, line_color)
    c.vline(87, 11, divider_height, line_color)
    c.vline(107, 11, divider_height, line_color)
    if mark_style == "badge":
        draw_number_badge(c, 4, 12, primary, line_color, athlete["jersey"])
    elif mark_style == "minimal":
        draw_minimal_jersey(c, 4, 12, primary, line_color, background, athlete["jersey"])
    else:
        draw_native_jersey(c, -1, 11, primary, line_color, background, athlete["jersey"])
    bio = clean(athlete.get("bio"))
    bio_width = compact_bio_width(c, bio) if bio != "" else 0
    # Keep the name on its original baseline. Height and position sit beside
    # it in the same compact font used by the stat-category labels.
    name_width = 111 if bio == "" else 107 - bio_width
    rendered_name_width = fit(c, athlete["name"], 2, 2, name_width, "5x7", INK)
    if bio != "":
        bio_x = 2 + rendered_name_width + 6
        draw_compact_bio(c, bio, bio_x, 3, DIM)
        extra_bio = clean(athlete.get("extra_bio"))
        extra_x = bio_x + bio_width + 4
        available_extra_width = 114 - extra_x
        if extra_bio != "" and c.text_width(extra_bio, "picopixel") <= available_extra_width:
            c.text_stroke(extra_bio, extra_x, 3, font = "picopixel", color = DIM, stroke = LINE, thickness = 1, align = "left")
    draw_team_logo(c, team, 115, 1, line_color)
    c.hline(1, 10, 126, line_color)

    # Match the compact rank/rating labels from the Illinois Team Page.
    category_y = 13 if game.get("mode") == "AVERAGES" else 12
    c.text_stroke("PTS", 32, category_y, font = "picopixel", color = accent, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke("REB", 57, category_y, font = "picopixel", color = accent, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke("AST", 77, category_y, font = "picopixel", color = accent, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke("STL", 97, category_y, font = "picopixel", color = accent, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke("BLK", 117, category_y, font = "picopixel", color = accent, stroke = line_color, thickness = 1, align = "center")



    if game.get("mode") == "AVERAGES":
        stat_values = {
            "pts": clean(athlete.get("pts"), "0.0"),
            "reb": clean(athlete.get("reb"), "0.0"),
            "ast": clean(athlete.get("ast"), "0.0"),
            "stl": clean(athlete.get("stl"), "0.0"),
            "blk": clean(athlete.get("blk"), "0.0"),
        }
        pts_y = 20
        pts_font = "6x8"
        secondary_y = 22
    else:
        stat_values = {
            "pts": clean(athlete.get("pts"), "0"),
            "reb": clean(athlete.get("reb"), "0"),
            "ast": clean(athlete.get("ast"), "0"),
            "stl": clean(athlete.get("stl"), "0"),
            "blk": clean(athlete.get("blk"), "0"),
        }
        pts_y = 20
        pts_font = "7x12"
        secondary_y = 19
    c.text_stroke(stat_values["pts"], 32, pts_y, font = pts_font, color = INK, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke(stat_values["reb"], 57, secondary_y, font = "4x5", color = INK, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke(stat_values["ast"], 77, secondary_y, font = "4x5", color = INK, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke(stat_values["stl"], 97, secondary_y, font = "4x5", color = INK, stroke = line_color, thickness = 1, align = "center")
    c.text_stroke(stat_values["blk"], 117, secondary_y, font = "4x5", color = INK, stroke = line_color, thickness = 1, align = "center")

    if game.get("mode") == "AVERAGES":
        return

    # Separate the live/final score strip from the stat grid above it.
    c.hline(48, 25, 126, line_color)

    team_abbr = upper(game["team"].get("abbreviation"), "TEAM")[:3]
    opponent_abbr = upper(game["opponent"].get("abbreviation"), "OPP")[:3]
    team_abbr_color = official_team_accent(game["team"], background)
    opponent_abbr_color = official_team_accent(game["opponent"], background)
    if game["state"] == "IN":
        team_score_color = INK
        opponent_score_color = INK
        status_color = LIVE
        period = int(game.get("period") or 0)
        period_label = "1H" if period == 1 else "2H" if period == 2 else "OT" if period > 2 else "LIVE"
        short_status = clean(game.get("clock"))
        status_font = "picopixel"
        status_x = 126
    elif game["state"] == "POST":
        team_total = score_number(game["team_score"])
        opponent_total = score_number(game["opponent_score"])
        team_score_color = LIVE if team_total > opponent_total else DARK_LOSER if team_total < opponent_total else DIM
        opponent_score_color = LIVE if opponent_total > team_total else DARK_LOSER if opponent_total < team_total else DIM
        status_color = RED
        short_status = "FINAL"
        status_font = "3x4"
        status_x = 126
    else:
        team_score_color = DIM
        opponent_score_color = DIM
        status_color = WARN
        short_status = "NEXT"
        status_font = "3x4"
        status_x = 126
    team_first = game.get("team_home_away", "away") == "away"
    away_abbr = team_abbr if team_first else opponent_abbr
    home_abbr = opponent_abbr if team_first else team_abbr
    away_score = game["team_score"] if team_first else game["opponent_score"]
    home_score = game["opponent_score"] if team_first else game["team_score"]
    away_color = team_abbr_color if team_first else opponent_abbr_color
    home_color = opponent_abbr_color if team_first else team_abbr_color
    score_numbers = away_score + "-" + home_score
    # Anchor the score strip: only the away and home team labels shift.
    away_x = 49
    score_x = 51 + c.text_width(away_abbr, "picopixel")
    home_x = score_x + c.text_width(score_numbers, "picopixel") + 2
    c.text(away_abbr, away_x, 26, font = "picopixel", color = away_color)
    c.text(score_numbers, score_x, 26, font = "picopixel", color = INK)
    c.text(home_abbr, home_x, 26, font = "picopixel", color = home_color)
    if game["state"] == "IN":
        c.text(period_label, 100, 26, font = "picopixel", color = status_color)
    c.text(short_status, status_x, 26, font = status_font, color = status_color, align = "right")

def capture_jersey(art, x, y, color = "white", legend = {}):
    return {"art": art, "legend": legend, "color": color}

def editable_jersey(c):
    # Click inside the c.sprite line below, then Pixel art.
    # Orange = school color, navy = outline, white = collar. Numbers stay automatic.
    return c.sprite(".....DDDDDD......DDDDDD.....\n.....DPPPPD......DPPPPD.....\n.....DPPPPD......DPPPPD.....\n.....DPPPPD......DPPPPD.....\n.....DPPPPD......DPPPPD.....\n.....DPPPPD......DPPPPD.....\n....DPPPPPWD....DWPPPPPD....\n...DPPPPPPPWD..DWPPPPPPPD...\n...DPPPPPPPPWWWWPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DPPPPPPPPPPPPPPPPPPPPD...\n...DDDDDDDDDDDDDDDDDDDDDD...", 3, 2, legend={"P":"orange","D":"navy","W":"white"})

def large_tracker_jersey(c, primary, border, number):
    artwork = editable_jersey(struct(sprite = capture_jersey))
    rows = artwork["art"].split("\n")
    palette = {"orange": primary, "navy": border, "white": INK}
    jersey_x = -2  # Artwork's 3px transparent inset leaves the jersey 1px from the panel edge.
    for row in range(min(28, len(rows))):
        for column in range(min(28, len(rows[row]))):
            pixel = rows[row][column]
            if pixel not in [".", " "]:
                color = artwork["legend"].get(pixel, artwork["color"])
                c.pixel(jersey_x + column, 2 + row, palette.get(color, color))
    digits = clean(number)[-2:]
    if digits != "":
        width = c.text_width(digits, "6x8")
        # Odd-width pairs fall between the jersey's two center pixels; round
        # their placement right rather than leaving the pair visually left-heavy.
        number_x = jersey_x + (28 - width + 1) // 2
        c.text_stroke(digits, number_x, 16, font = "6x8", color = INK, stroke = border, thickness = 1, align = "left")

def tracker_text(c, value, x, y, width, fonts, color, align = "left"):
    text = upper(value)
    font = fonts[-1]
    for candidate in fonts:
        if c.text_width(text, candidate) <= width:
            font = candidate
            break
    if c.text_width(text, font) > width:
        for count in range(len(text), 0, -1):
            if c.text_width(text[:count] + "..", font) <= width:
                text = text[:count] + ".."
                break
    c.text_stroke(text, x, y, font = font, color = color, stroke = "#0B1424", thickness = 1, align = align)
    return c.text_width(text, font)

def display_player_name(athlete, players):
    name = clean(athlete.get("name"), "PLAYER")
    parts = name.split(" ")
    if len(parts) < 2:
        return name
    first = parts[0]
    if len(first) != 2 or first[1] != ".":
        return name
    last = parts[-1]
    matches = 0
    for player in players:
        other = clean(player.get("name")).split(" ")
        if len(other) > 1 and other[-1] == last:
            matches += 1
    if matches > 1:
        return name
    return " ".join(parts[1:])

def overtime_label(period):
    if period <= 2:
        return ""
    overtime_number = period - 2
    return "OT" if overtime_number == 1 else "OT" + str(overtime_number)

def final_overtime_label(game):
    period = int(game.get("period") or 0)
    label = overtime_label(period)
    if label != "":
        return label
    detail = upper(game.get("detail"))
    for number in range(20, 1, -1):
        if "OT" + str(number) in detail or str(number) + "OT" in detail:
            return "OT" + str(number)
    if "OT3" in detail or "3OT" in detail:
        return "OT3"
    if "OT2" in detail or "2OT" in detail:
        return "OT2"
    if "OT" in detail:
        return "OT"
    return ""

def draw_decimal_stat(c, value, center, y, color_value):
    text = clean(value, "--")
    font = "4x5" if c.text_width(text, "4x5") <= 17 else "picopixel"
    dot_bearing = 2 if font == "4x5" else 1
    if "." not in text:
        c.text_stroke(text, center - c.text_width(text, font) - dot_bearing, y, font = font, color = color_value, stroke = "#0B1424", thickness = 1)
        return
    whole = text.split(".", 1)[0]
    whole_x = center - c.text_width(whole, font) - 1 - dot_bearing + 1
    dot_x = center - dot_bearing
    c.text_stroke(whole, whole_x, y, font = font, color = color_value, stroke = "#0B1424", thickness = 1)
    c.text_stroke("." + text.split(".", 1)[1], dot_x, y, font = font, color = color_value, stroke = "#0B1424", thickness = 1)

def player_page(c, ctx, page_index, force_average = False, preview_game = False, mark_style = "native"):
    # STUDIO DESIGN: identity above context above stats. Keep the same geometry
    # for averages and game results, so the card does not jump at the final horn.
    game = game_data(ctx)
    if game.get("error") != None:
        error_page(c, game["error"])
        return
    players = lineup(game)
    if page_index >= len(players):
        error_page(c, "LINEUP NOT POSTED")
        return
    athlete = players[page_index]
    team = game["team"]
    # School-specific dark primary tint, rather than a universal navy panel.
    team_primary = hex_color(team.get("color"), "#1F5AA6")
    background = rgb_hex(12 + channel(team_primary, 0) // 6, 12 + channel(team_primary, 2) // 6, 12 + channel(team_primary, 4) // 6)
    if str(team.get("id")) == "356":
        background = "#152338"
    preview_mode = ctx.inputs.get("preview", "AUTO")
    demo = preview_mode in ["LIVE DEMO", "NORMAL FINAL DEMO", "OT FINAL DEMO"]
    if demo:
        game = dict(game)
        live_demo = preview_mode == "LIVE DEMO"
        ot_final_demo = preview_mode == "OT FINAL DEMO"
        game.update({"mode": "GAME", "state": "IN" if live_demo else "POST", "opponent": {"abbreviation": "MSU", "color": "18453B", "alternateColor": "FFFFFF"}, "team_score": "78", "opponent_score": "74", "team_home_away": "away", "opponent_home_away": "home", "period": 2 if live_demo or not ot_final_demo else 4, "clock": "12:34", "detail": "LIVE" if live_demo else "FINAL/2OT" if ot_final_demo else "FINAL"})
        athlete = dict(athlete)
        athlete.update({"pts": "24", "reb": "11", "ast": "6", "stl": "2", "blk": "1"})
    border = "#0B1424"
    primary = hex_color(team.get("color"), "#1F5AA6")
    if str(team.get("id")) == "183":
        primary = "#F76900"
    accent = readable_team_accent(team, background)
    c.fill(background)
    c.rect(0, 0, 127, 31, outline = border)
    # One quiet rule, rather than boxing every individual statistic.
    c.hline(25, 9, 101, primary)
    bio = clean(athlete.get("bio"))
    year = clean(athlete.get("extra_bio"))
    player_name = display_player_name(athlete, game.get("players", []))
    player_name = player_name.replace(". ", ".")
    bio_parts = bio.split(" ", 1)
    position = bio_parts[0] if bio != "" and "'" not in bio_parts[0] else ""
    height = bio_parts[1] if len(bio_parts) > 1 else bio if "'" in bio else ""
    # Measure the whole header before positioning details; preserve the name.
    details = [value for value in [position, height, year] if value != ""]
    detail_width = 0
    for value in details:
        detail_width += compact_bio_width(c, value)
    opponent_rank = clean(game.get("opponent_ap_rank"), "") if game.get("mode") != "AVERAGES" else ""
    rank_badge = "OPP #" + opponent_rank if opponent_rank.isdigit() and int(opponent_rank) >= 1 and int(opponent_rank) <= 25 else ""
    # Keep all score/clock/OT anchors unchanged; the AP opponent badge owns a
    # measured header zone. Optional biography yields before player identity.
    header_width = 89 - (c.text_width(rank_badge, "picopixel") + 3 if rank_badge != "" else 0)
    name_budget = header_width - detail_width - 2 * len(details)
    # Identity takes priority over optional biography on unusually long names.
    if c.text_width(player_name, "picopixel") > name_budget:
        details = []
        detail_width = 0
        name_budget = header_width
    if c.text_width(player_name, "picopixel") > name_budget:
        shortened = ""
        for letter in player_name:
            if c.text_width(shortened + letter + ".", "picopixel") <= name_budget:
                shortened += letter
        player_name = shortened + "."
    name_font = "picopixel"
    for candidate in ["5x7", "4x5", "picopixel"]:
        if c.text_width(player_name, candidate) <= name_budget:
            name_font = candidate
            break
    name_width = c.text_width(player_name, name_font)
    gap = min(4, max(2, (header_width - name_width - detail_width) // max(1, len(details))))
    c.text_stroke(player_name, 25, 1 if name_font == "5x7" else 2, font = name_font, color = INK, stroke = border, thickness = 1)
    detail_x = 25 + name_width
    for value in details:
        detail_x += gap
        draw_compact_bio(c, value, detail_x, 3, "#A4B0BF")
        detail_x += compact_bio_width(c, value)
    if rank_badge != "":
        tight_rank_color = readable_team_accent(game.get("opponent", {}), background)
        c.text(rank_badge, 114, 2, font = "picopixel", color = tight_rank_color, align = "right")
    draw_team_logo(c, team, 116, 0, border)
    # Michigan wears maize; keep the school's navy panel and other accents unchanged.
    jersey_color = "#FFCB05" if str(team.get("id")) == "130" else primary
    if str(team.get("id")) == "2097":
        jersey_color = "#EA7125"  # Official Campbell Orange: brand.campbell.edu/visual-identity/color-palette/
    large_tracker_jersey(c, jersey_color, border, athlete["jersey"])
    if game.get("mode") != "AVERAGES":
        state = game.get("state")
    labels = ["PTS", "REB", "AST", "STL", "BLK"]
    keys = ["pts", "reb", "ast", "stl", "blk"]
    centers = [37, 61, 80, 99, 118]
    for index in range(5):
        center = centers[index]
        value = clean(athlete.get(keys[index]), "--")
        if index == 0:
            # Dedicated points column stays full-height in every mode.
            tracker_text(c, labels[index], center, 11, 24, ["picopixel"], accent, "center")
            points_width = tracker_text(c, value, center, 18, 28, ["scoretext", "6x8", "5x7"], INK, "center")
        else:
            live_layout = game.get("mode") != "AVERAGES"
            tracker_text(c, labels[index], center, 11 if live_layout else 13, 24, ["picopixel"], "#A4B0BF", "center")
            if live_layout:
                stat_font = "4x5" if c.text_width(value, "4x5") <= 17 else "picopixel"
                tracker_text(c, value, center, 18, 18, [stat_font], INK, "center")
            else:
                draw_decimal_stat(c, value, center, 21, INK)
    if game.get("mode") != "AVERAGES":
        own = upper(team.get("abbreviation"), "TEAM")
        opp = upper(game.get("opponent", {}).get("abbreviation"), "OPP")
        team_first = game.get("team_home_away", "away") == "away"
        away_abbr = own if team_first else opp
        home_abbr = opp if team_first else own
        away_score = clean(game.get("team_score"), "0") if team_first else clean(game.get("opponent_score"), "0")
        home_score = clean(game.get("opponent_score"), "0") if team_first else clean(game.get("team_score"), "0")
        score_numbers = away_score + "-" + home_score
        # Keep game context beneath REB–BLK only; PTS remains its own column.
        if state == "IN":
            period = int(game.get("period") or 0)
            detail = upper(game.get("detail"))
            is_halftime = "HALFTIME" in detail or "HALF TIME" in detail
            footer_period = "HALFTIME" if is_halftime else "1H" if period == 1 else "2H" if period == 2 else overtime_label(period) if period > 2 else "LIVE"
            footer_clock = "" if is_halftime else clean(game.get("clock"))
            footer_status = footer_period if is_halftime else footer_period + " " + footer_clock
            footer_color = LIVE
        elif state == "POST":
            overtime = final_overtime_label(game)
            footer_status = "FINAL" if overtime == "" else "FINAL " + overtime
            footer_color = "#FF4848"
        else:
            footer_status = "NEXT"
            footer_color = accent
        # Full-size footer text stays under the supporting stats.
        status_width = c.text_width(footer_status, "picopixel")
        status_x = 127 - status_width
        if state == "IN":
            if footer_clock != "":
                clock_x = 127 - c.text_width(footer_clock, "picopixel")
                # Keep the clock anchored at the right edge; preserve the
                # current one-pixel gap before the period label.
                period_x = clock_x - c.text_width(footer_period, "picopixel") - 3
            else:
                # At halftime the clock is stopped, so use its full footprint
                # for the explicit HALFTIME label.
                period_x = 127 - c.text_width(footer_period, "picopixel") - 2
            status_x = period_x
        away_color = readable_team_accent(team if team_first else game.get("opponent", {}), background)
        home_color = readable_team_accent(game.get("opponent", {}) if team_first else team, background)
        away_x = (55 if footer_status == "FINAL" else 47) if state == "POST" else 49
        row_width = c.text_width(away_abbr, "picopixel") + c.text_width(score_numbers, "picopixel") + c.text_width(home_abbr, "picopixel") + 4
        status_left = status_x + 3 if state == "POST" and footer_status != "FINAL" else status_x
        if away_x + row_width + 2 > status_left:
            # Keep a single score line. Shift it only as far left as needed.
            # For the longest codes/scores, raise PTS above the footer rather
            # than stacking score/status rows or clipping school codes.
            away_x = status_left - row_width - 2
        # Leave the approved PTS position and size alone whenever it fits.
        # First try a 3px shift; raise/shrink only if that is insufficient.
        if away_x < 37 + (points_width + 1) // 2 + 2:
            c.rect(24, 10, 51, 31, fill = background)
            tracker_text(c, "PTS", 34, 11, 20, ["picopixel"], accent, "center")
            if away_x >= 34 + (points_width + 1) // 2 + 2:
                tracker_text(c, clean(athlete.get("pts"), "--"), 34, 18, 22, ["scoretext", "6x8", "5x7"], INK, "center")
            else:
                tracker_text(c, clean(athlete.get("pts"), "--"), 34, 16, 20, ["6x8", "5x7", "4x5"], INK, "center")
        c.text(away_abbr, away_x, 26, font = "picopixel", color = away_color)
        score_x = away_x + 1 + c.text_width(away_abbr, "picopixel") + 1
        c.text(score_numbers, score_x, 26, font = "picopixel", color = INK)
        home_x = score_x + c.text_width(score_numbers, "picopixel") + 2
        c.text(home_abbr, home_x, 26, font = "picopixel", color = home_color)
        if state == "IN":
            c.text(footer_period, period_x, 26, font = "picopixel", color = footer_color)
            if footer_clock != "":
                c.text(footer_clock, clock_x, 26, font = "picopixel", color = footer_color)
        elif state == "POST" and footer_status != "FINAL":
            # Use the approved OT2 alignment rule for every overtime label.
            # The complete status remains right-aligned; the suffix gets the
            # same one-pixel gap after FINAL for OT, OT2, OT3, and beyond.
            final_x = status_x + 3
            overtime_x = status_x + c.text_width("FINAL ", "picopixel") + 1
            c.text("FINAL", final_x, 26, font = "picopixel", color = footer_color)
            c.text(overtime, overtime_x, 26, font = "picopixel", color = footer_color)
        elif state == "POST":
            # Regular finals use a simple right-aligned label; the overtime
            # branch above has its own split-label spacing and placement.
            c.text("FINAL", status_x, 26, font = "picopixel", color = footer_color)
        else:
            c.text(footer_status, status_x, 26, font = "picopixel", color = footer_color)

def player_1(c, ctx):
    player_page(c, ctx, 0, False, False, "native")

def player_2(c, ctx):
    player_page(c, ctx, 1, False, False, "native")

def player_3(c, ctx):
    player_page(c, ctx, 2, False, False, "native")

def player_4(c, ctx):
    player_page(c, ctx, 3, False, False, "native")

def player_5(c, ctx):
    player_page(c, ctx, 4, False, False, "native")

def player_6(c, ctx):
    player_page(c, ctx, 5, False, False, "native")

def player_7(c, ctx):
    player_page(c, ctx, 6, False, False, "native")
