PAD = 10  # scroll safe zone: keep the outer 10 px clear of content
HEX = "0123456789abcdef"
FONT_H = {"4x5": 5, "5x7": 7, "6x8": 8, "10x16": 16}
TITLE_COLOR = "#E8C25A"
FALLBACK_TEAM_COLOR = "#B4B4B4"
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
MONTH_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
ESPN = "https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball"
SEASONS = 7  # current + 6 past: 7 schedule calls + 1 poll call = the 8-request render budget

# Dropdown name (lowercase) -> (ESPN team id, abbreviation, primary color, alternate color).
# Baked in from ESPN's /teams so a render spends no requests on team info.
TEAMS = {
    "abilene christian": ("2000", "ACU", "#592d82", "#b1b3b3"),
    "air force": ("2005", "AF", "#003594", "#ffffff"),
    "akron": ("2006", "AKR", "#041e42", "#c5b783"),
    "alabama": ("333", "ALA", "#9e1b32", "#ffffff"),
    "alabama a&m": ("2010", "AAMU", "#790000", "#ffffff"),
    "alabama state": ("2011", "ALST", "#e9a900", "#0a0a0a"),
    "albany": ("399", "UALB", "#3d2777", "#ffffff"),
    "alcorn state": ("2016", "ALCN", "#4b0058", "#46166a"),
    "american": ("44", "AMER", "#c41130", "#c8102e"),
    "app state": ("2026", "APP", "#000000", "#ffcd00"),
    "arizona": ("12", "ARIZ", "#cc0033", "#003366"),
    "arizona state": ("9", "ASU", "#ffc627", "#8c1d40"),
    "arkansas": ("8", "ARK", "#a32136", "#ffffff"),
    "arkansas state": ("2032", "ARST", "#cc092f", "#000000"),
    "arkansas-pine bluff": ("2029", "UAPB", "#e0aa0f", "#eaaa00"),
    "army": ("349", "ARMY", "#000000", "#d3bc8d"),
    "auburn": ("2", "AUB", "#002b5c", "#f26522"),
    "austin peay": ("2046", "APSU", "#8e0b0b", None),
    "ball state": ("2050", "BALL", "#ba0c2f", "#ffffff"),
    "baylor": ("239", "BAY", "#154734", "#ffb81c"),
    "bellarmine": ("91", "BELL", "#000000", None),
    "belmont": ("2057", "BEL", "#182142", "#c9262d"),
    "bethune-cookman": ("2065", "BCU", "#7b1831", "#e9aa12"),
    "binghamton": ("2066", "BING", "#00614a", "#f0f0f0"),
    "boise state": ("68", "BOIS", "#0033a0", "#d64309"),
    "boston college": ("103", "BC", "#8c2232", "#dbcca6"),
    "boston university": ("104", "BU", "#cc0000", "#ffffff"),
    "bowling green": ("189", "BGSU", "#fd5000", "#4f2c1d"),
    "bradley": ("71", "BRAD", "#b70002", "#c0c0c0"),
    "brown": ("225", "BRWN", "#411e09", "#949300"),
    "bryant": ("2803", "BRY", "#000000", "#9f8343"),
    "bucknell": ("2083", "BUCK", "#000060", "#00316e"),
    "buffalo": ("2084", "BUF", "#005bbb", "#ffffff"),
    "butler": ("2086", "BTLR", "#0d1361", "#00a3e0"),
    "byu": ("252", "BYU", "#0047ba", "#002e5d"),
    "cal poly": ("13", "CP", "#1e4d2b", "#eed897"),
    "california": ("25", "CAL", "#041e42", "#ffc72c"),
    "california baptist": ("2856", "CBU", "#000080", None),
    "campbell": ("2097", "CAM", "#000000", None),
    "canisius": ("2099", "CAN", "#004a81", "#dda50f"),
    "central arkansas": ("2110", "CARK", "#a7a9ac", "#8e959a"),
    "central connecticut": ("2115", "CCSU", "#1b49a2", "#d1d5d8"),
    "central michigan": ("2117", "CMU", "#4c0027", "#fbab18"),
    "charleston": ("232", "COFC", "#7a2531", "#9e8959"),
    "charleston southern": ("2127", "CHSO", "#2e3192", "#ded090"),
    "charlotte": ("2429", "CLT", "#005035", "#a49665"),
    "chattanooga": ("236", "UTC", "#00386b", "#dca71d"),
    "chicago state": ("2130", "CHST", "#006700", None),
    "cincinnati": ("2132", "CIN", "#000000", "#e00122"),
    "clemson": ("228", "CLEM", "#f56600", "#ffffff"),
    "cleveland state": ("325", "CLE", "#006633", "#231f20"),
    "coastal carolina": ("324", "CCU", "#006f71", "#a27752"),
    "colgate": ("2142", "COLG", "#821019", "#ffffff"),
    "colorado": ("38", "COLO", "#cfb87c", "#000000"),
    "colorado state": ("36", "CSU", "#004c23", "#c8c372"),
    "columbia": ("171", "COLU", "#7ba4db", "#183863"),
    "coppin state": ("2154", "COPP", "#2e3192", "#ffd204"),
    "cornell": ("172", "COR", "#b31b1b", "#ffffff"),
    "creighton": ("156", "CREI", "#005ca9", "#6cadde"),
    "csu bakersfield": ("2934", "CSUB", "#003bab", None),
    "csu fullerton": ("2239", "CSUF", "#003767", "#ff8300"),
    "csun": ("2463", "CSUN", "#b50000", None),
    "dartmouth": ("159", "DART", "#005730", "#000000"),
    "davidson": ("2166", "DAV", "#000000", "#e51837"),
    "dayton": ("2168", "DAY", "#004b8d", "#ffffff"),
    "delaware": ("48", "DEL", "#00539f", "#ffd200"),
    "delaware state": ("2169", "DSU", "#009cdb", "#d51c28"),
    "denver": ("2172", "DEN", "#98002e", "#a8996e"),
    "depaul": ("305", "DEP", "#2d649c", "#ce1125"),
    "detroit mercy": ("2174", "DETM", "#165b9e", "#d31733"),
    "drake": ("2181", "DRKE", "#005596", "#bec0c2"),
    "drexel": ("2182", "DREX", "#020260", "#ffd65a"),
    "duke": ("150", "DUKE", "#00539b", "#ffffff"),
    "duquesne": ("2184", "DUQ", "#002d62", "#b90b2e"),
    "east carolina": ("151", "ECU", "#582c83", "#ffc72c"),
    "east tennessee state": ("2193", "ETSU", "#002d61", "#ffc423"),
    "east texas a&m": ("2837", "ETAM", "#000000", None),
    "eastern illinois": ("2197", "EIU", "#000000", "#bebab9"),
    "eastern kentucky": ("2198", "EKU", "#660819", "#f0f0f0"),
    "eastern michigan": ("2199", "EMU", "#006938", "#ffffff"),
    "eastern washington": ("331", "EWU", "#a10022", "#abb4bc"),
    "elon": ("2210", "ELON", "#020303", "#b59a57"),
    "evansville": ("339", "EVAN", "#663399", "#ef6f00"),
    "fairfield": ("2217", "FAIR", "#000000", "#ebebeb"),
    "fairleigh dickinson": ("161", "FDU", "#72293c", "#28334a"),
    "florida": ("57", "FLA", "#0021a5", "#fa4616"),
    "florida a&m": ("50", "FAMU", "#f89728", "#00843d"),
    "florida atlantic": ("2226", "FAU", "#003366", "#cc0000"),
    "florida gulf coast": ("526", "FGCU", "#00885a", "#076c3b"),
    "florida international": ("2229", "FIU", "#091f3f", "#c3993f"),
    "florida state": ("52", "FSU", "#782f40", "#ceb888"),
    "fordham": ("2230", "FOR", "#830032", "#909090"),
    "fresno state": ("278", "FRES", "#b1102b", "#13284c"),
    "furman": ("231", "FUR", "#582c83", "#ffffff"),
    "gardner-webb": ("2241", "GWEB", "#c12535", "#909090"),
    "george mason": ("2244", "GMU", "#016600", "#ecb010"),
    "george washington": ("45", "GW", "#002843", "#e8d2a1"),
    "georgetown": ("46", "GTWN", "#110e42", "#001c58"),
    "georgia": ("61", "UGA", "#ba0c2f", "#2c2a29"),
    "georgia southern": ("290", "GASO", "#041e42", "#a3aaae"),
    "georgia state": ("2247", "GAST", "#0039a6", "#ffffff"),
    "georgia tech": ("59", "GT", "#b3a369", "#ffffff"),
    "gonzaga": ("2250", "GONZ", "#041e42", "#c8102e"),
    "grambling": ("2755", "GRAM", "#ee8601", "#ffd10a"),
    "grand canyon": ("2253", "GCU", "#522398", "#ffffff"),
    "green bay": ("2739", "GB", "#006633", "#ffffff"),
    "hampton": ("2261", "HAMP", "#0067ac", None),
    "harvard": ("108", "HARV", "#990000", "#dbdbdb"),
    "hawai'i": ("62", "HAW", "#005737", "#000000"),
    "high point": ("2272", "HPU", "#330072", "#ffffff"),
    "hofstra": ("2275", "HOF", "#003594", "#ffc72c"),
    "holy cross": ("107", "HC", "#582c83", "#ffffff"),
    "houston": ("248", "HOU", "#c8102e", "#ffffff"),
    "houston christian": ("2277", "HCU", "#00539c", None),
    "howard": ("47", "HOW", "#003a63", "#e51937"),
    "idaho": ("70", "IDHO", "#000000", "#8c6e4a"),
    "idaho state": ("304", "IDST", "#ef8c00", "#e9a126"),
    "illinois": ("356", "ILL", "#ff5f05", "#13294b"),
    "illinois state": ("2287", "ILST", "#ce1126", "#ffe716"),
    "incarnate word": ("2916", "UIW", "#000000", "#080808"),
    "indiana": ("84", "IU", "#970310", "#ffffff"),
    "indiana state": ("282", "INST", "#00669a", "#f0f0f0"),
    "iona": ("314", "IONA", "#6f2c3e", "#f0ab00"),
    "iowa": ("2294", "IOWA", "#231f20", "#fcd116"),
    "iowa state": ("66", "ISU", "#ae192d", "#ffc72a"),
    "iu indianapolis": ("85", "IUIN", "#a81f30", "#d59f0f"),
    "jackson state": ("2296", "JKST", "#123297", "#b5b7ba"),
    "jacksonville": ("294", "JAX", "#00523e", None),
    "jacksonville state": ("55", "JXST", "#cc0000", "#000000"),
    "james madison": ("256", "JMU", "#450084", "#cbb677"),
    "kansas": ("2305", "KU", "#0051ba", "#e8000d"),
    "kansas city": ("140", "KC", "#004b87", "#ffc72c"),
    "kansas state": ("2306", "KSU", "#330a57", "#e2e3e4"),
    "kennesaw state": ("338", "KENN", "#fdbb30", "#0b1315"),
    "kent state": ("2309", "KENT", "#002664", "#eaab00"),
    "kentucky": ("96", "UK", "#0033a0", "#ffffff"),
    "la salle": ("2325", "LAS", "#003356", "#ffce00"),
    "lafayette": ("322", "LAF", "#790000", "#a59474"),
    "lamar": ("2320", "LAM", "#000000", "#ebebeb"),
    "le moyne": ("2330", "LEM", None, None),
    "lehigh": ("2329", "LEH", "#6c2b2a", "#b69e70"),
    "liberty": ("2335", "LIB", "#0a254e", "#b72025"),
    "lindenwood": ("2815", "LIN", "#000000", None),
    "lipscomb": ("288", "LIP", "#20366c", "#f6b734"),
    "little rock": ("2031", "LR", "#ad0000", "#898d8f"),
    "liu": ("112358", "LIU", "#50c9f7", "#ffbf00"),
    "long beach state": ("299", "LBSU", "#000000", "#f1f2f3"),
    "longwood": ("2344", "LONG", "#003273", "#9ea2a3"),
    "louisiana": ("309", "UL", "#ce181e", "#000000"),
    "louisiana tech": ("2348", "LT", "#003087", "#cb333b"),
    "louisville": ("97", "LOU", "#c9001f", "#ffffff"),
    "loyola chicago": ("2350", "LUC", "#9d1244", None),
    "loyola maryland": ("2352", "L-MD", "#76a7a0", "#c9cbca"),
    "loyola marymount": ("2351", "LMU", "#880029", "#00345b"),
    "lsu": ("99", "LSU", "#461d76", "#fdd023"),
    "maine": ("311", "ME", "#127dbe", None),
    "manhattan": ("2363", "MAN", "#4f8537", "#b5b7ba"),
    "marist": ("2368", "MRST", "#e53730", "#f0f0f0"),
    "marquette": ("269", "MARQ", "#003366", "#ffcc00"),
    "marshall": ("276", "MRSH", "#00b140", "#000000"),
    "maryland": ("120", "MD", "#ce1126", "#ffffff"),
    "maryland eastern shore": ("2379", "UMES", "#5c2301", "#b5b7ba"),
    "massachusetts": ("113", "MASS", "#881c1c", "#ffffff"),
    "mcneese": ("2377", "MCN", "#00529c", "#ffd204"),
    "memphis": ("235", "MEM", "#004991", "#8e908f"),
    "mercer": ("2382", "MER", "#ff7f29", "#080808"),
    "mercyhurst": ("2385", "MERC", "#000000", None),
    "merrimack": ("2771", "MRMK", "#2f4f93", "#e8c535"),
    "miami": ("2390", "MIA", "#f47423", "#035131"),
    "miami (oh)": ("193", "M-OH", "#c41230", "#ffffff"),
    "michigan": ("130", "MICH", "#00274c", "#ffcb05"),
    "michigan state": ("127", "MSU", "#173f35", "#ffffff"),
    "middle tennessee": ("2393", "MTSU", "#036eb7", "#ffffff"),
    "milwaukee": ("270", "MILW", "#000000", "#ffc20e"),
    "minnesota": ("135", "MINN", "#5e0a2f", "#fab41c"),
    "mississippi state": ("344", "MSST", "#5d1725", "#c1c6c8"),
    "mississippi valley state": ("2400", "MVSU", "#005328", "#cf2d34"),
    "missouri": ("142", "MIZ", "#f1b82d", "#000000"),
    "missouri state": ("2623", "MOST", "#5e0009", "#ffffff"),
    "monmouth": ("2405", "MONM", "#051844", None),
    "montana": ("149", "MONT", "#751d4a", "#666666"),
    "montana state": ("147", "MTST", "#00205c", "#bc955c"),
    "morehead state": ("2413", "MORE", "#094fa3", "#fed91a"),
    "morgan state": ("2415", "MORG", "#014786", "#f47937"),
    "mount st. mary's": ("116", "MSM", "#005596", "#ebebeb"),
    "murray state": ("93", "MUR", "#002148", "#000e00"),
    "navy": ("2426", "NAVY", "#00225b", "#b5a67c"),
    "nc state": ("152", "NCSU", "#cc0000", "#ffffff"),
    "nebraska": ("158", "NEB", "#e31937", "#ffffff"),
    "nevada": ("2440", "NEV", "#041e42", "#8a8d8f"),
    "new hampshire": ("160", "UNH", "#004990", "#c3c4c6"),
    "new mexico": ("167", "UNM", "#ba0c2f", "#a7a8aa"),
    "new mexico state": ("166", "NMSU", "#7e141b", "#231f20"),
    "new orleans": ("2443", "NOLA", "#461d7c", "#fdd023"),
    "niagara": ("315", "NIA", "#69207e", "#f0f0f0"),
    "nicholls": ("2447", "NICH", "#c41230", "#f0f0f0"),
    "njit": ("2885", "NJIT", "#ee3024", "#df3e2e"),
    "norfolk state": ("2450", "NORF", "#0c8968", "#fdb813"),
    "north alabama": ("2453", "UNA", "#663399", None),
    "north carolina": ("153", "UNC", "#7bafd4", "#13294b"),
    "north carolina a&t": ("2448", "NCAT", "#0505aa", "#004684"),
    "north carolina central": ("2428", "NCCU", "#880023", "#c2c3c0"),
    "north dakota": ("155", "UND", "#00a26b", "#c2c3c0"),
    "north dakota state": ("2449", "NDSU", "#01402a", "#ffffff"),
    "north florida": ("2454", "UNF", "#004b8d", "#babcbe"),
    "north texas": ("249", "UNT", "#068f33", "#ffffff"),
    "northeastern": ("111", "NE", "#cc0001", "#c2c3c0"),
    "northern arizona": ("2464", "NAU", "#003976", "#1b3069"),
    "northern colorado": ("2458", "UNCO", "#13558d", "#ffc533"),
    "northern illinois": ("2459", "NIU", "#c8102e", "#000000"),
    "northern iowa": ("2460", "UNI", "#473282", "#ffffff"),
    "northern kentucky": ("94", "NKU", "#ffc82e", "#000000"),
    "northwestern": ("77", "NU", "#492f92", "#ffffff"),
    "northwestern state": ("2466", "NWST", "#492f91", "#ed6118"),
    "notre dame": ("87", "ND", "#062340", "#c99700"),
    "oakland": ("2473", "OAK", "#04091c", "#bc955c"),
    "ohio": ("195", "OHIO", "#154734", "#ffffff"),
    "ohio state": ("194", "OSU", "#ba0c2f", "#a8adb4"),
    "oklahoma": ("201", "OU", "#990000", "#ffffff"),
    "oklahoma state": ("197", "OKST", "#fe5c00", "#000000"),
    "old dominion": ("295", "ODU", "#003768", "#a1d2f1"),
    "ole miss": ("145", "MISS", "#13294b", "#cf142b"),
    "omaha": ("2437", "OMA", "#e3193e", "#474648"),
    "oral roberts": ("198", "ORU", "#002462", "#dac792"),
    "oregon": ("2483", "ORE", "#00934b", "#fff41b"),
    "oregon state": ("204", "ORST", "#dc4405", "#000000"),
    "pacific": ("279", "PAC", "#f47820", "#c2c3c0"),
    "penn": ("219", "PENN", "#082a74", "#a6163d"),
    "penn state": ("213", "PSU", "#061440", "#ffffff"),
    "pepperdine": ("2492", "PEPP", "#003a72", "#dc762f"),
    "pittsburgh": ("221", "PITT", "#003594", "#ffb81c"),
    "portland": ("2501", "PORT", "#330072", "#a8b3ba"),
    "portland state": ("2502", "PRST", "#00311e", "#ebebeb"),
    "prairie view a&m": ("2504", "PV", "#582c83", "#eaaa00"),
    "presbyterian": ("2506", "PRES", "#194896", "#990134"),
    "princeton": ("163", "PRIN", "#000000", "#ff6000"),
    "providence": ("2507", "PROV", "#000000", "#a3a19e"),
    "purdue": ("2509", "PUR", "#ceb888", "#000000"),
    "purdue fort wayne": ("2870", "PFW", "#cfb991", "#000000"),
    "queens": ("2511", "QUC", "#192c66", "#857040"),
    "quinnipiac": ("2514", "QUIN", "#041b43", None),
    "radford": ("2515", "RAD", "#bc1515", "#c2c3c0"),
    "rhode island": ("227", "URI", "#091f3f", "#5ab3e8"),
    "rice": ("242", "RICE", "#00205b", "#c1c6c8"),
    "richmond": ("257", "RICH", "#9e0712", "#b90b2e"),
    "rider": ("2520", "RID", "#a80532", "#ebebeb"),
    "robert morris": ("2523", "RMU", "#00214d", "#a21d2b"),
    "rutgers": ("164", "RUTG", "#ce0e2d", "#ffffff"),
    "sacramento state": ("16", "SAC", "#00573c", "#cdb97d"),
    "sacred heart": ("2529", "SHU", "#a40012", "#c29472"),
    "saint francis": ("2598", "SFPA", "#a20012", "#000000"),
    "saint joseph's": ("2603", "JOES", "#9e1b32", "#6c6f70"),
    "saint louis": ("139", "SLU", "#00539c", "#ebebeb"),
    "saint mary's": ("2608", "SMC", "#d80024", "#003057"),
    "saint peter's": ("2612", "SPU", "#004cc2", None),
    "sam houston": ("2534", "SHSU", "#f56423", "#ffffff"),
    "samford": ("2535", "SAM", "#005485", "#bc0023"),
    "san diego": ("301", "USD", "#2f99d4", "#2f99d4"),
    "san diego state": ("21", "SDSU", "#a6192e", "#000000"),
    "san francisco": ("2539", "SF", "#005a36", "#ffffff"),
    "san josé state": ("23", "SJSU", "#0038a8", "#ffb81a"),
    "santa clara": ("2541", "SCU", "#690b0b", "#101010"),
    "seattle u": ("2547", "SEA", "#bf2e1a", "#c2c3c0"),
    "seton hall": ("2550", "HALL", "#0857b1", "#8a8d8f"),
    "siena": ("2561", "SIE", "#037961", "#eea60f"),
    "siu edwardsville": ("2565", "SIUE", "#eb1c23", "#080808"),
    "smu": ("2567", "SMU", "#a80000", "#0033a1"),
    "south alabama": ("6", "USA", "#00205b", "#bf0d3e"),
    "south carolina": ("2579", "SC", "#73000a", "#000000"),
    "south carolina state": ("2569", "SCST", "#7d1315", "#104897"),
    "south dakota": ("233", "SDAK", "#cd1241", "#f0f0f0"),
    "south dakota state": ("2571", "SDST", "#0033a0", "#ffd100"),
    "south florida": ("58", "USF", "#006747", "#cfc493"),
    "southeast missouri state": ("2546", "SEMO", "#c8102e", "#000000"),
    "southeastern louisiana": ("2545", "SELA", "#215732", "#ffc72c"),
    "southern": ("2582", "SOU", "#004b97", "#ffc82d"),
    "southern illinois": ("79", "SIU", "#85283d", "#c2c3c0"),
    "southern indiana": ("88", "USI", None, None),
    "southern miss": ("2572", "USM", "#ffc72c", "#231f20"),
    "southern utah": ("253", "SUU", "#c72026", "#000000"),
    "st. bonaventure": ("179", "SBU", "#70261d", None),
    "st. john's": ("2599", "SJU", "#d10000", "#101010"),
    "st. thomas": ("2900", "STMN", "#000000", None),
    "stanford": ("24", "STAN", "#8c1515", "#ffffff"),
    "stephen f. austin": ("2617", "SFA", "#393996", "#bec0c2"),
    "stetson": ("56", "STET", "#0a5640", "#56854e"),
    "stonehill": ("284", "STO", "#000000", None),
    "stony brook": ("2619", "STBK", "#990000", None),
    "syracuse": ("183", "SYR", "#000e54", "#ff431b"),
    "tarleton state": ("2627", "TAR", "#000000", None),
    "tcu": ("2628", "TCU", "#4d1979", "#ffffff"),
    "temple": ("218", "TEM", "#a41e35", "#ffffff"),
    "tennessee": ("2633", "TENN", "#ff8200", "#ffffff"),
    "tennessee state": ("2634", "TNST", "#171796", "#f0f0f0"),
    "tennessee tech": ("2635", "TNTC", "#5a4099", "#ffde00"),
    "texas": ("251", "TEX", "#af5c37", "#ffffff"),
    "texas a&m": ("245", "TA&M", "#500000", "#ffffff"),
    "texas a&m-corpus christi": ("357", "AMCC", "#0067c5", "#007f3e"),
    "texas southern": ("2640", "TXSO", "#860038", "#ffffff"),
    "texas state": ("326", "TXST", "#501214", "#6a5638"),
    "texas tech": ("2641", "TTU", "#da291c", "#000000"),
    "the citadel": ("2643", "CIT", "#7badd3", "#002856"),
    "toledo": ("2649", "TOL", "#0b2240", "#ffcd00"),
    "towson": ("119", "TOW", "#ffc229", None),
    "troy": ("2653", "TROY", "#862633", "#b1b1b1"),
    "tulane": ("2655", "TULN", "#006747", "#418fde"),
    "tulsa": ("202", "TLSA", "#003595", "#d0b787"),
    "uab": ("5", "UAB", "#1a5632", "#fdb913"),
    "uc davis": ("302", "UCD", "#002855", "#c3c4c6"),
    "uc irvine": ("300", "UCI", "#002b5c", "#fec52e"),
    "uc riverside": ("27", "UCR", "#14234f", None),
    "uc san diego": ("28", "UCSD", "#000000", "#ffcd00"),
    "uc santa barbara": ("2540", "UCSB", "#1e1840", "#febc11"),
    "ucf": ("2116", "UCF", "#000000", "#b4a169"),
    "ucla": ("26", "UCLA", "#2774ae", "#f2a900"),
    "uconn": ("41", "CONN", "#0c2340", "#a2aaad"),
    "uic": ("82", "UIC", "#001e62", "#d50032"),
    "ul monroe": ("2433", "ULM", "#840029", "#fdb913"),
    "umass lowell": ("2349", "UML", "#00529c", "#cf1f2f"),
    "umbc": ("2378", "UMBC", "#000000", "#ad860a"),
    "unc asheville": ("2427", "UNCA", "#003da5", "#ffffff"),
    "unc greensboro": ("2430", "UNCG", "#003559", "#ffd90a"),
    "unc wilmington": ("350", "UNCW", "#00665e", "#ffda00"),
    "unlv": ("2439", "UNLV", "#cf0a2c", "#cac8c8"),
    "usc": ("30", "USC", "#9d2235", "#ffc72c"),
    "usc upstate": ("2908", "UPST", "#008545", "#000000"),
    "ut arlington": ("250", "UTA", "#004b7c", "#f58024"),
    "ut martin": ("2630", "UTM", "#ff6700", "#102a5c"),
    "ut rio grande valley": ("292", "RGV", "#dc6000", "#e1732d"),
    "utah": ("254", "UTAH", "#be0000", "#ffffff"),
    "utah state": ("328", "USU", "#0f2439", "#ffffff"),
    "utah tech": ("3101", "UTU", "#000000", None),
    "utah valley": ("3084", "UVU", "#004812", "#e1c736"),
    "utep": ("2638", "UTEP", "#ff8200", "#041e42"),
    "utsa": ("2636", "UTSA", "#0c2340", "#f15a22"),
    "valparaiso": ("2674", "VAL", "#794500", None),
    "vanderbilt": ("238", "VAN", "#000000", "#cfae70"),
    "vcu": ("2670", "VCU", "#ffaf00", "#000000"),
    "vermont": ("261", "UVM", "#154734", "#ffc72c"),
    "villanova": ("222", "VILL", "#00205b", "#13b5ea"),
    "virginia": ("258", "UVA", "#232d4b", "#f84c1e"),
    "virginia tech": ("259", "VT", "#6a2c3e", "#cf4520"),
    "vmi": ("2678", "VMI", "#ae122a", "#000000"),
    "wagner": ("2681", "WAG", "#00483a", "#ffffff"),
    "wake forest": ("154", "WAKE", "#ceb888", "#2c2a29"),
    "washington": ("264", "WASH", "#33006f", "#e8d3a2"),
    "washington state": ("265", "WSU", "#a60f2d", "#4d4d4d"),
    "weber state": ("2692", "WEB", "#18005a", "#ebebeb"),
    "west georgia": ("2698", "WGA", "#0033a1", "#db1a21"),
    "west virginia": ("277", "WVU", "#eaaa00", "#002855"),
    "western carolina": ("2717", "WCU", "#492f91", "#bf9e70"),
    "western illinois": ("2710", "WIU", "#4e1e8a", "#ffc90a"),
    "western kentucky": ("98", "WKU", "#e13a3e", "#ffffff"),
    "western michigan": ("2711", "WMU", "#532e1f", "#f1c500"),
    "wichita state": ("2724", "WICH", "#ffcd00", "#27251f"),
    "william & mary": ("2729", "W&M", "#115740", "#f0b323"),
    "winthrop": ("2737", "WIN", "#9e0b0e", "#fdb41e"),
    "wisconsin": ("275", "WIS", "#a00000", "#ffffff"),
    "wofford": ("2747", "WOF", "#533b22", "#f0f0f0"),
    "wright state": ("2750", "WRST", "#cba052", "#cba052"),
    "wyoming": ("2751", "WYO", "#492f24", "#ffc425"),
    "xavier": ("2752", "XAV", "#21304e", "#a5a7a8"),
    "yale": ("43", "YALE", "#004a81", "#286dc0"),
    "youngstown state": ("2754", "YSU", "#e51935", "#690717"),
}

# Rivalry names. Key = both team names lowercase, joined by "|" (either order works).
# Value = list of titles, longest first; the header uses the first one that fits.
RIVALRIES = {
    "arizona|arizona state": ["TERRITORIAL CUP"],
    "army|navy": ["ARMY-NAVY"],
    "cincinnati|xavier": ["CROSSTOWN SHOOTOUT", "CROSSTOWN"],
    "clemson|south carolina": ["PALMETTO SERIES"],
    "duke|nc state": ["TOBACCO ROAD"],
    "duke|north carolina": ["TOBACCO ROAD", "DUKE-UNC"],
    "florida|florida state": ["SUNSHINE SHOWDOWN"],
    "georgia|georgia tech": ["CLEAN, OLD-FASHIONED HATE", "OLD-FASHIONED HATE"],
    "houston|texas tech": ["LONE STAR STATE BATTLE", "LONE STAR BATTLE"],
    "illinois|missouri": ["BRAGGIN RIGHTS"],
    "indiana|purdue": ["HOOSIER STATE RIVALRY", "HOOSIER RIVALRY"],
    "iowa|iowa state": ["CY-HAWK TROPHY"],
    "byu|utah": ["THE HOLY WAR", "HOLY WAR"],
    "kansas|kansas state": ["SUNFLOWER SHOWDOWN"],
    "kansas|missouri": ["BORDER WAR"],
    "kentucky|louisville": ["BATTLE FOR THE BLUEGRASS", "BLUEGRASS BATTLE"],
    "nc state|north carolina": ["TOBACCO ROAD"],
    "new mexico|new mexico state": ["RIO GRANDE RIVALRY"],
    "oklahoma|oklahoma state": ["BEDLAM"],
    "oklahoma|texas": ["RED RIVER RIVALRY"],
    "oregon|oregon state": ["CIVIL WAR"],
    "pittsburgh|west virginia": ["BACKYARD BRAWL"],
    "texas|texas a&m": ["LONE STAR SHOWDOWN"],
    "georgetown|villanova": ["CATHOLIC SEVEN ROOTS", "CATHOLIC SEVEN"],
    "ucla|usc": ["CROSSTOWN SHOWDOWN", "CROSSTOWN"],
}

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _norm(name):
    return str(name).strip().lower()

def _display(s):
    # Bitmap fonts have no accents or apostrophes; they would be skipped silently.
    return str(s).replace("é", "e").replace("É", "E").replace("'", "").replace("’", "").upper()

def _absdiff(a, b):
    return a - b if a > b else b - a

def _safe_int(val):
    if val == None:
        return None
    if type(val) == "int":
        return val
    if type(val) == "float":
        return int(val)
    s = str(val).strip()
    if s.isdigit():
        return int(s.lstrip("0") or "0")
    return None

def _abbr(name, teams_map):
    if not name:
        return "TEAM"
    name_str = str(name)
    n = _norm(name_str)
    if n in teams_map and teams_map[n].get("abbreviation"):
        return _display(teams_map[n]["abbreviation"])
    if len(name_str) <= 4:
        return _display(name_str)
    parts = name_str.upper().split()
    if len(parts) >= 2:
        return _display(parts[0][:3] + parts[1][:1])
    return _display(name_str[:4])

def _hex_rgb(col):
    if col == None:
        return None
    s = str(col).strip().lower()
    if s.startswith("#"):
        s = s[1:]
    if len(s) != 6:
        return None
    rgb = []
    for i in [0, 2, 4]:
        hi = HEX.find(s[i])
        lo = HEX.find(s[i + 1])
        if hi < 0 or lo < 0:
            return None
        rgb.append(hi * 16 + lo)
    return rgb

def _rgb_hex(rgb):
    out = "#"
    for v in rgb:
        out += HEX[v // 16] + HEX[v % 16]
    return out

def _too_close(a, b):
    ra = _hex_rgb(a)
    rb = _hex_rgb(b)
    if ra == None or rb == None:
        return False
    return _absdiff(ra[0], rb[0]) + _absdiff(ra[1], rb[1]) + _absdiff(ra[2], rb[2]) < 80

def _team_color(team_name, teams_map, avoid=None):
    # Print colors: black and deep navy vanish on an LED. Skip black, lift the rest to a
    # bright version of the same hue, and fall back to the alternate color when the primary
    # is black or too close to the other team's color (`avoid`).
    info = teams_map.get(_norm(team_name), {})
    options = []
    for key in ["color", "alt"]:
        rgb = _hex_rgb(info.get(key))
        if rgb != None and max(rgb) >= 24:
            peak = max(rgb)
            if peak < 210:
                rgb = [min(255, v * 210 // peak) for v in rgb]
            options.append(_rgb_hex(rgb))
    if avoid != None:
        distinct = [o for o in options + [FALLBACK_TEAM_COLOR] if not _too_close(o, avoid)]
        if distinct:
            return distinct[0]
    return options[0] if options else FALLBACK_TEAM_COLOR

def _text_y(font, top, height):
    return top + (height - FONT_H[font]) // 2

def _fit(c, text, fonts, maxw):
    # Largest font that fits; if none does, clip the smallest and end with "..".
    for f in fonts:
        if c.text_width(text, font=f) <= maxw:
            return text, f
    f = fonts[len(fonts) - 1]
    s = text
    for _ in range(len(text)):
        if len(s) <= 1 or c.text_width(s + "..", font=f) <= maxw:
            break
        s = s[:len(s) - 1]
    cut = s.rfind(" ")
    if cut > 0 and cut * 10 >= len(s) * 7:
        s = s[:cut]
    return s.rstrip(" ,-") + "..", f

def _lv_width(c, label, value):
    return c.text_width(label, font="4x5") + 4 + c.text_width(value, font="4x5")

def _label_value(c, label, value, x, y, align):
    lw = c.text_width(label, font="4x5")
    total = _lv_width(c, label, value)
    if align == "right":
        x = x - total + 1
    elif align == "center":
        x = x - total // 2
    c.text(label, x, y, font="4x5", color="gray")
    c.text(value, x + lw + 4, y, font="4x5", color="white")

def _message(c, title, detail, color):
    # Two-line status screen: what happened, then what to do about it.
    c.text_center(title, 8, font="5x7", color=color)
    c.text_center(detail, 19, font="4x5", color="gray")

def _tags_width(c, tags):
    w = 0
    for t in tags:
        if t:
            w = max(w, c.text_width(t, font="4x5"))
    return w + 3 if w > 0 else 0

def _pick_title(c, titles, maxw):
    # Prefer any title that fits in the big font, then the small font, else clip the last one.
    for f in ["5x7", "4x5"]:
        for t in titles:
            if c.text_width(t, font=f) <= maxw:
                return t, f
    return _fit(c, titles[len(titles) - 1], ["4x5"], maxw)

def _draw_header(c, titles, label1, label2, col1, col2, full_names):
    # Team chips pinned to the safe-zone edges, rivalry name centered between them.
    right = c.width - 1 - PAD
    font = "4x5" if full_names else "5x7"
    if full_names:
        label1, _ = _fit(c, label1, ["4x5"], 56)
        label2, _ = _fit(c, label2, ["4x5"], 56)
    w1 = c.text_width(label1, font=font) + 4
    w2 = c.text_width(label2, font=font) + 4
    ty = _text_y(font, 0, 9)
    c.rect(PAD, 0, PAD + w1 - 1, 8, fill=col1)
    c.text_stroke(label1, PAD + 2, ty, font=font, color="white", stroke="black")
    c.rect(right - w2 + 1, 0, right, 8, fill=col2)
    c.text_stroke(label2, right - w2 + 3, ty, font=font, color="white", stroke="black")

    x0 = PAD + w1 + 4
    x1 = right - w2 - 4
    maxw = x1 - x0 + 1
    title, tfont = _pick_title(c, titles, maxw)
    tw = c.text_width(title, font=tfont)
    c.text(title, x0 + (maxw - tw) // 2, _text_y(tfont, 0, 9), font=tfont, color=TITLE_COLOR)

def _draw_series(c, w1, w2, col1, col2, tags1, tags2):
    # Win totals flank a tug-of-war bar; rank sits at the top of each total, streak at the bottom.
    right = c.width - 1 - PAD
    n1 = str(w1)
    n2 = str(w2)
    d1 = c.text_width(n1, font="10x16")
    d2 = c.text_width(n2, font="10x16")
    c.text(n1, PAD, 10, font="10x16", color="white")
    c.text(n2, right - d2 + 1, 10, font="10x16", color="white")

    for i in range(2):
        if tags1[i]:
            c.text(tags1[i], PAD + d1 + 3, 10 + 11 * i, font="4x5", color="white")
        if tags2[i]:
            tw = c.text_width(tags2[i], font="4x5")
            c.text(tags2[i], right - d2 - 2 - tw, 10 + 11 * i, font="4x5", color="white")

    side = max(d1 + _tags_width(c, tags1), d2 + _tags_width(c, tags2))
    bx0 = PAD + side + 4
    bx1 = right - side - 4
    bw = bx1 - bx0 + 1
    total = w1 + w2
    p1 = (bw * w1 + total // 2) // total

    c.rect(bx0, 13, bx1, 22, fill=col2)
    if p1 > 0:
        c.rect(bx0, 13, bx0 + p1 - 1, 22, fill=col1)
    sx = bx0 + p1
    if sx > bx0 and sx <= bx1:
        c.vline(sx, 13, 10, "black")

    # Midfield marker: whichever color crosses it leads the series.
    mid = bx0 + bw // 2
    c.vline(mid, 10, 2, "white")

def _draw_first_meeting(c, rank1, rank2):
    right = c.width - 1 - PAD
    side = max(_tags_width(c, [rank1]), _tags_width(c, [rank2]))
    if rank1:
        c.text(rank1, PAD, 15, font="4x5", color="white")
    if rank2:
        c.text(rank2, right - c.text_width(rank2, font="4x5") + 1, 15, font="4x5", color="white")
    maxw = right - PAD + 1 - 2 * (side + 1)
    text, font = _fit(c, "FIRST MEETING", ["10x16", "6x8", "5x7"], maxw)
    c.text_center(text, _text_y(font, 10, 16), font=font, color="white")

def rivalry_titles(t1, t2):
    a = _norm(t1)
    b = _norm(t2)
    t = RIVALRIES.get(a + "|" + b)
    if t == None:
        t = RIVALRIES.get(b + "|" + a)
    if t == None:
        return None
    return [_display(x) for x in t]

def espn_get(path, params, ttl):
    return http.get(ESPN + path, params=params, ttl_seconds=ttl)

def _num(s):
    return _safe_int(s)

def _fmt_date(dt_str, tbd):
    # Tip-offs are mostly evening US time, which is the next day in UTC. Shift back 8 hours
    # so the calendar day matches what fans expect (skipped when the time is TBD).
    s = str(dt_str or "")
    if len(s) < 13:
        return "TBD"
    y = _num(s[0:4])
    m = _num(s[5:7])
    d = _num(s[8:10])
    h = _num(s[11:13])
    if y == None or m == None or d == None or h == None or m < 1 or m > 12:
        return "TBD"
    if not tbd and h < 8:
        d -= 1
        if d < 1:
            m -= 1
            if m < 1:
                m = 12
                y -= 1
            d = MONTH_DAYS[m - 1]
            if m == 2 and ((y % 4 == 0 and y % 100 != 0) or y % 400 == 0):
                d = 29
    return MONTHS[m - 1] + " " + str(d)

def _season_end(ctx):
    return ctx.now.year + 1 if ctx.now.month >= 11 else ctx.now.year

def _teams_map():
    out = {}
    for k, v in TEAMS.items():
        out[k] = {"abbreviation": v[1], "color": v[2], "alt": v[3]}
    return out

def _load_rankings(ctx):
    # Latest AP poll as a map of ESPN team id -> rank. Only in-season (Nov-Apr);
    # in the offseason the last poll of the old year would be misleading.
    out = {}
    if ctx.now.month >= 5 and ctx.now.month <= 10:
        return out
    r = espn_get("/rankings", {}, 21600)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return out
    for poll in r["json"].get("rankings") or []:
        if poll.get("type") != "ap":
            continue
        for row in poll.get("ranks") or []:
            rk = _safe_int(row.get("current"))
            tid = (row.get("team") or {}).get("id")
            if tid != None and rk != None and rk > 0:
                out[str(tid)] = rk
        break
    return out

def _load_games(tid, ctx):
    # One call per season (ESPN has no multi-season schedule), regular season incl.
    # conference tournaments. Past seasons never change, so they cache for a week.
    end = _season_end(ctx)
    games = []
    for s in range(end - SEASONS + 1, end + 1):
        r = espn_get("/teams/" + tid + "/schedule", {"season": str(s)}, 86400 if s >= end - 1 else 604800)
        if r["status_code"] != 200 or type(r["json"]) != "dict":
            return r["status_code"] or 1, []
        games += r["json"].get("events") or []
    return 200, games

def _score(comp):
    sc = comp.get("score")
    if type(sc) == "dict":
        return _safe_int(sc.get("value"))
    return _safe_int(sc)

def main(c, ctx):
    c.fill("black")

    team1 = _s(ctx, "team1", "Duke")
    team2 = _s(ctx, "team2", "North Carolina")
    full_names = _s(ctx, "teamnamelength", "Abbreviations") == "Full Name"

    t1n = _norm(team1)
    t2n = _norm(team2)
    if t1n == t2n:
        _message(c, "PICK TWO DIFFERENT TEAMS", "TEAM 1 AND TEAM 2 MATCH", "amber")
        return
    if t1n not in TEAMS or t2n not in TEAMS:
        _message(c, "TEAM NOT RECOGNIZED", "PICK BOTH TEAMS AGAIN IN SETTINGS", "amber")
        return

    teams_map = _teams_map()
    id1 = TEAMS[t1n][0]
    id2 = TEAMS[t2n][0]

    status, games = _load_games(id1, ctx)
    if status != 200:
        _message(c, "ESPN UNAVAILABLE", "TRY AGAIN LATER", "red")
        return

    # Tally the series from team 1's schedule: keep only games against team 2.
    w1 = 0
    w2 = 0
    played = []
    upcoming = []
    earliest = ""
    for g in games:
        sd = str(g.get("date") or "")
        if sd != "" and (earliest == "" or sd < earliest):
            earliest = sd
        comps = g.get("competitions") or []
        if len(comps) == 0:
            continue
        comp = comps[0]
        mine = None
        theirs = None
        for side in comp.get("competitors") or []:
            sid = str((side.get("team") or {}).get("id"))
            if sid == id1:
                mine = side
            elif sid == id2:
                theirs = side
        if mine == None or theirs == None:
            continue
        stype = (comp.get("status") or {}).get("type") or {}
        state = stype.get("state")
        p1 = _score(mine)
        p2 = _score(theirs)
        if stype.get("name") == "STATUS_FINAL" and p1 != None and p2 != None and p1 != p2:
            played.append((sd, p1, p2))
            if p1 > p2:
                w1 += 1
            else:
                w2 += 1
        elif state == "in":
            upcoming.append((sd, "in_progress", 0))
        elif state == "pre" and stype.get("name") == "STATUS_SCHEDULED":
            upcoming.append((sd, "scheduled", 0 if comp.get("timeValid") == True else 1))

    played = sorted(played, reverse=True)
    upcoming = sorted(upcoming)
    total = w1 + w2

    a1 = _abbr(team1, teams_map)
    a2 = _abbr(team2, teams_map)

    titles = rivalry_titles(team1, team2)
    if titles == None:
        titles = ["SERIES", "VS"] if total > 0 else ["HEAD TO HEAD", "VS"]

    last_game_str = "-"
    streak_who = 0
    streak_len = 0
    if len(played) > 0:
        _, p1, p2 = played[0]
        if p1 > p2:
            last_game_str = a1 + " " + str(p1) + "-" + str(p2)
        else:
            last_game_str = a2 + " " + str(p2) + "-" + str(p1)
        for _, p1, p2 in played:
            who = 1 if p1 > p2 else 2
            if streak_who == 0:
                streak_who = who
            if who != streak_who:
                break
            streak_len += 1

    next_date = "TBD"
    if len(upcoming) > 0:
        nsd, nstatus, ntbd = upcoming[0]
        next_date = "LIVE" if nstatus == "in_progress" else _fmt_date(nsd, ntbd == 1)

    since = ""
    if total > 0 and len(earliest) >= 4:
        since = "SINCE " + earliest[0:4]

    col1 = _team_color(team1, teams_map)
    col2 = _team_color(team2, teams_map, col1)
    label1 = _display(team1) if full_names else a1
    label2 = _display(team2) if full_names else a2

    rankings = _load_rankings(ctx)
    r1 = rankings.get(id1)
    r2 = rankings.get(id2)
    rank1 = "#" + str(r1) if r1 != None else ""
    rank2 = "#" + str(r2) if r2 != None else ""
    streak1 = "W" + str(streak_len) if streak_who == 1 else ""
    streak2 = "W" + str(streak_len) if streak_who == 2 else ""
    right = c.width - 1 - PAD

    _draw_header(c, titles, label1, label2, col1, col2, full_names)

    if total > 0:
        _draw_series(c, w1, w2, col1, col2, [rank1, streak1], [rank2, streak2])
        last_v = last_game_str.upper()
        next_v = next_date.upper()
        _label_value(c, "LAST", last_v, PAD, 27, "left")
        _label_value(c, "NEXT", next_v, right, 27, "right")
        # Coverage note in the middle, only when it fits with room on both sides.
        if since != "":
            sw = c.text_width(since, font="4x5")
            sx = c.width // 2 - sw // 2
            left_end = PAD + _lv_width(c, "LAST", last_v)
            right_start = right - _lv_width(c, "NEXT", next_v)
            if sx - left_end >= 4 and right_start - (sx + sw) >= 4:
                c.text(since, sx, 27, font="4x5", color="gray")
    else:
        _draw_first_meeting(c, rank1, rank2)
        _label_value(c, "NEXT", next_date.upper(), c.width // 2, 27, "center")
