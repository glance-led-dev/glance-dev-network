# NASCAR Race Center

Cup, O'Reilly or Truck Series, built around each car's real number art.

## Pages

**During a race, qualifying or the results:** race card, the field (5 pages - how many cars depends on the Running order setting), then the Chase (2 pages). Before the Chase starts, those last 2 pages are the points (1-8, 9-16) with green / red arrows for places moved since the race before; with the full field, from the final stage on, the field's last page (33-40) gives way and the last page shows the drivers just outside the cut and how far behind it they are (TIE when level).
**The Clash, the Duels and the All-Star Race** (no points): the field, then past winners instead of the Chase - the last 4 Clash winners, the last 4 Daytona 500 winners during the Duels, the last 3 All-Star winners.
**Off-season** (after the last Chase race's results until the next season's first points race): race card (season over, the champion), three champion pages - name, number, make and title margin; the season in numbers (wins, top 5s, top 10s, poles, laps led, stage wins); where they won - then the Chase's final standings and the season points past it. From January 1 until a week out, the race card counts down the days to the new season (the Clash and the Daytona 500 in Cup, the opener in O'Reilly and Trucks).
**Off days:** race card, the last race's top 8, the Chase, then season leaders (wins, top 5s, top 10s) and the points past the Chase. Before the Chase that last page shows the drivers just outside the cut (Cup top 16, O'Reilly 12, Trucks 10) and how many points behind it they are.

| Page | Shows |
|---|---|
| Race card | Live: flag, lap, laps to go in the stage, stage winners, leader · after the race: winner and margin (through Monday after a Thursday-Sunday race, else through the next day) · after qualifying: pole and speed · otherwise: next race, start time, TV |
| Field | Running order · finishing order · qualifying order (during qualifying, the cars still to run follow, marked TO GO) |
| Chase | Live points with places gained or lost tonight · standings |

## Reading the field

- **Number beside each car:** position. Under it, the gap to the leader (`1.734`), laps down (`-2L`) or `OUT`.
- **Gap color:** green = gained spots in the last 3 laps, amber = lost one, red = lost more.
- **Green-and-white checkered flag:** won a stage today, one per stage (the winner gets one for the final stage).
- **PIT:** on pit road.
- **2R / 2L:** took different tires from most of the field on their last stop, or were the only car with a recent tire stop. Shown until 3 green laps after the stop; cars that did what everyone did keep their gap.
- **PEN / BLK (red):** a penalty or black flag in NASCAR's lap notes, for 10 laps.
- **Left-edge stripe:** flag color (green, yellow, red, white = final).
- **WIN!:** the winner once the race is over.
- **Magenta position:** a Chase driver (in qualifying, a Chase driver still to run shows TO GO in magenta).

**Top 20, Top 10 and Chase drivers** add each driver's last name, a green ▲ or red ▼ for spots gained or lost since the start, and laps led (`LED 84`, shown only for drivers who led; gold for whoever has led the most). In Top 20 and Top 10, a Chase driver's position shows in magenta.

| Running order | Field pages |
|---|---|
| Full field | 1-40, 8 cars a page |
| Top 20 | 1-20, 4 cars a page |
| Top 10 | 1-10, 2 cars a page with big numbers |
| Chase drivers | Only the Chase drivers, in running order (Cup 3-3-3-3-4, O'Reilly 2-2-2-3-3, Trucks 2 a page); fewer cars a page get wider cells, two get the big numbers |

## Reading the Chase

- **Under each rank:** points behind the leader (the leader shows their total). During and after a race, a green ▲ or red ▼ beside the rank shows Chase places gained or lost since the green flag. The header counts the races left.
- **Red points behind:** mathematically out of the title - even the maximum in every race left (76 a race) with the leader scoring nothing can't catch the leader. Ties count as alive. Only from races already run.
- **CHAMP (gold):** clinched - no one can catch them; after the last race, the champion. A tie on points goes to the driver with more wins (the champion page says TIEBREAK); level on wins too, the app doesn't call it.
- **Amber points (during a race):** would be out of the title if the race ended in the current order. Not official.
- **Before the first points race:** last season's standings are gone once qualifying for the opener starts. Pages 7-8 say NO POINTS YET, and the Chase drivers setting shows the top 20 until the first race is over. After that it follows the current top of the points.

## Settings

- **Series:** Cup, O'Reilly or Truck.
- **Time zone:** for race and qualifying start times.
- **Running order:** Full field, Top 20, Top 10 or Chase drivers - what the 5 field pages show. The Clash, Duels and All-Star Race always show their whole (short) field.

## Data

NASCAR's public feeds (`cf.nascar.com`), no key: schedule, live feed, live points, pit stops, lap-by-lap positions, lap notes and official results. Refreshes every 5 minutes.
