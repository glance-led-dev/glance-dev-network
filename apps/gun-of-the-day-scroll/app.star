# Gun of the Day - a different historically significant firearm each day,
# written like a museum placard.
#
# ROSTER. Curated, 71 pieces from the flintlock era to the polymer one. It
# is curated rather than queried because the live sources are not good
# enough to place on a wall:
#
#   - Wikidata has no inception date at all for 41 of these 71, and no
#     country of origin for a single one of them. Several dates it does
#     carry are the wrong thing: 1675 for the Charleville musket is when
#     the armoury was founded, not when the 1717 pattern appeared, and its
#     dates for the M1 carbine, the MP 40 and the M2 Browning are all a
#     predecessor model rather than the piece named.
#   - Wikipedia's own short descriptions run from excellent to the single
#     word "Revolver".
#
# So the placard facts are curated and checked against the prose of the
# Wikipedia articles, and the years are the commonly cited year a design
# appeared or was adopted. Sources disagree by a year or two on plenty of
# these; the README says so.
#
# LIVE. Only the STORY page goes to the network, for one line of Wikipedia
# summary. TODAY and SPECS are pure curated data and cannot fail, so the
# panel keeps working with the network down.
#
# Two title traps, both found by probing: "Winchester Model 1873" silently
# redirects to the generic article "Winchester rifle", so the curated name
# is always displayed rather than whatever the API normalises to; and an
# ampersand in a title has to be percent-encoded by hand.
#
# ART. The silhouettes are drawn from rectangles, triangles and circles
# rather than character art, which keeps them editable and lets each shape
# take its own natural width: a derringer really is drawn short next to a
# musket.

REST = "https://en.wikipedia.org/api/rest_v1/page/summary/"
UA = {"User-Agent": "glance-gun-of-the-day (glance-led.dev)"}

INK = "#FFFFFF"
DIM = "#7C8BA1"
FAINT = "#222B3A"
STEEL = "#C3CEDC"
DARK = "#8A94A6"

# The furniture colour moves with the era, so consecutive days look
# different at a glance: brass, copper, olive, then steel blue.
ERAS = [
    [1850, "#E0A32E", "BEFORE 1850"],
    [1900, "#C87137", "1850 TO 1899"],
    [1946, "#93A85C", "WORLD WARS"],
    [9999, "#7FA8D4", "MODERN"],
]

# name, kind, category, year, country, designer, why it mattered, shape,
# wikipedia title
ROSTER = [
    ["BLUNDERBUSS", "FLARED MUZZLE GUN", "SHOTGUNS", 1650, "EUROPE", "",
     "A FLARED MUZZLE FOR CLOSE QUARTERS AT SEA AND ON COACHES", "BLUNDER",
     "Blunderbuss"],
    ["PUCKLE GUN", "CRANK REPEATER", "MACHINE GUNS", 1718, "BRITAIN", "JAMES PUCKLE",
     "PATENTED 1718, AN EARLY TRY AT A RAPID FIRING CREW WEAPON", "GATLING",
     "Puckle gun"],
    ["CHARLEVILLE MUSKET", "FLINTLOCK MUSKET", "RIFLES", 1717, "FRANCE", "CHARLEVILLE ARMOURY",
     "ARMED THE FRENCH LINE AND THE AMERICAN REVOLUTION", "MUSKET",
     "Charleville musket"],
    ["BROWN BESS", "FLINTLOCK MUSKET", "RIFLES", 1722, "BRITAIN", "",
     "THE BRITISH LAND PATTERN MUSKET, IN SERVICE OVER A CENTURY", "MUSKET",
     "Brown Bess"],
    ["LONG RIFLE", "FLINTLOCK RIFLE", "RIFLES", 1740, "USA", "",
     "THE AMERICAN LONG RIFLE, RIFLED FOR ACCURACY ON THE FRONTIER", "MUSKET",
     "Long rifle"],
    ["FERGUSON RIFLE", "BREECH LOADER", "RIFLES", 1776, "BRITAIN", "PATRICK FERGUSON",
     "ONE OF THE FIRST BREECH LOADERS IN MILITARY SERVICE", "MUSKET",
     "Ferguson rifle"],
    ["GIRARDONI AIR RIFLE", "REPEATING AIR RIFLE", "RIFLES", 1779, "AUSTRIA",
     "BARTOLOMEO GIRARDONI",
     "A REPEATING AIR RIFLE, CARRIED BY LEWIS AND CLARK", "MUSKET",
     "Girardoni air rifle"],
    ["BAKER RIFLE", "FLINTLOCK RIFLE", "RIFLES", 1800, "BRITAIN", "EZEKIEL BAKER",
     "RIFLE OF THE BRITISH GREEN JACKETS IN THE NAPOLEONIC WARS", "MUSKET",
     "Baker rifle"],
    ["COLT PATERSON", "REVOLVER", "PISTOLS", 1836, "USA", "SAMUEL COLT",
     "THE FIRST COMMERCIAL REVOLVER WITH A TURNING CYLINDER", "REVOLVER",
     "Colt Paterson"],
    ["DREYSE NEEDLE GUN", "BOLT ACTION RIFLE", "RIFLES", 1841, "PRUSSIA",
     "NICOLAUS VON DREYSE",
     "THE FIRST BOLT ACTION BREECH LOADER IN MILITARY SERVICE", "BOLT",
     "Dreyse needle gun"],
    ["COLT WALKER", "REVOLVER", "PISTOLS", 1847, "USA", "SAMUEL COLT",
     "DESIGNED WITH THE TEXAS RANGERS, HUGE AND VERY POWERFUL", "REVOLVER",
     "Colt Walker"],
    ["SHARPS RIFLE", "FALLING BLOCK RIFLE", "RIFLES", 1848, "USA", "CHRISTIAN SHARPS",
     "SINGLE SHOT BREECH LOADER FAMED FOR LONG RANGE SHOOTING", "BOLT",
     "Sharps rifle"],
    ["DERRINGER", "POCKET PISTOL", "PISTOLS", 1852, "USA", "HENRY DERINGER",
     "A POCKET PISTOL WHOSE MAKERS NAME BECAME A WHOLE CLASS", "DERRINGER",
     "Derringer"],
    ["PATTERN 1853 ENFIELD", "RIFLED MUSKET", "RIFLES", 1853, "BRITAIN", "ROYAL SMALL ARMS FACTORY",
     "RIFLED MUSKET OF THE CRIMEA AND THE AMERICAN CIVIL WAR", "MUSKET",
     "Pattern 1853 Enfield"],
    ["HENRY RIFLE", "LEVER ACTION RIFLE", "RIFLES", 1860, "USA", "BENJAMIN HENRY",
     "A REPEATER YOU COULD LOAD ON SUNDAY AND FIRE ALL WEEK", "LEVER",
     "Henry rifle"],
    ["SPENCER RIFLE", "LEVER ACTION RIFLE", "RIFLES", 1860, "USA", "CHRISTOPHER SPENCER",
     "FIRST METALLIC CARTRIDGE REPEATER IN MILITARY SERVICE", "LEVER",
     "Spencer repeating rifle"],
    ["SPRINGFIELD 1861", "RIFLED MUSKET", "RIFLES", 1861, "USA", "SPRINGFIELD ARMORY",
     "THE STANDARD UNION RIFLED MUSKET OF THE CIVIL WAR", "MUSKET",
     "Springfield Model 1861"],
    ["GATLING GUN", "HAND CRANKED GUN", "MACHINE GUNS", 1861, "USA", "RICHARD GATLING",
     "HAND CRANKED MULTI BARREL, ANCESTOR OF THE MACHINE GUN", "GATLING",
     "Gatling gun"],
    ["CHASSEPOT", "BOLT ACTION RIFLE", "RIFLES", 1866, "FRANCE", "ANTOINE CHASSEPOT",
     "NEEDLE FIRE BOLT ACTION THAT FAR OUTRANGED THE DREYSE", "BOLT",
     "Chassepot"],
    ["SNIDER-ENFIELD", "BREECH LOADER", "RIFLES", 1866, "BRITAIN", "JACOB SNIDER",
     "TURNED EXISTING MUZZLE LOADERS INTO CARTRIDGE RIFLES", "BOLT",
     "Snider-Enfield"],
    ["S&W MODEL 3", "TOP BREAK REVOLVER", "PISTOLS", 1870, "USA", "SMITH & WESSON",
     "BREAKS OPEN AND THROWS OUT ALL SIX CASES AT ONCE", "REVOLVER",
     "Smith & Wesson Model 3"],
    ["MARTINI-HENRY", "LEVER SINGLE SHOT", "RIFLES", 1871, "BRITAIN", "MARTINI AND HENRY",
     "LEVER WORKED SINGLE SHOT OF THE LATE VICTORIAN ARMY", "LEVER",
     "Martini-Henry"],
    ["MAUSER MODEL 1871", "BOLT ACTION RIFLE", "RIFLES", 1871, "GERMANY", "PAUL MAUSER",
     "THE FIRST OF THE LONG MAUSER BOLT ACTION LINE", "BOLT",
     "Mauser Model 1871"],
    ["COLT SINGLE ACTION", "REVOLVER", "PISTOLS", 1873, "USA", "WILLIAM MASON",
     "THE PEACEMAKER, THE REVOLVER OF THE AMERICAN WEST", "REVOLVER",
     "Colt Single Action Army"],
    ["WINCHESTER 1873", "LEVER ACTION RIFLE", "RIFLES", 1873, "USA", "WINCHESTER",
     "SHARED ITS CARTRIDGE WITH THE REVOLVER ON YOUR HIP", "LEVER",
     "Winchester Model 1873"],
    ["SPRINGFIELD 1873", "TRAPDOOR RIFLE", "RIFLES", 1873, "USA", "SPRINGFIELD ARMORY",
     "THE TRAPDOOR, FIRST STANDARD ISSUE US BREECH LOADER", "BOLT",
     "Springfield Model 1873"],
    ["MAXIM GUN", "MACHINE GUN", "MACHINE GUNS", 1884, "BRITAIN", "HIRAM MAXIM",
     "THE FIRST FULLY AUTOMATIC MACHINE GUN", "MG",
     "Maxim gun"],
    ["LEBEL 1886", "BOLT ACTION RIFLE", "RIFLES", 1886, "FRANCE", "NICOLAS LEBEL",
     "FIRST SERVICE RIFLE TO USE SMOKELESS POWDER", "BOLT",
     "Lebel Model 1886 rifle"],
    ["KRAG-JORGENSEN", "BOLT ACTION RIFLE", "RIFLES", 1886, "NORWAY", "OLE KRAG",
     "SIDE LOADING MAGAZINE, TAKEN UP BY NORWAY DENMARK AND THE US", "BOLT",
     "Krag-Jorgensen"],
    ["WEBLEY REVOLVER", "TOP BREAK REVOLVER", "PISTOLS", 1887, "BRITAIN", "WEBLEY & SCOTT",
     "TOP BREAK SERVICE REVOLVER OF THE BRITISH EMPIRE", "REVOLVER",
     "Webley Revolver"],
    ["MOSIN-NAGANT", "BOLT ACTION RIFLE", "RIFLES", 1891, "RUSSIA", "MOSIN AND NAGANT",
     "RUSSIAN SERVICE RIFLE THROUGH BOTH WORLD WARS", "BOLT",
     "Mosin-Nagant"],
    ["CARCANO", "BOLT ACTION RIFLE", "RIFLES", 1891, "ITALY", "SALVATORE CARCANO",
     "ITALIAN SERVICE RIFLE, FED BY A CLIP OF SIX", "BOLT",
     "Carcano"],
    ["BORCHARDT C-93", "SELF LOADING PISTOL", "PISTOLS", 1893, "GERMANY", "HUGO BORCHARDT",
     "THE FIRST COMMERCIALLY SUCCESSFUL SELF LOADING PISTOL", "PISTOL",
     "Borchardt C-93"],
    ["WINCHESTER 1894", "LEVER ACTION RIFLE", "RIFLES", 1894, "USA", "JOHN BROWNING",
     "ONE OF THE MOST POPULAR SPORTING RIFLES EVER MADE", "LEVER",
     "Winchester Model 1894"],
    ["NAGANT M1895", "GAS SEAL REVOLVER", "PISTOLS", 1895, "RUSSIA", "LEON NAGANT",
     "THE CYLINDER SLIDES FORWARD TO SEAL THE GAS AT FIRING", "REVOLVER",
     "Nagant M1895"],
    ["LEE-ENFIELD", "BOLT ACTION RIFLE", "RIFLES", 1895, "BRITAIN", "JAMES PARIS LEE",
     "A FAST BOLT AND TEN ROUNDS, THE RIFLE OF THE EMPIRE", "BOLT",
     "Lee-Enfield"],
    ["MAUSER C96", "SELF LOADING PISTOL", "PISTOLS", 1896, "GERMANY", "FEEDERLE BROTHERS",
     "BROOMHANDLE GRIP, WITH THE MAGAZINE AHEAD OF THE TRIGGER", "PISTOL",
     "Mauser C96"],
    ["WINCHESTER 1897", "PUMP SHOTGUN", "SHOTGUNS", 1897, "USA", "JOHN BROWNING",
     "THE TRENCH GUN OF THE FIRST WORLD WAR", "SHOTGUN",
     "Winchester Model 1897"],
    ["GEWEHR 98", "BOLT ACTION RIFLE", "RIFLES", 1898, "GERMANY", "PAUL MAUSER",
     "THE MAUSER ACTION THE WHOLE WORLD WENT ON TO COPY", "BOLT",
     "Gewehr 98"],
    ["LUGER", "SELF LOADING PISTOL", "PISTOLS", 1898, "GERMANY", "GEORG LUGER",
     "A TOGGLE THAT FOLDS UPWARD, AND A PROFILE NOBODY MISTAKES", "PISTOL",
     "Luger pistol"],
    ["M1903 SPRINGFIELD", "BOLT ACTION RIFLE", "RIFLES", 1903, "USA", "SPRINGFIELD ARMORY",
     "US SERVICE RIFLE OF THE FIRST WORLD WAR", "BOLT",
     "M1903 Springfield"],
    ["TYPE 38 RIFLE", "BOLT ACTION RIFLE", "RIFLES", 1905, "JAPAN", "KIJIRO NAMBU",
     "THE LONG JAPANESE SERVICE RIFLE OF BOTH WORLD WARS", "BOLT",
     "Type 38 rifle"],
    ["LEWIS GUN", "LIGHT MACHINE GUN", "MACHINE GUNS", 1911, "USA", "ISAAC LEWIS",
     "DRUM FED, WITH A FAT COOLING SHROUD AROUND THE BARREL", "MG",
     "Lewis gun"],
    ["M1911 PISTOL", "SELF LOADING PISTOL", "PISTOLS", 1911, "USA", "JOHN BROWNING",
     "THE US SIDEARM FOR MORE THAN SEVENTY YEARS", "PISTOL",
     "M1911 pistol"],
    ["VICKERS GUN", "MACHINE GUN", "MACHINE GUNS", 1912, "BRITAIN", "VICKERS LIMITED",
     "WATER COOLED, AND FAMOUS FOR FIRING FOR DAYS ON END", "MG",
     "Vickers machine gun"],
    ["THOMPSON", "SUBMACHINE GUN", "MACHINE GUNS", 1918, "USA", "JOHN T THOMPSON",
     "MEANT AS A TRENCH BROOM, REMEMBERED AS THE TOMMY GUN", "SMG",
     "Thompson submachine gun"],
    ["BROWNING AUTO RIFLE", "AUTOMATIC RIFLE", "MACHINE GUNS", 1918, "USA", "JOHN BROWNING",
     "AN AUTOMATIC RIFLE ONE MAN COULD CARRY AND FIRE WALKING", "RIFLE",
     "Browning Automatic Rifle"],
    ["WALTHER PP", "SELF LOADING PISTOL", "PISTOLS", 1929, "GERMANY", "CARL WALTHER",
     "DOUBLE ACTION BLOWBACK POCKET PISTOL", "PISTOL",
     "Walther PP"],
    ["M2 BROWNING", "HEAVY MACHINE GUN", "MACHINE GUNS", 1933, "USA", "JOHN BROWNING",
     "FIFTY CALIBRE HEAVY GUN STILL IN SERVICE NINETY YEARS ON", "MG",
     "M2 Browning"],
    ["BREN GUN", "LIGHT MACHINE GUN", "MACHINE GUNS", 1935, "BRITAIN", "VACLAV HOLEK",
     "A CZECH DESIGN IN BRITISH SERVICE, MAGAZINE ON TOP", "MG",
     "Bren light machine gun"],
    ["KARABINER 98K", "BOLT ACTION RIFLE", "RIFLES", 1935, "GERMANY", "MAUSER",
     "STANDARD GERMAN SERVICE RIFLE OF THE SECOND WORLD WAR", "BOLT",
     "Karabiner 98k"],
    ["BROWNING HI-POWER", "SELF LOADING PISTOL", "PISTOLS", 1935, "BELGIUM", "DIEUDONNE SAIVE",
     "THIRTEEN ROUNDS, THE FIRST HIGH CAPACITY SERVICE PISTOL", "PISTOL",
     "Browning Hi-Power"],
    ["M1 GARAND", "SELF LOADING RIFLE", "RIFLES", 1936, "USA", "JOHN GARAND",
     "FIRST SELF LOADING RIFLE ISSUED AS STANDARD TO AN ARMY", "RIFLE",
     "M1 Garand"],
    ["MP 40", "SUBMACHINE GUN", "MACHINE GUNS", 1940, "GERMANY", "HEINRICH VOLLMER",
     "STAMPED METAL AND A FOLDING STOCK, BUILT FOR MASS PRODUCTION", "SMG",
     "MP 40"],
    ["M1 CARBINE", "SELF LOADING CARBINE", "RIFLES", 1941, "USA", "DAVID WILLIAMS",
     "A LIGHT CARBINE FOR TROOPS WHO COULD NOT CARRY A RIFLE", "RIFLE",
     "M1 carbine"],
    ["PPSH-41", "SUBMACHINE GUN", "MACHINE GUNS", 1941, "USSR", "GEORGY SHPAGIN",
     "DRUM FED AND MADE IN THE MILLIONS", "SMG",
     "PPSh-41"],
    ["STEN", "SUBMACHINE GUN", "MACHINE GUNS", 1941, "BRITAIN", "SHEPHERD AND TURPIN",
     "TUBING AND STAMPINGS, BUILT WHEN BRITAIN HAD NOTHING SPARE", "SMG",
     "Sten"],
    ["FG 42", "AUTOMATIC RIFLE", "RIFLES", 1942, "GERMANY", "LOUIS STANGE",
     "AN AUTOMATIC RIFLE BUILT FOR PARATROOPERS", "RIFLE",
     "FG 42"],
    ["MG 42", "MACHINE GUN", "MACHINE GUNS", 1942, "GERMANY", "WERNER GRUNER",
     "A RATE OF FIRE SO HIGH IT IS STILL COPIED TODAY", "MG",
     "MG 42"],
    ["STG 44", "ASSAULT RIFLE", "RIFLES", 1944, "GERMANY", "HUGO SCHMEISSER",
     "THE FIRST TRUE ASSAULT RIFLE, AND THE PATTERN FOR ALL AFTER", "RIFLE",
     "StG 44"],
    ["AK-47", "ASSAULT RIFLE", "RIFLES", 1947, "USSR", "MIKHAIL KALASHNIKOV",
     "THE MOST PRODUCED FIREARM IN HISTORY", "RIFLE",
     "AK-47"],
    ["REMINGTON 870", "PUMP SHOTGUN", "SHOTGUNS", 1950, "USA", "REMINGTON",
     "PUMP SHOTGUN MADE IN THE MILLIONS SINCE 1950", "SHOTGUN",
     "Remington Model 870"],
    ["UZI", "SUBMACHINE GUN", "MACHINE GUNS", 1950, "ISRAEL", "UZIEL GAL",
     "THE MAGAZINE SITS IN THE GRIP, WHICH MADE IT SHORT", "SMG",
     "Uzi"],
    ["FN FAL", "BATTLE RIFLE", "RIFLES", 1953, "BELGIUM", "DIEUDONNE SAIVE",
     "CARRIED BY SO MANY ARMIES IT WAS CALLED THE FREE WORLDS ARM", "RIFLE",
     "FN FAL"],
    ["COLT PYTHON", "REVOLVER", "PISTOLS", 1955, "USA", "COLT",
     "A MAGNUM REVOLVER KNOWN FOR ITS FINISH AND ITS TRIGGER", "REVOLVER",
     "Colt Python"],
    ["S&W MODEL 29", "REVOLVER", "PISTOLS", 1955, "USA", "SMITH & WESSON",
     "THE FORTY FOUR MAGNUM REVOLVER", "REVOLVER",
     "Smith & Wesson Model 29"],
    ["M60 MACHINE GUN", "MACHINE GUN", "MACHINE GUNS", 1957, "USA", "SPRINGFIELD ARMORY",
     "THE GENERAL PURPOSE MACHINE GUN OF VIETNAM", "MG",
     "M60 machine gun"],
    ["H&K G3", "BATTLE RIFLE", "RIFLES", 1959, "GERMANY", "HECKLER & KOCH",
     "ROLLER DELAYED ACTION, TAKEN UP BY SOME FIFTY ARMIES", "RIFLE",
     "Heckler & Koch G3"],
    ["REMINGTON 700", "BOLT ACTION RIFLE", "RIFLES", 1962, "USA", "REMINGTON",
     "THE BOLT ACTION BEHIND COUNTLESS SPORTING AND TARGET RIFLES", "BOLT",
     "Remington Model 700"],
    ["M16 RIFLE", "ASSAULT RIFLE", "RIFLES", 1964, "USA", "EUGENE STONER",
     "ALUMINIUM AND PLASTIC, LIGHT, AND A SMALL FAST BULLET", "RIFLE",
     "M16 rifle"],
    ["GLOCK 17", "SELF LOADING PISTOL", "PISTOLS", 1982, "AUSTRIA", "GASTON GLOCK",
     "A POLYMER FRAME THAT CHANGED THE WHOLE HANDGUN TRADE", "PISTOL",
     "Glock"],
]

# ------------------------------------------------------------- text tools
# Every glyph the fonts actually carry.
ALLOWED = " !#$%&()*+,-./0123456789:?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"

SUBS = {
    "\u00d7": "X", "\u2013": "-", "\u2014": "-", "\u2212": "-",
    "\u2018": "", "\u2019": "", "\u201c": "", "\u201d": "",
    "\u00c1": "A", "\u00c0": "A", "\u00c2": "A", "\u00c4": "A",
    "\u00c3": "A", "\u00c5": "A", "\u00c6": "AE",
    "\u00c9": "E", "\u00c8": "E", "\u00ca": "E", "\u00cb": "E",
    "\u00cd": "I", "\u00cc": "I", "\u00ce": "I", "\u00cf": "I",
    "\u00d3": "O", "\u00d2": "O", "\u00d4": "O", "\u00d6": "O",
    "\u00d5": "O", "\u00d8": "O",
    "\u00da": "U", "\u00d9": "U", "\u00db": "U", "\u00dc": "U",
    "\u00d1": "N", "\u00c7": "C", "\u00dd": "Y", "\u00df": "SS",
}

def safe(s):
    """Filter live text to glyphs that exist. An unsupported character
    becomes a space rather than vanishing: dropping the multiplication sign
    turns 7.62x39MM into 7.6239MM, which is a different and wrong number."""
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

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    last = fonts[len(fonts) - 1]
    return [last, clip_words(c, text, last, maxw)]

def wrap2(c, text, font, maxw):
    """Two lines, split on the word boundary that evens them up best. A
    placard line that will not fit should not simply lose its ending."""
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

def rail(c, col):
    c.rect(0, 0, 1, 31, fill = col)

def pill(c, text, col, x, y):
    w = c.text_width(text, "4x5") + 4
    c.rect(x, y, x + w - 1, y + 6, fill = col)
    c.text(text, x + 2, y + 1, font = "4x5", color = "black")
    return w

# ---------------------------------------------------------- the silhouettes
# Each draws into a 22 px band from (x, y). The widths differ on purpose:
# relative size is part of the story. A handgun still has to read as a
# handgun rather than as a short rifle, so it gets a deep grip, a tall
# fluted cylinder and a barrel that stays short.
WIDTHS = {
    "MUSKET": 176, "BLUNDER": 140, "BOLT": 172, "LEVER": 164, "RIFLE": 168,
    "SHOTGUN": 164, "SMG": 140, "MG": 160, "GATLING": 150, "REVOLVER": 110,
    "PISTOL": 100, "DERRINGER": 64,
}

def _stock(c, x, y, butt, wrist, wood):
    """Butt plate, comb along the top, belly tapering into the wrist."""
    c.rect(x, y + 6, x + 4, y + 19, fill = wood)
    c.rect(x + 4, y + 7, x + butt, y + 11, fill = wood)
    c.rect(x + 4, y + 12, x + butt - 10, y + 18, fill = wood)
    c.fill_triangle(x + butt - 10, y + 12, x + butt - 10, y + 18,
                    x + wrist, y + 12, wood)
    c.rect(x + butt, y + 9, x + wrist, y + 14, fill = wood)

def _guard(c, x0, y0, x1, y1, metal):
    """An open trigger guard: two uprights and a bottom bar."""
    c.rect(x0, y0, x0 + 1, y1, fill = metal)
    c.rect(x1 - 1, y0, x1, y1, fill = metal)
    c.rect(x0, y1 - 1, x1, y1, fill = metal)

def draw_musket(c, x, y, metal, wood):
    _stock(c, x, y, 40, 50, wood)
    c.rect(x + 50, y + 9, x + 66, y + 15, fill = metal)       # lock plate
    c.rect(x + 55, y + 4, x + 60, y + 9, fill = metal)        # cock
    c.rect(x + 62, y + 4, x + 65, y + 9, fill = metal)        # frizzen
    _guard(c, x + 48, y + 15, x + 62, y + 20, metal)
    c.rect(x + 66, y + 11, x + 142, y + 14, fill = wood)      # forestock
    c.rect(x + 66, y + 5, x + 172, y + 9, fill = metal)       # barrel
    c.rect(x + 166, y + 3, x + 172, y + 11, fill = metal)     # muzzle
    c.rect(x + 70, y + 15, x + 150, y + 16, fill = metal)     # ramrod

def draw_blunder(c, x, y, metal, wood):
    _stock(c, x, y, 36, 44, wood)
    c.rect(x + 44, y + 9, x + 58, y + 15, fill = metal)       # lock plate
    c.rect(x + 48, y + 4, x + 53, y + 9, fill = metal)        # cock
    _guard(c, x + 42, y + 15, x + 56, y + 20, metal)
    c.rect(x + 58, y + 8, x + 104, y + 13, fill = metal)      # barrel
    c.rect(x + 104, y + 6, x + 118, y + 15, fill = metal)
    c.fill_triangle(x + 118, y + 10, x + 136, y + 2, x + 136, y + 19, metal)
    c.rect(x + 132, y + 2, x + 138, y + 19, fill = metal)     # the bell mouth

def draw_bolt(c, x, y, metal, wood):
    _stock(c, x, y, 42, 50, wood)
    c.rect(x + 50, y + 6, x + 84, y + 14, fill = metal)       # receiver
    c.rect(x + 84, y + 4, x + 89, y + 7, fill = metal)        # rear sight
    c.rect(x + 70, y + 14, x + 76, y + 18, fill = metal)      # bolt handle
    c.fill_circle(x + 73, y + 19, 3, metal)                   # bolt knob
    c.rect(x + 54, y + 14, x + 68, y + 19, fill = metal)      # magazine
    _guard(c, x + 46, y + 15, x + 60, y + 20, metal)
    c.rect(x + 84, y + 10, x + 130, y + 15, fill = wood)      # forend
    c.rect(x + 130, y + 8, x + 168, y + 12, fill = metal)     # barrel
    c.rect(x + 162, y + 5, x + 165, y + 9, fill = metal)      # front sight

def draw_lever(c, x, y, metal, wood):
    _stock(c, x, y, 40, 48, wood)
    c.rect(x + 48, y + 7, x + 80, y + 15, fill = metal)       # receiver
    c.rect(x + 44, y + 4, x + 50, y + 8, fill = metal)        # hammer spur
    # The finger loop, the one feature that says lever action at a glance.
    c.rect(x + 50, y + 16, x + 52, y + 21, fill = metal)
    c.rect(x + 74, y + 16, x + 76, y + 21, fill = metal)
    c.rect(x + 50, y + 19, x + 76, y + 21, fill = metal)
    c.rect(x + 80, y + 11, x + 118, y + 15, fill = wood)      # forend
    c.rect(x + 80, y + 15, x + 152, y + 17, fill = metal)     # magazine tube
    c.rect(x + 118, y + 8, x + 160, y + 13, fill = metal)     # barrel
    c.rect(x + 154, y + 5, x + 157, y + 9, fill = metal)      # front sight

def draw_shotgun(c, x, y, metal, wood):
    _stock(c, x, y, 42, 50, wood)
    c.rect(x + 50, y + 6, x + 78, y + 15, fill = metal)       # receiver
    _guard(c, x + 48, y + 15, x + 62, y + 20, metal)
    c.rect(x + 78, y + 5, x + 160, y + 10, fill = metal)      # barrel
    c.rect(x + 78, y + 11, x + 142, y + 14, fill = metal)     # magazine tube
    c.rect(x + 96, y + 10, x + 128, y + 17, fill = wood)      # pump forend
    c.rect(x + 155, y + 3, x + 157, y + 5, fill = metal)      # bead

def draw_rifle(c, x, y, metal, wood):
    c.rect(x, y + 7, x + 30, y + 14, fill = wood)             # straight stock
    c.rect(x + 30, y + 6, x + 80, y + 14, fill = metal)       # receiver
    c.rect(x + 72, y + 3, x + 77, y + 6, fill = metal)        # rear sight
    c.rect(x + 44, y + 14, x + 56, y + 21, fill = wood)       # pistol grip
    c.rect(x + 60, y + 14, x + 76, y + 21, fill = metal)      # magazine
    c.fill_triangle(x + 60, y + 21, x + 76, y + 21, x + 76, y + 15, metal)
    c.rect(x + 80, y + 6, x + 122, y + 9, fill = metal)       # gas tube
    c.rect(x + 80, y + 10, x + 122, y + 15, fill = wood)      # handguard
    c.rect(x + 122, y + 9, x + 162, y + 13, fill = metal)     # barrel
    c.rect(x + 150, y + 3, x + 155, y + 10, fill = metal)     # front post

def draw_smg(c, x, y, metal, wood):
    c.rect(x, y + 7, x + 5, y + 16, fill = metal)             # butt plate
    c.rect(x + 5, y + 10, x + 30, y + 13, fill = metal)       # wire stock
    c.rect(x + 30, y + 5, x + 96, y + 14, fill = metal)       # receiver tube
    c.rect(x + 64, y + 2, x + 70, y + 5, fill = metal)        # bolt handle
    c.rect(x + 34, y + 14, x + 46, y + 21, fill = wood)       # pistol grip
    c.rect(x + 54, y + 14, x + 66, y + 21, fill = metal)      # magazine
    c.rect(x + 78, y + 14, x + 90, y + 20, fill = wood)       # foregrip
    c.rect(x + 96, y + 7, x + 126, y + 12, fill = metal)      # barrel
    c.rect(x + 118, y + 5, x + 130, y + 14, fill = metal)     # compensator

def draw_mg(c, x, y, metal, wood):
    c.rect(x, y + 3, x + 14, y + 16, fill = metal)            # spade grips
    c.rect(x + 14, y + 5, x + 52, y + 15, fill = metal)       # receiver
    c.rect(x + 52, y + 5, x + 126, y + 15, fill = metal)      # water jacket
    for i in range(8):
        c.rect(x + 58 + i * 8, y + 5, x + 59 + i * 8, y + 15, fill = wood)
    c.rect(x + 126, y + 8, x + 144, y + 13, fill = metal)     # muzzle
    c.rect(x + 24, y + 15, x + 50, y + 19, fill = wood)       # ammunition belt
    c.rect(x + 84, y + 15, x + 88, y + 18, fill = metal)      # tripod head
    c.line(x + 86, y + 17, x + 62, y + 21, metal)
    c.line(x + 86, y + 17, x + 110, y + 21, metal)
    c.rect(x + 58, y + 20, x + 114, y + 21, fill = metal)

def draw_gatling(c, x, y, metal, wood):
    c.rect(x + 52, y, x + 70, y + 4, fill = wood)             # feed hopper
    c.fill_circle(x + 22, y + 10, 8, metal)                   # crank wheel
    c.rect(x + 28, y + 9, x + 42, y + 12, fill = metal)
    c.rect(x + 40, y + 4, x + 68, y + 16, fill = metal)       # receiver
    c.rect(x + 68, y + 4, x + 134, y + 6, fill = metal)       # barrel cluster
    c.rect(x + 68, y + 7, x + 134, y + 9, fill = metal)
    c.rect(x + 68, y + 10, x + 134, y + 12, fill = metal)
    c.rect(x + 68, y + 13, x + 134, y + 15, fill = metal)
    c.rect(x + 130, y + 3, x + 140, y + 16, fill = metal)     # muzzle plate
    c.fill_circle(x + 52, y + 19, 2, wood)                    # carriage wheel
    c.rect(x + 8, y + 18, x + 50, y + 20, fill = wood)        # trail

def draw_revolver(c, x, y, metal, wood):
    c.fill_triangle(x, y + 21, x + 6, y + 7, x + 26, y + 21, wood)
    c.rect(x + 6, y + 7, x + 26, y + 18, fill = wood)         # grip
    c.rect(x + 20, y + 5, x + 26, y + 10, fill = metal)       # backstrap
    c.rect(x + 18, y + 2, x + 28, y + 7, fill = metal)        # hammer
    c.rect(x + 24, y + 6, x + 46, y + 10, fill = metal)       # frame
    c.rect(x + 38, y + 5, x + 62, y + 17, fill = metal)       # cylinder
    c.rect(x + 44, y + 7, x + 46, y + 15, fill = wood)        # flutes
    c.rect(x + 52, y + 7, x + 54, y + 15, fill = wood)
    _guard(c, x + 24, y + 15, x + 40, y + 21, metal)
    c.rect(x + 30, y + 15, x + 32, y + 18, fill = metal)      # trigger
    c.rect(x + 62, y + 7, x + 100, y + 13, fill = metal)      # barrel
    c.rect(x + 62, y + 14, x + 92, y + 16, fill = metal)      # ejector rod
    c.rect(x + 94, y + 4, x + 98, y + 7, fill = metal)        # front sight

def draw_pistol(c, x, y, metal, wood):
    c.fill_triangle(x, y + 21, x + 8, y + 9, x + 24, y + 21, wood)
    c.rect(x + 8, y + 9, x + 24, y + 21, fill = wood)         # grip
    c.rect(x + 10, y + 10, x + 56, y + 15, fill = metal)      # frame
    c.rect(x + 10, y + 3, x + 92, y + 10, fill = metal)       # slide
    c.rect(x + 14, y + 4, x + 16, y + 8, fill = wood)         # serrations
    c.rect(x + 19, y + 4, x + 21, y + 8, fill = wood)
    c.rect(x + 50, y + 5, x + 64, y + 7, fill = wood)         # ejection port
    c.rect(x + 88, y + 4, x + 94, y + 9, fill = metal)        # muzzle
    _guard(c, x + 24, y + 15, x + 40, y + 20, metal)
    c.rect(x + 29, y + 15, x + 31, y + 18, fill = metal)      # trigger
    c.rect(x + 86, y + 1, x + 90, y + 3, fill = metal)        # front sight
    c.rect(x + 12, y + 1, x + 16, y + 3, fill = metal)        # rear sight

def draw_derringer(c, x, y, metal, wood):
    c.fill_triangle(x, y + 21, x + 4, y + 9, x + 20, y + 21, wood)
    c.rect(x + 4, y + 9, x + 20, y + 21, fill = wood)         # grip
    c.rect(x + 14, y + 4, x + 22, y + 9, fill = metal)        # hammer
    c.rect(x + 16, y + 8, x + 34, y + 15, fill = metal)       # frame
    c.rect(x + 22, y + 15, x + 24, y + 18, fill = metal)      # trigger
    c.rect(x + 34, y + 6, x + 60, y + 10, fill = metal)       # upper barrel
    c.rect(x + 34, y + 11, x + 60, y + 15, fill = metal)      # lower barrel

def silhouette(c, shape, y, metal, wood):
    """Centre whatever shape this piece uses inside the safe zone."""
    w = WIDTHS.get(shape, 140)
    x = 10 + (172 - w) // 2
    if shape == "MUSKET":
        draw_musket(c, x, y, metal, wood)
    elif shape == "BLUNDER":
        draw_blunder(c, x, y, metal, wood)
    elif shape == "BOLT":
        draw_bolt(c, x, y, metal, wood)
    elif shape == "LEVER":
        draw_lever(c, x, y, metal, wood)
    elif shape == "SHOTGUN":
        draw_shotgun(c, x, y, metal, wood)
    elif shape == "RIFLE":
        draw_rifle(c, x, y, metal, wood)
    elif shape == "SMG":
        draw_smg(c, x, y, metal, wood)
    elif shape == "MG":
        draw_mg(c, x, y, metal, wood)
    elif shape == "GATLING":
        draw_gatling(c, x, y, metal, wood)
    elif shape == "REVOLVER":
        draw_revolver(c, x, y, metal, wood)
    elif shape == "PISTOL":
        draw_pistol(c, x, y, metal, wood)
    else:
        draw_derringer(c, x, y, metal, wood)

# ------------------------------------------------------------------ pick
def era_of(year):
    for e in ERAS:
        if year < e[0]:
            return e
    return ERAS[len(ERAS) - 1]

def in_era(year, want):
    if want == "BEFORE 1850":
        return year < 1850
    if want == "1850 TO 1899":
        return year >= 1850 and year < 1900
    if want == "WORLD WARS":
        return year >= 1900 and year < 1946
    if want == "MODERN":
        return year >= 1946
    return True

def choose(ctx):
    era = str(ctx.inputs.get("era", "ALL ERAS")).strip().upper()
    kind = str(ctx.inputs.get("category", "ALL KINDS")).strip().upper()
    pool = []
    for g in ROSTER:
        if era != "ALL ERAS" and not in_era(g[3], era):
            continue
        if kind != "ALL KINDS" and g[2] != kind:
            continue
        pool.append(g)
    if len(pool) == 0:
        return None
    # One piece a day, the year shifting where the sequence starts so the
    # same date does not land on the same gun every year.
    idx = (ctx.now.yday - 1 + ctx.now.year * 3) % len(pool)
    return pool[idx]

def empty(c):
    c.fill("black")
    rail(c, "#C87137")
    c.text("NOTHING IN THAT PERIOD", 96, 8, font = "6x8", color = "#C87137",
           align = "center")
    c.text("TRY ANOTHER ERA OR KIND", 96, 20, font = "4x5", color = DIM,
           align = "center")

# ----------------------------------------------------------- page: today
def today(c, ctx):
    g = choose(ctx)
    if g == None:
        empty(c)
        return
    era = era_of(g[3])
    c.fill("black")
    rail(c, era[1])

    # The hero page gives its whole top to the piece: art 0..21, then the
    # name and year on one row at 23..30. What kind it is and where it came
    # from are on the specs page, which is what that page is for.
    silhouette(c, g[7], 0, STEEL, era[1])

    year = str(g[3])
    yw = c.text_width(year, "4x5")
    c.text(year, 181, 24, font = "4x5", color = era[1], align = "right")
    nf = fit(c, g[0], ["6x8", "5x7", "4x5"], 172 - yw - 6)
    c.text(nf[1], 10, 23, font = nf[0], color = INK)

# ----------------------------------------------------------- page: story
def story(c, ctx):
    g = choose(ctx)
    if g == None:
        empty(c)
        return
    era = era_of(g[3])
    c.fill("black")
    rail(c, era[1])

    x = 10 + pill(c, clip(c, g[0], "4x5", 96), era[1], 10, 0) + 3
    year = str(g[3])
    c.text(year, 181, 1, font = "4x5", color = INK, align = "right")

    two = wrap2(c, g[6], "4x5", 172)
    c.text(two[0], 10, 8, font = "4x5", color = INK)
    if two[1] != "":
        c.text(two[1], 10, 14, font = "4x5", color = INK)

    if g[5] != "":
        c.text(clip(c, "DESIGNED BY " + g[5], "4x5", 172), 10, 20,
               font = "4x5", color = DIM)

    # The only line that goes to the network. If it is not there, the
    # placard simply ends after the curated text.
    r = http.get(REST + g[8].replace(" ", "_").replace("&", "%26"),
                 headers = UA, ttl_seconds = 3600)
    if r["status_code"] == 200:
        js = r["json"]
        if type(js) == "dict":
            d = safe(js.get("description", ""))
            if d != "":
                c.text(clip_words(c, "WIKIPEDIA: " + d, "4x5", 172), 10, 26,
                       font = "4x5", color = DARK)

# ----------------------------------------------------------- page: specs
def specs(c, ctx):
    g = choose(ctx)
    if g == None:
        empty(c)
        return
    era = era_of(g[3])
    c.fill("black")
    rail(c, era[1])

    pill(c, clip(c, g[0], "4x5", 110), era[1], 10, 0)
    c.text(era[2], 181, 1, font = "4x5", color = DIM, align = "right")

    rows = [
        ["ORIGIN", g[4]],
        ["APPEARED", str(g[3])],
        ["DESIGNER", g[5] if g[5] != "" else "NO SINGLE DESIGNER"],
        ["KIND", g[1]],
    ]
    for i in range(len(rows)):
        y = 9 + i * 6
        c.text(rows[i][0], 10, y, font = "4x5", color = DIM)
        c.text(clip(c, rows[i][1], "4x5", 110), 181, y, font = "4x5",
               color = INK, align = "right")
