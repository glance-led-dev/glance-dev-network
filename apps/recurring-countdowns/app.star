def calc_days(ctx, m_key, d_key, default_m, default_d):
    target_m = int(ctx.inputs.get(m_key, default_m))
    target_d = int(ctx.inputs.get(d_key, default_d))

    now = ctx.now
    curr_y = now.year

    month_days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    def get_day_of_year(y, m, d):
        total = d
        for i in range(1, m):
            total += month_days[i]
        if m > 2 and (y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)):
            total += 1
        return total

    current_doy = get_day_of_year(curr_y, now.month, now.day)
    target_doy = get_day_of_year(curr_y, target_m, target_d)

    is_leap = (curr_y % 4 == 0 and (curr_y % 100 != 0 or curr_y % 400 == 0))
    days_in_year = 366 if is_leap else 365

    diff_days = target_doy - current_doy
    if diff_days < 0:
        diff_days += days_in_year
    return diff_days

def render_event(c, ctx, type_key, name_key, m_key, d_key, default_m, default_d, default_name):
    event_type = ctx.inputs.get(type_key, "NONE")

    if event_type == "NONE":
        c.text("ACTIVE", 22, 10, font="5x7", color="#222222", align="left")
        c.text("SLOT OFF", 18, 18, font="4x5", color="#222222", align="left")
        return

    raw_name = ctx.inputs.get(name_key, default_name)
    if raw_name == None:
        raw_name = default_name
    raw_name = str(raw_name).strip().upper()

    if event_type == "BDAY":
        title = (raw_name + " BDAY") if raw_name else "BIRTHDAY"
        celeb = "HAPPY BDAY!"
    elif event_type == "ANNIV":
        title = (raw_name + " ANNIV") if raw_name else "ANNIVERSARY"
        celeb = "HAPPY ANNIV!"
    elif event_type == "TRIP":
        title = (raw_name + " TRIP") if raw_name else "TRIP"
        celeb = "TIME TO GO!"
    else:
        # Milestone: uses the user-entered string directly as the title
        title = raw_name if raw_name else "MILESTONE"
        celeb = "IT'S TIME!"

    days = calc_days(ctx, m_key, d_key, default_m, default_d)

    # ==========================================
    # TOP HEADER: Event Name (rows 0-5) - Centered at x=32
    # ==========================================
    c.text(title, 32, 0, font="4x5", color="#11A9ED", align="center")
#   c.line(0, 6, 63, 6, "#222222")

    # Usable vertical space: rows 7 to 31 (height 25 pixels)
    if days == 0:
        c.text(celeb, 32, 16, font="5x7", color="green", align="center")
    else:
        # ==========================================
        # LEFT SIDE: Vertically Centered Image
        # ==========================================
        if event_type == "ANNIV":
            c.image("anniv.png", 6, 11)
        elif event_type == "BDAY":
            c.image("bday.png", 6, 11)
        elif event_type == "TRIP":
            c.image("trip.png", 6, 11)
        else: 
            c.image("trophy.png", 6, 11)

        # ==========================================
        # RIGHT SIDE: Vertically Centered Countdown Block
        # ==========================================
        right_x = 36

        if days < 10:
            leading = "00"
            val_str = "%d" % days
        elif days < 100:
            leading = "0"
            val_str = "%d" % days
        else:
            leading = ""
            val_str = "%d" % days

        # Number line (y=15)
        cur_x = right_x
        if leading:
            c.text(leading, cur_x, 15, font="6x8", color="gray", align="left")
            cur_x += len(leading) * 6
        
        c.text(val_str, cur_x, 15, font="6x8", color="#FF3333", align="left")

        # "DAYS" label placed directly under the number (y=24)
        c.text("DAYS", right_x, 24, font="4x5", color="gray", align="left")

# ==========================================
# 6 ROTATING SLOT MAPPINGS
# ==========================================
def event1(c, ctx):
    render_event(c, ctx, "event1", "name1", "month1", "day1", "2", "4", "Dad")

def event2(c, ctx):
    render_event(c, ctx, "event2", "name2", "month2", "day2", "6", "27", "Mom")

def event3(c, ctx):
    render_event(c, ctx, "event3", "name3", "month3", "day3", "4", "30", "Kid 1")

def event4(c, ctx):
    render_event(c, ctx, "event4", "name4", "month4", "day4", "1", "1", "Kid 2")

def event5(c, ctx):
    render_event(c, ctx, "event5", "name5", "month5", "day5", "1", "1", "Kid 3")

def event6(c, ctx):
    render_event(c, ctx, "event6", "name6", "month6", "day6", "1", "1", "Event")