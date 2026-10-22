def fetch_data(ctx):
    domain = ctx.inputs.get("deckurl", "").strip()
    if not domain:
        return None
    if domain.startswith("https://"):
        domain = domain[len("https://"):]
    resp = http.get("https://" + domain, ttl_seconds=3600)
    if resp["status_code"] != 200:
        return None
    data = resp["json"]

    # Accept either a bare array of cards or {"title": ..., "terms": [...]}
    if type(data) == "list":
        return {"title": "STUDY DECK", "terms": clean_terms(data)}
    if type(data) == "dict":
        return {"title": str(data.get("title", "STUDY DECK")), "terms": clean_terms(data.get("terms", []))}
    return None

def clean_terms(items):
    if type(items) != "list":
        return []
    out = []
    for item in items:
        if type(item) == "dict" and item.get("term") and item.get("definition"):
            out.append(item)
    return out

def current_index(ctx, count):
    return (ctx.now.unix // 300) % count

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

def setup_needed(c):
    c.text_center("SETUP NEEDED", 12, font="6x8", color="red")

def no_terms(c):
    c.text_center("NO TERMS", 12, font="6x8", color="red")

def subject(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        setup_needed(c)
        return

    lines = wrap_text(deck["title"].upper(), 16)
    total = len(lines[:3])
    y = (32 - total * 10) // 2
    for line in lines[:3]:
        c.text_center(line, y, font="6x8", color="amber")
        y += 10

def term(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        setup_needed(c)
        return

    terms = deck["terms"]
    if len(terms) == 0:
        no_terms(c)
        return

    idx = current_index(ctx, len(terms))
    entry = terms[idx]
    name = str(entry["term"]).upper()
    full = str(entry.get("fullname", "")).upper()

    if full == "":
        c.text_center(name, 10, font="7x12", color="cyan")
    else:
        c.text_center(name, 4, font="7x12", color="cyan")
        lines = wrap_text(full, 22)
        y = 20
        for line in lines[:2]:
            c.text_center(line, y, font="4x5", color="gray")
            y += 6

def definition(c, ctx):
    c.clear()
    deck = fetch_data(ctx)
    if deck == None:
        setup_needed(c)
        return

    terms = deck["terms"]
    if len(terms) == 0:
        no_terms(c)
        return

    idx = current_index(ctx, len(terms))
    entry = terms[idx]
    lines = wrap_text(str(entry["definition"]).upper(), 22)

    shown = lines[:5]
    if len(lines) > 5:
        shown[4] = shown[4][:19] + "..."

    total = len(shown)
    y = (32 - total * 6) // 2
    for line in shown:
        c.text_center(line, y, font="4x5", color="white")
        y += 6
