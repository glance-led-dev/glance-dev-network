# Approved 192x32 SCROLL layout: carrier at x10..50; sender + tracking suffix
# on EVERY page; details x57..181; five shipping stages (not a distance percent).
COLORS = {"UPS": "#FFBF47", "FEDEX": "#C49BFF", "USPS": "#78B5FF"}
ASSETS = {"UPS": "ups.png", "FEDEX": "fedex.png", "USPS": "usps.png"}
MUTED = "#BCC6D5"

def obj(v):
    return v if type(v) == "dict" else {}

def clean(v, fallback = ""):
    if type(v) != "string":
        return fallback
    text = "".join([ch if ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :/-.,&+()" else " " for ch in v[:300].upper().elems()])
    return " ".join(text.split()) or fallback

def fit(c, text, width, font = "5x7"):
    value = clean(text)
    if c.text_width(value, font) <= width:
        return value
    for n in range(len(value), -1, -1):
        if c.text_width(value[:n] + "..", font) <= width:
            return value[:n].rstrip() + ".."
    return ""

def text(c, value, y, color = "white", font = "5x7"):
    c.text(fit(c, value, 125, font), 57, y, font = font, color = color)

def chunks(c, value, width = 125, font = "5x7"):
    # Show full long carrier messages on later passes; never silently lose them.
    result = []
    line = ""
    for word in clean(value).split():
        if c.text_width(word, font) > width:
            if line:
                result.append(line)
                line = ""
            for ch in word.elems():
                if c.text_width(line + ch, font) > width:
                    result.append(line)
                    line = ""
                line += ch
        elif c.text_width((line + " " + word).strip(), font) > width:
            result.append(line)
            line = word
        else:
            line = (line + " " + word).strip()
    if line:
        result.append(line)
    return result or ["DETAILS PENDING"]

def demo_shipments():
    return [
        {"carrier": "UPS", "sender": "BAMBU LAB", "tracking_last4": "4821", "status": "in_transit", "stage": 2, "expected_date": "TUE SEP 29", "delivery_window": "2:00-6:00 PM", "latest_message": "DEPARTED FACILITY", "latest_location": "MEMPHIS, TN", "scan_time": "SEP 26 9:42 AM CT", "origin": "AUSTIN, TX", "destination": "NEW YORK, NY"},
        {"carrier": "FEDEX", "sender": "LEGO", "tracking_last4": "7194", "status": "in_transit", "stage": 2, "expected_date": "MON SEP 28", "delivery_window": "BY END OF DAY", "latest_message": "AT LOCAL FACILITY", "latest_location": "NEWARK, NJ", "scan_time": "SEP 26 8:15 AM ET", "origin": "ROMEOVILLE, IL", "destination": "NEW YORK, NY"},
        {"carrier": "USPS", "sender": "PAPER & PINE", "tracking_last4": "5932", "status": "pre_transit", "stage": 0, "latest_message": "USPS AWAITING ITEM", "latest_location": "PORTLAND, OR", "scan_time": "SEP 25 4:10 PM PT", "origin": "PORTLAND, OR", "destination": "NEW YORK, NY"},
    ]

def feed(ctx):
    mode = ctx.inputs.get("demo", "Live")
    endpoint = ctx.inputs.get("endpoint", "").strip()
    key = ctx.inputs.get("readkey", "")
    if mode != "Live":
        items = demo_shipments()
        if mode in ["UPS", "FedEx", "USPS"]:
            items = [p for p in items if p["carrier"] == mode.upper()]
        elif mode == "No active packages":
            items = []
        elif mode == "Missing details":
            items = [{"carrier": "FEDEX", "tracking_last4": "0042", "status": "unknown"}]
        elif mode == "Long details":
            items = [dict(items[0], sender = "AN EXTREMELY LONG MERCHANT NAME", latest_message = "YOUR PACKAGE HAS DEPARTED AN INTERNATIONAL DISTRIBUTION CENTER AND IS ON ITS WAY TO THE DESTINATION", latest_location = "RANCHO SANTA MARGARITA, CA", origin = "SAN LUIS OBISPO, CA")]
        elif mode in ["Delay", "Delivery attempted"]:
            items = [dict(items[0], status = "failure", stage = 2, expected_date = "", delivery_window = "", latest_message = "WEATHER DELAY" if mode == "Delay" else "DELIVERY ATTEMPTED")]
        return {"shipments": items, "generated_at": ctx.now.unix - (7200 if mode == "Stale data" else 0), "demo": True}
    if not endpoint or not key:
        return {"error": "CONNECT PACKAGE FEED", "detail": "ADD URL AND READ KEY"}
    if not endpoint.startswith("https://"):
        return {"error": "HTTPS URL REQUIRED", "detail": "CHECK FEED SETTINGS"}
    response = http.get(endpoint, headers = {"Authorization": "Bearer " + key}, ttl_seconds = 60)
    if response.get("status", 0) in [401, 403]:
        return {"error": "FEED KEY REJECTED", "detail": "CHECK READ KEY"}
    if not response.get("ok", False):
        return {"error": "FEED UNAVAILABLE", "detail": "WILL RETRY NEXT PASS"}
    data = obj(response.get("json"))
    if type(data.get("shipments")) != "list" or data.get("schema_version") != 1:
        return {"error": "INVALID FEED", "detail": "CHECK DISCOVERY SERVICE"}
    return data

def message(c, title, detail):
    c.fill("black")
    c.text("PACKAGE TRACKER", 10, 1, font = "5x7", color = "white")
    c.text(fit(c, title, 172), 10, 12, font = "5x7", color = "amber")
    c.text(fit(c, detail, 172, "4x5"), 10, 24, font = "4x5", color = MUTED)

def header(c, p, color):
    c.fill("black")
    c.image(ASSETS[p["carrier"]], 10, 2)
    suffix = "/" + clean(p.get("tracking_last4"), "----")[-4:]
    suffix_width = c.text_width(suffix, "5x7")
    sender = clean(p.get("sender"), "SENDER UNKNOWN")
    width = 125 - suffix_width - 5
    font = "5x7" if c.text_width(sender, "5x7") <= width else "4x5"
    c.text(fit(c, sender, width, font), 57, 1 if font == "5x7" else 2, font = font, color = "white")
    c.text(suffix, 182, 1, font = "5x7", color = "white", align = "right")
    c.line(57, 9, 181, 9, "#34383F")
    stage = p.get("stage", -1)
    stage = int(max(-1, min(4, stage))) if type(stage) in ["int", "float"] else -1
    for i in range(5):
        c.rect(57 + i*25, 29, 79 + i*25, 30, fill = color if i <= stage else "#252A30")

def draw(c, ctx, view):
    data = feed(ctx)
    if data.get("error"):
        message(c, data["error"], data.get("detail", "CHECK SETTINGS"))
        return
    active = [p for p in data.get("shipments", []) if type(p) == "dict" and p.get("status") != "delivered" and p.get("archived") != True and clean(p.get("carrier")) in COLORS]
    if not active:
        message(c, "NO ACTIVE PACKAGES", "UPDATES " + clean(data.get("discovery_status", "CONNECTED")))
        return
    slot = ctx.now.unix // 60
    p = dict(active[slot % len(active)])
    p["carrier"] = clean(p.get("carrier"))
    pass_number = slot // len(active)
    color = COLORS[p["carrier"]]
    if p.get("status") in ["failure", "error", "return_to_sender", "cancelled"]:
        color = "amber"
    header(c, p, color)
    generated = data.get("generated_at", 0)
    stale = type(generated) not in ["int", "float"] or ctx.now.unix - generated > 3600 or p.get("stale") == True
    if stale:
        color = "amber"
    if view == "delivery":
        date = clean(p.get("expected_date"))
        label = "EXPECTED " + date if date else "DELIVERY PENDING"
        text(c, label, 11, color, "5x7" if c.text_width(label, "5x7") <= 125 else "4x5")
        source_problem = data.get("discovery_status") not in [None, "CONNECTED", "IMPORTING"]
        tracking_problem = not p.get("tracking_connected", data.get("tracking_status") in [None, "CONNECTED"])
        detail = "CHECK GMAIL" if source_problem else ("CHECK TRACKING" if tracking_problem else ("UPDATE OVERDUE" if stale else clean(p.get("delivery_window"), "TIME NOT PROVIDED")))
        text(c, detail, 20, "amber" if stale or source_problem or tracking_problem else MUTED)
    elif view == "latest":
        parts = chunks(c, clean(p.get("latest_message"), clean(p.get("status"), "STATUS PENDING")))
        text(c, parts[pass_number % len(parts)], 11, color)
        locations = chunks(c, clean(p.get("latest_location"), "LOCATION PENDING"))
        text(c, locations[pass_number % len(locations)], 20, MUTED)
    elif view == "scan":
        is_email = p.get("source") == "EMAIL"
        text(c, "LAST CARRIER EMAIL" if is_email else "LAST CARRIER SCAN", 11, color)
        value = clean(p.get("notification_time") if is_email else p.get("scan_time"), "TIME PENDING" if is_email else "SCAN TIME PENDING")
        text(c, value, 20, MUTED, "5x7" if c.text_width(value, "5x7") <= 125 else "4x5")
    else:
        origin = chunks(c, "FROM " + clean(p.get("origin"), "UNKNOWN"))
        destination = chunks(c, "TO " + clean(p.get("destination"), "UNKNOWN"))
        text(c, origin[pass_number % len(origin)], 11, MUTED)
        text(c, destination[pass_number % len(destination)], 20, color)

def delivery(c, ctx):
    draw(c, ctx, "delivery")

def latest(c, ctx):
    draw(c, ctx, "latest")

def scan(c, ctx):
    draw(c, ctx, "scan")

def journey(c, ctx):
    draw(c, ctx, "journey")
