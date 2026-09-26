# Cat Stats: every page honors the Scroll safe zone x=10..181.
MUTED = "#B0BECA"
WATER = "#4DCBEA"
FOOD = "#FFC875"
LITTER = "#B6A5FF"

def obj(v):
    return v if type(v) == "dict" else {}

def items(v):
    return [x for x in v if type(x) == "dict"] if type(v) == "list" else []

def clean(v):
    return "".join([ch if ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .:/%-+" else " " for ch in str(v).upper()[:100].elems()])

def txt(c, v, x, y, width, font = "4x5", color = "white"):
    s = clean(v)
    if c.text_width(s, font) > width:
        for n in range(len(s), -1, -1):
            if c.text_width(s[:n] + "..", font) <= width:
                s = s[:n] + ".."
                break
    c.text(s, x, y, font = font, color = color)

def num(v, suffix = ""):
    return str(int(v)) + suffix if type(v) in ["int", "float"] and v >= 0 and v < 10000000 else "--" + suffix

def icon(c, kind, color):
    asset = {"food": "granary.png", "water": "dockstream.png", "litter": "lr5-pro.png", "hopper": "hopper.png"}.get(kind, "cat-face.png")
    c.image(asset, 11, 1)

def base(c, title, kind, color, demo):
    c.fill("black")
    icon(c, kind, color)
    c.line(42, 2, 42, 29, "#28323B")
    txt(c, title, 48, 1, 109 if demo else 134, color = color)
    if demo:
        txt(c, "DEMO", 162, 1, 20, color = MUTED)

def branded(c, kind, label, color, demo):
    c.fill("black")
    icon(c, kind, color)
    c.line(42, 2, 42, 29, "#28323B")
    c.image("petlibro.png" if kind in ["food", "water"] else "whisker.png", 48, 0)
    txt(c, "DEMO" if demo else label, 112, 1, 70, color = color)

def bar(c, x, y, width, value, color):
    c.rect(x, y, x + width - 1, y + 1, fill = "#26313B")
    if type(value) in ["int", "float"] and value > 0:
        c.rect(x, y, x + max(1, int(width * min(value, 100) / 100)) - 1, y + 1, fill = color)

def short_time(v):
    s = str(v or "--")
    return s[-5:] if len(s) >= 5 else s

def message(c, title, sub, demo = False):
    base(c, "CAT STATS", "cat", "amber", demo)
    txt(c, title, 46, 11, 136, "5x7", "amber")
    txt(c, sub, 46, 25, 136, color = MUTED)

def demo_data(ctx):
    d = {"schema_version": 1, "generated_at": ctx.now.unix, "demo": True,
         "pets": [{"id": "pet-1", "name": "TEGAN", "weight_kg": 5.6, "age_years": 4, "age_days": 120, "visits_today": 4}],
         "devices": [
             {"kind": "feeder", "name": "GRANARY", "last_feed_at_local": "09/23 18:04", "next_feed_at_local": "09/23 22:00", "feedings_today": 3},
             {"kind": "fountain", "name": "KITCHEN", "water_pct": 82, "filter_days": 18},
             {"kind": "fountain", "name": "OFFICE", "water_pct": 64, "filter_days": 12},
             {"kind": "litter", "name": "LITTER-ROBOT 5", "status": "READY", "waste_pct": 34, "litter_pct": 81, "cycles": 127, "online": True, "hopper_connected": True}],
         "hydration": {"today_ml": 146, "seven_days_ml": 1024, "last_ml": 18, "last_at_local": "09/23 20:17", "covered_days": 7}, "alerts": []}
    mode = ctx.inputs.get("demo")
    if mode == "Alert":
        d["alerts"] = [{"title": "WATER LOW", "device": "KITCHEN FOUNTAIN", "priority": 1}]
    elif mode == "Missing":
        d["hydration"] = {"covered_days": 2}
        d["devices"] = []
        d["pets"] = []
    elif mode == "Stale":
        d["generated_at"] = ctx.now.unix - 3600
    elif mode == "Long names":
        d["pets"][0]["name"] = "A VERY LONG CONFIGURABLE PET NAME"
        d["devices"][0]["name"] = "DOWNSTAIRS GRANARY CAMERA FEEDER"
    return d

def data(c, ctx):
    if ctx.inputs.get("demo", "Live") != "Live":
        d = demo_data(ctx)
    else:
        endpoint = ctx.inputs.get("endpoint", "")
        key = ctx.inputs.get("readkey", "")
        if not endpoint or not key:
            message(c, "SETUP REQUIRED", "ADD ENDPOINT + KEY")
            return None
        if not endpoint.startswith("https://"):
            message(c, "HTTPS REQUIRED", "CHECK ENDPOINT URL")
            return None
        response = http.get(endpoint, headers = {"x-api-key": key}, ttl_seconds = 300)
        d = response.get("json") if response.get("status_code") == 200 else None
    if type(d) != "dict" or d.get("schema_version") != 1:
        message(c, "NO CAT DATA", "CHECK SETUP / KEY")
        return None
    generated = d.get("generated_at")
    if type(generated) not in ["int", "float"] or ctx.now.unix - generated > 900 or generated > ctx.now.unix + 60 or d.get("stale") == True:
        message(c, "DATA STALE", "CHECK CAT STATS SERVICE", d.get("demo", False))
        return None
    return d

def alerts(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    warnings = items(d.get("alerts"))
    if not warnings:
        base(c, "CAT STATS / CHECK-IN", "cat", WATER, d.get("demo"))
        txt(c, "NO ACTIVE ALERTS", 46, 11, 136, "5x7", WATER)
        txt(c, "FOOD / WATER / LITTER", 46, 25, 136, color = MUTED)
        return
    priority = min([a.get("priority", 9) for a in warnings if type(a.get("priority", 9)) == "int"] or [9])
    warnings = [a for a in warnings if a.get("priority", 9) == priority] or warnings[:1]
    a = warnings[int(ctx.now.unix // 300) % len(warnings)]
    base(c, "NEEDS ATTENTION", {"feeder": "food", "fountain": "water", "litter": "litter"}.get(a.get("kind"), "cat"), FOOD, d.get("demo"))
    txt(c, a.get("title", "DEVICE ALERT"), 46, 11, 136, "5x7", FOOD)
    txt(c, a.get("device", "CHECK DEVICE"), 46, 25, 136, color = MUTED)

def select(d, kind, ctx):
    values = [x for x in items(d.get("devices")) if x.get("kind") == kind]
    return values[int(ctx.now.unix // 300) % len(values)] if values else {}

def summary(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    pets = [p for p in items(d.get("pets")) if not ctx.inputs.get("petid", "") or p.get("id") == ctx.inputs.get("petid", "")]
    p = pets[int(ctx.now.unix // 300) % len(pets)] if pets else {}
    base(c, p.get("name", "CAT STATS"), "cat", WATER, d.get("demo"))
    w = p.get("weight_kg")
    unit = ctx.inputs.get("units", "lb")
    tenths = int((w * 2.2046226218 if unit == "lb" else w) * 10 + 0.5) if type(w) in ["int", "float"] else None
    weight = str(tenths // 10) + "." + str(tenths % 10) + " " + unit if tenths != None else "-- " + unit
    txt(c, weight, 48, 12, 72, "5x7")
    txt(c, "WEIGHT", 48, 25, 68, color = MUTED)
    age = num(p.get("age_years")) + "Y " + num(p.get("age_days")) + "D"
    txt(c, age, 116, 12, 66, "5x7", LITTER)
    txt(c, "AGE", 116 + (min(66, c.text_width(age, "5x7")) - c.text_width("AGE", "4x5")) // 2, 25, 66, color = MUTED)

def feeding(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    f = select(d, "feeder", ctx)
    branded(c, "food", "FEEDING", FOOD, d.get("demo"))
    txt(c, "LAST " + str(f.get("last_feed_at_local") or "NOT REPORTED"), 48, 11, 134)
    txt(c, "NEXT " + str(f.get("next_feed_at_local") or "NOT REPORTED"), 48, 19, 134, color = MUTED)
    txt(c, num(f.get("feedings_today")) + " FEEDS TODAY", 48, 27, 90, color = FOOD)
    if f.get("food_low") == True:
        txt(c, "FOOD LOW", 142, 27, 40, color = FOOD)

def hydration(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    h = obj(d.get("hydration"))
    if ctx.inputs.get("petid", ""):
        matching = [p for p in items(d.get("pets")) if p.get("id") == ctx.inputs.get("petid", "")]
        h = obj(matching[0].get("hydration")) if matching else {}
    branded(c, "water", "WATER INTAKE", WATER, d.get("demo"))
    txt(c, num(h.get("today_ml")) + " ML", 48, 11, 69, "5x7", WATER)
    txt(c, num(h.get("seven_days_ml")) + " ML", 119, 11, 63, "5x7")
    txt(c, "TODAY", 48, 19, 63, color = MUTED)
    txt(c, "7 DAYS", 119, 19, 63, color = MUTED)
    last = "LAST " + num(h.get("last_ml"), "ML ") + short_time(h.get("last_at_local")) if h.get("last_ml") != None else "LAST DRINK NOT REPORTED"
    txt(c, last, 48, 27, 134, color = MUTED)

def fountains(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    fs = [f for f in items(d.get("devices")) if f.get("kind") == "fountain"]
    branded(c, "water", "TANK LEVELS", WATER, d.get("demo"))
    start = (int(ctx.now.unix // 300) % max(1, (len(fs) + 1) // 2)) * 2
    for i in range(2):
        f = fs[start + i] if start + i < len(fs) else {}
        x = 48 + i * 70
        name = str(f.get("name", "NO FOUNTAIN")).upper().replace(" FOUNTAIN", "")
        txt(c, name, x, 11, 64, color = MUTED)
        txt(c, num(f.get("water_pct"), "%"), x, 17, 64, "5x7", WATER)
        bar(c, x, 24, 62, f.get("water_pct"), WATER)
        txt(c, "FILTER IN " + num(f.get("filter_days"), "D"), x, 27, 64, color = MUTED)

def litter(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    l = select(d, "litter", ctx)
    branded(c, "litter", l.get("status") or "UNKNOWN", LITTER, d.get("demo"))
    txt(c, "DRAWER", 48, 10, 64, color = MUTED)
    txt(c, "BED LEVEL", 118, 10, 64, color = MUTED)
    txt(c, num(l.get("waste_pct"), "%"), 48, 17, 64, "5x7", LITTER)
    txt(c, num(l.get("litter_pct"), "%"), 118, 17, 64, "5x7")
    bar(c, 48, 28, 62, l.get("waste_pct"), LITTER)
    bar(c, 118, 28, 62, l.get("litter_pct"), LITTER)

def cycles(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    l = select(d, "litter", ctx)
    branded(c, "litter", "CLEAN CYCLES", LITTER, d.get("demo"))
    txt(c, num(l.get("cycles")) + " CYCLES", 48, 12, 134, "5x7", LITTER)
    txt(c, "LIFETIME TOTAL", 48, 26, 134, color = MUTED)

def hopper(c, ctx):
    d = data(c, ctx)
    if d == None:
        return
    l = select(d, "litter", ctx)
    branded(c, "hopper", "LITTERHOPPER", LITTER, d.get("demo"))
    status = l.get("hopper_status")
    txt(c, status or "LEVEL NOT REPORTED", 48, 12, 134, "5x7", LITTER)

