# Elections - Presidential, U.S. Senate, U.S. House and Governor races for a
# major US city: Kalshi win odds before election day, live results after.
#
# DESIGN. A race is a forecast until votes are counted, and a scoreboard
# after. Every race card is one grammar on a black ground:
#   - chip row (y 0-6): the office as a chip, where the race is beside it
#     (the state, or state + House district, plus "GOP PRIMARY" / "DEM
#     RUNOFF" when it isn't the general election), and the race's status
#     right-aligned: "VOTE NOV 3", "VOTE TODAY", "42% COUNTED",
#     "WINNER CALLED".
#   - content band (y 8-31), one of three layouts:
#       odds       before votes, when Kalshi has a market for the race: the
#                  two front-runners' last names with the Kalshi wordmark
#                  between them as the credit, each one's chance to win as
#                  the hero in party color, and a split bar labelled CHANCE
#                  TO WIN so it can't be mistaken for votes.
#       matchup    before votes, no market (House seats, primaries): last
#                  names are the hero with the party spelled out underneath
#                  - "WILSON / REPUBLICAN  VS  JOHNSON / DEMOCRAT".
#       scoreboard once counting starts: vote share is the hero, the same
#                  split bar, and a green check on the called winner.
# Status is computed once per race (race_status) and dresses the chrome:
# gray chip = election still ahead, amber = voting today / counting, green
# = winner called, so the chip and the words can never disagree. Party red
# and blue only ever mark candidates, never chrome. In a primary both sides
# share a party color, so the runner-up's side of the bar is the dim twin.
# The intro page is the identity: a ballot box, the title, the city, and the
# countdown to the next election.
#
# DATA. civicAPI (civicapi.org/api-documentation) has no zip/address lookup -
# races are only queryable by country and province (US state, e.g. "CA"). So
# the viewer picks a city from a dropdown, and CITIES below maps every choice
# to its state and downtown coordinates.
#
# Every race civicAPI returns with district == null is statewide. Of those,
# only President, U.S. Senate (including specials) and Governor are shown -
# see office_of(); every other statewide office (Lt. Governor, AG, ...) is
# filtered out by choice, not a data gap. Primaries and runoffs come back as
# their own races with the same type ("Governor"), told apart by
# election_type / election_name - see contest_tag().
#
# U.S. House races are district-scoped (civicAPI codes them "WA-01", or
# "WY-AL" for an at-large seat). The free, keyless Census Bureau geocoder
# resolves the city's coordinates to a Congressional District, built back
# into the same "XX-NN" / "XX-AL" shape. The coordinates are downtown / city
# hall, so a city that spans several districts shows its downtown seat. The
# lookup stays live instead of hardcoding district codes so redistricting is
# picked up. State legislature, county and city races are excluded.
#
# The same endpoint doubles as "upcoming" and "results": before election
# night percent_reporting is 0 and candidates show 0 votes; once results
# come in, percent_reporting and each candidate's percent/winner update -
# refetched at most every 30 minutes (ttl_seconds in fetch_races). The query
# starts RESULTS_KEEP_DAYS back so a finished race keeps its result on the
# panel for a week instead of vanishing the morning after.
#
# ODDS. Kalshi's public market data (api.elections.kalshi.com, no key) has a
# "who will win" event per statewide general election with predictable
# tickers - GOVPARTYSC-26, SENATETX-26, SENATEFLS-26 for a special - holding
# one market per candidate, priced 0-1 = the market's chance that candidate
# wins. Only Governor and U.S. Senate have them; House seats, primaries, and
# any race whose event is missing (404) or unreachable fall back to the
# matchup layout.
#
# PAGES. "intro" and "race". A manifest's pages: list is fixed, and can't
# track how many races a city has, so "race" time-multiplexes one race per
# minute (refresh: 60) - see current_index(). At most 3 http.get per render:
# the geocoder, civicAPI, and Kalshi for the one race on screen.

PAD = 10  # SCROLL safe zone: content stays inside x 10-181 on a 192 panel

FONTH = {"10x16": 16, "10x15": 15, "9x12": 12, "7x12": 12, "6x8": 8, "5x7": 7, "5x5": 7, "4x5": 5}

# Last names, biggest first. 8x12 is skipped on purpose: its "-" glyph is a
# solid block, and names like OCASIO-CORTEZ are hyphenated.
NAME_FONTS = ["10x16", "9x12", "7x12", "6x8", "5x7", "4x5"]
SCORE_NAME_FONTS = ["6x8", "5x7", "4x5"]
NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]

# Status chrome - one color per state, used by the chip and its words alike.
FUTURE = "#969696"  # gray: election still ahead
LIVE = "amber"  # voting today, or votes being counted
DONE = "green"  # winner called
RULE = "#505050"  # zone dividers
TRACK = "#282828"  # empty part of the split bar

# Party colors, LED-tuned: the API's own #c6606b / #4874a3 collapse to mud
# on an RGB565 panel. First keyword match wins ("Democratic" -> democrat).
PARTIES = [
    ["republican", "REPUBLICAN", "#FF4B4B"],
    ["democrat", "DEMOCRAT", "#3D8BFF"],
    ["libertarian", "LIBERTARIAN", "#FFC83D"],
    ["green", "GREEN PARTY", "#9BE564"],
    ["independent", "INDEPENDENT", "#C08CFF"],
]
OTHER_PARTY = "#D2D2D2"

# Kalshi's brand green - only ever on its wordmark, the odds credit.
KALSHI_GREEN = "#00DD94"  # from Kalshi-logo-2026.svg
KALSHI_MARK = "Kalshi"  # 5x5 is the one face with lowercase

RESULTS_KEEP_DAYS = 7
MAX_RACES = 6
HEX = "0123456789ABCDEF"

# 7x6 winner check, drawn in DONE green beside the winner's name.
CHECK = [
    [0, 0, 0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0, 1, 1],
    [1, 0, 0, 0, 1, 1, 0],
    [1, 1, 0, 1, 1, 0, 0],
    [0, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 0],
]

# 5x4 check marked on the intro's ballot paper.
BALLOT_MARK = [
    [0, 0, 0, 0, 1],
    [0, 0, 0, 1, 0],
    [1, 0, 1, 0, 0],
    [0, 1, 0, 0, 0],
]

MONTH_ABBR = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# ------------------------------------------------------------------ helpers

def pad(n, width):
    s = str(n)
    for i in range(width):
        if len(s) >= width:
            break
        s = "0" + s
    return s

def num(v):
    # Feed numbers come through here - a string or null where a number
    # belongs counts as 0 instead of raising and killing the render.
    t = type(v)
    if t == "int" or t == "float":
        return v
    return 0

def dollars(v):
    # Kalshi prices arrive as strings ("0.9500"); float() raises on anything
    # that isn't a plain decimal, so check first. None when unusable.
    s = str(v).strip()
    if s == "" or s == "." or s.count(".") > 1:
        return None
    for ch in s.elems():
        if ch not in "0123456789.":
            return None
    return float(s)

def dim_hex(h, pct):
    # "#3D8BFF" scaled to pct% brightness - the dim twin of a party color.
    h = str(h)
    if len(h) != 7 or not h.startswith("#"):
        return h
    out = "#"
    for i in [1, 3, 5]:
        v = int(h[i:i + 2], 16) * pct // 100
        out = out + HEX[v // 16] + HEX[v % 16]
    return out

def days_from_civil(y, m, d):
    # Days since 1970-01-01 for a proleptic Gregorian date (Howard Hinnant's
    # algorithm) - Starlark has no date math.
    if m <= 2:
        y = y - 1
    era = y // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def date_from_days(z):
    # Inverse of days_from_civil, as "YYYY-MM-DD".
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return str(y) + "-" + pad(m, 2) + "-" + pad(d, 2)

def iso_to_unix(s):
    # "2026-11-03T05:00:00.000Z" -> unix seconds, or None if unparseable.
    s = str(s)
    if len(s) < 10 or not (s[0:4].isdigit() and s[5:7].isdigit() and s[8:10].isdigit()):
        return None
    secs = days_from_civil(int(s[0:4]), int(s[5:7].lstrip("0") or "0"), int(s[8:10].lstrip("0") or "0")) * 86400
    if len(s) >= 16 and s[11:13].isdigit() and s[14:16].isdigit():
        secs = secs + int(s[11:13].lstrip("0") or "0") * 3600 + int(s[14:16].lstrip("0") or "0") * 60
    return secs

def short_date(s):
    s = str(s)
    if len(s) < 10 or not (s[5:7].isdigit() and s[8:10].isdigit()):
        return ""
    m = int(s[5:7].lstrip("0") or "0")
    if m < 1 or m > 12:
        return ""
    return MONTH_ABBR[m - 1] + " " + str(int(s[8:10].lstrip("0") or "0"))

def clip(c, text, font, maxw):
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text) - 1, 0, -1):
        t = text[:i].rstrip() + ".."
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def fit_font(c, texts, fonts, maxw):
    # The biggest font every text fits in, so paired names match in size.
    for f in fonts:
        ok = True
        for t in texts:
            if c.text_width(t, f) > maxw:
                ok = False
                break
        if ok:
            return f
    return fonts[-1]

# ---------------------------------------------------------------- location

# Every `city` dropdown choice in manifest.yaml, mapped to its state and
# downtown / city hall coordinates. Each point was checked against the
# Census geocoder to land inside its own state with a congressional
# district. Keys must match the manifest choices exactly.
DEFAULT_CITY = "Miami, Florida"

CITIES = {
    "Birmingham, Alabama": {"state": "AL", "lat": "33.5186", "lon": "-86.8104"},
    "Huntsville, Alabama": {"state": "AL", "lat": "34.7304", "lon": "-86.5861"},
    "Mobile, Alabama": {"state": "AL", "lat": "30.6954", "lon": "-88.0399"},
    "Montgomery, Alabama": {"state": "AL", "lat": "32.3777", "lon": "-86.3006"},
    "Anchorage, Alaska": {"state": "AK", "lat": "61.2181", "lon": "-149.9003"},
    "Fairbanks, Alaska": {"state": "AK", "lat": "64.8378", "lon": "-147.7164"},
    "Juneau, Alaska": {"state": "AK", "lat": "58.3019", "lon": "-134.4197"},
    "Mesa, Arizona": {"state": "AZ", "lat": "33.4152", "lon": "-111.8315"},
    "Phoenix, Arizona": {"state": "AZ", "lat": "33.4484", "lon": "-112.0740"},
    "Tucson, Arizona": {"state": "AZ", "lat": "32.2226", "lon": "-110.9747"},
    "Fayetteville, Arkansas": {"state": "AR", "lat": "36.0626", "lon": "-94.1574"},
    "Fort Smith, Arkansas": {"state": "AR", "lat": "35.3859", "lon": "-94.3985"},
    "Little Rock, Arkansas": {"state": "AR", "lat": "34.7465", "lon": "-92.2896"},
    "Fresno, California": {"state": "CA", "lat": "36.7378", "lon": "-119.7871"},
    "Los Angeles, California": {"state": "CA", "lat": "34.0537", "lon": "-118.2428"},
    "Sacramento, California": {"state": "CA", "lat": "38.5816", "lon": "-121.4944"},
    "San Diego, California": {"state": "CA", "lat": "32.7157", "lon": "-117.1611"},
    "San Francisco, California": {"state": "CA", "lat": "37.7793", "lon": "-122.4193"},
    "San Jose, California": {"state": "CA", "lat": "37.3382", "lon": "-121.8863"},
    "Aurora, Colorado": {"state": "CO", "lat": "39.7294", "lon": "-104.8319"},
    "Colorado Springs, Colorado": {"state": "CO", "lat": "38.8339", "lon": "-104.8214"},
    "Denver, Colorado": {"state": "CO", "lat": "39.7392", "lon": "-104.9903"},
    "Bridgeport, Connecticut": {"state": "CT", "lat": "41.1792", "lon": "-73.1894"},
    "Hartford, Connecticut": {"state": "CT", "lat": "41.7658", "lon": "-72.6734"},
    "New Haven, Connecticut": {"state": "CT", "lat": "41.3083", "lon": "-72.9279"},
    "Stamford, Connecticut": {"state": "CT", "lat": "41.0534", "lon": "-73.5387"},
    "Dover, Delaware": {"state": "DE", "lat": "39.1582", "lon": "-75.5244"},
    "Wilmington, Delaware": {"state": "DE", "lat": "39.7391", "lon": "-75.5398"},
    "Washington, District of Columbia": {"state": "DC", "lat": "38.8951", "lon": "-77.0364"},
    "Jacksonville, Florida": {"state": "FL", "lat": "30.3322", "lon": "-81.6557"},
    "Miami, Florida": {"state": "FL", "lat": "25.7743", "lon": "-80.1937"},
    "Orlando, Florida": {"state": "FL", "lat": "28.5384", "lon": "-81.3789"},
    "Tallahassee, Florida": {"state": "FL", "lat": "30.4383", "lon": "-84.2807"},
    "Tampa, Florida": {"state": "FL", "lat": "27.9506", "lon": "-82.4572"},
    "Atlanta, Georgia": {"state": "GA", "lat": "33.7490", "lon": "-84.3880"},
    "Augusta, Georgia": {"state": "GA", "lat": "33.4735", "lon": "-82.0105"},
    "Columbus, Georgia": {"state": "GA", "lat": "32.4610", "lon": "-84.9877"},
    "Savannah, Georgia": {"state": "GA", "lat": "32.0809", "lon": "-81.0912"},
    "Hilo, Hawaii": {"state": "HI", "lat": "19.7297", "lon": "-155.0900"},
    "Honolulu, Hawaii": {"state": "HI", "lat": "21.3069", "lon": "-157.8583"},
    "Boise, Idaho": {"state": "ID", "lat": "43.6150", "lon": "-116.2023"},
    "Idaho Falls, Idaho": {"state": "ID", "lat": "43.4917", "lon": "-112.0339"},
    "Nampa, Idaho": {"state": "ID", "lat": "43.5407", "lon": "-116.5635"},
    "Aurora, Illinois": {"state": "IL", "lat": "41.7606", "lon": "-88.3201"},
    "Chicago, Illinois": {"state": "IL", "lat": "41.8781", "lon": "-87.6298"},
    "Peoria, Illinois": {"state": "IL", "lat": "40.6936", "lon": "-89.5890"},
    "Rockford, Illinois": {"state": "IL", "lat": "42.2711", "lon": "-89.0940"},
    "Springfield, Illinois": {"state": "IL", "lat": "39.7817", "lon": "-89.6501"},
    "Evansville, Indiana": {"state": "IN", "lat": "37.9716", "lon": "-87.5711"},
    "Fort Wayne, Indiana": {"state": "IN", "lat": "41.0793", "lon": "-85.1394"},
    "Indianapolis, Indiana": {"state": "IN", "lat": "39.7684", "lon": "-86.1581"},
    "South Bend, Indiana": {"state": "IN", "lat": "41.6764", "lon": "-86.2520"},
    "Cedar Rapids, Iowa": {"state": "IA", "lat": "41.9779", "lon": "-91.6656"},
    "Davenport, Iowa": {"state": "IA", "lat": "41.5236", "lon": "-90.5776"},
    "Des Moines, Iowa": {"state": "IA", "lat": "41.5868", "lon": "-93.6250"},
    "Kansas City, Kansas": {"state": "KS", "lat": "39.1142", "lon": "-94.6275"},
    "Overland Park, Kansas": {"state": "KS", "lat": "38.9822", "lon": "-94.6708"},
    "Topeka, Kansas": {"state": "KS", "lat": "39.0473", "lon": "-95.6752"},
    "Wichita, Kansas": {"state": "KS", "lat": "37.6872", "lon": "-97.3301"},
    "Bowling Green, Kentucky": {"state": "KY", "lat": "36.9685", "lon": "-86.4808"},
    "Frankfort, Kentucky": {"state": "KY", "lat": "38.2009", "lon": "-84.8733"},
    "Lexington, Kentucky": {"state": "KY", "lat": "38.0406", "lon": "-84.5037"},
    "Louisville, Kentucky": {"state": "KY", "lat": "38.2527", "lon": "-85.7585"},
    "Baton Rouge, Louisiana": {"state": "LA", "lat": "30.4515", "lon": "-91.1871"},
    "Lafayette, Louisiana": {"state": "LA", "lat": "30.2241", "lon": "-92.0198"},
    "New Orleans, Louisiana": {"state": "LA", "lat": "29.9511", "lon": "-90.0715"},
    "Shreveport, Louisiana": {"state": "LA", "lat": "32.5252", "lon": "-93.7502"},
    "Augusta, Maine": {"state": "ME", "lat": "44.3106", "lon": "-69.7795"},
    "Bangor, Maine": {"state": "ME", "lat": "44.8016", "lon": "-68.7712"},
    "Portland, Maine": {"state": "ME", "lat": "43.6591", "lon": "-70.2568"},
    "Annapolis, Maryland": {"state": "MD", "lat": "38.9784", "lon": "-76.4922"},
    "Baltimore, Maryland": {"state": "MD", "lat": "39.2904", "lon": "-76.6122"},
    "Frederick, Maryland": {"state": "MD", "lat": "39.4143", "lon": "-77.4105"},
    "Boston, Massachusetts": {"state": "MA", "lat": "42.3601", "lon": "-71.0589"},
    "Springfield, Massachusetts": {"state": "MA", "lat": "42.1015", "lon": "-72.5898"},
    "Worcester, Massachusetts": {"state": "MA", "lat": "42.2626", "lon": "-71.8023"},
    "Ann Arbor, Michigan": {"state": "MI", "lat": "42.2808", "lon": "-83.7430"},
    "Detroit, Michigan": {"state": "MI", "lat": "42.3314", "lon": "-83.0458"},
    "Grand Rapids, Michigan": {"state": "MI", "lat": "42.9634", "lon": "-85.6681"},
    "Lansing, Michigan": {"state": "MI", "lat": "42.7325", "lon": "-84.5555"},
    "Duluth, Minnesota": {"state": "MN", "lat": "46.7867", "lon": "-92.1005"},
    "Minneapolis, Minnesota": {"state": "MN", "lat": "44.9778", "lon": "-93.2650"},
    "Rochester, Minnesota": {"state": "MN", "lat": "44.0121", "lon": "-92.4802"},
    "Saint Paul, Minnesota": {"state": "MN", "lat": "44.9537", "lon": "-93.0900"},
    "Gulfport, Mississippi": {"state": "MS", "lat": "30.3674", "lon": "-89.0928"},
    "Hattiesburg, Mississippi": {"state": "MS", "lat": "31.3271", "lon": "-89.2903"},
    "Jackson, Mississippi": {"state": "MS", "lat": "32.2988", "lon": "-90.1848"},
    "Jefferson City, Missouri": {"state": "MO", "lat": "38.5767", "lon": "-92.1735"},
    "Kansas City, Missouri": {"state": "MO", "lat": "39.0997", "lon": "-94.5786"},
    "Saint Louis, Missouri": {"state": "MO", "lat": "38.6270", "lon": "-90.1994"},
    "Springfield, Missouri": {"state": "MO", "lat": "37.2090", "lon": "-93.2923"},
    "Billings, Montana": {"state": "MT", "lat": "45.7833", "lon": "-108.5007"},
    "Bozeman, Montana": {"state": "MT", "lat": "45.6770", "lon": "-111.0429"},
    "Helena, Montana": {"state": "MT", "lat": "46.5891", "lon": "-112.0391"},
    "Missoula, Montana": {"state": "MT", "lat": "46.8721", "lon": "-113.9940"},
    "Grand Island, Nebraska": {"state": "NE", "lat": "40.9264", "lon": "-98.3420"},
    "Lincoln, Nebraska": {"state": "NE", "lat": "40.8136", "lon": "-96.7026"},
    "Omaha, Nebraska": {"state": "NE", "lat": "41.2565", "lon": "-95.9345"},
    "Carson City, Nevada": {"state": "NV", "lat": "39.1638", "lon": "-119.7674"},
    "Las Vegas, Nevada": {"state": "NV", "lat": "36.1699", "lon": "-115.1398"},
    "Reno, Nevada": {"state": "NV", "lat": "39.5296", "lon": "-119.8138"},
    "Concord, New Hampshire": {"state": "NH", "lat": "43.2081", "lon": "-71.5376"},
    "Manchester, New Hampshire": {"state": "NH", "lat": "42.9956", "lon": "-71.4548"},
    "Nashua, New Hampshire": {"state": "NH", "lat": "42.7654", "lon": "-71.4676"},
    "Atlantic City, New Jersey": {"state": "NJ", "lat": "39.3643", "lon": "-74.4229"},
    "Jersey City, New Jersey": {"state": "NJ", "lat": "40.7178", "lon": "-74.0431"},
    "Newark, New Jersey": {"state": "NJ", "lat": "40.7357", "lon": "-74.1724"},
    "Trenton, New Jersey": {"state": "NJ", "lat": "40.2206", "lon": "-74.7597"},
    "Albuquerque, New Mexico": {"state": "NM", "lat": "35.0844", "lon": "-106.6504"},
    "Las Cruces, New Mexico": {"state": "NM", "lat": "32.3199", "lon": "-106.7637"},
    "Santa Fe, New Mexico": {"state": "NM", "lat": "35.6870", "lon": "-105.9378"},
    "Albany, New York": {"state": "NY", "lat": "42.6526", "lon": "-73.7562"},
    "Buffalo, New York": {"state": "NY", "lat": "42.8864", "lon": "-78.8784"},
    "New York City, New York": {"state": "NY", "lat": "40.7128", "lon": "-74.0060"},
    "Rochester, New York": {"state": "NY", "lat": "43.1566", "lon": "-77.6088"},
    "Syracuse, New York": {"state": "NY", "lat": "43.0481", "lon": "-76.1474"},
    "Asheville, North Carolina": {"state": "NC", "lat": "35.5951", "lon": "-82.5515"},
    "Charlotte, North Carolina": {"state": "NC", "lat": "35.2271", "lon": "-80.8431"},
    "Durham, North Carolina": {"state": "NC", "lat": "35.9940", "lon": "-78.8986"},
    "Greensboro, North Carolina": {"state": "NC", "lat": "36.0726", "lon": "-79.7920"},
    "Raleigh, North Carolina": {"state": "NC", "lat": "35.7796", "lon": "-78.6382"},
    "Bismarck, North Dakota": {"state": "ND", "lat": "46.8083", "lon": "-100.7837"},
    "Fargo, North Dakota": {"state": "ND", "lat": "46.8772", "lon": "-96.7898"},
    "Grand Forks, North Dakota": {"state": "ND", "lat": "47.9253", "lon": "-97.0329"},
    "Akron, Ohio": {"state": "OH", "lat": "41.0814", "lon": "-81.5190"},
    "Cincinnati, Ohio": {"state": "OH", "lat": "39.1031", "lon": "-84.5120"},
    "Cleveland, Ohio": {"state": "OH", "lat": "41.4993", "lon": "-81.6944"},
    "Columbus, Ohio": {"state": "OH", "lat": "39.9612", "lon": "-82.9988"},
    "Dayton, Ohio": {"state": "OH", "lat": "39.7589", "lon": "-84.1916"},
    "Toledo, Ohio": {"state": "OH", "lat": "41.6528", "lon": "-83.5379"},
    "Norman, Oklahoma": {"state": "OK", "lat": "35.2226", "lon": "-97.4395"},
    "Oklahoma City, Oklahoma": {"state": "OK", "lat": "35.4676", "lon": "-97.5164"},
    "Tulsa, Oklahoma": {"state": "OK", "lat": "36.1540", "lon": "-95.9928"},
    "Bend, Oregon": {"state": "OR", "lat": "44.0582", "lon": "-121.3153"},
    "Eugene, Oregon": {"state": "OR", "lat": "44.0521", "lon": "-123.0868"},
    "Portland, Oregon": {"state": "OR", "lat": "45.5152", "lon": "-122.6784"},
    "Salem, Oregon": {"state": "OR", "lat": "44.9429", "lon": "-123.0351"},
    "Allentown, Pennsylvania": {"state": "PA", "lat": "40.6084", "lon": "-75.4902"},
    "Erie, Pennsylvania": {"state": "PA", "lat": "42.1292", "lon": "-80.0851"},
    "Harrisburg, Pennsylvania": {"state": "PA", "lat": "40.2732", "lon": "-76.8867"},
    "Philadelphia, Pennsylvania": {"state": "PA", "lat": "39.9526", "lon": "-75.1652"},
    "Pittsburgh, Pennsylvania": {"state": "PA", "lat": "40.4406", "lon": "-79.9959"},
    "Newport, Rhode Island": {"state": "RI", "lat": "41.4901", "lon": "-71.3128"},
    "Providence, Rhode Island": {"state": "RI", "lat": "41.8240", "lon": "-71.4128"},
    "Warwick, Rhode Island": {"state": "RI", "lat": "41.7001", "lon": "-71.4162"},
    "Charleston, South Carolina": {"state": "SC", "lat": "32.7765", "lon": "-79.9311"},
    "Columbia, South Carolina": {"state": "SC", "lat": "34.0007", "lon": "-81.0348"},
    "Greenville, South Carolina": {"state": "SC", "lat": "34.8526", "lon": "-82.3940"},
    "Myrtle Beach, South Carolina": {"state": "SC", "lat": "33.6891", "lon": "-78.8867"},
    "Pierre, South Dakota": {"state": "SD", "lat": "44.3683", "lon": "-100.3510"},
    "Rapid City, South Dakota": {"state": "SD", "lat": "44.0805", "lon": "-103.2310"},
    "Sioux Falls, South Dakota": {"state": "SD", "lat": "43.5446", "lon": "-96.7311"},
    "Chattanooga, Tennessee": {"state": "TN", "lat": "35.0456", "lon": "-85.3097"},
    "Knoxville, Tennessee": {"state": "TN", "lat": "35.9606", "lon": "-83.9207"},
    "Memphis, Tennessee": {"state": "TN", "lat": "35.1495", "lon": "-90.0490"},
    "Nashville, Tennessee": {"state": "TN", "lat": "36.1627", "lon": "-86.7816"},
    "Austin, Texas": {"state": "TX", "lat": "30.2672", "lon": "-97.7431"},
    "Dallas, Texas": {"state": "TX", "lat": "32.7767", "lon": "-96.7970"},
    "El Paso, Texas": {"state": "TX", "lat": "31.7619", "lon": "-106.4850"},
    "Fort Worth, Texas": {"state": "TX", "lat": "32.7555", "lon": "-97.3308"},
    "Houston, Texas": {"state": "TX", "lat": "29.7604", "lon": "-95.3698"},
    "San Antonio, Texas": {"state": "TX", "lat": "29.4241", "lon": "-98.4936"},
    "Ogden, Utah": {"state": "UT", "lat": "41.2230", "lon": "-111.9738"},
    "Provo, Utah": {"state": "UT", "lat": "40.2338", "lon": "-111.6585"},
    "Saint George, Utah": {"state": "UT", "lat": "37.0965", "lon": "-113.5684"},
    "Salt Lake City, Utah": {"state": "UT", "lat": "40.7608", "lon": "-111.8910"},
    "Burlington, Vermont": {"state": "VT", "lat": "44.4759", "lon": "-73.2121"},
    "Montpelier, Vermont": {"state": "VT", "lat": "44.2601", "lon": "-72.5754"},
    "Rutland, Vermont": {"state": "VT", "lat": "43.6106", "lon": "-72.9726"},
    "Arlington, Virginia": {"state": "VA", "lat": "38.8816", "lon": "-77.0910"},
    "Norfolk, Virginia": {"state": "VA", "lat": "36.8508", "lon": "-76.2859"},
    "Richmond, Virginia": {"state": "VA", "lat": "37.5407", "lon": "-77.4360"},
    "Roanoke, Virginia": {"state": "VA", "lat": "37.2710", "lon": "-79.9414"},
    "Virginia Beach, Virginia": {"state": "VA", "lat": "36.8529", "lon": "-75.9780"},
    "Olympia, Washington": {"state": "WA", "lat": "47.0379", "lon": "-122.9007"},
    "Seattle, Washington": {"state": "WA", "lat": "47.6062", "lon": "-122.3321"},
    "Spokane, Washington": {"state": "WA", "lat": "47.6588", "lon": "-117.4260"},
    "Tacoma, Washington": {"state": "WA", "lat": "47.2529", "lon": "-122.4443"},
    "Vancouver, Washington": {"state": "WA", "lat": "45.6387", "lon": "-122.6615"},
    "Charleston, West Virginia": {"state": "WV", "lat": "38.3498", "lon": "-81.6326"},
    "Huntington, West Virginia": {"state": "WV", "lat": "38.4192", "lon": "-82.4452"},
    "Morgantown, West Virginia": {"state": "WV", "lat": "39.6295", "lon": "-79.9559"},
    "Green Bay, Wisconsin": {"state": "WI", "lat": "44.5133", "lon": "-88.0133"},
    "Madison, Wisconsin": {"state": "WI", "lat": "43.0731", "lon": "-89.4012"},
    "Milwaukee, Wisconsin": {"state": "WI", "lat": "43.0389", "lon": "-87.9065"},
    "Casper, Wyoming": {"state": "WY", "lat": "42.8666", "lon": "-106.3131"},
    "Cheyenne, Wyoming": {"state": "WY", "lat": "41.1400", "lon": "-104.8202"},
    "Laramie, Wyoming": {"state": "WY", "lat": "41.3114", "lon": "-105.5911"},
}

def resolve_city(ctx):
    name = str(ctx.inputs.get("city", DEFAULT_CITY))
    if name not in CITIES:
        name = DEFAULT_CITY
    c = CITIES[name]
    parts = name.split(", ")
    return {
        "name": name,
        "city": parts[0].upper(),
        "state_name": parts[-1].upper(),
        "state": c["state"],
        "lat": c["lat"],
        "lon": c["lon"],
    }

def city_label(geo):
    return geo["city"] + ", " + geo["state"]

# -------------------------------------------------------------------- data

def fetch_congress_geo(lat, lon):
    return http.get(
        "https://geocoding.geo.census.gov/geocoder/geographies/coordinates",
        params = {
            "x": lon,
            "y": lat,
            "benchmark": "Public_AR_Current",
            "vintage": "Current_Current",
            "layers": "Congressional Districts",
            "format": "json",
        },
        ttl_seconds = 2592000,
    )

def congress_district_code(state, lat, lon):
    # The layer key is named after the current Congress (e.g. "119th
    # Congressional Districts") and rolls over every two years, so match on
    # the stable substring instead of a hardcoded ordinal.
    resp = fetch_congress_geo(lat, lon)
    if resp["status_code"] != 200:
        return None
    geos = ((resp["json"] or {}).get("result", {}) or {}).get("geographies", {})
    for key in geos:
        if "Congressional District" not in key:
            continue
        entries = geos[key]
        if len(entries) == 0:
            continue
        basename = str(entries[0].get("BASENAME", "")).strip()
        if "arge" in basename:
            return state + "-AL"
        if basename.isdigit():
            return state + "-" + pad(int(basename.lstrip("0") or "0"), 2)
        return None
    return None

def fetch_races(state, start_date):
    # civicAPI's own ordering is NOT priority-sorted - a busy state like TX
    # returns 300+ races (mostly county judges/clerks), and its one federal
    # US Senate race can sit past index 250. A small limit silently drops
    # marquee races before this app's own sort ever sees them. 2000 stays
    # safely under the host's 2MB response cap (TX's full ~300-race payload
    # is ~150KB) while covering every state's real race count.
    return http.get(
        "https://civicapi.org/api/v2/race/search",
        params = {
            "country": "US",
            "province": state,
            "startDate": start_date,
            "limit": 2000,
        },
        ttl_seconds = 1800,
    )

def office_of(race_type):
    # civicAPI's type strings vary ("US Senate", "U.S. Senate", "US Senate
    # Special", "House of Representatives") - fold them onto the chip label,
    # or None for an office this app doesn't show.
    t = str(race_type).lower().replace(".", "")
    if t.startswith("president"):
        return "PRESIDENT"
    if t.startswith("us senate"):
        return "U.S. SENATE"
    if t.startswith("us house") or t == "house of representatives":
        return "U.S. HOUSE"
    if t.startswith("governor"):
        return "GOVERNOR"
    return None

def contest_tag(race):
    # "" for a general election, else which party's primary or runoff it is:
    # "South Carolina Governor Republican Runoff" -> "GOP RUNOFF".
    kind = str(race.get("election_type", "")).lower()
    name = str(race.get("election_name", "")).lower()
    if "runoff" in kind or "runoff" in name:
        word = "RUNOFF"
    elif "primary" in kind or "primary" in name:
        word = "PRIMARY"
    else:
        return ""
    if "republican" in name:
        return "GOP " + word
    if "democrat" in name:
        return "DEM " + word
    if "open" in name or "top two" in name or "nonpartisan" in name:
        return "OPEN " + word
    return word

PRIORITY = {"PRESIDENT": 0, "U.S. SENATE": 1, "U.S. HOUSE": 2, "GOVERNOR": 3}

def relevant_races(races, district_code):
    out = []
    for r in races:
        if office_of(r.get("type", "")) == None:
            continue
        d = r.get("district", None)
        if d == None or (district_code != None and d == district_code):
            out.append(r)
    return out

def sort_races(races):
    # Soonest election first, then by office, then id for a stable order.
    return sorted(races, key = lambda r: (
        str(r.get("election_date", "9999-99-99"))[:10] + "_" +
        pad(PRIORITY.get(office_of(r.get("type", "")), 9), 2) + "_" +
        pad(num(r.get("id", 0)), 10)
    ))

def load_races(ctx, geo):
    start = date_from_days(ctx.now.unix // 86400 - RESULTS_KEEP_DAYS)
    district_code = congress_district_code(geo["state"], geo["lat"], geo["lon"])
    resp = fetch_races(geo["state"], start)
    if resp["status_code"] != 200:
        return (None, "races")
    races = (resp["json"] or {}).get("races", []) or []
    return (sort_races(relevant_races(races, district_code)), None)

# -------------------------------------------------------------------- odds

def kalshi_ticker(race, geo):
    # Kalshi event ticker for a general election, or None when Kalshi has no
    # series for this kind of race.
    if contest_tag(race) != "":
        return None
    year = str(race.get("election_date", ""))[2:4]
    if not year.isdigit():
        return None
    office = office_of(race.get("type", ""))
    if office == "GOVERNOR":
        return "GOVPARTY" + geo["state"] + "-" + year
    if office == "U.S. SENATE":
        special = "special" in str(race.get("type", "")).lower()
        return "SENATE" + geo["state"] + ("S" if special else "") + "-" + year
    return None

def fetch_kalshi_event(ticker):
    # Odds drift through the day, not by the minute - a 15 minute cache.
    return http.get(
        "https://api.elections.kalshi.com/trade-api/v2/events/" + ticker,
        params = {"with_nested_markets": "true"},
        headers = {"User-Agent": "glance-election-tracker"},
        ttl_seconds = 900,
    )

def market_chance(m):
    # 0-100 chance from one market: the bid/ask midpoint while the spread is
    # tight, else the last trade.
    bid = dollars(m.get("yes_bid_dollars", ""))
    ask = dollars(m.get("yes_ask_dollars", ""))
    if bid != None and ask != None and ask > 0 and ask - bid <= 0.1:
        return (bid + ask) * 50.0
    last = dollars(m.get("last_price_dollars", ""))
    if last != None and last > 0:
        return last * 100.0
    return None

def odds_row(who, suffix, chance, cands):
    # Kalshi names the candidate ("Alan Wilson"), or the party ("Republican
    # party") while the nominee is still undecided. The party comes from the
    # matching civicAPI candidate, else the market ticker's R / D suffix; any
    # other suffix (RBEN, DOSB) is an independent.
    w = who.lower()
    name = "TBD" if ("party" in w or w.strip() == "") else last_name(who)
    party = None
    color = None
    for r in cands:
        if name != "TBD" and r["name"] == name:
            party = r["party"]
            color = r["color"]
    if party == None:
        if suffix == "R" or "republican" in w:
            party, color = party_style("Republican")
        elif suffix == "D" or "democrat" in w:
            party, color = party_style("Democratic")
        else:
            party, color = party_style("Independent")
    if name == "TBD":
        for r in cands:
            if r["party"] == party and r["name"] != "TBD":
                name = r["name"]
    return {"name": name, "party": party, "color": color, "pct": chance, "winner": False}

def kalshi_odds(race, geo, cands):
    # The two front-runners, shaped like candidate_rows() with pct = chance
    # to win - or None, and the card falls back to the matchup layout.
    ticker = kalshi_ticker(race, geo)
    if ticker == None:
        return None
    resp = fetch_kalshi_event(ticker)
    if resp["status_code"] != 200:
        return None
    body = resp["json"] or {}
    markets = (body.get("event", {}) or {}).get("markets", None) or body.get("markets", []) or []
    rows = []
    for m in markets:
        if str(m.get("status", "")) != "active":
            continue
        chance = market_chance(m)
        if chance == None:
            continue
        suffix = str(m.get("ticker", "")).split("-")[-1]
        rows.append(odds_row(str(m.get("yes_sub_title", "") or ""), suffix, chance, cands))
    if len(rows) < 2:
        return None
    return sorted(rows, key = lambda r: -r["pct"])[:2]

# ------------------------------------------------------------------ status

def race_status(race, now_unix):
    # Computed once per race so the chip color and its words can't disagree.
    winner = False
    votes = False
    for cand in race.get("candidates", []) or []:
        if cand.get("winner", False) == True:
            winner = True
        if num(cand.get("votes", 0)) > 0:
            votes = True
    reporting = num(race.get("percent_reporting", 0))

    if winner:
        return {"key": "called", "meta": "WINNER CALLED", "short": "CALLED", "color": DONE, "ink": DONE}
    if reporting > 0 or votes:
        meta = "COUNTING" if reporting < 1 else str(int(reporting)) + "% COUNTED"
        short = "COUNTING" if reporting < 1 else str(int(reporting)) + "% IN"
        return {"key": "counting", "meta": meta, "short": short, "color": LIVE, "ink": LIVE, "reporting": reporting}

    start = iso_to_unix(race.get("election_date", ""))
    if start == None:
        return {"key": "upcoming", "meta": "DATE TBD", "short": "TBD", "color": FUTURE, "ink": "white", "days": None}
    if now_unix < start:
        days = (start - now_unix + 86399) // 86400
        meta = "VOTE " + short_date(race.get("election_date", ""))
        return {"key": "upcoming", "meta": meta, "short": short_date(race.get("election_date", "")), "color": FUTURE, "ink": "white", "days": days}
    if now_unix < start + 86400:
        return {"key": "today", "meta": "VOTE TODAY", "short": "TODAY", "color": LIVE, "ink": LIVE}
    return {"key": "waiting", "meta": "RESULTS SOON", "short": "SOON", "color": LIVE, "ink": LIVE}

def party_style(party):
    p = str(party).lower()
    for entry in PARTIES:
        if entry[0] in p:
            return entry[1], entry[2]
    label = str(party).upper().strip()
    return (label if label != "" else "CANDIDATE"), OTHER_PARTY

SUFFIXES = ["JR", "JR.", "SR", "SR.", "II", "III", "IV"]
PARTICLES = ["DE", "DEL", "DELLA", "LA", "LE", "DA", "DI", "DU", "VAN", "VON", "ST", "ST."]

def last_name(full):
    # "Maria Elvira Salazar" -> SALAZAR, "Bobby Scott Jr." -> SCOTT,
    # "Republican nominee" (primary not decided yet) -> TBD.
    s = str(full).strip()
    if s == "" or "nominee" in s.lower() or s.lower() == "tbd":
        return "TBD"
    words = s.upper().replace(",", " ").split()
    for _ in range(2):
        if len(words) > 1 and words[-1] in SUFFIXES:
            words = words[:-1]
    name = words[-1]
    for i in range(2, 4):
        if len(words) > i and words[-i] in PARTICLES:
            name = words[-i] + " " + name
        else:
            break
    return name

def candidate_rows(race, by_share):
    rows = []
    for cand in race.get("candidates", []) or []:
        label, color = party_style(cand.get("party", ""))
        pct = num(cand.get("percent", 0))
        rows.append({
            "name": last_name(cand.get("name", "")),
            "party": label,
            "color": color,
            "pct": 0 if pct < 0 else (100 if pct > 100 else pct),
            "winner": cand.get("winner", False) == True,
        })
    if by_share:
        rows = sorted(rows, key = lambda r: -r["pct"])
    return rows

def where_labels(race, geo):
    # Longest first; the chip row uses the first that fits beside the status.
    # The last resort drops the place - which contest it is matters more.
    tag = contest_tag(race)
    kind = ""
    if tag != "":
        kind = " " + tag
    elif "special" in str(race.get("type", "")).lower():
        kind = " SPECIAL"
    st = geo["state"]
    if office_of(race.get("type", "")) == "U.S. HOUSE":
        seat = str(race.get("district", "") or "").split("-")[-1]
        if seat == "AL":
            labels = [st + " AT-LARGE" + kind, st + "-AL" + kind]
        elif seat.isdigit():
            n = str(int(seat.lstrip("0") or "0"))
            labels = [st + " DISTRICT " + n + kind, st + "-" + n + kind]
        else:
            labels = [st + kind]
    else:
        labels = [geo["state_name"] + kind, st + kind]
    labels.append(tag if tag != "" else st)
    return labels

# ----------------------------------------------------------------- drawing

def zone_boxes(c, k):
    # k equal zones inside the safe zone, 7px gutters (3 gap, 1 rule, 3 gap).
    gutter = 7
    inner = c.width - 2 * PAD
    zw = (inner - (k - 1) * gutter) // k
    x = PAD + (inner - (k * zw + (k - 1) * gutter)) // 2
    return [x + i * (zw + gutter) for i in range(k)], zw

def zone_rules(c, boxes, y0, y1):
    for i in range(1, len(boxes)):
        c.line(boxes[i] - 4, y0, boxes[i] - 4, y1, RULE)

def draw_chip_row(c, race, status, geo):
    # The status is measured first and the location gets what's left. When
    # even the shortest location won't fit beside the full status ("SC DEM
    # PRIMARY" beside "WINNER CALLED" under a U.S. SENATE chip, which clipped
    # to "DEM PRIMAR.."), the status drops to its short form ("CALLED") before
    # the location is clipped.
    right = c.width - PAD
    x = PAD + c.badge(office_of(race.get("type", "")), PAD, 0, color = "black", bg = status["color"], font = "4x5")
    labels = where_labels(race, geo)
    where = None
    meta = status["meta"]
    room = 0
    for m in [status["meta"], status.get("short", status["meta"])]:
        meta = m
        room = right - c.text_width(m, "4x5") - 6 - (x + 3)
        for label in labels:
            if c.text_width(label, "4x5") <= room:
                where = label
                break
        if where != None:
            break
    if where == None:
        where = clip(c, labels[-1], "4x5", room)
    c.text(meta, right, 1, font = "4x5", color = status["ink"], align = "right")
    c.text(where, x + 3, 1, font = "4x5", color = "white")

def split_bar(c, x0, x1, y0, y1, lpct, rpct, lcolor, rcolor):
    # Each side fills from its own end by its share; the gap between is
    # everyone else (or undecided), and a white tick marks 50%.
    bw = x1 - x0 + 1
    c.rect(x0, y0, x1, y1, fill = TRACK)
    ln = int(bw * lpct / 100.0 + 0.5)
    rn = int(bw * rpct / 100.0 + 0.5)
    if ln > bw:
        ln = bw
    if ln + rn > bw:
        rn = bw - ln
    if ln > 0:
        c.rect(x0, y0, x0 + ln - 1, y1, fill = lcolor)
    if rn > 0:
        c.rect(x1 - rn + 1, y0, x1, y1, fill = rcolor)
    tick = x0 + bw // 2
    c.line(tick, y0 - 1, tick, y1 + 1, "white")

def pair_colors(left, right):
    # Same party on both sides (a primary): the runner-up's side of the bar
    # gets the dim twin. The numbers keep full color - a dimmed 10% was hard
    # to read.
    if left["color"] == right["color"]:
        return left["color"], dim_hex(right["color"], 55)
    return left["color"], right["color"]

def draw_matchup(c, rows):
    # Before votes: last names are the hero, party spelled out beneath.
    n = len(rows)
    if n == 0:
        c.text("CANDIDATES NOT SET", c.width // 2, 16, font = "5x7", color = "gray", align = "center")
        return
    if n == 2:
        mid = c.width // 2
        vs_w = c.text_width("VS", "vs")

        # Each name gets its half up to a 3px gap either side of the VS.
        maxw = mid - vs_w // 2 - 4 - PAD
        f = fit_font(c, [rows[0]["name"], rows[1]["name"]], NAME_FONTS, maxw)
        ny = 9 + (16 - FONTH[f]) // 2
        c.text(clip(c, rows[0]["name"], f, maxw), PAD, ny, font = f, color = "white")
        c.text(clip(c, rows[1]["name"], f, maxw), c.width - PAD, ny, font = f, color = "white", align = "right")
        c.text("VS", mid, 15, font = "vs", color = "gray", align = "center")
        c.text(clip(c, rows[0]["party"], "4x5", maxw), PAD, 26, font = "4x5", color = rows[0]["color"])
        c.text(clip(c, rows[1]["party"], "4x5", maxw), c.width - PAD, 26, font = "4x5", color = rows[1]["color"], align = "right")
        return

    # One candidate, or three or more: equal zones. Past three, the third
    # zone becomes an explicit "+N MORE" count.
    shown = rows[:3] if n <= 3 else rows[:2]
    extra = n - len(shown)
    boxes, zw = zone_boxes(c, len(shown) + (1 if extra > 0 else 0))
    f = fit_font(c, [r["name"] for r in shown], NAME_FONTS, zw)
    ny = 9 + (16 - FONTH[f]) // 2
    for i, r in enumerate(shown):
        cx = boxes[i] + zw // 2
        party = r["party"] + (" - UNOPPOSED" if n == 1 else "")
        c.text(clip(c, r["name"], f, zw), cx, ny, font = f, color = "white", align = "center")
        c.text(clip(c, party, "4x5", zw), cx, 26, font = "4x5", color = r["color"], align = "center")
    if extra > 0:
        cx = boxes[2] + zw // 2
        c.text("+" + str(extra), cx, 9, font = "10x16", color = "white", align = "center")
        c.text("MORE", cx, 26, font = "4x5", color = "gray", align = "center")
    zone_rules(c, boxes, 9, 30)

def pct_text(p):
    return str(int(p + 0.5)) + "%"

def chance_text(p):
    # A market is never certain: the label stays inside 1-99%.
    v = int(p + 0.5)
    if v < 1:
        v = 1
    if v > 99:
        v = 99
    return str(v) + "%"

def draw_kalshi_mark(c, cx, y):
    # The odds credit: Kalshi's wordmark in its brand green.
    w = c.text_width(KALSHI_MARK, "5x5")
    c.text(KALSHI_MARK, cx - w // 2, y, font = "5x5", color = KALSHI_GREEN)

def draw_odds(c, rows):
    # Before votes, with a Kalshi market: chance to win is the hero.
    left = rows[0]
    right = rows[1]
    lcolor, rcolor = pair_colors(left, right)
    rx = c.width - PAD
    mid = c.width // 2

    # Names row, with the wordmark centered between them.
    half = mid - PAD - c.text_width(KALSHI_MARK, "5x5") // 2 - 4
    nf = fit_font(c, [left["name"], right["name"]], SCORE_NAME_FONTS, half)
    ny = 8 + (8 - FONTH[nf]) // 2
    c.text(clip(c, left["name"], nf, half), PAD, ny, font = nf, color = "white")
    c.text(clip(c, right["name"], nf, half), rx, ny, font = nf, color = "white", align = "right")
    draw_kalshi_mark(c, mid, 8)

    lp = chance_text(left["pct"])
    rp = chance_text(right["pct"])
    c.text(lp, PAD, 17, font = "10x15", color = left["color"])
    c.text(rp, rx, 17, font = "10x15", color = right["color"], align = "right")

    # Between the two numbers: the label on top, the bar under it with a
    # 1px row free above its tick (label y 18-22, tick from 24).
    bx0 = PAD + c.text_width(lp, "10x15") + 5
    bx1 = rx - c.text_width(rp, "10x15") - 5
    c.text("CHANCE TO WIN", (bx0 + bx1) // 2, 18, font = "4x5", color = "gray", align = "center")
    split_bar(c, bx0, bx1, 25, 29, left["pct"], right["pct"], lcolor, rcolor)

def draw_name_check(c, name, font, x, y, winner, align):
    # Name with the green winner check on its inner side.
    w = c.text_width(name, font)
    if align == "left":
        c.text(name, x, y, font = font, color = "white")
        if winner:
            c.bitmap(CHECK, x + w + 2, 9, DONE)
    elif align == "right":
        c.text(name, x, y, font = font, color = "white", align = "right")
        if winner:
            c.bitmap(CHECK, x - w - 2 - 7, 9, DONE)
    else:
        total = w + (9 if winner else 0)
        left = x - total // 2
        c.text(name, left, y, font = font, color = "white")
        if winner:
            c.bitmap(CHECK, left + w + 2, 9, DONE)

def draw_scoreboard(c, rows):
    # Counting / called: percentages are the hero, names shrink to a row.
    if len(rows) == 0:
        c.text("NO RESULTS YET", c.width // 2, 16, font = "5x7", color = "gray", align = "center")
        return
    if len(rows) == 2:
        left = rows[0]
        right = rows[1]
        lcolor, rcolor = pair_colors(left, right)
        rx = c.width - PAD
        half = c.width // 2 - PAD - 4
        nf = fit_font(c, [left["name"], right["name"]], SCORE_NAME_FONTS, half - 9)
        ny = 8 + (8 - FONTH[nf]) // 2
        draw_name_check(c, clip(c, left["name"], nf, half - 9), nf, PAD, ny, left["winner"], "left")
        draw_name_check(c, clip(c, right["name"], nf, half - 9), nf, rx, ny, right["winner"], "right")

        lp = pct_text(left["pct"])
        rp = pct_text(right["pct"])
        c.text(lp, PAD, 17, font = "10x15", color = left["color"])
        c.text(rp, rx, 17, font = "10x15", color = right["color"], align = "right")
        bx0 = PAD + c.text_width(lp, "10x15") + 5
        bx1 = rx - c.text_width(rp, "10x15") - 5
        split_bar(c, bx0, bx1, 21, 27, left["pct"], right["pct"], lcolor, rcolor)
        return

    shown = rows[:3]
    boxes, zw = zone_boxes(c, len(shown))
    nf = fit_font(c, [r["name"] for r in shown], SCORE_NAME_FONTS, zw - 9)
    ny = 8 + (8 - FONTH[nf]) // 2
    for i, r in enumerate(shown):
        cx = boxes[i] + zw // 2
        draw_name_check(c, clip(c, r["name"], nf, zw - 9), nf, cx, ny, r["winner"], "center")
        c.text(pct_text(r["pct"]), cx, 17, font = "10x15", color = r["color"], align = "center")
    zone_rules(c, boxes, 8, 31)

def nodata(c, title, sub):
    c.fill("#0B0C12")
    mid = c.width // 2
    maxw = c.width - 2 * PAD
    f = fit_font(c, [title], NODATA_FONTS, maxw)
    c.text(clip(c, title, f, maxw), mid, 12 - FONTH[f] // 2, font = f, color = "#E8B04A", align = "center")
    c.text(clip(c, sub, "4x5", maxw), mid, 23, font = "4x5", color = "#6A7090", align = "center")

def draw_all_clear(c, geo):
    # Empty is an answer, not an error: green check, positive line.
    mid = c.width // 2
    title = "NO UPCOMING ELECTIONS"
    tw = c.text_width(title, "6x8")
    x = mid - (tw + 10) // 2
    c.bitmap(CHECK, x, 8, DONE)
    c.text(title, x + 10, 7, font = "6x8", color = DONE)
    c.text(clip(c, "FOR " + city_label(geo), "4x5", c.width - 2 * PAD), mid, 20, font = "4x5", color = "gray", align = "center")

def draw_ballot_box(c, x, y):
    # 18x20: a marked ballot standing in the slot of a slate ballot box.
    c.rect(x + 5, y, x + 12, y + 8, fill = "white")
    c.bitmap(BALLOT_MARK, x + 6, y + 2, "black")
    c.rect(x, y + 9, x + 17, y + 11, fill = "#AAB4C3")
    c.rect(x + 4, y + 9, x + 13, y + 9, fill = "black")
    c.rect(x + 1, y + 12, x + 16, y + 19, fill = "#5A6E8C")
    c.rect(x + 4, y + 14, x + 13, y + 15, fill = "white")

# ------------------------------------------------------------------- pages

def current_index(ctx, count):
    # One race per minute, wrapping at however many races this city has - a
    # 1-race city shows that race every time; a 6-race city cycles all 6.
    # `debugframe` is an undeclared, manifest-invisible input for
    # `gdn render --input debugframe=N` to preview a specific race.
    dbg = str(ctx.inputs.get("debugframe", "")).strip()
    if dbg.isdigit():
        return int(dbg.lstrip("0") or "0") % count
    return (ctx.now.unix // 60) % count

def race(c, ctx):
    c.clear()
    geo = resolve_city(ctx)
    races, err = load_races(ctx, geo)
    if err != None:
        nodata(c, "ELECTION DATA OFFLINE", "TRYING AGAIN SOON")
        return
    if len(races) == 0:
        draw_all_clear(c, geo)
        return

    shown = races[:MAX_RACES]
    r = shown[current_index(ctx, len(shown))]
    status = race_status(r, ctx.now.unix)
    draw_chip_row(c, r, status, geo)
    if status["key"] == "counting" or status["key"] == "called":
        draw_scoreboard(c, candidate_rows(r, True))
        return
    cands = candidate_rows(r, False)
    odds = kalshi_odds(r, geo, cands)
    if odds != None:
        draw_odds(c, odds)
    else:
        draw_matchup(c, cands)

def intro_countdown(races, err, now_unix):
    # (big, label, color) for the intro's right-hand zone, from the soonest race.
    if err != None:
        return ("--", "NO DATA", "gray")
    if len(races) == 0:
        return ("NONE", "SCHEDULED", "gray")
    s = race_status(races[0], now_unix)
    if s["key"] == "upcoming":
        if s["days"] == None:
            return ("--", "DATE TBD", "gray")
        return (str(s["days"]), "DAY LEFT" if s["days"] == 1 else "DAYS LEFT", "white")
    if s["key"] == "today":
        return ("VOTE", "TODAY", LIVE)
    if s["key"] == "waiting":
        return ("SOON", "RESULTS", LIVE)
    if s["key"] == "counting":
        if s["reporting"] < 1:
            return ("LIVE", "COUNTING", LIVE)
        return (str(int(s["reporting"])) + "%", "COUNTED", LIVE)
    return ("FINAL", "RESULTS", DONE)

def intro(c, ctx):
    c.clear()
    geo = resolve_city(ctx)
    races, err = load_races(ctx, geo)

    draw_ballot_box(c, PAD, 6)

    # Countdown zone on the right, 45px wide, behind a hairline at x 133 -
    # "ELECTIONS" is 98px in 10x16_bold, so from x 32 it ends at 129.
    zx = c.width - PAD - 45
    zcx = zx + 45 // 2
    c.line(zx - 4, 4, zx - 4, 27, RULE)
    big, label, color = intro_countdown(races, err, ctx.now.unix)
    bf = fit_font(c, [big], ["10x16", "6x8"], 45)
    c.text(clip(c, big, bf, 45), zcx, 3 + (16 - FONTH[bf]) // 2, font = bf, color = color, align = "center")
    c.text(clip(c, label, "4x5", 45), zcx, 23, font = "4x5", color = "gray", align = "center")

    tx = PAD + 18 + 4
    c.text("ELECTIONS", tx, 3, font = "10x16_bold", color = "white")
    c.text(clip(c, city_label(geo), "4x5", zx - 8 - tx), tx, 23, font = "4x5", color = "gray")
