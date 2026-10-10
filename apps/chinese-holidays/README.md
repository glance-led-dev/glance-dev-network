# Chinese Holidays

Days until the next of seven Chinese holidays on a 192x32 panel. A 32 px icon slot stands at each side; between them, a red key-fret border (回纹) runs along the top, with the count in gold below it. On the day itself, the count changes to a greeting.

| Holiday | Date | Picture | On the day |
|---|---|---|---|
| New Year's Day | 1 January | A red 福 in the left slot (`assets/fu.png`, 32x32), fireworks in the right | HAPPY NEW YEAR |
| Chinese New Year | 1st day of the 1st lunar month | Red lantern | HAPPY CHINESE NEW YEAR |
| Qingming | Clear and Bright solar term (4 or 5 April) | Willow in the rain | TODAY IS QINGMING |
| Labour Day | 1 May | Hammer and wrench | HAPPY LABOUR DAY |
| Dragon Boat | 5th day of the 5th lunar month | Dragon boat | HAPPY DRAGON BOAT |
| Mid-Autumn | 15th day of the 8th lunar month | Full moon and mooncake | HAPPY MID-AUTUMN |
| National Day | 1 October | National flag | HAPPY NATIONAL DAY |

On a countdown day, the number is followed by DAYS TIL and the holiday's name in its own colour.

## Inputs

| Input | What it does |
|---|---|
| **Holiday** | Next holiday (default) follows whichever of the seven comes next. Pick one instead to count down to it all year. A chosen lunar holiday after 2045 has no date, so the panel falls back to the next holiday. |
| **Time Zone** | The count rolls over at midnight in the chosen city. Listed west to east with each city's standard UTC offset: San Francisco (−8), Denver (−7), Chicago (−6), New York (−5), Rio de Janeiro (−3), London (0), Paris (+1), Moscow (+3), Bangkok (+7), Beijing (+8), Tokyo (+9), Sydney (+10). Defaults to New York (−5). Daylight saving is applied automatically.

## The lunar dates

Chinese New Year, Qingming, Dragon Boat and Mid-Autumn are stored as a table covering **2026 to 2045**. The Chinese calendar depends on the exact minute of each new moon and solar term in Beijing time, which is too precise to calculate on the panel. After 2045 the app counts down to the three fixed holidays only.

Every date in the table was checked two ways:

1. **Calculated:** new moons and solar terms were computed astronomically, then the calendar rules were applied: Beijing midnight, the winter solstice in month 11, and the leap month.
2. **Compared with published dates:**
   - [Chinese Fortune Calendar](https://www.chinesefortunecalendar.com/TDB/NewYearDays.asp) for Chinese New Year
   - [usemooncal](https://usemooncal.com/en/festivals/dragon-boat-festival) for Dragon Boat and [Mid-Autumn](https://usemooncal.com/en/festivals/mid-autumn-festival)
   - [qppstudio](https://www.qppstudio.net/global-holidays-observances/qing-ming-jie-tomb-sweeping-day.htm) for Qingming to 2036
   - the [Hong Kong Observatory](https://www.hko.gov.hk/en/gts/time/calendar/text/files/T2038e.txt) calendar for Qingming in 2038 and 2042, where the solar term falls close to midnight

Every date matched.

In 2031, Mid-Autumn falls on 1 October, National Day. That countdown and that day show the national flag in the left slot and the moon in the right, split the top border red over the left half and gold over the right, and name both holidays in a smaller font, each in its own colour: NATIONAL in red and MID-AUTUMN in gold. On the day the greeting reads HAPPY over NATIONAL & MID-AUTUMN.
