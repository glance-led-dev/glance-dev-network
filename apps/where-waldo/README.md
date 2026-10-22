# Where Waldo

A hide-and-seek game for the Glance LED panel. A busy pixel-art scene (a beach, a city street, or a fairground) fills the panel, and one striped hero is hiding in it, doing something. Find him.

- **Panel:** 384 x 32 (six 64 px modules)
- **Category:** Fun
- **Refresh:** every 60 seconds, so there is a new puzzle every minute
- **Author:** Brayden Slater

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
| **Scenes** | BEACH, CITY, FAIR, SKI SLOPES, GROCERY STORE, MOVIE THEATER, MUSIC CONCERT, SPORTS STADIUM, CAMPSITE, HOLLYWOOD | CITY | Picks the backdrop and everything that lives in it. |

### Difficulty levels

| Level | Things in scene | Background brightness | Overlap |
|-------|-----------------|-----------------------|---------|
| EASY | 22 | 30% | No (1 px gap between everything) |
| MEDIUM | 44 | 60% | No |
| HARD | 70 | 100% | No |
| EXTREME | 120 | 100% | **Yes**: things overlap, lower ones drawn in front |

"Things" means people, babies, animals, and objects combined, hero included. On EXTREME the hero is always drawn last, so he is never covered, only crowded.

## The scenes

Everything is placed so it makes sense with its backdrop: feet rest on the ground, boats sit in the water, birds fly in the sky, chairs hang from the lift cable.

**BEACH** (sky, sea, sand)
- Sky: seagulls, kites. Sea: sailboats, surfers, swimmers.
- Sand: sunbathers, castle builders, runners, a crab, starfish, a dog, umbrellas, towels.

**CITY** (sky, skyline, sidewalk, road)
- Sky: pigeons. Sidewalk: people (one on a bench), a dog, a cat, hydrants, cones, lamps, mailboxes, bins.
- Road: taxis and a bus.

**FAIR** (tent wall, grass)
- Air: balloons. Ground: people, a teddy bear, duck, pony, ticket booth, popcorn cart.

**SKI SLOPES** (sky, mountains, chairlift cable, snow)
- Chairlift: riders and empty chairs hanging from the cable.
- Snow: skiers, snowboarders, a sledder, snowmen, pine trees, a husky, a lodge.

**GROCERY STORE** (ceiling, stocked shelves, tiled floor)
- Ceiling: hanging sale, price and exit signs.
- Floor: shoppers pushing carts, someone slipping on a banana peel, a cat, a dog, a mouse, produce stands, boxes, a mop bucket, a wet-floor sign.

**MOVIE THEATER** (lobby: posters on the wall, red carpet)
- Wall: movie posters. Lobby: people with striped popcorn buckets, a bench, a popcorn machine, an arcade cabinet, a ticket booth, ropes, film reels, spilled popcorn.

**MUSIC CONCERT** (stage with light beams, crowd floor)
- Stage: singer, keyboardist, drummer, guitarist, speakers, mic stand.
- Crowd: people cheering with their arms up or holding up phones, glow sticks, beach balls and balloons overhead, and a crowd surfer.

**SPORTS STADIUM** (stands, ad boards, grass field)
- Stands: fans cheering, one waving a striped flag.
- Field: players running, jumping, kicking, and throwing; a referee in black-and-white stripes, a tiger mascot, a goal, balls, cones, and a dog that wandered on.

**CAMPSITE** (dusk sky, pine treeline, forest floor)
- Sky: bats, fireflies.
- Ground: people hiking, sitting on a log, building a campfire, or stargazing on their back; tents (one striped), a campfire, a bear, a deer, a squirrel, a canoe, a cooler, a lantern, mushrooms, pines.

**HOLLYWOOD** (the hillside sign, Walk of Fame sidewalk, road)
- Sky: a helicopter. Sidewalk: people posing, a director with a megaphone, someone taking a selfie, a clapperboard, a film camera, palm trees, a trophy, a red carpet, ropes.
- Road: limos, taxis, a bus.

The hero can appear doing any of a scene's striped-person poses: standing, walking, running, jumping, waving, and the scene's special ones (for example surfing, skiing, snowboarding, sledding, riding the chairlift, pushing a cart, slipping on a banana, holding popcorn, drumming, kicking a ball, building a fire, directing a film).

**Near-miss decoys:** striped umbrellas, towels, sails, tents, flags, popcorn buckets and machines, ticket booths, and popcorn-cart awnings use the hero's own stripe colors, a referee wears black-and-white stripes, and some decoys wear stripes, hats, or glasses (just never all three).

## Screens

- **Live:** the hunt and found pages described above.
- **Error:** if a setting has an unexpected value, the panel shows `BAD SETTING / SAVE AGAIN` in two short lines.
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
- The large 7x12 label font has no `?` or `!` glyphs, so those two marks are drawn by hand (pixel by pixel) to match the letters.

## Customizing (in `app.star`)

| To change | Edit |
|-----------|------|
| How many things per level | `COUNTS` near the top |
| How bright each level's background is | `BRIGHT` near the top |
| Add or remove a creature or object | the `SPR` table, then add its name to a zone in `THEME` |
| Which scenes things can appear in | the `names` lists inside `THEME` |
| Scene density (tight scenes get less) | `SCALE` near the top |
| A scene's people colors | its entry in `STYLES` |
| The character | `ACTIVE_CHARACTER` (see below) |

### Alternate character

A second character, **STRIPEY** (green and white stripes), is built into the code but not offered as a setting. To use it, change `ACTIVE_CHARACTER = "WALDO"` to `"STRIPEY"` near the top of `app.star`. The labels on the panel become WHERE / STRIPEY? and FOUND / STRIPEY!. You can also re-add a `character` dropdown to the manifest with choices `[WALDO, STRIPEY]`, since the code reads a `character` input if one exists.

## Notes

- **Name:** "Waldo" is a trademarked character. The manifest `id` and `name`, and the on-panel text, use the name. The character art itself is original pixel art (a striped shirt, beanie, and glasses). Check with the Glance team before publishing; STRIPEY is the fallback.
- **Performance:** the GDN guidance recommends 192 x 32 or smaller for best performance. At 384 wide, a page draws roughly 2,400 pixels on HARD and up to about 3,900 on EXTREME. If EXTREME is slow on your hardware, lower its count in `COUNTS`.
- **Input limit:** with refresh under 120 seconds the platform allows at most 48 input combinations. This app has 4 difficulties x 10 scenes = 40, so there is room for two more scenes, but not more without raising the refresh or removing a difficulty.
- **Layout:** content stays inside x 10-373, leaving 10 px of padding at both outer edges of the panel. The scene itself runs from x 80 to 373.
