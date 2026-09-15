def draw_record(c, text, color):
    c.fill("black")

    if text == "" or text == None:
        return

    if color == "" or color == None:
        color = "white"

    c.text_center(
        "NEW RECORD",
        6,
        font="5x7",
        color=color
    )

    c.text_center(
        str(text).upper(),
        18,
        font="6x8",
        color=color
    )


def page01(c, ctx):
    draw_record(c, ctx.inputs.get("record1", ""), ctx.inputs.get("color", "white"))

def page02(c, ctx):
    draw_record(c, ctx.inputs.get("record2", ""), ctx.inputs.get("color", "white"))

def page03(c, ctx):
    draw_record(c, ctx.inputs.get("record3", ""), ctx.inputs.get("color", "white"))

def page04(c, ctx):
    draw_record(c, ctx.inputs.get("record4", ""), ctx.inputs.get("color", "white"))

def page05(c, ctx):
    draw_record(c, ctx.inputs.get("record5", ""), ctx.inputs.get("color", "white"))