# Custom Schedule Classic -- upcoming-game card for a single 64x32 panel,
# styled after a pro-sports "matchup" board: two big team logos side by side
# with "VS" between them, each team's 2-4 letter code in bold underneath its
# own logo, and the date/time along the bottom.
#
# This is a hardcoded snapshot of the schedule spreadsheet's first 8 rows:
# https://docs.google.com/spreadsheets/d/1RAdODqjHvG5g7sagBCOCgtmuwggMEKTpZcYrktJw1NY
# not a live read of it -- most of its logo columns are file:// paths on this
# laptop, which nothing but this laptop can fetch, so a live version needs
# those hosted somewhere fetchable first. Colors come from the sheet's
# "home/away color or hex" columns; named colors are converted by hand since
# there's no live parsing yet. Team codes are the sheet's own "2-4 letter
# abreviation" column (Prout itself isn't in that column since it's only for
# non-Prout teams, so its code -- "PRT" -- is hardcoded here); if a 4-letter
# code is still too wide in bold at this size, it's cut to 3 -- see
# _team_code in the generator this file was built from (none of the current
# 8 needed it, they're all already narrow enough).

LOGO_W = 22
LOGO_H = 16
LOGO_Y = 1
AWAY_X = 2
HOME_X = 64 - 2 - LOGO_W

def _team_center(x):
    return x + LOGO_W // 2

def _draw_game(c, away_name, away_logo, away_color, home_name, home_logo, home_color, date_str, time_str):
    c.fill("black")

    # ---- logos, side by side, with "VS" between them ----
    c.image(away_logo, AWAY_X, LOGO_Y, w = LOGO_W, h = LOGO_H)
    c.image(home_logo, HOME_X, LOGO_Y, w = LOGO_W, h = LOGO_H)
    vs_x = (AWAY_X + LOGO_W + HOME_X) // 2
    c.text("VS", vs_x, LOGO_Y + LOGO_H // 2 - 3, font = "4x5", color = "gray", align = "center")

    # ---- team codes, bold, centered under each logo ----
    code_y = LOGO_Y + LOGO_H + 1
    c.text(away_name, _team_center(AWAY_X), code_y, font = "5x7b", color = away_color, align = "center")
    c.text(home_name, _team_center(HOME_X), code_y, font = "5x7b", color = home_color, align = "center")

    # ---- date / time, bottom, centered ----
    dt = date_str + " " + time_str
    c.text(dt, c.width // 2, 32 - 5, font = "4x5", color = "white", align = "center")

# ---- page 1: sheet row 2 -- PRT @ EG, AUG 25 4:30P ----
def game1(c, ctx):
    _draw_game(
        c,
        away_name = "PRT", away_logo = "prout.png", away_color = "white",
        home_name = "EG", home_logo = "eghs.png", home_color = "#800000",
        date_str = "AUG 25", time_str = "4:30P",
    )

# ---- page 2: sheet row 3 -- FOX @ PRT, AUG 28 6:15P ----
def game2(c, ctx):
    _draw_game(
        c,
        away_name = "FOX", away_logo = "foxborough.png", away_color = "#CEB45A",
        home_name = "PRT", home_logo = "prout.png", home_color = "#800000",
        date_str = "AUG 28", time_str = "6:15P",
    )

# ---- page 3: sheet row 4 -- PRT @ PILG, AUG 29 2:30P ----
def game3(c, ctx):
    _draw_game(
        c,
        away_name = "PRT", away_logo = "prout.png", away_color = "#800000",
        home_name = "PILG", home_logo = "pilgrim.png", home_color = "white",
        date_str = "AUG 29", time_str = "2:30P",
    )

# ---- page 4: sheet row 5 -- PRT @ CHAR, SEP 1 4:30P ----
def game4(c, ctx):
    _draw_game(
        c,
        away_name = "PRT", away_logo = "prout.png", away_color = "#800000",
        home_name = "CHAR", home_logo = "chariho.png", home_color = "green",
        date_str = "SEP 1", time_str = "4:30P",
    )

# ---- page 5: sheet row 6 -- PRT @ DCT, SEP 1 5:00P ----
def game5(c, ctx):
    _draw_game(
        c,
        away_name = "PRT", away_logo = "prout.png", away_color = "#800000",
        home_name = "DCT", home_logo = "daviesct.png", home_color = "#CEB45A",
        date_str = "SEP 1", time_str = "5:00P",
    )

# ---- page 6: sheet row 7 -- CWHS @ PRT, SEP 1 6:30P ----
def game6(c, ctx):
    _draw_game(
        c,
        away_name = "CWHS", away_logo = "cranstonwest.png", away_color = "red",
        home_name = "PRT", home_logo = "prout.png", home_color = "#800000",
        date_str = "SEP 1", time_str = "6:30P",
    )

# ---- page 7: sheet row 8 -- PRT @ JS, SEP 3 4:30P ----
def game7(c, ctx):
    _draw_game(
        c,
        away_name = "PRT", away_logo = "prout.png", away_color = "#800000",
        home_name = "JS", home_logo = "juanita.png", home_color = "red",
        date_str = "SEP 3", time_str = "4:30P",
    )

# ---- page 8: sheet row 9 -- LINC @ PRT, SEP 3 6:30P ----
def game8(c, ctx):
    _draw_game(
        c,
        away_name = "LINC", away_logo = "lincoln.png", away_color = "blue",
        home_name = "PRT", home_logo = "prout.png", home_color = "#800000",
        date_str = "SEP 3", time_str = "6:30P",
    )
