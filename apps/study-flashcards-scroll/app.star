def fetch_data(ctx):
    domain = ctx.inputs.get("deckurl", "")
    if not domain:
        return None
    resp = http.get("https://" + domain)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def current_index(ctx, count):
    return (ctx.now.unix // 60) % count

def wrap_text(text, max_chars):
    words = text.split(" ")
    lines = []
    current = ""
    for w in words:
        candidate = current + " " + w if current != "" else w
        if len(candidate) > max_chars:
            lines.append(current)
            current = w
        else:
            current = candidate
    if current != "":
        lines.append(current)
    return lines

def subject(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        c.text_center("SETUP NEEDED", 12, font="6x8", color="red")
        return

    title = deck.get("title", "STUDY DECK")
    lines = wrap_text(title, 16)
    total = len(lines[:3])
    y = (32 - total * 10) // 2
    for line in lines[:3]:
        c.text_center(line, y, font="6x8", color="amber")
        y += 10

def term(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        c.text_center("SETUP NEEDED", 12, font="6x8", color="red")
        return

    terms = deck.get("terms", [])
    if len(terms) == 0:
        c.text_center("NO TERMS", 12, font="6x8", color="red")
        return

    idx = current_index(ctx, len(terms))
    entry = terms[idx]
    full = entry.get("fullname", "")

    if full == "":
        c.text_center(entry["term"], 12, font="8x12", color="cyan")
    else:
        c.text_center(entry["term"], 4, font="8x12", color="cyan")
        lines = wrap_text(full, 22)
        y = 20
        for line in lines[:2]:
            c.text_center(line, y, font="4x5", color="gray")
            y += 6

def definition(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        c.text_center("SETUP NEEDED", 12, font="6x8", color="red")
        return

    terms = deck.get("terms", [])
    if len(terms) == 0:
        return

    idx = current_index(ctx, len(terms))
    entry = terms[idx]
    lines = wrap_text(entry["definition"], 22)

    shown = lines[:5]
    if len(lines) > 5:
        shown[4] = shown[4][:19] + "..."

    total = len(shown)
    y = (32 - total * 6) // 2
    for line in shown:
        c.text_center(line, y, font="4x5", color="white")
        y += 6