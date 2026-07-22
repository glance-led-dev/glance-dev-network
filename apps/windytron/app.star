# windytron: Wind data from Kanaha/Hookipa stations

def fetch_wind(ctx):
    station = ctx.inputs.get("station", "Kanaha")
    url = "https://windytron.com/out/kanaha.json"
    
    r = http.get(url, ttl_seconds=300)
    
    if r["status_code"] != 200:
        return {"ok": False, "error": "FETCH ERROR " + str(r["status_code"])}
    
    data = r["json"]
    if not data:
        return {"ok": False, "error": "NO DATA"}
    
    return {
        "ok": True,
        "avg": data.get("avg", 0),
        "gust": data.get("gust", 0),
        "lull": data.get("lull", 0),
        "dir": data.get("dir_card", "--"),
        "deg": data.get("dir_deg", 0),
        "label": data.get("label", station),
    }

DEGREE = [[0,1,1,0],[1,0,0,1],[1,0,0,1],[0,1,1,0]]

def wind_color(avg):
    if avg < 10:
        return "blue"
    elif avg < 25:
        return "cyan"
    elif avg < 30:
        return "green"
    else:
        return "red"

def main(c, ctx):
    d = fetch_wind(ctx)
    
    c.fill("black")
    
    if not d["ok"]:
        c.text_center("WINDYTRON", 2, font="6x8", color="green")
        c.text_center(d["error"], 14, font="5x7", color="red")
        return
    
    # STATION NAME AT VERY TOP
    c.text_center(d["label"].upper(), 0, font="4x5", color="green")
    
    # MAIN WIND: AVG (SMALL G) GUST - CENTERED AS A GROUP
    avg_s = str(d["avg"])
    gust_s = str(d["gust"])
    avg_w = c.text_width(avg_s, "10x16")
    g_w = c.text_width("G", "5x7")
    gust_w = c.text_width(gust_s, "10x16")
    gap = 2
    total_w = avg_w + gap + g_w + gap + gust_w
    x = (c.width - total_w) // 2
    col = wind_color(d["avg"])
    c.text(avg_s, x, 7, font="10x16", color=col)
    c.text("G", x + avg_w + gap, 15, font="5x7", color=col)
    c.text(gust_s, x + avg_w + gap + g_w + gap, 7, font="10x16", color=col)
    
    # DIRECTION: NE 45°
    dir_s = d["dir"] + " " + str(d["deg"])
    deg_s = str(d["deg"])
    dir_w = c.text_width(d["dir"] + " ", "5x7")
    deg_w = c.text_width(deg_s, "5x7")
    total_w = dir_w + deg_w + 6
    x = (c.width - total_w) // 2
    c.text(dir_s, x, 24, font="5x7", color="orange")
    c.bitmap(DEGREE, x + dir_w + deg_w + 1, 23, "orange")
