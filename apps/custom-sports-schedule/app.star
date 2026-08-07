# Custom Sports Schedule -- a title/splash card (Prout's logo + "UPCOMING
# GAMES"), then upcoming-game cards for Prout's athletics schedule: a sport
# icon (soccer ball w/ M or W above it for boys/girls, or a volleyball) all
# the way on the left, then team logos side by side, team names, and
# date/time.
#
# This is a hardcoded snapshot of the schedule spreadsheet's next 7 games:
# https://docs.google.com/spreadsheets/d/1RAdODqjHvG5g7sagBCOCgtmuwggMEKTpZcYrktJw1NY
# not a live read of it -- most of its logo columns are file:// paths on this
# laptop, which nothing but this laptop can fetch, so a live version needs
# those hosted somewhere fetchable first. Colors come from the sheet's
# "home/away color or hex" columns; named colors are converted by hand since
# there's no live parsing yet. Team names are the sheet's own name UNLESS it's
# too wide for the name column, in which case it's swapped for the sheet's
# "non prout teams abbreviation" column instead of shrinking the font --
# every name below is already whichever of the two fits.
#
# _draw_badge is a fallback for a team with no logo at all in the sheet: a
# plain colored circle with the first letter of its abbreviation. None of
# the current 7 games need it, but it's kept in case a future row does.

def title(c, ctx):
    c.fill("black")
    block_w = 32 + 4 + max(c.text_width("UPCOMING", "10x16_bold"), c.text_width("GAMES", "10x16_bold"))
    x0 = (c.width - block_w) // 2
    c.image("prout.png", x0, 0, w = 32, h = 32)
    c.text("UPCOMING", x0 + 36, 0, font = "10x16_bold", color = "white")
    c.text("GAMES", x0 + 36, 16, font = "10x16_bold", color = "#800000")

LOGO_SIZE = 26
LOGO_Y = 3
NAME_MAXW = 48  # each name must fit this (else the sheet's abbreviation is used instead)

# Sport icon on the far LEFT, then logos/names/date-time shifted right to
# make room for it.
ICON_SIZE = 20
ICON_X = 4
ICON_CX = ICON_X + ICON_SIZE // 2

AWAY_X = ICON_X + ICON_SIZE + 8
HOME_X = AWAY_X + LOGO_SIZE + 12

def _draw_badge(c, x, y, size, color, letter):
    """Fallback for a team with no logo in the sheet: a plain colored circle
    with the first letter of its abbreviation."""
    r = size // 2
    c.fill_circle(x + r, y + r, r, color)
    c.circle(x + r, y + r, r, "white")
    c.text(letter, x + r, y + r - 3, font = "5x7b", color = "black", align = "center")

def _draw_logo(c, logo, x, y, size, color, name):
    if logo == None:
        _draw_badge(c, x, y, size, color, name[0] if name else "?")
    else:
        c.image(logo, x, y, w = size, h = size)

def _draw_game(c, away_name, away_logo, away_color, home_name, home_logo, home_color, date_str, time_str, icon, letter):
    c.fill("black")

    # ---- sport icon, far left: soccer ball (+ M/W above it) or volleyball ----
    if letter != None:
        c.text(letter, ICON_CX, 1, font = "4x5", color = "white", align = "center")
        c.image(icon, ICON_X, 9, w = ICON_SIZE, h = ICON_SIZE)
    else:
        c.image(icon, ICON_X, (c.height - ICON_SIZE) // 2, w = ICON_SIZE, h = ICON_SIZE)

    # ---- logos, side by side, with "AT" between them ----
    _draw_logo(c, away_logo, AWAY_X, LOGO_Y, LOGO_SIZE, away_color, away_name)
    _draw_logo(c, home_logo, HOME_X, LOGO_Y, LOGO_SIZE, home_color, home_name)
    vs_x = (AWAY_X + LOGO_SIZE + HOME_X) // 2
    c.text("AT", vs_x, LOGO_Y + LOGO_SIZE // 2 - 5, font = "4x5", color = "gray", align = "center")

    # ---- team names (bold, fixed size -- long names already swapped for
    # the sheet's abbreviation upstream, so this never needs to shrink) ----
    name_x = HOME_X + LOGO_SIZE + 6
    c.text(away_name, name_x, 3, font = "5x7b", color = away_color)
    c.text(home_name, name_x, 17, font = "5x7b", color = home_color)

    # ---- date / time: right after the names, however wide they are ----
    name_w = max(c.text_width(away_name, "5x7b"), c.text_width(home_name, "5x7b"))
    dt_x = name_x + name_w + 8
    c.text(date_str, dt_x, 3, font = "4x5", color = "white")
    c.text(time_str, dt_x, 17, font = "4x5", color = "gray")

# ---- page 1: sheet row 2 -- mens soccer -- PROUT @ EGHS, AUG 25 4:30 PM ----
def game1(c, ctx):
    _draw_game(
        c,
        away_name = "PROUT", away_logo = "prout.png", away_color = "white",
        home_name = "EGHS", home_logo = "eghs.png", home_color = "#800000",
        date_str = "AUG 25", time_str = "4:30 PM",
        icon = "soccer_ball.png", letter = "M",
    )

# ---- page 2: sheet row 3 -- girls soccer -- FXBRGH @ PROUT, AUG 28 6:15 PM ----
def game2(c, ctx):
    _draw_game(
        c,
        away_name = "FXBRGH", away_logo = "foxborough.png", away_color = "#CEB45A",
        home_name = "PROUT", home_logo = "prout.png", home_color = "#800000",
        date_str = "AUG 28", time_str = "6:15 PM",
        icon = "soccer_ball.png", letter = "W",
    )

# ---- page 3: sheet row 4 -- girls soccer -- PROUT @ PILGRIM, AUG 29 2:30 PM ----
def game3(c, ctx):
    _draw_game(
        c,
        away_name = "PROUT", away_logo = "prout.png", away_color = "#800000",
        home_name = "PILGRIM", home_logo = "pilgrim.png", home_color = "white",
        date_str = "AUG 29", time_str = "2:30 PM",
        icon = "soccer_ball.png", letter = "W",
    )

# ---- page 4: sheet row 5 -- volleyball -- PROUT @ CHARIHO, SEP 1 4:30 PM ----
def game4(c, ctx):
    _draw_game(
        c,
        away_name = "PROUT", away_logo = "prout.png", away_color = "#800000",
        home_name = "CHARIHO", home_logo = "chariho.png", home_color = "green",
        date_str = "SEP 1", time_str = "4:30 PM",
        icon = "volleyball.png", letter = None,
    )

# ---- page 5: sheet row 6 -- mens soccer -- PROUT @ DAVIES, SEP 1 5:00 PM ----
def game5(c, ctx):
    _draw_game(
        c,
        away_name = "PROUT", away_logo = "prout.png", away_color = "#800000",
        home_name = "DAVIES", home_logo = "daviesct.png", home_color = "#CEB45A",
        date_str = "SEP 1", time_str = "5:00 PM",
        icon = "soccer_ball.png", letter = "M",
    )

# ---- page 6: sheet row 7 -- girls soccer -- CWHS @ PROUT, SEP 1 6:30 PM ----
def game6(c, ctx):
    _draw_game(
        c,
        away_name = "CWHS", away_logo = "cranstonwest.png", away_color = "red",
        home_name = "PROUT", home_logo = "prout.png", home_color = "#800000",
        date_str = "SEP 1", time_str = "6:30 PM",
        icon = "soccer_ball.png", letter = "W",
    )

# ---- page 7: sheet row 8 -- mens soccer -- PROUT @ JUANITA, SEP 3 4:30 PM ----
def game7(c, ctx):
    _draw_game(
        c,
        away_name = "PROUT", away_logo = "prout.png", away_color = "#800000",
        home_name = "JUANITA", home_logo = "juanita.png", home_color = "red",
        date_str = "SEP 3", time_str = "4:30 PM",
        icon = "soccer_ball.png", letter = "M",
    )
