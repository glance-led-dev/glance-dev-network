def fetch_data(ctx):
    domain = ctx.inputs.get("nightscouturl", "")
    token = ctx.inputs.get("token", "")
    if not domain or not token:
        return None
    resp = http.get("https://" + domain + "/api/v1/entries.json?count=36&token=" + token)
    if resp["status_code"] != 200:
        return None
    data = resp["json"]
    if len(data) == 0:
        return None
    return data

def main(c, ctx):
    c.clear()
    data = fetch_data(ctx)
    if data == None:
        c.text_center("SETUP NEEDED", 12, font="6x8", color="red")
        return

    entry = data[0]
    sgv = entry["sgv"]
    direction = entry.get("direction", "")

    color = "green"
    if sgv < 54 or sgv > 250:
        color = "red"
    elif sgv < 70 or sgv > 180:
        color = "yellow"

    arrow = "FLAT"
    if direction == "SingleUp":
        arrow = "UP"
    elif direction == "DoubleUp":
        arrow = "UP UP"
    elif direction == "FortyFiveUp":
        arrow = "RISING"
    elif direction == "SingleDown":
        arrow = "DOWN"
    elif direction == "DoubleDown":
        arrow = "DOWN DOWN"
    elif direction == "FortyFiveDown":
        arrow = "FALLING"

    total = 0
    for e in data:
        total += e["sgv"]
    avg = total // len(data)

    reading_seconds = entry["date"] // 1000
    age_minutes = (ctx.now.unix - reading_seconds) // 60

    # top row: big number left, trend centered, avg label top-right
    c.text(str(sgv), 2, 4, font="10x16", color=color, align="left")
    c.text(str(age_minutes) + " MIN AGO", 66, 8, font="4x7", color="orange", align="center")
    c.text(str(avg), 126, 4, font="10x16", color="gray", align="right")    


    # bottom row: age bottom-left, avg value bottom-right
    c.text(arrow, 2, 24, font="5x7", color=color, align="left")

    off = int(ctx.inputs.get("tzoffset", -6))
    reading_seconds = entry["date"] // 1000
    local = reading_seconds + off * 3600
    secs = local % 86400
    hour = secs // 3600
    minute = (secs % 3600) // 60
    ap = "AM" if hour < 12 else "PM"
    hh = hour % 12
    if hh == 0:
        hh = 12
    time_str = str(hh) + ":" + fmt.pad(minute) + ap

    c.text(time_str, 52, 24, font="4x7", color="orange", align="left")
    c.text("3HR AVG", 126, 24, font="4x7", color="gray", align="right")