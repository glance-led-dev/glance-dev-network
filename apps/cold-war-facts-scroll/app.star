# Cold War Facts - a different entry from 1945-1991 every day.
#
#   headline  the theme chip, the art, the title, the date, and a timeline
#             bar showing where in the era today's entry sits
#   story     where it happened and what happened, in three lines
#   legacy    why it mattered, plus one supplementary line from Wikipedia
#
# DESIGN. This is a museum placard, not a news ticker, so it is built the way
# a wall label is: a coloured rail and a chip that say which strand of the era
# you are looking at, one piece of real artwork, a title at the largest size
# that fits, and the prose underneath in a fixed reading size. The six themes
# each own a colour and a drawing - a wall in section, a missile, a satellite,
# a globe, a keyhole, a clock - so the panel is recognisable from across a
# room before a single word is read.
#
# The artwork is drawn from primitives rather than sprite strings. At 37x18 a
# character grid costs more lines than it saves and cannot be nudged a pixel
# at a time; a wall built from rects and hlines can have its courses restaggered
# without recounting a string.
#
# The timeline bar is the one piece of chrome that earns its row twice: it
# labels the date (a marker at 1961 sits visibly left of centre) and it gives
# the app a constant, so 90 entries spanning 46 years read as one era rather
# than 90 unrelated facts.
#
# TONE. Where an entry touches repression, famine, coups, nuclear near-misses
# or mass death it states the date, the place and the scale plainly, and it
# attributes anything historians still argue about rather than asserting it.
# Several WHY lines exist only to say that the figures are disputed - the
# Chernobyl long-term toll, the Arkhipov veto account, the roles in Lumumba's
# killing. That is the honest thing to put on a wall, and it is also the more
# interesting line.
#
# DATA. Every word on the first two pages comes from the curated table below,
# which is why they cannot fail: no page except `legacy` makes a network call,
# and `legacy` falls back to the curated place and date when the call is off
# or unavailable. Live history sources were tested and rejected - Wikidata had
# no inception date for well over half a comparable roster and no country for
# any of it. Dates were checked against Wikipedia article prose; the README
# records the handful where sources genuinely disagree.
#
# Cadence: refresh 86400, and the one http.get carries a matching ttl. The URL
# changes once a day at most, so the cache is hit on every render but the first.

# ------------------------------------------------------------------ palette
INK = "#F4F7FF"
DIM = "#6E7A94"
FAINT = "#3E465A"
TRACK = "#2E3444"
OFFLINE = "#3C4043"
STONE = "#8A93A6"
MORTAR = "#5A6274"
METAL = "#C8D0E0"

# Each theme owns a colour and a drawing. The colours are far apart in hue and
# all sit well clear of black, because RGB565 collapses anything subtle.
THEMES = {
    "D": ["IRON CURTAIN", "#E8B04A"],
    "A": ["ARMS RACE", "#FF6B3D"],
    "S": ["SPACE RACE", "#46D6FF"],
    "P": ["PROXY CONFLICT", "#FF4D6A"],
    "E": ["ESPIONAGE", "#A98CFF"],
    "T": ["THAW AND COLLAPSE", "#35D48B"],
}
# THAW AND COLLAPSE is 17 characters and would push the chip past the date on
# the headline row, so the chip wears the short form and the dropdown the long.
CHIP = {
    "D": "IRON CURTAIN", "A": "ARMS RACE", "S": "SPACE RACE",
    "P": "PROXY CONFLICT", "E": "ESPIONAGE", "T": "THAW",
}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

ERA_FROM = 1945
ERA_TO = 1991

X0 = 10          # safe zone, left
X1 = 181         # safe zone, right
ARTW = 37        # the art column on the headline page, x 10..46

# ------------------------------------------------------------------- roster
# year, month, day, theme, TITLE, PLACE, WHAT HAPPENED, WHY IT MATTERED, WIKI
#
# A WIKI entry of "" means no clean ASCII article title exists (several are
# spelled with an accented "coup d'etat", which cannot be encoded into a URL
# without guessing), so those entries simply skip the live line.
FACTS = [
    # ---------------------------------------------------------- iron curtain
    (1946, 3, 5, "D", "IRON CURTAIN SPEECH", "FULTON, MISSOURI",
     "CHURCHILL TOLD A COLLEGE AUDIENCE AN IRON CURTAIN HAD FALLEN ACROSS EUROPE.",
     "THE PHRASE NAMED THE DIVISION AND STUCK.", "Iron_Curtain"),
    (1947, 3, 12, "D", "TRUMAN DOCTRINE", "WASHINGTON DC",
     "TRUMAN ASKED CONGRESS FOR 400 MILLION DOLLARS TO AID GREECE AND TURKEY.",
     "CONTAINMENT BECAME DECLARED US POLICY.", "Truman_Doctrine"),
    (1947, 6, 5, "D", "MARSHALL PLAN", "HARVARD, MASSACHUSETTS",
     "MARSHALL OFFERED AMERICAN MONEY TO REBUILD A RUINED EUROPEAN ECONOMY.",
     "MOSCOW REFUSED IT AND BARRED ITS OWN BLOC.", "Marshall_Plan"),
    (1948, 2, 25, "D", "THE PRAGUE COUP", "PRAGUE, CZECHOSLOVAKIA",
     "COMMUNIST MINISTERS TOOK FULL CONTROL OF THE CZECHOSLOVAK GOVERNMENT.",
     "THE LAST COALITION IN THE EAST WAS GONE.", ""),
    (1948, 6, 24, "D", "BERLIN BLOCKADE", "BERLIN, GERMANY",
     "THE SOVIET UNION CUT ROAD, RAIL AND CANAL ROUTES INTO WEST BERLIN.",
     "TWO MILLION PEOPLE WERE SEALED OFF BY LAND.", "Berlin_Blockade"),
    (1948, 6, 26, "D", "THE BERLIN AIRLIFT", "BERLIN, GERMANY",
     "ALLIED AIRCRAFT BEGAN FLYING COAL AND FOOD INTO THE CLOSED CITY.",
     "IT SUPPLIED A CITY BY AIR FOR ELEVEN MONTHS.", "Berlin_Blockade"),
    (1948, 6, 28, "D", "THE TITO-STALIN SPLIT", "BELGRADE, YUGOSLAVIA",
     "THE COMINFORM EXPELLED YUGOSLAVIA AFTER TITO REFUSED TO TAKE SOVIET ORDERS.",
     "A COMMUNIST STATE STOOD OUTSIDE BOTH BLOCS.", "Tito-Stalin_split"),
    (1949, 4, 4, "D", "NATO FOUNDED", "WASHINGTON DC",
     "TWELVE STATES SIGNED THE NORTH ATLANTIC TREATY IN WASHINGTON.",
     "AN ATTACK ON ONE WOULD COUNT AS AN ATTACK ON ALL.", "NATO"),
    (1953, 6, 17, "D", "EAST GERMAN UPRISING", "EAST BERLIN",
     "STRIKES BEGUN ON 16 JUNE SPREAD NATIONWIDE AND SOVIET TANKS PUT THEM DOWN.",
     "ESTIMATES OF THE DEAD VARY, COMMONLY ABOVE 50.", "East_German_uprising_of_1953"),
    (1955, 5, 14, "D", "WARSAW PACT SIGNED", "WARSAW, POLAND",
     "EIGHT COMMUNIST STATES FORMED A MILITARY ALLIANCE UNDER SOVIET COMMAND.",
     "IT ANSWERED WEST GERMANY JOINING NATO.", "Warsaw_Pact"),
    (1955, 5, 15, "D", "AUSTRIAN STATE TREATY", "VIENNA, AUSTRIA",
     "THE FOUR POWERS ENDED THE OCCUPATION AND AUSTRIA DECLARED NEUTRALITY.",
     "ONE DIVIDED COUNTRY WAS PUT BACK TOGETHER.", "Austrian_State_Treaty"),
    (1956, 6, 28, "D", "POZNAN PROTESTS", "POZNAN, POLAND",
     "POLISH WORKERS STRUCK OVER PAY AND CONDITIONS AND WERE FIRED ON BY TROOPS.",
     "TOLLS DIFFER, FROM ABOUT 60 TO 100 KILLED.", "Poznan_1956_protests"),
    (1956, 10, 23, "D", "HUNGARIAN REVOLUTION", "BUDAPEST, HUNGARY",
     "A STUDENT MARCH GREW INTO A NATIONAL REVOLT, CRUSHED BY SOVIET FORCES ON 4 NOV.",
     "ABOUT 2,500 HUNGARIANS AND 700 SOVIET TROOPS DIED.", "Hungarian_Revolution_of_1956"),
    (1961, 8, 13, "D", "THE BERLIN WALL", "BERLIN, GERMANY",
     "EAST GERMAN TROOPS SEALED THE BORDER WITH WIRE, THEN BUILT IT IN CONCRETE.",
     "IT STOPPED AN EXODUS OF SOME 2.7 MILLION.", "Berlin_Wall"),
    (1961, 10, 27, "D", "CHECKPOINT CHARLIE", "BERLIN, GERMANY",
     "AMERICAN AND SOVIET TANKS FACED EACH OTHER ACROSS THE CROSSING FOR 16 HOURS.",
     "BOTH SIDES PULLED BACK, ONE TANK AT A TIME.", "Checkpoint_Charlie"),
    (1968, 8, 21, "D", "PRAGUE SPRING ENDS", "PRAGUE, CZECHOSLOVAKIA",
     "WARSAW PACT ARMIES INVADED AND ENDED THE REFORM PROGRAMME OVERNIGHT.",
     "SOCIALISM WITH A HUMAN FACE WAS OVER.", "Prague_Spring"),
    (1987, 6, 12, "D", "TEAR DOWN THIS WALL", "WEST BERLIN",
     "REAGAN SPOKE AT THE BRANDENBURG GATE AND CALLED ON GORBACHEV TO OPEN IT.",
     "HISTORIANS DIFFER ON HOW MUCH THE SPEECH DID.", "Berlin_Wall"),

    # ------------------------------------------------------------- arms race
    (1949, 8, 29, "A", "FIRST SOVIET A-BOMB", "SEMIPALATINSK, USSR",
     "THE SOVIET UNION TESTED ITS FIRST ATOMIC DEVICE, CODENAMED RDS-1.",
     "THE AMERICAN NUCLEAR MONOPOLY WAS OVER.", "RDS-1"),
    (1952, 10, 3, "A", "BRITAIN TESTS A BOMB", "MONTE BELLO ISLANDS",
     "OPERATION HURRICANE MADE THE UNITED KINGDOM THE THIRD NUCLEAR POWER.",
     "LONDON WANTED A DETERRENT OF ITS OWN.", "Operation_Hurricane"),
    (1952, 11, 1, "A", "FIRST HYDROGEN BOMB", "ENEWETAK ATOLL",
     "THE US TEST IVY MIKE WAS THE FIRST FULL-SCALE THERMONUCLEAR EXPLOSION.",
     "YIELDS JUMPED FROM KILOTONS TO MEGATONS.", "Ivy_Mike"),
    (1954, 3, 1, "A", "CASTLE BRAVO", "BIKINI ATOLL",
     "THE LARGEST US TEST RAN FAR OVER ITS PREDICTED YIELD AND SPREAD FALLOUT.",
     "ISLANDERS AND A JAPANESE CREW WERE EXPOSED.", "Castle_Bravo"),
    (1961, 10, 30, "A", "TSAR BOMBA", "NOVAYA ZEMLYA",
     "THE SOVIET UNION DETONATED THE LARGEST NUCLEAR DEVICE EVER TESTED.",
     "ABOUT 50 MEGATONS, AND NEVER A USABLE WEAPON.", "Tsar_Bomba"),
    (1962, 10, 27, "A", "THE B-59 INCIDENT", "CARIBBEAN SEA",
     "A SOVIET SUBMARINE UNDER DEPTH CHARGES CONSIDERED ARMING A NUCLEAR TORPEDO.",
     "THE FAMOUS VETO ACCOUNT IS NOW DISPUTED.", "Soviet_submarine_B-59"),
    (1963, 6, 20, "A", "THE MOSCOW HOTLINE", "GENEVA, SWITZERLAND",
     "THE TWO CAPITALS AGREED A DIRECT TELEPRINTER LINK AFTER THE MISSILE CRISIS.",
     "IT WAS TELEPRINTER TAPE, NEVER A RED PHONE.", "Moscow-Washington_hotline"),
    (1963, 8, 5, "A", "PARTIAL TEST BAN", "MOSCOW, USSR",
     "BRITAIN, THE USSR AND THE US BANNED TESTS IN THE AIR, IN SPACE AND AT SEA.",
     "IT CUT FALLOUT, BUT UNDERGROUND TESTS WENT ON.", "Partial_Nuclear_Test_Ban_Treaty"),
    (1964, 10, 16, "A", "CHINA TESTS A BOMB", "LOP NUR, XINJIANG",
     "CHINA DETONATED ITS FIRST ATOMIC DEVICE AND BECAME THE FIFTH NUCLEAR POWER.",
     "THE CONTEST WAS NO LONGER ONLY TWO-SIDED.", "Project_596"),
    (1968, 7, 1, "A", "NON-PROLIFERATION TREATY", "THREE CAPITALS",
     "THE NPT OPENED FOR SIGNATURE IN THREE CAPITALS ON THE SAME DAY.",
     "IT IS STILL THE WIDEST ARMS TREATY IN FORCE.", "Treaty_on_the_Non-Proliferation_of_Nuclear_Weapons"),
    (1972, 5, 26, "A", "SALT I AND THE ABM TREATY", "MOSCOW, USSR",
     "NIXON AND BREZHNEV CAPPED MISSILE LAUNCHERS AND LIMITED MISSILE DEFENCES.",
     "THE FIRST REAL CEILING ON THE ARMS RACE.", "Strategic_Arms_Limitation_Talks"),
    (1983, 3, 23, "A", "STRATEGIC DEFENSE PLAN", "WASHINGTON DC",
     "REAGAN PROPOSED A SPACE-BASED SHIELD THE PRESS QUICKLY CALLED STAR WARS.",
     "CRITICS SAID IT WOULD UNSETTLE DETERRENCE.", "Strategic_Defense_Initiative"),
    (1983, 9, 26, "A", "A FALSE ALARM", "SERPUKHOV-15, USSR",
     "A SOVIET WARNING SYSTEM REPORTED INCOMING MISSILES. THE OFFICER CALLED IT FAULTY.",
     "IT WAS SUNLIGHT ON CLOUD. PETROV WAS RIGHT.", "1983_Soviet_nuclear_false_alarm_incident"),
    (1983, 11, 7, "A", "ABLE ARCHER 83", "WESTERN EUROPE",
     "A NATO COMMAND EXERCISE REHEARSED NUCLEAR RELEASE PROCEDURES.",
     "HOW ALARMED MOSCOW REALLY WAS IS DEBATED.", "Able_Archer_83"),
    (1987, 12, 8, "A", "THE INF TREATY", "WASHINGTON DC",
     "REAGAN AND GORBACHEV AGREED TO DESTROY A WHOLE CLASS OF MISSILES.",
     "THE FIRST TREATY TO CUT ARSENALS, NOT CAP THEM.", "Intermediate-Range_Nuclear_Forces_Treaty"),
    (1990, 11, 19, "A", "CFE TREATY SIGNED", "PARIS, FRANCE",
     "NATO AND WARSAW PACT STATES CAPPED TANKS, ARTILLERY AND AIRCRAFT IN EUROPE.",
     "IT SCRAPPED TENS OF THOUSANDS OF VEHICLES.", "Treaty_on_Conventional_Armed_Forces_in_Europe"),
    (1991, 7, 31, "A", "START I SIGNED", "MOSCOW, USSR",
     "THE TWO SIDES AGREED THE DEEPEST CUTS YET IN LONG-RANGE NUCLEAR ARMS.",
     "SIGNED FIVE MONTHS BEFORE THE USSR DISSOLVED.", "START_I"),

    # ------------------------------------------------------------ space race
    (1957, 10, 4, "S", "SPUTNIK 1", "TYURATAM, KAZAKH SSR",
     "THE SOVIET UNION PUT THE FIRST ARTIFICIAL SATELLITE INTO ORBIT.",
     "ITS BEEP COULD BE HEARD ON ORDINARY RADIOS.", "Sputnik_1"),
    (1957, 11, 3, "S", "LAIKA IN ORBIT", "TYURATAM, KAZAKH SSR",
     "SPUTNIK 2 CARRIED A DOG INTO ORBIT WITH NO MEANS OF BRINGING HER BACK.",
     "SHE DIED IN FLIGHT, AND ACCOUNTS LONG DIFFERED.", "Laika"),
    (1958, 1, 31, "S", "EXPLORER 1", "CAPE CANAVERAL",
     "THE FIRST AMERICAN SATELLITE FOUND THE VAN ALLEN RADIATION BELTS.",
     "THE ANSWER TO SPUTNIK TOOK FOUR MONTHS.", "Explorer_1"),
    (1959, 9, 14, "S", "LUNA 2 REACHES THE MOON", "THE MOON",
     "A SOVIET PROBE BECAME THE FIRST OBJECT FROM EARTH TO STRIKE THE MOON.",
     "IT ARRIVED BY IMPACT, NOT BY LANDING.", "Luna_2"),
    (1961, 4, 12, "S", "GAGARIN ORBITS EARTH", "BAIKONUR, KAZAKH SSR",
     "YURI GAGARIN CIRCLED THE EARTH ONCE IN VOSTOK 1 AND LANDED BY PARACHUTE.",
     "THE FIRST HUMAN BEING TO LEAVE THE PLANET.", "Yuri_Gagarin"),
    (1961, 5, 25, "S", "THE MOON PLEDGE", "WASHINGTON DC",
     "KENNEDY ASKED CONGRESS TO COMMIT TO A LUNAR LANDING BEFORE 1970.",
     "IT SET A DEADLINE THE PROGRAMME THEN MET.", "Apollo_program"),
    (1963, 6, 16, "S", "TERESHKOVA IN ORBIT", "BAIKONUR, KAZAKH SSR",
     "VALENTINA TERESHKOVA FLEW VOSTOK 6 AND SPENT NEARLY THREE DAYS IN ORBIT.",
     "THE FIRST WOMAN IN SPACE, BY TWENTY YEARS.", "Valentina_Tereshkova"),
    (1965, 3, 18, "S", "THE FIRST SPACEWALK", "VOSKHOD 2, IN ORBIT",
     "ALEXEI LEONOV LEFT HIS CRAFT FOR 12 MINUTES AND STRUGGLED TO GET BACK IN.",
     "HIS SUIT HAD STIFFENED IN THE VACUUM.", "Alexei_Leonov"),
    (1966, 2, 3, "S", "LUNA 9 LANDS", "THE MOON",
     "A SOVIET PROBE MADE THE FIRST SOFT LANDING AND SENT BACK PICTURES.",
     "IT PROVED THE SURFACE WOULD BEAR WEIGHT.", "Luna_9"),
    (1969, 7, 20, "S", "APOLLO 11 LANDS", "THE MOON",
     "ARMSTRONG AND ALDRIN LANDED IN THE SEA OF TRANQUILLITY AND WALKED OUTSIDE.",
     "THE GOAL SET IN 1961, MET WITH MONTHS TO SPARE.", "Apollo_11"),
    (1971, 4, 19, "S", "SALYUT 1", "BAIKONUR, KAZAKH SSR",
     "THE SOVIET UNION LAUNCHED THE FIRST SPACE STATION TO ORBIT THE EARTH.",
     "ITS FIRST RETURNING CREW DIED IN DESCENT.", "Salyut_1"),
    (1975, 7, 17, "S", "APOLLO-SOYUZ DOCKING", "EARTH ORBIT",
     "AN AMERICAN AND A SOVIET SPACECRAFT DOCKED AND THE CREWS SHOOK HANDS.",
     "THE SPACE RACE ENDED WITH A HANDSHAKE.", "Apollo-Soyuz"),

    # -------------------------------------------------------- proxy conflict
    (1950, 6, 25, "P", "THE KOREAN WAR BEGINS", "KOREAN PENINSULA",
     "NORTH KOREAN FORCES CROSSED THE 38TH PARALLEL AND A UN COALITION INTERVENED.",
     "ESTIMATES OF THE DEAD RUN INTO MILLIONS.", "Korean_War"),
    (1953, 8, 19, "P", "THE IRAN COUP", "TEHRAN, IRAN",
     "PRIME MINISTER MOSADDEGH WAS OVERTHROWN WITH BRITISH AND AMERICAN BACKING.",
     "THE CIA ACKNOWLEDGED ITS ROLE IN 2013.", "Mohammad_Mosaddegh"),
    (1954, 5, 7, "P", "DIEN BIEN PHU FALLS", "DIEN BIEN PHU, VIETNAM",
     "VIET MINH FORCES OVERRAN THE FRENCH GARRISON AFTER A 56-DAY SIEGE.",
     "FRENCH RULE IN INDOCHINA WAS FINISHED.", "Battle_of_Dien_Bien_Phu"),
    (1955, 4, 18, "P", "THE BANDUNG CONFERENCE", "BANDUNG, INDONESIA",
     "TWENTY-NINE ASIAN AND AFRICAN STATES MET WITHOUT THEIR FORMER RULERS.",
     "A THIRD WAY BETWEEN THE BLOCS BEGAN HERE.", "Bandung_Conference"),
    (1956, 10, 29, "P", "THE SUEZ CRISIS", "SINAI AND SUEZ",
     "ISRAEL, BRITAIN AND FRANCE ATTACKED EGYPT. US AND SOVIET PRESSURE STOPPED THEM.",
     "IT EXPOSED THE LIMITS OF OLD EUROPEAN POWER.", "Suez_Crisis"),
    (1960, 6, 30, "P", "CONGO INDEPENDENCE", "LEOPOLDVILLE, CONGO",
     "BELGIAN RULE ENDED AND THE NEW STATE FRACTURED WITHIN WEEKS.",
     "BOTH BLOCS MOVED IN ALMOST AT ONCE.", "Congo_Crisis"),
    (1961, 1, 17, "P", "LUMUMBA KILLED", "KATANGA, CONGO",
     "THE FIRST CONGOLESE PRIME MINISTER WAS KILLED IN BREAKAWAY KATANGA.",
     "BELGIAN, US AND UK ROLES ARE STILL DEBATED.", "Patrice_Lumumba"),
    (1961, 4, 17, "P", "THE BAY OF PIGS", "BAY OF PIGS, CUBA",
     "A CIA-TRAINED EXILE BRIGADE LANDED IN CUBA AND WAS DEFEATED IN THREE DAYS.",
     "IT PUSHED HAVANA CLOSER TO MOSCOW.", "Bay_of_Pigs_Invasion"),
    (1962, 10, 16, "P", "CUBAN MISSILE CRISIS", "CUBA AND WASHINGTON",
     "US PHOTOGRAPHS CONFIRMED SOVIET MISSILE SITES IN CUBA. A BLOCKADE FOLLOWED.",
     "THE CLOSEST THE TWO CAME TO NUCLEAR WAR.", "Cuban_Missile_Crisis"),
    (1964, 8, 4, "P", "THE GULF OF TONKIN", "GULF OF TONKIN",
     "A REPORTED SECOND ATTACK ON US DESTROYERS ALMOST CERTAINLY NEVER HAPPENED.",
     "CONGRESS VOTED WIDE WAR POWERS DAYS LATER.", "Gulf_of_Tonkin_incident"),
    (1968, 1, 30, "P", "THE TET OFFENSIVE", "SOUTH VIETNAM",
     "ATTACKS BEGAN ON 30 JANUARY AND SPREAD COUNTRYWIDE THE FOLLOWING DAY.",
     "A MILITARY DEFEAT THAT CHANGED US OPINION.", "Tet_Offensive"),
    (1968, 3, 16, "P", "THE MY LAI MASSACRE", "SON MY, SOUTH VIETNAM",
     "US SOLDIERS KILLED UNARMED VILLAGERS. THE ARMY CONCEALED IT FOR A YEAR.",
     "TOLLS GIVEN AS 347 BY THE US, 504 IN VIETNAM.", "My_Lai_massacre"),
    (1969, 3, 2, "P", "SINO-SOVIET BORDER CLASH", "ZHENBAO ISLAND, USSURI",
     "CHINESE AND SOVIET TROOPS FOUGHT OVER A DISPUTED RIVER ISLAND.",
     "THE COMMUNIST WORLD WAS VISIBLY SPLIT.", "Sino-Soviet_border_conflict"),
    (1973, 9, 11, "P", "THE CHILE COUP", "SANTIAGO, CHILE",
     "THE ARMED FORCES OVERTHREW PRESIDENT ALLENDE, WHO DIED IN THE PALACE.",
     "LATER COMMISSIONS COUNTED OVER 3,000 KILLED.", "Salvador_Allende"),
    (1975, 4, 30, "P", "THE FALL OF SAIGON", "SAIGON, VIETNAM",
     "NORTH VIETNAMESE FORCES ENTERED THE CITY AS THE LAST AMERICANS FLEW OUT.",
     "THIRTY YEARS OF WAR IN VIETNAM ENDED.", "Fall_of_Saigon"),
    (1975, 11, 11, "P", "ANGOLAN INDEPENDENCE", "LUANDA, ANGOLA",
     "PORTUGUESE RULE ENDED AND RIVAL MOVEMENTS FOUGHT ON WITH FOREIGN BACKING.",
     "CUBAN AND SOUTH AFRICAN TROOPS BOTH DEPLOYED.", "Angolan_Civil_War"),
    (1979, 12, 25, "P", "SOVIET INVASION OF AFGHANISTAN", "KABUL, AFGHANISTAN",
     "SOVIET FORCES ENTERED AFGHANISTAN AND INSTALLED A NEW GOVERNMENT.",
     "AFGHAN DEATH ESTIMATES VARY WIDELY, IN MILLIONS.", "Soviet-Afghan_War"),
    (1983, 9, 1, "P", "FLIGHT KAL 007", "SEA OF JAPAN",
     "A SOVIET FIGHTER SHOT DOWN A KOREAN AIRLINER THAT HAD STRAYED INTO ITS AIRSPACE.",
     "ALL 269 ON BOARD DIED. THE CAUSE WAS DISPUTED.", "Korean_Air_Lines_Flight_007"),
    (1989, 2, 15, "P", "SOVIETS LEAVE AFGHANISTAN", "TERMEZ, UZBEK SSR",
     "THE LAST SOVIET COLUMN CROSSED THE FRIENDSHIP BRIDGE OUT OF AFGHANISTAN.",
     "SOVIET DEAD: 14,500 OFFICIALLY, MORE BY OTHERS.", "Soviet-Afghan_War"),

    # ------------------------------------------------------------- espionage
    (1945, 9, 5, "E", "THE GOUZENKO DEFECTION", "OTTAWA, CANADA",
     "A SOVIET CIPHER CLERK WALKED OUT WITH FILES ON A SPY NETWORK IN CANADA.",
     "OFTEN CALLED THE FIRST SHOT OF THE COLD WAR.", "Igor_Gouzenko"),
    (1946, 12, 20, "E", "THE VENONA BREAK", "ARLINGTON, VIRGINIA",
     "US CODEBREAKERS READ PART OF A SOVIET CABLE FOR THE FIRST TIME.",
     "THE PROGRAMME STAYED SECRET UNTIL 1995.", "Venona_project"),
    (1950, 2, 2, "E", "KLAUS FUCHS ARRESTED", "LONDON, ENGLAND",
     "A PHYSICIST ON THE BOMB PROJECT ADMITTED PASSING DESIGNS TO MOSCOW.",
     "IT SHOWED HOW EARLY THE SECRETS HAD GONE.", "Klaus_Fuchs"),
    (1953, 6, 19, "E", "THE ROSENBERG CASE", "SING SING, NEW YORK",
     "JULIUS AND ETHEL ROSENBERG WERE EXECUTED FOR CONSPIRACY TO COMMIT ESPIONAGE.",
     "LATER FILES SUPPORT HIS GUILT, NOT HERS.", "Julius_and_Ethel_Rosenberg"),
    (1956, 4, 22, "E", "THE BERLIN TUNNEL", "BERLIN, GERMANY",
     "SOVIET CREWS UNCOVERED AN ALLIED TUNNEL TAPPING MILITARY PHONE LINES.",
     "MOSCOW KNEW OF IT FROM A MOLE THROUGHOUT.", "Operation_Gold"),
    (1960, 5, 1, "E", "THE U-2 SHOT DOWN", "SVERDLOVSK, USSR",
     "A SOVIET MISSILE BROUGHT DOWN A US SPY PLANE AND ITS PILOT WAS CAPTURED.",
     "IT WRECKED THE PARIS SUMMIT TWO WEEKS LATER.", "1960_U-2_incident"),
    (1962, 2, 10, "E", "THE BRIDGE EXCHANGE", "GLIENICKE BRIDGE",
     "PILOT GARY POWERS WAS TRADED FOR THE SOVIET AGENT RUDOLF ABEL.",
     "THE BRIDGE SERVED FOR SWAPS UNTIL 1986.", "Glienicke_Bridge"),
    (1963, 1, 23, "E", "PHILBY DEFECTS", "BEIRUT, LEBANON",
     "A SENIOR BRITISH OFFICER VANISHED FROM BEIRUT AND SURFACED IN MOSCOW.",
     "HE HAD SERVED MOSCOW FOR THIRTY YEARS.", "Kim_Philby"),
    (1985, 5, 20, "E", "THE WALKER SPY RING", "NORFOLK, VIRGINIA",
     "A US NAVY OFFICER WAS ARRESTED AFTER SELLING CIPHER KEYS FOR 17 YEARS.",
     "IT COMPROMISED NAVAL SIGNALS FOR YEARS.", "John_Anthony_Walker"),

    # ----------------------------------------------------- thaw and collapse
    (1953, 3, 5, "T", "STALIN DIES", "MOSCOW, USSR",
     "JOSEPH STALIN DIED AT HIS DACHA AFTER A STROKE, AGED 74.",
     "A COLLECTIVE LEADERSHIP AND A THAW FOLLOWED.", "Joseph_Stalin"),
    (1956, 2, 25, "T", "THE SECRET SPEECH", "MOSCOW, USSR",
     "KHRUSHCHEV DENOUNCED STALIN TO A CLOSED SESSION OF THE PARTY CONGRESS.",
     "THE TEXT LEAKED AND SHOOK COMMUNIST PARTIES.", "On_the_Cult_of_Personality_and_Its_Consequences"),
    (1972, 2, 21, "T", "NIXON IN CHINA", "BEIJING, CHINA",
     "THE US PRESIDENT VISITED A COUNTRY WASHINGTON HAD NOT RECOGNISED IN 22 YEARS.",
     "IT TURNED A TWO-SIDED CONTEST INTO A TRIANGLE.", "1972_Nixon_visit_to_China"),
    (1975, 8, 1, "T", "THE HELSINKI FINAL ACT", "HELSINKI, FINLAND",
     "THIRTY-FIVE STATES ACCEPTED EUROPES BORDERS AND SIGNED HUMAN RIGHTS CLAUSES.",
     "DISSIDENTS USED THOSE CLAUSES AGAINST THEM.", "Helsinki_Accords"),
    (1980, 8, 31, "T", "THE GDANSK AGREEMENT", "GDANSK, POLAND",
     "STRIKING SHIPYARD WORKERS WON THE RIGHT TO AN INDEPENDENT TRADE UNION.",
     "THE NATIONAL UNION FOLLOWED THAT SEPTEMBER.", "Gdansk_Agreement"),
    (1981, 12, 13, "T", "MARTIAL LAW IN POLAND", "WARSAW, POLAND",
     "GENERAL JARUZELSKI SUSPENDED SOLIDARITY AND INTERNED THOUSANDS.",
     "THE UNION SURVIVED UNDERGROUND FOR EIGHT YEARS.", "Martial_law_in_Poland"),
    (1985, 3, 11, "T", "GORBACHEV TAKES OVER", "MOSCOW, USSR",
     "MIKHAIL GORBACHEV BECAME GENERAL SECRETARY AT THE AGE OF 54.",
     "GLASNOST AND PERESTROIKA FOLLOWED.", "Mikhail_Gorbachev"),
    (1986, 4, 26, "T", "CHERNOBYL", "PRIPYAT, UKRAINIAN SSR",
     "REACTOR FOUR EXPLODED DURING A TEST AND SPREAD FALLOUT ACROSS EUROPE.",
     "ACUTE DEATHS ABOUT 30. LONG-TERM TOLLS DIFFER.", "Chernobyl_disaster"),
    (1986, 10, 11, "T", "THE REYKJAVIK SUMMIT", "REYKJAVIK, ICELAND",
     "THE TWO CAME CLOSE TO DEEP CUTS, THEN BROKE OVER MISSILE DEFENCE.",
     "THE GROUNDWORK FOR THE INF TREATY WAS LAID.", "Reykjavik_Summit"),
    (1989, 6, 4, "T", "POLAND VOTES", "POLAND",
     "SOLIDARITY WON ALMOST EVERY SEAT IT WAS ALLOWED TO CONTEST, IN TWO ROUNDS.",
     "THE FIRST BLOC GOVERNMENT VOTED OUT OF POWER.", "1989_Polish_legislative_election"),
    (1989, 11, 9, "T", "THE WALL OPENS", "BERLIN, GERMANY",
     "A CONFUSED PRESS BRIEFING SENT CROWDS TO THE GATES AND GUARDS STOOD ASIDE.",
     "THE BORDER HAD HELD FOR 28 YEARS.", "Berlin_Wall"),
    (1989, 12, 25, "T", "THE ROMANIAN REVOLUTION", "TARGOVISTE, ROMANIA",
     "NICOLAE AND ELENA CEAUSESCU WERE TRIED BY A MILITARY COURT AND SHOT.",
     "THE ONLY 1989 CHANGE THAT TURNED VIOLENT.", "Romanian_Revolution"),
    (1990, 10, 3, "T", "GERMANY REUNIFIED", "BERLIN, GERMANY",
     "THE TWO GERMAN STATES JOINED UNDER THE FEDERAL REPUBLIC.",
     "FORTY-ONE YEARS OF TWO GERMANYS ENDED.", "German_reunification"),
    (1991, 7, 1, "T", "THE WARSAW PACT ENDS", "PRAGUE, CZECHOSLOVAKIA",
     "MEMBERS SIGNED THE MILITARY ALLIANCE OUT OF EXISTENCE.",
     "ITS COMMAND HAD GONE IN FEBRUARY.", "Warsaw_Pact"),
    (1991, 8, 19, "T", "THE AUGUST COUP", "MOSCOW, USSR",
     "HARDLINERS DETAINED GORBACHEV AND SENT TANKS INTO MOSCOW. IT FAILED IN DAYS.",
     "IT DESTROYED THE AUTHORITY IT MEANT TO SAVE.", "1991_Soviet_coup_attempt"),
    (1991, 12, 25, "T", "THE SOVIET UNION ENDS", "MOSCOW, USSR",
     "GORBACHEV RESIGNED AND THE RED FLAG CAME DOWN OVER THE KREMLIN.",
     "FIFTEEN REPUBLICS BECAME INDEPENDENT STATES.", "Dissolution_of_the_Soviet_Union"),
]

THEME_BY_LABEL = {
    "IRON CURTAIN": "D", "ARMS RACE": "A", "SPACE RACE": "S",
    "PROXY CONFLICT": "P", "ESPIONAGE": "E", "THAW AND COLLAPSE": "T",
}

# --------------------------------------------------------------------- text
# Every bundled font is uppercase and carries exactly these glyphs. History
# text is full of apostrophes and accents, and NO font has an apostrophe, so
# anything drawn goes through clean() first - including the Wikipedia line,
# which is the only string here the app did not write itself.
GLYPHS = " !#$%&()*+,-./0123456789:?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Folded before the glyph filter runs, so CEAUSESCU keeps its letters instead
# of losing them. Uppercase only: .upper() has already run, and an uppercase
# table keeps the lowercase linter quiet. Typographic punctuation is folded to
# the plain forms the fonts do carry; the apostrophes are dropped outright.
FOLDS = [
    ["Á", "A"], ["À", "A"], ["Â", "A"], ["Ä", "A"],
    ["Ã", "A"], ["Å", "A"], ["Ă", "A"], ["Ą", "A"],
    ["Ç", "C"], ["Č", "C"], ["Ć", "C"],
    ["É", "E"], ["È", "E"], ["Ê", "E"], ["Ë", "E"],
    ["Ě", "E"], ["Ę", "E"],
    ["Í", "I"], ["Ì", "I"], ["Î", "I"], ["Ï", "I"],
    ["İ", "I"],
    ["Ñ", "N"], ["Ň", "N"], ["Ń", "N"],
    ["Ó", "O"], ["Ò", "O"], ["Ô", "O"], ["Ö", "O"],
    ["Õ", "O"], ["Ø", "O"],
    ["Š", "S"], ["Ś", "S"], ["Ș", "S"], ["Ş", "S"],
    ["Ú", "U"], ["Ù", "U"], ["Û", "U"], ["Ü", "U"],
    ["Ů", "U"],
    ["Ý", "Y"], ["Ÿ", "Y"],
    ["Ž", "Z"], ["Ź", "Z"], ["Ż", "Z"],
    ["Ł", "L"], ["Đ", "D"], ["Ď", "D"],
    ["Ř", "R"], ["Ť", "T"], ["Ț", "T"], ["Ğ", "G"],
    ["Æ", "AE"], ["Œ", "OE"], ["ß", "SS"],
    ["’", ""], ["‘", ""], ["'", ""], ["“", ""],
    ["”", ""], ["\"", ""],
    ["–", "-"], ["—", "-"], ["−", "-"], ["·", "-"],
    ["…", "..."], [";", ","], ["=", "-"], ["_", " "],
]

def strip_parens(s):
    """Drop parenthetical groups. Wikipedia descriptions spend them almost
    entirely on life dates - "CONGOLESE POLITICIAN AND INDEPENDENCE LEADER
    (1925-1961)" - which the panel already carries in its own date, and which
    cost the words that actually say something. Dropping them also removes most
    of the clipping: both that line and "SOVIET DOG, FIRST ANIMAL TO ORBIT
    EARTH (C. 1954-1957)" fit whole once the bracket is gone, where before they
    were cut mid-bracket to "INDEPENDENCE.." and "EARTH (C..".
    """
    out = ""
    depth = 0
    for ch in str(s).elems():
        if ch == "(":
            depth += 1
        elif ch == ")":
            if depth > 0:
                depth -= 1
        elif depth == 0:
            out += ch
    return out

def clean(s):
    """Fold, then keep only glyphs a bundled font can actually draw. Anything
    that survives neither step is dropped rather than drawn as a blank box."""
    t = str(s).upper()
    for pair in FOLDS:
        if pair[0] in t:
            t = t.replace(pair[0], pair[1])
    out = ""
    for ch in t.elems():
        if ch in GLYPHS:
            out += ch
    # A fold can leave a double space behind; two passes cover the cases that
    # matter without a loop that could run away on a long extract.
    out = out.replace("  ", " ").replace("  ", " ")
    return out.strip()

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    """clip(), then backed up to a whole word and marked with .. so the cut
    reads as deliberate. A Wikipedia description cut mid-word looks like a
    rendering bug; the same cut at a space looks like an abbreviation."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    room = maxw - c.text_width("..", font)
    if room <= 0:
        return clip(c, t, font, maxw)
    cut = clip(c, t, font, room)
    sp = cut.rfind(" ")
    # Backing up past a third of the string costs more than it buys.
    if sp > len(cut) // 3:
        cut = cut[:sp]
    cut = cut.rstrip()
    # A word boundary can still leave dangling punctuation behind - "EARTH ("
    # or "LEADER," - and "(.." reads as a rendering fault rather than as a cut.
    for _ in range(3):
        if len(cut) > 0 and cut[len(cut) - 1] in "(,-.:":
            cut = cut[:len(cut) - 1].rstrip()
    return cut + ".."

def wrap(c, text, font, w):
    """Word-wrap into a list of lines. A single word wider than the box is
    left long here and clipped by the caller, which keeps the wrapper honest
    about how many lines the text really needs."""
    lines = []
    cur = ""
    for word in str(text).split(" "):
        if word == "":
            continue
        cand = word if cur == "" else cur + " " + word
        if cur == "" or c.text_width(cand, font) <= w:
            cur = cand
        else:
            lines.append(cur)
            cur = word
    if cur != "":
        lines.append(cur)
    return lines

def wrap_fit(c, text, opts, w):
    """opts is [[font, max_lines], ...] largest first. Returns the first pair
    whose wrap fits in its own line budget, so a short title gets 10x16 and a
    long one steps down rather than being clipped at the big size."""
    for o in opts:
        lines = wrap(c, text, o[0], w)
        if len(lines) <= o[1]:
            return [o[0], lines]
    last = opts[len(opts) - 1]
    lines = wrap(c, text, last[0], w)[:last[1]]
    out = []
    for ln in lines:
        out.append(clip(c, ln, last[0], w))
    return [last[0], out]

HEXD = "0123456789abcdef"

def ink_for(fill):
    """Black or white on a chip, whichever the fill can actually carry."""
    h = str(fill).lower()
    if not h.startswith("#") or len(h) != 7:
        return "black"
    v = [HEXD.find(h[i]) * 16 + HEXD.find(h[i + 1]) for i in [1, 3, 5]]
    return "black" if (299 * v[0] + 587 * v[1] + 114 * v[2]) // 1000 >= 150 else "white"

def pad2(n):
    # The % operator here has no width flags, so padding is done by hand.
    return str(n) if n >= 10 else "0" + str(n)

def date_text(f):
    return str(f[2]) + " " + MONTHS[f[1] - 1] + " " + str(f[0])

def decade_of(y):
    if y < 1950:
        return "1940S"
    if y < 1960:
        return "1950S"
    if y < 1970:
        return "1960S"
    if y < 1980:
        return "1970S"
    if y < 1990:
        return "1980S"
    return "1990S"

# ------------------------------------------------------------------ artwork
# Drawn from primitives at 37x18 from (x, y). Each piece is built so nothing
# reaches outside that box, because the title column starts 3px to the right
# of it and the timeline bar sits one row below.

def art_wall(c, x, y, col):
    """The Berlin Wall in section: two grounds at different brightnesses, a
    slab with staggered courses, and the round pipe cap in the theme colour.
    The staggering is what makes 10px of grey read as masonry rather than as
    a plain rectangle."""
    c.hline(x, y + 16, 14, "#3A4152")            # west side, lighter
    c.hline(x, y + 17, 14, "#2A3040")
    c.hline(x + 24, y + 16, 13, "#262C3A")       # east side, darker
    c.hline(x + 24, y + 17, 13, "#1C2230")
    c.rect(x + 14, y + 4, x + 23, y + 17, fill = STONE)
    c.hline(x + 14, y + 8, 10, MORTAR)
    c.hline(x + 14, y + 12, 10, MORTAR)
    c.vline(x + 18, y + 4, 4, MORTAR)
    c.vline(x + 16, y + 9, 3, MORTAR)
    c.vline(x + 20, y + 13, 5, MORTAR)
    c.rect(x + 13, y + 2, x + 24, y + 3, fill = col)
    # A watchtower reduced to its silhouette, east side, well clear of the slab.
    c.vline(x + 30, y + 9, 7, "#4A5468")
    c.vline(x + 32, y + 9, 7, "#4A5468")
    c.rect(x + 29, y + 6, x + 33, y + 8, fill = "#5A6274")

def art_missile(c, x, y, col):
    cx = x + 15
    c.fill_triangle(cx, y + 1, cx - 3, y + 7, cx + 3, y + 7, col)
    c.rect(cx - 3, y + 7, cx + 3, y + 14, fill = METAL)
    c.hline(cx - 3, y + 10, 7, col)
    c.fill_triangle(cx - 4, y + 16, cx - 4, y + 11, cx - 8, y + 16, "#8A93A6")
    c.fill_triangle(cx + 4, y + 16, cx + 4, y + 11, cx + 8, y + 16, "#8A93A6")
    c.vline(cx, y + 15, 2, col)
    c.hline(x + 4, y + 17, 23, "#3A4152")
    # A launch gantry on the right, so the missile reads as standing, not flying.
    c.vline(x + 30, y + 3, 15, "#4A5468")
    c.hline(x + 27, y + 5, 4, "#4A5468")
    c.hline(x + 27, y + 11, 4, "#4A5468")

def art_satellite(c, x, y, col):
    cx = x + 13
    cy = y + 7
    c.fill_circle(cx, cy, 4, METAL)
    c.fill_circle(cx - 1, cy - 1, 1, "white")
    # Four antennae trailing one way, as Sputnik carried them.
    c.line(cx + 3, cy + 1, cx + 16, cy + 4, col)
    c.line(cx + 3, cy + 2, cx + 17, cy + 9, col)
    c.line(cx + 2, cy + 4, cx + 14, cy + 14, col)
    c.line(cx + 1, cy + 4, cx + 8, cy + 16, col)
    # A dotted orbit under it, dim enough not to compete with the antennae.
    c.pixel(x + 1, y + 13, FAINT)
    c.pixel(x + 3, y + 15, FAINT)
    c.pixel(x + 6, y + 16, FAINT)
    c.pixel(x + 9, y + 17, FAINT)

def art_globe(c, x, y, col):
    cx = x + 18
    cy = y + 9
    c.circle(cx, cy, 8, "#7A86A0")
    c.hline(cx - 6, cy - 4, 13, "#49536A")
    c.hline(cx - 8, cy, 17, "#49536A")
    c.hline(cx - 6, cy + 4, 13, "#49536A")
    c.vline(cx, cy - 8, 17, "#49536A")
    # Three flashpoints, deliberately spread across the disc rather than
    # placed at real coordinates - at 17px across, a real map is a smear.
    c.fill_circle(cx - 4, cy - 2, 1, col)
    c.fill_circle(cx + 3, cy + 3, 1, col)
    c.fill_circle(cx + 5, cy - 4, 1, col)

def art_keyhole(c, x, y, col):
    """A keyhole is a dark void in a lit plate. The first cut drew it the other
    way round - a bright keyhole on a dark plate - and on the contact sheet it
    read as a chess pawn, because a light shape on dark is a piece, not a hole.
    The theme colour is spent on the light coming through the hole and on the
    two listening arcs, never on the plate."""
    c.round_rect(x + 9, y + 1, x + 27, y + 17, 3, fill = STONE, outline = "#B6BECE")
    c.fill_circle(x + 18, y + 7, 3, "#10141C")
    c.fill_triangle(x + 18, y + 8, x + 15, y + 14, x + 21, y + 14, "#10141C")
    c.pixel(x + 18, y + 7, col)
    # Escutcheon screws, clear of the hole at x 15..21.
    c.pixel(x + 12, y + 4, MORTAR)
    c.pixel(x + 24, y + 4, MORTAR)
    c.pixel(x + 12, y + 14, MORTAR)
    c.pixel(x + 24, y + 14, MORTAR)
    c.vline(x + 5, y + 6, 7, col)
    c.vline(x + 2, y + 4, 11, "#4A5468")

def art_clock(c, x, y, col):
    """A clock face with its hands pulled back from midnight - the era's own
    symbol, and the one piece of art here that carries a direction."""
    cx = x + 18
    cy = y + 9
    c.circle(cx, cy, 8, METAL)
    c.vline(cx, cy - 7, 2, DIM)
    c.vline(cx, cy + 6, 2, DIM)
    c.hline(cx - 7, cy, 2, DIM)
    c.hline(cx + 6, cy, 2, DIM)
    c.line(cx, cy, cx - 4, cy - 5, col)      # minute hand, backed off midnight
    c.line(cx, cy, cx - 1, cy - 4, col)      # hour hand
    c.fill_circle(cx, cy, 1, col)

def draw_art(c, key, x, y, col):
    if key == "D":
        art_wall(c, x, y, col)
    elif key == "A":
        art_missile(c, x, y, col)
    elif key == "S":
        art_satellite(c, x, y, col)
    elif key == "P":
        art_globe(c, x, y, col)
    elif key == "E":
        art_keyhole(c, x, y, col)
    else:
        art_clock(c, x, y, col)

# ------------------------------------------------------------------- chrome
def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def pill(c, word, fill, x, y):
    return c.badge(word, x, y, color = ink_for(fill), bg = fill, font = "4x5")

def chip_row(c, left, right, left_col, right_col):
    """Right first, then the left text fitted into whatever is left over, so
    the two can never draw through each other however long a place name is."""
    rw = 0
    if right != "":
        rw = c.text_width(right, "4x5")
        c.text(right, X1, 1, font = "4x5", color = right_col, align = "right")
    room = X1 - rw - 4 - X0 + 1
    if left != "" and room > 0:
        c.text(clip_words(c, left, "4x5", room), X0, 1, font = "4x5", color = left_col)

def timeline(c, year, col):
    """Where this date sits in 1945-1991. The marker is clamped so the arrow
    stays inside the safe zone at both ends - 1945 and 1991 both land on an
    end cap, and an unclamped triangle would draw at x=7."""
    span = ERA_TO - ERA_FROM
    y = year
    if y < ERA_FROM:
        y = ERA_FROM
    if y > ERA_TO:
        y = ERA_TO
    px = X0 + (y - ERA_FROM) * (X1 - X0) // span
    c.hline(X0, 30, X1 - X0 + 1, TRACK)
    for dec in [1950, 1960, 1970, 1980, 1990]:
        tx = X0 + (dec - ERA_FROM) * (X1 - X0) // span
        c.vline(tx, 29, 3, FAINT)
    c.vline(X0, 28, 4, "#4A5468")
    c.vline(X1, 28, 4, "#4A5468")
    mx = px
    if mx < X0 + 3:
        mx = X0 + 3
    if mx > X1 - 3:
        mx = X1 - 3
    c.fill_triangle(px, 29, mx - 3, 26, mx + 3, 26, col)
    c.vline(px, 29, 3, col)

# ---------------------------------------------------------------- selection
def filter_pool(tkey, dec):
    """Returns [pool, widened]. widened names the decade that was dropped when
    a theme and a decade together match nothing - SPACE RACE has no 1990S
    entry, and a blank panel is a worse answer than a wider one."""
    out = []
    for f in FACTS:
        if tkey != "" and f[3] != tkey:
            continue
        if dec != "" and dec != "ALL" and decade_of(f[0]) != dec:
            continue
        out.append(f)
    if len(out) > 0:
        return [out, ""]
    wide = []
    for f in FACTS:
        if tkey != "" and f[3] != tkey:
            continue
        wide.append(f)
    if len(wide) > 0:
        return [wide, dec]
    return [FACTS, dec]

def settings(ctx):
    theme = clean(ctx.inputs.get("theme", "ALL"))
    dec = clean(ctx.inputs.get("decade", "ALL"))
    if theme == "":
        theme = "ALL"
    if dec == "":
        dec = "ALL"
    tkey = THEME_BY_LABEL.get(theme, "")
    return [tkey, dec]

def pick(ctx):
    """One entry per day. The year term shifts where the sequence starts, so
    the same date does not land on the same entry every year."""
    s = settings(ctx)
    pool_w = filter_pool(s[0], s[1])
    pool = pool_w[0]
    idx = (ctx.now.yday - 1 + ctx.now.year * 3) % len(pool)
    return [pool[idx], idx, len(pool), pool_w[1], s[1]]

def wiki_on(ctx):
    v = str(ctx.inputs.get("wiki", "true")).strip().upper()
    return v not in ["FALSE", "0", "NO", "OFF", ""]

# --------------------------------------------------------------------- feed
WIKI = "https://en.wikipedia.org/api/rest_v1/page/summary/"
HEADERS = {"User-Agent": "glance-cold-war-facts (glance-led.dev)"}
TTL = 86400

def wiki_line(ctx, title):
    """One short supplementary line, and only ever on the `legacy` page.

    The REST summary's `description` field is the one-line Wikidata descriptor
    ("1948-1949 SOVIET BLOCKADE OF WEST BERLIN"), which is exactly a caption;
    `extract` is a full paragraph that would arrive as a clipped fragment, so
    it is only the fallback. The endpoint silently redirects some titles to a
    generic article, which is why the panel always draws the curated title and
    never the one that comes back."""
    if title == "":
        return ""
    url = WIKI + title.replace("&", "%26")
    r = http.get(url, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] != 200:
        return ""
    j = r["json"]
    if type(j) != "dict":
        return ""
    d = j.get("description", "")
    if type(d) != "string" or len(d) < 3:
        d = j.get("extract", "")
    if type(d) != "string":
        return ""
    return clean(strip_parens(d))

# -------------------------------------------------------------- page: title
def headline(c, ctx):
    p = pick(ctx)
    f = p[0]
    col = THEMES[f[3]][1]

    c.fill("black")
    rail(c, col)
    chip_row(c, "", date_text(f), INK, INK)
    pill(c, CHIP[f[3]], col, X0, 0)

    draw_art(c, f[3], X0, 8, col)

    # The title band is y 8..25: 18 rows, which is one 10x16 line, or two 6x8,
    # or three 4x5. Two 8x10 lines would need 21 and are not offered.
    tx = X0 + ARTW + 3
    tw = X1 - tx + 1
    fit = wrap_fit(c, clean(f[4]),
                   [["10x16", 1], ["8x10", 1], ["6x8", 2], ["5x7", 2], ["4x5", 3]], tw)
    font = fit[0]
    lines = fit[1]
    fh = {"10x16": 16, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}[font]
    block = len(lines) * fh + (len(lines) - 1)
    ty = 8 + (18 - block) // 2
    if ty < 8:
        ty = 8
    for ln in lines:
        c.text(ln, tx, ty, font = font, color = INK)
        ty += fh + 1

    timeline(c, f[0], col)

# -------------------------------------------------------------- page: story
def story(c, ctx):
    p = pick(ctx)
    f = p[0]
    col = THEMES[f[3]][1]

    c.fill("black")
    rail(c, col)

    # Right: the filter actually in force and this entry's place in the
    # rotation, so both dropdowns are visible on the panel. When a decade was
    # dropped because the combination was empty, it says so instead.
    # The decade only earns a place in the tag when it is actually filtering.
    # Printed unconditionally it produced "ALL 14/17", which reads as though
    # ALL qualified the 14 rather than naming the decade setting.
    tag = str(p[1] + 1) + "/" + str(p[2])
    if p[4] != "ALL":
        tag = p[4] + " " + tag
    if p[3] != "":
        tag = "NO " + p[3] + " ENTRY"
    chip_row(c, clean(f[5]), tag, col, DIM)

    fit = wrap_fit(c, clean(f[6]), [["5x7", 3], ["4x5", 4]], X1 - X0 + 1)
    font = fit[0]
    fh = 7 if font == "5x7" else 5
    y = 8
    for ln in fit[1]:
        c.text(ln, X0, y, font = font, color = INK)
        y += fh + 1

# ------------------------------------------------------------- page: legacy
def legacy(c, ctx):
    p = pick(ctx)
    f = p[0]
    col = THEMES[f[3]][1]

    extra = ""
    if wiki_on(ctx):
        extra = wiki_line(ctx, f[8])
    live = extra != ""
    # Offline, switched off, or an entry with no clean article title: the row
    # still carries something true, so the page never reads as broken.
    if not live:
        extra = clean(f[5]) + " - " + date_text(f)

    c.fill("black")
    # The rail stays the theme colour whether or not the live line arrived:
    # a missing supplementary sentence is not an error state, and dressing it
    # as one would have the panel contradict itself.
    rail(c, col)
    chip_row(c, "WHY IT MATTERED", "WIKIPEDIA" if live else str(f[0]), DIM, DIM)

    fit = wrap_fit(c, clean(f[7]), [["5x7", 2], ["4x5", 3]], X1 - X0 + 1)
    font = fit[0]
    fh = 7 if font == "5x7" else 5
    y = 8
    for ln in fit[1]:
        c.text(ln, X0, y, font = font, color = INK)
        y += fh + 1

    # The hairline is drawn only for the live row: it means "below this came
    # from somewhere else", so it would be a lie above the curated fallback.
    if live:
        c.hline(X0, 24, X1 - X0 + 1, TRACK)
    # Both rows read at the same weight: the curated fallback is no less true
    # than the live line, and FAINT on black is not legible across a room.
    # What separates them is the hairline and the WIKIPEDIA tag, not contrast.
    ef = "4x5" if c.text_width(extra, "4x5") <= X1 - X0 + 1 else "picopixel"
    c.text(clip_words(c, extra, ef, X1 - X0 + 1), X0, 26, font = ef, color = DIM)
