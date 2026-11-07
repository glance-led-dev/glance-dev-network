# Dexcom Glucose — big number + trend arrow on a 64x32 Glance panel.
#
# Data comes from a small bridge server (see ../bridge/) that logs into
# Dexcom Share and serves the latest reading as JSON. Glance apps can only
# make GET requests, so the app cannot talk to Dexcom Share directly.
#
# Bridge JSON shape:
#   {"mgdl": 142, "trend": "Flat", "trend_value": 0,
#    "minutes_ago": 3, "stale": false}

TREND_VALUE = {
    "DoubleUp": 2,
    "SingleUp": 1,
    "FortyFiveUp": 0.5,
    "Flat": 0,
    "FortyFiveDown": -0.5,
    "SingleDown": -1,
    "DoubleDown": -2,
}

def color_for(mgdl):
    if mgdl < 70 or mgdl > 250:
        return "red"
    if mgdl > 180:
        return "amber"
    return "green"

def draw_arrow(c, x, y, value, col):
    # A 12x12 arrow in the box (x, y) .. (x+11, y+11). Bigger than the
    # built-in 15x15 trend_arrow, so it reads from across the room.
    cx = x + 6
    if value == 0:
        c.line(x, y + 6, x + 10, y + 6, col)
        c.line(x + 11, y + 6, x + 6, y + 1, col)
        c.line(x + 11, y + 6, x + 6, y + 11, col)
    elif value > 0:
        if value >= 2:
            # double chevron
            c.line(cx, y, x, y + 5, col)
            c.line(cx, y, x + 11, y + 5, col)
            c.line(cx, y + 6, x, y + 11, col)
            c.line(cx, y + 6, x + 11, y + 11, col)
        elif value >= 1:
            c.line(cx, y + 11, cx, y + 2, col)
            c.line(cx, y, x, y + 5, col)
            c.line(cx, y, x + 11, y + 5, col)
        else:  # forty-five up
            c.line(x, y + 11, x + 10, y + 1, col)
            c.line(x + 11, y, x + 5, y, col)
            c.line(x + 11, y, x + 11, y + 6, col)
    else:
        if value <= -2:
            # double chevron
            c.line(cx, y + 11, x, y + 6, col)
            c.line(cx, y + 11, x + 11, y + 6, col)
            c.line(cx, y + 5, x, y, col)
            c.line(cx, y + 5, x + 11, y, col)
        elif value <= -1:
            c.line(cx, y, cx, y + 9, col)
            c.line(cx, y + 11, x, y + 6, col)
            c.line(cx, y + 11, x + 11, y + 6, col)
        else:  # forty-five down
            c.line(x, y, x + 10, y + 10, col)
            c.line(x + 11, y + 11, x + 5, y + 11, col)
            c.line(x + 11, y + 11, x + 11, y + 5, col)

def draw_reading(c, mgdl, trend_value, col):
    c.text(str(mgdl), 1, 4, font = "16x24", color = col)
    draw_arrow(c, 4 + 16 * len(str(mgdl)), 10, trend_value, col)

def main(c, ctx):
    c.clear()

    url = ctx.inputs.get("bridgeurl", "") or ""
    if url == "":
        # Demo screen: no bridge configured yet.
        c.text("DEMO", 1, 3, font = "5x7", color = "gray")
        c.text("142", 1, 12, font = "10x16", color = "green")
        draw_arrow(c, 34, 16, 1, "green")
        return

    if url.endswith("/"):
        url = url[:-1]

    token = ctx.inputs.get("token", "") or ""
    params = {"token": token} if token != "" else {}

    resp = http.get(url + "/glucose", params = params, ttl_seconds = 120)
    data = resp["json"]

    if resp["status_code"] != 200 or data == None or data.get("mgdl", None) == None:
        reason = "BRIDGE DOWN"
        if resp["status_code"] != 0 and resp["status_code"] != 200:
            reason = "HTTP " + str(resp["status_code"])
        c.text("NO DATA", 32, 8, font = "5x7", color = "red", align = "center")
        c.text(reason, 32, 19, font = "4x5", color = "gray", align = "center")
        return

    mgdl = data["mgdl"]
    trend_value = data.get("trend_value", 0)
    stale = data.get("stale", False)

    col = "gray" if stale else color_for(mgdl)
    draw_reading(c, mgdl, trend_value, col)