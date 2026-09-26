def main(c, ctx):
    c.fill("black")

    team_url = ctx.inputs.get(
        "teamurl",
        "https://www.maxpreps.com/oh/elyria/elyria-catholic-panthers/soccer/girls/"
    )

    resp = http.get(
        team_url + "schedule/",
        ttl_seconds=900
    )

    if resp["status_code"] != 200:
        c.text_center("FINAL", 1,
            font="4x5", color="green")
        c.text_center("NO DATA", 14,
            font="5x7", color="white")
        return

    body = resp["body"]

    # Find the most recent completed game
    pos = body.rfind('aria-label="W ')
    pos_l = body.rfind('aria-label="L ')
    pos_t = body.rfind('aria-label="T ')

    if pos_l > pos:
        pos = pos_l
    if pos_t > pos:
        pos = pos_t

    if pos < 0:
        c.text_center("FINAL", 1,
            font="4x5", color="green")
        c.text_center("NO SCORE", 14,
            font="5x7", color="white")
        return

    start = pos + len('aria-label="')
    end = body.find('"', start)
    result = body[start:end]

    # result example:
    # W 3-1 at Vermilion, 9/14

    first_space = result.find(" ")
    score_start = first_space + 1
    score_end = result.find(" ", score_start)
    score = result[score_start:score_end]

    location_start = score_end + 1

    if result[location_start:location_start + 3] == "at ":
        opponent_start = location_start + 3
    elif result[location_start:location_start + 3] == "vs ":
        opponent_start = location_start + 3
    else:
        opponent_start = location_start

    opponent_end = result.find(",", opponent_start)
    opponent = result[opponent_start:opponent_end]

    dash = score.find("-")
    ec_score = score[:dash]
    opp_score = score[dash + 1:]

    # Shorten names for the 64px display
    if opponent == "Notre Dame-Cathedral Latin":
        opponent = "NDCL"
    elif opponent == "Open Door Christian":
        opponent = "OPEN DOOR"
    elif opponent == "Lake Catholic":
        opponent = "LAKE"
    elif opponent == "Padua Franciscan":
        opponent = "PADUA"
    elif opponent == "Lutheran West":
        opponent = "LUTHERAN"
    elif opponent == "Cuyahoga Valley Christian Academy":
        opponent = "CVCA"
    elif opponent == "Beaumont School":
        opponent = "BEAUMONT"
    else:
        opponent = opponent.upper()

    c.text_center("FINAL", 1,
        font="4x5", color="green")
    team_abbr = ctx.inputs.get("teamabbr", "EC").upper()    
    c.text(team_abbr, 2, 9,
        font="5x7", color="white")
    c.text(ec_score, 51, 7,
        font="7x10", color="green")

    c.text(opponent, 2, 22,
        font="4x5", color="white")
    c.text(opp_score, 51, 21,
        font="7x10", color="white")



def season_record(c, ctx):
    c.fill("black")

    team_url = ctx.inputs.get(
        "teamurl",
        "https://www.maxpreps.com/oh/elyria/elyria-catholic-panthers/soccer/girls/"
    )
    team_abbr = ctx.inputs.get("teamabbr", "EC").upper()

    resp = http.get(
        team_url,
        ttl_seconds=900
    )
    if resp["status_code"] != 200:
        c.text_center(team_abbr + " SOCCER", 1,
            font="4x5", color="green")
        c.text_center("NO DATA", 12,
            font="5x7", color="white")
        return

    body = resp["body"]

    pos = body.find("Overall</div>")

    if pos >= 0:
        data_pos = body.find('<div class="data">', pos)
        start = data_pos + len('<div class="data">')
        end = body.find("</div>", start)
        record = body[start:end]
        record = record.replace("-", " - ")
    else:
        record = "NO DATA"

    c.text_center(team_abbr + " SOCCER", 1,
        font="4x5", color="green")

    c.text_center(record, 9,
        font="7x10", color="white")

    c.text_center("SEASON RECORD", 23,
        font="4x5", color="green")

def team_logo(c, ctx):
    c.fill("black")
    team_abbr = ctx.inputs.get("teamabbr", "TEAM").upper()

    c.text_center(team_abbr, 6,
        font="7x10", color="green")

    c.text_center("SOCCER", 20,
        font="5x7", color="white")
def next_game(c, ctx):
    c.fill("black")
    team_url = ctx.inputs.get(
        "teamurl",
        "https://www.maxpreps.com/oh/elyria/elyria-catholic-panthers/soccer/girls/"
    )
    team_abbr = ctx.inputs.get("teamabbr", "EC").upper()

    resp = http.get(
        team_url + "schedule/",
        ttl_seconds=900
    )
    if resp["status_code"] != 200:
        c.text_center("NEXT GAME", 1,
            font="4x5", color="green")
        c.text_center("NO DATA", 14,
            font="5x7", color="white")
        return

    body = resp["body"]
    now = ctx.now
    month = now.month
    day = now.day

    # Start with the first schedule row
    search_pos = body.find('aria-label="')

    found = False
    date_text = ""
    game_time = ""
    location = ""
    opponent = ""

    for scan in range(100):
        start = search_pos + len('aria-label="')
        end = body.find('"', start)

        if end < 0:
            break

        label = body[start:end]

        # Schedule rows begin with a date like 9/28 or 10/8
        slash = label.find("/")

        if slash > 0 and slash <= 2:
            space = label.find(" ")

            if space > slash:
                m_text = label[:slash]
                d_text = label[slash + 1:space]

                m = int(m_text)
                d = int(d_text)

                if m > month or (m == month and d >= day):
                    rest = label[space + 1:]

                    vs_pos = rest.find(" vs ")
                    at_pos = rest.find(" at ")

                    marker_pos = -1
                    marker = ""

                    if vs_pos >= 0:
                        marker_pos = vs_pos
                        marker = "VS"
                    elif at_pos >= 0:
                        marker_pos = at_pos
                        marker = "@"

                    if marker_pos >= 0:
                        game_time = rest[:marker_pos]

                        if marker == "VS":
                            opponent = rest[marker_pos + 4:]
                        else:
                            opponent = rest[marker_pos + 4:]

                        date_text = m_text + "/" + d_text
                        location = marker
                        found = True
                        break

        search_pos = body.find('aria-label="', end)

    if not found:
        c.text_center("SEASON", 7,
            font="5x7", color="green")
        c.text_center("COMPLETE", 18,
            font="5x7", color="white")
        return

    # Short names for 64x32
    if opponent == "Lake Catholic":
        opponent = "LAKE"
    elif opponent == "Cuyahoga Valley Christian Academy":
        opponent = "CVCA"
    elif opponent == "Padua Franciscan":
        opponent = "PADUA"
    elif opponent == "Lutheran West":
        opponent = "LUTHERAN"
    elif opponent == "Notre Dame-Cathedral Latin":
        opponent = "NDCL"
    elif opponent == "Beaumont School":
        opponent = "BEAUMONT"
    else:
        opponent = opponent.upper()

    game_time = game_time.upper()
    game_time = game_time.replace("PM", " PM")
    game_time = game_time.replace("AM", " AM")

    c.text_center("NEXT GAME", 1,
        font="4x5", color="green")

    c.text_center(location + " " + opponent, 9,
        font="4x5", color="white")

    c.text_center(date_text, 18,
        font="4x5", color="white")

    c.text_center(game_time, 26,
        font="4x5", color="green")