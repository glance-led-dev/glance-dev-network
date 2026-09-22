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


def get_schedule(ctx):
    year = str(ctx.now.year)

    month = str(ctx.now.month)
    if len(month) == 1:
        month = "0" + month

    day = str(ctx.now.day)
    if len(day) == 1:
        day = "0" + day

    date = year + "-" + month + "-" + day

    response = http.get(
        URL,
        params = {
            "from": date,
            "to": date,
        },
        ttl_seconds = 60,
    )

    if response["status_code"] != 200:
        return ""

    return response["body"]


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

    c.text(
        opponent,
        center_x(opponent, text_center),
        12,
        font = "5x7",
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


def main(c, ctx):
    body = get_schedule(ctx)

    if body == "":
        draw_error(c)
        return

    blocks = find_event_blocks(body)

    if len(blocks) == 0:
        draw_no_events(c)
        return

    c.clear()

    pair_count = (len(blocks) + 1) // 2
    pair_number = (ctx.now.unix // 60) % pair_count

    first_event = pair_number * 2
    second_event = first_event + 1

    draw_event(
        c,
        blocks[first_event],
        0,
    )

    if second_event < len(blocks):
        draw_event(
            c,
            blocks[second_event],
            180,
        )

    c.line(
        179,
        1,
        179,
        30,
        color = "white",
    )

    c.line(
        359,
        1,
        359,
        30,
        color = "white",
    )