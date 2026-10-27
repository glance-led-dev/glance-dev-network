# Amtrak Departures - Glance LED app (64x32)
# Live data: Amtraker API (https://api-v3.amtraker.com/docs), an unofficial
# third-party service built on Amtrak's train-tracking map data. Attribution
# to Amtraker is required by its ODC-By license. Not affiliated with Amtrak.

URL = "https://api-v3.amtraker.com/v3/trains"

NAMES = {
    "NYP": "NEW YORK PENN",
    "WAS": "WASHINGTON UNION",
    "BOS": "BOSTON SOUTH",
    "BBY": "BOSTON BACK BAY",
    "PHL": "PHILADELPHIA 30TH ST",
    "BAL": "BALTIMORE PENN",
    "BWI": "BWI AIRPORT",
    "WIL": "WILMINGTON DE",
    "NWK": "NEWARK PENN",
    "TRE": "TRENTON",
    "HAR": "HARRISBURG",
    "PVD": "PROVIDENCE",
    "NHV": "NEW HAVEN",
    "ALB": "ALBANY RENSSELAER",
    "SYR": "SYRACUSE",
    "ROC": "ROCHESTER NY",
    "BUF": "BUFFALO DEPEW",
    "NFS": "NIAGARA FALLS",
    "RVR": "RICHMOND STAPLES MILL",
    "NFK": "NORFOLK",
    "NPN": "NEWPORT NEWS",
    "CLT": "CHARLOTTE",
    "RGH": "RALEIGH",
    "SAV": "SAVANNAH",
    "JAX": "JACKSONVILLE",
    "ORL": "ORLANDO",
    "TPA": "TAMPA",
    "MIA": "MIAMI",
    "NOL": "NEW ORLEANS",
    "ATL": "ATLANTA PEACHTREE",
    "CHS": "CHARLESTON SC",
    "CHI": "CHICAGO UNION",
    "MKE": "MILWAUKEE",
    "STL": "ST LOUIS",
    "KCY": "KANSAS CITY",
    "DET": "DETROIT",
    "PIT": "PITTSBURGH",
    "CLE": "CLEVELAND",
    "CIN": "CINCINNATI",
    "IND": "INDIANAPOLIS",
    "MSP": "ST PAUL MINNEAPOLIS",
    "DEN": "DENVER",
    "SLC": "SALT LAKE CITY",
    "SEA": "SEATTLE",
    "PDX": "PORTLAND OR",
    "SAC": "SACRAMENTO",
    "EMY": "EMERYVILLE",
    "LAX": "LOS ANGELES",
    "SAN": "SAN DIEGO",
    "SBA": "SANTA BARBARA",
    "SJC": "SAN JOSE",
    "ABQ": "ALBUQUERQUE",
    "FLG": "FLAGSTAFF",
    "TUS": "TUCSON",
    "SAS": "SAN ANTONIO",
    "DAL": "DALLAS",
    "FTW": "FORT WORTH",
    "HOU": "HOUSTON",
    "AUS": "AUSTIN",
    "OKC": "OKLAHOMA CITY",
    "MEM": "MEMPHIS",
}

DEMO = [
    {"num": "171", "dest": "BOSTON SOUTH STATION", "t": "2026-01-01T10:45:00-05:00", "sch": "2026-01-01T10:45:00-05:00", "msg": ""},
    {"num": "2150", "dest": "CHICAGO UNION STATION", "t": "2026-01-01T11:12:00-05:00", "sch": "2026-01-01T11:00:00-05:00", "msg": ""},
    {"num": "91", "dest": "MIAMI", "t": "2026-01-01T11:40:00-05:00", "sch": "2026-01-01T11:40:00-05:00", "msg": ""},
    {"num": "79", "dest": "CHARLOTTE", "t": "2026-01-01T12:05:00-05:00", "sch": "2026-01-01T12:05:00-05:00", "msg": "CANCELED"},
]

# ---------- small helpers ----------

def p2(n):
    s = str(n)
    if len(s) < 2:
        return "0" + s
    return s

def toint(s):
    s = s.lstrip("0")
    if s == "":
        return 0
    return int(s)

def hm(ts):
    # "2026-10-26T10:45:00-04:00" -> (10, 45); None if it can't be read
    if ts == None or type(ts) != "string" or len(ts) < 16:
        return None
    parts = ts.split("T")
    if len(parts) < 2 or len(parts[1]) < 5:
        return None
    return (toint(parts[1][0:2]), toint(parts[1][3:5]))

def h12(h):
    r = h % 12
    if r == 0:
        return 12
    return r

def clock(ts):
    v = hm(ts)
    if v == None:
        return "--:--"
    ap = "A"
    if v[0] >= 12:
        ap = "P"
    return str(h12(v[0])) + ":" + p2(v[1]) + ap

def delay_min(t, sch):
    a = hm(t)
    b = hm(sch)
    if a == None or b == None:
        return 0
    d = (a[0] * 60 + a[1]) - (b[0] * 60 + b[1])
    if t[0:10] > sch[0:10]:
        d += 1440
    elif t[0:10] < sch[0:10]:
        d -= 1440
    return d

def short(s):
    s = s.upper().strip()
    for w in [" STATION", " UNION"]:
        s = s.replace(w, "")
    return s

def clip(c, s, font, maxw):
    for i in range(60):
        if len(s) <= 1 or c.text_width(s, font) <= maxw:
            return s
        s = s[:-1]
    return s

def status_of(tr):
    # returns (label, color)
    if "CANCEL" in tr["msg"].upper():
        return ("CANCELED", "red")
    d = delay_min(tr["t"], tr["sch"])
    if d > 5:
        return ("+" + str(d) + "M", "amber")
    return ("ON TIME", "green")

# ---------- data ----------

def collect(data, code):
    found = []
    name = ""
    for key in data:
        trains = data[key]
        if type(trains) != "list":
            continue
        for tr in trains:
            for stop in tr.get("stations") or []:
                if stop.get("code") != code or stop.get("bus"):
                    continue
                if not name:
                    name = stop.get("name") or ""
                if stop.get("status") == "Departed":
                    continue
                sch = stop.get("schDep") or ""
                if sch == "":
                    continue
                t = stop.get("dep") or sch
                found.append({
                    "num": tr.get("trainNumRaw") or tr.get("trainNum") or "",
                    "dest": tr.get("destName") or "",
                    "t": t,
                    "sch": sch,
                    "msg": tr.get("statusMsg") or "",
                })
    keys = []
    for i, d in enumerate(found):
        keys.append((d["t"][0:16], i))
    out = []
    for k in sorted(keys):
        out.append(found[k[1]])
    return (out, name)

def state(ctx):
    code = (ctx.inputs.get("customcode", "") or "").strip().upper()
    if code == "":
        code = ctx.inputs.get("station", "NYP")
    rows = 4
    if str(ctx.inputs.get("rows", "4")) == "2":
        rows = 2
    d = ctx.inputs.get("demo", False)
    demo = d == True or d == "true"
    name = NAMES.get(code, code)
    if demo:
        return {"kind": "demo", "trains": DEMO[:rows], "name": name, "code": code, "rows": rows}
    resp = http.get(URL, ttl_seconds = 300)
    if resp["status_code"] != 200:
        return {"kind": "error", "trains": [], "name": name, "code": code, "rows": rows}
    data = resp["json"]
    if type(data) != "dict":
        return {"kind": "error", "trains": [], "name": name, "code": code, "rows": rows}
    res = collect(data, code)
    if res[1]:
        name = res[1].upper()
    trains = res[0][:rows]
    kind = "ok"
    if len(trains) == 0:
        kind = "empty"
    return {"kind": kind, "trains": trains, "name": name, "code": code, "rows": rows}

# ---------- screens ----------

def draw_error(c):
    c.fill("black")
    c.text("NO DATA", 2, 8, font = "5x7", color = "red")
    c.text("WILL RETRY", 2, 19, font = "4x5", color = "gray")

def draw_empty(c):
    c.fill("black")
    c.text("ALL CLEAR", 2, 8, font = "5x7", color = "green")
    c.text("NO TRAINS", 2, 19, font = "4x5", color = "gray")

def wrap(c, name, font, maxw):
    lines = []
    cur = ""
    for w in name.split(" "):
        if w == "":
            continue
        cand = w
        if cur != "":
            cand = cur + " " + w
        if c.text_width(cand, font) <= maxw:
            cur = cand
        else:
            if cur != "":
                lines.append(cur)
            cur = clip(c, w, font, maxw)
    if cur != "":
        lines.append(cur)
    return lines

def title(c, ctx):
    s = state(ctx)
    c.fill("black")
    name = short(s["name"])
    font = "5x7"
    ys = [1, 9]
    lines = wrap(c, name, "5x7", 62)
    widest = 0
    for w in name.split(" "):
        if c.text_width(w, "5x7") > widest:
            widest = c.text_width(w, "5x7")
    if len(lines) > 2 or widest > 62:
        font = "4x5"
        ys = [0, 6, 12]
        lines = wrap(c, name, "4x5", 62)[:3]
    for i, ln in enumerate(lines):
        c.text(ln, 2, ys[i], font = font, color = "white")
    c.rect(0, 17, 63, 17, fill = "amber")
    c.text("AMTRAK", 2, 20, font = "4x5", color = "amber")
    if s["kind"] == "demo":
        w = c.text_width("DEMO", "4x5")
        c.text("DEMO", 62 - w, 20, font = "4x5", color = "amber")
    c.text("DEPARTURES", 2, 26, font = "4x5", color = "gray")

def next_train(c, ctx):
    s = state(ctx)
    if s["kind"] == "error":
        draw_error(c)
        return
    if s["kind"] == "empty":
        draw_empty(c)
        return
    tr = s["trains"][0]
    c.fill("black")
    st = status_of(tr)
    label = "NEXT"
    if s["kind"] == "demo":
        label = "DEMO"
    lw = c.text_width(label, "4x5")
    sw = c.text_width(st[0], "4x5")
    if 1 + lw + 2 + sw <= 62:
        c.text(label, 1, 1, font = "4x5", color = "amber" if s["kind"] == "demo" else "gray")
    c.text(st[0], 63 - sw, 1, font = "4x5", color = st[1])
    v = hm(tr["t"])
    if v == None:
        big = "--:--"
        ap = ""
    else:
        big = str(h12(v[0])) + ":" + p2(v[1])
        ap = "AM"
        if v[0] >= 12:
            ap = "PM"
    font = "10x16"
    th = 16
    apw = c.text_width("AM", "5x7")
    if 2 + c.text_width(big, font) + 2 + apw > 63:
        font = "7x12"
        th = 12
    ty = 7 + (16 - th) // 2
    c.text(big, 2, ty, font = font, color = st[1])
    bw = c.text_width(big, font)
    c.text(ap, 2 + bw + 2, ty + th - 7, font = "5x7", color = st[1])
    line = clip(c, tr["num"] + " " + short(tr["dest"]), "5x7", 61)
    c.text(line, 2, 25, font = "5x7", color = "white")

def draw_row(c, tr, y0):
    st = status_of(tr)
    c.text(tr["num"], 1, y0 + 2, font = "4x5", color = "white")
    if st[0] == "CANCELED":
        tt = "CXLD"
    else:
        tt = clock(tr["t"])
    tw = c.text_width(tt, "5x7")
    c.text(tt, 64 - tw, y0 + 1, font = "5x7", color = st[1])
    right = 0
    if st[1] == "amber":
        dw = c.text_width(st[0], "4x5")
        c.text(st[0], 63 - dw, y0 + 9, font = "4x5", color = "amber")
        right = dw + 3
    c.text(clip(c, short(tr["dest"]), "4x5", 62 - right), 1, y0 + 9, font = "4x5", color = "gray")

def board(c, ctx, page):
    s = state(ctx)
    if s["kind"] == "error":
        draw_error(c)
        return
    if s["kind"] == "empty":
        draw_empty(c)
        return
    c.fill("black")
    chunk = s["trains"][page * 2:page * 2 + 2]
    if len(chunk) == 0:
        w = c.text_width(s["code"], "10x16")
        c.text(s["code"], 32 - w // 2, 3, font = "10x16", color = "white")
        c.text("END OF LIST", 2, 24, font = "4x5", color = "gray")
        return
    draw_row(c, chunk[0], 0)
    if len(chunk) > 1:
        c.rect(0, 15, 63, 15, fill = "#333333")
        draw_row(c, chunk[1], 16)

def board1(c, ctx):
    board(c, ctx, 0)

def board2(c, ctx):
    board(c, ctx, 1)
