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
            if current != "":
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
        c.text_center("SETUP", 12, font="6x8", color="red")
        return
    title = deck.get("title", "STUDY DECK")
    lines = wrap_text(title, 10)
    total = len(lines[:4])
    y = (32 - total * 8) // 2
    for line in lines[:4]:
        c.text_center(line, y, font="4x7", color="amber")
        y += 8

def split_long_word(word, chunk_size):
    if len(word) <= chunk_size:
        return [word]
    mid = len(word) // 2
    return [word[:mid] + "-", word[mid:]]

def term(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        c.text_center("SETUP", 12, font="6x8", color="red")
        return
    terms = deck.get("terms", [])
    if len(terms) == 0:
        return

    idx = current_index(ctx, len(terms))
    t = terms[idx]["term"]
    words = t.replace("/", " / ").split(" ")

    lines = []
    for w in words:
        lines.extend(split_long_word(w, 8))

    lines = lines[:4]
    total = len(lines)
    h = 9 if total <= 2 else 7
    font = "5x7" if total <= 2 else "4x5"

    y = (32 - total * h) // 2
    for line in lines:
        c.text_center(line, y, font=font, color="cyan")
        y += h

def fullname(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        return
    terms = deck.get("terms", [])
    if len(terms) == 0:
        return

    idx = current_index(ctx, len(terms))
    entry = terms[idx]
    full = entry.get("fullname", "")

    if full == "":
        c.text_center("N/A", 12, font="6x8", color="gray")
        return

    words = full.replace(",", "").split(" ")[:4]

    rendered = []
    total_height = 0
    for w in words:
        if len(w) <= 8:
            font, h = "5x7", 9
        else:
            font, h = "4x5", 7
        rendered.append((w, font, h))
        total_height += h

    y = (32 - total_height) // 2
    for w, font, h in rendered:
        c.text_center(w, y, font=font, color="gray")
        y += h