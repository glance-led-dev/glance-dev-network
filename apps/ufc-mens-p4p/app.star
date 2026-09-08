API_URL = "https://api.citoapi.com/api/v1/ufc/rankings/media"

def get_rankings(ctx):
    key = ctx.inputs.get("citokey", "")
    if key == "":
        return []

    resp = http.get(
        API_URL,
        headers = {"x-api-key": key},
        ttl_seconds = 86400,
    )

    if resp["status_code"] != 200 or resp["json"] == None:
        return []

    data = resp["json"].get("data", [])
    rows = []

    for row in data:
        div = str(row.get(
            "normalizedDivision",
            row.get("division", "")
        )).upper()

        is_mens_p4p = (
            div == "MENS-POUND-FOR-POUND" or
            div == "MENS POUND-FOR-POUND" or
            div == "MEN'S POUND-FOR-POUND" or
            div == "MENS-P4P" or
            div == "MENS P4P"
        )

        if is_mens_p4p:
            rows.append(row)

    return rows[:15]


def main(c, ctx):
    c.clear()

    c.text("UFC MENS P4P", 4, 1, font="5x7", color="white")
    c.text("MEDIA RANKINGS", 92, 2, font="4x5", color="amber")
    c.text("LIVE", 320, 2, font="4x5", color="green")

    rows = get_rankings(ctx)

    if len(rows) == 0:
        c.text("ADD CITO API KEY", 110, 15, font="5x7", color="amber")
        return

    xs = [4, 80, 156, 232, 308]
    ys = [10, 17, 24]

    for i in range(len(rows)):
        row = rows[i]

        r = row.get("rank", None)
        if r == None:
            r = i + 1

        name = row.get("fighterName", "TBA").upper()
        if len(name) > 12:
            name = name[:12]

        move = row.get("rankChange", None)
        rank_color = "white"

        if move != None:
            if move > 0:
                rank_color = "green"
            elif move < 0:
                rank_color = "red"

        col = i % 5
        line = i // 5

        x = xs[col]
        y = ys[line]

        c.text(str(r), x, y, font="4x5", color=rank_color)
        c.text(name, x + 10, y, font="4x5", color="white")
