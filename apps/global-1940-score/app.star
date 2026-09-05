def draw_no_data(c):
    c.fill("black")
    c.text("G40", c.width // 2, 3, font = "6x8", color = "amber", align = "center")
    c.text("NO DATA", c.width // 2, 18, font = "5x7", color = "red", align = "center")


def draw_setup(c):
    c.fill("black")
    c.text("G40 SCORE", c.width // 2, 3, font = "5x7", color = "amber", align = "center")
    c.text("SET URL", c.width // 2, 18, font = "5x7", color = "white", align = "center")


def main(c, ctx):
    c.fill("black")

    score_url = ctx.inputs.get("scoreurl", "").strip()
    if score_url == "":
        draw_setup(c)
        return

    resp = http.get(score_url, ttl_seconds = 0)
    if resp["status_code"] != 200 or resp["json"] == None:
        draw_no_data(c)
        return

    data = resp["json"]
    if not data.get("ok", False):
        draw_no_data(c)
        return

    axis_ipc = int(data.get("axis_ipc", 0))
    allies_ipc = int(data.get("allies_ipc", 0))
    europe_vc = int(data.get("axis_vc_europe", 0))
    pacific_vc = int(data.get("axis_vc_pacific", 0))

    # Column headers.
    c.text("IPC", 28, 0, font = "4x5", color = "white", align = "center")
    c.text("VC", 53, 0, font = "4x5", color = "white", align = "center")

    # Axis and Allies IPC totals.
    c.text("AX", 1, 8, font = "5x7", color = "red")
    c.text(str(axis_ipc), 40, 6, font = "7x10", color = "white", align = "right")

    c.text("AL", 1, 22, font = "5x7", color = "green")
    c.text(str(allies_ipc), 40, 20, font = "7x10", color = "white", align = "right")

    # Axis victory-city counts by theater.
    c.line(43, 0, 43, 31, "darkgray")
    c.text("E" + str(europe_vc), 53, 8, font = "5x7", color = "blue", align = "center")
    c.text("P" + str(pacific_vc), 53, 22, font = "5x7", color = "blue", align = "center")


