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

def reading(c, ctx):
    c.clear()
    data = fetch_data(ctx)
    if data == None:
        letters = ["D", "E", "M", "O"]
        y = 1
        for ch in letters:
            c.text(ch, 1, y, font="4x5", color="gray", align="left")
            y += 8
        c.text_center("8:50AM", 1, font="4x7", color="amber")
        c.text_center("142", 10, font="8x12", color="green")
        c.text_center("FLAT", 24, font="5x7", color="green")
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
    arrow_color = "white"
    if direction == "SingleUp":
        arrow = "UP"
        arrow_color = "cyan"
    elif direction == "FortyFiveUp":
        arrow = "RISING"
        arrow_color = "blue"
    elif direction == "DoubleUp":
        arrow = "UP UP"
        arrow_color = "purple"
    elif direction == "SingleDown":
        arrow = "DOWN"
        arrow_color = "pink"
    elif direction == "FortyFiveDown":
        arrow = "FALLING"
        arrow_color = "magenta"
    elif direction == "DoubleDown":
        arrow = "DOWN DOWN"
        arrow_color = "skyblue"

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

    c.text_center(time_str, 1, font="4x7", color="orange")
    c.text_center(str(sgv), 10, font="8x12", color=color)
    c.text_center(arrow, 24, font="5x7", color=arrow_color)

def detail(c, ctx):
    c.clear()
    data = fetch_data(ctx)
    if data == None:
        letters = ["D", "E", "M", "O"]
        y = 1
        for ch in letters:
            c.text(ch, 1, y, font="4x5", color="gray", align="left")
            y += 8
        c.text_center("142", 4, font="8x12", color="green")
        c.text_center("3HR AVG", 22, font="5x7", color="gray")
        return
        return
    total = 0
    for e in data:
        total += e["sgv"]
    avg = total // len(data)

    c.text_center("3HR AVG", 2, font="5x7", color="gray")
    c.text_center(str(avg), 14, font="10x16", color="gray")