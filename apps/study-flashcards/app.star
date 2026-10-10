REFRESH = 300

# Shown when no deck URL is set, labelled DEMO on every page.
DEMO_TITLE = "WEB ACRONYMS"
DEMO_TERMS = [
    {"term": "HTTP", "fullname": "Hypertext Transfer Protocol"},
    {"term": "DNS", "fullname": "Domain Name System"},
    {"term": "CSS", "fullname": "Cascading Style Sheets"},
    {"term": "API", "fullname": "Application Programming Interface"},
    {"term": "JSON", "fullname": "JavaScript Object Notation"},
    {"term": "URL", "fullname": "Uniform Resource Locator"},
    {"term": "SQL", "fullname": "Structured Query Language"},
    {"term": "Latency", "definition": "Delay before data starts to arrive"},
]

FONT_H = {"10x14": 14, "8x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}
HERO_FONTS = ["10x14", "8x12", "6x8", "5x7", "4x5"]
BODY_FONTS = ["6x8", "5x7", "4x5"]

COVER_EDGE = "#6B4F00"
FRONT_EDGE = "#0A5A5A"
BACK_EDGE = "#3C3C46"
DIM = "#6A7090"

def clean(s, limit):
    return " ".join(str(s).upper().split(" "))[:limit].strip()

def parse_cards(raw):
    cards = []
    for e in raw[:500]:
        if type(e) != "dict":
            continue
        t = clean(e.get("term", ""), 40)
        if t == "":
            continue
        back = e.get("fullname", "") or e.get("definition", "") or ""
        cards.append({"term": t, "back": clean(back, 90)})
    return cards

def load_deck(ctx):
    """Returns (deck, error). deck = {title, cards, demo}."""
    url = ctx.inputs.get("deckurl", "").strip()
    if url.startswith("https://"):
        url = url[8:]
    elif url.startswith("http://"):
        url = url[7:]
    if url == "":
        return {"title": DEMO_TITLE, "cards": parse_cards(DEMO_TERMS), "demo": True}, None

    resp = http.get("https://" + url, ttl_seconds = 3600)
    if resp["status_code"] != 200:
        return None, ("OFFLINE", "CHECK DECK URL")
    data = resp["json"]
    title = "STUDY DECK"
    raw = []
    if type(data) == "list":
        raw = data
    elif type(data) == "dict":
        title = clean(data.get("title", "") or title, 40)
        raw = data.get("terms", [])
        if type(raw) != "list":
            raw = []
    else:
        return None, ("NOT A DECK", "URL MUST BE JSON")
    cards = parse_cards(raw)
    if len(cards) == 0:
        return None, ("NO CARDS", "ADD TERMS TO DECK")
    return {"title": title, "cards": cards, "demo": False}, None

def current_card(ctx, deck):
    cards = deck["cards"]
    i = (ctx.now.unix // REFRESH) % len(cards)
    return i, cards[i]

def wrap(c, text, font, maxw):
    lines = []
    cur = ""
    for w in text.split(" "):
        if w == "":
            continue
        if c.text_width(w, font) > maxw:
            # Too wide on its own: hyphenate across lines.
            if cur != "":
                lines.append(cur)
            chunk = ""
            for i in range(len(w)):
                if chunk != "" and c.text_width(chunk + w[i] + "-", font) > maxw:
                    lines.append(chunk + "-")
                    chunk = w[i]
                else:
                    chunk += w[i]
            cur = chunk
            continue
        cand = w if cur == "" else cur + " " + w
        if cur == "" or c.text_width(cand, font) <= maxw:
            cur = cand
        else:
            lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    return lines

def fit_block(c, text, x0, y0, w, h, fonts, color):
    """Draws text centered in the box, in the biggest font whose wrap fits."""
    cx = x0 + w // 2
    for f in fonts:
        fh = FONT_H[f]
        gap = 2 if fh >= 7 else 1
        lines = wrap(c, text, f, w)
        total = len(lines) * fh + (len(lines) - 1) * gap
        if total <= h or f == fonts[len(fonts) - 1]:
            n = min(len(lines), (h + gap) // (fh + gap))
            if n < len(lines):
                lines = lines[:n]
                lines[n - 1] = lines[n - 1][:max(1, len(lines[n - 1]) - 2)] + ".."
                total = n * fh + (n - 1) * gap
            y = y0 + (h - total) // 2
            for line in lines:
                c.text(line, cx, y, font = f, color = color, align = "center")
                y += fh + gap
            return

def card_frame(c, edge):
    c.clear()
    c.round_rect(0, 0, 63, 31, 2, outline = edge)

def footer(c, left, right, deck):
    # Footer row inside the frame: y 25..29.
    if deck["demo"]:
        c.text("DEMO", 3, 25, font = "4x5", color = "amber")
    elif left != "":
        c.text(left, 3, 25, font = "4x5", color = DIM)
    c.text(right, 60, 25, font = "4x5", color = DIM, align = "right")

def error_card(c, err):
    c.fill("#0B0C12")
    c.text_fit(err[0], 32, 7, ["6x8", "5x7", "4x5"], color = "#E8B04A", align = "center", maxw = 62)
    c.text_fit(err[1], 32, 19, ["4x5", "3x4"], color = DIM, align = "center", maxw = 62)

def subject(c, ctx):
    deck, err = load_deck(ctx)
    if err:
        error_card(c, err)
        return
    card_frame(c, COVER_EDGE)
    fit_block(c, deck["title"], 3, 2, 58, 21, HERO_FONTS, "amber")
    n = len(deck["cards"])
    footer(c, "", str(n) + (" CARD" if n == 1 else " CARDS"), deck)

def term(c, ctx):
    deck, err = load_deck(ctx)
    if err:
        error_card(c, err)
        return
    i, card = current_card(ctx, deck)
    card_frame(c, FRONT_EDGE)
    fit_block(c, card["term"], 3, 2, 58, 21, HERO_FONTS, "cyan")
    footer(c, "", str(i + 1) + "/" + str(len(deck["cards"])), deck)

def fullname(c, ctx):
    deck, err = load_deck(ctx)
    if err:
        error_card(c, err)
        return
    i, card = current_card(ctx, deck)
    card_frame(c, BACK_EDGE)
    # Header: which card this answers, then a rule.
    maxw = 58
    if deck["demo"]:
        c.text("DEMO", 60, 3, font = "4x5", color = "amber", align = "right")
        maxw = 58 - c.text_width("DEMO", "4x5") - 3
    head = card["term"]
    for _ in range(len(head)):
        if c.text_width(head, "4x5") <= maxw:
            break
        head = head[:len(head) - 1]
    c.text(head, 3, 3, font = "4x5", color = "cyan")
    c.line(3, 9, 60, 9, BACK_EDGE)
    if card["back"] == "":
        c.text_center("NO ANSWER", 16, font = "5x7", color = DIM)
        return
    fit_block(c, card["back"], 3, 11, 58, 18, BODY_FONTS, "white")
