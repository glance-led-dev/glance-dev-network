# MINECRAFT UPDATES
# 128x32
#
# SHOWS:
# - LATEST BEDROCK RELEASE / HOTFIX
# - LATEST JAVA SNAPSHOT / PRE-RELEASE
# - LATEST BEDROCK BETA / PREVIEW
#
# THE MAIN TEXT SUMMARIZES WHAT CHANGED.
# THE VERSION NUMBER IS SECONDARY.
#
# IMPORTANT:
# THIS VERSION DOES NOT USE:
# - WHILE LOOPS
# - DIRECT ITERATION OVER STRINGS


BASE = "https://feedback.minecraft.net/api/v2/help_center/en-us"

SECTION_RELEASE = "360001186971"
SECTION_JAVA = "360002267532"
SECTION_PREVIEW = "360001185332"


# ---------------------------------------------------------
# COLORS
# ---------------------------------------------------------

BG = "#050805"
PANEL = "#0B0F0B"

WHITE = "white"
GRAY = "#7C857C"

GREEN = "#57C84D"
GREEN_LIGHT = "#6FD15F"
GREEN_DARK = "#245C22"
GREEN_EDGE = "#183E17"

AMBER = "#E8B04A"
AMBER_DARK = "#4A3412"

DIRT = "#6B4423"
DIRT_DARK = "#4D2F17"

BLACK = "black"


# ---------------------------------------------------------
# PIXEL ART
# ---------------------------------------------------------

GRASS_BLOCK = [
    "GGGGGGGG",
    "GgGGgGGG",
    "GGGGGGgG",
    "gGGgGGGG",
    "DdDdDdDd",
    "dDDdDDdD",
    "DDdDdDDd",
    "dDDDDdDD",
]


# ---------------------------------------------------------
# DEMO CONTENT
# ---------------------------------------------------------

DEMO_RELEASE = {
    "title": "MINECRAFT BEDROCK EDITION 26.45 HOTFIX",
    "line1": "VIBRANT VISUALS",
    "line2": "INPUT + ITEM FIXES",
}

DEMO_JAVA = {
    "title": "MINECRAFT JAVA EDITION 26.3 PRE-RELEASE 3",
    "line1": "BUG FIXES",
    "line2": "TRADING + UI",
}

DEMO_PREVIEW = {
    "title": "MINECRAFT BETA PREVIEW 26.60.22/23",
    "line1": "STRAW BED FIXES",
    "line2": "TRAPDOOR CHANGES",
}


# ---------------------------------------------------------
# HTTP
# ---------------------------------------------------------

def _http_json(url, params):
    resp = http.get(
        url,
        params = params,
        ttl_seconds = 3600,
    )

    if resp["status_code"] != 200:
        return None

    return resp["json"]


def _fetch_latest(section_id):
    data = _http_json(
        BASE + "/sections/" + section_id + "/articles.json",
        {
            "per_page": "1",
            "sort_by": "created_at",
            "sort_order": "desc",
        },
    )

    if data == None:
        return {
            "state": "error",
        }

    articles = data.get("articles", [])

    if len(articles) == 0:
        return {
            "state": "empty",
        }

    article = articles[0]

    article_id = article.get("id", None)

    if article_id == None:
        return {
            "state": "empty",
        }

    detail = _http_json(
        BASE + "/articles/" + str(article_id) + ".json",
        {},
    )

    if detail == None:
        return {
            "state": "error",
        }

    full_article = detail.get("article", {})

    title = str(
        full_article.get(
            "title",
            "",
        )
    ).upper()

    body = str(
        full_article.get(
            "body",
            "",
        )
    ).upper()

    if title == "":
        return {
            "state": "empty",
        }

    summary = _build_summary(
        title,
        body,
    )

    return {
        "state": "live",
        "title": title,
        "line1": summary[0],
        "line2": summary[1],
    }


# ---------------------------------------------------------
# STRING HELPERS
# ---------------------------------------------------------

def _has(text, phrase):
    return text.find(phrase) >= 0


def _extract_version(title):
    s = title.upper()

    out = ""
    started = False

    for i in range(len(s)):
        ch = s[i]

        is_number = ch >= "0" and ch <= "9"

        if is_number:
            out = out + ch
            started = True

        elif started and ch == ".":
            out = out + ch

        elif started and ch == "/":
            out = out + ch

        elif started:
            break

    if out == "":
        return "UPDATE"

    return out.upper()


def _clip_to_width(c, text, font, maxw):
    s = text.upper()

    if c.text_width(s, font) <= maxw:
        return s

    out = ""

    for i in range(len(s)):
        ch = s[i]

        candidate = out + ch

        if c.text_width(candidate, font) > maxw:
            break

        out = candidate

    return out.upper()


# ---------------------------------------------------------
# SUMMARY ENGINE
# ---------------------------------------------------------

def _add_summary(result, text):
    if len(result) >= 2:
        return

    for existing in result:
        if existing == text:
            return

    result.append(text.upper())


def _build_summary(title, body):
    result = []

    text = title + " " + body


    # -----------------------------------------------------
    # LARGE / RECOGNIZABLE FEATURES
    # -----------------------------------------------------

    if _has(text, "VIBRANT VISUAL"):
        _add_summary(
            result,
            "VIBRANT VISUALS",
        )

    if _has(text, "HAPPY GHAST"):
        _add_summary(
            result,
            "HAPPY GHAST",
        )

    if _has(text, "COPPER GOLEM"):
        _add_summary(
            result,
            "COPPER GOLEMS",
        )

    if _has(text, "COPPER CHEST"):
        _add_summary(
            result,
            "COPPER CHESTS",
        )

    if _has(text, "SHELF"):
        _add_summary(
            result,
            "SHELF CHANGES",
        )

    if _has(text, "STRAW BED"):
        _add_summary(
            result,
            "STRAW BED FIXES",
        )

    if _has(text, "DRIED GHAST"):
        _add_summary(
            result,
            "DRIED GHAST",
        )

    if _has(text, "HARNESS"):
        _add_summary(
            result,
            "HARNESS CHANGES",
        )

    if _has(text, "LOCATOR BAR"):
        _add_summary(
            result,
            "LOCATOR BAR",
        )

    if _has(text, "PLAYER LOCATOR"):
        _add_summary(
            result,
            "PLAYER LOCATOR",
        )


    # -----------------------------------------------------
    # BLOCK / REDSTONE CHANGES
    # -----------------------------------------------------

    if _has(text, "TRAPDOOR"):
        _add_summary(
            result,
            "TRAPDOOR CHANGES",
        )

    if _has(text, "NOTE BLOCK"):
        _add_summary(
            result,
            "NOTE BLOCK FIXES",
        )

    if _has(text, "REDSTONE"):
        _add_summary(
            result,
            "REDSTONE CHANGES",
        )

    if _has(text, "PISTON"):
        _add_summary(
            result,
            "PISTON FIXES",
        )

    if _has(text, "MINECART"):
        _add_summary(
            result,
            "MINECART CHANGES",
        )


    # -----------------------------------------------------
    # MOBS / GAMEPLAY
    # -----------------------------------------------------

    if _has(text, "VILLAGER") or _has(text, "TRADING"):
        _add_summary(
            result,
            "TRADING CHANGES",
        )

    if _has(text, "HORSE"):
        _add_summary(
            result,
            "HORSE CHANGES",
        )

    if _has(text, "CAMEL"):
        _add_summary(
            result,
            "CAMEL CHANGES",
        )

    if _has(text, "WOLF"):
        _add_summary(
            result,
            "WOLF CHANGES",
        )

    if _has(text, "BOAT"):
        _add_summary(
            result,
            "BOAT CHANGES",
        )

    if _has(text, "BOW"):
        _add_summary(
            result,
            "BOW FIXES",
        )

    if _has(text, "PROJECTILE"):
        _add_summary(
            result,
            "PROJECTILE FIXES",
        )


    # -----------------------------------------------------
    # UI / TECHNICAL
    # -----------------------------------------------------

    if _has(text, "FULLSCREEN"):
        _add_summary(
            result,
            "FULLSCREEN FIX",
        )

    if _has(text, "CREATIVE INVENTORY"):
        _add_summary(
            result,
            "CREATIVE INV FIX",
        )

    if _has(text, "REALMS"):
        _add_summary(
            result,
            "REALMS FIXES",
        )

    if _has(text, "ANDROID"):
        _add_summary(
            result,
            "ANDROID FIXES",
        )

    if _has(text, "ADD-ON") or _has(text, "ADDON"):
        _add_summary(
            result,
            "ADD-ON FIXES",
        )

    if _has(text, "USER INTERFACE"):
        _add_summary(
            result,
            "UI FIXES",
        )

    if _has(text, "TOUCH CONTROL"):
        _add_summary(
            result,
            "TOUCH FIXES",
        )


    # -----------------------------------------------------
    # PERFORMANCE
    # -----------------------------------------------------

    if _has(text, "CRASH"):
        _add_summary(
            result,
            "CRASH FIXES",
        )

    if _has(text, "PERFORMANCE"):
        _add_summary(
            result,
            "PERFORMANCE",
        )

    if _has(text, "STABILITY"):
        _add_summary(
            result,
            "STABILITY FIXES",
        )


    # -----------------------------------------------------
    # FALLBACKS
    # -----------------------------------------------------

    if len(result) == 0:
        if _has(title, "HOTFIX"):
            _add_summary(
                result,
                "BUG FIXES",
            )

            _add_summary(
                result,
                "STABILITY FIXES",
            )

        elif _has(title, "PRE-RELEASE"):
            _add_summary(
                result,
                "JAVA CHANGES",
            )

            _add_summary(
                result,
                "BUG FIXES",
            )

        elif _has(title, "SNAPSHOT"):
            _add_summary(
                result,
                "JAVA CHANGES",
            )

            _add_summary(
                result,
                "NEW FEATURES",
            )

        elif _has(title, "PREVIEW"):
            _add_summary(
                result,
                "TEST FEATURES",
            )

            _add_summary(
                result,
                "GAMEPLAY FIXES",
            )

        elif _has(title, "BETA"):
            _add_summary(
                result,
                "TEST FEATURES",
            )

            _add_summary(
                result,
                "GAMEPLAY FIXES",
            )

        else:
            _add_summary(
                result,
                "GAMEPLAY CHANGES",
            )

            _add_summary(
                result,
                "BUG FIXES",
            )


    if len(result) == 1:
        if _has(title, "HOTFIX"):
            _add_summary(
                result,
                "BUG FIXES",
            )

        elif _has(title, "PREVIEW") or _has(title, "BETA"):
            _add_summary(
                result,
                "PREVIEW FIXES",
            )

        elif _has(title, "SNAPSHOT") or _has(title, "PRE-RELEASE"):
            _add_summary(
                result,
                "JAVA FIXES",
            )

        else:
            _add_summary(
                result,
                "MORE CHANGES",
            )


    return [
        result[0].upper(),
        result[1].upper(),
    ]


# ---------------------------------------------------------
# LABELS
# ---------------------------------------------------------

def _header_label(kind, title):
    version = _extract_version(title)

    if kind == "release":
        return (
            "BEDROCK " +
            version
        ).upper()

    if kind == "java":
        return (
            "JAVA " +
            version
        ).upper()

    return (
        "PREVIEW " +
        version
    ).upper()


def _badge_text(kind, demo):
    if demo:
        return "DEMO"

    if kind == "release":
        return "LIVE"

    return "TEST"


def _badge_bg(kind, demo):
    if demo:
        return AMBER_DARK

    if kind == "release":
        return GREEN_DARK

    return AMBER_DARK


def _badge_fg(kind, demo):
    if demo:
        return AMBER

    if kind == "release":
        return GREEN

    return AMBER


# ---------------------------------------------------------
# DRAWING HELPERS
# ---------------------------------------------------------

def _draw_fit(c, text, x, y, maxw, fonts, color):
    s = text.upper()

    for font in fonts:
        if c.text_width(s, font) <= maxw:
            c.text(
                s,
                x,
                y,
                font = font,
                color = color,
            )
            return

    smallest = fonts[len(fonts) - 1]

    clipped = _clip_to_width(
        c,
        s,
        smallest,
        maxw,
    )

    c.text(
        clipped.upper(),
        x,
        y,
        font = smallest,
        color = color,
    )


def _draw_grass_block(c, x, y):
    c.sprite(
        GRASS_BLOCK,
        x,
        y,
        legend = {
            "G": GREEN,
            "g": GREEN_LIGHT,
            "D": DIRT,
            "d": DIRT_DARK,
        },
        scale = 2,
    )


def _draw_grass_strip(c):
    # BRIGHT GREEN GRASS TOP
    c.rect(
        0,
        27,
        127,
        27,
        fill = GREEN_LIGHT,
    )

    # DARKER GRASS EDGE
    c.rect(
        0,
        28,
        127,
        28,
        fill = GREEN,
    )

    # DIRT
    c.rect(
        0,
        29,
        127,
        31,
        fill = DIRT,
    )

    # PIXEL DIRT TEXTURE
    c.pixel(
        8,
        29,
        DIRT_DARK,
    )

    c.pixel(
        21,
        30,
        DIRT_DARK,
    )

    c.pixel(
        33,
        29,
        DIRT_DARK,
    )

    c.pixel(
        47,
        31,
        DIRT_DARK,
    )

    c.pixel(
        62,
        30,
        DIRT_DARK,
    )

    c.pixel(
        79,
        29,
        DIRT_DARK,
    )

    c.pixel(
        95,
        30,
        DIRT_DARK,
    )

    c.pixel(
        112,
        29,
        DIRT_DARK,
    )


def _draw_badge(c, text, x1, y0, bg, fg):
    label = text.upper()

    font = "4x5"

    width = c.text_width(
        label,
        font,
    )

    x0 = x1 - width - 6

    c.round_rect(
        x0,
        y0,
        x1,
        y0 + 7,
        2,
        fill = bg,
    )

    c.text_stroke(
        label,
        x1 - 3,
        y0 + 1,
        font = font,
        color = fg,
        stroke = BLACK,
        thickness = 1,
        align = "right",
    )


# ---------------------------------------------------------
# LIVE SCREEN
# ---------------------------------------------------------

def _draw_live(c, kind, title, line1, line2, demo):
    c.fill(BG)

    c.rect(
        0,
        0,
        127,
        26,
        fill = PANEL,
    )

    # MINECRAFT GRASS BLOCK
    _draw_grass_block(
        c,
        4,
        5,
    )

    # DIVIDER
    c.vline(
        24,
        3,
        24,
        GREEN_EDGE,
    )

    # SMALL VERSION HEADER
    header = _header_label(
        kind,
        title,
    )

    _draw_fit(
        c,
        header,
        29,
        1,
        62,
        [
            "5x7",
            "4x5",
        ],
        GRAY,
    )

    # LIVE / TEST / DEMO BADGE
    badge = _badge_text(
        kind,
        demo,
    )

    _draw_badge(
        c,
        badge,
        123,
        0,
        _badge_bg(kind, demo),
        _badge_fg(kind, demo),
    )

    # MAIN UPDATE SUMMARY
    _draw_fit(
        c,
        line1,
        29,
        9,
        95,
        [
            "6x8",
            "5x7",
            "4x5",
        ],
        WHITE,
    )

    _draw_fit(
        c,
        line2,
        29,
        18,
        95,
        [
            "6x8",
            "5x7",
            "4x5",
        ],
        WHITE,
    )

    # GRASS ALONG BOTTOM
    _draw_grass_strip(c)


# ---------------------------------------------------------
# ERROR SCREEN
# ---------------------------------------------------------

def _draw_error(c):
    c.fill(BG)

    c.rect(
        0,
        0,
        127,
        26,
        fill = PANEL,
    )

    _draw_grass_block(
        c,
        4,
        5,
    )

    c.text(
        "MINECRAFT".upper(),
        29,
        2,
        font = "4x5",
        color = GRAY,
    )

    c.text(
        "CHECK FAILED".upper(),
        29,
        10,
        font = "6x8",
        color = AMBER,
    )

    c.text(
        "TRY AGAIN LATER".upper(),
        29,
        20,
        font = "4x5",
        color = GRAY,
    )

    _draw_grass_strip(c)


# ---------------------------------------------------------
# EMPTY SCREEN
# ---------------------------------------------------------

def _draw_empty(c):
    c.fill(BG)

    c.rect(
        0,
        0,
        127,
        26,
        fill = PANEL,
    )

    _draw_grass_block(
        c,
        4,
        5,
    )

    c.vline(
        24,
        3,
        24,
        GREEN_EDGE,
    )

    c.text(
        "MINECRAFT".upper(),
        29,
        2,
        font = "4x5",
        color = GRAY,
    )

    c.text(
        "ALL CLEAR".upper(),
        29,
        10,
        font = "7x12",
        color = GREEN,
    )

    c.text(
        "NO UPDATE LISTED".upper(),
        29,
        22,
        font = "4x5",
        color = GRAY,
    )

    _draw_grass_strip(c)


# ---------------------------------------------------------
# PAGE RENDERER
# ---------------------------------------------------------

def _render(c, ctx, kind, section_id, demo_data):
    mode = str(
        ctx.inputs.get(
            "mode",
            "LIVE",
        )
    ).upper()

    if mode == "DEMO":
        _draw_live(
            c,
            kind,
            demo_data["title"].upper(),
            demo_data["line1"].upper(),
            demo_data["line2"].upper(),
            True,
        )
        return

    result = _fetch_latest(
        section_id,
    )

    if result["state"] == "error":
        _draw_error(c)
        return

    if result["state"] == "empty":
        _draw_empty(c)
        return

    _draw_live(
        c,
        kind,
        result["title"].upper(),
        result["line1"].upper(),
        result["line2"].upper(),
        False,
    )


# ---------------------------------------------------------
# PAGES
# ---------------------------------------------------------

def release(c, ctx):
    c.clear()

    _render(
        c,
        ctx,
        "release",
        SECTION_RELEASE,
        DEMO_RELEASE,
    )


def java(c, ctx):
    c.clear()

    _render(
        c,
        ctx,
        "java",
        SECTION_JAVA,
        DEMO_JAVA,
    )


def bedrock(c, ctx):
    c.clear()

    _render(
        c,
        ctx,
        "bedrock",
        SECTION_PREVIEW,
        DEMO_PREVIEW,
    )