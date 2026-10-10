# Nutrition at a Glance

One food at a time, and what it actually gives you. A new food every ten
minutes, drawn as pixel art, with either its macronutrients or the
micronutrients it is genuinely worth eating for. 69 foods, no key, no
network.

## Settings

| setting | what it is |
|---|---|
| **Show** | `MACRONUTRIENTS` gives protein, fat, carbohydrate and fibre. `MICRONUTRIENTS` gives B12, B6, zinc, iron, selenium and magnesium. |
| **Food group** | Narrow the rotation to meat, poultry, seafood, eggs and dairy, or plants. |

## The pages

- **Food** - the food drawn large on the left, then four rows: what the
  nutrient is, a bar showing the share of a day's reference intake, and the
  amount in grams with that share as a percentage. The header names the
  serving, such as `1 OZ 28G`.
- **Detail** - six figures in a grid under the same serving header. In the
  micronutrient view that is all six micros at once, with energy in the
  header. In the macronutrient view it is energy and the four macros, and
  the sixth cell names the micronutrient this food is actually notable for,
  which is how the two views connect.

In the micronutrient view the four rows are **the four this food delivers
most of, ranked**, not a fixed four. The question the app answers is which
foods get you to a goal, and a fixed list would bury the reason an oyster
or a piece of liver is worth knowing about.

## Everything is per serving

The table is kept per 100 g, the standard basis it was checked on, and
every figure on the panel is scaled to one serving of that food. 100 g is
a fair basis for comparing foods but not what anyone eats: 100 g of
cheddar is 403 kcal, while a 1 oz serving is 113.

Serving sizes follow US label conventions:

| food | serving |
|---|---|
| cheese, nuts, seeds, prosciutto | 1 oz, 28 g |
| butter, olive oil | 1 tbsp, 14 g |
| peanut butter | 2 tbsp, 32 g |
| milk | 1 cup, 244 g |
| Greek yogurt | 1 pot, 170 g |
| cottage cheese | 1/2 cup, 113 g |
| egg, egg white | 1 large egg, 50 g and 33 g |
| whey protein | 1 scoop, 30 g |
| meat, poultry, fish, shellfish | 4 oz raw, 113 g, about 3 oz cooked |
| bacon | 2 slices raw, 50 g |
| pork sausage | 2 links, 55 g |
| ham | 2 slices, 56 g |
| sardines | 1 tin drained, 92 g |
| lentils, chickpeas, black beans, quinoa | 1/4 cup dry, 43 to 50 g |
| oats | 1/2 cup dry, 40 g |
| tofu, tempeh | 3 oz, 85 g |
| edamame | 1/2 cup, 78 g |
| spinach, kale, broccoli | 1 cup raw, 30 g, 67 g and 91 g |
| sweet potato | 1 medium, 130 g |
| avocado | 1/3 fruit, 50 g |

Raw, unless noted, and dry goods are weighed dry. Cooking changes things:
driving off water concentrates everything, and bacon renders out much of
its fat, so 2 slices of cooked bacon carry far less than the raw figure.

Real foods vary anyway. A chicken breast changes with trim and feed, a
steak with cut and grade, a fillet with whether the fish was farmed. Treat
these as typical figures, not as a measurement of the thing in your fridge.

## About the protein bar

The bar for protein is measured against **100 g a day**, not the 50 g that
appears on packaging as the reference intake. That was a deliberate choice
for this app, so a high-protein food does not peg the bar immediately. Every
other bar uses the standard EU Nutrient Reference Value: fat 70 g,
carbohydrate 260 g, fibre 30 g, B12 2.4 ug, B6 1.4 mg, zinc 10 mg, iron
14 mg, selenium 55 ug, magnesium 375 mg.

Micrograms are written `UG`, because no bundled font carries the micro sign
and dropping it silently would turn one unit into another.

## What the bars do and do not say

Length is the share of the reference intake. **Colour is the food's own,
not a verdict.** This panel is not qualified to tell anyone that fat is bad
or that protein is good; that depends entirely on the person eating it.

The one judgement it does make is factual: the bar and the figure turn
green when a single serving meets the whole reference intake on its own.
Over 100 per cent the bar stays full and the real percentage is still
printed, so beef liver reads 2792 per cent of a day's B12 rather than
quietly clamping to a full bar and hiding it.

## Where the numbers come from

The table is curated and each row records its own provenance. Seven foods
were machine checked against **USDA FoodData Central** before the shared
demo key began refusing requests: egg, chicken breast, salmon, tuna, cod,
shrimp and oyster. Three later attempts were refused outright, so the
remaining sixty-two are standard reference figures that this build could
not re-check.

A free FoodData Central key of your own would lift that limit and let the
whole table be verified against the database rather than seven rows of it.

Two faults in that first check are worth recording, because they are easy
to repeat. Free-text search returns the wrong food outright: a query for
chicken thigh returned chicken *skin* at 44 g of fat, one for beef sirloin
returned veal, and one for ground beef returned turkey. And the database
carries two nutrient rows both called `Energy`, one in kilocalories and one
in kilojoules, so taking the first gives kilojoules.

Every row is also cross-checked against its own energy figure: kilocalories
should be close to `4*protein + 9*fat + 4*carb`, with fibre charged at
2 kcal/g rather than 4. That check caught a real error with no API involved
at all, where lentils had been given 30.5 g of fibre, which is the daily
reference intake rather than the content of the food. One food still sits
outside the tolerance: oysters, whose glycogen the simple formula does not
model.

## The artwork

Thirty-five shapes, drawn as per-pixel sprite art in five tones, each
recoloured per food from its own palette. That is what lets one fillet
shape read as salmon, cod or tuna, and one nut pile read as almonds,
walnuts or pumpkin seeds. A `c.sprite` call costs one draw op no matter how
many pixels it lights, which is what makes art at this density affordable
inside the page budget.

## Notes

- **No network calls at all.** Composition does not change, so there is
  nothing to fetch. The ten minute refresh turns the food over.
- The design guide asks for four screens: live, error, empty and demo. With
  no feed and no key, error and demo cannot occur here. The empty screen is
  kept as a guard in case a group is ever emptied by a later edit, and it is
  written positive rather than as a fault.
- The food is chosen from `ctx.now.unix // 600`, so every panel showing
  this app is on the same food at the same moment.
- Nothing here is dietary advice. It is a reference table with pictures.
