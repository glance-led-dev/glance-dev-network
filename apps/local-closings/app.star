# Local Closings -- school, business, church and government closings and
# delays from your local TV station, on a 192x32 SCROLL panel.
#
# WHERE THE LIST COMES FROM. Type a ZIP code and the app finds the nearest
# closings source it can read (STATIONS below: 309 TV stations and statewide
# systems in 49 states and D.C. -- New Jersey is served from New York and
# Philadelphia -- each checked against this app's own reader), using the free
# zippopotam.us ZIP lookup. Or paste any station's closings page link,
# which wins over the ZIP code.
#
# PAGES
#   board      ALL CLEAR, or how many closings and of which kind, with your
#              school's status when you've named it
#   closings   three closings at a time with an icon for each kind of
#              place and a status chip; the list rolls on each refresh. With
#              nothing listed, the station being watched and how far away it is
#
# Family adapters (technology, not ownership). Not a universal HTML scraper:
#   Gray GSync JSON / NewsTicker XML  — Gray, Allen Media, and other GSync pages
#   TownNews / BLOX XML               — KOAM and other /app/closings/*.xml pages
#   Nexstar WP + PSG iframe           — KSN, Four States Homepage, similar WP sites;
#                                       PSG NewsTicker XML (WGN's Chicago-wide list)
#   NBC O&O WordPress                 — NBCDFW and other nbc-station school-closings pages
#   Scripps Brightspot / FlashAlert   — KOAA module--closings; KATU FlashAlert iframe
#   WorldNow orgname HTML             — FOX O&O media.foxtv.com pages; Sinclair ftptransfer
#                                       pages; the RI Broadcasters Association list
#   Delaware state XML                — schoolclosings.delaware.gov, every DE district
#   NPG closings table                — ABC 17 (KMIZ) npgdigital.com closings page
#   TownNews storm articles           — Wyoming News Now's newest "School Closings and
#                                       Delays" post, read only while it's under 20 hours old
#   TEGNA closings module             — WFAA / KHOU / KARE closings__* HTML
#   Hearst closingsData               — KMBC / WISN / WCVB embedded payload
#   CBS News school-closings feed     — NewsTicker or BLOX XML from data-school-closings-options
#   Cox Arc closing-list              — WSB / WPXI / KIRO school-closings widget
#   Arc SchoolClosings widget         — 9&10 News weather-school-closings JSON
#
# Visible HTML tables are often empty until JS runs. Glance cannot run that JS,
# so each adapter follows the small public feed the page itself loads.
#
# Starlark has no HTML/XML module and no regex. Tags and JSON keys are read
# with string finds / dict.get. Frames are still images.

HEADERS = {
    "User-Agent": "GlanceLocalClosings/1.0 (GDN; closings display)",
    "Accept": "application/json, application/xml, text/xml, text/html;q=0.9, */*;q=0.8",
}

TTL = 300
WANT = 5
ZIP_URL = "https://api.zippopotam.us/us/"
ZIP_TTL = 2592000  # a ZIP code doesn't move
LEFT = 10
RIGHT = 181
SCAN = 250
TOWNNEWS_TRIES = 3
GSYNC_PATH = "/pf/api/v3/content/fetch/gsync-closings"
ARC_SCHOOL_PATH = "/pf/api/v3/content/fetch/weather-school-closings"
STORM_LIST_HOURS = 20
DELAWARE_FEED = "https://schoolclosings.delaware.gov/XML/PortalFeed?_search=false&rows=250&page=1&sidx=name&sord=asc"

BG = "#000000"
TITLE = "#F4F7FF"
DIM = "#6E7A94"
MUTED = "#AEB8CE"
RED = "#FF3B3B"
AMBER = "#FFC43A"
ORANGE = "#FF8A3D"
GREEN = "#3EEB8A"
CYAN = "#5EE1FF"
FAIL = "#E8B04A"
INK = "#071018"

NAME_KEYS = [
    "name", "organization", "organizationName", "organization_name",
    "ORGANIZATION_NAME1", "orgName", "title", "forcedOrganizationName",
    "FORCED_ORGANIZATION_NAME", "organizationName1", "org", "Name1", "name1",
]
STATUS_KEYS = [
    "status", "completeStatus", "COMPLETE_STATUS", "statusName",
    "STATUS_NAME1", "statusText", "forcedStatusName", "FORCED_STATUS_NAME",
    "altStatusText", "ALT_STATUS_TEXT", "statusName1", "closingStatus",
    "notice",
]
DETAIL_KEYS = [
    "detail", "comments", "comment", "COMMENTS_LINE1", "description",
    "notes", "altStatusText", "commentsLine1",
]
ZIP_KEYS = ["zipcode", "zipCode", "ZIPCODE", "zip", "postalCode"]
TYPE_KEYS = [
    "type", "category", "CATEGORY_NAME1", "categoryName", "orgType", "EntityType",
    "entitytype",
]

# ---- art (three-tone shading) ---------------------------------------------------

# The school bus: the board's hero when schools lead the list. A conventional
# (Type C) bus from the door side: National School Bus Yellow, hood and grille
# up front, black rub rails, split-sash windows, the folding entrance door,
# the SCHOOL BUS sign band and the amber/red 8-way warning lamps on the roof.
BUS = """
.RAhhhhhhhhhhhhhhhhhhAR.......
RYYYYYYYYYYYYKKKKKKKYYYk......
YYsWWYsWWYsWWYsWWYkWWkYWk.....
YYWWWYWWWYWWWYWWWYkWWkYWWk....
YYkkkYkkkYkkkYkkkYkWWkYWWWk.K.
YYwwwYwwwYwwwYwwwYkwwkYwwwwkk.
KKKKKKKKKKKKKKKKKKkWWkKhhhhhhh
RYYYYYYYYYYYYYYYYYkWWkYYYYYYLG
KKKKKKKKKKKKKKKKKKkwwkKYYYYYYG
yyyyKKKKyyyyyyyyyykkkkyyKKKKyG
KyyKTTTTKyyyyyyyyyyyyyyKTTTTKK
.kkTtggtTkkkkkkkkkkkkkkTtggtT.
...TttttT..............TttttT.
....TTTT................TTTT..
"""
BUS_LEGEND = {"h": "#FFE07A", "Y": "#FFB81C", "y": "#D99200", "K": "#151515", "k": "#3C3C3C",
              "W": "#A8DAFA", "w": "#4F8CC0", "s": "#EAF7FF", "A": "#FF9500", "R": "#FF2E2E",
              "L": "#FFF6C8", "G": "#A7B0BE", "T": "#1B1B1B", "t": "#3A3A3A", "g": "#C3CBD6"}

# The storefront with its CLOSED sign: the hero when businesses lead.
STORE = """
.RWRWRWRWRWRWRWRWRWRWR.
RWRWRWRWRWRWRWRWRWRWRWR
.rwrwrwrwrwrwrwrwrwrwr.
.BBBBBBBBBBBBBBBBBBBBB.
.BGGGGGGGBBBDDDDDBGGGB.
.BGgGGGgGBBBDsssDBGgGB.
.BGGGGGGGBBBDSSSDBGGGB.
.BGGgGGGGBBBDsssDBGGgB.
.BGGGGGGGBBBDDDDDBGGGB.
.BBBBBBBBBBBDDkDDBBBBB.
.BBBBBBBBBBBDDDDDBBBBB.
PPPPPPPPPPPPPPPPPPPPPPP
"""
STORE_LEGEND = {"R": "#E5322D", "W": "#F4F7FB", "r": "#A3150F", "w": "#B9C4D2", "B": "#8A6A4A", "G": "#BFE6FF", "g": "#7FB8E0", "D": "#5A3A20", "s": "#FF3B30", "S": "#FFFFFF", "k": "#FFC21A", "P": "#6E7A94"}

CHECK = """
.........GG
........GGg
.......GGg.
GG....GGg..
gGG..GGg...
.gGGGGg....
..gGGg.....
...gg......
"""
CHECK_LEGEND = {"G": "#3EEB8A", "g": "#1E9E58"}

WARN = """
.....A.....
....AAA....
....AKA....
...AAKAA...
...AAKAA...
..AAAKAAA..
..AAAAAAA..
.AAAAKAAAA.
AAAAAAAAAAA
"""
WARN_LEGEND = {"A": "#FFC43A", "K": "#2A1A00"}

# The station being watched.
TV = """
..a.....a....
...a...a.....
....a.a......
.....a.......
SSSSSSSSSSSSS
SBBBBBBBBBSKS
SBGGgGGGGBSkS
SBGGGGGGGBSKS
SBGGGGgGGBSkS
SBBBBBBBBBSSS
SSSSSSSSSSSSS
.SS.......SS.
"""
TV_LEGEND = {"a": "#AEB8CE", "S": "#6E7A94", "B": "#1A2233", "G": "#5EE1FF", "g": "#BFF4FF", "K": "#FFC43A", "k": "#3A4763"}

# One small icon per kind of place, for the closings list.
ICONS = {
 "school": ["""
YYYYYYk..
YWYWYWWk.
KKKKKKKhh
YYYYYYYYL
yTTyyyTTG
.TT...TT.
""", {"Y": "#FFB81C", "y": "#D99200", "h": "#FFE07A", "W": "#A8DAFA", "K": "#151515",
      "k": "#3C3C3C", "L": "#FFF6C8", "G": "#A7B0BE", "T": "#5A5A5A"}],
 "business": ["""
RWRWRWRWR
rwrwrwrwr
.BGGBDDB.
.BGGBDDB.
.BBBBDDB.
PPPPPPPPP
""", {"R": "#E5322D", "W": "#F4F7FB", "r": "#A3150F", "w": "#B9C4D2", "B": "#8A6A4A", "G": "#BFE6FF", "D": "#5A3A20", "P": "#6E7A94"}],
 "church": ["""
....Y....
...YYY...
....W....
...WWW...
..WWWWW..
.WWWDWWW.
.WWWDWWW.
""", {"Y": "#FFC21A", "W": "#E8ECF4", "D": "#5A3A20"}],
 "government": ["""
....S....
..SSSSS..
SSSSSSSSS
.S.S.S.S.
.S.S.S.S.
SSSSSSSSS
""", {"S": "#DCE3EC"}],
 "daycare": ["""
.RRR.BBB.
.RAR.BBB.
.RRR.BBB.
..GGGGG..
..GGGGG..
..GGGGG..
""", {"R": "#FF6A5A", "A": "#FFFFFF", "B": "#5AB4FF", "G": "#3EEB8A"}],
}

# Stations whose closings page this app reads, for the ZIP code lookup:
# [name, city, state, lat, lng, closings page]. Each one was checked by
# running its page through this app's reader. A bare "host/path" is fetched
# on www; sites that don't use www are stored with https:// in front.
STATIONS = [
    ["ALASKA'S NEWS SOURCE", "ANCHORAGE", "AK", 61.22, -149.9, "alaskasnewssource.com/weather/closings/"],
    ["ABC 33/40", "BIRMINGHAM", "AL", 33.52, -86.81, "https://abc3340.com/resources/ftptransfer/wbma/closings/closings.html"],
    ["WAFF", "HUNTSVILLE", "AL", 34.73, -86.59, "waff.com/weather/closings/"],
    ["WBRC", "BIRMINGHAM", "AL", 33.52, -86.81, "wbrc.com/weather/closings/"],
    ["WSFA", "MONTGOMERY", "AL", 32.37, -86.3, "wsfa.com/weather/closings/"],
    ["WTVY", "DOTHAN", "AL", 31.22, -85.39, "wtvy.com/weather/closings/"],
    ["WVTM", "BIRMINGHAM", "AL", 33.52, -86.81, "wvtm13.com/weather/closings"],
    ["5NEWS", "FORT SMITH", "AR", 35.39, -94.4, "5newsonline.com/closings"],
    ["KAIT", "JONESBORO", "AR", 35.84, -90.7, "kait8.com/weather/closings/"],
    ["KARK", "LITTLE ROCK", "AR", 34.75, -92.29, "kark.com/weather/closings/"],
    ["KNWA", "FAYETTEVILLE", "AR", 36.06, -94.16, "nwahomepage.com/weather/closings/"],
    ["THV11", "LITTLE ROCK", "AR", 34.75, -92.29, "thv11.com/closings"],
    ["12NEWS", "PHOENIX", "AZ", 33.45, -112.07, "12news.com/closings"],
    ["AZFAMILY", "PHOENIX", "AZ", 33.45, -112.07, "azfamily.com/weather/closings/"],
    ["KOLD", "TUCSON", "AZ", 32.22, -110.97, "kold.com/weather/closings/"],
    ["ABC10", "SACRAMENTO", "CA", 38.58, -121.49, "abc10.com/closings"],
    ["KCRA", "SACRAMENTO", "CA", 38.58, -121.49, "kcra.com/weather/closings"],
    ["KMPH", "FRESNO", "CA", 36.74, -119.79, "https://kmph.com/resources/ftptransfer/kmph/closings/closings.html"],
    ["NBC 7", "SAN DIEGO", "CA", 32.72, -117.16, "nbcsandiego.com/weather/school-closings/"],
    ["NBC BAY AREA", "SAN FRANCISCO", "CA", 37.77, -122.42, "nbcbayarea.com/weather/school-closings/"],
    ["NBC BAY AREA", "SAN JOSE", "CA", 37.34, -121.89, "nbcbayarea.com/weather/school-closings/"],
    ["NBC LOS ANGELES", "LOS ANGELES", "CA", 34.05, -118.24, "nbclosangeles.com/weather/school-closings/"],
    ["9NEWS", "DENVER", "CO", 39.74, -104.99, "9news.com/closings"],
    ["DENVER7", "DENVER", "CO", 39.74, -104.99, "denver7.com/weather/school-closings-delays"],
    ["FLASHALERT", "COLORADO SPRINGS", "CO", 38.83, -104.82, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=5"],
    ["FOX31", "DENVER", "CO", 39.74, -104.99, "kdvr.com/weather/closings/"],
    ["KKCO", "GRAND JUNCTION", "CO", 39.06, -108.55, "kkco11news.com/weather/closings/"],
    ["KKTV", "COLORADO SPRINGS", "CO", 38.83, -104.82, "kktv.com/weather/closings/"],
    ["KOAA", "PUEBLO", "CO", 38.25, -104.61, "koaa.com/weather/school-closings-delays"],
    ["FOX61", "HARTFORD", "CT", 41.76, -72.67, "fox61.com/closings"],
    ["NBC CONNECTICUT", "HARTFORD", "CT", 41.76, -72.67, "nbcconnecticut.com/weather/school-closings/"],
    ["WTNH", "NEW HAVEN", "CT", 41.31, -72.92, "wtnh.com/weather/closings/"],
    ["DC NEWS NOW", "WASHINGTON", "DC", 38.91, -77.04, "dcnewsnow.com/weather/closings/"],
    ["FOX 5", "WASHINGTON", "DC", 38.91, -77.04, "https://media.foxtv.com/wttg/closings/closings.html"],
    ["FOX 5 DC", "WASHINGTON", "DC", 38.91, -77.04, "fox5dc.com/closings"],
    ["NBC WASHINGTON", "WASHINGTON", "DC", 38.91, -77.04, "nbcwashington.com/weather/school-closings/"],
    ["WJLA", "WASHINGTON", "DC", 38.91, -77.04, "https://wjla.com/resources/ftptransfer/wjla/closings/closings.html"],
    ["WUSA9", "WASHINGTON", "DC", 38.91, -77.04, "wusa9.com/closings"],
    ["DE SCHOOLS", "DOVER", "DE", 39.16, -75.52, "https://schoolclosings.delaware.gov/"],
    ["FIRST COAST NEWS", "JACKSONVILLE", "FL", 30.33, -81.66, "firstcoastnews.com/closings"],
    ["NBC 6", "MIAMI", "FL", 25.76, -80.19, "nbcmiami.com/weather/school-closings/"],
    ["WCJB", "GAINESVILLE", "FL", 29.65, -82.32, "wcjb.com/weather/closings/"],
    ["WCTV", "TALLAHASSEE", "FL", 30.44, -84.28, "wctv.tv/weather/closings/"],
    ["WEAR", "PENSACOLA", "FL", 30.42, -87.22, "https://weartv.com/resources/ftptransfer/wear/closings/closings.html"],
    ["WESH", "ORLANDO", "FL", 28.54, -81.38, "wesh.com/weather/closings"],
    ["WJHG", "PANAMA CITY", "FL", 30.16, -85.66, "wjhg.com/weather/closings/"],
    ["WPBF", "WEST PALM BEACH", "FL", 26.72, -80.05, "wpbf.com/weather/closings"],
    ["WTSP", "TAMPA", "FL", 27.95, -82.46, "wtsp.com/closings"],
    ["11ALIVE", "ATLANTA", "GA", 33.75, -84.39, "11alive.com/closings"],
    ["13WMAZ", "MACON", "GA", 32.84, -83.63, "13wmaz.com/closings"],
    ["FOX 5", "ATLANTA", "GA", 33.75, -84.39, "fox5atlanta.com/closings"],
    ["WALB", "ALBANY", "GA", 31.58, -84.16, "walb.com/weather/closings/"],
    ["WJCL", "SAVANNAH", "GA", 32.08, -81.09, "wjcl.com/weather/closings"],
    ["WRDW", "AUGUSTA", "GA", 33.47, -81.97, "wrdw.com/weather/closings/"],
    ["WSB-TV", "ATLANTA", "GA", 33.75, -84.39, "wsbtv.com/weather/school-closings/"],
    ["WTOC", "SAVANNAH", "GA", 32.08, -81.09, "wtoc.com/weather/closings/"],
    ["WTVM", "COLUMBUS", "GA", 32.46, -84.99, "wtvm.com/weather/closings/"],
    ["HAWAII NEWS NOW", "HONOLULU", "HI", 21.31, -157.86, "hawaiinewsnow.com/weather/closings/"],
    ["KCCI", "DES MOINES", "IA", 41.59, -93.62, "kcci.com/weather/closings"],
    ["KCRG", "CEDAR RAPIDS", "IA", 41.98, -91.67, "kcrg.com/weather/closings/"],
    ["KTIV", "SIOUX CITY", "IA", 42.5, -96.4, "ktiv.com/weather/closings/"],
    ["KWQC", "DAVENPORT", "IA", 41.52, -90.58, "kwqc.com/weather/closings/"],
    ["WE ARE IOWA", "DES MOINES", "IA", 41.59, -93.62, "weareiowa.com/closings"],
    ["WHO 13", "DES MOINES", "IA", 41.59, -93.62, "who13.com/weather/closings/"],
    ["FLASHALERT", "BOISE", "ID", 43.62, -116.2, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=15"],
    ["KIVI", "BOISE", "ID", 43.62, -116.2, "kivitv.com/weather/school-closings-delays"],
    ["KMVT", "TWIN FALLS", "ID", 42.56, -114.46, "kmvt.com/weather/closings/"],
    ["KTVB", "BOISE", "ID", 43.62, -116.2, "ktvb.com/closings"],
    ["ROCKFORD NEWS FIRST", "ROCKFORD", "IL", 42.27, -89.09, "rockfordnewsfirst.com/weather/closings/"],
    ["WCIA", "CHAMPAIGN", "IL", 40.12, -88.24, "wcia.com/weather/closings/"],
    ["WGEM", "QUINCY", "IL", 39.94, -91.41, "wgem.com/weather/closings/"],
    ["WGN", "CHICAGO", "IL", 41.88, -87.63, "https://media.psg.nexstardigital.net/WGNR/closings/closings.xml"],
    ["WMBD", "PEORIA", "IL", 40.69, -89.59, "centralillinoisproud.com/weather/closings/"],
    ["WQAD", "MOLINE", "IL", 41.51, -90.52, "wqad.com/closings"],
    ["21ALIVE", "FORT WAYNE", "IN", 41.08, -85.14, "21alivenews.com/weather/closings/"],
    ["EYEWITNESS NEWS", "EVANSVILLE", "IN", 37.97, -87.57, "tristatehomepage.com/weather/closings/"],
    ["WLFI", "LAFAYETTE", "IN", 40.42, -86.88, "wlfi.com/weather/closings/"],
    ["WNDU", "SOUTH BEND", "IN", 41.68, -86.25, "wndu.com/weather/closings/"],
    ["WSBT", "SOUTH BEND", "IN", 41.68, -86.25, "https://wsbt.com/resources/ftptransfer/wsbt/closings/wsbt-closings.htm"],
    ["WTHI", "TERRE HAUTE", "IN", 39.47, -87.41, "wthitv.com/weather/closings/"],
    ["WTHR", "INDIANAPOLIS", "IN", 39.77, -86.16, "wthr.com/closings"],
    ["WTWO", "TERRE HAUTE", "IN", 39.47, -87.41, "mywabashvalley.com/weather/closings/"],
    ["KOAM", "PITTSBURG", "KS", 37.41, -94.7, "koamnewsnow.com/weather/closings-and-delays/"],
    ["KSN", "WICHITA", "KS", 37.69, -97.34, "ksn.com/weather/closings/"],
    ["KSNT", "TOPEKA", "KS", 39.05, -95.68, "ksnt.com/weather/closings/"],
    ["KWCH", "WICHITA", "KS", 37.69, -97.34, "kwch.com/weather/closings/"],
    ["WIBW", "TOPEKA", "KS", 39.05, -95.68, "wibw.com/weather/closings/"],
    ["WAVE", "LOUISVILLE", "KY", 38.25, -85.76, "wdrbwave.com/weather/closings/"],
    ["WBKO", "BOWLING GREEN", "KY", 36.99, -86.44, "wbko.com/weather/closings/"],
    ["WHAS11", "LOUISVILLE", "KY", 38.25, -85.76, "whas11.com/closings"],
    ["WKYT", "LEXINGTON", "KY", 38.04, -84.5, "wkyt.com/weather/closings/"],
    ["WLKY", "LOUISVILLE", "KY", 38.25, -85.76, "wlky.com/weather/closings"],
    ["WYMT", "HAZARD", "KY", 37.25, -83.19, "wymt.com/weather/closings/"],
    ["FOX 8", "NEW ORLEANS", "LA", 29.95, -90.07, "fox8live.com/weather/closings/"],
    ["KNOE", "MONROE", "LA", 32.51, -92.12, "knoe.com/weather/closings/"],
    ["KPLC", "LAKE CHARLES", "LA", 30.23, -93.22, "kplctv.com/weather/closings/"],
    ["KSLA", "SHREVEPORT", "LA", 32.53, -93.75, "ksla.com/weather/closings/"],
    ["KTAL", "SHREVEPORT", "LA", 32.53, -93.75, "ktalnews.com/weather/closings/"],
    ["WAFB", "BATON ROUGE", "LA", 30.45, -91.19, "wafb.com/weather/closings/"],
    ["WDSU", "NEW ORLEANS", "LA", 29.95, -90.07, "wdsu.com/weather/closings"],
    ["WWL", "NEW ORLEANS", "LA", 29.95, -90.07, "wwltv.com/closings"],
    ["BOSTON 25", "BOSTON", "MA", 42.36, -71.06, "boston25news.com/weather/school-closings/"],
    ["NBC BOSTON", "BOSTON", "MA", 42.36, -71.06, "nbcboston.com/weather/school-closings/"],
    ["WBZ", "BOSTON", "MA", 42.36, -71.06, "cbsnews.com/boston/school-closings/"],
    ["WCVB", "BOSTON", "MA", 42.36, -71.06, "wcvb.com/weather/closings"],
    ["WWLP", "SPRINGFIELD", "MA", 42.1, -72.59, "wwlp.com/weather/closings/"],
    ["FOX45", "BALTIMORE", "MD", 39.29, -76.61, "https://foxbaltimore.com/resources/ftptransfer/wbff/closings/closings.html"],
    ["WBAL", "BALTIMORE", "MD", 39.29, -76.61, "wbaltv.com/weather/closings"],
    ["WJZ", "BALTIMORE", "MD", 39.29, -76.61, "cbsnews.com/baltimore/school-closings/"],
    ["WMAR", "BALTIMORE", "MD", 39.29, -76.61, "wmar2news.com/weather/school-closings-delays"],
    ["NEWS CENTER MAINE", "PORTLAND", "ME", 43.66, -70.26, "newscentermaine.com/closings"],
    ["WABI", "BANGOR", "ME", 44.8, -68.77, "wabi.tv/weather/closings/"],
    ["WGME", "PORTLAND", "ME", 43.66, -70.26, "https://wgme.com/resources/ftptransfer/wgme/closings/close.html"],
    ["WMTW", "PORTLAND", "ME", 43.66, -70.26, "wmtw.com/weather/closings"],
    ["9&10 NEWS", "CADILLAC", "MI", 44.25, -85.4, "9and10news.com/weather/school-closings/"],
    ["CBS DETROIT", "DETROIT", "MI", 42.33, -83.05, "cbsnews.com/detroit/school-closings/"],
    ["FOX 2", "DETROIT", "MI", 42.33, -83.05, "fox2detroit.com/closings"],
    ["FOX 2", "DETROIT", "MI", 42.33, -83.05, "https://media.foxtv.com/wjbk/closings/closings.html"],
    ["NBC25", "FLINT", "MI", 43.01, -83.69, "https://nbc25news.com/resources/ftptransfer/weyi/closings/closings.htm"],
    ["TV6", "MARQUETTE", "MI", 46.55, -87.4, "uppermichiganssource.com/weather/closings/"],
    ["UP NORTH LIVE", "TRAVERSE CITY", "MI", 44.76, -85.62, "https://upnorthlive.com/resources/ftptransfer/wpbn/closings/closings.html"],
    ["WILX", "LANSING", "MI", 42.73, -84.56, "wilx.com/weather/closings/"],
    ["WLNS", "LANSING", "MI", 42.73, -84.56, "wlns.com/weather/closings/"],
    ["WNEM", "SAGINAW", "MI", 43.42, -83.95, "wnem.com/weather/closings/"],
    ["WOOD", "GRAND RAPIDS", "MI", 42.96, -85.67, "woodtv.com/weather/closings/"],
    ["WWMT", "KALAMAZOO", "MI", 42.29, -85.59, "https://wwmt.com/resources/ftptransfer/wwmt/closings/closings.html"],
    ["WXYZ", "DETROIT", "MI", 42.33, -83.05, "wxyz.com/weather/school-closings-delays"],
    ["WZZM", "GRAND RAPIDS", "MI", 42.96, -85.67, "wzzm13.com/closings"],
    ["FOX 9", "MINNEAPOLIS", "MN", 44.98, -93.27, "https://media.foxtv.com/kmsp/closings/closings.html"],
    ["KARE 11", "MINNEAPOLIS", "MN", 44.98, -93.27, "kare11.com/closings"],
    ["KTTC", "ROCHESTER", "MN", 44.02, -92.47, "kttc.com/weather/closings/"],
    ["NORTHERN NEWS NOW", "DULUTH", "MN", 46.79, -92.1, "northernnewsnow.com/weather/closings/"],
    ["WCCO", "MINNEAPOLIS", "MN", 44.98, -93.27, "cbsnews.com/minnesota/school-closings/"],
    ["ABC 17", "COLUMBIA", "MO", 38.95, -92.33, "https://npgdigital.com/kmiz/closings.html"],
    ["FIRST ALERT 4", "ST. LOUIS", "MO", 38.63, -90.2, "firstalert4.com/weather/closings/"],
    ["FOX 2", "ST. LOUIS", "MO", 38.63, -90.2, "fox2now.com/weather/closings/"],
    ["KCTV", "KANSAS CITY", "MO", 39.1, -94.58, "kctv5.com/weather/closings/"],
    ["KFVS", "CAPE GIRARDEAU", "MO", 37.31, -89.52, "kfvs12.com/weather/closings/"],
    ["KMBC", "KANSAS CITY", "MO", 39.1, -94.58, "kmbc.com/weather/closings"],
    ["KRCG", "JEFFERSON CITY", "MO", 38.58, -92.17, "https://krcgtv.com/resources/ftptransfer/krcg/closings/WebClose.htm"],
    ["KSDK", "ST. LOUIS", "MO", 38.63, -90.2, "ksdk.com/closings"],
    ["KSHB", "KANSAS CITY", "MO", 39.1, -94.58, "kshb.com/weather/school-closings-delays"],
    ["KSN/KODE", "JOPLIN", "MO", 37.08, -94.51, "fourstateshomepage.com/weather/closings/"],
    ["KY3", "SPRINGFIELD", "MO", 37.21, -93.29, "ky3.com/weather/closings/"],
    ["WAPT", "JACKSON", "MS", 32.3, -90.18, "wapt.com/weather/closings"],
    ["WDAM", "HATTIESBURG", "MS", 31.33, -89.29, "wdam.com/weather/closings/"],
    ["WJTV", "JACKSON", "MS", 32.3, -90.18, "wjtv.com/weather/closings/"],
    ["WLOX", "BILOXI", "MS", 30.4, -88.89, "wlox.com/weather/closings/"],
    ["WTOK", "MERIDIAN", "MS", 32.36, -88.7, "wtok.com/weather/closings/"],
    ["KPAX", "MISSOULA", "MT", 46.87, -113.99, "kpax.com/school-closings-delays"],
    ["FOX 8", "GREENSBORO", "NC", 36.07, -79.79, "myfox8.com/weather/closings/"],
    ["QUEEN CITY NEWS", "CHARLOTTE", "NC", 35.23, -80.84, "https://media.psg.nexstardigital.net/WJZY/closings/closings.xml"],
    ["WBTV", "CHARLOTTE", "NC", 35.23, -80.84, "wbtv.com/weather/closings/"],
    ["WCNC", "CHARLOTTE", "NC", 35.23, -80.84, "wcnc.com/closings"],
    ["WCTI", "NEW BERN", "NC", 35.11, -77.04, "https://wcti12.com/resources/ftptransfer/wcti/closings/closings.html"],
    ["WECT", "WILMINGTON", "NC", 34.23, -77.94, "wect.com/weather/closings/"],
    ["WFMY", "GREENSBORO", "NC", 36.07, -79.79, "wfmynews2.com/closings"],
    ["WITN", "GREENVILLE", "NC", 35.61, -77.37, "witn.com/weather/closings/"],
    ["WLOS", "ASHEVILLE", "NC", 35.6, -82.55, "https://wlos.com/resources/ftptransfer/wlos/closings/schoolclosing.html"],
    ["WSOC", "CHARLOTTE", "NC", 35.23, -80.84, "wsoctv.com/weather/school-closings/"],
    ["WXII", "WINSTON-SALEM", "NC", 36.1, -80.24, "wxii12.com/weather/closings"],
    ["KFYR", "BISMARCK", "ND", 46.81, -100.78, "kfyrtv.com/weather/closings/"],
    ["KX NEWS", "BISMARCK", "ND", 46.81, -100.78, "kxnet.com/weather/closings/"],
    ["VALLEY NEWS LIVE", "FARGO", "ND", 46.88, -96.79, "valleynewslive.com/weather/closings/"],
    ["10/11", "LINCOLN", "NE", 40.81, -96.68, "1011now.com/weather/closings/"],
    ["3 NEWS NOW", "OMAHA", "NE", 41.26, -95.93, "3newsnow.com/weather/school-closings-delays"],
    ["KETV", "OMAHA", "NE", 41.26, -95.93, "ketv.com/weather/closings"],
    ["WOWT", "OMAHA", "NE", 41.26, -95.93, "wowt.com/weather/closings/"],
    ["WYOMING NEWS NOW", "SCOTTSBLUFF", "NE", 41.87, -103.66, "https://www.wyomingnewsnow.tv/search/?f=json&t=article&c=weather/closings&l=1&s=start_time&sd=desc"],
    ["WMUR", "MANCHESTER", "NH", 42.99, -71.46, "wmur.com/weather/closings"],
    ["KOAT", "ALBUQUERQUE", "NM", 35.08, -106.65, "koat.com/weather/closings"],
    ["KRQE", "ALBUQUERQUE", "NM", 35.08, -106.65, "krqe.com/weather/closings/"],
    ["FOX5", "LAS VEGAS", "NV", 36.17, -115.14, "fox5vegas.com/weather/closings/"],
    ["KOLO", "RENO", "NV", 39.53, -119.81, "kolotv.com/weather/closings/"],
    ["13WHAM", "ROCHESTER", "NY", 43.16, -77.61, "https://13wham.com/resources/ftptransfer/wham/closings/closings.html"],
    ["CNY CENTRAL", "SYRACUSE", "NY", 43.05, -76.15, "https://cnycentral.com/resources/ftptransfer/wstm/closings/closings.htm"],
    ["FOX 5", "NEW YORK", "NY", 40.71, -74.01, "https://media.foxtv.com/wnyw/closings/closings.html"],
    ["FOX 5 NY", "NEW YORK", "NY", 40.71, -74.01, "fox5ny.com/closings"],
    ["NBC NEW YORK", "NEW YORK", "NY", 40.71, -74.01, "nbcnewyork.com/weather/school-closings/"],
    ["NBC5", "PLATTSBURGH", "NY", 44.7, -73.45, "mynbc5.com/weather/closings"],
    ["NEWS10", "ALBANY", "NY", 42.65, -73.75, "news10.com/closings-and-delays/"],
    ["NEWSCHANNEL 9", "SYRACUSE", "NY", 43.05, -76.15, "localsyr.com/weather/closings/"],
    ["ROCHESTER FIRST", "ROCHESTER", "NY", 43.16, -77.61, "rochesterfirst.com/weather/closings/"],
    ["WBNG", "BINGHAMTON", "NY", 42.1, -75.91, "wbng.com/weather/closings/"],
    ["WETM", "ELMIRA", "NY", 42.09, -76.81, "mytwintiers.com/weather/closings/"],
    ["WGRZ", "BUFFALO", "NY", 42.89, -78.88, "wgrz.com/closings"],
    ["WIVB", "BUFFALO", "NY", 42.89, -78.88, "wivb.com/weather/closings/"],
    ["WKBW", "BUFFALO", "NY", 42.89, -78.88, "wkbw.com/weather/school-closings-delays"],
    ["10TV", "COLUMBUS", "OH", 39.96, -83.0, "10tv.com/closings"],
    ["13 ABC", "TOLEDO", "OH", 41.65, -83.54, "13abc.com/weather/closings/"],
    ["ABC6", "COLUMBUS", "OH", 39.96, -83.0, "https://abc6onyourside.com/resources/ftptransfer/wsyx/closings/closings.html"],
    ["FOX 8", "CLEVELAND", "OH", 41.5, -81.69, "fox8.com/weather/closings/"],
    ["FOX28", "COLUMBUS", "OH", 39.96, -83.0, "https://fox28media.com/resources/ftptransfer/wtte/closings/closings.html"],
    ["LOCAL 12", "CINCINNATI", "OH", 39.1, -84.51, "https://local12.com/resources/ftptransfer/wkrc/closings/closings.html"],
    ["NBC24", "TOLEDO", "OH", 41.65, -83.54, "https://nbc24.com/resources/ftptransfer/wnwo/closings/closings.html"],
    ["NBC4", "COLUMBUS", "OH", 39.96, -83.0, "nbc4i.com/weather/closings/"],
    ["NEWS 5", "CLEVELAND", "OH", 41.5, -81.69, "news5cleveland.com/weather/school-closings-delays"],
    ["WCPO", "CINCINNATI", "OH", 39.1, -84.51, "wcpo.com/weather/school-closings-delays"],
    ["WDTN", "DAYTON", "OH", 39.76, -84.19, "wdtn.com/weather/closings/"],
    ["WHIO", "DAYTON", "OH", 39.76, -84.19, "whio.com/weather/school-closings/"],
    ["WKBN", "YOUNGSTOWN", "OH", 41.1, -80.65, "wkbn.com/weather/closings/"],
    ["WKYC", "CLEVELAND", "OH", 41.5, -81.69, "wkyc.com/closings"],
    ["WLWT", "CINCINNATI", "OH", 39.1, -84.51, "wlwt.com/weather/closings"],
    ["WTOL", "TOLEDO", "OH", 41.65, -83.54, "wtol.com/closings"],
    ["WTOV", "STEUBENVILLE", "OH", 40.36, -80.61, "https://wtov9.com/resources/ftptransfer/wtov/closings/closings.html"],
    ["2NEWS", "TULSA", "OK", 36.15, -95.99, "kjrh.com/weather/school-closings-delays"],
    ["KFOR", "OKLAHOMA CITY", "OK", 35.47, -97.52, "kfor.com/weather/closings/"],
    ["KOCO", "OKLAHOMA CITY", "OK", 35.47, -97.52, "koco.com/weather/closings"],
    ["KTUL", "TULSA", "OK", 36.15, -95.99, "https://ktul.com/resources/ftptransfer/ktul/closings/closings.html"],
    ["OKC FOX", "OKLAHOMA CITY", "OK", 35.47, -97.52, "https://okcfox.com/resources/ftptransfer/kokh/closings/closings.htm"],
    ["FLASHALERT", "BEND", "OR", 44.06, -121.31, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=10"],
    ["FLASHALERT", "EUGENE", "OR", 44.05, -123.09, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=2"],
    ["FLASHALERT", "MEDFORD", "OR", 42.33, -122.87, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=25"],
    ["FLASHALERT", "PORTLAND", "OR", 45.52, -122.68, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=1"],
    ["KOIN", "PORTLAND", "OR", 45.52, -122.68, "koin.com/weather/closings/"],
    ["KPTV", "PORTLAND", "OR", 45.52, -122.68, "kptv.com/weather/closings/"],
    ["CBS PHILADELPHIA", "PHILADELPHIA", "PA", 39.95, -75.17, "cbsnews.com/philadelphia/school-closings/"],
    ["FOX 29", "PHILADELPHIA", "PA", 39.95, -75.17, "fox29.com/closings"],
    ["FOX 29", "PHILADELPHIA", "PA", 39.95, -75.17, "https://media.foxtv.com/wtxf/closings/closings.html"],
    ["FOX43", "HARRISBURG", "PA", 40.27, -76.88, "fox43.com/closings"],
    ["KDKA", "PITTSBURGH", "PA", 40.44, -80.0, "cbsnews.com/pittsburgh/school-closings/"],
    ["NBC10", "PHILADELPHIA", "PA", 39.95, -75.17, "nbcphiladelphia.com/weather/school-closings/"],
    ["WGAL", "LANCASTER", "PA", 40.04, -76.31, "wgal.com/weather/closings"],
    ["WJAC", "JOHNSTOWN", "PA", 40.33, -78.92, "https://wjactv.com/resources/ftptransfer/wjac/closings/closings.html"],
    ["WNEP", "SCRANTON", "PA", 41.41, -75.66, "wnep.com/closings"],
    ["WPXI", "PITTSBURGH", "PA", 40.44, -80.0, "wpxi.com/weather/school-closings/"],
    ["WTAE", "PITTSBURGH", "PA", 40.44, -80.0, "wtae.com/weather/closings"],
    ["WTAJ", "ALTOONA", "PA", 40.52, -78.39, "wtaj.com/weather/closings/"],
    ["YOUR ERIE", "ERIE", "PA", 42.13, -80.09, "yourerie.com/weather/closings/"],
    ["RI CLOSINGS", "PROVIDENCE", "RI", 41.82, -71.41, "ribroadcasters.com/news_and_events/closings_delays/"],
    ["WPRI", "PROVIDENCE", "RI", 41.82, -71.41, "wpri.com/weather/closings/"],
    ["COUNT ON 2", "CHARLESTON", "SC", 32.78, -79.93, "https://media.psg.nexstardigital.net/WCBD/closings/closings.xml"],
    ["LIVE 5", "CHARLESTON", "SC", 32.78, -79.93, "live5news.com/weather/closings/"],
    ["WACH", "COLUMBIA", "SC", 34.0, -81.03, "https://wach.com/resources/ftptransfer/wach/closings/closings.html"],
    ["WIS", "COLUMBIA", "SC", 34.0, -81.03, "wistv.com/weather/closings/"],
    ["WLTX", "COLUMBIA", "SC", 34.0, -81.03, "wltx.com/closings"],
    ["WSPA", "GREENVILLE", "SC", 34.85, -82.4, "wspa.com/weather/closings/"],
    ["WYFF", "GREENVILLE", "SC", 34.85, -82.4, "wyff4.com/weather/closings"],
    ["DAKOTA NEWS NOW", "SIOUX FALLS", "SD", 43.55, -96.73, "dakotanewsnow.com/weather/closings/"],
    ["KOTA", "RAPID CITY", "SD", 44.08, -103.23, "kotatv.com/weather/closings/"],
    ["ACTION NEWS 5", "MEMPHIS", "TN", 35.15, -90.05, "actionnews5.com/weather/closings/"],
    ["LOCAL 24", "MEMPHIS", "TN", 35.15, -90.05, "localmemphis.com/closings"],
    ["NEWSCHANNEL 5", "NASHVILLE", "TN", 36.16, -86.78, "newschannel5.com/weather/school-closings-delays"],
    ["WATE", "KNOXVILLE", "TN", 35.96, -83.92, "wate.com/weather/closings/"],
    ["WBIR", "KNOXVILLE", "TN", 35.96, -83.92, "wbir.com/closings"],
    ["WJHL", "JOHNSON CITY", "TN", 36.31, -82.35, "wjhl.com/weather/closings/"],
    ["WKRN", "NASHVILLE", "TN", 36.16, -86.78, "wkrn.com/weather/closings/"],
    ["WREG", "MEMPHIS", "TN", 35.15, -90.05, "wreg.com/weather/closings/"],
    ["WSMV", "NASHVILLE", "TN", 36.16, -86.78, "wsmv.com/weather/closings/"],
    ["WVLT", "KNOXVILLE", "TN", 35.96, -83.92, "wvlt.tv/weather/closings/"],
    ["ABC 7", "AMARILLO", "TX", 35.22, -101.83, "https://abc7amarillo.com/resources/ftptransfer/kvii/closings/closings.html"],
    ["CBS TEXAS", "DALLAS", "TX", 32.78, -96.8, "cbsnews.com/texas/school-closings/"],
    ["CBS19", "TYLER", "TX", 32.35, -95.3, "cbs19.tv/closings"],
    ["FOX 4", "DALLAS", "TX", 32.78, -96.8, "fox4news.com/closings"],
    ["FOX 4", "DALLAS", "TX", 32.78, -96.8, "https://media.foxtv.com/kdfw/closings/closings.html"],
    ["KAMR", "AMARILLO", "TX", 35.22, -101.83, "myhighplains.com/weather/closings/"],
    ["KAUZ", "WICHITA FALLS", "TX", 33.91, -98.49, "newschannel6now.com/weather/closings/"],
    ["KBTX", "BRYAN", "TX", 30.67, -96.37, "kbtx.com/weather/closings/"],
    ["KCBD", "LUBBOCK", "TX", 33.58, -101.86, "kcbd.com/weather/closings/"],
    ["KCEN", "WACO", "TX", 31.55, -97.15, "kcentv.com/closings"],
    ["KENS 5", "SAN ANTONIO", "TX", 29.42, -98.49, "kens5.com/closings"],
    ["KFDA", "AMARILLO", "TX", 35.22, -101.83, "newschannel10.com/weather/closings/"],
    ["KHOU", "HOUSTON", "TX", 29.76, -95.37, "khou.com/closings"],
    ["KIII", "CORPUS CHRISTI", "TX", 27.8, -97.4, "kiiitv.com/closings"],
    ["KLST", "SAN ANGELO", "TX", 31.46, -100.44, "conchovalleyhomepage.com/weather/closings/"],
    ["KLTV", "TYLER", "TX", 32.35, -95.3, "kltv.com/weather/closings/"],
    ["KTAB", "ABILENE", "TX", 32.45, -99.73, "bigcountryhomepage.com/weather/closings/"],
    ["KTXS", "ABILENE", "TX", 32.45, -99.73, "https://ktxs.com/resources/ftptransfer/ktxs/closings/closings.html"],
    ["KVUE", "AUSTIN", "TX", 30.27, -97.74, "kvue.com/closings"],
    ["KWTX", "WACO", "TX", 31.55, -97.15, "kwtx.com/weather/closings/"],
    ["KXII", "SHERMAN", "TX", 33.64, -96.61, "kxii.com/weather/closings/"],
    ["KXXV", "WACO", "TX", 31.55, -97.15, "kxxv.com/weather/school-closings-delays"],
    ["KZTV", "CORPUS CHRISTI", "TX", 27.8, -97.4, "kztv10.com/weather/school-closings-delays"],
    ["NBC DFW", "DALLAS", "TX", 32.78, -96.8, "nbcdfw.com/weather/school-closings/"],
    ["WFAA", "DALLAS", "TX", 32.78, -96.8, "wfaa.com/closings"],
    ["ABC4", "SALT LAKE CITY", "UT", 40.76, -111.89, "abc4.com/weather/closings/"],
    ["13NEWSNOW", "NORFOLK", "VA", 36.85, -76.29, "13newsnow.com/closings"],
    ["29NEWS", "CHARLOTTESVILLE", "VA", 38.03, -78.48, "29news.com/weather/closings/"],
    ["WAVY", "NORFOLK", "VA", 36.85, -76.29, "wavy.com/weather/closings/"],
    ["WCYB", "BRISTOL", "VA", 36.6, -82.19, "https://wcyb.com/resources/ftptransfer/wcyb/closings/Schools.html"],
    ["WDBJ", "ROANOKE", "VA", 37.27, -79.94, "wdbj7.com/weather/closings/"],
    ["WFXR", "ROANOKE", "VA", 37.27, -79.94, "wfxrtv.com/weather/closings/"],
    ["WHSV", "HARRISONBURG", "VA", 38.45, -78.87, "whsv.com/weather/closings/"],
    ["WSET", "LYNCHBURG", "VA", 37.41, -79.14, "https://wset.com/resources/ftptransfer/wset/closings/closings.html"],
    ["WCAX", "BURLINGTON", "VT", 44.48, -73.21, "wcax.com/weather/closings/"],
    ["FLASHALERT", "KENNEWICK", "WA", 46.21, -119.14, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=13"],
    ["FLASHALERT", "SEATTLE", "WA", 47.61, -122.33, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=12"],
    ["FLASHALERT", "SPOKANE", "WA", 47.66, -117.43, "https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=7"],
    ["FOX 13", "SEATTLE", "WA", 47.61, -122.33, "https://media.foxtv.com/kcpq/closings/closings.html"],
    ["KING 5", "SEATTLE", "WA", 47.61, -122.33, "king5.com/closings"],
    ["KIRO 7", "SEATTLE", "WA", 47.61, -122.33, "kiro7.com/weather/school-closings/"],
    ["KOMO", "SEATTLE", "WA", 47.61, -122.33, "https://komonews.com/resources/ftptransfer/komo/closings/komoclosings.html"],
    ["KREM", "SPOKANE", "WA", 47.66, -117.43, "krem.com/closings"],
    ["FOX6", "MILWAUKEE", "WI", 43.04, -87.91, "https://media.foxtv.com/witi/closings/closings.html"],
    ["NBC15", "MADISON", "WI", 43.07, -89.4, "wmtv15news.com/weather/closings/"],
    ["NBC26", "GREEN BAY", "WI", 44.52, -88.02, "nbc26.com/weather/school-closings-delays"],
    ["TMJ4", "MILWAUKEE", "WI", 43.04, -87.91, "tmj4.com/weather/school-closings-delays"],
    ["WBAY", "GREEN BAY", "WI", 44.52, -88.02, "wbay.com/weather/closings/"],
    ["WEAU", "EAU CLAIRE", "WI", 44.81, -91.5, "weau.com/weather/closings/"],
    ["WFRV", "GREEN BAY", "WI", 44.52, -88.02, "wearegreenbay.com/weather/closings/"],
    ["WISN", "MILWAUKEE", "WI", 43.04, -87.91, "wisn.com/weather/closings"],
    ["WSAW", "WAUSAU", "WI", 44.96, -89.63, "wsaw.com/weather/closings/"],
    ["WBOY", "CLARKSBURG", "WV", 39.28, -80.34, "wboy.com/weather/closings/"],
    ["WCHS", "CHARLESTON", "WV", 38.35, -81.63, "https://wchstv.com/resources/ftptransfer/wchs/closings/closings.html"],
    ["WDTV", "BRIDGEPORT", "WV", 39.29, -80.26, "wdtv.com/weather/closings/"],
    ["WOWK", "HUNTINGTON", "WV", 38.42, -82.45, "wowktv.com/weather/closings/"],
    ["WSAZ", "HUNTINGTON", "WV", 38.42, -82.45, "wsaz.com/weather/closings/"],
    ["WTAP", "PARKERSBURG", "WV", 39.27, -81.56, "wtap.com/weather/closings/"],
    ["WTRF", "WHEELING", "WV", 40.06, -80.72, "wtrf.com/weather/closings/"],
    ["WVVA", "BLUEFIELD", "WV", 37.27, -81.22, "wvva.com/weather/closings/"],
    ["WYOMING NEWS NOW", "CASPER", "WY", 42.87, -106.31, "https://www.wyomingnewsnow.tv/search/?f=json&t=article&c=weather/closings&l=1&s=start_time&sd=desc"],
    ["WYOMING NEWS NOW", "CHEYENNE", "WY", 41.14, -104.82, "https://www.wyomingnewsnow.tv/search/?f=json&t=article&c=weather/closings&l=1&s=start_time&sd=desc"],
]


def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()


def collapse_ws(s):
    t = str(s).replace("\n", " ").replace("\r", " ").replace("\t", " ")
    for _ in range(40):
        if t.find("  ") < 0:
            break
        t = t.replace("  ", " ")
    return t.strip()


def digits_only(s):
    out = ""
    t = str(s)
    for i in range(len(t)):
        if t[i].isdigit():
            out = out + t[i]
    return out


def zip_label(raw):
    d = digits_only(raw)
    if len(d) >= 5:
        return d[:5]
    return d


ENTITY_NAMES = {
    "&amp;": "&", "&apos;": "'", "&quot;": "\"", "&lt;": "<", "&gt;": ">", "&nbsp;": " ",
    "&rsquo;": "'", "&lsquo;": "'", "&ldquo;": "\"", "&rdquo;": "\"", "&ndash;": "-",
    "&mdash;": "-", "&hellip;": "...", "&eacute;": "E",
}
ENTITY_CODES = {8216: "'", 8217: "'", 8220: "\"", 8221: "\"", 8211: "-", 8212: "-", 8230: "...", 160: " ", 233: "E", 201: "E"}


def decode_numeric(t):
    # "&#8217;" / "&#x27;" -> plain ASCII; unknown codes are dropped.
    out = ""
    rest = t
    for _ in range(200):
        p = rest.find("&#")
        if p < 0:
            break
        semi = rest.find(";", p)
        if semi < 0 or semi - p > 9:
            out = out + rest[:p + 2]
            rest = rest[p + 2:]
            continue
        code = rest[p + 2:semi]
        n = -1
        if code[:1] == "x" or code[:1] == "X":
            hexd = code[1:].lower()
            v = 0
            ok = hexd != ""
            for ch in hexd.elems():
                d = "0123456789abcdef".find(ch)
                if d < 0:
                    ok = False
                    break
                v = v * 16 + d
            if ok:
                n = v
        elif code.isdigit():
            n = int(code)
        out = out + rest[:p]
        if n >= 32 and n < 127:
            out = out + chr(n)
        elif n in ENTITY_CODES:
            out = out + ENTITY_CODES[n]
        rest = rest[semi + 1:]
    return out + rest


def decode(s):
    out = str(s)
    out = out.replace("<![CDATA[", "").replace("]]>", "")
    for k in ENTITY_NAMES:
        out = out.replace(k, ENTITY_NAMES[k])
    out = decode_numeric(out)
    # Curly quotes and dashes typed straight into the feed.
    out = out.replace("’", "'").replace("‘", "'").replace("“", "\"").replace("”", "\"")
    out = out.replace("–", "-").replace("—", "-")
    return collapse_ws(out)


def strip_tags(s):
    out = ""
    i = 0
    n = len(s)
    for _ in range(n + 1):
        if i >= n:
            break
        lt = s.find("<", i)
        if lt < 0:
            out = out + s[i:]
            break
        out = out + s[i:lt]
        gt = s.find(">", lt)
        if gt < 0:
            break
        i = gt + 1
    return out


def xml_text(body, tag):
    close = "</" + tag + ">"
    open1 = "<" + tag + ">"
    start = body.find(open1)
    if start >= 0:
        start = start + len(open1)
    else:
        open2 = "<" + tag + " "
        p = body.find(open2)
        if p < 0:
            return ""
        gt = body.find(">", p)
        if gt < 0:
            return ""
        start = gt + 1
    end = body.find(close, start)
    if end < 0:
        return ""
    return decode(strip_tags(body[start:end]))


def origin_of(url):
    u = collapse_ws(url)
    if u == "":
        return ""
    scheme = "https"
    rest = u
    if u.find("://") >= 0:
        if u.lower().find("http://") == 0:
            scheme = "http"
        rest = u[u.find("://") + 3:]
    slash = rest.find("/")
    host = (rest if slash < 0 else rest[:slash]).lower()
    if host.find("?") >= 0:
        host = host[:host.find("?")]
    if host.find("#") >= 0:
        host = host[:host.find("#")]
    if host == "" or host.find(".") < 0:
        return ""
    return scheme + "://" + host


def clean_url(url):
    # "  HTTPS://WWW.Station.com/weather/closings/#top " ->
    # "https://www.station.com/weather/closings/" (the path keeps its case).
    u = collapse_ws(url)
    if u.find("#") >= 0:
        u = u[:u.find("#")]
    if u.find("://") < 0:
        if u.find(".") < 0:
            return ""
        u = "https://" + u
    scheme = u[:u.find("://")].lower()
    if scheme != "http" and scheme != "https":
        return ""
    rest = u[u.find("://") + 3:]
    slash = rest.find("/")
    host = rest if slash < 0 else rest[:slash]
    path = "" if slash < 0 else rest[slash:]
    if host.find(".") < 0:
        return ""
    return "https://" + host.lower() + path


def with_www(url):
    # https://station.com/x -> https://www.station.com/x ("" if it has www).
    o = origin_of(url)
    if o == "" or o.find("://www.") >= 0:
        return ""
    return "https://www." + url[url.find("://") + 3:]


def host_label(url):
    origin = origin_of(url)
    if origin == "":
        return ""
    host = origin
    if host.find("://") >= 0:
        host = host[host.find("://") + 3:]
    if host.find("www.") == 0:
        host = host[4:]
    return host.upper()


def looks_like_gsync(html):
    h = str(html)
    if h.find("gsync-closings") >= 0:
        return True
    if h.find("GSync/ClosingsDetailed") >= 0:
        return True
    if h.find("gsync-closings-detailed") >= 0:
        return True
    return False


def looks_like_newsticker(html):
    h = str(html)
    if h.find("newsticker/closings") >= 0:
        return True
    if h.find("<NUM_CLOSINGS>") >= 0:
        return True
    if h.find("<RECORD>") >= 0 and h.find("ORGANIZATION_NAME") >= 0:
        return True
    return False


def newsticker_xml_from_html(html):
    h = str(html)
    key = "newsticker_url\":\""
    p = h.find(key)
    if p < 0:
        key = "newsticker_url\":\"'"
        p = h.find("webpubcontent.gray.tv/")
        if p < 0:
            return ""
        rest = h[p:]
        end = rest.find("\"")
        if end < 0:
            end = rest.find("'")
        if end < 0:
            return ""
        url = "https://" + rest[:end]
        url = url.replace(".html", ".xml")
        return url
    rest = h[p + len(key):]
    end = rest.find("\"")
    if end < 0:
        return ""
    url = rest[:end].replace("\\/", "/")
    if url.find(".html") >= 0:
        url = url.replace(".html", ".xml")
    return url


def last_slug(url):
    u = collapse_ws(url)
    q = u.find("?")
    if q >= 0:
        u = u[:q]
    for _ in range(8):
        if u == "" or u[len(u) - 1] != "/":
            break
        u = u[:len(u) - 1]
    slash = -1
    for i in range(len(u)):
        if u[i] == "/":
            slash = i
    if slash < 0:
        return ""
    return u[slash + 1:]


def looks_like_closings_url(url):
    u = str(url).upper()
    return u.find("CLOSING") >= 0


def looks_like_townnews(html):
    h = str(html)
    if h.find("/app/closings/") >= 0:
        return True
    if h.find("getElementsByTagName(\"Closing\")") >= 0:
        return True
    if h.find("getElementsByTagName('Closing')") >= 0:
        return True
    if h.find("townnews") >= 0 and h.find("closings") >= 0:
        return True
    if h.find("bloximages") >= 0 and h.find("closings") >= 0:
        return True
    return False


def looks_like_townnews_url(url):
    u = str(url).lower()
    if u.find("closings-and-delays") >= 0:
        return True
    if u.find("/app/closings/") >= 0:
        return True
    return False


def townnews_callsign(url):
    host = host_label(url)
    dot = host.find(".")
    if dot >= 0:
        host = host[:dot]
    news = host.find("NEWS")
    if news >= 3 and news <= 5:
        return host[:news]
    n = len(host)
    if n >= 3 and n <= 5:
        return host
    if n >= 4:
        return host[:4]
    return ""


def townnews_guess_urls(origin, page_url):
    urls = []
    sign = townnews_callsign(page_url)
    if sign != "":
        urls.append(origin + "/app/closings/" + sign + "-closingsC.xml")
        urls.append(origin + "/app/closings/" + sign + "-closings.xml")
    return urls


def with_trailing_slash(url):
    u = collapse_ws(url)
    q = u.find("?")
    if q >= 0:
        path = u[:q]
        qs = u[q:]
    else:
        path = u
        qs = ""
    if path == "" or path[len(path) - 1] == "/":
        return u
    if path.find(".xml") >= 0 or path.find(".json") >= 0:
        return u
    return path + "/" + qs


def looks_like_nexstar(html):
    h = str(html)
    if h.find("nexstardigital.net") >= 0:
        return True
    if h.find("closings-page") >= 0 or h.find("closingsPage") >= 0:
        return True
    if h.find("No closings to report") >= 0:
        return True
    if h.find("wp-json/lakana") >= 0:
        return True
    if h.find("wp-json/nexstar") >= 0:
        return True
    if h.find("data-component=\"closingsPage\"") >= 0:
        return True
    return False


def looks_like_nbc(html):
    h = str(html)
    if h.find("article-content--wrap closings") >= 0:
        return True
    if h.find("closings--inactive") >= 0 or h.find("closings--active") >= 0:
        return True
    if h.find("schoolClosingTabs") >= 0:
        return True
    if h.find("nbc-school-closings") >= 0:
        return True
    if h.find("school-closings-alert") >= 0:
        return True
    if h.find("closings__listings") >= 0:
        return True
    return False


def looks_like_scripps(html):
    h = str(html)
    if h.find("module--closings") >= 0:
        return True
    if h.find("There are currently no active closings or delays") >= 0:
        return True
    return False


def looks_like_flashalert(html):
    h = str(html)
    if h.find("cwcReportContainer") >= 0:
        return True
    if h.find("flashalertnewswire.net") >= 0:
        return True
    if h.find("No information reported") >= 0 and h.find("cwcReport") >= 0:
        return True
    return False


def is_boilerplate(text):
    u = collapse_ws(str(text)).upper()
    if u.find("NO CLOSINGS TO REPORT") >= 0:
        return True
    if u.find("MOST RECENT CLOSINGS") >= 0:
        return True
    if u.find("ACTIVE CLOSURES") >= 0:
        return True
    if u.find("JUMP TO") >= 0:
        return True
    if u == "CLOSINGS & DELAYS" or u == "CLOSINGS AND DELAYS":
        return True
    if u.find("SCHOOL'S OPEN") >= 0 or u.find("SCHOOLS OPEN") >= 0:
        return True
    if u.find("FORECAST: SCHOOL") >= 0:
        return True
    if u.find("NO ACTIVE CLOSINGS") >= 0:
        return True
    if u.find("NO INFORMATION REPORTED") >= 0:
        return True
    if u.find("NO DELAYS OR CLOSINGS") >= 0:
        return True
    if u.find("NO CLOSINGS OR DELAYS") >= 0:
        return True
    if u.find("THERE ARE NO ACTIVE RECORDS") >= 0:
        return True
    if u.find("NO CLOSINGS REPORTED") >= 0:
        return True
    if u.find("THERE ARE CURRENTLY NO CLOSINGS") >= 0:
        return True
    if u.find("NO RESULTS FOUND") >= 0:
        return True
    if u.find("NO ACTIVE RECORDS AT THIS TIME") >= 0:
        return True
    return False


def split_name_status(text):
    # "Ulysses - USD 214: Delayed 2 hours" -> name before the last ": ",
    # else before the first dash.
    t = collapse_ws(text)
    p = t.rfind(": ")
    if p > 0:
        return t[:p], t[p + 2:]
    if t.endswith(":"):
        return t[:len(t) - 1], ""
    for sep in [" - ", " – ", " — "]:
        p = t.find(sep)
        if p > 0:
            return t[:p], t[p + len(sep):]
    return t, ""


def html_attr(tag, name):
    keys = [name + "=\"", name + "='"]
    for key in keys:
        p = tag.find(key)
        if p < 0:
            continue
        rest = tag[p + len(key):]
        quote = "\""
        if key[len(key) - 1] == "'":
            quote = "'"
        end = rest.find(quote)
        if end < 0:
            continue
        return rest[:end].replace("\\/", "/").replace("&amp;", "&")
    return ""


def nexstar_iframe_src(html):
    h = str(html)
    p = 0
    for _ in range(25):
        i = h.find("<iframe", p)
        if i < 0:
            i = h.find("<IFRAME", p)
        if i < 0:
            break
        gt = h.find(">", i)
        if gt < 0:
            break
        src = html_attr(h[i:gt], "src")
        p = gt + 1
        if src.find("nexstardigital.net") >= 0:
            return src
    k = h.find("https://media.psg.nexstardigital.net/")
    if k < 0:
        k = h.find("http://media.psg.nexstardigital.net/")
    if k < 0:
        return ""
    rest = h[k:]
    end = len(rest)
    for ch in ["\"", "'", " ", "<", ">"]:
        e = rest.find(ch)
        if e >= 0 and e < end:
            end = e
    return rest[:end]


def abs_url(src, page_url):
    s = collapse_ws(src)
    if s == "":
        return ""
    if s.find("://") >= 0:
        return s
    origin = origin_of(page_url)
    if s.find("/") == 0:
        return origin + s
    return origin + "/" + s


def townnews_xml_urls(html, origin):
    urls = []
    generic = origin + "/app/closings/closings.xml"
    rest = str(html)
    needle = "/app/closings/"
    for _ in range(16):
        p = rest.find(needle)
        if p < 0:
            break
        chunk = rest[p:]
        rest = rest[p + len(needle):]
        end = chunk.find(".xml")
        if end < 0:
            continue
        path = chunk[:end + 4]
        bad = False
        for ch in [" ", "\"", "'", "<", ">", "\n", "\r"]:
            if path.find(ch) >= 0:
                bad = True
        if bad:
            continue
        url = origin + path
        exists = False
        for prev in urls:
            if prev == url:
                exists = True
        if exists == False:
            urls.append(url)
    ordered = []
    for url in urls:
        if url != generic:
            ordered.append(url)
    for url in urls:
        if url == generic:
            ordered.append(url)
    return ordered


def extract_class_text(html, classname, paired = False):
    # paired=True keeps every entry (no de-duplication, no boilerplate
    # skipping) so two lists read with it stay aligned row for row.
    out = []
    needles = [
        "class=\"" + classname + "\"",
        "class=\"" + classname + " ",
        "class='" + classname + "'",
        "class='" + classname + " ",
        "CLASS=\"" + classname + "\"",
        "CLASS=\"" + classname + " ",
        "CLASS='" + classname + "'",
        "CLASS='" + classname + " ",
    ]
    h = str(html)
    for needle in needles:
        rest = h
        for _ in range(SCAN + 1):
            if len(out) >= SCAN:
                return out
            p = rest.find(needle)
            if p < 0:
                break
            gt = rest.find(">", p)
            if gt < 0:
                break
            inner = rest[gt + 1:]
            end = inner.find("</")
            rest = rest[gt + 1:]
            if end < 0:
                continue
            text = decode(strip_tags(inner[:end]))
            if paired:
                out.append(text)
                continue
            if text == "" or is_boilerplate(text):
                continue
            exists = False
            for prev in out:
                if prev == text:
                    exists = True
            if exists == False:
                out.append(text)
    return out


def extract_tag_texts(html, tag):
    out = []
    rest = str(html)
    open1 = "<" + tag
    close = "</" + tag + ">"
    for _ in range(SCAN + 1):
        if len(out) >= SCAN:
            break
        p = rest.find(open1)
        if p < 0:
            break
        gt = rest.find(">", p)
        if gt < 0:
            break
        rest = rest[gt + 1:]
        end = rest.find(close)
        if end < 0:
            break
        text = decode(strip_tags(rest[:end]))
        rest = rest[end + len(close):]
        if text == "" or is_boilerplate(text):
            continue
        out.append(text)
    return out


def append_named_row(rows, name, status):
    if is_boilerplate(name):
        return
    u = collapse_ws(name).upper()
    if u == "SCHOOLS" or u == "BUSINESSES" or u == "CHURCHES":
        return
    if u == "GOVERNMENT" or u == "DAYCARES" or u == "ORGANIZATIONS" or u == "COLLEGES":
        return
    row = normalize_row({
        "name": name,
        "status": status,
    })
    if row != None:
        rows.append(row)


def parse_townnews_xml(body):
    raw = str(body)
    if raw.find("<File") < 0 and raw.find("<Closing") < 0:
        return None
    rows = []
    rest = raw
    for _ in range(SCAN + 1):
        if len(rows) >= SCAN:
            break
        a = rest.find("<Closing")
        if a < 0:
            break
        rest = rest[a + 8:]
        end = rest.find("</Closing>")
        if end < 0:
            break
        block = rest[:end]
        rest = rest[end + 10:]
        name = xml_text(block, "Name1")
        if name == "":
            name = xml_text(block, "Name")
        status = xml_text(block, "Status")
        if status == "":
            status = xml_text(block, "Status1")
        typ = xml_text(block, "EntityType")
        row = normalize_row({
            "name": name,
            "status": status,
            "type": typ,
        })
        if row != None:
            rows.append(row)
    if rows != []:
        return {"kind": "ok", "rows": rows}
    if raw.find("<File") >= 0:
        return {"kind": "empty", "rows": []}
    return {"kind": "unparseable", "rows": []}


def div_texts(h, classname):
    # The whole text of each <div class="classname">, tags and all stripped
    # (a row can hold <strong><a>Name</a>:</strong> Status).
    out = []
    needle = "class=\"" + classname + "\""
    rest = str(h)
    for _ in range(SCAN + 1):
        p = rest.find(needle)
        if p < 0:
            break
        gt = rest.find(">", p)
        if gt < 0:
            break
        rest = rest[gt + 1:]
        end = rest.find("</div>")
        if end < 0:
            break
        text = decode(strip_tags(rest[:end]))
        rest = rest[end + 6:]
        if text != "" and not is_boilerplate(text):
            out.append(text)
    return out


def parse_closing_blocks(h):
    # Newer Nexstar pages: <div class="closing"> holding closing__title,
    # closing__category (School, Business...) and closing__status.
    rows = []
    needle = "class=\"closing\""
    rest = str(h)
    for _ in range(SCAN + 1):
        p = rest.find(needle)
        if p < 0:
            break
        rest = rest[p + len(needle):]
        nxt = rest.find(needle)
        block = rest[:nxt] if nxt >= 0 else rest[:4000]
        names = extract_class_text(block, "closing__title", True)
        stats = extract_class_text(block, "closing__status", True)
        cats = extract_class_text(block, "closing__category", True)
        if names != [] and not is_boilerplate(names[0]):
            row = normalize_row({
                "name": names[0],
                "status": stats[0] if stats != [] else "",
                "type": cats[0] if cats != [] else "",
            })
            if row != None:
                rows.append(row)
        if nxt < 0:
            break
    return rows


def parse_nexstar_html(html):
    h = str(html)
    if h.find("No closings to report") >= 0:
        return {"kind": "empty", "rows": []}
    if h.find("Most recent closings and delays are listed here") >= 0 and h.find("closings-list__name") < 0 and h.find("closing_row") < 0:
        return {"kind": "empty", "rows": []}

    rows = parse_closing_blocks(h)
    for text in ([] if rows != [] else div_texts(h, "closing_row")):
        name, status = split_name_status(text)
        append_named_row(rows, name, status)
        if len(rows) >= SCAN:
            break

    if rows == []:
        names = extract_class_text(h, "closings-list__name", True)
        stats = extract_class_text(h, "closings-list__status", True)
        for i in range(len(names)):
            status = ""
            if i < len(stats):
                status = stats[i]
            append_named_row(rows, names[i], status)
            if len(rows) >= SCAN:
                break

    if rows == []:
        p = h.find("closings-list")
        if p >= 0:
            section = h[p:]
            # The list ends at its article; headings after it are other content.
            stop = section.find("</article>")
            if stop > 0:
                section = section[:stop]
            if len(section) > 20000:
                section = section[:20000]
            names = extract_tag_texts(section, "h3")
            details = extract_tag_texts(section, "p")
            for i in range(len(names)):
                status = ""
                if i < len(details):
                    status = details[i]
                append_named_row(rows, names[i], status)
                if len(rows) >= SCAN:
                    break

    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}

    if h.find("closings-page") >= 0 or h.find("closingsPage") >= 0:
        if h.find("Most recent closings and delays are listed here") >= 0:
            return {"kind": "empty", "rows": []}
        if h.find("closings-nav__item--empty") >= 0:
            return {"kind": "empty", "rows": []}
        return {"kind": "unparseable", "rows": []}

    if h.find("closing_header") >= 0 or h.find("KSN Weather Closings") >= 0:
        return {"kind": "unparseable", "rows": []}
    return None


def wp_rendered(data):
    page = None
    if type(data) == "list":
        if len(data) == 0:
            return ""
        page = data[0]
    elif type(data) == "dict":
        page = data
    else:
        return ""
    if type(page) != "dict":
        return ""
    content = page.get("content", None)
    if type(content) == "dict":
        rendered = content.get("rendered", "")
        if rendered == None:
            return ""
        return str(rendered)
    if type(content) == "string":
        return content
    return ""


def fetch_townnews(origin, html, page_url = ""):
    urls = townnews_xml_urls(html, origin)
    extra = townnews_guess_urls(origin, page_url if page_url != "" else origin)
    for url in extra:
        exists = False
        for prev in urls:
            if prev == url:
                exists = True
        if exists == False:
            urls.append(url)
    if urls == []:
        parsed = parse_townnews_xml(html)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}
    saw_body = False
    for xml_url in urls[:TOWNNEWS_TRIES]:
        x = http_get(xml_url)
        if x["status_code"] != 200:
            continue
        saw_body = True
        parsed = parse_townnews_xml(x["body"])
        if parsed != None:
            return parsed
    if saw_body:
        return {"kind": "unparseable", "rows": []}
    return {"kind": "unavailable", "rows": []}


def try_townnews(url):
    origin = origin_of(url)
    if origin == "":
        return None
    got = fetch_townnews(origin, "", url)
    kind = got.get("kind", "")
    if kind == "ok" or kind == "empty":
        return got
    return None


def fetch_nexstar_wp(url):
    origin = origin_of(url)
    slug = last_slug(url)
    if origin == "" or slug == "":
        return None
    api = origin + "/wp-json/wp/v2/pages?slug=" + slug
    g = http_get(api)
    code = g["status_code"]
    if code >= 300 and code < 400 and with_www(api) != "":
        # The bare domain only redirects to www, and Glance doesn't follow redirects.
        g = http_get(with_www(api))
    if g["status_code"] != 200:
        return None
    html = wp_rendered(g["json"])
    if html == "":
        return None
    src = nexstar_iframe_src(html)
    if src != "":
        x = http_get(abs_url(src, url))
        if x["status_code"] == 200:
            parsed = parse_nexstar_html(x["body"])
            if parsed != None:
                return parsed
            return {"kind": "unparseable", "rows": []}
    parsed = parse_nexstar_html(html)
    if parsed != None:
        return parsed
    if looks_like_nexstar(html):
        return {"kind": "unparseable", "rows": []}
    return None


def fetch_nexstar(url, html):
    src = nexstar_iframe_src(html)
    if src != "":
        x = http_get(abs_url(src, url))
        if x["status_code"] == 200:
            parsed = parse_nexstar_html(x["body"])
            if parsed != None:
                return parsed
            return {"kind": "unparseable", "rows": []}
    parsed = parse_nexstar_html(html)
    if parsed != None:
        return parsed
    wp = fetch_nexstar_wp(url)
    if wp != None:
        return wp
    return {"kind": "unparseable", "rows": []}


def parse_nbc_json(data):
    if type(data) == "dict":
        if "sites" in data or "network_feature_flags" in data:
            return None
        for key in ["closings", "listings", "items", "data", "organizations", "results"]:
            if key in data:
                return parse_nbc_json(data[key])
        row = normalize_row(data)
        if row != None:
            return {"kind": "ok", "rows": [row]}
        return None
    if type(data) != "list":
        return None
    if len(data) == 0:
        return {"kind": "empty", "rows": []}
    rows = []
    for item in data:
        if type(item) != "dict":
            continue
        row = normalize_row(item)
        if row != None:
            rows.append(row)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows}
    return {"kind": "unparseable", "rows": []}


def parse_nbc_html(html):
    h = str(html)
    if h.find("closings--inactive") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    orgs = extract_class_text(h, "listing__org", True)
    notices = extract_class_text(h, "listing__notice", True)
    for i in range(len(orgs)):
        status = ""
        if i < len(notices):
            status = notices[i]
        append_named_row(rows, orgs[i], status)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("closings--active") >= 0:
        return None
    if h.find("closings__listings") >= 0:
        return {"kind": "empty", "rows": []}
    if h.find("article-content--wrap closings") >= 0:
        return {"kind": "empty", "rows": []}
    return None


def fetch_nbc_json(url):
    origin = origin_of(url)
    if origin == "":
        return None
    g = http_get(origin + "/wp-json/nbc/v1/school-closings")
    if g["status_code"] != 200:
        return None
    return parse_nbc_json(g["json"])


def fetch_nbc(url, html):
    parsed = parse_nbc_html(html)
    if parsed != None and parsed.get("kind") != "unparseable":
        return parsed
    jparsed = fetch_nbc_json(url)
    if jparsed != None:
        return jparsed
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def html_section(html, marker, maxn):
    p = str(html).find(marker)
    if p < 0:
        return ""
    rest = str(html)[p:]
    if len(rest) > maxn:
        return rest[:maxn]
    return rest


def parse_scripps_html(html):
    h = str(html)
    section = html_section(h, "module--closings", 40000)
    if section == "":
        if h.find("There are currently no active closings or delays") >= 0:
            return {"kind": "empty", "rows": []}
        return None
    if section.find("There are currently no active closings or delays") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    rest = section
    for _ in range(SCAN + 1):
        a = rest.find("<article class=\"closing")
        if a < 0:
            break
        rest = rest[a + 9:]
        e = rest.find("</article>")
        block = rest[:e] if e >= 0 else rest[:3000]
        n1 = extract_class_text(block, "text--primary", True)
        s1 = [t for t in extract_class_text(block, "text--secondary", True) if not (len(t) >= 10 and t[:4].isdigit() and t[4:5] == "-")]
        if n1 != []:
            append_named_row(rows, n1[0], s1[0] if s1 != [] else "")
    if rows != []:
        return {"kind": "ok", "rows": rows}
    names = extract_class_text(section, "text--primary", True)
    stats = extract_class_text(section, "text--secondary", True)
    for i in range(len(names)):
        status = ""
        if i < len(stats):
            status = stats[i]
        append_named_row(rows, names[i], status)
        if len(rows) >= SCAN:
            break
    if rows == []:
        for text in extract_class_text(section, "closing"):
            name, status = split_name_status(text)
            append_named_row(rows, name, status)
            if len(rows) >= SCAN:
                break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    return {"kind": "empty", "rows": []}


def flashalert_rows(h):
    # <div class='cwcReport'><strong>NAME</strong>&nbsp;- what's happening</div>
    t = str(h).replace("class=\"cwcReport\"", "class='cwcReport'")
    rows = []
    rest = t
    for _ in range(SCAN):
        p = rest.find("class='cwcReport'")
        if p < 0:
            break
        rest = rest[p + 17:]
        gt = rest.find(">")
        end = rest.find("</div>")
        if gt < 0 or end < gt:
            break
        block = rest[gt + 1:end]
        rest = rest[end:]
        a = block.find("<strong>")
        b = block.find("</strong>")
        if a < 0 or b < a:
            continue
        status = collapse_ws(decode(strip_tags(block[b + 9:])))
        for _ in range(4):
            if status.startswith("-") or status.startswith(" "):
                status = status[1:]
        append_named_row(rows, block[a + 8:b], status)
    return rows


def parse_flashalert_html(html):
    h = str(html)
    if h.find("No information reported") >= 0:
        return {"kind": "empty", "rows": []}
    rows = flashalert_rows(h)
    if rows == []:
        for text in extract_class_text(h, "cwcReport"):
            if is_boilerplate(text):
                continue
            name, status = split_name_status(text)
            append_named_row(rows, name, status)
            if len(rows) >= SCAN:
                break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("cwcReportContainer") >= 0:
        return {"kind": "empty", "rows": []}
    return None


def take_url_at(h, start):
    rest = str(h)[start:]
    rest = rest.replace("\\/", "/")
    rest = rest.replace("\\u002F", "/")
    if rest.find("https://") != 0 and rest.find("http://") != 0:
        return ""
    end = len(rest)
    for ch in ["\"", "'", " ", "<", ">", "}", "]", "\n", "\r", "\\"]:
        e = rest.find(ch)
        if e >= 0 and e < end:
            end = e
    url = rest[:end]
    if url.find("http") != 0:
        return ""
    return url


def url_near_needle(html, needle):
    h = str(html)
    p = h.find(needle)
    if p < 0:
        return ""
    idx = p
    for _ in range(180):
        if idx < 0:
            break
        if h[idx:idx + 4] == "http":
            return take_url_at(h, idx)
        idx = idx - 1
    return ""


def ftptransfer_path(html):
    h = str(html)
    needle = "/resources/ftptransfer/"
    rest = h
    for _ in range(16):
        p = rest.find(needle)
        if p < 0:
            return ""
        chunk = rest[p:]
        rest = rest[p + len(needle):]
        end = -1
        e1 = chunk.find(".html")
        e2 = chunk.find(".htm")
        if e1 >= 0 and e1 < 180:
            end = e1 + 5
        elif e2 >= 0 and e2 < 180:
            end = e2 + 4
        if end < 0:
            continue
        path = chunk[:end]
        if path.find("closing") < 0:
            continue
        bad = False
        for ch in [" ", "\"", "'", "<", ">", "\n", "\r", "\\"]:
            if path.find(ch) >= 0:
                bad = True
        if bad:
            continue
        return path
    return ""


def flashalert_src(html):
    u = url_near_needle(html, "flashalertnewswire.net")
    if u == "":
        u = url_near_needle(html, "cwc-closures.php")
    return u


def worldnow_src(html, page_url):
    foxtv = url_near_needle(html, "media.foxtv.com")
    if foxtv.find("/closings") >= 0 or foxtv.find("closings.") >= 0:
        return foxtv
    path = ftptransfer_path(html)
    if path != "":
        return abs_url(path, page_url)
    return ""


def cbs_feed_src(html):
    u = url_near_needle(html, "Integrations/SchoolClosings")
    if u != "":
        return u
    u = url_near_needle(html, "Integrations\\/SchoolClosings")
    if u != "":
        return u
    return url_near_needle(html, "SchoolClosings")


def looks_like_worldnow(html):
    h = str(html)
    if h.find("CLASS=\"orgname\"") >= 0 or h.find("class=\"orgname\"") >= 0:
        return True
    if h.find("There are no active records at this time") >= 0:
        return True
    if h.find("THERE ARE CURRENTLY NO CLOSINGS OR CANCELLATIONS") >= 0:
        return True
    if h.find("No Closings Reported") >= 0 and h.find("Last Updated") >= 0:
        return True
    if h.find("Closings Last Updated") >= 0:
        return True
    if h.find("There are no closings or cancellations at this time") >= 0:
        return True
    if h.find("media.foxtv.com") >= 0 and h.find("/closings") >= 0:
        return True
    if ftptransfer_path(h) != "":
        return True
    return False


def looks_like_tegna(html):
    h = str(html)
    if h.find("closings__error") >= 0:
        return True
    if h.find("closings__list") >= 0 or h.find("closings__item") >= 0:
        return True
    if h.find("closings__title") >= 0:
        return True
    return False


def looks_like_hearst(html):
    h = str(html)
    if h.find("closingsData") >= 0:
        return True
    if h.find("No closings or delays at this time") >= 0:
        return True
    return False


def looks_like_cbs(html):
    h = str(html)
    if h.find("data-component=\"school-closings\"") >= 0:
        return True
    if h.find("data-school-closings-options") >= 0:
        return True
    if h.find("Integrations/SchoolClosings") >= 0:
        return True
    return False


def looks_like_cox(html):
    h = str(html)
    if h.find("class=\"closing-list") >= 0:
        return True
    if h.find("class='closing-list") >= 0:
        return True
    return False


def looks_like_arc_school(html):
    h = str(html)
    if h.find("weather-school-closings") >= 0:
        return True
    if h.find("SchoolClosings/default") >= 0:
        return True
    if h.find("class=\"school-closings\"") >= 0:
        return True
    if h.find("class='school-closings'") >= 0:
        return True
    return False


def arc_school_empty_copy(html):
    h = str(html)
    if h.find("No active school closings at this time") >= 0:
        return True
    if h.find("No active school closings") >= 0:
        return True
    return False


def worldnow_empty_copy(html):
    h = str(html)
    if h.find("There are no active records at this time") >= 0:
        return True
    if h.find("No Closings Reported") >= 0:
        return True
    if h.find("THERE ARE CURRENTLY NO CLOSINGS OR CANCELLATIONS") >= 0:
        return True
    if h.find("THERE ARE CURRENTLY NO CLOSINGS") >= 0:
        return True
    if h.find("There are no closings or cancellations at this time") >= 0:
        return True
    if h.find("No Closings have been reported at this time") >= 0:
        return True
    return False


def parse_updated_table(h):
    # Older Sinclair feeds (WJAC, WSBT, WTOV): "Closings Last Updated at ..."
    # over a three-column table, <b>NAME</b> in one cell and the status in the next.
    if h.find("Closings Last Updated") < 0:
        return None
    t = h.replace("<B>", "<b>").replace("</B>", "</b>").replace("<TD", "<td").replace("</TD>", "</td>")
    rows = []
    rest = t
    for _ in range(SCAN):
        b = rest.find("<b>")
        if b < 0:
            break
        e = rest.find("</b>", b)
        if e < 0:
            break
        name = rest[b + 3:e]
        rest = rest[e + 4:]
        status = ""
        td = rest.find("<td")
        nxt = rest.find("<b>")
        if td >= 0 and (nxt < 0 or td < nxt):
            gt = rest.find(">", td)
            close = rest.find("</td>", td)
            if gt >= 0 and close > gt:
                status = rest[gt + 1:close]
        append_named_row(rows, name, status)
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    return {"kind": "unparseable", "rows": []}


def first_end(rest, marks):
    best = -1
    for m in marks:
        q = rest.find(m)
        if q >= 0 and (best < 0 or q < best):
            best = q
    return best


def worldnow_rows(h):
    # Each orgname is paired with the first status after it in the same table
    # row. Rows can start with a town in a status cell (RI Broadcasters), and
    # an orgname cell with no status after it is a section heading.
    t = h.replace("class=\"orgname\"", "CLASS=\"orgname\"").replace("class=\"status\"", "CLASS=\"status\"")
    t = t.replace("</tr>", "</TR>").replace("</td>", "</TD>").replace("</font>", "</FONT>").replace("</span>", "</SPAN>")
    rows = []
    rest = t
    for _ in range(SCAN * 2):
        p = rest.find("CLASS=\"orgname\"")
        if p < 0:
            break
        rest = rest[p + 15:]
        gt = rest.find(">")
        if gt < 0:
            break
        rest = rest[gt + 1:]
        end = first_end(rest, ["</FONT>", "</TD>", "</SPAN>"])
        if end < 0:
            break
        name = rest[:end]
        rest = rest[end:]
        limit = first_end(rest, ["</TR>", "CLASS=\"orgname\""])
        if limit < 0:
            limit = len(rest)
        sp = rest.find("CLASS=\"status\"")
        if sp < 0 or sp > limit:
            continue
        seg = rest[sp:]
        sgt = seg.find(">")
        if sgt < 0:
            continue
        seg = seg[sgt + 1:]
        send = first_end(seg, ["</FONT>", "</TD>", "</SPAN>"])
        if send < 0:
            continue
        append_named_row(rows, name, seg[:send])
        if len(rows) >= SCAN:
            break
    return rows


def parse_portal_rows(body):
    # Delaware's statewide feed (schoolclosings.delaware.gov): <row> elements of
    # <cell>s, school, headline, district, details. Zero records means clear.
    raw = str(body)
    if raw.find("<rows") < 0:
        return None
    if raw.find("<records>0</records>") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    rest = raw
    for _ in range(SCAN):
        p = rest.find("<row ")
        if p < 0:
            break
        rest = rest[p + 5:]
        end = rest.find("</row>")
        if end < 0:
            break
        block = rest[:end]
        rest = rest[end + 6:]
        cells = []
        part = block
        for _ in range(6):
            a = part.find("<cell>")
            if a < 0:
                break
            b = part.find("</cell>", a)
            if b < 0:
                break
            cells.append(part[a + 6:b])
            part = part[b + 7:]
        if len(cells) < 2:
            continue
        # The headline is free text ("Red Clay Closed 2/20/19", "Important
        # notice from BSD"); when it names no status, the details usually do.
        status = normalize_status(decode(cells[1]))
        if status_kind(status) == "other" and len(cells) >= 4:
            more = normalize_status(decode(cells[3]))
            if status_kind(more) != "other":
                status = more
        append_named_row(rows, cells[0], status)
    if rows != []:
        return {"kind": "ok", "rows": rows}
    return {"kind": "empty", "rows": []}


def parse_worldnow_html(html):
    h = str(html)
    if worldnow_empty_copy(h):
        return {"kind": "empty", "rows": []}
    table = parse_updated_table(h)
    if table != None:
        return table
    rows = worldnow_rows(h)
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("CLASS=\"orgname\"") >= 0 or h.find("class=\"orgname\"") >= 0:
        return {"kind": "empty", "rows": []}
    if looks_like_worldnow(h):
        return {"kind": "unparseable", "rows": []}
    return None


def parse_tegna_html(html):
    h = str(html)
    if h.find("No delays or closings") >= 0:
        return {"kind": "empty", "rows": []}
    if h.find("closings__error") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    names = extract_class_text(h, "closings__title", True)
    stats = extract_class_text(h, "closings__body", True)
    for i in range(len(names)):
        status = ""
        if i < len(stats):
            status = stats[i]
        append_named_row(rows, names[i], status)
        if len(rows) >= SCAN:
            break
    if rows == []:
        for text in extract_class_text(h, "closings__item"):
            name, status = split_name_status(text)
            append_named_row(rows, name, status)
            if len(rows) >= SCAN:
                break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("closings__list") >= 0:
        return {"kind": "empty", "rows": []}
    return {"kind": "unparseable", "rows": []}


def jsonish_field(block, key):
    needles = [
        "\"" + key + "\":\"",
        "\\\"" + key + "\\\":\\\"",
    ]
    for needle in needles:
        p = str(block).find(needle)
        if p < 0:
            continue
        rest = str(block)[p + len(needle):]
        end = len(rest)
        e1 = rest.find("\\\"")
        e2 = rest.find("\"")
        if e1 >= 0 and e1 < end:
            end = e1
        if e2 >= 0 and e2 < end:
            end = e2
        val = decode(rest[:end])
        if val != "":
            return val
    return ""


def hearst_array_populated(window):
    w = str(window)
    if w.find("closings\\\":[{") >= 0:
        return True
    if w.find("\"closings\":[{") >= 0:
        return True
    if w.find("closings\":[{") >= 0:
        return True
    return False


def parse_hearst_objects(window):
    w = str(window)
    start = w.find("[{")
    if start < 0:
        start = w.find("[ {")
    if start < 0:
        return []
    rest = w[start:]
    rows = []
    for _ in range(SCAN + 1):
        if len(rows) >= SCAN:
            break
        a = rest.find("{")
        if a < 0:
            break
        rest = rest[a + 1:]
        end = rest.find("}")
        if end < 0:
            break
        block = rest[:end]
        rest = rest[end + 1:]
        name = jsonish_field(block, "name")
        if name == "":
            name = jsonish_field(block, "title")
        if name == "":
            name = jsonish_field(block, "organization")
        if name == "":
            name = jsonish_field(block, "organizationName")
        if name == "":
            name = jsonish_field(block, "orgName")
        status = jsonish_field(block, "status")
        if status == "":
            status = jsonish_field(block, "closingStatus")
        if status == "":
            status = jsonish_field(block, "statusText")
        if status == "":
            status = jsonish_field(block, "notice")
        append_named_row(rows, name, status)
    return rows


def hearst_array(h, p):
    # The text of the closings array after "closingsData", or "".
    q = -1
    for key in ["closings\\\":[", "\"closings\":["]:
        k = h.find(key, p)
        if k >= 0 and (q < 0 or k < q):
            q = k + len(key) - 1
    if q < 0 or q - p > 400:
        return ""
    depth = 0
    for i in range(q, min(len(h), q + 400000)):
        ch = h[i]
        if ch == "[" or ch == "{":
            depth += 1
        elif ch == "]" or ch == "}":
            depth -= 1
            if depth == 0:
                return h[q:i + 1]
    return ""


def hearst_rows(arr):
    # Split the array into its top-level objects and read each one.
    rows = []
    depth = 0
    start = -1
    for i in range(len(arr)):
        ch = arr[i]
        if ch == "{":
            depth += 1
            if depth == 1:
                start = i
        elif ch == "}":
            depth -= 1
            if depth == 0 and start >= 0:
                obj = arr[start:i + 1]
                start = -1
                name = jsonish_field(obj, "name")
                status = jsonish_field(obj, "status")
                row = normalize_row({"name": name, "status": status, "type": jsonish_field(obj, "type")})
                if row != None:
                    rows.append(row)
                if len(rows) >= SCAN:
                    break
    return rows


def parse_hearst_html(html):
    h = str(html)
    p = h.find("closingsData")
    if p >= 0:
        arr = hearst_array(h, p)
        if arr != "":
            rows = hearst_rows(arr)
            if rows != []:
                return {"kind": "ok", "rows": rows}
            return {"kind": "empty", "rows": []}
        window = h[p:]
        if len(window) > 80000:
            window = window[:80000]
        if hearst_array_populated(window):
            rows = parse_hearst_objects(window)
            if rows != []:
                return {"kind": "ok", "rows": rows[:SCAN]}
            return {"kind": "unparseable", "rows": []}
        return {"kind": "empty", "rows": []}
    if h.find("No closings or delays at this time") >= 0:
        return {"kind": "empty", "rows": []}
    return None


def cox_details(block):
    k = block.find("margin-xs-left")
    if k < 0:
        return ""
    rest = block[k:]
    d = rest.find("<div")
    if d < 0:
        return ""
    rest = rest[d:]
    gt = rest.find(">")
    end = rest.find("</div>")
    if gt < 0 or end < gt:
        return ""
    return collapse_ws(decode(strip_tags(rest[gt + 1:end])))


def parse_cox_rows(section):
    rows = []
    rest = section
    for _ in range(SCAN + 1):
        p = rest.find(" closing=\"")
        if p < 0:
            break
        rest = rest[p + 10:]
        nxt = rest.find(" closing=\"")
        block = rest[:nxt] if nxt >= 0 else rest[:4000]
        names = extract_class_text(block, "truncate", True)
        stats = extract_class_text(block, "margin-xs-left", True)
        if names != []:
            status = stats[0] if stats != [] else ""
            if status_kind(normalize_status(status)) == "other":
                # The chip can just say "Other"; the details cell after it
                # carries the real status ("Closed. Due to ...; CLOSED").
                more = cox_details(block)
                if status_kind(normalize_status(more)) != "other":
                    status = more
            append_named_row(rows, names[0], status)
        if nxt < 0:
            break
    return rows


def parse_cox_html(html):
    h = str(html)
    section = html_section(h, "closing-list", 120000)
    if section == "":
        return None
    if section.find("No results found") >= 0:
        return {"kind": "empty", "rows": []}
    rows = parse_cox_rows(section)
    if rows != []:
        return {"kind": "ok", "rows": rows}
    names = extract_class_text(section, "closing-name")
    stats = extract_class_text(section, "closing-status")
    if names == []:
        names = extract_class_text(section, "closing-list__name", True)
        stats = extract_class_text(section, "closing-list__status", True)
    for i in range(len(names)):
        status = ""
        if i < len(stats):
            status = stats[i]
        append_named_row(rows, names[i], status)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    return {"kind": "unparseable", "rows": []}


def parse_arc_school_json(data):
    if type(data) != "dict":
        return None
    if "organizations" in data or "totalResults" in data:
        return None
    closing = data.get("closing", None)
    if closing == None:
        if "lastUpdated" in data:
            return {"kind": "empty", "rows": []}
        return None
    if type(closing) != "list":
        return None
    rows = []
    for item in closing:
        if type(item) != "dict":
            continue
        code = str(item.get("statuscode", ""))
        if code == "0":
            continue
        row = normalize_row({
            "name": item.get("name1", ""),
            "status": item.get("status", ""),
            "type": item.get("entitytype", ""),
        })
        if row != None:
            rows.append(row)
        if len(rows) >= SCAN:
            break
    if rows == []:
        return {"kind": "empty", "rows": []}
    return {"kind": "ok", "rows": rows[:SCAN]}


def parse_arc_school_html(html):
    h = str(html)
    section = html_section(h, "class=\"school-closings\"", 50000)
    if section == "":
        section = html_section(h, "class='school-closings'", 50000)
    if section == "":
        if arc_school_empty_copy(h):
            return {"kind": "empty", "rows": []}
        return None
    if arc_school_empty_copy(section):
        return {"kind": "empty", "rows": []}
    rows = []
    rest = section
    for _ in range(SCAN):
        p = rest.find("class=\"school\"")
        if p < 0:
            p = rest.find("class='school'")
        if p < 0:
            break
        rest = rest[p + 12:]
        nxt = rest.find("class=\"school\"")
        alt = rest.find("class='school'")
        if nxt < 0 or (alt >= 0 and alt < nxt):
            nxt = alt
        block = rest[:nxt] if nxt >= 0 else rest[:1500]
        names = extract_class_text(block, "name")
        stats = extract_class_text(block, "status")
        kinds = extract_class_text(block, "entity-type")
        name = ""
        if names != []:
            name = names[0]
        if kinds != [] and name != "":
            name = collapse_ws(name.replace(kinds[0], ""))
        status = ""
        if stats != []:
            status = stats[0]
        append_named_row(rows, name, status)
        if nxt < 0:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    return {"kind": "unparseable", "rows": []}


def fetch_arc_school(origin, html):
    if arc_school_empty_copy(html):
        return {"kind": "empty", "rows": []}
    api = origin + ARC_SCHOOL_PATH
    g = http_get(api)
    if g["status_code"] == 200:
        parsed = parse_arc_school_json(g["json"])
        if parsed != None:
            return parsed
    parsed = parse_arc_school_html(html)
    if parsed != None:
        return parsed
    if g["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    return {"kind": "unparseable", "rows": []}


def fetch_flashalert(url, html):
    src = flashalert_src(html)
    if src == "":
        parsed = parse_flashalert_html(html)
        if parsed != None:
            return parsed
        return None
    x = http_get(abs_url(src, url))
    if x["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    parsed = parse_flashalert_html(x["body"])
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def fetch_worldnow(url, html):
    src = worldnow_src(html, url)
    if src == "":
        parsed = parse_worldnow_html(html)
        if parsed != None:
            return parsed
        return None
    x = http_get(src)
    if x["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    parsed = parse_worldnow_html(x["body"])
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def fetch_cbs(html):
    feed = cbs_feed_src(html)
    if feed == "":
        return {"kind": "unparseable", "rows": []}
    if feed.find("emergencyclosingcenter.com") >= 0:
        return {"kind": "unsupported", "rows": []}
    x = http_get(feed)
    if x["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    parsed = parse_newsticker_xml(x["body"])
    if parsed != None:
        return parsed
    parsed = parse_townnews_xml(x["body"])
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def http_get(url):
    if url == "":
        return {"status_code": 0, "body": "", "json": None}
    return http.get(url, headers = HEADERS, ttl_seconds = TTL)


def first_str(obj, keys):
    if type(obj) != "dict":
        return ""
    for k in keys:
        if k not in obj or obj[k] == None:
            continue
        v = obj[k]
        t = type(v)
        if t == "string" or t == "int" or t == "float":
            s = decode(str(v))
            if s != "":
                return s
        elif t == "dict":
            inner = first_str(v, [
                "name", "name1", "text", "value", "label", "title",
                "forced", "completeStatus", "status",
            ])
            if inner != "":
                return inner
        elif t == "list" and len(v) > 0:
            item = v[0]
            if type(item) == "string" or type(item) == "int":
                s = decode(str(item))
                if s != "":
                    return s
            elif type(item) == "dict":
                inner = first_str(item, [
                    "name", "name1", "text", "value", "label", "title",
                ])
                if inner != "":
                    return inner
    return ""


def status_kind(status):
    u = str(status).upper()
    if u.find("REMOTE") >= 0 or u.find("VIRTUAL") >= 0 or u.find("E-LEARN") >= 0 or u.find("DISTANCE LEARN") >= 0 or u.find("ONLINE") >= 0 or u.find("NTI") >= 0:
        return "remote"
    if u.find("EARLY") >= 0 or u.find("DISMISS") >= 0 or u.find("CLOSING AT") >= 0 or u.find("CLOSES AT") >= 0 or u.find("CLOSE AT") >= 0:
        return "early"
    if u.find("OPEN THROUGH") >= 0 or u.find("OPEN UNTIL") >= 0 or u.find("OPEN TIL") >= 0:
        return "early"
    if u.find("CLOSED") >= 0 or u.find("CANCEL") >= 0 or u.find("NO SCHOOL") >= 0 or u.find("NO CLASSES") >= 0:
        return "closed"
    if u.find("DELAY") >= 0 or u.find("LATE") >= 0 or u.find("OPENING AT") >= 0 or u.find("OPENS AT") >= 0:
        return "delay"
    return "other"


def status_color(kind):
    if kind == "closed":
        return RED
    if kind == "delay":
        return AMBER
    if kind == "early":
        return ORANGE
    if kind == "remote":
        return CYAN
    return AMBER


def is_open_status(st):
    # Read on the raw status text, before it is rewritten.
    u = collapse_ws(str(st)).upper()
    if u == "OPEN" or u == "OPENED" or u == "NORMAL" or u == "NO CHANGE" or u == "ON TIME":
        return True
    if u.find("AS USUAL") >= 0 or u.find("NO DELAY") >= 0 or u.find("AS SCHEDULED") >= 0:
        return True
    if u.find("NO CLOS") >= 0 or u.find("NOT CLOSED") >= 0 or u.find("REGULAR SCHEDULE") >= 0:
        return True
    if u.find("OPEN -") == 0 or u.find("OPEN,") == 0 or u.find("OPEN TODAY") == 0:
        return True
    return False


def drop_dots(u):
    # "SCH. DIST." -> "SCH DIST" but "1.5 HR" keeps its decimal point.
    out = ""
    for i in range(len(u)):
        ch = u[i]
        if ch == ".":
            before = i > 0 and u[i - 1].isdigit()
            after = i + 1 < len(u) and u[i + 1].isdigit()
            if not (before and after):
                continue
        out = out + ch
    return out


def normalize_status(raw):
    u = collapse_ws(str(raw)).upper()
    u = u.replace("HOURS", "HR").replace("HOUR", "HR").replace("HRS", "HR")
    u = collapse_ws(drop_dots(u))
    if u == "":
        return ""
    if u.find("REMOTE") >= 0 or u.find("VIRTUAL") >= 0 or u.find("E-LEARN") >= 0 or u.find("E LEARN") >= 0 or u.find("DISTANCE LEARN") >= 0:
        return "REMOTE LEARNING"
    if u.find("EARLY DISMISS") >= 0 or u.find("EARLY RELEASE") >= 0 or u.find("CLOSING EARLY") >= 0:
        return "EARLY DISMISSAL"
    if u.find("CLOSING AT") >= 0 or u.find("CLOSES AT") >= 0 or u.find("CLOSE AT") >= 0 or u.find("DISMISS AT") >= 0:
        return u
    if u.find("NO SCHOOL") >= 0 or u.find("NO CLASSES") >= 0:
        return "CLOSED"
    if u.find("OPENING LATE") >= 0 or u.find("LATE START") >= 0 or u.find("STARTS LATE") >= 0:
        return "OPENING LATE"
    if u.find("CANCEL") >= 0:
        return "CANCELLED"
    for n in [["1.5", "1.5"], ["2.5", "2.5"], ["2", "2"], ["TWO", "2"], ["1", "1"], ["ONE", "1"], ["3", "3"], ["THREE", "3"]]:
        if u.find(n[0] + " HR") >= 0 or u.find(n[0] + "HR") >= 0:
            if n[0] == "1" and (u.find("1.5") >= 0 or u.find("11") >= 0):
                continue
            if n[0] == "2" and u.find("2.5") >= 0:
                continue
            return n[1] + " HR DELAY"
    if u.find("DELAY") >= 0:
        if u.find("HR DELAY") >= 0:
            return u
        return "DELAY"
    if u.find("CLOSED") >= 0 or u == "CLOSE" or u.find("CLOSING") >= 0 or u.find("CLOSURE") >= 0:
        return "CLOSED"
    return u


def drop_brackets(t):
    # "MILAN AREA SCHOOLS [WEB POSTING]" -> "MILAN AREA SCHOOLS"
    for _ in range(4):
        a = t.find("[")
        if a < 0:
            break
        b = t.find("]", a)
        t = t[:a] + (t[b + 1:] if b > a else "")
    return collapse_ws(t)


def normalize_row(obj):
    name = drop_brackets(first_str(obj, NAME_KEYS).upper())
    raw_status = first_str(obj, STATUS_KEYS)
    if is_open_status(raw_status):
        return None
    status = normalize_status(raw_status)
    detail = first_str(obj, DETAIL_KEYS).upper()
    z = zip_label(first_str(obj, ZIP_KEYS))
    if name == "":
        return None
    if is_open_status(status):
        return None
    typ = first_str(obj, TYPE_KEYS).upper()
    if status == "":
        status = "REPORTED"
    if detail == status:
        detail = ""
    return {
        "name": name,
        "status": status,
        "detail": detail,
        "zip": z,
        "kind": status_kind(status),
        "type": typ,
        "matched": False,
    }


def parse_gsync_json(data):
    if type(data) != "dict":
        return None
    has_total = "totalResults" in data
    has_orgs = "organizations" in data
    has_export = "exportType" in data
    if not has_total and not has_orgs and not has_export:
        return None
    orgs = data.get("organizations", [])
    rows = []
    seen = 0
    if type(orgs) == "list":
        seen = len(orgs)
        for item in orgs:
            row = normalize_row(item)
            if row != None:
                rows.append(row)
            if len(rows) >= SCAN:
                break
    total = data.get("totalResults", None)
    n = 0
    if total != None:
        n = int(digits_only(str(total)) or "0")
    if rows == [] and (has_total or has_orgs):
        if n == 0 or seen > 0 or (has_orgs and type(orgs) == "list" and len(orgs) == 0):
            return {"kind": "empty", "rows": []}
        return {"kind": "unparseable", "rows": []}
    return {"kind": "ok", "rows": rows, "total": n}


def parse_newsticker_xml(body):
    raw = str(body)
    start = raw.find("<DATA>")
    section = raw[start:] if start >= 0 else raw
    if section.find("<NUM_CLOSINGS>") < 0 and section.find("<RECORD") < 0:
        return None
    num = xml_text(section, "NUM_CLOSINGS")
    n = int(digits_only(num) or "0")
    rows = []
    seen = 0
    rest = section
    for _ in range(SCAN + 1):
        if len(rows) >= SCAN:
            break
        a = rest.find("<RECORD")
        if a < 0:
            break
        rest = rest[a + 7:]
        end = rest.find("</RECORD>")
        if end < 0:
            break
        block = rest[:end]
        rest = rest[end + 9:]
        seen += 1
        name = xml_text(block, "ORGANIZATION_NAME1")
        if name == "":
            name = xml_text(block, "FORCED_ORGANIZATION_NAME")
        if name == "":
            name = xml_text(block, "ALT_ORGANIZATION_NAME")
        status = xml_text(block, "COMPLETE_STATUS")
        if status == "":
            status = xml_text(block, "STATUS_NAME1")
        if status == "":
            status = xml_text(block, "FORCED_STATUS_NAME")
        if status == "":
            status = xml_text(block, "ALT_STATUS_TEXT")
        detail = xml_text(block, "COMMENTS_LINE1")
        z = xml_text(block, "ZIPCODE")
        row = normalize_row({
            "name": name,
            "status": status,
            "detail": detail,
            "zipcode": z,
        })
        if row != None:
            rows.append(row)
    if rows == []:
        if n == 0 or seen > 0:
            return {"kind": "empty", "rows": []}
        return {"kind": "unparseable", "rows": []}
    return {"kind": "ok", "rows": rows, "total": n}


def words_of(text):
    # "St. Mary's" -> "ST MARYS"; "Saint" reads as "ST".
    t = str(text).upper()
    out = ""
    for ch in t.elems():
        if ch.isalpha() or ch.isdigit():
            out = out + ch
        elif ch == "'":
            continue
        else:
            out = out + " "
    w = [x for x in out.split(" ") if x != ""]
    return " ".join(["ST" if x == "SAINT" else x for x in w])


def school_query(raw):
    q = words_of(raw)
    if q in ["NONE", "N A", "NA"]:
        return ""
    if len(q) < 3:
        return ""
    if q == "SCHOOL" or q == "SCHOOLS" or q == "THE" or q == "AND":
        return ""
    if q == "COUNTY" or q == "PUBLIC" or q == "CLOSED" or q == "CLOSINGS":
        return ""
    if q == "DELAY" or q == "DELAYS" or q == "DISTRICT":
        return ""
    return q


def school_match_score(query, name):
    # Whole words only: "LEE" matches "LEE ELEMENTARY", not "OAKLEE ACADEMY".
    q = school_query(query)
    n = words_of(name)
    if q == "" or n == "":
        return 0
    if q == n:
        return 3
    padded = " " + n + " "
    if (n + " ").find(q + " ") == 0:
        return 2
    if padded.find(" " + q + " ") >= 0:
        return 1
    return 0


def with_match(row, matched):
    return {
        "name": row.get("name", ""),
        "status": row.get("status", ""),
        "detail": row.get("detail", ""),
        "zip": row.get("zip", ""),
        "kind": row.get("kind", "other"),
        "type": row.get("type", ""),
        "matched": matched,
    }


def prefer_school(rows, query):
    if rows == []:
        return rows
    q = school_query(query)
    if q == "":
        out = []
        for r in rows:
            out.append(with_match(r, False))
        return out
    exact = []
    prefix = []
    contains = []
    rest = []
    for r in rows:
        score = school_match_score(q, r.get("name", ""))
        item = with_match(r, score > 0)
        if score == 3:
            exact.append(item)
        elif score == 2:
            prefix.append(item)
        elif score == 1:
            contains.append(item)
        else:
            rest.append(item)
    return exact + prefix + contains + rest


def http_get_www(url):
    # One GET, and a second on www when a bare domain only redirects there.
    r = http_get(url)
    code = r["status_code"]
    if code >= 300 and code < 400 and with_www(url) != "":
        r = http_get(with_www(url))
    return r


def parse_npg_html(body):
    # News-Press & Gazette's closings page (npgdigital.com/kmiz/closings.html):
    # two tables, schools then community. Each row is cells; the name is the
    # first cell and the status the first later cell that says what happened.
    h = str(body).replace("<TR", "<tr").replace("</TR>", "</tr>").replace("<TD", "<td").replace("</TD>", "</td>")
    if h.find("altrowstable") < 0 and h.find("No Active School Closings") < 0:
        return None
    rows = []
    rest = h
    for _ in range(SCAN * 2 + 10):
        a = rest.find("<tr")
        if a < 0 or len(rows) >= SCAN:
            break
        e = rest.find("</tr>", a)
        if e < 0:
            break
        tr = rest[a:e]
        rest = rest[e + 5:]
        cells = []
        part = tr
        for _ in range(12):
            c = part.find("<td")
            if c < 0:
                break
            gt = part.find(">", c)
            close = part.find("</td>", c)
            if gt < 0 or close < gt:
                break
            cells.append(decode(strip_tags(part[gt + 1:close])))
            part = part[close + 5:]
        cells = [x for x in cells if x != ""]
        if len(cells) < 2:
            continue
        status = ""
        for x in cells[1:]:
            if status_kind(x) != "other":
                status = x
                break
        if status == "":
            status = cells[1]
        append_named_row(rows, cells[0], status)
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("No Active") >= 0:
        return {"kind": "empty", "rows": []}
    return {"kind": "unparseable", "rows": []}


def storm_url(page_url):
    # A TownNews closings section ("/weather/closings/") -> its newest article as JSON.
    origin = origin_of(page_url)
    if origin == "":
        return ""
    path = clean_url(page_url)[len(origin):]
    if path.find("?") >= 0:
        path = path[:path.find("?")]
    path = path.strip("/")
    if path.lower().find("closing") < 0:
        return ""
    return origin + "/search/?f=json&t=article&c=" + path + "&l=1&s=start_time&sd=desc"


def ms_time(field):
    if type(field) != "dict" or field.get("utc") == None:
        return 0
    d = digits_only(str(field["utc"]))
    if d == "":
        return 0
    return int(d) // 1000


def storm_line(text):
    # "Eastern Wyoming College - Torrington Campus - 2 Hour Delay": the status
    # starts at the first piece that says what happened.
    t = collapse_ws(text.replace("\u00a0", " ").replace(" -", " - "))
    parts = t.split(" - ")
    for i in range(1, len(parts)):
        if status_kind(parts[i]) != "other":
            return " - ".join(parts[:i]), " - ".join(parts[i:])
    return split_name_status(t)


def parse_storm_json(data, now):
    # Stations that post one "School Closings and Delays" article per storm
    # (Wyoming News Now). Only an article from the last STORM_LIST_HOURS counts;
    # an older one is yesterday's storm, so the board is clear.
    if type(data) != "dict" or type(data.get("rows")) != "list":
        return None
    found = data["rows"]
    if found == []:
        return {"kind": "empty", "rows": []}
    art = found[0]
    if type(art) != "dict":
        return None
    start = ms_time(art.get("starttime"))
    if start == 0:
        return None
    if now > 0 and (now - start > STORM_LIST_HOURS * 3600 or start - now > 3600):
        return {"kind": "empty", "rows": []}
    content = art.get("content")
    pieces = content if type(content) == "list" else [str(content)]
    rows = []
    for piece in pieces:
        h = str(piece)
        for tag in ["</div>", "</p>", "</li>", "</h2>", "</h3>", "<br>", "<br/>", "<br />"]:
            h = h.replace(tag, "\n")
        for line in h.split("\n"):
            text = decode(strip_tags(line))
            if text == "" or text.endswith(":") or len(text) < 4:
                continue
            name, status = storm_line(text)
            if status == "":
                continue
            append_named_row(rows, name, status)
            if len(rows) >= SCAN:
                break
    if rows == []:
        return {"kind": "empty", "rows": []}
    return {"kind": "ok", "rows": rows[:SCAN]}


def fetch_storm(json_url, now):
    if json_url == "":
        return None
    r = http_get_www(json_url)
    if r["status_code"] != 200:
        return None
    return parse_storm_json(r["json"], now)


def fetch_source(url, now = 0):
    u = clean_url(url)
    if u == "":
        return {"kind": "unsupported", "rows": []}

    if u.find("gsync-closings") >= 0:
        r = http_get_www(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_gsync_json(r["json"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("/app/closings/") >= 0 and u.find(".xml") >= 0:
        r = http_get_www(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_townnews_xml(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("closings.xml") >= 0 or u.find("newsticker/closings") >= 0:
        xml_url = u.replace(".html", ".xml")
        r = http_get(xml_url)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_newsticker_xml(r["body"])
        if parsed != None:
            return parsed
        parsed = parse_townnews_xml(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("/search/") >= 0 and u.find("f=json") >= 0:
        got = fetch_storm(u, now)
        if got != None:
            return got
        return {"kind": "unavailable", "rows": []}

    if u.find("npgdigital.com/") >= 0 and u.find("closing") >= 0:
        r = http_get(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_npg_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("schoolclosings.delaware.gov") >= 0:
        r = http_get(DELAWARE_FEED)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_portal_rows(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("flashalertnewswire.net") >= 0:
        r = http_get_www(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_flashalert_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("media.foxtv.com") >= 0 and u.find("closing") >= 0:
        r = http_get_www(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_worldnow_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("/resources/ftptransfer/") >= 0 and u.find("closing") >= 0:
        r = http_get_www(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_worldnow_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("weather-school-closings") >= 0:
        r = http_get_www(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_arc_school_json(r["json"])
        if parsed != None:
            return parsed
        parsed = parse_arc_school_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    # TownNews HTML is ~370KB and often 301s without a trailing slash. Live GDN
    # does not follow redirects and times out at 4s through a proxy, so skip the
    # page and hit the small BLOX XML feed first (KOAM-closingsC.xml is 83 bytes).
    if looks_like_townnews_url(u):
        tn = try_townnews(u)
        if tn != None:
            return tn

    r = http_get(u)
    code = r["status_code"]
    if code >= 300 and code < 400 and with_www(u) != "":
        # Glance doesn't follow redirects; most bare domains redirect to www.
        u = with_www(u)
        r = http_get(u)
    if r["status_code"] != 200:
        slashed = with_trailing_slash(u)
        if slashed != u:
            r2 = http_get(slashed)
            if r2["status_code"] == 200:
                u = slashed
                r = r2
        if r["status_code"] != 200:
            if looks_like_townnews_url(u):
                tn = try_townnews(u)
                if tn != None:
                    return tn
            # "closings-and-delays" is a TownNews path and also a Nexstar
            # page name (NEWS10, Quad Cities), so try Nexstar either way.
            if looks_like_closings_url(u):
                wp = fetch_nexstar_wp(u)
                if wp != None:
                    return wp
            return {"kind": "unavailable", "rows": []}

    parsed = parse_gsync_json(r["json"])
    if parsed != None:
        return parsed
    parsed = parse_newsticker_xml(r["body"])
    if parsed != None:
        return parsed
    parsed = parse_townnews_xml(r["body"])
    if parsed != None:
        return parsed

    body = r["body"]
    if looks_like_gsync(body):
        api = origin_of(u) + GSYNC_PATH
        g = http_get(api)
        if g["status_code"] == 200:
            parsed = parse_gsync_json(g["json"])
            if parsed != None:
                return parsed
            return {"kind": "unparseable", "rows": []}
        return {"kind": "unavailable", "rows": []}

    if looks_like_newsticker(body):
        xml_url = newsticker_xml_from_html(body)
        if xml_url == "" and u.find(".html") >= 0:
            xml_url = u.replace(".html", ".xml")
        if xml_url != "":
            x = http_get(xml_url)
            if x["status_code"] == 200:
                parsed = parse_newsticker_xml(x["body"])
                if parsed != None:
                    return parsed
        parsed = parse_newsticker_xml(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    k = body.find("npgdigital.com/")
    if k >= 0 and body.find("closings.html", k) > k and body.find("closings.html", k) - k < 40:
        npg = "https://" + body[k:body.find("closings.html", k) + len("closings.html")]
        x = http_get(npg)
        if x["status_code"] == 200:
            parsed = parse_npg_html(x["body"])
            if parsed != None:
                return parsed

    if looks_like_townnews(body):
        got = fetch_townnews(origin_of(u), body, u)
        if got.get("kind", "") != "ok" and got.get("kind", "") != "empty":
            storm = fetch_storm(storm_url(u), now)
            if storm != None:
                return storm
        return got

    if looks_like_nexstar(body) or nexstar_iframe_src(body) != "":
        return fetch_nexstar(u, body)

    if looks_like_nbc(body):
        return fetch_nbc(u, body)

    if looks_like_scripps(body):
        parsed = parse_scripps_html(body)
        if parsed != None:
            return parsed

    if flashalert_src(body) != "" or looks_like_flashalert(body):
        parsed = fetch_flashalert(u, body)
        if parsed != None:
            return parsed

    if worldnow_src(body, u) != "" or looks_like_worldnow(body):
        parsed = fetch_worldnow(u, body)
        if parsed != None:
            return parsed

    if looks_like_tegna(body):
        parsed = parse_tegna_html(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if looks_like_hearst(body):
        parsed = parse_hearst_html(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if looks_like_cbs(body):
        return fetch_cbs(body)

    if looks_like_cox(body):
        parsed = parse_cox_html(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if looks_like_arc_school(body):
        return fetch_arc_school(origin_of(u), body)

    if looks_like_closings_url(u):
        wp = fetch_nexstar_wp(u)
        if wp != None:
            return wp

    return {"kind": "unsupported", "rows": []}


def clip_line(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        cand = t[:k] + ".."
        if c.text_width(cand, font) <= maxw:
            # Don't leave a dangling dash, comma or space before the dots.
            head = t[:k]
            for _ in range(4):
                if head != "" and head[len(head) - 1] in " -,:;/&":
                    head = head[:len(head) - 1]
            if head == "":
                return cand
            return head + ".."
    return ""


def wrap_words(c, text, font, maxw):
    words = str(text).upper().split(" ")
    lines = []
    cur = ""
    for w in words:
        if w == "":
            continue
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            if c.text_width(w, font) <= maxw:
                cur = w
            else:
                lines.append(clip_line(c, w, font, maxw))
                cur = ""
    if cur != "":
        lines.append(cur)
    return lines


def fit_name(c, text, maxw, one_line):
    # One big line if it fits, else two smaller lines, else two clipped 4x5 lines.
    # With a detail line to show, the name stays on one line down to 5x7.
    raw = str(text).upper()
    for font in ["9x12", "8x10", "6x8"]:
        if c.text_width(raw, font) <= maxw:
            return [raw], font
    if one_line and c.text_width(raw, "5x7") <= maxw:
        return [raw], "5x7"
    for font in ["6x8", "5x7"]:
        lines = wrap_words(c, raw, font, maxw)
        if lines != [] and len(lines) <= 2:
            return lines, font
    lines = wrap_words(c, raw, "4x5", maxw)
    if lines == []:
        return [clip_line(c, raw, "4x5", maxw)], "4x5"
    out = []
    for i in range(min(2, len(lines))):
        out.append(lines[i])
    if len(lines) > 2:
        out[1] = clip_line(c, out[1] + " " + lines[2], "4x5", maxw)
    return out, "4x5"


def compact_school(name):
    t = collapse_ws(str(name)).upper()
    pairs = [
        ["HIGH SCHOOL", "HS"],
        ["MIDDLE SCHOOL", "MS"],
        ["ELEMENTARY SCHOOL", "ES"],
        ["JUNIOR HIGH", "JR HI"],
        ["COMMUNITY SCHOOLS", "COMM SCH"],
        ["PUBLIC SCHOOLS", "PUB SCH"],
        ["SCHOOL DISTRICT", "DIST"],
        ["ELEMENTARY", "ELEM"],
        ["COMMUNITY", "COMM"],
        ["TOWNSHIP", "TWP"],
        ["COUNTY", "CO"],
        ["SCHOOLS", "SCH"],
        ["SCHOOL", "SCH"],
        ["DISTRICT", "DIST"],
        ["CENTRAL", "CTRL"],
        ["ENLARGED", "ENL"],
        ["CHRISTIAN", "CHR"],
        ["SAINT ", "ST "],
    ]
    for pair in pairs:
        t = t.replace(pair[0], pair[1])
    return collapse_ws(t)


def fit_small(c, text, maxw):
    t = collapse_ws(str(text)).upper()
    if c.text_width(t, "4x5") > maxw:
        t = compact_school(t)
    return clip_line(c, t, "4x5", maxw)


def kind_label(kind):
    if kind == "closed":
        return "CLOSED"
    if kind == "delay":
        return "DELAYED"
    if kind == "early":
        return "EARLY"
    if kind == "remote":
        return "REMOTE"
    return "OTHER"


def tally(rows):
    counts = {"closed": 0, "delay": 0, "early": 0, "remote": 0, "other": 0}
    for r in rows:
        k = r.get("kind", "other")
        if k not in counts:
            k = "other"
        counts[k] = counts[k] + 1
    out = []
    for k in ["closed", "delay", "early", "remote", "other"]:
        if counts[k] > 0:
            out.append([k, counts[k]])
    return sorted(out, key = lambda g: g[1], reverse = True)


def school_row(st):
    for r in st.get("rows", []):
        if r.get("matched", False):
            return r
    return None


# ---- what kind of place is closed ------------------------------------------

def org_type(row):
    # school / daycare / church / government / business, from the feed's own
    # type when it gives one, else from the name.
    t = (str(row.get("type", "")) + " " + str(row.get("name", ""))).upper()
    w = " " + words_of(t) + " "
    for k in [" DAYCARE ", " DAY CARE ", " CHILD CARE ", " CHILDCARE ", " PRESCHOOL ", " PRE SCHOOL ", " HEAD START ", " NURSERY ", " LEARNING CENTER ", " KIDS ", " PRE K ", " PREK ", " PRE KINDERGARTEN "]:
        if w.find(k) >= 0:
            return "daycare"
    for k in [" SCHOOL ", " SCHOOLS ", " SCH ", " ACADEMY ", " ELEMENTARY ", " ELEM ", " HIGH ", " MIDDLE ", " ISD ", " USD ",
              " DISTRICT ", " DIST ", " COLLEGE ", " UNIVERSITY ", " CSD ", " CAMPUS ", " EDUCATION ", " BOCES ",
              " CENTRAL ", " MONTESSORI ", " PAROCHIAL ", " CHARTER ", " K 12 ", " SEMINARY ", " INSTITUTE ",
              " SD ", " ESD ", " CUSD ", " PS ", " SAU ", " RSU ", " MSAD ", " BOE ", " VO TECH ", " VOCATIONAL "]:
        if w.find(k) >= 0:
            return "school"
    for k in [" CHURCH ", " BAPTIST ", " METHODIST ", " LUTHERAN ", " PARISH ", " MINISTRIES ", " MINISTRY ", " CHAPEL ",
              " TEMPLE ", " SYNAGOGUE ", " MOSQUE ", " PRESBYTERIAN ", " FELLOWSHIP ", " CONGREGATION ", " CATHEDRAL ", " ASSEMBLY OF GOD "]:
        if w.find(k) >= 0:
            return "church"
    for k in [" CITY OF ", " COUNTY ", " CO GOVT ", " GOVERNMENT ", " COURT ", " COURTS ", " LIBRARY ", " CLERK ", " TOWNSHIP ",
              " TOWN OF ", " VILLAGE OF ", " DMV ", " BMV ", " POST OFFICE ", " STATE OFFICES ", " CITY HALL ", " PARKS ", " SENIOR CENTER "]:
        if w.find(k) >= 0:
            return "government"
    return "business"


# ---- where you are: ZIP code -> nearest station ---------------------------------

def none_like(v):
    u = collapse_ws(str(v)).upper()
    return u == "" or u == "NONE" or u == "N/A" or u == "NA" or u == "-"


def cos_deg(d):
    # cos() for latitudes, from its Taylor series (Starlark has no math module).
    x = d * 3.141592653589793 / 180.0
    x2 = x * x
    return 1.0 - x2 / 2.0 + x2 * x2 / 24.0 - x2 * x2 * x2 / 720.0 + x2 * x2 * x2 * x2 / 40320.0


def sqrt(v):
    if v <= 0:
        return 0.0
    g = v if v > 1 else 1.0
    for _ in range(30):
        g = (g + v / g) / 2.0
    return g


def miles_between(la1, lo1, la2, lo2):
    # Straight-line miles (equirectangular), plenty for "which station is nearest".
    k = 3.141592653589793 / 180.0
    x = (lo2 - lo1) * k * cos_deg((la1 + la2) / 2.0)
    y = (la2 - la1) * k
    return 3959.0 * sqrt(x * x + y * y)


def locate_zip(z):
    # [lat, lng, "IN"] for a 5-digit ZIP, or None.
    resp = http.get(ZIP_URL + z, headers = HEADERS, ttl_seconds = ZIP_TTL)
    if resp["status_code"] != 200:
        return None
    data = resp["json"]
    places = (data or {}).get("places") if type(data) == "dict" else None
    if type(places) != "list" or len(places) == 0 or type(places[0]) != "dict":
        return None
    p = places[0]
    la = str(p.get("latitude", ""))
    lo = str(p.get("longitude", ""))
    if la == "" or lo == "":
        return None
    return [float(la), float(lo), str(p.get("state abbreviation", "")).upper()]


def nearest_station(la, lo):
    best = None
    best_d = 0.0
    for s in STATIONS:
        d = miles_between(la, lo, s[3], s[4])
        if best == None or d < best_d:
            best = s
            best_d = d
    return [best, best_d]


def link_label(url):
    # A pasted link shows the station's name when it's one we know, the call
    # sign for a FOX, Sinclair or Nexstar feed, otherwise the web address.
    u = collapse_ws(str(url)).lower()
    for st in STATIONS:
        path = st[5].lower()
        k = path.find("://")
        if k >= 0:
            path = path[k + 3:]
        if path.startswith("www."):
            path = path[4:]
        if path.endswith("/"):
            path = path[:len(path) - 1]
        if u.find(path) >= 0:
            return st[0]
    for needle in ["media.foxtv.com/", "/ftptransfer/", "nexstardigital.net/"]:
        k = u.find(needle)
        if k >= 0:
            rest = u[k + len(needle):]
            slash = rest.find("/")
            if slash >= 3 and slash <= 5:
                return rest[:slash].upper()
    host = host_label(url)
    dot = host.rfind(".")
    if dot > 0:
        return host[:dot]
    return host


def pick_source(ctx):
    # The URL setting wins; otherwise the nearest station to the ZIP code.
    url = _s(ctx, "closingsurl", "NONE")
    if not none_like(url):
        return {"kind": "ok", "url": url, "label": link_label(url), "where": "YOUR STATION LINK"}
    z = digits_only(_s(ctx, "zip", "NONE"))
    if len(z) < 5:
        return {"kind": "nozip"}
    z = z[:5]
    spot = locate_zip(z)
    if spot == None:
        return {"kind": "badzip", "zip": z}
    got = nearest_station(spot[0], spot[1])
    s = got[0]
    mi = int(got[1] + 0.5)
    where = s[1] + ", " + s[2]
    return {
        "kind": "ok",
        "url": "https://www." + s[5] if s[5].find("://") < 0 else s[5],
        "label": s[0],
        "where": where,
        "miles": mi,
        "zip": z,
    }


def load_state(ctx):
    school = school_query(_s(ctx, "school", "NONE"))
    src = pick_source(ctx)
    base = {"school": school, "rows": [], "all": [], "total": 0, "src": src}
    if src["kind"] != "ok":
        base["kind"] = src["kind"]
        return base
    got = fetch_source(src["url"], ctx.now.unix)
    found = got.get("rows", [])
    rows = prefer_school(found, school)
    kind = got.get("kind", "unavailable")
    if kind == "ok" and rows == []:
        kind = "empty"
    base["kind"] = kind
    base["rows"] = rows
    base["all"] = found
    base["total"] = max(len(found), int(got.get("total", 0) or 0))
    return base


# ---- drawing helpers -------------------------------------------------------------

def header(c, word, col, right):
    c.text(word, LEFT, 1, font = "4x5", color = col)
    if right != "":
        room = RIGHT - (LEFT + c.text_width(word, "4x5") + 8)
        c.text(clip_line(c, right, "4x5", room), RIGHT, 1, font = "4x5", color = DIM, align = "right")


def station_name(st):
    src = st.get("src", {})
    name = str(src.get("label", "")).upper()
    if name == "" and src.get("kind", "") == "ok":
        return "YOUR LINK"
    return name


def text_lines(c, text, font, maxw, maxlines):
    lines = wrap_words(c, text, font, maxw)
    if len(lines) > maxlines:
        lines = lines[:maxlines - 1] + [clip_line(c, " ".join(lines[maxlines - 1:]), font, maxw)]
    return lines


def chip(c, text, x_right, y, col, maxw):
    # A status chip, right-aligned, dark text on the status colour; returns its left edge.
    t = clip_line(c, str(text).upper(), "4x5", maxw - 4)
    w = c.text_width(t, "4x5") + 4
    x = x_right - w + 1
    c.rect(x, y, x_right, y + 6, fill = col)
    c.text(t, x + 2, y + 1, font = "4x5", color = INK)
    return x


def hero(c, rows):
    # The bus when schools lead the list, the storefront when businesses do.
    schools = 0
    others = 0
    for r in rows:
        t = org_type(r)
        if t == "school" or t == "daycare":
            schools += 1
        else:
            others += 1
    if others > schools:
        c.sprite(STORE, LEFT, 13, legend = STORE_LEGEND)
    else:
        c.sprite(BUS, LEFT, 13, legend = BUS_LEGEND)


def school_line(c, st, x, y):
    # Your school, and what the station says about it.
    q = st.get("school", "")
    if q == "":
        return False
    r = school_row(st)
    if r == None:
        status = "NOT LISTED"
        col = GREEN
    else:
        status = r["status"]
        col = status_color(r["kind"])
    sw = c.text_width(clip_line(c, status, "4x5", 70), "4x5")
    c.text(clip_line(c, status, "4x5", 70), RIGHT, y, font = "4x5", color = col, align = "right")
    name = q if r == None else r["name"]
    c.text(fit_small(c, name, RIGHT - sw - 6 - x), x, y, font = "4x5", color = CYAN)
    return True


# ---- screens ----------------------------------------------------------------------

def draw_problem(c, st, title, sub):
    header(c, "CLOSINGS", FAIL, station_name(st))
    c.sprite(WARN, LEFT, 12, legend = WARN_LEGEND)
    x = LEFT + 16
    f = "6x8" if c.text_width(title, "6x8") <= RIGHT - x and "'" not in title else "5x7"
    c.text(clip_line(c, title, f, RIGHT - x), x, 9, font = f, color = FAIL)
    lines = text_lines(c, sub, "4x5", RIGHT - x, 2)
    for i in range(len(lines)):
        c.text(lines[i], x, 20 + i * 6, font = "4x5", color = MUTED)


def board_for(c, st):
    kind = st["kind"]
    if kind == "nozip":
        draw_problem(c, st, "ADD YOUR ZIP CODE", "TYPE IT IN THE APP SETTINGS TO FIND YOUR LOCAL STATION")
    elif kind == "badzip":
        draw_problem(c, st, "ZIP CODE NOT FOUND", "CHECK " + st["src"].get("zip", "") + " IN THE APP SETTINGS")
    elif kind == "unavailable":
        draw_problem(c, st, "STATION OFFLINE", "THE CLOSINGS PAGE DID NOT LOAD. TRYING AGAIN SOON")
    elif kind == "unsupported" or kind == "unparseable":
        draw_problem(c, st, "CAN'T READ THIS PAGE", "PASTE A CLOSINGS LINK FROM ANOTHER LOCAL STATION")
    elif kind == "empty" or st["rows"] == []:
        draw_clear(c, st)
    else:
        draw_board(c, st)


def draw_clear(c, st):
    header(c, "CLOSINGS", GREEN, station_name(st))
    c.sprite(BUS, LEFT, 13, legend = BUS_LEGEND)
    c.sprite(CHECK, LEFT + 27, 7, legend = CHECK_LEGEND)
    x = LEFT + 42
    c.text("ALL CLEAR", x, 9, font = "11x14_bold", color = GREEN)
    if not school_line(c, st, x, 26):
        c.text("NO CLOSINGS OR DELAYS", x, 26, font = "4x5", color = MUTED)


def draw_board(c, st):
    found = st.get("all", st["rows"])
    groups = tally(found)
    col = status_color(groups[0][0])
    header(c, "CLOSINGS", col, station_name(st))
    hero(c, found)
    x = LEFT + 33
    num = str(st.get("total", len(found)))
    c.text(num, x, 8, font = "10x16", color = TITLE)
    gx = x + c.text_width(num, "10x16") + 6
    has_school = st.get("school", "") != ""
    lines = 2 if has_school else 3
    for i in range(min(lines, len(groups))):
        g = groups[i]
        y = 9 + i * 7 if not has_school else 8 + i * 8
        label = str(g[1]) + " " + kind_label(g[0])
        c.rect(gx, y + 1, gx + 2, y + 3, fill = status_color(g[0]))
        c.text(clip_line(c, label, "4x5", RIGHT - gx - 6), gx + 6, y, font = "4x5", color = status_color(g[0]))
    if has_school:
        school_line(c, st, x, 26)


def page_rows(st, now):
    # Three closings per refresh; the list rolls on every five minutes so the
    # whole list comes round. A matched school stays at the top.
    rows = st["rows"]
    pinned = [r for r in rows if r.get("matched", False)][:1]
    rest = [r for r in rows if not r.get("matched", False)]
    per = 3 - len(pinned)
    if len(rest) <= per:
        return [pinned + rest, 0, len(rows)]
    # Spread the rows evenly over the pages (13 -> 3,3,3,2,2), so the last
    # page isn't a lone row.
    pages = (len(rest) + per - 1) // per
    k = (now // 300) % pages
    base = len(rest) // pages
    extra = len(rest) % pages
    start = k * base + min(k, extra)
    size = base + (1 if k < extra else 0)
    return [pinned + rest[start:start + size], start, len(rows)]


def draw_list(c, st, now):
    got = page_rows(st, now)
    show = got[0]
    first = got[1] + 1
    n = st.get("total", got[2])
    col = status_color(show[0]["kind"])
    last = min(n, first + len(show) - 1)
    tag = (str(first) if last <= first else str(first) + "-" + str(last)) + " OF " + str(n)
    header(c, "CLOSINGS", col, tag)
    for i in range(len(show)):
        r = show[i]
        y = 8 + i * 8
        icon = ICONS[org_type(r)]
        c.sprite(icon[0], LEFT, y + 1, legend = icon[1])
        cx = chip(c, r["status"], RIGHT, y, status_color(r["kind"]), 62)
        room = cx - 4 - (LEFT + 13)
        name = r["name"]
        if c.text_width(name, "5x7") > room:
            name = compact_school(name)
        c.text(clip_line(c, name, "5x7", room), LEFT + 13, y, font = "5x7", color = CYAN if r.get("matched", False) else TITLE)


def draw_station(c, st):
    # The station the app is watching, and how far it is from you.
    src = st.get("src", {})
    kind = st["kind"]
    header(c, "WATCHING", DIM, "CHECKED EVERY 5 MIN")
    c.sprite(TV, LEFT, 9, legend = TV_LEGEND)
    x = LEFT + 20
    if kind == "nozip" or kind == "badzip":
        c.text("NO STATION YET", x, 9, font = "6x8", color = FAIL)
        tip = "ADD YOUR ZIP CODE IN SETTINGS" if kind == "nozip" else "CHECK YOUR ZIP CODE IN SETTINGS"
        c.text(clip_line(c, tip, "4x5", RIGHT - x), x, 20, font = "4x5", color = MUTED)
        return
    name = station_name(st)
    f = "6x8" if c.text_width(name, "6x8") <= RIGHT - x and "'" not in name else "5x7"
    c.text(clip_line(c, name, f, RIGHT - x), x, 8, font = f, color = TITLE)
    c.text(clip_line(c, str(src.get("where", "")), "4x5", RIGHT - x), x, 18, font = "4x5", color = MUTED)
    if kind == "unavailable":
        line = ["PAGE DID NOT LOAD", FAIL]
    elif kind == "unsupported" or kind == "unparseable":
        line = ["CAN'T READ THIS PAGE", FAIL]
    elif src.get("miles", None) != None:
        mi = src["miles"]
        line = [("UNDER 1 MI" if mi < 1 else str(mi) + " MI") + " FROM " + str(src.get("zip", "")), CYAN]
    else:
        line = ["FROM YOUR LINK", CYAN]
    c.text(clip_line(c, line[0], "4x5", RIGHT - x), x, 25, font = "4x5", color = line[1])


# ---- pages -------------------------------------------------------------------------

def board(c, ctx):
    c.fill(BG)
    board_for(c, load_state(ctx))


def closings(c, ctx):
    c.fill(BG)
    st = load_state(ctx)
    if st["kind"] == "ok" and st["rows"] != []:
        draw_list(c, st, ctx.now.unix)
    else:
        # Nothing to list: show which station is being watched instead of
        # repeating the board.
        draw_station(c, st)
