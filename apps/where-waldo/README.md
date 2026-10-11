# Where Waldo

A hide-and-seek game for the Glance LED panel. A busy pixel-art scene (a beach, a city street, or a fairground) fills the panel, and one striped hero is hiding in it, doing something. Find him.

- **Panel:** 384 x 32 (six 64 px modules)
- **Category:** Fun
- **Refresh:** every 60 seconds, so there is a new puzzle every minute
- **Author:** SlaterDen

## How it plays

The app has two pages that play back to back:

| Page | What you see |
|------|--------------|
| **hunt** | The hero mug shot and **WHERE / WALDO?** on the left, with the scene filling the rest of the panel. |
| **found** | The same scene, with a green box around the hero and **FOUND / WALDO!** in green. |

Both pages are drawn from the same seed (the current minute), so the reveal shows exactly the scene you were just searching. A new scene appears on the next minute.

The hero always wears a **striped hat**, **round glasses**, and a **striped shirt**. Everyone else is a near-miss at best: a decoy never has all three at once.

## Settings

| Setting | Choices | Default | What it does |
|---------|---------|---------|--------------|
| **Difficulty** | EASY, MEDIUM, HARD, EXTREME | MEDIUM | More things in the scene and a brighter, busier background. |
| **Scenes** | BEACH, CITY, FAIR | CITY | Picks the backdrop and everything that lives in it. |

### Difficulty levels

| Level | Things in scene | Background brightness | Overlap |
|-------|-----------------|-----------------------|---------|
| EASY | 22 | 30% | No (1 px gap between everything) |
| MEDIUM | 44 | 60% | No |
| HARD | 70 | 100% | No |
| EXTREME | 120 | 100% | **Yes**: things overlap, lower ones drawn in front |

"Things" means people, babies, animals, and objects combined, hero included. On EXTREME the hero is always drawn last, so he is never covered, only crowded.

## The scenes

Everything is placed so it makes sense with its backdrop: feet rest on the ground, boats sit in the water, birds fly in the sky.

**BEACH**: sky, sea, sand
- Sky: seagulls, kites
- Sea: sailboats (striped sails), surfers, swimmers
- Sand: people standing, walking, running, jumping, waving, building a sandcastle, lying down, and crawling babies; plus a crab, starfish, a seagull, a running dog, a beach ball, striped umbrellas and towels, and sandcastles

**CITY**: sky, rooftops, sidewalk, road
- Sky: pigeons flying above the skyline
- Sidewalk: people standing, walking, running, waving, jumping, and sitting on a bench; babies, a dog, a cat, a pigeon, fire hydrants, traffic cones, street lamps, mailboxes, and bins
- Road: taxis and buses

**FAIR**: striped tent wall, grass
- Air: floating balloons
- Ground: people standing, walking, running, jumping, waving, lying on the grass, and crawling babies; plus a teddy bear, duck, pony, ticket booth, and popcorn cart

The hero can appear doing any of: standing, walking, running, jumping, waving, and (depending on the scene) building a sandcastle, lying down, surfing, or sitting on a bench.

**Near-miss decoys:** striped umbrellas, towels, sails, booth roofs, and popcorn-cart awnings use the hero's own stripe colors, and some decoys wear stripes, hats, or glasses (just never all three).

## Screens

- **Live:** the hunt and found pages described above.
- **Error:** if a setting has an unexpected value, the panel shows `BAD SETTING / RE-SAVE APP` in two short lines.
- **Empty / demo:** not applicable. The app uses no live data and no API key, so there is nothing to be empty or in demo mode.

## Files

```
where-waldo/
  manifest.yaml   app settings, pages, and the two dropdown inputs
  app.star        all drawing logic (Starlark)
  README.md       this file
```

## How it works

- `hunt(c, ctx)` and `found(c, ctx)` each draw the whole frame immediately with `c.*` calls. There is no animation; the panel re-renders on the 60 second refresh.
- The scene is generated from a seed (`ctx.now` to the minute) using a small built-in random generator, so the same minute always gives the same scene on both pages.
- The hero is placed first. Then other things are placed at random positions inside the zones for the chosen scene, rejecting any that would come closer than 1 px to something else (skipped on EXTREME).
- Sprites are small pixel maps defined as rows of letters in the `SPR` table in `app.star`; stripe colors, skin tones, shirt colors, and hats are filled in when they are drawn.
- Backdrop colors are defined at full brightness and scaled down for easier levels.

## Customizing (in `app.star`)

| To change | Edit |
|-----------|------|
| How many things per level | `COUNTS` near the top |
| How bright each level's background is | `BRIGHT` near the top |
| Add or remove a creature or object | the `SPR` table, then add its name to a zone in `THEME` |
| Which scenes things can appear in | the `names` lists inside `THEME` |
| The character | `ACTIVE_CHARACTER` (see below) |

### Alternate character

A second character, **STRIPEY** (green and white stripes), is built into the code but not offered as a setting. To use it, change `ACTIVE_CHARACTER = "WALDO"` to `"STRIPEY"` near the top of `app.star`. The labels on the panel become WHERE / STRIPEY? and FOUND / STRIPEY!. You can also re-add a `character` dropdown to the manifest with choices `[WALDO, STRIPEY]`, since the code reads a `character` input if one exists.

## Notes

- **Name:** "Waldo" is a trademarked character. The manifest `id` and `name`, and the on-panel text, use the name. The character art itself is original pixel art (a striped shirt, beanie, and glasses). Check with the Glance team before publishing; STRIPEY is the fallback.
- **Performance:** the GDN guidance recommends 192 x 32 or smaller for best performance. At 384 wide, a page draws roughly 2,400 pixels on HARD and up to about 3,900 on EXTREME. If EXTREME is slow on your hardware, lower its count in `COUNTS`.
- **Layout:** content stays inside x 10-373, leaving 10 px of padding at both outer edges of the panel. The scene itself runs from x 80 to 373.