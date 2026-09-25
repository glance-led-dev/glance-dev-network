# College Conference Standings
#
# One FBS conference's standings, read like a ladder: every school's logo in
# standings order, its conference record in white (the number that decides
# the title race) and its overall record under it in gray.
#
# DESIGN. A table dressed like a Saturday broadcast. The left column is the
# legend: the conference's name stacked in its own colour on top (the Sun
# Belt's division word in white under it, so East and West read as two
# races), and the two row labels - CONF and OVERALL - underneath, lined up
# with the records they name. A thin divider in the conference colour closes
# the legend off; it is split into one segment per frame and the segment for
# the frame on screen is lit, so the rotation reads as a page count without
# spending text on "2/5". To the right, four columns: the school's 24 x 18
# logo with its standing numeral tucked at its top-left and, for a Top-25
# school, a gold AP-rank bug (black digits on gold, like the rank chip on a
# TV score bug) under the numeral; then the conference record (5x7, white)
# and the overall record (4x5, gray) with a streak arrow. Schools level with
# first place on conference WIN PERCENTAGE wear gold and a crown, so a
# crowded early-season top reads as a crowd. Before any conference game the
# race is the overall record: the best overall records go gold on the
# overall row instead, uncrowned. Gold is the only warm accent on the
# ladder; the conference colours stay in the legend.
#
# A second page, `leader`, gives first place the hero treatment: its 40 x 24
# logo, the name as the biggest type the panel can carry, and - the one loud
# thing on the page - a gold conference trophy beside the name when the
# name leaves room. A shared lead rotates the hero among the co-leaders every
# refresh, and the bottom row rotates too: records and streak, then points
# for / against / differential, then the record against AP Top-25 teams once
# one has been played.
#
# Frames: the ladder shows four schools at a time and steps to the next four
# every refresh (120 s), so an 18-team Big Ten cycles in ten minutes. The
# Sun Belt is two divisions of seven; each division is laid out on its own
# frames with its name in the legend. Standings move once a week, so the
# ESPN call is cached for 30 minutes whatever the refresh.

STANDINGS = "https://site.web.api.espn.com/apis/v2/sports/football/college-football/standings"
HEADERS = {"User-Agent": "glance-college-conference-standings (glance-led.dev)"}
TTL = 1800

# label -> [ESPN group id, legend lines, colour]. Legend lines stack in the
# left column (35 px wide); a line that is too wide steps down a font ladder.
CONFS = {
    "SEC": ["8", ["SEC"], "#4F8BFF"],
    "BIG TEN": ["5", ["BIG", "TEN"], "#2FA8FF"],
    "BIG 12": ["4", ["BIG", "12"], "#FF4B5C"],
    "ACC": ["1", ["ACC"], "#5CB8FF"],
    "AMERICAN": ["151", ["THE", "AMERICAN"], "#FF5A6E"],
    "MOUNTAIN WEST": ["17", ["MTN", "WEST"], "#7F9CFF"],
    "SUN BELT": ["37", ["SUN BELT"], "#FF9A1F"],
    "MAC": ["15", ["MAC"], "#2EE6C8"],
    "CONFERENCE USA": ["12", ["C-USA"], "#B18CFF"],
    "PAC-12": ["9", ["PAC-12"], "#3DA0FF"],
    "FBS INDEPENDENTS": ["18", ["FBS", "INDEP"], "#B0BCCB"],
}

# FBS logos by ESPN abbreviation: 24 x 18 for the ladder, 40 x 24 for the
# leader card. Literal names, so the asset lint can see every file.
LOGO_S = {
    "AFA": "AFA_S.png", "AKR": "AKR_S.png", "ALA": "ALA_S.png", "APP": "APP_S.png",
    "ARIZ": "ARIZ_S.png", "ARK": "ARK_S.png", "ARMY": "ARMY_S.png", "ARST": "ARST_S.png",
    "ASU": "ASU_S.png", "AUB": "AUB_S.png", "BALL": "BALL_S.png", "BAY": "BAY_S.png",
    "BC": "BC_S.png", "BGSU": "BGSU_S.png", "BOIS": "BOIS_S.png", "BUFF": "BUFF_S.png",
    "BYU": "BYU_S.png", "CAL": "CAL_S.png", "CCU": "CCU_S.png", "CIN": "CIN_S.png",
    "CLEM": "CLEM_S.png", "CLT": "CLT_S.png", "CMU": "CMU_S.png", "COLO": "COLO_S.png",
    "CONN": "CONN_S.png", "CSU": "CSU_S.png", "DEL": "DEL_S.png", "DUKE": "DUKE_S.png",
    "ECU": "ECU_S.png", "EMU": "EMU_S.png", "FAU": "FAU_S.png", "FIU": "FIU_S.png",
    "FLA": "FLA_S.png", "FRES": "FRES_S.png", "FSU": "FSU_S.png", "GASO": "GASO_S.png",
    "GAST": "GAST_S.png", "GT": "GT_S.png", "HAW": "HAW_S.png", "HOU": "HOU_S.png",
    "ILL": "ILL_S.png", "IOWA": "IOWA_S.png", "ISU": "ISU_S.png", "IU": "IU_S.png",
    "JMU": "JMU_S.png", "JXST": "JXST_S.png", "KENN": "KENN_S.png", "KENT": "KENT_S.png",
    "KSU": "KSU_S.png", "KU": "KU_S.png", "LIB": "LIB_S.png", "LOU": "LOU_S.png",
    "LSU": "LSU_S.png", "LT": "LT_S.png", "M-OH": "MOH_S.png", "MASS": "MASS_S.png",
    "MD": "MD_S.png", "MEM": "MEM_S.png", "MIA": "MIA_S.png", "MICH": "MICH_S.png",
    "MINN": "MINN_S.png", "MISS": "MISS_S.png", "MIZ": "MIZ_S.png", "MOST": "MOST_S.png",
    "MRSH": "MRSH_S.png", "MSST": "MSST_S.png", "MSU": "MSU_S.png", "MTSU": "MTSU_S.png",
    "NAVY": "NAVY_S.png", "NCSU": "NCSU_S.png", "ND": "ND_S.png", "NDSU": "NDSU_S.png",
    "NEB": "NEB_S.png", "NEV": "NEV_S.png", "NIU": "NIU_S.png", "NMSU": "NMSU_S.png",
    "NU": "NU_S.png", "ODU": "ODU_S.png", "OHIO": "OHIO_S.png", "OKST": "OKST_S.png",
    "ORE": "ORE_S.png", "ORST": "ORST_S.png", "OSU": "OSU_S.png", "OU": "OU_S.png",
    "PITT": "PITT_S.png", "PSU": "PSU_S.png", "PUR": "PUR_S.png", "RICE": "RICE_S.png",
    "RUTG": "RUTG_S.png", "SAC": "SAC_S.png", "SC": "SC_S.png", "SDSU": "SDSU_S.png",
    "SHSU": "SHSU_S.png", "SJSU": "SJSU_S.png", "SMU": "SMU_S.png", "STAN": "STAN_S.png",
    "SYR": "SYR_S.png", "TA&M": "TAMU_S.png", "TCU": "TCU_S.png", "TEM": "TEM_S.png",
    "TENN": "TENN_S.png", "TEX": "TEX_S.png", "TLSA": "TLSA_S.png", "TOL": "TOL_S.png",
    "TROY": "TROY_S.png", "TTU": "TTU_S.png", "TULN": "TULN_S.png", "TXST": "TXST_S.png",
    "UAB": "UAB_S.png", "UCF": "UCF_S.png", "UCLA": "UCLA_S.png", "UGA": "UGA_S.png",
    "UK": "UK_S.png", "UL": "UL_S.png", "ULM": "ULM_S.png", "UNC": "UNC_S.png",
    "UNLV": "UNLV_S.png", "UNM": "UNM_S.png", "UNT": "UNT_S.png", "USA": "USA_S.png",
    "USC": "USC_S.png", "USF": "USF_S.png", "USM": "USM_S.png", "USU": "USU_S.png",
    "UTAH": "UTAH_S.png", "UTEP": "UTEP_S.png", "UTSA": "UTSA_S.png", "UVA": "UVA_S.png",
    "VAN": "VAN_S.png", "VT": "VT_S.png", "WAKE": "WAKE_S.png", "WASH": "WASH_S.png",
    "WIS": "WIS_S.png", "WKU": "WKU_S.png", "WMU": "WMU_S.png", "WSU": "WSU_S.png",
    "WVU": "WVU_S.png", "WYO": "WYO_S.png",
}
LOGO_L = {
    "AFA": "AFA.png", "AKR": "AKR.png", "ALA": "ALA.png", "APP": "APP.png", "ARIZ": "ARIZ.png",
    "ARK": "ARK.png", "ARMY": "ARMY.png", "ARST": "ARST.png", "ASU": "ASU.png", "AUB": "AUB.png",
    "BALL": "BALL.png", "BAY": "BAY.png", "BC": "BC.png", "BGSU": "BGSU.png", "BOIS": "BOIS.png",
    "BUFF": "BUFF.png", "BYU": "BYU.png", "CAL": "CAL.png", "CCU": "CCU.png", "CIN": "CIN.png",
    "CLEM": "CLEM.png", "CLT": "CLT.png", "CMU": "CMU.png", "COLO": "COLO.png",
    "CONN": "CONN.png", "CSU": "CSU.png", "DEL": "DEL.png", "DUKE": "DUKE.png", "ECU": "ECU.png",
    "EMU": "EMU.png", "FAU": "FAU.png", "FIU": "FIU.png", "FLA": "FLA.png", "FRES": "FRES.png",
    "FSU": "FSU.png", "GASO": "GASO.png", "GAST": "GAST.png", "GT": "GT.png", "HAW": "HAW.png",
    "HOU": "HOU.png", "ILL": "ILL.png", "IOWA": "IOWA.png", "ISU": "ISU.png", "IU": "IU.png",
    "JMU": "JMU.png", "JXST": "JXST.png", "KENN": "KENN.png", "KENT": "KENT.png",
    "KSU": "KSU.png", "KU": "KU.png", "LIB": "LIB.png", "LOU": "LOU.png", "LSU": "LSU.png",
    "LT": "LT.png", "M-OH": "MOH.png", "MASS": "MASS.png", "MD": "MD.png", "MEM": "MEM.png",
    "MIA": "MIA.png", "MICH": "MICH.png", "MINN": "MINN.png", "MISS": "MISS.png",
    "MIZ": "MIZ.png", "MOST": "MOST.png", "MRSH": "MRSH.png", "MSST": "MSST.png",
    "MSU": "MSU.png", "MTSU": "MTSU.png", "NAVY": "NAVY.png", "NCSU": "NCSU.png", "ND": "ND.png",
    "NDSU": "NDSU.png", "NEB": "NEB.png", "NEV": "NEV.png", "NIU": "NIU.png", "NMSU": "NMSU.png",
    "NU": "NU.png", "ODU": "ODU.png", "OHIO": "OHIO.png", "OKST": "OKST.png", "ORE": "ORE.png",
    "ORST": "ORST.png", "OSU": "OSU.png", "OU": "OU.png", "PITT": "PITT.png", "PSU": "PSU.png",
    "PUR": "PUR.png", "RICE": "RICE.png", "RUTG": "RUTG.png", "SAC": "SAC.png", "SC": "SC.png",
    "SDSU": "SDSU.png", "SHSU": "SHSU.png", "SJSU": "SJSU.png", "SMU": "SMU.png",
    "STAN": "STAN.png", "SYR": "SYR.png", "TA&M": "TAMU.png", "TCU": "TCU.png", "TEM": "TEM.png",
    "TENN": "TENN.png", "TEX": "TEX.png", "TLSA": "TLSA.png", "TOL": "TOL.png",
    "TROY": "TROY.png", "TTU": "TTU.png", "TULN": "TULN.png", "TXST": "TXST.png",
    "UAB": "UAB.png", "UCF": "UCF.png", "UCLA": "UCLA.png", "UGA": "UGA.png", "UK": "UK.png",
    "UL": "UL.png", "ULM": "ULM.png", "UNC": "UNC.png", "UNLV": "UNLV.png", "UNM": "UNM.png",
    "UNT": "UNT.png", "USA": "USA.png", "USC": "USC.png", "USF": "USF.png", "USM": "USM.png",
    "USU": "USU.png", "UTAH": "UTAH.png", "UTEP": "UTEP.png", "UTSA": "UTSA.png",
    "UVA": "UVA.png", "VAN": "VAN.png", "VT": "VT.png", "WAKE": "WAKE.png", "WASH": "WASH.png",
    "WIS": "WIS.png", "WKU": "WKU.png", "WMU": "WMU.png", "WSU": "WSU.png", "WVU": "WVU.png",
    "WYO": "WYO.png",
}

REFRESH = 120
PER_FRAME = 4

# ------------------------------------------------------------------ layout
# 192 wide, content x 6..185. Legend x 6..40 (35 px), divider x 42, four
# columns of 35 px from x 46: numeral ending at x +6 (worst "18" is 8 px),
# the AP bug x -2..+6 under it, logo x +8..+31 (24 x 18 at y 0), 3 px to
# the next column. The last column ends at x 182.
LEG_X = 6
LEG_W = 35
DIV_X = 42
COL_X = 46
COL_W = 35
LOGO_DX = 8
REC_CX = 20        # records centre under the logo: col + 8 + 12
Y_CONF = 20        # 5x7 conference record, y 20..26
Y_ALL = 27         # 4x5 overall record,    y 27..31

INK = "#F4F7FF"
DIM = "#8A94A8"
LABEL = "#6E7A94"
GOLD = "#FFC72C"
GOOD = "#2FE06F"
RED = "#FF4B5C"
OFFLINE = "#3C4043"
AMBER = "#E8B04A"

# The leader page: logo x 6..45, text x 52..185, trophy x 173..185.
L_TX = 52
L_TR = 185
TROPHY_W = 13

INKH = {"10x16": 15, "9x12": 12, "8x10": 10, "6x8": 8, "5x7": 7, "4x7": 7, "3x7": 7, "4x5": 5,
        "picopixel": 5}

# ------------------------------------------------------------ text helpers
KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-&'/()"
ACCENT = {"É": "E", "é": "E", "Á": "A", "á": "A", "Í": "I", "í": "I", "Ó": "O", "ó": "O",
          "Ú": "U", "ú": "U", "Ñ": "N", "ñ": "N"}

def clean(s):
    out = ""
    for ch in str(s).elems():
        ch = ACCENT.get(ch, ch).upper()
        if KEEP.find(ch) >= 0:
            out += ch
    return out.replace("'", "").strip()

def clip(c, text, font, maxw):
    t = str(text)
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k].rstrip(" ")
    return ""

def fit(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    f = fonts[len(fonts) - 1]
    return [f, clip(c, text, f, maxw)]

# ------------------------------------------------------------------- data
def stat_map(entry):
    m = {}
    for s in entry.get("stats", []) or []:
        t = s.get("type", "")
        if t != "" and t not in m:
            m[t] = str(s.get("displayValue", ""))
    return m

def num(s, fallback):
    t = str(s).strip()
    if t == "" or not t.isdigit():
        return fallback
    return int(t)

def wl(rec):
    """'3-1' -> [3, 1]; anything else -> [0, 0]."""
    p = str(rec).split("-")
    if len(p) < 2:
        return [0, 0]
    return [num(p[0], 0), num(p[1], 0)]

def groups_in(node, out):
    """Every node with standings entries, depth first: the conference itself,
    or the Sun Belt's two divisions."""
    if type(node) != "dict":
        return out
    st = node.get("standings", None)
    if type(st) == "dict":
        es = st.get("entries", []) or []
        if len(es) > 0:
            out.append({"name": str(node.get("name", "")), "entries": es})
    for ch in node.get("children", []) or []:
        groups_in(ch, out)
    return out

def division_word(name):
    """'Sun Belt - East' -> 'EAST'."""
    i = name.rfind("-")
    return clean(name[i + 1:]) if i >= 0 else ""

def ap_rank(t):
    """The AP poll rank ESPN puts on the team, 1..25, else 0."""
    r = t.get("rank", None)
    if type(r) == "int" and r >= 1 and r <= 25:
        return r
    return num(r, 0) if num(r, 0) <= 25 else 0

def team_rows(entries):
    rows = []
    for i in range(len(entries)):
        e = entries[i]
        if type(e) != "dict":
            continue
        t = e.get("team", {}) or {}
        if type(t) != "dict" or str(t.get("abbreviation", "")) == "":
            continue
        m = stat_map(e)
        rows.append({
            "abbr": str(t.get("abbreviation", "")),
            "name": clean(t.get("shortDisplayName", "") or t.get("location", "") or t["abbreviation"]),
            "seed": num(m.get("playoffseed", ""), 99),
            "order": i,
            "conf": m.get("vsconf", ""),
            "all": m.get("total", ""),
            "streak": m.get("streak", ""),
            "ap": ap_rank(t),
            "pf": m.get("pointsfor", ""),
            "pa": m.get("pointsagainst", ""),
            "diff": m.get("pointdifferential", ""),
            "top25": m.get("vsaprankedteams", ""),
        })
    return sorted(rows, key = lambda r: (r["seed"], r["order"]))

def fetch(label):
    cf = CONFS[label]
    r = http.get(STANDINGS, params = {"group": cf[0]}, headers = HEADERS, ttl_seconds = TTL)
    if r["status_code"] == 0:
        return {"ok": False, "head": "ESPN OFFLINE", "sub": "RETRY IN 2 MIN"}
    if r["status_code"] != 200 or type(r["json"]) != "dict":
        return {"ok": False, "head": "STANDINGS ERROR", "sub": "HTTP " + str(r["status_code"]) + " - RETRY SOON"}
    gs = groups_in(r["json"], [])
    if len(gs) > 1:
        # A conference with divisions: the root's own list (if ESPN sends one)
        # repeats the divisions' teams, so keep only the leaves.
        gs = [g for g in gs if division_word(g["name"]) != ""] or gs[1:]
    groups = []
    for g in gs:
        groups.append({"div": division_word(g["name"]) if len(gs) > 1 else "",
                       "rows": team_rows(g["entries"])})
    return {"ok": True, "groups": groups}

def conf_label(ctx):
    v = str(ctx.inputs.get("conference", "SEC")).strip().upper()
    return v if v in CONFS else "SEC"

def independent(label):
    return label == "FBS INDEPENDENTS"

def best_by(rows, key):
    """Rows level with the best win percentage on `key`, in standings order.
    Schools with no games on that record are out of the race."""
    best = None
    for r in rows:
        p = wl(r[key])
        if p[0] + p[1] == 0:
            continue
        if best == None or p[0] * (best[0] + best[1]) > best[0] * (p[0] + p[1]):
            best = p
    if best == None:
        return []
    out = []
    for r in rows:
        p = wl(r[key])
        if p[0] + p[1] > 0 and p[0] * (best[0] + best[1]) == best[0] * (p[0] + p[1]):
            out.append(r)
    return out

def race(rows, indep):
    """Who is in first. mode 'conf' once a conference game is played (win
    pct, as the standings are kept), 'overall' before that and for the
    independents, 'none' before a game at all."""
    if not indep:
        top = best_by(rows, "conf")
        if len(top) > 0:
            return {"mode": "conf", "top": top, "set": {r["abbr"]: True for r in top}}
    top = best_by(rows, "all")
    if len(top) > 0:
        return {"mode": "indep" if indep else "overall", "top": top, "set": {r["abbr"]: True for r in top}}
    return {"mode": "none", "top": [], "set": {}}

# ----------------------------------------------------------------- chrome
def legend(c, label, div, rowlabels):
    """Conference name stacked in its colour; the row labels under it."""
    cf = CONFS[label]
    col = cf[2]
    lines = [[l, col] for l in cf[1]]
    if div != "":
        # The division word in white, so the Sun Belt's two halves read as
        # two separate races from across a room.
        lines = lines + [[div, INK]]
    if len(lines) == 1:
        f = fit(c, lines[0][0], ["10x16", "9x12", "6x8", "5x7", "4x5"], LEG_W)
        y = (18 - INKH[f[0]]) // 2
        c.text(f[1], LEG_X + LEG_W // 2, y, font = f[0], color = col, align = "center")
    else:
        # Two lines in y 0..17: the first may be an eyebrow (SUN BELT / THE),
        # the second the name proper.
        # "SUN BELT" is 35 px in 4x7 and "AMERICAN" 31 px in 3x7 - the
        # narrow 7 px faces keep them whole where 4x5 clipped them.
        f1 = fit(c, lines[0][0], ["6x8", "5x7", "4x7", "3x7"], LEG_W)
        f2 = fit(c, lines[1][0], ["6x8", "5x7", "4x7", "3x7"], LEG_W)
        h = INKH[f1[0]] + 2 + INKH[f2[0]]
        y = (18 - h) // 2
        c.text(f1[1], LEG_X + LEG_W // 2, y, font = f1[0], color = lines[0][1], align = "center")
        c.text(f2[1], LEG_X + LEG_W // 2, y + INKH[f1[0]] + 2, font = f2[0], color = lines[1][1], align = "center")
    # The app's mark: a football tucked beside the top row label (x 6..16),
    # drawn only when that label leaves 2 px ("CONF" is 18 px; the
    # independents' "W-L" 11).
    if LEG_X + 11 + 2 <= LEG_X + LEG_W - c.text_width(rowlabels[0], "4x5"):
        c.sprite(BALL, LEG_X, Y_CONF, legend = BALL_LEGEND)
    c.text(rowlabels[0], LEG_X + LEG_W - 1, Y_CONF + 1, font = "4x5", color = LABEL, align = "right")
    c.text(rowlabels[1], LEG_X + LEG_W - 1, Y_ALL, font = "4x5", color = LABEL, align = "right")

def divider(c, label, frame, frames):
    """x 42, split into one segment per frame; the current one is lit."""
    col = CONFS[label][2]
    if frames <= 1:
        c.rect(DIV_X, 0, DIV_X, 31, fill = col)
        return
    gap = 2
    seg = (32 - gap * (frames - 1)) // frames
    top = (32 - (seg * frames + gap * (frames - 1))) // 2
    for i in range(frames):
        y0 = top + i * (seg + gap)
        c.rect(DIV_X, y0, DIV_X, y0 + seg - 1, fill = col if i == frame else color.dim(col, 35))

def logo_s(c, abbr, x, y):
    f = LOGO_S.get(abbr, "")
    if f != "":
        c.image(f, x, y)
        return
    # A school outside the logo set: its abbreviation in a slate box.
    c.rect(x, y + 1, x + 23, y + 16, outline = "#3A4356")
    t = fit(c, clean(abbr), ["5x7", "4x5"], 20)
    c.text(t[1], x + 12, y + 9 - INKH[t[0]] // 2, font = t[0], color = DIM, align = "center")

def ap_bug(c, rank, right, y):
    """AP rank as a gold chip with black digits, right edge at `right`,
    y..y+6. Returns its width."""
    t = str(rank)
    w = c.text_width(t, "picopixel") + 2
    c.rect(right - w + 1, y, right, y + 6, fill = GOLD)
    c.text(t, right - w + 2, y + 1, font = "picopixel", color = "#000000")
    return w

def streak_dir(s):
    """'W3' -> 1, 'L2' -> -1, anything else 0."""
    t = str(s)
    return 1 if t.startswith("W") else (-1 if t.startswith("L") else 0)

def column(c, row, x, rank, rc, indep):
    first = row["abbr"] in rc["set"]
    crown = first and rc["mode"] in ("conf", "indep")
    top_col = GOLD if first and rc["mode"] in ("conf", "indep") else INK
    bot_col = GOLD if first and rc["mode"] == "overall" else DIM
    # First place wears a crown in the numeral's slot. Numerals end at x +6:
    # "18" is 8 px in 4x5, so it runs x -1..+6 and keeps 1 px off the logo
    # at +8 (and, in the first column, 2 px off the divider at 42).
    if crown:
        c.sprite(CROWN, x, 1, legend = {"G": GOLD, "R": "#FF4B5C"})
    else:
        c.text(str(rank), x + 6, 1, font = "4x5", color = DIM, align = "right")
    # A Top-25 school carries its AP rank as a gold bug under the numeral,
    # x -2..+6 at worst ("25"), 1 px off the logo and the divider.
    if row["ap"] > 0:
        ap_bug(c, row["ap"], x + 6, 10)
    logo_s(c, row["abbr"], x + LOGO_DX, 0)
    top = row["all"] if indep else row["conf"]
    bot = row["streak"] if indep else row["all"]
    top = top if top != "" else "-"
    bot = bot if bot != "" else "-"
    t = fit(c, top, ["5x7", "4x5"], COL_W - 2)
    c.text(t[1], x + REC_CX, Y_CONF + (1 if t[0] == "4x5" else 0), font = t[0], color = top_col, align = "center")
    # The overall record carries the streak as an arrow - green up on a win
    # streak, red down on a loss - centred with it as one unit.
    b = fit(c, bot, ["4x5"], COL_W - 8)
    d = 0 if indep else streak_dir(row["streak"])
    bw = c.text_width(b[1], "4x5")
    w = bw + (7 if d != 0 else 0)
    bx = x + REC_CX - w // 2
    c.text(b[1], bx, Y_ALL, font = "4x5", color = bot_col)
    if d != 0:
        c.sprite(UP if d > 0 else DOWN, bx + bw + 2, Y_ALL + 1, legend = {"X": GOOD if d > 0 else RED})

def rail(c, col):
    # x 6..7: nothing lights x 0..5 or 186..191, so the app never runs
    # into its neighbours on a scroll wall.
    c.rect(6, 0, 7, 31, fill = col)

def message(c, head, sub, col, rail_col):
    c.fill("black")
    rail(c, rail_col)
    hf = fit(c, head, ["10x16", "6x8", "5x7", "4x5"], 172)
    c.text(hf[1], c.width // 2, 13 - INKH[hf[0]] // 2 - 2, font = hf[0], color = col, align = "center")
    sf = fit(c, sub, ["4x5", "picopixel"], 172)
    c.text(sf[1], c.width // 2, 24, font = sf[0], color = LABEL, align = "center")

def no_standings(c, label):
    message(c, "NO STANDINGS YET", " ".join(CONFS[label][1]) + " - CHECK BACK IN AUGUST", GOOD, GOOD)

# ------------------------------------------------------------ page: ladder
def ladder(c, ctx):
    label = conf_label(ctx)
    d = fetch(label)
    if not d["ok"]:
        message(c, d["head"], d["sub"], AMBER, OFFLINE)
        return
    indep = independent(label)
    # Frames: each group (division) is chunked into fours; frames run
    # through every group in order.
    frames = []
    for g in d["groups"]:
        rows = g["rows"]
        rc = race(rows, indep)
        # Balanced chunks: 18 schools are 4-4-4-3-3, never 4-4-4-4-2.
        n = (len(rows) + PER_FRAME - 1) // PER_FRAME
        s = 0
        for k in range(n):
            size = len(rows) // n + (1 if k < len(rows) % n else 0)
            frames.append({"div": g["div"], "rows": rows[s:s + size], "start": s, "race": rc})
            s += size
    if len(frames) == 0:
        no_standings(c, label)
        return
    fi = (ctx.now.unix // REFRESH) % len(frames)
    fr = frames[fi]
    c.fill("black")
    legend(c, label, fr["div"], ["W-L", "STREAK"] if indep else ["CONF", "OVERALL"])
    divider(c, label, fi, len(frames))
    # A short frame (three schools, or the two independents) is centred in
    # the four-column band rather than left with an empty tail.
    off = (PER_FRAME - len(fr["rows"])) * COL_W // 2
    for i in range(len(fr["rows"])):
        r = fr["rows"][i]
        column(c, r, COL_X + off + i * COL_W, fr["start"] + i + 1, fr["race"], indep)

# ------------------------------------------------------------ page: leader
def pick_width(c, options, maxw):
    for o in options:
        if c.text_width(o, "4x5") <= maxw:
            return o
    return options[len(options) - 1]

def bottom_parts(top, mode, indep):
    """Label/value/colour triples for one bottom-row mode, longest labels
    first; the caller steps down until one fits."""
    s = top["streak"]
    s_col = GOOD if s.startswith("W") else (RED if s.startswith("L") else INK)
    conf_v = top["conf"] if top["conf"] != "" else "-"
    all_v = top["all"] if top["all"] != "" else "-"
    if mode == "points":
        dv = top["diff"]
        d_col = GOOD if dv.startswith("+") else (RED if dv.startswith("-") else INK)
        return [
            [["POINTS FOR", top["pf"], INK], ["AGAINST", top["pa"], INK], ["DIFF", dv, d_col]],
            [["PF", top["pf"], INK], ["PA", top["pa"], INK], ["DIFF", dv, d_col]],
            [["PF", top["pf"], INK], ["PA", top["pa"], INK], ["", dv, d_col]],
        ]
    if mode == "top25":
        return [
            [["VS AP TOP 25", top["top25"], INK], ["OVERALL", all_v, INK]],
            [["VS TOP 25", top["top25"], INK], ["ALL", all_v, INK]],
            [["VS TOP 25", top["top25"], INK]],
        ]
    opts = []
    for names in [["CONF", "OVERALL", "STREAK"], ["CONF", "ALL", "STRK"], ["CONF", "ALL", ""]]:
        parts = []
        if not indep:
            parts.append([names[0], conf_v, INK])
        parts.append([names[1], all_v, INK])
        if s != "" and s != "-" and names[2] != "":
            parts.append([names[2], s, s_col, "streak"])
        opts.append(parts)
    return opts

def parts_width(c, parts):
    w = 0
    for p in parts:
        if p[0] != "":
            w += c.text_width(p[0], "4x5") + 3
        w += c.text_width(p[1], "5x7") + 5
    return w - 5

def leader(c, ctx):
    label = conf_label(ctx)
    d = fetch(label)
    if not d["ok"]:
        message(c, d["head"], d["sub"], AMBER, OFFLINE)
        return
    indep = independent(label)
    groups = [g for g in d["groups"] if len(g["rows"]) > 0]
    if len(groups) == 0:
        no_standings(c, label)
        return
    tick = ctx.now.unix // REFRESH
    # The Sun Belt has a leader per division; they alternate with the refresh.
    g = groups[tick % len(groups)]
    tick = tick // len(groups)
    rows = g["rows"]
    rc = race(rows, indep)
    # A shared lead rotates the hero among the co-leaders, so every fan in
    # the tie gets their logo on the wall.
    pool = rc["top"] if len(rc["top"]) > 0 else rows[:1]
    top = pool[tick % len(pool)]
    tick = tick // len(pool)
    n = len(rc["top"])
    c.fill("black")
    cf = CONFS[label]

    f = LOGO_L.get(top["abbr"], "")
    if f != "":
        c.image(f, 6, 4)
    else:
        logo_s(c, top["abbr"], 14, 7)

    # Eyebrow: [crown] [AP bug] which race this is, and whether it's shared.
    name = " ".join(cf[1]) if label != "SUN BELT" else "SUN BELT"
    if g["div"] != "":
        name = name + " " + g["div"]
    way = str(n) + "-WAY"
    # A shorter race name keeps the tie count on screen: EAST for a Sun Belt
    # division, AMERICAN without its "THE".
    short = g["div"] if g["div"] != "" else (cf[1][len(cf[1]) - 1] if label == "AMERICAN" else name)
    if indep:
        options = ["BEST FBS INDEPENDENT", "BEST INDEPENDENT"]
    elif rc["mode"] == "none":
        options = [name + " - NO GAMES YET", "NO GAMES YET"]
    elif rc["mode"] == "overall":
        if n > 1:
            options = [name + " BEST OVERALL " + way, short + " BEST OVERALL " + way, name + " BEST OVERALL", "BEST OVERALL " + way, "BEST OVERALL"]
        else:
            options = [name + " BEST OVERALL", "BEST OVERALL"]
    elif n > 1:
        options = [name + " CO-LEADER " + way, short + " CO-LEADER " + way, "CO-LEADER " + way, name + " CO-LEADER", "CO-LEADER"]
    else:
        options = [name + " LEADER", "CONF LEADER", "LEADER"]
    crown = rc["mode"] in ("conf", "indep")
    ex = L_TX
    if crown:
        c.sprite(CROWN, ex, 1, legend = {"G": GOLD, "R": "#FF4B5C"})
        ex += 9
    if top["ap"] > 0:
        ap_bug(c, top["ap"], ex + c.text_width(str(top["ap"]), "picopixel") + 1, 0)
        ex += c.text_width(str(top["ap"]), "picopixel") + 2 + 3
    eyebrow = pick_width(c, options, L_TR - ex + 1)
    c.text(clip(c, eyebrow, "4x5", L_TR - ex + 1), ex, 1, font = "4x5", color = cf[2])

    # The school's name, the biggest face that fits x 52..185; the trophy
    # takes x 173..185 when the name leaves it 2 px.
    trophy = rc["mode"] == "conf"
    room = L_TR - L_TX + 1
    nf = fit(c, top["name"], ["10x16", "9x12", "6x8", "5x7"], room)
    if trophy:
        tf = fit(c, top["name"], ["10x16", "9x12"], room - TROPHY_W - 3)
        if c.text_width(tf[1], tf[0]) <= room - TROPHY_W - 3 and tf[1] == top["name"]:
            nf = tf
        else:
            trophy = False
    c.text(nf[1], L_TX, 8 + (15 - INKH[nf[0]]) // 2, font = nf[0], color = GOLD if rc["mode"] != "none" else INK)
    if trophy:
        c.sprite(TROPHY, L_TR - TROPHY_W + 1, 8, legend = TROPHY_LEGEND)

    # Bottom row: records & streak, then points, then vs Top 25 (once one
    # has been played), rotating with the refresh.
    modes = ["records"]
    if top["pf"] != "" and top["pa"] != "":
        modes.append("points")
    t25 = wl(top["top25"])
    if t25[0] + t25[1] > 0:
        modes.append("top25")
    mode = modes[tick % len(modes)]
    opts = bottom_parts(top, mode, indep)
    parts = opts[len(opts) - 1]
    for o in opts:
        if L_TX + parts_width(c, o) - 1 <= L_TR:
            parts = o
            break
    x = L_TX
    for p in parts:
        if p[0] != "":
            c.text(p[0], x, 26, font = "4x5", color = LABEL)
            x += c.text_width(p[0], "4x5") + 3
        c.text(p[1], x, 25, font = "5x7", color = p[2])
        x += c.text_width(p[1], "5x7") + 5
        if len(p) > 3:
            # Two or more in a row: a flame for a win streak, ice for a
            # losing one, 2 px after the streak value.
            s = p[1]
            if num(s[1:], 0) >= 2 and x + 3 <= L_TR:
                c.sprite(FLAME if s.startswith("W") else ICE, x - 3, 24, legend = FLAME_LEGEND if s.startswith("W") else ICE_LEGEND)

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
BALL = """
...DDDDD...
.DBBBBBBBD.
DBBWBWBWBBD
DBWWWWWWWBD
DBBWBWBWBBD
.DBBBBBBBD.
...DDDDD...
"""
BALL_LEGEND = {"D": "#7A3E14", "B": "#B8622E", "W": "#FFFFFF"}
FLAME = """
...R...
..RR..R
.RROR.R
.ROYORR
RROYYOR
ROYWYOR
.RYWYR.
"""
FLAME_LEGEND = {"R": "#FF3D00", "O": "#FF9100", "Y": "#FFE000", "W": "#FFF6C8"}
ICE = """
.IIIII.
IWWIIIL
IWIIIIL
IIIIIIL
IIIIIIL
IIIIIIL
.LLLLL.
"""
ICE_LEGEND = {"I": "#9FC9FF", "W": "#FFFFFF", "L": "#4A7FC0"}

CROWN = """
G.G.G.G
GGGGGGG
GRGGGRG
GGGGGGG
"""

# The conference trophy: a gold cup with handles on a walnut plinth, 13 x 15.
TROPHY = """
.GGGGGGGGGGG.
GGWYGGGGGGGGG
G.GWYGGGGGGDG
G.GWYGGGGGGDG
.GGWYGGGGGDGG
..GGYGGGGGDG.
...GGGGGGDG..
....GGGGGG...
.....GGGG....
......GG.....
......GG.....
....GGGGGG...
...BBBBBBBB..
...BGGGGGGB..
..BBBBBBBBBB.
"""
TROPHY_LEGEND = {"G": "#FFC72C", "Y": "#FFE88A", "W": "#FFFBE0", "D": "#C78F12", "B": "#7A4A1E"}
