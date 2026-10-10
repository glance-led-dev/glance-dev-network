# College Coaching Carousel
#
# Your school's head coach, live from ESPN: who he is, how long he has been
# there, this season's record and the titles he has won.
#
#   coach    THE SIDELINE. A big pixel-art coach walks the chalk line in
#            the middle of the panel, in the school's kit, headset on and
#            clipboard out. Over the name hangs a small school banner (the
#            nickname, 'CRIMSON TIDE'); under it the tenure strip - one
#            pennant per season, this one lit. To his right a stadium
#            scoreboard on legs shows the logo and his record at the school
#            in amber bulbs ('212-128', AT IOWA). A new hire's board reads
#            NEW HIRE over this season's record, and his strip says who he
#            replaced ('REPLACES MOORE') - the carousel story.
#   resume   The same sideline: this season on a scoreboard - a header in
#            the school colour ('2026 SEASON  1ST IN SEC'), the record in
#            bulbs (green while unbeaten, red once the losses lead by two),
#            the AP rank as a gold badge with last week's move as an arrow -
#            and beside it a wooden trophy case: one cup per championship the
#            coach has won as a head coach, in the colour of its level (gold
#            FBS, silver FCS, bronze D2/D3/NAIA, silver Lombardis for Bill
#            Belichick's six Super Bowls), each year on a plaque below. No
#            titles: the coach walks the sideline beside the board instead.
#
# DESIGN. Archetype: SIDELINE - a scene, not a logo-and-text row. A chalk
# line and striped turf run the full width of both school pages; the coach
# (28 x 28, the biggest thing on the panel) walks it in the middle, and the
# words live on the things that stand on a sideline: the school banner
# overhead, the scoreboard, the pennants. The logo is never a left column -
# it is lit on the scoreboard at 20 x 12. The coach is a picture - visor in
# the school's second colour, polo in its first (so crimson Alabama in a
# white visor never reads as red Utah) - and his collar is the season's
# mood: red on the hot seat, gold while unbeaten. Records are amber
# scoreboard bulbs, titles stand in a lit trophy case. Failure screens stay in the set: a dark scoreboard
# with the message and a flat grey coach on a dimmed sideline. Black
# ground; school colours are lifted when ESPN's are too dark for an LED.
#
# DATA. Who the coach is, the season record and the AP rank are always live
# (ESPN core API for the coach and the AP poll, ESPN site API for record,
# standing and colours). ESPN's coaching HISTORY is not trustworthy enough
# to count tenure from: it has bogus seasons (1914, 2001) before 2014,
# credits most December hires to the season they were hired in, and
# mis-files some. So first seasons (FIRST_SEASON), records at the school
# through 2025 (RECORD) and the predecessor of each new hire (PREV) are
# tables of historical facts keyed by ESPN coach id - a fact like "Kirk
# Ferentz's first Iowa season was 1999" never goes stale, and the id check
# means it is only used while that coach is still the one ESPN lists. A coach
# not in the tables (a hire after this was written) falls back to ESPN's own
# seasons, walked back year by year within the request budget, and his
# scoreboard shows this season's record rather than a career one.
#
# Budget (8 uncached requests a render). Studio and previews render both
# pages in ONE run and the cap is shared, so the pages are budgeted together:
# team 1 + coach lookup COACH_BUDGET (3) + AP poll 1 = 5. The coach
# lookup is the coach list (+ the coach's own record and one step of the walk
# for an unknown coach) - enough to tell a new or interim hire from a
# returning one. Both school pages use the same budget, so they agree on YEAR N.

TEAM_URL = "https://site.web.api.espn.com/apis/site/v2/sports/football/college-football/teams/"
CORE = "https://sports.core.api.espn.com/v2/sports/football/leagues/college-football/"
AP_URL = CORE + "rankings/1"   # the current AP Top 25
HEADERS = {"User-Agent": "glance-college-coaching-carousel (glance-led.dev)"}

TEAM_TTL = 3600      # record, rank, standing: move once a week, checked hourly
STAFF_TTL = 21600    # who the head coach is
PAST_TTL = 2592000   # a past season's coach never changes
COACH_BUDGET = 3     # requests fetch_coach may spend; see the budget note

# ------------------------------------------------------------------ palette
INK = "#F4F7FF"
DIM = "#6E7A94"
OFFLINE = "#3C4043"
GOOD = "#2FE06F"
GOLD = "#FFC62F"
SKY = "#78DCFF"
RED = "#FF3B30"
AMBER = "#FFB000"

# ----------------------------------------------------------------- schools
# Dropdown label -> [abbr, ESPN team id]. Generated from ESPN's FBS standings.
SCHOOLS = {
    "AIR FORCE": ["AFA", "2005"],
    "AKRON": ["AKR", "2006"],
    "ALABAMA": ["ALA", "333"],
    "APP STATE": ["APP", "2026"],
    "ARIZONA": ["ARIZ", "12"],
    "ARIZONA STATE": ["ASU", "9"],
    "ARKANSAS": ["ARK", "8"],
    "ARKANSAS STATE": ["ARST", "2032"],
    "ARMY": ["ARMY", "349"],
    "AUBURN": ["AUB", "2"],
    "BYU": ["BYU", "252"],
    "BALL STATE": ["BALL", "2050"],
    "BAYLOR": ["BAY", "239"],
    "BOISE STATE": ["BOIS", "68"],
    "BOSTON COLLEGE": ["BC", "103"],
    "BOWLING GREEN": ["BGSU", "189"],
    "BUFFALO": ["BUFF", "2084"],
    "CALIFORNIA": ["CAL", "25"],
    "CENTRAL MICHIGAN": ["CMU", "2117"],
    "CHARLOTTE": ["CLT", "2429"],
    "CINCINNATI": ["CIN", "2132"],
    "CLEMSON": ["CLEM", "228"],
    "COASTAL CAROLINA": ["CCU", "324"],
    "COLORADO": ["COLO", "38"],
    "COLORADO STATE": ["CSU", "36"],
    "DELAWARE": ["DEL", "48"],
    "DUKE": ["DUKE", "150"],
    "EAST CAROLINA": ["ECU", "151"],
    "EASTERN MICHIGAN": ["EMU", "2199"],
    "FLORIDA": ["FLA", "57"],
    "FLORIDA ATLANTIC": ["FAU", "2226"],
    "FLORIDA INTERNATIONAL": ["FIU", "2229"],
    "FLORIDA STATE": ["FSU", "52"],
    "FRESNO STATE": ["FRES", "278"],
    "GEORGIA": ["UGA", "61"],
    "GEORGIA SOUTHERN": ["GASO", "290"],
    "GEORGIA STATE": ["GAST", "2247"],
    "GEORGIA TECH": ["GT", "59"],
    "HAWAII": ["HAW", "62"],
    "HOUSTON": ["HOU", "248"],
    "ILLINOIS": ["ILL", "356"],
    "INDIANA": ["IU", "84"],
    "IOWA": ["IOWA", "2294"],
    "IOWA STATE": ["ISU", "66"],
    "JACKSONVILLE STATE": ["JXST", "55"],
    "JAMES MADISON": ["JMU", "256"],
    "KANSAS": ["KU", "2305"],
    "KANSAS STATE": ["KSU", "2306"],
    "KENNESAW STATE": ["KENN", "338"],
    "KENT STATE": ["KENT", "2309"],
    "KENTUCKY": ["UK", "96"],
    "LSU": ["LSU", "99"],
    "LIBERTY": ["LIB", "2335"],
    "LOUISIANA": ["UL", "309"],
    "LOUISIANA TECH": ["LT", "2348"],
    "LOUISVILLE": ["LOU", "97"],
    "MARSHALL": ["MRSH", "276"],
    "MARYLAND": ["MD", "120"],
    "MASSACHUSETTS": ["MASS", "113"],
    "MEMPHIS": ["MEM", "235"],
    "MIAMI": ["MIA", "2390"],
    "MIAMI (OH)": ["M-OH", "193"],
    "MICHIGAN": ["MICH", "130"],
    "MICHIGAN STATE": ["MSU", "127"],
    "MIDDLE TENNESSEE": ["MTSU", "2393"],
    "MINNESOTA": ["MINN", "135"],
    "MISSISSIPPI STATE": ["MSST", "344"],
    "MISSOURI": ["MIZ", "142"],
    "MISSOURI STATE": ["MOST", "2623"],
    "NC STATE": ["NCSU", "152"],
    "NAVY": ["NAVY", "2426"],
    "NEBRASKA": ["NEB", "158"],
    "NEVADA": ["NEV", "2440"],
    "NEW MEXICO": ["UNM", "167"],
    "NEW MEXICO STATE": ["NMSU", "166"],
    "NORTH CAROLINA": ["UNC", "153"],
    "NORTH DAKOTA STATE": ["NDSU", "2449"],
    "NORTH TEXAS": ["UNT", "249"],
    "NORTHERN ILLINOIS": ["NIU", "2459"],
    "NORTHWESTERN": ["NU", "77"],
    "NOTRE DAME": ["ND", "87"],
    "OHIO": ["OHIO", "195"],
    "OHIO STATE": ["OSU", "194"],
    "OKLAHOMA": ["OU", "201"],
    "OKLAHOMA STATE": ["OKST", "197"],
    "OLD DOMINION": ["ODU", "295"],
    "OLE MISS": ["MISS", "145"],
    "OREGON": ["ORE", "2483"],
    "OREGON STATE": ["ORST", "204"],
    "PENN STATE": ["PSU", "213"],
    "PITTSBURGH": ["PITT", "221"],
    "PURDUE": ["PUR", "2509"],
    "RICE": ["RICE", "242"],
    "RUTGERS": ["RUTG", "164"],
    "SMU": ["SMU", "2567"],
    "SACRAMENTO STATE": ["SAC", "16"],
    "SAM HOUSTON": ["SHSU", "2534"],
    "SAN DIEGO STATE": ["SDSU", "21"],
    "SAN JOSE STATE": ["SJSU", "23"],
    "SOUTH ALABAMA": ["USA", "6"],
    "SOUTH CAROLINA": ["SC", "2579"],
    "SOUTH FLORIDA": ["USF", "58"],
    "SOUTHERN MISS": ["USM", "2572"],
    "STANFORD": ["STAN", "24"],
    "SYRACUSE": ["SYR", "183"],
    "TCU": ["TCU", "2628"],
    "TEMPLE": ["TEM", "218"],
    "TENNESSEE": ["TENN", "2633"],
    "TEXAS": ["TEX", "251"],
    "TEXAS A&M": ["TA&M", "245"],
    "TEXAS STATE": ["TXST", "326"],
    "TEXAS TECH": ["TTU", "2641"],
    "TOLEDO": ["TOL", "2649"],
    "TROY": ["TROY", "2653"],
    "TULANE": ["TULN", "2655"],
    "TULSA": ["TLSA", "202"],
    "UAB": ["UAB", "5"],
    "UCF": ["UCF", "2116"],
    "UCLA": ["UCLA", "26"],
    "UCONN": ["CONN", "41"],
    "UL MONROE": ["ULM", "2433"],
    "UNLV": ["UNLV", "2439"],
    "USC": ["USC", "30"],
    "UTEP": ["UTEP", "2638"],
    "UTSA": ["UTSA", "2636"],
    "UTAH": ["UTAH", "254"],
    "UTAH STATE": ["USU", "328"],
    "VANDERBILT": ["VAN", "238"],
    "VIRGINIA": ["UVA", "258"],
    "VIRGINIA TECH": ["VT", "259"],
    "WAKE FOREST": ["WAKE", "154"],
    "WASHINGTON": ["WASH", "264"],
    "WASHINGTON STATE": ["WSU", "265"],
    "WEST VIRGINIA": ["WVU", "277"],
    "WESTERN KENTUCKY": ["WKU", "98"],
    "WESTERN MICHIGAN": ["WMU", "2711"],
    "WISCONSIN": ["WIS", "275"],
    "WYOMING": ["WYO", "2751"],
}

# Literal asset paths (the publish lint needs literals). 24 x 18 logos,
# drawn at their authored size on the scoreboard (never scaled); filenames match the shared
# _logos set so polished logos re-sync by a straight copy, except Texas A&M
# (TAMU.png - '&' is not a legal asset name).
LOGO_S = {
    "AFA": "S/AFA.png",
    "AKR": "S/AKR.png",
    "ALA": "S/ALA.png",
    "APP": "S/APP.png",
    "ARIZ": "S/ARIZ.png",
    "ARK": "S/ARK.png",
    "ARMY": "S/ARMY.png",
    "ARST": "S/ARST.png",
    "ASU": "S/ASU.png",
    "AUB": "S/AUB.png",
    "BALL": "S/BALL.png",
    "BAY": "S/BAY.png",
    "BC": "S/BC.png",
    "BGSU": "S/BGSU.png",
    "BOIS": "S/BOIS.png",
    "BUFF": "S/BUFF.png",
    "BYU": "S/BYU.png",
    "CAL": "S/CAL.png",
    "CCU": "S/CCU.png",
    "CIN": "S/CIN.png",
    "CLEM": "S/CLEM.png",
    "CLT": "S/CLT.png",
    "CMU": "S/CMU.png",
    "COLO": "S/COLO.png",
    "CONN": "S/CONN.png",
    "CSU": "S/CSU.png",
    "DEL": "S/DEL.png",
    "DUKE": "S/DUKE.png",
    "ECU": "S/ECU.png",
    "EMU": "S/EMU.png",
    "FAU": "S/FAU.png",
    "FIU": "S/FIU.png",
    "FLA": "S/FLA.png",
    "FRES": "S/FRES.png",
    "FSU": "S/FSU.png",
    "GASO": "S/GASO.png",
    "GAST": "S/GAST.png",
    "GT": "S/GT.png",
    "HAW": "S/HAW.png",
    "HOU": "S/HOU.png",
    "ILL": "S/ILL.png",
    "IOWA": "S/IOWA.png",
    "ISU": "S/ISU.png",
    "IU": "S/IU.png",
    "JMU": "S/JMU.png",
    "JXST": "S/JXST.png",
    "KENN": "S/KENN.png",
    "KENT": "S/KENT.png",
    "KSU": "S/KSU.png",
    "KU": "S/KU.png",
    "LIB": "S/LIB.png",
    "LOU": "S/LOU.png",
    "LSU": "S/LSU.png",
    "LT": "S/LT.png",
    "M-OH": "S/M-OH.png",
    "MASS": "S/MASS.png",
    "MD": "S/MD.png",
    "MEM": "S/MEM.png",
    "MIA": "S/MIA.png",
    "MICH": "S/MICH.png",
    "MINN": "S/MINN.png",
    "MISS": "S/MISS.png",
    "MIZ": "S/MIZ.png",
    "MOST": "S/MOST.png",
    "MRSH": "S/MRSH.png",
    "MSST": "S/MSST.png",
    "MSU": "S/MSU.png",
    "MTSU": "S/MTSU.png",
    "NAVY": "S/NAVY.png",
    "NCSU": "S/NCSU.png",
    "ND": "S/ND.png",
    "NDSU": "S/NDSU.png",
    "NEB": "S/NEB.png",
    "NEV": "S/NEV.png",
    "NIU": "S/NIU.png",
    "NMSU": "S/NMSU.png",
    "NU": "S/NU.png",
    "ODU": "S/ODU.png",
    "OHIO": "S/OHIO.png",
    "OKST": "S/OKST.png",
    "ORE": "S/ORE.png",
    "ORST": "S/ORST.png",
    "OSU": "S/OSU.png",
    "OU": "S/OU.png",
    "PITT": "S/PITT.png",
    "PSU": "S/PSU.png",
    "PUR": "S/PUR.png",
    "RICE": "S/RICE.png",
    "RUTG": "S/RUTG.png",
    "SAC": "S/SAC.png",
    "SC": "S/SC.png",
    "SDSU": "S/SDSU.png",
    "SHSU": "S/SHSU.png",
    "SJSU": "S/SJSU.png",
    "SMU": "S/SMU.png",
    "STAN": "S/STAN.png",
    "SYR": "S/SYR.png",
    "TA&M": "S/TAMU.png",
    "TCU": "S/TCU.png",
    "TEM": "S/TEM.png",
    "TENN": "S/TENN.png",
    "TEX": "S/TEX.png",
    "TLSA": "S/TLSA.png",
    "TOL": "S/TOL.png",
    "TROY": "S/TROY.png",
    "TTU": "S/TTU.png",
    "TULN": "S/TULN.png",
    "TXST": "S/TXST.png",
    "UAB": "S/UAB.png",
    "UCF": "S/UCF.png",
    "UCLA": "S/UCLA.png",
    "UGA": "S/UGA.png",
    "UK": "S/UK.png",
    "UL": "S/UL.png",
    "ULM": "S/ULM.png",
    "UNC": "S/UNC.png",
    "UNLV": "S/UNLV.png",
    "UNM": "S/UNM.png",
    "UNT": "S/UNT.png",
    "USA": "S/USA.png",
    "USC": "S/USC.png",
    "USF": "S/USF.png",
    "USM": "S/USM.png",
    "USU": "S/USU.png",
    "UTAH": "S/UTAH.png",
    "UTEP": "S/UTEP.png",
    "UTSA": "S/UTSA.png",
    "UVA": "S/UVA.png",
    "VAN": "S/VAN.png",
    "VT": "S/VT.png",
    "WAKE": "S/WAKE.png",
    "WASH": "S/WASH.png",
    "WIS": "S/WIS.png",
    "WKU": "S/WKU.png",
    "WMU": "S/WMU.png",
    "WSU": "S/WSU.png",
    "WVU": "S/WVU.png",
    "WYO": "S/WYO.png",
}

# ---------------------------------------------------------- verified facts
# ESPN coach id -> first season as head coach at the school ESPN lists him
# at in 2026. One rule for interims who kept the job: the season counts
# only when he coached regular-season games (Swinney 2008, Danielson 2023,
# Key 2022, Harrell 2024, Carney 2025); a bowl-only interim starts the next
# year (Freeman 2022, Desormeaux 2022, Golding 2026). Historical facts; only
# used while the ids still match.
FIRST_SEASON = {
    "559873": 2007,
    "3020317": 2022,
    "4608671": 2024,
    "104971": 2025,
    "4077317": 2024,
    "4606657": 2026,
    "2496595": 2014,
    "559942": 2021,
    "5119667": 2023,
    "5120149": 2026,
    "5078198": 2025,
    "4610724": 2020,
    "2553866": 2024,
    "560022": 2025,
    "5184597": 2023,
    "559876": 2024,
    "2026707": 2016,
    "107615": 2026,
    "240002": 2026,
    "3040635": 2023,
    "2331668": 2008,
    "4873061": 2025,
    "2092969": 2025,
    "560112": 2023,
    "3955239": 2026,
    "559936": 2026,
    "135425": 2022,
    "4408727": 2024,
    "5255090": 2024,
    "2518896": 2014,
    "5260405": 2025,
    "559887": 2025,
    "129643": 2026,
    "4408750": 2025,
    "108626": 2020,
    "3084808": 2022,
    "559909": 2024,
    "4410718": 2022,
    "105182": 2022,
    "2518900": 2024,
    "559947": 2021,
    "559972": 1999,
    "5124575": 2026,
    "4079704": 2024,
    "559988": 2026,
    "4437881": 2025,
    "3085450": 2025,
    "381823": 2026,
    "3889470": 2021,
    "3040574": 2023,
    "559870": 2023,
    "2331669": 2026,
    "4899097": 2022,
    "3083495": 2014,
    "3954134": 2025,
    "2331935": 2019,
    "139297": 2026,
    "559987": 2022,
    "2549295": 2026,
    "124316": 2017,
    "2140304": 2026,
    "4409388": 2020,
    "5260121": 2025,
    "136697": 2024,
    "559976": 2026,
    "3089803": 2024,
    "5121519": 2023,
    "2574258": 2013,
    "156842": 2022,
    "5192940": 2024,
    "559926": 2023,
    "3955639": 2024,
    "123418": 2026,
    "3163057": 2024,
    "5151053": 2023,
    "160438": 2026,
    "4913374": 2022,
    "2174345": 2026,
    "4369610": 2019,
    "4077277": 2022,
    "3164111": 2015,
    "2981878": 2026,
    "3955422": 2025,
    "4332630": 2025,
    "560013": 2020,
    "4848688": 2021,
    "156919": 2024,
    "5261285": 2025,
    "559953": 2024,
    "148630": 2022,
    "176295": 2026,
    "149819": 2024,
    "4910958": 2024,
    "2499309": 2022,
    "559970": 2025,
    "20842": 2021,
    "2331930": 2021,
    "477810": 2025,
    "1952833": 2026,
    "107656": 2024,
    "4913271": 2022,
    "4708261": 2026,
    "236717": 2023,
    "162030": 2025,
    "559910": 2025,
    "4291615": 2026,
    "3960423": 2016,
    "382346": 2026,
    "157747": 2022,
    "5078088": 2024,
    "560247": 2025,
    "2474036": 2025,
    "5077663": 2025,
    "3161773": 2026,
    "1954365": 2024,
    "145698": 2022,
    "173997": 2026,
    "3085388": 2026,
    "559871": 2025,
    "4691540": 2024,
    "4606700": 2020,
    "125223": 2022,
    "134205": 2021,
    "2537586": 2026,
    "2112091": 2025,
    "2333672": 2024,
    "559927": 2023,
    "4407282": 2019,
    "5122324": 2023,
    "483465": 2026,
    "559939": 2025,
    "5194312": 2024,
    # Added after the 2026 audit: ESPN's walk-back got these wrong (Scalley,
    # Hauser and Woods were bowl-only or no-game interims; ODU counts Rahne
    # from the cancelled 2020 season) or right only by luck.
    "120675": 2026,
    "5327253": 2026,
    "148819": 2026,
    "560015": 2020,
    "560251": 2025,
    "5345545": 2026,
}

# ESPN coach id -> [first, last] for the coaches above, so a known coach
# costs no extra request.
NAMES = {
    "559873": ["TROY", "CALHOUN"],
    "3020317": ["JOE", "MOORHEAD"],
    "4608671": ["KALEN", "DEBOER"],
    "104971": ["DOWELL", "LOGGAINS"],
    "4077317": ["BRENT", "BRENNAN"],
    "4606657": ["RYAN", "SILVERFIELD"],
    "2496595": ["JEFF", "MONKEN"],
    "559942": ["BUTCH", "JONES"],
    "5119667": ["KENNY", "DILLINGHAM"],
    "5120149": ["ALEX", "GOLESH"],
    "5078198": ["MIKE", "UREMOVICH"],
    "4610724": ["DAVE", "ARANDA"],
    "2553866": ["BILL", "O'BRIEN"],
    "560022": ["EDDIE", "GEORGE"],
    "5184597": ["SPENCER", "DANIELSON"],
    "559876": ["PETE", "LEMBO"],
    "2026707": ["KALANI", "SITAKE"],
    "107615": ["TOSH", "LUPOI"],
    "240002": ["RYAN", "BEARD"],
    "3040635": ["SCOTT", "SATTERFIELD"],
    "2331668": ["DABO", "SWINNEY"],
    "4873061": ["TIM", "ALBIN"],
    "2092969": ["MATT", "DRINKALL"],
    "560112": ["DEION", "SANDERS"],
    "3955239": ["JASON", "CANDLE"],
    "559936": ["JIM", "MORA"],
    "135425": ["RYAN", "CARTY"],
    "4408727": ["MANNY", "DIAZ"],
    "5255090": ["BLAKE", "HARRELL"],
    "2518896": ["CHRIS", "CREIGHTON"],
    "5260405": ["ZACH", "KITTLEY"],
    "559887": ["WILLIE", "SIMMONS"],
    "129643": ["JON", "SUMRALL"],
    "4408750": ["MATT", "ENTZ"],
    "108626": ["MIKE", "NORVELL"],
    "3084808": ["CLAY", "HELTON"],
    "559909": ["DELL", "MCGEE"],
    "4410718": ["BRENT", "KEY"],
    "105182": ["TIMMY", "CHANG"],
    "2518900": ["WILLIE", "FRITZ"],
    "559947": ["BRET", "BIELEMA"],
    "559972": ["KIRK", "FERENTZ"],
    "5124575": ["JIMMY", "ROGERS"],
    "4079704": ["CURT", "CIGNETTI"],
    "559988": ["BILLY", "NAPIER"],
    "4437881": ["CHARLES", "KELLY"],
    "3085450": ["JERRY", "MACK"],
    "381823": ["COLLIN", "KLEIN"],
    "3889470": ["LANCE", "LEIPOLD"],
    "3040574": ["JAMEY", "CHADWELL"],
    "559870": ["JEFF", "BROHM"],
    "2331669": ["LANE", "KIFFIN"],
    "4899097": ["SONNY", "CUMBIE"],
    "3083495": ["CHUCK", "MARTIN"],
    "3954134": ["JOE", "HARASYMIAK"],
    "2331935": ["MIKE", "LOCKSLEY"],
    "139297": ["CHARLES", "HUFF"],
    "559987": ["MARIO", "CRISTOBAL"],
    "2549295": ["KYLE", "WHITTINGHAM"],
    "124316": ["P.J.", "FLECK"],
    "2140304": ["PETE", "GOLDING"],
    "4409388": ["ELIAH", "DRINKWITZ"],
    "5260121": ["TONY", "GIBSON"],
    "136697": ["JEFF", "LEBBY"],
    "559976": ["PAT", "FITZGERALD"],
    "3089803": ["DEREK", "MASON"],
    "5121519": ["BRIAN", "NEWBERRY"],
    "2574258": ["DAVE", "DOEREN"],
    "156842": ["MARCUS", "FREEMAN"],
    "5192940": ["TIM", "POLASEK"],
    "559926": ["MATT", "RHULE"],
    "3955639": ["JEFF", "CHOATE"],
    "123418": ["ROB", "HARLEY"],
    "3163057": ["TONY", "SANCHEZ"],
    "5151053": ["DAVID", "BRAUN"],
    "160438": ["ERIC", "MORRIS"],
    "4913374": ["DAN", "LANNING"],
    "2174345": ["JAMARCUS", "SHEPHARD"],
    "4369610": ["RYAN", "DAY"],
    "4077277": ["BRENT", "VENABLES"],
    "3164111": ["PAT", "NARDUZZI"],
    "2981878": ["MATT", "CAMPBELL"],
    "3955422": ["BARRY", "ODOM"],
    "4332630": ["SCOTT", "ABELL"],
    "560013": ["GREG", "SCHIANO"],
    "4848688": ["SHANE", "BEAMER"],
    "156919": ["SEAN", "LEWIS"],
    "5261285": ["PHIL", "LONGO"],
    "559953": ["KEN", "NIUMATALOLO"],
    "148630": ["RHETT", "LASHLEE"],
    "176295": ["TAVITA", "PRITCHARD"],
    "149819": ["FRAN", "BROWN"],
    "4910958": ["MIKE", "ELKO"],
    "2499309": ["SONNY", "DYKES"],
    "559970": ["K.C.", "KEELER"],
    "20842": ["JOSH", "HEUPEL"],
    "2331930": ["STEVE", "SARKISIAN"],
    "477810": ["TRE", "LAMB"],
    "1952833": ["MIKE", "JACOBS"],
    "107656": ["GERAD", "PARKER"],
    "4913271": ["JOEY", "MCGUIRE"],
    "4708261": ["WILL", "HALL"],
    "236717": ["GJ", "KINNE"],
    "162030": ["ALEX", "MORTENSEN"],
    "559910": ["SCOTT", "FROST"],
    "4291615": ["BOB", "CHESNEY"],
    "3960423": ["KIRBY", "SMART"],
    "382346": ["WILL", "STEIN"],
    "157747": ["MICHAEL", "DESORMEAUX"],
    "5078088": ["BRYANT", "VINCENT"],
    "560247": ["BILL", "BELICHICK"],
    "2474036": ["DAN", "MULLEN"],
    "5077663": ["JASON", "ECK"],
    "3161773": ["NEAL", "BROWN"],
    "1954365": ["MAJOR", "APPLEWHITE"],
    "145698": ["LINCOLN", "RILEY"],
    "173997": ["BRIAN", "HARTLINE"],
    "3085388": ["BLAKE", "ANDERSON"],
    "559871": ["BRONCO", "MENDENHALL"],
    "4691540": ["SCOTTY", "WALDEN"],
    "4606700": ["JEFF", "TRAYLOR"],
    "125223": ["TONY", "ELLIOTT"],
    "134205": ["CLARK", "LEA"],
    "2537586": ["JAMES", "FRANKLIN"],
    "2112091": ["JAKE", "DICKERT"],
    "2333672": ["JEDD", "FISCH"],
    "559927": ["LUKE", "FICKELL"],
    "4407282": ["TYSON", "HELTON"],
    "5122324": ["LANCE", "TAYLOR"],
    "483465": ["KIRBY", "MOORE"],
    "559939": ["RICH", "RODRIGUEZ"],
    "5194312": ["JAY", "SAWVEL"],
    "120675": ["MORGAN", "SCALLEY"],
    "5327253": ["JOHN", "HAUSER"],
    "148819": ["CASEY", "WOODS"],
    "560015": ["RICKY", "RAHNE"],
    "560251": ["MARK", "CARNEY"],
    "5345545": ["ALONZO", "CARTER"],
}

# ESPN coach id -> championships won as a head coach, [level, [seasons]].
# NATL = FBS national title, FCS / D2 / D3 / NAIA = those divisions' titles,
# SB = Super Bowl (by the season it capped).
TITLES = {
    "3960423": [["NATL", [2021, 2022]]],                               # Kirby Smart, Georgia
    "2331668": [["NATL", [2016, 2018]]],                               # Dabo Swinney, Clemson
    "4369610": [["NATL", [2024]]],                                     # Ryan Day, Ohio State
    "4079704": [["NATL", [2025]]],                                     # Curt Cignetti, Indiana
    "560247": [["SB", [2001, 2003, 2004, 2014, 2016, 2018]]],          # Bill Belichick, Patriots
    "4408750": [["FCS", [2019, 2021]]],                                # Matt Entz, North Dakota State
    "5124575": [["FCS", [2023]]],                                      # Jimmy Rogers, South Dakota State
    "559970": [["FCS", [2003, 2020]]],                                 # K.C. Keeler, Delaware / Sam Houston
    "5192940": [["FCS", [2024]]],                                      # Tim Polasek, North Dakota State
    "3083495": [["D2", [2005, 2006]]],                                 # Chuck Martin, Grand Valley State
    "3889470": [["D3", [2007, 2009, 2010, 2011, 2013, 2014]]],         # Lance Leipold, UW-Whitewater
    "4608671": [["NAIA", [2006, 2008, 2009]]],                         # Kalen DeBoer, Sioux Falls
}
TROPHY_COLOR = {"NATL": GOLD, "SB": "#D9DEE8", "FCS": "#C9D1DC", "D2": "#E0915A", "D3": "#E0915A", "NAIA": "#E0915A"}
TITLE_WORD = {"NATL": "NATL CHAMP", "SB": "SUPER BOWL", "FCS": "FCS CHAMP", "D2": "D-II CHAMP", "D3": "D-III CHAMP", "NAIA": "NAIA CHAMP"}
TITLE_SHORT = {"NATL": "NATL", "SB": "SB", "FCS": "FCS", "D2": "D-II", "D3": "D-III", "NAIA": "NAIA"}

# ESPN coach id -> [wins, losses] as head coach at his 2026 school, every
# game through the 2025 season, in the school's official credit: all stints
# (Schiano, Rodriguez, Frost, Locksley's 2015 interim), interim and bowl-only
# games he coached (Swinney 4-3 in 2008, Freeman's Fiesta Bowl, Day's three
# acting games in 2018), vacated wins removed (Iowa 2023: Ferentz 209-128,
# not 213-128). Each total was summed from ESPN's season records and checked
# against the coach's per-season record table (Wikipedia, from the school
# media guides); partial seasons were split by hand. Coaches whose credit
# the sources disagree on are left out (Fickell and the 2022 Guaranteed
# Rate Bowl), and their scoreboard shows this season instead. The live season is added on top
# only while it is the season right after RECORD_THROUGH.
RECORD_THROUGH = 2025
RECORD = {
    "559873": [139, 97],  # AFA Troy Calhoun
    "3020317": [13, 35],  # AKR Joe Moorhead
    "4608671": [20, 8],   # ALA Kalen DeBoer
    "104971": [5, 8],     # APP Dowell Loggains
    "4077317": [13, 12],  # ARIZ Brent Brennan
    "2496595": [89, 63],  # ARMY Jeff Monken
    "559942": [26, 37],   # ARST Butch Jones
    "5119667": [22, 17],  # ASU Kenny Dillingham
    "5078198": [4, 8],    # BALL Mike Uremovich
    "4610724": [36, 37],  # BAY Dave Aranda
    "2553866": [9, 16],   # BC Bill O'Brien
    "560022": [4, 8],     # BGSU Eddie George
    "5184597": [24, 8],   # BOIS Spencer Danielson
    "559876": [14, 11],   # BUFF Pete Lembo
    "2026707": [84, 45],  # BYU Kalani Sitake
    "3040635": [15, 22],  # CIN Scott Satterfield
    "2331668": [187, 53], # CLEM Dabo Swinney
    "4873061": [1, 11],   # CLT Tim Albin
    "2092969": [7, 6],    # CMU Matt Drinkall
    "560112": [16, 21],   # COLO Deion Sanders
    "135425": [33, 17],   # DEL Ryan Carty
    "4408727": [18, 9],   # DUKE Manny Diaz
    "5255090": [14, 5],   # ECU Blake Harrell
    "2518896": [61, 83],  # EMU Chris Creighton
    "5260405": [4, 8],    # FAU Zach Kittley
    "559887": [7, 6],     # FIU Willie Simmons
    "4408750": [9, 4],    # FRES Matt Entz
    "108626": [38, 34],   # FSU Mike Norvell
    "3084808": [27, 25],  # GASO Clay Helton
    "559909": [4, 20],    # GAST Dell McGee
    "4410718": [27, 20],  # GT Brent Key
    "105182": [22, 29],   # HAW Timmy Chang
    "2518900": [14, 11],  # HOU Willie Fritz
    "559947": [37, 26],   # ILL Bret Bielema
    "559972": [209, 128], # IOWA Kirk Ferentz
    "4079704": [27, 2],   # IU Curt Cignetti
    "4437881": [9, 5],    # JXST Charles Kelly
    "3085450": [10, 4],   # KENN Jerry Mack
    "560251": [5, 7],     # KENT Mark Carney
    "3889470": [27, 35],  # KU Lance Leipold
    "3040574": [25, 13],  # LIB Jamey Chadwell
    "559870": [28, 12],   # LOU Jeff Brohm
    "4899097": [19, 31],  # LT Sonny Cumbie
    "3083495": [72, 74],  # M-OH Chuck Martin
    "3954134": [0, 12],   # MASS Joe Harasymiak
    "2331935": [37, 49],  # MD Mike Locksley
    "559987": [35, 19],   # MIA Mario Cristobal
    "124316": [66, 44],   # MINN P.J. Fleck
    "4409388": [46, 29],  # MIZ Eliah Drinkwitz
    "5260121": [5, 7],    # MRSH Tony Gibson
    "136697": [7, 18],    # MSST Jeff Lebby
    "3089803": [6, 18],   # MTSU Derek Mason
    "5121519": [26, 12],  # NAVY Brian Newberry
    "2574258": [95, 70],  # NCSU Dave Doeren
    "156842": [43, 12],   # ND Marcus Freeman
    "5192940": [26, 3],   # NDSU Tim Polasek
    "559926": [19, 19],   # NEB Matt Rhule
    "3955639": [6, 19],   # NEV Jeff Choate
    "3163057": [7, 17],   # NMSU Tony Sanchez
    "5151053": [19, 19],  # NU David Braun
    "560015": [30, 33],   # ODU Ricky Rahne
    "4913374": [48, 8],   # ORE Dan Lanning
    "4369610": [82, 12],  # OSU Ryan Day
    "4077277": [32, 20],  # OU Brent Venables
    "3164111": [80, 61],  # PITT Pat Narduzzi
    "3955422": [2, 10],   # PUR Barry Odom
    "4332630": [5, 8],    # RICE Scott Abell
    "560013": [99, 108],  # RUTG Greg Schiano
    "4848688": [33, 30],  # SC Shane Beamer
    "156919": [12, 13],   # SDSU Sean Lewis
    "5261285": [2, 10],   # SHSU Phil Longo
    "559953": [10, 15],   # SJSU Ken Niumatalolo
    "148630": [38, 16],   # SMU Rhett Lashlee
    "149819": [13, 12],   # SYR Fran Brown
    "4910958": [19, 7],   # TA&M Mike Elko
    "2499309": [36, 17],  # TCU Sonny Dykes
    "559970": [5, 7],     # TEM K.C. Keeler
    "20842": [45, 20],    # TENN Josh Heupel
    "2331930": [48, 20],  # TEX Steve Sarkisian
    "477810": [4, 8],     # TLSA Tre Lamb
    "107656": [12, 14],   # TROY Gerad Parker
    "4913271": [35, 18],  # TTU Joey McGuire
    "236717": [23, 16],   # TXST GJ Kinne
    "162030": [2, 4],     # UAB Alex Mortensen
    "559910": [24, 14],   # UCF Scott Frost
    "3960423": [117, 21], # UGA Kirby Smart
    "157747": [29, 25],   # UL Michael Desormeaux
    "5078088": [8, 16],   # ULM Bryant Vincent
    "560247": [4, 8],     # UNC Bill Belichick
    "2474036": [10, 4],   # UNLV Dan Mullen
    "5077663": [9, 4],    # UNM Jason Eck
    "1954365": [11, 14],  # USA Major Applewhite
    "145698": [35, 18],   # USC Lincoln Riley
    "559871": [6, 7],     # USU Bronco Mendenhall
    "4691540": [5, 19],   # UTEP Scotty Walden
    "4606700": [53, 26],  # UTSA Jeff Traylor
    "125223": [22, 26],   # UVA Tony Elliott
    "134205": [26, 36],   # VAN Clark Lea
    "2112091": [9, 4],    # WAKE Jake Dickert
    "2333672": [15, 11],  # WASH Jedd Fisch
    "4407282": [57, 36],  # WKU Tyson Helton
    "5122324": [20, 19],  # WMU Lance Taylor
    "559939": [64, 34],   # WVU Rich Rodriguez
    "5194312": [7, 17],   # WYO Jay Sawvel
}

# First-season coach id -> the head coach he replaced: the one who ran the
# program in 2025, not a mid-season interim (Pittman, not Petrino), except
# where the interim coached the whole season (Stanford's Frank Reich).
PREV = {
    "4606657": "PITTMAN",      # Silverfield, Arkansas
    "5120149": "FREEZE",       # Golesh, Auburn
    "107615": "WILCOX",        # Lupoi, California
    "240002": "BECK",          # Beard, Coastal Carolina
    "559936": "NORVELL",       # Mora, Colorado State
    "129643": "NAPIER",        # Sumrall, Florida
    "5124575": "CAMPBELL",     # Rogers, Iowa State
    "559988": "CHESNEY",       # Napier, James Madison
    "381823": "KLIEMAN",       # Klein, Kansas State
    "382346": "STOOPS",        # Stein, Kentucky
    "2331669": "KELLY",        # Kiffin, LSU
    "139297": "SILVERFIELD",   # Huff, Memphis
    "2549295": "MOORE",        # Whittingham, Michigan
    "559976": "SMITH",         # Fitzgerald, Michigan State
    "148819": "BEARD",         # Woods, Missouri State
    "3161773": "MORRIS",       # N. Brown, North Texas
    "123418": "HAMMOCK",       # Harley, Northern Illinois
    "5327253": "SMITH",        # Hauser, Ohio
    "160438": "GUNDY",         # Morris, Oklahoma State
    "2140304": "KIFFIN",       # Golding, Ole Miss
    "2174345": "BRAY",         # Shephard, Oregon State
    "2981878": "FRANKLIN",     # Campbell, Penn State
    "5345545": "MARION",       # Carter, Sacramento State
    "173997": "GOLESH",        # Hartline, South Florida
    "3085388": "HUFF",         # B. Anderson, Southern Miss
    "176295": "REICH",         # Pritchard, Stanford
    "1952833": "CANDLE",       # Jacobs, Toledo
    "4708261": "SUMRALL",      # Hall, Tulane
    "4291615": "FOSTER",       # Chesney, UCLA
    "3955239": "MORA",         # Candle, UConn
    "120675": "WHITTINGHAM",   # Scalley, Utah
    "2537586": "PRY",          # Franklin, Virginia Tech
    "483465": "ROGERS",        # K. Moore, Washington State
}

# --------------------------------------------------------------- pixel art
# The coach walking the sideline, 28 x 28, facing the scoreboard: V visor
# (the school's second colour, so crimson Alabama wears a white visor and
# does not look like red Utah), v brim shade, S skin, s skin shade, E eyes,
# H headset band/cup, M mic boom, P polo (school colour), p polo shade, L
# collar and placket (the momentum trim: red once the losses lead by two,
# gold while unbeaten), C clipboard, W paper, w play lines, K khakis, k
# khaki shade, B shoes. Mid-stride: back foot left, front foot right.
COACH = """
..........VVVVVV............
.........VVVVVVVV...........
........VVVVVVVVVV..........
........VVVVVVVVVVvvvvv.....
.......HHSSSSSSSSS..........
.......HHSSSSSSSSSS.........
.......HHSSSSSESSSES........
.......HHSSSSSSSSSSS........
........HSSSSSSSSSSs........
........MSSSSSSSsSs.........
.........MMMMSSSSs..........
............SSSS............
.........PPLLLLLPP..........
........PPPPPPLPPPPP........
.......PPPPPPPLPPPPPP.......
......PPpPPPPPPPPPPPPP......
......PPpPPPPPPPPPPPPPP..HH.
......PPpPPPPPPPPPPPPSCCHHCC
......SS.PPPPPPPPPPP.SCWWWWC
......SS.PPPPPPPPPPP..CWwwWC
.........PPPPPPPPPP...CWWWWC
.........KKKKKKKKKK...CWwwWC
........KKKKKkKKKKK...CWWWWC
.......KKKK...KKKKK...CCCCCC
......KKKK.....KKKKK........
.....KKKK.......KKKK........
....KKKK.........KKKK.......
...BBBBB.........BBBBBB.....
"""

# 7 x 9 trophies: a cup (college titles) and a Lombardi (the NFL's).
CUP = """
XXXXXXX
X.XXX.X
X.XXX.X
.XXXXX.
..XXX..
...X...
...X...
..XXX..
.XXXXX.
"""
LOMBARDI = """
...X...
..XXX..
.XXXXX.
..XXX..
...X...
...X...
...X...
..XXX..
.XXXXX.
"""
# 4 x 5 pennant, one per season in the tenure strip under the name.
PENNANT = """
X...
XXX.
XXXX
XXX.
X...
"""
# 5 x 3 poll-movement arrows beside the AP badge.
UP = """
..X..
.XXX.
XXXXX
"""
DOWN = """
XXXXX
.XXX.
..X..
"""

# ------------------------------------------------------------- text tools
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-:;/&+%#!?()"

def clean(s):
    out = ""
    for ch in str(s).upper().elems():
        if KEEP.find(ch) >= 0:
            out += ch
    return " ".join([w for w in out.split(" ") if w != ""])

def clip(c, t, font, maxw):
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, t, fonts, maxw):
    for f in fonts:
        if c.text_width(t, f) <= maxw:
            return [f, t]
    f = fonts[len(fonts) - 1]
    return [f, clip(c, t, f, maxw)]

# Lit rows per face (10x16 draws its capitals in rows 0-14).
INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5, "16x20": 20}

HEXD = "0123456789abcdef"

def rgb(h):
    h = str(h).lower().lstrip("#")
    if len(h) != 6:
        return None
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [0, 2, 4]]
    for x in v:
        if x < 0:
            return None
    return v

def hexs(v):
    out = "#"
    for x in v:
        x = max(0, min(255, int(x)))
        out += HEXD[x // 16] + HEXD[x % 16]
    return out

def lum(v):
    return (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000

def led(h, fallback):
    """An ESPN team colour made readable on a black LED panel: dark colours
    are scaled up until their brightness clears 95, keeping the hue, and a
    near-black or missing colour takes the fallback."""
    v = rgb(h)
    if v == None:
        return fallback
    if max(v) < 40:
        return fallback
    L = lum(v)
    if L >= 95:
        return hexs(v)
    k = 95.0 / max(L, 1)
    top = max(v) * k
    if top > 255:
        k = k * 255.0 / top
    return hexs([v[0] * k, v[1] * k, v[2] * k])

def ink_for(fill):
    v = rgb(fill)
    if v == None:
        return "black"
    return "black" if lum(v) >= 150 else "white"

def pill(c, word, fill, x, y):
    c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")
    return c.text_width(word, "4x5") + 4

def pill_w(c, word):
    return c.text_width(word, "4x5") + 4

# ESPN's standing names that do not fit the chip row ('1ST IN MOUNTAIN WEST'
# clipped to '1ST IN MOUNTAIN'), shortened the way fans write them.
CONF_SHORT = [
    ["SUN BELT - EAST", "SBC EAST"],
    ["SUN BELT - WEST", "SBC WEST"],
    ["MOUNTAIN WEST", "MWC"],
    ["CONFERENCE USA", "CUSA"],
    ["AMERICAN ATHLETIC", "AAC"],
    ["AMERICAN", "AAC"],
    ["BIG TEN", "B1G"],
    ["SUN BELT", "SBC"],
]

def short_standing(s):
    for m in CONF_SHORT:
        if s.endswith(" " + m[0]) or s == m[0]:
            return s[:len(s) - len(m[0])] + m[1]
    return s

# The bitmap faces have no apostrophe, so O'BRIEN drew as OBRIEN: names are
# drawn in pieces with a hand-made tick between them.
def tick_w(font):
    return 4 if INKH[font] >= 10 else 3

# The big faces also give '.' a full cell, so 'P.J. FLECK' drew in 10x16
# with holes after each dot. There a dot is hand-set: 2 x 2 on the
# baseline, 1 px after the letter, then 1 px before the next letter or a
# 5 px gap where a space followed (as fantasy-injury-report does).
TIGHT = ["16x20", "10x16", "9x12", "8x10", "6x8"]

def seg_w(c, s, font):
    if font not in TIGHT or s.find(".") < 0:
        return c.text_width(s, font) if s != "" else 0
    pieces = s.split(".")
    w = 0
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            w += 3 + (5 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        w += c.text_width(t, font) if t != "" else 0
    return w - (1 if s.endswith(".") else 0)

def seg_draw(c, s, x, y, font, col):
    if font not in TIGHT or s.find(".") < 0:
        if s != "":
            c.text(s, x, y, font = font, color = col)
        return
    base = y + INKH[font] - 1
    pieces = s.split(".")
    for i in range(len(pieces)):
        t = pieces[i]
        if i > 0:
            c.rect(x + 1, base - 1, x + 2, base, fill = col)
            x += 3 + (5 if t.startswith(" ") else 1)
            t = t.lstrip(" ")
        if t != "":
            c.text(t, x, y, font = font, color = col)
            x += c.text_width(t, font)

def name_w(c, t, font):
    parts = t.split("'")
    w = 0
    for p in parts:
        w += seg_w(c, p, font)
    return w + (len(parts) - 1) * tick_w(font)

def draw_name(c, t, x, y, font, col):
    parts = t.split("'")
    th = 4 if INKH[font] >= 10 else 2
    tw = 2 if INKH[font] >= 10 else 1
    for i in range(len(parts)):
        seg_draw(c, parts[i], x, y, font, col)
        x += seg_w(c, parts[i], font)
        if i < len(parts) - 1:
            c.rect(x + 1, y, x + tw, y + th - 1, fill = col)
            x += tick_w(font)

def wl(rec):
    """'7-3' -> [7, 3]; anything else -> None."""
    p = str(rec).split("-")
    if len(p) < 2 or not p[0].isdigit() or not p[1].isdigit():
        return None
    return [int(p[0]), int(p[1])]

# ------------------------------------------------------------------- feeds
def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def season_now(ctx):
    """College seasons run August to January: January belongs to last year's
    season, and from February ESPN already files coaches under the new one."""
    y = ctx.now.year
    return y - 1 if ctx.now.month == 1 else y

def school_pick(ctx):
    label = str(ctx.inputs.get("school", "ALABAMA")).strip().upper()
    if label not in SCHOOLS:
        label = "ALABAMA"
    s = SCHOOLS[label]
    return {"label": label, "abbr": s[0], "id": s[1]}

def coach_id_of(ref):
    t = str(ref)
    i = t.find("/coaches/")
    if i < 0:
        return ""
    t = t[i + 9:]
    j = t.find("?")
    return t[:j] if j >= 0 else t

def fetch_team(sch):
    r = http.get(TEAM_URL + sch["id"], headers = HEADERS, ttl_seconds = TEAM_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    t = get(r["json"], "team", {})
    rec = ""
    for it in get(get(t, "record", {}), "items", []):
        if get(it, "type", "") == "total":
            rec = str(get(it, "summary", ""))
    # A black primary (Iowa, Army, Wake Forest) would vanish on the panel,
    # so the school's second colour stands in: Iowa's gold.
    alt = led(get(t, "alternateColor", ""), INK)
    return {"name": clean(get(t, "location", sch["label"])), "nick": clean(get(t, "name", "")),
            "color": led(get(t, "color", ""), alt if alt != INK else "#9AA3B2"),
            "alt": alt, "record": rec,
            "standing": short_standing(clean(get(t, "standingSummary", "")))}

def fetch_ap(sch):
    """-> [rank, last week's rank] in the AP Top 25, or None. The team feed's
    own 'rank' switches to the CFP ranking once that is published in
    November, so the AP badge reads the AP poll itself (33 KB)."""
    r = http.get(AP_URL, headers = HEADERS, ttl_seconds = TEAM_TTL)
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return None
    for it in get(r["json"], "ranks", []):
        ref = str(get(get(it, "team", {}), "$ref", ""))
        if ref.find("/teams/" + sch["id"] + "?") >= 0:
            cur = get(it, "current", 0)
            prev = get(it, "previous", 0)
            if type(cur) in ["int", "float"] and cur >= 1 and cur <= 25:
                return [int(cur), int(prev) if type(prev) in ["int", "float"] else 0]
    return None

def fetch_coach(sch, season, budget):
    """-> {ok, id, first, last, since} or {ok False, why}. Uses at most
    `budget` requests: the season's coach list (and last season's when the
    new season has none yet), the coach's own record for a coach we have no
    facts on, and a walk back through past seasons for his first year."""
    calls = 0
    lst = None
    yr = season
    for step in range(2):
        yr = season - step
        r = http.get(CORE + "seasons/" + str(yr) + "/teams/" + sch["id"] + "/coaches",
                     headers = HEADERS, ttl_seconds = STAFF_TTL)
        calls += 1
        if r["status_code"] == 0:
            return {"ok": False, "why": "offline"}
        if r["status_code"] == 200 and type(r["json"]) == "dict" and len(get(r["json"], "items", [])) > 0:
            lst = r["json"]
            break
    if lst == None:
        return {"ok": False, "why": "none"}
    ref = get(get(lst, "items", [])[0], "$ref", "")
    cid = coach_id_of(ref)
    if cid in NAMES and cid in FIRST_SEASON:
        n = NAMES[cid]
        return {"ok": True, "id": cid, "first": n[0], "last": n[1], "since": FIRST_SEASON[cid], "season": yr}
    r = http.get(str(ref).replace("http://", "https://"), headers = HEADERS, ttl_seconds = STAFF_TTL)
    calls += 1
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "why": "offline" if r["status_code"] == 0 else "error"}
    first = clean(get(r["json"], "firstName", ""))
    last = clean(get(r["json"], "lastName", ""))
    since = FIRST_SEASON.get(cid, 0)
    if since == 0:
        # Unknown coach: walk back while ESPN still files him at this school.
        since = yr
        for step in range(6):
            if calls >= budget or since <= 2014:
                break
            p = http.get(CORE + "seasons/" + str(since - 1) + "/coaches/" + cid,
                         headers = HEADERS, ttl_seconds = PAST_TTL)
            calls += 1
            if p["status_code"] != 200 or type(p["json"]) != "dict":
                break
            if str(get(get(p["json"], "team", {}), "$ref", "")).find("/teams/" + sch["id"] + "?") < 0:
                break
            since -= 1
    return {"ok": True, "id": cid, "first": first, "last": last, "since": since, "season": yr}

def co_record(tm):
    r = str(tm["record"]).strip()
    return r if wl(r) != None else "0-0"

def rec_color(rec):
    """White while even or winning, red once the losses lead by two, green
    while unbeaten - a fact about the record, not an opinion about the coach."""
    v = wl(rec)
    if v == None:
        return INK
    if v[1] - v[0] >= 2:
        return RED
    if v[0] > 0 and v[1] == 0:
        return GOOD
    return INK

def career_record(co, tm):
    """'212-128': the coach's verified record at the school through
    RECORD_THROUGH plus this season's live one - or '' when there is no
    verified total, or a season has passed that the table does not cover."""
    base = RECORD.get(co["id"])
    if base == None:
        return ""
    if co["season"] == RECORD_THROUGH:
        return str(base[0]) + "-" + str(base[1])
    if co["season"] != RECORD_THROUGH + 1:
        return ""
    v = wl(co_record(tm))
    return str(base[0] + v[0]) + "-" + str(base[1] + v[1])

# ------------------------------------------------------------ shared chrome
# The sideline: a chalk boundary line at y 30 and turf at y 31 under every
# school page, mowed in 15 px stripes. Text stops at y 28, a row above it.
# Like everything else it stays inside x 6..185, so a scroll panel never
# runs it into the neighbouring app.
CHALK = "#C8D0DC"
TURF = "#1E7A38"
TURF2 = "#2C9A4A"
STEEL = "#5A6478"   # scoreboard frame
POST = "#3A4150"    # scoreboard legs, headset
EDGE0 = 6
EDGE1 = 185

def sideline(c, dim = False):
    c.rect(EDGE0, 30, EDGE1, 30, fill = color.dim(CHALK, 45) if dim else CHALK)
    for i in range(12):
        col = TURF if i % 2 == 0 else TURF2
        c.rect(EDGE0 + i * 15, 31, EDGE0 + i * 15 + 14, 31, fill = color.dim(col, 45) if dim else col)

def scoreboard(c, x0, x1, y1, frame = STEEL):
    """A stadium scoreboard: framed box y 0..y1 standing on two legs that
    reach the chalk. The inside is left black for the caller."""
    c.rect(x0, 0, x1, y1, outline = frame)
    for lx in [x0 + 8, x1 - 9]:
        c.rect(lx, y1 + 1, lx + 1, 29, fill = POST)

def coach_sprite(c, x, y, tm, rec):
    polo = tm["color"]
    visor = tm["alt"] if tm["alt"] != polo else INK
    state = rec_color(rec)
    trim = RED if state == RED else (GOLD if state == GOOD else visor)
    leg = {"V": visor, "v": color.dim(visor, 60), "S": "#E8B48A", "s": "#B9825C", "E": "#2A1A10",
           "H": POST, "M": "#9AA3B2", "P": polo, "p": color.dim(polo, 60), "L": trim,
           "C": "#8B5A2B", "W": "#F4F7FF", "w": "#6E7A94", "K": "#C8B48A", "k": "#9C8A64", "B": "#2A2E38"}
    c.sprite(COACH, x, y, legend = leg)

def ghost_coach(c, x, col):
    """The empty-sideline figure for the failure screens: one flat colour."""
    leg = {}
    for ch in "VvSsHMPpLCWwKkB".elems():
        leg[ch] = col
    leg["E"] = None
    c.sprite(COACH, x, 2, legend = leg)

def note_screen(c, head, sub, hcol, frame, ghost):
    """Failure and empty screens, in the page's own set: a dark scoreboard
    carries the message, a flat grey coach stands beside it."""
    c.fill("black")
    sideline(c, True)
    scoreboard(c, 6, 150, 23, frame)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 136)
    c.text(hf[1], 78, 4 + (8 - INKH[hf[0]]) // 2, font = hf[0], color = hcol, align = "center")
    sf = fit(c, sub, ["4x5"], 136)
    c.text(sf[1], 78, 15, font = sf[0], color = DIM, align = "center")
    ghost_coach(c, 158, ghost)

def fail_screen(c, head, sub):
    note_screen(c, head, sub, AMBER, OFFLINE, OFFLINE)

def quiet_screen(c, sch, head, sub):
    """No coach on file is an answer, not an outage: green and calm."""
    note_screen(c, head, sub, GOOD, STEEL, "#2A3040")

def load_school(c, ctx, budget):
    """Both school pages share this: -> [sch, tm, co] or None after drawing
    the right failure screen. `budget` is what fetch_coach may spend."""
    sch = school_pick(ctx)
    tm = fetch_team(sch)
    if tm == None:
        fail_screen(c, "ESPN OFFLINE", "CHECKING AGAIN SOON")
        return None
    co = fetch_coach(sch, season_now(ctx), budget)
    if not co["ok"]:
        if co["why"] == "none":
            quiet_screen(c, sch, "NO HEAD COACH ON FILE", "ESPN LISTS NONE FOR " + sch["abbr"])
        else:
            fail_screen(c, "ESPN OFFLINE", "CHECKING AGAIN SOON")
        return None
    return [sch, tm, co]

def banner(c, word, fill, x, y, maxw):
    """The school banner overhead: a cloth in the school colour with a
    swallowtail cut into its right end."""
    t = clip(c, word, "4x5", maxw - 7)
    if t == "":
        return
    x1 = x + 2 + c.text_width(t, "4x5") + 4
    c.rect(x, y, x1, y + 6, fill = fill)
    c.rect(x1, y + 2, x1, y + 4, fill = "black")
    c.pixel(x1 - 1, y + 3, "black")
    c.text(t, x + 2, y + 1, font = "4x5", color = ink_for(fill))

# Page 1 zones. Name block x TX..NR under the banner; the coach sprite at
# CX (his leftmost lit column, the back shoe, is CX + 3), so NR leaves
# 4 px of air; the scoreboard x BX0..BX1 (his clipboard ends at CX + 27,
# 2 px clear of the frame).
TX = 6
NR = 76
TW = NR - TX + 1
CX = 78
BX0 = 108
BX1 = 185

# --------------------------------------------------------------- page: coach
def coach(c, ctx):
    # team + COACH_BUDGET; see the budget note at the top.
    d = load_school(c, ctx, COACH_BUDGET)
    if d == None:
        return
    sch, tm, co = d[0], d[1], d[2]
    season_rec = co_record(tm)
    c.fill("black")
    sideline(c)
    coach_sprite(c, CX, 2, tm, season_rec)

    year = co["season"] - co["since"] + 1
    new = year <= 1

    # Banner overhead: the nickname ('CRIMSON TIDE'), else the school, else
    # its abbreviation - whichever is first to fit whole.
    word = sch["abbr"]
    for w in [tm["nick"], sch["label"]]:
        if w != "" and c.text_width(w, "4x5") <= TW - 7:
            word = w
            break
    banner(c, word, tm["color"], TX, 0, TW)

    # Hero y 8..22: the full name when it fits big, else the surname big.
    full = (co["first"] + " " + co["last"]).strip()
    pick = None
    for o in [[full, "10x16"], [co["last"], "10x16"], [full, "9x12"], [co["last"], "9x12"],
              [full, "8x10"], [co["last"], "8x10"], [co["last"], "6x8"], [co["last"], "5x7"]]:
        if o[0] != "" and name_w(c, o[0], o[1]) <= TW:
            pick = o
            break
    if pick == None:
        pick = [clip(c, co["last"], "4x5", TW), "4x5"]
    draw_name(c, pick[0], TX, 8 + (15 - INKH[pick[1]]) // 2, pick[1], INK)

    # The scoreboard: school logo and the record in amber bulbs. His record
    # at the school ('212-128', captioned AT IOWA) when it is verified; a
    # new hire's or an unverified coach's is this season's.
    # Inside the frame (x BX0+1..BX1-1, y 1..22): the 24 x 18 logo at its
    # authored size, x BX0+2.., y 3..20; right of it the zone x zx0..BX1-2
    # holds the record (y 2..13), a rule (y 15) and the caption (y 17..21).
    zx0 = BX0 + 2 + 24 + 1
    zw = BX1 - 2 - zx0 + 1
    car = "" if new else career_record(co, tm)
    if new:
        digits, caps, ccol = season_rec, ["NEW HIRE"], SKY
    elif car != "":
        digits, ccol = car, DIM
        caps = ["AT " + sch["abbr"] + " SINCE " + str(co["since"]), "AT " + sch["abbr"]]
    else:
        digits, ccol = season_rec, DIM
        caps = [str(co["season"]) + " SEASON", "IN " + str(co["season"])]
    cap = caps[len(caps) - 1]
    for t in caps:
        if c.text_width(t, "4x5") <= zw:
            cap = t
            break
    scoreboard(c, BX0, BX1, 23)
    c.image(LOGO_S[sch["abbr"]], BX0 + 2, 3)
    rf = fit(c, digits, ["9x12", "8x10", "6x8", "5x7", "4x5"], zw)
    c.text(rf[1], zx0 + zw // 2, 2 + (12 - INKH[rf[0]]) // 2, font = rf[0], color = AMBER, align = "center")
    c.rect(zx0, 15, BX1 - 2, 15, fill = "#2A3040")
    cf = fit(c, cap, ["4x5"], zw)
    c.text(cf[1], zx0 + zw // 2, 17, font = "4x5", color = ccol, align = "center")

    # Strip y 24..28 under the name. A new hire: his one gold pennant and
    # the man he replaced - the carousel story. Otherwise 'YEAR N' and one
    # pennant per season, this one lit; a long tenure shrinks them to 2 px
    # posts so Ferentz's 28 still fit, and the count is always in the label.
    if new:
        c.sprite(PENNANT, TX, 24, legend = {"X": GOLD})
        x = TX + 7
        prev = PREV.get(co["id"], "")
        if prev != "" and c.text_width("REPLACES " + prev, "4x5") <= NR - x + 1:
            c.text("REPLACES", x, 24, font = "4x5", color = DIM)
            c.text(prev, x + c.text_width("REPLACES ", "4x5"), 24, font = "4x5", color = INK)
        elif prev != "" and c.text_width("AFTER " + prev, "4x5") <= NR - x + 1:
            c.text("AFTER", x, 24, font = "4x5", color = DIM)
            c.text(prev, x + c.text_width("AFTER ", "4x5"), 24, font = "4x5", color = INK)
        else:
            c.text("YEAR 1", x, 24, font = "4x5", color = INK)
        return
    label = "YEAR " + str(year)
    c.text(label, TX, 24, font = "4x5", color = GOLD if year >= 10 else INK)
    x0 = TX + c.text_width(label, "4x5") + 4
    room = NR - x0 + 1
    if year * 5 - 1 <= room:
        for i in range(year):
            col = GOLD if i == year - 1 else tm["color"]
            c.sprite(PENNANT, x0 + i * 5, 24, legend = {"X": col})
    else:
        step = 3 if year * 3 - 1 <= room else 2
        n = min(year, (room + 1) // step)
        for i in range(n):
            col = GOLD if i == n - 1 else tm["color"]
            c.rect(x0 + i * step, 24, x0 + i * step, 28, fill = col)
            if step == 3:
                c.pixel(x0 + i * step + 1, 25, col)

# -------------------------------------------------------------- page: resume
# The trophy case: a wooden cabinet, cups on the shelf, and each title's
# year on a plaque under its cup.
WOOD = "#8A5A2E"
SHELF = "#C8904E"
GLASS = "#2E3A52"
PLAQUE = "#9AA3B2"
CY = 4   # the case's top edge; cups at CY + 2, shelf CY + 11, plaques CY + 13

def trophy_case(c, titles, n, x1, room):
    """Draws the cabinet right-aligned to x1 inside `room` px; -> True when
    the per-cup years fit underneath (10 px pitch), False at the 8 px pitch."""
    # Plaques are 3x4 two-digit years, 7 px - exactly a cup's width - so a
    # 10 px pitch leaves 3 px between them (4x5 '07' '09' is 9 px and read
    # as one number); a crowded case drops them and packs at 8.
    pitch = 10
    if n * pitch + 1 > room:
        pitch = 8
    shown = min(n, (room - 4 + (pitch - 7)) // pitch)
    inner = shown * pitch - (pitch - 7)
    w = inner + 4
    x0 = x1 - w + 1
    c.rect(x0, CY, x1, CY + 11, outline = WOOD)
    c.rect(x0, CY + 11, x1, CY + 11, fill = SHELF)
    c.pixel(x0 + 1, CY + 1, GLASS)
    c.pixel(x0 + 1, CY + 2, GLASS)
    c.pixel(x0 + 2, CY + 1, GLASS)
    tx = x0 + 2
    k = 0
    for t in titles:
        art = LOMBARDI if t[0] == "SB" else CUP
        for yr in t[1]:
            if k >= shown:
                break
            c.sprite(art, tx, CY + 2, legend = {"X": TROPHY_COLOR[t[0]]})
            if pitch == 10:
                c.text(str(yr)[2:], tx, CY + 13, font = "3x4", color = PLAQUE)
            tx += pitch
            k += 1
    return pitch == 10

def resume(c, ctx):
    # team + AP poll + COACH_BUDGET; see the budget note at the top.
    d = load_school(c, ctx, COACH_BUDGET)
    if d == None:
        return
    sch, tm, co = d[0], d[1], d[2]
    ap = fetch_ap(sch)
    rec = co_record(tm)
    c.fill("black")
    sideline(c)

    titles = TITLES.get(co["id"], [])
    n_troph = 0
    for t in titles:
        n_troph += len(t[1])
    badge = ""
    arrow = None
    if ap != None:
        badge = "#" + str(ap[0]) + " AP"
        if ap[1] > 0 and ap[1] != ap[0]:
            arrow = ap[0] < ap[1]

    # What stands right of the board: the trophy case (one cup per title,
    # 8 px each when packed) or, with no titles, the coach himself.
    if n_troph > 0:
        limit = 185 - (n_troph * 8 + 3) - 4
    else:
        limit = 150
    limit = max(limit, 96)

    # This season on the scoreboard, x 6..bx1: a header in the school colour
    # ('2026 SEASON', then the standing when it fits whole), the record in
    # bulbs - amber, green while unbeaten, red once the losses lead by two -
    # and the AP rank as a gold badge with last week's move as an arrow.
    word = str(co["season"]) + " SEASON"
    side = 0
    if badge != "":
        side = 3 + pill_w(c, badge) + (7 if arrow != None else 0)
    rf = fit(c, rec, ["10x16", "9x12", "8x10"], limit - 3 - 9 - side)
    rw = c.text_width(rf[1], rf[0])
    hw = c.text_width(word, "4x5")
    st = tm["standing"]
    stw = c.text_width(st, "4x5") if st != "" else 0
    bx1 = max(9 + rw + side + 3, 9 + hw + 3)
    if st != "" and 9 + hw + 6 + stw + 3 <= limit:
        bx1 = max(bx1, 9 + hw + 6 + stw + 3)
    else:
        st = ""
    bx1 = min(limit, max(bx1, 70))
    scoreboard(c, 6, bx1, 25)
    c.rect(7, 1, bx1 - 1, 7, fill = tm["color"])
    hink = ink_for(tm["color"])
    c.text(word, 9, 2, font = "4x5", color = hink)
    if st != "":
        c.text(st, bx1 - 3, 2, font = "4x5", color = hink, align = "right")
    rcol = rec_color(rec)
    c.text(rf[1], 9, 9 + (15 - INKH[rf[0]]) // 2, font = rf[0], color = AMBER if rcol == INK else rcol)
    rx = 9 + rw + 3
    if badge != "":
        pill(c, badge, GOLD, rx, 14)
        rx += pill_w(c, badge) + 2
        if arrow != None:
            c.sprite(UP if arrow else DOWN, rx, 16, legend = {"X": GOOD if arrow else RED})

    if n_troph == 0:
        coach_sprite(c, (bx1 + 187) // 2 - 14, 2, tm, rec)
        return

    # Trophy case, right-aligned to x 185: one cup per title the COACH has
    # won as a head coach, and the credit line names him so Alabama is
    # never read as a three-time NAIA champion.
    trophy_case(c, titles, n_troph, 185, 185 - (bx1 + 4) + 1)
    # The credit line names the top level only ('4X NATL', not the FCS
    # titles behind them); the cups show the rest in their own colours.
    level = titles[0][0]
    n_top = len(titles[0][1])
    cnt = (str(n_top) + "X " if n_top > 1 else "")
    who = co["last"]
    room = 185 - (bx1 + 4) + 1
    for w in [who + " " + cnt + TITLE_WORD[level], who + " " + cnt + TITLE_SHORT[level],
              cnt + TITLE_WORD[level], cnt + TITLE_SHORT[level]]:
        if c.text_width(w, "4x5") <= room:
            c.text(w, 185, 23, font = "4x5", color = TROPHY_COLOR[level], align = "right")
            break
