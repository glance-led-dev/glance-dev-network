STYLES = {
    "Straight row, seven big pinwheels side by side": "pinwheels-row.png",
    "Stepped arch, pinwheels on sticks rising to the center": "pinwheels-arch.png",
    "Fireworks, stepped arch with fireworks bursting behind": "pinwheels-fireworks.png",
}

def main(c, ctx):
    image = STYLES.get(ctx.inputs.get("style", ""), "pinwheels-row.png")
    c.fill("black")
    c.image(image, 0, 0, w=384, h=32)
