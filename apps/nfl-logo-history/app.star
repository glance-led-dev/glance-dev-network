# NFL Logo History
#
# Every primary logo an NFL club has worn, oldest to newest, on a timeline.
# Inspired by PR #770 (franciscocy505's chicago-bears-history-row, which laid
# seven Bears logos in a row); this app does it for all 32 clubs, with years.
#
# DESIGN. A museum wall read left to right. The club's older logos stand in a
# row (26 x 19 each) over a timeline, each dated by the season it debuted; the
# row runs into today's logo, drawn larger at the right between gold brackets
# and dated in gold. The timeline doubles as the franchise's road map: for a
# club that moved, each stretch of the line carries the city the marks debuted
# in (CHICAGO, ST. LOUIS...), bracketed like a stint on a stat sheet; for a
# club that never moved it is a plain rule with a tick in club colour under
# each logo. A club with more history than fits shows five logos per frame,
# one frame a minute, with a dot per frame beside the NOW year. A club with
# room to spare puts its name in the free space, with the counting rule.
# Page two sets the club's first logo and today's logo either side of its
# longest-serving mark - the tile itself when it is an older logo, or an
# arrow into NOW when today's logo is the one that has lasted - with the
# number of seasons it was worn as the hero.
#
# Eras: primary marks only; an update that only adjusts colour shades is
# merged into the mark it updates, while a new drawing or a visibly recoloured
# part (the Browns' facemask, the Rams' horn) starts a new era. The table and
# its sources live in _logos/history_src/lh_build.py. Washington's 1932-2019
# marks used Native American imagery the club has retired; they are one plain
# "9 MARKS" tile with the year, not pictures.

IMAGES = {
    "ARI_1920.png": "ARI_1920.png",
    "ARI_1920_FIRST.png": "ARI_1920_FIRST.png",
    "ARI_1947.png": "ARI_1947.png",
    "ARI_1960.png": "ARI_1960.png",
    "ARI_1962.png": "ARI_1962.png",
    "ARI_1970.png": "ARI_1970.png",
    "ATL_1966.png": "ATL_1966.png",
    "ATL_1966_FIRST.png": "ATL_1966_FIRST.png",
    "BAL_1996.png": "BAL_1996.png",
    "BAL_1996_FIRST.png": "BAL_1996_FIRST.png",
    "BUF_1960.png": "BUF_1960.png",
    "BUF_1962.png": "BUF_1962.png",
    "CAR_1995.png": "CAR_1995.png",
    "CAR_1995_FIRST.png": "CAR_1995_FIRST.png",
    "CHI_1940.png": "CHI_1940.png",
    "CHI_1940_FIRST.png": "CHI_1940_FIRST.png",
    "CHI_1946.png": "CHI_1946.png",
    "CHI_1962.png": "CHI_1962.png",
    "CHI_1974.png": "CHI_1974.png",
    "CIN_1968.png": "CIN_1968.png",
    "CIN_1968_FIRST.png": "CIN_1968_FIRST.png",
    "CIN_1970.png": "CIN_1970.png",
    "CIN_1981.png": "CIN_1981.png",
    "CIN_1997.png": "CIN_1997.png",
    "CLE_1946.png": "CLE_1946.png",
    "CLE_1946_FIRST.png": "CLE_1946_FIRST.png",
    "CLE_1950.png": "CLE_1950.png",
    "CLE_1970.png": "CLE_1970.png",
    "CLE_1975.png": "CLE_1975.png",
    "CLE_2006.png": "CLE_2006.png",
    "CLE_2015.png": "CLE_2015.png",
    "DAL_1960.png": "DAL_1960.png",
    "DAL_1960_FIRST.png": "DAL_1960_FIRST.png",
    "DEN_1960.png": "DEN_1960.png",
    "DEN_1960_FIRST.png": "DEN_1960_FIRST.png",
    "DEN_1962.png": "DEN_1962.png",
    "DEN_1968.png": "DEN_1968.png",
    "DET_1952.png": "DET_1952.png",
    "DET_1952_FIRST.png": "DET_1952_FIRST.png",
    "DET_1961.png": "DET_1961.png",
    "DET_1970.png": "DET_1970.png",
    "DET_2003.png": "DET_2003.png",
    "DET_2009.png": "DET_2009.png",
    "GB_1951.png": "GB_1951.png",
    "GB_1951_FIRST.png": "GB_1951_FIRST.png",
    "GB_1956.png": "GB_1956.png",
    "IND_1953.png": "IND_1953.png",
    "IND_1953_FIRST.png": "IND_1953_FIRST.png",
    "JAX_1995.png": "JAX_1995.png",
    "JAX_1995_FIRST.png": "JAX_1995_FIRST.png",
    "KC_1960.png": "KC_1960.png",
    "KC_1960_FIRST.png": "KC_1960_FIRST.png",
    "KC_1963.png": "KC_1963.png",
    "LAC_1960.png": "LAC_1960.png",
    "LAC_1960_FIRST.png": "LAC_1960_FIRST.png",
    "LAC_1961.png": "LAC_1961.png",
    "LAC_1974.png": "LAC_1974.png",
    "LAC_1988.png": "LAC_1988.png",
    "LAC_2002.png": "LAC_2002.png",
    "LAC_2007.png": "LAC_2007.png",
    "LAR_1941.png": "LAR_1941.png",
    "LAR_1941_FIRST.png": "LAR_1941_FIRST.png",
    "LAR_1944.png": "LAR_1944.png",
    "LAR_1948.png": "LAR_1948.png",
    "LAR_1966.png": "LAR_1966.png",
    "LAR_1983.png": "LAR_1983.png",
    "LAR_1989.png": "LAR_1989.png",
    "LAR_1995.png": "LAR_1995.png",
    "LAR_2000.png": "LAR_2000.png",
    "LAR_2017.png": "LAR_2017.png",
    "LAR_2020.png": "LAR_2020.png",
    "LV_1960.png": "LV_1960.png",
    "LV_1960_FIRST.png": "LV_1960_FIRST.png",
    "LV_1963.png": "LV_1963.png",
    "MIA_1966.png": "MIA_1966.png",
    "MIA_1966_FIRST.png": "MIA_1966_FIRST.png",
    "MIA_1974.png": "MIA_1974.png",
    "MIA_1980.png": "MIA_1980.png",
    "MIA_1997.png": "MIA_1997.png",
    "MIN_1961.png": "MIN_1961.png",
    "MIN_1961_FIRST.png": "MIN_1961_FIRST.png",
    "MIN_1966.png": "MIN_1966.png",
    "MIN_1997.png": "MIN_1997.png",
    "NE_1960.png": "NE_1960.png",
    "NE_1960_FIRST.png": "NE_1960_FIRST.png",
    "NE_1961.png": "NE_1961.png",
    "NE_1993.png": "NE_1993.png",
    "NOW_ARI.png": "NOW_ARI.png",
    "NOW_ATL.png": "NOW_ATL.png",
    "NOW_BAL.png": "NOW_BAL.png",
    "NOW_BUF.png": "NOW_BUF.png",
    "NOW_CAR.png": "NOW_CAR.png",
    "NOW_CHI.png": "NOW_CHI.png",
    "NOW_CIN.png": "NOW_CIN.png",
    "NOW_CLE.png": "NOW_CLE.png",
    "NOW_DAL.png": "NOW_DAL.png",
    "NOW_DEN.png": "NOW_DEN.png",
    "NOW_DET.png": "NOW_DET.png",
    "NOW_GB.png": "NOW_GB.png",
    "NOW_HOU.png": "NOW_HOU.png",
    "NOW_IND.png": "NOW_IND.png",
    "NOW_JAX.png": "NOW_JAX.png",
    "NOW_KC.png": "NOW_KC.png",
    "NOW_LAC.png": "NOW_LAC.png",
    "NOW_LAR.png": "NOW_LAR.png",
    "NOW_LV.png": "NOW_LV.png",
    "NOW_MIA.png": "NOW_MIA.png",
    "NOW_MIN.png": "NOW_MIN.png",
    "NOW_NE.png": "NOW_NE.png",
    "NOW_NO.png": "NOW_NO.png",
    "NOW_NYG.png": "NOW_NYG.png",
    "NOW_NYJ.png": "NOW_NYJ.png",
    "NOW_PHI.png": "NOW_PHI.png",
    "NOW_PIT.png": "NOW_PIT.png",
    "NOW_SEA.png": "NOW_SEA.png",
    "NOW_SF.png": "NOW_SF.png",
    "NOW_TB.png": "NOW_TB.png",
    "NOW_TEN.png": "NOW_TEN.png",
    "NOW_WSH.png": "NOW_WSH.png",
    "NO_1967.png": "NO_1967.png",
    "NYG_1945.png": "NYG_1945.png",
    "NYG_1945_FIRST.png": "NYG_1945_FIRST.png",
    "NYG_1950.png": "NYG_1950.png",
    "NYG_1956.png": "NYG_1956.png",
    "NYG_1961.png": "NYG_1961.png",
    "NYG_1975.png": "NYG_1975.png",
    "NYG_1976.png": "NYG_1976.png",
    "NYJ_1963.png": "NYJ_1963.png",
    "NYJ_1963_FIRST.png": "NYJ_1963_FIRST.png",
    "NYJ_1964.png": "NYJ_1964.png",
    "NYJ_1965.png": "NYJ_1965.png",
    "NYJ_1978.png": "NYJ_1978.png",
    "NYJ_1998.png": "NYJ_1998.png",
    "NYJ_2019.png": "NYJ_2019.png",
    "PHI_1933.png": "PHI_1933.png",
    "PHI_1933_FIRST.png": "PHI_1933_FIRST.png",
    "PHI_1936.png": "PHI_1936.png",
    "PHI_1942.png": "PHI_1942.png",
    "PHI_1948.png": "PHI_1948.png",
    "PHI_1969.png": "PHI_1969.png",
    "PHI_1973.png": "PHI_1973.png",
    "PHI_1987.png": "PHI_1987.png",
    "PIT_1933.png": "PIT_1933.png",
    "PIT_1933_FIRST.png": "PIT_1933_FIRST.png",
    "PIT_1940.png": "PIT_1940.png",
    "SEA_1976.png": "SEA_1976.png",
    "SEA_1976_FIRST.png": "SEA_1976_FIRST.png",
    "SEA_2002.png": "SEA_2002.png",
    "SF_1946.png": "SF_1946.png",
    "SF_1946_FIRST.png": "SF_1946_FIRST.png",
    "SF_1952.png": "SF_1952.png",
    "SF_1968.png": "SF_1968.png",
    "SF_1996.png": "SF_1996.png",
    "TB_1976.png": "TB_1976.png",
    "TB_1976_FIRST.png": "TB_1976_FIRST.png",
    "TB_1997.png": "TB_1997.png",
    "TEN_1960.png": "TEN_1960.png",
    "TEN_1961.png": "TEN_1961.png",
    "TEN_1969.png": "TEN_1969.png",
    "TEN_1972.png": "TEN_1972.png",
    "TEN_1980.png": "TEN_1980.png",
    "TEN_1999.png": "TEN_1999.png",
}

# ---- generated by _logos/history_src/lh_build.py (python lh_build.py app) - do not hand-edit ----
# club -> [name, accent, second, now_start, now_img, first_img, eras, first_is_small, home_city];
# era = [start, end, image ("" = text tile), marks it stands for, city it debuted in (relocated clubs), cells wide]
CLUBS = {
    "ARI": ["ARIZONA CARDINALS", "#E0304F", "#F0F2F5", 2005, "NOW_ARI.png", "ARI_1920_FIRST.png", [
        [1920, "1934", "ARI_1920.png", 1, "CHI", 1],
        [1947, "1959", "ARI_1947.png", 1, "CHI", 1],
        [1960, "1961", "ARI_1960.png", 1, "STL", 1],
        [1962, "1969", "ARI_1962.png", 1, "STL", 1],
        [1970, "2004", "ARI_1970.png", 1, "STL", 1],
    ], 0, "ARI"],
    "ATL": ["ATLANTA FALCONS", "#E8243C", "#A5ACAF", 2003, "NOW_ATL.png", "ATL_1966_FIRST.png", [
        [1966, "2002", "ATL_1966.png", 1, "", 1],
    ], 0, ""],
    "BAL": ["BALTIMORE RAVENS", "#D0A52E", "#7B5CE8", 1999, "NOW_BAL.png", "BAL_1996_FIRST.png", [
        [1996, "1998", "BAL_1996.png", 1, "", 1],
    ], 0, ""],
    "BUF": ["BUFFALO BILLS", "#E8203A", "#2A6BFF", 1974, "NOW_BUF.png", "BUF_1960.png", [
        [1960, "1961", "BUF_1960.png", 1, "", 1],
        [1962, "1973", "BUF_1962.png", 1, "", 1],
    ], 1, ""],
    "CAR": ["CAROLINA PANTHERS", "#19A6F0", "#B8BEC4", 2012, "NOW_CAR.png", "CAR_1995_FIRST.png", [
        [1995, "2011", "CAR_1995.png", 1, "", 1],
    ], 0, ""],
    "CHI": ["CHICAGO BEARS", "#FF5A1F", "#3F63C0", 2023, "NOW_CHI.png", "CHI_1940_FIRST.png", [
        [1940, "1945", "CHI_1940.png", 1, "", 1],
        [1946, "1961", "CHI_1946.png", 1, "", 1],
        [1962, "1973", "CHI_1962.png", 1, "", 1],
        [1974, "2022", "CHI_1974.png", 1, "", 1],
    ], 0, ""],
    "CIN": ["CINCINNATI BENGALS", "#FF6A1F", "#F0F2F5", 2004, "NOW_CIN.png", "CIN_1968_FIRST.png", [
        [1968, "1969", "CIN_1968.png", 1, "", 1],
        [1970, "1980", "CIN_1970.png", 1, "", 1],
        [1981, "1996", "CIN_1981.png", 1, "", 1],
        [1997, "2003", "CIN_1997.png", 1, "", 1],
    ], 0, ""],
    "CLE": ["CLEVELAND BROWNS", "#FF4E10", "#9A6433", 2024, "NOW_CLE.png", "CLE_1946_FIRST.png", [
        [1946, "1949", "CLE_1946.png", 1, "", 1],
        [1950, "1969", "CLE_1950.png", 1, "", 1],
        [1970, "1974", "CLE_1970.png", 1, "", 1],
        [1975, "2005", "CLE_1975.png", 1, "", 1],
        [2006, "2014", "CLE_2006.png", 1, "", 1],
        [2015, "2023", "CLE_2015.png", 1, "", 1],
    ], 0, ""],
    "DAL": ["DALLAS COWBOYS", "#B0B7BC", "#3D7BFF", 1964, "NOW_DAL.png", "DAL_1960_FIRST.png", [
        [1960, "1963", "DAL_1960.png", 1, "", 1],
    ], 0, ""],
    "DEN": ["DENVER BRONCOS", "#FF5A14", "#3A6AB0", 1997, "NOW_DEN.png", "DEN_1960_FIRST.png", [
        [1960, "1961", "DEN_1960.png", 1, "", 1],
        [1962, "1967", "DEN_1962.png", 1, "", 1],
        [1968, "1996", "DEN_1968.png", 1, "", 1],
    ], 0, ""],
    "DET": ["DETROIT LIONS", "#1C9BE8", "#B0B7BC", 2017, "NOW_DET.png", "DET_1952_FIRST.png", [
        [1952, "1960", "DET_1952.png", 1, "", 1],
        [1961, "1969", "DET_1961.png", 1, "", 1],
        [1970, "2002", "DET_1970.png", 1, "", 1],
        [2003, "2008", "DET_2003.png", 1, "", 1],
        [2009, "2016", "DET_2009.png", 1, "", 1],
    ], 0, ""],
    "GB": ["GREEN BAY PACKERS", "#FFB612", "#2E8B57", 1961, "NOW_GB.png", "GB_1951_FIRST.png", [
        [1951, "1955", "GB_1951.png", 1, "", 3],
        [1956, "1960", "GB_1956.png", 1, "", 1],
    ], 0, ""],
    "HOU": ["HOUSTON TEXANS", "#E8233C", "#3A5A8C", 2002, "NOW_HOU.png", "", [
    ], 0, ""],
    "IND": ["INDIANAPOLIS COLTS", "#3D86E8", "#F0F2F5", 1961, "NOW_IND.png", "IND_1953_FIRST.png", [
        [1953, "1960", "IND_1953.png", 1, "BAL", 1],
    ], 0, "IND"],
    "JAX": ["JACKSONVILLE JAGUARS", "#D7A22A", "#00A5B8", 2013, "NOW_JAX.png", "JAX_1995_FIRST.png", [
        [1995, "2012", "JAX_1995.png", 1, "", 1],
    ], 0, ""],
    "KC": ["KANSAS CITY CHIEFS", "#FFB612", "#FF2447", 1972, "NOW_KC.png", "KC_1960_FIRST.png", [
        [1960, "1962", "KC_1960.png", 1, "DAL", 1],
        [1963, "1971", "KC_1963.png", 1, "KC", 1],
    ], 0, "KC"],
    "LV": ["LAS VEGAS RAIDERS", "#C4CACD", "#8A9196", 1964, "NOW_LV.png", "LV_1960_FIRST.png", [
        [1960, "1962", "LV_1960.png", 1, "OAK", 1],
        [1963, "1963", "LV_1963.png", 1, "OAK", 1],
    ], 0, "LV"],
    "LAC": ["LOS ANGELES CHARGERS", "#FFC20E", "#2AA8F0", 2020, "NOW_LAC.png", "LAC_1960_FIRST.png", [
        [1960, "1960", "LAC_1960.png", 1, "LA", 1],
        [1961, "1973", "LAC_1961.png", 1, "SD", 1],
        [1974, "1987", "LAC_1974.png", 1, "SD", 1],
        [1988, "2001", "LAC_1988.png", 1, "SD", 1],
        [2002, "2006", "LAC_2002.png", 1, "SD", 1],
        [2007, "2019", "LAC_2007.png", 1, "SD", 1],
    ], 0, "LA"],
    "LAR": ["LOS ANGELES RAMS", "#FFD100", "#2F6BFF", 2026, "NOW_LAR.png", "LAR_1941_FIRST.png", [
        [1941, "1942", "LAR_1941.png", 1, "CLE", 1],
        [1944, "1947", "LAR_1944.png", 1, "CLE", 1],
        [1948, "1965", "LAR_1948.png", 1, "LA", 1],
        [1966, "1982", "LAR_1966.png", 1, "LA", 1],
        [1983, "1988", "LAR_1983.png", 1, "LA", 1],
        [1989, "1994", "LAR_1989.png", 1, "LA", 1],
        [1995, "1999", "LAR_1995.png", 1, "STL", 2],
        [2000, "2016", "LAR_2000.png", 1, "STL", 1],
        [2017, "2019", "LAR_2017.png", 1, "LA", 1],
        [2020, "2025", "LAR_2020.png", 1, "LA", 1],
    ], 0, "LA"],
    "MIA": ["MIAMI DOLPHINS", "#FC6A12", "#00C2CC", 2013, "NOW_MIA.png", "MIA_1966_FIRST.png", [
        [1966, "1973", "MIA_1966.png", 1, "", 1],
        [1974, "1979", "MIA_1974.png", 1, "", 1],
        [1980, "1996", "MIA_1980.png", 1, "", 1],
        [1997, "2012", "MIA_1997.png", 1, "", 1],
    ], 0, ""],
    "MIN": ["MINNESOTA VIKINGS", "#FFC62F", "#8F5BE8", 2013, "NOW_MIN.png", "MIN_1961_FIRST.png", [
        [1961, "1965", "MIN_1961.png", 1, "", 1],
        [1966, "1996", "MIN_1966.png", 1, "", 1],
        [1997, "2012", "MIN_1997.png", 1, "", 1],
    ], 0, ""],
    "NE": ["NEW ENGLAND PATRIOTS", "#E8203F", "#3A5A9C", 2000, "NOW_NE.png", "NE_1960_FIRST.png", [
        [1960, "1960", "NE_1960.png", 1, "BOS", 1],
        [1961, "1992", "NE_1961.png", 1, "BOS", 1],
        [1993, "1999", "NE_1993.png", 1, "NE", 1],
    ], 0, "NE"],
    "NO": ["NEW ORLEANS SAINTS", "#D3BC8D", "#F0F2F5", 2000, "NOW_NO.png", "NO_1967.png", [
        [1967, "1999", "NO_1967.png", 1, "", 1],
    ], 1, ""],
    "NYG": ["NEW YORK GIANTS", "#E8203F", "#2A5FE0", 2000, "NOW_NYG.png", "NYG_1945_FIRST.png", [
        [1945, "1949", "NYG_1945.png", 1, "", 1],
        [1950, "1955", "NYG_1950.png", 1, "", 1],
        [1956, "1960", "NYG_1956.png", 1, "", 1],
        [1961, "1974", "NYG_1961.png", 1, "", 1],
        [1975, "1975", "NYG_1975.png", 1, "", 1],
        [1976, "1999", "NYG_1976.png", 1, "", 2],
    ], 0, ""],
    "NYJ": ["NEW YORK JETS", "#F0F2F5", "#1FA36E", 2024, "NOW_NYJ.png", "NYJ_1963_FIRST.png", [
        [1963, "1963", "NYJ_1963.png", 1, "", 1],
        [1964, "1964", "NYJ_1964.png", 1, "", 1],
        [1965, "1977", "NYJ_1965.png", 1, "", 1],
        [1978, "1997", "NYJ_1978.png", 1, "", 2],
        [1998, "2018", "NYJ_1998.png", 1, "", 1],
        [2019, "2023", "NYJ_2019.png", 1, "", 1],
    ], 0, ""],
    "PHI": ["PHILADELPHIA EAGLES", "#B0B7BC", "#0FA0A8", 1996, "NOW_PHI.png", "PHI_1933_FIRST.png", [
        [1933, "1935", "PHI_1933.png", 1, "", 1],
        [1936, "1941", "PHI_1936.png", 1, "", 1],
        [1942, "1947", "PHI_1942.png", 1, "", 1],
        [1948, "1968", "PHI_1948.png", 1, "", 1],
        [1969, "1972", "PHI_1969.png", 1, "", 1],
        [1973, "1986", "PHI_1973.png", 1, "", 1],
        [1987, "1995", "PHI_1987.png", 1, "", 1],
    ], 0, ""],
    "PIT": ["PITTSBURGH STEELERS", "#FFB612", "#F0F2F5", 1962, "NOW_PIT.png", "PIT_1933_FIRST.png", [
        [1933, "1939", "PIT_1933.png", 1, "", 1],
        [1940, "1961", "PIT_1940.png", 1, "", 1],
    ], 0, ""],
    "SF": ["SAN FRANCISCO 49ERS", "#D4B46A", "#E8201F", 2009, "NOW_SF.png", "SF_1946_FIRST.png", [
        [1946, "1951", "SF_1946.png", 1, "", 1],
        [1952, "1967", "SF_1952.png", 1, "", 1],
        [1968, "1995", "SF_1968.png", 1, "", 1],
        [1996, "2008", "SF_1996.png", 1, "", 1],
    ], 0, ""],
    "SEA": ["SEATTLE SEAHAWKS", "#69BE28", "#3A5A9C", 2012, "NOW_SEA.png", "SEA_1976_FIRST.png", [
        [1976, "2001", "SEA_1976.png", 1, "", 1],
        [2002, "2011", "SEA_2002.png", 1, "", 1],
    ], 0, ""],
    "TB": ["TAMPA BAY BUCCANEERS", "#F0263A", "#8A8580", 2014, "NOW_TB.png", "TB_1976_FIRST.png", [
        [1976, "1996", "TB_1976.png", 1, "", 1],
        [1997, "2013", "TB_1997.png", 1, "", 1],
    ], 0, ""],
    "TEN": ["TENNESSEE TITANS", "#4B92DB", "#F0F2F5", 2026, "NOW_TEN.png", "TEN_1960.png", [
        [1960, "1960", "TEN_1960.png", 1, "HOU", 1],
        [1961, "1968", "TEN_1961.png", 1, "HOU", 1],
        [1969, "1971", "TEN_1969.png", 1, "HOU", 1],
        [1972, "1979", "TEN_1972.png", 1, "HOU", 1],
        [1980, "1998", "TEN_1980.png", 1, "HOU", 1],
        [1999, "2025", "TEN_1999.png", 1, "TEN", 1],
    ], 1, "TEN"],
    "WSH": ["WASHINGTON COMMANDERS", "#FFB612", "#B8323A", 2022, "NOW_WSH.png", "", [
        [1932, "2019", "", 9, "", 1],
        [2020, "2021", "", 1, "", 1],
    ], 0, ""],
}
CITY = {"CHI": ["CHICAGO", "CHI"], "STL": ["ST. LOUIS", "STL"], "ARI": ["ARIZONA", "ARI"], "BAL": ["BALTIMORE", "BAL"], "IND": ["INDY", "IND"], "DAL": ["DALLAS", "DAL"], "KC": ["KANSAS CITY", "KC"], "OAK": ["OAKLAND", "OAK"], "LA": ["LOS ANGELES", "LA"], "SD": ["SAN DIEGO", "SD"], "CLE": ["CLEVELAND", "CLE"], "BOS": ["BOSTON", "BOS"], "NE": ["NEW ENGLAND", "NE"], "HOU": ["HOUSTON", "HOU"], "TEN": ["TENNESSEE", "TEN"]}
# ---- end generated ----

ORDER = ["ARI", "ATL", "BAL", "BUF", "CAR", "CHI", "CIN", "CLE", "DAL", "DEN", "DET", "GB",
         "HOU", "IND", "JAX", "KC", "LV", "LAC", "LAR", "MIA", "MIN", "NE", "NO", "NYG",
         "NYJ", "PHI", "PIT", "SF", "SEA", "TB", "TEN", "WSH"]

GOLD = "#FFC83D"
DIM = "#6E7A94"
CITYC = "#9AA6BE"
RULE = "#3A4356"
CAP = "#56627A"
INK = "#F4F7FF"

# ------------------------------------------------------------------ layout
# 192 wide, 6 px padding each side. Older logos: up to five 26 x 19 cells at
# x 6..139 (1 px apart), y 1..19. Timeline band y 21..25 with its line at
# y 23 (city labels ride the line on relocated clubs), 1 px clear, then the
# years at y 27..31. NOW logo: 40 x 24 at x 144..183, y 1..24, gold brackets
# x 142..185, y 0..25; the frame dots sit right of the NOW year.
CELL_W = 26
CELL_H = 19
CELL_GAP = 1
CELLS_X = 6
PER_FRAME = 5
CELLS_R = CELLS_X + PER_FRAME * CELL_W + (PER_FRAME - 1) * CELL_GAP - 1   # 139
LOGO_Y = 1
LINE_Y = 23
YEAR_Y = 27
NOW_X = 144
NOW_Y = 1

def logo_count(club):
    """Logos in the club's history, today's included (a retired-marks tile
    counts every mark it stands for)."""
    t = 1
    for e in club[6]:
        t += e[3]
    return t

def pick_club(ctx):
    want = str(ctx.inputs.get("team", "ALL TEAMS")).strip().upper()
    for ab in ORDER:
        if CLUBS[ab][0] == want:
            return ab
    # ALL TEAMS (or anything unknown): a new club every 3 minutes
    return ORDER[(ctx.now.unix // 180) % len(ORDER)]

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return f
    return ""

def clip(c, text, font, maxw):
    t = text
    for k in range(len(text), 0, -1):
        t = text[:k]
        if c.text_width(t, font) <= maxw:
            return t
    return ""

def season_year(ctx):
    # an NFL season starts in September
    return ctx.now.year if ctx.now.month >= 9 else ctx.now.year - 1

def brackets(c, x0, y0, x1, y1, col):
    """Four 3 px gold corner brackets - the museum-label frame for NOW."""
    for cx, dx in [[x0, 1], [x1, -1]]:
        for cy, dy in [[y0, 1], [y1, -1]]:
            c.pixel(cx, cy, col)
            c.pixel(cx + dx, cy, col)
            c.pixel(cx + 2 * dx, cy, col)
            c.pixel(cx, cy + dy, col)
            c.pixel(cx, cy + 2 * dy, col)

def tile(c, x, y, w, h, era, club):
    """A text tile for an era with no picture: Washington's retired marks and
    the 2020-21 Washington Football Team wordmark."""
    c.rect(x, y, x + w - 1, y + h - 1, outline = club[2])
    cx = x + w // 2
    if era[0] == 2020:
        c.text("WFT", cx, y + (h - 7) // 2, font = "5x7", color = GOLD, align = "center")
    elif w >= 40:
        c.text(str(era[3]), cx, y + 2, font = "5x7", color = GOLD, align = "center")
        c.text("MARKS", cx, y + 10, font = "4x5", color = GOLD, align = "center")
        c.text("RETIRED", cx, y + 16, font = "4x5", color = DIM, align = "center")
    else:
        # 26 px cell: 'RETIRED' does not fit, so the tile says how many marks
        # it stands for ('9') over 'MARKS'.
        c.text(str(era[3]), cx, y + 3, font = "5x7", color = GOLD, align = "center")
        c.text("MARKS", cx, y + 12, font = "picopixel", color = DIM, align = "center")

def era_image(c, era, x, y, w, h, club):
    if era[2] == "":
        tile(c, x, y, w, h, era, club)
        return
    c.image(IMAGES[era[2]], x, y)

def now_logo(c, club):
    c.image(IMAGES[club[4]], NOW_X, NOW_Y)
    brackets(c, NOW_X - 2, 0, NOW_X + 41, 25, GOLD)
    c.text(str(club[3]), NOW_X + 20, YEAR_Y, font = "4x5", color = GOLD, align = "center")

def frames_of(older):
    """Pack the older eras into frames of at most five cells (a wordmark
    takes two) -> [[first, last], ...]."""
    out = []
    used = 0
    for i in range(len(older)):
        w = older[i][5]
        if len(out) == 0 or used + w > PER_FRAME:
            out.append([i, i])
            used = 0
        out[len(out) - 1][1] = i
        used += w
    return out

def cell_w(era):
    return era[5] * CELL_W + (era[5] - 1) * CELL_GAP

def timeline_band(c, club, shown, xs):
    """The timeline under the cells: a rule with a club-colour tick per logo,
    or - for a relocated club - one bracketed stretch per city, labelled
    with the city the marks in it debuted in."""
    k = len(shown)
    if club[8] == "":
        c.rect(xs[0], LINE_Y, CELLS_R + 1, LINE_Y, fill = RULE)
        for i in range(k):
            cx = xs[i] + cell_w(shown[i]) // 2
            c.rect(cx, LINE_Y - 1, cx, LINE_Y + 1, fill = club[1])
        return
    runs = []
    for i in range(k):
        if len(runs) > 0 and runs[len(runs) - 1][2] == shown[i][4]:
            runs[len(runs) - 1][1] = i
        else:
            runs.append([i, i, shown[i][4]])
    for run in runs:
        l = xs[run[0]] + 1
        r = xs[run[1]] + cell_w(shown[run[1]]) - 2
        c.rect(l, LINE_Y, r, LINE_Y, fill = RULE)
        # end caps: a stint on the road map
        c.rect(l, LINE_Y - 2, l, LINE_Y + 2, fill = RULE)
        c.rect(r, LINE_Y - 2, r, LINE_Y + 2, fill = RULE)
        names = CITY.get(run[2], [run[2], run[2]])
        room = r - l - 7
        label = names[0] if c.text_width(names[0], "4x5") <= room else names[1]
        if c.text_width(label, "4x5") > room:
            continue
        w = c.text_width(label, "4x5")
        lx = (l + r + 1 - w) // 2
        # a black gap in the line around the label
        c.rect(lx - 2, LINE_Y, lx + w + 1, LINE_Y, fill = "#000000")
        c.text(label, lx, LINE_Y - 2, font = "4x5", color = CITYC)

# ------------------------------------------------------------ page: timeline
def timeline(c, ctx):
    c.fill("black")
    ab = pick_club(ctx)
    club = CLUBS[ab]
    older = club[6]
    n = len(older)
    fl = frames_of(older)
    frames = max(1, len(fl))
    fr = (ctx.now.unix // 60) % frames
    shown = older[fl[fr][0]:fl[fr][1] + 1] if n > 0 else []
    k = len(shown)

    # Cells are right-aligned so the row always flows into NOW.
    width = 0
    for e in shown:
        width += cell_w(e) + CELL_GAP
    x0 = CELLS_R + 1 - (width - CELL_GAP if k > 0 else 0)
    xs = []
    x = x0
    for e in shown:
        xs.append(x)
        era_image(c, e, x, LOGO_Y, cell_w(e), CELL_H, club)
        c.text(str(e[0]), x + cell_w(e) // 2, YEAR_Y, font = "4x5", color = INK, align = "center")
        x += cell_w(e) + CELL_GAP
    if k > 0:
        timeline_band(c, club, shown, xs)
    now_logo(c, club)

    if frames > 1:
        for f in range(frames):
            fx = NOW_X + 36 + f * 3
            c.rect(fx, 28, fx + 1, 29, fill = club[1] if f == fr else RULE)

    # Free space left of the cells: the club's name, the count, and the rule
    # the count follows.
    free = x0 - CELLS_X - 4 if k > 0 else CELLS_R - CELLS_X - 4
    if free < 40:
        return
    total = logo_count(club)
    words = club[0].split(" ")
    nick = words[len(words) - 1]
    city = " ".join(words[:len(words) - 1])
    top = 1
    if city != "" and c.text_width(city, "4x5") <= free:
        c.text(city, CELLS_X, top, font = "4x5",
               color = club[2] if club[2] != "#F0F2F5" else DIM)
        top = 7
    f = fit(c, nick, ["9x12", "8x10", "6x8", "5x7", "4x5"], free)
    if f != "":
        c.text(nick, CELLS_X, top, font = f, color = club[1])
    note = "RECOLORS MERGED"
    if c.text_width(note, "4x5") <= free:
        c.text(note, CELLS_X, 21, font = "4x5", color = CAP)
    # the caption ends 4 px before the first cell's year label
    cap_w = free - 8 if k > 0 else free
    cap = str(total) + " PRIMARY LOGO" + ("S" if total != 1 else "")
    if c.text_width(cap, "4x5") > cap_w:
        cap = str(total) + " LOGO" + ("S" if total != 1 else "")
    c.text(cap, CELLS_X, YEAR_Y, font = "4x5", color = DIM)

# ------------------------------------------------------------ page: firstnow
def longest(club, sy):
    """The mark worn the most seasons: [seasons, start, end_label, image]; today's wins ties."""
    best = [max(1, sy - club[3] + 1), club[3], "", ""]
    for e in club[6]:
        if e[2] == "" or e[3] != 1 or e[5] != 1:
            continue
        s = int(e[1]) - e[0] + 1
        if s > best[0]:
            best = [s, e[0], e[1], e[2]]
    return best

def firstnow(c, ctx):
    c.fill("black")
    ab = pick_club(ctx)
    club = CLUBS[ab]
    older = club[6]
    total = logo_count(club)
    first_year = older[0][0] if len(older) > 0 else club[3]

    # left: the first logo (40 x 24), or a tile when it has no picture
    if len(older) == 0:
        c.image(IMAGES[club[4]], 6, 1)
    elif club[5] != "" and club[7] == 1:
        # only the 26 x 19 conversion passed the logo bar: centre it in the
        # 40 x 24 slot rather than ship a weaker large one
        c.image(IMAGES[club[5]], 13, 3)
    elif club[5] != "":
        c.image(IMAGES[club[5]], 6, 1)
    else:
        tile(c, 6, 1, 40, 24, older[0], club)
    c.text(str(first_year), 26, YEAR_Y, font = "4x5", color = INK, align = "center")

    now_logo(c, club)

    # middle x 50..139: the count and span on top, the longest-serving mark
    # as the hero, its years underneath
    mid_l = 50
    mid_r = 139
    cx = (mid_l + mid_r) // 2
    sy = season_year(ctx)
    span = max(1, sy - first_year + 1)
    head = str(total) + " LOGOS IN " + str(span) + " SEASONS"
    if total == 1:
        head = "ONE LOGO, " + str(span) + " SEASONS"
    if c.text_width(head, "4x5") > mid_r - mid_l + 1:
        head = str(total) + " LOGOS SINCE " + str(first_year)
    c.text(clip(c, head, "4x5", mid_r - mid_l + 1), cx, 0, font = "4x5", color = DIM, align = "center")

    lg = longest(club, sy)
    num = str(lg[0])
    nw = c.text_width(num, "10x16")
    sw = c.text_width("SEASONS", "4x5")
    if lg[3] != "":
        # an older mark lasted longest: show it
        bw = CELL_W + 3 + nw + 2 + sw
        x = cx - bw // 2
        c.image(IMAGES[lg[3]], x, 6)
        x += CELL_W + 3
        c.text(num, x, 7, font = "10x16", color = GOLD)
        c.text("SEASONS", x + nw + 2, 12, font = "4x5", color = INK)
        rng = str(lg[1]) + "-" + lg[2]
    else:
        # today's logo is the longest-serving: point at it
        bw = nw + 2 + sw + 3 + 5
        x = cx - bw // 2
        c.text(num, x, 7, font = "10x16", color = GOLD)
        c.text("SEASONS", x + nw + 2, 12, font = "4x5", color = INK)
        ax = x + nw + 2 + sw + 3
        for i in range(3):
            c.rect(ax + i, 11 + i, ax + i, 17 - i, fill = GOLD)
        rng = "SINCE " + str(lg[1])
    cap = "LONGEST: " + rng
    c.text(cap, cx, YEAR_Y, font = "4x5", color = DIM, align = "center")
