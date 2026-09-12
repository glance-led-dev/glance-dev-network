FONT_HEADER = "5x7"
FONT_HERO = "10x16"
FONT_SMALL = "4x5"

CONTENT_WIDTH = 120  # 128px panel, ~4px padding each side


# Fetches the current England Test/ODI match once, shared by both pages.
# Returns (state, match) where state is one of:
#   "demo"     - no API key entered
#   "error"    - CricAPI unreachable / bad HTTP status
#   "keyerror" - CricAPI reached, but rejected the key
#   "empty"    - key is fine, but no England Test/ODI is current
#   "ok"       - match is the live match dict
def get_match(ctx):
    apikey = ctx.inputs.get("apikey", "")
    if not apikey:
        return "demo", None

    resp = http.get(
        "https://api.cricapi.com/v1/currentMatches",
        params={"apikey": apikey, "offset": "0"},
        ttl_seconds=290,
    )

    if resp["status_code"] != 200:
        return "error", None

    body = resp["json"]

    if body.get("status", "") != "success":
        return "keyerror", None

    matches = body.get("data", [])
    match = find_match(matches)

    if match == None:
        return "empty", None

    return "ok", match


# Picks the first current Test or ODI match that involves England.
def find_match(matches):
    for m in matches:
        match_type = m.get("matchType", "").lower()
        if match_type != "test" and match_type != "odi":
            continue
        teams = m.get("teams", [])
        for t in teams:
            if "england" in t.lower():
                return m
    return None


def live(c, ctx):
    c.fill("black")
    state, match = get_match(ctx)

    if state == "demo":
        draw_demo(c)
    elif state == "error":
        draw_error(c, "CRICAPI ERROR", "RETRY NEXT REFRESH")
    elif state == "keyerror":
        draw_error(c, "CRICAPI KEY REJECTED", "CHECK YOUR API KEY")
    elif state == "empty":
        draw_empty(c)
    else:
        draw_match(c, match)


def commentary(c, ctx):
    c.fill("black")
    state, match = get_match(ctx)

    if state == "demo":
        draw_demo_commentary(c)
    elif state == "error":
        draw_error(c, "CRICAPI ERROR", "RETRY NEXT REFRESH")
    elif state == "keyerror":
        draw_error(c, "CRICAPI KEY REJECTED", "CHECK YOUR API KEY")
    elif state == "empty":
        draw_empty(c)
    else:
        draw_commentary(c, match)


def draw_match(c, m):
    teams = m.get("teams", ["", ""])
    home = teams[0] if len(teams) > 0 else ""
    away = teams[1] if len(teams) > 1 else ""
    match_started = m.get("matchStarted", False)
    match_ended = m.get("matchEnded", False)
    status_text = m.get("status", "")

    dot_color = dot_color_for(match_started, match_ended)
    draw_header(c, home, away, dot_color)

    if not match_started:
        c.text("UPCOMING", c.width // 2, 10, font="6x8", color="amber", align="center")
        draw_status_line(c, status_text, 27)
        return

    scores = m.get("score", [])
    if len(scores) > 0:
        last = scores[len(scores) - 1]
        inning_label = last.get("inning", "")
        batting_team = team_for_inning(inning_label, home, away)
        hero = abbr(batting_team) + " " + str(last.get("r", 0)) + "-" + str(last.get("w", 0))
        hero_color = "gray" if match_ended else "white"
        hero = fit_text(c, hero, FONT_HERO, CONTENT_WIDTH)
        c.text(hero, c.width // 2, 9, font=FONT_HERO, color=hero_color, align="center")
    else:
        c.text("STARTING", c.width // 2, 12, font="6x8", color="amber", align="center")

    draw_status_line(c, status_text, 27)


# The detail page: every innings for both sides, plus the full status line.
def draw_commentary(c, m):
    teams = m.get("teams", ["", ""])
    home = teams[0] if len(teams) > 0 else ""
    away = teams[1] if len(teams) > 1 else ""
    match_started = m.get("matchStarted", False)
    match_ended = m.get("matchEnded", False)
    status_text = m.get("status", "")
    scores = m.get("score", [])

    dot_color = dot_color_for(match_started, match_ended)
    draw_header(c, home, away, dot_color)

    if not match_started:
        line = fit_text(c, status_text, FONT_SMALL, CONTENT_WIDTH)
        c.text(line, c.width // 2, 15, font=FONT_SMALL, color="amber", align="center")
        return

    home_line = fit_text(c, abbr(home) + " " + innings_summary(scores, home), FONT_SMALL, CONTENT_WIDTH)
    away_line = fit_text(c, abbr(away) + " " + innings_summary(scores, away), FONT_SMALL, CONTENT_WIDTH)

    c.text(home_line, c.width // 2, 9, font=FONT_SMALL, color="white", align="center")
    c.text(away_line, c.width // 2, 16, font=FONT_SMALL, color="white", align="center")

    draw_status_line(c, status_text, 24)


# All of a team's innings scores, e.g. "133 & 449-10". "YET TO BAT" if none yet.
def innings_summary(scores, team_name):
    parts = []
    for s in scores:
        inning_label = s.get("inning", "")
        if team_name.lower() in inning_label.lower():
            parts.append(str(s.get("r", 0)) + "-" + str(s.get("w", 0)))
    if len(parts) == 0:
        return "YET TO BAT"
    return " & ".join(parts)


def dot_color_for(match_started, match_ended):
    if match_ended:
        return "gray"
    elif match_started:
        return "green"
    else:
        return "amber"


def draw_header(c, home, away, dot_color):
    draw_england_flag(c, 3, 1, 13, 8)
    label = abbr(home) + " V " + abbr(away)
    label = fit_text(c, label, FONT_HEADER, 92)
    c.text(label, 19, 1, font=FONT_HEADER, color="white")
    c.rect(c.width - 9, 2, c.width - 6, 5, fill=dot_color)


# A small St George's Cross (England's flag) drawn from plain rectangles,
# no image asset needed. w/h should be at least 10x6 to read cleanly.
def draw_england_flag(c, x, y, w, h):
    c.rect(x, y, x + w - 1, y + h - 1, fill="white")
    bar_h = max(2, h // 3)
    bar_y = y + (h - bar_h) // 2
    c.rect(x + 1, bar_y, x + w - 2, bar_y + bar_h - 1, fill="red")
    bar_w = max(2, w // 4)
    bar_x = x + (w - bar_w) // 2
    c.rect(bar_x, y + 1, bar_x + bar_w - 1, y + h - 2, fill="red")


def draw_status_line(c, status_text, y):
    if status_text == "":
        return
    line = fit_text(c, status_text, FONT_SMALL, CONTENT_WIDTH)
    c.text(line, c.width // 2, y, font=FONT_SMALL, color="gray", align="center")


# Truncates s (uppercased) with "..." so it fits max_width at the given font.
def fit_text(c, s, font, max_width):
    s = s.upper()
    if c.text_width(s, font=font) <= max_width:
        return s
    n = len(s)
    for i in range(n):
        trimmed = s[:n - i]
        if c.text_width(trimmed + "...", font=font) <= max_width:
            return trimmed + "..."
    return "..."


# "Pakistan Inning 2" -> "Pakistan" (matched against the known home/away names,
# since CricAPI's inning label isn't just a team name).
def team_for_inning(inning_label, home, away):
    label_lower = inning_label.lower()
    if home.lower() in label_lower:
        return home
    if away.lower() in label_lower:
        return away
    return inning_label


# "England" -> "ENG", "Trinbago Knight Riders" -> "TKR"
def abbr(name):
    name = name.upper()
    words = name.split(" ")
    if len(words) <= 1:
        return name[:3]
    out = ""
    for w in words:
        if len(w) > 0:
            out += w[0]
    return out


def draw_error(c, line1, line2):
    c.text(line1, c.width // 2, 11, font=FONT_HEADER, color="red", align="center")
    c.text(line2, c.width // 2, 20, font=FONT_SMALL, color="gray", align="center")


def draw_empty(c):
    c.text("NO MATCH LIVE", c.width // 2, 11, font=FONT_HEADER, color="white", align="center")
    c.text("CHECK BACK LATER", c.width // 2, 20, font=FONT_SMALL, color="gray", align="center")


def draw_demo(c):
    draw_header(c, "England", "Pakistan", "green")
    c.text("PAK 449-10", c.width // 2, 9, font=FONT_HERO, color="white", align="center")
    c.text("DEMO - ADD API KEY", c.width // 2, 27, font=FONT_SMALL, color="amber", align="center")


def draw_demo_commentary(c):
    draw_header(c, "England", "Pakistan", "green")
    c.text("PAK 133 & 449-10", c.width // 2, 9, font=FONT_SMALL, color="white", align="center")
    c.text("ENG 453", c.width // 2, 16, font=FONT_SMALL, color="white", align="center")
    c.text("DEMO - ADD API KEY", c.width // 2, 24, font=FONT_SMALL, color="amber", align="center")
