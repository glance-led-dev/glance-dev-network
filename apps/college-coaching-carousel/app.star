# College Coaching Carousel
#
# Your school's head coach, live from ESPN, plus the longest-serving coaches
# in major college football.
#
#   coach    Who is running your program right now: the school logo, the
#            coach's name, his record at the school ('212-128 AT IOWA'), a
#            pixel-art coach in the school's kit and a tenure strip - one
#            pennant per season, this season lit. A new hire gets a sky NEW
#            HIRE chip and 'REPLACES MOORE' - the carousel story.
#   resume   This season's record as the hero, the AP rank as a gold badge
#            with last week's move as a green/red arrow, the conference
#            standing, and a wooden trophy case: one cup per championship the
#            coach has won as a head coach, in the colour of its level (gold
#            FBS, silver FCS, bronze D2/D3/NAIA, silver Lombardis for Bill
#            Belichick's six Super Bowls), each year on a plaque below.
#   tenure   The longest-tenured FBS head coaches, three at a time: logo,
#            rank (T-5 for ties), years in charge, surname, first season and
#            a bar scaled to Ferentz's 28 years; gold for the leader.
#
# DESIGN. Graphics first, in the sideline's own vernacular. The coach is a
# picture - visor in the school's second colour, polo in its first (so
# crimson Alabama in a white visor never reads as red Utah), headset,
# clipboard - and his collar is the season's mood: red on the hot seat, gold
# while unbeaten. The program is its logo. Tenure is counted in pennants,
# titles stand in a lit trophy case, rank is a badge with an arrow, and the
# tenure ladder is a bar chart of years. The words left are the ones only
# words can say: the name, the records, the years. One bold thing per page:
# the coach figure, the trophy case, the tenure bars. Black ground; school
# colours are lifted when ESPN's are too dark for an LED (Alabama crimson,
# navy blues).
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
# seasons, walked back year by year within the request budget, and shows
# SINCE rather than a record.
#
# Budget (8 uncached requests a render): coach = team + coach list (+ the
# coach's own record and the walk for an unknown coach, capped at 7);
# resume = team + AP poll + the same, capped at 6; tenure = 3, the three
# coaches of the frame on screen.

TEAM_URL = "https://site.web.api.espn.com/apis/site/v2/sports/football/college-football/teams/"
CORE = "https://sports.core.api.espn.com/v2/sports/football/leagues/college-football/"
AP_URL = CORE + "rankings/1"   # the current AP Top 25
HEADERS = {"User-Agent": "glance-college-coaching-carousel (glance-led.dev)"}

TEAM_TTL = 3600      # record, rank, standing: move once a week, checked hourly
STAFF_TTL = 21600    # who the head coach is
PAST_TTL = 2592000   # a past season's coach never changes

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

# Literal asset paths (the publish lint needs literals). L = 40 x 24 hero
# logos, S = 24 x 18 for the tenure ladder; filenames match the shared
# _logos set so polished logos re-sync by a straight copy, except Texas A&M
# (TAMU.png - '&' is not a legal asset name).
LOGO_L = {
    "AFA": "L/AFA.png",
    "AKR": "L/AKR.png",
    "ALA": "L/ALA.png",
    "APP": "L/APP.png",
    "ARIZ": "L/ARIZ.png",
    "ARK": "L/ARK.png",
    "ARMY": "L/ARMY.png",
    "ARST": "L/ARST.png",
    "ASU": "L/ASU.png",
    "AUB": "L/AUB.png",
    "BALL": "L/BALL.png",
    "BAY": "L/BAY.png",
    "BC": "L/BC.png",
    "BGSU": "L/BGSU.png",
    "BOIS": "L/BOIS.png",
    "BUFF": "L/BUFF.png",
    "BYU": "L/BYU.png",
    "CAL": "L/CAL.png",
    "CCU": "L/CCU.png",
    "CIN": "L/CIN.png",
    "CLEM": "L/CLEM.png",
    "CLT": "L/CLT.png",
    "CMU": "L/CMU.png",
    "COLO": "L/COLO.png",
    "CONN": "L/CONN.png",
    "CSU": "L/CSU.png",
    "DEL": "L/DEL.png",
    "DUKE": "L/DUKE.png",
    "ECU": "L/ECU.png",
    "EMU": "L/EMU.png",
    "FAU": "L/FAU.png",
    "FIU": "L/FIU.png",
    "FLA": "L/FLA.png",
    "FRES": "L/FRES.png",
    "FSU": "L/FSU.png",
    "GASO": "L/GASO.png",
    "GAST": "L/GAST.png",
    "GT": "L/GT.png",
    "HAW": "L/HAW.png",
    "HOU": "L/HOU.png",
    "ILL": "L/ILL.png",
    "IOWA": "L/IOWA.png",
    "ISU": "L/ISU.png",
    "IU": "L/IU.png",
    "JMU": "L/JMU.png",
    "JXST": "L/JXST.png",
    "KENN": "L/KENN.png",
    "KENT": "L/KENT.png",
    "KSU": "L/KSU.png",
    "KU": "L/KU.png",
    "LIB": "L/LIB.png",
    "LOU": "L/LOU.png",
    "LSU": "L/LSU.png",
    "LT": "L/LT.png",
    "M-OH": "L/M-OH.png",
    "MASS": "L/MASS.png",
    "MD": "L/MD.png",
    "MEM": "L/MEM.png",
    "MIA": "L/MIA.png",
    "MICH": "L/MICH.png",
    "MINN": "L/MINN.png",
    "MISS": "L/MISS.png",
    "MIZ": "L/MIZ.png",
    "MOST": "L/MOST.png",
    "MRSH": "L/MRSH.png",
    "MSST": "L/MSST.png",
    "MSU": "L/MSU.png",
    "MTSU": "L/MTSU.png",
    "NAVY": "L/NAVY.png",
    "NCSU": "L/NCSU.png",
    "ND": "L/ND.png",
    "NDSU": "L/NDSU.png",
    "NEB": "L/NEB.png",
    "NEV": "L/NEV.png",
    "NIU": "L/NIU.png",
    "NMSU": "L/NMSU.png",
    "NU": "L/NU.png",
    "ODU": "L/ODU.png",
    "OHIO": "L/OHIO.png",
    "OKST": "L/OKST.png",
    "ORE": "L/ORE.png",
    "ORST": "L/ORST.png",
    "OSU": "L/OSU.png",
    "OU": "L/OU.png",
    "PITT": "L/PITT.png",
    "PSU": "L/PSU.png",
    "PUR": "L/PUR.png",
    "RICE": "L/RICE.png",
    "RUTG": "L/RUTG.png",
    "SAC": "L/SAC.png",
    "SC": "L/SC.png",
    "SDSU": "L/SDSU.png",
    "SHSU": "L/SHSU.png",
    "SJSU": "L/SJSU.png",
    "SMU": "L/SMU.png",
    "STAN": "L/STAN.png",
    "SYR": "L/SYR.png",
    "TA&M": "L/TAMU.png",
    "TCU": "L/TCU.png",
    "TEM": "L/TEM.png",
    "TENN": "L/TENN.png",
    "TEX": "L/TEX.png",
    "TLSA": "L/TLSA.png",
    "TOL": "L/TOL.png",
    "TROY": "L/TROY.png",
    "TTU": "L/TTU.png",
    "TULN": "L/TULN.png",
    "TXST": "L/TXST.png",
    "UAB": "L/UAB.png",
    "UCF": "L/UCF.png",
    "UCLA": "L/UCLA.png",
    "UGA": "L/UGA.png",
    "UK": "L/UK.png",
    "UL": "L/UL.png",
    "ULM": "L/ULM.png",
    "UNC": "L/UNC.png",
    "UNLV": "L/UNLV.png",
    "UNM": "L/UNM.png",
    "UNT": "L/UNT.png",
    "USA": "L/USA.png",
    "USC": "L/USC.png",
    "USF": "L/USF.png",
    "USM": "L/USM.png",
    "USU": "L/USU.png",
    "UTAH": "L/UTAH.png",
    "UTEP": "L/UTEP.png",
    "UTSA": "L/UTSA.png",
    "UVA": "L/UVA.png",
    "VAN": "L/VAN.png",
    "VT": "L/VT.png",
    "WAKE": "L/WAKE.png",
    "WASH": "L/WASH.png",
    "WIS": "L/WIS.png",
    "WKU": "L/WKU.png",
    "WMU": "L/WMU.png",
    "WSU": "L/WSU.png",
    "WVU": "L/WVU.png",
    "WYO": "L/WYO.png",
}
LOGO_S = {
    "IOWA": "S/IOWA.png",
    "AFA": "S/AFA.png",
    "CLEM": "S/CLEM.png",
    "NCSU": "S/NCSU.png",
    "ARMY": "S/ARMY.png",
    "EMU": "S/EMU.png",
    "M-OH": "S/M-OH.png",
    "PITT": "S/PITT.png",
    "UGA": "S/UGA.png",
    "BYU": "S/BYU.png",
    "MINN": "S/MINN.png",
    "MD": "S/MD.png",
    "OSU": "S/OSU.png",
    "WKU": "S/WKU.png",
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
# Rate Bowl), and they show SINCE instead. The live season is added on top
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

# The longest-tenured FBS coaches, oldest first: [abbr, coach id, first
# season, surname]. Every 2026 FBS coach who started before 2020 is here.
# Ranks come from this list (ties share one, shown T-5); the page checks
# only the three coaches it is about to draw against ESPN's current staff
# and drops any who has left.
TENURE = [
    ["IOWA", "559972", 1999, "FERENTZ"],
    ["AFA", "559873", 2007, "CALHOUN"],
    ["CLEM", "2331668", 2008, "SWINNEY"],
    ["NCSU", "2574258", 2013, "DOEREN"],
    ["ARMY", "2496595", 2014, "MONKEN"],
    ["EMU", "2518896", 2014, "CREIGHTON"],
    ["M-OH", "3083495", 2014, "MARTIN"],
    ["PITT", "3164111", 2015, "NARDUZZI"],
    ["UGA", "3960423", 2016, "SMART"],
    ["BYU", "2026707", 2016, "SITAKE"],
    ["MINN", "124316", 2017, "FLECK"],
    ["MD", "2331935", 2019, "LOCKSLEY"],
    ["OSU", "4369610", 2019, "DAY"],
    ["WKU", "4407282", 2019, "HELTON"],
]
# Abbr -> ESPN team id for the tenure candidates.
TENURE_TEAM = {
    "AFA": "2005",
    "ARMY": "349",
    "BYU": "252",
    "CLEM": "228",
    "EMU": "2199",
    "IOWA": "2294",
    "M-OH": "193",
    "MD": "120",
    "MINN": "135",
    "NCSU": "152",
    "OSU": "194",
    "PITT": "221",
    "UGA": "61",
    "WKU": "98",
}

# --------------------------------------------------------------- pixel art
# The coach, 22 x 24: V visor (the school's second colour, so crimson
# Alabama wears a white visor and does not look like red Utah), v brim
# shade, S skin, s skin shade, H headset band/cup, M mic, P polo (school
# colour), p polo shade, L collar and crest (the momentum trim: red once the
# losses lead by two, gold while unbeaten), C clipboard, W paper, K khakis,
# k khaki shade, B shoes.
COACH = """
......VVVVVV..........
.....VVVVVVVV.........
....HVVVVVVVVvvvv.....
....HSSSSSSSS.........
...HHSSSSSSSSS........
...HHSS.SS.SSS........
....HSSSSSSSSS........
....HMSSSSSSSs........
.....MMSSsSSs.........
.......SSSSS..........
.....PPLLLLLLPP.......
....PPPPLPPPPPPPP.....
...PPPPPLPPPPPPPPPP...
...PPpPPPPPPPPPCCCCC..
...PPpPPPPPPPPCWWWWWC.
...SSpPPPPPPPPCWWWWWC.
...SS.PPPPPPPPCWSWWWC.
......PPPPPPPPSCWWWWC.
......KKKKKKKK.CCCCC..
......KKKKkKKK........
......KKK..kKK........
......KKK..kKK........
.....BBBB..BBBB.......
.....BBBB..BBBBB......
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
# 5 x 7 pennant, one per season in the tenure strip.
PENNANT = """
X....
XXX..
XXXXX
XXX..
X....
X....
X....
"""
# 9 x 9 stopwatch for the tenure page.
WATCH = """
...XXX...
....X....
..XXXXX..
.X..W..X.
X...W...X
X...WW..X
X.......X
.X.....X.
..XXXXX..
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

def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

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
def school_mark(c, sch, tm):
    """The 40 x 24 logo at x 6..45, closed off at x 48..49 by a two-tone bar."""
    c.image(LOGO_L[sch["abbr"]], 6, 4)
    c.rect(48, 0, 48, 31, fill = tm["color"])
    c.rect(49, 0, 49, 31, fill = tm["alt"] if tm["alt"] != tm["color"] else DIM)

def coach_sprite(c, x, y, tm, rec):
    polo = tm["color"]
    visor = tm["alt"] if tm["alt"] != polo else INK
    state = rec_color(rec)
    trim = RED if state == RED else (GOLD if state == GOOD else visor)
    leg = {"V": visor, "v": color.dim(visor, 60), "S": "#E8B48A", "s": "#B9825C", "H": "#3A4150",
           "M": "#9AA3B2", "P": polo, "p": color.dim(polo, 60), "L": trim, "C": "#8B5A2B",
           "W": "#F4F7FF", "K": "#C8B48A", "k": "#9C8A64", "B": "#2A2E38"}
    c.sprite(COACH, x, y, legend = leg)

def fail_screen(c, head, sub):
    c.fill("black")
    rail(c, OFFLINE)
    c.sprite(CUP, 12, 11, legend = {"X": DIM})
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 160)
    c.text(hf[1], 108, 8, font = hf[0], color = AMBER, align = "center")
    sf = fit(c, sub, ["4x5"], 160)
    c.text(sf[1], 108, 21, font = sf[0], color = DIM, align = "center")

def quiet_screen(c, sch, head, sub):
    """No coach on file is an answer, not an outage: green and calm."""
    c.fill("black")
    rail(c, GOOD)
    c.image(LOGO_L[sch["abbr"]], 6, 4)
    hf = fit(c, head, ["6x8", "5x7", "4x5"], 128)
    c.text(hf[1], 118, 8, font = hf[0], color = GOOD, align = "center")
    sf = fit(c, sub, ["4x5"], 128)
    c.text(sf[1], 118, 21, font = sf[0], color = DIM, align = "center")

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
            quiet_screen(c, sch, "NO HEAD COACH ON FILE", "ESPN LISTS NONE FOR " + sch["label"])
        else:
            fail_screen(c, "ESPN OFFLINE", "CHECKING AGAIN SOON")
        return None
    return [sch, tm, co]

# Text zone between the team bar and the coach sprite, whose leftmost lit
# columns (headset, elbow) are x 167 when drawn at x 164. TR 165 left one
# pixel and 'JEFF LEBBY' read as touching the headset; 3 px reads as air.
TX = 53
TR = 163
TW = TR - TX + 1

# --------------------------------------------------------------- page: coach
def coach(c, ctx):
    # team + up to 7 = the 8-request cap.
    d = load_school(c, ctx, 7)
    if d == None:
        return
    sch, tm, co = d[0], d[1], d[2]
    c.fill("black")
    school_mark(c, sch, tm)
    coach_sprite(c, 164, 8, tm, co_record(tm))

    year = co["season"] - co["since"] + 1
    new = year <= 1
    since = "SINCE " + str(co["since"])
    sw = c.text_width(since, "4x5")

    # Chip row. New hire: the sky NEW HIRE pill. Otherwise the fan's
    # question - his record here, '212-128 AT IOWA' - with SINCE only when
    # it still fits ('212-128 AT IOWA' is 67 px, so Ferentz drops it; his
    # YEAR 28 below says the same). No verified record: the HEAD COACH pill.
    if new:
        pill(c, "NEW HIRE", SKY, TX, 0)
    else:
        car = career_record(co, tm)
        if car != "":
            tail = " AT " + sch["abbr"]
            c.text(car, TX, 1, font = "4x5", color = INK)
            x = TX + c.text_width(car, "4x5")
            c.text(tail, x, 1, font = "4x5", color = DIM)
            if x + c.text_width(tail, "4x5") + 5 <= TR - sw:
                c.text(since, TR, 1, font = "4x5", color = DIM, align = "right")
        else:
            pw = pill(c, "HEAD COACH", tm["color"], TX, 0)
            if TX + pw + 3 <= TR - sw:
                c.text(since, TR, 1, font = "4x5", color = DIM, align = "right")

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

    # Strip y 25..31. A new hire: his one gold pennant and the man he
    # replaced - the carousel story. Otherwise 'YEAR N' and one pennant per
    # season, this one lit; a long tenure shrinks them to 2 px posts so
    # Ferentz's 28 still fit, and the count is always in the label.
    if new:
        c.sprite(PENNANT, TX, 25, legend = {"X": GOLD})
        x = TX + 9
        prev = PREV.get(co["id"], "")
        if prev != "" and c.text_width("REPLACES " + prev, "4x5") <= TR - x + 1:
            c.text("REPLACES", x, 26, font = "4x5", color = DIM)
            c.text(prev, x + c.text_width("REPLACES ", "4x5"), 26, font = "4x5", color = INK)
        else:
            c.text("YEAR 1", x, 26, font = "4x5", color = INK)
        return
    label = "YEAR " + str(year)
    c.text(label, TX, 26, font = "4x5", color = GOLD if year >= 10 else INK)
    x0 = TX + c.text_width(label, "4x5") + 4
    room = TR - x0 + 1
    if year * 6 <= room:
        for i in range(year):
            col = GOLD if i == year - 1 else tm["color"]
            c.sprite(PENNANT, x0 + i * 6, 25, legend = {"X": col})
    else:
        step = 3 if year * 3 <= room else 2
        n = min(year, room // step)
        for i in range(n):
            col = GOLD if i == n - 1 else tm["color"]
            c.rect(x0 + i * step, 25, x0 + i * step, 31, fill = col)
            c.pixel(x0 + i * step + 1, 25, col)

# -------------------------------------------------------------- page: resume
# The trophy case: a wooden cabinet, cups on the shelf, and each title's
# year on a plaque under its cup.
WOOD = "#8A5A2E"
SHELF = "#C8904E"
GLASS = "#2E3A52"
PLAQUE = "#9AA3B2"

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
    c.rect(x0, 8, x1, 19, outline = WOOD)
    c.rect(x0, 19, x1, 19, fill = SHELF)
    c.pixel(x0 + 1, 9, GLASS)
    c.pixel(x0 + 1, 10, GLASS)
    c.pixel(x0 + 2, 9, GLASS)
    tx = x0 + 2
    k = 0
    for t in titles:
        art = LOMBARDI if t[0] == "SB" else CUP
        for yr in t[1]:
            if k >= shown:
                break
            c.sprite(art, tx, 10, legend = {"X": TROPHY_COLOR[t[0]]})
            if pitch == 10:
                c.text(str(yr)[2:], tx, 21, font = "3x4", color = PLAQUE)
            tx += pitch
            k += 1
    return pitch == 10

def resume(c, ctx):
    # team + AP poll + up to 6 = the 8-request cap.
    d = load_school(c, ctx, 6)
    if d == None:
        return
    sch, tm, co = d[0], d[1], d[2]
    ap = fetch_ap(sch)
    c.fill("black")
    school_mark(c, sch, tm)

    # Chip row: the season pill, the conference standing right-aligned
    # ('1ST IN SEC'), measured first so the pill never runs into it.
    word = str(co["season"]) + " SEASON"
    pw = pill_w(c, word)
    if tm["standing"] != "":
        sf = fit(c, tm["standing"], ["4x5"], 185 - (TX + pw + 4) + 1)
        c.text(sf[1], 185, 1, font = "4x5", color = INK, align = "right")
    pill(c, word, tm["color"], TX, 0)

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
    side = 0
    if badge != "":
        side = pill_w(c, badge) + 4 + (6 if arrow != None else 0)
    if n_troph > 0:
        side += n_troph * 8 + 3

    # Record hero: W-L under a SEASON pill needs no other label. It gets
    # what the badge and a packed trophy case leave (Belichick's six
    # Lombardis beside '#12 AP' take 85 px), stepping down a face rather
    # than pushing a cup off the shelf.
    rec = co_record(tm)
    rf = fit(c, rec, ["16x20", "10x16", "9x12", "8x10"], min(70, 185 - side - 5 - TX + 1))
    ry = 9 if rf[0] == "16x20" else 11
    c.text(rf[1], TX, ry, font = rf[0], color = rec_color(rec))
    rec_end = TX + c.text_width(rf[1], rf[0])
    rx = rec_end + 5

    # AP rank: a gold '#8 AP' badge with last week's move as an arrow
    # (green up, red down); unranked says nothing rather than 'NR'.
    if badge != "":
        pill(c, badge, GOLD, rx, 14)
        rx += pill_w(c, badge) + 2
        if arrow != None:
            c.sprite(UP if arrow else DOWN, rx, 16, legend = {"X": GOOD if arrow else RED})
            rx += 6
        rx += 2

    if n_troph == 0:
        coach_sprite(c, 164, 8, tm, rec)
        return

    # Trophy case, right-aligned to x 185: one cup per title the COACH has
    # won as a head coach, and the credit line names him so Alabama is
    # never read as a three-time NAIA champion.
    trophy_case(c, titles, n_troph, 185, 185 - rx + 1)
    # The credit line names the top level only ('4X NATL', not the FCS
    # titles behind them); the cups show the rest in their own colours.
    level = titles[0][0]
    n_top = len(titles[0][1])
    cnt = (str(n_top) + "X " if n_top > 1 else "")
    who = co["last"]
    room = 185 - (rec_end + 4) + 1
    for w in [who + " " + cnt + TITLE_WORD[level], who + " " + cnt + TITLE_SHORT[level],
              cnt + TITLE_WORD[level], cnt + TITLE_SHORT[level]]:
        if c.text_width(w, "4x5") <= room:
            c.text(w, 185, 27, font = "4x5", color = TROPHY_COLOR[level], align = "right")
            break

# -------------------------------------------------------------- page: tenure
def tenure_ranks():
    """Static ranks from TENURE's first seasons: [rank, tied]."""
    out = []
    for t in TENURE:
        ahead = 0
        same = 0
        for u in TENURE:
            if u[2] < t[2]:
                ahead += 1
            elif u[2] == t[2]:
                same += 1
        out.append([ahead + 1, same > 1])
    return out

def tenure(c, ctx):
    season = season_now(ctx)
    mine = school_pick(ctx)["abbr"]
    frames = (len(TENURE) + 2) // 3
    f = (ctx.now.unix // 900) % frames
    ranks = tenure_ranks()

    # Only this frame's three coaches are checked (3 requests): each must
    # still be the coach ESPN lists at his school, or he is left out.
    rows = []
    offline = False
    for k in range(f * 3, min(f * 3 + 3, len(TENURE))):
        t = TENURE[k]
        r = http.get(CORE + "seasons/" + str(season) + "/teams/" + TENURE_TEAM[t[0]] + "/coaches",
                     headers = HEADERS, ttl_seconds = STAFF_TTL)
        if r["status_code"] == 0:
            offline = True
            break
        if r["status_code"] != 200 or type(r["json"]) != "dict":
            continue
        items = get(r["json"], "items", [])
        if len(items) == 0 or coach_id_of(get(items[0], "$ref", "")) != t[1]:
            continue
        rows.append(k)
    if len(rows) == 0:
        if offline:
            fail_screen(c, "ESPN OFFLINE", "CHECKING AGAIN SOON")
        else:
            fail_screen(c, "NO TENURE DATA", "CHECKING AGAIN SOON")
        return

    c.fill("black")
    # Left header x 6..45: stopwatch over 'LONGEST / TENURED / FBS HCS'.
    c.sprite(WATCH, 6, 1, legend = {"X": GOLD, "W": INK})
    c.text(str(f + 1) + "/" + str(frames), 45, 3, font = "4x5", color = DIM, align = "right")
    c.text("LONGEST", 6, 13, font = "4x5", color = INK)
    c.text("TENURED", 6, 19, font = "4x5", color = INK)
    c.text("FBS HCS", 6, 25, font = "4x5", color = DIM)
    c.rect(48, 2, 48, 29, fill = "#2A3040")

    # Three 44 px slots from x 52: logo with the rank and years in charge
    # beside it, then surname and first season; a gold tenure bar under
    # each, its length the years in charge against Ferentz's.
    top = season - TENURE[0][2] + 1
    for i in range(len(rows)):
        k = rows[i]
        t = TENURE[k]
        # A short frame is centred in the ladder rather than left hanging.
        x = 52 + i * 45 + (3 - len(rows)) * 22
        lead = ranks[k][0] == 1
        me = t[0] == mine
        yrs = season - t[2] + 1
        c.image(LOGO_S[t[0]], x, 1)
        rk = ("T-" if ranks[k][1] else "#") + str(ranks[k][0])
        # 'T-12' is 23 px in 5x7 and ran into the logo (x + 0..23); the rank
        # gets x + 25..43, so a long one drops to 4x5.
        rf = fit(c, rk, ["5x7", "4x5"], 18)
        c.text(rf[1], x + 43, 2 if rf[0] == "5x7" else 3, font = rf[0], color = GOLD if lead else INK, align = "right")
        c.text(str(yrs) + "Y", x + 43, 11, font = "4x5", color = DIM, align = "right")
        nm = fit(c, t[3], ["4x5"], 43)
        c.text(nm[1], x, 20, font = "4x5", color = GOLD if me else INK)
        c.text(str(t[2]), x, 26, font = "4x5", color = GOLD if lead else DIM)
        # Tenure bar x + 20..43 after the year ('2019' is 16 px wide): 24 px
        # is Ferentz's run, everyone else to scale, so the ladder shows the
        # gap between 28 years and 8 at a glance.
        bw = max(2, (24 * yrs) // top)
        c.rect(x + 20, 27, x + 19 + bw, 29, fill = GOLD if lead else "#9AA3B2")
        if me:
            c.rect(x, 31, x + 42, 31, fill = GOLD)
