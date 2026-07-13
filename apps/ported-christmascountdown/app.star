# Ported from the tidbyt/community "Christmas Countdown" app
# (apps/christmascountdown/christmascountdown.star).
#
# ORIGINAL Pixlet: four base64 Christmas-tree PNG frames played as a
# render.Animation; beside the tree a render.Column shows "Merry" / "Christmas" /
# "<n> days" (days until Dec 25, computed with the time module).
#
# `gdn translate` converted the schema (3 colors + toggle + max value) and
# flagged base64/math/time/load() and the Animation/Row/Column/Image/Padding/Text
# widgets. Hand-finished for GDN (static 64x32): the DAYS-UNTIL-CHRISTMAS math
# ports (using ctx.now); the animated tree PNG became a static c.bitmap tree with
# a star and trunk; the text column ports directly.

TREE = [
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

def is_leap(y):
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)

def days_until_christmas(ctx):
    y = ctx.now.year
    today = ctx.now.yday
    # day-of-year of Dec 25 this year
    xmas = 25
    for i in range(11):
        xmas += MDAYS[i]
    if is_leap(y):
        xmas += 1
    if today <= xmas:
        return xmas - today
    diy = 366 if is_leap(y) else 365
    ny = 359 if not is_leap(y + 1) else 360
    return (diy - today) + ny

def main(c, ctx):
    days = days_until_christmas(ctx)

    c.fill("black")
    # tree (green), star (yellow), trunk (brown)
    c.bitmap(TREE, 2, 9, "green")
    c.pixel(7, 8, "yellow")
    c.rect(6, 21, 8, 23, fill = "#8a5a2b")
    # a couple of ornaments
    c.pixel(5, 13, "red")
    c.pixel(9, 16, "cyan")
    c.pixel(6, 19, "magenta")

    # text column to the right
    c.text("MERRY", 16, 4, font = "5x7", color = "red")
    c.text("CHRISTMAS", 16, 13, font = "4x5", color = "green")
    c.text(str(days) + " DAYS", 16, 21, font = "5x7", color = "#7aa0ff")
