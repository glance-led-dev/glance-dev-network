HEART = [
    [0, 1, 0, 1, 0],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
    [0, 0, 1, 0, 0],
]

FALLBACK_MESSAGE = "I LOVE YOU"
TITLE = "WHAT I LOVE"


def _truncate_to_width(canvas, text, font, max_w):
    if canvas.text_width(text, font) <= max_w:
        return text
    for i in range(len(text), -1, -1):
        candidate = text[:i] + ".."
        if canvas.text_width(candidate, font) <= max_w:
            return candidate
    return ""


def _wrap_lines(canvas, message, font, max_w):
    lines = []
    for paragraph in message.split("\n"):
        p = paragraph.strip()
        if p == "":
            lines.append("")
            continue

        words = p.split()
        current = ""
        for word in words:
            if current == "":
                test = word
            else:
                test = current + " " + word

            if canvas.text_width(test, font) <= max_w:
                current = test
            else:
                if current != "":
                    lines.append(current)
                    current = ""

                if canvas.text_width(word, font) <= max_w:
                    current = word
                else:
                    lines.append(_truncate_to_width(canvas, word, font, max_w))
        if current != "":
            lines.append(current)
    return lines


def _fetch_message(ctx):
    api_url = ctx.inputs.get("apiurl", "")
    api_key = ctx.inputs.get("apikey", "")
    if api_url == None or api_url == "":
        return FALLBACK_MESSAGE
    if api_key == None or api_key == "":
        return FALLBACK_MESSAGE

    resp = http.get(
        api_url,
        params = {"apiKey": api_key},
        ttl_seconds = 300,
    )
    if resp.get("status_code", 0) != 200:
        return FALLBACK_MESSAGE

    body = resp.get("json", None)
    if body == None:
        return FALLBACK_MESSAGE

    msg = body.get("message", "")
    if msg == None or msg == "":
        return FALLBACK_MESSAGE

    return str(msg)


def main(canvas, ctx):
    canvas.clear()

    message = _fetch_message(ctx).upper()

    heart_w = 5
    heart_h = 4
    heart_y = 1

    title_font = "picopixel"
    title_w = canvas.text_width(TITLE, title_font)
    gap = 2
    header_w = heart_w + gap + title_w + gap + heart_w
    header_x = (ctx.width - header_w) // 2

    canvas.bitmap(HEART, header_x, heart_y, "red")
    canvas.text(TITLE, header_x + heart_w + gap, heart_y, font = title_font, color = "white")
    canvas.bitmap(HEART, header_x + heart_w + gap + title_w + gap, heart_y, "red")

    font = "4x5"
    line_h = 6
    text_top = heart_y + heart_h + 3
    max_lines = (ctx.height - text_top) // line_h
    if max_lines <= 0:
        return

    lines = _wrap_lines(canvas, message, font, ctx.width)
    if len(lines) > max_lines:
        lines = lines[:max_lines]
        lines[max_lines - 1] = _truncate_to_width(canvas, lines[max_lines - 1], font, ctx.width)

    text_x = ctx.width // 2
    y = text_top
    for line in lines:
        canvas.text(line, text_x, y, font = font, color = "white", align = "center")
        y += line_h