ADS = {
    "MALORT": "chicago-parody-ad-malort.png",
    "CELL BLOCK": "chicago-parody-ad-cell-block.png",
}

def main(c, ctx):
    c.fill("black")
    c.image(ADS.get(ctx.inputs.get("ad", "MALORT"), ADS["MALORT"]), 0, 0, w=192, h=32)
