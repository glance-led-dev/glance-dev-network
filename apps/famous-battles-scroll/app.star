# Famous Battles - a different battle each day, from the Bronze Age to the
# twentieth century, written like a museum placard.
#
# ROSTER. Curated, 73 battles, deliberately global: Megiddo and Kadesh in
# the Bronze Age Levant, Red Cliffs on the Yangtze, Talas, Sekigahara,
# Plassey, Ain Jalut, Isandlwana, Omdurman, the Little Bighorn. Every date
# here was checked against the prose of the Wikipedia article rather than
# taken from Wikidata, which on a comparable roster had no date at all for
# more than half the entries.
#
# THE MAP. Positions are not guessed. Wikipedia's REST summary carries a
# coordinates field for geolocated articles, and those were converted to
# cells on the same 80x32 world map the internet-outages app draws.
#
# That map is NOT a full equirectangular sheet: its own note says 84N to
# 58S, so latitude spans 142 degrees over 32 rows rather than 180. Using
# the full range would put every battle several rows too far south. The
# conversion was checked by reproducing that app's own country cells for
# Britain, Japan and Australia exactly before any battle was placed.
#
# Seven entries have no coordinates on Wikipedia, mostly because they are
# campaigns rather than points: Hastings, the Spanish Armada, Lutzen,
# Borodino, the Marne, Britain and Berlin. Those were placed by hand at a
# representative location through the same formula.
#
# LIVE. Only the STORY page goes to the network. BATTLE and WHERE are pure
# curated data and cannot fail, so the panel survives the network going
# down.
#
# TONE. These were catastrophes for the people in them. The placards say
# who fought, what happened and what changed, in the register a museum
# label uses. They do not celebrate.

REST = "https://en.wikipedia.org/api/rest_v1/page/summary/"
UA = {"User-Agent": "glance-famous-battles (glance-led.dev)"}

INK = "#FFFFFF"
DIM = "#7C8BA1"
DARK = "#8A94A6"
LAND = "#24405E"
GRID = "#16243A"
STEEL = "#C3CEDC"

MAP_X = 10
MAP_W = 80

# Era by year, with the colour the whole panel takes.
ERAS = [
    [500, "#C9862E", "ANCIENT"],
    [1500, "#B0483C", "MEDIEVAL"],
    [1900, "#D9A441", "GUNPOWDER"],
    [9999, "#6E93C8", "MODERN"],
]

# --------------------------------------------------------------- the world
# Equirectangular, 84N to 58S, 80 x 32, the same sheet the internet-outages
# app uses. One character: the land is a backdrop and the battle is marked
# on top of it.
WORLD = """
..................###################.....####....#.........###.................
.............#######################......####.......##.....######....###.......
#....#......############...#########.........#.....##..####################.....
##.#######################..#######........#####################################
##########################..####..###....#######################################
...#################..####...##........#.######################################.
...###....##################..........##.###############################..###...
..........##################..........##################################..#.....
............#################..........#################################........
............#############.............################################.##.......
............############..............##################################........
.............##########..............##############################.###.........
..............#########..............###############################............
...............####..##.............###############################.............
.....#..........#####.####..........#################..##########.#.............
..................####..............################....###..####.##............
....................#######.........################....##...####.##............
.....................########........##############......##..##..####...........
......................#######.............#########..........########...........
......................##########..........########............############......
......................###########.........#######..............#############....
......................##########..........#######.................##.###.#.#....
.......................#########..........##########...............######....#.#
........................########..........######.##..............#########..#...
........................#######............#####.##..............#########......
........................######.............#####.................##########.....
........................#####...............###..................#########....#.
.......................#####...........................................###....##
.......................###..............................................#....##.
.......................###.............................#.....................#..
.......................##.#............................#........................
........................##......................................................
"""

# name, year, year text, place, war, shape, what happened, region, cx, cy,
# wikipedia title. Year is an integer so BC sorts and filters correctly.
ROSTER = [
    ["MEGIDDO", -1457, "1457 BC", "ISRAEL", "EGYPTIAN CAMPAIGNS", "SPEAR",
     "THE EARLIEST BATTLE RECORDED IN RELIABLE DETAIL, BY EGYPTIAN SCRIBES",
     "MIDDLE EAST", 47, 11, "Battle of Megiddo (15th century BC)"],
    ["KADESH", -1274, "1274 BC", "SYRIA", "EGYPTIAN HITTITE WAR", "SPEAR",
     "RAMESSES II AGAINST THE HITTITES, AND THE FIRST KNOWN PEACE TREATY",
     "MIDDLE EAST", 48, 11, "Battle of Kadesh"],
    ["MARATHON", -490, "490 BC", "GREECE", "GRECO PERSIAN WARS", "SPEAR",
     "ATHENS TURNED BACK THE FIRST PERSIAN INVASION OF GREECE",
     "EUROPE", 45, 10, "Battle of Marathon"],
    ["THERMOPYLAE", -480, "480 BC", "GREECE", "GRECO PERSIAN WARS", "SPEAR",
     "A GREEK REARGUARD HELD A MOUNTAIN PASS AGAINST XERXES AND DIED THERE",
     "EUROPE", 45, 10, "Battle of Thermopylae"],
    ["SALAMIS", -480, "480 BC", "GREECE", "GRECO PERSIAN WARS", "TRIREME",
     "IN A NARROW STRAIT THE GREEK FLEET WRECKED THE PERSIAN NAVY",
     "EUROPE", 45, 10, "Battle of Salamis"],
    ["GAUGAMELA", -331, "331 BC", "IRAQ", "WARS OF ALEXANDER", "SPEAR",
     "ALEXANDER BROKE DARIUS III AND WITH HIM THE PERSIAN EMPIRE",
     "MIDDLE EAST", 49, 10, "Battle of Gaugamela"],
    ["CANNAE", -216, "216 BC", "ITALY", "SECOND PUNIC WAR", "SPEAR",
     "HANNIBAL ENCIRCLED A FAR LARGER ROMAN ARMY AND DESTROYED IT",
     "EUROPE", 43, 9, "Battle of Cannae"],
    ["ZAMA", -202, "202 BC", "TUNISIA", "SECOND PUNIC WAR", "SPEAR",
     "SCIPIO BEAT HANNIBAL AT LAST AND ENDED CARTHAGE AS A GREAT POWER",
     "AFRICA", 42, 10, "Battle of Zama"],
    ["ALESIA", -52, "52 BC", "FRANCE", "GALLIC WARS", "CASTLE",
     "CAESAR BESIEGED VERCINGETORIX BEHIND TWO RINGS OF WORKS AND WON GAUL",
     "EUROPE", 41, 8, "Battle of Alesia"],
    ["ACTIUM", -31, "31 BC", "GREECE", "ROMAN CIVIL WARS", "TRIREME",
     "OCTAVIAN BEAT ANTONY AND CLEOPATRA AT SEA AND BECAME THE FIRST EMPEROR",
     "EUROPE", 44, 10, "Battle of Actium"],
    ["TEUTOBURG FOREST", 9, "9 AD", "GERMANY", "ROMAN GERMANIC WARS", "SPEAR",
     "THREE ROMAN LEGIONS WERE ANNIHILATED AND ROME STOPPED AT THE RHINE",
     "EUROPE", 41, 7, "Battle of the Teutoburg Forest"],
    ["RED CLIFFS", 208, "208 AD", "CHINA", "END OF THE HAN", "TRIREME",
     "A FIRE ATTACK ON THE YANGTZE STOPPED CAO CAO AND SPLIT CHINA IN THREE",
     "ASIA", 65, 12, "Battle of Red Cliffs"],
    ["ADRIANOPLE", 378, "378 AD", "TURKEY", "GOTHIC WAR", "SPEAR",
     "GOTHS DESTROYED AN EASTERN ROMAN ARMY AND KILLED THE EMPEROR VALENS",
     "EUROPE", 45, 9, "Battle of Adrianople"],
    ["CATALAUNIAN PLAINS", 451, "451 AD", "FRANCE", "HUNNIC INVASION", "SPEAR",
     "A ROMAN AND GOTHIC ALLIANCE CHECKED ATTILA IN GAUL",
     "EUROPE", 41, 7, "Battle of the Catalaunian Plains"],
    ["YARMUK", 636, "636", "SYRIA", "ARAB BYZANTINE WARS", "SPEAR",
     "THE RASHIDUN CALIPHATE TOOK SYRIA FROM BYZANTIUM FOR GOOD",
     "MIDDLE EAST", 47, 11, "Battle of the Yarmuk"],
    ["TOURS", 732, "732", "FRANCE", "UMAYYAD INVASION OF GAUL", "KNIGHT",
     "CHARLES MARTEL HALTED AN UMAYYAD ADVANCE INTO FRANKISH GAUL",
     "EUROPE", 40, 8, "Battle of Tours"],
    ["TALAS", 751, "751", "KYRGYZSTAN", "ABBASID TANG WAR", "SPEAR",
     "THE ABBASIDS BEAT TANG CHINA AND FIXED THE LIMIT OF BOTH EMPIRES",
     "ASIA", 56, 9, "Battle of Talas"],
    ["HASTINGS", 1066, "1066", "ENGLAND", "NORMAN CONQUEST", "KNIGHT",
     "WILLIAM OF NORMANDY KILLED HAROLD AND TOOK THE ENGLISH CROWN",
     "EUROPE", 40, 7, "Battle of Hastings"],
    ["MANZIKERT", 1071, "1071", "TURKEY", "BYZANTINE SELJUK WARS", "KNIGHT",
     "THE SELJUKS CAPTURED A BYZANTINE EMPEROR AND OPENED ANATOLIA",
     "MIDDLE EAST", 49, 10, "Battle of Manzikert"],
    ["HATTIN", 1187, "1187", "ISRAEL", "THE CRUSADES", "KNIGHT",
     "SALADIN DESTROYED THE CRUSADER FIELD ARMY AND RETOOK JERUSALEM",
     "MIDDLE EAST", 47, 11, "Battle of Hattin"],
    ["AIN JALUT", 1260, "1260", "ISRAEL", "MONGOL INVASIONS", "KNIGHT",
     "THE MAMLUKS BEAT A MONGOL ARMY AND ENDED THE ADVANCE WEST",
     "MIDDLE EAST", 47, 11, "Battle of Ain Jalut"],
    ["BANNOCKBURN", 1314, "1314", "SCOTLAND", "SCOTTISH INDEPENDENCE", "KNIGHT",
     "ROBERT THE BRUCE BROKE AN ENGLISH ARMY AND SECURED SCOTLAND",
     "EUROPE", 39, 6, "Battle of Bannockburn"],
    ["CRECY", 1346, "1346", "FRANCE", "HUNDRED YEARS WAR", "KNIGHT",
     "THE ENGLISH LONGBOW CUT DOWN THE FLOWER OF FRENCH CHIVALRY",
     "EUROPE", 40, 7, "Battle of Crecy"],
    ["AGINCOURT", 1415, "1415", "FRANCE", "HUNDRED YEARS WAR", "KNIGHT",
     "A SICK OUTNUMBERED ENGLISH ARMY WON IN THE MUD NEAR AZINCOURT",
     "EUROPE", 40, 7, "Battle of Agincourt"],
    ["CONSTANTINOPLE", 1453, "1453", "TURKEY", "OTTOMAN CONQUEST", "CASTLE",
     "AFTER 53 DAYS THE OTTOMAN GUNS BROKE THE WALLS AND BYZANTIUM ENDED",
     "EUROPE", 46, 9, "Fall of Constantinople"],
    ["BOSWORTH FIELD", 1485, "1485", "ENGLAND", "WARS OF THE ROSES", "KNIGHT",
     "RICHARD III DIED IN THE FIELD AND THE TUDOR LINE BEGAN",
     "EUROPE", 39, 7, "Battle of Bosworth Field"],
    ["LEPANTO", 1571, "1571", "GREECE", "OTTOMAN HABSBURG WARS", "TRIREME",
     "THE LAST GREAT GALLEY BATTLE, AND THE END OF OTTOMAN NAVAL DOMINANCE",
     "EUROPE", 44, 10, "Battle of Lepanto"],
    ["THE SPANISH ARMADA", 1588, "1588", "ENGLAND", "ANGLO SPANISH WAR", "SAIL",
     "FIRESHIPS AND THE WEATHER WRECKED PHILIP IIS FLEET IN THE CHANNEL",
     "EUROPE", 39, 7, "Spanish Armada"],
    ["SEKIGAHARA", 1600, "1600", "JAPAN", "SENGOKU PERIOD", "CANNON",
     "TOKUGAWA IEYASU WON AND FOUNDED A SHOGUNATE THAT LASTED 250 YEARS",
     "ASIA", 70, 10, "Battle of Sekigahara"],
    ["LUTZEN", 1632, "1632", "GERMANY", "THIRTY YEARS WAR", "CANNON",
     "SWEDEN HELD THE FIELD BUT LOST ITS KING GUSTAVUS ADOLPHUS ON IT",
     "EUROPE", 42, 7, "Battle of Lutzen (1632)"],
    ["VIENNA", 1683, "1683", "AUSTRIA", "OTTOMAN HABSBURG WARS", "CASTLE",
     "A RELIEF ARMY BROKE A TWO MONTH OTTOMAN SIEGE OF THE CITY",
     "EUROPE", 43, 8, "Battle of Vienna"],
    ["BLENHEIM", 1704, "1704", "GERMANY", "SPANISH SUCCESSION", "CANNON",
     "MARLBOROUGH AND EUGENE WRECKED A FRENCH ARMY FAR FROM HOME",
     "EUROPE", 42, 7, "Battle of Blenheim"],
    ["POLTAVA", 1709, "1709", "UKRAINE", "GREAT NORTHERN WAR", "CANNON",
     "PETER THE GREAT BROKE SWEDEN AND RUSSIA BECAME A EUROPEAN POWER",
     "EUROPE", 47, 7, "Battle of Poltava"],
    ["PLASSEY", 1757, "1757", "INDIA", "SEVEN YEARS WAR", "CANNON",
     "CLIVE WON BENGAL FOR THE EAST INDIA COMPANY, LARGELY BY DEFECTION",
     "ASIA", 59, 13, "Battle of Plassey"],
    ["PLAINS OF ABRAHAM", 1759, "1759", "CANADA", "SEVEN YEARS WAR", "CANNON",
     "A SHORT FIGHT OUTSIDE QUEBEC DECIDED THE FATE OF FRENCH CANADA",
     "AMERICAS", 24, 8, "Battle of the Plains of Abraham"],
    ["SARATOGA", 1777, "1777", "UNITED STATES", "AMERICAN REVOLUTION", "CANNON",
     "A BRITISH SURRENDER THAT BROUGHT FRANCE INTO THE WAR",
     "AMERICAS", 23, 9, "Battles of Saratoga"],
    ["YORKTOWN", 1781, "1781", "UNITED STATES", "AMERICAN REVOLUTION", "CASTLE",
     "TRAPPED BETWEEN AN ARMY AND A FRENCH FLEET, CORNWALLIS SURRENDERED",
     "AMERICAS", 22, 10, "Siege of Yorktown"],
    ["VALMY", 1792, "1792", "FRANCE", "FRENCH REVOLUTIONARY WARS", "CANNON",
     "AN ARTILLERY DUEL SAVED THE YOUNG FRENCH REPUBLIC",
     "EUROPE", 41, 7, "Battle of Valmy"],
    ["THE NILE", 1798, "1798", "EGYPT", "FRENCH REVOLUTIONARY WARS", "SAIL",
     "NELSON DESTROYED THE FRENCH FLEET AND STRANDED BONAPARTE IN EGYPT",
     "AFRICA", 46, 11, "Battle of the Nile"],
    ["TRAFALGAR", 1805, "1805", "SPAIN", "NAPOLEONIC WARS", "SAIL",
     "NELSON BROKE THE FRENCH AND SPANISH LINE AND DIED WINNING",
     "EUROPE", 38, 10, "Battle of Trafalgar"],
    ["AUSTERLITZ", 1805, "1805", "CZECHIA", "NAPOLEONIC WARS", "CANNON",
     "NAPOLEON GAVE UP HIS HIGH GROUND AS BAIT AND SPLIT THE ALLIED ARMY",
     "EUROPE", 43, 7, "Battle of Austerlitz"],
    ["BORODINO", 1812, "1812", "RUSSIA", "NAPOLEONIC WARS", "CANNON",
     "THE BLOODIEST DAY OF THE NAPOLEONIC WARS, AND MOSCOW FELL ANYWAY",
     "EUROPE", 47, 6, "Battle of Borodino"],
    ["LEIPZIG", 1813, "1813", "GERMANY", "NAPOLEONIC WARS", "CANNON",
     "THE BATTLE OF THE NATIONS, THE LARGEST IN EUROPE BEFORE 1914",
     "EUROPE", 42, 7, "Battle of Leipzig"],
    ["WATERLOO", 1815, "1815", "BELGIUM", "NAPOLEONIC WARS", "CANNON",
     "WELLINGTON HELD ALL DAY, BLUCHER ARRIVED, AND NAPOLEON WAS FINISHED",
     "EUROPE", 40, 7, "Battle of Waterloo"],
    ["THE ALAMO", 1836, "1836", "UNITED STATES", "TEXAS REVOLUTION", "CASTLE",
     "A 13 DAY SIEGE ENDED WITH THE MISSION STORMED AND ITS DEFENDERS DEAD",
     "AMERICAS", 18, 12, "Battle of the Alamo"],
    ["BALACLAVA", 1854, "1854", "UKRAINE", "CRIMEAN WAR", "CANNON",
     "REMEMBERED FOR THE CHARGE OF THE LIGHT BRIGADE INTO THE GUNS",
     "EUROPE", 47, 8, "Battle of Balaclava"],
    ["SOLFERINO", 1859, "1859", "ITALY", "ITALIAN INDEPENDENCE", "CANNON",
     "THE SUFFERING AFTERWARDS LED DIRECTLY TO THE RED CROSS",
     "EUROPE", 42, 8, "Battle of Solferino"],
    ["ANTIETAM", 1862, "1862", "UNITED STATES", "AMERICAN CIVIL WAR", "CANNON",
     "THE BLOODIEST SINGLE DAY IN AMERICAN HISTORY",
     "AMERICAS", 22, 10, "Battle of Antietam"],
    ["GETTYSBURG", 1863, "1863", "UNITED STATES", "AMERICAN CIVIL WAR", "CANNON",
     "THREE DAYS THAT TURNED BACK THE CONFEDERATE INVASION OF THE NORTH",
     "AMERICAS", 22, 9, "Battle of Gettysburg"],
    ["SEDAN", 1870, "1870", "FRANCE", "FRANCO PRUSSIAN WAR", "CANNON",
     "AN EMPEROR WAS CAPTURED WITH HIS ARMY AND THE GERMAN EMPIRE FOLLOWED",
     "EUROPE", 41, 7, "Battle of Sedan"],
    ["LITTLE BIGHORN", 1876, "1876", "UNITED STATES", "GREAT SIOUX WAR", "CANNON",
     "LAKOTA AND CHEYENNE FIGHTERS DESTROYED CUSTERS COMMAND",
     "AMERICAS", 16, 8, "Battle of the Little Bighorn"],
    ["ISANDLWANA", 1879, "1879", "SOUTH AFRICA", "ANGLO ZULU WAR", "CANNON",
     "A ZULU ARMY DESTROYED A BRITISH COLUMN IN THE OPEN FIELD",
     "AFRICA", 46, 25, "Battle of Isandlwana"],
    ["RORKES DRIFT", 1879, "1879", "SOUTH AFRICA", "ANGLO ZULU WAR", "CASTLE",
     "A HUNDRED MEN HELD A MISSION STATION THROUGH THE NIGHT THAT FOLLOWED",
     "AFRICA", 46, 25, "Battle of Rorke's Drift"],
    ["OMDURMAN", 1898, "1898", "SUDAN", "MAHDIST WAR", "CANNON",
     "MACHINE GUNS AGAINST MASSED INFANTRY, AND THE RESULT WAS SLAUGHTER",
     "AFRICA", 47, 15, "Battle of Omdurman"],
    ["TANNENBERG", 1914, "1914", "POLAND", "FIRST WORLD WAR", "CANNON",
     "GERMANY ENCIRCLED AND DESTROYED A RUSSIAN ARMY IN THE FIRST MONTH",
     "EUROPE", 44, 6, "Battle of Tannenberg"],
    ["THE MARNE", 1914, "1914", "FRANCE", "FIRST WORLD WAR", "CANNON",
     "THE GERMAN ADVANCE ON PARIS WAS STOPPED AND THE TRENCHES BEGAN",
     "EUROPE", 40, 7, "First Battle of the Marne"],
    ["GALLIPOLI", 1915, "1915", "TURKEY", "FIRST WORLD WAR", "WARSHIP",
     "AN ALLIED LANDING THAT STALLED ON THE BEACHES FOR EIGHT MONTHS",
     "EUROPE", 45, 9, "Gallipoli campaign"],
    ["VERDUN", 1916, "1916", "FRANCE", "FIRST WORLD WAR", "CANNON",
     "TEN MONTHS OF ARTILLERY, AND THE LONGEST BATTLE OF THE WAR",
     "EUROPE", 41, 7, "Battle of Verdun"],
    ["JUTLAND", 1916, "1916", "DENMARK", "FIRST WORLD WAR", "WARSHIP",
     "THE ONLY FULL FLEET ACTION OF THE WAR, AND IT SETTLED LITTLE",
     "EUROPE", 41, 6, "Battle of Jutland"],
    ["THE SOMME", 1916, "1916", "FRANCE", "FIRST WORLD WAR", "CANNON",
     "NEARLY SIXTY THOUSAND BRITISH CASUALTIES ON THE FIRST DAY ALONE",
     "EUROPE", 40, 7, "Battle of the Somme"],
    ["AMIENS", 1918, "1918", "FRANCE", "FIRST WORLD WAR", "TANK",
     "MASSED TANKS AND AIRCRAFT OPENED THE ADVANCE THAT ENDED THE WAR",
     "EUROPE", 40, 7, "Battle of Amiens (1918)"],
    ["BRITAIN", 1940, "1940", "ENGLAND", "SECOND WORLD WAR", "PLANE",
     "THE FIRST CAMPAIGN FOUGHT ENTIRELY IN THE AIR, AND GERMANY LOST IT",
     "EUROPE", 40, 7, "Battle of Britain"],
    ["PEARL HARBOR", 1941, "1941", "HAWAII", "SECOND WORLD WAR", "PLANE",
     "A SURPRISE CARRIER RAID THAT BROUGHT THE UNITED STATES INTO THE WAR",
     "PACIFIC", 4, 14, "Attack on Pearl Harbor"],
    ["MIDWAY", 1942, "1942", "PACIFIC OCEAN", "SECOND WORLD WAR", "PLANE",
     "FOUR JAPANESE CARRIERS SANK IN A DAY AND THE PACIFIC WAR TURNED",
     "PACIFIC", 0, 12, "Battle of Midway"],
    ["EL ALAMEIN", 1942, "1942", "EGYPT", "SECOND WORLD WAR", "TANK",
     "THE AXIS ADVANCE ON THE SUEZ CANAL WAS STOPPED AND THROWN BACK",
     "AFRICA", 46, 11, "Second Battle of El Alamein"],
    ["STALINGRAD", 1942, "1942", "RUSSIA", "SECOND WORLD WAR", "TANK",
     "MONTHS OF STREET FIGHTING ENDED WITH A WHOLE GERMAN ARMY ENCIRCLED",
     "EUROPE", 49, 7, "Battle of Stalingrad"],
    ["KURSK", 1943, "1943", "RUSSIA", "SECOND WORLD WAR", "TANK",
     "THE LARGEST ARMOURED BATTLE EVER FOUGHT, AND GERMANY NEVER ATTACKED AGAIN",
     "EUROPE", 48, 7, "Battle of Kursk"],
    ["NORMANDY", 1944, "1944", "FRANCE", "SECOND WORLD WAR", "WARSHIP",
     "THE LARGEST SEABORNE INVASION IN HISTORY, PUT ASHORE IN ONE DAY",
     "EUROPE", 39, 7, "Normandy landings"],
    ["LEYTE GULF", 1944, "1944", "PHILIPPINES", "SECOND WORLD WAR", "WARSHIP",
     "THE LARGEST NAVAL BATTLE OF THE WAR, AND BY SOME MEASURES OF ANY WAR",
     "ASIA", 67, 16, "Battle of Leyte Gulf"],
    ["BERLIN", 1945, "1945", "GERMANY", "SECOND WORLD WAR", "TANK",
     "THE LAST GREAT OFFENSIVE IN EUROPE, AND THE END OF THE THIRD REICH",
     "EUROPE", 42, 7, "Battle of Berlin"],
    ["INCHON", 1950, "1950", "SOUTH KOREA", "KOREAN WAR", "WARSHIP",
     "A LANDING FAR BEHIND THE FRONT THAT REVERSED THE WHOLE CAMPAIGN",
     "ASIA", 68, 10, "Battle of Inchon"],
    ["DIEN BIEN PHU", 1954, "1954", "VIETNAM", "FIRST INDOCHINA WAR", "CANNON",
     "ARTILLERY IN THE HILLS BEAT A FRENCH GARRISON AND ENDED FRENCH RULE",
     "ASIA", 62, 14, "Battle of Dien Bien Phu"],
    ["THE TET OFFENSIVE", 1968, "1968", "VIETNAM", "VIETNAM WAR", "TANK",
     "A MILITARY DEFEAT THAT CHANGED HOW THE WAR WAS SEEN AT HOME",
     "ASIA", 63, 16, "Tet Offensive"],
]

# ------------------------------------------------------------- text tools
ALLOWED = " !#$%&()*+,-./0123456789:?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"

SUBS = {
    "×": "X", "–": "-", "—": "-", "−": "-",
    "‘": "", "’": "", "“": "", "”": "",
    "Á": "A", "À": "A", "Â": "A", "Ä": "A",
    "Ã": "A", "Å": "A", "Æ": "AE",
    "É": "E", "È": "E", "Ê": "E", "Ë": "E",
    "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
    "Ó": "O", "Ò": "O", "Ô": "O", "Ö": "O",
    "Õ": "O", "Ø": "O",
    "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
    "Ñ": "N", "Ç": "C", "Ý": "Y", "ß": "SS",
}

def safe(s):
    """Filter live text to glyphs that exist. An unsupported character
    becomes a space rather than vanishing, because silently dropping one
    can change a number into a different number."""
    t = str(s).upper()
    out = ""
    for ch in t.elems():
        if ch in ALLOWED:
            out += ch
        elif ch in SUBS:
            out += SUBS[ch]
        else:
            out += " "
    for _ in range(4):
        out = out.replace("  ", " ")
    return out.strip()

def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for i in range(len(t), 0, -1):
        if c.text_width(t[:i], font) <= maxw:
            return t[:i]
    return ""

def clip_words(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    parts = t.split(" ")
    for n in range(len(parts) - 1, 0, -1):
        cut = " ".join(parts[:n])
        if c.text_width(cut, font) <= maxw:
            return cut
    return clip(c, t, font, maxw)

# Words a clipped line must not be left ending on. NAVAL BATTLE OF THE
# reads as though the rest were still coming.
TAIL = {
    "OF": True, "THE": True, "AND": True, "A": True, "AN": True, "IN": True,
    "ON": True, "AT": True, "TO": True, "FOR": True, "WITH": True,
    "BY": True, "FROM": True, "AS": True, "-": True, "&": True,
    "BETWEEN": True, "DURING": True, "AGAINST": True, "INTO": True,
    "OVER": True, "THAT": True, "WAS": True,
}

def trim_tail(s):
    parts = s.strip().split(" ")
    for _ in range(3):
        if len(parts) > 1 and parts[len(parts) - 1] in TAIL:
            parts = parts[:len(parts) - 1]
    return " ".join(parts).strip()

def fit_text(c, text, font, maxw):
    """Clip only when it has to, and never end on a connective."""
    if c.text_width(text, font) <= maxw:
        return text
    return trim_tail(clip_words(c, text, font, maxw))

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    last = fonts[len(fonts) - 1]
    return [last, clip_words(c, text, last, maxw)]

def wrap2(c, text, font, maxw):
    """Two lines, split at the word boundary that evens them up best."""
    if c.text_width(text, font) <= maxw:
        return [text, ""]
    parts = text.split(" ")
    best, score = -1, -999999
    for n in range(1, len(parts)):
        wa = c.text_width(" ".join(parts[:n]), font)
        wb = c.text_width(" ".join(parts[n:]), font)
        if wa <= maxw and wb <= maxw:
            s = -(wa - wb) if wa > wb else -(wb - wa)
            if s > score:
                best, score = n, s
    if best < 0:
        return [clip_words(c, text, font, maxw), ""]
    return [" ".join(parts[:best]), " ".join(parts[best:])]

def pick(c, options, font, maxw):
    for t in options:
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def rail(c, col):
    c.rect(0, 0, 1, 31, fill = col)

def pill(c, text, col, x, y):
    w = c.text_width(text, "4x5") + 4
    c.rect(x, y, x + w - 1, y + 6, fill = col)
    c.text(text, x + 2, y + 1, font = "4x5", color = "black")
    return w

# ---------------------------------------------------------- the silhouettes
# Each draws into a 22 px band from (x, y). A 14 px band was tried on an
# earlier app and every feature collapsed into a bar, so these get the room.
WIDTHS = {
    "SPEAR": 96, "TRIREME": 140, "KNIGHT": 94, "CASTLE": 120,
    "CANNON": 124, "SAIL": 130, "TANK": 130, "WARSHIP": 160, "PLANE": 128,
}

def draw_spear(c, x, y, ink, era):
    # a round hoplite shield with two spears crossed behind it
    c.line(x + 18, y + 20, x + 76, y + 1, ink)
    c.line(x + 18, y + 1, x + 76, y + 20, ink)
    c.fill_triangle(x + 72, y + 1, x + 80, y + 4, x + 72, y + 7, ink)
    c.fill_triangle(x + 72, y + 14, x + 80, y + 17, x + 72, y + 20, ink)
    c.fill_circle(x + 44, y + 11, 10, era)
    c.circle(x + 44, y + 11, 10, ink)
    c.circle(x + 44, y + 11, 6, ink)
    c.fill_circle(x + 44, y + 11, 2, ink)

def draw_trireme(c, x, y, ink, era):
    # oared galley: curved hull, mast and square sail, ram at the prow
    c.rect(x + 20, y + 12, x + 116, y + 16, fill = ink)
    c.fill_triangle(x + 116, y + 12, x + 136, y + 13, x + 116, y + 16, ink)
    c.fill_triangle(x + 20, y + 12, x + 10, y + 6, x + 20, y + 16, ink)
    c.rect(x + 66, y + 1, x + 68, y + 12, fill = ink)
    c.rect(x + 44, y + 3, x + 92, y + 11, fill = era)
    c.rect(x + 44, y + 3, x + 92, y + 4, fill = ink)
    for i in range(9):
        c.line(x + 28 + i * 10, y + 16, x + 24 + i * 10, y + 21, ink)

def draw_knight(c, x, y, ink, era):
    # A heater shield with a cross, a sword and a lance crossing behind it.
    #
    # Drawn three times as a helm above a sword and it never read: a box
    # with two slits, then a pair of spectacles, then three disconnected
    # bars. The fault was the composition rather than the coordinates.
    # Two objects stacked in a 22 px band leave neither room to be legible,
    # so this borrows the one that works on the hoplite panel: a single
    # bold shape, centred, with the weapons crossing behind it.
    c.line(x + 16, y + 20, x + 74, y + 2, ink)               # sword
    c.rect(x + 60, y + 3, x + 72, y + 5, fill = ink)         # crossguard
    c.line(x + 16, y + 2, x + 74, y + 20, ink)               # lance
    c.fill_triangle(x + 68, y + 16, x + 78, y + 21, x + 66, y + 21, ink)
    c.rect(x + 30, y + 1, x + 60, y + 3, fill = ink)         # shield rim
    c.rect(x + 30, y + 3, x + 60, y + 13, fill = era)        # shield face
    c.rect(x + 30, y + 3, x + 31, y + 13, fill = ink)
    c.rect(x + 59, y + 3, x + 60, y + 13, fill = ink)
    c.fill_triangle(x + 30, y + 13, x + 60, y + 13, x + 45, y + 21, era)
    c.line(x + 30, y + 13, x + 45, y + 21, ink)              # shield point
    c.line(x + 60, y + 13, x + 45, y + 21, ink)
    c.rect(x + 43, y + 1, x + 47, y + 18, fill = ink)        # the cross
    c.rect(x + 33, y + 6, x + 57, y + 9, fill = ink)

def draw_castle(c, x, y, ink, era):
    # a crenellated curtain wall with a gate tower
    c.rect(x, y + 10, x + 118, y + 21, fill = era)
    c.rect(x, y + 10, x + 118, y + 11, fill = ink)
    for i in range(10):
        c.rect(x + 4 + i * 12, y + 6, x + 11 + i * 12, y + 10, fill = era)
        c.rect(x + 4 + i * 12, y + 6, x + 11 + i * 12, y + 7, fill = ink)
    c.rect(x + 46, y + 1, x + 74, y + 21, fill = era)
    c.rect(x + 46, y + 1, x + 74, y + 2, fill = ink)
    c.rect(x + 46, y + 1, x + 47, y + 21, fill = ink)
    c.rect(x + 73, y + 1, x + 74, y + 21, fill = ink)
    c.rect(x + 56, y + 12, x + 64, y + 21, fill = ink)
    c.rect(x + 58, y + 5, x + 62, y + 9, fill = ink)

def draw_cannon(c, x, y, ink, era):
    # muzzle loading field gun on a two wheeled carriage
    c.rect(x + 34, y + 5, x + 104, y + 10, fill = ink)
    c.rect(x + 100, y + 4, x + 108, y + 11, fill = ink)
    c.rect(x + 28, y + 4, x + 40, y + 12, fill = ink)
    c.fill_circle(x + 52, y + 14, 8, era)
    c.circle(x + 52, y + 14, 8, ink)
    c.circle(x + 52, y + 14, 3, ink)
    c.line(x + 44, y + 14, x + 60, y + 14, ink)
    c.line(x + 52, y + 6, x + 52, y + 22, ink)
    c.fill_triangle(x + 46, y + 10, x + 52, y + 14, x + 4, y + 20, ink)
    c.rect(x, y + 18, x + 12, y + 21, fill = ink)

def draw_sail(c, x, y, ink, era):
    # a ship of the line: three masts, square sails, gunports
    c.rect(x + 14, y + 15, x + 116, y + 19, fill = ink)
    c.fill_triangle(x + 116, y + 15, x + 130, y + 12, x + 116, y + 19, ink)
    c.fill_triangle(x + 14, y + 15, x + 2, y + 11, x + 14, y + 19, ink)
    for m in range(3):
        mx = x + 34 + m * 30
        c.rect(mx, y + 1, mx + 1, y + 15, fill = ink)
        c.rect(mx - 12, y + 3, mx + 13, y + 8, fill = era)
        c.rect(mx - 12, y + 3, mx + 13, y + 4, fill = ink)
        c.rect(mx - 10, y + 10, mx + 11, y + 14, fill = era)
        c.rect(mx - 10, y + 10, mx + 11, y + 11, fill = ink)
    for i in range(9):
        c.rect(x + 22 + i * 10, y + 16, x + 24 + i * 10, y + 17, fill = era)

def draw_tank(c, x, y, ink, era):
    # hull, turret and a long gun over sprocket and road wheels
    c.rect(x + 8, y + 11, x + 112, y + 17, fill = era)
    c.rect(x + 8, y + 11, x + 112, y + 12, fill = ink)
    c.rect(x + 40, y + 4, x + 84, y + 11, fill = era)
    c.rect(x + 40, y + 4, x + 84, y + 5, fill = ink)
    c.rect(x + 84, y + 6, x + 128, y + 9, fill = ink)
    c.rect(x + 122, y + 5, x + 128, y + 10, fill = ink)
    c.rect(x + 4, y + 17, x + 116, y + 21, fill = ink)
    c.fill_circle(x + 12, y + 19, 4, era)
    c.fill_circle(x + 108, y + 19, 4, era)
    for i in range(6):
        c.fill_circle(x + 28 + i * 14, y + 19, 3, era)

def draw_warship(c, x, y, ink, era):
    # a battleship in profile: long hull, bridge, funnel, gun turrets
    c.rect(x + 4, y + 13, x + 150, y + 18, fill = ink)
    c.fill_triangle(x + 150, y + 13, x + 160, y + 15, x + 150, y + 18, ink)
    c.fill_triangle(x + 4, y + 13, x, y + 18, x + 4, y + 18, ink)
    c.rect(x + 60, y + 6, x + 84, y + 13, fill = era)
    c.rect(x + 60, y + 6, x + 84, y + 7, fill = ink)
    c.rect(x + 68, y + 1, x + 72, y + 6, fill = ink)
    c.rect(x + 92, y + 4, x + 104, y + 13, fill = era)
    c.rect(x + 92, y + 4, x + 104, y + 5, fill = ink)
    for gx in [x + 24, x + 124]:
        c.rect(gx, y + 9, gx + 16, y + 13, fill = era)
        c.rect(gx, y + 9, gx + 16, y + 10, fill = ink)
        c.rect(gx + 14, y + 10, gx + 28, y + 11, fill = ink)
    c.rect(x + 4, y + 18, x + 150, y + 19, fill = era)

def draw_plane(c, x, y, ink, era):
    # a fighter seen from above: fuselage, swept wings, tailplane
    c.rect(x + 20, y + 9, x + 116, y + 13, fill = ink)
    c.fill_triangle(x + 116, y + 9, x + 128, y + 11, x + 116, y + 13, ink)
    c.fill_triangle(x + 74, y + 9, x + 34, y + 1, x + 44, y + 9, era)
    c.fill_triangle(x + 74, y + 13, x + 34, y + 21, x + 44, y + 13, era)
    c.line(x + 74, y + 9, x + 34, y + 1, ink)
    c.line(x + 74, y + 13, x + 34, y + 21, ink)
    c.fill_triangle(x + 32, y + 9, x + 16, y + 4, x + 22, y + 9, era)
    c.fill_triangle(x + 32, y + 13, x + 16, y + 18, x + 22, y + 13, era)
    c.fill_circle(x + 96, y + 11, 2, era)

def silhouette(c, shape, y, ink, era):
    w = WIDTHS.get(shape, 120)
    x = 10 + (172 - w) // 2
    if shape == "SPEAR":
        draw_spear(c, x, y, ink, era)
    elif shape == "TRIREME":
        draw_trireme(c, x, y, ink, era)
    elif shape == "KNIGHT":
        draw_knight(c, x, y, ink, era)
    elif shape == "CASTLE":
        draw_castle(c, x, y, ink, era)
    elif shape == "CANNON":
        draw_cannon(c, x, y, ink, era)
    elif shape == "SAIL":
        draw_sail(c, x, y, ink, era)
    elif shape == "TANK":
        draw_tank(c, x, y, ink, era)
    elif shape == "WARSHIP":
        draw_warship(c, x, y, ink, era)
    else:
        draw_plane(c, x, y, ink, era)

# ------------------------------------------------------------------ pick
def era_of(year):
    for e in ERAS:
        if year < e[0]:
            return e
    return ERAS[len(ERAS) - 1]

def in_era(year, want):
    if want == "ANCIENT":
        return year < 500
    if want == "MEDIEVAL":
        return year >= 500 and year < 1500
    if want == "GUNPOWDER":
        return year >= 1500 and year < 1900
    if want == "MODERN":
        return year >= 1900
    return True

def choose(ctx):
    era = str(ctx.inputs.get("era", "ALL ERAS")).strip().upper()
    region = str(ctx.inputs.get("region", "ALL REGIONS")).strip().upper()
    pool = []
    for b in ROSTER:
        if era != "ALL ERAS" and not in_era(b[1], era):
            continue
        if region != "ALL REGIONS" and b[7] != region:
            continue
        pool.append(b)
    if len(pool) == 0:
        return None
    # One battle a day, the year shifting where the sequence starts so the
    # same date does not land on the same battle every year.
    idx = (ctx.now.yday - 1 + ctx.now.year * 3) % len(pool)
    return pool[idx]

def empty(c):
    c.fill("black")
    rail(c, "#B0483C")
    c.text("NOTHING IN THAT PERIOD", 96, 8, font = "6x8", color = "#B0483C",
           align = "center")
    c.text("TRY ANOTHER ERA OR REGION", 96, 20, font = "4x5", color = DIM,
           align = "center")

# ---------------------------------------------------------- page: battle
def battle(c, ctx):
    b = choose(ctx)
    if b == None:
        empty(c)
        return
    era = era_of(b[1])
    c.fill("black")
    rail(c, era[1])

    # Art 0..21, then the name and year on one row at 23..30.
    silhouette(c, b[5], 0, STEEL, era[1])
    yr = b[2]
    yw = c.text_width(yr, "4x5")
    c.text(yr, 181, 24, font = "4x5", color = era[1], align = "right")
    nf = fit(c, b[0], ["6x8", "5x7", "4x5"], 172 - yw - 6)
    c.text(nf[1], 10, 23, font = nf[0], color = INK)

# ----------------------------------------------------------- page: story
def story(c, ctx):
    b = choose(ctx)
    if b == None:
        empty(c)
        return
    era = era_of(b[1])
    c.fill("black")
    rail(c, era[1])

    pill(c, clip(c, b[0], "4x5", 96), era[1], 10, 0)
    c.text(b[2], 181, 1, font = "4x5", color = INK, align = "right")

    two = wrap2(c, b[6], "4x5", 172)
    c.text(two[0], 10, 8, font = "4x5", color = INK)
    if two[1] != "":
        c.text(two[1], 10, 14, font = "4x5", color = INK)

    c.text(clip(c, b[4], "4x5", 172), 10, 20, font = "4x5", color = DIM)

    # The only line that goes to the network. Without it the placard simply
    # ends after the curated text.
    r = http.get(REST + b[10].replace(" ", "_").replace("&", "%26"),
                 headers = UA, ttl_seconds = 3600)
    if r["status_code"] == 200:
        js = r["json"]
        if type(js) == "dict":
            d = safe(js.get("description", ""))
            if d != "":
                c.text(fit_text(c, "WIKIPEDIA: " + d, "4x5", 172), 10, 26,
                       font = "4x5", color = DARK)

# ----------------------------------------------------------- page: where
def where(c, ctx):
    b = choose(ctx)
    if b == None:
        empty(c)
        return
    era = era_of(b[1])
    c.fill("black")
    rail(c, era[1])

    c.sprite(WORLD, MAP_X, 0, legend = {"#": LAND})

    # Crosshairs first, so the eye finds one small mark on a busy map.
    mx, my = MAP_X + b[8], b[9]
    c.hline(MAP_X, my, MAP_W, GRID)
    c.vline(mx, 0, 32, GRID)
    c.circle(mx, my, 3, era[1])
    c.rect(mx - 1, my - 1, mx, my, fill = INK)

    tx = 94
    pill(c, era[2], era[1], tx, 0)

    c.text(clip(c, b[3], "4x5", 181 - tx + 1), tx, 8, font = "4x5", color = INK)
    c.text(clip(c, b[4], "4x5", 181 - tx + 1), tx, 14, font = "4x5", color = DIM)
    c.text(clip(c, b[7], "4x5", 181 - tx + 1), tx, 20, font = "4x5", color = DIM)
    c.text(b[2], tx, 26, font = "4x5", color = era[1])
