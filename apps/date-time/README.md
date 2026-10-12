# Date & Weather — today's date and weather for a US zip code. (192x32)

**TODAY:** the weekday over a big date on the left; on the right, the place,
a drawn condition icon, the temperature, today's high, low, and
current humidity in a column, and the condition by name.

**SKY:** the next six hours, three over three, each with its hour, a drawn
condition, the temperature, and the chance of rain that hour; sunrise (yellow)
stacked over sunset (orange) on the right.

Settings: a zip code, a date style (SEP 14 / 14 SEP / 09/14 / 14/09), and one
of five colors (white, amber, green, cyan, red) each for the date and the
weather. The current temperature defaults to weather-map colors (purple
when frigid through blue, green, yellow, and orange to red when hot), or takes
one of the five fixed colors. Today's high and low, the humidity, and the hourly
temperatures are always white; the hours are gray, like the sun labels.

At night the icon is the moon in its current phase, pale cream with its dark
seas filling in as it waxes. Partly cloudy puts a low cloud under it; mostly
cloudy (under 88% cloud cover) leaves only its top peeking over a big cloud;
overcast is cloud alone.

It refreshes every 15 minutes, so it shows no clock: a time drawn at that rate
would be up to 15 minutes stale. Sunrise and sunset are fixed for the day.
Weather is from Open-Meteo and the place from Zippopotam; neither needs a key.
