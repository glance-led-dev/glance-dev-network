# Commodities at a Glance

Six commodities, each as a piece of pixel art and a price: what it costs,
what it is priced in, and how far it has moved today. No key needed.

## Settings

Six dropdowns, three per page. Each one picks a commodity or `NONE` to
leave that tile empty.

| page | default |
|---|---|
| Page 1 | Live cattle, corn, soybeans |
| Page 2 | Crude oil, gold, wheat |

Choices: live cattle, feeder cattle, lean hogs, corn, soybeans, wheat,
oats, crude oil, natural gas, gold, silver, copper, coffee, sugar, cotton,
cocoa, orange juice.

## How the prices read

The exchanges quote these in different ways, so every tile carries its
unit under the price. Nothing is converted silently.

| commodity | quoted as | shown as |
|---|---|---|
| Corn, soybeans, wheat, oats | US cents a bushel | `$5.34` per `BUSHEL` |
| Live cattle, feeder cattle, lean hogs | US cents a pound | `$220.33` per `CWT`, the hundredweight the trade uses |
| Coffee, cotton, orange juice | US cents a pound | `$2.80` per `LB` |
| Sugar | US cents a pound | `18.92` per `C/LB`, because a fifth of a cent reads as nothing in dollars |
| Crude oil | dollars a barrel | `$102.10` per `BBL` |
| Natural gas | dollars per million BTU | `$2.89` per `MMBTU` |
| Gold, silver | dollars a troy ounce | `$4,303` per `OZ` |
| Copper | dollars a pound | `$6.44` per `LB` |
| Cocoa | dollars a ton | `$5,951` per `TON` |

The price is white. Green and red are only ever the day's move, and the
left edge of the panel follows whichever way the page leans.

## Notes

- Prices are front-month futures from Yahoo Finance, which is a free feed
  and therefore delayed. The chip row says `DELAYED` next to the time the
  quote was taken, in the exchange's own clock.
- Spot-checked against CNBC's quote service while this app was built: corn
  534.00 and -0.33%, live cattle 220.325 and -1.35%, soybeans 1321.50,
  gold 4303.20 - the same numbers on both.
- All six tiles come from a single request, so the panel asks once every
  ten minutes however many commodities are on it.
- Futures roll: the front-month contract changes through the year, which
  is why a price can step when the contract does.
