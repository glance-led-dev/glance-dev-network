# Civic Center Muni — 64x32, one page per platform.
# Public stop codes verified against SFMTA's stop finder:
# outbound 16997 (internal 6997); inbound 15727 (internal 5727).
# 511 StopMonitoring uses agency SF and the public stopcode.
# No key -> sample preview. API failures never turn into invented live arrivals.

API = "https://api.511.org/transit/StopMonitoring"
COLORS = {"J": "#F2A541", "K": "#65C8E8", "L": "#D77ACE", "M": "#37D47B", "N": "#509DFF", "S": "#F9D45C"}
STOPS = {"OUTBOUND": "16997", "INBOUND": "15727"}
STOP_REFS = {"OUTBOUND": ["16997", "6997"], "INBOUND": ["15727", "5727"]}
MAX_TRAINS = 8

def as_list(value):
    if type(value) == "list":
        return value
    if type(value) == "dict":
        return [value]
    return []

def as_dict(value):
    return value if type(value) == "dict" else {}

def label(value):
    # Some SIRI implementations wrap text in {value: ...} or a one-item list.
    if type(value) == "list":
        value = value[0] if value else ""
    if type(value) == "dict":
        value = value.get("value", "")
    return str(value).strip() if value != None else ""

def digits(s):
    return bool(s) and all([ch in "0123456789" for ch in s.elems()])

def epoch(value):
    # ISO8601 UTC or explicit offset. Reject missing zones and malformed dates.
    s = label(value)
    if len(s) < 20 or s[4] != "-" or s[7] != "-" or s[10] != "T" or s[13] != ":" or s[16] != ":":
        return None
    fields = [s[0:4], s[5:7], s[8:10], s[11:13], s[14:16], s[17:19]]
    if not all([digits(v) for v in fields]):
        return None
    y, m, d, h, mi, se = [int(v) for v in fields]
    if m < 1 or m > 12 or h > 23 or mi > 59 or se > 59:
        return None
    leap = y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)
    lengths = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if d < 1 or d > lengths[m - 1]:
        return None
    tail = s[19:]
    if tail.startswith("."):
        # Fractional seconds do not affect minute counts.
        zone_start = -1
        for i in range(1, len(tail)):
            if tail[i] in "Z+-":
                zone_start = i
                break
        if zone_start < 0 or not digits(tail[1:zone_start]):
            return None
        tail = tail[zone_start:]
    offset = 0
    if tail != "Z":
        if len(tail) != 6 or tail[0] not in "+-" or tail[3] != ":" or not digits(tail[1:3]) or not digits(tail[4:6]):
            return None
        oh, om = int(tail[1:3]), int(tail[4:6])
        if oh > 23 or om > 59:
            return None
        offset = (oh * 3600 + om * 60) * (1 if tail[0] == "+" else -1)
    yy = y - 1 if m <= 2 else y
    era = yy // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    days = era * 146097 + yoe * 365 + yoe // 4 - yoe // 100 + doy - 719468
    return days * 86400 + h * 3600 + mi * 60 + se - offset

def failed(value):
    return value == False or str(value).lower() == "false"

def route_letter(journey):
    for value in [journey.get("PublishedLineName", ""), journey.get("LineRef", "")]:
        text = label(value).upper().replace("SF:", "").replace("SF_", "")
        if text in COLORS:
            return text
        # Accept descriptive line names; exclude buses and surface replacements.
        for letter in COLORS:
            if text.startswith(letter + " ") or text.startswith(letter + "-"):
                return letter
    return ""

def parse_feed(payload, direction, now):
    root = as_dict(payload)
    service = as_dict(as_dict(root.get("Siri", root)).get("ServiceDelivery"))
    if not service or failed(service.get("Status", True)) or service.get("ErrorCondition"):
        return {"state": "error", "what": "FEED ERROR", "action": "TRY LATER", "trains": []}
    deliveries = as_list(service.get("StopMonitoringDelivery"))
    if not deliveries:
        return {"state": "error", "what": "BAD FEED", "action": "TRY LATER", "trains": []}
    trains = []
    seen = {}
    for delivery in deliveries:
        delivery = as_dict(delivery)
        if not delivery:
            return {"state": "error", "what": "BAD FEED", "action": "TRY LATER", "trains": []}
        if failed(delivery.get("Status", True)) or delivery.get("ErrorCondition"):
            return {"state": "error", "what": "FEED ERROR", "action": "TRY LATER", "trains": []}
        stamp = epoch(delivery.get("ResponseTimestamp", service.get("ResponseTimestamp", "")))
        if stamp == None or stamp > now + 120 or now - stamp > 600:
            return {"state": "error", "what": "STALE FEED", "action": "TRY LATER", "trains": []}
        for visit in as_list(delivery.get("MonitoredStopVisit")):
            visit = as_dict(visit)
            journey = as_dict(visit.get("MonitoredVehicleJourney"))
            call = as_dict(journey.get("MonitoredCall"))
            stop = label(call.get("StopPointRef", visit.get("MonitoringRef", ""))).split(":")[-1].split("_")[-1]
            if stop not in STOP_REFS[direction] or label(journey.get("OperatorRef", "SF")) != "SF":
                continue
            route = route_letter(journey)
            if not route or failed(journey.get("Monitored", True)):
                continue
            # Only predicted arrivals; do not present scheduled times as live.
            if label(call.get("ArrivalStatus", "")).lower() in ["cancelled", "canceled"] or label(call.get("DepartureStatus", "")).lower() in ["cancelled", "canceled"]:
                continue
            arrival = epoch(call.get("ExpectedArrivalTime") or call.get("ExpectedDepartureTime", ""))
            recorded = epoch(visit.get("RecordedAtTime", ""))
            if recorded != None and (now - recorded > 600 or recorded > now + 120):
                continue
            if arrival == None or arrival < now or arrival - now > 5400:
                continue
            # Keep two distinct trains at the same minute; remove repeated trips.
            trip = label(as_dict(journey.get("FramedVehicleJourneyRef")).get("DatedVehicleJourneyRef", ""))
            identity = route + ":" + (trip or label(journey.get("VehicleRef", "")) or str(arrival))
            if identity in seen:
                continue
            seen[identity] = True
            trains.append({"route": route, "destination": label(journey.get("DestinationName", "")), "arrival": arrival, "minutes": (arrival - now + 59) // 60})
    trains = sorted(trains, key = lambda t: t["arrival"])
    return {"state": "live" if trains else "empty", "trains": trains[:MAX_TRAINS]}

def demo(direction):
    routes = ["N", "K", "L", "M", "J", "N", "K", "M"] if direction == "OUTBOUND" else ["M", "N", "J", "K", "L", "M", "N", "K"]
    minutes = [3, 5, 7, 9, 11, 13, 15, 18]
    return {"state": "demo", "trains": [{"route": routes[i], "minutes": minutes[i]} for i in range(MAX_TRAINS)]}

def fetch(ctx, direction):
    key = str(ctx.inputs.get("apikey", "") or "").strip()
    if not key:
        return demo(direction)
    response = http.get(API, params = {"api_key": key, "agency": "SF", "stopcode": STOPS[direction], "format": "json"}, ttl_seconds = 300)
    if response["status_code"] != 200:
        status = response["status_code"]
        what = "CHECK KEY" if status in [401, 403] else ("RATE LIMIT" if status == 429 else "OFFLINE")
        action = "511 TOKEN" if status in [401, 403] else "TRY LATER"
        return {"state": "error", "what": what, "action": action, "trains": []}
    return parse_feed(response["json"], direction, ctx.now.unix)

def draw(c, direction, data):
    c.clear()
    state = data["state"]
    heading = "WESTBOUND" if direction == "OUTBOUND" else "EASTBOUND"
    c.text(heading, 5, 0, font = "4x5", color = "#72D6E8")
    c.hline(2, 6, 60, "#24313E")
    if state == "error":
        c.text_center(data["what"], 10, font = "5x7", color = "amber")
        c.text_center(data["action"], 23, font = "4x5", color = "#B6BEC8")
        return
    if state == "empty":
        c.text_center("NO TRAINS", 10, font = "5x7", color = "#72D6E8")
        c.text_center("PREDICTED", 23, font = "4x5", color = "#B6BEC8")
        return
    # Eight arrivals in two spacious columns and four rows. The regular
    # 4x5 font fits two-digit minutes with room between the pairs.
    # Read left-to-right, then top-to-bottom.
    # Zero minutes is shown as 0, keeping every cell the same compact format.
    trains = data["trains"][:MAX_TRAINS]
    for i, train in enumerate(trains):
        x = 5 + (i % 2) * 32
        y = 8 + (i // 2) * 6
        route = train["route"]
        c.text(route, x, y, font = "4x5", color = COLORS[route])
        c.text(str(train["minutes"]), x + 7, y, font = "4x5", color = "white")

def outbound(c, ctx):
    draw(c, "OUTBOUND", fetch(ctx, "OUTBOUND"))

def inbound(c, ctx):
    draw(c, "INBOUND", fetch(ctx, "INBOUND"))
