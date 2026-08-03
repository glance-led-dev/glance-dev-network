# Pixel Residents is a stateless, original pixel-art life simulation.
# Every frame is derived from UTC time and the resident's configuration.

PALETTES = {
    "COZY": {
        "wall": "#17110F",
        "wallline": "#38251D",
        "floor": "#4A2F20",
        "floorline": "#6C4328",
        "bed": "#B84D3A",
        "bedlight": "#E27B55",
        "furniture": "#79452B",
        "furniturelight": "#B8733F",
        "accent": "#FFB347",
        "soft": "#FFE0A3",
        "plant": "#36A852",
        "screen": "#55D6BE",
        "pants": "#28527A",
    },
    "MODERN": {
        "wall": "#101820",
        "wallline": "#284052",
        "floor": "#2E3A46",
        "floorline": "#536577",
        "bed": "#365D78",
        "bedlight": "#5E91B5",
        "furniture": "#394B59",
        "furniturelight": "#78909C",
        "accent": "#38D6E8",
        "soft": "#B7E8F2",
        "plant": "#42B883",
        "screen": "#37C6FF",
        "pants": "#252A34",
    },
    "ARCADE": {
        "wall": "#150D24",
        "wallline": "#48215F",
        "floor": "#25143A",
        "floorline": "#67308A",
        "bed": "#753B9C",
        "bedlight": "#C34FCB",
        "furniture": "#3F2360",
        "furniturelight": "#8C42B8",
        "accent": "#FF4FD8",
        "soft": "#78FFF1",
        "plant": "#54E65C",
        "screen": "#00E5FF",
        "pants": "#233A80",
    },
    "CABIN": {
        "wall": "#18110B",
        "wallline": "#4B2D18",
        "floor": "#56351E",
        "floorline": "#83532C",
        "bed": "#7F3C2A",
        "bedlight": "#B45F3B",
        "furniture": "#68401F",
        "furniturelight": "#A66A32",
        "accent": "#FF9D3D",
        "soft": "#FFD28A",
        "plant": "#4F9138",
        "screen": "#73B7A8",
        "pants": "#344D38",
    },
    "NIGHT": {
        "wall": "#080D1C",
        "wallline": "#172A4A",
        "floor": "#111C33",
        "floorline": "#243D66",
        "bed": "#242F62",
        "bedlight": "#42558E",
        "furniture": "#17294A",
        "furniturelight": "#314F76",
        "accent": "#688CFF",
        "soft": "#9CCBFF",
        "plant": "#247A58",
        "screen": "#4BE0FF",
        "pants": "#151D38",
    },
}

SKIN_TONES = {
    "LIGHT": "#FFD0A8",
    "MEDIUM": "#D99562",
    "TAN": "#B96F45",
    "DARK": "#75452F",
}

TIMEZONE_OFFSETS = {
    "UTC-12": -12,
    "UTC-11": -11,
    "UTC-10": -10,
    "UTC-09": -9,
    "UTC-08": -8,
    "UTC-07": -7,
    "UTC-06": -6,
    "UTC-05": -5,
    "UTC-04": -4,
    "UTC-03": -3,
    "UTC-02": -2,
    "UTC-01": -1,
    "UTC+00": 0,
    "UTC+01": 1,
    "UTC+02": 2,
    "UTC+03": 3,
    "UTC+04": 4,
    "UTC+05": 5,
    "UTC+06": 6,
    "UTC+07": 7,
    "UTC+08": 8,
    "UTC+09": 9,
    "UTC+10": 10,
    "UTC+11": 11,
    "UTC+12": 12,
    "UTC+13": 13,
    "UTC+14": 14,
}


def safe_input(ctx, key, default):
    value = ctx.inputs.get(key, default)
    if value == None or value == "":
        return default
    return value


def normalize_checkbox(value):
    if value == True:
        return True
    return str(value).upper() in ["TRUE", "1", "YES", "ON"]


def safe_name(value, c):
    name = str(value).upper()
    result = ""
    # The 3x4 font is compact, but measure rather than trusting character count.
    for i in range(1, len(name) + 1):
        candidate = name[:i]
        if c.text_width(candidate, font="3x4") <= 34:
            result = candidate
    if result == "":
        return "PIXEL"
    return result


def safe_message(value, c):
    message = str(value).upper()
    result = ""
    for i in range(1, len(message) + 1):
        candidate = message[:i]
        if c.text_width(candidate, font="4x5") <= 104:
            result = candidate
    return result


def get_palette(theme):
    return PALETTES.get(theme, PALETTES["COZY"])


def is_leap_year(year):
    return year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)


def days_in_month(year, month):
    if month in [4, 6, 9, 11]:
        return 30
    if month == 2:
        return 29 if is_leap_year(year) else 28
    return 31


def shifted_date(year, month, day, shift):
    if shift < 0:
        day -= 1
        if day < 1:
            month -= 1
            if month < 1:
                month = 12
                year -= 1
            day = days_in_month(year, month)
    elif shift > 0:
        day += 1
        if day > days_in_month(year, month):
            day = 1
            month += 1
            if month > 12:
                month = 1
                year += 1
    return [year, month, day]


def get_local_time(ctx, timezone):
    offset = TIMEZONE_OFFSETS.get(timezone, -5)
    local_unix = ctx.now.unix + offset * 3600
    seconds = local_unix % 86400
    day_shift = local_unix // 86400 - ctx.now.unix // 86400
    date = shifted_date(ctx.now.year, ctx.now.month, ctx.now.day, day_shift)
    return {
        "year": date[0],
        "month": date[1],
        "day": date[2],
        "hour": seconds // 3600,
        "minute": (seconds % 3600) // 60,
        "weekday": (ctx.now.weekday + day_shift) % 7,
    }


def get_easter_date(year):
    # Gregorian computus; returns [month, day] without external date APIs.
    a = year % 19
    b = year // 100
    c = year % 100
    d = b // 4
    e = b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i = c // 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) // 451
    value = h + l - 7 * m + 114
    return [value // 31, value % 31 + 1]


def resolve_season(local_time):
    # Auto seasonal decor from local date only — no user demo override.
    season = local_time["month"]
    easter = get_easter_date(local_time["year"])
    if local_time["month"] == 1 and local_time["day"] == 1:
        season = 101
    elif local_time["month"] == 2 and local_time["day"] == 14:
        season = 214
    elif local_time["month"] == easter[0] and local_time["day"] == easter[1]:
        season = 401
    elif local_time["month"] == 7 and local_time["day"] == 4:
        season = 704
    elif local_time["month"] == 11 and local_time["weekday"] == 3 and local_time["day"] >= 22 and local_time["day"] <= 28:
        season = 1124
    elif local_time["month"] == 12 and local_time["day"] == 31:
        season = 1231
    return season


def adjusted_hour(hour, schedule):
    # Advancing the schedule clock makes events happen earlier in real time.
    if schedule == "EARLY BIRD":
        return (hour + 2) % 24
    if schedule == "NIGHT OWL":
        return (hour + 21) % 24
    return hour


def activity_pool(hour, personality):
    if hour < 6 or hour == 23:
        return ["SLEEP"]

    if hour < 8:
        if personality == "LAZY":
            return ["SLEEP", "WAKE", "WAKE", "EAT"]
        if personality == "BUSY":
            return ["WAKE", "EAT", "WALK", "CLEAN"]
        return ["WAKE", "WAKE", "EAT", "WALK"]

    if hour < 12:
        if personality == "COZY":
            return ["EAT", "CLEAN", "SIT", "WORK"]
        if personality == "BUSY":
            return ["WORK", "WALK", "CLEAN", "WORK", "WALK"]
        if personality == "LAZY":
            return ["SIT", "IDLE", "SLEEP", "EAT"]
        if personality == "GAMER":
            return ["WORK", "PLAY", "EAT", "WALK"]
        if personality == "BOOKWORM":
            return ["SIT", "SIT", "WORK", "CLEAN"]
        return ["WORK", "WALK", "CLEAN", "SIT", "EAT", "PLAY", "IDLE"]

    if hour < 14:
        if personality == "LAZY":
            return ["EAT", "SIT", "SLEEP"]
        return ["EAT", "SIT", "WALK", "PET"]

    if hour < 18:
        if personality == "COZY":
            return ["CLEAN", "SIT", "PET", "WORK"]
        if personality == "BUSY":
            return ["WORK", "WALK", "CLEAN", "WORK", "PET"]
        if personality == "LAZY":
            return ["SIT", "SLEEP", "IDLE", "PET"]
        if personality == "GAMER":
            return ["WORK", "PLAY", "PLAY", "PET"]
        if personality == "BOOKWORM":
            return ["SIT", "WORK", "SIT", "PET"]
        return ["WORK", "PLAY", "CLEAN", "WALK", "SIT", "PET", "IDLE"]

    if hour < 21:
        if personality == "COZY":
            return ["EAT", "SIT", "PET", "CLEAN"]
        if personality == "BUSY":
            return ["EAT", "WORK", "WALK", "CLEAN"]
        if personality == "LAZY":
            return ["EAT", "SIT", "SIT", "IDLE"]
        if personality == "GAMER":
            return ["EAT", "PLAY", "PLAY", "PLAY"]
        if personality == "BOOKWORM":
            return ["EAT", "SIT", "SIT", "PET"]
        return ["EAT", "PLAY", "SIT", "PET", "WALK", "IDLE"]

    if personality == "GAMER":
        return ["PLAY", "PLAY", "SIT", "SLEEP"]
    if personality == "BOOKWORM":
        return ["SIT", "SIT", "IDLE", "SLEEP"]
    if personality == "LAZY":
        return ["SIT", "SLEEP", "SLEEP", "IDLE"]
    return ["SIT", "IDLE", "PET", "SLEEP"]


def choose_activity(ctx, local_time, personality, schedule, previewmode, name):
    if previewmode not in ["AUTO", "AUTO ROUTINE"]:
        actions = {
            "MAKE COFFEE": "EAT",
            "PLAY GAME": "PLAY",
            "READ BOOK": "SIT",
            "WATER PLANT": "WATER",
            "CALL PET": "PET",
            "FEED PET": "PETFEED",
            "PLAY WITH PET": "PETPLAY",
            "PET NAP": "PETNAP",
            "GO TO BED": "SLEEP",
        }
        return actions.get(previewmode, previewmode)
    hour = adjusted_hour(local_time["hour"], schedule)
    pool = activity_pool(hour, personality)
    # Activity changes at most every five minutes and never flickers randomly.
    slot = local_time["minute"] // 5
    seed = ctx.now.yday * 97 + hour * 13 + slot * 7 + len(name) * 3 + len(personality)
    return pool[seed % len(pool)]


def get_resident_message(activity, personality, frame, personality_enabled):
    personality_messages = {
        "COZY": ["STAY COZY", "COFFEE HELPS"],
        "BUSY": ["LETS GET IT DONE", "ONE THING AT A TIME"],
        "LAZY": ["NO RUSH", "NAP O CLOCK"],
        "GAMER": ["LEVEL UP", "READY PLAYER ONE"],
        "BOOKWORM": ["ONE MORE CHAPTER", "GOOD BOOK TODAY"],
        "RANDOM": ["TRY SOMETHING NEW", "TODAY IS YOURS"],
    }
    if personality_enabled and frame % 4 == 3:
        choices = personality_messages.get(personality, personality_messages["COZY"])
        return choices[(frame // 4) % len(choices)]

    messages = {
        "SLEEP": ["GOOD NIGHT", "SWEET DREAMS"],
        "WAKE": ["GOOD MORNING", "UP AND AT EM"],
        "WALK": ["GETTING STEPS", "NICE WALK"],
        "SIT": ["ONE MORE PAGE", "COZY TIME"],
        "EAT": ["COFFEE TIME", "TASTY"],
        "WORK": ["CHECKING MAIL", "BUSY BUSY"],
        "PLAY": ["HIGH SCORE", "ONE MORE ROUND"],
        "CLEAN": ["PLANT IS HAPPY", "ALL CLEAN"],
        "WATER": ["PLANT IS HAPPY", "NICE AND GREEN"],
        "PET": ["GOOD PET", "BEST FRIEND"],
        "PETFEED": ["DINNER TIME", "ENJOY YOUR FOOD"],
        "PETPLAY": ["PLAY TIME", "FETCH"],
        "PETNAP": ["SO PEACEFUL", "SWEET PET DREAMS"],
        "IDLE": ["NICE TO SEE YOU", "JUST RELAXING"],
        "WAVE": ["HELLO THERE", "HI FRIEND"],
        "DANCE": ["DANCE BREAK", "FEEL THE BEAT"],
    }
    choices = messages.get(activity, ["HELLO"])
    return choices[frame % len(choices)]


def get_uplifting_message(local_time):
    messages = [
        "YOU GOT THIS",
        "PROUD OF YOU",
        "KEEP GOING",
        "TAKE CARE TODAY",
        "ONE STEP AT A TIME",
        "YOU ARE DOING GREAT",
    ]
    seed = local_time["day"] * 3 + local_time["hour"] * 2 + local_time["minute"] // 30
    return messages[seed % len(messages)]


def draw_background(c, palette, theme, dim):
    c.fill("black")
    wall = "#08070A" if dim else palette["wall"]
    floor = "#171116" if dim else palette["floor"]
    c.rect(0, 6, c.width - 1, c.height - 6, fill=wall)
    c.rect(0, c.height - 5, c.width - 1, c.height - 1, fill=floor)
    c.line(0, c.height - 6, c.width - 1, c.height - 6, palette["floorline"])
    c.line(61, 7, 61, 16, palette["wallline"])
    c.line(128, 7, 128, 16, palette["wallline"])
    c.pixel(61, 18, palette["wallline"])
    c.pixel(128, 18, palette["wallline"])

    if theme == "ARCADE":
        for x in [3, 8, 13, 178, 183, 188]:
            c.pixel(x, 7, palette["accent"])
    elif theme == "CABIN":
        c.line(1, 12, 59, 12, palette["wallline"])
        c.line(130, 12, 190, 12, palette["wallline"])
    elif theme == "MODERN":
        c.line(2, 8, 58, 8, palette["wallline"])
        c.line(131, 8, 188, 8, palette["wallline"])
    elif theme == "NIGHT":
        c.pixel(6, 9, palette["soft"])
        c.pixel(43, 11, palette["soft"])

    if dim:
        c.line(0, 6, c.width - 1, 6, "#0A0A12")


def draw_bedroom(c, palette, theme, light_on, local_hour, month):
    # Window follows local time: daylight, twilight, or moonlit night.
    daylight = local_hour >= 7 and local_hour < 19
    twilight = local_hour == 6 or local_hour == 19
    sky = "#246F9E" if daylight else "#5A304F" if twilight else "#07101C"
    c.rect(17, 9, 34, 17, fill=sky, outline=palette["wallline"])
    c.line(25, 10, 25, 16, palette["wallline"])
    c.line(18, 13, 33, 13, palette["wallline"])
    if daylight:
        c.rect(29, 10, 31, 12, fill="#FFD35A")
        c.line(19, 15, 23, 15, "#D9F2FF")
        c.pixel(21, 14, "#D9F2FF")
    elif twilight:
        c.line(18, 15, 33, 15, palette["accent"])
        c.rect(22, 12, 24, 14, fill="#FFB347")
    else:
        c.pixel(29, 10, "#D9E6FF")
        c.pixel(30, 11, "#D9E6FF")
        c.pixel(20, 11, "#6477A8")
        c.pixel(32, 15, "#6477A8")
    if month == 10:
        c.pixel(19, 10, "#1A1328")
        c.pixel(20, 11, "#1A1328")
        c.pixel(21, 10, "#1A1328")
    elif month == 12 or month == 1231:
        c.pixel(19, 11, "#E8F4FF")
        c.pixel(23, 15, "#E8F4FF")
        c.pixel(28, 12, "#E8F4FF")
        c.pixel(33, 14, "#E8F4FF")
        c.line(18, 16, 33, 16, "#D9E6FF")

    # Bed, pillow, blanket and frame.
    c.rect(4, 21, 39, 28, fill=palette["bed"], outline=palette["furniturelight"])
    c.rect(6, 21, 13, 23, fill=palette["soft"])
    c.line(7, 21, 12, 21, "#FFF1D0")
    c.rect(14, 22, 37, 25, fill=palette["bedlight"])
    c.line(16, 24, 35, 24, palette["bed"])
    c.pixel(35, 22, palette["soft"])
    c.line(5, 28, 5, 30, palette["furniturelight"])
    c.line(38, 28, 38, 30, palette["furniturelight"])
    c.line(3, 18, 3, 28, palette["furniturelight"])

    # Bedside lamp.
    c.rect(42, 25, 49, 28, fill=palette["furniture"])
    c.line(46, 20, 46, 25, palette["furniturelight"])
    c.rect(43, 18, 49, 21, fill=palette["accent"] if light_on else palette["wallline"])
    if light_on:
        c.pixel(42, 19, palette["soft"])
        c.pixel(50, 19, palette["soft"])


def draw_living_room(c, palette, theme, screen_on, month, frame):
    # Rug and couch.
    c.rect(66, 29, 122, 31, fill=palette["wallline"])
    c.line(72, 30, 116, 30, palette["accent"])
    c.rect(70, 21, 100, 28, fill=palette["bed"], outline=palette["bedlight"])
    c.rect(73, 20, 83, 23, fill=palette["bedlight"])
    c.rect(87, 20, 97, 23, fill=palette["bedlight"])
    c.line(85, 21, 85, 27, palette["furniturelight"])
    c.line(72, 27, 99, 27, palette["furniturelight"])
    c.rect(68, 23, 72, 29, fill=palette["furniture"])
    c.rect(98, 23, 102, 29, fill=palette["furniture"])
    c.pixel(72, 29, palette["soft"])
    c.pixel(98, 29, palette["soft"])

    # Framed art above the couch.
    c.rect(69, 7, 94, 18, fill=palette["furniture"], outline=palette["furniturelight"])
    if theme == "MODERN":
        # Abstract geometric print — clean blocks, not a house portrait.
        c.rect(71, 9, 92, 16, fill="#0B141C")
        c.rect(72, 10, 80, 13, fill="#E8EEF2")
        c.rect(81, 10, 86, 13, fill=palette["accent"])
        c.rect(87, 10, 91, 13, fill="#2A3640")
        c.rect(72, 14, 77, 15, fill=palette["screen"])
        c.rect(78, 14, 91, 15, fill="#E8EEF2")
        c.pixel(74, 11, "#0B141C")
        c.pixel(89, 11, palette["soft"])
    elif theme == "ARCADE":
        # Retro high-score poster: neon grid + tiny spaceship + score ticks.
        c.rect(71, 9, 92, 16, fill="#12081F")
        c.line(72, 11, 91, 11, "#3A1A5C")
        c.line(72, 13, 91, 13, "#3A1A5C")
        c.line(72, 15, 91, 15, "#3A1A5C")
        c.line(76, 10, 76, 15, "#3A1A5C")
        c.line(82, 10, 82, 15, "#3A1A5C")
        c.line(88, 10, 88, 15, "#3A1A5C")
        c.pixel(74, 10, palette["accent"])
        c.pixel(80, 12, palette["screen"])
        c.pixel(86, 10, palette["soft"])
        c.pixel(90, 14, palette["plant"])
        # Tiny ship in the middle.
        c.line(80, 12, 84, 12, "#FFD35A")
        c.pixel(82, 11, "#FFD35A")
        c.pixel(81, 13, palette["accent"])
        c.pixel(83, 13, palette["accent"])
    else:
        # Miniature house portrait for the other themes.
        c.rect(71, 9, 92, 16, fill="#10233D")
        c.line(72, 16, 91, 16, palette["plant"])
        c.line(76, 12, 89, 12, palette["accent"])
        c.line(77, 11, 88, 11, palette["accent"])
        c.line(79, 10, 86, 10, palette["accent"])
        c.line(81, 9, 84, 9, palette["accent"])
        c.rect(77, 12, 88, 16, fill=palette["soft"])
        c.rect(81, 13, 84, 16, fill=palette["bed"])
        c.pixel(83, 15, palette["accent"])
        c.rect(78, 13, 79, 14, fill=palette["screen"])
        c.rect(86, 13, 87, 14, fill=palette["screen"])
        c.pixel(90, 10, palette["soft"])
    c.line(104, 14, 122, 14, palette["furniturelight"])
    c.rect(106, 11, 109, 13, fill=palette["bedlight"])
    c.rect(112, 10, 116, 13, fill=palette["plant"])

    if month == 12 or month == 1231:
        # Christmas tree replaces the plant for all of December.
        c.rect(116, 26, 123, 29, fill=palette["furniturelight"])
        c.line(119, 17, 119, 26, "#6B4423")
        c.line(119, 17, 115, 21, "#1FA34A")
        c.line(119, 17, 124, 21, "#1FA34A")
        c.line(119, 19, 113, 24, "#16843B")
        c.line(119, 19, 126, 24, "#16843B")
        c.line(114, 24, 125, 24, "#16843B")
        c.pixel(119, 16, "#FFD35A")
        c.pixel(116, 21, "#FF4F70")
        c.pixel(122, 20, "#55D6FF")
        c.pixel(119, 23, "#FFD35A" if frame % 2 == 0 else "#FF4F70")
    else:
        # Plant with pot and readable leaves.
        c.rect(116, 25, 123, 29, fill=palette["furniturelight"])
        c.line(119, 19, 119, 25, palette["plant"])
        c.line(119, 21, 115, 19, palette["plant"])
        c.line(120, 22, 124, 19, palette["plant"])
        c.pixel(116, 18, palette["plant"])
        c.pixel(124, 18, palette["plant"])

    if theme == "ARCADE":
        c.rect(125, 18, 132, 29, fill=palette["furniture"], outline=palette["accent"])
        c.rect(127, 20, 130, 23, fill=palette["screen"])
        c.pixel(128, 26, palette["accent"])
    elif theme == "CABIN":
        c.rect(125, 22, 132, 29, fill=palette["furniturelight"])
        c.rect(127, 24, 130, 28, fill=palette["accent"])


def draw_heart(c, x, y, color):
    c.pixel(x, y, color)
    c.pixel(x + 2, y, color)
    c.line(x, y + 1, x + 2, y + 1, color)
    c.pixel(x + 1, y + 2, color)


def draw_seasonal_decor(c, palette, season, frame):
    if season == 10:
        # Halloween: pumpkin, purple-orange garland and a corner cobweb.
        for x in range(66, 128, 8):
            c.pixel(x, 7, "#FF7A18" if (x // 8 + frame) % 2 == 0 else "#A855F7")
        c.fill_circle(113, 12, 2, "#F26A1B")
        c.pixel(113, 9, "#4FA34A")
        c.pixel(112, 12, "#17120F")
        c.pixel(114, 12, "#17120F")
        c.line(124, 8, 127, 11, "#9A8FA8")
        c.line(127, 8, 124, 11, "#9A8FA8")
        c.pixel(126, 10, "#E6DDF0")
    elif season == 12:
        # Holiday lights run across the apartment walls.
        colors = ["#FF4F70", "#55D6FF", "#FFD35A", "#55E06F"]
        for x in range(64, 176, 7):
            c.pixel(x, 7, colors[(x // 7 + frame) % len(colors)])
        c.rect(95, 24, 99, 27, fill="#C93642")
        c.pixel(97, 23, "#F2F0E8")
    elif season == 214:
        # Valentine's Day hearts and pink-red string lights.
        for x in range(66, 176, 8):
            c.pixel(x, 7, "#FF4F70" if (x // 8 + frame) % 2 == 0 else "#FF9EC4")
        draw_heart(c, 108, 10, "#FF4F70")
        draw_heart(c, 122, 16, "#FF9EC4")
        draw_heart(c, 48, 11, "#FF4F70")
    elif season == 704:
        # Fourth of July flag, patriotic lights and tiny fireworks.
        colors = ["#E33B3B", "#F2F0E8", "#3977D4"]
        for x in range(64, 176, 7):
            c.pixel(x, 7, colors[(x // 7 + frame) % len(colors)])
        c.rect(104, 9, 116, 14, fill="#F2F0E8")
        c.line(104, 9, 116, 9, "#E33B3B")
        c.line(104, 11, 116, 11, "#E33B3B")
        c.line(104, 13, 116, 13, "#E33B3B")
        c.rect(104, 9, 108, 11, fill="#3977D4")
        c.pixel(106, 10, "#F2F0E8")
        c.pixel(123, 10, "#FFD35A")
        c.pixel(121, 8, "#E33B3B")
        c.pixel(125, 8, "#3977D4")
        c.pixel(121, 12, "#3977D4")
        c.pixel(125, 12, "#E33B3B")
    elif season == 1231:
        # New Year's Eve keeps the Christmas tree and adds gold confetti/fireworks.
        for x in range(64, 176, 7):
            c.pixel(x, 7, "#FFD35A" if (x // 7 + frame) % 2 == 0 else "#D9E6FF")
        c.pixel(108, 9, "#FFD35A")
        c.pixel(106, 11, "#FF4F70")
        c.pixel(110, 11, "#55D6FF")
        c.pixel(108, 13, "#55E06F")
        c.pixel(126, 8, "#FF4F70")
        c.pixel(132, 12, "#FFD35A")
        c.pixel(142, 9, "#55D6FF")
    elif season == 101:
        # New Year's Day celebration.
        for x in range(66, 176, 8):
            c.pixel(x, 7, "#FFD35A" if (x // 8 + frame) % 2 == 0 else "#D9E6FF")
        c.pixel(106, 10, "#FF4F70")
        c.pixel(113, 12, "#55D6FF")
        c.pixel(121, 9, "#55E06F")
        c.pixel(129, 13, "#FFD35A")
    elif season == 401:
        # Easter: pastel eggs, spring bunting and a tiny bunny.
        colors = ["#FF9EC4", "#A9E4FF", "#FFE28A", "#B8F2B2"]
        for x in range(66, 176, 8):
            c.pixel(x, 7, colors[(x // 8 + frame) % len(colors)])
        c.fill_circle(106, 12, 1, "#FF9EC4")
        c.fill_circle(112, 12, 1, "#A9E4FF")
        c.fill_circle(118, 12, 1, "#FFE28A")
        c.rect(124, 11, 127, 14, fill="#E8F4FF")
        c.pixel(124, 9, "#E8F4FF")
        c.pixel(127, 9, "#E8F4FF")
        c.pixel(126, 12, "#33313A")
    elif season == 1124:
        # U.S. Thanksgiving: autumn garland, turkey and dinner plate.
        colors = ["#F26A1B", "#D9A441", "#9B4A2F"]
        for x in range(66, 176, 8):
            c.pixel(x, 7, colors[(x // 8 + frame) % len(colors)])
        c.pixel(108, 11, "#F26A1B")
        c.pixel(110, 10, "#D9A441")
        c.pixel(112, 11, "#9B4A2F")
        c.fill_circle(110, 13, 2, "#8B4A2B")
        c.pixel(113, 12, "#FFD35A")
        c.rect(163, 21, 170, 22, fill="#F2F0E8")
        c.pixel(166, 20, "#F26A1B")


def draw_kitchen_or_desk(c, palette, frame, activity, pcpower):
    active = activity == "PLAY" or activity == "WORK"
    if pcpower == "ON":
        active = True
    elif pcpower == "OFF":
        active = False
    # Open-legged desk keeps the work area visually light.
    c.rect(135, 23, 174, 25, fill=palette["furniturelight"])
    c.line(138, 26, 138, 29, palette["furniture"])
    c.line(171, 26, 171, 29, palette["furniture"])
    c.line(147, 22, 160, 22, palette["soft"])

    # Refrigerator and handles.
    c.rect(177, 10, 190, 29, fill=palette["furniture"], outline=palette["furniturelight"])
    c.line(178, 19, 189, 19, palette["furniturelight"])
    c.line(179, 16, 179, 18, palette["accent"])
    c.line(179, 21, 179, 24, palette["accent"])

    # One mug moves out of the resident's way while the PC is active.
    mug_x = 164 if active else 139
    c.rect(mug_x, 20, mug_x + 3, 23, fill=palette["soft"])
    c.pixel(mug_x + 4, 21, palette["soft"])

    # Recognizable desktop PC: monitor bezel, screen, stand, keyboard and tower.
    c.rect(146, 11, 163, 21, fill="#05080D", outline=palette["furniturelight"])
    screen = palette["screen"] if active else palette["wallline"]
    c.rect(148, 13, 161, 19, fill=screen)
    c.line(154, 21, 154, 22, palette["furniturelight"])
    c.line(151, 22, 158, 22, palette["furniturelight"])
    c.rect(165, 13, 173, 22, fill=palette["furniture"], outline=palette["furniturelight"])
    c.line(167, 15, 171, 15, palette["wallline"])
    c.fill_circle(169, 19, 1, palette["accent"] if active else palette["wallline"])
    if active and activity == "WORK":
        # Tiny spreadsheet: title bar, rows, columns and an active cell.
        c.line(148, 14, 161, 14, "#174C69")
        c.line(148, 16, 161, 16, "#39788C")
        c.line(148, 18, 161, 18, "#39788C")
        c.line(152, 14, 152, 19, "#39788C")
        c.line(157, 14, 157, 19, "#39788C")
        c.rect(153, 15, 156, 15, fill=palette["soft"])
    elif active and activity == "PLAY":
        # Tiny platform game with ground, player, collectible and moving enemy.
        c.rect(148, 13, 161, 19, fill="#10233D")
        c.line(148, 19, 161, 19, palette["plant"])
        c.line(150, 17, 154, 17, palette["bedlight"])
        c.pixel(151, 16, palette["soft"])
        c.pixel(159, 14, palette["accent"])
        c.pixel(157 + (frame % 2), 18, "#FF5B4D")
    elif active:
        # Calm desktop when the PC is manually switched on.
        c.rect(149, 14, 155, 18, fill="#173654")
        c.line(149, 15, 155, 15, palette["soft"])
        c.rect(157, 14, 160, 16, fill=palette["plant"])


def draw_head(c, x, y, skin, hair, facing):
    # Irregular hair, ears and a narrower jaw avoid a square character head.
    c.line(x + 3, y, x + 5, y, hair)
    c.line(x + 2, y + 1, x + 6, y + 1, hair)
    c.rect(x + 2, y + 2, x + 6, y + 3, fill=skin)
    c.line(x + 3, y + 4, x + 5, y + 4, skin)
    c.pixel(x + 1, y + 2, skin)
    c.pixel(x + 7, y + 2, skin)
    if facing == "FRONT":
        # Camera-facing: both eyes, no side fringe.
        c.pixel(x + 3, y + 2, "#17120F")
        c.pixel(x + 5, y + 2, "#17120F")
    else:
        c.pixel(x + 2 if facing == "LEFT" else x + 6, y + 2, hair)
        eye_x = x + 3 if facing == "LEFT" else x + 5
        c.pixel(eye_x, y + 2, "#17120F")
    c.pixel(x + 4, y + 3, "#8C4B38")


def draw_standing(c, x, y, pose, skin, hair, shirt, pants, facing):
    # Original 9-wide, 12-tall resident with tapered shoulders and separate legs.
    c.line(x + 1, y + 11, x + 7, y + 11, "#07080B")
    # Wave faces the camera; everything else keeps the walk/profile facing.
    head_facing = "FRONT" if pose == "WAVE" else facing
    draw_head(c, x, y, skin, hair, head_facing)
    c.line(x + 3, y + 5, x + 5, y + 5, skin)
    c.line(x + 2, y + 6, x + 6, y + 6, shirt)
    c.rect(x + 3, y + 7, x + 5, y + 9, fill=shirt)
    c.pixel(x + 2, y + 7, shirt)
    c.pixel(x + 6, y + 7, shirt)

    if pose == "IDLE1":
        # Both hands rest near the trouser pockets.
        c.line(x + 2, y + 7, x + 3, y + 9, skin)
        c.line(x + 6, y + 7, x + 5, y + 9, skin)
    elif pose == "IDLE2":
        # One relaxed arm and one hand resting at the hip.
        c.line(x + 2, y + 7, x + 1, y + 9, skin)
        c.line(x + 6, y + 7, x + 5, y + 8, skin)
    elif pose == "WAVE":
        c.line(x + 2, y + 7, x + 1, y + 9, skin)
        c.line(x + 6, y + 7, x + 8, y + 4, skin)
        c.pixel(x + 8, y + 3, skin)
    elif pose == "DANCE1":
        c.line(x + 2, y + 7, x, y + 5, skin)
        c.line(x + 6, y + 7, x + 8, y + 4, skin)
    elif pose == "DANCE2":
        c.line(x + 2, y + 7, x, y + 4, skin)
        c.line(x + 6, y + 7, x + 8, y + 6, skin)
    elif pose == "EAT":
        c.line(x + 6, y + 7, x + 9, y + 4, skin)
        c.rect(x + 9, y + 3, x + 10, y + 5, fill="#F1E7CE")
        c.pixel(x + 10, y + 2, "#D9F5F2")
    elif pose == "CLEAN":
        c.line(x + 2, y + 7, x + 1, y + 9, skin)
        c.line(x + 6, y + 7, x + 8, y + 8, skin)
        c.line(x + 8, y + 8, x + 10, y + 11, "#7CDDEA")
        c.pixel(x + 11, y + 11, "#B9F7FF")
    elif pose == "PET":
        c.line(x + 2, y + 7, x + 1, y + 10, skin)
        c.line(x + 6, y + 7, x + 7, y + 10, skin)
    elif pose == "WALK1":
        c.line(x + 2, y + 7, x, y + 9, skin)
        c.line(x + 6, y + 7, x + 8, y + 8, skin)
    elif pose == "WALK2":
        c.line(x + 2, y + 7, x, y + 8, skin)
        c.line(x + 6, y + 7, x + 8, y + 9, skin)
    else:
        c.line(x + 2, y + 7, x + 1, y + 9, skin)
        c.line(x + 6, y + 7, x + 7, y + 9, skin)

    c.line(x + 3, y + 9, x + 5, y + 9, pants)
    if pose == "WALK1" or pose == "DANCE1":
        c.line(x + 2, y + 10, x + 1, y + 11, pants)
        c.line(x + 6, y + 10, x + 7, y + 11, pants)
        c.pixel(x, y + 11, "#D8E4EA")
        c.pixel(x + 8, y + 11, "#D8E4EA")
    elif pose == "WALK2" or pose == "DANCE2":
        c.line(x + 2, y + 10, x + 4, y + 11, pants)
        c.line(x + 6, y + 10, x + 4, y + 11, pants)
        c.pixel(x + 3, y + 11, "#D8E4EA")
        c.pixel(x + 5, y + 11, "#D8E4EA")
    else:
        c.line(x + 2, y + 10, x + 2, y + 11, pants)
        c.line(x + 6, y + 10, x + 6, y + 11, pants)
        c.pixel(x + 1, y + 11, "#D8E4EA")
        c.pixel(x + 7, y + 11, "#D8E4EA")


def draw_sitting(c, x, y, skin, hair, shirt, pants, activity):
    draw_head(c, x, y, skin, hair, "RIGHT")
    c.line(x + 3, y + 5, x + 5, y + 5, skin)
    c.line(x + 2, y + 6, x + 6, y + 6, shirt)
    c.rect(x + 3, y + 7, x + 5, y + 9, fill=shirt)
    c.line(x + 2, y + 7, x + 1, y + 9, skin)
    if activity == "PLAY":
        c.line(x + 6, y + 7, x + 9, y + 8, skin)
        c.rect(x + 7, y + 8, x + 10, y + 9, fill="#30343B")
        c.pixel(x + 10, y + 8, "#FF4F70")
    elif activity == "WORK":
        c.line(x + 6, y + 7, x + 9, y + 8, skin)
        c.pixel(x + 10, y + 7, "#88F4FF")
    else:
        c.line(x + 6, y + 7, x + 9, y + 7, skin)
        c.rect(x + 8, y + 4, x + 12, y + 8, fill="#F0D45D", outline="#453814")
        c.line(x + 10, y + 5, x + 10, y + 7, "#8A6A24")
    c.line(x + 3, y + 9, x + 8, y + 9, pants)
    c.line(x + 8, y + 9, x + 8, y + 11, pants)
    c.pixel(x + 9, y + 11, "#D8E4EA")


def draw_sleeping(c, x, y, skin, hair, shirt):
    c.rect(x, y, x + 5, y + 5, fill="#090B0F")
    c.rect(x + 1, y + 1, x + 4, y + 4, fill=skin)
    c.line(x + 1, y + 1, x + 4, y + 1, hair)
    c.pixel(x + 1, y + 2, hair)
    c.line(x + 2, y + 3, x + 3, y + 3, "#251C1A")
    c.rect(x + 5, y + 2, x + 11, y + 5, fill=shirt, outline="#090B0F")
    c.line(x + 12, y + 4, x + 15, y + 4, "#28527A")
    c.pixel(x + 15, y + 5, "#D8E4EA")


def draw_sleep_blanket(c, palette):
    # Drawn after the resident so only the head and a hint of shoulder remain visible.
    c.rect(15, 21, 37, 25, fill=palette["bedlight"])
    c.line(17, 21, 35, 21, palette["soft"])
    c.pixel(15, 22, palette["soft"])
    c.line(19, 24, 35, 24, palette["bed"])
    c.pixel(36, 23, palette["bed"])


def draw_character(c, x, y, pose, skin, hair, shirt, pants, facing):
    if pose == "SLEEP":
        draw_sleeping(c, x, y, skin, hair, shirt)
    elif pose == "SIT" or pose == "WORK" or pose == "PLAY":
        draw_sitting(c, x, y, skin, hair, shirt, pants, pose)
    else:
        draw_standing(c, x, y, pose, skin, hair, shirt, pants, facing)


def draw_pet(c, x, y, pet_type, pose, palette):
    fur = "#C88A4D" if pet_type == "DOG" else "#A6A8B0"
    shade = "#714A2A" if pet_type == "DOG" else "#565A66"
    if pose == "SLEEP":
        c.rect(x + 1, y + 2, x + 6, y + 4, fill=fur)
        c.pixel(x, y + 3, shade)
        c.pixel(x + 6, y + 1, fur)
        c.pixel(x + 7, y + 2, fur)
        return

    c.rect(x + 2, y + 1, x + 5, y + 3, fill=fur)
    c.rect(x, y, x + 2, y + 2, fill=fur)
    c.pixel(x + 1, y + 1, "#17120F")
    if pet_type == "CAT":
        c.pixel(x, y - 1, fur)
        c.pixel(x + 2, y - 1, fur)
        c.line(x + 6, y + 2, x + 7, y, shade)
    else:
        c.pixel(x - 1, y, shade)
        c.pixel(x + 2, y, shade)
        c.line(x + 6, y + 1, x + 7, y + 2, shade)
    c.pixel(x + 2, y + 4, shade)
    c.pixel(x + 5, y + 4, shade)
    if pose == "HAPPY":
        c.pixel(x + 1, y + 2, palette["accent"])


def get_character_position(activity, frame):
    if activity == "SLEEP":
        return [10, 18, "SLEEP", "RIGHT"]
    if activity == "WAKE":
        return [51, 15, "STAND", "LEFT"]
    if activity == "WALK":
        step = frame % 16
        if step < 8:
            return [52 + step * 8, 20, "WALK1" if step % 2 == 0 else "WALK2", "RIGHT"]
        return [108 - (step - 8) * 8, 20, "WALK1" if step % 2 == 0 else "WALK2", "LEFT"]
    if activity == "SIT":
        return [80, 15, "SIT", "RIGHT"]
    if activity == "EAT":
        return [128, 15, "EAT", "RIGHT"]
    if activity == "WORK":
        return [133, 15, "WORK", "RIGHT"]
    if activity == "PLAY":
        return [133, 15, "PLAY", "RIGHT"]
    if activity == "CLEAN":
        return [104, 15, "CLEAN", "RIGHT"]
    if activity == "WATER":
        return [104, 15, "CLEAN", "RIGHT"]
    if activity == "PET":
        return [52, 20, "PET", "RIGHT"]
    if activity == "PETFEED":
        return [52, 20, "PET", "RIGHT"]
    if activity == "PETPLAY":
        return [52, 20, "PET", "RIGHT"]
    if activity == "PETNAP":
        return [80, 15, "SIT", "RIGHT"]
    if activity == "WAVE":
        return [52, 20, "WAVE", "FRONT"]
    if activity == "DANCE":
        pose = "DANCE1" if frame % 2 == 0 else "DANCE2"
        return [62, 20, pose, "RIGHT"]
    if frame % 4 < 2:
        return [62, 15, "IDLE1", "RIGHT"]
    return [61, 15, "IDLE2", "LEFT"]


def draw_activity_details(c, activity, frame, palette):
    blink = frame % 2 == 0
    if activity == "SLEEP":
        c.text("Z", 27, 15 if blink else 16, font="3x4", color=palette["soft"])
    elif activity == "WAKE":
        c.pixel(48, 15, palette["accent"])
        c.pixel(50, 13 if blink else 14, palette["soft"])
    elif activity == "EAT":
        c.pixel(141, 18 if blink else 19, palette["soft"])
        c.pixel(143, 17 if blink else 18, palette["soft"])
    elif activity == "CLEAN" or activity == "WATER":
        c.pixel(116, 18 if blink else 20, palette["screen"])
        c.pixel(122, 19 if blink else 21, palette["screen"])
        c.pixel(125, 17, palette["soft"])
    elif activity == "PET":
        c.pixel(103, 20, palette["accent"])
        if blink:
            c.pixel(105, 18, palette["accent"])
    elif activity == "PETFEED":
        c.rect(72, 29, 77, 30, fill=palette["bed"])
        c.pixel(74, 28, palette["accent"])
    elif activity == "PETPLAY":
        c.fill_circle(73 + (frame % 2), 28, 1, palette["accent"])


def home(c, ctx):
    charactername = safe_name(safe_input(ctx, "charactername", "PIXEL"), c)
    personality = str(safe_input(ctx, "personality", "COZY")).upper()
    shirtcolor = safe_input(ctx, "shirtcolor", "#00DC46")
    haircolor = safe_input(ctx, "haircolor", "#8B5A2B")
    skintone = str(safe_input(ctx, "skintone", "MEDIUM")).upper()
    roomtheme = str(safe_input(ctx, "roomtheme", "COZY")).upper()
    petenabled = normalize_checkbox(safe_input(ctx, "petenabled", "true"))
    pettype = str(safe_input(ctx, "pettype", "CAT")).upper()
    showclock = normalize_checkbox(safe_input(ctx, "showclock", "true"))
    timezone = str(safe_input(ctx, "timezone", "UTC-05")).upper()
    lights = str(safe_input(ctx, "lights", "AUTO")).upper()
    pcpower = str(safe_input(ctx, "pcpower", "AUTO")).upper()
    message = safe_message(safe_input(ctx, "message", ""), c)
    schedule = str(safe_input(ctx, "schedule", "NORMAL")).upper()
    previewmode = str(safe_input(ctx, "previewmode", "AUTO ROUTINE")).upper()
    auto_routine = previewmode == "AUTO" or previewmode == "AUTO ROUTINE"

    palette = get_palette(roomtheme)
    skin = SKIN_TONES.get(skintone, SKIN_TONES["MEDIUM"])
    local_time = get_local_time(ctx, timezone)
    season_month = resolve_season(local_time)
    activity = choose_activity(ctx, local_time, personality, schedule, previewmode, charactername)
    frame = (ctx.now.unix // 15) % 16
    schedule_hour = adjusted_hour(local_time["hour"], schedule)
    dim = activity == "SLEEP" or schedule_hour < 6 or schedule_hour >= 22
    if lights == "ON":
        dim = False
    elif lights == "OFF":
        dim = True
    light_on = not dim or activity == "WAKE" or activity == "SIT"
    if lights == "OFF":
        light_on = False
    elif lights == "ON":
        light_on = True
    screen_on = activity == "PLAY" or activity == "WORK"

    draw_background(c, palette, roomtheme, dim)
    draw_bedroom(c, palette, roomtheme, light_on, local_time["hour"], season_month)
    draw_living_room(c, palette, roomtheme, screen_on, season_month, frame)
    draw_kitchen_or_desk(c, palette, frame, activity, pcpower)
    draw_seasonal_decor(c, palette, season_month, frame)
    draw_activity_details(c, activity, frame, palette)

    position = get_character_position(activity, frame)
    draw_character(
        c,
        position[0],
        position[1],
        position[2],
        skin,
        haircolor,
        shirtcolor,
        palette["pants"],
        position[3],
    )
    if activity == "SLEEP":
        draw_sleep_blanket(c, palette)

    if petenabled:
        pet_pose = "HAPPY" if activity in ["PET", "PETFEED", "PETPLAY"] else "AWAKE"
        pet_x = position[0] + 11
        if auto_routine:
            pet_selector = (local_time["hour"] + local_time["minute"] // 10) % 3
            pet_x = [52, 105, 126][pet_selector]
            if pet_selector == 2:
                pet_pose = "SLEEP"
        if activity == "SLEEP":
            pet_x = 42
            pet_pose = "SLEEP"
        elif activity == "PET" or activity == "PETFEED" or activity == "PETPLAY":
            pet_x = 64
            pet_pose = "HAPPY"
        elif activity == "PETNAP":
            pet_x = 105
            pet_pose = "SLEEP"
        elif activity == "EAT" or activity == "WORK" or activity == "PLAY":
            if not auto_routine:
                pet_x = 118
        elif activity == "CLEAN" or activity == "WATER":
            if not auto_routine:
                pet_x = 97
        if pet_x > 181:
            pet_x = position[0] - 10
        draw_pet(c, pet_x, 26, pettype, pet_pose, palette)

    if showclock:
        hour24 = local_time["hour"]
        hour12 = hour24 % 12
        if hour12 == 0:
            hour12 = 12
        period = "AM" if hour24 < 12 else "PM"
        clock = fmt.pad(local_time["month"]) + "-" + fmt.pad(local_time["day"])
        clock += " " + str(hour12) + ":" + fmt.pad(local_time["minute"]) + " " + period
        c.text(clock, c.width - 2, 0, font="4x5", color=palette["soft"], align="right")

    display_message = get_resident_message(activity, personality, frame, auto_routine)
    if auto_routine and local_time["minute"] % 30 < 5:
        display_message = get_uplifting_message(local_time)
    if season_month == 101:
        display_message = "HAPPY NEW YEAR"
    elif season_month == 1231:
        display_message = "NEW YEARS EVE"
    if message != "":
        display_message = message
    c.text(display_message, 2, 0, font="4x5", color=palette["accent"])

