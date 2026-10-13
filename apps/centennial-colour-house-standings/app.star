# Centennial Colour House Standings
# The supplied scores are static until a live standings source is connected.

BG = "#04070C"
WHITE = "#F2F5F8"
GRAY = "#969696"
BLACK_TEXT = "#000000"
BLACK_BACKING = "#D8DEE5"
BLUE = "#005AFF"
NAVY = "#667FCF"
RULE = "#394653"


def _draw_title(c, is_demo):
    c.fill(BG)

    # Four square marks identify the four houses.
    c.rect(10, 3, 15, 8, fill=BLACK_BACKING)
    c.rect(18, 3, 23, 8, fill=WHITE)
    c.rect(26, 3, 31, 8, fill=BLUE)
    c.rect(34, 3, 39, 8, fill=NAVY)

    if is_demo:
        c.text("DEMO", 44, 3, font="4x5", color="amber")
    else:
        c.text("PTS", 44, 3, font="4x5", color=GRAY)

    # Split the title into panel-safe lines; the complete phrase still reads
    # COLOUR HOUSE STANDINGS without spilling into the next panel.
    c.text("COLOUR", 10, 11, font="4x5", color=WHITE)
    c.text("HOUSE", 10, 17, font="4x5", color=WHITE)
    c.text("STANDINGS", 10, 24, font="4x5", color=WHITE)


def _draw_row(c, panel_x, rank, house, score, label_color, shift):
    rank_x = panel_x + 9 + shift
    name_x = panel_x + 16 + shift
    rank_y = 5 if rank in ("1", "3") else 21
    score_y = rank_y - 2

    c.text(rank, rank_x, rank_y, font="4x5", color=GRAY)

    if house == "BLACK":
        # A pale tag keeps the black house name legible on the dark panel.
        name_width = c.text_width(house, font="4x5")
        c.rect(name_x - 1, rank_y - 1, name_x + name_width, rank_y + 5, fill=BLACK_BACKING)

    c.text(house, name_x, rank_y, font="4x5", color=label_color)

    # Keep the score aligned at the right of its panel and within the 192px safe zone.
    score_width = c.text_width(score, font="5x7")
    panel_right = panel_x + 58
    if panel_right > 182:
        panel_right = 182
    score_x = panel_right - score_width
    c.text(score, score_x, score_y, font="5x7", color=GRAY)


def _draw_standings(c, is_demo):
    _draw_title(c, is_demo)

    # Panel seams, with content held inside the scroll-safe area.
    c.line(63, 4, 63, 28, RULE)
    c.line(127, 4, 127, 28, RULE)

    _draw_row(c, 64, "1", "BLACK", "369", BLACK_TEXT, 0)
    _draw_row(c, 64, "2", "WHITE", "345", WHITE, 0)
    _draw_row(c, 128, "3", "BLUE", "284", BLUE, -3)
    _draw_row(c, 128, "4", "NAVY", "262", NAVY, -3)

    c.line(72, 15, 120, 15, RULE)
    c.line(136, 15, 181, 15, RULE)


def live(c, ctx):
    _draw_standings(c, False)


# Fallback screens are drawing helpers, kept out of the manifest page rotation.
# Add them to the manifest only when runtime state routing is available.
def error(c, ctx):
    c.fill(BG)
    c.text("STANDINGS UNAVAILABLE", 10, 6, font="5x7", color="red")
    c.text("CHECK SOURCE SETTINGS", 10, 18, font="5x7", color=WHITE)


def empty(c, ctx):
    c.fill(BG)
    c.text("ALL CLEAR", c.width // 2, 10, font="7x12", color="green", align="center")


def demo(c, ctx):
    _draw_standings(c, True)

