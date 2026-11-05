# NCAA Men's Basketball Leaders (192x32)
#
# The top 3 per-game and shooting leaders in one stat per page (Points,
# Rebounds, Assists, Steals, Blocks, FG Pct, 3PT Pct, FT Pct) for NCAA
# Division I men's basketball - all of D-I, or one conference.
# Sibling app to ncaaw-leaders and nba-leaders.
#
# Pages in this SDK are a fixed list declared in the manifest, so all 8
# category pages always exist.
#
# DATA. All of D-I comes from the NCAA's own national rankings
# (ncaa.com, via ncaa-api.henrygd.me) - the official leaders with the
# NCAA's minimums already applied, ranked and tied by the NCAA. ESPN's
# national college list can't stand in: it mixes in non-D-I players with
# one exhibition game. One conference comes from ESPN's stats-by-athlete
# API filtered to that conference, where only D-I teams play, with ESPN's
# qualified flag for the minimums. Both are keyless. The season label
# follows the data: last season's final leaders until the new season's
# first rankings post.
#
# DESIGN. The nba-leaders scorebook, on a black ground. The top row opens
# on a basketball in 9x9 pixel art, then a chip with the conference (D-I
# for the whole division), the stat in white, and "MEN'S" and the season
# in gray. Under it, three rows: the rank in gray, a team badge, the
# player's name in white (initial and last name if the full name won't
# fit), and the number in white against the right edge. The badge is the
# school's ESPN code in its own two colors. Everything stays 6px inside
# both edges so the app reads as its own unit in the stream.

GENDER_PATH = "basketball-men"     # ncaa.com sport path
ESPN_LEAGUE = "mens-college-basketball"
TAG = "MEN'S"                     # beside the season, so a men's and a women's board can't be confused

# Dropdown label: [ESPN conference id, chip label]. "" = all of D-I.
CONFERENCES = {
    "All D-I": ["", "D-I"],
    "ACC": ["2", "ACC"],
    "America East": ["1", "AM EAST"],
    "American": ["62", "AMERICAN"],
    "Atlantic 10": ["3", "A-10"],
    "ASUN": ["46", "ASUN"],
    "Big 12": ["8", "BIG 12"],
    "Big East": ["4", "BIG EAST"],
    "Big Sky": ["5", "BIG SKY"],
    "Big South": ["6", "BIG SOUTH"],
    "Big Ten": ["7", "BIG TEN"],
    "Big West": ["9", "BIG WEST"],
    "CAA": ["10", "CAA"],
    "Conference USA": ["11", "CUSA"],
    "Horizon": ["45", "HORIZON"],
    "Ivy League": ["12", "IVY"],
    "MAAC": ["13", "MAAC"],
    "MAC": ["14", "MAC"],
    "MEAC": ["16", "MEAC"],
    "Missouri Valley": ["18", "MVC"],
    "Mountain West": ["44", "MWC"],
    "NEC": ["19", "NEC"],
    "Ohio Valley": ["20", "OVC"],
    "Pac-12": ["21", "PAC-12"],
    "Patriot": ["22", "PATRIOT"],
    "SEC": ["23", "SEC"],
    "SoCon": ["24", "SOCON"],
    "Southland": ["25", "SOUTHLAND"],
    "SWAC": ["26", "SWAC"],
    "Summit": ["49", "SUMMIT"],
    "Sun Belt": ["27", "SUN BELT"],
    "UAC": ["30", "UAC"],
    "WCC": ["29", "WCC"],
}

# ESPN team id: [code, fill, ink]. Code, fill and ink are ESPN's own
# abbreviation, color and alternateColor; where that pair is too close in
# brightness to read at 4x5 (a gap under 60), the ink is swapped for plain
# white or black, whichever reads on that fill.
TEAMS = {
    2000: ["ACU", "#592D82", "#B1B3B3"],  # Abilene Christian
    2005: ["AF", "#003594", "#FFFFFF"],  # Air Force
    2006: ["AKR", "#041E42", "#C5B783"],  # Akron
    333: ["ALA", "#9E1B32", "#FFFFFF"],  # Alabama
    2010: ["AAMU", "#790000", "#FFFFFF"],  # Alabama A&M
    2011: ["ALST", "#E9A900", "#0A0A0A"],  # Alabama State
    2016: ["ALCN", "#4B0058", "#FFFFFF"],  # Alcorn State
    44: ["AMER", "#C41130", "#FFFFFF"],  # American University
    2026: ["APP", "#000000", "#FFCD00"],  # App State
    12: ["ARIZ", "#CC0033", "#FFFFFF"],  # Arizona
    9: ["ASU", "#FFC627", "#8C1D40"],  # Arizona State
    8: ["ARK", "#A32136", "#FFFFFF"],  # Arkansas
    2032: ["ARST", "#CC092F", "#000000"],  # Arkansas State
    2029: ["UAPB", "#E0AA0F", "#000000"],  # Arkansas-Pine Bluff
    349: ["ARMY", "#000000", "#D3BC8D"],  # Army
    2: ["AUB", "#002B5C", "#F26522"],  # Auburn
    2046: ["APSU", "#8E0B0B", "#FFFFFF"],  # Austin Peay
    252: ["BYU", "#0047BA", "#FFFFFF"],  # BYU
    2050: ["BALL", "#BA0C2F", "#FFFFFF"],  # Ball State
    239: ["BAY", "#154734", "#FFB81C"],  # Baylor
    91: ["BELL", "#000000", "#FFFFFF"],  # Bellarmine
    2057: ["BEL", "#182142", "#FFFFFF"],  # Belmont
    2065: ["BCU", "#7B1831", "#E9AA12"],  # Bethune-Cookman
    2066: ["BING", "#00614A", "#F0F0F0"],  # Binghamton
    68: ["BOIS", "#0033A0", "#FFFFFF"],  # Boise State
    103: ["BC", "#8C2232", "#DBCCA6"],  # Boston College
    104: ["BU", "#CC0000", "#FFFFFF"],  # Boston University
    189: ["BGSU", "#FD5000", "#4F2C1D"],  # Bowling Green
    71: ["BRAD", "#B70002", "#C0C0C0"],  # Bradley
    225: ["BRWN", "#411E09", "#949300"],  # Brown
    2803: ["BRY", "#000000", "#9F8343"],  # Bryant
    2083: ["BUCK", "#000060", "#FFFFFF"],  # Bucknell
    2084: ["BUF", "#005BBB", "#FFFFFF"],  # Buffalo
    2086: ["BTLR", "#0D1361", "#00A3E0"],  # Butler
    13: ["CP", "#1E4D2B", "#EED897"],  # Cal Poly
    2934: ["CSUB", "#003BAB", "#FFFFFF"],  # Cal State Bakersfield
    2239: ["CSUF", "#003767", "#FF8300"],  # Cal State Fullerton
    2463: ["CSUN", "#B50000", "#FFFFFF"],  # Cal State Northridge
    25: ["CAL", "#041E42", "#FFC72C"],  # California
    2856: ["CBU", "#000000", "#FFFFFF"],  # California Baptist
    2097: ["CAM", "#000000", "#FFFFFF"],  # Campbell
    2099: ["CAN", "#004A81", "#DDA50F"],  # Canisius
    2110: ["CARK", "#A7A9AC", "#000000"],  # Central Arkansas
    2115: ["CCSU", "#1B49A2", "#D1D5D8"],  # Central Connecticut
    2117: ["CMU", "#4C0027", "#FBAB18"],  # Central Michigan
    232: ["COFC", "#7A2531", "#9E8959"],  # Charleston
    2127: ["CHSO", "#2E3192", "#DED090"],  # Charleston Southern
    2429: ["CLT", "#005035", "#A49665"],  # Charlotte
    236: ["UTC", "#00386B", "#DCA71D"],  # Chattanooga
    2130: ["CHST", "#006700", "#FFFFFF"],  # Chicago State
    2132: ["CIN", "#000000", "#E00122"],  # Cincinnati
    228: ["CLEM", "#F56600", "#FFFFFF"],  # Clemson
    325: ["CLE", "#006633", "#FFFFFF"],  # Cleveland State
    324: ["CCU", "#006F71", "#FFFFFF"],  # Coastal Carolina
    2142: ["COLG", "#821019", "#FFFFFF"],  # Colgate
    38: ["COLO", "#CFB87C", "#000000"],  # Colorado
    36: ["CSU", "#004C23", "#C8C372"],  # Colorado State
    171: ["COLU", "#7BA4DB", "#183863"],  # Columbia
    2154: ["COPP", "#2E3192", "#FFD204"],  # Coppin State
    172: ["COR", "#B31B1B", "#FFFFFF"],  # Cornell
    156: ["CREI", "#005CA9", "#6CADDE"],  # Creighton
    159: ["DART", "#005730", "#FFFFFF"],  # Dartmouth
    2166: ["DAV", "#000000", "#E51837"],  # Davidson
    2168: ["DAY", "#004B8D", "#FFFFFF"],  # Dayton
    305: ["DEP", "#2D649C", "#FFFFFF"],  # DePaul
    48: ["DEL", "#00539F", "#FFD200"],  # Delaware
    2169: ["DSU", "#009CDB", "#FFFFFF"],  # Delaware State
    2172: ["DEN", "#98002E", "#A8996E"],  # Denver
    2174: ["DETM", "#165B9E", "#FFFFFF"],  # Detroit Mercy
    2181: ["DRKE", "#005596", "#BEC0C2"],  # Drake
    2182: ["DREX", "#020260", "#FFD65A"],  # Drexel
    150: ["DUKE", "#00539B", "#FFFFFF"],  # Duke
    2184: ["DUQ", "#002D62", "#FFFFFF"],  # Duquesne
    151: ["ECU", "#582C83", "#FFC72C"],  # East Carolina
    2193: ["ETSU", "#002D61", "#FFC423"],  # East Tennessee State
    2837: ["ETAM", "#000000", "#FFFFFF"],  # East Texas A&M
    2197: ["EIU", "#000000", "#BEBAB9"],  # Eastern Illinois
    2198: ["EKU", "#660819", "#F0F0F0"],  # Eastern Kentucky
    2199: ["EMU", "#006938", "#FFFFFF"],  # Eastern Michigan
    331: ["EWU", "#A10022", "#ABB4BC"],  # Eastern Washington
    2210: ["ELON", "#020303", "#B59A57"],  # Elon
    339: ["EVAN", "#663399", "#FFFFFF"],  # Evansville
    2217: ["FAIR", "#000000", "#EBEBEB"],  # Fairfield
    161: ["FDU", "#72293C", "#FFFFFF"],  # Fairleigh Dickinson
    57: ["FLA", "#0021A5", "#FA4616"],  # Florida
    50: ["FAMU", "#F89728", "#00843D"],  # Florida A&M
    2226: ["FAU", "#003366", "#FFFFFF"],  # Florida Atlantic
    526: ["FGCU", "#00885A", "#FFFFFF"],  # Florida Gulf Coast
    2229: ["FIU", "#091F3F", "#C3993F"],  # Florida International
    52: ["FSU", "#782F40", "#CEB888"],  # Florida State
    2230: ["FOR", "#830032", "#909090"],  # Fordham
    278: ["FRES", "#B1102B", "#FFFFFF"],  # Fresno State
    231: ["FUR", "#582C83", "#FFFFFF"],  # Furman
    2241: ["GWEB", "#C12535", "#FFFFFF"],  # Gardner-Webb
    2244: ["GMU", "#016600", "#ECB010"],  # George Mason
    45: ["GW", "#002843", "#E8D2A1"],  # George Washington
    46: ["GTWN", "#110E42", "#FFFFFF"],  # Georgetown
    61: ["UGA", "#BA0C2F", "#FFFFFF"],  # Georgia
    290: ["GASO", "#041E42", "#A3AAAE"],  # Georgia Southern
    2247: ["GAST", "#0039A6", "#FFFFFF"],  # Georgia State
    59: ["GT", "#B3A369", "#FFFFFF"],  # Georgia Tech
    2250: ["GONZ", "#041E42", "#FFFFFF"],  # Gonzaga
    2755: ["GRAM", "#EE8601", "#000000"],  # Grambling
    2253: ["GCU", "#522398", "#FFFFFF"],  # Grand Canyon
    2739: ["GB", "#006633", "#FFFFFF"],  # Green Bay
    2261: ["HAMP", "#0067AC", "#FFFFFF"],  # Hampton
    108: ["HARV", "#990000", "#DBDBDB"],  # Harvard
    62: ["HAW", "#005737", "#FFFFFF"],  # Hawai'i
    2272: ["HPU", "#330072", "#FFFFFF"],  # High Point
    2275: ["HOF", "#003594", "#FFC72C"],  # Hofstra
    107: ["HC", "#582C83", "#FFFFFF"],  # Holy Cross
    248: ["HOU", "#C8102E", "#FFFFFF"],  # Houston
    2277: ["HCU", "#00539C", "#FFFFFF"],  # Houston Christian
    47: ["HOW", "#003A63", "#FFFFFF"],  # Howard
    85: ["IUIN", "#A81F30", "#D59F0F"],  # IU Indianapolis
    70: ["IDHO", "#000000", "#8C6E4A"],  # Idaho
    304: ["IDST", "#EF8C00", "#000000"],  # Idaho State
    356: ["ILL", "#FF5F05", "#13294B"],  # Illinois
    2287: ["ILST", "#CE1126", "#FFE716"],  # Illinois State
    2916: ["UIW", "#000000", "#FFFFFF"],  # Incarnate Word
    84: ["IU", "#970310", "#FFFFFF"],  # Indiana
    282: ["INST", "#00669A", "#F0F0F0"],  # Indiana State
    314: ["IONA", "#6F2C3E", "#F0AB00"],  # Iona
    2294: ["IOWA", "#231F20", "#FCD116"],  # Iowa
    66: ["ISU", "#AE192D", "#FFC72A"],  # Iowa State
    2296: ["JKST", "#123297", "#B5B7BA"],  # Jackson State
    294: ["JAX", "#00523E", "#FFFFFF"],  # Jacksonville
    55: ["JXST", "#CC0000", "#000000"],  # Jacksonville State
    256: ["JMU", "#450084", "#CBB677"],  # James Madison
    2305: ["KU", "#0051BA", "#FFFFFF"],  # Kansas
    140: ["KC", "#004B87", "#FFC72C"],  # Kansas City
    2306: ["KSU", "#330A57", "#E2E3E4"],  # Kansas State
    338: ["KENN", "#FDBB30", "#0B1315"],  # Kennesaw State
    2309: ["KENT", "#002664", "#EAAB00"],  # Kent State
    96: ["UK", "#0033A0", "#FFFFFF"],  # Kentucky
    99: ["LSU", "#461D76", "#FDD023"],  # LSU
    2443: ["NOLA", "#461D7C", "#FDD023"],  # LSU New Orleans
    2325: ["LAS", "#003356", "#FFCE00"],  # La Salle
    322: ["LAF", "#790000", "#A59474"],  # Lafayette
    2320: ["LAM", "#000000", "#EBEBEB"],  # Lamar
    2330: ["LEM", "#000000", "#FFFFFF"],  # Le Moyne
    2329: ["LEH", "#6C2B2A", "#B69E70"],  # Lehigh
    2335: ["LIB", "#0A254E", "#FFFFFF"],  # Liberty
    2815: ["LIN", "#000000", "#FFFFFF"],  # Lindenwood
    288: ["LIP", "#20366C", "#F6B734"],  # Lipscomb
    2031: ["LR", "#AD0000", "#898D8F"],  # Little Rock
    299: ["LBSU", "#000000", "#F1F2F3"],  # Long Beach State
    112358: ["LIU", "#50C9F7", "#000000"],  # Long Island University
    2344: ["LONG", "#003273", "#9EA2A3"],  # Longwood
    309: ["UL", "#CE181E", "#000000"],  # Louisiana
    2348: ["LT", "#003087", "#FFFFFF"],  # Louisiana Tech
    97: ["LOU", "#C9001F", "#FFFFFF"],  # Louisville
    2350: ["LUC", "#9D1244", "#FFFFFF"],  # Loyola Chicago
    2352: ["L-MD", "#76A7A0", "#000000"],  # Loyola Maryland
    2351: ["LMU", "#880029", "#FFFFFF"],  # Loyola Marymount
    311: ["ME", "#127DBE", "#FFFFFF"],  # Maine
    2363: ["MAN", "#4F8537", "#B5B7BA"],  # Manhattan
    2368: ["MRST", "#E53730", "#F0F0F0"],  # Marist
    269: ["MARQ", "#003366", "#FFCC00"],  # Marquette
    276: ["MRSH", "#00B140", "#000000"],  # Marshall
    120: ["MD", "#CE1126", "#FFFFFF"],  # Maryland
    2379: ["UMES", "#5C2301", "#B5B7BA"],  # Maryland Eastern Shore
    113: ["MASS", "#881C1C", "#FFFFFF"],  # Massachusetts
    2377: ["MCN", "#00529C", "#FFD204"],  # McNeese
    235: ["MEM", "#004991", "#8E908F"],  # Memphis
    2382: ["MER", "#FF7F29", "#080808"],  # Mercer
    2385: ["MERC", "#000000", "#FFFFFF"],  # Mercyhurst
    2771: ["MRMK", "#2F4F93", "#E8C535"],  # Merrimack
    2390: ["MIA", "#F47423", "#035131"],  # Miami
    193: ["M-OH", "#C41230", "#FFFFFF"],  # Miami (OH)
    130: ["MICH", "#00274C", "#FFCB05"],  # Michigan
    127: ["MSU", "#173F35", "#FFFFFF"],  # Michigan State
    2393: ["MTSU", "#036EB7", "#FFFFFF"],  # Middle Tennessee
    270: ["MILW", "#000000", "#FFC20E"],  # Milwaukee
    135: ["MINN", "#5E0A2F", "#FAB41C"],  # Minnesota
    344: ["MSST", "#5D1725", "#C1C6C8"],  # Mississippi State
    2400: ["MVSU", "#005328", "#FFFFFF"],  # Mississippi Valley State
    142: ["MIZ", "#F1B82D", "#000000"],  # Missouri
    2623: ["MOST", "#5E0009", "#FFFFFF"],  # Missouri State
    2405: ["MONM", "#051844", "#FFFFFF"],  # Monmouth
    149: ["MONT", "#751D4A", "#FFFFFF"],  # Montana
    147: ["MTST", "#00205C", "#BC955C"],  # Montana State
    2413: ["MORE", "#094FA3", "#FED91A"],  # Morehead State
    2415: ["MORG", "#014786", "#F47937"],  # Morgan State
    116: ["MSM", "#005596", "#EBEBEB"],  # Mount St. Mary's
    93: ["MUR", "#002148", "#FFFFFF"],  # Murray State
    152: ["NCSU", "#CC0000", "#FFFFFF"],  # NC State
    2885: ["NJIT", "#EE3024", "#FFFFFF"],  # NJIT
    2426: ["NAVY", "#00225B", "#B5A67C"],  # Navy
    158: ["NEB", "#E31937", "#FFFFFF"],  # Nebraska
    2440: ["NEV", "#041E42", "#8A8D8F"],  # Nevada
    160: ["UNH", "#004990", "#C3C4C6"],  # New Hampshire
    2441: ["NHVN", "#041E42", "#FFC425"],  # New Haven
    167: ["UNM", "#BA0C2F", "#A7A8AA"],  # New Mexico
    166: ["NMSU", "#7E141B", "#FFFFFF"],  # New Mexico State
    315: ["NIA", "#69207E", "#F0F0F0"],  # Niagara
    2447: ["NICH", "#C41230", "#F0F0F0"],  # Nicholls
    2450: ["NORF", "#0C8968", "#FDB813"],  # Norfolk State
    2453: ["UNA", "#000000", "#FFFFFF"],  # North Alabama
    153: ["UNC", "#7BAFD4", "#13294B"],  # North Carolina
    2448: ["NCAT", "#0505AA", "#FFFFFF"],  # North Carolina A&T
    2428: ["NCCU", "#880023", "#C2C3C0"],  # North Carolina Central
    155: ["UND", "#00A26B", "#C2C3C0"],  # North Dakota
    2449: ["NDSU", "#01402A", "#FFFFFF"],  # North Dakota State
    2454: ["UNF", "#004B8D", "#BABCBE"],  # North Florida
    249: ["UNT", "#068F33", "#FFFFFF"],  # North Texas
    111: ["NE", "#CC0001", "#C2C3C0"],  # Northeastern
    2464: ["NAU", "#003976", "#FFFFFF"],  # Northern Arizona
    2458: ["UNCO", "#13558D", "#FFC533"],  # Northern Colorado
    2459: ["NIU", "#C8102E", "#000000"],  # Northern Illinois
    2460: ["UNI", "#473282", "#FFFFFF"],  # Northern Iowa
    94: ["NKU", "#FFC82E", "#000000"],  # Northern Kentucky
    77: ["NU", "#492F92", "#FFFFFF"],  # Northwestern
    2466: ["NWST", "#492F91", "#ED6118"],  # Northwestern State
    87: ["ND", "#062340", "#C99700"],  # Notre Dame
    2473: ["OAK", "#04091C", "#BC955C"],  # Oakland
    195: ["OHIO", "#154734", "#FFFFFF"],  # Ohio
    194: ["OSU", "#BA0C2F", "#A8ADB4"],  # Ohio State
    201: ["OU", "#990000", "#FFFFFF"],  # Oklahoma
    197: ["OKST", "#FE5C00", "#000000"],  # Oklahoma State
    295: ["ODU", "#003768", "#A1D2F1"],  # Old Dominion
    145: ["MISS", "#13294B", "#FFFFFF"],  # Ole Miss
    2437: ["OMA", "#E3193E", "#FFFFFF"],  # Omaha
    198: ["ORU", "#002462", "#DAC792"],  # Oral Roberts
    2483: ["ORE", "#00934B", "#FFF41B"],  # Oregon
    204: ["ORST", "#DC4405", "#000000"],  # Oregon State
    279: ["PAC", "#F47820", "#000000"],  # Pacific
    213: ["PSU", "#061440", "#FFFFFF"],  # Penn State
    219: ["PENN", "#082A74", "#FFFFFF"],  # Pennsylvania
    2492: ["PEPP", "#003A72", "#DC762F"],  # Pepperdine
    221: ["PITT", "#003594", "#FFB81C"],  # Pittsburgh
    2501: ["PORT", "#330072", "#A8B3BA"],  # Portland
    2502: ["PRST", "#00311E", "#EBEBEB"],  # Portland State
    2504: ["PV", "#582C83", "#EAAA00"],  # Prairie View A&M
    2506: ["PRES", "#194896", "#FFFFFF"],  # Presbyterian
    163: ["PRIN", "#000000", "#FF6000"],  # Princeton
    2507: ["PROV", "#000000", "#A3A19E"],  # Providence
    2509: ["PUR", "#CEB888", "#000000"],  # Purdue
    2870: ["PFW", "#CFB991", "#000000"],  # Purdue Fort Wayne
    2511: ["QUC", "#192C66", "#857040"],  # Queens University
    2514: ["QUIN", "#041B43", "#FFFFFF"],  # Quinnipiac
    2515: ["RAD", "#BC1515", "#C2C3C0"],  # Radford
    227: ["URI", "#091F3F", "#5AB3E8"],  # Rhode Island
    242: ["RICE", "#00205B", "#C1C6C8"],  # Rice
    257: ["RICH", "#9E0712", "#FFFFFF"],  # Richmond
    2520: ["RID", "#A80532", "#EBEBEB"],  # Rider
    2523: ["RMU", "#00214D", "#FFFFFF"],  # Robert Morris
    164: ["RUTG", "#CE0E2D", "#FFFFFF"],  # Rutgers
    2545: ["SELA", "#215732", "#FFC72C"],  # SE Louisiana
    2565: ["SIUE", "#EB1C23", "#080808"],  # SIU Edwardsville
    2567: ["SMU", "#A80000", "#FFFFFF"],  # SMU
    16: ["SAC", "#00573C", "#CDB97D"],  # Sacramento State
    2529: ["SHU", "#A40012", "#C29472"],  # Sacred Heart
    2603: ["JOES", "#9E1B32", "#FFFFFF"],  # Saint Joseph's
    139: ["SLU", "#00539C", "#EBEBEB"],  # Saint Louis
    2608: ["SMC", "#D80024", "#FFFFFF"],  # Saint Mary's
    2612: ["SPU", "#004CC2", "#FFFFFF"],  # Saint Peter's
    2534: ["SHSU", "#F56423", "#FFFFFF"],  # Sam Houston
    2535: ["SAM", "#005485", "#FFFFFF"],  # Samford
    301: ["USD", "#2F99D4", "#FFFFFF"],  # San Diego
    21: ["SDSU", "#A6192E", "#000000"],  # San Diego State
    2539: ["SF", "#005A36", "#FFFFFF"],  # San Francisco
    23: ["SJSU", "#0038A8", "#FFB81A"],  # San José State
    2541: ["SCU", "#690B0B", "#FFFFFF"],  # Santa Clara
    2547: ["SEA", "#BF2E1A", "#C2C3C0"],  # Seattle U
    2550: ["HALL", "#0857B1", "#8A8D8F"],  # Seton Hall
    2561: ["SIE", "#037961", "#EEA60F"],  # Siena
    6: ["USA", "#00205B", "#FFFFFF"],  # South Alabama
    2579: ["SC", "#73000A", "#FFFFFF"],  # South Carolina
    2569: ["SCST", "#7D1315", "#FFFFFF"],  # South Carolina State
    2908: ["UPST", "#008545", "#000000"],  # South Carolina Upstate
    233: ["SDAK", "#CD1241", "#F0F0F0"],  # South Dakota
    2571: ["SDST", "#0033A0", "#FFD100"],  # South Dakota State
    58: ["USF", "#006747", "#CFC493"],  # South Florida
    2546: ["SEMO", "#C8102E", "#000000"],  # Southeast Missouri State
    2582: ["SOU", "#004B97", "#FFC82D"],  # Southern
    79: ["SIU", "#85283D", "#C2C3C0"],  # Southern Illinois
    88: ["USI", "#000000", "#FFFFFF"],  # Southern Indiana
    2572: ["USM", "#FFC72C", "#231F20"],  # Southern Miss
    253: ["SUU", "#C72026", "#000000"],  # Southern Utah
    179: ["SBU", "#70261D", "#FFFFFF"],  # St. Bonaventure
    2599: ["SJU", "#D10000", "#FFFFFF"],  # St. John's
    2900: ["STMN", "#000000", "#FFFFFF"],  # St. Thomas
    24: ["STAN", "#8C1515", "#FFFFFF"],  # Stanford
    2617: ["SFA", "#393996", "#BEC0C2"],  # Stephen F. Austin
    56: ["STET", "#0A5640", "#FFFFFF"],  # Stetson
    284: ["STO", "#000000", "#FFFFFF"],  # Stonehill
    2619: ["STBK", "#990000", "#FFFFFF"],  # Stony Brook
    183: ["SYR", "#000E54", "#FF431B"],  # Syracuse
    2628: ["TCU", "#4D1979", "#FFFFFF"],  # TCU
    2627: ["TAR", "#000000", "#FFFFFF"],  # Tarleton State
    218: ["TEM", "#A41E35", "#FFFFFF"],  # Temple
    2633: ["TENN", "#FF8200", "#FFFFFF"],  # Tennessee
    2634: ["TNST", "#171796", "#F0F0F0"],  # Tennessee State
    2635: ["TNTC", "#5A4099", "#FFDE00"],  # Tennessee Tech
    251: ["TEX", "#AF5C37", "#FFFFFF"],  # Texas
    245: ["TA&M", "#500000", "#FFFFFF"],  # Texas A&M
    357: ["AMCC", "#0067C5", "#FFFFFF"],  # Texas A&M-Corpus Christi
    2640: ["TXSO", "#860038", "#FFFFFF"],  # Texas Southern
    326: ["TXST", "#501214", "#FFFFFF"],  # Texas State
    2641: ["TTU", "#DA291C", "#000000"],  # Texas Tech
    2643: ["CIT", "#7BADD3", "#002856"],  # The Citadel
    2649: ["TOL", "#0B2240", "#FFCD00"],  # Toledo
    119: ["TOW", "#FFC229", "#FFFFFF"],  # Towson
    2653: ["TROY", "#862633", "#B1B1B1"],  # Troy
    2655: ["TULN", "#006747", "#418FDE"],  # Tulane
    202: ["TLSA", "#003595", "#D0B787"],  # Tulsa
    5: ["UAB", "#1A5632", "#FDB913"],  # UAB
    399: ["UALB", "#3D2777", "#FFFFFF"],  # UAlbany
    302: ["UCD", "#002855", "#C3C4C6"],  # UC Davis
    300: ["UCI", "#002B5C", "#FEC52E"],  # UC Irvine
    27: ["UCR", "#14234F", "#FFFFFF"],  # UC Riverside
    28: ["UCSD", "#000000", "#FFCD00"],  # UC San Diego
    2540: ["UCSB", "#1E1840", "#FEBC11"],  # UC Santa Barbara
    2116: ["UCF", "#000000", "#B4A169"],  # UCF
    26: ["UCLA", "#2774AE", "#F2A900"],  # UCLA
    41: ["CONN", "#0C2340", "#A2AAAD"],  # UConn
    82: ["UIC", "#001E62", "#FFFFFF"],  # UIC
    2433: ["ULM", "#840029", "#FDB913"],  # UL Monroe
    2378: ["UMBC", "#000000", "#AD860A"],  # UMBC
    2349: ["UML", "#000000", "#CF1F2F"],  # UMass Lowell
    2427: ["UNCA", "#003DA5", "#FFFFFF"],  # UNC Asheville
    2430: ["UNCG", "#003559", "#FFD90A"],  # UNC Greensboro
    350: ["UNCW", "#00665E", "#FFDA00"],  # UNC Wilmington
    2439: ["UNLV", "#CF0A2C", "#CAC8C8"],  # UNLV
    30: ["USC", "#9D2235", "#FFC72C"],  # USC
    250: ["UTA", "#004B7C", "#F58024"],  # UT Arlington
    2630: ["UTM", "#FF6700", "#102A5C"],  # UT Martin
    292: ["RGV", "#DC6000", "#FFFFFF"],  # UT Rio Grande Valley
    2638: ["UTEP", "#FF8200", "#041E42"],  # UTEP
    2636: ["UTSA", "#0C2340", "#F15A22"],  # UTSA
    254: ["UTAH", "#BE0000", "#FFFFFF"],  # Utah
    328: ["USU", "#0F2439", "#FFFFFF"],  # Utah State
    3101: ["UTU", "#000000", "#FFFFFF"],  # Utah Tech
    3084: ["UVU", "#004812", "#E1C736"],  # Utah Valley
    2670: ["VCU", "#FFAF00", "#000000"],  # VCU
    2678: ["VMI", "#AE122A", "#000000"],  # VMI
    2674: ["VAL", "#794500", "#FFFFFF"],  # Valparaiso
    238: ["VAN", "#000000", "#CFAE70"],  # Vanderbilt
    261: ["UVM", "#154734", "#FFC72C"],  # Vermont
    222: ["VILL", "#00205B", "#13B5EA"],  # Villanova
    258: ["UVA", "#232D4B", "#F84C1E"],  # Virginia
    259: ["VT", "#6A2C3E", "#FFFFFF"],  # Virginia Tech
    2681: ["WAG", "#00483A", "#FFFFFF"],  # Wagner
    154: ["WAKE", "#CEB888", "#2C2A29"],  # Wake Forest
    264: ["WASH", "#33006F", "#E8D3A2"],  # Washington
    265: ["WSU", "#A60F2D", "#FFFFFF"],  # Washington State
    2692: ["WEB", "#18005A", "#EBEBEB"],  # Weber State
    2697: ["UWF", "#087DC2", "#FFFFFF"],  # West Florida
    2698: ["WGA", "#0033A1", "#FFFFFF"],  # West Georgia
    277: ["WVU", "#EAAA00", "#002855"],  # West Virginia
    2717: ["WCU", "#492F91", "#BF9E70"],  # Western Carolina
    2710: ["WIU", "#4E1E8A", "#FFC90A"],  # Western Illinois
    98: ["WKU", "#E13A3E", "#FFFFFF"],  # Western Kentucky
    2711: ["WMU", "#532E1F", "#F1C500"],  # Western Michigan
    2724: ["WICH", "#FFCD00", "#27251F"],  # Wichita State
    2729: ["W&M", "#115740", "#F0B323"],  # William & Mary
    2737: ["WIN", "#9E0B0E", "#FDB41E"],  # Winthrop
    275: ["WIS", "#A00000", "#FFFFFF"],  # Wisconsin
    2747: ["WOF", "#533B24", "#F0F0F0"],  # Wofford
    2750: ["WRST", "#CBA052", "#000000"],  # Wright State
    2751: ["WYO", "#492F24", "#FFC425"],  # Wyoming
    2752: ["XAV", "#21304E", "#A5A7A8"],  # Xavier
    43: ["YALE", "#004A81", "#FFFFFF"],  # Yale
    2754: ["YSU", "#E51937", "#FFFFFF"],  # Youngstown State
}

# The NCAA's school names (as its rankings print them) -> ESPN team id,
# so the national boards get the same badges as the conference ones.
NCAA_TEAMS = {
    "A&M-Corpus Christi": 357,
    "Abilene Christian": 2000,
    "Air Force": 2005,
    "Akron": 2006,
    "Alabama": 333,
    "Alabama A&M": 2010,
    "Alabama St.": 2011,
    "Alcorn": 2016,
    "American": 44,
    "App State": 2026,
    "Arizona": 12,
    "Arizona St.": 9,
    "Ark.-Pine Bluff": 2029,
    "Arkansas": 8,
    "Arkansas St.": 2032,
    "Army West Point": 349,
    "Auburn": 2,
    "Austin Peay": 2046,
    "BYU": 252,
    "Ball St.": 2050,
    "Baylor": 239,
    "Bellarmine": 91,
    "Belmont": 2057,
    "Bethune-Cookman": 2065,
    "Binghamton": 2066,
    "Boise St.": 68,
    "Boston College": 103,
    "Boston U.": 104,
    "Bowling Green": 189,
    "Bradley": 71,
    "Brown": 225,
    "Bryant": 2803,
    "Bucknell": 2083,
    "Buffalo": 2084,
    "Butler": 2086,
    "CSU Bakersfield": 2934,
    "CSUN": 2463,
    "Cal Poly": 13,
    "Cal St. Fullerton": 2239,
    "California": 25,
    "California Baptist": 2856,
    "Campbell": 2097,
    "Canisius": 2099,
    "Central Ark.": 2110,
    "Central Conn. St.": 2115,
    "Central Mich.": 2117,
    "Charleston So.": 2127,
    "Charlotte": 2429,
    "Chattanooga": 236,
    "Chicago St.": 2130,
    "Cincinnati": 2132,
    "Clemson": 228,
    "Cleveland St.": 325,
    "Coastal Carolina": 324,
    "Col. of Charleston": 232,
    "Colgate": 2142,
    "Colorado": 38,
    "Colorado St.": 36,
    "Columbia": 171,
    "Coppin St.": 2154,
    "Cornell": 172,
    "Creighton": 156,
    "Dartmouth": 159,
    "Davidson": 2166,
    "Dayton": 2168,
    "DePaul": 305,
    "Delaware": 48,
    "Delaware St.": 2169,
    "Denver": 2172,
    "Detroit Mercy": 2174,
    "Drake": 2181,
    "Drexel": 2182,
    "Duke": 150,
    "Duquesne": 2184,
    "ETSU": 2193,
    "East Carolina": 151,
    "East Texas A&M": 2837,
    "Eastern Ill.": 2197,
    "Eastern Ky.": 2198,
    "Eastern Mich.": 2199,
    "Eastern Wash.": 331,
    "Elon": 2210,
    "Evansville": 339,
    "FDU": 161,
    "FGCU": 526,
    "FIU": 2229,
    "Fairfield": 2217,
    "Fla. Atlantic": 2226,
    "Florida": 57,
    "Florida A&M": 50,
    "Florida St.": 52,
    "Fordham": 2230,
    "Fresno St.": 278,
    "Furman": 231,
    "Ga. Southern": 290,
    "Gardner-Webb": 2241,
    "George Mason": 2244,
    "George Washington": 45,
    "Georgetown": 46,
    "Georgia": 61,
    "Georgia St.": 2247,
    "Georgia Tech": 59,
    "Gonzaga": 2250,
    "Grambling": 2755,
    "Grand Canyon": 2253,
    "Green Bay": 2739,
    "Hampton": 2261,
    "Harvard": 108,
    "Hawaii": 62,
    "High Point": 2272,
    "Hofstra": 2275,
    "Holy Cross": 107,
    "Houston": 248,
    "Houston Christian": 2277,
    "Howard": 47,
    "IU Indy": 85,
    "Idaho": 70,
    "Idaho St.": 304,
    "Illinois": 356,
    "Illinois St.": 2287,
    "Indiana": 84,
    "Indiana St.": 282,
    "Iona": 314,
    "Iowa": 2294,
    "Iowa St.": 66,
    "Jackson St.": 2296,
    "Jacksonville": 294,
    "Jacksonville St.": 55,
    "James Madison": 256,
    "Kansas": 2305,
    "Kansas City": 140,
    "Kansas St.": 2306,
    "Kennesaw St.": 338,
    "Kent St.": 2309,
    "Kentucky": 96,
    "LIU": 112358,
    "LMU (CA)": 2351,
    "LSU": 99,
    "LSU New Orleans": 2443,
    "La Salle": 2325,
    "Lafayette": 322,
    "Lamar University": 2320,
    "Le Moyne": 2330,
    "Lehigh": 2329,
    "Liberty": 2335,
    "Lindenwood": 2815,
    "Lipscomb": 288,
    "Little Rock": 2031,
    "Long Beach St.": 299,
    "Longwood": 2344,
    "Louisiana": 309,
    "Louisiana Tech": 2348,
    "Louisville": 97,
    "Loyola Chicago": 2350,
    "Loyola Maryland": 2352,
    "Maine": 311,
    "Manhattan": 2363,
    "Marist": 2368,
    "Marquette": 269,
    "Marshall": 276,
    "Maryland": 120,
    "Massachusetts": 113,
    "McNeese": 2377,
    "Memphis": 235,
    "Mercer": 2382,
    "Mercyhurst": 2385,
    "Merrimack": 2771,
    "Miami (FL)": 2390,
    "Miami (OH)": 193,
    "Michigan": 130,
    "Michigan St.": 127,
    "Middle Tenn.": 2393,
    "Milwaukee": 270,
    "Minnesota": 135,
    "Mississippi St.": 344,
    "Mississippi Val.": 2400,
    "Missouri": 142,
    "Missouri St.": 2623,
    "Monmouth": 2405,
    "Montana": 149,
    "Montana St.": 147,
    "Morehead St.": 2413,
    "Morgan St.": 2415,
    "Mount St. Mary's": 116,
    "Murray St.": 93,
    "N.C. A&T": 2448,
    "N.C. Central": 2428,
    "NC State": 152,
    "NIU": 2459,
    "NJIT": 2885,
    "Navy": 2426,
    "Nebraska": 158,
    "Nevada": 2440,
    "New Hampshire": 160,
    "New Haven": 2441,
    "New Mexico": 167,
    "New Mexico St.": 166,
    "Niagara": 315,
    "Nicholls": 2447,
    "Norfolk St.": 2450,
    "North Ala.": 2453,
    "North Carolina": 153,
    "North Dakota": 155,
    "North Dakota St.": 2449,
    "North Florida": 2454,
    "North Texas": 249,
    "Northeastern": 111,
    "Northern Ariz.": 2464,
    "Northern Colo.": 2458,
    "Northern Ky.": 94,
    "Northwestern": 77,
    "Northwestern St.": 2466,
    "Notre Dame": 87,
    "Oakland": 2473,
    "Ohio": 195,
    "Ohio St.": 194,
    "Oklahoma": 201,
    "Oklahoma St.": 197,
    "Old Dominion": 295,
    "Ole Miss": 145,
    "Omaha": 2437,
    "Oral Roberts": 198,
    "Oregon": 2483,
    "Oregon St.": 204,
    "Pacific": 279,
    "Penn": 219,
    "Penn St.": 213,
    "Pepperdine": 2492,
    "Pittsburgh": 221,
    "Portland": 2501,
    "Portland St.": 2502,
    "Prairie View": 2504,
    "Presbyterian": 2506,
    "Princeton": 163,
    "Providence": 2507,
    "Purdue": 2509,
    "Purdue Fort Wayne": 2870,
    "Queens (NC)": 2511,
    "Quinnipiac": 2514,
    "Radford": 2515,
    "Rhode Island": 227,
    "Rice": 242,
    "Richmond": 257,
    "Rider": 2520,
    "Robert Morris": 2523,
    "Rutgers": 164,
    "SFA": 2617,
    "SIUE": 2565,
    "SMU": 2567,
    "Sacramento St.": 16,
    "Sacred Heart": 2529,
    "Saint Joseph's": 2603,
    "Saint Louis": 139,
    "Saint Mary's (CA)": 2608,
    "Saint Peter's": 2612,
    "Sam Houston": 2534,
    "Samford": 2535,
    "San Diego": 301,
    "San Diego St.": 21,
    "San Francisco": 2539,
    "San Jose St.": 23,
    "Santa Clara": 2541,
    "Seattle U": 2547,
    "Seton Hall": 2550,
    "Siena": 2561,
    "South Alabama": 6,
    "South Carolina": 2579,
    "South Carolina St.": 2569,
    "South Dakota": 233,
    "South Dakota St.": 2571,
    "South Fla.": 58,
    "Southeast Mo. St.": 2546,
    "Southeastern La.": 2545,
    "Southern California": 30,
    "Southern Ill.": 79,
    "Southern Ind.": 88,
    "Southern Miss.": 2572,
    "Southern U.": 2582,
    "Southern Utah": 253,
    "St. Bonaventure": 179,
    "St. John's (NY)": 2599,
    "St. Thomas (MN)": 2900,
    "Stanford": 24,
    "Stetson": 56,
    "Stonehill": 284,
    "Stony Brook": 2619,
    "Syracuse": 183,
    "TCU": 2628,
    "Tarleton St.": 2627,
    "Temple": 218,
    "Tennessee": 2633,
    "Tennessee St.": 2634,
    "Tennessee Tech": 2635,
    "Texas": 251,
    "Texas A&M": 245,
    "Texas Southern": 2640,
    "Texas St.": 326,
    "Texas Tech": 2641,
    "The Citadel": 2643,
    "Toledo": 2649,
    "Towson": 119,
    "Troy": 2653,
    "Tulane": 2655,
    "Tulsa": 202,
    "UAB": 5,
    "UAlbany": 399,
    "UC Davis": 302,
    "UC Irvine": 300,
    "UC Riverside": 27,
    "UC San Diego": 28,
    "UC Santa Barbara": 2540,
    "UCF": 2116,
    "UCLA": 26,
    "UConn": 41,
    "UIC": 82,
    "UIW": 2916,
    "ULM": 2433,
    "UMBC": 2378,
    "UMES": 2379,
    "UMass Lowell": 2349,
    "UNC Asheville": 2427,
    "UNC Greensboro": 2430,
    "UNCW": 350,
    "UNI": 2460,
    "UNLV": 2439,
    "USC Upstate": 2908,
    "UT Arlington": 250,
    "UT Martin": 2630,
    "UTEP": 2638,
    "UTRGV": 292,
    "UTSA": 2636,
    "Utah": 254,
    "Utah St.": 328,
    "Utah Tech": 3101,
    "Utah Valley": 3084,
    "VCU": 2670,
    "VMI": 2678,
    "Valparaiso": 2674,
    "Vanderbilt": 238,
    "Vermont": 261,
    "Villanova": 222,
    "Virginia": 258,
    "Virginia Tech": 259,
    "Wagner": 2681,
    "Wake Forest": 154,
    "Washington": 264,
    "Washington St.": 265,
    "Weber St.": 2692,
    "West Fla.": 2697,
    "West Ga.": 2698,
    "West Virginia": 277,
    "Western Caro.": 2717,
    "Western Ill.": 2710,
    "Western Ky.": 98,
    "Western Mich.": 2711,
    "Wichita St.": 2724,
    "William & Mary": 2729,
    "Winthrop": 2737,
    "Wisconsin": 275,
    "Wofford": 2747,
    "Wright St.": 2750,
    "Wyoming": 2751,
    "Xavier": 2752,
    "Yale": 43,
    "Youngstown St.": 2754,
}

# ---------- palette & grid ----------

INK = "#F4F7FF"      # names, live numbers, the stat title
DIM = "#6E7A94"      # ranks, season, sub-lines
AMBER = "#E8B04A"    # the one attention state (feed offline)
CHIP = "#2A66D9"
BALL = "#F26A1B"

PAD = 6              # scroll safe zone, both edges
RANK_W = 5           # one 5x7 digit
BADGE_X = PAD + RANK_W + 2  # 13
BADGE_H = 7
NAME_GAP = 2
GAP = 4              # blank px between a name and its value
ROW_Y = [9, 17, 25]  # three 7px rows, 1px apart, under the 8px header row
HEAD_Y = 2           # 4x5 header text, centered on the ball

# A basketball at 9x9: the center lines and two side seams in black, so on
# the LED they read as the ball's dark grooves. Its last row sits in the
# 1px gap above the first leader row.
LOGO = """
...OOO...
.OKOKOKO.
.KOOKOOK.
OKOOKOOKO
KKKKKKKKK
OKOOKOOKO
.KOOKOOK.
.OKOKOKO.
...OOO...
"""
LOGO_W = 9
LOGO_LEGEND = {"O": BALL, "K": "#000000"}

# Names get one font per page, not per row: a long name in 4x7 beside a
# short one in 5x7 reads as a mistake. 5x7 when every name on the page
# fits, else 4x7, then a hard clip.
NAME_FONTS = ["5x7", "4x7"]
VALUE_FONT = "5x7"

# ---------- name normalization ----------
# The bitmap fonts only cover plain ASCII - an accented letter renders as a
# stray symbol otherwise, so strip to the closest ASCII letter first.
ACCENT_MAP = {
    "Á": "A", "À": "A", "Â": "A", "Ä": "A", "Ã": "A", "Å": "A",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O", "Õ": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
    "Ñ": "N", "Ç": "C", "Ý": "Y",
    "á": "a", "à": "a", "â": "a", "ä": "a", "ã": "a", "å": "a",
    "é": "e", "è": "e", "ê": "e", "ë": "e",
    "í": "i", "ì": "i", "î": "i", "ï": "i",
    "ó": "o", "ò": "o", "ô": "o", "ö": "o", "õ": "o",
    "ú": "u", "ù": "u", "û": "u", "ü": "u",
    "ñ": "n", "ç": "c", "ý": "y",
    "Č": "C", "č": "c", "Ć": "C", "ć": "c", "Š": "S", "š": "s",
    "Ž": "Z", "ž": "z", "Đ": "D", "đ": "d",
}

def strip_accents(s):
    out = ""
    for i in range(len(s)):
        ch = s[i]
        out += ACCENT_MAP.get(ch, ch)
    return out

# ---------- color helpers ----------

HEX = "0123456789ABCDEF"

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def blend(a, b, pct):
    # pct% of a over b
    out = "#"
    for i in [1, 3, 5]:
        v = (int(a[i:i + 2], 16) * pct + int(b[i:i + 2], 16) * (100 - pct)) // 100
        out += HEX[v // 16] + HEX[v % 16]
    return out

# ---------- network (keyless) ----------

NCAA_API = "https://ncaa-api.henrygd.me/stats/" + GENDER_PATH + "/d1/current/individual/"
ESPN_API = "https://site.web.api.espn.com/apis/common/v3/sports/basketball/" + ESPN_LEAGUE + "/statistics/byathlete"
TTL = 10800          # matches manifest.yaml's refresh - keep in sync
MONTHS = ["January", "February", "March", "April", "May", "June", "July",
          "August", "September", "October", "November", "December"]

def conference_choice(ctx):
    v = ctx.inputs.get("conference", "All D-I")
    return v if v in CONFERENCES else "All D-I"

def get_json(url, params):
    resp = http.get(url, params = params, ttl_seconds = TTL)
    if resp["status_code"] != 200 or type(resp["json"]) != "dict":
        return None
    return resp["json"]

def ncaa_season(updated):
    # "... Through games Monday, April 06, 2026" -> "2025-26". A season
    # starts in November, so October onward names the season that starts
    # that fall.
    words = updated.replace(",", " ").split(" ")
    year = 0
    month = 0
    for w in words:
        if w in MONTHS:
            month = MONTHS.index(w) + 1
        if len(w) == 4 and w.isdigit():
            year = int(w)
    if year == 0:
        return ""
    start = year if month >= 10 else year - 1
    return str(start) + "-" + str(start + 1)[2:]

def stat_of(athlete, names, category, field):
    # One ESPN stat's display string ("23.2", "46.5"), or "".
    for cat in athlete.get("categories") or []:
        if cat.get("name") == category:
            fields = names.get(category, [])
            totals = cat.get("totals") or []
            for i in range(min(len(fields), len(totals))):
                if fields[i] == field:
                    return str(totals[i])
    return ""

def ncaa_rows(stat_id):
    # [season, rows] from the NCAA rankings, or None offline. Each row is
    # {rank, name, last, team_id, team, value}.
    d = get_json(NCAA_API + stat_id, {})
    if d == None:
        return None
    rows = []
    for r in d.get("data") or []:
        if type(r) != "dict":
            continue
        vals = list(r.values())
        rank = "".join([ch for ch in str(r.get("Rank", "")).elems() if ch.isdigit()])
        name = strip_accents(str(r.get("Name", "")))
        team = str(r.get("Team", ""))
        parts = name.split(" ")
        rows.append({
            "rank": rank or "-",
            "name": name,
            "last": " ".join(parts[1:]) if len(parts) > 1 else name,
            "style": team_style(NCAA_TEAMS.get(team, -1), team),
            "value": str(vals[-1]) if len(vals) > 0 else "",
        })
        if len(rows) >= len(ROW_Y):
            break
    return [ncaa_season(str(d.get("updated", ""))), rows]

def espn_rows(conf_id, category, field):
    # [season, rows] from ESPN's qualified list for one conference, or None
    # offline. Ties share a rank (1, 2, 2).
    d = get_json(ESPN_API, {
        "region": "us",
        "lang": "en",
        "contentorigin": "espn",
        "seasontype": "2",
        "isqualified": "true",
        "conference": conf_id,
        "sort": category + "." + field + ":desc",
        "limit": "10",
    })
    if d == None:
        return None
    names = {}
    for cat in d.get("categories") or []:
        names[cat.get("name", "")] = cat.get("names") or []
    season = str((d.get("requestedSeason") or {}).get("displayName") or "")
    vals = []
    for a in d.get("athletes") or []:
        v = stat_of(a, names, category, field)
        n = to_num(v)
        if n == None or n <= 0:
            continue
        vals.append([n, v, a.get("athlete") or {}])
    rows = []
    for i in range(min(len(ROW_Y), len(vals))):
        better = len([x for x in vals if x[0] > vals[i][0]])
        athlete = vals[i][2]
        tid = athlete.get("teamId")
        rows.append({
            "rank": str(better + 1),
            "name": strip_accents(str(athlete.get("displayName", ""))),
            "last": strip_accents(str(athlete.get("lastName", "?"))),
            "style": team_style(int(tid) if tid != None else -1, str(athlete.get("teamShortName", ""))),
            "value": vals[i][1],
        })
    return [season, rows]

# ---------- text helpers ----------

def clip(c, text, font, maxw):
    # Longest prefix that fits - nothing in the API clips on its own.
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for n in range(len(t), 0, -1):
        if c.text_width(t[:n], font) <= maxw:
            return t[:n]
    return ""

def page_font(c, strings, maxw):
    for f in NAME_FONTS:
        fits = True
        for s in strings:
            if c.text_width(s, f) > maxw:
                fits = False
                break
        if fits:
            return f
    return NAME_FONTS[-1]

def short_name(c, name, maxw):
    # A double-barrelled name that won't fit even in the smallest name font
    # keeps its last half whole rather than clipping mid-word.
    if "-" not in name or c.text_width(name, NAME_FONTS[-1]) <= maxw:
        return name
    parts = name.split("-")
    return parts[0][:1] + "-" + "-".join(parts[1:])

def display_name(c, row, room):
    # The longest form that fits in the main font: "AJ DYBANTSA", then
    # "A. DYBANTSA", then "DYBANTSA".
    full = row["name"].upper()
    last = row["last"].upper()
    for f in [full, full[:1] + ". " + last]:
        if f != "" and c.text_width(f, NAME_FONTS[0]) <= room:
            return f
    return short_name(c, last, room)

# ---------- chrome ----------

def conference_chip(c, label, x):
    # 7px pill beside the ball: 4x5 text with 1px of fill above and below,
    # 2px either side.
    w = c.text_width(label, "4x5") + 4
    c.round_rect(x, 1, x + w - 1, 7, 1, fill = CHIP)
    c.text(label, x + 2, HEAD_Y, font = "4x5", color = "white")
    return x + w

def header(c, chip, titles, season):
    # titles runs longest first; the header takes the first that fits beside
    # the ball, chip, tag and season.
    right = c.width - PAD - 1
    c.sprite(LOGO, PAD, 0, legend = LOGO_LEGEND)
    x = conference_chip(c, chip, PAD + LOGO_W + 3) + 3
    tail = TAG + (" " + season if season != "" else "")
    c.text(tail, right, HEAD_Y, font = "4x5", color = DIM, align = "right")
    room = right - c.text_width(tail, "4x5") - 3 - x
    title = clip(c, titles[-1], "4x5", room)
    for t in titles:
        if c.text_width(t, "4x5") <= room:
            title = t
            break
    c.text(title, x, HEAD_Y, font = "4x5", color = INK)

def message(c, head, sub, head_color):
    # Sits in the band under the header row, so a failed page still says
    # which stat and conference it is.
    w = c.width - 2 * PAD
    c.text(clip(c, head, "5x7", w), c.width // 2, 12, font = "5x7", color = head_color, align = "center")
    c.text(clip(c, sub, "4x5", w), c.width // 2, 23, font = "4x5", color = DIM, align = "center")

# ---------- team badges ----------

def team_style(team_id, team_name):
    t = TEAMS.get(team_id)
    if t:
        return t
    # A school this table doesn't know (a newcomer to D-I, or a name the
    # NCAA spells a new way): a neutral badge with the start of its name
    # beats a blank.
    code = strip_accents(team_name).upper().replace(".", "").replace(" ", "")[:4]
    return [code or "?", "#444444", "#FFFFFF"]

def badge_width(c):
    # One width for every badge so the names start on one column: the
    # widest code (4 chars at 4x5) plus 2px of fill either side.
    w = 0
    for t in TEAMS.values():
        w = max(w, c.text_width(t[0], "4x5"))
    return w + 4

def badge(c, x, y, w, style):
    code, fill, ink = style[0], style[1], style[2]
    # Navy/black/purple fills vanish into the ground, so the dark ones get
    # a rim - a half-tone of their own ink, not gray.
    edge = blend(ink, fill, 50) if brightness(fill) < 64 else fill
    c.round_rect(x, y, x + w - 1, y + BADGE_H - 1, 1, fill = fill, outline = edge)
    c.text(clip(c, code, "4x5", w - 2), x + w // 2, y + 1, font = "4x5", color = ink, align = "center")

# ---------- the leaderboard ----------

def to_num(v):
    # "23.2", "12" -> a number; anything else ("-", "") -> None.
    t = str(v)
    if t == "" or t == "." or t == "-":
        return None
    for i in range(len(t)):
        if t[i] not in "0123456789.":
            return None
    return float(t)

def leaderboard(c, ctx, ncaa_id, category, field, titles):
    c.clear()
    conf = conference_choice(ctx)
    conf_id, chip = CONFERENCES[conf][0], CONFERENCES[conf][1]
    got = ncaa_rows(ncaa_id) if conf_id == "" else espn_rows(conf_id, category, field)
    if got == None:
        # No feed, so no season to vouch for - the ball, chip and stat still
        # say which page this is.
        header(c, chip, titles, "")
        return message(c, "STATS OFFLINE", "TRYING AGAIN SOON", AMBER)
    season, rows = got[0], got[1]
    header(c, chip, titles, season)
    if len(rows) == 0:
        # Before the first rankings of a season (or a conference with no
        # qualified players yet) there's simply no leaderboard.
        return message(c, "NO STATS YET", "CHECK BACK AFTER A FEW GAMES", INK)

    # Values right-aligned on the edge and measured first; the names get
    # what's left.
    right = c.width - PAD - 1
    bw = badge_width(c)
    name_x = BADGE_X + bw + NAME_GAP
    valw = 0
    for r in rows:
        valw = max(valw, c.text_width(r["value"], VALUE_FONT))
    room = right - valw - GAP - name_x + 1
    for r in rows:
        r["shown"] = display_name(c, r, room)
    font = page_font(c, [r["shown"] for r in rows], room)

    for i in range(len(rows)):
        r = rows[i]
        y = ROW_Y[i]
        c.text(clip(c, r["rank"], "5x7", RANK_W), PAD + RANK_W // 2, y, font = "5x7", color = DIM, align = "center")
        badge(c, BADGE_X, y, bw, r["style"])
        c.text(clip(c, r["shown"], font, room), name_x, y, font = font, color = INK)
        c.text(clip(c, r["value"], VALUE_FONT, valw), right, y, font = VALUE_FONT, color = INK, align = "right")

# ---------- pages ----------
# NCAA ranking ids differ for men and women; ESPN's field names don't.

def points(c, ctx):
    leaderboard(c, ctx, "136", "offensive", "avgPoints", ["POINTS PER GAME", "POINTS"])

def rebounds(c, ctx):
    leaderboard(c, ctx, "137", "general", "avgRebounds", ["REBOUNDS PER GAME", "REBOUNDS"])

def assists(c, ctx):
    leaderboard(c, ctx, "140", "offensive", "avgAssists", ["ASSISTS PER GAME", "ASSISTS"])

def steals(c, ctx):
    leaderboard(c, ctx, "139", "defensive", "avgSteals", ["STEALS PER GAME", "STEALS"])

def blocks(c, ctx):
    leaderboard(c, ctx, "138", "defensive", "avgBlocks", ["BLOCKS PER GAME", "BLOCKS"])

def fgpct(c, ctx):
    leaderboard(c, ctx, "141", "offensive", "fieldGoalPct", ["FIELD GOAL PCT", "FG PCT"])

def tppct(c, ctx):
    leaderboard(c, ctx, "143", "offensive", "threePointFieldGoalPct", ["THREE POINT PCT", "3PT PCT"])

def ftpct(c, ctx):
    leaderboard(c, ctx, "142", "offensive", "freeThrowPct", ["FREE THROW PCT", "FT PCT"])
