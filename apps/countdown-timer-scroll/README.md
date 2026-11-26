# Countdown Timer

Time left until a date and time, or time since it:

    GOING HOME
    6 DAYS, 10 HOURS, 23 MINUTES

Past the moment it reads `2 DAYS, 3 HOURS AGO`.

## Settings

- **Date, Hour, Minute, Time zone**: the target, as a wall-clock time in
  that zone. Daylight saving is handled.
- **Largest unit**: `DAYS` (16 DAYS, 4 HOURS) or `WEEKS` (2 WEEKS, 2 DAYS).
- **Detail**: how many units to show, from the largest non-zero one.
- **Soon from / Imminent from**: thresholds for the colour change. The
  count is green far off, dark yellow once under Soon from, red once
  under Imminent from, and gray once passed.
- **Name color**: colour of the event name (white by default).

The panel refreshes every 5 minutes (Glance's minimum for apps with a
free-text setting), so the minute count can lag by up to that.
