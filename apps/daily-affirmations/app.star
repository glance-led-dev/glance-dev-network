# ==================================================
# DAILY AFFIRMATIONS
# DAXintheLAB
# ==================================================


# --------------------------------------------------
# CATEGORIES
# --------------------------------------------------

CATEGORIES = [
    "CONFIDENCE",
    "DISCIPLINE",
    "GROWTH",
    "PEACE",
    "CREATIVITY",
    "PURPOSE",
    "MONEY",
    "RESILIENCE",
]


CATEGORY_COLORS = [
    "cyan",       # CONFIDENCE
    "red",        # DISCIPLINE
    "green",      # GROWTH
    "blue",       # PEACE
    "magenta",    # CREATIVITY
    "yellow",     # PURPOSE
    "green",      # MONEY
    "red",        # RESILIENCE
]


# --------------------------------------------------
# AFFIRMATION LINE 1
#
# 8 options for each category.
# --------------------------------------------------

LINE_1 = [

    # CONFIDENCE
    [
        "TRUST YOURSELF",
        "BET ON YOURSELF",
        "OWN YOUR MOMENT",
        "STAND TALL",
        "SPEAK WITH POWER",
        "BACK YOURSELF",
        "YOU ARE CAPABLE",
        "BELIEVE BIG",
    ],

    # DISCIPLINE
    [
        "KEEP SHOWING UP",
        "STAY LOCKED IN",
        "DO THE WORK",
        "KEEP YOUR PROMISE",
        "STAY CONSISTENT",
        "FINISH STRONG",
        "CHOOSE DISCIPLINE",
        "MOVE WITH INTENT",
    ],

    # GROWTH
    [
        "KEEP GROWING",
        "KEEP EVOLVING",
        "LEARN AND BUILD",
        "PROGRESS DAILY",
        "LEVEL UP",
        "EMBRACE CHANGE",
        "KEEP EXPANDING",
        "BECOME MORE",
    ],

    # PEACE
    [
        "BREATHE DEEP",
        "CHOOSE CALM",
        "PROTECT YOUR PEACE",
        "MOVE WITH EASE",
        "BE HERE NOW",
        "SLOW IT DOWN",
        "RELEASE THE NOISE",
        "GIVE YOURSELF GRACE",
    ],

    # CREATIVITY
    [
        "TRUST YOUR IDEAS",
        "KEEP CREATING",
        "MAKE IT YOUR WAY",
        "FOLLOW THE VISION",
        "CREATE FREELY",
        "TRY SOMETHING NEW",
        "MAKE YOUR MARK",
        "BUILD YOUR VISION",
    ],

    # PURPOSE
    [
        "MOVE WITH PURPOSE",
        "FOLLOW YOUR PATH",
        "LIVE WITH INTENT",
        "MAKE TODAY COUNT",
        "TRUST YOUR PATH",
        "KEEP MOVING FORWARD",
        "CHOOSE YOUR DIRECTION",
        "HONOR YOUR VISION",
    ],

    # MONEY
    [
        "BUILD VALUE",
        "THINK LONG TERM",
        "CREATE MORE",
        "MOVE SMART",
        "BUILD YOUR FUTURE",
        "MAKE MONEY WORK",
        "THINK ABUNDANCE",
        "BUILD WITH PURPOSE",
    ],

    # RESILIENCE
    [
        "KEEP GOING",
        "GET BACK UP",
        "STAY STRONG",
        "KEEP PUSHING",
        "RISE AGAIN",
        "HOLD YOUR GROUND",
        "FACE IT HEAD ON",
        "KEEP THE FAITH",
    ],
]


# --------------------------------------------------
# AFFIRMATION LINE 2
#
# These are mixed with LINE_1 to create unique
# daily combinations.
# --------------------------------------------------

LINE_2 = [

    # CONFIDENCE
    [
        "YOU ARE READY",
        "YOU BELONG HERE",
        "MOVE BOLDLY",
        "YOUR VOICE MATTERS",
        "TAKE UP SPACE",
        "TRUST YOUR POWER",
        "SHOW UP FULLY",
        "YOU HAVE IT IN YOU",
    ],

    # DISCIPLINE
    [
        "THE WORK WILL SHOW",
        "SMALL STEPS ADD UP",
        "CONSISTENCY WINS",
        "DO IT ANYWAY",
        "YOUR HABITS MATTER",
        "STAY THE COURSE",
        "ACTION BUILDS YOU",
        "KEEP YOUR WORD",
    ],

    # GROWTH
    [
        "YOUR FUTURE AWAITS",
        "PROGRESS IS PROGRESS",
        "YOU GET BETTER",
        "TRUST THE PROCESS",
        "CHANGE BUILDS YOU",
        "KEEP LEARNING",
        "YOUR TIME IS COMING",
        "BECOME YOUR BEST",
    ],

    # PEACE
    [
        "YOU HAVE TIME",
        "LET IT BE EASY",
        "REST IS PRODUCTIVE",
        "LET GO A LITTLE",
        "YOU ARE SAFE HERE",
        "PEACE IS POWER",
        "BE KIND TO YOURSELF",
        "THIS MOMENT IS ENOUGH",
    ],

    # CREATIVITY
    [
        "YOUR VISION MATTERS",
        "YOUR IDEAS HAVE VALUE",
        "MAKE SOMETHING REAL",
        "THERE ARE NO RULES",
        "EXPRESS YOURSELF",
        "LET YOURSELF PLAY",
        "CREATE THEN REFINE",
        "MAKE IT YOUR OWN",
    ],

    # PURPOSE
    [
        "YOUR PATH IS YOURS",
        "YOU KNOW THE WAY",
        "KEEP YOUR VISION",
        "MAKE IT MEANINGFUL",
        "BUILD WHAT MATTERS",
        "YOUR LIFE HAS PURPOSE",
        "CHOOSE WHAT MATTERS",
        "THE NEXT STEP COUNTS",
    ],

    # MONEY
    [
        "BUILD REAL WEALTH",
        "VALUE CREATES VALUE",
        "PLAY THE LONG GAME",
        "CREATE OPPORTUNITY",
        "OWN MORE OF YOUR TIME",
        "LEARN THEN EARN",
        "BUILD YOUR FREEDOM",
        "LET VALUE LEAD",
    ],

    # RESILIENCE
    [
        "YOU CAN HANDLE IT",
        "THIS WILL PASS",
        "YOU HAVE MADE IT",
        "PRESSURE BUILDS POWER",
        "YOU ARE STILL HERE",
        "HARD DAYS END",
        "STRENGTH IS GROWING",
        "YOU ARE NOT DONE",
    ],
]


# --------------------------------------------------
# CALENDAR
# --------------------------------------------------

DAYS_BEFORE_MONTH = [
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
]


def get_day_of_year(month, day, year):
    total = DAYS_BEFORE_MONTH[month - 1] + day

    # Leap year adjustment
    if month > 2:
        if year % 400 == 0 or (
            year % 4 == 0 and
            year % 100 != 0
        ):
            total = total + 1

    return total


# --------------------------------------------------
# DAILY AFFIRMATION SELECTION
#
# Category rotates every day.
#
# Each category has 8 first lines × 8 second lines,
# giving 64 possible combinations.
#
# Since each category only appears ~46 times per
# year, there are no repeats during a normal year.
# --------------------------------------------------

def get_daily_affirmation(day_of_year):

    day_index = day_of_year - 1

    category_index = day_index % 8

    # Number of times we've reached this category
    occurrence = day_index // 8

    first_index = occurrence % 8

    second_index = (
        (occurrence // 8) +
        (first_index * 3) +
        category_index
    ) % 8

    category = CATEGORIES[category_index]
    accent = CATEGORY_COLORS[category_index]

    line1 = LINE_1[category_index][first_index]
    line2 = LINE_2[category_index][second_index]

    return [
        category,
        accent,
        line1,
        line2,
    ]


# ==================================================
# LOGO
# ==================================================

def draw_big_star(c, accent):

    c.sprite(
        [
            "..........W..........",
            "..........W..........",
            "..........W..........",
            ".........WWW.........",
            ".........WAW.........",
            "........WAAAW........",
            ".......WAAAAAW.......",
            "......WAAAAAAAW......",
            ".....WAAAAAAAAAW.....",
            "....WAAAAAAAAAAAW....",
            "WWWAAAAAAAAAAAAAAAWWW",
            "....WAAAAAAAAAAAW....",
            ".....WAAAAAAAAAW.....",
            "......WAAAAAAAW......",
            ".......WAAAAAW.......",
            "........WAAAW........",
            ".........WAW.........",
            ".........WWW.........",
            "..........W..........",
            "..........W..........",
            "..........W..........",
        ],
        4,
        5,
        legend={
            "W": "white",
            "A": accent,
        }
    )


# --------------------------------------------------
# LOGO SPARKLES
# --------------------------------------------------

def draw_sparkles(c, accent):

    # White sparkle - upper left
    c.sprite(
        [
            ".W.",
            "WWW",
            ".W.",
        ],
        1,
        3,
        legend={
            "W": "white",
        }
    )

    # Accent sparkle - upper right of logo
    c.sprite(
        [
            ".A.",
            "AAA",
            ".A.",
        ],
        27,
        5,
        legend={
            "A": accent,
        }
    )

    # Accent sparkle - lower right
    c.sprite(
        [
            ".A.",
            "AAA",
            ".A.",
        ],
        27,
        25,
        legend={
            "A": accent,
        }
    )


# ==================================================
# HEADER
# ==================================================

def draw_header_mark(c, accent):

    # Accent sparkle
    c.sprite(
        [
            ".A.",
            "AAA",
            ".A.",
        ],
        31,
        1,
        legend={
            "A": accent,
        }
    )

    # Small white horizontal rail
    c.sprite(
        [
            "WWWWW",
        ],
        35,
        2,
        legend={
            "W": "white",
        }
    )


# ==================================================
# TEXT POSITION HELPERS
# ==================================================

def right_center_x_5x7(text):

    # Roughly 6 pixels per character
    width = len(text) * 6

    # Right content area:
    # x = 31 through 127
    x = 31 + ((97 - width) // 2)

    if x < 31:
        x = 31

    return x


def right_center_x_4x5(text):

    # Roughly 5 pixels per character
    width = len(text) * 5

    x = 31 + ((97 - width) // 2)

    if x < 31:
        x = 31

    return x


# ==================================================
# AFFIRMATION TEXT
# ==================================================

def draw_affirmation_line(c, text, y):

    # Short lines get the larger font
    if len(text) <= 16:

        c.text(
            text,
            right_center_x_5x7(text),
            y,
            font="5x7",
            color="white"
        )

    # Longer lines automatically shrink
    else:

        c.text(
            text,
            right_center_x_4x5(text),
            y + 1,
            font="4x5",
            color="white"
        )


# ==================================================
# MAIN
# ==================================================

def main(c, ctx):

    c.fill("black")

    # ----------------------------------------------
    # GET TODAY'S DATE
    # ----------------------------------------------

    day_of_year = get_day_of_year(
        ctx.now.month,
        ctx.now.day,
        ctx.now.year
    )

    # ----------------------------------------------
    # GET TODAY'S AFFIRMATION
    # ----------------------------------------------

    daily = get_daily_affirmation(
        day_of_year
    )

    category = daily[0]
    accent = daily[1]
    line1 = daily[2]
    line2 = daily[3]

    # ----------------------------------------------
    # LEFT LOGO
    # ----------------------------------------------

    draw_big_star(
        c,
        accent
    )

    draw_sparkles(
        c,
        accent
    )

    # ----------------------------------------------
    # HEADER
    # ----------------------------------------------

    draw_header_mark(
        c,
        accent
    )

    c.text(
        "DAILY AFFIRMATION",
        42,
        0,
        font="4x5",
        color="white"
    )

    # ----------------------------------------------
    # CATEGORY
    # ----------------------------------------------

    c.text(
        category,
        right_center_x_5x7(category),
        8,
        font="5x7",
        color=accent
    )

    # ----------------------------------------------
    # AFFIRMATION
    # ----------------------------------------------

    draw_affirmation_line(
        c,
        line1,
        17
    )

    draw_affirmation_line(
        c,
        line2,
        25
    )