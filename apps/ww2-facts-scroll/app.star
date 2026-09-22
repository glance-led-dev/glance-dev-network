# WW2 Facts - one dated entry from the Second World War every day.
#
# DESIGN. This is a museum placard, not a war poster. The panel answers four
# questions in the order a placard does: WHAT and WHEN (page 1), WHY IT
# MATTERED (page 2), WHERE IN THE WAR IT SITS (page 3). Nothing animates,
# nothing shouts, and no page carries a number without the words that say
# what the number counts.
#
# The one piece of chrome that does the heavy lifting is COLOUR BY FRONT.
# Every entry belongs to one of ten fronts, each with its own colour and its
# own drawing - a fighter for Western Europe, a tank for the Eastern Front, a
# carrier for the Pacific, a convoy escort for the Atlantic, rotors for the
# codebreakers, a flame for remembrance. The accent rail at x0-1, the page
# chip, the timeline marker and the artwork all wear that one colour, so the
# front is legible from across a room before a single word is read.
#
# REMEMBRANCE entries - the Holocaust, Babi Yar, Katyn, Nanjing, Auschwitz,
# Hiroshima, the famines, the death marches - are drawn in bone white with a
# memorial flame, never in a front colour, and never with a weapon beside
# them. They state the date, the place and the scale, and stop. Omitting them
# would misrepresent the war, so they are in; sensationalising them would
# misrepresent it differently, so the text is written the way a memorial
# museum writes a wall panel. Where a figure is an estimate or is contested
# by historians, the panel says so rather than printing a false precision.
#
# DATA. A curated table, written and checked by hand against the Wikipedia
# article prose for each event. Live lookups were tested and rejected for the
# core facts: they carry no reliable date for a large share of historical
# events, and several dates they do carry describe a predecessor rather than
# the event named. So pages 1 and 2 touch the network never - the panel
# cannot go blank. Page 3 alone adds one supplementary line from Wikipedia's
# REST summary endpoint, and falls back to a curated line of its own if the
# request fails, if the viewer turns it off, or if the API silently redirects
# the title somewhere generic (which it does, so the response is checked
# against the title that was asked for before a word of it is drawn).
#
# ROTATION. The house idiom: one entry per day from ctx.now.yday, with the
# year term shifting where the sequence starts so the same date does not land
# on the same entry every year.
#
# Every string drawn on this panel goes through safe(), because the bundled
# fonts are uppercase-only and carry no apostrophe and no quotation mark -
# and history text is made of apostrophes. Accented letters fold to ASCII
# rather than vanishing, so NUREMBERG stays NUREMBERG and does not become
# NREMBERG.

WIKI_URL = "https://en.wikipedia.org/api/rest_v1/page/summary/"
UA = {"User-Agent": "glance-ww2-facts (glance-led.dev)"}
TTL = 86400

# ------------------------------------------------------------------ palette
INK = "#F4F7FF"
DIM = "#79849C"
FAINT = "#262D3C"
STRUCT = "#404A5E"

# One colour per front. Separated around the hue wheel rather than shaded,
# because RGB565 collapses close neighbours and these have to be told apart
# at ten feet.
FRONT_COLOR = {
    "EUROPE": "#4EA3FF",     # sky blue - the air and land war in the west
    "EAST": "#E03C3C",       # red - the German-Soviet war
    "PACIFIC": "#12C08E",    # green-teal - the ocean war
    "AFRICA": "#E8A33D",     # sand
    "ATLANTIC": "#9B7BE8",   # violet - the convoy war
    "HOME": "#E86AB0",       # pink - the home fronts
    "SCIENCE": "#00D4E8",    # cyan - codebreaking and technology
    "INDUSTRY": "#A8B0C0",   # steel - production and logistics
    "MEMORIAL": "#DCD6C8",   # bone - remembrance. never a bright colour
    "SUMMIT": "#8FBF5A",     # olive - conferences, pacts and trials
}

FRONT_CHIP = {
    "EUROPE": "EUROPE",
    "EAST": "EAST FRONT",
    "PACIFIC": "PACIFIC",
    "AFRICA": "AFRICA",
    "ATLANTIC": "ATLANTIC",
    "HOME": "HOME FRONT",
    "SCIENCE": "SCIENCE",
    "INDUSTRY": "INDUSTRY",
    "MEMORIAL": "MEMORIAL",
    "SUMMIT": "SUMMIT",
}

# The dropdown speaks in plain language; the table speaks in codes.
FRONT_PICK = {
    "WESTERN EUROPE": "EUROPE",
    "EASTERN FRONT": "EAST",
    "PACIFIC & ASIA": "PACIFIC",
    "NORTH AFRICA": "AFRICA",
    "ATLANTIC & SEA": "ATLANTIC",
    "HOME FRONT": "HOME",
    "SCIENCE & CODE": "SCIENCE",
    "WAR PRODUCTION": "INDUSTRY",
    "REMEMBRANCE": "MEMORIAL",
    "CONFERENCES": "SUMMIT",
}

MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

FONTH = {"10x16": 16, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7,
         "4x5": 5, "picopixel": 5}

# ------------------------------------------------------------------- glyphs
# Exactly what the bundled fonts can draw. Anything else is folded to this or
# dropped, because a missing glyph draws as nothing and silently eats the
# letter next to it.
ALLOWED = " !#$%&()*+,-./0123456789:?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Folded BEFORE the filter, and by whole-string replace rather than per
# character, so a multi-byte letter is handled whatever .elems() does with it.
FOLD = [
    ["A", "A"],
    ["Á", "A"], ["À", "A"], ["Â", "A"], ["Ä", "A"],
    ["Ã", "A"], ["Å", "A"], ["á", "A"], ["à", "A"],
    ["â", "A"], ["ä", "A"], ["ã", "A"], ["å", "A"],
    ["É", "E"], ["È", "E"], ["Ê", "E"], ["Ë", "E"],
    ["é", "E"], ["è", "E"], ["ê", "E"], ["ë", "E"],
    ["Í", "I"], ["Ì", "I"], ["Î", "I"], ["Ï", "I"],
    ["í", "I"], ["ì", "I"], ["î", "I"], ["ï", "I"],
    ["Ó", "O"], ["Ò", "O"], ["Ô", "O"], ["Ö", "O"],
    ["Õ", "O"], ["Ø", "O"], ["ó", "O"], ["ò", "O"],
    ["ô", "O"], ["ö", "O"], ["õ", "O"], ["ø", "O"],
    ["Ú", "U"], ["Ù", "U"], ["Û", "U"], ["Ü", "U"],
    ["ú", "U"], ["ù", "U"], ["û", "U"], ["ü", "U"],
    ["Ñ", "N"], ["ñ", "N"], ["Ç", "C"], ["ç", "C"],
    ["Ý", "Y"], ["ý", "Y"], ["ß", "SS"],
    ["Æ", "AE"], ["æ", "AE"], ["Œ", "OE"], ["œ", "OE"],
    ["Ł", "L"], ["ł", "L"], ["Ż", "Z"], ["ż", "Z"],
    ["Ź", "Z"], ["ź", "Z"], ["Ś", "S"], ["ś", "S"],
    ["Č", "C"], ["č", "C"], ["Š", "S"], ["š", "S"],
    ["Ž", "Z"], ["ž", "Z"], ["Ř", "R"], ["ř", "R"],
    ["Ě", "E"], ["ě", "E"], ["Ů", "U"], ["ů", "U"],
    ["Ą", "A"], ["ą", "A"], ["Ę", "E"], ["ę", "E"],
    ["Ć", "C"], ["ć", "C"], ["Ń", "N"], ["ń", "N"],
    ["Ő", "O"], ["ő", "O"], ["Ű", "U"], ["ű", "U"],
    # Punctuation the fonts do not carry, mapped to something they do.
    ["–", "-"], ["—", "-"], ["−", "-"], ["‐", "-"],
    ["‘", ""], ["’", ""], ["“", ""], ["”", ""],
    ["'", ""], ["\"", ""], ["`", ""],
    ["…", "..."], ["·", "-"], ["•", "-"], [" ", " "],
    [";", ","], ["_", " "], ["[", "("], ["]", ")"], ["{", "("], ["}", ")"],
    ["=", "-"], ["<", "("], [">", ")"], ["|", "-"], ["\\", "/"], ["^", ""],
    ["~", "-"],
]

def safe(s):
    """Every string drawn on this panel comes through here."""
    t = str(s)
    for pair in FOLD:
        t = t.replace(pair[0], pair[1])
    t = t.upper()
    out = ""
    for ch in t.elems():
        if ALLOWED.find(ch) >= 0:
            out += ch
    return out

# ------------------------------------------------------------- the roster
# (front, year, month, day, title, place, why it mattered, stat, extra note,
#  wikipedia article title)
#
# Dates and figures were checked against the prose of the English Wikipedia
# article named in the last field. Where historians disagree, the panel
# carries the range and the note says it is contested - see README.md, which
# lists every entry whose figure is an estimate.
TH = 0
YR = 1
MO = 2
DY = 3
TI = 4
PL = 5
FA = 6
ST = 7
NO = 8
WK = 9

ENTRIES = [
    # ------------------------------------------------- the run-up, 1937-39
    ("PACIFIC", 1937, 7, 7, "WAR COMES TO CHINA", "MARCO POLO BRIDGE, CHINA",
     "A CLASH OUTSIDE BEIJING OPENED JAPANS FULL WAR ON CHINA.",
     "8 YEARS OF WAR",
     "CHINA FOUGHT LONGER THAN ANY OTHER ALLIED NATION.",
     "Marco_Polo_Bridge_Incident"),
    ("MEMORIAL", 1937, 12, 13, "THE NANJING MASSACRE", "NANJING, CHINA",
     "JAPANESE FORCES KILLED CIVILIANS AND PRISONERS OVER SIX WEEKS.",
     "TOLL DISPUTED",
     "ESTIMATES RANGE FROM 40,000 TO OVER 200,000. CHINA CITES 300,000.",
     "Nanjing_Massacre"),
    ("MEMORIAL", 1938, 11, 9, "KRISTALLNACHT", "GERMANY AND AUSTRIA",
     "A STATE ORGANISED POGROM BURNED SYNAGOGUES AND LOOTED JEWISH SHOPS.",
     "30,000 ARRESTED",
     "OVER 1,400 SYNAGOGUES WERE DESTROYED IN TWO NIGHTS.",
     "Kristallnacht"),
    ("SUMMIT", 1938, 9, 30, "THE MUNICH AGREEMENT", "MUNICH, GERMANY",
     "BRITAIN AND FRANCE GAVE CZECH BORDERLANDS TO HITLER TO AVOID WAR.",
     "4 POWERS",
     "CZECHOSLOVAKIA WAS NOT INVITED TO THE TALKS THAT DIVIDED IT.",
     "Munich_Agreement"),
    ("HOME", 1938, 12, 2, "THE KINDERTRANSPORT", "GERMANY TO BRITAIN",
     "BRITAIN TOOK IN REFUGEE CHILDREN FROM NAZI CONTROLLED EUROPE.",
     "10,000 CHILDREN",
     "MOST OF THE CHILDREN NEVER SAW THEIR PARENTS AGAIN.",
     "Kindertransport"),
    ("SCIENCE", 1938, 8, 1, "CHAIN HOME RADAR", "EAST COAST, BRITAIN",
     "A RADAR CHAIN GAVE EARLY WARNING OF RAIDS CROSSING THE CHANNEL.",
     "21 STATIONS",
     "IT LET A SMALLER FIGHTER FORCE BE IN THE RIGHT PLACE AT THE RIGHT TIME.",
     "Chain_Home"),
    ("SUMMIT", 1939, 8, 23, "THE NAZI SOVIET PACT", "MOSCOW, USSR",
     "GERMANY AND THE USSR AGREED NOT TO FIGHT, AND SECRETLY SPLIT POLAND.",
     "SECRET PROTOCOL",
     "THE PROTOCOL DIVIDING EASTERN EUROPE WAS DENIED FOR FIFTY YEARS.",
     "Molotov-Ribbentrop_Pact"),
    ("SCIENCE", 1939, 8, 15, "BLETCHLEY PARK OPENS", "BUCKINGHAMSHIRE, BRITAIN",
     "BRITAINS CODEBREAKING CENTRE BEGAN WORK WEEKS BEFORE THE WAR.",
     "9,000 STAFF",
     "AT ITS PEAK NEARLY THREE QUARTERS OF THE STAFF WERE WOMEN.",
     "Bletchley_Park"),

    # ------------------------------------------------------- 1939 and 1940
    ("EUROPE", 1939, 9, 1, "GERMANY INVADES POLAND", "POLAND",
     "GERMAN FORCES CROSSED THE POLISH BORDER BEFORE DAWN.",
     "35 DAY CAMPAIGN",
     "THE WAR IN EUROPE BEGAN HERE AND RAN FOR SIX YEARS.",
     "Invasion_of_Poland"),
    ("EUROPE", 1939, 9, 3, "BRITAIN DECLARES WAR", "LONDON AND PARIS",
     "BRITAIN AND FRANCE DECLARED WAR TWO DAYS AFTER POLAND WAS INVADED.",
     "11:00 AM",
     "THE BRITISH ULTIMATUM EXPIRED AT 11 AM. FRANCE FOLLOWED THAT EVENING.",
     "Declarations_of_war_during_World_War_II"),
    ("EAST", 1939, 9, 17, "THE SOVIET INVASION", "EASTERN POLAND",
     "THE RED ARMY ENTERED POLAND FROM THE EAST UNDER THE SECRET PACT.",
     "320,000 CAPTURED",
     "POLAND WAS PARTITIONED BETWEEN GERMANY AND THE SOVIET UNION.",
     "Soviet_invasion_of_Poland"),
    ("EAST", 1939, 11, 30, "THE WINTER WAR", "FINLAND",
     "THE USSR INVADED FINLAND AND MET FAR STIFFER RESISTANCE THAN EXPECTED.",
     "105 DAYS",
     "FINLAND CEDED A TENTH OF ITS LAND BUT KEPT ITS INDEPENDENCE.",
     "Winter_War"),
    ("HOME", 1940, 1, 8, "RATIONING BEGINS", "BRITAIN",
     "BRITAIN RATIONED FOOD, FUEL AND CLOTHING TO SHARE A SHRINKING SUPPLY.",
     "LASTED 14 YEARS",
     "SOME RATIONING IN BRITAIN WAS NOT LIFTED UNTIL 1954.",
     "Rationing_in_the_United_Kingdom"),
    ("SCIENCE", 1940, 3, 18, "THE BOMBE", "BLETCHLEY PARK, BRITAIN",
     "AN ELECTROMECHANICAL MACHINE SEARCHED ENIGMA SETTINGS EVERY DAY.",
     "CODENAME ULTRA",
     "ITS OUTPUT WAS CODENAMED ULTRA AND STAYED SECRET FOR 30 YEARS.",
     "Bombe"),
    ("MEMORIAL", 1940, 4, 1, "THE KATYN MASSACRE", "KATYN AND OTHER SITES, USSR",
     "SOVIET SECURITY POLICE EXECUTED CAPTURED POLISH OFFICERS AND OFFICIALS.",
     "21,857 KILLED",
     "THE SOVIET UNION DENIED RESPONSIBILITY UNTIL APRIL 1990.",
     "Katyn_massacre"),
    ("EUROPE", 1940, 4, 9, "THE INVASION OF NORWAY", "DENMARK AND NORWAY",
     "GERMANY SEIZED BOTH COUNTRIES TO SECURE IRON ORE AND NAVAL BASES.",
     "DENMARK FELL IN 6 HOURS",
     "NORWAY HELD OUT UNTIL JUNE WITH BRITISH AND FRENCH HELP.",
     "Norwegian_campaign"),
    ("EUROPE", 1940, 5, 10, "BLITZKRIEG IN THE WEST", "FRANCE AND THE BENELUX",
     "GERMANY STRUCK THE NETHERLANDS, BELGIUM AND FRANCE ON ONE MORNING.",
     "FRANCE FELL IN 6 WEEKS",
     "CHURCHILL BECAME BRITISH PRIME MINISTER THE SAME DAY.",
     "Battle_of_France"),
    ("EUROPE", 1940, 5, 26, "THE DUNKIRK EVACUATION", "DUNKIRK, FRANCE",
     "WARSHIPS AND CIVILIAN BOATS LIFTED A TRAPPED ARMY OFF THE BEACHES.",
     "338,226 LIFTED",
     "THE MEN CAME HOME. ALMOST ALL THE HEAVY EQUIPMENT DID NOT.",
     "Dunkirk_evacuation"),
    ("EUROPE", 1940, 6, 18, "THE FRENCH RESISTANCE", "FRANCE",
     "DE GAULLE BROADCAST FROM LONDON CALLING ON FRANCE TO FIGHT ON.",
     "4 YEARS UNDERGROUND",
     "NETWORKS PASSED INTELLIGENCE AND SABOTAGED RAILWAYS.",
     "French_Resistance"),
    ("EUROPE", 1940, 6, 22, "FRANCE SIGNS AN ARMISTICE", "COMPIEGNE, FRANCE",
     "FRANCE LEFT THE WAR SIX WEEKS AFTER THE GERMAN ATTACK BEGAN.",
     "SIGNED 18:36",
     "HITLER CHOSE THE RAILWAY CARRIAGE USED FOR THE 1918 ARMISTICE.",
     "Armistice_of_22_June_1940"),
    ("EUROPE", 1940, 7, 10, "THE BATTLE OF BRITAIN", "SOUTHERN ENGLAND",
     "THE RAF HELD OFF THE LUFTWAFFE AND STOPPED AN INVASION OF BRITAIN.",
     "10 JUL - 31 OCT",
     "THE FIRST MAJOR CAMPAIGN IN HISTORY FOUGHT ENTIRELY IN THE AIR.",
     "Battle_of_Britain"),
    ("EUROPE", 1940, 8, 20, "THE FEW", "BRITAIN",
     "ABOUT 3,000 AIRCREW FLEW FOR FIGHTER COMMAND IN THE BATTLE OF BRITAIN.",
     "3,000 AIRCREW",
     "ONE IN FIVE CAME FROM OUTSIDE BRITAIN, INCLUDING 145 POLISH PILOTS.",
     "The_Few"),
    ("HOME", 1940, 9, 7, "THE BLITZ BEGINS", "LONDON AND BRITISH CITIES",
     "GERMAN BOMBERS ATTACKED LONDON FOR 57 NIGHTS IN A ROW.",
     "ABOUT 40,000 DEAD",
     "THE RAIDS RAN TO MAY 1941. NEARLY HALF THE DEAD WERE IN LONDON.",
     "The_Blitz"),
    ("SUMMIT", 1940, 9, 27, "THE TRIPARTITE PACT", "BERLIN, GERMANY",
     "GERMANY, ITALY AND JAPAN AGREED TO SUPPORT ONE ANOTHER.",
     "3 POWERS",
     "THE AXIS NEVER COORDINATED AS CLOSELY AS THE ALLIANCE IT FACED.",
     "Tripartite_Pact"),
    ("HOME", 1940, 11, 14, "THE COVENTRY RAID", "COVENTRY, BRITAIN",
     "A NIGHT RAID DESTROYED THE CITY CENTRE AND ITS MEDIEVAL CATHEDRAL.",
     "ABOUT 568 KILLED",
     "THE RUINED CATHEDRAL WAS KEPT STANDING AS A MEMORIAL AND STILL IS.",
     "Coventry_Blitz"),
    ("INDUSTRY", 1940, 5, 1, "THE SHADOW FACTORIES", "BRITAIN",
     "BRITAIN SPREAD AIRCRAFT PRODUCTION ACROSS HIDDEN DISPERSED SITES.",
     "OUT BUILT GERMANY",
     "BRITAIN BUILT MORE FIGHTERS THAN GERMANY THROUGH 1940.",
     "Shadow_factory"),
    ("INDUSTRY", 1940, 6, 1, "THE T 34 TANK", "SOVIET UNION",
     "SLOPED ARMOUR AND WIDE TRACKS MADE IT THE BEST TANK OF ITS DAY.",
     "57,000 BY 1945",
     "WHOLE FACTORIES WERE MOVED EAST OF THE URALS AND KEPT BUILDING.",
     "T-34"),

    # ------------------------------------------------------- 1941 and 1942
    ("SUMMIT", 1941, 3, 11, "LEND LEASE", "WASHINGTON, USA",
     "THE USA BEGAN SUPPLYING ARMS TO BRITAIN AND LATER THE SOVIET UNION.",
     "$50 BILLION",
     "IT MADE AMERICA THE ARSENAL OF DEMOCRACY BEFORE IT ENTERED THE WAR.",
     "Lend-Lease"),
    ("AFRICA", 1941, 2, 12, "ROMMEL ARRIVES IN AFRICA", "TRIPOLI, LIBYA",
     "GERMANY SENT AN ARMOURED CORPS TO STOP AN ITALIAN COLLAPSE.",
     "2 YEAR CAMPAIGN",
     "THE DESERT WAR SWUNG BACK AND FORTH ACROSS THE SAME COASTAL ROAD.",
     "Afrika_Korps"),
    ("AFRICA", 1941, 4, 10, "THE SIEGE OF TOBRUK", "TOBRUK, LIBYA",
     "AN ALLIED GARRISON HELD THE PORT BEHIND AXIS LINES FOR EIGHT MONTHS.",
     "231 DAYS",
     "MOSTLY AUSTRALIAN, THEY CALLED THEMSELVES DESERT RATS.",
     "Siege_of_Tobruk"),
    ("ATLANTIC", 1941, 5, 9, "ENIGMA TAKEN AT SEA", "NORTH ATLANTIC",
     "A BOARDING PARTY TOOK AN ENIGMA MACHINE AND CODEBOOKS FROM A U BOAT.",
     "U 110",
     "THE CAPTURE HELPED BLETCHLEY PARK READ GERMAN NAVAL SIGNALS.",
     "German_submarine_U-110_(1940)"),
    ("ATLANTIC", 1941, 5, 27, "THE SINKING OF THE BISMARCK", "NORTH ATLANTIC",
     "BRITAIN HUNTED DOWN GERMANYS NEWEST BATTLESHIP OVER NINE DAYS.",
     "OVER 2,000 LOST",
     "A TORPEDO FROM AN OBSOLETE BIPLANE JAMMED HER RUDDER AND SEALED IT.",
     "German_battleship_Bismarck"),
    ("EAST", 1941, 6, 22, "OPERATION BARBAROSSA", "WESTERN SOVIET UNION",
     "GERMANY INVADED THE USSR ALONG A FRONT NEARLY 2,900 KM LONG.",
     "3.8 MILLION TROOPS",
     "THE LARGEST INVASION FORCE IN HISTORY, AND THE DEADLIEST THEATRE OF THE WAR.",
     "Operation_Barbarossa"),
    ("EAST", 1941, 9, 8, "THE SIEGE OF LENINGRAD", "LENINGRAD, USSR",
     "THE CITY WAS ENCIRCLED AND CUT OFF FROM FOOD FOR NEARLY 900 DAYS.",
     "872 DAYS",
     "CIVILIAN DEATHS ARE ESTIMATED BETWEEN ONE AND ONE AND A HALF MILLION.",
     "Siege_of_Leningrad"),
    ("MEMORIAL", 1941, 9, 29, "BABI YAR", "KYIV, UKRAINE",
     "GERMAN FORCES MURDERED THE JEWS OF KYIV IN A RAVINE OUTSIDE THE CITY.",
     "33,771 IN TWO DAYS",
     "THE FIGURE COMES FROM THE PERPETRATORS OWN REPORT.",
     "Babi_Yar"),
    ("INDUSTRY", 1941, 9, 27, "THE LIBERTY SHIPS", "UNITED STATES",
     "AMERICAN YARDS BUILT CARGO SHIPS FASTER THAN U BOATS COULD SINK THEM.",
     "2,710 BUILT",
     "THE FAMOUS FOUR DAY BUILD WAS A STUNT, NEVER REPEATED.",
     "Liberty_ship"),
    ("PACIFIC", 1941, 12, 7, "PEARL HARBOR", "OAHU, HAWAII",
     "JAPAN ATTACKED THE US PACIFIC FLEET AT ANCHOR WITHOUT A DECLARATION.",
     "2,403 DEAD",
     "FOUR BATTLESHIPS WERE SUNK. THE UNITED STATES ENTERED THE WAR NEXT DAY.",
     "Attack_on_Pearl_Harbor"),
    ("MEMORIAL", 1942, 1, 20, "THE WANNSEE CONFERENCE", "BERLIN, GERMANY",
     "FIFTEEN OFFICIALS MET TO COORDINATE THE MURDER OF EUROPES JEWS.",
     "90 MINUTES",
     "THE MURDERS HAD ALREADY BEGUN. THE MINUTES SURVIVED AS EVIDENCE.",
     "Wannsee_Conference"),
    ("PACIFIC", 1942, 2, 15, "THE FALL OF SINGAPORE", "SINGAPORE",
     "BRITAINS MAIN FAR EAST BASE SURRENDERED TO A SMALLER JAPANESE FORCE.",
     "80,000 CAPTURED",
     "CHURCHILL CALLED IT THE WORST DISASTER IN BRITISH MILITARY HISTORY.",
     "Battle_of_Singapore"),
    ("PACIFIC", 1942, 2, 19, "THE BOMBING OF DARWIN", "DARWIN, AUSTRALIA",
     "JAPANESE AIRCRAFT STRUCK NORTHERN AUSTRALIA IN TWO RAIDS IN ONE DAY.",
     "OVER 230 DEAD",
     "MORE BOMBS FELL ON DARWIN THAT DAY THAN ON PEARL HARBOR.",
     "Bombing_of_Darwin"),
    ("HOME", 1942, 2, 19, "JAPANESE AMERICAN INTERNMENT", "WESTERN UNITED STATES",
     "US CITIZENS OF JAPANESE DESCENT WERE REMOVED TO INLAND CAMPS.",
     "120,000 INTERNED",
     "CONGRESS FORMALLY APOLOGISED AND PAID REDRESS IN 1988.",
     "Internment_of_Japanese_Americans"),
    ("MEMORIAL", 1942, 4, 9, "THE BATAAN DEATH MARCH", "BATAAN, PHILIPPINES",
     "CAPTURED US AND FILIPINO TROOPS WERE MARCHED WITHOUT FOOD OR WATER.",
     "ABOUT 65 MILES",
     "THOUSANDS DIED ON THE MARCH AND IN THE CAMPS THAT FOLLOWED IT.",
     "Bataan_Death_March"),
    ("PACIFIC", 1942, 4, 18, "THE DOOLITTLE RAID", "TOKYO, JAPAN",
     "US BOMBERS FLEW FROM A CARRIER TO STRIKE JAPAN FOR THE FIRST TIME.",
     "16 BOMBERS",
     "THE DAMAGE WAS SLIGHT. THE EFFECT ON MORALE ON BOTH SIDES WAS NOT.",
     "Doolittle_Raid"),
    ("PACIFIC", 1942, 5, 4, "THE CORAL SEA", "CORAL SEA",
     "THE FIRST NAVAL BATTLE IN WHICH THE FLEETS NEVER SIGHTED EACH OTHER.",
     "CARRIERS ONLY",
     "IT STOPPED THE JAPANESE ADVANCE ON PORT MORESBY IN NEW GUINEA.",
     "Battle_of_the_Coral_Sea"),
    ("PACIFIC", 1942, 5, 4, "THE NAVAJO CODE TALKERS", "PACIFIC THEATRE",
     "US MARINES SENT ORDERS IN NAVAJO, A CODE JAPAN NEVER BROKE.",
     "NEVER BROKEN",
     "ABOUT 300 SERVED. THEIR WORK STAYED CLASSIFIED UNTIL 1968.",
     "Code_talker"),
    ("PACIFIC", 1942, 6, 4, "THE BATTLE OF MIDWAY", "MIDWAY ATOLL",
     "US CARRIER AIRCRAFT SANK FOUR JAPANESE CARRIERS IN A SINGLE DAY.",
     "4 CARRIERS LOST",
     "IT ENDED JAPANESE OFFENSIVE POWER IN THE PACIFIC IN ONE MORNING.",
     "Battle_of_Midway"),
    ("EAST", 1942, 7, 17, "THE BATTLE OF STALINGRAD", "STALINGRAD, USSR",
     "GERMAN AND SOVIET ARMIES FOUGHT STREET BY STREET FOR SIX MONTHS.",
     "ABOUT 2 MILLION",
     "TOTAL CASUALTIES ON BOTH SIDES ARE ESTIMATED NEAR TWO MILLION.",
     "Battle_of_Stalingrad"),
    ("PACIFIC", 1942, 8, 7, "GUADALCANAL", "SOLOMON ISLANDS",
     "THE FIRST ALLIED LAND OFFENSIVE AGAINST JAPAN, FOUGHT FOR SIX MONTHS.",
     "6 MONTHS",
     "IT COST JAPAN SHIPS AND AIRCREW THAT COULD NOT BE REPLACED.",
     "Guadalcanal_campaign"),
    ("SCIENCE", 1942, 8, 13, "THE MANHATTAN PROJECT", "UNITED STATES",
     "A SECRET PROGRAMME BUILT THE FIRST ATOMIC WEAPONS IN THREE YEARS.",
     "130,000 WORKED ON IT",
     "MOST OF THOSE EMPLOYED DID NOT KNOW WHAT THEY WERE BUILDING.",
     "Manhattan_Project"),
    ("AFRICA", 1942, 10, 23, "EL ALAMEIN", "EL ALAMEIN, EGYPT",
     "THE EIGHTH ARMY BROKE THE AXIS LINE AND BEGAN A LONG RETREAT WEST.",
     "13 DAYS",
     "CHURCHILL CALLED IT NOT THE END, BUT THE END OF THE BEGINNING.",
     "Second_Battle_of_El_Alamein"),
    ("AFRICA", 1942, 11, 8, "OPERATION TORCH", "MOROCCO AND ALGERIA",
     "ANGLO AMERICAN LANDINGS OPENED A SECOND FRONT IN NORTH AFRICA.",
     "3 LANDING SITES",
     "IT WAS THE FIRST LARGE AMERICAN GROUND ACTION AGAINST GERMANY.",
     "Operation_Torch"),
    ("ATLANTIC", 1942, 6, 27, "THE ARCTIC CONVOYS", "BARENTS SEA",
     "CONVOYS CARRIED SUPPLIES TO THE USSR THROUGH ICE, U BOATS AND AIR ATTACK.",
     "78 CONVOYS",
     "CHURCHILL CALLED IT THE WORST JOURNEY IN THE WORLD.",
     "Arctic_convoys_of_World_War_II"),
    ("HOME", 1942, 1, 1, "WOMEN IN WAR WORK", "UNITED STATES AND BRITAIN",
     "MILLIONS OF WOMEN TOOK INDUSTRIAL JOBS WHILE THE MEN WERE AWAY.",
     "50% MORE AT WORK",
     "THE NUMBER OF EMPLOYED US WOMEN ROSE BY HALF FROM 1940 TO 1944.",
     "Rosie_the_Riveter"),
    ("MEMORIAL", 1942, 12, 1, "THE BURMA RAILWAY", "THAILAND AND BURMA",
     "PRISONERS AND FORCED LABOURERS BUILT A RAILWAY THROUGH THE JUNGLE.",
     "ABOUT 100,000 DIED",
     "MOST WHO DIED WERE ASIAN CIVILIAN LABOURERS, NOT PRISONERS OF WAR.",
     "Burma_Railway"),

    # ------------------------------------------------------- 1943 and 1944
    ("EAST", 1943, 2, 2, "STALINGRAD SURRENDERS", "STALINGRAD, USSR",
     "THE ENCIRCLED GERMAN SIXTH ARMY SURRENDERED AFTER MONTHS CUT OFF.",
     "91,000 PRISONERS",
     "ONLY ABOUT 6,000 OF THOSE PRISONERS EVER RETURNED HOME.",
     "Battle_of_Stalingrad"),
    ("MEMORIAL", 1943, 4, 19, "THE WARSAW GHETTO UPRISING", "WARSAW, POLAND",
     "JEWISH FIGHTERS RESISTED DEPORTATION FOR NEARLY A MONTH.",
     "29 DAYS",
     "THE LARGEST JEWISH REVOLT AGAINST NAZI GERMANY. AT LEAST 13,000 DIED.",
     "Warsaw_Ghetto_Uprising"),
    ("ATLANTIC", 1943, 5, 1, "BLACK MAY", "NORTH ATLANTIC",
     "U BOAT LOSSES ROSE SO SHARPLY THAT GERMANY WITHDREW FROM THE ATLANTIC.",
     "43 U BOATS LOST",
     "AIR COVER, RADAR AND CODEBREAKING TOGETHER TURNED THE LONGEST CAMPAIGN.",
     "Battle_of_the_Atlantic"),
    ("SCIENCE", 1943, 5, 16, "THE DAMBUSTERS RAID", "RUHR VALLEY, GERMANY",
     "PURPOSE BUILT BOUNCING BOMBS BREACHED TWO GERMAN DAMS IN ONE NIGHT.",
     "8 OF 19 LOST",
     "MOST OF THE 1,300 KILLED IN THE FLOODS WERE FOREIGN FORCED LABOURERS.",
     "Operation_Chastise"),
    ("EAST", 1943, 7, 5, "THE BATTLE OF KURSK", "KURSK, USSR",
     "THE DEADLIEST ARMOURED BATTLE EVER FOUGHT, AND GERMANYS LAST OFFENSIVE IN THE EAST.",
     "7 WEEKS",
     "AFTER KURSK THE GERMAN ARMY IN THE EAST ONLY EVER RETREATED.",
     "Battle_of_Kursk"),
    ("EUROPE", 1943, 7, 9, "THE INVASION OF SICILY", "SICILY, ITALY",
     "ALLIED FORCES LANDED IN SICILY AND TOOK THE ISLAND IN SIX WEEKS.",
     "6 WEEKS",
     "THE INVASION HELPED BRING DOWN MUSSOLINI WITHIN A FORTNIGHT.",
     "Allied_invasion_of_Sicily"),
    ("EUROPE", 1943, 7, 1, "THE TUSKEGEE AIRMEN", "NORTH AFRICA AND ITALY",
     "THE FIRST AFRICAN AMERICAN PILOTS IN US SERVICE FLEW COMBAT MISSIONS.",
     "15,000 SORTIES",
     "THEY FOUGHT SEGREGATION AT HOME AND THE LUFTWAFFE ABROAD.",
     "Tuskegee_Airmen"),
    ("EUROPE", 1943, 9, 8, "ITALY LEAVES THE WAR", "CASSIBILE, SICILY",
     "ITALY SIGNED AN ARMISTICE AND GERMANY IMMEDIATELY OCCUPIED THE COUNTRY.",
     "SIGNED 3 SEP",
     "SIGNED ON 3 SEPTEMBER AND KEPT SECRET FOR FIVE DAYS.",
     "Armistice_of_Cassibile"),
    ("MEMORIAL", 1943, 6, 1, "THE BENGAL FAMINE", "BENGAL, BRITISH INDIA",
     "FAMINE IN BRITISH INDIA KILLED MILLIONS DURING THE WAR YEARS.",
     "ABOUT 2 MILLION",
     "ESTIMATES RANGE FROM UNDER ONE MILLION TO OVER THREE MILLION.",
     "Bengal_famine_of_1943"),
    ("SUMMIT", 1943, 11, 28, "THE TEHRAN CONFERENCE", "TEHRAN, IRAN",
     "ROOSEVELT, CHURCHILL AND STALIN MET AND AGREED TO INVADE FRANCE.",
     "FIRST BIG THREE",
     "IT WAS THE FIRST MEETING OF ALL THREE ALLIED LEADERS IN ONE ROOM.",
     "Tehran_Conference"),
    ("EUROPE", 1944, 1, 17, "MONTE CASSINO", "LAZIO, ITALY",
     "FOUR ASSAULTS OVER FOUR MONTHS BROKE THE GERMAN LINE IN ITALY.",
     "4 ASSAULTS",
     "THE ABBEY WAS BOMBED ON 15 FEBRUARY, KILLING CIVILIAN REFUGEES.",
     "Battle_of_Monte_Cassino"),
    ("EUROPE", 1944, 1, 22, "THE ANZIO LANDINGS", "ANZIO, ITALY",
     "A LANDING BEHIND GERMAN LINES WAS PENNED INTO ITS BEACHHEAD FOR MONTHS.",
     "4 MONTHS",
     "THE BEACHHEAD WAS HELD UNDER FIRE UNTIL A BREAKOUT IN MAY.",
     "Battle_of_Anzio"),
    ("EUROPE", 1944, 3, 24, "THE GREAT ESCAPE", "STALAG LUFT III, SAGAN",
     "SEVENTY SIX PRISONERS TUNNELLED OUT OF A GERMAN AIR FORCE CAMP.",
     "76 ESCAPED, 3 FREE",
     "FIFTY OF THE RECAPTURED MEN WERE MURDERED BY THE GESTAPO.",
     "Stalag_Luft_III_escape"),
    ("EUROPE", 1944, 6, 6, "D DAY", "NORMANDY, FRANCE",
     "THE LARGEST SEABORNE INVASION EVER MOUNTED LANDED IN NORMANDY.",
     "156,000 LANDED",
     "NEARLY 7,000 VESSELS TOOK PART. 4,414 ALLIED DEAD ARE CONFIRMED.",
     "Normandy_landings"),
    ("INDUSTRY", 1944, 6, 7, "THE MULBERRY HARBOURS", "NORMANDY, FRANCE",
     "TWO ARTIFICIAL PORTS WERE TOWED ACROSS THE CHANNEL AFTER D DAY.",
     "2 PORTS TOWED",
     "ONE WAS WRECKED IN A STORM ON 19 JUNE. OPEN BEACHES LANDED MORE THAN BOTH.",
     "Mulberry_harbour"),
    ("PACIFIC", 1944, 6, 19, "THE PHILIPPINE SEA", "PHILIPPINE SEA",
     "JAPAN LOST THREE CARRIERS AND HUNDREDS OF AIRCRAFT IN TWO DAYS.",
     "ABOUT 600 PLANES",
     "JAPAN NEVER REBUILT ITS CARRIER AIR GROUPS AFTER THIS BATTLE.",
     "Battle_of_the_Philippine_Sea"),
    ("EAST", 1944, 6, 22, "OPERATION BAGRATION", "BELARUS",
     "A SOVIET OFFENSIVE DESTROYED GERMAN ARMY GROUP CENTRE IN WEEKS.",
     "LARGEST GERMAN DEFEAT",
     "GERMAN LOSSES ARE DISPUTED, BUT EXCEEDED THOSE AT STALINGRAD.",
     "Operation_Bagration"),
    ("EUROPE", 1944, 7, 20, "THE JULY PLOT", "EAST PRUSSIA",
     "GERMAN OFFICERS TRIED TO KILL HITLER WITH A BRIEFCASE BOMB.",
     "NEARLY 5,000 EXECUTED",
     "OPERATION VALKYRIE WAS THE EXISTING STATE PLAN THE PLOTTERS HIJACKED.",
     "20_July_plot"),
    ("EUROPE", 1944, 8, 25, "THE LIBERATION OF PARIS", "PARIS, FRANCE",
     "FRENCH AND AMERICAN TROOPS ENTERED PARIS AFTER A RESISTANCE RISING.",
     "RISING BEGAN 19 AUG",
     "THE GERMAN COMMANDER IGNORED ORDERS TO DESTROY THE CITY.",
     "Liberation_of_Paris"),
    ("MEMORIAL", 1944, 8, 1, "THE WARSAW UPRISING", "WARSAW, POLAND",
     "THE POLISH HOME ARMY ROSE AGAINST THE OCCUPATION FOR 63 DAYS.",
     "63 DAYS",
     "BETWEEN 150,000 AND 200,000 CIVILIANS DIED AND THE CITY WAS RAZED.",
     "Warsaw_Uprising"),
    ("INDUSTRY", 1944, 8, 25, "THE RED BALL EXPRESS", "FRANCE",
     "TRUCK CONVOYS RAN DAY AND NIGHT TO SUPPLY ARMIES ADVANCING EAST.",
     "6,000 TRUCKS",
     "MOST OF THE DRIVERS WERE AFRICAN AMERICAN SOLDIERS.",
     "Red_Ball_Express"),
    ("SCIENCE", 1944, 9, 8, "THE V 2 ROCKET", "LONDON AND ANTWERP",
     "THE FIRST BALLISTIC MISSILE STRUCK WITHOUT WARNING AND WITHOUT DEFENCE.",
     "OVER 3,000 FIRED",
     "MORE DIED AS FORCED LABOUR BUILDING THEM THAN WERE KILLED BY THEM.",
     "V-2_rocket"),
    ("EUROPE", 1944, 9, 17, "OPERATION MARKET GARDEN", "NETHERLANDS",
     "AN AIRBORNE ATTEMPT TO SEIZE THE RHINE BRIDGES FELL SHORT AT ARNHEM.",
     "8,000 OF 10,000 LOST",
     "THE BRIDGE AT ARNHEM WAS THE OBJECTIVE THAT COULD NOT BE HELD.",
     "Operation_Market_Garden"),
    ("PACIFIC", 1944, 10, 23, "LEYTE GULF", "PHILIPPINES",
     "THE LARGEST NAVAL BATTLE OF THE SECOND WORLD WAR, FOUGHT OVER FOUR DAYS.",
     "4 DAYS",
     "IT EFFECTIVELY ENDED THE JAPANESE NAVY AS A FIGHTING FORCE.",
     "Battle_of_Leyte_Gulf"),
    ("PACIFIC", 1944, 10, 25, "THE KAMIKAZE", "PHILIPPINES",
     "JAPAN BEGAN ORGANISED SUICIDE ATTACKS ON ALLIED SHIPPING.",
     "OVER 3,000 PILOTS",
     "THE TACTIC SANK DOZENS OF SHIPS BUT COULD NOT CHANGE THE OUTCOME.",
     "Kamikaze"),
    ("EUROPE", 1944, 12, 16, "THE BATTLE OF THE BULGE", "ARDENNES, BELGIUM",
     "A SURPRISE GERMAN WINTER ATTACK PUSHED A BULGE INTO THE ALLIED LINE.",
     "81,000 US CASUALTIES",
     "THE COSTLIEST SINGLE BATTLE EVER FOUGHT BY THE UNITED STATES ARMY.",
     "Battle_of_the_Bulge"),

    # ----------------------------------------------------------- 1945, end
    ("MEMORIAL", 1945, 1, 27, "THE LIBERATION OF AUSCHWITZ", "OSWIECIM, POLAND",
     "THE RED ARMY REACHED THE LARGEST NAZI CAMP AND FREED THE SURVIVORS.",
     "1.1 MILLION MURDERED",
     "27 JANUARY IS NOW INTERNATIONAL HOLOCAUST REMEMBRANCE DAY.",
     "Auschwitz_concentration_camp"),
    ("SUMMIT", 1945, 2, 4, "THE YALTA CONFERENCE", "YALTA, CRIMEA",
     "THE THREE ALLIED LEADERS AGREED HOW TO OCCUPY A DEFEATED GERMANY.",
     "8 DAYS",
     "THE LINES AGREED HERE SHAPED EUROPE FOR THE NEXT FORTY FIVE YEARS.",
     "Yalta_Conference"),
    ("EUROPE", 1945, 2, 13, "THE BOMBING OF DRESDEN", "DRESDEN, GERMANY",
     "ALLIED RAIDS DESTROYED THE CITY CENTRE IN A FIRESTORM OVER TWO NIGHTS.",
     "22,700 TO 25,000 DEAD",
     "HIGHER FIGURES COME FROM NAZI PROPAGANDA. A 2010 STUDY SETTLED IT.",
     "Bombing_of_Dresden_in_World_War_II"),
    ("PACIFIC", 1945, 2, 19, "IWO JIMA", "IWO JIMA, JAPAN",
     "US MARINES TOOK AN EIGHT SQUARE MILE ISLAND IN FIVE WEEKS OF FIGHTING.",
     "36 DAYS",
     "ALMOST THE ENTIRE JAPANESE GARRISON OF 21,000 DIED DEFENDING IT.",
     "Battle_of_Iwo_Jima"),
    ("PACIFIC", 1945, 4, 1, "OKINAWA", "OKINAWA, JAPAN",
     "THE LAST GREAT BATTLE OF THE PACIFIC WAR LASTED NEARLY THREE MONTHS.",
     "82 DAYS",
     "TENS OF THOUSANDS OF OKINAWAN CIVILIANS DIED IN THE FIGHTING.",
     "Battle_of_Okinawa"),
    ("EAST", 1945, 4, 16, "THE BATTLE OF BERLIN", "BERLIN, GERMANY",
     "THE RED ARMY TOOK THE GERMAN CAPITAL IN TWO WEEKS OF STREET FIGHTING.",
     "2.5 MILLION TROOPS",
     "ONE OF THE COSTLIEST BATTLES OF THE ENTIRE WAR, FOUGHT IN ITS LAST WEEKS.",
     "Battle_of_Berlin"),
    ("EUROPE", 1945, 4, 30, "HITLER DIES IN BERLIN", "BERLIN, GERMANY",
     "HITLER KILLED HIMSELF IN A BUNKER AS SOVIET TROOPS TOOK THE CITY.",
     "12 YEARS IN POWER",
     "THE REICH HE SAID WOULD LAST A THOUSAND YEARS LASTED TWELVE.",
     "Death_of_Adolf_Hitler"),
    ("EUROPE", 1945, 5, 8, "VE DAY", "REIMS AND BERLIN",
     "GERMANY SURRENDERED UNCONDITIONALLY AND THE WAR IN EUROPE ENDED.",
     "5 YEARS 8 MONTHS",
     "SIGNED TWICE, AT REIMS AND BERLIN. MOSCOW TIME MADE IT 9 MAY IN THE USSR.",
     "Victory_in_Europe_Day"),
    ("SUMMIT", 1945, 7, 17, "THE POTSDAM CONFERENCE", "POTSDAM, GERMANY",
     "THE ALLIES SET TERMS FOR GERMANY AND DEMANDED JAPAN SURRENDER.",
     "17 DAYS",
     "CHURCHILL LOST AN ELECTION PARTWAY THROUGH AND ATTLEE TOOK HIS SEAT.",
     "Potsdam_Conference"),
    ("MEMORIAL", 1945, 8, 6, "HIROSHIMA", "HIROSHIMA, JAPAN",
     "THE FIRST ATOMIC BOMB USED IN WAR DESTROYED MOST OF THE CITY.",
     "90,000 TO 166,000 DEAD",
     "THE RANGE COVERS DEATHS FROM BLAST AND RADIATION BY YEARS END.",
     "Atomic_bombings_of_Hiroshima_and_Nagasaki"),
    ("MEMORIAL", 1945, 8, 9, "NAGASAKI", "NAGASAKI, JAPAN",
     "A SECOND ATOMIC BOMB WAS DROPPED THREE DAYS AFTER HIROSHIMA.",
     "60,000 TO 80,000 DEAD",
     "JAPAN ANNOUNCED ITS SURRENDER SIX DAYS AFTER THIS ATTACK.",
     "Atomic_bombings_of_Hiroshima_and_Nagasaki"),
    ("EAST", 1945, 8, 9, "THE INVASION OF MANCHURIA", "MANCHURIA, CHINA",
     "THE USSR ATTACKED JAPANESE FORCES IN MANCHURIA IN A RAPID ADVANCE.",
     "1.6 MILLION TROOPS",
     "THE SOVIET ATTACK AND THE NAGASAKI BOMBING CAME A DAY APART.",
     "Soviet_invasion_of_Manchuria"),
    ("PACIFIC", 1945, 9, 2, "JAPAN SIGNS THE SURRENDER", "TOKYO BAY, JAPAN",
     "THE FORMAL SURRENDER WAS SIGNED ABOARD THE USS MISSOURI.",
     "6 YEARS AND A DAY",
     "JAPAN ANNOUNCED SURRENDER ON 15 AUGUST. THE WAR FORMALLY ENDED HERE.",
     "Surrender_of_Japan"),
    ("SUMMIT", 1945, 11, 20, "THE NUREMBERG TRIALS", "NUREMBERG, GERMANY",
     "SENIOR NAZI LEADERS WERE TRIED BEFORE AN INTERNATIONAL TRIBUNAL.",
     "22 TRIED",
     "IT ESTABLISHED THAT FOLLOWING ORDERS WAS NOT A DEFENCE IN LAW.",
     "Nuremberg_trials"),

    # ------------------------------------------- the war entire, and its cost
    ("ATLANTIC", 1939, 9, 3, "THE BATTLE OF THE ATLANTIC", "NORTH ATLANTIC",
     "CONVOYS CARRIED BRITAINS FOOD AND FUEL THROUGH U BOAT PATROLS.",
     "6 YEARS",
     "THE LONGEST CONTINUOUS CAMPAIGN OF THE WAR, FIRST DAY TO LAST.",
     "Battle_of_the_Atlantic"),
    ("MEMORIAL", 1945, 5, 8, "THE HOLOCAUST", "GERMAN OCCUPIED EUROPE",
     "NAZI GERMANY MURDERED AROUND SIX MILLION JEWS ACROSS OCCUPIED EUROPE.",
     "AROUND 6 MILLION",
     "TWO THIRDS OF THE JEWS OF EUROPE. ROMA, POLES AND OTHERS TOO.",
     "The_Holocaust"),
    ("MEMORIAL", 1945, 9, 2, "THE HUMAN COST", "WORLDWIDE",
     "THE SECOND WORLD WAR KILLED MORE PEOPLE THAN ANY OTHER IN HISTORY.",
     "60 TO 75 MILLION",
     "MOST OF THE DEAD WERE CIVILIANS. THE USSR AND CHINA LOST THE MOST.",
     "World_War_II_casualties"),
]

# ------------------------------------------------------------ text helpers
def clip(c, text, font, maxw):
    """Longest prefix that fits. Nothing in the drawing API clips, so a string
    that is not measured runs straight through whatever shares its row."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def wrap_greedy(c, text, font, maxw, maxlines):
    words = str(text).split(" ")
    lines = []
    cur = ""
    for w in words:
        if len(lines) >= maxlines:
            break
        cand = w if cur == "" else cur + " " + w
        if c.text_width(cand, font) <= maxw:
            cur = cand
        elif cur == "":
            lines.append(clip(c, w, font, maxw))
        else:
            lines.append(cur)
            cur = w
    if cur != "" and len(lines) < maxlines:
        lines.append(cur)
    return lines

def fits_whole(lines, text):
    """True when the wrap lost nothing: the rejoined lines are the original."""
    return " ".join(lines) == str(text)

def fit_block(c, text, opts, maxw):
    """opts is [[font, maxlines], ...] largest first. Returns [font, lines]
    for the first option the whole string fits in, else the smallest with
    each line hard clipped."""
    for o in opts:
        ls = wrap_greedy(c, text, o[0], maxw, o[1])
        if fits_whole(ls, text):
            return [o[0], ls]
    last = opts[len(opts) - 1]
    ls = wrap_greedy(c, text, last[0], maxw, last[1])
    out = []
    for ln in ls:
        out.append(clip(c, ln, last[0], maxw))
    return [last[0], out]

def fit_trunc(c, text, font, maxw, maxlines):
    """Wrap into at most maxlines, and when the string does not all fit, end
    the last line in '..' so the cut reads as deliberate.

    Without this the panel simply stops: an earlier build ended a note on
    "MOST NEVER SAW THEIR" and a Wikipedia line on "BY THE IMPERIAL", which
    reads as a broken app rather than as an abridged one."""
    ls = wrap_greedy(c, text, font, maxw, maxlines)
    if fits_whole(ls, text) or len(ls) == 0:
        return ls
    last = ls[len(ls) - 1]
    out = last
    for _ in range(len(last)):
        if c.text_width(out + "..", font) <= maxw:
            break
        out = out[:len(out) - 1]
    # Back up to a whole word, unless that costs most of the line.
    sp = out.rfind(" ")
    if sp > 0 and sp * 10 >= len(out) * 6:
        out = out[:sp]
    ls[len(ls) - 1] = out + ".."
    return ls

def first_sentence(s):
    """Wikipedia summaries are paragraphs and the panel has two rows. One
    sentence that ends beats a paragraph that stops."""
    t = str(s)
    i = t.find(". ")
    if i > 40:
        return t[:i + 1]
    return t

def draw_block(c, lines, font, x, top, color, gap = 1):
    h = FONTH[font]
    y = top
    for ln in lines:
        c.text(ln, x, y, font = font, color = color)
        y = y + h + gap
    return y - gap

def block_height(font, n, gap = 1):
    return FONTH[font] * n + gap * (n - 1)

# ------------------------------------------------------------------ colour
HEXD = "0123456789abcdef"

def _hex2(v):
    if v < 0:
        v = 0
    if v > 255:
        v = 255
    return HEXD[v // 16] + HEXD[v % 16]

def dim(col, num, den):
    """Knock a colour back without alpha, so one accent can carry a highlight,
    a body and a shadow and still read as one colour."""
    r = int(col[1:3], 16) * num // den
    g = int(col[3:5], 16) * num // den
    b = int(col[5:7], 16) * num // den
    return "#" + _hex2(r) + _hex2(g) + _hex2(b)

def ink_for(fill):
    """Black text on a light chip, white on a dark one, computed rather than
    guessed, so a new front colour can never ship an unreadable chip."""
    v = [int(fill[1:3], 16), int(fill[3:5], 16), int(fill[5:7], 16)]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def rail(c, col):
    c.rect(0, 0, 1, 31, fill = col)

def chip(c, word, col, x = 10):
    """The page chip: same object, same place, on all three pages."""
    return c.badge(word, x, 0, color = ink_for(col), bg = col, font = "4x5")

# ------------------------------------------------------------------- dates
CUM = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

def is_leap(y):
    if y % 400 == 0:
        return True
    if y % 100 == 0:
        return False
    return y % 4 == 0

def daynum(y, m, d):
    """A running day count, so two dates can be compared and a date can be
    placed on a bar. Only differences are ever used, so the origin is
    arbitrary."""
    n = y * 365 + (y // 4) - (y // 100) + (y // 400) + CUM[m - 1] + d
    if m <= 2 and is_leap(y):
        n = n - 1
    return n

def date_text(e):
    return str(e[DY]) + " " + MON[e[MO] - 1] + " " + str(e[YR])

# The timeline covers 1937 to the end of 1945, not just the war, because the
# roster deliberately carries the run-up: a 1938 entry has to land somewhere
# real rather than being clamped onto the left cap and quietly misdated.
TL_YEARS = [1937, 1938, 1939, 1940, 1941, 1942, 1943, 1944, 1945]
TL_X = 10
TL_W = 172

def tl_px(dn, t0, t1):
    """A day number to its column on the bar, clamped to the ends."""
    if dn <= t0:
        return TL_X
    if dn >= t1:
        return TL_X + TL_W - 1
    return TL_X + (dn - t0) * (TL_W - 1) // (t1 - t0)

# ------------------------------------------------------------------ inputs
def bool_input(value, fallback):
    """Checkbox inputs arrive as a bool from Studio and as text from a saved
    config, so both have to be accepted."""
    if value == None:
        return fallback
    if value == True or value == False:
        return value
    t = str(value).strip().lower()
    if t in ["true", "1", "yes", "on"]:
        return True
    if t in ["false", "0", "no", "off"]:
        return False
    return fallback

def in_era(y, m, era):
    if era == "BEFORE THE WAR":
        return y < 1939 or (y == 1939 and m < 9)
    if era == "1939-1941":
        return (y == 1939 and m >= 9) or y == 1940 or y == 1941
    if era == "1942-1943":
        return y == 1942 or y == 1943
    if era == "1944-1945":
        return y == 1944 or y == 1945
    return True

def pool_for(ctx):
    """The filtered roster. A front and a period that together match nothing
    falls back to the whole roster: an empty panel is never the right answer
    to a settings combination, and every combination has to render."""
    front = str(ctx.inputs.get("front", "ALL FRONTS")).strip().upper()
    era = str(ctx.inputs.get("era", "WHOLE WAR")).strip().upper()
    code = FRONT_PICK.get(front, "")
    out = []
    for e in ENTRIES:
        if code != "" and e[TH] != code:
            continue
        if not in_era(e[YR], e[MO], era):
            continue
        out.append(e)
    if len(out) == 0:
        return [ENTRIES, True]
    return [out, False]

def entry_today(ctx):
    p = pool_for(ctx)
    pool = p[0]
    # The house rotation: one entry a day, with the year term shifting where
    # the sequence starts so the same date does not land on the same entry
    # every year.
    idx = (ctx.now.yday - 1 + ctx.now.year * 3) % len(pool)
    return [pool[idx], p[1]]

# -------------------------------------------------------------------- art
# Silhouettes, drawn at native resolution. '#' is the front colour, '=' a
# knocked back version of it for shadow and sea, 'o' near black for cut outs
# (wheel hubs, windows), '+' a highlight.
PLANE = """
...............#...............
...............#...............
..............###..............
..............###..............
.............##+##.............
.............##+##.............
.......#################.......
...#########################...
###############################
###############################
...#########################...
.......#################.......
..............###..............
..............###..............
..............###..............
..............###..............
..........###########..........
...........#########...........
..............###..............
...............#...............
...............#...............
"""

TANK = """
................##########..........
...............############.........
..............##############........
..###########################.......
..###########################.......
.............################.......
.....############################...
...################################.
...################################.
..#################################.
.##################################.
####################################
###o####o####o####o####o####o####o##
####################################
.##################################.
"""

CARRIER = """
.........................####.........
........................#####.........
........................#####.........
........................#####.........
######################################
######################################
..###################################.
...#################################..
....###############################...
......###########################.....
.........#####################........
.............#############............
..==..==..==..==..==..==..==..==..==..
==..==..==..==..==..==..==..==..==..==
"""

ESCORT = """
.................#..................
.................#..................
..............#######...............
............###########.............
..........###############...........
........###################.........
..################################..
.##################################.
..################################..
....############################....
.......######################.......
..==..==..==..==..==..==..==..==..==
==..==..==..==..==..==..==..==..==..
"""

FACTORY = """
..=...=.........................
.=...=..........................
..##...##.......................
..##...##.......................
..##...##.......................
..##...##.......................
..##...##...#....#....#....#....
..##...##..###..###..###..###...
..##...##.#####################.
..############################..
..############################..
..##ooo##ooo##ooo##ooo##ooo###..
..##ooo##ooo##ooo##ooo##ooo###..
..############################..
..##ooo##ooo##ooo##ooo##ooo###..
..##ooo##ooo##ooo##ooo##ooo###..
..############################..
"""

FLAME = """
........+.......
.......+++......
......++#++.....
.....++###++....
....++#####++...
....++#####++...
.....++###++....
......+###+.....
.......###......
.......###......
.......###......
......#####.....
.....#######....
....=========...
...===========..
..=============.
..=============.
"""

DOC = """
.........................
.####################....
.#..................##...
.#..................###..
.#.================.####.
.#..................####.
.#.================.####.
.#..................####.
.#.================.####.
.#..................####.
.#.================.####.
.#..................####.
.#.=============....####.
.#..................####.
.#..................####.
.######################..
"""

HOUSES = """
..............................
..............................
..............................
..............................
..............................
......###.........###.........
.....#####.......#####........
....#######.....#######.......
...#########...#########......
..###########.###########.....
..##ooo##ooo###ooo##ooo##.....
..##ooo##ooo###ooo##ooo##.....
..#######################.....
..##ooo##ooo###ooo##ooo##.....
..##ooo##ooo###ooo##ooo##.....
..#######################.....
"""

# front code -> [art, width, height]
ART = {
    "EUROPE": [PLANE, 31, 21],
    "EAST": [TANK, 36, 15],
    "AFRICA": [TANK, 36, 15],
    "PACIFIC": [CARRIER, 38, 14],
    "ATLANTIC": [ESCORT, 36, 13],
    "INDUSTRY": [FACTORY, 32, 17],
    "MEMORIAL": [FLAME, 16, 17],
    "SUMMIT": [DOC, 25, 16],
    "HOME": [HOUSES, 30, 16],
}

ART_X = 10
ART_W = 40
ART_Y = 8
ART_H = 24

def art_legend(col):
    return {
        "#": col,
        "=": dim(col, 2, 5),
        "+": dim(col, 9, 5),
        "o": "#05070C",
    }

def draw_art(c, code, col):
    """The front's own drawing, centred in its column. SCIENCE is built from
    primitives rather than character art: three Enigma rotors are circles, and
    a circle drawn by the API is rounder than one typed by hand."""
    if code == "SCIENCE":
        # Three rotors on a shaft, with the setting notches showing.
        # Radius 7 centred on 18/30/42 spans x11..49: clear of the x10 safe
        # edge on the left and of the x53 divider on the right. An earlier cut
        # put setting notches either side of each rotor, which reached x9 and
        # x52 and broke both at once.
        c.rect(ART_X + 2, 26, ART_X + 37, 28, fill = dim(col, 2, 5))
        for i in range(3):
            cx = ART_X + 8 + i * 12
            c.fill_circle(cx, 17, 7, dim(col, 2, 5))
            c.circle(cx, 17, 7, col)
            c.circle(cx, 17, 3, col)
            c.vline(cx, 9, 3, col)
            c.vline(cx, 22, 3, col)
        return

    a = ART.get(code, ART["EUROPE"])
    ax = ART_X + (ART_W - a[1]) // 2
    ay = ART_Y + (ART_H - a[2]) // 2

    if code == "AFRICA":
        # The same tank, but under a low desert sun, so AFRICA and EAST are
        # never the same picture in two colours.
        c.fill_circle(ART_X + 32, 14, 5, dim(col, 2, 5))
        ay = ART_Y + 6
        c.hline(ART_X, 30, ART_W, dim(col, 2, 5))
    if code == "HOME":
        # Searchlights over the rooftops. Drawn as lines because a 1px
        # diagonal typed as character art stairsteps unevenly.
        c.line(ART_X + 4, 31, ART_X + 14, 8, dim(col, 2, 5))
        c.line(ART_X + 36, 31, ART_X + 26, 8, dim(col, 2, 5))
        ay = ART_Y + 8

    c.sprite(a[0], ax, ay, legend = art_legend(col))

# ------------------------------------------------------------------- pages
def front_of(e):
    code = e[TH]
    return [code, FRONT_COLOR.get(code, "#4EA3FF"), FRONT_CHIP.get(code, "EUROPE")]

def event(c, ctx):
    """WHAT and WHEN. The artwork is the front, the hero is the title, and the
    date sits in the chip row where it cannot crowd a long name."""
    r = entry_today(ctx)
    e = r[0]
    f = front_of(e)
    col = f[1]

    c.fill("black")
    rail(c, col)
    cw = chip(c, safe(f[2]), col)

    # The date is right aligned and the chip is measured, so the two can never
    # meet however long a front name gets.
    d = safe(date_text(e))
    room = 181 - (10 + cw + 3)
    c.text(clip(c, d, "4x5", room), 181, 1, font = "4x5", color = col,
           align = "right")

    draw_art(c, f[0], col)
    c.vline(53, 8, 24, FAINT)

    tx = 57
    tw = 181 - tx + 1              # 125px

    title = safe(e[TI])
    # One big line if it fits, two smaller ones if it does not. Two lines of
    # 9x12 need 25px and the band is 24, so the two line ladder starts at 6x8.
    tf = ""
    tl = []
    for f1 in ["9x12", "8x10"]:
        if c.text_width(title, f1) <= tw:
            tf = f1
            tl = [title]
            break
    if tf == "":
        b = fit_block(c, title, [["6x8", 2], ["5x7", 2], ["4x5", 2]], tw)
        tf = b[0]
        tl = b[1]

    place = clip(c, safe(e[PL]), "4x5", tw)
    th = block_height(tf, len(tl))
    block = th + 2 + FONTH["4x5"]
    top = ART_Y + (ART_H - block) // 2
    if top < ART_Y:
        top = ART_Y
    draw_block(c, tl, tf, tx, top, INK)
    c.text(place, tx, top + th + 2, font = "4x5", color = DIM)

def why(c, ctx):
    """WHY IT MATTERED. The prose gets the full safe width, because a sentence
    that has to say what a battle changed cannot be squeezed into a column
    beside a picture. The stat rides the chip row, already carrying the words
    that say what it counts."""
    r = entry_today(ctx)
    e = r[0]
    f = front_of(e)
    col = f[1]

    c.fill("black")
    rail(c, col)
    cw = chip(c, safe(f[2]), col)

    stat = safe(e[ST])
    room = 181 - (10 + cw + 3)
    c.text(clip(c, stat, "4x5", room), 181, 1, font = "4x5", color = col,
           align = "right")

    # Three rows of 6x8 need 26px and the band is 24, so three rows means 5x7.
    b = fit_block(c, safe(e[FA]),
                  [["8x10", 2], ["6x8", 2], ["5x7", 3], ["4x5", 4]], 172)
    h = block_height(b[0], len(b[1]))
    top = ART_Y + (ART_H - h) // 2
    if top < ART_Y:
        top = ART_Y
    draw_block(c, b[1], b[0], 10, top, INK)

def timeline(c, ctx):
    """WHERE IN THE WAR. The bar runs 1937 to the end of 1945: the pale band
    is the war itself, the brighter band is the period the viewer chose, and
    the marker is today's entry. Underneath, the one live line."""
    r = entry_today(ctx)
    e = r[0]
    f = front_of(e)
    col = f[1]
    era = str(ctx.inputs.get("era", "WHOLE WAR")).strip().upper()

    c.fill("black")
    rail(c, col)
    cw = chip(c, safe(f[2]), col)

    line = wiki_line(ctx, e)
    src = "WIKIPEDIA" if line != None else "GDN ARCHIVE"
    if line == None:
        line = safe(e[NO])
    room = 181 - (10 + cw + 3)
    c.text(clip(c, src, "4x5", room), 181, 1, font = "4x5", color = DIM,
           align = "right")

    t0 = daynum(1937, 1, 1)
    t1 = daynum(1946, 1, 1)

    # The whole period, then the war inside it, then the chosen years.
    c.rect(TL_X, 8, TL_X + TL_W - 1, 13, fill = FAINT)
    w0 = tl_px(daynum(1939, 9, 1), t0, t1)
    w1 = tl_px(daynum(1945, 9, 2), t0, t1)
    c.rect(w0, 8, w1, 13, fill = STRUCT)

    if era != "WHOLE WAR":
        e0 = t0
        e1 = t1
        if era == "BEFORE THE WAR":
            e1 = daynum(1939, 9, 1)
        elif era == "1939-1941":
            e0 = daynum(1939, 9, 1)
            e1 = daynum(1942, 1, 1)
        elif era == "1942-1943":
            e0 = daynum(1942, 1, 1)
            e1 = daynum(1944, 1, 1)
        elif era == "1944-1945":
            e0 = daynum(1944, 1, 1)
        c.rect(tl_px(e0, t0, t1), 8, tl_px(e1, t0, t1), 13,
               fill = dim(col, 2, 5))

    # Year boundaries, then the year each segment belongs to, centred under it.
    for y in TL_YEARS:
        if y > 1937:
            c.vline(tl_px(daynum(y, 1, 1), t0, t1), 8, 6, "#05070C")
    for y in TL_YEARS:
        mid = tl_px(daynum(y, 7, 1), t0, t1)
        c.text(str(y)[2:], mid, 15, font = "4x5", color = DIM, align = "center")

    # Today's entry. Three pixels wide with a white core, so it reads against
    # the band it sits on whatever colour that band happens to be.
    mx = tl_px(daynum(e[YR], e[MO], e[DY]), t0, t1)
    if mx < TL_X + 1:
        mx = TL_X + 1
    if mx > TL_X + TL_W - 2:
        mx = TL_X + TL_W - 2
    c.rect(mx - 1, 8, mx + 1, 13, fill = col)
    c.vline(mx, 8, 6, INK)

    # The supplementary line, curated or live, on the two rows left.
    draw_block(c, fit_trunc(c, line, "4x5", 172, 2), "4x5", 10, 21, DIM)

# --------------------------------------------------------------- live line
def dget(d, key, fallback):
    """Every read out of a decoded response comes through here: a raised host
    error kills the whole render, and this endpoint omits fields freely."""
    if d == None or type(d) != "dict":
        return fallback
    v = d.get(key, fallback)
    return fallback if v == None else v

def wiki_line(ctx, e):
    """One supplementary line from Wikipedia's REST summary endpoint, or None.

    The endpoint silently redirects some titles to a broader article, which is
    how a panel ends up captioning one battle with another campaigns summary.
    So the title that comes back is checked against the title that was asked
    for, and anything that does not match is dropped in favour of the curated
    line. The curated name is what the rest of the app displays, always."""
    if not bool_input(ctx.inputs.get("extra", True), True):
        return None
    title = e[WK]
    r = http.get(WIKI_URL + title, headers = UA, ttl_seconds = TTL)
    if r["status_code"] != 200:
        return None
    j = r["json"]
    if j == None or type(j) != "dict":
        return None
    if str(dget(j, "type", "")) == "disambiguation":
        return None
    norm = str(dget(dget(j, "titles", {}), "normalized", ""))
    if norm.upper() != title.replace("_", " ").upper():
        return None
    ex = safe(first_sentence(dget(j, "extract", "")))
    if len(ex) < 12:
        return None
    return ex
