# Countdown — days remaining until an event. (128x32)
# Uses ctx.now for today's date; the target comes from the `date` input.

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

def yday_of(y, m, d):
    n = d
    for i in range(m - 1):
        n = n + MDAYS[i]
    if m > 2 and is_leap(y):
        n = n + 1
    return n

def days_until(ctx, y, m, d):
    return (y - ctx.now.year) * 365 + (yday_of(y, m, d) - ctx.now.yday)

def _is_num(s):
    if len(s) == 0:
        return False
    for i in range(len(s)):
        if s[i] < "0" or s[i] > "9":
            return False
    return True

def days(c, ctx):
    event = ctx.inputs.get("event", "EVENT").upper()
    parts = ctx.inputs.get("date", "2027-01-01").split("-")

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text(event, c.width // 2, 1, font = "5x7", color = "white", align = "center")

    # Guard against anything that isn't YYYY-MM-DD so a stray input can't crash.
    if not (len(parts) == 3 and _is_num(parts[0]) and _is_num(parts[1]) and _is_num(parts[2])):
        c.text("SET DATE", c.width // 2, 14, font = "6x8", color = "red", align = "center")
        c.text("YYYY-MM-DD", c.width // 2, 25, font = "4x5", color = "gray", align = "center")
        return

    left = days_until(ctx, int(parts[0]), int(parts[1]), int(parts[2]))

    if left < 0:
        c.text("PASSED", c.width // 2, 15, font = "7x12", color = "gray", align = "center")
    elif left == 0:
        c.text("TODAY!", c.width // 2, 15, font = "7x12", color = "yellow", align = "center")
    else:
        c.text(str(left), 4, 11, font = "16x20", color = "yellow")
        c.text("TO GO", c.width - 4, 10, font = "4x5", color = "gray", align = "right")
        c.text("DAYS", c.width - 4, 18, font = "6x8", color = "orange", align = "right")
