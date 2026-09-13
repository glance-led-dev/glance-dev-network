def main(c, ctx):
    c.fill("black")

    # Default values
    thomas_points = 0
    thomas_rebirths = 0
    mark_points = 0
    mark_rebirths = 0

    # Fetch score CSV from server
    resp = http.get(
        "https://mulveyserver.com/str/pts",
        ttl_seconds=0
    )

    data_ok = resp["status_code"] == 200

    if data_ok:
        lines = resp["body"].splitlines()

        for line in lines:
            parts = line.strip().split(",")

            if len(parts) == 3:
                name = parts[0].upper()

                if name == "THOMAS":
                    thomas_points = int(parts[1])
                    thomas_rebirths = int(parts[2])

                elif name == "MARK":
                    mark_points = int(parts[1])
                    mark_rebirths = int(parts[2])

    # Keep values in expected ranges
    thomas_points = max(0, min(9, thomas_points))
    mark_points = max(0, min(9, mark_points))

    thomas_rebirths = max(0, min(99, thomas_rebirths))
    mark_rebirths = max(0, min(99, mark_rebirths))

    # -----------------------------
    # TITLE
    # -----------------------------

    c.rect(0, 0, 63, 6, fill="green")

    c.text(
        "POINT TRACKER",
        32,
        1,
        font="4x5",
        color="black",
        align="center"
    )

    # Center divider
    c.line(31, 8, 31, 31, "darkgray")

    # -----------------------------
    # NAMES
    # -----------------------------

    c.text(
        "THOMAS",
        15,
        8,
        font="4x5",
        color="white",
        align="center"
    )

    c.text(
        "MARK",
        48,
        8,
        font="4x5",
        color="white",
        align="center"
    )

    # -----------------------------
    # SCORES
    # -----------------------------

    if data_ok:
        # Thomas
        c.text("PTS:", 4, 15, font="4x5", color="green")
        c.text(str(thomas_points), 23, 15, font="4x5", color="green")

        c.text("RBS:", 4, 23, font="4x5", color="amber")
        c.text(str(thomas_rebirths), 23, 23, font="4x5", color="amber")

        # Mark
        c.text("PTS:", 36, 15, font="4x5", color="green")
        c.text(str(mark_points), 55, 15, font="4x5", color="green")

        c.text("RBS:", 36, 23, font="4x5", color="amber")
        c.text(str(mark_rebirths), 55, 23, font="4x5", color="amber")

    else:
        c.text("NO DATA", 32, 18, font="4x5", color="red", align="center")