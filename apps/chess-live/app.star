# Chess Live -- elite chess, your Chess.com rating and the daily puzzle, on a
# 192x32 SCROLL panel.
#
# DESIGN. A panel is 32 pixels tall and a chess board is 8 squares, so a
# real board fits exactly at 4px a square, and that board is the app's
# identity. Fan research set the three pages: fans watch elite events live,
# players put their own rating on every widget they own, and the daily
# puzzle is a daily habit.
#   live    the featured board of an elite (Lichess tier 5) event when a
#           round is on -- Tata Steel, Candidates, Grand Chess Tour -- and
#           otherwise Lichess TV, the top game being played online right now
#   you     your Chess.com rating, best and record for one time control; with
#           no username, the Chess.com top 3 (Hikaru, Magnus...)
#   puzzle  today's Chess.com daily puzzle on the board, from the side to move
#
# Data, all keyless:
#   lichess.org/api/broadcast/top          elite broadcasts and their rounds
#   lichess.org/api/broadcast/-/-/<round>  every board: fen, last move, result
#   lichess.org/api/tv/channels + /game/export/<id>   Lichess TV game
#   api.chess.com/pub/player/<u>/stats     ratings, best, win/loss/draw
#   api.chess.com/pub/leaderboards         top players per time control
#   api.chess.com/pub/puzzle               the daily puzzle (fen, title)

TOP_URL = "https://lichess.org/api/broadcast/top"
ROUND_URL = "https://lichess.org/api/broadcast/-/-/"
TV_URL = "https://lichess.org/api/tv/channels"
GAME_URL = "https://lichess.org/game/export/"
STATS_URL = "https://api.chess.com/pub/player/"
LEADERS_URL = "https://api.chess.com/pub/leaderboards"
PUZZLE_URL = "https://api.chess.com/pub/puzzle"
# Both APIs ask callers to identify themselves; Chess.com answers 403 to a
# generic Python user agent.
JSON_HEADERS = {
    "Accept": "application/json",
    "User-Agent": "Glance-GDN chess-live (github.com/glance-led-dev/glance-dev-network)",
}

# Lichess ranks broadcasts by tier; 5 is reserved for elite events.
ELITE_TIER = 5

MODES = {
    "BLITZ": ["chess_blitz", "live_blitz"],
    "RAPID": ["chess_rapid", "live_rapid"],
    "BULLET": ["chess_bullet", "live_bullet"],
}

COLORS = {
    "bg": "#000000",
    "text": "#F4F7FB",
    "label": "#8A93A6",
    "dim": "#4B5563",
    "hair": "#1E2430",
    # Board: dark slate keeps the panel near-black; white and gold pieces
    # read on every square (black pieces vanished on brown boards).
    "light": "#4A5568",
    "dark": "#262C38",
    "light_move": "#A8923C",
    "dark_move": "#7A6A26",
    "white_piece": "#FFFFFF",
    "black_piece": "#FFB020",
    "live": "#EF4444",
    "elite": "#D9A441",
    "chesscom": "#81B64C",
    "up": "#22C55E",
    "down": "#EF4444",
    "draw": "#8A93A6",
    "error": "#E8B04A",
    "error_sub": "#6A7090",
}

# 3x3 pieces in the lower-left of each 4x4 square, so a one-pixel gap
# separates neighbours (full-square pieces merged a row of pawns into a bar).
PIECES = {
    "p": [[0, 0, 0], [0, 1, 0], [1, 1, 1]],
    "r": [[1, 0, 1], [1, 1, 1], [1, 1, 1]],
    "n": [[1, 1, 0], [0, 1, 1], [1, 1, 1]],
    "b": [[0, 1, 0], [1, 1, 0], [1, 1, 1]],
    "q": [[1, 0, 1], [0, 1, 0], [1, 1, 1]],
    "k": [[0, 1, 0], [1, 1, 1], [1, 1, 1]],
}

# Page 2's identity: a large king.
KING = """
....K....
...KKK...
....K....
..KKKKK..
.KKKKKKK.
..KKKKK..
...KKK...
...KKK...
..KKKKK..
.KKKKKKK.
KKKKKKKKK
"""

START_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1"

BOARD_X = 10
SQ = 4
RIGHT = 181
TEXT_X = BOARD_X + 8 * SQ + 6

MONTHS = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

RESULT_WORD = {
    "mate": "CHECKMATE",
    "resign": "RESIGNED",
    "outoftime": "ON TIME",
    "timeout": "ON TIME",
    "stalemate": "STALEMATE",
    "draw": "DRAW",
    "aborted": "ABORTED",
}


# ---- helpers -------------------------------------------------------------

def get_json(url, ttl, headers = JSON_HEADERS):
    resp = http.get(url, headers = headers, ttl_seconds = ttl)
    return [resp["status_code"], resp["json"] if resp["status_code"] == 200 else None]


def clip(c, text, font, max_w):
    text = str(text)
    for _i in range(48):
        if len(text) <= 1 or c.text_width(text, font) <= max_w:
            break
        text = text[:len(text) - 1]
    return text.strip()


def clip_words(c, text, font, max_w):
    # Drop whole words from the end until it fits; never end mid-word.
    words = [w for w in str(text).split(" ") if w != ""]
    for n in range(len(words), 0, -1):
        trial = " ".join(words[:n]).rstrip(":,-")
        if c.text_width(trial, font) <= max_w:
            return trial
    return clip(c, text, font, max_w)


def wrap2(c, text, font, max_w):
    # Up to two lines, broken at words; the second line clipped at a word.
    words = [w for w in str(text).split(" ") if w != ""]
    used = 0
    for n in range(1, len(words) + 1):
        if c.text_width(" ".join(words[:n]), font) > max_w:
            break
        used = n
    if used == 0:
        return [clip(c, text, font, max_w), ""]
    rest = " ".join(words[used:])
    return [" ".join(words[:used]), clip_words(c, rest, font, max_w) if rest != "" else ""]


def civil_from_days(z):
    # Days since 1970-01-01 -> [y, m, d] (Howard Hinnant's algorithm).
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return [y, m, d]


def date_label(unix_seconds):
    ymd = civil_from_days(int(unix_seconds) // 86400)
    return MONTHS[ymd[1]] + " " + str(ymd[2])


def surname(name):
    # Broadcast names are "Surname, Given"; online names are usernames.
    n = str(name).strip()
    if "," in n:
        n = n.split(",")[0]
    return n.upper()


def username_input(ctx):
    # Glance cuts setting values at "_", so users type a space instead.
    u = str(ctx.inputs.get("username", "NONE")).strip()
    if u == "" or u.upper() in ["NONE", "N/A", "NA", "-"]:
        return ""
    return u.replace(" ", "_").lower()


def mode_input(ctx):
    m = str(ctx.inputs.get("timecontrol", "BLITZ")).upper()
    return m if m in MODES else "BLITZ"


# ---- board ---------------------------------------------------------------

def draw_board(c, fen, last_move = "", flip = False):
    # White at the bottom, or black at the bottom when flip is set (a puzzle
    # with black to move is shown from black's side, as Chess.com does).
    lit = {}
    lm = str(last_move or "")
    if len(lm) >= 4:
        lit[lm[0:2]] = True
        lit[lm[2:4]] = True
    for row in range(8):
        for col in range(8):
            file = 7 - col if flip else col
            rank = row if flip else 7 - row
            name = "abcdefgh"[file] + str(rank + 1)
            light = (row + col) % 2 == 0
            if lit.get(name, False):
                fill = COLORS["light_move"] if light else COLORS["dark_move"]
            else:
                fill = COLORS["light"] if light else COLORS["dark"]
            x = BOARD_X + col * SQ
            y = row * SQ
            c.rect(x, y, x + SQ - 1, y + SQ - 1, fill = fill)

    ranks = str(fen).split(" ")[0].split("/")
    for r in range(len(ranks)):
        if r >= 8:
            break
        f = 0
        for ch in ranks[r].elems():
            if ch in "12345678":
                f += int(ch)
                continue
            if f > 7:
                break
            art = PIECES.get(ch.lower())
            if art != None:
                col = 7 - f if flip else f
                row = 7 - r if flip else r
                piece = COLORS["white_piece"] if ch.upper() == ch else COLORS["black_piece"]
                c.bitmap(art, BOARD_X + col * SQ, row * SQ + 1, piece)
            f += 1


# ---- shared text pieces ----------------------------------------------------

def header(c, x, word, word_col, label, label_col, live):
    if live:
        c.fill_circle(x + 2, 3, 2, COLORS["live"])
        x += 7
    if word != "":
        c.text(word, x, 1, font = "4x5", color = word_col)
        x += c.text_width(word, "4x5") + 4
    c.text(clip_words(c, label, "4x5", RIGHT - x), x, 1, font = "4x5", color = label_col)


def player_row(c, y, is_white, name, rating, extra = "", title = ""):
    # Side chip (white / gold), name, then rating right-aligned.
    chip = COLORS["white_piece"] if is_white else COLORS["black_piece"]
    c.rect(TEXT_X, y + 1, TEXT_X + 3, y + 5, fill = chip)
    right = str(rating) if rating != None and str(rating) != "" else ""
    if extra != "":
        right = extra + " " + right if right != "" else extra
    right_w = c.text_width(right, "4x5")
    c.text(right, RIGHT, y + 1, font = "4x5", color = COLORS["label"], align = "right")
    room = RIGHT - right_w - 4 - (TEXT_X + 7)
    # Title + name if it fits; then the name alone; then the name cut down
    # (whole words for "Surname Surname", characters for one long username).
    shown = (title + " " + name) if title != "" else name
    if c.text_width(shown, "5x7") > room:
        shown = name
    if c.text_width(shown, "5x7") > room:
        shown = clip_words(c, name, "5x7", room)
    c.text(shown, TEXT_X + 7, y, font = "5x7", color = COLORS["text"])


def bottom_line(c, text, col):
    c.text(clip_words(c, text, "4x5", RIGHT - TEXT_X), TEXT_X, 26, font = "4x5", color = col)


def draw_error(c, title, sub):
    draw_board(c, START_FEN)
    c.text(clip_words(c, title, "6x8", RIGHT - TEXT_X), TEXT_X, 8, font = "6x8", color = COLORS["error"])
    c.text(clip_words(c, sub, "4x5", RIGHT - TEXT_X), TEXT_X, 20, font = "4x5", color = COLORS["error_sub"])


# ---- page 1: elite board, or Lichess TV -------------------------------------

def elite_live(top):
    # The highest-tier broadcast with a round in progress, if it is elite.
    best = None
    for b in (top.get("active") or []):
        if not bool((b.get("round") or {}).get("ongoing", False)):
            continue
        tier = int((b.get("tour") or {}).get("tier") or 0)
        if tier < ELITE_TIER:
            continue
        if best == None or tier > int((best.get("tour") or {}).get("tier") or 0):
            best = b
    return best


def draw_elite(c, b, games):
    featured = games[0]
    for g in games:
        if str(g.get("status") or "") == "*":
            featured = g
            break
    draw_board(c, featured.get("fen") or START_FEN, featured.get("lastMove") or "")
    status = str(featured.get("status") or "*")
    live = status == "*"
    tour = b.get("tour") or {}
    header(c, TEXT_X, "LIVE" if live else "FINAL", COLORS["live"] if live else COLORS["text"],
           str(tour.get("name") or "ELITE CHESS").upper(), COLORS["label"], live)
    ps = featured.get("players") or []
    for i in range(2):
        p = ps[i] if i < len(ps) else {}
        player_row(c, 8 if i == 0 else 17, i == 0, surname(p.get("name") or "TBD"),
                   p.get("rating"), str(p.get("fed") or ""), str(p.get("title") or ""))
    rname = str((b.get("round") or {}).get("name") or "").upper()
    if live:
        bottom_line(c, rname, COLORS["elite"])
    else:
        text = status.replace("½", "1/2")
        word = "WHITE WINS" if text == "1-0" else ("BLACK WINS" if text == "0-1" else "DRAW")
        bottom_line(c, text + "  " + word + ("  " + rname if rname != "" else ""),
                    COLORS["draw"] if word == "DRAW" else COLORS["up"])


def draw_tv(c):
    got = get_json(TV_URL, 60)
    chans = got[1]
    if chans == None or type(chans) != "dict" or chans.get("best") == None:
        draw_error(c, "LICHESS OFFLINE", "LIVE GAMES RETURN WHEN IT IS BACK")
        return
    gid = str(chans["best"].get("gameId") or "")
    game = get_json(GAME_URL + gid + "?moves=false&opening=true&lastFen=true", 60)[1] if gid != "" else None
    if game == None or type(game) != "dict" or game.get("lastFen") == None:
        draw_error(c, "LICHESS OFFLINE", "LIVE GAMES RETURN WHEN IT IS BACK")
        return
    draw_board(c, str(game["lastFen"]))
    status = str(game.get("status") or "")
    live = status == "started" or status == "created"
    speed = str(game.get("speed") or "").upper()
    header(c, TEXT_X, "LIVE" if live else "FINAL", COLORS["live"] if live else COLORS["text"],
           "LICHESS TV " + speed, COLORS["label"], live)
    players = game.get("players") or {}
    for side in ["white", "black"]:
        p = players.get(side) or {}
        user = p.get("user") or {}
        player_row(c, 8 if side == "white" else 17, side == "white",
                   str(user.get("name") or "ANONYMOUS").upper(), p.get("rating"), "",
                   str(user.get("title") or ""))
    if live:
        name = str((game.get("opening") or {}).get("name") or "").upper()
        if c.text_width(name, "4x5") > RIGHT - TEXT_X:
            # The opening family rather than a cut-off variation.
            name = name.split(":")[0].strip()
        bottom_line(c, name, COLORS["dim"])
    else:
        winner = str(game.get("winner") or "")
        word = RESULT_WORD.get(status, status.upper())
        if winner != "":
            bottom_line(c, winner.upper() + " WINS - " + word, COLORS["up"])
        else:
            bottom_line(c, word, COLORS["draw"])


def live(c, ctx):
    c.fill(COLORS["bg"])
    top = get_json(TOP_URL, 300)[1]
    if top != None and type(top) == "dict":
        b = elite_live(top)
        if b != None:
            rid = str((b.get("round") or {}).get("id") or "")
            data = get_json(ROUND_URL + rid, 120)[1] if rid != "" else None
            games = (data or {}).get("games") or []
            if len(games) > 0:
                draw_elite(c, b, games)
                return
    # No elite round on: the top game being played on Lichess right now.
    draw_tv(c)


# ---- page 2: your rating, or the top 3 --------------------------------------

def you(c, ctx):
    c.fill(COLORS["bg"])
    mode = mode_input(ctx)
    user = username_input(ctx)
    if user == "":
        draw_leaders(c, mode)
        return

    got = get_json(STATS_URL + user + "/stats", 300)
    if got[0] == 404:
        # Stats can be private on an account that exists (MagnusCarlsen's
        # are), so ask for the profile before blaming the username.
        if get_json(STATS_URL + user, 3600)[0] == 200:
            draw_you_message(c, user, "NO PUBLIC STATS", "THIS ACCOUNT HIDES ITS RATINGS")
        else:
            draw_you_message(c, user, "USER NOT FOUND", "CHECK THE USERNAME IN SETTINGS")
        return
    stats = got[1]
    if stats == None or type(stats) != "dict":
        draw_you_message(c, user, "CHESS.COM OFFLINE", "RATING RETURNS WHEN IT IS BACK")
        return
    block = stats.get(MODES[mode][0])
    if block == None or (block.get("last") or {}).get("rating") == None:
        draw_you_message(c, user, "NO " + mode + " GAMES YET", "PLAY ONE ON CHESS.COM TO START")
        return

    rating = int(block["last"]["rating"])
    best = int((block.get("best") or {}).get("rating") or rating)
    rec = block.get("record") or {}

    c.sprite(KING, 10, 11, color = COLORS["chesscom"])
    x0 = 24
    header(c, x0, "CHESS.COM", COLORS["chesscom"], mode, COLORS["label"], False)

    hero = str(rating)
    hero_w = c.text_width(hero, "10x16")
    c.text(hero, RIGHT, 8, font = "10x16", color = COLORS["text"], align = "right")
    if rating >= best:
        under = "NEW BEST"
        under_col = COLORS["up"]
    else:
        under = "BEST " + str(best)
        under_col = COLORS["label"]
    c.text(under, RIGHT, 26, font = "4x5", color = under_col, align = "right")

    room = RIGHT - hero_w - 6 - x0
    name = user.upper()
    font = "6x8" if c.text_width(name, "6x8") <= room else "5x7"
    c.text(clip(c, name, font, room), x0, 10, font = font, color = COLORS["text"])

    # Record: W green, L red, D grey -- labelled, never bare numbers.
    x = x0
    for item in [["W", rec.get("win"), COLORS["up"]], ["L", rec.get("loss"), COLORS["down"]], ["D", rec.get("draw"), COLORS["draw"]]]:
        piece = item[0] + " " + str(int(item[1] or 0))
        if x + c.text_width(piece, "4x5") > x0 + room:
            break
        c.text(piece, x, 22, font = "4x5", color = item[2])
        x += c.text_width(piece, "4x5") + 6


def draw_you_message(c, user, title, sub):
    c.sprite(KING, 10, 11, color = COLORS["dim"])
    header(c, 24, "CHESS.COM", COLORS["chesscom"], user.upper(), COLORS["label"], False)
    c.text(clip_words(c, title, "6x8", RIGHT - 24), 24, 11, font = "6x8", color = COLORS["error"])
    c.text(clip_words(c, sub, "4x5", RIGHT - 24), 24, 23, font = "4x5", color = COLORS["error_sub"])


def draw_leaders(c, mode):
    header(c, 10, "CHESS.COM TOP", COLORS["chesscom"], mode, COLORS["label"], False)
    c.rect(10, 7, RIGHT, 7, fill = COLORS["hair"])
    data = get_json(LEADERS_URL, 3600)[1]
    rows = ((data or {}).get(MODES[mode][1]) or []) if type(data) == "dict" else []
    if len(rows) == 0:
        c.text("CHESS.COM OFFLINE", 10, 14, font = "5x7", color = COLORS["error"])
        c.text("LEADERS RETURN WHEN IT IS BACK", 10, 24, font = "4x5", color = COLORS["error_sub"])
        return
    for i in range(3):
        if i >= len(rows):
            break
        r = rows[i]
        y = 9 + i * 8
        c.text(str(r.get("rank") or i + 1), 10, y + 1, font = "4x5", color = COLORS["label"])
        score = str(r.get("score") or "")
        # trend_score is {"direction": 1 | -1 | 0, "delta": points}.
        ts = r.get("trend_score") or {}
        trend = 0
        if type(ts) == "dict":
            trend = int(ts.get("delta") or 0) * (1 if int(ts.get("direction") or 0) >= 0 else -1)
            if int(ts.get("direction") or 0) == 0:
                trend = 0
        right_x = RIGHT
        c.text(score, right_x, y, font = "5x7", color = COLORS["text"], align = "right")
        right_x -= c.text_width(score, "5x7") + 4
        if trend != 0:
            t = ("+" if trend > 0 else "") + str(trend)
            c.text(t, right_x, y + 1, font = "4x5", color = COLORS["up"] if trend > 0 else COLORS["down"], align = "right")
            right_x -= c.text_width(t, "4x5") + 4
        title = str(r.get("title") or "")
        name = str(r.get("username") or "").upper()
        shown = title + " " + name if title != "" else name
        room = right_x - 20
        if c.text_width(shown, "5x7") > room:
            shown = clip(c, name, "5x7", room)
        c.text(shown, 20, y, font = "5x7", color = COLORS["text"])


# ---- page 3: daily puzzle ------------------------------------------------------

def puzzle(c, ctx):
    c.fill(COLORS["bg"])
    p = get_json(PUZZLE_URL, 3600)[1]
    if p == None or type(p) != "dict" or p.get("fen") == None:
        draw_error(c, "CHESS.COM OFFLINE", "TODAY'S PUZZLE RETURNS WHEN IT IS BACK")
        return
    fen = str(p["fen"])
    black = " b " in fen
    draw_board(c, fen, "", black)
    when = date_label(p.get("publish_time")) if p.get("publish_time") != None else ""
    header(c, TEXT_X, "DAILY PUZZLE", COLORS["elite"], when, COLORS["label"], False)
    lines = wrap2(c, str(p.get("title") or "").upper(), "5x7", RIGHT - TEXT_X)
    c.text(lines[0], TEXT_X, 9, font = "5x7", color = COLORS["text"])
    if lines[1] != "":
        c.text(lines[1], TEXT_X, 17, font = "5x7", color = COLORS["text"])
    side = "BLACK TO MOVE" if black else "WHITE TO MOVE"
    chip = COLORS["black_piece"] if black else COLORS["white_piece"]
    c.rect(TEXT_X, 27, TEXT_X + 3, 31, fill = chip)
    c.text(side, TEXT_X + 7, 26, font = "4x5", color = COLORS["label"])
