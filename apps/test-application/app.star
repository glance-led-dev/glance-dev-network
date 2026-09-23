# Custom 10x10 Pixel Art Sprites
SPRITE_CHIP = [
    [0, 1, 0, 1, 0, 1, 0, 1, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 0, 0, 0, 0, 0, 1, 0, 0],
    [1, 1, 0, 1, 1, 0, 0, 1, 1, 0],
    [0, 1, 0, 1, 1, 0, 0, 1, 0, 0],
    [1, 1, 0, 0, 0, 0, 0, 1, 1, 0],
    [0, 1, 0, 0, 0, 0, 0, 1, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 0, 1, 0, 1, 0, 1, 0, 0],
]

SPRITE_STAR = [
    [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
]

SPRITE_CHART = [
    [0, 0, 0, 0, 0, 0, 0, 1, 1, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 1, 0, 0, 1, 0, 0, 0],
    [1, 0, 1, 1, 0, 1, 1, 0, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

SPRITES = [SPRITE_CHIP, SPRITE_STAR, SPRITE_CHART]

def render_banner(c, ctx, is_demo):
    theme_color = ctx.inputs.get("theme", "skyblue")
    
    # Calculate sprite rotation index based on current time
    now_sec = ctx.now.unix if ctx.now else 0
    shift = (now_sec // 60) % 3

    # Clear canvas & set dark background with frame border
    c.fill("black")
    c.rect(4, 2, 379, 29, outline="gray")

    # Content Strings
    t1 = "TEST CONTENT 1".upper()
    t2 = "MSFT AI TOUR".upper()
    t3 = "LSEG DEMO".upper()

    font_style = "7x12"
    x_pos = 12

    # Text 1
    c.text(t1, x_pos, 10, font=font_style, color="white")
    x_pos += c.text_width(t1, font_style) + 12

    # Sprite 1
    c.bitmap(SPRITES[shift % 3], x_pos, 11, theme_color)
    x_pos += 22

    # Text 2
    c.text(t2, x_pos, 10, font=font_style, color="white")
    x_pos += c.text_width(t2, font_style) + 12

    # Sprite 2
    c.bitmap(SPRITES[(shift + 1) % 3], x_pos, 11, "amber")
    x_pos += 22

    # Text 3
    c.text(t3, x_pos, 10, font=font_style, color="white")
    x_pos += c.text_width(t3, font_style) + 12

    # Sprite 3
    c.bitmap(SPRITES[(shift + 2) % 3], x_pos, 11, "green")

    # Demo mode badge (x0, y0, x1, y1, radius=2, fill="amber")
    if is_demo:
        c.round_rect(328, 4, 368, 14, 2, fill="amber")
        c.text("DEMO".upper(), 332, 5, font="5x7", color="black")

def main_screen(c, ctx):
    render_banner(c, ctx, is_demo=False)

def demo_screen(c, ctx):
    render_banner(c, ctx, is_demo=True)

def empty_screen(c, ctx):
    c.fill("black")
    c.rect(4, 2, 379, 29, outline="gray")
    msg = "ALL CLEAR - NO SCHEDULED EVENTS".upper()
    font_style = "7x12"
    w = c.text_width(msg, font_style)
    x = 192 - (w // 2)
    c.text(msg, x, 10, font=font_style, color="green")

def error_screen(c, ctx):
    c.fill("black")
    c.rect(4, 2, 379, 29, outline="red")
    c.text("ERROR: FAILED TO FETCH EVENT BANNER DATA".upper(), 12, 6, font="5x7", color="red")
    c.text("PLEASE CHECK DISPLAY CONFIGURATION & REFRESH".upper(), 12, 17, font="5x7", color="white")