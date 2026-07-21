# Day of the Year - today's date up top, the ordinal day number big. (128x32)
# Jan 31 is the 31ST day, Feb 1 the 32ND, and so on. Leap years handled.

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# One hue per month; the banner is a dimmed version of the same color.
MONTH_COLORS = ["skyblue", "pink", "green", "cyan", "magenta", "yellow",
                "red", "orange", "amber", "purple", "#d2691e", "blue"]

# Days before the 1st of each month in a non-leap year.
CUM = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

def day_of_year(y, m, d):
    doy = CUM[m - 1] + d
    if m > 2 and is_leap(y):
        doy += 1
    return doy

def ordinal(n):
    # 11th-13th are TH despite ending in 1-3.
    if n % 100 >= 11 and n % 100 <= 13:
        return "TH"
    r = n % 10
    if r == 1:
        return "ST"
    if r == 2:
        return "ND"
    if r == 3:
        return "RD"
    return "TH"

def today(c, ctx):
    y = ctx.now.year
    m = ctx.now.month
    d = ctx.now.day
    doy = day_of_year(y, m, d)

    col = MONTH_COLORS[m - 1]

    c.fill("black")

    # Top bar: today's date, small, on a dark version of this month's color.
    c.rect(0, 0, c.width - 1, 8, fill = color.dim(col, 30))
    date = MONTHS[m - 1] + " " + str(d) + " " + str(y)
    c.text(date, c.width // 2, 1, font = "5x7", color = "white", align = "center")

    # Big day number with a superscript-style ordinal suffix, plus a small
    # label column, all centered as one block.
    num = str(doy)
    suf = ordinal(doy)
    nw = c.text_width(num, "16x20")
    sw = c.text_width(suf, "7x12")
    lw = max(c.text_width("DAY", "4x5"), c.text_width("OF YEAR", "4x5"))
    total = nw + 2 + sw + 6 + lw
    x = (c.width - total) // 2

    c.text(num, x, 11, font = "16x20", color = col)
    c.text(suf, x + nw + 2, 11, font = "7x12", color = col)

    lx = x + nw + 2 + sw + 6
    c.text("DAY", lx, 15, font = "4x5", color = "gray")
    c.text("OF YEAR", lx, 22, font = "4x5", color = "gray")
