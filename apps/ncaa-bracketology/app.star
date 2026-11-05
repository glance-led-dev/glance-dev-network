# Approved SomelofskeSports projections with proportional native team artwork.

BLUE = "#1677ff"

def tight_width(c, value, font):
    label = str(value)
    reduction = 0
    for letter in label[:-1].elems():
        if letter == "T": reduction += 1
    return c.text_width(label, font) - reduction

def tight_text(c, value, x, y, font = "4x5", color = "white", align = "left"):
    label = str(value)
    if "T" not in label[:-1]:
        c.text(label, x, y, font = font, color = color, align = align)
        return
    width = tight_width(c, label, font)
    left = x - width // 2 if align == "center" else x - width if align == "right" else x
    reduction = 0
    for index in range(len(label)):
        letter = label[index]
        offset = c.text_width(label[:index + 1], font) - c.text_width(letter, font)
        c.text(letter, left + offset - reduction, y, font = font, color = color)
        if letter == "T": reduction += 1

DARK = "#101820"
GRID = "#46515f"
LIGHT = "#f4f7fb"
MUTED = "#9aa8b8"
GOLD = "#f5c542"
GREEN = "#35d07f"
PURPLE = "#A855F7"
RED = "#ff5a5f"
TOP_FOUR_RANK_COLOR = "#808890"
# Slight optical enlargement for low-profile marks; retain team x corrections.
TOP_FOUR_LARGE_MARKS = ["drawn-tex.png", "drawn-ark.png", "drawn-gonz.png"]
# Small optical corrections for artwork with uneven transparent padding.
LOGO_X_OFFSETS = {
    "drawn-duke.png": -1,
    "drawn-conn.png": 1,
    "drawn-lou.png": 1,
    "drawn-ku.png": 0,
    "drawn-bama.png": -1,
    "drawn-tex.png": 1,
    "drawn-hou.png": 1,
}
# Overall ranks imported from Kyle's draft Seed List (all 76 teams).
TEAM_OVERALL_SEEDS = {'DUKE': 1, 'FLA': 2, 'ARIZ': 3, 'ILL': 4, 'CONN': 5, 'HOU': 6, 'LOU': 7, 'SJU': 8, 'UVA': 9, 'GONZ': 10, 'ISU': 11, 'BAMA': 12, 'ARK': 13, 'MSU': 14, 'MIA': 15, 'KU': 16, 'TTU': 17, 'TENN': 18, 'TEX': 19, 'MICH': 20, 'UK': 21, 'VAND': 22, 'UCLA': 23, 'NEB': 24, 'USC': 25, 'BYU': 26, 'BAY': 27, 'CREI': 28, 'OSU': 29, 'MARQ': 30, 'MIZ': 31, 'PROV': 32, 'NOVA': 33, 'PUR': 34, 'UNC': 35, 'TAMU': 36, 'CIN': 37, 'CLEM': 38, 'AUB': 39, 'TCU': 40, 'IOWA': 41, 'MD': 42, 'IND': 43, 'OU': 44, 'USU': 45, 'VT': 46, 'WIS': 47, 'WVU': 48, 'MISS': 49, 'SMU': 50, 'GCU': 51, 'VCU': 52, 'SMC': 53, 'HPU': 54, 'WICH': 55, 'MUR': 56, 'MCN': 57, 'UCSD': 58, 'UNCW': 59, 'AKR': 60, 'WKU': 61, 'PENN': 62, 'JMU': 63, 'MTST': 64, 'WRST': 65, 'FUR': 66, 'NDSU': 67, 'UCA': 68, 'HOW': 69, 'UVM': 70, 'MRMK': 71, 'TNST': 72, 'BCU': 73, 'AMER': 74, 'QUC': 75, 'LIU': 76}
BALL = [
    [0,0,0,1,1,1,1,1,0,0,0],
    [0,1,1,1,1,1,1,1,1,1,0],
    [0,1,1,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1],
    [0,1,1,1,1,1,1,1,1,1,0],
    [0,1,1,1,1,1,1,1,1,1,0],
    [0,0,0,1,1,1,1,1,0,0,0],
]

def projection_date_label(value):
    # Only format a complete calendar date supplied by the approved projection.
    if type(value) != "string" or len(value) != 10 or value[4] != "-" or value[7] != "-": return ""
    digits = value[:4] + value[5:7] + value[8:]
    for digit in digits.elems():
        if digit not in "0123456789": return ""
    year, month, day = int(value[:4]), int(value[5:7]), int(value[8:])
    if year < 1 or month < 1 or month > 12: return ""
    leap = year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
    days = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if day < 1 or day > days[month - 1]: return ""
    return str(month) + "/" + str(day)

def intro(c, ctx):
    c.fill("black")
    # Keep the supplied partner mark and divider intact; use the existing
    # Bracketology mark in the right-hand intro slot.
    c.image("somelofske-bracketology.png", 0, 0, w = 192, h = 32)
    # Replace only the Bracketology half with the established mark.
    c.rect(97, 0, 191, 31, fill = "black")
    # Original full-size artwork in its original position. Its right-hand
    # wordmark ends at y25; the lower ball tail stays left of the footer.
    c.image("bracketology-mark-redrawn.png", 97, 0, w = 95, h = 32)
    projection = projection_state()
    date = projection_date_label(projection.get("PROJECTION_DATE", ""))
    if date:
        # Use the established one-pixel visible-ink spacing, full 4x5 glyphs.
        # UPDATED 10/27 occupies x135..191, clear of the ball's lower tail.
        label = "SAVED" if projection.get("SAVED_PROJECTION", False) else "UPDATED"
        label_width = top_four_text_width(label)
        date_width = top_four_text_width(date)
        left = 192 - label_width - 3 - date_width
        top_four_text(c, label, left, 27, BLUE)
        top_four_text(c, date, left + label_width + 3, 27, LIGHT)
    else:
        c.text("UNDATED", 188, 28, font = "3x4", color = MUTED, align = "right")

def source_panel(c, region, city, badge = ""):
    c.fill("black")
    if badge:
        c.image(badge, 0, 0, w = 42, h = 32)
        return
    c.image("region-badge-shell.png", 0, 0, w = 42, h = 32)
    tight_text(c, "T3", 21, 4, font = "5x7", color = BLUE, align = "center")
    region_font = "4x5" if len(region) > 5 else "5x7"
    tight_text(c, region, 21, 13, font = region_font, color = LIGHT, align = "center")
    tight_text(c, city, 21, 22, font = "3x4", color = MUTED, align = "center")

def top_four_text_width(value, bold = False):
    label = str(value)
    width = max(0, len(label) - 1)
    for letter in label.elems():
        edges = SNAPSHOT_FONT_INK["4x5"][letter]
        width += edges[1] - edges[0] + 1 + (1 if bold else 0)
    return width

def top_four_text(c, value, left, y, color, bold = False):
    cursor = left
    for letter in str(value).elems():
        edges = SNAPSHOT_FONT_INK["4x5"][letter]
        tight_text(c, letter, cursor - edges[0], y, font = "4x5", color = color)
        if bold:
            tight_text(c, letter, cursor - edges[0] + 1, y, font = "4x5", color = color)
        cursor += edges[1] - edges[0] + 2 + (1 if bold else 0)

def region_page(_projection, c, region, city, teams, badge = "", show_seed = True, corner_rank = False, bubble_rank_spacing = False):
    source_panel(c, region, city, badge)
    for i in range(4):
        left = 42 + i * 37
        # The final Top 4 box extends to the actual panel edge (191), not 189.
        column_width = c.width - left if not corner_rank and i == 3 else 37
        c.line(left, 0, left, 31, color = GRID)
        overall_seed = _projection["TEAM_OVERALL_SEEDS"].get(teams[i][0], 0)
        logo = teams[i][1]
        # Match the logo's visible center to the abbreviation's box center.
        # Native frames, vertical positions and corner numbers stay unchanged.
        large_x = left + 5 + LOGO_X_OFFSETS.get(logo, 0)
        regular_x = left + 6 + LOGO_X_OFFSETS.get(logo, 0)
        if not corner_rank:
            code = teams[i][0]
            label_clearance = 2 if len(code) == 4 and overall_seed >= 10 else 0
            if bubble_rank_spacing and overall_seed > 0:
                # A two-digit bubble rank must not read as part of UNC/TAMU.
                # Keep two blank pixels before the label. The Bubble logo
                # stays independently centered in its box.
                centered_label = left + 1 + (column_width - 1 - top_four_text_width(code, True)) // 2
                rank_right = left + top_four_text_width(str(overall_seed))
                label_clearance = max(label_clearance, rank_right + 3 - centered_label)
            logo_clearance = 0 if bubble_rank_spacing else label_clearance
            large_x = left + 1 + (column_width - 1 - 28) // 2 + logo_clearance
            visible_width = SWEET_SINGLE_RIGHT_INK[code] - SWEET_SINGLE_LEFT_INK[code] + 1
            regular_x = left + 1 + (column_width - 1 - visible_width) // 2 - SWEET_SINGLE_LEFT_INK[code] + logo_clearance
        if logo in TOP_FOUR_LARGE_MARKS:
            if teams[i][0] in USER_LOGO_FRAMES:
                draw_user_logo_native(c, teams[i][0], large_x, 0, 28, 25)
            else:
                c.image(logo, large_x, 0, w = 28, h = 25)
        else:
            if teams[i][0] in USER_LOGO_FRAMES:
                draw_user_logo_native(c, teams[i][0], regular_x, 1, 26, 23)
            else:
                c.image(logo, regular_x, 1, w = 26, h = 23)
        label = teams[i][0]
        # Preserve the established bold label and custom spacing.
        label_width = 6 * len(label) - 1
        for j in range(len(label) - 1):
            if label[j] == "T":
                label_width -= 2
            elif label[j] == "I":
                label_width -= 1
        rank_width = c.text_width(str(overall_seed), "4x5") if corner_rank and overall_seed > 0 else 0
        x = left + (37 - label_width) // 2
        rank_x = left + 37 - rank_width
        if corner_rank and overall_seed in [38, 50]:
            rank_x += 2
        if not corner_rank:
            x = left + 1 + (column_width - 1 - top_four_text_width(label, True)) // 2 + label_clearance
            label_color = "#FFCC33" if bubble_rank_spacing and label == "MINN" else FULL_FIELD_COLORS.get(label, teams[i][2])
            top_four_text(c, label, x, 26, label_color, True)
        else:
            for j in range(len(label)):
                label_color = FULL_FIELD_COLORS.get(label, teams[i][2])
                tight_text(c, label[j], x, 26, font = "4x5", color = label_color)
                tight_text(c, label[j], x + 1, 26, font = "4x5", color = label_color)
                x += 4 if label[j] == "T" else 5 if label[j] == "I" else 6
        if not corner_rank:
            # Seed at top-left, overall rank flush with bottom-left.
            # Measure glyph ink so even the narrow digit 1 uses that same edge.
            if show_seed:
                top_four_text(c, str(i + 1), left + 1, 1, "white")
            if overall_seed > 0:
                top_four_text(c, str(overall_seed), left + 1, 26, TOP_FOUR_RANK_COLOR)
        if rank_width:
            # Draw the full number after the logo, safely inside this column.
            # Abbreviations remain centered and full-size logo geometry stays.
            tight_text(c, str(overall_seed), rank_x, 0, font = "4x5", color = TOP_FOUR_RANK_COLOR)

EAST_TEAMS = [['DUKE', 'drawn-duke.png', '#4f9dff'], ['HOU', 'drawn-hou.png', '#f04b55'], ['BAMA', 'drawn-bama.png', '#e85a66'], ['MSU', 'drawn-msu.png', '#41ad83']]
MIDWEST_TEAMS = [['ILL', 'drawn-ill.png', '#ff6a2a'], ['CONN', 'drawn-conn.png', '#7ca5d8'], ['ISU', 'drawn-isu.png', '#ef4050'], ['ARK', 'drawn-ark.png', '#f05a67']]
WEST_TEAMS = [['ARIZ', 'drawn-ariz.png', '#ef4050'], ['LOU', 'drawn-lou.png', '#f03a47'], ['GONZ', 'drawn-gonz.png', '#4a86df'], ['MIA', 'drawn-mia.png', '#48ba83']]
SOUTH_TEAMS = [['FLA', 'drawn-fla.png', '#ff6a2a'], ['SJU', 'drawn-sju.png', '#d83f49'], ['UVA', 'drawn-uva.png', '#4f83c2'], ['KU', 'drawn-ku.png', '#4c8dff']]

TEAM_INFO = {'DUKE': ['EAST', 1], 'FLA': ['SOUTH', 1], 'ARIZ': ['WEST', 1], 'ILL': ['MIDWEST', 1], 'CONN': ['MIDWEST', 2], 'HOU': ['EAST', 2], 'LOU': ['WEST', 2], 'SJU': ['SOUTH', 2], 'UVA': ['SOUTH', 3], 'GONZ': ['WEST', 3], 'ISU': ['MIDWEST', 3], 'BAMA': ['EAST', 3], 'ARK': ['MIDWEST', 4], 'MSU': ['EAST', 4], 'MIA': ['WEST', 4], 'KU': ['SOUTH', 4], 'TTU': ['MIDWEST', 5], 'TENN': ['WEST', 5], 'TEX': ['EAST', 5], 'MICH': ['SOUTH', 5], 'UK': ['MIDWEST', 6], 'VAND': ['WEST', 6], 'UCLA': ['SOUTH', 6], 'NEB': ['EAST', 6], 'USC': ['MIDWEST', 7], 'BYU': ['WEST', 7], 'BAY': ['SOUTH', 7], 'CREI': ['EAST', 7], 'OSU': ['WEST', 8], 'MARQ': ['MIDWEST', 8], 'MIZ': ['EAST', 8], 'PROV': ['SOUTH', 8], 'NOVA': ['EAST', 9], 'PUR': ['SOUTH', 9], 'UNC': ['MIDWEST', 9], 'TAMU': ['WEST', 9], 'CIN': ['MIDWEST', 10], 'CLEM': ['WEST', 10], 'AUB': ['SOUTH', 10], 'TCU': ['EAST', 10], 'IOWA': ['EAST', 10], 'MD': ['SOUTH', 10], 'IND': ['WEST', 11], 'OU': ['EAST', 11], 'USU': ['EAST', 11], 'VT': ['MIDWEST', 11], 'WIS': ['MIDWEST', 11], 'WVU': ['SOUTH', 11], 'MISS': ['SOUTH', 11], 'SMU': ['WEST', 11], 'GCU': ['WEST', 12], 'VCU': ['MIDWEST', 12], 'SMC': ['SOUTH', 12], 'HPU': ['EAST', 12], 'WICH': ['MIDWEST', 13], 'MUR': ['EAST', 13], 'MCN': ['WEST', 13], 'UCSD': ['SOUTH', 13], 'UNCW': ['EAST', 14], 'AKR': ['MIDWEST', 14], 'WKU': ['WEST', 14], 'PENN': ['SOUTH', 14], 'JMU': ['WEST', 15], 'MTST': ['SOUTH', 15], 'WRST': ['MIDWEST', 15], 'FUR': ['MIDWEST', 15], 'NDSU': ['EAST', 15], 'UCA': ['EAST', 15], 'HOW': ['MIDWEST', 16], 'UVM': ['MIDWEST', 16], 'MRMK': ['WEST', 16], 'TNST': ['WEST', 16], 'BCU': ['SOUTH', 16], 'AMER': ['SOUTH', 16], 'QUC': ['EAST', 16], 'LIU': ['EAST', 16]}

# Bright primary/secondary school-color accents chosen to remain readable on black.
TEAM_COLORS = {
    "DUKE": "#4f9dff", "CONN": "#7ca5d8", "MICH": "#f5c542", "TENN": "#ff8200",
    "ILL": "#ff6a2a", "LOU": "#f03a47", "TEX": "#e87532", "KU": "#4c8dff",
    "ARIZ": "#ef4050", "MSU": "#41ad83", "GONZ": "#4a86df", "BAMA": "#e85a66",
    "FLA": "#ff6a2a", "HOU": "#f04b55", "UVA": "#4f83c2", "ARK": "#f05a67",
    "OSU": "#e96873", "AUB": "#ff9a43", "ISU": "#ef4050", "WSU": "#d43d52",
    "LIB": "#c94a5a", "UK": "#4c8dff", "AKR": "#55a9e8", "UCLA": "#57a5ff",
    "TAMU": "#e34b56", "MIZ": "#f1bd38", "UNC": "#58a8ff", "SJU": "#d83f49",
    "ILST": "#ee4048", "USC": "#f49a30", "MCN": "#ffd520", "NEB": "#f34b53",
    "MTST": "#68a3eb", "UGA": "#f34a54", "WIS": "#e84953", "MIA": "#48ba83",
    "SCU": "#ee474f", "HPU": "#ab80f2", "BYU": "#5e9ce6", "VCU": "#f1c344",
    "YALE": "#65a7ff", "VAND": "#e9bc46", "PROV": "#d0d6df", "MARQ": "#f4c64e",
    "IND": "#e24a53", "TTU": "#e4444d", "UNM": "#d94c57", "PUR": "#d7aa39",
    "UNCW": "#43bcb4", "NOVA": "#5a94d9", "UCA": "#b58bff", "UCSB": "#4f9cda",
    "WVU": "#f1c344", "CREI": "#4b85d6", "NCST": "#e44751", "OKST": "#f27b36",
    "ORE": "#57a876", "MD": "#e34b56", "ASU": "#c05a63", "MISS": "#d94c57",
    "SMU": "#e34b56", "MINN": "#e34b56", "FSU": "#d34b59", "UCF": "#e5bd44",
}

# Fill missing palettes with the schools' published primary/secondary colors.
TEAM_COLORS.update({"ACU":"#B1B3B3","AF":"#FFFFFF","AAMU":"#FFFFFF","ALST":"#E9A900","ALCN":"#46166A","AMER":"#C8102E","APP":"#FFCD00","ARST":"#CC092F","UAPB":"#E0AA0F","ARMY":"#D3BC8D","APSU":"#8E0B0B","BALL":"#FFFFFF","BAY":"#FFB81C","BELL":"#000000","BEL":"#C9262D","BCU":"#E9AA12","BING":"#F0F0F0","BOIS":"#D64309","BC":"#DBCCA6","BU":"#FFFFFF","BGSU":"#FD5000","BRAD":"#C0C0C0","BRWN":"#949300","BRY":"#9F8343","BUCK":"#00316E","BUF":"#FFFFFF","BTLR":"#00A3E0","CP":"#EED897","CSUB":"#003BAB","CSUF":"#FF8300","CSUN":"#B50000","CBU":"#000080","CAL":"#FFC72C","CAM":"#000000","CAN":"#DDA50F","CCSU":"#D1D5D8","CMU":"#FBAB18","COFC":"#9E8959","CHSO":"#DED090","CLT":"#A49665","UTC":"#DCA71D","CHST":"#006700","CIN":"#E00122","CLEM":"#F56600","CLE":"#006633","CCU":"#006F71","COLG":"#FFFFFF","COLO":"#CFB87C","CSU":"#C8C372","COLU":"#7BA4DB","COPP":"#FFD204","COR":"#FFFFFF","DART":"#005730","DAV":"#E51837","DAY":"#FFFFFF","DEL":"#FFD200","DSU":"#009CDB","DEN":"#A8996E","DEP":"#2D649C","DETM":"#165B9E","DRKE":"#BEC0C2","DREX":"#FFD65A","DUQ":"#B90B2E","ECU":"#FFC72C","ETSU":"#FFC423","ETAM":"#000000","EIU":"#BEBAB9","EKU":"#F0F0F0","EMU":"#FFFFFF","EWU":"#ABB4BC","ELON":"#B59A57","EVAN":"#663399","FAIR":"#EBEBEB","FDU":"#72293C","FAMU":"#F89728","FAU":"#CC0000","FGCU":"#00885A","FIU":"#C3993F","FOR":"#909090","FRES":"#B1102B","FUR":"#FFFFFF","GWEB":"#C12535","GMU":"#ECB010","GW":"#E8D2A1","GTWN":"#001C58","GASO":"#A3AAAE","GAST":"#FFFFFF","GT":"#B3A369","GRAM":"#EE8601","GCU":"#FFFFFF","GB":"#FFFFFF","HAMP":"#0067AC","HARV":"#DBDBDB","HAW":"#005737","HOF":"#FFC72C","HC":"#FFFFFF","HCU":"#00539C","HOW":"#E51937","IDST":"#EF8C00","IDHO":"#8C6E4A","UIW":"#080808","INST":"#00669A","IONA":"#F0AB00","IOWA":"#FCD116","IUIN":"#D59F0F","JKST":"#B5B7BA","JAX":"#00523E","JXST":"#CC0000","JMU":"#CBB677","KC":"#FFC72C","KSU":"#E2E3E4","KENN":"#FDBB30","KENT":"#EAAB00","LAS":"#FFCE00","LAF":"#A59474","LAM":"#EBEBEB","LEH":"#B69E70","LIP":"#F6B734","LR":"#898D8F","LBSU":"#F1F2F3","LIU":"#50C9F7","LONG":"#9EA2A3","UL":"#CE181E","LT":"#CB333B","LUC":"#9D1244","LMD":"#76A7A0","LMU":"#880029","NOLA":"#FDD023","LSU":"#FDD023","ME":"#127DBE","MAN":"#4F8537","MRST":"#E53730","MRSH":"#00B140","UMES":"#B5B7BA","MASS":"#FFFFFF","MEM":"#8E908F","MER":"#FF7F29","MERC":"#000000","MRMK":"#2F4F93","MOH":"#FFFFFF","MTSU":"#036EB7","MILW":"#FFC20E","MSST":"#C1C6C8","MVSU":"#CF2D34","MOST":"#FFFFFF","MONM":"#051844","MONT":"#666666","MORE":"#FED91A","MORG":"#F47937","MSM":"#EBEBEB","MUR":"#002148","NAVY":"#B5A67C","NEV":"#8A8D8F","UNH":"#C3C4C6","NHVN":"#FFC425","NMSU":"#7E141B","NIA":"#F0F0F0","NICH":"#F0F0F0","NJIT":"#EE3024","NORF":"#0C8968","UNA":"#663399","NCAT":"#004684","NCCU":"#C2C3C0","UND":"#00A26B","NDSU":"#FFFFFF","UNF":"#BABCBE","UNT":"#068F33","NE":"#C2C3C0","NAU":"#1B3069","UNCO":"#FFC533","NIU":"#C8102E","UNI":"#FFFFFF","NKU":"#FFC82E","NWST":"#ED6118","NU":"#FFFFFF","ND":"#C99700","OAK":"#BC955C","OHIO":"#FFFFFF","OU":"#FFFFFF","ODU":"#A1D2F1","OMA":"#E3193E","ORU":"#DAC792","ORST":"#DC4405","PAC":"#F47820","PSU":"#FFFFFF","PENN":"#A6163D","PEPP":"#DC762F","PITT":"#FFB81C","PORT":"#A8B3BA","PRST":"#EBEBEB","PV":"#EAAA00","PRES":"#194896","PRIN":"#FF6000","PFW":"#CFB991","QUIN":"#041B43","RAD":"#C2C3C0","URI":"#5AB3E8","RICE":"#C1C6C8","RICH":"#B90B2E","RID":"#EBEBEB","RMU":"#A21D2B","RUTG":"#FFFFFF","SAC":"#CDB97D","SHU":"#C29472","JOES":"#6C6F70","SLU":"#EBEBEB","SMC":"#D80024","SPU":"#004CC2","SHSU":"#F56423","SAM":"#005485","SDSU":"#A6192E","USD":"#2F99D4","SF":"#FFFFFF","SJSU":"#FFB81A","SELA":"#FFC72C","SEA":"#BF2E1A","HALL":"#8A8D8F","SIE":"#037961","SIUE":"#EB1C23","USA":"#BF0D3E","SC":"#73000A","SCST":"#104897","UPST":"#008545","SDAK":"#CD1241","SDST":"#FFD100","USF":"#CFC493","SEMO":"#C8102E","SIU":"#C2C3C0","SOU":"#FFC82D","USM":"#FFC72C","SUU":"#C72026","SBU":"#70261D","STMN":"#000000","STAN":"#FFFFFF","SFA":"#BEC0C2","STET":"#56854E","STO":"#000000","STBK":"#990000","SYR":"#FF431B","TAR":"#000000","TCU":"#FFFFFF","TEM":"#FFFFFF","TNST":"#F0F0F0","TNTC":"#5A4099","AMCC":"#0067C5","TXSO":"#FFFFFF","TXST":"#6A5638","CIT":"#7BADD3","TOL":"#FFCD00","TOW":"#FFC229","TROY":"#B1B1B1","TULN":"#418FDE","TLSA":"#D0B787","UAB":"#FDB913","UALB":"#FFFFFF","UCD":"#C3C4C6","UCI":"#FEC52E","UCR":"#14234F","UCSD":"#FFCD00","UIC":"#D50032","ULM":"#FDB913","UML":"#CF1F2F","UMBC":"#AD860A","UNCA":"#FFFFFF","UNCG":"#FFD90A","UNLV":"#CAC8C8","UTA":"#F58024","UTM":"#FF6700","RGV":"#DC6000","USU":"#FFFFFF","UTU":"#000000","UTAH":"#FFFFFF","UVU":"#E1C736","UTEP":"#FF8200","UTSA":"#F15A22","VAL":"#794500","UVM":"#FFC72C","VT":"#CF4520","VMI":"#AE122A","WAG":"#FFFFFF","WAKE":"#CEB888","WASH":"#E8D3A2","WEB":"#EBEBEB","WGA":"#DB1A21","WCU":"#BF9E70","WIU":"#FFC90A","WKU":"#E13A3E","WMU":"#F1C500","WICH":"#FFCD00","WM":"#F0B323","WIN":"#FDB41E","WOF":"#F0F0F0","WRST":"#CBA052","WYO":"#FFC425","XAV":"#A5A7A8","YSU":"#E51935"})

# Display names for the current preview field. Keep provider codes for compact
# matchup references, but use readable school names on detail and bubble views.
TEAM_NAMES = {
    "DUKE": "DUKE", "CONN": "UCONN", "MICH": "MICHIGAN", "TENN": "TENNESSEE",
    "ILL": "ILLINOIS", "LOU": "LOUISVILLE", "TEX": "TEXAS", "KU": "KANSAS",
    "ARIZ": "ARIZONA", "MSU": "MICHIGAN ST", "GONZ": "GONZAGA", "BAMA": "ALABAMA",
    "FLA": "FLORIDA", "HOU": "HOUSTON", "UVA": "VIRGINIA", "ARK": "ARKANSAS",
    "OSU": "OHIO STATE", "AUB": "AUBURN", "ISU": "IOWA STATE", "WSU": "WASHINGTON ST",
    "LIB": "LIBERTY", "UK": "KENTUCKY", "AKR": "AKRON", "UCLA": "UCLA",
    "TAMU": "TEXAS A&M", "MIZ": "MISSOURI", "UNC": "NORTH CAROLINA", "SJU": "ST JOHN'S",
    "ILST": "ILLINOIS ST", "USC": "USC", "MCN": "MCNEESE", "NEB": "NEBRASKA",
    "MTST": "MONTANA ST", "UGA": "GEORGIA", "WIS": "WISCONSIN", "MIA": "MIAMI",
    "SCU": "SANTA CLARA", "HPU": "HIGH POINT", "BYU": "BYU", "VCU": "VCU",
    "YALE": "YALE", "VAND": "VANDERBILT", "PROV": "PROVIDENCE", "MARQ": "MARQUETTE",
    "IND": "INDIANA", "TTU": "TEXAS TECH", "UNM": "NEW MEXICO", "PUR": "PURDUE",
    "UNCW": "UNC WILMINGTON", "NOVA": "VILLANOVA", "UCA": "CENTRAL ARKANSAS", "UCSB": "UC SANTA BARBARA",
    "WVU": "WEST VIRGINIA", "CREI": "CREIGHTON", "NCST": "NC STATE", "OKST": "OKLAHOMA ST",
    "ORE": "OREGON", "MD": "MARYLAND", "ASU": "ARIZONA ST", "MISS": "OLE MISS",
    "SMU": "SMU", "MINN": "MINNESOTA", "FSU": "FLORIDA STATE", "UCF": "UCF",
}
# Remaining Division I teams, generated from the checked 365-team catalog.
TEAM_NAMES.update({
    "ACU": "ABILENE CHRISTIAN",
    "AF": "AIR FORCE",
    "AAMU": "ALABAMA A&M",
    "ALST": "ALABAMA STATE",
    "ALCN": "ALCORN STATE",
    "AMER": "AMERICAN UNIVERSITY",
    "APP": "APP STATE",
    "ARST": "ARKANSAS STATE",
    "UAPB": "ARKANSAS-PINE BLUFF",
    "ARMY": "ARMY",
    "APSU": "AUSTIN PEAY",
    "BALL": "BALL STATE",
    "BAY": "BAYLOR",
    "BELL": "BELLARMINE",
    "BEL": "BELMONT",
    "BCU": "BETHUNE-COOKMAN",
    "BING": "BINGHAMTON",
    "BOIS": "BOISE STATE",
    "BC": "BOSTON COLLEGE",
    "BU": "BOSTON UNIVERSITY",
    "BGSU": "BOWLING GREEN",
    "BRAD": "BRADLEY",
    "BRWN": "BROWN",
    "BRY": "BRYANT",
    "BUCK": "BUCKNELL",
    "BUF": "BUFFALO",
    "BTLR": "BUTLER",
    "CP": "CAL POLY",
    "CSUB": "CAL STATE BAKERSFIELD",
    "CSUF": "CAL STATE FULLERTON",
    "CSUN": "CAL STATE NORTHRIDGE",
    "CBU": "CALIFORNIA BAPTIST",
    "CAL": "CALIFORNIA",
    "CAM": "CAMPBELL",
    "CAN": "CANISIUS",
    "CCSU": "CENTRAL CONNECTICUT",
    "CMU": "CENTRAL MICHIGAN",
    "COFC": "CHARLESTON",
    "CHSO": "CHARLESTON SOUTHERN",
    "CLT": "CHARLOTTE",
    "UTC": "CHATTANOOGA",
    "CHST": "CHICAGO STATE",
    "CIN": "CINCINNATI",
    "CLEM": "CLEMSON",
    "CLE": "CLEVELAND STATE",
    "CCU": "COASTAL CAROLINA",
    "COLG": "COLGATE",
    "COLO": "COLORADO",
    "CSU": "COLORADO STATE",
    "COLU": "COLUMBIA",
    "COPP": "COPPIN STATE",
    "COR": "CORNELL",
    "DART": "DARTMOUTH",
    "DAV": "DAVIDSON",
    "DAY": "DAYTON",
    "DEL": "DELAWARE",
    "DSU": "DELAWARE STATE",
    "DEN": "DENVER",
    "DEP": "DEPAUL",
    "DETM": "DETROIT MERCY",
    "DRKE": "DRAKE",
    "DREX": "DREXEL",
    "DUQ": "DUQUESNE",
    "ECU": "EAST CAROLINA",
    "ETSU": "EAST TENNESSEE STATE",
    "ETAM": "EAST TEXAS A&M",
    "EIU": "EASTERN ILLINOIS",
    "EKU": "EASTERN KENTUCKY",
    "EMU": "EASTERN MICHIGAN",
    "EWU": "EASTERN WASHINGTON",
    "ELON": "ELON",
    "EVAN": "EVANSVILLE",
    "FAIR": "FAIRFIELD",
    "FDU": "FAIRLEIGH DICKINSON",
    "FAMU": "FLORIDA A&M",
    "FAU": "FLORIDA ATLANTIC",
    "FGCU": "FLORIDA GULF COAST",
    "FIU": "FLORIDA INTERNATIONAL",
    "FOR": "FORDHAM",
    "FRES": "FRESNO STATE",
    "FUR": "FURMAN",
    "GWEB": "GARDNER-WEBB",
    "GMU": "GEORGE MASON",
    "GW": "GEORGE WASHINGTON",
    "GTWN": "GEORGETOWN",
    "GASO": "GEORGIA SOUTHERN",
    "GAST": "GEORGIA STATE",
    "GT": "GEORGIA TECH",
    "GRAM": "GRAMBLING",
    "GCU": "GRAND CANYON",
    "GB": "GREEN BAY",
    "HAMP": "HAMPTON",
    "HARV": "HARVARD",
    "HAW": "HAWAI'I",
    "HOF": "HOFSTRA",
    "HC": "HOLY CROSS",
    "HCU": "HOUSTON CHRISTIAN",
    "HOW": "HOWARD",
    "IDST": "IDAHO STATE",
    "IDHO": "IDAHO",
    "UIW": "INCARNATE WORD",
    "INST": "INDIANA STATE",
    "IONA": "IONA",
    "IOWA": "IOWA",
    "IUIN": "IU INDIANAPOLIS",
    "JKST": "JACKSON STATE",
    "JAX": "JACKSONVILLE",
    "JXST": "JACKSONVILLE STATE",
    "JMU": "JAMES MADISON",
    "KC": "KANSAS CITY",
    "KSU": "KANSAS STATE",
    "KENN": "KENNESAW STATE",
    "KENT": "KENT STATE",
    "LAS": "LA SALLE",
    "LAF": "LAFAYETTE",
    "LAM": "LAMAR",
    "LEM": "LE MOYNE",
    "LEH": "LEHIGH",
    "LIN": "LINDENWOOD",
    "LIP": "LIPSCOMB",
    "LR": "LITTLE ROCK",
    "LBSU": "LONG BEACH STATE",
    "LIU": "LONG ISLAND UNIVERSITY",
    "LONG": "LONGWOOD",
    "UL": "LOUISIANA",
    "LT": "LOUISIANA TECH",
    "LUC": "LOYOLA CHICAGO",
    "LMD": "LOYOLA MARYLAND",
    "LMU": "LOYOLA MARYMOUNT",
    "NOLA": "NEW ORLEANS",
    "LSU": "LSU",
    "ME": "MAINE",
    "MAN": "MANHATTAN",
    "MRST": "MARIST",
    "MRSH": "MARSHALL",
    "UMES": "MARYLAND EASTERN SHORE",
    "MASS": "MASSACHUSETTS",
    "MEM": "MEMPHIS",
    "MER": "MERCER",
    "MERC": "MERCYHURST",
    "MRMK": "MERRIMACK",
    "MOH": "MIAMI (OH)",
    "MTSU": "MIDDLE TENNESSEE",
    "MILW": "MILWAUKEE",
    "MSST": "MISSISSIPPI STATE",
    "MVSU": "MISSISSIPPI VALLEY STATE",
    "MOST": "MISSOURI STATE",
    "MONM": "MONMOUTH",
    "MONT": "MONTANA",
    "MORE": "MOREHEAD STATE",
    "MORG": "MORGAN STATE",
    "MSM": "MOUNT ST. MARY'S",
    "MUR": "MURRAY STATE",
    "NAVY": "NAVY",
    "NEV": "NEVADA",
    "UNH": "NEW HAMPSHIRE",
    "NHVN": "NEW HAVEN",
    "NMSU": "NEW MEXICO STATE",
    "NIA": "NIAGARA",
    "NICH": "NICHOLLS",
    "NJIT": "NJIT",
    "NORF": "NORFOLK STATE",
    "UNA": "NORTH ALABAMA",
    "NCAT": "NORTH CAROLINA A&T",
    "NCCU": "NORTH CAROLINA CENTRAL",
    "UND": "NORTH DAKOTA",
    "NDSU": "NORTH DAKOTA STATE",
    "UNF": "NORTH FLORIDA",
    "UNT": "NORTH TEXAS",
    "NE": "NORTHEASTERN",
    "NAU": "NORTHERN ARIZONA",
    "UNCO": "NORTHERN COLORADO",
    "NIU": "NORTHERN ILLINOIS",
    "UNI": "NORTHERN IOWA",
    "NKU": "NORTHERN KENTUCKY",
    "NWST": "NORTHWESTERN STATE",
    "NU": "NORTHWESTERN",
    "ND": "NOTRE DAME",
    "OAK": "OAKLAND",
    "OHIO": "OHIO",
    "OU": "OKLAHOMA",
    "ODU": "OLD DOMINION",
    "OMA": "OMAHA",
    "ORU": "ORAL ROBERTS",
    "ORST": "OREGON STATE",
    "PAC": "PACIFIC",
    "PSU": "PENN STATE",
    "PENN": "PENNSYLVANIA",
    "PEPP": "PEPPERDINE",
    "PITT": "PITTSBURGH",
    "PORT": "PORTLAND",
    "PRST": "PORTLAND STATE",
    "PV": "PRAIRIE VIEW A&M",
    "PRES": "PRESBYTERIAN",
    "PRIN": "PRINCETON",
    "PFW": "PURDUE FORT WAYNE",
    "QUC": "QUEENS UNIVERSITY",
    "QUIN": "QUINNIPIAC",
    "RAD": "RADFORD",
    "URI": "RHODE ISLAND",
    "RICE": "RICE",
    "RICH": "RICHMOND",
    "RID": "RIDER",
    "RMU": "ROBERT MORRIS",
    "RUTG": "RUTGERS",
    "SAC": "SACRAMENTO STATE",
    "SHU": "SACRED HEART",
    "SFPA": "SAINT FRANCIS",
    "JOES": "SAINT JOSEPH'S",
    "SLU": "SAINT LOUIS",
    "SMC": "SAINT MARY'S",
    "SPU": "SAINT PETER'S",
    "SHSU": "SAM HOUSTON",
    "SAM": "SAMFORD",
    "SDSU": "SAN DIEGO STATE",
    "USD": "SAN DIEGO",
    "SF": "SAN FRANCISCO",
    "SJSU": "SAN JOS\u00c9 STATE",
    "SELA": "SE LOUISIANA",
    "SEA": "SEATTLE U",
    "HALL": "SETON HALL",
    "SIE": "SIENA",
    "SIUE": "SIU EDWARDSVILLE",
    "USA": "SOUTH ALABAMA",
    "SC": "SOUTH CAROLINA",
    "SCST": "SOUTH CAROLINA STATE",
    "UPST": "SOUTH CAROLINA UPSTATE",
    "SDAK": "SOUTH DAKOTA",
    "SDST": "SOUTH DAKOTA STATE",
    "USF": "SOUTH FLORIDA",
    "SEMO": "SOUTHEAST MISSOURI STATE",
    "SIU": "SOUTHERN ILLINOIS",
    "USI": "SOUTHERN INDIANA",
    "SOU": "SOUTHERN",
    "USM": "SOUTHERN MISS",
    "SUU": "SOUTHERN UTAH",
    "SBU": "ST. BONAVENTURE",
    "STMN": "ST. THOMAS",
    "STAN": "STANFORD",
    "SFA": "STEPHEN F. AUSTIN",
    "STET": "STETSON",
    "STO": "STONEHILL",
    "STBK": "STONY BROOK",
    "SYR": "SYRACUSE",
    "TAR": "TARLETON STATE",
    "TCU": "TCU",
    "TEM": "TEMPLE",
    "TNST": "TENNESSEE STATE",
    "TNTC": "TENNESSEE TECH",
    "AMCC": "TEXAS A&M-CORPUS CHRISTI",
    "TXSO": "TEXAS SOUTHERN",
    "TXST": "TEXAS ST",
    "CIT": "THE CITADEL",
    "TOL": "TOLEDO",
    "TOW": "TOWSON",
    "TROY": "TROY",
    "TULN": "TULANE",
    "TLSA": "TULSA",
    "UAB": "UAB",
    "UALB": "UALBANY",
    "UCD": "UC DAVIS",
    "UCI": "UC IRVINE",
    "UCR": "UC RIVERSIDE",
    "UCSD": "UC SAN DIEGO",
    "UIC": "UIC",
    "ULM": "UL MONROE",
    "UML": "UMASS LOWELL",
    "UMBC": "UMBC",
    "UNCA": "UNC ASHEVILLE",
    "UNCG": "UNC GREENSBORO",
    "UNLV": "UNLV",
    "UTA": "UT ARLINGTON",
    "UTM": "UT MARTIN",
    "RGV": "UT RIO GRANDE VALLEY",
    "USU": "UTAH STATE",
    "UTU": "UTAH TECH",
    "UTAH": "UTAH",
    "UVU": "UTAH VALLEY",
    "UTEP": "UTEP",
    "UTSA": "UTSA",
    "VAL": "VALPARAISO",
    "UVM": "VERMONT",
    "VT": "VIRGINIA TECH",
    "VMI": "VMI",
    "WAG": "WAGNER",
    "WAKE": "WAKE FOREST",
    "WASH": "WASHINGTON",
    "WEB": "WEBER STATE",
    "WGA": "WEST GEORGIA",
    "WCU": "WESTERN CAROLINA",
    "WIU": "WESTERN ILLINOIS",
    "WKU": "WESTERN KENTUCKY",
    "WMU": "WESTERN MICHIGAN",
    "WICH": "WICHITA STATE",
    "WM": "WILLIAM & MARY",
    "WIN": "WINTHROP",
    "WOF": "WOFFORD",
    "WRST": "WRIGHT STATE",
    "WYO": "WYOMING",
    "XAV": "XAVIER",
    "YSU": "YOUNGSTOWN STATE",
})


def selected_view(ctx):
    view = ctx.inputs.get("view", "My Team")
    if view in ["Field of 64", "Full Field", "Top 4 Seeds", "My Team", "Your Team", "Bubble", "Opening Round"]:
        return view
    # Retired preview settings and invalid saved inputs must not show blank pages.
    return "My Team"

def region_for_slot(_projection, c, slot):
    if slot == 1:
        region_page(_projection, c, "EAST", "NEW YORK", _projection["EAST_TEAMS"], "region-east-reference-v2.png")
    elif slot == 2:
        region_page(_projection, c, "MIDWEST", "KANSAS CITY", _projection["MIDWEST_TEAMS"], "region-midwest-reference.png")
    elif slot == 3:
        region_page(_projection, c, "WEST", "LOS ANGELES", _projection["WEST_TEAMS"], "region-west-reference.png")
    else:
        region_page(_projection, c, "SOUTH", "SAN ANTONIO", _projection["SOUTH_TEAMS"], "region-south-reference.png")

def top_four(c):
    c.fill("black")
    c.rect(8, 4, 184, 25, fill = DARK)
    tight_text(c, "ESPN10/6", 184, 1, font = "3x4", color = MUTED, align = "right")
    tight_text(c, "PROJECTED #1 SEEDS", 96, 2, font = "4x5", color = LIGHT, align = "center")
    teams = [["DUKE", "#4f9dff"], ["ILL", "#ff6a2a"], ["ARIZ", "#ef4050"], ["FLA", "#ff6a2a"]]
    for i in range(4):
        x = 32 + i * 43
        tight_text(c, "1", x, 11, font = "4x5", color = MUTED, align = "center")
        tight_text(c, teams[i][0], x, 19, font = "4x5", color = teams[i][1], align = "center")

REGION_MATCHUPS = [['EAST', 'NEW YORK', 'region-east-reference-v2.png', [['DUKE', 'drawn-duke.png', '#4f9dff'], ['HOU', 'drawn-hou.png', '#f04b55'], ['BAMA', 'drawn-bama.png', '#e85a66'], ['MSU', 'drawn-msu.png', '#41ad83']], [['1', 'DUKE', '16', 'TBD'], ['8', 'MIZ', '9', 'NOVA'], ['5', 'TEX', '12', 'HPU'], ['4', 'MSU', '13', 'MUR'], ['6', 'NEB', '11', 'TBD'], ['3', 'BAMA', '14', 'UNCW'], ['7', 'CREI', '10', 'TBD'], ['2', 'HOU', '15', 'TBD']]], ['MIDWEST', 'KANSAS CITY', 'region-midwest-reference.png', [['ILL', 'drawn-ill.png', '#ff6a2a'], ['CONN', 'drawn-conn.png', '#7ca5d8'], ['ISU', 'drawn-isu.png', '#ef4050'], ['ARK', 'drawn-ark.png', '#f05a67']], [['1', 'ILL', '16', 'TBD'], ['8', 'MARQ', '9', 'UNC'], ['5', 'TTU', '12', 'VCU'], ['4', 'ARK', '13', 'WICH'], ['6', 'UK', '11', 'TBD'], ['3', 'ISU', '14', 'AKR'], ['7', 'USC', '10', 'CIN'], ['2', 'CONN', '15', 'TBD']]], ['WEST', 'LOS ANGELES', 'region-west-reference.png', [['ARIZ', 'drawn-ariz.png', '#ef4050'], ['LOU', 'drawn-lou.png', '#f03a47'], ['GONZ', 'drawn-gonz.png', '#4a86df'], ['MIA', 'drawn-mia.png', '#48ba83']], [['1', 'ARIZ', '16', 'TBD'], ['8', 'OSU', '9', 'TAMU'], ['5', 'TENN', '12', 'GCU'], ['4', 'MIA', '13', 'MCN'], ['6', 'VAND', '11', 'TBD'], ['3', 'GONZ', '14', 'WKU'], ['7', 'BYU', '10', 'CLEM'], ['2', 'LOU', '15', 'JMU']]], ['SOUTH', 'SAN ANTONIO', 'region-south-reference.png', [['FLA', 'drawn-fla.png', '#ff6a2a'], ['SJU', 'drawn-sju.png', '#d83f49'], ['UVA', 'drawn-uva.png', '#4f83c2'], ['KU', 'drawn-ku.png', '#4c8dff']], [['1', 'FLA', '16', 'TBD'], ['8', 'PROV', '9', 'PUR'], ['5', 'MICH', '12', 'SMC'], ['4', 'KU', '13', 'UCSD'], ['6', 'UCLA', '11', 'TBD'], ['3', 'UVA', '14', 'PENN'], ['7', 'BAY', '10', 'TBD'], ['2', 'SJU', '15', 'MTST']]]]

# ESPN's Oct. 6, 2026 bracket projects six same-group auto-qualifier games
# and six at-large games in the expanded Opening Round. Each entry is
# [seed, team A, team B].
OPENING_ROUND_AUTO = [[[16, 'QUC', 'LIU'], [15, 'NDSU', 'UCA'], [16, 'MRMK', 'TNST']], [[16, 'HOW', 'UVM'], [15, 'WRST', 'FUR'], [16, 'AMER', 'BCU']]]
OPENING_ROUND_AT_LARGE = [[[11, 'OU', 'USU'], [10, 'TCU', 'IOWA'], [11, 'IND', 'SMU']], [[11, 'VT', 'WIS'], [11, 'MISS', 'WVU'], [10, 'AUB', 'MD']]]


# Full Field text-only contrast adjustments. Keep other views and school logos
# on their established palette; small seven-pixel labels need brighter tones.
FULL_FIELD_COLORS = {
    "USU": "white",  # User-approved contrast exception for Utah State text.
    "MUR": "#ECAC00",  # Murray State athletics secondary gold.
    "UVA": "#70a4e3", "GONZ": "#639aef", "WSU": "#ed6375",
    "LIB": "#e47080", "SJU": "#ef6570", "TAMU": "#ee6974",
    "WIS": "#f16c75", "IND": "#ef6d76", "TTU": "#f16870",
    "UNM": "#eb707b", "NOVA": "#79aceb", "MSU": "#61c79d",
}

# Non-neutral school colors for abbreviation text. Where the listed secondary
# is white/black, use the school's non-neutral primary instead. Logos unchanged.
TEAM_COLORS.update({
    "AF": "#003594", "AAMU": "#790000", "BALL": "#BA0C2F",
    "BELL": "#B3B3B3", "BU": "#CC0000", "BUF": "#005BBB",
    "CAM": "#EA7125", "COLG": "#821019", "COR": "#B31B1B",
    "DAY": "#004B8D", "ETAM": "#F1B20F", "EMU": "#006938",
    "FUR": "#582C83", "GAST": "#0039A6", "GCU": "#522398",
    "GB": "#006633", "HC": "#582C83", "MASS": "#881C1C",
    "MERC": "#FF7F29", "MOH": "#C41230", "MOST": "#5E0009",
    "NDSU": "#01402A", "UNI": "#473282", "NU": "#492F92",
    "OHIO": "#154734", "OU": "#990000", "PSU": "#061440",
    "RUTG": "#CE0E2D", "SF": "#005A36", "STMN": "#510C76",
    "STAN": "#8C1515", "STO": "#2F2975", "TAR": "#4F2D7F", "TCU": "#4D1979",
    "TEM": "#A41E35", "TXSO": "#860038", "UALB": "#3D2777",
    "UNCA": "#003DA5", "USU": "#0F2439", "UTU": "#BA1C21",
    "UTAH": "#BE0000", "WAG": "#00483A",
})

def full_field_color(team):
    if team == "TBD": return "#889098"
    return FULL_FIELD_COLORS.get(team, TEAM_COLORS.get(team, LIGHT))

def full_field_page(_projection, c, slot):
    c.fill("black")
    if slot <= 4:
        region_index = slot - 1
        region = _projection["REGION_MATCHUPS"][region_index]
        if slot == 1:
            for letter_index, letter in enumerate(["E", "A", "S", "T"]):
                tight_text(c, letter, 3, letter_index * 8, font = "5x7", color = BLUE)
                tight_text(c, letter, 4, letter_index * 8, font = "5x7", color = BLUE)
        elif slot == 3:
            for letter_index, letter in enumerate(["W", "E", "S", "T"]):
                letter_font = "6x8" if letter == "W" else "5x7"
                letter_y = letter_index * 8 + (1 if letter_index > 0 else 0)
                if letter == "W":
                    tight_text(c, letter, 3, letter_y, font = letter_font, color = BLUE)
                else:
                    tight_text(c, letter, 3, letter_y, font = letter_font, color = BLUE)
                    tight_text(c, letter, 4, letter_y, font = letter_font, color = BLUE)
        elif slot == 2:
            tight_text(c, "M", 0, 0, font = "4x5", color = BLUE)
            tight_text(c, "I", 5, 0, font = "4x5", color = BLUE)
            tight_text(c, "D", 9, 0, font = "4x5", color = BLUE)
            for letter_index, letter in enumerate(["W", "E", "S", "T"]):
                letter_y = 7 + letter_index * 6
                letter_x = 4
                tight_text(c, letter, letter_x, letter_y, font = "4x5", color = BLUE)
                tight_text(c, letter, letter_x + 1, letter_y, font = "4x5", color = BLUE)
        else:
            for letter_index, letter in enumerate(["S", "O", "U", "T", "H"]):
                tight_text(c, letter, 4, 1 + letter_index * 6, font = "4x5", color = BLUE)
                tight_text(c, letter, 5, 1 + letter_index * 6, font = "4x5", color = BLUE)
        c.line(13, 0, 13, 31, color = GRID)
        # Four equal 48-pixel sections run horizontally. Each shows two games as
        # stacked team lines, with their winners connected into the next round.
        # Use only the three internal dividers so the zones share one line and
        # no pixels are spent on outer or duplicate box borders.
        for divider_index, divider_x in enumerate([57, 99, 147]):
            if divider_index == 1:
                divider_x += 3
            c.line(divider_x, 0, divider_x, 31, color = GRID)
        for section in range(4):
            # Shift each bracket group two pixels to the right while trimming
            # the same amount from its right edge to stay inside its section.
            x = section * 48 + (9 if section == 1 else 12 if section == 0 else 6 if section == 2 else 3)
            y = 0
            first_game = region[4][section * 2]
            second_game = region[4][section * 2 + 1]
            for game_index, game in enumerate([first_game, second_game]):
                top_y = y + game_index * 16
                bottom_y = top_y + 8
                left_color = full_field_color(game[1])
                right_color = full_field_color(game[3])
                team_x = x + 12
                game_rail_x = x + 35
                # Each team name sits just above its bracket underline. Those
                # underlines meet at a shared game rail; the winner exits from
                # the midpoint between the two team lines.
                top_line = top_y + 7
                bottom_line = bottom_y + 7
                game_mid = top_y + 11
                top_seed_x = (x if "1" in game[0] else x + 1) + 2 + (1 if section == 0 else 0)
                bottom_seed_x = (x if "1" in game[2] else x + 1) + 2 + (1 if section == 0 else 0)
                # Start every regional underline at a fixed offset from its
                # bracket group so the extensions beneath seeds stay uniform.
                top_line_start = x + 2
                bottom_line_start = x + 2
                c.line(top_line_start, top_line, game_rail_x, top_line, color = BLUE)
                c.line(bottom_line_start, bottom_line, game_rail_x, bottom_line, color = BLUE)
                c.line(game_rail_x, top_line, game_rail_x, bottom_line, color = BLUE)
                c.line(game_rail_x, game_mid, x + 38, game_mid, color = BLUE)
                tight_text(c, game[0], top_seed_x, top_y + 1, font = "picopixel", color = MUTED)
                left_font = "3x4" if "/" in game[1] else "5x7"
                right_font = "3x4" if "/" in game[3] else "5x7"
                if game[1] == "TBD":
                    c.text("OPEN", team_x - 1, top_y + 2, font = "3x4", color = full_field_color("TBD"))
                    c.text("RD", team_x + 16, top_y + 2, font = "3x4", color = full_field_color("TBD"))
                else:
                    tight_text(c, game[1], team_x, top_y, font = left_font, color = left_color)
                tight_text(c, game[2], bottom_seed_x, bottom_y + 1, font = "picopixel", color = MUTED)
                if game[3] == "TBD":
                    # Approved opening-round treatment. 3x4 has no space glyph;
                    # draw words separately with the reviewed pixel offsets.
                    c.text("OPEN", team_x - 1, bottom_y + 2, font = "3x4", color = full_field_color("TBD"))
                    c.text("RD", team_x + 16, bottom_y + 2, font = "3x4", color = full_field_color("TBD"))
                else:
                    tight_text(c, game[3], team_x, bottom_y, font = right_font, color = right_color)
            # The two game winners meet at a small next-round feed on the right.
            c.line(x + 41, y + 11, x + 41, y + 27, color = BLUE)
            c.line(x + 38, y + 11, x + 41, y + 11, color = BLUE)
            c.line(x + 38, y + 27, x + 41, y + 27, color = BLUE)
            winner_end_x = x + 44
            c.line(x + 41, y + 19, winner_end_x, y + 19, color = BLUE)
    elif slot == 5:
        tight_text(c, "OPENING ROUND", 7, 1, font = "4x5", color = BLUE)
        tight_text(c, "ESPN10/6", 184, 1, font = "3x4", color = MUTED, align = "right")
        for row, games in enumerate(_projection["OPENING_ROUND_AUTO"] + _projection["OPENING_ROUND_AT_LARGE"]):
            y = 7 + row * 6
            if row:
                c.line(3, y - 1, 189, y - 1, color = "#27313d")
            for column, game in enumerate(games):
                label = str(game[0]) + " " + game[1] + "/" + game[2]
                tight_text(c, label, 3 + column * 64, y, font = "4x5", color = LIGHT)
    elif slot == 6:
        tight_text(c, "REGION #1 SEEDS", 7, 2, font = "4x5", color = BLUE)
        tight_text(c, "ESPN10/6", 182, 2, font = "3x4", color = MUTED, align = "right")
        for i in range(4):
            team = _projection["REGION_MATCHUPS"][i][3][0]
            x = 25 + i * 47
            tight_text(c, "1", x, 10, font = "4x5", color = MUTED, align = "center")
            tight_text(c, team[0], x, 19, font = "4x5", color = team[2], align = "center")
    else:
        tight_text(c, "CUT LINE", 7, 2, font = "4x5", color = BLUE)
        tight_text(c, "ESPN10/6", 182, 2, font = "3x4", color = MUTED, align = "right")
        tight_text(c, "LAST FOUR IN", 8, 9, font = "4x5", color = GREEN)
        for i, team in enumerate(["WVU", "CREI", "NCST", "OKST"]):
            tight_text(c, team, 8 + i * 45, 15, font = "3x4", color = TEAM_COLORS.get(team, GREEN))
        tight_text(c, "FIRST FOUR OUT", 8, 21, font = "4x5", color = RED)
        for i, team in enumerate(["ORE", "MD", "ASU", "MISS"]):
            tight_text(c, team, 8 + i * 45, 27, font = "3x4", color = TEAM_COLORS.get(team, RED))

def top_four_page(_projection, c, slot):
    region_index = slot - 1
    region = _projection["REGION_MATCHUPS"][region_index]
    source_panel(c, region[0], region[1], region[2])
    for i in range(4):
        team = region[3][i]
        y = 1 + i * 7
        c.image(team[1], 48, y, w = 14, h = 12)
        tight_text(c, str(i + 1), 68, y + 2, font = "4x5", color = MUTED)
        tight_text(c, team[0], 84, y + 2, font = "4x5", color = team[2])

def top_four_summary(_projection, c, seed):
    c.fill("black")
    tight_text(c, "PROJECTED #" + str(seed) + " SEEDS", 8, 2, font = "4x5", color = BLUE)
    tight_text(c, "ESPN10/6", 182, 2, font = "3x4", color = MUTED, align = "right")
    for i in range(4):
        team = _projection["REGION_MATCHUPS"][i][3][seed - 1]
        x = 25 + i * 47
        tight_text(c, str(seed), x, 10, font = "4x5", color = MUTED, align = "center")
        tight_text(c, team[0], x, 19, font = "4x5", color = team[2], align = "center")

def bracket_slot_for(_projection, team_code):
    for region in _projection["REGION_MATCHUPS"]:
        for game_index in range(len(region[4])):
            game = region[4][game_index]
            if game[1] == team_code:
                return [region[0], game[0], game[3], game[2], game_index]
            if game[3] == team_code:
                return [region[0], game[2], game[1], game[0], game_index]
    return None

def abbr_width(code):
    width = 6 * len(code) - 1
    for letter in code.elems():
        if letter == "T": width -= 2
        elif letter == "I": width -= 1
    return width

def draw_abbr(c, code, x, y, color, center = False):
    label = code.upper()
    width = abbr_width(label)
    if center: x -= width // 2
    cursor = x
    for letter in label.elems():
        tight_text(c, letter, cursor, y, font = "4x5", color = color)
        tight_text(c, letter, cursor + 1, y, font = "4x5", color = color)
        cursor += 4 if letter == "T" else 5 if letter == "I" else 6


TEAM_LOGO_FILES = {
    "ACU": "drawn-acu.png",
    "AF": "drawn-af.png",
    "AKR": "drawn-akr.png",
    "AAMU": "drawn-aamu.png",
    "BAMA": "drawn-bama.png",
    "ALST": "drawn-alst.png",
    "ALCN": "drawn-alcn.png",
    "AMER": "drawn-amer.png",
    "APP": "drawn-app.png",
    "ASU": "drawn-asu.png",
    "ARIZ": "drawn-ariz.png",
    "ARK": "drawn-ark.png",
    "ARST": "drawn-arst.png",
    "UAPB": "drawn-uapb.png",
    "ARMY": "drawn-army.png",
    "AUB": "drawn-aub.png",
    "APSU": "drawn-apsu.png",
    "BALL": "drawn-ball.png",
    "BAY": "drawn-bay.png",
    "BELL": "drawn-bell.png",
    "BEL": "drawn-bel.png",
    "BCU": "drawn-bcu.png",
    "BING": "drawn-bing.png",
    "BOIS": "drawn-bois.png",
    "BC": "drawn-bc.png",
    "BU": "drawn-bu.png",
    "BGSU": "drawn-bgsu.png",
    "BRAD": "drawn-brad.png",
    "BRWN": "drawn-brwn.png",
    "BRY": "drawn-bry.png",
    "BUCK": "drawn-buck.png",
    "BUF": "drawn-buf.png",
    "BTLR": "drawn-btlr.png",
    "BYU": "drawn-byu.png",
    "CP": "drawn-cp.png",
    "CSUB": "drawn-csub.png",
    "CSUF": "drawn-csuf.png",
    "CSUN": "drawn-csun.png",
    "CBU": "drawn-cbu.png",
    "CAL": "drawn-cal.png",
    "CAM": "drawn-cam.png",
    "CAN": "drawn-can.png",
    "UCA": "drawn-uca.png",
    "CCSU": "drawn-ccsu.png",
    "CMU": "drawn-cmu.png",
    "COFC": "drawn-cofc.png",
    "CHSO": "drawn-chso.png",
    "CLT": "drawn-clt.png",
    "UTC": "drawn-utc.png",
    "CHST": "drawn-chst.png",
    "CIN": "drawn-cin.png",
    "CLEM": "drawn-clem.png",
    "CLE": "drawn-cle.png",
    "CCU": "drawn-ccu.png",
    "COLG": "drawn-colg.png",
    "COLO": "drawn-colo.png",
    "CSU": "drawn-csu.png",
    "COLU": "drawn-colu.png",
    "COPP": "drawn-copp.png",
    "COR": "drawn-cor.png",
    "CREI": "drawn-crei.png",
    "DART": "drawn-dart.png",
    "DAV": "drawn-dav.png",
    "DAY": "drawn-day.png",
    "DEL": "drawn-del.png",
    "DSU": "drawn-dsu.png",
    "DEN": "drawn-den.png",
    "DEP": "drawn-dep.png",
    "DETM": "drawn-detm.png",
    "DRKE": "drawn-drke.png",
    "DREX": "drawn-drex.png",
    "DUKE": "drawn-duke.png",
    "DUQ": "drawn-duq.png",
    "ECU": "drawn-ecu.png",
    "ETSU": "drawn-etsu.png",
    "ETAM": "drawn-etam.png",
    "EIU": "drawn-eiu.png",
    "EKU": "drawn-eku.png",
    "EMU": "drawn-emu.png",
    "EWU": "drawn-ewu.png",
    "ELON": "drawn-elon.png",
    "EVAN": "drawn-evan.png",
    "FAIR": "drawn-fair.png",
    "FDU": "drawn-fdu.png",
    "FAMU": "drawn-famu.png",
    "FAU": "drawn-fau.png",
    "FLA": "drawn-fla.png",
    "FGCU": "drawn-fgcu.png",
    "FIU": "drawn-fiu.png",
    "FSU": "drawn-fsu.png",
    "FOR": "drawn-for.png",
    "FRES": "drawn-fres.png",
    "FUR": "drawn-fur.png",
    "GWEB": "drawn-gweb.png",
    "GMU": "drawn-gmu.png",
    "GW": "drawn-gw.png",
    "GTWN": "drawn-gtwn.png",
    "UGA": "drawn-uga.png",
    "GASO": "drawn-gaso.png",
    "GAST": "drawn-gast.png",
    "GT": "drawn-gt.png",
    "GONZ": "drawn-gonz.png",
    "GRAM": "drawn-gram.png",
    "GCU": "drawn-gcu.png",
    "GB": "drawn-gb.png",
    "HAMP": "drawn-hamp.png",
    "HARV": "drawn-harv.png",
    "HAW": "drawn-haw.png",
    "HPU": "drawn-hpu.png",
    "HOF": "drawn-hof.png",
    "HC": "drawn-hc.png",
    "HCU": "drawn-hcu.png",
    "HOU": "drawn-hou.png",
    "HOW": "drawn-how.png",
    "IDST": "drawn-idst.png",
    "IDHO": "drawn-idho.png",
    "ILL": "drawn-ill.png",
    "ILST": "drawn-ilst.png",
    "UIW": "drawn-uiw.png",
    "IND": "drawn-ind.png",
    "INST": "drawn-inst.png",
    "IONA": "drawn-iona.png",
    "IOWA": "drawn-iowa.png",
    "ISU": "drawn-isu.png",
    "IUIN": "drawn-iuin.png",
    "JKST": "drawn-jkst.png",
    "JAX": "drawn-jax.png",
    "JXST": "drawn-jxst.png",
    "JMU": "drawn-jmu.png",
    "KC": "drawn-kc.png",
    "KU": "drawn-ku.png",
    "KSU": "drawn-ksu.png",
    "KENN": "drawn-kenn.png",
    "KENT": "drawn-kent.png",
    "UK": "drawn-uk.png",
    "LAS": "drawn-las.png",
    "LAF": "drawn-laf.png",
    "LAM": "drawn-lam.png",
    "LEM": "drawn-lem.png",
    "LEH": "drawn-leh.png",
    "LIB": "drawn-lib.png",
    "LIN": "drawn-lin.png",
    "LIP": "drawn-lip.png",
    "LR": "drawn-lr.png",
    "LBSU": "drawn-lbsu.png",
    "LIU": "drawn-liu.png",
    "LONG": "drawn-long.png",
    "UL": "drawn-ul.png",
    "LT": "drawn-lt.png",
    "LOU": "drawn-lou.png",
    "LUC": "drawn-luc.png",
    "LMD": "drawn-lmd.png",
    "LMU": "drawn-lmu.png",
    "NOLA": "drawn-nola.png",
    "LSU": "drawn-lsu.png",
    "ME": "drawn-me.png",
    "MAN": "drawn-man.png",
    "MRST": "drawn-mrst.png",
    "MARQ": "drawn-marq.png",
    "MRSH": "drawn-mrsh.png",
    "UMES": "drawn-umes.png",
    "MD": "drawn-md.png",
    "MASS": "drawn-mass.png",
    "MCN": "drawn-mcn.png",
    "MEM": "drawn-mem.png",
    "MER": "drawn-mer.png",
    "MERC": "drawn-merc.png",
    "MRMK": "drawn-mrmk.png",
    "MOH": "drawn-moh.png",
    "MIA": "drawn-mia.png",
    "MSU": "drawn-msu.png",
    "MICH": "drawn-mich.png",
    "MTSU": "drawn-mtsu.png",
    "MILW": "drawn-milw.png",
    "MINN": "drawn-minn.png",
    "MSST": "drawn-msst.png",
    "MVSU": "drawn-mvsu.png",
    "MOST": "drawn-most.png",
    "MIZ": "drawn-miz.png",
    "MONM": "drawn-monm.png",
    "MONT": "drawn-mont.png",
    "MTST": "drawn-mtst.png",
    "MORE": "drawn-more.png",
    "MORG": "drawn-morg.png",
    "MSM": "drawn-msm.png",
    "MUR": "drawn-mur.png",
    "NAVY": "drawn-navy.png",
    "NCST": "drawn-ncst.png",
    "NEB": "drawn-neb.png",
    "NEV": "drawn-nev.png",
    "UNH": "drawn-unh.png",
    "NHVN": "drawn-nhvn.png",
    "UNM": "drawn-unm.png",
    "NMSU": "drawn-nmsu.png",
    "NIA": "drawn-nia.png",
    "NICH": "drawn-nich.png",
    "NJIT": "drawn-njit.png",
    "NORF": "drawn-norf.png",
    "UNA": "drawn-una.png",
    "NCAT": "drawn-ncat.png",
    "NCCU": "drawn-nccu.png",
    "UNC": "drawn-unc.png",
    "UND": "drawn-und.png",
    "NDSU": "drawn-ndsu.png",
    "UNF": "drawn-unf.png",
    "UNT": "drawn-unt.png",
    "NE": "drawn-ne.png",
    "NAU": "drawn-nau.png",
    "UNCO": "drawn-unco.png",
    "NIU": "drawn-niu.png",
    "UNI": "drawn-uni.png",
    "NKU": "drawn-nku.png",
    "NWST": "drawn-nwst.png",
    "NU": "drawn-nu.png",
    "ND": "drawn-nd.png",
    "OAK": "drawn-oak.png",
    "OHIO": "drawn-ohio.png",
    "OSU": "drawn-osu.png",
    "OU": "drawn-ou.png",
    "OKST": "drawn-okst.png",
    "ODU": "drawn-odu.png",
    "MISS": "drawn-miss.png",
    "OMA": "drawn-oma.png",
    "ORU": "drawn-oru.png",
    "ORE": "drawn-ore.png",
    "ORST": "drawn-orst.png",
    "PAC": "drawn-pac.png",
    "PSU": "drawn-psu.png",
    "PENN": "drawn-penn.png",
    "PEPP": "drawn-pepp.png",
    "PITT": "drawn-pitt.png",
    "PORT": "drawn-port.png",
    "PRST": "drawn-prst.png",
    "PV": "drawn-pv.png",
    "PRES": "drawn-pres.png",
    "PRIN": "drawn-prin.png",
    "PROV": "drawn-prov.png",
    "PUR": "drawn-pur.png",
    "PFW": "drawn-pfw.png",
    "QUC": "drawn-quc.png",
    "QUIN": "drawn-quin.png",
    "RAD": "drawn-rad.png",
    "URI": "drawn-uri.png",
    "RICE": "drawn-rice.png",
    "RICH": "drawn-rich.png",
    "RID": "drawn-rid.png",
    "RMU": "drawn-rmu.png",
    "RUTG": "drawn-rutg.png",
    "SAC": "drawn-sac.png",
    "SHU": "drawn-shu.png",
    "SFPA": "drawn-sfpa.png",
    "JOES": "drawn-joes.png",
    "SLU": "drawn-slu.png",
    "SMC": "smc-original-38x25.png",
    "SPU": "drawn-spu.png",
    "SHSU": "drawn-shsu.png",
    "SAM": "drawn-sam.png",
    "SDSU": "drawn-sdsu.png",
    "USD": "drawn-usd.png",
    "SF": "drawn-sf.png",
    "SJSU": "drawn-sjsu.png",
    "SCU": "drawn-scu.png",
    "SELA": "drawn-sela.png",
    "SEA": "drawn-sea.png",
    "HALL": "drawn-hall.png",
    "SIE": "drawn-sie.png",
    "SIUE": "drawn-siue.png",
    "SMU": "drawn-smu.png",
    "USA": "drawn-usa.png",
    "SC": "drawn-sc.png",
    "SCST": "drawn-scst.png",
    "UPST": "drawn-upst.png",
    "SDAK": "drawn-sdak.png",
    "SDST": "drawn-sdst.png",
    "USF": "drawn-usf.png",
    "SEMO": "drawn-semo.png",
    "SIU": "drawn-siu.png",
    "USI": "drawn-usi.png",
    "SOU": "drawn-sou.png",
    "USM": "drawn-usm.png",
    "SUU": "drawn-suu.png",
    "SBU": "drawn-sbu.png",
    "SJU": "drawn-sju.png",
    "STMN": "drawn-stmn.png",
    "STAN": "drawn-stan.png",
    "SFA": "drawn-sfa.png",
    "STET": "drawn-stet.png",
    "STO": "drawn-sto.png",
    "STBK": "drawn-stbk.png",
    "SYR": "drawn-syr.png",
    "TAR": "drawn-tar.png",
    "TCU": "drawn-tcu.png",
    "TEM": "drawn-tem.png",
    "TNST": "drawn-tnst.png",
    "TNTC": "drawn-tntc.png",
    "TENN": "drawn-tenn.png",
    "TAMU": "drawn-tamu.png",
    "AMCC": "drawn-amcc.png",
    "TEX": "drawn-tex.png",
    "TXSO": "drawn-txso.png",
    "TXST": "drawn-txst.png",
    "TTU": "drawn-ttu.png",
    "CIT": "drawn-cit.png",
    "TOL": "drawn-tol.png",
    "TOW": "drawn-tow.png",
    "TROY": "drawn-troy.png",
    "TULN": "drawn-tuln.png",
    "TLSA": "drawn-tlsa.png",
    "UAB": "drawn-uab.png",
    "UALB": "drawn-ualb.png",
    "UCD": "drawn-ucd.png",
    "UCI": "drawn-uci.png",
    "UCR": "drawn-ucr.png",
    "UCSD": "drawn-ucsd.png",
    "UCSB": "drawn-ucsb.png",
    "UCF": "drawn-ucf.png",
    "UCLA": "drawn-ucla.png",
    "CONN": "drawn-conn.png",
    "UIC": "drawn-uic.png",
    "ULM": "drawn-ulm.png",
    "UML": "drawn-uml.png",
    "UMBC": "drawn-umbc.png",
    "UNCA": "drawn-unca.png",
    "UNCG": "drawn-uncg.png",
    "UNCW": "drawn-uncw.png",
    "UNLV": "drawn-unlv.png",
    "USC": "drawn-usc.png",
    "UTA": "drawn-uta.png",
    "UTM": "drawn-utm.png",
    "RGV": "drawn-rgv.png",
    "USU": "drawn-usu.png",
    "UTU": "drawn-utu.png",
    "UTAH": "drawn-utah.png",
    "UVU": "drawn-uvu.png",
    "UTEP": "drawn-utep.png",
    "UTSA": "drawn-utsa.png",
    "VAL": "drawn-val.png",
    "VAND": "drawn-vand.png",
    "VCU": "drawn-vcu.png",
    "UVM": "drawn-uvm.png",
    "NOVA": "drawn-nova.png",
    "UVA": "drawn-uva.png",
    "VT": "drawn-vt.png",
    "VMI": "drawn-vmi.png",
    "WAG": "drawn-wag.png",
    "WAKE": "drawn-wake.png",
    "WASH": "drawn-wash.png",
    "WSU": "drawn-wsu.png",
    "WEB": "drawn-web.png",
    "WGA": "drawn-wga.png",
    "WVU": "drawn-wvu.png",
    "WCU": "drawn-wcu.png",
    "WIU": "drawn-wiu.png",
    "WKU": "drawn-wku.png",
    "WMU": "drawn-wmu.png",
    "WICH": "drawn-wich.png",
    "WM": "drawn-wm.png",
    "WIN": "drawn-win.png",
    "WIS": "drawn-wis.png",
    "WOF": "drawn-wof.png",
    "WRST": "drawn-wrst.png",
    "WYO": "drawn-wyo.png",
    "XAV": "drawn-xav.png",
    "YALE": "drawn-yale.png",
    "YSU": "drawn-ysu.png",
}

TEAM_LOGO_BOUNDS = {
    "AAMU": [23,24,1,0,21,23],
    "ACU": [23,24,0,4,22,20],
    "AF": [23,24,0,1,22,23],
    "AKR": [26,23,0,4,25,18],
    "ALCN": [23,24,0,2,22,22],
    "ALST": [23,24,0,7,22,17],
    "AMCC": [23,24,5,0,18,23],
    "AMER": [23,24,0,2,22,21],
    "APP": [23,24,1,0,21,23],
    "APSU": [23,24,1,0,22,23],
    "ARIZ": [26,23,1,0,25,21],
    "ARK": [26,23,0,5,25,17],
    "ARMY": [23,24,1,0,21,23],
    "ARST": [23,24,0,0,22,23],
    "ASU": [26,23,7,0,19,22],
    "AUB": [26,23,0,0,25,22],
    "BALL": [23,24,3,0,19,23],
    "BAMA": [26,23,0,0,25,23],
    "BAY": [23,24,2,0,21,23],
    "BC": [23,24,0,2,22,22],
    "BCU": [23,24,0,0,22,23],
    "BEL": [23,24,0,1,22,22],
    "BELL": [23,24,3,0,20,23],
    "BGSU": [23,24,0,1,22,22],
    "BING": [23,24,0,2,22,22],
    "BOIS": [23,24,0,3,22,21],
    "BRAD": [23,24,2,0,21,23],
    "BRWN": [23,24,2,0,21,23],
    "BRY": [23,24,0,3,22,21],
    "BTLR": [23,24,0,1,22,22],
    "BU": [23,24,0,3,22,21],
    "BUCK": [23,24,0,4,22,19],
    "BUF": [23,24,0,1,22,22],
    "BYU": [26,23,0,3,25,19],
    "CAL": [23,24,0,3,22,20],
    "CAM": [23,24,0,5,22,18],
    "CAN": [23,24,0,0,22,23],
    "CBU": [23,24,0,7,22,16],
    "CCSU": [23,24,1,0,21,23],
    "CCU": [23,24,1,0,22,23],
    "CHSO": [23,24,0,4,22,20],
    "CHST": [23,24,0,1,22,22],
    "CIN": [23,24,4,0,19,23],
    "CIT": [23,24,0,2,22,21],
    "CLE": [23,24,0,0,22,23],
    "CLEM": [23,24,0,1,22,22],
    "CLT": [23,24,2,0,20,23],
    "CMU": [23,24,0,4,22,20],
    "COFC": [23,24,2,0,21,23],
    "COLG": [23,24,0,2,22,22],
    "COLO": [23,24,0,4,22,20],
    "COLU": [23,24,1,0,21,23],
    "CONN": [26,23,2,0,22,23],
    "COPP": [23,24,0,5,22,19],
    "COR": [23,24,2,0,20,23],
    "CP": [23,24,0,1,22,23],
    "CREI": [26,23,1,0,24,23],
    "CSU": [23,24,0,1,22,23],
    "CSUB": [23,24,0,4,22,20],
    "CSUF": [23,24,4,0,19,23],
    "CSUN": [23,24,4,0,19,23],
    "DART": [23,24,2,0,21,23],
    "DAV": [23,24,1,0,22,23],
    "DAY": [23,24,0,5,22,19],
    "DEL": [23,24,0,4,22,19],
    "DEN": [23,24,0,8,22,15],
    "DEP": [23,24,0,0,22,23],
    "DETM": [23,24,0,4,22,20],
    "DREX": [23,24,0,4,22,20],
    "DRKE": [23,24,1,0,22,23],
    "DSU": [23,24,0,2,22,22],
    "DUKE": [26,23,1,2,24,23],
    "DUQ": [23,24,6,0,17,23],
    "ECU": [23,24,0,0,22,23],
    "EIU": [23,24,0,2,22,21],
    "EKU": [23,24,0,8,22,15],
    "ELON": [23,24,1,0,22,23],
    "EMU": [23,24,1,0,21,23],
    "ETAM": [23,24,0,1,22,23],
    "ETSU": [23,24,0,1,22,23],
    "EVAN": [23,24,0,3,22,21],
    "EWU": [23,24,0,1,22,22],
    "FAIR": [23,24,0,2,22,21],
    "FAMU": [23,24,0,4,22,20],
    "FAU": [23,24,0,5,22,18],
    "FDU": [23,24,0,1,22,22],
    "FGCU": [23,24,0,4,22,20],
    "FIU": [23,24,1,0,21,23],
    "FLA": [26,23,0,3,25,19],
    "FOR": [23,24,0,1,22,23],
    "FRES": [23,24,0,4,22,20],
    "FSU": [26,23,1,0,24,23],
    "FUR": [23,24,0,2,22,22],
    "GASO": [23,24,0,5,22,18],
    "GAST": [23,24,0,3,22,21],
    "GB": [23,24,0,3,22,20],
    "GCU": [23,24,0,8,22,16],
    "GMU": [23,24,0,3,22,20],
    "GONZ": [26,23,1,2,25,20],
    "GRAM": [23,24,0,5,22,19],
    "GT": [23,24,0,5,22,19],
    "GTWN": [23,24,0,2,22,22],
    "GW": [23,24,0,4,22,19],
    "GWEB": [23,24,0,2,22,22],
    "HALL": [23,24,0,1,22,23],
    "HAMP": [23,24,0,3,22,21],
    "HARV": [23,24,2,0,21,23],
    "HAW": [23,24,0,3,22,20],
    "HC": [23,24,2,0,21,23],
    "HCU": [23,24,0,0,22,23],
    "HOF": [23,24,0,3,22,21],
    "HOU": [26,23,0,0,25,22],
    "HOW": [23,24,0,2,22,21],
    "HPU": [26,23,0,4,25,19],
    "IDHO": [23,24,1,0,22,23],
    "IDST": [23,24,0,1,22,22],
    "ILL": [26,23,4,0,21,23],
    "ILST": [26,23,0,4,25,19],
    "IND": [26,23,4,0,22,23],
    "INST": [23,24,0,2,22,21],
    "IONA": [23,24,0,3,22,20],
    "IOWA": [23,24,0,5,22,19],
    "ISU": [26,23,2,4,24,19],
    "IUIN": [23,24,0,1,22,22],
    "JAX": [23,24,0,5,22,19],
    "JKST": [23,24,0,5,22,19],
    "JMU": [23,24,0,8,22,15],
    "JOES": [23,24,0,4,22,20],
    "JXST": [23,24,0,4,22,19],
    "KC": [23,24,0,1,22,22],
    "KENN": [23,24,0,1,22,22],
    "KENT": [23,24,0,5,22,18],
    "KSU": [23,24,0,4,22,20],
    "KU": [26,23,0,0,25,22],
    "LAF": [23,24,0,1,22,22],
    "LAM": [23,24,0,1,22,22],
    "LAS": [23,24,0,1,22,22],
    "LBSU": [23,24,2,0,21,23],
    "LEH": [23,24,0,1,22,22],
    "LEM": [23,24,0,6,22,18],
    "LIB": [26,23,0,0,25,23],
    "LIN": [23,24,0,4,22,20],
    "LIP": [23,24,2,0,21,23],
    "LIU": [23,24,1,0,21,23],
    "LMD": [23,24,1,0,22,23],
    "LMU": [23,24,0,7,22,17],
    "LONG": [23,24,0,5,22,18],
    "LOU": [26,23,2,0,23,23],
    "LR": [23,24,1,0,22,23],
    "LSU": [23,24,0,8,22,15],
    "LT": [23,24,0,2,22,22],
    "LUC": [23,24,0,3,22,21],
    "MAN": [23,24,0,3,22,21],
    "MARQ": [26,23,0,0,25,22],
    "MASS": [23,24,0,3,22,21],
    "MCN": [26,23,2,0,23,23],
    "MD": [26,23,2,0,23,23],
    "ME": [23,24,0,3,22,20],
    "MEM": [23,24,0,2,22,21],
    "MER": [23,24,0,3,22,20],
    "MERC": [23,24,0,1,22,22],
    "MIA": [26,23,0,4,25,19],
    "MICH": [26,23,0,4,25,21],
    "MILW": [23,24,0,8,22,16],
    "MINN": [26,23,0,4,25,19],
    "MISS": [26,23,0,0,25,23],
    "MIZ": [26,23,0,4,25,18],
    "MOH": [23,24,0,3,22,20],
    "MONM": [23,24,0,3,22,20],
    "MONT": [23,24,0,4,22,20],
    "MORE": [23,24,0,1,22,23],
    "MORG": [23,24,0,1,22,22],
    "MOST": [23,24,0,2,22,21],
    "MRMK": [26,23,0,1,26,21],
    "MRSH": [23,24,0,5,22,19],
    "MRST": [23,24,0,1,22,22],
    "MSM": [23,24,0,6,22,18],
    "MSST": [23,24,0,6,22,18],
    "MSU": [26,23,3,0,23,23],
    "MTST": [26,23,0,2,25,21],
    "MTSU": [23,24,0,5,22,18],
    "MUR": [23,24,1,0,22,23],
    "MVSU": [23,24,0,2,22,22],
    "NAU": [23,24,0,5,22,18],
    "NAVY": [23,24,2,0,21,23],
    "NCAT": [23,24,2,0,21,23],
    "NCCU": [23,24,0,6,22,17],
    "NCST": [26,23,4,0,21,23],
    "ND": [23,24,0,2,22,22],
    "NDSU": [23,24,0,6,22,17],
    "NE": [23,24,2,0,20,23],
    "NEB": [26,23,1,0,24,23],
    "NEV": [23,24,0,5,22,19],
    "NHVN": [23,24,0,3,22,21],
    "NIA": [23,24,0,7,22,16],
    "NICH": [23,24,0,6,22,17],
    "NIU": [23,24,0,1,22,22],
    "NJIT": [23,24,0,2,22,21],
    "NKU": [23,24,0,5,22,18],
    "NMSU": [23,24,0,4,22,20],
    "NOLA": [23,24,0,1,22,23],
    "NORF": [23,24,0,0,22,23],
    "NOVA": [26,23,0,0,25,22],
    "NU": [23,24,4,0,19,23],
    "NWST": [23,24,5,0,18,23],
    "OAK": [23,24,0,3,22,21],
    "ODU": [23,24,0,3,22,21],
    "OHIO": [23,24,0,6,22,17],
    "OKST": [26,23,0,5,25,18],
    "OMA": [23,24,0,1,22,22],
    "ORE": [26,23,0,1,25,22],
    "ORST": [23,24,0,6,22,18],
    "ORU": [23,24,0,5,22,18],
    "OSU": [26,23,1,0,24,23],
    "OU": [23,24,2,0,20,23],
    "PAC": [23,24,0,4,22,20],
    "PENN": [23,24,2,0,21,23],
    "PEPP": [23,24,1,0,21,23],
    "PFW": [23,24,0,0,22,23],
    "PITT": [23,24,0,6,22,18],
    "PORT": [23,24,0,1,22,22],
    "PRES": [23,24,0,1,22,23],
    "PRIN": [23,24,2,0,20,23],
    "PROV": [26,23,0,3,25,20],
    "PRST": [23,24,2,0,20,23],
    "PSU": [23,24,0,4,22,19],
    "PUR": [26,23,0,5,25,18],
    "PV": [23,24,0,1,22,22],
    "QUC": [23,24,0,2,22,22],
    "QUIN": [23,24,1,0,21,23],
    "RAD": [23,24,0,1,22,23],
    "RGV": [23,24,0,3,22,20],
    "RICE": [23,24,2,0,21,23],
    "RICH": [23,24,3,0,20,23],
    "RID": [23,24,0,5,22,18],
    "RMU": [23,24,0,7,22,17],
    "RUTG": [23,24,0,2,22,21],
    "SAC": [23,24,0,2,22,21],
    "SAM": [23,24,0,0,22,23],
    "SBU": [23,24,0,0,22,23],
    "SC": [23,24,1,0,22,23],
    "SCST": [23,24,2,0,21,23],
    "SCU": [26,23,4,0,22,23],
    "SDAK": [23,24,2,0,21,23],
    "SDST": [23,24,0,3,22,20],
    "SDSU": [23,24,0,4,22,19],
    "SEA": [23,24,1,0,21,23],
    "SELA": [23,24,1,0,21,23],
    "SEMO": [23,24,0,3,22,21],
    "SF": [23,24,0,2,22,22],
    "SFA": [23,24,0,1,22,22],
    "SFPA": [23,24,0,5,22,18],
    "SHSU": [23,24,0,3,22,21],
    "SHU": [23,24,0,7,22,16],
    "SIE": [23,24,1,0,22,23],
    "SIU": [23,24,0,5,22,18],
    "SIUE": [23,24,0,3,22,20],
    "SJSU": [23,24,1,0,22,23],
    "SJU": [26,23,5,0,21,23],
    "SLU": [23,24,0,1,22,23],
    "SMC": [38,25,0,0,38,25],
    "SMU": [26,23,0,5,25,18],
    "SOU": [23,24,0,5,22,19],
    "SPU": [23,24,3,0,20,23],
    "STAN": [23,24,4,0,19,23],
    "STBK": [23,24,0,4,22,20],
    "STET": [23,24,1,0,22,23],
    "STMN": [23,24,1,0,21,23],
    "STO": [23,24,0,4,22,20],
    "SUU": [23,24,0,5,22,19],
    "SYR": [23,24,3,0,20,23],
    "TAMU": [26,23,0,1,25,22],
    "TAR": [23,24,0,1,22,22],
    "TCU": [23,24,0,6,22,17],
    "TEM": [23,24,2,0,21,23],
    "TENN": [26,23,1,1,24,22],
    "TEX": [26,23,0,5,25,18],
    "TLSA": [23,24,0,3,22,21],
    "TNST": [23,24,0,2,22,22],
    "TNTC": [23,24,0,2,22,21],
    "TOL": [23,24,0,5,22,18],
    "TOW": [23,24,0,6,22,18],
    "TROY": [23,24,1,0,21,23],
    "TTU": [26,23,2,0,23,23],
    "TULN": [23,24,0,4,22,20],
    "TXSO": [23,24,0,1,22,22],
    "TXST": [23,24,1,0,21,23],
    "UAB": [23,24,0,3,22,21],
    "UALB": [23,24,5,0,17,23],
    "UAPB": [23,24,0,3,22,21],
    "UCA": [26,23,0,2,25,21],
    "UCD": [23,24,0,4,22,20],
    "UCF": [26,23,0,2,25,21],
    "UCI": [23,24,1,0,22,23],
    "UCLA": [26,23,0,5,25,17],
    "UCR": [23,24,0,1,22,22],
    "UCSB": [26,23,0,3,25,20],
    "UCSD": [23,24,0,1,22,23],
    "UGA": [26,23,0,3,25,19],
    "UIC": [23,24,0,7,22,16],
    "UIW": [23,24,0,6,22,18],
    "UK": [26,23,2,2,24,20],
    "UL": [23,24,0,6,22,17],
    "ULM": [23,24,0,4,22,19],
    "UMBC": [23,24,0,2,22,22],
    "UMES": [23,24,0,6,22,17],
    "UML": [23,24,0,7,22,17],
    "UNA": [23,24,0,4,22,20],
    "UNC": [26,23,0,1,25,21],
    "UNCA": [23,24,0,1,22,23],
    "UNCG": [23,24,0,3,22,20],
    "UNCO": [23,24,0,1,22,23],
    "UNCW": [26,23,1,0,25,23],
    "UND": [23,24,0,7,22,17],
    "UNF": [23,24,0,5,22,19],
    "UNH": [23,24,0,4,22,20],
    "UNI": [23,24,0,4,22,19],
    "UNLV": [23,24,0,5,22,18],
    "UNM": [26,23,3,0,22,23],
    "UNT": [23,24,1,0,22,23],
    "UPST": [23,24,0,4,22,19],
    "URI": [23,24,3,0,20,23],
    "USA": [23,24,0,4,22,20],
    "USC": [26,23,5,0,20,23],
    "USD": [23,24,0,1,22,22],
    "USF": [23,24,0,3,22,21],
    "USI": [23,24,0,5,22,19],
    "USM": [23,24,0,6,22,17],
    "USU": [23,24,0,3,22,20],
    "UTA": [23,24,0,3,22,20],
    "UTAH": [23,24,0,2,22,22],
    "UTC": [23,24,0,2,22,21],
    "UTEP": [23,24,0,4,22,20],
    "UTM": [23,24,0,3,22,20],
    "UTSA": [23,24,0,7,22,17],
    "UTU": [23,24,0,6,22,17],
    "UVA": [26,23,0,1,25,21],
    "UVM": [23,24,0,1,22,23],
    "UVU": [23,24,0,4,22,20],
    "VAL": [23,24,0,0,22,23],
    "VAND": [26,23,2,4,24,19],
    "VCU": [26,23,0,6,25,17],
    "VMI": [23,24,0,0,22,23],
    "VT": [23,24,0,7,22,17],
    "WAG": [23,24,1,6,22,17],
    "WAKE": [23,24,0,4,22,19],
    "WASH": [23,24,0,4,22,19],
    "WCU": [23,24,0,4,22,20],
    "WEB": [23,24,0,4,22,20],
    "WGA": [23,24,0,4,22,19],
    "WICH": [23,24,0,3,22,21],
    "WIN": [23,24,0,2,22,21],
    "WIS": [26,23,1,0,24,23],
    "WIU": [23,24,1,0,21,23],
    "WKU": [23,24,0,4,22,20],
    "WM": [23,24,0,3,22,21],
    "WMU": [23,24,0,7,22,16],
    "WOF": [23,24,1,0,22,23],
    "WRST": [23,24,0,3,22,20],
    "WSU": [26,23,1,0,24,23],
    "WVU": [29,22,0,0,29,22],
    "WYO": [23,24,4,0,18,23],
    "XAV": [23,24,0,3,22,20],
    "YALE": [26,23,0,0,25,23],
    "YSU": [23,24,0,5,22,19],
}

SMC_CRISP_ROWS = ['.......................', '.......................', '.......................', '.......................', '.......LLL..LLL........', '........LL..LLL........', '........LLLLLLL........', '..LLLLLLLLLLLLLLLLLLL..', 'LLL...LLL.LL.LLLL..LLL.', 'LLLLLLLWLL..LLL........', '..LLLLLLLLLLLLL........', 'LLL...LLL.LLL.LLL..LLL.', '.LLLLLLLWLLRLLWLLLLLL..', '...LL...LRRRRLL........', '........LRRRRLL........', '........LRRRRLL........', '........LRRRRLL........', '.........LLRLL.........', '..........LLL..........', '.......................', '.......................', '.......................', '.......................', '.......................']

SMC_OUTLINE_FIXES = {"3,6": True, "3,16": True, "5,5": True, "6,5": True, "6,17": True, "7,5": True, "7,17": True, "8,5": True, "8,17": True, "9,5": True, "10,5": True, "11,16": True, "27,16": True, "28,5": True, "29,5": True, "30,5": True, "30,17": True, "31,5": True, "31,17": True, "32,5": True, "32,17": True, "33,5": True, "34,16": True, "35,6": True}

def smc_simple_mark(c, x, y, w, h):
    # Hand-hinted 38x25 variant: separate letters, two-pixel navy strokes,
    # continuous one-pixel silver borders, red shield below the M.
    letters = [
        [14, 7, ["NN.......NN", "NNN.....NNN", "NNNN...NNNN", "NN.NN.NN.NN", "NN..NNN..NN", "NN...N...NN", "NN.......NN", "NN.......NN"]],
        [1, 10, ["..NNNNNNN..", ".NNNNNNNNN.", ".NN........", ".NNNNNNNN..", "..NNNNNNNN.", "........NN.", ".NNNNNNNNN.", "..NNNNNNN.."]],
        [26, 10, ["..NNNNNNN..", ".NNNNNNNNN.", "NN.........", "NN.........", "NN.........", "NN.........", ".NNNNNNNNN.", "..NNNNNNN.."]],
    ]
    grid = [["." for column in range(38)] for row in range(25)]
    for left, top, rows in letters:
        for row, line in enumerate(rows):
            for column in range(len(line)):
                if line[column] != "N": continue
                px, py = left + column, top + row
                for dx, dy in [[-1, 0], [1, 0], [0, -1], [0, 1]]:
                    xx, yy = px + dx, py + dy
                    if xx >= 0 and xx < 38 and yy >= 0 and yy < 25 and grid[yy][xx] == ".": grid[yy][xx] = "S"
    for left, top, rows in letters:
        for row, line in enumerate(rows):
            for column in range(len(line)):
                if line[column] == "N": grid[top + row][left + column] = "N"
    shield = ["SSSSSSSSSSSSS", "SNNRRRRRRRNNS", "SNRRWWWWRRRNS", "SNRRWRRRRRRNS", "SNRRWRWWRRRNS", ".SNRWWWRRRNS.", "..SNRRRRRNS..", "...SNNNNNS...", "....SSSSS...."]
    for row, line in enumerate(shield):
        for column in range(len(line)):
            if line[column] != ".": grid[16 + row][13 + column] = line[column]
    pixels = [[grid[min(24, int((row + 0.5) * 25 / h))][min(37, int((column + 0.5) * 38 / w))] for column in range(w)] for row in range(h)]
    for key, color in [["N", "#0A3155"], ["S", "#D6D6D6"], ["R", "#D80024"], ["W", "#FFFFFF"]]:
        c.bitmap([[1 if value == key else 0 for value in row] for row in pixels], x, y, color = color)

SMC_WHITE_SHIELD_OUTLINE = {"12,13": True, "13,13": True, "14,13": True, "17,13": True, "18,13": True, "19,13": True, "21,13": True, "23,13": True, "24,13": True, "25,13": True, "26,13": True, "12,14": True, "13,14": True, "15,14": True, "16,14": True, "17,14": True, "18,14": True, "22,14": True, "24,14": True, "25,14": True, "26,14": True, "15,15": True, "16,15": True, "17,15": True, "15,16": True, "16,16": True, "18,16": True, "19,16": True, "15,17": True, "16,17": True, "16,18": True, "16,19": True, "18,19": True, "19,20": True, "23,20": True, "15,21": True, "18,21": True, "16,22": True, "18,23": True, "19,23": True}

SMC_WHITE_SHIELD_OUTLINE.update({"20,13": True, "20,14": True, "21,14": True, "21,15": True, "22,15": True, "23,15": True, "22,16": True, "23,16": True, "22,17": True, "23,17": True, "15,18": True, "22,18": True, "23,18": True, "15,19": True, "22,19": True, "23,19": True, "15,20": True, "16,20": True, "21,20": True, "22,20": True, "16,21": True, "17,21": True, "20,21": True, "21,21": True, "22,21": True, "17,22": True, "18,22": True, "19,22": True, "20,22": True, "21,22": True})

SMC_NATIVE_FRAMES = {
    "38x25": ["smc-original-38x25.png", 38, 25],
    "38x24": ["smc-original-36x24.png", 36, 24],
    "34x24": ["smc-original-34x23.png", 34, 23],
    "26x23": ["smc-original-26x17.png", 26, 17],
    "31x24": ["smc-original-31x21.png", 31, 21],
    "29x22": ["smc-original-29x19.png", 29, 19],
    "25x19": ["smc-original-25x17.png", 25, 17],
    "22x20": ["smc-original-22x15.png", 22, 15],
    "24x25": ["smc-original-24x16.png", 24, 16],
    "30x19": ["smc-original-29x19.png", 29, 19],
    "25x22": ["smc-original-25x17.png", 25, 17],
}

def draw_smc_native(c, x, y, w, h, align = "center"):
    # Original navy/silver artwork directly from the user's original PNG.
    # No intermediate 64px image, runtime resizing, or hand-painted overlays.
    frame = SMC_NATIVE_FRAMES[str(w) + "x" + str(h)]
    inset = w - frame[1] if align == "right" else 0 if align == "left" else (w - frame[1]) // 2
    c.image(frame[0], x + inset, y + (h - frame[2]) // 2)

USER_LOGO_FRAMES = {"WRST":{"38x24":["user-wrst-31x24.png",31,24],"34x24":["user-wrst-31x24.png",31,24],"26x23":["user-wrst-26x20.png",26,20],"31x24":["user-wrst-31x24.png",31,24],"29x22":["user-wrst-29x22.png",29,22],"25x19":["user-wrst-25x19.png",25,19],"22x20":["user-wrst-22x17.png",22,17],"24x25":["user-wrst-24x18.png",24,18],"30x19":["user-wrst-25x19.png",25,19],"25x22":["user-wrst-25x19.png",25,19],"28x25":["user-wrst-28x21.png",28,21]},"FUR":{"38x24":["user-fur-24x24.png",24,24],"34x24":["user-fur-24x24.png",24,24],"26x23":["user-fur-23x23.png",23,23],"31x24":["user-fur-24x24.png",24,24],"29x22":["user-fur-22x22.png",22,22],"25x19":["user-fur-19x19.png",19,19],"22x20":["user-fur-20x20.png",20,20],"24x25":["user-fur-24x24.png",24,24],"30x19":["user-fur-19x19.png",19,19],"25x22":["user-fur-22x22.png",22,22],"28x25":["user-fur-26x25.png",26,25]},"NDSU":{"38x24":["user-ndsu-38x19.png",38,19],"34x24":["user-ndsu-34x17.png",34,17],"26x23":["user-ndsu-26x13.png",26,13],"31x24":["user-ndsu-31x16.png",31,16],"29x22":["user-ndsu-29x15.png",29,15],"25x19":["user-ndsu-25x13.png",25,13],"22x20":["user-ndsu-22x11.png",22,11],"24x25":["user-ndsu-24x12.png",24,12],"30x19":["user-ndsu-30x15.png",30,15],"25x22":["user-ndsu-25x13.png",25,13],"28x25":["user-ndsu-28x14.png",28,14]},"UCA":{"38x24":["user-uca-26x24.png",26,24],"34x24":["user-uca-26x24.png",26,24],"26x23":["user-uca-25x23.png",25,23],"31x24":["user-uca-26x24.png",26,24],"29x22":["user-uca-24x22.png",24,22],"25x19":["user-uca-21x19.png",21,19],"22x20":["user-uca-22x20.png",22,20],"24x25":["user-uca-24x22.png",24,22],"30x19":["user-uca-21x19.png",21,19],"25x22":["user-uca-24x22.png",24,22],"28x25":["user-uca-27x25.png",27,25]},"TNST":{"38x24":["user-tnst-26x24.png",26,24],"34x24":["user-tnst-26x24.png",26,24],"26x23":["user-tnst-25x23.png",25,23],"31x24":["user-tnst-26x24.png",26,24],"29x22":["user-tnst-24x22.png",24,22],"25x19":["user-tnst-20x19.png",20,19],"22x20":["user-tnst-22x20.png",22,20],"24x25":["user-tnst-24x22.png",24,22],"30x19":["user-tnst-20x19.png",20,19],"25x22":["user-tnst-24x22.png",24,22],"28x25":["user-tnst-27x25.png",27,25]},"TEX":{"38x24":["user-tex-38x19.png",38,19],"34x24":["user-tex-34x17.png",34,17],"26x23":["user-tex-26x13.png",26,13],"31x24":["user-tex-31x16.png",31,16],"29x22":["user-tex-29x15.png",29,15],"25x19":["user-tex-25x13.png",25,13],"22x20":["user-tex-22x11.png",22,11],"24x25":["user-tex-24x12.png",24,12],"30x19":["user-tex-30x15.png",30,15],"25x22":["user-tex-25x13.png",25,13],"28x25":["user-tex-28x14.png",28,14]},"PENN":{"38x24":["user-penn-20x24.png",20,24],"34x24":["user-penn-20x24.png",20,24],"26x23":["user-penn-19x23.png",19,23],"31x24":["user-penn-20x24.png",20,24],"29x22":["user-penn-18x22.png",18,22],"25x19":["user-penn-16x19.png",16,19],"22x20":["user-penn-16x20.png",16,20],"24x25":["user-penn-21x25.png",21,25],"30x19":["user-penn-16x19.png",16,19],"25x22":["user-penn-18x22.png",18,22],"28x25":["user-penn-21x25.png",21,25]}}

TEAM_LOGO_BOUNDS.update({"WRST":[26,23,0,1,26,21],"FUR":[26,23,1,0,24,23],"NDSU":[26,23,0,5,26,18],"UCA":[26,23,0,0,25,23],"TNST":[26,23,0,0,25,23],"TEX":[26,23,0,5,26,18],"PENN":[26,23,3,0,22,23]})

USER_LOGO_FRAMES.update({"ACU":{"38x24":["user-acu-32x24.png",32,24],"34x24":["user-acu-32x24.png",32,24],"26x23":["user-acu-26x19.png",26,19],"31x24":["user-acu-31x23.png",31,23],"29x22":["user-acu-29x22.png",29,22],"25x19":["user-acu-25x19.png",25,19],"22x20":["user-acu-22x16.png",22,16],"24x25":["user-acu-24x18.png",24,18],"30x19":["user-acu-26x19.png",26,19],"25x22":["user-acu-25x19.png",25,19],"28x25":["user-acu-28x21.png",28,21]},"AKR":{"38x24":["user-akr-38x21.png",38,21],"34x24":["user-akr-34x19.png",34,19],"26x23":["user-akr-26x14.png",26,14],"31x24":["user-akr-31x17.png",31,17],"29x22":["user-akr-29x16.png",29,16],"25x19":["user-akr-25x14.png",25,14],"22x20":["user-akr-22x12.png",22,12],"24x25":["user-akr-24x13.png",24,13],"30x19":["user-akr-30x17.png",30,17],"25x22":["user-akr-25x14.png",25,14],"28x25":["user-akr-28x15.png",28,15]},"AMER":{"38x24":["user-amer-24x24.png",24,24],"34x24":["user-amer-24x24.png",24,24],"26x23":["user-amer-23x23.png",23,23],"31x24":["user-amer-24x24.png",24,24],"29x22":["user-amer-22x22.png",22,22],"25x19":["user-amer-19x19.png",19,19],"22x20":["user-amer-20x20.png",20,20],"24x25":["user-amer-24x24.png",24,24],"30x19":["user-amer-19x19.png",19,19],"25x22":["user-amer-22x22.png",22,22],"28x25":["user-amer-25x25.png",25,25]},"BAY":{"38x24":["user-bay-20x24.png",20,24],"34x24":["user-bay-20x24.png",20,24],"26x23":["user-bay-19x23.png",19,23],"31x24":["user-bay-20x24.png",20,24],"29x22":["user-bay-18x22.png",18,22],"25x19":["user-bay-16x19.png",16,19],"22x20":["user-bay-16x20.png",16,20],"24x25":["user-bay-21x25.png",21,25],"30x19":["user-bay-16x19.png",16,19],"25x22":["user-bay-18x22.png",18,22],"28x25":["user-bay-21x25.png",21,25]}})
TEAM_LOGO_BOUNDS.update({"ACU":[26,23,0,2,26,21],"AKR":[26,23,0,4,26,18],"AMER":[26,23,1,0,24,23],"BAY":[26,23,3,0,22,23]})

USER_LOGO_FRAMES.update({"WIS":{"38x24":["user-wis-25x24.png",25,24],"34x24":["user-wis-25x24.png",25,24],"26x23":["user-wis-24x23.png",24,23],"31x24":["user-wis-25x24.png",25,24],"29x22":["user-wis-23x22.png",23,22],"25x19":["user-wis-20x19.png",20,19],"22x20":["user-wis-21x20.png",21,20],"24x25":["user-wis-24x23.png",24,23],"30x19":["user-wis-20x19.png",20,19],"25x22":["user-wis-23x22.png",23,22],"28x25":["user-wis-26x25.png",26,25]}})
TEAM_LOGO_BOUNDS.update({"WIS":[26,23,1,0,25,23]})

USER_LOGO_FRAMES.update({"BAMA":{"38x24":["user-bama-25x24.png",25,24],"34x24":["user-bama-25x24.png",25,24],"26x23":["user-bama-24x23.png",24,23],"31x24":["user-bama-25x24.png",25,24],"29x22":["user-bama-23x22.png",23,22],"25x19":["user-bama-20x19.png",20,19],"22x20":["user-bama-21x20.png",21,20],"24x25":["user-bama-24x23.png",24,23],"30x19":["user-bama-20x19.png",20,19],"25x22":["user-bama-23x22.png",23,22],"28x25":["user-bama-26x25.png",26,25]},"UK":{"38x24":["user-uk-29x24.png",29,24],"34x24":["user-uk-29x24.png",29,24],"26x23":["user-uk-26x21.png",26,21],"31x24":["user-uk-29x24.png",29,24],"29x22":["user-uk-27x22.png",27,22],"25x19":["user-uk-23x19.png",23,19],"22x20":["user-uk-22x18.png",22,18],"24x25":["user-uk-24x20.png",24,20],"30x19":["user-uk-23x19.png",23,19],"25x22":["user-uk-25x21.png",25,21],"28x25":["user-uk-28x23.png",28,23]}})
TEAM_LOGO_BOUNDS.update({"BAMA":[26,23,1,0,25,23],"UK":[26,23,0,1,26,22]})

USER_LOGO_FRAMES.update({"AAMU":{"38x24":["user-aamu-20x24.png",20,24],"34x24":["user-aamu-20x24.png",20,24],"26x23":["user-aamu-19x23.png",19,23],"31x24":["user-aamu-20x24.png",20,24],"29x22":["user-aamu-18x22.png",18,22],"25x19":["user-aamu-16x19.png",16,19],"22x20":["user-aamu-17x20.png",17,20],"24x25":["user-aamu-21x25.png",21,25],"30x19":["user-aamu-16x19.png",16,19],"25x22":["user-aamu-18x22.png",18,22],"28x25":["user-aamu-21x25.png",21,25]},"ALST":{"38x24":["user-alst-38x17.png",38,17],"34x24":["user-alst-34x15.png",34,15],"26x23":["user-alst-26x12.png",26,12],"31x24":["user-alst-31x14.png",31,14],"29x22":["user-alst-29x13.png",29,13],"25x19":["user-alst-25x11.png",25,11],"22x20":["user-alst-22x10.png",22,10],"24x25":["user-alst-24x11.png",24,11],"30x19":["user-alst-30x13.png",30,13],"25x22":["user-alst-25x11.png",25,11],"28x25":["user-alst-28x13.png",28,13]},"ALCN":{"38x24":["user-alcn-26x24.png",26,24],"34x24":["user-alcn-26x24.png",26,24],"26x23":["user-alcn-25x23.png",25,23],"31x24":["user-alcn-26x24.png",26,24],"29x22":["user-alcn-24x22.png",24,22],"25x19":["user-alcn-21x19.png",21,19],"22x20":["user-alcn-22x20.png",22,20],"24x25":["user-alcn-24x22.png",24,22],"30x19":["user-alcn-21x19.png",21,19],"25x22":["user-alcn-24x22.png",24,22],"28x25":["user-alcn-28x25.png",28,25]},"APP":{"38x24":["user-app-21x24.png",21,24],"34x24":["user-app-21x24.png",21,24],"26x23":["user-app-20x23.png",20,23],"31x24":["user-app-21x24.png",21,24],"29x22":["user-app-19x22.png",19,22],"25x19":["user-app-17x19.png",17,19],"22x20":["user-app-18x20.png",18,20],"24x25":["user-app-22x25.png",22,25],"30x19":["user-app-17x19.png",17,19],"25x22":["user-app-19x22.png",19,22],"28x25":["user-app-22x25.png",22,25]},"ASU":{"38x24":["user-asu-12x24.png",12,24],"34x24":["user-asu-12x24.png",12,24],"26x23":["user-asu-12x23.png",12,23],"31x24":["user-asu-12x24.png",12,24],"29x22":["user-asu-11x22.png",11,22],"25x19":["user-asu-10x19.png",10,19],"22x20":["user-asu-10x20.png",10,20],"24x25":["user-asu-13x25.png",13,25],"30x19":["user-asu-10x19.png",10,19],"25x22":["user-asu-11x22.png",11,22],"28x25":["user-asu-13x25.png",13,25]},"UAPB":{"38x24":["user-uapb-29x24.png",29,24],"34x24":["user-uapb-29x24.png",29,24],"26x23":["user-uapb-26x22.png",26,22],"31x24":["user-uapb-29x24.png",29,24],"29x22":["user-uapb-27x22.png",27,22],"25x19":["user-uapb-23x19.png",23,19],"22x20":["user-uapb-22x18.png",22,18],"24x25":["user-uapb-24x20.png",24,20],"30x19":["user-uapb-23x19.png",23,19],"25x22":["user-uapb-25x21.png",25,21],"28x25":["user-uapb-28x23.png",28,23]},"ARST":{"38x24":["user-arst-23x24.png",23,24],"34x24":["user-arst-23x24.png",23,24],"26x23":["user-arst-22x23.png",22,23],"31x24":["user-arst-23x24.png",23,24],"29x22":["user-arst-22x22.png",22,22],"25x19":["user-arst-19x19.png",19,19],"22x20":["user-arst-20x20.png",20,20],"24x25":["user-arst-24x25.png",24,25],"30x19":["user-arst-19x19.png",19,19],"25x22":["user-arst-22x22.png",22,22],"28x25":["user-arst-24x25.png",24,25]},"ARMY":{"38x24":["user-army-21x24.png",21,24],"34x24":["user-army-21x24.png",21,24],"26x23":["user-army-20x23.png",20,23],"31x24":["user-army-21x24.png",21,24],"29x22":["user-army-19x22.png",19,22],"25x19":["user-army-16x19.png",16,19],"22x20":["user-army-17x20.png",17,20],"24x25":["user-army-21x25.png",21,25],"30x19":["user-army-16x19.png",16,19],"25x22":["user-army-19x22.png",19,22],"28x25":["user-army-21x25.png",21,25]},"APSU":{"38x24":["user-apsu-21x24.png",21,24],"34x24":["user-apsu-21x24.png",21,24],"26x23":["user-apsu-21x23.png",21,23],"31x24":["user-apsu-21x24.png",21,24],"29x22":["user-apsu-20x22.png",20,22],"25x19":["user-apsu-17x19.png",17,19],"22x20":["user-apsu-18x20.png",18,20],"24x25":["user-apsu-22x25.png",22,25],"30x19":["user-apsu-17x19.png",17,19],"25x22":["user-apsu-20x22.png",20,22],"28x25":["user-apsu-22x25.png",22,25]},"BALL":{"38x24":["user-ball-17x24.png",17,24],"34x24":["user-ball-17x24.png",17,24],"26x23":["user-ball-16x23.png",16,23],"31x24":["user-ball-17x24.png",17,24],"29x22":["user-ball-16x22.png",16,22],"25x19":["user-ball-13x19.png",13,19],"22x20":["user-ball-14x20.png",14,20],"24x25":["user-ball-18x25.png",18,25],"30x19":["user-ball-13x19.png",13,19],"25x22":["user-ball-16x22.png",16,22],"28x25":["user-ball-18x25.png",18,25]}})
TEAM_LOGO_BOUNDS.update({"AAMU":[26,23,3,0,22,23],"ALST":[26,23,0,5,26,17],"ALCN":[26,23,0,0,25,23],"APP":[26,23,3,0,23,23],"ASU":[26,23,7,0,19,23],"UAPB":[26,23,0,0,26,22],"ARST":[26,23,2,0,24,23],"ARMY":[26,23,3,0,23,23],"APSU":[26,23,2,0,23,23],"BALL":[26,23,5,0,21,23]})

USER_LOGO_FRAMES.update({"ALST":{"38x24":["user-alst-34x24.png",34,24],"34x24":["user-alst-34x24.png",34,24],"26x23":["user-alst-26x18.png",26,18],"31x24":["user-alst-31x22.png",31,22],"29x22":["user-alst-29x20.png",29,20],"25x19":["user-alst-25x17.png",25,17],"22x20":["user-alst-22x15.png",22,15],"24x25":["user-alst-24x17.png",24,17],"30x19":["user-alst-27x19.png",27,19],"25x22":["user-alst-25x17.png",25,17],"28x25":["user-alst-28x20.png",28,20]}})
TEAM_LOGO_BOUNDS.update({"ALST":[26,23,0,2,26,20]})

USER_LOGO_FRAMES.update({"BELL":{"38x24":["user-bell-38x21.png",38,21],"34x24":["user-bell-34x19.png",34,19],"26x23":["user-bell-26x14.png",26,14],"31x24":["user-bell-31x17.png",31,17],"29x22":["user-bell-29x16.png",29,16],"25x19":["user-bell-25x14.png",25,14],"22x20":["user-bell-22x12.png",22,12],"24x25":["user-bell-24x13.png",24,13],"30x19":["user-bell-30x17.png",30,17],"25x22":["user-bell-25x14.png",25,14],"28x25":["user-bell-28x15.png",28,15]},"BEL":{"38x24":["user-bel-25x24.png",25,24],"34x24":["user-bel-25x24.png",25,24],"26x23":["user-bel-24x23.png",24,23],"31x24":["user-bel-25x24.png",25,24],"29x22":["user-bel-23x22.png",23,22],"25x19":["user-bel-20x19.png",20,19],"22x20":["user-bel-21x20.png",21,20],"24x25":["user-bel-24x23.png",24,23],"30x19":["user-bel-20x19.png",20,19],"25x22":["user-bel-23x22.png",23,22],"28x25":["user-bel-26x25.png",26,25]},"BCU":{"38x24":["user-bcu-23x24.png",23,24],"34x24":["user-bcu-23x24.png",23,24],"26x23":["user-bcu-22x23.png",22,23],"31x24":["user-bcu-23x24.png",23,24],"29x22":["user-bcu-21x22.png",21,22],"25x19":["user-bcu-18x19.png",18,19],"22x20":["user-bcu-19x20.png",19,20],"24x25":["user-bcu-24x25.png",24,25],"30x19":["user-bcu-18x19.png",18,19],"25x22":["user-bcu-21x22.png",21,22],"28x25":["user-bcu-24x25.png",24,25]},"BING":{"38x24":["user-bing-38x22.png",38,22],"34x24":["user-bing-34x20.png",34,20],"26x23":["user-bing-26x15.png",26,15],"31x24":["user-bing-31x18.png",31,18],"29x22":["user-bing-29x17.png",29,17],"25x19":["user-bing-25x15.png",25,15],"22x20":["user-bing-22x13.png",22,13],"24x25":["user-bing-24x14.png",24,14],"30x19":["user-bing-30x17.png",30,17],"25x22":["user-bing-25x15.png",25,15],"28x25":["user-bing-28x16.png",28,16]},"BOIS":{"38x24":["user-bois-29x24.png",29,24],"34x24":["user-bois-29x24.png",29,24],"26x23":["user-bois-26x22.png",26,22],"31x24":["user-bois-29x24.png",29,24],"29x22":["user-bois-26x22.png",26,22],"25x19":["user-bois-23x19.png",23,19],"22x20":["user-bois-22x18.png",22,18],"24x25":["user-bois-24x20.png",24,20],"30x19":["user-bois-23x19.png",23,19],"25x22":["user-bois-25x21.png",25,21],"28x25":["user-bois-28x23.png",28,23]},"BC":{"38x24":["user-bc-26x24.png",26,24],"34x24":["user-bc-26x24.png",26,24],"26x23":["user-bc-25x23.png",25,23],"31x24":["user-bc-26x24.png",26,24],"29x22":["user-bc-24x22.png",24,22],"25x19":["user-bc-21x19.png",21,19],"22x20":["user-bc-22x20.png",22,20],"24x25":["user-bc-24x22.png",24,22],"30x19":["user-bc-21x19.png",21,19],"25x22":["user-bc-24x22.png",24,22],"28x25":["user-bc-28x25.png",28,25]},"BU":{"38x24":["user-bu-26x24.png",26,24],"34x24":["user-bu-26x24.png",26,24],"26x23":["user-bu-25x23.png",25,23],"31x24":["user-bu-26x24.png",26,24],"29x22":["user-bu-24x22.png",24,22],"25x19":["user-bu-21x19.png",21,19],"22x20":["user-bu-22x20.png",22,20],"24x25":["user-bu-24x22.png",24,22],"30x19":["user-bu-21x19.png",21,19],"25x22":["user-bu-24x22.png",24,22],"28x25":["user-bu-27x25.png",27,25]},"BGSU":{"38x24":["user-bgsu-26x24.png",26,24],"34x24":["user-bgsu-26x24.png",26,24],"26x23":["user-bgsu-25x23.png",25,23],"31x24":["user-bgsu-26x24.png",26,24],"29x22":["user-bgsu-24x22.png",24,22],"25x19":["user-bgsu-21x19.png",21,19],"22x20":["user-bgsu-22x20.png",22,20],"24x25":["user-bgsu-24x22.png",24,22],"30x19":["user-bgsu-21x19.png",21,19],"25x22":["user-bgsu-24x22.png",24,22],"28x25":["user-bgsu-27x25.png",27,25]},"BRAD":{"38x24":["user-brad-20x24.png",20,24],"34x24":["user-brad-20x24.png",20,24],"26x23":["user-brad-19x23.png",19,23],"31x24":["user-brad-20x24.png",20,24],"29x22":["user-brad-18x22.png",18,22],"25x19":["user-brad-16x19.png",16,19],"22x20":["user-brad-17x20.png",17,20],"24x25":["user-brad-21x25.png",21,25],"30x19":["user-brad-16x19.png",16,19],"25x22":["user-brad-18x22.png",18,22],"28x25":["user-brad-21x25.png",21,25]},"BRWN":{"38x24":["user-brwn-20x24.png",20,24],"34x24":["user-brwn-20x24.png",20,24],"26x23":["user-brwn-19x23.png",19,23],"31x24":["user-brwn-20x24.png",20,24],"29x22":["user-brwn-18x22.png",18,22],"25x19":["user-brwn-16x19.png",16,19],"22x20":["user-brwn-16x20.png",16,20],"24x25":["user-brwn-20x25.png",20,25],"30x19":["user-brwn-16x19.png",16,19],"25x22":["user-brwn-18x22.png",18,22],"28x25":["user-brwn-20x25.png",20,25]},"BRY":{"38x24":["user-bry-30x24.png",30,24],"34x24":["user-bry-30x24.png",30,24],"26x23":["user-bry-26x21.png",26,21],"31x24":["user-bry-30x24.png",30,24],"29x22":["user-bry-27x22.png",27,22],"25x19":["user-bry-23x19.png",23,19],"22x20":["user-bry-22x18.png",22,18],"24x25":["user-bry-24x20.png",24,20],"30x19":["user-bry-23x19.png",23,19],"25x22":["user-bry-25x20.png",25,20],"28x25":["user-bry-28x23.png",28,23]},"BUCK":{"38x24":["user-buck-29x24.png",29,24],"34x24":["user-buck-29x24.png",29,24],"26x23":["user-buck-26x22.png",26,22],"31x24":["user-buck-29x24.png",29,24],"29x22":["user-buck-26x22.png",26,22],"25x19":["user-buck-23x19.png",23,19],"22x20":["user-buck-22x18.png",22,18],"24x25":["user-buck-24x20.png",24,20],"30x19":["user-buck-23x19.png",23,19],"25x22":["user-buck-25x21.png",25,21],"28x25":["user-buck-28x23.png",28,23]},"BUF":{"38x24":["user-buf-25x24.png",25,24],"34x24":["user-buf-25x24.png",25,24],"26x23":["user-buf-24x23.png",24,23],"31x24":["user-buf-25x24.png",25,24],"29x22":["user-buf-23x22.png",23,22],"25x19":["user-buf-20x19.png",20,19],"22x20":["user-buf-21x20.png",21,20],"24x25":["user-buf-24x23.png",24,23],"30x19":["user-buf-20x19.png",20,19],"25x22":["user-buf-23x22.png",23,22],"28x25":["user-buf-26x25.png",26,25]},"BTLR":{"38x24":["user-btlr-25x24.png",25,24],"34x24":["user-btlr-25x24.png",25,24],"26x23":["user-btlr-24x23.png",24,23],"31x24":["user-btlr-25x24.png",25,24],"29x22":["user-btlr-23x22.png",23,22],"25x19":["user-btlr-20x19.png",20,19],"22x20":["user-btlr-21x20.png",21,20],"24x25":["user-btlr-24x23.png",24,23],"30x19":["user-btlr-20x19.png",20,19],"25x22":["user-btlr-23x22.png",23,22],"28x25":["user-btlr-26x25.png",26,25]},"BYU":{"38x24":["user-byu-38x24.png",38,24],"34x24":["user-byu-34x21.png",34,21],"26x23":["user-byu-26x16.png",26,16],"31x24":["user-byu-31x19.png",31,19],"29x22":["user-byu-29x18.png",29,18],"25x19":["user-byu-25x16.png",25,16],"22x20":["user-byu-22x14.png",22,14],"24x25":["user-byu-24x15.png",24,15],"30x19":["user-byu-30x19.png",30,19],"25x22":["user-byu-25x16.png",25,16],"28x25":["user-byu-28x17.png",28,17]},"CP":{"38x24":["user-cp-25x24.png",25,24],"34x24":["user-cp-25x24.png",25,24],"26x23":["user-cp-24x23.png",24,23],"31x24":["user-cp-25x24.png",25,24],"29x22":["user-cp-23x22.png",23,22],"25x19":["user-cp-19x19.png",19,19],"22x20":["user-cp-21x20.png",21,20],"24x25":["user-cp-24x23.png",24,23],"30x19":["user-cp-19x19.png",19,19],"25x22":["user-cp-23x22.png",23,22],"28x25":["user-cp-26x25.png",26,25]},"CSUB":{"38x24":["user-csub-34x24.png",34,24],"34x24":["user-csub-34x24.png",34,24],"26x23":["user-csub-26x19.png",26,19],"31x24":["user-csub-31x22.png",31,22],"29x22":["user-csub-29x21.png",29,21],"25x19":["user-csub-25x18.png",25,18],"22x20":["user-csub-22x16.png",22,16],"24x25":["user-csub-24x17.png",24,17],"30x19":["user-csub-27x19.png",27,19],"25x22":["user-csub-25x18.png",25,18],"28x25":["user-csub-28x20.png",28,20]},"ARK":{"38x24":["user-ark-38x17.png",38,17],"34x24":["user-ark-34x15.png",34,15],"26x23":["user-ark-26x12.png",26,12],"31x24":["user-ark-31x14.png",31,14],"29x22":["user-ark-29x13.png",29,13],"25x19":["user-ark-25x11.png",25,11],"22x20":["user-ark-22x10.png",22,10],"24x25":["user-ark-24x11.png",24,11],"30x19":["user-ark-30x13.png",30,13],"25x22":["user-ark-25x11.png",25,11],"28x25":["user-ark-28x12.png",28,12]},"CSUF":{"38x24":["user-csuf-38x12.png",38,12],"34x24":["user-csuf-34x11.png",34,11],"26x23":["user-csuf-26x9.png",26,9],"31x24":["user-csuf-31x10.png",31,10],"29x22":["user-csuf-29x9.png",29,9],"25x19":["user-csuf-25x8.png",25,8],"22x20":["user-csuf-22x7.png",22,7],"24x25":["user-csuf-24x8.png",24,8],"30x19":["user-csuf-30x10.png",30,10],"25x22":["user-csuf-25x8.png",25,8],"28x25":["user-csuf-28x9.png",28,9]},"CSUN":{"38x24":["user-csun-19x24.png",19,24],"34x24":["user-csun-19x24.png",19,24],"26x23":["user-csun-18x23.png",18,23],"31x24":["user-csun-19x24.png",19,24],"29x22":["user-csun-17x22.png",17,22],"25x19":["user-csun-15x19.png",15,19],"22x20":["user-csun-16x20.png",16,20],"24x25":["user-csun-20x25.png",20,25],"30x19":["user-csun-15x19.png",15,19],"25x22":["user-csun-17x22.png",17,22],"28x25":["user-csun-20x25.png",20,25]},"CAL":{"38x24":["user-cal-30x24.png",30,24],"34x24":["user-cal-30x24.png",30,24],"26x23":["user-cal-26x21.png",26,21],"31x24":["user-cal-30x24.png",30,24],"29x22":["user-cal-28x22.png",28,22],"25x19":["user-cal-24x19.png",24,19],"22x20":["user-cal-22x18.png",22,18],"24x25":["user-cal-24x19.png",24,19],"30x19":["user-cal-24x19.png",24,19],"25x22":["user-cal-25x20.png",25,20],"28x25":["user-cal-28x22.png",28,22]},"CBU":{"38x24":["user-cbu-38x15.png",38,15],"34x24":["user-cbu-34x13.png",34,13],"26x23":["user-cbu-26x10.png",26,10],"31x24":["user-cbu-31x12.png",31,12],"29x22":["user-cbu-29x12.png",29,12],"25x19":["user-cbu-25x10.png",25,10],"22x20":["user-cbu-22x9.png",22,9],"24x25":["user-cbu-24x10.png",24,10],"30x19":["user-cbu-30x12.png",30,12],"25x22":["user-cbu-25x10.png",25,10],"28x25":["user-cbu-28x11.png",28,11]},"CAM":{"38x24":["user-cam-38x22.png",38,22],"34x24":["user-cam-34x20.png",34,20],"26x23":["user-cam-26x15.png",26,15],"31x24":["user-cam-31x18.png",31,18],"29x22":["user-cam-29x17.png",29,17],"25x19":["user-cam-25x14.png",25,14],"22x20":["user-cam-22x13.png",22,13],"24x25":["user-cam-24x14.png",24,14],"30x19":["user-cam-30x17.png",30,17],"25x22":["user-cam-25x14.png",25,14],"28x25":["user-cam-28x16.png",28,16]},"CAN":{"38x24":["user-can-23x24.png",23,24],"34x24":["user-can-23x24.png",23,24],"26x23":["user-can-22x23.png",22,23],"31x24":["user-can-23x24.png",23,24],"29x22":["user-can-21x22.png",21,22],"25x19":["user-can-18x19.png",18,19],"22x20":["user-can-19x20.png",19,20],"24x25":["user-can-24x25.png",24,25],"30x19":["user-can-18x19.png",18,19],"25x22":["user-can-21x22.png",21,22],"28x25":["user-can-24x25.png",24,25]},"CCSU":{"38x24":["user-ccsu-26x24.png",26,24],"34x24":["user-ccsu-26x24.png",26,24],"26x23":["user-ccsu-25x23.png",25,23],"31x24":["user-ccsu-26x24.png",26,24],"29x22":["user-ccsu-24x22.png",24,22],"25x19":["user-ccsu-21x19.png",21,19],"22x20":["user-ccsu-22x20.png",22,20],"24x25":["user-ccsu-24x22.png",24,22],"30x19":["user-ccsu-21x19.png",21,19],"25x22":["user-ccsu-24x22.png",24,22],"28x25":["user-ccsu-28x25.png",28,25]},"CMU":{"38x24":["user-cmu-34x24.png",34,24],"34x24":["user-cmu-34x24.png",34,24],"26x23":["user-cmu-26x18.png",26,18],"31x24":["user-cmu-31x22.png",31,22],"29x22":["user-cmu-29x21.png",29,21],"25x19":["user-cmu-25x18.png",25,18],"22x20":["user-cmu-22x16.png",22,16],"24x25":["user-cmu-24x17.png",24,17],"30x19":["user-cmu-27x19.png",27,19],"25x22":["user-cmu-25x18.png",25,18],"28x25":["user-cmu-28x20.png",28,20]},"COFC":{"38x24":["user-cofc-21x24.png",21,24],"34x24":["user-cofc-21x24.png",21,24],"26x23":["user-cofc-20x23.png",20,23],"31x24":["user-cofc-21x24.png",21,24],"29x22":["user-cofc-19x22.png",19,22],"25x19":["user-cofc-16x19.png",16,19],"22x20":["user-cofc-17x20.png",17,20],"24x25":["user-cofc-21x25.png",21,25],"30x19":["user-cofc-16x19.png",16,19],"25x22":["user-cofc-19x22.png",19,22],"28x25":["user-cofc-21x25.png",21,25]},"CHSO":{"38x24":["user-chso-30x24.png",30,24],"34x24":["user-chso-30x24.png",30,24],"26x23":["user-chso-26x21.png",26,21],"31x24":["user-chso-30x24.png",30,24],"29x22":["user-chso-27x22.png",27,22],"25x19":["user-chso-24x19.png",24,19],"22x20":["user-chso-22x18.png",22,18],"24x25":["user-chso-24x19.png",24,19],"30x19":["user-chso-24x19.png",24,19],"25x22":["user-chso-25x20.png",25,20],"28x25":["user-chso-28x23.png",28,23]},"CLT":{"38x24":["user-clt-19x24.png",19,24],"34x24":["user-clt-19x24.png",19,24],"26x23":["user-clt-18x23.png",18,23],"31x24":["user-clt-19x24.png",19,24],"29x22":["user-clt-18x22.png",18,22],"25x19":["user-clt-15x19.png",15,19],"22x20":["user-clt-16x20.png",16,20],"24x25":["user-clt-20x25.png",20,25],"30x19":["user-clt-15x19.png",15,19],"25x22":["user-clt-18x22.png",18,22],"28x25":["user-clt-20x25.png",20,25]}})
TEAM_LOGO_BOUNDS.update({"BELL":[26,23,0,4,26,18],"BEL":[26,23,1,0,25,23],"BCU":[26,23,2,0,24,23],"BING":[26,23,0,4,26,19],"BOIS":[26,23,0,0,26,22],"BC":[26,23,0,0,25,23],"BU":[26,23,0,0,25,23],"BGSU":[26,23,0,0,25,23],"BRAD":[26,23,3,0,22,23],"BRWN":[26,23,3,0,22,23],"BRY":[26,23,0,1,26,22],"BUCK":[26,23,0,0,26,22],"BUF":[26,23,1,0,25,23],"BTLR":[26,23,1,0,25,23],"BYU":[26,23,0,3,26,19],"CP":[26,23,1,0,25,23],"CSUB":[26,23,0,2,26,21],"ARK":[26,23,0,5,26,17],"CSUF":[26,23,0,7,26,16],"CSUN":[26,23,4,0,22,23],"CAL":[26,23,0,1,26,22],"CBU":[26,23,0,6,26,16],"CAM":[26,23,0,4,26,19],"CAN":[26,23,2,0,24,23],"CCSU":[26,23,0,0,25,23],"CMU":[26,23,0,2,26,20],"COFC":[26,23,3,0,23,23],"CHSO":[26,23,0,1,26,22],"CLT":[26,23,4,0,22,23]})

USER_LOGO_FRAMES.update({"UTC":{"38x24":["user-utc-27x24.png",27,24],"34x24":["user-utc-27x24.png",27,24],"26x23":["user-utc-26x23.png",26,23],"31x24":["user-utc-27x24.png",27,24],"29x22":["user-utc-25x22.png",25,22],"25x19":["user-utc-22x19.png",22,19],"22x20":["user-utc-22x19.png",22,19],"24x25":["user-utc-24x21.png",24,21],"30x19":["user-utc-22x19.png",22,19],"25x22":["user-utc-25x22.png",25,22],"28x25":["user-utc-28x25.png",28,25]},"CHST":{"38x24":["user-chst-35x24.png",35,24],"34x24":["user-chst-34x24.png",34,24],"26x23":["user-chst-26x18.png",26,18],"31x24":["user-chst-31x22.png",31,22],"29x22":["user-chst-29x20.png",29,20],"25x19":["user-chst-25x17.png",25,17],"22x20":["user-chst-22x15.png",22,15],"24x25":["user-chst-24x17.png",24,17],"30x19":["user-chst-27x19.png",27,19],"25x22":["user-chst-25x17.png",25,17],"28x25":["user-chst-28x19.png",28,19]},"CIN":{"38x24":["user-cin-15x24.png",15,24],"34x24":["user-cin-15x24.png",15,24],"26x23":["user-cin-15x23.png",15,23],"31x24":["user-cin-15x24.png",15,24],"29x22":["user-cin-14x22.png",14,22],"25x19":["user-cin-12x19.png",12,19],"22x20":["user-cin-13x20.png",13,20],"24x25":["user-cin-16x25.png",16,25],"30x19":["user-cin-12x19.png",12,19],"25x22":["user-cin-14x22.png",14,22],"28x25":["user-cin-16x25.png",16,25]},"CLEM":{"38x24":["user-clem-25x24.png",25,24],"34x24":["user-clem-25x24.png",25,24],"26x23":["user-clem-24x23.png",24,23],"31x24":["user-clem-25x24.png",25,24],"29x22":["user-clem-23x22.png",23,22],"25x19":["user-clem-20x19.png",20,19],"22x20":["user-clem-21x20.png",21,20],"24x25":["user-clem-24x23.png",24,23],"30x19":["user-clem-20x19.png",20,19],"25x22":["user-clem-23x22.png",23,22],"28x25":["user-clem-26x25.png",26,25]},"CLE":{"38x24":["user-cle-31x24.png",31,24],"34x24":["user-cle-31x24.png",31,24],"26x23":["user-cle-26x20.png",26,20],"31x24":["user-cle-31x24.png",31,24],"29x22":["user-cle-28x22.png",28,22],"25x19":["user-cle-24x19.png",24,19],"22x20":["user-cle-22x17.png",22,17],"24x25":["user-cle-24x19.png",24,19],"30x19":["user-cle-24x19.png",24,19],"25x22":["user-cle-25x19.png",25,19],"28x25":["user-cle-28x22.png",28,22]},"CCU":{"38x24":["user-ccu-21x24.png",21,24],"34x24":["user-ccu-21x24.png",21,24],"26x23":["user-ccu-21x23.png",21,23],"31x24":["user-ccu-21x24.png",21,24],"29x22":["user-ccu-20x22.png",20,22],"25x19":["user-ccu-17x19.png",17,19],"22x20":["user-ccu-18x20.png",18,20],"24x25":["user-ccu-22x25.png",22,25],"30x19":["user-ccu-17x19.png",17,19],"25x22":["user-ccu-20x22.png",20,22],"28x25":["user-ccu-22x25.png",22,25]},"COLG":{"38x24":["user-colg-26x24.png",26,24],"34x24":["user-colg-26x24.png",26,24],"26x23":["user-colg-25x23.png",25,23],"31x24":["user-colg-26x24.png",26,24],"29x22":["user-colg-24x22.png",24,22],"25x19":["user-colg-20x19.png",20,19],"22x20":["user-colg-21x20.png",21,20],"24x25":["user-colg-24x22.png",24,22],"30x19":["user-colg-20x19.png",20,19],"25x22":["user-colg-24x22.png",24,22],"28x25":["user-colg-27x25.png",27,25]},"COLO":{"38x24":["user-colo-33x24.png",33,24],"34x24":["user-colo-33x24.png",33,24],"26x23":["user-colo-26x19.png",26,19],"31x24":["user-colo-31x23.png",31,23],"29x22":["user-colo-29x21.png",29,21],"25x19":["user-colo-25x18.png",25,18],"22x20":["user-colo-22x16.png",22,16],"24x25":["user-colo-24x18.png",24,18],"30x19":["user-colo-26x19.png",26,19],"25x22":["user-colo-25x18.png",25,18],"28x25":["user-colo-28x21.png",28,21]},"CSU":{"38x24":["user-csu-24x24.png",24,24],"34x24":["user-csu-24x24.png",24,24],"26x23":["user-csu-23x23.png",23,23],"31x24":["user-csu-24x24.png",24,24],"29x22":["user-csu-22x22.png",22,22],"25x19":["user-csu-19x19.png",19,19],"22x20":["user-csu-20x20.png",20,20],"24x25":["user-csu-24x24.png",24,24],"30x19":["user-csu-19x19.png",19,19],"25x22":["user-csu-22x22.png",22,22],"28x25":["user-csu-25x25.png",25,25]},"COLU":{"38x24":["user-colu-21x24.png",21,24],"34x24":["user-colu-21x24.png",21,24],"26x23":["user-colu-20x23.png",20,23],"31x24":["user-colu-21x24.png",21,24],"29x22":["user-colu-19x22.png",19,22],"25x19":["user-colu-16x19.png",16,19],"22x20":["user-colu-17x20.png",17,20],"24x25":["user-colu-21x25.png",21,25],"30x19":["user-colu-16x19.png",16,19],"25x22":["user-colu-19x22.png",19,22],"28x25":["user-colu-21x25.png",21,25]},"COPP":{"38x24":["user-copp-38x24.png",38,24],"34x24":["user-copp-34x21.png",34,21],"26x23":["user-copp-26x16.png",26,16],"31x24":["user-copp-31x20.png",31,20],"29x22":["user-copp-29x18.png",29,18],"25x19":["user-copp-25x16.png",25,16],"22x20":["user-copp-22x14.png",22,14],"24x25":["user-copp-24x15.png",24,15],"30x19":["user-copp-30x19.png",30,19],"25x22":["user-copp-25x16.png",25,16],"28x25":["user-copp-28x18.png",28,18]},"COR":{"38x24":["user-cor-23x24.png",23,24],"34x24":["user-cor-23x24.png",23,24],"26x23":["user-cor-22x23.png",22,23],"31x24":["user-cor-23x24.png",23,24],"29x22":["user-cor-21x22.png",21,22],"25x19":["user-cor-18x19.png",18,19],"22x20":["user-cor-19x20.png",19,20],"24x25":["user-cor-24x25.png",24,25],"30x19":["user-cor-18x19.png",18,19],"25x22":["user-cor-21x22.png",21,22],"28x25":["user-cor-24x25.png",24,25]},"CREI":{"38x24":["user-crei-24x24.png",24,24],"34x24":["user-crei-24x24.png",24,24],"26x23":["user-crei-23x23.png",23,23],"31x24":["user-crei-24x24.png",24,24],"29x22":["user-crei-22x22.png",22,22],"25x19":["user-crei-19x19.png",19,19],"22x20":["user-crei-20x20.png",20,20],"24x25":["user-crei-24x24.png",24,24],"30x19":["user-crei-19x19.png",19,19],"25x22":["user-crei-22x22.png",22,22],"28x25":["user-crei-25x25.png",25,25]},"DART":{"38x24":["user-dart-19x24.png",19,24],"34x24":["user-dart-19x24.png",19,24],"26x23":["user-dart-18x23.png",18,23],"31x24":["user-dart-19x24.png",19,24],"29x22":["user-dart-17x22.png",17,22],"25x19":["user-dart-15x19.png",15,19],"22x20":["user-dart-16x20.png",16,20],"24x25":["user-dart-20x25.png",20,25],"30x19":["user-dart-15x19.png",15,19],"25x22":["user-dart-17x22.png",17,22],"28x25":["user-dart-20x25.png",20,25]},"DAY":{"38x24":["user-day-38x24.png",38,24],"34x24":["user-day-34x22.png",34,22],"26x23":["user-day-26x17.png",26,17],"31x24":["user-day-31x20.png",31,20],"29x22":["user-day-29x18.png",29,18],"25x19":["user-day-25x16.png",25,16],"22x20":["user-day-22x14.png",22,14],"24x25":["user-day-24x15.png",24,15],"30x19":["user-day-30x19.png",30,19],"25x22":["user-day-25x16.png",25,16],"28x25":["user-day-28x18.png",28,18]},"DEL":{"38x24":["user-del-35x24.png",35,24],"34x24":["user-del-34x24.png",34,24],"26x23":["user-del-26x18.png",26,18],"31x24":["user-del-31x22.png",31,22],"29x22":["user-del-29x20.png",29,20],"25x19":["user-del-25x17.png",25,17],"22x20":["user-del-22x15.png",22,15],"24x25":["user-del-24x17.png",24,17],"30x19":["user-del-27x19.png",27,19],"25x22":["user-del-25x17.png",25,17],"28x25":["user-del-28x19.png",28,19]},"DSU":{"38x24":["user-dsu-31x24.png",31,24],"34x24":["user-dsu-31x24.png",31,24],"26x23":["user-dsu-26x20.png",26,20],"31x24":["user-dsu-31x24.png",31,24],"29x22":["user-dsu-29x22.png",29,22],"25x19":["user-dsu-25x19.png",25,19],"22x20":["user-dsu-22x17.png",22,17],"24x25":["user-dsu-24x18.png",24,18],"30x19":["user-dsu-25x19.png",25,19],"25x22":["user-dsu-25x19.png",25,19],"28x25":["user-dsu-28x21.png",28,21]},"DEN":{"38x24":["user-den-33x24.png",33,24],"34x24":["user-den-33x24.png",33,24],"26x23":["user-den-26x19.png",26,19],"31x24":["user-den-31x22.png",31,22],"29x22":["user-den-29x21.png",29,21],"25x19":["user-den-25x18.png",25,18],"22x20":["user-den-22x16.png",22,16],"24x25":["user-den-24x17.png",24,17],"30x19":["user-den-26x19.png",26,19],"25x22":["user-den-25x18.png",25,18],"28x25":["user-den-28x20.png",28,20]},"DEP":{"38x24":["user-dep-23x24.png",23,24],"34x24":["user-dep-23x24.png",23,24],"26x23":["user-dep-22x23.png",22,23],"31x24":["user-dep-23x24.png",23,24],"29x22":["user-dep-21x22.png",21,22],"25x19":["user-dep-18x19.png",18,19],"22x20":["user-dep-19x20.png",19,20],"24x25":["user-dep-24x25.png",24,25],"30x19":["user-dep-18x19.png",18,19],"25x22":["user-dep-21x22.png",21,22],"28x25":["user-dep-24x25.png",24,25]},"DETM":{"38x24":["user-detm-32x24.png",32,24],"34x24":["user-detm-32x24.png",32,24],"26x23":["user-detm-26x20.png",26,20],"31x24":["user-detm-31x23.png",31,23],"29x22":["user-detm-29x22.png",29,22],"25x19":["user-detm-25x19.png",25,19],"22x20":["user-detm-22x17.png",22,17],"24x25":["user-detm-24x18.png",24,18],"30x19":["user-detm-25x19.png",25,19],"25x22":["user-detm-25x19.png",25,19],"28x25":["user-detm-28x21.png",28,21]},"DRKE":{"38x24":["user-drke-22x24.png",22,24],"34x24":["user-drke-22x24.png",22,24],"26x23":["user-drke-21x23.png",21,23],"31x24":["user-drke-22x24.png",22,24],"29x22":["user-drke-20x22.png",20,22],"25x19":["user-drke-18x19.png",18,19],"22x20":["user-drke-18x20.png",18,20],"24x25":["user-drke-23x25.png",23,25],"30x19":["user-drke-18x19.png",18,19],"25x22":["user-drke-20x22.png",20,22],"28x25":["user-drke-23x25.png",23,25]},"DREX":{"38x24":["user-drex-31x24.png",31,24],"34x24":["user-drex-31x24.png",31,24],"26x23":["user-drex-26x20.png",26,20],"31x24":["user-drex-31x24.png",31,24],"29x22":["user-drex-28x22.png",28,22],"25x19":["user-drex-24x19.png",24,19],"22x20":["user-drex-22x17.png",22,17],"24x25":["user-drex-24x19.png",24,19],"30x19":["user-drex-24x19.png",24,19],"25x22":["user-drex-25x20.png",25,20],"28x25":["user-drex-28x22.png",28,22]}})
TEAM_LOGO_BOUNDS.update({"UTC":[26,23,0,0,26,23],"CHST":[26,23,0,2,26,20],"CIN":[26,23,5,0,20,23],"CLEM":[26,23,1,0,25,23],"CLE":[26,23,0,1,26,21],"CCU":[26,23,2,0,23,23],"COLG":[26,23,0,0,25,23],"COLO":[26,23,0,2,26,21],"CSU":[26,23,1,0,24,23],"COLU":[26,23,3,0,23,23],"COPP":[26,23,0,3,26,19],"COR":[26,23,2,0,24,23],"CREI":[26,23,1,0,24,23],"DART":[26,23,4,0,22,23],"DAY":[26,23,0,3,26,20],"DEL":[26,23,0,2,26,20],"DSU":[26,23,0,1,26,21],"DEN":[26,23,0,2,26,21],"DEP":[26,23,2,0,24,23],"DETM":[26,23,0,1,26,21],"DRKE":[26,23,2,0,23,23],"DREX":[26,23,0,1,26,21]})

USER_LOGO_FRAMES.update({"BELL":{"38x24":["user-bell-textfree-oct26-17x24.png",17,24],"34x24":["user-bell-textfree-oct26-17x24.png",17,24],"26x23":["user-bell-textfree-oct26-17x23.png",17,23],"31x24":["user-bell-textfree-oct26-17x24.png",17,24],"29x22":["user-bell-textfree-oct26-16x22.png",16,22],"25x19":["user-bell-textfree-oct26-14x19.png",14,19],"22x20":["user-bell-textfree-oct26-15x20.png",15,20],"24x25":["user-bell-textfree-oct26-18x25.png",18,25],"30x19":["user-bell-textfree-oct26-14x19.png",14,19],"25x22":["user-bell-textfree-oct26-16x22.png",16,22],"28x25":["user-bell-textfree-oct26-18x25.png",18,25]},"BING":{"38x24":["user-bing-textfree-oct26-24x24.png",24,24],"34x24":["user-bing-textfree-oct26-24x24.png",24,24],"26x23":["user-bing-textfree-oct26-23x23.png",23,23],"31x24":["user-bing-textfree-oct26-24x24.png",24,24],"29x22":["user-bing-textfree-oct26-22x22.png",22,22],"25x19":["user-bing-textfree-oct26-19x19.png",19,19],"22x20":["user-bing-textfree-oct26-20x20.png",20,20],"24x25":["user-bing-textfree-oct26-24x24.png",24,24],"30x19":["user-bing-textfree-oct26-19x19.png",19,19],"25x22":["user-bing-textfree-oct26-22x22.png",22,22],"28x25":["user-bing-textfree-oct26-25x25.png",25,25]},"BRY":{"38x24":["user-bry-textfree-oct26-27x24.png",27,24],"34x24":["user-bry-textfree-oct26-27x24.png",27,24],"26x23":["user-bry-textfree-oct26-26x23.png",26,23],"31x24":["user-bry-textfree-oct26-27x24.png",27,24],"29x22":["user-bry-textfree-oct26-25x22.png",25,22],"25x19":["user-bry-textfree-oct26-21x19.png",21,19],"22x20":["user-bry-textfree-oct26-22x20.png",22,20],"24x25":["user-bry-textfree-oct26-24x21.png",24,21],"30x19":["user-bry-textfree-oct26-21x19.png",21,19],"25x22":["user-bry-textfree-oct26-25x22.png",25,22],"28x25":["user-bry-textfree-oct26-28x25.png",28,25]},"BUCK":{"38x24":["user-buck-textfree-oct26-21x24.png",21,24],"34x24":["user-buck-textfree-oct26-21x24.png",21,24],"26x23":["user-buck-textfree-oct26-20x23.png",20,23],"31x24":["user-buck-textfree-oct26-21x24.png",21,24],"29x22":["user-buck-textfree-oct26-20x22.png",20,22],"25x19":["user-buck-textfree-oct26-17x19.png",17,19],"22x20":["user-buck-textfree-oct26-18x20.png",18,20],"24x25":["user-buck-textfree-oct26-22x25.png",22,25],"30x19":["user-buck-textfree-oct26-17x19.png",17,19],"25x22":["user-buck-textfree-oct26-20x22.png",20,22],"28x25":["user-buck-textfree-oct26-22x25.png",22,25]},"CSUN":{"38x24":["user-csun-textfree-oct26-21x24.png",21,24],"34x24":["user-csun-textfree-oct26-21x24.png",21,24],"26x23":["user-csun-textfree-oct26-20x23.png",20,23],"31x24":["user-csun-textfree-oct26-21x24.png",21,24],"29x22":["user-csun-textfree-oct26-19x22.png",19,22],"25x19":["user-csun-textfree-oct26-16x19.png",16,19],"22x20":["user-csun-textfree-oct26-17x20.png",17,20],"24x25":["user-csun-textfree-oct26-21x25.png",21,25],"30x19":["user-csun-textfree-oct26-16x19.png",16,19],"25x22":["user-csun-textfree-oct26-19x22.png",19,22],"28x25":["user-csun-textfree-oct26-21x25.png",21,25]},"CAN":{"38x24":["user-can-textfree-oct26-32x24.png",32,24],"34x24":["user-can-textfree-oct26-32x24.png",32,24],"26x23":["user-can-textfree-oct26-26x19.png",26,19],"31x24":["user-can-textfree-oct26-31x23.png",31,23],"29x22":["user-can-textfree-oct26-29x22.png",29,22],"25x19":["user-can-textfree-oct26-25x19.png",25,19],"22x20":["user-can-textfree-oct26-22x16.png",22,16],"24x25":["user-can-textfree-oct26-24x18.png",24,18],"30x19":["user-can-textfree-oct26-25x19.png",25,19],"25x22":["user-can-textfree-oct26-25x19.png",25,19],"28x25":["user-can-textfree-oct26-28x21.png",28,21]},"CHSO":{"38x24":["user-chso-textfree-oct26-33x24.png",33,24],"34x24":["user-chso-textfree-oct26-33x24.png",33,24],"26x23":["user-chso-textfree-oct26-26x19.png",26,19],"31x24":["user-chso-textfree-oct26-31x22.png",31,22],"29x22":["user-chso-textfree-oct26-29x21.png",29,21],"25x19":["user-chso-textfree-oct26-25x18.png",25,18],"22x20":["user-chso-textfree-oct26-22x16.png",22,16],"24x25":["user-chso-textfree-oct26-24x17.png",24,17],"30x19":["user-chso-textfree-oct26-26x19.png",26,19],"25x22":["user-chso-textfree-oct26-25x18.png",25,18],"28x25":["user-chso-textfree-oct26-28x20.png",28,20]},"CLE":{"38x24":["user-cle-textfree-oct26-23x24.png",23,24],"34x24":["user-cle-textfree-oct26-23x24.png",23,24],"26x23":["user-cle-textfree-oct26-22x23.png",22,23],"31x24":["user-cle-textfree-oct26-23x24.png",23,24],"29x22":["user-cle-textfree-oct26-21x22.png",21,22],"25x19":["user-cle-textfree-oct26-18x19.png",18,19],"22x20":["user-cle-textfree-oct26-19x20.png",19,20],"24x25":["user-cle-textfree-oct26-23x25.png",23,25],"30x19":["user-cle-textfree-oct26-18x19.png",18,19],"25x22":["user-cle-textfree-oct26-21x22.png",21,22],"28x25":["user-cle-textfree-oct26-23x25.png",23,25]},"DREX":{"38x24":["user-drex-textfree-oct26-33x24.png",33,24],"34x24":["user-drex-textfree-oct26-33x24.png",33,24],"26x23":["user-drex-textfree-oct26-26x19.png",26,19],"31x24":["user-drex-textfree-oct26-31x23.png",31,23],"29x22":["user-drex-textfree-oct26-29x21.png",29,21],"25x19":["user-drex-textfree-oct26-25x18.png",25,18],"22x20":["user-drex-textfree-oct26-22x16.png",22,16],"24x25":["user-drex-textfree-oct26-24x17.png",24,17],"30x19":["user-drex-textfree-oct26-26x19.png",26,19],"25x22":["user-drex-textfree-oct26-25x18.png",25,18],"28x25":["user-drex-textfree-oct26-28x20.png",28,20]},"BEL":{"38x24":["user-bel-textfree-oct26-25x24.png",25,24],"34x24":["user-bel-textfree-oct26-25x24.png",25,24],"26x23":["user-bel-textfree-oct26-24x23.png",24,23],"31x24":["user-bel-textfree-oct26-25x24.png",25,24],"29x22":["user-bel-textfree-oct26-23x22.png",23,22],"25x19":["user-bel-textfree-oct26-20x19.png",20,19],"22x20":["user-bel-textfree-oct26-21x20.png",21,20],"24x25":["user-bel-textfree-oct26-24x23.png",24,23],"30x19":["user-bel-textfree-oct26-20x19.png",20,19],"25x22":["user-bel-textfree-oct26-23x22.png",23,22],"28x25":["user-bel-textfree-oct26-26x25.png",26,25]},"DUKE":{"38x24":["user-duke-27x24.png",27,24],"34x24":["user-duke-27x24.png",27,24],"26x23":["user-duke-26x23.png",26,23],"31x24":["user-duke-27x24.png",27,24],"29x22":["user-duke-25x22.png",25,22],"25x19":["user-duke-21x19.png",21,19],"22x20":["user-duke-22x20.png",22,20],"24x25":["user-duke-24x21.png",24,21],"30x19":["user-duke-21x19.png",21,19],"25x22":["user-duke-25x22.png",25,22],"28x25":["user-duke-28x25.png",28,25]}})
TEAM_LOGO_BOUNDS.update({"BELL":[26,23,4,0,21,23],"BING":[26,23,1,0,24,23],"BRY":[26,23,0,0,26,23],"BUCK":[26,23,3,0,23,23],"CSUN":[26,23,3,0,23,23],"CAN":[26,23,0,2,26,21],"CHSO":[26,23,0,2,26,21],"CLE":[26,23,2,0,24,23],"DREX":[26,23,0,2,26,21],"BEL":[26,23,1,0,25,23],"DUKE":[26,23,0,0,26,23]})

USER_LOGO_FRAMES.update({"DUQ":{"38x24":["user-duq-12x24.png",12,24],"34x24":["user-duq-12x24.png",12,24],"26x23":["user-duq-11x23.png",11,23],"31x24":["user-duq-12x24.png",12,24],"29x22":["user-duq-11x22.png",11,22],"25x19":["user-duq-9x19.png",9,19],"22x20":["user-duq-10x20.png",10,20],"24x25":["user-duq-12x25.png",12,25],"30x19":["user-duq-9x19.png",9,19],"25x22":["user-duq-11x22.png",11,22],"28x25":["user-duq-12x25.png",12,25]},"ECU":{"38x24":["user-ecu-23x24.png",23,24],"34x24":["user-ecu-23x24.png",23,24],"26x23":["user-ecu-22x23.png",22,23],"31x24":["user-ecu-23x24.png",23,24],"29x22":["user-ecu-21x22.png",21,22],"25x19":["user-ecu-18x19.png",18,19],"22x20":["user-ecu-19x20.png",19,20],"24x25":["user-ecu-24x25.png",24,25],"30x19":["user-ecu-18x19.png",18,19],"25x22":["user-ecu-21x22.png",21,22],"28x25":["user-ecu-24x25.png",24,25]},"ETSU":{"38x24":["user-etsu-24x24.png",24,24],"34x24":["user-etsu-24x24.png",24,24],"26x23":["user-etsu-23x23.png",23,23],"31x24":["user-etsu-24x24.png",24,24],"29x22":["user-etsu-22x22.png",22,22],"25x19":["user-etsu-19x19.png",19,19],"22x20":["user-etsu-20x20.png",20,20],"24x25":["user-etsu-24x24.png",24,24],"30x19":["user-etsu-19x19.png",19,19],"25x22":["user-etsu-22x22.png",22,22],"28x25":["user-etsu-25x25.png",25,25]},"ETAM":{"38x24":["user-etam-24x24.png",24,24],"34x24":["user-etam-24x24.png",24,24],"26x23":["user-etam-23x23.png",23,23],"31x24":["user-etam-24x24.png",24,24],"29x22":["user-etam-22x22.png",22,22],"25x19":["user-etam-19x19.png",19,19],"22x20":["user-etam-20x20.png",20,20],"24x25":["user-etam-24x24.png",24,24],"30x19":["user-etam-19x19.png",19,19],"25x22":["user-etam-22x22.png",22,22],"28x25":["user-etam-25x25.png",25,25]},"EIU":{"38x24":["user-eiu-28x24.png",28,24],"34x24":["user-eiu-28x24.png",28,24],"26x23":["user-eiu-26x22.png",26,22],"31x24":["user-eiu-28x24.png",28,24],"29x22":["user-eiu-26x22.png",26,22],"25x19":["user-eiu-22x19.png",22,19],"22x20":["user-eiu-22x19.png",22,19],"24x25":["user-eiu-24x21.png",24,21],"30x19":["user-eiu-22x19.png",22,19],"25x22":["user-eiu-25x21.png",25,21],"28x25":["user-eiu-28x24.png",28,24]},"EKU":{"38x24":["user-eku-31x24.png",31,24],"34x24":["user-eku-31x24.png",31,24],"26x23":["user-eku-26x20.png",26,20],"31x24":["user-eku-31x24.png",31,24],"29x22":["user-eku-28x22.png",28,22],"25x19":["user-eku-24x19.png",24,19],"22x20":["user-eku-22x17.png",22,17],"24x25":["user-eku-24x19.png",24,19],"30x19":["user-eku-24x19.png",24,19],"25x22":["user-eku-25x20.png",25,20],"28x25":["user-eku-28x22.png",28,22]},"EMU":{"38x24":["user-emu-21x24.png",21,24],"34x24":["user-emu-21x24.png",21,24],"26x23":["user-emu-20x23.png",20,23],"31x24":["user-emu-21x24.png",21,24],"29x22":["user-emu-19x22.png",19,22],"25x19":["user-emu-17x19.png",17,19],"22x20":["user-emu-18x20.png",18,20],"24x25":["user-emu-22x25.png",22,25],"30x19":["user-emu-17x19.png",17,19],"25x22":["user-emu-19x22.png",19,22],"28x25":["user-emu-22x25.png",22,25]},"EWU":{"38x24":["user-ewu-26x24.png",26,24],"34x24":["user-ewu-26x24.png",26,24],"26x23":["user-ewu-25x23.png",25,23],"31x24":["user-ewu-26x24.png",26,24],"29x22":["user-ewu-23x22.png",23,22],"25x19":["user-ewu-20x19.png",20,19],"22x20":["user-ewu-21x20.png",21,20],"24x25":["user-ewu-24x23.png",24,23],"30x19":["user-ewu-20x19.png",20,19],"25x22":["user-ewu-23x22.png",23,22],"28x25":["user-ewu-27x25.png",27,25]},"ELON":{"38x24":["user-elon-31x24.png",31,24],"34x24":["user-elon-31x24.png",31,24],"26x23":["user-elon-26x20.png",26,20],"31x24":["user-elon-31x24.png",31,24],"29x22":["user-elon-28x22.png",28,22],"25x19":["user-elon-24x19.png",24,19],"22x20":["user-elon-22x17.png",22,17],"24x25":["user-elon-24x19.png",24,19],"30x19":["user-elon-24x19.png",24,19],"25x22":["user-elon-25x20.png",25,20],"28x25":["user-elon-28x22.png",28,22]},"EVAN":{"38x24":["user-evan-29x24.png",29,24],"34x24":["user-evan-29x24.png",29,24],"26x23":["user-evan-26x22.png",26,22],"31x24":["user-evan-29x24.png",29,24],"29x22":["user-evan-26x22.png",26,22],"25x19":["user-evan-23x19.png",23,19],"22x20":["user-evan-22x18.png",22,18],"24x25":["user-evan-24x20.png",24,20],"30x19":["user-evan-23x19.png",23,19],"25x22":["user-evan-25x21.png",25,21],"28x25":["user-evan-28x23.png",28,23]},"FAIR":{"38x24":["user-fair-27x24.png",27,24],"34x24":["user-fair-27x24.png",27,24],"26x23":["user-fair-26x23.png",26,23],"31x24":["user-fair-27x24.png",27,24],"29x22":["user-fair-25x22.png",25,22],"25x19":["user-fair-22x19.png",22,19],"22x20":["user-fair-22x19.png",22,19],"24x25":["user-fair-24x21.png",24,21],"30x19":["user-fair-22x19.png",22,19],"25x22":["user-fair-25x22.png",25,22],"28x25":["user-fair-28x25.png",28,25]},"FDU":{"38x24":["user-fdu-26x24.png",26,24],"34x24":["user-fdu-26x24.png",26,24],"26x23":["user-fdu-25x23.png",25,23],"31x24":["user-fdu-26x24.png",26,24],"29x22":["user-fdu-24x22.png",24,22],"25x19":["user-fdu-20x19.png",20,19],"22x20":["user-fdu-22x20.png",22,20],"24x25":["user-fdu-24x22.png",24,22],"30x19":["user-fdu-20x19.png",20,19],"25x22":["user-fdu-24x22.png",24,22],"28x25":["user-fdu-27x25.png",27,25]},"FLA":{"38x24":["user-fla-38x24.png",38,24],"34x24":["user-fla-34x22.png",34,22],"26x23":["user-fla-26x17.png",26,17],"31x24":["user-fla-31x20.png",31,20],"29x22":["user-fla-29x18.png",29,18],"25x19":["user-fla-25x16.png",25,16],"22x20":["user-fla-22x14.png",22,14],"24x25":["user-fla-24x15.png",24,15],"30x19":["user-fla-30x19.png",30,19],"25x22":["user-fla-25x16.png",25,16],"28x25":["user-fla-28x18.png",28,18]},"FAMU":{"38x24":["user-famu-32x24.png",32,24],"34x24":["user-famu-32x24.png",32,24],"26x23":["user-famu-26x20.png",26,20],"31x24":["user-famu-31x23.png",31,23],"29x22":["user-famu-29x22.png",29,22],"25x19":["user-famu-25x19.png",25,19],"22x20":["user-famu-22x17.png",22,17],"24x25":["user-famu-24x18.png",24,18],"30x19":["user-famu-25x19.png",25,19],"25x22":["user-famu-25x19.png",25,19],"28x25":["user-famu-28x21.png",28,21]},"FAU":{"38x24":["user-fau-37x24.png",37,24],"34x24":["user-fau-34x22.png",34,22],"26x23":["user-fau-26x17.png",26,17],"31x24":["user-fau-31x20.png",31,20],"29x22":["user-fau-29x19.png",29,19],"25x19":["user-fau-25x16.png",25,16],"22x20":["user-fau-22x14.png",22,14],"24x25":["user-fau-24x15.png",24,15],"30x19":["user-fau-30x19.png",30,19],"25x22":["user-fau-25x16.png",25,16],"28x25":["user-fau-28x18.png",28,18]},"FGCU":{"38x24":["user-fgcu-34x24.png",34,24],"34x24":["user-fgcu-34x24.png",34,24],"26x23":["user-fgcu-26x19.png",26,19],"31x24":["user-fgcu-31x22.png",31,22],"29x22":["user-fgcu-29x21.png",29,21],"25x19":["user-fgcu-25x18.png",25,18],"22x20":["user-fgcu-22x16.png",22,16],"24x25":["user-fgcu-24x17.png",24,17],"30x19":["user-fgcu-27x19.png",27,19],"25x22":["user-fgcu-25x18.png",25,18],"28x25":["user-fgcu-28x20.png",28,20]}})
TEAM_LOGO_BOUNDS.update({"DUQ":[26,23,7,0,18,23],"ECU":[26,23,2,0,24,23],"ETSU":[26,23,1,0,24,23],"ETAM":[26,23,1,0,24,23],"EIU":[26,23,0,0,26,22],"EKU":[26,23,0,1,26,21],"EMU":[26,23,3,0,23,23],"EWU":[26,23,0,0,25,23],"ELON":[26,23,0,1,26,21],"EVAN":[26,23,0,0,26,22],"FAIR":[26,23,0,0,26,23],"FDU":[26,23,0,0,25,23],"FLA":[26,23,0,3,26,20],"FAMU":[26,23,0,1,26,21],"FAU":[26,23,0,3,26,20],"FGCU":[26,23,0,2,26,21]})

USER_LOGO_FRAMES.update({"EWU":{"38x24":["user-ewu-readable-oct26-26x24.png",26,24],"34x24":["user-ewu-readable-oct26-26x24.png",26,24],"26x23":["user-ewu-readable-oct26-25x23.png",25,23],"31x24":["user-ewu-readable-oct26-26x24.png",26,24],"29x22":["user-ewu-readable-oct26-23x22.png",23,22],"25x19":["user-ewu-readable-oct26-20x19.png",20,19],"22x20":["user-ewu-readable-oct26-21x20.png",21,20],"24x25":["user-ewu-readable-oct26-24x23.png",24,23],"30x19":["user-ewu-readable-oct26-20x19.png",20,19],"25x22":["user-ewu-readable-oct26-23x22.png",23,22],"28x25":["user-ewu-readable-oct26-27x25.png",27,25]}})
TEAM_LOGO_BOUNDS.update({"EWU":[26,23,0,0,25,23]})

USER_LOGO_FRAMES.update({"FIU":{"38x24":["user-fiu-19x24.png",19,24],"34x24":["user-fiu-19x24.png",19,24],"26x23":["user-fiu-18x23.png",18,23],"31x24":["user-fiu-19x24.png",19,24],"29x22":["user-fiu-17x22.png",17,22],"25x19":["user-fiu-15x19.png",15,19],"22x20":["user-fiu-16x20.png",16,20],"24x25":["user-fiu-19x25.png",19,25],"30x19":["user-fiu-15x19.png",15,19],"25x22":["user-fiu-17x22.png",17,22],"28x25":["user-fiu-19x25.png",19,25]},"FSU":{"38x24":["user-fsu-24x24.png",24,24],"34x24":["user-fsu-24x24.png",24,24],"26x23":["user-fsu-23x23.png",23,23],"31x24":["user-fsu-24x24.png",24,24],"29x22":["user-fsu-22x22.png",22,22],"25x19":["user-fsu-19x19.png",19,19],"22x20":["user-fsu-20x20.png",20,20],"24x25":["user-fsu-24x24.png",24,24],"30x19":["user-fsu-19x19.png",19,19],"25x22":["user-fsu-22x22.png",22,22],"28x25":["user-fsu-25x25.png",25,25]},"FOR":{"38x24":["user-for-27x24.png",27,24],"34x24":["user-for-27x24.png",27,24],"26x23":["user-for-26x23.png",26,23],"31x24":["user-for-27x24.png",27,24],"29x22":["user-for-25x22.png",25,22],"25x19":["user-for-21x19.png",21,19],"22x20":["user-for-22x20.png",22,20],"24x25":["user-for-24x22.png",24,22],"30x19":["user-for-21x19.png",21,19],"25x22":["user-for-25x22.png",25,22],"28x25":["user-for-28x25.png",28,25]},"FRES":{"38x24":["user-fres-33x24.png",33,24],"34x24":["user-fres-33x24.png",33,24],"26x23":["user-fres-26x19.png",26,19],"31x24":["user-fres-31x22.png",31,22],"29x22":["user-fres-29x21.png",29,21],"25x19":["user-fres-25x18.png",25,18],"22x20":["user-fres-22x16.png",22,16],"24x25":["user-fres-24x17.png",24,17],"30x19":["user-fres-26x19.png",26,19],"25x22":["user-fres-25x18.png",25,18],"28x25":["user-fres-28x20.png",28,20]},"FUR":{"38x24":["user-fur-refresh-oct26-24x24.png",24,24],"34x24":["user-fur-refresh-oct26-24x24.png",24,24],"26x23":["user-fur-refresh-oct26-23x23.png",23,23],"31x24":["user-fur-refresh-oct26-24x24.png",24,24],"29x22":["user-fur-refresh-oct26-22x22.png",22,22],"25x19":["user-fur-refresh-oct26-19x19.png",19,19],"22x20":["user-fur-refresh-oct26-20x20.png",20,20],"24x25":["user-fur-refresh-oct26-24x24.png",24,24],"30x19":["user-fur-refresh-oct26-19x19.png",19,19],"25x22":["user-fur-refresh-oct26-22x22.png",22,22],"28x25":["user-fur-refresh-oct26-26x25.png",26,25]},"GWEB":{"38x24":["user-gweb-26x24.png",26,24],"34x24":["user-gweb-26x24.png",26,24],"26x23":["user-gweb-25x23.png",25,23],"31x24":["user-gweb-26x24.png",26,24],"29x22":["user-gweb-24x22.png",24,22],"25x19":["user-gweb-21x19.png",21,19],"22x20":["user-gweb-22x20.png",22,20],"24x25":["user-gweb-24x22.png",24,22],"30x19":["user-gweb-21x19.png",21,19],"25x22":["user-gweb-24x22.png",24,22],"28x25":["user-gweb-27x25.png",27,25]},"GMU":{"38x24":["user-gmu-24x24.png",24,24],"34x24":["user-gmu-24x24.png",24,24],"26x23":["user-gmu-23x23.png",23,23],"31x24":["user-gmu-24x24.png",24,24],"29x22":["user-gmu-22x22.png",22,22],"25x19":["user-gmu-19x19.png",19,19],"22x20":["user-gmu-20x20.png",20,20],"24x25":["user-gmu-24x24.png",24,24],"30x19":["user-gmu-19x19.png",19,19],"25x22":["user-gmu-22x22.png",22,22],"28x25":["user-gmu-25x25.png",25,25]},"GW":{"38x24":["user-gw-34x24.png",34,24],"34x24":["user-gw-34x24.png",34,24],"26x23":["user-gw-26x18.png",26,18],"31x24":["user-gw-31x22.png",31,22],"29x22":["user-gw-29x20.png",29,20],"25x19":["user-gw-25x17.png",25,17],"22x20":["user-gw-22x15.png",22,15],"24x25":["user-gw-24x17.png",24,17],"30x19":["user-gw-27x19.png",27,19],"25x22":["user-gw-25x17.png",25,17],"28x25":["user-gw-28x20.png",28,20]},"UGA":{"38x24":["user-uga-37x24.png",37,24],"34x24":["user-uga-34x22.png",34,22],"26x23":["user-uga-26x17.png",26,17],"31x24":["user-uga-31x20.png",31,20],"29x22":["user-uga-29x19.png",29,19],"25x19":["user-uga-25x16.png",25,16],"22x20":["user-uga-22x14.png",22,14],"24x25":["user-uga-24x16.png",24,16],"30x19":["user-uga-29x19.png",29,19],"25x22":["user-uga-25x16.png",25,16],"28x25":["user-uga-28x18.png",28,18]},"GASO":{"38x24":["user-gaso-38x23.png",38,23],"34x24":["user-gaso-34x20.png",34,20],"26x23":["user-gaso-26x15.png",26,15],"31x24":["user-gaso-31x18.png",31,18],"29x22":["user-gaso-29x17.png",29,17],"25x19":["user-gaso-25x15.png",25,15],"22x20":["user-gaso-22x13.png",22,13],"24x25":["user-gaso-24x14.png",24,14],"30x19":["user-gaso-30x18.png",30,18],"25x22":["user-gaso-25x15.png",25,15],"28x25":["user-gaso-28x17.png",28,17]},"GAST":{"38x24":["user-gast-29x24.png",29,24],"34x24":["user-gast-29x24.png",29,24],"26x23":["user-gast-26x21.png",26,21],"31x24":["user-gast-29x24.png",29,24],"29x22":["user-gast-27x22.png",27,22],"25x19":["user-gast-23x19.png",23,19],"22x20":["user-gast-22x18.png",22,18],"24x25":["user-gast-24x20.png",24,20],"30x19":["user-gast-23x19.png",23,19],"25x22":["user-gast-25x21.png",25,21],"28x25":["user-gast-28x23.png",28,23]},"GT":{"38x24":["user-gt-38x24.png",38,24],"34x24":["user-gt-34x21.png",34,21],"26x23":["user-gt-26x16.png",26,16],"31x24":["user-gt-31x20.png",31,20],"29x22":["user-gt-29x18.png",29,18],"25x19":["user-gt-25x16.png",25,16],"22x20":["user-gt-22x14.png",22,14],"24x25":["user-gt-24x15.png",24,15],"30x19":["user-gt-30x19.png",30,19],"25x22":["user-gt-25x16.png",25,16],"28x25":["user-gt-28x18.png",28,18]},"GONZ":{"38x24":["user-gonz-30x24.png",30,24],"34x24":["user-gonz-30x24.png",30,24],"26x23":["user-gonz-26x21.png",26,21],"31x24":["user-gonz-30x24.png",30,24],"29x22":["user-gonz-27x22.png",27,22],"25x19":["user-gonz-24x19.png",24,19],"22x20":["user-gonz-22x18.png",22,18],"24x25":["user-gonz-24x19.png",24,19],"30x19":["user-gonz-24x19.png",24,19],"25x22":["user-gonz-25x20.png",25,20],"28x25":["user-gonz-28x22.png",28,22]},"GRAM":{"38x24":["user-gram-38x24.png",38,24],"34x24":["user-gram-34x22.png",34,22],"26x23":["user-gram-26x17.png",26,17],"31x24":["user-gram-31x20.png",31,20],"29x22":["user-gram-29x18.png",29,18],"25x19":["user-gram-25x16.png",25,16],"22x20":["user-gram-22x14.png",22,14],"24x25":["user-gram-24x15.png",24,15],"30x19":["user-gram-30x19.png",30,19],"25x22":["user-gram-25x16.png",25,16],"28x25":["user-gram-28x18.png",28,18]},"GCU":{"38x24":["user-gcu-38x13.png",38,13],"34x24":["user-gcu-34x12.png",34,12],"26x23":["user-gcu-26x9.png",26,9],"31x24":["user-gcu-31x11.png",31,11],"29x22":["user-gcu-29x10.png",29,10],"25x19":["user-gcu-25x9.png",25,9],"22x20":["user-gcu-22x8.png",22,8],"24x25":["user-gcu-24x9.png",24,9],"30x19":["user-gcu-30x11.png",30,11],"25x22":["user-gcu-25x9.png",25,9],"28x25":["user-gcu-28x10.png",28,10]}})
TEAM_LOGO_BOUNDS.update({"FIU":[26,23,4,0,22,23],"FSU":[26,23,1,0,24,23],"FOR":[26,23,0,0,26,23],"FRES":[26,23,0,2,26,21],"FUR":[26,23,1,0,24,23],"GWEB":[26,23,0,0,25,23],"GMU":[26,23,1,0,24,23],"GW":[26,23,0,2,26,20],"UGA":[26,23,0,3,26,20],"GASO":[26,23,0,4,26,19],"GAST":[26,23,0,1,26,22],"GT":[26,23,0,3,26,19],"GONZ":[26,23,0,1,26,22],"GRAM":[26,23,0,3,26,20],"GCU":[26,23,0,7,26,16]})

USER_LOGO_FRAMES.update({"FIU":{"38x24":["user-fiu-textfree-oct26-21x24.png",21,24],"34x24":["user-fiu-textfree-oct26-21x24.png",21,24],"26x23":["user-fiu-textfree-oct26-20x23.png",20,23],"31x24":["user-fiu-textfree-oct26-21x24.png",21,24],"29x22":["user-fiu-textfree-oct26-20x22.png",20,22],"25x19":["user-fiu-textfree-oct26-17x19.png",17,19],"22x20":["user-fiu-textfree-oct26-18x20.png",18,20],"24x25":["user-fiu-textfree-oct26-22x25.png",22,25],"30x19":["user-fiu-textfree-oct26-17x19.png",17,19],"25x22":["user-fiu-textfree-oct26-20x22.png",20,22],"28x25":["user-fiu-textfree-oct26-22x25.png",22,25]}})
TEAM_LOGO_BOUNDS.update({"FIU":[26,23,3,0,23,23]})

USER_LOGO_FRAMES.update({"GTWN":{"38x24":["user-gtwn-24x24.png",24,24],"34x24":["user-gtwn-24x24.png",24,24],"26x23":["user-gtwn-23x23.png",23,23],"31x24":["user-gtwn-24x24.png",24,24],"29x22":["user-gtwn-22x22.png",22,22],"25x19":["user-gtwn-19x19.png",19,19],"22x20":["user-gtwn-20x20.png",20,20],"24x25":["user-gtwn-24x24.png",24,24],"30x19":["user-gtwn-19x19.png",19,19],"25x22":["user-gtwn-22x22.png",22,22],"28x25":["user-gtwn-25x25.png",25,25]}})
TEAM_LOGO_BOUNDS.update({"GTWN":[26,23,1,0,24,23]})

USER_LOGO_FRAMES.update({"GASO":{"38x24":["user-gaso-textfree-oct26-38x22.png",38,22],"34x24":["user-gaso-textfree-oct26-34x20.png",34,20],"26x23":["user-gaso-textfree-oct26-26x15.png",26,15],"31x24":["user-gaso-textfree-oct26-31x18.png",31,18],"29x22":["user-gaso-textfree-oct26-29x17.png",29,17],"25x19":["user-gaso-textfree-oct26-25x15.png",25,15],"22x20":["user-gaso-textfree-oct26-22x13.png",22,13],"24x25":["user-gaso-textfree-oct26-24x14.png",24,14],"30x19":["user-gaso-textfree-oct26-30x18.png",30,18],"25x22":["user-gaso-textfree-oct26-25x15.png",25,15],"28x25":["user-gaso-textfree-oct26-28x16.png",28,16]}})
TEAM_LOGO_BOUNDS.update({"GASO":[26,23,0,4,26,19]})

USER_LOGO_FRAMES.update({"GB":{"38x24":["user-gb-31x24.png",31,24],"34x24":["user-gb-31x24.png",31,24],"26x23":["user-gb-26x20.png",26,20],"31x24":["user-gb-31x24.png",31,24],"29x22":["user-gb-28x22.png",28,22],"25x19":["user-gb-24x19.png",24,19],"22x20":["user-gb-22x17.png",22,17],"24x25":["user-gb-24x19.png",24,19],"30x19":["user-gb-24x19.png",24,19],"25x22":["user-gb-25x20.png",25,20],"28x25":["user-gb-28x22.png",28,22]},"HAMP":{"38x24":["user-hamp-22x24.png",22,24],"34x24":["user-hamp-22x24.png",22,24],"26x23":["user-hamp-21x23.png",21,23],"31x24":["user-hamp-22x24.png",22,24],"29x22":["user-hamp-20x22.png",20,22],"25x19":["user-hamp-17x19.png",17,19],"22x20":["user-hamp-18x20.png",18,20],"24x25":["user-hamp-23x25.png",23,25],"30x19":["user-hamp-17x19.png",17,19],"25x22":["user-hamp-20x22.png",20,22],"28x25":["user-hamp-23x25.png",23,25]},"HARV":{"38x24":["user-harv-20x24.png",20,24],"34x24":["user-harv-20x24.png",20,24],"26x23":["user-harv-19x23.png",19,23],"31x24":["user-harv-20x24.png",20,24],"29x22":["user-harv-18x22.png",18,22],"25x19":["user-harv-16x19.png",16,19],"22x20":["user-harv-16x20.png",16,20],"24x25":["user-harv-20x25.png",20,25],"30x19":["user-harv-16x19.png",16,19],"25x22":["user-harv-18x22.png",18,22],"28x25":["user-harv-20x25.png",20,25]},"HAW":{"38x24":["user-haw-32x24.png",32,24],"34x24":["user-haw-32x24.png",32,24],"26x23":["user-haw-26x20.png",26,20],"31x24":["user-haw-31x23.png",31,23],"29x22":["user-haw-29x22.png",29,22],"25x19":["user-haw-25x19.png",25,19],"22x20":["user-haw-22x17.png",22,17],"24x25":["user-haw-24x18.png",24,18],"30x19":["user-haw-25x19.png",25,19],"25x22":["user-haw-25x19.png",25,19],"28x25":["user-haw-28x21.png",28,21]},"HPU":{"38x24":["user-hpu-38x23.png",38,23],"34x24":["user-hpu-34x20.png",34,20],"26x23":["user-hpu-26x15.png",26,15],"31x24":["user-hpu-31x18.png",31,18],"29x22":["user-hpu-29x17.png",29,17],"25x19":["user-hpu-25x15.png",25,15],"22x20":["user-hpu-22x13.png",22,13],"24x25":["user-hpu-24x14.png",24,14],"30x19":["user-hpu-30x18.png",30,18],"25x22":["user-hpu-25x15.png",25,15],"28x25":["user-hpu-28x17.png",28,17]},"HOF":{"38x24":["user-hof-38x23.png",38,23],"34x24":["user-hof-34x21.png",34,21],"26x23":["user-hof-26x16.png",26,16],"31x24":["user-hof-31x19.png",31,19],"29x22":["user-hof-29x18.png",29,18],"25x19":["user-hof-25x15.png",25,15],"22x20":["user-hof-22x13.png",22,13],"24x25":["user-hof-24x15.png",24,15],"30x19":["user-hof-30x18.png",30,18],"25x22":["user-hof-25x15.png",25,15],"28x25":["user-hof-28x17.png",28,17]},"HC":{"38x24":["user-hc-20x24.png",20,24],"34x24":["user-hc-20x24.png",20,24],"26x23":["user-hc-20x23.png",20,23],"31x24":["user-hc-20x24.png",20,24],"29x22":["user-hc-19x22.png",19,22],"25x19":["user-hc-16x19.png",16,19],"22x20":["user-hc-17x20.png",17,20],"24x25":["user-hc-21x25.png",21,25],"30x19":["user-hc-16x19.png",16,19],"25x22":["user-hc-19x22.png",19,22],"28x25":["user-hc-21x25.png",21,25]},"HOU":{"38x24":["user-hou-25x24.png",25,24],"34x24":["user-hou-25x24.png",25,24],"26x23":["user-hou-24x23.png",24,23],"31x24":["user-hou-25x24.png",25,24],"29x22":["user-hou-23x22.png",23,22],"25x19":["user-hou-20x19.png",20,19],"22x20":["user-hou-21x20.png",21,20],"24x25":["user-hou-24x23.png",24,23],"30x19":["user-hou-20x19.png",20,19],"25x22":["user-hou-23x22.png",23,22],"28x25":["user-hou-26x25.png",26,25]},"HCU":{"38x24":["user-hcu-23x24.png",23,24],"34x24":["user-hcu-23x24.png",23,24],"26x23":["user-hcu-22x23.png",22,23],"31x24":["user-hcu-23x24.png",23,24],"29x22":["user-hcu-21x22.png",21,22],"25x19":["user-hcu-18x19.png",18,19],"22x20":["user-hcu-19x20.png",19,20],"24x25":["user-hcu-24x25.png",24,25],"30x19":["user-hcu-18x19.png",18,19],"25x22":["user-hcu-21x22.png",21,22],"28x25":["user-hcu-24x25.png",24,25]},"HOW":{"38x24":["user-how-19x24.png",19,24],"34x24":["user-how-19x24.png",19,24],"26x23":["user-how-18x23.png",18,23],"31x24":["user-how-19x24.png",19,24],"29x22":["user-how-17x22.png",17,22],"25x19":["user-how-15x19.png",15,19],"22x20":["user-how-16x20.png",16,20],"24x25":["user-how-19x25.png",19,25],"30x19":["user-how-15x19.png",15,19],"25x22":["user-how-17x22.png",17,22],"28x25":["user-how-19x25.png",19,25]},"IDHO":{"38x24":["user-idho-22x24.png",22,24],"34x24":["user-idho-22x24.png",22,24],"26x23":["user-idho-21x23.png",21,23],"31x24":["user-idho-22x24.png",22,24],"29x22":["user-idho-20x22.png",20,22],"25x19":["user-idho-17x19.png",17,19],"22x20":["user-idho-18x20.png",18,20],"24x25":["user-idho-23x25.png",23,25],"30x19":["user-idho-17x19.png",17,19],"25x22":["user-idho-20x22.png",20,22],"28x25":["user-idho-23x25.png",23,25]},"IDST":{"38x24":["user-idst-25x24.png",25,24],"34x24":["user-idst-25x24.png",25,24],"26x23":["user-idst-24x23.png",24,23],"31x24":["user-idst-25x24.png",25,24],"29x22":["user-idst-23x22.png",23,22],"25x19":["user-idst-20x19.png",20,19],"22x20":["user-idst-21x20.png",21,20],"24x25":["user-idst-24x23.png",24,23],"30x19":["user-idst-20x19.png",20,19],"25x22":["user-idst-23x22.png",23,22],"28x25":["user-idst-26x25.png",26,25]},"ILL":{"38x24":["user-ill-17x24.png",17,24],"34x24":["user-ill-17x24.png",17,24],"26x23":["user-ill-16x23.png",16,23],"31x24":["user-ill-17x24.png",17,24],"29x22":["user-ill-15x22.png",15,22],"25x19":["user-ill-13x19.png",13,19],"22x20":["user-ill-14x20.png",14,20],"24x25":["user-ill-17x25.png",17,25],"30x19":["user-ill-13x19.png",13,19],"25x22":["user-ill-15x22.png",15,22],"28x25":["user-ill-17x25.png",17,25]},"ILST":{"38x24":["user-ilst-38x23.png",38,23],"34x24":["user-ilst-34x21.png",34,21],"26x23":["user-ilst-26x16.png",26,16],"31x24":["user-ilst-31x19.png",31,19],"29x22":["user-ilst-29x18.png",29,18],"25x19":["user-ilst-25x15.png",25,15],"22x20":["user-ilst-22x13.png",22,13],"24x25":["user-ilst-24x15.png",24,15],"30x19":["user-ilst-30x18.png",30,18],"25x22":["user-ilst-25x15.png",25,15],"28x25":["user-ilst-28x17.png",28,17]},"UIW":{"38x24":["user-uiw-38x21.png",38,21],"34x24":["user-uiw-34x19.png",34,19],"26x23":["user-uiw-26x15.png",26,15],"31x24":["user-uiw-31x18.png",31,18],"29x22":["user-uiw-29x16.png",29,16],"25x19":["user-uiw-25x14.png",25,14],"22x20":["user-uiw-22x12.png",22,12],"24x25":["user-uiw-24x14.png",24,14],"30x19":["user-uiw-30x17.png",30,17],"25x22":["user-uiw-25x14.png",25,14],"28x25":["user-uiw-28x16.png",28,16]},"IND":{"38x24":["user-ind-19x24.png",19,24],"34x24":["user-ind-19x24.png",19,24],"26x23":["user-ind-18x23.png",18,23],"31x24":["user-ind-19x24.png",19,24],"29x22":["user-ind-17x22.png",17,22],"25x19":["user-ind-15x19.png",15,19],"22x20":["user-ind-16x20.png",16,20],"24x25":["user-ind-20x25.png",20,25],"30x19":["user-ind-15x19.png",15,19],"25x22":["user-ind-17x22.png",17,22],"28x25":["user-ind-20x25.png",20,25]},"INST":{"38x24":["user-inst-27x24.png",27,24],"34x24":["user-inst-27x24.png",27,24],"26x23":["user-inst-26x23.png",26,23],"31x24":["user-inst-27x24.png",27,24],"29x22":["user-inst-25x22.png",25,22],"25x19":["user-inst-22x19.png",22,19],"22x20":["user-inst-22x19.png",22,19],"24x25":["user-inst-24x21.png",24,21],"30x19":["user-inst-22x19.png",22,19],"25x22":["user-inst-25x22.png",25,22],"28x25":["user-inst-28x24.png",28,24]},"IONA":{"38x24":["user-iona-31x24.png",31,24],"34x24":["user-iona-31x24.png",31,24],"26x23":["user-iona-26x20.png",26,20],"31x24":["user-iona-31x24.png",31,24],"29x22":["user-iona-29x22.png",29,22],"25x19":["user-iona-25x19.png",25,19],"22x20":["user-iona-22x17.png",22,17],"24x25":["user-iona-24x18.png",24,18],"30x19":["user-iona-25x19.png",25,19],"25x22":["user-iona-25x19.png",25,19],"28x25":["user-iona-28x21.png",28,21]},"ISU":{"38x24":["user-isu-35x24.png",35,24],"34x24":["user-isu-34x23.png",34,23],"26x23":["user-isu-26x18.png",26,18],"31x24":["user-isu-31x21.png",31,21],"29x22":["user-isu-29x20.png",29,20],"25x19":["user-isu-25x17.png",25,17],"22x20":["user-isu-22x15.png",22,15],"24x25":["user-isu-24x17.png",24,17],"30x19":["user-isu-28x19.png",28,19],"25x22":["user-isu-25x17.png",25,17],"28x25":["user-isu-28x19.png",28,19]},"IOWA":{"38x24":["user-iowa-37x24.png",37,24],"34x24":["user-iowa-34x22.png",34,22],"26x23":["user-iowa-26x17.png",26,17],"31x24":["user-iowa-31x20.png",31,20],"29x22":["user-iowa-29x19.png",29,19],"25x19":["user-iowa-25x16.png",25,16],"22x20":["user-iowa-22x14.png",22,14],"24x25":["user-iowa-24x16.png",24,16],"30x19":["user-iowa-29x19.png",29,19],"25x22":["user-iowa-25x16.png",25,16],"28x25":["user-iowa-28x18.png",28,18]},"IUIN":{"38x24":["user-iuin-25x24.png",25,24],"34x24":["user-iuin-25x24.png",25,24],"26x23":["user-iuin-24x23.png",24,23],"31x24":["user-iuin-25x24.png",25,24],"29x22":["user-iuin-23x22.png",23,22],"25x19":["user-iuin-20x19.png",20,19],"22x20":["user-iuin-21x20.png",21,20],"24x25":["user-iuin-24x23.png",24,23],"30x19":["user-iuin-20x19.png",20,19],"25x22":["user-iuin-23x22.png",23,22],"28x25":["user-iuin-26x25.png",26,25]},"JKST":{"38x24":["user-jkst-38x23.png",38,23],"34x24":["user-jkst-34x21.png",34,21],"26x23":["user-jkst-26x16.png",26,16],"31x24":["user-jkst-31x19.png",31,19],"29x22":["user-jkst-29x18.png",29,18],"25x19":["user-jkst-25x15.png",25,15],"22x20":["user-jkst-22x14.png",22,14],"24x25":["user-jkst-24x15.png",24,15],"30x19":["user-jkst-30x18.png",30,18],"25x22":["user-jkst-25x15.png",25,15],"28x25":["user-jkst-28x17.png",28,17]},"JAX":{"38x24":["user-jax-38x24.png",38,24],"34x24":["user-jax-34x21.png",34,21],"26x23":["user-jax-26x16.png",26,16],"31x24":["user-jax-31x19.png",31,19],"29x22":["user-jax-29x18.png",29,18],"25x19":["user-jax-25x16.png",25,16],"22x20":["user-jax-22x14.png",22,14],"24x25":["user-jax-24x15.png",24,15],"30x19":["user-jax-30x19.png",30,19],"25x22":["user-jax-25x16.png",25,16],"28x25":["user-jax-28x17.png",28,17]},"JXST":{"38x24":["user-jxst-38x24.png",38,24],"34x24":["user-jxst-34x21.png",34,21],"26x23":["user-jxst-26x16.png",26,16],"31x24":["user-jxst-31x20.png",31,20],"29x22":["user-jxst-29x18.png",29,18],"25x19":["user-jxst-25x16.png",25,16],"22x20":["user-jxst-22x14.png",22,14],"24x25":["user-jxst-24x15.png",24,15],"30x19":["user-jxst-30x19.png",30,19],"25x22":["user-jxst-25x16.png",25,16],"28x25":["user-jxst-28x18.png",28,18]},"JMU":{"38x24":["user-jmu-18x24.png",18,24],"34x24":["user-jmu-18x24.png",18,24],"26x23":["user-jmu-17x23.png",17,23],"31x24":["user-jmu-18x24.png",18,24],"29x22":["user-jmu-16x22.png",16,22],"25x19":["user-jmu-14x19.png",14,19],"22x20":["user-jmu-15x20.png",15,20],"24x25":["user-jmu-19x25.png",19,25],"30x19":["user-jmu-14x19.png",14,19],"25x22":["user-jmu-16x22.png",16,22],"28x25":["user-jmu-19x25.png",19,25]},"KU":{"38x24":["user-ku-27x24.png",27,24],"34x24":["user-ku-27x24.png",27,24],"26x23":["user-ku-26x23.png",26,23],"31x24":["user-ku-27x24.png",27,24],"29x22":["user-ku-25x22.png",25,22],"25x19":["user-ku-21x19.png",21,19],"22x20":["user-ku-22x20.png",22,20],"24x25":["user-ku-24x21.png",24,21],"30x19":["user-ku-21x19.png",21,19],"25x22":["user-ku-25x22.png",25,22],"28x25":["user-ku-28x25.png",28,25]},"KC":{"38x24":["user-kc-25x24.png",25,24],"34x24":["user-kc-25x24.png",25,24],"26x23":["user-kc-24x23.png",24,23],"31x24":["user-kc-25x24.png",25,24],"29x22":["user-kc-23x22.png",23,22],"25x19":["user-kc-20x19.png",20,19],"22x20":["user-kc-21x20.png",21,20],"24x25":["user-kc-24x23.png",24,23],"30x19":["user-kc-20x19.png",20,19],"25x22":["user-kc-23x22.png",23,22],"28x25":["user-kc-26x25.png",26,25]},"KSU":{"38x24":["user-ksu-32x24.png",32,24],"34x24":["user-ksu-32x24.png",32,24],"26x23":["user-ksu-26x19.png",26,19],"31x24":["user-ksu-31x23.png",31,23],"29x22":["user-ksu-29x22.png",29,22],"25x19":["user-ksu-25x19.png",25,19],"22x20":["user-ksu-22x16.png",22,16],"24x25":["user-ksu-24x18.png",24,18],"30x19":["user-ksu-25x19.png",25,19],"25x22":["user-ksu-25x19.png",25,19],"28x25":["user-ksu-28x21.png",28,21]},"KENN":{"38x24":["user-kenn-25x24.png",25,24],"34x24":["user-kenn-25x24.png",25,24],"26x23":["user-kenn-24x23.png",24,23],"31x24":["user-kenn-25x24.png",25,24],"29x22":["user-kenn-23x22.png",23,22],"25x19":["user-kenn-20x19.png",20,19],"22x20":["user-kenn-21x20.png",21,20],"24x25":["user-kenn-24x23.png",24,23],"30x19":["user-kenn-20x19.png",20,19],"25x22":["user-kenn-23x22.png",23,22],"28x25":["user-kenn-27x25.png",27,25]},"KENT":{"38x24":["user-kent-36x24.png",36,24],"34x24":["user-kent-34x23.png",34,23],"26x23":["user-kent-26x18.png",26,18],"31x24":["user-kent-31x21.png",31,21],"29x22":["user-kent-29x20.png",29,20],"25x19":["user-kent-25x17.png",25,17],"22x20":["user-kent-22x15.png",22,15],"24x25":["user-kent-24x16.png",24,16],"30x19":["user-kent-28x19.png",28,19],"25x22":["user-kent-25x17.png",25,17],"28x25":["user-kent-28x19.png",28,19]},"LAS":{"38x24":["user-las-25x24.png",25,24],"34x24":["user-las-25x24.png",25,24],"26x23":["user-las-24x23.png",24,23],"31x24":["user-las-25x24.png",25,24],"29x22":["user-las-23x22.png",23,22],"25x19":["user-las-20x19.png",20,19],"22x20":["user-las-21x20.png",21,20],"24x25":["user-las-24x23.png",24,23],"30x19":["user-las-20x19.png",20,19],"25x22":["user-las-23x22.png",23,22],"28x25":["user-las-26x25.png",26,25]},"LAF":{"38x24":["user-laf-38x22.png",38,22],"34x24":["user-laf-34x20.png",34,20],"26x23":["user-laf-26x15.png",26,15],"31x24":["user-laf-31x18.png",31,18],"29x22":["user-laf-29x17.png",29,17],"25x19":["user-laf-25x14.png",25,14],"22x20":["user-laf-22x13.png",22,13],"24x25":["user-laf-24x14.png",24,14],"30x19":["user-laf-30x17.png",30,17],"25x22":["user-laf-25x14.png",25,14],"28x25":["user-laf-28x16.png",28,16]},"LAM":{"38x24":["user-lam-38x22.png",38,22],"34x24":["user-lam-34x20.png",34,20],"26x23":["user-lam-26x15.png",26,15],"31x24":["user-lam-31x18.png",31,18],"29x22":["user-lam-29x17.png",29,17],"25x19":["user-lam-25x15.png",25,15],"22x20":["user-lam-22x13.png",22,13],"24x25":["user-lam-24x14.png",24,14],"30x19":["user-lam-30x18.png",30,18],"25x22":["user-lam-25x15.png",25,15],"28x25":["user-lam-28x16.png",28,16]},"LEM":{"38x24":["user-lem-38x20.png",38,20],"34x24":["user-lem-34x18.png",34,18],"26x23":["user-lem-26x14.png",26,14],"31x24":["user-lem-31x17.png",31,17],"29x22":["user-lem-29x16.png",29,16],"25x19":["user-lem-25x13.png",25,13],"22x20":["user-lem-22x12.png",22,12],"24x25":["user-lem-24x13.png",24,13],"30x19":["user-lem-30x16.png",30,16],"25x22":["user-lem-25x13.png",25,13],"28x25":["user-lem-28x15.png",28,15]},"LEH":{"38x24":["user-leh-25x24.png",25,24],"34x24":["user-leh-25x24.png",25,24],"26x23":["user-leh-24x23.png",24,23],"31x24":["user-leh-25x24.png",25,24],"29x22":["user-leh-22x22.png",22,22],"25x19":["user-leh-19x19.png",19,19],"22x20":["user-leh-20x20.png",20,20],"24x25":["user-leh-24x23.png",24,23],"30x19":["user-leh-19x19.png",19,19],"25x22":["user-leh-22x22.png",22,22],"28x25":["user-leh-26x25.png",26,25]},"LIB":{"38x24":["user-lib-27x24.png",27,24],"34x24":["user-lib-27x24.png",27,24],"26x23":["user-lib-26x23.png",26,23],"31x24":["user-lib-27x24.png",27,24],"29x22":["user-lib-25x22.png",25,22],"25x19":["user-lib-22x19.png",22,19],"22x20":["user-lib-22x19.png",22,19],"24x25":["user-lib-24x21.png",24,21],"30x19":["user-lib-22x19.png",22,19],"25x22":["user-lib-25x22.png",25,22],"28x25":["user-lib-28x25.png",28,25]},"LIN":{"38x24":["user-lin-32x24.png",32,24],"34x24":["user-lin-32x24.png",32,24],"26x23":["user-lin-26x19.png",26,19],"31x24":["user-lin-31x23.png",31,23],"29x22":["user-lin-29x22.png",29,22],"25x19":["user-lin-25x19.png",25,19],"22x20":["user-lin-22x16.png",22,16],"24x25":["user-lin-24x18.png",24,18],"30x19":["user-lin-26x19.png",26,19],"25x22":["user-lin-25x19.png",25,19],"28x25":["user-lin-28x21.png",28,21]},"LIP":{"38x24":["user-lip-18x24.png",18,24],"34x24":["user-lip-18x24.png",18,24],"26x23":["user-lip-18x23.png",18,23],"31x24":["user-lip-18x24.png",18,24],"29x22":["user-lip-17x22.png",17,22],"25x19":["user-lip-15x19.png",15,19],"22x20":["user-lip-15x20.png",15,20],"24x25":["user-lip-19x25.png",19,25],"30x19":["user-lip-15x19.png",15,19],"25x22":["user-lip-17x22.png",17,22],"28x25":["user-lip-19x25.png",19,25]},"LR":{"38x24":["user-lr-38x21.png",38,21],"34x24":["user-lr-34x19.png",34,19],"26x23":["user-lr-26x14.png",26,14],"31x24":["user-lr-31x17.png",31,17],"29x22":["user-lr-29x16.png",29,16],"25x19":["user-lr-25x14.png",25,14],"22x20":["user-lr-22x12.png",22,12],"24x25":["user-lr-24x13.png",24,13],"30x19":["user-lr-30x16.png",30,16],"25x22":["user-lr-25x14.png",25,14],"28x25":["user-lr-28x15.png",28,15]},"LIU":{"38x24":["user-liu-27x24.png",27,24],"34x24":["user-liu-27x24.png",27,24],"26x23":["user-liu-26x23.png",26,23],"31x24":["user-liu-27x24.png",27,24],"29x22":["user-liu-25x22.png",25,22],"25x19":["user-liu-22x19.png",22,19],"22x20":["user-liu-22x19.png",22,19],"24x25":["user-liu-24x21.png",24,21],"30x19":["user-liu-22x19.png",22,19],"25x22":["user-liu-25x22.png",25,22],"28x25":["user-liu-28x25.png",28,25]},"LONG":{"38x24":["user-long-38x14.png",38,14],"34x24":["user-long-34x13.png",34,13],"26x23":["user-long-26x10.png",26,10],"31x24":["user-long-31x11.png",31,11],"29x22":["user-long-29x11.png",29,11],"25x19":["user-long-25x9.png",25,9],"22x20":["user-long-22x8.png",22,8],"24x25":["user-long-24x9.png",24,9],"30x19":["user-long-30x11.png",30,11],"25x22":["user-long-25x9.png",25,9],"28x25":["user-long-28x10.png",28,10]},"UL":{"38x24":["user-ul-38x19.png",38,19],"34x24":["user-ul-34x17.png",34,17],"26x23":["user-ul-26x13.png",26,13],"31x24":["user-ul-31x16.png",31,16],"29x22":["user-ul-29x15.png",29,15],"25x19":["user-ul-25x13.png",25,13],"22x20":["user-ul-22x11.png",22,11],"24x25":["user-ul-24x12.png",24,12],"30x19":["user-ul-30x15.png",30,15],"25x22":["user-ul-25x13.png",25,13],"28x25":["user-ul-28x14.png",28,14]},"LT":{"38x24":["user-lt-38x22.png",38,22],"34x24":["user-lt-34x20.png",34,20],"26x23":["user-lt-26x15.png",26,15],"31x24":["user-lt-31x18.png",31,18],"29x22":["user-lt-29x17.png",29,17],"25x19":["user-lt-25x15.png",25,15],"22x20":["user-lt-22x13.png",22,13],"24x25":["user-lt-24x14.png",24,14],"30x19":["user-lt-30x17.png",30,17],"25x22":["user-lt-25x15.png",25,15],"28x25":["user-lt-28x16.png",28,16]},"LOU":{"38x24":["user-lou-22x24.png",22,24],"34x24":["user-lou-22x24.png",22,24],"26x23":["user-lou-21x23.png",21,23],"31x24":["user-lou-22x24.png",22,24],"29x22":["user-lou-20x22.png",20,22],"25x19":["user-lou-17x19.png",17,19],"22x20":["user-lou-18x20.png",18,20],"24x25":["user-lou-23x25.png",23,25],"30x19":["user-lou-17x19.png",17,19],"25x22":["user-lou-20x22.png",20,22],"28x25":["user-lou-23x25.png",23,25]},"LUC":{"38x24":["user-luc-30x24.png",30,24],"34x24":["user-luc-30x24.png",30,24],"26x23":["user-luc-26x21.png",26,21],"31x24":["user-luc-30x24.png",30,24],"29x22":["user-luc-28x22.png",28,22],"25x19":["user-luc-24x19.png",24,19],"22x20":["user-luc-22x18.png",22,18],"24x25":["user-luc-24x19.png",24,19],"30x19":["user-luc-24x19.png",24,19],"25x22":["user-luc-25x20.png",25,20],"28x25":["user-luc-28x22.png",28,22]},"LMD":{"38x24":["user-lmd-22x24.png",22,24],"34x24":["user-lmd-22x24.png",22,24],"26x23":["user-lmd-21x23.png",21,23],"31x24":["user-lmd-22x24.png",22,24],"29x22":["user-lmd-20x22.png",20,22],"25x19":["user-lmd-17x19.png",17,19],"22x20":["user-lmd-18x20.png",18,20],"24x25":["user-lmd-23x25.png",23,25],"30x19":["user-lmd-17x19.png",17,19],"25x22":["user-lmd-20x22.png",20,22],"28x25":["user-lmd-23x25.png",23,25]},"LMU":{"38x24":["user-lmu-38x18.png",38,18],"34x24":["user-lmu-34x16.png",34,16],"26x23":["user-lmu-26x12.png",26,12],"31x24":["user-lmu-31x14.png",31,14],"29x22":["user-lmu-29x13.png",29,13],"25x19":["user-lmu-25x12.png",25,12],"22x20":["user-lmu-22x10.png",22,10],"24x25":["user-lmu-24x11.png",24,11],"30x19":["user-lmu-30x14.png",30,14],"25x22":["user-lmu-25x12.png",25,12],"28x25":["user-lmu-28x13.png",28,13]},"LSU":{"38x24":["user-lsu-38x13.png",38,13],"34x24":["user-lsu-34x11.png",34,11],"26x23":["user-lsu-26x9.png",26,9],"31x24":["user-lsu-31x10.png",31,10],"29x22":["user-lsu-29x10.png",29,10],"25x19":["user-lsu-25x8.png",25,8],"22x20":["user-lsu-22x7.png",22,7],"24x25":["user-lsu-24x8.png",24,8],"30x19":["user-lsu-30x10.png",30,10],"25x22":["user-lsu-25x8.png",25,8],"28x25":["user-lsu-28x9.png",28,9]},"ME":{"38x24":["user-me-31x24.png",31,24],"34x24":["user-me-31x24.png",31,24],"26x23":["user-me-26x20.png",26,20],"31x24":["user-me-31x24.png",31,24],"29x22":["user-me-29x22.png",29,22],"25x19":["user-me-25x19.png",25,19],"22x20":["user-me-22x17.png",22,17],"24x25":["user-me-24x18.png",24,18],"30x19":["user-me-25x19.png",25,19],"25x22":["user-me-25x19.png",25,19],"28x25":["user-me-28x21.png",28,21]},"MAN":{"38x24":["user-man-29x24.png",29,24],"34x24":["user-man-29x24.png",29,24],"26x23":["user-man-26x22.png",26,22],"31x24":["user-man-29x24.png",29,24],"29x22":["user-man-26x22.png",26,22],"25x19":["user-man-23x19.png",23,19],"22x20":["user-man-22x18.png",22,18],"24x25":["user-man-24x20.png",24,20],"30x19":["user-man-23x19.png",23,19],"25x22":["user-man-25x21.png",25,21],"28x25":["user-man-28x23.png",28,23]},"MRST":{"38x24":["user-mrst-38x18.png",38,18],"34x24":["user-mrst-34x16.png",34,16],"26x23":["user-mrst-26x13.png",26,13],"31x24":["user-mrst-31x15.png",31,15],"29x22":["user-mrst-29x14.png",29,14],"25x19":["user-mrst-25x12.png",25,12],"22x20":["user-mrst-22x11.png",22,11],"24x25":["user-mrst-24x12.png",24,12],"30x19":["user-mrst-30x15.png",30,15],"25x22":["user-mrst-25x12.png",25,12],"28x25":["user-mrst-28x14.png",28,14]},"MARQ":{"38x24":["user-marq-32x24.png",32,24],"34x24":["user-marq-32x24.png",32,24],"26x23":["user-marq-26x19.png",26,19],"31x24":["user-marq-31x23.png",31,23],"29x22":["user-marq-29x22.png",29,22],"25x19":["user-marq-25x19.png",25,19],"22x20":["user-marq-22x16.png",22,16],"24x25":["user-marq-24x18.png",24,18],"30x19":["user-marq-26x19.png",26,19],"25x22":["user-marq-25x19.png",25,19],"28x25":["user-marq-28x21.png",28,21]},"MRSH":{"38x24":["user-mrsh-36x24.png",36,24],"34x24":["user-mrsh-34x23.png",34,23],"26x23":["user-mrsh-26x17.png",26,17],"31x24":["user-mrsh-31x21.png",31,21],"29x22":["user-mrsh-29x19.png",29,19],"25x19":["user-mrsh-25x17.png",25,17],"22x20":["user-mrsh-22x15.png",22,15],"24x25":["user-mrsh-24x16.png",24,16],"30x19":["user-mrsh-29x19.png",29,19],"25x22":["user-mrsh-25x17.png",25,17],"28x25":["user-mrsh-28x19.png",28,19]},"MD":{"38x24":["user-md-22x24.png",22,24],"34x24":["user-md-22x24.png",22,24],"26x23":["user-md-21x23.png",21,23],"31x24":["user-md-22x24.png",22,24],"29x22":["user-md-20x22.png",20,22],"25x19":["user-md-17x19.png",17,19],"22x20":["user-md-18x20.png",18,20],"24x25":["user-md-23x25.png",23,25],"30x19":["user-md-17x19.png",17,19],"25x22":["user-md-20x22.png",20,22],"28x25":["user-md-23x25.png",23,25]},"UMES":{"38x24":["user-umes-38x17.png",38,17],"34x24":["user-umes-34x15.png",34,15],"26x23":["user-umes-26x11.png",26,11],"31x24":["user-umes-31x13.png",31,13],"29x22":["user-umes-29x13.png",29,13],"25x19":["user-umes-25x11.png",25,11],"22x20":["user-umes-22x10.png",22,10],"24x25":["user-umes-24x10.png",24,10],"30x19":["user-umes-30x13.png",30,13],"25x22":["user-umes-25x11.png",25,11],"28x25":["user-umes-28x12.png",28,12]},"MASS":{"38x24":["user-mass-29x24.png",29,24],"34x24":["user-mass-29x24.png",29,24],"26x23":["user-mass-26x21.png",26,21],"31x24":["user-mass-29x24.png",29,24],"29x22":["user-mass-27x22.png",27,22],"25x19":["user-mass-23x19.png",23,19],"22x20":["user-mass-22x18.png",22,18],"24x25":["user-mass-24x20.png",24,20],"30x19":["user-mass-23x19.png",23,19],"25x22":["user-mass-25x21.png",25,21],"28x25":["user-mass-28x23.png",28,23]},"MEM":{"38x24":["user-mem-28x24.png",28,24],"34x24":["user-mem-28x24.png",28,24],"26x23":["user-mem-26x23.png",26,23],"31x24":["user-mem-28x24.png",28,24],"29x22":["user-mem-25x22.png",25,22],"25x19":["user-mem-22x19.png",22,19],"22x20":["user-mem-22x19.png",22,19],"24x25":["user-mem-24x21.png",24,21],"30x19":["user-mem-22x19.png",22,19],"25x22":["user-mem-25x22.png",25,22],"28x25":["user-mem-28x24.png",28,24]},"MER":{"38x24":["user-mer-31x24.png",31,24],"34x24":["user-mer-31x24.png",31,24],"26x23":["user-mer-26x20.png",26,20],"31x24":["user-mer-31x24.png",31,24],"29x22":["user-mer-29x22.png",29,22],"25x19":["user-mer-25x19.png",25,19],"22x20":["user-mer-22x17.png",22,17],"24x25":["user-mer-24x18.png",24,18],"30x19":["user-mer-25x19.png",25,19],"25x22":["user-mer-25x19.png",25,19],"28x25":["user-mer-28x21.png",28,21]},"MERC":{"38x24":["user-merc-30x24.png",30,24],"34x24":["user-merc-30x24.png",30,24],"26x23":["user-merc-26x20.png",26,20],"31x24":["user-merc-30x24.png",30,24],"29x22":["user-merc-28x22.png",28,22],"25x19":["user-merc-24x19.png",24,19],"22x20":["user-merc-22x17.png",22,17],"24x25":["user-merc-24x19.png",24,19],"30x19":["user-merc-24x19.png",24,19],"25x22":["user-merc-25x20.png",25,20],"28x25":["user-merc-28x22.png",28,22]},"MIA":{"38x24":["user-mia-38x23.png",38,23],"34x24":["user-mia-34x21.png",34,21],"26x23":["user-mia-26x16.png",26,16],"31x24":["user-mia-31x19.png",31,19],"29x22":["user-mia-29x18.png",29,18],"25x19":["user-mia-25x15.png",25,15],"22x20":["user-mia-22x14.png",22,14],"24x25":["user-mia-24x15.png",24,15],"30x19":["user-mia-30x19.png",30,19],"25x22":["user-mia-25x15.png",25,15],"28x25":["user-mia-28x17.png",28,17]},"MOH":{"38x24":["user-moh-32x24.png",32,24],"34x24":["user-moh-32x24.png",32,24],"26x23":["user-moh-26x20.png",26,20],"31x24":["user-moh-31x23.png",31,23],"29x22":["user-moh-29x22.png",29,22],"25x19":["user-moh-25x19.png",25,19],"22x20":["user-moh-22x17.png",22,17],"24x25":["user-moh-24x18.png",24,18],"30x19":["user-moh-25x19.png",25,19],"25x22":["user-moh-25x19.png",25,19],"28x25":["user-moh-28x21.png",28,21]},"MICH":{"38x24":["user-mich-33x24.png",33,24],"34x24":["user-mich-33x24.png",33,24],"26x23":["user-mich-26x19.png",26,19],"31x24":["user-mich-31x22.png",31,22],"29x22":["user-mich-29x21.png",29,21],"25x19":["user-mich-25x18.png",25,18],"22x20":["user-mich-22x16.png",22,16],"24x25":["user-mich-24x17.png",24,17],"30x19":["user-mich-26x19.png",26,19],"25x22":["user-mich-25x18.png",25,18],"28x25":["user-mich-28x20.png",28,20]},"MTSU":{"38x24":["user-mtsu-37x24.png",37,24],"34x24":["user-mtsu-34x22.png",34,22],"26x23":["user-mtsu-26x17.png",26,17],"31x24":["user-mtsu-31x20.png",31,20],"29x22":["user-mtsu-29x19.png",29,19],"25x19":["user-mtsu-25x16.png",25,16],"22x20":["user-mtsu-22x14.png",22,14],"24x25":["user-mtsu-24x16.png",24,16],"30x19":["user-mtsu-29x19.png",29,19],"25x22":["user-mtsu-25x16.png",25,16],"28x25":["user-mtsu-28x18.png",28,18]},"MSU":{"38x24":["user-msu-21x24.png",21,24],"34x24":["user-msu-21x24.png",21,24],"26x23":["user-msu-20x23.png",20,23],"31x24":["user-msu-21x24.png",21,24],"29x22":["user-msu-19x22.png",19,22],"25x19":["user-msu-16x19.png",16,19],"22x20":["user-msu-17x20.png",17,20],"24x25":["user-msu-22x25.png",22,25],"30x19":["user-msu-16x19.png",16,19],"25x22":["user-msu-19x22.png",19,22],"28x25":["user-msu-22x25.png",22,25]},"MILW":{"38x24":["user-milw-25x24.png",25,24],"34x24":["user-milw-25x24.png",25,24],"26x23":["user-milw-24x23.png",24,23],"31x24":["user-milw-25x24.png",25,24],"29x22":["user-milw-23x22.png",23,22],"25x19":["user-milw-20x19.png",20,19],"22x20":["user-milw-21x20.png",21,20],"24x25":["user-milw-24x23.png",24,23],"30x19":["user-milw-20x19.png",20,19],"25x22":["user-milw-23x22.png",23,22],"28x25":["user-milw-26x25.png",26,25]},"MINN":{"38x24":["user-minn-38x22.png",38,22],"34x24":["user-minn-34x20.png",34,20],"26x23":["user-minn-26x15.png",26,15],"31x24":["user-minn-31x18.png",31,18],"29x22":["user-minn-29x17.png",29,17],"25x19":["user-minn-25x15.png",25,15],"22x20":["user-minn-22x13.png",22,13],"24x25":["user-minn-24x14.png",24,14],"30x19":["user-minn-30x18.png",30,18],"25x22":["user-minn-25x15.png",25,15],"28x25":["user-minn-28x17.png",28,17]},"MSST":{"38x24":["user-msst-38x23.png",38,23],"34x24":["user-msst-34x21.png",34,21],"26x23":["user-msst-26x16.png",26,16],"31x24":["user-msst-31x19.png",31,19],"29x22":["user-msst-29x18.png",29,18],"25x19":["user-msst-25x15.png",25,15],"22x20":["user-msst-22x13.png",22,13],"24x25":["user-msst-24x15.png",24,15],"30x19":["user-msst-30x18.png",30,18],"25x22":["user-msst-25x15.png",25,15],"28x25":["user-msst-28x17.png",28,17]},"MVSU":{"38x24":["user-mvsu-32x24.png",32,24],"34x24":["user-mvsu-32x24.png",32,24],"26x23":["user-mvsu-26x19.png",26,19],"31x24":["user-mvsu-31x23.png",31,23],"29x22":["user-mvsu-29x22.png",29,22],"25x19":["user-mvsu-25x19.png",25,19],"22x20":["user-mvsu-22x16.png",22,16],"24x25":["user-mvsu-24x18.png",24,18],"30x19":["user-mvsu-25x19.png",25,19],"25x22":["user-mvsu-25x19.png",25,19],"28x25":["user-mvsu-28x21.png",28,21]},"MIZ":{"38x24":["user-miz-38x22.png",38,22],"34x24":["user-miz-34x19.png",34,19],"26x23":["user-miz-26x15.png",26,15],"31x24":["user-miz-31x18.png",31,18],"29x22":["user-miz-29x17.png",29,17],"25x19":["user-miz-25x14.png",25,14],"22x20":["user-miz-22x13.png",22,13],"24x25":["user-miz-24x14.png",24,14],"30x19":["user-miz-30x17.png",30,17],"25x22":["user-miz-25x14.png",25,14],"28x25":["user-miz-28x16.png",28,16]},"MOST":{"38x24":["user-most-27x24.png",27,24],"34x24":["user-most-27x24.png",27,24],"26x23":["user-most-26x23.png",26,23],"31x24":["user-most-27x24.png",27,24],"29x22":["user-most-25x22.png",25,22],"25x19":["user-most-22x19.png",22,19],"22x20":["user-most-22x19.png",22,19],"24x25":["user-most-24x21.png",24,21],"30x19":["user-most-22x19.png",22,19],"25x22":["user-most-25x22.png",25,22],"28x25":["user-most-28x25.png",28,25]},"MONM":{"38x24":["user-monm-31x24.png",31,24],"34x24":["user-monm-31x24.png",31,24],"26x23":["user-monm-26x20.png",26,20],"31x24":["user-monm-31x24.png",31,24],"29x22":["user-monm-28x22.png",28,22],"25x19":["user-monm-24x19.png",24,19],"22x20":["user-monm-22x17.png",22,17],"24x25":["user-monm-24x19.png",24,19],"30x19":["user-monm-24x19.png",24,19],"25x22":["user-monm-25x19.png",25,19],"28x25":["user-monm-28x22.png",28,22]},"MONT":{"38x24":["user-mont-33x24.png",33,24],"34x24":["user-mont-33x24.png",33,24],"26x23":["user-mont-26x19.png",26,19],"31x24":["user-mont-31x23.png",31,23],"29x22":["user-mont-29x21.png",29,21],"25x19":["user-mont-25x18.png",25,18],"22x20":["user-mont-22x16.png",22,16],"24x25":["user-mont-24x18.png",24,18],"30x19":["user-mont-26x19.png",26,19],"25x22":["user-mont-25x18.png",25,18],"28x25":["user-mont-28x20.png",28,20]},"MTST":{"38x24":["user-mtst-32x24.png",32,24],"34x24":["user-mtst-32x24.png",32,24],"26x23":["user-mtst-26x20.png",26,20],"31x24":["user-mtst-31x23.png",31,23],"29x22":["user-mtst-29x22.png",29,22],"25x19":["user-mtst-25x19.png",25,19],"22x20":["user-mtst-22x17.png",22,17],"24x25":["user-mtst-24x18.png",24,18],"30x19":["user-mtst-25x19.png",25,19],"25x22":["user-mtst-25x19.png",25,19],"28x25":["user-mtst-28x21.png",28,21]},"MORE":{"38x24":["user-more-25x24.png",25,24],"34x24":["user-more-25x24.png",25,24],"26x23":["user-more-24x23.png",24,23],"31x24":["user-more-25x24.png",25,24],"29x22":["user-more-23x22.png",23,22],"25x19":["user-more-19x19.png",19,19],"22x20":["user-more-20x20.png",20,20],"24x25":["user-more-24x23.png",24,23],"30x19":["user-more-19x19.png",19,19],"25x22":["user-more-23x22.png",23,22],"28x25":["user-more-26x25.png",26,25]},"MORG":{"38x24":["user-morg-36x24.png",36,24],"34x24":["user-morg-34x23.png",34,23],"26x23":["user-morg-26x18.png",26,18],"31x24":["user-morg-31x21.png",31,21],"29x22":["user-morg-29x20.png",29,20],"25x19":["user-morg-25x17.png",25,17],"22x20":["user-morg-22x15.png",22,15],"24x25":["user-morg-24x16.png",24,16],"30x19":["user-morg-28x19.png",28,19],"25x22":["user-morg-25x17.png",25,17],"28x25":["user-morg-28x19.png",28,19]},"MSM":{"38x24":["user-msm-38x20.png",38,20],"34x24":["user-msm-34x18.png",34,18],"26x23":["user-msm-26x14.png",26,14],"31x24":["user-msm-31x17.png",31,17],"29x22":["user-msm-29x16.png",29,16],"25x19":["user-msm-25x13.png",25,13],"22x20":["user-msm-22x12.png",22,12],"24x25":["user-msm-24x13.png",24,13],"30x19":["user-msm-30x16.png",30,16],"25x22":["user-msm-25x13.png",25,13],"28x25":["user-msm-28x15.png",28,15]},"LBSU":{"38x24":["user-lbsu-20x24.png",20,24],"34x24":["user-lbsu-20x24.png",20,24],"26x23":["user-lbsu-19x23.png",19,23],"31x24":["user-lbsu-20x24.png",20,24],"29x22":["user-lbsu-18x22.png",18,22],"25x19":["user-lbsu-15x19.png",15,19],"22x20":["user-lbsu-16x20.png",16,20],"24x25":["user-lbsu-20x25.png",20,25],"30x19":["user-lbsu-15x19.png",15,19],"25x22":["user-lbsu-18x22.png",18,22],"28x25":["user-lbsu-20x25.png",20,25]}})
TEAM_LOGO_BOUNDS.update({"GB":[26,23,0,1,26,21],"HAMP":[26,23,2,0,23,23],"HARV":[26,23,3,0,22,23],"HAW":[26,23,0,1,26,21],"HPU":[26,23,0,4,26,19],"HOF":[26,23,0,3,26,19],"HC":[26,23,3,0,23,23],"HOU":[26,23,1,0,25,23],"HCU":[26,23,2,0,24,23],"HOW":[26,23,4,0,22,23],"IDHO":[26,23,2,0,23,23],"IDST":[26,23,1,0,25,23],"ILL":[26,23,5,0,21,23],"ILST":[26,23,0,3,26,19],"UIW":[26,23,0,4,26,19],"IND":[26,23,4,0,22,23],"INST":[26,23,0,0,26,23],"IONA":[26,23,0,1,26,21],"ISU":[26,23,0,2,26,20],"IOWA":[26,23,0,3,26,20],"IUIN":[26,23,1,0,25,23],"JKST":[26,23,0,3,26,19],"JAX":[26,23,0,3,26,19],"JXST":[26,23,0,3,26,19],"JMU":[26,23,4,0,21,23],"KU":[26,23,0,0,26,23],"KC":[26,23,1,0,25,23],"KSU":[26,23,0,2,26,21],"KENN":[26,23,1,0,25,23],"KENT":[26,23,0,2,26,20],"LAS":[26,23,1,0,25,23],"LAF":[26,23,0,4,26,19],"LAM":[26,23,0,4,26,19],"LEM":[26,23,0,4,26,18],"LEH":[26,23,1,0,25,23],"LIB":[26,23,0,0,26,23],"LIN":[26,23,0,2,26,21],"LIP":[26,23,4,0,22,23],"LR":[26,23,0,4,26,18],"LIU":[26,23,0,0,26,23],"LONG":[26,23,0,6,26,16],"UL":[26,23,0,5,26,18],"LT":[26,23,0,4,26,19],"LOU":[26,23,2,0,23,23],"LUC":[26,23,0,1,26,22],"LMD":[26,23,2,0,23,23],"LMU":[26,23,0,5,26,17],"LSU":[26,23,0,7,26,16],"ME":[26,23,0,1,26,21],"MAN":[26,23,0,0,26,22],"MRST":[26,23,0,5,26,18],"MARQ":[26,23,0,2,26,21],"MRSH":[26,23,0,3,26,20],"MD":[26,23,2,0,23,23],"UMES":[26,23,2,6,24,17],"MASS":[26,23,0,1,26,22],"MEM":[26,23,0,0,26,23],"MER":[26,23,0,1,26,21],"MERC":[26,23,0,1,26,21],"MIA":[26,23,0,3,26,19],"MOH":[26,23,0,1,26,21],"MICH":[26,23,0,2,26,21],"MTSU":[26,23,0,3,26,20],"MSU":[26,23,3,0,23,23],"MILW":[26,23,1,0,25,23],"MINN":[26,23,0,4,26,19],"MSST":[26,23,0,3,26,19],"MVSU":[26,23,0,2,26,21],"MIZ":[26,23,0,4,26,19],"MOST":[26,23,0,0,26,23],"MONM":[26,23,0,1,26,21],"MONT":[26,23,0,2,26,21],"MTST":[26,23,0,1,26,21],"MORE":[26,23,1,0,25,23],"MORG":[26,23,0,2,26,20],"MSM":[26,23,0,4,26,18],"LBSU":[26,23,3,0,22,23]})

USER_LOGO_FRAMES.update({"MUR":{"38x24":["user-mur-23x24.png",23,24],"34x24":["user-mur-23x24.png",23,24],"26x23":["user-mur-22x23.png",22,23],"31x24":["user-mur-23x24.png",23,24],"29x22":["user-mur-21x22.png",21,22],"25x19":["user-mur-18x19.png",18,19],"22x20":["user-mur-19x20.png",19,20],"24x25":["user-mur-24x25.png",24,25],"30x19":["user-mur-18x19.png",18,19],"25x22":["user-mur-21x22.png",21,22],"28x25":["user-mur-24x25.png",24,25]},"NAVY":{"38x24":["user-navy-19x24.png",19,24],"34x24":["user-navy-19x24.png",19,24],"26x23":["user-navy-19x23.png",19,23],"31x24":["user-navy-19x24.png",19,24],"29x22":["user-navy-18x22.png",18,22],"25x19":["user-navy-15x19.png",15,19],"22x20":["user-navy-16x20.png",16,20],"24x25":["user-navy-20x25.png",20,25],"30x19":["user-navy-15x19.png",15,19],"25x22":["user-navy-18x22.png",18,22],"28x25":["user-navy-20x25.png",20,25]},"NEB":{"38x24":["user-neb-24x24.png",24,24],"34x24":["user-neb-24x24.png",24,24],"26x23":["user-neb-23x23.png",23,23],"31x24":["user-neb-24x24.png",24,24],"29x22":["user-neb-22x22.png",22,22],"25x19":["user-neb-19x19.png",19,19],"22x20":["user-neb-20x20.png",20,20],"24x25":["user-neb-24x24.png",24,24],"30x19":["user-neb-19x19.png",19,19],"25x22":["user-neb-22x22.png",22,22],"28x25":["user-neb-25x25.png",25,25]},"NEV":{"38x24":["user-nev-37x24.png",37,24],"34x24":["user-nev-34x22.png",34,22],"26x23":["user-nev-26x17.png",26,17],"31x24":["user-nev-31x20.png",31,20],"29x22":["user-nev-29x19.png",29,19],"25x19":["user-nev-25x16.png",25,16],"22x20":["user-nev-22x14.png",22,14],"24x25":["user-nev-24x15.png",24,15],"30x19":["user-nev-30x19.png",30,19],"25x22":["user-nev-25x16.png",25,16],"28x25":["user-nev-28x18.png",28,18]},"UNH":{"38x24":["user-unh-28x24.png",28,24],"34x24":["user-unh-28x24.png",28,24],"26x23":["user-unh-26x22.png",26,22],"31x24":["user-unh-28x24.png",28,24],"29x22":["user-unh-26x22.png",26,22],"25x19":["user-unh-22x19.png",22,19],"22x20":["user-unh-22x19.png",22,19],"24x25":["user-unh-24x20.png",24,20],"30x19":["user-unh-22x19.png",22,19],"25x22":["user-unh-25x21.png",25,21],"28x25":["user-unh-28x24.png",28,24]},"UNM":{"38x24":["user-unm-19x24.png",19,24],"34x24":["user-unm-19x24.png",19,24],"26x23":["user-unm-19x23.png",19,23],"31x24":["user-unm-19x24.png",19,24],"29x22":["user-unm-18x22.png",18,22],"25x19":["user-unm-15x19.png",15,19],"22x20":["user-unm-16x20.png",16,20],"24x25":["user-unm-20x25.png",20,25],"30x19":["user-unm-15x19.png",15,19],"25x22":["user-unm-18x22.png",18,22],"28x25":["user-unm-20x25.png",20,25]},"NMSU":{"38x24":["user-nmsu-33x24.png",33,24],"34x24":["user-nmsu-33x24.png",33,24],"26x23":["user-nmsu-26x19.png",26,19],"31x24":["user-nmsu-31x23.png",31,23],"29x22":["user-nmsu-29x21.png",29,21],"25x19":["user-nmsu-25x18.png",25,18],"22x20":["user-nmsu-22x16.png",22,16],"24x25":["user-nmsu-24x18.png",24,18],"30x19":["user-nmsu-26x19.png",26,19],"25x22":["user-nmsu-25x18.png",25,18],"28x25":["user-nmsu-28x21.png",28,21]},"NOLA":{"38x24":["user-nola-28x24.png",28,24],"34x24":["user-nola-28x24.png",28,24],"26x23":["user-nola-26x23.png",26,23],"31x24":["user-nola-28x24.png",28,24],"29x22":["user-nola-25x22.png",25,22],"25x19":["user-nola-22x19.png",22,19],"22x20":["user-nola-22x19.png",22,19],"24x25":["user-nola-24x21.png",24,21],"30x19":["user-nola-22x19.png",22,19],"25x22":["user-nola-25x22.png",25,22],"28x25":["user-nola-28x24.png",28,24]},"NIA":{"38x24":["user-nia-38x16.png",38,16],"34x24":["user-nia-34x14.png",34,14],"26x23":["user-nia-26x11.png",26,11],"31x24":["user-nia-31x13.png",31,13],"29x22":["user-nia-29x12.png",29,12],"25x19":["user-nia-25x10.png",25,10],"22x20":["user-nia-22x9.png",22,9],"24x25":["user-nia-24x10.png",24,10],"30x19":["user-nia-30x12.png",30,12],"25x22":["user-nia-25x10.png",25,10],"28x25":["user-nia-28x12.png",28,12]},"NICH":{"38x24":["user-nich-38x19.png",38,19],"34x24":["user-nich-34x17.png",34,17],"26x23":["user-nich-26x13.png",26,13],"31x24":["user-nich-31x15.png",31,15],"29x22":["user-nich-29x14.png",29,14],"25x19":["user-nich-25x12.png",25,12],"22x20":["user-nich-22x11.png",22,11],"24x25":["user-nich-24x12.png",24,12],"30x19":["user-nich-30x15.png",30,15],"25x22":["user-nich-25x12.png",25,12],"28x25":["user-nich-28x14.png",28,14]},"NJIT":{"38x24":["user-njit-27x24.png",27,24],"34x24":["user-njit-27x24.png",27,24],"26x23":["user-njit-26x23.png",26,23],"31x24":["user-njit-27x24.png",27,24],"29x22":["user-njit-25x22.png",25,22],"25x19":["user-njit-22x19.png",22,19],"22x20":["user-njit-22x19.png",22,19],"24x25":["user-njit-24x21.png",24,21],"30x19":["user-njit-22x19.png",22,19],"25x22":["user-njit-25x22.png",25,22],"28x25":["user-njit-28x25.png",28,25]},"NORF":{"38x24":["user-norf-24x24.png",24,24],"34x24":["user-norf-24x24.png",24,24],"26x23":["user-norf-23x23.png",23,23],"31x24":["user-norf-24x24.png",24,24],"29x22":["user-norf-22x22.png",22,22],"25x19":["user-norf-19x19.png",19,19],"22x20":["user-norf-20x20.png",20,20],"24x25":["user-norf-24x24.png",24,24],"30x19":["user-norf-19x19.png",19,19],"25x22":["user-norf-22x22.png",22,22],"28x25":["user-norf-25x25.png",25,25]},"UNA":{"38x24":["user-una-33x24.png",33,24],"34x24":["user-una-33x24.png",33,24],"26x23":["user-una-26x19.png",26,19],"31x24":["user-una-31x22.png",31,22],"29x22":["user-una-29x21.png",29,21],"25x19":["user-una-25x18.png",25,18],"22x20":["user-una-22x16.png",22,16],"24x25":["user-una-24x17.png",24,17],"30x19":["user-una-26x19.png",26,19],"25x22":["user-una-25x18.png",25,18],"28x25":["user-una-28x20.png",28,20]},"UNC":{"38x24":["user-unc-31x24.png",31,24],"34x24":["user-unc-31x24.png",31,24],"26x23":["user-unc-26x20.png",26,20],"31x24":["user-unc-31x24.png",31,24],"29x22":["user-unc-28x22.png",28,22],"25x19":["user-unc-24x19.png",24,19],"22x20":["user-unc-22x17.png",22,17],"24x25":["user-unc-24x19.png",24,19],"30x19":["user-unc-24x19.png",24,19],"25x22":["user-unc-25x20.png",25,20],"28x25":["user-unc-28x22.png",28,22]},"NCAT":{"38x24":["user-ncat-20x24.png",20,24],"34x24":["user-ncat-20x24.png",20,24],"26x23":["user-ncat-19x23.png",19,23],"31x24":["user-ncat-20x24.png",20,24],"29x22":["user-ncat-18x22.png",18,22],"25x19":["user-ncat-16x19.png",16,19],"22x20":["user-ncat-16x20.png",16,20],"24x25":["user-ncat-21x25.png",21,25],"30x19":["user-ncat-16x19.png",16,19],"25x22":["user-ncat-18x22.png",18,22],"28x25":["user-ncat-21x25.png",21,25]},"NCCU":{"38x24":["user-nccu-38x18.png",38,18],"34x24":["user-nccu-34x16.png",34,16],"26x23":["user-nccu-26x13.png",26,13],"31x24":["user-nccu-31x15.png",31,15],"29x22":["user-nccu-29x14.png",29,14],"25x19":["user-nccu-25x12.png",25,12],"22x20":["user-nccu-22x11.png",22,11],"24x25":["user-nccu-24x12.png",24,12],"30x19":["user-nccu-30x15.png",30,15],"25x22":["user-nccu-25x12.png",25,12],"28x25":["user-nccu-28x14.png",28,14]},"NCST":{"38x24":["user-ncst-17x24.png",17,24],"34x24":["user-ncst-17x24.png",17,24],"26x23":["user-ncst-17x23.png",17,23],"31x24":["user-ncst-17x24.png",17,24],"29x22":["user-ncst-16x22.png",16,22],"25x19":["user-ncst-14x19.png",14,19],"22x20":["user-ncst-14x20.png",14,20],"24x25":["user-ncst-18x25.png",18,25],"30x19":["user-ncst-14x19.png",14,19],"25x22":["user-ncst-16x22.png",16,22],"28x25":["user-ncst-18x25.png",18,25]},"UND":{"38x24":["user-und-38x17.png",38,17],"34x24":["user-und-34x15.png",34,15],"26x23":["user-und-26x12.png",26,12],"31x24":["user-und-31x14.png",31,14],"29x22":["user-und-29x13.png",29,13],"25x19":["user-und-25x11.png",25,11],"22x20":["user-und-22x10.png",22,10],"24x25":["user-und-24x11.png",24,11],"30x19":["user-und-30x13.png",30,13],"25x22":["user-und-25x11.png",25,11],"28x25":["user-und-28x13.png",28,13]},"UNF":{"38x24":["user-unf-38x24.png",38,24],"34x24":["user-unf-34x21.png",34,21],"26x23":["user-unf-26x16.png",26,16],"31x24":["user-unf-31x19.png",31,19],"29x22":["user-unf-29x18.png",29,18],"25x19":["user-unf-25x16.png",25,16],"22x20":["user-unf-22x14.png",22,14],"24x25":["user-unf-24x15.png",24,15],"30x19":["user-unf-30x19.png",30,19],"25x22":["user-unf-25x16.png",25,16],"28x25":["user-unf-28x17.png",28,17]},"UNT":{"38x24":["user-unt-21x24.png",21,24],"34x24":["user-unt-21x24.png",21,24],"26x23":["user-unt-21x23.png",21,23],"31x24":["user-unt-21x24.png",21,24],"29x22":["user-unt-20x22.png",20,22],"25x19":["user-unt-17x19.png",17,19],"22x20":["user-unt-18x20.png",18,20],"24x25":["user-unt-22x25.png",22,25],"30x19":["user-unt-17x19.png",17,19],"25x22":["user-unt-20x22.png",20,22],"28x25":["user-unt-22x25.png",22,25]},"NE":{"38x24":["user-ne-24x24.png",24,24],"34x24":["user-ne-24x24.png",24,24],"26x23":["user-ne-23x23.png",23,23],"31x24":["user-ne-24x24.png",24,24],"29x22":["user-ne-22x22.png",22,22],"25x19":["user-ne-19x19.png",19,19],"22x20":["user-ne-20x20.png",20,20],"24x25":["user-ne-24x24.png",24,24],"30x19":["user-ne-19x19.png",19,19],"25x22":["user-ne-22x22.png",22,22],"28x25":["user-ne-25x25.png",25,25]},"NAU":{"38x24":["user-nau-38x23.png",38,23],"34x24":["user-nau-34x21.png",34,21],"26x23":["user-nau-26x16.png",26,16],"31x24":["user-nau-31x19.png",31,19],"29x22":["user-nau-29x18.png",29,18],"25x19":["user-nau-25x15.png",25,15],"22x20":["user-nau-22x13.png",22,13],"24x25":["user-nau-24x15.png",24,15],"30x19":["user-nau-30x18.png",30,18],"25x22":["user-nau-25x15.png",25,15],"28x25":["user-nau-28x17.png",28,17]},"UNCO":{"38x24":["user-unco-24x24.png",24,24],"34x24":["user-unco-24x24.png",24,24],"26x23":["user-unco-23x23.png",23,23],"31x24":["user-unco-24x24.png",24,24],"29x22":["user-unco-22x22.png",22,22],"25x19":["user-unco-19x19.png",19,19],"22x20":["user-unco-20x20.png",20,20],"24x25":["user-unco-24x24.png",24,24],"30x19":["user-unco-19x19.png",19,19],"25x22":["user-unco-22x22.png",22,22],"28x25":["user-unco-25x25.png",25,25]},"NIU":{"38x24":["user-niu-25x24.png",25,24],"34x24":["user-niu-25x24.png",25,24],"26x23":["user-niu-24x23.png",24,23],"31x24":["user-niu-25x24.png",25,24],"29x22":["user-niu-23x22.png",23,22],"25x19":["user-niu-20x19.png",20,19],"22x20":["user-niu-21x20.png",21,20],"24x25":["user-niu-24x23.png",24,23],"30x19":["user-niu-20x19.png",20,19],"25x22":["user-niu-23x22.png",23,22],"28x25":["user-niu-26x25.png",26,25]},"UNI":{"38x24":["user-uni-35x24.png",35,24],"34x24":["user-uni-34x23.png",34,23],"26x23":["user-uni-26x18.png",26,18],"31x24":["user-uni-31x21.png",31,21],"29x22":["user-uni-29x20.png",29,20],"25x19":["user-uni-25x17.png",25,17],"22x20":["user-uni-22x15.png",22,15],"24x25":["user-uni-24x17.png",24,17],"30x19":["user-uni-28x19.png",28,19],"25x22":["user-uni-25x17.png",25,17],"28x25":["user-uni-28x19.png",28,19]},"NKU":{"38x24":["user-nku-38x23.png",38,23],"34x24":["user-nku-34x21.png",34,21],"26x23":["user-nku-26x16.png",26,16],"31x24":["user-nku-31x19.png",31,19],"29x22":["user-nku-29x18.png",29,18],"25x19":["user-nku-25x15.png",25,15],"22x20":["user-nku-22x13.png",22,13],"24x25":["user-nku-24x15.png",24,15],"30x19":["user-nku-30x18.png",30,18],"25x22":["user-nku-25x15.png",25,15],"28x25":["user-nku-28x17.png",28,17]},"NU":{"38x24":["user-nu-16x24.png",16,24],"34x24":["user-nu-16x24.png",16,24],"26x23":["user-nu-15x23.png",15,23],"31x24":["user-nu-16x24.png",16,24],"29x22":["user-nu-14x22.png",14,22],"25x19":["user-nu-12x19.png",12,19],"22x20":["user-nu-13x20.png",13,20],"24x25":["user-nu-16x25.png",16,25],"30x19":["user-nu-12x19.png",12,19],"25x22":["user-nu-14x22.png",14,22],"28x25":["user-nu-16x25.png",16,25]},"NWST":{"38x24":["user-nwst-31x24.png",31,24],"34x24":["user-nwst-31x24.png",31,24],"26x23":["user-nwst-26x20.png",26,20],"31x24":["user-nwst-31x24.png",31,24],"29x22":["user-nwst-29x22.png",29,22],"25x19":["user-nwst-25x19.png",25,19],"22x20":["user-nwst-22x17.png",22,17],"24x25":["user-nwst-24x19.png",24,19],"30x19":["user-nwst-25x19.png",25,19],"25x22":["user-nwst-25x19.png",25,19],"28x25":["user-nwst-28x22.png",28,22]},"ND":{"38x24":["user-nd-27x24.png",27,24],"34x24":["user-nd-27x24.png",27,24],"26x23":["user-nd-25x23.png",25,23],"31x24":["user-nd-27x24.png",27,24],"29x22":["user-nd-24x22.png",24,22],"25x19":["user-nd-21x19.png",21,19],"22x20":["user-nd-22x20.png",22,20],"24x25":["user-nd-24x22.png",24,22],"30x19":["user-nd-21x19.png",21,19],"25x22":["user-nd-24x22.png",24,22],"28x25":["user-nd-28x25.png",28,25]},"OAK":{"38x24":["user-oak-29x24.png",29,24],"34x24":["user-oak-29x24.png",29,24],"26x23":["user-oak-26x22.png",26,22],"31x24":["user-oak-29x24.png",29,24],"29x22":["user-oak-26x22.png",26,22],"25x19":["user-oak-23x19.png",23,19],"22x20":["user-oak-22x19.png",22,19],"24x25":["user-oak-24x20.png",24,20],"30x19":["user-oak-23x19.png",23,19],"25x22":["user-oak-25x21.png",25,21],"28x25":["user-oak-28x24.png",28,24]},"OHIO":{"38x24":["user-ohio-28x24.png",28,24],"34x24":["user-ohio-28x24.png",28,24],"26x23":["user-ohio-26x22.png",26,22],"31x24":["user-ohio-28x24.png",28,24],"29x22":["user-ohio-26x22.png",26,22],"25x19":["user-ohio-22x19.png",22,19],"22x20":["user-ohio-22x19.png",22,19],"24x25":["user-ohio-24x21.png",24,21],"30x19":["user-ohio-22x19.png",22,19],"25x22":["user-ohio-25x21.png",25,21],"28x25":["user-ohio-28x24.png",28,24]},"OU":{"38x24":["user-ou-19x24.png",19,24],"34x24":["user-ou-19x24.png",19,24],"26x23":["user-ou-18x23.png",18,23],"31x24":["user-ou-19x24.png",19,24],"29x22":["user-ou-17x22.png",17,22],"25x19":["user-ou-15x19.png",15,19],"22x20":["user-ou-16x20.png",16,20],"24x25":["user-ou-19x25.png",19,25],"30x19":["user-ou-15x19.png",15,19],"25x22":["user-ou-17x22.png",17,22],"28x25":["user-ou-19x25.png",19,25]},"OKST":{"38x24":["user-okst-38x20.png",38,20],"34x24":["user-okst-34x18.png",34,18],"26x23":["user-okst-26x13.png",26,13],"31x24":["user-okst-31x16.png",31,16],"29x22":["user-okst-29x15.png",29,15],"25x19":["user-okst-25x13.png",25,13],"22x20":["user-okst-22x11.png",22,11],"24x25":["user-okst-24x12.png",24,12],"30x19":["user-okst-30x16.png",30,16],"25x22":["user-okst-25x13.png",25,13],"28x25":["user-okst-28x15.png",28,15]},"ODU":{"38x24":["user-odu-28x24.png",28,24],"34x24":["user-odu-28x24.png",28,24],"26x23":["user-odu-26x22.png",26,22],"31x24":["user-odu-28x24.png",28,24],"29x22":["user-odu-26x22.png",26,22],"25x19":["user-odu-22x19.png",22,19],"22x20":["user-odu-22x19.png",22,19],"24x25":["user-odu-24x20.png",24,20],"30x19":["user-odu-22x19.png",22,19],"25x22":["user-odu-25x21.png",25,21],"28x25":["user-odu-28x24.png",28,24]},"MISS":{"38x24":["user-miss-26x24.png",26,24],"34x24":["user-miss-26x24.png",26,24],"26x23":["user-miss-25x23.png",25,23],"31x24":["user-miss-26x24.png",26,24],"29x22":["user-miss-24x22.png",24,22],"25x19":["user-miss-21x19.png",21,19],"22x20":["user-miss-22x20.png",22,20],"24x25":["user-miss-24x22.png",24,22],"30x19":["user-miss-21x19.png",21,19],"25x22":["user-miss-24x22.png",24,22],"28x25":["user-miss-27x25.png",27,25]},"OMA":{"38x24":["user-oma-25x24.png",25,24],"34x24":["user-oma-25x24.png",25,24],"26x23":["user-oma-24x23.png",24,23],"31x24":["user-oma-25x24.png",25,24],"29x22":["user-oma-23x22.png",23,22],"25x19":["user-oma-19x19.png",19,19],"22x20":["user-oma-21x20.png",21,20],"24x25":["user-oma-24x23.png",24,23],"30x19":["user-oma-19x19.png",19,19],"25x22":["user-oma-23x22.png",23,22],"28x25":["user-oma-26x25.png",26,25]},"ORU":{"38x24":["user-oru-35x24.png",35,24],"34x24":["user-oru-34x23.png",34,23],"26x23":["user-oru-26x18.png",26,18],"31x24":["user-oru-31x21.png",31,21],"29x22":["user-oru-29x20.png",29,20],"25x19":["user-oru-25x17.png",25,17],"22x20":["user-oru-22x15.png",22,15],"24x25":["user-oru-24x16.png",24,16],"30x19":["user-oru-28x19.png",28,19],"25x22":["user-oru-25x17.png",25,17],"28x25":["user-oru-28x19.png",28,19]},"ORE":{"38x24":["user-ore-29x24.png",29,24],"34x24":["user-ore-29x24.png",29,24],"26x23":["user-ore-26x21.png",26,21],"31x24":["user-ore-29x24.png",29,24],"29x22":["user-ore-27x22.png",27,22],"25x19":["user-ore-23x19.png",23,19],"22x20":["user-ore-22x18.png",22,18],"24x25":["user-ore-24x20.png",24,20],"30x19":["user-ore-23x19.png",23,19],"25x22":["user-ore-25x21.png",25,21],"28x25":["user-ore-28x23.png",28,23]},"ORST":{"38x24":["user-orst-38x22.png",38,22],"34x24":["user-orst-34x19.png",34,19],"26x23":["user-orst-26x15.png",26,15],"31x24":["user-orst-31x18.png",31,18],"29x22":["user-orst-29x16.png",29,16],"25x19":["user-orst-25x14.png",25,14],"22x20":["user-orst-22x13.png",22,13],"24x25":["user-orst-24x14.png",24,14],"30x19":["user-orst-30x17.png",30,17],"25x22":["user-orst-25x14.png",25,14],"28x25":["user-orst-28x16.png",28,16]},"PAC":{"38x24":["user-pac-34x24.png",34,24],"34x24":["user-pac-34x24.png",34,24],"26x23":["user-pac-26x18.png",26,18],"31x24":["user-pac-31x22.png",31,22],"29x22":["user-pac-29x21.png",29,21],"25x19":["user-pac-25x18.png",25,18],"22x20":["user-pac-22x16.png",22,16],"24x25":["user-pac-24x17.png",24,17],"30x19":["user-pac-27x19.png",27,19],"25x22":["user-pac-25x18.png",25,18],"28x25":["user-pac-28x20.png",28,20]},"PSU":{"38x24":["user-psu-35x24.png",35,24],"34x24":["user-psu-34x24.png",34,24],"26x23":["user-psu-26x18.png",26,18],"31x24":["user-psu-31x22.png",31,22],"29x22":["user-psu-29x20.png",29,20],"25x19":["user-psu-25x17.png",25,17],"22x20":["user-psu-22x15.png",22,15],"24x25":["user-psu-24x17.png",24,17],"30x19":["user-psu-27x19.png",27,19],"25x22":["user-psu-25x17.png",25,17],"28x25":["user-psu-28x19.png",28,19]},"PEPP":{"38x24":["user-pepp-23x24.png",23,24],"34x24":["user-pepp-23x24.png",23,24],"26x23":["user-pepp-22x23.png",22,23],"31x24":["user-pepp-23x24.png",23,24],"29x22":["user-pepp-21x22.png",21,22],"25x19":["user-pepp-18x19.png",18,19],"22x20":["user-pepp-19x20.png",19,20],"24x25":["user-pepp-23x25.png",23,25],"30x19":["user-pepp-18x19.png",18,19],"25x22":["user-pepp-21x22.png",21,22],"28x25":["user-pepp-23x25.png",23,25]},"PITT":{"38x24":["user-pitt-38x22.png",38,22],"34x24":["user-pitt-34x19.png",34,19],"26x23":["user-pitt-26x15.png",26,15],"31x24":["user-pitt-31x18.png",31,18],"29x22":["user-pitt-29x16.png",29,16],"25x19":["user-pitt-25x14.png",25,14],"22x20":["user-pitt-22x12.png",22,12],"24x25":["user-pitt-24x14.png",24,14],"30x19":["user-pitt-30x17.png",30,17],"25x22":["user-pitt-25x14.png",25,14],"28x25":["user-pitt-28x16.png",28,16]},"PORT":{"38x24":["user-port-21x24.png",21,24],"34x24":["user-port-21x24.png",21,24],"26x23":["user-port-20x23.png",20,23],"31x24":["user-port-21x24.png",21,24],"29x22":["user-port-20x22.png",20,22],"25x19":["user-port-17x19.png",17,19],"22x20":["user-port-18x20.png",18,20],"24x25":["user-port-22x25.png",22,25],"30x19":["user-port-17x19.png",17,19],"25x22":["user-port-20x22.png",20,22],"28x25":["user-port-22x25.png",22,25]},"PRST":{"38x24":["user-prst-19x24.png",19,24],"34x24":["user-prst-19x24.png",19,24],"26x23":["user-prst-18x23.png",18,23],"31x24":["user-prst-19x24.png",19,24],"29x22":["user-prst-17x22.png",17,22],"25x19":["user-prst-15x19.png",15,19],"22x20":["user-prst-15x20.png",15,20],"24x25":["user-prst-19x25.png",19,25],"30x19":["user-prst-15x19.png",15,19],"25x22":["user-prst-17x22.png",17,22],"28x25":["user-prst-19x25.png",19,25]},"PV":{"38x24":["user-pv-38x23.png",38,23],"34x24":["user-pv-34x21.png",34,21],"26x23":["user-pv-26x16.png",26,16],"31x24":["user-pv-31x19.png",31,19],"29x22":["user-pv-29x18.png",29,18],"25x19":["user-pv-25x15.png",25,15],"22x20":["user-pv-22x13.png",22,13],"24x25":["user-pv-24x15.png",24,15],"30x19":["user-pv-30x18.png",30,18],"25x22":["user-pv-25x15.png",25,15],"28x25":["user-pv-28x17.png",28,17]},"PRES":{"38x24":["user-pres-24x24.png",24,24],"34x24":["user-pres-24x24.png",24,24],"26x23":["user-pres-23x23.png",23,23],"31x24":["user-pres-24x24.png",24,24],"29x22":["user-pres-22x22.png",22,22],"25x19":["user-pres-19x19.png",19,19],"22x20":["user-pres-20x20.png",20,20],"24x25":["user-pres-24x24.png",24,24],"30x19":["user-pres-19x19.png",19,19],"25x22":["user-pres-22x22.png",22,22],"28x25":["user-pres-25x25.png",25,25]},"PRIN":{"38x24":["user-prin-21x24.png",21,24],"34x24":["user-prin-21x24.png",21,24],"26x23":["user-prin-20x23.png",20,23],"31x24":["user-prin-21x24.png",21,24],"29x22":["user-prin-19x22.png",19,22],"25x19":["user-prin-17x19.png",17,19],"22x20":["user-prin-17x20.png",17,20],"24x25":["user-prin-22x25.png",22,25],"30x19":["user-prin-17x19.png",17,19],"25x22":["user-prin-19x22.png",19,22],"28x25":["user-prin-22x25.png",22,25]},"PROV":{"38x24":["user-prov-36x24.png",36,24],"34x24":["user-prov-34x23.png",34,23],"26x23":["user-prov-26x17.png",26,17],"31x24":["user-prov-31x21.png",31,21],"29x22":["user-prov-29x19.png",29,19],"25x19":["user-prov-25x17.png",25,17],"22x20":["user-prov-22x15.png",22,15],"24x25":["user-prov-24x16.png",24,16],"30x19":["user-prov-29x19.png",29,19],"25x22":["user-prov-25x17.png",25,17],"28x25":["user-prov-28x19.png",28,19]},"PUR":{"38x24":["user-pur-38x20.png",38,20],"34x24":["user-pur-34x18.png",34,18],"26x23":["user-pur-26x14.png",26,14],"31x24":["user-pur-31x17.png",31,17],"29x22":["user-pur-29x16.png",29,16],"25x19":["user-pur-25x13.png",25,13],"22x20":["user-pur-22x12.png",22,12],"24x25":["user-pur-24x13.png",24,13],"30x19":["user-pur-30x16.png",30,16],"25x22":["user-pur-25x13.png",25,13],"28x25":["user-pur-28x15.png",28,15]},"PFW":{"38x24":["user-pfw-26x24.png",26,24],"34x24":["user-pfw-26x24.png",26,24],"26x23":["user-pfw-25x23.png",25,23],"31x24":["user-pfw-26x24.png",26,24],"29x22":["user-pfw-24x22.png",24,22],"25x19":["user-pfw-21x19.png",21,19],"22x20":["user-pfw-22x20.png",22,20],"24x25":["user-pfw-24x22.png",24,22],"30x19":["user-pfw-21x19.png",21,19],"25x22":["user-pfw-24x22.png",24,22],"28x25":["user-pfw-27x25.png",27,25]},"QUIN":{"38x24":["user-quin-23x24.png",23,24],"34x24":["user-quin-23x24.png",23,24],"26x23":["user-quin-22x23.png",22,23],"31x24":["user-quin-23x24.png",23,24],"29x22":["user-quin-21x22.png",21,22],"25x19":["user-quin-18x19.png",18,19],"22x20":["user-quin-19x20.png",19,20],"24x25":["user-quin-24x25.png",24,25],"30x19":["user-quin-18x19.png",18,19],"25x22":["user-quin-21x22.png",21,22],"28x25":["user-quin-24x25.png",24,25]},"QUC":{"38x24":["user-quc-19x24.png",19,24],"34x24":["user-quc-19x24.png",19,24],"26x23":["user-quc-18x23.png",18,23],"31x24":["user-quc-19x24.png",19,24],"29x22":["user-quc-17x22.png",17,22],"25x19":["user-quc-15x19.png",15,19],"22x20":["user-quc-16x20.png",16,20],"24x25":["user-quc-20x25.png",20,25],"30x19":["user-quc-15x19.png",15,19],"25x22":["user-quc-17x22.png",17,22],"28x25":["user-quc-20x25.png",20,25]},"RAD":{"38x24":["user-rad-28x24.png",28,24],"34x24":["user-rad-28x24.png",28,24],"26x23":["user-rad-26x22.png",26,22],"31x24":["user-rad-28x24.png",28,24],"29x22":["user-rad-26x22.png",26,22],"25x19":["user-rad-22x19.png",22,19],"22x20":["user-rad-22x19.png",22,19],"24x25":["user-rad-24x20.png",24,20],"30x19":["user-rad-22x19.png",22,19],"25x22":["user-rad-25x21.png",25,21],"28x25":["user-rad-28x24.png",28,24]},"URI":{"38x24":["user-uri-19x24.png",19,24],"34x24":["user-uri-19x24.png",19,24],"26x23":["user-uri-18x23.png",18,23],"31x24":["user-uri-19x24.png",19,24],"29x22":["user-uri-17x22.png",17,22],"25x19":["user-uri-15x19.png",15,19],"22x20":["user-uri-16x20.png",16,20],"24x25":["user-uri-19x25.png",19,25],"30x19":["user-uri-15x19.png",15,19],"25x22":["user-uri-17x22.png",17,22],"28x25":["user-uri-19x25.png",19,25]},"RICE":{"38x24":["user-rice-20x24.png",20,24],"34x24":["user-rice-20x24.png",20,24],"26x23":["user-rice-19x23.png",19,23],"31x24":["user-rice-20x24.png",20,24],"29x22":["user-rice-18x22.png",18,22],"25x19":["user-rice-16x19.png",16,19],"22x20":["user-rice-16x20.png",16,20],"24x25":["user-rice-21x25.png",21,25],"30x19":["user-rice-16x19.png",16,19],"25x22":["user-rice-18x22.png",18,22],"28x25":["user-rice-21x25.png",21,25]},"RICH":{"38x24":["user-rich-18x24.png",18,24],"34x24":["user-rich-18x24.png",18,24],"26x23":["user-rich-17x23.png",17,23],"31x24":["user-rich-18x24.png",18,24],"29x22":["user-rich-16x22.png",16,22],"25x19":["user-rich-14x19.png",14,19],"22x20":["user-rich-15x20.png",15,20],"24x25":["user-rich-18x25.png",18,25],"30x19":["user-rich-14x19.png",14,19],"25x22":["user-rich-16x22.png",16,22],"28x25":["user-rich-18x25.png",18,25]},"RID":{"38x24":["user-rid-38x23.png",38,23],"34x24":["user-rid-34x20.png",34,20],"26x23":["user-rid-26x16.png",26,16],"31x24":["user-rid-31x19.png",31,19],"29x22":["user-rid-29x17.png",29,17],"25x19":["user-rid-25x15.png",25,15],"22x20":["user-rid-22x13.png",22,13],"24x25":["user-rid-24x14.png",24,14],"30x19":["user-rid-30x18.png",30,18],"25x22":["user-rid-25x15.png",25,15],"28x25":["user-rid-28x17.png",28,17]},"RMU":{"38x24":["user-rmu-38x18.png",38,18],"34x24":["user-rmu-34x16.png",34,16],"26x23":["user-rmu-26x12.png",26,12],"31x24":["user-rmu-31x15.png",31,15],"29x22":["user-rmu-29x14.png",29,14],"25x19":["user-rmu-25x12.png",25,12],"22x20":["user-rmu-22x11.png",22,11],"24x25":["user-rmu-24x11.png",24,11],"30x19":["user-rmu-30x14.png",30,14],"25x22":["user-rmu-25x12.png",25,12],"28x25":["user-rmu-28x13.png",28,13]},"RUTG":{"38x24":["user-rutg-27x24.png",27,24],"34x24":["user-rutg-27x24.png",27,24],"26x23":["user-rutg-26x23.png",26,23],"31x24":["user-rutg-27x24.png",27,24],"29x22":["user-rutg-25x22.png",25,22],"25x19":["user-rutg-21x19.png",21,19],"22x20":["user-rutg-22x20.png",22,20],"24x25":["user-rutg-24x21.png",24,21],"30x19":["user-rutg-21x19.png",21,19],"25x22":["user-rutg-25x22.png",25,22],"28x25":["user-rutg-28x25.png",28,25]},"SAC":{"38x24":["user-sac-27x24.png",27,24],"34x24":["user-sac-27x24.png",27,24],"26x23":["user-sac-26x23.png",26,23],"31x24":["user-sac-27x24.png",27,24],"29x22":["user-sac-25x22.png",25,22],"25x19":["user-sac-21x19.png",21,19],"22x20":["user-sac-22x20.png",22,20],"24x25":["user-sac-24x21.png",24,21],"30x19":["user-sac-21x19.png",21,19],"25x22":["user-sac-25x22.png",25,22],"28x25":["user-sac-28x25.png",28,25]},"SHU":{"38x24":["user-shu-38x15.png",38,15],"34x24":["user-shu-34x14.png",34,14],"26x23":["user-shu-26x10.png",26,10],"31x24":["user-shu-31x12.png",31,12],"29x22":["user-shu-29x12.png",29,12],"25x19":["user-shu-25x10.png",25,10],"22x20":["user-shu-22x9.png",22,9],"24x25":["user-shu-24x10.png",24,10],"30x19":["user-shu-30x12.png",30,12],"25x22":["user-shu-25x10.png",25,10],"28x25":["user-shu-28x11.png",28,11]},"JOES":{"38x24":["user-joes-38x23.png",38,23],"34x24":["user-joes-34x21.png",34,21],"26x23":["user-joes-26x16.png",26,16],"31x24":["user-joes-31x19.png",31,19],"29x22":["user-joes-29x18.png",29,18],"25x19":["user-joes-25x15.png",25,15],"22x20":["user-joes-22x14.png",22,14],"24x25":["user-joes-24x15.png",24,15],"30x19":["user-joes-30x18.png",30,18],"25x22":["user-joes-25x15.png",25,15],"28x25":["user-joes-28x17.png",28,17]},"SLU":{"38x24":["user-slu-25x24.png",25,24],"34x24":["user-slu-25x24.png",25,24],"26x23":["user-slu-24x23.png",24,23],"31x24":["user-slu-25x24.png",25,24],"29x22":["user-slu-23x22.png",23,22],"25x19":["user-slu-20x19.png",20,19],"22x20":["user-slu-21x20.png",21,20],"24x25":["user-slu-24x23.png",24,23],"30x19":["user-slu-20x19.png",20,19],"25x22":["user-slu-23x22.png",23,22],"28x25":["user-slu-26x25.png",26,25]},"SPU":{"38x24":["user-spu-18x24.png",18,24],"34x24":["user-spu-18x24.png",18,24],"26x23":["user-spu-17x23.png",17,23],"31x24":["user-spu-18x24.png",18,24],"29x22":["user-spu-17x22.png",17,22],"25x19":["user-spu-14x19.png",14,19],"22x20":["user-spu-15x20.png",15,20],"24x25":["user-spu-19x25.png",19,25],"30x19":["user-spu-14x19.png",14,19],"25x22":["user-spu-17x22.png",17,22],"28x25":["user-spu-19x25.png",19,25]},"SHSU":{"38x24":["user-shsu-29x24.png",29,24],"34x24":["user-shsu-29x24.png",29,24],"26x23":["user-shsu-26x21.png",26,21],"31x24":["user-shsu-29x24.png",29,24],"29x22":["user-shsu-27x22.png",27,22],"25x19":["user-shsu-23x19.png",23,19],"22x20":["user-shsu-22x18.png",22,18],"24x25":["user-shsu-24x20.png",24,20],"30x19":["user-shsu-23x19.png",23,19],"25x22":["user-shsu-25x20.png",25,20],"28x25":["user-shsu-28x23.png",28,23]},"SAM":{"38x24":["user-sam-38x23.png",38,23],"34x24":["user-sam-34x21.png",34,21],"26x23":["user-sam-26x16.png",26,16],"31x24":["user-sam-31x19.png",31,19],"29x22":["user-sam-29x18.png",29,18],"25x19":["user-sam-25x15.png",25,15],"22x20":["user-sam-22x13.png",22,13],"24x25":["user-sam-24x15.png",24,15],"30x19":["user-sam-30x18.png",30,18],"25x22":["user-sam-25x15.png",25,15],"28x25":["user-sam-28x17.png",28,17]},"USD":{"38x24":["user-usd-25x24.png",25,24],"34x24":["user-usd-25x24.png",25,24],"26x23":["user-usd-24x23.png",24,23],"31x24":["user-usd-25x24.png",25,24],"29x22":["user-usd-23x22.png",23,22],"25x19":["user-usd-20x19.png",20,19],"22x20":["user-usd-21x20.png",21,20],"24x25":["user-usd-24x23.png",24,23],"30x19":["user-usd-20x19.png",20,19],"25x22":["user-usd-23x22.png",23,22],"28x25":["user-usd-26x25.png",26,25]},"SDSU":{"38x24":["user-sdsu-34x24.png",34,24],"34x24":["user-sdsu-34x24.png",34,24],"26x23":["user-sdsu-26x18.png",26,18],"31x24":["user-sdsu-31x22.png",31,22],"29x22":["user-sdsu-29x20.png",29,20],"25x19":["user-sdsu-25x17.png",25,17],"22x20":["user-sdsu-22x15.png",22,15],"24x25":["user-sdsu-24x17.png",24,17],"30x19":["user-sdsu-27x19.png",27,19],"25x22":["user-sdsu-25x17.png",25,17],"28x25":["user-sdsu-28x20.png",28,20]},"SF":{"38x24":["user-sf-27x24.png",27,24],"34x24":["user-sf-27x24.png",27,24],"26x23":["user-sf-26x23.png",26,23],"31x24":["user-sf-27x24.png",27,24],"29x22":["user-sf-25x22.png",25,22],"25x19":["user-sf-21x19.png",21,19],"22x20":["user-sf-22x20.png",22,20],"24x25":["user-sf-24x21.png",24,21],"30x19":["user-sf-21x19.png",21,19],"25x22":["user-sf-25x22.png",25,22],"28x25":["user-sf-28x25.png",28,25]},"SJSU":{"38x24":["user-sjsu-22x24.png",22,24],"34x24":["user-sjsu-22x24.png",22,24],"26x23":["user-sjsu-22x23.png",22,23],"31x24":["user-sjsu-22x24.png",22,24],"29x22":["user-sjsu-21x22.png",21,22],"25x19":["user-sjsu-18x19.png",18,19],"22x20":["user-sjsu-19x20.png",19,20],"24x25":["user-sjsu-23x25.png",23,25],"30x19":["user-sjsu-18x19.png",18,19],"25x22":["user-sjsu-21x22.png",21,22],"28x25":["user-sjsu-23x25.png",23,25]},"SCU":{"38x24":["user-scu-18x24.png",18,24],"34x24":["user-scu-18x24.png",18,24],"26x23":["user-scu-18x23.png",18,23],"31x24":["user-scu-18x24.png",18,24],"29x22":["user-scu-17x22.png",17,22],"25x19":["user-scu-15x19.png",15,19],"22x20":["user-scu-15x20.png",15,20],"24x25":["user-scu-19x25.png",19,25],"30x19":["user-scu-15x19.png",15,19],"25x22":["user-scu-17x22.png",17,22],"28x25":["user-scu-19x25.png",19,25]},"SEA":{"38x24":["user-sea-21x24.png",21,24],"34x24":["user-sea-21x24.png",21,24],"26x23":["user-sea-20x23.png",20,23],"31x24":["user-sea-21x24.png",21,24],"29x22":["user-sea-20x22.png",20,22],"25x19":["user-sea-17x19.png",17,19],"22x20":["user-sea-18x20.png",18,20],"24x25":["user-sea-22x25.png",22,25],"30x19":["user-sea-17x19.png",17,19],"25x22":["user-sea-20x22.png",20,22],"28x25":["user-sea-22x25.png",22,25]},"HALL":{"38x24":["user-hall-24x24.png",24,24],"34x24":["user-hall-24x24.png",24,24],"26x23":["user-hall-23x23.png",23,23],"31x24":["user-hall-24x24.png",24,24],"29x22":["user-hall-22x22.png",22,22],"25x19":["user-hall-19x19.png",19,19],"22x20":["user-hall-20x20.png",20,20],"24x25":["user-hall-24x24.png",24,24],"30x19":["user-hall-19x19.png",19,19],"25x22":["user-hall-22x22.png",22,22],"28x25":["user-hall-25x25.png",25,25]},"SIE":{"38x24":["user-sie-38x21.png",38,21],"34x24":["user-sie-34x18.png",34,18],"26x23":["user-sie-26x14.png",26,14],"31x24":["user-sie-31x17.png",31,17],"29x22":["user-sie-29x16.png",29,16],"25x19":["user-sie-25x14.png",25,14],"22x20":["user-sie-22x12.png",22,12],"24x25":["user-sie-24x13.png",24,13],"30x19":["user-sie-30x16.png",30,16],"25x22":["user-sie-25x14.png",25,14],"28x25":["user-sie-28x15.png",28,15]},"SIUE":{"38x24":["user-siue-38x13.png",38,13],"34x24":["user-siue-34x12.png",34,12],"26x23":["user-siue-26x9.png",26,9],"31x24":["user-siue-31x11.png",31,11],"29x22":["user-siue-29x10.png",29,10],"25x19":["user-siue-25x9.png",25,9],"22x20":["user-siue-22x8.png",22,8],"24x25":["user-siue-24x8.png",24,8],"30x19":["user-siue-30x10.png",30,10],"25x22":["user-siue-25x9.png",25,9],"28x25":["user-siue-28x10.png",28,10]},"SMU":{"38x24":["user-smu-38x20.png",38,20],"34x24":["user-smu-34x18.png",34,18],"26x23":["user-smu-26x13.png",26,13],"31x24":["user-smu-31x16.png",31,16],"29x22":["user-smu-29x15.png",29,15],"25x19":["user-smu-25x13.png",25,13],"22x20":["user-smu-22x11.png",22,11],"24x25":["user-smu-24x12.png",24,12],"30x19":["user-smu-30x16.png",30,16],"25x22":["user-smu-25x13.png",25,13],"28x25":["user-smu-28x15.png",28,15]},"USA":{"38x24":["user-usa-32x24.png",32,24],"34x24":["user-usa-32x24.png",32,24],"26x23":["user-usa-26x19.png",26,19],"31x24":["user-usa-31x23.png",31,23],"29x22":["user-usa-29x22.png",29,22],"25x19":["user-usa-25x19.png",25,19],"22x20":["user-usa-22x16.png",22,16],"24x25":["user-usa-24x18.png",24,18],"30x19":["user-usa-26x19.png",26,19],"25x22":["user-usa-25x19.png",25,19],"28x25":["user-usa-28x21.png",28,21]},"SC":{"38x24":["user-sc-22x24.png",22,24],"34x24":["user-sc-22x24.png",22,24],"26x23":["user-sc-21x23.png",21,23],"31x24":["user-sc-22x24.png",22,24],"29x22":["user-sc-20x22.png",20,22],"25x19":["user-sc-17x19.png",17,19],"22x20":["user-sc-18x20.png",18,20],"24x25":["user-sc-23x25.png",23,25],"30x19":["user-sc-17x19.png",17,19],"25x22":["user-sc-20x22.png",20,22],"28x25":["user-sc-23x25.png",23,25]},"SCST":{"38x24":["user-scst-20x24.png",20,24],"34x24":["user-scst-20x24.png",20,24],"26x23":["user-scst-19x23.png",19,23],"31x24":["user-scst-20x24.png",20,24],"29x22":["user-scst-18x22.png",18,22],"25x19":["user-scst-16x19.png",16,19],"22x20":["user-scst-16x20.png",16,20],"24x25":["user-scst-20x25.png",20,25],"30x19":["user-scst-16x19.png",16,19],"25x22":["user-scst-18x22.png",18,22],"28x25":["user-scst-20x25.png",20,25]},"UPST":{"38x24":["user-upst-35x24.png",35,24],"34x24":["user-upst-34x24.png",34,24],"26x23":["user-upst-26x18.png",26,18],"31x24":["user-upst-31x21.png",31,21],"29x22":["user-upst-29x20.png",29,20],"25x19":["user-upst-25x17.png",25,17],"22x20":["user-upst-22x15.png",22,15],"24x25":["user-upst-24x17.png",24,17],"30x19":["user-upst-27x19.png",27,19],"25x22":["user-upst-25x17.png",25,17],"28x25":["user-upst-28x19.png",28,19]},"SDAK":{"38x24":["user-sdak-19x24.png",19,24],"34x24":["user-sdak-19x24.png",19,24],"26x23":["user-sdak-18x23.png",18,23],"31x24":["user-sdak-19x24.png",19,24],"29x22":["user-sdak-17x22.png",17,22],"25x19":["user-sdak-15x19.png",15,19],"22x20":["user-sdak-16x20.png",16,20],"24x25":["user-sdak-20x25.png",20,25],"30x19":["user-sdak-15x19.png",15,19],"25x22":["user-sdak-17x22.png",17,22],"28x25":["user-sdak-20x25.png",20,25]},"SDST":{"38x24":["user-sdst-31x24.png",31,24],"34x24":["user-sdst-31x24.png",31,24],"26x23":["user-sdst-26x20.png",26,20],"31x24":["user-sdst-31x24.png",31,24],"29x22":["user-sdst-29x22.png",29,22],"25x19":["user-sdst-25x19.png",25,19],"22x20":["user-sdst-22x17.png",22,17],"24x25":["user-sdst-24x18.png",24,18],"30x19":["user-sdst-25x19.png",25,19],"25x22":["user-sdst-25x19.png",25,19],"28x25":["user-sdst-28x21.png",28,21]},"USF":{"38x24":["user-usf-30x24.png",30,24],"34x24":["user-usf-30x24.png",30,24],"26x23":["user-usf-26x21.png",26,21],"31x24":["user-usf-30x24.png",30,24],"29x22":["user-usf-27x22.png",27,22],"25x19":["user-usf-24x19.png",24,19],"22x20":["user-usf-22x18.png",22,18],"24x25":["user-usf-24x19.png",24,19],"30x19":["user-usf-24x19.png",24,19],"25x22":["user-usf-25x20.png",25,20],"28x25":["user-usf-28x22.png",28,22]},"SEMO":{"38x24":["user-semo-38x23.png",38,23],"34x24":["user-semo-34x21.png",34,21],"26x23":["user-semo-26x16.png",26,16],"31x24":["user-semo-31x19.png",31,19],"29x22":["user-semo-29x18.png",29,18],"25x19":["user-semo-25x15.png",25,15],"22x20":["user-semo-22x14.png",22,14],"24x25":["user-semo-24x15.png",24,15],"30x19":["user-semo-30x18.png",30,18],"25x22":["user-semo-25x15.png",25,15],"28x25":["user-semo-28x17.png",28,17]},"SELA":{"38x24":["user-sela-20x24.png",20,24],"34x24":["user-sela-20x24.png",20,24],"26x23":["user-sela-20x23.png",20,23],"31x24":["user-sela-20x24.png",20,24],"29x22":["user-sela-19x22.png",19,22],"25x19":["user-sela-16x19.png",16,19],"22x20":["user-sela-17x20.png",17,20],"24x25":["user-sela-21x25.png",21,25],"30x19":["user-sela-16x19.png",16,19],"25x22":["user-sela-19x22.png",19,22],"28x25":["user-sela-21x25.png",21,25]},"SOU":{"38x24":["user-sou-27x24.png",27,24],"34x24":["user-sou-27x24.png",27,24],"26x23":["user-sou-26x23.png",26,23],"31x24":["user-sou-27x24.png",27,24],"29x22":["user-sou-25x22.png",25,22],"25x19":["user-sou-22x19.png",22,19],"22x20":["user-sou-22x19.png",22,19],"24x25":["user-sou-24x21.png",24,21],"30x19":["user-sou-22x19.png",22,19],"25x22":["user-sou-25x22.png",25,22],"28x25":["user-sou-28x25.png",28,25]},"SIU":{"38x24":["user-siu-38x22.png",38,22],"34x24":["user-siu-34x20.png",34,20],"26x23":["user-siu-26x15.png",26,15],"31x24":["user-siu-31x18.png",31,18],"29x22":["user-siu-29x17.png",29,17],"25x19":["user-siu-25x15.png",25,15],"22x20":["user-siu-22x13.png",22,13],"24x25":["user-siu-24x14.png",24,14],"30x19":["user-siu-30x17.png",30,17],"25x22":["user-siu-25x15.png",25,15],"28x25":["user-siu-28x16.png",28,16]},"USI":{"38x24":["user-usi-37x24.png",37,24],"34x24":["user-usi-34x22.png",34,22],"26x23":["user-usi-26x17.png",26,17],"31x24":["user-usi-31x20.png",31,20],"29x22":["user-usi-29x19.png",29,19],"25x19":["user-usi-25x16.png",25,16],"22x20":["user-usi-22x14.png",22,14],"24x25":["user-usi-24x15.png",24,15],"30x19":["user-usi-30x19.png",30,19],"25x22":["user-usi-25x16.png",25,16],"28x25":["user-usi-28x18.png",28,18]},"USM":{"38x24":["user-usm-38x21.png",38,21],"34x24":["user-usm-34x18.png",34,18],"26x23":["user-usm-26x14.png",26,14],"31x24":["user-usm-31x17.png",31,17],"29x22":["user-usm-29x16.png",29,16],"25x19":["user-usm-25x14.png",25,14],"22x20":["user-usm-22x12.png",22,12],"24x25":["user-usm-24x13.png",24,13],"30x19":["user-usm-30x16.png",30,16],"25x22":["user-usm-25x14.png",25,14],"28x25":["user-usm-28x15.png",28,15]},"SUU":{"38x24":["user-suu-38x23.png",38,23],"34x24":["user-suu-34x21.png",34,21],"26x23":["user-suu-26x16.png",26,16],"31x24":["user-suu-31x19.png",31,19],"29x22":["user-suu-29x18.png",29,18],"25x19":["user-suu-25x15.png",25,15],"22x20":["user-suu-22x14.png",22,14],"24x25":["user-suu-24x15.png",24,15],"30x19":["user-suu-30x19.png",30,19],"25x22":["user-suu-25x15.png",25,15],"28x25":["user-suu-28x17.png",28,17]}})
TEAM_LOGO_BOUNDS.update({"MUR":[26,23,2,0,24,23],"NAVY":[26,23,3,0,22,23],"NEB":[26,23,1,0,24,23],"NEV":[26,23,0,3,26,20],"UNH":[26,23,0,0,26,22],"UNM":[26,23,3,0,22,23],"NMSU":[26,23,0,2,26,21],"NOLA":[26,23,0,0,26,23],"NIA":[26,23,0,6,26,17],"NICH":[26,23,0,5,26,18],"NJIT":[26,23,0,0,26,23],"NORF":[26,23,1,0,24,23],"UNA":[26,23,0,2,26,21],"UNC":[26,23,0,1,26,21],"NCAT":[26,23,3,0,22,23],"NCCU":[26,23,0,5,26,18],"NCST":[26,23,4,0,21,23],"UND":[26,23,0,5,26,17],"UNF":[26,23,0,3,26,19],"UNT":[26,23,2,0,23,23],"NE":[26,23,1,0,24,23],"NAU":[26,23,0,3,26,19],"UNCO":[26,23,1,0,24,23],"NIU":[26,23,1,0,25,23],"UNI":[26,23,0,2,26,20],"NKU":[26,23,0,3,26,19],"NU":[26,23,5,0,20,23],"NWST":[26,23,0,1,26,21],"ND":[26,23,0,0,25,23],"OAK":[26,23,0,0,26,22],"OHIO":[26,23,0,0,26,22],"OU":[26,23,4,0,22,23],"OKST":[26,23,0,5,26,18],"ODU":[26,23,0,0,26,22],"MISS":[26,23,0,0,25,23],"OMA":[26,23,1,0,25,23],"ORU":[26,23,0,2,26,20],"ORE":[26,23,0,1,26,22],"ORST":[26,23,0,4,26,19],"PAC":[26,23,0,2,26,20],"PSU":[26,23,0,2,26,20],"PEPP":[26,23,2,0,24,23],"PITT":[26,23,0,4,26,19],"PORT":[26,23,3,0,23,23],"PRST":[26,23,4,0,22,23],"PV":[26,23,0,3,26,19],"PRES":[26,23,1,0,24,23],"PRIN":[26,23,3,0,23,23],"PROV":[26,23,0,3,26,20],"PUR":[26,23,0,4,26,18],"PFW":[26,23,0,0,25,23],"QUIN":[26,23,2,0,24,23],"QUC":[26,23,4,0,22,23],"RAD":[26,23,0,0,26,22],"URI":[26,23,4,0,22,23],"RICE":[26,23,3,0,22,23],"RICH":[26,23,4,0,21,23],"RID":[26,23,0,3,26,19],"RMU":[26,23,0,5,26,17],"RUTG":[26,23,0,0,26,23],"SAC":[26,23,0,0,26,23],"SHU":[26,23,0,6,26,16],"JOES":[26,23,0,3,26,19],"SLU":[26,23,1,0,25,23],"SPU":[26,23,4,0,21,23],"SHSU":[26,23,0,1,26,22],"SAM":[26,23,0,3,26,19],"USD":[26,23,1,0,25,23],"SDSU":[26,23,0,2,26,20],"SF":[26,23,0,0,26,23],"SJSU":[26,23,2,0,24,23],"SCU":[26,23,4,0,22,23],"SEA":[26,23,3,0,23,23],"HALL":[26,23,1,0,24,23],"SIE":[26,23,0,4,26,18],"SIUE":[26,23,0,7,26,16],"SMU":[26,23,0,5,26,18],"USA":[26,23,0,2,26,21],"SC":[26,23,2,0,23,23],"SCST":[26,23,3,0,22,23],"UPST":[26,23,0,2,26,20],"SDAK":[26,23,4,0,22,23],"SDST":[26,23,0,1,26,21],"USF":[26,23,0,1,26,22],"SEMO":[26,23,0,3,26,19],"SELA":[26,23,3,0,23,23],"SOU":[26,23,0,0,26,23],"SIU":[26,23,0,4,26,19],"USI":[26,23,0,3,26,20],"USM":[26,23,0,4,26,18],"SUU":[26,23,0,3,26,19]})

USER_LOGO_FRAMES.update({"OSU":{"38x24":["user-osu-24x24.png",24,24],"34x24":["user-osu-24x24.png",24,24],"26x23":["user-osu-23x23.png",23,23],"31x24":["user-osu-24x24.png",24,24],"29x22":["user-osu-22x22.png",22,22],"25x19":["user-osu-19x19.png",19,19],"22x20":["user-osu-20x20.png",20,20],"24x25":["user-osu-24x24.png",24,24],"30x19":["user-osu-19x19.png",19,19],"25x22":["user-osu-22x22.png",22,22],"28x25":["user-osu-25x25.png",25,25]}})
TEAM_LOGO_BOUNDS.update({"OSU":[26,23,1,0,24,23]})

USER_LOGO_FRAMES.update({"SFPA":{"38x24":["user-sfpa-38x22.png",38,22],"34x24":["user-sfpa-34x20.png",34,20],"26x23":["user-sfpa-26x15.png",26,15],"31x24":["user-sfpa-31x18.png",31,18],"29x22":["user-sfpa-29x17.png",29,17],"25x19":["user-sfpa-25x15.png",25,15],"22x20":["user-sfpa-22x13.png",22,13],"24x25":["user-sfpa-24x14.png",24,14],"30x19":["user-sfpa-30x17.png",30,17],"25x22":["user-sfpa-25x15.png",25,15],"28x25":["user-sfpa-28x16.png",28,16]},"SJU":{"38x24":["user-sju-17x24.png",17,24],"34x24":["user-sju-17x24.png",17,24],"26x23":["user-sju-16x23.png",16,23],"31x24":["user-sju-17x24.png",17,24],"29x22":["user-sju-16x22.png",16,22],"25x19":["user-sju-14x19.png",14,19],"22x20":["user-sju-14x20.png",14,20],"24x25":["user-sju-18x25.png",18,25],"30x19":["user-sju-14x19.png",14,19],"25x22":["user-sju-16x22.png",16,22],"28x25":["user-sju-18x25.png",18,25]},"STMN":{"38x24":["user-stmn-22x24.png",22,24],"34x24":["user-stmn-22x24.png",22,24],"26x23":["user-stmn-21x23.png",21,23],"31x24":["user-stmn-22x24.png",22,24],"29x22":["user-stmn-20x22.png",20,22],"25x19":["user-stmn-17x19.png",17,19],"22x20":["user-stmn-18x20.png",18,20],"24x25":["user-stmn-22x25.png",22,25],"30x19":["user-stmn-17x19.png",17,19],"25x22":["user-stmn-20x22.png",20,22],"28x25":["user-stmn-22x25.png",22,25]},"STAN":{"38x24":["user-stan-16x24.png",16,24],"34x24":["user-stan-16x24.png",16,24],"26x23":["user-stan-15x23.png",15,23],"31x24":["user-stan-16x24.png",16,24],"29x22":["user-stan-14x22.png",14,22],"25x19":["user-stan-12x19.png",12,19],"22x20":["user-stan-13x20.png",13,20],"24x25":["user-stan-16x25.png",16,25],"30x19":["user-stan-12x19.png",12,19],"25x22":["user-stan-14x22.png",14,22],"28x25":["user-stan-16x25.png",16,25]},"SFA":{"38x24":["user-sfa-25x24.png",25,24],"34x24":["user-sfa-25x24.png",25,24],"26x23":["user-sfa-24x23.png",24,23],"31x24":["user-sfa-25x24.png",25,24],"29x22":["user-sfa-23x22.png",23,22],"25x19":["user-sfa-20x19.png",20,19],"22x20":["user-sfa-21x20.png",21,20],"24x25":["user-sfa-24x23.png",24,23],"30x19":["user-sfa-20x19.png",20,19],"25x22":["user-sfa-23x22.png",23,22],"28x25":["user-sfa-26x25.png",26,25]},"STET":{"38x24":["user-stet-24x24.png",24,24],"34x24":["user-stet-24x24.png",24,24],"26x23":["user-stet-23x23.png",23,23],"31x24":["user-stet-24x24.png",24,24],"29x22":["user-stet-22x22.png",22,22],"25x19":["user-stet-19x19.png",19,19],"22x20":["user-stet-20x20.png",20,20],"24x25":["user-stet-24x24.png",24,24],"30x19":["user-stet-19x19.png",19,19],"25x22":["user-stet-22x22.png",22,22],"28x25":["user-stet-25x25.png",25,25]},"STO":{"38x24":["user-sto-33x24.png",33,24],"34x24":["user-sto-33x24.png",33,24],"26x23":["user-sto-26x19.png",26,19],"31x24":["user-sto-31x22.png",31,22],"29x22":["user-sto-29x21.png",29,21],"25x19":["user-sto-25x18.png",25,18],"22x20":["user-sto-22x16.png",22,16],"24x25":["user-sto-24x17.png",24,17],"30x19":["user-sto-26x19.png",26,19],"25x22":["user-sto-25x18.png",25,18],"28x25":["user-sto-28x20.png",28,20]},"STBK":{"38x24":["user-stbk-33x24.png",33,24],"34x24":["user-stbk-33x24.png",33,24],"26x23":["user-stbk-26x19.png",26,19],"31x24":["user-stbk-31x22.png",31,22],"29x22":["user-stbk-29x21.png",29,21],"25x19":["user-stbk-25x18.png",25,18],"22x20":["user-stbk-22x16.png",22,16],"24x25":["user-stbk-24x17.png",24,17],"30x19":["user-stbk-26x19.png",26,19],"25x22":["user-stbk-25x18.png",25,18],"28x25":["user-stbk-28x20.png",28,20]},"SYR":{"38x24":["user-syr-18x24.png",18,24],"34x24":["user-syr-18x24.png",18,24],"26x23":["user-syr-17x23.png",17,23],"31x24":["user-syr-18x24.png",18,24],"29x22":["user-syr-16x22.png",16,22],"25x19":["user-syr-14x19.png",14,19],"22x20":["user-syr-15x20.png",15,20],"24x25":["user-syr-18x25.png",18,25],"30x19":["user-syr-14x19.png",14,19],"25x22":["user-syr-16x22.png",16,22],"28x25":["user-syr-18x25.png",18,25]},"TAR":{"38x24":["user-tar-26x24.png",26,24],"34x24":["user-tar-26x24.png",26,24],"26x23":["user-tar-24x23.png",24,23],"31x24":["user-tar-26x24.png",26,24],"29x22":["user-tar-23x22.png",23,22],"25x19":["user-tar-20x19.png",20,19],"22x20":["user-tar-21x20.png",21,20],"24x25":["user-tar-24x23.png",24,23],"30x19":["user-tar-20x19.png",20,19],"25x22":["user-tar-23x22.png",23,22],"28x25":["user-tar-27x25.png",27,25]},"TCU":{"38x24":["user-tcu-38x19.png",38,19],"34x24":["user-tcu-34x17.png",34,17],"26x23":["user-tcu-26x13.png",26,13],"31x24":["user-tcu-31x15.png",31,15],"29x22":["user-tcu-29x14.png",29,14],"25x19":["user-tcu-25x12.png",25,12],"22x20":["user-tcu-22x11.png",22,11],"24x25":["user-tcu-24x12.png",24,12],"30x19":["user-tcu-30x15.png",30,15],"25x22":["user-tcu-25x12.png",25,12],"28x25":["user-tcu-28x14.png",28,14]},"TEM":{"38x24":["user-tem-21x24.png",21,24],"34x24":["user-tem-21x24.png",21,24],"26x23":["user-tem-20x23.png",20,23],"31x24":["user-tem-21x24.png",21,24],"29x22":["user-tem-19x22.png",19,22],"25x19":["user-tem-17x19.png",17,19],"22x20":["user-tem-18x20.png",18,20],"24x25":["user-tem-22x25.png",22,25],"30x19":["user-tem-17x19.png",17,19],"25x22":["user-tem-19x22.png",19,22],"28x25":["user-tem-22x25.png",22,25]},"TENN":{"38x24":["user-tenn-24x24.png",24,24],"34x24":["user-tenn-24x24.png",24,24],"26x23":["user-tenn-23x23.png",23,23],"31x24":["user-tenn-24x24.png",24,24],"29x22":["user-tenn-22x22.png",22,22],"25x19":["user-tenn-19x19.png",19,19],"22x20":["user-tenn-20x20.png",20,20],"24x25":["user-tenn-24x24.png",24,24],"30x19":["user-tenn-19x19.png",19,19],"25x22":["user-tenn-22x22.png",22,22],"28x25":["user-tenn-25x25.png",25,25]},"TNTC":{"38x24":["user-tntc-31x24.png",31,24],"34x24":["user-tntc-31x24.png",31,24],"26x23":["user-tntc-26x20.png",26,20],"31x24":["user-tntc-31x24.png",31,24],"29x22":["user-tntc-29x22.png",29,22],"25x19":["user-tntc-25x19.png",25,19],"22x20":["user-tntc-22x17.png",22,17],"24x25":["user-tntc-24x18.png",24,18],"30x19":["user-tntc-25x19.png",25,19],"25x22":["user-tntc-25x19.png",25,19],"28x25":["user-tntc-28x21.png",28,21]},"TAMU":{"38x24":["user-tamu-25x24.png",25,24],"34x24":["user-tamu-25x24.png",25,24],"26x23":["user-tamu-24x23.png",24,23],"31x24":["user-tamu-25x24.png",25,24],"29x22":["user-tamu-23x22.png",23,22],"25x19":["user-tamu-19x19.png",19,19],"22x20":["user-tamu-21x20.png",21,20],"24x25":["user-tamu-24x23.png",24,23],"30x19":["user-tamu-19x19.png",19,19],"25x22":["user-tamu-23x22.png",23,22],"28x25":["user-tamu-26x25.png",26,25]},"AMCC":{"38x24":["user-amcc-26x24.png",26,24],"34x24":["user-amcc-26x24.png",26,24],"26x23":["user-amcc-25x23.png",25,23],"31x24":["user-amcc-26x24.png",26,24],"29x22":["user-amcc-24x22.png",24,22],"25x19":["user-amcc-21x19.png",21,19],"22x20":["user-amcc-22x20.png",22,20],"24x25":["user-amcc-24x22.png",24,22],"30x19":["user-amcc-21x19.png",21,19],"25x22":["user-amcc-24x22.png",24,22],"28x25":["user-amcc-27x25.png",27,25]},"TXSO":{"38x24":["user-txso-25x24.png",25,24],"34x24":["user-txso-25x24.png",25,24],"26x23":["user-txso-24x23.png",24,23],"31x24":["user-txso-25x24.png",25,24],"29x22":["user-txso-23x22.png",23,22],"25x19":["user-txso-20x19.png",20,19],"22x20":["user-txso-21x20.png",21,20],"24x25":["user-txso-24x23.png",24,23],"30x19":["user-txso-20x19.png",20,19],"25x22":["user-txso-23x22.png",23,22],"28x25":["user-txso-26x25.png",26,25]},"TXST":{"38x24":["user-txst-21x24.png",21,24],"34x24":["user-txst-21x24.png",21,24],"26x23":["user-txst-20x23.png",20,23],"31x24":["user-txst-21x24.png",21,24],"29x22":["user-txst-19x22.png",19,22],"25x19":["user-txst-16x19.png",16,19],"22x20":["user-txst-17x20.png",17,20],"24x25":["user-txst-21x25.png",21,25],"30x19":["user-txst-16x19.png",16,19],"25x22":["user-txst-19x22.png",19,22],"28x25":["user-txst-21x25.png",21,25]},"TTU":{"38x24":["user-ttu-21x24.png",21,24],"34x24":["user-ttu-21x24.png",21,24],"26x23":["user-ttu-20x23.png",20,23],"31x24":["user-ttu-21x24.png",21,24],"29x22":["user-ttu-19x22.png",19,22],"25x19":["user-ttu-16x19.png",16,19],"22x20":["user-ttu-17x20.png",17,20],"24x25":["user-ttu-21x25.png",21,25],"30x19":["user-ttu-16x19.png",16,19],"25x22":["user-ttu-19x22.png",19,22],"28x25":["user-ttu-21x25.png",21,25]},"CIT":{"38x24":["user-cit-27x24.png",27,24],"34x24":["user-cit-27x24.png",27,24],"26x23":["user-cit-26x23.png",26,23],"31x24":["user-cit-27x24.png",27,24],"29x22":["user-cit-25x22.png",25,22],"25x19":["user-cit-22x19.png",22,19],"22x20":["user-cit-22x19.png",22,19],"24x25":["user-cit-24x21.png",24,21],"30x19":["user-cit-22x19.png",22,19],"25x22":["user-cit-25x22.png",25,22],"28x25":["user-cit-28x25.png",28,25]},"TOL":{"38x24":["user-tol-38x22.png",38,22],"34x24":["user-tol-34x20.png",34,20],"26x23":["user-tol-26x15.png",26,15],"31x24":["user-tol-31x18.png",31,18],"29x22":["user-tol-29x17.png",29,17],"25x19":["user-tol-25x15.png",25,15],"22x20":["user-tol-22x13.png",22,13],"24x25":["user-tol-24x14.png",24,14],"30x19":["user-tol-30x18.png",30,18],"25x22":["user-tol-25x15.png",25,15],"28x25":["user-tol-28x17.png",28,17]},"TOW":{"38x24":["user-tow-35x24.png",35,24],"34x24":["user-tow-34x23.png",34,23],"26x23":["user-tow-26x18.png",26,18],"31x24":["user-tow-31x21.png",31,21],"29x22":["user-tow-29x20.png",29,20],"25x19":["user-tow-25x17.png",25,17],"22x20":["user-tow-22x15.png",22,15],"24x25":["user-tow-24x16.png",24,16],"30x19":["user-tow-28x19.png",28,19],"25x22":["user-tow-25x17.png",25,17],"28x25":["user-tow-28x19.png",28,19]},"TROY":{"38x24":["user-troy-21x24.png",21,24],"34x24":["user-troy-21x24.png",21,24],"26x23":["user-troy-20x23.png",20,23],"31x24":["user-troy-21x24.png",21,24],"29x22":["user-troy-19x22.png",19,22],"25x19":["user-troy-17x19.png",17,19],"22x20":["user-troy-18x20.png",18,20],"24x25":["user-troy-22x25.png",22,25],"30x19":["user-troy-17x19.png",17,19],"25x22":["user-troy-19x22.png",19,22],"28x25":["user-troy-22x25.png",22,25]},"TULN":{"38x24":["user-tuln-33x24.png",33,24],"34x24":["user-tuln-33x24.png",33,24],"26x23":["user-tuln-26x19.png",26,19],"31x24":["user-tuln-31x22.png",31,22],"29x22":["user-tuln-29x21.png",29,21],"25x19":["user-tuln-25x18.png",25,18],"22x20":["user-tuln-22x16.png",22,16],"24x25":["user-tuln-24x17.png",24,17],"30x19":["user-tuln-26x19.png",26,19],"25x22":["user-tuln-25x18.png",25,18],"28x25":["user-tuln-28x20.png",28,20]},"TLSA":{"38x24":["user-tlsa-30x24.png",30,24],"34x24":["user-tlsa-30x24.png",30,24],"26x23":["user-tlsa-26x21.png",26,21],"31x24":["user-tlsa-30x24.png",30,24],"29x22":["user-tlsa-27x22.png",27,22],"25x19":["user-tlsa-24x19.png",24,19],"22x20":["user-tlsa-22x18.png",22,18],"24x25":["user-tlsa-24x19.png",24,19],"30x19":["user-tlsa-24x19.png",24,19],"25x22":["user-tlsa-25x20.png",25,20],"28x25":["user-tlsa-28x22.png",28,22]},"UAB":{"38x24":["user-uab-28x24.png",28,24],"34x24":["user-uab-28x24.png",28,24],"26x23":["user-uab-26x22.png",26,22],"31x24":["user-uab-28x24.png",28,24],"29x22":["user-uab-26x22.png",26,22],"25x19":["user-uab-22x19.png",22,19],"22x20":["user-uab-22x19.png",22,19],"24x25":["user-uab-24x20.png",24,20],"30x19":["user-uab-22x19.png",22,19],"25x22":["user-uab-25x21.png",25,21],"28x25":["user-uab-28x24.png",28,24]},"UALB":{"38x24":["user-ualb-13x24.png",13,24],"34x24":["user-ualb-13x24.png",13,24],"26x23":["user-ualb-12x23.png",12,23],"31x24":["user-ualb-13x24.png",13,24],"29x22":["user-ualb-12x22.png",12,22],"25x19":["user-ualb-10x19.png",10,19],"22x20":["user-ualb-11x20.png",11,20],"24x25":["user-ualb-13x25.png",13,25],"30x19":["user-ualb-10x19.png",10,19],"25x22":["user-ualb-12x22.png",12,22],"28x25":["user-ualb-13x25.png",13,25]},"UCD":{"38x24":["user-ucd-33x24.png",33,24],"34x24":["user-ucd-33x24.png",33,24],"26x23":["user-ucd-26x19.png",26,19],"31x24":["user-ucd-31x22.png",31,22],"29x22":["user-ucd-29x21.png",29,21],"25x19":["user-ucd-25x18.png",25,18],"22x20":["user-ucd-22x16.png",22,16],"24x25":["user-ucd-24x17.png",24,17],"30x19":["user-ucd-26x19.png",26,19],"25x22":["user-ucd-25x18.png",25,18],"28x25":["user-ucd-28x20.png",28,20]},"UCI":{"38x24":["user-uci-23x24.png",23,24],"34x24":["user-uci-23x24.png",23,24],"26x23":["user-uci-22x23.png",22,23],"31x24":["user-uci-23x24.png",23,24],"29x22":["user-uci-21x22.png",21,22],"25x19":["user-uci-18x19.png",18,19],"22x20":["user-uci-19x20.png",19,20],"24x25":["user-uci-23x25.png",23,25],"30x19":["user-uci-18x19.png",18,19],"25x22":["user-uci-21x22.png",21,22],"28x25":["user-uci-23x25.png",23,25]},"UCR":{"38x24":["user-ucr-25x24.png",25,24],"34x24":["user-ucr-25x24.png",25,24],"26x23":["user-ucr-24x23.png",24,23],"31x24":["user-ucr-25x24.png",25,24],"29x22":["user-ucr-23x22.png",23,22],"25x19":["user-ucr-20x19.png",20,19],"22x20":["user-ucr-21x20.png",21,20],"24x25":["user-ucr-24x23.png",24,23],"30x19":["user-ucr-20x19.png",20,19],"25x22":["user-ucr-23x22.png",23,22],"28x25":["user-ucr-26x25.png",26,25]},"UCSD":{"38x24":["user-ucsd-24x24.png",24,24],"34x24":["user-ucsd-24x24.png",24,24],"26x23":["user-ucsd-23x23.png",23,23],"31x24":["user-ucsd-24x24.png",24,24],"29x22":["user-ucsd-22x22.png",22,22],"25x19":["user-ucsd-19x19.png",19,19],"22x20":["user-ucsd-20x20.png",20,20],"24x25":["user-ucsd-24x24.png",24,24],"30x19":["user-ucsd-19x19.png",19,19],"25x22":["user-ucsd-22x22.png",22,22],"28x25":["user-ucsd-25x25.png",25,25]},"UCSB":{"38x24":["user-ucsb-36x24.png",36,24],"34x24":["user-ucsb-34x23.png",34,23],"26x23":["user-ucsb-26x18.png",26,18],"31x24":["user-ucsb-31x21.png",31,21],"29x22":["user-ucsb-29x20.png",29,20],"25x19":["user-ucsb-25x17.png",25,17],"22x20":["user-ucsb-22x15.png",22,15],"24x25":["user-ucsb-24x16.png",24,16],"30x19":["user-ucsb-28x19.png",28,19],"25x22":["user-ucsb-25x17.png",25,17],"28x25":["user-ucsb-28x19.png",28,19]},"UCF":{"38x24":["user-ucf-30x24.png",30,24],"34x24":["user-ucf-30x24.png",30,24],"26x23":["user-ucf-26x21.png",26,21],"31x24":["user-ucf-30x24.png",30,24],"29x22":["user-ucf-27x22.png",27,22],"25x19":["user-ucf-24x19.png",24,19],"22x20":["user-ucf-22x18.png",22,18],"24x25":["user-ucf-24x19.png",24,19],"30x19":["user-ucf-24x19.png",24,19],"25x22":["user-ucf-25x20.png",25,20],"28x25":["user-ucf-28x22.png",28,22]},"UCLA":{"38x24":["user-ucla-38x18.png",38,18],"34x24":["user-ucla-34x16.png",34,16],"26x23":["user-ucla-26x13.png",26,13],"31x24":["user-ucla-31x15.png",31,15],"29x22":["user-ucla-29x14.png",29,14],"25x19":["user-ucla-25x12.png",25,12],"22x20":["user-ucla-22x11.png",22,11],"24x25":["user-ucla-24x12.png",24,12],"30x19":["user-ucla-30x14.png",30,14],"25x22":["user-ucla-25x12.png",25,12],"28x25":["user-ucla-28x14.png",28,14]},"CONN":{"38x24":["user-conn-19x24.png",19,24],"34x24":["user-conn-19x24.png",19,24],"26x23":["user-conn-18x23.png",18,23],"31x24":["user-conn-19x24.png",19,24],"29x22":["user-conn-18x22.png",18,22],"25x19":["user-conn-15x19.png",15,19],"22x20":["user-conn-16x20.png",16,20],"24x25":["user-conn-20x25.png",20,25],"30x19":["user-conn-15x19.png",15,19],"25x22":["user-conn-18x22.png",18,22],"28x25":["user-conn-20x25.png",20,25]},"UIC":{"38x24":["user-uic-38x16.png",38,16],"34x24":["user-uic-34x15.png",34,15],"26x23":["user-uic-26x11.png",26,11],"31x24":["user-uic-31x13.png",31,13],"29x22":["user-uic-29x13.png",29,13],"25x19":["user-uic-25x11.png",25,11],"22x20":["user-uic-22x10.png",22,10],"24x25":["user-uic-24x10.png",24,10],"30x19":["user-uic-30x13.png",30,13],"25x22":["user-uic-25x11.png",25,11],"28x25":["user-uic-28x12.png",28,12]},"ULM":{"38x24":["user-ulm-34x24.png",34,24],"34x24":["user-ulm-34x24.png",34,24],"26x23":["user-ulm-26x18.png",26,18],"31x24":["user-ulm-31x22.png",31,22],"29x22":["user-ulm-29x20.png",29,20],"25x19":["user-ulm-25x18.png",25,18],"22x20":["user-ulm-22x16.png",22,16],"24x25":["user-ulm-24x17.png",24,17],"30x19":["user-ulm-27x19.png",27,19],"25x22":["user-ulm-25x18.png",25,18],"28x25":["user-ulm-28x20.png",28,20]},"UML":{"38x24":["user-uml-38x17.png",38,17],"34x24":["user-uml-34x16.png",34,16],"26x23":["user-uml-26x12.png",26,12],"31x24":["user-uml-31x14.png",31,14],"29x22":["user-uml-29x13.png",29,13],"25x19":["user-uml-25x12.png",25,12],"22x20":["user-uml-22x10.png",22,10],"24x25":["user-uml-24x11.png",24,11],"30x19":["user-uml-30x14.png",30,14],"25x22":["user-uml-25x12.png",25,12],"28x25":["user-uml-28x13.png",28,13]},"UMBC":{"38x24":["user-umbc-26x24.png",26,24],"34x24":["user-umbc-26x24.png",26,24],"26x23":["user-umbc-25x23.png",25,23],"31x24":["user-umbc-26x24.png",26,24],"29x22":["user-umbc-24x22.png",24,22],"25x19":["user-umbc-20x19.png",20,19],"22x20":["user-umbc-22x20.png",22,20],"24x25":["user-umbc-24x22.png",24,22],"30x19":["user-umbc-20x19.png",20,19],"25x22":["user-umbc-24x22.png",24,22],"28x25":["user-umbc-27x25.png",27,25]},"UNCA":{"38x24":["user-unca-36x24.png",36,24],"34x24":["user-unca-34x22.png",34,22],"26x23":["user-unca-26x17.png",26,17],"31x24":["user-unca-31x20.png",31,20],"29x22":["user-unca-29x19.png",29,19],"25x19":["user-unca-25x16.png",25,16],"22x20":["user-unca-22x14.png",22,14],"24x25":["user-unca-24x16.png",24,16],"30x19":["user-unca-29x19.png",29,19],"25x22":["user-unca-25x16.png",25,16],"28x25":["user-unca-28x18.png",28,18]},"UNCG":{"38x24":["user-uncg-31x24.png",31,24],"34x24":["user-uncg-31x24.png",31,24],"26x23":["user-uncg-26x20.png",26,20],"31x24":["user-uncg-31x24.png",31,24],"29x22":["user-uncg-28x22.png",28,22],"25x19":["user-uncg-24x19.png",24,19],"22x20":["user-uncg-22x17.png",22,17],"24x25":["user-uncg-24x19.png",24,19],"30x19":["user-uncg-24x19.png",24,19],"25x22":["user-uncg-25x19.png",25,19],"28x25":["user-uncg-28x22.png",28,22]},"UNCW":{"38x24":["user-uncw-21x24.png",21,24],"34x24":["user-uncw-21x24.png",21,24],"26x23":["user-uncw-20x23.png",20,23],"31x24":["user-uncw-21x24.png",21,24],"29x22":["user-uncw-19x22.png",19,22],"25x19":["user-uncw-17x19.png",17,19],"22x20":["user-uncw-18x20.png",18,20],"24x25":["user-uncw-22x25.png",22,25],"30x19":["user-uncw-17x19.png",17,19],"25x22":["user-uncw-19x22.png",19,22],"28x25":["user-uncw-22x25.png",22,25]},"UNLV":{"38x24":["user-unlv-38x22.png",38,22],"34x24":["user-unlv-34x20.png",34,20],"26x23":["user-unlv-26x15.png",26,15],"31x24":["user-unlv-31x18.png",31,18],"29x22":["user-unlv-29x17.png",29,17],"25x19":["user-unlv-25x14.png",25,14],"22x20":["user-unlv-22x13.png",22,13],"24x25":["user-unlv-24x14.png",24,14],"30x19":["user-unlv-30x17.png",30,17],"25x22":["user-unlv-25x14.png",25,14],"28x25":["user-unlv-28x16.png",28,16]},"USC":{"38x24":["user-usc-23x24.png",23,24],"34x24":["user-usc-23x24.png",23,24],"26x23":["user-usc-22x23.png",22,23],"31x24":["user-usc-23x24.png",23,24],"29x22":["user-usc-21x22.png",21,22],"25x19":["user-usc-18x19.png",18,19],"22x20":["user-usc-19x20.png",19,20],"24x25":["user-usc-24x25.png",24,25],"30x19":["user-usc-18x19.png",18,19],"25x22":["user-usc-21x22.png",21,22],"28x25":["user-usc-24x25.png",24,25]},"UTA":{"38x24":["user-uta-31x24.png",31,24],"34x24":["user-uta-31x24.png",31,24],"26x23":["user-uta-26x20.png",26,20],"31x24":["user-uta-31x24.png",31,24],"29x22":["user-uta-29x22.png",29,22],"25x19":["user-uta-25x19.png",25,19],"22x20":["user-uta-22x17.png",22,17],"24x25":["user-uta-24x18.png",24,18],"30x19":["user-uta-25x19.png",25,19],"25x22":["user-uta-25x19.png",25,19],"28x25":["user-uta-28x22.png",28,22]},"UTM":{"38x24":["user-utm-30x24.png",30,24],"34x24":["user-utm-30x24.png",30,24],"26x23":["user-utm-26x21.png",26,21],"31x24":["user-utm-30x24.png",30,24],"29x22":["user-utm-28x22.png",28,22],"25x19":["user-utm-24x19.png",24,19],"22x20":["user-utm-22x18.png",22,18],"24x25":["user-utm-24x19.png",24,19],"30x19":["user-utm-24x19.png",24,19],"25x22":["user-utm-25x20.png",25,20],"28x25":["user-utm-28x22.png",28,22]},"RGV":{"38x24":["user-rgv-31x24.png",31,24],"34x24":["user-rgv-31x24.png",31,24],"26x23":["user-rgv-26x20.png",26,20],"31x24":["user-rgv-31x24.png",31,24],"29x22":["user-rgv-28x22.png",28,22],"25x19":["user-rgv-24x19.png",24,19],"22x20":["user-rgv-22x17.png",22,17],"24x25":["user-rgv-24x19.png",24,19],"30x19":["user-rgv-24x19.png",24,19],"25x22":["user-rgv-25x20.png",25,20],"28x25":["user-rgv-28x22.png",28,22]},"UTAH":{"38x24":["user-utah-26x24.png",26,24],"34x24":["user-utah-26x24.png",26,24],"26x23":["user-utah-25x23.png",25,23],"31x24":["user-utah-26x24.png",26,24],"29x22":["user-utah-24x22.png",24,22],"25x19":["user-utah-20x19.png",20,19],"22x20":["user-utah-21x20.png",21,20],"24x25":["user-utah-24x22.png",24,22],"30x19":["user-utah-20x19.png",20,19],"25x22":["user-utah-24x22.png",24,22],"28x25":["user-utah-27x25.png",27,25]},"USU":{"38x24":["user-usu-32x24.png",32,24],"34x24":["user-usu-32x24.png",32,24],"26x23":["user-usu-26x20.png",26,20],"31x24":["user-usu-31x23.png",31,23],"29x22":["user-usu-29x22.png",29,22],"25x19":["user-usu-25x19.png",25,19],"22x20":["user-usu-22x17.png",22,17],"24x25":["user-usu-24x18.png",24,18],"30x19":["user-usu-25x19.png",25,19],"25x22":["user-usu-25x19.png",25,19],"28x25":["user-usu-28x21.png",28,21]},"UTU":{"38x24":["user-utu-35x24.png",35,24],"34x24":["user-utu-34x23.png",34,23],"26x23":["user-utu-26x18.png",26,18],"31x24":["user-utu-31x21.png",31,21],"29x22":["user-utu-29x20.png",29,20],"25x19":["user-utu-25x17.png",25,17],"22x20":["user-utu-22x15.png",22,15],"24x25":["user-utu-24x16.png",24,16],"30x19":["user-utu-28x19.png",28,19],"25x22":["user-utu-25x17.png",25,17],"28x25":["user-utu-28x19.png",28,19]},"UVU":{"38x24":["user-uvu-34x24.png",34,24],"34x24":["user-uvu-34x24.png",34,24],"26x23":["user-uvu-26x18.png",26,18],"31x24":["user-uvu-31x22.png",31,22],"29x22":["user-uvu-29x20.png",29,20],"25x19":["user-uvu-25x18.png",25,18],"22x20":["user-uvu-22x15.png",22,15],"24x25":["user-uvu-24x17.png",24,17],"30x19":["user-uvu-27x19.png",27,19],"25x22":["user-uvu-25x18.png",25,18],"28x25":["user-uvu-28x20.png",28,20]},"UTEP":{"38x24":["user-utep-24x24.png",24,24],"34x24":["user-utep-24x24.png",24,24],"26x23":["user-utep-23x23.png",23,23],"31x24":["user-utep-24x24.png",24,24],"29x22":["user-utep-22x22.png",22,22],"25x19":["user-utep-19x19.png",19,19],"22x20":["user-utep-20x20.png",20,20],"24x25":["user-utep-24x24.png",24,24],"30x19":["user-utep-19x19.png",19,19],"25x22":["user-utep-22x22.png",22,22],"28x25":["user-utep-25x25.png",25,25]},"UTSA":{"38x24":["user-utsa-38x18.png",38,18],"34x24":["user-utsa-34x16.png",34,16],"26x23":["user-utsa-26x12.png",26,12],"31x24":["user-utsa-31x15.png",31,15],"29x22":["user-utsa-29x14.png",29,14],"25x19":["user-utsa-25x12.png",25,12],"22x20":["user-utsa-22x10.png",22,10],"24x25":["user-utsa-24x11.png",24,11],"30x19":["user-utsa-30x14.png",30,14],"25x22":["user-utsa-25x12.png",25,12],"28x25":["user-utsa-28x13.png",28,13]},"VAL":{"38x24":["user-val-23x24.png",23,24],"34x24":["user-val-23x24.png",23,24],"26x23":["user-val-22x23.png",22,23],"31x24":["user-val-23x24.png",23,24],"29x22":["user-val-21x22.png",21,22],"25x19":["user-val-19x19.png",19,19],"22x20":["user-val-20x20.png",20,20],"24x25":["user-val-24x25.png",24,25],"30x19":["user-val-19x19.png",19,19],"25x22":["user-val-21x22.png",21,22],"28x25":["user-val-24x25.png",24,25]},"VAND":{"38x24":["user-vand-34x24.png",34,24],"34x24":["user-vand-34x24.png",34,24],"26x23":["user-vand-26x18.png",26,18],"31x24":["user-vand-31x22.png",31,22],"29x22":["user-vand-29x20.png",29,20],"25x19":["user-vand-25x18.png",25,18],"22x20":["user-vand-22x16.png",22,16],"24x25":["user-vand-24x17.png",24,17],"30x19":["user-vand-27x19.png",27,19],"25x22":["user-vand-25x18.png",25,18],"28x25":["user-vand-28x20.png",28,20]},"VCU":{"38x24":["user-vcu-38x16.png",38,16],"34x24":["user-vcu-34x14.png",34,14],"26x23":["user-vcu-26x11.png",26,11],"31x24":["user-vcu-31x13.png",31,13],"29x22":["user-vcu-29x12.png",29,12],"25x19":["user-vcu-25x11.png",25,11],"22x20":["user-vcu-22x9.png",22,9],"24x25":["user-vcu-24x10.png",24,10],"30x19":["user-vcu-30x13.png",30,13],"25x22":["user-vcu-25x11.png",25,11],"28x25":["user-vcu-28x12.png",28,12]},"UVM":{"38x24":["user-uvm-25x24.png",25,24],"34x24":["user-uvm-25x24.png",25,24],"26x23":["user-uvm-24x23.png",24,23],"31x24":["user-uvm-25x24.png",25,24],"29x22":["user-uvm-23x22.png",23,22],"25x19":["user-uvm-20x19.png",20,19],"22x20":["user-uvm-21x20.png",21,20],"24x25":["user-uvm-24x23.png",24,23],"30x19":["user-uvm-20x19.png",20,19],"25x22":["user-uvm-23x22.png",23,22],"28x25":["user-uvm-26x25.png",26,25]},"NOVA":{"38x24":["user-nova-27x24.png",27,24],"34x24":["user-nova-27x24.png",27,24],"26x23":["user-nova-26x23.png",26,23],"31x24":["user-nova-27x24.png",27,24],"29x22":["user-nova-25x22.png",25,22],"25x19":["user-nova-21x19.png",21,19],"22x20":["user-nova-22x20.png",22,20],"24x25":["user-nova-24x21.png",24,21],"30x19":["user-nova-21x19.png",21,19],"25x22":["user-nova-25x22.png",25,22],"28x25":["user-nova-28x25.png",28,25]},"UVA":{"38x24":["user-uva-31x24.png",31,24],"34x24":["user-uva-31x24.png",31,24],"26x23":["user-uva-26x20.png",26,20],"31x24":["user-uva-31x24.png",31,24],"29x22":["user-uva-28x22.png",28,22],"25x19":["user-uva-24x19.png",24,19],"22x20":["user-uva-22x17.png",22,17],"24x25":["user-uva-24x19.png",24,19],"30x19":["user-uva-24x19.png",24,19],"25x22":["user-uva-25x20.png",25,20],"28x25":["user-uva-28x22.png",28,22]},"VT":{"38x24":["user-vt-38x18.png",38,18],"34x24":["user-vt-34x16.png",34,16],"26x23":["user-vt-26x12.png",26,12],"31x24":["user-vt-31x15.png",31,15],"29x22":["user-vt-29x14.png",29,14],"25x19":["user-vt-25x12.png",25,12],"22x20":["user-vt-22x11.png",22,11],"24x25":["user-vt-24x11.png",24,11],"30x19":["user-vt-30x14.png",30,14],"25x22":["user-vt-25x12.png",25,12],"28x25":["user-vt-28x13.png",28,13]},"VMI":{"38x24":["user-vmi-23x24.png",23,24],"34x24":["user-vmi-23x24.png",23,24],"26x23":["user-vmi-22x23.png",22,23],"31x24":["user-vmi-23x24.png",23,24],"29x22":["user-vmi-21x22.png",21,22],"25x19":["user-vmi-18x19.png",18,19],"22x20":["user-vmi-19x20.png",19,20],"24x25":["user-vmi-24x25.png",24,25],"30x19":["user-vmi-18x19.png",18,19],"25x22":["user-vmi-21x22.png",21,22],"28x25":["user-vmi-24x25.png",24,25]},"WAG":{"38x24":["user-wag-38x19.png",38,19],"34x24":["user-wag-34x17.png",34,17],"26x23":["user-wag-26x13.png",26,13],"31x24":["user-wag-31x15.png",31,15],"29x22":["user-wag-29x14.png",29,14],"25x19":["user-wag-25x12.png",25,12],"22x20":["user-wag-22x11.png",22,11],"24x25":["user-wag-24x12.png",24,12],"30x19":["user-wag-30x15.png",30,15],"25x22":["user-wag-25x12.png",25,12],"28x25":["user-wag-28x14.png",28,14]},"WAKE":{"38x24":["user-wake-34x24.png",34,24],"34x24":["user-wake-34x24.png",34,24],"26x23":["user-wake-26x18.png",26,18],"31x24":["user-wake-31x22.png",31,22],"29x22":["user-wake-29x21.png",29,21],"25x19":["user-wake-25x18.png",25,18],"22x20":["user-wake-22x16.png",22,16],"24x25":["user-wake-24x17.png",24,17],"30x19":["user-wake-27x19.png",27,19],"25x22":["user-wake-25x18.png",25,18],"28x25":["user-wake-28x20.png",28,20]},"WASH":{"38x24":["user-wash-35x24.png",35,24],"34x24":["user-wash-34x23.png",34,23],"26x23":["user-wash-26x18.png",26,18],"31x24":["user-wash-31x21.png",31,21],"29x22":["user-wash-29x20.png",29,20],"25x19":["user-wash-25x17.png",25,17],"22x20":["user-wash-22x15.png",22,15],"24x25":["user-wash-24x16.png",24,16],"30x19":["user-wash-28x19.png",28,19],"25x22":["user-wash-25x17.png",25,17],"28x25":["user-wash-28x19.png",28,19]},"WSU":{"38x24":["user-wsu-25x24.png",25,24],"34x24":["user-wsu-25x24.png",25,24],"26x23":["user-wsu-24x23.png",24,23],"31x24":["user-wsu-25x24.png",25,24],"29x22":["user-wsu-23x22.png",23,22],"25x19":["user-wsu-20x19.png",20,19],"22x20":["user-wsu-21x20.png",21,20],"24x25":["user-wsu-24x23.png",24,23],"30x19":["user-wsu-20x19.png",20,19],"25x22":["user-wsu-23x22.png",23,22],"28x25":["user-wsu-26x25.png",26,25]},"WEB":{"38x24":["user-web-34x24.png",34,24],"34x24":["user-web-34x24.png",34,24],"26x23":["user-web-26x19.png",26,19],"31x24":["user-web-31x22.png",31,22],"29x22":["user-web-29x21.png",29,21],"25x19":["user-web-25x18.png",25,18],"22x20":["user-web-22x16.png",22,16],"24x25":["user-web-24x17.png",24,17],"30x19":["user-web-27x19.png",27,19],"25x22":["user-web-25x18.png",25,18],"28x25":["user-web-28x20.png",28,20]},"WGA":{"38x24":["user-wga-35x24.png",35,24],"34x24":["user-wga-34x24.png",34,24],"26x23":["user-wga-26x18.png",26,18],"31x24":["user-wga-31x22.png",31,22],"29x22":["user-wga-29x20.png",29,20],"25x19":["user-wga-25x17.png",25,17],"22x20":["user-wga-22x15.png",22,15],"24x25":["user-wga-24x17.png",24,17],"30x19":["user-wga-27x19.png",27,19],"25x22":["user-wga-25x17.png",25,17],"28x25":["user-wga-28x19.png",28,19]},"WVU":{"38x24":["user-wvu-25x24.png",25,24],"34x24":["user-wvu-25x24.png",25,24],"26x23":["user-wvu-24x23.png",24,23],"31x24":["user-wvu-25x24.png",25,24],"29x22":["user-wvu-23x22.png",23,22],"25x19":["user-wvu-20x19.png",20,19],"22x20":["user-wvu-21x20.png",21,20],"24x25":["user-wvu-24x23.png",24,23],"30x19":["user-wvu-20x19.png",20,19],"25x22":["user-wvu-23x22.png",23,22],"28x25":["user-wvu-27x25.png",27,25]},"WCU":{"38x24":["user-wcu-29x24.png",29,24],"34x24":["user-wcu-29x24.png",29,24],"26x23":["user-wcu-26x21.png",26,21],"31x24":["user-wcu-29x24.png",29,24],"29x22":["user-wcu-27x22.png",27,22],"25x19":["user-wcu-23x19.png",23,19],"22x20":["user-wcu-22x18.png",22,18],"24x25":["user-wcu-24x20.png",24,20],"30x19":["user-wcu-23x19.png",23,19],"25x22":["user-wcu-25x20.png",25,20],"28x25":["user-wcu-28x23.png",28,23]},"WIU":{"38x24":["user-wiu-25x24.png",25,24],"34x24":["user-wiu-25x24.png",25,24],"26x23":["user-wiu-24x23.png",24,23],"31x24":["user-wiu-25x24.png",25,24],"29x22":["user-wiu-23x22.png",23,22],"25x19":["user-wiu-20x19.png",20,19],"22x20":["user-wiu-21x20.png",21,20],"24x25":["user-wiu-24x23.png",24,23],"30x19":["user-wiu-20x19.png",20,19],"25x22":["user-wiu-23x22.png",23,22],"28x25":["user-wiu-26x25.png",26,25]},"WKU":{"38x24":["user-wku-33x24.png",33,24],"34x24":["user-wku-33x24.png",33,24],"26x23":["user-wku-26x19.png",26,19],"31x24":["user-wku-31x23.png",31,23],"29x22":["user-wku-29x21.png",29,21],"25x19":["user-wku-25x18.png",25,18],"22x20":["user-wku-22x16.png",22,16],"24x25":["user-wku-24x18.png",24,18],"30x19":["user-wku-26x19.png",26,19],"25x22":["user-wku-25x18.png",25,18],"28x25":["user-wku-28x21.png",28,21]},"WMU":{"38x24":["user-wmu-24x24.png",24,24],"34x24":["user-wmu-24x24.png",24,24],"26x23":["user-wmu-23x23.png",23,23],"31x24":["user-wmu-24x24.png",24,24],"29x22":["user-wmu-22x22.png",22,22],"25x19":["user-wmu-19x19.png",19,19],"22x20":["user-wmu-20x20.png",20,20],"24x25":["user-wmu-24x24.png",24,24],"30x19":["user-wmu-19x19.png",19,19],"25x22":["user-wmu-22x22.png",22,22],"28x25":["user-wmu-25x25.png",25,25]},"WICH":{"38x24":["user-wich-29x24.png",29,24],"34x24":["user-wich-29x24.png",29,24],"26x23":["user-wich-26x22.png",26,22],"31x24":["user-wich-29x24.png",29,24],"29x22":["user-wich-26x22.png",26,22],"25x19":["user-wich-23x19.png",23,19],"22x20":["user-wich-22x18.png",22,18],"24x25":["user-wich-24x20.png",24,20],"30x19":["user-wich-23x19.png",23,19],"25x22":["user-wich-25x21.png",25,21],"28x25":["user-wich-28x23.png",28,23]},"WM":{"38x24":["user-wm-29x24.png",29,24],"34x24":["user-wm-29x24.png",29,24],"26x23":["user-wm-26x21.png",26,21],"31x24":["user-wm-29x24.png",29,24],"29x22":["user-wm-27x22.png",27,22],"25x19":["user-wm-23x19.png",23,19],"22x20":["user-wm-22x18.png",22,18],"24x25":["user-wm-24x20.png",24,20],"30x19":["user-wm-23x19.png",23,19],"25x22":["user-wm-25x20.png",25,20],"28x25":["user-wm-28x23.png",28,23]},"WIN":{"38x24":["user-win-27x24.png",27,24],"34x24":["user-win-27x24.png",27,24],"26x23":["user-win-26x23.png",26,23],"31x24":["user-win-27x24.png",27,24],"29x22":["user-win-25x22.png",25,22],"25x19":["user-win-22x19.png",22,19],"22x20":["user-win-22x19.png",22,19],"24x25":["user-win-24x21.png",24,21],"30x19":["user-win-22x19.png",22,19],"25x22":["user-win-25x22.png",25,22],"28x25":["user-win-28x25.png",28,25]},"WOF":{"38x24":["user-wof-22x24.png",22,24],"34x24":["user-wof-22x24.png",22,24],"26x23":["user-wof-21x23.png",21,23],"31x24":["user-wof-22x24.png",22,24],"29x22":["user-wof-20x22.png",20,22],"25x19":["user-wof-17x19.png",17,19],"22x20":["user-wof-18x20.png",18,20],"24x25":["user-wof-23x25.png",23,25],"30x19":["user-wof-17x19.png",17,19],"25x22":["user-wof-20x22.png",20,22],"28x25":["user-wof-23x25.png",23,25]},"WYO":{"38x24":["user-wyo-14x24.png",14,24],"34x24":["user-wyo-14x24.png",14,24],"26x23":["user-wyo-13x23.png",13,23],"31x24":["user-wyo-14x24.png",14,24],"29x22":["user-wyo-13x22.png",13,22],"25x19":["user-wyo-11x19.png",11,19],"22x20":["user-wyo-12x20.png",12,20],"24x25":["user-wyo-14x25.png",14,25],"30x19":["user-wyo-11x19.png",11,19],"25x22":["user-wyo-13x22.png",13,22],"28x25":["user-wyo-14x25.png",14,25]},"XAV":{"38x24":["user-xav-30x24.png",30,24],"34x24":["user-xav-30x24.png",30,24],"26x23":["user-xav-26x21.png",26,21],"31x24":["user-xav-30x24.png",30,24],"29x22":["user-xav-28x22.png",28,22],"25x19":["user-xav-24x19.png",24,19],"22x20":["user-xav-22x18.png",22,18],"24x25":["user-xav-24x19.png",24,19],"30x19":["user-xav-24x19.png",24,19],"25x22":["user-xav-25x20.png",25,20],"28x25":["user-xav-28x22.png",28,22]},"YALE":{"38x24":["user-yale-26x24.png",26,24],"34x24":["user-yale-26x24.png",26,24],"26x23":["user-yale-25x23.png",25,23],"31x24":["user-yale-26x24.png",26,24],"29x22":["user-yale-24x22.png",24,22],"25x19":["user-yale-21x19.png",21,19],"22x20":["user-yale-22x20.png",22,20],"24x25":["user-yale-24x22.png",24,22],"30x19":["user-yale-21x19.png",21,19],"25x22":["user-yale-24x22.png",24,22],"28x25":["user-yale-27x25.png",27,25]},"YSU":{"38x24":["user-ysu-38x24.png",38,24],"34x24":["user-ysu-34x21.png",34,21],"26x23":["user-ysu-26x16.png",26,16],"31x24":["user-ysu-31x20.png",31,20],"29x22":["user-ysu-29x18.png",29,18],"25x19":["user-ysu-25x16.png",25,16],"22x20":["user-ysu-22x14.png",22,14],"24x25":["user-ysu-24x15.png",24,15],"30x19":["user-ysu-30x19.png",30,19],"25x22":["user-ysu-25x16.png",25,16],"28x25":["user-ysu-28x18.png",28,18]}})
TEAM_LOGO_BOUNDS.update({"SFPA":[26,23,0,4,26,19],"SJU":[26,23,5,0,21,23],"STMN":[26,23,2,0,23,23],"STAN":[26,23,5,0,20,23],"SFA":[26,23,1,0,25,23],"STET":[26,23,1,0,24,23],"STO":[26,23,0,2,26,21],"STBK":[26,23,0,2,26,21],"SYR":[26,23,4,0,21,23],"TAR":[26,23,1,0,25,23],"TCU":[26,23,0,5,26,18],"TEM":[26,23,3,0,23,23],"TENN":[26,23,1,0,24,23],"TNTC":[26,23,0,1,26,21],"TAMU":[26,23,1,0,25,23],"AMCC":[26,23,0,0,25,23],"TXSO":[26,23,1,0,25,23],"TXST":[26,23,3,0,23,23],"TTU":[26,23,3,0,23,23],"CIT":[26,23,0,0,26,23],"TOL":[26,23,1,4,26,19],"TOW":[26,23,0,2,26,20],"TROY":[26,23,3,0,23,23],"TULN":[26,23,0,2,26,21],"TLSA":[26,23,0,1,26,22],"UAB":[26,23,0,0,26,22],"UALB":[26,23,7,0,19,23],"UCD":[26,23,0,2,26,21],"UCI":[26,23,2,0,24,23],"UCR":[26,23,1,0,25,23],"UCSD":[26,23,1,0,24,23],"UCSB":[26,23,0,2,26,20],"UCF":[26,23,0,1,26,22],"UCLA":[26,23,0,5,26,18],"CONN":[26,23,4,0,22,23],"UIC":[26,23,0,6,26,17],"ULM":[26,23,0,2,26,20],"UML":[26,23,0,5,26,17],"UMBC":[26,23,0,0,25,23],"UNCA":[26,23,0,3,26,20],"UNCG":[26,23,0,1,26,21],"UNCW":[26,23,3,0,23,23],"UNLV":[26,23,0,4,26,19],"USC":[26,23,2,0,24,23],"UTA":[26,23,0,1,26,21],"UTM":[26,23,0,1,26,22],"RGV":[26,23,0,1,26,21],"UTAH":[26,23,0,0,25,23],"USU":[26,23,0,1,26,21],"UTU":[26,23,0,2,26,20],"UVU":[26,23,0,2,26,20],"UTEP":[26,23,1,0,24,23],"UTSA":[26,23,0,5,26,17],"VAL":[26,23,2,0,24,23],"VAND":[26,23,0,2,26,20],"VCU":[26,23,0,6,26,17],"UVM":[26,23,1,0,25,23],"NOVA":[26,23,0,0,26,23],"UVA":[26,23,0,1,26,21],"VT":[26,23,0,5,26,17],"VMI":[26,23,2,0,24,23],"WAG":[26,23,1,5,26,18],"WAKE":[26,23,0,2,26,20],"WASH":[26,23,0,2,26,20],"WSU":[26,23,1,0,25,23],"WEB":[26,23,0,2,26,21],"WGA":[26,23,0,2,26,20],"WVU":[26,23,1,0,25,23],"WCU":[26,23,0,1,26,22],"WIU":[26,23,1,0,25,23],"WKU":[26,23,0,2,26,21],"WMU":[26,23,1,0,24,23],"WICH":[26,23,0,0,26,22],"WM":[26,23,0,1,26,22],"WIN":[26,23,0,0,26,23],"WOF":[26,23,2,0,23,23],"WYO":[26,23,6,0,19,23],"XAV":[26,23,0,1,26,22],"YALE":[26,23,0,0,25,23],"YSU":[26,23,0,3,26,19]})

USER_LOGO_FRAMES.update({"IOWA":{"38x24":["user-iowa-solid-oct26-37x24.png",37,24],"34x24":["user-iowa-solid-oct26-34x22.png",34,22],"26x23":["user-iowa-solid-oct26-26x17.png",26,17],"31x24":["user-iowa-solid-oct26-31x20.png",31,20],"29x22":["user-iowa-solid-oct26-29x19.png",29,19],"25x19":["user-iowa-solid-oct26-25x16.png",25,16],"22x20":["user-iowa-solid-oct26-22x14.png",22,14],"24x25":["user-iowa-solid-oct26-24x16.png",24,16],"30x19":["user-iowa-solid-oct26-29x19.png",29,19],"25x22":["user-iowa-solid-oct26-25x16.png",25,16],"28x25":["user-iowa-solid-oct26-28x18.png",28,18]}})
TEAM_LOGO_BOUNDS.update({"IOWA":[26,23,0,3,26,20]})

# Official NDSU head-only mark; previous wordmark frames remain archived.
USER_LOGO_FRAMES.update({"NDSU":{"38x24":["user-ndsu-textfree-oct27-22x24.png",22,24],"34x24":["user-ndsu-textfree-oct27-22x24.png",22,24],"26x23":["user-ndsu-textfree-oct27-21x23.png",21,23],"31x24":["user-ndsu-textfree-oct27-22x24.png",22,24],"29x22":["user-ndsu-textfree-oct27-20x22.png",20,22],"25x19":["user-ndsu-textfree-oct27-18x19.png",18,19],"22x20":["user-ndsu-textfree-oct27-18x20.png",18,20],"24x25":["user-ndsu-textfree-oct27-23x25.png",23,25],"30x19":["user-ndsu-textfree-oct27-18x19.png",18,19],"25x22":["user-ndsu-textfree-oct27-20x22.png",20,22],"28x25":["user-ndsu-textfree-oct27-23x25.png",23,25]}})
TEAM_LOGO_BOUNDS.update({"NDSU":[26,23,2,0,23,23]})

# Arizona replacement supplied and approved October 29; native proportional PNGs.
USER_LOGO_FRAMES.update({"ARIZ":{"38x24":["user-ariz-26x24.png",26,24],"34x24":["user-ariz-26x24.png",26,24],"26x23":["user-ariz-25x23.png",25,23],"31x24":["user-ariz-26x24.png",26,24],"29x22":["user-ariz-24x22.png",24,22],"25x19":["user-ariz-21x19.png",21,19],"22x20":["user-ariz-22x20.png",22,20],"24x25":["user-ariz-24x22.png",24,22],"30x19":["user-ariz-21x19.png",21,19],"25x22":["user-ariz-24x22.png",24,22],"28x25":["user-ariz-27x25.png",27,25]}})
TEAM_LOGO_BOUNDS.update({"ARIZ":[26,23,0,0,25,23]})

# Auburn's supplied October 29 source uses the same proportional native frames.
USER_LOGO_FRAMES.update({"AUB":{"38x24":["user-aub-27x24.png",27,24],"34x24":["user-aub-27x24.png",27,24],"26x23":["user-aub-26x23.png",26,23],"31x24":["user-aub-27x24.png",27,24],"29x22":["user-aub-25x22.png",25,22],"25x19":["user-aub-21x19.png",21,19],"22x20":["user-aub-22x19.png",22,19],"24x25":["user-aub-24x21.png",24,21],"30x19":["user-aub-21x19.png",21,19],"25x22":["user-aub-25x22.png",25,22],"28x25":["user-aub-28x25.png",28,25]}})
TEAM_LOGO_BOUNDS.update({"AUB":[26,23,0,0,26,23]})

def draw_user_logo_native(c, team, x, y, w, h, align = "center"):
    frame = USER_LOGO_FRAMES[team][str(w) + "x" + str(h)]
    inset = w - frame[1] if align == "right" else 0 if align == "left" else (w - frame[1]) // 2
    c.image(frame[0], x + inset, y + (h - frame[2]) // 2)

def draw_team_logo(c, team, x, y, w, h):
    if team in USER_LOGO_FRAMES:
        draw_user_logo_native(c, team, x, y, w, h)
        return
    if team == "SMC":
        draw_smc_native(c, x, y, w, h)
        return
    if team == "MRMK":
        draw_mrmk_native(c, x, y, w, h)
        return
    c.image(TEAM_LOGO_FILES[team], x, y, w = w, h = h)

# Direct-source, proportional native frames. Keep the original geometry and
# colors; do not enlarge a small mascot raster or redraw the user's lettering.
MRMK_NATIVE_FRAMES = {
    "38x24": ["mrmk-clean-31x24.png", 31, 24],
    "34x24": ["mrmk-clean-31x24.png", 31, 24],
    "26x23": ["mrmk-clean-26x20.png", 26, 20],
    "31x24": ["mrmk-clean-31x24.png", 31, 24],
    "29x22": ["mrmk-clean-28x22.png", 28, 22],
    "25x19": ["mrmk-clean-24x19.png", 24, 19],
    "22x20": ["mrmk-clean-22x17.png", 22, 17],
    "24x25": ["mrmk-clean-24x19.png", 24, 19],
    "30x19": ["mrmk-clean-24x19.png", 24, 19],
    "25x22": ["mrmk-clean-25x19.png", 25, 19],
}

def draw_mrmk_native(c, x, y, w, h, align = "center"):
    frame = MRMK_NATIVE_FRAMES[str(w) + "x" + str(h)]
    inset = w - frame[1] if align == "right" else 0 if align == "left" else (w - frame[1]) // 2
    c.image(frame[0], x + inset, y + (h - frame[2]) // 2)

RESUME_TEAM_IDS = {"ACU":"2000","AF":"2005","AKR":"2006","AAMU":"2010","BAMA":"333","ALST":"2011","ALCN":"2016","AMER":"44","APP":"2026","ASU":"9","ARIZ":"12","ARK":"8","ARST":"2032","UAPB":"2029","ARMY":"349","AUB":"2","APSU":"2046","BALL":"2050","BAY":"239","BELL":"91","BEL":"2057","BCU":"2065","BING":"2066","BOIS":"68","BC":"103","BU":"104","BGSU":"189","BRAD":"71","BRWN":"225","BRY":"2803","BUCK":"2083","BUF":"2084","BTLR":"2086","BYU":"252","CP":"13","CSUB":"2934","CSUF":"2239","CSUN":"2463","CBU":"2856","CAL":"25","CAM":"2097","CAN":"2099","UCA":"2110","CCSU":"2115","CMU":"2117","COFC":"232","CHSO":"2127","CLT":"2429","UTC":"236","CHST":"2130","CIN":"2132","CLEM":"228","CLE":"325","CCU":"324","COLG":"2142","COLO":"38","CSU":"36","COLU":"171","COPP":"2154","COR":"172","CREI":"156","DART":"159","DAV":"2166","DAY":"2168","DEL":"48","DSU":"2169","DEN":"2172","DEP":"305","DETM":"2174","DRKE":"2181","DREX":"2182","DUKE":"150","DUQ":"2184","ECU":"151","ETSU":"2193","ETAM":"2837","EIU":"2197","EKU":"2198","EMU":"2199","EWU":"331","ELON":"2210","EVAN":"339","FAIR":"2217","FDU":"161","FAMU":"50","FAU":"2226","FLA":"57","FGCU":"526","FIU":"2229","FSU":"52","FOR":"2230","FRES":"278","FUR":"231","GWEB":"2241","GMU":"2244","GW":"45","GTWN":"46","UGA":"61","GASO":"290","GAST":"2247","GT":"59","GONZ":"2250","GRAM":"2755","GCU":"2253","GB":"2739","HAMP":"2261","HARV":"108","HAW":"62","HPU":"2272","HOF":"2275","HC":"107","HCU":"2277","HOU":"248","HOW":"47","IDST":"304","IDHO":"70","ILL":"356","ILST":"2287","UIW":"2916","IND":"84","INST":"282","IONA":"314","IOWA":"2294","ISU":"66","IUIN":"85","JKST":"2296","JAX":"294","JXST":"55","JMU":"256","KC":"140","KU":"2305","KSU":"2306","KENN":"338","KENT":"2309","UK":"96","LAS":"2325","LAF":"322","LAM":"2320","LEM":"2330","LEH":"2329","LIB":"2335","LIN":"2815","LIP":"288","LR":"2031","LBSU":"299","LIU":"112358","LONG":"2344","UL":"309","LT":"2348","LOU":"97","LUC":"2350","LMD":"2352","LMU":"2351","NOLA":"2443","LSU":"99","ME":"311","MAN":"2363","MRST":"2368","MARQ":"269","MRSH":"276","UMES":"2379","MD":"120","MASS":"113","MCN":"2377","MEM":"235","MER":"2382","MERC":"2385","MRMK":"2771","MOH":"193","MIA":"2390","MSU":"127","MICH":"130","MTSU":"2393","MILW":"270","MINN":"135","MSST":"344","MVSU":"2400","MOST":"2623","MIZ":"142","MONM":"2405","MONT":"149","MTST":"147","MORE":"2413","MORG":"2415","MSM":"116","MUR":"93","NAVY":"2426","NCST":"152","NEB":"158","NEV":"2440","UNH":"160","NHVN":"2441","UNM":"167","NMSU":"166","NIA":"315","NICH":"2447","NJIT":"2885","NORF":"2450","UNA":"2453","NCAT":"2448","NCCU":"2428","UNC":"153","UND":"155","NDSU":"2449","UNF":"2454","UNT":"249","NE":"111","NAU":"2464","UNCO":"2458","NIU":"2459","UNI":"2460","NKU":"94","NWST":"2466","NU":"77","ND":"87","OAK":"2473","OHIO":"195","OSU":"194","OU":"201","OKST":"197","ODU":"295","MISS":"145","OMA":"2437","ORU":"198","ORE":"2483","ORST":"204","PAC":"279","PSU":"213","PENN":"219","PEPP":"2492","PITT":"221","PORT":"2501","PRST":"2502","PV":"2504","PRES":"2506","PRIN":"163","PROV":"2507","PUR":"2509","PFW":"2870","QUC":"2511","QUIN":"2514","RAD":"2515","URI":"227","RICE":"242","RICH":"257","RID":"2520","RMU":"2523","RUTG":"164","SAC":"16","SHU":"2529","SFPA":"2598","JOES":"2603","SLU":"139","SMC":"2608","SPU":"2612","SHSU":"2534","SAM":"2535","SDSU":"21","USD":"301","SF":"2539","SJSU":"23","SCU":"2541","SELA":"2545","SEA":"2547","HALL":"2550","SIE":"2561","SIUE":"2565","SMU":"2567","USA":"6","SC":"2579","SCST":"2569","UPST":"2908","SDAK":"233","SDST":"2571","USF":"58","SEMO":"2546","SIU":"79","USI":"88","SOU":"2582","USM":"2572","SUU":"253","SBU":"179","SJU":"2599","STMN":"2900","STAN":"24","SFA":"2617","STET":"56","STO":"284","STBK":"2619","SYR":"183","TAR":"2627","TCU":"2628","TEM":"218","TNST":"2634","TNTC":"2635","TENN":"2633","TAMU":"245","AMCC":"357","TEX":"251","TXSO":"2640","TXST":"326","TTU":"2641","CIT":"2643","TOL":"2649","TOW":"119","TROY":"2653","TULN":"2655","TLSA":"202","UAB":"5","UALB":"399","UCD":"302","UCI":"300","UCR":"27","UCSD":"28","UCSB":"2540","UCF":"2116","UCLA":"26","CONN":"41","UIC":"82","ULM":"2433","UML":"2349","UMBC":"2378","UNCA":"2427","UNCG":"2430","UNCW":"350","UNLV":"2439","USC":"30","UTA":"250","UTM":"2630","RGV":"292","USU":"328","UTU":"3101","UTAH":"254","UVU":"3084","UTEP":"2638","UTSA":"2636","VAL":"2674","VAND":"238","VCU":"2670","UVM":"261","NOVA":"222","UVA":"258","VT":"259","VMI":"2678","WAG":"2681","WAKE":"154","WASH":"264","WSU":"265","WEB":"2692","WGA":"2698","WVU":"277","WCU":"2717","WIU":"2710","WKU":"98","WMU":"2711","WICH":"2724","WM":"2729","WIN":"2737","WIS":"275","WOF":"2747","WRST":"2750","WYO":"2751","XAV":"2752","YALE":"43","YSU":"2754"}
RESUME_AP_URL = "https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/rankings?season=2027"
RESUME_NET_URL = "https://www.ncaa.com/rankings/basketball-men/d1/ncaa-mens-basketball-net-rankings"
RESUME_WAB_URL = "https://www.ncaa.com/rankings/basketball-men/d1/wab-ranking"
RESUME_TORVIK_URL = "https://barttorvik.com/2027_team_results.csv"
# Explicit NCAA table labels, independent of our compact display names.
# Do not fuzzy-match Miami campuses or collapse similarly named schools.
RESUME_NCAA_NAMES = {
    "MIA": "Miami (FL)", "UNCW": "UNCW", "UCA": "Central Ark.", "ALCN": "Alcorn",
    "AMER": "American", "UAPB": "Ark.-Pine Bluff", "ARMY": "Army West Point", "BU": "Boston U.",
    "CSUB": "CSU Bakersfield", "CSUN": "CSUN", "CCSU": "Central Conn. St.", "CMU": "Central Mich.",
    "COFC": "Col. of Charleston", "CHSO": "Charleston So.", "ETSU": "ETSU", "EIU": "Eastern Ill.",
    "EKU": "Eastern Ky.", "EMU": "Eastern Mich.", "EWU": "Eastern Wash.", "FDU": "FDU",
    "FAU": "Fla. Atlantic", "FGCU": "FGCU", "FIU": "FIU", "GASO": "Ga. Southern",
    "UIW": "UIW", "IUIN": "IU Indy", "LAM": "Lamar University", "LIU": "LIU", "LMU": "LMU (CA)",
    "NOLA": "New Orleans", "LSU": "LSU", "UMES": "UMES", "MTSU": "Middle Tenn.",
    "MVSU": "Mississippi Val.", "NJIT": "NJIT", "UNA": "North Ala.", "NCAT": "N.C. A&T",
    "NCCU": "N.C. Central", "NAU": "Northern Ariz.", "UNCO": "Northern Colo.", "NIU": "NIU",
    "UNI": "UNI", "NKU": "Northern Ky.", "PENN": "Penn", "PV": "Prairie View", "QUC": "Queens (NC)",
    "SMC": "Saint Mary's (CA)", "SJSU": "San Jose St.", "SELA": "Southeastern La.", "SIUE": "SIUE",
    "UPST": "USC Upstate", "USF": "South Fla.", "SEMO": "Southeast Mo. St.", "SIU": "Southern Ill.",
    "USI": "Southern Ind.", "SOU": "Southern U.", "STMN": "St. Thomas (MN)", "SFA": "SFA", "TCU": "TCU",
    "AMCC": "A&M-Corpus Christi", "UAB": "UAB", "UIC": "UIC", "ULM": "ULM", "UMBC": "UMBC",
    "UNLV": "UNLV", "RGV": "UTRGV", "UTEP": "UTEP", "UTSA": "UTSA", "VMI": "VMI",
    "WGA": "West Ga.", "WCU": "Western Caro.", "WIU": "Western Ill.", "WKU": "Western Ky.", "WMU": "Western Mich.",
}

RESUME_TORVIK_NAMES = {
    "CONN": "Connecticut", "MCN": "McNeese St.", "MISS": "Mississippi", "APP": "Appalachian St.",
    "CBU": "Cal Baptist", "GRAM": "Grambling St.", "KC": "UMKC", "LMD": "Loyola MD",
    "NICH": "Nicholls St.", "OMA": "Nebraska Omaha", "QUC": "Queens", "SHSU": "Sam Houston St.",
    "SELA": "Southeastern Louisiana", "SEA": "Seattle", "AMCC": "Texas A&M Corpus Chris",
    "UALB": "Albany", "UIC": "Illinois Chicago", "ULM": "Louisiana Monroe", "UTM": "Tennessee Martin",
}

def resume_text(html):
    text = ""
    for piece in html.split("<"):
        text += piece.split(">")[-1]
    return text.replace("&amp;", "&").replace("&#039;", "'").replace("&#39;", "'").replace("&#x27;", "'").replace("&apos;", "'").replace("&nbsp;", " ").strip()

def resume_normalize(value):
    value = value.upper().replace("(NY)", "").replace("&", " AND ").replace("'", "").replace(".", "")
    clean = ""
    for ch in value.elems():
        clean += ch if ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 " else " "
    clean = " ".join([word for word in clean.split(" ") if word])
    if clean.endswith(" ST"): clean = clean[:-3] + " STATE"
    return clean.replace(" ST ", " STATE ")

def resume_season(year):
    return str(int(year) - 1)[2:] + "-" + str(year)[2:]

def resume_source_season(stamp):
    # Basketball uses its ending year: Oct 2026 and Apr 2027 are 26-27.
    if len(stamp) >= 10 and stamp[4:5] == "-" and stamp[7:8] == "-":
        year, month = stamp[:4], stamp[5:7]
        if year.isdigit() and month.isdigit() and int(month) >= 1 and int(month) <= 12:
            return resume_season(int(year) + (1 if int(month) >= 7 else 0))
        return "--"
    words = [word for word in stamp.upper().replace(".", "").replace(",", "").split() if word]
    months = {"JAN": 1, "FEB": 2, "MAR": 3, "APR": 4, "MAY": 5, "JUN": 6, "JUL": 7, "AUG": 8, "SEP": 9, "OCT": 10, "NOV": 11, "DEC": 12}
    if len(words) != 3 or words[0][:3] not in months or not words[2].isdigit(): return "--"
    if not words[1].isdigit() or int(words[1]) < 1 or int(words[1]) > 31: return "--"
    return resume_season(int(words[2]) + (1 if months[words[0][:3]] >= 7 else 0))

def resume_ncaa_variants(team):
    # One exact-name policy for NET/Q1/Q2 and WAB. Abbreviated NCAA labels
    # must not depend on which statistic is being read. No fuzzy matching.
    aliases = {"CONN": ["UCONN", "CONNECTICUT"], "MCN": ["MCNEESE", "MCNEESE STATE"], "SJU": ["ST JOHNS"], "UNCW": ["UNC WILMINGTON"], "USC": ["SOUTHERN CALIFORNIA", "USC"], "NCST": ["NC STATE"], "MSU": ["MICHIGAN STATE"]}
    names = [TEAM_NAMES.get(team, team)]
    if team in RESUME_NCAA_NAMES: names.append(RESUME_NCAA_NAMES[team])
    names += aliases.get(team, [])
    variants = []
    for name in names:
        normalized = resume_normalize(name)
        if normalized and normalized not in variants: variants.append(normalized)
    return variants

def resume_wab(html, team):
    # NCAA WAB is wins above bubble, not its rank. Only a dated 2026-27
    # table may populate this season's box; footer years do not count.
    if "Through Games" not in html or "<table" not in html: return {}
    stamp = resume_text(html.split("Through Games")[1].split("<")[0]).upper()
    if resume_source_season(stamp) != "26-27": return {}
    variants = resume_ncaa_variants(team)
    table = html.split("<table")[1].split("</table>")[0]
    headers = [resume_text(cell.split("</th>")[0]).upper() for cell in table.split("<th")[1:] if "</th>" in cell]
    if "SCHOOL" not in headers or "WAB" not in headers: return {}
    school_column = headers.index("SCHOOL")
    wab_column = headers.index("WAB")
    for row in table.split("<tr"):
        cells = [resume_text(cell.split("</td>")[0]) for cell in row.split("<td")[1:]]
        if len(cells) <= max(school_column, wab_column): continue
        if resume_normalize(cells[school_column]) not in variants: continue
        value = cells[wab_column].replace("−", "-").replace("&minus;", "-").strip()
        digits = value[1:] if value.startswith("-") or value.startswith("+") else value
        if len(value) > 7 or digits.count(".") > 1 or not digits.replace(".", "").isdigit(): return {}
        return {"WAB": value, "_WAB_SEASON": "26-27", "_WAB_ASOF": stamp, "_WAB_SOURCE": "NCAA", "_WAB_SCHOOL": cells[school_column]}
    return {}

def resume_csv_row(line):
    cells, cell, quoted, skip = [], "", False, False
    for i in range(len(line)):
        if skip:
            skip = False
            continue
        ch = line[i]
        if ch == '"':
            if quoted and i + 1 < len(line) and line[i + 1] == '"':
                cell += '"'
                skip = True
            else:
                quoted = not quoted
        elif ch == "," and not quoted:
            cells.append(cell.strip())
            cell = ""
        else:
            cell += ch
    if quoted: return []
    return cells + [cell.strip()]

def resume_sos_score(value):
    # Integer fixed point preserves ordering without float/locale differences.
    pieces = value.split(".")
    if len(pieces) > 2 or not pieces[0].isdigit(): return -1
    decimal = pieces[1] if len(pieces) == 2 else "0"
    if not decimal.isdigit() or len(decimal) > 18: return -1
    score = int(pieces[0]) * 1000000000000000000 + int((decimal + "000000000000000000")[:18])
    return score if score <= 1000000000000000000 else -1

def resume_played(record):
    parts = record.split("-")
    return len(parts) == 2 and parts[0].isdigit() and parts[1].isdigit() and int(parts[0]) + int(parts[1]) > 0

def resume_torvik_sos(body, team):
    # The season-specific 2027 URL is authoritative for season. This export
    # supplies SOS values, NOT SOS ranks: rank the played `sos` column only.
    # Never substitute `rank` (overall T-Rank) or `Proj. SOS`.
    lines = [line.strip() for line in body.split("\n") if line.strip()]
    if len(lines) < 351 or len(lines) > 401: return {}
    headers = resume_csv_row(lines[0])
    if "team" not in headers or "record" not in headers or "sos" not in headers: return {}
    name_col, record_col, sos_col = headers.index("team"), headers.index("record"), headers.index("sos")
    variants = [resume_normalize(TEAM_NAMES.get(team, team)), resume_normalize(team)]
    for alias in [RESUME_NCAA_NAMES.get(team, ""), RESUME_TORVIK_NAMES.get(team, "")]:
        if alias: variants.append(resume_normalize(alias))
    seen, played, matches = {}, [], []
    for line in lines[1:]:
        cells = resume_csv_row(line)
        if len(cells) != len(headers): return {}
        name = resume_normalize(cells[name_col])
        if not name or name in seen: return {}
        seen[name] = True
        score = resume_sos_score(cells[sos_col])
        if score < 0: return {}
        active = resume_played(cells[record_col])
        if active: played.append(score)
        if name in variants: matches.append([name, score, active])
    if len(matches) != 1 or not matches[0][2] or len(played) == 0: return {}
    score = matches[0][1]
    # All-zero setup exports have no meaningful schedule ordering.
    if max(played) == 0: return {}
    rank = 1 + len([other for other in played if other > score])
    return {"SOS": str(rank), "_SOS_SOURCE": "TORVIK", "_SOS_SEASON": "26-27", "_SOS_VALUE": str(score), "_SOS_SCHOOL": matches[0][0]}

def resume_sor(html, team_id):
    # ESPN silently falls back to last season even when /season/2027 is requested.
    # Require both the selected season and the actual page heading, not the URL.
    if team_id == "" or '"seasonDisplayName":"2026-27"' not in html or "Men's College Basketball Power Index 2026-27" not in html:
        return {}
    if '"table":' not in html:
        return {}
    table = html.split('"table":', 1)[1]
    for entry in table.split('"team":{')[1:]:
        if not entry.startswith('"id":"' + team_id + '"'):
            continue
        if '"name":"sorrank","value":"' not in entry:
            return {}
        value = entry.split('"name":"sorrank","value":"', 1)[1].split('"', 1)[0]
        if value.isdigit() and int(value) >= 1 and int(value) <= 400:
            return {"SOR": value}
    return {}

RESUME_RECORDS_URL = "https://www.espn.com/mens-college-basketball/standings/_/season/2027/group/50"

def resume_record(body, team_id):
    # ESPN's compact HTML includes all 365 overall records in one response.
    # Its full standings API is >6 MB, above the host's 2 MB response limit.
    # Check the actual page season and column definition, not just the URL.
    if team_id == "" or "Men's College Basketball Standings - 2026-27 NCAA Division I Standings" not in body:
        return {}
    if '"season":"2027","group":"50","sport":"basketball","pageType":"standings"' not in body:
        return {}
    marker = '"groups":{"headers":'
    if marker not in body: return {}
    table = body.split(marker, 1)[1].split("</script>", 1)[0]
    if '"total":{' not in table or '"groups":[' not in table: return {}
    header_text = table.split('"total":', 1)[1].split("}", 1)[0] + "}"
    header = safe_json_document(header_text)
    if type(header) != "dict" or header.get("d") != "Overall Record": return {}
    column = header.get("i")
    if type(column) != "int" or column < 0 or column > 30: return {}
    rows = table.split('"groups":[', 1)[1]
    matches = rows.split('"team":{"id":"' + team_id + '"')
    if len(matches) != 2: return {}
    entry = matches[1].split('"team":{', 1)[0]
    if '},"stats":[' not in entry: return {}
    stats = entry.split('},"stats":[', 1)[1]
    if "]" not in stats: return {}
    values = safe_json_document("[" + stats.split("]", 1)[0] + "]")
    if type(values) != "list" or column >= len(values): return {}
    record = values[column]
    if type(record) != "string": return {}
    parts = record.split("-")
    if len(parts) != 2: return {}
    for number in parts:
        if len(number) < 1 or len(number) > 3: return {}
        for digit in number.elems():
            if digit not in "0123456789": return {}
    return {"RECORD": record}

def your_team_resume(team, include_wab = False):
    # Full metrics are requested by the team snapshot and the single R64
    # opponent card, never for each possible future-round opponent.
    # Shared key-free ranking reads are cached for an hour.
    metrics = {}
    seasons = []
    # Full-metric cards use one shared whole-table SOR read, not an AP read.
    if include_wab:
        sor = http.get("https://www.espn.com/mens-college-basketball/bpi/_/view/resume/season/2027/limit/500", ttl_seconds = 3600)
        if sor["status_code"] == 200:
            metrics.update(resume_sor(sor.get("body", ""), RESUME_TEAM_IDS.get(team, "")))
    net = http.get(RESUME_NET_URL, ttl_seconds = 3600)
    if net["status_code"] == 200:
        html = net.get("body", "")
        date = resume_text(html.split("Through Games")[1].split("<")[0]) if "Through Games" in html else ""
        # Unstamped data is never silently treated as this season.
        if resume_source_season(date) == "26-27":
            variants = resume_ncaa_variants(team)
            for row in html.split("<tr"):
                cells = []
                for cell in row.split("<td")[1:]:
                    cells.append(resume_text(cell.split("</td>")[0]))
                if len(cells) >= 11 and resume_normalize(cells[1]) in variants:
                    metrics["NET"] = cells[0]
                    metrics["Q1"] = cells[9]
                    metrics["Q2"] = cells[10]
                    seasons.append("26-27")
                    break
    if len(seasons) == 2 and seasons[0] != seasons[1]:
        # When the new AP poll arrives before NET, do not mix it with last
        # season's resume. Keep only the newer season's fields.
        if seasons[0] > seasons[1]:
            for field in ["NET", "Q1", "Q2"]: metrics[field] = "--"
        else:
            metrics["AP"] = "--"
    metrics["_season"] = max(seasons) if len(seasons) > 0 else "--"
    # Current-season record is separate from the dated NET/AP resume.
    team_id = RESUME_TEAM_IDS.get(team, "")
    if team_id != "":
        record_response = http.get(RESUME_RECORDS_URL, ttl_seconds = 3600)
        if record_response["status_code"] == 200:
            metrics.update(resume_record(record_response.get("body", ""), team_id))
    if include_wab:
        wab = http.get(RESUME_WAB_URL, ttl_seconds = 3600)
        if wab["status_code"] == 200:
            metrics.update(resume_wab(wab.get("body", ""), team))
        sos = http.get(RESUME_TORVIK_URL, ttl_seconds = 3600)
        if sos["status_code"] == 200:
            metrics.update(resume_torvik_sos(sos.get("body", ""), team))
    return metrics

def your_team_opening(_projection, team):
    for group in _projection["OPENING_ROUND_AUTO"] + _projection["OPENING_ROUND_AT_LARGE"]:
        for pair in group:
            if team == pair[1]: return [pair[0], pair[2]]
            if team == pair[2]: return [pair[0], pair[1]]
    return None

# Verified opening-round destinations from Kyle's draft Bracket tab.
YOUR_TEAM_SAMPLE_SLOTS = {'EAST|16': ['QUC', 'LIU'], 'EAST|11': ['OU', 'USU'], 'EAST|10': ['TCU', 'IOWA'], 'EAST|15': ['NDSU', 'UCA'], 'WEST|16': ['MRMK', 'TNST'], 'WEST|11': ['IND', 'SMU'], 'MIDWEST|16': ['HOW', 'UVM'], 'MIDWEST|11': ['VT', 'WIS'], 'MIDWEST|15': ['WRST', 'FUR'], 'SOUTH|16': ['AMER', 'BCU'], 'SOUTH|11': ['MISS', 'WVU'], 'SOUTH|10': ['AUB', 'MD']}

def your_team_slot_options(_projection, seed, region = ""):
    sample = _projection["YOUR_TEAM_SAMPLE_SLOTS"].get(region + "|" + str(seed))
    if sample != None: return [sample]
    options = []
    for group in _projection["OPENING_ROUND_AUTO"] + _projection["OPENING_ROUND_AT_LARGE"]:
        for pair in group:
            if str(pair[0]) == str(seed): options.append([pair[1], pair[2]])
    return options

def your_team_demo_destination(_projection, team):
    for key, pair in _projection["YOUR_TEAM_SAMPLE_SLOTS"].items():
        if team not in pair: continue
        parts = key.split("|")
        for region in _projection["REGION_MATCHUPS"]:
            if region[0] != parts[0]: continue
            for index, game in enumerate(region[4]):
                if game[0] == parts[1] and game[1] == "TBD":
                    return [region[0], index, game[3], game[2], region[4]]
                if game[2] == parts[1] and game[3] == "TBD":
                    return [region[0], index, game[1], game[0], region[4]]
    return None

SWEET_PAIR_FRAMES = {"ACU":["sweet-side-acu-24x18.png",24,18,0,23],"AF":["sweet-side-af-22x22.png",22,22,0,21],"AKR":["sweet-side-akr-24x13.png",24,13,0,23],"AAMU":["sweet-side-aamu-19x23.png",19,23,0,18],"BAMA":["sweet-side-bama-24x23.png",24,23,0,23],"ALST":["sweet-side-alst-24x17.png",24,17,0,23],"ALCN":["sweet-side-alcn-24x22.png",24,22,0,23],"AMER":["sweet-side-amer-23x23.png",23,23,0,22],"APP":["sweet-side-app-20x23.png",20,23,0,19],"ASU":["sweet-side-asu-12x23.png",12,23,0,11],"ARIZ":["sweet-side-ariz-24x21.png",24,21,0,23],"ARK":["sweet-side-ark-24x11.png",24,11,0,23],"ARST":["sweet-side-arst-22x23.png",22,23,0,21],"UAPB":["sweet-side-uapb-24x20.png",24,20,0,23],"ARMY":["sweet-side-army-20x23.png",20,23,0,19],"AUB":["sweet-side-aub-24x21.png",24,21,0,23],"APSU":["sweet-side-apsu-21x23.png",21,23,0,20],"BALL":["sweet-side-ball-16x23.png",16,23,0,15],"BAY":["sweet-side-bay-19x23.png",19,23,0,18],"BELL":["sweet-side-bell-17x23.png",17,23,0,16],"BEL":["sweet-side-bel-24x23.png",24,23,0,23],"BCU":["sweet-side-bcu-22x23.png",22,23,0,21],"BING":["sweet-side-bing-23x23.png",23,23,0,22],"BOIS":["sweet-side-bois-24x20.png",24,20,0,23],"BC":["sweet-side-bc-24x22.png",24,22,0,23],"BU":["sweet-side-bu-24x22.png",24,22,0,23],"BGSU":["sweet-side-bgsu-24x22.png",24,22,0,23],"BRAD":["sweet-side-brad-19x23.png",19,23,0,18],"BRWN":["sweet-side-brwn-19x23.png",19,23,0,18],"BRY":["sweet-side-bry-24x21.png",24,21,0,23],"BUCK":["sweet-side-buck-20x23.png",20,23,0,19],"BUF":["sweet-side-buf-24x23.png",24,23,0,23],"BTLR":["sweet-side-btlr-24x23.png",24,23,0,23],"BYU":["sweet-side-byu-24x15.png",24,15,0,23],"CP":["sweet-side-cp-24x23.png",24,23,0,23],"CSUB":["sweet-side-csub-24x17.png",24,17,0,23],"CSUF":["sweet-side-csuf-24x8.png",24,8,0,23],"CSUN":["sweet-side-csun-20x23.png",20,23,0,19],"CBU":["sweet-side-cbu-24x10.png",24,10,0,23],"CAL":["sweet-side-cal-24x19.png",24,19,0,23],"CAM":["sweet-side-cam-24x14.png",24,14,0,23],"CAN":["sweet-side-can-24x18.png",24,18,0,23],"UCA":["sweet-side-uca-24x22.png",24,22,0,23],"CCSU":["sweet-side-ccsu-24x22.png",24,22,0,23],"CMU":["sweet-side-cmu-24x17.png",24,17,0,23],"COFC":["sweet-side-cofc-20x23.png",20,23,0,19],"CHSO":["sweet-side-chso-24x17.png",24,17,0,23],"CLT":["sweet-side-clt-18x23.png",18,23,0,17],"UTC":["sweet-side-utc-24x21.png",24,21,0,23],"CHST":["sweet-side-chst-24x17.png",24,17,0,23],"CIN":["sweet-side-cin-15x23.png",15,23,0,14],"CLEM":["sweet-side-clem-24x23.png",24,23,0,23],"CLE":["sweet-side-cle-22x23.png",22,23,0,21],"CCU":["sweet-side-ccu-21x23.png",21,23,0,20],"COLG":["sweet-side-colg-24x22.png",24,22,0,23],"COLO":["sweet-side-colo-24x18.png",24,18,0,23],"CSU":["sweet-side-csu-23x23.png",23,23,0,22],"COLU":["sweet-side-colu-20x23.png",20,23,0,19],"COPP":["sweet-side-copp-24x15.png",24,15,0,23],"COR":["sweet-side-cor-22x23.png",22,23,0,21],"CREI":["sweet-side-crei-23x23.png",23,23,0,22],"DART":["sweet-side-dart-18x23.png",18,23,0,17],"DAV":["sweet-side-dav-21x23.png",21,23,0,20],"DAY":["sweet-side-day-24x15.png",24,15,0,23],"DEL":["sweet-side-del-24x17.png",24,17,0,23],"DSU":["sweet-side-dsu-24x18.png",24,18,0,23],"DEN":["sweet-side-den-24x17.png",24,17,0,23],"DEP":["sweet-side-dep-22x23.png",22,23,0,21],"DETM":["sweet-side-detm-24x18.png",24,18,0,23],"DRKE":["sweet-side-drke-21x23.png",21,23,0,20],"DREX":["sweet-side-drex-24x17.png",24,17,0,23],"DUKE":["sweet-side-duke-24x21.png",24,21,0,23],"DUQ":["sweet-side-duq-11x23.png",11,23,0,10],"ECU":["sweet-side-ecu-22x23.png",22,23,0,21],"ETSU":["sweet-side-etsu-23x23.png",23,23,0,22],"ETAM":["sweet-side-etam-23x23.png",23,23,0,22],"EIU":["sweet-side-eiu-24x21.png",24,21,0,23],"EKU":["sweet-side-eku-24x19.png",24,19,0,23],"EMU":["sweet-side-emu-20x23.png",20,23,0,19],"EWU":["sweet-side-ewu-24x23.png",24,23,0,23],"ELON":["sweet-side-elon-24x19.png",24,19,0,23],"EVAN":["sweet-side-evan-24x20.png",24,20,0,23],"FAIR":["sweet-side-fair-24x21.png",24,21,0,23],"FDU":["sweet-side-fdu-24x22.png",24,22,0,23],"FAMU":["sweet-side-famu-24x18.png",24,18,0,23],"FAU":["sweet-side-fau-24x15.png",24,15,0,23],"FLA":["sweet-side-fla-24x15.png",24,15,0,23],"FGCU":["sweet-side-fgcu-24x17.png",24,17,0,23],"FIU":["sweet-side-fiu-20x23.png",20,23,0,19],"FSU":["sweet-side-fsu-23x23.png",23,23,0,22],"FOR":["sweet-side-for-24x22.png",24,22,0,23],"FRES":["sweet-side-fres-24x17.png",24,17,0,23],"FUR":["sweet-side-fur-23x23.png",23,23,0,22],"GWEB":["sweet-side-gweb-24x22.png",24,22,0,23],"GMU":["sweet-side-gmu-23x23.png",23,23,0,22],"GW":["sweet-side-gw-24x17.png",24,17,0,23],"GTWN":["sweet-side-gtwn-23x23.png",23,23,0,22],"UGA":["sweet-side-uga-24x16.png",24,16,0,23],"GASO":["sweet-side-gaso-24x14.png",24,14,0,23],"GAST":["sweet-side-gast-24x20.png",24,20,0,23],"GT":["sweet-side-gt-24x15.png",24,15,0,23],"GONZ":["sweet-side-gonz-24x19.png",24,19,0,23],"GRAM":["sweet-side-gram-24x15.png",24,15,0,23],"GCU":["sweet-side-gcu-24x9.png",24,9,0,23],"GB":["sweet-side-gb-24x19.png",24,19,0,23],"HAMP":["sweet-side-hamp-21x23.png",21,23,0,20],"HARV":["sweet-side-harv-19x23.png",19,23,0,18],"HAW":["sweet-side-haw-24x18.png",24,18,0,23],"HPU":["sweet-side-hpu-24x14.png",24,14,0,23],"HOF":["sweet-side-hof-24x15.png",24,15,0,23],"HC":["sweet-side-hc-20x23.png",20,23,0,19],"HCU":["sweet-side-hcu-22x23.png",22,23,0,21],"HOU":["sweet-side-hou-24x23.png",24,23,0,23],"HOW":["sweet-side-how-18x23.png",18,23,0,17],"IDST":["sweet-side-idst-24x23.png",24,23,0,23],"IDHO":["sweet-side-idho-21x23.png",21,23,0,20],"ILL":["sweet-side-ill-16x23.png",16,23,0,15],"ILST":["sweet-side-ilst-24x15.png",24,15,0,23],"UIW":["sweet-side-uiw-24x14.png",24,14,0,23],"IND":["sweet-side-ind-18x23.png",18,23,0,17],"INST":["sweet-side-inst-24x21.png",24,21,0,23],"IONA":["sweet-side-iona-24x18.png",24,18,0,23],"IOWA":["sweet-side-iowa-24x16.png",24,16,0,23],"ISU":["sweet-side-isu-24x17.png",24,17,0,23],"IUIN":["sweet-side-iuin-24x23.png",24,23,0,23],"JKST":["sweet-side-jkst-24x15.png",24,15,0,23],"JAX":["sweet-side-jax-24x15.png",24,15,0,23],"JXST":["sweet-side-jxst-24x15.png",24,15,0,23],"JMU":["sweet-side-jmu-17x23.png",17,23,0,16],"KC":["sweet-side-kc-24x23.png",24,23,0,23],"KU":["sweet-side-ku-24x21.png",24,21,0,23],"KSU":["sweet-side-ksu-24x18.png",24,18,0,23],"KENN":["sweet-side-kenn-24x23.png",24,23,0,23],"KENT":["sweet-side-kent-24x16.png",24,16,0,23],"UK":["sweet-side-uk-24x20.png",24,20,0,23],"LAS":["sweet-side-las-24x23.png",24,23,0,23],"LAF":["sweet-side-laf-24x14.png",24,14,0,23],"LAM":["sweet-side-lam-24x14.png",24,14,0,23],"LEM":["sweet-side-lem-24x13.png",24,13,0,23],"LEH":["sweet-side-leh-24x23.png",24,23,0,23],"LIB":["sweet-side-lib-24x21.png",24,21,0,23],"LIN":["sweet-side-lin-24x18.png",24,18,0,23],"LIP":["sweet-side-lip-18x23.png",18,23,0,17],"LR":["sweet-side-lr-24x13.png",24,13,0,23],"LBSU":["sweet-side-lbsu-19x23.png",19,23,0,18],"LIU":["sweet-side-liu-24x21.png",24,21,0,23],"LONG":["sweet-side-long-24x9.png",24,9,0,23],"UL":["sweet-side-ul-24x12.png",24,12,0,23],"LT":["sweet-side-lt-24x14.png",24,14,0,23],"LOU":["sweet-side-lou-21x23.png",21,23,0,20],"LUC":["sweet-side-luc-24x19.png",24,19,0,23],"LMD":["sweet-side-lmd-21x23.png",21,23,0,20],"LMU":["sweet-side-lmu-24x11.png",24,11,0,23],"NOLA":["sweet-side-nola-24x21.png",24,21,0,23],"LSU":["sweet-side-lsu-24x8.png",24,8,0,23],"ME":["sweet-side-me-24x18.png",24,18,0,23],"MAN":["sweet-side-man-24x20.png",24,20,0,23],"MRST":["sweet-side-mrst-24x12.png",24,12,0,23],"MARQ":["sweet-side-marq-24x18.png",24,18,0,23],"MRSH":["sweet-side-mrsh-24x16.png",24,16,0,23],"UMES":["sweet-side-umes-24x10.png",24,10,0,23],"MD":["sweet-side-md-21x23.png",21,23,0,20],"MASS":["sweet-side-mass-24x20.png",24,20,0,23],"MCN":["sweet-side-mcn-21x23.png",21,23,0,20],"MEM":["sweet-side-mem-24x21.png",24,21,0,23],"MER":["sweet-side-mer-24x18.png",24,18,0,23],"MERC":["sweet-side-merc-24x19.png",24,19,0,23],"MRMK":["sweet-side-mrmk-24x19.png",24,19,0,23],"MOH":["sweet-side-moh-24x18.png",24,18,0,23],"MIA":["sweet-side-mia-24x15.png",24,15,0,23],"MSU":["sweet-side-msu-20x23.png",20,23,0,19],"MICH":["sweet-side-mich-24x17.png",24,17,0,23],"MTSU":["sweet-side-mtsu-24x16.png",24,16,0,23],"MILW":["sweet-side-milw-24x23.png",24,23,0,23],"MINN":["sweet-side-minn-24x14.png",24,14,0,23],"MSST":["sweet-side-msst-24x15.png",24,15,0,23],"MVSU":["sweet-side-mvsu-24x18.png",24,18,0,23],"MOST":["sweet-side-most-24x21.png",24,21,0,23],"MIZ":["sweet-side-miz-24x14.png",24,14,0,23],"MONM":["sweet-side-monm-24x19.png",24,19,0,23],"MONT":["sweet-side-mont-24x18.png",24,18,0,23],"MTST":["sweet-side-mtst-24x18.png",24,18,0,23],"MORE":["sweet-side-more-24x23.png",24,23,0,23],"MORG":["sweet-side-morg-24x16.png",24,16,0,23],"MSM":["sweet-side-msm-24x13.png",24,13,0,23],"MUR":["sweet-side-mur-22x23.png",22,23,0,21],"NAVY":["sweet-side-navy-19x23.png",19,23,0,18],"NCST":["sweet-side-ncst-17x23.png",17,23,0,16],"NEB":["sweet-side-neb-23x23.png",23,23,0,22],"NEV":["sweet-side-nev-24x15.png",24,15,0,23],"UNH":["sweet-side-unh-24x20.png",24,20,0,23],"NHVN":["sweet-side-nhvn-22x18.png",22,18,0,21],"UNM":["sweet-side-unm-19x23.png",19,23,0,18],"NMSU":["sweet-side-nmsu-24x18.png",24,18,0,23],"NIA":["sweet-side-nia-24x10.png",24,10,0,23],"NICH":["sweet-side-nich-24x12.png",24,12,0,23],"NJIT":["sweet-side-njit-24x21.png",24,21,0,23],"NORF":["sweet-side-norf-23x23.png",23,23,0,22],"UNA":["sweet-side-una-24x17.png",24,17,0,23],"NCAT":["sweet-side-ncat-19x23.png",19,23,0,18],"NCCU":["sweet-side-nccu-24x12.png",24,12,1,23],"UNC":["sweet-side-unc-24x19.png",24,19,0,23],"UND":["sweet-side-und-24x11.png",24,11,0,23],"NDSU":["sweet-side-ndsu-24x12.png",24,12,0,23],"UNF":["sweet-side-unf-24x15.png",24,15,0,23],"UNT":["sweet-side-unt-21x23.png",21,23,0,20],"NE":["sweet-side-ne-23x23.png",23,23,4,20],"NAU":["sweet-side-nau-24x15.png",24,15,0,23],"UNCO":["sweet-side-unco-23x23.png",23,23,0,22],"NIU":["sweet-side-niu-24x23.png",24,23,0,23],"UNI":["sweet-side-uni-24x17.png",24,17,0,23],"NKU":["sweet-side-nku-24x15.png",24,15,0,23],"NWST":["sweet-side-nwst-24x19.png",24,19,0,23],"NU":["sweet-side-nu-15x23.png",15,23,0,14],"ND":["sweet-side-nd-24x22.png",24,22,0,23],"OAK":["sweet-side-oak-24x20.png",24,20,0,23],"OHIO":["sweet-side-ohio-24x21.png",24,21,0,23],"OSU":["sweet-side-osu-23x23.png",23,23,0,22],"OU":["sweet-side-ou-18x23.png",18,23,0,17],"OKST":["sweet-side-okst-24x12.png",24,12,0,23],"ODU":["sweet-side-odu-24x20.png",24,20,0,23],"MISS":["sweet-side-miss-24x22.png",24,22,0,23],"OMA":["sweet-side-oma-24x23.png",24,23,0,23],"ORU":["sweet-side-oru-24x16.png",24,16,0,23],"ORE":["sweet-side-ore-24x20.png",24,20,0,23],"ORST":["sweet-side-orst-24x14.png",24,14,1,23],"PAC":["sweet-side-pac-24x17.png",24,17,3,22],"PSU":["sweet-side-psu-24x17.png",24,17,0,23],"PENN":["sweet-side-penn-19x23.png",19,23,0,18],"PEPP":["sweet-side-pepp-22x23.png",22,23,0,21],"PITT":["sweet-side-pitt-24x14.png",24,14,0,23],"PORT":["sweet-side-port-20x23.png",20,23,0,19],"PRST":["sweet-side-prst-18x23.png",18,23,0,17],"PV":["sweet-side-pv-24x15.png",24,15,0,23],"PRES":["sweet-side-pres-23x23.png",23,23,0,22],"PRIN":["sweet-side-prin-20x23.png",20,23,0,19],"PROV":["sweet-side-prov-24x16.png",24,16,0,23],"PUR":["sweet-side-pur-24x13.png",24,13,0,23],"PFW":["sweet-side-pfw-24x22.png",24,22,0,23],"QUC":["sweet-side-quc-18x23.png",18,23,0,17],"QUIN":["sweet-side-quin-22x23.png",22,23,0,21],"RAD":["sweet-side-rad-24x20.png",24,20,0,23],"URI":["sweet-side-uri-18x23.png",18,23,0,17],"RICE":["sweet-side-rice-19x23.png",19,23,0,18],"RICH":["sweet-side-rich-17x23.png",17,23,0,16],"RID":["sweet-side-rid-24x14.png",24,14,0,23],"RMU":["sweet-side-rmu-24x11.png",24,11,0,23],"RUTG":["sweet-side-rutg-24x21.png",24,21,0,23],"SAC":["sweet-side-sac-24x21.png",24,21,0,23],"SHU":["sweet-side-shu-24x10.png",24,10,0,23],"SFPA":["sweet-side-sfpa-24x14.png",24,14,0,23],"JOES":["sweet-side-joes-24x15.png",24,15,0,23],"SLU":["sweet-side-slu-24x23.png",24,23,0,23],"SMC":["sweet-side-smc-24x16.png",24,16,0,23],"SPU":["sweet-side-spu-17x23.png",17,23,0,16],"SHSU":["sweet-side-shsu-24x20.png",24,20,0,23],"SAM":["sweet-side-sam-24x15.png",24,15,0,23],"SDSU":["sweet-side-sdsu-24x17.png",24,17,0,23],"USD":["sweet-side-usd-24x23.png",24,23,0,23],"SF":["sweet-side-sf-24x21.png",24,21,0,23],"SJSU":["sweet-side-sjsu-22x23.png",22,23,0,21],"SCU":["sweet-side-scu-18x23.png",18,23,0,17],"SELA":["sweet-side-sela-20x23.png",20,23,0,19],"SEA":["sweet-side-sea-20x23.png",20,23,0,18],"HALL":["sweet-side-hall-23x23.png",23,23,0,22],"SIE":["sweet-side-sie-24x13.png",24,13,0,23],"SIUE":["sweet-side-siue-24x8.png",24,8,0,23],"SMU":["sweet-side-smu-24x12.png",24,12,0,23],"USA":["sweet-side-usa-24x18.png",24,18,0,23],"SC":["sweet-side-sc-21x23.png",21,23,0,20],"SCST":["sweet-side-scst-19x23.png",19,23,0,18],"UPST":["sweet-side-upst-24x17.png",24,17,0,23],"SDAK":["sweet-side-sdak-18x23.png",18,23,0,17],"SDST":["sweet-side-sdst-24x18.png",24,18,0,23],"USF":["sweet-side-usf-24x19.png",24,19,0,23],"SEMO":["sweet-side-semo-24x15.png",24,15,0,23],"SIU":["sweet-side-siu-24x14.png",24,14,0,23],"USI":["sweet-side-usi-24x15.png",24,15,0,23],"SOU":["sweet-side-sou-24x21.png",24,21,0,23],"USM":["sweet-side-usm-24x13.png",24,13,0,23],"SUU":["sweet-side-suu-24x15.png",24,15,0,23],"SBU":["sweet-side-sbu-22x23.png",22,23,0,21],"SJU":["sweet-side-sju-16x23.png",16,23,0,15],"STMN":["sweet-side-stmn-21x23.png",21,23,0,20],"STAN":["sweet-side-stan-15x23.png",15,23,0,14],"SFA":["sweet-side-sfa-24x23.png",24,23,0,23],"STET":["sweet-side-stet-23x23.png",23,23,0,22],"STO":["sweet-side-sto-24x17.png",24,17,0,23],"STBK":["sweet-side-stbk-24x17.png",24,17,0,23],"SYR":["sweet-side-syr-17x23.png",17,23,0,16],"TAR":["sweet-side-tar-24x23.png",24,23,0,23],"TCU":["sweet-side-tcu-24x12.png",24,12,0,23],"TEM":["sweet-side-tem-20x23.png",20,23,0,19],"TNST":["sweet-side-tnst-24x22.png",24,22,0,23],"TNTC":["sweet-side-tntc-24x18.png",24,18,0,23],"TENN":["sweet-side-tenn-23x23.png",23,23,0,22],"TAMU":["sweet-side-tamu-24x23.png",24,23,0,23],"AMCC":["sweet-side-amcc-24x22.png",24,22,0,23],"TEX":["sweet-side-tex-24x12.png",24,12,0,23],"TXSO":["sweet-side-txso-24x23.png",24,23,0,23],"TXST":["sweet-side-txst-20x23.png",20,23,0,19],"TTU":["sweet-side-ttu-20x23.png",20,23,0,19],"CIT":["sweet-side-cit-24x21.png",24,21,0,23],"TOL":["sweet-side-tol-24x14.png",24,14,0,23],"TOW":["sweet-side-tow-24x16.png",24,16,0,23],"TROY":["sweet-side-troy-20x23.png",20,23,0,19],"TULN":["sweet-side-tuln-24x17.png",24,17,0,23],"TLSA":["sweet-side-tlsa-24x19.png",24,19,0,23],"UAB":["sweet-side-uab-24x20.png",24,20,0,23],"UALB":["sweet-side-ualb-12x23.png",12,23,0,11],"UCD":["sweet-side-ucd-24x17.png",24,17,0,23],"UCI":["sweet-side-uci-22x23.png",22,23,0,21],"UCR":["sweet-side-ucr-24x23.png",24,23,0,23],"UCSD":["sweet-side-ucsd-23x23.png",23,23,0,22],"UCSB":["sweet-side-ucsb-24x16.png",24,16,0,23],"UCF":["sweet-side-ucf-24x19.png",24,19,0,23],"UCLA":["sweet-side-ucla-24x12.png",24,12,0,23],"CONN":["sweet-side-conn-18x23.png",18,23,0,17],"UIC":["sweet-side-uic-24x10.png",24,10,0,23],"ULM":["sweet-side-ulm-24x17.png",24,17,0,23],"UML":["sweet-side-uml-24x11.png",24,11,0,23],"UMBC":["sweet-side-umbc-24x22.png",24,22,0,23],"UNCA":["sweet-side-unca-24x16.png",24,16,0,23],"UNCG":["sweet-side-uncg-24x19.png",24,19,0,23],"UNCW":["sweet-side-uncw-20x23.png",20,23,0,19],"UNLV":["sweet-side-unlv-24x14.png",24,14,0,23],"USC":["sweet-side-usc-22x23.png",22,23,0,21],"UTA":["sweet-side-uta-24x18.png",24,18,0,23],"UTM":["sweet-side-utm-24x19.png",24,19,0,23],"RGV":["sweet-side-rgv-24x19.png",24,19,0,23],"USU":["sweet-side-usu-24x18.png",24,18,0,23],"UTU":["sweet-side-utu-24x16.png",24,16,0,23],"UTAH":["sweet-side-utah-24x22.png",24,22,0,23],"UVU":["sweet-side-uvu-24x17.png",24,17,0,23],"UTEP":["sweet-side-utep-23x23.png",23,23,0,22],"UTSA":["sweet-side-utsa-24x11.png",24,11,0,23],"VAL":["sweet-side-val-22x23.png",22,23,0,21],"VAND":["sweet-side-vand-24x17.png",24,17,0,23],"VCU":["sweet-side-vcu-24x10.png",24,10,0,23],"UVM":["sweet-side-uvm-24x23.png",24,23,0,23],"NOVA":["sweet-side-nova-24x21.png",24,21,0,23],"UVA":["sweet-side-uva-24x19.png",24,19,0,23],"VT":["sweet-side-vt-24x11.png",24,11,0,23],"VMI":["sweet-side-vmi-22x23.png",22,23,0,21],"WAG":["sweet-side-wag-24x12.png",24,12,0,23],"WAKE":["sweet-side-wake-24x17.png",24,17,0,23],"WASH":["sweet-side-wash-24x16.png",24,16,0,23],"WSU":["sweet-side-wsu-24x23.png",24,23,0,23],"WEB":["sweet-side-web-24x17.png",24,17,0,23],"WGA":["sweet-side-wga-24x17.png",24,17,0,23],"WVU":["sweet-side-wvu-24x23.png",24,23,0,23],"WCU":["sweet-side-wcu-24x20.png",24,20,0,23],"WIU":["sweet-side-wiu-24x23.png",24,23,0,23],"WKU":["sweet-side-wku-24x18.png",24,18,0,23],"WMU":["sweet-side-wmu-23x23.png",23,23,0,22],"WICH":["sweet-side-wich-24x20.png",24,20,0,23],"WM":["sweet-side-wm-24x20.png",24,20,0,23],"WIN":["sweet-side-win-24x21.png",24,21,0,23],"WIS":["sweet-side-wis-24x23.png",24,23,0,23],"WOF":["sweet-side-wof-21x23.png",21,23,0,20],"WRST":["sweet-side-wrst-24x18.png",24,18,0,23],"WYO":["sweet-side-wyo-13x23.png",13,23,0,12],"XAV":["sweet-side-xav-24x19.png",24,19,0,23],"YALE":["sweet-side-yale-24x22.png",24,22,0,23],"YSU":["sweet-side-ysu-24x15.png",24,15,0,23]}
SWEET_COMPACT_FRAMES = {"ACU":["sweet-side-acu-18x13.png",18,13,0,17],"AF":["sweet-side-af-18x18.png",18,18,0,17],"AKR":["sweet-side-akr-18x10.png",18,10,0,17],"AAMU":["sweet-side-aamu-18x21.png",18,21,0,17],"BAMA":["sweet-side-bama-18x17.png",18,17,0,17],"ALST":["sweet-side-alst-18x13.png",18,13,0,17],"ALCN":["sweet-side-alcn-18x16.png",18,16,0,17],"AMER":["sweet-side-amer-18x18.png",18,18,0,17],"APP":["sweet-side-app-18x20.png",18,20,0,17],"ASU":["sweet-side-asu-12x23.png",12,23,0,11],"ARIZ":["sweet-side-ariz-18x16.png",18,16,0,17],"ARK":["sweet-side-ark-18x8.png",18,8,0,17],"ARST":["sweet-side-arst-18x18.png",18,18,0,17],"UAPB":["sweet-side-uapb-18x15.png",18,15,0,17],"ARMY":["sweet-side-army-18x21.png",18,21,0,17],"AUB":["sweet-side-aub-18x16.png",18,16,0,17],"APSU":["sweet-side-apsu-18x20.png",18,20,0,17],"BALL":["sweet-side-ball-16x23.png",16,23,0,15],"BAY":["sweet-side-bay-18x22.png",18,22,0,17],"BELL":["sweet-side-bell-17x23.png",17,23,0,16],"BEL":["sweet-side-bel-18x18.png",18,18,0,17],"BCU":["sweet-side-bcu-18x19.png",18,19,0,17],"BING":["sweet-side-bing-18x18.png",18,18,0,17],"BOIS":["sweet-side-bois-18x15.png",18,15,0,17],"BC":["sweet-side-bc-18x16.png",18,16,0,17],"BU":["sweet-side-bu-18x16.png",18,16,0,17],"BGSU":["sweet-side-bgsu-18x17.png",18,17,0,17],"BRAD":["sweet-side-brad-18x21.png",18,21,0,17],"BRWN":["sweet-side-brwn-18x22.png",18,22,0,17],"BRY":["sweet-side-bry-18x16.png",18,16,0,17],"BUCK":["sweet-side-buck-18x20.png",18,20,0,17],"BUF":["sweet-side-buf-18x17.png",18,17,0,17],"BTLR":["sweet-side-btlr-18x17.png",18,17,0,17],"BYU":["sweet-side-byu-18x11.png",18,11,0,17],"CP":["sweet-side-cp-18x18.png",18,18,0,17],"CSUB":["sweet-side-csub-18x13.png",18,13,0,17],"CSUF":["sweet-side-csuf-18x6.png",18,6,0,17],"CSUN":["sweet-side-csun-18x21.png",18,21,0,17],"CBU":["sweet-side-cbu-18x7.png",18,7,0,17],"CAL":["sweet-side-cal-18x14.png",18,14,0,17],"CAM":["sweet-side-cam-18x10.png",18,10,0,17],"CAN":["sweet-side-can-18x13.png",18,13,0,17],"UCA":["sweet-side-uca-18x16.png",18,16,0,17],"CCSU":["sweet-side-ccsu-18x16.png",18,16,0,17],"CMU":["sweet-side-cmu-18x13.png",18,13,0,17],"COFC":["sweet-side-cofc-18x21.png",18,21,0,17],"CHSO":["sweet-side-chso-18x13.png",18,13,0,17],"CLT":["sweet-side-clt-18x23.png",18,23,0,17],"UTC":["sweet-side-utc-18x16.png",18,16,0,17],"CHST":["sweet-side-chst-18x13.png",18,13,0,17],"CIN":["sweet-side-cin-15x23.png",15,23,0,14],"CLEM":["sweet-side-clem-18x17.png",18,17,0,17],"CLE":["sweet-side-cle-18x19.png",18,19,0,17],"CCU":["sweet-side-ccu-18x20.png",18,20,0,17],"COLG":["sweet-side-colg-18x17.png",18,17,0,17],"COLO":["sweet-side-colo-18x13.png",18,13,0,17],"CSU":["sweet-side-csu-18x18.png",18,18,0,17],"COLU":["sweet-side-colu-18x21.png",18,21,0,17],"COPP":["sweet-side-copp-18x11.png",18,11,0,17],"COR":["sweet-side-cor-18x19.png",18,19,0,17],"CREI":["sweet-side-crei-18x18.png",18,18,0,17],"DART":["sweet-side-dart-18x23.png",18,23,0,17],"DAV":["sweet-side-dav-18x20.png",18,20,0,17],"DAY":["sweet-side-day-18x11.png",18,11,0,17],"DEL":["sweet-side-del-18x12.png",18,12,0,17],"DSU":["sweet-side-dsu-18x14.png",18,14,0,17],"DEN":["sweet-side-den-18x13.png",18,13,0,17],"DEP":["sweet-side-dep-18x19.png",18,19,0,17],"DETM":["sweet-side-detm-18x14.png",18,14,0,17],"DRKE":["sweet-side-drke-18x20.png",18,20,0,17],"DREX":["sweet-side-drex-18x13.png",18,13,0,17],"DUKE":["sweet-side-duke-18x16.png",18,16,0,17],"DUQ":["sweet-side-duq-11x23.png",11,23,0,10],"ECU":["sweet-side-ecu-18x19.png",18,19,0,17],"ETSU":["sweet-side-etsu-18x18.png",18,18,0,17],"ETAM":["sweet-side-etam-18x18.png",18,18,0,17],"EIU":["sweet-side-eiu-18x15.png",18,15,0,17],"EKU":["sweet-side-eku-18x14.png",18,14,0,17],"EMU":["sweet-side-emu-18x20.png",18,20,0,17],"EWU":["sweet-side-ewu-18x17.png",18,17,0,17],"ELON":["sweet-side-elon-18x14.png",18,14,0,17],"EVAN":["sweet-side-evan-18x15.png",18,15,0,17],"FAIR":["sweet-side-fair-18x16.png",18,16,0,17],"FDU":["sweet-side-fdu-18x17.png",18,17,0,17],"FAMU":["sweet-side-famu-18x14.png",18,14,0,17],"FAU":["sweet-side-fau-18x12.png",18,12,0,17],"FLA":["sweet-side-fla-18x11.png",18,11,0,17],"FGCU":["sweet-side-fgcu-18x13.png",18,13,0,17],"FIU":["sweet-side-fiu-18x20.png",18,20,0,17],"FSU":["sweet-side-fsu-18x18.png",18,18,0,17],"FOR":["sweet-side-for-18x16.png",18,16,0,17],"FRES":["sweet-side-fres-18x13.png",18,13,0,17],"FUR":["sweet-side-fur-18x18.png",18,18,0,17],"GWEB":["sweet-side-gweb-18x16.png",18,16,0,17],"GMU":["sweet-side-gmu-18x18.png",18,18,0,17],"GW":["sweet-side-gw-18x13.png",18,13,0,17],"GTWN":["sweet-side-gtwn-18x18.png",18,18,0,17],"UGA":["sweet-side-uga-18x12.png",18,12,0,17],"GASO":["sweet-side-gaso-18x11.png",18,11,0,17],"GAST":["sweet-side-gast-18x15.png",18,15,0,17],"GT":["sweet-side-gt-18x11.png",18,11,0,17],"GONZ":["sweet-side-gonz-18x14.png",18,14,0,17],"GRAM":["sweet-side-gram-18x11.png",18,11,0,17],"GCU":["sweet-side-gcu-18x6.png",18,6,0,17],"GB":["sweet-side-gb-18x14.png",18,14,0,17],"HAMP":["sweet-side-hamp-18x20.png",18,20,0,17],"HARV":["sweet-side-harv-18x22.png",18,22,0,17],"HAW":["sweet-side-haw-18x14.png",18,14,0,17],"HPU":["sweet-side-hpu-18x11.png",18,11,0,17],"HOF":["sweet-side-hof-18x11.png",18,11,0,17],"HC":["sweet-side-hc-18x21.png",18,21,0,17],"HCU":["sweet-side-hcu-18x19.png",18,19,0,17],"HOU":["sweet-side-hou-18x17.png",18,17,0,17],"HOW":["sweet-side-how-18x23.png",18,23,0,17],"IDST":["sweet-side-idst-18x17.png",18,17,0,17],"IDHO":["sweet-side-idho-18x20.png",18,20,0,17],"ILL":["sweet-side-ill-16x23.png",16,23,0,15],"ILST":["sweet-side-ilst-18x11.png",18,11,0,17],"UIW":["sweet-side-uiw-18x10.png",18,10,0,17],"IND":["sweet-side-ind-18x23.png",18,23,0,17],"INST":["sweet-side-inst-18x16.png",18,16,0,17],"IONA":["sweet-side-iona-18x14.png",18,14,0,17],"IOWA":["sweet-side-iowa-18x12.png",18,12,0,17],"ISU":["sweet-side-isu-18x12.png",18,12,0,17],"IUIN":["sweet-side-iuin-18x17.png",18,17,0,17],"JKST":["sweet-side-jkst-18x11.png",18,11,0,17],"JAX":["sweet-side-jax-18x11.png",18,11,0,17],"JXST":["sweet-side-jxst-18x11.png",18,11,0,17],"JMU":["sweet-side-jmu-17x23.png",17,23,0,16],"KC":["sweet-side-kc-18x17.png",18,17,0,17],"KU":["sweet-side-ku-18x16.png",18,16,0,17],"KSU":["sweet-side-ksu-18x13.png",18,13,0,17],"KENN":["sweet-side-kenn-18x17.png",18,17,0,17],"KENT":["sweet-side-kent-18x12.png",18,12,0,17],"UK":["sweet-side-uk-18x15.png",18,15,0,17],"LAS":["sweet-side-las-18x17.png",18,17,0,17],"LAF":["sweet-side-laf-18x10.png",18,10,0,17],"LAM":["sweet-side-lam-18x11.png",18,11,0,17],"LEM":["sweet-side-lem-18x10.png",18,10,0,17],"LEH":["sweet-side-leh-18x18.png",18,18,0,17],"LIB":["sweet-side-lib-18x16.png",18,16,0,17],"LIN":["sweet-side-lin-18x13.png",18,13,0,17],"LIP":["sweet-side-lip-18x23.png",18,23,0,17],"LR":["sweet-side-lr-18x10.png",18,10,0,17],"LBSU":["sweet-side-lbsu-18x22.png",18,22,0,17],"LIU":["sweet-side-liu-18x16.png",18,16,0,17],"LONG":["sweet-side-long-18x7.png",18,7,0,17],"UL":["sweet-side-ul-18x9.png",18,9,0,17],"LT":["sweet-side-lt-18x11.png",18,11,0,17],"LOU":["sweet-side-lou-18x20.png",18,20,0,17],"LUC":["sweet-side-luc-18x14.png",18,14,0,17],"LMD":["sweet-side-lmd-18x20.png",18,20,1,16],"LMU":["sweet-side-lmu-18x8.png",18,8,0,17],"NOLA":["sweet-side-nola-18x16.png",18,16,0,17],"LSU":["sweet-side-lsu-18x6.png",18,6,0,17],"ME":["sweet-side-me-18x14.png",18,14,0,17],"MAN":["sweet-side-man-18x15.png",18,15,0,17],"MRST":["sweet-side-mrst-18x9.png",18,9,0,17],"MARQ":["sweet-side-marq-18x13.png",18,13,0,17],"MRSH":["sweet-side-mrsh-18x12.png",18,12,0,17],"UMES":["sweet-side-umes-18x8.png",18,8,0,17],"MD":["sweet-side-md-18x20.png",18,20,0,17],"MASS":["sweet-side-mass-18x15.png",18,15,0,17],"MCN":["sweet-side-mcn-18x20.png",18,20,0,17],"MEM":["sweet-side-mem-18x16.png",18,16,0,17],"MER":["sweet-side-mer-18x14.png",18,14,0,17],"MERC":["sweet-side-merc-18x14.png",18,14,0,17],"MRMK":["sweet-side-mrmk-18x14.png",18,14,0,17],"MOH":["sweet-side-moh-18x14.png",18,14,0,17],"MIA":["sweet-side-mia-18x11.png",18,11,0,17],"MSU":["sweet-side-msu-18x21.png",18,21,0,17],"MICH":["sweet-side-mich-18x13.png",18,13,0,17],"MTSU":["sweet-side-mtsu-18x12.png",18,12,0,17],"MILW":["sweet-side-milw-18x17.png",18,17,0,17],"MINN":["sweet-side-minn-18x11.png",18,11,0,17],"MSST":["sweet-side-msst-18x11.png",18,11,0,17],"MVSU":["sweet-side-mvsu-18x13.png",18,13,0,17],"MOST":["sweet-side-most-18x16.png",18,16,0,17],"MIZ":["sweet-side-miz-18x10.png",18,10,0,17],"MONM":["sweet-side-monm-18x14.png",18,14,0,17],"MONT":["sweet-side-mont-18x13.png",18,13,0,17],"MTST":["sweet-side-mtst-18x14.png",18,14,0,17],"MORE":["sweet-side-more-18x18.png",18,18,0,17],"MORG":["sweet-side-morg-18x12.png",18,12,0,17],"MSM":["sweet-side-msm-18x10.png",18,10,0,17],"MUR":["sweet-side-mur-18x19.png",18,19,0,17],"NAVY":["sweet-side-navy-18x22.png",18,22,0,17],"NCST":["sweet-side-ncst-17x23.png",17,23,0,16],"NEB":["sweet-side-neb-18x18.png",18,18,0,17],"NEV":["sweet-side-nev-18x12.png",18,12,0,17],"UNH":["sweet-side-unh-18x15.png",18,15,0,17],"NHVN":["sweet-side-nhvn-18x15.png",18,15,0,17],"UNM":["sweet-side-unm-18x22.png",18,22,0,17],"NMSU":["sweet-side-nmsu-18x13.png",18,13,0,17],"NIA":["sweet-side-nia-18x7.png",18,7,0,17],"NICH":["sweet-side-nich-18x9.png",18,9,0,17],"NJIT":["sweet-side-njit-18x16.png",18,16,0,17],"NORF":["sweet-side-norf-18x18.png",18,18,0,17],"UNA":["sweet-side-una-18x13.png",18,13,0,17],"NCAT":["sweet-side-ncat-18x22.png",18,22,0,17],"NCCU":["sweet-side-nccu-18x9.png",18,9,0,17],"UNC":["sweet-side-unc-18x14.png",18,14,0,17],"UND":["sweet-side-und-18x8.png",18,8,0,17],"NDSU":["sweet-side-ndsu-18x9.png",18,9,0,17],"UNF":["sweet-side-unf-18x11.png",18,11,0,17],"UNT":["sweet-side-unt-18x20.png",18,20,0,17],"NE":["sweet-side-ne-18x18.png",18,18,3,16],"NAU":["sweet-side-nau-18x11.png",18,11,0,17],"UNCO":["sweet-side-unco-18x18.png",18,18,0,17],"NIU":["sweet-side-niu-18x17.png",18,17,0,17],"UNI":["sweet-side-uni-18x12.png",18,12,0,17],"NKU":["sweet-side-nku-18x11.png",18,11,0,17],"NWST":["sweet-side-nwst-18x14.png",18,14,0,17],"NU":["sweet-side-nu-15x23.png",15,23,0,14],"ND":["sweet-side-nd-18x16.png",18,16,0,17],"OAK":["sweet-side-oak-18x15.png",18,15,0,17],"OHIO":["sweet-side-ohio-18x15.png",18,15,0,17],"OSU":["sweet-side-osu-18x18.png",18,18,0,17],"OU":["sweet-side-ou-18x23.png",18,23,0,17],"OKST":["sweet-side-okst-18x9.png",18,9,0,17],"ODU":["sweet-side-odu-18x15.png",18,15,0,17],"MISS":["sweet-side-miss-18x16.png",18,16,0,17],"OMA":["sweet-side-oma-18x18.png",18,18,0,17],"ORU":["sweet-side-oru-18x12.png",18,12,0,17],"ORE":["sweet-side-ore-18x15.png",18,15,0,17],"ORST":["sweet-side-orst-18x10.png",18,10,0,17],"PAC":["sweet-side-pac-18x13.png",18,13,2,17],"PSU":["sweet-side-psu-18x13.png",18,13,0,17],"PENN":["sweet-side-penn-18x22.png",18,22,0,17],"PEPP":["sweet-side-pepp-18x19.png",18,19,0,17],"PITT":["sweet-side-pitt-18x10.png",18,10,0,17],"PORT":["sweet-side-port-18x20.png",18,20,0,17],"PRST":["sweet-side-prst-18x23.png",18,23,0,17],"PV":["sweet-side-pv-18x11.png",18,11,0,17],"PRES":["sweet-side-pres-18x18.png",18,18,0,17],"PRIN":["sweet-side-prin-18x21.png",18,21,0,17],"PROV":["sweet-side-prov-18x12.png",18,12,0,17],"PUR":["sweet-side-pur-18x10.png",18,10,1,17],"PFW":["sweet-side-pfw-18x17.png",18,17,0,17],"QUC":["sweet-side-quc-18x23.png",18,23,0,17],"QUIN":["sweet-side-quin-18x19.png",18,19,0,17],"RAD":["sweet-side-rad-18x15.png",18,15,0,17],"URI":["sweet-side-uri-18x23.png",18,23,0,17],"RICE":["sweet-side-rice-18x22.png",18,22,0,17],"RICH":["sweet-side-rich-17x23.png",17,23,0,16],"RID":["sweet-side-rid-18x11.png",18,11,0,17],"RMU":["sweet-side-rmu-18x9.png",18,9,0,17],"RUTG":["sweet-side-rutg-18x16.png",18,16,0,17],"SAC":["sweet-side-sac-18x16.png",18,16,0,17],"SHU":["sweet-side-shu-18x7.png",18,7,0,17],"SFPA":["sweet-side-sfpa-18x10.png",18,10,0,17],"JOES":["sweet-side-joes-18x11.png",18,11,0,17],"SLU":["sweet-side-slu-18x17.png",18,17,0,17],"SMC":["sweet-side-smc-18x12.png",18,12,0,17],"SPU":["sweet-side-spu-17x23.png",17,23,0,16],"SHSU":["sweet-side-shsu-18x15.png",18,15,0,17],"SAM":["sweet-side-sam-18x11.png",18,11,0,17],"SDSU":["sweet-side-sdsu-18x13.png",18,13,0,17],"USD":["sweet-side-usd-18x17.png",18,17,0,17],"SF":["sweet-side-sf-18x16.png",18,16,0,17],"SJSU":["sweet-side-sjsu-18x19.png",18,19,0,17],"SCU":["sweet-side-scu-18x23.png",18,23,0,17],"SELA":["sweet-side-sela-18x21.png",18,21,0,17],"SEA":["sweet-side-sea-18x20.png",18,20,0,17],"HALL":["sweet-side-hall-18x18.png",18,18,0,17],"SIE":["sweet-side-sie-18x10.png",18,10,0,17],"SIUE":["sweet-side-siue-18x6.png",18,6,0,17],"SMU":["sweet-side-smu-18x9.png",18,9,0,17],"USA":["sweet-side-usa-18x13.png",18,13,0,17],"SC":["sweet-side-sc-18x20.png",18,20,0,17],"SCST":["sweet-side-scst-18x22.png",18,22,0,17],"UPST":["sweet-side-upst-18x12.png",18,12,0,17],"SDAK":["sweet-side-sdak-18x23.png",18,23,0,17],"SDST":["sweet-side-sdst-18x14.png",18,14,0,17],"USF":["sweet-side-usf-18x14.png",18,14,0,17],"SEMO":["sweet-side-semo-18x11.png",18,11,0,17],"SIU":["sweet-side-siu-18x10.png",18,10,0,17],"USI":["sweet-side-usi-18x12.png",18,12,0,17],"SOU":["sweet-side-sou-18x16.png",18,16,0,17],"USM":["sweet-side-usm-18x10.png",18,10,0,17],"SUU":["sweet-side-suu-18x11.png",18,11,0,17],"SBU":["sweet-side-sbu-18x19.png",18,19,0,17],"SJU":["sweet-side-sju-16x23.png",16,23,0,15],"STMN":["sweet-side-stmn-18x20.png",18,20,0,17],"STAN":["sweet-side-stan-15x23.png",15,23,0,14],"SFA":["sweet-side-sfa-18x17.png",18,17,0,17],"STET":["sweet-side-stet-18x18.png",18,18,0,17],"STO":["sweet-side-sto-18x13.png",18,13,0,17],"STBK":["sweet-side-stbk-18x13.png",18,13,0,17],"SYR":["sweet-side-syr-17x23.png",17,23,0,16],"TAR":["sweet-side-tar-18x17.png",18,17,0,17],"TCU":["sweet-side-tcu-18x9.png",18,9,0,17],"TEM":["sweet-side-tem-18x21.png",18,21,0,17],"TNST":["sweet-side-tnst-18x17.png",18,17,0,17],"TNTC":["sweet-side-tntc-18x14.png",18,14,0,17],"TENN":["sweet-side-tenn-18x18.png",18,18,0,17],"TAMU":["sweet-side-tamu-18x18.png",18,18,0,17],"AMCC":["sweet-side-amcc-18x17.png",18,17,0,17],"TEX":["sweet-side-tex-18x9.png",18,9,0,17],"TXSO":["sweet-side-txso-18x17.png",18,17,0,17],"TXST":["sweet-side-txst-18x21.png",18,21,0,17],"TTU":["sweet-side-ttu-18x21.png",18,21,0,17],"CIT":["sweet-side-cit-18x16.png",18,16,0,17],"TOL":["sweet-side-tol-18x11.png",18,11,0,17],"TOW":["sweet-side-tow-18x12.png",18,12,0,17],"TROY":["sweet-side-troy-18x20.png",18,20,0,17],"TULN":["sweet-side-tuln-18x13.png",18,13,0,17],"TLSA":["sweet-side-tlsa-18x14.png",18,14,0,17],"UAB":["sweet-side-uab-18x15.png",18,15,0,17],"UALB":["sweet-side-ualb-12x23.png",12,23,0,11],"UCD":["sweet-side-ucd-18x13.png",18,13,0,17],"UCI":["sweet-side-uci-18x19.png",18,19,0,17],"UCR":["sweet-side-ucr-18x17.png",18,17,0,17],"UCSD":["sweet-side-ucsd-18x18.png",18,18,0,17],"UCSB":["sweet-side-ucsb-18x12.png",18,12,0,17],"UCF":["sweet-side-ucf-18x14.png",18,14,0,17],"UCLA":["sweet-side-ucla-18x9.png",18,9,0,17],"CONN":["sweet-side-conn-18x22.png",18,22,0,17],"UIC":["sweet-side-uic-18x8.png",18,8,0,17],"ULM":["sweet-side-ulm-18x13.png",18,13,0,17],"UML":["sweet-side-uml-18x8.png",18,8,0,17],"UMBC":["sweet-side-umbc-18x17.png",18,17,0,17],"UNCA":["sweet-side-unca-18x12.png",18,12,0,17],"UNCG":["sweet-side-uncg-18x14.png",18,14,0,17],"UNCW":["sweet-side-uncw-18x20.png",18,20,0,17],"UNLV":["sweet-side-unlv-18x10.png",18,10,0,17],"USC":["sweet-side-usc-18x19.png",18,19,0,17],"UTA":["sweet-side-uta-18x14.png",18,14,0,17],"UTM":["sweet-side-utm-18x14.png",18,14,0,17],"RGV":["sweet-side-rgv-18x14.png",18,14,0,17],"USU":["sweet-side-usu-18x14.png",18,14,0,17],"UTU":["sweet-side-utu-18x12.png",18,12,0,17],"UTAH":["sweet-side-utah-18x17.png",18,17,0,17],"UVU":["sweet-side-uvu-18x13.png",18,13,0,17],"UTEP":["sweet-side-utep-18x18.png",18,18,0,17],"UTSA":["sweet-side-utsa-18x8.png",18,8,0,17],"VAL":["sweet-side-val-18x18.png",18,18,0,17],"VAND":["sweet-side-vand-18x13.png",18,13,0,17],"VCU":["sweet-side-vcu-18x8.png",18,8,0,17],"UVM":["sweet-side-uvm-18x18.png",18,18,0,17],"NOVA":["sweet-side-nova-18x16.png",18,16,0,17],"UVA":["sweet-side-uva-18x14.png",18,14,0,17],"VT":["sweet-side-vt-18x9.png",18,9,0,17],"VMI":["sweet-side-vmi-18x19.png",18,19,0,17],"WAG":["sweet-side-wag-18x9.png",18,9,0,17],"WAKE":["sweet-side-wake-18x13.png",18,13,0,17],"WASH":["sweet-side-wash-18x12.png",18,12,0,17],"WSU":["sweet-side-wsu-18x17.png",18,17,0,17],"WEB":["sweet-side-web-18x13.png",18,13,0,17],"WGA":["sweet-side-wga-18x13.png",18,13,0,17],"WVU":["sweet-side-wvu-18x17.png",18,17,0,17],"WCU":["sweet-side-wcu-18x15.png",18,15,0,17],"WIU":["sweet-side-wiu-18x17.png",18,17,0,17],"WKU":["sweet-side-wku-18x13.png",18,13,0,17],"WMU":["sweet-side-wmu-18x18.png",18,18,0,17],"WICH":["sweet-side-wich-18x15.png",18,15,0,17],"WM":["sweet-side-wm-18x15.png",18,15,0,17],"WIN":["sweet-side-win-18x16.png",18,16,0,17],"WIS":["sweet-side-wis-18x17.png",18,17,0,17],"WOF":["sweet-side-wof-18x20.png",18,20,0,17],"WRST":["sweet-side-wrst-18x14.png",18,14,0,17],"WYO":["sweet-side-wyo-13x23.png",13,23,0,12],"XAV":["sweet-side-xav-18x14.png",18,14,0,17],"YALE":["sweet-side-yale-18x17.png",18,17,0,17],"YSU":["sweet-side-ysu-18x11.png",18,11,0,17]}
SWEET_SINGLE_LEFT_INK = {"ACU":0,"AF":0,"AKR":0,"AAMU":3,"BAMA":1,"ALST":0,"ALCN":0,"AMER":1,"APP":3,"ASU":7,"ARIZ":1,"ARK":0,"ARST":2,"UAPB":0,"ARMY":3,"AUB":0,"APSU":2,"BALL":5,"BAY":3,"BELL":4,"BEL":1,"BCU":2,"BING":1,"BOIS":0,"BC":0,"BU":0,"BGSU":0,"BRAD":3,"BRWN":3,"BRY":0,"BUCK":3,"BUF":1,"BTLR":1,"BYU":0,"CP":1,"CSUB":0,"CSUF":0,"CSUN":3,"CBU":0,"CAL":0,"CAM":0,"CAN":0,"UCA":0,"CCSU":0,"CMU":0,"COFC":3,"CHSO":0,"CLT":4,"UTC":0,"CHST":0,"CIN":5,"CLEM":1,"CLE":2,"CCU":2,"COLG":0,"COLO":0,"CSU":1,"COLU":3,"COPP":0,"COR":2,"CREI":1,"DART":4,"DAV":1,"DAY":0,"DEL":0,"DSU":0,"DEN":0,"DEP":2,"DETM":0,"DRKE":2,"DREX":0,"DUKE":0,"DUQ":7,"ECU":2,"ETSU":1,"ETAM":1,"EIU":0,"EKU":0,"EMU":3,"EWU":0,"ELON":0,"EVAN":0,"FAIR":0,"FDU":0,"FAMU":0,"FAU":0,"FLA":0,"FGCU":0,"FIU":3,"FSU":1,"FOR":0,"FRES":0,"FUR":1,"GWEB":0,"GMU":1,"GW":0,"GTWN":1,"UGA":0,"GASO":0,"GAST":0,"GT":0,"GONZ":0,"GRAM":0,"GCU":0,"GB":0,"HAMP":2,"HARV":3,"HAW":0,"HPU":0,"HOF":0,"HC":3,"HCU":2,"HOU":1,"HOW":4,"IDST":1,"IDHO":2,"ILL":5,"ILST":0,"UIW":0,"IND":4,"INST":0,"IONA":0,"IOWA":0,"ISU":0,"IUIN":1,"JKST":0,"JAX":0,"JXST":0,"JMU":4,"KC":1,"KU":0,"KSU":0,"KENN":1,"KENT":0,"UK":0,"LAS":1,"LAF":0,"LAM":0,"LEM":0,"LEH":1,"LIB":0,"LIN":0,"LIP":4,"LR":0,"LBSU":3,"LIU":0,"LONG":0,"UL":0,"LT":0,"LOU":2,"LUC":0,"LMD":2,"LMU":0,"NOLA":0,"LSU":0,"ME":0,"MAN":0,"MRST":0,"MARQ":0,"MRSH":0,"UMES":0,"MD":2,"MASS":0,"MCN":2,"MEM":0,"MER":0,"MERC":0,"MRMK":0,"MOH":0,"MIA":0,"MSU":3,"MICH":0,"MTSU":0,"MILW":1,"MINN":0,"MSST":0,"MVSU":0,"MOST":0,"MIZ":0,"MONM":0,"MONT":0,"MTST":0,"MORE":1,"MORG":0,"MSM":0,"MUR":2,"NAVY":3,"NCST":4,"NEB":1,"NEV":0,"UNH":0,"NHVN":0,"UNM":3,"NMSU":0,"NIA":0,"NICH":0,"NJIT":0,"NORF":1,"UNA":0,"NCAT":3,"NCCU":2,"UNC":0,"UND":0,"NDSU":0,"UNF":0,"UNT":2,"NE":5,"NAU":0,"UNCO":1,"NIU":1,"UNI":0,"NKU":0,"NWST":0,"NU":5,"ND":0,"OAK":0,"OHIO":0,"OSU":1,"OU":4,"OKST":0,"ODU":0,"MISS":0,"OMA":1,"ORU":0,"ORE":0,"ORST":2,"PAC":4,"PSU":0,"PENN":3,"PEPP":2,"PITT":0,"PORT":3,"PRST":4,"PV":0,"PRES":1,"PRIN":3,"PROV":0,"PUR":0,"PFW":0,"QUC":4,"QUIN":2,"RAD":0,"URI":4,"RICE":3,"RICH":4,"RID":0,"RMU":0,"RUTG":0,"SAC":0,"SHU":0,"SFPA":0,"JOES":0,"SLU":1,"SMC":0,"SPU":4,"SHSU":0,"SAM":0,"SDSU":0,"USD":1,"SF":0,"SJSU":2,"SCU":4,"SELA":3,"SEA":3,"HALL":1,"SIE":0,"SIUE":0,"SMU":0,"USA":0,"SC":2,"SCST":3,"UPST":0,"SDAK":4,"SDST":0,"USF":0,"SEMO":0,"SIU":0,"USI":0,"SOU":0,"USM":0,"SUU":0,"SBU":0,"SJU":5,"STMN":2,"STAN":5,"SFA":1,"STET":1,"STO":0,"STBK":0,"SYR":4,"TAR":1,"TCU":0,"TEM":3,"TNST":0,"TNTC":0,"TENN":1,"TAMU":1,"AMCC":0,"TEX":0,"TXSO":1,"TXST":3,"TTU":3,"CIT":0,"TOL":0,"TOW":0,"TROY":3,"TULN":0,"TLSA":0,"UAB":0,"UALB":7,"UCD":0,"UCI":2,"UCR":1,"UCSD":1,"UCSB":0,"UCF":0,"UCLA":0,"CONN":4,"UIC":0,"ULM":0,"UML":0,"UMBC":0,"UNCA":0,"UNCG":0,"UNCW":3,"UNLV":0,"USC":2,"UTA":0,"UTM":0,"RGV":0,"USU":0,"UTU":0,"UTAH":0,"UVU":0,"UTEP":1,"UTSA":0,"VAL":2,"VAND":0,"VCU":0,"UVM":1,"NOVA":0,"UVA":0,"VT":0,"VMI":2,"WAG":0,"WAKE":0,"WASH":0,"WSU":1,"WEB":0,"WGA":0,"WVU":1,"WCU":0,"WIU":1,"WKU":0,"WMU":1,"WICH":0,"WM":0,"WIN":0,"WIS":1,"WOF":2,"WRST":0,"WYO":6,"XAV":0,"YALE":0,"YSU":0}

SWEET_SINGLE_RIGHT_INK = {"ACU":25,"AF":24,"AKR":25,"AAMU":21,"BAMA":24,"ALST":25,"ALCN":24,"AMER":23,"APP":22,"ASU":18,"ARIZ":24,"ARK":25,"ARST":23,"UAPB":25,"ARMY":22,"AUB":24,"APSU":22,"BALL":20,"BAY":21,"BELL":20,"BEL":24,"BCU":23,"BING":23,"BOIS":25,"BC":24,"BU":24,"BGSU":24,"BRAD":21,"BRWN":21,"BRY":25,"BUCK":22,"BUF":24,"BTLR":24,"BYU":25,"CP":24,"CSUB":25,"CSUF":25,"CSUN":22,"CBU":25,"CAL":25,"CAM":25,"CAN":25,"UCA":24,"CCSU":24,"CMU":25,"COFC":22,"CHSO":25,"CLT":21,"UTC":25,"CHST":25,"CIN":19,"CLEM":24,"CLE":23,"CCU":22,"COLG":24,"COLO":25,"CSU":23,"COLU":22,"COPP":25,"COR":23,"CREI":23,"DART":21,"DAV":24,"DAY":25,"DEL":25,"DSU":25,"DEN":25,"DEP":23,"DETM":25,"DRKE":22,"DREX":25,"DUKE":25,"DUQ":17,"ECU":23,"ETSU":23,"ETAM":23,"EIU":25,"EKU":25,"EMU":22,"EWU":24,"ELON":25,"EVAN":25,"FAIR":25,"FDU":24,"FAMU":25,"FAU":25,"FLA":25,"FGCU":25,"FIU":22,"FSU":23,"FOR":25,"FRES":25,"FUR":23,"GWEB":24,"GMU":23,"GW":25,"GTWN":23,"UGA":25,"GASO":25,"GAST":25,"GT":25,"GONZ":25,"GRAM":25,"GCU":25,"GB":25,"HAMP":22,"HARV":21,"HAW":25,"HPU":25,"HOF":25,"HC":22,"HCU":23,"HOU":24,"HOW":21,"IDST":24,"IDHO":22,"ILL":20,"ILST":25,"UIW":25,"IND":21,"INST":25,"IONA":25,"IOWA":25,"ISU":25,"IUIN":24,"JKST":25,"JAX":25,"JXST":25,"JMU":20,"KC":24,"KU":25,"KSU":25,"KENN":24,"KENT":25,"UK":25,"LAS":24,"LAF":25,"LAM":25,"LEM":25,"LEH":24,"LIB":25,"LIN":25,"LIP":21,"LR":25,"LBSU":21,"LIU":25,"LONG":25,"UL":25,"LT":25,"LOU":22,"LUC":25,"LMD":22,"LMU":25,"NOLA":25,"LSU":25,"ME":25,"MAN":25,"MRST":25,"MARQ":25,"MRSH":25,"UMES":25,"MD":22,"MASS":25,"MCN":22,"MEM":25,"MER":25,"MERC":25,"MRMK":25,"MOH":25,"MIA":25,"MSU":22,"MICH":25,"MTSU":25,"MILW":24,"MINN":25,"MSST":25,"MVSU":25,"MOST":25,"MIZ":25,"MONM":25,"MONT":25,"MTST":25,"MORE":24,"MORG":25,"MSM":25,"MUR":23,"NAVY":21,"NCST":20,"NEB":23,"NEV":25,"UNH":25,"NHVN":24,"UNM":21,"NMSU":25,"NIA":25,"NICH":25,"NJIT":25,"NORF":23,"UNA":25,"NCAT":21,"NCCU":25,"UNC":25,"UND":25,"NDSU":25,"UNF":25,"UNT":22,"NE":21,"NAU":25,"UNCO":23,"NIU":24,"UNI":25,"NKU":25,"NWST":25,"NU":19,"ND":24,"OAK":25,"OHIO":25,"OSU":23,"OU":21,"OKST":25,"ODU":25,"MISS":24,"OMA":24,"ORU":25,"ORE":25,"ORST":25,"PAC":24,"PSU":25,"PENN":21,"PEPP":23,"PITT":25,"PORT":22,"PRST":21,"PV":25,"PRES":23,"PRIN":22,"PROV":25,"PUR":25,"PFW":24,"QUC":21,"QUIN":23,"RAD":25,"URI":21,"RICE":21,"RICH":20,"RID":25,"RMU":25,"RUTG":25,"SAC":25,"SHU":25,"SFPA":25,"JOES":25,"SLU":24,"SMC":25,"SPU":20,"SHSU":25,"SAM":25,"SDSU":25,"USD":24,"SF":25,"SJSU":23,"SCU":21,"SELA":22,"SEA":21,"HALL":23,"SIE":25,"SIUE":25,"SMU":25,"USA":25,"SC":22,"SCST":21,"UPST":25,"SDAK":21,"SDST":25,"USF":25,"SEMO":25,"SIU":25,"USI":25,"SOU":25,"USM":25,"SUU":25,"SBU":24,"SJU":20,"STMN":22,"STAN":19,"SFA":24,"STET":23,"STO":25,"STBK":25,"SYR":20,"TAR":24,"TCU":25,"TEM":22,"TNST":24,"TNTC":25,"TENN":23,"TAMU":24,"AMCC":24,"TEX":25,"TXSO":24,"TXST":22,"TTU":22,"CIT":25,"TOL":25,"TOW":25,"TROY":22,"TULN":25,"TLSA":25,"UAB":25,"UALB":18,"UCD":25,"UCI":23,"UCR":24,"UCSD":23,"UCSB":25,"UCF":25,"UCLA":25,"CONN":21,"UIC":25,"ULM":25,"UML":25,"UMBC":24,"UNCA":25,"UNCG":25,"UNCW":22,"UNLV":25,"USC":23,"UTA":25,"UTM":25,"RGV":25,"USU":25,"UTU":25,"UTAH":24,"UVU":25,"UTEP":23,"UTSA":25,"VAL":23,"VAND":25,"VCU":25,"UVM":24,"NOVA":25,"UVA":25,"VT":25,"VMI":23,"WAG":25,"WAKE":25,"WASH":25,"WSU":24,"WEB":25,"WGA":25,"WVU":24,"WCU":25,"WIU":24,"WKU":25,"WMU":23,"WICH":25,"WM":25,"WIN":25,"WIS":24,"WOF":22,"WRST":25,"WYO":18,"XAV":25,"YALE":24,"YSU":25}

SWEET_PAIR_FRAMES.update({"NDSU":["sweet-side-ndsu-21x23.png",21,23,0,20]})
SWEET_COMPACT_FRAMES.update({"NDSU":["sweet-side-ndsu-18x20.png",18,20,0,17]})
SWEET_SINGLE_LEFT_INK.update({"NDSU":2})
SWEET_SINGLE_RIGHT_INK.update({"NDSU":22})

# Visible left edge in the top six rows, relative to each artwork's full ink.
# [single, paired, compact]; 99 means no artwork beside the seed at that height.
# Reproduce with measure_sweet_seed_corners.py; no source image is modified.
SWEET_SEED_CORNER_INK = {"ACU":[6,5,6],"AF":[1,1,0],"AKR":[3,3,99],"AAMU":[0,0,0],"BAMA":[9,9,6],"ALST":[2,0,1],"ALCN":[7,7,5],"AMER":[3,3,2],"APP":[3,3,2],"ASU":[0,0,0],"ARIZ":[2,2,1],"ARK":[7,99,99],"ARST":[0,0,0],"UAPB":[5,2,4],"ARMY":[0,0,0],"AUB":[0,0,0],"APSU":[2,2,2],"BALL":[0,0,0],"BAY":[0,0,0],"BELL":[1,1,1],"BEL":[0,0,0],"BCU":[0,0,0],"BING":[0,0,0],"BOIS":[1,1,1],"BC":[2,2,1],"BU":[0,0,0],"BGSU":[0,0,0],"BRAD":[0,0,0],"BRWN":[0,0,0],"BRY":[0,0,0],"BUCK":[0,0,0],"BUF":[0,0,0],"BTLR":[0,0,0],"BYU":[0,1,99],"CP":[0,0,0],"CSUB":[0,0,1],"CSUF":[99,99,99],"CSUN":[2,2,2],"CBU":[99,99,99],"CAL":[2,2,2],"CAM":[0,0,99],"CAN":[0,0,2],"UCA":[0,0,0],"CCSU":[0,0,0],"CMU":[1,3,2],"COFC":[0,0,0],"CHSO":[1,1,2],"CLT":[0,0,0],"UTC":[0,0,0],"CHST":[5,8,3],"CIN":[0,0,0],"CLEM":[0,0,0],"CLE":[0,0,0],"CCU":[6,6,5],"COLG":[0,0,0],"COLO":[2,2,4],"CSU":[0,0,0],"COLU":[0,0,0],"COPP":[0,0,99],"COR":[1,1,0],"CREI":[0,0,0],"DART":[0,0,0],"DAV":[0,0,0],"DAY":[0,0,99],"DEL":[6,6,5],"DSU":[0,0,0],"DEN":[0,0,0],"DEP":[0,0,0],"DETM":[0,0,0],"DRKE":[0,0,0],"DREX":[0,1,1],"DUKE":[0,0,0],"DUQ":[1,1,1],"ECU":[1,1,0],"ETSU":[0,0,0],"ETAM":[0,0,0],"EIU":[0,0,0],"EKU":[5,5,4],"EMU":[0,0,0],"EWU":[0,0,0],"ELON":[5,5,4],"EVAN":[0,0,0],"FAIR":[0,0,0],"FDU":[0,8,5],"FAMU":[3,3,3],"FAU":[0,0,0],"FLA":[1,2,99],"FGCU":[11,10,9],"FIU":[0,0,0],"FSU":[0,0,0],"FOR":[0,0,0],"FRES":[1,1,2],"FUR":[7,7,5],"GWEB":[1,1,1],"GMU":[0,0,0],"GW":[0,1,1],"GTWN":[0,0,0],"UGA":[1,0,1],"GASO":[0,0,99],"GAST":[0,0,0],"GT":[0,0,99],"GONZ":[0,0,0],"GRAM":[1,3,99],"GCU":[99,99,99],"GB":[0,0,0],"HAMP":[0,0,0],"HARV":[0,0,0],"HAW":[0,0,0],"HPU":[0,0,99],"HOF":[5,6,99],"HC":[0,0,0],"HCU":[1,1,1],"HOU":[0,0,0],"HOW":[0,0,0],"IDST":[0,0,1],"IDHO":[3,3,2],"ILL":[0,0,0],"ILST":[0,0,99],"UIW":[1,0,99],"IND":[0,0,0],"INST":[0,1,2],"IONA":[0,0,0],"IOWA":[0,0,1],"ISU":[5,5,3],"IUIN":[0,0,1],"JKST":[0,0,99],"JAX":[6,6,99],"JXST":[1,1,99],"JMU":[0,0,0],"KC":[4,4,4],"KU":[2,2,3],"KSU":[0,0,0],"KENN":[0,0,0],"KENT":[0,2,0],"UK":[0,0,0],"LAS":[0,0,0],"LAF":[1,0,99],"LAM":[5,5,99],"LEM":[5,4,99],"LEH":[1,1,2],"LIB":[0,0,0],"LIN":[0,0,0],"LIP":[0,0,0],"LR":[1,1,99],"LBSU":[0,0,0],"LIU":[3,3,1],"LONG":[99,99,99],"UL":[0,0,99],"LT":[0,0,99],"LOU":[3,3,2],"LUC":[0,0,2],"LMD":[2,2,0],"LMU":[0,99,99],"NOLA":[0,0,0],"LSU":[99,99,99],"ME":[0,0,0],"MAN":[0,0,0],"MRST":[0,0,99],"MARQ":[1,0,0],"MRSH":[0,2,1],"UMES":[99,99,99],"MD":[0,0,0],"MASS":[2,1,1],"MCN":[0,0,0],"MEM":[0,0,0],"MER":[0,0,0],"MERC":[0,0,1],"MRMK":[5,4,3],"MOH":[0,0,0],"MIA":[0,0,99],"MSU":[0,0,0],"MICH":[0,0,0],"MTSU":[1,1,0],"MILW":[0,0,1],"MINN":[4,2,99],"MSST":[1,1,99],"MVSU":[2,1,0],"MOST":[0,0,0],"MIZ":[3,1,99],"MONM":[3,3,3],"MONT":[1,1,2],"MTST":[8,8,7],"MORE":[0,0,0],"MORG":[5,5,3],"MSM":[5,6,99],"MUR":[0,0,0],"NAVY":[0,0,0],"NCST":[0,0,0],"NEB":[0,0,0],"NEV":[1,0,0],"UNH":[1,0,1],"NHVN":[3,2,2],"UNM":[0,0,0],"NMSU":[6,6,8],"NIA":[99,99,99],"NICH":[3,5,99],"NJIT":[2,1,0],"NORF":[0,0,0],"UNA":[1,1,1],"NCAT":[1,1,1],"NCCU":[1,0,99],"UNC":[0,1,0],"UND":[0,99,99],"NDSU":[0,0,0],"UNF":[0,1,99],"UNT":[0,0,0],"NE":[5,5,4],"NAU":[0,0,99],"UNCO":[0,0,0],"NIU":[4,4,3],"UNI":[1,1,0],"NKU":[5,8,99],"NWST":[1,1,0],"NU":[0,0,0],"ND":[0,0,0],"OAK":[0,0,0],"OHIO":[0,0,1],"OSU":[1,1,1],"OU":[0,0,0],"OKST":[3,2,99],"ODU":[3,3,3],"MISS":[0,0,0],"OMA":[0,0,0],"ORU":[1,1,3],"ORE":[0,0,0],"ORST":[3,2,99],"PAC":[2,3,3],"PSU":[0,1,1],"PENN":[0,0,0],"PEPP":[0,0,0],"PITT":[0,0,99],"PORT":[2,2,2],"PRST":[0,0,0],"PV":[6,5,99],"PRES":[0,0,0],"PRIN":[0,0,0],"PROV":[6,6,5],"PUR":[6,6,99],"PFW":[1,1,0],"QUC":[0,0,0],"QUIN":[0,0,0],"RAD":[0,0,0],"URI":[0,0,0],"RICE":[0,0,0],"RICH":[0,0,0],"RID":[12,10,99],"RMU":[0,99,99],"RUTG":[0,0,0],"SAC":[0,0,0],"SHU":[99,99,99],"SFPA":[3,2,99],"JOES":[2,2,99],"SLU":[1,1,1],"SMC":[2,0,1],"SPU":[0,0,0],"SHSU":[0,0,0],"SAM":[5,5,99],"SDSU":[2,2,2],"USD":[3,3,2],"SF":[0,0,0],"SJSU":[0,0,0],"SCU":[0,0,0],"SELA":[0,0,0],"SEA":[0,0,0],"HALL":[0,0,0],"SIE":[0,8,99],"SIUE":[99,99,99],"SMU":[1,2,99],"USA":[2,0,2],"SC":[0,0,0],"SCST":[0,0,0],"UPST":[1,3,2],"SDAK":[3,3,3],"SDST":[3,3,3],"USF":[0,0,0],"SEMO":[0,0,99],"SIU":[5,4,99],"USI":[0,0,3],"SOU":[0,0,0],"USM":[3,4,99],"SUU":[6,6,99],"SBU":[0,0,0],"SJU":[0,0,0],"STMN":[0,0,0],"STAN":[0,0,0],"SFA":[1,1,0],"STET":[2,2,2],"STO":[0,0,0],"STBK":[8,7,7],"SYR":[0,0,0],"TAR":[2,2,1],"TCU":[0,0,99],"TEM":[0,0,0],"TNST":[4,3,2],"TNTC":[0,0,0],"TENN":[0,0,0],"TAMU":[3,3,2],"AMCC":[0,0,0],"TEX":[0,0,99],"TXSO":[3,3,2],"TXST":[1,1,1],"TTU":[0,0,0],"CIT":[0,0,0],"TOL":[8,7,99],"TOW":[0,0,4],"TROY":[0,0,0],"TULN":[9,8,7],"TLSA":[3,7,6],"UAB":[0,0,1],"UALB":[0,0,0],"UCD":[3,6,6],"UCI":[1,1,0],"UCR":[0,0,0],"UCSD":[3,3,2],"UCSB":[1,0,1],"UCF":[0,0,0],"UCLA":[0,0,99],"CONN":[0,0,0],"UIC":[99,99,99],"ULM":[6,5,3],"UML":[6,99,99],"UMBC":[0,0,0],"UNCA":[7,6,5],"UNCG":[3,3,2],"UNCW":[1,1,1],"UNLV":[1,1,99],"USC":[3,3,2],"UTA":[1,3,2],"UTM":[0,0,0],"RGV":[0,4,2],"USU":[0,0,1],"UTU":[4,4,4],"UTAH":[0,0,0],"UVU":[0,0,0],"UTEP":[5,5,5],"UTSA":[5,99,99],"VAL":[0,0,0],"VAND":[0,0,0],"VCU":[99,99,99],"UVM":[2,2,0],"NOVA":[0,0,0],"UVA":[3,3,2],"VT":[0,99,99],"VMI":[0,0,0],"WAG":[0,0,99],"WAKE":[0,0,0],"WASH":[0,0,0],"WSU":[5,5,5],"WEB":[2,2,1],"WGA":[0,1,4],"WVU":[0,0,0],"WCU":[1,1,0],"WIU":[0,0,0],"WKU":[1,1,2],"WMU":[0,0,0],"WICH":[1,1,0],"WM":[0,0,0],"WIN":[0,0,0],"WIS":[0,0,0],"WOF":[3,3,2],"WRST":[7,6,5],"WYO":[0,0,0],"XAV":[0,0,0],"YALE":[0,0,0],"YSU":[0,0,99]}

SWEET_PAIR_FRAMES.update({"ARIZ":["sweet-side-ariz-24x22.png",24,22,0,23]})
SWEET_COMPACT_FRAMES.update({"ARIZ":["sweet-side-ariz-18x17.png",18,17,0,17]})
SWEET_SINGLE_LEFT_INK.update({"ARIZ":0})
SWEET_SINGLE_RIGHT_INK.update({"ARIZ":24})
SWEET_SEED_CORNER_INK.update({"ARIZ":[2,2,1]})

SWEET_PAIR_FRAMES.update({"AUB":["sweet-side-aub-24x21.png",24,21,0,23]})
SWEET_COMPACT_FRAMES.update({"AUB":["sweet-side-aub-18x16.png",18,16,0,17]})
SWEET_SINGLE_LEFT_INK.update({"AUB":0})
SWEET_SINGLE_RIGHT_INK.update({"AUB":25})

def your_team_corner_seed(c, seed, left, top):
    # Anchor the visible digit ink, not the font's padding around a narrow 1.
    edges = snapshot_text_edges(c, str(seed), "4x5", 0, "left")
    tight_text(c, str(seed), left - edges[0], top, font = "4x5", color = MUTED)
    return left + edges[1] - edges[0] + 2

def your_team_small_pool_mark(c, team, edge, top, right = False, compact = False):
    frame = SWEET_COMPACT_FRAMES[team] if compact else SWEET_PAIR_FRAMES[team]
    c.image(frame[0], edge - (frame[4] if right else frame[3]), top + (23 - frame[2]) // 2)

def future_logo_width(code):
    return SWEET_SINGLE_RIGHT_INK[code] - SWEET_SINGLE_LEFT_INK[code] + 1

def future_seed_width(c, seed):
    edges = snapshot_text_edges(c, str(seed), "4x5", 0, "left")
    return edges[1] - edges[0] + 1

def sweet_pair_width(pair, compact = False, seed = ""):
    frames = SWEET_COMPACT_FRAMES if compact else SWEET_PAIR_FRAMES
    return frames[pair[0]][4] - frames[pair[0]][3] + frames[pair[1]][4] - frames[pair[1]][3] + 14 + (9 if str(seed) != "" else 0)

def sweet_pair(c, pair, seed, left, top, compact = False, logo_left = None):
    frames = SWEET_COMPACT_FRAMES if compact else SWEET_PAIR_FRAMES
    first_width = frames[pair[0]][4] - frames[pair[0]][3] + 1
    # The shared seed always belongs on the left, never above OR.
    first_left = your_team_corner_seed(c, seed, left, top)
    if logo_left != None:
        first_left = logo_left
    or_left = first_left + first_width + 3
    center = or_left + 3
    your_team_small_pool_mark(c, pair[0], first_left, top, False, compact)
    your_team_small_pool_mark(c, pair[1], or_left + 9, top, False, compact)
    tight_text(c, "OR", center, top + 12, font = "picopixel", color = MUTED, align = "center")

def round32_pool_width(c, pair):
    return tight_width(c, str(your_team_resume(pair[0]).get("RECORD", "--")), "picopixel") + tight_width(c, str(your_team_resume(pair[1]).get("RECORD", "--")), "picopixel") + future_logo_width(pair[0]) + future_logo_width(pair[1]) + 15

def round32_pool(c, pair, seed, left, top):
    records = [str(your_team_resume(code).get("RECORD", "--")) for code in pair]
    first_logo = left + tight_width(c, records[0], "picopixel") + 3
    or_left = first_logo + future_logo_width(pair[0]) + 1
    second_logo = or_left + 8
    your_team_corner_seed(c, seed, left, top)
    your_team_mark(c, pair[0], first_logo - SWEET_SINGLE_LEFT_INK[pair[0]], top, 26, 23)
    your_team_mark(c, pair[1], second_logo - SWEET_SINGLE_LEFT_INK[pair[1]], top, 26, 23)
    tight_text(c, "OR", or_left, top + 10, font = "picopixel", color = MUTED)
    tight_text(c, records[0], left, top + 12, font = "picopixel", color = LIGHT)
    tight_text(c, records[1], second_logo + future_logo_width(pair[1]) + 3, top + 12, font = "picopixel", color = LIGHT)

def your_team_options(_projection, c, seed, left, top, width, tall = False, region = "", sweet = False):
    options = your_team_slot_options(_projection, seed, region)
    sample = region + "|" + str(seed) in _projection["YOUR_TEAM_SAMPLE_SLOTS"]
    center = left + width // 2
    if len(options) == 0:
        tight_text(c, "SLOT UNASSIGNED", center, top + 8, font = "3x4", color = MUTED, align = "center")
        return
    if len(options) == 1 and tall:
        pair = options[0]
        # Match the single-opponent corner exactly, including narrow digits.
        # Keep both native-size marks left of that reserved seed corner.
        your_team_text(c, str(seed), left + width - 1, top + 1, font = "4x5", color = LIGHT, align = "right")
        or_width = tight_width(c, "OR", "picopixel")
        or_left = left + 32
        your_team_fit_mark(c, pair[0], left, top, 31, 24, "right")
        your_team_fit_mark(c, pair[1], or_left + or_width + 1, top, 31, 24, "left")
        tight_text(c, "OR", or_left, top + 10, font = "picopixel", color = MUTED)
        your_team_pair_text(c, pair, center, top + 26, "4x5", width)
        return
    heading = "SEED " + str(seed) if len(options) == 1 else "#" + str(seed) + " POOL"
    if len(options) == 1:
        pair = options[0]
        if sweet or width <= 40:
            sweet_pair(c, pair, seed, left, top, width < 53)
        else:
            round32_pool(c, pair, seed, left, top)
        return
    if len(options) == 4 and width >= 70 and not tall:
        # A four-pair pool needs the full height. Put its label in the existing
        # right header, leaving four readable 4x5 rows with one-pixel gaps.
        c.rect(left, 0, left + width, 4, fill = "black")
        tight_text(c, heading, center, 0, font = "4x5", color = BLUE, align = "center")
        for index, pair in enumerate(options):
            tight_text(c, pair[0] + "/" + pair[1], center, top + index * 6, font = "4x5", color = LIGHT, align = "center")
        return
    header_font = "3x4" if len(options) == 4 and not tall else "picopixel"
    tight_text(c, heading, center, top, font = header_font, color = BLUE, align = "center")
    for index, pair in enumerate(options):
        label = pair[0] + "/" + pair[1]
        font = "3x4" if (len(options) == 4 and not tall) or tight_width(c, label, "4x5") > width - 2 else "4x5"
        y = top + (8 + index * 6 if tall else 5 + index * 5 if len(options) == 4 else 7 + index * 6)
        tight_text(c, label, center, y, font = font, color = LIGHT, align = "center")

def your_team_pair_text(c, pair, center, y, font, width = 0):
    labels = [pair[0], pair[1]]
    if width > 0:
        names = ["QUEENS" if code == "QUC" else TEAM_NAMES.get(code, code) for code in pair]
        if tight_width(c, names[0] + "/" + names[1], font) + 4 <= width:
            labels = names
    first_width = tight_width(c, labels[0], font)
    slash_width = tight_width(c, "/", font)
    total = first_width + slash_width + tight_width(c, labels[1], font) + 4
    left = center - total // 2
    tight_text(c, labels[0], left, y, font = font, color = full_field_color(pair[0]))
    tight_text(c, "/", left + first_width + 2, y, font = font, color = MUTED)
    tight_text(c, labels[1], left + first_width + slash_width + 4, y, font = font, color = full_field_color(pair[1]))

def your_team_name(c, team, x, y, width, font = "4x5", center = False):
    name = TEAM_NAMES.get(team, "TBD") if team != "TBD" else "TBD"
    if tight_width(c, name, font) > width:
        name = team
    your_team_text(c, name, x, y, font = font, color = full_field_color(team), align = "center" if center else "left")

def your_team_text_anchor(c, value, font, x, align):
    edges = snapshot_text_edges(c, str(value), font, 0, align)
    if align == "center": return x - (edges[0] + edges[1]) // 2
    return x - (edges[1] if align == "right" else edges[0])

def your_team_text(c, value, x, y, font = "4x5", color = LIGHT, align = "left"):
    # Align actual glyph ink, independent of font bearings and narrow digits.
    tight_text(c, str(value), your_team_text_anchor(c, value, font, x, align), y, font = font, color = color, align = align)

def your_team_text_edges(c, value, font, x, align):
    return snapshot_text_edges(c, str(value), font, your_team_text_anchor(c, value, font, x, align), align)

def your_team_mark(c, team, x, y, w, h):
    if team == "TBD":
        c.rect(x + 2, y + 2, x + w - 3, y + h - 2, outline = "#12345c")
        tight_text(c, "TBD", x + w // 2, y + h // 2 - 2, font = "4x5", color = MUTED, align = "center")
    elif team in USER_LOGO_FRAMES:
        # Supplied originals take precedence over legacy hand-colored marks.
        draw_user_logo_native(c, team, x, y, w, h)
    elif team == "WVU":
        mark = [[BUBBLE_WVU_GOLD[min(21, row * 22 // h)][min(28, column * 29 // w)] for column in range(w)] for row in range(h)]
        c.bitmap(mark, x, y, color = "#EAAA00")
    else:
        draw_team_logo(c, team, x, y, w, h)

def your_team_fit_mark(c, team, left, top, width, height, align = "center"):
    # Fit the *visible* artwork rather than its transparent image rectangle.
    # Shared slots + fixed OR gutter keep every pairing collision-free.
    if team in USER_LOGO_FRAMES:
        draw_user_logo_native(c, team, left, top, width, height, align)
        return
    if team == "SMC":
        draw_smc_native(c, left, top, width, height, align)
        return
    if team == "MRMK":
        draw_mrmk_native(c, left, top, width, height, align)
        return
    bounds = TEAM_LOGO_BOUNDS.get(team, [26, 23, 0, 0, 26, 23])
    native_w, native_h, x0, y0, x1, y1 = bounds
    art_w = max(1, x1 - x0)
    art_h = max(1, y1 - y0)
    scale = min(width / float(art_w), height / float(art_h))
    draw_w = max(1, int(native_w * scale + 0.5))
    draw_h = max(1, int(native_h * scale + 0.5))
    visible_w = max(1, int(x1 * draw_w / native_w + 0.5) - int(x0 * draw_w / native_w + 0.5))
    visible_h = max(1, int(y1 * draw_h / native_h + 0.5) - int(y0 * draw_h / native_h + 0.5))
    inset = width - visible_w if align == "right" else 0 if align == "left" else (width - visible_w) // 2
    x = left + inset - int(x0 * draw_w / native_w + 0.5)
    y = top + (height - visible_h) // 2 - int(y0 * draw_h / native_h + 0.5)
    your_team_mark(c, team, x, y, draw_w, draw_h)

def your_team_notice(c, team, title, line1, line2):
    tight_text(c, title, 8, 0, font = "4x5", color = BLUE)
    c.line(8, 6, 184, 6, color = "#12345c")
    your_team_mark(c, team, 8, 9, 29, 22)
    tight_text(c, line1, 47, 11, font = "6x8" if tight_width(c, line1, "6x8") <= 137 else "4x5", color = full_field_color(team))
    tight_text(c, line2, 47, 25, font = "4x5" if tight_width(c, line2, "4x5") <= 137 else "picopixel", color = MUTED)

def your_team_round64_opponent(_projection, c, opponent, seed):
    # Keep the opening-round winner's single-opponent identity treatment.
    # Three larger resume columns keep the opponent card easy to read.
    metrics = your_team_resume(opponent, include_wab = True)
    your_team_text(c, "ROUND OF 64", 96, 0, font = "4x5", color = BLUE, align = "center")
    c.line(8, 6, 184, 6, color = "#12345c")
    your_team_mark(c, opponent, 8, 8, 38, 24)
    name = TEAM_NAMES.get(opponent, opponent)
    if tight_width(c, name, "4x5") > 52: name = opponent
    name_font = "6x8" if tight_width(c, name, "6x8") <= 52 else "4x5"
    your_team_text(c, name, 54, 10, font = name_font, color = full_field_color(opponent))
    record = str(metrics.get("RECORD", "--"))
    your_team_text(c, record, 54, 27, font = "picopixel", color = LIGHT)
    overall = _projection["TEAM_OVERALL_SEEDS"].get(opponent, 0)
    overall_label = "OVR " + (str(overall) if overall > 0 else "--")
    seed_label = str(seed) + " SEED"
    seed_font = "4x5"
    your_team_text(c, seed_label, 54, 20, font = seed_font, color = BLUE)
    your_team_text(c, overall_label, 105, 27, font = "4x5", color = MUTED, align = "right")
    for x in [107, 135, 163, 191]:
        c.line(x, 8, x, 31, color = "#12345c")
    for column, label in enumerate(["NET", "WAB", "SOR"]):
        center = 121 + column * 28
        your_team_text(c, label, center, 10, font = "4x5", color = BLUE, align = "center")
        value = str(metrics.get(label, "--"))
        font = "5x7" if tight_width(c, value, "5x7") <= 25 else "4x5" if tight_width(c, value, "4x5") <= 25 else "picopixel"
        your_team_text(c, value, center, 21, font = font, color = LIGHT, align = "center")

# Original-source frames for the remaining legacy marks. Scoped to this
# card only: Field of 64, Top 4 and the approved paired layouts stay untouched.
# Each entry is filename, native width/height, visible left/right ink edges.
ROUND32_SOURCE_LOGO_FRAMES = {
    "AF": ["round32-source-af-24x24.png", 24, 24, 0, 23],
    "DAV": ["round32-source-dav-22x24.png", 22, 24, 0, 21],
    "MCN": ["round32-source-mcn-22x24.png", 22, 24, 0, 21],
    "NHVN": ["round32-source-nhvn-29x24.png", 29, 24, 0, 28],
    "SBU": ["round32-source-sbu-23x24.png", 23, 24, 0, 22],
}

# Visible-color centering corrections for native frames whose outer black
# artwork disappears on the panel. These move the PNG, never reshape it.
ROUND32_LOGO_INK_ADJUST = {"NCCU": -2, "ORST": -2, "PAC": -2, "SEA": 1}

def your_team_round32_card(_projection, c, code, seed, left):
    # Half-width Houston card: three airy identity rows, with record and
    # overall sharing the bottom row. Move the logo/identity block left,
    # leaving NET and OVR fixed. Stop wide right-hand art at the divider.
    metrics = your_team_resume(code)
    frame = USER_LOGO_FRAMES[code]["38x24"] if code in USER_LOGO_FRAMES else SMC_NATIVE_FRAMES["38x24"] if code == "SMC" else MRMK_NATIVE_FRAMES["38x24"] if code == "MRMK" else ROUND32_SOURCE_LOGO_FRAMES[code]
    shift = min(5, (38 - frame[1]) // 2 + 1) if left > 96 else 5
    logo_left = left - shift
    if code in ROUND32_SOURCE_LOGO_FRAMES:
        source_frame = ROUND32_SOURCE_LOGO_FRAMES[code]
        ink_width = source_frame[4] - source_frame[3] + 1
        c.image(source_frame[0], logo_left + (38 - ink_width) // 2 - source_frame[3], 8 + (24 - source_frame[2]) // 2)
    else:
        your_team_mark(c, code, logo_left + ROUND32_LOGO_INK_ADJUST.get(code, 0), 8, 38, 24)
    identity_left = left + 40 - shift
    center = left + 78
    net_left = your_team_text_edges(c, "NET", "4x5", center, "center")[0]
    name = TEAM_NAMES.get(code, code)
    if tight_width(c, name, "6x8") > min(35, net_left - (left + 40) - 1): name = code
    your_team_text(c, name, identity_left, 10, font = "6x8", color = full_field_color(code))
    seed_label = str(seed) + " SEED"
    your_team_text(c, seed_label, identity_left, 20, font = "4x5", color = BLUE)
    record = str(metrics.get("RECORD", "--"))
    your_team_text(c, record, identity_left, 27, font = "picopixel", color = LIGHT)
    overall = _projection.get("TEAM_OVERALL_SEEDS", {}).get(code, 0)
    overall_label = "OVR " + (str(overall) if overall > 0 else "--")
    record_right = your_team_text_edges(c, record, "picopixel", identity_left, "left")[1]
    overall_font = "4x5" if your_team_text_edges(c, overall_label, "4x5", left + 85, "right")[0] > record_right + 1 else "picopixel"
    your_team_text(c, overall_label, left + 85, 27, font = overall_font, color = MUTED, align = "right")
    your_team_text(c, "NET", center, 9, font = "4x5", color = BLUE, align = "center")
    value = str(metrics.get("NET", "--")) if metrics.get("_season") == "26-27" else "--"
    seed_right = your_team_text_edges(c, seed_label, "4x5", identity_left, "left")[1]
    net_width = min(17, 2 * (center - seed_right - 2) + 2, 2 * (left + 85 - center) + 1)
    font = "5x7" if tight_width(c, value, "5x7") <= net_width else "4x5" if tight_width(c, value, "4x5") <= net_width else "picopixel"
    your_team_text(c, value, center, 18, font = font, color = LIGHT, align = "center")

def your_team_candidate(_projection, c, code, seed, left, region, width = 80):
    if code == "TBD":
        your_team_options(_projection, c, seed, left, 8, width, region = region)
        return
    resume = your_team_resume(code)
    logo_left = your_team_corner_seed(c, seed, left, 8)
    your_team_mark(c, code, logo_left - SWEET_SINGLE_LEFT_INK[code], 8, 26, 23)
    stats_left = logo_left + future_logo_width(code) + 5
    stats_width = width - (stats_left - left)
    stats_center = stats_left + stats_width // 2
    your_team_text(c, resume.get("RECORD", "--"), stats_center, 10, font = "4x5", color = LIGHT, align = "center")
    current_net = resume.get("NET", "--") if resume.get("_season") == "26-27" else "--"
    your_team_text(c, "NET", stats_center, 19, font = "picopixel", color = BLUE, align = "center")
    your_team_text(c, current_net, stats_center, 27, font = "picopixel", color = LIGHT, align = "center")

def round32_candidate_width(_projection, c, code, seed, region):
    if code == "TBD":
        options = your_team_slot_options(_projection, seed, region)
        return round32_pool_width(c, options[0]) if len(options) == 1 else 80
    record_width = tight_width(c, str(your_team_resume(code).get("RECORD", "--")), "4x5")
    return future_seed_width(c, seed) + 1 + future_logo_width(code) + 5 + max(record_width, 12)

def round32_mixed_pair_width(c, pair, seed, resumes = None):
    # Full native marks plus three compact identity rows per candidate.
    # NET + one-pixel gap + a three-digit value needs a 23-pixel column.
    width = future_seed_width(c, seed) + 2 + 9
    for index, code in enumerate(pair):
        metrics = resumes[index] if resumes != None else your_team_resume(code)
        record = str(metrics.get("RECORD", "--"))
        width += future_logo_width(code) + 2 + max(23, tight_width(c, code, "4x5"), tight_width(c, record, "picopixel"))
    return width

def your_team_round32_mixed_single(_projection, c, code, seed, left, width, metrics = None):
    if metrics == None: metrics = your_team_resume(code)
    your_team_mark(c, code, left - SWEET_SINGLE_LEFT_INK[code], 8, 26, 23)
    identity = left + future_logo_width(code) + 2
    net_center = left + width - 7
    name_width = net_center - 8 - identity - 1
    name_font = "6x8" if tight_width(c, code, "6x8") <= name_width else "5x7" if tight_width(c, code, "5x7") <= name_width else "4x5"
    your_team_text(c, code, identity, 10, font = name_font, color = full_field_color(code))
    seed_label = str(seed) + " SEED"
    seed_font = "4x5" if tight_width(c, seed_label, "4x5") <= net_center - 7 - identity - 1 else "picopixel"
    your_team_text(c, seed_label, identity, 20, font = seed_font, color = BLUE)
    record = str(metrics.get("RECORD", "--"))
    your_team_text(c, record, identity, 27, font = "picopixel", color = LIGHT)
    overall = _projection.get("TEAM_OVERALL_SEEDS", {}).get(code, 0)
    overall_label = "OVR " + (str(overall) if overall > 0 else "--")
    overall_left = your_team_text_edges(c, overall_label, "picopixel", left + width - 1, "right")[0]
    record_right = your_team_text_edges(c, record, "picopixel", identity, "left")[1]
    if overall_left > record_right + 1:
        your_team_text(c, overall_label, left + width - 1, 27, font = "picopixel", color = MUTED, align = "right")
    your_team_text(c, "NET", net_center, 9, font = "4x5", color = BLUE, align = "center")
    net = str(metrics.get("NET", "--")) if metrics.get("_season") == "26-27" else "--"
    your_team_text(c, net, net_center, 19, font = "picopixel", color = LIGHT, align = "center")

def your_team_round32_mixed_pair(_projection, c, pair, seed, left, resumes = None):
    # Keep the existing box allocation (and the single-team side) unchanged.
    # Split the removed corner-seed space between the two metadata columns.
    extra = (future_seed_width(c, seed) + 2) // 2
    logo_left = left
    for index, code in enumerate(pair):
        metrics = resumes[index] if resumes != None else your_team_resume(code)
        record = str(metrics.get("RECORD", "--"))
        column_width = max(23, tight_width(c, code, "4x5"), tight_width(c, record, "picopixel")) + extra
        your_team_mark(c, code, logo_left - SWEET_SINGLE_LEFT_INK[code], 8, 26, 23)
        text_left = logo_left + future_logo_width(code) + 2
        # Human-approved three-row, two-column order:
        # record / seed / OVR at left; NET / NET value / overall at right.
        net_center = text_left + column_width - 6
        value_left = net_center - 5
        # The record now shares a row with NET's heading rather than its
        # value. Keep the same two-pixel clearance from the heading's ink.
        record_font = "picopixel" if tight_width(c, record, "picopixel") <= value_left - text_left - 2 else "3x4"
        your_team_text(c, str(seed), text_left, 18, font = "picopixel", color = BLUE)
        if record_font == "3x4":
            tight_text(c, record, text_left, 9, font = record_font, color = LIGHT)
        else:
            your_team_text(c, record, text_left, 9, font = record_font, color = LIGHT)
        your_team_text(c, "NET", net_center, 9, font = "picopixel", color = BLUE, align = "center")
        net = str(metrics.get("NET", "--")) if metrics.get("_season") == "26-27" else "--"
        your_team_text(c, net, net_center, 18, font = "picopixel", color = LIGHT, align = "center")
        overall = _projection.get("TEAM_OVERALL_SEEDS", {}).get(code, 0)
        your_team_text(c, "OVR", text_left, 27, font = "picopixel", color = MUTED)
        your_team_text(c, str(overall) if overall > 0 else "--", net_center, 27, font = "picopixel", color = MUTED, align = "center")
        logo_left = text_left + column_width + 9
        if index == 0:
            tight_text(c, "OR", text_left + column_width + 1, 18, font = "picopixel", color = MUTED)

def your_team_round32_candidates(_projection, c, game, region):
    if game[1] != "TBD" and game[3] != "TBD":
        c.line(96, 9, 96, 30, color = "#12345c")
        your_team_round32_card(_projection, c, game[1], game[0], 8)
        your_team_round32_card(_projection, c, game[3], game[2], 98)
        return
    # One ordinary candidate versus a two-school opening-round slot. Keep
    # both native logos, but replace the old empty gutters with identity/data
    # columns. Leave the already-approved ordinary two-card layout unchanged.
    pair_index = 0 if game[1] == "TBD" else 1
    pair_seed = game[0] if pair_index == 0 else game[2]
    options = your_team_slot_options(_projection, pair_seed, region)
    other_code = game[3] if pair_index == 0 else game[1]
    if len(options) == 1 and other_code != "TBD":
        pair = options[0]
        # Share these reads between sizing and drawing: adding the labels
        # must not add repeat source pulls for either opening-round school.
        resumes = [your_team_resume(code) for code in pair]
        pair_width = round32_mixed_pair_width(c, pair, pair_seed, resumes)
        single_width = 181 - pair_width
        other_seed = game[2] if pair_index == 0 else game[0]
        minimum_single = future_logo_width(other_code) + max(40, tight_width(c, str(other_seed) + " SEED", "picopixel") + 15)
        if single_width >= minimum_single:
            first_width = pair_width if pair_index == 0 else single_width
            divider = 5 + first_width + 2
            c.line(divider, 9, divider, 30, color = "#12345c")
            pair_left = 5 if pair_index == 0 else divider + 3
            single_left = divider + 3 if pair_index == 0 else 5
            your_team_round32_mixed_single(_projection, c, other_code, other_seed, single_left, single_width)
            your_team_round32_mixed_pair(_projection, c, pair, pair_seed, pair_left, resumes)
            return
    widths = [round32_candidate_width(_projection, c, game[1], game[0], region), round32_candidate_width(_projection, c, game[3], game[2], region)]
    # Reserve each group's measured width, then share the remaining space
    # equally across the four gutters (outer edges and both divider sides).
    # A wide play-in pair can move the divider, but never unbalance a card.
    divider = (192 + widths[0] - widths[1]) // 2
    c.line(divider, 9, divider, 30, color = "#12345c")
    first_left = (divider - widths[0]) // 2
    second_left = divider + 1 + (191 - divider - widths[1]) // 2
    your_team_candidate(_projection, c, game[1], game[0], first_left, region, width = widths[0])
    your_team_candidate(_projection, c, game[3], game[2], second_left, region, width = widths[1])

def sweet_box_width(c, code, seed, options, compact = False):
    if code == "TBD" and len(options) != 1:
        return 34
    paired = len(options) == 1
    first = options[0][0] if paired else code
    art_width = sweet_pair_width(options[0], compact) if paired else future_logo_width(code)
    top_ink = SWEET_SEED_CORNER_INK[first][2 if compact else 1] if paired else SWEET_SEED_CORNER_INK[first][0]
    # Mirror only the clearance the left corner really needs. This keeps the
    # artwork centered on the entire box without touching the corner seed.
    margin = max(1, future_seed_width(c, seed) + 2 - top_ink)
    return art_width + 2 * margin

def your_team_sweet_candidates(_projection, c, possibilities, region):
    items = []
    for game in possibilities:
        for side in range(2):
            code = game[1] if side == 0 else game[3]
            seed = game[0] if side == 0 else game[2]
            options = your_team_slot_options(_projection, seed, region) if code == "TBD" else []
            width = sweet_box_width(c, code, seed, options)
            items.append([code, seed, options, width])
    total = 0
    for item in items:
        total += item[3]
    compact = total > 180
    if compact:
        for item in items:
            item[3] = sweet_box_width(c, item[0], item[1], item[2], True)
        total = 0
        for item in items:
            total += item[3]
    gap = max(2, (188 - total) // 3)
    left = (192 - total - gap * 3) // 2
    previous_divider = -1
    for index, item in enumerate(items):
        code, seed, options, width = item
        divider = left + width + gap // 2 if index < 3 else 192
        box_left = previous_divider + 1
        box_right = divider - 1
        seed_left = box_left + 1
        # Center artwork between the actual dividers. The corner seed is an
        # independent label, not an extra left margin that shifts the logo.
        art_left = box_left + 1
        art_right = box_right - 1
        if len(options) == 1:
            art_width = sweet_pair_width(options[0], compact)
            logo_left = art_left + (art_right - art_left + 1 - art_width) // 2
            sweet_pair(c, options[0], seed, seed_left, 8, compact, logo_left)
        elif code == "TBD":
            your_team_corner_seed(c, seed, seed_left, 8)
            center = (art_left + art_right) // 2
            tight_text(c, "OPENING", center, 18, font = "picopixel", color = BLUE, align = "center")
            tight_text(c, "WINNER", center, 26, font = "4x5", color = LIGHT, align = "center")
        else:
            your_team_corner_seed(c, seed, seed_left, 8)
            logo_left = art_left + (art_right - art_left + 1 - future_logo_width(code)) // 2
            your_team_mark(c, code, logo_left - SWEET_SINGLE_LEFT_INK[code], 8, 26, 23)
        if index < 3:
            c.line(divider, 9, divider, 30, color = "#12345c")
        previous_divider = divider
        left += width + gap

SNAPSHOT_LOGO_RIGHT = {'ACU': 35, 'AF': 35, 'AKR': 36, 'AAMU': 34, 'BAMA': 36, 'ALST': 35, 'ALCN': 35, 'AMER': 35, 'APP': 34, 'ASU': 27, 'ARIZ': 36, 'ARK': 36, 'ARST': 35, 'UAPB': 35, 'ARMY': 34, 'AUB': 36, 'APSU': 35, 'BALL': 30, 'BAY': 34, 'BELL': 32, 'BEL': 35, 'BCU': 35, 'BING': 35, 'BOIS': 35, 'BC': 35, 'BU': 35, 'BGSU': 35, 'BRAD': 34, 'BRWN': 34, 'BRY': 35, 'BUCK': 35, 'BUF': 35, 'BTLR': 35, 'BYU': 36, 'CP': 35, 'CSUB': 35, 'CSUF': 30, 'CSUN': 30, 'CBU': 35, 'CAL': 35, 'CAM': 35, 'CAN': 35, 'UCA': 36, 'CCSU': 34, 'CMU': 35, 'COFC': 34, 'CHSO': 35, 'CLT': 32, 'UTC': 35, 'CHST': 35, 'CIN': 30, 'CLEM': 35, 'CLE': 35, 'CCU': 35, 'COLG': 35, 'COLO': 35, 'CSU': 35, 'COLU': 34, 'COPP': 35, 'COR': 32, 'CREI': 34, 'DART': 34, 'DAV': 35, 'DAY': 35, 'DEL': 35, 'DSU': 35, 'DEN': 35, 'DEP': 35, 'DETM': 35, 'DRKE': 35, 'DREX': 35, 'DUKE': 34, 'DUQ': 27, 'ECU': 35, 'ETSU': 35, 'ETAM': 35, 'EIU': 35, 'EKU': 35, 'EMU': 34, 'EWU': 34, 'ELON': 35, 'EVAN': 35, 'FAIR': 35, 'FDU': 35, 'FAMU': 35, 'FAU': 35, 'FLA': 36, 'FGCU': 35, 'FIU': 34, 'FSU': 34, 'FOR': 35, 'FRES': 35, 'FUR': 35, 'GWEB': 35, 'GMU': 35, 'GW': 35, 'GTWN': 35, 'UGA': 36, 'GASO': 35, 'GAST': 35, 'GT': 35, 'GONZ': 36, 'GRAM': 35, 'GCU': 35, 'GB': 35, 'HAMP': 35, 'HARV': 34, 'HAW': 35, 'HPU': 36, 'HOF': 35, 'HC': 34, 'HCU': 35, 'HOU': 36, 'HOW': 35, 'IDST': 35, 'IDHO': 35, 'ILL': 30, 'ILST': 36, 'UIW': 35, 'IND': 31, 'INST': 35, 'IONA': 35, 'IOWA': 35, 'ISU': 34, 'IUIN': 35, 'JKST': 35, 'JAX': 35, 'JXST': 35, 'JMU': 35, 'KC': 35, 'KU': 36, 'KSU': 35, 'KENN': 35, 'KENT': 35, 'UK': 34, 'LAS': 35, 'LAF': 35, 'LAM': 35, 'LEM': 35, 'LEH': 35, 'LIB': 36, 'LIN': 35, 'LIP': 34, 'LR': 35, 'LBSU': 34, 'LIU': 34, 'LONG': 35, 'UL': 35, 'LT': 35, 'LOU': 33, 'LUC': 35, 'LMD': 35, 'LMU': 35, 'NOLA': 35, 'LSU': 35, 'ME': 35, 'MAN': 35, 'MRST': 35, 'MARQ': 36, 'MRSH': 34, 'UMES': 35, 'MD': 33, 'MASS': 35, 'MCN': 33, 'MEM': 35, 'MER': 35, 'MERC': 35, 'MRMK': 35, 'MOH': 35, 'MIA': 36, 'MSU': 34, 'MICH': 36, 'MTSU': 35, 'MILW': 35, 'MINN': 36, 'MSST': 35, 'MVSU': 35, 'MOST': 35, 'MIZ': 36, 'MONM': 35, 'MONT': 35, 'MTST': 36, 'MORE': 35, 'MORG': 35, 'MSM': 35, 'MUR': 35, 'NAVY': 34, 'NCST': 30, 'NEB': 34, 'NEV': 35, 'UNH': 35, 'NHVN': 35, 'UNM': 31, 'NMSU': 35, 'NIA': 35, 'NICH': 35, 'NJIT': 35, 'NORF': 35, 'UNA': 35, 'NCAT': 34, 'NCCU': 35, 'UNC': 36, 'UND': 35, 'NDSU': 35, 'UNF': 35, 'UNT': 35, 'NE': 32, 'NAU': 35, 'UNCO': 35, 'NIU': 35, 'UNI': 35, 'NKU': 35, 'NWST': 29, 'NU': 30, 'ND': 35, 'OAK': 35, 'OHIO': 35, 'OSU': 34, 'OU': 32, 'OKST': 36, 'ODU': 35, 'MISS': 36, 'OMA': 35, 'ORU': 35, 'ORE': 36, 'ORST': 35, 'PAC': 35, 'PSU': 35, 'PENN': 34, 'PEPP': 34, 'PITT': 35, 'PORT': 35, 'PRST': 32, 'PV': 35, 'PRES': 35, 'PRIN': 32, 'PROV': 36, 'PUR': 36, 'PFW': 35, 'QUC': 35, 'QUIN': 34, 'RAD': 35, 'URI': 32, 'RICE': 34, 'RICH': 32, 'RID': 35, 'RMU': 35, 'RUTG': 35, 'SAC': 35, 'SHU': 35, 'SFPA': 35, 'JOES': 32, 'SLU': 35, 'SMC': 35, 'SPU': 32, 'SHSU': 35, 'SAM': 35, 'SDSU': 25, 'USD': 35, 'SF': 35, 'SJSU': 35, 'SCU': 31, 'SELA': 34, 'SEA': 32, 'HALL': 35, 'SIE': 35, 'SIUE': 35, 'SMU': 36, 'USA': 35, 'SC': 35, 'SCST': 34, 'UPST': 35, 'SDAK': 34, 'SDST': 35, 'USF': 35, 'SEMO': 35, 'SIU': 35, 'USI': 35, 'SOU': 35, 'USM': 35, 'SUU': 35, 'SBU': 35, 'SJU': 30, 'STMN': 34, 'STAN': 30, 'SFA': 35, 'STET': 35, 'STO': 35, 'STBK': 35, 'SYR': 32, 'TAR': 35, 'TCU': 35, 'TEM': 34, 'TNST': 35, 'TNTC': 35, 'TENN': 34, 'TAMU': 36, 'AMCC': 29, 'TEX': 36, 'TXSO': 35, 'TXST': 34, 'TTU': 33, 'CIT': 35, 'TOL': 35, 'TOW': 35, 'TROY': 34, 'TULN': 35, 'TLSA': 35, 'UAB': 35, 'UALB': 27, 'UCD': 35, 'UCI': 35, 'UCR': 35, 'UCSD': 35, 'UCSB': 36, 'UCF': 36, 'UCLA': 36, 'CONN': 33, 'UIC': 35, 'ULM': 35, 'UML': 35, 'UMBC': 35, 'UNCA': 35, 'UNCG': 35, 'UNCW': 36, 'UNLV': 35, 'USC': 28, 'UTA': 35, 'UTM': 35, 'RGV': 35, 'USU': 35, 'UTU': 35, 'UTAH': 35, 'UVU': 35, 'UTEP': 35, 'UTSA': 35, 'VAL': 35, 'VAND': 34, 'VCU': 36, 'UVM': 35, 'NOVA': 36, 'UVA': 36, 'VT': 35, 'VMI': 35, 'WAG': 35, 'WAKE': 35, 'WASH': 35, 'WSU': 34, 'WEB': 35, 'WGA': 35, 'WVU': 37, 'WCU': 35, 'WIU': 34, 'WKU': 35, 'WMU': 35, 'WICH': 35, 'WM': 35, 'WIN': 35, 'WIS': 34, 'WOF': 35, 'WRST': 35, 'WYO': 29, 'XAV': 35, 'YALE': 36, 'YSU': 35}
SNAPSHOT_FONT_INK = {'4x5': {'A': [0, 3], 'B': [0, 3], 'C': [0, 3], 'D': [0, 3], 'E': [0, 3], 'F': [0, 3], 'G': [0, 3], 'H': [0, 3], 'I': [0, 2], 'J': [0, 3], 'K': [0, 3], 'L': [0, 3], 'M': [0, 3], 'N': [0, 3], 'O': [0, 3], 'P': [0, 3], 'Q': [0, 3], 'R': [0, 3], 'S': [0, 3], 'T': [0, 2], 't': [0, 3], 'U': [0, 3], 'V': [0, 3], 'W': [0, 3], 'X': [0, 3], 'Y': [0, 3], 'Z': [0, 3], '$': [0, 3], '0': [0, 3], '1': [1, 2], '2': [0, 3], '3': [0, 3], '4': [0, 3], '5': [0, 3], '6': [0, 3], '7': [0, 3], '8': [0, 3], '9': [0, 3], ':': [2, 2], '-': [0, 3], '+': [1, 3], '%': [0, 2], "'": [1, 2], '!': [1, 1], ',': [1, 2], '/': [0, 2], '|': [2, 2], '(': [1, 2], ')': [1, 2], '#': [0, 4], '&': [0, 5], '.': [2, 2]}, '5x7': {'A': [0, 4], 'B': [0, 4], 'C': [0, 4], 'D': [0, 4], 'E': [0, 4], 'F': [0, 4], 'G': [0, 4], 'H': [0, 4], 'I': [0, 4], 'J': [0, 4], 'K': [0, 4], 'L': [0, 4], 'M': [0, 4], 'N': [0, 4], 'O': [0, 4], 'P': [0, 4], 'Q': [0, 4], 'R': [0, 4], 'S': [0, 4], 'T': [0, 4], 'U': [0, 4], 'V': [0, 4], 'W': [0, 4], 'X': [0, 4], 'Y': [0, 4], 'Z': [0, 4], '!': [2, 2], "'": [1, 2], ',': [1, 2], '(': [1, 2], ')': [2, 3], ':': [2, 2], '|': [2, 2], '$': [0, 4], '%': [0, 4], '+': [0, 4], '-': [0, 4], '&': [0, 6], '.': [1, 2], '/': [0, 4], '^': [0, 4], '*': [0, 4], '0': [0, 4], '1': [0, 4], '2': [0, 4], '3': [0, 4], '4': [0, 4], '5': [0, 4], '6': [0, 4], '7': [0, 4], '8': [0, 4], '9': [0, 4]}, '6x8': {'A': [0, 5], 'B': [0, 5], 'C': [0, 5], 'D': [0, 5], 'E': [0, 5], 'F': [0, 5], 'G': [0, 5], 'H': [0, 5], 'I': [0, 5], 'J': [0, 5], 'K': [0, 5], 'L': [0, 5], 'M': [0, 5], 'N': [0, 5], 'O': [0, 5], 'P': [0, 5], 'Q': [0, 5], 'R': [0, 5], 'S': [0, 5], 'T': [0, 5], 'U': [0, 5], 'V': [0, 5], 'W': [0, 5], 'X': [0, 5], 'Y': [0, 5], 'Z': [0, 5], '-': [0, 5], '+': [0, 5], ':': [2, 3], '$': [0, 5], '0': [0, 5], '1': [0, 5], '2': [0, 5], '3': [0, 5], '4': [0, 5], '5': [0, 5], '6': [0, 5], '7': [0, 5], '8': [0, 5], '9': [0, 5], '@': [0, 5], '_': [0, 5], '#': [0, 4], '.': [2, 3], '(': [2, 4], ')': [1, 3], '/': [1, 4], ',': [2, 3], '%': [0, 5]}, '10x16': {'A': [0, 9], 'B': [0, 9], 'C': [0, 9], 'D': [0, 9], 'E': [0, 9], 'F': [0, 9], 'G': [0, 9], 'H': [0, 9], 'I': [0, 8], 'J': [0, 9], 'K': [0, 9], 'L': [0, 9], 'M': [0, 9], 'N': [0, 9], 'O': [0, 9], 'P': [0, 9], 'Q': [0, 9], 'R': [0, 9], 'S': [0, 9], 'T': [0, 8], 'U': [0, 9], 'V': [0, 9], 'W': [0, 9], 'X': [0, 9], 'Y': [0, 8], 'Z': [0, 9], '0': [0, 9], '1': [0, 8], '2': [0, 9], '3': [0, 9], '4': [0, 9], '5': [0, 9], '6': [0, 9], '7': [0, 9], '8': [0, 9], '9': [0, 9], '!': [3, 6], '#': [0, 9], '$': [0, 9], '%': [0, 9], '&': [0, 9], '(': [0, 4], ')': [0, 4], '*': [3, 6], '+': [1, 8], ',': [3, 5], '-': [1, 8], '.': [3, 6], '/': [0, 9], ':': [4, 5], '?': [0, 9], '@': [0, 9]}, 'picopixel': {'A': [0, 2], 'B': [0, 2], 'C': [0, 2], 'D': [0, 2], 'E': [0, 2], 'F': [0, 2], 'G': [0, 2], 'H': [0, 2], 'I': [0, 2], 'J': [0, 2], 'K': [0, 2], 'L': [0, 2], 'M': [0, 2], 'N': [0, 2], 'O': [0, 2], 'P': [0, 2], 'Q': [0, 2], 'R': [0, 2], 'S': [0, 2], 'T': [0, 2], 'U': [0, 2], 'V': [0, 2], 'W': [0, 4], 'X': [0, 2], 'Y': [0, 2], 'Z': [0, 2], '!': [1, 1], '=>': [1, 1], '$': [0, 2], '%': [0, 2], '+': [0, 2], '-': [0, 2], '.': [1, 1], '/': [0, 2], '0': [0, 2], '1': [0, 2], '2': [0, 2], '3': [0, 2], '4': [0, 2], '5': [0, 2], '6': [0, 2], '7': [0, 2], '8': [0, 2], '9': [0, 2], ':': [1, 1], '#': [0, 4], '&': [0, 2]}}

SNAPSHOT_LOGO_RIGHT.update({"BELL":37,"BEL":30,"BCU":29,"BING":37,"BOIS":32,"BC":31,"BU":31,"BGSU":31,"BRAD":28,"BRWN":28,"BRY":33,"BUCK":32,"BUF":30,"BTLR":30,"BYU":37,"CP":30,"CSUB":35,"ARK":37,"CSUF":37,"CSUN":27,"CAL":33,"CBU":37,"CAM":37,"CAN":29,"CCSU":31,"CMU":35,"COFC":28,"CHSO":33,"CLT":27})
SNAPSHOT_LOGO_RIGHT.update({"UTC":31,"CHST":35,"CIN":25,"CLEM":30,"CLE":33,"CCU":28,"COLG":31,"COLO":34,"CSU":30,"COLU":28,"COPP":37,"COR":29,"CREI":30,"DART":27,"DAY":37,"DEL":35,"DSU":33,"DEN":34,"DEP":29,"DETM":34,"DRKE":29,"DREX":33})
SNAPSHOT_LOGO_RIGHT.update({"SMC": 36})
SNAPSHOT_LOGO_RIGHT.update({"MRMK": 33})
SNAPSHOT_LOGO_RIGHT.update({"AAMU":28,"ALST":37,"ALCN":31,"APP":28,"ASU":24,"UAPB":32,"ARST":29,"ARMY":28,"APSU":28,"BALL":26})
SNAPSHOT_LOGO_RIGHT.update({"BAMA":30,"UK":32})
SNAPSHOT_LOGO_RIGHT.update({"WIS":30})
SNAPSHOT_LOGO_RIGHT.update({"ACU":34,"AKR":37,"AMER":30,"BAY":28})
SNAPSHOT_LOGO_RIGHT.update({"WRST":33,"FUR":30,"NDSU":37,"UCA":31,"TNST":31,"TEX":37,"PENN":28})

SNAPSHOT_LOGO_RIGHT.update({"ALST":35})

SNAPSHOT_LOGO_RIGHT.update({"BELL":26,"BING":30,"BRY":31,"BUCK":28,"CSUN":28,"CAN":34,"CHSO":34,"CLE":29,"DREX":34,"BEL":30,"DUKE":31})

SNAPSHOT_LOGO_RIGHT.update({"DUQ":24,"ECU":29,"ETSU":30,"ETAM":30,"EIU":32,"EKU":33,"EMU":28,"EWU":31,"ELON":33,"EVAN":32,"FAIR":31,"FDU":31,"FLA":37,"FAMU":34,"FAU":36,"FGCU":35})

SNAPSHOT_LOGO_RIGHT.update({"EWU":31})

SNAPSHOT_LOGO_RIGHT.update({"FIU":27,"FSU":30,"FOR":31,"FRES":34,"FUR":30,"GWEB":31,"GMU":30,"GW":35,"UGA":36,"GASO":37,"GAST":32,"GT":37,"GONZ":33,"GRAM":37,"GCU":37})

SNAPSHOT_LOGO_RIGHT.update({"FIU":28})

SNAPSHOT_LOGO_RIGHT.update({"GTWN":30})

SNAPSHOT_LOGO_RIGHT.update({"GASO":37})

SNAPSHOT_LOGO_RIGHT.update({"GB":33,"HAMP":29,"HARV":28,"HAW":34,"HPU":37,"HOF":37,"HC":28,"HOU":30,"HCU":29,"HOW":27,"IDHO":29,"IDST":30,"ILL":26,"ILST":37,"UIW":37,"IND":27,"INST":31,"IONA":33,"ISU":35,"IOWA":36,"IUIN":30,"JKST":37,"JAX":37,"JXST":37,"JMU":27,"KU":31,"KC":30,"KSU":34,"KENN":30,"KENT":36,"LAS":30,"LAF":37,"LAM":37,"LEM":37,"LEH":30,"LIB":31,"LIN":34,"LIP":27,"LR":37,"LIU":31,"LONG":37,"UL":37,"LT":37,"LOU":29,"LUC":33,"LMD":29,"LMU":37,"LSU":37,"ME":33,"MAN":32,"MRST":37,"MARQ":34,"MRSH":36,"MD":29,"UMES":33,"MASS":32,"MEM":32,"MER":33,"MERC":33,"MIA":37,"MOH":34,"MICH":34,"MTSU":36,"MSU":28,"MILW":30,"MINN":37,"MSST":37,"MVSU":34,"MIZ":37,"MOST":31,"MONM":33,"MONT":34,"MTST":34,"MORE":30,"MORG":36,"MSM":37,"LBSU":28})

SNAPSHOT_LOGO_RIGHT.update({"UMES":36})

SNAPSHOT_LOGO_RIGHT.update({"MUR":29,"NAVY":27,"NEB":30,"NEV":36,"UNH":32,"UNM":27,"NMSU":34,"NOLA":32,"NIA":37,"NICH":37,"NJIT":31,"NORF":30,"UNA":34,"UNC":33,"NCAT":28,"NCCU":37,"NCST":26,"UND":37,"UNF":37,"UNT":28,"NE":30,"NAU":37,"UNCO":30,"NIU":30,"UNI":35,"NKU":37,"NU":26,"NWST":33,"ND":31,"OAK":32,"OHIO":32,"OU":27,"OKST":37,"ODU":32,"MISS":31,"OMA":30,"ORU":35,"ORE":32,"ORST":37,"PAC":35,"PSU":35,"PEPP":29,"PITT":37,"PORT":28,"PRST":27,"PV":37,"PRES":30,"PRIN":28,"PROV":36,"PUR":37,"PFW":31,"QUIN":29,"QUC":27,"RAD":32,"URI":27,"RICE":28,"RICH":27,"RID":37,"RMU":37,"RUTG":31,"SAC":31,"SHU":37,"JOES":37,"SLU":30,"SPU":27,"SHSU":32,"SAM":37,"USD":30,"SDSU":35,"SF":31,"SJSU":29,"SCU":27,"SEA":28,"HALL":30,"SIE":37,"SIUE":37,"SMU":37,"USA":34,"SC":29,"SCST":28,"UPST":35,"SDAK":27,"SDST":33,"USF":33,"SEMO":37,"SELA":28,"SOU":31,"SIU":37,"USI":36,"USM":37,"SUU":37})

SNAPSHOT_LOGO_RIGHT.update({"OSU":30})

SNAPSHOT_LOGO_RIGHT.update({"NE":27})

SNAPSHOT_LOGO_RIGHT.update({"SFPA":37,"SJU":26,"STMN":29,"STAN":26,"SFA":30,"STET":30,"STO":34,"STBK":34,"SYR":27,"TAR":31,"TCU":37,"TEM":28,"TENN":30,"TNTC":33,"TAMU":30,"AMCC":31,"TXSO":30,"TXST":28,"TTU":28,"CIT":31,"TOL":37,"TOW":35,"TROY":28,"TULN":34,"TLSA":33,"UAB":32,"UALB":24,"UCD":34,"UCI":29,"UCR":30,"UCSD":30,"UCSB":36,"UCF":33,"UCLA":37,"CONN":27,"UIC":37,"ULM":35,"UML":37,"UMBC":31,"UNCA":36,"UNCG":33,"UNCW":28,"UNLV":37,"USC":29,"UTA":33,"UTM":33,"RGV":33,"UTAH":31,"USU":34,"UTU":35,"UVU":35,"UTEP":30,"UTSA":37,"VAL":29,"VAND":35,"VCU":37,"UVM":30,"NOVA":31,"UVA":33,"VT":37,"VMI":29,"WAG":37,"WAKE":35,"WASH":35,"WSU":30,"WEB":35,"WGA":35,"WVU":30,"WCU":32,"WIU":30,"WKU":34,"WMU":30,"WICH":32,"WM":32,"WIN":31,"WOF":29,"WYO":25,"XAV":33,"YALE":31,"YSU":37})

SNAPSHOT_LOGO_RIGHT.update({"IOWA":36})

def snapshot_text_edges(c, label, font, anchor, align):
    width = tight_width(c, label, font)
    start = anchor - width // 2 if align == "center" else anchor - width if align == "right" else anchor
    lo, hi = 10000, -10000
    reduction = 0
    for i in range(len(label)):
        letter = label[i]
        ink = SNAPSHOT_FONT_INK.get(font, {}).get(letter)
        if ink != None:
            offset = c.text_width(label[:i + 1], font) - c.text_width(letter, font) - reduction
            lo = min(lo, start + offset + ink[0])
            hi = max(hi, start + offset + ink[1])
        if letter == "T": reduction += 1
    return [lo, hi]

TEAM_DROPDOWN_CODES = {'Abilene Christian': 'ACU', 'Air Force': 'AF', 'Akron': 'AKR', 'Alabama': 'BAMA', 'Alabama A&M': 'AAMU', 'Alabama Birmingham': 'UAB', 'Alabama State': 'ALST', 'Alcorn State': 'ALCN', 'American University': 'AMER', 'Appalachian State': 'APP', 'Arizona': 'ARIZ', 'Arizona State': 'ASU', 'Arkansas': 'ARK', 'Arkansas State': 'ARST', 'Arkansas-Pine Bluff': 'UAPB', 'Army': 'ARMY', 'Auburn': 'AUB', 'Austin Peay': 'APSU', 'Ball State': 'BALL', 'Baylor': 'BAY', 'Bellarmine': 'BELL', 'Belmont': 'BEL', 'Bethune-Cookman': 'BCU', 'Binghamton': 'BING', 'Boise State': 'BOIS', 'Boston College': 'BC', 'Boston University': 'BU', 'Bowling Green': 'BGSU', 'Bradley': 'BRAD', 'Brigham Young': 'BYU', 'Brown': 'BRWN', 'Bryant': 'BRY', 'Bucknell': 'BUCK', 'Buffalo': 'BUF', 'Butler': 'BTLR', 'Cal Poly': 'CP', 'Cal State Bakersfield': 'CSUB', 'Cal State Fullerton': 'CSUF', 'Cal State Northridge': 'CSUN', 'California': 'CAL', 'California Baptist': 'CBU', 'California Los Angeles': 'UCLA', 'Campbell': 'CAM', 'Canisius': 'CAN', 'Central Arkansas': 'UCA', 'Central Connecticut': 'CCSU', 'Central Florida': 'UCF', 'Central Michigan': 'CMU', 'Charleston': 'COFC', 'Charleston Southern': 'CHSO', 'Charlotte': 'CLT', 'Chattanooga': 'UTC', 'Chicago State': 'CHST', 'Cincinnati': 'CIN', 'Clemson': 'CLEM', 'Cleveland State': 'CLE', 'Coastal Carolina': 'CCU', 'Colgate': 'COLG', 'Colorado': 'COLO', 'Colorado State': 'CSU', 'Columbia': 'COLU', 'Connecticut': 'CONN', 'Coppin State': 'COPP', 'Cornell': 'COR', 'Creighton': 'CREI', 'Dartmouth': 'DART', 'Davidson': 'DAV', 'Dayton': 'DAY', 'Delaware': 'DEL', 'Delaware State': 'DSU', 'Denver': 'DEN', 'Depaul': 'DEP', 'Detroit Mercy': 'DETM', 'Drake': 'DRKE', 'Drexel': 'DREX', 'Duke': 'DUKE', 'Duquesne': 'DUQ', 'East Carolina': 'ECU', 'East Tennessee State': 'ETSU', 'East Texas A&M': 'ETAM', 'Eastern Illinois': 'EIU', 'Eastern Kentucky': 'EKU', 'Eastern Michigan': 'EMU', 'Eastern Washington': 'EWU', 'Elon': 'ELON', 'Evansville': 'EVAN', 'Fairfield': 'FAIR', 'Fairleigh Dickinson': 'FDU', 'Florida': 'FLA', 'Florida A&M': 'FAMU', 'Florida Atlantic': 'FAU', 'Florida Gulf Coast': 'FGCU', 'Florida International': 'FIU', 'Florida State': 'FSU', 'Fordham': 'FOR', 'Fresno State': 'FRES', 'Furman': 'FUR', 'Gardner-Webb': 'GWEB', 'George Mason': 'GMU', 'George Washington': 'GW', 'Georgetown': 'GTWN', 'Georgia': 'UGA', 'Georgia Southern': 'GASO', 'Georgia State': 'GAST', 'Georgia Tech': 'GT', 'Gonzaga': 'GONZ', 'Grambling': 'GRAM', 'Grand Canyon': 'GCU', 'Green Bay': 'GB', 'Hampton': 'HAMP', 'Harvard': 'HARV', "Hawai'I": 'HAW', 'High Point': 'HPU', 'Hofstra': 'HOF', 'Holy Cross': 'HC', 'Houston': 'HOU', 'Houston Christian': 'HCU', 'Howard': 'HOW', 'IU Indianapolis': 'IUIN', 'Idaho': 'IDHO', 'Idaho State': 'IDST', 'Illinois': 'ILL', 'Illinois Chicago': 'UIC', 'Illinois State': 'ILST', 'Incarnate Word': 'UIW', 'Indiana': 'IND', 'Indiana State': 'INST', 'Iona': 'IONA', 'Iowa': 'IOWA', 'Iowa State': 'ISU', 'Jackson State': 'JKST', 'Jacksonville': 'JAX', 'Jacksonville State': 'JXST', 'James Madison': 'JMU', 'Kansas': 'KU', 'Kansas City': 'KC', 'Kansas State': 'KSU', 'Kennesaw State': 'KENN', 'Kent State': 'KENT', 'Kentucky': 'UK', 'La Salle': 'LAS', 'Lafayette': 'LAF', 'Lamar': 'LAM', 'Le Moyne': 'LEM', 'Lehigh': 'LEH', 'Liberty': 'LIB', 'Lindenwood': 'LIN', 'Lipscomb': 'LIP', 'Little Rock': 'LR', 'Long Beach State': 'LBSU', 'Long Island': 'LIU', 'Longwood': 'LONG', 'Louisiana': 'UL', 'Louisiana State': 'LSU', 'Louisiana Tech': 'LT', 'Louisville': 'LOU', 'Loyola Chicago': 'LUC', 'Loyola Maryland': 'LMD', 'Loyola Marymount': 'LMU', 'Maine': 'ME', 'Manhattan': 'MAN', 'Marist': 'MRST', 'Marquette': 'MARQ', 'Marshall': 'MRSH', 'Maryland': 'MD', 'Maryland Baltimore County': 'UMBC', 'Maryland Eastern Shore': 'UMES', 'Massachusetts': 'MASS', 'Mcneese': 'MCN', 'Memphis': 'MEM', 'Mercer': 'MER', 'Mercyhurst': 'MERC', 'Merrimack': 'MRMK', 'Miami (Florida)': 'MIA', 'Miami (Ohio)': 'MOH', 'Michigan': 'MICH', 'Michigan State': 'MSU', 'Middle Tennessee': 'MTSU', 'Milwaukee': 'MILW', 'Minnesota': 'MINN', 'Mississippi State': 'MSST', 'Mississippi Valley State': 'MVSU', 'Missouri': 'MIZ', 'Missouri State': 'MOST', 'Monmouth': 'MONM', 'Montana': 'MONT', 'Montana State': 'MTST', 'Morehead State': 'MORE', 'Morgan State': 'MORG', "Mount St. Mary'S": 'MSM', 'Murray State': 'MUR', 'Navy': 'NAVY', 'Nebraska': 'NEB', 'Nevada': 'NEV', 'Nevada Las Vegas': 'UNLV', 'New Hampshire': 'UNH', 'New Haven': 'NHVN', 'New Jersey Institute of Technology': 'NJIT', 'New Mexico': 'UNM', 'New Mexico State': 'NMSU', 'New Orleans': 'NOLA', 'Niagara': 'NIA', 'Nicholls': 'NICH', 'Norfolk State': 'NORF', 'North Alabama': 'UNA', 'North Carolina': 'UNC', 'North Carolina A&T': 'NCAT', 'North Carolina Central': 'NCCU', 'North Carolina State': 'NCST', 'North Dakota': 'UND', 'North Dakota State': 'NDSU', 'North Florida': 'UNF', 'North Texas': 'UNT', 'Northeastern': 'NE', 'Northern Arizona': 'NAU', 'Northern Colorado': 'UNCO', 'Northern Illinois': 'NIU', 'Northern Iowa': 'UNI', 'Northern Kentucky': 'NKU', 'Northwestern': 'NU', 'Northwestern State': 'NWST', 'Notre Dame': 'ND', 'Oakland': 'OAK', 'Ohio': 'OHIO', 'Ohio State': 'OSU', 'Oklahoma': 'OU', 'Oklahoma State': 'OKST', 'Old Dominion': 'ODU', 'Ole Miss': 'MISS', 'Omaha': 'OMA', 'Oral Roberts': 'ORU', 'Oregon': 'ORE', 'Oregon State': 'ORST', 'Pacific': 'PAC', 'Penn State': 'PSU', 'Pennsylvania': 'PENN', 'Pepperdine': 'PEPP', 'Pittsburgh': 'PITT', 'Portland': 'PORT', 'Portland State': 'PRST', 'Prairie View A&M': 'PV', 'Presbyterian': 'PRES', 'Princeton': 'PRIN', 'Providence': 'PROV', 'Purdue': 'PUR', 'Purdue Fort Wayne': 'PFW', 'Queens': 'QUC', 'Quinnipiac': 'QUIN', 'Radford': 'RAD', 'Rhode Island': 'URI', 'Rice': 'RICE', 'Richmond': 'RICH', 'Rider': 'RID', 'Robert Morris': 'RMU', 'Rutgers': 'RUTG', 'Sacramento State': 'SAC', 'Sacred Heart': 'SHU', 'Saint Francis': 'SFPA', "Saint Joseph'S": 'JOES', 'Saint Louis': 'SLU', "Saint Mary's": 'SMC', "Saint Peter'S": 'SPU', 'Sam Houston': 'SHSU', 'Samford': 'SAM', 'San Diego': 'USD', 'San Diego State': 'SDSU', 'San Francisco': 'SF', 'San José State': 'SJSU', 'Santa Clara': 'SCU', 'Seattle U': 'SEA', 'Seton Hall': 'HALL', 'Siena': 'SIE', 'Siu Edwardsville': 'SIUE', 'South Alabama': 'USA', 'South Carolina': 'SC', 'South Carolina State': 'SCST', 'South Carolina Upstate': 'UPST', 'South Dakota': 'SDAK', 'South Dakota State': 'SDST', 'South Florida': 'USF', 'Southeast Missouri State': 'SEMO', 'Southeastern Louisiana': 'SELA', 'Southern': 'SOU', 'Southern California': 'USC', 'Southern Illinois': 'SIU', 'Southern Indiana': 'USI', 'Southern Methodist': 'SMU', 'Southern Miss': 'USM', 'Southern Utah': 'SUU', 'St. Bonaventure': 'SBU', "St. John's": 'SJU', 'St. Thomas': 'STMN', 'Stanford': 'STAN', 'Stephen F. Austin': 'SFA', 'Stetson': 'STET', 'Stonehill': 'STO', 'Stony Brook': 'STBK', 'Syracuse': 'SYR', 'Tarleton State': 'TAR', 'Temple': 'TEM', 'Tennessee': 'TENN', 'Tennessee State': 'TNST', 'Tennessee Tech': 'TNTC', 'Texas': 'TEX', 'Texas A&M': 'TAMU', 'Texas A&M-Corpus Christi': 'AMCC', 'Texas Christian': 'TCU', 'Texas El Paso': 'UTEP', 'Texas San Antonio': 'UTSA', 'Texas Southern': 'TXSO', 'Texas State': 'TXST', 'Texas Tech': 'TTU', 'The Citadel': 'CIT', 'Toledo': 'TOL', 'Towson': 'TOW', 'Troy': 'TROY', 'Tulane': 'TULN', 'Tulsa': 'TLSA', 'UC Davis': 'UCD', 'UC Irvine': 'UCI', 'UC Riverside': 'UCR', 'UC San Diego': 'UCSD', 'UC Santa Barbara': 'UCSB', 'UNC Asheville': 'UNCA', 'UNC Greensboro': 'UNCG', 'UNC Wilmington': 'UNCW', 'UT Rio Grande Valley': 'RGV', 'Ualbany': 'UALB', 'Ul Monroe': 'ULM', 'Umass Lowell': 'UML', 'Ut Arlington': 'UTA', 'Ut Martin': 'UTM', 'Utah': 'UTAH', 'Utah State': 'USU', 'Utah Tech': 'UTU', 'Utah Valley': 'UVU', 'Valparaiso': 'VAL', 'Vanderbilt': 'VAND', 'Vermont': 'UVM', 'Villanova': 'NOVA', 'Virginia': 'UVA', 'Virginia Commonwealth': 'VCU', 'Virginia Military Institute': 'VMI', 'Virginia Tech': 'VT', 'Wagner': 'WAG', 'Wake Forest': 'WAKE', 'Washington': 'WASH', 'Washington State': 'WSU', 'Weber State': 'WEB', 'West Georgia': 'WGA', 'West Virginia': 'WVU', 'Western Carolina': 'WCU', 'Western Illinois': 'WIU', 'Western Kentucky': 'WKU', 'Western Michigan': 'WMU', 'Wichita State': 'WICH', 'William & Mary': 'WM', 'Winthrop': 'WIN', 'Wisconsin': 'WIS', 'Wofford': 'WOF', 'Wright State': 'WRST', 'Wyoming': 'WYO', 'Xavier': 'XAV', 'Yale': 'YALE', 'Youngstown State': 'YSU'}

SNAPSHOT_LOGO_RIGHT.update({"NDSU":29})
SNAPSHOT_LOGO_RIGHT.update({"ARIZ":31})
SNAPSHOT_LOGO_RIGHT.update({"AUB":31})

def selected_team(ctx):
    value = ctx.inputs.get("team", "Texas")
    return TEAM_DROPDOWN_CODES.get(value, value.upper())

def your_team_page(_projection, c, ctx, slot):
    team = selected_team(ctx)
    if team not in TEAM_LOGO_FILES: team = "TEX"
    info = bracket_slot_for(_projection, team)
    opening = your_team_opening(_projection, team)
    destination = your_team_demo_destination(_projection, team) if opening != None else None
    overall = _projection["TEAM_OVERALL_SEEDS"].get(team, 0)
    c.fill("black")
    games = []
    if info != None:
        for region in _projection["REGION_MATCHUPS"]:
            if region[0] == info[0]: games = region[4]
    if slot == 1:
        # A wider identity area and six equal 28x15 cells. Shared grid borders
        # leave every metric the same 27x14 interior, including the bottom row.
        name = TEAM_NAMES.get(team, team)
        # Keep the identity inside x0..38 for every school. Wider names use
        # their team code rather than crossing into the enlarged seed column.
        if tight_width(c, name, "4x5") > 39: name = team
        name_font = "5x7" if tight_width(c, name, "5x7") <= 39 else "4x5"
        your_team_text(c, name, 19, 0, font = name_font, color = LIGHT, align = "center")
        your_team_mark(c, team, 0, 8, 38, 24)
        seed = str(info[1]) if info != None else str(opening[0]) if opening != None else "--"
        metrics = your_team_resume(team, include_wab = True)
        # Shared centers keep identity, seed, and metadata independent.
        record = str(metrics.get("RECORD", "--"))
        record_font = "4x5" if tight_width(c, record, "4x5") <= 27 else "picopixel"
        your_team_text(c, record, 105, 13, font = record_font, color = LIGHT, align = "right")
        region_label = info[0] if info != None else "OPEN RD" if opening != None else "OUTSIDE"
        your_team_text(c, region_label, 105, 0, font = "4x5", color = BLUE, align = "right")
        # Invisible boundaries follow the furthest inward VISIBLE pixel:
        # name/logo on the left, region/record/overall on the right.
        overall_value = str(overall) if overall > 0 else "--"
        identity_right = max(SNAPSHOT_LOGO_RIGHT.get(team, 37), your_team_text_edges(c, name, name_font, 19, "center")[1])
        metadata_left = min(your_team_text_edges(c, region_label, "4x5", 105, "right")[0], your_team_text_edges(c, "OVR " + overall_value, "4x5", 105, "right")[0], your_team_text_edges(c, record, record_font, 105, "right")[0])
        seed_font = "10x16" if seed != "--" else "4x5"
        number_edges = your_team_text_edges(c, seed, seed_font, 0, "center")
        label_edges = your_team_text_edges(c, "SEED", "6x8", 0, "center")
        stack_left = min(number_edges[0], label_edges[0])
        stack_right = max(number_edges[1], label_edges[1])
        seed_center = (identity_right + metadata_left - stack_left - stack_right) // 2
        your_team_text(c, seed, seed_center, 3 if seed != "--" else 7, font = seed_font, color = LIGHT, align = "center")
        your_team_text(c, "SEED", seed_center, 22, font = "6x8", color = BLUE, align = "center")
        for x in [107, 135, 163, 191]:
            c.line(x, 0, x, 30, color = "#12345c")
        for y in [15]:
            c.line(107, y, 191, y, color = "#12345c")
        for row, labels in enumerate([["SOR", "NET", "SOS"], ["WAB", "Q1", "Q2"]]):
            for column, label in enumerate(labels):
                center = 121 + column * 28
                top = row * 15
                display_label = label
                your_team_text(c, display_label, center, top if row == 0 else top + 1, font = "4x5", color = BLUE, align = "center")
                value = str(metrics.get(label, "--"))
                font = "5x7" if tight_width(c, value, "5x7") <= 25 else "4x5" if tight_width(c, value, "4x5") <= 25 else "picopixel"
                your_team_text(c, value, center, top + 7 if font == "5x7" else top + 8, font = font, color = LIGHT, align = "center")
        overall_text = "OVR " + overall_value
        your_team_text(c, overall_text, 105, 27, font = "4x5", color = "#B0B0B0", align = "right")
    elif slot == 2:
        if info == None and opening == None:
            your_team_notice(c, team, "FIRST MATCHUP", "NOT IN FIELD", "NO MATCHUP PROJECTED")
            return
        seed = str(info[1]) if info != None else str(opening[0])
        opponent = info[2] if info != None else opening[1]
        opp_seed = str(info[3]) if info != None else seed
        round_label = "R64" if info != None and opponent == "TBD" else "ROUND OF 64" if info != None else "OPENING ROUND"
        your_team_text(c, round_label, 96, 0, font = "4x5", color = BLUE, align = "center")
        your_team_text(c, "VS", 96, 15, font = "3x4", color = MUTED, align = "center")
        for index, item in enumerate([[team, seed], [opponent, opp_seed]]):
            left = 8 + index * 96
            if item[0] == "TBD":
                your_team_options(_projection, c, item[1], left, 0, 80, True, info[0] if info != None else "")
                c.line(left, 31, left + 79, 31, color = BLUE)
                continue
            your_team_text(c, item[1], left if index == 0 else left + 79, 1, font = "4x5", color = LIGHT, align = "left" if index == 0 else "right")
            # Keep the short, wide Mustang below the longer opening title;
            # preserve its native size and horizontal center, and all seeds.
            logo_top = 2 if round_label == "OPENING ROUND" and item[0] == "SMU" else 0
            your_team_mark(c, item[0], left + 23, logo_top, 34, 24)
            your_team_name(c, item[0], left + 40, 26, 80, center = True)
            c.line(left, 31, left + 79, 31, color = BLUE)
    elif slot == 3:
        if info == None:
            if destination != None:
                opponent = destination[2]
                your_team_round64_opponent(_projection, c, opponent, destination[3])
            else:
                status = "NO BID PROJECTED"
                for group in _projection["BUBBLE_GROUPS"][:4]:
                    if team in group[1:]: status = group[0]
                your_team_notice(c, team, "PROJECTION STATUS", "OUTSIDE FIELD", status)
            return
        your_team_text(c, "ROUND OF 32", 96, 0, font = "4x5", color = BLUE, align = "center")
        c.line(8, 6, 184, 6, color = "#12345c")
        next_index = info[4] + 1 if info[4] % 2 == 0 else info[4] - 1
        pair = games[next_index]
        your_team_round32_candidates(_projection, c, pair, info[0])
    else:
        if info == None:
            if destination != None:
                paired = destination[1] + 1 if destination[1] % 2 == 0 else destination[1] - 1
                game = destination[4][paired]
                your_team_text(c, "ROUND OF 32", 96, 0, font = "4x5", color = BLUE, align = "center")
                c.line(8, 6, 184, 6, color = "#12345c")
                your_team_round32_candidates(_projection, c, game, destination[0])
            else:
                your_team_notice(c, team, "SELECTION WATCH", "NO REGIONAL PATH", "NEEDS A PROJECTED BID")
            return
        your_team_text(c, "SWEET 16", 96, 0, font = "4x5", color = BLUE, align = "center")
        c.line(8, 6, 184, 6, color = "#12345c")
        pair_base = (info[4] // 2) * 2
        future_base = pair_base + 2 if pair_base % 4 == 0 else pair_base - 2
        possibilities = [games[future_base], games[future_base + 1]]
        your_team_sweet_candidates(_projection, c, possibilities, info[0])

BUBBLE_GROUPS = [['LAST FOUR BYES', 'UNC', 'TAMU', 'CIN', 'CLEM'], ['LAST FOUR IN', 'WIS', 'WVU', 'MISS', 'SMU'], ['FIRST FOUR OUT', 'SLU', 'UGA', 'XAV', 'MINN'], ['NEXT FOUR OUT', 'ASU', 'NCST', 'LSU', 'OKST'], ['SOURCE SNAPSHOT', 'KYLE', '76 TEAMS', '', '']]

BUBBLE_EXTRA = [['CUT LINE', 'LAST IN: USU', 'FIRST OUT: UGA'], ['MOVEMENT', 'HISTORY NEEDED', 'KYLE DRAFT'], ['SOURCE STATUS', 'READ ONLY SHEET', 'DRAFT PREVIEW']]

def bubble_group_page(_projection, c, slot):
    group = _projection["BUBBLE_GROUPS"][slot - 1]
    c.fill("black")
    c.rect(8, 4, 184, 27, fill = DARK)
    c.rect(8, 4, 10, 27, fill = BLUE)
    tight_text(c, "ESPN10/6", 184, 1, font = "3x4", color = MUTED, align = "right")
    tight_text(c, group[0], 18, 6, font = "4x5", color = LIGHT)
    for i in range(1, 5):
        if group[i]:
            tight_text(c, group[i], 18 + ((i - 1) % 2) * 82, 15 + ((i - 1) // 2) * 8, font = "4x5", color = TEAM_COLORS.get(group[i], MUTED))

def bubble_extra_page(_projection, c, slot):
    item = _projection["BUBBLE_EXTRA"][slot - 1]
    c.fill("black")
    c.rect(8, 4, 184, 27, fill = DARK)
    c.rect(8, 4, 10, 27, fill = BLUE)
    tight_text(c, "ESPN10/6", 184, 1, font = "3x4", color = MUTED, align = "right")
    tight_text(c, item[0], 18, 6, font = "4x5", color = LIGHT)
    if item[0] == "CUT LINE":
        tight_text(c, "LAST IN:", 18, 15, font = "4x5", color = BLUE)
        tight_text(c, "OKST", 54, 15, font = "4x5", color = TEAM_COLORS.get("OKST", BLUE))
        tight_text(c, "FIRST OUT:", 101, 15, font = "4x5", color = MUTED)
        tight_text(c, "ORE", 145, 15, font = "4x5", color = TEAM_COLORS.get("ORE", MUTED))
    else:
        tight_text(c, item[1], 18, 15, font = "4x5", color = BLUE)
        tight_text(c, item[2], 101, 15, font = "4x5", color = MUTED)

# Same WVU silhouette, drawn in its gold secondary color for black backgrounds.
BUBBLE_WVU_GOLD = [[0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0],[0,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0],[0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0],[0,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,0],[0,0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,0],[0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0],[0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,1,1,1,1,1,1,1,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,0],[0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,0],[0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0]]

def bubble_cutoff_page(_projection, c, group_index, half):
    # Two teams per screen gives each school a real logo and full name.
    # Overall seed numbers stay absent until the source supplies them.
    group = _projection["BUBBLE_GROUPS"][group_index]
    accent = BLUE if group_index == 1 else RED
    c.fill("black")
    tight_text(c, group[0], 8, 0, font = "4x5", color = accent)
    tight_text(c, str(half + 1) + "/2", 184, 0, font = "4x5", color = BLUE, align = "right")
    c.line(8, 6, 184, 6, color = "#12345c")
    c.line(8, 6, 26, 6, color = accent)
    c.line(96, 9, 96, 29, color = "#12345c")
    full_names = {"WVU": ["WEST", "VIRGINIA"], "CREI": ["CREIGHTON"], "NCST": ["NC STATE"], "OKST": ["OKLAHOMA", "STATE"], "ORE": ["OREGON"], "MD": ["MARYLAND"], "ASU": ["ARIZONA", "STATE"], "MISS": ["OLE MISS"]}
    for column in range(2):
        team = group[1 + half * 2 + column]
        left = 8 + column * 96
        if team == "WVU" and team not in USER_LOGO_FRAMES:
            c.bitmap(BUBBLE_WVU_GOLD, left, 9, color = "#EAAA00")
        else:
            draw_team_logo(c, team, left, 9, 29, 22)
        name_x = left + 34
        lines = full_names.get(team, [TEAM_NAMES.get(team, team)])
        name_color = full_field_color(team)
        if len(lines) == 1:
            tight_text(c, lines[0], name_x, 17, font = "4x5", color = name_color)
        else:
            tight_text(c, lines[0], name_x, 12, font = "4x5", color = name_color)
            tight_text(c, lines[1], name_x, 23, font = "4x5", color = name_color)

def bubble_pair_page(_projection, c, first_group_index, second_group_index):
    first = _projection["BUBBLE_GROUPS"][first_group_index]
    second = _projection["BUBBLE_GROUPS"][second_group_index]
    category_colors = [GREEN, BLUE, GOLD, RED]
    first_color = category_colors[first_group_index]
    second_color = category_colors[second_group_index]
    c.fill("black")
    c.line(8, 6, 91, 6, color = first_color)
    c.line(101, 6, 184, 6, color = second_color)
    tight_text(c, first[0], 8, 0, font = "4x5", color = first_color)
    tight_text(c, second[0], 101, 0, font = "4x5", color = second_color)
    for i in range(1, 5):
        y = 8 + (i - 1) * 6
        first_name = TEAM_NAMES.get(first[i], first[i])
        second_name = TEAM_NAMES.get(second[i], second[i])
        tight_text(c, first_name, 8, y, font = "5x5b", color = full_field_color(first[i]))
        tight_text(c, second_name, 101, y, font = "5x5b", color = full_field_color(second[i]))

TEAM_CONFERENCES_2027 = {"AAMU":"SWAC","ACU":"UAC","AF":"MWC","AKR":"MAC","ALCN":"SWAC","ALST":"SWAC","AMCC":"SLC","AMER":"PAT","APP":"SUNBELT","APSU":"UAC","ARIZ":"B12","ARK":"SEC","ARMY":"PAT","ARST":"SUNBELT","ASU":"B12","AUB":"SEC","BALL":"MAC","BAMA":"SEC","BAY":"B12","BC":"ACC","BCU":"SWAC","BEL":"MVC","BELL":"ASUN","BGSU":"MAC","BING":"AEAST","BOIS":"PAC12","BRAD":"MVC","BRWN":"IVY","BRY":"AEAST","BTLR":"BE","BU":"PAT","BUCK":"PAT","BUF":"MAC","BYU":"B12","CAL":"ACC","CAM":"CAA","CAN":"MAAC","CBU":"BIGWEST","CCSU":"NEC","CCU":"SUNBELT","CHSO":"BSOUTH","CHST":"NEC","CIN":"B12","CIT":"SOCON","CLE":"HOR","CLEM":"ACC","CLT":"AAC","CMU":"MAC","COFC":"CAA","COLG":"PAT","COLO":"B12","COLU":"IVY","CONN":"BE","COPP":"MEAC","COR":"IVY","CP":"BIGWEST","CREI":"BE","CSU":"PAC12","CSUB":"BIGWEST","CSUF":"BIGWEST","CSUN":"BIGWEST","DART":"IVY","DAV":"A10","DAY":"A10","DEL":"CUSA","DEN":"WCC","DEP":"BE","DETM":"HOR","DREX":"CAA","DRKE":"MVC","DSU":"MEAC","DUKE":"ACC","DUQ":"A10","ECU":"AAC","EIU":"OVC","EKU":"UAC","ELON":"CAA","EMU":"MAC","ETAM":"SLC","ETSU":"SOCON","EVAN":"MVC","EWU":"BSKY","FAIR":"MAAC","FAMU":"SWAC","FAU":"AAC","FDU":"NEC","FGCU":"ASUN","FIU":"CUSA","FLA":"SEC","FOR":"A10","FRES":"PAC12","FSU":"ACC","FUR":"SOCON","GASO":"SUNBELT","GAST":"SUNBELT","GB":"HOR","GCU":"MWC","GMU":"A10","GONZ":"PAC12","GRAM":"SWAC","GT":"ACC","GTWN":"BE","GW":"A10","GWEB":"BSOUTH","HALL":"BE","HAMP":"CAA","HARV":"IVY","HAW":"MWC","HC":"PAT","HCU":"SLC","HOF":"CAA","HOU":"B12","HOW":"MEAC","HPU":"BSOUTH","IDHO":"BSKY","IDST":"BSKY","ILL":"B10","ILST":"MVC","IND":"B10","INST":"MVC","IONA":"MAAC","IOWA":"B10","ISU":"B12","IUIN":"HOR","JAX":"ASUN","JKST":"SWAC","JMU":"SUNBELT","JOES":"A10","JXST":"CUSA","KC":"SUMM","KENN":"CUSA","KENT":"MAC","KSU":"B12","KU":"B12","LAF":"PAT","LAM":"SLC","LAS":"A10","LBSU":"BIGWEST","LEH":"PAT","LEM":"NEC","LIB":"CUSA","LIN":"OVC","LIP":"ASUN","LIU":"NEC","LMD":"PAT","LMU":"WCC","LONG":"BSOUTH","LOU":"ACC","LR":"UAC","LSU":"SEC","LT":"SUNBELT","LUC":"A10","MAN":"MAAC","MARQ":"BE","MASS":"MAC","MCN":"SLC","MD":"B10","ME":"AEAST","MEM":"AAC","MER":"SOCON","MERC":"NEC","MIA":"ACC","MICH":"B10","MILW":"HOR","MINN":"B10","MISS":"SEC","MIZ":"SEC","MOH":"MAC","MONM":"CAA","MONT":"BSKY","MORE":"OVC","MORG":"MEAC","MOST":"CUSA","MRMK":"MAAC","MRSH":"SUNBELT","MRST":"MAAC","MSM":"MAAC","MSST":"SEC","MSU":"B10","MTST":"BSKY","MTSU":"CUSA","MUR":"MVC","MVSU":"SWAC","NAU":"BSKY","NAVY":"PAT","NCAT":"CAA","NCCU":"MEAC","NCST":"ACC","ND":"ACC","NDSU":"SUMM","NE":"CAA","NEB":"B10","NEV":"MWC","NHVN":"NEC","NIA":"MAAC","NICH":"SLC","NIU":"HOR","NJIT":"AEAST","NKU":"HOR","NMSU":"CUSA","NOLA":"SLC","NORF":"MEAC","NOVA":"BE","NU":"B10","NWST":"SLC","OAK":"HOR","ODU":"SUNBELT","OHIO":"MAC","OKST":"B12","OMA":"SUMM","ORE":"B10","ORST":"PAC12","ORU":"SUMM","OSU":"B10","OU":"SEC","PAC":"WCC","PENN":"IVY","PEPP":"WCC","PFW":"HOR","PITT":"ACC","PORT":"WCC","PRES":"BSOUTH","PRIN":"IVY","PROV":"BE","PRST":"BSKY","PSU":"B10","PUR":"B10","PV":"SWAC","QUC":"ASUN","QUIN":"MAAC","RAD":"BSOUTH","RGV":"SLC","RICE":"AAC","RICH":"A10","RID":"MAAC","RMU":"HOR","RUTG":"B10","SAC":"BIGWEST","SAM":"SOCON","SBU":"A10","SC":"SEC","SCST":"MEAC","SCU":"WCC","SDAK":"SUMM","SDST":"SUMM","SDSU":"PAC12","SEA":"WCC","SELA":"SLC","SEMO":"OVC","SF":"WCC","SFA":"SLC","SHSU":"CUSA","SHU":"MAAC","SIE":"MAAC","SIU":"MVC","SIUE":"OVC","SJSU":"MWC","SJU":"BE","SLU":"A10","SMC":"WCC","SMU":"ACC","SOU":"SWAC","SPU":"MAAC","STAN":"ACC","STBK":"CAA","STET":"ASUN","STMN":"SUMM","STO":"NEC","SUU":"BSKY","SYR":"ACC","TAMU":"SEC","TAR":"UAC","TCU":"B12","TEM":"AAC","TENN":"SEC","TEX":"SEC","TLSA":"AAC","TNST":"OVC","TNTC":"SOCON","TOL":"MAC","TOW":"CAA","TROY":"SUNBELT","TTU":"B12","TULN":"AAC","TXSO":"SWAC","TXST":"PAC12","UAB":"AAC","UALB":"AEAST","UAPB":"SWAC","UCA":"UAC","UCD":"MWC","UCF":"B12","UCI":"BIGWEST","UCLA":"B10","UCR":"BIGWEST","UCSB":"BIGWEST","UCSD":"BIGWEST","UGA":"SEC","UIC":"MVC","UIW":"SLC","UK":"SEC","UL":"SUNBELT","ULM":"SUNBELT","UMBC":"AEAST","UMES":"MEAC","UML":"AEAST","UNA":"UAC","UNC":"ACC","UNCA":"BSOUTH","UNCG":"SOCON","UNCO":"BSKY","UNCW":"CAA","UND":"SUMM","UNF":"ASUN","UNH":"AEAST","UNI":"MVC","UNLV":"MWC","UNM":"MWC","UNT":"AAC","UPST":"BSOUTH","URI":"A10","USA":"SUNBELT","USC":"B10","USD":"WCC","USF":"AAC","USI":"OVC","USM":"SUNBELT","USU":"PAC12","UTA":"UAC","UTAH":"B12","UTC":"SOCON","UTEP":"MWC","UTM":"OVC","UTSA":"AAC","UTU":"BSKY","UVA":"ACC","UVM":"AEAST","UVU":"BIGWEST","VAL":"MVC","VAND":"SEC","VCU":"A10","VMI":"SOCON","VT":"ACC","WAG":"NEC","WAKE":"ACC","WASH":"B10","WCU":"SOCON","WEB":"BSKY","WGA":"UAC","WICH":"AAC","WIN":"BSOUTH","WIS":"B10","WIU":"OVC","WKU":"CUSA","WM":"CAA","WMU":"MAC","WOF":"SOCON","WRST":"HOR","WSU":"PAC12","WVU":"B12","WYO":"MWC","XAV":"BE","YALE":"IVY","YSU":"HOR"}

def conference_bid_counts(_projection):
    counts = {}
    # TEAM_INFO has one entry per selected team, including BOTH participants
    # in each Opening Round slot. Do not count only the 64 bracket slots.
    for team in _projection["TEAM_INFO"]:
        name = TEAM_CONFERENCES_2027.get(team, "UNKNOWN")
        counts[name] = counts.get(name, 0) + 1
    ranked = sorted([[-count, name] for name, count in counts.items()])
    return [[item[1], -item[0]] for item in ranked]

def bubble_four_team_page(_projection, c, group_index):
    group = _projection["BUBBLE_GROUPS"][group_index]
    teams = [[code, TEAM_LOGO_FILES[code], full_field_color(code)] for code in group[1:5]]
    # Reuse the approved Top 4 Seeds renderer, including its logo sizing,
    # bold team lettering, optical offsets, dividers and overall-rank position.
    # A bubble list's column position is NOT a tournament seed, so omit 1-4.
    title = ["bubble-title-byes.png", "bubble-title-in-green.png", "bubble-title-out.png"][group_index]
    # Kyle confirmed that the First Four Out follow AQs 51-76 as 77-80.
    # Scope these display ranks to Bubble; never mutate the field's rankings.
    bubble_projection = _projection
    if group_index == 2:
        bubble_projection = dict(_projection)
        ranks = dict(_projection["TEAM_OVERALL_SEEDS"])
        for index, code in enumerate(group[1:5]):
            ranks[code] = 77 + index
        bubble_projection["TEAM_OVERALL_SEEDS"] = ranks
    region_page(bubble_projection, c, "", "", teams, title, show_seed = False, bubble_rank_spacing = True)

# Conference-brand accents on black: use SEC gold and BIG EAST red rather than
# near-black navy. PAC12 uses the user's dark-grey treatment. These
# are chart colors, not modified conference logos.
CONFERENCE_CHART_COLORS = {
    "B10": "#0088CE",
    "SEC": "#FFC72C",
    "B12": "#C41230",
    "ACC": "#003DA6",
    "BE": "#E41C39",
    "PAC12": "#41464D",
    "A10": "#DA291C",
    "AAC": "#004B8D",
}

def conference_layout_rows(_projection, preview):
    # Explicit local geometry tests, never imported into Kyle's projection.
    # Keep 50 multi-bid selections in each example; these are not predictions.
    if preview == "7 conferences - layout example":
        return [["B10", 11], ["SEC", 11], ["B12", 10], ["ACC", 7], ["BE", 6], ["A10", 3], ["PAC12", 2]]
    if preview == "8 conferences - layout example":
        return [["B10", 11], ["SEC", 10], ["B12", 9], ["ACC", 7], ["BE", 6], ["A10", 3], ["AAC", 2], ["PAC12", 2]]
    return conference_bid_counts(_projection)

def bubble_conference_page(_projection, c, preview = "Actual projection"):
    c.fill("black")
    rows = conference_layout_rows(_projection, preview)
    c.image("bubble-title-multibid.png", 0, 0, w = 46, h = 32)
    c.line(46, 0, 46, 31, color = GRID)
    multiple = [row for row in rows if row[1] > 1]
    visible = multiple[:8]
    grouped = len(multiple) > 8
    if grouped:
        remaining = 0
        for row in multiple[7:]:
            remaining += row[1]
        visible = multiple[:7] + [["OTHER", remaining]]
    # Proportional plot above a common label base, joined without a divider.
    # Conference abbreviations share one outlined 4x5 baseline.
    maximum = max([row[1] for row in visible] + [1])
    # Use one integer pitch per layout instead of rounding each column center
    # separately, which alternated the gaps by a pixel. Center the whole group.
    # Use the panel's full remaining width, including the former 6px right
    # margin. Seven keeps the 18px bars; eight fits 17px with 1px clear gaps.
    chart_width = 144
    bar_width = 18 if len(visible) <= 7 else 17
    bar_gap = (chart_width - len(visible) * bar_width) // max(1, len(visible) - 1)
    # Tighten the six-conference gaps to 3px; the freed space is split
    # equally between the left and right ends of the centered group.
    if len(visible) == 6:
        bar_gap = 3
    group_width = len(visible) * bar_width + max(0, len(visible) - 1) * bar_gap
    group_left = 48 + (chart_width - group_width) // 2
    for i in range(len(visible)):
        label, count = visible[i]
        bar_left = group_left + i * (bar_width + bar_gap)
        center = bar_left + bar_width // 2
        accent = CONFERENCE_CHART_COLORS.get(label, BLUE)
        height = max(5, (count * 21 + maximum // 2) // maximum)
        top = 21 - height
        c.rect(bar_left, top, bar_left + bar_width - 1, 31, fill = accent)
        # One size down from 5x7, consistent even on the shortest bars.
        number_font = "4x5"
        ink = "white"
        # Center horizontally in the bar, two pixels below its top edge.
        number_x = bar_left + (bar_width - c.text_width(str(count), number_font)) // 2
        number_y = top + 2
        c.text_stroke(str(count), number_x, number_y, font = number_font,
            color = ink, stroke = "black", thickness = 1, align = "left")
        label = "P12" if label == "PAC12" else ("B1G" if label == "B10" else label)
        label_font = "4x5" if tight_width(c, label, "4x5") <= 19 else "3x4"
        c.text_stroke(label, center, 27, font = label_font, color = ink, stroke = "black", thickness = 1, align = "center")
    if not visible:
        tight_text(c, "NO MULTI-BID LEAGUES", 117, 13, font = "3x4", color = MUTED, align = "center")

def opening_round_matchup(c, left, width, seed):
    # Each matchup gets its own bracket. Team baselines and connector endpoints
    # stay fixed across regions; only the space between matchups adapts.
    center = left + width // 2
    name_x = center - 15
    join_x = center + 11
    tight_text(c, str(seed) + " SEED", center, 8, font = "4x5", color = MUTED, align = "center")
    tight_text(c, "TBD", name_x, 14, font = "5x7", color = LIGHT)
    tight_text(c, "TBD", name_x, 23, font = "5x7", color = LIGHT)
    c.line(name_x, 22, join_x, 22, color = BLUE)
    c.line(name_x, 31, join_x, 31, color = BLUE)
    c.line(join_x, 22, join_x, 31, color = BLUE)
    c.line(join_x, 26, join_x + 5, 26, color = BLUE)

OPENING_LOGO_EDGES = {"ACU":[0,23],"AF":[0,22],"AKR":[0,23],"AAMU":[1,21],"BAMA":[0,23],"ALST":[0,23],"ALCN":[0,23],"AMER":[0,23],"APP":[1,22],"ASU":[5,17],"ARIZ":[1,22],"ARK":[0,23],"ARST":[0,23],"UAPB":[0,23],"ARMY":[1,21],"AUB":[0,22],"APSU":[1,22],"BALL":[3,20],"BAY":[1,21],"BELL":[3,20],"BEL":[0,23],"BCU":[0,23],"BING":[0,23],"BOIS":[0,23],"BC":[0,23],"BU":[0,23],"BGSU":[0,23],"BRAD":[1,21],"BRWN":[2,21],"BRY":[0,23],"BUCK":[1,22],"BUF":[0,23],"BTLR":[0,23],"BYU":[0,23],"CP":[0,23],"CSUB":[0,23],"CSUF":[0,23],"CSUN":[1,21],"CBU":[0,23],"CAL":[0,23],"CAM":[0,23],"CAN":[0,23],"UCA":[0,23],"CCSU":[0,23],"CMU":[0,23],"COFC":[1,21],"CHSO":[0,23],"CLT":[2,21],"UTC":[0,23],"CHST":[0,23],"CIN":[4,19],"CLEM":[0,23],"CLE":[0,22],"CCU":[1,22],"COLG":[0,23],"COLO":[0,23],"CSU":[0,23],"COLU":[1,21],"COPP":[0,23],"COR":[0,23],"CREI":[0,23],"DART":[2,21],"DAV":[1,22],"DAY":[0,23],"DEL":[0,23],"DSU":[0,23],"DEN":[0,23],"DEP":[0,23],"DETM":[0,23],"DRKE":[0,22],"DREX":[0,23],"DUKE":[0,23],"DUQ":[6,17],"ECU":[0,23],"ETSU":[0,23],"ETAM":[0,23],"EIU":[0,23],"EKU":[0,23],"EMU":[1,22],"EWU":[0,23],"ELON":[0,23],"EVAN":[0,23],"FAIR":[0,23],"FDU":[0,23],"FAMU":[0,23],"FAU":[0,23],"FLA":[0,23],"FGCU":[0,23],"FIU":[1,22],"FSU":[0,23],"FOR":[0,23],"FRES":[0,23],"FUR":[0,23],"GWEB":[0,23],"GMU":[0,23],"GW":[0,23],"GTWN":[0,23],"UGA":[0,23],"GASO":[0,23],"GAST":[0,23],"GT":[0,23],"GONZ":[0,23],"GRAM":[0,23],"GCU":[0,23],"GB":[0,23],"HAMP":[0,22],"HARV":[2,21],"HAW":[0,23],"HPU":[0,23],"HOF":[0,23],"HC":[1,21],"HCU":[0,23],"HOU":[0,23],"HOW":[2,20],"IDST":[0,23],"IDHO":[0,22],"ILL":[3,19],"ILST":[0,23],"UIW":[0,23],"IND":[2,21],"INST":[0,23],"IONA":[0,23],"IOWA":[0,23],"ISU":[0,23],"IUIN":[0,23],"JKST":[0,23],"JAX":[0,23],"JXST":[0,23],"JMU":[2,20],"KC":[0,23],"KU":[0,23],"KSU":[0,23],"KENN":[0,23],"KENT":[0,23],"UK":[0,23],"LAS":[0,23],"LAF":[0,23],"LAM":[0,23],"LEM":[0,23],"LEH":[0,23],"LIB":[0,23],"LIN":[0,23],"LIP":[2,20],"LR":[0,23],"LBSU":[2,21],"LIU":[0,23],"LONG":[0,23],"UL":[0,23],"LT":[0,23],"LOU":[0,22],"LUC":[0,23],"LMD":[0,22],"LMU":[0,23],"NOLA":[0,23],"LSU":[0,23],"ME":[0,23],"MAN":[0,23],"MRST":[0,23],"MARQ":[0,23],"MRSH":[0,23],"UMES":[1,21],"MD":[0,22],"MASS":[0,23],"MCN":[2,20],"MEM":[0,23],"MER":[0,23],"MERC":[0,23],"MRMK":[0,23],"MOH":[0,23],"MIA":[0,23],"MSU":[1,22],"MICH":[0,23],"MTSU":[0,23],"MILW":[0,23],"MINN":[0,23],"MSST":[0,23],"MVSU":[0,23],"MOST":[0,23],"MIZ":[0,23],"MONM":[0,23],"MONT":[0,23],"MTST":[0,23],"MORE":[0,23],"MORG":[0,23],"MSM":[0,23],"MUR":[0,23],"NAVY":[2,21],"NCST":[3,20],"NEB":[0,23],"NEV":[0,23],"UNH":[0,23],"NHVN":[0,22],"UNM":[2,21],"NMSU":[0,23],"NIA":[0,23],"NICH":[0,23],"NJIT":[0,23],"NORF":[0,23],"UNA":[0,23],"NCAT":[1,21],"NCCU":[0,23],"UNC":[0,23],"UND":[0,23],"NDSU":[0,23],"UNF":[0,23],"UNT":[1,22],"NE":[4,20],"NAU":[0,23],"UNCO":[0,23],"NIU":[0,23],"UNI":[0,23],"NKU":[0,23],"NWST":[0,23],"NU":[4,19],"ND":[0,23],"OAK":[0,23],"OHIO":[0,23],"OSU":[0,23],"OU":[2,20],"OKST":[0,23],"ODU":[0,23],"MISS":[0,23],"OMA":[0,23],"ORU":[0,23],"ORE":[0,23],"ORST":[0,23],"PAC":[0,23],"PSU":[0,23],"PENN":[1,21],"PEPP":[0,22],"PITT":[0,23],"PORT":[1,22],"PRST":[2,20],"PV":[0,23],"PRES":[0,23],"PRIN":[1,22],"PROV":[0,23],"PUR":[0,23],"PFW":[0,23],"QUC":[2,21],"QUIN":[0,23],"RAD":[0,23],"URI":[2,20],"RICE":[1,21],"RICH":[3,20],"RID":[0,23],"RMU":[0,23],"RUTG":[0,23],"SAC":[0,23],"SHU":[0,23],"SFPA":[0,23],"JOES":[0,23],"SLU":[0,23],"SMC":[0,23],"SPU":[2,20],"SHSU":[0,23],"SAM":[0,23],"SDSU":[0,23],"USD":[0,23],"SF":[0,23],"SJSU":[0,22],"SCU":[2,20],"SELA":[1,21],"SEA":[1,22],"HALL":[0,23],"SIE":[0,23],"SIUE":[0,23],"SMU":[0,23],"USA":[0,23],"SC":[0,22],"SCST":[2,21],"UPST":[0,23],"SDAK":[2,21],"SDST":[0,23],"USF":[0,23],"SEMO":[0,23],"SIU":[0,23],"USI":[0,23],"SOU":[0,23],"USM":[0,23],"SUU":[0,23],"SBU":[0,22],"SJU":[3,20],"STMN":[1,22],"STAN":[4,19],"SFA":[0,23],"STET":[0,23],"STO":[0,23],"STBK":[0,23],"SYR":[3,20],"TAR":[0,23],"TCU":[0,23],"TEM":[1,22],"TNST":[0,23],"TNTC":[0,23],"TENN":[0,23],"TAMU":[0,23],"AMCC":[0,23],"TEX":[0,23],"TXSO":[0,23],"TXST":[1,21],"TTU":[1,21],"CIT":[0,23],"TOL":[1,23],"TOW":[0,23],"TROY":[1,22],"TULN":[0,23],"TLSA":[0,23],"UAB":[0,23],"UALB":[5,17],"UCD":[0,23],"UCI":[0,22],"UCR":[0,23],"UCSD":[0,23],"UCSB":[0,23],"UCF":[0,23],"UCLA":[0,23],"CONN":[2,21],"UIC":[0,23],"ULM":[0,23],"UML":[0,23],"UMBC":[0,23],"UNCA":[0,23],"UNCG":[0,23],"UNCW":[1,22],"UNLV":[0,23],"USC":[0,23],"UTA":[0,23],"UTM":[0,23],"RGV":[0,23],"USU":[0,23],"UTU":[0,23],"UTAH":[0,23],"UVU":[0,23],"UTEP":[0,23],"UTSA":[0,23],"VAL":[0,23],"VAND":[0,23],"VCU":[0,23],"UVM":[0,23],"NOVA":[0,23],"UVA":[0,23],"VT":[0,23],"VMI":[0,23],"WAG":[1,23],"WAKE":[0,23],"WASH":[0,23],"WSU":[0,23],"WEB":[0,23],"WGA":[0,23],"WVU":[0,23],"WCU":[0,23],"WIU":[0,23],"WKU":[0,23],"WMU":[0,23],"WICH":[0,23],"WM":[0,23],"WIN":[0,23],"WIS":[0,23],"WOF":[0,22],"WRST":[0,23],"WYO":[5,18],"XAV":[0,23],"YALE":[0,23],"YSU":[0,23]}

OPENING_LOGO_EDGES.update({"NDSU":[0,22]})
OPENING_LOGO_EDGES.update({"ARIZ":[0,23]})
OPENING_LOGO_EDGES.update({"AUB":[0,23]})

def opening_round_vs_x(c, first, second, left):
    # Measure between the visible artwork, not the transparent 24px slots.
    first_edge = left + 3 + OPENING_LOGO_EDGES.get(first, [0, 23])[1]
    second_edge = left + 37 + OPENING_LOGO_EDGES.get(second, [0, 23])[0]
    return (first_edge + second_edge - c.text_width("VS", "3x4") + 1) // 2

def opening_round_page(c, group_name, page_number, matchups, accent, badge_letter):
    c.fill("black")
    # Each group has twelve teams: six same-group games across two screens.
    for i, pair in enumerate(matchups):
        left = i * 64
        if i:
            c.line(left, 8, left, 31, color = DARK)
        left_center = left + 15
        right_center = left + 49
        # One quiet footer gives the matchup context while preserving full-size
        # logos. The center gutter carries only VS, never stacked metadata.
        category = "AQ" if badge_letter == "A" else "AL"
        category_color = GREEN if category == "AQ" else PURPLE
        tight_text(c, category, left + 8, 27, font = "4x5", color = category_color)
        c.pixel(left + 20, 29, MUTED)
        tight_text(c, str(pair[0]), left + 24, 27, font = "4x5", color = LIGHT)
        tight_text(c, "SEED", left + 38, 27, font = "4x5", color = MUTED)
        if pair[1] != "TBD" and pair[2] != "TBD":
            # ESPN projected matchup: use the schools' real drawn logos and
            # abbreviated labels, with the projected seed in the center gutter.
            # Use the full top area for the team marks; only the matchup seed
            # and VS stay in the center gutter above the abbreviation row.
            draw_team_logo(c, pair[1], left_center - 12, 0, 24, 25)
            draw_team_logo(c, pair[2], right_center - 12, 0, 24, 25)
            tight_text(c, "VS", opening_round_vs_x(c, pair[1], pair[2], left), 10, font = "3x4", color = MUTED)
        else:
            c.circle(left_center, 15, 6, color = accent)
            c.circle(right_center, 15, 6, color = accent)
            tight_text(c, badge_letter, left_center, 12, font = "4x5", color = LIGHT, align = "center")
            tight_text(c, badge_letter, right_center, 12, font = "4x5", color = LIGHT, align = "center")
            tight_text(c, pair[1], left_center, 21, font = "4x5", color = MUTED, align = "center")
            tight_text(c, pair[2], right_center, 21, font = "4x5", color = MUTED, align = "center")
            tight_text(c, "VS", left + 32, 10, font = "3x4", color = MUTED, align = "center")

def render_content(_projection, c, ctx, slot):
    view = selected_view(ctx)
    if view == "Opening Round":
        if slot == 1:
            opening_round_page(c, "AUTO QUALIFIERS", 1, _projection["OPENING_ROUND_AUTO"][0], GREEN, "A")
        elif slot == 2:
            opening_round_page(c, "AUTO QUALIFIERS", 2, _projection["OPENING_ROUND_AUTO"][1], GREEN, "A")
        elif slot == 3:
            opening_round_page(c, "AT-LARGE", 1, _projection["OPENING_ROUND_AT_LARGE"][0], GOLD, "L")
        else:
            opening_round_page(c, "AT-LARGE", 2, _projection["OPENING_ROUND_AT_LARGE"][1], GOLD, "L")
        return
    if view == "Top 4 Seeds":
        if slot <= 4:
            region_for_slot(_projection, c, slot)
        elif slot == 5:
            bubble_current(_projection, c, ctx)
        else:
            bubble_group_page(_projection, c, slot - 5)
    elif view in ["Field of 64", "Full Field"]:
        full_field_page(_projection, c, slot)
    elif view in ["My Team", "Your Team"]:
        your_team_page(_projection, c, ctx, slot)
    elif view == "Bubble":
        if slot == 1:
            bubble_four_team_page(_projection, c, 0)
        elif slot == 2:
            bubble_four_team_page(_projection, c, 1)
        elif slot == 3:
            bubble_four_team_page(_projection, c, 2)
        else:
            bubble_conference_page(_projection, c)

def logo_preview(c, slot, ctx):
    # Inspect any of the 365 normalized team marks by changing the Team picker.
    team = selected_team(ctx)
    c.fill("black")
    tight_text(c, "LOGO PREVIEW", 96, 1, font = "4x5", color = BLUE, align = "center")
    draw_team_logo(c, team, 81, 7, 30, 19)
    tight_text(c, team, 96, 27, font = "4x5", color = TEAM_COLORS.get(team, LIGHT), align = "center")

def east1(c, ctx):
    _projection = projection_state()
    render_content(_projection, c, ctx, 1)

def midwest1(c, ctx):
    _projection = projection_state()
    render_content(_projection, c, ctx, 2)

def west1(c, ctx):
    _projection = projection_state()
    render_content(_projection, c, ctx, 3)

def south1(c, ctx):
    _projection = projection_state()
    render_content(_projection, c, ctx, 4)

def firstfour(c, ctx):
    _projection = projection_state()
    render_content(_projection, c, ctx, 5)

def east2(c, ctx):
    _projection = projection_state()
    render_content(_projection, c, ctx, 6)

def midwest2(c, ctx):
    _projection = projection_state()
    render_content(_projection, c, ctx, 7)

def bubble_current(_projection, c, ctx):
    c.fill("black")
    # The cut is the overview's main story; all four tiers follow on list pages.
    labels = [["LAST IN", _projection["BUBBLE_GROUPS"][1][4], GREEN], ["FIRST OUT", _projection["BUBBLE_GROUPS"][2][1], GOLD]]
    c.line(96, 2, 96, 29, color = GRID)
    for i in range(2):
        x = 8 + i * 94
        team = labels[i][1]
        tight_text(c, labels[i][0], x + 40, 1, font = "4x5", color = labels[i][2], align = "center")
        draw_team_logo(c, team, x + 2, 9, 25, 22)
        name = TEAM_NAMES.get(team, team)
        # Split the long Oklahoma State name into two comfortably readable rows.
        if team == "OKST":
            tight_text(c, "OKLAHOMA", x + 31, 13, font = "4x5", color = full_field_color(team))
            tight_text(c, "STATE", x + 31, 22, font = "4x5", color = full_field_color(team))
        else:
            tight_text(c, name, x + 31, 17, font = "5x7", color = full_field_color(team))
        c.line(x, 7, x + 80, 7, color = labels[i][2])


# Direct cell-table URL: pubhtml itself is only Google's JavaScript shell.
APPROVED_FEED_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT_p_lPisAzZBCPbnR0DcFzZK-Au2jad_rLOHnJVTPXYjjCZg2YbEEzPTZQJf1P6njUI5j9zM_dsRFw/pubhtml/sheet?headers=false&gid=0"

def scalar_json_token(atom):
    if atom in ["true", "false", "null"]: return True
    digits = atom[1:] if atom.startswith("-") else atom
    return len(digits) > 0 and all([ch in "0123456789" for ch in digits.elems()]) and (len(digits) == 1 or not digits.startswith("0"))

def safe_json_document(text):
    # This feed contains only integers, strings, booleans, null, lists and dicts.
    # Validate lexical/structural grammar before json.decode (host has no try).
    tokens = []
    atom = ""
    quoted = False
    escape = False
    unicode_left = 0
    for ch in text.elems():
        if quoted:
            if unicode_left:
                if ch not in "0123456789abcdefABCDEF": return None
                unicode_left -= 1
            elif escape:
                if ch == "u": unicode_left = 4
                elif ch not in '\\"/bfnrt': return None
                escape = False
            elif ch == "\\": escape = True
            elif ch == '"':
                quoted = False
                tokens.append("s")
            elif ch < " ": return None
            continue
        if ch in "{}[]:, \n\r\t" or ch == '"':
            if atom:
                if not scalar_json_token(atom): return None
                tokens.append("v")
                atom = ""
            if ch == '"': quoted = True
            elif ch in "{}[]:,": tokens.append(ch)
        else:
            atom += ch
    if quoted or escape or unicode_left: return None
    if atom:
        if not scalar_json_token(atom): return None
        tokens.append("v")
    states = ["value"]
    kinds = ["root"]
    for token in tokens:
        state = states[-1]
        kind = kinds[-1]
        if token in ["}", "]"]:
            if kind == "root" or (token == "}" and kind != "object") or (token == "]" and kind != "array"): return None
            if state not in ["emptykey", "emptyvalue", "comma"]: return None
            states.pop()
            kinds.pop()
        elif state in ["emptykey", "key"]:
            if token != "s": return None
            states[-1] = "colon"
        elif state == "colon":
            if token != ":": return None
            states[-1] = "value"
        elif state == "comma":
            if token != "," or kind == "root": return None
            states[-1] = "key" if kind == "object" else "value"
        elif state in ["value", "emptyvalue"]:
            if token not in ["s", "v", "{", "["]: return None
            states[-1] = "comma"
            if token in ["{", "["]:
                kinds.append("object" if token == "{" else "array")
                states.append("emptykey" if token == "{" else "emptyvalue")
        else: return None
    if kinds != ["root"] or states != ["comma"]: return None
    return json.decode(text)

def approved_cell(body):
    if "<tbody>" not in body: return None
    table = body.split("<tbody>", 1)[1]
    if "<td" not in table: return None
    cell = table.split("<td", 1)[1].split(">", 1)[-1].split("</td>", 1)[0]
    # JSON is written as one plain scalar cell by the private checker.
    # Google wraps an overflowing populated cell in one presentation-only div.
    # Accept that exact wrapper, not arbitrary nested HTML or executable content.
    if cell.startswith('<div class="softmerge-inner"') and cell.endswith("</div>"):
        cell = cell.split(">", 1)[-1][:-6]
    if "<" in cell: return None
    cell = cell.replace("&quot;", '"').replace("&#39;", "'").replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
    return safe_json_document(cell) if cell.strip() else None

def projection_state():
    fallback = {"TEAM_OVERALL_SEEDS": TEAM_OVERALL_SEEDS, "TEAM_INFO": TEAM_INFO, "REGION_MATCHUPS": REGION_MATCHUPS,
        "EAST_TEAMS": EAST_TEAMS, "MIDWEST_TEAMS": MIDWEST_TEAMS, "WEST_TEAMS": WEST_TEAMS, "SOUTH_TEAMS": SOUTH_TEAMS,
        "OPENING_ROUND_AUTO": OPENING_ROUND_AUTO, "OPENING_ROUND_AT_LARGE": OPENING_ROUND_AT_LARGE,
        "BUBBLE_GROUPS": BUBBLE_GROUPS, "BUBBLE_EXTRA": BUBBLE_EXTRA, "YOUR_TEAM_SAMPLE_SLOTS": YOUR_TEAM_SAMPLE_SLOTS,
        "PROJECTION_DATE": "2026-10-27", "SAVED_PROJECTION": True}
    response = http.get(APPROVED_FEED_URL, ttl_seconds = 900)
    if response["status_code"] != 200: return fallback
    data = approved_cell(response.get("body", ""))
    if type(data) != "dict" or data.get("draft") != False or data.get("schema_version") != 1 or data.get("season") != "2026-27": return fallback
    if type(data.get("revision")) != "int" or data["revision"] < 1: return fallback
    teams = data.get("teams", [])
    regions = data.get("regions", [])
    opening = data.get("opening_round", [])
    bubble = data.get("bubble", {})
    if type(teams) != "list" or len(teams) != 76 or type(regions) != "list" or len(regions) != 4 or type(opening) != "list" or len(opening) != 12 or type(bubble) != "dict": return fallback
    by_code = {}
    ranks = {}
    info = {}
    for t in teams:
        if type(t) != "dict": return fallback
        code = t.get("code", "")
        seed = t.get("seed", 0)
        overall = t.get("overall", 0)
        if code not in TEAM_LOGO_FILES or code in by_code or type(seed) != "int" or seed < 1 or seed > 16 or type(overall) != "int" or overall < 1 or overall > 76 or overall in ranks: return fallback
        by_code[code] = t
        ranks[overall] = code
        info[code] = [t.get("region", ""), seed]
    result = dict(fallback)
    result["TEAM_INFO"] = info
    result["TEAM_OVERALL_SEEDS"] = {code: t["overall"] for code, t in by_code.items()}
    region_rows = {}
    seen = {}
    pairs = {}
    badges = {"EAST": "region-east-reference-v2.png", "MIDWEST": "region-midwest-reference.png", "WEST": "region-west-reference.png", "SOUTH": "region-south-reference.png"}
    cities = {r[0]: r[1] for r in REGION_MATCHUPS}
    for r in regions:
        if type(r) != "dict": return fallback
        name = r.get("name", "")
        slots = r.get("slots", [])
        if name not in badges or name in region_rows or r.get("city") != cities[name] or type(slots) != "list" or len(slots) != 16: return fallback
        indexed = {}
        rows = []
        for s in slots:
            if type(s) != "dict": return fallback
            n = s.get("seed", 0)
            codes = s.get("teams", [])
            if type(n) != "int" or n < 1 or n > 16 or n in indexed or type(codes) != "list" or len(codes) not in [1, 2]: return fallback
            for code in codes:
                if code not in by_code or code in seen or info[code] != [name, n]: return fallback
                seen[code] = True
            indexed[n] = codes
            if len(codes) == 2: pairs[name + "|" + str(n)] = codes
        for i in range(0, 16, 2):
            a, b = slots[i], slots[i + 1]
            rows.append([str(a["seed"]), a["teams"][0] if len(a["teams"]) == 1 else "TBD", str(b["seed"]), b["teams"][0] if len(b["teams"]) == 1 else "TBD"])
        top = [[indexed[n][0], TEAM_LOGO_FILES[indexed[n][0]], TEAM_COLORS.get(indexed[n][0], LIGHT)] for n in range(1, 5)]
        result[name + "_TEAMS"] = top
        region_rows[name] = [name, cities[name], badges[name], top, rows]
    if len(seen) != 76 or len(pairs) != 12: return fallback
    games = {"AQ": [], "AL": []}
    for g in opening:
        if type(g) != "dict" or g.get("category") not in games: return fallback
        key = g.get("region", "") + "|" + str(g.get("seed", 0))
        if key not in pairs or g.get("teams") != pairs[key]: return fallback
        games[g["category"]].append([g["seed"]] + g["teams"])
    if len(games["AQ"]) != 6 or len(games["AL"]) != 6: return fallback
    groups = []
    for key, title in [["last_four_byes", "LAST FOUR BYES"], ["last_four_in", "LAST FOUR IN"], ["first_four_out", "FIRST FOUR OUT"], ["next_four_out", "NEXT FOUR OUT"]]:
        codes = bubble.get(key, [])
        if type(codes) != "list" or len(codes) != 4 or len({c: True for c in codes}) != 4: return fallback
        for code in codes:
            if code not in TEAM_LOGO_FILES: return fallback
        groups.append([title] + codes)
    result["REGION_MATCHUPS"] = [region_rows[n] for n in ["EAST", "MIDWEST", "WEST", "SOUTH"]]
    result["YOUR_TEAM_SAMPLE_SLOTS"] = pairs
    result["OPENING_ROUND_AUTO"] = [games["AQ"][:3], games["AQ"][3:]]
    result["OPENING_ROUND_AT_LARGE"] = [games["AL"][:3], games["AL"][3:]]
    result["BUBBLE_GROUPS"] = groups + [["SOURCE SNAPSHOT", "KYLE", "76 TEAMS", "", ""]]
    result["PROJECTION_DATE"] = data.get("projection_date", "")
    result["SAVED_PROJECTION"] = False
    return result

# Wright State's official standalone wolf, proportional native frames.
# Previous wordmark assets and metadata remain in source/textfree-backup-oct29.
USER_LOGO_FRAMES.update({"WRST":{"38x24":["user-wrst-textfree-oct29-30x24.png",30,24],"34x24":["user-wrst-textfree-oct29-30x24.png",30,24],"26x23":["user-wrst-textfree-oct29-26x21.png",26,21],"31x24":["user-wrst-textfree-oct29-30x24.png",30,24],"29x22":["user-wrst-textfree-oct29-27x22.png",27,22],"25x19":["user-wrst-textfree-oct29-23x19.png",23,19],"22x20":["user-wrst-textfree-oct29-22x18.png",22,18],"24x25":["user-wrst-textfree-oct29-24x19.png",24,19],"30x19":["user-wrst-textfree-oct29-23x19.png",23,19],"25x22":["user-wrst-textfree-oct29-25x20.png",25,20],"28x25":["user-wrst-textfree-oct29-28x23.png",28,23]}})
TEAM_LOGO_BOUNDS.update({"WRST":[26,23,0,1,26,22]})
USER_LOGO_FRAMES["WRST"]["25x19"] = ["user-wrst-textfree-oct29-24x19.png",24,19]
USER_LOGO_FRAMES["WRST"]["30x19"] = ["user-wrst-textfree-oct29-24x19.png",24,19]
SNAPSHOT_LOGO_RIGHT.update({"WRST":33})
SWEET_PAIR_FRAMES.update({"WRST":["sweet-side-wrst-24x19.png",24,19,0,23]})
SWEET_COMPACT_FRAMES.update({"WRST":["sweet-side-wrst-18x15.png",18,15,0,17]})
SWEET_SINGLE_LEFT_INK.update({"WRST":0})
SWEET_SINGLE_RIGHT_INK.update({"WRST":25})
SWEET_SEED_CORNER_INK.update({"WRST":[6,6,5]})
