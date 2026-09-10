# Arcade Basketball High Score

The house record on an arcade basketball machine, on a single 64x32 panel: the
machine's name in the top strip, a ball dropping through the hoop beside an
oversized score, and the record holder's name underneath.

## Settings

| Setting | Default | What it does |
|---|---|---|
| Champ | *(blank)* | Who holds the record. Shown in caps — the panel fonts have no lowercase. |
| High score | *(blank)* | The record itself. Whole numbers. |
| Title | `ARCADE HOOPS` | The top strip — name your machine. Change it and this app runs any other game in the room. |

Both the champ and the score start blank on purpose, so a freshly added app
asks to be set up instead of putting a made-up record on the wall.

## Why the score is typed in

A house record falls a few times a year. That is rarer than most people edit
their panel settings anyway, so a spreadsheet, a hosted JSON file or an API
would all have been machinery in service of nothing. Two text boxes it is.

## Layout

Three bands, and every one of the 32 rows is spoken for:

- **y 0–6** — the title strip, black text on filled orange, so no stroke needed.
- **y 8–23** — the hero. The hoop and the score are centered *as a group*, so a
  two-digit night and a four-digit night are both balanced instead of drifting
  left. The score drops a font rung (`10x16` → `8x12` → `6x9`) if it has to.
- **y 25–31** — the champ's name, fitted down a ladder and then hard-clipped.
  Nothing in the drawing API clips, so overflow is silent without this.

## The sprite

13x14, four colors. The rim tapers across two rows rather than sitting flat: a
flat bar under a round ball reads as a cocktail glass, and the taper is what
turns it back into a hoop seen from slightly above. The ball is 7 px across to
the rim's 13 — a 9.5" ball through an 18" rim, which is most of why it reads at
this size. Ball, rim and seams are three shades of one orange so the sprite
holds together as a single object.
