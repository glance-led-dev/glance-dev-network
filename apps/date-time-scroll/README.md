# Date & Time (Scroll) — local date, time, and current weather for a US zip code.

Format: DATE | TIME | weather ICON + TEMP + CONDITION.

Each section has its own configurable color. The whole line shares one
user-selected font (4x5/6x8/8x12/10x16/16x24) and only drops to a smaller
font if the full line — with real content — would overflow, so sizing stays
consistent instead of each section picking its own. At this width, the
condition word (e.g. "CLOUDY") is the first thing dropped if it still
doesn't fit even at the smallest font — the icon and temperature stay.

The temperature reading can either match the weather color, or follow a
hot/cold scale (icy blue when cold, ramping through green/yellow/orange to
red when hot).

This is the 192px-wide Scroll build of [Date & Time](../date-time).
