URL = "https://www.harrisonathletics.com/Events"


def clean_text(text):
    text = text.replace("&amp;", "&")
    text = text.replace("&#39;", "'")
    text = text.replace("&quot;", "\"")
    text = text.replace("&nbsp;", " ")
    text = text.replace("\n", " ")
    text = text.replace("\r", " ")
    text = text.replace("\t", " ")

    for i in range(10):
        text = text.replace("  ", " ")

    return text.strip()


def strip_tags(text):
    result = text

    for i in range(100):
        start = result.find("<")

        if start == -1:
            break

        end = result.find(">", start)

        if end == -1:
            break

        result = result[:start] + " " + result[end + 1:]

    return clean_text(result)


def today_text(ctx):
    return str(ctx.now.year) + "-" + pad2(ctx.now.month) + "-" + pad2(ctx.now.day)


def get_schedule(ctx):
    # Today and the next 7 days in one request. Today's cards and the
    # upcoming cards both read this body, so the second call is a cache hit.
    return get_schedule_for_range(
        today_text(ctx),
        shift_date(ctx.now.year, ctx.now.month, ctx.now.day, 7),
    )


def find_event_blocks(body):
    blocks = []
    cursor = 0

    for i in range(30):
        start = body.find("<h4", cursor)

        if start == -1:
            break

        open_end = body.find(">", start)

        if open_end == -1:
            break

        next_start = body.find("<h4", open_end + 1)

        if next_start == -1:
            next_start = len(body)

        block = body[start:next_start]
        blocks.append(block)

        cursor = next_start

    return blocks


def get_team(block):
    start = block.find("<h4")

    if start == -1:
        return "EVENT"

    start = block.find(">", start)

    if start == -1:
        return "EVENT"

    end = block.find("</h4>", start)

    if end == -1:
        return "EVENT"

    return strip_tags(block[start + 1:end])


def pretty_team(team):
    team = team.upper().strip()

    # -------------------------
    # FALL SPORTS
    # -------------------------

    if team == "GO GIRLS":
        return "GIRLS GOLF"

    if team == "TE BOYS":
        return "BOYS TENNIS"

    if team == "SO BOYS JV":
        return "BOYS JV SOCCER"

    if team == "SO BOYS V":
        return "BOYS VAR SOCCER"

    if team == "SO GIRLS JV":
        return "GIRLS JV SOCCER"

    if team == "SO GIRLS V":
        return "GIRLS VAR SOCCER"

    if team == "FB GIRLS":
        return "GIRLS FLAG FB"

    if team == "FB BOYS V":
        return "VARSITY FOOTBALL"

    if team == "FB BOYS JV":
        return "JV FOOTBALL"

    if team == "FB BOYS FR":
        return "FRESHMAN FOOTBALL"

    if team == "VB GIRLS V":
        return "VARSITY VOLLEY"

    if team == "VB GIRLS JV":
        return "JV VOLLEYBALL"

    if team == "VB GIRLS FR":
        return "FRESHMAN VOLLEY"

    if team == "CC BOYS":
        return "BOYS XC"

    if team == "CC GIRLS":
        return "GIRLS XC"

    # -------------------------
    # WINTER SPORTS
    # -------------------------

    if team == "BB BOYS V":
        return "BOYS VAR BASKETBALL"

    if team == "BB BOYS JV":
        return "BOYS JV BASKETBALL"

    if team == "BB GIRLS V":
        return "GIRLS VAR BASKETBALL"

    if team == "BB GIRLS JV":
        return "GIRLS JV BASKETBALL"

    if team == "WR BOYS":
        return "BOYS WRESTLING"

    if team == "WR GIRLS":
        return "GIRLS WRESTLING"

    if team == "SW BOYS":
        return "BOYS SWIM & DIVE"

    if team == "SW GIRLS":
        return "GIRLS SWIM & DIVE"

    # -------------------------
    # SPRING SPORTS
    # -------------------------

    if team == "BA BOYS V":
        return "VARSITY BASEBALL"

    if team == "BA BOYS JV":
        return "JV BASEBALL"

    if team == "SB GIRLS V":
        return "VARSITY SOFTBALL"

    if team == "SB GIRLS JV":
        return "JV SOFTBALL"

    if team == "TR BOYS":
        return "BOYS TRACK"

    if team == "TR GIRLS":
        return "GIRLS TRACK"

    if team == "TE GIRLS":
        return "GIRLS TENNIS"

    if team == "GO BOYS":
        return "BOYS GOLF"

    return team


def find_home_away(block):
    visible = strip_tags(block)

    if "(H)" in visible:
        return "HOME"

    if "(A)" in visible:
        return "AWAY"

    return ""


def find_time(block):
    visible = strip_tags(block)

    am = visible.find(" AM")
    pm = visible.find(" PM")

    marker = -1

    if am != -1:
        marker = am

    if pm != -1:
        if marker == -1 or pm < marker:
            marker = pm

    if marker == -1:
        return ""

    start = marker - 6

    if start < 0:
        start = 0

    candidate = visible[start:marker + 3].strip()

    space = candidate.find(" ")

    if space != -1:
        remaining = candidate[space + 1:]

        if ":" in remaining:
            candidate = remaining

    return candidate


def find_opponent(block, raw_team):
    visible = strip_tags(block)

    if visible.startswith(raw_team):
        visible = visible[len(raw_team):].strip()

    home_pos = visible.find("(H)")
    away_pos = visible.find("(A)")

    marker = -1

    if home_pos != -1:
        marker = home_pos

    if away_pos != -1:
        if marker == -1 or away_pos < marker:
            marker = away_pos

    if marker == -1:
        return ""

    opponent = visible[:marker].strip()

    return opponent


def pretty_opponent(opponent):
    opponent = opponent.upper().strip()

    # --------------------------------
    # LAFAYETTE JEFFERSON
    # --------------------------------

    if opponent == "LAFAYETTE JEFFERSON":
        return "LAFAYETTE JEFF"

    if opponent == "LAFAYETTE JEFFERSON HIGH SCHOOL":
        return "LAFAYETTE JEFF"

    if opponent == "LAFAYETTE JEFFERSON HS":
        return "LAFAYETTE JEFF"

    if opponent == "LAFAYETTE JEFF":
        return "LAFAYETTE JEFF"

    # --------------------------------
    # WEST LAFAYETTE
    # --------------------------------

    if opponent == "WEST LAFAYETTE":
        return "WEST LAFAYETTE"

    if opponent == "WEST LAFAYETTE HIGH SCHOOL":
        return "WEST LAFAYETTE"

    if opponent == "WEST LAFAYETTE JR-SR HIGH SCHOOL":
        return "WEST LAFAYETTE"

    if opponent == "WEST LAFAYETTE JR SR HIGH SCHOOL":
        return "WEST LAFAYETTE"

    if opponent == "WEST LAFAYETTE JR-SR HS":
        return "WEST LAFAYETTE"

    # --------------------------------
    # LEBANON
    # --------------------------------

    if opponent == "LEBANON":
        return "LEBANON"

    if opponent == "LEBANON HIGH SCHOOL":
        return "LEBANON"

    if opponent == "LEBANON HS":
        return "LEBANON"

    # --------------------------------
    # DANVILLE
    # --------------------------------

    if opponent == "DANVILLE":
        return "DANVILLE"

    if opponent == "DANVILLE COMMUNITY":
        return "DANVILLE"

    if opponent == "DANVILLE COMMUNITY HIGH SCHOOL":
        return "DANVILLE"

    if opponent == "DANVILLE COMMUNITY HS":
        return "DANVILLE"

    if opponent == "DANVILLE HIGH SCHOOL":
        return "DANVILLE"

    # --------------------------------
    # CRAWFORDSVILLE
    # --------------------------------

    if opponent == "CRAWFORDSVILLE":
        return "CRAWFORDSVILLE"

    if opponent == "CRAWFORDSVILLE HIGH SCHOOL":
        return "CRAWFORDSVILLE"

    if opponent == "CRAWFORDSVILLE HS":
        return "CRAWFORDSVILLE"

    # --------------------------------
    # KOKOMO
    # --------------------------------

    if opponent == "KOKOMO":
        return "KOKOMO"

    if opponent == "KOKOMO HIGH SCHOOL":
        return "KOKOMO"

    if opponent == "KOKOMO HS":
        return "KOKOMO"

    # --------------------------------
    # LOGANSPORT
    # --------------------------------

    if opponent == "LOGANSPORT":
        return "LOGANSPORT"

    if opponent == "LOGANSPORT HIGH SCHOOL":
        return "LOGANSPORT"

    if opponent == "LOGANSPORT HS":
        return "LOGANSPORT"

    # --------------------------------
    # BROWNSBURG
    # --------------------------------

    if opponent == "BROWNSBURG":
        return "BROWNSBURG"

    if opponent == "BROWNSBURG HIGH SCHOOL":
        return "BROWNSBURG"

    if opponent == "BROWNSBURG HS":
        return "BROWNSBURG"

    # --------------------------------
    # FISHERS
    # --------------------------------

    if opponent == "FISHERS":
        return "FISHERS"

    if opponent == "FISHERS HIGH SCHOOL":
        return "FISHERS"

    if opponent == "FISHERS HS":
        return "FISHERS"

    # --------------------------------
    # HAMILTON SOUTHEASTERN
    # --------------------------------

    if opponent == "HAMILTON SOUTHEASTERN":
        return "HSE"

    if opponent == "HAMILTON SOUTHEASTERN HIGH SCHOOL":
        return "HSE"

    if opponent == "HAMILTON SOUTHEASTERN HS":
        return "HSE"

    if opponent == "HSE":
        return "HSE"

    # --------------------------------
    # NOBLESVILLE
    # --------------------------------

    if opponent == "NOBLESVILLE":
        return "NOBLESVILLE"

    if opponent == "NOBLESVILLE HIGH SCHOOL":
        return "NOBLESVILLE"

    if opponent == "NOBLESVILLE HS":
        return "NOBLESVILLE"

    # --------------------------------
    # AVON
    # --------------------------------

    if opponent == "AVON":
        return "AVON"

    if opponent == "AVON HIGH SCHOOL":
        return "AVON"

    if opponent == "AVON HS":
        return "AVON"

    # --------------------------------
    # BISHOP CHATARD
    # --------------------------------

    if opponent == "BISHOP CHATARD":
        return "BISHOP CHATARD"

    if opponent == "BISHOP CHATARD HIGH SCHOOL":
        return "BISHOP CHATARD"

    if opponent == "BISHOP CHATARD HS":
        return "BISHOP CHATARD"

    if opponent == "BISHOP CHATARD TROJANS":
        return "BISHOP CHATARD"

    # --------------------------------
    # PLAINFIELD
    # --------------------------------

    if opponent == "PLAINFIELD":
        return "PLAINFIELD"

    if opponent == "PLAINFIELD HIGH SCHOOL":
        return "PLAINFIELD"

    if opponent == "PLAINFIELD HS":
        return "PLAINFIELD"

    if opponent == "PLAINFIELD QUAKERS":
        return "PLAINFIELD"

    # --------------------------------
    # WESTFIELD
    # --------------------------------

    if opponent == "WESTFIELD":
        return "WESTFIELD"

    if opponent == "WESTFIELD HIGH SCHOOL":
        return "WESTFIELD"

    if opponent == "WESTFIELD HS":
        return "WESTFIELD"

    if opponent == "WESTFIELD SHAMROCKS":
        return "WESTFIELD"

    # --------------------------------
    # CARMEL
    # --------------------------------

    if opponent == "CARMEL":
        return "CARMEL"

    if opponent == "CARMEL HIGH SCHOOL":
        return "CARMEL"

    if opponent == "CARMEL HS":
        return "CARMEL"

    if opponent == "CARMEL GREYHOUNDS":
        return "CARMEL"

    # --------------------------------
    # TERRE HAUTE SOUTH
    # --------------------------------

    if opponent == "TERRE HAUTE SOUTH":
        return "TERRE HAUTE SOUTH"

    if opponent == "TERRE HAUTE SOUTH VIGO":
        return "TERRE HAUTE SOUTH"

    if opponent == "TERRE HAUTE SOUTH VIGO HIGH SCHOOL":
        return "TERRE HAUTE SOUTH"

    if opponent == "TERRE HAUTE SOUTH VIGO HS":
        return "TERRE HAUTE SOUTH"

    if opponent == "TERRE HAUTE SOUTH HIGH SCHOOL":
        return "TERRE HAUTE SOUTH"

    if opponent == "TERRE HAUTE SOUTH HS":
        return "TERRE HAUTE SOUTH"

    if opponent == "TERRE HAUTE SOUTH BRAVES":
        return "TERRE HAUTE SOUTH"

    # --------------------------------
    # TERRE HAUTE NORTH
    # --------------------------------

    if opponent == "TERRE HAUTE NORTH":
        return "TERRE HAUTE NORTH"

    if opponent == "TERRE HAUTE NORTH VIGO":
        return "TERRE HAUTE NORTH"

    if opponent == "TERRE HAUTE NORTH VIGO HIGH SCHOOL":
        return "TERRE HAUTE NORTH"

    if opponent == "TERRE HAUTE NORTH VIGO HS":
        return "TERRE HAUTE NORTH"

    if opponent == "TERRE HAUTE NORTH HIGH SCHOOL":
        return "TERRE HAUTE NORTH"

    if opponent == "TERRE HAUTE NORTH HS":
        return "TERRE HAUTE NORTH"

    if opponent == "TERRE HAUTE NORTH PATRIOTS":
        return "TERRE HAUTE NORTH"

    # --------------------------------
    # LAFAYETTE CENTRAL CATHOLIC
    # --------------------------------

    if opponent == "LAFAYETTE CENTRAL CATHOLIC":
        return "LCC"

    if opponent == "LAFAYETTE CENTRAL CATHOLIC HIGH SCHOOL":
        return "LCC"

    if opponent == "LAFAYETTE CENTRAL CATHOLIC HS":
        return "LCC"

    if opponent == "CENTRAL CATHOLIC":
        return "LCC"

    if opponent == "CENTRAL CATHOLIC HIGH SCHOOL":
        return "LCC"

    if opponent == "LAFAYETTE CENTRAL CATHOLIC KNIGHTS":
        return "LCC"

    if opponent == "LCC":
        return "LCC"

    # --------------------------------
    # BENTON CENTRAL
    # --------------------------------

    if opponent == "BENTON CENTRAL":
        return "BENTON CENTRAL"

    if opponent == "BENTON CENTRAL HIGH SCHOOL":
        return "BENTON CENTRAL"

    if opponent == "BENTON CENTRAL HS":
        return "BENTON CENTRAL"

    if opponent == "BENTON CENTRAL JR-SR HIGH SCHOOL":
        return "BENTON CENTRAL"

    if opponent == "BENTON CENTRAL JR SR HIGH SCHOOL":
        return "BENTON CENTRAL"

    if opponent == "BENTON CENTRAL BISON":
        return "BENTON CENTRAL"

    # --------------------------------
    # BREBEUF JESUIT
    # --------------------------------

    if opponent == "BREBEUF":
        return "BREBEUF"

    if opponent == "BREBEUF JESUIT":
        return "BREBEUF"

    if opponent == "BREBEUF JESUIT PREPARATORY":
        return "BREBEUF"

    if opponent == "BREBEUF JESUIT PREPARATORY SCHOOL":
        return "BREBEUF"

    if opponent == "BREBEUF JESUIT PREP":
        return "BREBEUF"

    if opponent == "BREBEUF JESUIT HIGH SCHOOL":
        return "BREBEUF"

    if opponent == "BREBEUF JESUIT HS":
        return "BREBEUF"

    if opponent == "BREBEUF JESUIT BRAVES":
        return "BREBEUF"

    # --------------------------------
    # NORTH CENTRAL
    # --------------------------------

    if opponent == "NORTH CENTRAL":
        return "NORTH CENTRAL"

    if opponent == "NORTH CENTRAL HIGH SCHOOL":
        return "NORTH CENTRAL"

    if opponent == "NORTH CENTRAL HS":
        return "NORTH CENTRAL"

    if opponent == "NORTH CENTRAL INDIANAPOLIS":
        return "NORTH CENTRAL"

    if opponent == "NORTH CENTRAL PANTHERS":
        return "NORTH CENTRAL"

    # --------------------------------
    # WESTERN BOONE
    # --------------------------------

    if opponent == "WESTERN BOONE":
        return "WESTERN BOONE"

    if opponent == "WESTERN BOONE HIGH SCHOOL":
        return "WESTERN BOONE"

    if opponent == "WESTERN BOONE HS":
        return "WESTERN BOONE"

    if opponent == "WESTERN BOONE JR-SR HIGH SCHOOL":
        return "WESTERN BOONE"

    if opponent == "WESTERN BOONE JR SR HIGH SCHOOL":
        return "WESTERN BOONE"

    if opponent == "WESTERN BOONE STARS":
        return "WESTERN BOONE"

    if opponent == "WEBO":
        return "WESTERN BOONE"

    # --------------------------------
    # TWIN LAKES
    # --------------------------------

    if opponent == "TWIN LAKES":
        return "TWIN LAKES"

    if opponent == "TWIN LAKES HIGH SCHOOL":
        return "TWIN LAKES"

    if opponent == "TWIN LAKES HS":
        return "TWIN LAKES"

    if opponent == "TWIN LAKES SENIOR HIGH SCHOOL":
        return "TWIN LAKES"

    if opponent == "TWIN LAKES INDIANS":
        return "TWIN LAKES"

    # --------------------------------
    # NORTH MONTGOMERY
    # --------------------------------

    if opponent == "NORTH MONTGOMERY":
        return "NORTH MONTGOMERY"

    if opponent == "NORTH MONTGOMERY HIGH SCHOOL":
        return "NORTH MONTGOMERY"

    if opponent == "NORTH MONTGOMERY HS":
        return "NORTH MONTGOMERY"

    if opponent == "NORTH MONTGOMERY CHARGERS":
        return "NORTH MONTGOMERY"

    # --------------------------------
    # MICHIGAN CITY
    # --------------------------------

    if opponent == "MICHIGAN CITY":
        return "MICHIGAN CITY"

    if opponent == "MICHIGAN CITY HIGH SCHOOL":
        return "MICHIGAN CITY"

    if opponent == "MICHIGAN CITY HS":
        return "MICHIGAN CITY"

    if opponent == "MICHIGAN CITY WOLVES":
        return "MICHIGAN CITY"

    return opponent


def center_x(text, center):
    width = len(text) * 6

    return center - (width // 2)


def draw_no_events(c):
    c.clear()

    c.image(
        "harrison-logo.png.png",
        2,
        2,
        w = 28,
        h = 28,
    )

    c.text(
        "HARRISON",
        center_x("HARRISON", 90),
        2,
        font = "5x7",
        color = "orange",
    )

    c.text(
        "NO ATHLETIC",
        center_x("NO ATHLETIC", 90),
        12,
        font = "5x7",
        color = "white",
    )

    c.text(
        "EVENTS TODAY",
        center_x("EVENTS TODAY", 90),
        22,
        font = "5x7",
        color = "orange",
    )


def draw_error(c):
    c.clear()

    c.image(
        "harrison-logo.png.png",
        2,
        2,
        w = 28,
        h = 28,
    )

    c.text(
        "HARRISON",
        center_x("HARRISON", 90),
        2,
        font = "5x7",
        color = "orange",
    )

    c.text(
        "SCHEDULE",
        center_x("SCHEDULE", 90),
        12,
        font = "5x7",
        color = "white",
    )

    c.text(
        "UNAVAILABLE",
        center_x("UNAVAILABLE", 90),
        22,
        font = "5x7",
        color = "red",
    )


def get_opponent_logo(opponent):
    # Any opponent not listed below automatically
    # uses the generic IHSAA logo.
    logo = "ihsaa-logo-28.png.png"

    if opponent == "PIKE":
        logo = "pike-logo-28.png.png"

    if opponent == "ZIONSVILLE":
        logo = "zionsville-logo-28.png.png"

    if opponent == "RONCALLI":
        logo = "roncalli-logo-28.png.png"

    if opponent == "MCCUTCHEON":
        logo = "mccutcheon-logo-28.png.png"

    if opponent == "LAFAYETTE JEFF":
        logo = "lafayette-jeff-logo-28.png.png"

    if opponent == "WEST LAFAYETTE":
        logo = "west-lafayette-logo-28.png.png"

    if opponent == "LEBANON":
        logo = "lebanon-logo-28.png.png"

    if opponent == "DANVILLE":
        logo = "danville-logo-28.png.png"

    if opponent == "CRAWFORDSVILLE":
        logo = "crawfordsville-logo-28.png.png"

    if opponent == "KOKOMO":
        logo = "kokomo-logo-28.png.png"

    if opponent == "LOGANSPORT":
        logo = "logansport-logo-28.png.png"

    if opponent == "BROWNSBURG":
        logo = "brownsburg-logo-28.png.png"

    if opponent == "FISHERS":
        logo = "fishers-logo-28.png.png"

    if opponent == "HSE":
        logo = "hse-logo-28.png.png"

    if opponent == "NOBLESVILLE":
        logo = "noblesville-logo-28.png.png"

    if opponent == "AVON":
        logo = "avon-logo-28.png.png"

    if opponent == "BISHOP CHATARD":
        logo = "bishop-chatard-logo-28.png.png"

    if opponent == "PLAINFIELD":
        logo = "plainfield-logo-28.png.png"

    if opponent == "WESTFIELD":
        logo = "westfield-logo-28.png.png"

    if opponent == "CARMEL":
        logo = "carmel-logo-28.png.png"

    if opponent == "TERRE HAUTE SOUTH":
        logo = "terre-haute-south-logo-28.png.png"

    if opponent == "TERRE HAUTE NORTH":
        logo = "terre-haute-north-logo-28.png.png"

    if opponent == "LCC":
        logo = "lcc-logo-28.png.png"

    if opponent == "BENTON CENTRAL":
        logo = "benton-central-logo-28.png.png"

    if opponent == "BREBEUF":
        logo = "brebeuf-logo-28.png.png"

    if opponent == "NORTH CENTRAL":
        logo = "north-central-logo-28.png.png"

    if opponent == "WESTERN BOONE":
        logo = "western-boone-logo-28.png.png"

    if opponent == "TWIN LAKES":
        logo = "twin-lakes-logo-28.png.png"

    if opponent == "NORTH MONTGOMERY":
        logo = "north-montgomery-logo-28.png.png"

    if opponent == "MICHIGAN CITY":
        logo = "michigan-city-logo-28.png.png"

    return logo


def draw_event(c, block, offset):
    raw_team = get_team(block)
    team = pretty_team(raw_team)

    opponent = find_opponent(block, raw_team)
    opponent = pretty_opponent(opponent)

    event_time = find_time(block)
    home_away = find_home_away(block)

    if opponent == "":
        opponent = "OPPONENT TBD"

    bottom = event_time

    if home_away != "":
        if bottom != "":
            bottom = bottom + "  " + home_away
        else:
            bottom = home_away

    text_center = offset + 90

    c.image(
        "harrison-logo.png.png",
        offset + 2,
        2,
        w = 28,
        h = 28,
    )

    c.text(
        team,
        center_x(team, text_center),
        2,
        font = "5x7",
        color = "orange",
    )

    opponent_display = fit_card_text(opponent)

    c.text(
        opponent_display["text"],
        center_card_text(opponent_display["text"], text_center, opponent_display["font"]),
        12,
        font = opponent_display["font"],
        color = "white",
    )

    c.text(
        bottom,
        center_x(bottom, text_center) + 2,
        22,
        font = "5x7",
        color = "orange",
    )

    opponent_logo = get_opponent_logo(opponent)

    c.image(
        opponent_logo,
        offset + 150,
        2,
        w = 28,
        h = 28,
    )



# ============================================================
# V2 TWO-PAGE PROOF
# Page 1: newest two legitimate structured results
# Page 2: first two of today's events
# ============================================================

CACHE_SECONDS = 21600

RESULT_TEAMS = [
    {
        "team": "VARSITY VOLLEY",
        "url": "https://www.harrisonathletics.com/Team/4b009075-965e-4607-93bb-dee0ddb5d54a/VB%20Girls%20V",
    },
    {
        "team": "BOYS VAR SOCCER",
        "url": "https://www.harrisonathletics.com/Team/08cdd129-fbf6-4e1f-a78f-eb72b855d496/SO%20Boys%20V",
    },
    {
        "team": "GIRLS VAR SOCCER",
        "url": "https://www.harrisonathletics.com/Team/cdf8fa21-502f-4345-8f17-feca2f0ab0dc/SO%20Girls%20V",
    },
    {
        "team": "BOYS TENNIS",
        "url": "https://www.harrisonathletics.com/Team/f0768982-3c08-41ed-9ccf-1827e7c3b7b8/TE%20Boys",
    },
    {
        "team": "GIRLS GOLF",
        "url": "https://www.harrisonathletics.com/Team/6eb1d39e-85a0-4292-951f-3471cf723d4d/GO%20Girls",
    },
    {
        "team": "JV FOOTBALL",
        "url": "https://www.harrisonathletics.com/Team/cbb297c3-9400-44b2-bedd-0e622f1c8b75/FB%20Boys%20JV",
    },
    {
        "team": "FRESHMAN FOOTBALL",
        "url": "https://www.harrisonathletics.com/Team/01a0774c-f53e-482d-95cc-258d65f29fd2/FB%20Boys%20FR",
    },
]


def month_number(name):
    name = name.upper()

    if name == "JAN":
        return 1
    if name == "FEB":
        return 2
    if name == "MAR":
        return 3
    if name == "APR":
        return 4
    if name == "MAY":
        return 5
    if name == "JUN":
        return 6
    if name == "JUL":
        return 7
    if name == "AUG":
        return 8
    if name == "SEP":
        return 9
    if name == "OCT":
        return 10
    if name == "NOV":
        return 11
    if name == "DEC":
        return 12

    return 0


def date_value(year, month, day):
    return year * 372 + month * 31 + day


def parse_date_value(text):
    visible = clean_text(text)
    comma = visible.find(",")

    if comma == -1:
        return 0

    rest = visible[comma + 1:].strip()
    first_space = rest.find(" ")

    if first_space == -1:
        return 0

    month_text = rest[:first_space].replace(".", "")
    month = month_number(month_text)

    if month == 0:
        return 0

    rest = rest[first_space + 1:].strip()
    second_space = rest.find(" ")

    if second_space == -1:
        return 0

    day = int(rest[:second_space])
    rest = rest[second_space + 1:].strip()
    third_space = rest.find(" ")

    if third_space == -1:
        year = int(rest)
    else:
        year = int(rest[:third_space])

    return date_value(year, month, day)


def table_rows(body):
    upper = body.upper()
    marker = upper.find("SEASON SCORES")

    if marker == -1:
        return []

    table_start = upper.find("<TABLE", marker)

    if table_start == -1:
        return []

    table_end = upper.find("</TABLE>", table_start)

    if table_end == -1:
        return []

    table = body[table_start:table_end]
    table_upper = table.upper()
    rows = []
    cursor = 0

    for i in range(80):
        start = table_upper.find("<TR", cursor)

        if start == -1:
            break

        open_end = table.find(">", start)
        end = table_upper.find("</TR>", open_end)

        if open_end == -1 or end == -1:
            break

        rows.append(table[open_end + 1:end])
        cursor = end + 5

    return rows


def row_cells(row):
    cells = []
    cursor = 0
    upper = row.upper()

    for i in range(6):
        td = upper.find("<TD", cursor)

        if td == -1:
            break

        open_end = row.find(">", td)
        end = upper.find("</TD>", open_end)

        if open_end == -1 or end == -1:
            break

        cells.append(strip_tags(row[open_end + 1:end]))
        cursor = end + 5

    return cells


def result_outcome(score):
    # Harrison's site publishes score and outcome from Harrison's
    # perspective regardless of home/away. Do not reverse anything.
    upper = clean_text(score).upper()

    if upper.find("(WIN)") != -1:
        return "W"

    if upper.find("(LOSS)") != -1:
        return "L"

    if upper.find("(TIE)") != -1:
        return "T"

    return ""


def clean_result_score(score):
    text = clean_text(score)

    positions = [
        text.upper().find("(WIN)"),
        text.upper().find("(LOSS)"),
        text.upper().find("(TIE)"),
    ]

    cut = -1

    for pos in positions:
        if pos != -1:
            if cut == -1 or pos < cut:
                cut = pos

    if cut != -1:
        text = text[:cut].strip()

    return text


def result_opponent(event_text):
    text = clean_text(event_text)

    if text.upper().startswith("CANCELED:"):
        return ""

    home = text.find("(H)")
    away = text.find("(A)")
    cut = -1

    if home != -1:
        cut = home

    if away != -1:
        if cut == -1 or away < cut:
            cut = away

    if cut != -1:
        text = text[:cut].strip()

    return pretty_opponent(text)


def format_result_team(raw_team):
    text = clean_text(raw_team)

    # Compact display names for common Eventlink labels.
    if text == "G V Volleyball":
        return "VARSITY VOLLEY"
    if text == "B V Soccer":
        return "BOYS VAR SOCCER"
    if text == "G V Soccer":
        return "GIRLS VAR SOCCER"

    if text.startswith("B V "):
        return "BOYS VAR " + text[4:].upper()
    if text.startswith("G V "):
        return "GIRLS VAR " + text[4:].upper()
    if text.startswith("B JV "):
        return "BOYS JV " + text[5:].upper()
    if text.startswith("G JV "):
        return "GIRLS JV " + text[5:].upper()
    if text.startswith("B F "):
        return "BOYS FRESH " + text[4:].upper()
    if text.startswith("G F "):
        return "GIRLS FRESH " + text[4:].upper()
    if text.startswith("V "):
        return "VARSITY " + text[2:].upper()
    if text.startswith("JV "):
        return "JV " + text[3:].upper()
    if text.startswith("F "):
        return "FRESHMAN " + text[2:].upper()

    return text.upper()


def insert_result(results, item):
    placed = False

    for i in range(len(results)):
        if item["date"] > results[i]["date"]:
            results.insert(i, item)
            placed = True
            break

    if not placed:
        results.append(item)



def collect_recent_results(ctx):
    results = []
    today = date_value(ctx.now.year, ctx.now.month, ctx.now.day)
    oldest = today - 7

    # Use Harrison's Events feed instead of seven separate team-page requests.
    body = get_schedule_for_range(
        shift_date(ctx.now.year, ctx.now.month, ctx.now.day, -8),
        today_text(ctx),
    )

    if body == "":
        return results

    marker = 'class="score-ticker-card score-ticker-border"'
    cursor = 0

    for i in range(100):
        start = body.find(marker, cursor)
        if start == -1:
            break

        next_start = body.find(marker, start + len(marker))
        if next_start == -1:
            card = body[start:]
            cursor = len(body)
        else:
            card = body[start:next_start]
            cursor = next_start

        header_marker = 'score-ticker-card-header backgroundColor col-auto">'
        h1 = card.find(header_marker)
        if h1 == -1:
            continue
        h1 = h1 + len(header_marker)
        h2 = card.find("</span>", h1)
        if h2 == -1:
            continue

        date_text = clean_text(card[h1:h2])
        date_parts = date_text.split()
        if len(date_parts) < 2:
            continue

        month = month_number(date_parts[0][:3])
        if month == 0:
            continue

        day = int(date_parts[1])
        year = ctx.now.year
        if ctx.now.month == 1 and month == 12:
            year = year - 1

        dv = date_value(year, month, day)
        if dv > today:
            continue

        h3 = card.find(header_marker, h2)
        if h3 == -1:
            continue
        h3 = h3 + len(header_marker)
        h4 = card.find("</span>", h3)
        if h4 == -1:
            continue
        raw_team = clean_text(card[h3:h4])

        participant_marker = 'score-ticker-card-participant-text text-light">'
        p1 = card.find(participant_marker)
        if p1 == -1:
            continue
        p1 = p1 + len(participant_marker)
        p1_end = card.find("</span>", p1)
        if p1_end == -1:
            continue
        name1 = clean_text(card[p1:p1_end])

        p2 = card.find(participant_marker, p1_end)
        if p2 == -1:
            continue
        p2 = p2 + len(participant_marker)
        p2_end = card.find("</span>", p2)
        if p2_end == -1:
            continue
        name2 = clean_text(card[p2:p2_end])

        score_marker = 'score-ticker-card-score-container text-light">'
        s1 = card.find(score_marker)
        if s1 == -1:
            continue
        s1 = s1 + len(score_marker)
        s1_end = card.find("</div>", s1)
        if s1_end == -1:
            continue
        score1 = clean_text(card[s1:s1_end])

        s2 = card.find(score_marker, s1_end)
        if s2 == -1:
            continue
        s2 = s2 + len(score_marker)
        s2_end = card.find("</div>", s2)
        if s2_end == -1:
            continue
        score2 = clean_text(card[s2:s2_end])

        if score1 == "" or score2 == "":
            continue

        if "Harrison" in name1:
            opponent = name2
            our_score = score1
            their_score = score2
        elif "Harrison" in name2:
            opponent = name1
            our_score = score2
            their_score = score1
        else:
            continue

        opponent = pretty_opponent(opponent)

        our_score_num = int(our_score)
        their_score_num = int(their_score)

        if our_score_num > their_score_num:
            outcome = "W"
        elif our_score_num < their_score_num:
            outcome = "L"
        else:
            outcome = "T"

        team = format_result_team(raw_team)

        duplicate = False
        for existing in results:
            if existing["team"] == team and existing["opponent"] == opponent and existing["date"] == dv:
                duplicate = True
                break

        if duplicate:
            continue

        insert_result(
            results,
            {
                "team": team,
                "opponent": opponent,
                "score": our_score + " - " + their_score,
                "outcome": outcome,
                "date": dv,
            },
        )

    # Prefer a tight 3-day results window. If fewer than 4 results are
    # available, expand backward one whole day at a time, up to 7 days.
    # Every result on an included date is kept; no program is filtered out.
    lookback = 3
    for extra_day in range(12):
        lookback = 3 + extra_day
        cutoff = today - lookback
        count = 0
        for result in results:
            if result["date"] >= cutoff:
                count = count + 1
        if count >= 4:
            break

    cutoff = today - lookback
    selected = []
    for result in results:
        if result["date"] >= cutoff:
            selected.append(result)

    return selected

def fit_card_text(text):
    if len(text) <= 18:
        return {"text": text, "font": "5x7"}
    if len(text) <= 23:
        return {"text": text, "font": "4x5"}
    return {"text": text[:22], "font": "4x5"}


def center_card_text(text, center, font):
    # Existing center_x() is tuned for 5x7. 4x5 characters are
    # narrower, so use their actual 5-pixel advance here.
    if font == "4x5":
        return center - ((len(text) * 5) // 2)

    return center_x(text, center)


def draw_result(c, result, offset):
    team = result["team"]
    opponent = result["opponent"]
    bottom = result["outcome"] + "  " + result["score"]
    text_center = offset + 90

    c.image(
        "harrison-logo.png.png",
        offset + 2,
        2,
        w = 28,
        h = 28,
    )

    c.text(
        team,
        center_x(team, text_center),
        2,
        font = "5x7",
        color = "orange",
    )

    opponent_display = fit_card_text(opponent)

    c.text(
        opponent_display["text"],
        center_card_text(opponent_display["text"], text_center, opponent_display["font"]),
        12,
        font = opponent_display["font"],
        color = "white",
    )

    c.text(
        bottom,
        center_x(bottom, text_center) + 2,
        22,
        font = "5x7",
        color = "orange",
    )

    c.image(
        get_opponent_logo(opponent),
        offset + 150,
        2,
        w = 28,
        h = 28,
    )


def pad2(value):
    text = str(value)
    if len(text) == 1:
        return "0" + text
    return text


def days_in_month(year, month):
    if month == 2:
        if year % 400 == 0:
            return 29
        if year % 100 == 0:
            return 28
        if year % 4 == 0:
            return 29
        return 28
    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30
    return 31


def shift_date(year, month, day, amount):
    y = year
    m = month
    d = day

    for i in range(amount):
        d = d + 1
        if d > days_in_month(y, m):
            d = 1
            m = m + 1
            if m > 12:
                m = 1
                y = y + 1

    return str(y) + "-" + pad2(m) + "-" + pad2(d)


def get_schedule_for_range(from_text, to_text):
    response = http.get(
        URL,
        params = {"from": from_text, "to": to_text},
        ttl_seconds = 60,
    )

    if response["status_code"] != 200:
        return ""

    return response["body"]


def block_date_text(block, fallback):
    # Each event row carries its date as "Thu, Sep. 24 2026".
    # Returns YYYY-MM-DD, or fallback if the row can't be read.
    marker = '<p class="m-0">'
    start = block.find(marker)

    if start == -1:
        return fallback

    start = start + len(marker)
    end = block.find("</p>", start)

    if end == -1:
        return fallback

    value = parse_date_value(block[start:end])

    if value == 0:
        return fallback

    parts = clean_text(block[start:end]).replace(",", " ").replace(".", " ").split()

    if len(parts) < 4:
        return fallback

    month = month_number(parts[1])

    if month == 0:
        return fallback

    return parts[3] + "-" + pad2(month) + "-" + pad2(int(parts[2]))


def collect_upcoming_events(ctx):
    events = []
    today = today_text(ctx)

    body = get_schedule(ctx)
    if body == "":
        return events

    for block in find_event_blocks(body):
        date_text = block_date_text(block, today)
        if date_text > today and len(events) < 16:
            events.append({
                "block": block,
                "date": str(ctx.now.month) + "/" + str(ctx.now.day),
                "date_text": date_text,
            })

    return events


def compact_date(date_text):
    # Input is YYYY-MM-DD.
    month = date_text[5:7]
    day = date_text[8:10]

    if month[0:1] == "0":
        month = month[1:2]

    if day[0:1] == "0":
        day = day[1:2]

    return month + "/" + day


def draw_upcoming_event(c, block, date_text, offset):
    raw_team = get_team(block)
    team = pretty_team(raw_team)
    opponent = pretty_opponent(find_opponent(block, raw_team))
    time_text = find_time(block)
    home_away = find_home_away(block)
    date_text = compact_date(date_text)
    text_center = offset + 90
    opponent_display = fit_card_text(opponent)

    c.image("harrison-logo.png.png", offset + 2, 2, w = 28, h = 28)

    c.text(
        team,
        center_x(team, text_center),
        2,
        font = "5x7",
        color = "orange",
    )

    c.text(
        opponent_display["text"],
        center_card_text(opponent_display["text"], text_center, opponent_display["font"]),
        12,
        font = opponent_display["font"],
        color = "white",
    )

    bottom = date_text + "  " + time_text
    if home_away != "":
        bottom = bottom + " " + home_away

    c.text(
        bottom,
        center_x(bottom, text_center) + 2,
        22,
        font = "5x7",
        color = "orange",
    )

    c.image(get_opponent_logo(opponent), offset + 150, 2, w = 28, h = 28)


def collect_today_events(ctx):
    today = today_text(ctx)
    body = get_schedule(ctx)
    if body == "":
        return []
    return [b for b in find_event_blocks(body) if block_date_text(b, today) == today]


def draw_dynamic_page(c, ctx, page_number):
    # Fill the fixed physical page slots from one protected logical stream:
    # recent finals -> today's events -> upcoming events.
    # A later section can never displace an earlier real item.
    # Fetches are intentionally short-circuited so early pages do not
    # request future schedules until they are actually needed.
    first = page_number * 2
    second = first + 1

    results = collect_recent_results(ctx)

    c.clear()

    # If this page is fully inside Recent Results, draw it and stop.
    if second < len(results):
        draw_result(c, results[first], 0)
        draw_result(c, results[second], 180)
        c.line(179, 1, 179, 30, color = "white")
        c.line(359, 1, 359, 30, color = "white")
        return

    today = collect_today_events(ctx)
    result_count = len(results)
    today_count = len(today)

    # Only collect future events when this page reaches beyond Results + Today.
    upcoming = []
    if second >= result_count + today_count:
        upcoming = collect_upcoming_events(ctx)

    for side in range(2):
        index = first + side
        offset = side * 180

        if index < result_count:
            draw_result(c, results[index], offset)
        elif index < result_count + today_count:
            draw_event(c, today[index - result_count], offset)
        else:
            future_index = index - result_count - today_count
            if future_index < len(upcoming):
                item = upcoming[future_index]
                draw_upcoming_event(c, item["block"], item["date_text"], offset)
            else:
                # Never repeat an event just to fill a slot.
                # If the real data stream is exhausted, show a neutral
                # Harrison card rather than a misleading duplicate.
                c.image("harrison-logo.png.png", offset + 2, 2, w = 28, h = 28)
                c.text(
                    "HARRISON ATHLETICS",
                    center_x("HARRISON ATHLETICS", offset + 105),
                    7,
                    font = "5x7",
                    color = "orange",
                )
                c.text(
                    "RAIDER UP",
                    center_x("RAIDER UP", offset + 105),
                    17,
                    font = "5x7",
                    color = "white",
                )

    c.line(179, 1, 179, 30, color = "white")
    c.line(359, 1, 359, 30, color = "white")


def page_1(c, ctx):
    draw_dynamic_page(c, ctx, 0)


def page_2(c, ctx):
    draw_dynamic_page(c, ctx, 1)


def page_3(c, ctx):
    draw_dynamic_page(c, ctx, 2)


def page_4(c, ctx):
    draw_dynamic_page(c, ctx, 3)


def page_5(c, ctx):
    draw_dynamic_page(c, ctx, 4)


def page_6(c, ctx):
    draw_dynamic_page(c, ctx, 5)


def page_7(c, ctx):
    draw_dynamic_page(c, ctx, 6)


def page_8(c, ctx):
    draw_dynamic_page(c, ctx, 7)
